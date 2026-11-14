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
- Daily sweep: trigger `trig_015gBGZ169gCKj4KbpYm5bhB`, 02:35 Pacific. Until 518cb3c3 (make-release
  detach exits 5) is in this branch, run it as `CCV_FOREGROUND=1 tools/daily-sweep.sh` (TI 429:
  a sweep begun before a46afef7 otherwise pushes its merge ungated).
- Docs edits: a `find` replace "as text" inherits the first run's formatting
  (bold/code); for whole paragraphs use a guarded markdown replace.
- A rendered copy of a tab: read with `{"kind":"view"}` and render with the
  scratchpad script render.py (strips XML to `[id h=]` lines). Rebuild it if
  the scratchpad is gone.

## Bookmarks (register revs, 2026-11-13 10:40 UTC sweep)

Conventions 19, AR 350, TI 424, OA 414, IS 193, CP 157, OI 341, RA 136,
RI 70, MA 54, DA 119. TI 429 read. RA 141 read (item 6 settled MA 54: one GPR load a cycle at position 0). Specs doc: MIU tab rev 104, DCU tab rev 23.

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
4. Phase 2: module partition, per-port NGD budgets, index-lead schema row (after
   AR's sweep), the payload-slot macro decision.
