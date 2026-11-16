# RCU block report: ccv_rcu (RI, first pass)

Measured at commit 5516e643 on 2026-11-14. These are figures from existing runs: nothing was synthesised again for this report. Each figure names its source, and every figure that isn't available is listed in section 5. `docs/rcu-exit.md` holds the exit table; this report gives the block's figures behind it.

## Sources

| Tag | Source | What it is |
|---|---|---|
| G | `verify-5516e643-20261114-0138.log` (`$CCV_LOGDIR`) | The scoped gate at 5516e643: SCOPED PASS, 21 of 24 sections, with check-cg and check-ngd included |
| S-cg | RI's run of `tools/check-cg.py --unit rcu_bank_slice` | Per-gate DCGE, for the K=1 slice only |
| S-ngd | RI's endpoint script, using check-ngd's own synthesis and timing functions | Yosys cells, ABC gates and endpoint-depth histograms |
| U | `test/rcu/cg-units.json`, `rtl/top/rpt-units.json` | Units and their parameters |
| R | `rtl/rcu/ccv_rcu.sv` | Instance counts |
| W | `rtl/cg-waivers.json` | RCU waiver entries |

S-cg and S-ngd ran on the working tree minutes before 5516e643 was committed. There is no RTL or bench difference between that tree and 5516e643 (`git diff 6906c327 5516e643 -- rtl/rcu test/rcu` is empty). Every depth that S-ngd shares with G matches to 0.1 NGD. That covers flop to flop, input to flop, flop to output and flop to flop without the fanout term, for all 13 units. The slice's figures in S-cg are identical to G's: 6,556 flops, 6,519 of them in 199 gates, lowest DCGE 98/90/98.

## Instances

G's budget line reads "247473 flops in 15 unit(s)". The units below, at R's instance counts, sum to exactly 247,473. G's depth line reads "49 of 49 instance(s)".

