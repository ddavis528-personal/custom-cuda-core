<!-- design-snapshot url=https://claude.ai/artifact/4k7VrEKJG4KUgMYG1Qz8mB tab=Partition_and_checks rev=69 exported=2026-11-14 status=living -->
> **Snapshot: do not edit.** Exported from *CCV RCU Architecture*, tab *Partition and checks*, at revision 69 on 2026-11-14 ([live doc](https://claude.ai/artifact/4k7VrEKJG4KUgMYG1Qz8mB)). The live doc is the source; it is a living document, so this copy is refreshed whenever it changes. This copy pins what the repo was built against; see [README.md](README.md).

# Partition and checks

This tab is the implementation's floor plan: the modules, which flops each owns, the NGD budget of every port that needs one, where each clock enable comes from, the checks, and what the implementation agent measures before it calls a module done.

## Partition principles

Three rules from `docs/rtl-coding-style.md` decide the cuts:

- **No path straight through a module.** A combinational path from a module's input to its output is forbidden, so a module cannot sit between the issue payload and another module in cycle A.
- **No logic in a parent between its children.**
- **CG-5.** Every enable comes from the module's own flops.

So:

1. **The class is decoded once, in rcu\_isd (RI-25, RA rev 126).** The raw `ooe_rcu_issue_s*_payload` and the flopped valids are wired from the block's ports to every module that acts in A. The op-class fields come from rcu\_isd: at A−1, under each slot's lead valid, it decodes the slot's lead\_opcode (with lead\_done\_row, lead\_pred\_we and lead\_phys\_dst) into the 27-bit class word rcu\_cls and flops it for A. Lanes, the 32 slices, pred, mig, r and mem read rcu\_cls instead of decoding the opcode; each consumer's arrival is the measured fanout term of the bit it reads, with keep-copies per consumer group if needed. The encoding is defined once in rcu\_dec\_pkg, from the generated op-class table (Pipeline tab). Until RA rev 126 each module decoded the class itself into its own lead flops (RA-43); RI-25 measured those decodes as the block's deepest paths. The payload's opcode stays as a copy.
2. **A predicate read in A and its consumer share a module.** The guard read, `active`, the branch outcome and the R predicate sources all depend on a predicate read in A (so does the lanes' lead field sec\_pred\_bit\_a: rcu\_pred loads it at A's edge from active by section ownership and its Q is wired to the rcu\_lane\_ops port; RA rev 98, re:RI-20), so they live with the predicate file, in `rcu_pred`.
3. **A register file is the only module whose outputs are combinational.** Each read port's AND-OR is driven from the file's own predecode flops. The receiving module's budget pays for the rest of the path.
4. **Write data enters a register file directly from the block port or from the writer's flops.** Steering such as MW's position shift is inside the file.

## Modules

| Module | Inst | Holds | Flops (measured) |
| --- | --- | --- | --- |
| `ccv_rcu` | 1 | the block top: `ccv_common_clk`, children; the kill detector (the kill mask is flopped here) and the `core_clk` issue-wake flop | 40 |
| `rcu_bank_slice #(.K, .FULL_ROW(1))` | 32 | 192 rows × 32 bits, byte section K of lanes 4J to 4J+3; its own predecode flops for every port but R0/R1 (L0-3, M0-2, R2, LW/SW/MW/RW: 12 × 28); R0/R1's `rsrc`, 64 flops, decoded from `rcu_r`'s kept lead copy `rrow` (RA-39); RW's A+1/A+2 copy; MW position shift; the zero-register no-select. Bank K is slices (K, 0..7); physical chunk J is slices (0..3, J) (Register file tab, Slices). J is wiring, not a parameter, and `FULL_ROW` is fixed at the instance; four units, K0-K3, stand for the 32 | 6,553 to 6,562 each, about 209,840 in all |
| `rcu_pred` | 1 | 48 × 32 predicate file; every predicate read and write port; guard, MIU `pred_result` forward, `active`, branch outcome, `lead_br_*` (`(* keep *)`), `br_*_a`, `rpsrc_a`, `active_a[s]` | 3,127 |
| `rcu_r` (+ `rcu_xbar` helper) | 1 | R pipe A+1/A+2: `r_a`, `rlow_a`, `rres_a1`, `rpres_a1`; RW data merge and steer; done slots 5 and 6 (`done_v_q`, tags, `done_b*_q`, `done_aux_q`) | 2,680 |
| `rcu_lanes` | 1 | section ownership; 32 `rcu_lane_ops` payload, valid and lead flops; bypass tracker; `lwb_d[0..3]`, `swb_d`; done slots 0-4; `rcu_lane_ops` wakes | 6,888 |
| `rcu_mem` | 1 | memop operand assembly; 4 `rcu_miu_addr` payloads (3,111 b each); no MIU lead capture (the slices and rcu\_pred hold it, RI-20); `rcu_miu_addr_wake` | 12,560 (RI-20, as built) |
| `rcu_mig` | 1 | Migration tab | 7,383 |
| `rcu_kill` | 1 | kill drain and ack; `rcu_ooe_done_wake`; `rcu_idle_q`; credit-return flops for issue and lane-result slots (ooe\_rcu\_issue\_s0..s8\_credit among them); none for MIU data, whose wrapper returns the credit on receipt (RA-41; AR 330, RA rev 116); CSR tie-offs | 54 |
| `rcu_isd` | 9 | the shared issue-lead capture for the zero-cycle `ooe_rcu_issue` end, one instance a slot: under the slot's lead valid at A−1 it flops `rcu_cls` (the class word decoded from `lead_opcode`, with `lead_done_row`, `lead_pred_we` and `lead_phys_dst`; class bits 25 and 26 merged, RI-27) for A, and the every-slot copies `lead_cont` and `lead_pred_neg` (RI-29). With `LS=1`, on S0-S3, it also holds the lead copies `lead_phys_src`, `lead_phys_src2`, `lead_phys_old_dst`, `lead_old_dst_pos` and `lead_src_pos`, which `rcu_lanes` and the slices read instead of the payload (RI-31, OA 403). Lanes, the slices, pred, mig, r and mem take `rcu_cls` instead of decoding the opcode; the encoding is defined once in `rcu_dec_pkg`. Its four `lead_opcode`-class inputs have RCU in-side 13 (Daniel, DA 116). All its flops are one CG-5 lead waiver counted in the block's 2% (RI-25, RA revs 126 and 130-133) | 412 (5 × 28, and 4 × 68 with `LS=1`) |
| **Total** |  |  | **247,473 measured** (check-cg, 2026-11-12), 85% of it the 32 slices |

Each sequential module flops `rst_n` once for itself (RST-1). Reset values: Done, kill and reset tab.

## Port NGD budgets (`<module>.ngd.json`)

The `<module>.ngd.json` files are built (RI) and match this table; RA rev 140 (phase 5) adopts as written the 25 budgets RI left for RA. A block input starts at its interface flop with 0 NGD (every block boundary has a flop on each side; Conventions tab; at RCU's two zero-cycle ends, lane\_rcu\_res and ooe\_rcu\_issue, that flop is the sender's, and RCU's in-side is held to 12 in ccv\_rcu.ngd.json, RA rev 106 and RA-43, except 13 on lead\_opcode, lead\_done\_row, lead\_pred\_we and lead\_phys\_dst, whose OOE out-side is declared 0: Daniel, DA 116; RI-26, RA revs 128 and 129), so a module input fed from a block port has the whole 25 to spend, its fanout across the RCU included. The 12-a-side default applies only between modules inside the RCU; no NGD is budgeted across a block boundary. A driver of 1.4 is the fanout term from a flop (rcu\_isd's or the kill detector's); the block read takes 12 or 13 at ccv\_rcu's ports and measures 23.9 on the issue payload, 23.4 on lane\_rcu\_res and 14.4 on miu\_rcu\_data (tables below). Ports not listed keep the default 12 a side. There is no whole-RCU synthesis (Daniel, 2026-11-06, TI-51). The block's NGD and clock-gating limits are a sum of parts from module runs, so these port budgets are the contract the RCU is assembled from. Every RCU module has a check-cg / check-ngd unit at each parameter set the RCU instantiates it with: the four slice units, K0-K3, and every other module at its defaults. The block's 2% is the sum of its modules' take per instance.

| Path | Driver side | Receiver side | Total | Notes |
| --- | --- | --- | --- | --- |
| issue lead `lead_guard_pred` → `pred` `psel` flops (A−1); `psel` → 48:1 read → negate, forward → `lead_br_*` flops (A) | block port, 2 | `pred` in: 12 | 16.4 at assembly (A−1); in A, 13.6 without the fanout term, 17.0 with it | the split guard read (RA-32, Predicate file tab): the guard's row is predecoded at A−1 from the issue lead, so the A path starts at flops (`act_cr03h`, `test/rcu/guard-ngd.py`). RCU's tightest port is `lead_opcode`, 24.4 |
| issue payload → `bank` read predecode flops | 1.4 (fanout from rcu\_isd's flops) | `bank` in: 14 | 15.4 | class from rcu\_cls flops (no decode; RA rev 126), owner 3, predecode 3, port mux 2; measured at assembly in the table below (RI-35) |
| issue payload → `lanes` payload, bypass flops | 1.4 (fanout from rcu\_isd's flops) | `lanes` in: 18 | 19.4 | ownership, the age 4-6 compare, immediate substitution |
| issue payload → `mem` payload flops | 1.4 (fanout from rcu\_isd's flops) | `mem` in: 14 | 15.4 |  |
| issue payload → `mig` `dm_v_q`, `rs_v_a1` | 1.4 (fanout from rcu\_isd's flops) | `mig` in: 12 | 13.4 | the R2/RW-free decode |
| OOE `ccv_ooe_rcu_issue` R slot `phys_src0/1`, through `rcu_r`'s kept lead copy `rrow` → `bank` R0-R1 read (in A) → the slice's `rsrc`; `bank` R2 read (in A+1) → `r` `old` | `rcu_r`'s `rrow` from a flop (`rr_row_cr02h`, required 0); `bank` out: 11 for R2 (measured 11.0 with the fanout term, RI-9) | `rcu_bank_slice` in: `rrow` arrives at 1.4 (`rr_row_cr03h`), then decode, read and MIU write-through into `rsrc`; `r` in: 14 for R2 | 25 | alignment 2 into flops; R's compute starts at flops in A+1, about 16 for the register-index shfl and ret, alignment of rsrc included (R unit tab, early R source read, RA-39) |
| rcu\_r pr\_orow (phys\_pred\_old\_dst carried to A+1) → pred's PR merge | 0 (a flop) | pred in: per rcu\_pred.ngd.json; pred's dq out required 18 (merge path, migration 7) | ≤ 25 | RCU-internal port, added at assembly (RI-14 (5), RA rev 81); OL/OR/OC stay inside rcu\_pred; gt/pdt/br arrive at 0, their decode timed in pred |
| `bank` L0-L3 read → `lanes` payload | 11 | 14 | 25 |  |
| `bank` M0-M2 read → `mem` payload | 11 | 14 | 25 | operand assembly |
| `bank` R2 read → `mig` `dm_pay` | 11 | 12 (`rcu_mig` has no `rd2_cr03h` entry: the default) | 23 |  |
| `pred` OL/OR/OC/D reads → `lanes`, `r`, `mig` | OL/OR/OC: 0, straight from flops (`act`, `low`, `gv`, `pst`, `rpa`, `rpb`); D: 18 (`dq_cr02h`) | OL/OR/OC: the reader's in-side; D into `mig`: 7 (`dq_cr03h`) | D: 25 |  |
| `lane_rcu_res` → `bank` LW/SW D | block port, zero-cycle end (13 at assembly) | `bank` in: 12 (measured 10.4) | 23.4 measured | AND-OR with hold, into the slice's `wr_dat_cr02h`; holds 12 at assembly, so RA rev 95's condition is met |
| `miu_rcu_data` → `bank` MW D | 2 | `bank` in: 12 | 14 | slot select 2, shift 2, mask 1, D 3 |
| `miu_rcu_data` → `pred` guard forward | 2 | `pred` in: 23 | 25 | joins the split guard path after the 48:1 read; the forward mux is inside its 17.0 (13.6 without fanout) |
| `r` `rres_a1` → `bank` RW D | `r` out: 11 (`rw_*`, required) | `bank` in: 13 (fanout 1.4 inside it) | 24 | merge and steer in A+2 |
| `mig` `rs_f` → `bank` RW D | `mig` out: 11 (`rwv`, `rwsel`, `rwrow`, required) | 13 | 24 |  |
| `mig` R2 row request → `bank` R2 predecode | `mig` out: 11 (`r2v`, `r2row`, required) | `bank` in: 13 | 24 | without the stall and R2-busy terms (Migration tab); the bank applies its own R2 decode |
| every module's busy OR → `kill` `rcu_idle_q` | out: 5 | `kill` in: 5 | 10 |  |

### Measured at assembly (RI-34, RI-35; 8fcec64b)

The table above is the design budget. These are the assembled block's figures: the gate's block check for rcu passes at 8fcec64b, two levels timed alone, 49 of 49 instances on units at their parameters, and the block read converges with no findings. Each figure is on ccv\_rcu's port, arrival plus depth to the first flop, against 25, the fanout term included. The arrival is 12 on the four class-word lead fields (in-side 13, DA 116) and 13 elsewhere (in-side 12), per field in ccv\_rcu.ngd.json. Read at a whole-port 13, lead\_opcode would be 25.4, so the per-field arrivals are part of the contract.

| Issue lead field | S0-S3 (rcu\_isd\_s) | S4-S7 (rcu\_isd) | S8 | Notes |
| --- | --- | --- | --- | --- |
| lead\_done\_row | 21.5 | 21.9 | 21.9 |  |
| lead\_opcode | 24.4 | 24.4 | 24.4 | 12.4 in to lop\_cr01h, 0.6 under its 13; the block's closest |
| lead\_phys\_dst | 18.2 | 18.0 | 18.0 | the pcopy compare |
| lead\_pred\_we | 17.7 | 17.0 | 17.0 |  |

| Input | Total | Worst endpoint and notes |
| --- | --- | --- |
| other issue lead fields | 17.0 | sec\_mask into the slice's plsec\_cr00h (exact owner, RA 133); guard\_pred 16.4 into rcu\_pred |
| issue payload, outside the lead fields | 23.9 | rcu\_pred im\_cr02h, 10.9 in |
| issue valid | 21.2 | rcu\_kill, 8.2 in |
| lane\_rcu\_res payload / valid | 23.4 / 14.7 | slice wr\_dat\_cr02h, 10.4 in (zero-cycle end, RA rev 95; its assembly condition holds) |
| map and mig payloads / valids, mig credit and stall | 13.0 / 14.7 |  |
| wakes and the kill\_valid tap | 6.0 in | wake rule 12; kill\_valid is a wake port (AR 336 (b)) |
| kill\_epoch, kill\_warp\_mask | 13.0 | into the top's own detector flops (Done tab) |
| miu\_rcu\_data payload | about 14.4 | 14.4 in to rcu\_pred mr\_cr02h behind the flopped end. Read at a nominal 13 arrival it would be 27.4, so this end stays flopped (Daniel, DA 116, on AR 334) |
| every output | 1.4 worst | straight from a flop (the rcu\_lane\_ops fanout term); every stall output is constant 0 |

Not measured: the wrapper level's outputs and the repeater's flop-to-out on flopped ends.

RA rev 117's interim arrivals (0 on rcu\_lanes' opc\_cr02h and the slice's popc\_cr01h) have ended: rcu\_isd's class flops replace them, and the `ngd.json` files of rcu\_bank\_slice, rcu\_lanes and rcu\_mem say so (RI-34/35 at 8fcec64b).

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

OOE sends a lead slice on every `ccv_ooe_rcu_issue` slot. It is driven from a flop beside `valid` in A−1, so it arrives a cycle ahead of the payload in A. Cont slots carry zero. TI writes the fields into the schema as `lead_fields`. OOE builds every bit from the selected RS entry's static fields, so the slice carried no opcode until RA-43. Since then (RA rev 108/109, OA-387, OA-390) it carries lead\_opcode on every slot. RCU's op-class decode reads it at A−1 once, in rcu\_isd, which flops the class word rcu\_cls for every consumer (Partition rule 1; RI-25, RA rev 126).

| Field | Width | Slots | Meaning (OA's definitions) | RCU's use |
| --- | --- | --- | --- | --- |
| `lead_sec_mask` | CCV\_SECTIONS | all | the op's section footprint. Exact, not a superset: equal to the footprint on lead slots, 0 on continuations (OA 403) | per-section enable of the lane-op payload sections, the bypass selects and the address data sections; the slices precompute the P-slot section owner from it in A−1 (4 ungated flops a slice). Because ownership needs it exact, RCU asserts equality with the payload's footprint at its input, not only the subset; a negative control sets one extra bit and must fail, and TI's stub refuses a mismatch (RI-31, OA 403, TI 398, RA revs 132-133) |
| `lead_src_used[i]` | 3 | all | `src_valid[i]` | enable of operand field group i (lane-op source i; on an address slot, base, index or store data) |
| `lead_imm_used` | 1 | all | `imm_kind` not none, which covers every value OOE substitutes into imm | enable of the imm field group |
| `lead_merge_used` | 1 | all | the write merges, so the old destination is read | enable of the merge-data (old dst) group and its read select |
| `lead_guard_used` | 1 | R slot | the guard is not the always-true predicate | enable of the split guard read's `psel` flops |
| `lead_guard_pred` | CCV\_P\_W\_PHYS\_PRED | R slot | the guard's renamed physical predicate; its negate stays in the payload | the A−1 predecode of the split guard read (Predicate file tab) |
| lead\_guard\_used, lead\_guard\_pred (extended) | 1; 6 | all (RA rev 108/109) | the same fields, now driven on every slot for the zero-cycle issue end (RA-43). lead\_guard\_used: the op reads its predicate (guard or data) and it is not the always-true one. lead\_guard\_pred is moved: phys\_pred\_guard leaves the payload (TI 382) | every slot's guard read starts from the psel flops |
| lead\_opcode | 9 | all | a copy of the slot's opcode; the payload keeps its own (RA rev 108/109, OA-387) | rcu\_isd's op-class decode in A−1, into rcu\_cls (Partition rule 1; RI-25, RA rev 126) |
| lead\_phys\_src, lead\_phys\_src2, lead\_rpsrc | 16; 8; 32 | R slot | R's phys\_src and phys\_src2, moved from the payload; R's imm, all of \[31:0\] (widened from \[13:0\], RA-43), also moved: imm leaves R's payload (RA rev 114, TI 382) | the R0/R1 row selects and R's predicate sources, from flops; movi and the call link read imm from the lead\_rpsrc capture flop, which holds it at A |
| RA-43 lead copies (TI names them in the schema) | 23 a slot (32 with lead\_opcode); 40 more on S0-S3 | all; S0-S3 | copies at A−1, payload kept. Every slot: phys\_dst 8, dst\_pos 2, dst\_width 2, done\_row 2, pred\_we 1, phys\_pred\_dst 6, cont 1, pred\_neg 1. S0-S3: phys\_old\_dst 8, old\_dst\_pos 2, src\_pos 6 (3×2), phys\_src 16 (2×8), phys\_src2 8 (lead\_phys\_src2; RI-31, OA 403, RA revs 132-133): only the fields whose in-path was over 12 (RI rev 47, RI-29, RI-31). src\_width is not copied and stays payload (RA rev 114, TI 382). OOE: gated on iss\_en, out-depth 0, gnt in 10.2 (OA-390; OA priced 345 flops before RA rev 114 narrowed the S-slot copies and made R's imm a move; lead\_phys\_src2 adds 32, OA 403) | the destination, write, cont and negate paths in lanes, pred and the slices start from flops: consumers read the copies from rcu\_isd (every slot) and rcu\_isd\_s (S0-S3), never the payload, with keep-copies of a capture flop where a fanout term puts a port over 12 (RI-29, RA rev 131). Port budgets: lead\_opcode, lead\_done\_row, lead\_pred\_we and lead\_phys\_dst have RCU in-side 13 and OOE out-side declared 0 (Daniel, DA 116; RI-26, RA revs 128-129); every other lead field and the payload stay at 12. About 412 capture flops in rcu\_isd and rcu\_isd\_s against the block's 2% (about 4,850) |

**Timing in RCU.**

- The class bits come from rcu\_isd's rcu\_cls flops and the S0-S3 copies from rcu\_isd\_s's flops (RA revs 126 and 131-133); no module keeps its own copy of those. For the enable bits (sec\_mask, src\_used, imm\_used, merge\_used, guard), each module that owns a field group registers the bits it uses, with the issue valid, into its own copy of `iss_lead_q[s]` (Conventions tab) at A−1's edge. These are RCU's own flops, as CG-5 requires.
- A group's enable at A's edge is `iss_v_q[s] & iss_lead_q[s][bit]`.
- A group that loads after A carries the bit forward with the op. The bit is piped beside the op's valid in the same stage flops, and it is never recomputed from the payload.
- `iss_lead_q[s]` loads every issued cycle and is counted against the module's allowance for ungated flops, about 81 per module that takes all nine slots.

**Superset rule.**

- A set bit may load a group the op then does not use. That costs DCGE, not correctness.
- A clear bit is a promise. RCU asserts at A, for every valid slot, that what the payload uses is a subset of what the lead promised: `src` operands, a non-none imm, merge, sections and guard.
- Negative control `lead-src-clear` (TI's name, TI rev 288; this spec called it lead-promise): it clears one lead bit of an op that uses the group, and it must fail. It is in the controls list; the stub already refuses a broken promise, and the model and RTL must too.

**Address time.** `CCV_LAT_RCU_ADDR_BASE` = 1 is adopted (PF-47). TI's first application failed the gate in OI's RTL, so the params still say 5, and `CCV_LAT_L1_WAKE` 17, until OI fixes `ooe_wake`'s depth and the `no-msd` control's stimulus (TI rev 288); TI then reapplies them, L1\_WAKE going to 13. RCU's spec, model and RTL are built to 1. The address valid leaves at A's edge and the payload at A+1's edge, counted from the interface flop. The receiving interface flop's cycle is the link term bnd\_rx, not part of the base (AR row 300): CCV\_LAT\_RCU\_ADDR equals the base, and bnd\_rx(issue) counts only on the crossing, in L1\_WAKE's and L1\_CMPL's derives (AR row 301; counting it twice would give 18/20). Likewise LANE\_BASE stays 7 and the SFU base 12; a zero-cycle receiving end is bnd\_rx 0. Daniel (2026-11-06, RA rev 91; DA 114, amended) approves a zero-cycle end only for IPC, and only if it meets the module NGD rules without its receiver flop; an end that cannot goes to Daniel whatever its IPC. Decided (RA rev 95, under DA 114/115): lane\_rcu\_res is zero-cycle on RI-16's runs (S1 1.04% fewer cycles, cm32 0.93% fewer, cm128 0.15% more), so CCV\_LAT\_LANE 7 and CCV\_LAT\_SFU 12; it never takes a repeater stage (RCU and the lanes abut), and its block-level read holds 12 (10.4 in at assembly), which closes RA rev 95's condition. miu\_rcu\_data (16.2 at module level) and ooe\_rcu\_issue stay flopped.

**Reduced units (RA-32 (2), TI rev 285).** Every RCU size is a module parameter that defaults to the `ccv_params_pkg` value, for example `parameter int ROWS = ccv_params_pkg::CCV_P_PHYS_REGS`. A reduced check-cg / check-ngd unit sets it, as in `{"name": "rcu_bank_slice_r32", "params": {"ROWS": 32}}`; the 32-row slice and the 4-copy `rcu_lanes` are local loops, not in `cg-units.json`. The full-size units are each module's exit; the four slice units peak at 1,435 MiB and are on `tools/heavy-units.json` only so each runs alone (TI #91). Yosys elaborates a module at its defaults when it reads the file, before the unit's parameters apply, so a reduced unit first pays its module's full-size elaboration: a 64,000-cell stand-in took 4.7 GB with whole-bank defaults and 449 MiB with small ones (2026-11-03). No module's default may therefore be larger than its full-size unit; a slice meets that, since its full size is one unit.

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

- The **arrival-cycle checker** on `rcu_ooe_done` per class: valid at A+1, A+6 or A+11 after the issue that names its `rob_tag`.
- **A-35's two isolation assertions.** Every lane of a newly allocated row is written by a lane result, the merge path or the copy before any read of it: a bind module with a 192 × 32 shadow, cleared by OOE's allocation, which it observes through the SV top. The restore half is built (`q53_iso`); the allocation half comes with CCV\_RCU\_RTL. The companion assertion reads: a launched warp's map is all zero registers (A-64).
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
| M0 | The cycle-accurate C++ model | tools/check-kernel.sh and tools/check-sv-hosted.sh with the model as RCU in both hosts; the model's unit tests; then block lock-step of the RTL against it (every output and event, every cycle) | every kernel passes against ccv-sim's oracle and every control above fails, with the model; every output and event on this spec's cycle, hazards and stalls included; kernel cycles reported against the stub's (pending RI). From then on, the assembled block runs lock-step with no mismatch |
| M1 | NGD per module and per port | `tools/check-ngd.py` at full size, plus each module's unit | every path ≤ 25, every port within its `.ngd.json`, all with check-ngd's fanout term counted (RA-33, Daniel's option (a)); the `pred` guard path in A ≤ 16 without the fanout term and ≤ 25 with it; measured 13.6 / 17.0 (`act_cr03h`, `test/rcu/guard-ngd.py`) |
| M2 | Clock gating | `tools/check-cg.py`: idle, medium and high scenarios (RA-34), driven by checked replays of ccv-skel port traces: high = coremark128 and vadd, medium = the same with two idle cycles after each, idle = reset and no issue; DCGE counts only from traces made after the stub's RA-19 merge fix | each module within its 2% / 8-flop allowance; block within 2% per instance, which also carries every RCU end's ungated boundary lead slice, in and out (835: ooe\_rcu\_issue 144 and miu\_rcu\_data 204 in, rcu\_ooe\_done 231 and rcu\_lane\_ops 32 × 8 out; DA rev 108, AR rev 292, TI rev 332), the boundary control flops (420, TI rev 332), every slice's below-75% row gate (RA rev 80), and the lead and credit flops waived at module level (825: rcu\_pred 324, of which MIU 184, guard leads 126 and R predicate sources 14; rcu\_r 48; rcu\_isd 412; rcu\_kill's credit-return pulses 41; Daniel, 2026-11-06, RA revs 87 and 88); no waiver except one Daniel signs. Met: block rcu 247,473 flops, 2% allows 4,949.5, its modules take 2,704 (55%), about 2,245 to spare; no slice waiver (the slice loads its M rows only when a P slot owns pipe K, RA 133; K3's idle DCGE 93%) |
| M3 | Bank slice synthesis | Yosys (`tools/shim/yosys`) on each slice unit, K0-K3, at 192 rows × 4 lanes, through check-ngd and check-cg; a local 32-row unit for loops | the unit's own peak within 2,048 MiB (measured 1,435; on `tools/heavy-units.json` only so each slice unit runs alone, TI #91); read AND-OR within 11 (measured 8.3, 11.0 with fanout, no margin); flops within 1% of 6,550 (measured 6,553 to 6,562) |
| M4 | Kill drain bound | the kill checker with `KILL_DRAIN` − 1 | fails on some kernel, or the margin is recorded. Met by the bench control, with the whole drain as margin |
| M5 | Migration throughput | demote and restore under an R-heavy kernel | 17 rows within 68 cycles of launch (K = 4), counted from c1. Met for demotion at 68 from c1 (no margin); restore pending RI's c1 count |
| M6 | Kernels | `tools/check-kernel.sh`, `tools/check-sv-hosted.sh` | every kernel passes with ccv-sim's oracle; every control above fails. Met |
| M7 | Swap boundary | SV-hosted run | no divergence: RCU reads only its receivers. Met with the model; the RTL's run is pending TI's selector |

Units for loops: a bank slice unit at 32 rows (module parameter `ROWS`; a package localparam such as `CCV_P_PHYS_REGS` cannot be overridden, RA-32 (2)) and `rcu_lanes` with 4 copies instead of 32 (`COPIES`), both local, not in `test/rcu/cg-units.json`. Traces for a reduced unit come from a skeleton run at the same sizes. Full-size runs are the exit: four slice units, K0-K3, stand for all 32, as J changes only which lanes a slice is wired to.
