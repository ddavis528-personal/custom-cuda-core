#!/usr/bin/env python3
"""Generate the SystemVerilog top level, block port lists, stubs and a
testbench from schema/interfaces.json and params/blocks.json.

  rtl/top/ccv_core_top.sv            45 block instances, 103 channel instances
  rtl/top/ports/ccv_<blk>_ports.svh  each block type's port list, generated
  rtl/top/stubs/ccv_<blk>.sv         a stub per block type
  test/top/tb_core_top.sv            clock, reset and tie-offs
  rtl/top/wrap/ccv_<blk>_w.sv        hardening wrappers: block + repeaters
                                     (params/links.json), the physical
                                     hierarchy; ccv_<inst>_w for one with
                                     feedthroughs
  rtl/top/dpi/ccv_<blk>.sv           the C++ skeleton's block, over DPI-C
  rtl/top/dpi/ccv_ext.sv             ...and its testbench end of EXTERNAL
  test/top/tb_sv_hosted.sv           the top built from those, run to the end
  sim/generated/ccv_dpi_ports.h      each shim's sample order, for the host

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
    """[(dir, width, name, guard, doc, type, meta)] for one block type.
    `guard` is False, or the macro the port exists under: CCV_TRACE for the
    trace sideband, CCV_CHECK for an observation port.

    Common ports follow their `fabric` (schema common_ports):
      broadcast  driven by one block (`from`), an input everywhere else
      gather     an output everywhere but `to`, which takes all of them as
                 one vector (`port`), a bit per block instance
      star       as declared on every block; the `owner` also drives every
                 OTHER block's copy through a vector port (`port`) -- its own
                 declared ports are the host side, and its own instance has no
                 slot in the vector, so nothing at the top is tied off
      observe    CCV_CHECK only, an output read by the checker bank alone
      (none)     as declared: core_clk and rst_n, straight from the top's
                 own ports
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
                P.append(("input", (len(srcs) if srcs else
                                    nb - ninst.get(btype, 1)) * w, fab["port"],
                          False,
                          "%s of %s, in that order" % (name, ", ".join(srcs))
                          if srcs else
                          "every other block instance's %s, by instance index,"
                          " %s's own omitted" % (name, btype),
                          None, None))
            elif srcs is None or btype in srcs:
                P.append((dr, w, name, False, None, None, None))
        elif kind == "star":
            P.append((dr, w, name, False, None, None, None))
            if btype == fab["owner"]:
                P.append((flip(dr), (nb - ninst.get(btype, 1)) * w, fab["port"],
                          False,
                          "%s of every other block instance, by instance index,"
                          " %s's own omitted" % (name, btype),
                          None, None))
        elif kind == "observe":
            P.append((dr, w, name, "CCV_CHECK", None, None, None))
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
                      "CCV_TRACE", None, None, (c, cp, s, "tid")))
    return P


def decl(w, typ):
    return typ + " " if typ else "logic " + rng(w)


GUARDS = ("CCV_CHECK", "CCV_TRACE")


def guarded(items, fmt, lead=", "):
    """Lines for guarded items, one `ifdef block per guard, in GUARDS order.
    `items` are (guard, payload); `fmt` renders a payload."""
    L = []
    for g in GUARDS:
        sel = [x for gg, x in items if gg == g]
        if sel:
            L.append("`ifdef %s" % g)
            L += ["  %s%s" % (lead, fmt(x)) for x in sel]
            L.append("`endif")
    return L


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
    L.append("// `_payload` is typed ccv_<chan>_t. `_tid` is trace-only (CCV_TRACE);")
    L.append("// `clk_gated` is an observation for the checker bank (CCV_CHECK).")
    L.append("//")
    L.append("// One clock, core_clk, UNGATED: the block gates it as its first act,")
    L.append("// inside the block. The top holds only block instances and nets.")
    plain = [p for p in P if not p[3]]
    for k, (dr, w, name, _, doc, typ, _m) in enumerate(plain):
        if doc:
            L.append("  // %s" % doc)
        sep = "," if k != len(plain) - 1 else ""
        L.append("  %-6s %s%s%s" % (dr, decl(w, typ), name, sep))
    L += guarded([(p[3], p) for p in P if p[3]],
                 lambda p: "%-6s %s%s" % (p[0], decl(p[1], p[5]), p[2]), lead=", ")
    return "\n".join(L) + "\n"


def gen_stub(btype, P):
    L = [BANNER]
    L.append("// STUB for ccv_%s: never sends, never consumes, never stalls." % btype)
    L.append("// That is protocol-legal on every channel -- no valid means no")
    L.append("// credit is owed -- so the top elaborates and simulates with every")
    L.append("// checker quiet. Common-port handshakes (kill, CSR) have no")
    L.append("// specified semantics yet, so outputs sit at their inactive value.")
    L.append("// A stub holds no state, so it has no clock gate: clk_gated reports")
    L.append("// the gate open. Real RTL gates core_clk inside itself (CCV-L22).")
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
            L.append("`ifdef %s" % tr)
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


