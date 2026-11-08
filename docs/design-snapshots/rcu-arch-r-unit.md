<!-- design-snapshot url=https://claude.ai/artifact/4k7VrEKJG4KUgMYG1Qz8mB tab=R_unit_and_crossbar rev=23 exported=2026-11-08 status=living -->
> **Snapshot: do not edit.** Exported from *CCV RCU Architecture*, tab *R unit and crossbar*, at revision 23 on 2026-11-08 ([live doc](https://claude.ai/artifact/4k7VrEKJG4KUgMYG1Qz8mB)). The live doc is the source; it is a living document, so this copy is refreshed whenever it changes. This copy pins what the repo was built against; see [README.md](README.md).

# R unit and crossbar

The R unit, `rcu_r`, executes one op a cycle from issue slot 8 in three stages: predicates and the branch outcome in A, every compute in A+1, the write in A+2. Its two compute sources, R0 and R1, are read a cycle early, in A, into flops; R2, the merge source, is read in A+1 (Early R source read, below; RA-39, taken: OA rev 336). Collectives use the same stages, so a collective is readable at A+3, inside its contracted `CCV_LAT_COLLECTIVE` = 5, and the R pipeline needs one GPR write port, not two.

**The A+2 rule (RA-29 (a), agreed by AR, TI and OA).** Every R-pipe class writes the GPR and predicate files at exactly A+2: RCU-only ops, call's link and every collective mode. That is what lets R share one GPR write port (RW).

- A future mode that needs a second crossbar cycle breaks the rule. It needs a fifth port or an R hold, and comes back as a row.
- The stub asserts the rule, and so does `rcu_r`: every `rres_a1`/`rpres_a1` load is followed by its write in the next cycle.
- Collectives and RCU-only ops are one issue class at R: one op a cycle on slot 8, both counted in the idle-R run. Collectives keep their own latency class and done slot 6.

## Early R source read (RA-39, taken 2026-11-04: OA rev 336, option (2))

**Why.** The bank read measures 8.3 NGD from the select flops at 192 rows, 11.0 with the fanout term (Register file tab), against the 7 the Partition tab budgeted. check-ngd enforces the fanout term since 2026-11-04 (RA-33, TI rev 299). With read, alignment and compute all in A+1, `ret` comes to about 27 and the register-index shfl about 26 with the fanout term, both over 25.

**What.** R0 and R1 are read in A instead of A+1, straight from the issue payload's `phys_src`\[15:8\] and \[7:0\] (no lead field: the predicate file's own form for guards), and each bank slice flops its own raw read of both into `rsrc`, at A's edge. Alignment and every compute are in A+1 in `rcu_r`, from flops. The write stays at A+2, so the A+2 rule, `CCV_LAT_RCU` = 3, the collective timing and both done slots are unchanged. The read lands in the slice, not in `r`, because a select on a port read out through the slice would be input to output through `rcu_bank_slice`, which the depth rules forbid.

| Cycle | R0, R1 | R2 |
| --- | --- | --- |
| A | rows from the payload's `phys_src` on the wire, decoded in each slice, read, MIU write-through, into the slice's `rsrc` (raw, unaligned) | rows from the payload, predecoded (as before) |
| A+1 | `r` aligns `rsrc` to the source's pos and width and computes | read, aligned, into `old` (as before) |
| A+2 | write (as before) | merge in the write (as before) |

**Why it is safe (OA checked it class by class, rev 328).** Every class's contracted latency is issue to readable: a write at W is readable from W+1 = A + LAT, and no bypass reaches an R-slot consumer (V-48), so R0 and R1 read the PRF in A\_c, a cycle earlier than the rest of the RCU reads. Lane, SFU, R and collective producers, the copies and completion-driven wakes all land before A\_c. **The one exception is an L1-hit load:** `CCV_LAT_L1_WAKE` puts the consumer's A in the very cycle T that MIU's payload lands, and MW writes in T. R0 and R1 therefore take an **MIU write-through** in A. OOE is unchanged and nothing waits.

**What it needs.**

- From OOE: since RA-43 the R slot's phys\_src comes as lead\_phys\_src at A−1, moved from the payload and captured in RCU's lead flops, and R's imm\[31:0\] as lead\_rpsrc (RA rev 108/109; OA-387, OA-390). What follows is its earlier form. `phys_src`\[15:8\] and \[7:0\] of the R slot on `ccv_ooe_rcu_issue`, driven straight from the issue register. Budgets (OA revs 336-337): RCU input 19 (lapsed: since the boundary flops, AR rev 285, RCU has 25 from its interface flop and OOE drives it at 0), OOE output 6 (RI measured 18.4, RI rev 8). The lead fields `lead_r_src0/1` of the earlier form are withdrawn (OI-115: muxed in select they put `ooe_sched` at 38.8 NGD against its 30.5).
- In each `rcu_bank_slice`: `rsrc`, R0 and R1 raw for its byte section of its 4 lanes, 2 × 4 × 8 = 64 flops (2,048 across the 32 slices, as before), enabled by the slice's flop of the R issue valid lead (CG-5). `lead_src_used` is not used: a source the op does not read is read anyway, a small DCGE cost. R0 and R1 have no select flops (the RI-9 binary selects go: 16 ungated flops a slice, 512 in all).
- Migration is unchanged: it uses R2 and RW only.
- **The MIU write-through (RA-39, RA rev 70).** The slice compares the payload's row with its own MW select flops (row, lane mask, section, valid; Register file tab, lead-loaded ports) and, on a match, substitutes per lane and section the MW write data already on its D inputs for the bank's read. That is the row as it will stand after T, so every source width and pos on it is right, and forwarding every MW write that lands in A is a correct superset of the L1-hit case. No compare of pos and no lead copies in `r`: the 180 MIU lead flops, 8 match flops and the \~10,000-cell post-alignment forward of the earlier form are gone.

**Rejected: compute in A+2 and write in A+3.** It moves every R write a cycle later. Either `CCV_LAT_RCU` grows from 3 to 4, which slows every predicate and movi chain, or only collectives move, and their writes collide with the next cycle's RCU-only writes on RW. `ret`'s done payload would also move to A+3, colliding on slot 5 with a branch issued a cycle after it unless R holds for a cycle, which OOE's select would have to know.

## Per-stage registers

| Register | Loaded at | Contents | Enable |
| --- | --- | --- | --- |
| `r_a` | A's edge | r\_kind, rob\_tag, done\_row, issue\_mask, `active`, `imm`, dst row predecode, dst pos and width, src pos and width (R0, R1), old-destination pos, `phys_pred_dst` and old-destination predecode, `r_wgpr`, `r_wpred` | `iss_v_q[8]` |
| `rpsrc_a` | A's edge | RA and RB values, negates applied, MIU forward applied (32 bits each) | `iss_v_q[8]` |
| `rlow_a` | A's edge | one-hot of the lowest set bit of `active` (32 bits); a flop of rcu\_pred, which computes active, read by rcu\_r (as built, RI; RA rev 73) | `iss_v_q[8]` |
| `rres_a1` | A+1's edge | GPR result `new[32][32]` right-aligned, old destination `old[32][32]` right-aligned, lane merge mask, dst predecode, pos, width | `r_v_a` (flop of `iss_v_q[8]`), or migration's restore grant (then the staged row) |
| `rpres_a1` | A+1's edge | predicate result (32), merge mask (32), pd and old-destination predecode | `r_v_a` |
| done slot 5 or 6 payload | A+1's edge | rob\_tag, done\_row; slot 5 adds branch\_taken, branch\_mask, aux | `r_v_a` |
| rsrc | A's edge | in each bank slice, not r: R0 and R1 raw for its section and 4 lanes, MIU write-through applied, 64 flops (2,048 in all); r aligns them in A+1 (RA-39) | the slice's flop of the R issue valid lead |

In A+2 the RW port writes `steer(merge(new, old, mask), pos)` into the sections `secmask(width, pos)`, with `merge` per lane = mask ? new : old and `steer` the left shift by 8·pos. Merging in A+2 rather than A+1 keeps the merge off the crossbar path, at the cost of 1,024 flops for `old`.

## Ops

`v(R0)` is R0's read, aligned to its source's pos and width and zero-extended; `old` is R2's read aligned to the old destination's pos and width; `em` = elemmask(dst width). An op's merge mask is `active` unless the row says otherwise.

| Op | A | A+1 compute | Writes (A+2) | Done |
| --- | --- | --- | --- | --- |
| `bra`, `bra.short` | `active` = issue\_mask (unguarded); `lead_br_taken_a` = OR(active), `lead_br_mask_a` = active | none | none | slot 5: valid A+1 with lead; payload A+2 with branch\_taken = OR(active), branch\_mask = active, aux = 0 |
| `bra.pred` | `active` = issue\_mask & guard | none | none | as `bra` |
| `call`, `call.short` | as `bra`; R2 predecode for rd's old destination | new = link & em, link = `imm`: DEC marks the call with `imm_kind` 6 and OOE puts pc\[31:0\] + length there (RA-18, settled by AR and OA) | GPR rd | as `bra` |
| `ret` | `active`; `rlow_a` | `aux` = OR over l of (`rlow_a`\[l\] & v(R0)\[l\]); `same`\[l\] = `active`\[l\] & (v(R0)\[l\] == aux) | none | slot 5: valid A+1, lead fields 0 (don't-care); payload branch\_taken = OR(active) (taken whenever any lane is active, since the lowest active lane matches itself), branch\_mask = `same`, aux |
| `pand`, `por`, `pxor` | RA, RB into `rpsrc_a` | p = RA op RB | predicate pd, merge mask = issue\_mask | slot 5, payload A+2, branch fields 0 |
| `pmov pd, #mask` | none | p = `imm` | predicate pd, merge mask = issue\_mask (RA-19 settled: the ISA's invariant 10; ccv-sim merges since CP-75; the stub still writes all 32 lanes until TI aligns it) | slot 5 |
| `movi`, `movi48` | `active` = issue\_mask | new = `imm` & em, every lane | GPR rd | slot 5 |
| `shfl.idx` (immediate index) | `active` = issue\_mask & guard | new\[l\] = v(R0)\[`imm`\[4:0\]\] & em | GPR rd | slot 6: valid A+1, payload A+2 |
| `shfl.idx` (register index) | as above | idx\[l\] = v(R1)\[l\]\[4:0\]; new\[l\] = xbar(v(R0), idx)\[l\] & em | GPR rd | slot 6 |
| `shfl.up`, `.down`, `.bfly` | as above | idx\[l\] = l − c, l + c, l XOR c with c = `imm`\[4:0\]; out of 0..31 → idx\[l\] = l; no segment or clamp (\[26:24\] reserved) (O-85) | GPR rd | slot 6 |
| `vote.any` | RA (ps) | r = OR over active lanes of ps; p = {32{r}} | predicate pd, merge mask = active | slot 6 |
| `vote.all` | RA (ps) | r = AND over active lanes of ps (1 when none active) | predicate pd, merge mask = active | slot 6 |
| `ballot` | RA (ps) | new\[l\] = ps & active (32 bits, truncated to rd's width by em); written on active lanes only | GPR rd | slot 6 |
| `unballot` | R0 (rs) | diagonal (O-85): p\[l\] = bit l of lane l's own aligned rs, a fixed wire per lane; 0 for l at or past rs's element width | predicate pd, merge mask = active | slot 6 |

The collective semantics are O-85: RA-20, adopted by Daniel. Normative text: ISA §3 Format G, "What the collectives compute", compiler a70f392.

- The participating lanes are `active` = issue mask AND guard, for every collective (Format K's unguarded vote and ballot have guard = true). Only participating lanes are written.
- A source lane is read whether or not it participates.
- The register-index form's index register is a renamed source read on R1. Its architectural number sits in \[22:19\], with \[23\] zero, which is DEC's concern.
- vote's and ballot's ps rides in `imm` in pand/por's first-source format (RA-29 (e)).

Barriers do not reach the RCU in the first build (TI-40, TI-42; RA-25 closed by TI and OA).

## Crossbar

`rcu_xbar` is a combinational inner helper of `rcu_r` (timed as its parent's logic, and held alone to 16 NGD until instantiated). Inputs: `src[32][32]` (v(R0)), `idx[32][5]`. Output: `out[l] = src[idx[l]]`. Each output lane decodes its index to a 32-bit one-hot (3 NGD) and takes a 32:1 AND-OR of 32-bit words (6 NGD): about 9 NGD, 32 × 32 × 32 AND-OR cells. The immediate-index form uses the same structure with every `idx[l]` equal. `ret` uses the one-hot `rlow_a` into the same kind of AND-OR, separately. `unballot` needs no crossbar: lane l takes bit l of its own rs.

## Depth (estimates, with the fanout term, for the implementation to measure)

| Stage | Path | Estimate (NGD) |
| --- | --- | --- |
| A | `phys_src` from the interface flop 0, fanout to the 32 slices about 2.5, binary decode in the slice 2, R0 or R1 read 11.0 (measured, with fanout), MIU write-through mux 2, into the slice's `rsrc` | measured 18.4 (15.9 in the slice + 2.5 fanout), RCU input within 25 from the interface flop |
| A | the write-through match: row compare against the MW select flops 3, AND lane mask, section and valid 1, fanout to the 64 bits about 3, after the port's 4.5 | about 11.5, in parallel |
| A+1 | R2 read 11.0, align 2, into `old` | 13 |
| A+1 | register-index shfl from `rsrc`: align 2, select fanout 1, decode 3, crossbar 6, em 1, fanout of the one-hots about 3 | 16 |
| A+1 | `ret` from `rsrc`: align 3, pick 5 (`aux`), broadcast about 2, compare 5, AND 1, into `branch_mask` | 16 |
| A+1 | `unballot` from `rsrc`: align 3, bit select 0 (a wire), into `rpres_a1` | 4 |
| A+1 | `vote`: OR or AND over 32 from `rpsrc_a`, into `rpres_a1` | 6 |

Every R path has 5 NGD or more of margin. Port budgets: `phys_src0/1` 25 from the interface flop (at `rcu_bank_slice`, fanout included); `bank` out 11 on R2; `rsrc` out of the slice from flops, `r` in 14. If OA cannot confirm RA-39's hazard condition for some class, the fallback is a late wake of R consumers by one cycle for that class, a bypass-table cell on OOE's side, not a change here.
