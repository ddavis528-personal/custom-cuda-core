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

PORT NAMING: one group of ports per slot, the payload typed. Every channel
signal is named

    <chan>[_c<NN>][_s<K>]_<sig>     sig: valid payload credit stall tid
    <chan>[_c<NN>]_wake             one per channel instance

where <chan> is the channel name without `ccv_`, `_c<NN>` the copy (two
digits) and `_s<K>` the slot. Each suffix is present only when that dimension
exists: `_s<K>` only on a channel of rate > 1, and `_c<NN>` only on a
replicated channel, and only where the name refers to ONE of its copies -- a
block that owns every copy (RCU, for the 32 lanes) and the top's nets carry
it; a block that IS one copy (a lane) does not. A slot's four signals share
one prefix, so a reader finds the group by name. `_payload` is typed
ccv_<chan>_t, from ccv_interfaces.svh.

Why per slot rather than an array of structs: Yosys 0.33 accepts a packed
struct port, but a packed array of packed structs as a port it mis-elaborates
SILENTLY -- it sizes the port by the array bound alone, declares the fields
as implicit 1-bit nets, and warns (measured 2026-09-26). Both simulators get
it right, so only synthesis and formal would see a different circuit.
tools/check-top-wiring.py refuses those warnings, and CCV-L26 refuses the
construct.

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
                       w if isinstance(w, int) else gs.resolve(w, pv),
                       cp.get("fabric", {})))
    return d, blocks, binst, chans, cinst, ninst, common


def copies_seen(c, btype, ninst):
    """How many copies of channel c a block of type btype sees."""
    if ninst.get(btype, 1) > 1:
        return 1                      # it IS one copy
    return c["ninst"]                 # it owns every copy


def rng(w):
    return "" if w == 1 else "[%d:0] " % (w - 1)


def flip(dr):
    return "output" if dr == "input" else "input"


def block_ports(btype, chans, ninst, common, nb):
    """[(dir, width, name, trace_only, doc)] for one block type.

    Common ports follow their `fabric` (schema common_ports):
      broadcast  driven by one block (`from`), an input everywhere else
      gather     an output everywhere but `to`, which takes all of them as
                 one vector (`port`), a bit per block instance
      star       as declared on every block; the `owner` also drives every
                 other block's copy through a vector port (`port`) -- its own
                 declared ports are the host side
      local      as declared, wired only to the block's own clock gate
    """
    P = []
    for name, dr, w, fab in common:
        dr = "input" if dr == "in" else "output"
        kind = fab.get("kind")
        if kind == "broadcast":
            if btype == fab["from"]:
                P.append(("output", w, name, False, None, None, None))
            elif btype in fab.get("to", [btype]):
                P.append(("input", w, name, False, None, None, None))
        elif kind == "gather":
            srcs = fab.get("from")
            if btype == fab["to"]:
                P.append(("input", (len(srcs) if srcs else nb) * w, fab["port"],
                          False,
                          "%s of %s, in that order" % (name, ", ".join(srcs))
                          if srcs else
                          "every block instance's %s, by instance index" % name,
                          None, None))
            elif srcs is None or btype in srcs:
                P.append((dr, w, name, False, None, None, None))
        elif kind == "star":
            P.append((dr, w, name, False, None, None, None))
            if btype == fab["owner"]:
                P.append((flip(dr), nb * w, fab["port"], False,
                          "%s of every block instance, by instance index" % name,
                          None, None))
        else:
            P.append((dr, w, name, False, None, None, None))
    for c in chans:
        for side in ("src", "dst"):
            if c[side] != btype:
                continue
            fwd = "output" if side == "src" else "input"
            P += chan_ports(c, fwd, owns_copies(c, btype, ninst))
    return P


def copy_sfx(c, copy):
    return "_c%02d" % copy if c["ninst"] > 1 and copy is not None else ""


def slot_sfx(c, s):
    return "_s%d" % s if c["rate"] > 1 else ""


