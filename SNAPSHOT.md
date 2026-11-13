# Snapshot snapshot-2026-11-13-a46afef

**A generated, read-only snapshot. Do not edit or merge it.** The source
is `ti-sram` at `a46afef70bd47919ee7a99b51dea0006dfac5e95`, and this branch is rebuilt from source by
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
| Source | `ti-sram` @ `a46afef70bd47919ee7a99b51dea0006dfac5e95` |
| Built | 2026-11-13 (UTC) |
| Gate | `tools/verify.sh`: PASS |
| Compiler snapshot | custom-cuda-complier `release` @ `e533ecdfabd1aa267e4cffd49a4d7e1e8c13b263` (source `45ce995c923e7267feb71d87f8f9c5edfefcf0df`) |
| Verilator | Verilator 5.052 2026-09-05 rev v5.052 |
| Icarus | Icarus Verilog version 12.0 (stable) () |
| Yosys | Yosys 0.33 (git sha1 2584903a060) |

## Kernels

| Kernel | Result |
|---|---|
| `addrhigh` | `name=addrhigh finished=1 cycles=83 from_fetch=52 retired=5 issue_groups=6 order=ok gpr_mismatch=0 pred_mismatch=0 mem_mismatch=0 check_failures=0 class_violations=0 overflows=0 credit_leaks=0 cor_late=0 channels_used=26/55 violations=0` |
| `addrlimit` | `name=addrlimit finished=1 cycles=1072 from_fetch=1041 retired=5 issue_groups=5 order=ok gpr_mismatch=0 pred_mismatch=0 mem_mismatch=0 check_failures=0 class_violations=0 overflows=0 credit_leaks=0 cor_late=0 channels_used=27/55 violations=0` |
| `addrneg` | `name=addrneg finished=1 cycles=83 from_fetch=52 retired=1 issue_groups=2 order=ok gpr_mismatch=0 pred_mismatch=0 mem_mismatch=0 check_failures=0 class_violations=0 overflows=0 credit_leaks=0 cor_late=0 channels_used=23/55 violations=0` |
| `atom` | `name=atom finished=1 cycles=7843 from_fetch=7812 retired=29 issue_groups=29 order=ok gpr_mismatch=0 pred_mismatch=0 mem_mismatch=0 check_failures=0 class_violations=0 overflows=0 credit_leaks=0 cor_late=0 channels_used=32/55 violations=0` |
| `atomf` | `name=atomf finished=1 cycles=4423 from_fetch=4392 retired=12 issue_groups=12 order=ok gpr_mismatch=0 pred_mismatch=0 mem_mismatch=0 check_failures=0 class_violations=0 overflows=0 credit_leaks=0 cor_late=0 channels_used=34/55 violations=0` |
| `borrow` | `name=borrow finished=1 cycles=99 from_fetch=68 retired=7 issue_groups=7 order=ok gpr_mismatch=0 pred_mismatch=0 mem_mismatch=0 check_failures=0 class_violations=0 overflows=0 credit_leaks=0 cor_late=0 channels_used=21/55 violations=0` |
| `brs` | `name=brs finished=1 cycles=99 from_fetch=68 retired=12 issue_groups=12 order=ok gpr_mismatch=0 pred_mismatch=0 mem_mismatch=0 check_failures=0 class_violations=0 overflows=0 credit_leaks=0 cor_late=0 channels_used=23/55 violations=0` |
| `byp` | `name=byp finished=1 cycles=118 from_fetch=87 retired=14 issue_groups=14 order=ok gpr_mismatch=0 pred_mismatch=0 mem_mismatch=0 check_failures=0 class_violations=0 overflows=0 credit_leaks=0 cor_late=0 channels_used=31/55 violations=0` |
| `callret` | `name=callret finished=1 cycles=265 from_fetch=234 retired=40 issue_groups=40 order=ok gpr_mismatch=0 pred_mismatch=0 mem_mismatch=0 check_failures=0 class_violations=0 overflows=0 credit_leaks=0 cor_late=0 channels_used=30/55 violations=0` |
| `cas` | `name=cas finished=1 cycles=6524 from_fetch=6493 retired=56 issue_groups=56 order=ok gpr_mismatch=0 pred_mismatch=0 mem_mismatch=0 check_failures=0 class_violations=0 overflows=0 credit_leaks=0 cor_late=0 channels_used=32/55 violations=0` |
| `chains` | `name=chains finished=1 cycles=96 from_fetch=65 retired=29 issue_groups=29 order=ok gpr_mismatch=0 pred_mismatch=0 mem_mismatch=0 check_failures=0 class_violations=0 overflows=0 credit_leaks=0 cor_late=0 channels_used=21/55 violations=0` |
| `coll` | `name=coll finished=1 cycles=78 from_fetch=47 retired=24 issue_groups=24 order=ok gpr_mismatch=0 pred_mismatch=0 mem_mismatch=0 check_failures=0 class_violations=0 overflows=0 credit_leaks=0 cor_late=0 channels_used=21/55 violations=0` |
| `div` | `name=div finished=1 cycles=978 from_fetch=947 retired=144 issue_groups=144 order=ok gpr_mismatch=0 pred_mismatch=0 mem_mismatch=0 check_failures=0 class_violations=0 overflows=0 credit_leaks=0 cor_late=0 channels_used=23/55 violations=0` |
| `divchw` | `name=divchw finished=1 cycles=111 from_fetch=80 retired=5 issue_groups=6 order=ok gpr_mismatch=0 pred_mismatch=0 mem_mismatch=0 check_failures=0 class_violations=0 overflows=0 credit_leaks=0 cor_late=0 channels_used=22/55 violations=0` |
| `divtail` | `name=divtail finished=1 cycles=642 from_fetch=611 retired=96 issue_groups=96 order=ok gpr_mismatch=0 pred_mismatch=0 mem_mismatch=0 check_failures=0 class_violations=0 overflows=0 credit_leaks=0 cor_late=0 channels_used=23/55 violations=0` |
| `divtail2` | `name=divtail2 finished=1 cycles=1517 from_fetch=1486 retired=366 issue_groups=366 order=ok gpr_mismatch=0 pred_mismatch=0 mem_mismatch=0 check_failures=0 class_violations=0 overflows=0 credit_leaks=0 cor_late=0 channels_used=23/55 violations=0` |
| `fence` | `name=fence finished=1 cycles=83 from_fetch=52 retired=7 issue_groups=7 order=ok gpr_mismatch=0 pred_mismatch=0 mem_mismatch=0 check_failures=0 class_violations=0 overflows=0 credit_leaks=0 cor_late=0 channels_used=30/55 violations=0` |
| `gather` | `name=gather finished=1 cycles=265 from_fetch=234 retired=16 issue_groups=16 order=ok gpr_mismatch=0 pred_mismatch=0 mem_mismatch=0 check_failures=0 class_violations=0 overflows=0 credit_leaks=0 cor_late=0 channels_used=31/55 violations=0` |
| `hit` | `name=hit finished=1 cycles=228 from_fetch=197 retired=17 issue_groups=17 order=ok gpr_mismatch=0 pred_mismatch=0 mem_mismatch=0 check_failures=0 class_violations=0 overflows=0 credit_leaks=0 cor_late=0 channels_used=31/55 violations=0` |
| `lanectx` | `name=lanectx finished=1 cycles=70 from_fetch=39 retired=10 issue_groups=10 order=ok gpr_mismatch=0 pred_mismatch=0 mem_mismatch=0 check_failures=0 class_violations=0 overflows=0 credit_leaks=0 cor_late=0 channels_used=29/55 violations=0` |
| `lanectx2` | `name=lanectx2 finished=1 cycles=70 from_fetch=39 retired=10 issue_groups=10 order=ok gpr_mismatch=0 pred_mismatch=0 mem_mismatch=0 check_failures=0 class_violations=0 overflows=0 credit_leaks=0 cor_late=0 channels_used=29/55 violations=0` |
| `late` | `name=late finished=1 cycles=172 from_fetch=141 retired=16 issue_groups=16 order=ok gpr_mismatch=0 pred_mismatch=0 mem_mismatch=0 check_failures=0 class_violations=0 overflows=0 credit_leaks=0 cor_late=0 channels_used=31/55 violations=0` |
| `ldpar` | `name=ldpar finished=1 cycles=154 from_fetch=123 retired=17 issue_groups=17 order=ok gpr_mismatch=0 pred_mismatch=0 mem_mismatch=0 check_failures=0 class_violations=0 overflows=0 credit_leaks=0 cor_late=0 channels_used=31/55 violations=0` |
| `lnorm1` | `name=lnorm1 finished=1 cycles=2535 from_fetch=2504 retired=526 issue_groups=526 order=ok gpr_mismatch=0 pred_mismatch=0 mem_mismatch=0 check_failures=0 class_violations=0 overflows=0 credit_leaks=0 cor_late=0 channels_used=37/55 violations=0` |
| `localsp` | `name=localsp finished=1 cycles=2175 from_fetch=2144 retired=40 issue_groups=40 order=ok gpr_mismatch=0 pred_mismatch=0 mem_mismatch=0 check_failures=0 class_violations=0 overflows=0 credit_leaks=0 cor_late=0 channels_used=31/55 violations=0` |
| `loop` | `name=loop finished=1 cycles=2842 from_fetch=2811 retired=407 issue_groups=407 order=ok gpr_mismatch=0 pred_mismatch=0 mem_mismatch=0 check_failures=0 class_violations=0 overflows=0 credit_leaks=0 cor_late=0 channels_used=23/55 violations=0` |
| `merge` | `name=merge finished=1 cycles=71 from_fetch=40 retired=9 issue_groups=9 order=ok gpr_mismatch=0 pred_mismatch=0 mem_mismatch=0 check_failures=0 class_violations=0 overflows=0 credit_leaks=0 cor_late=0 channels_used=21/55 violations=0` |
| `missrun` | `name=missrun finished=1 cycles=121 from_fetch=90 retired=28 issue_groups=28 order=ok gpr_mismatch=0 pred_mismatch=0 mem_mismatch=0 check_failures=0 class_violations=0 overflows=0 credit_leaks=0 cor_late=0 channels_used=31/55 violations=0` |
| `mload` | `name=mload finished=1 cycles=111 from_fetch=80 retired=11 issue_groups=11 order=ok gpr_mismatch=0 pred_mismatch=0 mem_mismatch=0 check_failures=0 class_violations=0 overflows=0 credit_leaks=0 cor_late=0 channels_used=31/55 violations=0` |
| `mlp` | `name=mlp finished=1 cycles=126 from_fetch=95 retired=21 issue_groups=21 order=ok gpr_mismatch=0 pred_mismatch=0 mem_mismatch=0 check_failures=0 class_violations=0 overflows=0 credit_leaks=0 cor_late=0 channels_used=31/55 violations=0` |
| `mwmiss` | `name=mwmiss finished=1 cycles=129 from_fetch=98 retired=88 issue_groups=88 order=ok gpr_mismatch=0 pred_mismatch=0 mem_mismatch=0 check_failures=0 class_violations=0 overflows=0 credit_leaks=0 cor_late=0 channels_used=31/55 violations=0` |
| `narrowadd` | `name=narrowadd finished=1 cycles=230 from_fetch=199 retired=21 issue_groups=21 order=ok gpr_mismatch=0 pred_mismatch=0 mem_mismatch=0 check_failures=0 class_violations=0 overflows=0 credit_leaks=0 cor_late=0 channels_used=32/55 violations=0` |
| `pguard` | `name=pguard finished=1 cycles=87 from_fetch=56 retired=12 issue_groups=12 order=ok gpr_mismatch=0 pred_mismatch=0 mem_mismatch=0 check_failures=0 class_violations=0 overflows=0 credit_leaks=0 cor_late=0 channels_used=29/55 violations=0` |
| `plog` | `name=plog finished=1 cycles=71 from_fetch=40 retired=11 issue_groups=11 order=ok gpr_mismatch=0 pred_mismatch=0 mem_mismatch=0 check_failures=0 class_violations=0 overflows=0 credit_leaks=0 cor_late=0 channels_used=21/55 violations=0` |
| `pmovdiv` | `name=pmovdiv finished=1 cycles=104 from_fetch=73 retired=12 issue_groups=12 order=ok gpr_mismatch=0 pred_mismatch=0 mem_mismatch=0 check_failures=0 class_violations=0 overflows=0 credit_leaks=0 cor_late=0 channels_used=22/55 violations=0` |
| `predlane` | `name=predlane finished=1 cycles=928 from_fetch=897 retired=10 issue_groups=10 order=ok gpr_mismatch=0 pred_mismatch=0 mem_mismatch=0 check_failures=0 class_violations=0 overflows=0 credit_leaks=0 cor_late=0 channels_used=31/55 violations=0` |
| `predmerge` | `name=predmerge finished=1 cycles=940 from_fetch=909 retired=9 issue_groups=9 order=ok gpr_mismatch=0 pred_mismatch=0 mem_mismatch=0 check_failures=0 class_violations=0 overflows=0 credit_leaks=0 cor_late=0 channels_used=33/55 violations=0` |
| `predspill` | `name=predspill finished=1 cycles=968 from_fetch=937 retired=12 issue_groups=12 order=ok gpr_mismatch=0 pred_mismatch=0 mem_mismatch=0 check_failures=0 class_violations=0 overflows=0 credit_leaks=0 cor_late=0 channels_used=31/55 violations=0` |
| `predswap` | `name=predswap finished=1 cycles=1186 from_fetch=1155 retired=46 issue_groups=46 order=ok gpr_mismatch=0 pred_mismatch=0 mem_mismatch=0 check_failures=0 class_violations=0 overflows=0 credit_leaks=0 cor_late=0 channels_used=33/55 violations=0` |
| `privwin` | `name=privwin finished=1 cycles=1161 from_fetch=1130 retired=52 issue_groups=52 order=ok gpr_mismatch=0 pred_mismatch=0 mem_mismatch=0 check_failures=0 class_violations=0 overflows=0 credit_leaks=0 cor_late=0 channels_used=34/55 violations=0` |
| `provswap` | `name=provswap finished=1 cycles=2290 from_fetch=2259 retired=978 issue_groups=978 order=ok gpr_mismatch=0 pred_mismatch=0 mem_mismatch=0 check_failures=0 class_violations=0 overflows=0 credit_leaks=0 cor_late=0 channels_used=33/55 violations=0` |
| `retmiss` | `name=retmiss finished=1 cycles=184 from_fetch=153 retired=19 issue_groups=19 order=ok gpr_mismatch=0 pred_mismatch=0 mem_mismatch=0 check_failures=0 class_violations=0 overflows=0 credit_leaks=0 cor_late=0 channels_used=33/55 violations=0` |
| `roconst` | `name=roconst finished=1 cycles=76 from_fetch=45 retired=4 issue_groups=5 order=ok gpr_mismatch=0 pred_mismatch=0 mem_mismatch=0 check_failures=0 class_violations=0 overflows=0 credit_leaks=0 cor_late=0 channels_used=26/55 violations=0` |
| `rogated` | `name=rogated finished=1 cycles=96 from_fetch=65 retired=7 issue_groups=8 order=ok gpr_mismatch=0 pred_mismatch=0 mem_mismatch=0 check_failures=0 class_violations=0 overflows=0 credit_leaks=0 cor_late=0 channels_used=26/55 violations=0` |
| `rokill` | `name=rokill finished=1 cycles=104 from_fetch=73 retired=41 issue_groups=4536 order=ok gpr_mismatch=0 pred_mismatch=0 mem_mismatch=0 check_failures=0 class_violations=0 overflows=0 credit_leaks=0 cor_late=0 channels_used=27/55 violations=0` |
| `rolaunch` | `name=rolaunch finished=1 cycles=74 from_fetch=43 retired=4 issue_groups=5 order=ok gpr_mismatch=0 pred_mismatch=0 mem_mismatch=0 check_failures=0 class_violations=0 overflows=0 credit_leaks=0 cor_late=0 channels_used=24/55 violations=0` |
| `rolimit` | `name=rolimit finished=1 cycles=76 from_fetch=45 retired=4 issue_groups=5 order=ok gpr_mismatch=0 pred_mismatch=0 mem_mismatch=0 check_failures=0 class_violations=0 overflows=0 credit_leaks=0 cor_late=0 channels_used=26/55 violations=0` |
| `roload` | `name=roload finished=1 cycles=105 from_fetch=74 retired=8 issue_groups=8 order=ok gpr_mismatch=0 pred_mismatch=0 mem_mismatch=0 check_failures=0 class_violations=0 overflows=0 credit_leaks=0 cor_late=0 channels_used=31/55 violations=0` |
| `rope` | `name=rope finished=1 cycles=705 from_fetch=674 retired=354 issue_groups=354 order=ok gpr_mismatch=0 pred_mismatch=0 mem_mismatch=0 check_failures=0 class_violations=0 overflows=0 credit_leaks=0 cor_late=0 channels_used=34/55 violations=0` |
| `ropediv` | `name=ropediv finished=1 cycles=1027 from_fetch=996 retired=203 issue_groups=203 order=ok gpr_mismatch=0 pred_mismatch=0 mem_mismatch=0 check_failures=0 class_violations=0 overflows=0 credit_leaks=0 cor_late=0 channels_used=34/55 violations=0` |
| `sel` | `name=sel finished=1 cycles=77 from_fetch=46 retired=8 issue_groups=8 order=ok gpr_mismatch=0 pred_mismatch=0 mem_mismatch=0 check_failures=0 class_violations=0 overflows=0 credit_leaks=0 cor_late=0 channels_used=29/55 violations=0` |
| `sized` | `name=sized finished=1 cycles=992 from_fetch=961 retired=25 issue_groups=25 order=ok gpr_mismatch=0 pred_mismatch=0 mem_mismatch=0 check_failures=0 class_violations=0 overflows=0 credit_leaks=0 cor_late=0 channels_used=32/55 violations=0` |
| `slotform` | `name=slotform finished=1 cycles=4350 from_fetch=4319 retired=12 issue_groups=12 order=ok gpr_mismatch=0 pred_mismatch=0 mem_mismatch=0 check_failures=0 class_violations=0 overflows=0 credit_leaks=0 cor_late=0 channels_used=32/55 violations=0` |
| `spinwait` | `name=spinwait finished=1 cycles=2160 from_fetch=2129 retired=211 issue_groups=211 order=ok gpr_mismatch=0 pred_mismatch=0 mem_mismatch=0 check_failures=0 class_violations=0 overflows=0 credit_leaks=0 cor_late=0 channels_used=34/55 violations=0` |
| `spmbank` | `name=spmbank finished=1 cycles=186 from_fetch=155 retired=13 issue_groups=13 order=ok gpr_mismatch=0 pred_mismatch=0 mem_mismatch=0 check_failures=0 class_violations=0 overflows=0 credit_leaks=0 cor_late=0 channels_used=28/55 violations=0` |
| `srd` | `name=srd finished=1 cycles=70 from_fetch=39 retired=6 issue_groups=6 order=ok gpr_mismatch=0 pred_mismatch=0 mem_mismatch=0 check_failures=0 class_violations=0 overflows=0 credit_leaks=0 cor_late=0 channels_used=29/55 violations=0` |
| `stall` | `name=stall finished=1 cycles=556 from_fetch=525 retired=116 issue_groups=116 order=ok gpr_mismatch=0 pred_mismatch=0 mem_mismatch=0 check_failures=0 class_violations=0 overflows=0 credit_leaks=0 cor_late=0 channels_used=31/55 violations=0` |
| `swap` | `name=swap finished=1 cycles=556 from_fetch=525 retired=174 issue_groups=174 order=ok gpr_mismatch=0 pred_mismatch=0 mem_mismatch=0 check_failures=0 class_violations=0 overflows=0 credit_leaks=0 cor_late=0 channels_used=31/55 violations=0` |
| `transp4` | `name=transp4 finished=1 cycles=1141 from_fetch=1110 retired=976 issue_groups=976 order=ok gpr_mismatch=0 pred_mismatch=0 mem_mismatch=0 check_failures=0 class_violations=0 overflows=0 credit_leaks=0 cor_late=0 channels_used=37/55 violations=0` |
| `unal` | `name=unal finished=1 cycles=137 from_fetch=106 retired=9 issue_groups=9 order=ok gpr_mismatch=0 pred_mismatch=0 mem_mismatch=0 check_failures=0 class_violations=0 overflows=0 credit_leaks=0 cor_late=0 channels_used=31/55 violations=0` |
| `vadd` | `name=vadd finished=1 cycles=158 from_fetch=127 retired=17 issue_groups=17 order=ok gpr_mismatch=0 pred_mismatch=0 mem_mismatch=0 check_failures=0 class_violations=0 overflows=0 credit_leaks=0 cor_late=0 channels_used=33/55 violations=0` |
| `vadd4` | `name=vadd4 finished=1 cycles=204 from_fetch=173 retired=68 issue_groups=68 order=ok gpr_mismatch=0 pred_mismatch=0 mem_mismatch=0 check_failures=0 class_violations=0 overflows=0 credit_leaks=0 cor_late=0 channels_used=33/55 violations=0` |
| `vaddslow` | `name=vaddslow finished=1 cycles=547 from_fetch=516 retired=17 issue_groups=17 order=ok gpr_mismatch=0 pred_mismatch=0 mem_mismatch=0 check_failures=0 class_violations=0 overflows=0 credit_leaks=0 cor_late=0 channels_used=33/55 violations=0` |

