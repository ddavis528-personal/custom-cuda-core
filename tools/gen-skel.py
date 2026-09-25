#!/usr/bin/env python3
"""Generate the Stage 3 skeleton's wiring from schema/interfaces.json.

Two outputs, both derived, neither hand-maintained:

  sim/generated/ccv_skel_wiring.h      block instances, channel instances,
                                       per-field bit layout, slot map (C++)
  rtl/generated/ccv_skel_checkers.sv   one ccv_credit_checker per slot of
                                       every channel instance (SV)

WHY THE CHECKER BANK IS SV, VERILATED INTO THE C++ SKELETON. Stage 3's exit
criterion includes "zero interface assertion violations", and the skeleton is
C++. The obvious move is a C++ port of the checker, and that is the wrong one:
it is a second implementation of the protocol, which drifts from the first,
and a checker that disagrees with the RTL's checker makes "zero violations" a
statement about the port. Verilating the SAME module means the skeleton and
every future RTL block are judged by identical logic, and the load-bearing
EV_CH_XFER stream comes from identical code on both sides -- which is what
makes 4d correlation compare like with like.

PAYLOAD LAYOUT IS THE SV PACKED LAYOUT. The first declared field is the most
significant, so a field's lsb is the total width of the fields AFTER it. The
C++ side must use exactly this or a swapped-in RTL block sees garbage (F-12:
packed-struct offsets are invisible at the C++ boundary, so they are
generated, never assumed).

INSTANCES. A channel whose endpoint is a multi-instance block is replicated
per instance -- LANE has 32, so rcu->lane and lane->rcu are 32 channels each.
A channel with BOTH endpoints multi-instance has no defined pairing and is a
generation error rather than a guess.

RATE > 1 is modelled as `rate` independent SLOTS, each a complete four-signal
credited channel with its own checker. That is the literal reading of "every
channel follows the common conventions", and it is an ASSUMPTION: the specs
say only "rate is per cycle at peak". It is isolated in the slot map, so the
alternative -- one valid vector with a shared credit pool -- changes this
generator and the skeleton's Channel class, nothing else.
"""
import json
import os
import re
import sys
from ccv_schema import field_width

ROOT = os.path.dirname(os.path.dirname(os.path.abspath(__file__)))
SCHEMA = os.path.join(ROOT, "schema", "interfaces.json")
PARAMS = os.path.join(ROOT, "params", "ccv_params.json")
BLOCKS = os.path.join(ROOT, "params", "blocks.json")
OUT_H = os.path.join(ROOT, "sim", "generated", "ccv_skel_wiring.h")
OUT_SV = os.path.join(ROOT, "rtl", "generated", "ccv_skel_checkers.sv")
OUT_PROBE_SV = os.path.join(ROOT, "rtl", "generated", "ccv_skel_layout_probe.sv")
OUT_PROBE_INC = os.path.join(ROOT, "sim", "generated", "ccv_skel_layout_probe.inc")
OUT_SLOTS_MD = os.path.join(ROOT, "docs", "skeleton-slots.md")

BANNER_C = """// GENERATED FILE -- DO NOT EDIT.
//
// Produced by tools/gen-skel.py from schema/interfaces.json,
// params/blocks.json and params/ccv_params.json. Edit a source and
// regenerate; tools/verify.sh fails if this file is stale.
"""

IDENT = re.compile(r"[A-Za-z_][A-Za-z0-9_]*")


def resolve(expr, pv):
    names = set(IDENT.findall(str(expr)))
    unknown = sorted(n for n in names if n not in pv)
    if unknown:
        raise SystemExit("width %r names unknown parameter(s): %s"
                         % (expr, ", ".join(unknown)))
    return int(eval(str(expr), {"__builtins__": {}}, dict(pv)))


def load():
    d = json.load(open(SCHEMA))
    pv = {x["name"]: x["value"] for x in json.load(open(PARAMS))["params"]}
    b = json.load(open(BLOCKS))
    blocks = [x for x in b["blocks"] if x.get("instances", 0) > 0]
    return d, pv, blocks


