# MA handoff (MIU and DCU architecture)

Session `session_01QPk2jyUbWA7fW9YpUwqdxk`, started 2026-11-13. Start doc:
`docs/miu-arch.md` (AR's handoff). Branch `claude/miu-dcu-microarch-spec-664pgr`
in custom-cuda-core (and the same name in custom-cuda-complier, unused so far).

## Working rules beyond CLAUDE.md

- MA owns the MIU and DCU tabs of *Per-block architecture specs*
  (doc 63a486a6-7f71-4c05-82e8-e696c74779b4; MIU body aa7a288a-dae2, DCU body
  c18a112b-d2c6). AR no longer edits them. MA never edits schema/params: a
  change is an MA row with TI in Needs, after AR agrees where it crosses a block.
- Register: MA tab body `1f971016-3f72` in doc JApHYjaUESeq8tsGMGXMU5
  (Opens table and Responses table; columns ID|Decision|Severity|Impl|Needs|Description
  and Re|Date|Impl|Response). Notify per `.claude/skills/register/SKILL.md` section 2.
- gate-push: always `CCV_PUSH_BRANCHES=claude/miu-dcu-microarch-spec-664pgr`, else it
  finds no base and runs the full gate. Run detached (setsid nohup tools/bg-run.sh ...)
  and watch the real PID with kill -0; a background watcher dies at 2h, the gate does not.
- Daily sweep: trigger `trig_015gBGZ169gCKj4KbpYm5bhB`, 02:35 Pacific.
- gate-push and verify.sh now detach themselves (518cb3c3 in this branch): run
  `CCV_PUSH_BRANCHES=claude/miu-dcu-microarch-spec-664pgr tools/gate-push.sh`, then
  `tools/gate-wait.sh <job log>` as a background task (exit 3: run it again; 4: killed by a
  restart, start the job again).
- Daniel (2026-11-15): MA has standing permission to record his rulings in the DA tab (node
  d5076b00-ef1b, table m8yvbw8rqgz.231; columns title(re:) | date | actions | decision with his
  words quoted; end "Recorded by MA in Daniel's session"). Notify TI/AR as the row needs.
- Docs edits: a `find` replace "as text" inherits the first run's formatting
  (bold/code); for whole paragraphs use a guarded markdown replace.
- A rendered copy of a tab: read with `{"kind":"view"}` and render with the
  scratchpad script render.py (strips XML to `[id h=]` lines). Rebuild it if
  the scratchpad is gone.

## Bookmarks (register revs)

Conventions 20, AR 388, TI 485, OA 440, IS 197, CP 160, OI 374, RA 156, RI 91, MA 110, DA 128.

## State, 2026-11-13

- Roster: MA's session id written (commit "register: MA is ...").
- Phase 0 done: miu-arch.md section 5's stale list is fixed in the MIU tab
  (Q-18 closed, cmpl 120 bits and its field table, rcu_data field table, the
  L1 contract's RA-43 numbers 18/14, encodings, alignment, F-WIDTH, bulk
  discard with loads and the atomics exemption, the S1 model text, 8 inbound
  wakes, tier labels, the sectioned footprint) and in the DCU tab (the held note).
- First-pass draft written, marked proposed: MIU tab section "MA's Phase 1
  draft" (L1-hit budget strawmen A/B, lane-group coalescing and the contract
  eligibility rule, the 32-entry memop queue and credit, req_id 6/5 bits,
  ordering/drain/TLB/miss path, the event list for coverage bins); DCU tab
  "MA's Phase 1 draft" (64 KiB 8-way baseline, 4R tags + 4 data banks,
  D1-D3, 16 miss buffers with 4-way merge, fill path, eviction, probes).
- Grill-me raised: MA-1..MA-14 (rev 3). Notices sent to AR, OA, IS, TI.
  MA-13 is DA's (compute priority; MI/DI start).

