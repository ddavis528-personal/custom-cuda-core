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
Conventions 17, AR 275, OA 336, IS 189, TI 321, OI 274, CP 152, DA 106, RA 84, RI 12. TI 326. TI 324. AR 287.
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
0000. RA revs 83/84 (zero-cycle pricing): depths answered (RI rev 16). Model runs could not price
    the flops: ccv-skel ignores no_flop (rtl/top only), SV-hosted at D fails fixed latency 8 vs 6 ->
    RI-16 (RI rev 17, notices TI/AR/RA). AR bases alone: S1 47,704 -> 48,264 (+1.17%). AR rev 300 (reverses 299): RI-16
    right; TI adds link term bnd_rx 1 per flopped receiving end in both hosts, bases back to 7/12/5.
    AFTER TI lands it: price D, N, Z1-Z3 as links.json no_flop edits (S1, CM32 detached), post RI row.
    Base-pricing runs stopped. ri-wt3 reverted, reusable.
000. Sweep 2026-11-05 DONE: 802b8ae pushed (SPLIT PASS 22/22), merged into ri-wt at 64a7f04.
    Pong sent to OI's 2026-11-06 ping. Note CLAUDE.md (2026-11-05): a boundary flop's lead slice (the
    block's own capture before the end was flopped) counts against the wrapper's 2% -- relevant to (d).
00. HELD: RA rev 81 declined rcu_pred's two CG-5 waivers (else accepted RI-14; gt/pdt/br at 0
    with the op-class decode inside pred once TI generates the table; ack/epoch assertion for
    rcu_kill (4) to add). e5e846b's gate STOPPED, not pushed. Measured strict-CG-5 variants (local
    WIP commits cf12cc0, 63457b2 on top of 7ca3d55/66b014e): none passes (row DCGE 14-18%, flop-flop
    26.0, R w/o lead 27.5, MIU lead ungated 152 vs 53.6 allowance). RI-15 (RI rev 15, notice to RA)
    asks DA/RA: (a) interface-flop Q may enable (recommended), (b) two-cycle leads, (c) keep waivers.
    RA rev 82: (a)/(c) reverse DA's strict CG-5; RA proposes (d) to DA: the one-cycle ungated lead
    holds (161 flops) charged to the RCU block's 2%, as DA rev 108 does boundary lead slices; a90cb8f
    timing kept, no waiver. HOLD until DA rules. On (d): revert the WIP commits, make the lead captures
    ungated (no enable), drop the two waivers, and say how the block budget is charged.
    On the ruling: (a)/(c) -> git revert cf12cc0 63457b2 (restores a90cb8f layout, waivers); (b) ->
    schema change via TI. Then add the rcu_kill ack/epoch assertion, regen, gate, push, tell TI (TI rev 330).
0a. TI rev 332: RI-11 accounting applied (f61983f), RI-13 took_flops fix pushed. Merge TI's tip
    before the next gate; then close RI-11 (for RCU) and RI-13 in the RI tab after verifying.
0. Next push: ri-wt holds 3c912d1 (M4: model knob CCV_RCU_KILL_DRAIN_CUT + docs/rcu-model.md) + this
   handoff, on d2ca2d7. Merge into the main tree after e5e846b's push; scope sim/rcu -> rcu_unit etc.
1. Phase 3 reported: RI-14 (RI rev 14; notices to RA, TI). TI took M4 (TI rev 330): kernel + V-24 post-ack check after AR 289; TELL TI (RI tab row + notice) once a90cb8f, d2ca2d7, 3c912d1 are pushed. Waiting on RA (departures 1-5,
   block-budget for credit pulses) and TI (SFU-in-flight kill kernel + post-ack checker for M4).
   M4 result: no kernel fails even at drain 0 (RCU idle at every kill); margin = whole drain.
2. RI-12: close when OI's fix lands (OI rev 287). Then TI's AR-bases push (LANE_BASE 8, SFU 13):
   re-run sim/rcu/run-tests.sh and check-kernel; KILL_DRAIN 16 (kd waiver max 5 covers it).
3. At bank assembly: row 135's gate (RA rev 80), rcu_r pr_orow output, block CG totals.
4. Remaining phases per docs/rcu-impl.md: rcu_mig, the lane/SFU descriptor pipes, assembly (M5-M7).
5. Remove worktrees /home/user/ri-wt, ri-wt2 once merged. Daily sweep trig_01YVAyULgv3K9NymwVJXZybD.
Bookmarks 2026-11-05 sweep: Conventions 17, AR 300, OA 347, IS 189, TI 338, OI 292, CP 154, DA 108, RA 84, RI 17.
