<!-- design-snapshot url=https://claude.ai/artifact/4k7VrEKJG4KUgMYG1Qz8mB tab=Register_file rev=12 exported=2026-11-04 status=living -->
> **Snapshot: do not edit.** Exported from *CCV RCU Architecture*, tab *Register file*, at revision 12 on 2026-11-04 ([live doc](https://claude.ai/artifact/4k7VrEKJG4KUgMYG1Qz8mB)). The live doc is the source; it is a living document, so this copy is refreshed whenever it changes. This copy pins what the repo was built against; see [README.md](README.md).

# Register file

The GPR file is four section banks, each 192 rows × 256 bits with 10 read ports and 4 write ports; every select is a pre-decoded one-hot held in a flop, so no row decode sits on a read path or a clock-enable cone. That is one write port fewer than RA-2's five: collectives execute in the R pipeline and share its port (R unit tab). A bank is logical: it is built as 8 slices, `rcu_bank_slice` × 32 in all (below).

## Slices and physical hierarchy (Daniel, 2026-11-03)

- **Slice (k, j):** byte section k of lanes 4j to 4j+3, 192 rows × 32 bits, `rcu_bank_slice #(K, J)`. It is the RTL module and the check-cg / check-ngd unit. Bank k is the 8 slices (k, 0..7); the RCU has 32.
- **Each slice is a complete bank for its 32 bits:** every read and write port, its own `sel_hi`/`sel_lo` copy per port (14 × 28 = 392 flops, which are also the fanout copies), its own row enables and gate groups, its own `rst_n` flop. No logic crosses slices: a read's bytes from the four banks meet at the reader (alignment on R and M; the lane's swizzle on L).
- **Physical chunk j:** the four slices (0..3, j), lanes 4j to 4j+3 whole, 192 rows × 128 bits, about 770,000 cells. Eight chunks. Place and route is flat (the plan); a chunk is the contiguous APR block kept open in case physical partitioning is ever needed, which Daniel adopts only if the cost of the alternatives is prohibitive.
- **Why 4 lanes of one byte (measured, Yosys and ABC through check-ngd's own flow, cold cache, a stand-in with the ports and selects of this tab):**

| Unit at 192 rows | Flops | Cells | Peak MiB | Read out, NGD (fanout term) | Row gate group |
| --- | --- | --- | --- | --- | --- |
| `ooe_rob_w` (the reference envelope) | 5,359 | 158,437 | 1,914 | — | — |
| byte slice, 2 lanes | 3,479 | 98,802 | 692 | 8.3 (10.3) | 16 flops |
| **byte slice, 4 lanes (chosen)** | **6,551** | **193,498** | **1,350** | **8.3 (11.0)** | **32 flops** |
| byte slice, 8 lanes | 12,695 | 382,890 | 2,665, a heavy unit | 8.3 (11.0) | 64 flops |
| lane slice, 1 lane × 4 sections | 7,727 | 203,550 | 1,419 | 8.3 (10.3) | 32 flops |
| whole bank, 32 lanes (extrapolated) | about 50,000 | about 1.5 M | about 10,500 | — | 256 flops |

- The whole bank is about 10 × `ooe_rob_w` and cannot be a unit. 8 lanes is over the 2,048 MiB light limit. 2 lanes halves the row gate groups to 16 flops and doubles the select copies. A lane slice has a clean physical column but needs a select per section per port: 1,232 flops a slice, about 27,000 more in all. The 4-lane byte slice is inside the envelope, with 32-flop row groups and 12,544 select flops in all.
- **One-hot row selects were measured too** (R ports, 192-bit one-hot per port): read out 8.0 (9.3), against 8.3 (11.0) predecoded. It is a fanout fix, not a depth fix: the 192:1 OR is about 8 NGD on its own. On R alone it costs about 15,700 flops; on every port about 270,000. Not adopted.

## Organisation

- **Bank k holds section k:** byte k of every lane's 32-bit word. Row r of bank k, bits \[8l+7:8l\], is lane l's byte k of physical register row r. A row of the four banks together is one 1,024-bit physical register row.
- **A register** is (row, position, width): it occupies sections `pos` to `pos + span − 1`, span = 4, 2, 1, 1 for width codes 0-3 (32, 16, 8, 4 bits). `secmask(width, pos)` names those sections.
- **Rows 0 to `CCV_P_PHYS_REGS` − 1 exist.** The zero register `CCV_P_PHYS_ZERO` (255) has no row: it decodes to no select, so it reads 0 and a write to it selects nothing (asserted never to happen, A-64). Rows 192-254 are never named (asserted).
- **Clock gate group = one row of one slice (32 flops),** enable `row_en[r]` below, computed in the slice from its own select flops (CG-5), so the 4 lanes' bytes of a row share one gate and 6,144 gates cover the PRF. No reset (OOE's A-29: no row is read before it is written).

## Row predecode

Every row index the RCU will use as a select is split at the edge before its use into two one-hots, stored in flops: `sel_hi[11:0]` = one-hot of r\[7:4\] (no bit for r\[7:4\] ≥ 12), `sel_lo[15:0]` = one-hot of r\[3:0\]. Row r is selected when `sel_hi[r>>4] & sel_lo[r&15]`, one AND level. 28 flops replace 192 per port, and the zero register and rows ≥ 192 fall out as no select. Read selects are decoded in A from the issue payload; write selects travel with the write's descriptor (lane, SFU, R) or are decoded from the MIU lead on the wire (load).

**Select fanout (RA-33, TI rev 286; Daniel chose option (a), 2026-11-02; TI builds it).** check-ngd's netlist is load-blind today: a select bit driving 1,024 cells times as one gate at fanout 4, while a real buffer tree adds ceil(log4(N/4)) inverter stages, 0.68 NGD each. RCU is built as if that cost were counted (TI's option (a)).