- Agreed since: MA-1..8, MA-10..12, MA-14 (AR rev 344); MA-4 with OA (OA-408/410:
  early 1-bit no_hit on ccv_miu_ooe_cmpl_hint, TI applied on ti-ma); MA-5 per-slot
  credits (AR 345, re-affirmed 347 after the withdrawn 346): CCV_MEMOP_CREDITS = 10 a
  slot, OOE sends on the first credited slot within pipes; MIU keeps one 40-entry
  queue, each entry's arrival slot (2b) for the credit and lead pipe ctz(pipes) for
  the address pairing, and a 4-bit owed count per slot (credit return is 1 pulse a
  slot a cycle). OI-138 measured the select at 0 NGD, so the pool fallback is closed.
- MA-13 (DA): no compute priority; MI and DI start only after the grill-me with AR
  is finished, a summary is delivered to Daniel, and everything is documented.
- session-home installed (`tools/setup-session-home.py --check` matches).
- MA-15 items 1-4 and MA-5 credits landed (TI 420, eda137fa; MA 46 accepts). Entry-free
  credit return is opt-in (CCV_MIU_MEMOP_CREDIT=entry) until OI's gating merges; item 5
  (SRAM macros) is TI's next.
- Sweep 2026-11-13: merged 7 branches (TI 23, infra 23, OI dca29edc 8, +4 small); RA.md
  conflict taken RA's side. Pushed 593010a0, SCOPED PASS 24/24 (2h43m). Friday pings: 8/9
  pongs (OI none yet); AR, CP, RH rosters lack MA until they merge (sender=stale).
- OI-139/140: OOE sends on lowest credited slot (28 flops, no NGD cost); OOE model gates on
  MIU per-slot credits (dca29edc), so TI can make entry-free return the default.
- Gate note: a scoped gate on a branch carrying many merges runs nearly every
  section; check-cg/check-ngd took over 1h serial. Run gate-push under the 2h
  background limit or via tools/bg-run.sh with the max timeout.

## Open work, most urgent first

