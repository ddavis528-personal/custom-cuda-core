#!/usr/bin/env bash
# The MIU model's unit tests (sim/miu/run-tests.sh; MI-1). Its PASS line is
# held exactly; a run without it, or with a failure, fails here.
set -uo pipefail
cd "$(dirname "$0")/.."
mkdir -p build/miu-unit
log=build/miu-unit/miu-test.log
say() { printf '  %-52s %s\n' "$1" "$2"; }
if CCV_BUILD=build sim/miu/run-tests.sh >"$log" 2>&1 && grep -qE '^miu unit: [0-9]+ checks, 0 failed$' "$log"; then
  say "MIU unit tests" "PASS"
else
  say "MIU unit tests" "FAIL (see $log)"; tail -20 "$log" | sed 's/^/    /'; exit 1
fi
