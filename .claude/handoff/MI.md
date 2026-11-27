# MI handoff (MIU implementation)

Keep current at every task's end. Role and ownership: docs/miu-impl.md (MA's handoff,
section 1). Spec: MIU tab of the per-block specs, pinned at
docs/design-snapshots/miu-spec.md (rev 144); the live doc
https://claude.ai/artifact/DJeg9Hh8rkPDecq4hrAz35 wins. DCU tab: dcu-spec.md.

## Who and setup
- MI = session_01QPk2jzH1Gd3DcxK4F4pwCC (roster commit cc8ed42d). Register tab MI node
  c1311541-4219; write only there. Daniel (DA) is a senior microprocessor design engineer.
- session-home installed (Daniel OK'd at session start); --check matches.
- Daily sweep scheduled task trig_01Szj1auKDJc4j8N6oZMnp69, 02:39 America/Los_Angeles.
- Toolchain: ./tools/setup-toolchain.sh, then ./tools/regen.sh.

## Branch, push
- Work tree /home/user/custom-cuda-core, branch ccr-58815650-0ch1hh (MA's branch
  claude/miu-dcu-microarch-spec-664pgr merged in at c524e330: handoffs, snapshots).
- Push: tools/gate-push.sh with CCV_PUSH_BRANCHES=ccr-58815650-0ch1hh, then tools/gate-wait.sh.
  Merge commits only. No PRs. No model ids or dates-as-deadlines anywhere.
  Name each commit for TI to merge in the MI tab.

## Working rules beyond CLAUDE.md
- TI-490 (DA ruling): RESUMED PASS counts as the full clean gate; after gate-wait says killed,
  rerun the same gate-push command with CCV_RESUME=1 (needs TI's 6464a030 merged in).
- MI owns sim/miu/, rtl/miu/ (after MA's Phase 2), test/miu/. Never edit schema/, params/,
  tools/, rtl/top/, stubs (incl. class Miu in sim/skel/kernel.cpp), blocks.list: MI-n row,
  TI in Needs. Architecture questions: MI-n row, MA in Needs.
- Model: cycle-accurate at the ports and events, not an RTL clone. Swap boundary: ports
  only; oracle for checks, never decisions. Stub controls (--break) must keep failing.
- Ring a notice only for a row that asks something of its receiver (register skill).

## Register bookmarks
- Daily sweep 2026-11-24 (Tue): AR 421, OA 502, IS 201, TI 582, OI 426, CP 160, RA 159, RI 92,
  MA 211, MI 68, DI 93, DA 134, Conventions 20; specs MIU 226, Common 9, DCU 126. Next pings: Friday.
  2f3c8db4 pushed (SCOPED PASS); TI and MA told. Sweep merge eba4a37a: ccr-183cc441 13 (carries TI's
  infra and DI's ccr-5e4d6c70), ccr-9eb50716 33, MA's spec branch 20, ccr-80102643 4, ccr-57eff422 2;
  full gate-push on it.
  To close at MI's next write: MI-20 (DI rev 73: UE second answer works under both MIUs), MI-29
  (DI-50: dcu-wb-refetch needs no kernel; unit control holds it). TI-571: orphan-declaration check
  in TI's 55d089a6 (refuses a feedback.json with no module beside it, or a key naming an absent
  instance): ccv_miu.feedback.json lands with the ccv_miu assembly. TI-580: MA may sign under rtl/miu.
  AR 416: credit avail form per end in params/links.json (sender's architect); MIU NS multi-spend
  reads registered thr_q (+1 depth); {K,2K} QDEPTH 16 waiver 8 flops, charged to MIU's 2%.
  DA 134: non-OOE NGD caps stay 25.
  MA-33 (2) answered in MI-45 (rev 69, MA rung): rope/ropediv's bank CHECK was the window-fill bank
  bug fixed in 8c9a6cd5 (unpushed at MA's 922bcc25). Ring MA with the pushed tip. RTL: fill-vs-pass
  same-bank case + control into lead_tb with the window fill.
- Daily sweep 2026-11-23 (Mon): AR 414, OA 474, IS 201, TI 529 (TI-531), OI 405, CP 160, RA 158, RI 91,
  MA 197, MI 54, DI 69, DA 131, Conventions 20; specs MIU 163, Common 9, DCU 115 (spec content nodes:
  MIU aa7a288a-dae2, Common 55ddf104-fe08, DCU c18a112b-d2c6). Next pings: Friday.
  MI rev 39: 012519d8 pushed, DI may send the UE first answer (DI, TI rung). TI-522: measure waypred
  deltas with CCV_MIU_IMPL=model + CCV_MLC_WARM=1. AR 410/TI-531: P_TIMEOUT_MEMOP becomes derived.
  TI-532 (FYI, rev 530): ti-tblat 8daf7a2c ends the tb slow region at 1 MiB; kernels with data >= 0xC0000
  drop (localsp 2144->164, privwin, waypred...). When it lands, recheck MI's IMPL_PINS (privwin priv_form=10)
  and any waypred/localsp numbers taken before.
  AR 403/404: MIU corrects CE (syndrome R2, completion withheld 1, fix in the stage after on flopped
  data+syndrome, K=128); UE on a clean line: DCU refetches under the same req_id, MIU keeps it live.
  AR 405 / DCU tab 84: mispredict = late answer at due+2 under the original req_id, no credit;
  pa_fold = XOR of PA[47:16] 4-bit chunks (wayfold helper, DI-24 asks TI); control miu-fold-flip.
- Sweep 2026-11-22 merge, pushed at 8170fdcf full PASS (gate-push --full, job-gate-push-20261122-104808-444.log): ccr-183cc441 54,
  ccr-5e4d6c70 10, ccr-80102643 10 (MA.md conflict: kept MA's newer f9fb834e), ccr-9eb50716 5,
  ccr-c22116ce 2, MA's spec branch 3, ccr-57eff422 17 (OI's; clean now).
- Sweep merge d26849c3 (ccr-183cc441 25, ccr-5e4d6c70 20, ccr-80102643 4, mi-dev A1 hold
  b1a85fa6) under full gate-push (job-gate-push-20261121-104904-28964.log). OI's ccr-57eff422
  conflicts in OI's OOE files: left to OI (AR 402); not merged.
- MI-8 at TI: under UE_INJECT=1 predlane/predmerge fail quiesced_at_end on ooe_miu_memop. Per
  AR 387/389 a store whose merge read was withheld never drains; ask: exempt mce runs.

## Settled since the handoff (MA tab rev 119-122)
- MI-2 settled (AR 392, Common tab rev 9): 64 KiB pages, 3 levels 6/13/13 (VA[47:42], [41:29],
  [28:16]), 512 B root, 64 KiB nodes, 8 B PTE (V/W/X bits 0-2, PPN 47:16), leaf-only TLB,
  identity translation, PTE value unused. Base is a CSR (CRU's, address TI's): model holds
  Pending::kWalkBase and must assert no kernel address falls in Walker::span(). PTE width and
  per-level extra latency are params (AR 391, extra 0). TLB cold at each kernel start.
  .global with VA[63:48] set or < 0 is F-ADDR in A2 before any walk; .shared not translated.
  Walk V=0: F-ADDR (data), store/atomic W=0: F-RO.
- AR 390 / OA-442: a way mispredict is NOT a late hit at due+1: it takes the bank-conflict
  loser's path, data due+2 at the earliest, answered as a miss. miu-impl.md updated (re-read
  its bins from MA's branch before building that bin).

- 2026-11-20: phase 1b first run. Local hook also selects DI's DCU model (CCV_DCU_IMPL=model:
  makeDcuModel in kernel.cpp, dcu_core.cpp + dcu_block.cpp in blocks.list; scratchpad
  re-saved). Both models, 64 kernels clean at WAYPRED_BITS 5/1/0 (L1 hit 8/9).
  b196110b: one hint promise a slot a cycle (bin hint_slot_taken, control hint-same-slot), bin
  l1_dcu_late. MI-9 rung to TI (rev 11): stub's latent hint bug, bins, a same-set kernel (no kernel
  reaches dcu_wp_wrong: all lines within 64 KiB), L1_HIT_BASE doc. Re OA-453 (rev 12, OA rung):
  notices off -> MIU sends no hint; hint controls need a CCV_DCU_NOTICE=1 scenario.
  Bookmarks since: OA 455, MI 12.

## Open work, most urgent first
00. MA rev 203 (re:MI-32) ruled: budgets approved (LANDED 469769e0); disp copies one per quarter (DONE 5b6c7418,
   miu_pair 754 flops, miu_lead 23.5); faults split adopted; 1 TLB port; RR stands; price LRU (rope, provswap,
   vadd, cm32: taken if >0.1% saving and <100 flops) and BCAST on ALL kernels with RR and LRU (adopted if no worse
   anywhere; rope >1% with both -> MA looks at L0 of 6). Knob CCV_MIU_L0_LRU=1 (1195958e).
   Rows: MI-35 (rev 60, TI+MA rung): L0 loop declaration text; lint has no cross-module form -> TI to answer.
   MI-36 (rev 61, MA rung): budgets/copies done, first LRU/BCAST reads (rope RR 677 LRU 677 bcRR 666 bcLRU 677;
   provswap 2249/2241/2249/2241; vadd 134 all). EDIT MI-36 WITH THE FULL TABLE when pricing ends, ring MA.
   PRICING (detached, serial): price32b (ruledbc all + cm128) -> price32c (ruledlru, ruledbclru all + bclru cm128)
   -> price32d (cm128 base, ruledp1). price32 itself was KILLED (launched without bg-run): cm32 borrow/dropfree and
   its cm128 runs lost. Table: cd scratchpad; python3 tab32.py price32 base,gate,lead,l0x4,l0x8,ruled,ruled8,
   ruledp1,ruledbc,ruledlru,ruledbclru. Jobs: ~/ccv-logs/price32{b,c,d}.log.
   Gate 0208d2ad FAILED cg only (miu_a2 9 ungated flops > 7; fixed: one valid flop a stage). Then committed
   06fc2171 (L0 filter + fix), 604e3906 (miu_grp), merged TI's claude/custom-cuda-core-infra-6msg93 (ef260513,
   has b780f324) at f5be7a33. GATE-PUSH IN FLIGHT on that (scoped, CCV_JOBS=3; see newest job-gate-push log). When pushed: RING TI WITH THE TIP (MI-34 promise).
   MA rev 204: MI-35 signed in substance; wants assertion+control for the 8-cycle bound -> DONE in scratch
   worktree scratchpad/wt-tr (test/miu/tlb_tb.cpp bound check + control tight; run-rtl.sh line): COPY BOTH INTO
   mi-wt AFTER THE PUSH and commit. MI-37 (rev 62, MA rung): BC+LRU explained (rope 6-page set), L0 of 6 measured
   (miu_a2 24.7, miu_tlb 18.2, +552 flops) and priced small kernels; proposal L0 6 RR no bcast. price32e queued
   (ruled6/ruled6lru all + ruled6 cm128). TI-552: b780f324 MERGED (f5be7a33).
   MI-38 (rev 63, TI rung): ccv_miu instantiates miu_a2+miu_tlb. MI-39 (rev 63, MA+OA rung): L0 no-dup filter
   (wt-tr miu_tlb.sv: pm/sa/ra match + wl/wv last-write copy; l0_nodup assertion; tlb_tb controls tight, l0dup).
   MA revs 206-208 + OA-484 + TI-558 answered in MI-40 (rev 64; MA, TI, OA rung). READY IN wt-tr, COMMIT AFTER THE PUSH:
   rtl/miu/miu_tlb.sv (N0 6, filter, iv_cm05h invalidate, l0_nodrop, l0_bound SVA under CCV_CHECK), miu_tlb.ngd.json,
   miu_a2.sv (N0 6), miu_a2.ngd.json (vpn/ms required 0, MA rev 207), test/miu/tlb_tb.cpp (wvkeep, ivkeep), a2_tb.cpp (kN0 6),
   cg-build.sh (-DCCV_CHECK for miu_tlb), run-rtl.sh (tight, l0dup, wvkeep, ivkeep). NOT wt-tr's sim/miu/miu_block.cpp (L0T trace).
   ccv_miu.feedback.json: 5 keyed entries (u_a2 reads l0*_cm11h from u_tlb, ahead 5) after TI-560 lands (lists for
   assert/control; each control named under test/miu or sim/miu): asserts l0_nodup,l0_nodrop,l0_bound; controls miu-l0-dup,wvkeep,tight,ivkeep (MI-41, OA-486).
   miu_grp per MA rev 209 fix (i): trial set saved in scratchpad/grp/v5 (miu_grp, miu_a2 + ngd.json, miu_agu8 LC
   param + lc_cm06h keep copy, agu8_tb lc check + control lcl1, cg-build/run-rtl/cg-units unit miu_agu8_lc).
   miu_a2 in-flop 25.0 (zero margin), agu8 LC=1 453 flops 24.6. MI-42 (rev 66) to MA: asks lc_cm06h budget and
   who signs miu_grp's inner decl. a2_tb now models it (leaders per F as miu_lead, lanes, lc; controls line,
   split, fone FAIL; PASS), cg-build a2 adds miu_grp + --trace-max-width 8192; re-measured at N0=6: a2 in-flop
   25.0, CG unchanged. budgets final (MA rev 211 accepted MI-42): a2 lc arrival 0, agu8 lc required 0, miu_grp inner decl by MA revs 209+211; third copy pre-approved if a2 grows. v5 READY to commit after the slice-1 commit (grp/v5 has all files). MA rev 210 (OA-486): with the MQ's A2 write, add an assertion (an outstanding MQ line completes or re-misses within pass + refill bound) and a control (mutation marks the lost line done). wt-tr holds v5
   now; the slice-1 commit set is in grp/commit (restore before copying to mi-wt). Next row MI-45.
   Next MI row MI-42.
   PRICING DONE: MI-43 (rev 67) to MA, cm128 at 6 +0.471%. (old: price32f relaunched as price32g (bg-run, ~/ccv-logs/price32g.log; skips kept runs): reruns lost runs from scratchpad/orc on skel-lru, then cm128
   base/ruledp1/ruled6 one at a time. Table: cd scratchpad; python3 tab32.py price32 <cfgs>.
   Next RTL: miu_grp (group check ge, page split, drop_line, F-ALIGN, MQ write/lane map, drop_held).
0. MI-19 done: 2d2259bf + a0afe9fc + miu_pair pushed at 073943f3 over DI's 818285df (MI rev 35,
   DI notified). mi-push branch obsolete. DI-18 settled (model already corrects CE as a refill).
   MIU tab rev 150/153: H = first MIU flops hold memop+address; every MIU receiver no-flop; address
   lands CCV_LAT_MIU_PAIR_LAG (3) after the memop; miu_pair loads A1 fields from MQ at H-1.
0a. MI-20 CLOSED (MI rev 40, TI rung): DI's d400b928 sends the UE first answer; with DCU model, vadd/ldpar/hit
   hit ue_second_answer and ue-close-first is caught (1/3/7 CHECKs). TI adds the kernel lines.
0c. TI-537 (DA via TI): one common RTL credit implementation (rtl/common, TI's); miu_cred keeps its counters
   until it lands, then swaps. MI rev 42 told TI miu_cred's needs; TI-538/539 full form, ccv_common_cr_cnt (DEPTH, SPEND_W, REFUND_W,
   THRESH list); TI-541 (DA, AR 415 (5)): link credits keep the cr_go exception at a flopped sender, depths 4+2N (FYI).
   MI rev 43: no same-cycle return, capture stays in miu_cred. TI posts the port list after AR/OA/RA/MA.
0z. MI-27 (MA rev 196) / MI-28 (MA rev 197) BUILT on mi-dev (unpushed): 87731fb7 (miu_ids reshaped +
   miu_rcap + MiuIds model; CCV_MIU_DCU_IDS cap now per quarter), 8c9a6cd5 (model: window fill keeps one
   lookup a bank a cycle, TI-544; bin credit_hold_other_bank), cde9f4a1 (miu_lead (b): NGD 21.2/24.7,
   199 flops 2 gates, lead_tb + controls used/scale/last; miu_pair a1q {sh2,sh1,disp16} per 4 lanes,
   576 flops, a1f/a1x keep too). Model check-kernel: only --break dcu-wb-refetch (slotform) unnoticed under
   CCV_MIU_IMPL=model, pre-existing (committed model too); told DI in MI-29.
   - MI-29 (MI rev 54, TI+DI rung): TI-544 answered (rope fixed, nothing holds TI's landing; cm128
     watchdog: asked whether it was under the MIU model).
   - PRICING IN FLIGHT (detached): scratchpad price28.sh then price28b.sh (coremark128priv one at a time:
     each >6 GB; two at once get OOM-killed), logs scratchpad/price28/<cfg>.<kernel>.log, table:
     python3 scratchpad/tab28.py scratchpad/price28. So far (vadd, divtail, ropediv, colwalk-p1k, cm32priv):
     no credit or id holds anywhere; GATE_ALL, BORROW, DROPFREE cost 0 cycles; LEAD_POS +2.1% ropediv, 0
     elsewhere. When cm128 is in: MI-30 row to MA with the table, miu_lead's numbers, copy flops 576.
   - MI-30 (MI rev 55, MA rung): A2 measured with scratch prototype scratchpad/a2p/{a2p,a2q,a2m,tlb}.sv
     (meas.py): bare TLB 16.5 (vs 12); (i) 33.2, third option 33.0, (ii) 26.5; split at match vector:
     (i) 26.5 (lo fanout), (ii) 21.7. Proposed (i) + split + lo copies. miu_tlb/miu_a2 wait on MA's ruling.
   - MA rev 198: split NOT adopted (adds L1-hit cycle); measure L0 TLB 4/8 per slot. Every-bank gate, id pool,
     disp copies (1 per 4 lanes) ADOPTED. MI-31 (MI rev 56, MA rung): L0x4 (ii) 23.7 fits, (i) 30.1; L0x8
     (ii) 25.9, (i) 32.1 (scratchpad/a2p/a2l.sv). Model knobs CCV_MIU_L0=n, CCV_MIU_PBINS=1 (MIUBINS line:
     bins outside TI's kCoverBins). Pricing: scratchpad/price31.sh (detached), table:
     python3 scratchpad/tab31.py scratchpad/price31. TODO when cm128 (base gate l0x4 l0x8 borrow dropfree)
     is in: edit MI-30 and MI-31 cells with it (no new notice). miu_tlb/miu_a2 wait on MA's ruling.
   - Push: tools/gate-push.sh after pricing ends (the gate needs the memory).
   - TI re:MI-29 (TI rev 546): cm128 watchdog at CCV_TB_LATENCY=1000 was under BOTH models; reproduce
     after pricing (CCV_MIU_IMPL=model CCV_DCU_IMPL=model, then MIU model alone), find whose, row TI+DI.
     DI-50 (DI rev 89): dcu-wb-refetch moved to DCU's unit-held list; nothing for MI.
0b'''''. MI-28 (MI rev 53, MA rung): miu_ids built on local branch mi-ids-wip 89c24f05 (not on mi-dev):
   556 flops, CG clean; NGD 18.0 inside but qid 20.8 / rid 12.5 need arrival 0 (asked MA for miu_ids.ngd.json).
   tk = miu_lead's launch flop (sv_cm06h); drop dp_cm06h from miu_a2's flop a cycle on, id free 2 cycles later;
   leads lv_cm05h (A1 lookup) and rs_cm05h (response captured). On MA's ruling: write the ngd.json, merge to
   mi-dev, then align the model's IdPool (quarter pick, drop delay). Bench controls noskip/relnow/nodrop.
0b''''. MI-27 (MI rev 52, MA rung): miu_lead measured on local branch mi-lead-wip (a94e83f8, not on mi-dev):
   as specified 49.1/39.6 NGD; narrow path (per-lane 2-input (idx<<sc)+disp low 16 bits, gate on every bank,
   form field picked after the route) 27.9 (23.2 no fanout), 270 flops; leader's whole sum 37.4. Asked MA:
   (1) gate every bank? (2) leader sum: A2 pick from agu8 flops, or first-lane-by-position leader + no-hit;
   (3) per-quarter disp/sh copies from miu_pair. Variants in scratchpad lead.v*.sv (v10 best narrow).
   Pricing run: model knobs CCV_MIU_GATE_ALL / CCV_MIU_LEAD_POS (uncommitted in sim/miu/miu_block.cpp),
   scratchpad price27.sh -> scratchpad/price27/{base,gate,lead}.txt, job log ~/ccv-logs/price27.log.
0b'''. MI-26 (MI rev 51, MA rung): MA ruled MI-22..25; (D) built. MA rev 195: local b unsigned 17-bit, C once per
   slot, agu8 out 0 / A2 in 0. Pushed e0a29c01 (agu8 (D), form). mi-dev c642ce7b (unpushed): C formed at A1 from
   H flops (ctx, local region, disp 17), c_cm06h, form 24.3 NGD / 6,851 flops, CG clean; bench C-carry bins.
   Tell MA in the next row: C sits at A1, out c_cm06h (A2 reads it at 0). Next: miu_lead per (D) (leader field
   select; measure VPN (5+k)-bit add in lead vs A2), miu_grp/miu_a2 (12/12), report NGD of agu8/lead/grp/a2/tlb
   to MA before the push. Fill assertion + orphan control (MA rev 187) go with miu_rsp. Diagnosis script for
   f-f paths: scratchpad ngdq2.py (rr with fanout, worst ends and starts).
0b''. MI-22/23 (MI revs 44-48, MA rung): miu_form built on mi-dev (bench form_tb, controls lane0/nohi1/noctx; NGD
   24.3 ff / 22.5 in; check-cg not yet run: OOM beside the gate, rerun alone). NOT pushable until MA sets its port
   budgets (ccv_miu has no unit: architect's). Ports: writes valid-then-fields (ctv_cm01h, ctc/ctl_cm02h; fv_cm01h,
   fc/fm_cm02h, fw_cm03h); pen_cm03h (new miu_pair comb out), pe_cm04h (new miu_pair keep out), mqa, mqi (new miu_mq
   issue_mask out); H out win, wv, fs{elig,local,slot}, wh, rk {ctx,hi+1,hi,lo8,bl}, dh. MI-23: R(ctx) is NOT wiring
   (bases differ by 2LC+PW): (b) carry-select; ctx add into lo8 moved to miu_agu8 beside its narrow sum. Asked MA: which
   kill clears window valids. Next: miu_pair pen/pe outs, miu_mq issue_mask out, miu_agu8 narrow adder + decision.
0b'. MI-21 DECIDED (MA rev 176, MIU tab rev 165; bookmarks MA 178, MIU 165): miu_form at H-1 beside miu_pair owns
   window table, local_base, W, R(ctx), written from ccv_rau_miu_cta (own enables); flops at H per slot: window word,
   local scalar into disp, R(ctx) bits, W high bits, form selects; one-hot of lane d flopped at H-1. Forms land in
   slice 1 before M0. O-83 (a): per lane a 2nd narrow 22-bit adder (log2(32L)) after one 3:2 over rindex rewired
   {rindex[31:2],11111,rindex[1:0]}, disp {disp[31:2],00000,disp[1:0]}, rbase low k bits at [20+k:21]; bits [6:2]
   replaced by l; R(ctx) is wiring above. Decision per lane parallel (~5) + one-hot pick (~3) = ~8, select after the
   adders (1 NGD); [0,L) check beside -> F-ADDR. miu_lead's leaders same. Report extra gates/lane; raise if > 25.
   AR 412 (4) FYI: future 160-entry miss park table, req_id 8 bits; keep MQ at 40.
0b. MI-21 (MI rev 41, MA rung): no module owns slot/local/priv form state (window table, local_base/W,
   local scalar, R(ctx)); O-83 decision ahead of the CSA puts A1 at ~32 NGD. Options (a) two sums late
   mux, proposal miu_form at H-1. miu_agu8 e0a29c01 (ordinary + sized forms) has ~1.7 NGD left for the
   window carry-save level (deepest 23.3: shared 23.3, sh 22.8; sum 18.5 with explicit CSA + Kogge-Stone,
   ABC's own adder gave 24). miu_pair now decodes the transfer a stage early (a1x {b2,b4,sh2,sh1}).
   Gate on e0a29c01 merge: job-gate-push-20261123-160322-2277.log.
1. RTL slice 1 (MA Phase 2, MIU tab rev 161): miu_cap pushed; miu_pair + miu_mq pushed at 512d2315 (SCOPED PASS).
   check-cg --unit exit 0 does not apply the module budget: read the ungated count vs 2%. miu_mq: 40 entries by arrival
   slot, psel one-hot + pre keep copy (me), rel decoded before its flop, dis (mem_op 0xF) muxes
   last; cg 5136/5205 gated, ngd 23.6/11.2. miu_pair reads mqa_cm02h (A1 view, FW 63) at H-1;
   miu_pkg dropped (Yosys refuses pkg->pkg refs; mq_tb static_asserts the layout). Lines, lane map,
   lost flag in miu_mq come with miu_a2. miu_cred 33146fbc (mi-dev, not pushed): credit state one stage 07
   (dcu_bctl's way), ports ge1/ge2_cm07h, return capture ports cv_cm04h/er,dr_cm05h. Model returns
   now counted a cycle after landing (cred_pend_, as RTL V+2): uncommitted until kernels pass both DCUs.
   Next: miu_lead (ge1/ge2/used),
   miu_tlb (ccv_common_wayfold, pa_fold), miu_grp, miu_a2 (drop), miu_ids, miu_hitq, miu_rsp,
   miu_rcap, miu_ext, miu_ecc (K=128, syndrome R2, budget 17), miu_out, ccv_miu top. Then model
   checks: UE on a clean line keeps req_id live (AR 403; MIU tab rev 163 via MA notice re DI-30:
   answered twice under one req_id, complete from DCU's refill, hit 0, no new credit); mispredict late answer at due+2.
   RTL lessons: CCV-L23 forbids a self-feeding param shift array (use a counter-indexed ring);
   a comb net read by more than its own state's flops must go inline in always_ff; CCV-L04 reads
   `<=` in always_comb as nonblocking; no package-to-package params; one assert label per module
   (fold generate checks into vectors); tags _cmNNh; RST-1 flop; CG-5; (* keep *) output copies;
   a payload no-flop end: compute next state both ways, mux by it last.
1b. MA-29 done by TI (bc9d61ff): merge it in the next sweep; miu_ecc RTL syndrome at K=128.
1c. MA-30 agreed (AR 405, MIU tab rev 161): each miu_tlb entry keeps fold(PFN) (k=4), written at
   the TLB fill; miu_a2 sends it as pa_fold in the req payload; control miu-fold-flip must fail.
   TI-518: pa_fold landed (912a155b, 458ddda3 on ccr-183cc441, after the 11-22 sweep merge):
   wayfold.h + rtl/common/ccv_common_wayfold.sv; TI's put in putIndexLead (miu-fold-flip) is
   mine now. Merge next sweep; miu_tlb keeps fold(PFN) per entry via ccv_common_wayfold.
2. MI-11 (2): lnorm1 under CCV_RAU_DEMOTE=mlc once OI's c461c1b0 lands (AR 399).
3. Way-mispredict path (AR 390) once TI's same-set kernel exists (MI-9 (3)).
4. Awaiting TI: MI-4, MI-8, MI-9 (3), MI-13. Phase 1a cold TLB flip (MI-6). M0 report.
- Docs write grammar: update ref node c1311541-4219, container project JApHYjaUESeq8tsGMGXMU5,
  engine prose, ops insert target {kind:blocks, ids:[table]} side end, source as blocks inline
  rows of cells of paragraphs. Opens m8yvbw8rqgz.613 (6 cells), Responses m8yvbw8rqgz.675 (4).

## Pushed
- ccr-58815650-0ch1hh at 1f9ce5c5: full PASS (sweep 2026-11-23: mi-dev 136 incl. TI ba085cda,
  ccr-5e4d6c70 8, ccr-80102643 6, ccr-9eb50716 3, MA's spec branch 3).
- ccr-58815650-0ch1hh at 073943f3: SCOPED PASS (mi-dev 6f7d98a4: MI-19 drop/syndrome, miu_pair
  RTL, merged over DI 818285df and TI b8233a39).
- ccr-58815650-0ch1hh at d26849c3: full PASS (sweep 2026-11-21: ccr-183cc441, ccr-5e4d6c70,
  ccr-80102643, mi-dev b1a85fa6 A1 hold).
- ccr-58815650-0ch1hh at b04269bb (dd04003d miu_cap RTL, bench, units): SCOPED PASS.
- ccr-58815650-0ch1hh at 7a4c2b43 (51cf5dd2 DI-9 fix): SCOPED PASS.
- ccr-58815650-0ch1hh at 5057ec50 (d639adb2 bank credits + TI's d761c634): SCOPED PASS.
- ccr-58815650-0ch1hh at f79b74f1: full PASS (Fri sweep: merged ccr-3868632d 78,
  ccr-5e4d6c70 7, ccr-c22116ce 9, MA's branch 6; walkthrough conflict regenerated).
- ccr-58815650-0ch1hh at eed37e0c: full PASS (daily sweep 2026-11-19 merges + e6712d62 TI-487 (3)).
- ccr-58815650-0ch1hh at 53b98a2f (steps 1-4, cold controls e62b76e2): SCOPED PASS. Earlier
  21274699 (076d0b75 model, 7cfc15ec walker). The remote
  branch was seeded with TI's gated 663bed37 so gate-push had a scoped base.
- TI-561 (rev 563, FYI): ef260513 landed (row-register form, connection check, conn-ratchet); MI's assert/control
  list form for the feedback declaration follows TI's next push: then write rtl/miu/ccv_miu.feedback.json.
- Gate f5be7a33+handoff (job-gate-push-20261124-060912-10645) FAILS s1d lint: miu_grp no Spec: line and `if` on fl
  (CCV-L11, L08); miu_tlb CCV-L23 (dup_cm07h read iv_q_cm06h; l0late_cm08h read age_q_cm09h). Fixed in
  scratchpad/lintfix (miu_grp ternary spl + Spec line; iv_cm06h/iv_q_cm07h; l0late_cm09h; tlb_tb iv_cm06h):
  lint clean, benches+controls pass, a2 25.0, tlb 17.7/14.8. That gate also failed check-ngd: miu_grp had no timing unit (added test/miu/ngd-units.json). All committed; GATE-PUSH IN FLIGHT (newest job-gate-push log).
- TI-568 (77f7849e/e113961e: list form landed). MI-44 (rev 68, TI rung): ccv_miu.feedback.json drafted at
  scratchpad/fb/ccv_miu.feedback.json, lint passes it UNREAD (no rtl/miu/ccv_miu wiring u_a2/u_tlb yet); held for
  the assembly commit; asked TI about refusing orphan declarations. Next row MI-45. Scratch worktree
  scratchpad/wt-fb = my 2f3c8db4 + TI tip merged (git worktree; remove when done).
- TI-569 (rev 571): agreed; TI's next push refuses an orphan feedback.json. Keep holding ccv_miu.feedback.json
  for the assembly commit. MI-44 closed by it.
