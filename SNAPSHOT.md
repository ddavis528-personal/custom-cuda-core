# Snapshot snapshot-2026-11-24-c919af5

**A generated, read-only snapshot. Do not edit or merge it.** The source
is `ccr-9eb50716-lecnjf` at `c919af51640722b3dd2a01d2e391df578c15a4f4`, and this branch is rebuilt from source by
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
| Source | `ccr-9eb50716-lecnjf` @ `c919af51640722b3dd2a01d2e391df578c15a4f4` |
| Built | 2026-11-24 (UTC) |
| Gate | `tools/verify.sh`: PASS |
| Compiler snapshot | custom-cuda-complier `release` @ `a293afe7d7873fb5d3fac70d8deca980e119b19f` (source `b9ae2c9d5d3b838d5d982d842b558e2d290185ea`) |
| Verilator | Verilator 5.052 2026-09-05 rev v5.052 |
| Icarus | Icarus Verilog version 12.0 (stable) () |
| Yosys | Yosys 0.33 (git sha1 2584903a060) |

## Kernels

| Kernel | Result |
|---|---|
| `addrhigh` | `name=addrhigh finished=1 cycles=97 from_fetch=52 retired=5 issue_groups=6 order=ok gpr_mismatch=0 pred_mismatch=0 mem_mismatch=0 check_failures=0 class_violations=0 overflows=0 credit_leaks=0 cor_late=0 channels_used=26/57 violations=0` |
| `addrlimit` | `name=addrlimit finished=1 cycles=107 from_fetch=62 retired=5 issue_groups=5 order=ok gpr_mismatch=0 pred_mismatch=0 mem_mismatch=0 check_failures=0 class_violations=0 overflows=0 credit_leaks=0 cor_late=0 channels_used=28/57 violations=0` |
| `addrneg` | `name=addrneg finished=1 cycles=95 from_fetch=50 retired=1 issue_groups=2 order=ok gpr_mismatch=0 pred_mismatch=0 mem_mismatch=0 check_failures=0 class_violations=0 overflows=0 credit_leaks=0 cor_late=0 channels_used=23/57 violations=0` |
| `atom` | `name=atom finished=1 cycles=8746 from_fetch=8701 retired=29 issue_groups=29 order=ok gpr_mismatch=0 pred_mismatch=0 mem_mismatch=0 check_failures=0 class_violations=0 overflows=0 credit_leaks=0 cor_late=0 channels_used=33/57 violations=0` |
| `atomf` | `name=atomf finished=1 cycles=4654 from_fetch=4609 retired=12 issue_groups=12 order=ok gpr_mismatch=0 pred_mismatch=0 mem_mismatch=0 check_failures=0 class_violations=0 overflows=0 credit_leaks=0 cor_late=0 channels_used=35/57 violations=0` |
| `borrow` | `name=borrow finished=1 cycles=113 from_fetch=68 retired=7 issue_groups=7 order=ok gpr_mismatch=0 pred_mismatch=0 mem_mismatch=0 check_failures=0 class_violations=0 overflows=0 credit_leaks=0 cor_late=0 channels_used=21/57 violations=0` |
| `brs` | `name=brs finished=1 cycles=113 from_fetch=68 retired=12 issue_groups=12 order=ok gpr_mismatch=0 pred_mismatch=0 mem_mismatch=0 check_failures=0 class_violations=0 overflows=0 credit_leaks=0 cor_late=0 channels_used=23/57 violations=0` |
| `byp` | `name=byp finished=1 cycles=143 from_fetch=98 retired=14 issue_groups=14 order=ok gpr_mismatch=0 pred_mismatch=0 mem_mismatch=0 check_failures=0 class_violations=0 overflows=0 credit_leaks=0 cor_late=0 channels_used=32/57 violations=0` |
| `callret` | `name=callret finished=1 cycles=290 from_fetch=245 retired=40 issue_groups=40 order=ok gpr_mismatch=0 pred_mismatch=0 mem_mismatch=0 check_failures=0 class_violations=0 overflows=0 credit_leaks=0 cor_late=0 channels_used=31/57 violations=0` |
| `cas` | `name=cas finished=1 cycles=6986 from_fetch=6941 retired=56 issue_groups=56 order=ok gpr_mismatch=0 pred_mismatch=0 mem_mismatch=0 check_failures=0 class_violations=0 overflows=0 credit_leaks=0 cor_late=0 channels_used=33/57 violations=0` |
| `chains` | `name=chains finished=1 cycles=110 from_fetch=65 retired=29 issue_groups=29 order=ok gpr_mismatch=0 pred_mismatch=0 mem_mismatch=0 check_failures=0 class_violations=0 overflows=0 credit_leaks=0 cor_late=0 channels_used=21/57 violations=0` |
| `coll` | `name=coll finished=1 cycles=92 from_fetch=47 retired=24 issue_groups=24 order=ok gpr_mismatch=0 pred_mismatch=0 mem_mismatch=0 check_failures=0 class_violations=0 overflows=0 credit_leaks=0 cor_late=0 channels_used=21/57 violations=0` |
| `div` | `name=div finished=1 cycles=992 from_fetch=947 retired=144 issue_groups=144 order=ok gpr_mismatch=0 pred_mismatch=0 mem_mismatch=0 check_failures=0 class_violations=0 overflows=0 credit_leaks=0 cor_late=0 channels_used=23/57 violations=0` |
| `divchw` | `name=divchw finished=1 cycles=125 from_fetch=80 retired=5 issue_groups=6 order=ok gpr_mismatch=0 pred_mismatch=0 mem_mismatch=0 check_failures=0 class_violations=0 overflows=0 credit_leaks=0 cor_late=0 channels_used=22/57 violations=0` |
| `divtail` | `name=divtail finished=1 cycles=656 from_fetch=611 retired=96 issue_groups=96 order=ok gpr_mismatch=0 pred_mismatch=0 mem_mismatch=0 check_failures=0 class_violations=0 overflows=0 credit_leaks=0 cor_late=0 channels_used=23/57 violations=0` |
| `divtail2` | `name=divtail2 finished=1 cycles=1531 from_fetch=1486 retired=366 issue_groups=366 order=ok gpr_mismatch=0 pred_mismatch=0 mem_mismatch=0 check_failures=0 class_violations=0 overflows=0 credit_leaks=0 cor_late=0 channels_used=23/57 violations=0` |
| `fence` | `name=fence finished=1 cycles=97 from_fetch=52 retired=7 issue_groups=7 order=ok gpr_mismatch=0 pred_mismatch=0 mem_mismatch=0 check_failures=0 class_violations=0 overflows=0 credit_leaks=0 cor_late=0 channels_used=31/57 violations=0` |
| `gather` | `name=gather finished=1 cycles=305 from_fetch=260 retired=16 issue_groups=16 order=ok gpr_mismatch=0 pred_mismatch=0 mem_mismatch=0 check_failures=0 class_violations=0 overflows=0 credit_leaks=0 cor_late=0 channels_used=33/57 violations=0` |
| `hit` | `name=hit finished=1 cycles=253 from_fetch=208 retired=17 issue_groups=17 order=ok gpr_mismatch=0 pred_mismatch=0 mem_mismatch=0 check_failures=0 class_violations=0 overflows=0 credit_leaks=0 cor_late=0 channels_used=32/57 violations=0` |
| `lanectx` | `name=lanectx finished=1 cycles=84 from_fetch=39 retired=10 issue_groups=10 order=ok gpr_mismatch=0 pred_mismatch=0 mem_mismatch=0 check_failures=0 class_violations=0 overflows=0 credit_leaks=0 cor_late=0 channels_used=30/57 violations=0` |
| `lanectx2` | `name=lanectx2 finished=1 cycles=84 from_fetch=39 retired=10 issue_groups=10 order=ok gpr_mismatch=0 pred_mismatch=0 mem_mismatch=0 check_failures=0 class_violations=0 overflows=0 credit_leaks=0 cor_late=0 channels_used=30/57 violations=0` |
| `late` | `name=late finished=1 cycles=203 from_fetch=158 retired=16 issue_groups=16 order=ok gpr_mismatch=0 pred_mismatch=0 mem_mismatch=0 check_failures=0 class_violations=0 overflows=0 credit_leaks=0 cor_late=0 channels_used=32/57 violations=0` |
| `ldpar` | `name=ldpar finished=1 cycles=188 from_fetch=143 retired=17 issue_groups=17 order=ok gpr_mismatch=0 pred_mismatch=0 mem_mismatch=0 check_failures=0 class_violations=0 overflows=0 credit_leaks=0 cor_late=0 channels_used=32/57 violations=0` |
| `lnorm1` | `name=lnorm1 finished=1 cycles=2586 from_fetch=2541 retired=526 issue_groups=526 order=ok gpr_mismatch=0 pred_mismatch=0 mem_mismatch=0 check_failures=0 class_violations=0 overflows=0 credit_leaks=0 cor_late=0 channels_used=38/57 violations=0` |
| `localsp` | `name=localsp finished=1 cycles=233 from_fetch=188 retired=40 issue_groups=40 order=ok gpr_mismatch=0 pred_mismatch=0 mem_mismatch=0 check_failures=0 class_violations=0 overflows=0 credit_leaks=0 cor_late=0 channels_used=32/57 violations=0` |
| `loop` | `name=loop finished=1 cycles=2856 from_fetch=2811 retired=407 issue_groups=407 order=ok gpr_mismatch=0 pred_mismatch=0 mem_mismatch=0 check_failures=0 class_violations=0 overflows=0 credit_leaks=0 cor_late=0 channels_used=23/57 violations=0` |
| `merge` | `name=merge finished=1 cycles=85 from_fetch=40 retired=9 issue_groups=9 order=ok gpr_mismatch=0 pred_mismatch=0 mem_mismatch=0 check_failures=0 class_violations=0 overflows=0 credit_leaks=0 cor_late=0 channels_used=21/57 violations=0` |
| `missrun` | `name=missrun finished=1 cycles=146 from_fetch=101 retired=28 issue_groups=28 order=ok gpr_mismatch=0 pred_mismatch=0 mem_mismatch=0 check_failures=0 class_violations=0 overflows=0 credit_leaks=0 cor_late=0 channels_used=32/57 violations=0` |
| `mload` | `name=mload finished=1 cycles=136 from_fetch=91 retired=11 issue_groups=11 order=ok gpr_mismatch=0 pred_mismatch=0 mem_mismatch=0 check_failures=0 class_violations=0 overflows=0 credit_leaks=0 cor_late=0 channels_used=32/57 violations=0` |
| `mlp` | `name=mlp finished=1 cycles=151 from_fetch=106 retired=21 issue_groups=21 order=ok gpr_mismatch=0 pred_mismatch=0 mem_mismatch=0 check_failures=0 class_violations=0 overflows=0 credit_leaks=0 cor_late=0 channels_used=32/57 violations=0` |
| `mwmiss` | `name=mwmiss finished=1 cycles=155 from_fetch=110 retired=88 issue_groups=88 order=ok gpr_mismatch=0 pred_mismatch=0 mem_mismatch=0 check_failures=0 class_violations=0 overflows=0 credit_leaks=0 cor_late=0 channels_used=32/57 violations=0` |
| `narrowadd` | `name=narrowadd finished=1 cycles=261 from_fetch=216 retired=21 issue_groups=21 order=ok gpr_mismatch=0 pred_mismatch=0 mem_mismatch=0 check_failures=0 class_violations=0 overflows=0 credit_leaks=0 cor_late=0 channels_used=33/57 violations=0` |
| `pgcross` | `name=pgcross finished=1 cycles=196 from_fetch=151 retired=8 issue_groups=8 order=ok gpr_mismatch=0 pred_mismatch=0 mem_mismatch=0 check_failures=0 class_violations=0 overflows=0 credit_leaks=0 cor_late=0 channels_used=32/57 violations=0` |
| `pguard` | `name=pguard finished=1 cycles=101 from_fetch=56 retired=12 issue_groups=12 order=ok gpr_mismatch=0 pred_mismatch=0 mem_mismatch=0 check_failures=0 class_violations=0 overflows=0 credit_leaks=0 cor_late=0 channels_used=30/57 violations=0` |
| `plog` | `name=plog finished=1 cycles=85 from_fetch=40 retired=11 issue_groups=11 order=ok gpr_mismatch=0 pred_mismatch=0 mem_mismatch=0 check_failures=0 class_violations=0 overflows=0 credit_leaks=0 cor_late=0 channels_used=21/57 violations=0` |
| `pmovdiv` | `name=pmovdiv finished=1 cycles=118 from_fetch=73 retired=12 issue_groups=12 order=ok gpr_mismatch=0 pred_mismatch=0 mem_mismatch=0 check_failures=0 class_violations=0 overflows=0 credit_leaks=0 cor_late=0 channels_used=22/57 violations=0` |
| `predlane` | `name=predlane finished=1 cycles=942 from_fetch=897 retired=10 issue_groups=10 order=ok gpr_mismatch=0 pred_mismatch=0 mem_mismatch=0 check_failures=0 class_violations=0 overflows=0 credit_leaks=0 cor_late=0 channels_used=32/57 violations=0` |
| `predmerge` | `name=predmerge finished=1 cycles=954 from_fetch=909 retired=9 issue_groups=9 order=ok gpr_mismatch=0 pred_mismatch=0 mem_mismatch=0 check_failures=0 class_violations=0 overflows=0 credit_leaks=0 cor_late=0 channels_used=34/57 violations=0` |
| `predspill` | `name=predspill finished=1 cycles=982 from_fetch=937 retired=12 issue_groups=12 order=ok gpr_mismatch=0 pred_mismatch=0 mem_mismatch=0 check_failures=0 class_violations=0 overflows=0 credit_leaks=0 cor_late=0 channels_used=32/57 violations=0` |
| `predswap` | `name=predswap finished=1 cycles=1200 from_fetch=1155 retired=46 issue_groups=46 order=ok gpr_mismatch=0 pred_mismatch=0 mem_mismatch=0 check_failures=0 class_violations=0 overflows=0 credit_leaks=0 cor_late=0 channels_used=34/57 violations=0` |
| `privwin` | `name=privwin finished=1 cycles=203 from_fetch=158 retired=52 issue_groups=52 order=ok gpr_mismatch=0 pred_mismatch=0 mem_mismatch=0 check_failures=0 class_violations=0 overflows=0 credit_leaks=0 cor_late=0 channels_used=35/57 violations=0` |
| `provswap` | `name=provswap finished=1 cycles=2324 from_fetch=2279 retired=978 issue_groups=978 order=ok gpr_mismatch=0 pred_mismatch=0 mem_mismatch=0 check_failures=0 class_violations=0 overflows=0 credit_leaks=0 cor_late=0 channels_used=34/57 violations=0` |
| `retmiss` | `name=retmiss finished=1 cycles=218 from_fetch=173 retired=19 issue_groups=19 order=ok gpr_mismatch=0 pred_mismatch=0 mem_mismatch=0 check_failures=0 class_violations=0 overflows=0 credit_leaks=0 cor_late=0 channels_used=34/57 violations=0` |
| `roconst` | `name=roconst finished=1 cycles=90 from_fetch=45 retired=4 issue_groups=5 order=ok gpr_mismatch=0 pred_mismatch=0 mem_mismatch=0 check_failures=0 class_violations=0 overflows=0 credit_leaks=0 cor_late=0 channels_used=26/57 violations=0` |
| `rogated` | `name=rogated finished=1 cycles=110 from_fetch=65 retired=7 issue_groups=8 order=ok gpr_mismatch=0 pred_mismatch=0 mem_mismatch=0 check_failures=0 class_violations=0 overflows=0 credit_leaks=0 cor_late=0 channels_used=26/57 violations=0` |
| `rokill` | `name=rokill finished=1 cycles=120 from_fetch=75 retired=41 issue_groups=4536 order=ok gpr_mismatch=0 pred_mismatch=0 mem_mismatch=0 check_failures=0 class_violations=0 overflows=0 credit_leaks=0 cor_late=0 channels_used=27/57 violations=0` |
| `rokilllane` | `name=rokilllane finished=1 cycles=1228 from_fetch=1183 retired=924 issue_groups=10674 order=ok gpr_mismatch=0 pred_mismatch=0 mem_mismatch=0 check_failures=0 class_violations=0 overflows=0 credit_leaks=0 cor_late=0 channels_used=27/57 violations=0` |
| `rolaunch` | `name=rolaunch finished=1 cycles=88 from_fetch=43 retired=4 issue_groups=5 order=ok gpr_mismatch=0 pred_mismatch=0 mem_mismatch=0 check_failures=0 class_violations=0 overflows=0 credit_leaks=0 cor_late=0 channels_used=24/57 violations=0` |
| `rolimit` | `name=rolimit finished=1 cycles=90 from_fetch=45 retired=4 issue_groups=5 order=ok gpr_mismatch=0 pred_mismatch=0 mem_mismatch=0 check_failures=0 class_violations=0 overflows=0 credit_leaks=0 cor_late=0 channels_used=26/57 violations=0` |
| `roload` | `name=roload finished=1 cycles=129 from_fetch=84 retired=8 issue_groups=8 order=ok gpr_mismatch=0 pred_mismatch=0 mem_mismatch=0 check_failures=0 class_violations=0 overflows=0 credit_leaks=0 cor_late=0 channels_used=32/57 violations=0` |
| `rope` | `name=rope finished=1 cycles=770 from_fetch=725 retired=354 issue_groups=354 order=ok gpr_mismatch=0 pred_mismatch=0 mem_mismatch=0 check_failures=0 class_violations=0 overflows=0 credit_leaks=0 cor_late=0 channels_used=35/57 violations=0` |
| `ropediv` | `name=ropediv finished=1 cycles=1062 from_fetch=1017 retired=203 issue_groups=203 order=ok gpr_mismatch=0 pred_mismatch=0 mem_mismatch=0 check_failures=0 class_violations=0 overflows=0 credit_leaks=0 cor_late=0 channels_used=35/57 violations=0` |
| `sel` | `name=sel finished=1 cycles=91 from_fetch=46 retired=8 issue_groups=8 order=ok gpr_mismatch=0 pred_mismatch=0 mem_mismatch=0 check_failures=0 class_violations=0 overflows=0 credit_leaks=0 cor_late=0 channels_used=30/57 violations=0` |
| `sized` | `name=sized finished=1 cycles=1001 from_fetch=956 retired=25 issue_groups=25 order=ok gpr_mismatch=0 pred_mismatch=0 mem_mismatch=0 check_failures=0 class_violations=0 overflows=0 credit_leaks=0 cor_late=0 channels_used=33/57 violations=0` |
| `slotform` | `name=slotform finished=1 cycles=486 from_fetch=441 retired=12 issue_groups=12 order=ok gpr_mismatch=0 pred_mismatch=0 mem_mismatch=0 check_failures=0 class_violations=0 overflows=0 credit_leaks=0 cor_late=0 channels_used=33/57 violations=0` |
| `spinwait` | `name=spinwait finished=1 cycles=2062 from_fetch=2017 retired=211 issue_groups=211 order=ok gpr_mismatch=0 pred_mismatch=0 mem_mismatch=0 check_failures=0 class_violations=0 overflows=0 credit_leaks=0 cor_late=0 channels_used=35/57 violations=0` |
| `spmbank` | `name=spmbank finished=1 cycles=200 from_fetch=155 retired=13 issue_groups=13 order=ok gpr_mismatch=0 pred_mismatch=0 mem_mismatch=0 check_failures=0 class_violations=0 overflows=0 credit_leaks=0 cor_late=0 channels_used=28/57 violations=0` |
| `srd` | `name=srd finished=1 cycles=84 from_fetch=39 retired=6 issue_groups=6 order=ok gpr_mismatch=0 pred_mismatch=0 mem_mismatch=0 check_failures=0 class_violations=0 overflows=0 credit_leaks=0 cor_late=0 channels_used=30/57 violations=0` |
| `stall` | `name=stall finished=1 cycles=581 from_fetch=536 retired=116 issue_groups=116 order=ok gpr_mismatch=0 pred_mismatch=0 mem_mismatch=0 check_failures=0 class_violations=0 overflows=0 credit_leaks=0 cor_late=0 channels_used=32/57 violations=0` |
| `swap` | `name=swap finished=1 cycles=581 from_fetch=536 retired=174 issue_groups=174 order=ok gpr_mismatch=0 pred_mismatch=0 mem_mismatch=0 check_failures=0 class_violations=0 overflows=0 credit_leaks=0 cor_late=0 channels_used=32/57 violations=0` |
| `transp4` | `name=transp4 finished=1 cycles=1246 from_fetch=1201 retired=976 issue_groups=976 order=ok gpr_mismatch=0 pred_mismatch=0 mem_mismatch=0 check_failures=0 class_violations=0 overflows=0 credit_leaks=0 cor_late=0 channels_used=38/57 violations=0` |
| `unal` | `name=unal finished=1 cycles=174 from_fetch=129 retired=9 issue_groups=9 order=ok gpr_mismatch=0 pred_mismatch=0 mem_mismatch=0 check_failures=0 class_violations=0 overflows=0 credit_leaks=0 cor_late=0 channels_used=33/57 violations=0` |
| `vadd` | `name=vadd finished=1 cycles=197 from_fetch=152 retired=17 issue_groups=17 order=ok gpr_mismatch=0 pred_mismatch=0 mem_mismatch=0 check_failures=0 class_violations=0 overflows=0 credit_leaks=0 cor_late=0 channels_used=34/57 violations=0` |
| `vadd4` | `name=vadd4 finished=1 cycles=247 from_fetch=202 retired=68 issue_groups=68 order=ok gpr_mismatch=0 pred_mismatch=0 mem_mismatch=0 check_failures=0 class_violations=0 overflows=0 credit_leaks=0 cor_late=0 channels_used=34/57 violations=0` |
| `vadd6` | `name=vadd6 finished=1 cycles=349 from_fetch=304 retired=102 issue_groups=102 order=ok gpr_mismatch=0 pred_mismatch=0 mem_mismatch=0 check_failures=0 class_violations=0 overflows=0 credit_leaks=0 cor_late=0 channels_used=34/57 violations=0` |
| `vaddslow` | `name=vaddslow finished=1 cycles=572 from_fetch=527 retired=17 issue_groups=17 order=ok gpr_mismatch=0 pred_mismatch=0 mem_mismatch=0 check_failures=0 class_violations=0 overflows=0 credit_leaks=0 cor_late=0 channels_used=34/57 violations=0` |
| `waypred` | `name=waypred finished=1 cycles=255 from_fetch=210 retired=18 issue_groups=18 order=ok gpr_mismatch=0 pred_mismatch=0 mem_mismatch=0 check_failures=0 class_violations=0 overflows=0 credit_leaks=0 cor_late=0 channels_used=32/57 violations=0` |

