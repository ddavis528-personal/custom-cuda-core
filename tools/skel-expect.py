#!/usr/bin/env python3
"""Expected skeleton counts, derived from the schema by code that shares
nothing with tools/gen-skel.py.

tools/check-skel.sh evals the output. Kept separate from the generator on
purpose: a count checked against the code that produced it checks nothing.
"""
import json
import os

ROOT = os.path.dirname(os.path.dirname(os.path.abspath(__file__)))
d = json.load(open(os.path.join(ROOT, "schema", "interfaces.json")))
b = json.load(open(os.path.join(ROOT, "params", "blocks.json")))
ni = {x["name"]: x["instances"] for x in b["blocks"]}
ni["EXTERNAL"] = 1


def copies(c):
    return max(ni[c["src"]], ni[c["dst"]])


ordered = " ".join(sorted(c["name"] for c in d["channels"]
                          if c.get("slot_attrs", {}).get("ordering") == "ordered"))
print("X_TYPES=%d X_INSTS=%d X_SLOTS=%d X_MULTI=%d X_ORDERED='%s'" % (
    len(d["channels"]),
    sum(copies(c) for c in d["channels"]),
    sum(c["rate"] * copies(c) for c in d["channels"]),
    sum(copies(c) for c in d["channels"] if c["rate"] > 1),
    ordered))
