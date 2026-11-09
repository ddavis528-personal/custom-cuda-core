#!/usr/bin/env bash
# RI's RCU RTL benches under Verilator, assertions on (docs/rcu-impl.md,
# section 5, step 2): each module against its reference, at the sizes the
# units use and the FULL_ROW build's both settings. One PASS line each; any
# failure fails the run.
#   rcu_bank_slice: test/rcu/bank_slice_tb.cpp, 32 rows (FULL_ROW 1 and 0;
#                   section 1, and 3 for every owner slot), and its controls
#                   nowt (no MIU write-through), rfirst (migration's row on
#                   R2 beside the R op's), lown (the L rows on slot 0) and
#                   msrc (the M rows by port, not the memop's sources) and
#                   lsecK (the owner's lead_sec_mask without section K) and
#                   psecX (a P lead_sec_mask with an extra bit, RA 133), each
#                   of which must fail
#   rcu_xbar:       test/rcu/xbar_tb.cpp, 32 lanes
#   rcu_r:          test/rcu/r_tb.cpp, and its negative controls (noalign,
#                   retlow, pmovneg), each of which must fail
#   rcu_pred:       test/rcu/pred_tb.cpp, and its negative controls (spbown, nofwd,
#                   nomerge, lgcorrupt), each of which must fail
#   rcu_isd(_s):    test/rcu/isd_tb.cpp (each slot's class from its lead, RA-43,
#                   RI-25; _s: an S slot's lead copies too, RA 131 (1)), and
#                   its controls pcopy (the copy without its predicate-only
#                   form) and xfree (the copies not held off a valid), each
#                   of which must fail;
#   rcu_kill:       test/rcu/kill_tb.cpp, and its control drain (KILL_DRAIN
#                   - 1 in the value model), which must fail
#   ccv_rcu_killsleep: test/rcu/killsleep_tb.cpp, the whole block on its gate:
#                   a kill landing while asleep, and two a cycle apart across
#                   the wake (RA rev 127), and its controls drop1 and drop2
#                   (the kill detector's held kill dropped), each must fail
#   rcu_mig:        test/rcu/mig_tb.cpp (M5 and random traffic with kills), and
#                   its controls rlie (the R op's R2/RW use hidden), cred (a
#                   credit fewer at the receiver), wake (the wake a cycle
#                   early), each of which must fail
#   rcu_lanes:      test/rcu/lanes_tb.cpp, 4 copies (--full adds 32), and its
#                   controls bypage (a forward's age one more) and immpos (the
#                   immediate at position 0), each of which must fail
#   rcu_mem:        test/rcu/mem_tb.cpp, 4 lanes (--full adds 32), and its
#                   controls align (operands not right-aligned) and pstlane
#                   (a predicate store's word in lane 1), each of which must fail
#   rcu_dec_pkg:    rtl/rcu/rcu_dec_pkg.sv is what test/rcu/gen_dec.cpp prints
#                   from the model's decode (sim/rcu/rcu_decode.h)
# Usage: test/rcu/run-rtl.sh [--full]   (--full adds the 192-row slice and the
#        32-copy lanes and mem)
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
# The op-class decode package is the model's decode written out (RI-21 (4)):
# rebuilt from sim/rcu/rcu_decode.h, it must match rtl/rcu/rcu_dec_pkg.sv.
if g++ -std=c++17 -O1 -Wall -Wextra -Werror -Isim/skel -Isim/generated -Isim/rcu -Isim/include \
     test/rcu/gen_dec.cpp -o "$B/gen_dec" >"$B/gen_dec.build.log" 2>&1 &&
   "$B/gen_dec" >"$B/rcu_dec_pkg.sv" && cmp -s "$B/rcu_dec_pkg.sv" rtl/rcu/rcu_dec_pkg.sv; then
  say "rcu_dec_pkg current with the model's decode" "PASS"
else
  say "rcu_dec_pkg current with the model's decode" "FAIL (run $B/gen_dec > rtl/rcu/rcu_dec_pkg.sv)"; fail=1
fi
units="rcu_bank_slice_r32 rcu_bank_slice_r32_sec rcu_bank_slice_r32_k3"
[ "${1:-}" = --full ] && units="$units rcu_bank_slice"
for u in $units; do
  bench "$u" test/rcu/cg-build.sh "$u" "$B/$u" -- "$B/$u/tb"
done
# psecX: the slice refuses the lead (p_lead_is_footprint, RA 133).
if [ -x "$B/rcu_bank_slice_r32/tb" ] && ! "$B/rcu_bank_slice_r32/tb" --control psecX >"$B/bs.psecX.log" 2>&1 &&
   grep -q "Assertion failed in .*p_lead_is_footprint" "$B/bs.psecX.log"; then
  say "rcu_bank_slice control psecX" "caught"
else
  say "rcu_bank_slice control psecX" "NOT CAUGHT ($B/bs.psecX.log)"; fail=1
fi
for c in nowt rfirst lown msrc lsecK; do
  if [ -x "$B/rcu_bank_slice_r32/tb" ] && ! "$B/rcu_bank_slice_r32/tb" --control "$c" >"$B/bs.$c.log" 2>&1 &&
     grep -q "control $c: .* [1-9][0-9]* mismatches: FAIL$" "$B/bs.$c.log"; then
    say "rcu_bank_slice control $c" "caught"
  else
    say "rcu_bank_slice control $c" "NOT CAUGHT ($B/bs.$c.log)"; fail=1
  fi
