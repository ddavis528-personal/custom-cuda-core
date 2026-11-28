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
  OA-427 cm128priv DONE + full table SENT 13:33Z (B +0.420%, C 0, D=B, A0==A). OA-428 cm128priv E +1.118% SENT 13:46Z. Both DONE; worktrees rh-oi427/rh-oi427b dropped 13:47Z; logs ~/ccv-logs/oi427,oi428 REMOVED 11-19 22:15Z. OA-427 cm32priv all SENT (C=0, D=B). OA-428 cm32priv E +3.575% SENT.
- MA-4 DONE and SENT 11:40Z (27/27 clean; control == MA-3 exactly; a.q8 cm128 -4.69% best, a.q16 +0.33% vs q8; ldf neutral).
  Table ~/ccv-logs/ma4/table.md. rh-ma4 dropped after MA-5; logs kept.
  Parser fix 11:50Z: p1_q09_15/p1_q16up were missed (a.q16 'max 8' wrong; corrected to MA). ma2-5 table.py fixed.
- OI OA-448 (2) bar_pend: final at c2adfe83 DONE+SENT 12:31Z (P1=P2 S1 +0.083%, kernels same as 31bf; bar_pend ~2x). 31bf run (logs oi448b-31bf) SENT 12:28Z (P1=P2: S1 +0.067%, layernorm -6.1%, sgemm -1.2%, cta-reduce +0.12%; P0=D0). Was: from 12:20Z: rh-jobs/oi448/oi448b.sh, worktree rh-oi448b at c2adfe83 (OI corrections: 42e8ee74 -> 31bf4b1e -> c2adfe83); P0 default (must = D0),
  P1 bar_pend=1, P2 bar_pend=1,bar_buf_depth=2; same set. Table python3 rh-jobs/oi448/table_b.py (bar_pend/bar_port/bar_buf). ~12:45Z.
- OI bar_buf_depth pricing DONE+SENT 12:16Z (D2/D3 = D0 exactly, bar_buf 0; depth 1 control binds). Was: from 12:12Z: rh-jobs/oi448/oi448.sh (resumable), worktree rh-oi448 at 71feef7e; D0/D2/D3
  (bar_buf_depth 0/2/3); S1 + CP-62 kernels transpose-128, layernorm-128, cta-reduce-128, sgemm-128 as CTA 0 of 4 warps (cfgs built
  from launch.txt into build/cp62). Table: python3 rh-jobs/oi448/table.py. Threshold 0.5% on any of the 4 -> depth 3. ~12:45Z.
- OI OA-504: stub seeds 1-3 SENT 00:43Z 11-28 (nothing beats 50; gtw32 PCA hang at m35 3/3 seeds AND m100 on s2/s3). Fix (b) DONE: the hang survives 669cfdde
  (stub s1 m35, s2/s3 m100). Fix gtw32 grid DONE+SENT 00:55Z: ARM 50 HANGS at s4 and s5 (base 57ca7d30 too; pre-existing), m75 clean 3/3, m35 3/3 hang, m100 hangs s2/s3.
  OI raised OI-234 (RA/RI); m75 s4-10 not needed. KEEP the s4/s5 m50 gtw32 logs (base + fix) and the rh-oi504 kernels; repro in ~/ccv-logs/oi504stub/OI-234.repro
