# Snapshot snapshot-2026-11-28-24cd474

**A generated, read-only snapshot. Do not edit or merge it.** The source
is `ccr-9eb50716-lecnjf` at `24cd474007e9583b2cfc3e4205012df9db7d2ac9`, and this branch is rebuilt from source by
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
| Source | `ccr-9eb50716-lecnjf` @ `24cd474007e9583b2cfc3e4205012df9db7d2ac9` |
| Built | 2026-11-28 (UTC) |
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
| `gather` | `name=gather finished=1 cycles=296 from_fetch=251 retired=16 issue_groups=16 order=ok gpr_mismatch=0 pred_mismatch=0 mem_mismatch=0 check_failures=0 class_violations=0 overflows=0 credit_leaks=0 cor_late=0 channels_used=33/57 violations=0` |
| `hit` | `name=hit finished=1 cycles=253 from_fetch=208 retired=17 issue_groups=17 order=ok gpr_mismatch=0 pred_mismatch=0 mem_mismatch=0 check_failures=0 class_violations=0 overflows=0 credit_leaks=0 cor_late=0 channels_used=32/57 violations=0` |
| `lanectx` | `name=lanectx finished=1 cycles=84 from_fetch=39 retired=10 issue_groups=10 order=ok gpr_mismatch=0 pred_mismatch=0 mem_mismatch=0 check_failures=0 class_violations=0 overflows=0 credit_leaks=0 cor_late=0 channels_used=30/57 violations=0` |
| `lanectx2` | `name=lanectx2 finished=1 cycles=84 from_fetch=39 retired=10 issue_groups=10 order=ok gpr_mismatch=0 pred_mismatch=0 mem_mismatch=0 check_failures=0 class_violations=0 overflows=0 credit_leaks=0 cor_late=0 channels_used=30/57 violations=0` |
| `late` | `name=late finished=1 cycles=203 from_fetch=158 retired=16 issue_groups=16 order=ok gpr_mismatch=0 pred_mismatch=0 mem_mismatch=0 check_failures=0 class_violations=0 overflows=0 credit_leaks=0 cor_late=0 channels_used=32/57 violations=0` |
| `ldpar` | `name=ldpar finished=1 cycles=188 from_fetch=143 retired=17 issue_groups=17 order=ok gpr_mismatch=0 pred_mismatch=0 mem_mismatch=0 check_failures=0 class_violations=0 overflows=0 credit_leaks=0 cor_late=0 channels_used=32/57 violations=0` |
| `lnorm1` | `name=lnorm1 finished=1 cycles=2583 from_fetch=2538 retired=526 issue_groups=526 order=ok gpr_mismatch=0 pred_mismatch=0 mem_mismatch=0 check_failures=0 class_violations=0 overflows=0 credit_leaks=0 cor_late=0 channels_used=38/57 violations=0` |
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
| `provswap` | `name=provswap finished=1 cycles=2285 from_fetch=2240 retired=978 issue_groups=978 order=ok gpr_mismatch=0 pred_mismatch=0 mem_mismatch=0 check_failures=0 class_violations=0 overflows=0 credit_leaks=0 cor_late=0 channels_used=34/57 violations=0` |
| `retmiss` | `name=retmiss finished=1 cycles=218 from_fetch=173 retired=19 issue_groups=19 order=ok gpr_mismatch=0 pred_mismatch=0 mem_mismatch=0 check_failures=0 class_violations=0 overflows=0 credit_leaks=0 cor_late=0 channels_used=34/57 violations=0` |
| `roconst` | `name=roconst finished=1 cycles=90 from_fetch=45 retired=4 issue_groups=5 order=ok gpr_mismatch=0 pred_mismatch=0 mem_mismatch=0 check_failures=0 class_violations=0 overflows=0 credit_leaks=0 cor_late=0 channels_used=26/57 violations=0` |
| `rogated` | `name=rogated finished=1 cycles=110 from_fetch=65 retired=7 issue_groups=8 order=ok gpr_mismatch=0 pred_mismatch=0 mem_mismatch=0 check_failures=0 class_violations=0 overflows=0 credit_leaks=0 cor_late=0 channels_used=26/57 violations=0` |
| `rokill` | `name=rokill finished=1 cycles=120 from_fetch=75 retired=41 issue_groups=4536 order=ok gpr_mismatch=0 pred_mismatch=0 mem_mismatch=0 check_failures=0 class_violations=0 overflows=0 credit_leaks=0 cor_late=0 channels_used=27/57 violations=0` |
| `rokilllane` | `name=rokilllane finished=1 cycles=1228 from_fetch=1183 retired=924 issue_groups=10674 order=ok gpr_mismatch=0 pred_mismatch=0 mem_mismatch=0 check_failures=0 class_violations=0 overflows=0 credit_leaks=0 cor_late=0 channels_used=27/57 violations=0` |
| `rolaunch` | `name=rolaunch finished=1 cycles=88 from_fetch=43 retired=4 issue_groups=5 order=ok gpr_mismatch=0 pred_mismatch=0 mem_mismatch=0 check_failures=0 class_violations=0 overflows=0 credit_leaks=0 cor_late=0 channels_used=24/57 violations=0` |
| `rolimit` | `name=rolimit finished=1 cycles=90 from_fetch=45 retired=4 issue_groups=5 order=ok gpr_mismatch=0 pred_mismatch=0 mem_mismatch=0 check_failures=0 class_violations=0 overflows=0 credit_leaks=0 cor_late=0 channels_used=26/57 violations=0` |
| `roload` | `name=roload finished=1 cycles=129 from_fetch=84 retired=8 issue_groups=8 order=ok gpr_mismatch=0 pred_mismatch=0 mem_mismatch=0 check_failures=0 class_violations=0 overflows=0 credit_leaks=0 cor_late=0 channels_used=32/57 violations=0` |
| `rope` | `name=rope finished=1 cycles=749 from_fetch=704 retired=354 issue_groups=354 order=ok gpr_mismatch=0 pred_mismatch=0 mem_mismatch=0 check_failures=0 class_violations=0 overflows=0 credit_leaks=0 cor_late=0 channels_used=35/57 violations=0` |
| `ropediv` | `name=ropediv finished=1 cycles=1062 from_fetch=1017 retired=203 issue_groups=203 order=ok gpr_mismatch=0 pred_mismatch=0 mem_mismatch=0 check_failures=0 class_violations=0 overflows=0 credit_leaks=0 cor_late=0 channels_used=35/57 violations=0` |
| `sel` | `name=sel finished=1 cycles=91 from_fetch=46 retired=8 issue_groups=8 order=ok gpr_mismatch=0 pred_mismatch=0 mem_mismatch=0 check_failures=0 class_violations=0 overflows=0 credit_leaks=0 cor_late=0 channels_used=30/57 violations=0` |
| `sized` | `name=sized finished=1 cycles=1001 from_fetch=956 retired=25 issue_groups=25 order=ok gpr_mismatch=0 pred_mismatch=0 mem_mismatch=0 check_failures=0 class_violations=0 overflows=0 credit_leaks=0 cor_late=0 channels_used=33/57 violations=0` |
| `slotform` | `name=slotform finished=1 cycles=431 from_fetch=386 retired=12 issue_groups=12 order=ok gpr_mismatch=0 pred_mismatch=0 mem_mismatch=0 check_failures=0 class_violations=0 overflows=0 credit_leaks=0 cor_late=0 channels_used=33/57 violations=0` |
| `spinwait` | `name=spinwait finished=1 cycles=2062 from_fetch=2017 retired=211 issue_groups=211 order=ok gpr_mismatch=0 pred_mismatch=0 mem_mismatch=0 check_failures=0 class_violations=0 overflows=0 credit_leaks=0 cor_late=0 channels_used=35/57 violations=0` |
| `spmbank` | `name=spmbank finished=1 cycles=200 from_fetch=155 retired=13 issue_groups=13 order=ok gpr_mismatch=0 pred_mismatch=0 mem_mismatch=0 check_failures=0 class_violations=0 overflows=0 credit_leaks=0 cor_late=0 channels_used=28/57 violations=0` |
| `srd` | `name=srd finished=1 cycles=84 from_fetch=39 retired=6 issue_groups=6 order=ok gpr_mismatch=0 pred_mismatch=0 mem_mismatch=0 check_failures=0 class_violations=0 overflows=0 credit_leaks=0 cor_late=0 channels_used=30/57 violations=0` |
| `stall` | `name=stall finished=1 cycles=581 from_fetch=536 retired=116 issue_groups=116 order=ok gpr_mismatch=0 pred_mismatch=0 mem_mismatch=0 check_failures=0 class_violations=0 overflows=0 credit_leaks=0 cor_late=0 channels_used=32/57 violations=0` |
| `swap` | `name=swap finished=1 cycles=581 from_fetch=536 retired=174 issue_groups=174 order=ok gpr_mismatch=0 pred_mismatch=0 mem_mismatch=0 check_failures=0 class_violations=0 overflows=0 credit_leaks=0 cor_late=0 channels_used=32/57 violations=0` |
| `transp4` | `name=transp4 finished=1 cycles=1248 from_fetch=1203 retired=976 issue_groups=976 order=ok gpr_mismatch=0 pred_mismatch=0 mem_mismatch=0 check_failures=0 class_violations=0 overflows=0 credit_leaks=0 cor_late=0 channels_used=38/57 violations=0` |
| `unal` | `name=unal finished=1 cycles=174 from_fetch=129 retired=9 issue_groups=9 order=ok gpr_mismatch=0 pred_mismatch=0 mem_mismatch=0 check_failures=0 class_violations=0 overflows=0 credit_leaks=0 cor_late=0 channels_used=33/57 violations=0` |
| `vadd` | `name=vadd finished=1 cycles=197 from_fetch=152 retired=17 issue_groups=17 order=ok gpr_mismatch=0 pred_mismatch=0 mem_mismatch=0 check_failures=0 class_violations=0 overflows=0 credit_leaks=0 cor_late=0 channels_used=34/57 violations=0` |
| `vadd4` | `name=vadd4 finished=1 cycles=214 from_fetch=169 retired=68 issue_groups=68 order=ok gpr_mismatch=0 pred_mismatch=0 mem_mismatch=0 check_failures=0 class_violations=0 overflows=0 credit_leaks=0 cor_late=0 channels_used=34/57 violations=0` |
| `vadd6` | `name=vadd6 finished=1 cycles=319 from_fetch=274 retired=102 issue_groups=102 order=ok gpr_mismatch=0 pred_mismatch=0 mem_mismatch=0 check_failures=0 class_violations=0 overflows=0 credit_leaks=0 cor_late=0 channels_used=34/57 violations=0` |
| `vaddslow` | `name=vaddslow finished=1 cycles=572 from_fetch=527 retired=17 issue_groups=17 order=ok gpr_mismatch=0 pred_mismatch=0 mem_mismatch=0 check_failures=0 class_violations=0 overflows=0 credit_leaks=0 cor_late=0 channels_used=34/57 violations=0` |
| `waypred` | `name=waypred finished=1 cycles=255 from_fetch=210 retired=18 issue_groups=18 order=ok gpr_mismatch=0 pred_mismatch=0 mem_mismatch=0 check_failures=0 class_violations=0 overflows=0 credit_leaks=0 cor_late=0 channels_used=32/57 violations=0` |

