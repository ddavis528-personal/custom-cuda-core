#!/usr/bin/env python3
"""Stage 1a -- tool-support spike (RTL execution strategy §7, §8 Stage 1a, §9).

Runs every case in spike/cases/ through Verilator, Icarus Verilog and
sby/Yosys, and records for each cell not merely whether the construct PARSED
but whether it actually CHECKED -- i.e. whether the deliberately-violated
property in that case produced a failure.

The distinction is the entire point. A construct that parses and is silently
never checked looks exactly like a construct that passes, and §7's formal
posture is built on properties that bite. `SILENT` is therefore reported as a
worse outcome than `PARSE-FAIL`, not a better one.

Writes docs/stage1a-tool-support.md and test/golden/stage1a-matrix.json.
"""
import json
import os
import re
import shutil
import subprocess
import sys
import tempfile

ROOT = os.path.dirname(os.path.dirname(os.path.abspath(__file__)))
CASES = os.path.join(ROOT, "spike", "cases")
TB = os.path.join(ROOT, "spike", "tb", "tb_sim.sv")

# Markers that mean "a property failed". Deliberately broad: a tool that
# reports a failure in a shape not listed here would be scored SILENT, which
# is the conservative direction for a spike whose job is to find gaps.
FAIL_RE = re.compile(
    r"(%Error|ERROR:|\berror\b.*assert|assertion .*fail|assert.*\bfail|"
    r"violat|\bfired\b|Assertion failed)", re.I)
# Compile-time errors that are NOT property failures.
COMPILE_ERR_RE = re.compile(r"(syntax error|Unsupported|not supported|"
                            r"Cannot find|error: )", re.I)


def run(cmd, cwd=None, timeout=180):
    try:
        p = subprocess.run(cmd, cwd=cwd, capture_output=True, text=True,
                           timeout=timeout)
        return p.returncode, (p.stdout or "") + (p.stderr or "")
    except subprocess.TimeoutExpired:
        return 124, "TIMEOUT"
    except FileNotFoundError:
        return 127, "tool not found"


def relpaths(text):
    """Absolute build paths make a generated doc differ between machines for
    no reason, and the diff noise hides the real changes."""
    return text.replace(ROOT + "/", "").replace(ROOT, ".")


def first_error(text, limit=180):
    """The most informative single line, for the matrix's notes column."""
    text = relpaths(text)
    for line in text.splitlines():
        s = line.strip()
        if re.search(r"(error|Error|%Error|Unsupported|syntax)", s):
            return s[:limit]
    for line in text.splitlines():
        s = line.strip()
        if s:
            return s[:limit]
    return ""


def parse_meta(path):
    meta = {"runners": ["iverilog", "verilator", "sby"]}
    with open(path) as f:
        for line in f:
            if not line.startswith("//"):
                break
            m = re.match(r"//\s*(case|expect_sim|expect_formal|runners|aux):\s*(.+)",
                         line.strip())
            if m:
                k, v = m.group(1), m.group(2).strip()
                meta[k] = [x.strip() for x in v.split(",")] if k == "runners" else v
    return meta


def sim_verdict(rc, out, expect):
    """Classify a simulation run. `ran` is decided by the testbench markers,
    so a compile that fails is never mistaken for a property that stayed
    quiet."""
    if "SPIKE_BEGIN" not in out:
        return "PARSE-FAIL", first_error(out)
    body = out.split("SPIKE_BEGIN", 1)[1]
    fired = bool(FAIL_RE.search(body))
    if expect == "SILENCED":
        return ("SILENCED", "") if not fired else ("NOT-SILENCED", first_error(body))
    if expect == "PARSE":
        return "PARSE-OK", ""
    if expect in ("CHECK",):
        return ("CHECK", "") if fired else ("SILENT", "compiled and ran; never fired")
    return ("CHECK", "") if fired else ("SILENT", "")


# --------------------------------------------------------------------------
# Icarus Verilog
# --------------------------------------------------------------------------
def run_iverilog(case, aux, meta, workdir):
    if not shutil.which("iverilog"):
        return "NO-TOOL", "iverilog not installed"
    exe = os.path.join(workdir, "a.out")
    src = [TB, case] + ([aux] if aux else [])
    # -g2012 is what enables the assertion grammar at all; without it the
    # constructs are not merely unsupported, they are syntax errors.
    rc, out = run(["iverilog", "-g2012", "-gassertions", "-o", exe, "-s", "tb"] + src)
    if rc != 0:
        return "PARSE-FAIL", first_error(out)
    rc, out = run(["vvp", exe], cwd=workdir)
    return sim_verdict(rc, out, meta.get("expect_sim", "CHECK"))


