#!/usr/bin/env python3
"""The SV top's connectivity, extracted from the ELABORATED netlist, must be
exactly the C++ skeleton's -- block port to block port, through the hardening
wrappers and every repeater stage between them.

Both are generated from the same schema and params/links.json, so comparing
the generators would prove nothing. This compares what the two realisations
actually are. Yosys elaborates the top with the blocks as blackboxes and the
wrappers and repeaters flattened into it (bit-level, constants propagated),
and every bit of every channel port on every block is mapped to a logical
coordinate -- (channel, copy, slot, signal, bit) -- from the port name and
the instance name alone, by the naming rule <chan>[_c<NN>][_s<K>]_<sig>
(tools/gen-top.py). Then every bit a block drives is followed, flop by flop,
to where it ends:

  - it ends on exactly one block port (or top port, for EXTERNAL), with the
    IDENTICAL coordinate: bit-exact routing, every payload bit included;
  - valid and payload flow producer -> consumer, credit and stall back;
  - the flops passed on the way are the link's repeater stages, the same
    in every signal of a slot, each way;

and the resulting (channel, copy, slot) -> (producer, consumer, stages) map
must equal the one ccv-skel --dump-wiring reports from the C++ skeleton.

--mutate first connects one lane's rcu->lane valid to another lane's net in a
temporary copy of the top; the check must then fail. A cross-check that
passes a miswired top proves nothing either.

Yosys elaborates struct-typed ports. A packed ARRAY of structs as a port it
gets silently wrong -- it sizes the port by the array bound and declares the
fields as implicit nets, with warnings only -- so those warnings are
refused here: a netlist Yosys had to resize or invent nets for is not the
design, whatever its connectivity says.
"""
import json
import os
import re
import subprocess
import sys
import tempfile
from ccv_schema import field_width

ROOT = os.path.dirname(os.path.dirname(os.path.abspath(__file__)))
SIGS = ("valid", "payload", "credit", "stall")


def schema():
    d = json.load(open(os.path.join(ROOT, "schema", "interfaces.json")))
    b = json.load(open(os.path.join(ROOT, "params", "blocks.json")))
    pv = {x["name"]: x["value"] for x in
          json.load(open(os.path.join(ROOT, "params", "ccv_params.json")))["params"]}
    ninst = {x["name"]: x["instances"] for x in b["blocks"]}
    ninst["EXTERNAL"] = 1
    ch = {}
    for c in d["channels"]:
        bits = sum(eval(str(field_width(d, c, f)), {"__builtins__": {}}, pv)
                   for f in c["payload_fields"])
        ch[c["name"][4:]] = dict(name=c["name"], src=c["src"], dst=c["dst"],
                                 rate=c["rate"], bits=bits,
                                 copies=max(ninst[c["src"]], ninst[c["dst"]]))
    return ch, ninst


def elaborate(top_path, out_json):
    """The top, the blocks as blackboxes, everything between them flattened
    to single-bit cells with constants propagated -- so a repeater stage is
    one flop per bit and a lead-mask merge is plain wiring."""
    d = os.path.join(ROOT, "rtl", "top")
    stubs = sorted(os.path.join(d, "stubs", f) for f in os.listdir(os.path.join(d, "stubs")))
    wraps = sorted(os.path.join(d, "wrap", f) for f in os.listdir(os.path.join(d, "wrap")))
    inc = " ".join("-I" + os.path.join(ROOT, p) for p in
                   ("rtl/include", "rtl/generated", "rtl/top/ports"))
    rv = "read_verilog -sv -formal %s" % inc
    script = ("%s %s; %s -lib %s; %s %s %s %s; hierarchy -check -top ccv_core_top; "
              "proc; flatten; chformal -remove; techmap; opt -fast; opt_clean; "
              "write_json %s"
              % (rv, os.path.join(ROOT, "rtl", "ccv_assert_pkg.sv"), rv, " ".join(stubs),
                 rv, os.path.join(ROOT, "rtl", "phys", "ccv_seq_rpt.sv"),
                 " ".join(wraps), top_path, out_json))
    r = subprocess.run(["yosys", "-q", "-p", script], capture_output=True, text=True)
    if r.returncode:
        sys.exit("yosys failed: %s" % (r.stderr or r.stdout)[:400])
    log = r.stderr + r.stdout
    for tell in ("Resizing cell port", "is implicitly declared"):
        if tell in log:
            line = next(l for l in log.splitlines() if tell in l)
            sys.exit("yosys mis-elaborated the top (%s): %s" % (tell, line.strip()))
    return json.load(open(out_json))["modules"]["ccv_core_top"]


