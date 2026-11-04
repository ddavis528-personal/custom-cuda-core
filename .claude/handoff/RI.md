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
Conventions 17, AR 275, OA 331, IS 189, TI 310, OI 274, CP 152, DA 106, RA 64, RI 5.
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
1. M0 MET and pushed (5968894, SPLIT SCOPED PASS 22/22; 2026-11-04). Reported as RI-8 (RI rev 5),
   with RI-1/2/3 closed in responses; notices sent to RA and TI. Cycles ~/ccv-logs/m0-cycles.txt.
   Wait for RA's acceptance and TI flipping the default; TI to fix GUARD_FWD's doc.
   Split gate recipe when every section runs: verify --changed <base> --only cg, export; same for
   ngd; gate-push --import=a.tgz,b.tgz (each part under the 2-h background limit).
2. Answer TI/RA/OI responses to RI-1..7 at the daily sweep.
3. Phase 2 (bank slice, R pipe RTL): start now; NGD fanout>4 is enforced (RA-33).
