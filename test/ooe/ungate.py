#!/usr/bin/env python3
"""Gated flops for test/ooe/depth.sh: every flop kind synthesis leaves in a
Yosys JSON netlist becomes the plain flop that stands for it, its enable
dropped and a synchronous reset kept (dfflegalize then puts the reset on D).
Under local clock gating an enabled flop is clocked through an ICG and takes
its next value directly; the hold mux a flop-only mapping would add is not
in the design, and the enable is timed on its own path to the gate
(check-cg's CG-2 holds it within 8 NGD). The mapping is tools/check-ngd.py's
(TI-16): legalizing first, as this script once did, left a hold mux on a
flop with both a synchronous reset and an enable.
Usage: ungate.py <in.json> <out.json>"""
import json
import re
import sys

UNGATE = [(re.compile(r"^\$_DFFE_([NP])[NP]_$"), r"$_DFF_\1_"),
          (re.compile(r"^\$_SDFFC?E_([NP][NP][01])[NP]_$"), r"$_SDFF_\1_"),
          (re.compile(r"^\$_(S?DFF)_([NP]|[NP][NP][01])_$"), None)]

d = json.load(open(sys.argv[1]))
n = 0
for m in d["modules"].values():
    for cn, c in m.get("cells", {}).items():
        t = c["type"]
        if not t.startswith("$_") or "DFF" not in t:
            continue
        for rx, to in UNGATE:
            if rx.match(t):
                if to:
                    c["type"] = rx.sub(to, t)
                    for k in ("connections", "port_directions"):
                        c.get(k, {}).pop("E", None)
                    n += 1
                break
        else:
            sys.exit("ungate: %s: no timing model for a %s cell" % (cn, t))
json.dump(d, open(sys.argv[2], "w"))
print("ungate: %d gated flops" % n, file=sys.stderr)
