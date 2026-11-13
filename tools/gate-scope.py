#!/usr/bin/env python3
"""Which of the gate's sections a change needs (OI-95; DA, 2026-10-31).

    tools/gate-scope.py <base>       the sections for HEAD and the tree since <base>
    tools/gate-scope.py --paths p..  the sections for these paths
    tools/gate-scope.py --selftest   the map's negative controls

Prints `ALL` or the section names (tools/verify.sh's jobs), one line, then
one `# <path>: <sections>` line per changed path. verify.sh --changed <base>
runs those sections and the ones they wait on; the generators, the staleness
check, the toolchain, lint and the interface checks run every time
(ALWAYS). The map is a list of path prefixes, the first match wins. A path
it does not name, and anything under schema/ or params/ or the gate's own
tools, runs the whole gate: a gap in the map costs a gate's time, never a
check. The daily sweep's merge, every release and the nightly run the full
clean gate whatever this says.
"""
import os
import re
import subprocess
import sys

ROOT = os.path.dirname(os.path.dirname(os.path.abspath(__file__)))
ALL = "ALL"
ALWAYS = ["s1a", "s1d", "iface", "vlint"]
# Every section that reads RTL, its benches or its synthesis flow.
RTL = ["s1b", "xprop", "ctech", "cg", "ngd", "clockgate", "ooe_rtl", "rcu_rtl", "rcu_ls",
       "top", "formal", "phys", "svh", "links"]
