<!-- design-snapshot url=https://claude.ai/artifact/4k7VrEKJG4KUgMYG1Qz8mB tab=Predicate_file rev=5 exported=2026-11-04 status=living -->
> **Snapshot: do not edit.** Exported from *CCV RCU Architecture*, tab *Predicate file*, at revision 5 on 2026-11-04 ([live doc](https://claude.ai/artifact/4k7VrEKJG4KUgMYG1Qz8mB)). The live doc is the source; it is a living document, so this copy is refreshed whenever it changes. This copy pins what the repo was built against; see [README.md](README.md).

# Predicate file

The predicate file, `rcu_pred`, is 48 rows × 32 bits read in A and written through masked write ports; the only forward it needs is from MIU's `pred_result` in the guard's own cycle, and every merge reads the old destination at write time, when it is already final.

## Organisation

- Row p, bit l = lane l's bit of physical predicate p. Rows 0 to `CCV_P_PRED_REGS` − 1 (48). The zero predicate `CCV_P_PRED_ZERO` (63) has no row: it reads 0 and is never written (A-64, asserted).
- Gate group = one row (32 flops). No reset: OOE maps a launched warp's predicates to the zero predicate (A-29).
- Predecode, as for GPR rows: `psel_hi[5:0]` = one-hot of p\[5:3\], `psel_lo[7:0]` = one-hot of p\[2:0\]; 14 flops per select.

## Read ports

| Port | Cycle | Row source | Purpose |
| --- | --- | --- | --- |
| G0-G8 | A | `phys_pred_guard` of slot s, on the wire (decoded combinationally) | guard of every lead slot; for a `pdata` op the data predicate; for a predicate store the store data |
| RA, RB | A | R op `imm`\[5:0\] and `imm`\[12:7\] (negates `imm`\[6\], `imm`\[13\]), TI-1 | predicate sources of pand, por, pxor; vote and ballot's `ps` (RA-29 proposes it rides `imm`\[6:0\] the same way) |
| OL0-OL3 | A+6 | lane descriptor's `phys_pred_old_dst` | merge source for a lane op's predicate result |
| OR | A+2 | `rpres_a1`'s old destination | merge source for an R op's predicate result |
| OC0-OC3 | A+2 | the predicate-only copy's `phys_pred_old_dst` | the copy's data |
| D0-D3 | A+1 of a demotion read cycle | the pairing entry's `pred_map`\[0..3\] | demotion row 16 |

No old-destination read needs a forward: OOE issues an op only when its old destination is ready (A-43 makes it a source), and nothing writes a register after it is ready.

## The guard path (stage I, the critical predicate path)

1. Decode `phys_pred_guard` (on the wire, arriving by 2 NGD) and read the row, 48:1 AND-OR: about 12 NGD.
2. **MIU forward.** For each MIU slot j with `mdat_v_q[j]`, lead `pred_we` and lead `phys_pred` equal to the guard's index (6-bit compare, in parallel with the read), substitute `(row & ~m_j) | (pred_result_j & m_j)`, m\_j the lead `active_mask`, `pred_result_j` from the wire. About 2 NGD after the read.
3. Negate by `pred_neg`; force all ones if the op is not `guarded` or is `pdata`: 1-2 NGD.
4. `active = issue_mask & guard`: 1 NGD, about 17 NGD in all, into `active_a[s]` and, for S slots, `sec_pred_bit_a`.
5. The branch outcome: OR over 32 lanes, about 5 NGD more, into `lead_br_taken_a` (22 NGD). `lead_br_mask_a` = `active` (17).

**The split guard read (RA-32, OA's rev 306).**

There is no pre-agreed fallback to resolving branches a cycle later. That costs more than 0.5%, which makes it Daniel's call, not a design default. Instead, OOE leads R's guard physical predicate in RA-31's lead slice, a cycle before the payload. With it, the guard predecode moves to A−1:

- In A−1, `pred` predecodes the lead's guard index into `psel` flops.
- In A, the guard read is an AND-OR from those flops (about 5 NGD), followed by the MIU forward mux, `active` and the branch outcome.
- That takes the path from about 22 to about 16 NGD, and the input-port budget of `pred` falls to the default 12.

The lane slots' guards (G0-G7) take the same lead if OOE sends it for every slot. Otherwise they stay on the A-cycle read, which is not on the branch path.

This lands when OI's NGD fits the lead slice at select. Until then the spec's 22-NGD path stands, and the implementation agent measures it (M1).

Only MIU writes need the forward: a lane producer lands at its A+6 and its consumer's A is at least A+7; an R producer lands at A+2 and its consumer's A is at least A+3; a predicate-only copy's consumer waits for the load. A guard read of a row that a non-MIU port writes in the same cycle is asserted never to happen.

For a `pdata` op the forwarded, negated value is also sent to the lanes as `sec_pred_data`. For a predicate store (`mem_kind` pred-store) the raw row, without the negate, is the store data in lane 0 (the stub's rule, kernel.cpp 3156-3160).

## Write ports

Each port presents a row select, a 32-bit lane mask m and 32-bit data d. Per row p:

- `hit_q[p] = v_q & psel_hi_q[p>>3] & psel_lo_q[p&7]`;  `row_en[p] = OR over q of hit_q[p]`.
- `D[p] = (Q[p] & ~M) | Dv`, with `M = OR over q of (hit_q[p] ? m_q : 0)` and `Dv = OR over q of (hit_q[p] ? (d_q & m_q) : 0)`.
- Ports hitting the same row in one cycle must have disjoint masks (asserted). That case is legal: a ld.pred's copy (inactive lanes) and its MIU return (active lanes) may land together.

| Port | W | Row | m | d |
| --- | --- | --- | --- | --- |
| PL0-PL3 (lane op whose lead section is k, `pred_we`) | A+6 | `phys_pred_dst` | all ones | per lane l: `active[l]` ? `lane_rcu_res`\[l\].`sec_pred_out`\[k\] : old destination\[l\] (OLk); with `merge_en` = 0 the old destination is 0 and OLk is not read, as `merge_data` is 0 for a GPR (RI-6 (d)) |
| PM0-PM3 (MIU slot j, lead `pred_we`) | T | lead `phys_pred` | lead `active_mask` | `pred_result` |
| PR (R op, `r_wpred`) | A+2 | `phys_pred_dst` | all ones | the R result merged with the old destination (OR) by the op's merge mask (R unit tab) |
| PC0-PC3 (predicate-only copy in S slot k) | A+2 | `phys_pred_dst` | \~`active` | old destination (OCk) |
| PG0-PG3 (restore row 16) | A+2 of a restore write cycle | `pred_map`\[p\] | all ones | `row_data`\[32p+31:32p\] |

The enable cone is AND3 then an OR over 17 hits: about 6 NGD from flops. The lane, R and copy ports' selects are predecoded into their descriptors in A; MIU's are predecoded from the lead on the wire in T−1, as for GPR loads.

## Sizes

| Item | Count |
| --- | --- |
| Row flops | 48 × 32 = 1,536 |
| Read ports | 24, each 48:1 × 32 bits |
| Write ports | 17 |
