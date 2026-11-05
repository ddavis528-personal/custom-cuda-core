<!-- design-snapshot url=https://claude.ai/artifact/4k7VrEKJG4KUgMYG1Qz8mB tab=Partition_and_checks rev=43 exported=2026-11-05 status=living -->
> **Snapshot: do not edit.** Exported from *CCV RCU Architecture*, tab *Partition and checks*, at revision 43 on 2026-11-05 ([live doc](https://claude.ai/artifact/4k7VrEKJG4KUgMYG1Qz8mB)). The live doc is the source; it is a living document, so this copy is refreshed whenever it changes. This copy pins what the repo was built against; see [README.md](README.md).

# Partition and checks

This tab is the implementation's floor plan: the modules, which flops each owns, the NGD budget of every port that needs one, where each clock enable comes from, the checks, and what the implementation agent measures before it calls a module done.

## Partition principles

Three rules from `docs/rtl-coding-style.md` decide the cuts:

- **No path straight through a module.** A combinational path from a module's input to its output is forbidden, so a module cannot sit between the issue payload and another module in cycle A.
- **No logic in a parent between its children.**
- **CG-5.** Every enable comes from the module's own flops.

So:

1. **Every module decodes the issue payload itself.** The raw `ooe_rcu_issue_s*_payload` and the flopped valids are wired from the block's ports to every module that acts in A. Each module decodes the op-class fields it needs, from the generated op-class table (Pipeline tab). The duplicated decode is a few hundred gates per module, against a through-path that is illegal.
2. **A predicate read in A and its consumer share a module.** The guard read, `active`, the branch outcome and the R predicate sources all depend on a predicate read in A, so they live with the predicate file, in `rcu_pred`.
3. **A register file is the only module whose outputs are combinational.** Each read port's AND-OR is driven from the file's own predecode flops. The receiving module's budget pays for the rest of the path.
4. **Write data enters a register file directly from the block port or from the writer's flops.** Steering such as MW's position shift is inside the file.

## Modules

| Module | Inst | Holds | Flops (approx.) |
| --- | --- | --- | --- |
| `ccv_rcu` | 1 | the block top: `ccv_common_clk`, children, wires only | 0 |
| `rcu_bank_slice #(K, J)` | 32 | 192 rows × 32 bits, byte section K of lanes 4J to 4J+3; its own predecode flops for every port but R0/R1 (L0-3, M0-2, R2, LW/SW/MW/RW: 12 × 28); R0/R1's `rsrc`, 64 flops (they decode the payload's rows on the wire, RA-39); RW's A+1/A+2 copy; MW position shift; the zero-register no-select. Bank K is slices (K, 0..7); physical chunk J is slices (0..3, J) (Register file tab, Slices) | about 6,550 each, 209,600 in all |
| `rcu_pred` | 1 | 48 × 32 predicate file; every predicate read and write port; guard, MIU `pred_result` forward, `active`, branch outcome, `lead_br_*` (`(* keep *)`), `br_*_a`, `rpsrc_a`, `active_a[s]` | 2,500 |
| `rcu_r` (+ `rcu_xbar` helper) | 1 | R pipe A+1/A+2: `r_a`, `rlow_a`, `rres_a1`, `rpres_a1`; RW data merge and steer; done slots 5 and 6 (`done_v_q`, tags, `done_b*_q`, `done_aux_q`) | 2,300 |
| `rcu_lanes` | 1 | section ownership; 32 `rcu_lane_ops` payload, valid and lead flops; bypass tracker; `lwb_d[0..3]`, `swb_d`; done slots 0-4; `rcu_lane_ops` wakes | 12,900 |
| `rcu_mem` | 1 | memop operand assembly; 4 `rcu_miu_addr` payloads (3,111 b each); MIU lead predecode flops (about 110 per slot); `rcu_miu_addr_wake` | 12,950 |
| `rcu_mig` | 1 | Migration tab | 6,300 |
| `rcu_kill` | 1 | kill drain and ack; `rcu_ooe_done_wake`; `rcu_idle_q`; credit-return flops for issue, lane-result and MIU-data slots; CSR tie-offs | 60 |
| **Total** |  |  | **about 246,000**, 80% of it PRF rows |

Each sequential module flops `rst_n` once for itself (RST-1). Reset values: Done, kill and reset tab.

## Port NGD budgets (`<module>.ngd.json`)

RA writes these files with the implementation. A block input starts at its interface flop with 0 NGD (every block boundary has a flop on each side; Conventions tab), so a module input fed from a block port has the whole 25 to spend, its fanout across the RCU included. The 12-a-side default applies only between modules inside the RCU; no NGD is budgeted across a block boundary. Ports not listed keep the default 12 a side.

| Path | Driver side | Receiver side | Total | Notes |
| --- | --- | --- | --- | --- |
| issue lead `lead_guard_pred` → `pred` `psel` flops (A−1); `psel` → 48:1 read → negate, forward → `lead_br_*` flops (A) | block port, 2 | `pred` in: 12 | 14 (A−1); about 16 in A | the split guard read (RA-32, Predicate file tab): the guard's row is predecoded at A−1 from the issue lead, so the A path starts at flops. Without the guard lead it is the old single-cycle path, pred in 23, about 22, still the tightest in RCU |
| issue payload → `bank` read predecode flops | 2 | `bank` in: 14 | 16 | op-class decode 5, owner 3, predecode 3, port mux 2 |
| issue payload → `lanes` payload, bypass flops | 2 | `lanes` in: 18 | 20 | ownership, the age 4-6 compare, immediate substitution |
| issue payload → `mem` payload flops | 2 | `mem` in: 14 | 16 |  |
| issue payload → `mig` `dm_v_q`, `rs_v_a1` | 2 | `mig` in: 12 | 14 | the R2/RW-free decode |
| OOE `ccv_ooe_rcu_issue` R slot `phys_src0/1` → `bank` R0-R1 read (in A) → the slice's `rsrc`; `bank` R2 read (in A+1) → `r` `old` | `phys_src0/1` from the interface flop at 0 (RA-39's 19/6 split lapsed with the boundary flops, AR rev 285); `bank` out: 11 for R2 (measured 11.0 with the fanout term, RI-9) | `rcu_bank_slice` in: 25 on `phys_src0/1` from the interface flop (fanout to 32 slices 2.5, decode, read, MIU write-through: measured 18.4, into `rsrc`); `r` in: 14 for R2 | 25 | alignment 2 into flops; R's compute starts at flops in A+1, about 16 for the register-index shfl and ret, alignment of rsrc included (R unit tab, early R source read, RA-39) |
| rcu\_r pr\_orow (phys\_pred\_old\_dst carried to A+1) → pred's PR merge | 0 (a flop) | pred in: per rcu\_pred.ngd.json; pred's dq out required 18 (merge path, migration 7) | ≤ 25 | RCU-internal port, added at assembly (RI-14 (5), RA rev 81); OL/OR/OC stay inside rcu\_pred; gt/pdt/br arrive at 0, their decode timed in pred |
| `bank` L0-L3 read → `lanes` payload | 11 | 6 | 17 |  |
| `bank` M0-M2 read → `mem` payload | 11 | 10 | 21 | operand assembly |
| `bank` R2 read → `mig` `dm_pay` | 11 | 3 | 14 |  |
| `pred` OL/OR/OC/D reads → `lanes`, `r`, `mig` | `pred` out: 5 | 8 | 13 |  |
| `lane_rcu_res` → `bank` LW/SW D | 2 | `bank` in: 8 | 10 | AND-OR with hold |
| `miu_rcu_data` → `bank` MW D | 2 | `bank` in: 12 | 14 | slot select 2, shift 2, mask 1, D 3 |
| `miu_rcu_data` → `pred` guard forward | 2 | `pred` in: 23 | 25 | joins the split guard path after the 48:1 read; the forward mux is inside its about 16 |
| `r` `rres_a1` → `bank` RW D | `r` out: 8 | `bank` in: 5 | 13 | merge and steer in A+2 |
| `mig` `rs_f` → `bank` RW D | `mig` out: 3 | 5 | 8 |  |
| `mig` R2 row request → `bank` R2 predecode | `mig` out: 8 | `bank` in: 14 | 22 | without the stall and R2-busy terms (Migration tab); the bank applies its own R2 decode |
| every module's busy OR → `kill` `rcu_idle_q` | out: 5 | `kill` in: 5 | 10 |  |