# The sections that read RI's RCU RTL and its benches (RI-10; rcu_rtl, RI's
# re:TI-371: test/rcu/run-rtl.sh), and, since RI's assembled ccv_rcu (RI-33)
# makes rcu an RTL top (tools/ccv_links.py rtl_tops()), those that read its
# generated wrapper rtl/top/wrap/ccv_rcu_w.sv or the no-flop rule it moves:
# the SV top, SV-hosted C++ and the links split (which regenerates the top in
# a copy of the tree and holds rcu's ends to the RTL-top rule). And rcu_ls,
# the block in lock-step with the model (RI's test/rcu/run-lockstep.sh, which
# the gate adopted for TI's rcu_blk, RI-36, RI-37), which builds ccv_rcu
# from rtl/rcu/, and its TI control tools/rcu-ls-corrupt.py.
RCU_RTL = ["cg", "ngd", "rcu_rtl", "rcu_ls", "top", "svh", "links"]
# The readers of rtl/rcu/ outside check-cg and check-ngd that RCU_RTL maps,
# each with the sections that read it; any other reader fails the selftest.
RCU_READERS = {
    "rtl/top/wrap/ccv_rcu_w.sv": ["top", "svh", "links"],
}
# First match wins: the more specific prefix comes first.
MAP = [
    # The sources of truth everything is generated from, and the gate itself.
    ("schema/", ALL),
    ("params/", ALL),
    ("tools/verify.sh", ALL),
    ("tools/gate-scope.py", ALL),
    ("tools/shim/", ALL),
    ("tools/genout.py", ALL),
    ("tools/check-ngd.py", ["ngd"]),
    ("tools/check-cg.py", ["cg", "ngd"]),   # check-ngd imports it
    ("tools/heavy-units.json", ["cg", "ngd"]),     # both read it, through check-cg
    ("tools/check-kernel.sh", ["kernel", "svh"]),
    ("tools/check-sv-hosted.sh", ["svh"]),
    ("tools/check-skel.sh", ["skel", "kernel", "svh", "top"]),
    ("tools/check-if.sh", ["iface"]),
    ("tools/check-ooe-unit.sh", ["ooe_unit"]),
    ("tools/check-formal.sh", ["formal"]),
    ("tools/check-phys.sh", ["phys"]),
    ("tools/check-links.sh", ["links"]),
    ("tools/check-top.sh", ["top"]),
    ("tools/check-xprop.sh", ["xprop"]),
    ("tools/check-ctech.sh", ["ctech"]),
    ("tools/check-clockgate.sh", ["clockgate"]),
    # The RCU block lock-step's corrupt-output control (TI's; the lock-step
    # itself is RI's, test/rcu/, in RCU_RTL).
    ("tools/rcu-ls-corrupt.py", ["rcu_ls"]),
    # Not the gate's: the push, sweep and release scripts and the summary.
    ("tools/gate-combine.py", ["iface"]),         # its selftest runs there
    ("tools/gate-export.sh", []),
    ("tools/gate-scratch.sh", []),
    ("tools/gate-push.sh", []),
    ("tools/gate-summary.py", []),
    ("tools/bg-run.sh", []),
    ("tools/daily-sweep.sh", []),
    ("tools/push-lib.sh", []),
    ("tools/make-release.sh", []),
    ("tools/setup-session-home.py", []),
    ("tools/", ALL),
    # The OOE model is the reference the OOE RTL is compared against.
    ("sim/ooe/", ["skel", "kernel", "ooe_unit", "ooe_rtl", "svh"]),
    # The RCU model (RI-2): built into both hosts (blocks.list), so the
    # kernels and the SV top read it, and its own harness.
    # And the block's lock-step job, which replays the model's port dump
    # into the RTL (rcu_ls).
    ("sim/rcu/", ["skel", "kernel", "rcu_unit", "rcu_ls", "svh"]),
    # The skeleton writes rcu_ls's port dumps (sim/skel/portdump.cpp).
    ("sim/skel/", ["skel", "kernel", "rcu_ls", "svh", "top"]),
    ("sim/", ALL),
    ("rtl/lint/", ["s1d"] + RTL),
    # RI's RCU RTL (RI-10, RA-37): check-cg and check-ngd (their rtl/**
    # globs and test/rcu/cg-units.json), RI's benches, and the sections that
    # read the generated wrapper that instantiates ccv_rcu (RI-33,
    # RCU_READERS); lint and vlint always run. The selftest fails when
    # anything else reads it.
    ("rtl/rcu/", RCU_RTL),
    # The hard macros' views: every RTL section, and check-skel's lockstep
    # of the SRAM model against them (test/vl/vl_sram_tb.cpp).
    ("rtl/macro/", RTL + ["skel"]),
    ("rtl/", RTL),
    ("test/kernels/", ["kernel", "rcu_ls", "svh"]),
    ("test/ooe/", ["ooe_rtl", "cg", "ngd"]),
    ("test/rcu/", RCU_RTL),
    ("test/cg/", ["cg"]),
    # The hard macros' fixture (AR's register rev 344): both selftests'.
    ("test/macro/", ["cg", "ngd"]),
    # The SRAM model's lockstep against rtl/macro/ (check-skel).
    ("test/vl/vl_sram_", ["skel"]),
    ("test/ngd/", ["ngd"]),
    ("test/neg/", ["iface"]),
    ("test/formal/", ["formal"]),
    ("test/phys/", ["phys", "cg"]),
    ("test/top/", ["top", "svh"]),
    ("test/", ALL),
    # Prose and the register's own files: no section reads them. The
    # generated docs are the staleness check's, which always runs.
    ("docs/", []),
    (".claude/", []),
    ("CLAUDE.md", []),
    ("README.md", []),
]


def jobs():
    """verify.sh's sections, from its ORDER, so the map cannot name one
    that does not exist."""
    s = open(os.path.join(ROOT, "tools", "verify.sh")).read()
    m = re.search(r'^ORDER="([^"]*)"', s, re.M)
    return m.group(1).split()


def scope_of(path):
    for pre, js in MAP:
        if path == pre or path.startswith(pre):
            return js
    return ALL


def scope(paths):
    """(ALL or a sorted list of sections, per-path detail)."""
    out, detail = set(ALWAYS), []
    whole = False
    for p in paths:
        js = scope_of(p)
        detail.append((p, js))
        if js == ALL:
            whole = True
        else:
            out |= set(js)
    if whole:
        return ALL, detail
    order = jobs()
    return [j for j in order if j in out], detail


