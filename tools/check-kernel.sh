#!/usr/bin/env bash
# Stage 3 skeleton -- S1: a kernel through the machine.
#
# vadd runs on S1's functional stubs, over the real channel path, with the
# checker bank judging every slot, and must end with the register file and
# memory ccv-sim ends with. Every clean result has a partner that must fail:
#
#   clean                                      negative control
#   final state == ccv-sim, 0 check failures   corrupt-fetch: DEC sees the byte
#                                              corrupt-load:  a lane sees the
#                                                operand AND the final R9 differs
#                                              drop-store:    all 32 words differ
#   responses correlated by req_id             corrupt-req-id: MLC refuses the
#                                                mis-tagged fill; nothing retires
#   addresses from the carried disp + scale    corrupt-disp: MIU's AGU address
#                                                disagrees with ccv-sim's
#   one ITLB miss outstanding                  itlb-double: the bank's
#                                                outstanding checker fires
#   branches resolved in RCU, guard negated    drop-negate: RCU's resolution
#                                                and FET's redirect both wrong
#   0 bank violations                          (S0's controls, tools/check-skel.sh)
#   EV_CH_XFER == every launch                 (exact multiset: one flipped bit
#                                                or identity fails it)
#
# Needs build/skel/ccv-skel from tools/check-skel.sh, which verify.sh runs
# first.
set -uo pipefail
cd "$(dirname "$0")/.."
B=build
SKEL="$B/skel/ccv-skel"
K=test/golden/vadd/oracle.jsonl
fail=0
say() { printf '  %-46s %s\n' "$1" "$2"; }
bad() { say "$1" "FAIL -- $2"; fail=1; }
# Whole-key match: `violations=` must not match `class_violations=`.
field() { tr ' ' '\n' <"$1" | sed -n "s/^$2=//p" | head -1; }

if [ ! -x "$SKEL" ]; then
  say "S1 kernel" "SKIP -- no $SKEL (tools/check-skel.sh builds it)"
  exit 0
fi

# -- golden record still what ccv-sim produces -----------------------------
tools/gen-golden.sh --check || fail=1

# -- the clean run -----------------------------------------------------------
log=$B/kernel_vadd.log
"$SKEL" --kernel "$K" --trace "$B/kernel_vadd.ccvtrace" >"$log" 2>&1
want="finished=1 retired=17 issue_groups=17 order=ok gpr_mismatch=0 pred_mismatch=0 mem_mismatch=0 check_failures=0 class_violations=0 overflows=0 violations=0"
ok=1
for kv in $want; do
  [ "$(field "$log" "${kv%%=*}")" = "${kv#*=}" ] || { ok=0; miss="$kv (got $(field "$log" "${kv%%=*}"))"; }
done
cyc=$(field "$log" cycles)
if [ $ok = 1 ]; then
  say "vadd: final state == ccv-sim, 0 violations" "PASS ($cyc cycles, $(field "$log" channels_used) channels)"
else
  bad "vadd: final state == ccv-sim, 0 violations" "$miss"
fi
if [ "$(field "$log" match)" = "yes" ]; then
  say "vadd: bank EV_CH_XFER == every launch" "PASS ($(field "$log" events) transfers)"
else
  bad "vadd: bank EV_CH_XFER == every launch" "$(grep '^XFER' "$log")"
fi

# Deterministic: a second run is cycle-identical and trace-identical.
"$SKEL" --kernel "$K" --trace "$B/kernel_vadd2.ccvtrace" >"$B/kernel_vadd2.log" 2>&1
if cmp -s "$B/kernel_vadd.ccvtrace" "$B/kernel_vadd2.ccvtrace" &&
   [ "$(field "$B/kernel_vadd2.log" cycles)" = "$cyc" ]; then
  say "vadd: deterministic (trace byte-identical)" "PASS"
else
  bad "vadd: deterministic" "second run differs"
fi

# -- Perfetto: both views convert, and every retire is on its instruction --
if python3 tools/trace2perfetto.py "$B/kernel_vadd.ccvtrace" --by=instr \
     -o "$B/kernel_vadd.json" >/dev/null 2>&1 &&
   got=$(python3 - "$B/kernel_vadd.json" <<'PY'
import json, sys
d = json.load(open(sys.argv[1]))["traceEvents"]
names = {e["pid"]: e["args"]["name"] for e in d
         if e.get("ph") == "M" and e.get("name") == "process_name"}
ret = [e for e in d if e.get("name") == "EV_RETIRE"]
# One retire per instruction process, none elsewhere.
print(len(ret), len({e["pid"] for e in ret}),
      sum(1 for e in ret if e["pid"] >= 1000))
PY
   ) && [ "$got" = "17 17 17" ] &&
   python3 tools/trace2perfetto.py "$B/kernel_vadd.ccvtrace" \
     -o "$B/kernel_vadd_units.json" >/dev/null 2>&1; then
  say "vadd trace -> Perfetto, 17 retires on 17 instrs" "PASS"
else
  bad "vadd trace -> Perfetto" "${got:-conversion failed}"
fi

