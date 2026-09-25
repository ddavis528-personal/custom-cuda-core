#!/usr/bin/env python3
"""Generate the SystemVerilog top level, block port lists, stubs and a
testbench from schema/interfaces.json and params/blocks.json.

  rtl/top/ccv_core_top.sv            45 block instances, 103 channel instances
  rtl/top/ports/ccv_<blk>_ports.svh  each block type's port list, generated
  rtl/top/stubs/ccv_<blk>.sv         a stub per block type
  test/top/tb_core_top.sv            clock, reset and tie-offs

TRACKED, unlike rtl/generated/, so the top level can be read in the repo; the
gate regenerates and fails if anything moved, which is what stops it being
edited by hand. The lint layer skips rtl/top/ for the same reason it skips
generated/: its port names cannot carry stage tags until 4a numbers the
stages (see docs/skeleton.md, "The SV top").

THE PORT LIST IS INCLUDED, NEVER RESTATED. A block's module header is

    module ccv_fet (
      `include "ccv_fet_ports.svh"
    );

in the stub and in the real 4c RTL alike, so the two cannot disagree on a
port. Swapping a stub for real RTL is then a file-list change -- the SV
analogue of the C++ skeleton's block swap.

PORT LAYOUT. A channel port is flat, instance-major then slot: bit range of
slot s of copy i is [(i*rate + s)*W +: W]. A block owning every copy of a
replicated channel (RCU, for the 32 lanes) sees all of them; a block that IS
one copy (a lane) sees its own `rate` slots. No 2-D packed arrays: Yosys
rejects them (CCV-L26).

CHECKERS. Under CCV_CHECK the top instantiates the SAME generated checker bank
the C++ skeleton Verilates -- ccv_skel_checkers -- fed by concatenating the
channel nets in slot order. Without CCV_CHECK there are no checkers at all,
which is the synthesis exclusion open item B-1 asked for. The trace sideband
(`_tid`) exists only under CCV_TRACE, as the identity decision requires.
"""
import importlib.util
import json
import os
import sys

ROOT = os.path.dirname(os.path.dirname(os.path.abspath(__file__)))
TOPDIR = os.path.join(ROOT, "rtl", "top")
TBDIR = os.path.join(ROOT, "test", "top")

spec = importlib.util.spec_from_file_location(
    "gen_skel", os.path.join(ROOT, "tools", "gen-skel.py"))
gs = importlib.util.module_from_spec(spec)
spec.loader.exec_module(gs)

BANNER = """// GENERATED FILE -- DO NOT EDIT.
//
// Produced by tools/gen-top.py from schema/interfaces.json and
// params/blocks.json. Edit a source and regenerate; tools/verify.sh fails if
// this file is stale.
"""


def inst_name(btype, idx, ninst):
    """Block instance name. The C++ skeleton's --dump-wiring uses the same
    rule, implemented separately, and the gate compares the two."""
    return "u_%s" % btype if ninst == 1 else "u_%s_%02d" % (btype, idx)


def load():
    d, pv, blocks = gs.load()
    binst, chans, cinst, nslots, pbits = gs.build(d, pv, blocks)
    ninst = {b["name"]: b["instances"] for b in blocks}
    common = []
    for cp in d["common_ports"]:
        w = cp["width"]
        common.append((cp["name"], cp["dir"],
                       w if isinstance(w, int) else gs.resolve(w, pv)))
    return d, blocks, binst, chans, cinst, ninst, common


def copies_seen(c, btype, ninst):
    """How many copies of channel c a block of type btype sees."""
    if ninst.get(btype, 1) > 1:
        return 1                      # it IS one copy
    return c["ninst"]                 # it owns every copy


def rng(w):
    return "" if w == 1 else "[%d:0] " % (w - 1)


