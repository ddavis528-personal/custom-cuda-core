# AR handoff (top-level architect)

Updated 2026-11-27 (trimmed from 65 KB; the full history before the trim is
`git show 60bceb62:.claude/handoff/AR.md`, and the register is the record).
Keep this current at every task's end. CLAUDE.md holds the repo's rules; this
file holds AR's.

## Who and what
- AR is Daniel's (DA's) top-level architect, in Daniel's own session
  (session_01FnGhxke3r33MeArLeQJRcD). Daniel is a senior microprocessor
  design engineer; answer him as one.
- AR owns:
  - the architecture docs and the partition spec;
  - the per-block specs for blocks without a session (RAU, PCA, FET, LANE,
    DEC, SYU, SPM; MIU and DCU are MA's since DA 118), and MLC's (and the
    MLC/EXB params) until Daniel creates an MLC agent (DA row .135300,
    2026-11-23);
  - the AR register tab and docs/perf-register.md (PF-30 on);
  - Q-42 (full abutment);
  - reading traces.
- AR writes no code. It writes only its own tab, plus DA rows that quote
  Daniel's own words, said in this session ("Recorded by AR in Daniel's
  session"). Interface changes go to TI as rows; AR writes the spec text.
- Rows record what lost, check the arithmetic and name what is missing.
  Decisions are Daniel's. Daniel's bar (DA 114/115):
  - up to 0.2% on S1, it stays;
  - 0.2 to 0.5% goes to Daniel;
  - over 0.5%, the owning architect may approve.
- No FP outside LANE. No broadcast channels. The owner wins a crossing:
  read the owner's latest row before re-ruling.
- Loop guard: never answer a notice only to acknowledge it.

## Repos, branches, push
- Core: /home/user/custom-cuda-core, branch `ccr-80102643-4n8bv4` only.
  The compiler checkout is /home/user/custom-cuda-complier (read only).
- No PRs. No model ids in commits or artifacts. Commits end with the
  Co-Authored-By and Claude-Session lines.
- Code merges:
  - run tools/regen.sh, then tools/verify.sh;
  - push only on PASS;
  - merge commits only: never rebase or force-push;
  - don't commit while a gate runs.
- Doc-only commits: run ./tools/check-docs.sh and check rc 0.
- Never use tools/daily-sweep.sh or make-release.sh --push.
- verify.sh detaches and exits 5. Wait with `tools/gate-wait.sh <log>` as a
  background task, timeout 7200000.
  - exit 3: still running, run gate-wait again at once;
  - exit 4 (killed) or a container restart: `CCV_RESUME=1 ./tools/verify.sh`
    (IS-27); it carries over the sections passed on the same commit and tree.
    RESUMED PASS counts as the full clean gate (DA via TI-490).
- A full gate takes about 4 h (ngd and cg about 3.7 h each in parallel).
  If one dies, split it: `verify.sh --only cg`, then `gate-export.sh`, then
  `gate-push.sh --full --branches=<ours> --import=<tgz>`.
- Never work around a permission refusal, the rm safety check included:
  use literal paths or `"${S:?}"`.
- A stop hook about unpushed commits gets a short answer: holding until the
  gate passes.

## Daily sweep (scheduled task trig_01V1WipqEXd8e7TAaWnKvQGu, 10:03Z)
1. Read the register from the bookmarks, through `register-reader`.
2. Answer rows with AR in Needs.
3. Fetch, then merge every remote branch with commits ours lacks, except
   `release` and `gate-scratch/*`, with the scratchpad's fast-merge.sh
   (`<scratchpad>/fast-merge.sh <branches...>`; if the scratchpad was
   cleared, rebuild it from AR 425's four steps). It merges on the newest single merge base (git merge-tree
   --merge-base), settles a conflicted file only where one side's history
   holds the other side's exact blob, else stops; `KEEP_OURS="<file>"` keeps
   ours by hand for a file you checked. It signs with commit-tree -S (without
   -S GitHub shows the merge Unverified). Proposed to TI for tools/ (AR 425).
   TI-605: tools/sweep-merge.sh (6a3b5132, virtual base, RI-65) replaces it
   once on our branch: `tools/sweep-merge.sh origin/<b> "<message>"` per
   branch. Until TI signs its merge (AR 430: -S under commit.gpgsign),
   re-sign its merges on the same trees before pushing.
   Never git's recursive merge at many bases: 10 bases ran 5.5 h on one
   branch on 11-27 without finishing. Conflicts by hand:
   - walkthrough: take theirs;
   - heavy-units.json: take TI's newest side.
4. Regen, full gate, push on PASS.
5. Run `python3 tools/setup-session-home.py --check`. On exit 1, ask Daniel;
   never reinstall without him.
6. Pings on Fridays; check the pongs on Saturdays.
7. Report in a few lines and update this file.

Credit rules (TI-49):
- read a notice's rows only through register-reader;
- ring only for a row that asks something of the receiver or answers the
  receiver's row;
- use gate-triage for a red gate and run-tabulate for runs.

## Register (doc JApHYjaUESeq8tsGMGXMU5)
- **AR tab:** node bc521c46-9710, responses table m8yvbw8rqgz.2139.
  - Latest row: AR 431 .702820 (tab rev 436).
  - **The next AR row inserts after .702820**, labelled AR 432.
  - A find-replace through the Docs update tool failed with a JSON parse error
    four times on 11-21; clarify in the notice instead of retrying.
  - A whole row can't be replaced; replace its last cell's paragraph
    (read for its id and h; ifHash and ifRev both required).
- **Other tabs:**

  | Tab | Node |
  |---|---|
  | DA | d5076b00-ef1b (table .231; 4 cells Re/Date/Impl/Response, no ID; last row .137863, rev 136) |
  | TI | e8b1d9d9-df9b |
  | OA | 4c6a3151-83eb |
  | OI | 384bc26c-cef6 |
  | IS | 60e6f93a-7fdc |
  | RA | 9851686b-2b0a |
  | RI | 8e4547bc-c469 |
  | CP | 099ebfed-9eea |
  | MA | 1f971016-3f72 |
  | Conventions | 55232329-ff5c |
  | MI | c1311541-4219 |
  | DI | 1ea5d5b3-6e9c |

- **Bookmarks** (revs read through): AR 436, OA 507, TI 605, MA 221, DI 99,
  MI 74, RA 164, RI 101, IS 201, CP 160, OI 437, DA 136, Conventions 20 (full
  sweep read 11-27; TI, RA, RI read further from notices).
- **Pings:** Friday 11-27 to all 11 (OA IS TI OI CP RA RI MA RH MI DI); all
  ponged within a minute, every one `check` rc 0. Saturday has nothing left
  to check. All 11 pinged AR too; each got a pong.
  Specs: FET tab rev 54, DCU tab rev 82, MIU tab rev 161.
- **No dated tasks** (DA, in TI's session, TI 461): work is best effort in
  priority order; a dependency is met by reordering, never a due date. No date
  on a row, a handoff item or a promise; an old row's date is its priority.
  Dates here record when something happened, never when it is due.
- **Sweep 2026-11-27 (merge):** fast-merge.sh merged all 10 branches in
  0.5 s (clcw9s 148, doowtf 222, p8esoz 190, 0ch1hh 18, n6402z 146, lecnjf
  135; 20cauz, 1vzyjg, 6msg93 already in) with 29 spurious conflicts, all
  settled by history; doowtf's RA.md was an older RA copy (kept ours; TI asked
  in AR 425 (b), RA-160 says RA's own merge was right). Regen clean, gate PASS
  on 4cf5b3ea (ngd 14367 s, cg 13671 s); the 7 merges re-signed on the same
  trees and pushed as 327863cf. Session home matches.
  Register 11-27 after the merge: AR 424 (colwalk-p1k: no control; close AR
  422 (1) unless a three-memop kernel is cheap). Credit modules: AR 426
  confirmed TI-595 v3 (csr_cr its own cr_dst WIDTH 1; AVAIL and the +1 from
  one links.json entry; COMB with SPEND_W > 1 an elaboration $error; waiver
  max_flops counter+thr_q+ok_q). RI-67 showed AR 416 (1)'s +1 was misplaced;
  settled in AR 427-429 with TI-597's split: COMB and in-cycle REG at 4+2N,
  REG_LATE (OOE cok, ok_q = next>=2 || next==1 && !ok_q) at 4+2N+1, a
  missing entry = REG_LATE; controls at the declared depth: COMB credlate2,
  REG credlate, REG_LATE itself at 4+2N (RI-71 has them). No Daniel ruling
  (arithmetic under his option A). rcu_pca_mig goes COMB (RA-160).
- **Sweeps 2026-11-26 and 11-27:** the 11-26 merge stalled: clcw9s and
  doowtf each took about 3 h, with 6 merge bases, and the first try was
  killed at the 2 h task limit. Run long merges detached:
  `tools/bg-run.sh <name> <script>`, then gate-wait. The other eight were
  already contained in doowtf. Merged clcw9s 10, doowtf 105, rest 0; regen
  clean. Gate PASS on 61347a89 (ngd 11615 s, cg 10671 s, no OOM). Pushed;
  session home matches. 11-27 register: AR 420-422 are built on TI's ti-rp
  (MA-34 B, EXB 8, TL source 8, TIMEOUT_MEMOP 40960). Its gate was red
  (miu_ids bench; stub pins re-measured) and is re-running (TI-590/591).
  miu_form check-cg OOM: MI's 3826f9cf (clang++) drops it to 564 MiB, and
  TI takes it after ti-rp. OA 504: THRESHOLD_MLC stays 50 until the
  re-sweep. OA 507 asked AR to fix doowtf (10 bases in OA's sweep). AR 423
  (.692383): AR can't push there; doowtf is already in
  ccr-80102643-4n8bv4, so merge that first. OA rung.
  11-27 merges (clcw9s 12, p8esoz 95, 0ch1hh 15, n6402z 19, lecnjf 1,
  1vzyjg 1) run after the push, then a gate.
- **Sweep 2026-11-24 (Tuesday, no pings):** register: nothing open for AR.
  OA 476 took AR 414 (OA asked Daniel whether the 0.2% band covers all its
  cost rulings); DA rev 134 (OA, from Daniel): OOE paths already on
  ngd-ratchet may rise to 30 NGD until block-level assembly; MA: L0 TLB
  4/slot in A2, 32-entry TLB to A3 (ropediv +2.1%), DCU fill bound 11; OA
  487-492: redirect lag 1 (fet_redirect ports retagged cq04h, timing
  only); DI asks TI for MLC-stub probe injection (TI's stub). TI-582:
  DA-135 in the lint: AR signs CCV-L23 declarations only outside
  ooe/miu/dcu/rcu. Merged clcw9s 7, doowtf 143, 5tdecg 2, 0ch1hh 12,
  lecnjf 32, 664pgr 20 (6msg93, p8esoz, n6402z, 20cauz, 1vzyjg already
  in); no conflicts; regen clean. Gate PASS on 3d4a2fe1 (ngd 13240 s, cg
  12534 s: over 2 h, gate-wait re-armed twice); pushed 222; session home
  matches.
- **Sweep 2026-11-23 (Monday, no pings):** register: nothing new for AR in
  the sweep read; MA rev 173 prefers AR 410 (1), fills term = DCU's 16 MLC
  req_ids. Merged clcw9s 7, doowtf 155, 0ch1hh 18, n6402z 8, lecnjf 3,
  664pgr 3; no conflicts. doowtf and 0ch1hh take ~28 min each to merge
  (criss-cross merge bases): run merges and gate-waits as background tasks
  with timeout 7200000. Gate PASS on cb7fa8e7 (ngd 10550 s, cg 9680 s);
  pushed 193 commits; session home matches.
- **Sweep 2026-11-22 (Sunday, no pings):** register: nothing for AR; DA
  129-131 recorded by OA in Daniel's session (ooe_mempl 21-flop CG waiver;
  OOE redirect lag option D; CCV-L23 "table" form with OA's 7 conditions).
  Merged clcw9s 7, doowtf 73, 5tdecg 17, n6402z 10, lecnjf 5, 1vzyjg 2,
  664pgr 3; no conflicts; regen clean; full gate PASS on 4bc5e708 (~2.7 h);
  pushed 124. Session home --check exit 0. TI-518 (63579fce, MA-30 landed:
  pa_fold, one fold both sides, CHECK) arrives next sweep.
- **Sweep 2026-11-21 (10:03Z trigger):** pass 1 merged doowtf 214, n6402z
  19, 0ch1hh 2; 5tdecg conflicted in OI's files, aborted, AR 402 to OI. Full
  gate PASS on 6ba64602; pushed 238. OI fixed 5tdecg (893f2eed, OI-196);
  pass 2 merged 5tdecg 40, doowtf 2 (TI-513), 0ch1hh 2, 664pgr 6; gate PASS
  on 435b229e (~3.8 h); pushed 54. New work on 9 branches since: next sweep.
  Session home --check exit 0. Saturday pongs: all 11-20 pongs were in.
- **Sweep 2026-11-20 (10:03Z trigger):** merged 7 branches, 60 commits (p8esoz 29,
  1vzyjg 10, miu-dcu-microarch-spec 6, n6402z 5, doowtf 4, infra-6msg93 4,
  0ch1hh 2), no conflicts, regen clean; full gate PASS on 5f02cdfc (~3.8 h);
  pushed. Answered every agent's Friday ping. Session home INSTALLED with
  Daniel's approval (2026-11-20); --check exit 0, handoff hook verified.
- **Earlier 2026-11-20:** merged the 11-19 and 11-20 branches (OA.md
  conflict in 20cauz taken as ours, which held OA's newer 5de62e85); the gate
  was killed by container restarts four times, then RESUMED PASS (22 of 24
  carried over) on adf157b0; pushed 308 commits. Session home still exit 1.
  Friday pings sent 2026-11-20 to OA IS TI OI CP RA RI MA RH MI DI (roster
  sessions). All 11 pongs passed check (none owed).
- **Sweep 2026-11-18:** 9 branches merged (139 commits); first full gate
  FAIL only because check-cg was OOM-killed (its python ~5 GB beside a cm128
  sim ~6.5 GB); rerun alone PASS (~3.8 h); pushed f28a3f33. Session home
  check exit 1 (settings.json keys autoCompactWindow/env/hooks differ, agents
  not linked): asked Daniel to approve a reinstall.
- **Never run a cm128-class sim beside a gate** (15 GB container): pause
  /home/user/ar-work lanes before verify.sh.
- **Insert a row:** update with ref {"object":"node","id":"bc521c46-9710"},
  engine "prose", container {"kind":"project","id":"JApHYjaUESeq8tsGMGXMU5"}.
  The payload is
  {"ops":[{"op":"insert","target":{"kind":"blocks","ids":["m8yvbw8rqgz.<row>"]},
  "side":"after","source":{"as":"blocks","from":{"kind":"inline","content":[tableRow
  of 4 tableCells: ref, date, Needs, a paragraph with a bold lead]}}}]}.
- **Replace text:** {"op":"replace","target":{"kind":"chars","range":[s,e]},"with":"..."}.
  The key is `with`, never `source`.
- **Read:** {"kind":"view","sinceRev":n} or {"kind":"search","text":...}.
- **Ids:** write ops need FULL ids (m8yvbw8rqgz.n; specs use m30rdwkg40n.n).
  A cell's paragraph is the cell id + 1. Never use "chars" on run ids.
- **Notices:**
  - send with mcp__claude-code-remote__send_message, priority "later", one
    recipient per call;
  - text: "REGISTER-NOTICE v1 from=AR to=X tab=AR rows=... rev=N\n<summary>\nRead
    the rows in the register (https://claude.ai/artifact/JApHYjaUESeq8tsGMGXMU5);
    answer there, in your own tab. This notice is a pointer, not a request:
    the rows are the record.";
  - logs on AR's own disk can't be reached by other sessions: never cite
    them in a row.
- **Sessions:**

  | Agent | Session |
  |---|---|
  | TI | session_01J4Yp3xeV6DJtgCtcoqVsAq |
  | OA | session_01TbX2MyX6quhjarDR7J2bMR |
  | OI | session_01DMw4FtFbGoVboMGxWpLBuv |
  | MA | session_01QPk2jyUbWA7fW9YpUwqdxk |
  | IS | session_01989HiTNh4Gx7XMSsdvdE7Z |
  | CP | session_019cSebQ45AT3pSnPU71torg |
  | RA | session_01QPk2jzLmjd3MWXjayVUy9d |
  | RI | session_01QPk2jvvXPLs4m8ZQbSk1g6 |
  | RH | session_01QPk2jvfKM1V5rRfip8FC86 |
  | MI | session_01QPk2jzH1Gd3DcxK4F4pwCC |
  | DI | session_01QPk2jz5TVESyWMKVKjqqEA |

  RH is DA's run helper. It has no register tab and reports by message.
  Daniel says AR may use RH for runs when it is idle.
- **Specs doc DJeg9Hh8rkPDecq4hrAz35:**

  | Tab | Node | Owner |
  |---|---|---|
  | MIU | aa7a288a-dae2 | MA |
  | DCU | c18a112b-d2c6 | MA |
  | RCU | eda9347a-feaa | RA |
  | OOE | 515615a9-8caf | OA |
  | RAU | 090626bb-a50c | AR |
  | PCA | 94b3a0ea-7224 | AR |
  | FET | 75d75b94-1614 | AR |
  | DEC | 1d1fdcda-739e | AR |
  | SPM | b66e4f64-612c | AR |
  | LANE | ea1f36a7-0725 | AR |
  | SYU | 1f8b4472-68c1 | AR |
  | CRU | 5a50fd80-2423 | AR |
  | MLC | f8873ac6-e74d | AR |
  | EXB | 56392a06-86a6 | AR |

## Decided recently (DA tab)
- **DA 114:** C9 approved. **DA 116:** RCU in-side 13 / OOE out 0;
  miu_rcu_data keeps its flop.
- **DA 117/118:** MA is the MIU and DCU architect; MI and DI implement.
  **DA 119:** model first, covering every important event.
- **DA 120:** owners may move NGD budgets that convergence times. Architects
  keep:
  - unmeasured-parent budgets;
  - block-boundary and lead budgets;
  - child ports wired to the boundary.
- **DA 121:**
  - (a) L1 built for 512 KiB (8 ways × 512 sets × 128 B), configured down by
    sets, with the 512 KiB hit latency at every size. TI sets CCV_DCU_SETS
    512 on ti-nohit. PF-51 (variable latency per size) is MA's.
  - (b) MIU and DCU stay separate. The merge is decided in Phase 2, on MI/DI's
    timing model plus AR's PF-33/PF-47 at 512 KiB.
  - MA-13 still holds: MI and DI start only once the grill-me is finished,
    Daniel's summary is delivered and everything is documented.

- **DA 124 (two rows, .125982 and .127235):** the machine-error system
  (AR 370) and SPM as RF (AR 371).

## Params at HEAD
- L1: HIT_BASE 7, RCU_ADDR_BASE 1, L1_WAKE 13, L1_CMPL 14, L1_NOHIT 9.
  Hit 8 gives 14/15; hit 9 gives 15/16; base 5 gives ADDR 5, WAKE 17,
  CMPL 18, NOHIT 13.
- DCU 64 sets now (512 on ti-nohit). CCV_L_PAGE_SHIFT 16.

## Open work (most urgent first)

000n. **PCA places (AR 431 .702820, 11-28; TI, RA, RI, OI rung).** gtw32
   (32 warps) hung: a demote took its PCA place only at drained, all 28 held.
   Ruled both: RAU reserves a place when it sends the demote (refused drained
   returns it), and PCA gets a spare, CCV_PCA_PLACES = CCV_PARKED_WARPS + 1 =
   29 (rows 247 of 256 per SRAM instance, inside the padding: no SRAM; div
   state RFs 29 x 212, +1,060 bits; W_PCA_PLACE stays 5). Why the spare: the
   policy is evict, so without it a full core never demotes until an exit.
   Spec tabs edited: RAU Parked places (now list item .35863), .23245,
   .37015 (was .34040); PCA .27, .12487, .3328 (doc revs RAU 66, PCA 21).
   TI owes the param, stubs, a no-reservation brk on gtw32, two bins; then
   OA's THRESHOLD_MLC re-sweep (OA 504) can run.

000m. **Read-path depth DECIDED: B, 128 lines (DA row .137863, 11-24; PF-54).**
   MA-31 (MA rev 218) sized A 64 / B 128 / C 192 on p1 at TB latency 1000.
   AR 419 (.686863) agreed B, with three points: (2) keep CCV_MIU_PIPES 4,
   since it is the AGU count tied to CCV_SECTIONS, and add a new MIU
   parameter for memops in flight, at 8; (3) MLC gets a 132-entry miss
   table, split by bank, about 8 kbit; (4) MA states the return-state
   delta for the area table. Daniel then chose B in this session,
   about 41 kbit. MA rung twice. MA owes the TI/DI/MI rows, then tells
   OA the THRESHOLD_MLC re-sweep can run. AR owes the 132-entry miss
   table in the MLC spec. MA rev 219 agreed AR 419: the new parameter is
   CCV_MIU_MEMOPS_INFLIGHT=8, about +800 flops (MI to measure); the
   return-state delta is +19.2 kbit; the 160-id pick splits by bank if it
   goes over 25 NGD. Nothing owed.
   Since then: MA-34 carries B; MLC spec rev 4 has the 132-entry table and
   HIT_MAX 28. AR 420 (EXB 8 plus require), AR 421 (TIMEOUT_MEMOP divides
   by MSHR_PER_BANK, stays 40960; control colwalk-p1k at TB 1000) and
   AR 422 (CCV_L_W_TL_SOURCE = W_REQ_MLC_EXB; TL_OUT 1229, TL_IN 1180;
   ride-along dropped) are all built by TI (06b85bfa, 2f1fde73, 686a9846)
   and land with ti-rp. DI-58 builds the per-bank dcu_mshr; MI-48 has
   miu_ids at 160. Watch ti-rp's gate, then OA's re-sweep.
000i1. **Re-baseline DONE (eb1c3851, AR 418 .685318, 11-24; MA rung).**
   RH's runs (warm-MLC recipe, 4e3dda64 vs 77f7849e, 49 exact): S1 1,640
   and cm32priv 1,177,935 unchanged at every seed; cm128priv 1,977,489 ->
   1,978,481 (+0.050% seed 1; +0.061% jitter 0; seed spread 0.091%).
   Warm-MLC figures never paid the slow region, so the L1 capacity and
   hit-latency tables stand; AR 411 (2) corrected. MA re-runs only its
   cold (non-CCV_MLC_WARM) runs. perf-register: re-baseline section, PF-39
   HIT_MAX 28, PF-54 read-path depth target. RH's worktrees released.
   MA rev 215 (re AR 418): MA-30 ran cold, so MA re-runs it on the fixed
   TB (its revs 174-175 batch); S1 and cm32priv done (R3 now -0.36% on
   cm32), cm128priv waits on DI's MA-33 fix; full table follows. Nothing
   owed until it lands (k=4 over the bar -> MA sends a row).
000l. **Common credit RTL modules (TI-537/539/540, Daniel to TI: "a common
   RTL module ... for the block interfaces"). AR 415 (.679095): at a flopped
   end (BOUNDARY 1, the RTL default) cr_src is the counter and go only, and
   cr_dst drives the credit from logic; their own valid/payload/credit flops
   exist only at no_flop ends; a generated FLOPPED and DEPTH per end; one
   module-level credit:true waiver. (5) the credit/stall -> cr_go -> valid
   port path: Daniel ruled option A in TI's session (a named exception
   timed as the pair of port budgets, only through cr_go, never NGD-5; TI
   writes it into rtl-coding-style and check-ngd, with a control). AR 416
   (.682467) on v2 (cr_cnt/cr_go/cr_src/cr_dst): confirmed; REG and LATE
   need 4+2N+1, so the avail form is declared per end in links.json and
   DEPTH, the checkers and AVAIL derive from it; COMB with SPEND_W>1 refused;
   waiver max_flops = the largest instance (MIU 8); lead:true only at
   FLOPPED=0. RA-159 confirmed with five RCU corrections, taken. TI builds
   after the ti-tblat landing. 11-27: v3 confirmed (AR 426); AR 416 (1)'s
   "REG and LATE +1" CORRECTED by AR 427-429: COMB and in-cycle REG at
   4+2N, only REG_LATE +1, missing entry = REG_LATE (see the 11-27 sweep
   note). Nothing owed by AR; TI builds after ti-rp.
000k. **MLC hit max (AR 413 .676576, 11-23; OA, TI, MA rung), re: MA rev
   178 (d).** HIT_MAX's (2^W_REQ_DCU_MLC - 1) term (AR's TI-24 (5)) counted
   DCU's in-flight misses as a port queue; it becomes 2**W_REQ_FET_MLC (4),
   HIT_MAX 39 -> 28, so MA's 8-bit DCU->MLC ids leave THRESHOLD_MLC=50
   standing. TI edits the derive and doc; OA decides on a re-sweep at the
   read class. AR fixes PF-39's wording at the re-baseline. MA rev 178:
   ~1,030-cycle RT -> ~130 lines; candidates 160/192 (DCU MSHR 160, bank
   queues 24, an MIU park table, 8-bit ids), measured in Phase 1 after
   ti-tblat. TI-534: AR 412 (1) on ti-tblat 4dc0dc41 (seed 1,
   tb_overtaken bin); (2)/(3) next; one before/after table on landing.
   TI-535: (2) on ti-tblat 290a158d. OA-475: THRESHOLD_MLC re-swept
   35/50/75/100 at the read/swap classes and S1 once MA's Phase 1 sizes are
   in the stub; 50 stands; OI adds a false-demotion split now. AR 414
   (.678467): accepted, but an S1 cost of 0.2-0.5% goes to Daniel (OA had
   written <=0.5%).
   TI-545: swap class on new kernel vadd6 (5 demoted/restored at 1000,
   slot_refill_parked); 20+-5 still demotes once (credit contention). AR 417
   (.684284): the control is both thresholds raised over the latency
   (bins empty, class fails); W_REQ_MLC_EXB 6 -> 8 (not 7: 128 < MA's ~130
   lines, shared with ifills and writebacks), provisional.
   MLC's spec is AR's (DA row .135300); W_REQ_MLC_EXB 8 stands as its owner's.
000j. **Testbench latency (DA row .133923, AR 412 .673737, 11-23; TI, MA
   rung).** Daniel: default 20 +/-5 (seeded draw keyed by CCV_TB_SEED and
   arrival order; CCV_TB_JITTER half-width; slow regions stay fixed); a swap
   class (CCV_TB_LATENCY=1000, >4 warps, demotion/restore/refill bins,
   control at 20); a read class at the true latency 1000 cycles with target
   16 B/cycle = 125 lines in flight (Daniel chose both). HEAD caps: DCU->MLC
   16 ids (8x short), MIU->DCU and MLC->EXB 64 (2x), MIU memop queue 40 (~3x).
   OWED BY AR: a PF row for the read target; raise MLC->EXB's owner with
   Daniel (no session owns MLC); re-baseline perf-register once on ti-tblat
   and the 20 default together. MA sizes MIU/DCU (Phase 1 model).
   The DRAM-latency question to Daniel is ANSWERED.
000i0. MI-21 (MA rev 176, FYI): O-83's one-sum form (AR revs 211-219) was
   ~32 NGD in A1; MA added a second 22-bit adder per lane (MIU tab rev 165).
   MA's block; nothing owed.
000i. **TI-532 / AR 411 .672138 (11-23; TI, MA rung): re-baseline
   perf-register when ti-tblat lands (OWED BY AR).** TI-532: fix 8daf7a2c on
   gate-scratch/TI-tblat, lands after the FILL_AGE gate; MEMOP timeout
   ceil(10x32/16)x2048 = 40,960 (checked). Deltas: colwalk/transpose/sgemm
   -84..-97%, cm1priv -10.8%, cm32priv -11.2%, cmpl32priv -2.3%, cm128priv
   -23.0%; S1 kernels unchanged. The 1000-cycle region dates from the 11-13
   merge 0a9a8e90 (f67bb983 only capped it), so every coremark -priv figure
   in perf-register from 11-13 on carries it (L1 capacity AR rev 344, hit
   latency AR rev 363, MA-30, DI-23). Re-baseline: mark each affected entry,
   replace a table only where a re-run exists; cycles from TI's landing row
   if FILL_AGE moved them, else TI-532's. MA (revs 174-175) re-runs the
   MA-30 grid, L1 capacity and hit latency in one batch after landing; a row
   to AR only if a step falls under 0.5% or a ranking flips.
000h. **TI-531 testbench slow region (AR 410 .670198, 11-23; TI rung).**
   coremark128's data (0x110000+) sat in the stub's 1000-cycle region
   (kDeepBase 0xC0000 to 4 GB), meant only for Daniel's stall kernel
   (2026-10-21, "no other kernel reaches it"). Ruled (1): kSlowEnd 1 MiB,
   stress via explicit CCV_TB_LATENCY, plus (2): CCV_P_TIMEOUT_MEMOP derived
   (queue depth x lines/memop / fills in flight x worst latency) with a
   require. TI first reports which perf kernels had data >= 0xC0000, with
   cycles before and after; AR then re-baselines docs/perf-register.md.
   Re-run only decisions near Daniel's bar on moved kernels (MA-30
   cm128priv +0.30%). Daniel's DRAM-latency answer: see 000j.
000g. **TI-527 probe ack (AR 409 .668434, 11-23; TI, MA rung).** ack=1 iff
   dirty_data carries the line (DI's reading); one ack per probe, its valid
   the acknowledgement; a dirty line reaches MLC exactly once (ack or
   writeback); a writeback-buffer hit answers ack=1 and cancels that
   writeback; already sent -> ack=0. MLC-stub CHECK, controls, bins. MA
   agreed (MA rev 165; DCU tab rev 107: same-cycle compare vs the request
   pick, probe wins). CLOSED; TI writes the doc text.
000f. **OA 469 pc_kept on ccv_ooe_rau_drained (AR 406 .664201, 11-23; TI, RA,
   OA rung).** Confirmed; PC-on-alloc stays rejected. pc_kept=1 iff nothing
   retired since the slot's alloc (launch/restore-alloc) and nothing in
   ROB/decq (held stragglers incl.); RAU resumes at its alloc PC. Exactness
   rests on "arch PC moves only at retire" (FET's predictor leaves start_pc
   without a ROB redirect, so OA's fetch argument was not the reason). (3)
   went to RA by mistake (RA is RCU's architect; RAU's spec is AR's, TI
   builds the stub). AR 407 .665996 rules it: no new RAU register; launch
   uses the grid start_pc, a provisional restore the parked record's
   resume_pc, kept valid to the next drained (masked write on pc_kept=1);
   non-provisional restores can't hit pc_kept (RAU's retired_ < p_base_+P
   guard). Stub's demote() must stop clearing parked[w].resume_pc. TI
   applies; nothing owed. LESSON: RA = RCU architect, not RAU.
   AR 408 .667395: took OA 471's 'iff' (pc_kept = !rsa, no retire since
   alloc; ROB/decq term dropped, per OA 470's RTL); OA 472 crossed, answered
   by AR 407. Final text for TI: AR 406 (1) as amended + AR 407 (5). CLOSED.
000e. **MA-30 way predictor (AR 405 .662302, 11-22; MA, TI rung).** Agreed
   k=4 fold table (16,384 flops in dcu_bctl), pa_fold on ccv_miu_dcu_req,
   HIT 8. Price vs k=5: S1 -0.02, cm32priv -0.17, cm128priv +0.30%; vs B9
   (no predictor, HIT 9) about -1.1/-1.0/-0.6%. Under Daniel's bar (S1).
   MA took the conditions (MA rev 155; DCU tab rev 82, MIU tab rev 161): an
   alias mispredict sends nothing at the hit slot (miss indication) and
   re-reads at H+5 on the loser's path, no new field; the table has a valid
   bit (no match = miss, no read); the fold is PA[47:16] XOR-chunked, i.e.
   the PFN (64 sets x 8 banks x 128 B = 64 KiB a way), so MIU's TLB holds it;
   CHECK, controls and bins stated. CLOSED; nothing owed.
000c. **MA-27/MA-28 (AR 400, 401, 403): CLOSED.** Drop field on
   ccv_miu_dcu_req and 128 check bits a slot on ccv_dcu_miu_rsp landed in
   TI-513 (8ac4c441), with CCV_DCU_ECC_INJECT; MA rev 146 accepted. MA rev 149
   priced AR 400 (3): the A1 hold fires 0 times on S1/cm32priv/cm128priv,
   drops cost <=0.008%; MA-27 closed. DI-18 (AR 403, MA rev 148 crossed and
   agrees): on a CE MIU corrects from the check bits and delivers the
   corrected data as a later ccv_miu_rcu_data write (AR 368 (2)), then the
   completion; DCU counts and rewrites in place and sends nothing more; a UE
   stays AR 370's (clean line refetched under the original req_id, MIU keeps
   it live). Added control: MIU withholds but delivers the data uncorrected.
   Still on others: DI's interim injection hook, MI's syndrome/drop model,
   MA's docs naming CCV_MIU_ECC_INJECT, TI's CCV_LAT_MIU_PAIR_LAG. Nothing owed
   by AR.
   MA-29 (AR 404, 11-22): agreed, check_bits 72 a slot, (137,128), forced by
   Daniel's MACRO-1; fix in the stage after R2's syndrome (15.4 + 10.7 NGD
   > 25); ECC stays 1. MBU question answered (MA rev 152): column mux >= 4
   in the 512x137 instance, a DCU instance requirement; closed. TI landed
   it (TI-517, bc9d61ff: CCV_DCU_ECC_K=128, CCV_DCU_ECC_CHECK_W).
000b. **TI-502 credit deadlock: SETTLED (AR 397 .649791, AR 398 .652069,
   AR 399 .653325; OA 459/460/461).** FET's full-credit wait (AR 395 (3))
   stays; (b) drained+delay and (c) no wait refused. OOE keeps a demoting warp
   bound to its tier-1 slot until a launch/restore gives the slot to another
   warp; stragglers in that window are walked, their credits returned on that
   slot no earlier than their beats (FET credits a slot to its last warp until
   take_slot). OA 455 A's pending counter becomes a CHECK with a bin. OI
   builds to OA 460; MI reruns MI-11 (2) (lnorm1, CCV_MIU_IMPL=model
   CCV_RAU_DEMOTE=mlc). Rows crossed twice (397 vs 459, 398 vs 460); OA 461
   says both forms are one rule. OA 462 (rev 464): the root cause was a
   lost epoch advance (OI-193, fixed); the binding is unreachable under 395 (3)
   and is dropped for a CHECK; 395 (3) is the rule. Accepted, nothing owed. LESSON: after ringing an owner
   on its own block, wait for its row before writing another; a crossing
   costs two rows each side.
   TI-501 (e8d8864b, on doowtf/infra-6msg93, not in 5f02cdfc): FET's mig wait
   matches AR 395 (3) with --break mig-before-credits; arrives next sweep.
000a. **AR 393-396 (11-19/20): rewind contract and DCU notices, CLOSED.**
   - Rewind (AR 393 amended by AR 395; OA-457 adopted 395, OA-456 crossed and
     is superseded): at most one rewind beat per ROB/decq entry with new lanes,
     no lane in two beats (FET asserts); beats one a cycle, applied on landing;
     held-ahead clear and credit return on the first beat only. The drain rests
     on conservation, not CCV_DRAIN_WAIT: OOE walks stragglers on arrival; each
     walked uop's credit reaches FET no earlier than its beat; FET sends
     ccv_fet_pca_mig and decides unnamed lanes only on ccv_rau_fet_mig AND the
     warp's credits full. FET tab rev 54 says so. Implemented by TI-493
     (b818bca1, ti-mi9) and OI (33b2971c, oi-5b). Do not re-rule.
   - DCU refill notices (AR 394, OA-453, DCU tab rev 59): CCV_DCU_NOTICE=0 by
     default, channel ccv_dcu_miu_fill_ntc kept; off measured -0.43% mean over
     64 kernels. Phase 2 prefers an MLC tag-lookup notice to a lead field.
   - DI-4 closed. Nothing owed.
00. **Machine-error system: DECIDED (DA rev 124; AR 370, row .596551,
   tab rev 372; notices to MA, IS, TI).** Daniel answered AR 369 (a)-(d):
   core-fatal yes; clean-line refetch "only if we keep track of how many
   times this has happened to the same line" (no forever loop on a real
   bad bit); F-MACHINE yes; polling yes.
   - CE corrected and counted. A clean-line UE is refetched, with
     CCV_DCU_UE_TRACK entries (MA sizes it) keyed by location (bank, set,
     way). A second UE at a recorded location, or a UE with the table full,
     is core-fatal and logged for spare-row repair.
   - Core-fatal: dirty-line UE, writeback victim, fill, or a hard error.
     ccv_dcu_cru_err (ue, ce_alert) goes to CRU, which latches
     MACHINE_CHECK, kills every grid via RAU, and writes F-MACHINE (code 10,
     Execute, lowest priority; IS O-86, §12.7 exception) into every live
     record. The host polls and resets.
   - ccv_common_err in DCU (MA 81), host-only. No ue on dcu_miu_rsp or
     spm_miu. F-MACHINE is written only by the core-fatal path in v1.
   - MA-19 (MA rev 82) took it: CCV_DCU_UE_TRACK 16 (one per spare row),
     key bank/instance/row, DCU tab rev 46. IS rev 197 wrote O-86 in ISA
     v1.9 at compiler 103976f (F-MACHINE §12.3/12.5/12.7/12.8; pin bump is
     TI's). Waiting on: TI landing it.
     Owe nothing.
0a. **L1_CMPL 15: RULED (OA 426, re OI-162; AR 368 closes on TI landing
   it).** CCV_LAT_L1_ECC = 1, CMPL 14 -> 15; HIT 7, WAKE 13 and NOHIT 9
   are unchanged. Priced at S1 +0.05%, cm32-priv -0.35%, cm128-priv +0.45%
   (mostly reexec, 7,992 -> 23,757). RA 154 closed RA 153. TI 478 landed
   it (5c1fe873; ooe_wake unit 9682b03a): param, CMPL and rcu_data
   contract text checked against AR 368, match. AR 368 CLOSED; reaches
   this branch in the next sweep. Nothing owed.
0. **SPM is RF: DECIDED (DA rev 124, "use RF"; AR 371, row .599641,
   Needs TI).** Each of the 32 banks is a ccv_common_rf_1r1w, 1024 x 32,
   at about 3.32x per bit (efficiency about 0.30). It runs at full rate and
   has no SECDED, so LAT_SPM_BASE stays 2. SPM is outside the fault system
   until PF-48.
   - No byte enables: a sub-word write is a read-modify-write (read port,
     then the write port next cycle), taking that bank's read slot.
   - Fallback: if check-ngd finds the 1024-word read launch too deep, use
     2 x 512 RFs per bank.
   - The specs doc's SPM tab carries it ("Arrays, decided", rev 4).
   - TI 477 landed MACRO-1 (ddc700a1: size limits, architect-written
     waivers, size penalty, per-block efficiency). SPM's 4 KiB RF (and the
     2 KiB fallback) is in range, so AR owes no waiver.
0-. **MIU/DCU Phase 1 sweeps (DA rev 125: all start now, split MA / RH / AR;
   MA-21).** MA builds the closed-loop p1 model and RH runs it. AR's three
   asks are answered in AR 373 (.604516; notices to MA, CP, TI):
   - (1) Open-loop screen: ~/l1sweep/bank/banksim_p1.py, grid in
     ~/l1sweep/bank/p1/grid.txt (90 runs). Step (ii) goes from 24 points to
     8: (a), (a+f) and (b) at depths 0 and 2, fixed order, then rotating
     order on the best two. At x1, depth 2 equals an unbounded queue, and
     fixed equals rotating (the stub issues one lookup a cycle). The 4x
     squeeze is past capacity everywhere and is kept only as the age-bound
     check (deferred max 30). Late loads (a / a+f / b): cm128 4.91 / 4.10 /
     4.12%, cm32 3.56 / 2.60 / 3.45%.
   - (2) Stride kernel: transpose and sgemm at n256 and n512 are at the
     pin, and TI is asked for their bench configs. colwalk-pP (1 to 32 KiB
     plus a 128 B control) is asked of CP, spec in the row.
   - (3) AR books every result in perf-register.md as PF rows, citing
     MA's rows and RH's runs.
   MA rev 88 took the 8 points: p1 model in (CCV_DCU_IMPL=p1, S1 clean),
   depth 0 a re-pass at +6, each point at an optimistic and a strict
   contract bound. Waiting on: MA's p1 results, CP's kernel, TI's configs.
   - AR 374 (.608275; Daniel asked whether AR should help with runs):
     offered to run every CCV_P1_STRICT=1 point on cm32, cm128 and both
     priv forms (32 runs; RH runs the defaults) plus step (iv)'s stride
     runs. Needs: p1 on a branch (none on any remote yet), its invocation,
     and MA's yes. One cm128 at a time (about 7 GB; disk had 15 GB free).
   - TI 479: the stride benches are built on ti-stride (also
     gate-scratch/TI-stride, not yet gated) at test/bench/{transpose,sgemm}-
     n{256,512}; run one with tools/time-bench.sh <dir>. Cycles (stub FET /
     perfect): transpose-n256 and n512 both 38649 / 37469 (428 DCU lookups,
     identical as AR 373 predicted), sgemm-n256 189253 / 187537, sgemm-n512
     374035 / 368223. sgemm FAILs on a false RCU lane-tid CHECK with SFU ops
     (RI's fix); its numbers wait on it, and transpose's stand.
   - MA rev 88 said yes to AR 374's split: AR runs every CCV_P1_STRICT=1
     point on cm32, cm128, cm32priv and cm128priv plus the stride runs
     (hash off and on at the winner, both bounds); RH runs the defaults and
     S1. The model is dd04f733 (gate-scratch/MA), worktree /root/p1wt
     (gens.sh, then check-skel). Env: CCV_DCU_WAYS=8 CCV_DCU_IMPL=p1
     CCV_P1_STORE=a|af|b CCV_P1_QDEPTH=0|2 CCV_P1_ARB=fixed|rot
     CCV_P1_STRICT=1 [CCV_P1_HASH=1]; ccv-skel --kernel <oracle> --cycles
     2000000000. Read KERNEL (cycles, finished, check_failures), COVER
     (l1_hit, l1_late, l1_inelig) and the P1 line. The runner is
     /root/l1sweep/p1runs/run.sh <128|32> [arb], detached in two lanes
     (cm128 one at a time); its progress is p1runs/progress.log. The
     oracles are reused from ~/l1sweep/oracle{,p} (same pin). Next: the rot
     points on the best two, then return one table to MA and book PF rows.
     **2026-11-18 ~03:00Z: the container was replaced and /root was lost**
     (/root/l1sweep: logs, scripts, ev traces, oracles, worktrees). Only
     /home/user survives, so keep everything under /home/user/ar-work. The
     numbers recovered from the transcript are in
     ar-work/results/recovered-2026-11-18.md (17 strict, all 88 stride, the
     p128b cuts, way prediction). The rebuild moved to MA's 258f642b
     (gate-scratch/MA). It adds CCV_P1_WAYPRED=0|3|4, and 13e584e5 fixes
     the (b) starvation: (a) and (af) are unchanged, (b) must be rerun.
     ar-work/rebuild2.sh (log rebuild.log) built wt7, wt8 and wt9:
     CCV_LAT_L1_HIT_BASE, HIT, WAKE and CMPL shifted +0/+1/+2 in params. HIT
     is build-time, not an env knob. Oracles are in ar-work/oracle (5.7 GB).
     MA's c94f0ae6 (the born_ fix: a store merged at arrival left a stale
     first-arrival time, so b's 63k tail and b's cycles were a measurement
     bug; a and af never take that path) is built as ar-work/wtb7 (hit 7;
     LDFIRST default 0). All (b) points run there (hit field "b7"). The (b)
     logs from 258f642b are in runs/old (invalid). ar-work/lanes.sh holds
     the lists (A is 128-class; B is 32-class and ends with cm128priv b_q0:
     check memory before it overlaps a cm128). Its first point is a control:
     cm32priv af q2 on wtb7 must equal 2,088,721.
     Tabulate with ar-work/tab.py. Progress is in ar-work/runs/progress.log.
     sgemm is not on 258f642b (TI's 358ace66 has it); add it later.
     MA-23: AR 377 (VA = PA; the fold is over VA bits above the page), AR
     378 (rows .616053, .618036): (B)+(C2) at hit 8, linear about +0.614%
     cm128 and +2.534% cm32 against (A), S1 flat; 3-bit fold. MA agrees
     and recommends it to DA. These runs confirm it closed-loop; then
     answer MA and DA in one row.
     Old note: tabulate with `python3 /root/l1sweep/p1runs/tab.py` (gone). 13/24 were done at
     21:11Z, all finished with check 0. (b) is cheapest on cycles everywhere,
     but cm32 shared (b) q2 has wait max 63,472 (1,100 waits >= 64). A
     suspected starvation, for MA in the table row: a lookup that re-passes
     is not in bq_, so arrive()'s (b) fast path (olderSameLine) cannot see
     it. A stream of stores to its line keeps held_ up, and the age bound
     covers only bq_ waiters. Confirm with the q0 points.
   - Stride runs: /root/stridewt is a local-only merge of dd04f733 (p1) and
     gate-scratch/TI-stride e978faa2 (benches, colwalk at a293afe, the sgemm
     RCU fix, L1_CMPL 15). Never push it. Prepared by
     /root/l1sweep/stride-prep.sh (skeleton plus build/bench-oracle). Run
     hash 0 and 1 at the winner, strict and default, on the same binary.
     DONE 22:10Z: 88 runs (11 benches; b and af at q2 fixed; h0/h1; s0/s1),
     all clean. Tabulate with `python3 /root/l1sweep/stride/tab.py`.
     - transpose and colwalk issue only 428-529 lookups; hash moves their
       cycles under 0.1%, but colwalk-p128b is +4.0% (s0) / +0.69% (s1).
     - sgemm late 25% -> 5-6% with hash, yet cycles +0.9/+1.7% at s0.
     - (b) wait max 2,434-2,484 on sgemm at h0, against af's 54-61.
     - colwalk p16k/p32k take 2x cycles (131k vs 66k) whatever the hash:
       not banks; L1 sets?
   - Strict so far: q0 is out (cm32 shared +30%, 4.5M re-passes), and
     cm128priv b_q0 wait max 1,019. Best two: b_q2 and af_q2. chain-rot.sh
     runs them with rot (QS=2 STS="b af" run.sh L rot) after each lane's
     "LANE L fixed DONE".
   - CP-84: colwalk-p1k to p32k and p128b are in compiler release a293afe;
     TI does the bench configs (they need gen-oracle's LOAD) and the pin
     bump.
0000000. **AR 391/392 (.640639/.641950; MA, IS, TI rung): page-table format DONE** (specs doc Common tab rev 8, 'Page tables' after 'Machine parameters'; paragraph .7244 + list .7628): 3 levels VA[47:42]/[41:29]/[28:16], 64 KiB nodes, 8-byte PTE V/W/X bits 0-2, PPN bits 47:16; F-ADDR/F-RO/F-FETCH per IS rev 198 (no ISA change). TI owes the page-table base CSR (with Q-50). MA asked VA[63:48]: Common tab rev 9 states ISA v1.9 §5.1 (.global outside [0,2^48) = F-ADDR before any walk). MA took the format (MA rev 122).
000000. **AR 390 (.639607, rev 393; MA+OA rung):** DI-2: agreed MA's default, a way mispredict (due+2, half-rate bank) takes the bank-conflict loser's path; TI-478 slot not stretched. OA 442 AGREED (closed). OA 443 said OOE neutral on TI-487; AR 389 (option 3) stands.
00000. **AR 389 (.638569, rev 392; MA/TI/OA rung): FINAL on TI-487 = option (3)** (MC kill: RAU waits for no ack; model still requires the 7 non-MIU acks). AR 388 (option 1) crossed MA 114/OA 441, which had taken (3), and is withdrawn. RAU bullet restored (RAU tab rev 63, block .35164). DCU tab rev 53 says (3). Do NOT change again without a new fact. Kill races CLOSED (OA 438; TI 663bed37). MA .91357 took AR 386 defaults (5/recent) unless the cm128 run loses >0.2%. PATTERN (3 crossings on 11-19): crossings happen when agents answer within minutes; before ruling on another owner's block, read that owner's tab for a newer row on the same question, and once owners have adopted a ruling of yours, do not withdraw it for an equally correct alternative.
0000. **AR 386 (.633499, rev 389; MA rung):** DA rev 128 closed MA-23 with (B) + way prediction as params; AR recommended defaults WAYPRED_BITS 5, SEL recent (recent = 0 wrong closed-loop on cm32priv/cm32/cm128priv at 3 and 5 bits). CONFIRMED by RH: cm128 h8 5/recent = 5,634,717 = no-WP, 0 wrong of 10.9M; defaults stand, closed. Container restarts every 20-90 min kill long runs: relaunch with setsid nohup ./run2.sh <point> after checking uptime. Remaining lane C index points dropped (not needed for defaults). Offline wpsim MRU is NOT the model's 'recent' (predicted 0.79% on cm128priv k3; model 0).
000. **AR 384 (.631084, rev 387; TI+OA rung):** withdrew AR 383; adopted OA 436 for both kill races. (a) MIU keeps atomic pass state through A3, completes, releases hold; no OOE change. (b) FET clears a killed slot's checkpoints on OOE's epoch_only notice (A-58/A-60 ordering), V-46 no exception, FET kill_ack follows the notice (FET spec rev 49; asked OA to confirm that last point). Lesson: read the owner's latest row (OA) before ruling across a boundary. OA 437 (OA rev 439) crossed it, accepting AR 383; AR 385 (.632674, rev 388) made OA 436 final for both. Do not re-flip; answer OA only on a technical objection to OA 436. MA rev 105 followed OA 437 (MIU tab rev 141 = AR 383 form); AR asked MA by notice to restore rev 140 (OA 436 form). Check MIU tab returns to it. MA rev 106: MIU tab pending (rev 142) until AR+OA name one form in one row; MA leans OA 437; else Daniel. AR waits for OA's answer to AR 385; if OA prefers 437, accept it for (a) (owners of OOE+MIU agree), then one joint row; (b) FET spec rev 49 to follow whatever is agreed.
00. **AR 382 (.626491, rev 385; MA rung):** agreed MA-24 (store (b), QDEPTH 16, DEFCAP 12) on 4 conditions: refusal signalling (encoding or TI field), same-line order, refused store re-presented first (BANK_AGE bound), coverage bin + control. Also carries the L1 ECC note (speculative+replay). MA accepted all 4 (MA rev 101): MIU-held per-bank credits, hard reservation 16 entries/12 data, DCU credit-return pulse vector = a TI field after MA prices it. Closed for AR. WPSEL results still owed in AR 383.
0. **TI-483 (TI rev 482, read; no ask of AR):** SECDED enc/syn/fix landed (b407ff71). Decode cannot share the rdata stage: either 2 flops (rdata, syndrome) or speculative use + replay on nonzero syndrome. L1 choice is MA's (CCV_LAT_L1_ECC=1 today); fold into AR 382: MA-23 closed loop prices +1 hit cycle at ~+1.0% cm32priv/cm128priv, ~+0.1% shared, so 2 flops ~+2% private -> favour speculative+replay for L1. AR's own arrays (FET I-cache, SPM, LANE RF) need the same choice in the owed specs.
0a. **AR 381 (.623833; rev 384; MA rung):** MA-23 closed loop + CORRECTION (fold-3 99.13% assumed most-recent select; way-index select is 6.4% wrong on cm128priv). Asked MA for a select knob (index|recent) + k=5 in wayPredict; AR runs h8wp3/h8wp5 on cm128 + cm128priv once on MA branch. Offline replay: /home/user/ar-work/scripts/wpsim.py (files comma-joined, sets, folds). Results in ar-work/results/recovered-2026-11-18.md. Lane A done (rot + a points). MA's a6c7de10 WPSEL knob landed; lane C (ar-work/laneC.sh, binary wtw8, hit 8) results so far: recent select k3/k5 = 0 wrong on cm32priv, cm32, cm128priv (cycles = h8 no-WP); k5 index cm32priv 5,234 wrong, cm128priv k3 index 26,096 wrong (+0.53%). Remaining: cm128priv h8wp5index, cm128 x3 (lane C relaunched after the 11-19 container restart). Defaults sent in AR 386; PF-52 (parallel-way hit 7) and PF-53 (rotating arbitration) booked, closing AR 373 (3) to MA (+DA): WPSEL table + full step (ii) table (pick b), notices, PF rows in perf-register (AR 373 (3)).
0b. **AR 380 (.622154; rev 383; TI, OI, OA rung):** approved OA 432, lead_fields [warp_id, fetch_epoch] on ccv_dec_ooe_uop; DEC spec line added (pending TI). Owed: watch TI apply it, OI benches + late-lead control, DA ruling on lead form vs +0.95% cycle. Lanes: lane A relaunched 06:33Z after restart (cm128 h8/h9/h8wp3, rot, a); lane B done; cm128priv_b_q0 skipped (memory).

0c. **AR 375 (.609311; TI rung) and AR 376 (.612527; MA rung), rev 376-378.**
   AR 375 answers TI-480 and TI-481.
   - p128b's perfect-fetch gap is the OOE window share at 3 or more warps
     on a latency-bound kernel. No PF.
   - Stride summary.
   - AR's arrays (corrected at rev 377): SPM is legal. SYU arrived lanes
     become 2 rf of 32 x 256 (contexts stay the rows; an exit reads row c at
     every id). PCA rows become SRAM, 2 parity banks x 8 slices of 137 x 256
     (238 rows used; padded over the 4 KiB minimum; a row a cycle for
     MIGRATION_CYCLES 17). PCA divergence state becomes 5 rf of 28 x 212.
     FET checkpoints stay flops.
   - OWED: write these into the SYU and PCA spec tabs (specs doc SYU node
     1f8b4472-68c1, PCA 94b3a0ea-7224). Size FET's I-cache, ITLB and
     predictor, RAU's grid table and LANE's SFU tables within the limits.
   AR 376 answers MA-23 (Needs MA, DA).
   - (B) is PF-33's hit 9 (cm128 +1.03%, cm32 +4.94%).
   - (C): an XOR-folded partial-tag predictor of 3 or 4 bits is right on
     99.1-99.4% of cm128priv hits (MRU 18.6%). Cost about 1% of (B)'s.
     It needs 16,384 predictor flops, and the folded bits either ride the
     lead or the compare sits in front of the data address.
   - A question to MA: can the tag read move into the lead cycle (B at +1)?
   - AR's view (B)+(C); Daniel rules. AR confirms (C) closed-loop when MA's
     knob lands.
0b. **MA-20 bank scheduling: answered, AR 372 (.601453; notice to MA).**
   All three go into Phase 1, (1) fairness and (3) the conflict queue priced
   together first. The 729-cycle wait was deferred work behind loads, not
   slot order. (2) is the within-page hash only (bank = PA[9:7]^[12:10]^
   [15:13]; bits above 15 are translated). Open-loop: cm32 2.60/2.69/2.64%,
   cm128 4.14/4.03/3.96% (plain/within/cross); tool
   ~/l1sweep/bank/banksim_h.py (hp|hx). MA rev 85 accepted as written;
   MA-20 closed into Phase 1. Wait for its figures.
1. **L1 at 512 KiB: DONE, AR 363 (row .579939, Needs MA, notice sent).**
   Post-fix (a5481843), cm128 hit 7/8/9: 512 KiB 1,924,529 / +0.61% / +1.03%;
   128 KiB 1,946,773 / +0.59% / +1.03%; 64 KiB 2,124,002 / +1.14% (hit 8).
   cm32: +2.51% / +4.94%. S1 1,640 flat (no L1 hits). Base 5: +3.19% cm128,
   +10.29% cm32, +2.68% S1. AR's view: hit 8 only on a measured timing need.
   perf-register PF-33 and PF-47 are booked. MA accepted: HIT 7 stays.
   The f*/h*/wp worktrees are removed (11-16). ~/l1sweep keeps the scripts,
   the run logs, bank/ and oracle/oraclep (5.8 GB, regenerable; delete if
   the disk is tight). One cm128 at a time (about 7 GB at its end).
1b. **MA-16 / DA 123 (SRAM is 1RW at half rate; a register file is 3x
   per bit): AR 364 answered (row .582383; notices to MA and TI).**
   - 8 half-rate banks by [9:7]. Open-loop port-trace replay (late loads,
     8 vs 16 banks): cm128 3.30/1.92%, cm32 2.49/1.46%; 16 buys under 0.2%.
   - No separate bank field (AR 362 (4)'s was AR's error): TI drops it and
     adds the require BANKS <= SETS.
   - DCU needs an age bound on hole-filling (it starves at 4x).
   - Tools: ~/l1sweep/bank (extract.py, banksim.py, cm32.ev, cm128.ev).
     Dump with `--port-dump dcu=<vcd>`; the payload follows its valid by
     a cycle.
   - MA 68 accepted (CCV_DCU_BANK_AGE 16, tunable). TI 457 landed it at
     1861cc51 (8 banks, lead_set_index only, 36 lead flops waived, banks <=
     sets require, gen-params controls); AR checked it; no reply owed. It
     merges in the next sweep. Wait for MA's closed-loop figure.
1c. **Macro pins (DA via TI 465, re: MA-16 and AR 344; Needs MA, AR; asks
   AR nothing, no row).** Pins are endpoints, dearer than a flop: the
   address setup is the decode plus 6 (SRAM) or 4 (RF); the data setup is
   8 or 6; the rdata launch is a static D:1 mux / 1.5 plus 6 or 4. The
   knobs are CCV_NGD_* in params, landing in TI's NGD-8. At 128 words an
   SRAM 512b has an address setup of 11.5 and an rdata launch of 18.6,
   leaving about 6 NGD, so a flop sits close behind rdata. TI 464's
   macros: SRAM 1RW at every other cycle with a 2-cycle read; RF 1R1W at
   every cycle, 3x the area. If DCU's hit latency moves, it is MA's call:
   hit 8 and 9 are priced in PF-33 (+0.61%/+1.03% cm128), with S1 flat.
1d. **TI 466 (DA: no SRAM byte enables; rf_1r1w_be at 4.5x SRAM per bit):
   AR 365 answered (row .586009, rev 366; MA rung).** DCU stores become
   read-modify-write. AR 365 corrects AR 364: the lead's speculative read
   covers stores too. On 8 half-rate banks, cm128 late loads:
   - (a) the store's slot read serves as the RMW read: 3.30 -> 4.10%
     (2x: 7.03 -> 8.28%);
   - (b) a 1-bit lead_store with the read deferred: late loads unchanged,
     deferred queue up to 15 at 2x.
   AR's view: (b) only if MA's model shows (a) costing over 0.2% on S1.
   Tool: banksim.py with rmw or rmwd (banksim_v1.py is the old one).
   MA-17 (crossed) took (a): the store's read in its slot, then a
   whole-line write in a later free slot, and same-line lookups wait for
   it. AR 366 (row .588100, rev 367; MA rung) replayed that with age 16
   and the same-line wait (banksim.py ... rmw a16 sl). cm128 late loads:
   3.30 -> 4.14% (not material); at 2x, 7.05 -> 9.10%, with p99 8 -> 17
   and max 33 -> 104 (material). 40% of the 2x rise is the same-line
   wait. AR's view: Phase 1 models MA-17 (5)'s forwarding write buffer
   too, and decides on closed-loop S1. Nothing owed.
   MA 72/73 agreed: Phase 1 runs (a), (a) + a forwarding write buffer, and
   (b), all closed-loop on S1; the cheapest within 0.2% of the best wins.
   Closed. Wait for Phase 1.
   MA rev 76 on TI 474 (SECDED): speculative ECC keeps hit 7 only if OA
   takes a late cancel, else hit 8. AR 367 (row .589591, rev 369; MA rung)
   says hit 8 is already priced (cm128 +0.61%, cm32 +2.51%, S1 flat), so
   it is within the bar. The ECC'd store merge stretches the gap from 3
   to 4, which raises cm128 late loads from 4.14 to 4.91% through the
   same-line wait; the forwarding write buffer removes that. (AR first
   wrote that the gap did not move late loads; measured, and corrected.)
   OA 424: the ECC late cancel rides OOE's miss path, so HIT stays 7 and
   CMPL goes 14 -> 15, and OA asks AR to own the term. AR 368 (row
   .591363, rev 370; OA, TI and RA rung) gives:
   - a new CCV_LAT_L1_ECC (MA's count, 1), on CMPL's derive only;
   - contract text for ccv_miu_ooe_cmpl, ccv_miu_rcu_data and L1_HIT's
     doc;
   - the order: TI lands it after OI prices it and OA rules;
   - an ask to RA: confirm RCU takes the corrected second data write to
     the same phys_dst.
   SPM's decode adds to LAT_SPM_BASE (2 -> 3) instead, since A-46 bars
   speculative SPM wakes. Wait for RA, OI's price and OA's ruling.
2. **AR 362, Strawman B: LANDED (e6b1dd68, TI 455) and checked by AR
   against the six conditions.** The page-offset require has refusal
   mutations; lead_set_index is a copy of the PA bits; the stub DCU reads
   its set from the payload (no state on the lead); the dcu-set-lead
   control is in check-kernel; probes and fills are unchanged. lead_bank
   is gone and banks are 8 at 1861cc51 (TI 457). (2) A1 closing in
   25 NGD and (5) the lead waiver and keep copy come with MI's and DI's
   RTL; check them there. No reply owed.
3. **Q-42 stays open** (full abutment: clock/reset trees, the kill
   broadcast, the CSR star, non-adjacent channels). DA 121 settles only
   MIU/DCU; MA 63's "can close" was withdrawn in MA 65.
   - Floorplan plan: 16 lanes per long side, MIU on one short side, PCA+OOE
     on the other, lane links abutted.
4. **The grill-me summary to Daniel** when MA's questions close (MA-13 gate
   for MI/DI; miu-arch.md section 8).
5. **Old spec debts.** Verify at a quiet time; some may be done, and the
   history (60bceb62) has the context:
   - kill_ack text, ack after the last message lands: RAU and PCA (MIU is
     MA's now);
   - DEC imm_kind 6 (call link) line;
   - the top-level assertion that coincident miu_rcu_data slots' sections
     are disjoint.
6. **Not AR's, but watch:**
   - TI routes the -priv operand CHECK defect (on the miss path; it falls
     as L1 grows) to its owner;
   - RI-54: the RCU model honours CCV_LAT_RCU_ADDR, merged by TI.
7. **Housekeeping:** keep this file to a few kB. Fold notes in here, not in
   the scratchpad.
