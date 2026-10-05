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
#   a redirect names FET's own checkpoint     corrupt-ckpt: FET refuses it
#   no free for a checkpoint a redirect       stale-free: FET refuses a free
#     restores; the pair lands in send order     for a dead checkpoint (A-58)
#   OOE schedules on DEC's sched_attr         attr-store-as-load: OOE never
#     (A-66), never on opcode                    commits the store
#   branches resolved in RCU, guard negated    drop-negate: RCU's resolution
#                                                and FET's redirect both wrong
#   load write-back from MIU's echo            corrupt-echo: C_ADD's lanes see
#                                                a stale R8
#   a guarded compare writes a predicate      conflate-pred: the next guard
#     other than its guard (pguard, Q-21)        is wrong at the lanes, and
#                                                P0 and P1 both end wrong
#   every op on its side of the rule (Q-32)   movi-in-lane: the lanes refuse
#                                                movi48 and movi, and OOE's
#                                                V-35 names the late done
#   srd's value from OOE's identity (Q-38)    corrupt-ctaid (srd kernel): the
#                                                lanes' srd result is wrong
#   an unallocated srd selector faults        srd-selector: DEC's range check
#                                                names it; nothing retires it
#   the lane mask is on the wire with valid,  late-lead: every lane takes a
#     a cycle ahead of the operands (Q-40)       stale mask
#   a masked-off lane does not compute, and   ignore-mask (pguard): its poison
#     RCU merges predicates by the mask (A-43)   lands in P1
#   a guarded write merges inactive lanes     wrong-merge (merge): the lanes
#     from its old destination (A-33, A-44)      refuse the wrong source
#   a launched warp reads the zero registers  dirty-zero (merge): every path
#     (A-64)                                     that reads one fails
#   a masked load's inactive lanes keep their skip-copy (mload): the lanes see
#     old value, by a copy-only op (A-38)        the fresh register's garbage
#                                              copy-from-new (mload): the lanes
#                                                refuse the copy's source
#   the copy lands within CCV_LAT_LANE of     late-copy (mload): RCU's
#     RCU taking it (A-38)                       contract check fires
#   a warp access split across two lines      one-line (unal): MIU's loaded
#     (unal) or spread over 32 (gather)          values and the stored words
#                                                past the boundary are wrong
#   retire frees the mapping a write          free-new (loop): live values
#     replaced; the free list wraps (loop)       reallocated, the lanes see it
#   the issue mask is FET's group mask,       corrupt-group-mask: the lanes
#     carried with the uop (A-69)                refuse a mask missing lane 31
#   a uop of a stale fetch epoch is dropped   stale-epoch (loop): OOE drops
#     before rename (A-70)                       it, and it never retires
#   every kernel reaches the bins it exists   (COVER counts, below; a stub
#     for (docs/coverage.md)                     change that stops reaching a
#                                                path fails here)
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
want="finished=1 retired=17 issue_groups=17 order=ok gpr_mismatch=0 pred_mismatch=0 mem_mismatch=0 check_failures=0 class_violations=0 overflows=0 credit_leaks=0 violations=0"
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
   grep -q "^CHECK fet: seq 8 redirect to" "$B/kernel_drop-negate.log" &&
   ! grep -q "redirect names checkpoint" "$B/kernel_drop-negate.log"; then
  say "--break drop-negate: RCU and FET reject the branch" "PASS"
else
  bad "--break drop-negate" "a backwards guard went unnoticed"
fi
# The checkpoint a redirect names is FET's own, back through DEC and OOE
# (A-42): drop-negate's redirect names the right one (checked just above),
# and one naming another must be refused.
run corrupt-ckpt
if grep -q "^CHECK fet: seq 8 redirect names checkpoint" "$B/kernel_corrupt-ckpt.log"; then
  say "--break corrupt-ckpt: FET refuses the checkpoint" "PASS"
else
  bad "--break corrupt-ckpt" "a redirect naming the wrong checkpoint went unnoticed"
fi
# A checkpoint is freed exactly once (A-56, A-58): stale-free has OOE also
# free the checkpoint its redirect restores. The two channels are a
# latency-matched pair and FET applies the redirect first, so the free lands
# on a checkpoint that is already dead, and FET must say so (V-46).
run stale-free
if grep -q "^CHECK fet: a free for tier-1 slot 0 checkpoint [0-9]*, which is not live" \
     "$B/kernel_stale-free.log"; then
  say "--break stale-free: FET refuses a dead free" "PASS"
else
  bad "--break stale-free" "a free for a restored checkpoint went unnoticed"
