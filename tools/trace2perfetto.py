#!/usr/bin/env python3
"""Convert a CCV binary event trace into Chrome Trace Event JSON, which
Perfetto (ui.perfetto.dev) renders directly.

§1: "the format maps directly onto the Chrome trace event format Perfetto
renders -- one track per instruction or structure, no bespoke viewer needed."
This is that mapping, and it is the entire visualization effort: there is no
CCV-specific viewer to build or maintain.

Two views, because §1 names both and they answer different questions:

  --by=unit   (default)  one track per structure. Occupancy and contention:
                         where the machine is spending itself.
  --by=instr             one track per instruction. Lifetime from decode to
                         retire, which is what a single instruction's stall
                         story looks like.

Arbitration-sensitive events (§1) are emitted into their own Perfetto category
so they can be filtered out in one click. The point is §5's triage: a
divergence in a load-bearing event is a bug, a divergence in an
arbitration-sensitive one may be a faithful-arbiter question, and the two
should not be read on the same footing by eye any more than by script.
"""
import argparse
import json
import os
import struct
import sys

ROOT = os.path.dirname(os.path.dirname(os.path.abspath(__file__)))
sys.path.insert(0, os.path.join(ROOT, "tools"))

HDR = struct.Struct("<8sII16sQ")
REC = struct.Struct("<QQHHIII")


def load_schema():
    with open(os.path.join(ROOT, "schema", "events.json")) as f:
        return json.load(f)


def read_trace(path):
    with open(path, "rb") as f:
        raw = f.read(HDR.size)
        if len(raw) < HDR.size:
            sys.exit("%s: short header" % path)
        magic, ver, rsize, shash, _ = HDR.unpack(raw)
        if magic != b"CCVTRACE":
            sys.exit("%s: not a CCV trace" % path)
        if rsize != REC.size:
            sys.exit("%s: record size %d, expected %d" % (path, rsize, REC.size))
        hdr = {"version": ver, "hash": shash.decode("ascii", "replace")}
        recs = []
        while True:
            b = f.read(REC.size)
            if len(b) == 0:
                break
            if len(b) < REC.size:
                sys.exit("%s: truncated final record" % path)
            recs.append(REC.unpack(b))
        return hdr, recs


def main():
    ap = argparse.ArgumentParser()
    ap.add_argument("trace")
    ap.add_argument("-o", "--out", default="-")
    ap.add_argument("--by", choices=("unit", "instr"), default="unit")
    args = ap.parse_args()

    schema = load_schema()
    ev_by_id = {e["id"]: e for e in schema["events"]}
    unit_by_id = {v: k for k, v in schema["units"].items()
                  if not k.startswith("_")}
    # EV_CH_XFER goes on a track per CHANNEL rather than per unit. It is
    # emitted by the shared credit checker, which sits between two blocks and
    # belongs to neither, so its unit is UNIT_UNKNOWN -- and a whole machine's
    # traffic on one track (231k events in the first skeleton run) is not a
    # view of anything. The schema defines its `a` field as the channel id,
    # so the channel is recoverable without changing the event record.
    with open(os.path.join(ROOT, "schema", "interfaces.json")) as f:
        chan_name = {i: c["name"] for i, c in
                     enumerate(json.load(f)["channels"])}
    xfer_id = next((e["id"] for e in schema["events"]
                    if e["name"] == "EV_CH_XFER"), None)

    hdr, recs = read_trace(args.trace)
    want = None
    # The schema hash is advisory here rather than fatal: looking at an old
    # trace is a legitimate thing to want to do, and refusing would make the
    # viewer useless for exactly the archaeology it is best at. The mismatch
    # is reported loudly instead, into the trace itself where it cannot be
    # missed.
    try:
        gen = os.path.join(ROOT, "sim", "generated", "ccv_event_ids.h")
        for line in open(gen):
            if "kSchemaHash" in line:
                want = line.split('"')[1]
                break
    except OSError:
        pass

    out = []
    if want and want != hdr["hash"]:
        out.append({"name": "SCHEMA MISMATCH: trace %s, current %s"
                            % (hdr["hash"], want),
                    "ph": "i", "s": "g", "ts": 0, "pid": 0, "tid": 0})

    for cycle, uid, eid, unit, a, b, c in recs:
        ev = ev_by_id.get(eid)
        name = ev["name"] if ev else "EV_UNKNOWN_%d" % eid
        cls = ev["class"] if ev else "load_bearing"
        fields = ev["fields"] if ev else {"a": "a", "b": "b", "c": "c"}
        if args.by == "unit" and eid == xfer_id:
            pid, tid = 3, a
            track = chan_name.get(a, "channel %d" % a)
        elif args.by == "unit":
            pid, tid = 1, unit
            track = unit_by_id.get(unit, "UNIT_%d" % unit)
        else:
            pid, tid = 2, uid & 0xFFFFFFFF
            track = "instr %d" % uid
        out.append({
            "name": name,
            "cat": cls,
            "ph": "i",            # instant event: §1's events are points in time
            "s": "t",
            # Chrome timestamps are microseconds; one cycle maps to one tick so
            # the axis reads directly as cycles rather than as a fake wall clock.
            "ts": cycle,
            "pid": pid,
            "tid": tid,
            "args": {"instr_uid": uid, "unit": track,
                     fields["a"]: a, fields["b"]: b, fields["c"]: c},
        })

    # Name the tracks so Perfetto's sidebar reads as structures, not numbers.
    meta = []
    seen = set()
    for e in out:
        key = (e.get("pid"), e.get("tid"))
        if key in seen or e.get("ph") == "i" and e.get("s") == "g":
            continue
        seen.add(key)
        meta.append({"name": "thread_name", "ph": "M", "pid": key[0],
                     "tid": key[1], "args": {"name": e["args"]["unit"]}})
    meta.append({"name": "process_name", "ph": "M", "pid": 1, "tid": 0,
                 "args": {"name": "CCV structures"}})
    meta.append({"name": "process_name", "ph": "M", "pid": 2, "tid": 0,
                 "args": {"name": "CCV instructions"}})
    meta.append({"name": "process_name", "ph": "M", "pid": 3, "tid": 0,
                 "args": {"name": "CCV channels"}})

    doc = {"traceEvents": meta + out,
           "displayTimeUnit": "ns",
           "ccv": {"schema_version": hdr["version"], "schema_hash": hdr["hash"],
                   "events": len(recs)}}
    text = json.dumps(doc, indent=1)
    if args.out == "-":
        sys.stdout.write(text + "\n")
    else:
        with open(args.out, "w") as f:
            f.write(text + "\n")
        print("  %d events -> %s (open at ui.perfetto.dev)"
              % (len(recs), os.path.relpath(args.out, ROOT)))
    return 0


if __name__ == "__main__":
    sys.exit(main())
