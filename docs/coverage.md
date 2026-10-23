# Kernel coverage plan

What the S1/S2 kernels exercise, what they do not, and the order the gaps
close in. A kernel here is a hand-written `.s` in `test/kernels/<k>/` (or a
compiler-corpus kernel named by `SOURCE=`), run on the functional stubs
against ccv-sim's oracle by `tools/check-kernel.sh` and on the SV-hosted top
by `tools/check-sv-hosted.sh`. Each claim below has a negative control or a
coverage count in the gate; a kernel that only "passes" proves nothing about
a path it never reached.

**Coverage counts.** The stubs count named bins where each path is taken,
and every run prints them on a `COVER` line beside `KERNEL`: redirects,
checkpoint frees, cycles FET stalled with every checkpoint live, the most
checkpoints live at once, merges, copy-only ops, zero-register reads,
physical registers reallocated after a free, memops touching more than one
line, the most lines one memop touched, store lines with a partial byte mask,
store lines written whole, without a read of the line first (`full_line`),
cycles MIU waited for a DCU request id, loads completed as L1 hits at the
contract (`l1_hit`) or hit but too late for it (`l1_late`), reads DCU answered
as hits while a miss was in flight or waiting (`hit_under_miss`), and instructions a
lane executed twice because OOE cancelled and replayed them (`reexec`). `tools/check-kernel.sh` holds
each kernel to the bins it exists for, so a stub change that stops reaching
a path fails the gate rather than passing it vacuously. The SV-hosted run
must print the same `COVER` line as the C++ one.

## Where coverage stands

