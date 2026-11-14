#!/usr/bin/env python3
"""M1's pred guard path in A (exit table; docs/rcu-exit.md): the depth from
rcu_pred's guard-lead flops (g_gl's rg_hi_cr02h, rg_lo_cr02h) to each flop
they reach, with check-ngd's fanout term and without, on both of check-ngd's
maps. check-ngd prints only a unit's worst; this times from the named flops
with check-ngd's own synthesis and timing. Run from the repo root as
PATH="$PWD/tools/shim:$PATH" python3 test/rcu/guard-ngd.py"""
import importlib.util, sys, os, re, collections
ROOT = os.path.abspath(os.path.join(os.path.dirname(__file__), "..", ".."))
sys.path.insert(0, os.path.join(ROOT, "tools"))
os.chdir(ROOT)
spec = importlib.util.spec_from_file_location("cn", "tools/check-ngd.py")
cn = importlib.util.module_from_spec(spec); spec.loader.exec_module(cn)
u = [x for x in cn.load_units() if x.name == "rcu_pred"][0]
s = u.spec
bbs = s.get("blackbox", {})
work, jf = cn.synth("u_rcu_pred", u.module, s["files"], [bbs[b] for b in sorted(bbs)], s.get("params"), s.get("defines", []))
t = cn.map_and_time(work, jf, bbs.keys(), cn.LIB, s.get("reset"), keep=True)
print("overall rr (flop-flop, fanout term): %.2f ; without: %.2f; area-map rr %.2f, map-r rr %.2f" % (t.rr, t.p_rr, t.rr, t._r.rr))
for label, tm, blif in (("map", t, "map.blif"), ("map -r", t._r, "map_r.blif")):
    ins, outs, latches, gates = cn.parse_blif(os.path.join(work, blif))
    qs = [q for _, q in latches]
    names = collections.defaultdict(list)
    for q in qs: names[cn.base(q)].append(q)
    guard = [q for q in qs if re.match(r"(rg_hi|rg_lo)_cr02h", cn.base(q))]
    arr = tm._prop(guard, fan=True)
    arr_nofan = tm._prop(guard)
    print("\n[%s] guard-lead flops: %d" % (label, len(guard)))
    ends = collections.defaultdict(lambda: [-1, -1])
    for d, q in latches:
        b = cn.base(q)
        a = arr.get(d, cn.NEG); p = arr_nofan.get(d, cn.NEG)
        if a > cn.NEG:
            e = ends[b]; e[0] = max(e[0], a); e[1] = max(e[1], p)
    for b, (a, p) in sorted(ends.items(), key=lambda kv: -kv[1][0]):
        print("  -> %-28s %5.2f (no fanout term %5.2f)" % (b, a, p))
    # all flops' overall worst by end register
    allq = tm._prop(qs, fan=True)
    w = collections.defaultdict(float)
    for d, q in latches:
        w[cn.base(q)] = max(w[cn.base(q)], allq.get(d, 0))
    print("  overall worst by capturing reg:", sorted(w.items(), key=lambda kv:-kv[1])[:6])