fi
# OOE decides memory kind from DEC's decoded sched_attr, not from opcode
# (A-66): attr-store-as-load marks the store a load in sched_attr alone.
# mem_op still says store (A-68), so MIU buffers it, but OOE never sends the
# commit a store owes at retire, and every word of the result stays unwritten.
"$SKEL" --kernel "$K" --break attr-store-as-load --cycles 3000 >"$B/kernel_attr-store-as-load.log" 2>&1
if [ "$(field "$B/kernel_attr-store-as-load.log" mem_mismatch)" = 32 ]; then
  say "--break attr-store-as-load: the store never lands" "PASS (32 words)"
else
  bad "--break attr-store-as-load" "OOE ignored sched_attr's memory kind"
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
# to the lanes instead, every lane must refuse both. The lane round trip also
# breaks CCV_LAT_RCU, which OOE schedules movi48's readers on: OOE's
# arrival-cycle checker on ccv_rcu_ooe_done (V-35) must name the late done,
# once. Its readers then see the stale register -- the cost of a broken
# latency contract to a latency-scheduled OOE, not a second fault -- and
# that shows up downstream as wrong lane operands, wrong addresses and
# loads at MIU, and a window base that differs across lanes. Those are the
# only other failures allowed, and the total is pinned: a new failure in
# this kernel still fails the control. (Re-pin MOVI_TOTAL only with the
# reason in the commit; it moves when OOE's timing does.)
MOVI_TOTAL=356
run movi-in-lane
L="$B/kernel_movi-in-lane.log"
nmovi=$(grep -c "^CHECK lane [0-9]*: MOVI\(48\)\? " "$L")
nlate=$(grep -c "^CHECK ooe: V-35: " "$L")
nother=$(grep "^CHECK" "$L" | grep -v "^CHECK lane [0-9]*: MOVI\(48\)\? \|^CHECK ooe: V-35: " |
         grep -vc "^CHECK lane [0-9]*: seq [0-9]* operand \|^CHECK miu: seq [0-9]* lane [0-9]* \(address\|loaded\) \|^CHECK rcu: window base differs across lanes")
total=$(field "$L" check_failures)
if [ "$nmovi" = 64 ] && [ "$nlate" = 1 ] && [ "$nother" = 0 ] && [ "$total" = "$MOVI_TOTAL" ] &&
   grep -q "^CHECK ooe: V-35: seq 1 (rob tag [0-9]*) done" "$L"; then
  say "--break movi-in-lane: the lanes refuse it" "PASS (V-35 names the late done; $total failures, as pinned)"
else
  bad "--break movi-in-lane" "$nmovi lane refusals (want 64), $nlate V-35 reports (want 1, seq 1), $nother failures of another kind (want 0), $total in all (want $MOVI_TOTAL)"
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
# A masked-off lane never computes: its predicate output is poison, and RCU
# merges predicates by read-modify-write under the active mask (A-43). If the
# merge drops the mask, pguard's guarded compare (lanes 16-31 off) puts poison
# into P1, which sel's lanes and the final compare see.
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
#   a masked-off lane does not compute, and   ignore-mask (pguard): its poison
#     RCU merges predicates by the mask (A-43)   lands in P1

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

# merge (S2's first kernel): guarded GPR and predicate writes that merge their
# inactive lanes from the old destination (A-33, A-43, A-44), and a launched
# warp's reads of the zero registers (A-64). Lanes 16-31 are off for the
# guarded writes, so their old value is what the lane must return.
M=build/oracle/merge/oracle.jsonl
"$SKEL" --kernel "$M" >"$B/kernel_merge.log" 2>&1
ok=1
for kv in finished=1 order=ok gpr_mismatch=0 pred_mismatch=0 mem_mismatch=0 check_failures=0 class_violations=0 violations=0; do
  [ "$(field "$B/kernel_merge.log" "${kv%%=*}")" = "${kv#*=}" ] || ok=0
done
if [ $ok = 1 ]; then
  say "merge: final state == ccv-sim, 0 violations" "PASS ($(field "$B/kernel_merge.log" cycles) cycles)"
else
  bad "merge: final state == ccv-sim, 0 violations" "$(grep '^KERNEL' "$B/kernel_merge.log")"
fi
# The zero registers read as garbage: R6's first guarded write merges it into
# lanes 16-31 (16), the next write reads those lanes back (16), C_ADD reads
# the unwritten R7 in every lane (32), and P2's merge leaves it wrong (1).
"$SKEL" --kernel "$M" --break dirty-zero >"$B/kernel_dirty-zero.log" 2>&1
if grep -q "^CHECK lane 16: seq 4 merge_data 5a5a5a5a, but R6 keeps 00000000" "$B/kernel_dirty-zero.log" &&
   [ "$(field "$B/kernel_dirty-zero.log" check_failures)" = 64 ] &&
   [ "$(field "$B/kernel_dirty-zero.log" pred_mismatch)" = 1 ]; then
  say "--break dirty-zero: every zero-register path" "PASS (64 lane checks, P2)"