# -- negative controls: each must fail, where it should ---------------------
run() { "$SKEL" --kernel "$K" --break "$1" >"$B/kernel_$1.log" 2>&1; }
run corrupt-fetch
if [ "$(field "$B/kernel_corrupt-fetch.log" check_failures)" != 0 ] &&
   grep -q "^CHECK dec: seq 5 " "$B/kernel_corrupt-fetch.log"; then
  say "--break corrupt-fetch: DEC rejects the bytes" "PASS"
else
  bad "--break corrupt-fetch" "not caught at DEC"
fi
run corrupt-load
if grep -q "^CHECK lane 5: seq 14 operand 1 (R9)" "$B/kernel_corrupt-load.log" &&
   [ "$(field "$B/kernel_corrupt-load.log" gpr_mismatch)" = 1 ]; then
  say "--break corrupt-load: lane check + final R9" "PASS"
else
  bad "--break corrupt-load" "not caught by the lane and the final compare"
fi
run drop-store
if [ "$(field "$B/kernel_drop-store.log" mem_mismatch)" = 32 ]; then
  say "--break drop-store: all 32 words differ" "PASS"
else
  bad "--break drop-store" "mem_mismatch=$(field "$B/kernel_drop-store.log" mem_mismatch), want 32"
fi

# Responses are matched by req_id, per hop, not by arrival order: a response
# that names the wrong id is refused rather than taken as the oldest.
"$SKEL" --kernel "$K" --break corrupt-req-id --cycles 3000 >"$B/kernel_corrupt-req-id.log" 2>&1
if grep -q "^CHECK mlc: a response for req_id 1, which is not outstanding" \
     "$B/kernel_corrupt-req-id.log" &&
   [ "$(field "$B/kernel_corrupt-req-id.log" finished)" = 0 ]; then
  say "--break corrupt-req-id: MLC refuses, no retire" "PASS"
else
  bad "--break corrupt-req-id" "a mis-tagged response was accepted"
fi

# The AGU computes addresses from what it is SENT: a displacement off by 4
# on the memop must surface as MIU's address check against ccv-sim.
run corrupt-disp
if grep -q "^CHECK miu: seq 6 lane 0 address 20008, oracle 20004" "$B/kernel_corrupt-disp.log"; then
  say "--break corrupt-disp: MIU's AGU address rejected" "PASS"
else
  bad "--break corrupt-disp" "the displacement did not reach the address check"
fi

# FET is single-miss-outstanding, asserted rather than tagged. Two misses
# outstanding must trip the bank's outstanding checker -- and nothing else
# in the bank.
"$SKEL" --kernel "$K" --break itlb-double --cycles 3000 >"$B/kernel_itlb-double.log" 2>&1
props=$(grep -o "CCV [a-z_]* failed" "$B/kernel_itlb-double.log" | awk '{print $2}' | sort -u | tr '\n' '+' | sed 's/+$//')
if [ "$props" = "within_limit" ] &&
   grep -q "u_fet_miu_itlb_req_outstanding" "$B/kernel_itlb-double.log"; then
  say "--break itlb-double: outstanding limit fires" "PASS"
else
  bad "--break itlb-double" "bank fired {$props}, want {within_limit} on the ITLB pair"
fi

# Branches resolve in RCU from the guard, negate included. Without the
# negate, vadd's @!P0 branch is taken by every lane: RCU's resolution must
# disagree with ccv-sim, and the redirect it causes must reach FET, which
# must reject it too -- the one run that exercises ooe_fet_redirect.
run drop-negate
if grep -q "^CHECK rcu: seq 8 branch taken by ffffffff, oracle 00000000" "$B/kernel_drop-negate.log" &&
   grep -q "^CHECK fet: seq 8 redirect to" "$B/kernel_drop-negate.log"; then
  say "--break drop-negate: RCU and FET reject the branch" "PASS"
else
  bad "--break drop-negate" "a backwards guard went unnoticed"
fi

# -- sel: a predicate read as DATA by the lane ------------------------------
# pred_bit is the lane's enable; sel's selector rides separately as
# pred_data, and half the lanes must choose rs1 for it to be observable.
S=test/golden/sel/oracle.jsonl
"$SKEL" --kernel "$S" >"$B/kernel_sel.log" 2>&1
ok=1
for kv in finished=1 order=ok gpr_mismatch=0 pred_mismatch=0 mem_mismatch=0 check_failures=0 class_violations=0 violations=0; do
  [ "$(field "$B/kernel_sel.log" "${kv%%=*}")" = "${kv#*=}" ] || ok=0
done
if [ $ok = 1 ]; then
  say "sel: final state == ccv-sim, 0 violations" "PASS ($(field "$B/kernel_sel.log" cycles) cycles)"
else
  bad "sel: final state == ccv-sim, 0 violations" "$(grep '^KERNEL' "$B/kernel_sel.log")"
fi
"$SKEL" --kernel "$S" --break drop-pred-data >"$B/kernel_drop-pred-data.log" 2>&1
if grep -q "^CHECK lane 0: seq 5 pred_data (sel's selector) wrong" "$B/kernel_drop-pred-data.log"; then
  say "--break drop-pred-data: sel's lanes reject it" "PASS"
else
  bad "--break drop-pred-data" "a missing selector went unnoticed"
fi

exit $fail
