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
Conventions 15, AR 256, OA 286, IS 180, TI 271, OI 239, CP 148, DA 97. Pings: Friday 10-30's all
answered (checked 10-30); next pings Friday 11-06.

## State
- Branch tip: the 10-31 sweep merge on da182a7 (ROB slice 2 part 1). TI's
  47e2622 (OI-92: ccv-skel's launch log only when traced) arrives with
  TI's next push; until then coremark128 needs over 11 GB.
- Model defaults: retire_lag 0 (OI-87: go_tb diverges under 1),
  release_names_lag 1 and squash_room_lag 1 (OA rev 280).
- Slice 2 knobs in wt4 (all 0 until DA rules, OA rev 284): resolve_lag,
  squash_act_lag, held_room_lag. Audit 901 base; rl1 916; rl1+sal 929;
  rl1+sal+hrl 934; sal 912; sal+hrl 920. S1 45,438 base, 45,805 at rl1
  (squash/held lags +0). coremark32 4,663,694 base, 4,693,463 rl1 (sal +0).
- coremark128 base 17,612,876 (155,416 redirects, wt4's model). The rest
  of OI-88's CoreMark runs are on RH (session_01QPk2jvfKM1V5rRfip8FC86,
  DA's run helper): skeleton da182a7, oracles from 21f7150 (pin d9ddd2c
  faults, OI-91 to TI); coremark128 base, rl, rlsh, sh, then coremark32
  sh, rlsh, one at a time, about 12 h from 2026-10-31 02:47 UTC; results
  by send_message, then the table to OA. Never run coremark128 here
  (OOM at 11 GB).
- wt5: slice 2's tree. Part 1 pushed (9be452c, da182a7: per-row done
  counts, OI-90; the model's knobs and log). Next, part 2's RTL per
  scratchpad plan-rob2.md: branch records, resolution, squash, held
  entries, room with holes; and ooe_rs's side of the row hold.
- OI-90 to OA: rev 282's done bit misses a cancelled issue's done; per-row
  counts proposed, width OA's.

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
