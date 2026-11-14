<!-- design-snapshot url=https://claude.ai/artifact/4k7VrEKJG4KUgMYG1Qz8mB tab=Migration rev=14 exported=2026-11-14 status=living -->
> **Snapshot: do not edit.** Exported from *CCV RCU Architecture*, tab *Migration*, at revision 14 on 2026-11-14 ([live doc](https://claude.ai/artifact/4k7VrEKJG4KUgMYG1Qz8mB)). The live doc is the source; it is a living document, so this copy is refreshed whenever it changes. This copy pins what the repo was built against; see [README.md](README.md).

# Migration

Migration moves one warp's 16 GPR rows and 4 predicates between RCU and PCA, one 1,024-bit row per message: rows 0-15 are R0-R15 and row 16 is the predicate row. All of it lives in `rcu_mig`. It owns no PRF port (AR re:RA-6):

- A demotion reads GPR rows on **R2**, in A+1 of a cycle whose R op does not read R2. It reads the predicate row on the dedicated predicate ports **D0-D3**.
- A restore writes GPR rows on **RW**, in A+2 of a cycle whose R op writes no GPR. It writes the predicate row on the dedicated predicate ports **PG0-PG3**.

OOE's idle-R rule (K = 4, OOE's side) guarantees progress: while a migration is active, slot 8 issues nothing in at least one cycle of every 4. Such a cycle frees both R2 and RW, so 17 rows take at most 68 cycles each way.

## Channels and what RCU takes from them

| Channel | Dir | Fields RCU uses | Fields RCU drops |
| --- | --- | --- | --- |
| `ooe_rcu_map` (222 b) | in | `warp_id`, `direction`, `gpr_map` (16 × 8), `pred_map` (4 × 6) | `gpr_pos`, `gpr_width` (OOE keeps them) |
| `rau_rcu_mig` (6 b) | in | `warp_id`, `direction` | none |
| `rcu_pca_mig` (1034 b) | out | `warp_id`, `mig_row`, `row_data` | none |
| `pca_rcu_mig` (1034 b) | in | `warp_id`, `mig_row`, `row_data` | none |

None of these four channels is fixed-latency, so the stall rule applies (next section). RCU never asserts stall on the two inbound channels it receives from OOE and RAU, nor on `pca_rcu_mig`. It holds a PCA row back by withholding credit, as TI-13 requires: a returned credit means the row is written. It holds an `ooe_rcu_map` or `rau_rcu_mig` message the same way, until its pair launches: the pairing entry is the credit, and returning it at landing would let the sender overrun the queue (RI-3, intended). Behind a busy engine that is up to `CCV_TIER1_WARPS` − 1 migrations of 17 rows each, every row paced by PCA's credits, so with every warp parked a third warp's pair waits past `CCV_P_TIMEOUT_N`. Both channels are therefore the backpressured class, held to `CCV_P_TIMEOUT_BP` (RI-3; TI marks them in the schema).

## The stall-safe sender pattern (all of RCU's non-fixed-latency outputs)

A stall on the wire in cycle t forbids a valid in t+1. `ccv_common_chk_credit` checks the stall that is 1 cycle older than the valid. The valid flop that drives t+1 therefore has to see the raw stall input of cycle t. CG-5, however, forbids an input in any enable cone. So:

- `want` is computed in t from RCU's own flops, plus the slot-8 decode for the R2/RW test, which is data, not an enable.
- The valid flop is written every cycle, ungated, with `D = want & ~<ch>_stall`.
- Every state change that the send causes (row counter, credit counter, payload register) is enabled by that flopped valid, one cycle later. The next cycle's `want` sees the advance through a combinational `+ valid_q` term on the flops.

The same pattern covers the two other credit counters RCU keeps for non-fixed-latency outputs (the done tab lists them).

## Pairing (A-45)

A map and a command pair by (`warp_id`, `direction`) and may arrive in either order. Each pairing queue is `CCV_TIER1_WARPS` = 4 entries deep, a derived value, not a literal. The bound is safe for two reasons (RA-28 (d), AR):

- RAU holds at most `CCV_TIER1_WARPS` migrations between command and `ccv_pca_rau_mig_done`.
- OOE sends a map only for a migration RAU has started.

So neither queue ever holds more unpaired halves than it has entries, and the two queues can never fill with halves that do not match. A require ties each channel's credit depth to at least the queue depth.

| Register | Width × entries | Enable | Meaning |
| --- | --- | --- | --- |
| `mig_mq_v[i]` | 1 × 4 | qv\_en: land or launch or kill drop | entry holds a map |
| `mig_mq[i]` | (5 + 1 + 128 + 24) × 4 = 632 | land into i | `{warp, dir, gpr_map, pred_map}` |
| `mig_cq_v[i]`, `mig_cq[i]` | (1 + 6) × 4 | qv\_en: land, launch, kill drop | `{warp, dir}` |
| `mig_mq_free`, `mig_cq_free` | 4 one-hot each | qv\_en | the lowest free entry of the `_v` flops' next values (after this cycle's land, launch and kill drop), so lands on consecutive cycles take different entries (RI-6 (b)) |
| `mig_dpick`, `mig_rpick` | 1 + 4 + 4 each | every cycle | the flopped picks. Demote: the lowest map entry that has a matching command, and its command entry. Restore: the paired map and command of the restore FIFO head's warp. |

