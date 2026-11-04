# RCU model: what it does beyond the spec, and its events

The RCU's cycle model is `sim/rcu/`. `rcu_core.{h,cpp}` holds the timing and
every structure. `rcu_block.cpp` holds the ports and oracle checks.
`rcu_test.cpp` holds the unit tests, which `sim/rcu/run-tests.sh` runs and the
gate's `rcu_unit` section runs. `CCV_RCU_IMPL=model` runs the model in both
hosts. The stub stays the default until RI reports M0 (`docs/rcu-impl.md`,
section 6). The spec is the RCU architecture doc (`docs/rcu-arch.md`, pinned
copies in `docs/design-snapshots/`). Owner: RI.

## Interims (each to be deleted when its cause lands)

| What | Why | Deleted when |
|---|---|---|
| `Config::full_row`, on in this build (`CCV_RCU_FULL_ROW=0` runs the spec's secmask) | AR-24's interim: SW, MW and RW write all four banks of the row, zero-extended above the element (RI-5, RA rev 64) | the footprint build, with the lanes' swizzle |
| call's link from ccv-sim's record (`rcu_block.cpp`, marked INTERIM) | RA-18 (imm_kind 6, OOE's pc + length) has not landed. This is the one oracle read that decides a value, and it mirrors the stub (CP-9, AR-22). | RA-18's TI/OI landing (RI-7) |

Choices the spec left open (RI-6, taken by RA rev 64):

- A kill that drops several pairing entries returns one credit a channel a cycle, from a pending count.
- A landing takes the lowest free entry.
- The FIFO pops one entry a cycle, and a restore write's pop goes first.
- A PL write with merge_en = 0 takes 0 as the old value.

## Trace events (schema/events.json, ids 33-47)

`rcu_block.cpp` packs the core's four-field events (`rcu::Ev`, which the
unit tests read) into the schema's three fields. No RCU event names a single
instruction, so uid is 0. `CCV_RCU_EVLOG=<file>` writes the core's own form, one
event a line.

| id | event | a | b | c |
|---|---|---|---|---|
| 33 | GPR_WRITE | row | lane mask | port << 4 \| section mask (LW 0, SW 1, MW 2, RW 3, RS 4) |
| 34 | PRED_WRITE | predicate row | the row's value after the write | port (PL 0, PM 1, PR 2, PC 3, PG 4) |
| 35 | BRANCH | ROB tag | branch mask (taken is != 0) | aux, below |
| 36 | GUARD_FWD | issue slot reading the guard | MIU slot whose PM write it takes | predicate row |
| 37 | RSRC_FWD | R source (0, 1) | MIU slot whose MW write it takes | row |
| 38 | BYPASS_SEL | issue slot | source port (0, 1, 2) | select \| footprint << 8; select = 1 \| lead << 1 \| (age - 4) << 3 |
| 39 | KILL_DRAIN | warp mask | epoch | KILL_DRAIN loaded |
| 40 | KILL_ACK | epoch | | |
| 41 | MIG_PAIR | warp | direction (0 demote, 1 restore) | |
| 42 | MIG_ROW_OUT | warp | migration row sent | |
| 43 | MIG_ROW_IN | warp | migration row written | |
| 44 | MIG_WAIT | warp | next row | 0 R holds R2 or RW; 1 no rcu_pca_mig credit or a stall |
| 45 | RESTORE_HOLD | warp | | |
| 46 | RESTORE_DONE | warp | | |
| 47 | IDLE | 1 idle, 0 busy | | |

**aux (BRANCH, c):** set only for ret. It is the lowest active lane's
return address (rs). The branch mask is then the active lanes whose rs
equals aux. For bra and call it is 0.

KILL_ACK is logged in the first cycle that `killQuiet()` holds after a kill:
the drain counter is 0 and no dead FIFO entry is left.

GUARD_FWD is RCU reading an MIU predicate write in the same cycle (MIU to RCU).
The schema's doc, "forwarded to an MIU slot", has the direction reversed.
RI asked TI to correct it.

## Negative controls in the unit tests

Each control prints `control <name> caught` when the model refuses its
hazard. There are seven: lane-missing, lane-early, byp-age3, guard-hazard, v60,
mig-row-order, restore-zero. The run ends in `rcu-test: PASS (0 failures)`.
