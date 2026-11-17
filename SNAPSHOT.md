# Snapshot snapshot-2026-11-17-56768c7

**A generated, read-only snapshot. Do not edit or merge it.** The source
is `ti-l1ecc` at `56768c792d6f371c3ee38364c6c5033a354b150a`, and this branch is rebuilt from source by
`tools/make-release.sh`; nothing here flows back.

**Start with [`docs/walkthrough.md`](docs/walkthrough.md):** one kernel
through the whole machine, every listing generated from this tree.

What is here beyond the source tree at that commit:

- **Generated files, at their real paths:** `rtl/generated/` (interface
  typedefs in `ccv_interfaces.svh`, parameter packages, the checker
  bank, event ids) and `sim/generated/`. On the development branch
  these are build products and gitignored.
- **`release/`:** the gate log (`verify.log`), the C++ skeleton's
  wiring dump, and for each S1 kernel its run summary, event trace
  (`.ccvtrace`) and two Perfetto views -- open the `.json` files at
  https://ui.perfetto.dev; a view over 1 MB ships as `.json.gz`, which
  the UI opens as it is -- and the ccv-sim oracle record it ran
  against, generated from the pinned compiler snapshot, and the
  same kernel's run with every block hosted by the SV top
  (`.sv-hosted.log`).

| | |
|---|---|
| Source | `ti-l1ecc` @ `56768c792d6f371c3ee38364c6c5033a354b150a` |
| Built | 2026-11-17 (UTC) |
| Gate | `tools/verify.sh`: PASS |
| Compiler snapshot | custom-cuda-complier `release` @ `a9241c22aee7ddb328c446b1467d71d7acc82033` (source `807056d4935cf7737caa0a89847d6bede6877e8d`) |
| Verilator | Verilator 5.052 2026-09-05 rev v5.052 |
| Icarus | Icarus Verilog version 12.0 (stable) () |
| Yosys | Yosys 0.33 (git sha1 2584903a060) |

## Kernels