- **Landing.** The valid input is flopped in T−1 (`mig_mq_rxv`). The payload lands in T, into the entry that `mig_mq_free` names, with that entry's write enable driven by the flopped valid. Credits guarantee a free entry. Commands land the same way.
- **Match.** `m[i][j] = mq_v[i] & cq_v[j] & (mq[i].warp == cq[j].warp) & (mq[i].dir == cq[j].dir)` is about 5 NGD. The demote and restore priority picks (16 → one-hot) add about 6 NGD. Both are flopped. An entry that lands in T can be picked at the end of T+1.
- **Launch.**
  - A demotion launches at the edge that ends a cycle in which `mig_dpick.v & ~dm_busy` holds.
  - A restore launches when mig\_rpick.v & \~rs\_busy holds; mig\_rpick is the pair of the restore FIFO head's warp, so the head is valid and its warp is the picked warp (see Restore).
  - Launch copies `{warp, gpr_map, pred_map}` (157 b, a 4:1 one-hot AND-OR) into the engine, clears both entries, and sets both channels' credit-return flops. The credits are on the wire the next cycle.
  - In cycles (RA rev 138, RI-45, 28cd347a): the launch is the edge that ends the flopped pick's cycle, c0, and demote and restore count from c1. A PCA row enters the restore FIFO the cycle after it lands, and from then it is the head a restore launch sees (option A, RI-22 (7)). The model matches the RTL here; the four \*\_demote block lock-step runs are the check.
- **Map checks** are assertions only, no logic:
  - A restore map names no row 255 and no predicate 63 (A-64).
  - No two registers of a restore map share a row (TI-25).

## Demotion engine

| Register | Width | Enable | Meaning |
| --- | --- | --- | --- |
| `dm_busy` | 1 | launch, last row sent, kill | engine owns a warp |
| `dm_warp`, `dm_gpr[16]`, `dm_pred[4]` | 5, 128, 24 | launch | the paired map |
| dm\_oh | 18 | `dm_v_q` or launch | next row to send, one-hot over rows 0..16 and done; row 16 is its own bit |
| `dm_wcnt` | 2 | launch or `dm_wcnt != 0` | wake lead counter, loaded with `CCV_WAKE_LAT` − 1 |
| `dm_cred` | 3 | `dm_v_q` or credit return (flopped) | `rcu_pca_mig` credits, reset `CCV_CREDIT_DEPTH` |
| `dm_v_q` | 1 | every cycle | `rcu_pca_mig_valid` (the wire) |
| `dm_r16_q` | 1 | every cycle | the row in flight is the predicate row |
| `dm_pay` | 1034 | `dm_v_q` | `rcu_pca_mig_payload` (the wire) |
| `dm_wake_q` | 1 | every cycle | `rcu_pca_mig_wake` (the wire) = `dm_busy_next` |

