<!-- design-snapshot url=https://claude.ai/artifact/4k7VrEKJG4KUgMYG1Qz8mB tab=Done,_kill_and_reset rev=45 exported=2026-11-13 status=living -->
> **Snapshot: do not edit.** Exported from *CCV RCU Architecture*, tab *Done, kill and reset*, at revision 45 on 2026-11-13 ([live doc](https://claude.ai/artifact/4k7VrEKJG4KUgMYG1Qz8mB)). The live doc is the source; it is a living document, so this copy is refreshed whenever it changes. This copy pins what the repo was built against; see [README.md](README.md).

# Done, kill and reset

This tab covers everything RCU tells OOE and RAU about completion and teardown: the done channel, the kill handshake, what reset clears, the CSR tie-off and the block clock gate. Done payloads live with their sources: slots 0-4 in `rcu_lanes`, slots 5-6 in `rcu_r`, and the slot-5 leads in `rcu_pred`. Kill, the done wake and the idle term live in `rcu_kill`, and the gate in the block top (Partition tab).

## Done slots: fixed per class

`rcu_ooe_done` is a free pool of 7 slots. RCU assigns every class a fixed slot, so no two classes can collide and no allocation logic is needed. AR, TI and OA agreed under RA-29 (b) that a fixed assignment satisfies the pool's contract and the `rcu-done-pool` control.

**Why it is collision-free.**

- Two lane ops that land in one cycle were issued in one cycle, because `CCV_LAT_LANE` is fixed. Ops issued in one cycle own disjoint sections, so their lead sections differ.
- Only one SFU op can issue per cycle (`CCV_SECTIONS // FOOT_MIN_SFU` = 1).
- The R slot issues one op per cycle, either RCU-only or collective.

| Class | Slot | Valid flop loaded at the edge ending | Valid on wire | Payload on wire | Payload source |
| --- | --- | --- | --- | --- | --- |
| RCU-only (bra, call, ret, pand/por/pxor, pmov, movi) | 5 (`CCV_DONE_SLOT_RCU`) | A | A+1 | A+2 | R pipe (`rres_a1` stage) |
| Warp collective (shfl, vote, ballot, unballot) | 6 | A | A+1 | A+2 | R pipe |
| Lane op, lead section k | k (0-3) | A+5 | A+6 | A+7 | `lwb_d[k]` descriptor, age 5 (CCV\_LAT\_LANE − 2) |
| SFU op | 4 | A+10 | A+11 | A+12 | `swb_d` descriptor, age 10 (CCV\_LAT\_SFU − 2) |
| PRF copy (GPR or predicate), any memop | none |  |  |  | OI-4; masked-load copy: done\_row 1 completes on MIU's cmpl |

A collective's done goes out at A+1, 3 cycles before `CCV_LAT_COLLECTIVE` = 5. The contract text allows an early finish (V-35: "RCU may finish sooner"). Its result is readable from A+3, so dependants woken at 5 read a landed value. RA-29 asks AR to confirm that an early done on a `fixed_latency` slot is legal; otherwise slot 6's valid is delayed 3 cycles through 3 more flop stages (rob\_tag and done\_row only, 9 b).

### Per-slot registers

| Register | Slots | Width | Enable | Notes |
| --- | --- | --- | --- | --- |
| `done_v_q[s]` | 0-6 | 1 | every cycle | `rcu_ooe_done_s<s>_valid` |
| `done_tag_q[s]` | 0-6 | 7 + 2 | `done_v_q[s]` | `{rob_tag, done_row}` echoed from the issue |
| `done_bt_q`, `done_bm_q`, `done_aux_q` | 5 only | 1 + 32 + 32 | `done_v_q[5]` | `branch_taken`, `branch_mask`, `aux` |
| `lead_bt_q`, `lead_bm_q` | 5 only | 1 + 32 | every cycle | `lead_br_taken`, `lead_br_mask`; NGD-7 `(* keep *)` copies, separate from the payload's |

On every slot except 5, `branch_taken`, `branch_mask`, `aux` and the two leads are constant 0, with no flops behind them. That holds the `slot-field-aux` control failing as it should.

### Slot 5 field rules

| Op | `lead_br_taken` / `lead_br_mask` (A+1) | `branch_taken` (A+2) | `branch_mask` (A+2) | `aux` (A+2) |
| --- | --- | --- | --- | --- |
| bra, call | outcome from stage I (split guard read, about 16 NGD), loaded at A's edge | = lead | = lead: issue mask AND guard | 0 |
| ret | 0 (don't-care; the stub leaves it 0) | OR(`active`) | active lanes whose rs equals `aux` | rs of the lowest active lane (R unit tab) |
| every other RCU-only op | 0 | 0 | 0 | 0 |

The payload's bra/call fields are a second copy of the outcome: `br_*_a` is loaded at A's edge alongside the lead copies, then moved to `done_b*_q` at A+1's edge. For a ret, `done_b*_q`/`done_aux_q` load from the R unit's A+1 outputs.

Barriers: RA-25. Settled: barriers are not in the first build (TI-42; OOE completes barrier arrive/wait without issue), so RCU never sees one. If a later build routes them through RCU, a barrier is an RCU-only op with `branch_mask` = issue mask AND guard and, for wait.phase, `aux` = ps's lanes, read at A on a guard-class port.

## Wakes RCU sends

Each outbound wake is a flop, written every cycle. The receiver's gate holds through wake + `CCV_WAKE_LAT`, so a valid at V needs a wake in \[V−4, V−1\].

| Wake | `D` of the flop | Why it covers the valid |
| --- | --- | --- |
| `rcu_lane_ops_c<NN>_wake` (each copy), `rcu_miu_addr_wake` | `ooe_rcu_issue_wake` | Lane and address valids are at A. OOE's own rule puts the issue wake in \[A−5, A−2\] for issue valid A−1, so RCU's flop is in \[A−4, A−1\]. |
| `rcu_ooe_done_wake` | any `ooe_rcu_issue_s*_valid` (wire) OR any `lwb_d`/`swb_d` stage valid OR R pipe valid OR `ooe_rcu_issue_wake` a cycle on, through ccv\_rcu's ungated wake detector (RA rev 136); its done-wake flop stays, and since RI-43 (c64b7417, RA rev 138) the detector holds no busy term | R done valid at A+1, from issue valid at A−1 → wake at A. R's done payload lands at A+2, so its wake is due at A−2, before any of the op's valids reach RCU; only OOE's issue wake, taken a cycle on, covers it (RI-37 (2), RA rev 136). That term is a superset: a wake with no done costs OOE's done receiver DCGE, never correctness. Lane done at A+6, from descriptor ages 1-5 → wake A+2..A+6. SFU likewise. |
| `rcu_pca_mig_wake` | `dm_busy_next` | Migration tab: 4-cycle lead counter. |

## Credits RCU returns

| Inbound channel | Credit flop `D` | Notes |
| --- | --- | --- |
| `ooe_rcu_issue_s*` | that slot's flopped valid (landed this cycle) | RCU never holds an issue. The model and the RTL both return this credit, and lane\_rcu\_res\_c\*'s, in the landing cycle (creditAtLanding; lock-step --credit-lead 0 and its 'lead' control; RA rev 138, RI-43, closing RA rev 135) |
| `lane_rcu_res_c*` | that copy's flopped valid |  |
| `miu_rcu_data_s*` | none: no RCU credit port | The wrapper returns the credit on receipt, from its own `b_` valid flop (`ccv_common_rpt` `CREDIT_ON_RECEIPT`; RA-41, AR 330, TI 383, RA rev 116) |
| `ooe_rcu_map`, `rau_rcu_mig` | entry launched or kill-dropped | Migration tab |
| `pca_rcu_mig` | row written or dead row popped | Migration tab (TI-13) |

On the outbound side RCU keeps a credit counter only for `rcu_pca_mig`, the one outbound channel that is not fixed-latency (Migration tab).

The other three outbound channels are fixed-latency: `rcu_ooe_done`, `rcu_lane_ops` and `rcu_miu_addr`. On each, the receiver returns every credit in the cycle its message lands. Those credits are checked by `ccv_common_chk_credit` only, with no counter logic.

AR settled RA-21: `rcu_miu_addr` is slot-bound (slot k = MIU pipe Pk) and fixed-latency, so it needs neither a counter nor a stall path.

## Kill

`kill_valid` comes a cycle ahead of `kill_warp_mask` and `kill_epoch`. All three are outside credits.

RCU's pipe carries no warp id: an issue carries only `rob_tag`. RCU therefore cannot tell which in-flight ops belong to killed warps, so it drains everything. It holds no per-warp state outside migration.

| Register | Width | Enable | Meaning |
| --- | --- | --- | --- |
| `kill_v_q` | 1 | every cycle | flopped `kill_valid` (cycle K−1 on the wire, so set in K) |
| `kill_ep_q` | 2 | `kill_v_q` | `kill_epoch`, taken in K |
| `kill_drain` | 5 | `kill_v_q` or `kill_drain != 0` | loaded with `KILL_DRAIN` − 1 at K's edge, K being the drain's first cycle (K counts; RA rev 136), counts to 0 |
| `kill_ack_q` | 1 | `kill_v_q` or ack-ready | `kill_ack`, a level (RA-23) |
| `kill_ack_ep_q` | 2 | ack-ready | `kill_ack_epoch` |

`KILL_DRAIN` = 2 + `link_n(ooe_rcu_issue)` + `bnd_rx(ooe_rcu_issue)` + `CCV_LAT_SFU` + 1 + `link_n(rcu_ooe_done)`, which is 15 at the defaults: abutted links, the issue end zero-cycle (bnd\_rx 0 since RA-43, AR 329; 16 with it flopped) and CCV\_LAT\_SFU 12 since lane\_rcu\_res's end at RCU went zero-cycle (RA rev 95). The issue end's bnd\_rx counts on the crossing, never in the base (AR revs 288, 300 and 301); 17 before RA rev 95. It covers:

- the last issue that OOE may send before it reacts to the same kill (valid at RCU's interface flop by K+1 + bnd\_rx(ooe\_rcu\_issue), so payload A = K+2 with the issue end zero-cycle, RA-43);
- that issue's longest RCU life: an SFU done payload at A+12, which is on the wire to OOE until it lands.

An address message (A+1) and a lane message (A+1) leave sooner. A load's data from MIU is MIU's own drain, and RCU writes whatever lands.

**Ack-ready** = `kill_drain == 0` and migration's quiesce term (Migration tab: no demotion, live restore row or unpaired entry of a killed warp).

- At its edge: `kill_ack_q` ← 1 and `kill_ack_ep_q` ← `kill_ep_q`.
- `kill_ack_q` clears at the edge that ends K of the next kill, so the ack is low through that kill's drain.
- A kill that arrives during a drain reloads `kill_drain`, ORs its mask into `mig_kmask`, takes the new epoch and is answered once, with the new epoch. RAU counts an ack only when its epoch matches (`CCV_P_W_KILL_EPOCH` = 2), so the earlier epoch's ack never appears, and needs not.

Kill inputs and sleep (AR 336 (b), AR 338/339; RI-27, RI-29, RI-33, RI-34; RA revs 127, 130, 131 and 134): the detector is in ccv\_rcu, its own CG unit of 35 flops. kill\_detect\_v\_cr01h flops kill\_valid on the ungated core\_clk every cycle, at 0 NGD and with no reset (it counts in the module's allowance); kill\_valid is a wake port. kill\_detect\_ep\_cr02h and kill\_detect\_km\_cr02h (34 flops) also sit on core\_clk, loaded under that valid flop (the module's own flop, CG-5; one gate, DCGE 100%) in the cycle after kill\_valid, which is when the epoch and mask arrive, since valid leads the payload. None of it depends on RCU's gated clock, so a kill that lands asleep is captured. rcu\_kill and rcu\_mig load epoch and mask from those flops at K+1. The ack is high from K + KILL\_DRAIN + 1 = 16 (RA rev 136, RI-37 (1); 17, at K + KILL\_DRAIN + 2, before), the same awake and asleep, and a second kill across the wake is acked with the later epoch. M4 runs both cases, each with a control that drops the held kill and must fail. M4's kill checker passes at this timing and its KILL\_DRAIN − 1 control fails; both stay on the RTL and the model, with killsleep's asleep-equals-awake and later-epoch cases. An earlier ack changes nothing for RAU, which counts the ack by epoch (AR 338/339). If the control ever stops failing, the bound is loose: record the margin, and never shorten it further without a row. Reset (RST-2, Daniel 2026-11-09): block rcu's reset arrives at cycle 1 at every endpoint (RI-34).

What to measure: the implementation agent runs the kill checker with `KILL_DRAIN` − 1 as a negative control. It must fail on some kernel whose kill lands with an SFU op in flight. If no kernel can make it fail, the bound is loose, and the margin is recorded.

## Reset (RST-1, A-29)

`rst_n` is flopped once (`rcu_rst_q`) before any use. The block clock gate opens on reset by itself (`docs/clock-gate.md`). Only control state resets.

| Reset (value) | Not reset (never read before written) |
| --- | --- |
| every valid flop: issue/lane/MIU/map/command/PCA receive valids, I/R/RW stage valids, `lwb_d`/`swb_d` stage valids, bypass history valids, `done_v_q`, lane-ops and address valids, `dm_v_q`, `rs_v_a*` (0) | PRF rows: 192 × 1,024 (A-29: launch maps every register to the zero registers) |
| every wake and credit-return flop (0) | predicate file: 48 × 32 |
| `mig_mq_v`, `mig_cq_v`, `rs_f_v`, `rs_f_dead` (0); `rs_hd`, `rs_tl`, the free pointers (entry 0) | every payload register: stage payloads, descriptors' payloads, done payloads, lane and address payloads, `dm_pay`, `rs_f` data, map/command entry data |
| `dm_busy`, `rs_busy`, `dm_wcnt` (0); `dm_cred` (`CCV_CREDIT_DEPTH`) | engine map copies (`dm_gpr`, `rs_gpr`, ...) |
| `kill_drain`, `kill_ack_q`, `kill_ack_ep_q`, `mig_kmask` (0) | the MIU lead predecode flops: they are written every cycle and are gated by the valid that is reset |
| `lead_bt_q`, `lead_bm_q` (0): leads are checked even without a valid |  |

About 1,500 flops reset, out of 247,468 (measured, RI-34). Every payload is ignored without its valid, and the `dirty-zero` control is unaffected: the zero registers are constants, not rows.

**kill\_ack after reset** is 0 with epoch 0. RAU starts no kill before reset ends, so a level of 0 is an unanswered nothing. AR confirms with RA-23.

## CSRs (RA-26)

AR confirmed RA-26: RCU has no CSRs in the first build. It still answers the CSR channel, from flops, with a 1-entry responder:

- `csr_rsp_q` (33 b, every cycle): `{done = 1, data = 32'b0}` in the cycle after a request lands, and 0 otherwise. A write is answered the same way and changes nothing.
- `csr_cr_q` (1 b, every cycle): `csr_credit`, high in the same cycle as the response.
- A request's arrival also wakes the block gate.

What marks a request on `csr_req` (49 b: address 16, data 32, write enable 1) is the CSR fabric's to define (Q-59). The implementation agent takes it from the generated port list when the fabric lands; until then the responder's arrival term is that definition.

The gate's hysteresis inputs stay tied to `CCV_CG_HYST_QUIESCE` and `CCV_CG_HYST_STALL`, and `cg_override` to 0, as `docs/clock-gate.md` says a block does until it decodes its own CSRs.

## Block clock gate

The block top instantiates `ccv_common_clk` once, on `core_clk`, and everything else runs on its `gclk` (CCV-L22).

| Input | Driven by |
| --- | --- |
| `rst_n` | `rst_n` (the gate flops it itself) |
| `wake` | `ooe_rcu_issue_wake`, every `lane_rcu_res_c*_wake`, `miu_rcu_data_wake`, `ooe_rcu_map_wake`, `rau_rcu_mig_wake`, `pca_rcu_mig_wake`, `kill_valid` |
| `quiesced` | `rcu_idle_q`: no valid in any stage, descriptor or bypass entry; `dm_busy` = `rs_busy` = 0; no dead FIFO row; `dm_cred` full; `kill_drain` = 0; no done, lane, address or PCA valid or wake flop high |
| `stalled` | 0: RCU has no state that waits on a level |
| `hyst_*`, `cg_override`, `te` | `hyst_*` and `cg_override` are tied (CSRs section). `te` is the scan test enable from the scan fabric when it lands after Stage 4, and 0 until then. It is the only test enable RCU codes: synthesis stitches it into every inferred clock gate, and scans the whole PRF transparently (Daniel, 2026-11-02). |

What may stay pending while the gate is closed:

- Unpaired map or command entries: the missing half arrives with its own wake.
- Live FIFO rows waiting for a pairing: same.
- `kill_ack_q` held high: it is a flop, and holds.

RCU is asleep whenever no warp issues to it and no migration is in progress. The gate stays open through a payload by ccv\_common\_clk's own hold (AR 343, WAKE\_HOLD = CCV\_WAKE\_LAT + 1), proved by wake\_keeps\_rx and its hold − 1 control, so ccv\_rcu's wake detector holds no busy term (RI-43, RA rev 138). rcu\_kill's NB is 5 (6 before).