Every register that drives a block output and something else is split into NGD-7 `(* keep *)` copies: the lead flops, the done valid, the lane-op and address valids, `dm_v_q` against its own use.

## Clock enables (CG-1 to CG-5)

DCGE (CG-3) is a clock gate's share of enabled cycles in which the gated value actually changes. A register loaded every cycle with new data scores high. The risk is an enable that fires while the value stays the same: a field reloaded with the value it already holds, or loaded with zeros or don't-cares it already holds because the op does not use it. A register clocked every cycle without a gate must change in 75% of cycles (CG-4).

| Register group | Enable (own flops) | Where DCGE could fall | Remedy |
| --- | --- | --- | --- |
| PRF row × slice (32 flops) | `row_en` from the write ports' predecode flops | a write of the value already held, which is rare; a lane-masked write still changes the row | none expected |
| predicate row (32) | the same, per predicate | a merge that leaves all bits unchanged, such as vote writing an unchanged result | none expected; measure |
| `rcu_lane_ops` payload, per copy | the flopped issue valid of any lane op | **field groups an op does not use**: unowned sections, an immediate op's operand fields, a full-mask op's merge data, the bypass selects of an op with no bypass | per-section and per-field-group enables; they need the op's section mask and operand use a cycle early (RA-31 (2)) |
| `rcu_miu_addr` payload, per slot | that pipe's flopped address valid | operand fields a memop does not use (a fence; a store's data on a load) | per-field-group enables, same lead |
| `lwb_d`, `swb_d`, bypass history | the stage's own valid | a shift stage of the same descriptor | none expected |
| `rres_a1`, `rpres_a1`, `r_a` | `r_v_a`, `r_v_a1` | the GPR result on a predicate-only R op, and the reverse | split the enables by write kind (GPR, predicate, branch-only), from `r_a`'s decoded class |
| migration arrays | land, launch, send (Migration tab) | none: each load is a new message | none |
| valids, credits, wakes, counters | ungated, written every cycle | inside the 2% / 8-flop allowance | count them |