| Kernel | Result |
|---|---|
| `addrhigh` | `name=addrhigh finished=1 cycles=83 from_fetch=52 retired=5 issue_groups=6 order=ok gpr_mismatch=0 pred_mismatch=0 mem_mismatch=0 check_failures=0 class_violations=0 overflows=0 credit_leaks=0 cor_late=0 channels_used=26/55 violations=0` |
| `addrlimit` | `name=addrlimit finished=1 cycles=1072 from_fetch=1041 retired=5 issue_groups=5 order=ok gpr_mismatch=0 pred_mismatch=0 mem_mismatch=0 check_failures=0 class_violations=0 overflows=0 credit_leaks=0 cor_late=0 channels_used=27/55 violations=0` |
| `addrneg` | `name=addrneg finished=1 cycles=80 from_fetch=49 retired=1 issue_groups=2 order=ok gpr_mismatch=0 pred_mismatch=0 mem_mismatch=0 check_failures=0 class_violations=0 overflows=0 credit_leaks=0 cor_late=0 channels_used=23/55 violations=0` |
| `atom` | `name=atom finished=1 cycles=8605 from_fetch=8574 retired=29 issue_groups=29 order=ok gpr_mismatch=0 pred_mismatch=0 mem_mismatch=0 check_failures=0 class_violations=0 overflows=0 credit_leaks=0 cor_late=0 channels_used=32/55 violations=0` |
| `atomf` | `name=atomf finished=1 cycles=4609 from_fetch=4578 retired=12 issue_groups=12 order=ok gpr_mismatch=0 pred_mismatch=0 mem_mismatch=0 check_failures=0 class_violations=0 overflows=0 credit_leaks=0 cor_late=0 channels_used=34/55 violations=0` |
| `borrow` | `name=borrow finished=1 cycles=99 from_fetch=68 retired=7 issue_groups=7 order=ok gpr_mismatch=0 pred_mismatch=0 mem_mismatch=0 check_failures=0 class_violations=0 overflows=0 credit_leaks=0 cor_late=0 channels_used=21/55 violations=0` |
| `brs` | `name=brs finished=1 cycles=99 from_fetch=68 retired=12 issue_groups=12 order=ok gpr_mismatch=0 pred_mismatch=0 mem_mismatch=0 check_failures=0 class_violations=0 overflows=0 credit_leaks=0 cor_late=0 channels_used=23/55 violations=0` |
| `byp` | `name=byp finished=1 cycles=118 from_fetch=87 retired=14 issue_groups=14 order=ok gpr_mismatch=0 pred_mismatch=0 mem_mismatch=0 check_failures=0 class_violations=0 overflows=0 credit_leaks=0 cor_late=0 channels_used=31/55 violations=0` |
| `callret` | `name=callret finished=1 cycles=265 from_fetch=234 retired=40 issue_groups=40 order=ok gpr_mismatch=0 pred_mismatch=0 mem_mismatch=0 check_failures=0 class_violations=0 overflows=0 credit_leaks=0 cor_late=0 channels_used=30/55 violations=0` |
| `cas` | `name=cas finished=1 cycles=6908 from_fetch=6877 retired=56 issue_groups=56 order=ok gpr_mismatch=0 pred_mismatch=0 mem_mismatch=0 check_failures=0 class_violations=0 overflows=0 credit_leaks=0 cor_late=0 channels_used=32/55 violations=0` |
| `chains` | `name=chains finished=1 cycles=96 from_fetch=65 retired=29 issue_groups=29 order=ok gpr_mismatch=0 pred_mismatch=0 mem_mismatch=0 check_failures=0 class_violations=0 overflows=0 credit_leaks=0 cor_late=0 channels_used=21/55 violations=0` |
| `coll` | `name=coll finished=1 cycles=78 from_fetch=47 retired=24 issue_groups=24 order=ok gpr_mismatch=0 pred_mismatch=0 mem_mismatch=0 check_failures=0 class_violations=0 overflows=0 credit_leaks=0 cor_late=0 channels_used=21/55 violations=0` |
| `div` | `name=div finished=1 cycles=978 from_fetch=947 retired=144 issue_groups=144 order=ok gpr_mismatch=0 pred_mismatch=0 mem_mismatch=0 check_failures=0 class_violations=0 overflows=0 credit_leaks=0 cor_late=0 channels_used=23/55 violations=0` |
| `divchw` | `name=divchw finished=1 cycles=111 from_fetch=80 retired=5 issue_groups=6 order=ok gpr_mismatch=0 pred_mismatch=0 mem_mismatch=0 check_failures=0 class_violations=0 overflows=0 credit_leaks=0 cor_late=0 channels_used=22/55 violations=0` |
| `divtail` | `name=divtail finished=1 cycles=642 from_fetch=611 retired=96 issue_groups=96 order=ok gpr_mismatch=0 pred_mismatch=0 mem_mismatch=0 check_failures=0 class_violations=0 overflows=0 credit_leaks=0 cor_late=0 channels_used=23/55 violations=0` |
| `divtail2` | `name=divtail2 finished=1 cycles=1517 from_fetch=1486 retired=366 issue_groups=366 order=ok gpr_mismatch=0 pred_mismatch=0 mem_mismatch=0 check_failures=0 class_violations=0 overflows=0 credit_leaks=0 cor_late=0 channels_used=23/55 violations=0` |
| `fence` | `name=fence finished=1 cycles=83 from_fetch=52 retired=7 issue_groups=7 order=ok gpr_mismatch=0 pred_mismatch=0 mem_mismatch=0 check_failures=0 class_violations=0 overflows=0 credit_leaks=0 cor_late=0 channels_used=30/55 violations=0` |
| `gather` | `name=gather finished=1 cycles=265 from_fetch=234 retired=16 issue_groups=16 order=ok gpr_mismatch=0 pred_mismatch=0 mem_mismatch=0 check_failures=0 class_violations=0 overflows=0 credit_leaks=0 cor_late=0 channels_used=32/55 violations=0` |
| `hit` | `name=hit finished=1 cycles=215 from_fetch=184 retired=17 issue_groups=17 order=ok gpr_mismatch=0 pred_mismatch=0 mem_mismatch=0 check_failures=0 class_violations=0 overflows=0 credit_leaks=0 cor_late=0 channels_used=31/55 violations=0` |
| `lanectx` | `name=lanectx finished=1 cycles=70 from_fetch=39 retired=10 issue_groups=10 order=ok gpr_mismatch=0 pred_mismatch=0 mem_mismatch=0 check_failures=0 class_violations=0 overflows=0 credit_leaks=0 cor_late=0 channels_used=29/55 violations=0` |
| `lanectx2` | `name=lanectx2 finished=1 cycles=70 from_fetch=39 retired=10 issue_groups=10 order=ok gpr_mismatch=0 pred_mismatch=0 mem_mismatch=0 check_failures=0 class_violations=0 overflows=0 credit_leaks=0 cor_late=0 channels_used=29/55 violations=0` |
| `late` | `name=late finished=1 cycles=168 from_fetch=137 retired=16 issue_groups=16 order=ok gpr_mismatch=0 pred_mismatch=0 mem_mismatch=0 check_failures=0 class_violations=0 overflows=0 credit_leaks=0 cor_late=0 channels_used=31/55 violations=0` |
| `ldpar` | `name=ldpar finished=1 cycles=154 from_fetch=123 retired=17 issue_groups=17 order=ok gpr_mismatch=0 pred_mismatch=0 mem_mismatch=0 check_failures=0 class_violations=0 overflows=0 credit_leaks=0 cor_late=0 channels_used=31/55 violations=0` |
| `lnorm1` | `name=lnorm1 finished=1 cycles=2515 from_fetch=2484 retired=526 issue_groups=526 order=ok gpr_mismatch=0 pred_mismatch=0 mem_mismatch=0 check_failures=0 class_violations=0 overflows=0 credit_leaks=0 cor_late=0 channels_used=37/55 violations=0` |
| `localsp` | `name=localsp finished=1 cycles=2175 from_fetch=2144 retired=40 issue_groups=40 order=ok gpr_mismatch=0 pred_mismatch=0 mem_mismatch=0 check_failures=0 class_violations=0 overflows=0 credit_leaks=0 cor_late=0 channels_used=31/55 violations=0` |
| `loop` | `name=loop finished=1 cycles=2842 from_fetch=2811 retired=407 issue_groups=407 order=ok gpr_mismatch=0 pred_mismatch=0 mem_mismatch=0 check_failures=0 class_violations=0 overflows=0 credit_leaks=0 cor_late=0 channels_used=23/55 violations=0` |
| `merge` | `name=merge finished=1 cycles=71 from_fetch=40 retired=9 issue_groups=9 order=ok gpr_mismatch=0 pred_mismatch=0 mem_mismatch=0 check_failures=0 class_violations=0 overflows=0 credit_leaks=0 cor_late=0 channels_used=21/55 violations=0` |
| `missrun` | `name=missrun finished=1 cycles=121 from_fetch=90 retired=28 issue_groups=28 order=ok gpr_mismatch=0 pred_mismatch=0 mem_mismatch=0 check_failures=0 class_violations=0 overflows=0 credit_leaks=0 cor_late=0 channels_used=31/55 violations=0` |
| `mload` | `name=mload finished=1 cycles=111 from_fetch=80 retired=11 issue_groups=11 order=ok gpr_mismatch=0 pred_mismatch=0 mem_mismatch=0 check_failures=0 class_violations=0 overflows=0 credit_leaks=0 cor_late=0 channels_used=31/55 violations=0` |
| `mlp` | `name=mlp finished=1 cycles=126 from_fetch=95 retired=21 issue_groups=21 order=ok gpr_mismatch=0 pred_mismatch=0 mem_mismatch=0 check_failures=0 class_violations=0 overflows=0 credit_leaks=0 cor_late=0 channels_used=31/55 violations=0` |
| `mwmiss` | `name=mwmiss finished=1 cycles=129 from_fetch=98 retired=88 issue_groups=88 order=ok gpr_mismatch=0 pred_mismatch=0 mem_mismatch=0 check_failures=0 class_violations=0 overflows=0 credit_leaks=0 cor_late=0 channels_used=31/55 violations=0` |
| `narrowadd` | `name=narrowadd finished=1 cycles=226 from_fetch=195 retired=21 issue_groups=21 order=ok gpr_mismatch=0 pred_mismatch=0 mem_mismatch=0 check_failures=0 class_violations=0 overflows=0 credit_leaks=0 cor_late=0 channels_used=32/55 violations=0` |
| `pguard` | `name=pguard finished=1 cycles=87 from_fetch=56 retired=12 issue_groups=12 order=ok gpr_mismatch=0 pred_mismatch=0 mem_mismatch=0 check_failures=0 class_violations=0 overflows=0 credit_leaks=0 cor_late=0 channels_used=29/55 violations=0` |
| `plog` | `name=plog finished=1 cycles=71 from_fetch=40 retired=11 issue_groups=11 order=ok gpr_mismatch=0 pred_mismatch=0 mem_mismatch=0 check_failures=0 class_violations=0 overflows=0 credit_leaks=0 cor_late=0 channels_used=21/55 violations=0` |
| `pmovdiv` | `name=pmovdiv finished=1 cycles=104 from_fetch=73 retired=12 issue_groups=12 order=ok gpr_mismatch=0 pred_mismatch=0 mem_mismatch=0 check_failures=0 class_violations=0 overflows=0 credit_leaks=0 cor_late=0 channels_used=22/55 violations=0` |
| `predlane` | `name=predlane finished=1 cycles=928 from_fetch=897 retired=10 issue_groups=10 order=ok gpr_mismatch=0 pred_mismatch=0 mem_mismatch=0 check_failures=0 class_violations=0 overflows=0 credit_leaks=0 cor_late=0 channels_used=31/55 violations=0` |
| `predmerge` | `name=predmerge finished=1 cycles=940 from_fetch=909 retired=9 issue_groups=9 order=ok gpr_mismatch=0 pred_mismatch=0 mem_mismatch=0 check_failures=0 class_violations=0 overflows=0 credit_leaks=0 cor_late=0 channels_used=33/55 violations=0` |
| `predspill` | `name=predspill finished=1 cycles=968 from_fetch=937 retired=12 issue_groups=12 order=ok gpr_mismatch=0 pred_mismatch=0 mem_mismatch=0 check_failures=0 class_violations=0 overflows=0 credit_leaks=0 cor_late=0 channels_used=31/55 violations=0` |
| `predswap` | `name=predswap finished=1 cycles=1186 from_fetch=1155 retired=46 issue_groups=46 order=ok gpr_mismatch=0 pred_mismatch=0 mem_mismatch=0 check_failures=0 class_violations=0 overflows=0 credit_leaks=0 cor_late=0 channels_used=33/55 violations=0` |
| `privwin` | `name=privwin finished=1 cycles=1161 from_fetch=1130 retired=52 issue_groups=52 order=ok gpr_mismatch=0 pred_mismatch=0 mem_mismatch=0 check_failures=0 class_violations=0 overflows=0 credit_leaks=0 cor_late=0 channels_used=34/55 violations=0` |
| `provswap` | `name=provswap finished=1 cycles=2285 from_fetch=2254 retired=978 issue_groups=978 order=ok gpr_mismatch=0 pred_mismatch=0 mem_mismatch=0 check_failures=0 class_violations=0 overflows=0 credit_leaks=0 cor_late=0 channels_used=33/55 violations=0` |
| `retmiss` | `name=retmiss finished=1 cycles=184 from_fetch=153 retired=19 issue_groups=19 order=ok gpr_mismatch=0 pred_mismatch=0 mem_mismatch=0 check_failures=0 class_violations=0 overflows=0 credit_leaks=0 cor_late=0 channels_used=33/55 violations=0` |
| `roconst` | `name=roconst finished=1 cycles=76 from_fetch=45 retired=4 issue_groups=5 order=ok gpr_mismatch=0 pred_mismatch=0 mem_mismatch=0 check_failures=0 class_violations=0 overflows=0 credit_leaks=0 cor_late=0 channels_used=26/55 violations=0` |
| `rogated` | `name=rogated finished=1 cycles=96 from_fetch=65 retired=7 issue_groups=8 order=ok gpr_mismatch=0 pred_mismatch=0 mem_mismatch=0 check_failures=0 class_violations=0 overflows=0 credit_leaks=0 cor_late=0 channels_used=26/55 violations=0` |
| `rokill` | `name=rokill finished=1 cycles=104 from_fetch=73 retired=41 issue_groups=4536 order=ok gpr_mismatch=0 pred_mismatch=0 mem_mismatch=0 check_failures=0 class_violations=0 overflows=0 credit_leaks=0 cor_late=0 channels_used=27/55 violations=0` |
| `rokilllane` | `name=rokilllane finished=1 cycles=1214 from_fetch=1183 retired=924 issue_groups=10674 order=ok gpr_mismatch=0 pred_mismatch=0 mem_mismatch=0 check_failures=0 class_violations=0 overflows=0 credit_leaks=0 cor_late=0 channels_used=27/55 violations=0` |
| `rolaunch` | `name=rolaunch finished=1 cycles=74 from_fetch=43 retired=4 issue_groups=5 order=ok gpr_mismatch=0 pred_mismatch=0 mem_mismatch=0 check_failures=0 class_violations=0 overflows=0 credit_leaks=0 cor_late=0 channels_used=24/55 violations=0` |
| `rolimit` | `name=rolimit finished=1 cycles=76 from_fetch=45 retired=4 issue_groups=5 order=ok gpr_mismatch=0 pred_mismatch=0 mem_mismatch=0 check_failures=0 class_violations=0 overflows=0 credit_leaks=0 cor_late=0 channels_used=26/55 violations=0` |
| `roload` | `name=roload finished=1 cycles=105 from_fetch=74 retired=8 issue_groups=8 order=ok gpr_mismatch=0 pred_mismatch=0 mem_mismatch=0 check_failures=0 class_violations=0 overflows=0 credit_leaks=0 cor_late=0 channels_used=31/55 violations=0` |
| `rope` | `name=rope finished=1 cycles=675 from_fetch=644 retired=354 issue_groups=354 order=ok gpr_mismatch=0 pred_mismatch=0 mem_mismatch=0 check_failures=0 class_violations=0 overflows=0 credit_leaks=0 cor_late=0 channels_used=34/55 violations=0` |
| `ropediv` | `name=ropediv finished=1 cycles=973 from_fetch=942 retired=203 issue_groups=203 order=ok gpr_mismatch=0 pred_mismatch=0 mem_mismatch=0 check_failures=0 class_violations=0 overflows=0 credit_leaks=0 cor_late=0 channels_used=34/55 violations=0` |
| `sel` | `name=sel finished=1 cycles=77 from_fetch=46 retired=8 issue_groups=8 order=ok gpr_mismatch=0 pred_mismatch=0 mem_mismatch=0 check_failures=0 class_violations=0 overflows=0 credit_leaks=0 cor_late=0 channels_used=29/55 violations=0` |
| `sized` | `name=sized finished=1 cycles=985 from_fetch=954 retired=25 issue_groups=25 order=ok gpr_mismatch=0 pred_mismatch=0 mem_mismatch=0 check_failures=0 class_violations=0 overflows=0 credit_leaks=0 cor_late=0 channels_used=32/55 violations=0` |
| `slotform` | `name=slotform finished=1 cycles=4350 from_fetch=4319 retired=12 issue_groups=12 order=ok gpr_mismatch=0 pred_mismatch=0 mem_mismatch=0 check_failures=0 class_violations=0 overflows=0 credit_leaks=0 cor_late=0 channels_used=32/55 violations=0` |
| `spinwait` | `name=spinwait finished=1 cycles=1976 from_fetch=1945 retired=211 issue_groups=211 order=ok gpr_mismatch=0 pred_mismatch=0 mem_mismatch=0 check_failures=0 class_violations=0 overflows=0 credit_leaks=0 cor_late=0 channels_used=34/55 violations=0` |
| `spmbank` | `name=spmbank finished=1 cycles=186 from_fetch=155 retired=13 issue_groups=13 order=ok gpr_mismatch=0 pred_mismatch=0 mem_mismatch=0 check_failures=0 class_violations=0 overflows=0 credit_leaks=0 cor_late=0 channels_used=28/55 violations=0` |
| `srd` | `name=srd finished=1 cycles=70 from_fetch=39 retired=6 issue_groups=6 order=ok gpr_mismatch=0 pred_mismatch=0 mem_mismatch=0 check_failures=0 class_violations=0 overflows=0 credit_leaks=0 cor_late=0 channels_used=29/55 violations=0` |
| `stall` | `name=stall finished=1 cycles=556 from_fetch=525 retired=116 issue_groups=116 order=ok gpr_mismatch=0 pred_mismatch=0 mem_mismatch=0 check_failures=0 class_violations=0 overflows=0 credit_leaks=0 cor_late=0 channels_used=31/55 violations=0` |
| `swap` | `name=swap finished=1 cycles=556 from_fetch=525 retired=174 issue_groups=174 order=ok gpr_mismatch=0 pred_mismatch=0 mem_mismatch=0 check_failures=0 class_violations=0 overflows=0 credit_leaks=0 cor_late=0 channels_used=31/55 violations=0` |
| `transp4` | `name=transp4 finished=1 cycles=1123 from_fetch=1092 retired=976 issue_groups=976 order=ok gpr_mismatch=0 pred_mismatch=0 mem_mismatch=0 check_failures=0 class_violations=0 overflows=0 credit_leaks=0 cor_late=0 channels_used=37/55 violations=0` |
| `unal` | `name=unal finished=1 cycles=137 from_fetch=106 retired=9 issue_groups=9 order=ok gpr_mismatch=0 pred_mismatch=0 mem_mismatch=0 check_failures=0 class_violations=0 overflows=0 credit_leaks=0 cor_late=0 channels_used=32/55 violations=0` |
| `vadd` | `name=vadd finished=1 cycles=158 from_fetch=127 retired=17 issue_groups=17 order=ok gpr_mismatch=0 pred_mismatch=0 mem_mismatch=0 check_failures=0 class_violations=0 overflows=0 credit_leaks=0 cor_late=0 channels_used=33/55 violations=0` |
| `vadd4` | `name=vadd4 finished=1 cycles=204 from_fetch=173 retired=68 issue_groups=68 order=ok gpr_mismatch=0 pred_mismatch=0 mem_mismatch=0 check_failures=0 class_violations=0 overflows=0 credit_leaks=0 cor_late=0 channels_used=33/55 violations=0` |
| `vaddslow` | `name=vaddslow finished=1 cycles=547 from_fetch=516 retired=17 issue_groups=17 order=ok gpr_mismatch=0 pred_mismatch=0 mem_mismatch=0 check_failures=0 class_violations=0 overflows=0 credit_leaks=0 cor_late=0 channels_used=33/55 violations=0` |

