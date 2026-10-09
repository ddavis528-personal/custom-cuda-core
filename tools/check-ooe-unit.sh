#!/usr/bin/env bash
# The OOE model's unit tests (sim/ooe/run-tests.sh): squash, deferred free,
# L1 cancel and replay, bypass groups, predicate renaming, several warps,
# demotion, kill, restore, faults and barriers -- the paths no S1 kernel
# reaches yet. The harness carries its own negative controls, each an
# injected bug that must fail it; a missed control fails the run. This
# check also holds the set of controls by name, so one dropped from the
# harness fails here rather than passing unnoticed.
set -uo pipefail
cd "$(dirname "$0")/.."
mkdir -p build/ooe
log=build/ooe/ooe-test.log
say() { printf '  %-52s %s\n' "$1" "$2"; }
fail=0

if sim/ooe/run-tests.sh >"$log" 2>&1 && grep -q "^ooe-test: PASS (0 failures)" "$log"; then
  say "OOE unit tests" "PASS"
else
  say "OOE unit tests" "FAIL (see $log)"; tail -20 "$log" | sed 's/^/    /'; fail=1
fi

for c in free-new shallow-cancel early-wake cmpl-wake-delay-ignored \
         bypass-faster-than-contract complete-before-rs-free narrow-footprint; do
  if grep -q "^  control $c  *caught$" "$log"; then
    say "control $c" "caught"
  else
    say "control $c" "MISSING OR MISSED"; fail=1
  fi
done
n=$(grep -c "^  control " "$log")
if [ "$n" != 7 ]; then
  say "control count" "$n, want 7 (add a new one to this list)"; fail=1
fi
exit $fail
