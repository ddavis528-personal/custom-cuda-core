# RCU exit table, M0 to M7 (RI)

RI's measurements against the exit table in the RCU spec's Partition tab
(`docs/design-snapshots/rcu-arch-partition.md`, rows M0 to M7; the live doc
wins), and `docs/rcu-impl.md` section 5, phase 5: "every row of the exit table
met, or a waiver Daniel signs. Then RA reconciles the spec with what was
built."

Measured at 7e10e72f (2026-11-13). The gate is
`verify-7e10e72f-20261113-2049.log`, SCOPED PASS 15/24, with check-cg and
check-ngd included. The figures the gate doesn't print were measured at the
same commit by the commands below. Confirmed since by the full clean gate on
ce5f44dd (`verify-ce5f44dd-20261115-1037.log`, PASS, 2026-11-15), which
carries the SFU class (RA rev 146), the split tree with the RTL (TI 7079fc14)
and the address timed from `CCV_LAT_RCU_ADDR` (RA rev 148).

## Summary

| Row | Verdict |
|---|---|
| M0, block lock-step | MET |
| M1, NGD | MET. The pred guard path in A is 13.6 without the fanout term and 17.0 with it, against RA's restated target of ≤ 16 and ≤ 25 (RA on RI-46, rev 139) |
| M2, clock gating | MET |
| M3, bank slice | MET. The AND-OR sits exactly at its limit. "Light" means the unit's own peak is within 2,048 MiB (RA, rev 139) |
| M4, kill drain | MET, by rcu_kill's control at KILL_DRAIN − 1 (RA, rev 139). Kernel margin with a lane op in flight: the whole drain, 15 (rokilllane, RI-58) |
| M5, migration | MET, from c1 (RA rev 140): demotion 68 and restore 64 cycles, against a bound of 68. Demotion has no margin |
| M6, kernels | MET |
| M7, swap boundary | MET, with the model and with the RTL, in the gate (TI's selector, 6061d0ee; gate 468fb286) |

## The rows

**M0 (tail): block lock-step.**
- `rcu_ls` passes 63 kernels, every output and event compared every cycle, the four `*_demote` runs included.
- 12 controls are caught: init, opnd, ev, gate, row, lead, arrival, pair, rzero, pzero, rdup and iso, plus the corrupt-output control.
- The restore map is checked as it lands (RA rev 140 (7); A-64): no GPR row 255 (`q53_rzero`) and no predicate 63 (`q53_pzero`) in `test/rcu/rcu_q53_chk.sv`, bound into every replay, and `mig_restore_map` in `rtl/rcu/rcu_mig.sv`. Launch copies that map unchanged. The lock-step controls rzero and pzero catch each fault.
- The model's unit tests pass, and their 7 controls are caught.
- Kernel cycles, the model against the stub (RA rev 140 (8)): all 63 kernels finish clean with each. In total, 54,729 cycles against 54,665, a geometric mean of 1.015.
  - 33 kernels are equal.
  - 21 are 1 to 4 cycles faster (narrowadd 230 against 234, borrow 99 against 102).
  - 9 are slower. 8 of them are the 8 kill kernels, by 10 to 13 cycles (addrneg 83 against 70, rokill 104 against 94). The ninth is rope, 705 against 704.
  - The causes aren't traced kernel by kernel. The kill kernels' gap isn't the drain: cutting it to 0 moves rokill by one cycle (M4).
- `rcu_rtl` runs every module bench, and every control is caught.

**M1: NGD.**
- check-ngd passes every RCU unit, and with it every port against its `.ngd.json`, with the fanout term.
- Worst flop to flop: rcu_r 23.9, rcu_pred 21.7, rcu_mig 21.4, the slice 19.0, rcu_lanes 14.1 and rcu_mem 11.0.
- The block is read as a sum of parts, 2 levels and 49 of 49 instances, and converges to 25.
- `rtl/ngd-ratchet.json` has no RCU entry.

The pred guard path in A, which must be ≤ 16 with the guard lead, comes from `test/rcu/guard-ngd.py`. It times from the guard-lead flops (rg_hi/rg_lo_cr02h, 126) with check-ngd's synthesis.

| End | `map`, the map check-ngd uses | `map -r` |
|---|---|---|
| act_cr03h, the guard result | **17.0** (13.6 without the fanout term) | 15.9 (10.5) |
| gv_cr03h | 16.9 | 15.2 |
| lbt_cr03h, the branch outcome (about +5, by design) | 20.3 | 20.3 |

The guard result is 1.0 over, and only through the fanout term. The lead flops also drive the branch-outcome and sec_pred logic, and that fanout costs 3.4 NGD.

RA's ruling on RI-46 (rev 139): the target is restated as ≤ 16 without the fanout term and ≤ 25 with it, with the guard lead in use. The old 16 was RA-32's estimate, made without the term. So there's no kept copy. That copy would have bought 1 NGD for up to 126 more waived lead flops, and doubled the load on lead_guard_pred's receiving flops. `test/rcu/guard-ngd.py` stays the check, and any growth past 16 without the term goes back to RA.

**M2: clock gating.**
- Block rcu: 247,473 flops. 2% allows 4,949.5. Its modules take 2,704, auto-waived (55%). That includes 825 waived lead or credit flops and 218 repeater control flops.
- Every module is within its own allowance.
- The ratchets hold no RCU entry.

**M3: the bank slice.**
- Flops: 6,556 (k0 6,553, k2 6,559, k3 6,562), within 0.2% of 6,550.
- Read AND-OR: 11.0 with the fanout term (8.3 without), against a limit of 11, so there is no margin.
- Peak memory: 1,435 MiB, against 2,048.
- The four slice units are on `tools/heavy-units.json` so that each runs alone. Four side by side ran a 15 GB container out of memory on 2026-11-08 (TI #91). That's a scheduling choice. "Light" means the unit's own peak is within 2,048 MiB, so the row is MET (RA, rev 139; RA rewords the row to say so).
- Any change that raises the AND-OR goes to RA before it lands.

**M4: kill drain.**
- KILL_DRAIN is 15, derived (RA-43's zero-cycle issue).
- RTL: rcu_kill's bench control `drain`, at KILL_DRAIN − 1, fails as it must. So do ccv_rcu_killsleep's drop1 and drop2.
- Kernels: 61 kernels were run in ccv-skel with `CCV_RCU_KILL_DRAIN_CUT` at 0 and 1. The 8 that kill (addrhigh, addrneg, divchw, roconst, rogated, rokill, rolaunch and rolimit) were also run at cuts 2, 5 and 15. All pass. The cut does take effect: for example, rokill goes from 103 to 102 cycles.
- No kernel had RCU work in flight when its kill landed, so the margin was recorded as the whole drain, as on 2026-11-05 (`docs/rcu-model.md`).
- rokilllane (TI 3eaaadc7 and 1861cc51, TI rev 457) kills a warp with lane ops in flight (its kill_lane bin is 1; rokill, its control, is 0). On 2026-11-16 it and rokill were run at every cut from 0 to 15. All pass, so the margin is the whole drain, 15 (RI-58, rev 87). The cut takes effect: rokilllane goes from 1214 to 1206 cycles by cut 8, then holds; rokill from 104 to 94 by cut 10, then holds. Past those cuts something other than the RCU's drain sets when the kill ends.
- The drain isn't what keeps these kernels correct: the model drops a killed warp's entries at the kill (`sim/rcu/rcu_core.cpp`, `Core::kill`), and a result that arrives later finds no entry (RI-59, rev 88). So no kernel tests the drain's length; rcu_kill's RTL control does.
- MET by rcu_kill's KILL_DRAIN − 1 control, on the RTL and the model (RA, rev 139).
- RA has also asked TI for a kill kernel with an SFU op in flight when the kill lands, so the drain is exercised end to end; it doesn't block sign-off. RI records its margin when the kernel lands. Note that the lane stub sends no SFU result yet (`sim/skel/kernel.cpp`, RA-16 (b)), so that kernel needs an SFU-capable stub. The same gap means no kernel or lock-step run exercises SW write-back (`sfu_result`) through the assembled block yet. That path is covered by the model's test and the slice bench's LW + SW same-lane case. The lanes bench drives SFU ops itself, as a lane opcode with UNIT SFU (505 ops, 430 of them writing SW), through swb_d, SW and done slot 4. Its control `swlate`, SW expected a cycle late, fails as it must (RA rev 140 (3)).

**M5: migration.**
- Counted from c1, the cycle after the launch's edge, when the launch's map or command credit is on the wire and a demotion's wake is high (RA rev 140 (2)). The bench fails a demotion whose wake doesn't rise in c1.
- From `test/rcu/cg-build.sh rcu_mig` and the bench `tb`: `mig M5 from c1: demotion 68 cycles (R idle 20), restore 64 (R idle 28), bound 68: met`.
- Demotion sits exactly at the bound: any added cycle on that path goes to RA before it lands.
- The random run gives 673 demotions, 571 restores, 108 kills, and 0 mismatches in 66,800 values.

**M6: kernels.**
- check-kernel and check-skel pass with the model as RCU by default: 63 kernels, every control caught.
- check-sv-hosted runs 63 kernels plus 4 swapping variants. All 45 kernel controls give the same KERNEL line in both hosts.

**M7: swap boundary.**
- Gate, with the model as RCU in both hosts: 67 of 67 SV-hosted runs equal their C++-hosted runs.
- RTL as RCU in the SV top (`test/rcu/ccv_rcu_svh.sv`), in the gate since TI's selector (6061d0ee, RI-44). The gate on 468fb286 (`verify-468fb286-20261114-0556.log`, SCOPED PASS 24/24) prints `RCU RTL in the SV top: == C++, == model PASS (63 kernels, rcu=rtl divergences=0)`. Run locally as well:
  - 63 of 63 kernels clean, divergences=0;
  - the RTL's final register compare clean;
  - the four `*_demote` runs clean;
  - the compare's controls (ev, gate, row) and the flip control fail as they must.
- Every derived CCV_LAT_LANE (RA rev 143): the RTL needs no change. The lanes bench and the Q-53 arrival check take the derived latencies (a61a79ca). The split tree (`test/phys/links_split.json`, CCV_LAT_LANE 11) carries `credit_on_receipt` for `miu_rcu_data@rcu`, and its SV-hosted run includes RCU's RTL (TI 7079fc14, RI-49, RI-50). The full gate on ce5f44dd prints `split: every kernel with OOE's bypass PASS (CCV_LAT_LANE 11, ...)`.
- The address cycle (RA rev 148, AR 356 (2)): the model launches an address at A + CCV_LAT_RCU_ADDR - 1 (8f00fdf8), the RTL's structural pipe at A, the same at base 1. The unit test `addr-cycle` holds the model to the param, and its control `addr-late` fails as it must (0fe15d9a). At base 2, tried and reverted, every kernel still equals ccv-sim; only checks tuned to base 1 move (RI-54). The RTL stays structural at 1; TI adds a check that refuses it at any other base (RA rev 148).

## Waivers for Daniel's signature

There are 8 RCU entries in `rtl/cg-waivers.json`, all written by RI as the owner. They are charged inside the block's 2,704 above.

- Lead waivers, under Daniel's ruling (RA rev 87):
  - rcu_pred CG-5 ×2: MIU's kept lead, 46 flops; each slot's guard lead.
  - rcu_r CG-5: imm and rrow, 48 flops.
  - rcu_isd CG-5: the class word and its lead copies (RA 131).
- Credit waiver, under Daniel's ruling (RA rev 88): rcu_kill CG-1, the credit-return pulses, 41 flops.
- Owner waivers, signed by Daniel on 2026-11-15 (RI-47, RI-55; each entry's `by` says so):
  - rcu_lanes CG-3, `pcm_n_cr04h`: PC's merge mask, 4 × 32 flops. Its floors are medium 49% and high 65%; measured 51% and 67%.
  - rcu_kill CG-4, `kd_cr02h`: the kill drain counter, 4 flops (max 4: $clog2(KILL_DRAIN + 1) at KILL_DRAIN 15).
  - rcu_kill CG-4, `kaep_q_cr03h`: the kill ack epoch, 2 flops.

`rtl/cg-ratchet.json`, `rtl/ngd-ratchet.json` and `rtl/stage-ratchet.json` have no RCU entry.

## Still open before sign-off

1. **Daniel:** the sign-off, after RA's report. The three owner waivers are signed (2026-11-15, RI-55).
2. **RA:** reconciling the spec with what was built (`docs/rcu-impl.md`, phase 5). RA's phase-5 items for RI (rev 140) are all closed (RA rev 142). That includes (6): under the full-row interim every GPR load overlaps section 0, so MIU never co-issues two and `one_load_a_bank` holds as built; it narrows to per bank when FULL_ROW goes (RA rev 141, MA 54). RA reports to DA.
3. **Block report:** `docs/rcu-block-report.md` (cells, flops, gating, DCGE, the 2% budget, depth histogram) at 5516e643.
4. **Not blocking, TI's:**
   - the SFU variant of the kill kernel, which needs a lane stub that sends SFU results; then the end-to-end SW check through the block. RI records its margin when it lands.
   - the stub's address timed from the param, with the RTL refused at a base other than 1 (RI-54; RA rev 148; TI).

Closed since 2026-11-14: the split tree with the RTL (TI 7079fc14; RA rev 143), the SFU class in the model's decode (RA rev 146, 9f513f3b), the address cycle (RA rev 148, ce5f44dd), `addr-late` in `tools/check-rcu-unit.sh`'s control list (TI a5481843), and the kill kernel with lane ops in flight, rokilllane (TI 1861cc51, rev 457; margin 15, RI-58).
