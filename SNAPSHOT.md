# Snapshot snapshot-2026-11-16-804d1e6

**A generated, read-only snapshot. Do not edit or merge it.** The source
is `ti-sweep16` at `804d1e6f301075b8a5a1ca63030813b6ee797793`, and this branch is rebuilt from source by
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
| Source | `ti-sweep16` @ `804d1e6f301075b8a5a1ca63030813b6ee797793` |
| Built | 2026-11-16 (UTC) |
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
| `addrneg` | `name=addrneg finished=1 cycles=79 from_fetch=48 retired=1 issue_groups=2 order=ok gpr_mismatch=0 pred_mismatch=0 mem_mismatch=0 check_failures=0 class_violations=0 overflows=0 credit_leaks=0 cor_late=0 channels_used=23/55 violations=0` |
| `atom` | `name=atom finished=1 cycles=7843 from_fetch=7812 retired=29 issue_groups=29 order=ok gpr_mismatch=0 pred_mismatch=0 mem_mismatch=0 check_failures=0 class_violations=0 overflows=0 credit_leaks=0 cor_late=0 channels_used=32/55 violations=0` |
| `atomf` | `name=atomf finished=1 cycles=4423 from_fetch=4392 retired=12 issue_groups=12 order=ok gpr_mismatch=0 pred_mismatch=0 mem_mismatch=0 check_failures=0 class_violations=0 overflows=0 credit_leaks=0 cor_late=0 channels_used=34/55 violations=0` |
| `borrow` | `name=borrow finished=1 cycles=99 from_fetch=68 retired=7 issue_groups=7 order=ok gpr_mismatch=0 pred_mismatch=0 mem_mismatch=0 check_failures=0 class_violations=0 overflows=0 credit_leaks=0 cor_late=0 channels_used=21/55 violations=0` |
| `brs` | `name=brs finished=1 cycles=99 from_fetch=68 retired=12 issue_groups=12 order=ok gpr_mismatch=0 pred_mismatch=0 mem_mismatch=0 check_failures=0 class_violations=0 overflows=0 credit_leaks=0 cor_late=0 channels_used=23/55 violations=0` |
| `byp` | `name=byp finished=1 cycles=118 from_fetch=87 retired=14 issue_groups=14 order=ok gpr_mismatch=0 pred_mismatch=0 mem_mismatch=0 check_failures=0 class_violations=0 overflows=0 credit_leaks=0 cor_late=0 channels_used=31/55 violations=0` |
| `callret` | `name=callret finished=1 cycles=265 from_fetch=234 retired=40 issue_groups=40 order=ok gpr_mismatch=0 pred_mismatch=0 mem_mismatch=0 check_failures=0 class_violations=0 overflows=0 credit_leaks=0 cor_late=0 channels_used=30/55 violations=0` |
| `cas` | `name=cas finished=1 cycles=6524 from_fetch=6493 retired=56 issue_groups=56 order=ok gpr_mismatch=0 pred_mismatch=0 mem_mismatch=0 check_failures=0 class_violations=0 overflows=0 credit_leaks=0 cor_late=0 channels_used=32/55 violations=0` |
| `chains` | `name=chains finished=1 cycles=96 from_fetch=65 retired=29 issue_groups=29 order=ok gpr_mismatch=0 pred_mismatch=0 mem_mismatch=0 check_failures=0 class_violations=0 overflows=0 credit_leaks=0 cor_late=0 channels_used=21/55 violations=0` |
| `coll` | `name=coll finished=1 cycles=78 from_fetch=47 retired=24 issue_groups=24 order=ok gpr_mismatch=0 pred_mismatch=0 mem_mismatch=0 check_failures=0 class_violations=0 overflows=0 credit_leaks=0 cor_late=0 channels_used=21/55 violations=0` |
| `div` | `name=div finished=1 cycles=978 from_fetch=947 retired=144 issue_groups=144 order=ok gpr_mismatch=0 pred_mismatch=0 mem_mismatch=0 check_failures=0 class_violations=0 overflows=0 credit_leaks=0 cor_late=0 channels_used=23/55 violations=0` |
| `divchw` | `name=divchw finished=1 cycles=111 from_fetch=80 retired=5 issue_groups=6 order=ok gpr_mismatch=0 pred_mismatch=0 mem_mismatch=0 check_failures=0 class_violations=0 overflows=0 credit_leaks=0 cor_late=0 channels_used=22/55 violations=0` |
| `divtail` | `name=divtail finished=1 cycles=642 from_fetch=611 retired=96 issue_groups=96 order=ok gpr_mismatch=0 pred_mismatch=0 mem_mismatch=0 check_failures=0 class_violations=0 overflows=0 credit_leaks=0 cor_late=0 channels_used=23/55 violations=0` |
| `divtail2` | `name=divtail2 finished=1 cycles=1517 from_fetch=1486 retired=366 issue_groups=366 order=ok gpr_mismatch=0 pred_mismatch=0 mem_mismatch=0 check_failures=0 class_violations=0 overflows=0 credit_leaks=0 cor_late=0 channels_used=23/55 violations=0` |
| `fence` | `name=fence finished=1 cycles=83 from_fetch=52 retired=7 issue_groups=7 order=ok gpr_mismatch=0 pred_mismatch=0 mem_mismatch=0 check_failures=0 class_violations=0 overflows=0 credit_leaks=0 cor_late=0 channels_used=30/55 violations=0` |
| `gather` | `name=gather finished=1 cycles=265 from_fetch=234 retired=16 issue_groups=16 order=ok gpr_mismatch=0 pred_mismatch=0 mem_mismatch=0 check_failures=0 class_violations=0 overflows=0 credit_leaks=0 cor_late=0 channels_used=32/55 violations=0` |
| `hit` | `name=hit finished=1 cycles=212 from_fetch=181 retired=17 issue_groups=17 order=ok gpr_mismatch=0 pred_mismatch=0 mem_mismatch=0 check_failures=0 class_violations=0 overflows=0 credit_leaks=0 cor_late=0 channels_used=31/55 violations=0` |
| `lanectx` | `name=lanectx finished=1 cycles=70 from_fetch=39 retired=10 issue_groups=10 order=ok gpr_mismatch=0 pred_mismatch=0 mem_mismatch=0 check_failures=0 class_violations=0 overflows=0 credit_leaks=0 cor_late=0 channels_used=29/55 violations=0` |
| `lanectx2` | `name=lanectx2 finished=1 cycles=70 from_fetch=39 retired=10 issue_groups=10 order=ok gpr_mismatch=0 pred_mismatch=0 mem_mismatch=0 check_failures=0 class_violations=0 overflows=0 credit_leaks=0 cor_late=0 channels_used=29/55 violations=0` |
| `late` | `name=late finished=1 cycles=168 from_fetch=137 retired=16 issue_groups=16 order=ok gpr_mismatch=0 pred_mismatch=0 mem_mismatch=0 check_failures=0 class_violations=0 overflows=0 credit_leaks=0 cor_late=0 channels_used=31/55 violations=0` |
| `ldpar` | `name=ldpar finished=1 cycles=154 from_fetch=123 retired=17 issue_groups=17 order=ok gpr_mismatch=0 pred_mismatch=0 mem_mismatch=0 check_failures=0 class_violations=0 overflows=0 credit_leaks=0 cor_late=0 channels_used=31/55 violations=0` |
| `lnorm1` | `name=lnorm1 finished=1 cycles=2516 from_fetch=2485 retired=526 issue_groups=526 order=ok gpr_mismatch=0 pred_mismatch=0 mem_mismatch=0 check_failures=0 class_violations=0 overflows=0 credit_leaks=0 cor_late=0 channels_used=37/55 violations=0` |
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
| `rope` | `name=rope finished=1 cycles=670 from_fetch=639 retired=354 issue_groups=354 order=ok gpr_mismatch=0 pred_mismatch=0 mem_mismatch=0 check_failures=0 class_violations=0 overflows=0 credit_leaks=0 cor_late=0 channels_used=34/55 violations=0` |
| `ropediv` | `name=ropediv finished=1 cycles=960 from_fetch=929 retired=203 issue_groups=203 order=ok gpr_mismatch=0 pred_mismatch=0 mem_mismatch=0 check_failures=0 class_violations=0 overflows=0 credit_leaks=0 cor_late=0 channels_used=34/55 violations=0` |
| `sel` | `name=sel finished=1 cycles=77 from_fetch=46 retired=8 issue_groups=8 order=ok gpr_mismatch=0 pred_mismatch=0 mem_mismatch=0 check_failures=0 class_violations=0 overflows=0 credit_leaks=0 cor_late=0 channels_used=29/55 violations=0` |
| `sized` | `name=sized finished=1 cycles=984 from_fetch=953 retired=25 issue_groups=25 order=ok gpr_mismatch=0 pred_mismatch=0 mem_mismatch=0 check_failures=0 class_violations=0 overflows=0 credit_leaks=0 cor_late=0 channels_used=32/55 violations=0` |
| `slotform` | `name=slotform finished=1 cycles=4350 from_fetch=4319 retired=12 issue_groups=12 order=ok gpr_mismatch=0 pred_mismatch=0 mem_mismatch=0 check_failures=0 class_violations=0 overflows=0 credit_leaks=0 cor_late=0 channels_used=32/55 violations=0` |
| `spinwait` | `name=spinwait finished=1 cycles=1976 from_fetch=1945 retired=211 issue_groups=211 order=ok gpr_mismatch=0 pred_mismatch=0 mem_mismatch=0 check_failures=0 class_violations=0 overflows=0 credit_leaks=0 cor_late=0 channels_used=34/55 violations=0` |
| `spmbank` | `name=spmbank finished=1 cycles=186 from_fetch=155 retired=13 issue_groups=13 order=ok gpr_mismatch=0 pred_mismatch=0 mem_mismatch=0 check_failures=0 class_violations=0 overflows=0 credit_leaks=0 cor_late=0 channels_used=28/55 violations=0` |
| `srd` | `name=srd finished=1 cycles=70 from_fetch=39 retired=6 issue_groups=6 order=ok gpr_mismatch=0 pred_mismatch=0 mem_mismatch=0 check_failures=0 class_violations=0 overflows=0 credit_leaks=0 cor_late=0 channels_used=29/55 violations=0` |
| `stall` | `name=stall finished=1 cycles=556 from_fetch=525 retired=116 issue_groups=116 order=ok gpr_mismatch=0 pred_mismatch=0 mem_mismatch=0 check_failures=0 class_violations=0 overflows=0 credit_leaks=0 cor_late=0 channels_used=31/55 violations=0` |
| `swap` | `name=swap finished=1 cycles=556 from_fetch=525 retired=174 issue_groups=174 order=ok gpr_mismatch=0 pred_mismatch=0 mem_mismatch=0 check_failures=0 class_violations=0 overflows=0 credit_leaks=0 cor_late=0 channels_used=31/55 violations=0` |
| `transp4` | `name=transp4 finished=1 cycles=1116 from_fetch=1085 retired=976 issue_groups=976 order=ok gpr_mismatch=0 pred_mismatch=0 mem_mismatch=0 check_failures=0 class_violations=0 overflows=0 credit_leaks=0 cor_late=0 channels_used=37/55 violations=0` |
| `unal` | `name=unal finished=1 cycles=137 from_fetch=106 retired=9 issue_groups=9 order=ok gpr_mismatch=0 pred_mismatch=0 mem_mismatch=0 check_failures=0 class_violations=0 overflows=0 credit_leaks=0 cor_late=0 channels_used=32/55 violations=0` |
| `vadd` | `name=vadd finished=1 cycles=158 from_fetch=127 retired=17 issue_groups=17 order=ok gpr_mismatch=0 pred_mismatch=0 mem_mismatch=0 check_failures=0 class_violations=0 overflows=0 credit_leaks=0 cor_late=0 channels_used=33/55 violations=0` |
| `vadd4` | `name=vadd4 finished=1 cycles=204 from_fetch=173 retired=68 issue_groups=68 order=ok gpr_mismatch=0 pred_mismatch=0 mem_mismatch=0 check_failures=0 class_violations=0 overflows=0 credit_leaks=0 cor_late=0 channels_used=33/55 violations=0` |
| `vaddslow` | `name=vaddslow finished=1 cycles=547 from_fetch=516 retired=17 issue_groups=17 order=ok gpr_mismatch=0 pred_mismatch=0 mem_mismatch=0 check_failures=0 class_violations=0 overflows=0 credit_leaks=0 cor_late=0 channels_used=33/55 violations=0` |

