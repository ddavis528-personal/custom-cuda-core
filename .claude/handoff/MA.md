# MA handoff (MIU and DCU architecture)

Session `session_01QPk2jyUbWA7fW9YpUwqdxk`, started 2026-11-13. Start doc:
`docs/miu-arch.md` (AR's handoff). Branch `claude/miu-dcu-microarch-spec-664pgr`
in custom-cuda-core (and the same name in custom-cuda-complier, unused so far).

## Now (2026-11-27 late)

- MA-35 / MA-33 (3) DONE at Daniel's direction: fold = fold(PA[47:16]) ^ fold(PA[15:7+log2 sets]). Commit f4952819
  (unpushed until gate; touches tools/ -> full gate). DCU tab rev 149, register MA rev 223. After push: notify TI, MI, DI
  (owners of the edited files); TI also fixes CCV_DCU_WAYPRED_BITS doc. Model runs at 64/128/512 sets in
  scratchpad/wf/runs (missrun, plog clean; cm128 new vs old binary pending) -> response row with figures.
- In RTL only MIU folds (DCU stores MIU's pa_fold); ccv_common_wayfold has no design instance yet (walker not written).
- RH (OA-504) asked for gtr4/gtw* kernels: sent inline (they live only in scratchpad/ar412/synth); told RH MA-31 had no
  B/cycle counter (lines x 128 / cycles is the equivalent), env, and the uncommitted p1-knobs.patch; offered it if needed.

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

Conventions 20, AR 426, OA 506, IS 201, CP 160, OI 427, RA 159, RI 93, MA 222, DA 136, MI 74, DI 100, TI 594.
- Sweep 2026-11-23: nothing in Needs MA. Merged TI infra 153, AR ccr-80102643 6, OA ccr-9eb50716 3, DI ccr-5e4d6c70 8,
  MI ccr-58815650 18 (single base 8e784c88 by merge-tree/commit-tree: ort recursion over 6-7 bases ran >30 min;
  merge TI's single-base branch first, then the rest drop to 1-2 bases). DCU snapshot rev 115.
Pings 2026-11-20 (Friday) to every roster session: AR OA IS TI OI CP RA RI RH MI DI; 11/11 pongs, all ok.

- Sweep 2026-11-20: merged infra 35, IS ccr-3868632d 82, AR ccr-80102643 28 (single base), DI ccr-5e4d6c70 7,
  MI ccr-58815650 2, RH ccr-c22116ce 9; pushed dbf69316, SCOPED PASS 26/26 (~4h40m, ngd/cg dominate).
- TI-501: e8d8864b landed MA rev 134 notices-on scenario (vadd4, both models, CCV_DCU_NOTICE=1; five hint/notice
  controls). Watch item on TI-495 closed; e8d8864b arrives with the next sweep.
- TI-506: MA-25 landed (d761c634; ccv_dcu_miu_cred, QDEPTH 16, STDATA 12). Spec tabs name them (DCU rev 60,
  MIU rev 146), snapshots 2c11d950, MA rev 136 closes MA-25.
- TI-508: MA rev 137 drops MI-7 (c) two-page-hit (eligibility page = TLB page 16 by design; MI agreed rev 22).

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

- DI-26 ANSWERED (MA rev 157): dcu_bctl budgets set in the row (inputs arrival 0, sa req 9, ce req 4, other outs 0);
  DI writes dcu_bctl.ngd.json with by "MA (MA rev 157, DI-26)"; partition changes (a)-(f) confirmed; DCU tab rev 84
  (snapshot at 82: refresh with next batch). Slice 2 owes store-to-load order in the bank queue (DI-26 (f)).
- Sweep 2026-11-22 merged 11 branches (AR's 80102643 by commit-tree: 5 merge bases hung the recursive merge),
  full PASS, pushed. TI-517 landed MA-29 (bc9d61ff), TI-518 landed MA-30 (63579fce); both marked in the tabs.
  Snapshots refreshed: dcu-spec rev 87, miu-spec rev 162. Next: DCU slice 2, then MIU slices 2-4.
- TI-533: CCV_DCU_FILL_AGE=4 landed 608f8711 (closes MA's ask). Bookmark TI 531.
- DI-39 ack (DI rev 75): built; model knob CCV_DCU_VICTIM_AT default 1, RTL 2 -> after pricing, default must match RTL (2) unless fallback taken.
- AR 412 (4) TAKEN (MA rev 178; DA row .133923 rev 132: DRAM 1000 cyc, read target 1 line/8 cyc, ~125 in flight; default TB latency 20+/-5). First cut: RT ~1030 -> ~130 lines; candidates 160/192: dcu_mshr 16->160 (RF read at F, CAM merge, FIFO unsent), bank queues 16->24, MIU park table ~160 x 200b RF (MQ stays 40/credits 10; changes MA-14), W_REQ_MIU_DCU 6->8, W_REQ_DCU_MLC 4->8 (schema rows after Daniel's area). NEXT: p1 model read class at CCV_TB_LATENCY=1000 after ti-tblat + AR412(1); sweep 128/160/192; then MA-31 row with area to Daniel. Waiting AR/OA on (d) MLC_HIT_MAX term vs THRESHOLD_MLC=50. Bookmarks AR 416, DA 132.
- AR 413 (AR rev 417): (d) resolved, MLC_HIT_MAX's queue term becomes FET's 4 ifill ids (HIT_MAX 28); 8-bit DCU->MLC ids leave THRESHOLD_MLC=50 standing. Bookmark AR 417.
- OA-475 (OA rev 475): THRESHOLD_MLC re-sweep (35/50/75/100) waits on MA's read-path sizes being in the stub -> after MA-31, ask TI to carry the sizes into the stub and notify OA.
- TI-537 (DA: common RTL credit modules in rtl/common by TI) confirmed with corrections (MA rev 179): cr_dst rel_n count (MIU REL_MAX 3), land+release per message (mlc_dcu_rsp), cr_src LATE_COUNT (dcu_mshr MLC req); CG-5 note. MI/DI migrate once it lands. Bookmark TI 535.
- TI-539: TI-537 v2 took all three corrections + CG-5 waiver once on cr_cnt. Bookmark TI 537.
- DI-40 GRANTED (MA rev 180): dcu_bctl fill ports arrival 0 / outputs required 0, dcu_mshr fill outputs required 0, dcu_fill fwb/state required 0; DI writes the files by 'MA (MA rev 180, DI-40)'. Bookmark DI 76.
- TI-541 (DA via AR 415 (5)): option A, named exception: credit/stall -> cr_go -> same channel's valid at a flopped sending end is timed as the port-budget pair, never NGD-5; depths stay 4+2N. Applies to MIU/DCU senders (MI/DI). Bookmark TI 539.
- DI-41 (MA rev 181): DI renames bctl fill budget keys to cc03h under rev 180 grant; CCV-L23 for fold table's 2nd writer: MA asks OA for (a) declared loops or (b) lint 2nd write port; (c) rejected (false-miss window under MA-30). Waiting OA. Bookmark DI 77.
- OA-479: OA recommends to Daniel a narrow two-writer CCV-L23 table form; if adopted, MA signs DCU's fold-table declaration (condition 1). Watch DA tab. Bookmark OA 479.
- DI-42 SPECIFIED (MA rev 182-183, DCU tab rev 121): fold-table margin (OA-479 (b), DA adopted) held by re-read not bypass: margin lookups take mispredict re-read (late, due+2; CHECK<=2), colliding fill re-snapshot (CHECK<=2); bins, control dcu-ft-margin. DCU snapshot due at rev 121. Bookmark DI 78, OA 479.
- DI-43 (MA rev 184, DCU tab rev 122): fill re-snapshot rule: slot w/o way, one snapshot/cycle oldest-first outside margin, reservation held until write visible (closes grant-cycle gap; bctl_one_fill_per_way + control), wait CHECK <= 2*(slots-1)+1; DI to confirm < 32 with DI-37 bound. Bookmark DI 79. DCU snapshot rev 122.
- MA-32: TI done (16943021, lands with TI's next gate-push; TI rev 540): CCV-L23 admits by MA under rtl/miu, rtl/dcu with a check-1d control. Close MA-32 when landed; TI may still answer the two-writer-form FYI. Bookmark TI 541; TI 541: the two-writer table form uses the same scope-aware signer list.
- MI-35/36 (MA rev 204): L0 refill loop signed in substance by MA (back edge miu_a2 cm06h read of miu_tlb *_q_cm11h; 5 uncontended, <=8 cycles; cancel on lead w/o miss) + add assertion <=8 w/ grant-hold control; file waits TI cross-module L23 form (MA backed to TI). Budgets landed 469769e0 (a2 24.6, lead 23.5, tlb 17.5; rk from miu_form). miu_pair 754 flops. NOT RULED: LRU vs RR, bcast, L0 4 vs 6 -- MI explains bcast+LRU rope 677 vs bcast+RR 666, prices L0x6 LRU (NGD + all kernels); first reads: LRU provswap -0.36% (24-32 flops), rope +2.58% w/o bcast. MIU tab: miu_pair 754 at next edit. Bookmark MI 61, MA 204.
- TI-554 (TI rev 553): TI proposes cross-module declared loop in the parent's feedback.json (MA signs for rtl/miu) + connection tag check, pending OA. MA already accepted either form (rev 204); no answer needed. Bookmark TI 553.
- OA-481/TI-554 ANSWERED (MA rev 205): parent ccv_miu (rtl/miu/ccv_miu.sv, MI's assembly), miu_a2+miu_tlb direct children -> rtl/miu/ccv_miu.feedback.json, by MA. Stale-read hazard: per-slot pending-VPN match in miu_tlb (2nd miss on pending VPN = L0-miss drop, no 2nd request; fill writes no duplicate VPN); assertions no dup VPN per slot, no 2nd request for pending VPN; control miu-l0-dup; MI measures the 32-bit compare. Bookmark OA 481.
- MI-37 RULED (MA rev 206): L0 of 6/slot, RR, no broadcast (rope +0, provswap +0.58; rope WS 6 pages). miu_a2 24.7 (0.3 left), miu_tlb 18.2, ~4,190 flops (L0s 1,656). Bound: bench check + controls tight/norr in run-rtl.sh; RTL SVA w/ age bits under assertion-only define. Owed: colwalk/cm32/cm128 at 6, pending-VPN match (rev 205). MIU tab rev 210 updated (TLB row, translation, miu_tlb contents/flops, budgets 24.7); snapshot rev 226. Bookmark MI 62, MA 206.
- MI-39 SIGNED (MA rev 207): L0 refill loop declaration text for rtl/miu/ccv_miu.feedback.json signed by MA (edited: bound 5/8 cycles, cancel, bound SVA). Budgets: miu_tlb vpn/ms_cm07h arr 0, miu_a2 out 0. No-dup filter (pending/granted/writing/last-written VPN, 36 flops) accepted; MI reports miu_tlb at L0 6 w/ filter. OA confirms cross-module form (TI-554). Bookmark MI 63, MA 207.
- OA-484 (MA rev 208): agreed 3 conditions: MI keyed form ahead=5; TI check admits block architect signer; L0 invalidate clears wv + refill stages (assertion: no filter drop on page absent from L0 and all refill stages; control: invalidate leaves wv set + re-miss). Rev 207 signature covers. Bookmark OA 484, MA 208.
- TI-561 (FYI, TI rev 563): ef260513 landed the two-writer table form (DI to write the fold-table declaration; MA-32 closes on DI's commit) and the connection check (42 OOE back edges on rtl/conn-ratchet.json, OI's); MI's list form next push. Bookmark TI 563.
- TI-568 (FYI, TI rev 570): 77f7849e landed DI-38 re-pins; MI can now write ccv_miu.feedback.json (MA-32 signature already given at MA revs 207/208). Bookmark TI 570.
- TI-580 (FYI, TI rev 582): lint already admits MA as signer under rtl/miu and rtl/dcu; nothing owed. Bookmark TI 582.
- SWEEP 2026-11-24: register nothing for MA. Noted: AR 417 raises W_REQ_MLC_EXB 6->8 (256 ids; 128 was under MA's ~130 lines at ~1,030 rt, MA rev 178); DA 133 AR owns MLC spec; DA 134 OOE ratcheted paths may rise to 30 NGD until assembly (non-OOE stays 25); AR 416 MIU NS {K,2K} credit at QDEPTH 16 is 8 flops (counts against MIU 2%); MI-44 holds ccv_miu.feedback.json until ccv_miu wires a2-tlb. Bookmarks AR 421, OA 502, OI 426, RA 159, RI 92, DA 134, MI 68.
- MA-33 RAISED (MA rev 212; DI, MI notified): re-pricing on fixed TB (922bcc25) blocked. (1) DI: DCU model reuses miss buffer id on cm128priv (timing-dependent; wrong data). (2) MI: rope/ropediv MA-27 CHECK under model/model. (3) MA's own: wayfold PA[47:16] covers tag only at 512 sets; below it fold in PA[15:7+log2 sets] at A1 before any sub-512K config. Valid so far (model/model): cm32priv R5 1,875,586 / R4 1,872,837 / R3 1,866,170 (-0.36%, now best) / R2 = R4 / B9 +1.01%; S1 R4 53,002, B9 +1.14%; hit7->9 on cm32 ~1.3%/cycle; cm128 R4 2,368,539, R5 +0.11% (MIU stub). Re-run cm128 (all of grid + capacity) after DI fixes; row to AR then. Scripts: scratchpad/g2 (run.sh, r5/b9/h7 patches, tab.py).
- MI-45 (MI rev 69): MA-33 (2) is the slot-window fill's bank, already fixed in 8c9a6cd5 (TI-544), not pushed at 922bcc25; RTL case goes to lead_tb. Recheck rope/ropediv after MI's push. Bookmark MI 69.
- DI-55 ACCEPTED (MA rev 213; DCU tab rev 127 adds late-miss -> miss-wait -> retry port rule; DI, MI notified). MA-33 (1) closes when DI's full cm128priv runs (stub MIU 64 sets; model/model seeds 1, 2) are clean; d16fc703 lands with DI's gate. (2) closed. DCU snapshot needs refresh (126 -> 127). Then re-run cm128 grid + capacity from scratchpad/g2. Bookmark DI 94.
- DA-135 (Daniel, recorded by OA, DA rev 135): a block's loop declarations are signed by its architect (MA for MIU/DCU); OA 484 closed (OA-503). No action. Bookmarks DA 135, OA 503.
- TI-582 (TI rev 584): DA-135 in lint 0878c4e5; MA alone signs rtl/miu, rtl/dcu declarations; a cross-block loop takes by: [both architects]. Bookmark TI 584.
- Sweep 2026-11-26: merged ccr-126afa13 (9), ccr-183cc441 (2), ccr-3868632d (8), ccr-58815650 (45), ccr-5e4d6c70 (5), ccr-80102643 (12), ccr-888218a3 (6), ccr-9eb50716 (7), ccr-c22116ce (3); generated conflicts taken ours then regen.
- g3 (cm128priv grid) agent DIED on the weekly limit; not re-run. AR 418: check whether MA-30's runs used CCV_MLC_WARM=1 before re-running; the g2 brief is scratchpad/grid2-prompt.md.
- MI-46 condition restated (MA rev 221): F-SHARED negative-sum bin miu_fshared_neg + control on the push landing b50828a9. MI notified.
- MA-31 DECIDED B (Daniel, DA rev 136) and APPLIED: DCU tab rev 147 (dcu_mshr x8 per bank, req_id {bank,entry} 7b, new dcu_mpick: cross-bank MLC request pick, retry grant, mlc_req flops; widths 8/7 "until TI applies MA-34"), MIU tab rev 236 (req_id 8b 160 ids, miu_ids ~1,400 flops, new "Memops in flight: 8" bullet). MA-34 raised (MA rev 220) for TI params/schema + DI/MI RTL; TI, DI, MI, AR, OA (OA-475 re-sweep after TI) notified.
- AR 419 AGREED (MA rev 219): B agreed by AR; PIPES stays 4, new CCV_MIU_MEMOPS_INFLIGHT=8 in MA's TI row after DA; return state B 32 kbit (+19.2 over 12.8); in-flight +~800 flops (MI to measure); 160-id pick per bank if >25. AR puts A/B/C to Daniel and records the DA row. Bookmark AR 423.
- cm128priv grid re-run (g3) launched on HEAD + d16fc703 + 2f3c8db4 (scratch merge); then full MA-30 table to AR (AR 418).
- MA-31 RAISED (MA rev 218; AR notified; Needs DA decide, AR agree): AR 412 sizing at DRAM 1000 on p1 (scratchpad/ar412: results.txt, p1-knobs.patch touches TI/MI files, not committed; dcu_p1.cpp seal() fix for stub MIU missing check_bits is mine to commit). Real workloads flat at 64 (S1 read class -10.4%); streams (gtr4/gtw*) keep gaining to 192. Binds: MSHR > MIU->DCU ids > MLC_EXB ids > MIU jobs (PIPES 4->8 enough); credits and bank queues never bind. Proposal B = 128 as 16 MSHR per bank (8 banks), W_REQ_DCU_MLC 4->7, W_REQ_MIU_DCU 6->8, miu_ids 64->160, return state ~160x200b RF, MIU_PIPES jobs 8. After DA: TI rows, DI/MI RTL rows, tell OA (OA-475 re-sweep).
- MI-46 ACCEPTED (MA rev 217; MIU tab updated): window F-ADDR at A1 (we/ow flopped in miu_agu8, 421/462 flops, 24.8 NGD; miu_a2 355 flops, 25.0); budgets fal/ilv/ow/we arrival 0 / ow, we required 0; CONDITION open: negative .shared sum must fault by F-SHARED at A3, with control. Bookmark MI 70.
- MA-33 (1) CLOSED (DI-57, DI rev 96: cm128priv clean on d16fc703); MA rev 216 status. NEXT: cm128priv re-run of grid (R5/R4/R3/R2/B9, model/model) on HEAD+ccr-5e4d6c70+ccr-58815650 after AR 412 sweep frees memory; then full table to AR (AR 418). Bookmark DI 96.
- AR 418 ANSWERED (MA rev 215, AR notified): AR's warm re-baseline -> capacity and hit-latency tables stand; only MA-30 (cold) owes a re-run = g2 grid; S1/cm32 sent, cm128 after DI-55 clean; then full table to AR. Bookmark AR 422.
- DI-56 (FYI, DI rev 95): fold-table port, fill re-snapshot, signed declaration landed at d16fc703; closes DI-43..47, DI-52, DI-54. Bookmark DI 95.
- MA-32 CLOSED (MA rev 214) on DI's 54eb9217 (dcu_bctl.feedback.json signed by MA, DI-40 budgets) + a518a612 (dcu_bctl CG 94/101.5), at d16fc703 on ccr-5e4d6c70 with the MA-33 fix. DI's full cm128priv runs in progress -> DI-55. Merge ccr-5e4d6c70 and ccr-58815650 at next sweep, then re-run cm128 grid.
- Pings 2026-11-27 (Friday) to every roster session (AR OA IS TI OI CP RA RI RH MI DI, sessions per notice.py roster); all 11 pongs back the same day, addressed=yes me=ok sender=ok, each from its roster session.
- Sweep 11-27 (10:35 trigger): register read, nothing in MA's Needs. Bookmarks now: Conventions 20, AR 426, OA 506, IS 201, CP 160, OI 427, RA 159, RI 93, MA 221, DA 136, MI 74, DI 99, TI 593. FYI: TI-590 B combined gate red (miu_ids_tb kNI=64, MI-48 fix 1ed1800b); MI-49/TI-591 drop miu_form from heavy-units via clang++ replay (3826f9cf); AR 421 TIMEOUT_MEMOP derive per bank; DI-58 waits on TI widths.
- TI-592 (TI rev 594): MA-34 B landed in c0883a36 (W_REQ_MIU_DCU 8, MIU_DCU_IDS 160, MEMOPS_INFLIGHT 8, MSHR 8x16, EXB 8, TL src 8; MI 1ed1800b). colwalk-p1k control dropped: stall at TB_LATENCY>=300 and stale-operand CHECK at 600-1000 (seq 131 C_FADD R12 reads load addr 0x5d80), predates push; TI tracing owner (stub MIU/DCU or OOE) -- watch, it may land on MIU/DCU. Merge c0883a36 at next sweep. Bookmark TI 594.
- DI-61 RULED (MA rev 222, DCU tab rev 148): (1) loser's same-D2 miss waits, retries by port 0 (dcu_bank_miss_busy, dcu-bank-two-miss); (2) dcu-late-miss-port retired, MA-33 path kept by choice. Bookmark DI 100, MA 222.
- Sweep 11-27: criss-cross merges (10 merge bases) hang ort for hours. Merge with `git merge-tree --write-tree --merge-base=<C>` where C wraps a synthetic tree: the theirs-side oldest first-parent commit containing every base, with files of its unique non-merge commits taken from HEAD; check the result's diff vs HEAD equals theirs' unique files, then commit-tree -p HEAD -p theirs.
- TI-586 (TI rev 588): TI took dcu_p1 seal() and the TL id ride-along (2f1fde73); sweep knobs not taken. My seal() commit is no longer owed.
- MI-46 CLOSED (MI-47, MI rev 71): F-SHARED negative-sum bin and control; ccr-58815650 merged in the 11-27 sweep. Gate on 8d9064c5 failed cg twice by OOM compiling miu_form's harness; fixed by miu_form in tools/heavy-units.json (merged 11-27).
- MI-40 RULED (MA rev 209): miu_grp is an inner helper of miu_a2 (lv/am_cm06h from miu_agu8 flops at arrival 0, ge_cm06h gone). Fix (i): one extra (* keep *) copy of the leader lines in miu_agu8 (<=50 compares each, ~41 flops), a third only if still >25; (ii) drop_split-to-pass rejected. Owed by MI: sum/lq/footprint depths and miu_agu8 flops. MIU tab rev 221 (miu_tlb 4,259, miu_pair 754, budgets rows rewritten). MI-40 (4) asks TI about list-valued assert/control in feedback.json.
- OA-486 AGREED (MA rev 210; MI, OA notified): invalidate may lose the refill request, never the lane; MI owes an assertion (outstanding MQ line completes or re-misses within pass + refill bound) and a control (mutation marks the lost line done). Bookmark OA 486.
- MI-42 ACCEPTED (MA rev 211): lc_cm06h keep copy (miu_agu8 LC=1 on octets 0/2, 453 flops, +328 total), miu_a2 in-flop 25.0 at zero margin, third copy pre-approved; lc budgets and miu_grp inner declaration by MA citing 209/211. MIU tab rev 226. Bookmark MI 66.
- MI-43 (FYI, no row): L0 6 priced, cm128 +0.471% (<0.5%, MA rev 199 reopen not triggered), cm32 +1 cycle, colwalk +0.078%, RR = LRU. L0 6 stands. Bookmark MI 67.
- MI-32 ANSWERED (MA rev 203): model fix -> old prices stale. Ruled-config prices: vadd +3.08 (cold), ropediv +2.10 (leader), rope +2.58 (L0; 8e +0.30, bcast +0.91), provswap +0.85, colwalk +0.115, cm32 0. Budgets approved: miu_a2 arrival 0 (v_cm04h,rv,lsi,lq,la,fm,l6,rh,va,c,l0*), ge 12; miu_lead rk_cm05h 0 (if sources out 0). miu_a2 24.6 (0.4 left, growth to MA). L0 refill loop (cm06h miss -> cm11h) signed by MA under MA-32 when MI sends text (else TI row). RR stands; MI prices LRU (adopt if >0.1% gain, <100 flops) and BCAST on all kernels (adopt if no worse; rope >1% after -> L0 of 6). disp copies 1/quarter. Faults: A2 drops list; F-RO/F-SHARED/.const to A3. 1 port decided. miu_tlb 3,634 (L0 1,104), miu_a2 361, miu_lead 332. MIU tab rev 203 has it; MIU snapshot rev 203. cm128priv still owed. Bookmark MI 58, MA 203.
- DI-54 SIGNED (MA rev 202): dcu_bctl.feedback.json table ft_q_cc03h (reader ftn_cc02h; port loop @2 pw_cc02h; fill @4 gfa/wfc_q_cc04h from wfs/wfw/wff_q_cc04h; asserts bctl_ft_one_writer/fill_margin/lookup_margin; bounds 22, port head 4). fr_cc03h out. DI commits when TI form on its branch -> close MA-32 (Opens table, mark closed). Bookmark DI 93, MA 202.
- DI-52 (MA rev 201): lint roles by stage: port (02) = loop writer, fill (04) = later writer (table at 03) accepted; bounds 22/4 stand; DI confirms held fill meets cond 3; final text after TI answers DI-51 (generate-row shape) -> MA signs, close MA-32. Bookmark DI 91, MA 201.
- TI-548 (MA rev 200): Daniel approved OA-479 (b) two-writer L23 form; TI building lint (gate-scratch/TI-tw 69381fed per notice). MA signs DI's one-table fold-table declaration (by MA; fill = loop writer, port write = non-loop writer, cond 3/5; bounds 22/4) when DI sends text; then close MA-32. Bookmarks TI 547, DI 89, MA 200.
- MI-31 RULED (MA rev 199): front (ii) fixed leader (quarter's first lane) + L0 TLB 4 entries/slot in A2 (23.7 NGD to payload flops), 32-entry TLB in A3 refills L0s, off hit path; no L1 hit change -> split dead, nothing to AR/DA. ropediv +2.1%; cm128priv >0.5% reopens. MI owes: miu_a2 rest in parallel w/ L0 (which faults must drop at A2), 32-entry 1 port vs 4 (<0.1% -> 1 port), page-heavy kernel (>8 pages/slot), trace zero-cost drop_l0 (model must charge no-hit), build miu_tlb+miu_a2 -> budgets+flops (L0s ~1,200). MIU tab rev 188 has it (TLB row, translation, H+1, tlb budget row and contents, flops form 6,900/ids 560/pair 1,042/lead 199); MIU snapshot rev 188. Bookmark MI 56, MA 199.
- MI-30 ANSWERED (MA rev 198): bare TLB 16.5 NGD > out 12; A2 misses under (i) 33.2, (iii) 33.0, (ii) 26.5. MI proposed split TLB at match vector (A3 PPN) = +1 L1 hit (PA/pa_fold at DCU H+3) -> NOT adopted (Daniel's number; WP-off hit 9 cost 0.8-1.1%); fallback to AR+Daniel. MI measures L0 TLB 4/8 entries per slot in A2, 32-entry TLB in A3, L0 miss -> no-hit path + refill; NGD to payload flops under (i)/(ii) fronts; model price. Rule order: (i)+L0, else (ii)+L0 (ropediv +2.1%), else split to AR/DA. Adopted: every-bank gate, id quarter pick + 3-cycle hold (all 0 cycles). miu_lead (b) 21.2/24.7, 199 flops; miu_pair 1,042 flops (576 disp copies per 4 lanes). MIU tab edits pending ruling: miu_form 6,900, miu_ids 560, miu_pair 1,042, miu_lead 199, tlb/a2 budgets. MI-29 is TI/DI (rope bank fix, wb-refetch control, cm128 watchdog). Bookmark MI 55, MA 198.
- MI-28 ANSWERED (MA rev 197): miu_ids 556 flops/18.0 NGD; arrival 0 for all inputs IF each source port out 0 in its ngd.json (rcap qid, lead sv/lv/rs, a2 dp, rid source), both sides one change. Quarter pick + 3-cycle drop hold accepted, model matches RTL; bins: own-quarter-empty-while-other-free stalls, drop-held-id stalls, same kernels as MI-27; >0.1% cycles -> re-rule (cross-quarter borrow / early free). MIU tab: miu_ids 450 -> 560 at next edit (with miu_form 6,900). Bookmark MI 53, MA 197.
- MI-27 ANSWERED (MA rev 196): miu_lead whole leader sum 37.4 at A1 (as specified 49.1). A1 = MI's (b) narrow 16-bit sum + 14-bit pick + set/bank + valid (27.9 before disp copies). (1) every-bank gate adopted, priced (S1, cm32priv, cm128priv, bank-skewed; re-rule if >0.1% cycles). (2) leader whole sum at A2: MI measures (i) flopped one-hot + A2 AND-OR pick (tlb/a2 at that arrival), (ii) fixed first-lane leader + model drop rate (incl. divergent kernel), (iii) TLB dual-compare high bits vs R_hi/R_hi+1 -> MA rules on numbers. (3) per-quarter keep copies of disp, sh1/sh2 from miu_pair to miu_lead approved. (4) C at A1 in miu_form, c_cm06h out 0, approved; miu_form 6,851 flops -> MIU tab 6,900 at next edit. MIU tab NOT updated for MI-27 yet (wait for ruling). Bookmark MI 52, MA 196.
- MI-26 ANSWERED (MA rev 195): (D) adopted, agu8 24.5 NGD / 412 flops, MI-24 (A) withdrawn, mw dropped; local b unsigned 17-bit (O-69) -> no ctx carry, C one add per slot in miu_form; agu8 out 0 / A2 in 0 (if flops hold chosen field); grp out 12, a2 from grp arr 12 restored. Owed: miu_lead measurement + leader VPN add placement. MIU tab rev 181. Bookmark MI 51, MA 195. MIU snapshot rev 181.
- DI-47 ANSWERED (MA rev 194, DCU tab rev 126): fold-table port 4 credits (round trip) + 2 entries confirmed; overflow control = 5 credits (must reach 3rd entry); port wait max 2 seen. MA signs port-level L23 entry (by MA) when TI's two-writer form lands -- DI sends text. Bookmark DI 85, MA 194. DCU snapshot rev 126.
- DI-46 ANSWERED (MA rev 193, DCU tab rev 125): fold-table port write buffer in dcu_bctl + credits to driver; depth max(2, credit round trip); fwcr_cc03h flop pulse cycle after entry writes; counter starts at depth; assert no overflow (control depth+1), CHECK wait <= 4 + occupancy. Bookmark DI 84, MA 193. DCU snapshot rev 125.
- DI-45 rev 83 ANSWERED (MA rev 192, DCU tab rev 124): fold-table port = port writes (fwe/fws/fwy/fwf) + fill at W; held fill yields at most once then wins -> DI-37 22 < 32, port-write wait <= 4 (fill slots); CHECKs+bins; control always-yield under flood; no invalidation rate limit, part 4 must not time the port. Bookmark DI 83, MA 192. DCU snapshot rev 124.
- MI-25 (MA rev 191): MI's agu8 fix (per-lane rbase-W) 32.2, A 27.9, MI wanted (C). MA: measure (D) first -- b = S - (W<<16), S ordinary exact sum; W aligned 2^k => F-ADDR iff S>>(16+k) != W>>k (A2), b = S low 16+k bits (wiring); addr = R + {b>>2,l,b[1:0]}: low 16 bits wiring, only (5+k)-bit add into R carry-select, needed only for leader VPN (miu_lead after leader adder, or A2 before TLB: MI measures both). Local = C | l<<2, C per slot in miu_form. A1 = ordinary sum 24.5. mw not needed. (C) rejected unless D fails (interleave decided in MIU -> late answers). MI-24's 4.1k flops should mostly go; MIU tab NOT yet updated (wait for D's numbers, then rewrite the MI-24 paragraph and budgets). Bookmark MI 50, MA 191.
- DI-45 ANSWERED (MA rev 190): DI-37 = 4+5+1+11 = 21 < 32 ok. The 4 dcu_bctl "CCV-L23" nets are NOT feedback (no loop: fill state doesn't depend on ft table) but a two-writer write port (lookup 02, fill 04) -> one port-level entry in TI's two-writer form, content approved; add control for bctl_ft_one_writer. TI told: MA-32 should cover the two-writer form's "by" if it has one. Bookmark DI 81, MA 190.
- DI-44 ANSWERED (MA rev 189, DCU tab rev 123): snapshot wait bound 3*(slots-1)+2 = 11 accepted (MA's earlier 2*(n-1)+1 missed the margins); DI-37 form accepted, DI to put the number vs 32 in RTL row. CCV-L23: lint FEEDBACK_BY = (OA, AR, DA) -> MA-32 (new, Opens table m8yvbw8rqgz.1470) asks TI to admit MA for rtl/miu, rtl/dcu; meanwhile DI puts 4 dcu_bctl declarations in its tab for MA review; fallback AR signs reviewed entries. MA-31 still reserved for the AR 412 area row. Bookmark DI 80, MA 189. DCU snapshot rev 123.
- MI-24 RULED (A) (MA rev 188): agu8 27.8 w/ select at A1 (fanout); last select to A2, +~4.1k flops (agu8 660 each); miu_lead selects only leader low-bit field at A1 (set/bank/credit gate), full line at A2 -- MI to confirm lead fits BEFORE build; budgets grp/a2 in from agu8 arr 3, grp out 15, a2 from grp arr 15. Rejected (B) residual 26.0 nets, (C) form-dependent latency. Watch MI measurements (agu8, grp, a2, lead) + flop count. Bookmark MI 49, MA 188. MIU tab rev 177, snapshot rev 177.
- MI-22 rev 48 ANSWERED (MA rev 187): miu_form 24.3/22.5 ok; pen_cm03h out 3/arr 3 (keep copies); rk {ctx,hi+1,hi,lo8,bl} replaces rx, ctx add in agu8 carry-selected per lane on narrow carry; no kill clears window valids (only cta write); fill only for live memop (assertion per-slot generation, control orphan fill across reuse); MI-23 closed. MIU tab rev 176. Bookmark MI 48, MA 187. Watch agu8 measured figure. MIU snapshot rev 176.
- MI-23 ANSWERED (MA rev 186): not (a) -- O-69/O-83 natural alignments contradict under W = local_base+3LC (checked PW 1,2,4). (b) cheap form: B_lo 4th narrow operand; per CTA/region store f (ctxw bits), U, U+1 at table write; H-1 f+ctx cin 0/1 selects U/U+1 (~10 NGD), both R_hi flopped at H; ~900 flops (miu_form 5,500). MIU tab rev 171. TODO: tell IS (low priority) that ISA "forms R(ctx) by wiring" (O-69, sec 5.9) does not hold; formula unchanged. Bookmark MI 47, MA 186. MI withdrew MI-23 at rev 47 building (b) "R_hi, R_hi+1 per CTA" -- crossed with MA 186; check MI handles ctx (per warp) via the f+ctx add. MIU snapshot rev 171.
- MI-22 ANSWERED (MA rev 185, MIU tab rev 169): miu_form ports confirmed; ccv_rau_miu_cta captured in flops first (A-61), write next cycle; kill-clear source for MI to name; slot-form base mux in miu_agu8 (23.3+1) on per-octet keep copies of win/select, not miu_cap; if agu8 >25 MI reports, mux stays, MA re-decides. Watch MI's measurement. MIU snapshot rev 169.
- DI-39 ANSWERED (MA rev 177, DCU tab 116-120): fill keeps lead-then-payload (one-cycle form = enable from input, CG-5):
  lead F+1 from dcu_mshr's F read (valid + bank one-hot), payload F+2 (mshr + fill flops), victim F+2, write waiter from F+4.
  DI prices model pickVictim F+2 after ti-tblat; >=0.5% -> earlier lead on MLC rsp with req_id (schema row).
- MI-21 DECIDED (MA rev 176, MIU tab rev 165): miu_form owns form state (H-1 beside miu_pair; forms within slice 1, before M0);
  O-83 by two sums per lane, interleaved adder narrow (log2(32L)=22 bits, R(ctx) wiring), decision ~8 NGD selects after adders;
  (b)/(c) out. AR told FYI (amends AR revs 211-219 'no new adder'). Watch MI's NGD and gate count; power gating if needed.
- DI-34 closed by DI (d400b928: bctl growth 518fe798, mshr CG c4061f75).
- Sweep 2026-11-23 pushed ef87bf44, full PASS (ngd 3h23m, cg 3h04m).
- AFTER ti-tblat LANDS (TI-532/AR 411, MA rev 174-175): re-run MA-30 grid (k5/4/3/2, B9; S1, cm32p, cm128p) plus L1 capacity (AR rev 344)
  and hit-latency (AR rev 363) steps on the fixed testbench; k=4 stays meanwhile; row to AR only if a step < 0.5% or ranking flips.
- DI-36 answered (every lookup gets a queue entry, D1 write, miss-wait at D3). DI-37 answered + amended (fill write waits <= CCV_DCU_FILL_AGE=4; bound K+gap+1=10; MA rev 172, DCU tab 115); TI asked for the param (require FILL_AGE < BANK_AGE): open.
- TI-531 answered (MA rev 173): committed-stores-first stays; MA prefers slow region ends at 1 MiB. AR 410 ruled that way (1)-(5); DRAM latency 10 is a placeholder Daniel sets.
- Open, not MA's: MI-20 (UE two answers; TI), DI-38 (check-kernel under model; TI; (5) cm128 memop hold 22679 vs 20480 watchdog, AR 410 makes watchdog derived).
- DI-34 closed from MA side (MA rev 167-168: update 2 conditions; Q(3) option a). DI-35 answered (MA rev 169; DCU tab 112-113): retry pick accepted, wait-again re-stamps head.
- AR-409 agreed (MA rev 165; DCU tab 107-109: probe takes unlaunched wb buffer line, ack=1, cancels). DI-34 v2 deviations (i)-(iv) accepted with conditions (MA rev 166, DCU tab 110).
- DI-34 ANSWERED (MA rev 164, DCU tab rev 106): mshr D2 PA staged, D3 writes with forwarding; waiter payload in every bctl queue entry (~75 flops, 1,200/bank). DI notified.
- DCU SLICE 2 COMPLETE (MA revs 159-162, DCU tab revs 89-96, MIU tab rev 163 UE rule; DI and MI notified;
  snapshots dcu 96 / miu 163; dcu-impl 3a-3d). Part 2 eviction/wb (fill's own entry reused for writeback, 2 wb
  buffers, DI-21 answered), part 3 stores (std RF 4x16x256 a bank + masks in flops per MACRO-1; dirty bits to
  flops, tag RF 136 bits; store-hit ack at contracted cycle; fill merges only stores ahead of first load),
  part 4 probes (4 buffers, RMW tag lookup), UE second answer both tabs, TI-475 repair/BIST groups.
  NEXT: MIU slices 2-4; then TI's cold-TLB scenarios; fold the coverage bins into the tabs.
- (history) DI-30: DCU slice 2 first, in parts. PART 1 LANDED (DCU tab rev 89, MA rev 159, DI
  notified; snapshot rev 89; dcu-impl phase 3a): dcu_mshr 16 (merge 4, miss-wait in bank queue = MA-12 hold, bank
  order rule), MLC req at H+5 from D2, dcu_fill 4 FBs (F capture, F+1 encode + victim, F+4 answers), write at W
  under BANK_AGE with tag RF RMW, tag-stale re-looks, late order aged-bank > fills > banks. NEXT: part 2 eviction
  and writeback (DI-21; dirty victim read before W; writeback's place in the MLC request order), then part 3
  stores (std index in merge list; merge only stores ahead of first load), part 4 probes, UE second response,
  then TI-475 column repair/BIST groups. DI-28 (PLRU D+3, owed max bin) FYI only.
- DI-25 ANSWERED (MA rev 156): dcu_btag's own flopped pick from channel leads confirmed (DCU tab rev 83); slice 2: tag-RF fill is RMW in the bank's free gap (RF stays 1r1w,
  forwarding covers same-set writes); model keeps the stub's same-cycle loser with a zero CHECK under MIU=model.
- MA-30 AGREED (AR 405, rev 409) with conditions, answered MA rev 155, DCU tab rev 82, MIU tab rev 161 (pushed with
  snapshots): mispredict = no contracted slot, re-read H+5, late at due+2 (no rsp field); fold table has a valid
  bit (2,560 flops/bank), no match = miss, no read; fold = XOR of PA[47:16] k-chunks (= PFN), kept in miu_tlb
  entries; TI asked for sim/skel/wayfold.h + rtl/common/ccv_common_wayfold.sv; CHECKs, controls
  dcu-wp-nocompare and miu-fold-flip, bins. Waiting: TI lands pa_fold, params, helper.
- DCU PHASE 2 SLICE 1 LANDED (DI-20): DCU tab rev 73 ("MA's Phase 2" section; Phase 1 arrays bullet and ECC
  bullet fixed to (137,128), 512x137, 72 check bits, 140-bit tag word, fold in flops). dcu-impl.md: status,
  RTL modules and phases 2a-2d, waits row. Snapshot dcu-spec.md at rev 73. Draft: scratchpad dcu-slice1.md.
  MA-30 RAISED (rev 153; AR to agree, TI apply, MI/DI FYI, all notified): fold table k=4 in dcu_bctl flops
  (64x8x4 a bank), MIU sends pa_fold (k bits) in ccv_miu_dcu_req payload from A2, SEL=index, HIT 8.
  Params asked: WAYPRED_BITS 5->4, SEL 1->0. Pricing (both models, 42b8458b): k5 S1 59,592 / cm32p 2,099,633 /
  cm128p 2,606,850; k4 -0.02/-0.17/+0.30%; k3 -0.02/-0.40/+0.65%; k2 +3.47% cm128; B9 (HIT 9) +1.11/+0.79/+0.88%.
  Answered DI-23 (rev 154). WHEN AR AGREES: MIU tab A2 gets pa_fold (fold of line PA tag bits), notify MI;
  mark MA-30 agreed in DCU tab text ("AR to agree" in status line, LRU para, arrays bullet defaults).
  DI-21 (slice 2): writeback-buffer-full case; answer with slice 2. Slice 2 owes: UE recovery's second
  response under the same req_id (MIU keeps the id on ded), a rule for both tabs; column repair and BIST
  groups for the 8 KiB data instances (TI-475), promised in the DCU ECC bullet.

- DI-18 DECIDED (MA rev 148): on a CE MIU corrects what it holds and redelivers as a refill; DCU counts,
  rewrites, sends nothing more (amends MA-28 (c)'s replay half to TI-513 (2)). MIU tab rev 153, DCU tab
  rev 65, dcu-impl.md row. Snapshots refreshed.

- MA-27 FULLY CLOSED (MA rev 149, AR notified): A1 hold 0 at defaults on S1/cm32priv/cm128priv; dup drops
  <=0.008% (MI a0afe9fc, CCV_MIU_DUP_IDEAL pricing aid). MIU tab rev 154. "TI landed the fields" marked; snapshots refreshed at 155/65.
- DI-18 also: AR-403 amended AR 401 to MIU-corrects (AR rev 407).
- MIU PHASE 2 IS FIRST (MI-15, MA rev 138; MI says at Daniel's request, no DA row found, order is MA's anyway).
  Slice 1 (L1-hit path) LANDED: MIU tab rev 147 "MA's Phase 2" (stage table at L1_HIT 8, partition of 17
  modules, port budgets), miu-impl.md module list + phase rows 2a-2d, snapshot. NEXT: notify MI once pushed;
  then slice 2 (miss/refill: slot reservation, hint, MIU_FILL 2; multi-pass from MQ), slice 3 (stores, drain,
  payload RF, st.pred, std credits), slice 4 (atomics, SPM, walker, faults, discard/replay/kill). Then DCU's.
- MA-27/MA-28 DECIDED (AR 400/401; MA rev 143): drop bit (MIU refunds the credit at A2, DI-12; ent_ret only for
  lookups that entered the queue) and (c) check bits on rsp, MIU syndrome in R2, ECC stays 1; req_id live until
  completion delivered; CCV_DCU_ECC_INJECT replaces MIU's. TI applies fields. In MIU tab rev 148, DCU tab rev 64.
  OWED: price the A1 hold (bank < CCV_DCACHE_LOOKUPS credits) on S1/cm32priv/cm128priv once MI's model has it.
- DI-8 DONE (MA rev 142): p1 credit returns, d494cf9b pushed on SCOPED PASS 26/26.
- MI-17 (MA rev 144): A1 credit gate = used[b] ? ge2[b] : ge1[b] (cred flops ge1/ge2, lead flops used). MI-18
  (MA rev 145): every MIU receiving end no-flop at RTL; CCV_LAT_MIU_PAIR_LAG = addr path - memop path (3), require
  >= 1, TI derives. MIU tab rev 150, snapshot refreshed.
- Sweep 2026-11-21: merged infra 16, MI ccr-58815650, DI ccr-5e4d6c70, AR ccr-80102643. NOT merged: OI's
  ccr-57eff422 (conflicts in OI's files); AR 402 already asks OI to merge TI's branch in, so no MA row.
- MI and DI ARE RUNNING (MI session_01QPk2jzH1Gd3DcxK4F4pwCC, DI session_01QPk2jz5TVESyWMKVKjqqEA; their
  roster commits arrive on their branches). Their tabs: MI c1311541-4219, DI 1ea5d5b3-6e9c (bookmarks MI 3, DI 2).
- DI-2 SETTLED (AR 390, OA-442; MA rev 121): a way mispredict (due+2 earliest) takes the conflict loser's
  path; TI-478 slot stays due+1. DCU tab rev 56, impl docs, snapshot updated.
- MI-2 (MA rev 119): confirmed MI's model walk with 3 levels (W_VA 64, page shift 16), identity
  translation, cold TLB per kernel. Page-table format is AR's (AR 391); IS owns the fault cause; PTE width and per-level latency are model params (MA rev 120).
- BANK_AGE DONE (RH part 1; MA rev 124): default stays 16 (a8 -0.09%, worse worst wait; a32/a64 +1%). RH
  HASH DONE (RH part 2; MA rev 125): stays 0; HASH=1 +2.90% on cm128 (tail piles on few banks).
  Gap: no heavy pow2-stride DCU kernel in S1 (transp4 too short); hash stays a parameter only.
- MI-6 DONE (MA rev 126): CCV_MIU_TLB=warm default through M0, cold opt-in with its own gated scenarios
  (TI's); flip is phase 1a, first after M0 (miu-impl.md). Watch: TI picks up the cold scenarios.
- DI-4 DONE (MA rev 129-135): un-noticed refill at F+4 (floor from fill payload), noticed stays exactly 4 after
  its notice lands (F+6). DI measured notices off -0.43% (31 faster, 2 slower). MA rev 130: CCV_DCU_NOTICE=0
  default, channel kept (valid low). AR 394 agreed (+ S1/cm32priv rerun, MA 131). OA 453 agreed on a condition
  that misread the hint; MA 132 restates it (off: zero refill hints, F+6; on: OA-23 controls). WAITING OA's
  accept: done (OA 454); DCU tab rev 59 corrected, snapshot + dcu-impl pushed 99341c99 (MA 133). MI bench
  met (MI rev 12); TI asked for a gated CCV_DCU_NOTICE=1 scenario (MA 134). DI-4 CLOSED (MA 135; S1 -0.43%,
  cm32priv off 2,105,390 vs on 2,105,392). Watch: TI's NOTICE=1 scenario. Phase 2: earlier notice, MLC
  tag-lookup first, lead field only if it can't reach F+4; skip under 0.5% on S1.
- MA rev 127: IS re VA[63:48], no change (MI confirmed full 64-bit fault address). MA rev 128: TI-488
  accepted; interim ooe_wake LAT_MISS 17 pin vs L1_CMPL 16 is OA's/OI's. TI-490 (DA): RESUMED PASS counts
  as the full clean gate; after gate-wait says killed, rerun the same command with CCV_RESUME=1 (once
  6464a030 is in). DI-3 asks TI for per-impl pins (+1.78% vs stub).
- Sweep 2026-11-20: ~196 commits merged (all remote branches but release/gate-scratch); two full gates
  lost to restarts, pushed 30a71d7b on SCOPED PASS 24/24. Merge helper: scratchpad sweep-merge.sh (git
  merge 90s; on a criss-cross stall, merge-tree each base, take fewest conflicts; generated files keep
  HEAD; one-sided file changes take that side; else stop; commit-tree -S). Rebuild it if gone.
- MI-3 (MA rev 123): a held load holds only itself; a pending fence holds its warp's younger memops.
  MIU tab rev 145 (snapshot refreshed). MI-2 closed (AR Common tab rev 8/9: 3 levels 6/13/13, VA[63:48]
  non-zero is F-ADDR).
- TI-487 SETTLED as (3) (AR 389 final, OA 441; MA rev 117): DCU withholds the fatal merge read; RAU's
  machine-check kill waits on no ack from MIU (still requires the seven others). DCU tab rev 55;
  dcu-impl.md bin added. TI lands it. (MA rev 117 says DCU rev 54; it is 55.) Bookmarks AR 392, MA 117.
- MA-26 defaults: 5 bits + recent (AR 386, MA rev 112); DCU tab rev 52, impl docs and snapshot
  updated (c0b8c899). AR's cm128 5/recent confirmation is still running: if it loses >0.2%, revisit.
  MI/DI handoffs pushed (73928bba). OA added MI 39 / DI 43 to the sweep series.
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