## Manifest of release/

```
20ee48e38e2831a4eb40425a90093dea700dcc8f909ff9302d615ba1556736cf  release/kernels/addrhigh.by_instr.json.gz
453e7940dc5340cf75589d2b36e1cb666ac3cef710872c0d1aa7312dff45493b  release/kernels/addrhigh.by_unit.json.gz
0ae129059e1e1ae3384c7c2e0b9bc7670fe0ad34be0a50dd748e64cb6ab75ff6  release/kernels/addrhigh.ccvtrace
8c262aabc8513395c961334a556b06e348c621684229fc08f8fc027aa6c8763d  release/kernels/addrhigh.log
569f2e22883fad5f0956c57ec734e6afbdd4b8a854e50277425172d6c0cbd766  release/kernels/addrhigh.oracle.jsonl
0ca5b170ac642268707142c81d5bf3faa26879bb65b3f593b3b844c254989d46  release/kernels/addrhigh.sv-hosted.log
46e943fcc54042aff9d156b39c48d4dc672c81facd9260e1237a66724927d6de  release/kernels/addrlimit.by_instr.json
864c0bc2a4ce482185348edf40591cce307269ee6abec293214daa584e215cf8  release/kernels/addrlimit.by_unit.json
19b1970a7f3795df488b793d1a599220bf1dd8c1c60568808fdb454cff60a92e  release/kernels/addrlimit.ccvtrace
04cd9bd6f29f252da5ad16964569447f02c30125978d852c4709ae3e9f9b978a  release/kernels/addrlimit.log
bc660b0b40359a2c5a2478cb0eb4950b73fd22db50ea76b80052bc195a1920f4  release/kernels/addrlimit.oracle.jsonl
5395d2f08cc088de9563eeaec42c528f1dbd9c16ff9a1ec1d4b2da4c5c330244  release/kernels/addrlimit.sv-hosted.log
8f8665b3cf94aaf6918e5964b8f1bc44148ae152f2625b935089fa1113668fd6  release/kernels/addrneg.by_instr.json
975b65c4c5ea12e08806297d6711732055909e6f142cc19f2771648c1a1402cf  release/kernels/addrneg.by_unit.json
ca95f5bc9b5a38c9a4b55584b40ef866d0bae9847d1c737b9650508222652023  release/kernels/addrneg.ccvtrace
aa71be9c5be05797bccec2d532ec995965b666f5b35390a91a4a031c83da964f  release/kernels/addrneg.log
16f5b0707ae44492a1efd67bb9dd38a7e79a7bbd354fa9207b9e7d150ff2f107  release/kernels/addrneg.oracle.jsonl
80a8451bf2ff76c5fca711695d28d40424ad273d0acccf027161a8927e270f6a  release/kernels/addrneg.sv-hosted.log
033da75bc242f7ed5396e175c0b55e7906ce84abb1c7b271eaee3652b931a941  release/kernels/atom.by_instr.json.gz
6b6cc7ca34ccd7dc9357f833a8c3fe161c22f66eb8f2a43f3c38f36b38b1bfaf  release/kernels/atom.by_unit.json.gz
797d54335b19f17db40cb50700fd6d672483c20c399983d17b7c22ed41852d07  release/kernels/atom.ccvtrace
2bd6535582e3abd3439cd60172d98616640734337f207f1030885d7ea49cf5aa  release/kernels/atom.log
504f5b6e9d25114dc35f2c70b21bb7b3f3c508c691de12dc0e87d12a74285361  release/kernels/atom.oracle.jsonl
1fdf9c57936c4e49514c83a2e1d561a70ed2ca65e1d5c6b33198c285df645ea6  release/kernels/atom.sv-hosted.log
e0c5e94ee6d46c781d6f61371ba7cae666660c5cb3faee7c7950710419ebbda1  release/kernels/atomf.by_instr.json.gz
96d6bcfb8c8e866c527fd3d40d4cc964fe7b0d7ea16225bb18c7cb68677115fd  release/kernels/atomf.by_unit.json.gz
e888bba046e29bba2f2b00119d3ab01329aabf2cb41340122aafe2800a113d80  release/kernels/atomf.ccvtrace
d081e212795172a533425bd1c5fe9bbd6378a0b58ce16d803871b467018a95ca  release/kernels/atomf.log
cfd1179edf4061a33ab2f75d7a6dec61decfe629000198189a7bfc2647b34238  release/kernels/atomf.oracle.jsonl
b6be65b9ec01fdbdfe62d64490cf87fdc749a0ea4317010e1d77d368235a0845  release/kernels/atomf.sv-hosted.log
724c193d10b01a47f904ce90e9a3b07fd8aaf31c97b503e41d02bc83d476e14b  release/kernels/borrow.by_instr.json.gz
0155b7e9d6752f9206a5c5e2081273f79fde699a749edcd6caf556fbef18307f  release/kernels/borrow.by_unit.json.gz
3edfd61a186bfa758b8d04dbd80df2e8d512e395a967fa9e17b90d21ebd652f1  release/kernels/borrow.ccvtrace
4a30435ce7a742f82fb025f57f8683b4f31ba1d9ebcf60f1010ee961715b7c50  release/kernels/borrow.log
4c565e1ce0b3baee36e158694b32c8defb5cd662b2f9af75cb5d8c26cb1168ed  release/kernels/borrow.oracle.jsonl
b61e5d55f37fe54433c79e21d7228c05e9ba0c320fdd24ac60115319e5ea872b  release/kernels/borrow.sv-hosted.log
6871e655a3b43963d421238d03d285b5881cffe82520fc128ce94bf5c3ab6d17  release/kernels/brs.by_instr.json.gz
81b95792909e4a620c5b7657f1870260ea8f4be6203917e9aa7c4c17dea4d8dc  release/kernels/brs.by_unit.json.gz
f1cd4f404850590aca4cdeda4f3362acf51fcb3969eda45616f8b51e5d389ad9  release/kernels/brs.ccvtrace
598ef73541fe01f4ba9e70f9bfbf9983f9ef61c3167cabd97bafb7a2168ef3d3  release/kernels/brs.log
e3c1cb3379580cf1aae44e8ddc8e846ef6fd661a573cfe0a8d4444b18a14dc56  release/kernels/brs.oracle.jsonl
acf8ba71bd4237194a5ec818d161b897235e46a5ebef5c21b3e059b9854c0319  release/kernels/brs.sv-hosted.log
5e368716b36fa90bdafd81fd3981e977d447484f830b4181ade291ebfcfc30d5  release/kernels/byp.by_instr.json.gz
f5582bf81298dcc7d775f01f38edf98107a0fffea9e2b6dd9137455167070716  release/kernels/byp.by_unit.json.gz
fad2fdb3804beaee0f9a3984ab23cb8e81c4be12cc2783cf9bc6af282f63d32d  release/kernels/byp.ccvtrace
f3569396ba05620d4bd418fa05de2598a51e3677f576038e2587425fbb6faf97  release/kernels/byp.log
5a03dfa4f3603fef49f1e3639e74e34152ca3ca5ef8e41eb959f8323040fa2d5  release/kernels/byp.oracle.jsonl
526e48dff70f029d20329d500e906c5fcb08ec68e7abc65f702ed8779da33ac8  release/kernels/byp.sv-hosted.log
5a07cb784a905869de9947eef75715bc8afd8bd031b287695057dbff2395c5e4  release/kernels/callret.by_instr.json.gz
03144d3ffaa9c006761721cb1b2cca1cf1c580519783586079931d2ae8fe9956  release/kernels/callret.by_unit.json.gz
37b60e82e7a301b0a6c3f86cd9a97f14a1ea8fbe6bb6dffc95a5a3ebafd9aaae  release/kernels/callret.ccvtrace
0a7a0e0bdbaec0105323b92f1d67382c1f446d0c286bdf08e0360a68a7ea759e  release/kernels/callret.log
9b1d1b50b527f732362f837250aa2f26dabf3e76e16a4794856ebd8f105635b8  release/kernels/callret.oracle.jsonl
e8450b15d0bc51f2a83becdce15f12e2f2754753d4abea0e638a4e7ff5a5ee9f  release/kernels/callret.sv-hosted.log
d506451b750f036ec13584a2f0b32ae4a6cbd0584539502270c815b087195a5e  release/kernels/cas.by_instr.json.gz
9518918876251cb8bf99e057541bf04999860bb78c5d3f656c3fb93355dd9767  release/kernels/cas.by_unit.json.gz
dc49d8fdd26dda21990042ef6d02dbb92fd98683141d71e1ae9883237213c069  release/kernels/cas.ccvtrace
526e4e0b4d677a9d63dd20ac839f85c4f909860805d3e0396d6f58551aeb5266  release/kernels/cas.log
0ab31a9443336fe5d08e1a5fa5fcba3bc279b19022f7c5007908d39d8ef39536  release/kernels/cas.oracle.jsonl
4f84f03b1197b19d5a42ac5d1f638467e5839698ddf93f295c1da31589c38ad9  release/kernels/cas.sv-hosted.log
54c4dc9e7be28c8724d0d3f9176eaff200904199d46987479db83fe0674bc20d  release/kernels/chains.by_instr.json.gz
de77abc7220e8235578867f0884d5a2eb555c328d83232bda22796782e21f415  release/kernels/chains.by_unit.json.gz
520637b4ca14de3ff66718fb9e68e41134e5c456612cab51f14ccb69a9802fe4  release/kernels/chains.ccvtrace
311e2e8b478ec08d04a3a37a374e07c1babbd5dab3ac8b3898f5f402ca912e43  release/kernels/chains.log
26a4cc5c5524c7219d8706c2582c80357dea60be9d6ffdec99dac7d0365e2264  release/kernels/chains.oracle.jsonl
0bdc7a1d2bc97e219cf43e85e4e1832ceeaf0e5bee7b36e351995efa2d153064  release/kernels/chains.sv-hosted.log
c7f188771387968514930b41aec73a118a96bbb0c1158020c2b2cb17069450a2  release/kernels/coll.by_instr.json.gz
9379a8a7887e60056f35bebbdb462dbf25ea7a2f5affa9dee6e78571648b01f4  release/kernels/coll.by_unit.json.gz
c8395342e50fa1411fc9e1cc08847942c35034a98673257a52395cff9506bcf9  release/kernels/coll.ccvtrace
1f94e8e915b618b415d9a23239f0f437032625e84841192264411dd14c061e66  release/kernels/coll.log
dd718d23c88df5dc7d92b055d8542865aa0e029118486af127312a8a578cfcbc  release/kernels/coll.oracle.jsonl
fd1320f43b591c9dcec7b1c90635a21a6b304018704418d1f7684e003708e4ff  release/kernels/coll.sv-hosted.log
bd6cc324f4ab49db694bcf5af9251f688abc5345327871c5dc21bb0089951e36  release/kernels/div.by_instr.json.gz
c97cc327cdad09f2f8cd84725e6f162186377b48fa4ac0f3b8e5504361ca5efd  release/kernels/div.by_unit.json.gz
52e372c9ab8b2e93a93d6b8b73ef6adde36081b43590718a75ba1e162d334db1  release/kernels/div.ccvtrace
31709da17f31b5ebe42649ff0c90395209169a4922d52ead0f28102adead6fbd  release/kernels/div.log
71a567b85cf85622631490187563de9a5661099c78a590adff4ed0a0c3d24c16  release/kernels/div.oracle.jsonl
ebc0ac54a6240eab474b91b85a89fe5aff9054c587afcf67a826f023ecfe552c  release/kernels/div.sv-hosted.log
eb68bd8d3926903c67dfa77d089e9b8bed4a03a83166306eacc1af4498ad9f18  release/kernels/divchw.by_instr.json.gz
664a77f44f68638d6a10691a2437e65165affb23c51c6ff4a357c794fad02191  release/kernels/divchw.by_unit.json.gz
4fe974515ba66dc40ad4876bcbfe310a78b48f2e1715facd3ac51aa321f0ffcd  release/kernels/divchw.ccvtrace
a45208754439400a23ee1cf29a342307e4dae92a25807f27ac3a4664ff0e6fab  release/kernels/divchw.log
58a541797f7a2df0a1c7528ae6a3edec212db90c7d3eb20656806f38b5c10b3d  release/kernels/divchw.oracle.jsonl
2bfa6b1220d8d2e6616ffdf4c633b67a716aaa6e99c31096f9d3cc7ef1eddb97  release/kernels/divchw.sv-hosted.log
fa881cd2938ed7a409c351089cd54b7aacfc2172fc2e0eacad11886c7af60035  release/kernels/divtail.by_instr.json.gz
2beef9a74a24d1c22db289e101c76febc96b9472fbb689ae33bc6bf635a36e11  release/kernels/divtail.by_unit.json.gz
cf8e154b191e828aaa771e84f4787f75466454fa0f1cad6d3ee7d831fdfef587  release/kernels/divtail.ccvtrace
7d253f91f1224853d1b8b6dfb1cef3ca37f03a08b67daaeeca69023e8240cf6c  release/kernels/divtail.log
75f11a75c9b3b336e446140af4579f05b46c363a76b7aab3ec88154a07ba097d  release/kernels/divtail.oracle.jsonl
838d28c360a9e50cbba7dc2cb2c850621b1d0856b555d3ee7f6205bf4b4b8b56  release/kernels/divtail.sv-hosted.log
c8e0d8fa61e354ae8f47aead28ad25ab22f1678694eaf437bef6f969945e5539  release/kernels/divtail2.by_instr.json.gz
78873059d95447f3791790bfe119607d37e834b40635895eb1e636eb76c6970b  release/kernels/divtail2.by_unit.json.gz
1e64902dfd7a748b57e0d7a68abea026230d563174bc2359f04a17cf0e6b3b2c  release/kernels/divtail2.ccvtrace
eec17c438b8b0d8b735c00f1edf22ff8736bc598f864aac36d8fec64c38bc493  release/kernels/divtail2.log
b2db6b05eb6cf4a0a7677e31d0c6c2952d5cab49d353f0bb1883fe0b2a20ed14  release/kernels/divtail2.oracle.jsonl
ad09c93f0821905b8ad4c1766bda0de09738b18ba942f5cd9ed936a14dfbcf2e  release/kernels/divtail2.sv-hosted.log
02cc7b9017a9108c4f50a2efb8772277ef6bbdfe914b0ec4767ba8b4e8a4fafb  release/kernels/fence.by_instr.json
60bf4dfa8a9b0df06ca70e78f28238014dac0c1cb7842dc4095431edc2afcabe  release/kernels/fence.by_unit.json.gz
7aeae6eaa496be2c18ce66c0c4e75f0d442864563007944997342ab51e0f9764  release/kernels/fence.ccvtrace
e144761a64683d25e879eacacdf2493cdb24fa9366d98a571dcc4f03b56d82ce  release/kernels/fence.log
d1d40317f6cf5bfb430cda1f9c0ef676609e59cabe2a11623c42ffbeca93142b  release/kernels/fence.oracle.jsonl
e43f2e2603a821c070885bfd24ffb206d0e5e2c602d49fe6254d8192d3e6988c  release/kernels/fence.sv-hosted.log
3403a1f1ded634b28e9b1e86f73054cb1f036cc7d0a0abac298260ebb9ecb2f6  release/kernels/gather.by_instr.json.gz
791aa01c3a826ad0ba07e9042826e80fd9f8a43a3bc48d9e0a6ea9b407762b99  release/kernels/gather.by_unit.json.gz
ee8f96b252913bf6f7d93969004dc5223a2e0e5e70c5e7cd7a0bc3b359222112  release/kernels/gather.ccvtrace
20fa50e271361eb584e85c1ec0984539e8595853efa16e15388b69e6dacf7647  release/kernels/gather.log
0413e781d8d6ff578c64eb1f800b7931e66f676d5cdabb97b94a4033e6037662  release/kernels/gather.oracle.jsonl
a0e23b65dd06b19414d4e6a5ab47644526344b482e71f3cf8131bd43cf0b2350  release/kernels/gather.sv-hosted.log
d11c96b4b63c1a102519851b2da03d5df0d0851e39ec76b194ef2a6e8de6c50b  release/kernels/hit.by_instr.json.gz
b83b057497878462319a0e743e6a1bafeeec1d3215b1ae5bdf850c6f6a00c262  release/kernels/hit.by_unit.json.gz
735e3e4b754041adf2cd9f7921a12e2d206beebe8746fd451a0488eeec7081f0  release/kernels/hit.ccvtrace
08d22357f2f434ac4b4a4629ba9e545fbfa3a96d4fc8dd9ceae3f8289b315424  release/kernels/hit.log
7ba9603e0088d9164de6528f16ef6a7fa9ce5821c8c12b52cbb3734e39b9fd52  release/kernels/hit.oracle.jsonl
ef5878fede5fe1d55513b974dc7cc847a47f3f03cebfdd5e0b876527084c6fbf  release/kernels/hit.sv-hosted.log
ba52e507e8f964663a0cbc762638b971f69558107dac7276de17f16ae7e3a180  release/kernels/lanectx.by_instr.json.gz
dc3f3e74ef393aed5768fdc01074a9fbcd256d537c398f96570efac69aede53c  release/kernels/lanectx.by_unit.json.gz
278282dd369c754555c55fedda1cbb6ba7503aa6db3cd38871efe993aa103826  release/kernels/lanectx.ccvtrace
0421102336d42de90a83fba8e5cd92bb3552a0789c4a23f7887af04cbc9f50b8  release/kernels/lanectx.log
888551babf540db8e3025b82e65ca655013f93eba3c8a65689d069d52a7e6039  release/kernels/lanectx.oracle.jsonl
bdac28a196e150a7b58b6c30988083780cee87a8e348bf9bbab35cdbda2fd877  release/kernels/lanectx.sv-hosted.log
adb377b7d83b3101d1ec1ad0cee5203fc60e74204fa139a6cc9279e279684969  release/kernels/lanectx2.by_instr.json.gz
0a11abababb9289e66b9b11605e01ca67e5666100d9b7f845da3041d09ada928  release/kernels/lanectx2.by_unit.json.gz
c78e8ffee4b615eae44985891233d95ec9b39e5ebedec165568495ed4a060ef8  release/kernels/lanectx2.ccvtrace
95da530e422219e6ca8deb8f1e946eacc657156d7f1f33c515b96f6ad12e5cfa  release/kernels/lanectx2.log
45c13056dff5c73ed0c9ece56cc36f929bf335322193c7d5eb38710b1d1dfb02  release/kernels/lanectx2.oracle.jsonl
26f286324e255ab1216bb5c85cd8c5aa895c3855810d96e4f0aa32b0959ac600  release/kernels/lanectx2.sv-hosted.log
bf2c226446de5ce717687ac43cac82146547f996ecf8534b8de9c40919a16f6e  release/kernels/late.by_instr.json.gz
aa694fd36a213c30af5eaf071458247dba6532ff2cf3c84c40965a09c456c7e1  release/kernels/late.by_unit.json.gz
89990f4c312f36e9af525b1140216180961d28754e12c0a447be546f40bcd4ff  release/kernels/late.ccvtrace
35af91c8773d23b2f2c3a12ffca2fe028b38bf48ca664a0b4905d9cd209a0eca  release/kernels/late.log
86084f6bd747a2cf32acbc0ebd96ebd3e4ef2d8d9e21be49e3ae49290d7927f3  release/kernels/late.oracle.jsonl
970b16b137cb81a320c191d6bb3719740914d9426ddcc50f33e3f2f158dc79b7  release/kernels/late.sv-hosted.log
f47ffb7e349477f5ea35cdb2e131886b3240eae580973d206d0c7ed8451b8765  release/kernels/ldpar.by_instr.json.gz
aecdbf0d95bfc75879fd22c3cd4ca6577c5f957763407f8939aa5c6ced1daab3  release/kernels/ldpar.by_unit.json.gz
d35f767b3b3643e898b79093465396b17ecb6beda48259913f4f688ae038b6e8  release/kernels/ldpar.ccvtrace
ca4a07aaaaa02a2ceac72fb1016d90fc3728ea949690c97c9d18586a08459ec7  release/kernels/ldpar.log
8ac08538e9c807637babd61b31e340f7461878ada31f0c0b83cd66331cfaf486  release/kernels/ldpar.oracle.jsonl
b11002ecf4297fdf1a0f681208c341603d509ffbe57d8fc1b6bf1b4d2f92a3c7  release/kernels/ldpar.sv-hosted.log
86feedd87fcdfabb7c0ea0b8a07d4413685e6059283d6a494bb7b2c1aa4c6e1e  release/kernels/lnorm1.by_instr.json.gz
1f90bc8756ef3ec268e5a64d8d6deccb5b6f26a98fba65fc272a6984280f15a6  release/kernels/lnorm1.by_unit.json.gz
a51891466de3d6adeaae5eec5f07bb203809aa7440c03ed92f0e5f1a09649c44  release/kernels/lnorm1.ccvtrace
d06e7b79eaee21fd5d9458744103a9afb841260640490fab1d3f0df3c9924df0  release/kernels/lnorm1.log
a8d85811af988a1b9fc00db1517300af3d93ec8e589e403d3b9113fa9e0ffc86  release/kernels/lnorm1.oracle.jsonl
0a11aaa21938701e066ee7b36a472d8b7238352c7d77d284078cf065beb2bea6  release/kernels/lnorm1.sv-hosted.log
2edb51c70d0f0f0c900c52c183d8e2ade214b99c5a0d650ae01f841e63e30528  release/kernels/localsp.by_instr.json.gz
14d61dd8838e93ad3b911b5239831354fb968250247e39f6af82231b385f8607  release/kernels/localsp.by_unit.json.gz
a48e944351c17396abfbaaba34cd7f467a7e01f97c99286f88e39b0a5692b7a9  release/kernels/localsp.ccvtrace
78540e7ebce3cbe543e8953b43634cf1e936805cef5b3ec536cdf9a371202241  release/kernels/localsp.log
55e3c9f36e7f7d38c0ddd38903aff4bb4509ae862015c592e6b937ea258042ca  release/kernels/localsp.oracle.jsonl
f8bd30538ab8cb6220056d38ba69313a8a048cab13ea3e096c2cd58fa04e5031  release/kernels/localsp.sv-hosted.log
326224602c19e08645baaf48fe110e297a93b272607eb0d791e831f3345b5e88  release/kernels/loop.by_instr.json.gz
273e834cd4de0063c83a5207e7932ecfb78d6d62b6fefe3d4f292eb30be8f374  release/kernels/loop.by_unit.json.gz
4282db3ef7e25eed678da3a1764b3297bf604de603f2c8b22fbba04e39ba0376  release/kernels/loop.ccvtrace
81034ddc9c8385dd21e4df63ac3c7eceeaf3ec10f44230b6211a4685c313b9a4  release/kernels/loop.log
03ce5920c06c93e93516d8e53c3f7169f14e3593de204eacceffc0b8a3e32016  release/kernels/loop.oracle.jsonl
189520354df1de62422cf08d5c2026959eb10d97b092374d6e79ee51cd4a5571  release/kernels/loop.sv-hosted.log
38e221b7aa172cfaec81c56eb5e9a485eb62eeb14650f5332c3d0db0ab342f16  release/kernels/merge.by_instr.json.gz
7f3e23e94d7a313ae5247675620737a581169956a2407051478bbe7be0547d6c  release/kernels/merge.by_unit.json.gz
1cdb81e86e4d30ab9e1a19efd1f3890da9123ddb88187024044b96268bbc023d  release/kernels/merge.ccvtrace
84b6598d4fe037255e54e52a29ee3d9fe151fd9b6c3c18cf07335442ececd222  release/kernels/merge.log
f96d28815f8756b1f5a45ded53e6170883d2dfa10f9eef0d14b8050b1318164a  release/kernels/merge.oracle.jsonl
fc7dbac78f7924402f051e55f532f00b75846ba831d3bb0b9d5130c4496f32ce  release/kernels/merge.sv-hosted.log
dde9300acb16ea562e6c1672ba1b3358a20425efb0afd64a3d12444d10530723  release/kernels/missrun.by_instr.json.gz
5e7a47395af4c43d35ca62c3ba00921470df15b7e38d8df99b29699581575cc1  release/kernels/missrun.by_unit.json.gz
b8eb371762b05f7890a1c8a1821bba0961af38a5db59fbcf5eaabfb132c5dc20  release/kernels/missrun.ccvtrace
0cee6d0b229cdc25d2b2e3236e9541ec99317dc4064ad892f7b3d9565487c0a4  release/kernels/missrun.log
531bdaf281e5590774bd2775427f25e4cc0419cf8e3d5b6999843ffe9ef87258  release/kernels/missrun.oracle.jsonl
58a6de7324695b2ee368b642ab9e1c7f025255d7c214b4d8e8b1a8063155d69f  release/kernels/missrun.sv-hosted.log
b57feb4a687160a74a6b61bf880014731b722105e760d0d41a43a5f9eba816ba  release/kernels/mload.by_instr.json.gz
5737645f80298bee7c54cb50b0fbf7185d032b330132e853a1df671837267a12  release/kernels/mload.by_unit.json.gz
97908ce5e7a9df5d988e06cdb58a9f10d0cdcd7e719b092502ccfd074b9228ab  release/kernels/mload.ccvtrace
aa90e9acfed3b113e9f35d6e3fe2b8430094c44bb4bb92e6fe82b3ffa30c0a40  release/kernels/mload.log
8000e477b9a95dfb9f0af964e8346acb9d36f1358fd06ffc4ff7cf599d2b8868  release/kernels/mload.oracle.jsonl
5aa46657ef675d20197f873dcbb4faa7917945d14fdcc5870fd99a215732fe21  release/kernels/mload.sv-hosted.log
071889023153736c7be00898d2a28f43e4eef8427a97349f57c7b795f080db29  release/kernels/mlp.by_instr.json.gz
9af4f31e1b7b76ed7d58f7cbede7067169b51ca502babe45b1d374e5395f1cc4  release/kernels/mlp.by_unit.json.gz
31ae54590ed11ce427715be77ad492dee5bab993e351a7b7de09dbb6123b7df7  release/kernels/mlp.ccvtrace
7077a1290445987297d6042cdf5375a0294f692c8c25564423026d2218442132  release/kernels/mlp.log
138d282f88d56c8ad648a91af0a983254b55d9fa22942c00d47b327f516a6e44  release/kernels/mlp.oracle.jsonl
85249e7c3d2c4af09594aeaf3db3be00c0182d67ceacbc072ce687c06e9d081a  release/kernels/mlp.sv-hosted.log
dd0a60ac8b8abc70723bf84aff494609d050e8e978a6e97aa30f959c092444cb  release/kernels/mwmiss.by_instr.json.gz
216c7fa0800dcdabf58630a0bba02c74794c85bf54653b13874ca5f1c9bcf0de  release/kernels/mwmiss.by_unit.json.gz
194cac222b145131d0bcee8e371334cde6ef588629e284b45917c6aa0fc6890b  release/kernels/mwmiss.ccvtrace
a61d09437e8fccb515d519111105956600bd34b8e0623f482acfa089cad5e539  release/kernels/mwmiss.log
8abe8e8997456a2a6711ee72da54d854b24e20abbdab28e4b7271c0d28418de8  release/kernels/mwmiss.oracle.jsonl
fc341167fa4c99f5a998e19b4995382b929ba30e0e65ceabb1c483560b4b72ff  release/kernels/mwmiss.sv-hosted.log
ca61980cd80eb4bfb4a5b84c04c7e74c86fcb89cea0fec48d9f8c04c2d2adcd8  release/kernels/narrowadd.by_instr.json.gz
ada1725ef1f4df8819dfaa44a8d188f6bd5b34dbb912fa3597e3f2a4ba2a3389  release/kernels/narrowadd.by_unit.json.gz
856c082ec93e6f7d5e8c0e82cce9a7d0d54c287a13629892ec5aab922f0ac02a  release/kernels/narrowadd.ccvtrace
aff869b1c1d36df372ed7d5f73969050107da3ed2d8e6f881b0348acaf3ece2b  release/kernels/narrowadd.log
40a2cf629853dd404bb06b4a07e35abde3d12efc13f26ffe28f923daf2994574  release/kernels/narrowadd.oracle.jsonl
33144ecc5efc04bf344d4cb68572f117897bb6d0a881cff7b62b6eefc37cebb7  release/kernels/narrowadd.sv-hosted.log
cdcbcd81a3fffefa43fdc9c452d3338eb72bda309b16f1f29051711b5302ce27  release/kernels/pgcross.by_instr.json.gz
9eb9b3fd8ea895ad930174fc89968a8e5505e0cefba816aa908801a348417fc5  release/kernels/pgcross.by_unit.json.gz
1075a5594ef3271367362cabe405239302b0e209c0d232029504894cde8b8086  release/kernels/pgcross.ccvtrace
8c07ccdd007d99d72f227c3fe8b96b8f5985dc9245ec662145c5dc1c19dc8ee6  release/kernels/pgcross.log
58aba9ba5ec6a72271191c0249014802cdc7e4470d27491f499a077f17ecc039  release/kernels/pgcross.oracle.jsonl
fceed55304e74a9b8ce48f3169a5a59401d9363b17293bfaa973a1aac72cee5f  release/kernels/pgcross.sv-hosted.log
ce4cf6a472abfb54b0a5864bf7bdb4e31e632bcf4fc918f2e7f018de0be47df9  release/kernels/pguard.by_instr.json.gz
2b0722c3a183ce727e080c1714ec4aa149d2c6a04cd6a0e3c321afe5730f4b06  release/kernels/pguard.by_unit.json.gz
5780c007d8d8e484e42eec3a5c12c48ba4c77684087ae6d5c756f31851aecb0c  release/kernels/pguard.ccvtrace
c3a32895844388cb8a5dc4af79462ae45de412704ef89567ae36d2a317684f85  release/kernels/pguard.log
690e56f1cb8d97cbf67124b7dff3ad0a90cb8981814cd1709cf0cd0e035b3bd9  release/kernels/pguard.oracle.jsonl
a3c568529991a715e6c660409585873cbc13b7fae668e694974cc587be78269d  release/kernels/pguard.sv-hosted.log
3fe9795900d8dcfc28d3246d47bae011d15880ee0e7e3fcb9cd1cf22a4087019  release/kernels/plog.by_instr.json.gz
a5065a26c0fa94e69cb11a23e4f30226615746b675e3d2c6b968babf249f036b  release/kernels/plog.by_unit.json.gz
387ce59a221b93134bbfe7a7174209bba6c1be72e7880075a42de6aae6e452bd  release/kernels/plog.ccvtrace
5eaa8df32fb8b4e334727d453dbb45b863c439bd3d082905b63113dd92258e9f  release/kernels/plog.log
0c99915e2da60f4670da00504a6371d7d17701d4431e733a3ff8fa98a2030d6a  release/kernels/plog.oracle.jsonl
fbb6f962191c894091bc6034bd598fef54c327817f60038c04b4e6293751e38d  release/kernels/plog.sv-hosted.log
0e0ce35231665d26209b94e440b93408419ab46482991cb71f387850d891d7cc  release/kernels/pmovdiv.by_instr.json.gz
0039345ef798a894ea8bf4ea42317659c01a505c9701cc13511dc2aff311866c  release/kernels/pmovdiv.by_unit.json.gz
e14b32efba43482905dd775905197af8a3748473c9b7a924664ec3b5a8fa00ca  release/kernels/pmovdiv.ccvtrace
f5111a4989ebcc8900e944a844cd398fb879df0e7a7eca33bec84a8638aeb1cf  release/kernels/pmovdiv.log
7bc646cff6166a51bdce03d7c1b7209e871f0a91d743083a9b910a80bcd0b33f  release/kernels/pmovdiv.oracle.jsonl
269b76f634860ab4b97d411c77a19a54628b35f2d74fca186b625600974327ab  release/kernels/pmovdiv.sv-hosted.log
dd9c1349e17e28eefdd3151997fc829c4ea53d0a8a2bad3a2f7b8c2e5e6ea2aa  release/kernels/predlane.by_instr.json.gz
60c230bbec908e2e6a97e5507f491a67486658c4ee87b4bfc48be3dbe99ab837  release/kernels/predlane.by_unit.json.gz
6125cd4c52ad4aca6219bd684c227cc5307c3a4ac7fade886528a4d29bfd1f8e  release/kernels/predlane.ccvtrace
76cb3adddcddbbc660eb9e0dbab4d89776502d6975eb9dbf6cb5ac4d02a6cbcc  release/kernels/predlane.log
c45f4177b9e84fc8a6e36b13534a0c7636eb30a3f8531847100ce5e23bf404b1  release/kernels/predlane.oracle.jsonl
8eb0055185d91311d53cff8d401550d52e25f48bf7544b53bb81ff733ae59dd8  release/kernels/predlane.sv-hosted.log
f2b86ddd3dcc64f293e86f5df88be1197598101694fba56478e28f9309dbbb40  release/kernels/predmerge.by_instr.json.gz
9537b40e2579abc476b316898d7049ddf4b27acd0e8281927947f0adce5f6e51  release/kernels/predmerge.by_unit.json.gz
d12b62f73d450c8a60520fe340f72a1d91fe544821abb08ce2129854705d4b11  release/kernels/predmerge.ccvtrace
6e67bd057e4408ba2769ba6eec6964781d78f053177df492508afbabfa9551c8  release/kernels/predmerge.log
6c737c49434bcd08e3e0814c8b1dbf15c586ae74f7929ba3148ddcee2c62c845  release/kernels/predmerge.oracle.jsonl
a6fa75ea7f89246b7693e5455a95e8587438426d9b00875b6ea08d41c37665a8  release/kernels/predmerge.sv-hosted.log
dafd126b8cfceae01accb8804f5a46bee8d912f419442f27262546be35bf94bf  release/kernels/predspill.by_instr.json.gz
4f4bb3be7c0b44eed75549f3e0141b895b35cd9df57d187ccaf0e469c2215ec6  release/kernels/predspill.by_unit.json.gz
4acb0d76476805572793da062f6710e4c560428db30adb45ddb33306f039c449  release/kernels/predspill.ccvtrace
ae0c20876547f727fb67e9cfc95c0dec7051e8b3100c572b9549cafb00483173  release/kernels/predspill.log
b7c84c6478117ffa0f06da0e6ad1e4628e2683426a7911080810e78e06a5242e  release/kernels/predspill.oracle.jsonl
4c30dad39481884b2c597d773f51aa23e3a9d9d1a4062c6706ac7f642ceb9ddc  release/kernels/predspill.sv-hosted.log
16752497f2e91bcc7f21c37af0b9c420e9ee14ff45dc77efc94094618913413a  release/kernels/predswap.by_instr.json.gz
7aaff3ee6440857e1bae1c3ecbfcf5c0c26807759a477f696700e188aa0acc48  release/kernels/predswap.by_unit.json.gz
88ff2cb8b6a348da34bc4e2f2984df9d8eff258c537100f2f51c42d8e9f31c94  release/kernels/predswap.ccvtrace
f34c67dd3c39609167174d0b8d801e49ffbb89bfc0a43c0504535b76c5fda01b  release/kernels/predswap.log
a6d4f7ed517553816d889c7c9eeb6bcfd1f6c973fbf682ecb69f3c2de619f7bb  release/kernels/predswap.oracle.jsonl
359b08119099f93ec32c08c66991d361dbb92d98cdbf209c19b327e6273acf2c  release/kernels/predswap.sv-hosted.log
80dccdd77aa5d87bb11427cc529479d0355de97c31fe0f5fd880ede456d04f39  release/kernels/privwin.by_instr.json.gz
0d7c4c5ba093ff36e0a708a776052456ea584677ade9304f396af893349b9acb  release/kernels/privwin.by_unit.json.gz
2d5ca9a18e8685cc4b204cae08205219ad84b1d53d3681103072d970f29f8f7a  release/kernels/privwin.ccvtrace
444437b6cdf024b204b108d3474195b1becc94d96ae6d1dd1ef6df7e03d21c61  release/kernels/privwin.log
861f686fc4480363472908d679d8815e8c957d768e7ab32c826930527b0fb7a8  release/kernels/privwin.oracle.jsonl
f94ad7cbaac986edaaa25c242270b06c3447ec20065274f701df8730d982cbdd  release/kernels/privwin.sv-hosted.log
707577e2f76059e49ea8d45eb25efe21582e3d7bdaaffb4faf792a43817491b6  release/kernels/provswap.by_instr.json.gz
c425b3e1fb32e759842fbc8d308be4c2a0ab41e14dceb459472a29540f850d41  release/kernels/provswap.by_unit.json.gz
088bc232abf07d6ba9a09759ecfbecf68eac57a4d0b7ed4f4618f90949e7f990  release/kernels/provswap.ccvtrace
cc9def6045b5b14888c46d01539a44c22d7224f213057242e0b36f2172d351ed  release/kernels/provswap.log
c9c32a793d54cc7401477f582487f7e8b345b2669a75337b8d6327120d98e5dc  release/kernels/provswap.oracle.jsonl
75c63fc36b9004cd3e05d1a92f08ce85b9ba8907fd2d2e68faf37f7fd5762e83  release/kernels/provswap.sv-hosted.log
fe1867ee4266ba69a4562af4602c207c76db933129064981f57413152e4a4647  release/kernels/retmiss.by_instr.json.gz
05136490dd97bb8bc56434f8b0a0b54eba5f4b620dec7315e86d36fa2f6d248b  release/kernels/retmiss.by_unit.json.gz
bfbbefd347fefcecce4c062f69411177881642da0b75e77882d3ee0581c76e73  release/kernels/retmiss.ccvtrace
46c94037ae257d4b7bf17452ee1f649da514cb81f2d8828ba5386c306bbc0df5  release/kernels/retmiss.log
e5ef8538e838c6cff7febfc679dd091cf5e002f82d34f1009b1948ce22bc3649  release/kernels/retmiss.oracle.jsonl
4bf6ed07f1e19a3df9d25e2d13755968ead09b343e9b27fe9f24fc0acbe6e932  release/kernels/retmiss.sv-hosted.log
603d34b3e2ef78fe7c2ee9caba2fa14cb6d65e9ed96577ec8788422100e509cb  release/kernels/roconst.by_instr.json
99d4752384a5073955557493bfaaf8d6c89073d0c28dfdf874716d828bad085b  release/kernels/roconst.by_unit.json
3f308625fba014120ba2ace4c66df0da328b8bb9f88284187036e935af11dcdc  release/kernels/roconst.ccvtrace
8e5c6e0a4ab361addc2605826200c307e17053895d157e1c0dc94e55b0747482  release/kernels/roconst.log
8087c0671de620162881aecd38cd6114b78e7be6bd71201e3ec02c9a2e2e750e  release/kernels/roconst.oracle.jsonl
0ac6a997c4ce8293ae7ef7feabb89a5fd121675c0361529b02daf45122701956  release/kernels/roconst.sv-hosted.log
021eba124835a32b76992f2e974ca3672b5a740356bf16a8537f2142f82cc04d  release/kernels/rogated.by_instr.json
539334a1b54e2a3e4eec21c2b7e812145b830e354b2d4f687d9a58d6e7ff4ccc  release/kernels/rogated.by_unit.json.gz
f3e4d01deb50c34072147f3b4ac9743b3f805cd081bddc5570306861f48fdbc3  release/kernels/rogated.ccvtrace
0f513c748e879791f8bb64add04b6838da25b97e6909701fe9e9eb6120db744a  release/kernels/rogated.log
7cd02bd4cceec5a044d6b4d6a80df1e68ed0ae71b0b2a953143636d5b809ea6c  release/kernels/rogated.oracle.jsonl
7e9ee41d6d90336db000774ba1f769931759f9a46833cf67f844a83405a3c268  release/kernels/rogated.sv-hosted.log
b53c4bc533222bd0ff00aad4ed13f72f7478a10aed21b79e8069af6fde34d361  release/kernels/rokill.by_instr.json.gz
be777abcc9555290834abf05fc706f78ced25da075cb80ccd8e6a6c6ac98c1c7  release/kernels/rokill.by_unit.json.gz
ff4c2934c06ed81c6d1273e91d72ebb62a6d87f228c416d1690656a5072fac04  release/kernels/rokill.ccvtrace
6d932ff7db834b8c263a3579e55990eece143437356583efbc97c150ed53833c  release/kernels/rokill.log
94efcef96af469a512d346ce61623980fe86383188eaebd55120f716db596f14  release/kernels/rokill.oracle.jsonl
ba7a98b03ca67532e384d31b0bdaea32fedccf3b27ac622e70c5a62a2af0a52a  release/kernels/rokill.sv-hosted.log
b8237e0a467f0a12dd610c48b93236a0250030f73e78682d0c4eeb1e55a76ce4  release/kernels/rokilllane.by_instr.json.gz
75153e08c52d0819a10061cdeb1187b180c60aa6b5eacc9db7a0338381ad365f  release/kernels/rokilllane.by_unit.json.gz
7549afe6896c59bb2f37fa53f994036c055fb96bf2b814ce7b70dd489f7f3cc4  release/kernels/rokilllane.ccvtrace
6deb08deeecfbe55beca74249e1fe8227206565da79932102522a53364ff8584  release/kernels/rokilllane.log
f5ca6e666eff2f44894df74a291b43b3c0e7be0a63a47d795fdefd7b22016f45  release/kernels/rokilllane.oracle.jsonl
4ae975a9f7912f4e281bc2bd47c5131baa168c5bf9cbf0d3a870a07927f83ea2  release/kernels/rokilllane.sv-hosted.log
569cff71dc56456188caca958f14a12768f3c7955945b5b4666dd0aa420f091f  release/kernels/rolaunch.by_instr.json
71c2e34031be2b753efbedd40555ead40760aef4021d4fcd4d64f65485c78962  release/kernels/rolaunch.by_unit.json
1ac753ea9ed608c9c4b4b6172ad5599c088c964fc8cb02e6ca17d9e2261a8b8c  release/kernels/rolaunch.ccvtrace
7d35f7248bf718d392723ad709639cc6dd1857bb749f474804a610f993f690b4  release/kernels/rolaunch.log
e7dad585c3e70615de04330fd03f4f282c29a005dc1732a35655fb261d51139e  release/kernels/rolaunch.oracle.jsonl
05e3f4b3f6a9c092050e51a113cdf4797570017a83e29ee2725d1001b61f43a6  release/kernels/rolaunch.sv-hosted.log
603d34b3e2ef78fe7c2ee9caba2fa14cb6d65e9ed96577ec8788422100e509cb  release/kernels/rolimit.by_instr.json
d92aa8adeb8a29fabf7e3b434e14c21423a947f08e863e13f2bdaa19587258de  release/kernels/rolimit.by_unit.json
fe3bdcdd340b4bfea2de5acc69b5e905c19abba754bcade8832f4bc9587637fd  release/kernels/rolimit.ccvtrace
6d8559621340bdd2429181131cf9e9aec8d66be8abd52c56ca41fbe3eb60de0b  release/kernels/rolimit.log
1c5bc0cb8e8b2e69505fb5a551a16d5d10c56f232b88da7a27e336ad7d962de2  release/kernels/rolimit.oracle.jsonl
b9423880723063b9d464c0844634abf81d3c2d6c8038b66c4c332594280ef974  release/kernels/rolimit.sv-hosted.log
594f9801cd71291fe26bbfb22447a2d971eeccce78f17edf6d14cbae3d4bc897  release/kernels/roload.by_instr.json.gz
2527daf03cac21c6b61a11c1b8a47688cbd19b31ff3b8f96414be477d6ed67c3  release/kernels/roload.by_unit.json.gz
daf6e410d7d2ac715ebbbbcb1e9b59b231ec34d4e160edc4d422b93676dcc296  release/kernels/roload.ccvtrace
0a9ab9ee8d660493d9a856dbbb2bbd6ac4b414903deede2be8e655481dd4ba33  release/kernels/roload.log
f7c1309cc9764769fb5803f6fd0f2f5e1eb418f2d23fbe5e17cf5f9106869fdf  release/kernels/roload.oracle.jsonl
cb9ed4d5b0673950064fa6e5f4f0f00099c742af9740eff7fdc346d72a719b06  release/kernels/roload.sv-hosted.log
49d6407c578ccab9154f50ebaf0b7bfa9f38d10e886aca5892644a5c3733d472  release/kernels/rope.by_instr.json.gz
1b35f87f0de30df76c504c488a043215491a9ed5fb11317e763da0d6b972675b  release/kernels/rope.by_unit.json.gz
05e7a6db36c3dd408f960bd4d1797ae391d5a8bd97ad85661fd17d69619631f0  release/kernels/rope.ccvtrace
cb357e6ad859ade227b4fb282f9951c1502cbde1fe14de8d7157c3aceed03a3d  release/kernels/rope.log
d55f9efae392dc8877c102c01c0810e7654b666b6ede386328108164c6cf88f3  release/kernels/rope.oracle.jsonl
be5c4bbbde79f6b3c04ee0efc27e2e146d9c2104fc10cffc5a59c0a4b8a57e04  release/kernels/rope.sv-hosted.log
d8a27046e43b9af5d828030285c6c9f2dacde12ac51643b8081537bdee68f02f  release/kernels/ropediv.by_instr.json.gz
5af3d8b39205d544b81897d536d9a3c9f440f6ef47ddbea9408b20e2a67f3986  release/kernels/ropediv.by_unit.json.gz
7f4913765afa02a393b311757c4c8ee344f32d9affc8ff7c28acf23787f3ab85  release/kernels/ropediv.ccvtrace
a4cb37bb799b7a568827da987ebb2a111f7883569514ed414ccb217768086ede  release/kernels/ropediv.log
10c0ec6ec18b7b44638c790033109198c079d07c1537bf193353ccedd00a920f  release/kernels/ropediv.oracle.jsonl
539d0196e20f1a37ce80cd27fb40d58a844c00279ddbbadf06732198279fed2a  release/kernels/ropediv.sv-hosted.log
bbfb5de3988e6d776569bc4afcbe33eeb24b98cba4be71c87df02883fee3a499  release/kernels/sel.by_instr.json.gz
a31edf710a6e0a12b56d2950b0db209c499a13e68fbe8050f2fa4276f7db5955  release/kernels/sel.by_unit.json.gz
dd647e12092a643c2a1460c40c481fdb05157296e3be93c0685190fc57d0cd35  release/kernels/sel.ccvtrace
0abc74b8857b58f092ccbf88b09537c3dce7dea2ea1fc596b7e83c5bc4358b71  release/kernels/sel.log
87f6a81e8afa004c8039bf2f61c90176fcf29ab29bb17ac44aa016a5cc8438fe  release/kernels/sel.oracle.jsonl
ed41485a833c0f0312268baefad566e8f8e0f5b83498ec3f8f8f79efb448b20f  release/kernels/sel.sv-hosted.log
d8747363a08da4958ab5d7396487e67c422ec5dcfa398e75be3704470cf1ed89  release/kernels/sized.by_instr.json.gz
aa7ac3e8db4ae0ac74c7db057bc02e7fbf633d563e70073f1fe3795d0ea9eba7  release/kernels/sized.by_unit.json.gz
bfe021e6fcb2def44b0664d1f590c6248056730c0d50adbff63cb285e95a2bcd  release/kernels/sized.ccvtrace
a0c6604c85a291d13dcf2492f30dbadcf5d4ebe1aaea96fc93609ca71eff1a28  release/kernels/sized.log
36d903ba1618bd1faa437c9812a6ee6c0c966a63196c796267d74bf2695ebc3d  release/kernels/sized.oracle.jsonl
b827be54d34be8b5a7e573b7c3c6401b906c916ac9c8108d420b600658f56f9e  release/kernels/sized.sv-hosted.log
284c01091a69d68bd459a4b674c47883084199a73a10672450f88ba314ea7df2  release/kernels/slotform.by_instr.json.gz
3d28b2bc2425e687cd53b6ade8b63ec9bb655c814869e4fd7ec2392fa4d2f9ff  release/kernels/slotform.by_unit.json.gz
3083add05cf1feff14db90d23aa30358f6222d090978cd1311e6aa9c9da213bc  release/kernels/slotform.ccvtrace
92485bcca80e735783fcb105c952c44fde7cc76464e8eaa21532b3189270e1e1  release/kernels/slotform.log
8b61db7419b18cea8a646fb628218447e72e84a18a9891ffb73b441736138ab9  release/kernels/slotform.oracle.jsonl
578589c040206c9542e1c01b599753e82939e886ef80bc56149852e2a0952f84  release/kernels/slotform.sv-hosted.log
65507a922c561e9530d23e46c6d8fb24e5b2ac1848ca2a2f93ed96d0ed268d68  release/kernels/spinwait.by_instr.json.gz
779b6d7b069736f1b17450c946bda5e4341e8dc94583d749ac164af947a5887f  release/kernels/spinwait.by_unit.json.gz
e1e6e79e8abe3c1cd8ab1b7a3082edbb235b9e5f5b8de9f967ea5c8bd9514fdd  release/kernels/spinwait.ccvtrace
2c9708b298bf666ab7834ff6db2d329de77d487851cc680e728f6db6e9ade457  release/kernels/spinwait.log
868920637236c878b33779bd450439466fc3626996a3164573dc11d437d5c709  release/kernels/spinwait.oracle.jsonl
c690db82804329bed23820e046ed6994dda1adce8527acaffa9a6ef1748713b5  release/kernels/spinwait.sv-hosted.log
4a0af4706dc74992a368e66fb4bab64842bfa15e71d07a90b409b6305d190086  release/kernels/spmbank.by_instr.json.gz
d4a2cf2dac1cddcde5b6c9828a50a6bd5425532914d568ed3b105babaadbdaa5  release/kernels/spmbank.by_unit.json.gz
07b1ee79a22697f03f52c66f26d006d2beff88468d0c195ed2e3ec245ebc3c51  release/kernels/spmbank.ccvtrace
d74dc6882a1c991cad404a516aec6ac019cad26a0f582a802b5c338cbdc22f1d  release/kernels/spmbank.log
3af490cc37d7a92dbe719b57de216b648536eb301ff9d13de9a39f50d150d725  release/kernels/spmbank.oracle.jsonl
7021dd7e0b71cb18868ba7f6c9105185fca1c0608f3d845432f7d9c2ee97b6f2  release/kernels/spmbank.sv-hosted.log
1c92a65ece1dee84210d6810e06265e4c3aed1dfdd497eface4e4a75cd299c5a  release/kernels/srd.by_instr.json.gz
da286847e6e3f12e4bc211bfbe4e183dffef087c25da44e5690625059c9f9a6b  release/kernels/srd.by_unit.json.gz
d61e4dfb34de07aed8e08cfc3fa64c6da1e9c6d0184e8d7953dca6fee93258f8  release/kernels/srd.ccvtrace
3dac8c1caa29d971be728f8551a1b0fff1fb13dd900af7e8448a0a91512eb058  release/kernels/srd.log
b08eb5e3673cac7eebb8b72af5ed3783c8e70a9e96592e76bf3722551bc79473  release/kernels/srd.oracle.jsonl
114d88b0dd1ebb63e78402b74fd9e8b2f0c0d715b78346c3c916d45dcc17b6ff  release/kernels/srd.sv-hosted.log
cce2753adc20b214cbcf117c8d6baa2ecb20823383d58734b087f6120e844972  release/kernels/stall.by_instr.json.gz
2d950b777f6f521c9d60e2b1bec5e5ac8e286407802de6e47c74ef44b6706a6a  release/kernels/stall.by_unit.json.gz
eb115d257b0d6e1f4a9f3feaeed1392031fab7d9c846825d321f87bf295c5129  release/kernels/stall.ccvtrace
d81cdedb6b5413388e0b9d127ef349f4543b0c2538a78f173675ffee81cedff8  release/kernels/stall.log
500db2c482b07a0706583422cd68878301d0146c1f872ccc1f11bfdcf5c993ef  release/kernels/stall.oracle.jsonl
59faf5dee53bace82daef62f8759aa35abcb24ff18b34ba289e20056e48993e1  release/kernels/stall.sv-hosted.log
7bead3c05990574fedff3e437673c17244254bb31807942aef8739b4b98bfec0  release/kernels/swap.by_instr.json.gz
d69ebf042ae8fc3f1f29e2a02bbe4a39fd91930d12e0c18c7f98b8e94f9ecf2c  release/kernels/swap.by_unit.json.gz
78358f37b30e6a964b01ed202048cf739786bf167ccad8185d2291f18edf25fa  release/kernels/swap.ccvtrace
171e889c4b2165efdeb24c863b5287b261f9e0131a97a2c754268129204ffce3  release/kernels/swap.log
3658a26316c1ff7bc1744304a42f736e930fcde2865c8913e6cc67a22ce96667  release/kernels/swap.oracle.jsonl
161fa560580e100adb3eacbd58c03af902802e301be4db03e89cbe7ed3dcc675  release/kernels/swap.sv-hosted.log
2c1907a80594d2ec8f5aa59abcde2cf1b5e908cd4b3acd19f86581cc28de9ec7  release/kernels/transp4.by_instr.json.gz
beb016e9abb0119644efc131db4effaa90c13ad8ce4f2633ce5d518453d3aaaa  release/kernels/transp4.by_unit.json.gz
ea582cf8bd5c73f7124e759d9d926fab43df18ec1d81300be7657119e501eeea  release/kernels/transp4.ccvtrace
c9fb608c4e4617468d6efa91af79307adf5fd697a642a0ec4969b54b84b78773  release/kernels/transp4.log
06396ace3ac19677fd39c700e408606e5bdbacb24997d663bbe8872e63dd74fc  release/kernels/transp4.oracle.jsonl
d403a8c72eb20e1eda12246c24720977a971514a05d427c1737543a31ff1a9f4  release/kernels/transp4.sv-hosted.log
ed18142ba294a4b6c2b692912c8c35b7d9f6cd3ab159e7359e190f5f83cb4953  release/kernels/unal.by_instr.json.gz
99ab63082d9490295d8377565f152b49bbb1faceb89f7ebcb5757fdcced17dd0  release/kernels/unal.by_unit.json.gz
27b99c99f163c010c426be84bef96cb51e5fa6b552aa3760d004decf550e09ea  release/kernels/unal.ccvtrace
51b9b6a1b88b1ea2acf9139fd128660aa81be8de190ec7753a82d203f7a5288f  release/kernels/unal.log
c3d484bb160657a563df983d9a2532eac27f556636617960aa1e72183ac2b299  release/kernels/unal.oracle.jsonl
cd19c9201b454a50d73f98a6042a13d9a3b919ebf5b1059aec0a19c27f9ac898  release/kernels/unal.sv-hosted.log
f2d744f3f31d6aa98f5b0aa64d2b1315f1b143ca1817d8188b61bf27bdba718f  release/kernels/vadd.by_instr.json.gz
c2df7e3ec62e5b5f1a6173660fac2edffdec1a988cb32b642dc45cf95c67f1ac  release/kernels/vadd.by_unit.json.gz
4b3f52dc9ed3b500b0b1ecca9758ca70de54df2df1d71ac14aa11787001a4654  release/kernels/vadd.ccvtrace
422e86936e03a36fa059f3559750fc2c039f5f32e71710a3372eef0748f8a8ad  release/kernels/vadd.log
0276b6d0611a4bbcdc004ab3987214aea138245bc7217504147331689a9c0880  release/kernels/vadd.oracle.jsonl
c80fc90f004d52d5bc4a2617d24ed96d1a4b91d0c35deceec989aed581e1e231  release/kernels/vadd.sv-hosted.log
f2ba5f99d12734cf90bcfa96810d5832999b1dbe969e085e7f1f35201ae2ef81  release/kernels/vadd4.by_instr.json.gz
d13f65fd8ad079ca1099158552ca48d1750653b6744ff74641e1124aadd7a5b5  release/kernels/vadd4.by_unit.json.gz
c45922d8a62b46d0193991e7eb78a7f057de7d2936f01a6052da2f43b0b5dd96  release/kernels/vadd4.ccvtrace
9f810f39bd07a9bc92b582fa1160693e48ce89a5688b7c2697eab7b3befcf7f8  release/kernels/vadd4.log
225aa18fc9f38aa9ad615aa11de254337d59fa705877553d873062c68366e0db  release/kernels/vadd4.oracle.jsonl
601475015d1052e421b1d9b4b5115f8c1f42f2d0885dec7ddfe42fca637ff9f6  release/kernels/vadd4.sv-hosted.log
e0778a4b109c3fc193bd1bd8502805858cd37f5fe9210f0b586c77c3861b6593  release/kernels/vadd6.by_instr.json.gz
afdda5d51aae4d46f67389ca47a4f0987674850c108dd1be74f9670e88461fff  release/kernels/vadd6.by_unit.json.gz
316afa3c985ecc510e40cebb3ea0bda78d207774fa0706a38d7e476098bc4f96  release/kernels/vadd6.ccvtrace
a99fe8d6e40c600dd9983d3727bc7e8fcb1fc18517e4a346a532b26ff2170400  release/kernels/vadd6.log
10335385a8b6359c5e8310565561a4a5febfe318ef4ea0a6e537be2d372c54f4  release/kernels/vadd6.oracle.jsonl
daa0e305a04ecf72fe9f4b89af77e7009e7232dd071745caaedddf8c3224e5fd  release/kernels/vadd6.sv-hosted.log
3a9a261d5ea3b0c6f084a098acb13f7f3f9da1a15fb1276e9814e783ff4d3ca7  release/kernels/vaddslow.by_instr.json.gz
1653f16d0889f4815e341c737b7ff1439341db2c6c2947690053b48bcc03911e  release/kernels/vaddslow.by_unit.json.gz
56e31060ffadebaac83b1bad04def18f7d68e31fbbb3d6472b00895f258ae40a  release/kernels/vaddslow.ccvtrace
9088da6be14fd4536bf0a79504e33753941f1d80cc21b3c41899547e5e7bed1e  release/kernels/vaddslow.log
e9e6218e8b8450e9f9ff6b39d659c994a1e51c527a0c5bd10d18b5658ae0e344  release/kernels/vaddslow.oracle.jsonl
371e4317c4ca041c9c8352fbea7a8bc24dc060885f789a4f37bd2abe26b7f7d5  release/kernels/vaddslow.sv-hosted.log
9a72defbb06f143058a8fb9f38cb5aa3ca302d623f3a5b522b0e59607721fccd  release/kernels/waypred.by_instr.json.gz
e05ec24c7922c0d069d9640d34bb53edf7a64ddf98094db2ae298104aa26fa0e  release/kernels/waypred.by_unit.json.gz
4bb4d9a54642ae3c60c9286bc24a3e1a9bbddc5c80a73703715c834d9f953507  release/kernels/waypred.ccvtrace
ed871c9de1bb0dafe72b053aca952b4dc71452a519eab3b1b3365854f4f47b6a  release/kernels/waypred.log
54fb803ce85c4458b8687bb0f61adc32a9d798448b914b06261dc49c2bb841c8  release/kernels/waypred.oracle.jsonl
129710c62f43e5e62b31ce7094e3c0f37136e6355c5ee025673bf305cddb5611  release/kernels/waypred.sv-hosted.log
5efdc1b439cacff39f3ac37c5982ace495c0d5e90333f21d0920b9348eb3147a  release/verify.log
f78197fa73514d4391564b6dbfda61c3c03a38e2134c9ddc2d24180f29c72e6c  release/wiring.txt
```