def owns_copies(c, btype, ninst):
    """The copies a block of this type names in its ports: every one if it
    owns a replicated channel's copies, else [None] (one, unnamed)."""
    if ninst.get(btype, 1) > 1 or c["ninst"] == 1:
        return [None]
    return list(range(c["ninst"]))


def chan_ports(c, fwd, copies):
    """Port tuples for one side of a channel: per copy, per slot, the four
    signals together, then the copy's wake; trace ids last, per slot."""
    back = flip(fwd)
    base = c["name"][4:]
    typ = "ccv_%s_t" % base
    P = []
    for cp in copies:
        for s in range(c["rate"]):
            pre = base + copy_sfx(c, cp) + slot_sfx(c, s)
            doc = "%s -> %s%s%s" % (c["src"], c["dst"],
                                    ", copy %d" % cp if cp is not None and c["ninst"] > 1 else "",
                                    ", slot %d of %d" % (s, c["rate"]) if c["rate"] > 1 else "")
            meta = lambda sig: (c, cp, s, sig)
            P.append((fwd, 1, pre + "_valid", False, doc, None, meta("valid")))
            P.append((fwd, c["bits"], pre + "_payload", False, None, typ, meta("payload")))
            P.append((back, 1, pre + "_credit", False, None, None, meta("credit")))
            P.append((back, 1, pre + "_stall", False, None, None, meta("stall")))
        P.append((fwd, 1, base + copy_sfx(c, cp) + "_wake", False, None, None,
                  (c, cp, None, "wake")))
    for cp in copies:
        for s in range(c["rate"]):
            P.append((fwd, 64, base + copy_sfx(c, cp) + slot_sfx(c, s) + "_tid",
                      True, None, None, (c, cp, s, "tid")))
    return P


def decl(w, typ):
    return typ + " " if typ else "logic " + rng(w)


def net_name(c, copy, slot, sig):
    """The top's net for one channel signal: the copy always named on a
    replicated channel, the slot on a multi-slot one."""
    base = c["name"][4:] + copy_sfx(c, copy)
    if sig == "wake":
        return base + "_wake"
    return base + slot_sfx(c, slot) + "_" + sig


def gen_ports(btype, P):
    L = [BANNER]
    L.append("// Port list of ccv_%s. Included between the parentheses of the" % btype)
    L.append("// module header, in the stub and in the real RTL alike.")
    L.append("//")
    L.append("// Channel ports are named by channel, not stage-tagged: stage")
    L.append("// numbers are assigned at 4a, and the tag belongs on the internal")
    L.append("// flop that drives the port. One group per slot:")
    L.append("//   <chan>[_c<NN>][_s<K>]_{valid,payload,credit,stall}, and")
    L.append("//   <chan>[_c<NN>]_wake per channel instance; `_c` only where a")
    L.append("// block names one of several copies, `_s` only at rate > 1.")
    L.append("// `_payload` is typed ccv_<chan>_t. `_tid` is trace-only (CCV_TRACE).")
    plain = [p for p in P if not p[3]]
    trace = [p for p in P if p[3]]
    for k, (dr, w, name, _, doc, typ, _m) in enumerate(plain):
        if doc:
            L.append("  // %s" % doc)
        sep = "," if k != len(plain) - 1 else ""
        L.append("  %-6s %s%s%s" % (dr, decl(w, typ), name, sep))
    if trace:
        L.append("`ifdef CCV_TRACE")
        for dr, w, name, _, _, typ, _m in trace:
            L.append("  , %-6s %s%s" % (dr, decl(w, typ), name))
        L.append("`endif")
    return "\n".join(L) + "\n"


