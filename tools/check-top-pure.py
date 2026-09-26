#!/usr/bin/env python3
"""THE TOP-LEVEL RULE, checked on the elaborated netlist: ccv_core_top holds
block instances and the nets between them, and nothing else.

  tools/check-top-pure.py [--mutate=gate|tie|flop|float|unloaded]

Why a hard rule (rtl-coding-style.md, "The top level"): everything the core
does is then inside a block, where a block's own checks see it, and the top
is pure connectivity, which the wiring check validates bit for bit. And the
floorplan can abut the blocks: no top-level cell needs a place to sit, and no
glue logic hides between two blocks. The first thing it moved was the clock
gates: each block gates core_clk inside itself, on its own quiescence or
stall, so the signals that decide sleep never leave the block.

Yosys elaborates the top (with `proc`, so a stray always-block becomes a
cell), and on module ccv_core_top:

  R1  every cell is a block instance, and the instances are exactly the 45
      the schema places; under CCV_CHECK, plus the one checker bank
  R2  no constant on any block port, and none on a top-level port: a tie-off
      is a cell in a netlist, and a decision nobody owns
  R3  every bit a block reads is driven, by exactly one block output or top
      input port
  R4  every bit a block drives is read, by a block or a top output port:
      an unloaded output is logic with nowhere to go
  R5  every top output port bit is driven by a block

The synthesis view (no defines) is held to all of it. The checking view
(CCV_CHECK, CCV_TRACE) may add the checker bank, which observes: its ports
may take constants and its inputs are loads, but it may drive nothing.

--mutate edits a temporary copy of the top so that it breaks one rule, and
the check must then fail, naming that rule:
  gate      a top-level clock gate, as the top used to have   R1
  tie       a block's reset tied high                         R2
  flop      a top-level flop between two blocks               R1
  float     a block's reset left unconnected                  R3
  unloaded  a block output disconnected                       R4
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
    b = json.load(open(os.path.join(ROOT, "params", "blocks.json")))
    want = {}
    for x in b["blocks"]:
        n = x["instances"]
        for i in range(n):
            want["u_%s" % x["name"] if n == 1 else "u_%s_%02d" % (x["name"], i)] = \
                "ccv_" + x["name"]
    return want


def elaborate(top_path, defines, tmp):
    """The top as Yosys elaborates it. The checker bank, where there is one,
    is read as a blackbox: its PORTS are what the rule is about, and its
    345 checkers' bodies would take Yosys minutes to elaborate."""
    stubs = sorted(os.path.join("rtl", "top", "stubs", f)
                   for f in os.listdir(os.path.join(ROOT, "rtl", "top", "stubs")))
    out = os.path.join(tmp, "top.json")
    rv = "read_verilog -sv %s -Irtl/include -Irtl/generated -Irtl/top/ports" \
        % " ".join("-D" + d for d in defines)
    script = "%s rtl/ccv_assert_pkg.sv; " % rv
    if defines:
        script += "%s -lib rtl/generated/ccv_skel_checkers.sv; " % rv
    script += ("%s %s %s; hierarchy -check -top ccv_core_top; proc; "
               "write_json %s" % (rv, " ".join(stubs), top_path, out))
    r = subprocess.run(["yosys", "-q", "-p", script], cwd=ROOT,
                       capture_output=True, text=True)
    if r.returncode:
        sys.exit("yosys failed: %s" % (r.stderr or r.stdout)[:600])
    return json.load(open(out))["modules"]


