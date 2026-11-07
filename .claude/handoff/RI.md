# RI handoff (RCU implementation)

Updated 2026-11-07. Keep current at every task's end. Role and ownership:
docs/rcu-impl.md (RA's handoff, section 1). Spec: docs/design-snapshots/rcu-arch-*.md
(live doc https://claude.ai/artifact/4k7VrEKJG4KUgMYG1Qz8mB wins).

## Who and setup
- RI = session_01QPk2jvvXPLs4m8ZQbSk1g6 (roster commit 187048a). Register tab RI node
  8e4547bc-c469; write only there. Daniel (DA) is a senior microprocessor design engineer.
- session-home installed (Daniel OK'd 2026-11-04, re-run 2026-11-06 after the merge: 350k window);
  --check matches.
- Daily sweep scheduled task trig_01YVAyULgv3K9NymwVJXZybD, 02:31 America/Los_Angeles.
- Toolchain: ./tools/setup-toolchain.sh (log ~/ccv-logs/setup-toolchain.log).

## Repos, branches, push
- Work tree /home/user/ri-wt (branch ccr-888218a3-20cauz); compiler repo read only.
- Push: tools/gate-push.sh with CCV_PUSH_BRANCHES=ccr-888218a3-20cauz. Merge commits only.
  No PRs. No model ids in commits/code. Name commits for TI to merge in the RI tab.
- Last push: 350729e (SPLIT SCOPED PASS, 2026-11-07): rcu_mig, slice zero-fill gate, lint
  fixes, TI's Z (f4ce0fd) and RI-18 (43695ae) merged, model --break ret-held-by-lanes.
- RH (session_01QPk2jvfKM1V5rRfip8FC86) takes RI's perf runs (Daniel, 2026-11-06): send base
  commit via gate-scratch/RI, exact arms and what to report; it replies with a table.

## Working rules beyond CLAUDE.md
- Container gets reclaimed when idle: keep a run_in_background until-loop waiter on any
  detached job (setsid nohup ... & disown). Restarts killed runs 3 times and lost commits once.
- Send every unverified commit to gate-scratch/RI (tools/gate-scratch.sh) before gating.
- Split gate: cg part with CCV_JOBS=1 (OOM at 15 GB otherwise), ngd part CCV_JOBS=2, each
  gate-export, then gate-push --import=a.tgz,b.tgz. Chain script pattern ~/ccv-logs/chain-269efe6.sh.
- TI owns schema/params/tools/stub/kernel.cpp. rcu_block.cpp uses ci.stages + ci.bnd_rx.
- Model events: rcu::Ev packed to schema ids in rcu_block.cpp event(); docs/rcu-model.md.

## Rulings (Daniel, 2026-11-06)
- RI-15 = (c): module-level CG-5 waivers for interface leads, `"lead": true`, each flop charged
  to the RCU block's 2% (RA rev 87, DA rev 109). Credit pulses `"credit": true` (RA rev 88, DA 110).
  Block limit = sum of parts (DA 111/112, TI-51); RCU top still a stub, so checked at assembly.
- Zero-cycle receiving ends only if IPC justifies; lane_rcu_res stays flopped; RI-16 runs decide (RA 91).

## Register
Bookmarks 2026-11-07 (sweep): Conventions 17, AR 316, OA 379, IS 190, TI 364, OI 319, CP 155, DA 115, RA 96, RI 32.
DA 114/115 bar for zero-cycle rx ends (S1 gain): <=0.2% stays flopped; 0.2-0.5% Daniel; >0.5%
architect may approve only if the end meets module NGD without the flop; can't meet 12 NGD -> Daniel.

## Open work, most urgent first
-1. TI rev 364 (coremarkpl32 under the model) answered RI rev 32: not RCU. The --cycles cut flushes held
   fails (replays pending); first real divergence seq 207330 = OOE's call-link imm stale for a diverged
   CALL (ooe_core.cpp ~3388 u.pc); stub masks it (kernel.cpp ~3132 uses the oracle link). Notices to TI, OI.
   Wait for OI's fix; nothing in the RCU model.
0. RI-19: note 1 confirmed (RA rev 96); mig_q_drop pushed 12e6b7b (RI rev 30). Close when RA has no more. Was: kmask +2 clear vs a
   relaunched warp's first row (>= 2 cycles after its map). Notes 2-9 in the row.
   Lessons: run tools/check-1d.sh before a gate (the linter misreads 1'b0 in a wire's concat and a
   for loop's <= bound); run tools/regen.sh after any merge before testing (sim/generated not checked in).
1. Phase 4 rcu_lanes + rcu_mem (exits M1, M2): RTL, benches (lanes_tb, mem_tb; controls
   bypage/immpos, align/pstlane), units rcu_lanes/rcu_mem (COPIES 32; _c4 local), ngd.json each,
   run-rtl.sh. 7e8fb4d on gate-scratch/RI; then CG-3 fixes in lanes (SFU valid stage 1 ungated,
   lact in the ll gate) and mem's asserts out of the generate (Yosys name clash): uncommitted while
   check-ngd/check-cg rerun (~/ccv-logs/chk-lm.log). Next: clean -> commit, run-rtl.sh, gate
   (split), push; RI row to RA: act_cr02h budget (lanes), class-bit arrival 5 (lanes+mem), bank
   L/M read-request decode at assembly, held unused groups vs spec "0", SW data/lane mask at
   assembly, no MIU lead flops in rcu_mem (slices + pred hold them), DCGE figures.
   Then assembly (M5-M7).
2. RI-18 CLOSED (RI rev 31): TI 41c82d8 runs the control on stub and model. Merge 41c82d8 at the next sweep.
3. RI-16: RI's part done (rerun at 7/12 passes); NGD read on lane_rcu_res at assembly (12 without flop).
4. RI-11/RI-13 (TI rev 332): verify on merged tip, close RI-13 (and RI-11 for RCU).
   RI-12: close when OI's fix lands (OI rev 287).
5. At bank assembly: row 135's gate (RA rev 80), rcu_r pr_orow output, block CG totals
   (lead/credit waiver flops charged; sum of parts), block NGD for lane_rcu_res, write_row_named vs ZROW.
6. Remove worktrees ri-wt2, ri-wt3 when done.