def block_ports(btype, chans, ninst, common):
    """[(dir, width, name, trace_only, doc)] for one block type."""
    P = []
    for name, dr, w in common:
        P.append(("input" if dr == "in" else "output", w, name, False, None))
    for c in chans:
        base = c["name"][4:]
        for side in ("src", "dst"):
            if c[side] != btype:
                continue
            n = copies_seen(c, btype, ninst) * c["rate"]
            prod = side == "src"
            fwd, back = ("output", "input") if prod else ("input", "output")
            doc = "%s -> %s, %d slot(s) x %d bit payload" % (
                c["src"], c["dst"], n, c["bits"])
            P.append((fwd, n, base + "_valid", False, doc))
            P.append((fwd, n * c["bits"], base + "_payload", False, None))
            P.append((back, n, base + "_credit", False, None))
            P.append((back, n, base + "_stall", False, None))
            P.append((fwd, n * 64, base + "_tid", True, None))
    return P


def gen_ports(btype, P):
    L = [BANNER]
    L.append("// Port list of ccv_%s. Included between the parentheses of the" % btype)
    L.append("// module header, in the stub and in the real RTL alike.")
    L.append("//")
    L.append("// Channel ports are named by channel, not stage-tagged: stage")
    L.append("// numbers are assigned at 4a, and the tag belongs on the internal")
    L.append("// flop that drives the port. `_tid` is trace-only (CCV_TRACE).")
    plain = [p for p in P if not p[3]]
    trace = [p for p in P if p[3]]
    for k, (dr, w, name, _, doc) in enumerate(plain):
        if doc:
            L.append("  // %s" % doc)
        sep = "," if k != len(plain) - 1 else ""
        L.append("  %-6s logic %s%s%s" % (dr, rng(w), name, sep))
    if trace:
        L.append("`ifdef CCV_TRACE")
        for dr, w, name, _, _ in trace:
            L.append("  , %-6s logic %s%s" % (dr, rng(w), name))
        L.append("`endif")
    return "\n".join(L) + "\n"


def gen_stub(btype, P):
    L = [BANNER]
    L.append("// STUB for ccv_%s: never sends, never consumes, never stalls." % btype)
    L.append("// That is protocol-legal on every channel -- no valid means no")
    L.append("// credit is owed -- so the top elaborates and simulates with every")
    L.append("// checker quiet. Common-port handshakes (kill, sleep, CSR) have no")
    L.append("// specified semantics yet, so outputs sit at their inactive value.")
    L.append("//")
    L.append("// Replaced at 4c by real RTL with the SAME module name, including")
    L.append("// the same generated port list; the swap is a file-list change.")
    L.append("`include \"ccv_interfaces.svh\"")
    L.append("")
    L.append("// A stub reads none of its inputs, by definition.")
    L.append("/* verilator lint_off UNUSEDSIGNAL */")
    L.append("module ccv_%s (" % btype)
    L.append("  `include \"ccv_%s_ports.svh\"" % btype)
    L.append(");")
    for dr, w, name, tr, _ in P:
        if dr != "output":
            continue
        if tr:
            L.append("`ifdef CCV_TRACE")
        if w > 8192:
            # Verilator flags any replication over 8k bits as "probably
            # wrong". These are real: 32 lanes x 4 x 110 bits of operands, and
            # RCU->MIU at 4 x 2119 -- the ~8,400-wire interface the payload
            # review already flagged. Suppressed here, per assignment.
            L.append("  /* verilator lint_off WIDTHCONCAT */")
            L.append("  assign %s = '0;  // %d bits, intended" % (name, w))
            L.append("  /* verilator lint_on WIDTHCONCAT */")
        else:
            L.append("  assign %s = '0;" % name)
        if tr:
            L.append("`endif")
    L.append("endmodule")
    L.append("/* verilator lint_on UNUSEDSIGNAL */")
    return "\n".join(L) + "\n"