Per cycle, with the demotion row's decision cycle A:

1. **A (stage I).**
   - Next row: dm\_oh, shifted one place by dm\_v\_q. Remaining credits: cred = dm\_cred - dm\_v\_q + cred\_ret\_q.
   - `dm_want = dm_busy & (dm_wcnt == 0) & (row <= 16) & (cred != 0) & (row == 16 | ~r2_busy)`, where `r2_busy = issue_s8_valid_q & r_reads[2]` comes from the slot-8 decode in A.
   - dm\_v\_q <= dm\_want & \~stall\_q, where stall\_q (ostq\_cr03h) is rcu\_pca\_mig\_stall flopped first, as CG-5 requires. At most one row follows a stall, and RESCUE\_DEPTH holds it (RA rev 110).
   - For a GPR row, the R2 port's predecode flops (`sel_hi`/`sel_lo` of every bank's R2) load the predecode of `dm_gpr[row]`: a 16:1 mux on flops (about 4 NGD), then the predecode (3 NGD), then the 2:1 port mux against the R op's R2 source (2 NGD). When the R op owns R2 they load the op's source. When neither does, they load 0.
   - For the predicate row, D0-D3's predecode flops load dm\_pred\[p\]; their leads start from row 14 on.
   - dm\_r16\_q <= dm\_oh's row-16 bit.
2. **A+1 (stage R).** R2 reads the row in all 4 banks, and D0-D3 read the 4 predicates. `rcu_pca_mig_valid` = `dm_v_q` is on the wire. At the end of A+1, enabled by `dm_v_q`:
   - `dm_pay.row_data` = `dm_r16_q ? {896'b0, D3, D2, D1, D0} : {R2.b3, R2.b2, R2.b1, R2.b0}`. P\_p sits at \[32p+31:32p\], lane l at bit 32p+l.
   - dm\_pay.mig\_row = the row being read, encoded from dm\_oh; dm\_pay.warp\_id = dm\_warp.
   - dm\_oh advances. dm\_cred decrements.
3. **A+2.** `rcu_pca_mig_payload` = `dm_pay` is on the wire.

**Zero registers need no logic.** Row 255 and predicate 63 predecode to no select, so their AND-OR reads return 0. That is what the demotion contract asks for: "a demotion map may name zero registers (RCU sends zeros)".

**Wake lead.** Launch at the edge ending c0 sets `dm_busy` and loads `dm_wcnt` = 3, and `dm_wake_q` goes high in c1. The first decision cycle can be c4, so its valid is in c5, which is wake + `CCV_WAKE_LAT`. Wake stays high while `dm_busy` holds. Each later valid therefore has a wake in its window.

**End.** At the edge where `dm_v_q` sends row 16, `dm_busy` clears and `dm_wake_q` drops. Its payload still goes out the next cycle, from `dm_pay`.

**Read order and stability.** Rows go out in order 0..16, one per sent cycle (the mig-row-order control stays failing). RCU reads the PRF live, with no snapshot. That is safe only if no write to the warp's 17 rows is in flight and none of them is reallocated until RAU's done (RA-24). The checker chk\_dm\_stable asserts that no GPR or predicate write port selects a row in dm\_gpr or dm\_pred while dm\_busy. It is in the model only (rcu\_core.cpp:266); the RTL is held to it through lock-step against the model.

**Timeline, no R-op conflict, credits available.**

