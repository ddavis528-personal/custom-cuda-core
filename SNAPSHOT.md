# Snapshot snapshot-2026-11-27-db54eeb

**A generated, read-only snapshot. Do not edit or merge it.** The source
is `ti-rp` at `db54eeb6b17927d715b4e27d9294a6926c41d92c`, and this branch is rebuilt from source by
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
| Source | `ti-rp` @ `db54eeb6b17927d715b4e27d9294a6926c41d92c` |
| Built | 2026-11-27 (UTC) |
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
d18c0a58e2fba9b99480d05bca76a76ae87d15f6717c3db323de0b242176108c  release/kernels/addrhigh.by_instr.json.gz
f2157e4a535e0aadc3a314656c2c1495179ffe8c2f25d9acd5a7bf90099214be  release/kernels/addrhigh.by_unit.json.gz
00aa9f51998bb9626c92b99976dd5d7c69de3f61b760968761b82ec90c505a5a  release/kernels/addrhigh.ccvtrace
8c262aabc8513395c961334a556b06e348c621684229fc08f8fc027aa6c8763d  release/kernels/addrhigh.log
569f2e22883fad5f0956c57ec734e6afbdd4b8a854e50277425172d6c0cbd766  release/kernels/addrhigh.oracle.jsonl
eb9f1357ec46f7efd7c9be168f2e8bbb355f4fd52ba05b6fcbf073a8ffd9135f  release/kernels/addrhigh.sv-hosted.log
6f10978c0d2bd2310db94413467c8192cf3405769ad19e4433cace98a196a795  release/kernels/addrlimit.by_instr.json
c9b8824ec76c0493a6e3f51a0c5aaa410581aac6b011c5157178ba5a2a4f4d1d  release/kernels/addrlimit.by_unit.json
020fba3b967ac88b1009f3f689ec377a7d962cf63f31f9c59ec8053ae96508b2  release/kernels/addrlimit.ccvtrace
04cd9bd6f29f252da5ad16964569447f02c30125978d852c4709ae3e9f9b978a  release/kernels/addrlimit.log
bc660b0b40359a2c5a2478cb0eb4950b73fd22db50ea76b80052bc195a1920f4  release/kernels/addrlimit.oracle.jsonl
069dcdc2752802472310097bb522ee1d1d6902d811612f11cab9a4ba255e7c07  release/kernels/addrlimit.sv-hosted.log
10f790f623c1988a4a701b2ed1f204612448086208931a7456e0648c455e87a6  release/kernels/addrneg.by_instr.json
6cc01cc7db43eefe2161b7fe13797f4b45c7b10c95bdc3155e57503425c4b5c0  release/kernels/addrneg.by_unit.json
66fe93895419e62fd3c292424e693819bae503553e64c4bc92c6ed729179d869  release/kernels/addrneg.ccvtrace
aa71be9c5be05797bccec2d532ec995965b666f5b35390a91a4a031c83da964f  release/kernels/addrneg.log
16f5b0707ae44492a1efd67bb9dd38a7e79a7bbd354fa9207b9e7d150ff2f107  release/kernels/addrneg.oracle.jsonl
dd7f87635015a7f103aa47dd5532ca600c9de8e91bf2e134907c5f421cad67a3  release/kernels/addrneg.sv-hosted.log
4e2a82f56efec3f0c7a85f90da7883c98512d488b41a01d83562225b8d92e0eb  release/kernels/atom.by_instr.json.gz
3f135f8634c1d61ae7deb4d38b0776f659e7a08f4973db4e3d96bdb1993e1a2f  release/kernels/atom.by_unit.json.gz
66317cddfd6e2c68a4fe4a7ceaac59358d16c75f4c2e8f6d47e23238287919da  release/kernels/atom.ccvtrace
2bd6535582e3abd3439cd60172d98616640734337f207f1030885d7ea49cf5aa  release/kernels/atom.log
504f5b6e9d25114dc35f2c70b21bb7b3f3c508c691de12dc0e87d12a74285361  release/kernels/atom.oracle.jsonl
d92dbbdb2a8d204e16378b9676b230e9a2106f211b4c4f2b22a2672b7e76c715  release/kernels/atom.sv-hosted.log
20ceb323aec463738b3782dca50d792bb49720f45dd1adfca87a7d53828fa4bf  release/kernels/atomf.by_instr.json.gz
c10aa5e9c6e5095e9757bc37a3bad81d390225578d201c9782f29a14938b887f  release/kernels/atomf.by_unit.json.gz
dec336dba4dda0da039100750f613725d07b5a6c61bc703bdeccafd4266ed5a7  release/kernels/atomf.ccvtrace
d081e212795172a533425bd1c5fe9bbd6378a0b58ce16d803871b467018a95ca  release/kernels/atomf.log
cfd1179edf4061a33ab2f75d7a6dec61decfe629000198189a7bfc2647b34238  release/kernels/atomf.oracle.jsonl
10465abe4ab6f28a9137a1ea078cf6b319cf98525790991da5794f4f9a686505  release/kernels/atomf.sv-hosted.log
257c28f368a2206cb5fb3882acb77f0c5ecf6d2b3daba8f86f64ab49518fac21  release/kernels/borrow.by_instr.json.gz
c9da8caedd786725b5c11505c2803ddd926f57a0e653f3c4d99e18dd8f632ab5  release/kernels/borrow.by_unit.json.gz
c162f4ee979318135abee3d266de57454e5bb84ab973a74730ab811eb7e245d6  release/kernels/borrow.ccvtrace
4a30435ce7a742f82fb025f57f8683b4f31ba1d9ebcf60f1010ee961715b7c50  release/kernels/borrow.log
4c565e1ce0b3baee36e158694b32c8defb5cd662b2f9af75cb5d8c26cb1168ed  release/kernels/borrow.oracle.jsonl
0bb80a4b1b724e6eb623ea7caadb59619fa6e73a45f2e46fc5969696e979e5c5  release/kernels/borrow.sv-hosted.log
ce097eda3492b60222387de28a24ffb4858f44efbd1a0b07b494e1883cafc0e2  release/kernels/brs.by_instr.json.gz
bc5dbee19f55aede58af26288555e3e9e3b3d10e50d9e89bf1d3ce7888912a92  release/kernels/brs.by_unit.json.gz
dcae433e5ec770eafe8f8de176cb5e74dff81f2342d0c58f9f7050cd86f73e51  release/kernels/brs.ccvtrace
598ef73541fe01f4ba9e70f9bfbf9983f9ef61c3167cabd97bafb7a2168ef3d3  release/kernels/brs.log
e3c1cb3379580cf1aae44e8ddc8e846ef6fd661a573cfe0a8d4444b18a14dc56  release/kernels/brs.oracle.jsonl
16096b5b6b832852200b7e39cc0c20fcfb206629759c9d80f7a562568499e940  release/kernels/brs.sv-hosted.log
52264ad9a0d64dacf20dc90a814ddbc01b2c291ce357769aa97b0e89848eae51  release/kernels/byp.by_instr.json.gz
7efce795bb3853bed9d12f03eb3b1bc3887afe166ad26e5e636dbfe799f2e10c  release/kernels/byp.by_unit.json.gz
fe3aeae66e69efed04c08c783f324da8c7da50e92863154f874f2b10b2fef80f  release/kernels/byp.ccvtrace
f3569396ba05620d4bd418fa05de2598a51e3677f576038e2587425fbb6faf97  release/kernels/byp.log
5a03dfa4f3603fef49f1e3639e74e34152ca3ca5ef8e41eb959f8323040fa2d5  release/kernels/byp.oracle.jsonl
21eceed5a69ff8c5c2426b7ec0d8818252b688e09ccaf1f99f2861e820c7af55  release/kernels/byp.sv-hosted.log
d8ca8543350c9b7cc98b2a4975dd0186304fae1bba76c20d860a13d49acf2c37  release/kernels/callret.by_instr.json.gz
a4ae766cbe4261c3f12a7afc64de91c277f8adbabd5789b891f2ebc7ad2f29f9  release/kernels/callret.by_unit.json.gz
a634c93c02419e38c904a3e03403f22a4f60897ef7fdf77ad2872956e77a422a  release/kernels/callret.ccvtrace
0a7a0e0bdbaec0105323b92f1d67382c1f446d0c286bdf08e0360a68a7ea759e  release/kernels/callret.log
9b1d1b50b527f732362f837250aa2f26dabf3e76e16a4794856ebd8f105635b8  release/kernels/callret.oracle.jsonl
7519ec8b324798cbb23014befdd9cb0dfbd667f2f0fd6af56a95ac30a0db2479  release/kernels/callret.sv-hosted.log
3e22975e1b81b11c6eb7d42f40d35e107c1360df91a88761cbc8a79ffad75894  release/kernels/cas.by_instr.json.gz
d73079bb4bbb6f5d3dc11acb46787669e50739747499ea04eb97b69677dd8af3  release/kernels/cas.by_unit.json.gz
99847c8ddbe72f92b5286f2292ccba324b846976d7f44f571d7c9c096b0e1d5d  release/kernels/cas.ccvtrace
526e4e0b4d677a9d63dd20ac839f85c4f909860805d3e0396d6f58551aeb5266  release/kernels/cas.log
0ab31a9443336fe5d08e1a5fa5fcba3bc279b19022f7c5007908d39d8ef39536  release/kernels/cas.oracle.jsonl
d731641c04379705db7fe19a2c76e3d4fe1d378f0213f92f32da2048bb0e4525  release/kernels/cas.sv-hosted.log
ddd926a15fb6dfd195315aff548a3b6399b552809dcfee62dc2c413a89f7c7bd  release/kernels/chains.by_instr.json.gz
d1de0649c04377bfaee8c267b6e78f0238ad9dab99d0486e750711cf26a6a25e  release/kernels/chains.by_unit.json.gz
f0ad6748d7e0809133787f5d672363e8bae7c700f2aa200f9cd057ad8060fef7  release/kernels/chains.ccvtrace
311e2e8b478ec08d04a3a37a374e07c1babbd5dab3ac8b3898f5f402ca912e43  release/kernels/chains.log
26a4cc5c5524c7219d8706c2582c80357dea60be9d6ffdec99dac7d0365e2264  release/kernels/chains.oracle.jsonl
7ab97c94fe28156cc89a223a773d5ae14e980c6d4af4dbea0c2a36608a05a0f3  release/kernels/chains.sv-hosted.log
fe3f235c9a77c28e2799ba3b34e2a84e155f9a03777ff3c0471826dd333d0c9a  release/kernels/coll.by_instr.json.gz
eaefd10141128a6fd76531fb05f4b23f49aea37ba5a44f102037816cd6782274  release/kernels/coll.by_unit.json.gz
b75fa7bcc42e58f6bf4fb8cbbe71ed872b553a772affc2eb2ef51dc12c1a52c5  release/kernels/coll.ccvtrace
1f94e8e915b618b415d9a23239f0f437032625e84841192264411dd14c061e66  release/kernels/coll.log
dd718d23c88df5dc7d92b055d8542865aa0e029118486af127312a8a578cfcbc  release/kernels/coll.oracle.jsonl
15fb4a334af95f5700459fa1c4d12e35a6fce834b0e6f93e14c6d41d0377f426  release/kernels/coll.sv-hosted.log
d663b97761307ae9524f1823bcc26c46ccd2481084d4461c3f175050ea96904e  release/kernels/div.by_instr.json.gz
5e4b07219f58c450f67ec58f6f6f523bdd8e41c25d6f107acdf25f967d4724b0  release/kernels/div.by_unit.json.gz
8d99973e50f9afeb5d145583eb1ce13934a3fb75d2b7f2f5e247df23ac8de41b  release/kernels/div.ccvtrace
31709da17f31b5ebe42649ff0c90395209169a4922d52ead0f28102adead6fbd  release/kernels/div.log
71a567b85cf85622631490187563de9a5661099c78a590adff4ed0a0c3d24c16  release/kernels/div.oracle.jsonl
28dd238d56dcf62f2770a08499d0d4d3c34a80c0a8f0dbf1433431ed8b43607c  release/kernels/div.sv-hosted.log
f427df88ebecdf63b25cc991c04189dfcf470838d3a0e0258da0f7af70fcd8d1  release/kernels/divchw.by_instr.json.gz
924c8d9eda748874d02180d8d60d9f31bbe2df5a0c03799fa8900306d9c538cc  release/kernels/divchw.by_unit.json.gz
b586c3d04326fe6df68acc9c5ca6cf0ef96d2f691b57c37141ca67ab39ee0ada  release/kernels/divchw.ccvtrace
a45208754439400a23ee1cf29a342307e4dae92a25807f27ac3a4664ff0e6fab  release/kernels/divchw.log
58a541797f7a2df0a1c7528ae6a3edec212db90c7d3eb20656806f38b5c10b3d  release/kernels/divchw.oracle.jsonl
fbae072d14e87520dc8294910e2a9a2dabb74ad4a98570227e7835a8e7b992e3  release/kernels/divchw.sv-hosted.log
ea4c7735bc2b2a5854ca0973e3d7c60b04b7000326f7f3ff47f4efaec86cd890  release/kernels/divtail.by_instr.json.gz
a6ada2f00e745821102c9fe4003a53b034eede8ea6358b70d135774547e6c17d  release/kernels/divtail.by_unit.json.gz
749943c90ca6381984c767ddf1e730d5f0bfa9c89b79f6bc65412000033b77fb  release/kernels/divtail.ccvtrace
7d253f91f1224853d1b8b6dfb1cef3ca37f03a08b67daaeeca69023e8240cf6c  release/kernels/divtail.log
75f11a75c9b3b336e446140af4579f05b46c363a76b7aab3ec88154a07ba097d  release/kernels/divtail.oracle.jsonl
46f0994c0a8a4ea8bf07fcaac563296e2688eee3cad727263c6ea95f73783eff  release/kernels/divtail.sv-hosted.log
4a2589cda2b96894f6d3275af581617d833be45543c0503a3d8a5eb18eebc794  release/kernels/divtail2.by_instr.json.gz
29fd1b483dbb2d275620a1ae56b668d97c6f57b96a8fcfba54a1299caeb9e786  release/kernels/divtail2.by_unit.json.gz
b409d4c368805e11a470d0fc0ba1ea8c8e14005a0119c058a648485abfdf5cf6  release/kernels/divtail2.ccvtrace
eec17c438b8b0d8b735c00f1edf22ff8736bc598f864aac36d8fec64c38bc493  release/kernels/divtail2.log
b2db6b05eb6cf4a0a7677e31d0c6c2952d5cab49d353f0bb1883fe0b2a20ed14  release/kernels/divtail2.oracle.jsonl
d172ecec138528ab1297a745ccee2af07c7d8a5c774bb736fb507404929843e4  release/kernels/divtail2.sv-hosted.log
89f180ab50b0800e573e41f47badbf93b78a6627d7c18c5029a3ebb03079d5a1  release/kernels/fence.by_instr.json
41db7e68df86cedb0ce31093354629000b72500b4d4c6368044a888b7e0f8f42  release/kernels/fence.by_unit.json.gz
527d7838739ba7af7bdde873fe9e9b17db1d33b715e56ec4fe213a940b792cdf  release/kernels/fence.ccvtrace
e144761a64683d25e879eacacdf2493cdb24fa9366d98a571dcc4f03b56d82ce  release/kernels/fence.log
d1d40317f6cf5bfb430cda1f9c0ef676609e59cabe2a11623c42ffbeca93142b  release/kernels/fence.oracle.jsonl
27c48c203a83408f32772bd2243980aa5fcd0c5876df8ec842845c6dc0956766  release/kernels/fence.sv-hosted.log
82cf2eb284a1c23791d789d0183fb71357187798c6ebb83b676d54ad63593410  release/kernels/gather.by_instr.json.gz
46b917f1003e3f490e3431ffdffee8ee000ab822925799ab5e0732cef22a128b  release/kernels/gather.by_unit.json.gz
b99395a37af3f9984a8a5ecf1d762e60da2ad9727302b9e2a7b2266490383a61  release/kernels/gather.ccvtrace
b88d522e3239e3f69c01714d71503e9c39b7efc46fa518170764c2c87581219a  release/kernels/gather.log
0413e781d8d6ff578c64eb1f800b7931e66f676d5cdabb97b94a4033e6037662  release/kernels/gather.oracle.jsonl
e8631e3759d7c2f804cd5ec28ba3311449fb376ac0699640e57d3e6ffc29d21d  release/kernels/gather.sv-hosted.log
4a26bd848b7cfa0fc3334ec99e0bf0825096818a25899491bc11291abb8b6b10  release/kernels/hit.by_instr.json.gz
818fb319843be5688bb488be415bf0c07723be37ff457d853e6837c2bc71358c  release/kernels/hit.by_unit.json.gz
a74b37a23cb2bd91815bfa2cc3ef0e2eda66a061dc4408be84eb9c176a30104b  release/kernels/hit.ccvtrace
08d22357f2f434ac4b4a4629ba9e545fbfa3a96d4fc8dd9ceae3f8289b315424  release/kernels/hit.log
7ba9603e0088d9164de6528f16ef6a7fa9ce5821c8c12b52cbb3734e39b9fd52  release/kernels/hit.oracle.jsonl
0888575bee1951cc71a55d2fc036fc3f005e53ffd82d503e62ea04f2d232cbcf  release/kernels/hit.sv-hosted.log
1bb4615a306a86d48865f6970393798501dfd10c98da1fc66f35953f49bd741a  release/kernels/lanectx.by_instr.json.gz
da6cf5f65d7633d6c480fe9c3ddb8f64083615e573896eca728ae2dd6b8ab0df  release/kernels/lanectx.by_unit.json.gz
019f350c5b82a674093d01edd79ba4b214a7d9b24cda3eeeaeb7a9dbcad4f248  release/kernels/lanectx.ccvtrace
0421102336d42de90a83fba8e5cd92bb3552a0789c4a23f7887af04cbc9f50b8  release/kernels/lanectx.log
888551babf540db8e3025b82e65ca655013f93eba3c8a65689d069d52a7e6039  release/kernels/lanectx.oracle.jsonl
64df399a8d70c6b0d3a7791850a25af74c8fe2a48c6e19c5b1c9809befe82725  release/kernels/lanectx.sv-hosted.log
de930e0195a93029e663fcc9fd4ccfc806af16626c0f7fc1546fd3aa7e170c34  release/kernels/lanectx2.by_instr.json.gz
46a3afde83d073de2fb0829cdd988110a9ee27be64f5e8605cddd324c96d909d  release/kernels/lanectx2.by_unit.json.gz
8e240ee934df5ee507e1a24ca759a52dcef71613c51a5fec463e17d1791418b7  release/kernels/lanectx2.ccvtrace
95da530e422219e6ca8deb8f1e946eacc657156d7f1f33c515b96f6ad12e5cfa  release/kernels/lanectx2.log
45c13056dff5c73ed0c9ece56cc36f929bf335322193c7d5eb38710b1d1dfb02  release/kernels/lanectx2.oracle.jsonl
3e8ab5b5088fe2236f22df60b3d0a77b52aa3c724ba7f57184fdd643c569ef61  release/kernels/lanectx2.sv-hosted.log
f4309eb50d57f93946ba4d71070ec420bd11dc4e30f254317fc0f1d935ccaedd  release/kernels/late.by_instr.json.gz
c7f9054b147b705c953f4f218d128e5601080a844848d05a5bf03eb0167d59e8  release/kernels/late.by_unit.json.gz
b004681de98ac30f08888801e20cc7e79f91e6d6426dab59c7b23723336edf59  release/kernels/late.ccvtrace
35af91c8773d23b2f2c3a12ffca2fe028b38bf48ca664a0b4905d9cd209a0eca  release/kernels/late.log
86084f6bd747a2cf32acbc0ebd96ebd3e4ef2d8d9e21be49e3ae49290d7927f3  release/kernels/late.oracle.jsonl
305f219835e3cccdae59e59c73d663cec69aa309934436a879a7b36cd7a2a3f6  release/kernels/late.sv-hosted.log
a810415477f31c9a5ab043bc139bc391a8c37cd883ba244e6e91817b9e6856c4  release/kernels/ldpar.by_instr.json.gz
e584eab4049b1e0faddc03e4350e750e3cdad51827f57a6b3c3278185034bcdf  release/kernels/ldpar.by_unit.json.gz
aa2fc2e76a50927b9bab6719b58e1029c0c179ee20fa974c0da734d750de4b6e  release/kernels/ldpar.ccvtrace
ca4a07aaaaa02a2ceac72fb1016d90fc3728ea949690c97c9d18586a08459ec7  release/kernels/ldpar.log
8ac08538e9c807637babd61b31e340f7461878ada31f0c0b83cd66331cfaf486  release/kernels/ldpar.oracle.jsonl
dd82a356407880e41968eac257792563f22be14fd3a22b6e6e970f265f896c39  release/kernels/ldpar.sv-hosted.log
21694594f34d88873a95c342fd204f0b36f59c9dcf7e7ebe3f3621a28d12ef6e  release/kernels/lnorm1.by_instr.json.gz
f012e9dc8112ce46be90e0818f80344c32418634f6faaf4b787e1712e12cfe25  release/kernels/lnorm1.by_unit.json.gz
05b46d026bd44afb1b50d7235276d41fe4c810e728c7421df9711beb90d6d0f2  release/kernels/lnorm1.ccvtrace
d7799b034a2f0f6db785e5000d8a12c605e99445e25daa9a45fcebc49ebeb832  release/kernels/lnorm1.log
a8d85811af988a1b9fc00db1517300af3d93ec8e589e403d3b9113fa9e0ffc86  release/kernels/lnorm1.oracle.jsonl
1bc6c23d502c536094a1a91988e9bbfa10327b36f93e005c78112745b476d469  release/kernels/lnorm1.sv-hosted.log
ad7b71d8bf8cc81ce59154a9c308f14aa9db72429410132a95ef50736a86acc1  release/kernels/localsp.by_instr.json.gz
57f190b328469b0d285b84e43411c680aefe9ec9f2e150086911530fdcc2bb2d  release/kernels/localsp.by_unit.json.gz
d729d72f91cb10b2cb4572c39668fe5dd28872996aec230fb5e116c0300b3c41  release/kernels/localsp.ccvtrace
78540e7ebce3cbe543e8953b43634cf1e936805cef5b3ec536cdf9a371202241  release/kernels/localsp.log
55e3c9f36e7f7d38c0ddd38903aff4bb4509ae862015c592e6b937ea258042ca  release/kernels/localsp.oracle.jsonl
410e1bb10c4541c69ff982b150e9f9329ffb2bf2fadc3875e9702e428a0a70fa  release/kernels/localsp.sv-hosted.log
2d60dd7b1e35caa6e34117200268c3860f7f291558f05c7868e39144fb4bd573  release/kernels/loop.by_instr.json.gz
f6cd873d660a3bae07155de19f10699982ee73d98066f1419a17a29303f643c8  release/kernels/loop.by_unit.json.gz
74b9f2e50c9a86a19eb43f81e823c8eec68401f745933b7e2c8280f07eedbfbb  release/kernels/loop.ccvtrace
81034ddc9c8385dd21e4df63ac3c7eceeaf3ec10f44230b6211a4685c313b9a4  release/kernels/loop.log
03ce5920c06c93e93516d8e53c3f7169f14e3593de204eacceffc0b8a3e32016  release/kernels/loop.oracle.jsonl
53963da942a66dd2cb9956299cc932b4f8cfd24cfe052040aee9029a688f3517  release/kernels/loop.sv-hosted.log
30fd22e097d3d7b5e7767eae13811f51a41a78e0413e5b73aea9e1f1925ba879  release/kernels/merge.by_instr.json.gz
4ef99732be6bff3f4ced667008de9eaabe4c41a35b8f8c1ef858fe5607663fd7  release/kernels/merge.by_unit.json.gz
16a07404e2ac320f4a41c6090712201a670d5820c1fec3fa9b2e2b1f5ae87489  release/kernels/merge.ccvtrace
84b6598d4fe037255e54e52a29ee3d9fe151fd9b6c3c18cf07335442ececd222  release/kernels/merge.log
f96d28815f8756b1f5a45ded53e6170883d2dfa10f9eef0d14b8050b1318164a  release/kernels/merge.oracle.jsonl
34d6e56e50df79b649f84d1eaa4c2f649a8dbb02efaaddf5ea2b9bf618937a50  release/kernels/merge.sv-hosted.log
7ee58a149aa1e264808aea7b09ad3f9a7dab4188d5664f714f6a883dedcd8395  release/kernels/missrun.by_instr.json.gz
76ec6e4eea86f87b47026d9be0ac0bc0daa574b8643179eee29c279b3bedec15  release/kernels/missrun.by_unit.json.gz
e0b95b2a02c9c64dc947e737831489359ec7afa20f837d5cb5385f3a4554be2b  release/kernels/missrun.ccvtrace
0cee6d0b229cdc25d2b2e3236e9541ec99317dc4064ad892f7b3d9565487c0a4  release/kernels/missrun.log
531bdaf281e5590774bd2775427f25e4cc0419cf8e3d5b6999843ffe9ef87258  release/kernels/missrun.oracle.jsonl
491b8df9715cadc23c8725490f709512476af77eab595ba2e0dfd965102fbd91  release/kernels/missrun.sv-hosted.log
e051525314a85f361041effe9308003a2adba25767f43789ea87d4e1ca474c84  release/kernels/mload.by_instr.json.gz
edecfecd22f396bc8881d860be03fbbe7d3b671e598bb7a6cc83b98afc7c089b  release/kernels/mload.by_unit.json.gz
a8d174b478a4b3d1b1664710cf3acd91c711252fb4860893007c0bd40013a41a  release/kernels/mload.ccvtrace
aa90e9acfed3b113e9f35d6e3fe2b8430094c44bb4bb92e6fe82b3ffa30c0a40  release/kernels/mload.log
8000e477b9a95dfb9f0af964e8346acb9d36f1358fd06ffc4ff7cf599d2b8868  release/kernels/mload.oracle.jsonl
f2262d18eb7df8329e991f0f961a4394204d1caf999b849a3d93682ce0527688  release/kernels/mload.sv-hosted.log
75ecb95f01aa8b1ea7d4b02a59a77c381746ad338d6e8931cc773127d2155ada  release/kernels/mlp.by_instr.json.gz
e91e15279e8c778d830f8be2b173a7b50d9545d6f570eed96f889a81a679b9f5  release/kernels/mlp.by_unit.json.gz
529fabf8fb1baa707088f0521496a79ba91f54c538c9a2ffc2c14c07d52d726b  release/kernels/mlp.ccvtrace
7077a1290445987297d6042cdf5375a0294f692c8c25564423026d2218442132  release/kernels/mlp.log
138d282f88d56c8ad648a91af0a983254b55d9fa22942c00d47b327f516a6e44  release/kernels/mlp.oracle.jsonl
497ccec7c0faeed182a5dede21e200738433276678f6f5f94d25c87283f21fec  release/kernels/mlp.sv-hosted.log
252a75bf83c931d6fa00faae67cf5b286742ce1b78ebf4d4fe63c38644652b7c  release/kernels/mwmiss.by_instr.json.gz
60431bdb10839709f16f05e4b3440e3db6aff416ee6375b18491038c996f9101  release/kernels/mwmiss.by_unit.json.gz
e57a4e49ca70cc1e10f290797099f6031cbf90bea00de551bc124c97b17eba38  release/kernels/mwmiss.ccvtrace
a61d09437e8fccb515d519111105956600bd34b8e0623f482acfa089cad5e539  release/kernels/mwmiss.log
8abe8e8997456a2a6711ee72da54d854b24e20abbdab28e4b7271c0d28418de8  release/kernels/mwmiss.oracle.jsonl
7ded172a488b35338882214b4a5780ad77b6e5abaa5697bc12b6c8127b45cbba  release/kernels/mwmiss.sv-hosted.log
b8fe117317d9e77f751ddbf561c57dbe5d61e06a1fedd265e52a28f87cee1d58  release/kernels/narrowadd.by_instr.json.gz
6bd171d78f445c8d563c4e11708065be37a22ed8495c3b553d4fcf372de99218  release/kernels/narrowadd.by_unit.json.gz
c0bfdc446933b7e543814b458c49f8c90e34d7431b0e29fd1013f942a91d74e8  release/kernels/narrowadd.ccvtrace
aff869b1c1d36df372ed7d5f73969050107da3ed2d8e6f881b0348acaf3ece2b  release/kernels/narrowadd.log
40a2cf629853dd404bb06b4a07e35abde3d12efc13f26ffe28f923daf2994574  release/kernels/narrowadd.oracle.jsonl
3173e66e07a3c59974a5175a88e579c7debbba8917e9c70312bb669c8f27dc62  release/kernels/narrowadd.sv-hosted.log
5dbb61d51eaa58a60d8b78d3b95666b9d396c314a25d10ea68a8a20c2e90bb9b  release/kernels/pgcross.by_instr.json.gz
26fd6eaa70efb98f6fcc69b4efc70bbc89a904ae1088c6cd0d8386d62d6c247a  release/kernels/pgcross.by_unit.json.gz
766a838d10365215d3d9a89ce421fed2ba6526c5ef7046514acc18eddc78aec2  release/kernels/pgcross.ccvtrace
8c07ccdd007d99d72f227c3fe8b96b8f5985dc9245ec662145c5dc1c19dc8ee6  release/kernels/pgcross.log
58aba9ba5ec6a72271191c0249014802cdc7e4470d27491f499a077f17ecc039  release/kernels/pgcross.oracle.jsonl
de92bc374f0350018465efd245c0c152a7a798466ca588d7f7c974c247ae2ceb  release/kernels/pgcross.sv-hosted.log
6954c6f0f95b4d3fc3225c4016abc984fbbf2590914766a4c232f632e5aed366  release/kernels/pguard.by_instr.json.gz
808c7a3be75f3e2055bd24340227c7a4401584b22e955f60fb2f5eef496dd9cf  release/kernels/pguard.by_unit.json.gz
6fd5d014c3c108d474d24c6b7a79fb796e4279692b33eefb21962f56d6c7981f  release/kernels/pguard.ccvtrace
c3a32895844388cb8a5dc4af79462ae45de412704ef89567ae36d2a317684f85  release/kernels/pguard.log
690e56f1cb8d97cbf67124b7dff3ad0a90cb8981814cd1709cf0cd0e035b3bd9  release/kernels/pguard.oracle.jsonl
860e0e99f97651308d10ba9d9c9cd0fd7855ff3793abadcd1249c0ebc2606b33  release/kernels/pguard.sv-hosted.log
c9d8b4f3fa1525ba151c7822af46dcd78548f2af0f100de6a95f94d3028051bc  release/kernels/plog.by_instr.json.gz
e7e56d3759dcc62cdfb8bcaeb79b54e6f0cfd901867c51706aae23e702f7e537  release/kernels/plog.by_unit.json.gz
e8bbf197bd772c214ea56a64eaa168c48dd5567c595a3865d1b48c638c317196  release/kernels/plog.ccvtrace
5eaa8df32fb8b4e334727d453dbb45b863c439bd3d082905b63113dd92258e9f  release/kernels/plog.log
0c99915e2da60f4670da00504a6371d7d17701d4431e733a3ff8fa98a2030d6a  release/kernels/plog.oracle.jsonl
184c28f76ab8a9f02a6e33191d67fee743016fa61dd8622e49b606f54054a1ac  release/kernels/plog.sv-hosted.log
a8f760571b22ec76bbd9e23558709be4d955d6ca4e2727141248eab0eb7efd18  release/kernels/pmovdiv.by_instr.json.gz
961b74ebd864a4e734a8c2ea2e06d0072ac21713581bf4875dda531ef8f04e4e  release/kernels/pmovdiv.by_unit.json.gz
c738ef1a8aafb2e2961378ffb44b60776e1aec6b52067efef14fa332b46653ce  release/kernels/pmovdiv.ccvtrace
f5111a4989ebcc8900e944a844cd398fb879df0e7a7eca33bec84a8638aeb1cf  release/kernels/pmovdiv.log
7bc646cff6166a51bdce03d7c1b7209e871f0a91d743083a9b910a80bcd0b33f  release/kernels/pmovdiv.oracle.jsonl
2fdd80b4b6d4b8f0abece1e92a1c410817c80067d04c5a70959fbfcb6b77544b  release/kernels/pmovdiv.sv-hosted.log
6ca66558e7e7a4c28d34a5219b5f2c24fbe90d869d37a3e19c6fb91db4551a42  release/kernels/predlane.by_instr.json.gz
707d4f3ccaed54b9c3d28084f38544444427a1d7001d00d58742b6aac1097b05  release/kernels/predlane.by_unit.json.gz
b484ff674c5d5c62efcdbbf021c53608ad93bce7e109325607d503007afe1f92  release/kernels/predlane.ccvtrace
76cb3adddcddbbc660eb9e0dbab4d89776502d6975eb9dbf6cb5ac4d02a6cbcc  release/kernels/predlane.log
c45f4177b9e84fc8a6e36b13534a0c7636eb30a3f8531847100ce5e23bf404b1  release/kernels/predlane.oracle.jsonl
bb6bbdc62b5e6335137b0c0f3e69d2c66f953af073f2318e9c3ecd83c32d575e  release/kernels/predlane.sv-hosted.log
ee692476d95ecc0995011f119ad96605e17c077aa1bee10dd59472609de880e3  release/kernels/predmerge.by_instr.json.gz
379aa1deac6f4836917dc0e0b375da9d16073d7c400f1ebe1b16067f8b2fc6df  release/kernels/predmerge.by_unit.json.gz
b19090334b40704b9762155133f2368a5635406f7cec125532c2b7606de91dbc  release/kernels/predmerge.ccvtrace
6e67bd057e4408ba2769ba6eec6964781d78f053177df492508afbabfa9551c8  release/kernels/predmerge.log
6c737c49434bcd08e3e0814c8b1dbf15c586ae74f7929ba3148ddcee2c62c845  release/kernels/predmerge.oracle.jsonl
924d5ce196acc1291c08c1e5092b2b2170efcdc6b021d01692f684d554c666fd  release/kernels/predmerge.sv-hosted.log
172fe029b4d767def6c40af95cf170795c89af640953e33acd630a1a67573dc8  release/kernels/predspill.by_instr.json.gz
47ec3b2a64985bbe4b712c3098242dae8d023d1e459beb350fe5b8b4105babe7  release/kernels/predspill.by_unit.json.gz
53f8c25a7b7cd82ea629dae53fed971c3d2043efe6c3caa983d1a22b0cc49df2  release/kernels/predspill.ccvtrace
ae0c20876547f727fb67e9cfc95c0dec7051e8b3100c572b9549cafb00483173  release/kernels/predspill.log
b7c84c6478117ffa0f06da0e6ad1e4628e2683426a7911080810e78e06a5242e  release/kernels/predspill.oracle.jsonl
c60d5a8c6fb63969edb9516ed933679bfa33eaccc79c0c41da7eec9c035967f3  release/kernels/predspill.sv-hosted.log
4f03c2bcc2b1a8a06872041773ec64b5812c0f0c80711bfce6171c9c3aa33c77  release/kernels/predswap.by_instr.json.gz
fcfb11b8f2746307631c5814e6f5c05986524310948933398d4369c4100bd346  release/kernels/predswap.by_unit.json.gz
b7799fbe150ad3930e4d98869fcb0e5a6d5d50d70beaf976076f7a0a2f610619  release/kernels/predswap.ccvtrace
f34c67dd3c39609167174d0b8d801e49ffbb89bfc0a43c0504535b76c5fda01b  release/kernels/predswap.log
a6d4f7ed517553816d889c7c9eeb6bcfd1f6c973fbf682ecb69f3c2de619f7bb  release/kernels/predswap.oracle.jsonl
ce23eb5a452fbd885b8f02ed2d55a176e4455eb5327395034f4aa68bf07811f0  release/kernels/predswap.sv-hosted.log
932125cd620e74328a8cc4e34447a3b307300678a3f0f1aed3f4765bb3166b20  release/kernels/privwin.by_instr.json.gz
270fc0e89d8fe0eb7f20f013be5ba327645f69f511f3f624ca5342680df7aa5f  release/kernels/privwin.by_unit.json.gz
35895703a6c78660094f91b1d65e3b2d7c5e0a7fd81c6413683c60102708af82  release/kernels/privwin.ccvtrace
1c2491e09fdca0d3fb69277354da7b62ade5d9b1e0550f24e59913a01034d61f  release/kernels/privwin.log
861f686fc4480363472908d679d8815e8c957d768e7ab32c826930527b0fb7a8  release/kernels/privwin.oracle.jsonl
673e84183137015cad06771ca88fa797f2bfc7defcdecbeeb6bfceaf614d8f5b  release/kernels/privwin.sv-hosted.log
dd289e2c8c21445fbc5e6134cf2300fe949d4ec2bd64e79d5b6e4d9d9353659f  release/kernels/provswap.by_instr.json.gz
e212d197e8d8e50871bdc7aa88481eb1e6d3ea3022107bf344d959366003a0fb  release/kernels/provswap.by_unit.json.gz
4d579672be0b4a1adba204682b5d9bc15900e502a378ec3ee58e16ec771ac95a  release/kernels/provswap.ccvtrace
92420a496671bf319d08668d46ae4d206e548797d92b19ed60ebefdfbe0b0c85  release/kernels/provswap.log
c9c32a793d54cc7401477f582487f7e8b345b2669a75337b8d6327120d98e5dc  release/kernels/provswap.oracle.jsonl
88dcc078a5c0e73a3591165a01a296fefdd09c3d93ad9fedbb96dbb4b5a30688  release/kernels/provswap.sv-hosted.log
631333f4b15967bd508cfeb938b61a18ea2083133ac2fbbcc39d6f3c740801e9  release/kernels/retmiss.by_instr.json.gz
037c3253f0f89074a70e81cb865b7359add86770799472b7f22c7848377ab3f0  release/kernels/retmiss.by_unit.json.gz
02c50e62284ba5c6510254c43bae6d27c6bf72c98f495f3c1a21a6f574fd59f9  release/kernels/retmiss.ccvtrace
46c94037ae257d4b7bf17452ee1f649da514cb81f2d8828ba5386c306bbc0df5  release/kernels/retmiss.log
e5ef8538e838c6cff7febfc679dd091cf5e002f82d34f1009b1948ce22bc3649  release/kernels/retmiss.oracle.jsonl
9970a5cf3d57be0ac458c41cf014496afeb82c76e33f2f6bda3e64fbe6830eee  release/kernels/retmiss.sv-hosted.log
bafcc75269772f69cc6a89e833b1e3e5b399a536121b9889709f78e7d8405a09  release/kernels/roconst.by_instr.json
ecae62f001689d6db6b667c7a567866101d63dad7f57abe73e77862a9706c35a  release/kernels/roconst.by_unit.json
3041ab5bc88dd35be6c67aab1ef4b9b67a454e0f17914b2060070ef5da3c7a7a  release/kernels/roconst.ccvtrace
8e5c6e0a4ab361addc2605826200c307e17053895d157e1c0dc94e55b0747482  release/kernels/roconst.log
8087c0671de620162881aecd38cd6114b78e7be6bd71201e3ec02c9a2e2e750e  release/kernels/roconst.oracle.jsonl
f89c1a5a7a52839e00901c0469ca0e6cc2d35facb80149a8ce54d400e069c555  release/kernels/roconst.sv-hosted.log
d7978a58a9ed70a2859d2e237a1c2df9e1074d1aa9de5fdac2bd9e9e4e2925d4  release/kernels/rogated.by_instr.json
d36416ee8d553243c5805400ba870d2256ba7247231c6c06bf9dead6e053b7f4  release/kernels/rogated.by_unit.json.gz
639e5aa87836c9ecbee582674b45dd4dbfd620120a21851850be5588a3cc210e  release/kernels/rogated.ccvtrace
0f513c748e879791f8bb64add04b6838da25b97e6909701fe9e9eb6120db744a  release/kernels/rogated.log
7cd02bd4cceec5a044d6b4d6a80df1e68ed0ae71b0b2a953143636d5b809ea6c  release/kernels/rogated.oracle.jsonl
1b84faa46ef457ab7ebfe14ed2a8050129de19f41ba5b6f039734088db774865  release/kernels/rogated.sv-hosted.log
3666362c747fcb01773f1fdb432c362350751c8c92a94b5c18e0bf7061956ae4  release/kernels/rokill.by_instr.json.gz
9b2af24fe2c955ead075212152415b430076ff698dc11d707fc08ecc1fb15314  release/kernels/rokill.by_unit.json.gz
252fd85df65ee93e64807728cf2ef8498904136f76bfb78a413518f04203fc21  release/kernels/rokill.ccvtrace
6d932ff7db834b8c263a3579e55990eece143437356583efbc97c150ed53833c  release/kernels/rokill.log
94efcef96af469a512d346ce61623980fe86383188eaebd55120f716db596f14  release/kernels/rokill.oracle.jsonl
5c7cca36fa1b71dd7b65c12e161f0ee27b6871ba1489fd8404d654636e00544a  release/kernels/rokill.sv-hosted.log
1f511e5e919c862c798b66e3a4410353fe5086e2646c0db97d1782c56672c3b2  release/kernels/rokilllane.by_instr.json.gz
a78f1b2de2f745d30ede7f55a6d8f726631cddc9db814ace72d797b0e5b671f2  release/kernels/rokilllane.by_unit.json.gz
18457748f3a10ad45348d861e2b0a155dc57d06d8d4be65691596aae62af46cb  release/kernels/rokilllane.ccvtrace
6deb08deeecfbe55beca74249e1fe8227206565da79932102522a53364ff8584  release/kernels/rokilllane.log
f5ca6e666eff2f44894df74a291b43b3c0e7be0a63a47d795fdefd7b22016f45  release/kernels/rokilllane.oracle.jsonl
98b1418ece94c626ac9a0337bb240fa3e9e578d21023c570911f2fbc825872cd  release/kernels/rokilllane.sv-hosted.log
fe81a58560151c8ff253f74922ca0066dfcc0d03b906cc7699ef32f75adae23e  release/kernels/rolaunch.by_instr.json
e67038adcabf20bc2e751707128a879d3339930fc63ef2663c138c8c777cc1f7  release/kernels/rolaunch.by_unit.json
cdb1bfcd866ec71dc9af6efbf59373b10e5aa2fc42298fc5040b4fd17cc1af99  release/kernels/rolaunch.ccvtrace
7d35f7248bf718d392723ad709639cc6dd1857bb749f474804a610f993f690b4  release/kernels/rolaunch.log
e7dad585c3e70615de04330fd03f4f282c29a005dc1732a35655fb261d51139e  release/kernels/rolaunch.oracle.jsonl
831197b8a07d439d7b5c69596cb6aa234820f27e93acf82b5f9ead047a444613  release/kernels/rolaunch.sv-hosted.log
bafcc75269772f69cc6a89e833b1e3e5b399a536121b9889709f78e7d8405a09  release/kernels/rolimit.by_instr.json
864284d58733a808e1c266543cafaca40d5b353cf78d1f81075dc2a0e391b8ca  release/kernels/rolimit.by_unit.json
e74d95d8ef33bac3ece62941eb325714edfbb227a54dd5a1df1688138eeb7aaa  release/kernels/rolimit.ccvtrace
6d8559621340bdd2429181131cf9e9aec8d66be8abd52c56ca41fbe3eb60de0b  release/kernels/rolimit.log
1c5bc0cb8e8b2e69505fb5a551a16d5d10c56f232b88da7a27e336ad7d962de2  release/kernels/rolimit.oracle.jsonl
d5461d5c23af2a013b1d0825bbd3b01fef28477728eed85549564e0bbdfae443  release/kernels/rolimit.sv-hosted.log
892df5b5e0feb31d684a08ea2f75722198cf86b5a94ea57e79638d2105064982  release/kernels/roload.by_instr.json.gz
6da5227253177deb3cc2306cf6ae47ecaabc38e11592b1efc0df061615072d8c  release/kernels/roload.by_unit.json.gz
e9fc03480273c1c79f8c397c62177035ea35b4737f406ad1ec3d420c7d6eb54f  release/kernels/roload.ccvtrace
0a9ab9ee8d660493d9a856dbbb2bbd6ac4b414903deede2be8e655481dd4ba33  release/kernels/roload.log
f7c1309cc9764769fb5803f6fd0f2f5e1eb418f2d23fbe5e17cf5f9106869fdf  release/kernels/roload.oracle.jsonl
6bb64d95555fd57e58ccb0e028040136881f8ae88c645e5141226f21b2c4753e  release/kernels/roload.sv-hosted.log
4621f8369c6fb3ac94baf68698cb0e6b54e6b43a40e1dc56fce5017ea1218f72  release/kernels/rope.by_instr.json.gz
12676565708429abc0a6a63f14065bea325a8508e8e425d72e3b8d2fab17fa22  release/kernels/rope.by_unit.json.gz
14829181e04e3828c82bed6845ec8488544d88bb28c2819ebbcab737b1c21273  release/kernels/rope.ccvtrace
a8ce3aa02888a6ecb2b10b40063322cdb4b11c1ee12f4f8e54eeedf7891c9057  release/kernels/rope.log
d55f9efae392dc8877c102c01c0810e7654b666b6ede386328108164c6cf88f3  release/kernels/rope.oracle.jsonl
eecacf613a978fad0862992b7400f535b6a0e00d3a906880a9fa4a220352d320  release/kernels/rope.sv-hosted.log
bf3d7f44b7aba6e39e43208a1325a127ffc61a5daa1a43b38ca003dd54e1d5bf  release/kernels/ropediv.by_instr.json.gz
f1b40ba1c0b08e17d0c1b3e592cf3da3fb7d28ae8c272b436a94fc03a312df62  release/kernels/ropediv.by_unit.json.gz
1925c339d6c2c9ab9c85c2492ff798158f40a7aef3a19801e92b9328ff3266da  release/kernels/ropediv.ccvtrace
a4cb37bb799b7a568827da987ebb2a111f7883569514ed414ccb217768086ede  release/kernels/ropediv.log
10c0ec6ec18b7b44638c790033109198c079d07c1537bf193353ccedd00a920f  release/kernels/ropediv.oracle.jsonl
f0b201f5de0c39617e38e8b5b5f4ede3635740a16300ac3db0b78b7dcf9777b2  release/kernels/ropediv.sv-hosted.log
9cf4d134c64c66575d8e9aa33a52a615f9c5f5f9aa63a8d66e4b85bec4237c9e  release/kernels/sel.by_instr.json.gz
46aae39c7829e048106fb22e59ea65f21a4114e9dfb0484ef50777b9f86f4b73  release/kernels/sel.by_unit.json.gz
acf5344b353833a01a9fb4ee3523f673eeace199c0ad663a8ab6b392886c1c30  release/kernels/sel.ccvtrace
0abc74b8857b58f092ccbf88b09537c3dce7dea2ea1fc596b7e83c5bc4358b71  release/kernels/sel.log
87f6a81e8afa004c8039bf2f61c90176fcf29ab29bb17ac44aa016a5cc8438fe  release/kernels/sel.oracle.jsonl
079bb5cbf669bc592d2f220293a68ecc9340176d7bb76792cae923450f313ec4  release/kernels/sel.sv-hosted.log
a04bc87e468faca2b779f5cfe078583e23035da984ac206308b628fb1e15bb93  release/kernels/sized.by_instr.json.gz
7c2e714171e000ecc4ec850491ebb769efbfc1637ba3c1fd61bd020c98ab36fa  release/kernels/sized.by_unit.json.gz
992c8e7a3e8e0239f20f021cabcfd4bcaa3d7654b433b0fd800946eeea48dca3  release/kernels/sized.ccvtrace
a0c6604c85a291d13dcf2492f30dbadcf5d4ebe1aaea96fc93609ca71eff1a28  release/kernels/sized.log
36d903ba1618bd1faa437c9812a6ee6c0c966a63196c796267d74bf2695ebc3d  release/kernels/sized.oracle.jsonl
54aa06114ad60d3fc027e985873b7141da23cda5093df4e6db3830295e3c330c  release/kernels/sized.sv-hosted.log
f3fd1edf350bda05e241241ecec6f4aaa1e4c3a3ee0346e308a80ab578be5500  release/kernels/slotform.by_instr.json.gz
50cfdb21a42d3f4bfdc9a0881f0db27ec26f6b0c2c6f0cafc9c75482095e1042  release/kernels/slotform.by_unit.json.gz
be84a5aba5dda4c4c31728cd270f4210d25b76cc8682f9e954fbbf12712c4a24  release/kernels/slotform.ccvtrace
0e5b5bc7c881b62ea19aa69c83e84971fbe0b2b603444d8712eb6d650c6fdec9  release/kernels/slotform.log
8b61db7419b18cea8a646fb628218447e72e84a18a9891ffb73b441736138ab9  release/kernels/slotform.oracle.jsonl
f467c6a5528552faf536376a8dc7468ec27093d8361f45880b524979b43f0005  release/kernels/slotform.sv-hosted.log
51e1e571dc829f7169c6a8a5496f3bc0ecbed2e51424631e3fbd9838634b4256  release/kernels/spinwait.by_instr.json.gz
f14785a1c9f7e16c0a3d61335dff0463077c726d8d5f18d3980fbca7f3336880  release/kernels/spinwait.by_unit.json.gz
277a4a18697dad1bb63695b1e20e1536e023b96c1d34bc22b0a8c3a3ef015499  release/kernels/spinwait.ccvtrace
2c9708b298bf666ab7834ff6db2d329de77d487851cc680e728f6db6e9ade457  release/kernels/spinwait.log
868920637236c878b33779bd450439466fc3626996a3164573dc11d437d5c709  release/kernels/spinwait.oracle.jsonl
a194ee8c250edbb769465aa93719c5add3301a5b3edd350785fb39a223fe4cb7  release/kernels/spinwait.sv-hosted.log
febeb03a95d7bfff0783534374c0f8da5b848a9a40ac9c4dae4186dfb6ba6728  release/kernels/spmbank.by_instr.json.gz
418bf0c492d5de2094ba4c5b5b34b5970bc93d44b8b6396ba8706ad92dfb9830  release/kernels/spmbank.by_unit.json.gz
febabca872eb01a4b7c0cbaab7a0876f5808df2426c9d1583a9a2c252be96285  release/kernels/spmbank.ccvtrace
d74dc6882a1c991cad404a516aec6ac019cad26a0f582a802b5c338cbdc22f1d  release/kernels/spmbank.log
3af490cc37d7a92dbe719b57de216b648536eb301ff9d13de9a39f50d150d725  release/kernels/spmbank.oracle.jsonl
b877c851d17d9bdc2991a42537861fcaf713425c44c50c70103974a20a2c33f5  release/kernels/spmbank.sv-hosted.log
0b5c4a75c78b527c6f40f88ec4de0e7adc935500a9c51bea0e1e7c88011d16a4  release/kernels/srd.by_instr.json.gz
e9f0677da9c25eae3d242f3dfa1f6e5161775a60f1d255d27e0f9a3b41337f14  release/kernels/srd.by_unit.json.gz
369a7ac6ca2cac89fdb22b1fd41e570bf73c41f665e14a6f301c395d78c1a4d6  release/kernels/srd.ccvtrace
3dac8c1caa29d971be728f8551a1b0fff1fb13dd900af7e8448a0a91512eb058  release/kernels/srd.log
b08eb5e3673cac7eebb8b72af5ed3783c8e70a9e96592e76bf3722551bc79473  release/kernels/srd.oracle.jsonl
8c6e15ac65e9df0b5d44bb0bca4ee6b7aa747a8e7a7ebec0ac077c2cd61cb36a  release/kernels/srd.sv-hosted.log
c18697fbe88c7e2e9ab811a74f2700aa031c7088153eed91d640f06b07198ecf  release/kernels/stall.by_instr.json.gz
0746fbb99da037e0135b3432e33656fd7f5e22cedff7482c81894f37106c1067  release/kernels/stall.by_unit.json.gz
2e93fe0f28b44df41319cb9df58eb2361839b71647a7c5f7e62d6db2804d6e89  release/kernels/stall.ccvtrace
d81cdedb6b5413388e0b9d127ef349f4543b0c2538a78f173675ffee81cedff8  release/kernels/stall.log
500db2c482b07a0706583422cd68878301d0146c1f872ccc1f11bfdcf5c993ef  release/kernels/stall.oracle.jsonl
2b84390f4d1280222d33b59870cb1a2076bb1d76e9d40dcd8d9308c63dc68c75  release/kernels/stall.sv-hosted.log
ea2ece3f05d84e92ce86ee30f8c95b528ee9121b3162fc60b23ffb3271a0aaf1  release/kernels/swap.by_instr.json.gz
f83f3a469253ff211ac5115ec8533eb384d08b4d05058c8bdaead4a742730539  release/kernels/swap.by_unit.json.gz
4f99621184f8e20f1ce293a7892bc7e85a0cf2fc52318f71c011e665e4917ccd  release/kernels/swap.ccvtrace
171e889c4b2165efdeb24c863b5287b261f9e0131a97a2c754268129204ffce3  release/kernels/swap.log
3658a26316c1ff7bc1744304a42f736e930fcde2865c8913e6cc67a22ce96667  release/kernels/swap.oracle.jsonl
e86f5e6409f9e4cfa4d9934dbc4e8af1a03af6cf37b37ba78eea4ffe890e0899  release/kernels/swap.sv-hosted.log
055e44907d500ce24f0c682840efacdb1c3474d2254412318395b6e56b914cea  release/kernels/transp4.by_instr.json.gz
d4e31e0e19f16b6fa9364e4118a5d054b6f8443d4727f86680003a1fdad9e87d  release/kernels/transp4.by_unit.json.gz
2ee16eb17dead12146378f4ccadb227ea4487e321af9ef1410b690fb45f7126a  release/kernels/transp4.ccvtrace
806c15d7561bc6e1884d41b7e19cf018412cd216d0d298a5ce6341b65c93108c  release/kernels/transp4.log
06396ace3ac19677fd39c700e408606e5bdbacb24997d663bbe8872e63dd74fc  release/kernels/transp4.oracle.jsonl
6305155fc232175de0c222bde02f6ff0f8f23f478350f47271f8be93235cadf5  release/kernels/transp4.sv-hosted.log
b17e74c66077d496131d422fc75d26f5120ce35f917754efdf7a8ff721bd58e7  release/kernels/unal.by_instr.json.gz
4cdd29f491c40fac6b18c426dad1d58421e823210d8fc558f298e5dea497e7fd  release/kernels/unal.by_unit.json.gz
ba611dde8556689a403a4509b9c9ff897d38b9c173cf4bd4ac01d10fb19b8b64  release/kernels/unal.ccvtrace
51b9b6a1b88b1ea2acf9139fd128660aa81be8de190ec7753a82d203f7a5288f  release/kernels/unal.log
c3d484bb160657a563df983d9a2532eac27f556636617960aa1e72183ac2b299  release/kernels/unal.oracle.jsonl
f469be0c8e9141e7d6867e3266ecab0f04a6acdd71e060833062a37a7f3bf380  release/kernels/unal.sv-hosted.log
ef661c6b3986319629cb890a7df55a2920c17ccdff4dbc559b8795a117f79953  release/kernels/vadd.by_instr.json.gz
d45c9029bacbc51c7e16c4df9c1e1c20a526196ff8c517aa24291d71c371d3bc  release/kernels/vadd.by_unit.json.gz
1da80e2eae0492a2823f171859a32d0ecd84580f6801dd19a18ff90154de5644  release/kernels/vadd.ccvtrace
422e86936e03a36fa059f3559750fc2c039f5f32e71710a3372eef0748f8a8ad  release/kernels/vadd.log
0276b6d0611a4bbcdc004ab3987214aea138245bc7217504147331689a9c0880  release/kernels/vadd.oracle.jsonl
b97bb0c4d3e0dc0a0614cd3fd26b70ce586b445c22601aec3cf39c14f9b9444b  release/kernels/vadd.sv-hosted.log
6f1dde3f2302cec5aa9fb1bd851cc9d2dba70a17288bdc335c1aff5ee4fe923b  release/kernels/vadd4.by_instr.json.gz
6f57a1387f37872933c5e78d1433e06c70fa5886ba5c91a6cc2df010ff58797b  release/kernels/vadd4.by_unit.json.gz
711475dc3c022d70e146adec377d74442c56a0dbbec408fb3361bf548cf7c47a  release/kernels/vadd4.ccvtrace
344ff76c9604bbc97ebcac6fed9a0add203c1f2f037978dc700be40280f444d0  release/kernels/vadd4.log
225aa18fc9f38aa9ad615aa11de254337d59fa705877553d873062c68366e0db  release/kernels/vadd4.oracle.jsonl
41ed817bb9c139fd85ee3e7ac1c889de2f1f04ff97775752fbbae5c311e1ab0c  release/kernels/vadd4.sv-hosted.log
7978098b8f45a943d5e647d3260d14b35ca86f3d5af74a487cd9f1145493fe2e  release/kernels/vadd6.by_instr.json.gz
212334f94a664d32b41947b14bfb490a65921aeae6dbe09a3fda53d313c3cb54  release/kernels/vadd6.by_unit.json.gz
a367c4f27d1fe8a2fdb0b104749d4368d1acdbbf0b87fcaf106f711a7ff1672d  release/kernels/vadd6.ccvtrace
5298a1401801448f982e84a70b969a43dafe19361a5a69310fdd5356b1f37f54  release/kernels/vadd6.log
10335385a8b6359c5e8310565561a4a5febfe318ef4ea0a6e537be2d372c54f4  release/kernels/vadd6.oracle.jsonl
82ec0df77f807661fef1f4fbac9dbe752c60bb04c41a0bac51b8545d4bc42d96  release/kernels/vadd6.sv-hosted.log
37efb6a8c23d5609f85cdc1cc78d245de5af0948f48e61045a1e96ae2b729a5f  release/kernels/vaddslow.by_instr.json.gz
cbc5218459ab393cda108a9f7938e533ed1f6dabf71ac3164b0088af79a461a7  release/kernels/vaddslow.by_unit.json.gz
1d25b61a639423d3208303a38fa45cce6c4bf5b44ee8e0061c5e0837696362e4  release/kernels/vaddslow.ccvtrace
9088da6be14fd4536bf0a79504e33753941f1d80cc21b3c41899547e5e7bed1e  release/kernels/vaddslow.log
e9e6218e8b8450e9f9ff6b39d659c994a1e51c527a0c5bd10d18b5658ae0e344  release/kernels/vaddslow.oracle.jsonl
91fa0712b681c89864ef95979896b15706d2f064477952c540234a4636c28899  release/kernels/vaddslow.sv-hosted.log
68381c30355b3c12a4eed9d59391e0ec107e065472b384255b3b50b7052eaba1  release/kernels/waypred.by_instr.json.gz
b42d33f2e98abccd65db86ea2efa282f46bc49bb851d5e8f8c8e91937b568ba1  release/kernels/waypred.by_unit.json.gz
9c99928fe20da842a9d703185b3c074bd001b51026f8b108b537b557c0dff703  release/kernels/waypred.ccvtrace
ed871c9de1bb0dafe72b053aca952b4dc71452a519eab3b1b3365854f4f47b6a  release/kernels/waypred.log
54fb803ce85c4458b8687bb0f61adc32a9d798448b914b06261dc49c2bb841c8  release/kernels/waypred.oracle.jsonl
912b55ae2f990eea4326de7ddb0567080a90a1a7d5ddd2d2a5da7b4297ac2ddb  release/kernels/waypred.sv-hosted.log
dc798fd67c6df238e578f8cef1afaff884771ac52dee987b32a54752998402ac  release/verify.log
f78197fa73514d4391564b6dbfda61c3c03a38e2134c9ddc2d24180f29c72e6c  release/wiring.txt
```