def gen_top(d, binst, chans, cinst, ninst, common, ports):
    NB = len(binst)
    names = [inst_name(t, i, ninst[t]) for t, i in binst]
    L = [BANNER]
    L.append("// The CCV core: %d block instances, %d channel instances."
             % (NB, len(cinst)))
    L.append("//")
    L.append("// Channel nets are flat, instance-major then slot -- the same order")
    L.append("// as the C++ skeleton's slot map, so the checker bank is fed by")
    L.append("// concatenation. tools/check-top.sh extracts this netlist's")
    L.append("// connectivity from Yosys and compares it, bit for bit, with the")
    L.append("// wiring the C++ skeleton reports.")
    L.append("//")
    L.append("// COMMON PORTS. clk is the block's gated clock, made here from")
    L.append("// core_clk; the gate enable is tied high because the power")
    L.append("// controller that would drive it from sleep_ok/wake_req is not")
    L.append("// specified. rst_n fans out directly; the reset tree (block letter")
    L.append("// z) is not modelled yet. kill_valid/kill_warp_mask are broadcast")
    L.append("// from the top: the schema says kill comes from RAU, but RAU has no")
    L.append("// kill OUTPUT. The per-block kill_ack, wake_req, sleep_ok and CSR")
    L.append("// ports have no fabric in the spec, so they are brought to this")
    L.append("// boundary as vectors indexed by block instance rather than wired")
    L.append("// to a guess.")
    L.append("//")
    L.append("// Block instance index (for the per-block common-port vectors):")
    for k, n in enumerate(names):
        L.append("//   %2d  %s" % (k, n))
    L.append("`include \"ccv_interfaces.svh\"")
    L.append("")
    cw = {n: w for n, _, w in common}
    ext = [c for c in chans if "EXTERNAL" in (c["src"], c["dst"])]
    L.append("module ccv_core_top (")
    P = ["  input  logic core_clk",
         "  input  logic rst_n",
         "  input  logic kill_valid",
         "  input  logic %skill_warp_mask" % rng(cw["kill_warp_mask"]),
         "  input  logic %swake_req" % rng(NB),
         "  input  logic %scsr_req" % rng(NB * cw["csr_req"]),
         "  output logic %skill_ack" % rng(NB),
         "  output logic %ssleep_ok" % rng(NB),
         "  output logic %scsr_rsp" % rng(NB * cw["csr_rsp"]),
         "  output logic %scsr_credit" % rng(NB)]
    tp = []
    for c in ext:
        base = c["name"][4:]
        out = c["src"] != "EXTERNAL"      # the core drives it
        fwd, back = ("output", "input") if out else ("input", "output")
        P += ["  %-6s logic %s%s_valid" % (fwd, rng(c["rate"]), base),
              "  %-6s logic %s%s_payload" % (fwd, rng(c["rate"] * c["bits"]), base),
              "  %-6s logic %s%s_credit" % (back, rng(c["rate"]), base),
              "  %-6s logic %s%s_stall" % (back, rng(c["rate"]), base)]
        tp.append("  , %-6s logic %s%s_tid" % (fwd, rng(c["rate"] * 64), base))
    L.append(",\n".join(P))
    L.append("`ifdef CCV_TRACE")
    L += tp
    L.append("`endif")
    L.append(");")
    L.append("")
    # nets for internal channels
    for c in chans:
        if "EXTERNAL" in (c["src"], c["dst"]):
            continue
        base = c["name"][4:]
        n = c["ninst"] * c["rate"]
        L.append("  // %s: %s -> %s, %d copy x %d slot" % (
            c["name"], c["src"], c["dst"], c["ninst"], c["rate"]))
        for sig, w in (("valid", n), ("payload", n * c["bits"]),
                       ("credit", n), ("stall", n)):
            L.append("  logic %s%s_%s;" % (rng(w), base, sig))
        L.append("`ifdef CCV_TRACE")
        L.append("  logic %s%s_tid;" % (rng(n * 64), base))
        L.append("`endif")
    L.append("")
    L.append("  // Per-block gated clocks. Gate enable tied high: see above.")
    for n in names:
        b = n[2:]
        L.append("  wire %s_clk_en = 1'b1;" % b)
        L.append("  wire %s_core_clk = core_clk & %s_clk_en;" % (b, b))
    L.append("")
    for k, (t, i) in enumerate(binst):
        n = names[k]
        conns = []
        trconns = []
        for dr, w, pname, tr, _ in ports[t]:
            if pname == "clk":
                ex = "%s_core_clk" % n[2:]
            elif pname == "clk_free":
                ex = "core_clk"
            elif pname in ("rst_n", "kill_valid", "kill_warp_mask"):
                ex = pname
            elif pname in ("kill_ack", "wake_req", "sleep_ok", "csr_credit"):
                ex = "%s[%d]" % (pname, k)
            elif pname in ("csr_req", "csr_rsp"):
                ex = "%s[%d +: %d]" % (pname, k * cw[pname], cw[pname])
            else:
                sig = pname.rsplit("_", 1)[1]
                base = pname[: -len(sig) - 1]
                c = next(c for c in chans if c["name"][4:] == base)
                per = {"valid": 1, "credit": 1, "stall": 1,
                       "payload": c["bits"], "tid": 64}[sig]
                if copies_seen(c, t, ninst) == c["ninst"]:
                    ex = pname
                else:
                    lo = i * c["rate"] * per
                    ex = "%s[%d +: %d]" % (pname, lo, c["rate"] * per)
            (trconns if tr else conns).append(".%s(%s)" % (pname, ex))
        L.append("  ccv_%s %s (" % (t, n))
        L.append("    " + ",\n    ".join(conns))
        if trconns:
            L.append("`ifdef CCV_TRACE")
            L.append("    , " + ",\n      ".join(trconns))
            L.append("`endif")
        L.append("  );")
        L.append("")
    # the checker bank
    order = list(reversed(chans))    # {last, ..., first}: slot 0 at the LSB
    def cat(sig):
        return "{%s}" % ", ".join("%s_%s" % (c["name"][4:], sig) for c in order)
    L.append("`ifdef CCV_CHECK")
    L.append("  // The SAME checker bank the C++ skeleton Verilates, on the real")
    L.append("  // nets. Absent unless CCV_CHECK is defined, so synthesis never")
    L.append("  // sees a checker.")
    L.append("  ccv_skel_checkers u_checkers (")
    L.append("    .clk(core_clk), .rst_n(rst_n), .force_atomic(1'b0),")
    L.append("    .valid(%s)," % cat("valid"))
    L.append("    .credit(%s)," % cat("credit"))
    L.append("    .stall(%s)," % cat("stall"))
    L.append("    .payload(%s)" % cat("payload"))
    L.append("`ifdef CCV_TRACE")
    L.append("    , .tid(%s)" % cat("tid"))
    L.append("`endif")
    L.append("  );")
    L.append("`endif")
    L.append("")
    L.append("endmodule")
    return "\n".join(L) + "\n"