| Cycle | c0 | c1 | c2 | c3 | c4 | c5 | c6 | c7 | ... | c20 | c21 | c22 |
| --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- |
| Event | pick, launch edge | wake=1 |  |  | decide row 0 | valid row 0; decide row 1; R2 reads row 0 | payload row 0 | payload row 1 | ... | decide row 16 (D0-D3) | valid row 16 | payload row 16; busy 0 |

## Restore engine

| Register | Width × entries | Enable | Meaning |
| --- | --- | --- | --- |
| `rs_busy` | 1 | launch, row 16 written, kill | engine owns a warp |
| `rs_warp`, `rs_gpr[16]`, `rs_pred[4]` | 5, 128, 24 | launch | the paired restore map |
| `rs_f_v[i]`, `rs_f_dead[i]` | 2 × 4 | land, pop, kill | FIFO entry holds a row; the row is a killed warp's |
| `rs_f[i]` | (5 + 17 + 1024) × 4 = 4,184 | land into i | `{warp, row one-hot (17, decoded at land), row_data}` |
| `rs_hd`, `rs_tl` | 4 one-hot each | pop, land | head and tail pointers |
| pwq, prowq, pdatq | 1,034 in all | the flopped pca\_rcu\_mig valid | the PCA capture: warp, mig\_row and row\_data of the row that lands; it enters the FIFO the next cycle |
| `rs_v_a1`, `rs_v_a2`, `rs_last_a1` | 1 each | every cycle | a restore write is in its A+1 / A+2; the A+1 write is row 16 |
| `rs_sel_a1`, `rs_sel_a2` | 4 one-hot each | every cycle | which entry the write reads |
| `rs_cr_q` | 1 | every cycle | `pca_rcu_mig_credit` (the wire) |

- **Landing.** A row lands at its payload cycle T into `rs_tl`, enabled by the flopped valid. The FIFO depth equals the channel's credit depth, `CCV_CREDIT_DEPTH` = 4. AR keeps it at 4 (RA-28 (c), Q-43): depth 2 measured half rate, and a restore runs near one row a cycle because R is idle most cycles.
- **Launch condition.** A restore launches only for the warp at the FIFO head: `rs_f_v[hd] & ~rs_f_dead[hd] & (rs_f[hd].warp == rpick.warp)`. PCA sends each restore's 17 rows contiguously, mig\_row 0 to 16 ascending, and finishes one warp before it starts the next (RA-28 (b), AR; a PCA spec rule with its own assertion). Without the assumption, a head row of warp Y could wait on a pairing behind warp X's rows, with no credit left for X.
- **Decision in A (stage I):**
  - `e = rs_hd` advanced by `rs_v_a1`, so a write already in A+1 is skipped. `row = rs_f[e].row`.
  - The row is a GPR row (rows 0-15): `rs_want = rs_busy & rs_f_v[e] & ~rs_f_dead[e] & (rs_f[e].warp == rs_warp) & ~rs_last_a1 & rw_free`, where `rs_last_a1` marks a row-16 write in flight, so no row of the next warp is decided before `rs_busy` clears, and `rw_free = ~(issue_s8_valid_q & (r_wgpr | collective))`.
  - The row is row 16: `rs_want` drops `rw_free`, because PG0-PG3 are dedicated. That decision sets `rs_last_a1`.
  - `rs_v_a1 <= rs_want`. `rs_sel_a1 <= e`.
  - The RW predecode flops load `predecode(rs_gpr[row])` (a 16:1 one-hot AND-OR, about 4 NGD, then 3 NGD), muxed against the R op's RW destination.
- **A+1.** `rs_v_a2 <= rs_v_a1`, `rs_sel_a2 <= rs_sel_a1`, and the head pointer advances (enable `rs_v_a1`). The RW predecode moves with the R pipe's A+1 → A+2 copy.
- **A+2 (the write).**
  - GPR row: RW writes `rs_f[rs_sel_a2].row_data` (a 4:1 one-hot AND-OR, 2 NGD) with all 32 lanes enabled, through RW's data mux (R result vs restore, 2 NGD).
  - Row 16: PG\_p writes `sel = rs_pred[p]`, `m = 32'hFFFF_FFFF`, `d = row_data[32p+31:32p]` for p = 0..3.
  - At the end of A+2, the entry's `rs_f_v` clears and `rs_cr_q` is set.
  - For row 16, `rs_busy` clears as well (the predicate row closes the transfer; PCA sends it last).
