# Snapshot snapshot-2026-11-22-8ca2bf1

**A generated, read-only snapshot. Do not edit or merge it.** The source
is `ti-l23` at `8ca2bf1bf7cf62b13a87fb180ecc641d133c6fb8`, and this branch is rebuilt from source by
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
| Source | `ti-l23` @ `8ca2bf1bf7cf62b13a87fb180ecc641d133c6fb8` |
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
dbe2e8d7ab4b87d53ab43155f48b3a5681764d6935912ef0e49080a01abac943  release/kernels/addrhigh.by_instr.json.gz
81144db9773ccfd122334f932973372545d4b391700939b1bad9b149cce9153d  release/kernels/addrhigh.by_unit.json.gz
77bc0c3be8e830d8723acdd7c4f9eb29f4078b3115874372bc60e68aa53b7183  release/kernels/addrhigh.ccvtrace
4a4c4ddefad62dd1d282fc68830907f1ef2ef53d2813ccf09451d7c3179f9989  release/kernels/addrhigh.log
569f2e22883fad5f0956c57ec734e6afbdd4b8a854e50277425172d6c0cbd766  release/kernels/addrhigh.oracle.jsonl
be52b30311e254f6e69f2c57375dc6733f7f99f0934e897246b98925c885d171  release/kernels/addrhigh.sv-hosted.log
8c3c69aeee911c0af65ab248e23004dcfbef9189634476f18c376caa596cf842  release/kernels/addrlimit.by_instr.json
3b35fee568600ef154c0e28928da998f194ab417705d71f582090dddfccd0ef7  release/kernels/addrlimit.by_unit.json
468c0908614c5661e9d860b55a9178899a4477c703f33d0f195813e281cd5610  release/kernels/addrlimit.ccvtrace
b2dc457e9293de385f3d65c013a1de7f94b7c22ddcab160c1634f29d03a06f61  release/kernels/addrlimit.log
bc660b0b40359a2c5a2478cb0eb4950b73fd22db50ea76b80052bc195a1920f4  release/kernels/addrlimit.oracle.jsonl
1a3d4b24bad207dd4b85fee19e6074d6444a918c9eb4e0b963d8cede66cbe8f5  release/kernels/addrlimit.sv-hosted.log
d5ee993d0a633a3a0837df8a1267138a4a90d71b0f13f2964db1fac129be4751  release/kernels/addrneg.by_instr.json
d4575a0211ba3cad70a041dab45c9876f749ac9173cd91604056151f0cb47c9b  release/kernels/addrneg.by_unit.json
b64cab0cffa732e5e0822d4d5e4704e4625cec46309de4e9af4fa929274a37fb  release/kernels/addrneg.ccvtrace
5fe710faea2bbaff65e35d140719023a419da1a2aabedb55a56f9222c7071fc7  release/kernels/addrneg.log
16f5b0707ae44492a1efd67bb9dd38a7e79a7bbd354fa9207b9e7d150ff2f107  release/kernels/addrneg.oracle.jsonl
cbb90eb2ec8d3b3cd90e8e3dc4111e2d22d08bf60b4b917c6a793ac743dcc9ad  release/kernels/addrneg.sv-hosted.log
ada8499e84fa23e0c6c79e59ed6b95042b612c66f02b83658fd6831ad988a62a  release/kernels/atom.by_instr.json.gz
419dccb21f243a45de01b5e1b14869c94241ddfb07a90db45658b3663899799d  release/kernels/atom.by_unit.json.gz
e52662d078aed7d484789b3150f99f6c99f9b9821d86a5e9bbd8cd5909299165  release/kernels/atom.ccvtrace
1a5cbd260179b55a68fca93f0da3599eb3523cb7cabfce9ebaa0b4a6b663e882  release/kernels/atom.log
504f5b6e9d25114dc35f2c70b21bb7b3f3c508c691de12dc0e87d12a74285361  release/kernels/atom.oracle.jsonl
9cb113b514fa40f8d4512d3e57454ca6ddd5553b224703365028e57cab7df6b4  release/kernels/atom.sv-hosted.log
fc2c189d69450ef0fa08b909e4623bb042bef69573bca7a2009c3fcefd03d421  release/kernels/atomf.by_instr.json.gz
9df4489982454f860cccee262d3eb7b2b840ef721078dee69c8846274c248bef  release/kernels/atomf.by_unit.json.gz
e249348e60083200e6314e3614e53460618456d16fdd85e004a0cea8ffd17787  release/kernels/atomf.ccvtrace
144740d7b18e5004ecc753719443f483dfec1c62fccbb62793a78a9251834439  release/kernels/atomf.log
cfd1179edf4061a33ab2f75d7a6dec61decfe629000198189a7bfc2647b34238  release/kernels/atomf.oracle.jsonl
a5e592476626a0c13116710becad05bfa54d233e71b1421b2d50c14bce005aef  release/kernels/atomf.sv-hosted.log
1bfceffbf7d4a0b7ddb7d7211de4f1dd3a1d70ec6379583ea6a8708d0dada8cf  release/kernels/borrow.by_instr.json.gz
72eaea66ddcd8cdf221dd8fc78e5e16111c38ba03d39cebbe8cffa29b70f9fd4  release/kernels/borrow.by_unit.json.gz
675e87f1c0e15b984bee253fff4849e79de6b07f83e6e28edfa102cf07f93b18  release/kernels/borrow.ccvtrace
8b80d936bfb5a6a60cbe286213f80e31b9ec6b7c210d1d543ff30c807ff2f890  release/kernels/borrow.log
4c565e1ce0b3baee36e158694b32c8defb5cd662b2f9af75cb5d8c26cb1168ed  release/kernels/borrow.oracle.jsonl
a81bdd2ab5d894293d054f0bf0dd57323eae53ed126571847ee7166b0701aa2a  release/kernels/borrow.sv-hosted.log
3471456d41d40a2a54f7643a6cb135f9e9560ab9b4e9ccacd93a7ead6f130e94  release/kernels/brs.by_instr.json.gz
a1ac68cf5b8d564b5c115b18a30b0b9edae9db9d3d433ccb782290762e4393ff  release/kernels/brs.by_unit.json.gz
dfdc00e3f7e638e036c8544c04704d8c1d4cca764d189ea7aa1e0739036dbfac  release/kernels/brs.ccvtrace
5e167af93ec43444ec4f671e3b35b43f5bf867fe74c8727bb56ddd5a04f12c7e  release/kernels/brs.log
e3c1cb3379580cf1aae44e8ddc8e846ef6fd661a573cfe0a8d4444b18a14dc56  release/kernels/brs.oracle.jsonl
27afd154e6cdf1b6fd230d673c373f3100b56eca4bc3696a44908f393a5a5b25  release/kernels/brs.sv-hosted.log
a4537bd31fcce432cc58aa983dac47cd8350ca81769e5a6a5bc10138b15c5ffd  release/kernels/byp.by_instr.json.gz
985892de890af28c56ec6ef49958479f3d5a810739de4b8be1ee56a7b6da610a  release/kernels/byp.by_unit.json.gz
1fb04b879fcd06185cbcd79e0db7e22f64c7784eebfcb96b8f923b6e165efa01  release/kernels/byp.ccvtrace
684180b85c89aa11dc1e7fbb30ff4b92c30eb4ff4cdf388c75fa9b97c6d2197b  release/kernels/byp.log
5a03dfa4f3603fef49f1e3639e74e34152ca3ca5ef8e41eb959f8323040fa2d5  release/kernels/byp.oracle.jsonl
52e56c94a3557f6546513ffce0d7d703de74a85e3bcbd0b5ea8e1babce950e58  release/kernels/byp.sv-hosted.log
46b5c579330c6b6435ade5ee788e10302c1a883c7fed34798a2557fdef75c42d  release/kernels/callret.by_instr.json.gz
476f62add83c10aedff7bbf017d17aa01844546e5381b9ab47e3cbb59e2823dd  release/kernels/callret.by_unit.json.gz
fc79cb4fe9f9b9f252e851c20fce32bcbd50757bbc898e386566e57505539b55  release/kernels/callret.ccvtrace
2c0f904e2caa2ee78d33bd850eea68448cb9537badda461cddc3c7251d701b89  release/kernels/callret.log
9b1d1b50b527f732362f837250aa2f26dabf3e76e16a4794856ebd8f105635b8  release/kernels/callret.oracle.jsonl
2c1570049a9b72a01adba9395c82e4e1a8176a433ca55ef7c234c1f29c6023db  release/kernels/callret.sv-hosted.log
c54b9639ece07394efc3f8e4705c0db186fead080eb1223e603522444182f3ca  release/kernels/cas.by_instr.json.gz
7a0bffc98b3656cde95a32810a88aa33d77d5d2abbc0d045ba6ff82b958d21e7  release/kernels/cas.by_unit.json.gz
958d832a5f5e0e22e7567c8665c11974d170ad73e94648a2cc141f993a452cf0  release/kernels/cas.ccvtrace
92810ff2b5e5b52cff6b089e5a2f12230372c02ba8b91dc8f5a50bc31001e21c  release/kernels/cas.log
0ab31a9443336fe5d08e1a5fa5fcba3bc279b19022f7c5007908d39d8ef39536  release/kernels/cas.oracle.jsonl
7309538bb6f68d58abba827b9fc7083b2f2744681e561ac3c70ac5420ec4ae44  release/kernels/cas.sv-hosted.log
6f153a6a69889e616c79528802ab213331782ef7b40cd079021db84d0ef4c9de  release/kernels/chains.by_instr.json.gz
ddf3b38ce70d6a7eeb32f878b615c1b2e07b36e99f88f66dcc834d278ace2ace  release/kernels/chains.by_unit.json.gz
f3c7f719a83f93768af61373514062f1b4654c87caae7a6fd23d0307b7b7ca0d  release/kernels/chains.ccvtrace
75a77a76c1d5e9f8f4777e3b28270c21a19d72afb8dff5755dd9e7b0281b7ba1  release/kernels/chains.log
26a4cc5c5524c7219d8706c2582c80357dea60be9d6ffdec99dac7d0365e2264  release/kernels/chains.oracle.jsonl
f21a9f4e9e1ab7065f380c98a03c2fb3e33959f4ba1f37013880d290a2c0d763  release/kernels/chains.sv-hosted.log
066a4cc4d641c897b96256c45bd8e8268b25b3eacb583b862906b7d1a95e4a20  release/kernels/coll.by_instr.json.gz
d1fd842b59b9058087e8924ff54937088718f39ccf2659c27f59922ed79ea406  release/kernels/coll.by_unit.json.gz
b9d0aa1fba37d6865c6e65310ddfdec12b1a406436489ff0c4ce6a811c10cdbf  release/kernels/coll.ccvtrace
fbae6259451785f0230c461784d6fb18d2602508c54ab60941d012b3e464d2be  release/kernels/coll.log
dd718d23c88df5dc7d92b055d8542865aa0e029118486af127312a8a578cfcbc  release/kernels/coll.oracle.jsonl
aff38def3da4683e81ae4c32e0cfb9dc339333758db7d8d46c2d2b6e2a8904f4  release/kernels/coll.sv-hosted.log
2c7cf921fa048d0b9cf198c210a87906896da38270f61016223f8dcbc0a2aa6b  release/kernels/div.by_instr.json.gz
3da84d6aa94f978f429fde14497e2944e1fa05d51265dbd372b5c50702df7134  release/kernels/div.by_unit.json.gz
0fa59319a49569c81f33bc11b669b5cff44d54af88e0e1a0318682d79a62911e  release/kernels/div.ccvtrace
34b679d1c3ad3d2b5ab454412748ea8123a484b3dd821af4c073cabb7f8d8b8e  release/kernels/div.log
71a567b85cf85622631490187563de9a5661099c78a590adff4ed0a0c3d24c16  release/kernels/div.oracle.jsonl
a0a7c356f331845b46c31d5762092ed4bec0b4ca5e03c5ace79963e0a0848028  release/kernels/div.sv-hosted.log
e011572b68f19989a24604198e2843036e5551265c3c9b8acd36a4b0722ac65f  release/kernels/divchw.by_instr.json.gz
5fb6abe6aa2e858479a1cbc443cb74596b5e8869eba66801a4653cac6ed29787  release/kernels/divchw.by_unit.json.gz
7171a5600e2647cfdb103881ce1d051b67e5c0f4b5522ff75b05208ed6ee3d4c  release/kernels/divchw.ccvtrace
fb7a68d1fe67c1bf5473c1da691f2ded3c617cd01507516ebc54dc63d48fa62c  release/kernels/divchw.log
58a541797f7a2df0a1c7528ae6a3edec212db90c7d3eb20656806f38b5c10b3d  release/kernels/divchw.oracle.jsonl
bec2fc6b2563f16d8305732ca14c217a4c81c440691cf880303e933fae1b51cb  release/kernels/divchw.sv-hosted.log
47dec3a8bc3eb881dd9509e3c9b098af133ac01c04cab3d2732f66768a55eb79  release/kernels/divtail.by_instr.json.gz
f950eaaf7128f5c9bd867fd63b0a5097061f10b626af8af34f2158ac8fa3cd33  release/kernels/divtail.by_unit.json.gz
db804fbb5ad528ab14845763f37b3761a0b667c3bab40606320e4d62853ca751  release/kernels/divtail.ccvtrace
48678bf518174b1b1a83d43de0622166240bba01bd75c6c2399c03f2d31d2b22  release/kernels/divtail.log
75f11a75c9b3b336e446140af4579f05b46c363a76b7aab3ec88154a07ba097d  release/kernels/divtail.oracle.jsonl
e44d1ee087c462c1282c9f56150390c85bb366840cee1b3709e725c35b90486c  release/kernels/divtail.sv-hosted.log
c7b8067eb1031a824715da8875978ef97ae0603939bdbd5d96cff2ecfbb347d9  release/kernels/divtail2.by_instr.json.gz
a877aa64596578d247fac528d809c8892d94e230c8d597b80387bb642578f5f5  release/kernels/divtail2.by_unit.json.gz
a75fe12547373cd47764249a890c8e2cff1203790b37cff1678beeeb1c5b2c44  release/kernels/divtail2.ccvtrace
fda7dcc5b150c06c13e0cf3776275c66d4c5e75c345512fb8be501c7f5a8297c  release/kernels/divtail2.log
b2db6b05eb6cf4a0a7677e31d0c6c2952d5cab49d353f0bb1883fe0b2a20ed14  release/kernels/divtail2.oracle.jsonl
8ccf21b3953b7969a21a6b0484fdf655784178c335edac60888b07bc6aa695b5  release/kernels/divtail2.sv-hosted.log
6113ee31293739cb89f7d7e6074ea2fbcec4152d7408f4d35066cbc47c89ab18  release/kernels/fence.by_instr.json
725a14ad6130215afbf977b59a887fa602c9a5752ad52bac423cb4d2329d2b56  release/kernels/fence.by_unit.json.gz
07b3835fa7e99b3db3da294ef152970712d64ccef233069735b96c6ef38d69d6  release/kernels/fence.ccvtrace
d8c05089e2d9c44ed98a10d42c7c1cb71a1738592e9009ad1ee8807726f16bab  release/kernels/fence.log
d1d40317f6cf5bfb430cda1f9c0ef676609e59cabe2a11623c42ffbeca93142b  release/kernels/fence.oracle.jsonl
24cd970bb9d3335979ea968af6ef113728343e2859af77faf6bb4caca27aea1d  release/kernels/fence.sv-hosted.log
7fbde4f978ff5bedaf313994011a88d6b1151e478defac1840e24fddfa1e530b  release/kernels/gather.by_instr.json.gz
4723629c2d2b4ecf3bf9e1eacfcb99ab9b1203040a2fba9a00e373172a364aab  release/kernels/gather.by_unit.json.gz
356d4b42afd03ad920bb11251e6784511c4334d2d1b21cfd452ba496cf31f975  release/kernels/gather.ccvtrace
4c9034956ab8996a5ca7dcf0ea982be1453a774ea7862226858d455833d3e3df  release/kernels/gather.log
0413e781d8d6ff578c64eb1f800b7931e66f676d5cdabb97b94a4033e6037662  release/kernels/gather.oracle.jsonl
89f72927efc0de140bb841e898354b3200e2899b3056ce0d8b023ba4933460ad  release/kernels/gather.sv-hosted.log
37df455c0948e3cd5e758a8e8972b5dbe37ef33a34563433ab9d3ad1ee8ece24  release/kernels/hit.by_instr.json.gz
727da9d9763fc6e9520631c92f44dd0af406a7f53ce8fafeb375840461b10359  release/kernels/hit.by_unit.json.gz
14177cdb44dcac6847993cb29fb18c5d1d31aa434b4b5e92d8935b236f3a1951  release/kernels/hit.ccvtrace
4b588fa3eee2d8a7ac9472702b74e4565629a7c3edd63dfac4219b509ad4e324  release/kernels/hit.log
7ba9603e0088d9164de6528f16ef6a7fa9ce5821c8c12b52cbb3734e39b9fd52  release/kernels/hit.oracle.jsonl
fc157986f7c555466c8b673e196241e912ef3e37cbacca6359937eb363378a6c  release/kernels/hit.sv-hosted.log
217a07320193900ffa4935bb8b28e2d490494170daa9f1c7bb679c44d4218af4  release/kernels/lanectx.by_instr.json.gz
3eb786547e61f5f7c368dff675d080e2756df43afbe199b8783a97b950e9dd41  release/kernels/lanectx.by_unit.json.gz
c8dbd5f0b00e54b370eba6f5c0a9ecb880268f40dc745215cd4be6aa885ebe77  release/kernels/lanectx.ccvtrace
938c05ea161f491989efd7c9f13b9f0788331145920a299dc6b05186410fe23e  release/kernels/lanectx.log
888551babf540db8e3025b82e65ca655013f93eba3c8a65689d069d52a7e6039  release/kernels/lanectx.oracle.jsonl
bde9c9d70b639c0fbaa19253697b50ee4e74c19d0c80a461714f6b5c8c21f808  release/kernels/lanectx.sv-hosted.log
e651e29a9bb8dc91b59fed999c9b73b9671f43694d61dcceab77f835862bc751  release/kernels/lanectx2.by_instr.json.gz
cf385ab3347ff79e8b64964e6cf4130f9e28a968c8efca5a13089da3dc65d830  release/kernels/lanectx2.by_unit.json.gz
094521bea2680f995ee4a3f798f37495a6540cad9569d634523f06847da7341c  release/kernels/lanectx2.ccvtrace
1b8a63975d703d2e8bac20dc5cba6c120837dd3596f41b22032aa5d754d78504  release/kernels/lanectx2.log
45c13056dff5c73ed0c9ece56cc36f929bf335322193c7d5eb38710b1d1dfb02  release/kernels/lanectx2.oracle.jsonl
2f2a8542b714831670ca8cfe4db697ef67c997bf547fd6671c7ebd7a7fe046ee  release/kernels/lanectx2.sv-hosted.log
b52f112bcafa9d3264f08176871af5d49ca104c6eeb2c6b175a1b6eb82965aee  release/kernels/late.by_instr.json.gz
f719f3b97cabefabdafb504b115885121da2e1ffeffc86089dcc58147b683590  release/kernels/late.by_unit.json.gz
56a358da38919c410520ee4f1d55eafb6e4c6c1b4a1995aa4188761859ef6d3b  release/kernels/late.ccvtrace
7bbc08683213142b0dae6430361eaa7238592e30b3e52d59a3995c43016622d7  release/kernels/late.log
86084f6bd747a2cf32acbc0ebd96ebd3e4ef2d8d9e21be49e3ae49290d7927f3  release/kernels/late.oracle.jsonl
16a4322f0b8475815312dfd804f218f99a30f080fd5596a2d0d87db1aa8d1414  release/kernels/late.sv-hosted.log
713a8c7e0047b162e83bc2562fbee7d6660a8f84aab5f16dd8d8afa051c35837  release/kernels/ldpar.by_instr.json.gz
8e39e0eec5a7ce446adf700b5166d6f768104f8bcfba57679ffb3dc75e17a60b  release/kernels/ldpar.by_unit.json.gz
ddd49addaf918696e10fc94de08ea8a643192f00498849772d8e0f02e26f1345  release/kernels/ldpar.ccvtrace
9f52c37eb307bded7d09b799c6a75351c43542a93da8e795dfed057eaabae313  release/kernels/ldpar.log
8ac08538e9c807637babd61b31e340f7461878ada31f0c0b83cd66331cfaf486  release/kernels/ldpar.oracle.jsonl
b2681cbc4b1fd2b502dbfbf023aab28994be5034bc968003913b8b3ad8cfa318  release/kernels/ldpar.sv-hosted.log
77b04038167466eb04b5865024e85a4eb21b2d8ce14a4fe06773bb4885f7b016  release/kernels/lnorm1.by_instr.json.gz
61f6d86ebe4df87c807a5068aae242b897f64d67a283b45ab117936960b9a3b8  release/kernels/lnorm1.by_unit.json.gz
9fc5f9c480b4705e2dd2dd6e69e2a88033876f0810a04316eff021e6014bd65a  release/kernels/lnorm1.ccvtrace
94a983b1b87b00a5383384192d75c28f8b12b9325f92f7483dd79795d07bd222  release/kernels/lnorm1.log
a8d85811af988a1b9fc00db1517300af3d93ec8e589e403d3b9113fa9e0ffc86  release/kernels/lnorm1.oracle.jsonl
b849f0f4fb0336277b1472eb4105f8059fbda4b23921075290b8639266898603  release/kernels/lnorm1.sv-hosted.log
539da5c38a004b72c24f9cf2bf6b03c3e7786f65c6d7290c65f8253e4921ef07  release/kernels/localsp.by_instr.json.gz
327ee5a3765a36b3260c0f9892c45f7905ceaf1764e1b8def4da0768564fa526  release/kernels/localsp.by_unit.json.gz
87878ff18dcbc81cdbe45be1c4f867fda1c2c2c5d032348280ea3c663b00d0bf  release/kernels/localsp.ccvtrace
409398211acac6ca33c070cc63a59165c24d5d26dad4d7f5a63f0812b3b0079f  release/kernels/localsp.log
55e3c9f36e7f7d38c0ddd38903aff4bb4509ae862015c592e6b937ea258042ca  release/kernels/localsp.oracle.jsonl
b7d4a6a29b17effd9ed3b9226dcdcffbd6f3682ae1f4545747a154f90478e988  release/kernels/localsp.sv-hosted.log
cba6bc1a3aaefe9dc20d187b3ae8b48f71fac0fed1f16103312184535d5e0b14  release/kernels/loop.by_instr.json.gz
caebb59b99c41a098c23b18490343f20eb2dec4c0dab4744b74ceda43b19c964  release/kernels/loop.by_unit.json.gz
8e6c9417e35af8bbae117adade5b9d2de71420fc35abe4aae7df581e61dd52a5  release/kernels/loop.ccvtrace
f866d8a4749354e95816291f3c5889b929e80f35dfcb082fbc11fda7ea14042b  release/kernels/loop.log
03ce5920c06c93e93516d8e53c3f7169f14e3593de204eacceffc0b8a3e32016  release/kernels/loop.oracle.jsonl
a8614a66fd3bc5720f4800634a71b5767c994815569a099817736de635fef568  release/kernels/loop.sv-hosted.log
87e795f41f5b544e3a31b9c01c9339afb9b3eaafd0dba474fabafa7b2e301415  release/kernels/merge.by_instr.json.gz
a11abd4c0d57dea20cc6b8ab872a4b14c6af1d578e752fc2d532da76d98a59bb  release/kernels/merge.by_unit.json.gz
7c5c27b8590c634e6a6fa0ce6ebc8afed33e3101ca7690ecc2efe7cde41a32b3  release/kernels/merge.ccvtrace
33e93c9c0c53e8efb684052041ab2cb0e4bcbaa6f7de81b2a0c08e514f458420  release/kernels/merge.log
f96d28815f8756b1f5a45ded53e6170883d2dfa10f9eef0d14b8050b1318164a  release/kernels/merge.oracle.jsonl
d45d10188911cdd11e3a3e21288647707d58116cb4f3d64d41ff1219d97dbe33  release/kernels/merge.sv-hosted.log
b90fc99da9e241de5c9b10353c705829bc3e3db41672cc295a5d06da12918034  release/kernels/missrun.by_instr.json.gz
d1165851383be32fd7ee6b29f5046eea59aa09e15901988994fa17a9d4d30674  release/kernels/missrun.by_unit.json.gz
ade0c926af6b8801ad9a0c584464c80d257bb383968a4ec36f0e3a4053fef56b  release/kernels/missrun.ccvtrace
4782ff541659b0a3fa7be602db5b132e0c8024719642729ae881606e40904ece  release/kernels/missrun.log
531bdaf281e5590774bd2775427f25e4cc0419cf8e3d5b6999843ffe9ef87258  release/kernels/missrun.oracle.jsonl
ee36942c6d940ce8bba2a8a7089716a3c0c8ee6c5132bbeeba0c85a9d5c56b78  release/kernels/missrun.sv-hosted.log
a2ffbb3ae404632e4c0e64b139178252ec2091e78762796158fb3ce2d626b701  release/kernels/mload.by_instr.json.gz
5aeb8bc13836a704f2b0db84b0013ddbd2bcc75113255a2cfca5afc87d72994e  release/kernels/mload.by_unit.json.gz
8349891c8cf45b330da9258046fc2c43ce47b7e0ec3b4793ecf79d4b9191701f  release/kernels/mload.ccvtrace
2e1e63b5d1878fc3bfe5e38a97e4210c5905dc4ed76238e0781e0c1b9e013ac5  release/kernels/mload.log
8000e477b9a95dfb9f0af964e8346acb9d36f1358fd06ffc4ff7cf599d2b8868  release/kernels/mload.oracle.jsonl
5a0f8ebb32c5a9b2b59344396cbc8684ed6af52bb4b0f5844404c0e375228f98  release/kernels/mload.sv-hosted.log
af69b0c2731c37506d9b140e6412f5c0d3d1744c4493f213651dff8253f81e03  release/kernels/mlp.by_instr.json.gz
34fad355de1a389e7be02f38f687194aeb1e622b85f5b4e506603f0eea390d3b  release/kernels/mlp.by_unit.json.gz
20cd6709d3c32211ed6eaef3c8b9c4a5ee5b3016039985849af2985b3dafda4a  release/kernels/mlp.ccvtrace
e2114712ae56119c74d1725c8ebb2604aa0822dd5648d9c3dfc568342d046c85  release/kernels/mlp.log
138d282f88d56c8ad648a91af0a983254b55d9fa22942c00d47b327f516a6e44  release/kernels/mlp.oracle.jsonl
551ac53a54baaaa8f9dbd716dd24c5c338b3a6ea288fa4aeea205d920589307f  release/kernels/mlp.sv-hosted.log
ff664efc67fb8fde03270ab9d52fcbab710717a4efec254b468636b490d95b3c  release/kernels/mwmiss.by_instr.json.gz
885dfe3cc09da8ed8d210beeea8e9545126216c37ce8649cc2d38564a614d08b  release/kernels/mwmiss.by_unit.json.gz
65867eb2557a384f3c51a883e852b728fbc03cffe0a29c9ac4b5502aa5d1de5d  release/kernels/mwmiss.ccvtrace
c62f5039a65e7587ef8c3a44bc659ccd318d97e6472e460c2c25a76e798006c1  release/kernels/mwmiss.log
8abe8e8997456a2a6711ee72da54d854b24e20abbdab28e4b7271c0d28418de8  release/kernels/mwmiss.oracle.jsonl
d2b7cc4b94210e31ea4c63b0ccb5e787a9f65757ac9b71af7bd63fdfe8fe47c2  release/kernels/mwmiss.sv-hosted.log
428ed37f5027657c35b33918bbef3cea1d5ad27b15de8b2debc250228bb6a966  release/kernels/narrowadd.by_instr.json.gz
a4fc01b984b4f86bdbf6f625ad1ee6eea5d2e1265b4b2e7567b95eede9dea29d  release/kernels/narrowadd.by_unit.json.gz
70f3064aa65b7765b7a6b444510e3f09a7cd4c4605374df03aa452b3837b7a5f  release/kernels/narrowadd.ccvtrace
7996f0a3c636f81c340eb845035b44eecf28ff087ae83510fa2c2b3cfa8743d2  release/kernels/narrowadd.log
40a2cf629853dd404bb06b4a07e35abde3d12efc13f26ffe28f923daf2994574  release/kernels/narrowadd.oracle.jsonl
4893deeed4883928afe781af9542281722bb0c2cda91b764fa7712ac754d520e  release/kernels/narrowadd.sv-hosted.log
6cac2a0557dc522a906843d833a7546f66c69354e5df6cdf2972f3fc35bcc5b5  release/kernels/pgcross.by_instr.json.gz
7b9892787a1de07e36e22e5a991be63047637745f5c2c0a16974d237f17321c6  release/kernels/pgcross.by_unit.json.gz
55954f76cdb425f55f73efefc451c9e900e91431f122622f0c5c8b26648d7622  release/kernels/pgcross.ccvtrace
455fe9c66bbc12ad338315206c8a3cd2de560cf97049d79d0a614a1fdf4be3a3  release/kernels/pgcross.log
58aba9ba5ec6a72271191c0249014802cdc7e4470d27491f499a077f17ecc039  release/kernels/pgcross.oracle.jsonl
4d16d10672dab201e85ea0ad20f904bf06d9a07e13fda26c64f4d62bf5f01717  release/kernels/pgcross.sv-hosted.log
be17a921e8bfd9babe31c05ef10f7d298f954679d67715f091cdd70ee96e2c5e  release/kernels/pguard.by_instr.json.gz
4ca3493917f67adfbf4a825286da6b99eeaa6e565c0c62bed8cd76193a95eccc  release/kernels/pguard.by_unit.json.gz
d3a0f73a186c037df930784ca453b1f6217e7443e14b5e2c4715bad84be9ef5d  release/kernels/pguard.ccvtrace
2e514be55c95ff3d12900a08b3aebbaee27987059b21659637bc19cf708eb851  release/kernels/pguard.log
690e56f1cb8d97cbf67124b7dff3ad0a90cb8981814cd1709cf0cd0e035b3bd9  release/kernels/pguard.oracle.jsonl
59cf422f49229a880ca1e88c38ac97c4a22953beb6bec3ad8862e133bc066a33  release/kernels/pguard.sv-hosted.log
ebbdf261719e02298283efbeadb1bde9617aeee3006978b5bba9c83bdb8263d2  release/kernels/plog.by_instr.json.gz
830adf32e702e1f7768c66933a9059900e37bb0f7eeb5f6e3b4f719187a2dfc7  release/kernels/plog.by_unit.json.gz
7823562f75147705b01f772471b6175774023d19935926703e158062b24cf94d  release/kernels/plog.ccvtrace
5dd800c35e450251b77b9013e871ed605a01b3b79d999d146ceaa0132460cb94  release/kernels/plog.log
0c99915e2da60f4670da00504a6371d7d17701d4431e733a3ff8fa98a2030d6a  release/kernels/plog.oracle.jsonl
f61f77877c60e3e1ea39ddd24a3a4c76c99efd89a997c6966ca245eb4a0d9d3c  release/kernels/plog.sv-hosted.log
10b7ce92ed0ee81b2564c6fcb101872c63b8d1c533d8dd03951fb35535a2de2d  release/kernels/pmovdiv.by_instr.json.gz
e3c70afc35cc736211e73f3457616a8a714d09b9579fdadcbdac8460b7de903a  release/kernels/pmovdiv.by_unit.json.gz
da1865544271c3c70d3eab1061f5060d833a856975f75b28d0921880ec954a97  release/kernels/pmovdiv.ccvtrace
1fb7bbeb928dfa33ad6976c7ff0885380d55798d1f12a3986ee5bcb1a2a90d25  release/kernels/pmovdiv.log
7bc646cff6166a51bdce03d7c1b7209e871f0a91d743083a9b910a80bcd0b33f  release/kernels/pmovdiv.oracle.jsonl
c11d3edf795c80af847210e0e2668b1e3539077ddded6879f80e0748b81c98bf  release/kernels/pmovdiv.sv-hosted.log
af70658e1488cf7a4959176821fc76c75f79d9c69175cb14326312ef53c457e9  release/kernels/predlane.by_instr.json.gz
0e5565b3d24bbde9e0281c154ed7e7a4166695dff089f1f57b89c299ebe5ac9f  release/kernels/predlane.by_unit.json.gz
50d80cc740eb64f50d8d451ba21e1c58972991ba64ccd7114c95e774f4a430f9  release/kernels/predlane.ccvtrace
4f5c315278af5d7b7cd1745f5fa1c9586b79966aac23429b40df2a6c11bb04e5  release/kernels/predlane.log
c45f4177b9e84fc8a6e36b13534a0c7636eb30a3f8531847100ce5e23bf404b1  release/kernels/predlane.oracle.jsonl
1bd334bdeaffb8862d86ce56b92232c0272df2eb754cfa2651b23617dbcd424e  release/kernels/predlane.sv-hosted.log
1b1635f6459f071665dfabd130ec31e056bf7ba467dd80fa1718b027b307d971  release/kernels/predmerge.by_instr.json.gz
de29b005bbda784e000d94b4ca173e7d91ba08258187e84cc295878935d1d451  release/kernels/predmerge.by_unit.json.gz
d4fbcf1a0ea13a89d7fdccfc214c4f918257cba14aa024d4ca6250f04d3a7fc8  release/kernels/predmerge.ccvtrace
7faf372c46056a939f4fb2c6eae629cae2f49cc35e1788960b99e85ebeae48d3  release/kernels/predmerge.log
6c737c49434bcd08e3e0814c8b1dbf15c586ae74f7929ba3148ddcee2c62c845  release/kernels/predmerge.oracle.jsonl
9d5e6866236a1fe31bb2c7615b433e47403ffab96a2d4fe3655aec5bf469e30b  release/kernels/predmerge.sv-hosted.log
f153c1a318f4af463467340259c4b9820fff39d9948b26015fa28af1efbf9c85  release/kernels/predspill.by_instr.json.gz
3ddc9d22b82b4ad4aec9b164be4133c4d0f30ae43697588fcd66be96fb35e793  release/kernels/predspill.by_unit.json.gz
68b1af2edfcc1c09bfe4cde2e148b0eaec9035dcca2ce8d1acd4ee551303d76a  release/kernels/predspill.ccvtrace
ce9e896c491b96b3f48d4dd3ced4510e123f4ea336826c1c8cf36006816667fc  release/kernels/predspill.log
b7c84c6478117ffa0f06da0e6ad1e4628e2683426a7911080810e78e06a5242e  release/kernels/predspill.oracle.jsonl
43b2d70ee0c00b8890cef1ce247a6fb509538a295f2fd51affa2272dd0d6a4c3  release/kernels/predspill.sv-hosted.log
21a239834814191e98942d15dcc67efca17a54496ff9b2a5f29f2b36c48153a9  release/kernels/predswap.by_instr.json.gz
57eba33a3d719df697fac8487d4285f811bea99b562d94d488c8b5caa6b651f1  release/kernels/predswap.by_unit.json.gz
cc0bb7da1c9dd84f7a62c74627d792b5662c595294304c08509661b0a072d0f5  release/kernels/predswap.ccvtrace
367395ec06f0de718c1c19353cda3dc36a9252302f0fb689b37cb916384c05db  release/kernels/predswap.log
a6d4f7ed517553816d889c7c9eeb6bcfd1f6c973fbf682ecb69f3c2de619f7bb  release/kernels/predswap.oracle.jsonl
6078e15f367467efc4f65a09693bdae4c7f0458e6dd13fa30eccb5a8c008f855  release/kernels/predswap.sv-hosted.log
679dc503324f006b0d60fc26a11f5754da4a24119f1ce1b9b543c55c2ee53e5e  release/kernels/privwin.by_instr.json.gz
e516ce7b11b43cbe3f8d7a6c6dbb4d64c01f2ffed1ec4c888c479bca3a08e25b  release/kernels/privwin.by_unit.json.gz
b05842fd55756949b74bcf3dd99cc17c0dab77b15911287ab50f3420319bb912  release/kernels/privwin.ccvtrace
4d2979ac4ab0ee9cd7c8cda5ad46d9dc2ca40440c2859d8c1730dab1a5ef056b  release/kernels/privwin.log
861f686fc4480363472908d679d8815e8c957d768e7ab32c826930527b0fb7a8  release/kernels/privwin.oracle.jsonl
2ab9284cda9dbbaa9376c846610d696233cbb6ea89087542a37ee4ccddb84afe  release/kernels/privwin.sv-hosted.log
8aca6b18754bcfbf823e8de64e7760dfbe312a62a26b94d4236530c54bb10efc  release/kernels/provswap.by_instr.json.gz
faa2c360b565781466aa6fa676585ffc9e483498ac130ed086054a2bd1b4bf33  release/kernels/provswap.by_unit.json.gz
71b721e2bd1fc8dd52b36767c301a10981b26e89728d6827c65aaf14dda88f38  release/kernels/provswap.ccvtrace
c51a2d0144d451f0d0bd5c7f01097960b965f1a2a021cf9523c04f8eeb55e5f5  release/kernels/provswap.log
c9c32a793d54cc7401477f582487f7e8b345b2669a75337b8d6327120d98e5dc  release/kernels/provswap.oracle.jsonl
cd20111a51a4d41301b5927290130c85afdb484458e644b9f6371c56a8dbd8d8  release/kernels/provswap.sv-hosted.log
77e29bc1efb6d70430df6fc3c6e43761eaf97e45b3887c924ca5ffee4c3c91be  release/kernels/retmiss.by_instr.json.gz
d539022eb253c4e3469fd4eab92362d30cfdb338c45ab5a76a17a4bb21f305e8  release/kernels/retmiss.by_unit.json.gz
5fd48fe228e08b7647063cef9db1a2d2e027a5a03176463da79fbd5263ed78ab  release/kernels/retmiss.ccvtrace
6741cdcef6adde227ee6f6ae609171e0f30860fc63bd14047ede6239fc8b34e6  release/kernels/retmiss.log
e5ef8538e838c6cff7febfc679dd091cf5e002f82d34f1009b1948ce22bc3649  release/kernels/retmiss.oracle.jsonl
ff543df7f77643f47164920ea91517b5989ea21ec5aa7d00e51ed00964cdcc91  release/kernels/retmiss.sv-hosted.log
b8af37455b33a1b36ab55a477d4761f76bdf9dd3edd8eab5fb7f2c3731ac8ec5  release/kernels/roconst.by_instr.json
1bd6e3d57918f6dc12f88a90fbad3431d9d6ab8123f8959ed02ca7c9430da7dc  release/kernels/roconst.by_unit.json
55981e07a1a8d3ed8b7a9f6797e5f718e3161cc5f6e1218171db77f9b6115f18  release/kernels/roconst.ccvtrace
ff94a2918fb8a411a7bca72900e139969eb9788e56c8839af7eae053dd9185e7  release/kernels/roconst.log
8087c0671de620162881aecd38cd6114b78e7be6bd71201e3ec02c9a2e2e750e  release/kernels/roconst.oracle.jsonl
20ae5b500ed4325725580469e8f6533b62ef2ea6531e2b2ab4cd1ff9bc0cc2b7  release/kernels/roconst.sv-hosted.log
10c797fb8d044649f6d3dee9c07281c225794258b33e21124d781108ba92c747  release/kernels/rogated.by_instr.json
d08ff393f916cda49d4e241adc2fe05439427eee409d878c645b55be9e0f97a9  release/kernels/rogated.by_unit.json.gz
efce29ea7c5e82d9ca9f5522549f4958218e9ae67a9114f6c26c60f34501ba52  release/kernels/rogated.ccvtrace
123202deab65d07ae58b4f5e0d3e057b8240c73d133d058df16afbdf7b8d1355  release/kernels/rogated.log
7cd02bd4cceec5a044d6b4d6a80df1e68ed0ae71b0b2a953143636d5b809ea6c  release/kernels/rogated.oracle.jsonl
2a4b98110a9192314cf8b0b792fada9d370888de69d06f7dd205a96bfdbd4026  release/kernels/rogated.sv-hosted.log
5c119aac01d02769759f0465396e75aa3f2d18b916dbc152922b0be99a8a47ea  release/kernels/rokill.by_instr.json.gz
62a90887fc9a59054f3729920ba5d235c663cb482cf44060834f342a747e0fe2  release/kernels/rokill.by_unit.json.gz
8a540e1a67dce0d3845964ab547fce4b1c674a042f6be8c8d8c8b7dd46f4663e  release/kernels/rokill.ccvtrace
a79d727e80bb32b05293ca69e95d1b3946c235aaa107095c53edf9419f0202e5  release/kernels/rokill.log
94efcef96af469a512d346ce61623980fe86383188eaebd55120f716db596f14  release/kernels/rokill.oracle.jsonl
55c71fec19f790df71bcb75ad6c540e3b9532ff47aae9b1815fc6ef5aef1aabf  release/kernels/rokill.sv-hosted.log
9fd6cdfaa2764bec85e86e62969ac6f4bdfdc684087aa5af15fef3b722bf4ab1  release/kernels/rokilllane.by_instr.json.gz
692a4d2dbea8447a92f32a6ca708b1933b142c73258586fa96866f8260184a78  release/kernels/rokilllane.by_unit.json.gz
c54a973f624a7ad5b95499138a725ad2287a564534121f4f568394896b3522b8  release/kernels/rokilllane.ccvtrace
f595321fb7ad42f9333ba3e2a7cb9bef3dabcfa3db38e03b6675eec8f9bb84dd  release/kernels/rokilllane.log
f5ca6e666eff2f44894df74a291b43b3c0e7be0a63a47d795fdefd7b22016f45  release/kernels/rokilllane.oracle.jsonl
1aaf0ed065c63d178abbf46114e7a7561b8a87e1fd6d1e073282bdaf9c5d0340  release/kernels/rokilllane.sv-hosted.log
6018676757a05a45231fba12ff6df60d07f415338c1d836cc09d99465b73577e  release/kernels/rolaunch.by_instr.json
8512780fe1bbc0571a43ff91654c0ffdb7545b9c1ac040c907e50a29bfbd10d3  release/kernels/rolaunch.by_unit.json
289a78e36e414127402cf1c2f9514ddf7965e2988e5c5c2c172bf77c872262d4  release/kernels/rolaunch.ccvtrace
371d15ae379840f4207401ff871dfc5ae5deffff3e4b1034c83ddbc66f6a3d0d  release/kernels/rolaunch.log
e7dad585c3e70615de04330fd03f4f282c29a005dc1732a35655fb261d51139e  release/kernels/rolaunch.oracle.jsonl
867831baa0222d60150f50070846fc3e0913066ca29d67c16632b98401f1b4b4  release/kernels/rolaunch.sv-hosted.log
b8af37455b33a1b36ab55a477d4761f76bdf9dd3edd8eab5fb7f2c3731ac8ec5  release/kernels/rolimit.by_instr.json
0e20aabf7e39b687a2ade0f80fd977c9d7bd313c2cebdac11d43f35296e7d911  release/kernels/rolimit.by_unit.json
6105e32f751a15c0875d0d2a30a1e054656c0475286b5e2739728e13fa4d3e83  release/kernels/rolimit.ccvtrace
7832f04ccde4ecad3e94da09fd6ef61a15bcf77b29a10fd6cda4cb4c1313b48c  release/kernels/rolimit.log
1c5bc0cb8e8b2e69505fb5a551a16d5d10c56f232b88da7a27e336ad7d962de2  release/kernels/rolimit.oracle.jsonl
c8673c7875020db8b4493bf9f1ddc08599ff02e99872a86ede23339e02a4d3d6  release/kernels/rolimit.sv-hosted.log
7d48a4e491ce31b374638f459be3ac1f5826dac99915d7db5783c19e9b06692a  release/kernels/roload.by_instr.json.gz
2e01a3daf7ea10cd488e8fa4e01d751beabe3efccb4648e4e9b1dfb62321c420  release/kernels/roload.by_unit.json.gz
1578a583d5c4f4db19dc0bd74a872681a3a72c6e6f5b8cde88c5ca1dc140c41e  release/kernels/roload.ccvtrace
fcc3b2d334bdcfcae1f619e84883ff1eac360f81c71aa48b3075b0f907b9b302  release/kernels/roload.log
f7c1309cc9764769fb5803f6fd0f2f5e1eb418f2d23fbe5e17cf5f9106869fdf  release/kernels/roload.oracle.jsonl
0ede7fdab2e146346dc04435509f38a43b7a5c5179b3b54929794f046ed0356e  release/kernels/roload.sv-hosted.log
528d10f23860b4676adfdac8bb12a07102c68cfe732051a242485d485b36c7fc  release/kernels/rope.by_instr.json.gz
cd0f1f5f6cdedc8a58d988ad303e41ba91caa694b0479a7f40a96814c4ad12ff  release/kernels/rope.by_unit.json.gz
c28a1bf8541fe51be00d4bf9cc41210c6cba3db2f220dfca58ceb07bf23f1fb7  release/kernels/rope.ccvtrace
6098bf8f8f071afefe0454906467e7a51b3c29236881e4ac7f18575e79c401b2  release/kernels/rope.log
d55f9efae392dc8877c102c01c0810e7654b666b6ede386328108164c6cf88f3  release/kernels/rope.oracle.jsonl
d1c547be35f77ef94535eba2c9600c602524e43b8cc49e58fd4eb00fa46d71b5  release/kernels/rope.sv-hosted.log
84576cf4165e9204ba87329d387a24cb338e115966cecf6438ff517b24c1a4ae  release/kernels/ropediv.by_instr.json.gz
df1a697aa6ef4d246cd06e590c2c0992bc8e572847122d19f539644b41dfaac7  release/kernels/ropediv.by_unit.json.gz
f3b563b58e4997345f986a68124b88067afacf867bd6c7f3c4f48cf639bdef31  release/kernels/ropediv.ccvtrace
d2435c5275e9e649d73142c96b6858d14a471b268a944dad943def4be7e1a6e1  release/kernels/ropediv.log
10c0ec6ec18b7b44638c790033109198c079d07c1537bf193353ccedd00a920f  release/kernels/ropediv.oracle.jsonl
1aed709a3aa5fdf56a02d5fd2793ca7f8aa99119305dc73994e01fc6a395f8e1  release/kernels/ropediv.sv-hosted.log
68af1491b26874e30d44f38a99e3dbf0b907a62c43babe7cc5708d7702166a3b  release/kernels/sel.by_instr.json.gz
33f130a248cf3f24350503efb8b907e79cf71d115ad0284f60a59b1863ab0fb9  release/kernels/sel.by_unit.json.gz
0e8438b35022c4f1ce3255dded34165aef8dfb098254ae97b0f80b67fffe2c18  release/kernels/sel.ccvtrace
b8f0aea93813d06d71ed246ad987d811e6fdcd29ac2f40c242efe42c9dcf0f24  release/kernels/sel.log
87f6a81e8afa004c8039bf2f61c90176fcf29ab29bb17ac44aa016a5cc8438fe  release/kernels/sel.oracle.jsonl
3cda64b5fb07bdce21af4331783acaf86090a30e20f993d3b1a3c6af6da24440  release/kernels/sel.sv-hosted.log
dccb63880bd68f96158eb9d6a00ea6c57707eacc8e3fc66cd19bfb185fe85dd7  release/kernels/sized.by_instr.json.gz
160a9403d13cfb62cc92c7330e1668bacb8dc8c6e29cf95d0e5be298619e4b6b  release/kernels/sized.by_unit.json.gz
fc2280a2a3c07287069cdcf194669d210c189c42292f2c8f18c06e80ccb1dbbe  release/kernels/sized.ccvtrace
bc2fbc1e9089cb3762a267e1c109b3f0b5eb570ae43e1298d73406da9c1e9db2  release/kernels/sized.log
36d903ba1618bd1faa437c9812a6ee6c0c966a63196c796267d74bf2695ebc3d  release/kernels/sized.oracle.jsonl
371f7346f3f822ece951582ec6ed419a7da205d69f10853488599e42bb8ebe06  release/kernels/sized.sv-hosted.log
c19f4e580264175a0ef5ec10050a657c7bc2e8a2211092774fea1551c26864a2  release/kernels/slotform.by_instr.json.gz
b4a9547d2694d5ba767127a314184c90281d893ee181b3c37a2be624a6b42a5e  release/kernels/slotform.by_unit.json.gz
ff8972a50d2be95058930e607a107394abbccd183eaad7a443dad100e56f5019  release/kernels/slotform.ccvtrace
a6b73850ce6cfb796b5cc1f1d7753f4dedb584e9c17f3b7aff79eb4db6a1a52a  release/kernels/slotform.log
8b61db7419b18cea8a646fb628218447e72e84a18a9891ffb73b441736138ab9  release/kernels/slotform.oracle.jsonl
6d800c3be90bca14a5b4a75d9dfcc76c5f5fdb390c1db795d8aa53945b6a05f5  release/kernels/slotform.sv-hosted.log
ef062294fdd110ad0fdec56126c6396a568de457ab4b73f863579f2bfe946878  release/kernels/spinwait.by_instr.json.gz
c1d85681bc4781cfab58c74a3ed27c979377fc8a689388abaf6fb026e442da5c  release/kernels/spinwait.by_unit.json.gz
96ed0aa7d277284575bad8804bec69409b22c9b86085c7cdf2a3776908b9761f  release/kernels/spinwait.ccvtrace
714ad6121a5cc9b9a35d0abaa7ff923ce127a2ea957acc01451dad385cf1545a  release/kernels/spinwait.log
868920637236c878b33779bd450439466fc3626996a3164573dc11d437d5c709  release/kernels/spinwait.oracle.jsonl
a89f7502a657930761e47cf4fc7b36c41b63d04527f11de3a82786abde4e10a2  release/kernels/spinwait.sv-hosted.log
a6a89032038d37b693701cb868e5d6bb3f51ac27c3cf3c6b032115c5811d92bf  release/kernels/spmbank.by_instr.json.gz
622aa5080d7822b9940f3797376717bc51259a902fdc93ab2fcc16aedd44db7d  release/kernels/spmbank.by_unit.json.gz
0b63ddd199108d5d57dacf8da3b47f37f0c4b36c8ae2b2605a61415aba0d0ef1  release/kernels/spmbank.ccvtrace
6097b6dacb597c0bd06c7e502815be57848570f1c9de4541c4f4618e1025ba1f  release/kernels/spmbank.log
3af490cc37d7a92dbe719b57de216b648536eb301ff9d13de9a39f50d150d725  release/kernels/spmbank.oracle.jsonl
ae1f10cb900ded691b876596a4975da0e46118ff7588ef383bfd30547214d297  release/kernels/spmbank.sv-hosted.log
86f98d68a68313b7d1f7596a8afd816c3181c0a0724ee1be684c5ec62c502a89  release/kernels/srd.by_instr.json.gz
0718a1a24fc1be3154bf182a91c5753fc24ee9179fe48fb864a769fb38daf9f1  release/kernels/srd.by_unit.json.gz
0c47cb484cf0fa4aeccd7dbb998c726c231c62826d2093825653eafe0ebf1c2e  release/kernels/srd.ccvtrace
3457e8d78f7b3da9840d7885eb9b6c0a0244ea0ddda73e0067bffe9e9c98d744  release/kernels/srd.log
b08eb5e3673cac7eebb8b72af5ed3783c8e70a9e96592e76bf3722551bc79473  release/kernels/srd.oracle.jsonl
7af1aa5589a4ba1bd96b46eadb9c19e9e5db5a2d3e8d4e56b020cd50d5d7ccda  release/kernels/srd.sv-hosted.log
dec7d021276540293934d6139e89207d0dc4e83f5918dddf96744f235b1b89dc  release/kernels/stall.by_instr.json.gz
37ecafb04e9e1bb47595e26dbb72c5e2a5502e579da90d5de3b7d4f80f3c17e5  release/kernels/stall.by_unit.json.gz
fdbaf4c7902b755d682cce57fc79287d1b42ac04bc16f363e0ae6381951d354a  release/kernels/stall.ccvtrace
0e83017402b6ebfc90193c3fe1ec1c57697746a8c92242d3bfbbb54e526ce698  release/kernels/stall.log
500db2c482b07a0706583422cd68878301d0146c1f872ccc1f11bfdcf5c993ef  release/kernels/stall.oracle.jsonl
81851a6b54f29278fbd3c1c479c57ab71d6ab901ceb49dd983ecf98316bbf8ef  release/kernels/stall.sv-hosted.log
27558d3caaec19dbe5446dc2ca0fa6d5fd0697f43a3f7e7eec82d19898fec0e2  release/kernels/swap.by_instr.json.gz
2bfb9f790ca26b1883d673d4d4fc4e78fd25a34b443576abbd4efa272cd1ee0f  release/kernels/swap.by_unit.json.gz
e57df079f08803da10c14868ef10984f224605451405d05a7f253f3e19b0b77a  release/kernels/swap.ccvtrace
51b7d55aa98bb09dd8f550da4e6be54998204c11fa0dc48faa94ab523c754bd4  release/kernels/swap.log
3658a26316c1ff7bc1744304a42f736e930fcde2865c8913e6cc67a22ce96667  release/kernels/swap.oracle.jsonl
257feefc6e32097cf08a22e58113abcc1c85b2941d7c791851cfc9a1382aa811  release/kernels/swap.sv-hosted.log
1ebc2afcfa95288de2c2704803f3150bafbea8d7a9e6a25600495d1bc52bd3b2  release/kernels/transp4.by_instr.json.gz
e8306b60ea143b7915595ddbd856eff2d18cc78301d5523bde700e1a68bad969  release/kernels/transp4.by_unit.json.gz
8f2febb448d3affcf9fd137c0f5e513ad3afa69793c63d3f8a51fa6550ab966d  release/kernels/transp4.ccvtrace
a344611b3b1d958cf39c497cdc7f7dbf191db1be0a201f3dad4ae1e756f8a4d6  release/kernels/transp4.log
06396ace3ac19677fd39c700e408606e5bdbacb24997d663bbe8872e63dd74fc  release/kernels/transp4.oracle.jsonl
7864e45baffee037863912e65a0f01c67962ff78a2a46bc9876d93be06a69eae  release/kernels/transp4.sv-hosted.log
e28ace8f2a0308ef51077c38c22818cb4175fd4a9b6b7ba3d9a7518476ce85b2  release/kernels/unal.by_instr.json.gz
e3f18f7ec8dfe009620e25a5e56093d7a8369d13d335b63fcee41825a161a134  release/kernels/unal.by_unit.json.gz
0cd8c220c97c584d454372ee65753f8c7eeab527faa08ee5dea40239360b17f8  release/kernels/unal.ccvtrace
2e3869bbbfb2eaaa261b4d85139f6600a6d0cf6045cc4da02c08f924f14b421a  release/kernels/unal.log
c3d484bb160657a563df983d9a2532eac27f556636617960aa1e72183ac2b299  release/kernels/unal.oracle.jsonl
3b9f047b9bceb4e0b7974b99abca1d192fcc208fb2e6c8a7f84151bc733fbedc  release/kernels/unal.sv-hosted.log
9b29fde2e1b5071c323b666bf8568de9dc7af9dccdc136a47c815c7c0ec0c7e2  release/kernels/vadd.by_instr.json.gz
1e1418866fb3fd8add05c293bf8cf6b144bc4b2cbbbcd0aca3632294488b8db1  release/kernels/vadd.by_unit.json.gz
e325dbc3fdad4e6bbbc3475cfda348ad306843a8c5a0b3ab2737111454ceb121  release/kernels/vadd.ccvtrace
c7d3eabb67601c4c8601f04d4973f022abb56802b1e9542d7547b74980329a69  release/kernels/vadd.log
0276b6d0611a4bbcdc004ab3987214aea138245bc7217504147331689a9c0880  release/kernels/vadd.oracle.jsonl
387548fd1db55998367b9ab184c8afda1d8cff11eeea63d1a341a7fa27cdf96e  release/kernels/vadd.sv-hosted.log
c883fd58bc71cea1f7928786a68c58d463729a5bbec30154323dcd04f7501c88  release/kernels/vadd4.by_instr.json.gz
372bbbe1662b8f69f2f3cce5a028c03f0aa20483f64f03afb56ce60ef1f52535  release/kernels/vadd4.by_unit.json.gz
5edf3b0f5cdc6d57709ad1ea5489bde063b3190c90a27c1f1a43d010b19e7983  release/kernels/vadd4.ccvtrace
75772c0dbc8470d0fbcd62f27f3f9acf9dead3028d2cdb4d80bddcc6fa784795  release/kernels/vadd4.log
225aa18fc9f38aa9ad615aa11de254337d59fa705877553d873062c68366e0db  release/kernels/vadd4.oracle.jsonl
f894cc95e594c91e8fbbedffb0cccffed75fffaaf40d300a52a2c5e696a31a4e  release/kernels/vadd4.sv-hosted.log
f0516d45807ad79354206250aec7873a7905428a5db1047062eebf3c2a771732  release/kernels/vaddslow.by_instr.json.gz
dfd0a7fe403eded7b1ffecae4e5a9ddb2a94c44b0ee2b4a1c5b6095f2f0180e9  release/kernels/vaddslow.by_unit.json.gz
f4edab31577c7354ea3937a41cb1bd675d1b2f6cf11e99ef319d3ce31b4cb878  release/kernels/vaddslow.ccvtrace
3611036e09ac427e98ab9914f8a5a2844abd86e5a4e128e6138044a2eb15db56  release/kernels/vaddslow.log
e9e6218e8b8450e9f9ff6b39d659c994a1e51c527a0c5bd10d18b5658ae0e344  release/kernels/vaddslow.oracle.jsonl
036a379c7c2f5ce9a4cab5c1574d6850f0cef8b2a784766de07ad144b742f483  release/kernels/vaddslow.sv-hosted.log
d95f43a934bac1cc765df81ad268a9f06df41c8de822b45c89c9096ca330546d  release/kernels/waypred.by_instr.json.gz
43e03d883a0341cd167577b5ad6e3a3174f055e3861719643101e12f3b280e20  release/kernels/waypred.by_unit.json.gz
5be72e1d051494726fba08e1bc919a11cd5a7afe6cfd7065564f3a1c0c0c3f24  release/kernels/waypred.ccvtrace
95697c664cbe3a63d683b0e9851efd403eaecb424a41620bb106842bc7ea833b  release/kernels/waypred.log
54fb803ce85c4458b8687bb0f61adc32a9d798448b914b06261dc49c2bb841c8  release/kernels/waypred.oracle.jsonl
f15b713c9e0d6577e01294e9b86cac7aaa0bbccb15d9d62ace4825681d26059f  release/kernels/waypred.sv-hosted.log
f17841a73cfca8e0cd51a03c6ad64b90e58d92ef71574b0f212d6ed8c9a0a508  release/verify.log
f78197fa73514d4391564b6dbfda61c3c03a38e2134c9ddc2d24180f29c72e6c  release/wiring.txt
```
