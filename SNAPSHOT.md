# Snapshot snapshot-2026-11-27-7f5195a

**A generated, read-only snapshot. Do not edit or merge it.** The source
is `ccr-9eb50716-lecnjf` at `7f5195a486518d84fc9373d1f2b2197d138b767d`, and this branch is rebuilt from source by
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
| Source | `ccr-9eb50716-lecnjf` @ `7f5195a486518d84fc9373d1f2b2197d138b767d` |
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
113990aef5a62ad150301bb82c48922e83e9a1a7d4070918e955aa4f0c461341  release/kernels/addrhigh.by_instr.json.gz
295891b3d7035453fbb290010837143fc480918a1f53781001ffc4c395f2e4a5  release/kernels/addrhigh.by_unit.json.gz
0ae129059e1e1ae3384c7c2e0b9bc7670fe0ad34be0a50dd748e64cb6ab75ff6  release/kernels/addrhigh.ccvtrace
8c262aabc8513395c961334a556b06e348c621684229fc08f8fc027aa6c8763d  release/kernels/addrhigh.log
569f2e22883fad5f0956c57ec734e6afbdd4b8a854e50277425172d6c0cbd766  release/kernels/addrhigh.oracle.jsonl
99c8e66b14810f4f939c25717008d2334da6b55af19f41b78fb9542932a0525d  release/kernels/addrhigh.sv-hosted.log
46e943fcc54042aff9d156b39c48d4dc672c81facd9260e1237a66724927d6de  release/kernels/addrlimit.by_instr.json
864c0bc2a4ce482185348edf40591cce307269ee6abec293214daa584e215cf8  release/kernels/addrlimit.by_unit.json
19b1970a7f3795df488b793d1a599220bf1dd8c1c60568808fdb454cff60a92e  release/kernels/addrlimit.ccvtrace
04cd9bd6f29f252da5ad16964569447f02c30125978d852c4709ae3e9f9b978a  release/kernels/addrlimit.log
bc660b0b40359a2c5a2478cb0eb4950b73fd22db50ea76b80052bc195a1920f4  release/kernels/addrlimit.oracle.jsonl
4cc4041ed36a587c0463227678ff75bd2c8d6a5429ed09bc80b8697f36ea5018  release/kernels/addrlimit.sv-hosted.log
8f8665b3cf94aaf6918e5964b8f1bc44148ae152f2625b935089fa1113668fd6  release/kernels/addrneg.by_instr.json
975b65c4c5ea12e08806297d6711732055909e6f142cc19f2771648c1a1402cf  release/kernels/addrneg.by_unit.json
ca95f5bc9b5a38c9a4b55584b40ef866d0bae9847d1c737b9650508222652023  release/kernels/addrneg.ccvtrace
aa71be9c5be05797bccec2d532ec995965b666f5b35390a91a4a031c83da964f  release/kernels/addrneg.log
16f5b0707ae44492a1efd67bb9dd38a7e79a7bbd354fa9207b9e7d150ff2f107  release/kernels/addrneg.oracle.jsonl
fa15543398c449e71a9411ff884256f74aa280119477b7d8b86a9ea35d5d17d3  release/kernels/addrneg.sv-hosted.log
b4d8a6513c87b9bdcdede630151650bb4ecb1a6753035eb5b8b42cdfe7195b0f  release/kernels/atom.by_instr.json.gz
24e8ac1e2af8f37e2ebaa16d2534868ea7f0eb7fb42930dc37f7682c82b153fd  release/kernels/atom.by_unit.json.gz
797d54335b19f17db40cb50700fd6d672483c20c399983d17b7c22ed41852d07  release/kernels/atom.ccvtrace
2bd6535582e3abd3439cd60172d98616640734337f207f1030885d7ea49cf5aa  release/kernels/atom.log
504f5b6e9d25114dc35f2c70b21bb7b3f3c508c691de12dc0e87d12a74285361  release/kernels/atom.oracle.jsonl
77a9b67be010141f8d6a7d2f9a0c5500820da07414126b9c6ba7b7e82bd3f507  release/kernels/atom.sv-hosted.log
3e263c7445cc6bf2446cfc78cc9bdc60bc455866612e8c86393c3076c4cb957c  release/kernels/atomf.by_instr.json.gz
4e8236b10f38d8cb4bcd08329df5bed61f32181852c626b5c284cd7e6999a504  release/kernels/atomf.by_unit.json.gz
e888bba046e29bba2f2b00119d3ab01329aabf2cb41340122aafe2800a113d80  release/kernels/atomf.ccvtrace
d081e212795172a533425bd1c5fe9bbd6378a0b58ce16d803871b467018a95ca  release/kernels/atomf.log
cfd1179edf4061a33ab2f75d7a6dec61decfe629000198189a7bfc2647b34238  release/kernels/atomf.oracle.jsonl
3dca010e4ca9cf5e799dd3340ac5f17814cc1598a630fb03bd68852f982416ab  release/kernels/atomf.sv-hosted.log
002b71b6ff8875b658de9a448f8ddbc85ff167e6b6744c77b2666af4f9c5413c  release/kernels/borrow.by_instr.json.gz
ccac513d5c074b951bdf166e2bc716fa4327ce6f49e6734c3ebe6302c240e21e  release/kernels/borrow.by_unit.json.gz
3edfd61a186bfa758b8d04dbd80df2e8d512e395a967fa9e17b90d21ebd652f1  release/kernels/borrow.ccvtrace
4a30435ce7a742f82fb025f57f8683b4f31ba1d9ebcf60f1010ee961715b7c50  release/kernels/borrow.log
4c565e1ce0b3baee36e158694b32c8defb5cd662b2f9af75cb5d8c26cb1168ed  release/kernels/borrow.oracle.jsonl
c7179503e0d7a352610040b66544633a3c9bdc5dd9c404653bce0e834ad54335  release/kernels/borrow.sv-hosted.log
35f7d26aa9482b666a4633a99ebb6740aac32d191045df14f147cae471e81add  release/kernels/brs.by_instr.json.gz
4dc163b311ce7e633a91b9079d67bf8366b1e461f8e857e44696159e5146f861  release/kernels/brs.by_unit.json.gz
f1cd4f404850590aca4cdeda4f3362acf51fcb3969eda45616f8b51e5d389ad9  release/kernels/brs.ccvtrace
598ef73541fe01f4ba9e70f9bfbf9983f9ef61c3167cabd97bafb7a2168ef3d3  release/kernels/brs.log
e3c1cb3379580cf1aae44e8ddc8e846ef6fd661a573cfe0a8d4444b18a14dc56  release/kernels/brs.oracle.jsonl
74e3f7cd1fc1d9b5ad9fcb24e5e45e6adf3604e04b841d070c0009241d95be24  release/kernels/brs.sv-hosted.log
2be47b36b72226ac55f25955326f60d9b41b8f11e61d5e07fc37601c8e1fa64b  release/kernels/byp.by_instr.json.gz
7f04dafc143795ec7c98031527f65e00a92a96eb692ef9ba428ec328f8ee1c5e  release/kernels/byp.by_unit.json.gz
fad2fdb3804beaee0f9a3984ab23cb8e81c4be12cc2783cf9bc6af282f63d32d  release/kernels/byp.ccvtrace
f3569396ba05620d4bd418fa05de2598a51e3677f576038e2587425fbb6faf97  release/kernels/byp.log
5a03dfa4f3603fef49f1e3639e74e34152ca3ca5ef8e41eb959f8323040fa2d5  release/kernels/byp.oracle.jsonl
88a2bf86b58ef6bcf76267cef7f0180322e1257454608b595a7d22dd5342a194  release/kernels/byp.sv-hosted.log
fee66aed9dbbfac772a3acf7ee52b2b8b1d8d03be2fa786372b7c2e5f393f0e5  release/kernels/callret.by_instr.json.gz
c5c11927ea366ea7afa1d7c9a2f92527133aec1278ad7df5a39ea5a1a27e75b2  release/kernels/callret.by_unit.json.gz
37b60e82e7a301b0a6c3f86cd9a97f14a1ea8fbe6bb6dffc95a5a3ebafd9aaae  release/kernels/callret.ccvtrace
0a7a0e0bdbaec0105323b92f1d67382c1f446d0c286bdf08e0360a68a7ea759e  release/kernels/callret.log
9b1d1b50b527f732362f837250aa2f26dabf3e76e16a4794856ebd8f105635b8  release/kernels/callret.oracle.jsonl
965bef941e84fc7aba2facf9579e2b86e9bf16fc6a8168746fcc83e5ae4d3b12  release/kernels/callret.sv-hosted.log
3b78c823e786fb80ea24ee0cc1f04dccf2eac58bfc6a71243b0c7f9aa6da0942  release/kernels/cas.by_instr.json.gz
cb0816c4b9d7c3ed08cca9b310634b3bae3e78fdad95496459c5f617865a15ef  release/kernels/cas.by_unit.json.gz
dc49d8fdd26dda21990042ef6d02dbb92fd98683141d71e1ae9883237213c069  release/kernels/cas.ccvtrace
526e4e0b4d677a9d63dd20ac839f85c4f909860805d3e0396d6f58551aeb5266  release/kernels/cas.log
0ab31a9443336fe5d08e1a5fa5fcba3bc279b19022f7c5007908d39d8ef39536  release/kernels/cas.oracle.jsonl
beddc361fe652e41c3da876b0046958834762d95d8a63b8d28e01792019ded1e  release/kernels/cas.sv-hosted.log
84106ca114190254226e1630160b371aeeeb4885c7194008ef8faeac6c97f770  release/kernels/chains.by_instr.json.gz
df85a95a42050908d92c991d663a7c0f05bdcc08705b6155f59bf8bb5a84de5a  release/kernels/chains.by_unit.json.gz
520637b4ca14de3ff66718fb9e68e41134e5c456612cab51f14ccb69a9802fe4  release/kernels/chains.ccvtrace
311e2e8b478ec08d04a3a37a374e07c1babbd5dab3ac8b3898f5f402ca912e43  release/kernels/chains.log
26a4cc5c5524c7219d8706c2582c80357dea60be9d6ffdec99dac7d0365e2264  release/kernels/chains.oracle.jsonl
5871655f44af2b69f3cf8b5154a84ccbd574208348e8289c83a6b3a35c9453ac  release/kernels/chains.sv-hosted.log
2bffa362f04da920a129eeb6281a84071859a7d1a1348913f225b4134fd86d0e  release/kernels/coll.by_instr.json.gz
0e34804df79f43d860a346587bc9a300bb5d58f3250570bfd1023bc97ecf1b8c  release/kernels/coll.by_unit.json.gz
c8395342e50fa1411fc9e1cc08847942c35034a98673257a52395cff9506bcf9  release/kernels/coll.ccvtrace
1f94e8e915b618b415d9a23239f0f437032625e84841192264411dd14c061e66  release/kernels/coll.log
dd718d23c88df5dc7d92b055d8542865aa0e029118486af127312a8a578cfcbc  release/kernels/coll.oracle.jsonl
8723f899548fcf68f4cfa273237decf0de9442a62f330ab1cc2198fad91f6320  release/kernels/coll.sv-hosted.log
0642cce072933278b414478224bef92af379ef8e33738208c6935bf41a1b5137  release/kernels/div.by_instr.json.gz
d3956ce1ba38748ebc03b05645b7b600fe947a5fee7b4abea8b5c5081e775dcf  release/kernels/div.by_unit.json.gz
52e372c9ab8b2e93a93d6b8b73ef6adde36081b43590718a75ba1e162d334db1  release/kernels/div.ccvtrace
31709da17f31b5ebe42649ff0c90395209169a4922d52ead0f28102adead6fbd  release/kernels/div.log
71a567b85cf85622631490187563de9a5661099c78a590adff4ed0a0c3d24c16  release/kernels/div.oracle.jsonl
fb3a09c186dacabdf3f51ea875b41a242928e8dae7162f32933bcd869a59a890  release/kernels/div.sv-hosted.log
8a99fa5abafffe6d7f3ac95584336803a6ae22c08db48fe71742a94b9734dc0d  release/kernels/divchw.by_instr.json.gz
8020ce317b1db4ba14ce8d4c1cca114d3d0aa869eb962d0ab8f138a78a2e6ab0  release/kernels/divchw.by_unit.json.gz
4fe974515ba66dc40ad4876bcbfe310a78b48f2e1715facd3ac51aa321f0ffcd  release/kernels/divchw.ccvtrace
a45208754439400a23ee1cf29a342307e4dae92a25807f27ac3a4664ff0e6fab  release/kernels/divchw.log
58a541797f7a2df0a1c7528ae6a3edec212db90c7d3eb20656806f38b5c10b3d  release/kernels/divchw.oracle.jsonl
075c707fe7ac3ab8270b74bf1ca584a40cc24adcfcd220ab6eb56b17d3280969  release/kernels/divchw.sv-hosted.log
179c77f2e98a4055522dd4dd46df0f78ef929325c16f6fe8a63ae3855739bbbe  release/kernels/divtail.by_instr.json.gz
e1b08b77240f2f47ea0937fee07ec2f68b97d1efcf037ab5043ef941ff3823f7  release/kernels/divtail.by_unit.json.gz
cf8e154b191e828aaa771e84f4787f75466454fa0f1cad6d3ee7d831fdfef587  release/kernels/divtail.ccvtrace
7d253f91f1224853d1b8b6dfb1cef3ca37f03a08b67daaeeca69023e8240cf6c  release/kernels/divtail.log
75f11a75c9b3b336e446140af4579f05b46c363a76b7aab3ec88154a07ba097d  release/kernels/divtail.oracle.jsonl
df261761838e42eee25ebc42b38ce55ea046bb2e094d1731b2d063be3b47983f  release/kernels/divtail.sv-hosted.log
11374a41456c5be9a5fe2552e1783850c32a9697fe60ebc44f03f85f7da894e8  release/kernels/divtail2.by_instr.json.gz
65239d196b9cc58edc70e1fe131727f14029a783797dcfb269d37950e4dbde97  release/kernels/divtail2.by_unit.json.gz
1e64902dfd7a748b57e0d7a68abea026230d563174bc2359f04a17cf0e6b3b2c  release/kernels/divtail2.ccvtrace
eec17c438b8b0d8b735c00f1edf22ff8736bc598f864aac36d8fec64c38bc493  release/kernels/divtail2.log
b2db6b05eb6cf4a0a7677e31d0c6c2952d5cab49d353f0bb1883fe0b2a20ed14  release/kernels/divtail2.oracle.jsonl
1b181a4525c6b551e03f785fd8560106a5273fc7905fcbda591a34448855b0a6  release/kernels/divtail2.sv-hosted.log
02cc7b9017a9108c4f50a2efb8772277ef6bbdfe914b0ec4767ba8b4e8a4fafb  release/kernels/fence.by_instr.json
be6ec5350fc7b934b80432f1e8a409e502e385c209ef73659370277dbebdb506  release/kernels/fence.by_unit.json.gz
7aeae6eaa496be2c18ce66c0c4e75f0d442864563007944997342ab51e0f9764  release/kernels/fence.ccvtrace
e144761a64683d25e879eacacdf2493cdb24fa9366d98a571dcc4f03b56d82ce  release/kernels/fence.log
d1d40317f6cf5bfb430cda1f9c0ef676609e59cabe2a11623c42ffbeca93142b  release/kernels/fence.oracle.jsonl
1dd4a0181e74480338c59c16fd96fc69e4a953320d1403609d715e3082c526e8  release/kernels/fence.sv-hosted.log
4752ff3446c7b74f084a34641f01b7946f8f3f9a9e3d842b19c8705c4b852004  release/kernels/gather.by_instr.json.gz
c84cf2cbbdae280608a302e706679065fc386ab0e84fdc79d459a000559b4326  release/kernels/gather.by_unit.json.gz
ee8f96b252913bf6f7d93969004dc5223a2e0e5e70c5e7cd7a0bc3b359222112  release/kernels/gather.ccvtrace
20fa50e271361eb584e85c1ec0984539e8595853efa16e15388b69e6dacf7647  release/kernels/gather.log
0413e781d8d6ff578c64eb1f800b7931e66f676d5cdabb97b94a4033e6037662  release/kernels/gather.oracle.jsonl
5fd55f747157062b9dd637ad73c6f69884f0c436fefd5bcab55f26e2b29114a3  release/kernels/gather.sv-hosted.log
dedf5e435b04f591f2bdb1cba672438bf76fbae6543eed77f45ddf18a8b25225  release/kernels/hit.by_instr.json.gz
46d7431af090bcbc9a274985b04973d86b96ab62dfd267933a9441a8d85fa146  release/kernels/hit.by_unit.json.gz
735e3e4b754041adf2cd9f7921a12e2d206beebe8746fd451a0488eeec7081f0  release/kernels/hit.ccvtrace
08d22357f2f434ac4b4a4629ba9e545fbfa3a96d4fc8dd9ceae3f8289b315424  release/kernels/hit.log
7ba9603e0088d9164de6528f16ef6a7fa9ce5821c8c12b52cbb3734e39b9fd52  release/kernels/hit.oracle.jsonl
a46ddbc6f67ee7dcd65afc25b5401e3f2e697ffa6b77903acb87cc1f0fae916e  release/kernels/hit.sv-hosted.log
631b01166fe56cd0a42bcf5d09cc49deff95c032c5adc1516512e613aeb7ae62  release/kernels/lanectx.by_instr.json.gz
27802e11f81ce64fcac12baa3f29fd937ef2857e00c1b8a8122c0e6d75d6eb56  release/kernels/lanectx.by_unit.json.gz
278282dd369c754555c55fedda1cbb6ba7503aa6db3cd38871efe993aa103826  release/kernels/lanectx.ccvtrace
0421102336d42de90a83fba8e5cd92bb3552a0789c4a23f7887af04cbc9f50b8  release/kernels/lanectx.log
888551babf540db8e3025b82e65ca655013f93eba3c8a65689d069d52a7e6039  release/kernels/lanectx.oracle.jsonl
a3f6266c3feda5530351acb5aa648004c3c1017878e45c5fbdb68058e69518e0  release/kernels/lanectx.sv-hosted.log
ac6d3bf7a2d86599ffa5ab9c5942c18d5c6e9dce169223117085740b5209a2ff  release/kernels/lanectx2.by_instr.json.gz
380208a4f34896e9ecf99107ec0fe95d2b8f9cbd04ef52499dd6ebe5619b553b  release/kernels/lanectx2.by_unit.json.gz
c78e8ffee4b615eae44985891233d95ec9b39e5ebedec165568495ed4a060ef8  release/kernels/lanectx2.ccvtrace
95da530e422219e6ca8deb8f1e946eacc657156d7f1f33c515b96f6ad12e5cfa  release/kernels/lanectx2.log
45c13056dff5c73ed0c9ece56cc36f929bf335322193c7d5eb38710b1d1dfb02  release/kernels/lanectx2.oracle.jsonl
802e7d402835d6861976dddd6377a6af90bbc10bccbbdfc77800a3c6d3d5d73a  release/kernels/lanectx2.sv-hosted.log
3e5bbcb8f60fa739ef81d1a269363f4939089d1315d7f20dd5b6f8b686d1a2ca  release/kernels/late.by_instr.json.gz
e6c4ce628729fb8f2db16642e73254891b766dd51f87be8d3b06ff0544a8a29a  release/kernels/late.by_unit.json.gz
89990f4c312f36e9af525b1140216180961d28754e12c0a447be546f40bcd4ff  release/kernels/late.ccvtrace
35af91c8773d23b2f2c3a12ffca2fe028b38bf48ca664a0b4905d9cd209a0eca  release/kernels/late.log
86084f6bd747a2cf32acbc0ebd96ebd3e4ef2d8d9e21be49e3ae49290d7927f3  release/kernels/late.oracle.jsonl
cf39b37d2620a350ca4190174afbd8d2ee4cfa4957cf12b2d149388e6cfd3ba5  release/kernels/late.sv-hosted.log
dd0bba07a151d36465417f99b47176991938539cc0765a5965ca1ab6811a0562  release/kernels/ldpar.by_instr.json.gz
16585a71624decc25e204c4397a7258381943a21859209a720a7da8cd9a27f52  release/kernels/ldpar.by_unit.json.gz
d35f767b3b3643e898b79093465396b17ecb6beda48259913f4f688ae038b6e8  release/kernels/ldpar.ccvtrace
ca4a07aaaaa02a2ceac72fb1016d90fc3728ea949690c97c9d18586a08459ec7  release/kernels/ldpar.log
8ac08538e9c807637babd61b31e340f7461878ada31f0c0b83cd66331cfaf486  release/kernels/ldpar.oracle.jsonl
99c0e251479124c392e6b07d4565e53e39dd4f6ad1b36fd149613260fdc9df79  release/kernels/ldpar.sv-hosted.log
722fb965efce4227c00bd4314aaead813ad65c72bfab318a9ea80181887e7579  release/kernels/lnorm1.by_instr.json.gz
890fbf9fca3bd57d1c355bc6a1c8f5aab2ddaadd48873df78fe1e47cb23d1f62  release/kernels/lnorm1.by_unit.json.gz
a51891466de3d6adeaae5eec5f07bb203809aa7440c03ed92f0e5f1a09649c44  release/kernels/lnorm1.ccvtrace
d06e7b79eaee21fd5d9458744103a9afb841260640490fab1d3f0df3c9924df0  release/kernels/lnorm1.log
a8d85811af988a1b9fc00db1517300af3d93ec8e589e403d3b9113fa9e0ffc86  release/kernels/lnorm1.oracle.jsonl
1db25217616e3de7c91d99b5ff4d3103359bf4348b4a38361124c3ca933cce94  release/kernels/lnorm1.sv-hosted.log
4b9652205a92af8e392d39379ad0698083ef8d8073604792206b23c17740ea9f  release/kernels/localsp.by_instr.json.gz
bc15ab7b33a42e5f5fca5ce41c55529ff78ae0bc13cb9efbaa98d228dc9c8a5a  release/kernels/localsp.by_unit.json.gz
a48e944351c17396abfbaaba34cd7f467a7e01f97c99286f88e39b0a5692b7a9  release/kernels/localsp.ccvtrace
78540e7ebce3cbe543e8953b43634cf1e936805cef5b3ec536cdf9a371202241  release/kernels/localsp.log
55e3c9f36e7f7d38c0ddd38903aff4bb4509ae862015c592e6b937ea258042ca  release/kernels/localsp.oracle.jsonl
e656d8ff008010fa0c73db00a50f48286ca6f1a79b9f4f37bca395ed7b1ead3b  release/kernels/localsp.sv-hosted.log
61073b15d35ef95ef0c99b4b56530dd070444997dde79f3c926dd89a4c3ed1f9  release/kernels/loop.by_instr.json.gz
149b88dcefd54f610acd9f11e1b1919a11206536edd887edab5acdb7a84d68a2  release/kernels/loop.by_unit.json.gz
4282db3ef7e25eed678da3a1764b3297bf604de603f2c8b22fbba04e39ba0376  release/kernels/loop.ccvtrace
81034ddc9c8385dd21e4df63ac3c7eceeaf3ec10f44230b6211a4685c313b9a4  release/kernels/loop.log
03ce5920c06c93e93516d8e53c3f7169f14e3593de204eacceffc0b8a3e32016  release/kernels/loop.oracle.jsonl
751eb948a4283c267fd0dcaa9bda3889395dda3d58ac29486a251fd63d9ae235  release/kernels/loop.sv-hosted.log
04799cfebc6b20e7bdd04083fc097e8f1d955150a6376eed055c85b0d8f0fac2  release/kernels/merge.by_instr.json.gz
01abf6937a2da8bd4dcd2c2c9471a4c5c9de630eea276b22fd72fc40a942ff83  release/kernels/merge.by_unit.json.gz
1cdb81e86e4d30ab9e1a19efd1f3890da9123ddb88187024044b96268bbc023d  release/kernels/merge.ccvtrace
84b6598d4fe037255e54e52a29ee3d9fe151fd9b6c3c18cf07335442ececd222  release/kernels/merge.log
f96d28815f8756b1f5a45ded53e6170883d2dfa10f9eef0d14b8050b1318164a  release/kernels/merge.oracle.jsonl
13728dd9e4655fa0ded0ddf40228ffeb7abd1d8660f870dcc27e8c4c3be22f48  release/kernels/merge.sv-hosted.log
7bc1b5689daf7ed7f2d79c166fb9884c42dd555b6bb03054148bd3a8f06d79c9  release/kernels/missrun.by_instr.json.gz
46acefaddb618472f8f91444d0af30a3625627f5caa4730db41713e620efb9e2  release/kernels/missrun.by_unit.json.gz
b8eb371762b05f7890a1c8a1821bba0961af38a5db59fbcf5eaabfb132c5dc20  release/kernels/missrun.ccvtrace
0cee6d0b229cdc25d2b2e3236e9541ec99317dc4064ad892f7b3d9565487c0a4  release/kernels/missrun.log
531bdaf281e5590774bd2775427f25e4cc0419cf8e3d5b6999843ffe9ef87258  release/kernels/missrun.oracle.jsonl
aff886cd502aa4f6da261d678d4d4267bb4075196cf4e2ba48e47b1dceff9e1c  release/kernels/missrun.sv-hosted.log
c93cccca835ecbfcb981b8cbc7a13817b17781feeae78b8674c7e44ab865b328  release/kernels/mload.by_instr.json.gz
cd58f091b53a7a75a4313e2fcd37ec8811008a1623ec571daef406dc77578122  release/kernels/mload.by_unit.json.gz
97908ce5e7a9df5d988e06cdb58a9f10d0cdcd7e719b092502ccfd074b9228ab  release/kernels/mload.ccvtrace
aa90e9acfed3b113e9f35d6e3fe2b8430094c44bb4bb92e6fe82b3ffa30c0a40  release/kernels/mload.log
8000e477b9a95dfb9f0af964e8346acb9d36f1358fd06ffc4ff7cf599d2b8868  release/kernels/mload.oracle.jsonl
b1115718453a58195a138b1d2e5db3ad52bf7edd3b8ed48686f3ba681a851e52  release/kernels/mload.sv-hosted.log
18317656be663bcc5438ed4b6a52fa5321e3cf2b9825aa54c698765fc99695bd  release/kernels/mlp.by_instr.json.gz
e71819c13ffce5158578a5e349d3bec2964f56d0f14c515cd4825d55843e04a3  release/kernels/mlp.by_unit.json.gz
31ae54590ed11ce427715be77ad492dee5bab993e351a7b7de09dbb6123b7df7  release/kernels/mlp.ccvtrace
7077a1290445987297d6042cdf5375a0294f692c8c25564423026d2218442132  release/kernels/mlp.log
138d282f88d56c8ad648a91af0a983254b55d9fa22942c00d47b327f516a6e44  release/kernels/mlp.oracle.jsonl
d9a37324887fb1295b6ff85fd0b42b9cc9034d6b84fefaf39fb52e51a3e6f355  release/kernels/mlp.sv-hosted.log
6e73a76181fccd749b7299beb8bcfc76060d5fe01dc40f31c9e6152fbc49be26  release/kernels/mwmiss.by_instr.json.gz
137b2e19f004ec23b67e5e86b866e8ca61f9cabaf7376d0a11ab812edfced1a2  release/kernels/mwmiss.by_unit.json.gz
194cac222b145131d0bcee8e371334cde6ef588629e284b45917c6aa0fc6890b  release/kernels/mwmiss.ccvtrace
a61d09437e8fccb515d519111105956600bd34b8e0623f482acfa089cad5e539  release/kernels/mwmiss.log
8abe8e8997456a2a6711ee72da54d854b24e20abbdab28e4b7271c0d28418de8  release/kernels/mwmiss.oracle.jsonl
7b46d07744a7f9151b7a6ad1d8b8de37bf70bbeda1c56134d65495a50d89c17f  release/kernels/mwmiss.sv-hosted.log
71866f191dbf38c17e9c988935990c8daa7b0f40d22617c506a14c7748daf633  release/kernels/narrowadd.by_instr.json.gz
e1b6c03a99c5b9154665c9a25c1e8a88cf0e34afbc6b2752a94592eb0b922611  release/kernels/narrowadd.by_unit.json.gz
856c082ec93e6f7d5e8c0e82cce9a7d0d54c287a13629892ec5aab922f0ac02a  release/kernels/narrowadd.ccvtrace
aff869b1c1d36df372ed7d5f73969050107da3ed2d8e6f881b0348acaf3ece2b  release/kernels/narrowadd.log
40a2cf629853dd404bb06b4a07e35abde3d12efc13f26ffe28f923daf2994574  release/kernels/narrowadd.oracle.jsonl
00c269f39ebe082a592185c9299e29ab8f9d2e1c261b4efa0971144db7dcf653  release/kernels/narrowadd.sv-hosted.log
1c03fbec4af9b11bda7f392d1f96b2ad77824d30ea9d0d6dbf1a13276c2df9c6  release/kernels/pgcross.by_instr.json.gz
d127f1773480655480c251b42c334f64ed59cd759c5726816abd5b333aa53820  release/kernels/pgcross.by_unit.json.gz
1075a5594ef3271367362cabe405239302b0e209c0d232029504894cde8b8086  release/kernels/pgcross.ccvtrace
8c07ccdd007d99d72f227c3fe8b96b8f5985dc9245ec662145c5dc1c19dc8ee6  release/kernels/pgcross.log
58aba9ba5ec6a72271191c0249014802cdc7e4470d27491f499a077f17ecc039  release/kernels/pgcross.oracle.jsonl
0e8591fbc11557f273bea9bb360dc8bdf6c02c6af91e773dfbffc74c9d09cc8a  release/kernels/pgcross.sv-hosted.log
d7abaf86c09d410cc0707105aec0be1d9792fe52010c77db4665c9252352f24c  release/kernels/pguard.by_instr.json.gz
1b29f6d3f80e911705e9493235add275fa0b822d07431b294311cdc870270ba2  release/kernels/pguard.by_unit.json.gz
5780c007d8d8e484e42eec3a5c12c48ba4c77684087ae6d5c756f31851aecb0c  release/kernels/pguard.ccvtrace
c3a32895844388cb8a5dc4af79462ae45de412704ef89567ae36d2a317684f85  release/kernels/pguard.log
690e56f1cb8d97cbf67124b7dff3ad0a90cb8981814cd1709cf0cd0e035b3bd9  release/kernels/pguard.oracle.jsonl
ce56dc4005b34ac4b61915c249a9b994f558aa146bf1d7575dbb1ab163578ac6  release/kernels/pguard.sv-hosted.log
03a0bfec63ce5165da59b04d4e9de881e0199b7a81d33054eb52971073414725  release/kernels/plog.by_instr.json.gz
cd1e6629222d69fda3396602b5a8a26e3a2a0b4868a6eea0120d8258ef296c22  release/kernels/plog.by_unit.json.gz
387ce59a221b93134bbfe7a7174209bba6c1be72e7880075a42de6aae6e452bd  release/kernels/plog.ccvtrace
5eaa8df32fb8b4e334727d453dbb45b863c439bd3d082905b63113dd92258e9f  release/kernels/plog.log
0c99915e2da60f4670da00504a6371d7d17701d4431e733a3ff8fa98a2030d6a  release/kernels/plog.oracle.jsonl
66523b75c662b5d765ea3d7711b981dba926262e0e0ae250021c1c24f5376160  release/kernels/plog.sv-hosted.log
97ff08c631581b203a02844357f8d603ea61038a8a4cc9e26a8f7fb7a59073d3  release/kernels/pmovdiv.by_instr.json.gz
69df0388533f5739ee9cbfaa111110ccec1107a003845065f16c713676007fe2  release/kernels/pmovdiv.by_unit.json.gz
e14b32efba43482905dd775905197af8a3748473c9b7a924664ec3b5a8fa00ca  release/kernels/pmovdiv.ccvtrace
f5111a4989ebcc8900e944a844cd398fb879df0e7a7eca33bec84a8638aeb1cf  release/kernels/pmovdiv.log
7bc646cff6166a51bdce03d7c1b7209e871f0a91d743083a9b910a80bcd0b33f  release/kernels/pmovdiv.oracle.jsonl
d3d6a49c866b51bc8d600d05bc92ff1c95283071e746aaa2574d67553a684196  release/kernels/pmovdiv.sv-hosted.log
6010280c0e2354c9dba27ddeccf8a7d2d4496ea592411b4b63c7ecceb9e0f7c8  release/kernels/predlane.by_instr.json.gz
2bb9b2e7a929ceab0cc628065a3d41eebfdcd2d2865b194b410daff07e6db905  release/kernels/predlane.by_unit.json.gz
6125cd4c52ad4aca6219bd684c227cc5307c3a4ac7fade886528a4d29bfd1f8e  release/kernels/predlane.ccvtrace
76cb3adddcddbbc660eb9e0dbab4d89776502d6975eb9dbf6cb5ac4d02a6cbcc  release/kernels/predlane.log
c45f4177b9e84fc8a6e36b13534a0c7636eb30a3f8531847100ce5e23bf404b1  release/kernels/predlane.oracle.jsonl
222f9cb0738a915c7143e37e993bd78403e8e2ffef9da1b19fe23b1e6507253a  release/kernels/predlane.sv-hosted.log
19f6905eeb18d2e4dd1fafc319580804b2b03ac8edb08f1c306920e99a4e4e40  release/kernels/predmerge.by_instr.json.gz
e94f4f5fbdfe3504da7639cb77567b2ac9e90d80b11868dc6cc2bc8e87fbf637  release/kernels/predmerge.by_unit.json.gz
d12b62f73d450c8a60520fe340f72a1d91fe544821abb08ce2129854705d4b11  release/kernels/predmerge.ccvtrace
6e67bd057e4408ba2769ba6eec6964781d78f053177df492508afbabfa9551c8  release/kernels/predmerge.log
6c737c49434bcd08e3e0814c8b1dbf15c586ae74f7929ba3148ddcee2c62c845  release/kernels/predmerge.oracle.jsonl
2fcfb51fb9dd59805fde87073cb0f5fe587522f9a18b919c68a5412ae8c6b5ea  release/kernels/predmerge.sv-hosted.log
283c6b059cb0c22c2d5556c83071cda0a395bbb9deaedcc07631dfbf26827a95  release/kernels/predspill.by_instr.json.gz
b50fa10f9f0149c84a68cf58ddc03390bf9071150046fb2b629f0951a42aa6a0  release/kernels/predspill.by_unit.json.gz
4acb0d76476805572793da062f6710e4c560428db30adb45ddb33306f039c449  release/kernels/predspill.ccvtrace
ae0c20876547f727fb67e9cfc95c0dec7051e8b3100c572b9549cafb00483173  release/kernels/predspill.log
b7c84c6478117ffa0f06da0e6ad1e4628e2683426a7911080810e78e06a5242e  release/kernels/predspill.oracle.jsonl
3ca83fe4dfdbc1908c19bdb730552146e7136d5a0e3959b39274079ce2895a85  release/kernels/predspill.sv-hosted.log
99b0d37487357a5eb2988438dd848c019144e08c85b3a644fd5d09e41ab0be84  release/kernels/predswap.by_instr.json.gz
c404d72cb18e106db56522916f79eeb82da6180efee093cfb73ccc310b061e49  release/kernels/predswap.by_unit.json.gz
88ff2cb8b6a348da34bc4e2f2984df9d8eff258c537100f2f51c42d8e9f31c94  release/kernels/predswap.ccvtrace
f34c67dd3c39609167174d0b8d801e49ffbb89bfc0a43c0504535b76c5fda01b  release/kernels/predswap.log
a6d4f7ed517553816d889c7c9eeb6bcfd1f6c973fbf682ecb69f3c2de619f7bb  release/kernels/predswap.oracle.jsonl
153508978ed82c8fe26e1442626b7782ee7be0877f718853e9cf4783b1a3a951  release/kernels/predswap.sv-hosted.log
1654318bbdba28675c31eb8cd254726645f29656b8913ea21d87a563b7fdb3e0  release/kernels/privwin.by_instr.json.gz
8c0fd4aa4b2388312ae779648861f32d710865faa44ff12d9c8a275e4ca35e43  release/kernels/privwin.by_unit.json.gz
2d5ca9a18e8685cc4b204cae08205219ad84b1d53d3681103072d970f29f8f7a  release/kernels/privwin.ccvtrace
444437b6cdf024b204b108d3474195b1becc94d96ae6d1dd1ef6df7e03d21c61  release/kernels/privwin.log
861f686fc4480363472908d679d8815e8c957d768e7ab32c826930527b0fb7a8  release/kernels/privwin.oracle.jsonl
202354b6997758bd2c739380185cc355bdf5e0cddc3098b7510c6fda1e059e75  release/kernels/privwin.sv-hosted.log
159bc643b5de83e88b3ae5ee9de4d5f5148ef5f689a92231c28cef9a07fc44ef  release/kernels/provswap.by_instr.json.gz
7a6584609c740097e4bfe16add28e8fd909e70e7410e33194de260bc682abf51  release/kernels/provswap.by_unit.json.gz
088bc232abf07d6ba9a09759ecfbecf68eac57a4d0b7ed4f4618f90949e7f990  release/kernels/provswap.ccvtrace
cc9def6045b5b14888c46d01539a44c22d7224f213057242e0b36f2172d351ed  release/kernels/provswap.log
c9c32a793d54cc7401477f582487f7e8b345b2669a75337b8d6327120d98e5dc  release/kernels/provswap.oracle.jsonl
3dc66723f9973813fdcee1ed741e6ce3a2caa3ca8a20840be1f556d42db74145  release/kernels/provswap.sv-hosted.log
4437fea7d3cabb7b679a51b6fbaa68c1a36d6279b4700d6180b23c063bb47913  release/kernels/retmiss.by_instr.json.gz
c0056f05bf4bc5530d81709f2603cc9ee0abf3a8ef48f17f4a8d93a5093c0a5c  release/kernels/retmiss.by_unit.json.gz
bfbbefd347fefcecce4c062f69411177881642da0b75e77882d3ee0581c76e73  release/kernels/retmiss.ccvtrace
46c94037ae257d4b7bf17452ee1f649da514cb81f2d8828ba5386c306bbc0df5  release/kernels/retmiss.log
e5ef8538e838c6cff7febfc679dd091cf5e002f82d34f1009b1948ce22bc3649  release/kernels/retmiss.oracle.jsonl
0059fc1c3aae7e0ec684c2baf4b65a93e5985e7eb9e87355806d767de846a4fe  release/kernels/retmiss.sv-hosted.log
603d34b3e2ef78fe7c2ee9caba2fa14cb6d65e9ed96577ec8788422100e509cb  release/kernels/roconst.by_instr.json
99d4752384a5073955557493bfaaf8d6c89073d0c28dfdf874716d828bad085b  release/kernels/roconst.by_unit.json
3f308625fba014120ba2ace4c66df0da328b8bb9f88284187036e935af11dcdc  release/kernels/roconst.ccvtrace
8e5c6e0a4ab361addc2605826200c307e17053895d157e1c0dc94e55b0747482  release/kernels/roconst.log
8087c0671de620162881aecd38cd6114b78e7be6bd71201e3ec02c9a2e2e750e  release/kernels/roconst.oracle.jsonl
24d93fe711ec932b8055d84a7cfad74b27774ad15599bc81540eddc45dcef04e  release/kernels/roconst.sv-hosted.log
021eba124835a32b76992f2e974ca3672b5a740356bf16a8537f2142f82cc04d  release/kernels/rogated.by_instr.json
057767bd46924bde6ea65f85a2218e7dbc335f78bec8821153600cb439378c0e  release/kernels/rogated.by_unit.json.gz
f3e4d01deb50c34072147f3b4ac9743b3f805cd081bddc5570306861f48fdbc3  release/kernels/rogated.ccvtrace
0f513c748e879791f8bb64add04b6838da25b97e6909701fe9e9eb6120db744a  release/kernels/rogated.log
7cd02bd4cceec5a044d6b4d6a80df1e68ed0ae71b0b2a953143636d5b809ea6c  release/kernels/rogated.oracle.jsonl
e86a33f4f9233baf2edae905a6836ad1075ce28e2a73ba59f1a05e394c8da55d  release/kernels/rogated.sv-hosted.log
5e8b469d1b9008927902a6cb5442e9e83f0ef9f13b55fa7c172d75acb27c3cf8  release/kernels/rokill.by_instr.json.gz
839a8aa8c9510dd7898ab683fb360ec83406dd13c52397d5d2983bc310517645  release/kernels/rokill.by_unit.json.gz
ff4c2934c06ed81c6d1273e91d72ebb62a6d87f228c416d1690656a5072fac04  release/kernels/rokill.ccvtrace
6d932ff7db834b8c263a3579e55990eece143437356583efbc97c150ed53833c  release/kernels/rokill.log
94efcef96af469a512d346ce61623980fe86383188eaebd55120f716db596f14  release/kernels/rokill.oracle.jsonl
3bc73a59d9251835312026d02ef714bac826bd221b4604edd714b23226186058  release/kernels/rokill.sv-hosted.log
5e07a5e4045bcf852e2aaf47fb8d0f66dc6fadc5b1b953fd2ae889f00dc8d90a  release/kernels/rokilllane.by_instr.json.gz
2c36dfec8600a684ad4d28edb1ba3aafcf751fd552789c10774ca9a5602541f9  release/kernels/rokilllane.by_unit.json.gz
7549afe6896c59bb2f37fa53f994036c055fb96bf2b814ce7b70dd489f7f3cc4  release/kernels/rokilllane.ccvtrace
6deb08deeecfbe55beca74249e1fe8227206565da79932102522a53364ff8584  release/kernels/rokilllane.log
f5ca6e666eff2f44894df74a291b43b3c0e7be0a63a47d795fdefd7b22016f45  release/kernels/rokilllane.oracle.jsonl
1ea25cbd892c2cc87ffcf374db6f7bf18cf57db4d9a88c3652b300f1b5793b34  release/kernels/rokilllane.sv-hosted.log
569cff71dc56456188caca958f14a12768f3c7955945b5b4666dd0aa420f091f  release/kernels/rolaunch.by_instr.json
71c2e34031be2b753efbedd40555ead40760aef4021d4fcd4d64f65485c78962  release/kernels/rolaunch.by_unit.json
1ac753ea9ed608c9c4b4b6172ad5599c088c964fc8cb02e6ca17d9e2261a8b8c  release/kernels/rolaunch.ccvtrace
7d35f7248bf718d392723ad709639cc6dd1857bb749f474804a610f993f690b4  release/kernels/rolaunch.log
e7dad585c3e70615de04330fd03f4f282c29a005dc1732a35655fb261d51139e  release/kernels/rolaunch.oracle.jsonl
f50a8d0b0347bdd0e3d9fc22364c9caf438f2992289565820aa06343d1fe723d  release/kernels/rolaunch.sv-hosted.log
603d34b3e2ef78fe7c2ee9caba2fa14cb6d65e9ed96577ec8788422100e509cb  release/kernels/rolimit.by_instr.json
d92aa8adeb8a29fabf7e3b434e14c21423a947f08e863e13f2bdaa19587258de  release/kernels/rolimit.by_unit.json
fe3bdcdd340b4bfea2de5acc69b5e905c19abba754bcade8832f4bc9587637fd  release/kernels/rolimit.ccvtrace
6d8559621340bdd2429181131cf9e9aec8d66be8abd52c56ca41fbe3eb60de0b  release/kernels/rolimit.log
1c5bc0cb8e8b2e69505fb5a551a16d5d10c56f232b88da7a27e336ad7d962de2  release/kernels/rolimit.oracle.jsonl
0e12966571cd448907146779ba23fe38d3c64397504824ae6e6dadf4225875d3  release/kernels/rolimit.sv-hosted.log
a46c046a980ffe880a7eef65536a56682fd7cdf1ccc4c6f94b0b30965dd338f2  release/kernels/roload.by_instr.json.gz
ed097625a2269f259aeb55eecc560cf2c12ce2af4381a00f2e817a9ade5915a4  release/kernels/roload.by_unit.json.gz
daf6e410d7d2ac715ebbbbcb1e9b59b231ec34d4e160edc4d422b93676dcc296  release/kernels/roload.ccvtrace
0a9ab9ee8d660493d9a856dbbb2bbd6ac4b414903deede2be8e655481dd4ba33  release/kernels/roload.log
f7c1309cc9764769fb5803f6fd0f2f5e1eb418f2d23fbe5e17cf5f9106869fdf  release/kernels/roload.oracle.jsonl
0278ba3ecf78bc427e93019eb0dc6edf28ece9a7df44df53332a483a52c9fa76  release/kernels/roload.sv-hosted.log
854fc6a9ffd68169418ece5ae4cbdc8b195c20a3cb19ee8a501f9427848aef62  release/kernels/rope.by_instr.json.gz
d6daa5403e4448fa5ef77b394c92f253552c657414b6a7db5a08a31d829a4df9  release/kernels/rope.by_unit.json.gz
05e7a6db36c3dd408f960bd4d1797ae391d5a8bd97ad85661fd17d69619631f0  release/kernels/rope.ccvtrace
cb357e6ad859ade227b4fb282f9951c1502cbde1fe14de8d7157c3aceed03a3d  release/kernels/rope.log
d55f9efae392dc8877c102c01c0810e7654b666b6ede386328108164c6cf88f3  release/kernels/rope.oracle.jsonl
2c2a3ad8e9a938678c3852c771c1146f1ce467baa89a48c5144536eb90c2f7e9  release/kernels/rope.sv-hosted.log
3fdc091e608a5b98850407b645ebd5c9c8af7217f9a1c1fc1e38618794097e69  release/kernels/ropediv.by_instr.json.gz
300a823a1a14c7ae5881beface71c3f4725a07029b40892b5b245e23a9d6cc5e  release/kernels/ropediv.by_unit.json.gz
7f4913765afa02a393b311757c4c8ee344f32d9affc8ff7c28acf23787f3ab85  release/kernels/ropediv.ccvtrace
a4cb37bb799b7a568827da987ebb2a111f7883569514ed414ccb217768086ede  release/kernels/ropediv.log
10c0ec6ec18b7b44638c790033109198c079d07c1537bf193353ccedd00a920f  release/kernels/ropediv.oracle.jsonl
c4a6e8fceb9f64ed666ce627a15dacf62466e00e35562fa39a06a9e6d5493453  release/kernels/ropediv.sv-hosted.log
6653f1ae40ef942f4bae82678d6323e5ded6c1a0c0a2c992af1602d5245d0e76  release/kernels/sel.by_instr.json.gz
fadc8d99f4b316772d4bf8fc99ced5f37c1ff76a2ae39e910fc425c098e33fcc  release/kernels/sel.by_unit.json.gz
dd647e12092a643c2a1460c40c481fdb05157296e3be93c0685190fc57d0cd35  release/kernels/sel.ccvtrace
0abc74b8857b58f092ccbf88b09537c3dce7dea2ea1fc596b7e83c5bc4358b71  release/kernels/sel.log
87f6a81e8afa004c8039bf2f61c90176fcf29ab29bb17ac44aa016a5cc8438fe  release/kernels/sel.oracle.jsonl
8a02187da12404746084da9c07c7bc6811b146f5a946ab0bca273a15230387fb  release/kernels/sel.sv-hosted.log
88800a776ff33b44fae2a1c178c4f7897c48bf39a380ac988392d59fb760114c  release/kernels/sized.by_instr.json.gz
accfcd5f57ea6b2581c79b763ece7a9f527c7e72a9ebcb675c59a64ed23e67d5  release/kernels/sized.by_unit.json.gz
bfe021e6fcb2def44b0664d1f590c6248056730c0d50adbff63cb285e95a2bcd  release/kernels/sized.ccvtrace
a0c6604c85a291d13dcf2492f30dbadcf5d4ebe1aaea96fc93609ca71eff1a28  release/kernels/sized.log
36d903ba1618bd1faa437c9812a6ee6c0c966a63196c796267d74bf2695ebc3d  release/kernels/sized.oracle.jsonl
a3be8cb1b9cf509f29b784a3f8cbb7a358bea461e57aa759c1a6a29a0e40ef34  release/kernels/sized.sv-hosted.log
87f849852821a3f04aa60450ea062f089342a5834d3407f4f78a4b6c26824a83  release/kernels/slotform.by_instr.json.gz
e5eeb3c75e982fe2177c43bc617a9c2c54b852a7be7905eeb13be54b8b996607  release/kernels/slotform.by_unit.json.gz
3083add05cf1feff14db90d23aa30358f6222d090978cd1311e6aa9c9da213bc  release/kernels/slotform.ccvtrace
92485bcca80e735783fcb105c952c44fde7cc76464e8eaa21532b3189270e1e1  release/kernels/slotform.log
8b61db7419b18cea8a646fb628218447e72e84a18a9891ffb73b441736138ab9  release/kernels/slotform.oracle.jsonl
07270845fb0c0e5f08e1cf642b6f4b4c3266649d61989e630a227ed1ebaf8d63  release/kernels/slotform.sv-hosted.log
8e0116d6c87d9a923fe4e1df4ead36f178e47a8bbefa8ff553ab3ddd9a42e63c  release/kernels/spinwait.by_instr.json.gz
029dfc0af6ff2fad52992bef310363e130ffd1d8af26296460ae9d2f8479ba92  release/kernels/spinwait.by_unit.json.gz
e1e6e79e8abe3c1cd8ab1b7a3082edbb235b9e5f5b8de9f967ea5c8bd9514fdd  release/kernels/spinwait.ccvtrace
2c9708b298bf666ab7834ff6db2d329de77d487851cc680e728f6db6e9ade457  release/kernels/spinwait.log
868920637236c878b33779bd450439466fc3626996a3164573dc11d437d5c709  release/kernels/spinwait.oracle.jsonl
c48e1a404830c5cdca32a466497b3df2083cda209e5662d88943fb32af02451c  release/kernels/spinwait.sv-hosted.log
cda39c05e7d7cdc6c46c4c78153f361c8b96c3d8577e37fe6c7f723cee089f75  release/kernels/spmbank.by_instr.json.gz
de19b0b5b3ec5c8221fad2f1eb7c5cb07d023b2e7528814dc83205ca3cfe7d58  release/kernels/spmbank.by_unit.json.gz
07b1ee79a22697f03f52c66f26d006d2beff88468d0c195ed2e3ec245ebc3c51  release/kernels/spmbank.ccvtrace
d74dc6882a1c991cad404a516aec6ac019cad26a0f582a802b5c338cbdc22f1d  release/kernels/spmbank.log
3af490cc37d7a92dbe719b57de216b648536eb301ff9d13de9a39f50d150d725  release/kernels/spmbank.oracle.jsonl
cf607c79903907128ad52bea3d87559079d2edd17a09e2dea1bddd39dcf7ca36  release/kernels/spmbank.sv-hosted.log
74a18076124c8acf1d33fe6e105b502315a6efbe826c58990ee43c12563f1342  release/kernels/srd.by_instr.json.gz
42a1a045a975e850e3fd3419b37fb378b9d50a5338066967145c3a699e443ce1  release/kernels/srd.by_unit.json.gz
d61e4dfb34de07aed8e08cfc3fa64c6da1e9c6d0184e8d7953dca6fee93258f8  release/kernels/srd.ccvtrace
3dac8c1caa29d971be728f8551a1b0fff1fb13dd900af7e8448a0a91512eb058  release/kernels/srd.log
b08eb5e3673cac7eebb8b72af5ed3783c8e70a9e96592e76bf3722551bc79473  release/kernels/srd.oracle.jsonl
ab2e76c3340fb6ae1b65ecb5592d40bbdde3d215aae5838ebc17759edc091e83  release/kernels/srd.sv-hosted.log
d8cd479358f63818bbe10ef60d799b4cb9aef91fe7fd9feaf4b8f625972e096d  release/kernels/stall.by_instr.json.gz
05504309a6a414611a66067bcf19e5847f94973a8e6d4a132f342986578306f5  release/kernels/stall.by_unit.json.gz
eb115d257b0d6e1f4a9f3feaeed1392031fab7d9c846825d321f87bf295c5129  release/kernels/stall.ccvtrace
d81cdedb6b5413388e0b9d127ef349f4543b0c2538a78f173675ffee81cedff8  release/kernels/stall.log
500db2c482b07a0706583422cd68878301d0146c1f872ccc1f11bfdcf5c993ef  release/kernels/stall.oracle.jsonl
59c8286e67567060e86fcd52decb0a4e0f58f41e76ae76fc9e8f0647611fb356  release/kernels/stall.sv-hosted.log
d1f705cbe80ab9e8967f639ccbe9fb57e621c16308dadd44b1b8aa5183c94833  release/kernels/swap.by_instr.json.gz
6e3b29933cc9b7843fb2a80fe3edf58008b0df4610b20b28b8e99a9fe0a0300a  release/kernels/swap.by_unit.json.gz
78358f37b30e6a964b01ed202048cf739786bf167ccad8185d2291f18edf25fa  release/kernels/swap.ccvtrace
171e889c4b2165efdeb24c863b5287b261f9e0131a97a2c754268129204ffce3  release/kernels/swap.log
3658a26316c1ff7bc1744304a42f736e930fcde2865c8913e6cc67a22ce96667  release/kernels/swap.oracle.jsonl
e177e2533ba9318444b55810c4f3b283c4caef24a99b3a7745a0e5eccfbe06e5  release/kernels/swap.sv-hosted.log
ac6f461522aa9b13d0f8f9f2da950caa5f3ee92a1889f090daa2a88929053ce2  release/kernels/transp4.by_instr.json.gz
d52c0c3c0c37d33c8eec9aa0bae7f8e8d165b39c4a4901536ea6df20fe79aff5  release/kernels/transp4.by_unit.json.gz
ea582cf8bd5c73f7124e759d9d926fab43df18ec1d81300be7657119e501eeea  release/kernels/transp4.ccvtrace
c9fb608c4e4617468d6efa91af79307adf5fd697a642a0ec4969b54b84b78773  release/kernels/transp4.log
06396ace3ac19677fd39c700e408606e5bdbacb24997d663bbe8872e63dd74fc  release/kernels/transp4.oracle.jsonl
9f887aef830233e2fbae451ec25bd818697fae54efcc71c5821bfefc14877494  release/kernels/transp4.sv-hosted.log
1335bdc225600bb1f2df15fe440e1c2736698952431831c80b22f81fb2b6aa54  release/kernels/unal.by_instr.json.gz
da902c644ed383ccb6338dbd6dd63461d4f9cd3614b131cce2d65326cfd40bf1  release/kernels/unal.by_unit.json.gz
27b99c99f163c010c426be84bef96cb51e5fa6b552aa3760d004decf550e09ea  release/kernels/unal.ccvtrace
51b9b6a1b88b1ea2acf9139fd128660aa81be8de190ec7753a82d203f7a5288f  release/kernels/unal.log
c3d484bb160657a563df983d9a2532eac27f556636617960aa1e72183ac2b299  release/kernels/unal.oracle.jsonl
d7f29d120a7d40e5ee41cb63078b21fa6bb5aa16c82828a1dddbd11ced2624a2  release/kernels/unal.sv-hosted.log
743ffbdb6e3dae09b65c941f8296a6c65a09f0ee6b4b1d953f28e29eff6f441f  release/kernels/vadd.by_instr.json.gz
dcad03ad3c3db8d0d8ee77112f69fb6996ac5074a74a27442b9103fc8cfa613d  release/kernels/vadd.by_unit.json.gz
4b3f52dc9ed3b500b0b1ecca9758ca70de54df2df1d71ac14aa11787001a4654  release/kernels/vadd.ccvtrace
422e86936e03a36fa059f3559750fc2c039f5f32e71710a3372eef0748f8a8ad  release/kernels/vadd.log
0276b6d0611a4bbcdc004ab3987214aea138245bc7217504147331689a9c0880  release/kernels/vadd.oracle.jsonl
b32c46bc28db8c5976d5699a6feea340d0d9d5b1906163b47d1616f8641e475f  release/kernels/vadd.sv-hosted.log
cc559b694a4c23918ffa4c38b930a5b0c10e3cb342185fadef62164b57d7fb33  release/kernels/vadd4.by_instr.json.gz
2bea571f27cf1acd5e02d78d0dc4ede517df994293a9663a6dbf6162c853c398  release/kernels/vadd4.by_unit.json.gz
c45922d8a62b46d0193991e7eb78a7f057de7d2936f01a6052da2f43b0b5dd96  release/kernels/vadd4.ccvtrace
9f810f39bd07a9bc92b582fa1160693e48ce89a5688b7c2697eab7b3befcf7f8  release/kernels/vadd4.log
225aa18fc9f38aa9ad615aa11de254337d59fa705877553d873062c68366e0db  release/kernels/vadd4.oracle.jsonl
2befe1841a085e42d38cb2ca05f27c77d0e99968d1be30a43705384538995ce9  release/kernels/vadd4.sv-hosted.log
2bd8fc80c636ca04c3d1ed887c4fc6654f2f53b2e6c381f22006ba25a8036139  release/kernels/vadd6.by_instr.json.gz
e57ad44b903505cff450a7fc79975b8cf2fef53ddcf8c3d6959905f9bc27caca  release/kernels/vadd6.by_unit.json.gz
316afa3c985ecc510e40cebb3ea0bda78d207774fa0706a38d7e476098bc4f96  release/kernels/vadd6.ccvtrace
a99fe8d6e40c600dd9983d3727bc7e8fcb1fc18517e4a346a532b26ff2170400  release/kernels/vadd6.log
10335385a8b6359c5e8310565561a4a5febfe318ef4ea0a6e537be2d372c54f4  release/kernels/vadd6.oracle.jsonl
0d1cf5d98120ea53e299e4ef523d279d8d4388e0fcc27773f63cd73d28444904  release/kernels/vadd6.sv-hosted.log
066396493d1f697394b7c3b321f24c00ae07fe1a5c4217067420dbf8752a267f  release/kernels/vaddslow.by_instr.json.gz
c1ea8ecb570ffa233a0ca07f7e88b370cdb01f7a496f1b9550d3f6be8bf58d74  release/kernels/vaddslow.by_unit.json.gz
56e31060ffadebaac83b1bad04def18f7d68e31fbbb3d6472b00895f258ae40a  release/kernels/vaddslow.ccvtrace
9088da6be14fd4536bf0a79504e33753941f1d80cc21b3c41899547e5e7bed1e  release/kernels/vaddslow.log
e9e6218e8b8450e9f9ff6b39d659c994a1e51c527a0c5bd10d18b5658ae0e344  release/kernels/vaddslow.oracle.jsonl
06695418a70bb1bf3aead2a21273bd9e3996c786cd30bbc45289c15a15a8b86f  release/kernels/vaddslow.sv-hosted.log
7f98fa112ce71d5c96334afb36db7ab7f47e047c607ed5101b3df0f06915919c  release/kernels/waypred.by_instr.json.gz
1e6c97746fde6d13fa2d3c0d03e5503127e8aa52370dd31c7ef4acc2ff839727  release/kernels/waypred.by_unit.json.gz
4bb4d9a54642ae3c60c9286bc24a3e1a9bbddc5c80a73703715c834d9f953507  release/kernels/waypred.ccvtrace
ed871c9de1bb0dafe72b053aca952b4dc71452a519eab3b1b3365854f4f47b6a  release/kernels/waypred.log
54fb803ce85c4458b8687bb0f61adc32a9d798448b914b06261dc49c2bb841c8  release/kernels/waypred.oracle.jsonl
f2893836a715871fe8fb8476ed01b89c643b6cd5d1571d59876c2187c356caee  release/kernels/waypred.sv-hosted.log
9167b406cdaf4a4ee6bddbc1c3687553ca3a8c60b503c903594828dcdca33949  release/verify.log
f78197fa73514d4391564b6dbfda61c3c03a38e2134c9ddc2d24180f29c72e6c  release/wiring.txt
```
