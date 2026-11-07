# RI handoff (RCU implementation)

Updated 2026-11-06 (evening). Keep current at every task's end. Role and ownership:
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
- Last push: d227bf0 (SPLIT SCOPED PASS; 8ebe948 ret-check fix + TI's dc380a1 merge),
  after 6e0402d (SPLIT PASS, full). TI merged RI-17 at dc380a1 (TI rev 355).
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
Bookmarks 2026-11-06: Conventions 17, AR 308, OA 366, IS 190, TI 356, OI 306, CP 155, DA 115, RA 95, RI 24.
DA 114/115 bar for zero-cycle rx ends (S1 gain): <=0.2% stays flopped; 0.2-0.5% Daniel; >0.5%
architect may approve only if the end meets module NGD without the flop; can't meet 12 NGD -> Daniel.

## Open work, most urgent first
0. rcu_mig restructured, local 16f0c65 (on gate-scratch/RI, unverified): 400 seeds + controls pass,
   M5 dm 65 / rs 66 of 68. CG/NGD run: ~/ccv-logs/mig-chk.sh -> mig-cg.log, mig-ngd.log. Then
   slice 192 unit check, split gate, push (with 1d4b3dd, 20ab341), RI row to RA (kmask clear +2
   ordering note, head-warp restore pick, dropped rs warp compare, ZROW vs write_row_named).
   TI rev 356: Z (f4ce0fd, LANE 7/SFU 12) gating, push ~2h; RI-18 kernel 2026-11-07. After Z
   merges fix stale 8/13 comments: sim/rcu/rcu_test.cpp:179,216; cg-waivers.json rcu_kill kd why
   (KILL_DRAIN 16 at SFU 12, still 5 flops).
1. RI-16 DECIDED (RA rev 95): lane_rcu_res zero-cycle (LANE 7 / SFU 12), link_n 0 forever, on
   condition the block-level read at RCU's assembly holds 12 on it without the flop (else Daniel).
   TI drops it from links.json except + retimes 5 controls. When TI lands it: merge, run
   sim/rcu/run-tests.sh + check-kernel; RTL descriptor pipes (lwb_d/swb_d) at the new depths.
2. RI-18 (rev 23, TI): ret held-check key fixed (8ebe948); TI to add a ret-replay kernel and a
   --break; RI then keys the model's check by returned lanes under that brk name.
3. RI-11/RI-13 (TI rev 332): verify on merged tip, close RI-13 (and RI-11 for RCU).
   RI-12: close when OI's fix lands (OI rev 287).
4. At bank assembly: row 135's gate (RA rev 80), rcu_r pr_orow output, block CG totals
   (lead/credit waiver flops charged; sum of parts), block NGD for lane_rcu_res if Z.
5. Remaining phases per docs/rcu-impl.md: rcu_mig, lane/SFU descriptor pipes, assembly (M5-M7).
6. Remove worktrees ri-wt2, ri-wt3 when done.