- MI/DI START (Daniel 2026-11-19: opens stay parameters; MA-23 ruled (B) + way prediction as a
  parameter, DA rev 128, MA-26 MA rev 109, MA-23 closed MA rev 110). Done: register tabs MI
  (c1311541-4219) and DI (1ea5d5b3-6e9c), each with Opens m8yvbw8rqgz.613 / Responses .675;
  Conventions rows rev 20; roster MI/DI (session null); docs/miu-impl.md, docs/dcu-impl.md;
  snapshots docs/design-snapshots/miu-spec.md (rev 144), dcu-spec.md (rev 50); CLAUDE.md pointer.
  Sweep minutes MI 39, DI 43 (ask OA to add them to the register skill's series).
  NEXT: Phase 2 (partition, per-cycle tables, port NGD budgets) for both blocks; fold the impl docs'
  added bins into the MIU/DCU tabs' events tables; the DCU tab's ECC item still says
  "CCV_LAT_L1_HIT (7)" (stale: 8/9 now) and L1_CMPL 15 needs re-deriving for 8/9 with TI;
  refresh the two snapshots whenever a tab changes.
- PHASE 1 SWEEPS (DA rev 125; plan MA-21). Model sim/dcu/dcu_p1.cpp, runner sim/dcu/p1-run.sh
  <oracle dir> <out.tsv> [K=V]; oracle build/oracle (gate cleanup deletes it: CCV_FOREGROUND=1
  tools/gen-oracle.sh). Knobs: STORE a|af|b, ARB fixed|rot, HASH, BANK_AGE, QDEPTH, STRICT/PAD, REPASS,
  GAP (default 4), DLAT, WAYPRED 1..16 + WPSEL index|recent, LDFIRST, DEFCAP (b3c74623: (b) defers no
  more than N data-holding entries per bank). Counters p1_data_peak / p1_data_sum_peak (acc4479a).
  BASELINE MOVED with the 11-18 sweep merge (stub S1 55,572 -> 56,933): give RH pre-merge shas for
  comparability. gate-scratch/MA = 85045a15 (pre-merge base + counters + DEFCAP).
  Results cm128 gap 4: a.q2 5,455,658, a.q8 5,199,588, a.q8.rot 5,191,161, a.q16 5,216,535; b.q2
  5,310,989, b.q8 5,189,898, b.q12 5,154,723, b.q16 5,141,670, b.q16.rot 5,138,164. cm32 flat at q8+.
  SECDED (TI-483, b407ff71; MA rev 98): store corrected read syn+fix 30.8 NGD = 2 stages, so GAP 5.
  Gap 5: a.q8.rot 5,227,944 (+0.71%), b.q16 5,165,866 (+0.47%): b.q16 leads a.q8.rot by 1.19% but
  holds 2.5x the data (peaks per bank / summed: a.q8.rot 18/109, b.q16 43/264; ~1,152 b/entry; extra ~5%
  of L1 data bits, ~14% area-equiv as RF). Settled: LDFIRST model-only (neutral); rot not worth it at
  b.q16; knees (a) 8, (b) 12-16.
  MA-7 DONE -> MA-24 (MA rev 100): (b), QDEPTH 16, GAP 5, store-data cap 12. cm128 gap 5 vs uncapped
  b.q16 5,165,866: cap 24 +0.14, 18 -0.12, 12 -0.57 (5,136,180), 8/6 -0.26, 4 +0.84; a.q16 5,207,327.
  AR 382 agreed on 4 conditions (signalling, order, progress, coverage); MA rev 101 answered: MIU-held
  per-bank credits (hard reservation). Model CCV_P1_CREDIT (a6597228, pushed): cm128 5,130,918 (-0.10%
  vs soft cap, -1.47% vs (a)), repass 0, store-data peak 12; S1 clean 55,693. Reproduced RH exactly
  (5,136,180 from fetch) in worktree /home/user/wt-credit at 11dcec83 (oracle build/oracle-cm128;
  run build/cr/run.sh; note bg-run.sh ran in place there, so launch long runs with setsid nohup).
  MA-25 (MA rev 108, TI notified): params CCV_DCU_BANK_QDEPTH 16 / CCV_DCU_BANK_STDATA 12, two 8-bit
  credit-return vectors DCU->MIU (TI picks channel). Spec tabs updated (DCU rev 48, MIU rev 144); rename
  channel there once TI lands it.
  IN FLIGHT: RH at 11dcec83 (soft cap DEFCAP 12): BANK_AGE 8/16/32/64 (cm128 + S1), then HASH 0/1
  with stride-kernel callout; ETA part 1 ~07:30Z.
- TI-485 kill races (settled, MA rev 107): OA 436 final (OA 438, AR 385): MIU completes every memop of a
  killed warp, keeps an atomic's hold through A3 (more = 0), UE-withheld read completes with no data.
  MIU tab rev 143. (MA flip-flopped on crossing rows; lesson: wait for AR and OA to agree before editing.)
- TI-484 (MA rev 99): miu-impl.md must require MI's MIU to pass the CCV_MIU_ECC_INJECT runs (0767fe1c).
- MA-23 (DCU data array shape; MA rev 90-97): (A) parallel 8-way, hit 7, 512 tiny SRAMs w/ waivers; (B)
  tag-then-data hit 9; (B)+(C2) way prediction in the payload cycle, hit 8 (mispredict 9), 2nd bank access.
  AR 381 closed loop (h7 base / h8 / h9 / h8+wp3 index): cm32priv +1.00/+2.12/+1.00; cm32 ~0; cm128priv
  +0.93/+0.90/+1.47 (6.44% wrong); cm128 +0.19/+0.09/+1.56 (1.69% wrong). Way-index pick is bad
  (power-of-two per-warp buffers); offline: k5 index 1.48%/0.00%, k3 recent 0.79%/0.06%. AR runs h8 with
  k3 recent, k5 index, k5 recent on a6c7de10. Recent needs true LRU (24 b/set vs 7 pLRU) + age compare in
  11.88 NGD; k5 index = 512x40 RF. Expected ~+1.0% private, <=0.2% shared vs (A): over 0.5%, so Daniel
  rules. Then DCU tab array text: data 8x512x137 per bank, tags 2x64x144 RF, predictor, pipeline.

- MA-20 closed by AR 372 (MA rev 85 accepts): Phase 1 prices (1)+(3) together first (fixed vs rotating
  on re-pass tail; oldest-first only after A1 NGD check); queue head owns BANK_AGE, entries are deferred
  work under the bound, 99.9th pct sizing; (2) within-page hash only, bank = PA[9:7]^PA[12:10]^PA[15:13],
  bar >0.2% over (1). 729-cycle wait was deferred work vs on-time loads, not slot order. When (3)
  lands, fix the age-owner text in both spec tabs; carry all into dcu-impl.md.

- TI-478: AR 368 landed (9682b03a; L1_ECC 1, L1_CMPL 15). MA rev 83 took it: impl docs must require
  data at L1_HIT, completion L1_ECC later (zero syndrome), late hit completes at due + 1.

- TI-474 (DA via TI): BIST override, ports up to block wrapper tied off, 1 spare row per instance,
  column repair >8 KiB, SECDED on every SRAM. MA rev 76 answered: asks the 32 KiB limit count data
  bits (keeps 2 x 512x576 per bank; else 4 x 512x288, 10% penalty); loads use data speculatively at
  L1_HIT 7, non-zero syndrome cancels +1 cycle and replays (asked OA if the scheduler takes it; else
  L1_HIT 8, AR prices); store merge reads corrected data; encode in its own stage (fill +1 stage);
  spare rows ~11.5k flops. OA 424: OOE takes the cancel as a miss; L1_HIT stays 7, cmpl derive 14 to 15 (OA's row
  for TI); MA rev 78 confirmed the 1-cycle syndrome (~15 NGD). AR 367: ECC'd merge (gap 4) is in
  Phase 1's store variants (MA rev 77). AR-368: new CCV_LAT_L1_ECC (MA's, = 1), cmpl 14->15, contract text for
  TI. MA rev 79 took RA 153's MIU conditions (corrected beat via fill return path/RA-28 (a), data
  before completion, kill as miss, MI injected-syndrome knob + DED test): carry into impl docs.
  TI-475 (DA) answered (a): 32 KiB is logical size before ECC, so 2 x 512x576 per bank stays, no
  waiver; BIST groups <=32 KiB; ECC outside the wrapper; ECC events to AR's fault system. DCU tab
  rev 45 has a new arrays item recording TI-474/475; MA rev 80 proposed the 2-bit-error handling
  (clean: invalidate + refetch; dirty: AR's). AR 369 proposed the machine-error system
  (CE count, clean UE refetch, attributable UE -> F-MACHINE, unattributable -> core-fatal via
  ccv_<blk>_cru_err, ccv_common_err). MA rev 81: agree, but a dirty-line UE is core-fatal for DCU
  (no ue on dcu_miu_rsp; SPM's ue passes through MIU). DECIDED as AR 370 (DA rev 124), MA's change
  folded in; clean-line refetch bounded by a per-location track table. MA-19 (rev 82, Needs TI):
  CCV_DCU_UE_TRACK = 16, 13-bit locations; DCU tab rev 46 holds it and ccv_common_err. TI-476:
  flop arrays scan only. SPM is RF (AR 371), so DCU data is the only SRAM. Waiting: TI's BIST style. Then
  update the DCU tab arrays paragraph and carry it into dcu-impl.md. TI-472/473: no action (TI-473
  fixed 128w SRAM launch to 16.3; 512w stays TI-470's 18.5, 6.5 left).
- TI-467 (DA, 2026-11-17): macro size per instance, RF 512 B-8 KiB, SRAM 4-32 KiB (check-ngd MACRO-1,
  rtl/macro-waivers.json). MA-18 (rev 74): no waiver. Data bank = 2 x (512w x 512b, 32 KiB) SRAM, 16 in all
  (MA rev 75, TI-469: size penalty 20% at a type's minimum, 0 at max; 16 KiB fallback only if timing fails;
  TI 470: 512w SRAM addr setup 13.1, rdata launch 18.5, 6.5 NGD left: flopped rdata fits);
  tag RF word = the set (8 x 35 tags + 7 PLRU, 64 x 288 b, 2,304 B, 8 instances; hit's LRU write-back dropped
  if a fill wrote the set since its read); payload store RF only (5,760 B, or 2 x 2,880 B); window table RF
  512 B passes: TI-468 (DA) rules limits inclusive. Size waivers are written by the block architect (MA
  for MIU/DCU), DA approves before block completion. DCU tab rev 43, MIU tab rev 137.

- TI-466 (DA, 2026-11-17): no SRAM byte enables; only ccv_common_rf_1r1w_be has wmask (4.5x SRAM/bit).
  MA-17 (rev 71, Needs AR, TI FYI): store hit = its lookup's line read + D3 merge + whole-line write in the
  bank's next free slot (2 slots a store); same-line lookups wait for the write; partial miss merges in the
  fill buffer. DCU tab rev 41 (.14745, Arrays para). Fallback: idle-cycle write buffer with forwarding.
  AR 365 (open-loop): (a)=MA-17, cm128 late loads 3.30->4.10% (2x 7.03->8.28%); (b) 1-bit lead_store,
  read deferred: late loads unchanged, DCU deferred queue 5 (2x 15). MA rev 72: (a) now; (b) only if Phase 1
  shows >0.2% on S1. Summary doc rev 20 updated. AR 366 (MA-17 as written): cm128 3.30->4.14%; 2x
  7.05->9.10%, 40% of it same-line wait. MA rev 73: Phase 1 runs (a), (a+f: forwarding write buffer), (b)
  closed-loop on S1; cheapest within 0.2% of best wins.

- TI-465 (DA, 2026-11-17): macro pin timing. Addr setup = decode + 6 (SRAM) / 4 (RF); data setup 8/6;
  rdata launch = static D:1 mux / 1.5 + 6/4 (128w SRAM 512b: 18.6, about 6 NGD left). MA rev 70: Phase 1 sizes
  macros (words x width) per bank to fit, rdata straight into a flop; any shortfall is a hit stage on DI's
  measured need (PF-51). Carry into docs/dcu-impl.md and the Phase 1 resource model.

- DA ruling (TI-461, 2026-11-16): no task carries a date; best effort in priority order; a dependency
  is met by reordering, never a due date. No dates on rows, handoff items or promises.

- Sweep 2026-11-17: register had nothing for MA. Merged ccr-126afa13 9, ccr-183cc441 62,
  ccr-3868632d 33, ccr-57eff422 24, ccr-80102643 17, ccr-9eb50716 7, ccr-c22116ce 9 (all clean);
  full gate PASS on db5a70de (ngd 3.9h, cg 3.6h), pushed. Criss-cross sweep merges have ~8
  merge bases and take minutes each: run them via tools/bg-run.sh, never in the foreground.
- Sweep 2026-11-16: 9 branches merged (merge commits; 2 slow, multiple merge bases). TI-455: AR 362
  lead landed (e6b1dd68); TI 457: AR 364 + DCU_BANKS 8, DCU_BANK_AGE 16, lead_set_index at 1861cc51. Only MI/DI blocker left: Daniel reads
  the summary, then docs/miu-impl.md + docs/dcu-impl.md. CP-83: coremark-derived-pl-priv in a9241c2.

- 2026-11-16: DA rev 123 (Daniel): SRAM is 1RW (6T) only, accessed every other cycle; banking for
  bandwidth; 1R1W or every-cycle arrays are RF at 3x area/bit; tags RF, data SRAM. MA-16 (rev 67,
  Needs AR, TI): DCU data >= 8 half-rate banks (bits [9:7], lead bank field 2->3 bits, 48 lead flops),
  2-cycle read assumed (fits hit 7 under B), tags RF banked like data (not 4 copies), LRU + MIU window
  table RF, MIU memop payload store (46 Kbit) RF or 2 half-rate banks. TI: macro library; AR: 8 vs 16
  banks. SETTLED (MA rev 68): AR 364 agreed 8 banks (16 buys <0.2% open-loop); the bank is
  set_index's low 3 bits, so no bank field: lead = 9 bits/slot, 36 DCU lead flops (my 48 was wrong).
  DCU gets an age bound on hole-filling, CCV_DCU_BANK_AGE (start 16; AR saw 729-cycle starvation);
  Phase 1 model sets it. TI 464: macro library landed 0b270eb3, checked against DA 123 (MA rev 69, matches); told TI the lead width derives from
  CCV_DCU_SETS only. Spec tabs updated (MIU rev 136, DCU rev 39) and summary doc (rev 19).

- 2026-11-15 late: doc check done (MIU tab rev 128, DCU tab rev 37: drafts -> decided, Strawman B
  chosen, 512 KiB geometry, req_id/wire totals). AR 362 agreed B with 6 conditions (MA rev 65);
  TI-449 lands the index lead + require 11-16. Q-42 stays open (AR, floorplan abutment).
  Summary to Daniel delivered as a Claude doc: https://claude.ai/artifact/AEUqHyXyixyuxytWxc7mGd
  NEXT, after Daniel reads it: docs/miu-impl.md, docs/dcu-impl.md; MI/DI start after TI-449's gate.
  TI-450 (a5481843): the cm128priv CHECK bug was the stub MIU's completion ahead of late data;
  fixed, cm128priv clean; also landed no-hit and CCV_DCU_SETS 512. Summary doc rev 12 says so.
  AR 363 (PF-33/PF-47 at 512 KiB, a5481843): 0.6%/hit cycle cm128priv, 2.5% cm32priv; configured
  down +0.59% (128K)/+1.14% (64K) per cycle. MA rev 66: L1_HIT stays 7; hit 8 only on DI's measured
  timing need. PF-51 Signal updated.

- 2026-11-15: MA-9 CLOSED (DA rev 121): MIU and DCU stay separate; merge/direct return is Phase 2,
  priced on MI/DI's timing model (boundary hops as configurable latencies) + AR's PF-33/PF-47 at
  512 KiB base 7/8/9. MA rev 63 answers AR-349 (Q-42 can close). The grill-me is finished. NEXT:
  documentation check of the MIU/DCU tabs (no 'proposed' drafts, no superseded numbers), then
  Daniel's summary, then docs/miu-impl.md and docs/dcu-impl.md.

- MA 61-62 (DA in session, 2026-11-15): L1 BUILT FOR 512 KiB (8w, 512 sets, 128 B), configured
  down by sets only; supersedes MA 60. TI to set CCV_DCU_SETS 512. DCU tab Geometry updated (rev 24;
  the Capacity item's history below it still reads as history). Pinged AR for the PF-33/PF-47 status
  on -priv at 512 KiB, hit base 7/8/9: that curve is the MA-9 number.
  DA: fixed 512 KiB hit latency at every configured size for the first implementation; the
  size-following latency is PF-51 in docs/perf-register.md (owner MA). TI-447: CCV_DCU_SETS 512
  in params (6d36c1b2, lands with ti-nohit). Asked Daniel whether TI should log the 512 KiB decision
  in the DA tab.
- MA 60 (re:AR 360, superseded by 61): capacity on -priv: cm128priv 64/128/256/512 KiB = 2.133M/1.947M/1.928M/1.925M
  (128 KiB takes 8.7 of 9.7 pts); cm32priv -0.17%, S1 flat. Accepted: 64 KiB baseline, Phase 1
  resource model prices 64 and 128 KiB; area delta to Daniel in the summary (corpus sweep DA rev 95
  decides). AR 360 (2): operand CHECKs track misses/evictions (672/128/0/32 lines), cm128priv only;
  TI naming the owner; MA checks the spec's fill/return order against the cause.
- TI-444 (cc MA, no ask): -priv has no ineligible load, knob k0=k1 (cm32priv 2,253,475; cm128priv
  22.78M cold, k1 OOM-killed); PF-33/PF-47 can re-book on -priv. 128 operand CHECKs on cm128priv
  (consumer reads before load lands, no replay): TI bisecting with RCU/OOE stubs; if it lands on
  the MIU/DCU stubs it comes to MA.
- Sweep 2026-11-15 pushed 313d6c04, SCOPED PASS 24/24 (ngd 2.6h). AR 358 made coremark-derived-priv the perf baseline (MA 59 taken); TI 442
  moved benches (cm32priv/cm128priv). AR 356: stub gets MA-4 eligibility + no-hit, knob off/on
  runs pending (TI). AR re-books PF-33/PF-47 on -priv: the MA-9 merge numbers come from those.

- MA 57-58 (TI 440-441): cm32 gathers are all 25-32 lines (one per lane), PF-46 per-thread
  blocks via ordinary .global, none in IS-24's window: ports closed as a fix (no 6/8-port
  pricing in Phase 1). CP-82: coremark-derived-priv already uses the window; MA 59 asks AR to make it the
  sweep baseline (.global secondary); Phase 1 sizes on the window form.
  1-line late loads are stub effects; endorsed TI's AR 356 stub change (first pass first).

- MA 55-56 (re:TI-437, AR 353-354, TI 438): no-hit settled. CCV_LAT_MIU_NOHIT_A2 = 2 (A1 at H,
  A2 at H+1, launch H+2); CCV_LAT_L1_NOHIT = issue-to-H + 2 + HOP = 9 under PF-47 (TI applied).
  MA 55's L1_WAKE-5 withdrawn (it moved with L1_HIT).
- Phase 1 model: report max memop hold against CCV_P_TIMEOUT_MEMOP 20480 (stub's cm128 hit
  19201, TI 436, from its global head-of-line block); send the no-hit for OI-142's knob.

- Sweep 2026-11-14: merged 9 branches (+3 updates after a restart killed the first gate);
  RA.md conflicts kept RA's newest (d4d4976c). Pushed 9d3acbae, SCOPED PASS 24/24.
  For Phase 1: OI-142's l1_nohit knob waits on MA's model sending no-hits; AR 351 set
  CCV_LAT_RCU_ADDR_BASE = 1 (L1_WAKE 13, L1_CMPL 14), so PF-33's merge numbers move.

0. MA rev 51-52 (re:AR-350, TI-424): memop watchdog CCV_P_TIMEOUT_MEMOP = CCV_MEMOP_CREDITS x
   CCV_P_TIMEOUT_MEM = 20480 (spec MIU blocks a warp only on its own; rev 50's 81920 withdrawn,
   it was the stub's global head-of-line queue); TI applies
   with an 8192 control and a bounded cm128 check. Caveat for Phase 1: measure DCU miss rounds
   per 32-line memop; if >1 it joins the derive. AR-349 answer and the MA-9 close wait on
   Daniel's OK of: close MA-9 with latency moved to the timing model; partition a Phase 2
   decision priced on configurable boundary latencies; 64 KiB stays baseline.

1. MA-9 (MIU-DCU boundary): waits on AR's capacity sweep (64 vs 512 KiB, L1_HIT
   5/7/8). When it closes, the grill-me is finished.
2. Then: the summary to Daniel (all MA rows, decisions, what changed in the spec
   tabs), and confirm everything is documented. Only after that, MI and DI
   handoffs (docs/miu-impl.md, docs/dcu-impl.md).
3. MA-15 closed (MA 47-48; TI-420, a46afef7): all 5 items in, entry-free credits default.
   For DI's handoff: rtl/macro/ccv_common_sram_{1rw,1r1w}.sv; 1r1w same-cycle read of the
   written word returns OLD data (DCU forwards fills itself); W a multiple of 8 (pad tags).
   TI's a46afef7 adds tools/gate-wait.sh <job log> (exit 3 rerun, 4 killed) once merged.
4. Phase 2 (TI-445, DA ruling: a module's owner (MI/DI) sets/moves an NGD port budget where
   check-ngd times the connection (parent has a unit) and passes; MA still sets the budgets
   for unmeasured parents, the MIU/DCU block boundaries and boundary-wired ports; DA rev 120): module partition, per-port NGD budgets, index-lead schema row (after
   AR's sweep), the payload-slot macro decision.