def gen_tb(d, binst, chans, common):
    NB = len(binst)
    cw = {n: w for n, _, w in common}
    ext = [c for c in chans if "EXTERNAL" in (c["src"], c["dst"])]
    L = [BANNER.replace("// Produced", "// Produced"), "`timescale 1ns/1ps"]
    L.append("// Clock, reset and tie-offs for ccv_core_top. With stub blocks nothing")
    L.append("// moves; what this proves is that the whole top elaborates and runs")
    L.append("// in each simulator, with the checker bank attached under CCV_CHECK.")
    L.append("// The machine's real testbench is the C++ skeleton (sim/skel/).")
    L.append("module tb;")
    L.append("  logic core_clk = 1'b0, rst_n = 1'b0;")
    L.append("  logic [%d:0] kill_ack, sleep_ok, csr_credit;" % (NB - 1))
    L.append("  logic [%d:0] csr_rsp;" % (NB * cw["csr_rsp"] - 1))
    conns = [".core_clk(core_clk)", ".rst_n(rst_n)", ".kill_valid(1'b0)",
             ".kill_warp_mask('0)", ".wake_req('0)", ".csr_req('0)",
             ".kill_ack(kill_ack)", ".sleep_ok(sleep_ok)",
             ".csr_rsp(csr_rsp)", ".csr_credit(csr_credit)"]
    tr = []
    phantom = None
    for c in ext:
        base = c["name"][4:]
        out = c["src"] != "EXTERNAL"
        r = c["rate"]
        if out:
            L.append("  logic %s%s_valid;" % (rng(r), base))
            L.append("  logic %s%s_payload;" % (rng(r * c["bits"]), base))
            L.append("  logic %s%s_credit = '0;" % (rng(r), base))
            conns += [".%s_valid(%s_valid)" % (base, base),
                      ".%s_payload(%s_payload)" % (base, base),
                      ".%s_credit(%s_credit)" % (base, base),
                      ".%s_stall('0)" % base]
            phantom = base
            L.append("`ifdef CCV_TRACE")
            L.append("  logic %s%s_tid;" % (rng(r * 64), base))
            L.append("`endif")
            tr.append(".%s_tid(%s_tid)" % (base, base))
        else:
            L.append("  logic %s%s_credit, %s_stall;" % (rng(r), base, base))
            conns += [".%s_valid('0)" % base, ".%s_payload('0)" % base,
                      ".%s_credit(%s_credit)" % (base, base),
                      ".%s_stall(%s_stall)" % (base, base)]
            tr.append(".%s_tid('0)" % base)
    L.append("")
    L.append("  ccv_core_top u_top (")
    L.append("    " + ",\n    ".join(conns))
    L.append("`ifdef CCV_TRACE")
    L.append("    , " + ",\n      ".join(tr))
    L.append("`endif")
    L.append("  );")
    L.append("")
    L.append("  always #5 core_clk = ~core_clk;")
    L.append("  initial begin")
    L.append("    repeat (3) @(posedge core_clk);")
    L.append("    rst_n = 1'b1;")
    L.append("    // +phantom: a credit returned to the core for nothing it sent.")
    L.append("    // The negative control for the checker bank INSIDE the SV top --")
    L.append("    // with stub blocks, a quiet run looks the same whether the bank")
    L.append("    // is connected or not.")
    L.append("    if ($test$plusargs(\"phantom\")) begin")
    L.append("      repeat (4) @(posedge core_clk);")
    L.append("      #1 %s_credit = '1;" % phantom)
    L.append("      @(posedge core_clk);")
    L.append("      #1 %s_credit = '0;" % phantom)
    L.append("    end")
    L.append("    repeat (50) @(posedge core_clk);")
    L.append("    if (%s_valid !== '0) $display(\"TOP_UNEXPECTED_TRAFFIC\");"
             % [c for c in ext if c["src"] != "EXTERNAL"][0]["name"][4:])
    L.append("    $display(\"TOP_OK\");")
    L.append("    $finish;")
    L.append("  end")
    L.append("endmodule")
    return "\n".join(L) + "\n"