def check(mod, with_bank, modules):
    """[(rule, message)] for everything in the top that is not a block
    instance or a net between blocks."""
    bad = []
    want = expected_instances()
    blocks, bank = {}, None
    for name, c in mod["cells"].items():
        if with_bank and c["type"] == BANK and bank is None:
            bank = (name, c)
        elif name in want and c["type"] == want[name]:
            blocks[name] = c
        else:
            bad.append(("R1", "cell %s of type %s is not a block instance"
                        % (name, c["type"])))
    for name in sorted(set(want) - set(blocks)):
        bad.append(("R1", "block instance %s is missing" % name))

    drivers, loads = {}, {}
    for pname, p in mod["ports"].items():
        for b in p["bits"]:
            if isinstance(b, str):
                bad.append(("R2", "top port %s has a constant bit" % pname))
                break
            (drivers if p["direction"] == "input" else loads) \
                .setdefault(b, []).append("port " + pname)
    for name, c in blocks.items():
        # A port left out of the instance, or connected empty, is not in
        # `connections` at all: compare with the module's own port list.
        for pname, p in modules[c["type"]]["ports"].items():
            if len(c["connections"].get(pname, [])) != len(p["bits"]):
                bad.append(("R3" if p["direction"] == "input" else "R4",
                            "%s.%s is not connected" % (name, pname)))
        for pname, bits in c["connections"].items():
            dr = c["port_directions"][pname]
            if any(isinstance(b, str) for b in bits):
                bad.append(("R2", "%s.%s is tied to a constant" % (name, pname)))
            for b in bits:
                if not isinstance(b, str):
                    (drivers if dr == "output" else loads) \
                        .setdefault(b, []).append("%s.%s" % (name, pname))
    bank_loads = set()
    if bank:
        for pname, bits in bank[1]["connections"].items():
            if bank[1]["port_directions"][pname] == "output":
                bad.append(("R1", "the checker bank drives %s" % pname))
            bank_loads.update(b for b in bits if not isinstance(b, str))

    for b, who in loads.items():
        d = drivers.get(b, [])
        if len(d) != 1:
            bad.append(("R3" if who[0].startswith("u_") else "R5",
                        "%s reads a bit with %s" % (who[0], "no driver" if not d
                                                    else "drivers " + ", ".join(d))))
    for b, who in drivers.items():
        if len(who) > 1:
            continue                 # already reported as a doubled driver
        if b not in loads and b not in bank_loads:
            bad.append(("R4", "%s drives a bit nothing reads" % who[0]))
    # One line per rule and port, not per bit.
    seen, out = set(), []
    for r, m in bad:
        k = (r, re.sub(r"\s.*", "", m))
        if k not in seen:
            seen.add(k)
            out.append((r, m))
    return out, len(blocks), bank is not None


MUTATIONS = {
    # (rule it must break, edit to the top's text)
    "gate": ("R1", lambda t: t.replace(
        ".core_clk(core_clk),", ".core_clk(syu_gclk),", 1).replace(
        "endmodule", "  wire syu_gclk = core_clk & rst_n;\nendmodule", 1)),
    "tie": ("R2", lambda t: t.replace(".rst_n(rst_n),", ".rst_n(1'b1),", 1)),
    "flop": ("R1", lambda t: t.replace(
        ".rst_n(rst_n),", ".rst_n(rst_q),", 1).replace(
        "endmodule", "  logic rst_q;\n  always_ff @(posedge core_clk) rst_q <= rst_n;\nendmodule", 1)),
    "float": ("R3", lambda t: t.replace(".rst_n(rst_n),", ".rst_n(),", 1)),
    "unloaded": ("R4", lambda t: t.replace(".kill_acks(kill_ack),",
                                           ".kill_acks(),", 1)),
}


def main():
    mutate = None
    for a in sys.argv[1:]:
        if a.startswith("--mutate="):
            mutate = a.split("=", 1)[1]
            if mutate not in MUTATIONS:
                sys.exit("unknown mutation %s" % mutate)
    with tempfile.TemporaryDirectory() as tmp:
        top = TOP
        if mutate:
            text = open(TOP).read()
            new = MUTATIONS[mutate][1](text)
            if new == text:
                sys.exit("mutation %s did not apply" % mutate)
            top = os.path.join(tmp, "ccv_core_top.sv")
            open(top, "w").write(new)
        fails = []
        for label, defs in (("synthesis view", []),
                            ("checking view", ["CCV_CHECK", "CCV_TRACE"])):
            mods = elaborate(top, defs, tmp)
            bad, nb, has_bank = check(mods["ccv_core_top"], bool(defs), mods)
            if defs and not has_bank:
                bad.append(("R1", "no checker bank under CCV_CHECK"))
            if bad:
                fails.append((label, bad))
            else:
                print("  %s: %d block instances, nothing else%s"
                      % (label, nb, ", plus the checker bank" if has_bank else ""))
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