done
bench rcu_xbar verilator --cc --exe --build -j 0 -O2 -Wno-fatal --top-module rcu_xbar --Mdir "$B/xbar" -o tb \
  rtl/rcu/rcu_xbar.sv test/rcu/xbar_tb.cpp -- "$B/xbar/tb"
bench rcu_r test/rcu/cg-build.sh rcu_r "$B/rcu_r" -- "$B/rcu_r/tb"
for c in noalign retlow pmovneg; do   # a control the bench does not catch is a failure
  if [ -x "$B/rcu_r/tb" ] && ! "$B/rcu_r/tb" --control "$c" >"$B/rcu_r.$c.log" 2>&1 &&
     grep -q "control $c: .* [1-9][0-9]* mismatches: FAIL$" "$B/rcu_r.$c.log"; then
    say "rcu_r control $c" "caught"
  else
    say "rcu_r control $c" "NOT CAUGHT ($B/rcu_r.$c.log)"; fail=1
  fi
done
bench rcu_pred test/rcu/cg-build.sh rcu_pred "$B/rcu_pred" -- "$B/rcu_pred/tb"
for c in nofwd nomerge spbown lgcorrupt; do
  if [ -x "$B/rcu_pred/tb" ] && ! "$B/rcu_pred/tb" --control "$c" >"$B/rcu_pred.$c.log" 2>&1 &&
     grep -q "control $c: .* [1-9][0-9]* mismatches: FAIL$" "$B/rcu_pred.$c.log"; then
    say "rcu_pred control $c" "caught"
  else
    say "rcu_pred control $c" "NOT CAUGHT ($B/rcu_pred.$c.log)"; fail=1
  fi
done
for u in rcu_isd rcu_isd_s; do
  bench $u test/rcu/cg-build.sh $u "$B/$u" -- "$B/$u/tb"
  for c in pcopy xfree; do
    if [ -x "$B/$u/tb" ] && ! "$B/$u/tb" --control $c >"$B/$u.$c.log" 2>&1 &&
       grep -q "control $c: .* [1-9][0-9]* mismatches: FAIL$" "$B/$u.$c.log"; then
      say "$u control $c" "caught"
    else
      say "$u control $c" "NOT CAUGHT ($B/$u.$c.log)"; fail=1
    fi
  done
done
bench rcu_kill test/rcu/cg-build.sh rcu_kill "$B/rcu_kill" -- "$B/rcu_kill/tb"
if [ -x "$B/rcu_kill/tb" ] && ! "$B/rcu_kill/tb" --control drain >"$B/rcu_kill.drain.log" 2>&1 &&
   grep -q "control drain: .* [1-9][0-9]* mismatches: FAIL$" "$B/rcu_kill.drain.log"; then
  say "rcu_kill control drain" "caught"
else
  say "rcu_kill control drain" "NOT CAUGHT ($B/rcu_kill.drain.log)"; fail=1
fi
# The whole block on its gate: a kill that lands while RCU sleeps (RA rev 127).
bench ccv_rcu_killsleep test/rcu/cg-build.sh ccv_rcu_killsleep "$B/killsleep" -- "$B/killsleep/tb"
for c in drop1 drop2; do
  if [ -x "$B/killsleep/tb" ] && ! "$B/killsleep/tb" --control "$c" >"$B/killsleep.$c.log" 2>&1 &&
     grep -q "control $c: .*: FAIL$" "$B/killsleep.$c.log"; then
    say "ccv_rcu_killsleep control $c" "caught"
  else
    say "ccv_rcu_killsleep control $c" "NOT CAUGHT ($B/killsleep.$c.log)"; fail=1
  fi
done
bench rcu_mig test/rcu/cg-build.sh rcu_mig "$B/rcu_mig" -- "$B/rcu_mig/tb"
grep -h "^mig M5" "$B/rcu_mig.log" 2>/dev/null | sed 's/^/    /'
for c in rlie cred wake stall2; do
  if [ -x "$B/rcu_mig/tb" ] && ! "$B/rcu_mig/tb" --control "$c" >"$B/rcu_mig.$c.log" 2>&1 &&
     grep -q "control $c .* [1-9][0-9]* mismatches: FAIL$" "$B/rcu_mig.$c.log"; then
    say "rcu_mig control $c" "caught"
  else
    say "rcu_mig control $c" "NOT CAUGHT ($B/rcu_mig.$c.log)"; fail=1
  fi
done
for m in lanes mem; do
  us="rcu_${m}_c4"; [ "${1:-}" = --full ] && us="$us rcu_$m"
  for u in $us; do bench "$u" test/rcu/cg-build.sh "$u" "$B/$u" -- "$B/$u/tb"; done
  case $m in lanes) cs="bypage immpos pcrow" ;; mem) cs="align pstlane" ;; esac
  for c in $cs; do
    if [ -x "$B/rcu_${m}_c4/tb" ] && ! "$B/rcu_${m}_c4/tb" --control "$c" >"$B/rcu_$m.$c.log" 2>&1 &&
       grep -q "control $c: .* [1-9][0-9]* mismatches: FAIL$" "$B/rcu_$m.$c.log"; then
      say "rcu_$m control $c" "caught"
    else
      say "rcu_$m control $c" "NOT CAUGHT ($B/rcu_$m.$c.log)"; fail=1
    fi
  done
done
exit $fail
