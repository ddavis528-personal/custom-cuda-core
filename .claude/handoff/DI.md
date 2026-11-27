# DI handoff (DCU implementation)

Session `session_01QPk2jz5TVESyWMKVKjqqEA`, branch `ccr-5e4d6c70-n6402z`
(core and compiler). Start: `docs/dcu-impl.md` (MA's handoff), then
`docs/miu-impl.md` sections 1, 2, 4, 5, 8, 9 read as DI/DCU.

## Working rules beyond CLAUDE.md
- DI writes only the DI tab (node `1ea5d5b3-6e9c`) and mints DI-n.
- Never edit TI's files (schema, params, tools, sim/skel stubs, kernel.cpp's
  makeDcu, blocks.list, rtl/top). Ask with a DI row, TI in Needs.
- `sim/dcu/dcu_p1.cpp` is MA's resource model: read, never edit.
- Model layout (RCU pattern): `sim/dcu/dcu_core.{h,cpp}` (no skeleton
  deps, unit-tested by `sim/dcu/dcu_test.cpp`, `sim/dcu/run-tests.sh`),
  `sim/dcu/dcu_block.cpp` (ports only).
- DI-1 landed (TI-497, cb8ca9be, merged here): CCV_DCU_IMPL=model and
  check-dcu-unit are real; the local hook patch is retired.
- No dates on tasks; no model identifiers in anything pushed.
- Merge a blocker the moment it lands on a working branch, never waiting
  for the daily sweep (Daniel). Ask its owner to move it up (a DI row and a
  notice), and set an hourly check while it is pending.

## Timing frame (DCU-local; checked against the MIU tab's L1-hit budget)
- L = lead (valid) at DCU = H+2; P = payload lands (Stub::has) = H+3.
- Response valid launches at P + (CCV_LAT_L1_HIT - 5): P+2 at 7, P+3 at 8 (C),
  P+4 at 9 (B). A mispredict (C) re-reads as a bank-conflict loser: due + 2
  at the earliest (DI-2).
- A lookup's data-bank access starts at D (P under A and C, P+1 under B) and
  each bank is arbitrated in work(D) from what DCU holds then; the response
  launches at D+2 (A) or D+3 (B, C).

- Memory: 15 GB, 4 cores. Never run a coremark ccv-skel (up to 5 GB each)
  beside a gate: it OOM-killed check-cg once. Gates take ~3.5 h (ngd, cg).
- check-cg --unit never applies the module budget (max(2% flops, 7)); use
  scratchpad/cgbudget.py <unit> (execs check-cg with the budget printed).
- Scratch worktrees (never push from them): scratchpad/m0w (old port work),
  scratchpad/ma33 (MA-33 debug instrumentation: g_dbg_site, DBG prints).

## Open work, most urgent first
1. MA-34 (MA rev 220, DCU tab rev 147; DI-58 accepted): dcu_mshr 8 banks x 16,
   req_id {bank, entry}, new dcu_mpick (cross-bank pick by stamp behind
   writebacks, DI-35's retry grant, ccv_dcu_mlc_req's flops), bctl queue req_id
   8, recheck dcu_fill's 4 buffers under gtw. New CHECKs: an id's bank is its
   line's bank; one new miss per bank per cycle. Model first, then RTL.
   Blocked on TI's params (ti-rp 1183b16c: W_REQ_MIU_DCU 8, W_REQ_DCU_MLC 7,
   MSHRs 8x16) landing on a working branch; TI-rp's gate waits on MI's
   miu_ids bench (TI-590 (1)). DI's interim (80071ac5, NE = per-bank 16) and
   bench width fix 79203045 (gate-scratch/DI-rp) ride TI's gate. Merge at once.
2. OA-505 answered (DI-60, rev 99): dcu_bctl cold check-cg peak 371 MiB.
3. TI-590 (TI rev 592), low: re-measure dcu=model IMPL_PINS rows on ti-rp's
   params (held-wait demote dcu=model 862, pair 876; UE rows); the vadd4-swap
   rows are gone. Answer in the DI tab.
4. DI-38 (1) fill-unheld kernel line; DI-38 (5) coremark128 pair watchdog
   (MI first, TI-547).
5. RTL slice 2 increment B: tag-stale marking in dcu_bctl; a relook that
   misses joins the miss-wait FIFO, retries on port 0 (DCU tab rev 127),
   with the dcu-late-miss-port control in the bench. Then btag's fill tag RF
   write (DI-25), rarb/rslot growth, dcu_bdat wdata select.
6. TI-537: one common credit module (TI); dcu_mshr's cr_q_cc05h moves to it.
7. Later: price VICTIM_AT=2, wb_ack_delay, re-measure DI-23; watch DA rev
   134's TB read class (1000 cycles, 1 line per 8) for MA's fill sizing.
8. Gaps vs spec: probes (no MLC probe traffic), CE injection on DCU side,
   MA-25 vectors unwired.
9. Merges: criss-cross history; ort can hang (timeout 60), resolve refuses
   >8 bases: then read-tree -m -u <newest base> HEAD <theirs>, merge-index,
   commit-tree with both parents. Session home installed; --check in sweep.

## Status
- Pushed 987567fd (SCOPED PASS 28/28): sweep merge of every remote branch to
  11-27, incl. TI's heavy-units miu_form. MA-33 closed (DI-57).

## Register bookmarks
Conventions 20, DI 99, MI 70, MA 220, AR 423, OA 505, TI 592, OI 427, DA 136,
RA 159, RI 92, IS 201, CP 160 (sweep 2026-11-26). DI tab last row DI-60 (id m8yvbw8rqgz.116565).
Sweep task trig_012HeCB5PRdC5uQzvjzTtU7g, 02:43 Pacific.
