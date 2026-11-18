# Snapshot snapshot-2026-11-18-a10d4dc

**A generated, read-only snapshot. Do not edit or merge it.** The source
is `ccr-9eb50716-lecnjf` at `a10d4dc7558ff1ad6459ec069cfb422a76d75064`, and this branch is rebuilt from source by
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
| Source | `ccr-9eb50716-lecnjf` @ `a10d4dc7558ff1ad6459ec069cfb422a76d75064` |
| Built | 2026-11-18 (UTC) |
| Gate | `tools/verify.sh`: PASS |
| Compiler snapshot | custom-cuda-complier `release` @ `a293afe7d7873fb5d3fac70d8deca980e119b19f` (source `b9ae2c9d5d3b838d5d982d842b558e2d290185ea`) |
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
1bfb94dec31454f36a2bb21739f0864a294e345dae674cad6cc6a3a2b1ec19f0  release/kernels/addrhigh.by_instr.json.gz
6ad045375451afdc79f7fd5ac394daec02cbef3d673b78a79a51dd8960938bf6  release/kernels/addrhigh.by_unit.json.gz
7f4025bfdc4a9e67d17c349cc2031239027d3a614a0080c15e41212d388f6c80  release/kernels/addrhigh.ccvtrace
d188a13da323dee296f6ad49abd1a00b75ea59792469e9b1428c440acd27f4f1  release/kernels/addrhigh.log
569f2e22883fad5f0956c57ec734e6afbdd4b8a854e50277425172d6c0cbd766  release/kernels/addrhigh.oracle.jsonl
a0c3db0ab2be654052cd51329b2f7126137217da9cb5458da4da211804ff102d  release/kernels/addrhigh.sv-hosted.log
fdf05a21b8e2f633bf1762387759f685dffafe71b32f0dfe4b60ace1d1647053  release/kernels/addrlimit.by_instr.json
939d6b115a1bc45b8e75c394811a9aa84b1fb504faed4cc318d2f53cd6131e43  release/kernels/addrlimit.by_unit.json
f8287904c415dfd8f4cf0ec4a8dcdb95ef81669e365fea28a62d9f2feaa3ac8f  release/kernels/addrlimit.ccvtrace
2601caaea99b2bf4f608c2b9d2317603315571028937a17cc4314f545672835f  release/kernels/addrlimit.log
bc660b0b40359a2c5a2478cb0eb4950b73fd22db50ea76b80052bc195a1920f4  release/kernels/addrlimit.oracle.jsonl
9cc295ca5a584348aebe4a6db206138753ccac0421909c29a0420a2dc4388636  release/kernels/addrlimit.sv-hosted.log
444a139be8ad3ef2636383cc788bb28ec816e5e0284123df710c7a5c06003bd5  release/kernels/addrneg.by_instr.json
cc2e8d376cbfa7fcffe6246821ac1957c7be5b157b52ec7e5b037ac37f067408  release/kernels/addrneg.by_unit.json
aaae096aee3b8e71dc063bbf880dc9562e93bac3102ea7b4a1d249bda0baa1df  release/kernels/addrneg.ccvtrace
f0e7b84ca37f444b52f48fa7d6abf472a5ccff0f7de3decc4f3c40f2961af301  release/kernels/addrneg.log
16f5b0707ae44492a1efd67bb9dd38a7e79a7bbd354fa9207b9e7d150ff2f107  release/kernels/addrneg.oracle.jsonl
313c85c07011cc3ca10d3623ea256015d57ec1557e8a0303f1e9b2fca0d7e13b  release/kernels/addrneg.sv-hosted.log
d741fd0fca48a09c5296ae7c7c50bda479359c704d00e13f236b0899a5c511da  release/kernels/atom.by_instr.json.gz
bb5dc9e034cad29fa6db3e6c9c4d3ba51401c3b759cb3270df740268b469635c  release/kernels/atom.by_unit.json.gz
67214e5fefe2e38f320350b9f45b87cdb42d0e7d4a1a7f6072b7c57e90b8c6e2  release/kernels/atom.ccvtrace
65f76766807d3ddd308a0e8e9f05f51f6843f718a1d0818d8e3137052f06755c  release/kernels/atom.log
504f5b6e9d25114dc35f2c70b21bb7b3f3c508c691de12dc0e87d12a74285361  release/kernels/atom.oracle.jsonl
297cc05ce67042e8d5373d3a8aa23eacf839c021fe903519b6a3c43a3748b290  release/kernels/atom.sv-hosted.log
c9f86e77b28896e2b51f167662d10fd087a8d39b89825bc4315303df1270a7fb  release/kernels/atomf.by_instr.json.gz
50f7b7c57627edc37dece257deb735663b6ba8130483b6de8b101bf73ca93acc  release/kernels/atomf.by_unit.json.gz
098de58c0913a300162a361cc42b0f5101b06c5bd7a51f91ce63bb456800b6c2  release/kernels/atomf.ccvtrace
7ff6bc20d8fc8ad36a96b99fbeade475d42805b6c37beebeb334e422db7c183c  release/kernels/atomf.log
cfd1179edf4061a33ab2f75d7a6dec61decfe629000198189a7bfc2647b34238  release/kernels/atomf.oracle.jsonl
61aab558784f8a8bd3009dd8f30598aa6e400d503ea6e4a5dd7824627612a7e2  release/kernels/atomf.sv-hosted.log
22f9a1e02d0f5072d7658170297d9050b0b6c2e095a1aefcac384b00fc9c7dcf  release/kernels/borrow.by_instr.json.gz
63d6f87f83e62bd11fce2695b84f4cd6197120b42185ed4c65747721578cf25e  release/kernels/borrow.by_unit.json.gz
f47ba0ff76f39020aec6e50deb887c83af18cb9efde597aa3d2ebc7261eb3139  release/kernels/borrow.ccvtrace
c3d024f391d0e65117fcedb685bccadc5401855d7721ab046a343ab09a9d4bb1  release/kernels/borrow.log
4c565e1ce0b3baee36e158694b32c8defb5cd662b2f9af75cb5d8c26cb1168ed  release/kernels/borrow.oracle.jsonl
e887b937859c3f82120ced3a375d05f103aeacf0a27a49a5a641b3c8bd589106  release/kernels/borrow.sv-hosted.log
123a1d54e739598684df12df15e150f4dd0998b8324a2ba1a6624eb252d9c0a2  release/kernels/brs.by_instr.json.gz
2d4d6c2a684223fde488d4751d4680f222304c63d115cb4f32df801a9c1df428  release/kernels/brs.by_unit.json.gz
0efbd34762b9bb839d84507973259b9161e0b6b94498eb217ab8eb280dacf7b3  release/kernels/brs.ccvtrace
fde89de0803e0cd1d0ab0f335c4ab24e713bacd0314dcbb0795f27dbe07bbadc  release/kernels/brs.log
e3c1cb3379580cf1aae44e8ddc8e846ef6fd661a573cfe0a8d4444b18a14dc56  release/kernels/brs.oracle.jsonl
863a371df22147847a423e9ff9bb0312207714f2168f6cb5ebff272122670dfe  release/kernels/brs.sv-hosted.log
bd4f07520ff45cf5e67dde7ac8edd656b8da8e9c4eb373a4dc5524bf2ad15849  release/kernels/byp.by_instr.json.gz
3259c605034af16175e489cebe411f8fe258a0b3b11c94796f1adfb58963601e  release/kernels/byp.by_unit.json.gz
d981f1490d418679982388372cc80497485d972a295ae5f1d1a60d06b0c22c67  release/kernels/byp.ccvtrace
e24483d1f6045db4572b0878fe87b7301d5c3c3fbca3efb4d1d6f5ec82aff466  release/kernels/byp.log
5a03dfa4f3603fef49f1e3639e74e34152ca3ca5ef8e41eb959f8323040fa2d5  release/kernels/byp.oracle.jsonl
dc72ffc2b7665eb5c7ae9668f7cfcca3ea95a7ba9480b6f41138d8fe5e0d2091  release/kernels/byp.sv-hosted.log
7e6fb5baf077ecb402cc5746ca756894ed7a33fb75eeaeb4c6077f5fcaa588cf  release/kernels/callret.by_instr.json.gz
6d21eff836457de33ccce1f19222287546cc51cb51588220397953550ff94517  release/kernels/callret.by_unit.json.gz
485f5f7c964b7718cdf5f6475c30219443e9a079bfcab6718359dd789900a2c6  release/kernels/callret.ccvtrace
547fc1318d0d1c4f7a1ac5e325c26da0bc202c8a8ad51e2685b4d94b423bcb64  release/kernels/callret.log
9b1d1b50b527f732362f837250aa2f26dabf3e76e16a4794856ebd8f105635b8  release/kernels/callret.oracle.jsonl
89eef42423b1f451b0cfc66ecd9e53bdcf3fea0daa9189618539c70be7ba82de  release/kernels/callret.sv-hosted.log
6b8d85a2f6662a6dceca47272c16cdce98024e6e2b816fb4ca6d4be43fb4396d  release/kernels/cas.by_instr.json.gz
27ef5438e1c27adcedd387bf8b7b5d190ae676ba10a28a270f2eb81386f153a9  release/kernels/cas.by_unit.json.gz
df448ccfbf455fe5abd8ab9a4deac8d3b068ef26494c81dc0ebf78f22bc88684  release/kernels/cas.ccvtrace
bc653250c9c1c8826ab5d5cec08160f4dea35314b0c7d36cf76179cf6ac80358  release/kernels/cas.log
0ab31a9443336fe5d08e1a5fa5fcba3bc279b19022f7c5007908d39d8ef39536  release/kernels/cas.oracle.jsonl
013e30deb1520afc75b2139174ceb345aff28ddb977145d128c825874d67758d  release/kernels/cas.sv-hosted.log
8109c3cd420303021cf1905c39398f906a388110ffab85fb303df7b73cb3a278  release/kernels/chains.by_instr.json.gz
bfdb5b175b4788e84ac8223cf64aa0c781033977850eba8d81db64476bcd383c  release/kernels/chains.by_unit.json.gz
b47e10902de830c337bf591bfc2daf06098880741b67957d8e8dd9c45208dc56  release/kernels/chains.ccvtrace
8d3f3d205ff9d2f9ec4b1b9153332062b1ccc2e37048430fd6fb5465c8a6adb5  release/kernels/chains.log
26a4cc5c5524c7219d8706c2582c80357dea60be9d6ffdec99dac7d0365e2264  release/kernels/chains.oracle.jsonl
751cacaf63704ab0c1d5d32eea9b6a7da88fbb3cd3387652a83a24d92f83366b  release/kernels/chains.sv-hosted.log
0179a01914fab9f382d46278667eeab78485aeb0f63bf6bb5716cb2c73af29c9  release/kernels/coll.by_instr.json.gz
6bc87678e175dc50ed188616a9c7bd53c2563dfab4642c5193438db79a3f4d51  release/kernels/coll.by_unit.json.gz
9b2defbca3a81f102a07f1fb1a9473253e58da6ab1e7375a8d81f4d1fe098bae  release/kernels/coll.ccvtrace
9a42fccf43093b9a678988d3c33fd7bade69270a538c61adff15a02b4b801fd9  release/kernels/coll.log
dd718d23c88df5dc7d92b055d8542865aa0e029118486af127312a8a578cfcbc  release/kernels/coll.oracle.jsonl
b73063bab8a3629b23918c509d5edb97cd780d0869fb1ffb38d25deb27cd7104  release/kernels/coll.sv-hosted.log
b05f1cc62f7e113162a8fedee8d45fda54756f27c422d7f107596be9087d31f7  release/kernels/div.by_instr.json.gz
a81edde2feef49f413e55c3cfd88cf94c94de8b243166c91a261636dd54e4eaa  release/kernels/div.by_unit.json.gz
182346c5baad147767effbea67248ccbc6e5c35582f0590ab266ce10e6e9dbc8  release/kernels/div.ccvtrace
f96c31a039f22248349177f56cc28abde17125b635030abadd5726d01dbfadbb  release/kernels/div.log
71a567b85cf85622631490187563de9a5661099c78a590adff4ed0a0c3d24c16  release/kernels/div.oracle.jsonl
4df262000c7671b3489bd0e7ef81c4a87aa495c18409a513beee6b3ce3935f40  release/kernels/div.sv-hosted.log
65465ad95f33f8575205a5a4416545595f0e4a8a5aea1c8bdbf427cd338557d9  release/kernels/divchw.by_instr.json.gz
61f71f12148202255fc4f1668be53a4c6dade1b25a65140db875ea9cbcfb134f  release/kernels/divchw.by_unit.json.gz
4471a48e9f9555ec3ff526316b30290fb0ff75d28588185a2a52382020681eb5  release/kernels/divchw.ccvtrace
e686e48b43b1625bb3f158f5a9ade85a9cd789adaaa348d446f1fa4007d99b8f  release/kernels/divchw.log
58a541797f7a2df0a1c7528ae6a3edec212db90c7d3eb20656806f38b5c10b3d  release/kernels/divchw.oracle.jsonl
77b970b212e7f22cd2b0cea3b116fcb4b006cd1c0de06134a79631193bd76155  release/kernels/divchw.sv-hosted.log
fe96d0f57af9328a6a2c7725c0f74bd773e52b53bd11035109d8bdf90f6a3451  release/kernels/divtail.by_instr.json.gz
953abe719a73dc12d4844d808bb678400befe5f3274b809c81eef19ea0cbd838  release/kernels/divtail.by_unit.json.gz
2ade202d8c5fc071687f18239b0573f55461d1606452ff6daa16db3738442f2c  release/kernels/divtail.ccvtrace
4a032dbea80b2e7c78314abe431fc8544595ea430d15f98e405f2117d747de44  release/kernels/divtail.log
75f11a75c9b3b336e446140af4579f05b46c363a76b7aab3ec88154a07ba097d  release/kernels/divtail.oracle.jsonl
e1dcd6868e1d982fb875e9e1971026be8df8d9c1ee855f6beb53810afc80470b  release/kernels/divtail.sv-hosted.log
f9e2a40b9738c7b11e07d173acaa7283d76e359fdddc60743f9c412f69dafe5d  release/kernels/divtail2.by_instr.json.gz
9ba9812f95eaf81b1b1fd0df3b16a777585c972aec4111dad66a90372e8411d9  release/kernels/divtail2.by_unit.json.gz
e27413844716e2c50ee7f69833576c60a6fb7bc226660dfe365677c387affdcd  release/kernels/divtail2.ccvtrace
455cbb6be770850b69bd5b3ba1be7a2a27eedd5814c2e68a0b53ce98999e71ac  release/kernels/divtail2.log
b2db6b05eb6cf4a0a7677e31d0c6c2952d5cab49d353f0bb1883fe0b2a20ed14  release/kernels/divtail2.oracle.jsonl
60741488bec0d13f0fbff11d820c8db91eb6f48558bfd7886b64b657083489b5  release/kernels/divtail2.sv-hosted.log
f634c829dd69a6dadc8d0f5ce33f337f02a188fa6039340fa75021cf7e855510  release/kernels/fence.by_instr.json
0ec7e0fd883dcfc06efe58d185fcc59de022a3c71c261fcbeb93571d1f25e66d  release/kernels/fence.by_unit.json.gz
937d3193ab570b47d1b195b8243ed02ee198d22a5792ddebd2ade6682955a956  release/kernels/fence.ccvtrace
e6a3f2fb6ec5d8a6d3fd2e51dc88d561d5654beca1079c310bc31c50baeefc9c  release/kernels/fence.log
d1d40317f6cf5bfb430cda1f9c0ef676609e59cabe2a11623c42ffbeca93142b  release/kernels/fence.oracle.jsonl
21e3d6fe14ffba6269b443120b1404c94a1dd61c18f71573d2c455f158a40d03  release/kernels/fence.sv-hosted.log
43202bd7a68e692d8a443bf8fc803c76fd07fbfa421f6cdb5d7edfd60d31ee43  release/kernels/gather.by_instr.json.gz
f798a93c1d7b71759fc138a432bf29443bed2bf0c31ad50e68ade92f8aef7959  release/kernels/gather.by_unit.json.gz
579bce9756a2a49ebd6423bf0c53491401251d7e21bde54947c3723f31ce67c5  release/kernels/gather.ccvtrace
5db99c84e45b0c4f67a4a937e9cf7487a2da1e3172fa76ca9945d9f29bd5d628  release/kernels/gather.log
0413e781d8d6ff578c64eb1f800b7931e66f676d5cdabb97b94a4033e6037662  release/kernels/gather.oracle.jsonl
dffb4f4e83cc576c677c115513c59a57ec48c2eb52c78a4c5b59f0520b503c5d  release/kernels/gather.sv-hosted.log
5dc05a2bd0365faaa5dca598242b439e983be6280bba109aefd7d8d96c2bf83e  release/kernels/hit.by_instr.json.gz
751f798e9dc388fee57515eea9e1e808193d825970d1e99b2ccba5b82b0323a6  release/kernels/hit.by_unit.json.gz
597cfadc23b94de41d89d5a56a23c9b9debbdf001a780374272eb2d5133e3691  release/kernels/hit.ccvtrace
9daed040f3e9532de0c428f4b76073e19c9212f4bca6375a595987dac4908bae  release/kernels/hit.log
7ba9603e0088d9164de6528f16ef6a7fa9ce5821c8c12b52cbb3734e39b9fd52  release/kernels/hit.oracle.jsonl
f91c637976bc6edd4f8be8e745c27d18c4958d7d5c2ed9a51531ec4c9a0a8d9a  release/kernels/hit.sv-hosted.log
2b38edd80bf2adfdcdca445ae7d3491b6d013e5d75f53d057b20ba377cbceaf3  release/kernels/lanectx.by_instr.json.gz
aeb474bdc78cc102fa585a47c4bac7b3193241afc2751481c2dcdb0075e0f290  release/kernels/lanectx.by_unit.json.gz
bfdf212b12cc609da0b786f23ac7a775a880d9c7078d0dc1cb4ea29899191bf0  release/kernels/lanectx.ccvtrace
63907d9716f545d7b7bc0388c2f570abb6a2b5983562fe99254f8382fb376d87  release/kernels/lanectx.log
888551babf540db8e3025b82e65ca655013f93eba3c8a65689d069d52a7e6039  release/kernels/lanectx.oracle.jsonl
372b69dff2fe50cf2da5666547450c9ab7358861eef055da177c0d3afe34324d  release/kernels/lanectx.sv-hosted.log
9c95e10ebf596dfe7a84ab84b0f3f83677c1298198762268ea06f34880ca0b7a  release/kernels/lanectx2.by_instr.json.gz
60af40504e437aa9b76fe147521e7eae01aa58013db5c71c517381c5dfdf396e  release/kernels/lanectx2.by_unit.json.gz
d1c46c94b6b1d1fb2f239a45a58cc2a129820423a056374ffd66eda0640423d9  release/kernels/lanectx2.ccvtrace
2a50d44c3399be12b6677359d626a6601348f5b9863e5e102dcbf73a174016d2  release/kernels/lanectx2.log
45c13056dff5c73ed0c9ece56cc36f929bf335322193c7d5eb38710b1d1dfb02  release/kernels/lanectx2.oracle.jsonl
f43cde57324409e9a1051058e1133bc5ba2bf3ab2e40cc6b0be35be4c43f39bb  release/kernels/lanectx2.sv-hosted.log
16bfe6a33d834caa6a622d293f4a45accf85621a41e2a4e22522c162fd32e36d  release/kernels/late.by_instr.json.gz
f888218d371df0ca1b1b46b21706d5a885105e9b6bbdf7fe6d35abbcc91d800c  release/kernels/late.by_unit.json.gz
93f58dfd71bcce521d94f02a4d2a6383df7923f6b52ef8f9af0c7695ecba0175  release/kernels/late.ccvtrace
1daa79ecbe1d5934f858a0b0addda2778ebcdd6e334221ca64fd59d83411c829  release/kernels/late.log
86084f6bd747a2cf32acbc0ebd96ebd3e4ef2d8d9e21be49e3ae49290d7927f3  release/kernels/late.oracle.jsonl
2b6acecc1373fc3bdc5bac517b9c50be10cef7206229fdc093d23bc268b809b7  release/kernels/late.sv-hosted.log
332ad15fe7883d25bb80c341ec89c1daf5d3ce055d0788c43cff4dfb4771a1ac  release/kernels/ldpar.by_instr.json.gz
65d905ea94b7fd1507f962f720e1878ad2a8de773e149e25c0d13ffbd9bf0b12  release/kernels/ldpar.by_unit.json.gz
722b3b0bd4f84b30172e365d6b94c20ae6f9a6dc51fe16af1db2c1ccdedc66d1  release/kernels/ldpar.ccvtrace
29466161123b95f5461b944da79406e70878159431f7abd46955d976e3f9cc00  release/kernels/ldpar.log
8ac08538e9c807637babd61b31e340f7461878ada31f0c0b83cd66331cfaf486  release/kernels/ldpar.oracle.jsonl
202666954a5e2c42d39a4bf0c2bb55744d2d9d8667cd575b22f144a89ce2014f  release/kernels/ldpar.sv-hosted.log
abfc55c61d12543860d66003855a290491d685ca47b5aa956f4a4133cbd2696c  release/kernels/lnorm1.by_instr.json.gz
672a1197418cbb9da5d7153eea7ded33eefec2145058dd73a6c2cff0653df95d  release/kernels/lnorm1.by_unit.json.gz
bd93a528f262358a0d5085c0fb6ee324fe4df97ebdc0f35f512adc9840c947c8  release/kernels/lnorm1.ccvtrace
d41cf17b3d5dd0cfefabe566f2b6c87ef2f98a6f1fbe64ad94538640dbac3423  release/kernels/lnorm1.log
a8d85811af988a1b9fc00db1517300af3d93ec8e589e403d3b9113fa9e0ffc86  release/kernels/lnorm1.oracle.jsonl
188d0c868dd362abfd6562db678a7de7af923f70572bfcd146f6ca901525d8ab  release/kernels/lnorm1.sv-hosted.log
92e153a826c2e7c71c29576c47bdbc45a6c19a9bfc31206dbd62aeb20ab4c1a7  release/kernels/localsp.by_instr.json.gz
3e21a8b3e25358832b8d2ea0e6995a77bb004c2c95a9f1b87397967015297a23  release/kernels/localsp.by_unit.json.gz
059709bbb46930f59c1fe5b8c2ebefc8ffbfd68ee95254593ed3b7c5f506085a  release/kernels/localsp.ccvtrace
511df7a1f716999dd53275b5cc745b3cbb87aa97a25d2ef0d3d57a2f10c478e5  release/kernels/localsp.log
55e3c9f36e7f7d38c0ddd38903aff4bb4509ae862015c592e6b937ea258042ca  release/kernels/localsp.oracle.jsonl
89d7e25451d5c03dd6f0e90e161a00b0c5f7651a550213c10b205468e8ba1e5c  release/kernels/localsp.sv-hosted.log
732eaf7d103159860f56f86e5923a5403bbd69592bffc506e3e7cb76b31da16d  release/kernels/loop.by_instr.json.gz
cc54d2fc60479d6f78cb58582f22876c4bff391f59541aa050a36bd2200faa5f  release/kernels/loop.by_unit.json.gz
05599f989c0d60da6bbedde81701aa56ae1c2a56bbb878bbddeca9829b14e167  release/kernels/loop.ccvtrace
38cd3396460d72c10df25bd0ce36f34878949d68a99291e4abd3ef577e4573a6  release/kernels/loop.log
03ce5920c06c93e93516d8e53c3f7169f14e3593de204eacceffc0b8a3e32016  release/kernels/loop.oracle.jsonl
8af49e88c1e9df1a3ef4b6b9f5e2c913fa60e18d4d168d3c6dbeb34fd1be8b5c  release/kernels/loop.sv-hosted.log
4f7b72c25548095fb101a2c9fb177cea5e64145c2df6e7241c05cbc991097fab  release/kernels/merge.by_instr.json.gz
df54a7182e67324094d077c48466d8afcd1520f716fafe0d76f81a6db6fe8eb3  release/kernels/merge.by_unit.json.gz
2f43408ff2d9fff8512adaa9e24aae50158636b35dd1778e07d3a003df283170  release/kernels/merge.ccvtrace
0642768dff1f7f8a9f371cdf7b183509b780fdfc50ca2791a0d3450ea9f4c845  release/kernels/merge.log
f96d28815f8756b1f5a45ded53e6170883d2dfa10f9eef0d14b8050b1318164a  release/kernels/merge.oracle.jsonl
e2e8415f04bf20efc828e1d95520fe31d5e156b7f33a92e039a0c61716d66309  release/kernels/merge.sv-hosted.log
9c773505ef5633fa44e734bc9b76f9b0bde15552deeee98403702972a122e661  release/kernels/missrun.by_instr.json.gz
33cd70703a41b9b39f8ded75ca8f8d3b0cc6ff047e11c3f61c26bac5ab5ebcd4  release/kernels/missrun.by_unit.json.gz
db24d680f2714f6ba755b577007c566da5cbb6d8199ef80f7238cfd6455173ff  release/kernels/missrun.ccvtrace
78a26b3f437e1fe3afb5256b2ab0d42c955f1901462b5fbead062cb4805be804  release/kernels/missrun.log
531bdaf281e5590774bd2775427f25e4cc0419cf8e3d5b6999843ffe9ef87258  release/kernels/missrun.oracle.jsonl
0fd8ceabb6fb71f49ed4406f525a0bc43f0753059e4bb9b3617089c1242102c7  release/kernels/missrun.sv-hosted.log
799e46be577fe76c71fb0a839fc83347d05bfbfd0a5d120385251ff50f947729  release/kernels/mload.by_instr.json.gz
a303635ce78ad7ac411e0b756a5bfea6621264a32ec402d24dc1ffc2ec921e7d  release/kernels/mload.by_unit.json.gz
79882da1a5000197ea1770e602c7728cf915639724cfbaf1361823897ffa2e5e  release/kernels/mload.ccvtrace
9fc3bc7b25ca9569da146872a305deed1c0f2a637d7fec6129586e5bdb852452  release/kernels/mload.log
8000e477b9a95dfb9f0af964e8346acb9d36f1358fd06ffc4ff7cf599d2b8868  release/kernels/mload.oracle.jsonl
64f01afaafffdd73e7c9a5740b6372c96977f7f6eb2a307efed7e7e7a5ba2d0b  release/kernels/mload.sv-hosted.log
36c1e5d360c95eb210554ccc78b22c7463b05b485bf8a2904e372b14fef75d09  release/kernels/mlp.by_instr.json.gz
9247c6f5cfa3da19cc5fcc391cfda9a2008f481d1c272d6d93a2faf5ad0b01ca  release/kernels/mlp.by_unit.json.gz
44a6c1be3992aaf05a52c9c4573292650df8adef89278215be94866ccdf399c4  release/kernels/mlp.ccvtrace
91b4ef9fbec8234236cda533f0c69d6ecdf958bf0071132766743179cb18ea39  release/kernels/mlp.log
138d282f88d56c8ad648a91af0a983254b55d9fa22942c00d47b327f516a6e44  release/kernels/mlp.oracle.jsonl
53d011e840ad0df2207d9df0e4793c5552fc10b3a52639f6d0842d43bf3e1b94  release/kernels/mlp.sv-hosted.log
af6834361dd10c16e11b34667c332f9174af1183fd1cbe9e39406bea5058b718  release/kernels/mwmiss.by_instr.json.gz
36dfc9d67d14152c5f4c44d6c25e5dd120c3a09576ebf11a4035ccd4a78f3f1a  release/kernels/mwmiss.by_unit.json.gz
3c7c5c446414a8097fa212b31a8698d8c53100b6fea56b002ef7dbb232cb472d  release/kernels/mwmiss.ccvtrace
451ede22ff06e711081337a9fcc8059c0878535b8e4c6c3094d907be51350b55  release/kernels/mwmiss.log
8abe8e8997456a2a6711ee72da54d854b24e20abbdab28e4b7271c0d28418de8  release/kernels/mwmiss.oracle.jsonl
6d21da06a7af1a60649dd255548ec710dd1259bda4872d92e7075ff755bdace0  release/kernels/mwmiss.sv-hosted.log
a4e99c3de2fd66d7cb6eb3ed617c7a72d81ce1b922f9d17499274ee2465d67b3  release/kernels/narrowadd.by_instr.json.gz
24813ac8fbb5dc183763d9b0ac02831a17d382a8fa4b2b13c567f48d1f7d0b35  release/kernels/narrowadd.by_unit.json.gz
a589458c6355b0e9bbd7589bcae11dc10a6d1cac5cd0f0dda330a6d9a3dc58cd  release/kernels/narrowadd.ccvtrace
d72f59a088484011a60c4677ee6ec06af471de4c8061257966cd62d865a121b8  release/kernels/narrowadd.log
40a2cf629853dd404bb06b4a07e35abde3d12efc13f26ffe28f923daf2994574  release/kernels/narrowadd.oracle.jsonl
73150b7c53d340155f5baec064f68e88752fa387c2670418c96f2335fff11555  release/kernels/narrowadd.sv-hosted.log
e9009dcca4953339dc729ed8bb790d38bfe38a6ed419f8cae518d8bc840657b8  release/kernels/pguard.by_instr.json.gz
c1fce43e1651f3200e85de11fe7528803f8ae95385f19ad101d01cedcf9f8e03  release/kernels/pguard.by_unit.json.gz
7ea87af30b8cfa9e54b7754dd440ef60896a0330a3e1f42f3983de79cf02bd5d  release/kernels/pguard.ccvtrace
36a8e73893e37a93d594b8ae73b09da3357a747637dd3819fbea26dea18d5caa  release/kernels/pguard.log
690e56f1cb8d97cbf67124b7dff3ad0a90cb8981814cd1709cf0cd0e035b3bd9  release/kernels/pguard.oracle.jsonl
1bfbca81b560a97d561a936e1ef94cf5a6235e47a1bfc846cc4fe8223cdbe1de  release/kernels/pguard.sv-hosted.log
3369d7556fbd4cc23fdb50dbd0ba0898183816b1bdc5f3bd592af3991197d871  release/kernels/plog.by_instr.json.gz
10a7b7d926d557fd7a85a52e62baf848b109a9ef379750ca3cec7ac8ed977778  release/kernels/plog.by_unit.json.gz
ce4aec9a797ce6e24a9082c3c4e22e4cc45d2bd6d9cf47ffadb3e8da5e251eb9  release/kernels/plog.ccvtrace
fdac345ea363af737ad946144b80db833fd50ec242049ceeb8418057a57ffad6  release/kernels/plog.log
0c99915e2da60f4670da00504a6371d7d17701d4431e733a3ff8fa98a2030d6a  release/kernels/plog.oracle.jsonl
064b66d1af1acb8b361ff5b45d3a79b2931f3c80a0c8d38ffc00bf0f4ff9cf8a  release/kernels/plog.sv-hosted.log
e9d4894237b82a3bc753127f68277c6421fa238e49f86e4aea901501cfa1c571  release/kernels/pmovdiv.by_instr.json.gz
8615bddd3f1fcfc047f4c3cf12d282b0dbe83ce99875dfbd5d5b0f05a4fb7cf3  release/kernels/pmovdiv.by_unit.json.gz
4fe481c67584f36b72d1f510fbace5f75fa34ca8d76713e16d393f8638f099f9  release/kernels/pmovdiv.ccvtrace
6a390bd9d495b5f2a68f393b5a0e1799379092a482f2900a3202335373391038  release/kernels/pmovdiv.log
7bc646cff6166a51bdce03d7c1b7209e871f0a91d743083a9b910a80bcd0b33f  release/kernels/pmovdiv.oracle.jsonl
b0faa043de6f71329d3b247aa8bfb80ec997c1d5a906dd4909358919220b1165  release/kernels/pmovdiv.sv-hosted.log
0582278bcb1bf0b986523f38bb9b7212e5c8c484a14db0b428858ee7ddd1da32  release/kernels/predlane.by_instr.json.gz
67d82d5aa945319e2a3218a4ef134a6721cc53ce93978baa1e61cd3c05a51eb4  release/kernels/predlane.by_unit.json.gz
43ffb5fd93c492e608093ee380fd91f02047a73d0d5bca90f37879a3a9b027e6  release/kernels/predlane.ccvtrace
479e3a3c99ea93e23bfe746c9f8dcd8e967aa4a4902d2fc4603d0fc5617f5de0  release/kernels/predlane.log
c45f4177b9e84fc8a6e36b13534a0c7636eb30a3f8531847100ce5e23bf404b1  release/kernels/predlane.oracle.jsonl
c4e25f13e3a28e6452eaadb1742419e9eebcc5a00057a3c6a7f6dc5d195e582f  release/kernels/predlane.sv-hosted.log
af7dd815cf40462a6885966995208bc890c83548f3cf58542e5ad87290c22589  release/kernels/predmerge.by_instr.json.gz
a383261b289ad522d44c91f4659c38f5f2232755826fd5e7eb524933cb510b28  release/kernels/predmerge.by_unit.json.gz
d773aa91af7cfa2400e67801a569c10b730b800848cf39adce1a17e4661f83d2  release/kernels/predmerge.ccvtrace
0519f238adaf3a6e08771d0e2a16b56ad9c6c879708d8498869806605d09e994  release/kernels/predmerge.log
6c737c49434bcd08e3e0814c8b1dbf15c586ae74f7929ba3148ddcee2c62c845  release/kernels/predmerge.oracle.jsonl
e040fb7eef0d87c078e2ff22315c18b4aa8204cbf69c51c91ae48c2ab7094f11  release/kernels/predmerge.sv-hosted.log
8603e60616acc48d393d1f4881ad0e98217922e9b7fc33b1d39b2ab281b1db2b  release/kernels/predspill.by_instr.json.gz
dc460dbb275bf515866b9a2835397eff5b3eb4812286603eb7fe4a5a4f2bb9f0  release/kernels/predspill.by_unit.json.gz
ef5cd45c3aca2c80a0f934209300878095623cf9fdccac71b72455d598a5cc83  release/kernels/predspill.ccvtrace
b74453365f9626a9409e6d640e53ab7e82192753459b98c362b79e73c7c443a4  release/kernels/predspill.log
b7c84c6478117ffa0f06da0e6ad1e4628e2683426a7911080810e78e06a5242e  release/kernels/predspill.oracle.jsonl
93642cb00a9254a7437bd33fe3edb87e46627330bbf341a617453a4c4e4ab03a  release/kernels/predspill.sv-hosted.log
735edb80e8c030526244b8379e1f43a512715699cea9c691882e5f9e6377e17f  release/kernels/predswap.by_instr.json.gz
6a8573c03983b9dd248c2b64ee4a33037b7b968848ce6b73240865abafcb3be1  release/kernels/predswap.by_unit.json.gz
6dde3956ce0082953ad263d923ba60c127a1dbf50b2927cd690a854dd840bac6  release/kernels/predswap.ccvtrace
69ed6f207b3cad4ac61f32b06735e6878b4f50c1802b141d303d23f863f31011  release/kernels/predswap.log
a6d4f7ed517553816d889c7c9eeb6bcfd1f6c973fbf682ecb69f3c2de619f7bb  release/kernels/predswap.oracle.jsonl
9cc027e2b86114214e994215e57ad58c8e354efafdcefb2296e4083ce01d3103  release/kernels/predswap.sv-hosted.log
7a8fa4a8e1abadb285ed4437af93e838d226a64fba8816ab7ab2e4c950038cb6  release/kernels/privwin.by_instr.json.gz
c803cbb2602ca1b397adccdf2a1ed449173ce78ab617f11f6e198f21d35f8494  release/kernels/privwin.by_unit.json.gz
d53c8162338be0b94ef51f673abfc0f89554e08e8932971eff0d29056ca8812d  release/kernels/privwin.ccvtrace
7079891685b3eecf6e7d505c709120bf9a469665823581448d93ca8d86be2ff3  release/kernels/privwin.log
861f686fc4480363472908d679d8815e8c957d768e7ab32c826930527b0fb7a8  release/kernels/privwin.oracle.jsonl
88a31ff8833473e5bae08ff4a17036929d03d12a5a763c58f0220d3c7e9a73d9  release/kernels/privwin.sv-hosted.log
8b577a314a338569c678ac4e31615cfc21f5a2cc64d49361d96b6cd30465d737  release/kernels/provswap.by_instr.json.gz
542495312bea4ce8b15f888d467e6ef1e344be49f122441261a640c82a03c70d  release/kernels/provswap.by_unit.json.gz
52011821a7e778f898c918823c2e49261fea50a7278468ff0e93ab6514c207f1  release/kernels/provswap.ccvtrace
c38536ad24c43db7a89cc7345baff7e6b97972a9b5152f0120a06bfa0b2fec77  release/kernels/provswap.log
c9c32a793d54cc7401477f582487f7e8b345b2669a75337b8d6327120d98e5dc  release/kernels/provswap.oracle.jsonl
0181f188216685d795a0f64d73f2c05d522abbdcc89ac65a3613c13b3d8744e5  release/kernels/provswap.sv-hosted.log
514043926cd5396decec555dc92361ef1365d2e2ca6c30ac09c63fffb16a7533  release/kernels/retmiss.by_instr.json.gz
cc6e259691e8edf8511692049abf01327acfaefcb2724751b835d8174cd9f707  release/kernels/retmiss.by_unit.json.gz
e01787edcae3313ceb75059412210168f0598207c4ff3b7135fd33247080941c  release/kernels/retmiss.ccvtrace
16cf0e54f6bbc6d5341141943710efe6adc74b24d9d7a8518a979e96c59dd574  release/kernels/retmiss.log
e5ef8538e838c6cff7febfc679dd091cf5e002f82d34f1009b1948ce22bc3649  release/kernels/retmiss.oracle.jsonl
7acdecb54525fff3759b19c38ae76ba809e85ad666ec7c162bcdfaed7c349177  release/kernels/retmiss.sv-hosted.log
d45b064f90b496adbbbf3be694a8cc4f6af4ea41825c8bb83b0c4042da5a369a  release/kernels/roconst.by_instr.json
b38b6900712bfd3ada68a6b3627c4ea3fe521aef042fc47dd43dfb23bb1283cf  release/kernels/roconst.by_unit.json
f3713f83ec2f195b035033bdb47cfd76ef95bbcac2a975d18c8e17e3b3ccda49  release/kernels/roconst.ccvtrace
3a8dbca0fe64dc3e35a8d8b8ab3c8131a6e1fb9fe115ce6f593786597c144408  release/kernels/roconst.log
8087c0671de620162881aecd38cd6114b78e7be6bd71201e3ec02c9a2e2e750e  release/kernels/roconst.oracle.jsonl
45c3b7b1b56174ddb512f59265ed00b22ef2570ac5a09bfd886bd110ce6d7e53  release/kernels/roconst.sv-hosted.log
7d213047dc11229803ff907bc5a2192cad3a16f993fe7f5ae66bdd5e6ec74442  release/kernels/rogated.by_instr.json
3a6a748df6a4dbb1e6aeaf303bcb3d15181e59f0192c0a6cce0cc8318bd48d09  release/kernels/rogated.by_unit.json.gz
e0022bd67a6d629144891b56607860fafa98ac1de5fa80dc411be11a44c9a890  release/kernels/rogated.ccvtrace
6ff2c0de9a74cc2c88ce562712e3c17e249f4b9bbdf2ff359bf78e9da4fcda33  release/kernels/rogated.log
7cd02bd4cceec5a044d6b4d6a80df1e68ed0ae71b0b2a953143636d5b809ea6c  release/kernels/rogated.oracle.jsonl
653f7c2d6861fdf2c480875ab81280b67d7b39555902fc7cc68a9ae58a16088e  release/kernels/rogated.sv-hosted.log
76487fad60030dd0669686dd08ff37f8f8741190266426e50d9a9b906d054f83  release/kernels/rokill.by_instr.json.gz
54858197eb8bffc744a60f1962365f655af4491524073fd9bb07ec42d46fa6ff  release/kernels/rokill.by_unit.json.gz
cb434c89178bda63feb85c508e8cbd1b00bffd6b69525ab858d2b11b6cf16c17  release/kernels/rokill.ccvtrace
ea61cbe4274fdafe115b14e163dd1b38a709532704e4afc20a8bfd30b4f41add  release/kernels/rokill.log
94efcef96af469a512d346ce61623980fe86383188eaebd55120f716db596f14  release/kernels/rokill.oracle.jsonl
d53f9029cfd55adaf4a3dd724735978e57b2a3f1dff0ccc2a205b6d4c70091ae  release/kernels/rokill.sv-hosted.log
34d4486390d52c340fb38b47e48667791a92dd4fbc27ed335a8ea4733413bcee  release/kernels/rokilllane.by_instr.json.gz
737cca5a3573f1480b2f8f68a05286aec70707c7a2652960218ff17f9fdfa9db  release/kernels/rokilllane.by_unit.json.gz
dba628a43540510e90493dcf402203d99b3542ad6dd5a94033f0f5f1309c0d42  release/kernels/rokilllane.ccvtrace
b3c1c89ea1e6f2d421cffa5d9cf6096947f962c930ba06a48245483fac507ef8  release/kernels/rokilllane.log
f5ca6e666eff2f44894df74a291b43b3c0e7be0a63a47d795fdefd7b22016f45  release/kernels/rokilllane.oracle.jsonl
357a910914f11fad4180eb0e62e72fa915445ed330709915dab6628afa62ef4e  release/kernels/rokilllane.sv-hosted.log
f8fe604241644b224e6431d16e4fad889c99826b82f49205e4c9014b9ae62e8a  release/kernels/rolaunch.by_instr.json
12e5281971b0a06ca95d953aa22a6d6b481d8fee948f50ab777c87877757fe46  release/kernels/rolaunch.by_unit.json
32fbf77dc8fb17f0113b068b5a00568b6ea97be3ad8e5bd1c69b7cae2f04a946  release/kernels/rolaunch.ccvtrace
17eae3d99453e99b558374444cbf9f8f6c2600910a4f13fd722a13caf49fc391  release/kernels/rolaunch.log
e7dad585c3e70615de04330fd03f4f282c29a005dc1732a35655fb261d51139e  release/kernels/rolaunch.oracle.jsonl
d5b0adf293638d6b20bdab836c9df931b15e1e6172e4d04625b00a46b70b107c  release/kernels/rolaunch.sv-hosted.log
d45b064f90b496adbbbf3be694a8cc4f6af4ea41825c8bb83b0c4042da5a369a  release/kernels/rolimit.by_instr.json
e8822066a61bf10f59647aa7240a3044f25d2eba55ac5f7ebacbf1901974dd8f  release/kernels/rolimit.by_unit.json
0e8db555321feaf0fded659de3d7ab35b3dadb15ccef4bf8dabfaec2e87a5563  release/kernels/rolimit.ccvtrace
690b62f8e82f8a12b84214d2020eb8c2d16af9b6a6199944cc903b1f214f389e  release/kernels/rolimit.log
1c5bc0cb8e8b2e69505fb5a551a16d5d10c56f232b88da7a27e336ad7d962de2  release/kernels/rolimit.oracle.jsonl
69ac43c6e12c5df8ff3a631bee39065bbdcaf71725f3cf64e2eb65268ce0a801  release/kernels/rolimit.sv-hosted.log
0ae5d6354369c1919e1a328a92afd0cd57188264ca16b1355dd02d8dc6aaef37  release/kernels/roload.by_instr.json.gz
a0cea0ab4c6618508e85314b4f1a2c3364c3e9cf26ce278aa5f9c10699326e4d  release/kernels/roload.by_unit.json.gz
aeaec16ad191a7398d05779dae10b703ade002cfd0dc122e276602930405a40a  release/kernels/roload.ccvtrace
22ff90c31abf892048dae7d01af2653e0bba3d91f7eefdae5b1f00a17407a031  release/kernels/roload.log
f7c1309cc9764769fb5803f6fd0f2f5e1eb418f2d23fbe5e17cf5f9106869fdf  release/kernels/roload.oracle.jsonl
15f9280cde4e30937fda2cf3db359fed040da932a6d2bd95747e7b6fb98bde78  release/kernels/roload.sv-hosted.log
06ac6fdb88d9345b70854219f7daa3a0376119d50a05d1954c6fe66f6dc28eef  release/kernels/rope.by_instr.json.gz
0cad7aba5867ae3fe9c1f6f6887769b976718ae66db87a599dca802ae4c40cdb  release/kernels/rope.by_unit.json.gz
01c05d72273a423f5463206a601cdb64c719d7094a97707467ef837b8c036602  release/kernels/rope.ccvtrace
5fdfba263e0b0cd2661b4ae962093d02b5a1c5ac10eeba1f8329407b3eed25fd  release/kernels/rope.log
d55f9efae392dc8877c102c01c0810e7654b666b6ede386328108164c6cf88f3  release/kernels/rope.oracle.jsonl
a1848bb7506dc4fe353fd209e558b114c6e9f08d3f4e1eaaa3dc9b878ae49db1  release/kernels/rope.sv-hosted.log
9c7b9f691680df827e83606f78e40f323ba354e0ba2b15f172913cfa7df29672  release/kernels/ropediv.by_instr.json.gz
eeb979a6ab4f5c61ba4ade6058e803a1390de5ef2c54cf4b5b832a4143b114c0  release/kernels/ropediv.by_unit.json.gz
314a1adcf5bf9b94fa9b376e8492417842a1d2b334018cc1014c4df80ab63dfa  release/kernels/ropediv.ccvtrace
ac6a27099a06caf9ade548138b723475305ddbda0a8e9e3663a477ef4638d710  release/kernels/ropediv.log
10c0ec6ec18b7b44638c790033109198c079d07c1537bf193353ccedd00a920f  release/kernels/ropediv.oracle.jsonl
38b89a6aa7379ec57d6fc5a7beb7fc3b2ee092eb1f296ee57486ffec1c2df630  release/kernels/ropediv.sv-hosted.log
4326685209add293653e14530cde79c171b0a14e14f95305399efa433ef35b68  release/kernels/sel.by_instr.json.gz
1133ae322f9c5607c3da9f0d9720c7e9beab3d84870107b349b8cbbef7b9696d  release/kernels/sel.by_unit.json.gz
33a33114b5167306fc24ee447399ba293a8568ed59ddc2c9e307b97a3df3638f  release/kernels/sel.ccvtrace
c9c85eb35ca8618e716376041ac183a741bb46124ed4a49d06637dca9342f8e2  release/kernels/sel.log
87f6a81e8afa004c8039bf2f61c90176fcf29ab29bb17ac44aa016a5cc8438fe  release/kernels/sel.oracle.jsonl
12dac5e95efbc2cd3f2ad731451320bff786192c86f7a9565de3efbfc5d89865  release/kernels/sel.sv-hosted.log
6bff22fb1de3323c56cd57c48281cc12fc4ba1d9966874537fb80952ed17e617  release/kernels/sized.by_instr.json.gz
6e22ba561c688b7360d6acf6581b04aed2c506edf7ecdc22c14124f548767930  release/kernels/sized.by_unit.json.gz
96ab17d9315d0926a3fe12caabaecf335da5f274469ba35da2137ab19e16294a  release/kernels/sized.ccvtrace
6613b159f2e23e93daffb07ae923b058eb801746717995dfdc3d7ee04b6fcbb5  release/kernels/sized.log
36d903ba1618bd1faa437c9812a6ee6c0c966a63196c796267d74bf2695ebc3d  release/kernels/sized.oracle.jsonl
c6be61d8fa4a87d6a6597559a792f2d0ac3a09e39badebb777f7e051d5836c2b  release/kernels/sized.sv-hosted.log
1b83e97986b875c1211d2d514fc42d5195894958d5aa2e6daf6b4749b03b3ac9  release/kernels/slotform.by_instr.json.gz
dd0c1dcdfa540e0c588c3568b5ba89862a0aa785c7eb423a6b6f033791862e3b  release/kernels/slotform.by_unit.json.gz
4b489164ed494bde355d915acfca6d1c7e362baf785a511c2f9c5aa2e36d0471  release/kernels/slotform.ccvtrace
33d4c85159771243e8012d4d2802694643345bb26c9a994aa1bfc75059c5fd80  release/kernels/slotform.log
8b61db7419b18cea8a646fb628218447e72e84a18a9891ffb73b441736138ab9  release/kernels/slotform.oracle.jsonl
44c9bbc8560833b0cec9f62dea3ae0371fc132bf897de7ef3be9e4afa3bccad6  release/kernels/slotform.sv-hosted.log
a7fe9150f617788aad166c9c5721008fbf85652a0c749722787c07cc5988cd0a  release/kernels/spinwait.by_instr.json.gz
e787625b49fcf7cea86a549c870c4bd8dc8ef2c0af244c35d6cc0aae67a07c67  release/kernels/spinwait.by_unit.json.gz
1542b9b1af9bbcf090c10f31e2ac5a965ab4fd4812810c7ed152387a80e3f9cb  release/kernels/spinwait.ccvtrace
285d630ce34fabd0d8bd1a796c7043da45033ceb5018ad55b459e80ebcfdff51  release/kernels/spinwait.log
868920637236c878b33779bd450439466fc3626996a3164573dc11d437d5c709  release/kernels/spinwait.oracle.jsonl
e51ee763fba779706d9e728940bd3b75efb7fca2f6a8051f4c515171c7f7f8f8  release/kernels/spinwait.sv-hosted.log
4956b62a831d9c70b23e5780fae074fafc818a64ef2e37641054ae6f955e37cc  release/kernels/spmbank.by_instr.json.gz
1c6f717f3ae51bfdcb2d734a5df3b448ed9521ff7568c176279b1892d47ef40b  release/kernels/spmbank.by_unit.json.gz
c9e0541d73a86ace0be2c7140b58c219c67cdc59ea3c535408d630297cbaaec6  release/kernels/spmbank.ccvtrace
42557d5759bd562f8d661b42e41efe639f216a1607b0f52145012e5d8d61a576  release/kernels/spmbank.log
3af490cc37d7a92dbe719b57de216b648536eb301ff9d13de9a39f50d150d725  release/kernels/spmbank.oracle.jsonl
8604403abb5e3227aedf81aa5c66ca70af5892c2024007979504f49ab63911d7  release/kernels/spmbank.sv-hosted.log
dea16777f6d564eb6b26d0001d84cb833533e16d731519e5e9ddd88fc04441fa  release/kernels/srd.by_instr.json.gz
235fa1ec4f59773a81a64403265695582a9580b9e8f2a9bd0ea403074a53fbfe  release/kernels/srd.by_unit.json.gz
f255c02a28c53c4b57a6b17bccf73852f4dfb2d06486b63be7fd69e6f3ef22dd  release/kernels/srd.ccvtrace
5e92d83bb1bef4aaf765a4b87019bbfb93e7974c037864bf12c5ee1b2ca4a90c  release/kernels/srd.log
b08eb5e3673cac7eebb8b72af5ed3783c8e70a9e96592e76bf3722551bc79473  release/kernels/srd.oracle.jsonl
6f58763476a03209a548512c1d37477c832b3888914062841f49b99168d68ab4  release/kernels/srd.sv-hosted.log
3cb62f6549a7b8b6c0d1a0ab37d0e1411239fe60f7b3f348b53547904fa283e5  release/kernels/stall.by_instr.json.gz
2c5c1f8bd53ac4939a742b525d71d8a4c2c7f23f6f992f6e42bc90717aed1254  release/kernels/stall.by_unit.json.gz
7be7622c1b3bdf30f0362f3058694550ecf66c17ded838a604d1f10d3816874e  release/kernels/stall.ccvtrace
e226193e535a7ee5074c7cd156f6b983ce594d1fb689dfef3c2395b87e60c89d  release/kernels/stall.log
500db2c482b07a0706583422cd68878301d0146c1f872ccc1f11bfdcf5c993ef  release/kernels/stall.oracle.jsonl
9be3494ee8eee23de53775ea8d70cc3785d08e12d3c9f23ee1027534a64ed857  release/kernels/stall.sv-hosted.log
2fc0902c15675ad965bfb0ffce9d865c8e80119f6690175b358b275ebe088d4e  release/kernels/swap.by_instr.json.gz
54aeedfdd025f01e95fea94816964f3ef3246b4074a90ad5426aec1c39fa7049  release/kernels/swap.by_unit.json.gz
03edb62824a690d4bf7f46bc9d4841c7612d9a08df8aaf6af5750971130cd3a2  release/kernels/swap.ccvtrace
94cbfab634a7e28151a3178a8c31d0e7011bde3634a665e7f6c0248b9fac4871  release/kernels/swap.log
3658a26316c1ff7bc1744304a42f736e930fcde2865c8913e6cc67a22ce96667  release/kernels/swap.oracle.jsonl
59e4025d424ad7388489106b862b9b9d3c6757cd552752374001a7e23f330c08  release/kernels/swap.sv-hosted.log
55502e7234195f803541b1ce7fcaa47a65553551eca864a26cbceb8062dea63b  release/kernels/transp4.by_instr.json.gz
1eaf5c7212ef20a4e760adef4ed7bf1b8472779cd5d32ad8719c7ac743ef708e  release/kernels/transp4.by_unit.json.gz
42420d45bcd9f832fbda0212608f9f12d023ad5855373035414c976b969d7d47  release/kernels/transp4.ccvtrace
969ac423919f32b7c07f2649f164171dd9bc8e049af25e92a0952234af28e7f9  release/kernels/transp4.log
06396ace3ac19677fd39c700e408606e5bdbacb24997d663bbe8872e63dd74fc  release/kernels/transp4.oracle.jsonl
70740ca0290d661eab848c171e36b6fde1a3a968c813f15f9132c862128fbecf  release/kernels/transp4.sv-hosted.log
8b2e8203ed718b22affe7e0265c08123649af0fea5c12a3c94154dd5875ed032  release/kernels/unal.by_instr.json.gz
7e09e1dff6a425f46200480046a9fa1dac2752a8481d895f8115842718100e59  release/kernels/unal.by_unit.json.gz
f0cc8a6483da7e1547d81822745f9513824861f37c3e59f25922c8df4895b09b  release/kernels/unal.ccvtrace
73cef6003f06c7a06cbd8dff05d46e32447275d222a44b380e6553a28d48edef  release/kernels/unal.log
c3d484bb160657a563df983d9a2532eac27f556636617960aa1e72183ac2b299  release/kernels/unal.oracle.jsonl
2a088840de59ac5528b97575087f528412f358569277d64e8e4825b5a89a2c80  release/kernels/unal.sv-hosted.log
6ce0f0b8ffe2d68a062d12e55c495f895e65f68c7c7ca945eac189035713d17a  release/kernels/vadd.by_instr.json.gz
2e894dbb44f22d4b248ad004ca7e1ca20cd1a5960aedc339103c102acadf763b  release/kernels/vadd.by_unit.json.gz
825febc1f9a8bc5b55bb674ac0be9eac9ba860f1958becaca4d396290e4eefb3  release/kernels/vadd.ccvtrace
ff777e4dbfa68b04069d091254550c7725243e226258bbc7e172ba2368e65ff2  release/kernels/vadd.log
0276b6d0611a4bbcdc004ab3987214aea138245bc7217504147331689a9c0880  release/kernels/vadd.oracle.jsonl
1f14dffe1068163efcbdd2d04ffa7252710d956ba324ad425ac97a0fed7b78cc  release/kernels/vadd.sv-hosted.log
ab74ddce27a6ad937cba48dd255ec4ba388fb628610487397d4b3fda0b236fe1  release/kernels/vadd4.by_instr.json.gz
68fdca7fbed6e0bbb7ba71c1aac0a76bddebe0a8d8171f20b56d80f82a810c1a  release/kernels/vadd4.by_unit.json.gz
9960fe139d35d9d668e0051597af8d273d43e895a52869c29d53b486d2556f84  release/kernels/vadd4.ccvtrace
98e3343895e84c51d61f86434920c2649e1bbb7ed5a42311fdb5698afd73803e  release/kernels/vadd4.log
225aa18fc9f38aa9ad615aa11de254337d59fa705877553d873062c68366e0db  release/kernels/vadd4.oracle.jsonl
53dfa9d7ebfb427718af6eb5ffea8c84becd9437008164173c59c94cca789eaf  release/kernels/vadd4.sv-hosted.log
dba1b19d787a505abf7133c95d1503934c04738c9f22b1a3d8f90d9e0b748d8a  release/kernels/vaddslow.by_instr.json.gz
d2cde459891cc0e4cb62436532213d62aef6429d324c4ff5bdcaf910a463bad4  release/kernels/vaddslow.by_unit.json.gz
d87344fe4eb495874c5458634e18751f8cf89c534e99fde16c9d9771b54ae8b2  release/kernels/vaddslow.ccvtrace
d633b387442348f4a78b6110c450afa6abfcba8427cc163b7e8ac91310f4bbb2  release/kernels/vaddslow.log
e9e6218e8b8450e9f9ff6b39d659c994a1e51c527a0c5bd10d18b5658ae0e344  release/kernels/vaddslow.oracle.jsonl
f6e52da9d4a1a96add35988677d4f27852877d2c078e44007e429fd4a8947d9b  release/kernels/vaddslow.sv-hosted.log
d296da238d59a4996afdad739f5d5f16f7fab836d01e854fd5ccc25aa2b50abd  release/verify.log
56b3d8627d79d397ca06dfb57060015391cb95e52e925d1f09a4b2a7f4147127  release/wiring.txt
```