- OA-504: part (a) reported; OI released rh-oi504fix (removed). Keep ~/ccv-logs/oi504fix and oi504stub until OI sends the full rerun (after TI lands AR-431 RAU fix). Keep rh-oi504 + OI-234.repro for RA/RI.
  trigger 03:00Z. Disk: removed rh-oi504/build/bench-oracle (3G, regenerable) and trimmed the non-kept hang logs; s4/s5 m50 logs kept whole. FIX RUN (OI 22:23Z): rh-oi504fix = 57ca7d30 + 669cfdde (MA's OI-225 fix; local merge 6e034acc, never push), MA kernels copied.
  rh-jobs/oi504/prepfix.sh (prep) then chainfix.sh (after chains23): (a) oi504f.sh/oi504fr.sh model+p1 seed 1 all arms; (b) stub gtw32 m35. Logs ~/ccv-logs/oi504fix.
  Report one table (arm × class Δ vs 50) + req_id/credit CHECKs, 75/100 mismatches, hang lines.
- OI OA-504 MODEL+P1 MIX ABANDONED (OI 19:05Z: not clean; chk at every arm). Seed-1 model+p1 tables sent 19:05Z; logs kept in ~/ccv-logs/oi504 (aborted s2 in aborted-s2/).
  Cycle-stamped CHECK head sent to OI for MI/DI: ~/ccv-logs/oi504/rh-cyc.s1.m50.coremark32priv.head (build/skel-rh in rh-oi504 is an experiment binary; source reverted).
  NOW: STUB-MIU mix (CCV_MIU_IMPL unset, DCU p1), logs ~/ccv-logs/oi504stub. Step 1 gate50.sh CLEAN 19:21Z (73/73, 0 chk; sent). Step 2 seed 1 DONE+SENT 21:10Z (all clean except gtw32 m35 HANG: 'rau: warp 30 drained, PCA has no free place', the same in model+p1, so it is the arm, not the mix).
  Seeds 2+3 RUNNING all arms from 21:10Z (chains23.sh, ~4h); then send the seeds-1-3 table. Was: oi504s.sh 1 + oi504sr.sh 1 for all arms; then seeds 2 and 3 only for arms within 0.5% of 50.
  Table: table.py <seed> ~/ccv-logs/oi504stub. Watcher bg4vy9t7j ('[c]hains23.sh'); trigger trig_01XKmiGkDDgf8LZDaC4zaxWG 23:20Z. Originally started 17:07Z 11-27: THRESHOLD_MLC re-sweep at 57ca7d30 (origin/ccr-57eff422-5tdecg) in rh-oi504, rh-jobs/oi504/oi504.sh <seed> [arms]
  (resumable), logs ~/ccv-logs/oi504 (s<seed>.m<arm>.*). Common env: CCV_RAU_DEMOTE=mlc CCV_MIU_IMPL=model CCV_DCU_IMPL=p1. Arms: demote_mlc_miss=35/50/75/100.
  Class 2: vadd6 at CCV_TB_LATENCY=1000 --cycles 400000. Class 3: S1, cm32p, cm128p at default. Seed 1 first; arms within 0.5% of 50 get seeds 2 and 3.
  Class 1 (read): MA sent gtr4 and gtw8/16/32 (17:10Z; uncommitted in rh-oi504/test/kernels, oracles in build/syn-oracle); rh-jobs/oi504/oi504r.sh <seed> [arms].
  B/cycle = demanded load lines (256/512/1024/2048) x 128 / KERNEL cycles (MA's definition); also report p1_mshr_peak and sum/cycles. Env = OI's (not MA-31's
  P1_STORE=af/STRICT/jitter 0/size knobs), so cycles won't match MA-31 c128. MA (17:11Z): p1 holds up to 128 fills (IdPool by dcu_mlc req_id width 7); dcu_core.h:141 is the DCU model's. A low p1_mshr_peak means MIU binds (ids or memops 8). MIU model + p1 is a mix MA-31 never measured (stub MIU): LABEL it. Watcher '[o]i504.sh' does not match oi504r.sh.
  Per run: cycles, Δ vs 50, fin/order/chk, demote_trigger.mlc_miss.true_miss/false_hit/unresolved, demote, restored, parked, slot_refill_parked.
  The decision is OI's and OA's.
- AR 410/412 re-baseline DONE+SENT 17:20Z 11-24 (rh-jobs/ar410, ~/ccv-logs/ar410, <tag>.<k>.cmd). All 49 runs exact. S1 (1,640) and cm32priv
  (1,177,935) are bit-identical OLD vs NEW at every seed: with warm MLC they never pay DRAM, so the 0.2% S1 bar can't be tested this way (offered a
  cold-MLC rerun). cm128priv: OLD 1,977,489; NEW s1/s2/s3 +0.050/+0.141/+0.135%; jitter 0 +0.061%; seed spread 0.091%.
  AR booked it (perf-register eb1c3851, AR 418) and released it 17:18Z; worktrees DROPPED. No cold-MLC run needed. Logs REMOVED (cleanup fired 11-25 17:20Z, run 11-27 02:42Z).
- OI OA-466 DONE+SENT 03:16Z 11-22 at a5d5cb83 (rh-oi466, rh-jobs/oi466, ~/ccv-logs/oi466), mlc, B = beat_merge=0,demote_walk=1. All clean (0 chk):
  S1(66) +0.072%, cm32p +0.149%, cm128p -0.038% (B 2,993,073: no CHECK, no hang). Walk mean/max: 14.96/34, 36.53/40, 26.87/40. OI landed the flip as c69ee1a3
  (13:41Z 11-22) and released it: rh-oi466 and rh-oi451 DROPPED 13:42Z. Logs oi451/451b/455/455b/455c/466 REMOVED 13:45Z 11-23.
- OI OA-455 11-20, WAITING on OI's next commit. Round 2 at 33b2971c SENT 07:46Z: Bm chk 1 (AR 395); Ck and Dn chk 0 but can't fail.
  Round 3 at 05ee3bdb (rh-oi455c, ~/ccv-logs/oi455c): built OK; Bm ran 49 min with no exit, STOPPED by RH ~08:34Z (OI: likely a hang, FET
  waits on a credit OOE holds in cred_pend_); Cw dropped. OI will send a new commit with a run list. Keep rh-oi455c, rh-oi455 and rh-oi451
  (oracle symlink source) until then. Fetch with plain git fetch origin gate-scratch/OI.
- OI OA-451 rounds 2-3 DONE+SENT by 04:55Z 11-20 at 367bc942 (oi451b.sh, oi451c.sh, table_b.py; logs ~/ccv-logs/oi451b).
  S1-mlc +0.066% clean; cm32priv-mlc Bm +0.147% clean (168 demotes); cm128priv all 4 runs have check failures (TI-46 (b) decq share,
  fet tier-1 credit share) from cycle ~238k after the 123rd demote bounce. S1 under fallback=150: atom mem_mismatch 31 (Af and Bf).
  OI owns the root cause; no cm128priv rerun until OI sends a fix commit. rh-oi451 is DIRTY by design: an uncommitted fail()-cycle
  patch in sim/skel/kernel.cpp, built to build/skel-rh. NEVER commit it. Probe logs in oi451b/probe (t.bin trace, window.sorted;
  rh70.full = #70 window prints, which confirmed OI's hypothesis: 3 late epoch-6 uops were dropped after the reseed, so credits peaked at 7+3; OI raised it as OI-188 for OA/TI; no 240,200 run needed; cm128 walk price waits on the fix commit). Patch also prints RH lines in 237140..238125.
- OI OA-449 DONE+SENT 22:52Z: why layernorm/sgemm gain under bar_pend: P0/P1 at c2adfe83 in rh-oi449 (rh-jobs/oi449/oi449.sh, diff.py ->
  ~/ccv-logs/oi449/diff.md). Same barriers/retired; layernorm rename.one_warp_short -234 (= -232 cyc), decq_full -480, credit_wait -614;
  sgemm hold.registered.barrier -244. No per-warp split in stats. rh-oi449 released and dropped 23:14Z (written up as OI-185); logs ~/ccv-logs/oi449 to drop 11-20 22:30Z.
- OI OA-447 (re:OI-179 (3)) RUNNING from 11:59Z: rh-jobs/oi447/oi447.sh (resumable), A=99ee28168b (rh-oi447a), B=582fedae14 (rh-oi447),
  C=582f + redirect_send_lag=2; oracles shared (symlinked). S1 + cm32priv + cm128priv (cm128 lock). Table: python3 rh-jobs/oi427/table.py
  A A=~/ccv-logs/oi447 B=... C=... --ctr=redirect.send_lagged; report Δ B vs A and C vs B (C vs B 0.5% S1). S1+cm32priv SENT 12:46Z: B=A exactly; C vs B S1 +1.420% (-> DA), cm32p +3.721%. cm128priv DONE+SENT 13:31Z: B=A, C +0.899%. OI 22:41Z: + D = redirect_send_lag=1 DONE+SENT 23:12Z: S1 +0.720%, cm32p +1.903%, cm128p +0.527% vs B (half of C; still > 0.5% -> DA). OI 22:19Z: rh-oi443/oi448/oi448b dropped; KEEP rh-oi447 + rh-oi447a until DA rules on redirect_send_lag. Logs oi443/oi448/oi448b/oi448b-31bf/oi449 REMOVED 22:30Z 11-20 (cleanup trigger); oi447 kept until DA rules.
  Container restart ~11:58Z 11-19 (nothing was running).
- OI OA-443 (re:OI-176) from 09:28Z: rh-jobs/oi443/oi443.sh (resumable), worktree rh-oi443 at 14526054 (gate-scratch/OI),
  A slot_verdict_lag=0, B defaults (1). S1 + cm32priv + cm128priv (cm128 lock after AR). Table: python3 rh-jobs/oi427/table.py A
  A=~/ccv-logs/oi443 B=~/ccv-logs/oi443 --ctr=demote,kill,demote.refused. DONE+SENT 10:35Z: B == A cycle-identical on all
  (+0.000%); but demote=0/restored=0 on cm128priv (triggers fire 4,520) -> demote path unpriced, flagged. Keep rh-oi443 until OI releases.
- AR 386 DONE+SENT 09:47Z: (a) wp0 and (b) wp5 recent both 5,634,717 (wp_wrong 0); (a) equals AR's earlier hit-7 figure exactly
  (flagged; offered a hit-7 rerun). Worktree dropped; logs ~/ccv-logs/ar386.
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
