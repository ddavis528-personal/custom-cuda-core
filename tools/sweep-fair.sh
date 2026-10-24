#!/usr/bin/env bash
# The CCV_FAIR_N sweep (IS-17, AR's revs 119-121): every kernel's cycles with
# FET's fairness rule at each N against the rule off.
#
# For each N, ccv-sim generates the kernels' records at -fairness=N
# (gen-oracle.sh, CCV_FAIR_N) and the skeleton runs them with FET's rule at
# the same N, so FET's picks are checked against the order ccv-sim took. N = 0
# is the rule off, strict min-PC: a kernel whose lanes wait on each other
# (spinwait) has no record there, since ccv-sim runs it to its step limit.
#
# Not part of the gate: it runs every kernel once per N, a few minutes each.
# Writes build/sweep/fair.md, a table of cycles from FET's first fetch, and
# fails if any run at any N differs from ccv-sim.
#
#   tools/sweep-fair.sh [N ...]      default: 0 32 48 64
set -uo pipefail
cd "$(dirname "$0")/.."
SKEL=build/skel/ccv-skel
[ -x "$SKEL" ] || { echo "sweep-fair: no $SKEL (tools/check-skel.sh builds it)" >&2; exit 1; }
ns=("$@"); [ ${#ns[@]} -gt 0 ] || ns=(0 32 48 64)
field() { tr ' ' '\n' <"$1" | sed -n "s/^$2=//p" | head -1; }
cover() { sed -n 's/^COVER //p' "$1" | tr ' ' '\n' | sed -n "s/^$2=//p"; }
mkdir -p build/sweep
rc=0
declare -A cyc fair odiff
for n in "${ns[@]}"; do
  d=build/sweep/n$n
  CCV_FAIR_N=$n CCV_ORACLE_DIR=$d tools/gen-oracle.sh >"$d.gen.log" 2>&1
  for k in $(ls -d test/kernels/*/ | xargs -n1 basename); do
    # No record: ccv-sim did not finish it (its step limit), which under
    # strict min-PC is spinwait's hang. It leaves a partial record, so the
    # verdict is gen-oracle's, not the file's.
    if grep -qE "oracle $k from the pinned ccv-sim +FAIL" "$d.gen.log" || [ ! -s "$d/$k/oracle.jsonl" ]; then
      cyc[$k,$n]="hangs"; continue
    fi
    log=$d/$k.log
    CCV_FAIR_N=$n "$SKEL" --kernel "$d/$k/oracle.jsonl" >"$log" 2>&1
    ok=1
    for kv in finished=1 order=ok gpr_mismatch=0 pred_mismatch=0 mem_mismatch=0 check_failures=0 violations=0; do
      [ "$(field "$log" "${kv%%=*}")" = "${kv#*=}" ] || ok=0
    done
    # The same run with the swap on: a restored diverged warp may depart
    # from ccv-sim's order there (TI-27 (c)), counted as order_diff.
    CCV_FAIR_N=$n CCV_RAU_DEMOTE=mlc "$SKEL" --kernel "$d/$k/oracle.jsonl" >"$d/$k.swap.log" 2>&1
    for kv in finished=1 order=ok gpr_mismatch=0 pred_mismatch=0 mem_mismatch=0 check_failures=0 violations=0; do
      [ "$(field "$d/$k.swap.log" "${kv%%=*}")" = "${kv#*=}" ] || ok=0
    done
    odiff[$k,$n]=$(cover "$d/$k.swap.log" order_diff)
    if [ $ok = 1 ]; then
      cyc[$k,$n]=$(field "$log" from_fetch)
      fair[$k,$n]=$(cover "$log" fair_pick)
    else
      cyc[$k,$n]="FAIL"; rc=1
      echo "sweep-fair: $k at N=$n: $(grep '^KERNEL' "$log")" >&2
    fi
  done
done
{
  echo "# CCV_FAIR_N sweep"
  echo
  echo "Cycles from FET's first fetch, each kernel with FET's rule and ccv-sim's"
  echo "order at the same N; N = 0 is the rule off (strict min-PC). Fair picks"
  echo "in parentheses where any fired. Compiler $(sed -n 's/^commit=//p' tools/compiler.lock | cut -c1-7)."
  echo
  printf '| kernel |'; for n in "${ns[@]}"; do [ "$n" = 0 ] && printf ' off |' || printf ' N = %s |' "$n"; done; echo
  printf '| --- |'; for n in "${ns[@]}"; do printf ' ---: |'; done; echo
  for k in $(ls -d test/kernels/*/ | xargs -n1 basename); do
    printf '| %s |' "$k"
    for n in "${ns[@]}"; do
      v=${cyc[$k,$n]}; f=${fair[$k,$n]:-0}
      [ "$f" != 0 ] && v="$v ($f)"
      printf ' %s |' "$v"
    done
    echo
  done
  echo
  printf 'order_diff with the swap on (CCV_RAU_DEMOTE=mlc), picks a restored warp took from ccv-sim'"'"'s order instead of its own (TI-27 (c)):'
  any=0
  for n in "${ns[@]}"; do for k in $(ls -d test/kernels/*/ | xargs -n1 basename); do
    o=${odiff[$k,$n]:-0}; [ "$o" = 0 ] || { printf ' %s at N=%s: %s;' "$k" "$n" "$o"; any=1; }
  done; done
  [ $any = 1 ] && echo || echo ' none.'
} >build/sweep/fair.md
cat build/sweep/fair.md
exit $rc
