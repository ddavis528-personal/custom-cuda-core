#!/usr/bin/env python3
"""Critical path from an input port (or every flop: 'FLOPS') to flops or
outputs, on a kept check-ngd unit netlist, with the fanout term.
usage: ngdpath.py <mapped.blif> <start port|FLOPS> [top N ends] [end filter substring]"""
import sys, collections, importlib.util
spec = importlib.util.spec_from_file_location("cn", "/home/user/wt-sw/tools/check-ngd.py")
cn = importlib.util.module_from_spec(spec)
sys.argv_saved = sys.argv
spec.loader.exec_module(cn)
blif, start = sys.argv[1], sys.argv[2]
topn = int(sys.argv[3]) if len(sys.argv) > 3 else 3
filt = sys.argv[4] if len(sys.argv) > 4 else None
ins, outs, latches, gates = cn.parse_blif(blif)
lib = cn.LIB
driver = {o: (g, a) for g, a, o in gates}
loads = collections.Counter(x for _, a, _ in gates for _, x in a)
loads.update(d for d, _ in latches)
loads.update(outs)
inv = cn.delay(lib, "INV", "A")
def fo(n):
    k, c = 0, 4
    while c < loads.get(n, 0):
        c, k = c * 4, k + 1
    return k * inv
order, seen = [], set()
for n0 in driver:
    stack = [(n0, False)]
    while stack:
        x, done = stack.pop()
        if done:
            order.append(x); continue
        if x in seen or x not in driver: continue
        seen.add(x); stack.append((x, True))
        stack.extend((a, False) for _, a in driver[x][1] if a not in seen)
if start == "FLOPS":
    st = [q for _, q in latches]
else:
    st = [i for i in ins if cn.base(i) == start]
arr = {x: fo(x) for x in st}
pred = {}
for n in order:
    g, a = driver[n]
    if g in ("ZERO", "ONE"): continue
    best, bp = cn.NEG, None
    for pin, x in a:
        if x in arr:
            t = arr[x] + (0.0 if g == "BUF" else cn.delay(lib, g, pin))
            if t > best: best, bp = t, x
    if bp is not None:
        arr[n] = best + fo(n); pred[n] = (bp, g)
d2q = {d: q for d, q in latches}
ends = [(arr[d], "flop " + d2q[d], d) for d, _ in latches if d in arr]
ends += [(arr[o], "out " + o, o) for o in outs if o in arr]
if filt: ends = [e for e in ends if filt in e[1]]
ends.sort(reverse=True)
for t, name, n in ends[:topn]:
    print(f"== {t:.1f} to {name}")
    chain = []
    while n in pred:
        p, g = pred[n]
        chain.append(f"  {arr[n]:5.1f} {g:8s} {n} (loads {loads.get(n,0)})")
        n = p
    chain.append(f"  {arr.get(n,0):5.1f} start   {n} (loads {loads.get(n,0)})")
    print("\n".join(reversed(chain)))
