# Snapshot snapshot-2026-11-23-7696e42

**A generated, read-only snapshot. Do not edit or merge it.** The source
is `ccr-9eb50716-lecnjf` at `7696e42ce8c75fd814a595c26e18ff95a0c3c6ae`, and this branch is rebuilt from source by
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
| Source | `ccr-9eb50716-lecnjf` @ `7696e42ce8c75fd814a595c26e18ff95a0c3c6ae` |
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
24840b94c69e92dd1afd98025d3147d911300b23bedc09527d61e17d499660b6  release/kernels/addrhigh.by_instr.json.gz
dce6114c6c69f7bc35f6a588843bee6c1d7937e0cdcb121ef1182b518c3a78a0  release/kernels/addrhigh.by_unit.json.gz
77bc0c3be8e830d8723acdd7c4f9eb29f4078b3115874372bc60e68aa53b7183  release/kernels/addrhigh.ccvtrace
4a748fd2428f8f748bc3385fd0da079cb05b3c4495a6a039d5bbd8768242cce6  release/kernels/addrhigh.log
569f2e22883fad5f0956c57ec734e6afbdd4b8a854e50277425172d6c0cbd766  release/kernels/addrhigh.oracle.jsonl
850659ef3a857fe14acb157d50f55bd1499cf3191cdb249305faa27d3c2d0d86  release/kernels/addrhigh.sv-hosted.log
8c3c69aeee911c0af65ab248e23004dcfbef9189634476f18c376caa596cf842  release/kernels/addrlimit.by_instr.json
3b35fee568600ef154c0e28928da998f194ab417705d71f582090dddfccd0ef7  release/kernels/addrlimit.by_unit.json
468c0908614c5661e9d860b55a9178899a4477c703f33d0f195813e281cd5610  release/kernels/addrlimit.ccvtrace
f29bc5a6d59f98d72f416219987b9fb54ee515ae49604e2af42c3af85b1bc769  release/kernels/addrlimit.log
bc660b0b40359a2c5a2478cb0eb4950b73fd22db50ea76b80052bc195a1920f4  release/kernels/addrlimit.oracle.jsonl
7c0d95e8a53a49e1c0fe3cdc8e4576535905474f85f3f63608dd9c511bd2df3d  release/kernels/addrlimit.sv-hosted.log
d5ee993d0a633a3a0837df8a1267138a4a90d71b0f13f2964db1fac129be4751  release/kernels/addrneg.by_instr.json
d4575a0211ba3cad70a041dab45c9876f749ac9173cd91604056151f0cb47c9b  release/kernels/addrneg.by_unit.json
b64cab0cffa732e5e0822d4d5e4704e4625cec46309de4e9af4fa929274a37fb  release/kernels/addrneg.ccvtrace
790335dd5f79e058d5608736614f06f40582b917d8c0b4c8413964aed5f56bd8  release/kernels/addrneg.log
16f5b0707ae44492a1efd67bb9dd38a7e79a7bbd354fa9207b9e7d150ff2f107  release/kernels/addrneg.oracle.jsonl
1cce327c169a826406b2c73ca368d53defeeaeec66d1278f1f544df8b23fb9ac  release/kernels/addrneg.sv-hosted.log
fecfeeeb0f005817d1de0aa119e6a1fbb730f190a73045acafee59b385eadf00  release/kernels/atom.by_instr.json.gz
30f2b040eb0e6a278f9de30fafabfbd2e54ca73335b50ccfce6317e9b74cd4de  release/kernels/atom.by_unit.json.gz
e52662d078aed7d484789b3150f99f6c99f9b9821d86a5e9bbd8cd5909299165  release/kernels/atom.ccvtrace
665eea1313806fcbc1c9d86557fca3132bc20b9a7a0327933fff8fb546ce6445  release/kernels/atom.log
504f5b6e9d25114dc35f2c70b21bb7b3f3c508c691de12dc0e87d12a74285361  release/kernels/atom.oracle.jsonl
91f3bd25333833fbbffe3bb3dd1ed89631e22170be685274464e0c256ff42511  release/kernels/atom.sv-hosted.log
f57cf7a01a7bbe1dbe31b325b5a9ae6739c49c425649c05b4083a23afb6d70ed  release/kernels/atomf.by_instr.json.gz
bcd9c79e1a9dabc9e0a02db6a641af2ddb8f52d1a4cc819a621901d5ed59fb3d  release/kernels/atomf.by_unit.json.gz
e249348e60083200e6314e3614e53460618456d16fdd85e004a0cea8ffd17787  release/kernels/atomf.ccvtrace
8d931b20157a1c7a1e8947919b0f1bce36503b52ab081d44ba947bd939a023ef  release/kernels/atomf.log
cfd1179edf4061a33ab2f75d7a6dec61decfe629000198189a7bfc2647b34238  release/kernels/atomf.oracle.jsonl
47dfacdd0853822be93a5904a574fff32721d8f15d809c37502a71907ba508c3  release/kernels/atomf.sv-hosted.log
1eb5f82a18777aa832070a9397e3ebdec02333231b21052b983ab7992bc3d12f  release/kernels/borrow.by_instr.json.gz
257b1a6cc902bd362ebbd3f851157a1a9a6628634759b0335f9a5abb84c98d00  release/kernels/borrow.by_unit.json.gz
675e87f1c0e15b984bee253fff4849e79de6b07f83e6e28edfa102cf07f93b18  release/kernels/borrow.ccvtrace
3fe067ff87cedaac70132be811b2678a530601d3b15c2c62c767940bf6c83177  release/kernels/borrow.log
4c565e1ce0b3baee36e158694b32c8defb5cd662b2f9af75cb5d8c26cb1168ed  release/kernels/borrow.oracle.jsonl
76d55343c4c454ed551a96ab994282290b82fcf41c3e88c5ba271077ef7e51cc  release/kernels/borrow.sv-hosted.log
8278dedb35a425af3b4d0c723da11de1d27da5e5142f474268a57000aae102c2  release/kernels/brs.by_instr.json.gz
2aa774521df9929695901602986f95fcc2a5ae96e5409b8edfa68d036f811c42  release/kernels/brs.by_unit.json.gz
dfdc00e3f7e638e036c8544c04704d8c1d4cca764d189ea7aa1e0739036dbfac  release/kernels/brs.ccvtrace
eaf7a33c5651c8a9435b727b76b1da508aa9a5b7824234a55d9bbcfbfa155d2b  release/kernels/brs.log
e3c1cb3379580cf1aae44e8ddc8e846ef6fd661a573cfe0a8d4444b18a14dc56  release/kernels/brs.oracle.jsonl
428edf65bed8f2d4aeb53497874dafc0fc7f0c3900af6ef8becdd69d3922ffd1  release/kernels/brs.sv-hosted.log
e10ecb45032eaa40826380027d1b9a8f8bd31fae14a5c60cb061d1fa4561f596  release/kernels/byp.by_instr.json.gz
90e8b42a8bdccc6a7c2831da88f9b4baa572082f28024c9be569572661af0511  release/kernels/byp.by_unit.json.gz
1fb04b879fcd06185cbcd79e0db7e22f64c7784eebfcb96b8f923b6e165efa01  release/kernels/byp.ccvtrace
5f133659563ab6b50dcbbcd29849526a0151e1c8e7147a43ec0f57717f8332b9  release/kernels/byp.log
5a03dfa4f3603fef49f1e3639e74e34152ca3ca5ef8e41eb959f8323040fa2d5  release/kernels/byp.oracle.jsonl
24a8af0bb3cd7dc21dadb5226ec707de53e87cf5eab81ecc16db200c56eaa122  release/kernels/byp.sv-hosted.log
000b5f6a0303cc9858a93060ae22b4403468b8d42bb948a6f182ded13671026a  release/kernels/callret.by_instr.json.gz
85ced7bc067ed8b36bec3aa03cf0849e45826422dd9ec52dbd2fd3c96539004a  release/kernels/callret.by_unit.json.gz
fc79cb4fe9f9b9f252e851c20fce32bcbd50757bbc898e386566e57505539b55  release/kernels/callret.ccvtrace
c6b82cfc22fe00721d417559986b31ce6c400b02bd4865a99d4335648dc829a8  release/kernels/callret.log
9b1d1b50b527f732362f837250aa2f26dabf3e76e16a4794856ebd8f105635b8  release/kernels/callret.oracle.jsonl
42fec1aff5d8a242964aca7577227c906c134331ed0d497fe0dceb85b8848cc5  release/kernels/callret.sv-hosted.log
4b630b4b7002f6323ef044c8b5f88dab1fa12c94a66121edee480d824c2ea366  release/kernels/cas.by_instr.json.gz
61b110c3ad332eebc4ed9f96d6b4fc026a550cad77504f58fde1f1c051777aab  release/kernels/cas.by_unit.json.gz
958d832a5f5e0e22e7567c8665c11974d170ad73e94648a2cc141f993a452cf0  release/kernels/cas.ccvtrace
4cb6ad9ca1ab577669fc762ed467157ff4fc2959718c82fb5d7bb786525c726d  release/kernels/cas.log
0ab31a9443336fe5d08e1a5fa5fcba3bc279b19022f7c5007908d39d8ef39536  release/kernels/cas.oracle.jsonl
7ef2be01ed24875f713d5d110aa5cc26f576ac3570dbc5ce364709c5f8dc9bd9  release/kernels/cas.sv-hosted.log
1bcdccf8c98a75cd78e39985c30aa381b0135b28cb461b4120157d9d65c564ae  release/kernels/chains.by_instr.json.gz
4e07b0352fc82e2d74f2bc4adffc0c610f4a32eb5a5e97e782c4dd70c9815560  release/kernels/chains.by_unit.json.gz
f3c7f719a83f93768af61373514062f1b4654c87caae7a6fd23d0307b7b7ca0d  release/kernels/chains.ccvtrace
88e187da214d0988c3e99082628816ac0312a11dbd1f10fe062c025916cb92fc  release/kernels/chains.log
26a4cc5c5524c7219d8706c2582c80357dea60be9d6ffdec99dac7d0365e2264  release/kernels/chains.oracle.jsonl
5b78f08f3d6f3f0700eaab2894fec6ea8063061338a9b0105757f1b09aae1d7b  release/kernels/chains.sv-hosted.log
1ee4f2fa1b90e1d3b3c497f6c030e0e464e9468ba87c27c529c7d2a3b0512973  release/kernels/coll.by_instr.json.gz
eeeaf1abdb9cd276d1bffa199cbe3fe16d4768f18ce8d286a7b5edb2ddacfcdf  release/kernels/coll.by_unit.json.gz
b9d0aa1fba37d6865c6e65310ddfdec12b1a406436489ff0c4ce6a811c10cdbf  release/kernels/coll.ccvtrace
6f81703da1d3974706766903f5aa322309ffff5a67bd93d1342a848d255afebd  release/kernels/coll.log
dd718d23c88df5dc7d92b055d8542865aa0e029118486af127312a8a578cfcbc  release/kernels/coll.oracle.jsonl
8bcea50b217a5f0b382427579346dd52146a2a2d408229ad0e1098777f150ded  release/kernels/coll.sv-hosted.log
0569eb111c7675b86e871a70779dff40ac9f20b40620a2c578e5ce7cd8491f9c  release/kernels/div.by_instr.json.gz
b0676aef6f7dbe7fd28b9790102d5af7570326b095caf3ba108e5eb63404ca8d  release/kernels/div.by_unit.json.gz
0fa59319a49569c81f33bc11b669b5cff44d54af88e0e1a0318682d79a62911e  release/kernels/div.ccvtrace
a1c36f4185ac8982feac923a05051e9a36a405866b1e811d71a9683b65bd97e6  release/kernels/div.log
71a567b85cf85622631490187563de9a5661099c78a590adff4ed0a0c3d24c16  release/kernels/div.oracle.jsonl
fa959066a26b68a6e6488be09bc7b331de35b4ae270f71b2a874ac0d348175b1  release/kernels/div.sv-hosted.log
038520d36e90cd80eca9db32721ffc2e43a879f1f84dc6541d769f4aa09a0568  release/kernels/divchw.by_instr.json.gz
d726dd86312d88e061a20bd7c8d6b757ad5bd0339911f5d2743c0da336730be6  release/kernels/divchw.by_unit.json.gz
7171a5600e2647cfdb103881ce1d051b67e5c0f4b5522ff75b05208ed6ee3d4c  release/kernels/divchw.ccvtrace
01580a9cdb3f4bca63737675a12deed8b017d082feefdd0c3f7cd4e1f063f5e4  release/kernels/divchw.log
58a541797f7a2df0a1c7528ae6a3edec212db90c7d3eb20656806f38b5c10b3d  release/kernels/divchw.oracle.jsonl
f66bf5e811b5827e050f4e2eb143a02058716935e81570a3948c293dacb06b19  release/kernels/divchw.sv-hosted.log
3d935ac8e7bbd76edf9c5e57247626d80f81b5c4b7ba08d6e7724a0cc8f830f2  release/kernels/divtail.by_instr.json.gz
a73280d52bc36a15430f92e8affad7cd72b62ec876f7897069662c357d4175b0  release/kernels/divtail.by_unit.json.gz
db804fbb5ad528ab14845763f37b3761a0b667c3bab40606320e4d62853ca751  release/kernels/divtail.ccvtrace
0c317ea908694dc2eda769ea669afdf2f94c6ebca324ba33d16748089c4874de  release/kernels/divtail.log
75f11a75c9b3b336e446140af4579f05b46c363a76b7aab3ec88154a07ba097d  release/kernels/divtail.oracle.jsonl
8e14f0462cf83c25f516c8e731991a10a7f1ba1e197c999e83290ff44a5b1cb0  release/kernels/divtail.sv-hosted.log
c7ea7636495c23f596e6588fd082e92ec3a4ce217efadf157eaeeb6e97f71c6b  release/kernels/divtail2.by_instr.json.gz
cfbd69d52f035b3b9f7a4203e8181a61620b9fbc82b1bb5a9b0a4a76a27499df  release/kernels/divtail2.by_unit.json.gz
a75fe12547373cd47764249a890c8e2cff1203790b37cff1678beeeb1c5b2c44  release/kernels/divtail2.ccvtrace
e48dbbdb86b48efeb88f7833193135460932708a27cc0f955f31f96af42991ec  release/kernels/divtail2.log
b2db6b05eb6cf4a0a7677e31d0c6c2952d5cab49d353f0bb1883fe0b2a20ed14  release/kernels/divtail2.oracle.jsonl
678fac6717a316f5ab87ae33b349e35088692f6d5d3d5acbcdf317db422f1a8d  release/kernels/divtail2.sv-hosted.log
6113ee31293739cb89f7d7e6074ea2fbcec4152d7408f4d35066cbc47c89ab18  release/kernels/fence.by_instr.json
2f3e2ffab04d7f0c9e07a846e2fd639880c38e4a22ba4234489ab86b7645ca99  release/kernels/fence.by_unit.json.gz
07b3835fa7e99b3db3da294ef152970712d64ccef233069735b96c6ef38d69d6  release/kernels/fence.ccvtrace
b817fbc1c606d4926a75a3a0d04082cb820a7515e5ec15b8e36adc98cddb3258  release/kernels/fence.log
d1d40317f6cf5bfb430cda1f9c0ef676609e59cabe2a11623c42ffbeca93142b  release/kernels/fence.oracle.jsonl
c2d0a2755442e4e7d45f031efa03cdeb3251ef11cbeac34210b6ccbc4bc74f19  release/kernels/fence.sv-hosted.log
ced6ba7188c600ff910308c7c1fc78ddb743aa17a47806065d2c3013dcaab5ce  release/kernels/gather.by_instr.json.gz
fb1c6e584f6a15299f315065df48a1905ed88a2705496017b37589696232c229  release/kernels/gather.by_unit.json.gz
356d4b42afd03ad920bb11251e6784511c4334d2d1b21cfd452ba496cf31f975  release/kernels/gather.ccvtrace
455b6fde3f951c99f1b69d4cf462d84f889ec3325eb445e272ecf78fce8a15ee  release/kernels/gather.log
0413e781d8d6ff578c64eb1f800b7931e66f676d5cdabb97b94a4033e6037662  release/kernels/gather.oracle.jsonl
39b5fe999529be67647d2002f62b177293ff40242ff28b2a58f0880945a9a30e  release/kernels/gather.sv-hosted.log
af1d9a0147ad50d5944c455e35528aee3e64284efa4830a7ddff1baf485d4844  release/kernels/hit.by_instr.json.gz
1a614436b8bfcb3de9332dca7cd3e4db2720e67d359e7e6ff8cea3f68307379a  release/kernels/hit.by_unit.json.gz
14177cdb44dcac6847993cb29fb18c5d1d31aa434b4b5e92d8935b236f3a1951  release/kernels/hit.ccvtrace
40469bcaef2b1214ddf9f1e5a7c1c52fb0a263075789733f20a801d872f4aa5c  release/kernels/hit.log
7ba9603e0088d9164de6528f16ef6a7fa9ce5821c8c12b52cbb3734e39b9fd52  release/kernels/hit.oracle.jsonl
97a9b8f5185540eee769a9cd8f5a1742a24bd4771d9ab133168d3a85441e2bc7  release/kernels/hit.sv-hosted.log
5e4cac1407b5cee1e108c2477e66bdba5bfbe8451cfcae6d546598ebdbfa0a7a  release/kernels/lanectx.by_instr.json.gz
c612dd987c6e2a1b449fa92b6f7744c1097057108610cdece66f40e6ae1d713e  release/kernels/lanectx.by_unit.json.gz
c8dbd5f0b00e54b370eba6f5c0a9ecb880268f40dc745215cd4be6aa885ebe77  release/kernels/lanectx.ccvtrace
6225c4553da4e434ff20c0a793cfbe93beda8197ed48f2b0bdd60cd47c699ce6  release/kernels/lanectx.log
888551babf540db8e3025b82e65ca655013f93eba3c8a65689d069d52a7e6039  release/kernels/lanectx.oracle.jsonl
14cfe9605e7318762c9e8b301e711a98bd6afc9ba4755a611d4dd5a4af8e0932  release/kernels/lanectx.sv-hosted.log
9860c2b60dec945e23b221a19175cffde374409acb5a9bb7ec40f4d0f84978ce  release/kernels/lanectx2.by_instr.json.gz
de15e44746104505163c92784e65183f6f3df3cdcd78a06d3ede79528e088c07  release/kernels/lanectx2.by_unit.json.gz
094521bea2680f995ee4a3f798f37495a6540cad9569d634523f06847da7341c  release/kernels/lanectx2.ccvtrace
24e519fbc6c9b2c208554c20d440bb3745e62217f0ff737a369442cdfbc56690  release/kernels/lanectx2.log
45c13056dff5c73ed0c9ece56cc36f929bf335322193c7d5eb38710b1d1dfb02  release/kernels/lanectx2.oracle.jsonl
4ba971e406d94a124f7384aee29004cdff09bfc4449788b0fdacf26a07eaf57a  release/kernels/lanectx2.sv-hosted.log
cafec60cb04bf48e3d49ae5e3483abf6e170603670fa384032ee4537504a2114  release/kernels/late.by_instr.json.gz
a9cb9dc1774f1b0c665e4827e4c4ae6a8a961600ae3bbc9b919cd1999b74cbba  release/kernels/late.by_unit.json.gz
56a358da38919c410520ee4f1d55eafb6e4c6c1b4a1995aa4188761859ef6d3b  release/kernels/late.ccvtrace
353dc1eb4d702eac5995cfa6c5b1b0a38e7f0f81870e30fa2567538300c86191  release/kernels/late.log
86084f6bd747a2cf32acbc0ebd96ebd3e4ef2d8d9e21be49e3ae49290d7927f3  release/kernels/late.oracle.jsonl
8027c2a961971944ff39ca08e0474ee294237925c439a4c3c270dd1939bd5e81  release/kernels/late.sv-hosted.log
b81a8c7658c8372b6485177addd8873af2961258b334e1ab23d6fcee36fd35ca  release/kernels/ldpar.by_instr.json.gz
7f6a27b11a5a38222965105ee43ed0e16ed7ad978b2fd7c46369a26b9317f216  release/kernels/ldpar.by_unit.json.gz
ddd49addaf918696e10fc94de08ea8a643192f00498849772d8e0f02e26f1345  release/kernels/ldpar.ccvtrace
05bd26ddef297ac409cc796af72c45f08cc1d0d69c38a85bd5de0ec2519f37bc  release/kernels/ldpar.log
8ac08538e9c807637babd61b31e340f7461878ada31f0c0b83cd66331cfaf486  release/kernels/ldpar.oracle.jsonl
67c60eca1e9a0df85e21a34626e361150b1885cc727e22c9856f45731327fbc2  release/kernels/ldpar.sv-hosted.log
8a5f76dba2dce3c5a5a62ba54f1e271b69a4d128f64dda8dfde89ae58e96e4ff  release/kernels/lnorm1.by_instr.json.gz
6f61c586c8e44399d1437f375dc22804534ed57039e8adcbcae03ff327af3d2f  release/kernels/lnorm1.by_unit.json.gz
9fc5f9c480b4705e2dd2dd6e69e2a88033876f0810a04316eff021e6014bd65a  release/kernels/lnorm1.ccvtrace
892b44fa9b72cc3a9ea6018f4c1a2a594aad8ae934e8c385ae0b3df5092ac7ef  release/kernels/lnorm1.log
a8d85811af988a1b9fc00db1517300af3d93ec8e589e403d3b9113fa9e0ffc86  release/kernels/lnorm1.oracle.jsonl
a3ec424f43cc18add16607781cc6d22a94af1b02e25e5230c00247b932ea03ac  release/kernels/lnorm1.sv-hosted.log
ded7b59d06e245edfb8b49f594cc53ecb7c428e3a32c2a59d387c17ac69fd9e8  release/kernels/localsp.by_instr.json.gz
b77244117117a063e3a3d1b257b35c8192a643f2b7bfc2e16032cd66cc5022e2  release/kernels/localsp.by_unit.json.gz
87878ff18dcbc81cdbe45be1c4f867fda1c2c2c5d032348280ea3c663b00d0bf  release/kernels/localsp.ccvtrace
a0c3847568b8a096cbdfbec879f9c56c7d95020bca74fcc4598d1b2e9af0fe9a  release/kernels/localsp.log
55e3c9f36e7f7d38c0ddd38903aff4bb4509ae862015c592e6b937ea258042ca  release/kernels/localsp.oracle.jsonl
183a38f8927f64b9fb5fe70673bd0cbbcb8c9abb3bf495f6df9652543e9ea9db  release/kernels/localsp.sv-hosted.log
4dd0c8b2180eeba26aa35137a1db32ebb38742e1f731cc620de83ef27d282d42  release/kernels/loop.by_instr.json.gz
c5d9b57403dc41cec68939f5e24fe3a3b4966215cd79589062f5421a27a2cb96  release/kernels/loop.by_unit.json.gz
8e6c9417e35af8bbae117adade5b9d2de71420fc35abe4aae7df581e61dd52a5  release/kernels/loop.ccvtrace
75d39b37a3df5b8e1330c53d7c43a22db4b613ca54aa3613e1e72446c48ad1ad  release/kernels/loop.log
03ce5920c06c93e93516d8e53c3f7169f14e3593de204eacceffc0b8a3e32016  release/kernels/loop.oracle.jsonl
b2391956b7303b80634a031ddf2a9a615cde8a6e643f1230b1cff1bd98682bfb  release/kernels/loop.sv-hosted.log
e2f75ac3c2c9467f07c2b80de23004da0cd6ab4ed5081e5a7d49ef3d07c7feb4  release/kernels/merge.by_instr.json.gz
ed492988c1061c2293655a274b6f9c632699b76c7a4fd02e7adb729db3c9bea8  release/kernels/merge.by_unit.json.gz
7c5c27b8590c634e6a6fa0ce6ebc8afed33e3101ca7690ecc2efe7cde41a32b3  release/kernels/merge.ccvtrace
ffee51773874fa3375ff866901f5bb4c9f43ff7c3725c1f40a1b1f5583b9c674  release/kernels/merge.log
f96d28815f8756b1f5a45ded53e6170883d2dfa10f9eef0d14b8050b1318164a  release/kernels/merge.oracle.jsonl
acb7c6a3402d7a9a13406e1685b33cc9d28f2642b4f9979df92683deb7217b33  release/kernels/merge.sv-hosted.log
e91454884dc6d82bf68cc4010e490fa91f6fd7cfecc525deab81d41645b35c67  release/kernels/missrun.by_instr.json.gz
c4d0a66a1419d7c980bbb039b6b9585b63d34df1e1d0b1d387c5f0ef48d1f9b2  release/kernels/missrun.by_unit.json.gz
ade0c926af6b8801ad9a0c584464c80d257bb383968a4ec36f0e3a4053fef56b  release/kernels/missrun.ccvtrace
cf458ac25f203806ee1bb5bcca6df83ee5f96b7ad527f373a1b0617e2bb1fbb2  release/kernels/missrun.log
531bdaf281e5590774bd2775427f25e4cc0419cf8e3d5b6999843ffe9ef87258  release/kernels/missrun.oracle.jsonl
a92a4f79a63cb7dd167aaf170b5fc83ba02bb13d79d6e9c2d47cbeb670f3e7dd  release/kernels/missrun.sv-hosted.log
e43691b8875b8294eaee6c048ad1dd5fb686f623d70f7d20c7648df9d974d5a8  release/kernels/mload.by_instr.json.gz
6933d627f11931563428a7e49bffe1752210611125d67981fe365d2591d36aaa  release/kernels/mload.by_unit.json.gz
8349891c8cf45b330da9258046fc2c43ce47b7e0ec3b4793ecf79d4b9191701f  release/kernels/mload.ccvtrace
32658214840395799bba1d8d19aeeefcdab3d747276c9c7cc3f2460878049aba  release/kernels/mload.log
8000e477b9a95dfb9f0af964e8346acb9d36f1358fd06ffc4ff7cf599d2b8868  release/kernels/mload.oracle.jsonl
43061e7b0dd4081f6005c387c8832975d63897baa69d6bb5671b21e33d73d08c  release/kernels/mload.sv-hosted.log
b7b99a189728c6bfd0b27c164dbc024d64b4c0231df5a0eb39ede3b253d6070d  release/kernels/mlp.by_instr.json.gz
28399024cc96e8a2ffade8198489186ec86560eda499366422127000d211e49b  release/kernels/mlp.by_unit.json.gz
20cd6709d3c32211ed6eaef3c8b9c4a5ee5b3016039985849af2985b3dafda4a  release/kernels/mlp.ccvtrace
5bc2cfae7b8daf2172bcdd8023fa8496692923792a821ef708a65b5bd5a75b93  release/kernels/mlp.log
138d282f88d56c8ad648a91af0a983254b55d9fa22942c00d47b327f516a6e44  release/kernels/mlp.oracle.jsonl
389d7358fcf893760a71c5e0b03c52f7dc7f305aaca565dbdc7f12108048fa76  release/kernels/mlp.sv-hosted.log
06dd55f41e9373f388485693e8dcac7b2a050fd0f1d5a9976fe0ee25b606a8fc  release/kernels/mwmiss.by_instr.json.gz
61fb2e45c124345b91e6ab524438551508de5febba0c6595358b460f97faed9c  release/kernels/mwmiss.by_unit.json.gz
65867eb2557a384f3c51a883e852b728fbc03cffe0a29c9ac4b5502aa5d1de5d  release/kernels/mwmiss.ccvtrace
272ecc613e36724e497f827d0fb2ef3a26ce42f32b0be7760e498559c0ab6ee8  release/kernels/mwmiss.log
8abe8e8997456a2a6711ee72da54d854b24e20abbdab28e4b7271c0d28418de8  release/kernels/mwmiss.oracle.jsonl
4f7e385b360122b3f6df44b81e7946b6755dd9cf55139adaaab0f8ef5208e932  release/kernels/mwmiss.sv-hosted.log
87c79611d1a5672e1e2efb0b0d2a34c471d68cdd8aece28915f2462ab4a4e779  release/kernels/narrowadd.by_instr.json.gz
71b7ccd74c214e9896a4b9480d5d83f13dfd8fd2f22ce99949d1a79422f65760  release/kernels/narrowadd.by_unit.json.gz
70f3064aa65b7765b7a6b444510e3f09a7cd4c4605374df03aa452b3837b7a5f  release/kernels/narrowadd.ccvtrace
136f9c5bca9755f7c7e6efd806b618cd1cc42b153afa1bd4de70a61c6cbfe9be  release/kernels/narrowadd.log
40a2cf629853dd404bb06b4a07e35abde3d12efc13f26ffe28f923daf2994574  release/kernels/narrowadd.oracle.jsonl
3462c38df09999ffb09c2bdfcfb4045e4b7c1fab8e2c410a58d2128e0aa162b7  release/kernels/narrowadd.sv-hosted.log
43f9e8d133cddbf8e3dbc45ed86bfc68158dcced2de40c1d0d89cf21079c9ace  release/kernels/pgcross.by_instr.json.gz
117ea9639be08935c524e9a3735de78ced1c03edeaa2f096aa5df337c3e04ccc  release/kernels/pgcross.by_unit.json.gz
55954f76cdb425f55f73efefc451c9e900e91431f122622f0c5c8b26648d7622  release/kernels/pgcross.ccvtrace
b4c232fc98170aa8e0337c71c4b2114c469c515856943f2663bea6d222615887  release/kernels/pgcross.log
58aba9ba5ec6a72271191c0249014802cdc7e4470d27491f499a077f17ecc039  release/kernels/pgcross.oracle.jsonl
44de07e683e6fdd577e69aa9bdad1ff4e88a8591a3062045b5eff210c7d2313f  release/kernels/pgcross.sv-hosted.log
5f3326c2860895678d5b72db6d2394e51e954a20469b44035f72aba2d9e6b77e  release/kernels/pguard.by_instr.json.gz
e28041ca23cd38f1aa3bee4e6de0bf1ef8cd472dafc95a56fc63fb0ce213b935  release/kernels/pguard.by_unit.json.gz
d3a0f73a186c037df930784ca453b1f6217e7443e14b5e2c4715bad84be9ef5d  release/kernels/pguard.ccvtrace
671c22dc16cc8225e424742bbe3f9d23834cd277699374cec7326729c041c4bb  release/kernels/pguard.log
690e56f1cb8d97cbf67124b7dff3ad0a90cb8981814cd1709cf0cd0e035b3bd9  release/kernels/pguard.oracle.jsonl
55d53b67d2ea8a217ffdad32371750e026b4174d9a3ed91cfb4b180b09591ae8  release/kernels/pguard.sv-hosted.log
6c17cf7fc593c55f63e3284aedd2f4f7f491f291723b82490ecddb45dd705c03  release/kernels/plog.by_instr.json.gz
0d697038def739175b5ec4392accccfa4bac4cf0f6f119563fce507369613c3b  release/kernels/plog.by_unit.json.gz
7823562f75147705b01f772471b6175774023d19935926703e158062b24cf94d  release/kernels/plog.ccvtrace
63e5cf8d014f79dca17e4b29f545badcd3c1720e56d8bcbe26e3f214f0833b61  release/kernels/plog.log
0c99915e2da60f4670da00504a6371d7d17701d4431e733a3ff8fa98a2030d6a  release/kernels/plog.oracle.jsonl
4995ed4a06324d41e7b68c3a12ccb2f5129e1450030a11932ebf1d60c3fdf76a  release/kernels/plog.sv-hosted.log
bccd71200c930be1a5f2ea3ae35b24dcefcc2b06510891738c46946a6e68eaa6  release/kernels/pmovdiv.by_instr.json.gz
af9aa91ff36a18c1a356ad74553fc818e07a9216916cbf086ec495b89af89525  release/kernels/pmovdiv.by_unit.json.gz
da1865544271c3c70d3eab1061f5060d833a856975f75b28d0921880ec954a97  release/kernels/pmovdiv.ccvtrace
0087eb8f2e613b8e14e8583945e2babde0b00b2b97c6989dc5123f75bb96e1f5  release/kernels/pmovdiv.log
7bc646cff6166a51bdce03d7c1b7209e871f0a91d743083a9b910a80bcd0b33f  release/kernels/pmovdiv.oracle.jsonl
c1f75cce9ac2af395bedce3c3e8701606e6981d48d0684a3bb6a60761b358317  release/kernels/pmovdiv.sv-hosted.log
a8976e4c9daff1316fa7a691532c7a78bca40da70a707c10bd194811c22576f3  release/kernels/predlane.by_instr.json.gz
41ff0ebfb10bb9abf2536923cabc445158d9ee7373bcf79f87341e2dd99d432f  release/kernels/predlane.by_unit.json.gz
50d80cc740eb64f50d8d451ba21e1c58972991ba64ccd7114c95e774f4a430f9  release/kernels/predlane.ccvtrace
ebefa15d24ca82a595cc3038b7b9e5e89a63a5ef3010dd03189d820239a4327d  release/kernels/predlane.log
c45f4177b9e84fc8a6e36b13534a0c7636eb30a3f8531847100ce5e23bf404b1  release/kernels/predlane.oracle.jsonl
40d529730fdcc6cee3cd8bc2093181182aba968f77fe1aec8908c3af7f75a3ad  release/kernels/predlane.sv-hosted.log
63facd416a753b8a7773a3be5d138e79669efec551ab3dfc54a3e7418ca3836e  release/kernels/predmerge.by_instr.json.gz
aba3f43b22c63f1128411ed00d5a044a27574ee30d88b93ba5620c8db1d7ae28  release/kernels/predmerge.by_unit.json.gz
d4fbcf1a0ea13a89d7fdccfc214c4f918257cba14aa024d4ca6250f04d3a7fc8  release/kernels/predmerge.ccvtrace
f7d3c10065b81da23b4673c5ecca1e33ac6fb08cee95ed85e198d7d92477dfb8  release/kernels/predmerge.log
6c737c49434bcd08e3e0814c8b1dbf15c586ae74f7929ba3148ddcee2c62c845  release/kernels/predmerge.oracle.jsonl
3a5102df4faf54c3a0da3dccf149b4c506202beacdc623318a19c4529337fa21  release/kernels/predmerge.sv-hosted.log
39348337bfabb6dea0b8dc37caab0289fdda241083bc4ea5dde99398bfddf0f3  release/kernels/predspill.by_instr.json.gz
c05979e80545327615f4fb9ce6d2429237dc8585ff203881db0846fab9f5fd42  release/kernels/predspill.by_unit.json.gz
68b1af2edfcc1c09bfe4cde2e148b0eaec9035dcca2ce8d1acd4ee551303d76a  release/kernels/predspill.ccvtrace
295b777baaff518ea496c5fe4e620f7b8a9e4adde25c7743ef39d137a20c438c  release/kernels/predspill.log
b7c84c6478117ffa0f06da0e6ad1e4628e2683426a7911080810e78e06a5242e  release/kernels/predspill.oracle.jsonl
8a9eeb5e8b2790275d8e71ef7cd639763e6a0824c7f9f6c401a873377c79b926  release/kernels/predspill.sv-hosted.log
67a1ba65def9751167e16425dc57d137158a80604981210341eab8911f61bee9  release/kernels/predswap.by_instr.json.gz
996e0eb75c601f8b9723f68c39ef2f7b97195fb11402cde537c12f0c35e3a292  release/kernels/predswap.by_unit.json.gz
cc0bb7da1c9dd84f7a62c74627d792b5662c595294304c08509661b0a072d0f5  release/kernels/predswap.ccvtrace
643c95d96ce50a0073d40703ad24386d622e7388b2f76303704b0350198f4098  release/kernels/predswap.log
a6d4f7ed517553816d889c7c9eeb6bcfd1f6c973fbf682ecb69f3c2de619f7bb  release/kernels/predswap.oracle.jsonl
4a0d688f1708b0801768681b6cb3de037f70319e6288fe6928a9ddcbff469d0a  release/kernels/predswap.sv-hosted.log
8d284390879cbe6cc8819e5581bbd935451f82b99c32c7a0efd79765ee541c21  release/kernels/privwin.by_instr.json.gz
6172d9285f3ebe6035cb5d4537e81182593aba0deb436e934b438f20d7a04518  release/kernels/privwin.by_unit.json.gz
b05842fd55756949b74bcf3dd99cc17c0dab77b15911287ab50f3420319bb912  release/kernels/privwin.ccvtrace
42c90c54672c9e72a421d0b723574363e15c461bcfdaeb5e8205ba53c905ca6d  release/kernels/privwin.log
861f686fc4480363472908d679d8815e8c957d768e7ab32c826930527b0fb7a8  release/kernels/privwin.oracle.jsonl
941738d213720ef6bbbae5b77489be0755a6eb5c75c0b70ccf41a26500ed4f50  release/kernels/privwin.sv-hosted.log
ea37d14fb43136771d73e9c7142cba32dcd96e5565d40bafde5f83682c6281b1  release/kernels/provswap.by_instr.json.gz
5f5fac70cd4836438fbbd3aa544ce2a8378c18b60a986cd1777fa6aa2bfc11db  release/kernels/provswap.by_unit.json.gz
71b721e2bd1fc8dd52b36767c301a10981b26e89728d6827c65aaf14dda88f38  release/kernels/provswap.ccvtrace
5e4046804e3d47d12f296dcfa41c9e5b2c642a11bbbf016c6e0f5e2231a2281b  release/kernels/provswap.log
c9c32a793d54cc7401477f582487f7e8b345b2669a75337b8d6327120d98e5dc  release/kernels/provswap.oracle.jsonl
323722dd224dd7d92ffb52865374ef9ac5ab01935cf37f42dd25b08d084b9c54  release/kernels/provswap.sv-hosted.log
4fea0dc1090cf9b564a1f89babad6bd071caef7807e2882ff375f2f5785ecaf7  release/kernels/retmiss.by_instr.json.gz
58e14bfc1da3810c6fbff52e0fcc9ab6a511c0ecbe9233c59e329fe5601af0b8  release/kernels/retmiss.by_unit.json.gz
5fd48fe228e08b7647063cef9db1a2d2e027a5a03176463da79fbd5263ed78ab  release/kernels/retmiss.ccvtrace
7684c258cc6760de8f43e42333f7a16a68cb81b0e2a86ff78a82e1d5097d99ce  release/kernels/retmiss.log
e5ef8538e838c6cff7febfc679dd091cf5e002f82d34f1009b1948ce22bc3649  release/kernels/retmiss.oracle.jsonl
51d99dc4876dcd3aac5f979d33bcacdf06110b65401e2ae2ae9c6ece10d94879  release/kernels/retmiss.sv-hosted.log
b8af37455b33a1b36ab55a477d4761f76bdf9dd3edd8eab5fb7f2c3731ac8ec5  release/kernels/roconst.by_instr.json
1bd6e3d57918f6dc12f88a90fbad3431d9d6ab8123f8959ed02ca7c9430da7dc  release/kernels/roconst.by_unit.json
55981e07a1a8d3ed8b7a9f6797e5f718e3161cc5f6e1218171db77f9b6115f18  release/kernels/roconst.ccvtrace
d1921a51f069c052bcd02c989bef88cd791138501f72e3a24a20f86fc587b33d  release/kernels/roconst.log
8087c0671de620162881aecd38cd6114b78e7be6bd71201e3ec02c9a2e2e750e  release/kernels/roconst.oracle.jsonl
92135b13ad438cd82274e9a573a9aa76a5212d636c0d8975ffceca413ef45c13  release/kernels/roconst.sv-hosted.log
10c797fb8d044649f6d3dee9c07281c225794258b33e21124d781108ba92c747  release/kernels/rogated.by_instr.json
e5b2d0660fc389c421189416e413a2f5c5663b46c40489197716e6cbd08a64b4  release/kernels/rogated.by_unit.json.gz
efce29ea7c5e82d9ca9f5522549f4958218e9ae67a9114f6c26c60f34501ba52  release/kernels/rogated.ccvtrace
4740f432e5fd2c34f691b0da6676ac020294b9940c50379d1bb6cc50e3a6b740  release/kernels/rogated.log
7cd02bd4cceec5a044d6b4d6a80df1e68ed0ae71b0b2a953143636d5b809ea6c  release/kernels/rogated.oracle.jsonl
e2a16a8c5a06fd1881b25339b91f1a332a6537130aabdc3af9c910b2ec4df01d  release/kernels/rogated.sv-hosted.log
31fbc446cec02e5330cede31ccdb156e4f8c1abfcd9fa91bda13a9f0d8ad02a4  release/kernels/rokill.by_instr.json.gz
b59d753355c7b6f31f1666bf2545677dab17c59b900f6055b72fcedee3c33906  release/kernels/rokill.by_unit.json.gz
8a540e1a67dce0d3845964ab547fce4b1c674a042f6be8c8d8c8b7dd46f4663e  release/kernels/rokill.ccvtrace
85275fca9bc7152dacc45fd90a4d3328624171bcb743f591c47418594c839fc4  release/kernels/rokill.log
94efcef96af469a512d346ce61623980fe86383188eaebd55120f716db596f14  release/kernels/rokill.oracle.jsonl
1401ac06517febfbca5228ac343cd2f5f78106af09b436207cbf3345552fdd6e  release/kernels/rokill.sv-hosted.log
1bf0c9148f868ef599eac457b7f58316a8d217644b51f3c954bfac1293584909  release/kernels/rokilllane.by_instr.json.gz
704b20672fb33abe7e01ee71cf7c12d8b22106abb4f1f668b4a838d86a43deca  release/kernels/rokilllane.by_unit.json.gz
c54a973f624a7ad5b95499138a725ad2287a564534121f4f568394896b3522b8  release/kernels/rokilllane.ccvtrace
7c8a089773871b40ca63f8d38b28e883c326a5305685737afe4e06cd5a071549  release/kernels/rokilllane.log
f5ca6e666eff2f44894df74a291b43b3c0e7be0a63a47d795fdefd7b22016f45  release/kernels/rokilllane.oracle.jsonl
a013a820e332cfd1117c5c448f05760b0466c5d5545b562d2d4b965cc9213d68  release/kernels/rokilllane.sv-hosted.log
6018676757a05a45231fba12ff6df60d07f415338c1d836cc09d99465b73577e  release/kernels/rolaunch.by_instr.json
8512780fe1bbc0571a43ff91654c0ffdb7545b9c1ac040c907e50a29bfbd10d3  release/kernels/rolaunch.by_unit.json
289a78e36e414127402cf1c2f9514ddf7965e2988e5c5c2c172bf77c872262d4  release/kernels/rolaunch.ccvtrace
89e705b2c50372bc88b0a5676deb01fb38211e30088052322c9d747b26535b97  release/kernels/rolaunch.log
e7dad585c3e70615de04330fd03f4f282c29a005dc1732a35655fb261d51139e  release/kernels/rolaunch.oracle.jsonl
adf17c90b2c5719c503b60439057389db61e9c7adf4a41dc5a49b24751565a48  release/kernels/rolaunch.sv-hosted.log
b8af37455b33a1b36ab55a477d4761f76bdf9dd3edd8eab5fb7f2c3731ac8ec5  release/kernels/rolimit.by_instr.json
0e20aabf7e39b687a2ade0f80fd977c9d7bd313c2cebdac11d43f35296e7d911  release/kernels/rolimit.by_unit.json
6105e32f751a15c0875d0d2a30a1e054656c0475286b5e2739728e13fa4d3e83  release/kernels/rolimit.ccvtrace
1063a5bb38caa7980d064cd94e43b582cc64fe3bb8b9e577e18ea36169208862  release/kernels/rolimit.log
1c5bc0cb8e8b2e69505fb5a551a16d5d10c56f232b88da7a27e336ad7d962de2  release/kernels/rolimit.oracle.jsonl
b2d9741830c6339f5ef8dddb9f9c37de5a9c015cefa7ae2011d0d13b3398fbb2  release/kernels/rolimit.sv-hosted.log
2e6ab0aa8e02ef9094303235da73e3ca9c6ff9caddcbfca545caaad085e821f9  release/kernels/roload.by_instr.json.gz
1d666aa873a326457c8cbff1ce34ea74373475a7298c8e63774bd3414777a9aa  release/kernels/roload.by_unit.json.gz
1578a583d5c4f4db19dc0bd74a872681a3a72c6e6f5b8cde88c5ca1dc140c41e  release/kernels/roload.ccvtrace
28839763810d653927388e4466d6c7b5805b56626472fdf00ddf6738ef5e8bf0  release/kernels/roload.log
f7c1309cc9764769fb5803f6fd0f2f5e1eb418f2d23fbe5e17cf5f9106869fdf  release/kernels/roload.oracle.jsonl
8941441193f0ee60afe5993b9da02f55eb0d5b59539b2cf06f4d708d92a73a44  release/kernels/roload.sv-hosted.log
24b2af34b30f6b992358f7810b0646bc14dbb9409882a37da99df8f4f2089a6d  release/kernels/rope.by_instr.json.gz
a7f413e38f6d7f7bf3688042d8dc1babeb97fbffa426c19a196430002cfc440f  release/kernels/rope.by_unit.json.gz
c28a1bf8541fe51be00d4bf9cc41210c6cba3db2f220dfca58ceb07bf23f1fb7  release/kernels/rope.ccvtrace
f37bde90394dfd0459d1922bcf9ccded862fcbd49bd21227dcab2a3451ce1e76  release/kernels/rope.log
d55f9efae392dc8877c102c01c0810e7654b666b6ede386328108164c6cf88f3  release/kernels/rope.oracle.jsonl
d26680ed40176fa0a8ceebe6cb2ede9a20e7436c7eadc4e5d6e4ab202392a1b8  release/kernels/rope.sv-hosted.log
364be39c2fb6d6bdc2bc554adee19f737a04c6e8c8eb31c8c564a8eb191dc850  release/kernels/ropediv.by_instr.json.gz
f44be9c198aebd0e3742148407051c58b4f5457d020115b872b849f8501b92c1  release/kernels/ropediv.by_unit.json.gz
f3b563b58e4997345f986a68124b88067afacf867bd6c7f3c4f48cf639bdef31  release/kernels/ropediv.ccvtrace
41e08b6f90eebad42d46aa6764788d480738a3cd9b49b2534c19ae393afdaa9e  release/kernels/ropediv.log
10c0ec6ec18b7b44638c790033109198c079d07c1537bf193353ccedd00a920f  release/kernels/ropediv.oracle.jsonl
e05595c5ce8b12cc05ef2ed1e67f286eb60c6f6d6f8b062f9a15eeaed43da223  release/kernels/ropediv.sv-hosted.log
1819d5705d883f65308ac2e8757835f76e0292b73648fe3de7accd224638b132  release/kernels/sel.by_instr.json.gz
79cf145c9265a26c136d86ae6fe796cd9ec328c7421f2c081478f6e6d0e41b7d  release/kernels/sel.by_unit.json.gz
0e8438b35022c4f1ce3255dded34165aef8dfb098254ae97b0f80b67fffe2c18  release/kernels/sel.ccvtrace
a62c49703fb6a3927b9c51486c9caab3573c8b10b3978fbfd174d5d460599228  release/kernels/sel.log
87f6a81e8afa004c8039bf2f61c90176fcf29ab29bb17ac44aa016a5cc8438fe  release/kernels/sel.oracle.jsonl
b9623668f2e8e239e9ff3e319b2ad62ea2fe6cb918f1b2b3b357a1081ace79ba  release/kernels/sel.sv-hosted.log
b24c197e42434dd6bf9c529e719e41afb66bdd6785c02125c99aa64ef3051f33  release/kernels/sized.by_instr.json.gz
247da90c26c82c6dfeda5564c65d8602e8f92f5b00c07e2c19fd8468b6033997  release/kernels/sized.by_unit.json.gz
fc2280a2a3c07287069cdcf194669d210c189c42292f2c8f18c06e80ccb1dbbe  release/kernels/sized.ccvtrace
6c3cc34f4cd04d9794365b712e172017b4c6e7c16727a0712576b81d6059ccfd  release/kernels/sized.log
36d903ba1618bd1faa437c9812a6ee6c0c966a63196c796267d74bf2695ebc3d  release/kernels/sized.oracle.jsonl
14046af16c4250943465efddf9e84de02936544e029f7e88380e75cf5d8cd302  release/kernels/sized.sv-hosted.log
9a1b18cb685f21fba192c1e2eb2155c1ef8ae15c51d891ae276d1a48d3714dae  release/kernels/slotform.by_instr.json.gz
ae11d1a3c8f90f06e8fbe23cfc440541809764cf67755d30b5422ee155ff7890  release/kernels/slotform.by_unit.json.gz
ff8972a50d2be95058930e607a107394abbccd183eaad7a443dad100e56f5019  release/kernels/slotform.ccvtrace
0f64f39f3164330e3dbda61cfa75ca0fc1e6ab66cd4a84787d45912115f7295a  release/kernels/slotform.log
8b61db7419b18cea8a646fb628218447e72e84a18a9891ffb73b441736138ab9  release/kernels/slotform.oracle.jsonl
99c2dc18da940b30eb29e89ffb3642bd36e0a0877ea06589ceabae73b8f6c07d  release/kernels/slotform.sv-hosted.log
da4ca59f4f361e2312c6ee9f021bc687b2c654e248ea254de6d8595ff1a2ae09  release/kernels/spinwait.by_instr.json.gz
ca6b3193fb9d71f71ad1be6ffd01667f6c0f21185c5597fc70ea7c2b0a8db227  release/kernels/spinwait.by_unit.json.gz
96ed0aa7d277284575bad8804bec69409b22c9b86085c7cdf2a3776908b9761f  release/kernels/spinwait.ccvtrace
2907e945178a4fb6547e6b3c50837032d4201c2b7819fc2346667eff3a07ac97  release/kernels/spinwait.log
868920637236c878b33779bd450439466fc3626996a3164573dc11d437d5c709  release/kernels/spinwait.oracle.jsonl
9b6aa14075344bc2596a727776ce972313f718de6993cceb5016910beba4be59  release/kernels/spinwait.sv-hosted.log
b984b3d63570a58d3098cc2017cb5de9b5451c690ec053ce812891a145ac1bd9  release/kernels/spmbank.by_instr.json.gz
464eb0df4ab8fda52fb765e9269033a3eea6769ce4777c70e73d01fa1946eb9b  release/kernels/spmbank.by_unit.json.gz
0b63ddd199108d5d57dacf8da3b47f37f0c4b36c8ae2b2605a61415aba0d0ef1  release/kernels/spmbank.ccvtrace
7f6e8a592ba22b934ee3544a29849ae35a648d25731dfc10220cd974147ad380  release/kernels/spmbank.log
3af490cc37d7a92dbe719b57de216b648536eb301ff9d13de9a39f50d150d725  release/kernels/spmbank.oracle.jsonl
4efedd3a0860ae00ca6f46bf1b7a43822bc0043c2a8f958b7c07680e8eb9833e  release/kernels/spmbank.sv-hosted.log
46911656529f7352f9ddbc6f7c89d5c457d889a795ccc1aee26fcd7c1472aa7e  release/kernels/srd.by_instr.json.gz
095db3b9759f641dc83a209e25079c22b6b2593a669e28139839f72b482cc3a3  release/kernels/srd.by_unit.json.gz
0c47cb484cf0fa4aeccd7dbb998c726c231c62826d2093825653eafe0ebf1c2e  release/kernels/srd.ccvtrace
fc35cbbaf22ee47d96edc102a27ecacec81a30a00eab9121045a5b3ba3ece355  release/kernels/srd.log
b08eb5e3673cac7eebb8b72af5ed3783c8e70a9e96592e76bf3722551bc79473  release/kernels/srd.oracle.jsonl
436a5c8f493473066551d6c069943fe9f620577a24f131139426d7f2d636745f  release/kernels/srd.sv-hosted.log
b0c03b4074285a451927940d76adc61174dda9ea72165b98509b44fffb358143  release/kernels/stall.by_instr.json.gz
31078deb6a79fabe91d09a606cda0618dad490746d42761eb938c725550563cc  release/kernels/stall.by_unit.json.gz
fdbaf4c7902b755d682cce57fc79287d1b42ac04bc16f363e0ae6381951d354a  release/kernels/stall.ccvtrace
cbe2c08b144e7b2b87a50bab0a1b1c38a186237abb978a9cdb6518895ecdb3c2  release/kernels/stall.log
500db2c482b07a0706583422cd68878301d0146c1f872ccc1f11bfdcf5c993ef  release/kernels/stall.oracle.jsonl
7c4a26e6a42a43f90acafe6d93a904920cd70b5fa17ca2bc4db4e6d8fcb1177a  release/kernels/stall.sv-hosted.log
c8d880d4ca983ff4f3dc935dd5bd103cd282da2215639fd0891012b574d4ed99  release/kernels/swap.by_instr.json.gz
5f864bf83171344a346b824ed0ca16ed1a7d5ad6f0865645c10e23ccbc8af401  release/kernels/swap.by_unit.json.gz
e57df079f08803da10c14868ef10984f224605451405d05a7f253f3e19b0b77a  release/kernels/swap.ccvtrace
a9b5a363999caaf49803d18ba88b6fb7e865c512f817a5204a26be9a097442e3  release/kernels/swap.log
3658a26316c1ff7bc1744304a42f736e930fcde2865c8913e6cc67a22ce96667  release/kernels/swap.oracle.jsonl
2785413a241e692e55cb24db6dfa8f59da9936a7b727a107045bdc47de9cc16c  release/kernels/swap.sv-hosted.log
08ec9443cdf2cbdf5c65b581a67a3e445f178df8f915b77b449ff07528e99dca  release/kernels/transp4.by_instr.json.gz
7194a0e538463129f1e268bb47ddf3c7e8d5e2995ae1e5e1c594554dfd6cc7e4  release/kernels/transp4.by_unit.json.gz
8f2febb448d3affcf9fd137c0f5e513ad3afa69793c63d3f8a51fa6550ab966d  release/kernels/transp4.ccvtrace
8612f62aebf5f47b156998a954650079ec4510e10690792999da7499734045e4  release/kernels/transp4.log
06396ace3ac19677fd39c700e408606e5bdbacb24997d663bbe8872e63dd74fc  release/kernels/transp4.oracle.jsonl
9c3b7d2b125e1e5ab2b257f4630dc26bbb6811e4097ff6b62b4a5ec5fc875872  release/kernels/transp4.sv-hosted.log
4854b8d45c250210208c9520365dd68876a6e70e4dc00d45343de1f28e4d86a5  release/kernels/unal.by_instr.json.gz
74459c8201c7bb8ad39b2f80e44464dee59666b456fba0e3dc76a56d183a1f4f  release/kernels/unal.by_unit.json.gz
0cd8c220c97c584d454372ee65753f8c7eeab527faa08ee5dea40239360b17f8  release/kernels/unal.ccvtrace
9170506d27d9ab469fe0a77e3007593a47af91134832ed621de10b9eb76ed389  release/kernels/unal.log
c3d484bb160657a563df983d9a2532eac27f556636617960aa1e72183ac2b299  release/kernels/unal.oracle.jsonl
d5ee269303eb3f353cf5dc4c3ee3cfa50b5be474337ade6504f4760feb02427c  release/kernels/unal.sv-hosted.log
34d74c2a9f02150132d8a8e51471d63f99de36b3716f6db083d8b3ffacef67ef  release/kernels/vadd.by_instr.json.gz
af5a8fea71526cd1159b1baae378a5b01b3a32deaad15d200dddf026c91377a3  release/kernels/vadd.by_unit.json.gz
e325dbc3fdad4e6bbbc3475cfda348ad306843a8c5a0b3ab2737111454ceb121  release/kernels/vadd.ccvtrace
ffd97c70d6f6cd2ed7a9e20f2604f290fa647ac7511231929bcd87bfa978a29b  release/kernels/vadd.log
0276b6d0611a4bbcdc004ab3987214aea138245bc7217504147331689a9c0880  release/kernels/vadd.oracle.jsonl
480ad24d43a2d8794d27ae255e8f40a25ff300606637fe81bd63e7f5ee3ea741  release/kernels/vadd.sv-hosted.log
da8a0484a486dc07b80a745f6e74c9b46eff885e154dae6df66b8cb44231fb5b  release/kernels/vadd4.by_instr.json.gz
3f8a733ecf9a07c365e493773eac9795a3e8b76fabe6c63f661ef0b570723166  release/kernels/vadd4.by_unit.json.gz
5edf3b0f5cdc6d57709ad1ea5489bde063b3190c90a27c1f1a43d010b19e7983  release/kernels/vadd4.ccvtrace
cb0f5738726d98e76180a0d28f11334e9fc879f6a7bb838e8b33103f01cdc8cd  release/kernels/vadd4.log
225aa18fc9f38aa9ad615aa11de254337d59fa705877553d873062c68366e0db  release/kernels/vadd4.oracle.jsonl
8d65941a725c10d5a09bf2b2784a732afc2d3c01b5996c9ecfe430ba243f4d55  release/kernels/vadd4.sv-hosted.log
aca522237cb4f331b67b76da652b09d731e7a3c2788b95efea65ecd07b54404a  release/kernels/vaddslow.by_instr.json.gz
28358ec10d66dd98192755cb66462ac284734d350f7890d3ecda9ca0fa798281  release/kernels/vaddslow.by_unit.json.gz
f4edab31577c7354ea3937a41cb1bd675d1b2f6cf11e99ef319d3ce31b4cb878  release/kernels/vaddslow.ccvtrace
b68782cb1f71ca34dd7e2dd75cd964a272da74fa5ba3f975bfe312fd8e908f71  release/kernels/vaddslow.log
e9e6218e8b8450e9f9ff6b39d659c994a1e51c527a0c5bd10d18b5658ae0e344  release/kernels/vaddslow.oracle.jsonl
33f95bdc6f50b43ada0d07c6d24bc06e23307255bfc4f82deab0761c20cd824d  release/kernels/vaddslow.sv-hosted.log
e5144cd0faf40ac615994d323d06619eda8189d30e822213ff6dd80dbe22e06c  release/kernels/waypred.by_instr.json.gz
e34eac2fbe96c32bad23617141c7ea7fa5d23eaf2ff9b9997d31c7b2b5cc6b4d  release/kernels/waypred.by_unit.json.gz
5be72e1d051494726fba08e1bc919a11cd5a7afe6cfd7065564f3a1c0c0c3f24  release/kernels/waypred.ccvtrace
38afb5576cfc4b8c8b08564acdf46af22b328d26a02308f792dbedb801ffccb2  release/kernels/waypred.log
54fb803ce85c4458b8687bb0f61adc32a9d798448b914b06261dc49c2bb841c8  release/kernels/waypred.oracle.jsonl
4317e467e86493d20d9d956d377444d0c69a9041243bfb48f24126b8c93eda15  release/kernels/waypred.sv-hosted.log
80ba10d5c1f780bea9b4beb6c6c0d79337605afcdfac7a1051b453382d444015  release/verify.log
f78197fa73514d4391564b6dbfda61c3c03a38e2134c9ddc2d24180f29c72e6c  release/wiring.txt
```