# -- hardening wrappers and repeated links -------------------------------------
#
# Every block instance sits in a hardening wrapper of the same instance name:
# the physical hierarchy, stable whatever the floorplan decides. A wrapper is
# the block plus one sequential repeater (rtl/phys/ccv_seq_rpt.sv) per
# channel end the block owns, at STAGES 0 unless params/links.json says
# otherwise, plus one per FEEDTHROUGH: a channel the floorplan routes across
# this wrapper, which then has ports for it. A stage count is a wrapper
# parameter, set by the top, so changing a split changes no structure; a
# feedthrough changes that one wrapper's ports, and it gets a module of its
# own (ccv_<instance>_w) instead of its type's shared one (ccv_<type>_w).
#
# A channel instance whose route crosses feedthroughs runs in SEGMENTS
# between wrappers; segment j leaves hop j. The top names them
# <chan>[_c<NN>]_h<j>[_s<K>]_<sig> -- and a channel with no feedthrough is
# one segment with its plain name, so an unrepeated top reads as before. The
# checker bank watches segment 0, where the link leaves the source's wrapper.


def cinst_index(cinst, c, copy):
    return next(k for k, x in enumerate(cinst) if x["chan"] is c and x["inst"] == copy)


def nsegs(ci):
    return len(ci["hops"]) - 1


def seg_net(ci, slot, sig, j):
    """The top's net for signal `sig` of `slot` on segment j of a channel
    instance. The segment at EXTERNAL is the top's own port, so it keeps the
    plain name, as does the only segment of an unrouted channel."""
    c, copy, n = ci["chan"], ci["inst"], nsegs(ci)
    if (n == 1 or (c["src"] == "EXTERNAL" and j == 0) or
            (c["dst"] == "EXTERNAL" and j == n - 1)):
        return net_name(c, copy, slot, sig)
    base = c["name"][4:] + copy_sfx(c, copy) + "_h%d" % j
    return base + ("_wake" if sig == "wake" else slot_sfx(c, slot) + "_" + sig)


def seg_is_port(ci, j):
    c, n = ci["chan"], nsegs(ci)
    return ((c["src"] == "EXTERNAL" and j == 0) or
            (c["dst"] == "EXTERNAL" and j == n - 1))


def block_ends(t, i, P, cinst):
    """Block instance (type t, index i)'s channel ends: [(cinst index,
    'src'|'dst', copy as the ports name it)], in port-list order."""
    out, seen = [], set()
    for p in P:
        if p[6] is None:
            continue
        c, cp = p[6][0], p[6][1]
        if (c["id"], cp) in seen:
            continue
        seen.add((c["id"], cp))
        copy = cp if cp is not None else (i if c["ninst"] > 1 else 0)
        assert c["src"] != c["dst"], "a channel from a block to itself"
        out.append((cinst_index(cinst, c, copy), "src" if c["src"] == t else "dst", cp))
    return out


def rpt_param(c, cp):
    return "RPT_" + (c["name"][4:] + copy_sfx(c, cp)).upper()


def ft_param(ci):
    c = ci["chan"]
    return "FT_" + (c["name"][4:] + copy_sfx(c, ci["inst"])).upper()


def feedthroughs(binst, cinst):
    """Block-instance index -> [(cinst index, hop j)] routed across it."""
    ft = {}
    for x, ci in enumerate(cinst):
        for j in range(1, len(ci["hops"]) - 1):
            ft.setdefault(ci["hops"][j][0], []).append((x, j))
    return ft


def wrapper_module(k, t, names, ft):
    return "ccv_%s_w" % (names[k][2:] if ft.get(k) else t)


def rpt_inst(L, name, stages, c, src, dst):
    """One ccv_seq_rpt for a channel instance. `src` and `dst` map a signal to
    its per-slot net names (a function of slot and sig)."""
    r = c["rate"]
    lead = (", .LEAD_MASK(%d'h%x)" % (c["bits"], c["lead_mask"])
            if c["lead_mask"] else "")
    cat = lambda f, sig: "{%s}" % ", ".join(f(sl, sig) for sl in reversed(range(r)))
    L.append("  ccv_seq_rpt #(.STAGES(%s), .SLOTS(%d), .PAYLOAD_W(%d)%s) %s ("
             % (stages, r, c["bits"], lead, name))
    L.append("    .clk(core_clk), .rst_n(rst_n),")
    L.append("    .src_valid(%s), .src_payload(%s)," % (cat(src, "valid"), cat(src, "payload")))
    L.append("    .src_wake(%s), .src_credit(%s), .src_stall(%s),"
             % (src(None, "wake"), cat(src, "credit"), cat(src, "stall")))
    L.append("    .dst_valid(%s), .dst_payload(%s)," % (cat(dst, "valid"), cat(dst, "payload")))
    L.append("    .dst_wake(%s), .dst_credit(%s), .dst_stall(%s)"
             % (dst(None, "wake"), cat(dst, "credit"), cat(dst, "stall")))
    L.append("`ifdef CCV_TRACE")
    L.append("    , .src_tid(%s), .dst_tid(%s)" % (cat(src, "tid"), cat(dst, "tid")))
    L.append("`endif")
    L.append("  );")