def build(d, pv, blocks):
    ninst = {x["name"]: x["instances"] for x in blocks}
    ninst["EXTERNAL"] = 1

    # Block instances, in partition order; a multi-instance block's copies
    # are contiguous so an instance index is (block, n).
    binst = []
    for x in blocks:
        for n in range(x["instances"]):
            binst.append((x["name"], n))
    bidx = {bi: k for k, bi in enumerate(binst)}

    chans = []
    for cid, c in enumerate(d["channels"]):
        fields = []
        widths = [resolve(field_width(d, c, f), pv) for f in c["payload_fields"]]
        total = sum(widths)
        lsb = total
        for f, w in zip(c["payload_fields"], widths):
            lsb -= w                  # first field is the MSB end
            fields.append((f, lsb, w))
        ms, md = ninst[c["src"]] > 1, ninst[c["dst"]] > 1
        if ms and md:
            raise SystemExit("channel %s: both endpoints are multi-instance, "
                             "so its per-instance pairing is undefined"
                             % c["name"])
        n = max(ninst[c["src"]], ninst[c["dst"]])
        dflt = d["slot_attr_defaults"]
        attrs, decided = {}, {}
        for a in ("acceptance", "slot_binding", "binding_group", "ordering",
                  "lockstep"):
            v = c.get("slot_attrs", {}).get(a)
            attrs[a] = v if v is not None else dflt[a]["default"]
            decided[a] = v is not None
        chans.append(dict(id=cid, name=c["name"], src=c["src"], dst=c["dst"],
                          rate=c["rate"], bits=total, fields=fields, ninst=n,
                          src_multi=ms, dst_multi=md, attrs=attrs,
                          decided=decided, id_classes=c["id_classes"],
                          why=c.get("slot_attrs_why", {}),
                          binding_key=c.get("slot_attrs", {}).get("binding_key"),
                          outstanding=c.get("outstanding")))

    # Channel instances and the slot map. Slots are numbered channel instance
    # by channel instance, so a slot index is stable for a fixed schema and
    # a checker instance name maps back to exactly one slot.
    cinst = []
    slot = 0
    pbit = 0
    for c in chans:
        for i in range(c["ninst"]):
            s_inst = i if c["src_multi"] else 0
            d_inst = i if c["dst_multi"] else 0
            cinst.append(dict(chan=c, inst=i, slot_base=slot,
                              payload_base=pbit,
                              src=None if c["src"] == "EXTERNAL"
                              else bidx[(c["src"], s_inst)],
                              dst=None if c["dst"] == "EXTERNAL"
                              else bidx[(c["dst"], d_inst)]))
            slot += c["rate"]
            pbit += c["rate"] * c["bits"]
    return binst, chans, cinst, slot, pbit