# --------------------------------------------------------------------------
# Verilator
# --------------------------------------------------------------------------
def run_verilator(case, aux, meta, workdir):
    if not shutil.which("verilator"):
        return "NO-TOOL", "verilator not installed"
    src = [TB, case] + ([aux] if aux else [])
    # --assert is not a default. Without it Verilator elaborates assertions and
    # checks nothing -- the exact SILENT failure mode this spike exists to find,
    # available as a flag mistake rather than a tool limitation.
    cmd = ["verilator", "--binary", "-j", "0", "--assert", "--timing",
           "-Wno-fatal", "--top-module", "tb",
           "--Mdir", os.path.join(workdir, "obj")] + src
    rc, out = run(cmd, cwd=workdir, timeout=300)
    if rc != 0:
        return "PARSE-FAIL", first_error(out)
    exe = os.path.join(workdir, "obj", "Vtb")
    if not os.path.exists(exe):
        return "PARSE-FAIL", "no executable produced: " + first_error(out)
    rc, out = run([exe], cwd=workdir)
    return sim_verdict(rc, out, meta.get("expect_sim", "CHECK"))


# --------------------------------------------------------------------------
# sby / Yosys
# --------------------------------------------------------------------------
def sby_engine():
    """Pick an engine that exists here. Recorded in the results, because
    "formal works" is a claim about a solver as much as about Yosys.

    Order is empirical, not preference. The 1a run found that Debian's
    boolector (1.5, 2012) is too old for yosys-smtbmc and dies with a broken
    pipe, and that the `abc bmc3` engine crashes on the witness format this
    sby/Yosys pairing produces. cvc5 is what actually completes."""
    for exe, eng, name in (("cvc5", "smtbmc cvc5", "cvc5"),
                           ("yices-smt2", "smtbmc yices", "yices"),
                           ("z3", "smtbmc z3", "z3"),
                           ("boolector", "smtbmc boolector", "boolector")):
        if shutil.which(exe):
            return eng, name
    return "abc bmc3", "abc (bundled)"


ENGINE, ENGINE_NAME = sby_engine()


def run_sby(case, aux, meta, workdir):
    if not shutil.which("sby") or not shutil.which("yosys"):
        return "NO-TOOL", "sby/yosys not installed"
    expect = meta.get("expect_formal", "CHECK")
    if expect == "SKIP":
        return "N/A", "not a formal construct"
    mode = "cover" if expect == "COVER" else "bmc"
    files = [case] + ([aux] if aux else [])
    reads = "\n".join("read_verilog -sv -formal %s" % os.path.basename(f)
                       for f in files)
    for f in files:
        shutil.copy(f, workdir)
    sby = """[options]
mode {mode}
depth 12
expect pass,fail

[engines]
{engine}

[script]
{reads}
prep -top dut

[files]
{filelist}
""".format(mode=mode, engine=ENGINE, reads=reads,
           filelist="\n".join(os.path.basename(f) for f in files))
    p = os.path.join(workdir, "case.sby")
    with open(p, "w") as f:
        f.write(sby)
    rc, out = run(["sby", "-f", "case.sby"], cwd=workdir, timeout=300)
    # A Yosys front-end rejection is a PARSE-FAIL, not an engine error. The two
    # are worth distinguishing: a parse failure is a statement about the SVA
    # subset (which is what this spike measures), an engine error is a
    # statement about the solver install (which is not).
    if re.search(r"ERROR: syntax error|ERROR: Can't open|is not a valid",
                 out) and "DONE (PASS" not in out and "DONE (FAIL" not in out:
        return "PARSE-FAIL", first_error(out)
    if "DONE (PASS" in out:
        # A knowingly-false property that PASSES was dropped before the solver.
        if expect == "CHECK":
            return "SILENT", "BMC passed a property written to be false"
        if expect == "PROVE":
            return "PROVE-PASS", "assume honoured -- cut-point usable"
        if expect == "COVER":
            return "COVER-HIT", ""
        return "PARSE-OK", ""
    if "DONE (FAIL" in out:
        if expect == "CHECK":
            return "CHECK", ""
        if expect == "PROVE":
            return "PROVE-FAIL", "assume did not constrain -- cut-point NOT usable"
        if expect == "COVER":
            return "COVER-MISS", "cover unreachable"
        return "CHECK", ""
    if "DONE (UNKNOWN" in out or "DONE (ERROR" in out:
        return "ERROR", first_error(out)
    return "ERROR", first_error(out)



