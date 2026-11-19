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
- MI owns sim/miu/, rtl/miu/ (after MA's Phase 2), test/miu/. Never edit schema/, params/,
  tools/, rtl/top/, stubs (incl. class Miu in sim/skel/kernel.cpp), blocks.list: MI-n row,
  TI in Needs. Architecture questions: MI-n row, MA in Needs.
- Model: cycle-accurate at the ports and events, not an RTL clone. Swap boundary: ports
  only; oracle for checks, never decisions. Stub controls (--break) must keep failing.
- Ring a notice only for a row that asks something of its receiver (register skill).

## Register bookmarks
- Session-start read: AR 392, OA 443, IS 197, TI 486, OI 378, CP 160, RA 156, RI 91, MA 117,
  MI 2 (MI-1 written), DI 1, DA 128, Conventions 20. Since: MA 122 (MI-2 settled, AR 390/391/392 read),
  specs Common tab 9. MI tab now rev 4 (MI-2 closed, MI-3 raised, re:MI-1). Nothing had MI in Needs. MA-25 (QDEPTH/STDATA, credit
  vectors ent_ret/std_ret) and MA-26 (WAYPRED_BITS/SEL) await TI; TI-484 (ECC inject) landed 0767fe1c.

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

## Open work, most urgent first
1. Model restructure to the spec's timing, in worktree /home/user/mi-wt on local branch mi-dev
   (the MI-1 hook applied there uncommitted, git update-index --skip-worktree on
   sim/skel/{kernel.cpp,blocks.list}; scratchpad mi1-hook-bound.patch, which also bounds the
   testbench's slow regions below 1<<32 (MI-5 (1)); never commit it; --no-skip-worktree before
   merging TI's hook). Pushed: steps 1-2 (6b019dce), step 3 (8e1792b6: store keeps MQ entry to
   drain, drain guard on Pending::kDrainWait, wide bit), step 4 (2e1975e6: TLB in A2 + shared
   walker, before any bin; cold only under CCV_MIU_TLB=cold, default warm as the stub).
   Warm check-kernel fails only MI-4's stub-pinned set. Cold moves ~30 checks (MI-6 to MA).
   Next: (5) bank credits once MA-25's channel exists; (6) bins/stats/controls (way
   mispredict path, AR 390). Validate each with CCV_MIU_IMPL=model ./tools/check-kernel.sh
   (~30 min, CCV_FOREGROUND=1; never rebuild the skeleton while it runs).
2. MI-1 rung to TI (MI tab rev 4, response row names 21274699). Await TI's hook.
3. MI-3 closed (rev 5). Rung and awaiting: TI on MI-1, MI-4 (stub-pinned checks, transp4
   barrier bug), MI-5 (testbench bound, 14 bins for kernel.h, narrowadd bug); MA on MI-6
   (cold TLB default at M0). MI tab at rev 6.
4. Phase 1b with DI's DCU model; agree landing order of bank credits / way mispredict (the
   conflict loser's path, due+2, as a miss) / withheld completion with DI in our tabs.
5. RTL waits on MA's Phase 2 (partition, stage tables, port budgets). Nothing in rtl/miu/.

## Pushed
- ccr-58815650-0ch1hh at 2e1975e6 (steps 1-4): SCOPED PASS. Earlier
  21274699 (076d0b75 model, 7cfc15ec walker). The remote
  branch was seeded with TI's gated 663bed37 so gate-push had a scoped base.