- Each read and write port keeps its own copy of `sel_hi`/`sel_lo` in every slice, as `(* keep *)` flops loaded together. The row AND in a slice drives 32 bit-cells, one stage, about 0.7 NGD. A single copy for all four banks would drive 1,024 cells, which costs 4 stages, about 2.7 NGD.
- Each `sel_hi` bit then drives 16 row ANDs, and each `sel_lo` bit drives 12, both at most 1 stage.
- Cost: 28 flops × 14 ports × 32 slices = 12,544 flops (about 5% of RCU), against 6,300 for the per-64-bit copies this tab had before the slicing. They load only when the port is used, so they gate with the port's valid: 28-flop groups.
- Write data is broadcast to the 192 rows of a slice. It is registered per slice as well, which costs 3 stages (about 2 NGD) on a path that is otherwise short.
- Every path budget in this tab carries its fanout stages. The implementation agent reports them beside check-ngd's number until the tool counts them.
- If Daniel picks (b), a stated fanout limit, the copies stay and are sized to that limit.

## Read ports (per bank k, read in A+1)

| Port | Row source (decoded in A) | Used by | Select flops' enable |
| --- | --- | --- | --- |
| L0, L1, L2 | `phys_src`\[15:8\], \[7:0\], `phys_src2` of the S op that owns section k | lane operands src0-src2 | `iss_v_q` OR over S slots 0..k |
| L3 | `phys_old_dst` of that op | `merge_data` | same |
| M0, M1, M2 | base, index, data source rows of the P op that owns pipe k | `rcu_miu_addr` base, index, store data | `iss_v_q` OR over P slots 0..k |
| R0 | R op `phys_src`\[15:8\], on the payload wire in A: decoded in the slice, read in A into the slice's `rsrc` (RA-39, OA rev 336) | shfl source, ret's rs, unballot's rs | `iss_v_q[8]` |
| R1 | R op `phys_src`\[7:0\], on the payload wire in A: as R0 (RA-39) | register-index shfl's index | `iss_v_q[8]` |
| R2 | R op `phys_old_dst`, or a demotion row | merge source for movi, call, shfl, ballot; demotion | `iss_v_q[8]` OR migration's read grant |

