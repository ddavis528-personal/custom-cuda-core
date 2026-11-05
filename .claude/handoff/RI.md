# RI handoff (RCU implementation)

Updated 2026-11-05. Keep current at every task's end. Role and ownership:
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
Conventions 17, AR 275, OA 336, IS 189, TI 321, OI 274, CP 152, DA 106, RA 80, RI 12. TI 326. TI 324. AR 287.
Nothing had RI in Needs at session start.

## Working rules beyond CLAUDE.md
- TI owns schema/params/tools/stub/kernel.cpp. TI landed (merged at f25b3e2): makeRcu with
  CCV_RCU_IMPL=model, lane stub's per-section sec_dst_width, rcu_unit gate section
  (tools/check-rcu-unit.sh), gate-scope for sim/rcu/, events 33-47, map/mig backpressured.
  No local kernel.cpp patch any more.
- Model events: rcu::Ev (4 fields, unit tests) packed to schema ids in rcu_block.cpp event();
  docs/rcu-model.md has the packing, aux, interims, controls.

## Model state (2026-11-04)
- sim/rcu/: rcu_core.{h,cpp}, rcu_block.cpp, rcu_test.cpp (7 "control <name> caught" lines), run-tests.sh.
- Interims: Config::full_row (AR-24; CCV_RCU_FULL_ROW=0 = secmask); call link from record (RA-18, RI-7).
- Pushed: a0f6ccd, b685619, 131cdee (sweep merge, SPLIT PASS). Then merged 7 branches -> f25b3e2;
  on top: events emit, KillAck, MIU slot on GuardFwd/RsrcFwd, controls, docs/rcu-model.md.
- Logs: ~/ccv-logs/kernel-model-m0b.log (model run after merge); per-kernel logs in build/kernel*.
- Gate: split gate if all sections run (`verify.sh --full --only ngd` + gate-export + gate-push --import).

## Open work, most urgent first
00. Push e5e846b (main tree: a90cb8f rcu_pred, d2ca2d7 rcu_kill, trust-report regen). Split gate:
    cg part bcdqazsfg running in main tree (verify --changed 89543cc --only cg ->
    ~/ccv-logs/split-cg-e5e846b.log, gate-cg-e5e846b.tgz). Then, in the main tree, in the background:
    CCV_PUSH_BRANCHES=ccr-888218a3-20cauz tools/gate-push.sh --import=$HOME/ccv-logs/gate-cg-e5e846b.tgz
    (it runs the other scoped sections); expect SPLIT SCOPED PASS. 89543cc already pushed.
0. Next push: ri-wt holds 3c912d1 (M4: model knob CCV_RCU_KILL_DRAIN_CUT + docs/rcu-model.md) + this
   handoff, on d2ca2d7. Merge into the main tree after e5e846b's push; scope sim/rcu -> rcu_unit etc.
1. Phase 3 reported: RI-14 (RI rev 14; notices to RA, TI). Waiting on RA (departures 1-5,
   block-budget for credit pulses) and TI (SFU-in-flight kill kernel + post-ack checker for M4).
   M4 result: no kernel fails even at drain 0 (RCU idle at every kill); margin = whole drain.
2. RI-12: close when OI's fix lands (OI rev 287). Then TI's AR-bases push (LANE_BASE 8, SFU 13):
   re-run sim/rcu/run-tests.sh and check-kernel; KILL_DRAIN 16 (kd waiver max 5 covers it).
3. At bank assembly: row 135's gate (RA rev 80), rcu_r pr_orow output, block CG totals.
4. Remaining phases per docs/rcu-impl.md: rcu_mig, the lane/SFU descriptor pipes, assembly (M5-M7).
5. Remove worktrees /home/user/ri-wt, ri-wt2 once merged. Daily sweep trig_01YVAyULgv3K9NymwVJXZybD.
Bookmarks 2026-11-05: RA 80, TI 326, OA 338, OI 287, AR 287, RI 14.