# --------------------------------------------------------------------------
# Out-of-band probes
#
# Three questions §8 Stage 1a asks that are not "does this construct compile",
# and so cannot be answered by a case run through the common testbench.
# --------------------------------------------------------------------------
def probe_x_randomization():
    """§6: does Verilator's X-randomization actually vary un-reset state?

    The mitigation §6 relies on is: randomize un-reset state, run the same
    test across several seeds, and treat divergence between seeds as a real
    dependency on uninitialized state. That is only a mitigation if the flags
    do something. Case 26's DUT has an un-reset control bit and drives it to
    the output, so two seeds must produce different output if randomization
    is working."""
    if not shutil.which("verilator"):
        return {"result": "NO-TOOL", "detail": "verilator not installed"}
    case = os.path.join(CASES, "26_isunknown_immediate.sv")
    tb = os.path.join(ROOT, "spike", "tb", "tb_xrand.sv")
    with tempfile.TemporaryDirectory() as wd:
        mdir = os.path.join(wd, "obj")
        rc, out = run(["verilator", "--binary", "-j", "0", "--assert", "--timing",
                       "--x-assign", "unique", "--x-initial", "unique",
                       "-Wno-fatal", "--top-module", "tb", "--Mdir", mdir,
                       tb, case], cwd=wd, timeout=300)
        exe = os.path.join(mdir, "Vtb")
        if not os.path.exists(exe):
            return {"result": "PARSE-FAIL", "detail": first_error(out),
                    "flags": "--x-assign unique --x-initial unique"}
        runs = {}
        for seed in (1, 2, 3, 4):
            rc, o = run([exe, "+verilator+rand+reset+2",
                         "+verilator+seed+%d" % seed], cwd=wd)
            body = o.split("SPIKE_BEGIN", 1)[-1]
            runs[seed] = re.findall(r"cyc=\d+ o=(\S+)", body)
        distinct = {tuple(v) for v in runs.values()}
    if len(distinct) > 1:
        return {"result": "VARIES", "seeds": len(distinct),
                "flags": "--x-assign unique --x-initial unique "
                         "+verilator+rand+reset+2 +verilator+seed+N",
                "detail": "%d distinct traces across 4 seeds -- un-reset state "
                          "dependency is detectable" % len(distinct)}
    return {"result": "IDENTICAL", "seeds": 1,
            "flags": "--x-assign unique --x-initial unique "
                     "+verilator+rand+reset+2 +verilator+seed+N",
            "detail": "all 4 seeds produced identical output; on this version "
                      "seed variation does NOT expose the un-reset dependency "
                      "in case 26, so the §6 blind spot stays open between "
                      "Icarus X-passes"}


def probe_interface_boundary():
    """§9/§1: can an interface sit on a block's top-level port list and still
    be Verilated into a C++ model? This is the block-swap question, not a
    style question."""
    out = {}
    case = os.path.join(CASES, "30_iface_top_boundary.sv")
    aux = os.path.join(CASES, "30_iface_top_boundary.aux.sv")
    if not os.path.exists(case):
        return {"result": "NO-CASE"}
    if shutil.which("verilator"):
        with tempfile.TemporaryDirectory() as wd:
            rc, o = run(["verilator", "--lint-only", "-Wno-fatal",
                         "--top-module", "blk", aux, case], cwd=wd)
            out["verilator_lint"] = "OK" if rc == 0 else first_error(o)
            mdir = os.path.join(wd, "obj")
            rc, o = run(["verilator", "--cc", "-Wno-fatal", "--top-module",
                         "blk", "--Mdir", mdir, aux, case], cwd=wd, timeout=240)
            hdr = os.path.join(mdir, "Vblk.h")
            if rc == 0 and os.path.exists(hdr):
                txt = open(hdr).read()
                # The swap mechanism needs the boundary signals reachable from
                # C++. An interface port that elaborates but exposes nothing is
                # not usable for it.
                exposed = ("valid" in txt) and ("ready" in txt)
                out["verilator_cc"] = ("C++ model built, boundary signals "
                                       + ("EXPOSED" if exposed else
                                          "NOT exposed"))
                out["result"] = "USABLE" if exposed else "ELABORATES-ONLY"
            else:
                out["verilator_cc"] = first_error(o) or "no C++ model produced"
                out["result"] = "NOT-USABLE"
    else:
        out["result"] = "NO-TOOL"
    if shutil.which("iverilog"):
        with tempfile.TemporaryDirectory() as wd:
            rc, o = run(["iverilog", "-g2012", "-o", os.path.join(wd, "x"),
                         "-s", "blk", aux, case])
            out["iverilog"] = "OK" if rc == 0 else first_error(o)
    if shutil.which("yosys"):
        with tempfile.TemporaryDirectory() as wd:
            for f in (aux, case):
                shutil.copy(f, wd)
            rc, o = run(["yosys", "-p",
                         "read_verilog -sv -formal %s %s; prep -top blk" %
                         (os.path.basename(aux), os.path.basename(case))],
                        cwd=wd)
            out["yosys"] = "OK" if rc == 0 else first_error(o)
    return out


