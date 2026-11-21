#!/usr/bin/env python3
"""Writes pl_fields.h for test/ooe/pl_tb.cpp: ccv_ooe_rcu_issue's and
ccv_ooe_miu_memop's fields (name, lsb, width, the slots each is defined on, whether it is a lead)
as tools/gen-skel.py lays them out from schema/interfaces.json, so the bench
reads the channels as the skeleton does and cannot drift from them.
Usage: test/ooe/pl-fields.py <out.h>
"""
import importlib.util
import os
import sys

ROOT = os.path.join(os.path.dirname(os.path.abspath(__file__)), "..", "..")
sys.path.insert(0, os.path.join(ROOT, "tools"))
spec = importlib.util.spec_from_file_location("gen_skel", os.path.join(ROOT, "tools", "gen-skel.py"))
gs = importlib.util.module_from_spec(spec)
spec.loader.exec_module(gs)

d, pv, blocks = gs.load()
chans = {c["name"]: c for c in gs.build(d, pv, blocks)[1]}
L = ["// Written by test/ooe/pl-fields.py from schema/interfaces.json; not checked in.",
     "#pragma once",
     "struct PlField { const char *name; unsigned lsb, width; unsigned slots; bool lead; };"]
for name, tag in (("ccv_ooe_rcu_issue", "Iss"), ("ccv_ooe_miu_memop", "Mo")):
    c = chans[name]
    L.append("constexpr unsigned k%sBits = %d;" % (tag, c["bits"]))
    L.append("constexpr PlField k%sFields[] = {" % tag)
    for f, lsb, w in c["fields"]:
        L.append('  {"%s", %d, %d, 0x%xu, %s},' % (f, lsb, w, c["slot_masks"].get(f, 0xFFFFFFFF),
                                               "true" if f in c["lead"] else "false"))
    L.append("};")
open(sys.argv[1], "w").write("\n".join(L) + "\n")