## Manifest of release/

```
8df44b78456df33feefb2f2c2f6b444f8c6dc231b6bc260b95cc28a446799555  release/kernels/addrhigh.by_instr.json.gz
85e3321763c0738174b7389b8922202281c7e3036d8e6a282b430a0c79e824f6  release/kernels/addrhigh.by_unit.json.gz
7f4025bfdc4a9e67d17c349cc2031239027d3a614a0080c15e41212d388f6c80  release/kernels/addrhigh.ccvtrace
d188a13da323dee296f6ad49abd1a00b75ea59792469e9b1428c440acd27f4f1  release/kernels/addrhigh.log
569f2e22883fad5f0956c57ec734e6afbdd4b8a854e50277425172d6c0cbd766  release/kernels/addrhigh.oracle.jsonl
a98c656ebd85c6eca67121290ad724296a3b1e2075c95d21e4e49176414de1bc  release/kernels/addrhigh.sv-hosted.log
fdf05a21b8e2f633bf1762387759f685dffafe71b32f0dfe4b60ace1d1647053  release/kernels/addrlimit.by_instr.json
939d6b115a1bc45b8e75c394811a9aa84b1fb504faed4cc318d2f53cd6131e43  release/kernels/addrlimit.by_unit.json
f8287904c415dfd8f4cf0ec4a8dcdb95ef81669e365fea28a62d9f2feaa3ac8f  release/kernels/addrlimit.ccvtrace
2601caaea99b2bf4f608c2b9d2317603315571028937a17cc4314f545672835f  release/kernels/addrlimit.log
bc660b0b40359a2c5a2478cb0eb4950b73fd22db50ea76b80052bc195a1920f4  release/kernels/addrlimit.oracle.jsonl
7f544bbe9f778eaf7ec14047fdb95b55de7fcd282df26e959a7485d6300f5b04  release/kernels/addrlimit.sv-hosted.log
e7abe7817b399a7c2517f35ab48166e57586a5f46b99d90f11550210332bc0fd  release/kernels/addrneg.by_instr.json
55ad70974dc8a9ea0533a37b55ae47f2ab3280b5eeb9e4f5f56b2a2d355031f6  release/kernels/addrneg.by_unit.json
34b171591ba4b885fa0d843ce2817d49eb6638f478e426eb5b2947e4aabce7cc  release/kernels/addrneg.ccvtrace
cb07e7d61ff57a65eee26593ad82530df254e308192a2dc53bd7334a267f9047  release/kernels/addrneg.log
16f5b0707ae44492a1efd67bb9dd38a7e79a7bbd354fa9207b9e7d150ff2f107  release/kernels/addrneg.oracle.jsonl
21eb262477134c7097e42ba675082b5222dc3fe368dccf78f9b7f01e036fae83  release/kernels/addrneg.sv-hosted.log
f2c8b709cbb3a0f7bf3c59f314f71ca324d89fa3b9cffd6f089cf960403a8b0a  release/kernels/atom.by_instr.json.gz
e7c49475689af30a1728468eebd6e99b4a1523951a2f74e4155b60d95fbdc144  release/kernels/atom.by_unit.json.gz
51878459999e6a8143a9c939d03f13cffb2bcc3133bb489ea2a99a6e129ae17a  release/kernels/atom.ccvtrace
99a8ac1abe46096f4ba29d3230893df3a57804ca75f2b6cc9bab04561efaaae8  release/kernels/atom.log
504f5b6e9d25114dc35f2c70b21bb7b3f3c508c691de12dc0e87d12a74285361  release/kernels/atom.oracle.jsonl
8b95c61385db7e1e2611f420050421f15a64795efa824f1cb00f27ee9d0e1d70  release/kernels/atom.sv-hosted.log
512cb3eebaf9dafbbbf4dc94b503b6b45cdafee2ca3350b820f1c2a32c199bb3  release/kernels/atomf.by_instr.json.gz
6dea00abb27e4cbf22575fe73cb2bdb1a52cac494573b424378a87a642d60161  release/kernels/atomf.by_unit.json.gz
c92618b4ca499739a0e52243245224f7df3dc31ccd8e86a8504d3bde9c6b280d  release/kernels/atomf.ccvtrace
a73a92943f9c5795127a3c0b5c1903ed4e59fa8c4a5bcb79209c81a3476fbc9c  release/kernels/atomf.log
cfd1179edf4061a33ab2f75d7a6dec61decfe629000198189a7bfc2647b34238  release/kernels/atomf.oracle.jsonl
529128111fe1219b344d658dc2639ee901f0bed3d3eac99b963e57156786c0cc  release/kernels/atomf.sv-hosted.log
1ce4a18797c0b79e91403119052f49b94df93e5acd1c2037c899ee630c19b0a9  release/kernels/borrow.by_instr.json.gz
78cd3547aaacb6cccad52d2bbc8c6069a3d415e35d9f2a7ef9938cb78f97a7f7  release/kernels/borrow.by_unit.json.gz
f47ba0ff76f39020aec6e50deb887c83af18cb9efde597aa3d2ebc7261eb3139  release/kernels/borrow.ccvtrace
c3d024f391d0e65117fcedb685bccadc5401855d7721ab046a343ab09a9d4bb1  release/kernels/borrow.log
4c565e1ce0b3baee36e158694b32c8defb5cd662b2f9af75cb5d8c26cb1168ed  release/kernels/borrow.oracle.jsonl
586bbfce61b2a727d56d9723aea6dd289134f5724ddc4714429be92bc9f5e2ae  release/kernels/borrow.sv-hosted.log
e46b9d1ebf2bd5e5930b665fa24c653338ff1f95908da9cfa3f3eded5e4c5c5e  release/kernels/brs.by_instr.json.gz
2adcbad7d6f919ac72b3cbbafdbd76e1692ff483bdc573204de3a8450e16dc7c  release/kernels/brs.by_unit.json.gz
0efbd34762b9bb839d84507973259b9161e0b6b94498eb217ab8eb280dacf7b3  release/kernels/brs.ccvtrace
fde89de0803e0cd1d0ab0f335c4ab24e713bacd0314dcbb0795f27dbe07bbadc  release/kernels/brs.log
e3c1cb3379580cf1aae44e8ddc8e846ef6fd661a573cfe0a8d4444b18a14dc56  release/kernels/brs.oracle.jsonl
269ccae9b3ee3fcde607726b37b86a29c65b3c1702d9856b79531e44a268dd19  release/kernels/brs.sv-hosted.log
e0fd78cede61738638998ef1bb1fbf39ec96ef68609cbb4315ddc9a8e5d58152  release/kernels/byp.by_instr.json.gz
608b6832c5ee4064189b222c86983e5949db56f460298c74af3766fb593e5482  release/kernels/byp.by_unit.json.gz
eeaeecbeffcfabb26607ba4cd6b679e552bee7dc964f95f3f62f7662d3bf9781  release/kernels/byp.ccvtrace
e24483d1f6045db4572b0878fe87b7301d5c3c3fbca3efb4d1d6f5ec82aff466  release/kernels/byp.log
5a03dfa4f3603fef49f1e3639e74e34152ca3ca5ef8e41eb959f8323040fa2d5  release/kernels/byp.oracle.jsonl
0f3bb164347cad8e52ddef889bad290e1e4558884e1abb5873a4151845b34bbf  release/kernels/byp.sv-hosted.log
539f9c5cca73be40ec23c1b948a93313055458ac4b29f42f8f3a1f7499ed295b  release/kernels/callret.by_instr.json.gz
572d8c1c41bc65e9ef6dd9f7c38be889a185b68968e73b5735bb5b4b94214c06  release/kernels/callret.by_unit.json.gz
485f5f7c964b7718cdf5f6475c30219443e9a079bfcab6718359dd789900a2c6  release/kernels/callret.ccvtrace
547fc1318d0d1c4f7a1ac5e325c26da0bc202c8a8ad51e2685b4d94b423bcb64  release/kernels/callret.log
9b1d1b50b527f732362f837250aa2f26dabf3e76e16a4794856ebd8f105635b8  release/kernels/callret.oracle.jsonl
464fa2a82a4dfa0454ff5599f6e4a872c0662077125fb6d961b53062bf513f28  release/kernels/callret.sv-hosted.log
6665a98e85728800097c04d1d719f2ccec8a94a1d77dc16efac6c2e54601e8ee  release/kernels/cas.by_instr.json.gz
0357acaf9a24d9a038b97d9245ab15153e1ab59a23e56a26f8d73cbfeffd6240  release/kernels/cas.by_unit.json.gz
19ca0d1b967f3d4b5ec6b979125ad1b2f5a3964472905a0b9e3b4204f3c646b1  release/kernels/cas.ccvtrace
9c315bdd9d4f8712096ab1f8f9dde645b5f4bd3ac3a9e1c45e15c0027d4b4124  release/kernels/cas.log
0ab31a9443336fe5d08e1a5fa5fcba3bc279b19022f7c5007908d39d8ef39536  release/kernels/cas.oracle.jsonl
f44b0bd76f65eb256a26a096121df3954074c23c0fbb1e733606419dcd9b8b6d  release/kernels/cas.sv-hosted.log
f13c72dec33991bbb63a430fe2382d459c6c2cf78af85fc222c4cfdd129b5fc4  release/kernels/chains.by_instr.json.gz
a7b0b31c0e345e29de3e0c82d190edeb72058e4909b1e916fed119658a6831a3  release/kernels/chains.by_unit.json.gz
b47e10902de830c337bf591bfc2daf06098880741b67957d8e8dd9c45208dc56  release/kernels/chains.ccvtrace
8d3f3d205ff9d2f9ec4b1b9153332062b1ccc2e37048430fd6fb5465c8a6adb5  release/kernels/chains.log
26a4cc5c5524c7219d8706c2582c80357dea60be9d6ffdec99dac7d0365e2264  release/kernels/chains.oracle.jsonl
b3a1c97243a3368152c3c0f01db8c03002c79580355489ff739823b84261b497  release/kernels/chains.sv-hosted.log
d53281abfb55c48fc8524256c7f373270a2048ffdcfd6eb3f318390258e1a4ed  release/kernels/coll.by_instr.json.gz
c2f21e04393673b66efb0db77aadfe74c31679a68971e476ca171a6bde63b386  release/kernels/coll.by_unit.json.gz
9b2defbca3a81f102a07f1fb1a9473253e58da6ab1e7375a8d81f4d1fe098bae  release/kernels/coll.ccvtrace
9a42fccf43093b9a678988d3c33fd7bade69270a538c61adff15a02b4b801fd9  release/kernels/coll.log
dd718d23c88df5dc7d92b055d8542865aa0e029118486af127312a8a578cfcbc  release/kernels/coll.oracle.jsonl
882789a301ad4309af34f88acded94a3c9da8b6d7755fe0bda757b4e2f8a5ee5  release/kernels/coll.sv-hosted.log
9d4033138fdbc98a5148836533d1bb31f639fb6317602794aa9dfefd01d52e88  release/kernels/div.by_instr.json.gz
e419f983f32372bc33bfcca085c79ace16d624408be4a184fe42b315a1aa06ac  release/kernels/div.by_unit.json.gz
182346c5baad147767effbea67248ccbc6e5c35582f0590ab266ce10e6e9dbc8  release/kernels/div.ccvtrace
f96c31a039f22248349177f56cc28abde17125b635030abadd5726d01dbfadbb  release/kernels/div.log
71a567b85cf85622631490187563de9a5661099c78a590adff4ed0a0c3d24c16  release/kernels/div.oracle.jsonl
eea326326531c3e54b4b2826a4d46aaa0a4eccab209d3a65eff75a7f1d173e59  release/kernels/div.sv-hosted.log
cc51c88be02c49798480d4ad7410f62965ba147a3603beea29908d46ea602558  release/kernels/divchw.by_instr.json.gz
7c93b33e0b13b74c223e662bd5d8b0c39500c16fd38ea737f1cc521dc5afd84b  release/kernels/divchw.by_unit.json.gz
4471a48e9f9555ec3ff526316b30290fb0ff75d28588185a2a52382020681eb5  release/kernels/divchw.ccvtrace
e686e48b43b1625bb3f158f5a9ade85a9cd789adaaa348d446f1fa4007d99b8f  release/kernels/divchw.log
58a541797f7a2df0a1c7528ae6a3edec212db90c7d3eb20656806f38b5c10b3d  release/kernels/divchw.oracle.jsonl
92936848e744c7ed32d2d25213ea4b1c94da222adddb649a9bca50264b815a2d  release/kernels/divchw.sv-hosted.log
c5d8ac9b7f563882fb2cfa738fb66253d15b004830ce8683c27e230403278269  release/kernels/divtail.by_instr.json.gz
04eaa725a35563de1348178a788cb5dda6305ea26492f6589c0b0d458ea0992d  release/kernels/divtail.by_unit.json.gz
2ade202d8c5fc071687f18239b0573f55461d1606452ff6daa16db3738442f2c  release/kernels/divtail.ccvtrace
4a032dbea80b2e7c78314abe431fc8544595ea430d15f98e405f2117d747de44  release/kernels/divtail.log
75f11a75c9b3b336e446140af4579f05b46c363a76b7aab3ec88154a07ba097d  release/kernels/divtail.oracle.jsonl
8e7d7ebd445010bfd606e2e886551621527478deb52293aa01e08a7caf7d9669  release/kernels/divtail.sv-hosted.log
f42f71625c3b8d101191ad8073244b42d231ddda4d895dd511d2f34a1d1cf4d3  release/kernels/divtail2.by_instr.json.gz
eddf9421ff942f243412cc42b5581979d94dff550561c8dbc19ef55c797a144e  release/kernels/divtail2.by_unit.json.gz
e27413844716e2c50ee7f69833576c60a6fb7bc226660dfe365677c387affdcd  release/kernels/divtail2.ccvtrace
455cbb6be770850b69bd5b3ba1be7a2a27eedd5814c2e68a0b53ce98999e71ac  release/kernels/divtail2.log
b2db6b05eb6cf4a0a7677e31d0c6c2952d5cab49d353f0bb1883fe0b2a20ed14  release/kernels/divtail2.oracle.jsonl
a4e8509521d0dee864e871e53bedb3f9d2f9db8ad81d40ccbb2a9be30a93e46c  release/kernels/divtail2.sv-hosted.log
f634c829dd69a6dadc8d0f5ce33f337f02a188fa6039340fa75021cf7e855510  release/kernels/fence.by_instr.json
c6df076e8accf704dd1be71fab73c5570e95bbe937c4b6ce367c48683bedb6b1  release/kernels/fence.by_unit.json.gz
937d3193ab570b47d1b195b8243ed02ee198d22a5792ddebd2ade6682955a956  release/kernels/fence.ccvtrace
e6a3f2fb6ec5d8a6d3fd2e51dc88d561d5654beca1079c310bc31c50baeefc9c  release/kernels/fence.log
d1d40317f6cf5bfb430cda1f9c0ef676609e59cabe2a11623c42ffbeca93142b  release/kernels/fence.oracle.jsonl
68a7951ca88446ca448c6ed72d0e921ec5f4d8b36466854a345547ed5271d248  release/kernels/fence.sv-hosted.log
ccf1a7200ca55ccea453d7b42895e0b68c9a0840cb4257a096b4637265645087  release/kernels/gather.by_instr.json.gz
cb04b52786f515255f4894d67bf742d5486686e487908f89199bd255adb54969  release/kernels/gather.by_unit.json.gz
579bce9756a2a49ebd6423bf0c53491401251d7e21bde54947c3723f31ce67c5  release/kernels/gather.ccvtrace
5db99c84e45b0c4f67a4a937e9cf7487a2da1e3172fa76ca9945d9f29bd5d628  release/kernels/gather.log
0413e781d8d6ff578c64eb1f800b7931e66f676d5cdabb97b94a4033e6037662  release/kernels/gather.oracle.jsonl
c25c6ba772e8cdd2b51c6ff169139966ca350ebb466302cb3cc9babf6d78225f  release/kernels/gather.sv-hosted.log
e08dc918a2742fd20e79937353a533e16e3afd4ab4d641c3136d3283754b7bc8  release/kernels/hit.by_instr.json.gz
5f3b85d54448e655720c89c8751c0b4ab4d03c4b72e519bdc0803437a9daa002  release/kernels/hit.by_unit.json.gz
49e386589dfc6f8d5371bd908ca1002022ca80542b41ab51820ce7562e08e6dd  release/kernels/hit.ccvtrace
a83a1c8aa88a83d54109d036eab37920506a581a3404333f0d854e82c131ddf4  release/kernels/hit.log
7ba9603e0088d9164de6528f16ef6a7fa9ce5821c8c12b52cbb3734e39b9fd52  release/kernels/hit.oracle.jsonl
a821ec756a6d617d686ad5eaa9be88aee6820f8b01847fffe669a88fefdb5778  release/kernels/hit.sv-hosted.log
e9b3067221fd582d3006720258bd60397dbf052bbe6d6c6811ac023054d3e81c  release/kernels/lanectx.by_instr.json.gz
ed602040eb8a121538565c2779fa9ac8db6e774f1d4e1ca2749886de19196b53  release/kernels/lanectx.by_unit.json.gz
bfdf212b12cc609da0b786f23ac7a775a880d9c7078d0dc1cb4ea29899191bf0  release/kernels/lanectx.ccvtrace
63907d9716f545d7b7bc0388c2f570abb6a2b5983562fe99254f8382fb376d87  release/kernels/lanectx.log
888551babf540db8e3025b82e65ca655013f93eba3c8a65689d069d52a7e6039  release/kernels/lanectx.oracle.jsonl
8901c3874934b4206f693ea5b640c3704708f4137177bb71e18e0cf1b629127a  release/kernels/lanectx.sv-hosted.log
067d8de655c366c1a9e9bab434adb4c6647695c5d6d5a6e88c0d3f9946084dc1  release/kernels/lanectx2.by_instr.json.gz
4b26a2dd65e0496747dd17e10035e7b92a568f61de5c9a52001cfca058f7867d  release/kernels/lanectx2.by_unit.json.gz
d1c46c94b6b1d1fb2f239a45a58cc2a129820423a056374ffd66eda0640423d9  release/kernels/lanectx2.ccvtrace
2a50d44c3399be12b6677359d626a6601348f5b9863e5e102dcbf73a174016d2  release/kernels/lanectx2.log
45c13056dff5c73ed0c9ece56cc36f929bf335322193c7d5eb38710b1d1dfb02  release/kernels/lanectx2.oracle.jsonl
2300bd5f2b6400b96b1250351f0f9dbe1962b2ba888e477614bf10c4d6fa6b04  release/kernels/lanectx2.sv-hosted.log
621b22b61f777d94b97f3b4144d239a14443d337460be984d529b7593a805778  release/kernels/late.by_instr.json.gz
9746e322f179549564212ee79845a938cec3bc82f39e69c2ce9ae1ea3b71787c  release/kernels/late.by_unit.json.gz
e2e8c328a671570ef9221f3e2a55944f588eb875ffbbf334e4fe20682a6c3ecc  release/kernels/late.ccvtrace
1daa79ecbe1d5934f858a0b0addda2778ebcdd6e334221ca64fd59d83411c829  release/kernels/late.log
86084f6bd747a2cf32acbc0ebd96ebd3e4ef2d8d9e21be49e3ae49290d7927f3  release/kernels/late.oracle.jsonl
a7eaa446947718168824a36c6d32f1b450ce3efe66a1af83c1e72315b9e22c2f  release/kernels/late.sv-hosted.log
3b0d4f9a398ef81717998088bd54e493f49ccbb649b52128e963ae0906ab659b  release/kernels/ldpar.by_instr.json.gz
fc3acf515c6e9409fca70839a00e889521e6e7e30c1eae2887a38b8189827de0  release/kernels/ldpar.by_unit.json.gz
8b80f0644ce546519b2907f4eaa06ccf24dacfb174a0929ae5b16e41cca94a47  release/kernels/ldpar.ccvtrace
29466161123b95f5461b944da79406e70878159431f7abd46955d976e3f9cc00  release/kernels/ldpar.log
8ac08538e9c807637babd61b31e340f7461878ada31f0c0b83cd66331cfaf486  release/kernels/ldpar.oracle.jsonl
997d2a2b6a10905ba59149b0957d281e124526aca5d4cedb1325f459a41b7822  release/kernels/ldpar.sv-hosted.log
8e78153105cb10f95248df2d00ae84fb43d34cdbe3c831421e03401b848893c4  release/kernels/lnorm1.by_instr.json.gz
8b22c4bbb7634259dca3df0dd9edc6383ca8610252d75175ec3084b4ef772a45  release/kernels/lnorm1.by_unit.json.gz
5a1fb2f1c1df24b661430c0b1fff617e90148350d09e52fd054d1beb65d44d5e  release/kernels/lnorm1.ccvtrace
0d68c02fbb3ae957004ac7fc7fde9de803ec3cecbf62f32fbc1e25467bf9675d  release/kernels/lnorm1.log
a8d85811af988a1b9fc00db1517300af3d93ec8e589e403d3b9113fa9e0ffc86  release/kernels/lnorm1.oracle.jsonl
bdf5e2b05444fdc078ac947b4fb1da18d6670e524bb331987348d71e59cb55d9  release/kernels/lnorm1.sv-hosted.log
171a7f89b2e84b811cd17484fa235ace810d999c10955c44eeee783ff5828c4d  release/kernels/localsp.by_instr.json.gz
b1398d0b2b41cfa0f1f5f44eb822831ece270aa30dceca949955a288334843d5  release/kernels/localsp.by_unit.json.gz
bd78e05909ec69aa774a212478967f904e3257a1e5cdf3edc7689cab7f3da1a7  release/kernels/localsp.ccvtrace
c03841aa7f8c45609c1c2b708f72d017d671120831e6467579ac5c0e12422659  release/kernels/localsp.log
55e3c9f36e7f7d38c0ddd38903aff4bb4509ae862015c592e6b937ea258042ca  release/kernels/localsp.oracle.jsonl
93a87c5004ad59b0b7fc274e8b9a1222ec92e4ebeb346567b0e9f7297dfe5cff  release/kernels/localsp.sv-hosted.log
eeb1cc8308d569d8ba6fe6f65f866c44d3678b9623faee0c94e67fd47e0d9b3a  release/kernels/loop.by_instr.json.gz
61b3adf0a82e2ee6483226b549eb6922518b0662037c96c2a1a83979586c144d  release/kernels/loop.by_unit.json.gz
05599f989c0d60da6bbedde81701aa56ae1c2a56bbb878bbddeca9829b14e167  release/kernels/loop.ccvtrace
38cd3396460d72c10df25bd0ce36f34878949d68a99291e4abd3ef577e4573a6  release/kernels/loop.log
03ce5920c06c93e93516d8e53c3f7169f14e3593de204eacceffc0b8a3e32016  release/kernels/loop.oracle.jsonl
a739e777bb46af3b5e2e1c9bb37ac43aa2475807df9b7d04c559c4f7b7cdd188  release/kernels/loop.sv-hosted.log
1f77023694bd9816a98227fa6fa2534b48de2b730ba5bbf4cafbcb05c3838af1  release/kernels/merge.by_instr.json.gz
75ec201f2870e3dd8323bda6f5586c36dba21019aafc5c77be06e84138035436  release/kernels/merge.by_unit.json.gz
2f43408ff2d9fff8512adaa9e24aae50158636b35dd1778e07d3a003df283170  release/kernels/merge.ccvtrace
0642768dff1f7f8a9f371cdf7b183509b780fdfc50ca2791a0d3450ea9f4c845  release/kernels/merge.log
f96d28815f8756b1f5a45ded53e6170883d2dfa10f9eef0d14b8050b1318164a  release/kernels/merge.oracle.jsonl
be6a04557e28947a5b479de2a5846bd226191147185deff8667f75565e41b315  release/kernels/merge.sv-hosted.log
0e8197d35e457560f957030eb6767714c21fb9b3741fdf3573778d48692d04f0  release/kernels/missrun.by_instr.json.gz
0b4cccc0d49e4a5f2bac3aebf091d3fff8dbf6aeaa5a2999902592f43ce3fda4  release/kernels/missrun.by_unit.json.gz
9b9e962099b538ac683b0f9ee8745062f8642478667cdaed17c5bc301fa4b958  release/kernels/missrun.ccvtrace
78a26b3f437e1fe3afb5256b2ab0d42c955f1901462b5fbead062cb4805be804  release/kernels/missrun.log
531bdaf281e5590774bd2775427f25e4cc0419cf8e3d5b6999843ffe9ef87258  release/kernels/missrun.oracle.jsonl
e2fb140bfd907503143b9113a4b74931b77bff282ab1afb206ce83ca63ed08cf  release/kernels/missrun.sv-hosted.log
4becc21546981314a25ed4c3f2e1faef77bf54f6cd7e5f6bcc731f7874028631  release/kernels/mload.by_instr.json.gz
2903994792d3a0983ae8ba2c60095d6e3b5ebeb0897aaf4b1a29e20a72b821b9  release/kernels/mload.by_unit.json.gz
063b6cceb78f323833fbe9eb0ae6ddab36c499214e9f131972fb171c4a6635c1  release/kernels/mload.ccvtrace
9fc3bc7b25ca9569da146872a305deed1c0f2a637d7fec6129586e5bdb852452  release/kernels/mload.log
8000e477b9a95dfb9f0af964e8346acb9d36f1358fd06ffc4ff7cf599d2b8868  release/kernels/mload.oracle.jsonl
083c3016c3909f9e2504aec063d2fbb41361b592ebcb05bd3cb2c604c7ce7991  release/kernels/mload.sv-hosted.log
778ee083e9f1752842c394b2ce7411e03b6c1f4b113423b8ebc49b34a00248c6  release/kernels/mlp.by_instr.json.gz
c82ba17828b913d3410413e03f6cb6520b2407cadd4406f77106d2af4c837d6b  release/kernels/mlp.by_unit.json.gz
0dcc5e88bf12bbd8f4e8841fb80413dd37c8213957342197e5cf7b89748182e1  release/kernels/mlp.ccvtrace
91b4ef9fbec8234236cda533f0c69d6ecdf958bf0071132766743179cb18ea39  release/kernels/mlp.log
138d282f88d56c8ad648a91af0a983254b55d9fa22942c00d47b327f516a6e44  release/kernels/mlp.oracle.jsonl
228f9a0751b0e33ab2af361c539579a2f30f5f24e92dd8de822cbe74458d751c  release/kernels/mlp.sv-hosted.log
6e087e2d7ffff20edcbbdb5af3dde791cf62ffa2d9c0b02c4c39235c824286d7  release/kernels/mwmiss.by_instr.json.gz
35c3060d34e06e1034114aa2ea9f715dc982e13b641417a3e5b3c5b054a16bed  release/kernels/mwmiss.by_unit.json.gz
a4bdf907a65868c13182ce6e067e1dd7099fcb30b095e752d15512c05ecfbb58  release/kernels/mwmiss.ccvtrace
451ede22ff06e711081337a9fcc8059c0878535b8e4c6c3094d907be51350b55  release/kernels/mwmiss.log
8abe8e8997456a2a6711ee72da54d854b24e20abbdab28e4b7271c0d28418de8  release/kernels/mwmiss.oracle.jsonl
f97e6157f34f904095f0171274e35c56b0d0385d2ff20c81adeafe0042add840  release/kernels/mwmiss.sv-hosted.log
33559f0d59d71a212265bf0b03059c99d2a07d6dd4bbc2c966cd61ec60988809  release/kernels/narrowadd.by_instr.json.gz
28c8e34959d6f23f9be03565d1739941b0b321f1bc3435bebe6fe66a92cd66ca  release/kernels/narrowadd.by_unit.json.gz
e2aa3a9a060a4ea9aff1dea86739a679757392bbdd64b520c0cd72275fc6410e  release/kernels/narrowadd.ccvtrace
d72f59a088484011a60c4677ee6ec06af471de4c8061257966cd62d865a121b8  release/kernels/narrowadd.log
40a2cf629853dd404bb06b4a07e35abde3d12efc13f26ffe28f923daf2994574  release/kernels/narrowadd.oracle.jsonl
9c8ae1fd04bed48077d4466c39452bfc6b4f38f2487896cbea98ea33fe231874  release/kernels/narrowadd.sv-hosted.log
f89225b3d23535e7a90b30627d71ecddbd42020723dc6b43ee7ffc3ff83e7ae8  release/kernels/pguard.by_instr.json.gz
0cdccc6ceceb17ed70b51ef452ebb56d572b36695176b989392fb9f843dc2719  release/kernels/pguard.by_unit.json.gz
7ea87af30b8cfa9e54b7754dd440ef60896a0330a3e1f42f3983de79cf02bd5d  release/kernels/pguard.ccvtrace
36a8e73893e37a93d594b8ae73b09da3357a747637dd3819fbea26dea18d5caa  release/kernels/pguard.log
690e56f1cb8d97cbf67124b7dff3ad0a90cb8981814cd1709cf0cd0e035b3bd9  release/kernels/pguard.oracle.jsonl
a5776af181c36e4f74e81b2b2e53ee4599ed667a821830ce777e5576b1df5b85  release/kernels/pguard.sv-hosted.log
c9fd0c682ef429dd9597c39d60311887b228ed4a9d786e66ca926d82b7b460f2  release/kernels/plog.by_instr.json.gz
0cbe4d7ed2132f75cc6d880bad00e075a6e5ae4dc978099cb7c537d10d890bb0  release/kernels/plog.by_unit.json.gz
ce4aec9a797ce6e24a9082c3c4e22e4cc45d2bd6d9cf47ffadb3e8da5e251eb9  release/kernels/plog.ccvtrace
fdac345ea363af737ad946144b80db833fd50ec242049ceeb8418057a57ffad6  release/kernels/plog.log
0c99915e2da60f4670da00504a6371d7d17701d4431e733a3ff8fa98a2030d6a  release/kernels/plog.oracle.jsonl
38e4df7f4f9b55629f63a198ba2867d7261dc005209ee2cb91900fbc50c2f301  release/kernels/plog.sv-hosted.log
5264788ff1450c6682af62e49b75f0cd290d953e7da2971bef2a589e7fba4626  release/kernels/pmovdiv.by_instr.json.gz
9dd3bfa4d895af0b64ffbfafec7fc30787a78de10ab8f121d3305368abd35d78  release/kernels/pmovdiv.by_unit.json.gz
4fe481c67584f36b72d1f510fbace5f75fa34ca8d76713e16d393f8638f099f9  release/kernels/pmovdiv.ccvtrace
6a390bd9d495b5f2a68f393b5a0e1799379092a482f2900a3202335373391038  release/kernels/pmovdiv.log
7bc646cff6166a51bdce03d7c1b7209e871f0a91d743083a9b910a80bcd0b33f  release/kernels/pmovdiv.oracle.jsonl
198bdcc68d4c2b8fcf667cb791ed351dd41f43e1c54e5aa5fbca63e4ed1aefc1  release/kernels/pmovdiv.sv-hosted.log
f863316d4c643bc7dd0f56213d55a7533c854ec4c0a932e2a41fd6f77dc41a10  release/kernels/predlane.by_instr.json.gz
62af9a08059ca63fdb75babfda00deea8c634694d1f70510608503b5a9eaefeb  release/kernels/predlane.by_unit.json.gz
43ffb5fd93c492e608093ee380fd91f02047a73d0d5bca90f37879a3a9b027e6  release/kernels/predlane.ccvtrace
479e3a3c99ea93e23bfe746c9f8dcd8e967aa4a4902d2fc4603d0fc5617f5de0  release/kernels/predlane.log
c45f4177b9e84fc8a6e36b13534a0c7636eb30a3f8531847100ce5e23bf404b1  release/kernels/predlane.oracle.jsonl
e2356a2f7d22fcf5bf5547515ee7e19cc5aef1b6e0a8f45a34a2ad21b56d6d1a  release/kernels/predlane.sv-hosted.log
20b7a109bcc99e0975f522e2015848e9e97cde91d2c206bbafef88e83bf38887  release/kernels/predmerge.by_instr.json.gz
f4699292e88f11cd145104d4672dc2482bd77934c235ef01678fb61c9421bcc6  release/kernels/predmerge.by_unit.json.gz
d773aa91af7cfa2400e67801a569c10b730b800848cf39adce1a17e4661f83d2  release/kernels/predmerge.ccvtrace
0519f238adaf3a6e08771d0e2a16b56ad9c6c879708d8498869806605d09e994  release/kernels/predmerge.log
6c737c49434bcd08e3e0814c8b1dbf15c586ae74f7929ba3148ddcee2c62c845  release/kernels/predmerge.oracle.jsonl
ad21800054193a6553c3734d8934b7bb60db7a1d35db5715696e2d089f7e06df  release/kernels/predmerge.sv-hosted.log
afe727507026e3909c54948fe220c15bbe5dc1c7b97821b86a62fd8cffca66b0  release/kernels/predspill.by_instr.json.gz
44ba33b0a31d86164ce2cf82b3f9935ba76b07b716cf059524131432d6efd38b  release/kernels/predspill.by_unit.json.gz
ef5cd45c3aca2c80a0f934209300878095623cf9fdccac71b72455d598a5cc83  release/kernels/predspill.ccvtrace
b74453365f9626a9409e6d640e53ab7e82192753459b98c362b79e73c7c443a4  release/kernels/predspill.log
b7c84c6478117ffa0f06da0e6ad1e4628e2683426a7911080810e78e06a5242e  release/kernels/predspill.oracle.jsonl
8520789de5c27e68465419b7f4813c0a160ff37b3f344bcc84dbc929a67288c3  release/kernels/predspill.sv-hosted.log
1a62843197943a9a6b167bc9c00d57e45c70489c74e3b9369ff9adccfacdf9ba  release/kernels/predswap.by_instr.json.gz
f1c07aa0be2ec7fa15e0ebb0dfbdccb0809c03f26b665ee2f8ddffe00f07bf14  release/kernels/predswap.by_unit.json.gz
6dde3956ce0082953ad263d923ba60c127a1dbf50b2927cd690a854dd840bac6  release/kernels/predswap.ccvtrace
69ed6f207b3cad4ac61f32b06735e6878b4f50c1802b141d303d23f863f31011  release/kernels/predswap.log
a6d4f7ed517553816d889c7c9eeb6bcfd1f6c973fbf682ecb69f3c2de619f7bb  release/kernels/predswap.oracle.jsonl
48b9875c9df0132c8658311b107dce8e8ae725665a0c611eaf80618cbb077811  release/kernels/predswap.sv-hosted.log
00041695f4d374baee30030509b61c5e7464e567a19043a4c3c183d6cbcc73f6  release/kernels/privwin.by_instr.json.gz
0811d5c23f7b7eb2c157e3f04108f3bfae12a721c2d020b12d22dcd51ad42e0f  release/kernels/privwin.by_unit.json.gz
eeb608f6ab0b70400d080d3c510895c3591c8cb7f98b9664b7579dfc372fdb75  release/kernels/privwin.ccvtrace
7079891685b3eecf6e7d505c709120bf9a469665823581448d93ca8d86be2ff3  release/kernels/privwin.log
861f686fc4480363472908d679d8815e8c957d768e7ab32c826930527b0fb7a8  release/kernels/privwin.oracle.jsonl
bc0ee29fb475d23a5e7676958f2b3899546be30c4d9e42b7d28999262f7f6488  release/kernels/privwin.sv-hosted.log
626fcca293dfd4b20b969ad140c7df335da5136c7bd6e7d60cd33735fa808647  release/kernels/provswap.by_instr.json.gz
31ffacfc771538615cea3f832a622c80c6c7b5fc24f87d2d7cc356a7c50daf3c  release/kernels/provswap.by_unit.json.gz
5770ff85f63ab02333da388b746df768fb8608a837f5d910b09c6867fac6d8e4  release/kernels/provswap.ccvtrace
c38536ad24c43db7a89cc7345baff7e6b97972a9b5152f0120a06bfa0b2fec77  release/kernels/provswap.log
c9c32a793d54cc7401477f582487f7e8b345b2669a75337b8d6327120d98e5dc  release/kernels/provswap.oracle.jsonl
405e6ac4f3a103f087e8c23b21bb02265e0182635e799aa50afb833a86c339f7  release/kernels/provswap.sv-hosted.log
8ec769c805ce1232a3b1b9028119006b474bdcb3dab1398070f9cdc3a8528c21  release/kernels/retmiss.by_instr.json.gz
a9824bc7472a83de9aa47d8ea231da1a0865c6214a45b1a43d02ae80d05422f2  release/kernels/retmiss.by_unit.json.gz
45e974b9faa7643f7c6b02d61ea31b5f19f83a182e6edae29a5cc9969e3de614  release/kernels/retmiss.ccvtrace
16cf0e54f6bbc6d5341141943710efe6adc74b24d9d7a8518a979e96c59dd574  release/kernels/retmiss.log
e5ef8538e838c6cff7febfc679dd091cf5e002f82d34f1009b1948ce22bc3649  release/kernels/retmiss.oracle.jsonl
ca6d539320417faa1ca2f0f609b5fc4eec99166951ef0c102a9ceda8cedc06fb  release/kernels/retmiss.sv-hosted.log
d45b064f90b496adbbbf3be694a8cc4f6af4ea41825c8bb83b0c4042da5a369a  release/kernels/roconst.by_instr.json
b38b6900712bfd3ada68a6b3627c4ea3fe521aef042fc47dd43dfb23bb1283cf  release/kernels/roconst.by_unit.json
f3713f83ec2f195b035033bdb47cfd76ef95bbcac2a975d18c8e17e3b3ccda49  release/kernels/roconst.ccvtrace
3a8dbca0fe64dc3e35a8d8b8ab3c8131a6e1fb9fe115ce6f593786597c144408  release/kernels/roconst.log
8087c0671de620162881aecd38cd6114b78e7be6bd71201e3ec02c9a2e2e750e  release/kernels/roconst.oracle.jsonl
71e6e0fb31ea77b15b4085b76d709c7132bfbe1bbec0b1b233e4d2a7295e01a1  release/kernels/roconst.sv-hosted.log
7d213047dc11229803ff907bc5a2192cad3a16f993fe7f5ae66bdd5e6ec74442  release/kernels/rogated.by_instr.json
538b2dcd3f13bd6c16224e6133e485a707f1360c1c13b42c9ffb7f36bdd9ba71  release/kernels/rogated.by_unit.json.gz
e0022bd67a6d629144891b56607860fafa98ac1de5fa80dc411be11a44c9a890  release/kernels/rogated.ccvtrace
6ff2c0de9a74cc2c88ce562712e3c17e249f4b9bbdf2ff359bf78e9da4fcda33  release/kernels/rogated.log
7cd02bd4cceec5a044d6b4d6a80df1e68ed0ae71b0b2a953143636d5b809ea6c  release/kernels/rogated.oracle.jsonl
292aa368c7a1051159a97a7524656218705815ba28b58db9003ddb85c6221bcb  release/kernels/rogated.sv-hosted.log
90d031c092c9580acafa1c4f13823911844db6b51f0512ab2b79c12abc2db3f3  release/kernels/rokill.by_instr.json.gz
461acbe03301c4ccad79d77d3402bccdd86738220d7fe1e918b18415ddc125ee  release/kernels/rokill.by_unit.json.gz
cb434c89178bda63feb85c508e8cbd1b00bffd6b69525ab858d2b11b6cf16c17  release/kernels/rokill.ccvtrace
ea61cbe4274fdafe115b14e163dd1b38a709532704e4afc20a8bfd30b4f41add  release/kernels/rokill.log
94efcef96af469a512d346ce61623980fe86383188eaebd55120f716db596f14  release/kernels/rokill.oracle.jsonl
97ca376f72181d89d59483883205b750b2f828f46ebd94d848cc967cf0ac72a1  release/kernels/rokill.sv-hosted.log
e3623ccded9b858436609221b6b3faeab0d3c448a2f2c5d42b60b8ee1dd78216  release/kernels/rokilllane.by_instr.json.gz
b66a4e9bbeaad542a653b043bdc8de39a1e434923249d826e14952887f040bab  release/kernels/rokilllane.by_unit.json.gz
dba628a43540510e90493dcf402203d99b3542ad6dd5a94033f0f5f1309c0d42  release/kernels/rokilllane.ccvtrace
b3c1c89ea1e6f2d421cffa5d9cf6096947f962c930ba06a48245483fac507ef8  release/kernels/rokilllane.log
f5ca6e666eff2f44894df74a291b43b3c0e7be0a63a47d795fdefd7b22016f45  release/kernels/rokilllane.oracle.jsonl
3ba18e98351c62019c86c3a2d698987486f74671a8b3ff2a3766afc673cf7dcc  release/kernels/rokilllane.sv-hosted.log
f8fe604241644b224e6431d16e4fad889c99826b82f49205e4c9014b9ae62e8a  release/kernels/rolaunch.by_instr.json
12e5281971b0a06ca95d953aa22a6d6b481d8fee948f50ab777c87877757fe46  release/kernels/rolaunch.by_unit.json
32fbf77dc8fb17f0113b068b5a00568b6ea97be3ad8e5bd1c69b7cae2f04a946  release/kernels/rolaunch.ccvtrace
17eae3d99453e99b558374444cbf9f8f6c2600910a4f13fd722a13caf49fc391  release/kernels/rolaunch.log
e7dad585c3e70615de04330fd03f4f282c29a005dc1732a35655fb261d51139e  release/kernels/rolaunch.oracle.jsonl
3e30c32578d1a9972b21672ac7e4ab195b99179e3ea444996da18890e369e891  release/kernels/rolaunch.sv-hosted.log
d45b064f90b496adbbbf3be694a8cc4f6af4ea41825c8bb83b0c4042da5a369a  release/kernels/rolimit.by_instr.json
e8822066a61bf10f59647aa7240a3044f25d2eba55ac5f7ebacbf1901974dd8f  release/kernels/rolimit.by_unit.json
0e8db555321feaf0fded659de3d7ab35b3dadb15ccef4bf8dabfaec2e87a5563  release/kernels/rolimit.ccvtrace
690b62f8e82f8a12b84214d2020eb8c2d16af9b6a6199944cc903b1f214f389e  release/kernels/rolimit.log
1c5bc0cb8e8b2e69505fb5a551a16d5d10c56f232b88da7a27e336ad7d962de2  release/kernels/rolimit.oracle.jsonl
a58659c8e667fd145dd0332f81675bcfea901930ea6d07835d84d12329a4aae1  release/kernels/rolimit.sv-hosted.log
cff5f59151c47ae3d30c54261fb5029cf69475b1b2f0fa6715859d98e71a4777  release/kernels/roload.by_instr.json.gz
570c103c26b020c25efbabe527661898c0dd25f8d175c6db63d57f86398a29fc  release/kernels/roload.by_unit.json.gz
d030ac67b1dcde0dcc21aad32d53d84415c253aeea08ff0736e55b0472fc9a6e  release/kernels/roload.ccvtrace
22ff90c31abf892048dae7d01af2653e0bba3d91f7eefdae5b1f00a17407a031  release/kernels/roload.log
f7c1309cc9764769fb5803f6fd0f2f5e1eb418f2d23fbe5e17cf5f9106869fdf  release/kernels/roload.oracle.jsonl
89e6a6e9422e3b8f3d867abd6d81ca426f0204c1178a241f8fad5c0d1224bd8f  release/kernels/roload.sv-hosted.log
6100212704ed09e5df1c30e4073895ba3ea126bba1f863bcc31fc84c987b5c18  release/kernels/rope.by_instr.json.gz
f29cd4d5a3e663ee0c69330e3ca1dba73d9779a5aac0a9e13b77f3ff4ade4a9c  release/kernels/rope.by_unit.json.gz
fc7ff8922f97156780744ae5b935ea98329ade9e9e7d72f2e04d088ffb65160f  release/kernels/rope.ccvtrace
c2f7c391be76fe57acc637a18b19e14697903adf4e20962531961890974139bd  release/kernels/rope.log
d55f9efae392dc8877c102c01c0810e7654b666b6ede386328108164c6cf88f3  release/kernels/rope.oracle.jsonl
7c97c33177fb97066293324c91c60866c025101610f765c08faef20b8c7da89a  release/kernels/rope.sv-hosted.log
0e0222ec8a02e47db776a73138605f4223a955217926efb038b163eea789f819  release/kernels/ropediv.by_instr.json.gz
dc8295176dae35269464fa38d30af77da1a0df58254d65ebceca9cf117b2bdbe  release/kernels/ropediv.by_unit.json.gz
68a770673c6707faa7e6c6c87ba328fabbd4ee5bc1a1daad0064d679fa7c0c89  release/kernels/ropediv.ccvtrace
fea00e8bf23ba451fc44a507b6c7de64df095a8ce2d4f4d20fbfeba54975a630  release/kernels/ropediv.log
10c0ec6ec18b7b44638c790033109198c079d07c1537bf193353ccedd00a920f  release/kernels/ropediv.oracle.jsonl
cf7f88b1ba0c427d3e04a5e8012f91126aef60c2a5b945a128af2640f4c6d9f0  release/kernels/ropediv.sv-hosted.log
462a74cc7a1fae6b459031c36f61e81905361d4b9f927c53711dc68d54124aca  release/kernels/sel.by_instr.json.gz
f675e0a31fadb93860be5c7f47cf292ee9729929e994c25b8d8f866605475bcd  release/kernels/sel.by_unit.json.gz
33a33114b5167306fc24ee447399ba293a8568ed59ddc2c9e307b97a3df3638f  release/kernels/sel.ccvtrace
c9c85eb35ca8618e716376041ac183a741bb46124ed4a49d06637dca9342f8e2  release/kernels/sel.log
87f6a81e8afa004c8039bf2f61c90176fcf29ab29bb17ac44aa016a5cc8438fe  release/kernels/sel.oracle.jsonl
04e4a557203713d1288d15e34333d19ca7cdef96d94ba1cbb8493f952fb811be  release/kernels/sel.sv-hosted.log
82c3129622ed0bc0cc6f745fb436ebfeb049c37ae9753e4cec0bf9a469346346  release/kernels/sized.by_instr.json.gz
32ebb2a99a23f3c1f026c3247846a406189bc94c63a2a16dde1915ec2e87b7a0  release/kernels/sized.by_unit.json.gz
19d51ff5b6b8460534f510632660d9c1fc7ad3ee8ff7d9b60ea78660a12e7e17  release/kernels/sized.ccvtrace
348d09e46e42c0133c3fed97dec0cc356ea5ae2588ae0539dad4de16ba393e1f  release/kernels/sized.log
36d903ba1618bd1faa437c9812a6ee6c0c966a63196c796267d74bf2695ebc3d  release/kernels/sized.oracle.jsonl
2fcfcb08af7d9d20eb0462c0917f5db4b05761fb78176da5367031c7d1f67ff6  release/kernels/sized.sv-hosted.log
8dfa43961f0046d34e729e0f9928f3aa6dcfd1488aa618a7642470c9432d28b9  release/kernels/slotform.by_instr.json.gz
866b0c00da27fd68007ec73caa732e1a0b0d2bf130a4571b0664579667694b8e  release/kernels/slotform.by_unit.json.gz
140f5579dac1c3408bb35a5f3bdbf309b6d065e2aaab8c64937909a79222face  release/kernels/slotform.ccvtrace
33d4c85159771243e8012d4d2802694643345bb26c9a994aa1bfc75059c5fd80  release/kernels/slotform.log
8b61db7419b18cea8a646fb628218447e72e84a18a9891ffb73b441736138ab9  release/kernels/slotform.oracle.jsonl
882829b3ee164ad4043555f502f9200b26b8b24c07b81f0784cd7afa8763238d  release/kernels/slotform.sv-hosted.log
1b29617908bd8ce0dbd67a99828f7e4c27389c166efc045f77c4751cc7264d15  release/kernels/spinwait.by_instr.json.gz
e143c63a9f873a9bfcf4ccbc63aad353ec257b437662c72f8ddbde1f299271e4  release/kernels/spinwait.by_unit.json.gz
ae2744f200137504e4e16953e8b2e58f8055d8e728e2cb6ed8e4e996da5a28f2  release/kernels/spinwait.ccvtrace
285d630ce34fabd0d8bd1a796c7043da45033ceb5018ad55b459e80ebcfdff51  release/kernels/spinwait.log
868920637236c878b33779bd450439466fc3626996a3164573dc11d437d5c709  release/kernels/spinwait.oracle.jsonl
7bc119095d55505f176e26307919838fe9d47c76740960f8de9b4003397f39bc  release/kernels/spinwait.sv-hosted.log
b0ba3bb1d43ee6dfb0bc5a51a9bfe69938d8a63a9ed7cc446ce4a5c68c609177  release/kernels/spmbank.by_instr.json.gz
f300eb516974b03476527ad3ed6ae0593fbb3de1626f3daa7e5014306cbee2ee  release/kernels/spmbank.by_unit.json.gz
c9e0541d73a86ace0be2c7140b58c219c67cdc59ea3c535408d630297cbaaec6  release/kernels/spmbank.ccvtrace
42557d5759bd562f8d661b42e41efe639f216a1607b0f52145012e5d8d61a576  release/kernels/spmbank.log
3af490cc37d7a92dbe719b57de216b648536eb301ff9d13de9a39f50d150d725  release/kernels/spmbank.oracle.jsonl
c564684c4b87b01f2743d13fb187c7422fc20d0d38f4023b6a75d0c0ffbb2cc4  release/kernels/spmbank.sv-hosted.log
46740b360cdfcef3a675493f6150a8a0a93e942cb1c196b34d07369828711805  release/kernels/srd.by_instr.json.gz
bc81e402a1eaec61560704c5e888de23c09944a8a20b2e40d4eeb3f736f2de26  release/kernels/srd.by_unit.json.gz
f255c02a28c53c4b57a6b17bccf73852f4dfb2d06486b63be7fd69e6f3ef22dd  release/kernels/srd.ccvtrace
5e92d83bb1bef4aaf765a4b87019bbfb93e7974c037864bf12c5ee1b2ca4a90c  release/kernels/srd.log
b08eb5e3673cac7eebb8b72af5ed3783c8e70a9e96592e76bf3722551bc79473  release/kernels/srd.oracle.jsonl
5511f9de2b49008017a3b63e08dfa5e5dfde6339a8410bd00672357ba1ba7e46  release/kernels/srd.sv-hosted.log
4b39846350bfac73c3b32ba2b8c0338c46f5fcd88e5a399ed6f1b4e677bbb323  release/kernels/stall.by_instr.json.gz
3f9af77eed79af0e9488b94ca19fdff12af21bf9c88eb1d9af15efe59778664d  release/kernels/stall.by_unit.json.gz
0b1d90e2b2a1a6a0982b2fb7ffbf4faf290767e6f55e1ad096d003702d2e26ea  release/kernels/stall.ccvtrace
e226193e535a7ee5074c7cd156f6b983ce594d1fb689dfef3c2395b87e60c89d  release/kernels/stall.log
500db2c482b07a0706583422cd68878301d0146c1f872ccc1f11bfdcf5c993ef  release/kernels/stall.oracle.jsonl
a497120a815607b0f3739230f15b4725c6d79a0d87216c1aab5d4cb319048382  release/kernels/stall.sv-hosted.log
82e9c2de98a28ad7b8e492d66c3cdc750acea00805728836b8942a6e08ce958d  release/kernels/swap.by_instr.json.gz
ff15426cf2f056f4918f2c07867e53bafbe2c97a76a20f6fce36f5f51103fbce  release/kernels/swap.by_unit.json.gz
d4f9a6abd33a375605faaab1f07f1de4820d583ff4a9a9ba229e1cbda4f8a28f  release/kernels/swap.ccvtrace
17d665eca634f68f3e57a0ff9243950479f212b069c8e643cbb01e4a89c07eab  release/kernels/swap.log
3658a26316c1ff7bc1744304a42f736e930fcde2865c8913e6cc67a22ce96667  release/kernels/swap.oracle.jsonl
2af1333dccb2931a7b2220af790423b7e47ff9ca39fead53f07bf1f4e8fe2cde  release/kernels/swap.sv-hosted.log
e49518cb8c76e79167dba4fe956a86f8694f51165f47479c3c44f64fd8a92680  release/kernels/transp4.by_instr.json.gz
dd6343e7f501d26f3691d72502f02b3fcbf31616890f8c0cf868916273d05649  release/kernels/transp4.by_unit.json.gz
f3aa58c6b823e6d3415eb0f60bfba601890efdffb7b20e25f9d8f81c37a06054  release/kernels/transp4.ccvtrace
b6835b3995160ec1f7ffdf363728dbe89b2369ee0234633673554f911d982a1f  release/kernels/transp4.log
06396ace3ac19677fd39c700e408606e5bdbacb24997d663bbe8872e63dd74fc  release/kernels/transp4.oracle.jsonl
3d8ec630f74ce1028e0daf503e25451b56d1ffcd71672d568dc1f968fc1b4df5  release/kernels/transp4.sv-hosted.log
83656ab93eae1eba164b795f0551ad86ff29e0dc4d55c34098912ae538240e6a  release/kernels/unal.by_instr.json.gz
960666a86d5c6ef7f0a8b80c2f068abd71a10d63dd5ed976e728af2f3b656d41  release/kernels/unal.by_unit.json.gz
f0cc8a6483da7e1547d81822745f9513824861f37c3e59f25922c8df4895b09b  release/kernels/unal.ccvtrace
73cef6003f06c7a06cbd8dff05d46e32447275d222a44b380e6553a28d48edef  release/kernels/unal.log
c3d484bb160657a563df983d9a2532eac27f556636617960aa1e72183ac2b299  release/kernels/unal.oracle.jsonl
8cab2ee90bd3b9a5c6a1f377b231c3ed4b7103160f80fa79e709b71b431f815e  release/kernels/unal.sv-hosted.log
cf2e01f2135402ad3f1f64c4414dac35cfe13a2c20c6407744ca61608776535d  release/kernels/vadd.by_instr.json.gz
9e5addb76c8858fd32775e941b271830eb5bd516fef835263c78e365e83e123c  release/kernels/vadd.by_unit.json.gz
d60247e80c3d58b0b971253c140a1b93ebf7a3763f11e23443a9108a3199dd49  release/kernels/vadd.ccvtrace
ff777e4dbfa68b04069d091254550c7725243e226258bbc7e172ba2368e65ff2  release/kernels/vadd.log
0276b6d0611a4bbcdc004ab3987214aea138245bc7217504147331689a9c0880  release/kernels/vadd.oracle.jsonl
f754c237d6544b17b013a44c3caa407a1e1a5cf20296b2354d0dc7934e3d8295  release/kernels/vadd.sv-hosted.log
89bccbd783a34253b17a702751c6d8090319b4b852b46b85d3cebf729014aa0c  release/kernels/vadd4.by_instr.json.gz
ca275a01f7245c2386ed6228666fb853130529747f7b240375a32646e99d7952  release/kernels/vadd4.by_unit.json.gz
12c2c2f0d29aeeb32d687a26b8adee42605196396852a4fee675c92870f17252  release/kernels/vadd4.ccvtrace
17f69a7bef5852a6271fb360f709ee08a0ae943d42bd8cbe829ff5e6de094a13  release/kernels/vadd4.log
225aa18fc9f38aa9ad615aa11de254337d59fa705877553d873062c68366e0db  release/kernels/vadd4.oracle.jsonl
41387c09290ce45ef6b0711bdf708c979f510594e51a4fc5d8d9a7800048448d  release/kernels/vadd4.sv-hosted.log
9d58522d10bee2d8bd893a15081141a4cda216a38e0701a72a0bebd29466fc84  release/kernels/vaddslow.by_instr.json.gz
54bdcaec3833413b53cb336743b0c9978705a67373a020560f544f2a049d27dc  release/kernels/vaddslow.by_unit.json.gz
360619055225f8897e5f13dc2ce9fc418dcbe487f70c2adb3c0452eb50912e4c  release/kernels/vaddslow.ccvtrace
d633b387442348f4a78b6110c450afa6abfcba8427cc163b7e8ac91310f4bbb2  release/kernels/vaddslow.log
e9e6218e8b8450e9f9ff6b39d659c994a1e51c527a0c5bd10d18b5658ae0e344  release/kernels/vaddslow.oracle.jsonl
e5ade275fba82b5dbfd8c5e0715ffd6b59be4e814976340cd2905e5684e0cecc  release/kernels/vaddslow.sv-hosted.log
51f6f6c0656a9e4f9aad604e928c2ba46854f5f644c013180f105a35958a9755  release/verify.log
56b3d8627d79d397ca06dfb57060015391cb95e52e925d1f09a4b2a7f4147127  release/wiring.txt
```