def probe_verible():
    """§6/§9: Verible is the fourth tool the X-safety approach adds, and
    'lint enforces it' is load-bearing for the whole approach. So whether
    Verible is OBTAINABLE is itself a 1a finding, before whether its rule
    language can express the rules."""
    if shutil.which("verible-verilog-lint"):
        _, o = run(["verible-verilog-lint", "--version"])
        return {"result": "PRESENT", "detail": o.strip().splitlines()[0]}
    return {"result": "ABSENT",
            "detail": "verible-verilog-lint not on PATH; upstream ships only "
                      "GitHub release binaries, which are not reachable from "
                      "this environment"}


RUNNERS = [("iverilog", run_iverilog), ("verilator", run_verilator),
           ("sby", run_sby)]

# Cells whose verdict means the construct is usable by the 1b primitive library.
GOOD = {"CHECK", "COVER-HIT", "PROVE-PASS", "PARSE-OK", "SILENCED", "N/A"}


def main():
    cases = sorted(f for f in os.listdir(CASES)
                   if f.endswith(".sv") and ".aux." not in f)
    results = []
    for cf in cases:
        path = os.path.join(CASES, cf)
        meta = parse_meta(path)
        auxp = os.path.join(CASES, meta["aux"]) if meta.get("aux") else None
        row = {"file": cf, "case": meta.get("case", cf),
               "expect_sim": meta.get("expect_sim", "CHECK"),
               "expect_formal": meta.get("expect_formal", "CHECK"),
               "cells": {}}
        for name, fn in RUNNERS:
            if name not in meta["runners"]:
                row["cells"][name] = {"verdict": "N/A", "note": "not applicable"}
                continue
            with tempfile.TemporaryDirectory() as wd:
                v, note = fn(path, auxp, meta, wd)
            row["cells"][name] = {"verdict": v, "note": note}
            print("  %-34s %-10s %s" % (cf, name, v), flush=True)
        results.append(row)
    print("\n  -- out-of-band probes --", flush=True)
    probes = {"x_randomization": probe_x_randomization(),
              "interface_boundary": probe_interface_boundary(),
              "verible": probe_verible()}
    for k, v in probes.items():
        print("  %-34s %s" % (k, v.get("result", "?")), flush=True)
    out = {"engine": ENGINE_NAME, "cases": results,
           "probes": probes, "tools": tool_versions()}
    os.makedirs(os.path.join(ROOT, "test", "golden"), exist_ok=True)
    with open(os.path.join(ROOT, "test", "golden", "stage1a-matrix.json"), "w") as f:
        json.dump(out, f, indent=2, sort_keys=True)
    write_doc(out)
    return 0


def tool_versions():
    v = {}
    for name, cmd in (("verilator", ["verilator", "--version"]),
                      ("iverilog", ["iverilog", "-V"]),
                      ("yosys", ["yosys", "-V"]),
                      ("sby", ["sby", "--version"])):
        if shutil.which(cmd[0]):
            _, o = run(cmd)
            v[name] = o.strip().splitlines()[0] if o.strip() else "?"
        else:
            v[name] = "NOT INSTALLED"
    v["verible"] = ("NOT INSTALLED" if not shutil.which("verible-verilog-lint")
                    else "present")
    return v


