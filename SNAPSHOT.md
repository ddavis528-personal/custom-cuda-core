# Snapshot snapshot-2026-11-22-11f9009

**A generated, read-only snapshot. Do not edit or merge it.** The source
is `ccr-9eb50716-lecnjf` at `11f90098681d75d07e2189c31e0164dc023706c5`, and this branch is rebuilt from source by
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
| Source | `ccr-9eb50716-lecnjf` @ `11f90098681d75d07e2189c31e0164dc023706c5` |
| Built | 2026-11-22 (UTC) |
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
04c42041afa177bebadcfdae6c6f7e486b0b915e72dc982e54181eeda8656693  release/kernels/addrhigh.by_instr.json.gz
04bd6f3bca0f05bce5b875aa5c428b1ff729fecb5622ef0d130c5001d468eff1  release/kernels/addrhigh.by_unit.json.gz
77bc0c3be8e830d8723acdd7c4f9eb29f4078b3115874372bc60e68aa53b7183  release/kernels/addrhigh.ccvtrace
4a4c4ddefad62dd1d282fc68830907f1ef2ef53d2813ccf09451d7c3179f9989  release/kernels/addrhigh.log
569f2e22883fad5f0956c57ec734e6afbdd4b8a854e50277425172d6c0cbd766  release/kernels/addrhigh.oracle.jsonl
8d28b66c3fd16c7579a0d1cb564e28efb0710cdccdcfc3b94f0e1874e1186a85  release/kernels/addrhigh.sv-hosted.log
32a11e6c63c10e002e92d55eecd4c03ed5a665fb9bd4817e1f94a15264c96010  release/kernels/addrlimit.by_instr.json
85186aa3b401b5167e046a30f2ae0d04b84e1039b985e951672289388f9efc3f  release/kernels/addrlimit.by_unit.json
d8f758a9ea0bb7fc9f4b2e3e6de970d00e0ed7699ff2a1a062d133c10932c23f  release/kernels/addrlimit.ccvtrace
b2dc457e9293de385f3d65c013a1de7f94b7c22ddcab160c1634f29d03a06f61  release/kernels/addrlimit.log
bc660b0b40359a2c5a2478cb0eb4950b73fd22db50ea76b80052bc195a1920f4  release/kernels/addrlimit.oracle.jsonl
50ca7d057153b3ea3da66f43f03bd47d878403db8526d9ec7db983ad551d2910  release/kernels/addrlimit.sv-hosted.log
d5ee993d0a633a3a0837df8a1267138a4a90d71b0f13f2964db1fac129be4751  release/kernels/addrneg.by_instr.json
d4575a0211ba3cad70a041dab45c9876f749ac9173cd91604056151f0cb47c9b  release/kernels/addrneg.by_unit.json
b64cab0cffa732e5e0822d4d5e4704e4625cec46309de4e9af4fa929274a37fb  release/kernels/addrneg.ccvtrace
5fe710faea2bbaff65e35d140719023a419da1a2aabedb55a56f9222c7071fc7  release/kernels/addrneg.log
16f5b0707ae44492a1efd67bb9dd38a7e79a7bbd354fa9207b9e7d150ff2f107  release/kernels/addrneg.oracle.jsonl
e89a7b207fc3130b909ced11eb187fc7ed2664dfc8a24cbc3f45d3aa9de5788d  release/kernels/addrneg.sv-hosted.log
d327d6dbe758cc9a00ff0e4e830ea8050b019463cc04137f118bf5f1b278acc6  release/kernels/atom.by_instr.json.gz
c7f7b7732dde491a33b681e048a2ab474f0ab1202fc142ba736a49b1f1dd20ed  release/kernels/atom.by_unit.json.gz
055cf6a2d64de7815c35275a5fc599c607cff309a46397b5ff72adae4fa74a1c  release/kernels/atom.ccvtrace
1a5cbd260179b55a68fca93f0da3599eb3523cb7cabfce9ebaa0b4a6b663e882  release/kernels/atom.log
504f5b6e9d25114dc35f2c70b21bb7b3f3c508c691de12dc0e87d12a74285361  release/kernels/atom.oracle.jsonl
d441787c9a703920407a6e11e3060b0aa4e62ec13462ac62b06970554ab38551  release/kernels/atom.sv-hosted.log
5d01d5a1e1206198cc1d159faf859eb625772aa8a7d34bccf916a645687aa040  release/kernels/atomf.by_instr.json.gz
62a66d34d2e20df3193f3edd165cc41c568eda3765d41f8f4653b91488d92696  release/kernels/atomf.by_unit.json.gz
a30c43cb673fa284dbe4978b78f7c1496d326013ff2507e2c5d3c3b83483dddf  release/kernels/atomf.ccvtrace
144740d7b18e5004ecc753719443f483dfec1c62fccbb62793a78a9251834439  release/kernels/atomf.log
cfd1179edf4061a33ab2f75d7a6dec61decfe629000198189a7bfc2647b34238  release/kernels/atomf.oracle.jsonl
af64f97561bbc89ec0529f82fe47b359f794d3dd5980a99b859dbc561417b6b2  release/kernels/atomf.sv-hosted.log
c9e8f14292dbabc551abd3a0a125e61a93164a105207ad64c3ec1638e206713d  release/kernels/borrow.by_instr.json.gz
6435c931c55014801dd550d808a64334f33decbe1c753bc42d5edbd295e0ca10  release/kernels/borrow.by_unit.json.gz
675e87f1c0e15b984bee253fff4849e79de6b07f83e6e28edfa102cf07f93b18  release/kernels/borrow.ccvtrace
8b80d936bfb5a6a60cbe286213f80e31b9ec6b7c210d1d543ff30c807ff2f890  release/kernels/borrow.log
4c565e1ce0b3baee36e158694b32c8defb5cd662b2f9af75cb5d8c26cb1168ed  release/kernels/borrow.oracle.jsonl
51db976f2f14f9c582b20db44881045c4563c8583b9fe121e8d3e7a1e9d40052  release/kernels/borrow.sv-hosted.log
bd62460ee34c8cc3113ef121d07d3204909ab09fbf51d5fcf6a241f438f389d4  release/kernels/brs.by_instr.json.gz
b1d84482b5f0b91e46f4269e083b1687f7737354a330a2eca7f864b7444bb2d9  release/kernels/brs.by_unit.json.gz
dfdc00e3f7e638e036c8544c04704d8c1d4cca764d189ea7aa1e0739036dbfac  release/kernels/brs.ccvtrace
5e167af93ec43444ec4f671e3b35b43f5bf867fe74c8727bb56ddd5a04f12c7e  release/kernels/brs.log
e3c1cb3379580cf1aae44e8ddc8e846ef6fd661a573cfe0a8d4444b18a14dc56  release/kernels/brs.oracle.jsonl
d7759802440880aab908ebcf1a0cc9d85268cf65a8ff7d47d613fa40e530303e  release/kernels/brs.sv-hosted.log
817e10cf4e4053e7ff7ad39f5d88aeb08caefb0ac5176ba94d1f6279f76ee9ca  release/kernels/byp.by_instr.json.gz
abc40b91a9e17fff9fbce7535e120c0e1f6008ddffd6aa78284eb027985ce04e  release/kernels/byp.by_unit.json.gz
70e707155bf385f9a85a1245aa2bfff68d571c7723cb190f1b3dc06795570c25  release/kernels/byp.ccvtrace
684180b85c89aa11dc1e7fbb30ff4b92c30eb4ff4cdf388c75fa9b97c6d2197b  release/kernels/byp.log
5a03dfa4f3603fef49f1e3639e74e34152ca3ca5ef8e41eb959f8323040fa2d5  release/kernels/byp.oracle.jsonl
11da811502f5c5a8bd001b0f33a273f0fcf5a0957af127d0447a414869f7da4b  release/kernels/byp.sv-hosted.log
b517c4b8543b570cd0c8a439ef8132bd9de40c34bba67b957347fa3e73735a71  release/kernels/callret.by_instr.json.gz
e4acea68fcd47d1895f6bc6a584cd2fdff7ad79eb68b81957c522dfd0f5164d2  release/kernels/callret.by_unit.json.gz
b9b05ccbb7a867bb47673194bf89bd27d15ff6cf8067ded59577632268aafe52  release/kernels/callret.ccvtrace
2c0f904e2caa2ee78d33bd850eea68448cb9537badda461cddc3c7251d701b89  release/kernels/callret.log
9b1d1b50b527f732362f837250aa2f26dabf3e76e16a4794856ebd8f105635b8  release/kernels/callret.oracle.jsonl
7b3ba4bb709cb4121ff16237ebb36a94777cd8aa445fdf8517efbad5335d5926  release/kernels/callret.sv-hosted.log
7af658f707f745a36c6b146f5108a35948c7eaad75d9a5990c9d6375702bc044  release/kernels/cas.by_instr.json.gz
5f4daa4f811f6a6fc25f37ab2c1ef5c00148d240f3848deba4c63f89f5632721  release/kernels/cas.by_unit.json.gz
45ee28cf8ea78c37fe4597ff9b157572a01b18228d2b8472d3c1ef3a88ddf325  release/kernels/cas.ccvtrace
92810ff2b5e5b52cff6b089e5a2f12230372c02ba8b91dc8f5a50bc31001e21c  release/kernels/cas.log
0ab31a9443336fe5d08e1a5fa5fcba3bc279b19022f7c5007908d39d8ef39536  release/kernels/cas.oracle.jsonl
626a1d40d4ba69937bdc74db161e534ce35648bc7988f47226fe170241d73d8c  release/kernels/cas.sv-hosted.log
c1d036e5284104c87a4ba5e198cd38a0bd5e716c153bec6fab405250e99213c3  release/kernels/chains.by_instr.json.gz
ccd660941b0673267095e75609252662d91cba74780631c7fe20698cd42b9cd9  release/kernels/chains.by_unit.json.gz
f3c7f719a83f93768af61373514062f1b4654c87caae7a6fd23d0307b7b7ca0d  release/kernels/chains.ccvtrace
75a77a76c1d5e9f8f4777e3b28270c21a19d72afb8dff5755dd9e7b0281b7ba1  release/kernels/chains.log
26a4cc5c5524c7219d8706c2582c80357dea60be9d6ffdec99dac7d0365e2264  release/kernels/chains.oracle.jsonl
d607006ed95638805df34f33f8fb4c44b35a2319bb0b2969cc47c5e36139bd2d  release/kernels/chains.sv-hosted.log
c36bd6315ec009a488f1868824d719de48cdbb9edc0ed2b7ddd342f2b883cd97  release/kernels/coll.by_instr.json.gz
03ce339b378a6f8cd7c93c3660a4ade546e6e13d987f6004ee30761c2fe11e3a  release/kernels/coll.by_unit.json.gz
b9d0aa1fba37d6865c6e65310ddfdec12b1a406436489ff0c4ce6a811c10cdbf  release/kernels/coll.ccvtrace
fbae6259451785f0230c461784d6fb18d2602508c54ab60941d012b3e464d2be  release/kernels/coll.log
dd718d23c88df5dc7d92b055d8542865aa0e029118486af127312a8a578cfcbc  release/kernels/coll.oracle.jsonl
f203a57e9587fbfeb4cebc71f56b27d5f813d7a6608fc7dc9bb3a89819ad1dbf  release/kernels/coll.sv-hosted.log
a4ea7f701e9910001a1d85b9b96676ca354e20f719f616e5419e62d7a859856b  release/kernels/div.by_instr.json.gz
2337ce33a97158c9b33e38cea4184a8dd8c97ccdbbaa493ea4007cb78cb2b6d7  release/kernels/div.by_unit.json.gz
0fa59319a49569c81f33bc11b669b5cff44d54af88e0e1a0318682d79a62911e  release/kernels/div.ccvtrace
34b679d1c3ad3d2b5ab454412748ea8123a484b3dd821af4c073cabb7f8d8b8e  release/kernels/div.log
71a567b85cf85622631490187563de9a5661099c78a590adff4ed0a0c3d24c16  release/kernels/div.oracle.jsonl
6640ad1fdd2a5bf5fa079b1dbfb4b6ff336f2f611078001ef2e9a51599e2be0e  release/kernels/div.sv-hosted.log
357d362d3a9257dba2528a2e0d020b96b319c935fa0a0bdc8717ec0154b553ca  release/kernels/divchw.by_instr.json.gz
dc75b000b420b9ef67fa4df97d714c0f0793a38865c19c9cf41d5d490e2a7dc0  release/kernels/divchw.by_unit.json.gz
7171a5600e2647cfdb103881ce1d051b67e5c0f4b5522ff75b05208ed6ee3d4c  release/kernels/divchw.ccvtrace
fb7a68d1fe67c1bf5473c1da691f2ded3c617cd01507516ebc54dc63d48fa62c  release/kernels/divchw.log
58a541797f7a2df0a1c7528ae6a3edec212db90c7d3eb20656806f38b5c10b3d  release/kernels/divchw.oracle.jsonl
ad3d06941b015409314c9640bb4002e87546ff64ff0d4ac9c568aa9474a4a4a7  release/kernels/divchw.sv-hosted.log
51b48c5b1d93b90bf7b53b068fa94a16e5cfa7cc88241f75dfdebd86c044db77  release/kernels/divtail.by_instr.json.gz
298b363fa50906fc02f6146f8f4b32e51b8f860164879a8a3abdc78ae8fb7e7b  release/kernels/divtail.by_unit.json.gz
db804fbb5ad528ab14845763f37b3761a0b667c3bab40606320e4d62853ca751  release/kernels/divtail.ccvtrace
48678bf518174b1b1a83d43de0622166240bba01bd75c6c2399c03f2d31d2b22  release/kernels/divtail.log
75f11a75c9b3b336e446140af4579f05b46c363a76b7aab3ec88154a07ba097d  release/kernels/divtail.oracle.jsonl
add3a057eec846f5a4582b3cf950a9d9db765bfa804f4c1af30cce4aef6cf4f2  release/kernels/divtail.sv-hosted.log
ea3f8ddc3d612d778d28e31dc372ac4e09a5d89e1b179ec5d93414e529eae115  release/kernels/divtail2.by_instr.json.gz
45cd8e3b7c4f2602118ef08a6675500698d30bfc3d09f830e48cc150484d15a0  release/kernels/divtail2.by_unit.json.gz
a75fe12547373cd47764249a890c8e2cff1203790b37cff1678beeeb1c5b2c44  release/kernels/divtail2.ccvtrace
fda7dcc5b150c06c13e0cf3776275c66d4c5e75c345512fb8be501c7f5a8297c  release/kernels/divtail2.log
b2db6b05eb6cf4a0a7677e31d0c6c2952d5cab49d353f0bb1883fe0b2a20ed14  release/kernels/divtail2.oracle.jsonl
941390cccf4866883420a3b8eef233496b3ac5424ec1d4855b1a86469587450f  release/kernels/divtail2.sv-hosted.log
592d1f48d0937bd7121917707fa60e7288c575148cbca00ca763e44178c2c1fb  release/kernels/fence.by_instr.json
f49e1a2482f0499bfedb85954e7076222ddfbc826b772391cc3b506178b2088b  release/kernels/fence.by_unit.json.gz
75dbeefd2daaf5cef11628cdfe19d17d267486ec6a6fa9e0a84ab6be0c53f265  release/kernels/fence.ccvtrace
d8c05089e2d9c44ed98a10d42c7c1cb71a1738592e9009ad1ee8807726f16bab  release/kernels/fence.log
d1d40317f6cf5bfb430cda1f9c0ef676609e59cabe2a11623c42ffbeca93142b  release/kernels/fence.oracle.jsonl
4145ea38872fd10df78c01d29eb489f29cf5d51717dc3670166095e800aa14bd  release/kernels/fence.sv-hosted.log
871875f6dd1eefa453eeded9b3791f4bcd1fe08a323ec1838c5d976088dd75bf  release/kernels/gather.by_instr.json.gz
18b25862cec8077000f48feb828d5545697b613df50364ce61004e9c6f2715c6  release/kernels/gather.by_unit.json.gz
1b07ff381da27a7744b24df0bad462deb609a06d1358064fe0af4c9c960c74f3  release/kernels/gather.ccvtrace
4c9034956ab8996a5ca7dcf0ea982be1453a774ea7862226858d455833d3e3df  release/kernels/gather.log
0413e781d8d6ff578c64eb1f800b7931e66f676d5cdabb97b94a4033e6037662  release/kernels/gather.oracle.jsonl
2fdd6df067836314a53fb5154b728bf750eed07a90158c15b3917ae76ea6ab79  release/kernels/gather.sv-hosted.log
1a547a0a7e516ff01d9bbdddca24da55e71dadfcc35cd5cd98d9ce2feb3c836a  release/kernels/hit.by_instr.json.gz
071df9ffe63435bd6953524b6e480e04afc1afa7b943d26f0ff96db9b3f1c59c  release/kernels/hit.by_unit.json.gz
612a3d419e47e9b0c17059a2ed0716eed431c8212743ef8129a454054b083bff  release/kernels/hit.ccvtrace
4b588fa3eee2d8a7ac9472702b74e4565629a7c3edd63dfac4219b509ad4e324  release/kernels/hit.log
7ba9603e0088d9164de6528f16ef6a7fa9ce5821c8c12b52cbb3734e39b9fd52  release/kernels/hit.oracle.jsonl
e78e052049c4f64f2eca243d1cc8dd8f8cfdbdba9236aa37ed20a2e3e7848b00  release/kernels/hit.sv-hosted.log
2e25ecf1d47462f4a61990a9142db2d535aac0230b3cdc0678bc102fcb64a48f  release/kernels/lanectx.by_instr.json.gz
3a825f1ec7dc06aea7d3c9374ca74b8a50721810253cc572f8469a7f30589ef9  release/kernels/lanectx.by_unit.json.gz
676e0a1c1bfb92259e47e4441214679e0336f5ccce97baf948d1a0ea33cf0c39  release/kernels/lanectx.ccvtrace
938c05ea161f491989efd7c9f13b9f0788331145920a299dc6b05186410fe23e  release/kernels/lanectx.log
888551babf540db8e3025b82e65ca655013f93eba3c8a65689d069d52a7e6039  release/kernels/lanectx.oracle.jsonl
21d5f9904d9f56d0e54ab79a94ed18bf5ca4f169fe437ed6c66a0b494f6b41a4  release/kernels/lanectx.sv-hosted.log
94b89c731373fe8cf4401d1a8877cbdade0bffe9ecf80afd3d5a4145eb94224b  release/kernels/lanectx2.by_instr.json.gz
96557f72cbc3359df612020e98ca92b3d017244f7eb5f31a25b2f3a9afa7f347  release/kernels/lanectx2.by_unit.json.gz
ee7739ee3adfbdc677d7a3ae0ec74c87d0214968514e51cc5743dc73210f7a86  release/kernels/lanectx2.ccvtrace
1b8a63975d703d2e8bac20dc5cba6c120837dd3596f41b22032aa5d754d78504  release/kernels/lanectx2.log
45c13056dff5c73ed0c9ece56cc36f929bf335322193c7d5eb38710b1d1dfb02  release/kernels/lanectx2.oracle.jsonl
98f166094293af8bbc45e75e8defa3af8058207d77e54437f90bf49566b266ab  release/kernels/lanectx2.sv-hosted.log
71298ce5cb15405f1a9335277363f6e88b8095ac725b42db12ab452634568a2b  release/kernels/late.by_instr.json.gz
8f0b59eaeaa1ce0616a824d53c95404269a1f6fd4c660c6abba63596c9d3d0ab  release/kernels/late.by_unit.json.gz
01a9e024b220753e37b882a53ff1d931ac90c5daa07e718acc841108b81f341c  release/kernels/late.ccvtrace
7bbc08683213142b0dae6430361eaa7238592e30b3e52d59a3995c43016622d7  release/kernels/late.log
86084f6bd747a2cf32acbc0ebd96ebd3e4ef2d8d9e21be49e3ae49290d7927f3  release/kernels/late.oracle.jsonl
6d038551040deddd85308f813e9fd17dc641109a1e73cef16c7e8bc803ad2582  release/kernels/late.sv-hosted.log
8f7b04bf7d0686a6fa1f4c71d5aaefac49d67aaaeaeffaee850e85398e205fda  release/kernels/ldpar.by_instr.json.gz
d22b82f629e8b2b6475a4d7f0633cca25caa04196760cc52918f330a9a2add5b  release/kernels/ldpar.by_unit.json.gz
7f7a3fbec2acec70caeb9b4d7b7f02a4b0b1c77df9aa28acd4ae303d5f2e85b3  release/kernels/ldpar.ccvtrace
9f52c37eb307bded7d09b799c6a75351c43542a93da8e795dfed057eaabae313  release/kernels/ldpar.log
8ac08538e9c807637babd61b31e340f7461878ada31f0c0b83cd66331cfaf486  release/kernels/ldpar.oracle.jsonl
8cfd468c68cbba7fbdca88bffc140a43e87f2dbe808357b1d8a446b8fa4968cc  release/kernels/ldpar.sv-hosted.log
8d43bd7884a5a3c9575710621012e61c186cf4fc9fa5a8f9fb7b0e9ee4bb56b4  release/kernels/lnorm1.by_instr.json.gz
6d634d439e16056450cfa58c6d874a9965289c3cdf41bc1aa4cb32aa856cbc61  release/kernels/lnorm1.by_unit.json.gz
b80094ed9b5cedd16e1c1c1ebd75ce12379c234cf74a982a20235ee70c37935d  release/kernels/lnorm1.ccvtrace
94a983b1b87b00a5383384192d75c28f8b12b9325f92f7483dd79795d07bd222  release/kernels/lnorm1.log
a8d85811af988a1b9fc00db1517300af3d93ec8e589e403d3b9113fa9e0ffc86  release/kernels/lnorm1.oracle.jsonl
4b71b2e8f80bab5d28d33287442f395767887eeba2534d710c05159513915de0  release/kernels/lnorm1.sv-hosted.log
36be3bae982d5f597a64295b8c443dd77bd4bb92eb117e050e9bd6023f49706d  release/kernels/localsp.by_instr.json.gz
0a2cc9d442cb75dabceedc6c4b3a0ca6f14bf1c5d3436ae93d9567ec8a3a96fb  release/kernels/localsp.by_unit.json.gz
30108d5c3dbe430bd996136964446f39da37f3f32566ae0981123a64efa814a9  release/kernels/localsp.ccvtrace
409398211acac6ca33c070cc63a59165c24d5d26dad4d7f5a63f0812b3b0079f  release/kernels/localsp.log
55e3c9f36e7f7d38c0ddd38903aff4bb4509ae862015c592e6b937ea258042ca  release/kernels/localsp.oracle.jsonl
0c9c1d224132ecc5eeb27392f5df3c6cf3641db4896705c57d71a13edd0afa23  release/kernels/localsp.sv-hosted.log
3762f1d1eea05b342d783fd6b071ee53fc4543c46b02c456e873788f309ee6c0  release/kernels/loop.by_instr.json.gz
02f7d0b8c2a01c2a135e8c908362a2acfc3b10c52367b8cc18f44588e4d47026  release/kernels/loop.by_unit.json.gz
8e6c9417e35af8bbae117adade5b9d2de71420fc35abe4aae7df581e61dd52a5  release/kernels/loop.ccvtrace
f866d8a4749354e95816291f3c5889b929e80f35dfcb082fbc11fda7ea14042b  release/kernels/loop.log
03ce5920c06c93e93516d8e53c3f7169f14e3593de204eacceffc0b8a3e32016  release/kernels/loop.oracle.jsonl
397daf337db21b2128e6d21de63c7cf7d8b669ba4d1267a6181f60e8c9940d28  release/kernels/loop.sv-hosted.log
b15637eff6473ece33971021e2e5e9ddd03c1f33459d7941d2aa21fba30beab0  release/kernels/merge.by_instr.json.gz
7118195e88352a513b8037d98215e64b8c357cbcc135a879c6d294b8ccabcdc6  release/kernels/merge.by_unit.json.gz
7c5c27b8590c634e6a6fa0ce6ebc8afed33e3101ca7690ecc2efe7cde41a32b3  release/kernels/merge.ccvtrace
33e93c9c0c53e8efb684052041ab2cb0e4bcbaa6f7de81b2a0c08e514f458420  release/kernels/merge.log
f96d28815f8756b1f5a45ded53e6170883d2dfa10f9eef0d14b8050b1318164a  release/kernels/merge.oracle.jsonl
d1d01bd88b34e4bfcf1a8c80bcfd14a622ee3ac9f1392125905a85db4e1863da  release/kernels/merge.sv-hosted.log
4b292ab9810cb159574a7350b9e2b488652be04a084b0a60b25e940b6ba1f9b1  release/kernels/missrun.by_instr.json.gz
242afdac6731875633675cad192531d75f2646187e5b047fdcce685bbd0b6335  release/kernels/missrun.by_unit.json.gz
b00bd530f11d8c19cbfced59ea80388d9e122b3a4960a77421efdf002e4ef973  release/kernels/missrun.ccvtrace
4782ff541659b0a3fa7be602db5b132e0c8024719642729ae881606e40904ece  release/kernels/missrun.log
531bdaf281e5590774bd2775427f25e4cc0419cf8e3d5b6999843ffe9ef87258  release/kernels/missrun.oracle.jsonl
fcb25097a292a4e88ae9a84cc4199590ba60b1ea4529622f00d7f9398664b580  release/kernels/missrun.sv-hosted.log
8a2f0b3a16203f317d8f8e5b37e1c8db5bd2931203d2abba8ef81264907eb0f1  release/kernels/mload.by_instr.json.gz
2db028b89769cfda50b18e99d83e85df8b2a9bffe8be6d72c07f7d88c8642784  release/kernels/mload.by_unit.json.gz
790adbcad540ada593e57f65e351bee486eb890fd1c8b57658c360e427adb7f9  release/kernels/mload.ccvtrace
2e1e63b5d1878fc3bfe5e38a97e4210c5905dc4ed76238e0781e0c1b9e013ac5  release/kernels/mload.log
8000e477b9a95dfb9f0af964e8346acb9d36f1358fd06ffc4ff7cf599d2b8868  release/kernels/mload.oracle.jsonl
84a5a7f5371f867fd6de08a1b9389dc9a9ca88e3094c1b957be4b98d52a82314  release/kernels/mload.sv-hosted.log
8de47ed1b6cb4c841d72f8fa39fb4f97ff6bfb9067aa3256d99f586d57845912  release/kernels/mlp.by_instr.json.gz
ba22e2d0106a92649e17a5fcdda5c7fbb2675d54ed6e658991f435baaf246fee  release/kernels/mlp.by_unit.json.gz
b905f953896bc1f5788bf233e72298bbe386b4ece38067fd6f7fd695c77b7a6d  release/kernels/mlp.ccvtrace
e2114712ae56119c74d1725c8ebb2604aa0822dd5648d9c3dfc568342d046c85  release/kernels/mlp.log
138d282f88d56c8ad648a91af0a983254b55d9fa22942c00d47b327f516a6e44  release/kernels/mlp.oracle.jsonl
886ce975c7c5b8d4e820e4a3b8096965071cd8e3066ed6572f79bdbf4c804809  release/kernels/mlp.sv-hosted.log
75c7388a7ae499e945727f7daacc79524cf118191d8ff50b15a505805792f2a0  release/kernels/mwmiss.by_instr.json.gz
6c95c06be6c2a89356ef4bf2f09d376a1dda8b568cb0883e6bc6d87196fa75a0  release/kernels/mwmiss.by_unit.json.gz
09c6f28aa22c384cee4953ed4e2dbadff91674142e09450348f5f7ca0ca6a5cf  release/kernels/mwmiss.ccvtrace
c62f5039a65e7587ef8c3a44bc659ccd318d97e6472e460c2c25a76e798006c1  release/kernels/mwmiss.log
8abe8e8997456a2a6711ee72da54d854b24e20abbdab28e4b7271c0d28418de8  release/kernels/mwmiss.oracle.jsonl
838ddaa2fb80e9e81d10dba73e17aa3daf0671d504557c7ff9c3d0103e0a8f04  release/kernels/mwmiss.sv-hosted.log
1ce4d03fd631f174203b7f6934e0de52c06ef7f7e333ee156ce404a217d63552  release/kernels/narrowadd.by_instr.json.gz
6d97c3db265e0d9400c5ec342beebf3044ad2b48435ee6b906bc5266252ff239  release/kernels/narrowadd.by_unit.json.gz
ca362c683dfd1ae84158dff4ee1fc4968028ea6752d24619cf0e72edefad4ba7  release/kernels/narrowadd.ccvtrace
7996f0a3c636f81c340eb845035b44eecf28ff087ae83510fa2c2b3cfa8743d2  release/kernels/narrowadd.log
40a2cf629853dd404bb06b4a07e35abde3d12efc13f26ffe28f923daf2994574  release/kernels/narrowadd.oracle.jsonl
a9b2ae289e55ac953262c1fd1eb17f56b332372076fcf9be70a91eaab760cddc  release/kernels/narrowadd.sv-hosted.log
8bdc844a4ea4e37dc2e0f98ebf3ec969b04b25e30c63d2bfcd525581cd3d63f7  release/kernels/pgcross.by_instr.json.gz
3af4a405f66d4c08b263103fed243cdabd0eb68715aea7b13fe9813f3c09a146  release/kernels/pgcross.by_unit.json.gz
99feade5df9f9b2eca906eb420c5501832797c743f8f7f10e044dfa6f8dc3a32  release/kernels/pgcross.ccvtrace
455fe9c66bbc12ad338315206c8a3cd2de560cf97049d79d0a614a1fdf4be3a3  release/kernels/pgcross.log
58aba9ba5ec6a72271191c0249014802cdc7e4470d27491f499a077f17ecc039  release/kernels/pgcross.oracle.jsonl
4a8bea0711ec2be32930ecded5f9f1a63b074c28f5c5bbf0817c334e9e3b7b31  release/kernels/pgcross.sv-hosted.log
4d0d6d65007b3ed0235ef152d2c5b8f3269c31138dfcd902dc3a1d98fcf6d2d3  release/kernels/pguard.by_instr.json.gz
869f687bcae9c76de8f898cfeb2aff8470b56c9f52e20ff37465deb0bdf1b71a  release/kernels/pguard.by_unit.json.gz
ac59e51c29dd4a8d1179fee1fe87d5778cf214fe591f41a36596e881a2601566  release/kernels/pguard.ccvtrace
2e514be55c95ff3d12900a08b3aebbaee27987059b21659637bc19cf708eb851  release/kernels/pguard.log
690e56f1cb8d97cbf67124b7dff3ad0a90cb8981814cd1709cf0cd0e035b3bd9  release/kernels/pguard.oracle.jsonl
7f360db752a819c1f230bf4639980246124a906ddb691a094255ff43e0059081  release/kernels/pguard.sv-hosted.log
3b07298ddf5b7f5485bb2ec8040b0f4d3bcf85b8f4f90ede284f9b3d9806f282  release/kernels/plog.by_instr.json.gz
48dba1fc313deab9728dc74498eb25dcc11478e31043727e2e640c28673fcb72  release/kernels/plog.by_unit.json.gz
7823562f75147705b01f772471b6175774023d19935926703e158062b24cf94d  release/kernels/plog.ccvtrace
5dd800c35e450251b77b9013e871ed605a01b3b79d999d146ceaa0132460cb94  release/kernels/plog.log
0c99915e2da60f4670da00504a6371d7d17701d4431e733a3ff8fa98a2030d6a  release/kernels/plog.oracle.jsonl
ece18c124d5c641e87a1588ba8da42f157f657a41dd05ac07df5eef12253d6d3  release/kernels/plog.sv-hosted.log
0af2b0b8ac2a2df6cf6584b050238d5bb4cfc818bcf05dba2d25fe646c4231e9  release/kernels/pmovdiv.by_instr.json.gz
106fb61c9943c28a3bf04fdc4d39b18f7351482ad677d292d7a6494a7cebfbbd  release/kernels/pmovdiv.by_unit.json.gz
da1865544271c3c70d3eab1061f5060d833a856975f75b28d0921880ec954a97  release/kernels/pmovdiv.ccvtrace
1fb7bbeb928dfa33ad6976c7ff0885380d55798d1f12a3986ee5bcb1a2a90d25  release/kernels/pmovdiv.log
7bc646cff6166a51bdce03d7c1b7209e871f0a91d743083a9b910a80bcd0b33f  release/kernels/pmovdiv.oracle.jsonl
2336eb9b8c79493fdfe05e411dd3e8cbc662f9421b76141908cebe9a3e4449cf  release/kernels/pmovdiv.sv-hosted.log
22a3c4ab3d6548db50c579d1f3b6c9e4acbe269a2996041de271691c86e4786a  release/kernels/predlane.by_instr.json.gz
aa3ddeeec236ecb419551ce15e54871de85a8b6d89b52605684b3616dae32ee5  release/kernels/predlane.by_unit.json.gz
f2c4e771d73fe1fe9f5c718f6ba74ddcac133f335a8911c99691380bd04f0268  release/kernels/predlane.ccvtrace
4f5c315278af5d7b7cd1745f5fa1c9586b79966aac23429b40df2a6c11bb04e5  release/kernels/predlane.log
c45f4177b9e84fc8a6e36b13534a0c7636eb30a3f8531847100ce5e23bf404b1  release/kernels/predlane.oracle.jsonl
9b15e945fa85a866561b143cac6cceb8bac31bb3fcc0d4331932d1edfcb08f2e  release/kernels/predlane.sv-hosted.log
0875a7f98585a4acaea35cd788ce0b4b50755e8d59bf668097e9b5fadf90f7bb  release/kernels/predmerge.by_instr.json.gz
5dea41517aa3bbd041be20ca68e7eae094f815f5dada65abd272bdca8c01b9fc  release/kernels/predmerge.by_unit.json.gz
745a2074a86865f389cc443817052e25d3d5938b6d845c443ea59b15f1d05b2b  release/kernels/predmerge.ccvtrace
7faf372c46056a939f4fb2c6eae629cae2f49cc35e1788960b99e85ebeae48d3  release/kernels/predmerge.log
6c737c49434bcd08e3e0814c8b1dbf15c586ae74f7929ba3148ddcee2c62c845  release/kernels/predmerge.oracle.jsonl
e59d77730452dd8cc76a10e24f283fba1cc412b248ce4f7d3ee854dd979187c1  release/kernels/predmerge.sv-hosted.log
56ee5afcaf082048a44adb3f4fa94c8f2b18e04319f861188b77431c1f58c148  release/kernels/predspill.by_instr.json.gz
04a0be3c81b586749fd46473f548d317cdfebeb7f95f1df553067f1f060abace  release/kernels/predspill.by_unit.json.gz
dc226bd8dc783230d00e3eda3e5937882e7e1672f578ac91e632db6260cac3b6  release/kernels/predspill.ccvtrace
ce9e896c491b96b3f48d4dd3ced4510e123f4ea336826c1c8cf36006816667fc  release/kernels/predspill.log
b7c84c6478117ffa0f06da0e6ad1e4628e2683426a7911080810e78e06a5242e  release/kernels/predspill.oracle.jsonl
0c16f14e63c11765a86b692e0537e13e7691de1406bbcfba1b041713702a0d4d  release/kernels/predspill.sv-hosted.log
f0b2ada8eb4e539a43743c58c44504cf08634e8911897d39941a565119f0b74f  release/kernels/predswap.by_instr.json.gz
9058ec603a2bde487af4b10a38565a9e31be6ab1b17bdc99dedf904834c3a7ef  release/kernels/predswap.by_unit.json.gz
c26aae306b8e7b8a7b34b1f1af0b103094c9689c1125529c3483410c8ab600fa  release/kernels/predswap.ccvtrace
367395ec06f0de718c1c19353cda3dc36a9252302f0fb689b37cb916384c05db  release/kernels/predswap.log
a6d4f7ed517553816d889c7c9eeb6bcfd1f6c973fbf682ecb69f3c2de619f7bb  release/kernels/predswap.oracle.jsonl
99bda2c9854d116f15ab188fb31ab4c08ef341274796996612f401427bb1b766  release/kernels/predswap.sv-hosted.log
e9f7a5482d964cd8ffcaa39593be6ca00294d27ea2ca9c456f107ae0b4db6792  release/kernels/privwin.by_instr.json.gz
5cf87c880d0e079f320f9898c61fff779bcff55fb53f99c6e1ff642591ec2028  release/kernels/privwin.by_unit.json.gz
1d18d24bcc44d96b2806790509ab63a9d776374efe9925a66409a7c9623a2885  release/kernels/privwin.ccvtrace
4d2979ac4ab0ee9cd7c8cda5ad46d9dc2ca40440c2859d8c1730dab1a5ef056b  release/kernels/privwin.log
861f686fc4480363472908d679d8815e8c957d768e7ab32c826930527b0fb7a8  release/kernels/privwin.oracle.jsonl
1335077027a17b9358c63f4e72c09b2f3c80616d58b69e62280a92cbb01bbfa1  release/kernels/privwin.sv-hosted.log
e61ee0f4aad4cccf1786eeecada383d4387625f855654dfb9126f0810c1655fc  release/kernels/provswap.by_instr.json.gz
d90d395a54b55158c4abc8fa69f2ca003690ac2da0f58e058e70e3f9c0d144c7  release/kernels/provswap.by_unit.json.gz
d10df1f4c99aefe57851dc71fcfc5d941b8aee0fd33faae68b51b90c341f48f7  release/kernels/provswap.ccvtrace
c51a2d0144d451f0d0bd5c7f01097960b965f1a2a021cf9523c04f8eeb55e5f5  release/kernels/provswap.log
c9c32a793d54cc7401477f582487f7e8b345b2669a75337b8d6327120d98e5dc  release/kernels/provswap.oracle.jsonl
bd2765175fcc685960ac600e778d30931a93df74dc1f8a8eb86a04b5b6ea342a  release/kernels/provswap.sv-hosted.log
4c37454c5ea8235eaf52be600769a1c05dd87721c78928014c8d21b2a059c136  release/kernels/retmiss.by_instr.json.gz
229d1ebdd93d8ba934a1988b860bd130b3ac7f0cf90ae59c6f54a977f396b4dd  release/kernels/retmiss.by_unit.json.gz
ce0129ebf8f86ca16feb4e5a909cd715b679f9642f6e7ff7a8b30f7327ccb9b3  release/kernels/retmiss.ccvtrace
6741cdcef6adde227ee6f6ae609171e0f30860fc63bd14047ede6239fc8b34e6  release/kernels/retmiss.log
e5ef8538e838c6cff7febfc679dd091cf5e002f82d34f1009b1948ce22bc3649  release/kernels/retmiss.oracle.jsonl
0416830f859a6c8e4c6747b69075d94c7a63a641bf8b6c2cbb7c77b935e772ab  release/kernels/retmiss.sv-hosted.log
b8af37455b33a1b36ab55a477d4761f76bdf9dd3edd8eab5fb7f2c3731ac8ec5  release/kernels/roconst.by_instr.json
1bd6e3d57918f6dc12f88a90fbad3431d9d6ab8123f8959ed02ca7c9430da7dc  release/kernels/roconst.by_unit.json
55981e07a1a8d3ed8b7a9f6797e5f718e3161cc5f6e1218171db77f9b6115f18  release/kernels/roconst.ccvtrace
ff94a2918fb8a411a7bca72900e139969eb9788e56c8839af7eae053dd9185e7  release/kernels/roconst.log
8087c0671de620162881aecd38cd6114b78e7be6bd71201e3ec02c9a2e2e750e  release/kernels/roconst.oracle.jsonl
9be0f6e8d6b49e378f9612b3c6e205998fe8e0c9c88fcc4e72f299579d472bd2  release/kernels/roconst.sv-hosted.log
10c797fb8d044649f6d3dee9c07281c225794258b33e21124d781108ba92c747  release/kernels/rogated.by_instr.json
7887ba0f87e9025a705fa9f5cf665db27ea07661fdddcd665a26dc6bdd3b699b  release/kernels/rogated.by_unit.json.gz
efce29ea7c5e82d9ca9f5522549f4958218e9ae67a9114f6c26c60f34501ba52  release/kernels/rogated.ccvtrace
123202deab65d07ae58b4f5e0d3e057b8240c73d133d058df16afbdf7b8d1355  release/kernels/rogated.log
7cd02bd4cceec5a044d6b4d6a80df1e68ed0ae71b0b2a953143636d5b809ea6c  release/kernels/rogated.oracle.jsonl
8623d5a110c452e42e9bb96e101fa1e1e875050c43b1bea66b47972060bef4e6  release/kernels/rogated.sv-hosted.log
f2125eef00c70347f6ea5b384e663175b12b28d570b468a363d0e6fe612ea1b4  release/kernels/rokill.by_instr.json.gz
7bb6f9c25fe4990150ce6470e006b667d20650dda4570c64fc3a13ee4291dade  release/kernels/rokill.by_unit.json.gz
8a540e1a67dce0d3845964ab547fce4b1c674a042f6be8c8d8c8b7dd46f4663e  release/kernels/rokill.ccvtrace
a79d727e80bb32b05293ca69e95d1b3946c235aaa107095c53edf9419f0202e5  release/kernels/rokill.log
94efcef96af469a512d346ce61623980fe86383188eaebd55120f716db596f14  release/kernels/rokill.oracle.jsonl
57d3a6605ab5e28992a84d585a45f8b1e8cc8aad85bd74e55523bb2eb06f57ba  release/kernels/rokill.sv-hosted.log
7db3bec768c361e4e7bcf06a9931025d849d1d2d5b1f7d5e749b8bbb21000d1e  release/kernels/rokilllane.by_instr.json.gz
e77b95b31c18723334420aa41576ff915c5dc508adcf3cf7ab4be8be0b38bbd3  release/kernels/rokilllane.by_unit.json.gz
c54a973f624a7ad5b95499138a725ad2287a564534121f4f568394896b3522b8  release/kernels/rokilllane.ccvtrace
f595321fb7ad42f9333ba3e2a7cb9bef3dabcfa3db38e03b6675eec8f9bb84dd  release/kernels/rokilllane.log
f5ca6e666eff2f44894df74a291b43b3c0e7be0a63a47d795fdefd7b22016f45  release/kernels/rokilllane.oracle.jsonl
b2b8f803f0e7fb6cee457878130d34919a50a6594b23cfca7c227315d6fb107e  release/kernels/rokilllane.sv-hosted.log
6018676757a05a45231fba12ff6df60d07f415338c1d836cc09d99465b73577e  release/kernels/rolaunch.by_instr.json
8512780fe1bbc0571a43ff91654c0ffdb7545b9c1ac040c907e50a29bfbd10d3  release/kernels/rolaunch.by_unit.json
289a78e36e414127402cf1c2f9514ddf7965e2988e5c5c2c172bf77c872262d4  release/kernels/rolaunch.ccvtrace
371d15ae379840f4207401ff871dfc5ae5deffff3e4b1034c83ddbc66f6a3d0d  release/kernels/rolaunch.log
e7dad585c3e70615de04330fd03f4f282c29a005dc1732a35655fb261d51139e  release/kernels/rolaunch.oracle.jsonl
b15d96e8c841c7f529ae322dea5e66618eb8cb214438879759f081aa2cc79834  release/kernels/rolaunch.sv-hosted.log
b8af37455b33a1b36ab55a477d4761f76bdf9dd3edd8eab5fb7f2c3731ac8ec5  release/kernels/rolimit.by_instr.json
0e20aabf7e39b687a2ade0f80fd977c9d7bd313c2cebdac11d43f35296e7d911  release/kernels/rolimit.by_unit.json
6105e32f751a15c0875d0d2a30a1e054656c0475286b5e2739728e13fa4d3e83  release/kernels/rolimit.ccvtrace
7832f04ccde4ecad3e94da09fd6ef61a15bcf77b29a10fd6cda4cb4c1313b48c  release/kernels/rolimit.log
1c5bc0cb8e8b2e69505fb5a551a16d5d10c56f232b88da7a27e336ad7d962de2  release/kernels/rolimit.oracle.jsonl
dd71c61f974f953048c6f71d9aaeae9a562687209c34337472d665b64de34454  release/kernels/rolimit.sv-hosted.log
8be0a889c603b9508758777fc3d1d8f30b8e8d791c74671e57305188693d6297  release/kernels/roload.by_instr.json.gz
7fe32b9b52314aa03978f086af6efd31dfa21c47b26f3ad42560118eab8be979  release/kernels/roload.by_unit.json.gz
0194db79692e1ecf3808cdb94cae8661210c638970d53bbfa7df11bc0d70ed6d  release/kernels/roload.ccvtrace
fcc3b2d334bdcfcae1f619e84883ff1eac360f81c71aa48b3075b0f907b9b302  release/kernels/roload.log
f7c1309cc9764769fb5803f6fd0f2f5e1eb418f2d23fbe5e17cf5f9106869fdf  release/kernels/roload.oracle.jsonl
c23577dd9a4020541ecd8c78670ee626dec9dae34c27a97b98cc6db2de3f4f60  release/kernels/roload.sv-hosted.log
e2e711daa552c9489959414e7530dc8b43b760211cf6848e30d7a01e713c2786  release/kernels/rope.by_instr.json.gz
b32254b82dcd9dfaf6ea7dbd170070e9e6ff4175eadf6072f581df51373ca057  release/kernels/rope.by_unit.json.gz
5e957881cb0c366d8ccd4ee65eb92b6c5ba42999e853dbc2a91b4ec1db726796  release/kernels/rope.ccvtrace
6098bf8f8f071afefe0454906467e7a51b3c29236881e4ac7f18575e79c401b2  release/kernels/rope.log
d55f9efae392dc8877c102c01c0810e7654b666b6ede386328108164c6cf88f3  release/kernels/rope.oracle.jsonl
45923395765794d5361f538f688c37d07ee9a17ce0cce63c4d37fe2c523067ff  release/kernels/rope.sv-hosted.log
ec07f696d8ec953f91927d0144255ee03b05b1841b095bb6990431139748728e  release/kernels/ropediv.by_instr.json.gz
85e65491e3931e7d4da78a8bcb2176943dfc5c5e57a191dfc7bc3e11f28471c3  release/kernels/ropediv.by_unit.json.gz
5a0b9795628a100bfc0332f4c3dec76db4a769bed0810433eff007e1204be741  release/kernels/ropediv.ccvtrace
d2435c5275e9e649d73142c96b6858d14a471b268a944dad943def4be7e1a6e1  release/kernels/ropediv.log
10c0ec6ec18b7b44638c790033109198c079d07c1537bf193353ccedd00a920f  release/kernels/ropediv.oracle.jsonl
f129e97948328e70870e57aebe8b07e6fb03c029c0a968e45275ab7320e97280  release/kernels/ropediv.sv-hosted.log
7bf1fc9de10be15186e055beb87f74c80a867d5416c7d8993f1764532e2585a5  release/kernels/sel.by_instr.json.gz
06e8c8f6bd5f3b5eb187d8c32f855526f9cb81f884426c67c74f5f3fd9bb432d  release/kernels/sel.by_unit.json.gz
9c53eebe2b618f054a586665b1b4ded69152979d8a322800f723264581b649f8  release/kernels/sel.ccvtrace
b8f0aea93813d06d71ed246ad987d811e6fdcd29ac2f40c242efe42c9dcf0f24  release/kernels/sel.log
87f6a81e8afa004c8039bf2f61c90176fcf29ab29bb17ac44aa016a5cc8438fe  release/kernels/sel.oracle.jsonl
f13653dcbd722d0a94d4b64256679f3b15541ebaefb7780a14e0515679ed8f2f  release/kernels/sel.sv-hosted.log
6013039991c767e9b3ac05a162d4006c8ec5f2fb60d5341580c4514caf8ce942  release/kernels/sized.by_instr.json.gz
aff822e9bc9aa20e3ae0b976aecab994bfac6b53393f6388de7e5c6f87af010c  release/kernels/sized.by_unit.json.gz
9ddf8dc62025f1e52adc724455b9c71ac8280d0996df3a3927d43ed75986b2ef  release/kernels/sized.ccvtrace
bc2fbc1e9089cb3762a267e1c109b3f0b5eb570ae43e1298d73406da9c1e9db2  release/kernels/sized.log
36d903ba1618bd1faa437c9812a6ee6c0c966a63196c796267d74bf2695ebc3d  release/kernels/sized.oracle.jsonl
9022f68488c80627a1cfd8b57e5173cdbf645cbac50f2ec9c3fc6813b2db9db8  release/kernels/sized.sv-hosted.log
ac180c3078aaf117215b93d67a365737636005eadd869825705382bfafe728bf  release/kernels/slotform.by_instr.json.gz
dc54a650adbac3f542f2079bd6baf785e31cf4f29489982160a6294776b477ab  release/kernels/slotform.by_unit.json.gz
d817b5a56b97569f4b839e78b66d5be186543c10b5343dc84eac5ee0dc4b1f87  release/kernels/slotform.ccvtrace
a6b73850ce6cfb796b5cc1f1d7753f4dedb584e9c17f3b7aff79eb4db6a1a52a  release/kernels/slotform.log
8b61db7419b18cea8a646fb628218447e72e84a18a9891ffb73b441736138ab9  release/kernels/slotform.oracle.jsonl
18a82011b961b5c1b2e835f76a67dde2397030989681228986d96f548b46c1d8  release/kernels/slotform.sv-hosted.log
18b8f9a4939a67c76f74803b1909d4f28d81fc3b17efd0c082d32c3035ade72c  release/kernels/spinwait.by_instr.json.gz
c6c6fb9398091638c0b9fa3fa5ea0518e7596a8bc94d477b1588bbe6d5ff817c  release/kernels/spinwait.by_unit.json.gz
d862f76f68698bc1a90901e48cb7aa5bd0f3c5251402ba2c3ed246791d83eb33  release/kernels/spinwait.ccvtrace
714ad6121a5cc9b9a35d0abaa7ff923ce127a2ea957acc01451dad385cf1545a  release/kernels/spinwait.log
868920637236c878b33779bd450439466fc3626996a3164573dc11d437d5c709  release/kernels/spinwait.oracle.jsonl
e8218ea3a04663774a9a1d7625bc0acc3846f1f4390eeac74b6d2ed02feec18e  release/kernels/spinwait.sv-hosted.log
e3f9b1d031531762f2a854c24da3e35f992c9e7d1b20f1c7fab54495506b46e6  release/kernels/spmbank.by_instr.json.gz
a3a838a71b8a9a1afe6d0f95e0f51ed1840e4527f3c62d6f4aaa09f773d0aa8e  release/kernels/spmbank.by_unit.json.gz
0b63ddd199108d5d57dacf8da3b47f37f0c4b36c8ae2b2605a61415aba0d0ef1  release/kernels/spmbank.ccvtrace
6097b6dacb597c0bd06c7e502815be57848570f1c9de4541c4f4618e1025ba1f  release/kernels/spmbank.log
3af490cc37d7a92dbe719b57de216b648536eb301ff9d13de9a39f50d150d725  release/kernels/spmbank.oracle.jsonl
c14c34ff074a524747a25cccdeda8f1831d4c53468b9f26d6fac5f6c715826b2  release/kernels/spmbank.sv-hosted.log
27bee002ef72fee4011dad1d34547c6a6715c4db6bebc500a21de2bf70a9752a  release/kernels/srd.by_instr.json.gz
d882bfb3f921d9227c3bb83028a4d5eb5a51c6adbb02db05db0eeab9a21e3e45  release/kernels/srd.by_unit.json.gz
d0cdd0ba564115a18c44c0930bbb53b299072ff23d43f1accf29a4ebf90d01b3  release/kernels/srd.ccvtrace
3457e8d78f7b3da9840d7885eb9b6c0a0244ea0ddda73e0067bffe9e9c98d744  release/kernels/srd.log
b08eb5e3673cac7eebb8b72af5ed3783c8e70a9e96592e76bf3722551bc79473  release/kernels/srd.oracle.jsonl
3b3a0b5b6e47e103ced2539816bff22d4f71ac02872b0f6c713c6a179f2045c5  release/kernels/srd.sv-hosted.log
c61b22f0861eb9db917627a79393b38afa0eba5bb855c122c83dc4f09c51eeb0  release/kernels/stall.by_instr.json.gz
96b02596f748e65d93acc87e7fd3c1679283f54bc4edad87a255b503f32feee8  release/kernels/stall.by_unit.json.gz
2208df4c4267d1f26ae44f2c181c59791e818b1049109c98383c80aab98ba0c7  release/kernels/stall.ccvtrace
0e83017402b6ebfc90193c3fe1ec1c57697746a8c92242d3bfbbb54e526ce698  release/kernels/stall.log
500db2c482b07a0706583422cd68878301d0146c1f872ccc1f11bfdcf5c993ef  release/kernels/stall.oracle.jsonl
2eebdf40d44d87977c138a90c0357b24e142acf49ce85710190f69e1600af7e2  release/kernels/stall.sv-hosted.log
6ecfbb1293e4050a7fc582a7ac45d833e2f01d5c0d061b355d96a0d325a9cee4  release/kernels/swap.by_instr.json.gz
47d69341f566a152f035e0bedac4515244518470f8ddfbe113a29edeadf1ce1b  release/kernels/swap.by_unit.json.gz
d5b26fc6d43b0d5e56f3b160b1ffcccb80d905f055af19fd6fc051f94e051837  release/kernels/swap.ccvtrace
51b7d55aa98bb09dd8f550da4e6be54998204c11fa0dc48faa94ab523c754bd4  release/kernels/swap.log
3658a26316c1ff7bc1744304a42f736e930fcde2865c8913e6cc67a22ce96667  release/kernels/swap.oracle.jsonl
6c14ca27814670a80b8cb05679c7c6c05664f6dd79c6aa6e2718e884d3c7ac20  release/kernels/swap.sv-hosted.log
263a648b566567ad43563176975e5963df52115377410e9b29de3b50a441612a  release/kernels/transp4.by_instr.json.gz
a75fe53f960a1a481ecc69d1d0a333b344ab270a1aa50a45786bd7100b939faf  release/kernels/transp4.by_unit.json.gz
c388463e19738164eb38969eb4f57ca71ebda3a12ec2364818042fe30c703391  release/kernels/transp4.ccvtrace
a344611b3b1d958cf39c497cdc7f7dbf191db1be0a201f3dad4ae1e756f8a4d6  release/kernels/transp4.log
06396ace3ac19677fd39c700e408606e5bdbacb24997d663bbe8872e63dd74fc  release/kernels/transp4.oracle.jsonl
46f4b6651d69cb8a85fd7a3365aa6ab178d29435ce934e89db8562673b9a9054  release/kernels/transp4.sv-hosted.log
be791dea6445b80dbb3ebf0ac44c15c3be9ea971fbe841e6ad2ac477e21bca05  release/kernels/unal.by_instr.json.gz
6b8e9cf0f917f224ba9cc3bbf0ab4581214831c6df82e20e01fc9347b4e2d44f  release/kernels/unal.by_unit.json.gz
62ef4af21616ab31f4f23ca2dec656fa2f260691eddb44895b7a023759fd98b5  release/kernels/unal.ccvtrace
2e3869bbbfb2eaaa261b4d85139f6600a6d0cf6045cc4da02c08f924f14b421a  release/kernels/unal.log
c3d484bb160657a563df983d9a2532eac27f556636617960aa1e72183ac2b299  release/kernels/unal.oracle.jsonl
dd957c1a2c0c7525fc8127900de32974bf9a01915bbe42cff033173fd7f8460b  release/kernels/unal.sv-hosted.log
ab636b265020aa7686edded20b4f2c1291741c57f49861ecf37a04c028fd78ad  release/kernels/vadd.by_instr.json.gz
295f14296f119e508bd1fb0cb6097ac9507d1d5a52f9a5a7603e972788e1fd2b  release/kernels/vadd.by_unit.json.gz
c3c8c14a7aaa95a2520a64971ac207b1e8dbb289e3a6ef8fb9d7ffb935a4231c  release/kernels/vadd.ccvtrace
c7d3eabb67601c4c8601f04d4973f022abb56802b1e9542d7547b74980329a69  release/kernels/vadd.log
0276b6d0611a4bbcdc004ab3987214aea138245bc7217504147331689a9c0880  release/kernels/vadd.oracle.jsonl
09858e25b2dec1dba60aa10ac69d59397bf8a3b39398f1616a308a368e241a4e  release/kernels/vadd.sv-hosted.log
2f16fd75d8bb6cb16278e30e8fea9bfdb077a362083ca9fc27d0f73591f87435  release/kernels/vadd4.by_instr.json.gz
a7d57a67cb5d782b4e2dc571933dd0c071faa4b234e27cb53b24cfe9f54742d6  release/kernels/vadd4.by_unit.json.gz
2dd112030ce67c5ca62959e4a6df118564afbc9bcd218d7708f42dc279b9914b  release/kernels/vadd4.ccvtrace
75772c0dbc8470d0fbcd62f27f3f9acf9dead3028d2cdb4d80bddcc6fa784795  release/kernels/vadd4.log
225aa18fc9f38aa9ad615aa11de254337d59fa705877553d873062c68366e0db  release/kernels/vadd4.oracle.jsonl
a625c24ed1b23223bab768fcb9382ac86814113bf26657033bcca9386eeb1134  release/kernels/vadd4.sv-hosted.log
93f30f07acfd33c140f62e7953a398752ef9acb0a326d53c86cc901d917a6f2e  release/kernels/vaddslow.by_instr.json.gz
b81d1f7c2b2b17d2f69cfd5363c1ed9cfa7e6585434254a593a1589e48108d7a  release/kernels/vaddslow.by_unit.json.gz
c69b1eaa871bc33634e98cb0a54cd8170391ff06583c7c19375110acc3112cca  release/kernels/vaddslow.ccvtrace
3611036e09ac427e98ab9914f8a5a2844abd86e5a4e128e6138044a2eb15db56  release/kernels/vaddslow.log
e9e6218e8b8450e9f9ff6b39d659c994a1e51c527a0c5bd10d18b5658ae0e344  release/kernels/vaddslow.oracle.jsonl
17fe5f9c9720dae735de91246f649b732d872a8056f54bb0c7e9c1835a50b871  release/kernels/vaddslow.sv-hosted.log
22f73582f563be6b748ba7833d28aa91a369d8a4d529d34e185138189c063214  release/kernels/waypred.by_instr.json.gz
9f85c546d6ed022329afcf12f8773895ceff5f42355b069b7eee555db6e553e9  release/kernels/waypred.by_unit.json.gz
93332dd6951ed50865d6b5ec1b30f82b438515f86d448331dc124a203b080fc5  release/kernels/waypred.ccvtrace
95697c664cbe3a63d683b0e9851efd403eaecb424a41620bb106842bc7ea833b  release/kernels/waypred.log
c8833938fa0199fa850184f9c93413283b4148a4bd7f1763d5597c544f14ad5e  release/kernels/waypred.oracle.jsonl
5fc886a37cff123ab415e617ba3aaa35990fe984adca76415ea304654594aa12  release/kernels/waypred.sv-hosted.log
96bdc4860b9769ebd20b2feea9bee2af3628ecd636ee9c6a3d66663b994bd6c6  release/verify.log
f78197fa73514d4391564b6dbfda61c3c03a38e2134c9ddc2d24180f29c72e6c  release/wiring.txt
```
