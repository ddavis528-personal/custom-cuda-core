# RCU exit table, M0 to M7 (RI)

RI's measurements against the exit table in the RCU spec's Partition tab
(`docs/design-snapshots/rcu-arch-partition.md`, rows M0 to M7; the live doc
wins), and `docs/rcu-impl.md` section 5, phase 5: "every row of the exit table
met, or a waiver Daniel signs. Then RA reconciles the spec with what was
built."

Measured at 7e10e72f (2026-11-13). The gate is
`verify-7e10e72f-20261113-2049.log`, SCOPED PASS 15/24, with check-cg and
check-ngd included. The last full gate is 7e29cef5, SPLIT PASS 24/24. The
figures the gate doesn't print were measured at the same commit by the
commands below.

## Summary

| Row | Verdict |
|---|---|
| M0, block lock-step | MET |
| M1, NGD | MET, except the pred guard path in A: **17.0 against 16** (raised to RA) |
| M2, clock gating | MET |
| M3, bank slice | MET on flops, AND-OR and memory. The AND-OR sits exactly at its limit. Whether a heavy-listed unit is a "light unit" is for RA or DA to rule |
| M4, kill drain | MET by the recorded margin. The RTL control at KILL_DRAIN − 1 fails as it should |
| M5, migration | MET: 65 and 67 cycles, against a bound of 68 |
| M6, kernels | MET |
| M7, swap boundary | MET with the model. The RTL passes locally, pending TI's selector in the gate (RI-44) |

## The rows

**M0 (tail): block lock-step.**
- `rcu_ls` passes 63 kernels, every output and event compared every cycle, the four `*_demote` runs included.
- 11 controls are caught: init, opnd, ev, gate, row, lead, arrival, pair, rzero, rdup and iso, plus the corrupt-output control.
- The model's unit tests pass, and their 7 controls are caught.
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

RI's proposal to RA is a kept copy of the guard-lead flops for the guard-result path alone. That takes the 13.6 cone off the shared net, and costs up to 126 more lead flops. Those are waived lead flops, charged to the block's 2%, which has about 2,245 flops of headroom. The alternative is for RA to restate the target.

**M2: clock gating.**
- Block rcu: 247,473 flops. 2% allows 4,949.5. Its modules take 2,704, auto-waived (55%). That includes 825 waived lead or credit flops and 218 repeater control flops.
- Every module is within its own allowance.
- The ratchets hold no RCU entry.

**M3: the bank slice.**
- Flops: 6,556 (k0 6,553, k2 6,559, k3 6,562), within 0.2% of 6,550.
- Read AND-OR: 11.0 with the fanout term (8.3 without), against a limit of 11, so there is no margin.
- Peak memory: 1,435 MiB, against 2,048.
- The four slice units are on `tools/heavy-units.json` so that each runs alone. Four side by side ran a 15 GB container out of memory on 2026-11-08 (TI #91). Each one's own peak is within the light limit. RA or DA should rule whether that meets "completes as a light unit".

**M4: kill drain.**
- KILL_DRAIN is 15, derived (RA-43's zero-cycle issue).
- RTL: rcu_kill's bench control `drain`, at KILL_DRAIN − 1, fails as it must. So do ccv_rcu_killsleep's drop1 and drop2.
- Kernels: 61 kernels were run in ccv-skel with `CCV_RCU_KILL_DRAIN_CUT` at 0 and 1. The 8 that kill (addrhigh, addrneg, divchw, roconst, rogated, rokill, rolaunch and rolimit) were also run at cuts 2, 5 and 15. All pass. The cut does take effect: for example, rokill goes from 103 to 102 cycles.
- No kernel has RCU work in flight when its kill lands, so the margin is recorded as the whole drain, as on 2026-11-05 (`docs/rcu-model.md`).
- A kernel that fails would need a kill with an SFU op in flight. That's a kernel for TI.

**M5: migration.**
- From `test/rcu/cg-build.sh rcu_mig` and the bench `tb`: `mig M5 demotion 65 cycles (R idle 17), restore 67 (R idle 31), bound 68: met`.
- The random run gives 673 demotions, 571 restores, 108 kills, and 0 mismatches in 66,800 values.

**M6: kernels.**
- check-kernel and check-skel pass with the model as RCU by default: 63 kernels, every control caught.
- check-sv-hosted runs 63 kernels plus 4 swapping variants. All 45 kernel controls give the same KERNEL line in both hosts.

**M7: swap boundary.**
- Gate, with the model as RCU in both hosts: 67 of 67 SV-hosted runs equal their C++-hosted runs.
- RTL as RCU in the SV top (`test/rcu/ccv_rcu_svh.sv`), run locally with TI's host diff (RI-44):
  - 63 of 63 kernels clean, divergences=0;
  - the RTL's final register compare clean;
  - the four `*_demote` runs clean;
  - the compare's controls (ev, gate, row) and the flip control fail as they must.
- This goes into the gate once TI adds the SVHOST 45/46 selector.

## Waivers for Daniel's signature

There are 8 RCU entries in `rtl/cg-waivers.json`, all written by RI as the owner. They are charged inside the block's 2,704 above.

- Lead waivers, under Daniel's ruling (RA rev 87):
  - rcu_pred CG-5 ×2: MIU's kept lead, 46 flops; each slot's guard lead.
  - rcu_r CG-5: imm and rrow, 48 flops.
  - rcu_isd CG-5: the class word and its lead copies (RA 131).
- Credit waiver, under Daniel's ruling (RA rev 88): rcu_kill CG-1, the credit-return pulses, 41 flops.
- Owner waivers with no ruling cited, for Daniel to sign or refuse:
  - rcu_lanes CG-3, `pcm_n_cr04h`: PC's merge mask, 4 × 32 flops. Its floors are medium 49% and high 65%; measured 51% and 67%.
  - rcu_kill CG-4, `kd_cr02h`: the kill drain counter, 4 flops (max 5).
  - rcu_kill CG-4, `kaep_q_cr03h`: the kill ack epoch, 2 flops.

`rtl/cg-ratchet.json`, `rtl/ngd-ratchet.json` and `rtl/stage-ratchet.json` have no RCU entry.

## Still open before sign-off

1. **M1 guard path:** RA's choice between the kept lead copy and restating the target.
2. **M3 wording:** "light unit".
3. **M7 in the gate:** TI's selector, and the merge of 7e10e72f (RI-44).
4. **Daniel:** the three owner waivers above, and the sign-off.
5. **RA:** reconciling the spec with what was built (`docs/rcu-impl.md`, phase 5).
