#!/usr/bin/env python3
"""The SV top's connectivity, extracted from the ELABORATED netlist, must be
exactly the C++ skeleton's.

Both are generated from the same schema, so comparing the generators would
prove nothing. This compares what the two realisations actually are: Yosys
elaborates rtl/top/ccv_core_top.sv, and every bit of every channel port on
every block instance is mapped to a logical coordinate -- (channel, copy,
slot, signal, bit) -- from the port name and the instance name alone, by the
naming rule <chan>[_c<NN>][_s<K>]_<sig> (tools/gen-top.py). Then, for every
net:

  - exactly one driver and one load: nothing dangling, nothing doubled;
  - the driver's and the load's coordinates are IDENTICAL: bit-exact
    routing, including every payload bit;
  - valid and payload flow producer -> consumer, credit and stall back;

and the resulting (channel, copy, slot) -> (producer, consumer) map must equal
the one ccv-skel --dump-wiring reports from the running C++ skeleton.

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
    stubs = sorted(os.path.join(ROOT, "rtl", "top", "stubs", f)
                   for f in os.listdir(os.path.join(ROOT, "rtl", "top", "stubs")))
    inc = " ".join("-I" + os.path.join(ROOT, p) for p in
                   ("rtl/include", "rtl/generated", "rtl/top/ports"))
    files = " ".join([os.path.join(ROOT, "rtl", "ccv_assert_pkg.sv")] + stubs + [top_path])
    r = subprocess.run(["yosys", "-q", "-p",
                        "read_verilog -sv %s %s; hierarchy -check -top ccv_core_top; "
                        "write_json %s" % (inc, files, out_json)],
                       capture_output=True, text=True)
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

    drivers, loads = {}, {}
    def add(bitid, who, coord, is_driver):
        (drivers if is_driver else loads).setdefault(bitid, []).append((who, coord))

    ncells = 0
    for cname, cell in top["cells"].items():
        if not cell["type"].startswith("ccv_"):
            continue
        ncells += 1
        btype = cell["type"][4:]
        dirs = cell.get("port_directions", {})
        for port, bits in cell["connections"].items():
            for i, b in enumerate(bits):
                co = coord_of(ch, ninst, cname, btype, port, i)
                if co is None or isinstance(b, str):
                    continue
                add(b, cname, co, dirs.get(port) == "output")
    for pname, p in top["ports"].items():
        for i, b in enumerate(p["bits"]):
            co = coord_of(ch, ninst, "EXTERNAL", "EXTERNAL", pname, i)
            if co is None:
                continue
            # a top INPUT drives the inside; a top OUTPUT loads it
            add(b, "EXTERNAL", co, p["direction"] == "input")

    errs = []
    edge = {}           # (chan, copy, slot) -> (producer, consumer)
    wake = {}           # (chan, copy) -> (producer, consumer)
    seen = set()
    for b in set(drivers) | set(loads):
        dv, ld = drivers.get(b, []), loads.get(b, [])
        if len(dv) != 1 or len(ld) != 1:
            errs.append("net %s: %d driver(s) %s, %d load(s) %s"
                        % (b, len(dv), dv[:2], len(ld), ld[:2]))
            continue
        (dw, dc), (lw, lc) = dv[0], ld[0]
        if dc != lc:
            errs.append("misrouted: %s %s -> %s %s" % (dw, dc, lw, lc))
            continue
        seen.add(dc)
        chan, copy, slot, sig, _ = dc
        if sig == "wake":
            wake[(chan, copy)] = (dw, lw)       # producer drives it
            continue
        fwd = sig in ("valid", "payload")
        prod, cons = (dw, lw) if fwd else (lw, dw)
        key = (chan, copy, slot)
        if edge.setdefault(key, (prod, cons)) != (prod, cons):
            errs.append("%s: %s disagrees with the slot's other signals" % (key, sig))

    # Wake runs sender to receiver of the same channel instance as its slots.
    for (chan, copy), pc in wake.items():
        if edge.get((chan, copy, 0)) != pc:
            errs.append("%s copy %d: _wake runs %s -> %s, its slots %s"
                        % (chan, copy, pc[0], pc[1], edge.get((chan, copy, 0))))
    want_bits = sum(c["copies"] * (c["rate"] * (3 + c["bits"]) + 1)
                    for c in ch.values())
    if len(seen) != want_bits:
        errs.append("%d channel-signal bits connected, the schema implies %d"
                    % (len(seen), want_bits))

    cpp = set()
    for line in open(dump):
        chan, copy, slot, src, dst = line.split()
        cpp.add((chan, int(copy), int(slot), src, dst))
    sv = {(k[0], k[1], k[2], v[0], v[1]) for k, v in edge.items()}
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
    print("TOPWIRING %s: %d block instances, %d slots, %d bits, "
          "identical to the C++ skeleton" % (label, ncells, len(sv), len(seen)))
    return 0


if __name__ == "__main__":
    sys.exit(main())