def changed(base):
    git = ["git", "-C", ROOT]
    r = subprocess.run(git + ["diff", "--name-only", "--no-renames", base + "...HEAD"],
                       capture_output=True, text=True)
    if r.returncode:
        sys.exit("gate-scope: cannot diff against %s: %s" % (base, r.stderr.strip()))
    paths = set(r.stdout.split())
    # The tree too: verify.sh checks what is on disk, not only what is committed.
    st = subprocess.run(git + ["status", "--porcelain", "--no-renames", "-uall"],
                        capture_output=True, text=True).stdout
    paths |= {l[3:] for l in st.splitlines() if len(l) > 3}
    return sorted(paths)


def rcu_rtl_readers(root=ROOT):
    """What reads rtl/rcu/ beyond check-cg and check-ngd: an RTL file
    elsewhere under rtl/ that instantiates one of its modules, or a tool,
    test script or CI file that names the directory."""
    import glob
    mods = set()
    for f in glob.glob(os.path.join(root, "rtl", "rcu", "**", "*.sv"), recursive=True):
        mods |= set(re.findall(r"^\s*module\s+(\w+)", open(f).read(), re.M))
    out = []
    if mods:
        inst = re.compile(r"^\s*(%s)\b\s*(#\s*\(|\w+\s*\()" % "|".join(sorted(mods)), re.M)
        for f in glob.glob(os.path.join(root, "rtl", "**", "*.sv"), recursive=True):
            rel = os.path.relpath(f, root)
            if not rel.startswith("rtl/rcu/") and inst.search(open(f).read()):
                out.append(rel)
    allowed = {"tools/gate-scope.py", "tools/check-cg.py", "tools/check-ngd.py"}
    for pat in ("tools/*", "test/**/*.sh", "test/**/*.py", ".github/workflows/*"):
        for f in glob.glob(os.path.join(root, pat), recursive=True):
            rel = os.path.relpath(f, root)
            if rel.startswith("test/rcu/") or rel in allowed or not os.path.isfile(f):
                continue
            try:
                if "rtl/rcu" in open(f, errors="replace").read():
                    out.append(rel)
            except OSError:
                pass
    return out


