#!/usr/bin/env python3
"""tools/genlib-xor.py <sky130_fd_sc_hd__tt_025C_1v80.lib>: the GATE lines of
tools/ngd.genlib's XOR family (Daniel, 2026-10-24). Not run by the gate,
which has no network: the .lib is the open PDK's, as OpenROAD-flow-scripts
carries it (flow/platforms/sky130hd/lib/).

GATE lines for sky130hd's XOR family, each pin's delay over NAND2_1's, both
at fanout 4 (four times the cell's mean input capacitance) and at the input
slew a NAND2_1 makes at fanout 4 (iterated to a fixed point)."""
import re, sys, bisect
txt = open(sys.argv[1]).read()
def block(s, start):
    i = s.index("{", start); d = 0
    for j in range(i, len(s)):
        d += s[j] == "{"; d -= s[j] == "}"
        if d == 0: return s[i+1:j]
def cell(n): return block(txt, txt.index('cell ("sky130_fd_sc_hd__%s")' % n))
def nums(s): return [float(x) for x in re.findall(r"[-0-9.eE+]+", s)]
def table(g):
    i1 = nums(re.search(r'index_1\s*\(\s*"([^"]*)"', g).group(1)); i2 = nums(re.search(r'index_2\s*\(\s*"([^"]*)"', g).group(1))
    v = [nums(r) for r in re.findall(r'"([^"]*)"', re.search(r'values\s*\((.*?)\)\s*;', g, re.S).group(1))]
    return i1, i2, v
def interp(t, x, y):
    i1, i2, v = t
    def seg(a, z):
        k = min(max(bisect.bisect_left(a, z), 1), len(a) - 1); return k - 1, k
    a0, a1 = seg(i1, x); b0, b1 = seg(i2, y)
    fx = (x - i1[a0]) / (i1[a1] - i1[a0]); fy = (y - i2[b0]) / (i2[b1] - i2[b0])
    return (1-fx)*(1-fy)*v[a0][b0] + fx*(1-fy)*v[a1][b0] + (1-fx)*fy*v[a0][b1] + fx*fy*v[a1][b1]
def arcs(n, slew, kinds=("cell_rise", "cell_fall")):
    c = cell(n); ps = {m.group(1): block(c, m.start()) for m in re.finditer(r'pin\s*\("(\w+)"\)', c)}
    cap = {p: float(re.search(r"\bcapacitance\s*:\s*([0-9.]+)", b).group(1)) for p, b in ps.items() if re.search(r'direction\s*:\s*"?input', b)}
    load = 4 * sum(cap.values()) / len(cap); out = {}
    for p, b in ps.items():
        for m in re.finditer(r"timing\s*\(\s*\)", b):
            g = block(b, m.start()); rp = re.search(r'related_pin\s*:\s*"(\w+)"', g).group(1)
            for k in kinds:
                mm = re.search(k + r"\s*\(\s*\"?\w*\"?\s*\)", g)
                if mm: out[rp] = max(out.get(rp, 0.0), interp(table(block(g, mm.start())), slew, load))
    return out
s = 0.1
for _ in range(20):
    s = max(arcs("nand2_1", s, ("rise_transition", "fall_transition")).values())
ref = max(arcs("nand2_1", s).values())
print("# slew %.4f ns, NAND2_1 %.4f ns" % (s, ref), file=sys.stderr)
cells = [("XOR2", "xor2_1", 10, "Y=A*!B+!A*B;", "AB"), ("XNOR2", "xnor2_1", 10, "Y=A*B+!A*!B;", "AB"),
         ("XOR3", "xor3_1", 22, "Y=A*!B*!C+!A*B*!C+!A*!B*C+A*B*C;", "ABC"),
         ("XNOR3", "xnor3_1", 22, "Y=!(A*!B*!C+!A*B*!C+!A*!B*C+A*B*C);", "ABC")]
for g, c, area, f, pins in cells:
    a = arcs(c, s)
    print("GATE %-6s %2d %s" % (g, area, f))
    for p in pins:
        d = a[p] / ref
        print("  PIN %s UNKNOWN 1 999 %.2f 0 %.2f 0" % (p, d, d))
