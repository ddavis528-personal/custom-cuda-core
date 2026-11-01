#!/usr/bin/env python3
"""The gate's result in a few lines, from tools/verify.sh's log.

    tools/gate-summary.py [verify.log] [--tail N] [--scoped]

Prints the result, every section's time, and for each failing claim its line
plus the last N lines (default 8) of any log it names in parentheses. A
session reads this instead of the log itself, which runs to ~1,000 lines.
Exit status: 0 for PASS, 1 for FAIL, 2 when the log has no result (the gate
did not finish). With --scoped, a SCOPED PASS (verify.sh --changed) is 0
too; without it, it is 1: only a push to a working branch takes one.
"""
import re
import sys
from pathlib import Path

args = sys.argv[1:]
tail = 8
scoped = "--scoped" in args
if scoped:
    args.remove("--scoped")
if "--tail" in args:
    i = args.index("--tail")
    tail = int(args[i + 1])
    del args[i:i + 2]
log = Path(args[0] if args else "build/verify.log")
lines = log.read_text(errors="replace").splitlines()

result = None
for i, l in enumerate(lines):
    if l.strip() == "== result ==" and i + 1 < len(lines):
        result = lines[i + 1].strip()
times = re.findall(r"^\s*\[([\w-]+): (\d+)s\]", "\n".join(lines), re.M)
fails = [l for l in lines
         if re.search(r"\sFAIL\b", l) and "== result ==" not in l and l.strip() != "FAIL"]
failed_jobs = [l.strip() for l in lines if re.match(r"\s*-> .* FAILED$", l)]

print(f"gate: {result or 'NO RESULT (did not finish)'}  ({log})")
if times:
    tot = sorted(times, key=lambda t: -int(t[1]))
    print("  slowest: " + ", ".join(f"{n} {s}s" for n, s in tot[:6]))
for l in failed_jobs:
    print("  " + l)
for l in fails:
    print("  " + l.strip())
    for ref in re.findall(r"\(([^()\s]+\.log)\)", l):
        p = Path(ref)
        if p.is_file():
            body = p.read_text(errors="replace").splitlines()[-tail:]
            print(f"    -- last {len(body)} lines of {ref}:")
            for b in body:
                print("       " + b[:200])
if result is None:
    print("  last lines:")
    for l in lines[-tail:]:
        print("    " + l[:200])
ok = result == "PASS" or (scoped and (result or "").startswith("SCOPED PASS"))
sys.exit(0 if ok else 1 if result else 2)
