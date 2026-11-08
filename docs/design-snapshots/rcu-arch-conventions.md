<!-- design-snapshot url=https://claude.ai/artifact/4k7VrEKJG4KUgMYG1Qz8mB tab=Conventions_and_interfaces rev=17 exported=2026-11-08 status=living -->
> **Snapshot: do not edit.** Exported from *CCV RCU Architecture*, tab *Conventions and interfaces*, at revision 17 on 2026-11-08 ([live doc](https://claude.ai/artifact/4k7VrEKJG4KUgMYG1Qz8mB)). The live doc is the source; it is a living document, so this copy is refreshed whenever it changes. This copy pins what the repo was built against; see [README.md](README.md).

# Conventions and interfaces

Every cycle number in this spec counts from **A, the cycle the RCU's interface flop holds an issue's payload**. Every block boundary has a flop on each side, built by the interface module (ccv\_common\_rpt; Daniel 2026-11-05, TI rev 321, accounted by AR rev 285): no logic sits between a block port and the receiver's first flop, so every RCU input starts at a flop with 0 NGD, and every output leaves straight from an RCU register at 0 NGD. Two RCU receiving ends are zero-cycle under DA 115: lane\_rcu\_res (RA rev 95) and ooe\_rcu\_issue (RA-43, AR 329). At those ends the 'interface flop' is the sender's flop across an abutted link. A is the cycle OOE's issue register drives the payload onto RCU's port. Every issue input is held to 12 NGD inside RCU (ccv\_rcu.ngd.json), and the fields RCU cannot meet 12 from come as lead copies at A−1, captured in RCU's lead flops (Partition tab). Throughout this spec, an input 'on the wire' in cycle T means at its interface flop's output in T. This tab fixes those conventions and, per channel, which RCU register samples or drives each field in which cycle. Field widths and bit ranges are the schema's (`schema/interfaces.json`); they are not repeated here.

## Timing conventions

- **Clock and reset.** One input clock, `core_clk`, ungated; the RCU gates it as its first act through `ccv_common_clk` (CCV-L22). `rst_n` is captured by plain flops, `rst_n_q`, and every use of reset reads those (RST-1).
- **A channel message** has its valid (and lead slice) at the receiver's interface flop in cycle T−1 and the rest of its payload there in cycle T, the *payload cycle*. Valid binds: the payload follows even if a stall arrives between.
- **Receiving.** The RCU captures every input valid in a flop written every cycle, `<ch>_v_q`, and every input lead slice in flops written every cycle, `<ch>_lead_q`. In cycle T those flops are the enables (CG-5, means L1 of the OOE doc) for whatever captures the payload at T's edge. Logic may also use the payload in T, from the interface flop's output, with the whole 25 NGD (Partition tab).
- **Sending.** An output's valid and lead slice are flops loaded at the edge ending T−1, so they drive the wire in T; its payload flops load at the edge ending T, driving T+1. No logic sits between an output flop and the port; a flop that also feeds internal logic is duplicated, one `(* keep *)` copy for the port (NGD-7).
- **A, A+n.** A is the payload cycle of an issue. "At A's edge" means the edge that ends cycle A.
- **Writes.** A write to the PRF or predicate file *lands in W* when its data is on the row flops' D pins in cycle W; the new value is readable from W+1. A contracted latency L (issue to readable) puts W at A+L−1.
- **Reads.** GPR rows are read in A+1 from select flops loaded at A's edge, except the R op's sources R0 and R1, which are read in A from the payload's rows on the wire, decoded in each bank slice, into flops in the slice (R unit tab, early R source read, RA-39). Predicate rows are read in A from the payload wires (Predicate file tab).
- **Credits.** The RCU never stalls on its three fixed-latency inputs (issue, lane results, MIU data). On issue and lane results it returns a credit in each message's payload cycle, from `<ch>_v_q` (issue's from rcu\_kill, ooe\_rcu\_issue\_s0..s8\_credit). miu\_rcu\_data has no RCU credit port: its wrapper (ccv\_common\_rpt, CREDIT\_ON\_RECEIPT) returns the credit from its own b\_ valid flop (RA-41; AR 330, TI 383; RA rev 116). On the other three inputs it returns a credit when it frees the entry the message took. On every output it keeps a counter per slot of depth `CCV_CREDIT_DEPTH` (4); on a fixed-latency output, sending with the counter at 0 is an assertion failure, never a stall.
- **Wake.** Each output channel's `_wake` is a flop of the OR of the RCU's input wakes that can lead to a send on it (issue for lane ops, done and MIU address; map, command and PCA rows for demotion rows). That gives at least `CCV_WAKE_LAT` (4) of lead, since the inputs' wakes lead their valids by 4 and the RCU's earliest output valid is A+1. The RCU's own clock gate closes only when no input valid, no pipeline valid, no staged row and no pending migration is held.

## Naming

Registers carry a stage tag (CCV-L29): `_a` for flops loaded at A's edge, `_a1` at A+1's edge, and so on; `_w` for write-back stage flops. A one-hot row select is `<port>_sel_hi_a[11:0]` and `<port>_sel_lo_a[15:0]` (Register file tab). Port names are the generated ones (`rtl/top/ports/ccv_rcu_ports.svh`).

## Inputs

| Channel, slot | Valid flop (T−1) | Payload use in T | Captured at T's edge into | Credit |
| --- | --- | --- | --- | --- |
| `ooe_rcu_issue` s0-s8 | `iss_v_q[s]`; lead `iss_lead_q[s]` (the issue lead slice, RA-31) | slot decode, guard and predicate reads, row predecode, lead outputs (Pipeline tab) | issue stage register `iss_*_a[s]`, each field group enabled by `iss_v_q[s]` and its `iss_lead_q[s]` bit (Partition tab, The issue lead slice) | every message, from `iss_v_q[s]` |
| `lane_rcu_res` c00-c31 | `lres_v_q` (one flop per side of the floorplan, all 32 copies must agree) | `result`, `sec_pred_out` into the lane write port and predicate write port directly | nothing: written into the PRF in T (W = T) | every message |
| `miu_rcu_data` s0-s3 | `mdat_v_q[j]`; lead `mdat_lead_q[j]` = phys\_dst, dst\_pos, dst\_width, active\_mask, phys\_pred, pred\_we (51 bits, RA-4) | `load_data`, `pred_result` into the load write ports; `pred_result` into the guard forward | nothing: W = T | every message |
| `pca_rcu_mig` | `pcar_v_q` | none | restore staging FIFO entry (Migration tab), enable `pcar_v_q` | when the row is written (TI-13) |
| `ooe_rcu_map` | `map_v_q` | none | pairing entry for its direction (Migration tab) | when the pairing entry frees |
| `rau_rcu_mig` | `cmd_v_q` | none | pairing entry's command flag | when the pairing entry frees |
| `kill_valid`, `kill_warp_mask`, `kill_epoch` | `kill_v_q` (valid a cycle ahead of the mask) | none | `kill_epoch_q`; the mask is not stored (RA-14) | outside credits |
| `csr_req` | n/a | n/a | n/a | RA-26 (proposed: credit back, reads 0) |

## Outputs

| Channel, slot | Valid and lead flops (drive T−1) | Payload flops (drive T) | First valid cycle |
| --- | --- | --- | --- |
| `rcu_lane_ops` c00-c31 | `lop_v_a`, lead `section_en_a[3:0]`, `sec_pred_bit_a[31:0][3:0]` | `lop_*_a1`: operands, merge\_data, per-section fields, `operand_byp` | valid A+1, payload A+2 |
| `rcu_ooe_done` s0-s6 | `done_v[k]`; slot 5 lead `lead_br_taken_a`, `lead_br_mask_a` | `done_*[k]`: rob\_tag, done\_row; slot 5 adds branch\_taken, branch\_mask, aux | R ops A+1; lane ops A+6; SFU A+11 (Done tab) |
| `rcu_miu_addr` s0-s3 | `addr_v_a[j]` | `addr_*_a1[j]`: rob\_tag, active\_mask, base, index, store data | valid A+1, payload A+2 (`CCV_LAT_RCU_ADDR_BASE` = 1, RA-7; adopted as PF-47, RA-31; CCV\_LAT\_RCU\_ADDR equals the base; the boundary flop is bnd\_rx(issue) on the crossing, AR rows 300-301) |
| `rcu_pca_mig` | `pcam_v_a` | `pcam_*_a1`: warp\_id, mig\_row, row\_data | valid A+1, payload A+2 of an idle-R cycle A (Migration tab) |
| `kill_ack`, `kill_ack_epoch` | `kill_ack_q`, `kill_ack_epoch_q` | n/a | Done tab |
| `csr_rsp`, `csr_credit` | RA-26 |  |  |

The lead slices on `rcu_lane_ops` and `rcu_ooe_done` are loaded at the same edge as their valid and are separate flops from any payload copy (`lead_br_*` are 33 flops apart from `branch_taken`/`branch_mask`).
