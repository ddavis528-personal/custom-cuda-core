#!/usr/bin/env python3
"""CoreMark-derived's width changes, classed (TI-45, AR's rev 175):
every register-width setting in exactly one class, and every chwidth
instruction classed by its worst setting.

A lifetime is a register's stretch at one narrow width, from the setting
that starts it to the next setting that changes the width (a no-op setting
neither ends nor starts one). Its uses class it: "unused"; "mem", only as
the data of narrow loads and stores; "bw", only bitwise ops, with no narrow
access (the compiler's F-196 keeps these at 32 bits); "bwmem", bitwise ops
and narrow accesses; else "needs". A changed setting ends the lifetime
before it and starts the one after (a 32-bit side constrains nothing) and
carries both their classes; a no-op setting carries none. A chwidth
instruction goes under a remedy only when every setting it makes does, so a
chwidth.multi is counted once, by instruction (AR's rev 175).

Usage: tools/chwidth-classes.py <one-lane oracle.jsonl>. Not part of the
gate; re-run on CP's export after step 0 (AR's rev 175, IS-23)."""
import json, sys, collections
W = {0: 32, 1: 16, 2: 8, 3: 4}
BITWISE = {"AND", "OR", "XOR", "C_AND", "C_OR", "C_XOR", "ANDI", "C_ANDI", "ANDN", "C_ANDN"}
width = [32] * 16
life = {}                 # reg -> {"kinds": set, "waiters": [settings that touch it]}
settings = []             # per setting: the set of its lifetimes' classes
instrs = []               # per chwidth instruction: its setting indices
total = 0
def lclass(k):
    if not k: return "unused"
    if k <= {"mem"}: return "mem"
    if k <= BITWISE: return "bw"
    if k <= BITWISE | {"mem"}: return "bwmem"
    return "needs"
def close(r):
    L = life.pop(r, None)
    if L is None: return
    c = lclass(L["kinds"])
    for s in L["waiters"]: settings[s].add(c)
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
            settings.append(set())
            if width[r] == w: continue
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
ORDER = ["noop", "unused", "mem", "bw", "bwmem", "needs"]
def shown(cs):          # one class per setting, for the table: the remedy it needs most
    if not cs: return "noop"
    if "needs" in cs: return "needs"
    if "bwmem" in cs or {"mem", "bw"} <= cs: return "bwmem"
    for c in ("bw", "mem", "unused"):
        if c in cs: return c
multi = sum(len(m) > 1 for m in instrs)
print("instructions %d, chwidth instructions %d (multi %d), settings %d" % (total, len(instrs), multi, len(settings)))
sc = collections.Counter(shown(c) for c in settings)
ic = collections.Counter(shown(set().union(*(settings[s] for s in m))) for m in instrs)
print("%-7s %9s %7s %9s %7s %7s" % ("class", "settings", "%set", "instrs", "%chw", "%kern"))
for k in ORDER:
    print("%-7s %9d %6.1f%% %9d %6.1f%% %6.2f%%" % (k, sc[k], 100*sc[k]/len(settings), ic[k],
          100*ic[k]/len(instrs), 100*ic[k]/total))
REMEDIES = [("no-op widths dropped (step 0)", set()),
            ("+ unused narrowings", {"unused"}),
            ("+ F-196, bitwise at 32 bits", {"unused", "bw"}),
            ("+ option A, sized loads and stores", {"unused", "mem"}),
            ("+ F-196 and option A", {"unused", "bw", "mem"}),
            ("+ F-196 and option A, bitwise ending in an access", {"unused", "bw", "mem", "bwmem"})]
print("removed, by instruction:")
for name, ok in REMEDIES:
    n = sum(all(settings[s] <= ok for s in m) for m in instrs)
    print("  %-52s %7d  %5.1f%% of chw  %5.2f%% of kernel" % (name, n, 100*n/len(instrs), 100*n/total))
