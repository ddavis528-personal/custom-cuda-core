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
- Daily sweep 2026-11-19: AR 395, OA 446, IS 199, TI 487, OI 380, CP 160, RA 156, RI 91, MA 127,
  MI 10, DI 4, DA 128, Conventions 20; specs MIU 145, Common 9, DCU 56. Only TI-488 named MI.
- MA-26 landed (WAYPRED_BITS 5, SEL 1; L1_HIT 8, WAKE 14, CMPL 16). MA-25 (bank credits
  ent_ret/std_ret, QDEPTH 16, STDATA 12) still pending at TI.
- MA-127 answered (rev 9: full 64-bit fault address reaches the record). MI-7 (d) UE scenario
  added (rev 8). MI-8 rung to TI (rev 10): under UE_INJECT=1 predlane/predmerge fail
  quiesced_at_end on ooe_miu_memop (a store whose merge read was withheld never drains, so its
  credit stays out, per spec); asked TI to exempt machine-checked runs with a control.

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
   e62b76e2: cold controls (walk_reads, tlb_two_page_lost; breaks walk-no-dcu, itlb-no-walk,
   walk-before-faddr, two-page-hit, registered only in local main.cpp). MA-126 accepted (MI tab
   rev 7-8): warm default through M0; cold scenarios (a-d, incl. UE inject: walk reads already
   count) proposed to TI as MI-7; phase 1a's first item is the flip to cold (re-pin ~30 checks);
   the M0 report states the cold cost, 110-160 cycles a kernel.
   Next: (5) bank credits once MA-25's channel exists; (6) bins/stats/controls (way
   mispredict path, AR 390). Validate each with CCV_MIU_IMPL=model ./tools/check-kernel.sh
   (~30 min, CCV_FOREGROUND=1; never rebuild the skeleton while it runs).
2. MI-1 rung to TI (MI tab rev 4, response row names 21274699). Await TI's hook.
3. MI-3 closed (rev 5). Rung and awaiting: TI on MI-1, MI-4 (stub-pinned checks, transp4
   barrier bug), MI-5 (testbench bound, 14 bins for kernel.h, narrowadd bug); MA on MI-6
   (cold TLB default at M0). MI tab at rev 8 (MI-7 rung to TI).
4. Phase 1b with DI's DCU model; agree landing order of bank credits / way mispredict (the
   conflict loser's path, due+2, as a miss) / withheld completion with DI in our tabs.
5. RTL waits on MA's Phase 2 (partition, stage tables, port budgets). Nothing in rtl/miu/.

## Pushed
- ccr-58815650-0ch1hh at eed37e0c: full PASS (daily sweep 2026-11-19 merges + e6712d62 TI-487 (3)).
- ccr-58815650-0ch1hh at 53b98a2f (steps 1-4, cold controls e62b76e2): SCOPED PASS. Earlier
  21274699 (076d0b75 model, 7cfc15ec walker). The remote
  branch was seeded with TI's gated 663bed37 so gate-push had a scoped base.
