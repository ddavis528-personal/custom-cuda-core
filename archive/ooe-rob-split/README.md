# The ROB split's miter (archived)

OA-24 (a), OA rev 312; DA rev 104 split `ooe_rob` into four per-warp
`ooe_rob_w` (`rtl/ooe/ooe_rob_w.sv`). This directory keeps the pre-split ROB
and the formal miter that compared the two. **Nothing here is built, linted
or run by the gate or any bench** (`tools/` and `test/` never read
`archive/`; DA, 2026-11-02: no full-size ROB check may stay in a regression).

- `ooe_rob_ref.sv`: the single `ooe_rob` of 917752b (slices 1 and 2),
  renamed `ooe_rob_ref`, frozen.
- `fv_rob_split.sv`: the miter, the reference beside four `ooe_rob_w` and
  the OR of their frees, every output compared each cycle after reset;
  control `FV_MUT_WID` builds instance 1 as slot 2 and must fail.
- `run.sh`: Yosys to AIGER, then ABC `bmc3`; `maxrss.py` reports peak memory.

## Result (2026-11-02)

At D 8 entries a warp, PCW 16 (full size, D 32, took Yosys past 12.9 GB of
the container's 14.3 and was stopped; D 8 keeps every WID compare):

- The split passes BMC through frame 9 (reset held to frame 3, so six live
  cycles); frame 10 had not returned after more than an hour, and PDR found
  no invariant in 30 minutes. Depth 40 is out of reach here. DA closed the
  equivalence work at this point (2026-11-02).
- The control fails at frame 8, as it must.
- Yosys about 5.4 GB a build; ABC under 0.6 GB.

The claim's limits: both sides start from all-zero flops; the RTL's
don't-care x values are zero on both; the reference's own assertions are
assumed as the inputs' constraints; a payload is compared only where its
valid is set (the reference loaded every slot's retire payload on one
enable, each `ooe_rob_w` loads only its own; `ooe_rat` reads `ret_dst` and
`ret_gname` only under `ret_gwe`, `ret_pdst` and `ret_pname` under
`ret_pwe`). The split's main evidence is the benches: `test/ooe/run-rtl.sh`
passes, `rob_tb` against the model shows no mismatch in 50 seeds (25 with
mispredicts), every negative control caught.
