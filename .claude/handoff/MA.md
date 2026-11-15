# MA handoff (MIU and DCU architecture)

Session `session_01QPk2jyUbWA7fW9YpUwqdxk`, started 2026-11-13. Start doc:
`docs/miu-arch.md` (AR's handoff). Branch `claude/miu-dcu-microarch-spec-664pgr`
in custom-cuda-core (and the same name in custom-cuda-complier, unused so far).

## Working rules beyond CLAUDE.md

- MA owns the MIU and DCU tabs of *Per-block architecture specs*
  (doc 63a486a6-7f71-4c05-82e8-e696c74779b4; MIU body aa7a288a-dae2, DCU body
  c18a112b-d2c6). AR no longer edits them. MA never edits schema/params: a
  change is an MA row with TI in Needs, after AR agrees where it crosses a block.
- Register: MA tab body `1f971016-3f72` in doc JApHYjaUESeq8tsGMGXMU5
  (Opens table and Responses table; columns ID|Decision|Severity|Impl|Needs|Description
  and Re|Date|Impl|Response). Notify per `.claude/skills/register/SKILL.md` section 2.
- gate-push: always `CCV_PUSH_BRANCHES=claude/miu-dcu-microarch-spec-664pgr`, else it
  finds no base and runs the full gate. Run detached (setsid nohup tools/bg-run.sh ...)
  and watch the real PID with kill -0; a background watcher dies at 2h, the gate does not.
- Daily sweep: trigger `trig_015gBGZ169gCKj4KbpYm5bhB`, 02:35 Pacific.
- gate-push and verify.sh now detach themselves (518cb3c3 in this branch): run
  `CCV_PUSH_BRANCHES=claude/miu-dcu-microarch-spec-664pgr tools/gate-push.sh`, then
  `tools/gate-wait.sh <job log>` as a background task (exit 3: run it again; 4: killed by a
  restart, start the job again).
- Docs edits: a `find` replace "as text" inherits the first run's formatting
  (bold/code); for whole paragraphs use a guarded markdown replace.
- A rendered copy of a tab: read with `{"kind":"view"}` and render with the
  scratchpad script render.py (strips XML to `[id h=]` lines). Rebuild it if
  the scratchpad is gone.

## Bookmarks (register revs, 2026-11-13 10:40 UTC sweep)

Conventions 19, AR 361, TI 445, OA 418, IS 194, CP 158, OI 350, RA 148, RI 82, MA 62, DA 120.

## State, 2026-11-13

- Roster: MA's session id written (commit "register: MA is ...").
- Phase 0 done: miu-arch.md section 5's stale list is fixed in the MIU tab
  (Q-18 closed, cmpl 120 bits and its field table, rcu_data field table, the
  L1 contract's RA-43 numbers 18/14, encodings, alignment, F-WIDTH, bulk
  discard with loads and the atomics exemption, the S1 model text, 8 inbound
  wakes, tier labels, the sectioned footprint) and in the DCU tab (the held note).
- First-pass draft written, marked proposed: MIU tab section "MA's Phase 1
  draft" (L1-hit budget strawmen A/B, lane-group coalescing and the contract
  eligibility rule, the 32-entry memop queue and credit, req_id 6/5 bits,
  ordering/drain/TLB/miss path, the event list for coverage bins); DCU tab
  "MA's Phase 1 draft" (64 KiB 8-way baseline, 4R tags + 4 data banks,
  D1-D3, 16 miss buffers with 4-way merge, fill path, eviction, probes).
- Grill-me raised: MA-1..MA-14 (rev 3). Notices sent to AR, OA, IS, TI.
  MA-13 is DA's (compute priority; MI/DI start).

- Agreed since: MA-1..8, MA-10..12, MA-14 (AR rev 344); MA-4 with OA (OA-408/410:
  early 1-bit no_hit on ccv_miu_ooe_cmpl_hint, TI applied on ti-ma); MA-5 per-slot
  credits (AR 345, re-affirmed 347 after the withdrawn 346): CCV_MEMOP_CREDITS = 10 a
  slot, OOE sends on the first credited slot within pipes; MIU keeps one 40-entry
  queue, each entry's arrival slot (2b) for the credit and lead pipe ctz(pipes) for
  the address pairing, and a 4-bit owed count per slot (credit return is 1 pulse a
  slot a cycle). OI-138 measured the select at 0 NGD, so the pool fallback is closed.
- MA-13 (DA): no compute priority; MI and DI start only after the grill-me with AR
  is finished, a summary is delivered to Daniel, and everything is documented.
- session-home installed (`tools/setup-session-home.py --check` matches).
- MA-15 items 1-4 and MA-5 credits landed (TI 420, eda137fa; MA 46 accepts). Entry-free
  credit return is opt-in (CCV_MIU_MEMOP_CREDIT=entry) until OI's gating merges; item 5
  (SRAM macros) is TI's next.
- Sweep 2026-11-13: merged 7 branches (TI 23, infra 23, OI dca29edc 8, +4 small); RA.md
  conflict taken RA's side. Pushed 593010a0, SCOPED PASS 24/24 (2h43m). Friday pings: 8/9
  pongs (OI none yet); AR, CP, RH rosters lack MA until they merge (sender=stale).
- OI-139/140: OOE sends on lowest credited slot (28 flops, no NGD cost); OOE model gates on
  MIU per-slot credits (dca29edc), so TI can make entry-free return the default.
- Gate note: a scoped gate on a branch carrying many merges runs nearly every
  section; check-cg/check-ngd took over 1h serial. Run gate-push under the 2h
  background limit or via tools/bg-run.sh with the max timeout.

