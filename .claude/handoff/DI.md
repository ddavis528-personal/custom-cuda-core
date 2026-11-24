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
1. MA-33 (1) CLOSED: full runs clean (DI-57, rev 96).
   control dcu-late-miss-port, test late-miss-retry; DI-55, MA accepted rev
   213, DCU tab rev 127 holds the rule for RTL increment B). Closes on clean
   full coremark128priv runs: stub MIU at CCV_DCU_SETS=64, model/model seeds
   1 and 2 (running in ma33: scratchpad/fx-runs.sh, logs fx-*.log). Put the
   results in DI-55 and notify MA.
2. Post-push DI row: port work status, DI-43..47/52/54 landed (54eb9217,
   a518a612, pushed at d16fc703). DI-45's no-yield control = port_nowait
   (caught by bctl_ft_one_writer); DI-47 overflow at 5 credits = credit_plus;
   DI-52: the held fill's data/index/enable are flops (wfs/wfw/wff/wfc_q,
   gfa_q) unchanged until W. MA-32 closes on 54eb9217 (MA told).
3. Sweep merge: every remote branch incl. TI's 77f7849e (DI-38 re-pins:
   slotform 52/57, vadd4 orphan 2); regen; gate-push.
4. DI-38 (1) fill-unheld kernel line; DI-38 (5) coremark128 pair watchdog
   (MI first, TI-547).
5. RTL slice 2 increment B: tag-stale marking in dcu_bctl; a relook that
   misses joins the miss-wait FIFO, retries on port 0 (DCU tab rev 127),
   with the dcu-late-miss-port control in the bench. Then btag's fill tag RF
   write (DI-25), rarb/rslot growth, dcu_bdat wdata select.
6. TI-537: one common credit module (TI); dcu_mshr's cr_q_cc05h moves to it.
   MA FYI: DRAM target may grow mshr to ~160 and bank queues to 24; build 16.
7. Later: price VICTIM_AT=2, wb_ack_delay, re-measure DI-23; watch DA rev
   134's TB read class (1000 cycles, 1 line per 8) for MA's fill sizing.
8. Gaps vs spec: probes (no MLC probe traffic), CE injection on DCU side,
   MA-25 vectors unwired.
9. Session home installed; recheck --check in the sweep. A killed gate:
   rerun with CCV_RESUME=1.

## Register bookmarks
Conventions 20, DI 96, MI 68, MA 213, AR 421, OA 502, TI 582, OI 426, DA 134,
RA 159, RI 92, IS 201, CP 160 (sweep 2026-11-24). DI tab last row DI-57 (id m8yvbw8rqgz.113801).
Sweep task trig_012HeCB5PRdC5uQzvjzTtU7g, 02:43 Pacific.
