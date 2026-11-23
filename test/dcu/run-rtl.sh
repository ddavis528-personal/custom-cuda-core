#!/usr/bin/env bash
# DI's DCU RTL benches under Verilator, assertions on (docs/dcu-impl.md; MA's
# Phase 2 slice 1, DCU tab rev 82): each module against its value model, at
# the sizes its units use. One PASS line each; any failure fails the run.
#   dcu_cap: test/dcu/cap_tb.cpp, one request slot's capture, and its control
#            early (the payload taken with its valid), which must fail
#   dcu_btag: test/dcu/btag_tb.cpp, one bank's tag RFs and compare, and its
#            controls highest (the highest slot picked) and wbr (a same-edge
#            write seen by the read), which must fail
#   dcu_bctl: test/dcu/bctl_tb.cpp, one bank's controller (fold compare,
#            grants, wait queue, aging, fix, PLRU, entry returns), and its
#            controls flat (the model puts a new lookup ahead of the re-read)
#            and nofree (a dropped access keeps its entry), which must fail
#   dcu_mshr: test/dcu/mshr_tb.cpp, the miss buffers (merge, allocate, wait,
#            bank order, the request to MLC, a fill's entry read), and its
#            controls nomerge (dcu-mshr-nomerge), order (dcu-miss-reorder), credit and retry,
#            which must fail
set -uo pipefail
cd "$(dirname "$0")/../.."
B=build/dcu-rtl; mkdir -p "$B"
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
    say "$name" "PASS ($(grep -o '[0-9]* values checked' "$B/$name.log" | head -1))"
  else
    say "$name" "FAIL ($B/$name.log)"; tail -5 "$B/$name.log" | sed 's/^/    /'; fail=1
  fi
}
control() {   # unit, control: the bench must fail with mismatches
  local u=$1 c=$2
  if [ -x "$B/$u/tb" ] && ! "$B/$u/tb" --control "$c" >"$B/$u.$c.log" 2>&1 &&
     grep -q "control $c: .* [1-9][0-9]* mismatches: FAIL$" "$B/$u.$c.log"; then
    say "$u control $c" "caught"
  else
    say "$u control $c" "NOT CAUGHT ($B/$u.$c.log)"; fail=1
  fi
}
bench dcu_cap test/dcu/cg-build.sh dcu_cap "$B/dcu_cap" -- "$B/dcu_cap/tb"
control dcu_cap early
bench dcu_btag test/dcu/cg-build.sh dcu_btag "$B/dcu_btag" -- "$B/dcu_btag/tb"
control dcu_btag highest
control dcu_btag wbr
for seed in 1 2 3; do
  bench "dcu_bctl seed $seed" test/dcu/cg-build.sh dcu_bctl "$B/dcu_bctl" -- "$B/dcu_bctl/tb" --seed $seed
done
control dcu_bctl flat
control dcu_bctl nofree
for seed in 1 2 3; do
  bench "dcu_mshr seed $seed" test/dcu/cg-build.sh dcu_mshr "$B/dcu_mshr" -- "$B/dcu_mshr/tb" --seed $seed
done
control dcu_mshr nomerge
control dcu_mshr order
control dcu_mshr credit
control dcu_mshr retry
exit $fail
