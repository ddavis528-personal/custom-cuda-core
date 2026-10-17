#!/usr/bin/env python3
"""Gated flops for test/ooe/depth.sh: each enabled flop of a Yosys JSON
netlist ($_DFFE_PP_, after dfflegalize) becomes a plain $_DFF_P_ on its D
input, its enable dropped. Under local clock gating an enabled flop is
clocked through an ICG and takes its next value directly; the hold mux a
flop-only mapping would add is not in the design, and the enable is timed
on its own path to the gate (check-cg's CG-2 holds it within 8 NGD).
Usage: ungate.py <in.json> <out.json>"""
import json
import sys

d = json.load(open(sys.argv[1]))
n = 0
for m in d["modules"].values():
    for c in m.get("cells", {}).values():
        if c["type"] == "$_DFFE_PP_":
            c["type"] = "$_DFF_P_"
            for k in ("connections", "port_directions"):
                c.get(k, {}).pop("E", None)
            n += 1
json.dump(d, open(sys.argv[2], "w"))
print("ungate: %d gated flops" % n, file=sys.stderr)
