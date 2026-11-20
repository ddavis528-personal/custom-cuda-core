#!/usr/bin/env bash
# The DCU model's unit tests (sim/dcu/run-tests.sh; DI-1). Its PASS line is
# held exactly; a run without it, or with a failure, fails here.
set -uo pipefail
cd "$(dirname "$0")/.."
mkdir -p build/dcu-unit
log=build/dcu-unit/dcu-test.log
say() { printf '  %-52s %s\n' "$1" "$2"; }
if CCV_BUILD=build sim/dcu/run-tests.sh >"$log" 2>&1 && grep -qE '^dcu-test: all passed$' "$log"; then
  say "DCU unit tests" "PASS"
else
  say "DCU unit tests" "FAIL (see $log)"; tail -20 "$log" | sed 's/^/    /'; exit 1
fi
