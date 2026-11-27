# MI handoff (MIU implementation)

Keep current at every task's end, in a few kB (older detail is in this file's git history).
Role and ownership: docs/miu-impl.md. Spec: MIU tab of the per-block specs, pinned at
docs/design-snapshots/miu-spec.md; the live doc https://claude.ai/artifact/DJeg9Hh8rkPDecq4hrAz35
wins (spec content nodes: MIU aa7a288a-dae2, Common 55ddf104-fe08, DCU c18a112b-d2c6).

## Who and setup
- MI = session_01QPk2jzH1Gd3DcxK4F4pwCC. Register tab MI node c1311541-4219; write only there.
  MA session_01QPk2jyUbWA7fW9YpUwqdxk, TI session_01J4Yp3xeV6DJtgCtcoqVsAq,
  OA session_01TbX2MyX6quhjarDR7J2bMR, DI session_01QPk2jz5TVESyWMKVKjqqEA.
- session-home installed (Daniel OK'd); --check matches.
- Daily sweep scheduled task trig_01Szj1auKDJc4j8N6oZMnp69, 02:39 America/Los_Angeles.
- Toolchain: ./tools/setup-toolchain.sh, then ./tools/regen.sh.

## Branch, push
- Work tree /home/user/mi-wt, local branch mi-dev, pushed to ccr-58815650-0ch1hh.
  (/home/user/custom-cuda-core is an older checkout of the push branch; don't work there.)
- Push: `CCV_JOBS=3 CCV_PUSH_BRANCHES=ccr-58815650-0ch1hh tools/gate-push.sh` (`--full` for the
  sweep), then `tools/gate-wait.sh <job log>` as a background task (timeout 7200000); exit 3 rerun,
  exit 4 (killed) rerun gate-push with CCV_RESUME=1 (RESUMED PASS counts as full, TI-490).
- Merge commits only; never rebase, force-push, reset --hard, bare stash. No PRs. No model ids
  or dates-as-deadlines anywhere. Commits end with the Co-Authored-By and Claude-Session lines.

## Working rules beyond CLAUDE.md
- MI owns sim/miu/, rtl/miu/, test/miu/. Never edit schema/, params/, tools/, rtl/top/, stubs
  (incl. class Miu in sim/skel/kernel.cpp), blocks.list: MI-n row, TI in Needs. Never commit sim/dcu.
- Port budgets and feedback/loop declarations with no measured parent are MA's (DA-135, TI-580):
  write only MA's approved values, `"by": "MA"`, citing the rev. Architecture questions: MI-n, MA.
- Model: cycle-accurate at ports and events; oracle for checks, never decisions; --break controls
  must keep failing. Never weaken a control.
- Ring a notice only for a row that asks something of, or answers, its receiver.
- Docs write: mcp__Claude_Docs__update ref node c1311541-4219, container project
  JApHYjaUESeq8tsGMGXMU5, engine prose, ops insert target {kind:blocks, ids:[m8yvbw8rqgz.613]}
  side end, rows of 6 cells (ID, status, priority, refs, Needs, text). Responses table m8yvbw8rqgz.675 (4).
  Notice: python3 .claude/skills/register/notice.py compose --from MI --to X --rows MI-n --rev N --summary ..
- Single-unit checks: tools/bg-run.sh <name> python3 tools/check-ngd.py --unit <u> (or check-cg.py);
  check-cg --unit exit 0 does not apply the module budget: read ungated vs max(2%, 7).
  Lint: python3 tools/lint-rtl.py. Benches + controls: test/miu/run-rtl.sh.
- RTL lessons: CCV-L23 no self-feeding shift array; a comb net read by more than its own state's
  flops goes inline in always_ff; no package-to-package params; one assert label per module;
  tags _cmNNh; RST-1; CG-5; (* keep *) output copies; payload no-flop end: compute both, mux last.
  Sum == constant without a carry chain: A+B+c == K iff A^B^K == {Z[n-2:0], c}, Z = A&B | (A|B)&~K.

## Register bookmarks (sweep of Fri 11-27)
AR 423, OA 503, IS 201, TI 586, OI 427, CP 160, RA 159, RI 92, MA 221, MI 70, DI 96, DA 136,
Conventions 20; specs MIU 236, Common 9, DCU 142. Friday pings (section 6) due after the push.
- To close at MI's next write (MI-47): MI-20 (DI rev 73), MI-29 (DI-50), MI-46 (MA revs 217/221).
- TI-569/571: ccv_miu.feedback.json lands with the ccv_miu assembly (held at
  scratchpad/ccv_miu.feedback.held.json, "by": "MA" per DA-135).
- AR 416: MIU NS multi-spend reads registered thr_q (+1 depth); {K,2K} QDEPTH 16 waiver 8 flops.
- MA-34 rev 220 / DA 136 / TI-584 (option B): 160 DCU req ids, 8-bit req_id, memops in flight 8
  (CCV_MIU_MEMOPS_INFLIGHT; TI params ec4270d4). IdPool caps at ccv::kMiuDcuIds (3rd arg).
  AR 419: time the 160-id free pick against 25 NGD (free-list FIFO is flat); over -> split by bank (20/bank).

## Open work, most urgent first
0. IN FLIGHT: sweep merge (11 branches, no conflicts, 1b3cea3d) + b50828a9 (A2 faults) + e8df1179
   (MQ lane map) + 2a6e4861 (MA rev 217 budgets) + 3b4345f3 (F-SHARED neg-sum bin/control, MA rev
   221's condition for landing b50828a9) + this handoff: full gate-push. Then ring TI with the tip,
   write MI-47 (MI-46 closed, F-SHARED done; close MI-20, MI-29), Friday pings, report.
   Big criss-cross merges: `git -c merge.renames=false -c diff.renames=false merge` (~18 min each).
1. Option B: miu_ids at 160 ids, timed free pick; 8-bit req_id; memops 8; IdPool cap (TI-584).
2. miu_grp remaining: window fill RTL (same-bank fill-vs-pass case + control in lead_tb, MA rev 213);
   lines + lost flag (OA-486 assertion + control); drop_held; predicate-transfer faults.
3. Then: miu_hitq, miu_rsp (fill assertion + orphan control, MA rev 187), miu_ext, miu_ecc (K=128,
   syndrome R2, budget 17), miu_out, ccv_miu top (+ feedback.json); miu_cred -> TI's common counter.
4. Model: UE on a clean line keeps req_id live (AR 403); mispredict late answer at due+2 (AR 405);
   MI-11 (2); way-mispredict path (AR 390). Awaiting TI: MI-4, MI-8, MI-9 (3), MI-13. M0 report.
- Scratch: scratchpad/wt-tr worktree (its sim/miu/miu_block.cpp has an L0T debug trace; never carry).

## Pushed
- ccr-58815650-0ch1hh at c73919f3: full PASS (sweep 11-24 merge eba4a37a + MA-33 fix + handoff).