def main():
    check = "--check" in sys.argv
    d, blocks, binst, chans, cinst, ninst, common = load()
    ports = {b["name"]: block_ports(b["name"], chans, ninst, common)
             for b in blocks}
    targets = [(os.path.join(TOPDIR, "ccv_core_top.sv"),
                gen_top(d, binst, chans, cinst, ninst, common, ports)),
               (os.path.join(TBDIR, "tb_core_top.sv"),
                gen_tb(d, binst, chans, common))]
    for b in blocks:
        t = b["name"]
        targets.append((os.path.join(TOPDIR, "ports", "ccv_%s_ports.svh" % t),
                        gen_ports(t, ports[t])))
        targets.append((os.path.join(TOPDIR, "stubs", "ccv_%s.sv" % t),
                        gen_stub(t, ports[t])))
    stale = []
    for path, text in targets:
        os.makedirs(os.path.dirname(path), exist_ok=True)
        cur = open(path).read() if os.path.exists(path) else None
        if cur != text:
            stale.append(os.path.relpath(path, ROOT))
            if not check:
                open(path, "w").write(text)
    msg = "%d files: top, %d port lists, %d stubs, testbench" % (
        len(targets), len(blocks), len(blocks))
    if check:
        if stale:
            sys.stderr.write("stale: %s\n  run tools/gen-top.py\n"
                             % ", ".join(stale[:5]))
            return 1
        print("  SV top up to date (%s)" % msg)
        return 0
    print("  generated SV top (%s)" % msg)
    return 0


if __name__ == "__main__":
    sys.exit(main())