| Area | Kernels | What is reached (gate bins) | Control |
|---|---|---|---|
| Straight-line ALU, loads, stores | vadd, srd, sel | one line per warp access, aligned; a correctly predicted branch frees its checkpoint (`ckpt_free=1`); a store covering its whole line is written without DCU reading the line first (`full_line=1`, AR-19) | vadd's eleven |
| Guarded writes and merge under rename | merge, pguard | GPR merge through a lane, predicate merge in RCU, zero registers (`merge=4 zero_read=2`) | wrong-merge, dirty-zero, ignore-mask |
| Masked loads | mload | the copy-only op (A-38), its landing contract (`copy=2`) | skip-copy, copy-from-new, late-copy |
| Warp access not line-aligned | unal | two lines per access, split at lanes 27, 1 and 15; a store's partial byte mask on two lines (`line_split=3 partial_line=2`), each merged into the line DCU reads, so the four words beside it that it never writes keep their values | one-line, skip-read-partial |
| Scattered lane addresses | gather | one line per lane: 32 line requests for one memop, MIU waiting on DCU request ids and reusing them (`lines_peak=32 dcu_id_wait>0`); reversed order within a line; broadcast; a store with a 4-byte mask in each of 32 lines; with memops in flight together, two reads DCU answers as hits while another is missing (`hit_under_miss=2`) | (MIU's per-lane address and data checks) |
| Branch mispredicts (redirect, checkpoint restore) | loop, brs | a backward branch mispredicted 99 times, then a correct fall-through (`redirect=99`); a uniform taken forward branch | drop-negate, corrupt-ckpt, stale-free |
| Rename free list wrapping | loop | about 200 writes against 192 registers (`reg_reuse>0`) | free-new |
| L1 hits at the contract (A-46, OI-5) | hit | DCU holds lines (a small direct-mapped array); MIU completes a load whose lines all hit at exactly `CCV_LAT_L1_CMPL` after OOE issued it, data and completion together, and anything later is the miss indication. Four pointer-chasing hits on time (`l1_hit=4`) | early-hit, late-hit-data |
| L1 hits too late for the contract, and on time under a miss (A-46) | late | two loads of one line, back to back and independent: the first misses and fills it, and the second finds it only after the fill, past `CCV_LAT_L1_CMPL`, so MIU completes it as a miss (`l1_late=1`); a third, chasing the second's result, hits on time. Then a load of a second line misses, and one of the first line issues a cycle behind it: MIU holds up to `CCV_MIU_PIPES` memops in flight (AR-19), so it reaches DCU during the miss and hits on time under it (`l1_hit=2 hit_under_miss=1`). An MIU that serialised its memops again would make that load late too (`l1_hit=1 l1_late=2`, gather's two hits under a miss gone), which the pinned bins refuse | (the bins; MIU's contract timing, as hit's) |
| L1 speculation (OOE's `l1_spec`) | every kernel | on by default (OI-5), and each kernel passes again with it alone and with both modes off: the dependants of a load woken at `CCV_LAT_L1_WAKE` and replayed on a miss: RCU's register read sees the same cycle's write, and a lane judges a replayed op on its last execution (`Kernel::failHeld`); hit replays its miss's dependant (`reexec=1`) | no-rcu-bypass, late-hit-data |
| Lane-local bypass (OOE's `bypass`; A-59, TI-8) | every kernel; byp, merge | on by default (OI-5), and each kernel passes again with it alone and with both modes off, lane dependants woken at `CCV_LAT_LANE_BYP`: the lanes answer at `CCV_LAT_LANE`, so the dependant reads the register file before the write, RCU names the producer's lead section and age in `operand_byp`, and the lane forwards its own result. byp forwards four operands, MADLO's third among them (`lane_byp=4` with the bypass, `lane_byp=0` with both modes off; five while full-width lane ops could co-issue, before one lane op a cycle); merge forwards a merge_data. Not reached: a forward into a masked load's copy-only op, since OOE issues a memop and its copy only on confirmed sources (V-17) | no-lane-bypass; an OOE bypassing at 3, which RCU refuses |
| Decode-free scheduling (A-75, TI-1) | every kernel; plog | OOE renames and waits on the sources DEC's `src_valid` marks, reads guard or data from `pred_use`, and takes exit and `srd`'s identity from `sched_attr` and `imm_kind`, never from `opcode`. Predicate logic reaches RCU with its two sources renamed in `imm`: plog computes P3 = !P1 \| P2 from real values and guards an add with it (`merge=3`) | drop-src-valid (vadd), arch-pred-srcs (plog) |
| Checkpoint pressure | brs | five unresolved branches against `CCV_P_BR_CKPTS` = 4: FET stalls until a free (`ckpt_peak=4 ckpt_full>0 ckpt_free=5`) | |
| Out-of-order issue (Daniel, 2026-10-21) | chains, missrun, ldpar, mlp, mwmiss, stall; every kernel | a younger instruction issues ahead of an older one of its warp, measured from each kernel's trace over the instructions that retire (`tools/check-ooo.py`): chains' pairs pass a chain of eight dependent adds; missrun's twenty instructions issue under a miss and its three dependants; ldpar's four loads hit ahead of a miss's dependant (`hit_under_miss=4`); mlp's four unrolled iterations each load ahead of the last's add, the misses in flight together. Each holds its own bounds, and the suite a floor (ahead 50, depth 6, ten kernels) | in-order: the same traces held in program order fail the floor |
| Several warps at once (Daniel, 2026-10-21) | mwmiss, stall, vadd4 | ccv-sim runs one warp a CTA, so a kernel of several warps is several CTAs (`CTAS` in kernel.cfg, one oracle a warp), which RAU launches side by side, one a tier-1 slot: they share FET's fetch, DEC, rename, the RS, issue and memory, and each warp's registers are compared with its own run, the memory with all of theirs. An instruction's identity carries its warp in the sequence's top bits. mwmiss: four warps, each missing on a line of its own, 45 instructions issued past their warps' misses; vadd4: vadd over four CTAs, which fills the decode queue, so DEC's uops wait in their slots on rename, held to CCV_P_TIMEOUT_BP as a backpressured channel and their longest wait reported (AR's response TI-22); both hosts agree event for event | (the per-warp compare; OOE's per-warp order, which takes a slot's head only if it is its warp's oldest uop) |
| Notices and the completion's RS echo (OA-23; AR's response TI-23) | vadd, mlp | DCU notices a refill on ccv_dcu_miu_fill_ntc, CCV_LAT_FILL_NOTICE cycles ahead of it, holding its slot's credit and its line busy until it leaves; MIU, on a notice for a load's last line, hints OOE on ccv_miu_ooe_cmpl_hint CCV_LAT_CMPL_HINT cycles ahead of the completion, which leaves on that cycle on the credits it held back for it and its data. vadd: 3 notices, 3 hints; mlp: both. The bank's ccv_common_chk_notice holds every promise, slot by slot. Every completion echoes its memop's rs_idx, which OOE checks per rob tag | late-refill, notice-wrong-id, late-cmpl, hint-wrong-tag (vadd): on_time or same_keys on the broken notice; rs-echo (vadd): OOE refuses all 8 completions |
| The swap: demotion, PCA, restore (TI-24; Daniel, 2026-10-21) | stall, swap (six warps, four slots), every kernel with CCV_RAU_DEMOTE=mlc | OOE reports a head load outstanding past CCV_DEMOTION_THRESHOLD_MLC (Q18, AR's rev 101) and RAU demotes it, one at a time. OOE squashes to retirement, sends FET its rewind beats and RCU its map, waits for the drain and reports drained. RAU sends the three migration commands, each with PCA's place; RCU's rows (one per architectural register, no merging, TI-25 (1)), FET's per-lane PCs and RAU's command reach PCA, which acks, and RAU frees the slot. A free slot goes to the oldest ready warp, a launch, then a parked warp: restore-allocate, the three commands in, PCA's rows written by RCU and its PCs to FET, the ack once every row's credit is home, then restore-activate. A parked warp is checked at its park: rows, predicates and each lane's PC against ccv-sim after what it retired. Restored, it ends where ccv-sim does. Each warp's registers are compared as it exits, since a reused slot reallocates them. The SV top agrees event for event (stall, vadd4, swap). The parked-state runs keep warps parked (CCV_RAU_RESTORE=0) | pca-row-order and early-restore-done (swap): the final compare, and RCU refusing a read before its restore row is written; corrupt-map, mig-row-order, resume-pc, rewind-pc (stall, parked): the parked check; pca-place (mwmiss, overlapping demotions): PCA refuses a held place |
| The replay drain, a provisional restore and a refused demote (TI-21, TI-25) | stall, vadd4, provswap (OOE's thresholds at 150), every kernel with CCV_RAU_DEMOTE=mlc; brs with OOE's fallback threshold at 10 | A demotion's squash sends a bulk discard of the whole ROB. MIU ends each load of the warp it covers with one replay completion (status 2): one not started, or one in flight, whose DCU requests become orphans, their responses dropped. A load already hinted completes as promised. MIU counts orphans per warp and reports the warp ready on ccv_miu_rau_ready as the count returns to zero, or at once when the discard orphans nothing (vadd4); RAU restores only a ready warp (RAU spec rev 25), and stall's replayed load hits. RAU evicts (DA, 2026-10-22): it demotes a warp its trigger names whether or not another wants the slot; CCV_RAU_MODE=swap demotes only when a ready parked warp or a launch waits. With CCV_RAU_READY=0 (AR's revs 115-116, a knob: about 1% lost on OI's sweep), a slot that would otherwise idle, with no ready parked warp and no launch pending, takes the oldest parked warp provisionally: stall finishes 47 cycles sooner. A provisional warp may demote again whenever a ready warp or a launch wants its slot, and its P count starts at its ready report: provswap's warp 0, on a 1,000-cycle line, demotes again when warp 1's 250-cycle line lands first. A demote landing after the warp's exit retired is refused: drained with refused = 1, no migration, and the exit frees the slot | drop-replay, replay-twice, no-ready (swap): no drain, OOE refuses the second completion, the warp stays parked; early-ready (stall): the replay misses again; guard-at-restore (provswap): the provisional warp keeps its slot; demote-unwanted (stall): it demotes with nobody waiting; ignore-refused (brs): RAU refuses the drained report; restore-share (swap): RCU refuses a restore map giving two registers one row |
| A warp stalled on a long miss (Daniel, 2026-10-21; TI-21) | stall | warp 0's line is in the testbench's slow region (0x80000 up, 400 cycles); warps 1 to 3 share the machine with it and finish by cycle 157, warp 0 at 542: they fill its hole rather than wait it out. Held as a bound (`tools/check-ooo.py --stalled`: the others at least 300 cycles before it). DCU keeps up to sixteen misses in flight (`CCV_P_W_REQ_DCU_MLC`), each by its req_id, so a fast miss does not wait behind a slow one; with it blocking, the three finished after warp 0 | dcu-one-miss: DCU one miss at a time, and the others finish after warp 0 |
| Divergence and O-60's fairness (IS-17 (b); FET spec rev 16) | div, spinwait | FET holds each lane's PC, its live lanes and the fairness pointer and counter, and picks every group itself: the lowest PC, except that once lane r's group has gone CCV_FAIR_N picks without issuing it picks that group. ccv-sim's record checks each pick (gen-oracle runs it at the same N). A divergent branch splits its group at the redirect, the taken lanes to the target and the rest to the fall-through, and groups reconverge where their PCs meet. FET marks the exit whose fetch clears the warp's last live lanes, and OOE ends the warp when that uop retires (TI-27). RAU names the launch's lanes, and the live mask migrates with the PCs, as FET holds it after the demotion's beats. div: an if/else that splits the warp in halves and reconverges, then a loop each lane runs tid + 1 times, one split an iteration, with the leavers waiting at the exit until the rule picks them (`split=32 reconverge=2 groups_peak=2 fair_pick=1`). spinwait: lane 0 spins on a flag lane 1 sets at a higher PC, which hangs under strict min-PC; the rule picks lane 1's group (`fair_pick=4 groups_peak=3`), and lane 0's flag load waits behind lane 1's older store until it commits (`st_ld_wait`; MIU forwards nothing) divtail runs div's code with 20 threads: lanes 20-31 never issue (`split=20`). divtail2 runs it over one CTA of 52 threads, two warps (ccv-sim -warp, TI-29): RAU's mask is per warp, so warp 1 launches with lanes 0-19 and srd gives them threads 32-51 (`split=51`). With the swap on, every restored warp's picks that departed from ccv-sim's are printed as order_diff, per kernel (AR's rev 134; none yet). | early-mark (div): the warp ends at its first partial exit; whole-cta-mask (divtail2): warp 1 launches with 32 lanes and picks lanes ccv-sim never issued; beats-dead (stall, swapped): FET parks a mask without the beats' lanes, refused against the boundary's; fair-off, fair-late (div): FET refuses ccv-sim's pick at seq 82; split-swap (div): the first split's lanes go the wrong way; no-st-wait (spinwait): the load reads the flag still clear; ccv-sim at -fairness=0 runs spinwait to its step limit |
| F-RO: stores into read-only memory (AR's responses TI-26; O-51, O-61) | roconst, rolimit, rolaunch, rogated, roload | RAU sends each CTA's .const range on ccv_rau_miu_cta (from the launch, until Q-50's descriptor). MIU refuses a store any of whose lanes' four bytes lie in that range or in the launch window, window 2: it completes the store as a fault (status 1, cause 8, the faulting lanes, the lowest one's address) and writes nothing. OOE takes the fault at retirement, and CRU's stub holds it to ccv-sim's cause, pc, lanes and address (its oracle ends with the faulting instruction's record and the state after the rollback, TI-28). roconst: lane 0 inside the range, lane 1 straddling its limit; rolimit: a store at the limit less 4 faults, one at the limit does not; rolaunch: every lane, with no .const range; rogated: only the lanes that execute the store, after a split; roload: loads never fault (`ro_fault`, `fault`). The final state is ccv-sim's after the rollback, so no lane's store landed | no-ro (roconst): MIU's check dropped, its 32 stores land and the warp never faults |
| Launch-slot memops and a per-lane base (AR's responses TI-31, TI-32; ISA O-45, O-30) | slotform | DEC decodes Format D's launch-slot form into slot_form and arg_slot, which OOE copies to ccv_ooe_miu_memop unexamined. MIU forms the address from the slot's window, the word at the CTA's launch block + 32 + 8k (launch_block_addr on ccv_rau_miu_cta), held in a table per CTA slot and filled a line at a time on first use: a memop whose window is not yet valid waits for the line, an L1 miss. The table clears on the slot's ccv_rau_miu_cta and on a kill. Every other memop's base is per lane, base_per_lane on ccv_rcu_miu_addr. slotform: slots 0 and 13 sit in the two lines of the block's slot area, so two fills (`window_fill=2`), four slot memops (`slot_form=4`), none a hit (`l1_hit=0`); R6 is a window per lane, an O-30 frame pointer's shape, so its store and load take 32 lines each (`frame_lookups=64`, the DCU lookups of accesses whose lanes span windows, AR-23's measure; `dcu_lookups` counts them all) | no-window-fill, window-from-base: the window taken as zero or from base_per_lane, and every lane of the first load reads window 0; scalar-base: lane 0's base on every lane, and lanes 1-31's store and load land in lane 0's window |
| srd #2, %lanectx (ISA v1.9 O-64; OA's and IS's responses TI-33) | lanectx, lanectx2 | DEC decodes srd selector 2 into imm_kind 4; OOE substitutes ((CCV_P_CORE_ID << CCV_W_WARP_ID) \| hardware warp context) << 5, the context being warp_id, and the lane ORs its index. lanectx: one CTA of two warps, so warp 1's context is 1 on the core and in ccv-sim (-warp 1), and its lanes read 32-63. lanectx2: the same code over two one-warp CTAs, each warp 0 of its CTA, so srd #0 would read 0-31 in both while srd #2 reads CTA 1's context. gen-oracle passes ccv-sim -context w, the warp_id RAU gives run w (TI-35), and the loader refuses a run of another context | lanectx-literal: imm_kind sent as a literal, no substitution, and 48 of the 64 lanes refuse; lanectx-as-ctatid (lanectx2): srd #2 taken as srd #0, and CTA 1's 32 lanes refuse; lanectx2's CTA 1 rerun at -context 0 is refused at load |
| Predicate transfers, ld.pred and st.pred (ISA O-19, O-62, O-63; AR's and OA's responses TI-36; MIU spec rev 25) | predspill, predmerge, predlane, predswap | DEC cracks a mask into one uop per predicate (mem_op 4 or 5, uop k at disp + 4k, sharing the instruction's id but for its sub field), and an instruction retires with its last uop. MIU takes one address from lane 0's base, whether or not lane 0 is active. A load returns its word as pred_result, written under active_mask, its copy merging the inactive lanes in RCU from the old predicate (OOE makes the copy for a masked load with any destination). A store carries its predicate's word in store_data's lane 0, completes at execute and drains after commit as a read-merge-write, new = (old & ~m) \| (d & m). predspill (CP's): a three-predicate mask, single-predicate spills and a reload (`pred_merge=6`). predlane: lanes 16-31 store with a non-uniform rbase, which must be lane 0's, merging only their bits. predmerge (CP's): a partial reload and store, the reload's copy a predicate-only one naming no GPR, the zero register (TI-37; `pred_copy=1`). predswap: two-predicate transfers in a loop; CCV_RAU_DEMOTE=at:57, from a sweep, demotes it between a st.pred's uops (`crack_split=1`) and it resumes at the instruction | drop-pred-copy, ldpred-whole-word (predmerge): the reload loses lanes 16-31; stpred-whole-word (predlane): lanes 0-15's bits land too; xfer-low-lane (predlane): window 25 for 9; pdata-guard (predlane): st.pred's predicate as a guard keeps memory's ones; resume-mid (predswap at:57): it resumes past the split instruction |
| The kill (V-24; RAU spec, Kill; IS-2) | rokill, and every ro kernel | A fault OOE takes at retirement reaches RAU as fault_taken, and RAU kills the context: kill_valid, then a cycle later the mask of every valid warp context, resident, moving or parked, with an epoch, broadcast to FET, DEC, OOE, RCU, MIU, SPM, SYU and PCA; nothing more launches. Each drops the killed warps' state (FET stops them and frees their slots, DEC drops their queued uops, OOE's model squashes, sends FET its epoch notice and releases them, PCA drops their contexts) and acks at the epoch once quiesced, a level; RAU counts an ack only at its own epoch, and frees its tables once all eight are in. The fabric runs in both hosts: the C++ machine's registered fabric state, and the SV-hosted shims' kill ports through DPI. rokill: CTA 0 faults, CTAs 1-3 are mid-loop, and the kill stops them (`kill=1`); a warp it cut short is held to a prefix of its run, the faulted one to its state at the fault | no-kill: the faulted warp is never killed; withheld-ack (MIU) and stale-ack (FET, the epoch before): the kill never completes, naming the block |

## What is not reached, and why

1. **Wrong-path execution.** FET predicts not-taken, and the stub fetches
   nothing past a branch it will mispredict (it has no oracle record for the
   wrong path). So a mispredict today exercises the redirect and the
   checkpoint restore, but no squash: no wrong-path uop is renamed, issued or
   discarded, no RAT is recovered, no store is discarded. MIU's bulk
   discard (A-41) runs only as a demotion's, which takes loads, never a
   store (TI-21). The interface gap is closed (A-70, applied:
   every uop carries a 3-bit fetch epoch, and OOE drops stale ones before
   rename, `--break stale-epoch` as the control); what remains is stub work,
   step 1 below.
2. **A restored diverged warp's order (TI-27 (c)).** FET cannot know the
   fairness state at a demotion's boundary, so it saturates the counter
   (AR's response TI-27), and the first pick after the restore may go to a
   group ccv-sim picked later. Checking that order per lane needs
   instructions ccv-sim never issued, which a trace-driven FET cannot fetch;
   so a restored warp that departs follows ccv-sim's group, counted
   (`order_diff`), and no kernel departs yet. Barriers and sleeps, whose
   lanes wait out of the pick, have no kernel; FET fails on a barrier's
   record. CP's spinwait, as the compiler snapshot assembles it, uses
   launch-block slot addressing, which MIU's stub does not form, so the
   core's spinwait is the same shape in fixed windows.
3. **A lane's word split across lines.** ccv-sim accepts a 4-byte access at
   any byte address. Whether the ISA does is deferred to the ISA track
   (Review A-71); the MIU stub assumes a lane's word lies in one line. If it
   is legal, such an access cannot meet the L1 contract and completes late
   (A-46); if not, it faults at retirement.
4. **Per-warp concurrency.** One warp, one CTA throughout: no tier-1 slot
   other than 0, no binding-group contention, no SPM, no barriers, no
   migration.
5. **Narrow ops (Daniel's responses OI-28 to OI-31; TI-9).** A lane block
   has four 32-bit operand ports, three sources and merge, each in four
   8-bit sections; a full-width lane op takes every section, so one issues
   a cycle, and four co-issue only as narrow ops in separate sections. The
   channels now have that shape (nine resource slots on the issue, one
   message a lane), and the lane ports are limited: the kernels run OOE's
   sectioned select (OI-31), which at 32 bits issues one lane op, one memop
   and one RCU op a cycle, so cycle counts are no longer optimistic on that
   account. What is not reached is anything narrower than 32 bits: every S1
   kernel is full width, the stubs refuse a narrow op by name, and a
   footprint is always a whole group. The model and its sweep already
   place and co-issue narrow ops (OI-34); what the kernels lack is the
   stubs' half: a narrow kernel, vadd16, needs per-section execution,
   slice write-back and sliced address reads in the RCU, LANE and MIU
   stubs (after TI-10), then co-issue and footprint-width bins (AR-15),
   section-level forwarding, and the V-60 control re-aimed at two narrow
   ops granted one section.
6. **Faults other than F-RO, and a host kill.** A fatal fault's kill is
   reached (rokill); a host's grid-scoped kill_grid on ccv_cru_rau_cfg has
   no stub half, since CRU's stub only takes faults. F-ALIGN waits on IS-2
   (Q-57), and F-ADDR on the page table. Each block's quiescence is its
   whole idleness, exact for a context-wide kill, which is the only kind a
   fault raises (IS-2).

## Next, in order

1. **Wrong-path fetch and squash** (A-70 is settled). FET fetches past a
   predicted branch for as long as it has a decode for the next PC (in a
   loop, the exit path is decoded on the last iteration). Wrong-path uops get
   their own identity class, the lanes check nothing for them, and the final
   compare and retire order check that none leaked. OOE squashes the ROB
   younger than the branch, restores its RAT, returns the squashed
   destinations to the free list, and bulk-discards the warp's younger
   stores. Controls: a squashed write that lands, a squashed store that
   commits, a register freed twice.
2. **Divergence** (A-69 is settled): a tail warp (`n` not a multiple of
   32, so the bounds branch splits the warp), if/else with reconvergence, and
   masked loads masked by the issue mask rather than a guard.
3. **Compiler-corpus kernels.** `bench-vadd_loop` (a grid-stride loop) and
   `cuda-vadd` (the unaligned ABI of ISA §5.5: byte offsets, slot-indexed
   loads whose window base MIU reads from the launch block) need ops the stub
   table does not decode yet: `shl`, `add`, `mov`, `fadd`, `mad.acc`, the
   unsigned and `le` compares, and `ld/st.global` by launch slot.
4. **Several warps** sharing the machine: tier-1 slots 1 to 3, binding-group
   arbitration, checkpoint frees across slots.
