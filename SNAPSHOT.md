# Snapshot snapshot-2026-11-13-0bc9897

**A generated, read-only snapshot. Do not edit or merge it.** The source
is `ccr-9eb50716-lecnjf` at `0bc98973cacea326e1743552c57c691cc628332e`, and this branch is rebuilt from source by
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
| Source | `ccr-9eb50716-lecnjf` @ `0bc98973cacea326e1743552c57c691cc628332e` |
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
7e98d2af2f30b65a18af859d31274603bc48f2689ec9259ddf248c9b909bafac  release/kernels/addrhigh.by_instr.json.gz
3ccfd754bcdcb846ce844a43800b6ea64d03167a4766d9b35db1de5305311fdc  release/kernels/addrhigh.by_unit.json.gz
7f4025bfdc4a9e67d17c349cc2031239027d3a614a0080c15e41212d388f6c80  release/kernels/addrhigh.ccvtrace
27240e2037e268e0eb06b1d826d900fa924c27faf55adf36860aeb04bdc1cea0  release/kernels/addrhigh.log
569f2e22883fad5f0956c57ec734e6afbdd4b8a854e50277425172d6c0cbd766  release/kernels/addrhigh.oracle.jsonl
bc743f9017abee09bfe364fb33e822a0b3cce295c9fb814c165c1106480f2f0d  release/kernels/addrhigh.sv-hosted.log
7ff7a6bd65a25659a8a1b815d8504fb8b139b110df665a4bbe86e8b5816d6d4f  release/kernels/addrlimit.by_instr.json
ec825e1aa533db01d6778b4cedc3d0b6d2a4485af86d802037be182be141b2f7  release/kernels/addrlimit.by_unit.json
2415076357c13d532727f342d8d78f9769f3996b44e4d63253d5779fe61d8f1b  release/kernels/addrlimit.ccvtrace
9cf9efd6482b990e089b34bf8b39a7821f8f46d28f9c16a407bb8daf6339f60d  release/kernels/addrlimit.log
bc660b0b40359a2c5a2478cb0eb4950b73fd22db50ea76b80052bc195a1920f4  release/kernels/addrlimit.oracle.jsonl
ea24607e73c7c469247713324189d9fa12f379c4878c0a0a25eec57783a037e4  release/kernels/addrlimit.sv-hosted.log
99ca7dcfacf2ebfc39fe2d3c7e3168d75bba13443bc769835dd303eb097904c8  release/kernels/addrneg.by_instr.json
2757a55ed6523961f52b4d7721719c43976041c291cfd2e87b8d126e26facf27  release/kernels/addrneg.by_unit.json
f4503455b47d08c163665f4af4b035f48f142c804c82e0b56a2e7e02d6712ca8  release/kernels/addrneg.ccvtrace
1e13c092179509033a5cd30bff752dd977913c9cec73d53baf24c1ed303149c9  release/kernels/addrneg.log
16f5b0707ae44492a1efd67bb9dd38a7e79a7bbd354fa9207b9e7d150ff2f107  release/kernels/addrneg.oracle.jsonl
0c94173ffe666703103071a1c6b6959c882d272b8e9d751b7d3f5d598ee46d38  release/kernels/addrneg.sv-hosted.log
c96059489eb5fb3621deab1749b02dfd517ddeaf6ea80ecac5ec3c401647ab18  release/kernels/atom.by_instr.json.gz
fa81802b029b4f3b2a0a1e1003404ef2cefb082c1eaa135f1290fd7cd3a04fb7  release/kernels/atom.by_unit.json.gz
0bc740f47ce8f01033071f6055bec13f279a8d85482563042171f4c1dcde13c5  release/kernels/atom.ccvtrace
2bba398ae8c90e1b42560318118d1b69e92904b17fe91cdc57cfeaffcb0f6ee0  release/kernels/atom.log
504f5b6e9d25114dc35f2c70b21bb7b3f3c508c691de12dc0e87d12a74285361  release/kernels/atom.oracle.jsonl
5b59829a4d62d61c9bce8ce62517f05e65b6ad9d164b42d237e3f52b3a5dd399  release/kernels/atom.sv-hosted.log
ed28dd8ba3299cfb7283414efe7b8d74f7be9bcbfda25f4f251102459788bb10  release/kernels/atomf.by_instr.json.gz
4ee23f58bbba75925184498e2b95ddfa706ca3b77913ad158259d48e18dc4287  release/kernels/atomf.by_unit.json.gz
26531d45406dfa3872adce367e3f24b1c4b4e71c50dddad8d89173d4301de9b9  release/kernels/atomf.ccvtrace
977980468bb913164283628fa958797c01953312a70ecb48024fea550c7191a0  release/kernels/atomf.log
cfd1179edf4061a33ab2f75d7a6dec61decfe629000198189a7bfc2647b34238  release/kernels/atomf.oracle.jsonl
cac2eac3ea19dd6ae638c9a8f17c397f698400ef0e63bc4bcf7034b267d21087  release/kernels/atomf.sv-hosted.log
b498de03274b64c7d7f67dd57b2c6eda7e0d27f75d9e9fe92ca897d4748b99bc  release/kernels/borrow.by_instr.json.gz
768c0b9823cb20521dbcbcfc5328d2e60fcf5c41500f89f355ca8faf1e3ff9e8  release/kernels/borrow.by_unit.json.gz
f47ba0ff76f39020aec6e50deb887c83af18cb9efde597aa3d2ebc7261eb3139  release/kernels/borrow.ccvtrace
4786fdc81633a7e164dbd794685e0d722bd11c6cc913ab97d20ceefe74c70f87  release/kernels/borrow.log
4c565e1ce0b3baee36e158694b32c8defb5cd662b2f9af75cb5d8c26cb1168ed  release/kernels/borrow.oracle.jsonl
7fa3efbf4a39624edcb777109e3d9ac22d653a118da5508cddd46361a5a9729b  release/kernels/borrow.sv-hosted.log
f7a04f97ad458ace01419bf3716f4e41d92f4b7ae42d5909d2ef3bce18d07ef3  release/kernels/brs.by_instr.json.gz
9f98add0877042782dac71a9150affd5e84a3a93c90c3dc6269b674d227a9342  release/kernels/brs.by_unit.json.gz
0efbd34762b9bb839d84507973259b9161e0b6b94498eb217ab8eb280dacf7b3  release/kernels/brs.ccvtrace
a19bd76fb1181d09b31c61f7135684ff2af7747979e2a8760d8281eefcb55323  release/kernels/brs.log
e3c1cb3379580cf1aae44e8ddc8e846ef6fd661a573cfe0a8d4444b18a14dc56  release/kernels/brs.oracle.jsonl
67e66ad66b37b20337f77688037bf61728bc3b8a9a9308643bbbc80ab62530d1  release/kernels/brs.sv-hosted.log
83c5968a624d5f080d3908e08b7bfd2f8a05072319aa64c5f5939b71babd3be7  release/kernels/byp.by_instr.json.gz
bc4c7b6c88347a09af8e7603f4d83190da3f6e5823dc2d2876e498d61a8377c0  release/kernels/byp.by_unit.json.gz
86ca4cee698bf94b1548f3b1c9acbdec7c36a7e3888421f2fae3bd0627791e2d  release/kernels/byp.ccvtrace
b8467b758102880af68fda8812b0ff4d28f5a0384fba734ed5dd2de4e8433771  release/kernels/byp.log
5a03dfa4f3603fef49f1e3639e74e34152ca3ca5ef8e41eb959f8323040fa2d5  release/kernels/byp.oracle.jsonl
5be2ac58a7bd004dde8f1f4f41be8db326b72d94967afc707357956925376357  release/kernels/byp.sv-hosted.log
6fa6a095152e91f5a3c23c0441e4ec45d6796d13573d3ed570c3b325cdd40061  release/kernels/callret.by_instr.json.gz
1b1abe90f3e2a17ff278d64cacbc234eb005b71021b19772f45ffb6b3d5549ce  release/kernels/callret.by_unit.json.gz
b7b7eeb3e6d53aa18dca668f0bd9f2a6a499f69105bd8e0b4f645473e8e03fc4  release/kernels/callret.ccvtrace
a9a9771e1f6004b107c82c5d53e813b95b0bb95146a88e0c7e50cc8d715a0a49  release/kernels/callret.log
9b1d1b50b527f732362f837250aa2f26dabf3e76e16a4794856ebd8f105635b8  release/kernels/callret.oracle.jsonl
b332d5dcc6fb9f911b91282a6203e32056b69061f133647640fd0759bce58936  release/kernels/callret.sv-hosted.log
3589587ab7a061c8aa3ae13f1c10e18a55096488fcb78d1f206e34709cd5043b  release/kernels/cas.by_instr.json.gz
312deed3f8f00d661dde03448e7f07c7687912f06686ff70df9b94da6c6f67be  release/kernels/cas.by_unit.json.gz
5877d648cbd8cd3344bbeb0cdc1aab3baf484763a7027f4a0402a924a8efc846  release/kernels/cas.ccvtrace
f9ed36c4ac7797a4635793f89c44910f7f2b63a9a3d491e6a03cee8459a5d051  release/kernels/cas.log
0ab31a9443336fe5d08e1a5fa5fcba3bc279b19022f7c5007908d39d8ef39536  release/kernels/cas.oracle.jsonl
a096fbe4ad4cce6a2ff168681e50913ff02701813655b72e7e67c2896415db50  release/kernels/cas.sv-hosted.log
d3c93a62cd09dc6743044bfd03c83bc8e9c92cbf036cfc6bac82b3d13386e8b3  release/kernels/chains.by_instr.json.gz
b730e325f0442f90040ac613bd53554d3d96e66493739559df086c576997c254  release/kernels/chains.by_unit.json.gz
b47e10902de830c337bf591bfc2daf06098880741b67957d8e8dd9c45208dc56  release/kernels/chains.ccvtrace
17038086c82eede07c9b11c8984a145cc6c6151e5280902f9ade357e56901816  release/kernels/chains.log
26a4cc5c5524c7219d8706c2582c80357dea60be9d6ffdec99dac7d0365e2264  release/kernels/chains.oracle.jsonl
7003d98da6d091f3a482aaed299eb414113f1e61a70cba21c6ddc7d5a2999c08  release/kernels/chains.sv-hosted.log
ff7d98c57ccbb292bf24869b5eee9cc08c1fc7cccc2b233f201905a0e850dabe  release/kernels/coll.by_instr.json.gz
4ff4274125ef71e93d8f7ee8bc0c235f5dd5bbf38bdefdc497ced2abee34b820  release/kernels/coll.by_unit.json.gz
9b2defbca3a81f102a07f1fb1a9473253e58da6ab1e7375a8d81f4d1fe098bae  release/kernels/coll.ccvtrace
0e6a0ad8c11fde3f73a7a9336deff59f1c647ac0a8c0c4f3664f642d2aade93b  release/kernels/coll.log
dd718d23c88df5dc7d92b055d8542865aa0e029118486af127312a8a578cfcbc  release/kernels/coll.oracle.jsonl
b35897a57ca42a4c6b825c8474d1e1e8ecc5455b57e6d783e3bd8f593158f8c4  release/kernels/coll.sv-hosted.log
4b0332d6bbb0063b573585e4a1b2d9f368b3961dc667c693bbcc992ee44a55e6  release/kernels/div.by_instr.json.gz
6067144112522e91e0edde959571800345756cd02bc60ed5ef4f96a5e7e3fcf6  release/kernels/div.by_unit.json.gz
182346c5baad147767effbea67248ccbc6e5c35582f0590ab266ce10e6e9dbc8  release/kernels/div.ccvtrace
a4462adfc79ec3d45f8b1110d29ba7ec90563d91eaa481c4e653ace4e5b06acf  release/kernels/div.log
71a567b85cf85622631490187563de9a5661099c78a590adff4ed0a0c3d24c16  release/kernels/div.oracle.jsonl
145628a74fa7d2b26c12f09ebc90eebf5e9a265065300a5630e33ca38f9d6063  release/kernels/div.sv-hosted.log
a10687e26342fbc02c37087ba5cd6bc53cd1bed280382f58ec3e454037198ed3  release/kernels/divchw.by_instr.json.gz
cf9105d5cd44a68c6715070aeef447c482930790ddc97f8187586d9966565f24  release/kernels/divchw.by_unit.json.gz
4471a48e9f9555ec3ff526316b30290fb0ff75d28588185a2a52382020681eb5  release/kernels/divchw.ccvtrace
ec3288779cf35de1931359664969c8760225430b8998588f3fec4f283399689a  release/kernels/divchw.log
58a541797f7a2df0a1c7528ae6a3edec212db90c7d3eb20656806f38b5c10b3d  release/kernels/divchw.oracle.jsonl
7bb13b7d3114747cd665387848b70c1b4ef597229d08da0e42b5561a1c624bb4  release/kernels/divchw.sv-hosted.log
4dee3bb5e89b1068828b59ce5e9ea89b8e96d9c5560c8a570f703b092f2a1ae3  release/kernels/divtail.by_instr.json.gz
dd917c9d20d06346ca4e5462fbc1cc9f47bb4a70948dae2adfa53543cfbc2610  release/kernels/divtail.by_unit.json.gz
2ade202d8c5fc071687f18239b0573f55461d1606452ff6daa16db3738442f2c  release/kernels/divtail.ccvtrace
efcbc091c0052371a944535e887d9d2eaf262e919351fb7cd64cd12abceab439  release/kernels/divtail.log
75f11a75c9b3b336e446140af4579f05b46c363a76b7aab3ec88154a07ba097d  release/kernels/divtail.oracle.jsonl
1ed8f1b3e42f951a6eb26b77caba4d6d60af12050a419eab07b9d6c7689ee8a9  release/kernels/divtail.sv-hosted.log
bfa21e7f0731ef2ffbe8f8466720341a5172183601a067ac96014730b8f78b5d  release/kernels/divtail2.by_instr.json.gz
b57dab485e365f015557e6e149fca2a687901338a8be60147748b95fba3abf32  release/kernels/divtail2.by_unit.json.gz
e27413844716e2c50ee7f69833576c60a6fb7bc226660dfe365677c387affdcd  release/kernels/divtail2.ccvtrace
e79718018ddc531b9d42364bf06628a117dab83f08c2920bf4e7cec446b5720a  release/kernels/divtail2.log
b2db6b05eb6cf4a0a7677e31d0c6c2952d5cab49d353f0bb1883fe0b2a20ed14  release/kernels/divtail2.oracle.jsonl
32891bdcf957b32f81ebc4ac567713d876afd44460e3bff864f2d86584beda5e  release/kernels/divtail2.sv-hosted.log
7ed7898e468f05a58ee4a868919f8464ca5a672cbb98c6e9d739843a64cc4af3  release/kernels/fence.by_instr.json
58126d1147335ffcf760fcbcde86900190c381edefe5830d6c6eda1b0e7d544c  release/kernels/fence.by_unit.json.gz
902d571234711aa609de8947a424a60e599755724ff6b2bf6bdf1550cf10ecf6  release/kernels/fence.ccvtrace
4fb3b513ac3706d718bee29502d215d5d252a9bfc51e742dc47431201dea0f46  release/kernels/fence.log
d1d40317f6cf5bfb430cda1f9c0ef676609e59cabe2a11623c42ffbeca93142b  release/kernels/fence.oracle.jsonl
aa9f588ec61891d38553db480b310948d473d736e7c24c833b3332928d5d697c  release/kernels/fence.sv-hosted.log
b6ffd39081ffc597f263c4701ee325b2e1f67b747439460a32173acca54cb5bb  release/kernels/gather.by_instr.json.gz
780c35ad4e6d0069ed1950dcdd503710cb28170bb743072b8aeb41686596c21c  release/kernels/gather.by_unit.json.gz
7dd36b5debb059b7451787301e7c983159b9833d498fbce4faad199f81b1b646  release/kernels/gather.ccvtrace
cbbc4f6a6bf97866fcf81716b84784fa871072dee24aefb6cae938ca5f85b607  release/kernels/gather.log
0413e781d8d6ff578c64eb1f800b7931e66f676d5cdabb97b94a4033e6037662  release/kernels/gather.oracle.jsonl
2df76f46e1775dc3ed8b92a2860b34861f2ccc01ab4b35c87a89ffdb130dad8e  release/kernels/gather.sv-hosted.log
1034d942a2a413c1cb7b17bd6e44b23d492f63ea7a1171c59243c8781374a780  release/kernels/hit.by_instr.json.gz
fa3aaaf4c84922ef1d79321e7eda93599438ab302567cbe808b515fe545faffc  release/kernels/hit.by_unit.json.gz
893ff785c670decbe42a7f52b662717eafc73000532b6104f2b6de421c0005f4  release/kernels/hit.ccvtrace
4d2023614dc4afb7fe24088c5e6b47191985a47b92d1c5604aaa5d6a5c1307f0  release/kernels/hit.log
7ba9603e0088d9164de6528f16ef6a7fa9ce5821c8c12b52cbb3734e39b9fd52  release/kernels/hit.oracle.jsonl
b6d48c740b4365c9573d600e11150d5c7bd184a452481d95c3fdb02aaf78dafb  release/kernels/hit.sv-hosted.log
d814bdb043b91d5876f02895483e03ff31e7dd5334eeba8032e1d0f9831427b9  release/kernels/lanectx.by_instr.json.gz
ddaf319ce10b74eab690bf73650aac11038d6fc246cd90dc296db83f4561f28b  release/kernels/lanectx.by_unit.json.gz
04cb909321122accc72a84a88ce06c11e76a20160502594b50a562bafe82b1a5  release/kernels/lanectx.ccvtrace
17303dfed26ab81c0d23a0ff6c0b705da05bb945b8b9a6da5f596f859bfe75db  release/kernels/lanectx.log
888551babf540db8e3025b82e65ca655013f93eba3c8a65689d069d52a7e6039  release/kernels/lanectx.oracle.jsonl
8db94bd3ffe233132b1ce2c36bed5a882dba41d54e1004e289d8a7175ff3daae  release/kernels/lanectx.sv-hosted.log
e9744579bd66ad989d611d7b9d9d6dd6486e7619b053a97e981b0f3e2448680b  release/kernels/lanectx2.by_instr.json.gz
bb2bc5c9002a8c1e734856f7c549a81be4bd6138df4604de13527458cb6e36d5  release/kernels/lanectx2.by_unit.json.gz
ef023c0267cd5d07b71c47b7a7879f569ee3c013aa6d0e14a776bf7dd08e305f  release/kernels/lanectx2.ccvtrace
d95a004ae6acdbea5426d50f16a989bf99ccb1649efa633146852636840067c3  release/kernels/lanectx2.log
45c13056dff5c73ed0c9ece56cc36f929bf335322193c7d5eb38710b1d1dfb02  release/kernels/lanectx2.oracle.jsonl
f035ae85d6bfa95233b8938275b231f7d08cca99a4499d086d48fef736f90a3c  release/kernels/lanectx2.sv-hosted.log
fd30badd922b154a7f4513ad2d1f6e7233adc25e49f5b954717f99ff25432007  release/kernels/late.by_instr.json.gz
081163061c7a51fddd204c5e4a26831e60fb6a9bc9e3cc9e9550805a49245b67  release/kernels/late.by_unit.json.gz
4d01e4f710094f92535e5bdf98d039b53e0279d85297e3891c30c9a918042525  release/kernels/late.ccvtrace
1a1bcf07749573fe53943ff499b7d89c2cea909e9f08760c8f28079ee89fdf8e  release/kernels/late.log
86084f6bd747a2cf32acbc0ebd96ebd3e4ef2d8d9e21be49e3ae49290d7927f3  release/kernels/late.oracle.jsonl
22e982f5265e4d6b9bf5192ae7eccf63baab2280756e6aefc42b764abda9bc74  release/kernels/late.sv-hosted.log
8b6d7817d307ed1dcdd9c17cf3ce56edeb2b7604b4b0638136fadd59b94dadf4  release/kernels/ldpar.by_instr.json.gz
4264ccf76d4c8de15ceb1edd2b7302a673b83e4ab9904e019907570a73e92b60  release/kernels/ldpar.by_unit.json.gz
e1a8cb1b4392a870125afce5c147babd4adb301aca13ea213a6b9f40bd246472  release/kernels/ldpar.ccvtrace
05abd79fe8e3c055712ee8af3438b645e63c18a60f3b23d6f729c23599cb8ef3  release/kernels/ldpar.log
8ac08538e9c807637babd61b31e340f7461878ada31f0c0b83cd66331cfaf486  release/kernels/ldpar.oracle.jsonl
cbcb225c1cad701806c92b3d695bdc7ada6cd0ce14087083adea0a46a5247d4a  release/kernels/ldpar.sv-hosted.log
9581c51ac5a930db3bfbb8d0a41d943cddfd4ed7c698b831b54ed06b3d2e691b  release/kernels/lnorm1.by_instr.json.gz
4b5d0761f8eb7e1756d633248c1decc4b3c71fc29d66b51a4a5e322740f419be  release/kernels/lnorm1.by_unit.json.gz
efb3db304100f3fb99fc9ef199e8c8c51f704b777b3235b0821e11432d79f628  release/kernels/lnorm1.ccvtrace
0ba51447e579ab5edf752c2a1092e7f9df4324c6ab72379065f9ce3eb4a3fa73  release/kernels/lnorm1.log
a8d85811af988a1b9fc00db1517300af3d93ec8e589e403d3b9113fa9e0ffc86  release/kernels/lnorm1.oracle.jsonl
46677d2b9214ca6e63cbbc7e8a3062c9797fc5b6d9e48d0dc24a96ebe941ab5e  release/kernels/lnorm1.sv-hosted.log
0f109dee22fce93d910c31b71f30aecd79e9357875b35efd8e654fac4e96e523  release/kernels/localsp.by_instr.json.gz
e38cf25a275e55a13a41af77881567c53c5929cff3d6c6578939da064766b512  release/kernels/localsp.by_unit.json.gz
d1f65404e6fa7aec7e975bd27f5d846267aae0c74d0e1a60346d2df8cc2b3b3a  release/kernels/localsp.ccvtrace
145d81b566740c3c48acc4ea417a5518b0a1a2d2e91771f1c7ec8704bdf8afa3  release/kernels/localsp.log
55e3c9f36e7f7d38c0ddd38903aff4bb4509ae862015c592e6b937ea258042ca  release/kernels/localsp.oracle.jsonl
06b1230292b53e6c189d93c11576f927d35d0e8f7942e81a6f4b0f476e4802e3  release/kernels/localsp.sv-hosted.log
a21222b9380d977dda4127b796997788ef5872984402d401e18d83e6e5deba60  release/kernels/loop.by_instr.json.gz
d6a3a9db3790d19017a8b40b37c1dc9b64f129c63a54de0437e7459f7507db21  release/kernels/loop.by_unit.json.gz
05599f989c0d60da6bbedde81701aa56ae1c2a56bbb878bbddeca9829b14e167  release/kernels/loop.ccvtrace
95577315961e0d18064c954d82b7100f3a7dc26da98851d7725e0d4e2339200b  release/kernels/loop.log
03ce5920c06c93e93516d8e53c3f7169f14e3593de204eacceffc0b8a3e32016  release/kernels/loop.oracle.jsonl
c2080f127d34f9ae7a0c762ba0d272d7ba91503c7161c17d95a434766bcf39fa  release/kernels/loop.sv-hosted.log
792e2018f3ee3a0427fefd8cb6343f54ff836dfbdc6f7181ed6852445518cd7a  release/kernels/merge.by_instr.json.gz
03828f9ac7ed32a817eed832fefcca092a0ee82acea716c9f176721d8ea99501  release/kernels/merge.by_unit.json.gz
2f43408ff2d9fff8512adaa9e24aae50158636b35dd1778e07d3a003df283170  release/kernels/merge.ccvtrace
0c4e8c75c740e2d3583b6a3b1ccdf9df16fd6d1a9ae859b2d93b269eb7124d12  release/kernels/merge.log
f96d28815f8756b1f5a45ded53e6170883d2dfa10f9eef0d14b8050b1318164a  release/kernels/merge.oracle.jsonl
7de42fe7e318cdc04213672602648451f28c6c92c9df907da2a895f6ad4e5d69  release/kernels/merge.sv-hosted.log
a4fd69da13c0d6737f3c6dd0e246dde5a9ddf7c214e0888e24b1d0a6bce74b44  release/kernels/missrun.by_instr.json.gz
af31004d95cc2ec8bc077d3b8b0efc0af0164d7c04ef903bb080cbf4f4ff1b9c  release/kernels/missrun.by_unit.json.gz
904f65ed8087afef70b94611476fe70013468834790cc80993d641d175678d82  release/kernels/missrun.ccvtrace
b21f82b9228e087a7f62888d2b9999a9bbfd07c22e9c7d68743ff4bf90c4cb1a  release/kernels/missrun.log
531bdaf281e5590774bd2775427f25e4cc0419cf8e3d5b6999843ffe9ef87258  release/kernels/missrun.oracle.jsonl
f14caade0466d9f6881c9e420ceafe80dda7bf4862c86f1d168d840dbcfe1dbd  release/kernels/missrun.sv-hosted.log
3666315bd211a9d43e0d46679140f1aa32b2547ec712e5dae9c3c399e1a02150  release/kernels/mload.by_instr.json.gz
9c5d6076e018c7c54fe6ffd55bac24ac8ca68397bd4fe4ba44f394e221b75481  release/kernels/mload.by_unit.json.gz
76b553be6382705b8a38e14f10567c4c54c80edce392f55edf4aad513b4ff522  release/kernels/mload.ccvtrace
dc12e5fe4a8f4275055cdb173d4f205468f5c79c05fb0e2df3f8d185b3f86229  release/kernels/mload.log
8000e477b9a95dfb9f0af964e8346acb9d36f1358fd06ffc4ff7cf599d2b8868  release/kernels/mload.oracle.jsonl
dbe15571e982b34c05a8b2100e594d75b4966aee0a7ab62e83cf8b6b7eb373e7  release/kernels/mload.sv-hosted.log
be588ee6e5b79c64155ea83c5897711665f1012ff50bd1e0c460492fc0f05357  release/kernels/mlp.by_instr.json.gz
a56bcc1705111a9a8f3c8fd3aad87502a8e4ee997361fef663cd2272d47b096e  release/kernels/mlp.by_unit.json.gz
7cd6f5ae5f30dbf86e7e4a4c0a82e6f1bdf6fe471cc6e6e37aef86e03bf88150  release/kernels/mlp.ccvtrace
663e5791fa4a2595c8c2d4dbd78a97c15bdc59d9aa4963acfac6e10ba521927e  release/kernels/mlp.log
138d282f88d56c8ad648a91af0a983254b55d9fa22942c00d47b327f516a6e44  release/kernels/mlp.oracle.jsonl
1a66836ebd6027fc85814863db018f832331488100030ac1f352de6db0a6fd66  release/kernels/mlp.sv-hosted.log
8649e7add72da050c830ad696ef48c8947afc8ebe4c82d0d532381174a447fe6  release/kernels/mwmiss.by_instr.json.gz
eaf68cdf7907a528b68d7e798fefd081e84bc55bb9266683ece1e502104c653e  release/kernels/mwmiss.by_unit.json.gz
f218172f4887742106b54c2b71356b417c6f406c740e78cca232f9d437b3fdc5  release/kernels/mwmiss.ccvtrace
4495e1483809dbd02df4a66cf83a33963ab3438062664aeda37fbc12fcabd5c7  release/kernels/mwmiss.log
8abe8e8997456a2a6711ee72da54d854b24e20abbdab28e4b7271c0d28418de8  release/kernels/mwmiss.oracle.jsonl
6619c5cdefe0488ceb1cff9d94ca8611dcd4d2b314b88d46985965fae9f5a3bf  release/kernels/mwmiss.sv-hosted.log
2cc76d42e1faceae466e8c19d76a12f8075bc54111552452c9db30f08d811195  release/kernels/narrowadd.by_instr.json.gz
66ffc9df19badea6b91547fa9e0689ccd6bd75d95d78b27a42017314d4fd9fae  release/kernels/narrowadd.by_unit.json.gz
15a76c0955f9c35c0f6536d59b6c38e517ded7ea3b74e350d2288ab716482cf9  release/kernels/narrowadd.ccvtrace
2184ff8b5c34a5079d953ec22a0261e335af6fbdbee6a454b89916ff5d62c021  release/kernels/narrowadd.log
40a2cf629853dd404bb06b4a07e35abde3d12efc13f26ffe28f923daf2994574  release/kernels/narrowadd.oracle.jsonl
50db5cd88e660d513d91a593b98ffff5af1b3e5911270397a46872a25402171e  release/kernels/narrowadd.sv-hosted.log
3d8843ef41b4a89f898be520a39e5231f8da9a21189a0bb66cca8b05fcfde532  release/kernels/pguard.by_instr.json.gz
311c25be9d25a7f5c795276af8cb326266059589c1f72f657a2628c4c619822f  release/kernels/pguard.by_unit.json.gz
1be32dfaa56dbde149ff08e78810d1e8adfc2d6b199d31a352930ba7859d0d18  release/kernels/pguard.ccvtrace
d78c48c368ed6b5d4cecb33d8b6bf4a849ddf729870a54f4f11e1932982af933  release/kernels/pguard.log
690e56f1cb8d97cbf67124b7dff3ad0a90cb8981814cd1709cf0cd0e035b3bd9  release/kernels/pguard.oracle.jsonl
8ede42df6ca5305379583b5499894771c5ea703be085742aaff8614e017c9ae1  release/kernels/pguard.sv-hosted.log
a44c2be585ebbbae64d9dc62b910639b1838de19d660c3c1209483e5392f7725  release/kernels/plog.by_instr.json.gz
b3aecf68905bfcfc52f957020af9324119fa181f26b642d7bb36714e68151ced  release/kernels/plog.by_unit.json.gz
ce4aec9a797ce6e24a9082c3c4e22e4cc45d2bd6d9cf47ffadb3e8da5e251eb9  release/kernels/plog.ccvtrace
950e21ab65d30856daf26671cf6bf7ac47b78552e17e8c1aa5c47e83eabc7b94  release/kernels/plog.log
0c99915e2da60f4670da00504a6371d7d17701d4431e733a3ff8fa98a2030d6a  release/kernels/plog.oracle.jsonl
5e2a75115508db9db7034004072e836535ea0244b738b9dd5fde9f21d417227e  release/kernels/plog.sv-hosted.log
ae0337cabf20fdc648cfd5ae2a1e2cc5616afdbdaa94f755cab229bfdab10196  release/kernels/pmovdiv.by_instr.json.gz
06198eafcdedcc1eb10961d550c758e28c66571a59a566f862486b929ccbe540  release/kernels/pmovdiv.by_unit.json.gz
4fe481c67584f36b72d1f510fbace5f75fa34ca8d76713e16d393f8638f099f9  release/kernels/pmovdiv.ccvtrace
165329c19f2cd1b4682252353a170783f76de7b8ccd1edae6e2ba00ee80780db  release/kernels/pmovdiv.log
7bc646cff6166a51bdce03d7c1b7209e871f0a91d743083a9b910a80bcd0b33f  release/kernels/pmovdiv.oracle.jsonl
19cf3b853b9dfb96b5e9968c0926e7875a11ce14f95c8ddbbda9bc1344825ab3  release/kernels/pmovdiv.sv-hosted.log
c4584a7c3e7bb8fd954dbd288bef608530f2a8eaaa0699b3edf69634a8a39e01  release/kernels/predlane.by_instr.json.gz
33afbdd264fbd5d8fc5c523af0240a18d51dc7db514bbe6c560ab8d672646ccb  release/kernels/predlane.by_unit.json.gz
532a8a0c9135721ab0526accc4358e8fdb1ef57c82585686a0c80705acd1e51b  release/kernels/predlane.ccvtrace
8c4a653f5294a203cf3b88e7da6b1eaa04ecd0faf3131afe7551db0e1d10289e  release/kernels/predlane.log
c45f4177b9e84fc8a6e36b13534a0c7636eb30a3f8531847100ce5e23bf404b1  release/kernels/predlane.oracle.jsonl
8b09931571ba3f5b932ef97fc64671f54cdd27e3b0b219bbc681f389b4065962  release/kernels/predlane.sv-hosted.log
687895496d257b695c091246b14b2903f131a6c47056fbbf8aad4f0067fdbe26  release/kernels/predmerge.by_instr.json.gz
7f14bfdd8d588813dba597ea30de67eae7a1433210d064a173e13cef28cbebd6  release/kernels/predmerge.by_unit.json.gz
505403182995d5204046ce387c328ebcdbcf638bf96eeca5047ce00ae556e20c  release/kernels/predmerge.ccvtrace
8f067d385cf0afab6e862f2a895b3405188d7a4cca304332b86c5b7960e58982  release/kernels/predmerge.log
6c737c49434bcd08e3e0814c8b1dbf15c586ae74f7929ba3148ddcee2c62c845  release/kernels/predmerge.oracle.jsonl
17c5e9176425f930f8cb0ff572e641fa3069cdf9d74d25747cbf380f81da90ad  release/kernels/predmerge.sv-hosted.log
72d03477b36c1d49cdcc2750ef05bf14c78e0089ada28e52dee7fbf39a1a55ab  release/kernels/predspill.by_instr.json.gz
9cc8daff6a1fcb992b2e387624d42d43d73f593c75a3fde837cbd0f1da3afcd3  release/kernels/predspill.by_unit.json.gz
99589c2367cfa6d554c451bed32503c586dd1c925cf07763095171cadff9a5d7  release/kernels/predspill.ccvtrace
e96494394e32dba75c3eb8f93ca5fb4743d861a8ef33c5ca4e96f4d2dfce016a  release/kernels/predspill.log
b7c84c6478117ffa0f06da0e6ad1e4628e2683426a7911080810e78e06a5242e  release/kernels/predspill.oracle.jsonl
a348984558ac262def9044da1bad9dd063cd088b169df70b3cab84d2a007410c  release/kernels/predspill.sv-hosted.log
d0399a7f5554d5d4ad60c967c277521f0fcdd619f47a1c2a9e7f75558d943ece  release/kernels/predswap.by_instr.json.gz
c03ce004eb5113944f096864bbd8901762d8a7d08880987812f4ac0971156e32  release/kernels/predswap.by_unit.json.gz
e93b8efd89d74d085e81ca285cc6abdc1d88d9191054f91939a93cd8fb6e173d  release/kernels/predswap.ccvtrace
253ff10981635ad5684e9ef9818f3d383312e940e65cb6477edfc9002b9b5be5  release/kernels/predswap.log
a6d4f7ed517553816d889c7c9eeb6bcfd1f6c973fbf682ecb69f3c2de619f7bb  release/kernels/predswap.oracle.jsonl
6e4b49049ffcd49123fff49ce5cfe7a590894d4f4d89781b6585a217d15a54e5  release/kernels/predswap.sv-hosted.log
87838a35add7b623033f4739447313f5d7804a827ec65f7968b9874b011cc403  release/kernels/privwin.by_instr.json.gz
45c797a1cbb07b98ca703904e2aebd13f58828cd0adff4d9ea68c85f78dbfa3f  release/kernels/privwin.by_unit.json.gz
18e0e4196496316afea8ddb1ebfd35823b55f55b525c74a00da737519767f2c8  release/kernels/privwin.ccvtrace
c5df1f91d99233fca8df94ade4f20dda846e5658fb5fe8897f8a41d60e086b39  release/kernels/privwin.log
861f686fc4480363472908d679d8815e8c957d768e7ab32c826930527b0fb7a8  release/kernels/privwin.oracle.jsonl
d2a26d9c7dc2fc2559cdf2de142a03d81410df1d9222e30d62fb9bb310ac631f  release/kernels/privwin.sv-hosted.log
ac1b56d6083c432672c3cfaa891c43e600b54f222c0ba2fb3e60ca3d6422f35f  release/kernels/provswap.by_instr.json.gz
8bd034cf9688a6c6e48ec2c063132d6e2fe6ab3ce21b70d621e311ee663e32ad  release/kernels/provswap.by_unit.json.gz
5597ac486c6c41c594b8dca2384709e7efa590ee2803188b22be0d922972f27b  release/kernels/provswap.ccvtrace
0ccca9556ddb76b513877830f163d0a225dc04ea17d3832eaffacc29e8ad73a1  release/kernels/provswap.log
c9c32a793d54cc7401477f582487f7e8b345b2669a75337b8d6327120d98e5dc  release/kernels/provswap.oracle.jsonl
30280ace4e707c5350e8a8a89f0d500bdcb270592600a7a13c7e3d008696cb2c  release/kernels/provswap.sv-hosted.log
5d8688ef45c64f6fe0c9d44dda25c75c773ec727170685acf978a73dfa03641b  release/kernels/retmiss.by_instr.json.gz
fa4039348ff63edbaad69d9646c102e0025e436dad009918a6964ec528d72a16  release/kernels/retmiss.by_unit.json.gz
d362264f223295de3b7593ec488c489875eb71f98f1a9eba55148418537fdaa8  release/kernels/retmiss.ccvtrace
745020f73edb3b989781696be4734528346e677e484a36702ed84a5ca2bca571  release/kernels/retmiss.log
e5ef8538e838c6cff7febfc679dd091cf5e002f82d34f1009b1948ce22bc3649  release/kernels/retmiss.oracle.jsonl
fc80fbd2b331cc6a18592852f5954b2c00874c55e66d69789364c55cbf55cae7  release/kernels/retmiss.sv-hosted.log
d45b064f90b496adbbbf3be694a8cc4f6af4ea41825c8bb83b0c4042da5a369a  release/kernels/roconst.by_instr.json
b38b6900712bfd3ada68a6b3627c4ea3fe521aef042fc47dd43dfb23bb1283cf  release/kernels/roconst.by_unit.json
f3713f83ec2f195b035033bdb47cfd76ef95bbcac2a975d18c8e17e3b3ccda49  release/kernels/roconst.ccvtrace
494fc327cd7db4bbda75ead1a960b5cc2c6390a9eb632c53d924434c0ef4f183  release/kernels/roconst.log
8087c0671de620162881aecd38cd6114b78e7be6bd71201e3ec02c9a2e2e750e  release/kernels/roconst.oracle.jsonl
670fe6ba89c8dd50373949ce92592f7c88968f468f4684244738d7c70f7f4b68  release/kernels/roconst.sv-hosted.log
7d213047dc11229803ff907bc5a2192cad3a16f993fe7f5ae66bdd5e6ec74442  release/kernels/rogated.by_instr.json
6e5fea0905ce90fdacc116ffbec2a292fd3a4da76b7c8712e9316ff64c5efdff  release/kernels/rogated.by_unit.json.gz
e0022bd67a6d629144891b56607860fafa98ac1de5fa80dc411be11a44c9a890  release/kernels/rogated.ccvtrace
967b63b0779565534ed14849e12e764c85fa1d5d58327962314628713d519d91  release/kernels/rogated.log
7cd02bd4cceec5a044d6b4d6a80df1e68ed0ae71b0b2a953143636d5b809ea6c  release/kernels/rogated.oracle.jsonl
6677499ae82332214a3160c9d5e49f9931671b55ffe64a11c74680dab604c9cc  release/kernels/rogated.sv-hosted.log
21adb941112799afdb405446a63a2ecd189537bc54ce980664ef42f6c18001e2  release/kernels/rokill.by_instr.json.gz
c49584a48bb715f1baca71cdf42c7029195b1ca5b3cc90f89e341992bfd9d25b  release/kernels/rokill.by_unit.json.gz
cb434c89178bda63feb85c508e8cbd1b00bffd6b69525ab858d2b11b6cf16c17  release/kernels/rokill.ccvtrace
0a224446371827af3aa6e2a2ff7bc3015355c20c5b05026f0fe7d9491095620d  release/kernels/rokill.log
94efcef96af469a512d346ce61623980fe86383188eaebd55120f716db596f14  release/kernels/rokill.oracle.jsonl
8360f5d0ad137691b0270485d70306f21bda8ce3ce6ffafd1b8a5bd908ce86cf  release/kernels/rokill.sv-hosted.log
f8fe604241644b224e6431d16e4fad889c99826b82f49205e4c9014b9ae62e8a  release/kernels/rolaunch.by_instr.json
12e5281971b0a06ca95d953aa22a6d6b481d8fee948f50ab777c87877757fe46  release/kernels/rolaunch.by_unit.json
32fbf77dc8fb17f0113b068b5a00568b6ea97be3ad8e5bd1c69b7cae2f04a946  release/kernels/rolaunch.ccvtrace
815a52d7fef6048024bb21899b0c6bfa2f645b3324c929f7e39485deda041c84  release/kernels/rolaunch.log
e7dad585c3e70615de04330fd03f4f282c29a005dc1732a35655fb261d51139e  release/kernels/rolaunch.oracle.jsonl
d8992e6ed3cbb31e5ea6293a48fb9b445e5670c34b21447a49c4bfe71f43293c  release/kernels/rolaunch.sv-hosted.log
d45b064f90b496adbbbf3be694a8cc4f6af4ea41825c8bb83b0c4042da5a369a  release/kernels/rolimit.by_instr.json
e8822066a61bf10f59647aa7240a3044f25d2eba55ac5f7ebacbf1901974dd8f  release/kernels/rolimit.by_unit.json
0e8db555321feaf0fded659de3d7ab35b3dadb15ccef4bf8dabfaec2e87a5563  release/kernels/rolimit.ccvtrace
e0fe2aef239b29aa5c5a9beab75d32011361fe49e69b6efe59169eed5c4b061c  release/kernels/rolimit.log
1c5bc0cb8e8b2e69505fb5a551a16d5d10c56f232b88da7a27e336ad7d962de2  release/kernels/rolimit.oracle.jsonl
ab0906bcdb35a7a1992f8019bbd4ecca69d555a0d006de5f07609a71e564f372  release/kernels/rolimit.sv-hosted.log
e23f98dba88ba249e3031e7aa8b78fd47d00bfab40fe834aec20e52b75208e72  release/kernels/roload.by_instr.json.gz
043b8ce9e4f20e5f19a308ef357a3d4ae135d50b7342ad367975836a8f5825bf  release/kernels/roload.by_unit.json.gz
e2634c3e7aff20e8ca7e9c8f14599a3f74ea0f42f10d0bcb19fb0f8333fc3eef  release/kernels/roload.ccvtrace
3e8adaeaab7710c41cc0cbee77cd72198bbc26b2d187bf70cbc2f17d635dfc25  release/kernels/roload.log
f7c1309cc9764769fb5803f6fd0f2f5e1eb418f2d23fbe5e17cf5f9106869fdf  release/kernels/roload.oracle.jsonl
1c4f8cacb7cf9b7326e2ed662e118c258eeec6d12e1ce206546783522b14ad9c  release/kernels/roload.sv-hosted.log
8bcc1771ca1cfe4cb7bf386798946cec332270baf5c863ca53c681c10e08120a  release/kernels/rope.by_instr.json.gz
955ce15b20fc291ec11f235f6c51df67d11abf8f8d0e7aa8af76077c70a3c94c  release/kernels/rope.by_unit.json.gz
c40ca40858a13f0528f0d1f946ad3b0ad60d1c6c35bb432ae5f6fa95b49f701f  release/kernels/rope.ccvtrace
bed846f2d8b5551840fdd0d9a83995feb63ea64b60a892f6a2bef1ffa41d0512  release/kernels/rope.log
d55f9efae392dc8877c102c01c0810e7654b666b6ede386328108164c6cf88f3  release/kernels/rope.oracle.jsonl
74c0321d019f720d97627f26d4f8ebd2e1c384aee20106c8f3de868bfeaf5783  release/kernels/rope.sv-hosted.log
13a40ce98fb93473842224803251473753a9fa388a62e535288c6361a796bcde  release/kernels/ropediv.by_instr.json.gz
26b811bcc81e033f5f8bbc4694506ce49c19c18fc547d10dc069ff216ccd2dc5  release/kernels/ropediv.by_unit.json.gz
ab39624cae9f0b150f2bac34676e667c91b8d180c27d5860c8050cf057a4329f  release/kernels/ropediv.ccvtrace
b14725c2f548caa6cb4fdd5b44469f1a7b022967f180f528421f43036d91fcab  release/kernels/ropediv.log
10c0ec6ec18b7b44638c790033109198c079d07c1537bf193353ccedd00a920f  release/kernels/ropediv.oracle.jsonl
c361c05fc6263638ab39f2b7bf5042f696abb920fc1e7524f97175a06399900b  release/kernels/ropediv.sv-hosted.log
311a003ad0395ea74750b49e2cf55b670b7a4a5af9a3696d5767f2c19a1344d3  release/kernels/sel.by_instr.json.gz
f27707abc20930b46155c9bbc47a06c2174205f553c2d8a4e926c8fefc54febd  release/kernels/sel.by_unit.json.gz
bfbdf6055affcc6f1da5e0ca404d70f0e1ba25424943b4357452b1e5ed16df5c  release/kernels/sel.ccvtrace
5020df1161245c5960188582d1d73b4580faaeb7bd6fe2e7900aaddf2d45d8df  release/kernels/sel.log
87f6a81e8afa004c8039bf2f61c90176fcf29ab29bb17ac44aa016a5cc8438fe  release/kernels/sel.oracle.jsonl
1b8c11bf446d736ae16f37649780a2c292964c097d481d221dca16a0b2fde1a4  release/kernels/sel.sv-hosted.log
ea2f9f488a27d6dffdac51e7e7d60f0af3a5b4047ab1866ee868c45e8afd0b20  release/kernels/sized.by_instr.json.gz
db15c5fc66141939ab0c22cab91d7f5c279a328994c9f589e68b83d713300c9f  release/kernels/sized.by_unit.json.gz
7d7b3156291cf98ba08d0d93b5dbbc7f7d1b3bc9b4d7c8cf2ed07ddf408043a5  release/kernels/sized.ccvtrace
63f95636d5d4c0425862898cffb0b89812d2105c0d6bec2db19f6b3468c7237b  release/kernels/sized.log
36d903ba1618bd1faa437c9812a6ee6c0c966a63196c796267d74bf2695ebc3d  release/kernels/sized.oracle.jsonl
786f259e8dd9713a8e8ded3ab6baaf8183fb60369e313870b426ddb174cb66f1  release/kernels/sized.sv-hosted.log
2e8bfc5f1f5483e9938e547b91b88fa05f3b49c81af3dd69decf2344ed5eadb0  release/kernels/slotform.by_instr.json.gz
ca15a03c19c2110520fcfbe4c66ec4d484389b6ba198b1ce800afcf37300bd98  release/kernels/slotform.by_unit.json.gz
bca4999deafabda9e24ba5d6f10ffaa5606d1f7062993e6963b4a14026bb40df  release/kernels/slotform.ccvtrace
84718e471ad018df06bb9ba37dfe861fc4fb53cd4cef7cb0834506505bd5edfe  release/kernels/slotform.log
8b61db7419b18cea8a646fb628218447e72e84a18a9891ffb73b441736138ab9  release/kernels/slotform.oracle.jsonl
bc04e41f844ba0346eae80157a642628085da033ec6c99b8a655f8a0d5bbf41a  release/kernels/slotform.sv-hosted.log
886e9b2fbc30436b2ca558ab781bd916d2980c3dd8b48e0f9755d0dec456a61e  release/kernels/spinwait.by_instr.json.gz
4a3447f5cefb063be39f36b42f63f5bdba226913fd23e050bc9b10b57f546794  release/kernels/spinwait.by_unit.json.gz
53849dec78b50d586a2288aaf2ef2ffb67a257378360d999d4c232b28e82f6f6  release/kernels/spinwait.ccvtrace
65130011661c53771d8073cd3c89a6bb63bb29883971f906c17fc2135184bdd1  release/kernels/spinwait.log
868920637236c878b33779bd450439466fc3626996a3164573dc11d437d5c709  release/kernels/spinwait.oracle.jsonl
03ae3db693ea3ab7d964cca9e4f113d8277abb461a289bf38202fed5f19578cf  release/kernels/spinwait.sv-hosted.log
69845e6b7317902d7d4d0c2470eee00660b9f516bc0589ad34105c7a815dcb6f  release/kernels/spmbank.by_instr.json.gz
0cbddccb1f838cc7eeabccb7189fee5121a161a7a1f1c86f0754111222c41d7d  release/kernels/spmbank.by_unit.json.gz
c9e0541d73a86ace0be2c7140b58c219c67cdc59ea3c535408d630297cbaaec6  release/kernels/spmbank.ccvtrace
4546faaf18deb38edf8b0645a03b1bfb927d2a82fec857f975035486fd49ee91  release/kernels/spmbank.log
3af490cc37d7a92dbe719b57de216b648536eb301ff9d13de9a39f50d150d725  release/kernels/spmbank.oracle.jsonl
1db32afb23f342ea03a6ea16a7db83d5424363fd4d28ddc434894b9f11d40653  release/kernels/spmbank.sv-hosted.log
84ded3f7086f8a77f195b5701268cfd90bfaeed65bd8ef7b2e7203e589657488  release/kernels/srd.by_instr.json.gz
daa61bc9d6b556b693f66712a81490d541414b8d0e8467509710861d198957be  release/kernels/srd.by_unit.json.gz
d238546574b90fbe0c75cbf57797cc2895661a7fe80c064873a7564e05062e66  release/kernels/srd.ccvtrace
e4c2a3098a0a7ac41c6a3c9cf643e1b947dfbeaa12a8a55f779ec0165e9ff8b9  release/kernels/srd.log
b08eb5e3673cac7eebb8b72af5ed3783c8e70a9e96592e76bf3722551bc79473  release/kernels/srd.oracle.jsonl
8359b89d18f117a303b80ea9c88ee8906212ba46ab1d247047b2206ed32a9ed9  release/kernels/srd.sv-hosted.log
0b2ce260767bd4cc9888a00f97e9f928df003b0f2c7b6aedfdfad42bc17c3084  release/kernels/stall.by_instr.json.gz
c23502703f732c03cceed89ef98918c4e5b300e5e27f8e5eb14a1f31f8b6ee5e  release/kernels/stall.by_unit.json.gz
c494990d95781e403a11dc1615b4fa16f41b87795a16a0a4511cb9f71ed8d417  release/kernels/stall.ccvtrace
51d1fc31172956fbbcfa61cac85819c6f71c4214bca5f7bda9358d14809295e1  release/kernels/stall.log
500db2c482b07a0706583422cd68878301d0146c1f872ccc1f11bfdcf5c993ef  release/kernels/stall.oracle.jsonl
c7f0cd39683e9a9e0fb208512201d06b4304b9972b8f6c25aa6f97ad30ccf8fa  release/kernels/stall.sv-hosted.log
9df6af507299044e5131f7a783d7a2f655bc818ef49927373f0ea14fdac24ded  release/kernels/swap.by_instr.json.gz
27dfed27f6731871d9cfd2fb36e85b610d936d8194dab31e664a1be0b6b2b560  release/kernels/swap.by_unit.json.gz
7b0725bde43732d26a656be638f86d7ce1448c757594b8e6778537db9652fbb2  release/kernels/swap.ccvtrace
39aa781f6e8deef7e28a814007e1dbf2ef7fe429494665ab1ec14b27beeeb96b  release/kernels/swap.log
3658a26316c1ff7bc1744304a42f736e930fcde2865c8913e6cc67a22ce96667  release/kernels/swap.oracle.jsonl
ee3ca0882f8df343bb11d4146a0d8b9ba3b3900b85bfd4b17ce9ae918f17d8be  release/kernels/swap.sv-hosted.log
e7282463f74f4eb9df863e65a95703aed3de5d71edee5cfb015fbae68a3fa3d2  release/kernels/transp4.by_instr.json.gz
47c4fe22a611589564a01cfc1b0af2212ed556255b906c5df44f4c047a5bb1af  release/kernels/transp4.by_unit.json.gz
e40f8be7172257f616cebe3a609bffa593ac8431dee2b99a7c84766f8e5a972d  release/kernels/transp4.ccvtrace
e01552b32817b0d63f545b48dd079cc66f0ed0dcc40d1f5e2f8f44c306131244  release/kernels/transp4.log
06396ace3ac19677fd39c700e408606e5bdbacb24997d663bbe8872e63dd74fc  release/kernels/transp4.oracle.jsonl
da4fd0892da3cd84423a2d244789be67b654edd28daf733fc14479b2932c39a0  release/kernels/transp4.sv-hosted.log
939d2715bfa04e12fa0d749baa401e89ef973737fc2bab92ac8b49769d2c621a  release/kernels/unal.by_instr.json.gz
ee185fa3c810a9c35c30dd0b43520acd9cc0a57af7f3246836bced765a178155  release/kernels/unal.by_unit.json.gz
bed38c6948932e9ef926b367d9a71e3ecb42820fe2788472e967e21137d660fc  release/kernels/unal.ccvtrace
77e80513a79f1c7b20a6006c87b3fd770f00670e027195a964383123beb004c5  release/kernels/unal.log
c3d484bb160657a563df983d9a2532eac27f556636617960aa1e72183ac2b299  release/kernels/unal.oracle.jsonl
7adf0134879d4dd7772982568634ce90d08f0210db81ba66aeba4978e04c1e2c  release/kernels/unal.sv-hosted.log
e52733c5a3c3fa0d3fa5a1891a91dd137f76a9611e2f303d11b48cb548e2beed  release/kernels/vadd.by_instr.json.gz
268f644504b8f4a620bced742180fefcac88c732b411c8ae3dbf5d11e4e1a50c  release/kernels/vadd.by_unit.json.gz
acd26d8cf606915a4436044898763e8bd6715e04c919701e0f0e0c5581e62ef6  release/kernels/vadd.ccvtrace
dae5bc48b1509c91e324b4bcb79e9a7c9ce3b348b9d6450fe1a5bcd7f4c47cdc  release/kernels/vadd.log
0276b6d0611a4bbcdc004ab3987214aea138245bc7217504147331689a9c0880  release/kernels/vadd.oracle.jsonl
e5c3ec5248ec4a0517c2257ed64e6e51069bfe2c3578fc1b2d44644a6b545558  release/kernels/vadd.sv-hosted.log
869771b9a279ea1cc9bea291ae7ecd461394fb14608bc4a20c432e1f7ef5f23d  release/kernels/vadd4.by_instr.json.gz
4f28d4fcfc6efd42a985c76f8d62fe60781c9873bd8fc46c3abcc0d4b67a44fa  release/kernels/vadd4.by_unit.json.gz
71dcc94b28fbfd36359cec958483c6e4fbfd49ec8cd6a13ae3ec523942286ed9  release/kernels/vadd4.ccvtrace
420872d019327f5b0a3db4f84d73fb02d153f8b1de5b754e771d75a62261af14  release/kernels/vadd4.log
225aa18fc9f38aa9ad615aa11de254337d59fa705877553d873062c68366e0db  release/kernels/vadd4.oracle.jsonl
aadd84e3ca9e17489e92d16e438d2e2f7bf1966fcd3a2fc0f08ed773fce6fd05  release/kernels/vadd4.sv-hosted.log
f8b498fd68f51bb471e36c301a773c8fcbde095a3c11a6ecd4183aa33d1442ba  release/kernels/vaddslow.by_instr.json.gz
9ac89e73429297ff495f411fe2c31e102c0286bd878d762f85eebeee0817785b  release/kernels/vaddslow.by_unit.json.gz
f2b68db0cbdfc905931b8b63047e9e17f76d5ab8e3de1afbcdc92b6394869340  release/kernels/vaddslow.ccvtrace
99ff1bd7c07c011552c0503b940b3957c35c15338ca9260650cc3cbc20dd309f  release/kernels/vaddslow.log
e9e6218e8b8450e9f9ff6b39d659c994a1e51c527a0c5bd10d18b5658ae0e344  release/kernels/vaddslow.oracle.jsonl
8bf221f4bd1bbf489560d86eb56701f6f6beae9960af9ab01ddae7d0dece73df  release/kernels/vaddslow.sv-hosted.log
67aeb2c0d114083a00099dffd4ab9a481b119e52426c557dd43617c29d8574bd  release/verify.log
56b3d8627d79d397ca06dfb57060015391cb95e52e925d1f09a4b2a7f4147127  release/wiring.txt
```