def gen_h(binst, chans, cinst, nslots, pbits, blocks):
    L = [BANNER_C, "#ifndef CCV_SKEL_WIRING_H", "#define CCV_SKEL_WIRING_H",
         "", "#include <cstdint>", "", "namespace ccv {", "namespace skel {",
         ""]
    L.append("/// Block TYPES, in partition order. EXTERNAL is the testbench "
             "end")
    L.append("/// of an outbound external channel, not a block.")
    L.append("enum class Blk : uint8_t {")
    for x in blocks:
        L.append("  %s," % x["name"].upper())
    L.append("  EXTERNAL,")
    L.append("};")
    L.append("constexpr unsigned kNumBlockTypes = %d;" % len(blocks))
    L.append("")
    L.append("inline const char *blkName(Blk b) {")
    L.append("  switch (b) {")
    for x in blocks:
        L.append('  case Blk::%s: return "%s";' % (x["name"].upper(), x["name"]))
    L.append('  case Blk::EXTERNAL: return "EXTERNAL";')
    L.append("  }")
    L.append('  return "?";')
    L.append("}")
    L.append("")
    L.append("/// One bit field of a payload. lsb/width are positions in the")
    L.append("/// SystemVerilog PACKED struct: the first declared field is the")
    L.append("/// most significant.")
    L.append("struct FieldDesc { const char *name; uint32_t lsb; uint32_t width; };")
    L.append("")
    L.append("/// Ordering is a KEY: none; one order per binding group; or one")
    L.append("/// order per value of a payload field (e.g. warp_id).")
    L.append("enum class Order : uint8_t { kNone, kSlotGroup, kField };")
    L.append("")
    L.append("struct ChanDesc {")
    L.append("  uint16_t id; const char *name; Blk src, dst;")
    L.append("  uint16_t rate;       ///< slots: independent credited channels")
    L.append("  uint32_t bits;       ///< payload width")
    L.append("  uint16_t nfields; const FieldDesc *fields;")
    L.append("  uint16_t ninst;      ///< copies, one per instance of a multi-instance end")
    L.append("  bool atomic;         ///< acceptance: a group moves together")
    L.append("  uint8_t bind_group;  ///< 0 = free; else slots per binding group")
    L.append("  Order order;         ///< ordering key kind")
    L.append("  int16_t order_field; ///< fields[] index when order == kField")
    L.append("  bool lockstep;       ///< all instances advance together")
    L.append("  uint8_t id_classes;  ///< bit (1 << IdClass) per class it may carry")
    L.append("  int16_t bind_key;    ///< fields[] index of the binding key, or -1:")
    L.append("                       ///< it must equal slot / bind_group")
    L.append("};")
    L.append("")
    for c in chans:
        L.append("inline constexpr FieldDesc kF_%s[] = {" % c["name"])
        for f, lsb, w in c["fields"]:
            L.append('  {"%s", %d, %d},' % (f, lsb, w))
        L.append("};")
    L.append("")
    L.append("inline constexpr ChanDesc kChans[] = {")
    for c in chans:
        cls = sum(1 << {"none": 0, "instr": 1, "txn": 2}[k]
                  for k in c["id_classes"])
        o = c["attrs"]["ordering"]
        if c["rate"] == 1 or o == "none":
            ok, of = "Order::kNone", -1
        elif o == "slot_group":
            ok, of = "Order::kSlotGroup", -1
        else:
            ok = "Order::kField"
            of = [f for f, _, _ in c["fields"]].index(o)
        bg = (c["attrs"]["binding_group"]
              if c["attrs"]["slot_binding"] == "bound" else 0)
        bk = ([f for f, _, _ in c["fields"]].index(c["binding_key"])
              if c["binding_key"] else -1)
        L.append('  {%d, "%s", Blk::%s, Blk::%s, %d, %d, %d, kF_%s, %d, %s, %d, %s, %d, %s, %d, %d},'
                 % (c["id"], c["name"], c["src"].upper(), c["dst"].upper(),
                    c["rate"], c["bits"], len(c["fields"]), c["name"],
                    c["ninst"],
                    "true" if c["attrs"]["acceptance"] == "atomic" else "false",
                    bg, ok, of,
                    "true" if c["attrs"]["lockstep"] else "false", cls, bk))
    L.append("};")
    L.append("constexpr unsigned kNumChans = %d;" % len(chans))
    L.append("")
    L.append("/// Block INSTANCES: 45 of them. A multi-instance type's copies")
    L.append("/// are contiguous.")
    L.append("struct BlkInst { Blk type; uint16_t index; };")
    L.append("inline constexpr BlkInst kBlkInsts[] = {")
    for name, n in binst:
        L.append("  {Blk::%s, %d}," % (name.upper(), n))
    L.append("};")
    L.append("constexpr unsigned kNumBlkInsts = %d;" % len(binst))
    L.append("")
    L.append("/// Channel INSTANCES. src/dst index kBlkInsts; -1 is EXTERNAL.")
    L.append("/// slot_base and payload_base locate this instance in the")
    L.append("/// checker bank's flat valid/credit/stall and payload vectors.")
    L.append("struct ChanInst {")
    L.append("  uint16_t chan; uint16_t inst; int16_t src; int16_t dst;")
    L.append("  uint32_t slot_base; uint64_t payload_base;")
    L.append("};")
    L.append("inline constexpr ChanInst kChanInsts[] = {")
    for ci in cinst:
        L.append("  {%d, %d, %d, %d, %d, %d},"
                 % (ci["chan"]["id"], ci["inst"],
                    -1 if ci["src"] is None else ci["src"],
                    -1 if ci["dst"] is None else ci["dst"],
                    ci["slot_base"], ci["payload_base"]))
    L.append("};")
    L.append("constexpr unsigned kNumChanInsts = %d;" % len(cinst))
    L.append("constexpr unsigned kNumSlots = %d;" % nslots)
    L.append("constexpr uint64_t kPayloadBits = %d;" % pbits)
    L.append("")
    L.append("} // namespace skel")
    L.append("} // namespace ccv")
    L.append("#endif // CCV_SKEL_WIRING_H")
    return "\n".join(L) + "\n"


