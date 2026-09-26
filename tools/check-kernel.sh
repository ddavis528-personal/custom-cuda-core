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
#   load write-back from MIU's echo            corrupt-echo: C_ADD's lanes see
#                                                a stale R8
#   a guarded compare writes a predicate      conflate-pred: the next guard
#     other than its guard (pguard, Q-21)        is wrong at the lanes, and
#                                                P0 and P1 both end wrong
#   every op on its side of the rule (Q-32)   movi-in-lane: the lanes refuse
#                                                movi48 and movi
#   srd's value from OOE's identity (Q-38)    corrupt-ctaid (srd kernel): the
#                                                lanes' srd result is wrong
#   an unallocated srd selector faults        srd-selector: DEC's range check
#                                                names it; nothing retires it
#   the lane mask is on the wire with valid,  late-lead: every lane takes a
#     a cycle ahead of the operands (Q-40)       stale mask
#   a masked-off lane does nothing, and RCU   ignore-mask (pguard): its poison
#     writes back only active lanes              lands in P1
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
K=build/oracle/vadd/oracle.jsonl
fail=0
say() { printf '  %-46s %s\n' "$1" "$2"; }
bad() { say "$1" "FAIL -- $2"; fail=1; }
# Whole-key match: `violations=` must not match `class_violations=`.
field() { tr ' ' '\n' <"$1" | sed -n "s/^$2=//p" | head -1; }

if [ ! -x "$SKEL" ]; then
  say "S1 kernel" "SKIP -- no $SKEL (tools/check-skel.sh builds it)"
  exit 0
fi

# -- the oracle records, from the pinned compiler snapshot -------------------
# Generated each run by the snapshot's built ccv-sim (tools/compiler.lock), not
# checked in. No oracle, no kernel runs: that is a failure, not a skip.
tools/gen-oracle.sh || { echo "  S1 kernels: no oracle records" >&2; exit 1; }

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

# RCU keeps no table of outstanding loads: it writes where MIU's echo says.
# A wrong echo lands a[i] in R9, leaving R8 stale, and C_ADD's lanes must
# reject the operand. (The final compare cannot see it: the next load
# rewrites R9 and C_ADD's result comes from the oracle.)
run corrupt-echo
if grep -q "^CHECK lane 1: seq 14 operand 0 (R8)" "$B/kernel_corrupt-echo.log"; then
  say "--break corrupt-echo: stateless write-back misroutes" "PASS"
else
  bad "--break corrupt-echo" "a wrong echoed destination went unnoticed"
fi

# Where each op executes (Q-32, Q-38) is checked on every op. movi and
# movi48 have no per-lane input, so RCU writes their immediate itself; sent
# to the lanes instead, every lane must refuse both, and nothing else fails.
run movi-in-lane
if [ "$(field "$B/kernel_movi-in-lane.log" check_failures)" = 64 ] &&
   ! grep "^CHECK" "$B/kernel_movi-in-lane.log" | grep -qv "MOVI48\|MOVI "; then
  say "--break movi-in-lane: the lanes refuse it" "PASS"
else
  bad "--break movi-in-lane" "check_failures=$(field "$B/kernel_movi-in-lane.log" check_failures), want 64 from movi and movi48 alone"
fi

# srd's selector is a legal field that can hold an unallocated value: DEC's
# range check, a separate obligation from the reserved-field zero checks,
# must name it, and the instruction must not retire.
run srd-selector
if grep -q "^CHECK dec: seq 2 srd selector 2 is unallocated" "$B/kernel_srd-selector.log" &&
   [ "$(field "$B/kernel_srd-selector.log" retired)" != 17 ]; then
  say "--break srd-selector: DEC's range check" "PASS"
else
  bad "--break srd-selector" "an unallocated selector decoded"
fi

# -- sel: a predicate read as DATA by the lane ------------------------------
# pred_bit is the lane's enable; sel's selector rides separately as
# pred_data, and half the lanes must choose rs1 for it to be observable.
S=build/oracle/sel/oracle.jsonl
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

# -- srd: identity from OOE, at a non-zero CTA index (Q-38) ----------------
# OOE puts srd's value in the immediate from its shadow of RAU's table; the
# lane ORs its index in for %ctatid. CTA 7, so %ctaid is visible.
D=build/oracle/srd/oracle.jsonl
"$SKEL" --kernel "$D" >"$B/kernel_srd.log" 2>&1
ok=1
for kv in finished=1 order=ok gpr_mismatch=0 pred_mismatch=0 mem_mismatch=0 check_failures=0 class_violations=0 violations=0; do
  [ "$(field "$B/kernel_srd.log" "${kv%%=*}")" = "${kv#*=}" ] || ok=0
