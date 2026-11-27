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
1. MA-34 (MA rev 220/222, DCU tab rev 147/148): params landed (TI c0883a36,
   merged). Model done (078f5069, af59fee3 on main): per-bank offers, CHECKs
   id bank == line bank and one new miss a bank a D2; a loser's same-D2 miss
   waits and retries on port 0 (control dcu-bank-two-miss); dcu-late-miss-port
   retired (DI-61, MA rev 222). Next: check the model's cross-bank MLC pick and
   retry grant vs dcu_mpick's spec; kernel sweep CCV_DCU_IMPL=model (never
   beside a gate); then RTL: dcu_mshr per bank, dcu_mpick, bctl queue req_id
   8; then the dcu_fill 4-buffer recheck under gtw.
2. TI-590 (TI rev 592), low: re-measure dcu=model IMPL_PINS rows on ti-rp's
   params (held-wait demote dcu=model 862, pair 876; UE rows); the vadd4-swap
   rows are gone. Answer in the DI tab.
3. DI-38 (1) fill-unheld kernel line; DI-38 (5) coremark128 pair watchdog
   (MI first, TI-547).
4. RTL slice 2 increment B: tag-stale marking in dcu_bctl; a relook that
   misses joins the miss-wait FIFO, retries on port 0 (DCU tab rev 127),
   (dcu-late-miss-port retired by MA rev 222). Then btag's fill tag RF
   write (DI-25), rarb/rslot growth, dcu_bdat wdata select.
5. TI-537: one common credit module (TI); dcu_mshr's cr_q_cc05h moves to it.
6. Later: price VICTIM_AT=2, wb_ack_delay, re-measure DI-23; watch DA rev
   134's TB read class (1000 cycles, 1 line per 8) for MA's fill sizing.
7. Gaps vs spec: probes (no MLC probe traffic), CE injection on DCU side,
   MA-25 vectors unwired.
8. Merges: criss-cross history; ort can hang (timeout 60), resolve refuses
   >8 bases: then read-tree -m -u <newest base> HEAD <theirs>, merge-index,
   commit-tree with both parents. Session home installed; --check in sweep.

## Status
- Pushed 5a4a865c: OA-508 merge of 7f5195a4 (DI-62, rev 101, OA notified), on
  724beb26 (TI c0883a36 + MA-34 model, SCOPED PASS 28/28). Before: f2accd75, sweep merge to
  11-27.
- OI-225 -> DI-63 (rev 102; MA, OI notified): p1 ignores MA-27 drop; fix is MA's (dcu_p1.cpp). Repro: build/oracle/coremark32priv, CCV_MIU_IMPL=model CCV_DCU_IMPL=p1 seed 1, 3000 cycles.
- Pongs 11-27: all answered; OI and RH sender=stale (their roster); tell
  Daniel if still stale next Friday.

## Register bookmarks
Conventions 20, DI 102, MI 74, MA 222, AR 426, OA 506, TI 594, OI 427, DA 136,
RA 159, RI 93, IS 201, CP 160 (sweep 2026-11-27). DI tab last row DI-63 (id m8yvbw8rqgz.120139).
Sweep task trig_012HeCB5PRdC5uQzvjzTtU7g, 02:43 Pacific.
