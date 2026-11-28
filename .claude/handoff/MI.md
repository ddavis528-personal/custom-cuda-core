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
- RTL lessons: CCV-L23 no self-feeding shift array; a hold enable (prev || self valid) must be
  `logic x_en_cmNNh; assign ...` (the D-side exemption skips `wire x = ...`), named <what>_en; a comb net read by more than its own state's
  flops goes inline in always_ff; no package-to-package params; one assert label per module;
  tags _cmNNh; RST-1; CG-5; (* keep *) output copies; payload no-flop end: compute both, mux last.
  Sum == constant without a carry chain: A+B+c == K iff A^B^K == {Z[n-2:0], c}, Z = A&B | (A|B)&~K.

## Register bookmarks (sweep of Sat 11-28)
AR 437, OA 518, IS 201, TI 609, OI 439, CP 160, RA 164, RI 101, MA 233, MI 77, DI 108, DA 136,
Conventions 20; specs MIU 236, Common 9, DCU 152. Friday pings sent 11-27; all 11 ponged ok.
- Sweep 11-28: 10 branches merged (0c9dd8f6), full gate PASS, pushed.
- Sweep merges: use tools/sweep-merge.sh (TI-605: the one procedure; virtual base, history-only
  resolution, signs the merge). scratchpad/sweep2.sh is retired.
- MI tab rev 72: MI-47 (8566e6ff to TI; MI-20/29/46 decided), MI-48 (TI-590, OA-505).
- TI-569/571: ccv_miu.feedback.json lands with the ccv_miu assembly (held at
  scratchpad/ccv_miu.feedback.held.json, "by": "MA" per DA-135).
- AR 416: MIU NS multi-spend reads registered thr_q (+1 depth); {K,2K} QDEPTH 16 waiver 8 flops.
- MA-34 rev 220 / DA 136 / TI-584 (option B): 160 DCU req ids, 8-bit req_id, memops in flight 8
  (CCV_MIU_MEMOPS_INFLIGHT; TI params ec4270d4). IdPool caps at ccv::kMiuDcuIds (3rd arg).
  AR 419: time the 160-id free pick against 25 NGD (free-list FIFO is flat); over -> split by bank (20/bank).

## Open work, most urgent first
0. Pushed 285eaef0, 196cd569 (SCOPED PASS) and sweep 0c9dd8f6 (PASS; d5903f2b merged). MI tab rev 77: MI-52 (ruled, below), MI-53 done: TI landed picks + bin at d5903f2b (TI-611, TI rev 608); merge at sweep.
   MA tab rev 224: MI-52 ruled. New miu_pass (1 inst, stage H-1): picks every MQ-sourced lookup
   (later passes, window fills, drains incl st.pred RMW and atomic A1/A3, walker reads); TLB lookup
   (its one port, RR with L0 refills) before offering; flops per-lookup-slot candidate at H-1
   {valid, PA line, set, bank, pa_fold, kind, MQ entry}. Order: walker, N_drain-fired drain, fills +
   later passes oldest MQ first, other drains. miu_lead gains a flop-selected 2:1 before req valid
   and lead flops: slot k takes the candidate only when no first pass owns k by footprint (miu_pair
   H-1 flops), never on the late credit-gated valid. Pass spends bank credit via miu_cred; used[b]
   counts it. miu_a2 muxes payload by flopped pass bit (PA from candidate, no L0). A2 ranks every
   first pass ahead of every pass; loser dropped like a first-pass loser, re-offered later.
   Bins pass_bank_lost, pass_slot_busy; controls pass-wins-bank, pass-on-owned-slot. Responses by
   req_id (miu_ids), never hitq. Partition row comes with slice 2's notice (wait for it).
   MA-35 merged (8bd5f9f2, MA's cd94f843: lofold in miu_a2, unit miu_a2_s64, control lofold) and
   accepted in MI-54 (rev 77, rung MA); MI-51 closed (MA's 669cfdde). Pushed 196cd569 (SCOPED PASS).
1. Option B done in the model (0c891315): IdPool(width, slots, ids=kMiuDcuIds) interleaved
   id%4 = slot; record gate recs_ = CCV_MIU_MEMOPS_INFLIGHT (env lowers it), bin miu_memop_rec_full.
2. miu_pass (MI-52) once MA's slice-2 notice brings its partition row. miu_grp remaining: lines + lost flag (OA-486 assertion +
   control); drop_held; predicate-transfer faults.
3. miu_hitq landed (ef9bb022; 253 flops, 22 gates). Next: miu_rsp (fill assertion + orphan
   control, MA rev 187; reads hitq's hv/he/hs at R1), miu_ext, miu_ecc (K=128, syndrome R2,
   budget 17), miu_out, ccv_miu top (+ feedback.json); miu_cred -> TI's common counter.
4. Model: UE on a clean line keeps req_id live (AR 403); mispredict late answer at due+2 (AR 405);
   MI-11 (2); way-mispredict path (AR 390). Awaiting TI: MI-4, MI-8, MI-9 (3), MI-13. M0 report.
- Scratch: scratchpad/wt-tr worktree (its sim/miu/miu_block.cpp has an L0T debug trace; never carry).

## Pushed
- ccr-58815650-0ch1hh at 208e4c46: SCOPED PASS (miu_form clang++, handoff); RI and TI rung.
- ccr-58815650-0ch1hh at 196cd569: SCOPED PASS (MA-35 merge, handoff).
- ccr-58815650-0ch1hh at 285eaef0: SCOPED PASS (option B model, miu_hitq, handoff).
- ccr-58815650-0ch1hh at 8719d88b: full PASS (sweep merge of 8 branches incl. TI's c0883a36).
