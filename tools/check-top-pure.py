#!/usr/bin/env python3
"""THE TOP-LEVEL RULE, checked on the elaborated netlist, at both levels of
the physical hierarchy: ccv_core_top holds hardening wrappers and the nets
between them, and each wrapper holds its block, its repeaters and the nets
between them -- and nothing else.

  tools/check-top-pure.py [--mutate=gate|tie|flop|float|unloaded|wrapgate|wraptie]

Why a hard rule (rtl-coding-style.md, "The top level"): everything the core
does is then inside a block, where a block's own checks see it, and the rest
is pure connectivity, which the wiring check validates bit for bit. And the
floorplan can abut the wrappers: no cell outside a block or a repeater needs
a place to sit, and no glue hides between two of them. The first thing it
moved was the clock gates: each block gates core_clk inside itself, on its
own quiescence or stall, so the signals that decide sleep never leave it.

Yosys elaborates the top (with `proc`, so a stray always-block becomes a
cell), and on ccv_core_top and on every wrapper module:

  R1  every cell is what that level may hold: at the top, the 45 wrappers,
      one per block instance, named for it; in a wrapper, exactly one block
      (u_blk) of the wrapper's type, and sequential repeaters (u_rpt_*,
      u_ft_*). Under CCV_CHECK the top may also hold the one checker bank
  R2  no constant on any cell port, and none on the module's own ports: a
      tie-off is a cell in a netlist, and a decision nobody owns
  R3  every bit a cell reads is driven, by exactly one cell output or module
      input port
  R4  every bit a cell drives is read, by a cell or a module output port:
      an unloaded output is logic with nowhere to go
  R5  every module output port bit is driven by a cell

The synthesis view (no defines) is held to all of it. The checking view
(CCV_CHECK, CCV_TRACE) may add the checker bank, which observes: its ports
may take constants and its inputs are loads, but it may drive nothing.

--mutate edits a temporary copy so that it breaks one rule, and the check
must then fail, naming that rule:
  gate      a top-level clock gate, as the top used to have   R1
  tie       a wrapper's reset tied high at the top            R2
  flop      a top-level flop between two wrappers             R1
  float     a wrapper's reset left unconnected                R3
  unloaded  a wrapper output disconnected                     R4
  wrapgate  a clock gate inside FET's wrapper                 R1
  wraptie   FET's block reset tied high inside its wrapper    R2
"""
import json
import os
import re
import subprocess
import sys
import tempfile

ROOT = os.path.dirname(os.path.dirname(os.path.abspath(__file__)))
TOP = os.path.join(ROOT, "rtl", "top", "ccv_core_top.sv")
BANK = "ccv_skel_checkers"


def expected_instances():
    """Instance name -> (block type, instance name without u_)."""
    b = json.load(open(os.path.join(ROOT, "params", "blocks.json")))
    want = {}
    for x in b["blocks"]:
        n = x["instances"]
        for i in range(n):
            nm = x["name"] if n == 1 else "%s_%02d" % (x["name"], i)
            want["u_" + nm] = (x["name"], nm)
    return want


def base(t):
    """A cell type without Yosys's parameter decoration: $paramod\\ccv_lane_w\\
    RPT_...=1 and $paramod$<hash>\\ccv_seq_rpt are ccv_lane_w and ccv_seq_rpt."""
    m = re.match(r"^\$paramod[^\\]*\\([^\\]+)", t)
    return m.group(1) if m else t


def elaborate(files, defines, tmp):
    """The design as Yosys elaborates it. The checker bank, where there is
    one, is read as a blackbox: its PORTS are what the rule is about, and
    its 345 checkers' bodies would take Yosys minutes to elaborate."""
    out = os.path.join(tmp, "top.json")
    rv = "read_verilog -sv -formal %s -Irtl/include -Irtl/generated -Irtl/top/ports" \
        % " ".join("-D" + d for d in defines)
    script = "%s rtl/ccv_assert_pkg.sv; " % rv
    if defines:
        script += "%s -lib rtl/generated/ccv_skel_checkers.sv; " % rv
    script += ("%s %s; hierarchy -check -top ccv_core_top; proc; "
               "write_json %s" % (rv, " ".join(files), out))
    r = subprocess.run(["yosys", "-q", "-p", script], cwd=ROOT,
                       capture_output=True, text=True)
    if r.returncode:
        sys.exit("yosys failed: %s" % (r.stderr or r.stdout)[:600])
    return json.load(open(out))["modules"]


