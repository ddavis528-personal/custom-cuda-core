<!-- design-snapshot url=https://claude.ai/artifact/4k7VrEKJG4KUgMYG1Qz8mB tab=Predicate_file rev=13 exported=2026-11-14 status=living -->
> **Snapshot: do not edit.** Exported from *CCV RCU Architecture*, tab *Predicate file*, at revision 13 on 2026-11-14 ([live doc](https://claude.ai/artifact/4k7VrEKJG4KUgMYG1Qz8mB)). The live doc is the source; it is a living document, so this copy is refreshed whenever it changes. This copy pins what the repo was built against; see [README.md](README.md).

# Predicate file

The predicate file, `rcu_pred`, is 48 rows × 32 bits read in A and written through masked write ports; the only forward it needs is from MIU's `pred_result` in the guard's own cycle, and every merge reads the old destination at write time, when it is already final.

*Reconciled to the RTL as built, RA rev 140 (phase 5). Path depths are RI's measurements (M1; RA rev 139 (1)).*

## Organisation

- Row p, bit l = lane l's bit of physical predicate p. Rows 0 to `CCV_P_PRED_REGS` − 1 (48). The zero predicate `CCV_P_PRED_ZERO` (63) has no row: it reads 0 and is never written (A-64, asserted).
- Gate group = one row (32 flops). No reset: OOE maps a launched warp's predicates to the zero predicate (A-29).
- Predecode, as for GPR rows: `psel_hi[5:0]` = one-hot of p\[5:3\], `psel_lo[7:0]` = one-hot of p\[2:0\]; 14 flops per select.

## Read ports

| Port | Cycle | Row source | Purpose |
| --- | --- | --- | --- |
| G0-G8 | A | `lead_guard_pred` of slot s at A−1, predecoded into the psel flops (RA-43; `phys_pred_guard` is not in the payload, TI 382) | guard of every lead slot; for a `pdata` op the data predicate; for a predicate store the store data |
| RA, RB | A | `lead_rpsrc[13:0]` at A−1, captured into `rimm_cr02h`: \[5:0\] and \[12:7\] the rows, \[6\] and \[13\] their negates (RA-43; R's payload carries no `imm`) | predicate sources of pand, por, pxor; vote and ballot's `ps` |
| OL0-OL3 | A+6 | lane descriptor's `phys_pred_old_dst` | merge source for a lane op's predicate result |
| OR | A+2 | `rpres_a1`'s old destination | merge source for an R op's predicate result |
| OC0-OC3 | A+2 | the predicate-only copy's `phys_pred_old_dst` | the copy's data |
| D0-D3 | A+1 of a demotion read cycle | the pairing entry's `pred_map`\[0..3\] | demotion row 16 |

No old-destination read needs a forward: OOE issues an op only when its old destination is ready (A-43 makes it a source), and nothing writes a register after it is ready.

## The guard path (stage I, the critical predicate path)

1. Read the row: every slot's guard index arrives as `lead_guard_pred` at A−1 (RA-43) and is predecoded into the psel flops (RA-32), so the A-cycle read is an AND-OR from flops.
2. **MIU forward.** For each MIU slot j with `mdat_v_q[j]`, lead `pred_we` and lead `phys_pred` equal to the guard's index (6-bit compare, in parallel with the read), substitute `(row & ~m_j) | (pred_result_j & m_j)`, m\_j the lead `active_mask`, `pred_result_j` from the wire. About 2 NGD after the read.
3. Negate by `pred_neg` (its lead copy, RA-43); force all ones if the op is not `guarded` or is `pdata`. The guard value is 16.9 NGD (gv).
4. `active = issue_mask & guard`, into `active_a[s]` and, for S slots, `sec_pred_bit_a`: 17.0 NGD at `act_cr03h`, 13.6 without the fanout term.
5. The branch outcome: OR over 32 lanes into `lead_br_taken_a`, 20.3 NGD (lbt). `lead_br_mask_a` = `active`.

**The split guard read (RA-32, OA's rev 306).**

Branches resolve in A: resolving them a cycle later costs more than 0.5%, which makes it Daniel's call, not a design default. Instead OOE leads every slot's guard physical predicate a cycle before the payload (RA-31's lead slice, RA-43), and the guard predecode moves to A−1:

- In A−1, `pred` predecodes the lead's guard index into `psel` flops.
- In A, the guard read is an AND-OR from those flops, followed by the MIU forward mux, `active` and the branch outcome.
- The target is at most 16 NGD without the fanout term and at most 25 with it (RA rev 139 (1)); measured, `act_cr03h` is 13.6 and 17.0. The worst flop-to-flop path in `rcu_pred` is 21.7 NGD.

Only MIU writes need the forward: a lane producer lands at its A+6 and its consumer's A is at least A+7; an R producer lands at A+2 and its consumer's A is at least A+3; a predicate-only copy's consumer waits for the load. A guard read of a row that a non-MIU port writes in the same cycle is asserted never to happen.

For a `pdata` op the forwarded, negated value is also sent to the lanes as `sec_pred_data`. For a predicate store (`mem_kind` pred-store) the store data in lane 0 is the forwarded row, `pst_a`: after the MIU forward, without the negate (the stub's rule, kernel.cpp 3156-3160).

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
| PC0-PC3 (predicate-only copy in S slot k; valid on every S issue, a non-copy writing the zero predicate, which selects no row) | A+2 | `phys_pred_dst` | \~`active` | old destination (OCk) |
| PG0-PG3 (restore row 16) | A+2 of a restore write cycle | `pred_map`\[p\] | all ones | `row_data`\[32p+31:32p\] |

The enable cone is AND3 then an OR over 17 hits, from flops. Descriptors carry binary rows: `rcu_pred` predecodes each port's row and old row into select flops the cycle before the write (`qrow`/`qorow_cr01h`). MIU's selects are predecoded from the lead on the wire in T−1, as for GPR loads.

## Sizes

| Item | Count |
| --- | --- |
| Row flops | 48 × 32 = 1,536 |
| Read ports | 24, each 48:1 × 32 bits |
| Write ports | 17 |