The lane-message and address payloads are the groups to watch. In both, an enable that loads every field group for every op wastes clocks on the fields the op does not use.

The remedies, in order:

1. Enable each field group only when the op uses it, from a lead slice: the op's section mask and operand-use bits a cycle ahead (RA-31 (2)).
2. Where no lead exists, keep the group's enable and accept the field's DCGE. The implementation agent measures it.
3. Only if both fail: a waiver request to Daniel, with the measured numbers.

### The issue lead slice (RA-31, AR rev 266, OA rev 307)

OOE sends a lead slice on every `ccv_ooe_rcu_issue` slot. It is driven from a flop beside `valid` in A−1, so it arrives a cycle ahead of the payload in A. Cont slots carry zero. TI writes the fields into the schema as `lead_fields`. OOE builds every bit from the selected RS entry's static fields, so the slice carries no opcode and RCU decodes none from it.

| Field | Width | Slots | Meaning (OA's definitions) | RCU's use |
| --- | --- | --- | --- | --- |
| `lead_sec_mask` | CCV\_SECTIONS | all | the op's section footprint | per-section enable of the lane-op payload sections, the bypass selects and the address data sections |
| `lead_src_used[i]` | 3 | all | `src_valid[i]` | enable of operand field group i (lane-op source i; on an address slot, base, index or store data) |
| `lead_imm_used` | 1 | all | `imm_kind` not none, which covers every value OOE substitutes into imm | enable of the imm field group |
| `lead_merge_used` | 1 | all | the write merges, so the old destination is read | enable of the merge-data (old dst) group and its read select |
| `lead_guard_used` | 1 | R slot | the guard is not the always-true predicate | enable of the split guard read's `psel` flops |
| `lead_guard_pred` | CCV\_P\_W\_PHYS\_PRED | R slot | the guard's renamed physical predicate; its negate stays in the payload | the A−1 predecode of the split guard read (Predicate file tab) |

**Timing in RCU.**

- Each module that owns a field group registers the bits it uses, with the issue valid, into its own copy of `iss_lead_q[s]` (Conventions tab) at A−1's edge. These are RCU's own flops, as CG-5 requires.
- A group's enable at A's edge is `iss_v_q[s] & iss_lead_q[s][bit]`.
- A group that loads after A carries the bit forward with the op. The bit is piped beside the op's valid in the same stage flops, and it is never recomputed from the payload.
- `iss_lead_q[s]` loads every issued cycle and is counted against the module's allowance for ungated flops, about 81 per module that takes all nine slots.

**Superset rule.**

- A set bit may load a group the op then does not use. That costs DCGE, not correctness.
- A clear bit is a promise. RCU asserts at A, for every valid slot, that what the payload uses is a subset of what the lead promised: `src` operands, a non-none imm, merge, sections and guard.
- Negative control `lead-src-clear` (TI's name, TI rev 288; this spec called it lead-promise): it clears one lead bit of an op that uses the group, and it must fail. It is in the controls list; the stub already refuses a broken promise, and the model and RTL must too.
- The imm group's DCGE is the known weak spot. `imm_kind` literal does not say whether the op reads the literal (AR rev 266), so imm loads for every literal op. If the implementation measures that group under 75%, the remedy is a DEC bit through OA, not a waiver.

**Contingencies.**

- If OI's select-path NGD does not fit the grant mux, OOE sends the same bits from a registered copy of the entry (OA, NGD-7's copy). Nothing changes on RCU's side.
- If OOE does not send the slice at all, every group falls back to `issue_v_q` and the implementation measures DCGE (list item 2 above).

**Address time.** `CCV_LAT_RCU_ADDR_BASE` = 1 is adopted (PF-47). TI's first application failed the gate in OI's RTL, so the params still say 5 until OI fixes `ooe_wake`'s depth and the `no-msd` control's stimulus (TI rev 288); TI then reapplies it. RCU's spec, model and RTL are built to 1 regardless. The address valid leaves at A's edge and the payload at A+1's edge. If M1 misses, RA returns with 2 and one pipeline stage is added in `_mem`. `CCV_LAT_L1_WAKE` goes from 17 to 13. The boundary flops leave RCU's address time unchanged: valid and payload as above, counted from the interface flop. The receiving interface flop's cycle is the link term bnd\_rx, not part of the base (AR row 300): TI reapplies the base as 1, and the derived CCV\_LAT\_RCU\_ADDR is 2. Likewise LANE\_BASE stays 7 and the SFU base 12, with bnd\_rx making CCV\_LAT\_LANE 8 and CCV\_LAT\_SFU 13; a zero-cycle receiving end is bnd\_rx 0.

**Reduced units (RA-32 (2), TI rev 285).** Every RCU size is a module parameter that defaults to the `ccv_params_pkg` value, for example `parameter int ROWS = ccv_params_pkg::CCV_P_PHYS_REGS`. A reduced check-cg / check-ngd unit sets it in `cg-units.json`, as in `{"name": "rcu_bank_slice_r32", "params": {"ROWS": 32}}`. The full-size unit stays for each module's exit, and a full-size unit that peaks over 2 GB goes on `tools/heavy-units.json`. Yosys elaborates a module at its defaults when it reads the file, before the unit's parameters apply, so a reduced unit first pays its module's full-size elaboration: a 64,000-cell stand-in took 4.7 GB with whole-bank defaults and 449 MiB with small ones (2026-11-03). No module's default may therefore be larger than its full-size unit; a slice meets that, since its full size is one unit.

## Assertions and checkers

In each module (sim-only, `ifdef CCV_ASSERT`):

- **bank:**
  - Never two write ports on one row and lane in one cycle.
  - No write selects row 255 (A-64, `dirty-zero`).
  - MW: at most one slot per bank per cycle (RA-28).
- **pred:**
  - No write to predicate 63.
  - The guard forward fires only on a MIU `pred_we` to the guard's row in A.
- **lanes:**
  - The lanes' `sec_valid` equals the descriptor's write flags.
  - Bypass select only at age 4-6.
  - Done slot k valid only with `lwb_d[k]` age 5.
- **r:** one R op per cycle; slot 5 fields zero for non-branch ops.
- **mig:** Migration tab list.
- **kill:** ack only with `kill_drain` = 0; ack epoch equals the last kill's.

Q-53 checkers owed by RCU's RTL:

- The **arrival-cycle checker** on `rcu_ooe_done` per class: valid at A+1, A+7 or A+12 after the issue that names its `rob_tag`.
- **A-35's two isolation assertions.** Every lane of a newly allocated row is written by a lane result, the merge path or the copy before any read of it. This is a bind module with a 192 × 32 shadow, cleared by OOE's allocation, which it observes through the SV top. The companion assertion now reads: a launched warp's map is all zero registers (A-64).
- The **A-45 pairing checker**: every launch pairs one map with one command of the same warp and direction.

## Stub controls that must keep failing

The model replaces the stub in both hosts (`sim/skel/blocks.list`, selected by TI's makeRcu hook, RA-38), and the RTL replaces `ccv_rcu`'s DPI shim in the SV top. Every `--break` control below must fail with the model in place, and still fail with the RTL in place (`tools/check-kernel.sh`, and `tools/check-sv-hosted.sh` for the SV top):

`ignore-mask`, `movi-in-lane`, `lead-corrupt`, `slot-field-aux`, `done-row`, `rcu-done-pool`, `no-rcu-bypass`, `wrong-merge`, `copy-from-new`, `mig-row-order`, `arch-pred-srcs`, `pdata-guard`, `dirty-zero`, `scalar-base`, `no-lane-bypass`, `late-copy`, `drop-pred-copy`, `drop-pred-data`, `attr-coll-as-rcu`, `conflate-pred`, `corrupt-echo`, `late-lead`, `lead-src-clear` (new with the issue lead slice, RA-31; TI rev 288), and `drop-src-valid`, which now expects the lead's refusals too.

Two of these change meaning with this spec; TI and OA agreed the new meanings under RA-29, and TI updates the controls with the RTL:

- `rcu-done-pool` (lowest-free versus a fixed slot).
- `attr-coll-as-rcu` (collectives now on slot 6 at RCU timing).

## What the implementation agent measures, and the exit criteria

RA does not run these. The implementation agent (RI; handoff `docs/rcu-impl.md`) does, with RH's help if needed, and reports each against its criterion. **Model first (Daniel, 2026-11-02; DA tab):** a cycle-accurate C++ model, owned by RI, is in place ahead of the RTL, and the RTL is verified against it in lock-step for good. Cycle-accurate means at the block's interfaces and in its events: every output and input on this spec's cycle, every register-file write, done, branch outcome, kill and migration step when it happens, and every hazard, stall and idle period this spec implies. It does not clone the RTL: its inside is RI's to organise, with no modules, predecode flops or stage registers it does not need for that timing. RTL modules are verified by their own benches and assertions; RTL and model meet in lock-step at the block's ports and events. M0 comes before every RTL measure.

| # | Measure | How | Exit criterion |
| --- | --- | --- | --- |
| M0 | The cycle-accurate C++ model | tools/check-kernel.sh and tools/check-sv-hosted.sh with the model as RCU in both hosts; the model's unit tests; then block lock-step of the RTL against it (every output and event, every cycle) | every kernel passes against ccv-sim's oracle and every control above fails, with the model; every output and event on this spec's cycle, hazards and stalls included; kernel cycles reported against the stub's. From then on, the assembled block runs lock-step with no mismatch |
| M1 | NGD per module and per port | `tools/check-ngd.py` at full size, plus each module's unit | every path ≤ 25, every port within its `.ngd.json`, all with check-ngd's fanout term counted (RA-33, Daniel's option (a)); the `pred` guard path in A ≤ 16 with the guard lead (≤ 23 without it) |
| M2 | Clock gating | `tools/check-cg.py`: idle, medium and high scenarios (RA-34), driven by checked replays of ccv-skel port traces: high = coremark128 and vadd, medium = the same with two idle cycles after each, idle = reset and no issue; DCGE counts only from traces made after the stub's RA-19 merge fix | each module within its 2% / 8-flop allowance; block within 2% per instance, which also carries every RCU end's ungated boundary lead slice, in and out (835: ooe\_rcu\_issue 144 and miu\_rcu\_data 204 in, rcu\_ooe\_done 231 and rcu\_lane\_ops 32 × 8 out; DA rev 108, AR rev 292, TI rev 332), the boundary control flops (420, TI rev 332), every slice's below-75% row gate (RA rev 80), and, if DA agrees, the lead holds (161, RA rev 82) and rcu\_kill's credit pulses (45); about 2,500 of about 4,700 flops at 192 rows (TI's bar: 62,750 + 50 × the modules' take); if over, shrink lead fields first; no waiver except one Daniel signs |
| M3 | Bank slice synthesis | Yosys (`tools/shim/yosys`) on one slice at 192 rows × 4 lanes, through check-ngd and check-cg; a reduced unit at 32 rows for loops | completes as a light unit, within 2,048 MiB (stand-in 1,350); read AND-OR within the bank-out budget of 11 at 192 rows, fanout term included (stand-in 8.3, 11.0 with fanout); flop count within 1% of 6,550 |
| M4 | Kill drain bound | the kill checker with `KILL_DRAIN` − 1 | fails on some kernel, or the margin is recorded |
| M5 | Migration throughput | demote and restore under an R-heavy kernel | 17 rows within 68 cycles of launch (K = 4) |
| M6 | Kernels | `tools/check-kernel.sh`, `tools/check-sv-hosted.sh` | every kernel passes with ccv-sim's oracle; every control above fails |
| M7 | Swap boundary | SV-hosted run | no divergence: RCU reads only its receivers |

Units for loops: a bank slice unit at 32 rows (module parameter `ROWS` set in `test/rcu/cg-units.json`; a package localparam such as `CCV_P_PHYS_REGS` cannot be overridden, RA-32 (2)), and `rcu_lanes` with 4 copies instead of 32 (`COPIES`). Traces for a reduced unit come from a skeleton run at the same sizes. Full-size runs are the exit: one slice at 192 rows stands for all 32, as K and J change only which bytes and lanes it is wired to.
