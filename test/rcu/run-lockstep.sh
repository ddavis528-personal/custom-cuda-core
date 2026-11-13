#!/usr/bin/env bash
# RI's block lock-step (docs/rcu-impl.md, section 5, step 3): every kernel
# the oracles hold, run on the skeleton with the RCU model in place and its
# ports dumped (ccv-skel --port-dump rcu=), each dump replayed into
# rtl/rcu/ccv_rcu.sv under Verilator, assertions on, and every output
# compared every cycle (test/rcu/lockstep.py says what counts on each
# channel). One line a kernel; any divergence or assertion fails the run.
# Then its negative controls, on vadd, each of which must diverge:
#   init  the RTL's register file left unmatched to the model's power-up
#   opnd  one operand bit a lane consumes flipped in the dump
# Needs build/skel/ccv-skel (tools/check-skel.sh) and build/oracle/
# (tools/check-kernel.sh).
# Usage: test/rcu/run-lockstep.sh [KERNEL...]   (default: every oracle)
set -uo pipefail
cd "$(dirname "$0")/../.."
B=build/rcu-ls; D=$B/k; mkdir -p "$D"
SKEL=build/skel/ccv-skel
fail=0
say() { printf '  %-52s %s\n' "$1" "$2"; }
if [ ! -x "$SKEL" ] || [ ! -d build/oracle ]; then
  say "RCU block lock-step" "FAIL (needs $SKEL and build/oracle: check-skel, check-kernel)"; exit 1
fi
if [ $# -gt 0 ]; then ks=("$@"); else
  ks=(); for o in build/oracle/*/oracle.jsonl; do ks+=("$(basename "$(dirname "$o")")"); done
fi
# The model's ports, a kernel at a time on the jobs the gate gives.
printf '%s\n' "${ks[@]}" | xargs -P "${CCV_JOBS:-4}" -I{} sh -c \
  'env -u CCV_RCU_IMPL "$1" --kernel "build/oracle/$2/oracle.jsonl" --port-dump "rcu=$3/$2.vcd" >"$3/$2.skel.log" 2>&1 ||
   echo "skel $2 failed" >"$3/$2.skel.fail"' _ "$SKEL" {} "$D"
dumps=()
for k in "${ks[@]}"; do
  if [ -f "$D/$k.skel.fail" ] || [ ! -s "$D/$k.vcd" ]; then
    say "lockstep $k" "FAIL (skeleton run; $D/$k.skel.log)"; fail=1; rm -f "$D/$k.skel.fail"
  else
    dumps+=("$D/$k.vcd")
  fi
done
python3 test/rcu/lockstep.py --build "$B" --triage "${dumps[@]}" >"$B/lockstep.log" 2>&1
for d in "${dumps[@]}"; do
  k=$(basename "$d" .vcd)
  r=$(grep -m1 "^$d: " "$B/lockstep.log" | sed "s|^$d: ||")
  case "$r" in
    IDENTICAL*) say "lockstep $k" "PASS (${r#IDENTICAL, })" ;;
    *) say "lockstep $k" "FAIL (${r:-no result}; $B/lockstep.log)"; fail=1 ;;
  esac
done
[ -s "$D/vadd.vcd" ] ||
  env -u CCV_RCU_IMPL "$SKEL" --kernel build/oracle/vadd/oracle.jsonl --port-dump "rcu=$D/vadd.vcd" >"$D/vadd.skel.log" 2>&1
for c in init opnd; do
  if python3 test/rcu/lockstep.py --build "$B" --control "$c" "$D/vadd.vcd" >"$B/control.$c.log" 2>&1; then
    say "lockstep control $c" "caught"
  else
    say "lockstep control $c" "NOT CAUGHT ($B/control.$c.log)"; fail=1
  fi
done
exit $fail
