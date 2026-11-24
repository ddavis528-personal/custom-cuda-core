# TI handoff (top-level implementation)

Updated 2026-11-24. Keep this current at every task's end; it is what
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
/home/user/ti-register-bookmarks.json (outside the repo). See the file (nested "bookmarks" object; keep updates there). Last row TI-580 (rev 582). Row insert payload: ops insert, target {"kind":"blocks",
"ids":["m8yvbw8rqgz.217"]}, side end, source {"as":"blocks","from":{"kind":
"inline","content":[tableRow of 4 tableCells, each a paragraph of text]}}.

## Long runs
Every long tool detaches and exits 5. Wait with `tools/gate-wait.sh <log>` as
a background task, timeout 7200000 (exit 3: rerun the wait; 4: rerun the job
with CCV_RESUME=1; RESUMED PASS counts as the full gate, Daniel 11-20).
Never run skeleton measurements beside a gate: on 11-23 a coremark run
(2.7 GB) beside check-cg (5.4 GB) OOM-killed the cg job and lost a 7 h gate.
bg-run dies with its 30-min wrapper; a measurement runs `setsid nohup` with a
background `while pgrep` wait.

## State (2026-11-23)
- Landed ba085cda (SCOPED PASS 28/28) on both branches: DI's slice 2
  (a6b8a4eb) + DI-33 (a)(b) lines (04a0f58d); ti-pk (parked check masks by
  ccv-sim width, control parked-full-width; pc_kept on ccv_ooe_rau_drained per
  AR 406/408, RAU stub keeps/derives resume_pc, bins pc_kept_launch/restore,
  control rau-pc-from-drained whitelist-only); ti-mi20 (stub MIU takes a UE
  line's two answers, bin ue_second_answer, control ue-close-first
  whitelist-only). TI-529 to OI, DI, MI.
- 11-23 sweep landed b4930c18 (full clean gate; release d6bbd90e, tag
  refused, local only). It skipped ccr-80102643-4n8bv4 and
  ccr-9eb50716-lecnjf (they moved mid-merge): next sweep takes them.
- Task 59 closed: transp4 restore hang gone (2,000-run scan); narrowadd R2
  was TI's checker (fixed above); early-demote resume_pc 0 became pc_kept.
- DI-23 answered (TI-522): localsp mru doubling is the stub MIU's MA-14
  head-of-line block behind a pred-store RMW through the cacheless MLC stub.
- Gate times: a scoped gate touching params now takes ~7 h (cg 3.4 h, ngd
  3.7 h, mostly heavy-unit serialisation); plan pushes around it.
- Disk: scratchpad priv/ and ~/.cache/ccache untouched: ask Daniel before
  clearing. Worktrees ti-ecc72, ti-drop are landed and clean (ti-fold holds ba085cda):
  their build/ dirs may go.
- Known: MIU-model rows on bank bounds are stub-MIU only (slotform,
  coremark128). AR 405 leaves MA to state the mispredict path; a DCU
  response field for it would be a new TI row.

## In flight
- ti-pt (worktree /home/user/ti-pt, on landed 77f7849e): 9578fbef input-port
  table form (OA-492 (3)) + b3834897 check-ngd OOE cap rise to 30 (DA rev 134).
  Gate restarted with CCV_RESUME=1 after a disk-full stop; job log
  /root/ccv-logs/job-gate-push-20261124-094150-3345.log. On landing: row to OI, OA.
  Never edit ti-pt while it gates.
- ti-hop (worktree /home/user/ti-hop, gate-scratch/TI-hop @ 02dbf5c4, on
  b3834897): orphan check (MI-44), helper hops (OI-213), named crossings
  (OA-494), cone + registered hop (OA-495), OA-496, writer-input exemption
  (OI-217/OA-497/OI-219), OA-498/499 cone sources, OA-500 write-pipeline
  fixed point (u_map's ten off), OA-501 helper crossing over a sibling-output
  source (CCV_LINT_FIXTURE_UNITS for check-1d), OI's u_gfree declarations
  (cherry-picked cf3ce683, 9ffba2bd, ade5d5a1, f05fad61: u_gfree ratchet
  empty, 24 entries left). check-1d 68 PASS, tree lint 0. Gate-push right
  after ti-pt lands (merge its landed tip first); ring OI, OA, MI, MA.
- 11-24 daily sweep: register half done (TI-580). Repo half (daily-sweep.sh)
  waits: run it after ti-pt and ti-hop land, never beside a gate.
- Disk: landed worktrees' build/ dirs were cleared (ti-tw, ti-conn, ti-drop,
  ti-l23, ti-fold). 12G free.
- Then: OA signatures on u_gfree's child-to-child entries (rt_v/row wait on
  OI's late-return control; OI drafts sa_l/rt_l); MI writes
  ccv_miu.feedback.json at assembly; DI-38 (1) fill-unheld line (task 72,
  needs DI's spec); MI 29603c02 held-wait re-pin (task 80); OI-204 pc_kept
  at:11 lines (task 66); AR 417 (task 79); task 76 credit modules.

## Open work (priority order)
0. MI-12 order (Daniel via MI): all done (TI-506, 508, 509).
1. Task 55: OI-193/195's fix and decq_credit_lag knob (oi-sw 0fc3dc5a)
   land with OI's sweep merge. Then: lag 512 --cycles 200000 pass
   (mig_credit_wait>0) and mig-before-credits CHECK; due-epoch-lost; and check-kernel line for MI-11 (lnorm1 CCV_MIU_IMPL=model
   CCV_RAU_DEMOTE=mlc clean, parks>0, FET wait on). OA 462: binding dropped;
   once OI shows the released-slot CHECK catches it, --break
   mig-before-credits becomes the full-credit wait's control line.
2. Task 66 rest: once OI sets pc_kept in the OOE model, check-kernel
   at:11 lines for transp4 and narrowadd (pc_kept_launch>0),
   rau-pc-from-drained and OI's pc-kept-lost caught, a pc_kept_restore kernel.
   Task 69 rest: once DI sends the UE first answer and MI's 012519d8 is in,
   ue_second_answer>0 on ldpar CCV_DCU_UE_INJECT=1 for both MIUs and
   ue-close-first caught. Task 68: DI-33 (c) MLC stub probe injection per
   AR 409 (read it in full first). Then dcu-drop-credit / dcu-drop-answers
   controls once MI's drop sender lands.
3. Task 51 rest: MI-7 page-boundary kernel; MI-5 bins/slow regions.
4. AR 370 ccv_common_err RTL; task 28 RAS wrapper (BIST override, spare
   row/column, broadcast groups); AR 371 SPM banks; AR 392 PT base CSR
   with Q-50; AR 393; OI-187.
5. Low: RA re:RI-46 (3) SFU kill variant; RA 148 (post-sign-off).
