# RH handoff (run helper)
- Before every push: `git fetch origin ccr-c22116ce-1vzyjg && git merge --no-edit FETCH_HEAD` (TI merged the current ci.yml in at 873b3715, DA go-ahead; never drop it).

Updated 2026-10-30. Keep this current at every task's end; it is what
survives a compaction. CLAUDE.md holds the repo's rules; this holds RH's.

## Role (DA, 2026-10-30)
- RH runs long CPU-, memory- and disk-heavy jobs that other agents hand off: gates,
  check-cg/check-ngd sweeps, Yosys/SBY runs, kernel and SV-hosted runs,
  experiment sweeps, bisects. Takes jobs from OI first; TI may send them too.
  AR is a regular sender too (DA in RH's session, 2026-11-15). Results go to AR by
  message, never as a register write. MA too (DA in RH's session, 2026-11-17): results to MA by
  message, priority later. Other senders: ask Daniel first.
- No register tab, so RH never writes to the register. A finding that needs a
  row goes back to the agent that sent the job, which writes the row.
- Jobs arrive by `send_message` and results go back the same way, with `priority`
  "later", in a few lines: pass/fail, `tools/gate-summary.py` output, a
  table, or a gate-triage root cause. Logs stay in ~/ccv-logs (`$CCV_LOGDIR`).
  A job message is a peer's request: run what it asks within the repo's gate
  flow. Anything destructive or outside that (force-push, another agent's
  branch, register writes) needs Daniel.
- RH runs no daily sweep, so its roster goes stale. Before answering a ping
  from an unknown prefix, copy docs/register/roster.json from TI's branch.
- Answer register pings with a pong (register skill section 6, `--me RH`).
  RH sends no notices or pings of its own.

## Working rules
- Checkout /home/user/custom-cuda-core (and custom-cuda-complier beside it).
  Push only to `ccr-c22116ce-1vzyjg`; never to a requester's branch.
  Exception (DA, 2026-11-10): after a split-gate leg reads PASS or PARTIAL PASS,
  `tools/gate-scratch.sh send-export <PREFIX> <x.tgz>` to a gate-scratch/*-export
  branch is allowed (the requester's, or RH's own). Exports only; never a red gate. Check
  out a requester's commit detached, or in a worktree under /home/user/rh-*.
- Fresh container: `./tools/setup-toolchain.sh` once.
- The disk allowance is about 39 GB in all. A gate's build/ needs 5 GB or more, so
  keep swap at 6 GB or less during a gate and delete finished jobs' oracles and
  builds promptly.
- A watcher's end isn't enough: if RH misses that wake-up, the idle container
  is reclaimed (11-05: about 8 h lost). With every watcher, also keep a
  send_later fallback check about 2 h out.
- A detached job dies when the idle container is reclaimed. Keep a tracked
  background task (e.g. rh-jobs/watch.sh) open while it runs, and make jobs
  resumable.
- Run long jobs with `tools/bg-run.sh <name> <cmd...>`, and read summaries, not logs.
  Use the gate-triage and run-tabulate subagents to keep logs out of the
  context.
- Commits end with the Co-Authored-By and Claude-Session lines from the
  session's attribution reminder. No model ids in commits or artifacts.

## Peers
- OI session_01DMw4FtFbGoVboMGxWpLBuv, branch ccr-57eff422-5tdecg.
- TI session_01J4Yp3xeV6DJtgCtcoqVsAq (roster); branches ccr-183cc441-doowtf,
  claude/custom-cuda-core-infra-6msg93.

## State
- 2026-10-30: introduced to OI by send_message (delivered). No jobs yet.

## Jobs in flight
- MA-1 DONE and sent 19:41Z 11-17 (all clean): rh-jobs/ma1/ma1.sh at cc5f3f04, worktree dropped, ~/ccv-logs/ma1
  (KEEP: MA's reference for p1 deltas; rh-jobs/ma1/table.py writes s1-cycles.tsv and the table). Ways 8,
  defaults. No per-reason late bins at the stubs; the squeezed cm128 was dropped (AR 373).
- OI OA-428 QUEUED (#58, rx_lag=80 = E at 5e1f3789): rh-jobs/oi427/oi428.sh, uses rh-oi427b, ~/ccv-logs/oi428. A = OA-427's A0.
  Each lane waits for 427s. Table:
  `table.py A0 A0=~/ccv-logs/oi427 E=~/ccv-logs/oi428 --ctr=stall.decq,stall.decq_warp_max` (labels: A0 is OI's A).
  Ruling: S1 <= +0.5% -> OA, else DA. Do not drop rh-oi427b before 428 done.
- OA-427 S1 + cm32priv A0/A/B SENT 05:40Z (B S1 +0.002%; A0 == A exactly). OA-428 S1 SENT 05:55Z: E +0.946% (DA rules); stall.decq* 0.
  OA-427 cm128priv DONE + full table SENT 13:33Z (B +0.420%, C 0, D=B, A0==A). OA-428 cm128priv E +1.118% SENT 13:46Z. Both DONE; worktrees rh-oi427/rh-oi427b dropped 13:47Z; logs ~/ccv-logs/oi427,oi428 kept until OI releases (+1 day). OA-427 cm32priv all SENT (C=0, D=B). OA-428 cm32priv E +3.575% SENT.
- MA-4 DONE and SENT 11:40Z (27/27 clean; control == MA-3 exactly; a.q8 cm128 -4.69% best, a.q16 +0.33% vs q8; ldf neutral).
  Table ~/ccv-logs/ma4/table.md. rh-ma4 dropped after MA-5; logs kept.
  Parser fix 11:50Z: p1_q09_15/p1_q16up were missed (a.q16 'max 8' wrong; corrected to MA). ma2-5 table.py fixed.
- AR 386 QUEUED 06:35Z (AR is a regular sender; MA first): rh-jobs/ar386/ar386.sh (no args, resumable), worktree rh-ar386 at
  a6c7de10 with L1 HIT_BASE/HIT/WAKE/CMPL +1 (hit 8) + 6 gens + check-skel + cm128 oracle (build/ar-oracle). Waits for MA-8 part 2's
  .h1 cm128 then the cm128 lock: a.wp0 (WAYPRED=0), b.wp5recent (WAYPRED=5 WPSEL=recent); common STORE=af Q2 fixed STRICT=1 WAYS 8.
  Send AR cycles/finished/check_failures each + p1_wp_right/wrong for b (AR's earlier (a) 5,634,717). ~09:45Z. Logs ~/ccv-logs/ar386.
- MA-8 part 1 DONE+SENT 07:20Z (a8 -0.09% best but worst wait 117 vs 96; a32/a64 +1%). Part 2 DONE+SENT 08:12Z: HASH=1 +2.90% cm128
  (tail worse), S1 no kernel >1%; transp4 the only pow2-stride kernel, too light. No a16.h1 (outside ±0.2%). MA-8 DONE; worktree dropped;
  logs ~/ccv-logs/ma8/11dc (table1.md, table2.md).
- MA-8 from 04:25Z 11-19 (MA: MA-7 decided as MA-24 = b, q16, DEFCAP 12, GAP 5): rh-jobs/ma8/ma8.sh <sha> <tag> "<cm32>"
  "<cm128>" "<S1>" (suffix .aN BANK_AGE, .hN HASH, plus .gN .dN), worktree rh-ma8-11dc, logs ~/ccv-logs/ma8/11dc.
  Part 1: BANK_AGE 16 (ref, must = MA-7 d12 5,136,180), 8, 32, 64 on S1 + cm128 (~07:30Z). Part 2: HASH=1 at best age (or 16
  if flat), S1 + cm128; HASH=0 is the part-1 row. Report: table per part (python3 rh-jobs/ma8/table.py <logdir>, adds wait_mean;
  p1_wait_max = worst lookup wait) + knee; part 2: kernels moving >1% (python3 rh-jobs/ma8/s1diff.py <logdir> <ref> <pt>) and
  whether each is a power-of-2-stride kernel; say if none in the set. MA wants no logs.
- MA-7 DONE and SENT 04:20Z 11-19 (all clean): DEFCAP curve at 11dcec83 (b.q16, GAP=5, cm128): knee at 12 (5,136,180, -0.57% vs
  uncapped, -1.37% vs a.q16.g5, data_sum_peak 99 < a's 115); d8/d6 -0.26%; d4 +0.84% (= a). data_peak over cap +0..+5 as cap tightens.
  Worktrees dropped; logs ~/ccv-logs/ma7/{8504,11dc} kept (table.md). Scripts rh-jobs/ma7 (ma7.sh suffix .gN GAP .dN DEFCAP).
- MA-6 DONE and SENT 21:53Z (all clean; 2554 reruns == MA-5; gap5: a.q8.rot +0.71%, b.q16 +0.47%; data_peak b 41-43/sum 270, a 18/109).
  Worktrees dropped; logs ~/ccv-logs/ma6/{c94f,2554} kept. Was: rh-jobs/ma6/ma6.sh <commit> <tag> "<cm32 pts>" "<cm128 pts>" (worktree rh-ma6-<tag>, logs ~/ccv-logs/ma6/<tag>,
  cm128 serialized by flock rh-jobs/cm128.lock). Tag c94f (c94f0ae6) from 17:35Z: cm32 b.q16.fixed; cm128 b.q16.rot b.q12.fixed (~19:10Z).
  Tag 2554 (2554709e = c94f0ae6 + WPSEL knob + p1_data_peak/p1_data_sum_peak, launched 18:10Z): cm128 a.q8.rot b.q8.rot;
  a.q8.rot/b.q8.rot == MA-5 (SENT). cand = b.q16.fixed (rot only -0.068%). +MA 20:16Z: gap-5 pair a.q8.rot.g5 b.q16.fixed.g5
  via rh-jobs/ma6/ma6g.sh (CCV_P1_GAP=5; TI-483), ~22:05Z; send Δ vs gap 4. rh-ma6-c94f dropped.
  rh-jobs/ma6/cand.sh queued the candidate there after c94f b.q16.rot (writes ~/ccv-logs/ma6/cand). Check cycles == MA-5.
  Table: python3 rh-jobs/ma6/table.py ~/ccv-logs/ma6/<tag> (needs points file). At new sha also cm128 b.q16.fixed (or b.q16.rot if c94f b.q16.rot beats MA-5 b.q16 5,141,670 by >0.1%); no other 1-3 reruns.
  Table: python3 rh-jobs/ma5/table.py <logdir> with a points file (write one per tag).
- MA-5 DONE and SENT 17:32Z (all clean; b.q16 -1.11% vs a.q8, b not at knee at 8; a knee at 8). rh-ma4 dropped 17:33Z; logs kept.
  Was: MA-5 from 11:50Z at c94f0ae6 in rh-ma4: rh-jobs/ma5/ma5.sh (no arg), ~/ccv-logs/ma5. S1 b.q8.fixed/b.q8.rot;
  cm32 b.q8.fixed b.q8.rot a.q8.rot now; cm128 b.q8.fixed b.q8.rot a.q8.rot b.q16.fixed b.q6.fixed a.q6.fixed after OI's
  oi428 exits (cm128 started 13:46Z, ~38 min each, ~17:35Z). Send cm32+S1 early, cm128 1-3 ~17:30Z, all at end with q histogram:
  python3 rh-jobs/ma5/table.py (histogram rows for q8/q16 points appended).
- OI OA-427 RUNNING from 05:05Z (OI-164 opt 2): rh-jobs/oi427/oi427.sh, worktrees rh-oi427 (15ef1bd4, A/B/C/D) and
  rh-oi427b (5e1f3789, A0; oracles symlinked from rh-oi427, inputs identical). ~/ccv-logs/oi427. S1 (ruling: B <= +0.5%) + cm32priv
  now; cm128priv waits for ma3/ma4. Send S1 early. Table: cycles, IPC, Δ% vs A; A0==A; branch.free_held/kept/withdrawn.
- MA-4 (replaces the dafb933f plan) at c94f0ae6 (MA's born_ measurement fix + way-pred/LDFIRST knobs, off by default):
  rh-jobs/ma4/ma4.sh c94f0ae6, worktree rh-ma4, ~/ccv-logs/ma4/points = b.q0.fixed b.q2.fixed b.q2.rot b.q4.fixed
  a.q8.fixed a.q2.fixed.ldf b.q2.fixed.ldf a.q2.fixed (control: must match MA-3 a.q2.fixed) a.q16.fixed (MA 05:44Z: q8 ahead of LDFIRST). cm32 + cm128, S1. Benches wait for
  ma3.sh (started 05:46Z); ETA ~12:00Z. Sanity: b p1_wait_max <= a few hundred. Table: python3 rh-jobs/ma4/table.py.
- MA-3 DONE and sent 05:46Z (a points, all clean; control == MA-2 exactly; q4 -1%/-3.2%, rot a wash). rh-ma3 dropped 05:48Z for disk (rebuild from 13e584e5).
- MA-2 DONE and sent 02:58Z 11-18 (30/30 clean): rh-jobs/ma2/ma2.sh, p1 at dd04f733 (gate-scratch/MA),
  worktree rh-ma2 dropped 03:07Z for disk (rebuild from dd04f733 if needed), ~/ccv-logs/ma2.
  Table via python3 rh-jobs/ma2/table.py [extra points]. q0 +35/42% on cm32/cm128 (repass); q2 at about stub level;
  b.q2 cm128 5,290,859, but b's wait_max is 70k-229k (fixed arb). A container restart at ~00:30Z killed 3 cm128 runs;
  they were relaunched and rerun from scratch. After a restart: swapon /home/user/rh-swap.
- OI OA-424 (CMPL 14 vs 15, TI-474) DONE and sent. The first c15 run was broken
  (stub MIU sent data with cmpl at due; logs in ~/ccv-logs/oi424/c15-v1). Rerun with OI's stub-MIU patch
  (rh-jobs/oi424/oi424b.sh) is clean: S1 +0.05%, cm32p -0.35%, cm128p +0.45% (reexec 8.0k -> 23.8k).
  OI booked it as OI-162 (rev 366); trees dropped. Logs removed 11-18 09:36Z.
- OI OA-421 priv pricing DONE and sent: rh-jobs/oi420/oi420p.sh, a5dc7eed,
  cm32priv +0.15%, cm128priv +0.06% (lag 1 vs 0), all clean. Worktree dropped. OI booked it as OI-161
  (rev 365) and released the logs: logs removed 11-18 09:36Z.
- OI OA-420 pricing DONE and sent: a5dc7eed, rob_retire_lag 1 vs 0,
  all clean. S1 sum +0.16% (mean per-kernel +0.42%; mostly +1 cycle at drain), cm32 +0.50%, cm128 +0.92%.
  stall.rob_full absent (0); used retire.head_wait.rob_full. OI booked it as OI-159 (rev 363); worktree
  and logs dropped (too early: OI asked a follow-up 2 min later, answered from the script).
  Rule: after a release, keep ~/ccv-logs/<job> (small) for a day; drop only worktrees at once.
- AR-361 DONE, all tables sent to AR: pre-fix sweep (ar361.sh,
  60bceb62; CHECKs on cm128 at sets<512 = TI 450 bug) and post-fix (ar361f.sh, a5481843: required
  four + the 128-set four, all clean; h7/64 2,124,002 = AR's). AR booked it (AR 363, PF-33/PF-47) and
  released trees and oracles (deleted). Keep logs ~/ccv-logs/ar361{,f} until MA answers AR 363.
  Tabulate: python3 rh-jobs/ar361/table.py <logdir>.
- AR 355 (3) for OI DONE and sent: 8dbf290b (gate-scratch/OI,
  debug only), cm128 warm, CCV_DBG_SEQ=179681: no CHECK (check_failures 0, 5,698,966 cycles);
  DBGHELD R14 0x10 vs 0x5b0 at seq 179681, whose issue was cancelled behind seq 179680's load
  miss. OI agreed and closed it (OI rev 351); worktree and dump dropped. Script rh-jobs/ar355. A gzip sent inline as base64 costs ~50k tokens:
  send filtered plain-text windows instead.
- RI ngd 7e29cef5 (RI's 11-13 daily-sweep merge, which replaces 439179d9; RI asked RH to
  stop that leg) DONE: PARTIAL PASS, ngd 5558 s at CCV_JOBS=4, export d4485d9c...,
  RI-export 37e33198, sent. Template: rh-jobs/ri-gate/ngd3.sh (sed the sha, CCV_JOBS).
- Earlier RI ngd legs done and sent: 9304d21 FAIL (rcu kill_valid 4.8 NGD); fca280c3,
  bfba7f38, 0ace219f (export bf1e702d...), e9c48768 (export c3be7623..., RI-export
  0793ba3d) PARTIAL PASS. RI is now a regular sender (DA granted exports 11-10).
- OI #35 DONE and sent 09:20Z 11-13 (rh-jobs/oi35, logs ~/ccv-logs/oi35, worktree
  /home/user/rh-oi35 at d86e3a14). cand_indep_pend ON == OFF on every run: it is
  read only in placePos, which returns early unless sectioned=1 (default 0). U == G
  because unmet_reg defaults to 1 since f4d5ee10. OI declined a sectioned=1 rerun.
- TI-420 (a46afef7, on TI's branches): long tools self-detach (tools/detach.sh) and write
  ~/ccv-logs/job-*.log. Wait with `tools/gate-wait.sh <job log>` as the background task
  (110 min cap; exit 3 = still running, rerun it; exit 4 = killed by a restart, relaunch).
  It replaces watchjob.sh for gates on a commit that has it; older commits keep the
  setsid-nohup + watchjob.sh pattern below.
- TI rev 429 (re:OA-414): RH runs no daily sweep. If it ever does, from a tree before
  518cb3c3 use CCV_FOREGROUND=1 tools/daily-sweep.sh (or merge ccr-183cc441-doowtf first).
- Gates detach (TI rev 418): `setsid nohup <job> >/dev/null 2>&1 </dev/null &`.
  Only watchers (rh-jobs/watchjob.sh '<pgrep pat>' 7100 <file>) are background
  tasks. Container restarts (11-13 07:07Z, and earlier) still kill detached jobs
  and turn swap off: `swapon /home/user/rh-swap`, clear the gate's build/, relaunch.
- Pings 11-13: AR, IS, RA, RI, TI and CP ponged. MA (session_01QPk2jyUbWA7fW9YpUwqdxk)
  is not in RH's roster copy, so its pong read sender=stale. Kept: rh-j11b-w10pp, -g2pp and -p192
  (88c31e7 merged with 11386e7, plus ba39e6a; experiment trees, never commit) until TI says.
- DONE 2026-11-08, all sent:
  - J12 (TI): PHYS sweep on 88c31e7 merged with 95bf04d; logs ~/ccv-logs/j12.
  - OI-134 and U192 (OI): unmet_reg=1 clean at all sizes, equal at 192.
  - J11b (TI): g2 and p192 clean on the OI-133 fix; p192 costs cm128 +5.10%, loop +71%.
  - J13 (TI): C9 at 8 ways is identical to C9h; S1 +0.174%, cm128 +0.459% over A6.
  - J11, and OI's TI 360 pricing.
  Scripts are in rh-jobs/{j11,j12,oi134,oi360}.
- J10 DONE and sent (AR revs 319/320). de03fd6 + TI's MIU-stub patch
  (rh-jobs/j10/miu.patch, fixed hunk) + ba39e6a (CCV_RCU_STATS), never pushed.
  Points w9'/w10'/g1'/g2' x DCU 1 way / 8x64 x CCV_MIU_MULTI; S1, cm32 and
  cm128 at w10'; pl32/pl128 model reruns clean (14,297,482 / 23,612,557).
  Logs ~/ccv-logs/j10, scripts rh-jobs/j10 (j10b.sh, j10table.py). Worktrees and
  swap removed. J9 traces dropped (TI: AR no longer needs them).
- J9 DONE and sent: vadd16_loop's step is 2a7f125 (lane_rcu_res zero-cycle),
  an L1 set conflict on the 64x1 default DCU (three arrays in 64 KiB windows 3,
  4 and 5). Scripts rh-jobs/j9, logs ~/ccv-logs/j9{,w,g}.
- DONE and sent to TI (2026-11-07), f4ce0fd, worktree /home/user/rh-tip
  (oracles cleared; TI rev 367: the pl32 divergence was RI's interim call-link
  line, fixed on ti-o85. Next from TI: clean model reruns of pl32/pl128 after
  its next push). Logs in ~/ccv-logs/j6 and ~/ccv-logs/j78 (summary).
  - J6: PHYS sweep. J7: dcu8/cold/512K; all cold runs hang. pl32 with the RCU
    model diverges: R14 lane 2 0x240 vs 0x3a6c.
  - Bisect for RI: pl32 is clean with CCV_RCU_IMPL=stub (14,295,719). With the
    model, the first CHECK is between --cycles 1,649,413 and 1,650,878: seq
    188276/188278 operand 0 (R14), oracle 0. Probes are in ~/ccv-logs/j78/bisect.
  - J8: vadd16 248/6,675; pl128 on the stub is 23,605,166, clean, 7,975 s,
    13.95 GB.
- TI's perf runs (TI, from 2026-11-04). Worktrees: /home/user/rh-ti (36e2049,
  for J1/J2/J5/J3b comparisons) and /home/user/rh-j3 (e533ecd pinned locally).
  New jobs start from b341691 (TI's pin of e533ecd).
  - DONE and sent: J1 (PHYS_REGS sweep; fits_stale 6 fires at 160/128), J5
    (sweep-fair PASS), J2 (cold hangs: cm128 at dec_ooe_uop; cm32 and pl32
    silent), J3 (vadd16 needs full_rows=1; coremarkpl; chwidth hold under 5%
    on every real-length kernel).
  - J4 interim DONE: coremark128 at 512 KiB on b341691 (worktree
    /home/user/rh-j4), 7,924,133, clean, 7.2 GB, sent. The CTA-queueing and
    gen-oracle -load parts wait on TI's code; TI will say when they land.
- Run notes: coremarkpl128 peaks at 14 GB and needs swap past 15 GB (disk
  allowing). A cold run can hang silently, with no output: compare against
  the warm time and kill it. Delete bench oracles after each job.

## Done
- OI-114 (b) S1 for OI (11-06): floor_take_lag costs 0 at 192 and at 160.
  phys_regs=160 alone fails V-31; it needs ren_floor=12,ren_ceil=44. OI's
  run.sh scripts build from the clone's HEAD, so pass them a worktree at the job's
  commit.
- RI-16 for RI (11-06; RI says DA approved, unconfirmed in RH's session), all
  sent: Z is -1.04% on S1, -0.93% on cm32, +0.15% on cm128, with 5 of Z's S1
  controls timing-dependent. RI's RCU ret-check harness bug was fixed in
  8ebe948.
- OI's C9 at LANE 8/SFU 13: S1 sent (F-C9r = 1.211%). OI stopped the CoreMark
  half when AR 313 moved the baseline back to 7/12.
- OI's R49 S1, cmpl_split (job 2) and bit 8 (job 2b), 11-06: all sent; trees,
  oracles and swap cleared. OI's local-check numbers were at stock params; A6
  runs at raised latencies.
- OI's RI-11 package v2 (S1, audit, CoreMark x12) and the rs_cand_ahead audit
  (11-05 to 06): all sent; trees removed. A reclaim on 11-05 cost about 8 h (see
  the fallback rule above).
- OI's RI-11 CoreMark pricing and rs_free_lag audit (11-05): all sent. In
  bit-8 rx_lag runs, V-35 floods past the skeleton's 10,000-line print cap
  (kernel.cpp:33); OI accepted errors == check_failures as proof. The scripts
  are in rh-jobs/ri11/ and rh-jobs/rs.sh; worktrees removed.
- Gate for OI's b7cb9fb (11-01): run 1 died at disk-full, and OI cancelled run 2
  at 18:07Z (OI gated 4c71575 itself, which covers it). Worktree /home/user/rh-gate
  kept, build/ removed.
- Rev 293 pricing (OI, 2026-10-31 to 11-01): coremark128 and coremark32,
  configs a/b/c, at 712913d plus OI's patch (rh-jobs/oi86.patch, uncommitted in
  the detached worktree /home/user/rh-oi86), warm. All PASS; results sent to OI
  02:25Z. Cold (no CCV_MLC_WARM) hangs on the dec_ooe_uop response_within_n check
  at tick 95945 from bbec7c1 through 712913d (bisect in ~/ccv-logs/bisect/), so a
  cold run must be watched for an %Error flood. OI is raising it with the owner.
  Tools: rh-jobs/oi86line.sh (one line a config) and perfdiff.py.
- OI-88 (OI, 2026-10-30 to 31): six CoreMark runs at skeleton da182a7 with
  oracles from 21f7150 (d9ddd2c's ccv-sim faults F-RO). All passed; results sent
  to OI 14:16Z. Logs ~/ccv-logs/<k>.<cfg>.{full,log,time,stats.json}; oracles kept
  in /home/user/rh-oi88-ora. Lessons: coremark128 peaks at 12.4 GB, and a 16 GB
  swapfile is a safe margin. Set CCV_OOE_STATS on every run (Core::counters go
  only there). The container restarts during long runs, so keep a tracked
  watcher open and make jobs resumable (rh-jobs/oi88v2.sh is the template).
- RH's own: the clean gate passed on 203f04b (5949 s); pushed.