def gen_sv(chans, cinst, nslots, pbits):
    L = [BANNER_C.replace("C++", "SV"), ""]
    L.append("// One ccv_credit_checker per slot of every channel instance --")
    L.append("// %d in all. Verilated into the C++ skeleton, which drives these"
             % nslots)
    L.append("// ports from its channels every cycle, so the skeleton is judged")
    L.append("// by the same checker the RTL will be.")
    L.append("`include \"ccv_if.svh\"")
    L.append("`include \"ccv_params_pkg.sv\"")
    L.append("")
    L.append("module ccv_skel_checkers (")
    L.append("  input logic                 clk,")
    L.append("  input logic                 rst_n,")
    L.append("  input logic [%d:0]          valid," % (nslots - 1))
    L.append("  input logic [%d:0]          credit," % (nslots - 1))
    L.append("  input logic [%d:0]          stall," % (nslots - 1))
    L.append("  input logic [%d:0]          payload," % (pbits - 1))
    L.append("  // Test override: switches EVERY multi-slot channel's atomic")
    L.append("  // check on. It can only add checks -- a channel the schema")
    L.append("  // marks atomic is checked whatever this says.")
    L.append("  input logic                 force_atomic,")
    L.append("  // Request/response pairs with an outstanding limit. Off only for")
    L.append("  // the S0 exerciser, whose synthetic traffic sends on each channel")
    L.append("  // independently; on for the functional stubs and in the SV top.")
    L.append("  input logic                 pair_enable")
    L.append("`ifdef CCV_TRACE")
    L.append("  ,")
    L.append("  // Trace-only message identity, 64 bits per slot. Absent")
    L.append("  // without CCV_TRACE, so synthesis never sees it.")
    L.append("  input logic [%d:0]          tid" % (64 * nslots - 1))
    L.append("`endif")
    L.append(");")
    L.append("")
    for ci in cinst:
        c = ci["chan"]
        base = c["name"][4:]
        tag = "%s_i%d" % (base, ci["inst"]) if c["ninst"] > 1 else base
        for s in range(c["rate"]):
            k = ci["slot_base"] + s
            off = ci["payload_base"] + s * c["bits"]
            L.append("  ccv_credit_checker #(.PAYLOAD_W(%d), .CHANNEL(%d)) "
                     "u_%s_s%d (" % (c["bits"], c["id"], tag, s))
            L.append("    .clk(clk), .rst_n(rst_n), .ch_valid(valid[%d]), "
                     ".ch_credit(credit[%d]), .ch_stall(stall[%d])," % (k, k, k))
            L.append("    .ch_payload(payload[%d:%d])" % (off + c["bits"] - 1, off))
            L.append("`ifdef CCV_TRACE")
            L.append("    , .ch_tid(tid[%d:%d])" % (64 * k + 63, 64 * k))
            L.append("`endif")
            L.append("  );")
        if c["rate"] > 1:
            lo, hi = ci["slot_base"], ci["slot_base"] + c["rate"] - 1
            L.append("  ccv_atomic_checker #(.N(%d)) u_%s_atomic ("
                     % (c["rate"], tag))
            L.append("    .clk(clk), .rst_n(rst_n), .enable(1'b%d | force_atomic),"
                     % (1 if c["attrs"]["acceptance"] == "atomic" else 0))
            L.append("    .valid(valid[%d:%d]), .credit(credit[%d:%d]));"
                     % (hi, lo, hi, lo))
    for ci in cinst:
        c = ci["chan"]
        if not c["binding_key"]:
            continue
        f, klsb, kw = next(x for x in c["fields"] if x[0] == c["binding_key"])
        tag = "%s_i%d" % (c["name"][4:], ci["inst"]) if c["ninst"] > 1 else c["name"][4:]
        lo, hi = ci["slot_base"], ci["slot_base"] + c["rate"] - 1
        keys = ", ".join(
            "payload[%d:%d]" % (ci["payload_base"] + s * c["bits"] + klsb + kw - 1,
                                ci["payload_base"] + s * c["bits"] + klsb)
            for s in reversed(range(c["rate"])))
        L.append("  ccv_binding_checker #(.N(%d), .GROUP(%d), .W(%d)) u_%s_binding ("
                 % (c["rate"], c["attrs"]["binding_group"], kw, tag))
        L.append("    .clk(clk), .rst_n(rst_n), .valid(valid[%d:%d]),"
                 % (hi, lo))
        L.append("    .key({%s}));" % keys)
    byname = {c["name"]: c for c in chans}
    for c in chans:
        if not c["outstanding"]:
            continue
        rsp = byname[c["outstanding"]["answered_by"]]
        rq = next(ci for ci in cinst if ci["chan"] is c)["slot_base"]
        rs = next(ci for ci in cinst if ci["chan"] is rsp)["slot_base"]
        L.append("  ccv_outstanding_checker #(.MAX(%d)) u_%s_outstanding ("
                 % (c["outstanding"]["max"], c["name"][4:]))
        L.append("    .clk(clk), .rst_n(rst_n), .enable(pair_enable),")
        L.append("    .req_valid(valid[%d]), .rsp_valid(valid[%d]));  // %s"
                 % (rq, rs, rsp["name"]))
    for c in chans:
        if not c["attrs"]["lockstep"]:
            continue
        first = [ci for ci in cinst if ci["chan"] is c]
        lo = first[0]["slot_base"]
        hi = lo + c["ninst"] * c["rate"] - 1
        # The instances' slots are contiguous and instance-major, because the
        # slot map is built channel instance by channel instance.
        assert all(ci["slot_base"] == lo + ci["inst"] * c["rate"] for ci in first)
        L.append("  ccv_lockstep_checker #(.INSTS(%d), .N(%d)) u_%s_lockstep ("
                 % (c["ninst"], c["rate"], c["name"][4:]))
        L.append("    .clk(clk), .rst_n(rst_n),")
        L.append("    .valid(valid[%d:%d]), .credit(credit[%d:%d])" % (hi, lo, hi, lo))
        L.append("`ifdef CCV_TRACE")
        L.append("    , .tid(tid[%d:%d])" % (64 * hi + 63, 64 * lo))
        L.append("`endif")
        L.append("  );")
    L.append("")
    L.append("endmodule")
    return "\n".join(L) + "\n"


