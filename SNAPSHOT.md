# Snapshot snapshot-2026-11-23-b4930c1

**A generated, read-only snapshot. Do not edit or merge it.** The source
is `ti-di23` at `b4930c1855e87a2a1fa28a7db43f115163cccac3`, and this branch is rebuilt from source by
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
| Source | `ti-di23` @ `b4930c1855e87a2a1fa28a7db43f115163cccac3` |
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
126cc96348b31963dabed1ac9b0cf31943248730663f9d83be90a6e1ff4f24f6  release/kernels/addrhigh.by_instr.json.gz
2331efa1ca9256d0a48ae2db82adafeceb8f10122363d12138996076152c893e  release/kernels/addrhigh.by_unit.json.gz
77bc0c3be8e830d8723acdd7c4f9eb29f4078b3115874372bc60e68aa53b7183  release/kernels/addrhigh.ccvtrace
4a4c4ddefad62dd1d282fc68830907f1ef2ef53d2813ccf09451d7c3179f9989  release/kernels/addrhigh.log
569f2e22883fad5f0956c57ec734e6afbdd4b8a854e50277425172d6c0cbd766  release/kernels/addrhigh.oracle.jsonl
45901986a16519f87b6ef31f00f2f086640451970493cdea5bc0307632241dbc  release/kernels/addrhigh.sv-hosted.log
8c3c69aeee911c0af65ab248e23004dcfbef9189634476f18c376caa596cf842  release/kernels/addrlimit.by_instr.json
3b35fee568600ef154c0e28928da998f194ab417705d71f582090dddfccd0ef7  release/kernels/addrlimit.by_unit.json
468c0908614c5661e9d860b55a9178899a4477c703f33d0f195813e281cd5610  release/kernels/addrlimit.ccvtrace
b2dc457e9293de385f3d65c013a1de7f94b7c22ddcab160c1634f29d03a06f61  release/kernels/addrlimit.log
bc660b0b40359a2c5a2478cb0eb4950b73fd22db50ea76b80052bc195a1920f4  release/kernels/addrlimit.oracle.jsonl
9470709dd3ad160f6811d19b2ee0b2f3b0311f97a3befcf71ee38fa09b128042  release/kernels/addrlimit.sv-hosted.log
d5ee993d0a633a3a0837df8a1267138a4a90d71b0f13f2964db1fac129be4751  release/kernels/addrneg.by_instr.json
d4575a0211ba3cad70a041dab45c9876f749ac9173cd91604056151f0cb47c9b  release/kernels/addrneg.by_unit.json
b64cab0cffa732e5e0822d4d5e4704e4625cec46309de4e9af4fa929274a37fb  release/kernels/addrneg.ccvtrace
5fe710faea2bbaff65e35d140719023a419da1a2aabedb55a56f9222c7071fc7  release/kernels/addrneg.log
16f5b0707ae44492a1efd67bb9dd38a7e79a7bbd354fa9207b9e7d150ff2f107  release/kernels/addrneg.oracle.jsonl
0dce9cfd7a445ec1905abf20537c5c95ce87846d055ba7fafbd1db08f232d403  release/kernels/addrneg.sv-hosted.log
b13eddc4d7882c974273e3a577f1cfc4782d9a24e10adccc618adcb10d76e809  release/kernels/atom.by_instr.json.gz
2e40b6bab20e338ab113e8c4555a79c4a652c9949f64e9a79dd8322ec49e2421  release/kernels/atom.by_unit.json.gz
e52662d078aed7d484789b3150f99f6c99f9b9821d86a5e9bbd8cd5909299165  release/kernels/atom.ccvtrace
1a5cbd260179b55a68fca93f0da3599eb3523cb7cabfce9ebaa0b4a6b663e882  release/kernels/atom.log
504f5b6e9d25114dc35f2c70b21bb7b3f3c508c691de12dc0e87d12a74285361  release/kernels/atom.oracle.jsonl
fea3a92fbbcc47bf9bfb4b475280ad2ece09eca7370eff7e2171a12add39080f  release/kernels/atom.sv-hosted.log
81c30f57ebc6ddba010b97bfd60f45c3a85b22ed5656b8173a9cabd3e480484a  release/kernels/atomf.by_instr.json.gz
c32479d1da271f386d5a52b1266b851f6689806fa0b09e98497ce65c4e9c951f  release/kernels/atomf.by_unit.json.gz
e249348e60083200e6314e3614e53460618456d16fdd85e004a0cea8ffd17787  release/kernels/atomf.ccvtrace
144740d7b18e5004ecc753719443f483dfec1c62fccbb62793a78a9251834439  release/kernels/atomf.log
cfd1179edf4061a33ab2f75d7a6dec61decfe629000198189a7bfc2647b34238  release/kernels/atomf.oracle.jsonl
a0a4f13d08da9e5170b0760dff2e7e9ad07b02853e2b4cdbeb519c6b820de996  release/kernels/atomf.sv-hosted.log
0180d6f6253411e8ea8be11ec0451f411a7bf0b2a4f06f40612d21e8d5970c53  release/kernels/borrow.by_instr.json.gz
89aaf56598f6656dd4172ab16fe1aa3d0a842bf0446148b027b55887ea6a03f8  release/kernels/borrow.by_unit.json.gz
675e87f1c0e15b984bee253fff4849e79de6b07f83e6e28edfa102cf07f93b18  release/kernels/borrow.ccvtrace
8b80d936bfb5a6a60cbe286213f80e31b9ec6b7c210d1d543ff30c807ff2f890  release/kernels/borrow.log
4c565e1ce0b3baee36e158694b32c8defb5cd662b2f9af75cb5d8c26cb1168ed  release/kernels/borrow.oracle.jsonl
1379197954be3b10357d6bf21137ea83a011d463375fa0bda8e0c369c840a709  release/kernels/borrow.sv-hosted.log
46d41db19e683c47a52bb8db4612ce77bc2a31c576840cd3a81d7a1a43eefcd6  release/kernels/brs.by_instr.json.gz
81d0c04259bd52b90a1ab559acb5a00e66807d856ee29ba0f80c7d40ee42fb12  release/kernels/brs.by_unit.json.gz
dfdc00e3f7e638e036c8544c04704d8c1d4cca764d189ea7aa1e0739036dbfac  release/kernels/brs.ccvtrace
5e167af93ec43444ec4f671e3b35b43f5bf867fe74c8727bb56ddd5a04f12c7e  release/kernels/brs.log
e3c1cb3379580cf1aae44e8ddc8e846ef6fd661a573cfe0a8d4444b18a14dc56  release/kernels/brs.oracle.jsonl
12e9f7400a55a9fcfd115c875a7059f6c4f0fe9ff4beb53578d83d79ff8bcd35  release/kernels/brs.sv-hosted.log
57b926bd3c714857375a6c1b310ffac31c9202046bdda1d77871ed8da0d4914d  release/kernels/byp.by_instr.json.gz
dccdc94b549060fba3db59e61cfb6081e4103aa7c13b3b693ed4f714f0d901a4  release/kernels/byp.by_unit.json.gz
1fb04b879fcd06185cbcd79e0db7e22f64c7784eebfcb96b8f923b6e165efa01  release/kernels/byp.ccvtrace
684180b85c89aa11dc1e7fbb30ff4b92c30eb4ff4cdf388c75fa9b97c6d2197b  release/kernels/byp.log
5a03dfa4f3603fef49f1e3639e74e34152ca3ca5ef8e41eb959f8323040fa2d5  release/kernels/byp.oracle.jsonl
fb5fab0fe6c262083e09be2c9718992bd72361ea96d2188c39af3a36df20b6a6  release/kernels/byp.sv-hosted.log
0855de5e16a8cf7fbdd0443cda094fd1450da1c7d2927648700177108467f918  release/kernels/callret.by_instr.json.gz
6506529f91280a4923ca20e30deb8a4369e24bde9c81af7b9377c616ea2124e2  release/kernels/callret.by_unit.json.gz
fc79cb4fe9f9b9f252e851c20fce32bcbd50757bbc898e386566e57505539b55  release/kernels/callret.ccvtrace
2c0f904e2caa2ee78d33bd850eea68448cb9537badda461cddc3c7251d701b89  release/kernels/callret.log
9b1d1b50b527f732362f837250aa2f26dabf3e76e16a4794856ebd8f105635b8  release/kernels/callret.oracle.jsonl
7ad1c43455535861ee6d65e5db23b0e02db5b1f3700f6eb1797230e9b133a071  release/kernels/callret.sv-hosted.log
cd90e136c0f404ba736106501a8760b74cf8bd8fa9aff8c8ba8a59c1eb48dbc8  release/kernels/cas.by_instr.json.gz
4fa12d7499539467a9d1a0188e0dbdd8638b56dc733561e4d1ea6a976dbc0898  release/kernels/cas.by_unit.json.gz
958d832a5f5e0e22e7567c8665c11974d170ad73e94648a2cc141f993a452cf0  release/kernels/cas.ccvtrace
92810ff2b5e5b52cff6b089e5a2f12230372c02ba8b91dc8f5a50bc31001e21c  release/kernels/cas.log
0ab31a9443336fe5d08e1a5fa5fcba3bc279b19022f7c5007908d39d8ef39536  release/kernels/cas.oracle.jsonl
baeaa068de8105727c29e126b8047ef72c50e989d33ceb4cbbf4d3f2355685ef  release/kernels/cas.sv-hosted.log
115ee13a826485e2277220587cb5a26c8c6a4f222a282b329f8dfc35b05913e1  release/kernels/chains.by_instr.json.gz
b7cc9b67c0dee1cfd182f4288d1f1b2458748ea62a64c1197d6945bee27e7bb0  release/kernels/chains.by_unit.json.gz
f3c7f719a83f93768af61373514062f1b4654c87caae7a6fd23d0307b7b7ca0d  release/kernels/chains.ccvtrace
75a77a76c1d5e9f8f4777e3b28270c21a19d72afb8dff5755dd9e7b0281b7ba1  release/kernels/chains.log
26a4cc5c5524c7219d8706c2582c80357dea60be9d6ffdec99dac7d0365e2264  release/kernels/chains.oracle.jsonl
bee0ae796a9e9f91e028767d1a9049371d9be003444f31d486e0ad6fcd6ae869  release/kernels/chains.sv-hosted.log
c1acefa79ff5edc6b438754ce9dfc74ef96f5f7925c78c3feec76f93ef779802  release/kernels/coll.by_instr.json.gz
2f64cc4df0603140a6e542a5d2830b2e2fcf4c7aa091cf77f584be013bd71bdd  release/kernels/coll.by_unit.json.gz
b9d0aa1fba37d6865c6e65310ddfdec12b1a406436489ff0c4ce6a811c10cdbf  release/kernels/coll.ccvtrace
fbae6259451785f0230c461784d6fb18d2602508c54ab60941d012b3e464d2be  release/kernels/coll.log
dd718d23c88df5dc7d92b055d8542865aa0e029118486af127312a8a578cfcbc  release/kernels/coll.oracle.jsonl
d1404744d3d0fbe260cca27dae316e8812037d5f0a197fdb48116d6b6f0b8f49  release/kernels/coll.sv-hosted.log
278b6ffae65c6c67563f4995f9fa978087f70f6d2a707ad8781ee99846dc9093  release/kernels/div.by_instr.json.gz
10399002de75faf4ddd06884b9f8475cecb1e199fc8cc94e5da1a80eb71ce215  release/kernels/div.by_unit.json.gz
0fa59319a49569c81f33bc11b669b5cff44d54af88e0e1a0318682d79a62911e  release/kernels/div.ccvtrace
34b679d1c3ad3d2b5ab454412748ea8123a484b3dd821af4c073cabb7f8d8b8e  release/kernels/div.log
71a567b85cf85622631490187563de9a5661099c78a590adff4ed0a0c3d24c16  release/kernels/div.oracle.jsonl
7451d938545d1db068e9e791e72034231b6c83ee21ab4d3bbf42e7c4af05bdbb  release/kernels/div.sv-hosted.log
089cc4f9ebdcabf8dfae3ab95f7b245a2a83f439d16e2db4a6f0a92c597916ac  release/kernels/divchw.by_instr.json.gz
f8e891af0ca9e96b1c024eb85dbeab307586af64f1c603870dfe876cdf1236f7  release/kernels/divchw.by_unit.json.gz
7171a5600e2647cfdb103881ce1d051b67e5c0f4b5522ff75b05208ed6ee3d4c  release/kernels/divchw.ccvtrace
fb7a68d1fe67c1bf5473c1da691f2ded3c617cd01507516ebc54dc63d48fa62c  release/kernels/divchw.log
58a541797f7a2df0a1c7528ae6a3edec212db90c7d3eb20656806f38b5c10b3d  release/kernels/divchw.oracle.jsonl
5a357a25db8996a8d1e130495d762a25568a1f50821e6c0da0d85f47123d0ebe  release/kernels/divchw.sv-hosted.log
fd483eb62a63ef92bc0a88bdd813b3f2b91240638fc9c7902ce69fca6fa7cfae  release/kernels/divtail.by_instr.json.gz
93f65fdb79f1bcd86bd062b49a292219977e0960cc1a76970ccdb3676d7da619  release/kernels/divtail.by_unit.json.gz
db804fbb5ad528ab14845763f37b3761a0b667c3bab40606320e4d62853ca751  release/kernels/divtail.ccvtrace
48678bf518174b1b1a83d43de0622166240bba01bd75c6c2399c03f2d31d2b22  release/kernels/divtail.log
75f11a75c9b3b336e446140af4579f05b46c363a76b7aab3ec88154a07ba097d  release/kernels/divtail.oracle.jsonl
66bcf4f6a6433d199fd2e16c5244b2ecf72f93417680129bbd7e3f3e0ffef94b  release/kernels/divtail.sv-hosted.log
3843e1c6bb827dc7a7090812c76a8b1dc68f771e8647ff7a776dd1cca52f7c76  release/kernels/divtail2.by_instr.json.gz
6b1ecf1073cdd81190df5879e36dd33b749963be474f7d0dd89af88b7653cdd5  release/kernels/divtail2.by_unit.json.gz
a75fe12547373cd47764249a890c8e2cff1203790b37cff1678beeeb1c5b2c44  release/kernels/divtail2.ccvtrace
fda7dcc5b150c06c13e0cf3776275c66d4c5e75c345512fb8be501c7f5a8297c  release/kernels/divtail2.log
b2db6b05eb6cf4a0a7677e31d0c6c2952d5cab49d353f0bb1883fe0b2a20ed14  release/kernels/divtail2.oracle.jsonl
1ec8a9c2af947ac8cba7bd5abae3bbf3d029348e92baf8de50b012ffa3c70836  release/kernels/divtail2.sv-hosted.log
6113ee31293739cb89f7d7e6074ea2fbcec4152d7408f4d35066cbc47c89ab18  release/kernels/fence.by_instr.json
839031c7aeb14e9fe4650b5572b895aafd533a761db9717ff6e017521e46b356  release/kernels/fence.by_unit.json.gz
07b3835fa7e99b3db3da294ef152970712d64ccef233069735b96c6ef38d69d6  release/kernels/fence.ccvtrace
d8c05089e2d9c44ed98a10d42c7c1cb71a1738592e9009ad1ee8807726f16bab  release/kernels/fence.log
d1d40317f6cf5bfb430cda1f9c0ef676609e59cabe2a11623c42ffbeca93142b  release/kernels/fence.oracle.jsonl
8dd77917ff6430691567ecac7936a4da63345d9e1f61c3c0e2854fab2a881d8a  release/kernels/fence.sv-hosted.log
9b9eba39ffda9036d3a7edaa8a6b27a228c3e1aed389e8e176ce05bd47a40d87  release/kernels/gather.by_instr.json.gz
248060e67b215547563fcb206a2b892c946919f88d5c24c10197a87cef2b65ba  release/kernels/gather.by_unit.json.gz
356d4b42afd03ad920bb11251e6784511c4334d2d1b21cfd452ba496cf31f975  release/kernels/gather.ccvtrace
4c9034956ab8996a5ca7dcf0ea982be1453a774ea7862226858d455833d3e3df  release/kernels/gather.log
0413e781d8d6ff578c64eb1f800b7931e66f676d5cdabb97b94a4033e6037662  release/kernels/gather.oracle.jsonl
db9706601107b915df0c657ac675408b0e3e9a9c46add6a54716bbeb2f043757  release/kernels/gather.sv-hosted.log
379734864c1b29bf7af5ae5d385c3a3982a5aa40f450a41f5c09850684ba79ac  release/kernels/hit.by_instr.json.gz
242a26f6bba61f2613e1d0bae2d281e1200366261a7682b58efc2d2804964790  release/kernels/hit.by_unit.json.gz
14177cdb44dcac6847993cb29fb18c5d1d31aa434b4b5e92d8935b236f3a1951  release/kernels/hit.ccvtrace
4b588fa3eee2d8a7ac9472702b74e4565629a7c3edd63dfac4219b509ad4e324  release/kernels/hit.log
7ba9603e0088d9164de6528f16ef6a7fa9ce5821c8c12b52cbb3734e39b9fd52  release/kernels/hit.oracle.jsonl
ec473c6180936ad49e489a10998742e24c7dd464692245cec79b33e0b2f40148  release/kernels/hit.sv-hosted.log
a86613ae0ec0990b71afb9bd13f183934301d701f3531981b20865d973a04026  release/kernels/lanectx.by_instr.json.gz
0655cf6bc7075e8aa59476d24bceb9e92ee44309e27e94cc9d9048ea72abc945  release/kernels/lanectx.by_unit.json.gz
c8dbd5f0b00e54b370eba6f5c0a9ecb880268f40dc745215cd4be6aa885ebe77  release/kernels/lanectx.ccvtrace
938c05ea161f491989efd7c9f13b9f0788331145920a299dc6b05186410fe23e  release/kernels/lanectx.log
888551babf540db8e3025b82e65ca655013f93eba3c8a65689d069d52a7e6039  release/kernels/lanectx.oracle.jsonl
26287223ecea0779c253840302c43ba7812c6a9d179c35d6d528e853d00da145  release/kernels/lanectx.sv-hosted.log
e39938c6a48547b89e3c11e6a54b880e77e3de8518c4e78a6337f451a1f30636  release/kernels/lanectx2.by_instr.json.gz
ad01a8fb5d4c9e1f17a257a7b2f94136c428c76c5ab260e4fa694e396134f8a6  release/kernels/lanectx2.by_unit.json.gz
094521bea2680f995ee4a3f798f37495a6540cad9569d634523f06847da7341c  release/kernels/lanectx2.ccvtrace
1b8a63975d703d2e8bac20dc5cba6c120837dd3596f41b22032aa5d754d78504  release/kernels/lanectx2.log
45c13056dff5c73ed0c9ece56cc36f929bf335322193c7d5eb38710b1d1dfb02  release/kernels/lanectx2.oracle.jsonl
f4a443d6b0334ff25ce991e36e02f28d63e5093b57bfffbb2a66211bdafa31d7  release/kernels/lanectx2.sv-hosted.log
38533c79aab431238ac65f219b2fe14f332af4965e774b317cbda7082e49c890  release/kernels/late.by_instr.json.gz
1d6b434d337fda369afea7c1eb1cf9fb868ec8100bc9a5efe5be14a997e12fb6  release/kernels/late.by_unit.json.gz
56a358da38919c410520ee4f1d55eafb6e4c6c1b4a1995aa4188761859ef6d3b  release/kernels/late.ccvtrace
7bbc08683213142b0dae6430361eaa7238592e30b3e52d59a3995c43016622d7  release/kernels/late.log
86084f6bd747a2cf32acbc0ebd96ebd3e4ef2d8d9e21be49e3ae49290d7927f3  release/kernels/late.oracle.jsonl
6bbd30e1fb8fcc3a6255f85274c92cdd0ccb46c10ff565177f63fab4abdde68e  release/kernels/late.sv-hosted.log
83166a345e6df5389f186803ea6f544ec23eef893655c87949f8f519c0840808  release/kernels/ldpar.by_instr.json.gz
185b5bb82ebca8b7c4971ba51090964d6fb22faadd622129caaf2225f9d77746  release/kernels/ldpar.by_unit.json.gz
ddd49addaf918696e10fc94de08ea8a643192f00498849772d8e0f02e26f1345  release/kernels/ldpar.ccvtrace
9f52c37eb307bded7d09b799c6a75351c43542a93da8e795dfed057eaabae313  release/kernels/ldpar.log
8ac08538e9c807637babd61b31e340f7461878ada31f0c0b83cd66331cfaf486  release/kernels/ldpar.oracle.jsonl
3a5ca6eafd189f55848b504c470afa4a79123274e201767b8c0890d1c83e95df  release/kernels/ldpar.sv-hosted.log
de29cae5d7eb6bc737c82b6c088a9dc35f3f613ca515457d2e9ae47d6316a464  release/kernels/lnorm1.by_instr.json.gz
2917493665c3b807d179b8f884eb5c807ff31485d81bec937bfc3bbdfea189a5  release/kernels/lnorm1.by_unit.json.gz
9fc5f9c480b4705e2dd2dd6e69e2a88033876f0810a04316eff021e6014bd65a  release/kernels/lnorm1.ccvtrace
94a983b1b87b00a5383384192d75c28f8b12b9325f92f7483dd79795d07bd222  release/kernels/lnorm1.log
a8d85811af988a1b9fc00db1517300af3d93ec8e589e403d3b9113fa9e0ffc86  release/kernels/lnorm1.oracle.jsonl
32dd27cd349bc3686a45e49c94c7be824e01148ef5bd0a178f8773f26fc3ec09  release/kernels/lnorm1.sv-hosted.log
2e1e9039f7825df1ff40bb2a6623e8f144791769f6657d0509b5de093f71a31a  release/kernels/localsp.by_instr.json.gz
285f77ac5ea6771471fd0808fe6099fd3e949f558702d05726d47c3e0efcd8aa  release/kernels/localsp.by_unit.json.gz
87878ff18dcbc81cdbe45be1c4f867fda1c2c2c5d032348280ea3c663b00d0bf  release/kernels/localsp.ccvtrace
409398211acac6ca33c070cc63a59165c24d5d26dad4d7f5a63f0812b3b0079f  release/kernels/localsp.log
55e3c9f36e7f7d38c0ddd38903aff4bb4509ae862015c592e6b937ea258042ca  release/kernels/localsp.oracle.jsonl
bc2d97aaa0ed63b8acb9adf021f2078a1c4fecdf023edfb2776f6a4b5dc3efaf  release/kernels/localsp.sv-hosted.log
377b12b4fc97911918b884984c79b0e37e30f1a69d371fa0c6ba20e97d125d17  release/kernels/loop.by_instr.json.gz
afa81fe4fc8aac31cad6e01e06f6961e664a25b2db9c1e5fa14c8f4574013d36  release/kernels/loop.by_unit.json.gz
8e6c9417e35af8bbae117adade5b9d2de71420fc35abe4aae7df581e61dd52a5  release/kernels/loop.ccvtrace
f866d8a4749354e95816291f3c5889b929e80f35dfcb082fbc11fda7ea14042b  release/kernels/loop.log
03ce5920c06c93e93516d8e53c3f7169f14e3593de204eacceffc0b8a3e32016  release/kernels/loop.oracle.jsonl
155a287d3b050c200e9a612dde2a2c0f09905fd46a65fd86adcc6b117e564854  release/kernels/loop.sv-hosted.log
27c0246c70e09702b3436e481b68467280e470782777c1d54417828279a1c6ef  release/kernels/merge.by_instr.json.gz
1d27e1b99e1873d7463a01511334b4b57b00f626ea2675a6fdba071137fa9aef  release/kernels/merge.by_unit.json.gz
7c5c27b8590c634e6a6fa0ce6ebc8afed33e3101ca7690ecc2efe7cde41a32b3  release/kernels/merge.ccvtrace
33e93c9c0c53e8efb684052041ab2cb0e4bcbaa6f7de81b2a0c08e514f458420  release/kernels/merge.log
f96d28815f8756b1f5a45ded53e6170883d2dfa10f9eef0d14b8050b1318164a  release/kernels/merge.oracle.jsonl
671ecc77f593f41a3620437e8305d6fe128281ef0413fa9a15a6d11a78abf3c8  release/kernels/merge.sv-hosted.log
96cfe123e2652d8f7c46ff7a3caba1c10bf8e07b6bb552a09ee24b9f68fc300a  release/kernels/missrun.by_instr.json.gz
c55a270e15fba08e91881522f7164a487adcc1d306ed850d308175fdc19314f2  release/kernels/missrun.by_unit.json.gz
ade0c926af6b8801ad9a0c584464c80d257bb383968a4ec36f0e3a4053fef56b  release/kernels/missrun.ccvtrace
4782ff541659b0a3fa7be602db5b132e0c8024719642729ae881606e40904ece  release/kernels/missrun.log
531bdaf281e5590774bd2775427f25e4cc0419cf8e3d5b6999843ffe9ef87258  release/kernels/missrun.oracle.jsonl
d46a7613d6801e9783e134d04137886521472f96a56f45bb40615beae0b0a297  release/kernels/missrun.sv-hosted.log
6a7dfcea2572c33f0beca79d5471e1a48bfe27c08f3adb407c00e13e4360fcf0  release/kernels/mload.by_instr.json.gz
a113be4c169cdfee6f29f9fbcf849dce4044fe905f1db40e750ab0d9fb455e54  release/kernels/mload.by_unit.json.gz
8349891c8cf45b330da9258046fc2c43ce47b7e0ec3b4793ecf79d4b9191701f  release/kernels/mload.ccvtrace
2e1e63b5d1878fc3bfe5e38a97e4210c5905dc4ed76238e0781e0c1b9e013ac5  release/kernels/mload.log
8000e477b9a95dfb9f0af964e8346acb9d36f1358fd06ffc4ff7cf599d2b8868  release/kernels/mload.oracle.jsonl
d5982326aafd707b54af29c8dd8682343f91edae3982c209e6c90f9a05105750  release/kernels/mload.sv-hosted.log
8a7badc82799a06e74b964be0fa66ae0e5bf8ca26fb35057cf2624c61438a566  release/kernels/mlp.by_instr.json.gz
ebcd601465102a9f67f8cfb5d02fc75b524c97a37fd4229525d317c9d4ebe77a  release/kernels/mlp.by_unit.json.gz
20cd6709d3c32211ed6eaef3c8b9c4a5ee5b3016039985849af2985b3dafda4a  release/kernels/mlp.ccvtrace
e2114712ae56119c74d1725c8ebb2604aa0822dd5648d9c3dfc568342d046c85  release/kernels/mlp.log
138d282f88d56c8ad648a91af0a983254b55d9fa22942c00d47b327f516a6e44  release/kernels/mlp.oracle.jsonl
e9d26dc1fcadbd197b67d7f20d6475c94aa11be9a4994e2d9b5a09a8d8b5c9d0  release/kernels/mlp.sv-hosted.log
4173457d9de723c6d3c5fe0383358c068f4cd939b23e888567f1f154e9e56da2  release/kernels/mwmiss.by_instr.json.gz
bb9d49fadf2c3b1ce81443b94d3e2d881d44e3ac4a8b8af32df4643cff161704  release/kernels/mwmiss.by_unit.json.gz
65867eb2557a384f3c51a883e852b728fbc03cffe0a29c9ac4b5502aa5d1de5d  release/kernels/mwmiss.ccvtrace
c62f5039a65e7587ef8c3a44bc659ccd318d97e6472e460c2c25a76e798006c1  release/kernels/mwmiss.log
8abe8e8997456a2a6711ee72da54d854b24e20abbdab28e4b7271c0d28418de8  release/kernels/mwmiss.oracle.jsonl
44914d25e3d317f788907d07f3bfeb5f4a3d0c3d768da069f551e70047e738d0  release/kernels/mwmiss.sv-hosted.log
ea82a4a40866dc4cd9527dfe197ce2f82ca061f9b108885c3913b60b7b6718fa  release/kernels/narrowadd.by_instr.json.gz
86b287c3bf634e351c2fcb3b4a743fd3e97ca456c822c17422a1ca0092a870f6  release/kernels/narrowadd.by_unit.json.gz
70f3064aa65b7765b7a6b444510e3f09a7cd4c4605374df03aa452b3837b7a5f  release/kernels/narrowadd.ccvtrace
7996f0a3c636f81c340eb845035b44eecf28ff087ae83510fa2c2b3cfa8743d2  release/kernels/narrowadd.log
40a2cf629853dd404bb06b4a07e35abde3d12efc13f26ffe28f923daf2994574  release/kernels/narrowadd.oracle.jsonl
b6f7e42ee84bb523b0602816f0dc9df2d428aff6c7138d0ef8c72a5d8ea128a3  release/kernels/narrowadd.sv-hosted.log
26dcebc0d7584c5ddca315c9926d54e9920f879dc176977f67d3da20e007b7f8  release/kernels/pgcross.by_instr.json.gz
ace1492481bd5448af469f19f863ee7d61cb0d5200d16635fd1864eb2c1c88bc  release/kernels/pgcross.by_unit.json.gz
55954f76cdb425f55f73efefc451c9e900e91431f122622f0c5c8b26648d7622  release/kernels/pgcross.ccvtrace
455fe9c66bbc12ad338315206c8a3cd2de560cf97049d79d0a614a1fdf4be3a3  release/kernels/pgcross.log
58aba9ba5ec6a72271191c0249014802cdc7e4470d27491f499a077f17ecc039  release/kernels/pgcross.oracle.jsonl
23c07424e8e0e52b08f5cafb6e2cb7b2a029eb78f558607e2b461f64ff1d487a  release/kernels/pgcross.sv-hosted.log
cca4ab9e5079170154937279b43479d9a59f7b321d4476c8921faa15ebd0a28f  release/kernels/pguard.by_instr.json.gz
3c186f0b68684d77c0f88c41cfea0bda68ec2423acf3ec78866f2e99cc489079  release/kernels/pguard.by_unit.json.gz
d3a0f73a186c037df930784ca453b1f6217e7443e14b5e2c4715bad84be9ef5d  release/kernels/pguard.ccvtrace
2e514be55c95ff3d12900a08b3aebbaee27987059b21659637bc19cf708eb851  release/kernels/pguard.log
690e56f1cb8d97cbf67124b7dff3ad0a90cb8981814cd1709cf0cd0e035b3bd9  release/kernels/pguard.oracle.jsonl
192393f70ad9a9962d134c8bfec687ff3f7e157d497c05d4819b013b0d384609  release/kernels/pguard.sv-hosted.log
ee66137726253e971e7f94498513dce28d9d8f54449975c8008ada796f73984a  release/kernels/plog.by_instr.json.gz
5e3cfbc09bbce770545120d291a3f55569466d70f7351a5679eaa7dde399c41d  release/kernels/plog.by_unit.json.gz
7823562f75147705b01f772471b6175774023d19935926703e158062b24cf94d  release/kernels/plog.ccvtrace
5dd800c35e450251b77b9013e871ed605a01b3b79d999d146ceaa0132460cb94  release/kernels/plog.log
0c99915e2da60f4670da00504a6371d7d17701d4431e733a3ff8fa98a2030d6a  release/kernels/plog.oracle.jsonl
e916662258dfbf44c917161b8349fbdc52c89af3ad53dfb12378cd871c4b2ed9  release/kernels/plog.sv-hosted.log
307cd222306187d1ef928882036ba67363b138092bdcf9efe9dc202533d1ea81  release/kernels/pmovdiv.by_instr.json.gz
bf7869e463ec470a44a15a23519228c91ede59b43290f5289cd3e11a03eba252  release/kernels/pmovdiv.by_unit.json.gz
da1865544271c3c70d3eab1061f5060d833a856975f75b28d0921880ec954a97  release/kernels/pmovdiv.ccvtrace
1fb7bbeb928dfa33ad6976c7ff0885380d55798d1f12a3986ee5bcb1a2a90d25  release/kernels/pmovdiv.log
7bc646cff6166a51bdce03d7c1b7209e871f0a91d743083a9b910a80bcd0b33f  release/kernels/pmovdiv.oracle.jsonl
be00d658453591c4a74a747e26571077fa6d23f0d7e26427405894763191d224  release/kernels/pmovdiv.sv-hosted.log
11a1819904a37790f675bad9d10292d109110b236ff66bc0b2c23e2de5fc1327  release/kernels/predlane.by_instr.json.gz
9fdd594900ef6b3d7489e4a365b1ce9509f9d1a4a16937673ddae1ed3f93df38  release/kernels/predlane.by_unit.json.gz
50d80cc740eb64f50d8d451ba21e1c58972991ba64ccd7114c95e774f4a430f9  release/kernels/predlane.ccvtrace
4f5c315278af5d7b7cd1745f5fa1c9586b79966aac23429b40df2a6c11bb04e5  release/kernels/predlane.log
c45f4177b9e84fc8a6e36b13534a0c7636eb30a3f8531847100ce5e23bf404b1  release/kernels/predlane.oracle.jsonl
8961b372d5e9d41a6f66cccaf765319cfa785548e656561f24ea751b1a090f28  release/kernels/predlane.sv-hosted.log
fe7d3073eea02645d52a6dc0112898c412f292338e7c193480f3b85c70ce622a  release/kernels/predmerge.by_instr.json.gz
a7beadb01f8f502146e6b9f8496c89d6b52c398a786235ebd9e33a5ff8aed201  release/kernels/predmerge.by_unit.json.gz
d4fbcf1a0ea13a89d7fdccfc214c4f918257cba14aa024d4ca6250f04d3a7fc8  release/kernels/predmerge.ccvtrace
7faf372c46056a939f4fb2c6eae629cae2f49cc35e1788960b99e85ebeae48d3  release/kernels/predmerge.log
6c737c49434bcd08e3e0814c8b1dbf15c586ae74f7929ba3148ddcee2c62c845  release/kernels/predmerge.oracle.jsonl
039912660566ab5df7dec5963352df5b8f9b8afce8f9d4c40d9c56168abf8b57  release/kernels/predmerge.sv-hosted.log
6ffb89821fbe3ebce9913e952f4c293f4f52c3abb0bc42e2c6152bf174770f52  release/kernels/predspill.by_instr.json.gz
531b25a15b18fbdaf2b466e0fc3464d245ce5fb0fcc2cbaf1ad65d13f056861b  release/kernels/predspill.by_unit.json.gz
68b1af2edfcc1c09bfe4cde2e148b0eaec9035dcca2ce8d1acd4ee551303d76a  release/kernels/predspill.ccvtrace
ce9e896c491b96b3f48d4dd3ced4510e123f4ea336826c1c8cf36006816667fc  release/kernels/predspill.log
b7c84c6478117ffa0f06da0e6ad1e4628e2683426a7911080810e78e06a5242e  release/kernels/predspill.oracle.jsonl
a2cd6e40782211ff45b0970d4c9c294a91754e6c40d433ad3a677eee5e6c830f  release/kernels/predspill.sv-hosted.log
90828039c137676f9cc9977c14e2ce611cc8e3b58bfab63a05caf6965c5c2c53  release/kernels/predswap.by_instr.json.gz
325c99c20ce3fa7c5366e64524ef7de2e5aa23885cb6293aae36da6e75f8ce0a  release/kernels/predswap.by_unit.json.gz
cc0bb7da1c9dd84f7a62c74627d792b5662c595294304c08509661b0a072d0f5  release/kernels/predswap.ccvtrace
367395ec06f0de718c1c19353cda3dc36a9252302f0fb689b37cb916384c05db  release/kernels/predswap.log
a6d4f7ed517553816d889c7c9eeb6bcfd1f6c973fbf682ecb69f3c2de619f7bb  release/kernels/predswap.oracle.jsonl
1e29fcf3d380900a53b93ea7851d205ef09d55e6ef99576158d2edccd1bd29cf  release/kernels/predswap.sv-hosted.log
d706282564a8043ca23b2a494c7629240431791c595f6464bec2921c8d006f85  release/kernels/privwin.by_instr.json.gz
2e6c203e6c680c08707fd2b9a0a0c61b9c1ce5a1ebff608826aedf53d865153d  release/kernels/privwin.by_unit.json.gz
b05842fd55756949b74bcf3dd99cc17c0dab77b15911287ab50f3420319bb912  release/kernels/privwin.ccvtrace
4d2979ac4ab0ee9cd7c8cda5ad46d9dc2ca40440c2859d8c1730dab1a5ef056b  release/kernels/privwin.log
861f686fc4480363472908d679d8815e8c957d768e7ab32c826930527b0fb7a8  release/kernels/privwin.oracle.jsonl
8926efebcb88d7a3cebfc5b4fe7afaea6b70e23fb202f32324e4737e983cb565  release/kernels/privwin.sv-hosted.log
10696616c1ee48cf7d8d91ae9d367a5e81fce9f4b43ec5a8f50267df33807c79  release/kernels/provswap.by_instr.json.gz
475d6f9db4551d390f72da205ce8ba51d06acf2826d705b749a35dcf9e069c2c  release/kernels/provswap.by_unit.json.gz
71b721e2bd1fc8dd52b36767c301a10981b26e89728d6827c65aaf14dda88f38  release/kernels/provswap.ccvtrace
c51a2d0144d451f0d0bd5c7f01097960b965f1a2a021cf9523c04f8eeb55e5f5  release/kernels/provswap.log
c9c32a793d54cc7401477f582487f7e8b345b2669a75337b8d6327120d98e5dc  release/kernels/provswap.oracle.jsonl
e148479b2412dc775742ca14fc2c08959ec76af37a82c046f3128457cfc78869  release/kernels/provswap.sv-hosted.log
8a01852086157439bf2147903203d942e4b840838d8e87a5ae4f6d3a3adc3f02  release/kernels/retmiss.by_instr.json.gz
37f3ab2753f06c03c28f8874e89e50b83e954288e8b9c5278f30035b13d80454  release/kernels/retmiss.by_unit.json.gz
5fd48fe228e08b7647063cef9db1a2d2e027a5a03176463da79fbd5263ed78ab  release/kernels/retmiss.ccvtrace
6741cdcef6adde227ee6f6ae609171e0f30860fc63bd14047ede6239fc8b34e6  release/kernels/retmiss.log
e5ef8538e838c6cff7febfc679dd091cf5e002f82d34f1009b1948ce22bc3649  release/kernels/retmiss.oracle.jsonl
d941171ab8e6f0a418884226ac090c9c5943048cb480947c4c9eb89e0643c918  release/kernels/retmiss.sv-hosted.log
b8af37455b33a1b36ab55a477d4761f76bdf9dd3edd8eab5fb7f2c3731ac8ec5  release/kernels/roconst.by_instr.json
1bd6e3d57918f6dc12f88a90fbad3431d9d6ab8123f8959ed02ca7c9430da7dc  release/kernels/roconst.by_unit.json
55981e07a1a8d3ed8b7a9f6797e5f718e3161cc5f6e1218171db77f9b6115f18  release/kernels/roconst.ccvtrace
ff94a2918fb8a411a7bca72900e139969eb9788e56c8839af7eae053dd9185e7  release/kernels/roconst.log
8087c0671de620162881aecd38cd6114b78e7be6bd71201e3ec02c9a2e2e750e  release/kernels/roconst.oracle.jsonl
2395d69a039451ac459131db4179a867488859362a4ccb80bbfb16513b422566  release/kernels/roconst.sv-hosted.log
10c797fb8d044649f6d3dee9c07281c225794258b33e21124d781108ba92c747  release/kernels/rogated.by_instr.json
a35cca4e8648dec20d18f2b40da66da07704d855c6e18a8c8782aae0095dedfc  release/kernels/rogated.by_unit.json.gz
efce29ea7c5e82d9ca9f5522549f4958218e9ae67a9114f6c26c60f34501ba52  release/kernels/rogated.ccvtrace
123202deab65d07ae58b4f5e0d3e057b8240c73d133d058df16afbdf7b8d1355  release/kernels/rogated.log
7cd02bd4cceec5a044d6b4d6a80df1e68ed0ae71b0b2a953143636d5b809ea6c  release/kernels/rogated.oracle.jsonl
98a2720774d3aa431afa722e8e0b09dd7a7e19e93b742c77ef5e1cfd94e8e03f  release/kernels/rogated.sv-hosted.log
626ca71c75a93531e6a32853d1c161d2260b7d8247a2fce5ca8de907f6a76b5b  release/kernels/rokill.by_instr.json.gz
aa4c3f88df361340b6527e78851e168b6bb483003566941a23dff50e9a044066  release/kernels/rokill.by_unit.json.gz
8a540e1a67dce0d3845964ab547fce4b1c674a042f6be8c8d8c8b7dd46f4663e  release/kernels/rokill.ccvtrace
a79d727e80bb32b05293ca69e95d1b3946c235aaa107095c53edf9419f0202e5  release/kernels/rokill.log
94efcef96af469a512d346ce61623980fe86383188eaebd55120f716db596f14  release/kernels/rokill.oracle.jsonl
7231f8eabef6331d4800c7d0e22ee4a79e7759b91757661ae298a203a292d255  release/kernels/rokill.sv-hosted.log
c3b80834f47e0903700d814d82ffd703ea309042c676d56c99e0f34dc706d9c3  release/kernels/rokilllane.by_instr.json.gz
4be3d215745ac0851b07dcd5364dd036e5a95df8657a68a3b4f602491ca1e8cf  release/kernels/rokilllane.by_unit.json.gz
c54a973f624a7ad5b95499138a725ad2287a564534121f4f568394896b3522b8  release/kernels/rokilllane.ccvtrace
f595321fb7ad42f9333ba3e2a7cb9bef3dabcfa3db38e03b6675eec8f9bb84dd  release/kernels/rokilllane.log
f5ca6e666eff2f44894df74a291b43b3c0e7be0a63a47d795fdefd7b22016f45  release/kernels/rokilllane.oracle.jsonl
e42e1f5d5d08f96a7c4d0ed87da0b365cc21f128761ed766366bd414f67c063c  release/kernels/rokilllane.sv-hosted.log
6018676757a05a45231fba12ff6df60d07f415338c1d836cc09d99465b73577e  release/kernels/rolaunch.by_instr.json
8512780fe1bbc0571a43ff91654c0ffdb7545b9c1ac040c907e50a29bfbd10d3  release/kernels/rolaunch.by_unit.json
289a78e36e414127402cf1c2f9514ddf7965e2988e5c5c2c172bf77c872262d4  release/kernels/rolaunch.ccvtrace
371d15ae379840f4207401ff871dfc5ae5deffff3e4b1034c83ddbc66f6a3d0d  release/kernels/rolaunch.log
e7dad585c3e70615de04330fd03f4f282c29a005dc1732a35655fb261d51139e  release/kernels/rolaunch.oracle.jsonl
9e06609120a1338208115593a6a5e1d5ba453edda5dd2e66587355e5efe013c2  release/kernels/rolaunch.sv-hosted.log
b8af37455b33a1b36ab55a477d4761f76bdf9dd3edd8eab5fb7f2c3731ac8ec5  release/kernels/rolimit.by_instr.json
0e20aabf7e39b687a2ade0f80fd977c9d7bd313c2cebdac11d43f35296e7d911  release/kernels/rolimit.by_unit.json
6105e32f751a15c0875d0d2a30a1e054656c0475286b5e2739728e13fa4d3e83  release/kernels/rolimit.ccvtrace
7832f04ccde4ecad3e94da09fd6ef61a15bcf77b29a10fd6cda4cb4c1313b48c  release/kernels/rolimit.log
1c5bc0cb8e8b2e69505fb5a551a16d5d10c56f232b88da7a27e336ad7d962de2  release/kernels/rolimit.oracle.jsonl
c7694a1225d6deb27de89e9cbedeff1c4dabd73372099388c18e22b824831939  release/kernels/rolimit.sv-hosted.log
350d8649093b29a01365496185352b1fde95b3f01250fc79dedde3cf0488c078  release/kernels/roload.by_instr.json.gz
446831df12eb0710bf7e9aa54ba007c587d9e09fe8556aa57375971afb5f02f6  release/kernels/roload.by_unit.json.gz
1578a583d5c4f4db19dc0bd74a872681a3a72c6e6f5b8cde88c5ca1dc140c41e  release/kernels/roload.ccvtrace
fcc3b2d334bdcfcae1f619e84883ff1eac360f81c71aa48b3075b0f907b9b302  release/kernels/roload.log
f7c1309cc9764769fb5803f6fd0f2f5e1eb418f2d23fbe5e17cf5f9106869fdf  release/kernels/roload.oracle.jsonl
f3ce0d24037168eea3d7e87147b3f3b5430a1fe7d9c300d4502e16a38fb26c35  release/kernels/roload.sv-hosted.log
da0bf92f93b87454d471eb748675c06d702562e7809400c452d80b7ce31c1699  release/kernels/rope.by_instr.json.gz
61145782733bba0b8c8e5623c95f170e15e9de0e4513b9daec22fd63faa1744b  release/kernels/rope.by_unit.json.gz
c28a1bf8541fe51be00d4bf9cc41210c6cba3db2f220dfca58ceb07bf23f1fb7  release/kernels/rope.ccvtrace
6098bf8f8f071afefe0454906467e7a51b3c29236881e4ac7f18575e79c401b2  release/kernels/rope.log
d55f9efae392dc8877c102c01c0810e7654b666b6ede386328108164c6cf88f3  release/kernels/rope.oracle.jsonl
306e3f4351a7c7ac7ebfce0d91a957b3d60b0abe4af039261f2df5288369e6d4  release/kernels/rope.sv-hosted.log
eae361c08fcb8660728f65d3b48d3ed37d8c27dee87a237397c6c20fdb028f30  release/kernels/ropediv.by_instr.json.gz
caef08731c1002e62a919ded4723676c468b64d781f25e636308eee8b50bb028  release/kernels/ropediv.by_unit.json.gz
f3b563b58e4997345f986a68124b88067afacf867bd6c7f3c4f48cf639bdef31  release/kernels/ropediv.ccvtrace
d2435c5275e9e649d73142c96b6858d14a471b268a944dad943def4be7e1a6e1  release/kernels/ropediv.log
10c0ec6ec18b7b44638c790033109198c079d07c1537bf193353ccedd00a920f  release/kernels/ropediv.oracle.jsonl
581ab68ada81648a82572747952c178b36af390a4502d78e5875cd12c73db6ae  release/kernels/ropediv.sv-hosted.log
62e59d2077ba55c1ffd5da1a93f87da1d452ac626aa00fc9333d88141264a238  release/kernels/sel.by_instr.json.gz
6881776361ae18d11af5b0457abbd5b1c7300716d5971463856d483a68e315d4  release/kernels/sel.by_unit.json.gz
0e8438b35022c4f1ce3255dded34165aef8dfb098254ae97b0f80b67fffe2c18  release/kernels/sel.ccvtrace
b8f0aea93813d06d71ed246ad987d811e6fdcd29ac2f40c242efe42c9dcf0f24  release/kernels/sel.log
87f6a81e8afa004c8039bf2f61c90176fcf29ab29bb17ac44aa016a5cc8438fe  release/kernels/sel.oracle.jsonl
78ab9b8017f28651856f2090ce512d0fd731e1207e965aee393da0dae07d2801  release/kernels/sel.sv-hosted.log
100f023137a7e77f4584fc7bc6f578c5a166edc410216c2c9b786cbdb14e2819  release/kernels/sized.by_instr.json.gz
d3989cff5343329b553176ae0f8353b3148f224c82ea9a7fb3815cc0b7b1b770  release/kernels/sized.by_unit.json.gz
fc2280a2a3c07287069cdcf194669d210c189c42292f2c8f18c06e80ccb1dbbe  release/kernels/sized.ccvtrace
bc2fbc1e9089cb3762a267e1c109b3f0b5eb570ae43e1298d73406da9c1e9db2  release/kernels/sized.log
36d903ba1618bd1faa437c9812a6ee6c0c966a63196c796267d74bf2695ebc3d  release/kernels/sized.oracle.jsonl
7fd5e1ec509700d075bb18dbfab1c1ebe1da1c9e07346d566aa59a57912cc8c8  release/kernels/sized.sv-hosted.log
0e734d5aa2ee8e90619aa81ee9a23c9f2db43a0a234e906828bbdeab6539d5ef  release/kernels/slotform.by_instr.json.gz
c91b2d90d20adb4451c521c03af48a4d57e7fc34f343c217d8fa27a628cbf2e2  release/kernels/slotform.by_unit.json.gz
ff8972a50d2be95058930e607a107394abbccd183eaad7a443dad100e56f5019  release/kernels/slotform.ccvtrace
a6b73850ce6cfb796b5cc1f1d7753f4dedb584e9c17f3b7aff79eb4db6a1a52a  release/kernels/slotform.log
8b61db7419b18cea8a646fb628218447e72e84a18a9891ffb73b441736138ab9  release/kernels/slotform.oracle.jsonl
f599c98301728e8a47cf0d599f3ca8830ee161fb385b952a8d408a7ccb973ba0  release/kernels/slotform.sv-hosted.log
217cf974018f38af45bbc35c3911b2da044db305b5b60de2698666af62f3c82b  release/kernels/spinwait.by_instr.json.gz
c04dc8eadfb5f78b0731979541d09119481afdbc5a6eedb94514ec05f561f83c  release/kernels/spinwait.by_unit.json.gz
96ed0aa7d277284575bad8804bec69409b22c9b86085c7cdf2a3776908b9761f  release/kernels/spinwait.ccvtrace
714ad6121a5cc9b9a35d0abaa7ff923ce127a2ea957acc01451dad385cf1545a  release/kernels/spinwait.log
868920637236c878b33779bd450439466fc3626996a3164573dc11d437d5c709  release/kernels/spinwait.oracle.jsonl
d44716dffa0c0aa766622147ce8adaf239ca892bd3fa4d4e1f678ba8887b4510  release/kernels/spinwait.sv-hosted.log
60301f278fe343a1a4d35cdcfa07d1d47db7c20a808733ea5bc7f670c7631c2d  release/kernels/spmbank.by_instr.json.gz
58474264220e560a6d5d34545841f82361e760ba952fb3e965a2239c71098cdf  release/kernels/spmbank.by_unit.json.gz
0b63ddd199108d5d57dacf8da3b47f37f0c4b36c8ae2b2605a61415aba0d0ef1  release/kernels/spmbank.ccvtrace
6097b6dacb597c0bd06c7e502815be57848570f1c9de4541c4f4618e1025ba1f  release/kernels/spmbank.log
3af490cc37d7a92dbe719b57de216b648536eb301ff9d13de9a39f50d150d725  release/kernels/spmbank.oracle.jsonl
32edafb4e0c8d5571df2aa65798ef3a6f80e3e8142cdfcd6db463b0d283d2999  release/kernels/spmbank.sv-hosted.log
1ae651e6c7d595ed0ace5ca944b4c76b6eff41889303222784175980779c6f89  release/kernels/srd.by_instr.json.gz
de655af211e2948cbeccdcccad08b8e548e6bc687ce93773ed3cf47eb59a7e5d  release/kernels/srd.by_unit.json.gz
0c47cb484cf0fa4aeccd7dbb998c726c231c62826d2093825653eafe0ebf1c2e  release/kernels/srd.ccvtrace
3457e8d78f7b3da9840d7885eb9b6c0a0244ea0ddda73e0067bffe9e9c98d744  release/kernels/srd.log
b08eb5e3673cac7eebb8b72af5ed3783c8e70a9e96592e76bf3722551bc79473  release/kernels/srd.oracle.jsonl
0d1513c61e04c3066b42260db72d5369af98f20ffa43ce69c2df858248334f69  release/kernels/srd.sv-hosted.log
9874359cb258f9c69c6607d88c024d1f9267db87b0c64a36752f252af69d2bbc  release/kernels/stall.by_instr.json.gz
aa6e96e1c720d6264c82f1e164cdf02090d9795634d2f207141a79c7790d21be  release/kernels/stall.by_unit.json.gz
fdbaf4c7902b755d682cce57fc79287d1b42ac04bc16f363e0ae6381951d354a  release/kernels/stall.ccvtrace
0e83017402b6ebfc90193c3fe1ec1c57697746a8c92242d3bfbbb54e526ce698  release/kernels/stall.log
500db2c482b07a0706583422cd68878301d0146c1f872ccc1f11bfdcf5c993ef  release/kernels/stall.oracle.jsonl
87f748be36c505d9f99df13596e8d86fe34b71d2b4d287821be64744d9ca92ca  release/kernels/stall.sv-hosted.log
9a7e096f0b6ede58643dad09cabdaaddc5ff2a5343976ca169894e6ad3744963  release/kernels/swap.by_instr.json.gz
cb90d382155dea757bbf3f5db0fda55ae667852dc411031aa4282a2781ea2cda  release/kernels/swap.by_unit.json.gz
e57df079f08803da10c14868ef10984f224605451405d05a7f253f3e19b0b77a  release/kernels/swap.ccvtrace
51b7d55aa98bb09dd8f550da4e6be54998204c11fa0dc48faa94ab523c754bd4  release/kernels/swap.log
3658a26316c1ff7bc1744304a42f736e930fcde2865c8913e6cc67a22ce96667  release/kernels/swap.oracle.jsonl
3a63990bcccb63f9919896b47cac8c4e4c48173c6630db50e9afee0a9a0f3455  release/kernels/swap.sv-hosted.log
50bd92b487a2416370152f26097954d8046ea13f451b223a888164ad16f213ad  release/kernels/transp4.by_instr.json.gz
4af1a9f94b32a516722ec973b59154fa19a673a381810347b1f8082727a71828  release/kernels/transp4.by_unit.json.gz
8f2febb448d3affcf9fd137c0f5e513ad3afa69793c63d3f8a51fa6550ab966d  release/kernels/transp4.ccvtrace
a344611b3b1d958cf39c497cdc7f7dbf191db1be0a201f3dad4ae1e756f8a4d6  release/kernels/transp4.log
06396ace3ac19677fd39c700e408606e5bdbacb24997d663bbe8872e63dd74fc  release/kernels/transp4.oracle.jsonl
cd54329e20bef2704ecfe79996fe73183c56c777db67802941e0c651e41b396b  release/kernels/transp4.sv-hosted.log
e250e7d1d518d10cb402cc10fceb3e0b3f0b09d0076d891b79842c4fe3952a00  release/kernels/unal.by_instr.json.gz
5a687283c5e6fb9290b917286dd42af89f4ba564622283c5845aa91fa4e253d3  release/kernels/unal.by_unit.json.gz
0cd8c220c97c584d454372ee65753f8c7eeab527faa08ee5dea40239360b17f8  release/kernels/unal.ccvtrace
2e3869bbbfb2eaaa261b4d85139f6600a6d0cf6045cc4da02c08f924f14b421a  release/kernels/unal.log
c3d484bb160657a563df983d9a2532eac27f556636617960aa1e72183ac2b299  release/kernels/unal.oracle.jsonl
421566aabf9225acc59bad9df53efa8a4e7b81e5b8c53944c64d021fc6c24f18  release/kernels/unal.sv-hosted.log
b11f9594f6120c4915a548e8d7f68943d14f54fcc5342b50df9c4d0cb06c8cfb  release/kernels/vadd.by_instr.json.gz
449f4c2bd624cd7d989109950421130b19411eb103e9e4dbe0ead0e159caff21  release/kernels/vadd.by_unit.json.gz
e325dbc3fdad4e6bbbc3475cfda348ad306843a8c5a0b3ab2737111454ceb121  release/kernels/vadd.ccvtrace
c7d3eabb67601c4c8601f04d4973f022abb56802b1e9542d7547b74980329a69  release/kernels/vadd.log
0276b6d0611a4bbcdc004ab3987214aea138245bc7217504147331689a9c0880  release/kernels/vadd.oracle.jsonl
9a1489c4d3b48df37a051773116cf9320f718e02fdaf3fa21351ce8df08ec5d2  release/kernels/vadd.sv-hosted.log
88bf17175c14d1c208793a3dddf594a2c98250aeec6a2cccf5775f23e0980838  release/kernels/vadd4.by_instr.json.gz
389127e7db3fc6891f6929a4e14889cdcdc782aed1fb1ab04b39de987ee26d7f  release/kernels/vadd4.by_unit.json.gz
5edf3b0f5cdc6d57709ad1ea5489bde063b3190c90a27c1f1a43d010b19e7983  release/kernels/vadd4.ccvtrace
75772c0dbc8470d0fbcd62f27f3f9acf9dead3028d2cdb4d80bddcc6fa784795  release/kernels/vadd4.log
225aa18fc9f38aa9ad615aa11de254337d59fa705877553d873062c68366e0db  release/kernels/vadd4.oracle.jsonl
ee326f5f56d96f1292c74e583040fb8ee3fdbff7d32d9529e835eba873e0d79d  release/kernels/vadd4.sv-hosted.log
434ac10c6e5f7addc02f8d89607ab99b9c77c4ec8192862a6f62f9eec35aa24e  release/kernels/vaddslow.by_instr.json.gz
269054765f9fbbab881a35ee63890dc9b6a517fd7c1e09ee82bce7ad8b47a5f8  release/kernels/vaddslow.by_unit.json.gz
f4edab31577c7354ea3937a41cb1bd675d1b2f6cf11e99ef319d3ce31b4cb878  release/kernels/vaddslow.ccvtrace
3611036e09ac427e98ab9914f8a5a2844abd86e5a4e128e6138044a2eb15db56  release/kernels/vaddslow.log
e9e6218e8b8450e9f9ff6b39d659c994a1e51c527a0c5bd10d18b5658ae0e344  release/kernels/vaddslow.oracle.jsonl
ad5693ac6098ec0dabac0f2f58505c7a648aef819ebee61591b0fe687bcc554e  release/kernels/vaddslow.sv-hosted.log
3b902d07b0bb91965da594feb3fa2e03dd8ed922cbd2ef1d28cf7010f6857daf  release/kernels/waypred.by_instr.json.gz
0067f0bad48195cbe180c57fb6b483fb14cd2fd9dc2208536b81d565f7ad2559  release/kernels/waypred.by_unit.json.gz
5be72e1d051494726fba08e1bc919a11cd5a7afe6cfd7065564f3a1c0c0c3f24  release/kernels/waypred.ccvtrace
95697c664cbe3a63d683b0e9851efd403eaecb424a41620bb106842bc7ea833b  release/kernels/waypred.log
54fb803ce85c4458b8687bb0f61adc32a9d798448b914b06261dc49c2bb841c8  release/kernels/waypred.oracle.jsonl
d9a91bb0d33f59e8d2203070d2a2b9d34324e6844fd99286edf24faba0079fb1  release/kernels/waypred.sv-hosted.log
e89a757c6a29742391eabfc53cc447e75513fff7ed72674f2fde677f00954bb3  release/verify.log
f78197fa73514d4391564b6dbfda61c3c03a38e2134c9ddc2d24180f29c72e6c  release/wiring.txt
```