- **A+3.** The credit is on the wire, and the row is readable. TI-13 holds: the credit returns only after the write.
- **The skeleton writes the predicate row's predicates only** (`pred[pred[p]]` = its slice). The same applies here: bits \[1023:128\] are ignored.

**Restore timeline** (row lands at T, R slot idle):

| Cycle | T−1 | T | T+1 | T+2 | T+3 | T+4 |
| --- | --- | --- | --- | --- | --- | --- |
| Event | `pca_rcu_mig_valid` | payload lands in FIFO | decide (A) | A+1 | RW writes (A+2) | readable; credit on wire |

## Kill

kill\_valid (cycle K−1, flopped) and kill\_warp\_mask (cycle K, flopped in ccv\_rcu's kill detector, then OR-accumulated into mig\_kmask\[31:0\]) act from K+1:

- **Pairing entries.** Map and command entries of a killed warp are dropped and their credits returned. Each channel returns one credit a cycle, so the credits a cycle frees (a launch's one, a kill's several) add into a per-channel pending count, `mig_mcr_n` and `mig_ccr_n` (4 bits each, enabled while nonzero or freeing; a kill's drops are first counted in a 3-bit count per channel and join a cycle later), and one credit goes out each cycle while it is nonzero (RI-6 (a)). A launch's credit is therefore on the wire the next cycle at the earliest. A row that lands for a warp whose `mig_kmask` bit is set is marked dead. A `ooe_rcu_map` landing for warp w clears `mig_kmask[w]`; a new map comes only after RAU relaunches, which is after every ack. The clear may lag the map's landing by up to 2 cycles (RI-19: from flops, keeping the 32:1 select off the credit paths). That is safe because only landing PCA rows test kmask, and a relaunched warp's first PCA row follows a whole demotion paired on that first map (at least 17 cycles; RA rev 96). Map and command entries are dropped by the kill event itself, never by kmask's level: a relaunched warp's command can land before its map or during the lag, and must pair.
- **Demotion of a killed warp.** It stops at a row boundary: `dm_busy` clears at the first edge from K+1. A row whose valid is already out still sends its payload, since valid is binding.
- **Restore of a killed warp.** `rs_busy` clears. Its FIFO rows are marked dead. A dead head entry is popped without a write, and its credit is returned at the next edge, so PCA's in-flight rows drain. The FIFO pops at most one entry a cycle: when a restore write's pop and a dead head's pop fall in the same cycle, the write pops first and the dead head the next cycle (RI-6 (c)).
- **Quiesce contribution.** The kill tab's ack takes the AND of:
  - no `dm_busy` for a killed warp;
  - no live FIFO entry of a killed warp;
  - no unpaired entry of a killed warp.

  All three are true within 1 cycle, plus the FIFO's dead-row drain.

## Flops and checks

7,383 flops as built (RA rev 140 (phase 5)), every one of them behind its land, launch or send enable; the free and valid registers behind qv\_en. The large arrays are rs\_f (4,184 flops), the PCA capture pwq/prowq/pdatq (1,034), dm\_pay (1,034) and mig\_mq (632).

Assertions in `rcu_mig`:

- `chk_dm_stable`.
- Rows sent in order 0..16 per demotion.
- Every restore row's warp equals `rs_warp` when written.
- Row 16 is the last row of each restore.
- No FIFO overrun.
- `dm_cred` stays in \[0, 4\].
- No two registers of a restore map share a row.
- No row-255 entry in a restore map.
