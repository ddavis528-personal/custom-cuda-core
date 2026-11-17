# AR handoff (top-level architect)

Updated 2026-11-17 (trimmed from 65 KB; the full history before the trim is
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
    DEC, SYU, SPM; MIU and DCU are MA's since DA 118);
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
  - exit 4: killed, start the job again.
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
   `release` and `gate-scratch/*`. Conflicts:
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
  - Latest rows: AR 373 .604516, AR 374 .608275 (tab rev 375).
  - **The next AR row inserts after .608275**, labelled AR 375.
  - A whole row can't be replaced; replace its last cell's paragraph
    (read for its id and h; ifHash and ifRev both required).
- **Other tabs:**

  | Tab | Node |
  |---|---|
  | DA | d5076b00-ef1b (table .231) |
  | TI | e8b1d9d9-df9b |
  | OA | 4c6a3151-83eb |
  | OI | 384bc26c-cef6 |
  | IS | 60e6f93a-7fdc |
  | RA | 9851686b-2b0a |
  | RI | 8e4547bc-c469 |
  | CP | 099ebfed-9eea |
  | MA | 1f971016-3f72 |
  | Conventions | 55232329-ff5c |

- **Bookmarks** (revs read through): AR 375, OA 428, TI 479, RA 154, RI 90,
  IS 197, CP 160, OI 366, DA 125, MA 89, Conventions 19.
- **No dated tasks** (DA, in TI's session, TI 461): work is best effort in
  priority order; a dependency is met by reordering, never a due date. No date
  on a row, a handoff item or a promise; an old row's date is its priority.
  Dates here record when something happened, never when it is due.
- **Last sweep 2026-11-16:** 7 branches merged (doowtf, miu-dcu-microarch-spec,
  57eff422, 126afa13, 9eb50716, 3868632d, c22116ce); full gate PASS (about
  4.5 h; ngd and cg take most of it); pushed de433e3b; session home matches.
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
     Tabulate with `python3 /root/l1sweep/p1runs/tab.py`. 13/24 were done at
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
   - CP-84: colwalk-p1k to p32k and p128b are in compiler release a293afe;
     TI does the bench configs (they need gen-oracle's LOAD) and the pin
     bump.
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
