# RI handoff (RCU implementation)

Updated 2026-11-04. Keep current at every task's end. Role and ownership:
docs/rcu-impl.md (RA's handoff, section 1). Spec: docs/design-snapshots/rcu-arch-*.md
(live doc https://claude.ai/artifact/4k7VrEKJG4KUgMYG1Qz8mB wins).

## Who and setup
- RI = session_01QPk2jvvXPLs4m8ZQbSk1g6 (roster commit 187048a). Register tab RI node
  8e4547bc-c469; write only there. Daniel (DA) is a senior microprocessor design engineer.
- session-home installed (Daniel OK'd, 2026-11-04); --check matches.
- Daily sweep scheduled task trig_01YVAyULgv3K9NymwVJXZybD, 02:31 America/Los_Angeles.
- Toolchain: ./tools/setup-toolchain.sh (log ~/ccv-logs/setup-toolchain.log).

## Repos, branches, push
- Core /home/user/custom-cuda-core, compiler /home/user/custom-cuda-complier (read only),
  both on branch ccr-888218a3-20cauz. Started from TI's fbefc16, merged RA's 9676944.
- Push: tools/gate-push.sh with CCV_PUSH_BRANCHES=ccr-888218a3-20cauz. Merge commits only.
  No PRs. No model ids in commits/code. Name commits for TI to merge in the RI tab.

## Register bookmarks (2026-11-04)
Conventions 17, AR 275, OA 329, IS 189, TI 303, OI 272, CP 152, DA 106, RA 63, RI 1.
Nothing had RI in Needs at session start.

## Working rules beyond CLAUDE.md
- TI owns schema/params/tools/stub/kernel.cpp's makeKernelBlock: makeRcu hook is TI's
  (RA-38, planned TI rev 290, not built as of TI 303). Use a LOCAL uncommitted patch to run
  kernels with the model until it lands; carry the blocks.list line with the first model
  commit or ping TI.
- No RCU events exist in schema/events.json: the model logs its events internally
  (for unit tests and lock-step) until TI assigns ids (row to raise).
- Model reads/writes Kernel::gpr / Kernel::pred as its PRF (the final-state compare
  reads them), via a reference so unit tests use their own.
- Params today: kLatRcuAddr 5 (spec builds to 1; TI reapplies after OI's ooe_wake fix),
  no KILL_DRAIN param yet (RA-16 (g)), done slots still a pool in schema text (RA-29 (b)),
  no MIU lead fields (RA-4), no lead_r_src0/1 (RA-39 (c)).

## Model state (2026-11-04)
- sim/rcu/: rcu_core.{h,cpp} (spec timing), rcu_block.cpp (ports, oracle checks), rcu_test.cpp +
  run-tests.sh (PASS). Block runs under CCV_RCU_IMPL=model via LOCAL kernel.cpp patch (never commit):
  makeRcuLocal + lane stub reads sec_dst_width via getSec(...,0) (line ~2316).
- Interims in the model: Config::full_row (AR-24, CCV_RCU_FULL_ROW=0 = spec secmask MW/RW);
  LW writes every owned bank (Register file tab) not secmask (Lane tab) - conflict for RA;
  call link from the record until RA-18 lands (rcu_block decode).
- Fixed: demote wcnt off-by-one (first row c4), late-copy tid + copy contract check, seq printing.
- Kernel cycles vs stub so far: vadd 157/157, sel 76/76, merge 71/72, callret 280/280,
  sized 2640/2641, narrowadd 226/230. Stub log ~/ccv-logs/kernel-stub.log, model kernel-model.log.

## Open work, most urgent first
1. M0: rerun CCV_RCU_IMPL=model tools/check-kernel.sh; remaining fails were controls
   (drop-src-valid, early-restore-done, lead-src-clear, pca-row-order, swap-on, mwmiss parked,
   movi-in-lane counts, rcu-done-pool, slot-field-aux, lead-corrupt). Then check-sv-hosted.sh.
2. Rows (RI tab empty, node 8e4547bc-c469): TI - lane stub sec_dst_width whole-field read; makeRcu hook +
   check-rcu-unit wiring; RCU events ids; RA-18 status. RA - LW secmask vs owned banks; AR-24 full-row
   interim vs secmask MW/RW; kill-drop multi-credit; mq_free flop; dead pop vs write pop; PL merge_en=0 old=0.