def port_nm(c, cp, slot, sig):
    """A block port's name for one signal of the end (c, cp)."""
    base = c["name"][4:] + copy_sfx(c, cp)
    return base + ("_wake" if sig == "wake" else slot_sfx(c, slot) + "_" + sig)


def gen_wrapper(t, mod, P, ends, fts, cinst, ninst):
    L = [BANNER]
    L.append("// HARDENING WRAPPER %s: ccv_%s and the sequential repeaters of its"
             % (mod, t))
    L.append("// channel ends -- the physical hierarchy (docs/physical.md, \"Wrappers")
    L.append("// and links\"). Nothing but instances and nets, like the top. Every")
    L.append("// end has its repeater whether or not the link is repeated: STAGES is")
    L.append("// a parameter the top sets from params/links.json, 0 meaning wires, so")
    L.append("// a new split changes parameters and never this structure.")
    if fts:
        L.append("//")
        L.append("// FEEDTHROUGHS: channels routed across this wrapper, with ports")
        L.append("// fti_* (toward the source) and fto_* (toward the destination):")
        for x, j in fts:
            ci = cinst[x]
            L.append("//   %s copy %d, hop %d" % (ci["chan"]["name"], ci["inst"], j))
    L.append("`include \"ccv_interfaces.svh\"")
    L.append("")
    params = [rpt_param(cinst[x]["chan"], cp) for x, _, cp in ends]
    params += [ft_param(cinst[x]) for x, _ in fts]
    L.append("module %s #(" % mod)
    L.append(",\n".join("  parameter int %s = 0" % p for p in params))
    L.append(") (")
    L.append("  `include \"ccv_%s_ports.svh\"" % t)
    fps = []
    for x, _ in fts:
        ci = cinst[x]
        for side, fwd in (("fti_", "input"), ("fto_", "output")):
            for dr, w, name, tr, _d, typ, _m in chan_ports(ci["chan"], fwd, [ci["inst"]]):
                fps.append((tr, "%-6s %s%s%s" % (dr, decl(w, typ), side, name)))
    L += ["  , " + x for tr, x in fps if not tr]
    L += guarded([x for x in fps if x[0]], lambda x: x)
    L.append(");")
    L.append("")
    L.append("  // Between the block and its repeaters: b_<port>, one net per port.")
    for dr, w, name, tr, _d, typ, m in P:
        if m is None or tr:
            continue
        L.append("  %sb_%s;" % (decl(w, typ), name))
    L += guarded([(tr, "%sb_%s;" % (decl(w, typ), name))
                  for dr, w, name, tr, _d, typ, m in P if m is not None and tr],
                 lambda x: x, lead="")
    L.append("")
    conns, gconns = [], []
    for dr, w, name, tr, _d, typ, m in P:
        ex = name if m is None else "b_" + name
        (gconns.append((tr, ".%s(%s)" % (name, ex))) if tr
         else conns.append(".%s(%s)" % (name, ex)))
    L.append("  ccv_%s u_blk (" % t)
    L.append("    " + ",\n    ".join(conns))
    L += guarded(gconns, lambda x: x, lead="  , ")
    L.append("  );")
    L.append("")
    for x, side, cp in ends:
        c = cinst[x]["chan"]
        blk = lambda sl, sig, c=c, cp=cp: "b_" + port_nm(c, cp, sl, sig)
        out = lambda sl, sig, c=c, cp=cp: port_nm(c, cp, sl, sig)
        L.append("  // %s, %s end" % (c["name"], "source" if side == "src" else "destination"))
        rpt_inst(L, "u_rpt_" + c["name"][4:] + copy_sfx(c, cp), rpt_param(c, cp), c,
                 blk if side == "src" else out, out if side == "src" else blk)
    for x, j in fts:
        ci = cinst[x]
        c = ci["chan"]
        L.append("  // %s copy %d, routed across this wrapper (hop %d)" % (c["name"], ci["inst"], j))
        rpt_inst(L, "u_ft_" + c["name"][4:] + copy_sfx(c, ci["inst"]), ft_param(ci), c,
                 lambda sl, sig, c=c, ci=ci: "fti_" + port_nm(c, ci["inst"], sl, sig),
                 lambda sl, sig, c=c, ci=ci: "fto_" + port_nm(c, ci["inst"], sl, sig))
    L.append("endmodule")
    return "\n".join(L) + "\n"


