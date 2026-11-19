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
  specs Common tab 9. Nothing had MI in Needs. MA-25 (QDEPTH/STDATA, credit
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
- MI-2 needs a closing line in the MI tab (adopted) with the next MI tab write.

## Open work, most urgent first
0. Restructure in worktree /home/user/mi-wt (branch mi-dev): step 1 (per-warp drain, kAnyWrite,
   tried_ for A1 bins) and step 2 (first pass at H+1 on footprint slots, slot-order bank
   losers, later passes on idle slots, ld_pass_held) applied. cm128 bounded no longer
   starves (oldest memop 18831 vs stub 19148, watchdog 20480). Next: kernel suite triage
   (ue_recover counts, UE track-table, machine-check controls, replay drain), remove the
   TEMP CCV_MIU_DEBUG block, commit; then steps 3-6 (store MQ entry to drain + N_drain
   guard; TLB+walker cold start + span assert; bank credits after MA-25; bins/controls).
   mi-wt keeps TI's kernel.cpp/blocks.list hook skip-worktree: never commit them.
1. MI-1 (MI tab rev 2) asks TI for makeMiu (CCV_MIU_IMPL=model), blocks.list lines,
   check-miu-unit, later the port-trace dump. NOT rung yet: ring TI when the sim/miu/
   commit it waits on is pushed and named in the MI tab.
2. Phase 1 (M0): the model in sim/miu/ (core + block + unit tests), per miu-impl.md
   section 5 obligations and coverage bins. Defaults while params are pending:
   QDEPTH 16, STDATA 12, WAYPRED_BITS 5 (L1_HIT 8; also test 9), BANK_HASH off.
3. Phase 1b with DI's DCU model; agree landing order of bank credits / late hit /
   withheld completion with DI in our tabs.
4. RTL waits on MA's Phase 2 (partition, stage tables, port budgets). Nothing in rtl/miu/.
