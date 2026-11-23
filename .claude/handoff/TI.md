# TI handoff (top-level implementation)

Updated 2026-11-22. Keep this current at every task's end; it is what
survives a compaction. CLAUDE.md holds the repo's rules; this holds TI's.

## Working rules
- Push only to `ccr-183cc441-doowtf` and
  `claude/custom-cuda-core-infra-6msg93`, only through
  `CCV_PUSH_BRANCHES=ccr-183cc441-doowtf,claude/custom-cuda-core-infra-6msg93
  tools/gate-push.sh` or `tools/daily-sweep.sh` with the same env (ALWAYS set
  it for the sweep). No PRs, no force-push of a working branch, never ungated.
  Ungated backup: `git push -qf origin HEAD:refs/heads/gate-scratch/TI`.
- Never bare `git stash`. Never edit a worktree while a gate, check or sweep
  runs in it (`ps aux | grep -E 'check-|gate-|verify|daily'`). One heavy job
  at a time (15 GB container).
- Never merge another agent's gate-scratch branch wholesale (OI's ungated RTL
  broke ti-mi9, 11-20): take only the commits or paths needed.
- Deleting other agents' /tmp/tmp.* was denied by the auto-mode classifier:
  don't work around it; ask Daniel if space is needed. Scratchpad priv/ is
  unknown: leave it.
- Commits end with the Co-Authored-By and Claude-Session lines from the
  session's attribution reminder. No model ids in commits or artifacts.
- Edits to OI's files (sim/ooe/*) follow OI-18: edit, then notify OI.
- Record a DA decision only on Daniel's word or a DA-tab entry.
- Register: write only the TI tab (node e8b1d9d9-df9b; responses table
  m8yvbw8rqgz.217). Writes need container {"kind":"project","id":
  "JApHYjaUESeq8tsGMGXMU5"}. Notices via `.claude/skills/register/notice.py
  compose`, `send_message` priority "later". Pongs: `notice.py pong --me TI`.
- Notices' rows: `register-reader` subagent; gate red: `gate-triage`.

## Daily sweep (scheduled task trig_01A8r3ENUjnLyTaNUcc23ZbF, 02:11 PT)
Register section 4 from the bookmarks; then the repo half (daily-sweep.sh,
detached; wait with gate-wait). Exit 3 = a real conflict to resolve.
Since 7b0bbe2a (ti-oo, not yet landed) the sweep merges fewest merge bases
first and retries a merge past CCV_SWEEP_MERGE_TIMEOUT (300 s) with
`-s resolve`. Until it lands: a merge hung for minutes = kill the sweep,
`git merge -s resolve` that branch by hand, rerun the sweep (11-20: OA's
4-base branch hung 25 min; resolve took 0.15 s).

## Register bookmarks
/home/user/ti-register-bookmarks.json (outside the repo). 11-23: TI 520,
OI 402, AR 409, MA 157, MI 35, DI 46, MI 36; the rest as of the 11-22 sweep.
Last row TI-522. Row insert payload: ops insert, target {"kind":"blocks",
"ids":["m8yvbw8rqgz.217"]}, side end, source {"as":"blocks","from":{"kind":
"inline","content":[tableRow of 4 tableCells, each a paragraph of text]}}.

## Long runs
Every long tool detaches and exits 5. Wait with `tools/gate-wait.sh <log>` as
a background task, timeout 7200000 (exit 3: rerun the wait; 4: rerun the job
with CCV_RESUME=1; RESUMED PASS counts as the full gate, Daniel 11-20).

## State (2026-11-23)
- DI-23 answered (TI-522, no code change): localsp mru doubling is the
  stub MIU's MA-14 cross-warp head-of-line block behind a pred-store RMW
  through the cacheless MLC stub (2 x ~1,000-cycle trips); MIU model shows
  mru +3 cycles. Stub stays the functional reference (MA-14).
- Landed 8e784c88 (SCOPED PASS 28/28): verify.sh sections dcu_rtl and
  miu_rtl (DI's/MI's run-rtl.sh), gate-scope maps test/dcu, test/miu;
  DI's DCU paths from 3b6b66f2 taken by checkout (merge: too many bases).
  TI-521 to DI, MI (DI asked to check nothing missing).
- 11-22 sweep landed 8ca2bf1b on both branches (full clean gate); release
  041c6c62, tag snapshot-2026-11-22-8ca2bf1 refused (local only). It merged
  MA's spec branch, AR's ccr-80102643-4n8bv4 (by hand: main.cpp --break
  list conflict, HEAD's side a superset) and OI's ccr-57eff422-5tdecg (17).
  OI's c69ee1a3 (provswap CCV_RAU_CONCURRENT=1, confirmed TI-520) and
  dc2c3697 (demote_walk=1 default, OA 466) came after: next sweep.
  /home/user/ti-ret is gone; sweep from /home/user/ti-l23.
- Landed 63579fce (SCOPED PASS): MA-30 pa_fold (CCV_W_PA_FOLD), waypred
  bits 4 / sel index, sim/skel/wayfold.h + rtl/common/ccv_common_wayfold.sv
  lockstep, miu-fold-flip control, dcu-wp-nocompare registered, MI's
  putIndexLead one-liner (MI owns it), waypred retarget; CCV-L23 table form
  (DA rev 131) with check-1d fixtures. TI-518 (MA AR MI DI), TI-519 (OI OA).
- Landed bc9d61ff: MA-29 check_bits 72 (CCV_DCU_ECC_K=128). TI-517.
- Gate times: a scoped gate touching params now takes ~7 h (cg 3.4 h, ngd
  3.7 h, mostly heavy-unit serialisation); plan pushes around it.
- Disk: scratchpad priv/ and ~/.cache/ccache untouched: ask Daniel before
  clearing. Worktrees ti-ecc72, ti-fold, ti-drop are landed and clean:
  their build/ dirs may go.
- Known: MIU-model rows on bank bounds are stub-MIU only (slotform,
  coremark128). AR 405 leaves MA to state the mispredict path; a DCU
  response field for it would be a new TI row.

## Open work (priority order)
0. MI-12 order (Daniel via MI): all done (TI-506, 508, 509).
1. Task 55: OI-193/195's fix and decq_credit_lag knob (oi-sw 0fc3dc5a)
   land with OI's sweep merge. Then: lag 512 --cycles 200000 pass
   (mig_credit_wait>0) and mig-before-credits CHECK; due-epoch-lost; and check-kernel line for MI-11 (lnorm1 CCV_MIU_IMPL=model
   CCV_RAU_DEMOTE=mlc clean, parks>0, FET wait on). OA 462: binding dropped;
   once OI shows the released-slot CHECK catches it, --break
   mig-before-credits becomes the full-credit wait's control line.
2. Task 59: demotion restore hang (transp4 CCV_RAU_CONCURRENT=1 at:286
   and later: demoted warps never restored) and narrowadd at:100-126 PCA
   parked R2 upper half lost (MI-5). Then the pair dcu-drop-credit /
   dcu-drop-answers controls once MI's drop sender lands.
3. Task 51 rest: MI-7 page-boundary kernel; MI-5 bins/slow regions.
4. AR 370 ccv_common_err RTL; task 28 RAS wrapper (BIST override, spare
   row/column, broadcast groups); AR 371 SPM banks; AR 392 PT base CSR
   with Q-50; AR 393; OI-187.
5. Low: RA re:RI-46 (3) SFU kill variant; RA 148 (post-sign-off).
