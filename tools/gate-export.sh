#!/usr/bin/env bash
# Pack a gate run's record for the container that pushes (OI-101; DA,
# 2026-11-01): build/verify (every section's log and manifest.json, which
# names the commit and its tree) and, with --cache, build/synth-cache, whose
# entries are keyed by content and merge into any other cache.
#
#   tools/gate-export.sh <out.tgz> [--cache | --cache-only]
#
# The pushing side passes it to tools/gate-push.sh --import=<out.tgz>, which
# accepts its sections only for the identical commit and tree (gate-combine.py).
set -uo pipefail
cd "$(dirname "$0")/.."
[ $# -ge 1 ] || { echo "usage: $0 <out.tgz> [--cache]" >&2; exit 2; }
out=$1; shift
case "${1:-}" in
  --cache-only)
    [ -d build/synth-cache ] || { echo "gate-export: no build/synth-cache" >&2; exit 1; }
    tar -czf "$out" --exclude='*.lock' build/synth-cache || exit 1
    echo "gate-export: $out: build/synth-cache only ($(ls build/synth-cache | grep -vc '\.lock$') entries)"
    exit 0 ;;
esac
dirs=(build/verify)
[ "${1:-}" = --cache ] && [ -d build/synth-cache ] && dirs+=(build/synth-cache)
[ -f build/verify/manifest.json ] || { echo "gate-export: no build/verify/manifest.json: run tools/verify.sh first" >&2; exit 1; }
tar -czf "$out" --exclude='*.lock' "${dirs[@]}" || exit 1
python3 - "$out" <<'PY'
import json, sys, tarfile
m = json.load(tarfile.open(sys.argv[1]).extractfile("build/verify/manifest.json"))
ran = [j for j, v in m["sections"].items() if v["outcome"] in ("pass", "fail")]
print("gate-export: %s: %s at %s, ran %s" % (sys.argv[1], m["commit"][:7], m["tree"][:7], " ".join(ran) or "nothing"))
PY