def check(where, mod, modules, allowed):
    """[(rule, message)] for everything in one module that is not an allowed
    cell or a net between cells. `allowed(name, base type)` returns None to
    accept a cell, "bank" for the observing checker bank, or why not."""
    bad = []
    cells, bank = {}, None
    for name, c in mod["cells"].items():
        why = allowed(name, base(c["type"]))
        if why == "bank" and bank is None:
            bank = (name, c)
        elif why is None:
            cells[name] = c
        else:
            bad.append(("R1", "%s: cell %s of type %s %s"
                        % (where, name, base(c["type"]), why)))

    drivers, loads = {}, {}
    for pname, p in mod["ports"].items():
        for b in p["bits"]:
            if isinstance(b, str):
                bad.append(("R2", "%s: port %s has a constant bit" % (where, pname)))
                break
            (drivers if p["direction"] == "input" else loads) \
                .setdefault(b, []).append("port " + pname)
    for name, c in cells.items():
        # A port left out of the instance, or connected empty, is not in
        # `connections` at all: compare with the module's own port list.
        for pname, p in modules[c["type"]]["ports"].items():
            if len(c["connections"].get(pname, [])) != len(p["bits"]):
                bad.append(("R3" if p["direction"] == "input" else "R4",
                            "%s: %s.%s is not connected" % (where, name, pname)))
        for pname, bits in c["connections"].items():
            dr = c["port_directions"][pname]
            if any(isinstance(b, str) for b in bits):
                bad.append(("R2", "%s: %s.%s is tied to a constant" % (where, name, pname)))
            for b in bits:
                if not isinstance(b, str):
                    (drivers if dr == "output" else loads) \
                        .setdefault(b, []).append("%s.%s" % (name, pname))
    bank_loads = set()
    if bank:
        for pname, bits in bank[1]["connections"].items():
            if bank[1]["port_directions"][pname] == "output":
                bad.append(("R1", "%s: the checker bank drives %s" % (where, pname)))
            bank_loads.update(b for b in bits if not isinstance(b, str))

    for b, who in loads.items():
        d = drivers.get(b, [])
        if len(d) != 1:
            bad.append(("R3" if not who[0].startswith("port ") else "R5",
                        "%s: %s reads a bit with %s" % (where, who[0], "no driver" if not d
                                                        else "drivers " + ", ".join(d))))
    for b, who in drivers.items():
        if len(who) > 1:
            continue                 # already reported as a doubled driver
        if b not in loads and b not in bank_loads:
            bad.append(("R4", "%s: %s drives a bit nothing reads" % (where, who[0])))
    # One line per rule and port, not per bit.
    seen, out = set(), []
    for r, m in bad:
        k = (r, re.sub(r"\s.*", "", m.split(": ", 1)[1]))
        if (where, k) not in seen:
            seen.add((where, k))
            out.append((r, m))
    return out, len(cells), bank is not None


def check_all(modules, with_bank):
    want = expected_instances()
    top = modules["ccv_core_top"]

    def top_allowed(name, t):
        if with_bank and t == BANK:
            return "bank"
        if name not in want:
            return "is not a wrapper instance"
        btype, nm = want[name]
        if t not in ("ccv_%s_w" % btype, "ccv_%s_w" % nm):
            return "is not %s's wrapper (ccv_%s_w or ccv_%s_w)" % (name, btype, nm)
        return None

    bad, nw, has_bank = check("ccv_core_top", top, modules, top_allowed)
    present = set(n for n, c in top["cells"].items() if top_allowed(n, base(c["type"])) is None)
    for name in sorted(set(want) - present):
        bad.append(("R1", "ccv_core_top: wrapper %s is missing" % name))
    if with_bank and not has_bank:
        bad.append(("R1", "ccv_core_top: no checker bank under CCV_CHECK"))

    # Every wrapper module the top instantiates, parameterised or not.
    nwrap = 0
    for mname in sorted({c["type"] for c in top["cells"].values()}):
        t = base(mname)
        if not t.endswith("_w"):
            continue
        nwrap += 1
        btype = next((bt for bt, nm in want.values()
                      if t in ("ccv_%s_w" % bt, "ccv_%s_w" % nm)), None)
        seen_blk = []

        def w_allowed(name, ct, btype=btype, seen_blk=seen_blk):
            if name == "u_blk" and ct == "ccv_%s" % btype:
                seen_blk.append(name)
                return None
            if ct == "ccv_seq_rpt" and re.match(r"^u_(rpt|ft)_", name):
                return None
            return "is not the wrapper's block (u_blk) or a repeater"

        b2, _, _ = check(t, modules[mname], modules, w_allowed)
        bad += b2
        if len(seen_blk) != 1:
            bad.append(("R1", "%s: %d block instances, want exactly one u_blk"
                        % (t, len(seen_blk))))
    return bad, nw, nwrap, has_bank


