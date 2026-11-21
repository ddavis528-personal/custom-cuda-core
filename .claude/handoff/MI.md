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
- Daily sweep 2026-11-21 (Sat): AR 406, OA 466, IS 201, TI 511, OI 399, CP 160, RA 157, RI 91,
  MA 145, MI 30, DI 29, DA 128, Conventions 20; specs MIU 150, Common 9, DCU 64. TI 512 (TI-513
  notice: 8ac4c441 drop/check_bits/CCV_DCU_ECC_INJECT landed). Next pings: Friday.
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
0. MI-19: mi-dev holds 2d2259bf (drop bit, R2 syndrome) + a0afe9fc (drop_held = older-store
   overlap only; CCV_MIU_DUP_IDEAL) + handoff, NOT pushed. 3224eaff on mi-dev is my local
   cherry-pick of all of DI's 8b6090d0: do NOT gate it (its ECC half waits on TI's re-pin, DI-16).
   Plan (DI-17, answered rev 31): when DI's notice says 7bf5073a (drop half alone) is on
   ccr-5e4d6c70-n6402z, in the main checkout merge that branch and mi-dev AT a0afe9fc (not the
   tip), then CCV_PUSH_BRANCHES=ccr-58815650-0ch1hh tools/gate-push.sh. Gate runs stubs only.
   Pricing answered (rev 32, MA rung): S1 gap 0, cm32priv +0.008%, cm128priv -0.10%; spec kept.
   DI-18 settled (MA rev 148, MIU tab 153): MIU corrects a CE, completion withheld a cycle as a
   refill, nothing to DCU, req_id frees on its one response: the model already does this.
   MIU tab rev 150: H = first MIU flops hold memop+address; every MIU receiver no-flop; address
   lands CCV_LAT_MIU_PAIR_LAG (3, >=1) after the memop; miu_pair loads A1 fields from MQ at H-1.
1. RTL slice 1 (MA Phase 2, MIU tab rev 149/150): miu_cap done (pushed b04269bb). Next miu_pair
   (+ miu_mq: A1 fields read at H-1; per lead pipe ring of {entry, valid} indexed by arrival
   counter bridging LAG=3, CCV_LAT_MIU_PAIR_LAG once TI derives it; fences pair on slot 0; bulk
   discards no address; memop ends no-flop). Then miu_agu8, miu_lead (ge1/ge2/used), miu_cred,
   miu_tlb, miu_grp, miu_a2 (drop), miu_ids, miu_hitq, miu_rsp, miu_rcap, miu_ext, miu_ecc
   (syndrome R2, budget 17), miu_out, ccv_miu top. MI-16: TI wires the MIU RTL job.
   RTL lessons: CCV-L23 forbids a self-feeding param shift array (use a counter-indexed ring);
   tags _cmNNh; RST-1 flop; CG-5 enables from own flops; (* keep *) output copies.
2. MI-11 (2): lnorm1 under CCV_RAU_DEMOTE=mlc once OI's c461c1b0 lands (AR 399).
3. Way-mispredict path (AR 390) once TI's same-set kernel exists (MI-9 (3)).
4. Awaiting TI: MI-4, MI-8, MI-9 (3), MI-13. Phase 1a cold TLB flip (MI-6). M0 report.
- Docs write grammar: update ref node c1311541-4219, container project JApHYjaUESeq8tsGMGXMU5,
  engine prose, ops insert target {kind:blocks, ids:[table]} side end, source as blocks inline
  rows of cells of paragraphs. Opens m8yvbw8rqgz.613 (6 cells), Responses m8yvbw8rqgz.675 (4).

## Pushed
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