The owner of section k is the lead (cont = 0) S slot j ≤ k whose `footprint` has bit k−j set; V-60 guarantees at most one. Memops follow the same rule over P slots, with pipe k ≡ section k: a memop's footprint is the union of its operands' sections, destination included (the schema's `CCV_PRF_MEMOP_READ_BITS` requirement, 3 × 256 bits per pipe). R ports read the same row in all four banks.

**Read mux:** `rd[31:0] = OR over r of (sel_hi[r>>4] & sel_lo[r&15] & row[r])` in each slice, built as 12 groups of a 16:1 AND-OR on `sel_lo`, each gated by its `sel_hi` bit, then a 12:1 OR. **Measured: 8.3 NGD from the select flops at 192 rows, 11.0 with the fanout term** (stand-in, 2026-11-03; 5.8 at 32 rows). Every reader takes it into flops after at most alignment, so the bank's read-out budget is 11 (Partition tab). R0 and R1 are read a cycle early, in A, from the payload's rows on the wire, into flops in the slice (\`rsrc\`), so that R's compute starts at flops (R unit tab, RA-39); their path from the RCU port is about 17.5 against an input budget of 18.

**Alignment (R and M ports only).** A lane's word is {bank3, bank2, bank1, bank0}. Right-aligned value `v = (word >> 8·pos) & elemmask(width)`, elemmask = all ones, 0xFFFF, 0xFF, 0xF. A 4:1 byte mux plus the mask, about 2 NGD, using pos and width from `iss_*_a`. Lane ports send raw bytes; the lane swizzles (OOE doc, footprint rule).

## Write ports (per bank k)

| Port | Lands in | Row select | Data for lane l | Lanes written | Section k written when |
| --- | --- | --- | --- | --- | --- |
| LW (lane) | A+6 | lane descriptor `lwb_d[k]` at depth 6 (predecoded at A) | `lane_rcu_res` c\_l `result`\[8k+7:8k\] | all 32; the GPR copy writes only lanes with `active` = 0 | descriptor valid, the op owns section k, it writes a GPR |
| SW (SFU) | A+11 | SFU descriptor `swb_d` at depth 11 | the SFU second result (RA-3), byte k | all 32 | descriptor valid and k in the SFU destination's `secmask` (all four under `FULL_ROW`) |
| MW (load) | MIU payload cycle T | `mdat_lead_q[j]`, predecoded on the wire in T−1 | `load_data` lane word of slot j, shifted left 8·pos, byte k | lanes in the lead `active_mask` | `mdat_v_q[j]` and k in `secmask(dst_width, dst_pos)` of slot j (all four under `FULL_ROW`), and phys\_dst is not the zero register |
| RW (R) | A+2 | `rres_a1` | R result (already merged with the old destination), shifted to pos, byte k; or a staged restore row | all 32 | R result valid and k in its `secmask` (all four under `FULL_ROW`); a restore row writes all four |

**One load write per bank per cycle.** Four MIU slots can land in one cycle, so bank k's MW port takes the one slot j whose `secmask` covers k. Two slots covering the same bank in one cycle is an MIU contract breach (asserted; raised to AR as RA-28, since narrow loads in different pipes can name overlapping sections).

**The full-row interim (AR-24; RI-5, 2026-11-04).** Today OOE allocates every register as a whole row at position 0, charged four sections, while the width codes stay the registers' own (`full_rows`, AR-24's interim; OOE's RTL keeps rows whole until its slice 6). The lanes then do no swizzle, and narrow-carry and lane-unmasked ops read the row whole, so the row must be zero above the register's width. `ccv_rcu` therefore takes a parameter `FULL_ROW`, passed down to every slice and to `r` and `mem`, **built as 1 now**:

- `FULL_ROW` = 1: SW, MW and RW write all four banks of the row; the data above `dst_width` is forced to zero (an AND per byte from the width code, in the write data's own stage). LW needs nothing: it writes the op's owned sections, which OOE makes the whole row.
- `FULL_ROW` = 0: the enables are the `secmask` terms in the table above, the spec's sectioned build.

It flips to 0 only when both have landed: OOE allocating narrow registers at their positions (the footprint build, AR-24's end) and the lanes' swizzle. Every kernel without `full_rows` today has only 32-bit registers, for which the two settings write the same banks. The RCU model's `Config::full_row` (`CCV_RCU_FULL_ROW`) is the same switch; RTL and model run lock-step at the same setting.

**Lead-loaded ports and CG-5 (RI-9, 2026-11-04; R0/R1 revised by RA-39, OA rev 336).** Every other port's select flops load at A's edge (or from a descriptor) under a valid that is already a slice flop. MW (from the MIU lead in T−1) loads from lead fields that arrive with their valid, so no flop of the slice can enable it, and MIU cannot send a valid a cycle earlier. Its select state is therefore **loaded every cycle, ungated**, inside the slice's 2% allowance, and kept small. R0 and R1 have no select flops: they decode the payload's rows on the wire in A, and the slice's `rsrc` flops are enabled by its flop of the R issue valid lead.

- **R0, R1:** the 8-bit row index of the payload's `phys_src`, binary, on the wire (the zero register selects nothing), decoded to `sel_hi`/`sel_lo` in the slice in A, read, merged with the MIU write-through (R unit tab) and flopped into `rsrc` (64 flops a slice). The path from the RCU port: fanout to the 32 slices about 2.5, decode 2, read 11.0, write-through 2, about 17.5 within RCU's input budget of 18 on `phys_src0/1` (OOE out 7, OA rev 336).
- **MW:** the slice picks, in T−1 from its own inputs, the one MIU slot whose `secmask` covers its byte section k (one per bank per cycle, asserted), and loads every cycle {row index (8, binary, decoded in T), the slot's `active_mask` for the slice's 4 lanes (4), `dst_pos` (2), valid (1)}.

That is about 15 ungated flops a slice (MW's), about 11% of its allowance (2% of 6,574 = 131) and about 480 across the 32 slices. The binary R0/R1 selects of RI-9 (16 a slice) went with RA-39's payload-wire read.

**Write data and masks.** Write data goes from the port straight into the rows' D, with no per-slice data flop, so LW lands in A+6 and MW in T. MW masks a 4-bit load's byte to its low nibble in the slice (and, under `FULL_ROW`, everything above `dst_width`): RCU does it, so MIU's upper bits never matter. A write whose lane mask has none of the slice's 4 lanes set does not clock the slice's row: each port's hit includes the OR of its lane mask over the slice's lanes.

**D input and enable, per row r of bank k:**

- `hit_p[r] = v_p & sel_hi_p[r>>4] & sel_lo_p[r&15]` for each port p.
- `row_en[k][r] = OR over p of hit_p[r]`: about 4 NGD from flops (AND3 then OR4), inside CG-2's 8.
- `D[r][l] = OR over p of (hit_p[r] & lmask_p[l] & data_p[l])  |  (~(OR over p of (hit_p[r] & lmask_p[l])) & Q[r][l])`. The hold term keeps unwritten lanes (loads, the copy) under the row's one enable, the AND-OR-on-D form the coding style allows, so the group stays 32 flops.
- At most one p hits a row in a cycle (asserted: renaming gives each in-flight write its own register slice, and section ownership keeps two writes of one cycle on different banks).

**Migration's use of R ports.** A demotion row is read on R2 in A+1 of a cycle whose R op does not read R2; a restore row is written on RW in A+2 of a cycle whose R op writes no GPR (Migration tab). Neither adds a port.

## Sizes (for the implementation's checks)

| Item | Count |
| --- | --- |
| Row flops | 192 × 1,024 = 196,608 |
| Read select flops | 10 ports × 28 × 32 slices = 8,960 (with the 4 write ports, 12,544) |
| Read mux | 10 × 1,024 bits, each a 192:1 AND-OR |
| Write D-mux | 4 ports + hold, per bit |
| Gate groups | 6,144 slice rows of 32 flops |
| Slices / chunks | 32 slices of 6,550 flops (6,144 rows, 392 selects, control); 8 chunks of 4 slices |
