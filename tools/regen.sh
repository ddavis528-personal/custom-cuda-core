#!/usr/bin/env bash
# Every generated file, rewritten, before the gate (DA, 2026-10-23).
#
# The gate refuses a generated file that differs from a fresh build, and the
# walkthrough can be checked only at its end, from the skeleton, kernel and
# SV-hosted builds: a stale one cost a whole gate. This runs every generator,
# builds what the walkthrough runs (the skeleton, vadd's oracle, the SV-hosted
# binary) and rewrites docs/walkthrough.md, in a few minutes. Commit what it
# changes, then run tools/verify.sh. It checks nothing itself: the gate does.
set -uo pipefail
cd "$(dirname "$0")/.."
step() { printf '  %-40s' "$1"; shift; if "$@" >build/regen.log 2>&1; then echo ok; else echo "FAILED (build/regen.log)"; exit 1; fi; }
mkdir -p build
step "event schema"   python3 tools/gen-event-schema.py
step "parameters"     python3 tools/gen-params.py
step "interfaces"     python3 tools/gen-interfaces.py
step "payload spec"   python3 tools/gen-payload-spec.py
step "trust report"   python3 tools/gen-trust-report.py
step "skel wiring"    python3 tools/gen-skel.py
step "SV top"         python3 tools/gen-top.py
step "skeleton build" tools/check-skel.sh
step "oracles"        tools/gen-oracle.sh
step "SV-hosted build" tools/check-sv-hosted.sh --build-only
step "walkthrough"    python3 tools/gen-walkthrough.py
echo "  changed:"
git status --short -- sim/generated rtl/generated rtl/top docs/payload-spec.md \
  docs/trust-report.md docs/walkthrough.md | sed 's/^/    /'