else
  bad "--break dirty-zero" "a zero-register read went unnoticed: $(grep '^KERNEL' "$B/kernel_dirty-zero.log")"
fi
# The merge value from the wrong register: every inactive lane of both
# guarded writes refuses it, and R6 ends wrong on the lanes the second one
# switched off.
"$SKEL" --kernel "$M" --break wrong-merge >"$B/kernel_wrong-merge.log" 2>&1
if grep -q "^CHECK lane 16: seq 4 merge_data 00000010, but R6 keeps 00000000" "$B/kernel_wrong-merge.log" &&
   [ "$(field "$B/kernel_wrong-merge.log" gpr_mismatch)" = 16 ]; then
  say "--break wrong-merge: the lanes refuse it" "PASS"
else
  bad "--break wrong-merge" "a wrong merge source went unnoticed: $(grep '^KERNEL' "$B/kernel_wrong-merge.log")"
fi

# mload: masked loads under rename (A-33, A-38). MIU writes a load's active
# lanes; its inactive ones are copied from the old destination by the
# copy-only op OOE issues beside it, through a lane, written back on the
# inactive lanes only. Lanes 16-31 keep R5 = 100 + tid across the first load;
# lanes 0-15 keep R8 = 0, from the zero register, across the second.
L=build/oracle/mload/oracle.jsonl
"$SKEL" --kernel "$L" >"$B/kernel_mload.log" 2>&1
ok=1
for kv in finished=1 order=ok gpr_mismatch=0 pred_mismatch=0 mem_mismatch=0 check_failures=0 class_violations=0 violations=0; do
  [ "$(field "$B/kernel_mload.log" "${kv%%=*}")" = "${kv#*=}" ] || ok=0
done
if [ $ok = 1 ]; then
  say "mload: final state == ccv-sim, 0 violations" "PASS ($(field "$B/kernel_mload.log" cycles) cycles)"
else
  bad "mload: final state == ccv-sim, 0 violations" "$(grep '^KERNEL' "$B/kernel_mload.log")"
fi
# No copy: the fresh registers keep their power-on garbage on the inactive
# lanes. C_ADD reads R5's 16 of them, and R8 ends wrong on its 16.
"$SKEL" --kernel "$L" --break skip-copy >"$B/kernel_skip-copy.log" 2>&1
if grep -q "^CHECK lane 16: seq 9 operand 0 (R5) dead...., oracle 00000074" "$B/kernel_skip-copy.log" &&
   [ "$(field "$B/kernel_skip-copy.log" check_failures)" = 16 ] &&
   [ "$(field "$B/kernel_skip-copy.log" gpr_mismatch)" = 16 ]; then
  say "--break skip-copy: inactive lanes keep garbage" "PASS (R5 read, R8 final)"
else
  bad "--break skip-copy" "a masked load without its copy went unnoticed: $(grep '^KERNEL' "$B/kernel_skip-copy.log")"
fi
# The copy from the load's own fresh register: each lane it carries refuses
# it -- 16 inactive lanes per copy, two copies -- and C_ADD reads R5's 16.
"$SKEL" --kernel "$L" --break copy-from-new >"$B/kernel_copy-from-new.log" 2>&1
if grep -q "^CHECK lane 16: seq 7's copy carries dead...., but R5 keeps 00000074" "$B/kernel_copy-from-new.log" &&
   [ "$(field "$B/kernel_copy-from-new.log" check_failures)" = 48 ] &&
   [ "$(field "$B/kernel_copy-from-new.log" gpr_mismatch)" = 16 ]; then
  say "--break copy-from-new: the lanes refuse it" "PASS (32 copied lanes, 16 reads)"
else
  bad "--break copy-from-new" "a copy from the wrong register went unnoticed: $(grep '^KERNEL' "$B/kernel_copy-from-new.log")"
