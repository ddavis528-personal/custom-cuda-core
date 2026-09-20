#!/usr/bin/env python3
"""Re-measure the tool matrix and report ANY cell that changed.

The Stage 1 conclusions are measurements of third-party tools, and several
decisions exist *because* of a limitation. A limitation that lifts silently
leaves the workaround in the flow and the reasoning behind it wrong -- so a
cell going FAIL -> PASS is reported as loudly as the reverse, and is the one
far easier to miss.

Slow (minutes), so this is a CI job rather than part of the local gate. The
local gate checks the RECORDED matrix for internal consistency
(tools/check-1a.sh) and the pinned tool versions (tools/check-toolchain.sh);
between them a drifting tool is caught in seconds, and this establishes what
actually changed.

    tools/check-matrix-drift.py           re-measure, diff, non-zero on change
    tools/check-matrix-drift.py --accept  re-measure and adopt the new results
"""
import json
import os
import subprocess
import sys

ROOT = os.path.dirname(os.path.dirname(os.path.abspath(__file__)))
GOLD = os.path.join(ROOT, "test", "golden", "stage1a-matrix.json")
TOOLS = ("iverilog", "verilator", "sby")


def load(path):
    with open(path) as f:
        return json.load(f)


def cells(m):
    out = {}
    for c in m["cases"]:
        for t in TOOLS:
            out[(c["file"], t)] = c["cells"].get(t, {}).get("verdict", "?")
    return out


def main():
    accept = "--accept" in sys.argv
    if not os.path.exists(GOLD):
        sys.exit("no recorded matrix at %s" % os.path.relpath(GOLD, ROOT))
    before = load(GOLD)

    print("  re-measuring (this takes a few minutes)...", flush=True)
    r = subprocess.run([sys.executable, os.path.join(ROOT, "tools",
                                                     "run-spike-1a.py")],
                       cwd=ROOT, capture_output=True, text=True)
    if r.returncode != 0:
        sys.stderr.write(r.stdout + r.stderr)
        sys.exit("the spike runner failed; nothing was compared")
    after = load(GOLD)

    a, b = cells(before), cells(after)
    changed = sorted(k for k in set(a) | set(b) if a.get(k) != b.get(k))

    vb = {k: v for k, v in before.get("tools", {}).items()}
    va = {k: v for k, v in after.get("tools", {}).items()}
    vdrift = sorted(k for k in set(vb) | set(va) if vb.get(k) != va.get(k))

    if not changed and not vdrift:
        print("  matrix unchanged: %d cells across %d cases"
              % (len(b), len(after["cases"])))
        return 0

    for t in vdrift:
        print("  TOOL VERSION CHANGED: %s\n      was %s\n      now %s"
              % (t, vb.get(t, "-"), va.get(t, "-")))

    # A limitation lifting is the easy-to-miss direction, so it is named
    # rather than lumped in with regressions.
    GOOD = {"CHECK", "COVER-HIT", "PROVE-PASS", "PARSE-OK", "SILENCED", "N/A"}
    for key in changed:
        case, tool = key
        was, now = a.get(key, "-"), b.get(key, "-")
        lifted = was not in GOOD and now in GOOD
        tag = "LIMITATION LIFTED" if lifted else "CHANGED"
        print("  %-18s %s / %s : %s -> %s" % (tag, case, tool, was, now))

    print()
    print("  A changed cell is a FINDING, not a build break. Several Stage 1")
    print("  decisions exist because of a limitation; one that lifted leaves")
    print("  the workaround in place and its reasoning wrong. Read")
    print("  docs/stage1a-findings.md against the change before accepting it.")
    if accept:
        print("\n  --accept given: the new matrix is now the recorded one.")
        return 0
    # Restore, so a CI run leaves nothing half-updated behind.
    with open(GOLD, "w") as f:
        json.dump(before, f, indent=2, sort_keys=True)
    print("\n  recorded matrix restored; rerun with --accept to adopt.")
    return 1


if __name__ == "__main__":
    sys.exit(main())