done
if [ $ok = 1 ]; then
  say "srd: final state == ccv-sim, 0 violations" "PASS ($(field "$B/kernel_srd.log" cycles) cycles)"
else
  bad "srd: final state == ccv-sim, 0 violations" "$(grep '^KERNEL' "$B/kernel_srd.log")"
fi
"$SKEL" --kernel "$D" --break corrupt-ctaid >"$B/kernel_corrupt-ctaid.log" 2>&1
if grep -q "^CHECK lane [0-9]*: seq 2 srd 8, oracle 7" "$B/kernel_corrupt-ctaid.log"; then
  say "--break corrupt-ctaid: srd's lanes reject it" "PASS"
else
  bad "--break corrupt-ctaid" "a wrong CTA index reached a register unnoticed"
fi

# -- the lane mask: one cycle ahead, and always gating (Q-40) ---------------
# pred_bit, pred_data and section_en are rcu_lane_ops' LEAD fields: driven with
# valid, a cycle ahead of the operands, so a lane gates itself before its
# operands land. Driven late, with the operands, the lane takes whatever the
# wire's lead slice held in the valid cycle -- a stale mask -- and must reject
# it at once.
run late-lead
if grep -q "^CHECK lane [0-9]*: seq [0-9]* pred_bit is not issue mask AND guard" \
     "$B/kernel_late-lead.log"; then
  say "--break late-lead: every lane sees a stale mask" "PASS"
else
  bad "--break late-lead" "a mask arriving with the operands went unnoticed"
fi
# A masked-off lane never computes: its outputs are poison. RCU must write
# back only the lanes the mask enables, or pguard's guarded compare (lanes
# 16-31 off) puts poison into P1, which sel's lanes and the final compare see.
"$SKEL" --kernel build/oracle/pguard/oracle.jsonl --break ignore-mask \
  >"$B/kernel_ignore-mask.log" 2>&1
if grep -q "^CHECK lane [0-9]*: seq 9 pred_data (sel's selector) wrong" "$B/kernel_ignore-mask.log" &&
   [ "$(field "$B/kernel_ignore-mask.log" pred_mismatch)" = 1 ]; then
  say "--break ignore-mask: masked-off poison lands" "PASS"
else
  bad "--break ignore-mask" "a write-back from a masked-off lane went unnoticed"
fi

#   an unallocated srd selector faults        srd-selector: DEC's range check
#                                                names it; nothing retires it
#   the lane mask is on the wire with valid,  late-lead: every lane takes a
#     a cycle ahead of the operands (Q-40)       stale mask
#   a masked-off lane does nothing, and RCU   ignore-mask (pguard): its poison
#     writes back only active lanes              lands in P1

# @P0 setp P1 carries its guard and destination in separate uop fields. With
# them conflated back into one (the destination named by the guard), the
# compare writes P0, so the next compare's guard is wrong at its lanes, and
# both predicates end differently from ccv-sim.
P=build/oracle/pguard/oracle.jsonl
"$SKEL" --kernel "$P" >"$B/kernel_pguard.log" 2>&1
ok=1
for kv in finished=1 order=ok gpr_mismatch=0 pred_mismatch=0 mem_mismatch=0 check_failures=0 class_violations=0 violations=0; do
  [ "$(field "$B/kernel_pguard.log" "${kv%%=*}")" = "${kv#*=}" ] || ok=0
done
if [ $ok = 1 ]; then
  say "pguard: final state == ccv-sim, 0 violations" "PASS ($(field "$B/kernel_pguard.log" cycles) cycles)"
else
  bad "pguard: final state == ccv-sim, 0 violations" "$(grep '^KERNEL' "$B/kernel_pguard.log")"
fi
"$SKEL" --kernel "$P" --break conflate-pred >"$B/kernel_conflate-pred.log" 2>&1
if grep -q "^CHECK lane [0-9]*: seq 7 pred_bit is not issue mask AND guard" "$B/kernel_conflate-pred.log" &&
   [ "$(field "$B/kernel_conflate-pred.log" pred_mismatch)" = 2 ]; then
  say "--break conflate-pred: guard and P0/P1 wrong" "PASS"
else
  bad "--break conflate-pred" "one field for guard and destination went unnoticed"
fi

exit $fail
