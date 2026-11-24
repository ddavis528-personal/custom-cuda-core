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

## Register bookmarks (sweep of Tue 11-24)
AR 421, OA 502, IS 201, TI 582, OI 426, CP 160, RA 159, RI 92, MA 217, MI 70, DI 93, DA 135,
Conventions 20; specs MIU 226, Common 9, DCU 126. Next pings: Friday (section 6).
- To close at MI's next write: MI-20 (DI rev 73), MI-29 (DI-50).
- TI-569/571: TI refuses an orphan feedback.json: ccv_miu.feedback.json lands with the ccv_miu
  assembly (held at scratchpad/ccv_miu.feedback.held.json, "by": "MA" per DA-135).
- AR 416: MIU NS multi-spend reads registered thr_q (+1 depth); {K,2K} QDEPTH 16 waiver 8 flops,
  charged to MIU's 2%. DA 134: non-OOE NGD caps stay 25.

## Open work, most urgent first
0. GATE-PUSH IN FLIGHT (scoped) on mi-dev: b50828a9 (A2 faults) + e8df1179 (miu_mq lane map; NGD in-to-flop
   10.4 worst, CG 77/283 ungated) + budgets (MA rev 217 accepted MI-46). Wait on the newest job-gate-push log
   with tools/gate-wait.sh. When pushed: ring TI with the tip to merge. Also on gate-scratch/MI (older tip).
   MA rev 217's condition: show a negative .shared sum still faults by F-SHARED at A3, with a control
   (with A3's F-SHARED; not built yet). Close MI-46 then. Spec agu8 flops 421/462 accepted.
1. A2 fault slice, mi-dev b50828a9 (LOCAL, held): F-ALIGN, S[49:48] F-ADDR on every lane, window
   F-ADDR (ordinary lane in the windows; interleaved off W's block) in A2's drop; agu8 computes per lane
   we (S[47:16+k] == W>>k, carry-save, no carry chain) and ow; .shared no longer drops on a negative sum.
   agu8 24.8 NGD, 421/462 flops; a2 25.0, 355 flops. Benches: a2_tb win/iblk/align, agu8_tb wnoc.
   MI-46 (rev 70, MA rung) asks: miu_a2 inputs fal/ilv/ow/we_cm06h arrival 0; miu_agu8 outputs
   ow/we_cm06h required 0; spec flops 421/462. ON MA'S ANSWER: write rtl/miu/miu_a2.ngd.json and
   miu_agu8.ngd.json ("by": "MA", the rev), check-ngd both units, copy this handoff, commit, scoped
   gate-push, gate-wait, then ring TI with the tip.
2. miu_grp remaining: window fill in RTL with a same-bank fill-vs-pass case + control in lead_tb
   (MA-33 RTL follow-up, MA rev 213); MQ A2 write and lane map with OA-486's assertion (an outstanding
   MQ line completes or re-misses within pass + refill bound) and control (mutation marks the lost line
   done); drop_held; predicate-transfer faults (lane d's b alone, with its single address from miu_lead).
3. Then: miu_hitq, miu_rsp (fill assertion + orphan control, MA rev 187), miu_ext, miu_ecc (K=128,
   syndrome R2, budget 17), miu_out, ccv_miu top (+ feedback.json); miu_cred swaps to TI's common
   credit counter (TI-537..541) when it lands.
4. Model: UE on a clean line keeps req_id live (AR 403); mispredict late answer at due+2 (AR 405);
   MI-11 (2) lnorm1 under CCV_RAU_DEMOTE=mlc; way-mispredict path (AR 390) once TI's same-set kernel
   exists. Awaiting TI: MI-4, MI-8, MI-9 (3), MI-13. M0 report.
- Scratch: scratchpad/wt-tr worktree (0208d2ad + old trials; its sim/miu/miu_block.cpp has an L0T
  debug trace, never carry it). Remove when nothing in it is wanted.

## Pushed
- ccr-58815650-0ch1hh at c73919f3: full PASS (sweep 11-24 merge eba4a37a + MA-33 fix + handoff).
