<!-- design-snapshot url=https://claude.ai/artifact/4k7VrEKJG4KUgMYG1Qz8mB tab=Register_file rev=4 exported=2026-11-02 status=living -->
> **Snapshot: do not edit.** Exported from *CCV RCU Architecture*, tab *Register file*, at revision 4 on 2026-11-02 ([live doc](https://claude.ai/artifact/4k7VrEKJG4KUgMYG1Qz8mB)). The live doc is the source; it is a living document, so this copy is refreshed whenever it changes. This copy pins what the repo was built against; see [README.md](README.md).

# Register file

The GPR file is four section banks, `ccv_rcu_bank` × 4, each 192 rows × 256 bits with 10 read ports and 4 write ports; every select is a pre-decoded one-hot held in a flop, so no row decode sits on a read path or a clock-enable cone. That is one write port fewer than RA-2's five: collectives execute in the R pipeline and share its port (R unit tab).

## Organisation

- **Bank k holds section k:** byte k of every lane's 32-bit word. Row r of bank k, bits \[8l+7:8l\], is lane l's byte k of physical register row r. A row of the four banks together is one 1,024-bit physical register row.
- **A register** is (row, position, width): it occupies sections `pos` to `pos + span − 1`, span = 4, 2, 1, 1 for width codes 0-3 (32, 16, 8, 4 bits). `secmask(width, pos)` names those sections.
- **Rows 0 to `CCV_P_PHYS_REGS` − 1 exist.** The zero register `CCV_P_PHYS_ZERO` (255) has no row: it decodes to no select, so it reads 0 and a write to it selects nothing (asserted never to happen, A-64). Rows 192-254 are never named (asserted).
- **Clock gate group = one row of one bank (256 flops),** enable `row_en[k][r]` below. No reset (OOE's A-29: no row is read before it is written).

## Row predecode

Every row index the RCU will use as a select is split at the edge before its use into two one-hots, stored in flops: `sel_hi[11:0]` = one-hot of r\[7:4\] (no bit for r\[7:4\] ≥ 12), `sel_lo[15:0]` = one-hot of r\[3:0\]. Row r is selected when `sel_hi[r>>4] & sel_lo[r&15]`, one AND level. 28 flops replace 192 per port, and the zero register and rows ≥ 192 fall out as no select. Read selects are decoded in A from the issue payload; write selects travel with the write's descriptor (lane, SFU, R) or are decoded from the MIU lead on the wire (load).

**Select fanout (RA-33, TI rev 286; Daniel chose option (a), 2026-11-02; TI builds it).** check-ngd's netlist is load-blind today: a select bit driving 1,024 cells times as one gate at fanout 4, while a real buffer tree adds ceil(log4(N/4)) inverter stages, 0.68 NGD each. RCU is built as if that cost were counted (TI's option (a)).

- Each read and write port keeps its own copy of `sel_hi`/`sel_lo` per bank and per section, as `(* keep *)` copies loaded together. The row AND for one bank and one section drives 64 bit-cells, which costs 2 stages, about 1.4 NGD. A single copy for all four banks would drive 1,024 cells, which costs 4 stages, about 2.7 NGD.
- Each `sel_hi` bit then drives 16 row ANDs, and each `sel_lo` bit drives 12, both at most 1 stage.
- Cost: 28 flops × 4 banks × 4 sections × 14 ports, about 6,300 flops (+2.7% of RCU). They load only when the port is used, so they gate with the port's valid.
- Write data is broadcast to 192 rows of a bank-section. It is registered per bank and per section as well, which costs 3 stages (about 2 NGD) on a path that is otherwise short.
- Every path budget in this tab carries its fanout stages. The implementation agent reports them beside check-ngd's number until the tool counts them.
- If Daniel picks (b), a stated fanout limit, the copies stay and are sized to that limit.

## Read ports (per bank k, read in A+1)

| Port | Row source (decoded in A) | Used by | Select flops' enable |
| --- | --- | --- | --- |
| L0, L1, L2 | `phys_src`\[15:8\], \[7:0\], `phys_src2` of the S op that owns section k | lane operands src0-src2 | `iss_v_q` OR over S slots 0..k |
| L3 | `phys_old_dst` of that op | `merge_data` | same |
| M0, M1, M2 | base, index, data source rows of the P op that owns pipe k | `rcu_miu_addr` base, index, store data | `iss_v_q` OR over P slots 0..k |
| R0 | R op `phys_src`\[15:8\] | shfl source, ret's rs, unballot's rs | `iss_v_q[8]` |
| R1 | R op `phys_src`\[7:0\] | register-index shfl's index | `iss_v_q[8]` |
| R2 | R op `phys_old_dst`, or a demotion row | merge source for movi, call, shfl, ballot; demotion | `iss_v_q[8]` OR migration's read grant |

The owner of section k is the lead (cont = 0) S slot j ≤ k whose `footprint` has bit k−j set; V-60 guarantees at most one. Memops follow the same rule over P slots, with pipe k ≡ section k: a memop's footprint is the union of its operands' sections, destination included (the schema's `CCV_PRF_MEMOP_READ_BITS` requirement, 3 × 256 bits per pipe). R ports read the same row in all four banks.

**Read mux:** `rd[255:0] = OR over r of (sel_hi[r>>4] & sel_lo[r&15] & row[r])`, built as 12 groups of a 16:1 AND-OR on `sel_lo`, each gated by its `sel_hi` bit, then a 12:1 OR. About 9-10 NGD from the select flops (to be confirmed by the implementation's unit at 32 rows, extrapolated).

**Alignment (R and M ports only).** A lane's word is {bank3, bank2, bank1, bank0}. Right-aligned value `v = (word >> 8·pos) & elemmask(width)`, elemmask = all ones, 0xFFFF, 0xFF, 0xF. A 4:1 byte mux plus the mask, about 2 NGD, using pos and width from `iss_*_a`. Lane ports send raw bytes; the lane swizzles (OOE doc, footprint rule).

## Write ports (per bank k)

| Port | Lands in | Row select | Data for lane l | Lanes written | Section k written when |
| --- | --- | --- | --- | --- | --- |
| LW (lane) | A+6 | lane descriptor `lwb_d[k]` at depth 6 (predecoded at A) | `lane_rcu_res` c\_l `result`\[8k+7:8k\] | all 32; the GPR copy writes only lanes with `active` = 0 | descriptor valid, the op owns section k, it writes a GPR |
| SW (SFU) | A+11 | SFU descriptor `swb_d` at depth 11 | the SFU second result (RA-3), byte k | all 32 | descriptor valid and k in the SFU destination's `secmask` |
| MW (load) | MIU payload cycle T | `mdat_lead_q[j]`, predecoded on the wire in T−1 | `load_data` lane word of slot j, shifted left 8·pos, byte k | lanes in the lead `active_mask` | `mdat_v_q[j]` and k in `secmask(dst_width, dst_pos)` of slot j, and phys\_dst is not the zero register |
| RW (R) | A+2 | `rres_a1` | R result (already merged with the old destination), shifted to pos, byte k; or a staged restore row | all 32 | R result valid and k in its `secmask`; a restore row writes all four |

**One load write per bank per cycle.** Four MIU slots can land in one cycle, so bank k's MW port takes the one slot j whose `secmask` covers k. Two slots covering the same bank in one cycle is an MIU contract breach (asserted; raised to AR as RA-28, since narrow loads in different pipes can name overlapping sections).

**D input and enable, per row r of bank k:**

- `hit_p[r] = v_p & sel_hi_p[r>>4] & sel_lo_p[r&15]` for each port p.
- `row_en[k][r] = OR over p of hit_p[r]`: about 4 NGD from flops (AND3 then OR4), inside CG-2's 8.
- `D[r][l] = OR over p of (hit_p[r] & lmask_p[l] & data_p[l])  |  (~(OR over p of (hit_p[r] & lmask_p[l])) & Q[r][l])`. The hold term keeps unwritten lanes (loads, the copy) under the row's one enable, the AND-OR-on-D form the coding style allows, so the group stays 256 flops.
- At most one p hits a row in a cycle (asserted: renaming gives each in-flight write its own register slice, and section ownership keeps two writes of one cycle on different banks).

**Migration's use of R ports.** A demotion row is read on R2 in A+1 of a cycle whose R op does not read R2; a restore row is written on RW in A+2 of a cycle whose R op writes no GPR (Migration tab). Neither adds a port.

## Sizes (for the implementation's checks)

| Item | Count |
| --- | --- |
| Row flops | 192 × 1,024 = 196,608 |
| Read select flops | 10 ports × 4 banks × 28 = 1,120 |
| Read mux | 10 × 1,024 bits, each a 192:1 AND-OR |
| Write D-mux | 4 ports + hold, per bit |
| Gate groups | 768 rows of 256 flops |
