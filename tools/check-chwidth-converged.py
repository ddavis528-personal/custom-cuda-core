#!/usr/bin/env python3
"""Every chwidth in a converged warp (F-197; AR's revs 179 and 181, OA's 232).

A register's width is warp state, set in rename order, and rename order is
FET's pick, not ccv-sim's lowest PC first. So a chwidth executed by one
group of a diverged warp races the other groups, and the core and the
oracle can disagree. Until the ISA makes it a fault (IS-23), this holds
every record to it: a chwidth's issue mask must be the warp's live lanes,
with no exception for a register dead past the reconvergence.

Each oracle file is one warp. Its live lanes are its first record's mask
(a warp starts converged), less every exit's mask.

Usage: tools/check-chwidth-converged.py <oracle*.jsonl> ...
       tools/check-chwidth-converged.py --selftest <oracle*.jsonl>
--selftest takes the first chwidth of the files it is given, clears one of
its lanes, and must find it diverged: the check's negative control.
"""
import json, sys

CHW = ("C_CHWIDTH", "CHWIDTH_MULTI")

def scan(lines):
    """(chwidths seen, [(seq, mask, live)] diverged)"""
    live = None; seen = 0; bad = []
    for line in lines:
        j = json.loads(line)
        if "op" not in j: continue
        if live is None: live = j["mask"]
        if j["op"] in CHW:
            seen += 1
            if j["mask"] != live: bad.append((j["seq"], j["mask"], live))
        if j["op"].endswith("EXIT"): live &= ~j["mask"]
    return seen, bad

def mutate(lines):
    out = []; done = False
    for line in lines:
        j = json.loads(line) if not done else None
        if j and j.get("op") in CHW and j["mask"]:
            j["mask"] &= j["mask"] - 1          # clear its lowest lane
            line = json.dumps(j); done = True
        out.append(line)
    return out, done

args = sys.argv[1:]
selftest = args[:1] == ["--selftest"]
if selftest: args = args[1:]
total = 0; fails = []
for f in args:
    lines = open(f).read().splitlines()
    if selftest:
        lines, ok = mutate(lines)
        if not ok: continue
        seen, bad = scan(lines)
        print("CHW selftest %s: %s" % (f, "caught" if bad else "MISSED"))
        sys.exit(0 if bad else 1)
    seen, bad = scan(lines)
    total += seen
    fails += [(f,) + b for b in bad]
if selftest:
    print("CHW selftest: no chwidth in the files given"); sys.exit(1)
for f, seq, mask, live in fails[:10]:
    print("CHW FAIL %s seq %d: chwidth issued to %08x, live lanes %08x" % (f, seq, mask, live))
print("CHW %d chwidth(s) in %d file(s), %d diverged" % (total, len(args), len(fails)))
sys.exit(1 if fails else 0)
