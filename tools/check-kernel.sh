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
#   a CTA is one CTA slot, its warps from one cta-per-warp (lanectx): MIU sees
#     ccv-sim -cta run, and a slot is one     one CTA's warps in two slots;
#     CTA's (CP-30)                              cta-shared (rope): two CTAs
#                                                in one slot
#   an unallocated srd selector faults        srd-selector: DEC's range check
#                                                names it; nothing retires it
#   the lane mask is on the wire with valid,  late-lead: every lane takes a
#     a cycle ahead of the operands (Q-40)       stale mask
#   a masked-off lane does not compute, and   ignore-mask (pguard): its poison
#     RCU merges predicates by the mask (A-43)   lands in P1
#   final predicates are read through OOE's   swap-prat0 (pguard): P0 and P1
#     committed predicate map (OI-3)             both end wrong
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
#   a store covering its line is written      skip-read-partial (unal): a
#     without a read (full_line, AR-19); a       partial store written blind
#     partial one merges into the line read      loses its lines' other four
#                                                words
#   DCU is write-back, write-allocate with    write-through (predswap): the
#     ownership (DCU spec rev 8): a store        old policy, each store to MLC,
#     to an owned line merges there              misses store_hit
#     (store_hit), and a dirty line leaves    drop-writeback (slotform): the
#     whole when its set is taken                evicted lines' 32 words reload
#     (dcu_evict)                                stale and memory differs
#   ...on MLC's grant (ownership)             deny-ownership (predswap, vadd):
#                                                DCU's check refuses the line
#   O-69's interleaved spill space (IS-19):   local-no-ctx (localsp): warp
#     no base register; MIU forms each           1 spills into context 0's
#     lane's address from local_base (its        frame; local-base-slot: the
#     table, launch-block byte 24) and the       window read from slot 0's
#     warp's context (local_form)                word misses the space
#   retire frees the mapping a write          free-new (loop): live values
#     replaced; the free list wraps (loop)       reallocated, the lanes see it
#   the issue mask is FET's group mask,       corrupt-group-mask: the lanes
#     carried with the uop (A-69)                refuse a mask missing lane 31
#   FET picks each group itself, min-PC and   fair-off, fair-late (div): FET
#     O-60's fairness at CCV_FAIR_N, and         refuses ccv-sim's seq 82;
#     splits and reconverges groups              split-swap (div): the first
#     (IS-17 (b))                                split goes the wrong way
#   a load waits for an older store of its    no-st-wait (spinwait): lane 0
#     warp to commit (MIU's disambiguation)      reads the flag still clear
#   RAU's launch mask is per warp, [0,        whole-cta-mask (divtail2): warp
#     min(32, T - 32 x warp_in_cta))             1 picks lanes 20-31
#   a store into .const or the launch window  no-ro (roconst): its 32 stores
#     faults F-RO, and nothing lands; CRU        land, and the warp never
#     holds the fault to ccv-sim's (TI-26)       faults
#   a launch-slot memop's window is the       no-window-fill, window-from-base
#     word at launch block + 32 + 8k, from       (slotform): every lane's
#     MIU's table, filled on first use (TI-31)   address is in window 0
#   a memop's base is per lane (TI-32)        scalar-base (slotform): lanes
#                                                1-31 store into lane 0's window
#   srd #2, %lanectx, is the warp's context   lanectx-literal (lanectx): no
#     << 5 OOE substitutes, lane ORed (O-64)     substitution; the lanes refuse;
#     -- not its index in its CTA                lanectx-as-ctatid (lanectx2):
#                                                CTA 1's warp reads 0-31
#   ld.pred and st.pred (O-19, O-62, O-63;    drop-pred-copy, ldpred-whole-word
#     TI-36) move only the issue mask's bits:    (predmerge): the reload loses
#     the load's copy keeps the rest, the        lanes 16-31; stpred-whole-word
#     store merges its word after commit         (predlane): lanes 0-15's land
#   their address is lane 0's rbase, lane 0   xfer-low-lane (predlane): lanes
#     active or not                              16-31 use their own window
#   st.pred's predicate is data, not a guard  pdata-guard (predlane): its clear
#                                                bits keep memory's ones
#   a demotion between a cracked              resume-mid (predswap, at:57):
#     instruction's uops resumes at its          the warp resumes past it
#     first uop (AR's response TI-36)
#   OOE stamps each memop with its warp's     zero-cta-slot (vadd4): warps 1-3
#     CTA slot, from RAU's alloc (TI-34)         name slot 0, and MIU refuses
#   a fatal fault kills the context: every   no-kill, withheld-ack, stale-ack
#     owner drops the warps and acks at the      (rokill): never killed, or the
#     kill's epoch (V-24)                        kill never completes
#   OOE ends a warp at the exit FET marks     early-mark (div): the warp ends
#     final (TI-27)                              with lanes live, and the rest
#                                                of its uops find no slot
#   spinwait needs the rule                   ccv-sim at -fairness=0 runs to
#                                                its step limit
#   a uop of a stale fetch epoch is dropped   stale-epoch (loop): OOE drops
#     before rename (A-70)                       it, and it never retires
#   an L1 hit completes at the contract with  early-hit, late-hit-data,
#     its data, and its dependants read it       no-rcu-bypass (hit, with
#     (A-46, OI-5)                               l1_spec): V-44 or stale reads
#   a dependant woken at CCV_LAT_LANE_BYP     no-lane-bypass (byp, with
#     reads the value its lane forwards          bypass): four stale operands;
#     (A-59, TI-8)                               an OOE bypassing at 3: RCU
#                                                refuses it
#   a notice's partner follows on its slot  late-refill, notice-wrong-id,
#     exactly its lead later, same keys        late-cmpl, hint-wrong-tag
#     (OA-23, TI-23)                           (vadd): the bank's notice check
#   a completion echoes its memop's RS      rs-echo (vadd): OOE refuses
#     entry (OA-23)                            every completion
#   a parked warp is restored, resumes at     pca-row-order (swap): it ends
#     its boundary and ends as ccv-sim         wrong; early-restore-done
#     does (TI-24)                             (swap): RCU refuses the read
#   a demotion's bulk discard ends its       drop-replay (swap): it never
#     loads with one replay completion each,   drains; replay-twice (swap):
#     orphans their DCU requests, and MIU      OOE refuses the second;
#     reports the warp ready once they are     no-ready (swap): it stays
#     home, which RAU restores on (TI-21)      parked; early-ready (stall):
#                                              the replay misses again
#   CCV_RAU_READY=0: with a slot idle, a     guard-at-restore (provswap):
#     parked warp is restored provisionally,   it keeps the slot;
#     and demotes again for a ready warp       demote-unwanted (stall): it
#     (RAU spec rev 25)                        demotes with nobody waiting
#   a demotion moves one row per register,   restore-share (swap): RCU
#     restored each into its own (TI-25)       refuses the shared row
#   a demote that lands after the exit       ignore-refused (brs): RAU
#     retired is refused, and the exit         migrates it, and refuses
#     frees the slot (TI-25)                   the drained report
#   a demoted warp parks in PCA with its     corrupt-map, mig-row-order,
#     state at its retirement boundary         resume-pc (stall, demoting):
#     (TI-24), at the place RAU names, each    resume-pc, rewind-pc (stall):
#     lane's PC from OOE's rewind beats        the parked check refuses each;
#                                              pca-place (mwmiss): PCA refuses
#   OOE renames and waits on the sources     drop-src-valid (vaddslow): DEC
#     DEC marks real (TI-1)                      hides a second source, and
#                                                seq 14 reads R9 stale
#   predicate logic reads renamed sources     arch-pred-srcs (plog): RCU
#     from imm, with negates (TI-1)              reads DEC's qualifiers, and
#                                                P3 comes out wrong
#   co-issued footprints are disjoint on the  no-resource-cap: two ops claim
#     nine resource slots (V-60, TI-9)           one group; RCU refuses each
#                                                shared slot
#   a register fits its row at its position   bad-pos: RCU and the lanes
#     (OI-29, TI-9)                              refuse a 32-bit one at 1
#   a memop's pipes are its width's span      narrow-pipes: MIU refuses one
#     (OI-33, TI-9)                              pipe for a 32-bit memop
#   only a fence carries an ordering          ordering-on-load: DEC's output
#     (IS-11)                                    and MIU refuse each of vadd's 7
#                                                loads; memop-ordering: MIU alone
#   the suite issues out of order: enough     --in-order: the same traces held
#     instructions ahead of older ones, deep     in program order fail the
#     enough (tools/check-ooo.py)                floor
#   a warp stalled on a long miss holds no    dcu-one-miss (stall): the other
#     other up: they finish 300 cycles before    warps finish after it
#     it (stall)
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
# A run's cycles, and those from FET's first instruction to DEC (AR-19): the
# launch and the cold ITLB and ifill misses before it are the same in every
# kernel, so comparisons between kernels and stubs run from_fetch.
cycles() { echo "$(field "$1" cycles) cycles, $(field "$1" from_fetch) from first fetch"; }

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
ff=$(field "$log" from_fetch)
# from_fetch counts from a cycle inside the run: set, and short of the total.
[ "${ff:-0}" -gt 0 ] && [ "$ff" -lt "$cyc" ] || { ok=0; miss="from_fetch=$ff of $cyc cycles"; }
if [ $ok = 1 ]; then
  say "vadd: final state == ccv-sim, 0 violations" "PASS ($(cycles "$log"), $(field "$log" channels_used) channels)"
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
# loads at MIU. Those are the
# only other failures allowed, and the total is pinned: a new failure in
# this kernel still fails the control. (Re-pin MOVI_TOTAL only with the
# reason in the commit; it moves when OOE's timing does. 356 -> 259 when RCU's
# register read began to see the same cycle's writes, OI-5: fewer readers
# land before the value. 259 -> 676 when the lanes began answering at
# CCV_LAT_LANE rather than early, TI-8: the misplaced movi's round trip now
# lands two cycles later, so more readers land before the value. 676 -> 516
# when the lane channel became one message a cycle and OOE one full-width
# lane op a cycle, TI-9: the readers issue later, so fewer land before it.
# 516 -> 512 when the base became per lane, TI-32: the four reports that
# the window base differed across lanes went with the scalar base.)
# One lane message a cycle also means the misplaced movi takes the message
# OOE scheduled for the lane op issued beside it, seq 3's srd, whose done
# V-35 then names a cycle late too: the cost of the movi, not a second fault.
MOVI_TOTAL=512
run movi-in-lane
L="$B/kernel_movi-in-lane.log"
nmovi=$(grep -c "^CHECK lane [0-9]*: MOVI\(48\)\? " "$L")
nlate=$(grep -c "^CHECK ooe: V-35: " "$L")
nother=$(grep "^CHECK" "$L" | grep -v "^CHECK lane [0-9]*: MOVI\(48\)\? \|^CHECK ooe: V-35: " |
         grep -vc "^CHECK lane [0-9]*: seq [0-9]* operand \|^CHECK miu: seq [0-9]* lane [0-9]* \(address\|loaded\) ")
