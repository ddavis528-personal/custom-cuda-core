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
AR 426, OA 506, IS 201, TI 594, OI 427, CP 160, RA 159, RI 93, MA 221, MI 74, DI 99, DA 136,
Conventions 20; specs MIU 236, Common 9, DCU 142. Friday pings sent 11-27; all 11 ponged ok, and
every agent's ping to MI answered.
- Sweep merges: ort on many criss-cross bases can run hours. Use scratchpad/sweep2.sh: merge-tree
  against the one base with fewest conflicts, auto-resolving only where one side's blob is in the
  other's history; anything else stops for a decision.
- MI tab rev 72: MI-47 (8566e6ff to TI; MI-20/29/46 decided), MI-48 (TI-590, OA-505).
- TI-569/571: ccv_miu.feedback.json lands with the ccv_miu assembly (held at
  scratchpad/ccv_miu.feedback.held.json, "by": "MA" per DA-135).
- AR 416: MIU NS multi-spend reads registered thr_q (+1 depth); {K,2K} QDEPTH 16 waiver 8 flops.
- MA-34 rev 220 / DA 136 / TI-584 (option B): 160 DCU req ids, 8-bit req_id, memops in flight 8
  (CCV_MIU_MEMOPS_INFLIGHT; TI params ec4270d4). IdPool caps at ccv::kMiuDcuIds (3rd arg).
  AR 419: time the 160-id free pick against 25 NGD (free-list FIFO is flat); over -> split by bank (20/bank).

## Open work, most urgent first
0. TI landed c0883a36 (TI-592) with MI's 1ed1800b; merged into mi-dev (28b755f4, sweep). TI takes the
   miu_form clang++ fix (104678de, pushed in 208e4c46; MI-49/50, RI-64) in its next push and drops
   miu_form from heavy-units. Now: re-measure MI's IMPL_PINS rows on option-B params (held-wait
   875/876, privwin priv_form 10, UE rows; TI-590), then answer TI-590 in an MI row.
1. Option B rest: model IdPool cap at ccv::kMiuDcuIds (TI-584), 8-bit req_id, memops 8 (after ti-rp lands).
2. miu_grp remaining: window fill RTL (same-bank fill-vs-pass case + control in lead_tb, MA rev 213);
   lines + lost flag (OA-486 assertion + control); drop_held; predicate-transfer faults.
3. Then: miu_hitq, miu_rsp (fill assertion + orphan control, MA rev 187), miu_ext, miu_ecc (K=128,
   syndrome R2, budget 17), miu_out, ccv_miu top (+ feedback.json); miu_cred -> TI's common counter.
4. Model: UE on a clean line keeps req_id live (AR 403); mispredict late answer at due+2 (AR 405);
   MI-11 (2); way-mispredict path (AR 390). Awaiting TI: MI-4, MI-8, MI-9 (3), MI-13. M0 report.
- Scratch: scratchpad/wt-tr worktree (its sim/miu/miu_block.cpp has an L0T debug trace; never carry).

## Pushed
- ccr-58815650-0ch1hh at 208e4c46: SCOPED PASS (miu_form clang++, handoff); RI and TI rung.
- Sweep merge of Fri 11-27 (2nd firing, 8 branches) on mi-dev: full gate-push in flight.