def gen_top(d, binst, chans, cinst, ninst, common, ports):
    NB = len(binst)
    names = [inst_name(t, i, ninst[t]) for t, i in binst]
    cw = {n: w for n, _, w, _ in common}
    fab = {n: f for n, _, _, f in common}
    owner_idx = lambda t: [k for k, (bt, _) in enumerate(binst) if bt == t]
    # A per-block vector (star, gather by instance) has no slot for its owner:
    # instance k sits at k less the owner instances before it.
    slot_of = lambda k, owner: k - sum(1 for j in owner_idx(owner) if j < k)
    L = [BANNER]
    L.append("// The CCV core: %d block instances, %d channel instances."
             % (NB, len(cinst)))
    L.append("//")
    L.append("// THE RULE: this module holds block instances and the nets between")
    L.append("// them, and nothing else -- no gate, no flop, no constant, no clock")
    L.append("// gate (rtl-coding-style.md, \"The top level\"). Everything can then be")
    L.append("// validated here, and the floorplan can abut the blocks. Each block")
    L.append("// gates core_clk inside itself. tools/check-top-pure.py enforces it on")
    L.append("// the elaborated netlist. The one exception is the checker bank under")
    L.append("// CCV_CHECK, which observes and is absent from every synthesis view.")
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
    L.append("//   core_clk                     UNGATED, to every block; each gates")
    L.append("//                                it inside itself (CCV-L22)")
    L.append("//   clk_gated                    CCV_CHECK only: each block's gate")
    L.append("//                                state, to the checker bank alone")
    L.append("//   csr_*                        a star from CRU, which owns the")
    L.append("//                                CSR fabric; CRU's own csr ports")
    L.append("//                                are the host side, at this")
    L.append("//                                boundary, and CRU has no slot in")
    L.append("//                                its own vectors")
    L.append("// rst_n fans out directly; the reset tree (block letter z) is not")
    L.append("// modelled yet (Q-37).")
    L.append("//")
    L.append("// Block instance index (the per-block common-port vectors are in this")
    L.append("// order, less the vector's owner):")
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
                tp.append((tr, "%-6s %s%s" % (dr, decl(w, typ), name)))
            else:
                P.append("  %-6s %s%s" % (dr, decl(w, typ), name))
    L.append(",\n".join(P))
    L += guarded(tp, lambda x: x)
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
                nv = NB - len(owner_idx(f["to"]))
                L.append("  logic %s%s;   // gathered at %s, its own omitted"
                         % (rng(nv * cw[n]), n, f["to"]))
        elif k == "star":
            nv = NB - len(owner_idx(f["owner"]))
            L.append("  logic %s%s;   // %s, star from %s, its own omitted"
                     % (rng(nv * cw[n]), f["port"], n, f["owner"]))
        elif k == "observe":
            L.append("`ifdef CCV_CHECK")
            L.append("  // %s of every block instance, to the checker bank alone." % n)
            for nm in names:
                L.append("  logic %s_%s;" % (nm[2:], n))
            L.append("`endif")
    L.append("")
    # nets: every segment of every channel instance, but those that are the
    # top's own ports
    ft = feedthroughs(binst, cinst)
    for c in chans:
        cis = [ci for ci in cinst if ci["chan"] is c]
        segs = [(ci, j) for ci in cis for j in range(nsegs(ci)) if not seg_is_port(ci, j)]
        if not segs:
            continue
        L.append("  // %s: %s -> %s, %d cop%s x %d slot%s" % (
            c["name"], c["src"], c["dst"], c["ninst"],
            "y" if c["ninst"] == 1 else "ies", c["rate"],
            "" if c["rate"] == 1 else "s"))
        tr = []
        for ci, j in segs:
            for sl in range(c["rate"]):
                for sig in ("valid", "payload", "credit", "stall"):
                    w = c["bits"] if sig == "payload" else 1
                    typ = "ccv_%s_t" % c["name"][4:] if sig == "payload" else None
                    L.append("  %s%s;" % (decl(w, typ), seg_net(ci, sl, sig, j)))
            L.append("  logic %s;" % seg_net(ci, None, "wake", j))
            tr += [("CCV_TRACE", "logic [63:0] %s;" % seg_net(ci, sl, "tid", j))
                   for sl in range(c["rate"])]
        L += guarded(tr, lambda x: x, lead="")
    L.append("")
    for k, (t, i) in enumerate(binst):
        n = names[k]
        conns = []
        trconns = []
        ends = block_ends(t, i, ports[t], cinst)
        pov = []
        for x, side, cp in ends:
            st = cinst[x]["hops"][0 if side == "src" else -1][1]
            if st:
                pov.append(".%s(%d)" % (rpt_param(cinst[x]["chan"], cp), st))
        for x, j in ft.get(k, []):
            if cinst[x]["hops"][j][1]:
                pov.append(".%s(%d)" % (ft_param(cinst[x]), cinst[x]["hops"][j][1]))
        for dr, w, pname, tr, _, _typ, meta in ports[t]:
            f = fab.get(pname, {})
            kind = f.get("kind")
            gathers = {ff["port"]: nm for nm, ff in fab.items()
                       if ff.get("kind") == "gather"}
            stars = {ff["port"]: nm for nm, ff in fab.items()
                     if ff.get("kind") == "star"}
            if pname == "core_clk":
                ex = "core_clk"              # ungated: the block gates it
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
                    ex = "%s[%d]" % (pname, slot_of(k, f["to"]))
            elif pname in gathers:
                ex = gathers[pname]
            elif kind == "observe":
                ex = "%s_%s" % (n[2:], pname)
            elif kind == "star":
                j = slot_of(k, f["owner"])
                if t == f["owner"]:
                    ex = pname                        # host side
                elif cw[pname] == 1:
                    ex = "%s[%d]" % (f["port"], j)
                else:
                    ex = "%s[%d +: %d]" % (f["port"], j * cw[pname], cw[pname])
            elif pname in stars:
                ex = pname
            else:
                # A channel port: the segment leaving this wrapper, if it is
                # the source, or arriving at it. A block that IS one copy
                # leaves the copy out of its ports; the top's nets carry it.
                c, cp, sl, sig = meta
                copy = cp if cp is not None else (i if c["ninst"] > 1 else 0)
                ci = cinst[cinst_index(cinst, c, copy)]
                ex = seg_net(ci, sl, sig, 0 if c["src"] == t else nsegs(ci) - 1)
            if tr:
                trconns.append((tr, ".%s(%s)" % (pname, ex)))
            else:
                conns.append(".%s(%s)" % (pname, ex))
        for x, j in ft.get(k, []):
            ci = cinst[x]
            for side, jj in (("fti_", j - 1), ("fto_", j)):
                for sl in range(ci["chan"]["rate"]):
                    for sig in ("valid", "payload", "credit", "stall"):
                        conns.append(".%s%s(%s)" % (side, port_nm(ci["chan"], ci["inst"], sl, sig),
                                                    seg_net(ci, sl, sig, jj)))
                    trconns.append(("CCV_TRACE", ".%s%s(%s)" % (
                        side, port_nm(ci["chan"], ci["inst"], sl, "tid"), seg_net(ci, sl, "tid", jj))))
                conns.append(".%s%s(%s)" % (side, port_nm(ci["chan"], ci["inst"], None, "wake"),
                                            seg_net(ci, None, "wake", jj)))
        mod = wrapper_module(k, t, names, ft)
        L.append("  %s %s%s (" % (mod, "#(%s) " % ", ".join(pov) if pov else "", n))
        L.append("    " + ",\n    ".join(conns))
        L += guarded(trconns, lambda x: x, lead="  , ")
        L.append("  );")
        L.append("")
    # the checker bank
    # The bank's vectors are in slot-map order -- channel instance by channel
    # instance, then slot -- with slot 0 at the LSB, so {last, ..., first}.
    # Segment 0 of each: where the link leaves the source's wrapper.
    def cat(sig):
        nets = [seg_net(ci, s, sig, 0)
                for ci in cinst for s in range(ci["chan"]["rate"])]
        return "{%s}" % ", ".join(reversed(nets))
    def cat_wake():
        nets = [seg_net(ci, None, "wake", 0) for ci in cinst]
        return "{%s}" % ", ".join(reversed(nets))
    L.append("`ifdef CCV_CHECK")
    L.append("  // The SAME checker bank the C++ skeleton Verilates, on the real")
    L.append("  // nets: the one thing here that is not a block. It only observes,")
    L.append("  // and it is absent unless CCV_CHECK is defined, so synthesis and")
    L.append("  // the floorplan never see it.")
    L.append("  ccv_skel_checkers u_checkers (")
    L.append("    .clk(core_clk), .rst_n(rst_n), .force_atomic(1'b0), .pair_enable(1'b1),")
    L.append("    .valid(%s)," % cat("valid"))
    L.append("    .credit(%s)," % cat("credit"))
    L.append("    .stall(%s)," % cat("stall"))
    L.append("    .payload(%s)," % cat("payload"))
    L.append("    .wake(%s)," % cat_wake())
    # Each channel instance's receiver's gate state, in the bank's channel
    # instance order; the testbench end of EXTERNAL never sleeps.
    rxg = ["1'b0" if ci["dst"] is None else "%s_clk_gated" % names[ci["dst"]][2:]
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


# -- SV-hosted C++ blocks ------------------------------------------------------
#
# The C++ skeleton's blocks, hosted INSIDE the SV top: a shim per block type
# with the same module name and the same included port list as the stub, so
# swapping a stub, a shim or real RTL is one file-list change, in any mix.
# The shim samples every channel signal it can see at its clock edge -- its
# inputs AND its own registered outputs, since a sender reads back its valid
# and a held payload -- hands them to sim/skel/dpi_host.cpp, which runs the
# C++ block for that cycle, and registers what the block drove. What crosses
# a block boundary is then an SV net, never a C++ object: the top-level
# Verilog does the stitching.
#
# The sample and drive vectors are concatenations in port-list order, the
# first port at the LSB; sim/generated/ccv_dpi_ports.h describes the same
# order to the host, from the same port list, so the two cannot disagree.
# `_wake` is not sampled: no C++ block sleeps or wakes yet (Q-33), so a shim
# drives it low, as a stub does.

SIGS = ("valid", "payload", "credit", "stall", "tid")


def dpi_ports(P):
    """The channel ports a shim samples, in order: every one but wake."""
    return [p for p in P if p[6] is not None and p[6][3] != "wake"]


def ext_ports(chans):
    """The testbench's end of every EXTERNAL channel, as port tuples."""
    P = [("input", 1, "core_clk", False, None, None, None),
         ("input", 1, "rst_n", False, None, None, None)]
    for c in chans:
        if c["src"] == "EXTERNAL":
            P += chan_ports(c, "output", [None])
        elif c["dst"] == "EXTERNAL":
            P += chan_ports(c, "input", [None])
    return P


def gen_shim(btype, P, own_ports=False):
    """A block type whose behaviour is the C++ skeleton's, over DPI-C."""
    S = dpi_ports(P)
    O = [p for p in S if p[0] == "output"]
    sw = sum(p[1] for p in S)
    ow = sum(p[1] for p in O)
    ext = btype == "ext"
    L = [BANNER]
    L.append("// SV-HOSTED C++ for ccv_%s: the C++ skeleton's %s, run through DPI-C" % (
        btype, "testbench end of EXTERNAL" if ext else "functional stub"))
    L.append("// by sim/skel/dpi_host.cpp. Same module name and port list as the")
    L.append("// stub in rtl/top/stubs/ and the real RTL to come, so any mix of the")
    L.append("// three is a file-list change; tools/check-sv-hosted.sh builds the top")
    L.append("// from these alone and requires the run the C++ skeleton produces.")
    L.append("//")
    L.append("// At each edge of its clock: sample every channel signal (%d bits," % sw)
    L.append("// first port at the LSB), let the C++ block run its cycle, register")
    L.append("// what it drove (%d bits). Common-port outputs sit inactive, as in" % ow)
    L.append("// the stub. Simulation only, and only with the trace sideband: the")
    L.append("// C++ blocks carry trace identity on every message.")
    L.append("`include \"ccv_interfaces.svh\"")
    L.append("")
    L.append("/* verilator lint_off UNUSEDSIGNAL */")
    if own_ports:
        L.append("module ccv_%s (" % btype)
        plain = [p for p in P if not p[3]]
        trace = [p for p in P if p[3]]
        for k, (dr, w, name, _, doc, typ, _m) in enumerate(plain):
            sep = "," if k != len(plain) - 1 else ""
            L.append("  %-6s %s%s%s" % (dr, decl(w, typ), name, sep))
        L += guarded([(p[3], p) for p in trace],
                     lambda p: "%-6s %s%s" % (p[0], decl(p[1], p[5]), p[2]))
        L.append(");")
    else:
        L.append("module ccv_%s (" % btype)
        L.append("  `include \"ccv_%s_ports.svh\"" % btype)
        L.append(");")
    L.append("`ifndef CCV_TRACE")
    L.append("  // Refused at elaboration: without _tid there is no identity to carry.")
    L.append("  ccv_sv_hosted_needs_CCV_TRACE u_needs_trace ();")
    L.append("`else")
    L.append("  import \"DPI-C\" context function int ccv_dpi_register(input string path);")
    L.append("  import \"DPI-C\" function bit ccv_dpi_skew(input int h);")
    L.append("  import \"DPI-C\" context function void ccv_dpi_cycle_%s(" % btype)
    L.append("    input int h, input longint cyc, input bit rst,")
    L.append("    input bit [%d:0] sample, output bit [%d:0] drive);" % (sw - 1, ow - 1))
    L.append("")
    L.append("  int h;")
    L.append("  bit skew;              // negative control: one extra register")
    L.append("  longint cyc = 0;")
    L.append("  bit [%d:0] drv, q, q2;" % (ow - 1))
    L.append("  initial begin")
    L.append("    h = ccv_dpi_register($sformatf(\"%m\"));")
    L.append("    skew = ccv_dpi_skew(h);")
    L.append("  end")
    L.append("  // No clock gate: a C++ block never sleeps (Q-33), so it runs on")
    L.append("  // core_clk, which is what a real block's gate would pass when open.")
    L.append("  always @(posedge core_clk) begin")
    L.append("    ccv_dpi_cycle_%s(h, cyc, !rst_n, {" % btype)
    names = [p[2] for p in reversed(S)]
    for k in range(0, len(names), 3):
        chunk = ", ".join(names[k:k + 3])
        L.append("      %s%s" % (chunk, "," if k + 3 < len(names) else ""))
    L.append("    }, drv);")
    L.append("    q <= drv;")
    L.append("    q2 <= q;")
    L.append("    cyc <= cyc + 1;")
    L.append("  end")
    L.append("  assign {")
    names = [p[2] for p in reversed(O)]
    for k in range(0, len(names), 3):
        chunk = ", ".join(names[k:k + 3])
        L.append("    %s%s" % (chunk, "," if k + 3 < len(names) else ""))
    L.append("  } = skew ? q2 : q;")
    L.append("`endif")
    for dr, w, name, tr, _, _t, m in P:
        if dr != "output" or (m is not None and m[3] != "wake"):
            continue
        if tr:
            L.append("`ifdef %s" % tr)
        if w > 8192:
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


def gen_dpi_header(types):
    """sim/generated/ccv_dpi_ports.h: each shim's sample order, for the host.
    `types` is [(name, P)], EXTERNAL's end last as `ext`."""
    L = ["// GENERATED FILE -- DO NOT EDIT. From tools/gen-top.py, with the",
         "// SV-hosted shims in rtl/top/dpi/: each shim's sample vector, in order,",
         "// first entry at the LSB. `copy` -1 is the instance's own copy (a block",
         "// that IS one copy of a replicated channel); `out` is from the block's side.",
         "#ifndef CCV_DPI_PORTS_H",
         "#define CCV_DPI_PORTS_H",
         "#include <cstdint>",
         "",
         "namespace ccv {",
         "namespace skel {",
         "",
         "enum class DpiSig : uint8_t { VALID, PAYLOAD, CREDIT, STALL, TID };",
         "struct DpiPort { uint16_t chan; int16_t copy; uint8_t slot; DpiSig sig;",
         "                 uint32_t width; bool out; };",
         "struct DpiType { const char *name; const DpiPort *ports; unsigned nports;",
         "                 uint32_t sample_bits, drive_bits; };",
         ""]
    for t, P in types:
        S = dpi_ports(P)
        L.append("inline constexpr DpiPort kDpiPorts_%s[] = {" % t)
        for dr, w, name, _tr, _d, _ty, (c, cp, sl, sig) in S:
            L.append("  {%d, %d, %d, DpiSig::%s, %d, %s},  // %s" % (
                c["id"], -1 if cp is None else cp, sl, sig.upper(), w,
                "true" if dr == "output" else "false", name))
        L.append("};")
    L.append("")
    L.append("inline constexpr DpiType kDpiTypes[] = {")
    for t, P in types:
        S = dpi_ports(P)
        L.append("  {\"%s\", kDpiPorts_%s, %d, %d, %d}," % (
            t, t, len(S), sum(p[1] for p in S),
            sum(p[1] for p in S if p[0] == "output")))
    L.append("};")
    L.append("constexpr unsigned kNumDpiTypes = %d;" % len(types))
    L.append("")
    L.append("/// X(type, index into kDpiTypes): one ccv_dpi_cycle_<type> per shim.")
    L.append("#define CCV_DPI_TYPES(X) \\")
    L.append(" \\\n".join("  X(%s, %d)" % (t, k) for k, (t, _) in enumerate(types)))
    L.append("")
    L.append("} // namespace skel")
    L.append("} // namespace ccv")
    L.append("#endif")
    return "\n".join(L) + "\n"


def gen_tb_hosted(chans, common):
    """The testbench for the SV-hosted run: clock, reset, the top, and the
    EXTERNAL end as one more shim. It asks the host each cycle whether the
    kernel is finished, by the same rule the C++ skeleton's loop applies."""
    cw = {n: w for n, _, w, _ in common}
    ext = [c for c in chans if "EXTERNAL" in (c["src"], c["dst"])]
    L = [BANNER, "`timescale 1ns/1ps"]
    L.append("// The SV-hosted run: ccv_core_top built from rtl/top/dpi/ shims, so")
    L.append("// every block is the C++ skeleton's and every connection between them")
    L.append("// is this top's Verilog. The kernel, trace and negative controls come")
    L.append("// in as plusargs the host reads (+ccv_oracle= +ccv_trace= +ccv_break=")
    L.append("// +ccv_shim_delay=<instance> +ccv_cycles=). Reset is low for the first")
    L.append("// two edges, as in the C++ skeleton's loop.")
    L.append("`include \"ccv_interfaces.svh\"")
    L.append("module tb;")
    L.append("  logic core_clk = 1'b0, rst_n = 1'b0;")
    L.append("  // The CSR owner's host side: idle, and nothing here reads it.")
    L.append("  /* verilator lint_off UNUSEDSIGNAL */")
    L.append("  logic %scsr_rsp;" % rng(cw["csr_rsp"]))
    L.append("  logic csr_credit;")
    L.append("  /* verilator lint_on UNUSEDSIGNAL */")
    conns = [".core_clk(core_clk)", ".rst_n(rst_n)", ".csr_req('0)",
             ".csr_rsp(csr_rsp)", ".csr_credit(csr_credit)"]
    econns = [".core_clk(core_clk)", ".rst_n(rst_n)"]
    tr, etr = [], []
    for c in ext:
        for dr, w, name, t, _, typ, _m in chan_ports(c, "output", [None]):
            if t:
                L.append("`ifdef CCV_TRACE")
                L.append("  %s%s;" % (decl(w, typ), name))
                L.append("`endif")
                tr.append(".%s(%s)" % (name, name))
            else:
                L.append("  %s%s;" % (decl(w, typ), name))
                conns.append(".%s(%s)" % (name, name))
    L.append("")
    L.append("  ccv_core_top u_top (")
    L.append("    " + ",\n    ".join(conns))
    L.append("`ifdef CCV_TRACE")
    L.append("    , " + ",\n      ".join(tr))
    L.append("`endif")
    L.append("  );")
    L.append("  ccv_ext u_ext (")
    L.append("    " + ",\n    ".join(econns + conns[5:]))
    L.append("`ifdef CCV_TRACE")
    L.append("    , " + ",\n      ".join(tr))
    L.append("`endif")
    L.append("  );")
    L.append("")
    L.append("  import \"DPI-C\" context function bit ccv_dpi_done(input longint cyc);")
    L.append("  import \"DPI-C\" context function void ccv_dpi_report();")
    L.append("  initial forever #5 core_clk = ~core_clk;")
    L.append("  // Off the edge, so no block samples it mid-change.")
    L.append("  initial begin")
    L.append("    repeat (2) @(posedge core_clk);")
    L.append("    #1 rst_n = 1'b1;")
    L.append("  end")
    L.append("  // Between edges every block has run the cycle: ask whether it is over.")
    L.append("  longint c = 0;")
    L.append("  always @(negedge core_clk) begin")
    L.append("    if (ccv_dpi_done(c)) begin")
    L.append("      ccv_dpi_report();")
    L.append("      $finish;")
    L.append("    end")
    L.append("    c <= c + 1;")
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
        targets.append((os.path.join(TOPDIR, "dpi", "ccv_%s.sv" % t),
                        gen_shim(t, ports[t])))
    names = [inst_name(t, i, ninst[t]) for t, i in binst]
    ft = feedthroughs(binst, cinst)
    made = set()
    for k, (t, i) in enumerate(binst):
        mod = wrapper_module(k, t, names, ft)
        if mod in made:
            continue
        made.add(mod)
        targets.append((os.path.join(TOPDIR, "wrap", "%s.sv" % mod),
                        gen_wrapper(t, mod, ports[t], block_ends(t, i, ports[t], cinst),
                                    ft.get(k, []), cinst, ninst)))
    eports = ext_ports(chans)
    targets.append((os.path.join(TOPDIR, "dpi", "ccv_ext.sv"),
                    gen_shim("ext", eports, own_ports=True)))
    targets.append((os.path.join(TBDIR, "tb_sv_hosted.sv"),
                    gen_tb_hosted(chans, common)))
    # A build product, like the rest of sim/generated/: written, not tracked.
    hdr = os.path.join(ROOT, "sim", "generated", "ccv_dpi_ports.h")
    htext = gen_dpi_header([(b["name"], ports[b["name"]]) for b in blocks] +
                           [("ext", eports)])
    os.makedirs(os.path.dirname(hdr), exist_ok=True)
    if not os.path.exists(hdr) or open(hdr).read() != htext:
        open(hdr, "w").write(htext)
    stale = []
    for path, text in targets:
        os.makedirs(os.path.dirname(path), exist_ok=True)
        cur = open(path).read() if os.path.exists(path) else None
        if cur != text:
            stale.append(os.path.relpath(path, ROOT))
            if not check:
                open(path, "w").write(text)
    # A wrapper module that no longer exists (a feedthrough removed from
    # params/links.json) must not linger: it would still compile, unused.
    wdir = os.path.join(TOPDIR, "wrap")
    want = {os.path.basename(p) for p, _ in targets if os.path.dirname(p) == wdir}
    for f in sorted(os.listdir(wdir)):
        if f.endswith(".sv") and f not in want:
            stale.append(os.path.relpath(os.path.join(wdir, f), ROOT))
            if not check:
                os.remove(os.path.join(wdir, f))
    msg = ("%d files: top, %d port lists, %d stubs, %d DPI shims, %d wrappers, "
           "2 testbenches" % (len(targets), len(blocks), len(blocks),
                              len(blocks) + 1, len(want)))
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