total=$(field "$L" check_failures)
if [ "$nmovi" = 64 ] && [ "$nlate" = 2 ] && [ "$nother" = 0 ] && [ "$total" = "$MOVI_TOTAL" ] &&
   grep -q "^CHECK ooe: V-35: seq 1 (rob tag [0-9]*) done" "$L" &&
   grep -q "^CHECK ooe: V-35: seq 3 (rob tag [0-9]*) done" "$L"; then
  say "--break movi-in-lane: the lanes refuse it" "PASS (V-35 names the late done; $total failures, as pinned)"
else
  bad "--break movi-in-lane" "$nmovi lane refusals (want 64), $nlate V-35 reports (want 2, seq 1 and 3), $nother failures of another kind (want 0), $total in all (want $MOVI_TOTAL)"
fi

# srd's selector is a legal field that can hold an unallocated value: DEC's
# range check, a separate obligation from the reserved-field zero checks,
# must name it, and the instruction must not retire.
run srd-selector
if grep -q "^CHECK dec: seq 2 srd selector 3 is unallocated" "$B/kernel_srd-selector.log" &&
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
  say "sel: final state == ccv-sim, 0 violations" "PASS ($(cycles "$B/kernel_sel.log"))"
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
  say "srd: final state == ccv-sim, 0 violations" "PASS ($(cycles "$B/kernel_srd.log"))"
else
  bad "srd: final state == ccv-sim, 0 violations" "$(grep '^KERNEL' "$B/kernel_srd.log")"
fi
"$SKEL" --kernel "$D" --break corrupt-ctaid >"$B/kernel_corrupt-ctaid.log" 2>&1
if grep -q "^CHECK lane [0-9]*: seq 2 srd 8, oracle 7" "$B/kernel_corrupt-ctaid.log"; then
  say "--break corrupt-ctaid: srd's lanes reject it" "PASS"
else
  bad "--break corrupt-ctaid" "a wrong CTA index reached a register unnoticed"
fi
# One CTA slot per CTA (CP-30): lanectx's two warps are one -cta run.
"$SKEL" --kernel build/oracle/lanectx/oracle.jsonl --break cta-per-warp >"$B/kernel_cta-per-warp.log" 2>&1
if grep -q "^CHECK miu: warps 0 and 1 of ctaid 0 name CTA slots 0 and 1" "$B/kernel_cta-per-warp.log"; then
  say "--break cta-per-warp: one CTA in two slots" "PASS (lanectx)"
else
  bad "--break cta-per-warp" "one CTA's warps in two CTA slots went unnoticed"
fi
"$SKEL" --kernel build/oracle/rope/oracle.jsonl --break cta-shared >"$B/kernel_cta-shared.log" 2>&1
if grep -q "^CHECK miu: CTA slot 0 holds warp 0 of ctaid 0 and warp 1 of ctaid 1" "$B/kernel_cta-shared.log"; then
  say "--break cta-shared: two CTAs in one slot" "PASS (rope)"
else
  bad "--break cta-shared" "two CTAs in one CTA slot went unnoticed"
fi

# -- the lane mask: one cycle ahead, and always gating (Q-40) ---------------
# section_en, sec_owner, sec_pred_bit and sec_pred_data are rcu_lane_ops' LEAD
# fields: driven with valid, a cycle ahead of the operands, so a lane gates
# each section before its operands land. Driven late, with the operands, the
# lane takes whatever the wire's lead slice held in the valid cycle -- a stale
# mask, empty before the first op -- and must reject it at once: every lane,
# on the first lane op.
run late-lead
if [ "$(grep -c "^CHECK lane [0-9]*: sections 0 owned 00; " "$B/kernel_late-lead.log")" = 32 ]; then
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
  say "pguard: final state == ccv-sim, 0 violations" "PASS ($(cycles "$B/kernel_pguard.log"))"
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
# The final compare reads predicates through Kernel::prat0, OOE's committed
# map, once an OOE renames them (OI-3). A map with P0 and P1 swapped must
# fail both, and nothing else.
"$SKEL" --kernel "$P" --break swap-prat0 >"$B/kernel_swap-prat0.log" 2>&1
if [ "$(field "$B/kernel_swap-prat0.log" pred_mismatch)" = 2 ] &&
   [ "$(field "$B/kernel_swap-prat0.log" check_failures)" = 0 ] &&
   [ "$(field "$B/kernel_swap-prat0.log" gpr_mismatch)" = 0 ]; then
  say "--break swap-prat0: compare reads OOE's map" "PASS"
else
  bad "--break swap-prat0" "the final compare does not read through the predicate map"
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
  say "merge: final state == ccv-sim, 0 violations" "PASS ($(cycles "$B/kernel_merge.log"))"
else
  bad "merge: final state == ccv-sim, 0 violations" "$(grep '^KERNEL' "$B/kernel_merge.log")"
fi
# The zero registers read as garbage: R6's first guarded write merges it into
# lanes 16-31 (16), the next write reads those lanes back (16), C_ADD reads
# the unwritten R7 in every lane (32), and P2's merge leaves it wrong (1).
"$SKEL" --kernel "$M" --break dirty-zero >"$B/kernel_dirty-zero.log" 2>&1
if grep -q "^CHECK lane 16: seq 4 merge_data 5a5a5a5a, but R6 keeps 00000000" "$B/kernel_dirty-zero.log" &&
   [ "$(field "$B/kernel_dirty-zero.log" check_failures)" = 64 ] &&
   [ "$(field "$B/kernel_dirty-zero.log" pred_mismatch)" = 2 ]; then
  say "--break dirty-zero: every zero-register path" "PASS (64 lane checks, P2, P3)"
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
  say "mload: final state == ccv-sim, 0 violations" "PASS ($(cycles "$B/kernel_mload.log"))"
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
    say "$k: == ccv-sim, reaches its bins" "PASS ($(cycles "$log"); $want)"
  else
    bad "$k: == ccv-sim, reaches its bins" "${why# }"
  fi
done <<'KERNELS'
unal   line_split=3 lines_peak=2 partial_line=2 full_line=0
gather lines_peak=32 line_split=2 partial_line=32 full_line=0 dcu_id_wait>0 hit_under_miss=2
loop   redirect=99 ckpt_free=1 reg_reuse>0
brs    redirect=1 ckpt_peak=4 ckpt_full>0 ckpt_free=5
mload  copy=2 zero_read=1
merge  zero_read=2 merge=4
vadd   ckpt_free=1 redirect=0 epoch_drop=0 full_line=1 fill_notice=3 cmpl_hint=3
hit    l1_hit=4 l1_late=0
late   l1_late=1 l1_hit=2 hit_under_miss=1
byp    copy=1 lane_byp=4
plog   merge=3
chains lane_byp=9
missrun l1_hit=0 reexec=2
ldpar  l1_hit=4 hit_under_miss=4
mlp    l1_hit=0 reexec=5 fill_notice>0 cmpl_hint>0
mwmiss l1_hit=0
vadd4  full_line=4
swap   slot_reuse=2
provswap redirect>0 slot_reuse>0
stall  l1_late>0
vaddslow full_line=1
div    split=32 reconverge=2 groups_peak=2 fair_pick=1
spinwait fair_pick=4 groups_peak=3 st_ld_wait>0
divtail split=20 groups_peak=2
divtail2 split=51 groups_peak=2
roconst ro_fault=1 fault=1 kill=1
rolimit ro_fault=1 fault=1 kill=1
rolaunch ro_fault=1 fault=1 kill=1
rogated ro_fault=1 fault=1 split=1 kill=1
roload ro_fault=0 fault=0 kill=0
rokill ro_fault=1 fault=1 kill=1
slotform slot_form=4 window_fill=2 frame_lookups=64 l1_hit=0 dcu_evict=32
lanectx redirect=0 split=0
lanectx2 redirect=0 split=0
predspill pred_xfer=7 pred_merge=6 pred_copy=0
predmerge pred_xfer=3 pred_merge=2 pred_copy=1
predlane pred_xfer=2 pred_merge=2 pred_copy=0
predswap pred_xfer=32 pred_merge=16 crack_split=0 store_hit=15
localsp local_form=12 window_fill=2 pred_xfer=4 frame_lookups=0
rope local_form=44 frame_lookups=0
fence fence=1 fence_wait>0
ropediv local_form=30 frame_lookups=0 split=2 groups_peak=2
KERNELS
"$SKEL" --kernel build/oracle/unal/oracle.jsonl --break one-line >"$B/kernel_one-line.log" 2>&1
# 19 words: the 17 the lanes past the boundary should have stored in line 1,
# and two of the words unal pokes beside its store in line 0, which those
# lanes write over instead (17 before the pokes, AR-19).
if grep -q "^CHECK miu: seq 4 lane 27 loaded 000003e8, oracle 000004c8" "$B/kernel_one-line.log" &&
   [ "$(field "$B/kernel_one-line.log" mem_mismatch)" = 19 ]; then
  say "--break one-line: the lanes past the boundary" "PASS (loads at MIU, 17 stored words and 2 overwritten)"
else
  bad "--break one-line" "a warp access split across lines went unchecked: $(grep '^KERNEL' "$B/kernel_one-line.log")"
fi
# A store that covers its line is written without reading it (full_line:
# vadd, sel, srd and pguard each store one whole line), and a partial one
# merges into the line DCU reads (AR-19). Written blind, unal's two partial
# lines lose the four words it pokes beside the store and never writes.
"$SKEL" --kernel build/oracle/unal/oracle.jsonl --break skip-read-partial >"$B/kernel_skip-read-partial.log" 2>&1
if [ "$(field "$B/kernel_skip-read-partial.log" mem_mismatch)" = 4 ] &&
   [ "$(field "$B/kernel_skip-read-partial.log" check_failures)" = 0 ]; then
  say "--break skip-read-partial: words lost" "PASS (unal's 4 words beside its store)"