| Unit | Module | Parameters | Instances |
|---|---|---|---|
| ccv_rcu | ccv_rcu | – | 1 (the top's own flops) |
| rcu_clk | ccv_common_clk | NWAKE 38 | 1 |
| rcu_isd_s | rcu_isd | LS 1 | 4 (slots S0 to S3) |
| rcu_isd | rcu_isd | LS 0 | 5 (P0 to P3, and R) |
| rcu_bank_slice_k0, rcu_bank_slice, rcu_bank_slice_k2, rcu_bank_slice_k3 | rcu_bank_slice | ROWS 192; K 0, 1, 2, 3 | 8 each, 32 in all (NK 4 × NJ 8) |
| rcu_pred, rcu_r, rcu_lanes (COPIES 32), rcu_mem (COPIES 32), rcu_mig, rcu_kill | – | – | 1 each |
| rcu_xbar | – | – | inside rcu_r; no flops |
| repeater, RPT_MIU_RCU_DATA | ccv_common_rpt | W 1114, SLOTS 4, STAGES 0 | 1 |

## 1. Cells, flops and the clock-gating rules

Flops, flops in gates, gates and the worst enable come from G's check-cg lines. Ungated means flops minus flops in gates. The allowance and the auto-waived flops come from G's module budget lines. Cells come from S-ngd: Yosys cells in the top module, and ABC gates excluding WIRE, ZERO, ONE and BUF.

| Unit | Inst | Yosys cells | ABC gates | Flops | In gates | Ungated | Gates (groups < 8) | Worst enable (NGD) | Allowance | Auto-waived (findings) |
|---|---|---|---|---|---|---|---|---|---|---|
| ccv_rcu | 1 | n/a | n/a | 36 | 34 | 2 | 1 (0) | 0.0 | 7.0 | 2 (2) |
| rcu_clk | 1 | 221 | 213 | 21 | 14 | 7 | 1 (0) | 4.7 | 7.0 | 7 (5) |
| rcu_isd_s | 4 | 722 | 387 | 68 | 68 | 0 | 1 (0) | 0.0 | not printed | no line |
| rcu_isd | 5 | 684 | 395 | 28 | 28 | 0 | 1 (0) | 0.0 | not printed | no line |
| slice k0 | 8 | 204,644 | 79,429 | 6,553 | 6,519 | 34 | 199 (0) | 8.0 | 131.1 | 37 (20) |
| slice K=1 | 8 | 205,028 | 79,543 | 6,556 | 6,519 | 37 | 199 (0) | 8.0 | 131.1 | 40 (20) |
| slice k2 | 8 | 205,349 | 79,856 | 6,559 | 6,519 | 40 | 199 (0) | 8.0 | 131.2 | 43 (20) |
| slice k3 | 8 | 205,542 | 79,962 | 6,562 | 6,519 | 43 | 199 (0) | 8.0 | 131.2 | 46 (20) |
| rcu_pred | 1 | 210,863 | 113,263 | 3,127 | 3,081 | 46 | 88 (0) | 5.5 | 62.5 | 46 (8) |
| rcu_r (with xbar) | 1 | 97,778 | 78,322 | 2,684 | 2,679 | 5 | 7 (0) | 4.2 | 53.7 | 5 (4) |
| rcu_xbar alone | – | 64,512 | 23,552 | 0 | – | – | – | – | – | – |
| rcu_lanes | 1 | 21,516 | 14,691 | 6,888 | 6,811 | 77 | 106 (5) | 7.2 | 137.8 | 133 (19) |
| rcu_mem | 1 | 62,533 | 32,223 | 12,558 | 12,540 | 18 | 20 (4) | 2.9 | 251.2 | 18 (7) |
| rcu_mig | 1 | 20,250 | 10,078 | 7,383 | 7,268 | 115 | 16 (14) | 5.5 | 147.7 | 115 (56) |
| rcu_kill | 1 | 127 | 151 | 54 | 0 | 54 | 0 (3) | 0.0 | 7.0 | 7 (7) |
| repeater | 1 | n/a | n/a | 4,470 | 4,252 | 218 | 4 (0) | 0.0 | 89.4 | 0 (1); its 218 control flops go to the block |

Block totals:

| Figure | Value | Source |
|---|---|---|
| Flops | **247,473** | G |
| Flops in gates | 245,699 (99.28%) | summed from G |
| Ungated flops | 1,774 | summed from G |
| Yosys cells, excluding ccv_rcu's own logic and the repeater | 6,984,100 | summed from S-ngd |
| ABC gates, on the same basis | 2,802,784 | summed from S-ngd |

ABC counts slightly fewer flops than check-cg. For example, rcu_lanes is 6,760 against 6,888. The flop figures here are check-cg's.

rcu_kill has no clock gate by design; its waivers are in W.

The K=1 slice's 37 ungated flops are all control (S-cg): mw_row 8, mw_lm 4, wr_act 3, wr_v 3, and the flopped reset among them.

## 2. DCGE

G prints only the lowest DCGE for each unit and scenario. A dash means no gate was enabled.

| Unit | Idle | Medium | High |
|---|---|---|---|
| ccv_rcu | - | 100 | 100 |
| rcu_clk | 100 | 100 | 100 |
| rcu_isd_s | - | 100 | 100 |
| rcu_isd | - | 99 | 99 |
| slice k0 | 100 | 89 | 96 |
| slice K=1 | 98 | 90 | 98 |
| slice k2 | 98 | 90 | 96 |
| slice k3 | 93 | 92 | 97 |
| rcu_pred | - | 89 | 92 |
| rcu_r | - | 99 | 99 |
| rcu_lanes | - | 55 | 69 |
| rcu_mem | - | 95 | 94 |
| rcu_mig | - | 99 | 99 |
| rcu_kill | - | - | - |
| repeater | - | 100 | 100 |

rcu_lanes' figures are those of its waived CG-3 gate, pcm_n_cr04h:
- G measures its four slot gates at medium 54.9% and 71.1%, and high 68.8%, 71.4% and 71.8%.
- That is above the 51% and 67% the waiver records (TI's re-measure on 7ee18501), and above its floors of 49% and 65%.
- The figures depend on the bench's random draw of active masks (the waiver's why). So the floors stay as RI-47 put them to Daniel, and aren't tightened from one run.

For the block, each unit's lowest DCGE is weighted by its gated flops × instances. That makes it a lower bound:

| Scenario | Weighted lowest DCGE | Gated flops covered |
|---|---|---|
| Idle | ≥ 97.3% | 208,622 (only rcu_clk and the slices enable a gate in idle) |
| Medium | ≥ 90.0% | 245,699 |
| High | ≥ 95.9% | 245,699 |

A true flop-weighted DCGE exists only for the K=1 slice (S-cg):
- 98.9% idle, over the 196 flops whose gates were enabled;
- 99.7% medium;
- 99.7% high.

## 3. The 2% budget

G reads: "4949.5 allowed, 2704 auto-waived in its modules (218 of them repeater control; 825 of them waived as lead or credit flops)".

| Part | Flops |
|---|---|
| The modules' auto-waived flops × instances (G): ccv_rcu 2, rcu_clk 7, the slices 8 × (37 + 40 + 43 + 46) = 1,328, rcu_pred 46, rcu_r 5, rcu_kill 7, rcu_mig 115, rcu_lanes 133, rcu_mem 18 | 1,661 |
| Repeater control | 218 |
| Lead or credit waivers (G gives the total only) | 825 |
| **Total** | **2,704, which is 54.6% of 4,949.5** |

Every unit stays within its own allowance.

The 825 lead and credit flops are charged to the block:
- rcu_pred CG-5 ×2: MIU's kept lead (46 flops) and each slot's guard lead.
- rcu_r CG-5: imm and rrow, 48 flops.
- rcu_isd CG-5: the class word and its lead copies.
- rcu_kill CG-1: the credit-return pulses, 41 flops.

The owner waivers RI-47 put to Daniel are not lead or credit:
- rcu_lanes CG-3, pcm_n_cr04h;
- rcu_kill CG-4, kd_cr02h, 4 flops;
- rcu_kill CG-4, kaep_q_cr03h, 2 flops.

## 4. Logic depth (G)

Each cell gives the depth with the fanout term, then without it in brackets. "n/p" means G doesn't print it.

| Unit | Inst | Flop to flop | Input to flop | Flop to output | Input to output | Widest net |
|---|---|---|---|---|---|---|
| ccv_rcu | 1 | 0.0 (n/p) | 0.0 | 0.0 | 0.0 | – |
| rcu_clk | 1 | 10.4 (9.7) | 9.7 (9.7) | 4.9 (4.2) | 3.0 | 10 |
| rcu_isd_s | 4 | 0.0 | 12.8 (9.7) | 0.0 | 0.0 | 32 |
| rcu_isd | 5 | 0.0 | 12.7 (9.5) | 0.0 | 0.0 | 38 |
| slice, all four K | 32 | 19.0 (12.3) | 15.9 (12.5) | 11.0 (8.3) | 0.0 | 385 |
| rcu_pred | 1 | 21.7 (15.6) | 14.9 (13.5) | 8.3 (6.2) | 0.0 | 196 |
| rcu_r | 1 | **23.9 (17.1)** | 19.8 (17.1) | 9.9 (7.2) | 0.0 | 1,793 |
| rcu_xbar (an inner helper) | – | – | – | – | 6.8 | – |
| rcu_lanes | 1 | 14.1 (11.4) | 13.2 (11.4) | 8.6 (7.5) | 0.0 | 264 |
| rcu_mem | 1 | 11.0 (5.6) | 5.9 (5.2) | 2.8 (2.8) | 0.0 | 769 |
| rcu_mig | 1 | 21.4 (16.7) | 17.8 (15.7) | 10.9 (7.3) | 0.0 | 1,155 |
| rcu_kill | 1 | 6.8 (n/p) | 6.5 | 0.0 | 0.0 | – |
| repeater | 1 | 2.4 (1.7) | 1.7 | 0.0 | 0.0 | 13 |

For the block, G reports 2 levels, each timed alone for convergence; 49 of 49 instances; and the boundary held by its parts. There is no RCU entry in the fanout ratchet.

The endpoint histogram below is from S-ngd, with the fanout term:
- Each endpoint takes the larger of its flop-to-D and input-to-D arrival within its own unit, with the unit's inputs at 0.
- Endpoints are weighted by instance count.
- It covers 13 units and 242,671 flops. ccv_rcu's own flops and the repeater are not in it.

| Depth (NGD) | ≤ 10 | 10 to 15 | 15 to 20 | 20 to 23 | 23 to 25 | > 25 |
|---|---|---|---|---|---|---|
| Endpoints | 26,536 | 14,088 | 200,922 | 524 | 601 | 0 |
| Share | 10.9% | 5.8% | 82.8% | 0.2% | 0.2% | 0 |

The 15-to-20 bin is almost all slice row writes: 6,208 × 32 = 198,656. The endpoints over 20 are in rcu_r (455 at 20 to 23, 601 at 23 to 25), rcu_pred (24 at 20 to 23) and rcu_mig (45 at 20 to 23).

## Cross-check against docs/rcu-exit.md

The exit table was measured at 7e10e72f. It agrees with G on:
- 247,473 flops, 4,949.5 allowed and 2,704 taken, with 825 lead or credit flops and 218 repeater control flops;
- the worst flop-to-flop depths: 23.9, 21.7, 21.4, 19.0, 14.1 and 11.0;
- 2 levels and 49 of 49 instances;
- the slice flops and the AND-OR at 11.0 (8.3 without the fanout term).

rcu_lanes' CG-3 gate now measures above the figures the waiver records (section 2).

## 5. Not available

| Figure | Where it would come from |
|---|---|
| Cells as the gate counts them (G prints none) | The synthesis cache's ABC netlists, or S-ngd run again at the commit |
| Cells for ccv_rcu's own logic and the repeater | S-ngd extended to those units |
| Per-gate DCGE, and so a true weighted DCGE, for every unit but the K=1 slice | `check-cg --unit`, or the gate's cg section log (cleared once it passes) |
| The 825 lead and credit flops by module | The block budget items in the cg section log |
| rcu_isd's and rcu_isd_s's budget lines (G prints none) | The cg section log, or `check-cg --unit` |
| The number of RCU waivers in use (G gives 84 for all of check-cg) | The per-unit cg output |
| Depths without the fanout term for ccv_rcu and rcu_kill | check-ngd's per-unit output |
| Histograms for ccv_rcu and the repeater, and any histogram without the fanout term | S-ngd extended |
| Depths across unit boundaries | No flow: the block is a sum of parts, with no whole-block synthesis (Daniel, 2026-11-06) |
| Time and memory for the light units | `unit-times/`, which only a clean gate writes |
