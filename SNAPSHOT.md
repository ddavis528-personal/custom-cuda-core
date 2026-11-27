# Snapshot snapshot-2026-11-26-a1decc2

**A generated, read-only snapshot. Do not edit or merge it.** The source
is `ti-pt` at `a1decc2e3917cb59793f6401a11fd5ef4c657ae5`, and this branch is rebuilt from source by
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
| Source | `ti-pt` @ `a1decc2e3917cb59793f6401a11fd5ef4c657ae5` |
| Built | 2026-11-26 (UTC) |
| Gate | `tools/verify.sh`: RESUMED PASS (26 of 28 sections carried over from an earlier run of this commit and tree) |
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
7467694d3e6b33f79e698a2b08cf1988617c47798101e9e922cde26893cb01f7  release/kernels/addrhigh.by_instr.json.gz
ced85e53febb8ad38d07e17ff32236d495b7ba79432390c73ce2714ba9e19d7b  release/kernels/addrhigh.by_unit.json.gz
0ae129059e1e1ae3384c7c2e0b9bc7670fe0ad34be0a50dd748e64cb6ab75ff6  release/kernels/addrhigh.ccvtrace
8c262aabc8513395c961334a556b06e348c621684229fc08f8fc027aa6c8763d  release/kernels/addrhigh.log
569f2e22883fad5f0956c57ec734e6afbdd4b8a854e50277425172d6c0cbd766  release/kernels/addrhigh.oracle.jsonl
01ec6f7cbb103ac4879fb9b09301a53505dec5936bdd35718cd5c3e792e8a6c2  release/kernels/addrhigh.sv-hosted.log
46e943fcc54042aff9d156b39c48d4dc672c81facd9260e1237a66724927d6de  release/kernels/addrlimit.by_instr.json
864c0bc2a4ce482185348edf40591cce307269ee6abec293214daa584e215cf8  release/kernels/addrlimit.by_unit.json
19b1970a7f3795df488b793d1a599220bf1dd8c1c60568808fdb454cff60a92e  release/kernels/addrlimit.ccvtrace
04cd9bd6f29f252da5ad16964569447f02c30125978d852c4709ae3e9f9b978a  release/kernels/addrlimit.log
bc660b0b40359a2c5a2478cb0eb4950b73fd22db50ea76b80052bc195a1920f4  release/kernels/addrlimit.oracle.jsonl
3b59686e5f9f0f762d66aa48093f8b496d8bb2820926ba8adb20303c6e120467  release/kernels/addrlimit.sv-hosted.log
8f8665b3cf94aaf6918e5964b8f1bc44148ae152f2625b935089fa1113668fd6  release/kernels/addrneg.by_instr.json
975b65c4c5ea12e08806297d6711732055909e6f142cc19f2771648c1a1402cf  release/kernels/addrneg.by_unit.json
ca95f5bc9b5a38c9a4b55584b40ef866d0bae9847d1c737b9650508222652023  release/kernels/addrneg.ccvtrace
aa71be9c5be05797bccec2d532ec995965b666f5b35390a91a4a031c83da964f  release/kernels/addrneg.log
16f5b0707ae44492a1efd67bb9dd38a7e79a7bbd354fa9207b9e7d150ff2f107  release/kernels/addrneg.oracle.jsonl
015eb703b981411196c64371da93180a7ea2f71c3a7719eb4f85bd64ac06c543  release/kernels/addrneg.sv-hosted.log
079fd68cea30304f226c7f1256ebb5e843c322583ea32588c31694f88b9d98a4  release/kernels/atom.by_instr.json.gz
0af2df97f49370a7e1e52380cea19aa89f700f04dc0f96d76688faafefc4bdf7  release/kernels/atom.by_unit.json.gz
797d54335b19f17db40cb50700fd6d672483c20c399983d17b7c22ed41852d07  release/kernels/atom.ccvtrace
2bd6535582e3abd3439cd60172d98616640734337f207f1030885d7ea49cf5aa  release/kernels/atom.log
504f5b6e9d25114dc35f2c70b21bb7b3f3c508c691de12dc0e87d12a74285361  release/kernels/atom.oracle.jsonl
b22ca61daed21b74c9e84887f41911d8d464181440fe0cc513cfb9dd0ae0aa7b  release/kernels/atom.sv-hosted.log
8c058d20a612b26ac880021dfc6946c062833c3aa191f5fb459aaa2db07da05b  release/kernels/atomf.by_instr.json.gz
9afa4f68c3e2f63bd24ebc0e3cd8fb5d18676118ad23375be0eb483223f03cb0  release/kernels/atomf.by_unit.json.gz
e888bba046e29bba2f2b00119d3ab01329aabf2cb41340122aafe2800a113d80  release/kernels/atomf.ccvtrace
d081e212795172a533425bd1c5fe9bbd6378a0b58ce16d803871b467018a95ca  release/kernels/atomf.log
cfd1179edf4061a33ab2f75d7a6dec61decfe629000198189a7bfc2647b34238  release/kernels/atomf.oracle.jsonl
5f9531c20e96be20e3e0a31d20d94d957c74cc83164970ef2341d26b1c93e4c5  release/kernels/atomf.sv-hosted.log
6c0e7346a32e8b3cd58fbe2191c801d3f524e083098f5674c78fc658d3241d2c  release/kernels/borrow.by_instr.json.gz
be4826ee726b6f8a987460b497be92f0fd0180953e1669d937081fde5a36131f  release/kernels/borrow.by_unit.json.gz
3edfd61a186bfa758b8d04dbd80df2e8d512e395a967fa9e17b90d21ebd652f1  release/kernels/borrow.ccvtrace
4a30435ce7a742f82fb025f57f8683b4f31ba1d9ebcf60f1010ee961715b7c50  release/kernels/borrow.log
4c565e1ce0b3baee36e158694b32c8defb5cd662b2f9af75cb5d8c26cb1168ed  release/kernels/borrow.oracle.jsonl
92ecbefd037592a92bb970590c2d539150fa3ae7cdd4be5184f7bf5f3e40ff6f  release/kernels/borrow.sv-hosted.log
907a672577fb770adfcc3224caa7f5af330761a1ba88248e44fba41ecd704f6c  release/kernels/brs.by_instr.json.gz
678feae194d9737c765f929da2f6c543d8c8cc94d506977b8eb78cac678a4bfb  release/kernels/brs.by_unit.json.gz
f1cd4f404850590aca4cdeda4f3362acf51fcb3969eda45616f8b51e5d389ad9  release/kernels/brs.ccvtrace
598ef73541fe01f4ba9e70f9bfbf9983f9ef61c3167cabd97bafb7a2168ef3d3  release/kernels/brs.log
e3c1cb3379580cf1aae44e8ddc8e846ef6fd661a573cfe0a8d4444b18a14dc56  release/kernels/brs.oracle.jsonl
e36e1c9daf0bf332f7abc8706faeae9c60f3c0fdf67b149979ccf5a0f9d8bc17  release/kernels/brs.sv-hosted.log
b4c4ae4820e8de50acc1c9479057c74941f0ab7c35676b575834118e76f4dc43  release/kernels/byp.by_instr.json.gz
1b6045225730c351b38ad9b3659fceec004c9a7c3509d86055f60f4cc4b256f2  release/kernels/byp.by_unit.json.gz
fad2fdb3804beaee0f9a3984ab23cb8e81c4be12cc2783cf9bc6af282f63d32d  release/kernels/byp.ccvtrace
f3569396ba05620d4bd418fa05de2598a51e3677f576038e2587425fbb6faf97  release/kernels/byp.log
5a03dfa4f3603fef49f1e3639e74e34152ca3ca5ef8e41eb959f8323040fa2d5  release/kernels/byp.oracle.jsonl
534eda7fddd773c20d4d6269adf5534304ad2281940115822c85bcf5d5c2852f  release/kernels/byp.sv-hosted.log
683a64fdbe2a8f4c6ac677c3d60a9ce2ac875f66a09b7ff7aee79c201afbc600  release/kernels/callret.by_instr.json.gz
3dc42bb901a42e4cfab65adff74d5db6efaee38800205e55f5a3178e5d371706  release/kernels/callret.by_unit.json.gz
37b60e82e7a301b0a6c3f86cd9a97f14a1ea8fbe6bb6dffc95a5a3ebafd9aaae  release/kernels/callret.ccvtrace
0a7a0e0bdbaec0105323b92f1d67382c1f446d0c286bdf08e0360a68a7ea759e  release/kernels/callret.log
9b1d1b50b527f732362f837250aa2f26dabf3e76e16a4794856ebd8f105635b8  release/kernels/callret.oracle.jsonl
4ff6dcb158890232735af0cd02994ec50ad8432b6731d76f1d688fedd5e39317  release/kernels/callret.sv-hosted.log
168a9050744946c9238cfa16a113d3b7158b21d508be2d82ed0012a300e05fb7  release/kernels/cas.by_instr.json.gz
0bf0d4fcab7787db28482cf2b913384383ac484bacedc7d28429de08fde76193  release/kernels/cas.by_unit.json.gz
dc49d8fdd26dda21990042ef6d02dbb92fd98683141d71e1ae9883237213c069  release/kernels/cas.ccvtrace
526e4e0b4d677a9d63dd20ac839f85c4f909860805d3e0396d6f58551aeb5266  release/kernels/cas.log
0ab31a9443336fe5d08e1a5fa5fcba3bc279b19022f7c5007908d39d8ef39536  release/kernels/cas.oracle.jsonl
63fd25563e958de0cd128aaa32b1bdcc7a02109f0b1384ecad3b549fd70eaa2f  release/kernels/cas.sv-hosted.log
29a88e70729379c8912684fb99072cada6feb07c2344fb3111c80ab68be4da6f  release/kernels/chains.by_instr.json.gz
1eadd56bf81697868524ebbc1675d5858d6d7d9442f210990de3264b1c3c40ac  release/kernels/chains.by_unit.json.gz
520637b4ca14de3ff66718fb9e68e41134e5c456612cab51f14ccb69a9802fe4  release/kernels/chains.ccvtrace
311e2e8b478ec08d04a3a37a374e07c1babbd5dab3ac8b3898f5f402ca912e43  release/kernels/chains.log
26a4cc5c5524c7219d8706c2582c80357dea60be9d6ffdec99dac7d0365e2264  release/kernels/chains.oracle.jsonl
84218e164dedfd03e7414c775134e348b067f2687804f818fc7982ad6a0a0cef  release/kernels/chains.sv-hosted.log
93b915f8eba4ca382c960c367f1ac67cc8488479d8255368b28e34d008ce032c  release/kernels/coll.by_instr.json.gz
eb6ad40b2787ca0064c1a64be707debda4c1f00934865ae5eb83b20b6c0630dd  release/kernels/coll.by_unit.json.gz
c8395342e50fa1411fc9e1cc08847942c35034a98673257a52395cff9506bcf9  release/kernels/coll.ccvtrace
1f94e8e915b618b415d9a23239f0f437032625e84841192264411dd14c061e66  release/kernels/coll.log
dd718d23c88df5dc7d92b055d8542865aa0e029118486af127312a8a578cfcbc  release/kernels/coll.oracle.jsonl
bf52da65d21e7cc52d04bc4c6f42f274fc46ebaa6a90ebe657ccd240d4beadc9  release/kernels/coll.sv-hosted.log
1efdb20868ff4e8aab26896f03ff0ff853aa28016676a095c7b36fe88599bab3  release/kernels/div.by_instr.json.gz
36b6ffe958a3767a53fa635286c6421fce0f9aa54ed36d4f4eef3a03ba9a5dae  release/kernels/div.by_unit.json.gz
52e372c9ab8b2e93a93d6b8b73ef6adde36081b43590718a75ba1e162d334db1  release/kernels/div.ccvtrace
31709da17f31b5ebe42649ff0c90395209169a4922d52ead0f28102adead6fbd  release/kernels/div.log
71a567b85cf85622631490187563de9a5661099c78a590adff4ed0a0c3d24c16  release/kernels/div.oracle.jsonl
e4ad3f8b7f641ad0b8e3dc0b3af5350a9f6cad4c2a6dad15ae398e1d0441f1b8  release/kernels/div.sv-hosted.log
a4e24922caf22d3f282fbd82f4cca9348b60ddac1a7b08ae755f6dd729163088  release/kernels/divchw.by_instr.json.gz
b6ec53caaf1179be3a0e084cabaa5d3eefcc9c30df3dc65aa55d7437d428dd36  release/kernels/divchw.by_unit.json.gz
4fe974515ba66dc40ad4876bcbfe310a78b48f2e1715facd3ac51aa321f0ffcd  release/kernels/divchw.ccvtrace
a45208754439400a23ee1cf29a342307e4dae92a25807f27ac3a4664ff0e6fab  release/kernels/divchw.log
58a541797f7a2df0a1c7528ae6a3edec212db90c7d3eb20656806f38b5c10b3d  release/kernels/divchw.oracle.jsonl
0db55919f0fd1a56c5f0e45c4471f6e089a41b88c3884376a61ac704cc190969  release/kernels/divchw.sv-hosted.log
f95c058c9eb30662cb9cf5bb4bde404594f0589743df29b3390196fbffbd7847  release/kernels/divtail.by_instr.json.gz
d5cf8f37c09d6172df4c4b4cd1cc21badb25b7f1368d64cb741e267ad7f8029a  release/kernels/divtail.by_unit.json.gz
cf8e154b191e828aaa771e84f4787f75466454fa0f1cad6d3ee7d831fdfef587  release/kernels/divtail.ccvtrace
7d253f91f1224853d1b8b6dfb1cef3ca37f03a08b67daaeeca69023e8240cf6c  release/kernels/divtail.log
75f11a75c9b3b336e446140af4579f05b46c363a76b7aab3ec88154a07ba097d  release/kernels/divtail.oracle.jsonl
35fe4da43c45e362bbb813ba51ff020c112233bb460ee31eea3f5b2e39e32aa1  release/kernels/divtail.sv-hosted.log
f353d3f3e43bb9d573b4977b199e701b489bee8725f23818cb9750f15e57d527  release/kernels/divtail2.by_instr.json.gz
af40ffab701a2bb3910bfb7788fbd6aed488b996c4d23518c763a0a442ea2d29  release/kernels/divtail2.by_unit.json.gz
1e64902dfd7a748b57e0d7a68abea026230d563174bc2359f04a17cf0e6b3b2c  release/kernels/divtail2.ccvtrace
eec17c438b8b0d8b735c00f1edf22ff8736bc598f864aac36d8fec64c38bc493  release/kernels/divtail2.log
b2db6b05eb6cf4a0a7677e31d0c6c2952d5cab49d353f0bb1883fe0b2a20ed14  release/kernels/divtail2.oracle.jsonl
ae7068fdd92eff416a60c2b65c1498595bce3c8be9921aac3b1d5473b4e69478  release/kernels/divtail2.sv-hosted.log
02cc7b9017a9108c4f50a2efb8772277ef6bbdfe914b0ec4767ba8b4e8a4fafb  release/kernels/fence.by_instr.json
f23efa6b98665a529dd335e176d81fe8aad33719916857709783cfc99324e297  release/kernels/fence.by_unit.json.gz
7aeae6eaa496be2c18ce66c0c4e75f0d442864563007944997342ab51e0f9764  release/kernels/fence.ccvtrace
e144761a64683d25e879eacacdf2493cdb24fa9366d98a571dcc4f03b56d82ce  release/kernels/fence.log
d1d40317f6cf5bfb430cda1f9c0ef676609e59cabe2a11623c42ffbeca93142b  release/kernels/fence.oracle.jsonl
9168c67ee1e6db956171853d90f02308c6471ef2f22787504f5b1ceb70740ed7  release/kernels/fence.sv-hosted.log
4122a241278f4090fb77981bb361f1c38425d0d07dd13d8e555db7646421b04e  release/kernels/gather.by_instr.json.gz
a7feddd6780374656f51b5be286c7f7cc139a747badb2e06c37915af5191f72b  release/kernels/gather.by_unit.json.gz
ee8f96b252913bf6f7d93969004dc5223a2e0e5e70c5e7cd7a0bc3b359222112  release/kernels/gather.ccvtrace
20fa50e271361eb584e85c1ec0984539e8595853efa16e15388b69e6dacf7647  release/kernels/gather.log
0413e781d8d6ff578c64eb1f800b7931e66f676d5cdabb97b94a4033e6037662  release/kernels/gather.oracle.jsonl
9a3428bfc9a9c217c3dc53c4c04f816d281009a0117e15bbbf2317a3f323dbaa  release/kernels/gather.sv-hosted.log
b47f3581ac6ef0d941b6d9a2e478e5f9e52fb6935631617ccbca789cff40fa53  release/kernels/hit.by_instr.json.gz
73cbcc47103acb8a033385025be9df1fc86c2c8cccaddb3e1ed90e093f418e46  release/kernels/hit.by_unit.json.gz
735e3e4b754041adf2cd9f7921a12e2d206beebe8746fd451a0488eeec7081f0  release/kernels/hit.ccvtrace
08d22357f2f434ac4b4a4629ba9e545fbfa3a96d4fc8dd9ceae3f8289b315424  release/kernels/hit.log
7ba9603e0088d9164de6528f16ef6a7fa9ce5821c8c12b52cbb3734e39b9fd52  release/kernels/hit.oracle.jsonl
3462b714e476f4eaa00ef881908b8f3634f1c96bfb29b4c9ecfc59750e2bfa31  release/kernels/hit.sv-hosted.log
d74670f2626885a88c363799b03733dc99d77d2c03d03f997152913d220d7250  release/kernels/lanectx.by_instr.json.gz
fd9bb7bb05aea5d50af66dedc39276e52721bd93b08848979b44d2739172f5dd  release/kernels/lanectx.by_unit.json.gz
278282dd369c754555c55fedda1cbb6ba7503aa6db3cd38871efe993aa103826  release/kernels/lanectx.ccvtrace
0421102336d42de90a83fba8e5cd92bb3552a0789c4a23f7887af04cbc9f50b8  release/kernels/lanectx.log
888551babf540db8e3025b82e65ca655013f93eba3c8a65689d069d52a7e6039  release/kernels/lanectx.oracle.jsonl
b51e81ed086cba8f04f433404f2d50b9e12e7d431c2d0f620dd03e194535cef5  release/kernels/lanectx.sv-hosted.log
4e32ad25d4375ead548b1cc2097519b0f79690a0f2fc9d42dca7a13716c8fcdf  release/kernels/lanectx2.by_instr.json.gz
8f0670220bf653fd1fecaeed350236c34f0366db35f920456d96b32d538b527b  release/kernels/lanectx2.by_unit.json.gz
c78e8ffee4b615eae44985891233d95ec9b39e5ebedec165568495ed4a060ef8  release/kernels/lanectx2.ccvtrace
95da530e422219e6ca8deb8f1e946eacc657156d7f1f33c515b96f6ad12e5cfa  release/kernels/lanectx2.log
45c13056dff5c73ed0c9ece56cc36f929bf335322193c7d5eb38710b1d1dfb02  release/kernels/lanectx2.oracle.jsonl
7a821e26089c2fb72eb8527d1d98a7899efa804dba010b63ed0badc831d1b5d4  release/kernels/lanectx2.sv-hosted.log
fd584396c806356e09a94994989fa4db9809d2d78cd816c54c0ca079fad1d769  release/kernels/late.by_instr.json.gz
6f6c40622a081e784309d20257d3b2c80f5004b4a6fb39e108d5b5ddb21c4a52  release/kernels/late.by_unit.json.gz
89990f4c312f36e9af525b1140216180961d28754e12c0a447be546f40bcd4ff  release/kernels/late.ccvtrace
35af91c8773d23b2f2c3a12ffca2fe028b38bf48ca664a0b4905d9cd209a0eca  release/kernels/late.log
86084f6bd747a2cf32acbc0ebd96ebd3e4ef2d8d9e21be49e3ae49290d7927f3  release/kernels/late.oracle.jsonl
61b73287c212d9f8e6bc1a894f22b211f915fed2a135ccf42d22615c25ffc5f7  release/kernels/late.sv-hosted.log
675c4939c94f83bb9b3bc3c1e438918082d5075d1cee25a5b9168f40be30b17b  release/kernels/ldpar.by_instr.json.gz
fa1d5d4cd52811f7862ae3d8ca0aae9cd67c0986222f29be09d6361f51db54aa  release/kernels/ldpar.by_unit.json.gz
d35f767b3b3643e898b79093465396b17ecb6beda48259913f4f688ae038b6e8  release/kernels/ldpar.ccvtrace
ca4a07aaaaa02a2ceac72fb1016d90fc3728ea949690c97c9d18586a08459ec7  release/kernels/ldpar.log
8ac08538e9c807637babd61b31e340f7461878ada31f0c0b83cd66331cfaf486  release/kernels/ldpar.oracle.jsonl
37508dccd591f224599ad39428251f9b0fc192b851a61fd898c0c975f8852925  release/kernels/ldpar.sv-hosted.log
a137e05259213da231c38e73f53e7ae6e686f00fb8e47d13b2492b600b6bdd5d  release/kernels/lnorm1.by_instr.json.gz
5ea5bcc49043cfbd0ae619590c8365525376828d3df4d8b9ece36dc3da6b08cd  release/kernels/lnorm1.by_unit.json.gz
a51891466de3d6adeaae5eec5f07bb203809aa7440c03ed92f0e5f1a09649c44  release/kernels/lnorm1.ccvtrace
d06e7b79eaee21fd5d9458744103a9afb841260640490fab1d3f0df3c9924df0  release/kernels/lnorm1.log
a8d85811af988a1b9fc00db1517300af3d93ec8e589e403d3b9113fa9e0ffc86  release/kernels/lnorm1.oracle.jsonl
2d0964dec567efad466924c1a68334a0b0f63da1a659d1e98c43d9997a8ae7ae  release/kernels/lnorm1.sv-hosted.log
3aee0b0d7c172683307b4272daa80e40026fffe374a5f3dd10a928c686f39471  release/kernels/localsp.by_instr.json.gz
c6170a0b870e73e867c854f3057f026f88a4dd6fe1c99a85517ca4f9bb26d4f9  release/kernels/localsp.by_unit.json.gz
a48e944351c17396abfbaaba34cd7f467a7e01f97c99286f88e39b0a5692b7a9  release/kernels/localsp.ccvtrace
78540e7ebce3cbe543e8953b43634cf1e936805cef5b3ec536cdf9a371202241  release/kernels/localsp.log
55e3c9f36e7f7d38c0ddd38903aff4bb4509ae862015c592e6b937ea258042ca  release/kernels/localsp.oracle.jsonl
3f04c4fce2b2a5cb6f4944ba1b0ea34f551c7684cb96638aa8dde9fd2be494fc  release/kernels/localsp.sv-hosted.log
fc6ec03abcd84ff88f42e6d6f1ec1c82298212e537ae9c036c91104d8d3a299c  release/kernels/loop.by_instr.json.gz
48c738f4631cc6c0d87e38e04b77a9e95ca4b4e29126bc1ced008765f4f86737  release/kernels/loop.by_unit.json.gz
4282db3ef7e25eed678da3a1764b3297bf604de603f2c8b22fbba04e39ba0376  release/kernels/loop.ccvtrace
81034ddc9c8385dd21e4df63ac3c7eceeaf3ec10f44230b6211a4685c313b9a4  release/kernels/loop.log
03ce5920c06c93e93516d8e53c3f7169f14e3593de204eacceffc0b8a3e32016  release/kernels/loop.oracle.jsonl
30dc930598102cebaa5e28a7e11e8a2173db197763f588bf6a442b74c598144e  release/kernels/loop.sv-hosted.log
8812b3b8d0ba7299e72869e5ad81c2a62f60b1a5ed90bdbd266513da601f5fe8  release/kernels/merge.by_instr.json.gz
fcead0703de8f9c48b478d47e9014776d1420a0ac4f2626252d16358bc9b4532  release/kernels/merge.by_unit.json.gz
1cdb81e86e4d30ab9e1a19efd1f3890da9123ddb88187024044b96268bbc023d  release/kernels/merge.ccvtrace
84b6598d4fe037255e54e52a29ee3d9fe151fd9b6c3c18cf07335442ececd222  release/kernels/merge.log
f96d28815f8756b1f5a45ded53e6170883d2dfa10f9eef0d14b8050b1318164a  release/kernels/merge.oracle.jsonl
442c82e36b0f308c0eba0f847d956442571862914f70698ea3fee661df325ae3  release/kernels/merge.sv-hosted.log
33f00c3b8d19fb69684ab00e0704a403dce288a776da30fb880824cd5a98337e  release/kernels/missrun.by_instr.json.gz
b1e878849585941fab4ccb7ca4836840eb2eea7489c8f1b3539384d6ca2f31e1  release/kernels/missrun.by_unit.json.gz
b8eb371762b05f7890a1c8a1821bba0961af38a5db59fbcf5eaabfb132c5dc20  release/kernels/missrun.ccvtrace
0cee6d0b229cdc25d2b2e3236e9541ec99317dc4064ad892f7b3d9565487c0a4  release/kernels/missrun.log
531bdaf281e5590774bd2775427f25e4cc0419cf8e3d5b6999843ffe9ef87258  release/kernels/missrun.oracle.jsonl
de28532fa788104faad90e60153f27c6ad3a2889a4395bdac90ab70857034c0d  release/kernels/missrun.sv-hosted.log
f44dd17ecad4d192726a842cbb6d8dec48bf03c23e5cbdee9153e9f1b113e428  release/kernels/mload.by_instr.json.gz
1e3cfc8863f1c97c6e20270aab4ec09e994bc1ed4795f28de6e93b947dded398  release/kernels/mload.by_unit.json.gz
97908ce5e7a9df5d988e06cdb58a9f10d0cdcd7e719b092502ccfd074b9228ab  release/kernels/mload.ccvtrace
aa90e9acfed3b113e9f35d6e3fe2b8430094c44bb4bb92e6fe82b3ffa30c0a40  release/kernels/mload.log
8000e477b9a95dfb9f0af964e8346acb9d36f1358fd06ffc4ff7cf599d2b8868  release/kernels/mload.oracle.jsonl
a8f39bccf3cb21034a16c667c6fa856e49f60827186e14bb0eda5e715c7139ab  release/kernels/mload.sv-hosted.log
81d6f2016587d0bc060dfe4988bbec84f9aea8f780bc3a706110beb7d3be54b3  release/kernels/mlp.by_instr.json.gz
fd43e38c71b1edd07e1c5c294982034b411ade3fb370534be61b5bf92162458c  release/kernels/mlp.by_unit.json.gz
31ae54590ed11ce427715be77ad492dee5bab993e351a7b7de09dbb6123b7df7  release/kernels/mlp.ccvtrace
7077a1290445987297d6042cdf5375a0294f692c8c25564423026d2218442132  release/kernels/mlp.log
138d282f88d56c8ad648a91af0a983254b55d9fa22942c00d47b327f516a6e44  release/kernels/mlp.oracle.jsonl
e6cf695f9db166a652a98e74ff9238aeda5b96255bb564276687935547231bbf  release/kernels/mlp.sv-hosted.log
f89052f8cb3291a84a9ac412f5f66673977328e4d80ee3c9447a7cbd46f64123  release/kernels/mwmiss.by_instr.json.gz
134462ed1414bd6ac2ac17aaf9982e4e99f7153a4af5dac2ed1e56184c31bf09  release/kernels/mwmiss.by_unit.json.gz
194cac222b145131d0bcee8e371334cde6ef588629e284b45917c6aa0fc6890b  release/kernels/mwmiss.ccvtrace
a61d09437e8fccb515d519111105956600bd34b8e0623f482acfa089cad5e539  release/kernels/mwmiss.log
8abe8e8997456a2a6711ee72da54d854b24e20abbdab28e4b7271c0d28418de8  release/kernels/mwmiss.oracle.jsonl
4053ac3e1234e723ba3c827a8c35ee5b6201f799ffd331c52dc37bb17b8cce1d  release/kernels/mwmiss.sv-hosted.log
04a45382100c978df45792e5a8fc6df4e3e8c977cdaf5783291c074dd7985a66  release/kernels/narrowadd.by_instr.json.gz
d08cf472fb616e09a30919390d47da63cea5592af7c5f7f975369e6c583096d7  release/kernels/narrowadd.by_unit.json.gz
856c082ec93e6f7d5e8c0e82cce9a7d0d54c287a13629892ec5aab922f0ac02a  release/kernels/narrowadd.ccvtrace
aff869b1c1d36df372ed7d5f73969050107da3ed2d8e6f881b0348acaf3ece2b  release/kernels/narrowadd.log
40a2cf629853dd404bb06b4a07e35abde3d12efc13f26ffe28f923daf2994574  release/kernels/narrowadd.oracle.jsonl
444b607433c3eee843a0abee90aaf07735aecbd36dacc2fae075faf29f0e87ac  release/kernels/narrowadd.sv-hosted.log
4e9509574166438caea4ccc1117af0fc9d4d3273840bfdade2ea487014cfa167  release/kernels/pgcross.by_instr.json.gz
6e7fc98f118d6c34fe7cf02eae391a090121a4f15061de18224fc3b82a76932d  release/kernels/pgcross.by_unit.json.gz
1075a5594ef3271367362cabe405239302b0e209c0d232029504894cde8b8086  release/kernels/pgcross.ccvtrace
8c07ccdd007d99d72f227c3fe8b96b8f5985dc9245ec662145c5dc1c19dc8ee6  release/kernels/pgcross.log
58aba9ba5ec6a72271191c0249014802cdc7e4470d27491f499a077f17ecc039  release/kernels/pgcross.oracle.jsonl
171b60da58443a1aeb4ba4709ab6ae4c1cd4bc27fc818c8a87218330e7cf484b  release/kernels/pgcross.sv-hosted.log
167cb18b56e93e138095070af3a442365a198ed815337a89ebe90567986bc631  release/kernels/pguard.by_instr.json.gz
80e48c732bd8b15dc32458cb2887f53452754f17f6cc3ad18ca7bbe2c0f4555f  release/kernels/pguard.by_unit.json.gz
5780c007d8d8e484e42eec3a5c12c48ba4c77684087ae6d5c756f31851aecb0c  release/kernels/pguard.ccvtrace
c3a32895844388cb8a5dc4af79462ae45de412704ef89567ae36d2a317684f85  release/kernels/pguard.log
690e56f1cb8d97cbf67124b7dff3ad0a90cb8981814cd1709cf0cd0e035b3bd9  release/kernels/pguard.oracle.jsonl
af0149c825cada44f9c16dd93998e4847be68419200602c8dfc5758085398d59  release/kernels/pguard.sv-hosted.log
280256b165c173f24a677ddc85e9a3c9b08f5328939f8db61bb3d7df1f2db66e  release/kernels/plog.by_instr.json.gz
5a7ff40d5aab0886959b93b38d21b17e9280a3d0d584de6651ca5fa246de5ba8  release/kernels/plog.by_unit.json.gz
387ce59a221b93134bbfe7a7174209bba6c1be72e7880075a42de6aae6e452bd  release/kernels/plog.ccvtrace
5eaa8df32fb8b4e334727d453dbb45b863c439bd3d082905b63113dd92258e9f  release/kernels/plog.log
0c99915e2da60f4670da00504a6371d7d17701d4431e733a3ff8fa98a2030d6a  release/kernels/plog.oracle.jsonl
98554008cef00e5930b3cfc0ae8c705c5f88e065f72eff917c9b32a6e7e8c9de  release/kernels/plog.sv-hosted.log
c0852998ddedd318dce6db4c49dc533f235f1e67ba5119d80c2baed2dacbecbf  release/kernels/pmovdiv.by_instr.json.gz
019ecbc0bb2a64da65508f4a28015d68b60860288d5f9baf606192a2d1f57518  release/kernels/pmovdiv.by_unit.json.gz
e14b32efba43482905dd775905197af8a3748473c9b7a924664ec3b5a8fa00ca  release/kernels/pmovdiv.ccvtrace
f5111a4989ebcc8900e944a844cd398fb879df0e7a7eca33bec84a8638aeb1cf  release/kernels/pmovdiv.log
7bc646cff6166a51bdce03d7c1b7209e871f0a91d743083a9b910a80bcd0b33f  release/kernels/pmovdiv.oracle.jsonl
75845fa900da2428dde2c86d15305d2490e005c06a74e68cad704a03fd853f08  release/kernels/pmovdiv.sv-hosted.log
e3bed606d8d1fc1544ccda57d2cfe4763fbecadec24f49d3d994cd7eef65ceef  release/kernels/predlane.by_instr.json.gz
ab9bd3770ec445b8ddf9782837506849125f6e69fb563bee6b7c059c86bb655c  release/kernels/predlane.by_unit.json.gz
6125cd4c52ad4aca6219bd684c227cc5307c3a4ac7fade886528a4d29bfd1f8e  release/kernels/predlane.ccvtrace
76cb3adddcddbbc660eb9e0dbab4d89776502d6975eb9dbf6cb5ac4d02a6cbcc  release/kernels/predlane.log
c45f4177b9e84fc8a6e36b13534a0c7636eb30a3f8531847100ce5e23bf404b1  release/kernels/predlane.oracle.jsonl
b02b357d464b5cb4d455fd2cc554f8db859f93c51faa764cbe32e726f5d1563b  release/kernels/predlane.sv-hosted.log
b59d177e8376e784a3e1524f8e4b95d364161b3b798d9d3d77bd1fbeb01032d5  release/kernels/predmerge.by_instr.json.gz
dbaf340582f1b623d76a97349dd3bdbeb573c843cdaa087661356fba24dd1f1d  release/kernels/predmerge.by_unit.json.gz
d12b62f73d450c8a60520fe340f72a1d91fe544821abb08ce2129854705d4b11  release/kernels/predmerge.ccvtrace
6e67bd057e4408ba2769ba6eec6964781d78f053177df492508afbabfa9551c8  release/kernels/predmerge.log
6c737c49434bcd08e3e0814c8b1dbf15c586ae74f7929ba3148ddcee2c62c845  release/kernels/predmerge.oracle.jsonl
50224fabdcf0bbc5a49778547348877108378e095e9eb80abc1abfc04237acdf  release/kernels/predmerge.sv-hosted.log
f4bf4ef59c93671526da336a74fd22c072a08c50058ff514c1fdf9cdd6d20499  release/kernels/predspill.by_instr.json.gz
924b9cc45a898f7b44cfaf6f03a2fcc1ba1aee565c3c774490c7758ae2ad9b88  release/kernels/predspill.by_unit.json.gz
4acb0d76476805572793da062f6710e4c560428db30adb45ddb33306f039c449  release/kernels/predspill.ccvtrace
ae0c20876547f727fb67e9cfc95c0dec7051e8b3100c572b9549cafb00483173  release/kernels/predspill.log
b7c84c6478117ffa0f06da0e6ad1e4628e2683426a7911080810e78e06a5242e  release/kernels/predspill.oracle.jsonl
93195ce85a9a534d44698e554c888562fa4e36ddf3d49eb4abd34d10bf47dc7c  release/kernels/predspill.sv-hosted.log
8e8a26921b3829e31ef4c9ae1d77addd9a80de4b4304ef0f72d527114e40dd50  release/kernels/predswap.by_instr.json.gz
4de6383780850ead316f126ae2ef08dce3458902c362f8517d75228c42f7a272  release/kernels/predswap.by_unit.json.gz
88ff2cb8b6a348da34bc4e2f2984df9d8eff258c537100f2f51c42d8e9f31c94  release/kernels/predswap.ccvtrace
f34c67dd3c39609167174d0b8d801e49ffbb89bfc0a43c0504535b76c5fda01b  release/kernels/predswap.log
a6d4f7ed517553816d889c7c9eeb6bcfd1f6c973fbf682ecb69f3c2de619f7bb  release/kernels/predswap.oracle.jsonl
5cdadf86cfb0aab317aa8d2dccc62f8e139252e4e4ff6da4d7b52d5d1a6e70a0  release/kernels/predswap.sv-hosted.log
3da8a6543d36021561d68f8ff59183fba32a388a468d1838810ca8e12135b3f9  release/kernels/privwin.by_instr.json.gz
99f1c41a30588e51f4e13178c571b00763c406e7aca574239c623dfa7bdbc4f8  release/kernels/privwin.by_unit.json.gz
2d5ca9a18e8685cc4b204cae08205219ad84b1d53d3681103072d970f29f8f7a  release/kernels/privwin.ccvtrace
444437b6cdf024b204b108d3474195b1becc94d96ae6d1dd1ef6df7e03d21c61  release/kernels/privwin.log
861f686fc4480363472908d679d8815e8c957d768e7ab32c826930527b0fb7a8  release/kernels/privwin.oracle.jsonl
320caafb8f1122a45096ba0e032be898b5b8bf9bd4543d39252fec0cb08f9b06  release/kernels/privwin.sv-hosted.log
a5bbb043437ab04ce45e4fba45fd06b33cab200735dc36160b81eef995b087f7  release/kernels/provswap.by_instr.json.gz
345f1d8227a26492ace644fcf2d767a7e33c8256a2ec5a57efc76d4ff0471168  release/kernels/provswap.by_unit.json.gz
088bc232abf07d6ba9a09759ecfbecf68eac57a4d0b7ed4f4618f90949e7f990  release/kernels/provswap.ccvtrace
cc9def6045b5b14888c46d01539a44c22d7224f213057242e0b36f2172d351ed  release/kernels/provswap.log
c9c32a793d54cc7401477f582487f7e8b345b2669a75337b8d6327120d98e5dc  release/kernels/provswap.oracle.jsonl
173597144d4b0a773f6aaf4a25a163a8492620ae17d40ae69dc8515932860aec  release/kernels/provswap.sv-hosted.log
0f42c35c5af6d3e26e200667d820838b404070638bcd4229937522eae9680e57  release/kernels/retmiss.by_instr.json.gz
78c37b77796588bc832901e4edf5aceea080e7cfa613594c6a638d2b4f60abb9  release/kernels/retmiss.by_unit.json.gz
bfbbefd347fefcecce4c062f69411177881642da0b75e77882d3ee0581c76e73  release/kernels/retmiss.ccvtrace
46c94037ae257d4b7bf17452ee1f649da514cb81f2d8828ba5386c306bbc0df5  release/kernels/retmiss.log
e5ef8538e838c6cff7febfc679dd091cf5e002f82d34f1009b1948ce22bc3649  release/kernels/retmiss.oracle.jsonl
40b6d7f59ca555f0ca1bba816c57052c3374fdb7d2c09529b6d7a50a8e95dec3  release/kernels/retmiss.sv-hosted.log
603d34b3e2ef78fe7c2ee9caba2fa14cb6d65e9ed96577ec8788422100e509cb  release/kernels/roconst.by_instr.json
99d4752384a5073955557493bfaaf8d6c89073d0c28dfdf874716d828bad085b  release/kernels/roconst.by_unit.json
3f308625fba014120ba2ace4c66df0da328b8bb9f88284187036e935af11dcdc  release/kernels/roconst.ccvtrace
8e5c6e0a4ab361addc2605826200c307e17053895d157e1c0dc94e55b0747482  release/kernels/roconst.log
8087c0671de620162881aecd38cd6114b78e7be6bd71201e3ec02c9a2e2e750e  release/kernels/roconst.oracle.jsonl
7d660cb42c74370d34269d1d58a4f8ba940addd1f98d87d56d24bc5c80589e70  release/kernels/roconst.sv-hosted.log
021eba124835a32b76992f2e974ca3672b5a740356bf16a8537f2142f82cc04d  release/kernels/rogated.by_instr.json
70a334ff8b37567322173efabea06b4e6ff72e388e9f64fc950fa1b567acebd3  release/kernels/rogated.by_unit.json.gz
f3e4d01deb50c34072147f3b4ac9743b3f805cd081bddc5570306861f48fdbc3  release/kernels/rogated.ccvtrace
0f513c748e879791f8bb64add04b6838da25b97e6909701fe9e9eb6120db744a  release/kernels/rogated.log
7cd02bd4cceec5a044d6b4d6a80df1e68ed0ae71b0b2a953143636d5b809ea6c  release/kernels/rogated.oracle.jsonl
d4a0b027fdf4958ba41c06d59a070985e15d8734193af217794a664208bd08de  release/kernels/rogated.sv-hosted.log
8a1ae4b0428bc801c80bb5d426c45d805515f0f152b8418d1ad101d6448cdab0  release/kernels/rokill.by_instr.json.gz
7088758b7984613b5dcbda95b52e60e5372ec292339bb6d752f736f42cd73e94  release/kernels/rokill.by_unit.json.gz
ff4c2934c06ed81c6d1273e91d72ebb62a6d87f228c416d1690656a5072fac04  release/kernels/rokill.ccvtrace
6d932ff7db834b8c263a3579e55990eece143437356583efbc97c150ed53833c  release/kernels/rokill.log
94efcef96af469a512d346ce61623980fe86383188eaebd55120f716db596f14  release/kernels/rokill.oracle.jsonl
9fcecd8c18fe93e570b1b77fb284cf16adedfdef7a82152420ece74b0f136ed8  release/kernels/rokill.sv-hosted.log
228db10346e2946fe8b499d8fc600ab580cab3497122836e14e50982ecd151dd  release/kernels/rokilllane.by_instr.json.gz
b8f2a666927c671d7f582deec4c72c0c2413b6ceeced64afce6830fa8541ffee  release/kernels/rokilllane.by_unit.json.gz
7549afe6896c59bb2f37fa53f994036c055fb96bf2b814ce7b70dd489f7f3cc4  release/kernels/rokilllane.ccvtrace
6deb08deeecfbe55beca74249e1fe8227206565da79932102522a53364ff8584  release/kernels/rokilllane.log
f5ca6e666eff2f44894df74a291b43b3c0e7be0a63a47d795fdefd7b22016f45  release/kernels/rokilllane.oracle.jsonl
8bc674cca9a47026a847145bb18d237f4b17ca112dcfc2ae222177aa8ae8bb93  release/kernels/rokilllane.sv-hosted.log
569cff71dc56456188caca958f14a12768f3c7955945b5b4666dd0aa420f091f  release/kernels/rolaunch.by_instr.json
71c2e34031be2b753efbedd40555ead40760aef4021d4fcd4d64f65485c78962  release/kernels/rolaunch.by_unit.json
1ac753ea9ed608c9c4b4b6172ad5599c088c964fc8cb02e6ca17d9e2261a8b8c  release/kernels/rolaunch.ccvtrace
7d35f7248bf718d392723ad709639cc6dd1857bb749f474804a610f993f690b4  release/kernels/rolaunch.log
e7dad585c3e70615de04330fd03f4f282c29a005dc1732a35655fb261d51139e  release/kernels/rolaunch.oracle.jsonl
989b0d8ea016d5d7310e4c67ab331849925becc2bae99461a3103446c93d94b4  release/kernels/rolaunch.sv-hosted.log
603d34b3e2ef78fe7c2ee9caba2fa14cb6d65e9ed96577ec8788422100e509cb  release/kernels/rolimit.by_instr.json
d92aa8adeb8a29fabf7e3b434e14c21423a947f08e863e13f2bdaa19587258de  release/kernels/rolimit.by_unit.json
fe3bdcdd340b4bfea2de5acc69b5e905c19abba754bcade8832f4bc9587637fd  release/kernels/rolimit.ccvtrace
6d8559621340bdd2429181131cf9e9aec8d66be8abd52c56ca41fbe3eb60de0b  release/kernels/rolimit.log
1c5bc0cb8e8b2e69505fb5a551a16d5d10c56f232b88da7a27e336ad7d962de2  release/kernels/rolimit.oracle.jsonl
ea1c5205362804c57d703d75af4daad2337a00722e4f4cd57f10e0b461356eb7  release/kernels/rolimit.sv-hosted.log
19d867cbb33df7aeb38cfbfb29832ff2687a1396de0dce873d006de00b65ec5f  release/kernels/roload.by_instr.json.gz
33a1e335744c16c113e72a01cd09349d793851f0651c0a1938577a4478475d7f  release/kernels/roload.by_unit.json.gz
daf6e410d7d2ac715ebbbbcb1e9b59b231ec34d4e160edc4d422b93676dcc296  release/kernels/roload.ccvtrace
0a9ab9ee8d660493d9a856dbbb2bbd6ac4b414903deede2be8e655481dd4ba33  release/kernels/roload.log
f7c1309cc9764769fb5803f6fd0f2f5e1eb418f2d23fbe5e17cf5f9106869fdf  release/kernels/roload.oracle.jsonl
fe1738ed992a064df3dd794b28f6974a63b155c9bfc0a60692b0c935a2794f63  release/kernels/roload.sv-hosted.log
fd109e96f4764398d380d349b8283a5ea14f824042af0b973f650a49c1d09805  release/kernels/rope.by_instr.json.gz
4e1c2e316239d655d9a97b91d24f722a6dc97e40180f745e39e3a99b9ed76772  release/kernels/rope.by_unit.json.gz
05e7a6db36c3dd408f960bd4d1797ae391d5a8bd97ad85661fd17d69619631f0  release/kernels/rope.ccvtrace
cb357e6ad859ade227b4fb282f9951c1502cbde1fe14de8d7157c3aceed03a3d  release/kernels/rope.log
d55f9efae392dc8877c102c01c0810e7654b666b6ede386328108164c6cf88f3  release/kernels/rope.oracle.jsonl
479a09dcb8ffe677b57ae5b81dcdb790b7021b2e12479bb761cd5006a2a5ad89  release/kernels/rope.sv-hosted.log
bd6a4ef50f14793ca8adf1da8cedf32b59ff34c99d28183040ae79de7c6380b7  release/kernels/ropediv.by_instr.json.gz
6140e473790b258a399b9bc7c1339c55310b66cdc568232f111226b588153c5a  release/kernels/ropediv.by_unit.json.gz
7f4913765afa02a393b311757c4c8ee344f32d9affc8ff7c28acf23787f3ab85  release/kernels/ropediv.ccvtrace
a4cb37bb799b7a568827da987ebb2a111f7883569514ed414ccb217768086ede  release/kernels/ropediv.log
10c0ec6ec18b7b44638c790033109198c079d07c1537bf193353ccedd00a920f  release/kernels/ropediv.oracle.jsonl
f5013a5f3276c13adf58b2a7a3a708abf7e6ed6958046fb9f6bfdfcd0cfd293a  release/kernels/ropediv.sv-hosted.log
4545abfeec7a212ed0a6f58a070bec208a5ef419bc3981d54235214b650949a9  release/kernels/sel.by_instr.json.gz
f3276e8d9513ecc7c36ef02d36cc76f129e483e1881a17cb99a48f3d1c45f8cc  release/kernels/sel.by_unit.json.gz
dd647e12092a643c2a1460c40c481fdb05157296e3be93c0685190fc57d0cd35  release/kernels/sel.ccvtrace
0abc74b8857b58f092ccbf88b09537c3dce7dea2ea1fc596b7e83c5bc4358b71  release/kernels/sel.log
87f6a81e8afa004c8039bf2f61c90176fcf29ab29bb17ac44aa016a5cc8438fe  release/kernels/sel.oracle.jsonl
c41125f98e5c0a2fa28c7ffc2576339e5b04dffabba9e0b5172d23d2fbb9b9bc  release/kernels/sel.sv-hosted.log
f093ec623ae5689937b8ad763483c0a6689801ae2ccf3e078b4e0f269969cbfa  release/kernels/sized.by_instr.json.gz
ee612b2885f68718dacfb5e5490f89f82f72eb1fe9afd653c8e58b96f94116e9  release/kernels/sized.by_unit.json.gz
bfe021e6fcb2def44b0664d1f590c6248056730c0d50adbff63cb285e95a2bcd  release/kernels/sized.ccvtrace
a0c6604c85a291d13dcf2492f30dbadcf5d4ebe1aaea96fc93609ca71eff1a28  release/kernels/sized.log
36d903ba1618bd1faa437c9812a6ee6c0c966a63196c796267d74bf2695ebc3d  release/kernels/sized.oracle.jsonl
45e712a56f0005d5fffa79fff4e58f9f0bcc6c12713190ec0dc00d3f281fb359  release/kernels/sized.sv-hosted.log
d6ffd068653493722882a07058810a45a58e1c3bda9a7b877aca742a74662568  release/kernels/slotform.by_instr.json.gz
dd9912c93196f0bd83d9776b2153b709be69ba2571e28cddcfd50dde2ea1985a  release/kernels/slotform.by_unit.json.gz
3083add05cf1feff14db90d23aa30358f6222d090978cd1311e6aa9c9da213bc  release/kernels/slotform.ccvtrace
92485bcca80e735783fcb105c952c44fde7cc76464e8eaa21532b3189270e1e1  release/kernels/slotform.log
8b61db7419b18cea8a646fb628218447e72e84a18a9891ffb73b441736138ab9  release/kernels/slotform.oracle.jsonl
58e32187e6e40c1fedaa09dec8e8f38a3cc6acab5f824bbf929a918c7510c303  release/kernels/slotform.sv-hosted.log
c91f4f1c0924fa002a3ea16c7069635bfc0b2e6b3cbf28b82031119eb039ec6a  release/kernels/spinwait.by_instr.json.gz
510969c30373042b3f37e4cd3085ee8847695bc0fd09467800bc490c58b706d8  release/kernels/spinwait.by_unit.json.gz
e1e6e79e8abe3c1cd8ab1b7a3082edbb235b9e5f5b8de9f967ea5c8bd9514fdd  release/kernels/spinwait.ccvtrace
2c9708b298bf666ab7834ff6db2d329de77d487851cc680e728f6db6e9ade457  release/kernels/spinwait.log
868920637236c878b33779bd450439466fc3626996a3164573dc11d437d5c709  release/kernels/spinwait.oracle.jsonl
f37f1e9bf0c741e04092ea9c5412009d4071fb67472f15e02dd8df296b6441e6  release/kernels/spinwait.sv-hosted.log
ce6b1131dfae218c3553646d891e270f30e563cb5f4ddeca7b1fb9cadd380de0  release/kernels/spmbank.by_instr.json.gz
e67d6bd12050900337d33bcde710b6dd20b8949b1db27105e6df863bf800ebda  release/kernels/spmbank.by_unit.json.gz
07b1ee79a22697f03f52c66f26d006d2beff88468d0c195ed2e3ec245ebc3c51  release/kernels/spmbank.ccvtrace
d74dc6882a1c991cad404a516aec6ac019cad26a0f582a802b5c338cbdc22f1d  release/kernels/spmbank.log
3af490cc37d7a92dbe719b57de216b648536eb301ff9d13de9a39f50d150d725  release/kernels/spmbank.oracle.jsonl
48a7fa0d5e092268993005a4cd920c722bf4538bcd202ddff245bc11efbc7dbb  release/kernels/spmbank.sv-hosted.log
57fbe67adfb976daa192c523b284782826295b62ac0611323a9abcc7d63d7918  release/kernels/srd.by_instr.json.gz
75b44e1788381a6c18c75afb4ed455cfd7d91702cdb2d97b4ab92d9498fd9782  release/kernels/srd.by_unit.json.gz
d61e4dfb34de07aed8e08cfc3fa64c6da1e9c6d0184e8d7953dca6fee93258f8  release/kernels/srd.ccvtrace
3dac8c1caa29d971be728f8551a1b0fff1fb13dd900af7e8448a0a91512eb058  release/kernels/srd.log
b08eb5e3673cac7eebb8b72af5ed3783c8e70a9e96592e76bf3722551bc79473  release/kernels/srd.oracle.jsonl
c9dcd66cdafa01b1e40977aa5fb0aa08aa9330c2c98a689db8e10c46f076229c  release/kernels/srd.sv-hosted.log
19d41bebd1c20bb41c5101e3c456395f21d794a58fabe61e1fcf9cdce335c037  release/kernels/stall.by_instr.json.gz
2b62194897e2f1b916b454e83da85430fc427190c17ef79dfecf778e577d8534  release/kernels/stall.by_unit.json.gz
eb115d257b0d6e1f4a9f3feaeed1392031fab7d9c846825d321f87bf295c5129  release/kernels/stall.ccvtrace
d81cdedb6b5413388e0b9d127ef349f4543b0c2538a78f173675ffee81cedff8  release/kernels/stall.log
500db2c482b07a0706583422cd68878301d0146c1f872ccc1f11bfdcf5c993ef  release/kernels/stall.oracle.jsonl
d6212c6cb0667990d2cc462c530d598751acecdf80c57f2e7139343eaef39956  release/kernels/stall.sv-hosted.log
f02f1ab7c090f562a5fd37a48eedcbe83180cf329c1c206897c8723f84bb7e82  release/kernels/swap.by_instr.json.gz
290a5e5a1de2da5cefe4be650ad714fb873f3831455659ce82d439210e897c14  release/kernels/swap.by_unit.json.gz
78358f37b30e6a964b01ed202048cf739786bf167ccad8185d2291f18edf25fa  release/kernels/swap.ccvtrace
171e889c4b2165efdeb24c863b5287b261f9e0131a97a2c754268129204ffce3  release/kernels/swap.log
3658a26316c1ff7bc1744304a42f736e930fcde2865c8913e6cc67a22ce96667  release/kernels/swap.oracle.jsonl
cd3b404db9535f7dee6bfb412bdb7b2e2b2194d2878ff10fb5d6c3e2c66dba33  release/kernels/swap.sv-hosted.log
a75fead165b18e1f6b8403887d956f206a5a40c0abf5a2ca7abc5bd46a6c0bdb  release/kernels/transp4.by_instr.json.gz
d028c503e57c8d77e8c929a49095ca47c896aa82059da27887395d66771215ba  release/kernels/transp4.by_unit.json.gz
ea582cf8bd5c73f7124e759d9d926fab43df18ec1d81300be7657119e501eeea  release/kernels/transp4.ccvtrace
c9fb608c4e4617468d6efa91af79307adf5fd697a642a0ec4969b54b84b78773  release/kernels/transp4.log
06396ace3ac19677fd39c700e408606e5bdbacb24997d663bbe8872e63dd74fc  release/kernels/transp4.oracle.jsonl
6f4f75712aa3c0b252d9f054d98edafc702efd523ebf5cc8004d47759ea9e77c  release/kernels/transp4.sv-hosted.log
d87a534002d282003756aee340e9c7b63f7d51de9cbdb1ad8a02d0c6fbee0788  release/kernels/unal.by_instr.json.gz
8e1ce2e78c8c2aa30ef903ec3deb17f0ae2a7aa46fc3f59499e0b4f16a8b92d5  release/kernels/unal.by_unit.json.gz
27b99c99f163c010c426be84bef96cb51e5fa6b552aa3760d004decf550e09ea  release/kernels/unal.ccvtrace
51b9b6a1b88b1ea2acf9139fd128660aa81be8de190ec7753a82d203f7a5288f  release/kernels/unal.log
c3d484bb160657a563df983d9a2532eac27f556636617960aa1e72183ac2b299  release/kernels/unal.oracle.jsonl
eb564fa8d9328a1868d143b349f20f12bdbb093e834ec7ccd66f6c4c54df308a  release/kernels/unal.sv-hosted.log
4f9f978fea1471f99fd0c0049b1ade7eadf28736ba24f725456dbb8c168df052  release/kernels/vadd.by_instr.json.gz
04b26e15069f7513621e9a5e8571b7a19b3b3cb7ce5f14c5ec9533212d8ab03e  release/kernels/vadd.by_unit.json.gz
4b3f52dc9ed3b500b0b1ecca9758ca70de54df2df1d71ac14aa11787001a4654  release/kernels/vadd.ccvtrace
422e86936e03a36fa059f3559750fc2c039f5f32e71710a3372eef0748f8a8ad  release/kernels/vadd.log
0276b6d0611a4bbcdc004ab3987214aea138245bc7217504147331689a9c0880  release/kernels/vadd.oracle.jsonl
af72a13d997546b1154e094545bd4fcee858c11f1b1df6a145d31209077e1ffc  release/kernels/vadd.sv-hosted.log
f7ce75d337515517095d28bec96c9f93611ff5af50ab42f540dfc2fb6272713a  release/kernels/vadd4.by_instr.json.gz
2aba9fd3aa3b7f276fedb061085f07faf67bcf6ea7a5cfba4c18745810dda136  release/kernels/vadd4.by_unit.json.gz
c45922d8a62b46d0193991e7eb78a7f057de7d2936f01a6052da2f43b0b5dd96  release/kernels/vadd4.ccvtrace
9f810f39bd07a9bc92b582fa1160693e48ce89a5688b7c2697eab7b3befcf7f8  release/kernels/vadd4.log
225aa18fc9f38aa9ad615aa11de254337d59fa705877553d873062c68366e0db  release/kernels/vadd4.oracle.jsonl
8456e9f0943e933b9c643322ad74c4296c3f6ec58990412ef93104c9c7f51a73  release/kernels/vadd4.sv-hosted.log
ee6d340b34ec6025b2d22d7fb0ee1c24776b1c0f2d830a8f33112a5ce7846ed0  release/kernels/vadd6.by_instr.json.gz
578931044eb23d48af9cf06b0d9ddfac9f5396a0ee76dfedef60a5d3755578cc  release/kernels/vadd6.by_unit.json.gz
316afa3c985ecc510e40cebb3ea0bda78d207774fa0706a38d7e476098bc4f96  release/kernels/vadd6.ccvtrace
a99fe8d6e40c600dd9983d3727bc7e8fcb1fc18517e4a346a532b26ff2170400  release/kernels/vadd6.log
10335385a8b6359c5e8310565561a4a5febfe318ef4ea0a6e537be2d372c54f4  release/kernels/vadd6.oracle.jsonl
9d8aafe31d39a35d12b1f58798d6a5010e1b47098fe0bb0ac7bb737c84481ff3  release/kernels/vadd6.sv-hosted.log
f061a9953199f07001bec20ad3eb7e5d9ad06b021d654a2655fc4e5bb4d00ea9  release/kernels/vaddslow.by_instr.json.gz
4b2b7ec3553a646c2ed29dc90a6ba601d9574c66b9e7dffd908cf8166194014a  release/kernels/vaddslow.by_unit.json.gz
56e31060ffadebaac83b1bad04def18f7d68e31fbbb3d6472b00895f258ae40a  release/kernels/vaddslow.ccvtrace
9088da6be14fd4536bf0a79504e33753941f1d80cc21b3c41899547e5e7bed1e  release/kernels/vaddslow.log
e9e6218e8b8450e9f9ff6b39d659c994a1e51c527a0c5bd10d18b5658ae0e344  release/kernels/vaddslow.oracle.jsonl
9fa9a092c30957ee081e0061275c6622d45db51d3fe347040bf31740e002b818  release/kernels/vaddslow.sv-hosted.log
9a092a6e4a10500faece93ee0a126f54132347de4b1ef9f93b087a96cb5614ec  release/kernels/waypred.by_instr.json.gz
c10bf45ba2c19d8050a63834db59e7d6cdf4324d29a687652fe99986ee43c229  release/kernels/waypred.by_unit.json.gz
4bb4d9a54642ae3c60c9286bc24a3e1a9bbddc5c80a73703715c834d9f953507  release/kernels/waypred.ccvtrace
ed871c9de1bb0dafe72b053aca952b4dc71452a519eab3b1b3365854f4f47b6a  release/kernels/waypred.log
54fb803ce85c4458b8687bb0f61adc32a9d798448b914b06261dc49c2bb841c8  release/kernels/waypred.oracle.jsonl
130b906f7d1e5192c2c2fda41032d1934da1610a16c3bc276877dd97518c5306  release/kernels/waypred.sv-hosted.log
904370157068362b06444f69a943af6d0b8dcadaca1e99a0a1f56c8a0c3ed6ae  release/verify.log
f78197fa73514d4391564b6dbfda61c3c03a38e2134c9ddc2d24180f29c72e6c  release/wiring.txt
```
