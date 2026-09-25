#!/usr/bin/env python3
"""The per-instruction trace view shows what the identity decision says.

Builds a small synthetic trace, runs tools/trace2perfetto.py --by=instr, and
checks its structure:
  - an instruction is one process;
  - the transactions it OWNS nest under it by sub-index, not beside it;
  - unowned transactions are grouped apart;
  - class `none` does not appear -- it has no instruction behind it;
  - EV_ID_LINK draws an arrow from the old id to the new.
Each assertion would fail on the obvious wrong implementation (owned txns as
peers; a replay drawn as one id), which is the point of stating them.
"""
import json
import os
import struct
import subprocess
import sys
import tempfile

ROOT = os.path.dirname(os.path.dirname(os.path.abspath(__file__)))
HDR = struct.Struct("<8sII16sQ")
REC = struct.Struct("<QQHHIII")

sch = json.load(open(os.path.join(ROOT, "schema", "events.json")))
uf = sch["uid_layout"]["fields"]
K = sch["uid_layout"]["classes"]
ev = {e["name"]: e["id"] for e in sch["events"]}


def uid(cls, seq, sub=0, owned=0):
    return ((K[cls] << uf["class"]["lsb"]) | (owned << uf["owned"]["lsb"]) |
            (sub << uf["sub"]["lsb"]) | (seq << uf["seq"]["lsb"]))


X, L = ev["EV_CH_XFER"], ev["EV_ID_LINK"]
recs = [
    (1, uid("instr", 7), X, 0, 0, 0, 0),
    (2, uid("txn", 7, sub=1, owned=1), X, 0, 11, 0, 0),   # page split, part 1
    (3, uid("txn", 7, sub=2, owned=1), X, 0, 11, 0, 0),   # page split, part 2
    (4, uid("txn", 99), X, 0, 15, 0, 0),                  # writeback, no owner
    (5, uid("none", 0), X, 0, 17, 0, 0),                  # probe
    (6, 0, L, 0, 8, 7, sch["uid_layout"]["replay_reasons"]["load_replay"]),
    (7, uid("instr", 8), X, 0, 0, 0, 0),                  # the re-execution
]

fails = []
with tempfile.TemporaryDirectory() as t:
    tr, js = os.path.join(t, "t.ccvtrace"), os.path.join(t, "t.json")
    with open(tr, "wb") as f:
        f.write(HDR.pack(b"CCVTRACE", sch["schema_version"], REC.size,
                         b"0" * 16, 0))
        for r in recs:
            f.write(REC.pack(*r))
    subprocess.run([sys.executable, os.path.join(ROOT, "tools", "trace2perfetto.py"),
                    tr, "-o", js, "--by", "instr"], check=True,
                   stdout=subprocess.DEVNULL)
    d = json.load(open(js))["traceEvents"]

inst = [e for e in d if e.get("ph") == "i" and not e["name"].startswith("SCHEMA")]
where = {e["ts"]: (e["pid"], e["tid"]) for e in inst}
P = 1000
if where.get(1) != (P + 7, 0):
    fails.append("instruction 7 is not its own process")
if where.get(2) != (P + 7, 1) or where.get(3) != (P + 7, 2):
    fails.append("owned transactions do not nest under instruction 7 by sub")
if where.get(4, (None,))[0] != 2:
    fails.append("an unowned transaction is not grouped apart")
if 5 in where:
    fails.append("a class-none message appears in the instruction view")
fl = [e for e in d if e.get("ph") in ("s", "f")]
s_ = [e for e in fl if e["ph"] == "s"]
f_ = [e for e in fl if e["ph"] == "f"]
if not (len(s_) == len(f_) == 1 and s_[0]["id"] == f_[0]["id"] and
        s_[0]["pid"] == P + 7 and f_[0]["pid"] == P + 8):
    fails.append("the re-execution is not an arrow from instr 7 to instr 8")
names = {e["pid"]: e["args"]["name"] for e in d
         if e.get("ph") == "M" and e["name"] == "process_name"}
if names.get(P + 7) != "instr 7" or names.get(P + 8) != "instr 8":
    fails.append("instruction processes are not named by id")

if fails:
    for f in fails:
        print("  trace identity view: FAIL -- %s" % f)
    sys.exit(1)
print("  %-46s %s" % ("trace identity view: nesting, replay, none",
                      "PASS"))
