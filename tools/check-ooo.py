#!/usr/bin/env python3
"""How out of order the kernels run, measured from their event traces.

A kernel that never makes a younger instruction issue ahead of an older one
of its warp runs the OOE as an in-order machine, and passes whatever the
reordering logic does. So every kernel's trace is measured, over the
instructions that retire (a wrong path's issues say nothing about order):

  ahead    instructions that issued before some older instruction of their
           warp had issued: the reorderings
  depth    the most older instructions of its warp still unissued when one
           issued: how far the window reached
  dual     cycles in which two or more of one warp's instructions issued
  fin      each warp's last retirement, the cycle it finished (by warp_id)

An instruction's issue is its first EV_ISSUE; a re-execution (an L1
cancel's replay) is the same instruction issued again, not a new one.

  tools/check-ooo.py TRACE...                  one line per trace
  tools/check-ooo.py --floor SPEC TRACE...     and the suite's floor:
        SPEC is "ahead=N,depth=M,kernels=K": the suite's ahead summed at
        least N, some kernel's depth at least M, at least K kernels with
        a reordering at all
  tools/check-ooo.py --want K:BINS TRACE...    a kernel's own bounds, as
        check-kernel's bins: "ahead>3 depth>2" (repeatable)
  tools/check-ooo.py --stalled K:W:GAP TRACE... in kernel K, warp W is the
        stalled one, and every other warp must finish at least GAP cycles
        before it: they filled its hole rather than waiting it out
  --in-order   measure each trace with its issues held in program order (no
               instruction before its warp's previous one): the negative
               control, what an in-order machine would at best have done.
               Its ahead and depth must read 0, and the floor must fail.

Exit 1 if a floor or a bound is not met, 2 on a bad trace.
"""
import argparse
import collections
import importlib.util
import os
import sys

ROOT = os.path.dirname(os.path.dirname(os.path.abspath(__file__)))
_spec = importlib.util.spec_from_file_location(
    "trace2perfetto", os.path.join(ROOT, "tools", "trace2perfetto.py"))
t2p = importlib.util.module_from_spec(_spec)
_spec.loader.exec_module(t2p)


def event_ids():
    ids = {e["name"]: e["id"] for e in t2p.load_schema()["events"]}
    return ids["EV_ISSUE"], ids["EV_RETIRE"]


def measure(path, in_order=False):
    """{warps, instrs, ahead, depth, dual} for one trace."""
    issue_id, retire_id = event_ids()
    _, recs = t2p.read_trace(path)
    first, retired, fin = {}, set(), {}
    for cyc, uid, eid, _unit, a, _b, _c in recs:
        key = (a, uid & 0xffffffff)          # (warp_id, the fetch seq)
        if eid == issue_id:
            first.setdefault(key, cyc)
        elif eid == retire_id:
            retired.add(key)
            fin[a] = max(fin.get(a, 0), cyc)
    warps = collections.defaultdict(list)
    for key, cyc in first.items():
        if key in retired:
            warps[key[0]].append((key[1], cyc))
    out = {"warps": len(warps), "instrs": 0, "ahead": 0, "depth": 0, "dual": 0,
           "fin": [fin[w] for w in sorted(fin)]}
    for lst in warps.values():
        lst.sort()                                   # program order
        cycs = [c for _, c in lst]
        if in_order:
            for i in range(1, len(cycs)):
                cycs[i] = max(cycs[i], cycs[i - 1])
        out["instrs"] += len(cycs)
        for i, c in enumerate(cycs):
            older = sum(1 for j in range(i) if cycs[j] > c)
            if older:
                out["ahead"] += 1
                out["depth"] = max(out["depth"], older)
        out["dual"] += sum(1 for n in collections.Counter(cycs).values() if n > 1)
    return out


def name_of(path):
    """The kernel's name: the trace's file name less any ooo_ or kernel_."""
    n = os.path.basename(path).split(".")[0]
    for p in ("ooo_", "kernel_"):
        if n.startswith(p):
            n = n[len(p):]
    return n


def bounds_fail(m, bins):
    """check-kernel's bin grammar: name=N exact, name>N above N."""
    why = []
    for w in bins.split():
        if ">" in w:
            k, v = w.split(">", 1)
            if not m[k] > int(v):
                why.append("%s=%d (want >%s)" % (k, m[k], v))
        else:
            k, v = w.split("=", 1)
            if m[k] != int(v):
                why.append("%s=%d (want %s)" % (k, m[k], v))
    return why


def main():
    ap = argparse.ArgumentParser()
    ap.add_argument("traces", nargs="+")
    ap.add_argument("--floor")
    ap.add_argument("--want", action="append", default=[])
    ap.add_argument("--stalled", action="append", default=[])
    ap.add_argument("--in-order", action="store_true")
    a = ap.parse_args()
    ms = {}
    for p in a.traces:
        ms[name_of(p)] = m = measure(p, a.in_order)
        print("OOO %-12s warps=%d instrs=%d ahead=%d depth=%d dual=%d fin=%s"
              % (name_of(p), m["warps"], m["instrs"], m["ahead"], m["depth"], m["dual"],
                 ",".join(str(f) for f in m["fin"])))
    fails = []
    for w in a.want:
        k, bins = w.split(":", 1)
        if k not in ms:
            fails.append("%s: no trace" % k)
            continue
        fails += ["%s: %s" % (k, x) for x in bounds_fail(ms[k], bins)]
    for st in a.stalled:
        k, w, gap = st.split(":")
        w, gap = int(w), int(gap)
        fin = ms.get(k, {}).get("fin", [])
        if w >= len(fin):
            fails.append("%s: no warp %d retired" % (k, w))
            continue
        late = [(o, f) for o, f in enumerate(fin) if o != w and f > fin[w] - gap]
        for o, f in late:
            fails.append("%s: warp %d finished at %d, within %d of stalled warp %d's %d"
                         % (k, o, f, gap, w, fin[w]))
    if a.floor:
        f = dict(kv.split("=") for kv in a.floor.split(","))
        ahead = sum(m["ahead"] for m in ms.values())
        depth = max(m["depth"] for m in ms.values())
        kernels = sum(1 for m in ms.values() if m["ahead"])
        print("OOO suite ahead=%d depth=%d kernels=%d of %d" % (ahead, depth, kernels, len(ms)))
        for k, have in (("ahead", ahead), ("depth", depth), ("kernels", kernels)):
            if k in f and have < int(f[k]):
                fails.append("suite %s=%d, below its floor %s" % (k, have, f[k]))
    for x in fails:
        print("OOO FAIL %s" % x)
    return 1 if fails else 0


if __name__ == "__main__":
    sys.exit(main())