def selftest():
    bad = []
    order = jobs()

    def expect(c, what):
        if not c:
            bad.append(what)
    for pre, js in MAP:
        if js != ALL:
            for j in js:
                expect(j in order, "the map names a section verify.sh has not: %s (%s)" % (j, pre))
    for j in ALWAYS + RTL:
        expect(j in order, "ALWAYS or RTL names a section verify.sh has not: %s" % j)
    # Each a control: the map must answer ALL here, or the named sections.
    expect(scope(["schema/interfaces.json"])[0] == ALL, "a schema change was scoped")
    expect(scope(["params/ccv_params.json"])[0] == ALL, "a params change was scoped")
    expect(scope(["somewhere/new.txt"])[0] == ALL, "a path the map does not name was scoped")
    expect(scope(["tools/verify.sh"])[0] == ALL, "a change to the gate itself was scoped")
    expect(scope(["tools/new-check.py"])[0] == ALL, "a new tool was scoped")
    expect(scope(["test/new/x.sv"])[0] == ALL, "a new test directory was scoped")
    expect(scope(["sim/src/x.cpp"])[0] == ALL, "ccv-sim's side of sim/ was scoped")
    s, _ = scope(["rtl/ooe/ooe_rob_w.sv"])
    expect(s != ALL and {"cg", "ngd", "ooe_rtl", "svh", "top"} <= set(s),
           "an OOE RTL change skips a section that reads it: %s" % s)
    s, _ = scope(["sim/ooe/ooe_core.cpp"])
    expect(s != ALL and {"kernel", "ooe_unit", "ooe_rtl", "skel", "svh"} <= set(s),
           "an OOE model change skips a section that reads it: %s" % s)
    s, _ = scope(["sim/rcu/rcu_core.cpp"])
    expect(s != ALL and {"kernel", "rcu_unit", "rcu_ls", "skel", "svh"} <= set(s),
           "an RCU model change skips a section that reads it: %s" % s)
    s, _ = scope(["rtl/rcu/rcu_bank_slice.sv", "test/rcu/cg-units.json"])
    expect(s != ALL and {"cg", "ngd", "rcu_rtl", "rcu_ls", "top", "svh", "links"} <= set(s)
           and "ooe_rtl" not in s,
           "an RCU RTL change is not scoped to check-cg, check-ngd, its benches and "
           "the sections that read its wrapper: %s" % s)
    s, _ = scope(["rtl/rcu/ccv_rcu.sv"])
    for x, js in RCU_READERS.items():
        expect(s != ALL and set(js) <= set(s),
               "an RCU RTL change skips a section that reads %s: %s" % (x, s))
    s, _ = scope(["test/rcu/r_tb.cpp"])
    expect(s != ALL and "rcu_rtl" in s, "an RCU bench change skips the benches: %s" % s)
    # The block's lock-step job (RI's, adopted for rcu_blk; RI-36, RI-37):
    # the RTL, the model, the skeleton that dumps its ports, the kernels it
    # runs, the port list and packages it reads, its scripts and TI's control
    # each reach it.
    for p in ("rtl/rcu/ccv_rcu.sv", "rtl/rcu/rcu_dec_pkg.sv", "sim/rcu/rcu_block.cpp",
              "sim/skel/portdump.cpp", "sim/skel/channel.h", "test/kernels/vadd/kernel.cfg",
              "rtl/top/ports/ccv_rcu_ports.svh", "rtl/generated/ccv_params_pkg.sv",
              "test/rcu/run-lockstep.sh", "test/rcu/lockstep.py", "tools/rcu-ls-corrupt.py"):
        s, _ = scope([p])
        expect(s != ALL and "rcu_ls" in s, "%s skips the RCU block lock-step job: %s" % (p, s))
    # RCU_RTL holds only while nothing else reads rtl/rcu/: no RTL outside it
    # instantiates its modules but the readers RCU_READERS maps, each within
    # RCU_RTL, and no script but the two names it.
    for x, js in RCU_READERS.items():
        expect(set(js) <= set(RCU_RTL),
               "RCU_READERS maps %s to sections outside RCU_RTL: %s" % (x, js))
    for x in rcu_rtl_readers():
        if x not in RCU_READERS:
            bad.append("rtl/rcu/ is read by %s, outside RCU_RTL's sections: map it there" % x)
    # Its control: a tree where the top instantiates an RCU module and a
    # script names the directory must show both.
    import tempfile
    with tempfile.TemporaryDirectory() as t:
        for rel, text in (("rtl/rcu/rcu_x.sv", "module rcu_x (input logic a);\nendmodule\n"),
                          ("rtl/top/top.sv", "module top;\n  rcu_x u_x (.a(1'b0));\nendmodule\n"),
                          ("tools/check-x.sh", "verilator rtl/rcu/rcu_x.sv\n"),
                          ("tools/check-cg.py", "glob('rtl/rcu')\n")):
            os.makedirs(os.path.dirname(os.path.join(t, rel)), exist_ok=True)
            open(os.path.join(t, rel), "w").write(text)
        got = sorted(rcu_rtl_readers(t))
        expect(got == ["rtl/top/top.sv", "tools/check-x.sh"],
               "a reader of rtl/rcu/ outside check-cg and check-ngd went unseen: %s" % got)
    s, _ = scope(["docs/roadmap.md"])
    expect(s == [j for j in order if j in ALWAYS], "a prose change ran more than ALWAYS: %s" % s)
    s, _ = scope(["docs/roadmap.md", "params/links.json"])
    expect(s == ALL, "ALL lost to a scoped path beside it")
    for x in bad:
        sys.stderr.write("gate-scope selftest: %s\n" % x)
    if not bad:
        print("  gate scope: every section named exists; schema, params, the gate, "
              "unmapped paths run all; RTL and model changes reach their sections")
    return 1 if bad else 0


def main():
    a = sys.argv[1:]
    if a == ["--selftest"]:
        return selftest()
    if a[:1] == ["--paths"]:
        paths = a[1:]
    elif len(a) == 1:
        paths = changed(a[0])
    else:
        sys.exit(__doc__)
    s, detail = scope(paths)
    print(ALL if s == ALL else " ".join(s))
    for p, js in detail:
        print("# %s: %s" % (p, js if js == ALL else " ".join(js) or "(none)"))
    return 0


if __name__ == "__main__":
    sys.exit(main())