else
  bad "--break skip-read-partial" "a partial store written without a read went unnoticed: $(grep '^KERNEL' "$B/kernel_skip-read-partial.log")"
fi
# DCU spec rev 8: write-back, write-allocate with ownership. predswap's
# spills after the first each merge into the line DCU owns (store_hit=15);
# written through to MLC, as before rev 8, none does. slotform's 32 dirty
# lines are evicted by the lines its loads bring in (dcu_evict=32); dropped
# instead of written back, seq 8 reloads them stale and memory differs.
"$SKEL" --kernel build/oracle/predswap/oracle.jsonl --break write-through >"$B/kernel_write-through.log" 2>&1
if [ "$(cover "$B/kernel_write-through.log" store_hit)" = 0 ] &&
   grep -q "finished=1 .*order=ok gpr_mismatch=0 pred_mismatch=0 mem_mismatch=0 check_failures=0" "$B/kernel_write-through.log"; then
  say "--break write-through: no store merges in DCU" "PASS (predswap's store_hit 15 -> 0, $(field "$B/kernel_write-through.log" cycles) cycles)"
else
  bad "--break write-through" "store_hit not tied to the write-back policy: $(grep '^KERNEL' "$B/kernel_write-through.log")"
fi
"$SKEL" --kernel build/oracle/slotform/oracle.jsonl --break drop-writeback >"$B/kernel_drop-writeback.log" 2>&1
if [ "$(grep -c '^CHECK miu: seq 8 lane' "$B/kernel_drop-writeback.log")" = 32 ] &&
   [ "$(field "$B/kernel_drop-writeback.log" mem_mismatch)" = 32 ]; then
  say "--break drop-writeback: evicted lines lost" "PASS (seq 8's 32 lanes reload stale; 32 words in memory)"
else
  bad "--break drop-writeback" "a dropped writeback went unnoticed: $(grep '^KERNEL' "$B/kernel_drop-writeback.log")"
fi
# DCU marks a line owned only on MLC's grant (ccv_mlc_dcu_rsp.ownership):
# refused it, predswap's first spill (AcquireBlock) and vadd's whole-line
# store (AcquirePerm) each stop at DCU's check.
"$SKEL" --kernel build/oracle/predswap/oracle.jsonl --break deny-ownership >"$B/kernel_deny-ownership.log" 2>&1
"$SKEL" --kernel build/oracle/vadd/oracle.jsonl --break deny-ownership >"$B/kernel_deny-ownership_vadd.log" 2>&1
if grep -q "^CHECK dcu: MLC answered the acquire of line 90000 (req_id 0) without ownership" "$B/kernel_deny-ownership.log" &&
   grep -q "^CHECK dcu: MLC answered the acquire of line .* without ownership" "$B/kernel_deny-ownership_vadd.log"; then
  say "--break deny-ownership: DCU refuses the line" "PASS (predswap's AcquireBlock, vadd's AcquirePerm)"
else
  bad "--break deny-ownership" "a line taken as owned without MLC's grant: $(grep '^KERNEL' "$B/kernel_deny-ownership.log")"
fi
# O-69's spill space (IS-19): localsp's two warps spill in their own
# frames, 4 MiB apart. MIU forms ctx from the memop's warp_id; taken as 0,
# warp 1's first st.local lands in context 0's frame. local_base is the
# launch block's word at byte 24; read from launch slot 0's instead, every
# local address misses the space.
"$SKEL" --kernel build/oracle/localsp/oracle.jsonl --break local-no-ctx >"$B/kernel_local-no-ctx.log" 2>&1
"$SKEL" --kernel build/oracle/localsp/oracle.jsonl --break local-base-slot >"$B/kernel_local-base-slot.log" 2>&1
if grep -q "^CHECK miu: seq 6 lane 0 address 11000100, oracle 11400100" "$B/kernel_local-no-ctx.log" &&
   grep -q "^CHECK miu: seq 6 lane 0 address 10000100, oracle 11000100" "$B/kernel_local-base-slot.log"; then
  say "--break local-no-ctx, local-base-slot" "PASS (warp 1 in context 0's frame; local_base from the wrong word)"
else
  bad "--break local-no-ctx, local-base-slot" "a local-form address went unchecked: $(grep '^KERNEL' "$B/kernel_local-no-ctx.log")"
fi
"$SKEL" --kernel build/oracle/loop/oracle.jsonl --break free-new >"$B/kernel_free-new.log" 2>&1
# The first wrong read follows when OOE's free lists refill: since OI's
# FreeVec alignment (OI-70, OI-71), seq 204's R3.
if grep -q "^CHECK lane 0: seq 204 operand 1 (R3) 00000032, oracle 00000064" "$B/kernel_free-new.log" &&
   [ "$(field "$B/kernel_free-new.log" gpr_mismatch)" -gt 0 ]; then
  say "--break free-new: a live register reallocated" "PASS (seq 204, its source reallocated)"
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

# Divergence (IS-17 (b)): FET picks every group itself, min-PC and O-60's
# fairness rule at CCV_FAIR_N, and ccv-sim's record checks each pick. div's
# loop sends its leavers a lane at a time to a waiting group, which the rule
# picks once at seq 82: FET without the rule, or with N + 1, picks the loop
# again there. split-swap sends a redirect's taken lanes down the fall-through
# and the rest to the target, which the first split (seq 6) shows.
for b in fair-off fair-late; do
  "$SKEL" --kernel build/oracle/div/oracle.jsonl --break $b >"$B/kernel_$b.log" 2>&1
  if grep -q "^CHECK fet: warp 0 picks 102e for lanes fffe0000; ccv-sim issued 103a for 0001ffff (seq 82)" "$B/kernel_$b.log" &&
     [ "$(field "$B/kernel_$b.log" check_failures)" = 1 ]; then
    say "--break $b: FET skips the fair pick (div)" "PASS (seq 82)"
  else
    bad "--break $b" "a pick without O-60's rule went unnoticed: $(grep '^KERNEL' "$B/kernel_$b.log")"
  fi
done
"$SKEL" --kernel build/oracle/div/oracle.jsonl --break split-swap >"$B/kernel_split-swap.log" 2>&1
if grep -q "^CHECK fet: warp 0 picks 1014 for lanes 0000ffff; ccv-sim issued 1014 for ffff0000 (seq 6)" "$B/kernel_split-swap.log"; then
  say "--break split-swap: the halves go the wrong way (div)" "PASS ($(field "$B/kernel_split-swap.log" check_failures) picks refused)"
else
  bad "--break split-swap" "a split the wrong way went unnoticed: $(grep '^KERNEL' "$B/kernel_split-swap.log")"
fi
# The final exit (OA's rev 170, TI-27): OOE ends a warp when the exit FET
# marked final retires. Marked one exit early, at div's first partial exit,
# the warp ends with lanes still live, RAU frees its slot, and the rest of
# its uops find no slot.
"$SKEL" --kernel build/oracle/div/oracle.jsonl --break early-mark >"$B/kernel_early-mark.log" 2>&1
if grep -q "^CHECK ooe: uop for warp 0, which holds no tier-1 slot" "$B/kernel_early-mark.log" &&
   [ "$(field "$B/kernel_early-mark.log" finished)" = 0 ]; then
  say "--break early-mark: the warp ends with lanes live" "PASS (div, $(field "$B/kernel_early-mark.log" retired) of 144 retire)"
else
  bad "--break early-mark" "an early final exit went unnoticed: $(grep '^KERNEL' "$B/kernel_early-mark.log")"
fi
# RAU's launch mask is per warp (AR's rev 134): divtail2's warp 1 has lanes
# 0-19. Given the CTA's first warp's lanes, FET picks lanes 20-31 at its
# first instruction, which ccv-sim never issued.
"$SKEL" --kernel build/oracle/divtail2/oracle.jsonl --break whole-cta-mask >"$B/kernel_whole-cta-mask.log" 2>&1
if grep -q "^CHECK fet: warp 1 picks 1000 for lanes ffffffff; ccv-sim issued 1000 for 000fffff (seq 0)" "$B/kernel_whole-cta-mask.log"; then
  say "--break whole-cta-mask: warp 1 takes 32 lanes" "PASS (divtail2)"
else
  bad "--break whole-cta-mask" "a mask not per warp went unnoticed: $(grep '^KERNEL' "$B/kernel_whole-cta-mask.log")"
fi
# F-RO (AR's responses TI-26): MIU refuses a store any byte of which lies in
# the CTA's .const range or the launch window, and the fault reaches CRU,
# held there to ccv-sim's cause, pc, lanes and address; the ro* kernels above
# pass only so, with nothing written. Without MIU's check, roconst's 32
# stores land and the warp never faults.
"$SKEL" --kernel build/oracle/roconst/oracle.jsonl --break no-ro >"$B/kernel_no-ro.log" 2>&1
if grep -q "^CHECK cru: warp 0 never faulted; ccv-sim ended it with F-RO at pc 100e" "$B/kernel_no-ro.log" &&
   [ "$(field "$B/kernel_no-ro.log" mem_mismatch)" = 32 ]; then
  say "--break no-ro: the stores land, no fault" "PASS (roconst: 32 words)"
else
  bad "--break no-ro" "a store into .const went unrefused: $(grep '^KERNEL' "$B/kernel_no-ro.log")"
fi
# The launch-slot form (TI-31): the window is the word at the CTA's launch
# block + 32 + 8 x arg_slot, which MIU reads into its table on first use.
# Taken as zero, or from base_per_lane (don't-care for the form), every lane
# of slotform's first load reads window 0.
for b in no-window-fill window-from-base; do
  "$SKEL" --kernel build/oracle/slotform/oracle.jsonl --break $b >"$B/kernel_$b.log" 2>&1
  if grep -q "^CHECK miu: seq 1 lane 0 address 0, oracle 30000" "$B/kernel_$b.log" &&
     [ "$(field "$B/kernel_$b.log" mem_mismatch)" = 64 ]; then
    say "--break $b: the slot's window is lost" "PASS (slotform: window 0, 64 words)"
  else
    bad "--break $b" "a launch-slot memop's window went unchecked: $(grep '^KERNEL' "$B/kernel_$b.log")"
  fi