def gen_probe_sv(chans):
    """Every field read back THROUGH the generated SV typedef.

    The C++ offsets above and the SV structs in ccv_interfaces.svh come from
    two generators that agree by construction -- both walk payload_fields in
    order. That is exactly the kind of agreement F-12 says not to trust at a
    swap boundary: if they ever disagree, a swapped-in RTL block reads every
    field wrong while the skeleton looks fine. So the SV side is asked
    directly, through the real struct, rather than recomputed.
    """
    L = [BANNER_C.replace("C++", "SV"), ""]
    L.append("`include \"ccv_interfaces.svh\"")
    L.append("")
    L.append("module ccv_skel_layout_probe (")
    ports = []
    for c in chans:
        ports.append("  input  logic [%d:0] c%d" % (c["bits"] - 1, c["id"]))
        for j, (f, lsb, w) in enumerate(c["fields"]):
            rng = "" if w == 1 else "[%d:0] " % (w - 1)
            ports.append("  output logic %sc%d_f%d" % (rng, c["id"], j))
    L.append(",\n".join(ports))
    L.append(");")
    for c in chans:
        L.append("  ccv_%s_t s%d;" % (c["name"][4:], c["id"]))
        L.append("  assign s%d = c%d;" % (c["id"], c["id"]))
        for j, (f, lsb, w) in enumerate(c["fields"]):
            L.append("  assign c%d_f%d = s%d.%s;" % (c["id"], j, c["id"], f))
    L.append("endmodule")
    return "\n".join(L) + "\n"


def gen_probe_inc(chans):
    L = [BANNER_C, "// Included by sim/skel/layout_probe.cpp, which supplies put/eq.", ""]
    L.append("static unsigned probeOnce(Vccv_skel_layout_probe &p, uint64_t seed) {")
    L.append("  unsigned bad = 0;")
    for c in chans:
        L.append("  {")
        L.append("    const Bits b = randomBits(%d, seed ^ %du);" % (c["bits"], c["id"] * 7919))
        L.append("    put(p.c%d, b);" % c["id"])
        L.append("    p.eval();")
        for j, (f, lsb, w) in enumerate(c["fields"]):
            L.append('    bad += check("%s", "%s", p.c%d_f%d, b, %d, %d);'
                     % (c["name"], f, c["id"], j, lsb, w))
        L.append("  }")
    L.append("  return bad;")
    L.append("}")
    return "\n".join(L) + "\n"


