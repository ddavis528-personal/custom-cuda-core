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
- Daily sweep 2026-11-20 (Fri): AR 400, OA 462, IS 201, TI 503, OI 395, CP 160, RA 157, RI 91,
  MA 135, MI 18, DI 13, DA 128, Conventions 20; specs MIU 145, Common 9, DCU 59.
  Weekly pings: all 11 ponged; OI's and RH's rosters predated cc8ed42d (MI unnamed) then.
- Since: MI 27, TI 510, MA 140, OA 464, DI 21, MA 137, OI 397 (others as above).
- MA-26 landed (WAYPRED_BITS 5, SEL 1; L1_HIT 8, WAKE 14, CMPL 16). MA-25 landed (TI's
  d761c634); the model spends the credits at d639adb2 (step 5).
- MI-8 at TI: under UE_INJECT=1 predlane/predmerge fail quiesced_at_end on ooe_miu_memop. Per
  AR 387/389 (RAU spec rev 63) a store whose merge read was withheld never drains, so its MQ
  entry's credit stays out; TI's KernelEnd already allows it. Ask: exempt mce runs with a control.
  DI-5 (C) was the same thing; answered re DI-5 (rev 17): nothing to change in MIU or DCU.

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
1. Model work in worktree /home/user/mi-wt, branch mi-dev = pushed tip (d639adb2 + regen 5057ec50).
   No local patch. Steps 1-5 pushed (TLB/walker, store drain, drain guard, bank credits).
   Next: (6) way-mispredict path (AR 390: the bank loser's path, due+2, as a miss) once TI's
   same-set kernel exists (MI-9 (3)). MI-13 (rev 23, TI rung): drop check-kernel's skip of the
   bank-credit holds/controls under CCV_MIU_IMPL=model. MI-12 (rev 19): asked TI/OI to move
   our blockers up their order (Daniel's request).
   Validate: CCV_FOREGROUND=1 CCV_MIU_IMPL=model ./tools/check-kernel.sh (~30 min). It fails only
   lnorm1 under demotion (item 2) and the replay drain's stall/vadd4 (MI-4, TI's).
2. MI-11 (2): lnorm1 under CCV_RAU_DEMOTE=mlc. Root cause per OI-193: OOE lost an epoch
   advance; fixed in OI's c461c1b0 (not on a remote yet). When it lands, rerun
   CCV_MIU_IMPL=model CCV_RAU_DEMOTE=mlc build/skel/ccv-skel --kernel build/oracle/lnorm1/oracle.jsonl
   and close MI-11 (2).
3. DI-9 fixed: tryStart's mo/am references past their erase (use-after-free) are copies at
   51cf5dd2 (pushed 7a4c2b43). ASan only sees it at -O0 (scratchpad build-skel-asan*.sh);
   fixed model ASan-clean over 910 runs. DI asked (rev 26) to rerun the pair's check-sv-hosted
   (lnorm1 / RCU RTL host diffs were this). MI-14 landed by TI (ec8f3422), MI-13 (56c7ce54).
4. Awaiting TI: MI-4 (replay drain stall/vadd4), MI-8, MI-9 (3), MI-13; TI's 78e74f4e (MI-7
   a/b/d cold-TLB scenarios): run them with the model when merged. MI-7 (c) dropped (rev 22).
5. Phase 1a: flip the TLB to cold (MI-6, MA-126) and re-pin ~30 checks; the M0 report states
   the cold cost, 110-160 cycles a kernel. Phase 1b with DI's DCU: clean on 64 kernels.
6. RTL waits on MA's Phase 2 (partition, stage tables, port budgets). Nothing in rtl/miu/.
   MI-15 (rev 27, MA rung, Daniel's request): Phase 2 to the top of MA's order; a first slice
   (L1-hit path) is enough to start modules. MA accepted (MA rev 138): Phase 2 first, slice 1
   = L1-hit path, later slices each with a notice. Slice 1 raised, both pending AR, model
   changes once they land: MA-27 (rev 139) a drop bit on ccv_miu_dcu_req for A2's lookup
   losses (H+1 valid binds) and a first pass takes CCV_DCACHE_LOOKUPS bank entry credits at
   A1; MA-28 (rev 140) a DCU->MIU hit-ECC-error bit a cycle after the response, the model's
   in-MIU ECC injection moving to DCU's side.

## Pushed
- ccr-58815650-0ch1hh at 7a4c2b43 (51cf5dd2 DI-9 fix): SCOPED PASS.
- ccr-58815650-0ch1hh at 5057ec50 (d639adb2 bank credits + TI's d761c634): SCOPED PASS.
- ccr-58815650-0ch1hh at f79b74f1: full PASS (Fri sweep: merged ccr-3868632d 78,
  ccr-5e4d6c70 7, ccr-c22116ce 9, MA's branch 6; walkthrough conflict regenerated).
- ccr-58815650-0ch1hh at eed37e0c: full PASS (daily sweep 2026-11-19 merges + e6712d62 TI-487 (3)).
- ccr-58815650-0ch1hh at 53b98a2f (steps 1-4, cold controls e62b76e2): SCOPED PASS. Earlier
  21274699 (076d0b75 model, 7cfc15ec walker). The remote
  branch was seeded with TI's gated 663bed37 so gate-push had a scoped base.
