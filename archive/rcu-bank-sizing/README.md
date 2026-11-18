# RCU bank sizing stand-in (archived)

The measurements behind the register file's slicing (Daniel, 2026-11-03;
spec *CCV RCU Architecture*, Register file tab, "Slices and physical
hierarchy"). **Nothing here is built, linted or run by the gate or any
bench**: `tools/` and `test/` never read `archive/`. The real module is RI's
`ccv_rcu_bank_slice`; this is only a stand-in for its size and depth.

- `rcu_bank_sz.sv`: ROWS × (8 × LANES) bits of flop rows, RP read ports and
  WP write ports. Every select is a predecoded one-hot pair in `(* keep *)`
  flops (sel\_hi of r\[7:4\], sel\_lo of r\[3:0\]), one copy per SECW bits
  per port (RA-33 (a)). Read: AND-OR from the select flops. Write: hit =
  v & hi & lo, row enable = OR of hits, D = OR of hit & lane mask & data,
  else hold. `ONEHOT=1` holds the read selects as a ROWS-bit one-hot.
  Its parameter defaults are small on purpose: Yosys elaborates a module's
  defaults when it reads the file, and whole-bank defaults took a 64k-cell
  unit to 4.7 GB (449 MiB with small ones).
- `measure.py`: one unit through `tools/check-ngd.py`'s own synthesis and
  ABC timing, with a private empty synthesis cache, so peak memory and time
  are a cold run's. Prints NGD (with the fanout term), flops, cells, peak
  MiB and seconds.
- `run.sh`: every figure below, or one unit.

## Results (2026-11-03)

| Unit (192 rows unless noted) | Flops | Cells | Peak | Time | Read out, NGD (with fanout) |
|---|---|---|---|---|---|
| `ooe_rob_w`, the envelope reference (measure.py on rtl/ooe/ooe_rob_w.sv at the package sizes; not in run.sh) | 5,359 | 158,437 | 1,914 MiB | 561 s | — |
| Byte slice, 2 lanes | 3,479 | 98,802 | 692 MiB | 98 s | 8.3 (10.3) |
| **Byte slice, 4 lanes (chosen)** | 6,551 | 193,498 | 1,350 MiB | 198 s | 8.3 (11.0) |
| Byte slice, 8 lanes | 12,695 | 382,890 | 2,665 MiB (heavy) | 435 s | 8.3 (11.0) |
| Lane slice, 1 lane × 4 sections | 7,727 | 203,550 | 1,419 MiB | — | 8.3 (10.3) |
| Byte slice, 8 lanes, 32 rows | — | — | — | — | 5.8 |
| Whole bank, extrapolated | ~50k | ~1.5M | ~10.5 GB | — | — |

- Write path 7.3 NGD, write-data input 5.6 (byte slice, 4 lanes).
- One-hot R read selects: 8.0 NGD (9.3 with fanout), against 8.3 (11.0)
  predecoded: a fanout fix, not a depth fix.
- The slice's read out took a budget of 11 (Register file tab); RA-39 moved
  R0/R1 to A to fit the R path under 25 with it.

The fanout term was report-only when these ran; check-ngd enforces it since
TI rev 299, which changes no figure here.