## Manifest of release/

```
0c24cf7ebffbe6610027a9841457e7f116313f2710428f190bd256172615f5aa  release/kernels/addrhigh.by_instr.json.gz
b72eea1351cec49132d151dd4ff006d310da470548faf6cfb41d5212526e0a25  release/kernels/addrhigh.by_unit.json.gz
7f4025bfdc4a9e67d17c349cc2031239027d3a614a0080c15e41212d388f6c80  release/kernels/addrhigh.ccvtrace
d188a13da323dee296f6ad49abd1a00b75ea59792469e9b1428c440acd27f4f1  release/kernels/addrhigh.log
569f2e22883fad5f0956c57ec734e6afbdd4b8a854e50277425172d6c0cbd766  release/kernels/addrhigh.oracle.jsonl
eef2ee0788cdb3dd5489520589e7bf442b87f89d6ecd0dfc40efcb56dd154eb1  release/kernels/addrhigh.sv-hosted.log
fdf05a21b8e2f633bf1762387759f685dffafe71b32f0dfe4b60ace1d1647053  release/kernels/addrlimit.by_instr.json
939d6b115a1bc45b8e75c394811a9aa84b1fb504faed4cc318d2f53cd6131e43  release/kernels/addrlimit.by_unit.json
f8287904c415dfd8f4cf0ec4a8dcdb95ef81669e365fea28a62d9f2feaa3ac8f  release/kernels/addrlimit.ccvtrace
2601caaea99b2bf4f608c2b9d2317603315571028937a17cc4314f545672835f  release/kernels/addrlimit.log
bc660b0b40359a2c5a2478cb0eb4950b73fd22db50ea76b80052bc195a1920f4  release/kernels/addrlimit.oracle.jsonl
f7df55169163dd0497514651442045982868f16117364c3f6ecc31d402d9b1ff  release/kernels/addrlimit.sv-hosted.log
444a139be8ad3ef2636383cc788bb28ec816e5e0284123df710c7a5c06003bd5  release/kernels/addrneg.by_instr.json
cc2e8d376cbfa7fcffe6246821ac1957c7be5b157b52ec7e5b037ac37f067408  release/kernels/addrneg.by_unit.json
aaae096aee3b8e71dc063bbf880dc9562e93bac3102ea7b4a1d249bda0baa1df  release/kernels/addrneg.ccvtrace
f0e7b84ca37f444b52f48fa7d6abf472a5ccff0f7de3decc4f3c40f2961af301  release/kernels/addrneg.log
16f5b0707ae44492a1efd67bb9dd38a7e79a7bbd354fa9207b9e7d150ff2f107  release/kernels/addrneg.oracle.jsonl
12b0f135034bc99173211401ed64c59126d14a40366ea22a8a7b330354bb0884  release/kernels/addrneg.sv-hosted.log
8bb822c5b80cdbf263f625efe963f76ec082d333da0a56b995d3ba950175aefb  release/kernels/atom.by_instr.json.gz
7ede6872adab534d43bc7e641f4f8eb320d82afb053ae4b1fe8a8fec76ce40cc  release/kernels/atom.by_unit.json.gz
67214e5fefe2e38f320350b9f45b87cdb42d0e7d4a1a7f6072b7c57e90b8c6e2  release/kernels/atom.ccvtrace
65f76766807d3ddd308a0e8e9f05f51f6843f718a1d0818d8e3137052f06755c  release/kernels/atom.log
504f5b6e9d25114dc35f2c70b21bb7b3f3c508c691de12dc0e87d12a74285361  release/kernels/atom.oracle.jsonl
38f27a4e9b3965067b83dab3bb63ce59d9e721943a7d9b15ef1a2349047d2a86  release/kernels/atom.sv-hosted.log
6ae9dfe1eb75293e3960d7b5fb7048c066ac6067a2e8bdaf672285e83fdaaba2  release/kernels/atomf.by_instr.json.gz
06110b6d44817f8619e297623b8a12df36958a4efd061a1f2703942f01f40147  release/kernels/atomf.by_unit.json.gz
098de58c0913a300162a361cc42b0f5101b06c5bd7a51f91ce63bb456800b6c2  release/kernels/atomf.ccvtrace
7ff6bc20d8fc8ad36a96b99fbeade475d42805b6c37beebeb334e422db7c183c  release/kernels/atomf.log
cfd1179edf4061a33ab2f75d7a6dec61decfe629000198189a7bfc2647b34238  release/kernels/atomf.oracle.jsonl
bbc135dd92534d9f4e9475557b2cb7fdbc10c319d933e619c15aa3fe87f40405  release/kernels/atomf.sv-hosted.log
135eb9efb790404609c1b24844a25a48ab5f0add9025b506beadc652061b5d38  release/kernels/borrow.by_instr.json.gz
ba4353a14d19edeb1ba4bfcb232b67001502d682cd5837ccbe8c8b3374d5d691  release/kernels/borrow.by_unit.json.gz
f47ba0ff76f39020aec6e50deb887c83af18cb9efde597aa3d2ebc7261eb3139  release/kernels/borrow.ccvtrace
c3d024f391d0e65117fcedb685bccadc5401855d7721ab046a343ab09a9d4bb1  release/kernels/borrow.log
4c565e1ce0b3baee36e158694b32c8defb5cd662b2f9af75cb5d8c26cb1168ed  release/kernels/borrow.oracle.jsonl
04b3e0c55151af12edcba83c1849c025e657b62471083b96c5b70d6d7800c72e  release/kernels/borrow.sv-hosted.log
e334ae1626c5357560efbb28205d2b0883d602b6cbb8ae4870102dd037680157  release/kernels/brs.by_instr.json.gz
9e2c9136b4f107b235e5971276e6374e243597b482828707ab6a3c5f44cedaa6  release/kernels/brs.by_unit.json.gz
0efbd34762b9bb839d84507973259b9161e0b6b94498eb217ab8eb280dacf7b3  release/kernels/brs.ccvtrace
fde89de0803e0cd1d0ab0f335c4ab24e713bacd0314dcbb0795f27dbe07bbadc  release/kernels/brs.log
e3c1cb3379580cf1aae44e8ddc8e846ef6fd661a573cfe0a8d4444b18a14dc56  release/kernels/brs.oracle.jsonl
4ee79bbef764298dcd164d3641d9d5a4e99004a7e52fa8aef6cb38b693055a40  release/kernels/brs.sv-hosted.log
19121d97766d2c1d960126d9735c929c44a63f77e9b3ab087ea8a91e4b29e062  release/kernels/byp.by_instr.json.gz
cabda89591311c00389870415e45bd8a3a05b3f936601fd68e4152bb748d8542  release/kernels/byp.by_unit.json.gz
d981f1490d418679982388372cc80497485d972a295ae5f1d1a60d06b0c22c67  release/kernels/byp.ccvtrace
e24483d1f6045db4572b0878fe87b7301d5c3c3fbca3efb4d1d6f5ec82aff466  release/kernels/byp.log
5a03dfa4f3603fef49f1e3639e74e34152ca3ca5ef8e41eb959f8323040fa2d5  release/kernels/byp.oracle.jsonl
08e04271abd0ae026b1145ea63ee74200e7a79d9823602ccf91ae25e99ab95d6  release/kernels/byp.sv-hosted.log
bbaae1d0f18812bf94a4e62de892a8797557504f5c966b0d593d1da3c0cb01a7  release/kernels/callret.by_instr.json.gz
8ff8a6a20f2889323a322456a7ec019bebb851df60280a19575387b855c2d713  release/kernels/callret.by_unit.json.gz
485f5f7c964b7718cdf5f6475c30219443e9a079bfcab6718359dd789900a2c6  release/kernels/callret.ccvtrace
547fc1318d0d1c4f7a1ac5e325c26da0bc202c8a8ad51e2685b4d94b423bcb64  release/kernels/callret.log
9b1d1b50b527f732362f837250aa2f26dabf3e76e16a4794856ebd8f105635b8  release/kernels/callret.oracle.jsonl
bf45b33160436a1de9f66f41bd00474b077409e6f842cfe1b2589ae9eaee4c2c  release/kernels/callret.sv-hosted.log
c643311f2700eaf7c589c0e64186193c7d9cf42c684af67c50b58b305b5da550  release/kernels/cas.by_instr.json.gz
2fbf02dff16f9628c8805657fbf3c77b6959c0d9643554ce3456481741bd1da3  release/kernels/cas.by_unit.json.gz
df448ccfbf455fe5abd8ab9a4deac8d3b068ef26494c81dc0ebf78f22bc88684  release/kernels/cas.ccvtrace
bc653250c9c1c8826ab5d5cec08160f4dea35314b0c7d36cf76179cf6ac80358  release/kernels/cas.log
0ab31a9443336fe5d08e1a5fa5fcba3bc279b19022f7c5007908d39d8ef39536  release/kernels/cas.oracle.jsonl
a83613096e3c0cdf7483ffeac883dcd6394bf87c1abd0756d3e3ed69036b5d65  release/kernels/cas.sv-hosted.log
6e1252441a7d409b8e8cb23036b77de60b790bf630831c7dea1e5575d78b4610  release/kernels/chains.by_instr.json.gz
20e3447cecc39832a277a409f0be6c7c0e6493195f10edf64b088144dab2fbf0  release/kernels/chains.by_unit.json.gz
b47e10902de830c337bf591bfc2daf06098880741b67957d8e8dd9c45208dc56  release/kernels/chains.ccvtrace
8d3f3d205ff9d2f9ec4b1b9153332062b1ccc2e37048430fd6fb5465c8a6adb5  release/kernels/chains.log
26a4cc5c5524c7219d8706c2582c80357dea60be9d6ffdec99dac7d0365e2264  release/kernels/chains.oracle.jsonl
f541098a9efd6536b337f8e96601b3e132c9bd9b0ef44cd26ff6127806c73d2a  release/kernels/chains.sv-hosted.log
82cb28c0aa156a72d3a9110df24fec59909843191beef64286efd283a38fe870  release/kernels/coll.by_instr.json.gz
943a48ed7a8a9d3e963e372dde3b4fddc9270f5c47a8ea55de6221c1f5c709f6  release/kernels/coll.by_unit.json.gz
9b2defbca3a81f102a07f1fb1a9473253e58da6ab1e7375a8d81f4d1fe098bae  release/kernels/coll.ccvtrace
9a42fccf43093b9a678988d3c33fd7bade69270a538c61adff15a02b4b801fd9  release/kernels/coll.log
dd718d23c88df5dc7d92b055d8542865aa0e029118486af127312a8a578cfcbc  release/kernels/coll.oracle.jsonl
c75fa9b26bae2dcb0fe53976ffd196c773ad4dfdea314179f7fd87bb53aa4fd0  release/kernels/coll.sv-hosted.log
6fa09209e904c824b91bbd0ad7131d614b759bd8b428eaeac2ab185de257b858  release/kernels/div.by_instr.json.gz
1c6f033c4078cff91789608d143cca69c07d0c6a7faf85bdf552926482e10ed1  release/kernels/div.by_unit.json.gz
182346c5baad147767effbea67248ccbc6e5c35582f0590ab266ce10e6e9dbc8  release/kernels/div.ccvtrace
f96c31a039f22248349177f56cc28abde17125b635030abadd5726d01dbfadbb  release/kernels/div.log
71a567b85cf85622631490187563de9a5661099c78a590adff4ed0a0c3d24c16  release/kernels/div.oracle.jsonl
6d625c1291187a879155bf714598609596722e4cbae7a2e5eea80aff7a1f44ca  release/kernels/div.sv-hosted.log
3452fbc7d3f59725eb07f1d7009010b54dadddff9021a969e5119513d75e4271  release/kernels/divchw.by_instr.json.gz
7b1f96bccb0085e23f8bcb32f7107e2a8c16e3b5e5be1f2a97d7cd6228d20457  release/kernels/divchw.by_unit.json.gz
4471a48e9f9555ec3ff526316b30290fb0ff75d28588185a2a52382020681eb5  release/kernels/divchw.ccvtrace
e686e48b43b1625bb3f158f5a9ade85a9cd789adaaa348d446f1fa4007d99b8f  release/kernels/divchw.log
58a541797f7a2df0a1c7528ae6a3edec212db90c7d3eb20656806f38b5c10b3d  release/kernels/divchw.oracle.jsonl
a941e3be8630492a45ea0a8ce5795503de2ae1a249582b332d45ac461d246469  release/kernels/divchw.sv-hosted.log
b3c589bac9c7b02d88d37c09bc392b854aaa4b7f1e1df8d31a9376e55950fba5  release/kernels/divtail.by_instr.json.gz
3eb524069032f04fe00933d5d770c666a20dd3203c90057666d8420d91d9477d  release/kernels/divtail.by_unit.json.gz
2ade202d8c5fc071687f18239b0573f55461d1606452ff6daa16db3738442f2c  release/kernels/divtail.ccvtrace
4a032dbea80b2e7c78314abe431fc8544595ea430d15f98e405f2117d747de44  release/kernels/divtail.log
75f11a75c9b3b336e446140af4579f05b46c363a76b7aab3ec88154a07ba097d  release/kernels/divtail.oracle.jsonl
d854c03fb07bd8388661a9a145c30feea989c1bc3ef52f440c6c79f8633d29c8  release/kernels/divtail.sv-hosted.log
401a311a6ffbf939e1b9506524d928f8a351ea622abcc37a26546520d12e467c  release/kernels/divtail2.by_instr.json.gz
5547377eef3af612f1e5f26f791929ecc91ed6f2ce8c9444635e0303f89ae2da  release/kernels/divtail2.by_unit.json.gz
e27413844716e2c50ee7f69833576c60a6fb7bc226660dfe365677c387affdcd  release/kernels/divtail2.ccvtrace
455cbb6be770850b69bd5b3ba1be7a2a27eedd5814c2e68a0b53ce98999e71ac  release/kernels/divtail2.log
b2db6b05eb6cf4a0a7677e31d0c6c2952d5cab49d353f0bb1883fe0b2a20ed14  release/kernels/divtail2.oracle.jsonl
205d643e12c61b39eb664b41622cff364f5b77238a798c513ca5c97c2bf57e30  release/kernels/divtail2.sv-hosted.log
f634c829dd69a6dadc8d0f5ce33f337f02a188fa6039340fa75021cf7e855510  release/kernels/fence.by_instr.json
943b487960721af3e172c0668a208ebe644c41982a519f9c1ad5bca206fd2a94  release/kernels/fence.by_unit.json.gz
937d3193ab570b47d1b195b8243ed02ee198d22a5792ddebd2ade6682955a956  release/kernels/fence.ccvtrace
e6a3f2fb6ec5d8a6d3fd2e51dc88d561d5654beca1079c310bc31c50baeefc9c  release/kernels/fence.log
d1d40317f6cf5bfb430cda1f9c0ef676609e59cabe2a11623c42ffbeca93142b  release/kernels/fence.oracle.jsonl
dacdb2a438a6edf9ade3e97bbf87308963a5410303bcc3d8b241416ddf370d90  release/kernels/fence.sv-hosted.log
606bd522a8d1435ab6d201ba5868b8fd06e3b2200279cdc4c96c891dfa88ef01  release/kernels/gather.by_instr.json.gz
6b7b58eafa7c7699a54d3bf910a4077fe046cf27b44c20bb680cf7b857771ac7  release/kernels/gather.by_unit.json.gz
579bce9756a2a49ebd6423bf0c53491401251d7e21bde54947c3723f31ce67c5  release/kernels/gather.ccvtrace
5db99c84e45b0c4f67a4a937e9cf7487a2da1e3172fa76ca9945d9f29bd5d628  release/kernels/gather.log
0413e781d8d6ff578c64eb1f800b7931e66f676d5cdabb97b94a4033e6037662  release/kernels/gather.oracle.jsonl
99dd145d90dc9d9627c7ef0eb1093a45bf896c25334de553e7d1eef1c3f9240c  release/kernels/gather.sv-hosted.log
a8e2254077adfcc8b45e171bca42b2a45622617f307fa8413bec81ada3f6b3c1  release/kernels/hit.by_instr.json.gz
6af348c03580e4a5f643aaf9b28bafaeafeb405307d97fada65d9b37635d2237  release/kernels/hit.by_unit.json.gz
597cfadc23b94de41d89d5a56a23c9b9debbdf001a780374272eb2d5133e3691  release/kernels/hit.ccvtrace
9daed040f3e9532de0c428f4b76073e19c9212f4bca6375a595987dac4908bae  release/kernels/hit.log
7ba9603e0088d9164de6528f16ef6a7fa9ce5821c8c12b52cbb3734e39b9fd52  release/kernels/hit.oracle.jsonl
0712c64df3446491da9d3aabc384bda2f861e1e4f46aa2697b8cab9e387f1318  release/kernels/hit.sv-hosted.log
d10c65138659ba674c48eef614e8e609170a71c8c81fe33513351e162a08ff90  release/kernels/lanectx.by_instr.json.gz
5928a649ae684b519c56d4b1d4d945f4f7d525d6769a99528c40654ab432b481  release/kernels/lanectx.by_unit.json.gz
bfdf212b12cc609da0b786f23ac7a775a880d9c7078d0dc1cb4ea29899191bf0  release/kernels/lanectx.ccvtrace
63907d9716f545d7b7bc0388c2f570abb6a2b5983562fe99254f8382fb376d87  release/kernels/lanectx.log
888551babf540db8e3025b82e65ca655013f93eba3c8a65689d069d52a7e6039  release/kernels/lanectx.oracle.jsonl
6249b3c241be1b15fa78f721948c12a424f9bd2333048ea9e7eb440bbe8f1808  release/kernels/lanectx.sv-hosted.log
7522265ad3ec318d659754c060ed8621d1c0509e97d15837f1762672f42bcdaf  release/kernels/lanectx2.by_instr.json.gz
9153eed886072a53933a96f706ce10ae9d73cc7d93023761fae62062ddfb77ab  release/kernels/lanectx2.by_unit.json.gz
d1c46c94b6b1d1fb2f239a45a58cc2a129820423a056374ffd66eda0640423d9  release/kernels/lanectx2.ccvtrace
2a50d44c3399be12b6677359d626a6601348f5b9863e5e102dcbf73a174016d2  release/kernels/lanectx2.log
45c13056dff5c73ed0c9ece56cc36f929bf335322193c7d5eb38710b1d1dfb02  release/kernels/lanectx2.oracle.jsonl
29a9446c7f7e2022d3d29518af89b1df87031c5893368b43f962771863e3c148  release/kernels/lanectx2.sv-hosted.log
f4d4aa7297172caf2cceb0873ec735ecc462f39fe626f8da552ab2432b92293b  release/kernels/late.by_instr.json.gz
586c0cfea54adac256a3ec105ecdbc5c99663080d454a726c8e1215f9bfa10b6  release/kernels/late.by_unit.json.gz
93f58dfd71bcce521d94f02a4d2a6383df7923f6b52ef8f9af0c7695ecba0175  release/kernels/late.ccvtrace
1daa79ecbe1d5934f858a0b0addda2778ebcdd6e334221ca64fd59d83411c829  release/kernels/late.log
86084f6bd747a2cf32acbc0ebd96ebd3e4ef2d8d9e21be49e3ae49290d7927f3  release/kernels/late.oracle.jsonl
1fabc8f64d548dce936ab2b22dd6a14ce7af34dfd8833d76887f6484200ad44f  release/kernels/late.sv-hosted.log
86c4e99779d2fd7781fbcc88edfacdf45257b708d7711dabf8d14335daebf458  release/kernels/ldpar.by_instr.json.gz
ae862db1ee46f1a241c6d2398fdba475cd2923c7beac77db6cb90462452b5b07  release/kernels/ldpar.by_unit.json.gz
722b3b0bd4f84b30172e365d6b94c20ae6f9a6dc51fe16af1db2c1ccdedc66d1  release/kernels/ldpar.ccvtrace
29466161123b95f5461b944da79406e70878159431f7abd46955d976e3f9cc00  release/kernels/ldpar.log
8ac08538e9c807637babd61b31e340f7461878ada31f0c0b83cd66331cfaf486  release/kernels/ldpar.oracle.jsonl
33e08a0b2e6c530d4108fec8c3553867a7463daa53cd870dd8c51b981c0b7939  release/kernels/ldpar.sv-hosted.log
bc50bbcf5ae2b926c031b6ec7e1ceb0bfe51e85b1b53f2552c10459e73bf3c4d  release/kernels/lnorm1.by_instr.json.gz
7b52164280c884c53cce1047547d2cedc325d65e85d50c35288be173abed99d2  release/kernels/lnorm1.by_unit.json.gz
bd93a528f262358a0d5085c0fb6ee324fe4df97ebdc0f35f512adc9840c947c8  release/kernels/lnorm1.ccvtrace
d41cf17b3d5dd0cfefabe566f2b6c87ef2f98a6f1fbe64ad94538640dbac3423  release/kernels/lnorm1.log
a8d85811af988a1b9fc00db1517300af3d93ec8e589e403d3b9113fa9e0ffc86  release/kernels/lnorm1.oracle.jsonl
9d56fcf9d952cf76e29da06df40259b1f53b265af53445c5293eac7d4d9478dc  release/kernels/lnorm1.sv-hosted.log
5e30fb9fe52be171670d322fd9452250d4ee50d5b334f21e28e76cc35eb764ab  release/kernels/localsp.by_instr.json.gz
1f5f4b8e9d7e3b8cf6b0a6482184b5c6dad620c214634f0860e01d3206a49ed9  release/kernels/localsp.by_unit.json.gz
059709bbb46930f59c1fe5b8c2ebefc8ffbfd68ee95254593ed3b7c5f506085a  release/kernels/localsp.ccvtrace
511df7a1f716999dd53275b5cc745b3cbb87aa97a25d2ef0d3d57a2f10c478e5  release/kernels/localsp.log
55e3c9f36e7f7d38c0ddd38903aff4bb4509ae862015c592e6b937ea258042ca  release/kernels/localsp.oracle.jsonl
62389f44ce213e60359ec5d4a7a028e6438853da9b11def77c3f7fb52029cfc5  release/kernels/localsp.sv-hosted.log
dd618e61f5c20b487a0a335e7929b48d3b2bd710ad4494251a87f83711a8f01e  release/kernels/loop.by_instr.json.gz
1cc352380176ef8452f03d5e6ee29daefe43be5a2221a9bdbfe73253c3c51844  release/kernels/loop.by_unit.json.gz
05599f989c0d60da6bbedde81701aa56ae1c2a56bbb878bbddeca9829b14e167  release/kernels/loop.ccvtrace
38cd3396460d72c10df25bd0ce36f34878949d68a99291e4abd3ef577e4573a6  release/kernels/loop.log
03ce5920c06c93e93516d8e53c3f7169f14e3593de204eacceffc0b8a3e32016  release/kernels/loop.oracle.jsonl
00a8941120eb0d4fcae1015171bad92d8cca4dd068ee18d8e779fedb5aac1040  release/kernels/loop.sv-hosted.log
9c7d4173a91e0b2ad3a9ed13c7602256dde21786fc873c07d6840a499b0e428f  release/kernels/merge.by_instr.json.gz
25aa821693a7b12bf58d0152ef27cb927044ec9c35e815485c9daee0da4c12ab  release/kernels/merge.by_unit.json.gz
2f43408ff2d9fff8512adaa9e24aae50158636b35dd1778e07d3a003df283170  release/kernels/merge.ccvtrace
0642768dff1f7f8a9f371cdf7b183509b780fdfc50ca2791a0d3450ea9f4c845  release/kernels/merge.log
f96d28815f8756b1f5a45ded53e6170883d2dfa10f9eef0d14b8050b1318164a  release/kernels/merge.oracle.jsonl
aac5e41126c7accea5f7870cd63f98c33d8440f9308afdc1f75897add7f9209b  release/kernels/merge.sv-hosted.log
ccc28a22885f97ba307285c91f2fea455d240d72cf48515e2a5056cdd6226337  release/kernels/missrun.by_instr.json.gz
6bba3275b1ac0ec976bbab0844b332f1c9a89244b28506702ea2c126baeb428d  release/kernels/missrun.by_unit.json.gz
db24d680f2714f6ba755b577007c566da5cbb6d8199ef80f7238cfd6455173ff  release/kernels/missrun.ccvtrace
78a26b3f437e1fe3afb5256b2ab0d42c955f1901462b5fbead062cb4805be804  release/kernels/missrun.log
531bdaf281e5590774bd2775427f25e4cc0419cf8e3d5b6999843ffe9ef87258  release/kernels/missrun.oracle.jsonl
bc1587c766a880e912205ac4522e7abf6011c6518063368ffc63efc5d8b229f9  release/kernels/missrun.sv-hosted.log
6f8140494a04200ef8edf801e838d44a381da8b06baf0f2f3e729c19ff4a6724  release/kernels/mload.by_instr.json.gz
4a1032705b5deb6f81948975d4e90a6758600438de8a038a15a576c70a9a275f  release/kernels/mload.by_unit.json.gz
79882da1a5000197ea1770e602c7728cf915639724cfbaf1361823897ffa2e5e  release/kernels/mload.ccvtrace
9fc3bc7b25ca9569da146872a305deed1c0f2a637d7fec6129586e5bdb852452  release/kernels/mload.log
8000e477b9a95dfb9f0af964e8346acb9d36f1358fd06ffc4ff7cf599d2b8868  release/kernels/mload.oracle.jsonl
b13c96fd23bb053a7925c1aff112d3703920d2e6fb814ef60015a51977934630  release/kernels/mload.sv-hosted.log
52ad6637dfee4929555ffc0372dcaacc8fd030633d2049f3a9a7ecde57911773  release/kernels/mlp.by_instr.json.gz
d0c4e1db2bb0d57dded4860fabd19ef9f57404e0943e5dec646efd845c94b361  release/kernels/mlp.by_unit.json.gz
44a6c1be3992aaf05a52c9c4573292650df8adef89278215be94866ccdf399c4  release/kernels/mlp.ccvtrace
91b4ef9fbec8234236cda533f0c69d6ecdf958bf0071132766743179cb18ea39  release/kernels/mlp.log
138d282f88d56c8ad648a91af0a983254b55d9fa22942c00d47b327f516a6e44  release/kernels/mlp.oracle.jsonl
c97eca1d4137287366d3f2167851e6fb0b4d665166a7e8df6e07f8702d50a32c  release/kernels/mlp.sv-hosted.log
66b045b4f9545cb906e7e82ef481361983e44c3b4b5fc5879a2018d60344dc5a  release/kernels/mwmiss.by_instr.json.gz
0090f675f35791a22362c33c3c62333d2a823e242bb1a10eb488bda119e3adea  release/kernels/mwmiss.by_unit.json.gz
3c7c5c446414a8097fa212b31a8698d8c53100b6fea56b002ef7dbb232cb472d  release/kernels/mwmiss.ccvtrace
451ede22ff06e711081337a9fcc8059c0878535b8e4c6c3094d907be51350b55  release/kernels/mwmiss.log
8abe8e8997456a2a6711ee72da54d854b24e20abbdab28e4b7271c0d28418de8  release/kernels/mwmiss.oracle.jsonl
011b8db8b7da89534446e2c0c54292e47664531d5c2866b32e485c89368af989  release/kernels/mwmiss.sv-hosted.log
6c0cb7e874fa49f66e116c128a7eba4ff21c5fa86383aa026fc235915fc7b91e  release/kernels/narrowadd.by_instr.json.gz
79bb921a20f7d2d2454c26898ab3b27a508d31f6872826511c215e4bbfb3328b  release/kernels/narrowadd.by_unit.json.gz
a589458c6355b0e9bbd7589bcae11dc10a6d1cac5cd0f0dda330a6d9a3dc58cd  release/kernels/narrowadd.ccvtrace
d72f59a088484011a60c4677ee6ec06af471de4c8061257966cd62d865a121b8  release/kernels/narrowadd.log
40a2cf629853dd404bb06b4a07e35abde3d12efc13f26ffe28f923daf2994574  release/kernels/narrowadd.oracle.jsonl
18f961e76f54eb93ca1702d05bb3fe05ce83f38c60fca09ed8efa16128629036  release/kernels/narrowadd.sv-hosted.log
31d6847ea0f433cc9226834e45c7108b599688087b8a4593bec2a30245e89cc1  release/kernels/pguard.by_instr.json.gz
c770c9e3712528c1cc2b36f07c389a278e2af65be10928c58449616bba403e5c  release/kernels/pguard.by_unit.json.gz
7ea87af30b8cfa9e54b7754dd440ef60896a0330a3e1f42f3983de79cf02bd5d  release/kernels/pguard.ccvtrace
36a8e73893e37a93d594b8ae73b09da3357a747637dd3819fbea26dea18d5caa  release/kernels/pguard.log
690e56f1cb8d97cbf67124b7dff3ad0a90cb8981814cd1709cf0cd0e035b3bd9  release/kernels/pguard.oracle.jsonl
db0831b9a717e9d10995c6caeb5514933fc7e697c92a05ca4d344278ff29b9c7  release/kernels/pguard.sv-hosted.log
d99104953b6e8e08e86e6f6003666aabf3b6292d418ff17b5533e38ad3685035  release/kernels/plog.by_instr.json.gz
cee531c9fb66e82e9077645bf8ac29c0abe76f1d3d5de9e98112879a3528b339  release/kernels/plog.by_unit.json.gz
ce4aec9a797ce6e24a9082c3c4e22e4cc45d2bd6d9cf47ffadb3e8da5e251eb9  release/kernels/plog.ccvtrace
fdac345ea363af737ad946144b80db833fd50ec242049ceeb8418057a57ffad6  release/kernels/plog.log
0c99915e2da60f4670da00504a6371d7d17701d4431e733a3ff8fa98a2030d6a  release/kernels/plog.oracle.jsonl
8dbb491bf30441c3b03b57a64d8b08b891127dc733268944c4a681a74e421114  release/kernels/plog.sv-hosted.log
100df8b157f825cb8e73593f1e5535e1e3b4622aefcc6cd2bd8c589fda64a6ff  release/kernels/pmovdiv.by_instr.json.gz
a877b2b595d94c7c096ff32839205c8e8e5312ab4f83899e383eabe7dd71ddd6  release/kernels/pmovdiv.by_unit.json.gz
4fe481c67584f36b72d1f510fbace5f75fa34ca8d76713e16d393f8638f099f9  release/kernels/pmovdiv.ccvtrace
6a390bd9d495b5f2a68f393b5a0e1799379092a482f2900a3202335373391038  release/kernels/pmovdiv.log
7bc646cff6166a51bdce03d7c1b7209e871f0a91d743083a9b910a80bcd0b33f  release/kernels/pmovdiv.oracle.jsonl
61f0a59812e6aab56891bd82068c880a382799f119860e50f9076743f8a3cb5a  release/kernels/pmovdiv.sv-hosted.log
0117bfafe2513495cd8d0a8cd0951ec8d7306a6b887183b93c8ad5f4e1627a30  release/kernels/predlane.by_instr.json.gz
72a881d1d09e9b9d5da146e951175dd35ae04ce39cf8cbc3529a6ff30f4f52a4  release/kernels/predlane.by_unit.json.gz
43ffb5fd93c492e608093ee380fd91f02047a73d0d5bca90f37879a3a9b027e6  release/kernels/predlane.ccvtrace
479e3a3c99ea93e23bfe746c9f8dcd8e967aa4a4902d2fc4603d0fc5617f5de0  release/kernels/predlane.log
c45f4177b9e84fc8a6e36b13534a0c7636eb30a3f8531847100ce5e23bf404b1  release/kernels/predlane.oracle.jsonl
2e5271f6d2f0a339f349378b6a724b386926a35d9c6b18a0cfc5f7645b56b5c1  release/kernels/predlane.sv-hosted.log
95720eaece37680df6468964dc64680e3f7a31fa4090c870c56deea9f165f0f6  release/kernels/predmerge.by_instr.json.gz
8743beb876c0be09a77e0fd34bd5a9b33cff194e298aef545c04833b8a396265  release/kernels/predmerge.by_unit.json.gz
d773aa91af7cfa2400e67801a569c10b730b800848cf39adce1a17e4661f83d2  release/kernels/predmerge.ccvtrace
0519f238adaf3a6e08771d0e2a16b56ad9c6c879708d8498869806605d09e994  release/kernels/predmerge.log
6c737c49434bcd08e3e0814c8b1dbf15c586ae74f7929ba3148ddcee2c62c845  release/kernels/predmerge.oracle.jsonl
6748577fd2defcbd9bff298e45faf2a0111de95bfc22a0d77b15fd4fcb792fa4  release/kernels/predmerge.sv-hosted.log
dea7d94c2278b5fcf5c9fb38604cc5c152f9886c2bd48e143cc5918e1b60169a  release/kernels/predspill.by_instr.json.gz
1160dbb8f4100d5b3b4c4e8eba265ef20c2fab193a7efccb990bf9156ecd0181  release/kernels/predspill.by_unit.json.gz
ef5cd45c3aca2c80a0f934209300878095623cf9fdccac71b72455d598a5cc83  release/kernels/predspill.ccvtrace
b74453365f9626a9409e6d640e53ab7e82192753459b98c362b79e73c7c443a4  release/kernels/predspill.log
b7c84c6478117ffa0f06da0e6ad1e4628e2683426a7911080810e78e06a5242e  release/kernels/predspill.oracle.jsonl
5416e7b848dc36d87b78359fbd18433443b5d592a88d71c152994bc0b836658d  release/kernels/predspill.sv-hosted.log
42ff2ae24dd8beba7fb931e730eef5e380539de065b1f7dce44b2e8cfe4cc76e  release/kernels/predswap.by_instr.json.gz
c038412a2133285013bccdbf59933a3897df93fb0b4befe7047934d6ebd9f305  release/kernels/predswap.by_unit.json.gz
6dde3956ce0082953ad263d923ba60c127a1dbf50b2927cd690a854dd840bac6  release/kernels/predswap.ccvtrace
69ed6f207b3cad4ac61f32b06735e6878b4f50c1802b141d303d23f863f31011  release/kernels/predswap.log
a6d4f7ed517553816d889c7c9eeb6bcfd1f6c973fbf682ecb69f3c2de619f7bb  release/kernels/predswap.oracle.jsonl
69f12e4999923709459641e1bc7a9833456a01d53b8cf3344e3c092520f6847a  release/kernels/predswap.sv-hosted.log
699027e0a466ff84a86348a5005955ef9af52774d1f467b50602169151214138  release/kernels/privwin.by_instr.json.gz
c88ab2ee17440853ce2b8a856c420176a445face41b347e6c8de4743f6be28a4  release/kernels/privwin.by_unit.json.gz
d53c8162338be0b94ef51f673abfc0f89554e08e8932971eff0d29056ca8812d  release/kernels/privwin.ccvtrace
7079891685b3eecf6e7d505c709120bf9a469665823581448d93ca8d86be2ff3  release/kernels/privwin.log
861f686fc4480363472908d679d8815e8c957d768e7ab32c826930527b0fb7a8  release/kernels/privwin.oracle.jsonl
4c8ee53438a11e0ac199e38645ecea7ef6889619f853373c379c15726a1c0424  release/kernels/privwin.sv-hosted.log
d573798e6c8ed22c712c6bb8e1698bf6dd3131ab00de1465bc060d91db447aa7  release/kernels/provswap.by_instr.json.gz
a40ed4eda988486a57561a214c584d749bb03c97541188506863786d57e360b9  release/kernels/provswap.by_unit.json.gz
52011821a7e778f898c918823c2e49261fea50a7278468ff0e93ab6514c207f1  release/kernels/provswap.ccvtrace
c38536ad24c43db7a89cc7345baff7e6b97972a9b5152f0120a06bfa0b2fec77  release/kernels/provswap.log
c9c32a793d54cc7401477f582487f7e8b345b2669a75337b8d6327120d98e5dc  release/kernels/provswap.oracle.jsonl
d28bd9461b194e3d9d32ce3d62702d47d2db5780db63e70dbb5e56411afc6f4b  release/kernels/provswap.sv-hosted.log
0e3fac31705db29cfeaa3b73ca079a1819547e2389f636b7732e6d39935e337e  release/kernels/retmiss.by_instr.json.gz
18a005ebe05dfcc180032945b46ea0db7485f72ac99be3a156b7cb4d07414495  release/kernels/retmiss.by_unit.json.gz
e01787edcae3313ceb75059412210168f0598207c4ff3b7135fd33247080941c  release/kernels/retmiss.ccvtrace
16cf0e54f6bbc6d5341141943710efe6adc74b24d9d7a8518a979e96c59dd574  release/kernels/retmiss.log
e5ef8538e838c6cff7febfc679dd091cf5e002f82d34f1009b1948ce22bc3649  release/kernels/retmiss.oracle.jsonl
eadd80ee41bcf2f50745c6a4d0e522aaa22ce79a67fc1fa48b612c3cf4f96326  release/kernels/retmiss.sv-hosted.log
d45b064f90b496adbbbf3be694a8cc4f6af4ea41825c8bb83b0c4042da5a369a  release/kernels/roconst.by_instr.json
b38b6900712bfd3ada68a6b3627c4ea3fe521aef042fc47dd43dfb23bb1283cf  release/kernels/roconst.by_unit.json
f3713f83ec2f195b035033bdb47cfd76ef95bbcac2a975d18c8e17e3b3ccda49  release/kernels/roconst.ccvtrace
3a8dbca0fe64dc3e35a8d8b8ab3c8131a6e1fb9fe115ce6f593786597c144408  release/kernels/roconst.log
8087c0671de620162881aecd38cd6114b78e7be6bd71201e3ec02c9a2e2e750e  release/kernels/roconst.oracle.jsonl
e68e7cd2150bd054983297ec483bfdf74ca99b44026075e1e7b97f5edc95ce44  release/kernels/roconst.sv-hosted.log
7d213047dc11229803ff907bc5a2192cad3a16f993fe7f5ae66bdd5e6ec74442  release/kernels/rogated.by_instr.json
780f573361718d589d4d8f9b1dde00733c8c8b549760f6108d514ef74514a8c4  release/kernels/rogated.by_unit.json.gz
e0022bd67a6d629144891b56607860fafa98ac1de5fa80dc411be11a44c9a890  release/kernels/rogated.ccvtrace
6ff2c0de9a74cc2c88ce562712e3c17e249f4b9bbdf2ff359bf78e9da4fcda33  release/kernels/rogated.log
7cd02bd4cceec5a044d6b4d6a80df1e68ed0ae71b0b2a953143636d5b809ea6c  release/kernels/rogated.oracle.jsonl
7a8b27cd83946016ef85dc390c14c8e1dafe4bf90aee94abfdcdf3a461b4f6ee  release/kernels/rogated.sv-hosted.log
971ccbd18eb6ab2eeeeda4cf42d61a7bafe001e080fc0721a63e4ff2e4fe8a77  release/kernels/rokill.by_instr.json.gz
fbc8b2df4e6fb779738f81d0a0d20c4c87b5d96bf089a5bffb03a1de48fe0c4f  release/kernels/rokill.by_unit.json.gz
cb434c89178bda63feb85c508e8cbd1b00bffd6b69525ab858d2b11b6cf16c17  release/kernels/rokill.ccvtrace
ea61cbe4274fdafe115b14e163dd1b38a709532704e4afc20a8bfd30b4f41add  release/kernels/rokill.log
94efcef96af469a512d346ce61623980fe86383188eaebd55120f716db596f14  release/kernels/rokill.oracle.jsonl
c8761f1cd0ce2e3baba2e0d5b614f489761cf2bba19c56962543b9371e2a6e0e  release/kernels/rokill.sv-hosted.log
ca75e383728cd7b2b8a11157bf8d8265449374b42b0cd4197e100c6a4e465e46  release/kernels/rokilllane.by_instr.json.gz
8d156ef7ebd80d42d30b1730f87a4ee255ad6782ad22dcdd5740d09e9c325d8c  release/kernels/rokilllane.by_unit.json.gz
dba628a43540510e90493dcf402203d99b3542ad6dd5a94033f0f5f1309c0d42  release/kernels/rokilllane.ccvtrace
b3c1c89ea1e6f2d421cffa5d9cf6096947f962c930ba06a48245483fac507ef8  release/kernels/rokilllane.log
f5ca6e666eff2f44894df74a291b43b3c0e7be0a63a47d795fdefd7b22016f45  release/kernels/rokilllane.oracle.jsonl
4da38dbc109f9115d1aaf007344ac412ea0955c87d0a76ac729a1cbcda804cf7  release/kernels/rokilllane.sv-hosted.log
f8fe604241644b224e6431d16e4fad889c99826b82f49205e4c9014b9ae62e8a  release/kernels/rolaunch.by_instr.json
12e5281971b0a06ca95d953aa22a6d6b481d8fee948f50ab777c87877757fe46  release/kernels/rolaunch.by_unit.json
32fbf77dc8fb17f0113b068b5a00568b6ea97be3ad8e5bd1c69b7cae2f04a946  release/kernels/rolaunch.ccvtrace
17eae3d99453e99b558374444cbf9f8f6c2600910a4f13fd722a13caf49fc391  release/kernels/rolaunch.log
e7dad585c3e70615de04330fd03f4f282c29a005dc1732a35655fb261d51139e  release/kernels/rolaunch.oracle.jsonl
9431e65383e4ccedd6cd37e7db86c34d4116a9210d64e7c281abccf4a317f7d8  release/kernels/rolaunch.sv-hosted.log
d45b064f90b496adbbbf3be694a8cc4f6af4ea41825c8bb83b0c4042da5a369a  release/kernels/rolimit.by_instr.json
e8822066a61bf10f59647aa7240a3044f25d2eba55ac5f7ebacbf1901974dd8f  release/kernels/rolimit.by_unit.json
0e8db555321feaf0fded659de3d7ab35b3dadb15ccef4bf8dabfaec2e87a5563  release/kernels/rolimit.ccvtrace
690b62f8e82f8a12b84214d2020eb8c2d16af9b6a6199944cc903b1f214f389e  release/kernels/rolimit.log
1c5bc0cb8e8b2e69505fb5a551a16d5d10c56f232b88da7a27e336ad7d962de2  release/kernels/rolimit.oracle.jsonl
7dcc7b87ef952ea0a9dbafaa984a293be27b3fe4f576a04f35ef3374e441dbe4  release/kernels/rolimit.sv-hosted.log
9a20de411ddc45cccdb6bd3eb960e61027ad09ca4b3dce88112af9d8609abaa6  release/kernels/roload.by_instr.json.gz
a6e9b8149356376a7eaec5044ed6093e3e062a6eeabf15a2b12d5b29a0850d82  release/kernels/roload.by_unit.json.gz
aeaec16ad191a7398d05779dae10b703ade002cfd0dc122e276602930405a40a  release/kernels/roload.ccvtrace
22ff90c31abf892048dae7d01af2653e0bba3d91f7eefdae5b1f00a17407a031  release/kernels/roload.log
f7c1309cc9764769fb5803f6fd0f2f5e1eb418f2d23fbe5e17cf5f9106869fdf  release/kernels/roload.oracle.jsonl
a568a7b637a9c610dbebd7b5e5817d1a71c39a906914f3cbe79c6383e503117b  release/kernels/roload.sv-hosted.log
c46716329fdbcaaf7cb4ce5ec72fe20fead5d8730d2032417503fb78a54c16d9  release/kernels/rope.by_instr.json.gz
dac88f9c06b1ea0aeb91cdf1a18e3013c35a07ff150643bc5837261c8b6737f2  release/kernels/rope.by_unit.json.gz
01c05d72273a423f5463206a601cdb64c719d7094a97707467ef837b8c036602  release/kernels/rope.ccvtrace
5fdfba263e0b0cd2661b4ae962093d02b5a1c5ac10eeba1f8329407b3eed25fd  release/kernels/rope.log
d55f9efae392dc8877c102c01c0810e7654b666b6ede386328108164c6cf88f3  release/kernels/rope.oracle.jsonl
b4ce4be5bcf059d5df64b53338f87d1a9ce7fd9f9e9da408466e38b0bfebbf2a  release/kernels/rope.sv-hosted.log
54716fa9e96353ea4cdedbf00c4cdf1b02c6a2c3b0afad6a0a32e4c05b9daff1  release/kernels/ropediv.by_instr.json.gz
a3bf6d2cf62c688df4fba00d7e7af0ce42e0c07b1893df52b08ea08c988b1da1  release/kernels/ropediv.by_unit.json.gz
314a1adcf5bf9b94fa9b376e8492417842a1d2b334018cc1014c4df80ab63dfa  release/kernels/ropediv.ccvtrace
ac6a27099a06caf9ade548138b723475305ddbda0a8e9e3663a477ef4638d710  release/kernels/ropediv.log
10c0ec6ec18b7b44638c790033109198c079d07c1537bf193353ccedd00a920f  release/kernels/ropediv.oracle.jsonl
5816d78da165d30e779c7750822408536935a90e1b8c1720fa6c453c4af5427e  release/kernels/ropediv.sv-hosted.log
65e9f5b22bc7cc66907b919632e49caf9d95ed896339c8e1e928858f27cac226  release/kernels/sel.by_instr.json.gz
e7f629fa5ed01d44b3b7e88acf6582e5d20013f6e59b6671cd582143369edfc3  release/kernels/sel.by_unit.json.gz
33a33114b5167306fc24ee447399ba293a8568ed59ddc2c9e307b97a3df3638f  release/kernels/sel.ccvtrace
c9c85eb35ca8618e716376041ac183a741bb46124ed4a49d06637dca9342f8e2  release/kernels/sel.log
87f6a81e8afa004c8039bf2f61c90176fcf29ab29bb17ac44aa016a5cc8438fe  release/kernels/sel.oracle.jsonl
b71edcadf1678406560558022638bef02620c2a2bd0c978ddc2eedbf15ae604f  release/kernels/sel.sv-hosted.log
15e03d333c30ee8e4dd617094b9ffc86bd32a45d573183fd15bf8bd4b0dd3ae1  release/kernels/sized.by_instr.json.gz
30f156193a0fd911bd108d8508f0408aeb57723287ae938cd65438c0ae94989c  release/kernels/sized.by_unit.json.gz
96ab17d9315d0926a3fe12caabaecf335da5f274469ba35da2137ab19e16294a  release/kernels/sized.ccvtrace
6613b159f2e23e93daffb07ae923b058eb801746717995dfdc3d7ee04b6fcbb5  release/kernels/sized.log
36d903ba1618bd1faa437c9812a6ee6c0c966a63196c796267d74bf2695ebc3d  release/kernels/sized.oracle.jsonl
1f5ff9586530a92851c20dbf769ca5266412cb8b914306c9f4815fa0e25299ad  release/kernels/sized.sv-hosted.log
bc9a6b58963554302b53d58aec92891c1ca1f5cfeebbc3738a7359478a13e84b  release/kernels/slotform.by_instr.json.gz
c7ba0e00c1ab1786d41990f8f7e6b96f58946a7f60c423a9274b9f16a3162b9e  release/kernels/slotform.by_unit.json.gz
4b489164ed494bde355d915acfca6d1c7e362baf785a511c2f9c5aa2e36d0471  release/kernels/slotform.ccvtrace
33d4c85159771243e8012d4d2802694643345bb26c9a994aa1bfc75059c5fd80  release/kernels/slotform.log
8b61db7419b18cea8a646fb628218447e72e84a18a9891ffb73b441736138ab9  release/kernels/slotform.oracle.jsonl
f9f95701c8e7a38d683d933ed08e4b84590a526281307b4e6625e96c2611218a  release/kernels/slotform.sv-hosted.log
7e1d44d935a6c7f74eab11cb79e8ac6256d89fe3e5b9c6ca6a222e3a5b57d3ae  release/kernels/spinwait.by_instr.json.gz
665ef44b3df218fb3cf27d2e693dcfa193b3fed88d51b6e898ce4850c134f095  release/kernels/spinwait.by_unit.json.gz
1542b9b1af9bbcf090c10f31e2ac5a965ab4fd4812810c7ed152387a80e3f9cb  release/kernels/spinwait.ccvtrace
285d630ce34fabd0d8bd1a796c7043da45033ceb5018ad55b459e80ebcfdff51  release/kernels/spinwait.log
868920637236c878b33779bd450439466fc3626996a3164573dc11d437d5c709  release/kernels/spinwait.oracle.jsonl
1dec56544d066f8b61c03eee596f7daff5ae93f907f5303bc0669477367e9b22  release/kernels/spinwait.sv-hosted.log
751c7b8e6092afc3d4be2ed736e714314940c107c24c11db295c41d62028f3bf  release/kernels/spmbank.by_instr.json.gz
17d2b624677b8eadae381604a422746b6cb6f8d7a45dea046d1673306acc4ced  release/kernels/spmbank.by_unit.json.gz
c9e0541d73a86ace0be2c7140b58c219c67cdc59ea3c535408d630297cbaaec6  release/kernels/spmbank.ccvtrace
42557d5759bd562f8d661b42e41efe639f216a1607b0f52145012e5d8d61a576  release/kernels/spmbank.log
3af490cc37d7a92dbe719b57de216b648536eb301ff9d13de9a39f50d150d725  release/kernels/spmbank.oracle.jsonl
98fad1ee5383ba68becf1c13d4255cfacc1ed54fe81732706778e33c24203283  release/kernels/spmbank.sv-hosted.log
78a903b8f925e2e3e527c67f66367d9ad026376b2a3a48eeb092641063911296  release/kernels/srd.by_instr.json.gz
57be822e2cc974efb7232b168580a983049a63b77de5fdd824edc7c618bef4c4  release/kernels/srd.by_unit.json.gz
f255c02a28c53c4b57a6b17bccf73852f4dfb2d06486b63be7fd69e6f3ef22dd  release/kernels/srd.ccvtrace
5e92d83bb1bef4aaf765a4b87019bbfb93e7974c037864bf12c5ee1b2ca4a90c  release/kernels/srd.log
b08eb5e3673cac7eebb8b72af5ed3783c8e70a9e96592e76bf3722551bc79473  release/kernels/srd.oracle.jsonl
4556c3c6da63c6b0c58018f77893cd9bc2b3857e587beff48029a938ea575c6d  release/kernels/srd.sv-hosted.log
f98d64ac29c90466dcb8b4165db6388691df9859c2a6cebee5be5e43ce54d470  release/kernels/stall.by_instr.json.gz
80a1efbf1e92ecd559ffff0d71410dc4a007c9584885f80d7e13b57245773140  release/kernels/stall.by_unit.json.gz
7be7622c1b3bdf30f0362f3058694550ecf66c17ded838a604d1f10d3816874e  release/kernels/stall.ccvtrace
e226193e535a7ee5074c7cd156f6b983ce594d1fb689dfef3c2395b87e60c89d  release/kernels/stall.log
500db2c482b07a0706583422cd68878301d0146c1f872ccc1f11bfdcf5c993ef  release/kernels/stall.oracle.jsonl
a1cb5ba8481cb60e57137cb17a9aeb0c9dc6d85c114c0562fba6c7b4c4f78efa  release/kernels/stall.sv-hosted.log
d3bc6c607a93b3b861cf3343d35e6afe0784f7b95708c51a603f3f1c486e65a3  release/kernels/swap.by_instr.json.gz
463d2eaf476a0555a81213d9e8ece880a9d1cb865279c0bacc5d385e92a7793d  release/kernels/swap.by_unit.json.gz
03edb62824a690d4bf7f46bc9d4841c7612d9a08df8aaf6af5750971130cd3a2  release/kernels/swap.ccvtrace
94cbfab634a7e28151a3178a8c31d0e7011bde3634a665e7f6c0248b9fac4871  release/kernels/swap.log
3658a26316c1ff7bc1744304a42f736e930fcde2865c8913e6cc67a22ce96667  release/kernels/swap.oracle.jsonl
e6f6c3aa245c8465c271a55aea34341b14002743dd079e0292d6e9264dc10df7  release/kernels/swap.sv-hosted.log
e55ba8062a1c212ed75399bced2c812cfef418691dff35af0d0861b1bb8c1c88  release/kernels/transp4.by_instr.json.gz
905b584b6acb5ca72d2df8f8d7d1cf03cda2ed94d6505562159625025e2f2e51  release/kernels/transp4.by_unit.json.gz
42420d45bcd9f832fbda0212608f9f12d023ad5855373035414c976b969d7d47  release/kernels/transp4.ccvtrace
969ac423919f32b7c07f2649f164171dd9bc8e049af25e92a0952234af28e7f9  release/kernels/transp4.log
06396ace3ac19677fd39c700e408606e5bdbacb24997d663bbe8872e63dd74fc  release/kernels/transp4.oracle.jsonl
3810a573e36d21dd7061f2589a5e0863ae71fbbc33c70bd2134607223b3c01b9  release/kernels/transp4.sv-hosted.log
b2614cf7ff07e9d6b879fd990892b6a4746ca0760a6144e0ebf348b57f13ad9f  release/kernels/unal.by_instr.json.gz
3a32df610521573de8811b917c704415203189ef1815d630d591726243352c56  release/kernels/unal.by_unit.json.gz
f0cc8a6483da7e1547d81822745f9513824861f37c3e59f25922c8df4895b09b  release/kernels/unal.ccvtrace
73cef6003f06c7a06cbd8dff05d46e32447275d222a44b380e6553a28d48edef  release/kernels/unal.log
c3d484bb160657a563df983d9a2532eac27f556636617960aa1e72183ac2b299  release/kernels/unal.oracle.jsonl
76d875f7e987bd8d5b8d0a78a566e90a602607347f392b941cd09572ff1de55d  release/kernels/unal.sv-hosted.log
d9e6a23516992bf75fba3ae7eb4460e5c68482cae3d539a48940fdef5c73d3b4  release/kernels/vadd.by_instr.json.gz
f74d32b7ec49a5a4abb8215e312950757a9b171a11becdf8c8b991b1f0ddcce2  release/kernels/vadd.by_unit.json.gz
825febc1f9a8bc5b55bb674ac0be9eac9ba860f1958becaca4d396290e4eefb3  release/kernels/vadd.ccvtrace
ff777e4dbfa68b04069d091254550c7725243e226258bbc7e172ba2368e65ff2  release/kernels/vadd.log
0276b6d0611a4bbcdc004ab3987214aea138245bc7217504147331689a9c0880  release/kernels/vadd.oracle.jsonl
08b658e1af47a5b15a4c745d0e9ac1c3ad0095fe4d732c5314d402a3b3cb108a  release/kernels/vadd.sv-hosted.log
7630b12dcc7992a5eb3d71252e2bfcb22af40a012356e3e5506cd9e3e45471c0  release/kernels/vadd4.by_instr.json.gz
c677a4fa56361a7806775f7c822e2e3f39453a00037926601f7cd38ca49ecbcb  release/kernels/vadd4.by_unit.json.gz
9960fe139d35d9d668e0051597af8d273d43e895a52869c29d53b486d2556f84  release/kernels/vadd4.ccvtrace
98e3343895e84c51d61f86434920c2649e1bbb7ed5a42311fdb5698afd73803e  release/kernels/vadd4.log
225aa18fc9f38aa9ad615aa11de254337d59fa705877553d873062c68366e0db  release/kernels/vadd4.oracle.jsonl
853899d29e7d9c98eae2e07b4c2002766c1dd6507d6288361a6c9868ba92938b  release/kernels/vadd4.sv-hosted.log
92e3ae9f1316277980e58f10543577d208090d21e8ff5f074b5f54439f9ca056  release/kernels/vaddslow.by_instr.json.gz
8d840dc79d42338c9ee1178b5b6f401380a9f71d0dd853da8be3a168f9a8bb9f  release/kernels/vaddslow.by_unit.json.gz
d87344fe4eb495874c5458634e18751f8cf89c534e99fde16c9d9771b54ae8b2  release/kernels/vaddslow.ccvtrace
d633b387442348f4a78b6110c450afa6abfcba8427cc163b7e8ac91310f4bbb2  release/kernels/vaddslow.log
e9e6218e8b8450e9f9ff6b39d659c994a1e51c527a0c5bd10d18b5658ae0e344  release/kernels/vaddslow.oracle.jsonl
c8ac3c102fe9321b30df94c2aa9554e8565de45a494dca373e071c62c6ed459c  release/kernels/vaddslow.sv-hosted.log
5f1d3335727231638d248d5bb5c851a117ac282192f2e0a182f4393c92f3bb2e  release/verify.log
56b3d8627d79d397ca06dfb57060015391cb95e52e925d1f09a4b2a7f4147127  release/wiring.txt
```
