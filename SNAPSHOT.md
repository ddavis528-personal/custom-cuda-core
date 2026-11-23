# Snapshot snapshot-2026-11-23-4e3dda6

**A generated, read-only snapshot. Do not edit or merge it.** The source
is `ti-d33m` at `4e3dda643abeaa5a646f383f9af7791dde5d04d4`, and this branch is rebuilt from source by
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
| Source | `ti-d33m` @ `4e3dda643abeaa5a646f383f9af7791dde5d04d4` |
| Built | 2026-11-23 (UTC) |
| Gate | `tools/verify.sh`: PASS |
| Compiler snapshot | custom-cuda-complier `release` @ `a293afe7d7873fb5d3fac70d8deca980e119b19f` (source `b9ae2c9d5d3b838d5d982d842b558e2d290185ea`) |
| Verilator | Verilator 5.052 2026-09-05 rev v5.052 |
| Icarus | Icarus Verilog version 12.0 (stable) () |
| Yosys | Yosys 0.33 (git sha1 2584903a060) |

## Kernels

| Kernel | Result |
|---|---|
| `addrhigh` | `name=addrhigh finished=1 cycles=83 from_fetch=52 retired=5 issue_groups=6 order=ok gpr_mismatch=0 pred_mismatch=0 mem_mismatch=0 check_failures=0 class_violations=0 overflows=0 credit_leaks=0 cor_late=0 channels_used=26/57 violations=0` |
| `addrlimit` | `name=addrlimit finished=1 cycles=82 from_fetch=51 retired=5 issue_groups=5 order=ok gpr_mismatch=0 pred_mismatch=0 mem_mismatch=0 check_failures=0 class_violations=0 overflows=0 credit_leaks=0 cor_late=0 channels_used=28/57 violations=0` |
| `addrneg` | `name=addrneg finished=1 cycles=81 from_fetch=50 retired=1 issue_groups=2 order=ok gpr_mismatch=0 pred_mismatch=0 mem_mismatch=0 check_failures=0 class_violations=0 overflows=0 credit_leaks=0 cor_late=0 channels_used=23/57 violations=0` |
| `atom` | `name=atom finished=1 cycles=8732 from_fetch=8701 retired=29 issue_groups=29 order=ok gpr_mismatch=0 pred_mismatch=0 mem_mismatch=0 check_failures=0 class_violations=0 overflows=0 credit_leaks=0 cor_late=0 channels_used=33/57 violations=0` |
| `atomf` | `name=atomf finished=1 cycles=4640 from_fetch=4609 retired=12 issue_groups=12 order=ok gpr_mismatch=0 pred_mismatch=0 mem_mismatch=0 check_failures=0 class_violations=0 overflows=0 credit_leaks=0 cor_late=0 channels_used=35/57 violations=0` |
| `borrow` | `name=borrow finished=1 cycles=99 from_fetch=68 retired=7 issue_groups=7 order=ok gpr_mismatch=0 pred_mismatch=0 mem_mismatch=0 check_failures=0 class_violations=0 overflows=0 credit_leaks=0 cor_late=0 channels_used=21/57 violations=0` |
| `brs` | `name=brs finished=1 cycles=99 from_fetch=68 retired=12 issue_groups=12 order=ok gpr_mismatch=0 pred_mismatch=0 mem_mismatch=0 check_failures=0 class_violations=0 overflows=0 credit_leaks=0 cor_late=0 channels_used=23/57 violations=0` |
| `byp` | `name=byp finished=1 cycles=118 from_fetch=87 retired=14 issue_groups=14 order=ok gpr_mismatch=0 pred_mismatch=0 mem_mismatch=0 check_failures=0 class_violations=0 overflows=0 credit_leaks=0 cor_late=0 channels_used=32/57 violations=0` |
| `callret` | `name=callret finished=1 cycles=265 from_fetch=234 retired=40 issue_groups=40 order=ok gpr_mismatch=0 pred_mismatch=0 mem_mismatch=0 check_failures=0 class_violations=0 overflows=0 credit_leaks=0 cor_late=0 channels_used=31/57 violations=0` |
| `cas` | `name=cas finished=1 cycles=6972 from_fetch=6941 retired=56 issue_groups=56 order=ok gpr_mismatch=0 pred_mismatch=0 mem_mismatch=0 check_failures=0 class_violations=0 overflows=0 credit_leaks=0 cor_late=0 channels_used=33/57 violations=0` |
| `chains` | `name=chains finished=1 cycles=96 from_fetch=65 retired=29 issue_groups=29 order=ok gpr_mismatch=0 pred_mismatch=0 mem_mismatch=0 check_failures=0 class_violations=0 overflows=0 credit_leaks=0 cor_late=0 channels_used=21/57 violations=0` |
| `coll` | `name=coll finished=1 cycles=78 from_fetch=47 retired=24 issue_groups=24 order=ok gpr_mismatch=0 pred_mismatch=0 mem_mismatch=0 check_failures=0 class_violations=0 overflows=0 credit_leaks=0 cor_late=0 channels_used=21/57 violations=0` |
| `div` | `name=div finished=1 cycles=978 from_fetch=947 retired=144 issue_groups=144 order=ok gpr_mismatch=0 pred_mismatch=0 mem_mismatch=0 check_failures=0 class_violations=0 overflows=0 credit_leaks=0 cor_late=0 channels_used=23/57 violations=0` |
| `divchw` | `name=divchw finished=1 cycles=111 from_fetch=80 retired=5 issue_groups=6 order=ok gpr_mismatch=0 pred_mismatch=0 mem_mismatch=0 check_failures=0 class_violations=0 overflows=0 credit_leaks=0 cor_late=0 channels_used=22/57 violations=0` |
| `divtail` | `name=divtail finished=1 cycles=642 from_fetch=611 retired=96 issue_groups=96 order=ok gpr_mismatch=0 pred_mismatch=0 mem_mismatch=0 check_failures=0 class_violations=0 overflows=0 credit_leaks=0 cor_late=0 channels_used=23/57 violations=0` |
| `divtail2` | `name=divtail2 finished=1 cycles=1517 from_fetch=1486 retired=366 issue_groups=366 order=ok gpr_mismatch=0 pred_mismatch=0 mem_mismatch=0 check_failures=0 class_violations=0 overflows=0 credit_leaks=0 cor_late=0 channels_used=23/57 violations=0` |
| `fence` | `name=fence finished=1 cycles=83 from_fetch=52 retired=7 issue_groups=7 order=ok gpr_mismatch=0 pred_mismatch=0 mem_mismatch=0 check_failures=0 class_violations=0 overflows=0 credit_leaks=0 cor_late=0 channels_used=31/57 violations=0` |
| `gather` | `name=gather finished=1 cycles=265 from_fetch=234 retired=16 issue_groups=16 order=ok gpr_mismatch=0 pred_mismatch=0 mem_mismatch=0 check_failures=0 class_violations=0 overflows=0 credit_leaks=0 cor_late=0 channels_used=33/57 violations=0` |
| `hit` | `name=hit finished=1 cycles=219 from_fetch=188 retired=17 issue_groups=17 order=ok gpr_mismatch=0 pred_mismatch=0 mem_mismatch=0 check_failures=0 class_violations=0 overflows=0 credit_leaks=0 cor_late=0 channels_used=32/57 violations=0` |
| `lanectx` | `name=lanectx finished=1 cycles=70 from_fetch=39 retired=10 issue_groups=10 order=ok gpr_mismatch=0 pred_mismatch=0 mem_mismatch=0 check_failures=0 class_violations=0 overflows=0 credit_leaks=0 cor_late=0 channels_used=30/57 violations=0` |
| `lanectx2` | `name=lanectx2 finished=1 cycles=70 from_fetch=39 retired=10 issue_groups=10 order=ok gpr_mismatch=0 pred_mismatch=0 mem_mismatch=0 check_failures=0 class_violations=0 overflows=0 credit_leaks=0 cor_late=0 channels_used=30/57 violations=0` |
| `late` | `name=late finished=1 cycles=169 from_fetch=138 retired=16 issue_groups=16 order=ok gpr_mismatch=0 pred_mismatch=0 mem_mismatch=0 check_failures=0 class_violations=0 overflows=0 credit_leaks=0 cor_late=0 channels_used=32/57 violations=0` |
| `ldpar` | `name=ldpar finished=1 cycles=154 from_fetch=123 retired=17 issue_groups=17 order=ok gpr_mismatch=0 pred_mismatch=0 mem_mismatch=0 check_failures=0 class_violations=0 overflows=0 credit_leaks=0 cor_late=0 channels_used=32/57 violations=0` |
| `lnorm1` | `name=lnorm1 finished=1 cycles=2531 from_fetch=2500 retired=526 issue_groups=526 order=ok gpr_mismatch=0 pred_mismatch=0 mem_mismatch=0 check_failures=0 class_violations=0 overflows=0 credit_leaks=0 cor_late=0 channels_used=38/57 violations=0` |
| `localsp` | `name=localsp finished=1 cycles=2175 from_fetch=2144 retired=40 issue_groups=40 order=ok gpr_mismatch=0 pred_mismatch=0 mem_mismatch=0 check_failures=0 class_violations=0 overflows=0 credit_leaks=0 cor_late=0 channels_used=32/57 violations=0` |
| `loop` | `name=loop finished=1 cycles=2842 from_fetch=2811 retired=407 issue_groups=407 order=ok gpr_mismatch=0 pred_mismatch=0 mem_mismatch=0 check_failures=0 class_violations=0 overflows=0 credit_leaks=0 cor_late=0 channels_used=23/57 violations=0` |
| `merge` | `name=merge finished=1 cycles=71 from_fetch=40 retired=9 issue_groups=9 order=ok gpr_mismatch=0 pred_mismatch=0 mem_mismatch=0 check_failures=0 class_violations=0 overflows=0 credit_leaks=0 cor_late=0 channels_used=21/57 violations=0` |
| `missrun` | `name=missrun finished=1 cycles=121 from_fetch=90 retired=28 issue_groups=28 order=ok gpr_mismatch=0 pred_mismatch=0 mem_mismatch=0 check_failures=0 class_violations=0 overflows=0 credit_leaks=0 cor_late=0 channels_used=32/57 violations=0` |
| `mload` | `name=mload finished=1 cycles=111 from_fetch=80 retired=11 issue_groups=11 order=ok gpr_mismatch=0 pred_mismatch=0 mem_mismatch=0 check_failures=0 class_violations=0 overflows=0 credit_leaks=0 cor_late=0 channels_used=32/57 violations=0` |
| `mlp` | `name=mlp finished=1 cycles=126 from_fetch=95 retired=21 issue_groups=21 order=ok gpr_mismatch=0 pred_mismatch=0 mem_mismatch=0 check_failures=0 class_violations=0 overflows=0 credit_leaks=0 cor_late=0 channels_used=32/57 violations=0` |
| `mwmiss` | `name=mwmiss finished=1 cycles=129 from_fetch=98 retired=88 issue_groups=88 order=ok gpr_mismatch=0 pred_mismatch=0 mem_mismatch=0 check_failures=0 class_violations=0 overflows=0 credit_leaks=0 cor_late=0 channels_used=32/57 violations=0` |
| `narrowadd` | `name=narrowadd finished=1 cycles=227 from_fetch=196 retired=21 issue_groups=21 order=ok gpr_mismatch=0 pred_mismatch=0 mem_mismatch=0 check_failures=0 class_violations=0 overflows=0 credit_leaks=0 cor_late=0 channels_used=33/57 violations=0` |
| `pgcross` | `name=pgcross finished=1 cycles=162 from_fetch=131 retired=8 issue_groups=8 order=ok gpr_mismatch=0 pred_mismatch=0 mem_mismatch=0 check_failures=0 class_violations=0 overflows=0 credit_leaks=0 cor_late=0 channels_used=32/57 violations=0` |
| `pguard` | `name=pguard finished=1 cycles=87 from_fetch=56 retired=12 issue_groups=12 order=ok gpr_mismatch=0 pred_mismatch=0 mem_mismatch=0 check_failures=0 class_violations=0 overflows=0 credit_leaks=0 cor_late=0 channels_used=30/57 violations=0` |
| `plog` | `name=plog finished=1 cycles=71 from_fetch=40 retired=11 issue_groups=11 order=ok gpr_mismatch=0 pred_mismatch=0 mem_mismatch=0 check_failures=0 class_violations=0 overflows=0 credit_leaks=0 cor_late=0 channels_used=21/57 violations=0` |
| `pmovdiv` | `name=pmovdiv finished=1 cycles=104 from_fetch=73 retired=12 issue_groups=12 order=ok gpr_mismatch=0 pred_mismatch=0 mem_mismatch=0 check_failures=0 class_violations=0 overflows=0 credit_leaks=0 cor_late=0 channels_used=22/57 violations=0` |
| `predlane` | `name=predlane finished=1 cycles=928 from_fetch=897 retired=10 issue_groups=10 order=ok gpr_mismatch=0 pred_mismatch=0 mem_mismatch=0 check_failures=0 class_violations=0 overflows=0 credit_leaks=0 cor_late=0 channels_used=32/57 violations=0` |
| `predmerge` | `name=predmerge finished=1 cycles=940 from_fetch=909 retired=9 issue_groups=9 order=ok gpr_mismatch=0 pred_mismatch=0 mem_mismatch=0 check_failures=0 class_violations=0 overflows=0 credit_leaks=0 cor_late=0 channels_used=34/57 violations=0` |
| `predspill` | `name=predspill finished=1 cycles=968 from_fetch=937 retired=12 issue_groups=12 order=ok gpr_mismatch=0 pred_mismatch=0 mem_mismatch=0 check_failures=0 class_violations=0 overflows=0 credit_leaks=0 cor_late=0 channels_used=32/57 violations=0` |
| `predswap` | `name=predswap finished=1 cycles=1186 from_fetch=1155 retired=46 issue_groups=46 order=ok gpr_mismatch=0 pred_mismatch=0 mem_mismatch=0 check_failures=0 class_violations=0 overflows=0 credit_leaks=0 cor_late=0 channels_used=34/57 violations=0` |
| `privwin` | `name=privwin finished=1 cycles=1161 from_fetch=1130 retired=52 issue_groups=52 order=ok gpr_mismatch=0 pred_mismatch=0 mem_mismatch=0 check_failures=0 class_violations=0 overflows=0 credit_leaks=0 cor_late=0 channels_used=35/57 violations=0` |
| `provswap` | `name=provswap finished=1 cycles=2286 from_fetch=2255 retired=978 issue_groups=978 order=ok gpr_mismatch=0 pred_mismatch=0 mem_mismatch=0 check_failures=0 class_violations=0 overflows=0 credit_leaks=0 cor_late=0 channels_used=34/57 violations=0` |
| `retmiss` | `name=retmiss finished=1 cycles=184 from_fetch=153 retired=19 issue_groups=19 order=ok gpr_mismatch=0 pred_mismatch=0 mem_mismatch=0 check_failures=0 class_violations=0 overflows=0 credit_leaks=0 cor_late=0 channels_used=34/57 violations=0` |
| `roconst` | `name=roconst finished=1 cycles=76 from_fetch=45 retired=4 issue_groups=5 order=ok gpr_mismatch=0 pred_mismatch=0 mem_mismatch=0 check_failures=0 class_violations=0 overflows=0 credit_leaks=0 cor_late=0 channels_used=26/57 violations=0` |
| `rogated` | `name=rogated finished=1 cycles=96 from_fetch=65 retired=7 issue_groups=8 order=ok gpr_mismatch=0 pred_mismatch=0 mem_mismatch=0 check_failures=0 class_violations=0 overflows=0 credit_leaks=0 cor_late=0 channels_used=26/57 violations=0` |
| `rokill` | `name=rokill finished=1 cycles=104 from_fetch=73 retired=41 issue_groups=4536 order=ok gpr_mismatch=0 pred_mismatch=0 mem_mismatch=0 check_failures=0 class_violations=0 overflows=0 credit_leaks=0 cor_late=0 channels_used=27/57 violations=0` |
| `rokilllane` | `name=rokilllane finished=1 cycles=1214 from_fetch=1183 retired=924 issue_groups=10674 order=ok gpr_mismatch=0 pred_mismatch=0 mem_mismatch=0 check_failures=0 class_violations=0 overflows=0 credit_leaks=0 cor_late=0 channels_used=27/57 violations=0` |
| `rolaunch` | `name=rolaunch finished=1 cycles=74 from_fetch=43 retired=4 issue_groups=5 order=ok gpr_mismatch=0 pred_mismatch=0 mem_mismatch=0 check_failures=0 class_violations=0 overflows=0 credit_leaks=0 cor_late=0 channels_used=24/57 violations=0` |
| `rolimit` | `name=rolimit finished=1 cycles=76 from_fetch=45 retired=4 issue_groups=5 order=ok gpr_mismatch=0 pred_mismatch=0 mem_mismatch=0 check_failures=0 class_violations=0 overflows=0 credit_leaks=0 cor_late=0 channels_used=26/57 violations=0` |
| `roload` | `name=roload finished=1 cycles=105 from_fetch=74 retired=8 issue_groups=8 order=ok gpr_mismatch=0 pred_mismatch=0 mem_mismatch=0 check_failures=0 class_violations=0 overflows=0 credit_leaks=0 cor_late=0 channels_used=32/57 violations=0` |
| `rope` | `name=rope finished=1 cycles=677 from_fetch=646 retired=354 issue_groups=354 order=ok gpr_mismatch=0 pred_mismatch=0 mem_mismatch=0 check_failures=0 class_violations=0 overflows=0 credit_leaks=0 cor_late=0 channels_used=35/57 violations=0` |
| `ropediv` | `name=ropediv finished=1 cycles=982 from_fetch=951 retired=203 issue_groups=203 order=ok gpr_mismatch=0 pred_mismatch=0 mem_mismatch=0 check_failures=0 class_violations=0 overflows=0 credit_leaks=0 cor_late=0 channels_used=35/57 violations=0` |
| `sel` | `name=sel finished=1 cycles=77 from_fetch=46 retired=8 issue_groups=8 order=ok gpr_mismatch=0 pred_mismatch=0 mem_mismatch=0 check_failures=0 class_violations=0 overflows=0 credit_leaks=0 cor_late=0 channels_used=30/57 violations=0` |
| `sized` | `name=sized finished=1 cycles=987 from_fetch=956 retired=25 issue_groups=25 order=ok gpr_mismatch=0 pred_mismatch=0 mem_mismatch=0 check_failures=0 class_violations=0 overflows=0 credit_leaks=0 cor_late=0 channels_used=33/57 violations=0` |
| `slotform` | `name=slotform finished=1 cycles=4348 from_fetch=4317 retired=12 issue_groups=12 order=ok gpr_mismatch=0 pred_mismatch=0 mem_mismatch=0 check_failures=0 class_violations=0 overflows=0 credit_leaks=0 cor_late=0 channels_used=33/57 violations=0` |
| `spinwait` | `name=spinwait finished=1 cycles=2022 from_fetch=1991 retired=211 issue_groups=211 order=ok gpr_mismatch=0 pred_mismatch=0 mem_mismatch=0 check_failures=0 class_violations=0 overflows=0 credit_leaks=0 cor_late=0 channels_used=35/57 violations=0` |
| `spmbank` | `name=spmbank finished=1 cycles=186 from_fetch=155 retired=13 issue_groups=13 order=ok gpr_mismatch=0 pred_mismatch=0 mem_mismatch=0 check_failures=0 class_violations=0 overflows=0 credit_leaks=0 cor_late=0 channels_used=28/57 violations=0` |
| `srd` | `name=srd finished=1 cycles=70 from_fetch=39 retired=6 issue_groups=6 order=ok gpr_mismatch=0 pred_mismatch=0 mem_mismatch=0 check_failures=0 class_violations=0 overflows=0 credit_leaks=0 cor_late=0 channels_used=30/57 violations=0` |
| `stall` | `name=stall finished=1 cycles=556 from_fetch=525 retired=116 issue_groups=116 order=ok gpr_mismatch=0 pred_mismatch=0 mem_mismatch=0 check_failures=0 class_violations=0 overflows=0 credit_leaks=0 cor_late=0 channels_used=32/57 violations=0` |
| `swap` | `name=swap finished=1 cycles=556 from_fetch=525 retired=174 issue_groups=174 order=ok gpr_mismatch=0 pred_mismatch=0 mem_mismatch=0 check_failures=0 class_violations=0 overflows=0 credit_leaks=0 cor_late=0 channels_used=32/57 violations=0` |
| `transp4` | `name=transp4 finished=1 cycles=1133 from_fetch=1102 retired=976 issue_groups=976 order=ok gpr_mismatch=0 pred_mismatch=0 mem_mismatch=0 check_failures=0 class_violations=0 overflows=0 credit_leaks=0 cor_late=0 channels_used=38/57 violations=0` |
| `unal` | `name=unal finished=1 cycles=137 from_fetch=106 retired=9 issue_groups=9 order=ok gpr_mismatch=0 pred_mismatch=0 mem_mismatch=0 check_failures=0 class_violations=0 overflows=0 credit_leaks=0 cor_late=0 channels_used=33/57 violations=0` |
| `vadd` | `name=vadd finished=1 cycles=158 from_fetch=127 retired=17 issue_groups=17 order=ok gpr_mismatch=0 pred_mismatch=0 mem_mismatch=0 check_failures=0 class_violations=0 overflows=0 credit_leaks=0 cor_late=0 channels_used=34/57 violations=0` |
| `vadd4` | `name=vadd4 finished=1 cycles=204 from_fetch=173 retired=68 issue_groups=68 order=ok gpr_mismatch=0 pred_mismatch=0 mem_mismatch=0 check_failures=0 class_violations=0 overflows=0 credit_leaks=0 cor_late=0 channels_used=34/57 violations=0` |
| `vaddslow` | `name=vaddslow finished=1 cycles=547 from_fetch=516 retired=17 issue_groups=17 order=ok gpr_mismatch=0 pred_mismatch=0 mem_mismatch=0 check_failures=0 class_violations=0 overflows=0 credit_leaks=0 cor_late=0 channels_used=34/57 violations=0` |
| `waypred` | `name=waypred finished=1 cycles=1211 from_fetch=1180 retired=18 issue_groups=18 order=ok gpr_mismatch=0 pred_mismatch=0 mem_mismatch=0 check_failures=0 class_violations=0 overflows=0 credit_leaks=0 cor_late=0 channels_used=32/57 violations=0` |