done
# The base is per lane (TI-32): slotform's R6 is a window per lane, as an
# O-30 frame pointer is. Lane 0's base on every lane puts lanes 1-31's
# store and load in lane 0's window.
"$SKEL" --kernel build/oracle/slotform/oracle.jsonl --break scalar-base >"$B/kernel_scalar-base.log" 2>&1
if grep -q "^CHECK miu: seq 7 lane 1 address 5ffffc, oracle 60fffc" "$B/kernel_scalar-base.log" &&
   [ "$(field "$B/kernel_scalar-base.log" mem_mismatch)" = 32 ]; then
  say "--break scalar-base: lanes 1-31 in lane 0's window" "PASS (slotform: 32 words)"
else
  bad "--break scalar-base" "a per-lane base went unchecked: $(grep '^KERNEL' "$B/kernel_scalar-base.log")"
fi
# srd #2 (O-64): %lanectx is (hardware warp context << 5) | lane. OOE
# substitutes the context, the lane ORs its index; lanectx's warp 1 reads
# 32-63. With srd #2's imm_kind sent as a literal, OOE substitutes nothing,
# and 48 of the 64 lanes refuse the value (the 16 whose index already holds
# bit 1 of the literal 2 compute it by chance in warp 0).
"$SKEL" --kernel build/oracle/lanectx/oracle.jsonl --break lanectx-literal >"$B/kernel_lanectx-literal.log" 2>&1
if grep -q "^CHECK lane 0: seq 0 srd 2, oracle 32" "$B/kernel_lanectx-literal.log" &&
   [ "$(grep -c "^CHECK lane [0-9]*: seq 0 srd " "$B/kernel_lanectx-literal.log")" = 48 ]; then
  say "--break lanectx-literal: no context substituted" "PASS (lanectx: 48 lanes refuse)"
else
  bad "--break lanectx-literal" "srd #2's substitution went unchecked: $(grep '^KERNEL' "$B/kernel_lanectx-literal.log")"
fi
# srd #2 names the hardware context, not the warp's index in its CTA: over
# lanectx2's two one-warp CTAs those differ for CTA 1 (ccv-sim -context,
# TI-35). Taken as srd #0, CTA 1's 32 lanes read 0-31 and refuse.
"$SKEL" --kernel build/oracle/lanectx2/oracle.jsonl --break lanectx-as-ctatid >"$B/kernel_lanectx-as-ctatid.log" 2>&1
if grep -q "^CHECK lane 0: seq 0 srd 0, oracle 32" "$B/kernel_lanectx-as-ctatid.log" &&
   [ "$(grep -c "^CHECK lane [0-9]*: seq 0 srd " "$B/kernel_lanectx-as-ctatid.log")" = 32 ]; then
  say "--break lanectx-as-ctatid: srd #2 read as #0" "PASS (lanectx2: CTA 1's 32 lanes refuse)"
else
  bad "--break lanectx-as-ctatid" "srd #2's context went unchecked: $(grep '^KERNEL' "$B/kernel_lanectx-as-ctatid.log")"
fi
# And each oracle run must name the context RAU gives its warp: lanectx2's
# CTA 1 run again with ccv-sim -context 0, as before TI-35, is refused at
# load, before a cycle runs.
mkdir -p "$B/ctx0" && cp build/oracle/lanectx2/oracle.jsonl "$B/ctx0/oracle.jsonl" &&
"$(tools/fetch-compiler.sh)/release/bin/ccv-sim" build/oracle/lanectx2/kernel.bin -ctaid 1 -context 0 \
  -oracle "$B/ctx0/oracle.1.jsonl" >/dev/null 2>&1
"$SKEL" --kernel "$B/ctx0/oracle.jsonl" >"$B/kernel_ctx0.log" 2>&1
if grep -q "oracle.1.jsonl: ccv-sim ran it as context 0, but RAU gives it warp_id 1" "$B/kernel_ctx0.log"; then
  say "an oracle run of another context: refused" "PASS (lanectx2's CTA 1 at -context 0)"
else
  bad "an oracle run of another context" "loaded: $(tail -1 "$B/kernel_ctx0.log")"
fi
# Predicate transfers (TI-36; ISA O-19, O-62, O-63). predlane: lanes 16-31
# store P1 with rbase 9 + lane, non-uniform, and the address is lane 0's,
# window 9, though lane 0 is inactive (O-62); the lowest active lane's base
# puts them in window 25. The store merges only their bits (O-63): written
# whole, lanes 0-15's land too. Its last store writes P1, clear in lanes
# 16-31, over poked ones: as a guard, P1 would keep memory's ones there.
# predmerge (CP's): lanes 0-15 reload P1 from a zero word and store it. The
# reload writes only their bits, and its copy, a predicate-only one that
# names no GPR (the zero register, TI-37), keeps lanes 16-31's. Without the
# copy, or with the reload written whole, P1 loses lanes 16-31's ones.
for b in drop-pred-copy ldpred-whole-word; do
  "$SKEL" --kernel build/oracle/predmerge/oracle.jsonl --break $b >"$B/kernel_$b.log" 2>&1
  if grep -q "^CHECK miu: seq 6 P1's word 00000000, oracle ffff0000" "$B/kernel_$b.log" &&
     [ "$(field "$B/kernel_$b.log" pred_mismatch)" = 1 ]; then
    say "--break $b: P1 loses lanes 16-31" "PASS (predmerge)"
  else
    bad "--break $b" "ld.pred's lane enable went unchecked: $(grep '^KERNEL' "$B/kernel_$b.log")"
  fi
done
"$SKEL" --kernel build/oracle/predlane/oracle.jsonl --break stpred-whole-word >"$B/kernel_stpred-whole-word.log" 2>&1
if grep -q "^CHECK miu: seq 6 P1 merged ffffffff into 90010, oracle ffff0000" "$B/kernel_stpred-whole-word.log"; then
  say "--break stpred-whole-word: lanes 0-15 stored" "PASS (predlane: 0x90010)"
else
  bad "--break stpred-whole-word" "st.pred's merge went unchecked: $(grep '^KERNEL' "$B/kernel_stpred-whole-word.log")"
fi
"$SKEL" --kernel build/oracle/predlane/oracle.jsonl --break xfer-low-lane >"$B/kernel_xfer-low-lane.log" 2>&1
if grep -q "^CHECK miu: seq 6 uop 0 address 190010, oracle 90010" "$B/kernel_xfer-low-lane.log"; then
  say "--break xfer-low-lane: the lowest active lane's base" "PASS (predlane: window 25)"
else
  bad "--break xfer-low-lane" "a predicate transfer's lane 0 address went unchecked: $(grep '^KERNEL' "$B/kernel_xfer-low-lane.log")"
fi
"$SKEL" --kernel build/oracle/predlane/oracle.jsonl --break pdata-guard >"$B/kernel_pdata-guard.log" 2>&1
if grep -q "^CHECK miu: seq 8 P1 merged ffffffff into 90030, oracle 0000ffff" "$B/kernel_pdata-guard.log"; then
  say "--break pdata-guard: st.pred's predicate as a guard" "PASS (predlane)"
else
  bad "--break pdata-guard" "st.pred's data predicate was taken as a guard unnoticed: $(grep '^KERNEL' "$B/kernel_pdata-guard.log")"
fi
# A demotion between a cracked instruction's uops (AR's response TI-36):
# at cycle 57 predswap's first st.pred has retired its first uop and not
# its second, and the warp resumes at the instruction, running its first
# uop again, which both transfers allow. Resumed past it, the second uop is
# lost. The cycle comes from a sweep of CCV_RAU_DEMOTE=at:<cycle>: if timing
# moves it, crack_split falls to 0 here and the cycle is swept again.
CCV_RAU_DEMOTE=at:57 "$SKEL" --kernel build/oracle/predswap/oracle.jsonl >"$B/kernel_predswap_at57.log" 2>&1
if [ "$(cover "$B/kernel_predswap_at57.log" crack_split)" = 1 ] &&
   grep -q "finished=1 .*order=ok gpr_mismatch=0 pred_mismatch=0 mem_mismatch=0 check_failures=0" "$B/kernel_predswap_at57.log"; then
  say "predswap demoted between a st.pred's uops" "PASS (at:57, it resumes at the instruction)"
else
  bad "predswap demoted between a st.pred's uops" "$(grep '^KERNEL' "$B/kernel_predswap_at57.log"); crack_split=$(cover "$B/kernel_predswap_at57.log" crack_split)"
fi
CCV_RAU_DEMOTE=at:57 "$SKEL" --kernel build/oracle/predswap/oracle.jsonl --break resume-mid >"$B/kernel_resume-mid.log" 2>&1
if grep -q "^CHECK fet: restored warp 0 lane 0 at 1014, but it resumes at 1018" "$B/kernel_resume-mid.log"; then
  say "--break resume-mid: past the split instruction" "PASS (predswap at:57)"
else
  bad "--break resume-mid" "a mid-instruction resume went unchecked: $(grep '^KERNEL' "$B/kernel_resume-mid.log")"
fi
# Each memop names its warp's CTA slot (TI-34): RAU sends it on the alloc,
# and OOE holds it per tier-1 slot and stamps it. Every memop zeroed, as
# before TI-34, and MIU refuses vadd4's warps 1-3, 8 memops each.
"$SKEL" --kernel build/oracle/vadd4/oracle.jsonl --break zero-cta-slot >"$B/kernel_zero-cta-slot.log" 2>&1
if [ "$(grep -c "^CHECK miu: rob tag [0-9]* (warp [123]) names CTA slot 0; RAU gave it [123]" "$B/kernel_zero-cta-slot.log")" = 24 ] &&
   [ "$(field "$B/kernel_zero-cta-slot.log" check_failures)" = 24 ]; then
  say "--break zero-cta-slot: warps 1-3 name slot 0" "PASS (vadd4: 24 memops refused)"
else
  bad "--break zero-cta-slot" "a memop's CTA slot went unchecked: $(grep '^KERNEL' "$B/kernel_zero-cta-slot.log")"