PORT_RE = re.compile(r"(?P<base>.+?)(?:_c(?P<copy>\d\d))?(?:_s(?P<slot>\d+))?"
                     r"_(?P<sig>valid|payload|credit|stall|wake)$")


def coord_of(ch, ninst, endpoint, btype, port, bit):
    """(chan, copy, slot, sig, bitpos) for one port bit, or None.

    Every port is one slot's signal (or one copy's wake), so the bit index is
    the bit within it. The copy is in the name when the block names one of
    several; a block that IS one copy takes it from its instance name."""
    m = PORT_RE.match(port)
    if not m or m.group("base") not in ch:
        return None
    c = ch[m.group("base")]
    sig = m.group("sig")
    if m.group("copy") is not None:
        copy = int(m.group("copy"))
    elif ninst.get(btype, 1) > 1:
        copy = int(endpoint.rsplit("_", 1)[1])
    else:
        copy = 0
    if sig == "wake":
        return (c["name"], copy, None, sig, 0)
    slot = int(m.group("slot")) if m.group("slot") is not None else 0
    if (m.group("slot") is None) != (c["rate"] == 1):
        return None                             # not this channel's naming
    return (c["name"], copy, slot, sig, bit)


def main():
    mutate = "--mutate" in sys.argv
    dump = next((a.split("=", 1)[1] for a in sys.argv if a.startswith("--wiring=")),
                os.path.join(ROOT, "build", "wiring.txt"))
    ch, ninst = schema()
    top_src = os.path.join(ROOT, "rtl", "top", "ccv_core_top.sv")
    with tempfile.TemporaryDirectory() as t:
        top_path = top_src
        if mutate:
            src = open(top_src).read()
            want = ".rcu_lane_ops_s0_valid(rcu_lane_ops_c03_s0_valid)"
            if want not in src:
                sys.exit("mutation site not found")
            top_path = os.path.join(t, "ccv_core_top.sv")
            open(top_path, "w").write(
                src.replace(want, ".rcu_lane_ops_s0_valid(rcu_lane_ops_c07_s0_valid)", 1))
        top = elaborate(top_path, os.path.join(t, "top.json"))

    # Every endpoint bit -- a block port bit or a top port bit -- with its
    # coordinate, and whether it drives (a block output, a top input).
    ends = {}                  # net bit -> [(who, coord, drives)]
    loads = {}                 # net bit -> [(cell, port)] for every cell input
    flops = {}                 # cell name -> (D bit, Q bit)
    nblocks = 0
    for cname, cell in top["cells"].items():
        ctype = cell["type"]
        conns = cell["connections"]
        dirs = cell.get("port_directions", {})
        if ctype.startswith("ccv_"):            # a block, kept as a blackbox
            nblocks += 1
            inst = cname[:-len(".u_blk")] if cname.endswith(".u_blk") else cname
            btype = ctype[4:]
            for port, bits in conns.items():
                for i, b in enumerate(bits):
                    co = coord_of(ch, ninst, inst, btype, port, i)
                    if co is None or isinstance(b, str):
                        continue
                    ends.setdefault(b, []).append((inst, co, dirs.get(port) == "output"))
            continue
        if "DFF" in ctype:
            flops[cname] = (conns["D"][0], conns["Q"][0])
        for port, bits in conns.items():
            if port in ("Q", "Y") or dirs.get(port) == "output":
                continue
            if "DFF" in ctype and port != "D":
                continue            # an enable, clock or reset: not the data path
            for b in bits:
                loads.setdefault(b, []).append((cname, port))
    for pname, p in top["ports"].items():
        for i, b in enumerate(p["bits"]):
            co = coord_of(ch, ninst, "EXTERNAL", "EXTERNAL", pname, i)
            if co is not None:
                # a top INPUT drives the inside; a top OUTPUT loads it
                ends.setdefault(b, []).append(("EXTERNAL", co, p["direction"] == "input"))
    by_d = {}
    for cname, (d, q) in flops.items():
        by_d.setdefault(d, []).append(q)

    errs = []
    edge = {}           # (chan, copy, slot) -> (producer, consumer, stages)
    wake = {}           # (chan, copy) -> (producer, consumer, stages)
    seen = set()
    for b0, es in ends.items():
        for who, co, drives in es:
            if not drives:
                continue
            # Follow the data path: through flops, to the one endpoint.
            b, n, path_ok = b0, 0, True
            while True:
                sinks = [e for e in ends.get(b, []) if not e[2]]
                nxt = by_d.get(b, [])
                other = [l for l in loads.get(b, []) if l[0] not in flops]
                if len(sinks) + len(nxt) != 1 or other:
                    errs.append("%s %s: %d endpoint(s), %d flop(s) and %d other load(s) at stage %d"
                                % (who, co, len(sinks), len(nxt), len(other), n))
                    path_ok = False
                    break
                if sinks:
                    break
                b, n = nxt[0], n + 1
            if not path_ok:
                continue
            lw, lco, _ = sinks[0]
            if lco != co:
                errs.append("misrouted: %s %s -> %s %s" % (who, co, lw, lco))
                continue
            seen.add(co)
            chan, copy, slot, sig, _ = co
            if sig == "wake":
                if wake.setdefault((chan, copy), (who, lw, n)) != (who, lw, n):
                    errs.append("%s copy %d: _wake bits disagree" % (chan, copy))
                continue
            fwd = sig in ("valid", "payload", "tid")
            prod, cons = (who, lw) if fwd else (lw, who)
            key = (chan, copy, slot)
            if edge.setdefault(key, (prod, cons, n)) != (prod, cons, n):
                errs.append("%s: %s bit %d runs %s -> %s through %d stage(s), the slot's "
                            "other signals %s" % (key, sig, co[4], prod, cons, n, edge[key]))

    # Wake runs sender to receiver of the same channel instance as its slots,
    # through as many stages.
    for (chan, copy), pc in wake.items():
        if edge.get((chan, copy, 0)) != pc:
            errs.append("%s copy %d: _wake runs %s -> %s (%d stages), its slots %s"
                        % (chan, copy, pc[0], pc[1], pc[2], edge.get((chan, copy, 0))))
    want_bits = sum(c["copies"] * (c["rate"] * (3 + c["bits"]) + 1)
                    for c in ch.values())
    nbits = len([x for x in seen if x[3] != "tid"])
    if nbits != want_bits:
        errs.append("%d channel-signal bits connected, the schema implies %d"
                    % (nbits, want_bits))

    cpp = set()
    for line in open(dump):
        chan, copy, slot, src, dst, stages = line.split()
        cpp.add((chan, int(copy), int(slot), src, dst, int(stages)))
    sv = {(k[0], k[1], k[2], v[0], v[1], v[2]) for k, v in edge.items()}
    for x in sorted(cpp - sv)[:3]:
        errs.append("in the C++ skeleton, not the SV top: %s" % (x,))
    for x in sorted(sv - cpp)[:3]:
        errs.append("in the SV top, not the C++ skeleton: %s" % (x,))

    label = "mutated top" if mutate else "SV top"
    if errs:
        print("TOPWIRING %s: FAIL (%d problem(s))" % (label, len(errs)))
        for e in errs[:6]:
            print("  " + e)
        return 1
    rep = sum(1 for x in sv if x[5])
    print("TOPWIRING %s: %d blocks, %d slots, %d bits, identical to the C++ "
          "skeleton; %d slot(s) repeated, %d flop stage(s) traced"
          % (label, nblocks, len(sv), nbits, rep, sum(x[5] for x in sv)))
    return 0


if __name__ == "__main__":
    sys.exit(main())
