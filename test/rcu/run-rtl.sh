#!/usr/bin/env bash
# RI's RCU RTL benches under Verilator, assertions on (docs/rcu-impl.md,
# section 5, step 2): each module against its reference, at the sizes the
# units use and the FULL_ROW build's both settings. One PASS line each; any
# failure fails the run.
#   rcu_bank_slice: test/rcu/bank_slice_tb.cpp, 32 rows (FULL_ROW 1 and 0)
#   rcu_xbar:       test/rcu/xbar_tb.cpp, 32 lanes
#   rcu_r:          test/rcu/r_tb.cpp, and its negative controls (nofwd,
#                   retlow), each of which must fail
# Usage: test/rcu/run-rtl.sh [--full]   (--full adds the 192-row slice)
set -uo pipefail
cd "$(dirname "$0")/../.."
B=build/rcu-rtl; mkdir -p "$B"
fail=0
say() { printf '  %-52s %s\n' "$1" "$2"; }
bench() {   # name, build command..., then the run's argv after --
  local name=$1; shift
  local build=() run=()
  while [ "$1" != -- ]; do build+=("$1"); shift; done; shift; run=("$@")
  if ! "${build[@]}" >"$B/$name.build.log" 2>&1; then
    say "$name" "FAIL (build; $B/$name.build.log)"; fail=1; return
  fi
  if "${run[@]}" >"$B/$name.log" 2>&1 && grep -q ": PASS$" "$B/$name.log"; then
    say "$name" "PASS ($(grep -o '[0-9]* reads checked\|[0-9]* lanes checked\|[0-9]* values checked' "$B/$name.log" | head -1))"
  else
    say "$name" "FAIL ($B/$name.log)"; tail -5 "$B/$name.log" | sed 's/^/    /'; fail=1
  fi
}
units="rcu_bank_slice_r32 rcu_bank_slice_r32_sec"
[ "${1:-}" = --full ] && units="$units rcu_bank_slice"
for u in $units; do
  bench "$u" test/rcu/cg-build.sh "$u" "$B/$u" -- "$B/$u/tb"
done
bench rcu_xbar verilator --cc --exe --build -j 0 -O2 -Wno-fatal --top-module rcu_xbar --Mdir "$B/xbar" -o tb \
  rtl/rcu/rcu_xbar.sv test/rcu/xbar_tb.cpp -- "$B/xbar/tb"
bench rcu_r test/rcu/cg-build.sh rcu_r "$B/rcu_r" -- "$B/rcu_r/tb"
for c in nofwd retlow; do   # a control the bench does not catch is a failure
  if [ -x "$B/rcu_r/tb" ] && ! "$B/rcu_r/tb" --control "$c" >"$B/rcu_r.$c.log" 2>&1 &&
     grep -q "control $c: .* [1-9][0-9]* mismatches: FAIL$" "$B/rcu_r.$c.log"; then
    say "rcu_r control $c" "caught"
  else
    say "rcu_r control $c" "NOT CAUGHT ($B/rcu_r.$c.log)"; fail=1
  fi
done
exit $fail