WRAP_FET = os.path.join(ROOT, "rtl", "top", "wrap", "ccv_fet_w.sv")
MUTATIONS = {
    # (rule it must break, file it edits, the edit)
    "gate": ("R1", TOP, lambda t: t.replace(
        ".core_clk(core_clk),", ".core_clk(syu_gclk),", 1).replace(
        "endmodule", "  wire syu_gclk = core_clk & rst_n;\nendmodule", 1)),
    "tie": ("R2", TOP, lambda t: t.replace(".rst_n(rst_n),", ".rst_n(1'b1),", 1)),
    "flop": ("R1", TOP, lambda t: t.replace(
        ".rst_n(rst_n),", ".rst_n(rst_q),", 1).replace(
        "endmodule", "  logic rst_q;\n  always_ff @(posedge core_clk) rst_q <= rst_n;\nendmodule", 1)),
    "float": ("R3", TOP, lambda t: t.replace(".rst_n(rst_n),", ".rst_n(),", 1)),
    "unloaded": ("R4", TOP, lambda t: t.replace(".kill_acks(kill_ack),",
                                                ".kill_acks(),", 1)),
    "wrapgate": ("R1", WRAP_FET, lambda t: t.replace(
        ".core_clk(core_clk),", ".core_clk(fet_gclk),", 1).replace(
        "endmodule", "  wire fet_gclk = core_clk & rst_n;\nendmodule", 1)),
    "wraptie": ("R2", WRAP_FET, lambda t: t.replace(
        "    .rst_n(rst_n),", "    .rst_n(1'b1),", 1)),
}


def sources(override=None):
    """The files Yosys reads: stubs, the repeater, the wrappers, the top --
    with one of them replaced by a mutated copy."""
    d = os.path.join(ROOT, "rtl", "top")
    files = sorted(os.path.join(d, "stubs", f) for f in os.listdir(os.path.join(d, "stubs")))
    files.append(os.path.join(ROOT, "rtl", "phys", "ccv_seq_rpt.sv"))
    files += sorted(os.path.join(d, "wrap", f) for f in os.listdir(os.path.join(d, "wrap")))
    files.append(TOP)
    if override:
        files = [override[1] if f == override[0] else f for f in files]
    return files


def main():
    mutate = None
    for a in sys.argv[1:]:
        if a.startswith("--mutate="):
            mutate = a.split("=", 1)[1]
            if mutate not in MUTATIONS:
                sys.exit("unknown mutation %s" % mutate)
    with tempfile.TemporaryDirectory() as tmp:
        override = None
        if mutate:
            _, path, edit = MUTATIONS[mutate]
            text = open(path).read()
            new = edit(text)
            if new == text:
                sys.exit("mutation %s did not apply" % mutate)
            copy = os.path.join(tmp, os.path.basename(path))
            open(copy, "w").write(new)
            override = (path, copy)
        fails = []
        for label, defs in (("synthesis view", []),
                            ("checking view", ["CCV_CHECK", "CCV_TRACE"])):
            mods = elaborate(sources(override), defs, tmp)
            bad, nw, nwrap, has_bank = check_all(mods, bool(defs))
            if bad:
                fails.append((label, bad))
            else:
                print("  %s: %d wrappers (%d modules), each a block and its "
                      "repeaters, nothing else%s"
                      % (label, nw, nwrap, ", plus the checker bank" if has_bank else ""))
        if not fails:
            print("TOP_PURE ok")
            return 0
        for label, bad in fails:
            print("TOP_PURE violated (%s): %d finding(s)" % (label, len(bad)))
            for r, m in bad[:8]:
                print("  %s %s" % (r, m))
        if mutate:
            want = MUTATIONS[mutate][0]
            got = {r for _, bad in fails for r, _ in bad}
            print("MUTANT %s: want %s, got %s" % (mutate, want, " ".join(sorted(got))))
            return 1 if want in got else 2
        return 1


if __name__ == "__main__":
    sys.exit(main())
