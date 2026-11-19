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
   (the MI-1 hook applied there uncommitted and marked git update-index --skip-worktree on
   sim/skel/{kernel.cpp,blocks.list}; scratchpad mi1-hook.patch; never commit it; clear the
   flag with --no-skip-worktree before merging TI's hook).
   Done: step 1 (f167df9f: A1/A2 at H, own-warp holds, fence holds, held load's no-hit),
   step 2 (891f5bb0: first pass at H+1 on footprint slots, slot-order bank losers, later
   passes on idle slots, per-warp drains, ld_pass_held), 4f30397b (formation bins once a memop).
   Loads hold on own-warp writes only (MA-11): tried any-warp for transp4, wrong, reverted.
   Model check-kernel now fails only stub-timing-pinned checks (raised to TI as MI-4):
   vadd/ldpar ue_recover, privwin priv_form 10 vs 12 (stub counts per try: 50 per try,
   10 per memop), UE track-table-full (ldpar gets 1 clean UE), fet-reset-on-kill (ropediv),
   vadd4 replay drain (model 185 cycles vs 298: no mlc demotion), and transp4 demoted at
   760, a real bug outside MIU (stub fails at demote 750/840/846/876/888 the same way: a
   warp passes the barrier before two warps re-execute a discarded .shared store).
   Next steps: (3) a store keeps its MQ entry until it drains, drain guard N_drain=16
   withholding one memop credit; (4) TLB + walker, cold per kernel, span assert; (5) bank
   credits once MA-25's channel exists; (6) bins, stats, controls (way mispredict path).
   Validate each with CCV_MIU_IMPL=model ./tools/check-kernel.sh (~30 min; never rebuild
   the skeleton while it runs: its control builds read the source).
2. MI-1 rung to TI (MI tab rev 4, response row names 21274699). Await TI's hook.
3. MI-3: MA rev 123 confirmed the per-load hold; close it in the MI tab.
4. Phase 1b with DI's DCU model; agree landing order of bank credits / way mispredict (the
   conflict loser's path, due+2, as a miss) / withheld completion with DI in our tabs.
5. RTL waits on MA's Phase 2 (partition, stage tables, port budgets). Nothing in rtl/miu/.

## Pushed
- ccr-58815650-0ch1hh at 21274699 (076d0b75 model, 7cfc15ec walker): SCOPED PASS. The remote
  branch was seeded with TI's gated 663bed37 so gate-push had a scoped base.