def gen_stub(btype, P):
    L = [BANNER]
    L.append("// STUB for ccv_%s: never sends, never consumes, never stalls." % btype)
    L.append("// That is protocol-legal on every channel -- no valid means no")
    L.append("// credit is owed -- so the top elaborates and simulates with every")
    L.append("// checker quiet. Common-port handshakes (kill, sleep, CSR) have no")
    L.append("// specified semantics yet, so outputs sit at their inactive value:")
    L.append("// sleep_ok low keeps the block's clock running.")
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
    for dr, w, name, tr, _, _t, _m in P:
        if dr != "output":
            continue
        if tr:
            L.append("`ifdef CCV_TRACE")
        if w > 8192:
            # Verilator flags any replication over 8k bits as "probably
            # wrong". Real where it happens: a wide common-port vector.
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
    cw = {n: w for n, _, w, _ in common}
    fab = {n: f for n, _, _, f in common}
    owner_idx = lambda t: [k for k, (bt, _) in enumerate(binst) if bt == t]
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
    L.append("// COMMON PORTS, by fabric (schema common_ports):")
    L.append("//   kill_valid / _warp_mask /    broadcast from RAU, the one true")
    L.append("//   _epoch                       broadcast, to the eight blocks that")
    L.append("//                                own warp state; kill_ack and its")
    L.append("//                                epoch gathered back at RAU")
    L.append("//   wake                         not a common port: each channel")
    L.append("//                                carries <name>_wake, sender to")
    L.append("//                                receiver")
    L.append("//   sleep_ok                     local: drives the block's own")
    L.append("//                                clock gate, nothing else")
    L.append("//   csr_*                        a star from CRU, which owns the")
    L.append("//                                CSR fabric; CRU's own csr ports")
    L.append("//                                are the host side, at this")
    L.append("//                                boundary")
    L.append("// rst_n fans out directly; the reset tree (block letter z) is not")
    L.append("// modelled yet.")
    L.append("//")
    L.append("// Block instance index (for the per-block common-port vectors):")
    for k, n in enumerate(names):
        L.append("//   %2d  %s" % (k, n))
    L.append("`include \"ccv_interfaces.svh\"")
    L.append("")
    ext = [c for c in chans if "EXTERNAL" in (c["src"], c["dst"])]
    csr = [n for n, f in fab.items() if f.get("kind") == "star"]
    L.append("module ccv_core_top (")
    P = ["  input  logic core_clk",
         "  input  logic rst_n"]
    for n in csr:                        # the CSR owner's host side
        dr = next(dr for nm, dr, _, _ in common if nm == n)
        P.append("  %-6s logic %s%s" % ("input" if dr == "in" else "output",
                                          rng(cw[n]), n))
    tp = []
    for c in ext:
        out = c["src"] != "EXTERNAL"      # the core drives it
        for dr, w, name, tr, _, typ, _m in chan_ports(c, "output" if out else "input", [None]):
            if tr:
                tp.append("  , %-6s %s%s" % (dr, decl(w, typ), name))
            else:
                P.append("  %-6s %s%s" % (dr, decl(w, typ), name))
    L.append(",\n".join(P))
    L.append("`ifdef CCV_TRACE")
    L += tp
    L.append("`endif")
    L.append(");")
    L.append("")
    # common-port fabrics
    L.append("  // Common-port fabrics.")
    for n, f in fab.items():
        k = f.get("kind")
        if k == "broadcast":
            L.append("  logic %s%s;   // from %s" % (rng(cw[n]), n, f["from"]))
        elif k == "gather":
            srcs = f.get("from")
            if srcs:
                assert all(ninst[b] == 1 for b in srcs), "gather from a multi-instance block"
                L.append("  logic %s%s;   // gathered at %s from %s"
                         % (rng(len(srcs) * cw[n]), n, f["to"], ", ".join(srcs)))
            else:
                L.append("  logic %s%s;   // gathered at %s" % (rng(NB * cw[n]), n, f["to"]))
                for kk in owner_idx(f["to"]):
                    L.append("  assign %s[%d] = 1'b1;   // %s does not ack itself"
                             % (n, kk, names[kk]))
        elif k == "star":
            dr = next(dr for nm, dr, _, _ in common if nm == n)
            if dr == "in":
                # The owner drives every slice, its own included, and its own
                # is read by nobody: its host side is at the boundary.
                L.append("  /* verilator lint_off UNUSEDSIGNAL */")
            L.append("  logic %s%s;   // %s, star from %s" % (rng(NB * cw[n]), f["port"], n, f["owner"]))
            if dr == "in":
                L.append("  /* verilator lint_on UNUSEDSIGNAL */")
    for n, f in fab.items():
        if f.get("kind") != "star":
            continue
        dr = next(dr for nm, dr, _, _ in common if nm == n)
        if dr == "out":                  # the owner's own slot of a gathered vector
            for kk in owner_idx(f["owner"]):
                L.append("  assign %s[%d +: %d] = '0;   // %s's own: its host side is at the boundary"
                         % (f["port"], kk * cw[n], cw[n], names[kk]))
    L.append("")
    # nets for internal channels
    for c in chans:
        if "EXTERNAL" in (c["src"], c["dst"]):
            continue
        L.append("  // %s: %s -> %s, %d cop%s x %d slot%s" % (
            c["name"], c["src"], c["dst"], c["ninst"],
            "y" if c["ninst"] == 1 else "ies", c["rate"],
            "" if c["rate"] == 1 else "s"))
        cps = list(range(c["ninst"]))
        for dr, w, name, tr, _, typ, m in chan_ports(c, "output", cps):
            if tr:
                continue
            L.append("  %s%s;" % (decl(w, typ), name))
        L.append("`ifdef CCV_TRACE")
        for dr, w, name, tr, _, typ, m in chan_ports(c, "output", cps):
            if tr:
                L.append("  %s%s;" % (decl(w, typ), name))
        L.append("`endif")
    L.append("")
    L.append("  // Per-block gated clocks: each block's sleep_ok drives its own")
    L.append("  // gate and nothing else. A stub holds sleep_ok low, so its clock")
    L.append("  // runs; a real block's wake detector (on clk_free) lowers it when")
    L.append("  // a _wake arrives on one of its input channels.")
    for n in names:
        b = n[2:]
        L.append("  logic %s_sleep_ok;" % b)
        L.append("  wire %s_core_clk = core_clk & ~%s_sleep_ok;" % (b, b))
    L.append("")
    for k, (t, i) in enumerate(binst):
        n = names[k]
        conns = []
        trconns = []
        for dr, w, pname, tr, _, _typ, meta in ports[t]:
            f = fab.get(pname, {})
            kind = f.get("kind")
            gathers = {ff["port"]: nm for nm, ff in fab.items()
                       if ff.get("kind") == "gather"}
            stars = {ff["port"]: nm for nm, ff in fab.items()
                     if ff.get("kind") == "star"}
            if pname == "clk":
                ex = "%s_core_clk" % n[2:]
            elif pname == "clk_free":
                ex = "core_clk"
            elif pname == "rst_n":
                ex = "rst_n"
            elif kind == "broadcast":
                ex = pname
            elif kind == "gather":
                srcs = f.get("from")
                if srcs:
                    j = srcs.index(t)
                    ex = ("%s[%d]" % (pname, j) if cw[pname] == 1
                          else "%s[%d +: %d]" % (pname, j * cw[pname], cw[pname]))
                else:
                    ex = "%s[%d]" % (pname, k)
            elif pname in gathers:
                ex = gathers[pname]
            elif kind == "local":
                ex = "%s_%s" % (n[2:], pname)
            elif kind == "star":
                if t == f["owner"]:
                    ex = pname                        # host side
                elif cw[pname] == 1:
                    ex = "%s[%d]" % (f["port"], k)
                else:
                    ex = "%s[%d +: %d]" % (f["port"], k * cw[pname], cw[pname])
            elif pname in stars:
                ex = pname
            else:
                # A channel port: the net is the same name with the copy
                # filled in. A block that IS one copy leaves it out of its
                # ports; the top's nets always carry it.
                c, cp, sl, sig = meta
                if cp is None and c["ninst"] > 1:
                    cp = i
                ex = net_name(c, cp, sl, sig)
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
    # The bank's vectors are in slot-map order -- channel instance by channel
    # instance, then slot -- with slot 0 at the LSB, so {last, ..., first}.
    def cat(sig):
        nets = [net_name(ci["chan"], ci["inst"], s, sig)
                for ci in cinst for s in range(ci["chan"]["rate"])]
        return "{%s}" % ", ".join(reversed(nets))
    def cat_wake():
        nets = [net_name(ci["chan"], ci["inst"], None, "wake") for ci in cinst]
        return "{%s}" % ", ".join(reversed(nets))
    L.append("`ifdef CCV_CHECK")
    L.append("  // The SAME checker bank the C++ skeleton Verilates, on the real")
    L.append("  // nets. Absent unless CCV_CHECK is defined, so synthesis never")
    L.append("  // sees a checker.")
    L.append("  ccv_skel_checkers u_checkers (")
    L.append("    .clk(core_clk), .rst_n(rst_n), .force_atomic(1'b0), .pair_enable(1'b1),")
    L.append("    .valid(%s)," % cat("valid"))
    L.append("    .credit(%s)," % cat("credit"))
    L.append("    .stall(%s)," % cat("stall"))
    L.append("    .payload(%s)," % cat("payload"))
    L.append("    .wake(%s)," % cat_wake())
    # Each channel instance's receiver's sleep_ok, in the bank's channel
    # instance order; the testbench end of EXTERNAL never sleeps.
    rxg = ["1'b0" if ci["dst"] is None else "%s_sleep_ok" % names[ci["dst"]][2:]
           for ci in reversed(cinst)]
    L.append("    .rx_gated({%s})" % ", ".join(rxg))
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
    cw = {n: w for n, _, w, _ in common}
    ext = [c for c in chans if "EXTERNAL" in (c["src"], c["dst"])]
    L = [BANNER.replace("// Produced", "// Produced"), "`timescale 1ns/1ps"]
    L.append("// Clock, reset and tie-offs for ccv_core_top. With stub blocks nothing")
    L.append("// moves; what this proves is that the whole top elaborates and runs")
    L.append("// in each simulator, with the checker bank attached under CCV_CHECK.")
    L.append("// The machine's real testbench is the C++ skeleton (sim/skel/).")
    L.append("module tb;")
    L.append("  logic core_clk = 1'b0, rst_n = 1'b0;")
    L.append("  // The CSR owner's host side, idle.")
    L.append("  logic %scsr_rsp;" % rng(cw["csr_rsp"]))
    L.append("  logic csr_credit;")
    conns = [".core_clk(core_clk)", ".rst_n(rst_n)", ".csr_req('0)",
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
            L.append("  logic %s_wake;" % base)
            conns += [".%s_valid(%s_valid)" % (base, base),
                      ".%s_payload(%s_payload)" % (base, base),
                      ".%s_credit(%s_credit)" % (base, base),
                      ".%s_stall('0)" % base,
                      ".%s_wake(%s_wake)" % (base, base)]
            phantom = base
            L.append("`ifdef CCV_TRACE")
            L.append("  logic %s%s_tid;" % (rng(r * 64), base))
            L.append("`endif")
            tr.append(".%s_tid(%s_tid)" % (base, base))
        else:
            L.append("  logic %s%s_credit, %s_stall;" % (rng(r), base, base))
            conns += [".%s_valid('0)" % base, ".%s_payload('0)" % base,
                      ".%s_credit(%s_credit)" % (base, base),
                      ".%s_stall(%s_stall)" % (base, base),
                      ".%s_wake(1'b0)" % base]
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
    ports = {b["name"]: block_ports(b["name"], chans, ninst, common, len(binst))
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