## Manifest of release/

```
9fe197d5a7172471cb67af104bca53d142a2041c8828448527a1424f02344459  release/kernels/addrhigh.by_instr.json.gz
d3551d8540d223fed5a9c4025352a14ca609086fce3d84eda362e13b9f7b8280  release/kernels/addrhigh.by_unit.json.gz
7f4025bfdc4a9e67d17c349cc2031239027d3a614a0080c15e41212d388f6c80  release/kernels/addrhigh.ccvtrace
0a74cf91e3e02900fa39d1bff23eff5758a3aa344868af920c4bbd7caca2ec29  release/kernels/addrhigh.log
569f2e22883fad5f0956c57ec734e6afbdd4b8a854e50277425172d6c0cbd766  release/kernels/addrhigh.oracle.jsonl
54b11f44d8a4f4e0b884bb16fe621e7df008384179eccaf7477a04b8e21373f1  release/kernels/addrhigh.sv-hosted.log
7ff7a6bd65a25659a8a1b815d8504fb8b139b110df665a4bbe86e8b5816d6d4f  release/kernels/addrlimit.by_instr.json
ec825e1aa533db01d6778b4cedc3d0b6d2a4485af86d802037be182be141b2f7  release/kernels/addrlimit.by_unit.json
2415076357c13d532727f342d8d78f9769f3996b44e4d63253d5779fe61d8f1b  release/kernels/addrlimit.ccvtrace
7ba51537f2c4d44cfd9795b9ce86ae35959875c0fe52f4ea420791436fd55716  release/kernels/addrlimit.log
bc660b0b40359a2c5a2478cb0eb4950b73fd22db50ea76b80052bc195a1920f4  release/kernels/addrlimit.oracle.jsonl
d0f11524e7d8fd6aa1ddff6e4d854122a40dea3272bbb54ee455ced359445c99  release/kernels/addrlimit.sv-hosted.log
99ca7dcfacf2ebfc39fe2d3c7e3168d75bba13443bc769835dd303eb097904c8  release/kernels/addrneg.by_instr.json
2757a55ed6523961f52b4d7721719c43976041c291cfd2e87b8d126e26facf27  release/kernels/addrneg.by_unit.json
f4503455b47d08c163665f4af4b035f48f142c804c82e0b56a2e7e02d6712ca8  release/kernels/addrneg.ccvtrace
ff2dfa1899482cc3ada6689ea0e344595c6755c4c96b8531b56e5ea00585329a  release/kernels/addrneg.log
16f5b0707ae44492a1efd67bb9dd38a7e79a7bbd354fa9207b9e7d150ff2f107  release/kernels/addrneg.oracle.jsonl
57ecad02e7c076bc605835fbc3b06d0c7c7193078b475fba2d4fb42f1ed3e371  release/kernels/addrneg.sv-hosted.log
e9bcf635cad5af022d5df7d97526e7232200b9d37ab412a0731efb800a7fa569  release/kernels/atom.by_instr.json.gz
6b8527a3bc7922eb33c23d4b761342295891556f028546f27faf59f8613150d8  release/kernels/atom.by_unit.json.gz
0bc740f47ce8f01033071f6055bec13f279a8d85482563042171f4c1dcde13c5  release/kernels/atom.ccvtrace
bf6141fadaaa6fb79a1e26bf7a1b0001f9307948f5071140afd3bb3067f4b441  release/kernels/atom.log
504f5b6e9d25114dc35f2c70b21bb7b3f3c508c691de12dc0e87d12a74285361  release/kernels/atom.oracle.jsonl
0d3d266c3385ace64d2b477bc05407581318e0106ed9329e9de1c524b6bcf65b  release/kernels/atom.sv-hosted.log
7d6d4140ff4ce2a8128c6fa877e74889dd533fae74b1d11e9cbf814ad91ee9d4  release/kernels/atomf.by_instr.json.gz
19abd8f28d08bd24f65cce46ee499fe86892ba95e9741146c65a01e45e3257e0  release/kernels/atomf.by_unit.json.gz
26531d45406dfa3872adce367e3f24b1c4b4e71c50dddad8d89173d4301de9b9  release/kernels/atomf.ccvtrace
e849a3f5bed472d06fb0b748b3c917c9f1e6f56dffc407e3abe640b8c5eb2773  release/kernels/atomf.log
cfd1179edf4061a33ab2f75d7a6dec61decfe629000198189a7bfc2647b34238  release/kernels/atomf.oracle.jsonl
e8b20cfb690ed14487c9bafdd960336912d11d560f043dcbffccc97f9a22bc62  release/kernels/atomf.sv-hosted.log
ec11493212111853660185e0e0a5f4f72b2be6cd09d3a3fc66c564c27ec9c3ec  release/kernels/borrow.by_instr.json.gz
d235286859cc59c50c0447bf1123c9e0aeb72103b4e6c97ac2d9518e7b7d1209  release/kernels/borrow.by_unit.json.gz
f47ba0ff76f39020aec6e50deb887c83af18cb9efde597aa3d2ebc7261eb3139  release/kernels/borrow.ccvtrace
078333d1a2e49691fd09848e8c9075757fb3f1e14960b26b1a57d3ab07bb626d  release/kernels/borrow.log
4c565e1ce0b3baee36e158694b32c8defb5cd662b2f9af75cb5d8c26cb1168ed  release/kernels/borrow.oracle.jsonl
a1e8ca4c9b7fd1faddadace6872d28c02777d329b3c8ec7ee1ced067d068b541  release/kernels/borrow.sv-hosted.log
ccb647d55ba1da69144658367363c4f1b9d62ad1c63f5a4358e29cf10e3f1606  release/kernels/brs.by_instr.json.gz
d5cf9549f26e25194389ba7ce26f10ddd442cd3c128c3f263ec1e9c3a7594c62  release/kernels/brs.by_unit.json.gz
0efbd34762b9bb839d84507973259b9161e0b6b94498eb217ab8eb280dacf7b3  release/kernels/brs.ccvtrace
59c0ae053d8a6c5533452d799062ed415ae7dfe2d6e8ffe2f0e3356fe8dd95ff  release/kernels/brs.log
e3c1cb3379580cf1aae44e8ddc8e846ef6fd661a573cfe0a8d4444b18a14dc56  release/kernels/brs.oracle.jsonl
cd2a012b649c09061036508b6e7d0d3f1d12a627c017d2c6c165f2bf3c91431b  release/kernels/brs.sv-hosted.log
f3d578eb887a8f63a397b5032ee85627a98d45ad38afe1e6c8f496ba138bcd40  release/kernels/byp.by_instr.json.gz
a316bb2fe958e8df90e9e9655d7ede3afa0361b848a85b5797dca5c67ecffc63  release/kernels/byp.by_unit.json.gz
86ca4cee698bf94b1548f3b1c9acbdec7c36a7e3888421f2fae3bd0627791e2d  release/kernels/byp.ccvtrace
94a68b5126be06296bec57801d9acad157931ac654bd080e7aa6ff2569ac9489  release/kernels/byp.log
5a03dfa4f3603fef49f1e3639e74e34152ca3ca5ef8e41eb959f8323040fa2d5  release/kernels/byp.oracle.jsonl
6d2e70440fff7d329e1f5b28d0c7e74280628e6fb41eb06227db300722560107  release/kernels/byp.sv-hosted.log
d4aa603aa21710aa1c421032d83940f5e756f9ec1a365fa59d6deeab303f7613  release/kernels/callret.by_instr.json.gz
e51582ec7460cc0a4c9f4972dcd64cf002e72c355d56a1ab8783ed1b698557e8  release/kernels/callret.by_unit.json.gz
b7b7eeb3e6d53aa18dca668f0bd9f2a6a499f69105bd8e0b4f645473e8e03fc4  release/kernels/callret.ccvtrace
4ba35e46d155137a7e3f1aaa51e74f0ed4b7b7d2b5314c9b91559852c25b28c1  release/kernels/callret.log
9b1d1b50b527f732362f837250aa2f26dabf3e76e16a4794856ebd8f105635b8  release/kernels/callret.oracle.jsonl
663aeeb616cdbb35f8635e65a6e3809de647ac289f28cf201908070bf5651aba  release/kernels/callret.sv-hosted.log
aa030a82789276d7e30652cc347ec2e7af60a3a353eb694f7e319c9b017e5657  release/kernels/cas.by_instr.json.gz
b7d8aa9bd0cf0d41793ce206fb9183690db33b5bfa3575ba87b74b7348cd67a3  release/kernels/cas.by_unit.json.gz
5877d648cbd8cd3344bbeb0cdc1aab3baf484763a7027f4a0402a924a8efc846  release/kernels/cas.ccvtrace
4c2c4c73748096117abca9e157d768636eb285ef725768e2262622925f63998e  release/kernels/cas.log
0ab31a9443336fe5d08e1a5fa5fcba3bc279b19022f7c5007908d39d8ef39536  release/kernels/cas.oracle.jsonl
eea7423a89592d77c8c949b9566bb7cd0e5df5af96d89a87f06a24f454326dd7  release/kernels/cas.sv-hosted.log
8d52dbce345d7def9c61bfd8f648631a1e86914f5c57f89f50664e29a88a1b59  release/kernels/chains.by_instr.json.gz
a7fc64a0e40db4bf7d7cb60be8c0ea6b3a641dec5ee89e16902818ce4085fbec  release/kernels/chains.by_unit.json.gz
b47e10902de830c337bf591bfc2daf06098880741b67957d8e8dd9c45208dc56  release/kernels/chains.ccvtrace
92808aed444133d20fa81b6584f64002595b7dfa0b4223e529cf9b36b04eabaa  release/kernels/chains.log
26a4cc5c5524c7219d8706c2582c80357dea60be9d6ffdec99dac7d0365e2264  release/kernels/chains.oracle.jsonl
acd5c920eeb895cf19ad59d518de73794bde297276f8942132630ac84049daf6  release/kernels/chains.sv-hosted.log
0cdfd549a682f684b8d4aa5dc6da6dc4118dc3c6493027b0993dab3dd3c8d5c1  release/kernels/coll.by_instr.json.gz
72270f3af563d417433a1e079f3526a28ee24b0e3276d75fdfdd016ea9a7b8ea  release/kernels/coll.by_unit.json.gz
9b2defbca3a81f102a07f1fb1a9473253e58da6ab1e7375a8d81f4d1fe098bae  release/kernels/coll.ccvtrace
c4de3a161b96e933a8726d32935ccabbe7783e0457d940516c7a23bceae02922  release/kernels/coll.log
dd718d23c88df5dc7d92b055d8542865aa0e029118486af127312a8a578cfcbc  release/kernels/coll.oracle.jsonl
369a829bbb893a7e41981dcbae47bf62e970fca52eb87ad43040357881861413  release/kernels/coll.sv-hosted.log
3e6a66f56ce5114741d9756fd3b289acd4eb86916e13756c7424aa17b1a2ba79  release/kernels/div.by_instr.json.gz
96d06baad2ac0a694292698cda9b78c556186f27be9c1d6ee25e7d78050645a2  release/kernels/div.by_unit.json.gz
182346c5baad147767effbea67248ccbc6e5c35582f0590ab266ce10e6e9dbc8  release/kernels/div.ccvtrace
e6d34502ba3994ba6f14446279d89d52812925991390f86267568a539ba22e9d  release/kernels/div.log
71a567b85cf85622631490187563de9a5661099c78a590adff4ed0a0c3d24c16  release/kernels/div.oracle.jsonl
66c31d18f2957883d9ea896bfb3d7193057699ac74c4206a41f8c0db17d074c2  release/kernels/div.sv-hosted.log
a670b87389383bc7c999620bec2c310777b905de14f47492191dfa7c281413dc  release/kernels/divchw.by_instr.json.gz
b0596359caacc1dcd9b95038cfbcb478d1dc520fb192808617952ea59c935546  release/kernels/divchw.by_unit.json.gz
4471a48e9f9555ec3ff526316b30290fb0ff75d28588185a2a52382020681eb5  release/kernels/divchw.ccvtrace
fa43ff67f1edd65d9fd095d126920572caeba9f2e5ecc2f7f8da1bebd909b0ae  release/kernels/divchw.log
58a541797f7a2df0a1c7528ae6a3edec212db90c7d3eb20656806f38b5c10b3d  release/kernels/divchw.oracle.jsonl
803703628288f768fc00a1df6dd8720bd927fc49685475821f0f44bed352b614  release/kernels/divchw.sv-hosted.log
a7a190fe12eec2f3866d27fd9717ffe1e1f65529fe40cc8bff9a3072907c0d7c  release/kernels/divtail.by_instr.json.gz
48cc8397267f902c727526824ded39ccc262faecdb5f47c1d7b849320cab79e9  release/kernels/divtail.by_unit.json.gz
2ade202d8c5fc071687f18239b0573f55461d1606452ff6daa16db3738442f2c  release/kernels/divtail.ccvtrace
8c3e9a31cecc7ac6c0e8dda970c548c5940e8b707f43fddd1cb1699f686344d0  release/kernels/divtail.log
75f11a75c9b3b336e446140af4579f05b46c363a76b7aab3ec88154a07ba097d  release/kernels/divtail.oracle.jsonl
d088a7b379fa8a75901e7fe32c184b49d845d6a8ed0a64320fc4f0797b7830ef  release/kernels/divtail.sv-hosted.log
2fbcfdbb539a213089075193d8c90007557daed45e2e0182e33c44f00697d314  release/kernels/divtail2.by_instr.json.gz
b165d6a0fca19caeb6c18a1233b76be0d5bdef2c4efbca7315828b2462d227d6  release/kernels/divtail2.by_unit.json.gz
e27413844716e2c50ee7f69833576c60a6fb7bc226660dfe365677c387affdcd  release/kernels/divtail2.ccvtrace
a9cfb2ce10083885a5a804e142a8d82870a90cf2db1c4d471b4eeaccd45c0270  release/kernels/divtail2.log
b2db6b05eb6cf4a0a7677e31d0c6c2952d5cab49d353f0bb1883fe0b2a20ed14  release/kernels/divtail2.oracle.jsonl
a86bd427b132bacdca82ee7a3ea53a5c38520b6d0e6d1563bd939ec83c994e1a  release/kernels/divtail2.sv-hosted.log
7ed7898e468f05a58ee4a868919f8464ca5a672cbb98c6e9d739843a64cc4af3  release/kernels/fence.by_instr.json
9bdb84dd19f4e499bd41461ed417ac4a744e7ead8f263a021cbd5fd2be40c270  release/kernels/fence.by_unit.json.gz
902d571234711aa609de8947a424a60e599755724ff6b2bf6bdf1550cf10ecf6  release/kernels/fence.ccvtrace
7394178e308a3f62f6d2a67789b15daa27b7b684bb04f49d4b5a8205ddc7fd4e  release/kernels/fence.log
d1d40317f6cf5bfb430cda1f9c0ef676609e59cabe2a11623c42ffbeca93142b  release/kernels/fence.oracle.jsonl
b24582185dd12d35ee3c9c63adcf3af900c96ca2bf5844acdc8c607d9aefab55  release/kernels/fence.sv-hosted.log
34be85025f40e23e15c5f4914786e4969f34adc022ad2d5fbdbd27a0402e96fd  release/kernels/gather.by_instr.json.gz
3d214dd82d53c96fc9592a432f0d00dd36c3b0c1394153f97d93150922ad4954  release/kernels/gather.by_unit.json.gz
7dd36b5debb059b7451787301e7c983159b9833d498fbce4faad199f81b1b646  release/kernels/gather.ccvtrace
657b7ed009f2441ba3d197df48f305a139e92f6270a8ad702c9555f3f0ac5d64  release/kernels/gather.log
0413e781d8d6ff578c64eb1f800b7931e66f676d5cdabb97b94a4033e6037662  release/kernels/gather.oracle.jsonl
5ef3bce0ac76efa414ca5217381b4ba8ba78ece1f2fa3bb611cfbe3642b5db6b  release/kernels/gather.sv-hosted.log
d5bf2ef2c06aba437df7bff5edfef9cee8a89644bb704cae19c97feabae82ef1  release/kernels/hit.by_instr.json.gz
5da69592bc68a73ac63897cbfa1c67440274f8a20834fd1a42350c96c8872359  release/kernels/hit.by_unit.json.gz
893ff785c670decbe42a7f52b662717eafc73000532b6104f2b6de421c0005f4  release/kernels/hit.ccvtrace
c2ea52d1260d3e6cc46422353a7734f73ddf134027490975bb4da437fd0d9d58  release/kernels/hit.log
7ba9603e0088d9164de6528f16ef6a7fa9ce5821c8c12b52cbb3734e39b9fd52  release/kernels/hit.oracle.jsonl
6779a0b4a0982414cb0aed9f7fe9deb645f357df2fce0cad0d499ba04f442d0b  release/kernels/hit.sv-hosted.log
ba5029e1bc7e4913f44f8c87619aecfa26a8707c38900720962c821660d85822  release/kernels/lanectx.by_instr.json.gz
c2c4472e3e6b6a0d16cd7d7323facb56cb7a62a2690c987eeade8d1a7faf4a37  release/kernels/lanectx.by_unit.json.gz
04cb909321122accc72a84a88ce06c11e76a20160502594b50a562bafe82b1a5  release/kernels/lanectx.ccvtrace
89d4c5aff37234ccc4508c60f6138dacfb2f756d0fa370f651ff4e27e07a953f  release/kernels/lanectx.log
888551babf540db8e3025b82e65ca655013f93eba3c8a65689d069d52a7e6039  release/kernels/lanectx.oracle.jsonl
ff644c2db4e9af47a57a41a0ec7057a70951b2ec7f1819b96e735686e08b3976  release/kernels/lanectx.sv-hosted.log
29db0a8749812f8d920222b7fdf055d77f51867fb8300cad518493618183e2ee  release/kernels/lanectx2.by_instr.json.gz
6b611a9310efbc338d5152eebfe99f9ce7d1e072a539fe070659348531920410  release/kernels/lanectx2.by_unit.json.gz
ef023c0267cd5d07b71c47b7a7879f569ee3c013aa6d0e14a776bf7dd08e305f  release/kernels/lanectx2.ccvtrace
1f8855508ed71eb4e7f249100f71df311766d959ae18ed5128b99bfeb317dbe7  release/kernels/lanectx2.log
45c13056dff5c73ed0c9ece56cc36f929bf335322193c7d5eb38710b1d1dfb02  release/kernels/lanectx2.oracle.jsonl
2d1d7968a6211921272df610fb8325067634bb9b88f8b229bbe6b68969c221d3  release/kernels/lanectx2.sv-hosted.log
70ea6b71f9b814ca99b479bfa03b41f3dff0c80dd8238b2eb2a43f3cf1207557  release/kernels/late.by_instr.json.gz
6a50263747d44272481b1d1152fbb07346ae7d92ea8005be143791ec5bc373bf  release/kernels/late.by_unit.json.gz
4d01e4f710094f92535e5bdf98d039b53e0279d85297e3891c30c9a918042525  release/kernels/late.ccvtrace
6a6829c47e87e438160fbb598f5a2361248d8ff215d04c3f6ac949f57e330bc2  release/kernels/late.log
86084f6bd747a2cf32acbc0ebd96ebd3e4ef2d8d9e21be49e3ae49290d7927f3  release/kernels/late.oracle.jsonl
38baae0f758453df1ad9ee1f2d946c7da34f988272ed64b6974e48f336c1f421  release/kernels/late.sv-hosted.log
147cd9f561b3fa8db1d2cd303abb7d6c789123fc0997b449f5671116b8ccb520  release/kernels/ldpar.by_instr.json.gz
36fba666df66ccacd78ca9e7fffd18be3c1b30b74f50e8c9450b7034e2fcdedb  release/kernels/ldpar.by_unit.json.gz
e1a8cb1b4392a870125afce5c147babd4adb301aca13ea213a6b9f40bd246472  release/kernels/ldpar.ccvtrace
e1aebea917ba0e38996a7258ab2056c30274ce54827df8d4a9eb195165f0ad4a  release/kernels/ldpar.log
8ac08538e9c807637babd61b31e340f7461878ada31f0c0b83cd66331cfaf486  release/kernels/ldpar.oracle.jsonl
5a6eb22aab2268b7a77508d384a4e8a4ba9c4191c86418d2aa0dd3d64743c800  release/kernels/ldpar.sv-hosted.log
b9483d4cc251440a1fd98041526762f9cdf48578c261af11e7d6696b22991f90  release/kernels/lnorm1.by_instr.json.gz
86c2683a8b1ee653b918c034f48b968503c6c7427ee043eaa2aeca1e65f516d1  release/kernels/lnorm1.by_unit.json.gz
efb3db304100f3fb99fc9ef199e8c8c51f704b777b3235b0821e11432d79f628  release/kernels/lnorm1.ccvtrace
6cf3343ffa81d830b3f7d1f3d38f9c8f4edb5c6d7870b46ac74e489545ba7d79  release/kernels/lnorm1.log
a8d85811af988a1b9fc00db1517300af3d93ec8e589e403d3b9113fa9e0ffc86  release/kernels/lnorm1.oracle.jsonl
ecd8626b940e83caf742dfd9166d0d75d7b717eb3d7e3e0cf07511da7a9d8bb9  release/kernels/lnorm1.sv-hosted.log
5b5912eec8d34edca5dd040b7696296c524610b331dcfaa5aa103bc9424e152c  release/kernels/localsp.by_instr.json.gz
e7e51a1dc2e4067e5f9db2da2205c75b98af4f55c019ef5eed4cdda6ec5e8204  release/kernels/localsp.by_unit.json.gz
d1f65404e6fa7aec7e975bd27f5d846267aae0c74d0e1a60346d2df8cc2b3b3a  release/kernels/localsp.ccvtrace
e6d79df53fd6baf9dafb871ccd6226b093177a4c0567402ba8ebe070e1933828  release/kernels/localsp.log
55e3c9f36e7f7d38c0ddd38903aff4bb4509ae862015c592e6b937ea258042ca  release/kernels/localsp.oracle.jsonl
70d9cffb1f4bcd9acf9e622aa67ef92d810db4310f05b8b492559d9e2fc363e5  release/kernels/localsp.sv-hosted.log
23dcda3e1dd596789cf9135421a91c1ca684ab90e4c57aebc1b56083137e0f5e  release/kernels/loop.by_instr.json.gz
7cdb3eeeb80c7da52aa7d4993a8e9ab409252a0bc83f1c01d68d1c871465af8c  release/kernels/loop.by_unit.json.gz
05599f989c0d60da6bbedde81701aa56ae1c2a56bbb878bbddeca9829b14e167  release/kernels/loop.ccvtrace
d670c088d570a06362fc60bc51fd5c878034236e9d498b064b13be7a480f3b59  release/kernels/loop.log
03ce5920c06c93e93516d8e53c3f7169f14e3593de204eacceffc0b8a3e32016  release/kernels/loop.oracle.jsonl
dbca5d68a5360f63b8c0da48b46572fbf9c596a67b3dc9216d2584678a756b51  release/kernels/loop.sv-hosted.log
a31d7341571cc7a50a7869ec05abc431f1f268b1ecf06074ef52e05b889d29c3  release/kernels/merge.by_instr.json.gz
369c570a1b873cd3a587d078b019129fd293d22f8ed343b0e69b559c165594b6  release/kernels/merge.by_unit.json.gz
2f43408ff2d9fff8512adaa9e24aae50158636b35dd1778e07d3a003df283170  release/kernels/merge.ccvtrace
a543c4ec961bafda2f38f60a5d0238d7aaa951d10112b1d22fc21391c59d166c  release/kernels/merge.log
f96d28815f8756b1f5a45ded53e6170883d2dfa10f9eef0d14b8050b1318164a  release/kernels/merge.oracle.jsonl
7d94801571771be2e7a7486b0d6fafa2cf542783a01913a3f76ecba90354b045  release/kernels/merge.sv-hosted.log
57c0c30b091261e0273d3513e320620f90333d733eaecfea6c2d7ae580934690  release/kernels/missrun.by_instr.json.gz
c1b0e073b2e6c4f182433ec905f1e26b1cd7f9cbdeddbb10f84243ba6ee45ed5  release/kernels/missrun.by_unit.json.gz
904f65ed8087afef70b94611476fe70013468834790cc80993d641d175678d82  release/kernels/missrun.ccvtrace
2258d758877d9ef35a06c00d8825f5c394c7951120f2a7747f29d482716a46d6  release/kernels/missrun.log
531bdaf281e5590774bd2775427f25e4cc0419cf8e3d5b6999843ffe9ef87258  release/kernels/missrun.oracle.jsonl
3401ce22c5aa883b09e5361aaf58ef6febb1ff5a7bcde71d9e77234033b11ba0  release/kernels/missrun.sv-hosted.log
1563f690c60519e17583f419eacd07b78252c870fc23f7c54cac84b7f5b8c28b  release/kernels/mload.by_instr.json.gz
ffaec4192bdfece7453fbf7423a11a04b59037d8a9be02c3e5a30152612a2b96  release/kernels/mload.by_unit.json.gz
76b553be6382705b8a38e14f10567c4c54c80edce392f55edf4aad513b4ff522  release/kernels/mload.ccvtrace
fb8cd197586e4e7b90a2efa8008d35cc138249e696a406040d9c53c6ab81adf9  release/kernels/mload.log
8000e477b9a95dfb9f0af964e8346acb9d36f1358fd06ffc4ff7cf599d2b8868  release/kernels/mload.oracle.jsonl
4b5d978b8d3808d5f5d8743065a51e72241717cffbdda4f0fc538e46d68222b9  release/kernels/mload.sv-hosted.log
6f5314aaffc6766b60f9b132b7125fbe0c4fa1ae699d783559600292ad6ba960  release/kernels/mlp.by_instr.json.gz
f7f351ab23fee385af13f1374eda762cd2223bf267e8f8529fd8c507be2bc43f  release/kernels/mlp.by_unit.json.gz
7cd6f5ae5f30dbf86e7e4a4c0a82e6f1bdf6fe471cc6e6e37aef86e03bf88150  release/kernels/mlp.ccvtrace
215753317accf28495e9b917b226d4ff17aefc209e593f4386531f4e7bd34386  release/kernels/mlp.log
138d282f88d56c8ad648a91af0a983254b55d9fa22942c00d47b327f516a6e44  release/kernels/mlp.oracle.jsonl
beb5ec598b76e12ac61a7137f410479f0c3700f9bca957c064aad5b9c7e2c5ee  release/kernels/mlp.sv-hosted.log
545f19e91e31c08aa80b78f487a43a806a2be23334158ce160c96088ed75e9d6  release/kernels/mwmiss.by_instr.json.gz
eb51e06dfdc6d83df8b563b7b67569331cffc0518a4d5fc2807d905b401e0f91  release/kernels/mwmiss.by_unit.json.gz
f218172f4887742106b54c2b71356b417c6f406c740e78cca232f9d437b3fdc5  release/kernels/mwmiss.ccvtrace
fa949a208405fbfa27d0193be907c18b20e9f6b844c8c7adc4abcf2385659385  release/kernels/mwmiss.log
8abe8e8997456a2a6711ee72da54d854b24e20abbdab28e4b7271c0d28418de8  release/kernels/mwmiss.oracle.jsonl
10ec655e91ffca11ce1a55befe99ef75a02305b52fec8ee52c9c6e88d95c1bb4  release/kernels/mwmiss.sv-hosted.log
f64e3d84d06a8b3147e8bf0bcf28dfc00174724115b17c5032d8f0a315169bcb  release/kernels/narrowadd.by_instr.json.gz
ac99fa7d320918193d41fb3c4c5fbad6ee14b7c2bc1157d7dfed8d6b0f015bf6  release/kernels/narrowadd.by_unit.json.gz
15a76c0955f9c35c0f6536d59b6c38e517ded7ea3b74e350d2288ab716482cf9  release/kernels/narrowadd.ccvtrace
fde08eed67d983d400582513a6336495112becca847373f287bf951b55ec1aa7  release/kernels/narrowadd.log
40a2cf629853dd404bb06b4a07e35abde3d12efc13f26ffe28f923daf2994574  release/kernels/narrowadd.oracle.jsonl
30bf2e81e24d28e82a4513b674e7c1f65f9052f338c7f3a31e0abbd5efd5e881  release/kernels/narrowadd.sv-hosted.log
3c95747bd51f8dac6e30d5b724541572a3193bbde3fd48d4818702061dcf6e28  release/kernels/pguard.by_instr.json.gz
e99b1458c66274c7a89b957c8faab5d363bdd09cbe7d65e19440b7753450d2ac  release/kernels/pguard.by_unit.json.gz
1be32dfaa56dbde149ff08e78810d1e8adfc2d6b199d31a352930ba7859d0d18  release/kernels/pguard.ccvtrace
33161da8796b18faa2f619cb07f234d2e811699a739081209a6d5778639e12f6  release/kernels/pguard.log
690e56f1cb8d97cbf67124b7dff3ad0a90cb8981814cd1709cf0cd0e035b3bd9  release/kernels/pguard.oracle.jsonl
3d0d7f492e06486b2f48744cf31b71186a78afc0acc47831cce2047b3ae5e7a0  release/kernels/pguard.sv-hosted.log
d3fc2627d9f8c7e501c863574a5991e2fd5b5a99b94656a37e397888b93d1a17  release/kernels/plog.by_instr.json.gz
b7f1f5f7f43d8fb3539f0eb4b1199439b06b32d194ddf0996e653947a3901db6  release/kernels/plog.by_unit.json.gz
ce4aec9a797ce6e24a9082c3c4e22e4cc45d2bd6d9cf47ffadb3e8da5e251eb9  release/kernels/plog.ccvtrace
ab63c291fb2bbbd12b826c64e25f78f3cd40d2ebed5f4ce3fd270ea6fd3629d8  release/kernels/plog.log
0c99915e2da60f4670da00504a6371d7d17701d4431e733a3ff8fa98a2030d6a  release/kernels/plog.oracle.jsonl
644075758ce0d96d99d37dbb6eb312b77f6cbde118e70cf1fc0ad47272ea55ce  release/kernels/plog.sv-hosted.log
d016394bf8b78629f2c1fa66cd1aae32d4b088ea15d887fc70bd185d33c44219  release/kernels/pmovdiv.by_instr.json.gz
bd5d7a3826b6a013563c088a783f2f2e990629ba88ac64ce96af1073b6d2fbd8  release/kernels/pmovdiv.by_unit.json.gz
4fe481c67584f36b72d1f510fbace5f75fa34ca8d76713e16d393f8638f099f9  release/kernels/pmovdiv.ccvtrace
a1126ce1715383989708d6a2a6d400272fccb9cbc20625f330f3f2f76628f499  release/kernels/pmovdiv.log
7bc646cff6166a51bdce03d7c1b7209e871f0a91d743083a9b910a80bcd0b33f  release/kernels/pmovdiv.oracle.jsonl
7c74a1c8b8b61c52e655f92991122663d4f6e98c323446cfaa6fd5793fb1ae46  release/kernels/pmovdiv.sv-hosted.log
2a6408d46cbd9acc53c8f8004d152c93b80f155c1122d27a89c2d5fff025e8b8  release/kernels/predlane.by_instr.json.gz
6efd4f9b116e7f9f9f90aea754cb58dd18e17f812957fe51ba12e351cb77cdd3  release/kernels/predlane.by_unit.json.gz
532a8a0c9135721ab0526accc4358e8fdb1ef57c82585686a0c80705acd1e51b  release/kernels/predlane.ccvtrace
de77c2a200a7eea5e2a95b5c2941fb6619f5e7bc588a1abf7397bfc6f7919087  release/kernels/predlane.log
c45f4177b9e84fc8a6e36b13534a0c7636eb30a3f8531847100ce5e23bf404b1  release/kernels/predlane.oracle.jsonl
6c7d5da08f8a1a241371a6d1890cc4365d83f21878b587c9dce97239f1bb6a3e  release/kernels/predlane.sv-hosted.log
07a64b617cf3c7c7c0ba963123b83caa925da623a786b4ea3c82c5e4c5bba5ef  release/kernels/predmerge.by_instr.json.gz
c2d54197a9c2839900681a40283d86d92b8ee48845c0a3ddb8bab952f8b599c3  release/kernels/predmerge.by_unit.json.gz
505403182995d5204046ce387c328ebcdbcf638bf96eeca5047ce00ae556e20c  release/kernels/predmerge.ccvtrace
38b22234711b465b56987edeb8723e0edbf44de8fe3bb8589ce0a4f03ec34731  release/kernels/predmerge.log
6c737c49434bcd08e3e0814c8b1dbf15c586ae74f7929ba3148ddcee2c62c845  release/kernels/predmerge.oracle.jsonl
ee44fe4c69c288e4ec58b4c60f4b21cf165c4664ab77a5b3fb173d0a133e2c89  release/kernels/predmerge.sv-hosted.log
a6ce1cfa7fb2493c90815c1a6e8299b37d6bdaa2f480928dc4b0d6eb14436b08  release/kernels/predspill.by_instr.json.gz
6d978fb5b220a294ccba8d4f58b7dea42cec82df4482ceb024e949f461141968  release/kernels/predspill.by_unit.json.gz
99589c2367cfa6d554c451bed32503c586dd1c925cf07763095171cadff9a5d7  release/kernels/predspill.ccvtrace
81dc5c4f3a3679428dbb4d029e57a6cfc42704d1c0fbb9da7f079cbbf3f74009  release/kernels/predspill.log
b7c84c6478117ffa0f06da0e6ad1e4628e2683426a7911080810e78e06a5242e  release/kernels/predspill.oracle.jsonl
d5794529dfd27bc0e57b4ccbfff4a6c5bc24270b9389e9ab95567d2c34e0b673  release/kernels/predspill.sv-hosted.log
d4b306c6b13a040e3e060537c93427b1e3932b6d46ea2b021b2097d2e46a35f2  release/kernels/predswap.by_instr.json.gz
449567b41897f3d954b9fd0d5365a8a2e49154b0a5e60ea78616ea8aff3f50ca  release/kernels/predswap.by_unit.json.gz
e93b8efd89d74d085e81ca285cc6abdc1d88d9191054f91939a93cd8fb6e173d  release/kernels/predswap.ccvtrace
00db5b897304d7d5723bf99cb2708cce44000d69959ea25bd7192b101a3a3d0e  release/kernels/predswap.log
a6d4f7ed517553816d889c7c9eeb6bcfd1f6c973fbf682ecb69f3c2de619f7bb  release/kernels/predswap.oracle.jsonl
52d5c5c2d85099a5a341580caca6bff71de39d46d4b7ded7ac0ba47d3cb4b127  release/kernels/predswap.sv-hosted.log
e6130a3e9b90b56f2d93c7a2ce530cf0f59eaea90299a6acf4a81cea038f5c8d  release/kernels/privwin.by_instr.json.gz
c4bf9f1055eb3538bdb54bc0de541f9a14e67b49d63aaae653647373f29aa24a  release/kernels/privwin.by_unit.json.gz
18e0e4196496316afea8ddb1ebfd35823b55f55b525c74a00da737519767f2c8  release/kernels/privwin.ccvtrace
15522f8c55aea562cc2f16ae5fc5dc77544187dd22eddb0286b22ec6ce35cad8  release/kernels/privwin.log
861f686fc4480363472908d679d8815e8c957d768e7ab32c826930527b0fb7a8  release/kernels/privwin.oracle.jsonl
65cb2d11f166cfaa326f146d7c58f827787fe08655490b6278c7435168579ddd  release/kernels/privwin.sv-hosted.log
348d598d9541ac0bb9c2892dbf35b259d1c48857129df22c5c38fab76881a942  release/kernels/provswap.by_instr.json.gz
66c84bd955def4050807289a3b8d09ac77d84a23d0d4f76fc7455408bf5c4d32  release/kernels/provswap.by_unit.json.gz
5597ac486c6c41c594b8dca2384709e7efa590ee2803188b22be0d922972f27b  release/kernels/provswap.ccvtrace
e5906641458d1c4da95ca7fbc9c0e1dd0ba6da543f74aef6725c6f9fafb695a5  release/kernels/provswap.log
c9c32a793d54cc7401477f582487f7e8b345b2669a75337b8d6327120d98e5dc  release/kernels/provswap.oracle.jsonl
330acae363ff0d01ea8251ff3f77cefeac01664b8fa9adf1547bcdd1eb8289f1  release/kernels/provswap.sv-hosted.log
b16e06918bb8acb0ec5b0c69c222977f46e4dceecf3c5a4593b444e420c26829  release/kernels/retmiss.by_instr.json.gz
5950dd03eda62318cf9bfb9edd63418bf403f380dae68b68d5e59ccfbda05925  release/kernels/retmiss.by_unit.json.gz
d362264f223295de3b7593ec488c489875eb71f98f1a9eba55148418537fdaa8  release/kernels/retmiss.ccvtrace
8e43260ce1ac93e295a1fee7ae7365019c67a2aca9915e84b915d5ac262ad828  release/kernels/retmiss.log
e5ef8538e838c6cff7febfc679dd091cf5e002f82d34f1009b1948ce22bc3649  release/kernels/retmiss.oracle.jsonl
caec7c345223aee5ee2b904f3c7388df35c5deeb92abe5aa118881d9c24baaff  release/kernels/retmiss.sv-hosted.log
d45b064f90b496adbbbf3be694a8cc4f6af4ea41825c8bb83b0c4042da5a369a  release/kernels/roconst.by_instr.json
b38b6900712bfd3ada68a6b3627c4ea3fe521aef042fc47dd43dfb23bb1283cf  release/kernels/roconst.by_unit.json
f3713f83ec2f195b035033bdb47cfd76ef95bbcac2a975d18c8e17e3b3ccda49  release/kernels/roconst.ccvtrace
dc91a5edaa0d74b984ccd65fb7d9cbdaba95276c615c1e018dced07a52ddc50a  release/kernels/roconst.log
8087c0671de620162881aecd38cd6114b78e7be6bd71201e3ec02c9a2e2e750e  release/kernels/roconst.oracle.jsonl
c065a9c620d36d0d54b5289e6c71ff8e66249edaf0ff612febbaba0693b3e35b  release/kernels/roconst.sv-hosted.log
7d213047dc11229803ff907bc5a2192cad3a16f993fe7f5ae66bdd5e6ec74442  release/kernels/rogated.by_instr.json
61bcfb41f9b3894bfe2473270bf23bf55f26e03fb8b46a571c663df40cc17a47  release/kernels/rogated.by_unit.json.gz
e0022bd67a6d629144891b56607860fafa98ac1de5fa80dc411be11a44c9a890  release/kernels/rogated.ccvtrace
ad8cb6720e63d2fa507fe62fb0ed5d0a6bab3a9600c2d2d70031e5c8a08972e4  release/kernels/rogated.log
7cd02bd4cceec5a044d6b4d6a80df1e68ed0ae71b0b2a953143636d5b809ea6c  release/kernels/rogated.oracle.jsonl
936ae82d2c581049f28631071cd59abf641c0c52731354f473d68abd59398a69  release/kernels/rogated.sv-hosted.log
591aa3db992db71acd16309bb91732cb507a1e1fbecd38ab7478b3a9687070d2  release/kernels/rokill.by_instr.json.gz
06ed1a1a79d52e2957a3e95373c7bce979b3765d31335a1c69baae091408ebe4  release/kernels/rokill.by_unit.json.gz
cb434c89178bda63feb85c508e8cbd1b00bffd6b69525ab858d2b11b6cf16c17  release/kernels/rokill.ccvtrace
078908bca4b0405d6f0c6b9f0677267633d2480fc0ed5ea3bdad46d862eea96c  release/kernels/rokill.log
94efcef96af469a512d346ce61623980fe86383188eaebd55120f716db596f14  release/kernels/rokill.oracle.jsonl
da82de35e44ceb150851fdc1bbe1e7788e387e4c4bbad7eb762ef72ec3ead8fc  release/kernels/rokill.sv-hosted.log
f8fe604241644b224e6431d16e4fad889c99826b82f49205e4c9014b9ae62e8a  release/kernels/rolaunch.by_instr.json
12e5281971b0a06ca95d953aa22a6d6b481d8fee948f50ab777c87877757fe46  release/kernels/rolaunch.by_unit.json
32fbf77dc8fb17f0113b068b5a00568b6ea97be3ad8e5bd1c69b7cae2f04a946  release/kernels/rolaunch.ccvtrace
49bf5f581e328a376aa686b72457d616723a5976bc381f49641c690ed483ecc8  release/kernels/rolaunch.log
e7dad585c3e70615de04330fd03f4f282c29a005dc1732a35655fb261d51139e  release/kernels/rolaunch.oracle.jsonl
e75c3f8d6e6e273f91087ccb1113d3f475a405e1866d249acc8a7dd37e4c325f  release/kernels/rolaunch.sv-hosted.log
d45b064f90b496adbbbf3be694a8cc4f6af4ea41825c8bb83b0c4042da5a369a  release/kernels/rolimit.by_instr.json
e8822066a61bf10f59647aa7240a3044f25d2eba55ac5f7ebacbf1901974dd8f  release/kernels/rolimit.by_unit.json
0e8db555321feaf0fded659de3d7ab35b3dadb15ccef4bf8dabfaec2e87a5563  release/kernels/rolimit.ccvtrace
c1545bc7954a44910abfaef8ea83feb5038438270845bbffd1fed45fa018a4e4  release/kernels/rolimit.log
1c5bc0cb8e8b2e69505fb5a551a16d5d10c56f232b88da7a27e336ad7d962de2  release/kernels/rolimit.oracle.jsonl
41444b52bc769fdd712b2c9d4ae35d9c33de0fff969c09dcb01fb89ec15a31a8  release/kernels/rolimit.sv-hosted.log
a03a2ad5511207eb9e97a1555da073da500e866d8e50333cb18d2a4bda8a6662  release/kernels/roload.by_instr.json.gz
aa3f7cb1cac6efc2ed32083dca96f772552cdce2427f29d1c994bd27ef9f0c9b  release/kernels/roload.by_unit.json.gz
e2634c3e7aff20e8ca7e9c8f14599a3f74ea0f42f10d0bcb19fb0f8333fc3eef  release/kernels/roload.ccvtrace
02f83029780f7a9a8331bc6b74705395a99927f62cbb1591413e592a84d87cde  release/kernels/roload.log
f7c1309cc9764769fb5803f6fd0f2f5e1eb418f2d23fbe5e17cf5f9106869fdf  release/kernels/roload.oracle.jsonl
5d9b4ecaf49e8e53c61965e32c74f27c3b800b41ed7f6c920f57d1d06907d8f3  release/kernels/roload.sv-hosted.log
952b09a6281af83ed94dff769a712da34a58370844c1b49afdfa1817828ee415  release/kernels/rope.by_instr.json.gz
cd62e8a76a87d880c1c6a2d48cdb5b0fca13ef23be3a0c832b86062332cefc16  release/kernels/rope.by_unit.json.gz
c40ca40858a13f0528f0d1f946ad3b0ad60d1c6c35bb432ae5f6fa95b49f701f  release/kernels/rope.ccvtrace
ec2221459ab433fc247a50dd1aaf174c1a3d209e216d5727676176151feef454  release/kernels/rope.log
d55f9efae392dc8877c102c01c0810e7654b666b6ede386328108164c6cf88f3  release/kernels/rope.oracle.jsonl
2144b3f26a6bbae73f7c165516e0033eaee76a1aaf6d0d6ff57d614a7b70ba79  release/kernels/rope.sv-hosted.log
e7c5513bac45e4e1046c50122d168b8c2ae18f8d288af16cd7453bc929bdcf3d  release/kernels/ropediv.by_instr.json.gz
5c990db982f00a75132b190efb4dc9739b33f7470da711d09398dc18499b3d1d  release/kernels/ropediv.by_unit.json.gz
ab39624cae9f0b150f2bac34676e667c91b8d180c27d5860c8050cf057a4329f  release/kernels/ropediv.ccvtrace
fcc57720b91947f7dda01aecd780e78a85f2d259b770d62faef38483b464f31e  release/kernels/ropediv.log
10c0ec6ec18b7b44638c790033109198c079d07c1537bf193353ccedd00a920f  release/kernels/ropediv.oracle.jsonl
74a85fdeb28656b737794f6b9f63f90499907809512638f98ca5c9c737f8113f  release/kernels/ropediv.sv-hosted.log
5985f2dfc37816f12704ff18927ce293f0caf61326e8c02fdaa7b80b7db5145b  release/kernels/sel.by_instr.json.gz
f3b8cacfca873df204951df83170be65c119f6e869d1bd71c68154ebed706738  release/kernels/sel.by_unit.json.gz
bfbdf6055affcc6f1da5e0ca404d70f0e1ba25424943b4357452b1e5ed16df5c  release/kernels/sel.ccvtrace
53585b0d78ca5db9290b3d3372c89d2e55f27ee17d51a1bb73a130c4d3692cb6  release/kernels/sel.log
87f6a81e8afa004c8039bf2f61c90176fcf29ab29bb17ac44aa016a5cc8438fe  release/kernels/sel.oracle.jsonl
fd1197f2b18bdc7384f3301d9e369d77650310d4f7e11e3935af29320cacb906  release/kernels/sel.sv-hosted.log
cad3e1d4125885fc28545a3db2eb333af5c0ed8fd373686c5160449b24153c0b  release/kernels/sized.by_instr.json.gz
4934e16a28bf11f3cee0e736974e37cb9b9c9e303cfdaf4f125b77ecc16022e3  release/kernels/sized.by_unit.json.gz
7d7b3156291cf98ba08d0d93b5dbbc7f7d1b3bc9b4d7c8cf2ed07ddf408043a5  release/kernels/sized.ccvtrace
6131bd9eac6c8b283a8325ac9d8d9e3582cb6b9d0a2a9250fc66b7ed714e6f30  release/kernels/sized.log
36d903ba1618bd1faa437c9812a6ee6c0c966a63196c796267d74bf2695ebc3d  release/kernels/sized.oracle.jsonl
7dc3e828507b7305299d73f8bcd6824c8d219529ec398a4257b80bd4b54b4176  release/kernels/sized.sv-hosted.log
5cbc70b04b248e2bce766fc5447320b8a9d73edeecdd0bfb9683068753660c4c  release/kernels/slotform.by_instr.json.gz
061c0b9458a42938502ad48ee5751a5f7c906509c78d4ce363ebd169abc34933  release/kernels/slotform.by_unit.json.gz
bca4999deafabda9e24ba5d6f10ffaa5606d1f7062993e6963b4a14026bb40df  release/kernels/slotform.ccvtrace
1f6191b1556b9a2350337fd78a5d09d705d0ac8e593343bd13115ec115570c09  release/kernels/slotform.log
8b61db7419b18cea8a646fb628218447e72e84a18a9891ffb73b441736138ab9  release/kernels/slotform.oracle.jsonl
967c147ee4a44ccca1e404c8a0e17ae16f322c191b8556711918bea6497dc2d2  release/kernels/slotform.sv-hosted.log
6863824807dfd8f8fd1c01ea06bf9b6105ba887b9c8429a38de6a9619e09bf07  release/kernels/spinwait.by_instr.json.gz
2a7199c7319e1bf32518b9a1d4d693d9bf80f9b11426b9ad57f71208e0ad1ecc  release/kernels/spinwait.by_unit.json.gz
53849dec78b50d586a2288aaf2ef2ffb67a257378360d999d4c232b28e82f6f6  release/kernels/spinwait.ccvtrace
8d3652268d57c2271d123b624776b39324da31b60105e535697010208b817621  release/kernels/spinwait.log
868920637236c878b33779bd450439466fc3626996a3164573dc11d437d5c709  release/kernels/spinwait.oracle.jsonl
80323bfa2f07386ea259ea88fe8ed76008149fa6341c8c1b016ef3e4f51be975  release/kernels/spinwait.sv-hosted.log
981465db4539d18f6d2d3de7ea63ca6c2910f103a9a2421893475b38b28ae162  release/kernels/spmbank.by_instr.json.gz
abf5fa38ebad5d7bbfb18f6061bb2e674e7722680c01aec67ad3a46f3631f482  release/kernels/spmbank.by_unit.json.gz
c9e0541d73a86ace0be2c7140b58c219c67cdc59ea3c535408d630297cbaaec6  release/kernels/spmbank.ccvtrace
a66f475f71f5c7aa9c8a0a25c874ca0a4390dba339ac7b6003231ace9d59648b  release/kernels/spmbank.log
3af490cc37d7a92dbe719b57de216b648536eb301ff9d13de9a39f50d150d725  release/kernels/spmbank.oracle.jsonl
79d3429cb55c2fe9cbdb4915a6b34cbd32c8c1fb27e55d9eab478f32b3199fbd  release/kernels/spmbank.sv-hosted.log
c6771eb05965a3ed4281cdbf555d44a2a09a377a38edf70d1888a68d8f1d3370  release/kernels/srd.by_instr.json.gz
d7aa270c7895c0668c6ab2193cfbd182c0b825f3e566d81cab87f5e4df5b4b4d  release/kernels/srd.by_unit.json.gz
d238546574b90fbe0c75cbf57797cc2895661a7fe80c064873a7564e05062e66  release/kernels/srd.ccvtrace
89c8f5142b0c34bdcd0a71da949a3f57cd4e28467f94681cb18c9238b748c18a  release/kernels/srd.log
b08eb5e3673cac7eebb8b72af5ed3783c8e70a9e96592e76bf3722551bc79473  release/kernels/srd.oracle.jsonl
c299b6d9d24945eb5bf7c387c50a010047ec98833fb9d426ff7c7ceaea75f484  release/kernels/srd.sv-hosted.log
d200009eef9c943d170c313bc3368a84df3aefbdf0f827f0b6f9715005d7a055  release/kernels/stall.by_instr.json.gz
021405c4fd0d8829751a528fc41245e3d68d33328a2cc5e3af7d7222af6c961c  release/kernels/stall.by_unit.json.gz
c494990d95781e403a11dc1615b4fa16f41b87795a16a0a4511cb9f71ed8d417  release/kernels/stall.ccvtrace
1f5d43b7e1f79e4a2eb940536cf925856ffc7618ab0bd61d2acaafc0ab687656  release/kernels/stall.log
500db2c482b07a0706583422cd68878301d0146c1f872ccc1f11bfdcf5c993ef  release/kernels/stall.oracle.jsonl
f62f4f972035bc4abb6e5ef4ba66a14eb2c6161f4115d676f6a81344b137c4bd  release/kernels/stall.sv-hosted.log
6acdb7c8309993c5d7e365e1295897cd6eb5f6712852e17ea58f03ee0b8fa38a  release/kernels/swap.by_instr.json.gz
aa59f931ad2d29ab912899f23b2479b593c861bc689519267dc0c7755b8baee7  release/kernels/swap.by_unit.json.gz
7b0725bde43732d26a656be638f86d7ce1448c757594b8e6778537db9652fbb2  release/kernels/swap.ccvtrace
f2dd52f402accdc6eb6074e0cbb4686f0750c8aa0561845478a1d293e04bf771  release/kernels/swap.log
3658a26316c1ff7bc1744304a42f736e930fcde2865c8913e6cc67a22ce96667  release/kernels/swap.oracle.jsonl
3450ba444b6600be54d88282ca1e6d339ad6709bb8af2cbf2224bb6dd50ff5d7  release/kernels/swap.sv-hosted.log
50bbb978b51088017fe4d38489cf70d92f778379ae97af4ffb42ec725c4ec716  release/kernels/transp4.by_instr.json.gz
d01a1b5a2bae362e22e56a8417c618f743334bfa5a7b2ff4e746138c7203c045  release/kernels/transp4.by_unit.json.gz
e40f8be7172257f616cebe3a609bffa593ac8431dee2b99a7c84766f8e5a972d  release/kernels/transp4.ccvtrace
73ea8a0f480182a48d096ee7b4c317d63855481bc6c6f1d79d352401f50d207e  release/kernels/transp4.log
06396ace3ac19677fd39c700e408606e5bdbacb24997d663bbe8872e63dd74fc  release/kernels/transp4.oracle.jsonl
b373c6e3986a246528aa90aa18f92dee0d9fec06ce9105c42ef4dd8eaef3f83c  release/kernels/transp4.sv-hosted.log
8b5e88b672c9b367b5452d417735a5a51ec516162c8d16066cfb7807422ca8c2  release/kernels/unal.by_instr.json.gz
c68dca027dd4a1b6fb733d34552169ccf205fd0ab81463c970b0b73779eafb0f  release/kernels/unal.by_unit.json.gz
bed38c6948932e9ef926b367d9a71e3ecb42820fe2788472e967e21137d660fc  release/kernels/unal.ccvtrace
161076313e8349e16e301a7c9e45697e4ffcc63d4d08951e6fe7293ee23d93d1  release/kernels/unal.log
c3d484bb160657a563df983d9a2532eac27f556636617960aa1e72183ac2b299  release/kernels/unal.oracle.jsonl
0ddc3a1863577255e2c9dac4f05fc2b4a399892991631fc95f7ca5045281da6e  release/kernels/unal.sv-hosted.log
582a76bab445ea68def5e26a1671b3fc70d84c24ca07c247c793aa35480ec909  release/kernels/vadd.by_instr.json.gz
7414a1c92c005af27959d443ee750ce2d42303e36b932ca546921d3971d4cfb9  release/kernels/vadd.by_unit.json.gz
acd26d8cf606915a4436044898763e8bd6715e04c919701e0f0e0c5581e62ef6  release/kernels/vadd.ccvtrace
ba5c3b9f995672a46990551bd82a46011b185b8a6e770e3ba827527ed5537f2d  release/kernels/vadd.log
0276b6d0611a4bbcdc004ab3987214aea138245bc7217504147331689a9c0880  release/kernels/vadd.oracle.jsonl
bbfb87eccb792034ec48137da21d7fa37a5f3570a2fdd1a169dc2a7531ba350a  release/kernels/vadd.sv-hosted.log
58650a86badf5af1e7caf9da37c3bdd8c011da25b0956260196a455f03a3773f  release/kernels/vadd4.by_instr.json.gz
1381b186561497d9201f79cedf6e5baad2750a88225003859abf2a0e45034625  release/kernels/vadd4.by_unit.json.gz
71dcc94b28fbfd36359cec958483c6e4fbfd49ec8cd6a13ae3ec523942286ed9  release/kernels/vadd4.ccvtrace
31dc582f537964edd909c7c8f05a554197020763f999fe559b86fcb5cd89cb55  release/kernels/vadd4.log
225aa18fc9f38aa9ad615aa11de254337d59fa705877553d873062c68366e0db  release/kernels/vadd4.oracle.jsonl
3de1d3ab87bcb536f419c6ee06babc397b60d1eb0a3437a9868833207f9d5bfe  release/kernels/vadd4.sv-hosted.log
e81214fee62550d4ae81f1bb141cd9d5b2f0e87f5c7de59e8f712672778c3db4  release/kernels/vaddslow.by_instr.json.gz
1482c39e1daa4e608c05084ed88b747b7444bdc7684d8e6ad379df72ca521105  release/kernels/vaddslow.by_unit.json.gz
f2b68db0cbdfc905931b8b63047e9e17f76d5ab8e3de1afbcdc92b6394869340  release/kernels/vaddslow.ccvtrace
bf2d1b51f20523d35d8eb8689f1b31f81542d42eb4d7c661256e9ef73e5bca02  release/kernels/vaddslow.log
e9e6218e8b8450e9f9ff6b39d659c994a1e51c527a0c5bd10d18b5658ae0e344  release/kernels/vaddslow.oracle.jsonl
271f3963600706541dc7a2b12ad56f6af4296ba46a19f40a738b47cd5e94b87c  release/kernels/vaddslow.sv-hosted.log
706dc2f2f9a0d7efd57a8a43c1e41a39ea3f6d50a9f5db68c2a851067333636f  release/verify.log
56b3d8627d79d397ca06dfb57060015391cb95e52e925d1f09a4b2a7f4147127  release/wiring.txt
```