fi
# The copy held past its contract: the stubs' load completion is slow enough
# to hide it from the reader, so RCU's own check is what must fire, once per
# copy. A real OOE wakes the reader on the contract, not on the completion.
"$SKEL" --kernel "$L" --break late-copy >"$B/kernel_late-copy.log" 2>&1
if [ "$(grep -c "^CHECK rcu: seq [78]'s copy reached the PRF [0-9]* cycles after RCU took it" "$B/kernel_late-copy.log")" = 2 ] &&
   [ "$(field "$B/kernel_late-copy.log" check_failures)" = 2 ]; then
  say "--break late-copy: RCU's contract check fires" "PASS (both copies)"
else
  bad "--break late-copy" "a copy past CCV_LAT_LANE went unnoticed: $(grep '^KERNEL' "$B/kernel_late-copy.log")"
fi


# Coverage kernels (docs/coverage.md): misaligned and scattered warp accesses,
# mispredicted branches, checkpoint pressure. Each must match ccv-sim, AND
# reach the bins it exists for -- a kernel that passes without reaching its
# path proves nothing about it. Bins are counted in the stubs (COVER line).
cover() { sed -n 's/^COVER //p' "$1" | tr ' ' '\n' | sed -n "s/^$2=//p"; }
while read -r k want; do
  [ -z "$k" ] && continue
  log="$B/kernel_$k.log"
  "$SKEL" --kernel "build/oracle/$k/oracle.jsonl" >"$log" 2>&1
  why=""
  for kv in finished=1 order=ok gpr_mismatch=0 pred_mismatch=0 mem_mismatch=0 check_failures=0 class_violations=0 violations=0; do
    [ "$(field "$log" "${kv%%=*}")" = "${kv#*=}" ] || why="$why ${kv%%=*}=$(field "$log" "${kv%%=*}")"
  done
  for w in $want; do
    bin=${w%%[=>]*}; have=$(cover "$log" "$bin")
    case "$w" in
      *'>'*) [ "${have:-0}" -gt "${w#*>}" ] || why="$why $bin=$have (want >${w#*>})" ;;
      *)     [ "$have" = "${w#*=}" ] || why="$why $bin=$have (want ${w#*=})" ;;
    esac
  done
  if [ -z "$why" ]; then
    say "$k: == ccv-sim, reaches its bins" "PASS ($(field "$log" cycles) cycles; $want)"
  else
    bad "$k: == ccv-sim, reaches its bins" "${why# }"
  fi
done <<'KERNELS'
unal   line_split=3 lines_peak=2 partial_line=2
gather lines_peak=32 line_split=2 partial_line=32 dcu_id_wait>0
loop   redirect=99 ckpt_free=1 reg_reuse>0
brs    redirect=1 ckpt_peak=4 ckpt_full>0 ckpt_free=5
mload  copy=2 zero_read=1
merge  zero_read=2 merge=4
vadd   ckpt_free=1 redirect=0 epoch_drop=0
KERNELS
"$SKEL" --kernel build/oracle/unal/oracle.jsonl --break one-line >"$B/kernel_one-line.log" 2>&1
if grep -q "^CHECK miu: seq 4 lane 27 loaded 000003e8, oracle 000004c8" "$B/kernel_one-line.log" &&
   [ "$(field "$B/kernel_one-line.log" mem_mismatch)" = 17 ]; then
  say "--break one-line: the lanes past the boundary" "PASS (loads at MIU, 17 stored words)"
else
  bad "--break one-line" "a warp access split across lines went unchecked: $(grep '^KERNEL' "$B/kernel_one-line.log")"
fi
"$SKEL" --kernel build/oracle/loop/oracle.jsonl --break free-new >"$B/kernel_free-new.log" 2>&1
if grep -q "^CHECK lane 0: seq 382 operand 1 (R1) 0000005e, oracle 00000000" "$B/kernel_free-new.log" &&
   [ "$(field "$B/kernel_free-new.log" gpr_mismatch)" -gt 0 ]; then
  say "--break free-new: a live register reallocated" "PASS (seq 382, once the list wraps)"
else
  bad "--break free-new" "freeing the wrong register went unnoticed: $(grep '^KERNEL' "$B/kernel_free-new.log")"
fi
"$SKEL" --kernel "$K" --break corrupt-group-mask >"$B/kernel_corrupt-group-mask.log" 2>&1
if grep -q "^CHECK lane 31: seq 5 pred_bit is not issue mask AND guard" "$B/kernel_corrupt-group-mask.log" &&
   [ "$(field "$B/kernel_corrupt-group-mask.log" check_failures)" = 1 ]; then
  say "--break corrupt-group-mask: lane 31 refuses it" "PASS (A-69)"
else
  bad "--break corrupt-group-mask" "a wrong group mask went unnoticed: $(grep '^KERNEL' "$B/kernel_corrupt-group-mask.log")"
fi
"$SKEL" --kernel build/oracle/loop/oracle.jsonl --break stale-epoch >"$B/kernel_stale-epoch.log" 2>&1
if [ "$(cover "$B/kernel_stale-epoch.log" epoch_drop)" = 1 ] &&
   [ "$(field "$B/kernel_stale-epoch.log" order)" = bad ] &&
   [ "$(field "$B/kernel_stale-epoch.log" retired)" = 406 ]; then
  say "--break stale-epoch: OOE drops the uop" "PASS (A-70; 406 of 407 retire)"
else
  bad "--break stale-epoch" "a stale-epoch uop was not dropped: $(grep -E '^(KERNEL|COVER)' "$B/kernel_stale-epoch.log" | xargs)"
fi

exit $fail
