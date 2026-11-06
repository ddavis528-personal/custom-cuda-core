# RI handoff (RCU implementation)

Updated 2026-11-06. Keep current at every task's end. Role and ownership:
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
- Last push: 269efe6 (SPLIT SCOPED PASS; carries a90cb8f, d2ca2d7, 3c912d1, a4592af).
  Then sweep merge 699d0c9 + regen bcc5f44 (5 branches), not yet gated.

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
Bookmarks 2026-11-06: Conventions 17, AR 308, OA 366, IS 190, TI 349, OI 306, CP 155, DA 112, RA 89, RI 21.
RI-15 closed. RI-17 open (198 lead flops: MIU 4x46 + R 14), commit cell says awaits push.

## Open work, most urgent first
1. Gate + push bcc5f44 + handoff/rcu-impl.md commit (sweep merge: full or split full gate).
2. RI-17: mark pushed at 269efe6, check-cg charges lead/credit marks; close. Tell TI (row +
   notice) that a90cb8f, d2ca2d7, 3c912d1 are pushed (TI rev 330).
3. RI-16 pricing (TI rev 352 recipe): flopped arm = defaults; zero-cycle arm = drop lane_rcu_res
   from RCU's except list in params/links.json, LANE 7 / SFU 12, regen (in ri-wt3, never committed).
   Run S1 and CoreMark32 each, detached; RI row for RA and DA.
4. RI-11/RI-13 (TI rev 332): verify on merged tip, close RI-13 (and RI-11 for RCU).
   RI-12: close when OI's fix lands (OI rev 287).
5. At bank assembly: row 135's gate (RA rev 80), rcu_r pr_orow output, block CG totals.
6. Remaining phases per docs/rcu-impl.md: rcu_mig, lane/SFU descriptor pipes, assembly (M5-M7).
7. Remove worktrees ri-wt2, ri-wt3 when done.
