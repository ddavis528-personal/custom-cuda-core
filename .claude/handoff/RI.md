# RI handoff (RCU implementation)

Updated 2026-11-08. Keep current at every task's end. Role and ownership:
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
- Last push: 5ac616f (2026-11-07, SPLIT SCOPED PASS 22/22): TI's de03fd6 bundle (O-85, IS-21 atomics,
  #88 fix) and 31168a3 (stub DCU 8x64: rebaseline cycle counts) merged on 64fce0d (RA rev 98).
  Before: ba0df94 (lanes+mem). Before: 350729e (SPLIT SCOPED PASS, 2026-11-07): rcu_mig, slice zero-fill gate, lint
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
Bookmarks 2026-11-08 (notices): Conventions 17, AR 322, OA 379, IS 190, TI 379, OI 324, CP 155, DA 115, RA 103, RI 42.
DA 114/115 bar for zero-cycle rx ends (S1 gain): <=0.2% stays flopped; 0.2-0.5% Daniel; >0.5%
architect may approve only if the end meets module NGD without the flop; can't meet 12 NGD -> Daniel.

## Open work, most urgent first
-2. IN FLIGHT 2026-11-08: chain-ri5 (~/ccv-logs/chain-ri5.sh, out chain-ri5.out) gates ri-wt2 branch ri-dec
   (de9894d: module fixes, ccv_rcu.sv removed) and pushes. Then merge ri-retime (ri-wt4: d38ab59 retime,
   f3f5de7 arrivals at fanout term + rcu_pred act_d pre-decode, 521d4fa stall flopped + stall2 control;
   all unit NGD/CG + run-rtl clean) and gate it the same way. Then, when TI's ti-ri22 (TI rev 381) lands:
   restore ccv_rcu.sv (gen: /home/user/ri-keep/gen_ccv_rcu.py; in 952dd81) + ccv_rcu.ngd.json (draft in /home/user/ri-keep;
   scratchpad: lane_rcu_res_cNN arrival 13), rerun block check (blk_ngd.py), gate.
   Rows written RI rev 44/45: re:RI-22 rulings (M5 65/67 of 68, RA to confirm), (e): 14 issue in-paths
   over 12 (worst lanes dst 20.7). RA rev 111: M5 confirmed, RI-22 closed; (e) re-run (RI rev 47): only
   lanes 14.5 (odst/opos/spos/src) left; +128 lead flops -> 10.9 block worst; ~567 lead flops vs 2% ~4,850. Await RA.
   Still owed: re:RA-42 (BND_ISS term in KILL_DRAIN, model+RTL; checker at KILL_DRAIN-1 control),
   RA rev 102 re:RI-21 (slice L/M owner assert + control; pred drives PC0-3; kill flop TODO).
-2. PHASE 5 (2026-11-08): worktree /home/user/ri-wt2, branch ri-dec: 415b0ca P7, 847d085 P2,
   c8dbab0 pred/mig fixes, fe76e2a ccv_rcu.sv assembled + RA-42 (on gate-scratch/RI). ccv_rcu.sv
   is written by scratchpad gen_ccv_rcu.py + ccv_rcu_body.svf (hand-edit the .sv once settled).
   Block check loop: scratchpad blk_ngd.py (check-ngd's block_check on RCU units only),
   log ~/ccv-logs/blk-ngd.log. New units: rcu_bank_slice_k0/_k2/_k3 (ROWS 192), rcu_clk (NWAKE 37).
   Next: block NGD clean -> regen, check-1d, run-rtl.sh, split gate, gate-push (merge ri-dec into
   ccr-888218a3-20cauz). Then RI rows: re:RA-42 (RTL 15->16 via CCV_LAT_RCU_KILL_DRAIN; the model
   already added bnd_rx via Config; M4 kernel control at cut 1 still to run), re:AR 322 (RA-41 TODO
   flops marked in ccv_rcu.sv header), RA FYI: P2/P7, lanes pcm CG-3 waiver, slice ropc/rmrg
   arrival 0, SFU never decoded, no PXOR, S6 kill credit in series, CSR wake (Q-59).
   Then task 5c: lock-step vs model, RTL event monitor, Q-53 checkers.
-1. J9 settled (AR 320): the cliff was the stub DCU's 8 KiB direct-mapped default; TI made it 8x64
   (31168a3). Not RCU. #88 fixed by TI (21b4356, reviewed RI rev 39); TI rev 367 ran coremarkpl32 to
   the end on the model. OI-127/OI-129: A2 carries ppdst/pred_we/ppold (OI f727aed); the model's
   lane write-back already writes it (RI rev 40). When TI says a CAS-with-pd kernel exists, run it
   on model and stub.
-0.5 RA rev 100 limits: rcu_pred gd_cr02h in-flop must stay <= 24.5 (now 23.9; first remedy:
   pre-decode act_d); class-bit arrival 5 must hold with the atomics term added. TI built an
   rcu_rtl gate section (0a6b7b3, TI rev 374) running test/rcu/run-rtl.sh: merge it at the sweep.
0. RI-19: note 1 confirmed (RA rev 96); mig_q_drop pushed 12e6b7b (RI rev 30). Close when RA has no more. Was: kmask +2 clear vs a
   relaunched warp's first row (>= 2 cycles after its map). Notes 2-9 in the row.
   Lessons: run tools/check-1d.sh before a gate (the linter misreads 1'b0 in a wire's concat and a
   for loop's <= bound); run tools/regen.sh after any merge before testing (sim/generated not checked in).
1. DONE: Phase 4 rcu_lanes + rcu_mem pushed ba0df94 (SPLIT SCOPED PASS); RI-20 to RA (rev 38):
   class-bit arrival 5, act_cr02h budget; notes FYI. Lesson: check-cg wants the reset if alone
   in its always_ff (CG-1), and grep a unit run for every CG-n, not only CG-3. Old item: RTL, benches (lanes_tb, mem_tb; controls
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
