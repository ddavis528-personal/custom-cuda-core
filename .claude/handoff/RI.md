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
Conventions 17, AR 275, OA 336, IS 189, TI 321, OI 274, CP 152, DA 106, RA 74, RI 9.
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
0. RI-11 (RI rev 9; notices to RA, OA, TI): DA ruled every block boundary has a flop by
   construction (credited interface module). RCU spec's 'inputs consumed off the wire in A' and
   RA-39's NGD split are void. Repo today: ccv_common_rpt at STAGES=0 is wires, so TI must make it
   real. TI rev 321: DA ruled the interface module defaults to a flop on each
   side (zero-cycle option kept); AR decides the latency accounting, then TI builds it, then RA
   restates. RTL waits (rr_row 8.5, rcu_r arrivals 2 will change). RA/OA held at RA 75 / OA 338.
1. Phase 2 RTL (rtl/rcu/, test/rcu/): rcu_bank_slice (RA-39: R0/R1 read from phys_src on the
   wire, rsrc flopped per slice with MW write-through), rcu_r + rcu_xbar. Figures sent to RA as
   RI responses rev 8 (notice sent): phys_src->rsrc 18.4 vs 18 at 192 (miss 0.4) RA-39 CLOSED (RA rev 74, OA rev 337):
   RCU in 19 / OOE out 6; rr_row arrival 8.5 set. Departures (1)-(3) accepted. rcu_r 2,626 flops, 23.9 NGD, CG clean. Departures to confirm:
   low from pred's flops, the .ngd.json arrivals, RI-9 (e). RI-10 (192-row cg harness) with TI.
   Benches: test/rcu/run-rtl.sh (all units + controls nowt/noalign/retlow).
2. Push chain: ba3549b (main tree) split gate cg passed (~/ccv-logs/gate-cg-ba3549b.tgz), ngd
   part -> gate-ngd-ba3549b.tgz, then gate-push --import=both. Then fast-forward main tree to
   the ri-wt commits (795776d, 316564f, aa00783, 58ae73e + this handoff), regen, split gate, push.
3. TI to merge eac3054 (model drops lead_r_src; on gate-scratch/RI, ri-wt2). Merge TI back after.
4. Remove worktrees /home/user/ri-wt, ri-wt2 once merged. Daily sweep trig_01YVAyULgv3K9NymwVJXZybD.
5. Split gate recipe when every section runs: verify --changed <base> --only cg, export; same for
   ngd; gate-push --import=a.tgz,b.tgz (each part a separate background job, < 2 h).
