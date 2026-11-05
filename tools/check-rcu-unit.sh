#!/usr/bin/env bash
# The RCU model's unit tests (sim/rcu/run-tests.sh; RI-2, RA-37/38): the
# spec's cycles at the core's decoded interface and the hazards it must
# refuse, each such hazard a negative control inside the harness. Its PASS
# line is held exactly; a run without it, or with a failure, fails here.
set -uo pipefail
cd "$(dirname "$0")/.."
mkdir -p build/rcu
log=build/rcu/rcu-test.log
say() { printf '  %-52s %s\n' "$1" "$2"; }
if sim/rcu/run-tests.sh >"$log" 2>&1 && grep -q "^rcu-test: PASS (0 failures)$" "$log"; then
  say "RCU unit tests" "PASS"
else
  say "RCU unit tests" "FAIL (see $log)"; tail -20 "$log" | sed 's/^/    /'; exit 1
fi
# RI's named controls (RI-8): each must print that it was caught, so one that
# stops firing fails here rather than passing quietly.
missing=""
for c in lane-missing lane-early byp-age3 guard-hazard v60 mig-row-order restore-zero; do
  grep -qx "control $c caught" "$log" || missing="$missing $c"
done
if [ -z "$missing" ]; then
  say "RCU unit-test controls caught" "PASS (7)"
else
  say "RCU unit-test controls caught" "FAIL (not caught:$missing)"; exit 1
fi