def gen_slots_md(chans, cinst, nslots):
    """The slot count, derived where it can be re-derived by hand.

    A wrong rate on a times-32 channel inflates the count and STILL produces a
    clean run: every slot that exists is checked, and no checker exists for a
    slot that should have been there. So the count is the one number a clean
    run does not validate, and it is written out term by term instead of
    being inferred from a passing run. tools/check-skel.sh re-derives it
    independently of this generator every time the gate runs.
    """
    L = ["<!-- GENERATED FILE -- DO NOT EDIT. Produced by tools/gen-skel.py;",
         "     tools/verify.sh fails if it is stale. -->", "",
         "# Skeleton slot derivation", "",
         "Every credited slot the skeleton builds, derived from",
         "`schema/interfaces.json` and `params/blocks.json`: a channel type has",
         "`rate` slots per instance, and one instance per instance of a",
         "multi-instance endpoint (LANE has 32).", "",
         "## The count", "",
         "| Channel types | Rate | Instances each | Slots |", "|---|---|---|---|"]
    groups = {}
    for c in chans:
        groups.setdefault((c["rate"], c["ninst"]), []).append(c)
    total = 0
    for (r, n) in sorted(groups):
        k = len(groups[(r, n)])
        L.append("| %d | %d | %d | %d |" % (k, r, n, k * r * n))
        total += k * r * n
    L.append("| **%d** | | | **%d** |" % (len(chans), total))
    assert total == nslots
    L.append("")
    L.append("%d channel types; **%d channel instances** (%d types at one "
             "instance, plus %d at 32 each); **%d slots**, one "
             "`ccv_credit_checker` each."
             % (len(chans), len(cinst),
                sum(1 for c in chans if c["ninst"] == 1),
                sum(1 for c in chans if c["ninst"] > 1), nslots))
    L.append("")
    L.append("The terms that matter most are the ones multiplied by 32: a rate "
             "wrong by one on either lane channel moves the total by 32 and "
             "every run stays clean.")
    L.append("")
    L.append("## Every channel, with its slot attributes")
    L.append("")
    L.append("Slot attributes apply to rate > 1 only; lockstep to channels "
             "replicated across a multi-instance endpoint. *Italic* is the "
             "permissive default; **bold** is decided, with the reason.")
    L.append("")
    L.append("| # | Channel | Rate × inst | Slots | Acceptance | Binding | "
             "Ordering key | Lockstep | Id classes |")
    L.append("|---|---|---|---|---|---|---|---|---|")
    def fmt(c, a, show=None):
        if a != "lockstep" and c["rate"] == 1:
            return "—"
        if a == "lockstep" and c["ninst"] == 1:
            return "—"
        v = show if show is not None else c["attrs"][a]
        return ("**%s** — %s" % (v, c["why"][a]) if c["decided"][a]
                else "*%s*" % v)
    for c in chans:
        b = c["attrs"]["slot_binding"]
        if b == "bound":
            b = "bound, groups of %d" % c["attrs"]["binding_group"]
        L.append("| %d | `%s` | %d × %d | %d | %s | %s | %s | %s | %s |"
                 % (c["id"], c["name"], c["rate"], c["ninst"],
                    c["rate"] * c["ninst"], fmt(c, "acceptance"),
                    fmt(c, "slot_binding", b), fmt(c, "ordering"),
                    fmt(c, "lockstep", "true" if c["attrs"]["lockstep"] else "false"),
                    ", ".join(c["id_classes"])))
    return "\n".join(L) + "\n"


def main():
    check = "--check" in sys.argv
    d, pv, blocks = load()
    binst, chans, cinst, nslots, pbits = build(d, pv, blocks)
    targets = [(OUT_H, gen_h(binst, chans, cinst, nslots, pbits, blocks)),
               (OUT_SV, gen_sv(chans, cinst, nslots, pbits)),
               (OUT_PROBE_SV, gen_probe_sv(chans)),
               (OUT_PROBE_INC, gen_probe_inc(chans)),
               (OUT_SLOTS_MD, gen_slots_md(chans, cinst, nslots))]
    stale = []
    for path, text in targets:
        os.makedirs(os.path.dirname(path), exist_ok=True)
        cur = open(path).read() if os.path.exists(path) else None
        if cur != text:
            stale.append(os.path.relpath(path, ROOT))
            if not check:
                open(path, "w").write(text)
    msg = ("%d block instances, %d channel instances, %d slots, %d payload bits"
           % (len(binst), len(cinst), nslots, pbits))
    if check:
        if stale:
            sys.stderr.write("stale: %s\n  run tools/gen-skel.py\n"
                             % ", ".join(stale))
            return 1
        print("  skeleton wiring up to date (%s)" % msg)
        return 0
    print("  generated skeleton wiring (%s)" % msg)
    return 0


if __name__ == "__main__":
    sys.exit(main())
