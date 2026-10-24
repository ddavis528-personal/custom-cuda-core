#!/usr/bin/env python3
"""CoreMark-derived's width changes, classed (TI-45, AR's rev 175):
every register-width setting in exactly one class, and every chwidth
instruction classed by its worst setting.

A lifetime is a register's stretch at one narrow width, from the setting
that starts it to the next setting that changes the width (a no-op setting
neither ends nor starts one). It is "mem" if the register is used only as
the data of narrow loads and stores (or unused), "bitwise" if only that and
bitwise ops, else "needs". A changed setting ends the lifetime before it and
starts the one after (either may be 32 bits, which constrains nothing); its
class is the worse of the two. An instruction's class is its worst
setting's, so it goes only when every setting it makes goes.

Usage: tools/chwidth-classes.py <one-lane oracle.jsonl>. Not part of the
gate; re-run on CP's export after step 0 (AR's rev 175, IS-23)."""
import json, sys, collections
W = {0: 32, 1: 16, 2: 8, 3: 4}
BITWISE = {"AND", "OR", "XOR", "C_AND", "C_OR", "C_XOR", "ANDI", "C_ANDI", "ANDN", "C_ANDN"}
width = [32] * 16
life = {}                 # reg -> {"kinds": set, "waiters": [settings that touch it]}
settings = []             # each: {"cls": rank so far, "instr": index}
instrs = []               # per chwidth instruction: list of setting indices
total = 0
def lclass(k):
    if k <= {"mem"}: return 1
    if k <= BITWISE | {"mem"}: return 2
    return 3
def close(r):
    L = life.pop(r, None)
    if L is None: return
    c = lclass(L["kinds"])
    for s in L["waiters"]: settings[s] = max(settings[s], c)
for line in open(sys.argv[1]):
    j = json.loads(line)
    if "op" not in j: continue
    total += 1
    op = j["op"]
    if op in ("C_CHWIDTH", "CHWIDTH_MULTI"):
        if op == "C_CHWIDTH":
            regs = [int((j["defs"][0] if j["defs"] else j["uses"][0])["reg"][1:])]; w = W[j["imms"][0] & 3]
        else:
            regs = [g for g in range(16) if j["imms"][0] >> g & 1]; w = W[j["imms"][1] & 3]
        mine = []
        for r in regs:
            s = len(settings); mine.append(s)
            if width[r] == w: settings.append(0); continue
            settings.append(1)                       # a change costs at least "mem"
            if r in life: life[r]["waiters"].append(s); close(r)
            width[r] = w
            if w < 32: life[r] = {"kinds": set(), "waiters": [s]}
        instrs.append(mine)
        continue
    data = None
    if j["mem"]:
        if j["load"] and j["defs"]: data = j["defs"][0]["reg"]
        elif j["store"]:
            g = [u["reg"] for u in j["uses"] if u["reg"][0] == "R"]; data = g[0] if g else None
    for u in j["uses"] + j["defs"]:
        if u["reg"][0] != "R": continue
        r = int(u["reg"][1:])
        if r in life: life[r]["kinds"].add("mem" if u["reg"] == data else op)
for r in list(life): close(r)
names = ["noop", "mem", "bitwise", "needs"]
sc = collections.Counter(settings)
ic = collections.Counter(max((settings[s] for s in m), default=0) for m in instrs)
multi = sum(len(m) > 1 for m in instrs)
print("instructions %d, chwidth instructions %d (multi %d), settings %d" % (total, len(instrs), multi, len(settings)))
print("%-8s %9s %7s %9s %7s %7s" % ("class", "settings", "%set", "instrs", "%chw", "%kern"))
cs = ci = 0
for k in range(4):
    cs += sc[k]; ci += ic[k]
    print("%-8s %9d %6.1f%% %9d %6.1f%% %6.2f%%   cumulative: %d settings %.1f%%, %d instrs %.1f%% of chw, %.2f%% of kernel" % (
        names[k], sc[k], 100*sc[k]/len(settings), ic[k], 100*ic[k]/len(instrs), 100*ic[k]/total,
        cs, 100*cs/len(settings), ci, 100*ci/len(instrs), 100*ci/total))