def write_doc(out):
    from datetime import date
    L = []
    L.append("# Stage 1a — SVA support across the free toolchain\n")
    L.append("**Generated by `tools/run-spike-1a.py`. Do not edit by hand — "
             "rerun it.**\n")
    L.append("Generated %s.\n" % date.today().isoformat())
    L.append("This is the written matrix §8's Stage 1 exit criteria ask for: "
             "SVA constructs × three tools, pass/fail per cell, with a named "
             "usable subset.\n")
    L.append("## Tool versions\n")
    L.append("| Tool | Version |")
    L.append("|---|---|")
    for k, v in sorted(out["tools"].items()):
        L.append("| `%s` | %s |" % (k, v))
    L.append("")
    L.append("Formal engine: **%s**.\n" % out["engine"])
    L.append("## Verdicts\n")
    L.append("| Verdict | Meaning |")
    L.append("|---|---|")
    for k, d in [
        ("`CHECK`", "Compiled, ran, and the deliberately-violated property "
         "**fired**. Usable."),
        ("`SILENT`", "Compiled and ran and **never fired**. The dangerous cell: "
         "indistinguishable from a passing property. Treated as worse than a "
         "parse failure."),
        ("`PARSE-FAIL`", "Rejected at compile. Honest, and cheap to work around."),
        ("`PARSE-OK`", "Compiled; the case asserts nothing to fire (`assume`, "
         "`restrict`, liveness under BMC)."),
        ("`SILENCED`", "`$assertoff` suppressed a property that case 01 shows "
         "does fire otherwise. The §7 runtime knob works."),
        ("`NOT-SILENCED`", "`$assertoff` parsed and did nothing."),
        ("`PROVE-PASS`", "Formal proved a property that is false without the "
         "`assume`. Positive evidence the cut-point mechanism works."),
        ("`PROVE-FAIL`", "The `assume` did not constrain. Cut-points unusable."),
        ("`COVER-HIT` / `COVER-MISS`", "Reachability established / not."),
    ]:
        L.append("| %s | %s |" % (k, d))
    L.append("")
    L.append("## The matrix\n")
    L.append("| # | Construct | Icarus | Verilator | sby/Yosys |")
    L.append("|---|---|---|---|---|")
    for r in out["cases"]:
        num = r["file"].split("_")[0]
        cells = [r["cells"][t]["verdict"] for t in ("iverilog", "verilator", "sby")]
        # `|` inside a construct name (|->, |=>) would end the table cell.
        name = r["case"].replace("|", "\\|")
        L.append("| %s | %s | %s | %s | %s |" %
                 (num, name, *["`%s`" % c for c in cells]))
    L.append("")
    L.append("## Out-of-band probes\n")
    L.append("Three Stage 1a questions that are not \"does this construct "
             "compile\", and so are asked directly rather than through a "
             "case.\n")
    pr = out.get("probes", {})
    for key, title in (("x_randomization",
                        "Verilator X-randomization (§6)"),
                       ("interface_boundary",
                        "SystemVerilog `interface` on a block boundary (§9, §1)"),
                       ("verible", "Verible availability (§6, §9)")):
        d = pr.get(key, {})
        L.append("**%s** — `%s`\n" % (title, d.get("result", "not run")))
        for k, v in sorted(d.items()):
            if k == "result":
                continue
            L.append("- `%s`: %s" % (k, v))
        L.append("")

    notes = [(r, t) for r in out["cases"] for t in ("iverilog", "verilator", "sby")
             if r["cells"][t]["note"]]
    if notes:
        L.append("## Cell notes\n")
        for r, t in notes:
            L.append("- **%s / %s** — `%s`: %s" %
                     (r["file"].split("_")[0], t, r["cells"][t]["verdict"],
                      r["cells"][t]["note"]))
        L.append("")
    usable = [r for r in out["cases"]
              if all(r["cells"][t]["verdict"] in GOOD
                     for t in ("iverilog", "verilator", "sby"))]
    L.append("## The usable subset\n")
    L.append("Constructs green in **all three** tools. Stage 1b's primitive "
             "library may use these and nothing else; anything outside this "
             "list needs an explicit per-tool exception recorded here first.\n")
    for r in usable:
        L.append("- %s (case %s)" % (r["case"], r["file"].split("_")[0]))
    if not usable:
        L.append("- *(none)* — see the matrix above.")
    L.append("")
    path = os.path.join(ROOT, "docs", "stage1a-tool-support.md")
    with open(path, "w") as f:
        f.write("\n".join(L) + "\n")
    print("\nwrote docs/stage1a-tool-support.md and "
          "test/golden/stage1a-matrix.json")


if __name__ == "__main__":
    sys.exit(main())