fi
# The kill (V-24): a fatal fault kills the context. RAU broadcasts the mask
# of every valid warp context with an epoch, and waits for the eight owners'
# acks at that epoch; rokill's CTAs 1-3, mid-loop, are stopped by it. Without
# the kill the faulted warp is never killed; with MIU's ack withheld, or
# FET's at the epoch before, the kill never completes.
for b in no-kill withheld-ack stale-ack; do
  "$SKEL" --kernel build/oracle/rokill/oracle.jsonl --break $b >"$B/kernel_$b.log" 2>&1
  case $b in
    no-kill)      want="rau: warp 0 faulted and was never killed" ;;
    withheld-ack) want="rau: the kill never completed: no ack at its epoch from miu" ;;
    stale-ack)    want="rau: the kill never completed: no ack at its epoch from fet" ;;
  esac
  if grep -q "^CHECK $want" "$B/kernel_$b.log" && [ "$(field "$B/kernel_$b.log" finished)" = 0 ]; then
    say "--break $b: the run never ends (rokill)" "PASS"
  else
    bad "--break $b" "the kill's failure went unnoticed: $(grep '^KERNEL' "$B/kernel_$b.log")"
  fi
done
# A demotion's live mask is FET's after the beats (AR's response TI-27 (b)):
# stall's warp 0 has fetched its exit when it demotes, so without the beats'
# lanes FET would park it with none live; held to the boundary's mask.
CCV_RAU_DEMOTE=mlc "$SKEL" --kernel build/oracle/stall/oracle.jsonl --break beats-dead >"$B/kernel_beats-dead.log" 2>&1
if grep -q "^CHECK fet: warp 0's live mask after the beats is 00000000; at its boundary, ffffffff" "$B/kernel_beats-dead.log"; then
  say "--break beats-dead: the parked mask is refused" "PASS (stall, swapped)"
else
  bad "--break beats-dead" "a parked mask without the beats' lanes went unnoticed: $(grep '^KERNEL' "$B/kernel_beats-dead.log")"
fi
# spinwait: lane 0's flag load waits behind lane 1's older store, which has
# not committed (MIU's disambiguation). Read past it, the flag is still 0.
"$SKEL" --kernel build/oracle/spinwait/oracle.jsonl --break no-st-wait >"$B/kernel_no-st-wait.log" 2>&1
if grep -q "^CHECK miu: seq 205 lane 0 loaded 00000000, oracle 00000001" "$B/kernel_no-st-wait.log"; then
  say "--break no-st-wait: the load reads past the store" "PASS (spinwait seq 205)"
else
  bad "--break no-st-wait" "a load past an older store went unnoticed: $(grep '^KERNEL' "$B/kernel_no-st-wait.log")"
fi
# And the rule is what lets spinwait finish: ccv-sim with it off (strict
# min-PC, -fairness=0) runs to its step limit, so no oracle exists to follow.
C=$(tools/fetch-compiler.sh)
pokes=(); while read -r p; do pokes+=(-poke "$p"); done < <(grep -E '^0x' test/kernels/spinwait/kernel.cfg)
# ccv-sim exits non-zero at the limit, so its output is taken whole first
# (under pipefail its status would fail the pipe however grep matched).
sw=$("$C/release/bin/ccv-sim" build/oracle/spinwait/kernel.bin "${pokes[@]}" -fairness=0 2>&1)
if grep -q "step limit reached with lanes still active" <<<"$sw"; then
  say "spinwait under strict min-PC: hangs" "PASS (ccv-sim at -fairness=0)"
else
  bad "spinwait under strict min-PC" "it finished: the kernel no longer needs O-60's rule"
fi

# The OOE modes. bypass and l1_spec are on by default (OI-5), so the runs
# above are both modes on. Here each runs alone, and every kernel runs once
# more with both off, the conservative scheduler (CCV_OOE_CONFIG=bypass=0,
# l1_spec=0): a mode's pass must not rest on the other.
#
# L1 speculation (A-46, OI-5). With OOE's l1_spec on, a load's dependants
# issue at CCV_LAT_L1_WAKE before the load completes, and are cancelled and
# replayed if it misses. That needs MIU to complete a hit at exactly the
# contract (CCV_LAT_L1_CMPL at OOE) with its data, RCU's register read to see
# the same cycle's write (the data lands in the dependant's read cycle), and
# the lanes to judge a replayed op on its last execution (Kernel::failHeld).
# Every kernel must pass so; hit must take its four hits on time and replay
# its miss's dependant. Each piece has a control that must fail.
for k in $(ls build/oracle); do
  log="$B/kernel_${k}_l1spec.log"
  CCV_OOE_CONFIG=bypass=0,l1_spec=1 "$SKEL" --kernel "build/oracle/$k/oracle.jsonl" >"$log" 2>&1
  why=""
  for kv in finished=1 order=ok gpr_mismatch=0 pred_mismatch=0 mem_mismatch=0 check_failures=0 class_violations=0 violations=0; do
    [ "$(field "$log" "${kv%%=*}")" = "${kv#*=}" ] || why="$why ${kv%%=*}=$(field "$log" "${kv%%=*}")"
  done
  [ -z "$why" ] || bad "$k with l1_spec" "${why# }"
done
log="$B/kernel_hit_l1spec.log"
if [ "$(cover "$log" l1_hit)" = 4 ] && [ "$(cover "$log" reexec)" = 1 ] &&
   [ "$(field "$log" check_failures)" = 0 ]; then
  say "every kernel with l1_spec alone; hit's 4 on time" "PASS (its miss's dependant replayed)"
else
  bad "hit with l1_spec" "$(grep -E '^(KERNEL|COVER)' "$log" | xargs)"
fi
l1ctl() { CCV_OOE_CONFIG=l1_spec=1 "$SKEL" --kernel build/oracle/hit/oracle.jsonl --break "$1" >"$B/kernel_$1.log" 2>&1; }
# The completion a cycle early: OOE's V-44 names each of the four, one cycle
# short of the generated contract.
l1ctl early-hit
cmpl=$(sed -n 's/^static constexpr uint32_t kLatL1Cmpl = \([0-9]*\);/\1/p' sim/generated/ccv_params.h)
if [ "$(grep -c "^CHECK ooe: V-44: rob tag [0-9]* completed $((cmpl - 1)) cycles after issue" "$B/kernel_early-hit.log")" = 4 ] &&
   [ "$(field "$B/kernel_early-hit.log" check_failures)" = 4 ]; then
  say "--break early-hit: V-44 names all four" "PASS (at $((cmpl - 1)), CCV_LAT_L1_CMPL $cmpl)"
else
  bad "--break early-hit" "a hit completed early went unnoticed: $(grep '^KERNEL' "$B/kernel_early-hit.log")"
fi
# The data a cycle behind its completion, and RCU reading before the same
# cycle's write: either way the hits' dependants read the old register, and
# nothing replays them, so the held checks fail at the end of the run. Four
# dependants meet the contract cycle: R6's second reader, seq 13, issues a
# cycle after seq 11 while one lane op issues a cycle (TI-9), and finds the
# data in place.
for brk in late-hit-data no-rcu-bypass; do
  l1ctl "$brk"
  n=$(grep -c "^CHECK lane [0-9]*: seq \(5\|7\|9\|11\) operand 1 " "$B/kernel_$brk.log")
  if [ "$n" = 128 ] && [ "$(field "$B/kernel_$brk.log" check_failures)" = 128 ]; then
    say "--break $brk: hits' dependants read stale" "PASS (4 ops x 32 lanes)"
  else
    bad "--break $brk" "$n stale reads (want 128): $(grep '^KERNEL' "$B/kernel_$brk.log")"
  fi
done

# MIU echoes each memop's RS entry on its completion (OA-23),
# so OOE wakes the entry the completion names with no lookup. An echo of the
# wrong entry is a completion waking another uop's dependants: OOE's check
# names every completion it receives.
"$SKEL" --kernel build/oracle/vadd/oracle.jsonl --break rs-echo >"$B/kernel_rs-echo.log" 2>&1
n=$(grep -c "^CHECK ooe: rob tag [0-9]* completed for RS entry [0-9]*, but its memop named entry [0-9]*" "$B/kernel_rs-echo.log")
if [ "$n" -gt 0 ] && [ "$(field "$B/kernel_rs-echo.log" check_failures)" = "$n" ]; then
  say "--break rs-echo: OOE refuses the wrong entry" "PASS ($n completions)"
else
  bad "--break rs-echo" "$n refused: $(grep '^KERNEL' "$B/kernel_rs-echo.log")"
fi

