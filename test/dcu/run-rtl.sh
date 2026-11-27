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
#            controls flat (the model puts a new lookup ahead of the re-read),
#            order (a miss presented past its bank's waiter)
#            and nofree (a dropped access keeps its entry), which must fail
#   dcu_mshr: test/dcu/mshr_tb.cpp, one bank's miss buffers (merge, allocate,
#            wait, bank order, the MLC offers and their payload, a fill's
#            entry read, other banks' fills and frees), built at banks 0 and
#            5 (MA-34), and its controls nomerge (dcu-mshr-nomerge), order
#            (dcu-miss-reorder) and early (a miss offered at its own D2, not
#            a cycle on: DI-66), which must fail, and twolook (two live lookups to
#            the bank, MIU's pass-wins-bank), which must fail mshr_one_lookup
#   dcu_mpick: test/dcu/mpick_tb.cpp, the cross-bank picks (the retry grant
#            and its D2 port, the MLC send, its credits and payload), and its
#            controls retry (the lowest offering bank granted), age (the
#            lowest bank's head sent), pass (last cycle's bank not passed
#            over) and credit (last cycle's send not counted), which must fail
#   dcu_fill: test/dcu/fill_tb.cpp, the fill buffers (capture, encode, the
#            write request, answers owed, the free's credit and entry), and its
#            controls nowait (freed with answers owed) and highest (the
#            highest free buffer taken), which must fail
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
for seed in 1 2; do
  bench "dcu_bctl flood seed $seed" true -- "$B/dcu_bctl/tb" --seed $seed --flood
done
control dcu_bctl flat
control dcu_bctl nofree
control dcu_bctl order
control dcu_bctl unheld
control dcu_bctl nomargin
# A control build or option the bench must fail with an assertion's name.
asserts() {   # name, unit, assertion, bench options...
  local n=$1 u=$2 a=$3; shift 3
  if test/dcu/cg-build.sh "$u" "$B/$u" >"$B/$u.build.log" 2>&1 &&
     ! "$B/$u/tb" "$@" >"$B/$u.$n.log" 2>&1 &&
     grep -q "$a failed" "$B/$u.$n.log"; then
    say "$u control $n" "caught"
  else
    say "$u control $n" "NOT CAUGHT ($B/$u.$n.log)"; fail=1
  fi
}
# The reservation held through W (DI-43): released at the grant instead, two
# fills take one way.
asserts rel_at_grant dcu_bctl_rel bctl_one_fill_per_way --seed 1
# The fold table's port (DI-46): its head written over a fill's write; a held
# fill that yields every time (starved under a flood of port writes); a
# credit the queue has no entry for.
asserts port_nowait dcu_bctl_pnw bctl_ft_one_writer --seed 1
asserts always_yield dcu_bctl_ayl bctl_fill_held_wait --seed 1 --flood
asserts credit_plus dcu_bctl bctl_port_overflow --seed 1 --flood --control credit_plus
for seed in 1 2 3; do
  bench "dcu_mshr seed $seed" test/dcu/cg-build.sh dcu_mshr "$B/dcu_mshr" -- "$B/dcu_mshr/tb" --seed $seed
done
for seed in 1 2; do
  bench "dcu_mshr bank 5 seed $seed" test/dcu/cg-build.sh dcu_mshr_bk5 "$B/dcu_mshr_bk5" -- \
    "$B/dcu_mshr_bk5/tb" --seed $seed
done
control dcu_mshr nomerge
control dcu_mshr order
control dcu_mshr early
asserts twolook dcu_mshr mshr_one_lookup --control twolook
for seed in 1 2 3; do
  bench "dcu_mpick seed $seed" test/dcu/cg-build.sh dcu_mpick "$B/dcu_mpick" -- "$B/dcu_mpick/tb" --seed $seed
done
control dcu_mpick retry
control dcu_mpick age
control dcu_mpick pass
control dcu_mpick credit
for seed in 1 2 3; do
  bench "dcu_fill seed $seed" test/dcu/cg-build.sh dcu_fill "$B/dcu_fill" -- "$B/dcu_fill/tb" --seed $seed
done
control dcu_fill nowait
control dcu_fill highest
exit $fail