## Open work, most urgent first

- MA 61-62 (DA in session, 2026-11-15): L1 BUILT FOR 512 KiB (8w, 512 sets, 128 B), configured
  down by sets only; supersedes MA 60. TI to set CCV_DCU_SETS 512. DCU tab Geometry updated (rev 24;
  the Capacity item's history below it still reads as history). Pinged AR for the PF-33/PF-47 status
  on -priv at 512 KiB, hit base 7/8/9: that curve is the MA-9 number.
- MA 60 (re:AR 360, superseded by 61): capacity on -priv: cm128priv 64/128/256/512 KiB = 2.133M/1.947M/1.928M/1.925M
  (128 KiB takes 8.7 of 9.7 pts); cm32priv -0.17%, S1 flat. Accepted: 64 KiB baseline, Phase 1
  resource model prices 64 and 128 KiB; area delta to Daniel in the summary (corpus sweep DA rev 95
  decides). AR 360 (2): operand CHECKs track misses/evictions (672/128/0/32 lines), cm128priv only;
  TI naming the owner; MA checks the spec's fill/return order against the cause.
- TI-444 (cc MA, no ask): -priv has no ineligible load, knob k0=k1 (cm32priv 2,253,475; cm128priv
  22.78M cold, k1 OOM-killed); PF-33/PF-47 can re-book on -priv. 128 operand CHECKs on cm128priv
  (consumer reads before load lands, no replay): TI bisecting with RCU/OOE stubs; if it lands on
  the MIU/DCU stubs it comes to MA.
- Sweep 2026-11-15 pushed 313d6c04, SCOPED PASS 24/24 (ngd 2.6h). AR 358 made coremark-derived-priv the perf baseline (MA 59 taken); TI 442
  moved benches (cm32priv/cm128priv). AR 356: stub gets MA-4 eligibility + no-hit, knob off/on
  runs pending (TI). AR re-books PF-33/PF-47 on -priv: the MA-9 merge numbers come from those.

- MA 57-58 (TI 440-441): cm32 gathers are all 25-32 lines (one per lane), PF-46 per-thread
  blocks via ordinary .global, none in IS-24's window: ports closed as a fix (no 6/8-port
  pricing in Phase 1). CP-82: coremark-derived-priv already uses the window; MA 59 asks AR to make it the
  sweep baseline (.global secondary); Phase 1 sizes on the window form.
  1-line late loads are stub effects; endorsed TI's AR 356 stub change (first pass first).

- MA 55-56 (re:TI-437, AR 353-354, TI 438): no-hit settled. CCV_LAT_MIU_NOHIT_A2 = 2 (A1 at H,
  A2 at H+1, launch H+2); CCV_LAT_L1_NOHIT = issue-to-H + 2 + HOP = 9 under PF-47 (TI applied).
  MA 55's L1_WAKE-5 withdrawn (it moved with L1_HIT).
- Phase 1 model: report max memop hold against CCV_P_TIMEOUT_MEMOP 20480 (stub's cm128 hit
  19201, TI 436, from its global head-of-line block); send the no-hit for OI-142's knob.

- Sweep 2026-11-14: merged 9 branches (+3 updates after a restart killed the first gate);
  RA.md conflicts kept RA's newest (d4d4976c). Pushed 9d3acbae, SCOPED PASS 24/24.
  For Phase 1: OI-142's l1_nohit knob waits on MA's model sending no-hits; AR 351 set
  CCV_LAT_RCU_ADDR_BASE = 1 (L1_WAKE 13, L1_CMPL 14), so PF-33's merge numbers move.

0. MA rev 51-52 (re:AR-350, TI-424): memop watchdog CCV_P_TIMEOUT_MEMOP = CCV_MEMOP_CREDITS x
   CCV_P_TIMEOUT_MEM = 20480 (spec MIU blocks a warp only on its own; rev 50's 81920 withdrawn,
   it was the stub's global head-of-line queue); TI applies
   with an 8192 control and a bounded cm128 check. Caveat for Phase 1: measure DCU miss rounds
   per 32-line memop; if >1 it joins the derive. AR-349 answer and the MA-9 close wait on
   Daniel's OK of: close MA-9 with latency moved to the timing model; partition a Phase 2
   decision priced on configurable boundary latencies; 64 KiB stays baseline.

1. MA-9 (MIU-DCU boundary): waits on AR's capacity sweep (64 vs 512 KiB, L1_HIT
   5/7/8). When it closes, the grill-me is finished.
2. Then: the summary to Daniel (all MA rows, decisions, what changed in the spec
   tabs), and confirm everything is documented. Only after that, MI and DI
   handoffs (docs/miu-impl.md, docs/dcu-impl.md).
3. MA-15 closed (MA 47-48; TI-420, a46afef7): all 5 items in, entry-free credits default.
   For DI's handoff: rtl/macro/ccv_common_sram_{1rw,1r1w}.sv; 1r1w same-cycle read of the
   written word returns OLD data (DCU forwards fills itself); W a multiple of 8 (pad tags).
   TI's a46afef7 adds tools/gate-wait.sh <job log> (exit 3 rerun, 4 killed) once merged.
4. Phase 2 (TI-445, DA ruling: a module's owner (MI/DI) sets/moves an NGD port budget where
   check-ngd times the connection (parent has a unit) and passes; MA still sets the budgets
   for unmeasured parents, the MIU/DCU block boundaries and boundary-wired ports; DA rev 120): module partition, per-port NGD budgets, index-lead schema row (after
   AR's sweep), the payload-slot macro decision.