# Notices (OA-23; AR's response TI-23): DCU promises a refill
# CCV_LAT_FILL_NOTICE cycles after its notice lands, MIU a completion
# CCV_LAT_CMPL_HINT cycles after its hint, each on the same slot with the
# same key fields, and the bank's ccv_common_chk_notice holds them to it. The
# runs above reach both (fill_notice, cmpl_hint); here each promise is broken
# both ways, and only the checker that guards it fires.
for spec in late-refill:dcu_miu_fill_ntc:on_time notice-wrong-id:dcu_miu_fill_ntc:same_keys \
            late-cmpl:miu_ooe_cmpl_hint:on_time hint-wrong-tag:miu_ooe_cmpl_hint:same_keys; do
  brk=${spec%%:*}; rest=${spec#*:}; chan=${rest%%:*}; prop=${rest#*:}
  "$SKEL" --kernel build/oracle/vadd/oracle.jsonl --break "$brk" >"$B/kernel_$brk.log" 2>&1
  n=$(grep -c "u_${chan}_notice_s[0-9]*\.g_${prop}_as" "$B/kernel_$brk.log")
  if [ "$n" -gt 0 ]; then
    say "--break $brk: $chan $prop" "PASS ($n)"
  else
    bad "--break $brk" "no $prop on $chan: $(grep '^KERNEL' "$B/kernel_$brk.log")"
  fi
done
# The swap (TI-24; Daniel, 2026-10-21): RAU demotes a warp whose head load
# is outstanding past CCV_DEMOTION_THRESHOLD_MLC (CCV_RAU_DEMOTE=mlc, OOE's
# trigger), parks it in PCA, and restores it into the next free tier-1
# slot, the oldest ready warp first. A warp that parks is checked where it
# parked: PCA's rows, predicates and each lane's PC against ccv-sim's state
# after the instructions it retired. Restored, it resumes at that boundary
# and must still end where ccv-sim does. Every kernel passes so; stall and
# swap (six warps, four slots) are held to the whole round trip.
ok() {   # $1 log, then cover bins name=value; prints why not, or nothing
  local log=$1 why="" kv; shift
  for kv in finished=1 order=ok gpr_mismatch=0 pred_mismatch=0 mem_mismatch=0 check_failures=0 violations=0; do
    [ "$(field "$log" "${kv%%=*}")" = "${kv#*=}" ] || why="$why ${kv%%=*}=$(field "$log" "${kv%%=*}")"
  done
  for kv in "$@"; do
    [ "$(cover "$log" "${kv%%=*}")" = "${kv#*=}" ] || why="$why ${kv%%=*}=$(cover "$log" "${kv%%=*}")"
  done
  echo "${why# }"
}
bad_k=""
for k in $(ls -d test/kernels/*/ | xargs -n1 basename); do
  CCV_RAU_DEMOTE=mlc "$SKEL" --kernel "build/oracle/$k/oracle.jsonl" >"$B/kernel_${k}_swap.log" 2>&1
  w=$(ok "$B/kernel_${k}_swap.log")
  [ -z "$w" ] || bad_k="$bad_k $k($w)"
done
n_par=$(cat "$B"/kernel_*_swap.log | sed -n 's/.* parked=\([0-9]*\) .*/\1/p' | awk '{n+=$1} END {print n+0}')
# order_diff (AR's responses TI-27, rev 134): a restored diverged warp whose
# own pick departs from ccv-sim's follows ccv-sim's group, a named exception
# to the swap-boundary rule, so each kernel's count is printed.
od=""
for k in $(ls -d test/kernels/*/ | xargs -n1 basename); do
  n=$(cover "$B/kernel_${k}_swap.log" order_diff)
  [ "${n:-0}" = 0 ] || od="$od $k=$n"
done
if [ -z "$bad_k" ]; then
  say "every kernel with the swap on == ccv-sim" "PASS ($n_par parks, each restored; order_diff:${od:- none})"
else
  bad "every kernel with the swap on" "${bad_k# }"
fi
for k in stall swap; do
  log="$B/kernel_${k}_swap.log"
  w=$(ok "$log" demote=1 parked=1 rewound=1 restored=1 resumed=1)
  if [ -z "$w" ]; then
    say "$k: warp 0 parked, restored, resumed == ccv-sim" "PASS (rows, predicates and lane PCs at its boundary)"
  else
    bad "$k swapped" "$w"
  fi
done
# The replay drain (TI-21): the demotion's squash sends a bulk discard, MIU
# ends each of the warp's loads in flight with a replay completion and
# orphans its DCU requests, and reports the warp ready to RAU once they are
# home. RAU restores only a ready warp (RAU spec rev 25), so the restored
# warp's replayed load hits (stall's one L1 hit; none without the swap).
# vadd4's discard orphans nothing: it is ready at once.
w=$(ok "$B/kernel_stall_swap.log" bulk_discard=1 replay=1 orphan=1 ready=1 l1_hit=1 provisional=0)
w2=$(ok "$B/kernel_vadd4_swap.log" bulk_discard=1 orphan=0 ready=1 restored=1)
if [ -z "$w$w2" ]; then
  say "replay drain: loads replayed, orphans home, then restored" "PASS (stall's replay hits; vadd4 ready at once)"
else
  bad "replay drain" "stall: $w; vadd4: $w2"
fi
rd() { CCV_RAU_DEMOTE=mlc "$SKEL" --kernel "build/oracle/$1/oracle.jsonl" --break "$2" >"$B/kernel_$1_$2.log" 2>&1; }
rd swap drop-replay
if [ "$(field "$B/kernel_swap_drop-replay.log" finished)" != 1 ]; then
  say "--break drop-replay: the demotion never drains" "PASS"
else
  bad "--break drop-replay" "a load with no completion drained anyway"
fi
rd swap replay-twice
if grep -q "^CHECK ooe: completion for rob tag [0-9]*, which is not in the ROB" "$B/kernel_swap_replay-twice.log"; then
  say "--break replay-twice: OOE refuses the second completion" "PASS"
else
  bad "--break replay-twice" "two completions for one load went unnoticed"
fi
rd swap no-ready
if [ "$(field "$B/kernel_swap_no-ready.log" finished)" != 1 ] &&
   [ "$(cover "$B/kernel_swap_no-ready.log" restored)" = 0 ]; then
  say "--break no-ready: RAU restores only a ready warp" "PASS"
else
  bad "--break no-ready" "a warp MIU never reported ready was restored"
fi
rd stall early-ready
if [ "$(cover "$B/kernel_stall_early-ready.log" l1_hit)" = 0 ]; then
  say "--break early-ready: the replay misses again" "PASS"
else
  bad "--break early-ready" "a restore before the orphans were home still hit"
fi
# A provisional restore (AR's revs 115-116, RAU spec rev 25; a knob,
# CCV_RAU_READY=0): with a free slot, no ready parked warp and no launch
# pending, RAU restores the oldest parked warp before its ready report
# (stall: 47 cycles sooner than waiting). Until the report it may demote again whenever a ready warp or a
# launch wants its slot, its P count starting at the report: provswap's
# warp 0, restored on a 1,000-cycle line, demotes again when warp 1's
# 250-cycle line lands first. OOE's thresholds are raised for provswap (a
# model setting), so only those two lines trigger, not the cold misses.
CCV_RAU_READY=0 CCV_RAU_DEMOTE=mlc "$SKEL" --kernel build/oracle/stall/oracle.jsonl \
  >"$B/kernel_stall_prov.log" 2>&1
w=$(ok "$B/kernel_stall_prov.log" provisional=1 prov_demote=0)
pv() { CCV_RAU_READY=0 CCV_OOE_CONFIG=demote_mlc_miss=150,demote_fallback=150 CCV_RAU_DEMOTE=mlc "$SKEL" \
         --kernel build/oracle/provswap/oracle.jsonl "$@"; }
pv >"$B/kernel_provswap_prov.log" 2>&1
w2=$(ok "$B/kernel_provswap_prov.log" provisional=2 prov_demote=1 restored=3)
if [ -z "$w$w2" ]; then
  say "provisional restores, one demoted for a ready warp" "PASS (stall; provswap's warp 0 == ccv-sim)"
else
  bad "provisional restore" "stall: $w; provswap: $w2"
fi
pv --break guard-at-restore >"$B/kernel_provswap_guard-at-restore.log" 2>&1
if [ "$(cover "$B/kernel_provswap_guard-at-restore.log" prov_demote)" = 0 ]; then
  say "--break guard-at-restore: the warp keeps the slot" "PASS"
else
  bad "--break guard-at-restore" "a provisional warp held to P from its restore still demoted"
fi
CCV_RAU_READY=0 rd stall demote-unwanted
if [ "$(cover "$B/kernel_stall_demote-unwanted.log" prov_demote)" -gt 0 ]; then
  say "--break demote-unwanted: demoted with nobody waiting" "PASS ($(cover "$B/kernel_stall_demote-unwanted.log" prov_demote) times)"
else
  bad "--break demote-unwanted" "a provisional warp is never demoted"
fi
# Evict, the default (DA, 2026-10-22): RAU demotes a warp its trigger names
# whether or not another wants the slot, as stall shows, four warps in four
# slots. Swap (CCV_RAU_MODE=swap) demotes only when one does: none in
# stall, and swap's warp 0 while its warps 4 and 5 wait to launch.
for k in stall swap; do
  CCV_RAU_MODE=swap CCV_RAU_DEMOTE=mlc "$SKEL" --kernel "build/oracle/$k/oracle.jsonl" \
    >"$B/kernel_${k}_swapmode.log" 2>&1
done
w=$(ok "$B/kernel_stall_swapmode.log" demote=0)
w2=$(ok "$B/kernel_swap_swapmode.log" demote=1 restored=1)
if [ -z "$w$w2" ] && [ "$(cover "$B/kernel_stall_swap.log" demote)" = 1 ]; then
  say "evict demotes regardless; swap only for a waiter" "PASS (stall: 1 and 0; swap: 1)"
else
  bad "evict and swap" "stall evict: $(cover "$B/kernel_stall_swap.log" demote); stall swap: $w; swap swap: $w2"
fi
# One row per register (TI-25 (1)): a restore map that gives two registers
# one row is refused by RCU.
rd swap restore-share
if grep -q "^CHECK rcu: warp [0-9]*'s restore map gives R1 and R2 one row" "$B/kernel_swap_restore-share.log"; then
  say "--break restore-share: RCU refuses a shared row" "PASS"
else
  bad "--break restore-share" "a restore map sharing a row was taken"
fi
# A refused demote (TI-25): OOE's fallback threshold lowered (a model
# setting) so brs's warp is demoted after its exit has retired.
ref() { CCV_OOE_CONFIG=demote_fallback=10 CCV_RAU_DEMOTE=fallback "$SKEL" --kernel build/oracle/brs/oracle.jsonl "$@"; }
ref >"$B/kernel_brs_refused.log" 2>&1
w=$(ok "$B/kernel_brs_refused.log" demote=1 refused=1 parked=0)
if [ -z "$w" ]; then
  say "brs: a demote after the exit is refused == ccv-sim" "PASS"
else
  bad "brs refused" "$w"
fi
ref --break ignore-refused >"$B/kernel_brs_ignore-refused.log" 2>&1
if grep -q "^CHECK rau: warp 0 drained after its exit retired" "$B/kernel_brs_ignore-refused.log"; then
  say "--break ignore-refused: RAU refuses the drained report" "PASS"
else
  bad "--break ignore-refused" "a refused demote was migrated"
fi

# A restore's controls: PCA's rows renumbered, so RCU writes each into
# another register (the final compare refuses it); and PCA's ack and PCs
# before its rows, so the restored warp reads a register before its row is
# written (RCU refuses the read: done means written, TI-13).
CCV_RAU_DEMOTE=mlc "$SKEL" --kernel build/oracle/swap/oracle.jsonl --break pca-row-order \
  >"$B/kernel_swap_pca-row-order.log" 2>&1
if [ "$(field "$B/kernel_swap_pca-row-order.log" gpr_mismatch)" -gt 0 ]; then
  say "--break pca-row-order: the restored warp ends wrong" "PASS ($(field "$B/kernel_swap_pca-row-order.log" gpr_mismatch) lanes)"
else
  bad "--break pca-row-order" "rows written to the wrong registers went unnoticed"
fi
CCV_RAU_DEMOTE=mlc "$SKEL" --kernel build/oracle/swap/oracle.jsonl --break early-restore-done \
  >"$B/kernel_swap_early-restore-done.log" 2>&1
n=$(grep -c "^CHECK rcu: seq [0-9]* reads row [0-9]* before its restore row is written" "$B/kernel_swap_early-restore-done.log")
if [ "$n" -gt 0 ]; then
  say "--break early-restore-done: RCU refuses the read" "PASS ($n reads)"
else
  bad "--break early-restore-done" "a restored warp read before its rows were written"
fi

# Parked state, held without restore (CCV_RAU_RESTORE=0, so a parked warp
# ends its run parked): the controls break the map OOE sends RCU, the order
# RCU sends PCA its rows in, the resume PC OOE reports, and the rewind beats'
# PCs; PCA filing two warps at one place; and every warp parked at once.
dem() { CCV_RAU_RESTORE=0 CCV_RAU_DEMOTE=fallback "$SKEL" --kernel build/oracle/stall/oracle.jsonl "$@"; }
# PCA files a warp at the place RAU names (TI-24 (1)): RAU naming one place
# twice is refused. It needs two warps parked, so OOE's fallback threshold
# is lowered for this run (demote_fallback, a model setting): mwmiss then
# parks all four, each matching ccv-sim, instead of how many the default's
# timing happens to park (vadd4 parked two, until OI-45 moved its timing),
# and RAU lets demotions overlap (CCV_RAU_CONCURRENT=1), where the
# environment's RAU runs one at a time.
CCV_RAU_RESTORE=0 CCV_RAU_CONCURRENT=1 CCV_OOE_CONFIG=demote_fallback=20 CCV_RAU_DEMOTE=fallback "$SKEL" \
  --kernel build/oracle/mwmiss/oracle.jsonl --break pca-place \
  >"$B/kernel_demote_pca-place.log" 2>&1
if grep -q "^CHECK pca: place 0 is already held, by warp" "$B/kernel_demote_pca-place.log"; then
  say "--break pca-place: PCA refuses a held place" "PASS"
else
  bad "--break pca-place" "a place named twice was filed: $(grep '^KERNEL' "$B/kernel_demote_pca-place.log")"
fi
log="$B/kernel_mwmiss_demote_all.log"
CCV_RAU_RESTORE=0 CCV_RAU_CONCURRENT=1 CCV_OOE_CONFIG=demote_fallback=20 CCV_RAU_DEMOTE=fallback "$SKEL" \
  --kernel build/oracle/mwmiss/oracle.jsonl >"$log" 2>&1
w=$(ok "$log" parked=4)
if [ -z "$w" ]; then
  say "mwmiss, every warp parked == ccv-sim" "PASS (4 places, each warp at its boundary)"
else
  bad "mwmiss, every warp parked" "$w"
fi
for spec in "corrupt-map:CHECK parked warp 0 R1 lane" "mig-row-order:CHECK parked warp 0 R0 lane" \
            "resume-pc:CHECK parked warp 0 resumes at" "rewind-pc:CHECK parked warp 0 lane 0 resumes at"; do
  brk=${spec%%:*}; want=${spec#*:}
  dem --break "$brk" >"$B/kernel_demote_$brk.log" 2>&1
  n=$(grep -c "^$want" "$B/kernel_demote_$brk.log")
  if [ "$n" -gt 0 ]; then
    say "--break $brk: the parked check refuses it" "PASS ($n)"
  else
    bad "--break $brk" "PCA's copy was not refused: $(grep '^KERNEL' "$B/kernel_demote_$brk.log")"
  fi
done

# DEC's decode fields (A-75, TI-1): OOE renames and waits on the sources
# src_valid marks, and nothing else, so a real read DEC hides is read stale.
# On vaddslow, whose b[i] lands long after a[i]: with DCU's misses in flight
# together, vadd's two loads land close enough that a hidden R9 is no longer
# stale by luck of timing, and the control would prove nothing.
"$SKEL" --kernel build/oracle/vaddslow/oracle.jsonl --break drop-src-valid >"$B/kernel_drop-src-valid.log" 2>&1
n=$(grep -c "^CHECK lane [0-9]*: seq 14 operand 1 (R9) " "$B/kernel_drop-src-valid.log")
if [ "$n" = 32 ] && [ "$(field "$B/kernel_drop-src-valid.log" check_failures)" = 32 ]; then
  say "--break drop-src-valid: seq 14 reads R9 stale" "PASS (32 lanes)"
else
  bad "--break drop-src-valid" "$n stale reads (want 32): $(grep '^KERNEL' "$B/kernel_drop-src-valid.log")"
fi
# Predicate logic's sources arrive renamed in imm: RCU reading DEC's
# qualifiers instead gets plog's P3 = !P1 | P2 wrong, and its own check, the
# guarded add's lanes and the final compare all say so.
"$SKEL" --kernel build/oracle/plog/oracle.jsonl --break arch-pred-srcs >"$B/kernel_arch-pred-srcs.log" 2>&1
if grep -q "^CHECK rcu: seq 7 P3 = ffffffff, oracle ffff00ff" "$B/kernel_arch-pred-srcs.log" &&
   [ "$(field "$B/kernel_arch-pred-srcs.log" pred_mismatch)" = 1 ] &&
   [ "$(field "$B/kernel_arch-pred-srcs.log" check_failures)" = 9 ]; then
  say "--break arch-pred-srcs: plog's P3 wrong" "PASS (RCU's check, 8 lanes' enable, the final P3)"
else
  bad "--break arch-pred-srcs" "a misnamed predicate source went unnoticed: $(grep '^KERNEL' "$B/kernel_arch-pred-srcs.log")"
fi

# Lane-local bypass (A-59, TI-8). With OOE's bypass on, a lane op's
# dependant issues CCV_LAT_LANE_BYP after it, before the result reaches
# RCU's register file: RCU names the producer's slot and age in operand_byp
# and the lane forwards its own result. The lanes answer at the contract, so
# a dependant that took the register file's value instead would read it
# stale. Every kernel must pass so with bypass alone, and with both modes
# off; byp forwards four operands, a third operand among them, and merge a
# merge_data. With both off nothing forwards. (byp forwarded five while
# full-width lane ops could co-issue; at one a cycle, TI-9, tid's third
# reader, seq 8, issues after tid's write lands and reads the register file.)
for k in $(ls build/oracle); do
  for cfg in bypass=1,l1_spec=0 bypass=0,l1_spec=0; do
    log="$B/kernel_${k}_${cfg//[=,]/_}.log"
    CCV_OOE_CONFIG=$cfg "$SKEL" --kernel "build/oracle/$k/oracle.jsonl" >"$log" 2>&1
    why=""
    for kv in finished=1 order=ok gpr_mismatch=0 pred_mismatch=0 mem_mismatch=0 check_failures=0 class_violations=0 violations=0; do
      [ "$(field "$log" "${kv%%=*}")" = "${kv#*=}" ] || why="$why ${kv%%=*}=$(field "$log" "${kv%%=*}")"
    done
    [ -z "$why" ] || bad "$k with $cfg" "${why# }"
  done
done
log="$B/kernel_byp_bypass_1_l1_spec_0.log"
nbyp=0; noff=0
for k in $(ls build/oracle); do
  [ "$(cover "$B/kernel_${k}_bypass_1_l1_spec_0.log" lane_byp)" -gt 0 ] && nbyp=$((nbyp + 1))
  [ "$(cover "$B/kernel_${k}_bypass_0_l1_spec_0.log" lane_byp)" = 0 ] || noff=$((noff + 1))
done
if [ "$(cover "$log" lane_byp)" = 4 ] && [ "$(cover "$log" copy)" = 1 ] && [ "$noff" = 0 ]; then
  say "every kernel with bypass alone, and both off" "PASS (forwarding in $nbyp kernels; byp's 4; none with both off)"
else
  bad "byp with bypass" "$(grep -E '^(KERNEL|COVER)' "$log" | xargs)"
fi
bctl() { CCV_OOE_CONFIG=$1 "$SKEL" --kernel "build/oracle/$2/oracle.jsonl" ${3:+--break "$3"} >"$B/kernel_$4.log" 2>&1; }
# RCU never names the producer: each forwarded operand is the stale value
# RCU read, on all 32 lanes, and nothing replays it.
bctl bypass=1 byp no-lane-bypass no-lane-bypass
n=$(grep -cE "^CHECK lane [0-9]+: seq (6 operand 0|7 operand 1|9 operand 0|10 operand 2) " "$B/kernel_no-lane-bypass.log")
if [ "$n" = 128 ] && [ "$(field "$B/kernel_no-lane-bypass.log" check_failures)" = 128 ]; then
  say "--break no-lane-bypass: forwards read stale" "PASS (4 operands x 32 lanes)"
else
  bad "--break no-lane-bypass" "$n stale reads (want 128): $(grep '^KERNEL' "$B/kernel_no-lane-bypass.log")"
fi
bctl bypass=1 merge no-lane-bypass no-lane-bypass-merge
if [ "$(grep -c "^CHECK lane [0-9]*: seq 5 merge_data " "$B/kernel_no-lane-bypass-merge.log")" = 16 ]; then
  say "  ...and merge's merge_data" "PASS (its 16 switched-off lanes)"
else
  bad "--break no-lane-bypass (merge)" "the merge_data forward was not missed: $(grep '^KERNEL' "$B/kernel_no-lane-bypass-merge.log")"
fi
# An OOE bypassing a cycle faster than CCV_LAT_LANE_BYP: RCU refuses each
# dependant it meets three cycles behind its producer. Two do: with one RCU
# op a cycle (TI-9) byp's five immediates issue in turn, so seq 6 waits on
# R2's movi rather than on tid, and seq 7 follows it.
bctl bypass=1,lat_lane_byp=3 byp "" early-bypass
n=$(grep -cE "^CHECK rcu: seq [0-9]+ reads operand [0-9] 3 cycles after its lane producer; CCV_LAT_LANE_BYP is 4" "$B/kernel_early-bypass.log")
if [ "$n" = 2 ] && [ "$(field "$B/kernel_early-bypass.log" check_failures)" = 66 ]; then
  say "an OOE bypassing at 3: RCU refuses it" "PASS (2 dependants; their 64 lane reads stale)"
else
  bad "an OOE bypassing at 3" "$n refusals (want 2): $(grep '^KERNEL' "$B/kernel_early-bypass.log")"
fi

# Sectioned lanes (OI-28 to OI-33, TI-9). ccv_ooe_rcu_issue is one slot per
# select resource, S0-S3, P0-P3 and R, and co-issued footprints are disjoint
# (V-60), which OOE's sectioned select (OI-31) guarantees by construction.
# no-resource-cap makes the model grant a second lane op and a second memop
# onto resources already held (inject_double_grant): a second op claims a
# group already held, and RCU refuses every slot the two share: the lane
# sections for one pair, the pipes for three more. (Two more until MIU was
# pipelined, AR-19: vadd's memops now complete sooner, so a third pair is
# ready to issue together. 12 slots then, 16 now.)
"$SKEL" --kernel "$K" --break no-resource-cap >"$B/kernel_no-resource-cap.log" 2>&1
log="$B/kernel_no-resource-cap.log"
if grep -q "^CHECK rcu: V-60: seq 3's footprint 1111 overlaps seq 2's at S0" "$log" &&
   grep -q "^CHECK rcu: V-60: seq 6's footprint 1111 overlaps seq 4's at P0" "$log" &&
   [ "$(grep -c "^CHECK rcu: V-60: " "$log")" = 16 ]; then
  say "--break no-resource-cap: RCU refuses the overlap" "PASS (V-60: 4 pairs, 16 slots, sections and pipes)"
else
  bad "--break no-resource-cap" "$(grep -c "^CHECK rcu: V-60: " "$log") overlaps refused (want 16): $(grep '^KERNEL' "$log")"
fi
# A register is a row and a position; a 32-bit one fills its row from 0.
# OOE naming one at position 1 overruns the row: RCU refuses it, the lanes
# refuse the destination, and the next reader of it reads it stale.
"$SKEL" --kernel "$K" --break bad-pos >"$B/kernel_bad-pos.log" 2>&1
log="$B/kernel_bad-pos.log"
if grep -q "^CHECK rcu: seq 2's destination, a 32-bit register at position 1, overruns its row" "$log" &&
   [ "$(grep -c "^CHECK lane [0-9]*: a full-width op whose sections, operands or destination disagree" "$log")" = 32 ]; then
  say "--break bad-pos: RCU and the lanes refuse it" "PASS (seq 2's destination; 32 lanes)"
else
  bad "--break bad-pos" "a register past its row went unnoticed: $(grep '^KERNEL' "$log")"
fi
# A memop's pipe footprint is its width's span from its position (OI-33):
# four pipes at 32 bits. One pipe for each of vadd's memops, MIU refuses all.
"$SKEL" --kernel "$K" --break narrow-pipes >"$B/kernel_narrow-pipes.log" 2>&1
log="$B/kernel_narrow-pipes.log"
n=$(grep -c "^CHECK miu: rob tag [0-9]* has pipes 1, but a 32-bit memop at position 0 takes f" "$log")
if [ "$n" = 8 ] && [ "$(field "$log" check_failures)" = 8 ]; then
  say "--break narrow-pipes: MIU refuses each memop" "PASS (8 memops)"
else
  bad "--break narrow-pipes" "$n refusals (want 8): $(grep '^KERNEL' "$log")"
fi

"$SKEL" --kernel "$K" --break ordering-on-load >"$B/kernel_ordering-on-load.log" 2>&1
log="$B/kernel_ordering-on-load.log"
n=$(grep -c "^CHECK dec: pc 0x[0-9a-f]* has ordering 1 but is not a fence" "$log")
m=$(grep -c "^CHECK miu: rob tag [0-9]* has ordering 1 but is not a fence" "$log")
# OOE's model holds V-36 as an input assumption too (OI, dbe8acd).
o=$(grep -c "^CHECK ooe: V-36: uop seq [0-9]* carries ordering 1 on mem_op 0, not a fence" "$log")
if [ "$n" = 7 ] && [ "$m" = 7 ] && [ "$o" = 7 ] && [ "$(field "$log" check_failures)" = 21 ]; then
  say "--break ordering-on-load: DEC, OOE and MIU refuse" "PASS (7 loads each)"
else
  bad "--break ordering-on-load" "$n DEC, $o OOE and $m MIU refusals (want 7 each): $(grep '^KERNEL' "$log")"
fi

"$SKEL" --kernel "$K" --break memop-ordering >"$B/kernel_memop-ordering.log" 2>&1
log="$B/kernel_memop-ordering.log"
n=$(grep -c "^CHECK miu: rob tag [0-9]* has ordering 1 but is not a fence" "$log")
o=$(grep -c "^CHECK ooe: V-36: uop seq [0-9]* carries ordering 1 on mem_op 0, not a fence" "$log")
if [ "$n" = 7 ] && [ "$o" = 7 ] && [ "$(field "$log" check_failures)" = 14 ]; then
  say "--break memop-ordering: OOE and MIU refuse each" "PASS (7 loads)"
else
  bad "--break memop-ordering" "$n MIU and $o OOE refusals (want 7 each): $(grep '^KERNEL' "$log")"
fi

# -- backpressured channels (AR's response TI-22) -------------------------------
# A channel whose receiver may hold behind a stall (schema: backpressure) is
# held to CCV_P_TIMEOUT_BP, a watchdog; what it measures is reported here, the
# longest any message waited in one of its slots in any kernel, so a kernel
# near the watchdog shows as a sizing signal before it is a failure.
bp=$(cat "$B"/kernel_*.log 2>/dev/null | sed -n 's/^BPAGE \([^ ]*\) max=\([0-9]*\) watchdog=\([0-9]*\)$/\1 \2 \3/p' |
     sort -k1,1 -k2,2n | awk '{m[$1]=$2; w[$1]=$3} END {for (c in m) printf "%s %d of %d; ", c, m[c], w[c]}')
if [ -n "$bp" ]; then
  say "backpressured channels: longest wait" "PASS (${bp%; })"
else
  bad "backpressured channels: longest wait" "no BPAGE line in any kernel's log"
fi

# -- out of order (Daniel, 2026-10-21) -----------------------------------------
# A suite of hazard-free kernels runs the OOE as an in-order machine and
# passes whatever its reordering does. So every kernel's trace is measured
# (tools/check-ooo.py, over retired instructions): how many issued ahead of
# an older instruction of their warp, and how deep. The suite must reach its
# floor, and each kernel written to force reordering its own bounds (OOO_WANT,
# step 2). The control: the same traces held in program order, as an
# in-order machine would at best issue them, must fail the floor.
# The floor sits below today's suite (ahead 69, depth 9, 12 kernels), so a
# timing change has room; the bounds below are the kernels' purpose.
OOO_FLOOR="ahead=50,depth=6,kernels=10"
OOO_STALLED=(
  "stall:0:300"                # warps 1 to 3 finish well before warp 0's slow line
)
OOO_WANT=(
  "chains:ahead>11 depth>6"    # the pairs behind a chain of eight adds
  "missrun:ahead>15 depth>3"   # twenty instructions under a miss and its chain
  "ldpar:ahead>3"              # four hits ahead of a miss's dependant
  "mlp:ahead>5 depth>4"        # each iteration's load ahead of the last's add
  "mwmiss:ahead>30"            # four warps' work past each warp's miss
  "stall:ahead>50"             # the other warps', and warp 0's own, under its miss
)
ooo_traces=""
for d in test/kernels/*/; do
  k=$(basename "$d")
  "$SKEL" --kernel "build/oracle/$k/oracle.jsonl" --trace "$B/ooo_$k.ccvtrace" >"$B/ooo_$k.log" 2>&1
  ooo_traces="$ooo_traces $B/ooo_$k.ccvtrace"
done
want_args=()
for w in "${OOO_WANT[@]}"; do want_args+=(--want "$w"); done
for w in "${OOO_STALLED[@]}"; do want_args+=(--stalled "$w"); done
if out=$(python3 tools/check-ooo.py --floor "$OOO_FLOOR" "${want_args[@]}" $ooo_traces 2>&1); then
  say "kernels issue out of order" "PASS ($(sed -n 's/^OOO suite //p' <<<"$out"))"
else
  bad "kernels issue out of order" "$(grep -m3 '^OOO FAIL' <<<"$out" | sed 's/^OOO FAIL //' | xargs)"
fi
# The stall bound's control: DCU one miss at a time, so the other warps' fast
# misses wait behind warp 0's slow line, and they finish after it.
"$SKEL" --kernel build/oracle/stall/oracle.jsonl --break dcu-one-miss \
  --trace "$B/ooo_stall-blocking.ccvtrace" >"$B/kernel_dcu-one-miss.log" 2>&1
if out=$(python3 tools/check-ooo.py --stalled stall-blocking:0:300 "$B/ooo_stall-blocking.ccvtrace" 2>&1); then
  bad "--break dcu-one-miss: the stall bound fails" "passed: $(grep '^OOO stall' <<<"$out")"
elif [ "$(field "$B/kernel_dcu-one-miss.log" gpr_mismatch)" = 0 ]; then
  say "--break dcu-one-miss: the stall bound fails" "PASS ($(grep -m1 '^OOO FAIL' <<<"$out" | sed 's/^OOO FAIL stall-blocking: //'))"
else
  bad "--break dcu-one-miss" "the run itself went wrong: $(grep '^KERNEL' "$B/kernel_dcu-one-miss.log")"
fi
if out=$(python3 tools/check-ooo.py --in-order --floor "$OOO_FLOOR" "${want_args[@]}" $ooo_traces 2>&1); then
  bad "--in-order: the same traces in program order" "passed the floor: $(sed -n 's/^OOO suite //p' <<<"$out")"
elif grep -q '^OOO suite ahead=0 depth=0 kernels=0 ' <<<"$out"; then
  say "--in-order: the same traces in program order" "PASS (fails the floor: nothing reordered)"
else
  bad "--in-order: the same traces in program order" "reordered still: $(sed -n 's/^OOO suite //p' <<<"$out")"
fi

exit $fail