## Manifest of release/

```
7c67ec24a23b0f753323f6dca1600cc0ebf9393285627bb79409d6c0d4ddc535  release/kernels/addrhigh.by_instr.json.gz
6c6695bfedfb67b9eb2ea3a535bba7196c2020a34befaaf006270755c94064be  release/kernels/addrhigh.by_unit.json.gz
77bc0c3be8e830d8723acdd7c4f9eb29f4078b3115874372bc60e68aa53b7183  release/kernels/addrhigh.ccvtrace
4a748fd2428f8f748bc3385fd0da079cb05b3c4495a6a039d5bbd8768242cce6  release/kernels/addrhigh.log
569f2e22883fad5f0956c57ec734e6afbdd4b8a854e50277425172d6c0cbd766  release/kernels/addrhigh.oracle.jsonl
adc8a78e219beb8e824685233a6b542af4fd4b2a1dd6d7f759a5c0574f2fae1c  release/kernels/addrhigh.sv-hosted.log
8c3c69aeee911c0af65ab248e23004dcfbef9189634476f18c376caa596cf842  release/kernels/addrlimit.by_instr.json
3b35fee568600ef154c0e28928da998f194ab417705d71f582090dddfccd0ef7  release/kernels/addrlimit.by_unit.json
468c0908614c5661e9d860b55a9178899a4477c703f33d0f195813e281cd5610  release/kernels/addrlimit.ccvtrace
f29bc5a6d59f98d72f416219987b9fb54ee515ae49604e2af42c3af85b1bc769  release/kernels/addrlimit.log
bc660b0b40359a2c5a2478cb0eb4950b73fd22db50ea76b80052bc195a1920f4  release/kernels/addrlimit.oracle.jsonl
848f2ce9fdbc262a8602ef01bf2dde10bf7c7d55c1edc6ea83d109cbbaf5e0b5  release/kernels/addrlimit.sv-hosted.log
d5ee993d0a633a3a0837df8a1267138a4a90d71b0f13f2964db1fac129be4751  release/kernels/addrneg.by_instr.json
d4575a0211ba3cad70a041dab45c9876f749ac9173cd91604056151f0cb47c9b  release/kernels/addrneg.by_unit.json
b64cab0cffa732e5e0822d4d5e4704e4625cec46309de4e9af4fa929274a37fb  release/kernels/addrneg.ccvtrace
790335dd5f79e058d5608736614f06f40582b917d8c0b4c8413964aed5f56bd8  release/kernels/addrneg.log
16f5b0707ae44492a1efd67bb9dd38a7e79a7bbd354fa9207b9e7d150ff2f107  release/kernels/addrneg.oracle.jsonl
41b40d0fd8878494dc1395ea0f8ba8f8df94826aad17d37f9063ba43982e131b  release/kernels/addrneg.sv-hosted.log
a8118b484fd07b2891b1f2e0227c4d009f5c42966d52540b7e6cb996e6ed06aa  release/kernels/atom.by_instr.json.gz
64479a6785e284b3808b6687a902b6f98d2bc8a0ec0fb89abf9243fecc27d133  release/kernels/atom.by_unit.json.gz
e52662d078aed7d484789b3150f99f6c99f9b9821d86a5e9bbd8cd5909299165  release/kernels/atom.ccvtrace
665eea1313806fcbc1c9d86557fca3132bc20b9a7a0327933fff8fb546ce6445  release/kernels/atom.log
504f5b6e9d25114dc35f2c70b21bb7b3f3c508c691de12dc0e87d12a74285361  release/kernels/atom.oracle.jsonl
e301d9112bdffa2c99ae9cd6e09471ef892de89b23a2aabb16db35bb7f706e58  release/kernels/atom.sv-hosted.log
ea53f524bf8b493dd17d6d6d492a61deaa8c4b53901ea708651271d979db1a24  release/kernels/atomf.by_instr.json.gz
e1f58044b968acc7f7076b77f3336a3a3c6fb9f30f633765b3746d9d706e72a6  release/kernels/atomf.by_unit.json.gz
e249348e60083200e6314e3614e53460618456d16fdd85e004a0cea8ffd17787  release/kernels/atomf.ccvtrace
8d931b20157a1c7a1e8947919b0f1bce36503b52ab081d44ba947bd939a023ef  release/kernels/atomf.log
cfd1179edf4061a33ab2f75d7a6dec61decfe629000198189a7bfc2647b34238  release/kernels/atomf.oracle.jsonl
bb1c58c1b3ca0bcae5b0c6a7ce74c93b01748be1064a701b32a1ff093a0238d3  release/kernels/atomf.sv-hosted.log
d5d1ad69fe710e1d728e2a575434c2dccd8c1c50d7fdcd78d696784518dc7d49  release/kernels/borrow.by_instr.json.gz
d41d5723df4ee1e38dfee367b25cc5e14d0f092508223258dcca2a62b7e4ff69  release/kernels/borrow.by_unit.json.gz
675e87f1c0e15b984bee253fff4849e79de6b07f83e6e28edfa102cf07f93b18  release/kernels/borrow.ccvtrace
3fe067ff87cedaac70132be811b2678a530601d3b15c2c62c767940bf6c83177  release/kernels/borrow.log
4c565e1ce0b3baee36e158694b32c8defb5cd662b2f9af75cb5d8c26cb1168ed  release/kernels/borrow.oracle.jsonl
ab600f8fabd3dad1dac9ddff7d81c741fc53754e072f3e215df1773148ce088f  release/kernels/borrow.sv-hosted.log
dd6d2b76f820dc2ec3281e69ad0168c6bd624053eb6221f01f863f382edd7231  release/kernels/brs.by_instr.json.gz
7b94406e472f05d9bc5a97dbc5fcaecf418ff6321e1c1208af0b1f74ee7cda96  release/kernels/brs.by_unit.json.gz
dfdc00e3f7e638e036c8544c04704d8c1d4cca764d189ea7aa1e0739036dbfac  release/kernels/brs.ccvtrace
eaf7a33c5651c8a9435b727b76b1da508aa9a5b7824234a55d9bbcfbfa155d2b  release/kernels/brs.log
e3c1cb3379580cf1aae44e8ddc8e846ef6fd661a573cfe0a8d4444b18a14dc56  release/kernels/brs.oracle.jsonl
177482368389232b8aa623fa03189cfb5bbafbb79a77a6e1ab84c261b2983f6a  release/kernels/brs.sv-hosted.log
23d1f4ad54fde897fb49233da6270a468bcbae5f96ff700903da88d1c76d275a  release/kernels/byp.by_instr.json.gz
0a4478f6b9d876b1147ae7e4683f5874715ae2cc79817a6c249997d06f3bf4d1  release/kernels/byp.by_unit.json.gz
1fb04b879fcd06185cbcd79e0db7e22f64c7784eebfcb96b8f923b6e165efa01  release/kernels/byp.ccvtrace
5f133659563ab6b50dcbbcd29849526a0151e1c8e7147a43ec0f57717f8332b9  release/kernels/byp.log
5a03dfa4f3603fef49f1e3639e74e34152ca3ca5ef8e41eb959f8323040fa2d5  release/kernels/byp.oracle.jsonl
001ce7c714a4a92c33f9968b42606f13b9d7a1a0b50250676c468fcace1c81ec  release/kernels/byp.sv-hosted.log
00053c87672e3538eb6f739070701d81de66f1ba7e14d1ff7fea3e0a2402f403  release/kernels/callret.by_instr.json.gz
9a2d5a4ddced1764eb8f9868365be7b7663882795be8f43f7ad5f0f99649ef9b  release/kernels/callret.by_unit.json.gz
fc79cb4fe9f9b9f252e851c20fce32bcbd50757bbc898e386566e57505539b55  release/kernels/callret.ccvtrace
c6b82cfc22fe00721d417559986b31ce6c400b02bd4865a99d4335648dc829a8  release/kernels/callret.log
9b1d1b50b527f732362f837250aa2f26dabf3e76e16a4794856ebd8f105635b8  release/kernels/callret.oracle.jsonl
3d196101d59952e3870a459203ddfe7565e59a8ccbf3210e572c6fd00c796e4c  release/kernels/callret.sv-hosted.log
b159591e47f8a84520ac7a4cf7add07e177daa92775511faa7e0515b969946a7  release/kernels/cas.by_instr.json.gz
1a38deb0fbd92e1bac54c2d242a8a4ad76cf40842992736548d4cbd67622fcf0  release/kernels/cas.by_unit.json.gz
958d832a5f5e0e22e7567c8665c11974d170ad73e94648a2cc141f993a452cf0  release/kernels/cas.ccvtrace
4cb6ad9ca1ab577669fc762ed467157ff4fc2959718c82fb5d7bb786525c726d  release/kernels/cas.log
0ab31a9443336fe5d08e1a5fa5fcba3bc279b19022f7c5007908d39d8ef39536  release/kernels/cas.oracle.jsonl
656bac6d520bc17b59317a4324843c73ab82d99123a6c0e317d0892db20e3aad  release/kernels/cas.sv-hosted.log
651a2b79a7ebedaecc5297826fc5dc5b59cb7d1c7b7b7278151fa92d320de967  release/kernels/chains.by_instr.json.gz
815c49b75d52955743a3c4ce10149f02761727d9c142b0f42a5a13a61d2c7354  release/kernels/chains.by_unit.json.gz
f3c7f719a83f93768af61373514062f1b4654c87caae7a6fd23d0307b7b7ca0d  release/kernels/chains.ccvtrace
88e187da214d0988c3e99082628816ac0312a11dbd1f10fe062c025916cb92fc  release/kernels/chains.log
26a4cc5c5524c7219d8706c2582c80357dea60be9d6ffdec99dac7d0365e2264  release/kernels/chains.oracle.jsonl
cabdda4482c2d82d4ad755525f2cccc69ed2375f35dfcb8413f2ffa5768021f5  release/kernels/chains.sv-hosted.log
10404f5492eb283778fd67d3e4c4c0a764748808dbd998cc76d5def2132e402e  release/kernels/coll.by_instr.json.gz
ae492af7c8e6f2708346cd0339ffed3013005dd87f64ebc65c597238db96f620  release/kernels/coll.by_unit.json.gz
b9d0aa1fba37d6865c6e65310ddfdec12b1a406436489ff0c4ce6a811c10cdbf  release/kernels/coll.ccvtrace
6f81703da1d3974706766903f5aa322309ffff5a67bd93d1342a848d255afebd  release/kernels/coll.log
dd718d23c88df5dc7d92b055d8542865aa0e029118486af127312a8a578cfcbc  release/kernels/coll.oracle.jsonl
0857deef776060e6f5dbc2a39b3e82679a328bc075439226c9b75a2b22333770  release/kernels/coll.sv-hosted.log
c2e454fc0d28339d9167a4d533ffae81787464a2f10ac1244100fbb96bea5631  release/kernels/div.by_instr.json.gz
c90b0e8b58e87cdf5379d9b294a270fc4e877eb8872249c0866e048fd74d7acc  release/kernels/div.by_unit.json.gz
0fa59319a49569c81f33bc11b669b5cff44d54af88e0e1a0318682d79a62911e  release/kernels/div.ccvtrace
a1c36f4185ac8982feac923a05051e9a36a405866b1e811d71a9683b65bd97e6  release/kernels/div.log
71a567b85cf85622631490187563de9a5661099c78a590adff4ed0a0c3d24c16  release/kernels/div.oracle.jsonl
1b5d14673272e0181e3d27cfd60624e8e3dc9bb024bc7c4469a80337a4cc7462  release/kernels/div.sv-hosted.log
9cee434517970bc18df3e264c88bdd3eb3afe02ce057edfc37fcafb4efb4a707  release/kernels/divchw.by_instr.json.gz
5c4f77a758394220004cc04d3a62c2f829f639a8f0da088b2e07c3a8144f6366  release/kernels/divchw.by_unit.json.gz
7171a5600e2647cfdb103881ce1d051b67e5c0f4b5522ff75b05208ed6ee3d4c  release/kernels/divchw.ccvtrace
01580a9cdb3f4bca63737675a12deed8b017d082feefdd0c3f7cd4e1f063f5e4  release/kernels/divchw.log
58a541797f7a2df0a1c7528ae6a3edec212db90c7d3eb20656806f38b5c10b3d  release/kernels/divchw.oracle.jsonl
87c4c7fb5d57ff7f43056bba45b2fdb532336e1d4cfcfa765c1d15cc61d3a08f  release/kernels/divchw.sv-hosted.log
ff58fe3662c0845231a13741743a4e6237a3779c40385076b29bd7f5c0216d9a  release/kernels/divtail.by_instr.json.gz
6582ac97b7e38b910537dccafd043a8bb8242faf997c79f628707d07aafa45bb  release/kernels/divtail.by_unit.json.gz
db804fbb5ad528ab14845763f37b3761a0b667c3bab40606320e4d62853ca751  release/kernels/divtail.ccvtrace
0c317ea908694dc2eda769ea669afdf2f94c6ebca324ba33d16748089c4874de  release/kernels/divtail.log
75f11a75c9b3b336e446140af4579f05b46c363a76b7aab3ec88154a07ba097d  release/kernels/divtail.oracle.jsonl
87c5316d863d272a56aa35b51ade2946230c8644a04d53a9fcfb1251d60f25f6  release/kernels/divtail.sv-hosted.log
a4ea9fed2be3b1fedde979a27937cc006afc187124fb6f12936f26cc1441d431  release/kernels/divtail2.by_instr.json.gz
8499263cb92d18518e49aaf8658e90a79177cfe3f4cdd561e110faa5b74c1955  release/kernels/divtail2.by_unit.json.gz
a75fe12547373cd47764249a890c8e2cff1203790b37cff1678beeeb1c5b2c44  release/kernels/divtail2.ccvtrace
e48dbbdb86b48efeb88f7833193135460932708a27cc0f955f31f96af42991ec  release/kernels/divtail2.log
b2db6b05eb6cf4a0a7677e31d0c6c2952d5cab49d353f0bb1883fe0b2a20ed14  release/kernels/divtail2.oracle.jsonl
cf882c3c72253d0458fa01cabec3849c3da9f9a09d04ebb6ea269c0e6af62103  release/kernels/divtail2.sv-hosted.log
6113ee31293739cb89f7d7e6074ea2fbcec4152d7408f4d35066cbc47c89ab18  release/kernels/fence.by_instr.json
761b4f180e9a55f937ffe85a70119198f8f6e9d6801d069b4b6043596c939365  release/kernels/fence.by_unit.json.gz
07b3835fa7e99b3db3da294ef152970712d64ccef233069735b96c6ef38d69d6  release/kernels/fence.ccvtrace
b817fbc1c606d4926a75a3a0d04082cb820a7515e5ec15b8e36adc98cddb3258  release/kernels/fence.log
d1d40317f6cf5bfb430cda1f9c0ef676609e59cabe2a11623c42ffbeca93142b  release/kernels/fence.oracle.jsonl
b17e1094319dac96411702aac2b580eceb209e3353d84945e96a6f569d3389c0  release/kernels/fence.sv-hosted.log
743fe25a287b8767a17e91eb9e6d7aef606826b2bfbb79960575af3a60f2db17  release/kernels/gather.by_instr.json.gz
18e32cdeb4aaa92bcf96c2549dfb4edcb1bb5347dc3712c269af3a006db54da1  release/kernels/gather.by_unit.json.gz
356d4b42afd03ad920bb11251e6784511c4334d2d1b21cfd452ba496cf31f975  release/kernels/gather.ccvtrace
455b6fde3f951c99f1b69d4cf462d84f889ec3325eb445e272ecf78fce8a15ee  release/kernels/gather.log
0413e781d8d6ff578c64eb1f800b7931e66f676d5cdabb97b94a4033e6037662  release/kernels/gather.oracle.jsonl
0e552eee2203177f68a5878dc0450d07b4d808f8740af8527174ceb97f740cf5  release/kernels/gather.sv-hosted.log
352808e97f7e1f22997fdf51ab7a26e2ac2021cab33c413454a78101bae5d700  release/kernels/hit.by_instr.json.gz
22cbcba32fc7cfcf1e0494088fc915d3761e98a8b1de291ff0b411c432e5dd6e  release/kernels/hit.by_unit.json.gz
14177cdb44dcac6847993cb29fb18c5d1d31aa434b4b5e92d8935b236f3a1951  release/kernels/hit.ccvtrace
40469bcaef2b1214ddf9f1e5a7c1c52fb0a263075789733f20a801d872f4aa5c  release/kernels/hit.log
7ba9603e0088d9164de6528f16ef6a7fa9ce5821c8c12b52cbb3734e39b9fd52  release/kernels/hit.oracle.jsonl
c8e69953a35f0bb5d9f96d187040d404f5419c816403e2eb5bb4a70843b7843d  release/kernels/hit.sv-hosted.log
88f12976f97519d478c5cfc53701987b2f1415e7d79eb0207f42cd58750e131c  release/kernels/lanectx.by_instr.json.gz
2d291bdab51fe8dc2d8f7944b95a4a32897f9a56ced5d8973d0f736a4dea08fb  release/kernels/lanectx.by_unit.json.gz
c8dbd5f0b00e54b370eba6f5c0a9ecb880268f40dc745215cd4be6aa885ebe77  release/kernels/lanectx.ccvtrace
6225c4553da4e434ff20c0a793cfbe93beda8197ed48f2b0bdd60cd47c699ce6  release/kernels/lanectx.log
888551babf540db8e3025b82e65ca655013f93eba3c8a65689d069d52a7e6039  release/kernels/lanectx.oracle.jsonl
f89bf3c42cf3f60b8f9c909cd80a1dfb8d6c64a6d765f89ee1779007cc748734  release/kernels/lanectx.sv-hosted.log
ac27a0c0da8a1e7b88fff73883b4d4dd337f71a90f72d57224da647ce293e2cd  release/kernels/lanectx2.by_instr.json.gz
cae74491c1a6a8db86805489334b2a963fdefd5c95a631cd154b6182ad0e9a41  release/kernels/lanectx2.by_unit.json.gz
094521bea2680f995ee4a3f798f37495a6540cad9569d634523f06847da7341c  release/kernels/lanectx2.ccvtrace
24e519fbc6c9b2c208554c20d440bb3745e62217f0ff737a369442cdfbc56690  release/kernels/lanectx2.log
45c13056dff5c73ed0c9ece56cc36f929bf335322193c7d5eb38710b1d1dfb02  release/kernels/lanectx2.oracle.jsonl
f6facb36f04b953efd1615a8d51ca42b8d042e0d1893865353038bd4aaae1851  release/kernels/lanectx2.sv-hosted.log
79490885518371868444728b22221610ed656879865019b89ed98942959ace4c  release/kernels/late.by_instr.json.gz
b1759bd7f583c7eb2e2019b9d3642b928a07e49f3c01149c0fb5fed393331fc3  release/kernels/late.by_unit.json.gz
56a358da38919c410520ee4f1d55eafb6e4c6c1b4a1995aa4188761859ef6d3b  release/kernels/late.ccvtrace
353dc1eb4d702eac5995cfa6c5b1b0a38e7f0f81870e30fa2567538300c86191  release/kernels/late.log
86084f6bd747a2cf32acbc0ebd96ebd3e4ef2d8d9e21be49e3ae49290d7927f3  release/kernels/late.oracle.jsonl
14470a43381808c94fa6cb7fa89ea7de06ee2ae6e92b88d889a29d1cd65786bf  release/kernels/late.sv-hosted.log
35f96537a73b89ca53bf8224893965966c3ca063e781c653acdb1e50f351e0ee  release/kernels/ldpar.by_instr.json.gz
debf0fff987bf6140aacdfabf60dde3ee9a4670afe588adc5cf1c8efbbb5e87d  release/kernels/ldpar.by_unit.json.gz
ddd49addaf918696e10fc94de08ea8a643192f00498849772d8e0f02e26f1345  release/kernels/ldpar.ccvtrace
05bd26ddef297ac409cc796af72c45f08cc1d0d69c38a85bd5de0ec2519f37bc  release/kernels/ldpar.log
8ac08538e9c807637babd61b31e340f7461878ada31f0c0b83cd66331cfaf486  release/kernels/ldpar.oracle.jsonl
f2fa0b79430311ec750bb163e043c41948cafc843eb5ff66073f1b3354f1d32f  release/kernels/ldpar.sv-hosted.log
37ab531b5a8da7adec37483098d52498c10c3e9234d9a217d7151f494b12f290  release/kernels/lnorm1.by_instr.json.gz
e13f772e9a98bb3da6dcb2b6bc4fbea02c56bed7cf149c7c00cfdf06dec690c9  release/kernels/lnorm1.by_unit.json.gz
9fc5f9c480b4705e2dd2dd6e69e2a88033876f0810a04316eff021e6014bd65a  release/kernels/lnorm1.ccvtrace
892b44fa9b72cc3a9ea6018f4c1a2a594aad8ae934e8c385ae0b3df5092ac7ef  release/kernels/lnorm1.log
a8d85811af988a1b9fc00db1517300af3d93ec8e589e403d3b9113fa9e0ffc86  release/kernels/lnorm1.oracle.jsonl
3ce1ee0c532dca0dfa9e32f4787d56ecb2c3d04317b8c1ffa11125ba9c64c392  release/kernels/lnorm1.sv-hosted.log
38475680c7d941926bc8812dcc56558eb2eee7773204bbc0582b5a4b705286fc  release/kernels/localsp.by_instr.json.gz
e5063b5de71ce3697cc6817aa3fa837d2001a6ca3b6ac325579d59148710bb9d  release/kernels/localsp.by_unit.json.gz
87878ff18dcbc81cdbe45be1c4f867fda1c2c2c5d032348280ea3c663b00d0bf  release/kernels/localsp.ccvtrace
a0c3847568b8a096cbdfbec879f9c56c7d95020bca74fcc4598d1b2e9af0fe9a  release/kernels/localsp.log
55e3c9f36e7f7d38c0ddd38903aff4bb4509ae862015c592e6b937ea258042ca  release/kernels/localsp.oracle.jsonl
d6b868c0e1afbd506b6fc28efbe98d61135cfb495574138fa247ab9ed04f48c3  release/kernels/localsp.sv-hosted.log
168d0bfeb73303bc7d761fe59a38aa6bf73a93ce77ad36997c9ded1371dd6da7  release/kernels/loop.by_instr.json.gz
8e611550ec4c449dc6c48740753fc85a0886546d566ae4722740a58cac377f98  release/kernels/loop.by_unit.json.gz
8e6c9417e35af8bbae117adade5b9d2de71420fc35abe4aae7df581e61dd52a5  release/kernels/loop.ccvtrace
75d39b37a3df5b8e1330c53d7c43a22db4b613ca54aa3613e1e72446c48ad1ad  release/kernels/loop.log
03ce5920c06c93e93516d8e53c3f7169f14e3593de204eacceffc0b8a3e32016  release/kernels/loop.oracle.jsonl
b94a48d731279f70f55975a8625aafdf7a7928e557b24cd9995048523d4bb752  release/kernels/loop.sv-hosted.log
f6a080553216b62fa89343e5d1f2fe5f1510f96a1bfde448c36be5e137aa16ba  release/kernels/merge.by_instr.json.gz
efa88f53ea9232c5595fd06fe95fe7e71d901856df1470bf0a7e532abf441691  release/kernels/merge.by_unit.json.gz
7c5c27b8590c634e6a6fa0ce6ebc8afed33e3101ca7690ecc2efe7cde41a32b3  release/kernels/merge.ccvtrace
ffee51773874fa3375ff866901f5bb4c9f43ff7c3725c1f40a1b1f5583b9c674  release/kernels/merge.log
f96d28815f8756b1f5a45ded53e6170883d2dfa10f9eef0d14b8050b1318164a  release/kernels/merge.oracle.jsonl
d1934ce8659940c69dcbbbc0b9bfb4b11f7114c4b006babdad3093b73b2a91d6  release/kernels/merge.sv-hosted.log
8a0ddd204c1731554bac0c33638277d64bc1dd4fe0554a28be8e72586c82f6cf  release/kernels/missrun.by_instr.json.gz
9401ccaea8435fa41548139bdf91030df7ecf61c2a03f5e43666ee3783eabbcc  release/kernels/missrun.by_unit.json.gz
ade0c926af6b8801ad9a0c584464c80d257bb383968a4ec36f0e3a4053fef56b  release/kernels/missrun.ccvtrace
cf458ac25f203806ee1bb5bcca6df83ee5f96b7ad527f373a1b0617e2bb1fbb2  release/kernels/missrun.log
531bdaf281e5590774bd2775427f25e4cc0419cf8e3d5b6999843ffe9ef87258  release/kernels/missrun.oracle.jsonl
55c1a86bf70b45799181ef9783cc984168866fc873618820f57a85fc54b1a355  release/kernels/missrun.sv-hosted.log
83525d70d24ad40b50f4cc1fb5f4117c80c7cfd5650a6fcaf06f5f7625997518  release/kernels/mload.by_instr.json.gz
947d7c1c16ca445d4d8a043180c378163060e6d28081c0dc242a0ac0ec0a9c49  release/kernels/mload.by_unit.json.gz
8349891c8cf45b330da9258046fc2c43ce47b7e0ec3b4793ecf79d4b9191701f  release/kernels/mload.ccvtrace
32658214840395799bba1d8d19aeeefcdab3d747276c9c7cc3f2460878049aba  release/kernels/mload.log
8000e477b9a95dfb9f0af964e8346acb9d36f1358fd06ffc4ff7cf599d2b8868  release/kernels/mload.oracle.jsonl
94e363fb60cca5a5b3bc3fd1111b36e91b76c4033c02e36538838d9f4472f618  release/kernels/mload.sv-hosted.log
2c1d8e90996b524300a7c7d8a9df29d3c091c1c17e8e52655d567c7fa4ab5272  release/kernels/mlp.by_instr.json.gz
bbe5b770433de89cfc9183a96d6162b67db8731a919c263d12e5f0e57b35514e  release/kernels/mlp.by_unit.json.gz
20cd6709d3c32211ed6eaef3c8b9c4a5ee5b3016039985849af2985b3dafda4a  release/kernels/mlp.ccvtrace
5bc2cfae7b8daf2172bcdd8023fa8496692923792a821ef708a65b5bd5a75b93  release/kernels/mlp.log
138d282f88d56c8ad648a91af0a983254b55d9fa22942c00d47b327f516a6e44  release/kernels/mlp.oracle.jsonl
d9b866ed309dc061373f25ca4031f286c950ef070662e1cdfa21cbabdd5b7c61  release/kernels/mlp.sv-hosted.log
7879694580ec4cb343a713f585e69f09dd14c44bec5b47d9a67b962cc9a61005  release/kernels/mwmiss.by_instr.json.gz
d7ab2ed0c3c64ddeddd6c36440cc75cf2840bf0458965d3cbba4a654960449e2  release/kernels/mwmiss.by_unit.json.gz
65867eb2557a384f3c51a883e852b728fbc03cffe0a29c9ac4b5502aa5d1de5d  release/kernels/mwmiss.ccvtrace
272ecc613e36724e497f827d0fb2ef3a26ce42f32b0be7760e498559c0ab6ee8  release/kernels/mwmiss.log
8abe8e8997456a2a6711ee72da54d854b24e20abbdab28e4b7271c0d28418de8  release/kernels/mwmiss.oracle.jsonl
8adfd5df570b5b4f0f02762a6e237c11a772692c8d961efdcc1fe4d262d169cd  release/kernels/mwmiss.sv-hosted.log
1692d15a2e391c0f117d2e9b4ca3d0155fff0ebe2f57dcea0351a237d98e9cf6  release/kernels/narrowadd.by_instr.json.gz
a3ff4ac1bf84868ea7086d3d49395902a80aee43289c32c9d0c53699e80f355a  release/kernels/narrowadd.by_unit.json.gz
70f3064aa65b7765b7a6b444510e3f09a7cd4c4605374df03aa452b3837b7a5f  release/kernels/narrowadd.ccvtrace
136f9c5bca9755f7c7e6efd806b618cd1cc42b153afa1bd4de70a61c6cbfe9be  release/kernels/narrowadd.log
40a2cf629853dd404bb06b4a07e35abde3d12efc13f26ffe28f923daf2994574  release/kernels/narrowadd.oracle.jsonl
f92d19726b575170a7e1a50a1c5b1a274b15963fa2021841fd6fa896a5bf7185  release/kernels/narrowadd.sv-hosted.log
1a683b8ad28d48a7a95fb905b9ef3852bffc0426efa1e432d9c8c40a1c867139  release/kernels/pgcross.by_instr.json.gz
f15958c9ec18ac2ab2ceaceee96d8a0a5b50b0634c5cccab1e3804d62d45703c  release/kernels/pgcross.by_unit.json.gz
55954f76cdb425f55f73efefc451c9e900e91431f122622f0c5c8b26648d7622  release/kernels/pgcross.ccvtrace
b4c232fc98170aa8e0337c71c4b2114c469c515856943f2663bea6d222615887  release/kernels/pgcross.log
58aba9ba5ec6a72271191c0249014802cdc7e4470d27491f499a077f17ecc039  release/kernels/pgcross.oracle.jsonl
34d0be77a301683350f2ab152cef4653fdf2985e584955c3fb2748c68dfea3cf  release/kernels/pgcross.sv-hosted.log
8da5d00de27ae7a0a43188ea215339344424b9c70b6d1d3bdf75f44a8868fe5a  release/kernels/pguard.by_instr.json.gz
fb90762a4966c2cb8949ccc79ca2110436555d2b59fb09acc17c5641fe6edeef  release/kernels/pguard.by_unit.json.gz
d3a0f73a186c037df930784ca453b1f6217e7443e14b5e2c4715bad84be9ef5d  release/kernels/pguard.ccvtrace
671c22dc16cc8225e424742bbe3f9d23834cd277699374cec7326729c041c4bb  release/kernels/pguard.log
690e56f1cb8d97cbf67124b7dff3ad0a90cb8981814cd1709cf0cd0e035b3bd9  release/kernels/pguard.oracle.jsonl
02642fc2b6b0ca64a9a143940d23d4b07e48c4c387f261f7cb6f45eb8c05b06d  release/kernels/pguard.sv-hosted.log
589fb91f2a1a8cbb549b3f227817287faacacd0613d0da1ed779c30736ab2411  release/kernels/plog.by_instr.json.gz
ede0babe31709603a49f5496d788f3f98ec5dfe6b4b5c06805acb5d13f0e7470  release/kernels/plog.by_unit.json.gz
7823562f75147705b01f772471b6175774023d19935926703e158062b24cf94d  release/kernels/plog.ccvtrace
63e5cf8d014f79dca17e4b29f545badcd3c1720e56d8bcbe26e3f214f0833b61  release/kernels/plog.log
0c99915e2da60f4670da00504a6371d7d17701d4431e733a3ff8fa98a2030d6a  release/kernels/plog.oracle.jsonl
ce65fe4596398a4b15469275ffd162eaee208d03531b2baa3c32660658b113ce  release/kernels/plog.sv-hosted.log
6e3e6c30d946acd2dfdc7369e3c1128451dbb00726c5da5bf709746eac4ac80b  release/kernels/pmovdiv.by_instr.json.gz
fd48dfc572ff8f69930ac8b6b90a94cbae672767555211a0d89439dff186b72b  release/kernels/pmovdiv.by_unit.json.gz
da1865544271c3c70d3eab1061f5060d833a856975f75b28d0921880ec954a97  release/kernels/pmovdiv.ccvtrace
0087eb8f2e613b8e14e8583945e2babde0b00b2b97c6989dc5123f75bb96e1f5  release/kernels/pmovdiv.log
7bc646cff6166a51bdce03d7c1b7209e871f0a91d743083a9b910a80bcd0b33f  release/kernels/pmovdiv.oracle.jsonl
84cc77febb0a8959913271fbb9343ba198777697f888f479dbff4308f9e40e90  release/kernels/pmovdiv.sv-hosted.log
0504538c821d987f35f4a22638d3ed1cd8b939981560b603fbc06e84d7fc0f1c  release/kernels/predlane.by_instr.json.gz
d108cdc1ff605737f037f668d18982a0fa81b61e8c2119f60e37b0dd9b395b8b  release/kernels/predlane.by_unit.json.gz
50d80cc740eb64f50d8d451ba21e1c58972991ba64ccd7114c95e774f4a430f9  release/kernels/predlane.ccvtrace
ebefa15d24ca82a595cc3038b7b9e5e89a63a5ef3010dd03189d820239a4327d  release/kernels/predlane.log
c45f4177b9e84fc8a6e36b13534a0c7636eb30a3f8531847100ce5e23bf404b1  release/kernels/predlane.oracle.jsonl
34bd5a6e37cf7ad852f01dc946d71f10ca375dc7c5a9a3271606fe93cd1fc210  release/kernels/predlane.sv-hosted.log
e5865001b3200626d1cfc95addb4bf08e75ff7f346d495f33c3b0eb9de7b1835  release/kernels/predmerge.by_instr.json.gz
536bcace09adfb4e1ac208f89b9944d2ad4125910af0f23f2351c9f92ca10fd7  release/kernels/predmerge.by_unit.json.gz
d4fbcf1a0ea13a89d7fdccfc214c4f918257cba14aa024d4ca6250f04d3a7fc8  release/kernels/predmerge.ccvtrace
f7d3c10065b81da23b4673c5ecca1e33ac6fb08cee95ed85e198d7d92477dfb8  release/kernels/predmerge.log
6c737c49434bcd08e3e0814c8b1dbf15c586ae74f7929ba3148ddcee2c62c845  release/kernels/predmerge.oracle.jsonl
3dbf56c1ea597a3d5d0f3ffa11e36d31b23c7d18dd383e89998b6028a07a7c5e  release/kernels/predmerge.sv-hosted.log
1dd5540d1f3bd97303bbaee331747e44f60e1d38a997cf5509ed6369bb774b6c  release/kernels/predspill.by_instr.json.gz
e0afe4a215ab8803e15398b5293608fe3c73a6be23f586ca2c13f85101b3ed2d  release/kernels/predspill.by_unit.json.gz
68b1af2edfcc1c09bfe4cde2e148b0eaec9035dcca2ce8d1acd4ee551303d76a  release/kernels/predspill.ccvtrace
295b777baaff518ea496c5fe4e620f7b8a9e4adde25c7743ef39d137a20c438c  release/kernels/predspill.log
b7c84c6478117ffa0f06da0e6ad1e4628e2683426a7911080810e78e06a5242e  release/kernels/predspill.oracle.jsonl
b518a1f4a3620fe114dd7318e47c7bdf5d179e50ab35eaf4f889975e92747cc9  release/kernels/predspill.sv-hosted.log
9b759e2a8e60aae91ce40fdb19e59d4d39b45d3e096fe90aee503e5fa33abc33  release/kernels/predswap.by_instr.json.gz
d5defe278b0d7d068e99d317de263c0e8ad6dc400e1a7ae6b60da5c1580ac65c  release/kernels/predswap.by_unit.json.gz
cc0bb7da1c9dd84f7a62c74627d792b5662c595294304c08509661b0a072d0f5  release/kernels/predswap.ccvtrace
643c95d96ce50a0073d40703ad24386d622e7388b2f76303704b0350198f4098  release/kernels/predswap.log
a6d4f7ed517553816d889c7c9eeb6bcfd1f6c973fbf682ecb69f3c2de619f7bb  release/kernels/predswap.oracle.jsonl
1e6fb597204ba5c9e9cebbca26261d86312b0bde4812d11dea8bde3c2ab40814  release/kernels/predswap.sv-hosted.log
b3a93aeafa8c4d2e736742f5b5fecc51be8b0d1a70abd36a10291519d31b7691  release/kernels/privwin.by_instr.json.gz
685ac9339b68e288ea083546af09cd51d53b5e6877caeb65836205955cfad462  release/kernels/privwin.by_unit.json.gz
b05842fd55756949b74bcf3dd99cc17c0dab77b15911287ab50f3420319bb912  release/kernels/privwin.ccvtrace
42c90c54672c9e72a421d0b723574363e15c461bcfdaeb5e8205ba53c905ca6d  release/kernels/privwin.log
861f686fc4480363472908d679d8815e8c957d768e7ab32c826930527b0fb7a8  release/kernels/privwin.oracle.jsonl
60f82f7ee9bc4ff1ac0a1c57bd7ca77ec1f9ea4955b7ba4faf4c90cbf8e91b61  release/kernels/privwin.sv-hosted.log
7a8e90a75ac89692ae6ee95ad40f06d721010df992e9cf077870a59b4a4732fb  release/kernels/provswap.by_instr.json.gz
74f63d1e76f8cc16a9063b05528b6f9e1b83eadca09590c0dfb6c393808cd720  release/kernels/provswap.by_unit.json.gz
71b721e2bd1fc8dd52b36767c301a10981b26e89728d6827c65aaf14dda88f38  release/kernels/provswap.ccvtrace
5e4046804e3d47d12f296dcfa41c9e5b2c642a11bbbf016c6e0f5e2231a2281b  release/kernels/provswap.log
c9c32a793d54cc7401477f582487f7e8b345b2669a75337b8d6327120d98e5dc  release/kernels/provswap.oracle.jsonl
f841eb1d0eaa094bfe740ec006dace285c648bc8bdebe503c81e377a0dbc43f8  release/kernels/provswap.sv-hosted.log
c8c558e3337905363f3dc77e3dae6709f26a31e78f04725799baca384f6a33e7  release/kernels/retmiss.by_instr.json.gz
29ca914e233dcb6453172a52600d65af3034dfac9611534467ddf3cff340db5a  release/kernels/retmiss.by_unit.json.gz
5fd48fe228e08b7647063cef9db1a2d2e027a5a03176463da79fbd5263ed78ab  release/kernels/retmiss.ccvtrace
7684c258cc6760de8f43e42333f7a16a68cb81b0e2a86ff78a82e1d5097d99ce  release/kernels/retmiss.log
e5ef8538e838c6cff7febfc679dd091cf5e002f82d34f1009b1948ce22bc3649  release/kernels/retmiss.oracle.jsonl
f6d9c4912a68d6ba7f032068bcb14644fd19cf056603e48d86aff1b5c5da7da5  release/kernels/retmiss.sv-hosted.log
b8af37455b33a1b36ab55a477d4761f76bdf9dd3edd8eab5fb7f2c3731ac8ec5  release/kernels/roconst.by_instr.json
1bd6e3d57918f6dc12f88a90fbad3431d9d6ab8123f8959ed02ca7c9430da7dc  release/kernels/roconst.by_unit.json
55981e07a1a8d3ed8b7a9f6797e5f718e3161cc5f6e1218171db77f9b6115f18  release/kernels/roconst.ccvtrace
d1921a51f069c052bcd02c989bef88cd791138501f72e3a24a20f86fc587b33d  release/kernels/roconst.log
8087c0671de620162881aecd38cd6114b78e7be6bd71201e3ec02c9a2e2e750e  release/kernels/roconst.oracle.jsonl
138ee55ced821c3c432e7272d97a8522c412d247f89a95861b55fd3131f84c75  release/kernels/roconst.sv-hosted.log
10c797fb8d044649f6d3dee9c07281c225794258b33e21124d781108ba92c747  release/kernels/rogated.by_instr.json
cb067fbbd36eab5467e8c04eb4f8e79abdbf82dcd612999a5cdf078462dc735f  release/kernels/rogated.by_unit.json.gz
efce29ea7c5e82d9ca9f5522549f4958218e9ae67a9114f6c26c60f34501ba52  release/kernels/rogated.ccvtrace
4740f432e5fd2c34f691b0da6676ac020294b9940c50379d1bb6cc50e3a6b740  release/kernels/rogated.log
7cd02bd4cceec5a044d6b4d6a80df1e68ed0ae71b0b2a953143636d5b809ea6c  release/kernels/rogated.oracle.jsonl
3baf91cd5d618dd0326e37af6f54f2b1ba4cfb172ada770c7308d12ac72771d6  release/kernels/rogated.sv-hosted.log
148b0a7027a37dfaa1a8724757fcba3a59c56119a2cfb92bf7164c0540718dba  release/kernels/rokill.by_instr.json.gz
2b1b997d7004ce500fff5b0ed7d85ab1bcb6c21bfd7fa1d20235f43a456bbfb1  release/kernels/rokill.by_unit.json.gz
8a540e1a67dce0d3845964ab547fce4b1c674a042f6be8c8d8c8b7dd46f4663e  release/kernels/rokill.ccvtrace
85275fca9bc7152dacc45fd90a4d3328624171bcb743f591c47418594c839fc4  release/kernels/rokill.log
94efcef96af469a512d346ce61623980fe86383188eaebd55120f716db596f14  release/kernels/rokill.oracle.jsonl
f08007160ca25a00dba7cc1fe6641d12c5ac5974552434d031ef400b7ce80e4c  release/kernels/rokill.sv-hosted.log
c19ccb83ee76e32c38bd354fb4071aad10d758d6255c3bb1468356f3f65f5ac7  release/kernels/rokilllane.by_instr.json.gz
15edf0ae85daeeceb1a6ff4f70c086fd1c5e21568bd512be57d0b79cd9d3a4e3  release/kernels/rokilllane.by_unit.json.gz
c54a973f624a7ad5b95499138a725ad2287a564534121f4f568394896b3522b8  release/kernels/rokilllane.ccvtrace
7c8a089773871b40ca63f8d38b28e883c326a5305685737afe4e06cd5a071549  release/kernels/rokilllane.log
f5ca6e666eff2f44894df74a291b43b3c0e7be0a63a47d795fdefd7b22016f45  release/kernels/rokilllane.oracle.jsonl
c9ae2e6f8109445a5cac483f880f119c55c44b82338b8fa6bc089e2208c4014c  release/kernels/rokilllane.sv-hosted.log
6018676757a05a45231fba12ff6df60d07f415338c1d836cc09d99465b73577e  release/kernels/rolaunch.by_instr.json
8512780fe1bbc0571a43ff91654c0ffdb7545b9c1ac040c907e50a29bfbd10d3  release/kernels/rolaunch.by_unit.json
289a78e36e414127402cf1c2f9514ddf7965e2988e5c5c2c172bf77c872262d4  release/kernels/rolaunch.ccvtrace
89e705b2c50372bc88b0a5676deb01fb38211e30088052322c9d747b26535b97  release/kernels/rolaunch.log
e7dad585c3e70615de04330fd03f4f282c29a005dc1732a35655fb261d51139e  release/kernels/rolaunch.oracle.jsonl
05efe6623bd2363f981e8bbf814db08a674e1aac43594aa9dd8fc3665c84a9ad  release/kernels/rolaunch.sv-hosted.log
b8af37455b33a1b36ab55a477d4761f76bdf9dd3edd8eab5fb7f2c3731ac8ec5  release/kernels/rolimit.by_instr.json
0e20aabf7e39b687a2ade0f80fd977c9d7bd313c2cebdac11d43f35296e7d911  release/kernels/rolimit.by_unit.json
6105e32f751a15c0875d0d2a30a1e054656c0475286b5e2739728e13fa4d3e83  release/kernels/rolimit.ccvtrace
1063a5bb38caa7980d064cd94e43b582cc64fe3bb8b9e577e18ea36169208862  release/kernels/rolimit.log
1c5bc0cb8e8b2e69505fb5a551a16d5d10c56f232b88da7a27e336ad7d962de2  release/kernels/rolimit.oracle.jsonl
47551fe5d52477028d5f8a3ee6321144cde994107ca60a677fb7358715e75c50  release/kernels/rolimit.sv-hosted.log
0e79fffc7a180a08ee9d657bc0c018ab2fac5db91b277e621f09951838e94f66  release/kernels/roload.by_instr.json.gz
86356c7e1b13bbe249462497a9b67d53bf4dc1de4506937b20ef6ef05baeb405  release/kernels/roload.by_unit.json.gz
1578a583d5c4f4db19dc0bd74a872681a3a72c6e6f5b8cde88c5ca1dc140c41e  release/kernels/roload.ccvtrace
28839763810d653927388e4466d6c7b5805b56626472fdf00ddf6738ef5e8bf0  release/kernels/roload.log
f7c1309cc9764769fb5803f6fd0f2f5e1eb418f2d23fbe5e17cf5f9106869fdf  release/kernels/roload.oracle.jsonl
b3ddb901995fd4954e3e682a7a73d550dca8e6943b14346f875f5365de26d89a  release/kernels/roload.sv-hosted.log
17c3e832447b30939659fdc04eb6446829a0379898764cb567adee804c687521  release/kernels/rope.by_instr.json.gz
8d623d6178d2928b291e620604719f5d87ac79e69cfcc639a8a88ce0cf0f02da  release/kernels/rope.by_unit.json.gz
c28a1bf8541fe51be00d4bf9cc41210c6cba3db2f220dfca58ceb07bf23f1fb7  release/kernels/rope.ccvtrace
f37bde90394dfd0459d1922bcf9ccded862fcbd49bd21227dcab2a3451ce1e76  release/kernels/rope.log
d55f9efae392dc8877c102c01c0810e7654b666b6ede386328108164c6cf88f3  release/kernels/rope.oracle.jsonl
d2102ce8565a5923818e487c5189b25f4320815c41d5e5367bbab9bcf9788769  release/kernels/rope.sv-hosted.log
d9234e8ff60b72edf6768d5763237f9a55d968401002a76558e998a759564122  release/kernels/ropediv.by_instr.json.gz
64ba618dea8302b40f951582ea174bc1deca0c64106d23740edba06379992eec  release/kernels/ropediv.by_unit.json.gz
f3b563b58e4997345f986a68124b88067afacf867bd6c7f3c4f48cf639bdef31  release/kernels/ropediv.ccvtrace
41e08b6f90eebad42d46aa6764788d480738a3cd9b49b2534c19ae393afdaa9e  release/kernels/ropediv.log
10c0ec6ec18b7b44638c790033109198c079d07c1537bf193353ccedd00a920f  release/kernels/ropediv.oracle.jsonl
5d553df67bf13ddebd9696ac44ac41817314b5c0f1b2299aed017c3edf6ea470  release/kernels/ropediv.sv-hosted.log
6e553a3b00e27015e02088e4fb9ebd237c8409be4c7e59bd1791d08bc19c59fb  release/kernels/sel.by_instr.json.gz
77f6011a979527129b790e9df438b2cafc6f76ffa13f6e693d52196f81a4b741  release/kernels/sel.by_unit.json.gz
0e8438b35022c4f1ce3255dded34165aef8dfb098254ae97b0f80b67fffe2c18  release/kernels/sel.ccvtrace
a62c49703fb6a3927b9c51486c9caab3573c8b10b3978fbfd174d5d460599228  release/kernels/sel.log
87f6a81e8afa004c8039bf2f61c90176fcf29ab29bb17ac44aa016a5cc8438fe  release/kernels/sel.oracle.jsonl
70d84c8b03dd3a3b0d583430e6d1ee9367edf58f1e45f97af2455441f3b7baaa  release/kernels/sel.sv-hosted.log
72b3492d0c5df7f25e2c8ce69f5eb4a6c770b080c484584b99d38fa05c29c511  release/kernels/sized.by_instr.json.gz
fd8063f1c4ee3fced40e68d68e3690af945d3cb4ccbc9221b12e31c17a32da9f  release/kernels/sized.by_unit.json.gz
fc2280a2a3c07287069cdcf194669d210c189c42292f2c8f18c06e80ccb1dbbe  release/kernels/sized.ccvtrace
6c3cc34f4cd04d9794365b712e172017b4c6e7c16727a0712576b81d6059ccfd  release/kernels/sized.log
36d903ba1618bd1faa437c9812a6ee6c0c966a63196c796267d74bf2695ebc3d  release/kernels/sized.oracle.jsonl
c9351630e9837dd7725074ff4df8069faef6625e47d4d46d38ff59677c2202c2  release/kernels/sized.sv-hosted.log
e902d1e01f3e84bcc810242febaa4572311229c9344dbe2da7dd0cd75536a638  release/kernels/slotform.by_instr.json.gz
c582ee0322e90141d2a93b688934c3effd2fbc2b010a37f268317fd0d325bc81  release/kernels/slotform.by_unit.json.gz
ff8972a50d2be95058930e607a107394abbccd183eaad7a443dad100e56f5019  release/kernels/slotform.ccvtrace
0f64f39f3164330e3dbda61cfa75ca0fc1e6ab66cd4a84787d45912115f7295a  release/kernels/slotform.log
8b61db7419b18cea8a646fb628218447e72e84a18a9891ffb73b441736138ab9  release/kernels/slotform.oracle.jsonl
394c54d8dc252c0e6ba1daf19b616709e3378bb09033a91ec610f079507ccc31  release/kernels/slotform.sv-hosted.log
f1641a8bae9faa6b0c3642bb3f84299fac49c7a4ad28486574fc65709fc79923  release/kernels/spinwait.by_instr.json.gz
895ca38fbe38090b32985a78bb633a35f045b512fb6275e6f34a529e89172b0d  release/kernels/spinwait.by_unit.json.gz
96ed0aa7d277284575bad8804bec69409b22c9b86085c7cdf2a3776908b9761f  release/kernels/spinwait.ccvtrace
2907e945178a4fb6547e6b3c50837032d4201c2b7819fc2346667eff3a07ac97  release/kernels/spinwait.log
868920637236c878b33779bd450439466fc3626996a3164573dc11d437d5c709  release/kernels/spinwait.oracle.jsonl
9902d1ffdade2df0201c32095204fe3bbb0963725b1719a3844c7d098e95ff2b  release/kernels/spinwait.sv-hosted.log
42b2c2089edb1852b262d34e6641c917b00aeb853d85a710abfb2f2b48f0c8a4  release/kernels/spmbank.by_instr.json.gz
d9eb59aae1c8d84ae0be7c6e08b1c4f63ccb68ad324dcd3b27b644bd53c0281a  release/kernels/spmbank.by_unit.json.gz
0b63ddd199108d5d57dacf8da3b47f37f0c4b36c8ae2b2605a61415aba0d0ef1  release/kernels/spmbank.ccvtrace
7f6e8a592ba22b934ee3544a29849ae35a648d25731dfc10220cd974147ad380  release/kernels/spmbank.log
3af490cc37d7a92dbe719b57de216b648536eb301ff9d13de9a39f50d150d725  release/kernels/spmbank.oracle.jsonl
9d2abeaa457de98410cf78b965c3ecbe5363e89c1743824f7fbed9f0f47bb160  release/kernels/spmbank.sv-hosted.log
e6796535a93d809a14edecb600ed970ea1e3c6d19f57c41551afbeb0a083ab9e  release/kernels/srd.by_instr.json.gz
6c00a3bc141f8f812f88268b4d8ee268487df26c9b0362e818c5cc64256960c0  release/kernels/srd.by_unit.json.gz
0c47cb484cf0fa4aeccd7dbb998c726c231c62826d2093825653eafe0ebf1c2e  release/kernels/srd.ccvtrace
fc35cbbaf22ee47d96edc102a27ecacec81a30a00eab9121045a5b3ba3ece355  release/kernels/srd.log
b08eb5e3673cac7eebb8b72af5ed3783c8e70a9e96592e76bf3722551bc79473  release/kernels/srd.oracle.jsonl
3cb18ccd30d92fbad70c28d6f8ecc5c17131679ecad54457605a91ec1fa49dfc  release/kernels/srd.sv-hosted.log
8f679b0657de57ce782f113df78eea33cc98abcdab3ae30e7801376e5686beb6  release/kernels/stall.by_instr.json.gz
d45d1eb96d61925fd99770b6fea448dc2e66ff81eb71ab76f7c64a62252ff610  release/kernels/stall.by_unit.json.gz
fdbaf4c7902b755d682cce57fc79287d1b42ac04bc16f363e0ae6381951d354a  release/kernels/stall.ccvtrace
cbe2c08b144e7b2b87a50bab0a1b1c38a186237abb978a9cdb6518895ecdb3c2  release/kernels/stall.log
500db2c482b07a0706583422cd68878301d0146c1f872ccc1f11bfdcf5c993ef  release/kernels/stall.oracle.jsonl
9fd04cdeab606a8ac19464b201b51b267655121dc7997dccccc34ad1c910f18a  release/kernels/stall.sv-hosted.log
d8decb7aba8278ab29c302aae7719497471198909e5753b52b6b27d6033b105f  release/kernels/swap.by_instr.json.gz
ea0905fc507f0dc40d26525f18e720420b35969f3893d45dfbb0535e09489a1b  release/kernels/swap.by_unit.json.gz
e57df079f08803da10c14868ef10984f224605451405d05a7f253f3e19b0b77a  release/kernels/swap.ccvtrace
a9b5a363999caaf49803d18ba88b6fb7e865c512f817a5204a26be9a097442e3  release/kernels/swap.log
3658a26316c1ff7bc1744304a42f736e930fcde2865c8913e6cc67a22ce96667  release/kernels/swap.oracle.jsonl
a02d057089c09127929df1795426d12429923ed64a9fe965c85eea827171aa24  release/kernels/swap.sv-hosted.log
90c92af53b23a5bb30375c3d787fa8187502c451c7e40f419d2e7d6d8b737ff5  release/kernels/transp4.by_instr.json.gz
baad62bb3055253e0afde4a7214d25de92b58cb2554c7c61cc0dc3c7c1234aee  release/kernels/transp4.by_unit.json.gz
8f2febb448d3affcf9fd137c0f5e513ad3afa69793c63d3f8a51fa6550ab966d  release/kernels/transp4.ccvtrace
8612f62aebf5f47b156998a954650079ec4510e10690792999da7499734045e4  release/kernels/transp4.log
06396ace3ac19677fd39c700e408606e5bdbacb24997d663bbe8872e63dd74fc  release/kernels/transp4.oracle.jsonl
21809097a626413f8e9db99793e0008c975d99cec5962b4794f6865e60cbfd48  release/kernels/transp4.sv-hosted.log
dde6b426929c4390971e56b9ed2871037a8de0a9b9b07fef609a5d52b2dcca00  release/kernels/unal.by_instr.json.gz
0719338a2b60a712e8aa1ff16da3b2c30be95f03900f81e8f756f90d9948beaf  release/kernels/unal.by_unit.json.gz
0cd8c220c97c584d454372ee65753f8c7eeab527faa08ee5dea40239360b17f8  release/kernels/unal.ccvtrace
9170506d27d9ab469fe0a77e3007593a47af91134832ed621de10b9eb76ed389  release/kernels/unal.log
c3d484bb160657a563df983d9a2532eac27f556636617960aa1e72183ac2b299  release/kernels/unal.oracle.jsonl
172f070a2ffe4ab26f56143c6ea1d5b7b76dd2ff4861131e4bb40e3c70bdcc46  release/kernels/unal.sv-hosted.log
cdccafad6be164e6913bcc6d73e7363b1d917a33bd6845d11f66212a4c036744  release/kernels/vadd.by_instr.json.gz
0e79b22be968f97c1d73c53e25990af420413ec6c82c136e2ef919b6854c5d43  release/kernels/vadd.by_unit.json.gz
e325dbc3fdad4e6bbbc3475cfda348ad306843a8c5a0b3ab2737111454ceb121  release/kernels/vadd.ccvtrace
ffd97c70d6f6cd2ed7a9e20f2604f290fa647ac7511231929bcd87bfa978a29b  release/kernels/vadd.log
0276b6d0611a4bbcdc004ab3987214aea138245bc7217504147331689a9c0880  release/kernels/vadd.oracle.jsonl
11e07b5a831fcbc7ae40622533d8ea42b35f3ad95734d60f2e7bc846af69e5ab  release/kernels/vadd.sv-hosted.log
3c68134580a161795817b7861cd519d541105a90b6efdd1287ed0e9704fbcd8c  release/kernels/vadd4.by_instr.json.gz
2ff2b50d584bf6724c8099345df21e36834a9f34239fb38582d55650ee4f5dc2  release/kernels/vadd4.by_unit.json.gz
5edf3b0f5cdc6d57709ad1ea5489bde063b3190c90a27c1f1a43d010b19e7983  release/kernels/vadd4.ccvtrace
cb0f5738726d98e76180a0d28f11334e9fc879f6a7bb838e8b33103f01cdc8cd  release/kernels/vadd4.log
225aa18fc9f38aa9ad615aa11de254337d59fa705877553d873062c68366e0db  release/kernels/vadd4.oracle.jsonl
14ab7a2b7daa0dbb7d8b8a6876ba5b69100450c350aaf34fba54396db4b81935  release/kernels/vadd4.sv-hosted.log
3ae6434233a2d9fa3274b7b358ebd4d5b756d6d0ed805069dd4df2d2a7965662  release/kernels/vaddslow.by_instr.json.gz
138e2d155a94498c2d2731b3fcefd363ce4d6ded5561f33b2828e1323272a3b3  release/kernels/vaddslow.by_unit.json.gz
f4edab31577c7354ea3937a41cb1bd675d1b2f6cf11e99ef319d3ce31b4cb878  release/kernels/vaddslow.ccvtrace
b68782cb1f71ca34dd7e2dd75cd964a272da74fa5ba3f975bfe312fd8e908f71  release/kernels/vaddslow.log
e9e6218e8b8450e9f9ff6b39d659c994a1e51c527a0c5bd10d18b5658ae0e344  release/kernels/vaddslow.oracle.jsonl
b7ac089b28bc0d626e5d5fd8c882aeee8e8706c13a773cfaadf085e4bf44789d  release/kernels/vaddslow.sv-hosted.log
bd6036222c71634277f35979b840d1660b286078dedadbcc5f3a259962ff342c  release/kernels/waypred.by_instr.json.gz
94676a58405a4819cf05c2ab292765ebff0d307788385b77aeeaba73a8add45f  release/kernels/waypred.by_unit.json.gz
5be72e1d051494726fba08e1bc919a11cd5a7afe6cfd7065564f3a1c0c0c3f24  release/kernels/waypred.ccvtrace
38afb5576cfc4b8c8b08564acdf46af22b328d26a02308f792dbedb801ffccb2  release/kernels/waypred.log
54fb803ce85c4458b8687bb0f61adc32a9d798448b914b06261dc49c2bb841c8  release/kernels/waypred.oracle.jsonl
d2232a7f225d2ae23fdb2dd24cfaba2db7c74d5856241c6be125ed679a4cf570  release/kernels/waypred.sv-hosted.log
9f0dc29cdfe9d682d7960ba39cf7031190b8eb9dab171ddf1035cec8581c3aed  release/verify.log
f78197fa73514d4391564b6dbfda61c3c03a38e2134c9ddc2d24180f29c72e6c  release/wiring.txt
```
