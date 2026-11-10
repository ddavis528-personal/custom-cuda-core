<!-- design-snapshot url=https://claude.ai/artifact/4k7VrEKJG4KUgMYG1Qz8mB tab=Overview rev=68 exported=2026-11-10 status=living -->
> **Snapshot: do not edit.** Exported from *CCV RCU Architecture*, tab *Overview*, at revision 68 on 2026-11-10 ([live doc](https://claude.ai/artifact/4k7VrEKJG4KUgMYG1Qz8mB)). The live doc is the source; it is a living document, so this copy is refreshed whenever it changes. This copy pins what the repo was built against; see [README.md](README.md).

# CCV RCU Architecture

Nov 1, 2026 · @Daniel Davis

**Status: RTL-depth spec, accepted by Daniel as a first pass (2026-11-02), updated through RA rev 77 (RA-31 to RA-39) and the bank slicing of 2026-11-03; ready for the implementation agent (RI).** A copy is pinned in custom-cuda-core at `docs/design-snapshots/rcu-arch-*.md`; this doc stays the source. RI's ramp is `docs/rcu-impl.md`. It follows Daniel's direction of 2026-11-02:

- The spec defines the full cycle-accurate pipeline, so RTL can be written from it alone.
- There is no area target. The goal is synthesizability at a reasonable frequency and efficiency, under the OOE rules: 25 NGD, 12 per port side, CG-5, RST-1, DCGE 75%.
- RA owns architecture only. A separate implementation agent, with RH's help if needed, runs every measurement.

The first pass of 2026-11-01 is superseded and kept in this tab's history.

## What the RCU is

The RCU, block R (`ccv_rcu`, one instance), holds and moves the core's register state:

- **Storage:**
  - the 192 × 1,024-bit physical register file, flops, as 4 section banks of 256 bits;
  - the 48 × 32 predicate file;
  - the zero registers, GPR 255 and predicate 63, which are constants.
- **Execution:** it executes issue slot 8 (R): branches, calls, rets, predicate logic, movi and the warp collectives.
- **Operand delivery:** it reads every operand for the 32 lanes and the 4 MIU pipes, and writes every result back.
- **Migration:** it moves a warp's 17 rows to and from PCA.

It holds no warp state of its own beyond migration. Every select it uses is a pre-decoded one-hot in a flop.

## How to read this spec

| Tab | What it fixes |
| --- | --- |
| Conventions and interfaces | the cycle convention (A = issue payload cycle, a write in W is readable from W+1), naming, and every input and output field with its cycle |
| Pipeline | the stages I (A), R (A+1), RW (A+2); the op-class decode table; every op class cycle by cycle |
| Register file | the bank: rows, 10 read and 4 write ports, the split one-hot predecode, the write enables and D muxes |
| Predicate file | the 48 × 32 file, its read ports in A, A+2 and A+6, the 17 masked write ports, the guard path and the MIU forward |
| R unit and crossbar | every R op's datapath in A and A+1, the crossbar helper, and the collectives |
| Lane and memory paths | lane message assembly per owned section, the bypass tracker, the write-back descriptors, memop operands and load write-back |
| Migration | pairing, the demotion and restore engines, the stall-safe sender pattern, migration under kill |
| Done, kill and reset | done slots and timing, wakes, credits, the kill drain and ack, the reset line, the CSR tie-off, the block clock gate |
| Partition and checks | the modules, the port NGD budgets, clock enables, assertions, stub controls, and what the implementation agent measures with each exit criterion |

## The decisions this spec takes

| Decision | Value | Tab | Row |
| --- | --- | --- | --- |
| Stages | I in A (decode, guard, predicates, predecode, leads; R0/R1 source read); R in A+1 (other GPR reads, compute); RW in A+2 (R write) | Pipeline | RA-1, RA-5, RA-39 |
| Write timing | lane LW at A+6, SFU SW at A+11, load MW at its payload cycle, R RW at A+2 | Pipeline |  |
| GPR ports per bank | 10 read (L0-3, M0-2, R0-2), 4 write (LW, SW, MW, RW) | Register file | RA-6; RA-29 (a) |
| Collectives | run in the R pipe: done at A+1, written at A+2, readable at A+3, inside `CCV_LAT_COLLECTIVE` = 5; no fifth write port | R unit | RA-29 (a), (c); RA-8 |
| Row select | split one-hot predecode, 12 + 16 flops per port and slice; the zero register selects nothing | Register file |  |
| Predicate merges | masked write ports; old destination read at write time; the forwards are MIU `pred_result` into the guard and MIU's MW write through into the R0/R1 read in each bank slice | Predicate file; R unit |  |
| Lane bypass | age 4-5 (`CCV_LAT_LANE_BYP` to `CCV_LAT_LANE` − 2); no SFU bypass | Lane and memory | RA-29 (d) |
| Done slots | fixed: lane lead section k → k, SFU → 4, RCU-only → 5, collective → 6 | Done | RA-29 (b) |
| Migration ports | demotion reads R2 and D0-3; restore writes RW and PG0-3; no port of its own; 4-deep restore FIFO | Migration | RA-6, RA-17, RA-28 |
| Kill | drain everything for `KILL_DRAIN` = 15 (RA-43); ack as a level with epoch | Done | RA-14, RA-23 |
| Reset | control state only, about 1,500 flops; no PRF or payload reset | Done | A-29 |
| CSRs | none; a read-0 responder (RA-26) | Done | RA-26 |
| Size | 247,468 flops measured at assembly (RI-34: check-cg at 8fcec64b, 15 units at their instances' parameters; estimated about 242,400 from the units, RI rev 47), about 80% of them PRF rows (196,608); the block's 2% allows 4,949.4 and its modules take 2,703 (55%); CCV\_P\_PHYS\_REGS stays 192 (AR 333), no area target (Daniel, 2026-11-02); RA-11 closed (RA rev 122) | Partition | RA-11 |
| Address time | CCV\_LAT\_RCU\_ADDR\_BASE = 1: address valid at A+1, payload at A+2; RCU-internal, from the interface flop; the receiving interface flop's cycle is the link term bnd\_rx (AR row 300), counted only on the crossing, so the base and CCV\_LAT\_RCU\_ADDR stay 1 (AR row 301), and L1 wake goes 17 to 13; one more if M1 misses (RA rev 79) | Lane and memory; Partition | RA-7, RA-31 (1); PF-47 |
| Issue lead slice | OOE sends section mask, source, imm and merge use (and on R's slot the guard predicate) a cycle ahead; RCU enables each field group from it; a clear bit is asserted as a promise | Partition; Pipeline (stage IL) | RA-31 (2), RA-39 |
| Split guard read | guard row predecoded at A−1 from the lead; guard path about 16 NGD in A (about 22 without the lead) | Predicate file | RA-32 (1) |
| Select fanout | row selects copied per slice and port, 32 loads a row AND; 12,544 flops; fanout counted by check-ngd (Daniel's option (a)), enforced (TI rev 299) | Register file | RA-33 |
| CG stimulus | checked replays of ccv-skel port traces: high coremark128 and vadd, medium with two idle cycles after each, idle reset | Partition (M2) | RA-34 |
| Model first | a cycle-accurate C++ model, owned by RI, ahead of the RTL; the RTL runs lock-step against it for good (Daniel, 2026-11-02, DA tab; RTL-first lost) | Partition (M0) | RA-38 |
| Bank slices | each bank is 8 slices of one byte section across 4 lanes (192 rows × 32 bits, about 6,550 flops, 193,000 cells, 1.35 GB: inside ooe\_rob\_w's envelope), 32 in all, each with its own selects; a physical chunk is the 4 slices of 4 lanes, about 770,000 cells, 8 chunks; place and route flat, chunks keep physical partitioning open. Bank read out budget 11 (measured 8.3, 11.0 with fanout) | Register file, Partition | Daniel, 2026-11-03 |
| Early R source read | R0/R1 rows from the issue payload's `phys_src` on the wire (no lead; since RA-43 they come from R's lead\_phys\_src at A−1, in RCU flops), decoded in each bank slice and read in A into the slice's `rsrc` with an MIU write-through for L1-hit loads; `phys_src0/1` budgets from RCU's interface flop, 18.4 within 25 (no split since the boundary flops); align and compute from flops in A+1 (about 16 NGD); `CCV_LAT_RCU` stays 3 | R unit | RA-39 |

## Settled with AR (RA-1 to RA-17)

| Area | Status | Row |
| --- | --- | --- |
| Cycle convention A / A+1 / A+2 | settled | RA-1, RA-5 |
| Write ports | settled at 5; this spec needs 4, because collectives share RW. AR agreed 4 under RA-29 (a). | RA-2 |
| SFU second result on `ccv_lane_rcu_res` | settled | RA-3 |
| MIU lead fields, for CG-5 on load write-back | settled | RA-4 |
| Read ports: 10 per bank, migration on an idle R port | settled (AR re:RA-6) | RA-6 |
| `CCV_LAT_RCU_ADDR` = 1, its base; bnd\_rx(issue) counts on the crossing (AR rows 300-301) (fallback 2) | adopted (AR rev 266, PF-47); the boundary flop's +1 is bnd\_rx on the crossing, in L1\_WAKE's derive, not in this parameter (AR rows 300-301); one more if M1 misses | RA-7 |
| Collective fold 5 → 3 | RCU now meets 3; folding the contract is OA's, then Daniel's | RA-8 |
| Crossbar as an RCU sub-module | settled: `rcu_xbar`, an inner helper | RA-9 |
| Q-18: the AGU stays in MIU | settled | RA-10 |
| No area budget; floorplan | settled (Daniel, 2026-11-02); 192 rows kept (AR 333, RA rev 122) | RA-11, RA-12 |
| `dispatch_fault` deleted | settled, TI to apply | RA-13, RA-16 (e) |
| Kill drain | settled, TI to add the parameter | RA-14, RA-16 (g) |
| Ops on R | settled | RA-15 |
| Idle-R rule for migration, K = 4 | settled, OI prices it | RA-17 |

## Open questions (RA tab of the register)

| Row | Needs | Question | Status (2026-11-04) | Effect on this spec |
| --- | --- | --- | --- | --- |
| RA-16 | TI | schema and parameter changes (a)-(g) | closed (RA rev 121): (a), (d)-(g) in TI's 9894da1; (b) SFU second result and (f) C\_RECONV in a0c2f68; register-form PMOV in 8dbc152 | none |
| RA-18 | AR, OA, TI | call's link value | **settled**: `imm_kind` 6, OOE puts pc\[31:0\] + length in `imm` | R unit: call writes `imm` |
| RA-19 | IS, CP | pmov #mask gated by the issue mask | **settled**: gated (ISA invariant 10); ccv-sim merges (CP-75) | as written |
| RA-20 | IS, then TI | collective semantics | **settled as O-85** (Daniel), diagonal unballot | R unit collective rows updated |
| RA-21 | AR, TI | `rcu_miu_addr` binding and latency; fence | **settled**: bound, fixed; a fence **does** send an address message | Lane and memory: fence sends rob\_tag and active\_mask |
| RA-22 | OA | atomics' A1/A2/A3 | **settled**: ordinary P or S issues (AR-21); OI confirms done\_row values | none |
| RA-23 | AR | kill\_ack shape | **settled**: level with epoch | as written |
| RA-24 | OA | rows stable through a demotion | **settled**: yes, no snapshot | as written |
| RA-25 | OA, TI | barriers through RCU | **settled**: not in the first build (TI-42) | as written |
| RA-26 | AR | RCU CSRs | **settled**: none; answer reads 0 with done, from flops | Done: 1-entry responder |
| RA-27 | OA | RA in the register skill | **done** |  |
| RA-14 | AR | kill during migration | **settled**: discard held map, command and restore rows of killed warps, return credits | as written |
| RA-28 | AR | MIU's one-load-per-section, PCA row order and credit depth, the outstanding-migration bound | settled (AR rev 265): (a) MIU lands at most one GPR write per section a cycle; (b) PCA's rows are contiguous 0..16; (c) depth stays 4 (Q-43); (d) at most CCV\_TIER1\_WARPS migrations outstanding, the pairing queue depth | a second MW port, or a deeper restore path |
| RA-29 | AR, TI, OA | 4 write ports, fixed done slots, early collective done, SFU wake, vote/ballot `ps` | **(a), (b), (d), (e) agreed** by TI and OA; (c) legal on OA's three conditions, which the spec meets; the fold to 3 goes to Daniel with Phase 1 figures; AR agreed (a) and added the A+2 rule for every R class; one SFU issue a cycle (OA) keeps slot 4 collision-free | none |
| RA-30 | TI | the schema and stub work AR's answers left to TI | raised | none |
| RA-31 | AR, OA, TI | (1) CCV\_LAT\_RCU\_ADDR\_BASE 5 to 1; (2) a lead slice on ccv\_ooe\_rcu\_issue for per-field-group clock enables | settled: (1) 1 now, 2 if M1 misses (AR rev 266, PF-47; L1 wake 16 to 12, now 17 to 13 with the boundary flop); the params still say 5 until OI's `ooe_wake` fix, then TI reapplies; (2) contents fixed (OA rev 307), TI writes lead\_fields | Partition (The issue lead slice) |
| RA-32 | OA, TI | (1) guard-path fallback; (2) reduced-size units for check-cg / check-ngd | settled: (1) no lag-1 fallback; OOE leads R's guard physical predicate (OA rev 306); (2) no tool work: sizes are module parameters defaulting to the package (TI rev 285) | Predicate file (The split guard read); Partition (The issue lead slice) |
| RA-33 | TI, DA | is high fanout buffered or costed in check-ngd's netlist? | settled: it was not (load-blind genlib); Daniel chose (a), a per-net fanout term; enforced in check-ngd (TI rev 299), paths over 25 then on a shrinking ratchet | Register file (Select fanout); Partition (M1) |
| RA-34 | TI | stimulus for RCU's clock-gating units | settled: scenarios by activity; checked kernel-trace replay; TI adds a ccv-skel per-block port-trace dump (TI rev 286, RA rev 51) | Partition (M2) |
| RA-35 | AR | rcu-arch.md's ports, latencies and section 8 | raised | none (process) |
| RA-36 | TI | roadmap Part 0 for the RCU | **done** (TI rev 317, e60ae23): roadmap RCU status; `rcu_miu_width` deleted, Q-18 closed; (d) goes to OI with ADDR\_BASE = 1 | none (process) |
| RA-37, RA-38 | TI, OA | repo support for RI: gate-scope map, model hook (`makeRcu`, `CCV_RCU_IMPL`), `check-rcu-unit`, `job_rcu_rtl`, `CCV_RCU_RTL` | agreed (TI rev 290, OA rev 308); built: makeRcu with `CCV_RCU_IMPL`, `check-rcu-unit`, the gate-scope map (39a1861). RI met M0 with the model (5968894, RI rev 5), **accepted by RA** (rev 68); TI makes the model the default | Partition (M0); rcu-impl.md |
| RA-39 | OA, TI, AR | early R source read: R0/R1 read in A from the payload's phys\_src | (a) taken by OA (revs 328-329). (b) as first written (R0/R1 rows on R's lead) withdrawn: OI-115 measured the lead mux in select at 38.8 NGD against `ooe_sched`'s 30.5. Taken instead, OA rev 336 on RA's price (RA rev 70): option (2), the read from the payload's `phys_src` on the wire into `rsrc` in each slice, the MIU forward a bank-level write-through, budgets RCU in 19 and OOE out 6 (moved 1 at OA rev 337 after RI measured 18.4). (c) `lead_r_src0/1` withdrawn: TI takes them out of the schema and stubs (landed at TI rev 309). (d) lapses (OA rev 336). Closed (RA rev 74). The split lapsed with the boundary flops (Daniel 2026-11-05, AR rev 285): the read now runs 18.4 from RCU's interface flop within its own 25. | R unit (Early R source read); Register file; Pipeline |

## For Daniel

Daniel accepted the spec as a first pass (2026-11-02) and answered RA's questions:

- **Clock gating.** DCGE is a gate's share of enabled cycles in which the value changes, so a payload loaded with new data each cycle is fine. The risk is enabling field groups an op does not use (Partition tab, rewritten).
- **Parity and ECC.** Not in the first version. End-to-end parity is PF-48 in `docs/perf-register.md`.
- **Storage.** Flops for the first version. A latch-based PRF is PF-49.
- **Scan.** The PRF is fully scanned, handled transparently by synthesis. `te` is needed only on the block's one coded clock gate, `ccv_common_clk`, and is stitched into every inferred gate.
- **Implementation session.** Daniel spins it up when ready.
- **Fanout.** check-ngd counts it per net (option (a), 2026-11-02); RCU copies its selects to suit (Register file tab).
- **Floorplan.** Nothing is baked in until bottom-up gate counts exist; the spec assumes no placement.

**Block boundaries (Daniel, 2026-11-05; TI rev 321; AR rev 285; RA rev 77).** Every block boundary has a flop on each side, built by the interface module. A and every channel's payload cycle T are counted from the RCU's interface flop (Conventions tab), and RCU's inputs start at 0 NGD with their whole 25. RCU's internal stages are unchanged. The contract moves by one cycle where a receiver's write used to precede its first flop: `CCV_LAT_LANE` 8 and `CCV_LAT_SFU` 13, so LW lands at A+7 and SW at A+12, lane and SFU done one cycle later, and `KILL_DRAIN` is 16. `CCV_LAT_RCU` stays 3, `CCV_LAT_COLLECTIVE` 5, and bypass latencies are unchanged. The lane-bypass compare window grows by one age. Since RA rev 95 lane\_rcu\_res's end at RCU is zero-cycle (bnd\_rx 0), so CCV\_LAT\_LANE is 7 and CCV\_LAT\_SFU 12: LW lands at A+6 and SW at A+11, and the bypass window is back to ages 4-5. KILL\_DRAIN stayed 16 while the issue end was flopped. Zero-cycle ooe\_rcu\_issue (RA-43, approved by RA under DA 115, 2026-11-08; AR 329): OOE sends lead copies at A−1 of every field RCU cannot meet 12 from (Partition tab, lead slice), so both sides meet 12 without the flop: RCU's worst issue in-path is 10.9 (RI rev 47), and OOE drives from its issue register at 0, with gnt in 10.2 and no OOE cycle (OA-390). The gain is S1 3.48% and cm32 1.98% (J11). AR checked the derives: KILL\_DRAIN 16 to 15, L1\_CMPL 19 to 18, and the issue channel's credit depth stays 4: 4 + 2(N + bnd\_rx) with both at 0. RA-41's credit-on-receipt had already taken bnd\_rx out of that loop, so AR 329's −2 is against a flopped end without it (TI 382, RA rev 114). LAT\_LANE 7, LAT\_SFU 12, L1\_WAKE 17 and L1\_MISS\_WAKE 1 are unchanged. V-35's done comes a cycle sooner after issue. There is no credit-on-receipt on this channel; RA-41 keeps it for miu\_rcu\_data only. The cost is about 595 RCU lead-capture flops against the block's 2% (about 4,850), less the boundary flops the end removes, and gated OOE flops (OA priced 345 before RA rev 114 narrowed the S0-S3 copies to 32 bits and made R's imm a move).

**Phase 2 figures (RI, 2026-11-05; RI rev 8).** `rcu_bank_slice`: 1,324 flops at 32 rows, clock gating clean (lowest DCGE 91%/94%); at 192 rows flop to flop 17.7 NGD, read out 11.0, MW data to flops 10.5, and the RA-39 payload read 18.4 from the RCU port (from the interface flop since the boundary flops, AR rev 285; it was fitted after a 1 NGD budget move from OOE, OA rev 337). `rcu_r` with `rcu_xbar`: 2,626 flops, clock gating clean (6 gates, DCGE 99-100%), 23.9 NGD flop to flop; its bench passes 142,737 values with the alignment and ret-low controls caught. The 192-row clock-gating harness is TI's (RI-10).

Still open for Daniel: the collective latency fold from 5 to 3, after Phase 1 (RA-29 (c), RA-8).
