# OI handoff (OOE model and RTL)

Updated 2026-10-30. Keep this current at every task's end; it is what
survives a compaction. CLAUDE.md holds the repo's rules; this holds OI's.

## Working rules
- The user is DA (Daniel). Standing order: rename top, atomics, barriers,
  AR-24 (d), then RTL items 5-8 (done but 7), then the ROB slices; no need
  to ask DA for a go unless there is a key decision point.
- Push only to `ccr-57eff422-5tdecg` (`git push -u origin HEAD:ccr-57eff422-5tdecg`,
  retry with backoff). Never push red: the clean gate is `tools/regen.sh`
  then `CCV_JOBS=4 ./tools/verify.sh`, run alone (no CoreMark beside it:
  memory). No PRs. Don't edit a tree while a gate runs in it.
- Owners: OA the microarchitecture and port budgets; DA waivers and
  anything over OA's 0.5%; TI schema/, params/, tools/ (OI carries a tools
  fix only when TI says so, as OI-89). Never weaken a negative control.
- Commits end with the Co-Authored-By and Claude-Session lines; no model
  ids in commits or artifacts.
- Register: write only the OI tab (node 384bc26c-cef6, table
  m8yvbw8rqgz.11664, rows: title, date, summary ending "Needs: X",
  detail). Notices via `.claude/skills/register/notice.py` and
  send_message. Pings weekly, Fridays (TI-49, DA).
- Trees in the scratchpad (/tmp/claude-0/-home-user/<session>/scratchpad):
  wt the sweep tree, wt3 slice 1 (pushed), wt4 slice 2 work (at 21f7150 +
  uncommitted model edits). Disk is a fixed allowance: delete build dirs
  you no longer need; one gate's build is about 15 GB.

## Daily sweep (scheduled task trig_01RHTzEomNoTP7mgfQxaNkmm)
Read every tab since the bookmarks; merge every remote branch that is
ahead (not release) into wt, gate, push; pongs; pings on Fridays only.

## Register bookmarks (revs read through)
Conventions 15, AR 255, OA 284, IS 176, TI 267, OI 234, CP 143, DA 97.

## State
- Branch tip 9c079f9 (ROB slice 1, check-cg generate-scope fix). The merge
  of TI's ccr-183cc441-doowtf (row-indexed dones 6ba08b1, handoff
  mechanism, %privoff) is on wt, with this file.
- Model defaults: retire_lag 0 (OI-87: go_tb diverges under 1),
  release_names_lag 1 and squash_room_lag 1 (OA rev 280) in wt4 only.
- Slice 2 knobs in wt4 (all 0 until DA rules, OA rev 284): resolve_lag,
  squash_act_lag, held_room_lag. Audit 901 base; rl1 916; rl1+sal 929;
  rl1+sal+hrl 934; sal 912; sal+hrl 920. S1 45,438 base, 45,805 at rl1
  (squash/held lags +0). coremark32 4,663,694 base, 4,693,463 rl1 (sal +0).
- Runs in flight: coremark128 base, rl, rlsh, sh in wt4
  (build/bench/coremark128.<n>.log), serially, about 3.6 GB each.

## Open work (most urgent first)
1. coremark128 results to OA (OI-88 package for DA, OA rev 284).
2. ROB slice 2 (OI-85): RobLog extension done in wt4's model; RTL per
   scratchpad plan-rob2.md (mis bit at C, oldest pick and squash register
   at R, squash acts at R + 1, held entries, room with holes, records);
   rob_tb on the new log. Move wt4 onto the branch tip first.
3. Land with slice 2: model fixes in wt4 (release_names_lag V-01 at slot
   release; swap seed 2 forced DRAM miss, OA rev 284).
4. OI-87: go_tb/model divergence under retire_lag 1 (CAS pairs under
   stall.share.rs); then flip the default with check-kernel's re-pins.
5. ROB slices 3-6; RTL 7 (barriers, in slice 5).