## Manifest of release/

```
12b3c4451c5aa78045a8c5a8d95df003bb4a1a30a84acc4d9927a2c778e31163  release/kernels/addrhigh.by_instr.json.gz
758486c0a0a735e80530a6d8d97cdf9eddaae45374ee3b8eaa25ae69444df2a5  release/kernels/addrhigh.by_unit.json.gz
00aa9f51998bb9626c92b99976dd5d7c69de3f61b760968761b82ec90c505a5a  release/kernels/addrhigh.ccvtrace
92e2aecda02effc982678cb466567e0f43d3f5d314b95b18e8a354845df469b6  release/kernels/addrhigh.log
569f2e22883fad5f0956c57ec734e6afbdd4b8a854e50277425172d6c0cbd766  release/kernels/addrhigh.oracle.jsonl
3869674187bfb1c24283704c02da390b74e5f95b223bc05ff0c1fe884c248e64  release/kernels/addrhigh.sv-hosted.log
6f10978c0d2bd2310db94413467c8192cf3405769ad19e4433cace98a196a795  release/kernels/addrlimit.by_instr.json
c9b8824ec76c0493a6e3f51a0c5aaa410581aac6b011c5157178ba5a2a4f4d1d  release/kernels/addrlimit.by_unit.json
020fba3b967ac88b1009f3f689ec377a7d962cf63f31f9c59ec8053ae96508b2  release/kernels/addrlimit.ccvtrace
b0f881cf485b3bef7e15f1ea2629ccf61472055a0099dad3d6e879a327fa521e  release/kernels/addrlimit.log
bc660b0b40359a2c5a2478cb0eb4950b73fd22db50ea76b80052bc195a1920f4  release/kernels/addrlimit.oracle.jsonl
f40f890e381134fab496aeaa09e0ea7c4d48a295c98dc6356994d9873f270803  release/kernels/addrlimit.sv-hosted.log
10f790f623c1988a4a701b2ed1f204612448086208931a7456e0648c455e87a6  release/kernels/addrneg.by_instr.json
6cc01cc7db43eefe2161b7fe13797f4b45c7b10c95bdc3155e57503425c4b5c0  release/kernels/addrneg.by_unit.json
66fe93895419e62fd3c292424e693819bae503553e64c4bc92c6ed729179d869  release/kernels/addrneg.ccvtrace
0330a6a734392006f0d6e7efa2eb9d4d7edd04fbd6b379e26a508abeab669f3e  release/kernels/addrneg.log
16f5b0707ae44492a1efd67bb9dd38a7e79a7bbd354fa9207b9e7d150ff2f107  release/kernels/addrneg.oracle.jsonl
09347a5bf47955c079d49a98015d984749193823c56ef14389355ba7e2344112  release/kernels/addrneg.sv-hosted.log
97caaf10add3087247349f541ea85d69fd1263eb5209924eae84e4eb6003e8b5  release/kernels/atom.by_instr.json.gz
490ccfcc15485dbef8c89cc6f54eb5d13e03463ff8cd77a7debd02012f519952  release/kernels/atom.by_unit.json.gz
66317cddfd6e2c68a4fe4a7ceaac59358d16c75f4c2e8f6d47e23238287919da  release/kernels/atom.ccvtrace
55893b530a83e2ce45b27274064d5bcff2b37e40d5179bf8756a9e005b1c48a7  release/kernels/atom.log
504f5b6e9d25114dc35f2c70b21bb7b3f3c508c691de12dc0e87d12a74285361  release/kernels/atom.oracle.jsonl
293b8306915575188339b50bf390a05c5affe1da47d2c3292c0f0ea3548642c4  release/kernels/atom.sv-hosted.log
7e35c520a2665be2c90b7f06d6aea4345b11e850ff2638bb8350c47793da7e09  release/kernels/atomf.by_instr.json.gz
156e83719332fd7b684aaf7b1f9ebe8345e10c546782377a0f4392f73b2ce495  release/kernels/atomf.by_unit.json.gz
dec336dba4dda0da039100750f613725d07b5a6c61bc703bdeccafd4266ed5a7  release/kernels/atomf.ccvtrace
8afd4c8b59dd8fcc71f92d8607c7881d6feae1bd3e351e25e67db34fa695e6d2  release/kernels/atomf.log
cfd1179edf4061a33ab2f75d7a6dec61decfe629000198189a7bfc2647b34238  release/kernels/atomf.oracle.jsonl
4e797d5869375f9914d3309eab1249d44128a4d608d82f9e6dcdf44eaa361b77  release/kernels/atomf.sv-hosted.log
7cd7ca27d79d12f5896c7cbbc71e1e07f5e5757ebfa10a0db8427a6b06a38e00  release/kernels/borrow.by_instr.json.gz
91af7436cdc6eb6bf53bd190f92e1eb8aaa4431339e39ef65b46af0947c3ceec  release/kernels/borrow.by_unit.json.gz
c162f4ee979318135abee3d266de57454e5bb84ab973a74730ab811eb7e245d6  release/kernels/borrow.ccvtrace
f1813ef125fc3deba0750fef079148c27c229ab1605ed6a5b5d4f4ce6dc4519a  release/kernels/borrow.log
4c565e1ce0b3baee36e158694b32c8defb5cd662b2f9af75cb5d8c26cb1168ed  release/kernels/borrow.oracle.jsonl
d9138bb230f3319dfa0b29059e011799ecd21f967a4f9023f3e39e1edd81db19  release/kernels/borrow.sv-hosted.log
cc85fd7183084bd546f03475ea6c1cbf010263910e95073bac8b355bd489e6d7  release/kernels/brs.by_instr.json.gz
9554c4931835ccfc658cabf52eacbcf4f972f265f4f8ef100ec5975551c46694  release/kernels/brs.by_unit.json.gz
dcae433e5ec770eafe8f8de176cb5e74dff81f2342d0c58f9f7050cd86f73e51  release/kernels/brs.ccvtrace
0b083a297d87774c1f8ef01cb87b20fc202f400c48ab69a79849ff418c071822  release/kernels/brs.log
e3c1cb3379580cf1aae44e8ddc8e846ef6fd661a573cfe0a8d4444b18a14dc56  release/kernels/brs.oracle.jsonl
700aab75af7e21f520dc54c9733be28a4fab65f85acc3c7450c67a648b88d18b  release/kernels/brs.sv-hosted.log
123857cef695ea96156efd22429de4629c676d83987186866ac2ae20851d2b3d  release/kernels/byp.by_instr.json.gz
adf3b68b5c70b13dc9687062fde80c440e1a1c1fabf8d1c4811b065644a29cec  release/kernels/byp.by_unit.json.gz
fe3aeae66e69efed04c08c783f324da8c7da50e92863154f874f2b10b2fef80f  release/kernels/byp.ccvtrace
55cdb677a6ac2a4a56c3fbf6414a6dfb18c635ac05c78cc74eaa1fe4b066e9dd  release/kernels/byp.log
5a03dfa4f3603fef49f1e3639e74e34152ca3ca5ef8e41eb959f8323040fa2d5  release/kernels/byp.oracle.jsonl
f6e1e7efb3e9bb624e48ec9dd5331534b1588f36c9291976f87dd3ea0437d4ba  release/kernels/byp.sv-hosted.log
f538b16c09d1a0de71338dce97437fc8dbb0dbf1d0478e8f022915f94765f466  release/kernels/callret.by_instr.json.gz
36210d0a2c81807293049b4ac8472ed7dbb9031d452a48a0b94d4bb872aa7897  release/kernels/callret.by_unit.json.gz
a634c93c02419e38c904a3e03403f22a4f60897ef7fdf77ad2872956e77a422a  release/kernels/callret.ccvtrace
d809673c05efeb5a8eadf7e5df25730e9a4ecfe50a6dcce4e6b2e59090b4f704  release/kernels/callret.log
9b1d1b50b527f732362f837250aa2f26dabf3e76e16a4794856ebd8f105635b8  release/kernels/callret.oracle.jsonl
8f3babb34c00d2af9c7c166bed6024ebfb55a847c7e49ade84e2dcf3275039fc  release/kernels/callret.sv-hosted.log
eaa2fe1fd8611c604f05c47fef07de4128a139d07948936ebdd9ee8c45d439b1  release/kernels/cas.by_instr.json.gz
5e3e543980bb30362008503917522bbe9bc034de79c2a7d1f1012f82359eed21  release/kernels/cas.by_unit.json.gz
99847c8ddbe72f92b5286f2292ccba324b846976d7f44f571d7c9c096b0e1d5d  release/kernels/cas.ccvtrace
c6b3cf3a0d7077da5259e3566665a500e55a60b2500eda26b2bdfef2d8427b41  release/kernels/cas.log
0ab31a9443336fe5d08e1a5fa5fcba3bc279b19022f7c5007908d39d8ef39536  release/kernels/cas.oracle.jsonl
b90a90c6429213cdf304335af1cf7d175c091d68011602ce4e9b163f3bbfaab4  release/kernels/cas.sv-hosted.log
274b497711e8b8f5a32e7dad7503aa8cf934ba045c58125dbeac09cc937cf266  release/kernels/chains.by_instr.json.gz
c2ff38f0d0e7ce0534068beb05261a84d8ac2f3675e2d05e1bea204ec0b273da  release/kernels/chains.by_unit.json.gz
f0ad6748d7e0809133787f5d672363e8bae7c700f2aa200f9cd057ad8060fef7  release/kernels/chains.ccvtrace
a6bfabbb9bf680943f7b641ec43a04340b0774378cc3a50b4e948f2839d2473f  release/kernels/chains.log
26a4cc5c5524c7219d8706c2582c80357dea60be9d6ffdec99dac7d0365e2264  release/kernels/chains.oracle.jsonl
14fee6fcfcf157b60c87b0715b476bbb2ddc95ccea439023d5afb0b38f157cf7  release/kernels/chains.sv-hosted.log
24f618495216f1d21d2a47db3cb292eb49db1d8f8f2f868c642fc3c9c57b7f33  release/kernels/coll.by_instr.json.gz
7e6dbcb7dc5e81f8ce992ea8025df41afb4ef41432158c21f0ccd93d4a092f5f  release/kernels/coll.by_unit.json.gz
b75fa7bcc42e58f6bf4fb8cbbe71ed872b553a772affc2eb2ef51dc12c1a52c5  release/kernels/coll.ccvtrace
b39a8cadc87bc32f28c08b9a73c3261de8f11c3b6dcdb04bfd0d4e397c99abe8  release/kernels/coll.log
dd718d23c88df5dc7d92b055d8542865aa0e029118486af127312a8a578cfcbc  release/kernels/coll.oracle.jsonl
e51ea9b95b8e8ba19da1e18466c1c5874342d035451a1313f4abfb8805076382  release/kernels/coll.sv-hosted.log
b83625f86f39dd6cb5c8e6eba7ceb8eb3aff6b1c45dddcf852fa139359306d5b  release/kernels/div.by_instr.json.gz
e455bd1de19a094357f30bb77efdd53f46064038dd8fbd44f192fa45fcb1357c  release/kernels/div.by_unit.json.gz
8d99973e50f9afeb5d145583eb1ce13934a3fb75d2b7f2f5e247df23ac8de41b  release/kernels/div.ccvtrace
d7919df9247d6a0d8fa99dbef73f6afe51fae529cfd37938dbef0fda024c1668  release/kernels/div.log
71a567b85cf85622631490187563de9a5661099c78a590adff4ed0a0c3d24c16  release/kernels/div.oracle.jsonl
084b245c6b7d072a0f85b06eaeada2e81db36a06b1ea8e07d32e0b6b1a2bed93  release/kernels/div.sv-hosted.log
1e6db3d77e5a4794e53d4c6e104232aebc501ec3ca6975a3426f3604fd2fd750  release/kernels/divchw.by_instr.json.gz
72cd0822d1d9efd3a4042700c3129c9f18a44fe5056a551f94b7868c2b502baa  release/kernels/divchw.by_unit.json.gz
b586c3d04326fe6df68acc9c5ca6cf0ef96d2f691b57c37141ca67ab39ee0ada  release/kernels/divchw.ccvtrace
8e98bc61fd8e3606912d8093d549804966389e299e8dde9c498799a804b85dc9  release/kernels/divchw.log
58a541797f7a2df0a1c7528ae6a3edec212db90c7d3eb20656806f38b5c10b3d  release/kernels/divchw.oracle.jsonl
52522b5f499ebcbc5620d659a8f54a9e620ac27710cdaf8dc1f002d180894f5d  release/kernels/divchw.sv-hosted.log
18b555c7a8e31675814488b69c7c04a3561f05ad751a21e87030361861db0fb4  release/kernels/divtail.by_instr.json.gz
485741ec3eee5493c7d501dc73ec27dfc1a96c4127a75fd372747eb6e71adc8b  release/kernels/divtail.by_unit.json.gz
749943c90ca6381984c767ddf1e730d5f0bfa9c89b79f6bc65412000033b77fb  release/kernels/divtail.ccvtrace
677d94b0f55cd660441139fea35d214065419ef1b010e967e033c5442e7c6c2b  release/kernels/divtail.log
75f11a75c9b3b336e446140af4579f05b46c363a76b7aab3ec88154a07ba097d  release/kernels/divtail.oracle.jsonl
c2af059b1353ee317afe6622517337dd7c5c9999ada47dd11052b55b1c971abb  release/kernels/divtail.sv-hosted.log
b9695dc72119af68a9de9d19c329d7b467ed2169fd09c5479419427cc02c96c1  release/kernels/divtail2.by_instr.json.gz
08896f7ec0b3693ae52765b521e6821176f1d480fd45398718511eceb30aa70a  release/kernels/divtail2.by_unit.json.gz
b409d4c368805e11a470d0fc0ba1ea8c8e14005a0119c058a648485abfdf5cf6  release/kernels/divtail2.ccvtrace
d8375bb9de932f1df9be9a1af04b6184b3e9ff0b0a12c1aed0fd2d410c35ff59  release/kernels/divtail2.log
b2db6b05eb6cf4a0a7677e31d0c6c2952d5cab49d353f0bb1883fe0b2a20ed14  release/kernels/divtail2.oracle.jsonl
bfd090824371daab1e950cc96a015b4b808f53fea8b33cf6532b1162fb3bd141  release/kernels/divtail2.sv-hosted.log
89f180ab50b0800e573e41f47badbf93b78a6627d7c18c5029a3ebb03079d5a1  release/kernels/fence.by_instr.json
b458236d9e8fc13d9d6d7dda404ed0b27c48099c4d2eb6816d2f67585a0712a2  release/kernels/fence.by_unit.json.gz
527d7838739ba7af7bdde873fe9e9b17db1d33b715e56ec4fe213a940b792cdf  release/kernels/fence.ccvtrace
b8fd3aa74abdfa82c892f6252498affa357d62a15f5402049641835997e3bebd  release/kernels/fence.log
d1d40317f6cf5bfb430cda1f9c0ef676609e59cabe2a11623c42ffbeca93142b  release/kernels/fence.oracle.jsonl
1a3ae28427293519f73d432f5f38c36c46c03df1892bd51842f659ae9d36013f  release/kernels/fence.sv-hosted.log
cac94f4c71524154fa1171f3c2cfa8dd8015f5a1adcc1847181982589fceb108  release/kernels/gather.by_instr.json.gz
980182c84ca8ba54645b374edffed70de7352953eaccc7e19d3b07c582f59211  release/kernels/gather.by_unit.json.gz
b99395a37af3f9984a8a5ecf1d762e60da2ad9727302b9e2a7b2266490383a61  release/kernels/gather.ccvtrace
2e31806bb0a0a3306396e515d9369e19eccfea6dbfcc7b45240dbf7702db24df  release/kernels/gather.log
0413e781d8d6ff578c64eb1f800b7931e66f676d5cdabb97b94a4033e6037662  release/kernels/gather.oracle.jsonl
7fbe076f71ef44c1acca9447b137feb5708bc05c7a899ab146ef0d25332c64a3  release/kernels/gather.sv-hosted.log
1349b55a98f8d84472529990b1487e1ad4a99e85fd33db64e27f00d87ef87fbf  release/kernels/hit.by_instr.json.gz
ed58e157adb23266601c8a1bbbe33f8934ff8d09e81ba63f0b004e0b9815fa70  release/kernels/hit.by_unit.json.gz
a74b37a23cb2bd91815bfa2cc3ef0e2eda66a061dc4408be84eb9c176a30104b  release/kernels/hit.ccvtrace
8a0af00d41dfe9f95b13b253369c11335a1427a8be909908291919726c8a6ded  release/kernels/hit.log
7ba9603e0088d9164de6528f16ef6a7fa9ce5821c8c12b52cbb3734e39b9fd52  release/kernels/hit.oracle.jsonl
3526254e3f979367029301f884c4ac7ee8f4f1c3b78b26603b54a779941ed53b  release/kernels/hit.sv-hosted.log
c52e4325bcb73bef912261ae95f9bf4d190bb4721fd265ef1d10912de655369f  release/kernels/lanectx.by_instr.json.gz
ca3d793067688e4ee3c453495c4f700e87eb80b586f6d6c573bfb682a60ab9ff  release/kernels/lanectx.by_unit.json.gz
019f350c5b82a674093d01edd79ba4b214a7d9b24cda3eeeaeb7a9dbcad4f248  release/kernels/lanectx.ccvtrace
d551dcca72038197184922378ab3cb3fc18c3e852773864ac686d46985beeb47  release/kernels/lanectx.log
888551babf540db8e3025b82e65ca655013f93eba3c8a65689d069d52a7e6039  release/kernels/lanectx.oracle.jsonl
329ef743e1dbc13802743ef02064ea95dcce8362a5fcd78ecbdd4739aae519d8  release/kernels/lanectx.sv-hosted.log
4e98a4e69618d0a485b391e630cd4f53085c6e021286a8fc32f916c8d0db893d  release/kernels/lanectx2.by_instr.json.gz
5c756535debb5940dcd401bd2fa82157bd0d4567a507fabcf1d257394f51d085  release/kernels/lanectx2.by_unit.json.gz
8e240ee934df5ee507e1a24ca759a52dcef71613c51a5fec463e17d1791418b7  release/kernels/lanectx2.ccvtrace
28e8c3040dd32e765e6e34f7078a318b85e80237edb4622b9e67d3cfb49c8a6f  release/kernels/lanectx2.log
45c13056dff5c73ed0c9ece56cc36f929bf335322193c7d5eb38710b1d1dfb02  release/kernels/lanectx2.oracle.jsonl
50fa115f48bc07105d44165627bf32a9c703ad06d68eb3d4e268846e6fb0dd13  release/kernels/lanectx2.sv-hosted.log
24fa68066ac8db8073007f80199ee6237c243a402a763c24ca77a26667212e31  release/kernels/late.by_instr.json.gz
30ed22ef8a31171389a9b794fa703e51062f65ede2972a93c174ad0126186818  release/kernels/late.by_unit.json.gz
b004681de98ac30f08888801e20cc7e79f91e6d6426dab59c7b23723336edf59  release/kernels/late.ccvtrace
fa5365170fad79e804cf9ee2a59a56438d007da7c1f48ad144c4130f74a73297  release/kernels/late.log
86084f6bd747a2cf32acbc0ebd96ebd3e4ef2d8d9e21be49e3ae49290d7927f3  release/kernels/late.oracle.jsonl
7284ed667f090f9736c1355019a8be53da99ac1f05ac179def9ff671c67c99c4  release/kernels/late.sv-hosted.log
862e99a3e1a16bbd2ad1c40d6598d8e653ac0127abd3e6a67ac4aaf498b7af07  release/kernels/ldpar.by_instr.json.gz
fc3cb77f04e0ebe4028096b9cc4057469af3416d7bb22ee70eed6358b8d5398e  release/kernels/ldpar.by_unit.json.gz
aa2fc2e76a50927b9bab6719b58e1029c0c179ee20fa974c0da734d750de4b6e  release/kernels/ldpar.ccvtrace
9505f34d83863b7dfc23649bb22bfd32d8ecd4eed7011554b840d7581834fb11  release/kernels/ldpar.log
8ac08538e9c807637babd61b31e340f7461878ada31f0c0b83cd66331cfaf486  release/kernels/ldpar.oracle.jsonl
6376f2d6c9c5a1acd09680d152c6f91f5a93c312545f2de0aa589545c1b332c3  release/kernels/ldpar.sv-hosted.log
3998801e587dc5805d5244845651e7180fbbe9a52ba2b19657bbd666d8504b3e  release/kernels/lnorm1.by_instr.json.gz
746920b813be87a7f609244b6217800983a8f27733437f0876ce43279e5c1ea3  release/kernels/lnorm1.by_unit.json.gz
05b46d026bd44afb1b50d7235276d41fe4c810e728c7421df9711beb90d6d0f2  release/kernels/lnorm1.ccvtrace
a2e9db2d56f1adc50dd9a277cfca6e30124a1f369a8f3026a4002603b0453e30  release/kernels/lnorm1.log
a8d85811af988a1b9fc00db1517300af3d93ec8e589e403d3b9113fa9e0ffc86  release/kernels/lnorm1.oracle.jsonl
280f6899f93db912a02f3a88b4c906dcb9ee775ae19a271c9c44b0cd9014eb4a  release/kernels/lnorm1.sv-hosted.log
dab72b9a3f06152ad4b3f7f64719d62133c93cfe22eb75213b9a1c74e759e1b7  release/kernels/localsp.by_instr.json.gz
e17ea291d12f42f2ad4e7822f26d4c26f82fb8c152914da8e987f97b60a752c3  release/kernels/localsp.by_unit.json.gz
d729d72f91cb10b2cb4572c39668fe5dd28872996aec230fb5e116c0300b3c41  release/kernels/localsp.ccvtrace
a0510a72040183d3597ac688417e57cacc35b3fff958fcf39b95fe18a499d802  release/kernels/localsp.log
55e3c9f36e7f7d38c0ddd38903aff4bb4509ae862015c592e6b937ea258042ca  release/kernels/localsp.oracle.jsonl
aa9e480f31d2244392cc0b4ffc1a2e0c1c17b1d8f8e328095598983eea9906a7  release/kernels/localsp.sv-hosted.log
9ced6ffa51e2873064af31f27a5cca1bc751adad67c0b72c5dfc9030611a0e0b  release/kernels/loop.by_instr.json.gz
5626bad8512273e65ee27a12a48dcd2a4d5b240167042cecef0bcf9130765808  release/kernels/loop.by_unit.json.gz
74b9f2e50c9a86a19eb43f81e823c8eec68401f745933b7e2c8280f07eedbfbb  release/kernels/loop.ccvtrace
3765b35721051959e066760294f5310c677fa8ca0914c28b19d5aea8c272be68  release/kernels/loop.log
03ce5920c06c93e93516d8e53c3f7169f14e3593de204eacceffc0b8a3e32016  release/kernels/loop.oracle.jsonl
b4da25c3df61f9e8c14647b1773a9ccf8b5787d008aeceea5c9bf7a64792a3ff  release/kernels/loop.sv-hosted.log
b2241313107a916afbec60beab8dada0ec3a1f515a6c7f2990073f3f161787af  release/kernels/merge.by_instr.json.gz
531727a3f447e590ae218bd7041b67b2e41a67398c903fdf976b96241aae0fb3  release/kernels/merge.by_unit.json.gz
16a07404e2ac320f4a41c6090712201a670d5820c1fec3fa9b2e2b1f5ae87489  release/kernels/merge.ccvtrace
b7c2d3026453b60afbd59daffdfe119774598bc96f4c3d6d8b78f12fba330528  release/kernels/merge.log
f96d28815f8756b1f5a45ded53e6170883d2dfa10f9eef0d14b8050b1318164a  release/kernels/merge.oracle.jsonl
14739ddab9e6a97424912a30b93a515b0c2ec1a1d63a7548ee74cb57628a9251  release/kernels/merge.sv-hosted.log
c953b94f9f2f7778ab9be8910bc74d72dc90001408a898e57c9fadcda647994b  release/kernels/missrun.by_instr.json.gz
bb175091c44f97e7b24a3cafc6002a9883b6cf9c77f0028490df398f3c41500a  release/kernels/missrun.by_unit.json.gz
e0b95b2a02c9c64dc947e737831489359ec7afa20f837d5cb5385f3a4554be2b  release/kernels/missrun.ccvtrace
20ffef0ccc98e0abd6605ba7f18c56c8b6668b7bf04fb1d88044df793f8f3741  release/kernels/missrun.log
531bdaf281e5590774bd2775427f25e4cc0419cf8e3d5b6999843ffe9ef87258  release/kernels/missrun.oracle.jsonl
a45ef908e782cc0d3f4063137f98237aae85c1ac34f960638f21b3061ac207fd  release/kernels/missrun.sv-hosted.log
b44d889942837abdc6d25cbc753a96990a3e0d773ab4b6e55727dbc919b2d6e6  release/kernels/mload.by_instr.json.gz
044e2cccf9bde0b8e13ad8142efb8501d9ecf0dcc9d6ebe28d8d34003d72d96d  release/kernels/mload.by_unit.json.gz
a8d174b478a4b3d1b1664710cf3acd91c711252fb4860893007c0bd40013a41a  release/kernels/mload.ccvtrace
74b7d36c845a6e39c5c1f90c461281c372eb05b0402ad815de689020cb5ef8d2  release/kernels/mload.log
8000e477b9a95dfb9f0af964e8346acb9d36f1358fd06ffc4ff7cf599d2b8868  release/kernels/mload.oracle.jsonl
893addf2b4615e5b8ffea554b480b4f3ccc45e2862a7afa118b2d679970f85a7  release/kernels/mload.sv-hosted.log
129e72918aa3184f2d0dd546236459e8de46352cd4da04f358e8f3ea561f66c8  release/kernels/mlp.by_instr.json.gz
7cf09880486a2e3cda200974a71244a7903fd7a372aecef294d601a87bb8e936  release/kernels/mlp.by_unit.json.gz
529fabf8fb1baa707088f0521496a79ba91f54c538c9a2ffc2c14c07d52d726b  release/kernels/mlp.ccvtrace
991f0502b84b02382619851e83386e257588c0a84b094ddad15f934176400756  release/kernels/mlp.log
138d282f88d56c8ad648a91af0a983254b55d9fa22942c00d47b327f516a6e44  release/kernels/mlp.oracle.jsonl
0dc260e42b6a25cb2a557adfce53dd01b7da8a9f1defba7d2369663aa4fa5c18  release/kernels/mlp.sv-hosted.log
b874982db88ee9b0fa1531517f91f5bda781c13704ecefedb9accd797275299a  release/kernels/mwmiss.by_instr.json.gz
c0b041a9943bdb8ba580ab3291ab2e9395b90dd27496fbd5cabba490e441269d  release/kernels/mwmiss.by_unit.json.gz
e57a4e49ca70cc1e10f290797099f6031cbf90bea00de551bc124c97b17eba38  release/kernels/mwmiss.ccvtrace
50beebc354590cf7b8e71b5f9a6fbcd7454424bc062d14bdeb1ebf26a4d401dd  release/kernels/mwmiss.log
8abe8e8997456a2a6711ee72da54d854b24e20abbdab28e4b7271c0d28418de8  release/kernels/mwmiss.oracle.jsonl
6bd71d0c67756ecc4580c275f858501d0493894ae2ee70633ccc51cd27165a39  release/kernels/mwmiss.sv-hosted.log
9ab9daa5914b58d5f5a32a2554f6932486e0888566a55c7b4ee430a6014679d6  release/kernels/narrowadd.by_instr.json.gz
be431068d78851c7c48a869cf07a18141057dba0c4682ebcd377efdf1c486ea1  release/kernels/narrowadd.by_unit.json.gz
c0bfdc446933b7e543814b458c49f8c90e34d7431b0e29fd1013f942a91d74e8  release/kernels/narrowadd.ccvtrace
3f46aabe318f3a0d59182bb02c5d6897b0f6177f08c2120b68607c86c97f4e89  release/kernels/narrowadd.log
40a2cf629853dd404bb06b4a07e35abde3d12efc13f26ffe28f923daf2994574  release/kernels/narrowadd.oracle.jsonl
4cde0ba724a0bc2a80caaa9b6cf0a007ec7072d77d638a15402a6923136c93a7  release/kernels/narrowadd.sv-hosted.log
8dcc01969947344a824ab62882d3918469460db2ff57b5462be9d0e46a28e494  release/kernels/pgcross.by_instr.json.gz
04f8c0254422e57873c989f423a1b8e2c66d13814dcca7d39f163ec493834167  release/kernels/pgcross.by_unit.json.gz
766a838d10365215d3d9a89ce421fed2ba6526c5ef7046514acc18eddc78aec2  release/kernels/pgcross.ccvtrace
da552950b7bce0e061082cdeadbc1e71168f079b65b39f207be984ebdaf121db  release/kernels/pgcross.log
58aba9ba5ec6a72271191c0249014802cdc7e4470d27491f499a077f17ecc039  release/kernels/pgcross.oracle.jsonl
e6fdb7a0378d1b884e049c8c57464ec3d668e9c92a1c300b26d68c1ccef12a42  release/kernels/pgcross.sv-hosted.log
d8f1fa72a9703bdf489548052ddba82dcabcd26cfb0189b2f3ac815ea69a88b4  release/kernels/pguard.by_instr.json.gz
2ef11ddb3bfe394266546512f2dd2a1661a8d426b0b48641c0753da45cf1270c  release/kernels/pguard.by_unit.json.gz
6fd5d014c3c108d474d24c6b7a79fb796e4279692b33eefb21962f56d6c7981f  release/kernels/pguard.ccvtrace
3a740ffc4ca4a5eaa98190f6412560b4f783c0ae4a1aa9cb43b41acc9690ce09  release/kernels/pguard.log
690e56f1cb8d97cbf67124b7dff3ad0a90cb8981814cd1709cf0cd0e035b3bd9  release/kernels/pguard.oracle.jsonl
c3c8c41e4343d45f8ab60845aec6a934d01f0e9d7ddaf3d48d0809ad58f97397  release/kernels/pguard.sv-hosted.log
e63925e241d2324a2ab4c668c4d6e247e28bc2d87dcb9d1773f87aba146c322e  release/kernels/plog.by_instr.json.gz
e0d1f7bbfe8558999fccc5b320c6e1bb88b3e69020c3b6096aa75155de363337  release/kernels/plog.by_unit.json.gz
e8bbf197bd772c214ea56a64eaa168c48dd5567c595a3865d1b48c638c317196  release/kernels/plog.ccvtrace
058d5ca2c8aba169bbfbe682e6d6b3804654347dfe79a348c25363936da6d7b0  release/kernels/plog.log
0c99915e2da60f4670da00504a6371d7d17701d4431e733a3ff8fa98a2030d6a  release/kernels/plog.oracle.jsonl
7bfd70a8859ec09038459fb70ed01c153863348c6dd0b485e816411c6e7a7a21  release/kernels/plog.sv-hosted.log
aca2b3e81383b6f2e60185820e8d246c869c63cb1e1198352c33811eba4b57d9  release/kernels/pmovdiv.by_instr.json.gz
1eaa4d6560054d2c3cb5a5375a5999f796baea6c151272e2182c6a048e2e68ff  release/kernels/pmovdiv.by_unit.json.gz
c738ef1a8aafb2e2961378ffb44b60776e1aec6b52067efef14fa332b46653ce  release/kernels/pmovdiv.ccvtrace
95b409843aa9b97c9e1074bb6f5c3a3bdba1d626cce1a9234f96de33e5f0b1de  release/kernels/pmovdiv.log
7bc646cff6166a51bdce03d7c1b7209e871f0a91d743083a9b910a80bcd0b33f  release/kernels/pmovdiv.oracle.jsonl
ce81ff705da8459313d23919f313481f8a0489c5096ef70674d94f461aefef88  release/kernels/pmovdiv.sv-hosted.log
335e29072269c6f2d32d5bebad56329db6332a1531266623bd30def0a47a4bc2  release/kernels/predlane.by_instr.json.gz
be9d8a85f5ff1d60e3b9ca86b74c97922679a1e7c8b8d4372296645a5ebfcbf9  release/kernels/predlane.by_unit.json.gz
b484ff674c5d5c62efcdbbf021c53608ad93bce7e109325607d503007afe1f92  release/kernels/predlane.ccvtrace
dc17455b0d57c8acf1cbcae1a1e4ceb065d72fa9a5a2490fcadc6c597dc95c61  release/kernels/predlane.log
c45f4177b9e84fc8a6e36b13534a0c7636eb30a3f8531847100ce5e23bf404b1  release/kernels/predlane.oracle.jsonl
def99173cdec7ad7d82e5c3117d31539719ea53c8b61ee78171bfe438f0e3a4e  release/kernels/predlane.sv-hosted.log
bfc94183e713ea8ddde41190ccdca3c232ec362cd64af5f776acbc5f31d74cb6  release/kernels/predmerge.by_instr.json.gz
3b6a6d671b0cb6855b82538958b404191209f6129db7a3b3618df4ebcca7a584  release/kernels/predmerge.by_unit.json.gz
b19090334b40704b9762155133f2368a5635406f7cec125532c2b7606de91dbc  release/kernels/predmerge.ccvtrace
3da3f91843daab657ebda8556d86eb3ee9135f502e59096e3ca8c12d7a7f3b28  release/kernels/predmerge.log
6c737c49434bcd08e3e0814c8b1dbf15c586ae74f7929ba3148ddcee2c62c845  release/kernels/predmerge.oracle.jsonl
21b34b71fbbab8fa0ef99364029286ebfed4a94aa12f8353d368a7ab3083cbe2  release/kernels/predmerge.sv-hosted.log
783c5982c762891cfcaafbf657ff98771031ef9c21d270910380636618d30730  release/kernels/predspill.by_instr.json.gz
2447cd0b6af6cbf8669ee092dc1be356fdba97db026038d20fd93813cccfa944  release/kernels/predspill.by_unit.json.gz
53f8c25a7b7cd82ea629dae53fed971c3d2043efe6c3caa983d1a22b0cc49df2  release/kernels/predspill.ccvtrace
f431e4dcae3b5165c1cfe5ae6f6e61c6684651ccd03dace13c9eedc8b7420172  release/kernels/predspill.log
b7c84c6478117ffa0f06da0e6ad1e4628e2683426a7911080810e78e06a5242e  release/kernels/predspill.oracle.jsonl
e9614d1f754ef222b1763e1e70dc43618e91e5562206e3463f4d16e471d9e720  release/kernels/predspill.sv-hosted.log
78d0269bca2dfd92fdd6b0dbc2b1b38d49a86c66ebe7da1d742289bd233a67de  release/kernels/predswap.by_instr.json.gz
f38509a54bdb89a4c30eb98061226d7bc0bd1a4f7069a7a456440b09b71c37a7  release/kernels/predswap.by_unit.json.gz
b7799fbe150ad3930e4d98869fcb0e5a6d5d50d70beaf976076f7a0a2f610619  release/kernels/predswap.ccvtrace
1ae2c95728f8573d7acab1f5e3d5b0640b754e6d2c9ce44ae6d4700af8fecdc9  release/kernels/predswap.log
a6d4f7ed517553816d889c7c9eeb6bcfd1f6c973fbf682ecb69f3c2de619f7bb  release/kernels/predswap.oracle.jsonl
2b33945bc57051b94c020c657aac37c5bb9413669be1833256b92aaddd9caa90  release/kernels/predswap.sv-hosted.log
d7521fbe05bd1f7079f6f75d7c83201e62abb8672cb686798d1802b367c699b9  release/kernels/privwin.by_instr.json.gz
1e4a35b33bf0b275b967f80a6daafa5720d78823fe02e70850e29b447e58b719  release/kernels/privwin.by_unit.json.gz
35895703a6c78660094f91b1d65e3b2d7c5e0a7fd81c6413683c60102708af82  release/kernels/privwin.ccvtrace
e86e980d7d1258695cc545cdbb04261ef1914f4143251e307194ab406337bd9f  release/kernels/privwin.log
861f686fc4480363472908d679d8815e8c957d768e7ab32c826930527b0fb7a8  release/kernels/privwin.oracle.jsonl
8dde8a32cd7f6738938da21df450efaf3040b449084b1f646814023771dcf546  release/kernels/privwin.sv-hosted.log
07a9e35738db5b165a3224388fc868adc4497ece88eba137cfc8e5daf6e3465b  release/kernels/provswap.by_instr.json.gz
68bff3acaf0427e4a1a096eb236fb232b453a0431b00daa1a4a6352bd409f609  release/kernels/provswap.by_unit.json.gz
4d579672be0b4a1adba204682b5d9bc15900e502a378ec3ee58e16ec771ac95a  release/kernels/provswap.ccvtrace
e4ff5f75c0489d5ab17a0d460031f1a6810d9ee401f960563b1f0236cdb4b045  release/kernels/provswap.log
c9c32a793d54cc7401477f582487f7e8b345b2669a75337b8d6327120d98e5dc  release/kernels/provswap.oracle.jsonl
87b081e8adadf3a6388e140b473250ebc391f00edf91b844f0309a591e9457fa  release/kernels/provswap.sv-hosted.log
ad800c0ee7e6f1efafd3ee84d2a48a71d2e6b8d184717be41b48c9de3506d6b5  release/kernels/retmiss.by_instr.json.gz
b536b06fd87bc2e36c25101a27011acfbf2dd63e3f40f61ceaa2e57289097eeb  release/kernels/retmiss.by_unit.json.gz
02c50e62284ba5c6510254c43bae6d27c6bf72c98f495f3c1a21a6f574fd59f9  release/kernels/retmiss.ccvtrace
f02bf819fd7a822b264885666bd83c3a95ad0f29dec77452d620d99c71f26468  release/kernels/retmiss.log
e5ef8538e838c6cff7febfc679dd091cf5e002f82d34f1009b1948ce22bc3649  release/kernels/retmiss.oracle.jsonl
49eba81dff4bbcc16f1cb36422fd1b4e5e0022b6c43234ca48b606e468178fd5  release/kernels/retmiss.sv-hosted.log
bafcc75269772f69cc6a89e833b1e3e5b399a536121b9889709f78e7d8405a09  release/kernels/roconst.by_instr.json
ecae62f001689d6db6b667c7a567866101d63dad7f57abe73e77862a9706c35a  release/kernels/roconst.by_unit.json
3041ab5bc88dd35be6c67aab1ef4b9b67a454e0f17914b2060070ef5da3c7a7a  release/kernels/roconst.ccvtrace
f1e18c76b28ff1b33105798a03685ae77da610e7d7d18aeffd4562076416c6d7  release/kernels/roconst.log
8087c0671de620162881aecd38cd6114b78e7be6bd71201e3ec02c9a2e2e750e  release/kernels/roconst.oracle.jsonl
cb2e43779127d4014a141fa04eeaae7429ebc56afa3eecc7062d65e091f8f312  release/kernels/roconst.sv-hosted.log
d7978a58a9ed70a2859d2e237a1c2df9e1074d1aa9de5fdac2bd9e9e4e2925d4  release/kernels/rogated.by_instr.json
746808be5f4e32e61fc260cad40b18f3d645b3d81fa183ee9bce434a25bddd1e  release/kernels/rogated.by_unit.json.gz
639e5aa87836c9ecbee582674b45dd4dbfd620120a21851850be5588a3cc210e  release/kernels/rogated.ccvtrace
356090631bde4c2dfc9af586b2deeef7d4db4edcc7ca960aae7e8ffeb14cc8d1  release/kernels/rogated.log
7cd02bd4cceec5a044d6b4d6a80df1e68ed0ae71b0b2a953143636d5b809ea6c  release/kernels/rogated.oracle.jsonl
505b7dfbc98e95e73c33dd75d703409a75a3a699810cd00f6012b4f43bdfdb63  release/kernels/rogated.sv-hosted.log
88b8dd1e831becce756ecf6a3e8712183d9a83b1e6bf8355e8b7d2f9008b8d57  release/kernels/rokill.by_instr.json.gz
bd751ad93af9049a4152dcf72389bd16ea57dd391bcd42964a6f51826bff36f1  release/kernels/rokill.by_unit.json.gz
252fd85df65ee93e64807728cf2ef8498904136f76bfb78a413518f04203fc21  release/kernels/rokill.ccvtrace
18a673e5f8e05c0e44553d606e892a7947213c968715e773066b99c721be8a7e  release/kernels/rokill.log
94efcef96af469a512d346ce61623980fe86383188eaebd55120f716db596f14  release/kernels/rokill.oracle.jsonl
0870644314acbd600db3277a1026570424f9567e57ce654ce0ef33ba9f7f6a9b  release/kernels/rokill.sv-hosted.log
8b5ae21f3f2d7b3530b271983452e98c99a1ff2d7e8788198f22cb30aa8bb93e  release/kernels/rokilllane.by_instr.json.gz
a4d87193da1928171a8b51b8e761393f021ae41074e71dfd79bc597e0ef2b360  release/kernels/rokilllane.by_unit.json.gz
18457748f3a10ad45348d861e2b0a155dc57d06d8d4be65691596aae62af46cb  release/kernels/rokilllane.ccvtrace
e571f89dc9f1d7ceb26edce6ba171e937c9933a63c4e322fdcdfc67183010954  release/kernels/rokilllane.log
f5ca6e666eff2f44894df74a291b43b3c0e7be0a63a47d795fdefd7b22016f45  release/kernels/rokilllane.oracle.jsonl
1c0f68cd2f8f3ac31db5aef95dbd7aa14fdd7058c2a4ad01c0ab4dd02f5dc632  release/kernels/rokilllane.sv-hosted.log
fe81a58560151c8ff253f74922ca0066dfcc0d03b906cc7699ef32f75adae23e  release/kernels/rolaunch.by_instr.json
e67038adcabf20bc2e751707128a879d3339930fc63ef2663c138c8c777cc1f7  release/kernels/rolaunch.by_unit.json
cdb1bfcd866ec71dc9af6efbf59373b10e5aa2fc42298fc5040b4fd17cc1af99  release/kernels/rolaunch.ccvtrace
226e929e77b439095e52ca77cd6dbb2f25431ee27e35de96b6e2041abad785c8  release/kernels/rolaunch.log
e7dad585c3e70615de04330fd03f4f282c29a005dc1732a35655fb261d51139e  release/kernels/rolaunch.oracle.jsonl
a5d17941a182de59c1ac56f97cec334c533def2ad1e8203210fdb30cbbef5f39  release/kernels/rolaunch.sv-hosted.log
bafcc75269772f69cc6a89e833b1e3e5b399a536121b9889709f78e7d8405a09  release/kernels/rolimit.by_instr.json
864284d58733a808e1c266543cafaca40d5b353cf78d1f81075dc2a0e391b8ca  release/kernels/rolimit.by_unit.json
e74d95d8ef33bac3ece62941eb325714edfbb227a54dd5a1df1688138eeb7aaa  release/kernels/rolimit.ccvtrace
21205613e34c1fec0627c636a789ae047cb64c37b78399c19a0ef571b8f53c01  release/kernels/rolimit.log
1c5bc0cb8e8b2e69505fb5a551a16d5d10c56f232b88da7a27e336ad7d962de2  release/kernels/rolimit.oracle.jsonl
f350d007184fb0fe23fb2d2004372b54ba20d4f54aab19102c0a16cb4d753e8b  release/kernels/rolimit.sv-hosted.log
c13450c8b9c9c74a73ecc1d884a4102e380e7985797ab5efec7584307556c9a4  release/kernels/roload.by_instr.json.gz
a7e4a249337abf8c54d4af38ea3fd856a3ff75056ad5d8e8aa5c3d906a9f987c  release/kernels/roload.by_unit.json.gz
e9fc03480273c1c79f8c397c62177035ea35b4737f406ad1ec3d420c7d6eb54f  release/kernels/roload.ccvtrace
549c900ab24e6c4933fa61064574e9d1ff46f97a368c49b1dbf0ffc56b436309  release/kernels/roload.log
f7c1309cc9764769fb5803f6fd0f2f5e1eb418f2d23fbe5e17cf5f9106869fdf  release/kernels/roload.oracle.jsonl
43a4dc9fb61746fd5958d3ac977f6721fadcbc77b3254b3675ba53c601b78b3e  release/kernels/roload.sv-hosted.log
27b8a50f0b767468063705883bf200e8f48c677e09d28641b8d5d6dd4884c32a  release/kernels/rope.by_instr.json.gz
9dc8fd7fa6085d9f230bfd55c5d415d6c7dbf3161a1728b7335438694be7aded  release/kernels/rope.by_unit.json.gz
14829181e04e3828c82bed6845ec8488544d88bb28c2819ebbcab737b1c21273  release/kernels/rope.ccvtrace
1d9169edb0b3f3fb2301a4df0e30ba0d19fa1c6284a2d18b6d77ed42c3e62a02  release/kernels/rope.log
d55f9efae392dc8877c102c01c0810e7654b666b6ede386328108164c6cf88f3  release/kernels/rope.oracle.jsonl
2fb51270c6c976e6c0ea79dfc4e276e0ddf3036b3f55f646cdf1cb4a62e8fa06  release/kernels/rope.sv-hosted.log
6e4a896489d331bc0dc8438c57ed0e60f37a3f40c1fc503aff9c0b78a895d19a  release/kernels/ropediv.by_instr.json.gz
0d341ca452469ffb56613702b5ec67c5fcd3323a3feeda8d42f6903144280109  release/kernels/ropediv.by_unit.json.gz
1925c339d6c2c9ab9c85c2492ff798158f40a7aef3a19801e92b9328ff3266da  release/kernels/ropediv.ccvtrace
c8409b89121c67f234ed1a8e7999839431a61d79ef642a4eb531b76fc079c8e3  release/kernels/ropediv.log
10c0ec6ec18b7b44638c790033109198c079d07c1537bf193353ccedd00a920f  release/kernels/ropediv.oracle.jsonl
5f824f573abb6eb294ada4328db2c6da9d71c389ddc7e8f1bde91ce8c7d7ab20  release/kernels/ropediv.sv-hosted.log
a9b063d7e4491b2c431797030f42652210445a74ef5747d08c311bb4e4e8d11d  release/kernels/sel.by_instr.json.gz
f18a22e7048c0962839b5dfede9ff2622a454dffc2d73fd69f2c12dee94b9b4e  release/kernels/sel.by_unit.json.gz
acf5344b353833a01a9fb4ee3523f673eeace199c0ad663a8ab6b392886c1c30  release/kernels/sel.ccvtrace
31398647de798ca4fc27f40a93d5ee413fca6aabf6d7b1efaf7ccbfff556ae8b  release/kernels/sel.log
87f6a81e8afa004c8039bf2f61c90176fcf29ab29bb17ac44aa016a5cc8438fe  release/kernels/sel.oracle.jsonl
fb593ef45bfcc7e0eca485e1379209019763f9ded30850a6787d93487917c62e  release/kernels/sel.sv-hosted.log
0eb9f81d403a9eec99762e405b1e67e020d6d549e8a5c1f3659f501de8a2bde5  release/kernels/sized.by_instr.json.gz
2a9a7fb742d1611397faf0e6d8053a992be5f0ec5848b4c02fac483179083d75  release/kernels/sized.by_unit.json.gz
992c8e7a3e8e0239f20f021cabcfd4bcaa3d7654b433b0fd800946eeea48dca3  release/kernels/sized.ccvtrace
ec4d252102ead2e70de8cffc3d750aa1f6edf83ca4d4e2eae523c718d8e38529  release/kernels/sized.log
36d903ba1618bd1faa437c9812a6ee6c0c966a63196c796267d74bf2695ebc3d  release/kernels/sized.oracle.jsonl
3dffab38e44c6f2cce49e31fdeab2abf1bd5f6ae0d610c73841a2d6a8042fe59  release/kernels/sized.sv-hosted.log
840ef9047b392232ae86b5eeff0e74c0db8eb1c48da2ce5a6dc833cb9c0836e0  release/kernels/slotform.by_instr.json.gz
57b0ddab657735f2bbc123f9c70f7e597ba0e1cb84a88b395d185a4ec8dc4a9c  release/kernels/slotform.by_unit.json.gz
be84a5aba5dda4c4c31728cd270f4210d25b76cc8682f9e954fbbf12712c4a24  release/kernels/slotform.ccvtrace
2bef212d9e1a9fefdbd259176b5ccf9e6b69b34a4d1a6e62f9c7d0ea4233cf51  release/kernels/slotform.log
8b61db7419b18cea8a646fb628218447e72e84a18a9891ffb73b441736138ab9  release/kernels/slotform.oracle.jsonl
111f76288437886dd1bb4376cbd94fae7ee38bd9889730b195bbf91510f26d3f  release/kernels/slotform.sv-hosted.log
819c2b9bd0eed3dd9761b7836bc50548523e0ba4e7173db0d438b65dd0384c8c  release/kernels/spinwait.by_instr.json.gz
0cea8eca4f24ca88559c7eed7469af55aad5d4682a9cc46e3680f5471c576904  release/kernels/spinwait.by_unit.json.gz
277a4a18697dad1bb63695b1e20e1536e023b96c1d34bc22b0a8c3a3ef015499  release/kernels/spinwait.ccvtrace
d1a52af44eb49ec3140bb48ac589551907795a69f6bc08366a1f18d07a937f7f  release/kernels/spinwait.log
868920637236c878b33779bd450439466fc3626996a3164573dc11d437d5c709  release/kernels/spinwait.oracle.jsonl
0cb857e2f5a7d7f80930442fbb1cbe8700dfebde56facb9d166385da567b13c4  release/kernels/spinwait.sv-hosted.log
8a26d13c0abc80ac236e2254bf2862025fcbe85f9e170fb5218e3b2e0c17baaa  release/kernels/spmbank.by_instr.json.gz
e9b4787597b7a2287105470b21f91c05c64b00525298acc02baf7690b3943985  release/kernels/spmbank.by_unit.json.gz
febabca872eb01a4b7c0cbaab7a0876f5808df2426c9d1583a9a2c252be96285  release/kernels/spmbank.ccvtrace
4bc11f12bc653af5a0dc67bbeb0e3988af7ee42026fd8f1418f78d2d4bf431c3  release/kernels/spmbank.log
3af490cc37d7a92dbe719b57de216b648536eb301ff9d13de9a39f50d150d725  release/kernels/spmbank.oracle.jsonl
5c1173eba27713be55ba96e80789ddf2b0f3a5b73cc85cbfae06790e3e344e76  release/kernels/spmbank.sv-hosted.log
766fbdfc7c71548ef6953cd508e8713308e1971ccc60f036eca55cecf4fe5053  release/kernels/srd.by_instr.json.gz
c6a1b3649c22d953de1bc47a8aa1fdaf125c6b9d190f5d35feb06ca37708d398  release/kernels/srd.by_unit.json.gz
369a7ac6ca2cac89fdb22b1fd41e570bf73c41f665e14a6f301c395d78c1a4d6  release/kernels/srd.ccvtrace
13c265707266560522348ec1f354a67170be06a065f067aaecc8aa9cd40db9a4  release/kernels/srd.log
b08eb5e3673cac7eebb8b72af5ed3783c8e70a9e96592e76bf3722551bc79473  release/kernels/srd.oracle.jsonl
69acbc67863f074b5d188b7caf3c265b40f48bd6b86ec93a92c0bc37c4aa28bb  release/kernels/srd.sv-hosted.log
62c5ae786004c72955e9ff773a671c564d607713473927337ae9efe4a7efb183  release/kernels/stall.by_instr.json.gz
a676e27027b4f09dc0414d82f3107504520e29f617f17092b3f1b59feb93f3b6  release/kernels/stall.by_unit.json.gz
2e93fe0f28b44df41319cb9df58eb2361839b71647a7c5f7e62d6db2804d6e89  release/kernels/stall.ccvtrace
9b252e8fd5ccd491b62b10a532858a55d20d1431193d850365dcb7c6e52bdf6f  release/kernels/stall.log
500db2c482b07a0706583422cd68878301d0146c1f872ccc1f11bfdcf5c993ef  release/kernels/stall.oracle.jsonl
91bf233e8a6fcaead7de577c69bd447ce446db7a001b5e4434e9e2b113286014  release/kernels/stall.sv-hosted.log
f2856fe2a5b7531e332c649de1f3a405a6251e75d3e7d2e68250d28be5e91bd1  release/kernels/swap.by_instr.json.gz
8118aa6de3f3500d2001f83cb1d3cafdd3205dcd58747ad59ba4c356cdc36233  release/kernels/swap.by_unit.json.gz
4f99621184f8e20f1ce293a7892bc7e85a0cf2fc52318f71c011e665e4917ccd  release/kernels/swap.ccvtrace
9eec949efacf2118a437caf774b7cc971af0a4a280595eafed7ad83f3a1e42a0  release/kernels/swap.log
3658a26316c1ff7bc1744304a42f736e930fcde2865c8913e6cc67a22ce96667  release/kernels/swap.oracle.jsonl
409b5148a25359fee80b62e49c275deb1e27514ab0911a7a006825c201f87b48  release/kernels/swap.sv-hosted.log
dd306f61019eb54d77341d691054b45ff9d0de56188b39158cd1c99fd790e6fa  release/kernels/transp4.by_instr.json.gz
97e0a6b901429165cc5397f6828cda69fefb8a008e07a7ff9c7db6bb4733b3f3  release/kernels/transp4.by_unit.json.gz
2ee16eb17dead12146378f4ccadb227ea4487e321af9ef1410b690fb45f7126a  release/kernels/transp4.ccvtrace
6c318609a02200da159ac5dfd8b43ac7ac2dd6c7a95a00814543e7c280190b56  release/kernels/transp4.log
06396ace3ac19677fd39c700e408606e5bdbacb24997d663bbe8872e63dd74fc  release/kernels/transp4.oracle.jsonl
217638b91ab84af016aad9d010b016431160adb47d738f39b56728842e41142d  release/kernels/transp4.sv-hosted.log
dff5a41b7eea2d8d15b794f008602f66d648cd6453f267b7145a98737e5c9198  release/kernels/unal.by_instr.json.gz
a1df57b9d71aa45a7db15829494f01674aedafb8041d7fcceeb92e17df5640bc  release/kernels/unal.by_unit.json.gz
ba611dde8556689a403a4509b9c9ff897d38b9c173cf4bd4ac01d10fb19b8b64  release/kernels/unal.ccvtrace
0b1b4073a52e2a7ce0fd7582ecbc857e3ecdff63ec9f3cbbc51f091582590b96  release/kernels/unal.log
c3d484bb160657a563df983d9a2532eac27f556636617960aa1e72183ac2b299  release/kernels/unal.oracle.jsonl
20103c47e65471752447f150e9769d0c88f1aebd97cbf7e28191f33728a43811  release/kernels/unal.sv-hosted.log
c6eb2428431fc022290ca1c2e35f26367a128e64e5fa9f50475e5a39ef4ab403  release/kernels/vadd.by_instr.json.gz
5594e55e9f983f96af01df46e29e109e63671a0d62b06edf4c2bf2e23454b2b5  release/kernels/vadd.by_unit.json.gz
1da80e2eae0492a2823f171859a32d0ecd84580f6801dd19a18ff90154de5644  release/kernels/vadd.ccvtrace
b13f24a3c7a6d4cc4b62889b6a85e56df3a75c62b0b366cc0e27c355ee29335d  release/kernels/vadd.log
0276b6d0611a4bbcdc004ab3987214aea138245bc7217504147331689a9c0880  release/kernels/vadd.oracle.jsonl
da09e549c492b878abf7d77b98f245b3ad4a6785497166be2bd1f18a5379d3ba  release/kernels/vadd.sv-hosted.log
486957505590bb88b967878124aa4c54ca8847d6c918dcb14c156d89ac51e767  release/kernels/vadd4.by_instr.json.gz
5b326c8c0d4ecbf82778dbcbc799f6863c59bf78bac1333752d1f544943c5b1e  release/kernels/vadd4.by_unit.json.gz
711475dc3c022d70e146adec377d74442c56a0dbbec408fb3361bf548cf7c47a  release/kernels/vadd4.ccvtrace
c68d648afa47ec6c6dff3e93c24e2556fe63e048accdee5ddba730d083d20476  release/kernels/vadd4.log
225aa18fc9f38aa9ad615aa11de254337d59fa705877553d873062c68366e0db  release/kernels/vadd4.oracle.jsonl
e361570d8634dfe53a3da9396452a0be439fef68521e398333eb7f465cb4652b  release/kernels/vadd4.sv-hosted.log
ebaeff166732a382b4b143c6668911de78898d314211ecffde91174253f86e21  release/kernels/vadd6.by_instr.json.gz
dfc8ba8997161674b193b2416ac964d3e722c6f65dda194210bfb5d5b6a84ed3  release/kernels/vadd6.by_unit.json.gz
a367c4f27d1fe8a2fdb0b104749d4368d1acdbbf0b87fcaf106f711a7ff1672d  release/kernels/vadd6.ccvtrace
296722180e7760def2bd9f22f481138bdeeb7f4c2cc5003311708cdc10eb0ae7  release/kernels/vadd6.log
10335385a8b6359c5e8310565561a4a5febfe318ef4ea0a6e537be2d372c54f4  release/kernels/vadd6.oracle.jsonl
1d292d4eb77e27593e67d6ed4a76409b76b76c2f4f015f77b44c7e366b119dc3  release/kernels/vadd6.sv-hosted.log
e89014a5fcdb6aa79ca2fa26e3d19e34891d67f99ec79ef4966987ea5e8019c8  release/kernels/vaddslow.by_instr.json.gz
ff80293147556d33b06ac65a372283818d71ffcbb954a019a68fc02e5e61f17a  release/kernels/vaddslow.by_unit.json.gz
1d25b61a639423d3208303a38fa45cce6c4bf5b44ee8e0061c5e0837696362e4  release/kernels/vaddslow.ccvtrace
ef3d9b3096f853f04af2d16f3bd637056af3d9227058eca6732a40857e380a78  release/kernels/vaddslow.log
e9e6218e8b8450e9f9ff6b39d659c994a1e51c527a0c5bd10d18b5658ae0e344  release/kernels/vaddslow.oracle.jsonl
ce26a6e982f8559fe9211e1d4b844dec21c70783bfb9b659d465d7b00faee16c  release/kernels/vaddslow.sv-hosted.log
08c6987c5efed7da8e8dc1fcb6a3608077609a7e14c5b9c0a1eaf0cadf8c319a  release/kernels/waypred.by_instr.json.gz
541eeb707feed52d3af6da80c86cb3589c09f6fe949b8ea602032728080b2434  release/kernels/waypred.by_unit.json.gz
9c99928fe20da842a9d703185b3c074bd001b51026f8b108b537b557c0dff703  release/kernels/waypred.ccvtrace
567d8f15b8cf30875e5e48c4e2238fdca83e2d720d5bd7e8f6f8bcbda3567f44  release/kernels/waypred.log
54fb803ce85c4458b8687bb0f61adc32a9d798448b914b06261dc49c2bb841c8  release/kernels/waypred.oracle.jsonl
1de17a5a0b5c4b574bdac0737bec4eb7ac6224292166ed959b064ccfe8993725  release/kernels/waypred.sv-hosted.log
bc4385032ee98d4f98f47aaef44d658c45e67940fbc9a1ee1648ebdd863bd4ad  release/verify.log
f78197fa73514d4391564b6dbfda61c3c03a38e2134c9ddc2d24180f29c72e6c  release/wiring.txt
```
