# Snapshot snapshot-2026-11-14-e48fa51

**A generated, read-only snapshot. Do not edit or merge it.** The source
is `ti-sram` at `e48fa517d6430abf73ca768bc3d0d831fff5e13a`, and this branch is rebuilt from source by
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
| Source | `ti-sram` @ `e48fa517d6430abf73ca768bc3d0d831fff5e13a` |
| Built | 2026-11-14 (UTC) |
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
e78c17e472dc58ef5c6b3007e47f980acfe5d92415dcb8490c6e97b98ba1f00a  release/kernels/addrhigh.by_instr.json.gz
683325d206a0063f113af32719f438bdffecbce3d811d7a639811a2650565faf  release/kernels/addrhigh.by_unit.json.gz
7f4025bfdc4a9e67d17c349cc2031239027d3a614a0080c15e41212d388f6c80  release/kernels/addrhigh.ccvtrace
02e1f708896ac32aa45132af3c14a11382cbc34faa03669a1b35404f2447d72b  release/kernels/addrhigh.log
569f2e22883fad5f0956c57ec734e6afbdd4b8a854e50277425172d6c0cbd766  release/kernels/addrhigh.oracle.jsonl
3fa0386f2a750dacd04f1461cc5d9343160882f174fc0c04838fe1f160d1d3b7  release/kernels/addrhigh.sv-hosted.log
7ff7a6bd65a25659a8a1b815d8504fb8b139b110df665a4bbe86e8b5816d6d4f  release/kernels/addrlimit.by_instr.json
ec825e1aa533db01d6778b4cedc3d0b6d2a4485af86d802037be182be141b2f7  release/kernels/addrlimit.by_unit.json
2415076357c13d532727f342d8d78f9769f3996b44e4d63253d5779fe61d8f1b  release/kernels/addrlimit.ccvtrace
7dd1b8f960512493d827ff5d953bdc5835c9ca758abbd91135bb64af6757b9a7  release/kernels/addrlimit.log
bc660b0b40359a2c5a2478cb0eb4950b73fd22db50ea76b80052bc195a1920f4  release/kernels/addrlimit.oracle.jsonl
a2feab2198326da968d4dfa53b3e5e7885ecea031bc1719a28677baa8396ca3f  release/kernels/addrlimit.sv-hosted.log
99ca7dcfacf2ebfc39fe2d3c7e3168d75bba13443bc769835dd303eb097904c8  release/kernels/addrneg.by_instr.json
2757a55ed6523961f52b4d7721719c43976041c291cfd2e87b8d126e26facf27  release/kernels/addrneg.by_unit.json
f4503455b47d08c163665f4af4b035f48f142c804c82e0b56a2e7e02d6712ca8  release/kernels/addrneg.ccvtrace
df36b2cde3e4397d913dfcb6b897ef21ce9fb7f8435bcb09ca39f5c9b4905e32  release/kernels/addrneg.log
16f5b0707ae44492a1efd67bb9dd38a7e79a7bbd354fa9207b9e7d150ff2f107  release/kernels/addrneg.oracle.jsonl
a49ff12d076927a982b37db5a0c1dbdf41be6018c811b2b6912f62d62af755fc  release/kernels/addrneg.sv-hosted.log
fbfd0d0aa0b613bc72b59315b6a15c01b2b1608f832c0f5aa0d4dfcfa740af0e  release/kernels/atom.by_instr.json.gz
8c43555c46e785835249d35a9ddffa71891766292e7f34e7bf5374f9d717733a  release/kernels/atom.by_unit.json.gz
0bc740f47ce8f01033071f6055bec13f279a8d85482563042171f4c1dcde13c5  release/kernels/atom.ccvtrace
956e8d0198c1eb8de0124be8c09af239ceed4e1532a6c4a87e6e250321efa6c5  release/kernels/atom.log
504f5b6e9d25114dc35f2c70b21bb7b3f3c508c691de12dc0e87d12a74285361  release/kernels/atom.oracle.jsonl
7075df78070d7fb6bfd2a5a6432992d512735d90b4091f755f41e6ac9fe1ff61  release/kernels/atom.sv-hosted.log
5705367da000c33b8ebbd0ac84c7c61de6d7a8d243b762827adcca3dfb41e5d8  release/kernels/atomf.by_instr.json.gz
0ba25923c2a45260f6f3c303f514f7b5e435570ab70272a7da3bb49c2ba64fa7  release/kernels/atomf.by_unit.json.gz
26531d45406dfa3872adce367e3f24b1c4b4e71c50dddad8d89173d4301de9b9  release/kernels/atomf.ccvtrace
6742e572bf5a4c5b1cd47a87fb80a9d2669b7161a6d68ed2ffb27277f2748334  release/kernels/atomf.log
cfd1179edf4061a33ab2f75d7a6dec61decfe629000198189a7bfc2647b34238  release/kernels/atomf.oracle.jsonl
3d1a7eae77cf755ea61dd17716530650d5419cea3879b908028e33fb381f904b  release/kernels/atomf.sv-hosted.log
a84097ac488e0c988105c827e8412e03df256208b93018bf736ae83012eeff8a  release/kernels/borrow.by_instr.json.gz
4cbbc328a2df5ec5a5d6cb630f327bf064a03b1316ca1ef6d63e5cd7ad089744  release/kernels/borrow.by_unit.json.gz
f47ba0ff76f39020aec6e50deb887c83af18cb9efde597aa3d2ebc7261eb3139  release/kernels/borrow.ccvtrace
e954c5df6c562b7dc6f77be7f3a2931922a0667c41b3d0f3bba6f626f6a4131d  release/kernels/borrow.log
4c565e1ce0b3baee36e158694b32c8defb5cd662b2f9af75cb5d8c26cb1168ed  release/kernels/borrow.oracle.jsonl
e9e1a2bfab060cf569a850e26e8218679c372fd43c912362b3a484f0fe960518  release/kernels/borrow.sv-hosted.log
69822f989c625a27513c2417ed0533a6ec6e515fe9314f8447d307c76e1f8384  release/kernels/brs.by_instr.json.gz
0acbfffc04ca2a5780967327298f073741bac63b92b738f6cd2445848d08c54f  release/kernels/brs.by_unit.json.gz
0efbd34762b9bb839d84507973259b9161e0b6b94498eb217ab8eb280dacf7b3  release/kernels/brs.ccvtrace
ed119ed82ff4d2c7e72b7c1bc127e2227a13f2aebfc4173bbcfb22d3dc17e0ee  release/kernels/brs.log
e3c1cb3379580cf1aae44e8ddc8e846ef6fd661a573cfe0a8d4444b18a14dc56  release/kernels/brs.oracle.jsonl
8b61667870bfb1b26afcde062405a45a612ac27924887246598b153161d11837  release/kernels/brs.sv-hosted.log
0a041055c995f1e9b0a712da787ee729adc8a1740afd519457af9b5a2efa67ee  release/kernels/byp.by_instr.json.gz
780128e48c5fd9a0185daed3e09b332f9239e13d847c421faa11bce7d9148785  release/kernels/byp.by_unit.json.gz
86ca4cee698bf94b1548f3b1c9acbdec7c36a7e3888421f2fae3bd0627791e2d  release/kernels/byp.ccvtrace
d70ab9eaa9fb613e4fe194c5930acb62f4d02aa7302a2b30a846cff9fe912ea1  release/kernels/byp.log
5a03dfa4f3603fef49f1e3639e74e34152ca3ca5ef8e41eb959f8323040fa2d5  release/kernels/byp.oracle.jsonl
7794a4984d5a002c9515e2641bfa4c96947e5945faee3a27d399b03861ab6a2a  release/kernels/byp.sv-hosted.log
8789b7f3e8e95c7109f5e598929afd06612de15f55000e5350ec16f66a1c9adb  release/kernels/callret.by_instr.json.gz
f5b3abc4257dfb3487909b95a9b095ef3415a6ebe6118c0cfc64168353aeee7e  release/kernels/callret.by_unit.json.gz
b7b7eeb3e6d53aa18dca668f0bd9f2a6a499f69105bd8e0b4f645473e8e03fc4  release/kernels/callret.ccvtrace
58ca6b7217c50e9fd56476107305fb97168cbd36e6cb3a3dd91ee4b5bc66315b  release/kernels/callret.log
9b1d1b50b527f732362f837250aa2f26dabf3e76e16a4794856ebd8f105635b8  release/kernels/callret.oracle.jsonl
8c39b3ab5e5fb7daa76ffc216618358590e7c3f6341db8694b5c84fc8e5968ff  release/kernels/callret.sv-hosted.log
751a50252bc9117cd77d2c4fada0a58ca49aa58390e3e3327c0c9893a168182d  release/kernels/cas.by_instr.json.gz
ab9e9cfac0e298216e6727f4e9ff2edcf9a78dd16636021073e8a34da696f142  release/kernels/cas.by_unit.json.gz
5877d648cbd8cd3344bbeb0cdc1aab3baf484763a7027f4a0402a924a8efc846  release/kernels/cas.ccvtrace
1cd693a54c6b325a43915f1d40a5e9cc98908127125367e5e76a641322546c32  release/kernels/cas.log
0ab31a9443336fe5d08e1a5fa5fcba3bc279b19022f7c5007908d39d8ef39536  release/kernels/cas.oracle.jsonl
c6a0127351ca6b1d6fb0d22240fbeca115efb4fb19e36e4bb8fbd7a3b602194c  release/kernels/cas.sv-hosted.log
d59944d0931a3df1609da12e6923b1918694605c0a1af3d1d682e659a2bba944  release/kernels/chains.by_instr.json.gz
a2522e17181816a828819afed36cb156a8ac50b011499d07cd7ed3aaef231186  release/kernels/chains.by_unit.json.gz
b47e10902de830c337bf591bfc2daf06098880741b67957d8e8dd9c45208dc56  release/kernels/chains.ccvtrace
08e20f8f8fdb123ecd3d02f62b7395e3fcfea10a7ea24580bb41712da18514f0  release/kernels/chains.log
26a4cc5c5524c7219d8706c2582c80357dea60be9d6ffdec99dac7d0365e2264  release/kernels/chains.oracle.jsonl
1cce4935742ba85e3c5ff85d7fc517c39983018ea23ae3d7e21df5b63242ed90  release/kernels/chains.sv-hosted.log
da12cbbcd38bfee185e40bc8bdc12d15e0b3a469b6412a1cc2eaa6436a565007  release/kernels/coll.by_instr.json.gz
acee19c01b382de91e56d183ebf97a8227c1e6623d0baa3aa5f821f27c726bb4  release/kernels/coll.by_unit.json.gz
9b2defbca3a81f102a07f1fb1a9473253e58da6ab1e7375a8d81f4d1fe098bae  release/kernels/coll.ccvtrace
1d20dba35eec4d23efeba9e32fac0760493a9148755ebd17d7b173a10739a671  release/kernels/coll.log
dd718d23c88df5dc7d92b055d8542865aa0e029118486af127312a8a578cfcbc  release/kernels/coll.oracle.jsonl
f39c8d0f481cf3d99540d4f8f8c00b6627cf64a9ae88992ae85dc85af7049cd9  release/kernels/coll.sv-hosted.log
2ea8f24f9dae8bb26ed9add0d0cdd7dc3c5dddeb276a1888485bf82f662f2b85  release/kernels/div.by_instr.json.gz
5a8a33d542a6d0db31066d81d34d48ca5f5909ebf2d86ccd08b6760e693e050d  release/kernels/div.by_unit.json.gz
182346c5baad147767effbea67248ccbc6e5c35582f0590ab266ce10e6e9dbc8  release/kernels/div.ccvtrace
97baf1d1cedbdcee58528838d0065b9be9a0409f2449e83f9b95ea2d469e70e0  release/kernels/div.log
71a567b85cf85622631490187563de9a5661099c78a590adff4ed0a0c3d24c16  release/kernels/div.oracle.jsonl
8edd1aba87f8f925c682da1f22274cb044abcdbd1b141026178acde4737589e2  release/kernels/div.sv-hosted.log
87ff5c79c04c9d5a9ce58c111fea007bc7571444a957621d8c37d943825d2007  release/kernels/divchw.by_instr.json.gz
c07fd0fac4e303c136c6544a20ed50d3bd4566ffd30d62a527becb4d956fb29c  release/kernels/divchw.by_unit.json.gz
4471a48e9f9555ec3ff526316b30290fb0ff75d28588185a2a52382020681eb5  release/kernels/divchw.ccvtrace
041dfd3b5f3da8b1c51d1b9ddba49816e86f4252c02d3a80b1fc51e9ae32c52a  release/kernels/divchw.log
58a541797f7a2df0a1c7528ae6a3edec212db90c7d3eb20656806f38b5c10b3d  release/kernels/divchw.oracle.jsonl
ab5cc3e2bb710332442aba15f38861e8e00350db6a2072f4baef6167369b12a0  release/kernels/divchw.sv-hosted.log
7287b6828982d6cabfba77216f14d6330ec8b9bb87fb79d2c73226657ef68f20  release/kernels/divtail.by_instr.json.gz
9755f8aaaed6fe72ba117c93b23c3ca52dc125b49e104d0c6beda23e8319478e  release/kernels/divtail.by_unit.json.gz
2ade202d8c5fc071687f18239b0573f55461d1606452ff6daa16db3738442f2c  release/kernels/divtail.ccvtrace
005c23ce6689b7f49ec80eba6ba113c4aa2991749aaa3616ab26329b1ebd708e  release/kernels/divtail.log
75f11a75c9b3b336e446140af4579f05b46c363a76b7aab3ec88154a07ba097d  release/kernels/divtail.oracle.jsonl
5a0c628d1ca8e6daab2032f1aeb4d4171cf1b9b751d0e17bb1e1d4ac5620ba17  release/kernels/divtail.sv-hosted.log
4e7802c1254e9469b32fe96d3ab388b8f54dd90d319777ad02a29ab235d7af20  release/kernels/divtail2.by_instr.json.gz
79f0dc7580910b7847ad098f7aa22d063d29e6dba135f767ac2094e5322fd0c5  release/kernels/divtail2.by_unit.json.gz
e27413844716e2c50ee7f69833576c60a6fb7bc226660dfe365677c387affdcd  release/kernels/divtail2.ccvtrace
b0ac644feb8dfbface75f1f9cf72262da7e52e27f5943d46e074242d9508f258  release/kernels/divtail2.log
b2db6b05eb6cf4a0a7677e31d0c6c2952d5cab49d353f0bb1883fe0b2a20ed14  release/kernels/divtail2.oracle.jsonl
63f49e50365a7382c0a55efc3306300b2fda304874e68cd73a9f529fb07bb308  release/kernels/divtail2.sv-hosted.log
7ed7898e468f05a58ee4a868919f8464ca5a672cbb98c6e9d739843a64cc4af3  release/kernels/fence.by_instr.json
f384ef5f6ace156e75b63eed36593fffad4db80e05da5a77919e7dac626b928e  release/kernels/fence.by_unit.json.gz
902d571234711aa609de8947a424a60e599755724ff6b2bf6bdf1550cf10ecf6  release/kernels/fence.ccvtrace
a54537e1572c77e0ebf6694b77222d9a8fcb15272bf304ed1655b1464c688b00  release/kernels/fence.log
d1d40317f6cf5bfb430cda1f9c0ef676609e59cabe2a11623c42ffbeca93142b  release/kernels/fence.oracle.jsonl
fb80b65272c6394650872819d2c4720cc6fef623a51b7f78a8532e10b0ab2615  release/kernels/fence.sv-hosted.log
d225df83ce1642dfaa4577203c71c886586970068528465dcb16d28434e72d62  release/kernels/gather.by_instr.json.gz
5e4cbbf3126d6050ef31d28ec955860266ce03adea0fdd4901ceb1db07f092b2  release/kernels/gather.by_unit.json.gz
7dd36b5debb059b7451787301e7c983159b9833d498fbce4faad199f81b1b646  release/kernels/gather.ccvtrace
cde4320919ad6c3495b8211b9ba7b5a07895d7a02a1a1522a91680da921044e0  release/kernels/gather.log
0413e781d8d6ff578c64eb1f800b7931e66f676d5cdabb97b94a4033e6037662  release/kernels/gather.oracle.jsonl
c423f5f132cf0762f335b1aa9a7c025dd6717d96a8fff230f529a5bbe1d935d7  release/kernels/gather.sv-hosted.log
146792399d6e9f95967b94062bf1b515010b131b097199fb10f6f350306b6826  release/kernels/hit.by_instr.json.gz
16368b617eedf5872f99b29d7c6c73f57b10ef00744709232b5a4f68e214be22  release/kernels/hit.by_unit.json.gz
893ff785c670decbe42a7f52b662717eafc73000532b6104f2b6de421c0005f4  release/kernels/hit.ccvtrace
9fe1ad73deb11da451a49813e6d6896d7646ccb27da3b2c7c4af44284354e6fa  release/kernels/hit.log
7ba9603e0088d9164de6528f16ef6a7fa9ce5821c8c12b52cbb3734e39b9fd52  release/kernels/hit.oracle.jsonl
6b4f0b58f8b3f1de44a67abfbac477d30afc13f1df99225d11ea8bf4f9fc6fe7  release/kernels/hit.sv-hosted.log
fbf210b8cf44c5f56c4b8f22e5d89f059ea87ee2467075bf9ec89bdf2c664ea6  release/kernels/lanectx.by_instr.json.gz
99bac0e4c53a2de9aca29ed6709b6c2b4b3a02c971df5f442a4c8079d350e0af  release/kernels/lanectx.by_unit.json.gz
04cb909321122accc72a84a88ce06c11e76a20160502594b50a562bafe82b1a5  release/kernels/lanectx.ccvtrace
b7595004cd8a0551a712bf726936af05a0d8476340bb3e1b27ac89b81ffda3fb  release/kernels/lanectx.log
888551babf540db8e3025b82e65ca655013f93eba3c8a65689d069d52a7e6039  release/kernels/lanectx.oracle.jsonl
47b8756558f2f4911d5e0a5278967dd69217be7918071406d1d6df3953a2135d  release/kernels/lanectx.sv-hosted.log
31589209b01c1850cd333f9d56e42d77f0335365c5ad17f37216895b0772e2ab  release/kernels/lanectx2.by_instr.json.gz
0b4d90737eb17e19dd54839e3b6210c293976306325a187db415aa7332bfac15  release/kernels/lanectx2.by_unit.json.gz
ef023c0267cd5d07b71c47b7a7879f569ee3c013aa6d0e14a776bf7dd08e305f  release/kernels/lanectx2.ccvtrace
b0f1d268b57e48e30fec66a31fcef75383e015e245df3a181940f5186b936e42  release/kernels/lanectx2.log
45c13056dff5c73ed0c9ece56cc36f929bf335322193c7d5eb38710b1d1dfb02  release/kernels/lanectx2.oracle.jsonl
e41bae982919bdfcd50532bf82328fae976ba8a8f3b9d09c9513e31354b3bad3  release/kernels/lanectx2.sv-hosted.log
6f84c657b201629316bd1640308eda0494eb6f81eb1e15b7fb45d0ef6368cf31  release/kernels/late.by_instr.json.gz
34f7de8f8c08e1369262b3cd486d79f10e6c952169a2a37fdeb98dc3d9c69b93  release/kernels/late.by_unit.json.gz
4d01e4f710094f92535e5bdf98d039b53e0279d85297e3891c30c9a918042525  release/kernels/late.ccvtrace
2ec1135acb724e9f04fff31a61fca6bd58c0df26d9d5c8373045297cc0293b9c  release/kernels/late.log
86084f6bd747a2cf32acbc0ebd96ebd3e4ef2d8d9e21be49e3ae49290d7927f3  release/kernels/late.oracle.jsonl
446161a3cf5dff897c2e657c0bba374c43668779d8327af35ceecd50c5db9423  release/kernels/late.sv-hosted.log
ff1f7028a1b35e0c08968a949d432df3bfc04764f65c4704dd8d2edeeb425c04  release/kernels/ldpar.by_instr.json.gz
d22d4d5cbfe117d8ec633d67badbb0bb1e60ca5beb7248f3c28ec518e7b15c5f  release/kernels/ldpar.by_unit.json.gz
e1a8cb1b4392a870125afce5c147babd4adb301aca13ea213a6b9f40bd246472  release/kernels/ldpar.ccvtrace
f88bd25f8003161ac2aebb60363dac8ff5bdcb80c61d138687f0406e23bec42a  release/kernels/ldpar.log
8ac08538e9c807637babd61b31e340f7461878ada31f0c0b83cd66331cfaf486  release/kernels/ldpar.oracle.jsonl
6720bee3ac2bada66aaa2cc089a18448a5c75086f70de557313860dbf49eeeed  release/kernels/ldpar.sv-hosted.log
05ac0bd9e48b8407166ebe08ec65dac4f220433bd0c5f253aeb1df29018cf061  release/kernels/lnorm1.by_instr.json.gz
1ae39c4fb3c6a4f47c2556b73c7dcf5e24f6f5aeba5e8d32fbaf5989d6335cb4  release/kernels/lnorm1.by_unit.json.gz
efb3db304100f3fb99fc9ef199e8c8c51f704b777b3235b0821e11432d79f628  release/kernels/lnorm1.ccvtrace
067ec5ad306527157a3ed4bdafbaf41e0b1d6a961d1450ce02348a47dd740692  release/kernels/lnorm1.log
a8d85811af988a1b9fc00db1517300af3d93ec8e589e403d3b9113fa9e0ffc86  release/kernels/lnorm1.oracle.jsonl
71d31a91ad9d2b553d5d27b8a7b935cbd5bff189453a0e92b288c87c5fc80048  release/kernels/lnorm1.sv-hosted.log
2a98cde7ddbda9a0a55a67dd64b635115998d6ed4a050b06f51368918ef2b548  release/kernels/localsp.by_instr.json.gz
75c7c6a852239bba81582f59c0c43c9b033b7cb341651ba48389c52d0cb17ad2  release/kernels/localsp.by_unit.json.gz
d1f65404e6fa7aec7e975bd27f5d846267aae0c74d0e1a60346d2df8cc2b3b3a  release/kernels/localsp.ccvtrace
9859a17b8c7645700ceee2fb07e3388980cdb4cc127414ca073edb651b4ee69b  release/kernels/localsp.log
55e3c9f36e7f7d38c0ddd38903aff4bb4509ae862015c592e6b937ea258042ca  release/kernels/localsp.oracle.jsonl
2c877553475e13e169ef75d1b33a2296813d2b2b389dcdb0be1c21a6eb355a64  release/kernels/localsp.sv-hosted.log
f320555bfb9144d376185a7103e740be7dbaf28376a9649968bc15d84b5d9850  release/kernels/loop.by_instr.json.gz
1f51fafefaef2b0a2a78d3b4cee28a8fd5f096ab19d9859f717ae7295a957efc  release/kernels/loop.by_unit.json.gz
05599f989c0d60da6bbedde81701aa56ae1c2a56bbb878bbddeca9829b14e167  release/kernels/loop.ccvtrace
b63c67764f690c900331744e5c43f7cf5545980fa79b7c95760dcef3d574eb17  release/kernels/loop.log
03ce5920c06c93e93516d8e53c3f7169f14e3593de204eacceffc0b8a3e32016  release/kernels/loop.oracle.jsonl
d86420f772e180d3744264d8f8c27c7870f158eb6362b2e6821ff00a05e92e8a  release/kernels/loop.sv-hosted.log
2f379b9fd2edcff872a9d2619b58a8037e32be737fc2d2e6901890909cdec713  release/kernels/merge.by_instr.json.gz
9927cd3c964a2dad31570c90eee53c02615772a796c1b8888baab6b72148be98  release/kernels/merge.by_unit.json.gz
2f43408ff2d9fff8512adaa9e24aae50158636b35dd1778e07d3a003df283170  release/kernels/merge.ccvtrace
05b3f579c4368e3dec84a7db73c8ab88a0dd5d5e5058e09b268e77ad7bd34755  release/kernels/merge.log
f96d28815f8756b1f5a45ded53e6170883d2dfa10f9eef0d14b8050b1318164a  release/kernels/merge.oracle.jsonl
cd7978f04d2f2a506b08f394a821a00bcc262a02e9afdc8a0c6095518d9398e7  release/kernels/merge.sv-hosted.log
30eb63e22c327d93e06ba58bccdde514dbd1052375c0cd0c995bcfaf5c90f1b6  release/kernels/missrun.by_instr.json.gz
9c1aa0cff6c0b7d4bc17719572b7be801afbc5ac875fb5cccd30d7cbb65b3dee  release/kernels/missrun.by_unit.json.gz
904f65ed8087afef70b94611476fe70013468834790cc80993d641d175678d82  release/kernels/missrun.ccvtrace
e2e3de8463209fa7a01f41c8625dbd04e0039971d80db9721964ea88b1d63f3c  release/kernels/missrun.log
531bdaf281e5590774bd2775427f25e4cc0419cf8e3d5b6999843ffe9ef87258  release/kernels/missrun.oracle.jsonl
8c1a85934389aa7516177d202b281dd3daf502feeaf98dd7cda39ee3e84d8c8b  release/kernels/missrun.sv-hosted.log
09ad294f26b92fd8aa0b10cb01fcb1cb22290e392ada851ad212b9d2ca963876  release/kernels/mload.by_instr.json.gz
fc9255ef4072fbc4de5c5e2566efeb68d221e9256b79531af1d52db470a10365  release/kernels/mload.by_unit.json.gz
76b553be6382705b8a38e14f10567c4c54c80edce392f55edf4aad513b4ff522  release/kernels/mload.ccvtrace
afab4abf6a993f6fc99239c3ed24b57fe3715bc9ece4d0b1b2235c0bd671448d  release/kernels/mload.log
8000e477b9a95dfb9f0af964e8346acb9d36f1358fd06ffc4ff7cf599d2b8868  release/kernels/mload.oracle.jsonl
ca0ca5304119113c894b9890141172444757e73532a8171dbcca934b67fe12a8  release/kernels/mload.sv-hosted.log
8a9c73fa7070a9b245204a2e662fddde13641b33b52259dd08c9e7d035432d4c  release/kernels/mlp.by_instr.json.gz
e0240b332c2b1d0fb76fdc5071475910aa5513cfb9a33bb1043a7e3ba5e099d5  release/kernels/mlp.by_unit.json.gz
7cd6f5ae5f30dbf86e7e4a4c0a82e6f1bdf6fe471cc6e6e37aef86e03bf88150  release/kernels/mlp.ccvtrace
2aeddbc1dd361ae4fff86dc6c8a682ac3a8e36bba0ef73c42128dfd336860e62  release/kernels/mlp.log
138d282f88d56c8ad648a91af0a983254b55d9fa22942c00d47b327f516a6e44  release/kernels/mlp.oracle.jsonl
a77efe1d7e3e01f3b31dfb7ca3ad0e8269bcd42fdd1660b39a5ab6ad3a8c1400  release/kernels/mlp.sv-hosted.log
0632a5f527baebb04f2925f87e62e3b18301aa2287cea080badf0449ffb93ca3  release/kernels/mwmiss.by_instr.json.gz
398357a2cc09ca9474b0c7b3c6e44ddda30e00cee512d1e0d7f21af621f4a7c1  release/kernels/mwmiss.by_unit.json.gz
f218172f4887742106b54c2b71356b417c6f406c740e78cca232f9d437b3fdc5  release/kernels/mwmiss.ccvtrace
6e52809086fff0e9505ff8373948c4fadb3a806036be5b4440e92bf79fe3e5ee  release/kernels/mwmiss.log
8abe8e8997456a2a6711ee72da54d854b24e20abbdab28e4b7271c0d28418de8  release/kernels/mwmiss.oracle.jsonl
f3bc33a43a2d8e64245dea88fd75770b4cc8dfbb5a9ed94f7bf53eec4ff09021  release/kernels/mwmiss.sv-hosted.log
f81415d031b122f588587b08368db4b0159805ebe30ba5ac6e7b7e42a093528d  release/kernels/narrowadd.by_instr.json.gz
afae89149246b93019c4a6c8bf63319958efbe5db0e364776567f562824d8b56  release/kernels/narrowadd.by_unit.json.gz
15a76c0955f9c35c0f6536d59b6c38e517ded7ea3b74e350d2288ab716482cf9  release/kernels/narrowadd.ccvtrace
a519aa92c6851282acf2a424155d6a787de378c67735a4788f0d9850b5a4ad75  release/kernels/narrowadd.log
40a2cf629853dd404bb06b4a07e35abde3d12efc13f26ffe28f923daf2994574  release/kernels/narrowadd.oracle.jsonl
1ccf56e3a57d0bbe5ab9d9f7ac34d11568ebbdcee4538a6486ae7e10b0f2d5c8  release/kernels/narrowadd.sv-hosted.log
21734ecd3a5aeddeeda4bb6c17078ebb8d9305566ce6189609a0975700c435f6  release/kernels/pguard.by_instr.json.gz
0964a78f7081a0ce54582862bf167632333b73ebef3f3155ae524b96fa042022  release/kernels/pguard.by_unit.json.gz
1be32dfaa56dbde149ff08e78810d1e8adfc2d6b199d31a352930ba7859d0d18  release/kernels/pguard.ccvtrace
b227e27956647283beb5c258f97ddccea623b345f4210fce92ed72791b29fbe1  release/kernels/pguard.log
690e56f1cb8d97cbf67124b7dff3ad0a90cb8981814cd1709cf0cd0e035b3bd9  release/kernels/pguard.oracle.jsonl
6f48f1178d283d668469df8734885346e866c4e36b36494700077e3a028c1e69  release/kernels/pguard.sv-hosted.log
834bc996ecf914c58992b01a4428aa398c6a5150d35fc4a34da801dd9e89a768  release/kernels/plog.by_instr.json.gz
9bf7495dfce787bd2354f97e4d0cb3ecbff842c867a156b30f2c7a2be6d71185  release/kernels/plog.by_unit.json.gz
ce4aec9a797ce6e24a9082c3c4e22e4cc45d2bd6d9cf47ffadb3e8da5e251eb9  release/kernels/plog.ccvtrace
c38f08db9a948ffed4ac4dea41d588cbe2aae168ae3b06e0a2abb4074406b692  release/kernels/plog.log
0c99915e2da60f4670da00504a6371d7d17701d4431e733a3ff8fa98a2030d6a  release/kernels/plog.oracle.jsonl
afb040981a5efcc4b9755d4a212d62996de8fa4acc86465d9647ac5990251f5e  release/kernels/plog.sv-hosted.log
494df17cb491b67ad6464fdc80c3be30aac620770bb1b11dc63f8a9ac1fdae96  release/kernels/pmovdiv.by_instr.json.gz
d93fa2916966d206abdff2853e2194e1e6473c7e30c99e869770fd7b1c2a26cf  release/kernels/pmovdiv.by_unit.json.gz
4fe481c67584f36b72d1f510fbace5f75fa34ca8d76713e16d393f8638f099f9  release/kernels/pmovdiv.ccvtrace
c0e98d22d0eb3e6b16c394cfa5bdab7f535805cb521cf04bd7a32e2107b46817  release/kernels/pmovdiv.log
7bc646cff6166a51bdce03d7c1b7209e871f0a91d743083a9b910a80bcd0b33f  release/kernels/pmovdiv.oracle.jsonl
0e56181e7c064bf8acb9d7e3a5172f84602ed56e1cebc26f27489b483acca1f2  release/kernels/pmovdiv.sv-hosted.log
4670ab46137d008fee401019dd06d9032de4fc6db532cb3931806cd51c64070a  release/kernels/predlane.by_instr.json.gz
b39c661a4039e966241ab5a83d94d1a3a179a6ba7e9294e8c099e4e0d23d1cb6  release/kernels/predlane.by_unit.json.gz
532a8a0c9135721ab0526accc4358e8fdb1ef57c82585686a0c80705acd1e51b  release/kernels/predlane.ccvtrace
5d3481d188d7a2f0ce2ff7d7a279208339d8c41e3b905868532a0d52b1d038cf  release/kernels/predlane.log
c45f4177b9e84fc8a6e36b13534a0c7636eb30a3f8531847100ce5e23bf404b1  release/kernels/predlane.oracle.jsonl
bcb0d39c5d9dca8e0be73cc2486149fa409cddfc11b71c5f94800bd665c93d28  release/kernels/predlane.sv-hosted.log
e83fa8d2ab1e5fc57d8af4d53b1ee01a7fe0395db8952aba9edb12c32c9bf52a  release/kernels/predmerge.by_instr.json.gz
9d27c920627c6cfd5c2774f2437d712f42206b95fd92facb83b5eeddd52f8db9  release/kernels/predmerge.by_unit.json.gz
505403182995d5204046ce387c328ebcdbcf638bf96eeca5047ce00ae556e20c  release/kernels/predmerge.ccvtrace
106b3c2bacb2bfd6e86cbb1d530d8735eeb4db7607df0d7b1a00564edd758c01  release/kernels/predmerge.log
6c737c49434bcd08e3e0814c8b1dbf15c586ae74f7929ba3148ddcee2c62c845  release/kernels/predmerge.oracle.jsonl
f7d073de5ff61245fb50d29545c25d169d28eb466cc1901e02e33ba4f5c2f74e  release/kernels/predmerge.sv-hosted.log
350156502e30a1c977518674081c74cf068709251f69f5bb31a350e9264652d6  release/kernels/predspill.by_instr.json.gz
bb2c313183a3534bab9a050ef8c29d5693af6868a7d844f25f1971d97dbf3b9f  release/kernels/predspill.by_unit.json.gz
99589c2367cfa6d554c451bed32503c586dd1c925cf07763095171cadff9a5d7  release/kernels/predspill.ccvtrace
7f09479ad9a5a5bd303bf7230d0016994baea30c5a41377721d1e8277d9b86c7  release/kernels/predspill.log
b7c84c6478117ffa0f06da0e6ad1e4628e2683426a7911080810e78e06a5242e  release/kernels/predspill.oracle.jsonl
d3eca12d2769c466a8ebc30e9073d2c38cac6a97881cc276cdf7b040afdeb1e4  release/kernels/predspill.sv-hosted.log
8a4423e736e8f4bcd946c2882653da93bbde1e28386285d4daba7846a82604f6  release/kernels/predswap.by_instr.json.gz
b9ece2968b32c2d2b7d85fb4a6d874d30ae28d524f3a855e838aaeae0e54d155  release/kernels/predswap.by_unit.json.gz
e93b8efd89d74d085e81ca285cc6abdc1d88d9191054f91939a93cd8fb6e173d  release/kernels/predswap.ccvtrace
39b1ce9faddaeb4e4ff45e0182ced692b4d1d62dda8b107dfa7001dc248d5af2  release/kernels/predswap.log
a6d4f7ed517553816d889c7c9eeb6bcfd1f6c973fbf682ecb69f3c2de619f7bb  release/kernels/predswap.oracle.jsonl
f023bad4158fde49ac6bea38c307a38c28f8f24ab7810e2648e3aaf4e88c3a79  release/kernels/predswap.sv-hosted.log
308960d74ff90c08d21f0b16639bea8eb43cbae8d4b35e5bbe2740f0e9e9edfd  release/kernels/privwin.by_instr.json.gz
7059bb3f985d67b30e1b71a33a7567db6bb8530453cd7df46618bd4f02b689f2  release/kernels/privwin.by_unit.json.gz
18e0e4196496316afea8ddb1ebfd35823b55f55b525c74a00da737519767f2c8  release/kernels/privwin.ccvtrace
acbc0583950a69a9cd22f36e5f5a2880d0b56fa6f99adc6fa8873499472acdd6  release/kernels/privwin.log
861f686fc4480363472908d679d8815e8c957d768e7ab32c826930527b0fb7a8  release/kernels/privwin.oracle.jsonl
5871ef53ef1eb670ea56b5fbd1c68b93b367798a4db5f4c75b9587ab60769f4e  release/kernels/privwin.sv-hosted.log
71fe0888d0205e737189aa4716ddfacb7c8bfe2368f4c9d91acfd56a5ec2a53b  release/kernels/provswap.by_instr.json.gz
ed117b305e3846b7d29fd4c786757ea97bdc7a2e6a82798f1456723a2b2a75af  release/kernels/provswap.by_unit.json.gz
5597ac486c6c41c594b8dca2384709e7efa590ee2803188b22be0d922972f27b  release/kernels/provswap.ccvtrace
15f1abd262c243a24f5714b6ebb9c7da8484665bf3f56ecc3dd905575e93b063  release/kernels/provswap.log
c9c32a793d54cc7401477f582487f7e8b345b2669a75337b8d6327120d98e5dc  release/kernels/provswap.oracle.jsonl
a8b04a8cd9fdda1f03f21ceafba3f2d8801f43dcd932652a68288d0fe3851736  release/kernels/provswap.sv-hosted.log
80b145e1ba07c42dc419eb6c5d4df28023b7cfa18ca72134c9ce887dd8211865  release/kernels/retmiss.by_instr.json.gz
ff217bf116f43fa7b8172e3cddfb68ba8c75ecb9b64b4bc1a23cebf5d4933572  release/kernels/retmiss.by_unit.json.gz
d362264f223295de3b7593ec488c489875eb71f98f1a9eba55148418537fdaa8  release/kernels/retmiss.ccvtrace
6a0c6a584378cb14c42758f94a42d99204842e891441adf7fe42edb6df3ebf31  release/kernels/retmiss.log
e5ef8538e838c6cff7febfc679dd091cf5e002f82d34f1009b1948ce22bc3649  release/kernels/retmiss.oracle.jsonl
13a05ebd2d2e38b177a26b64ced548638f277a5baee19a5cd3aec92c373106e1  release/kernels/retmiss.sv-hosted.log
d45b064f90b496adbbbf3be694a8cc4f6af4ea41825c8bb83b0c4042da5a369a  release/kernels/roconst.by_instr.json
b38b6900712bfd3ada68a6b3627c4ea3fe521aef042fc47dd43dfb23bb1283cf  release/kernels/roconst.by_unit.json
f3713f83ec2f195b035033bdb47cfd76ef95bbcac2a975d18c8e17e3b3ccda49  release/kernels/roconst.ccvtrace
9d6365b62ab170111a1fb2a99102afacb330befb377387ecf08467fabf15b3e7  release/kernels/roconst.log
8087c0671de620162881aecd38cd6114b78e7be6bd71201e3ec02c9a2e2e750e  release/kernels/roconst.oracle.jsonl
71b1fe256c864624fe1325d353c644654d3ca5a65483062600d23b2357c916a1  release/kernels/roconst.sv-hosted.log
7d213047dc11229803ff907bc5a2192cad3a16f993fe7f5ae66bdd5e6ec74442  release/kernels/rogated.by_instr.json
8194a43567bbd6ef47011bf5ea5b478a1f7fc08ef95ee54d4a666fa6074bb57f  release/kernels/rogated.by_unit.json.gz
e0022bd67a6d629144891b56607860fafa98ac1de5fa80dc411be11a44c9a890  release/kernels/rogated.ccvtrace
d94c0d81f0559576e8276d0f498290c863840b7365b30eb5f2838713a256111f  release/kernels/rogated.log
7cd02bd4cceec5a044d6b4d6a80df1e68ed0ae71b0b2a953143636d5b809ea6c  release/kernels/rogated.oracle.jsonl
c80acd010957d86f51897e1ecdeb24326a16966172efb8e2739ad3ee0d7800df  release/kernels/rogated.sv-hosted.log
3a7d335b61fdf5378872cf74fe33bca30f7734e96287f0bc4557769ff1323288  release/kernels/rokill.by_instr.json.gz
ed102cb13eb74cf8bfe0b20f25e8549dc03fa4247d4ea3bcc3d40f8e1b45fb05  release/kernels/rokill.by_unit.json.gz
cb434c89178bda63feb85c508e8cbd1b00bffd6b69525ab858d2b11b6cf16c17  release/kernels/rokill.ccvtrace
c48d1a47dca890ee28085c194f6ac97d10103c2b5f3385d95d3143aa1d3222c2  release/kernels/rokill.log
94efcef96af469a512d346ce61623980fe86383188eaebd55120f716db596f14  release/kernels/rokill.oracle.jsonl
4e34d4d0d75cbdcc49dbac0a0b8402484f8491cf4f26a030dbe75ff602d1fb6f  release/kernels/rokill.sv-hosted.log
f8fe604241644b224e6431d16e4fad889c99826b82f49205e4c9014b9ae62e8a  release/kernels/rolaunch.by_instr.json
12e5281971b0a06ca95d953aa22a6d6b481d8fee948f50ab777c87877757fe46  release/kernels/rolaunch.by_unit.json
32fbf77dc8fb17f0113b068b5a00568b6ea97be3ad8e5bd1c69b7cae2f04a946  release/kernels/rolaunch.ccvtrace
05593d496d7640f61121e25c28096a5ccc811a6f65b9925378404bae6ab85a92  release/kernels/rolaunch.log
e7dad585c3e70615de04330fd03f4f282c29a005dc1732a35655fb261d51139e  release/kernels/rolaunch.oracle.jsonl
f907d68828ca31065456822af2b06342661cb2a5854fd294ccefd7d355564176  release/kernels/rolaunch.sv-hosted.log
d45b064f90b496adbbbf3be694a8cc4f6af4ea41825c8bb83b0c4042da5a369a  release/kernels/rolimit.by_instr.json
e8822066a61bf10f59647aa7240a3044f25d2eba55ac5f7ebacbf1901974dd8f  release/kernels/rolimit.by_unit.json
0e8db555321feaf0fded659de3d7ab35b3dadb15ccef4bf8dabfaec2e87a5563  release/kernels/rolimit.ccvtrace
b7f15638a705291312ed5cbe7ced98ccc2cb88bca39b8f6f8c69586273a388c3  release/kernels/rolimit.log
1c5bc0cb8e8b2e69505fb5a551a16d5d10c56f232b88da7a27e336ad7d962de2  release/kernels/rolimit.oracle.jsonl
be473fd4b5a884500cb6458ab89e4cad30d769b839dff8fad7ff956747def668  release/kernels/rolimit.sv-hosted.log
a0157de6cfcfb850abac902fb7bf1a9d4ee3bb0401f86b266797020420deb9ed  release/kernels/roload.by_instr.json.gz
acecf38bd270d5c3b499bf9192c3e055616b7ed6cb664b187a04f1890b82fcb0  release/kernels/roload.by_unit.json.gz
e2634c3e7aff20e8ca7e9c8f14599a3f74ea0f42f10d0bcb19fb0f8333fc3eef  release/kernels/roload.ccvtrace
875187801025e4573d18cb9cd39ee2df6fd5108c8e63cd3ceabbc6b1385fe2f7  release/kernels/roload.log
f7c1309cc9764769fb5803f6fd0f2f5e1eb418f2d23fbe5e17cf5f9106869fdf  release/kernels/roload.oracle.jsonl
5cfb3551d4e8889bfc48823efe5cdbb53d2afa7577eb59db0d1e8cdfe7afedf0  release/kernels/roload.sv-hosted.log
fbeee1e2e6a9cbbf940984363d70fff14bd366bd7a7dd3f0f4fe53d84e42b57e  release/kernels/rope.by_instr.json.gz
08195af3eb58f37ed4927bdb697c06391d71821ba3366f54528e4e9037b77810  release/kernels/rope.by_unit.json.gz
c40ca40858a13f0528f0d1f946ad3b0ad60d1c6c35bb432ae5f6fa95b49f701f  release/kernels/rope.ccvtrace
18fdea4027fdfeedf477030ab5c8c9234e4f0284157f52349eff9a989ac424f9  release/kernels/rope.log
d55f9efae392dc8877c102c01c0810e7654b666b6ede386328108164c6cf88f3  release/kernels/rope.oracle.jsonl
d4908052f6de3dcfb8d0ea4419ce8b7ffab27d63aea60120b94c396f5d9c76e2  release/kernels/rope.sv-hosted.log
a8d49dee876fd7514408bf408cb823271658d5460b747fe022f5c9ba6c264e4d  release/kernels/ropediv.by_instr.json.gz
40ad2271b7b63f95e76688af1278e93be45e830a64102f32dbd9b9c3cfabd204  release/kernels/ropediv.by_unit.json.gz
ab39624cae9f0b150f2bac34676e667c91b8d180c27d5860c8050cf057a4329f  release/kernels/ropediv.ccvtrace
01c99f50ccfa33f62bd3eb558af2e38d67c653f4ad5d4d2d6f785591375f4786  release/kernels/ropediv.log
10c0ec6ec18b7b44638c790033109198c079d07c1537bf193353ccedd00a920f  release/kernels/ropediv.oracle.jsonl
d727facffafef39e9c6bed3317dab3cfceb2d588ff286a50af7d76d6bec66db1  release/kernels/ropediv.sv-hosted.log
a116a5c8d96e7ca5e0648589f6930eb7b39243c27624f6967801fdaca32e9df1  release/kernels/sel.by_instr.json.gz
2bb84426b92b4aac850de5c8affadfed17b57e8cbd112d0b49578e0e2feeb807  release/kernels/sel.by_unit.json.gz
bfbdf6055affcc6f1da5e0ca404d70f0e1ba25424943b4357452b1e5ed16df5c  release/kernels/sel.ccvtrace
5b3b4286e9507ecdeabf9cca08b34736ac1cd8877e948b86d2dc983ee38c314f  release/kernels/sel.log
87f6a81e8afa004c8039bf2f61c90176fcf29ab29bb17ac44aa016a5cc8438fe  release/kernels/sel.oracle.jsonl
3fe8b0f76c60c0569b001a2f465bfc8908024d17d6547e0b561900762688f0d9  release/kernels/sel.sv-hosted.log
e354b9f67bdd0df2e323954e9b8fde3527aef9d0c071149493dc7fec8fb799ff  release/kernels/sized.by_instr.json.gz
03286b1cbebe248f5b9a1210ecf61a5d0184002f10d54d325b99927e67061a17  release/kernels/sized.by_unit.json.gz
7d7b3156291cf98ba08d0d93b5dbbc7f7d1b3bc9b4d7c8cf2ed07ddf408043a5  release/kernels/sized.ccvtrace
735acc469eefa9dc8c30ac20835f876deb7634edb3cf7967d32e64f67a0ed34b  release/kernels/sized.log
36d903ba1618bd1faa437c9812a6ee6c0c966a63196c796267d74bf2695ebc3d  release/kernels/sized.oracle.jsonl
6f14b13edec5e7f9a39370608600fffc7e65cc9e322124eaa4729ffac29a03ab  release/kernels/sized.sv-hosted.log
4f8d5739a2fa817fd35227e23e60c76b77ec6310d5b110e87f5ae6a9f6180e23  release/kernels/slotform.by_instr.json.gz
4b2d9f99544b9feefb64684d49d9739446f8ae2b0e76b6d926cd07d2aa17a85c  release/kernels/slotform.by_unit.json.gz
bca4999deafabda9e24ba5d6f10ffaa5606d1f7062993e6963b4a14026bb40df  release/kernels/slotform.ccvtrace
4e6c84d3a50dabee34cbe6df2881a20f73014e49adecc46aa647c749d5739b6a  release/kernels/slotform.log
8b61db7419b18cea8a646fb628218447e72e84a18a9891ffb73b441736138ab9  release/kernels/slotform.oracle.jsonl
56e6dfc2d31b75191fb3eeba3eb7abf9b1410787e8301a0b53b7cfd0185d45bd  release/kernels/slotform.sv-hosted.log
5efca5ddd17fb4e82158aa84e7da591f25b2802e68decb08538ba26372ac7e9a  release/kernels/spinwait.by_instr.json.gz
4e2ba602b1a48201988e2ae19ae401faaf1faba7ce3d26200f217d2e116b51f3  release/kernels/spinwait.by_unit.json.gz
53849dec78b50d586a2288aaf2ef2ffb67a257378360d999d4c232b28e82f6f6  release/kernels/spinwait.ccvtrace
0b55bcc49600ee90e426ad1abb57afe45798c0040c0fd9336a3a2be9d1a0269f  release/kernels/spinwait.log
868920637236c878b33779bd450439466fc3626996a3164573dc11d437d5c709  release/kernels/spinwait.oracle.jsonl
073b7c7872f1d4b1d307af0d6f1c57a4cd9424770b9be3d88a5d5c195a91154e  release/kernels/spinwait.sv-hosted.log
3e0a324d46544aa06c273996f94f65d34967f4588e6ab34ccf286393d7929f8e  release/kernels/spmbank.by_instr.json.gz
fe9442cd99b05f37030fffc8ef3a69f2e32a2e12376acf22bc0f77db1a9fdf01  release/kernels/spmbank.by_unit.json.gz
c9e0541d73a86ace0be2c7140b58c219c67cdc59ea3c535408d630297cbaaec6  release/kernels/spmbank.ccvtrace
bac9b837b9955a005960fd939687ee56e928371efb73e1db0e9c46d715aad6ac  release/kernels/spmbank.log
3af490cc37d7a92dbe719b57de216b648536eb301ff9d13de9a39f50d150d725  release/kernels/spmbank.oracle.jsonl
13845ee88ed72451d39a09aca042842033cdff0def9faa530aede805b787572c  release/kernels/spmbank.sv-hosted.log
eb7ba5056e78d39186d086b558820049080af612bd8b7d766bda93388418f69c  release/kernels/srd.by_instr.json.gz
10ed341534abf08058c8512380f51001dd87d652da1f9d2b14c61171e933d799  release/kernels/srd.by_unit.json.gz
d238546574b90fbe0c75cbf57797cc2895661a7fe80c064873a7564e05062e66  release/kernels/srd.ccvtrace
8732eeab64418aa8122c1e0b3778dded40625ea3f76c41504d652a511da6a31c  release/kernels/srd.log
b08eb5e3673cac7eebb8b72af5ed3783c8e70a9e96592e76bf3722551bc79473  release/kernels/srd.oracle.jsonl
dc7acf23990e080609e2117a50ec8fe3cb7ad0c33b750bcc84dd0fa2f2afe3de  release/kernels/srd.sv-hosted.log
2af59c8f2db3e0a5bfbd5d386477a9c80342e505212786f497c3a78b49ab404f  release/kernels/stall.by_instr.json.gz
74e25b548be8218752a22ebe72c57470419863039be7d1cfc3d70c432d189067  release/kernels/stall.by_unit.json.gz
c494990d95781e403a11dc1615b4fa16f41b87795a16a0a4511cb9f71ed8d417  release/kernels/stall.ccvtrace
dd9015b08afc16d81bf84a22abadbf7937caed3cba6ce93236486a6ff64abacc  release/kernels/stall.log
500db2c482b07a0706583422cd68878301d0146c1f872ccc1f11bfdcf5c993ef  release/kernels/stall.oracle.jsonl
764ec61de41e93793e97038293c0d82a848e283212f044624dc896fc49838368  release/kernels/stall.sv-hosted.log
f663545c07f0672a0b07c9cecca54e10ef8d9ebf6a0eee7baf7019d3bc61e7fb  release/kernels/swap.by_instr.json.gz
77e2a181d894ea2767192a3878dc7296e959d8d6ee0bc6aa3b264ae5d6032227  release/kernels/swap.by_unit.json.gz
7b0725bde43732d26a656be638f86d7ce1448c757594b8e6778537db9652fbb2  release/kernels/swap.ccvtrace
021bbe850e94cdd0bd575acd95e3c0a756a367359df9009aba9414baa6b3752f  release/kernels/swap.log
3658a26316c1ff7bc1744304a42f736e930fcde2865c8913e6cc67a22ce96667  release/kernels/swap.oracle.jsonl
476607b0c20a64606f4bdc6eb2ee41fbc3a94d1a63e9098bf97a0996760f51a1  release/kernels/swap.sv-hosted.log
e9c5419b173bac8085d7d2594b978a90f7970a7997bf5922f7e1134c279b4b36  release/kernels/transp4.by_instr.json.gz
e70995a13d0307ee0810c58235e19b1fc9b710ace04ef8075b6eeff4823dbed3  release/kernels/transp4.by_unit.json.gz
e40f8be7172257f616cebe3a609bffa593ac8431dee2b99a7c84766f8e5a972d  release/kernels/transp4.ccvtrace
f7157130d0ec429fda7e017698967ffad307265173365c9a53b01d7d647a62e9  release/kernels/transp4.log
06396ace3ac19677fd39c700e408606e5bdbacb24997d663bbe8872e63dd74fc  release/kernels/transp4.oracle.jsonl
cb9a168d16740412659b06f9d21fe65e35a2f049edf1dee34dd0a3eb8535f23b  release/kernels/transp4.sv-hosted.log
b5dd32b2a1c78d137a7421276beae077dc969a09381cfc23a3820204f572175e  release/kernels/unal.by_instr.json.gz
1893b779040c520e7f56d3163fdac585dbd370a64840089a68e29c89aadd1214  release/kernels/unal.by_unit.json.gz
bed38c6948932e9ef926b367d9a71e3ecb42820fe2788472e967e21137d660fc  release/kernels/unal.ccvtrace
987c97fceca2d914408955381fb0e8f809f0251750c45b77c9547fe55256b119  release/kernels/unal.log
c3d484bb160657a563df983d9a2532eac27f556636617960aa1e72183ac2b299  release/kernels/unal.oracle.jsonl
ae157ad126e0944f9e25e00e5c02a4a3b9416b4e3207a11553f72548be101cf2  release/kernels/unal.sv-hosted.log
f1668e57da4c092c8b42b2b86a9ed40990912c8193d0f1026bef89b49e1da49b  release/kernels/vadd.by_instr.json.gz
8e35f62b4021caf8c4b39cc98ab57cf8d6fb516bc8af3cb96f05e90cc0c76c18  release/kernels/vadd.by_unit.json.gz
acd26d8cf606915a4436044898763e8bd6715e04c919701e0f0e0c5581e62ef6  release/kernels/vadd.ccvtrace
04a8c79142c22325a9ca98858eae045e098a911682d0998bf5ffa2ea20fdfb38  release/kernels/vadd.log
0276b6d0611a4bbcdc004ab3987214aea138245bc7217504147331689a9c0880  release/kernels/vadd.oracle.jsonl
1b064be90319572aae4f2fc5cebcc531f2e0c9dd5be3061c995b73a62ad03875  release/kernels/vadd.sv-hosted.log
e1b42794ad4a3cfd7636ea5dd282570ce9fbfa8efc3849f62b88a58981636e5b  release/kernels/vadd4.by_instr.json.gz
1d63c31afef9d143a88e0ca65d5065d6cc2c7acceadd5bd16d8d3a2e0f2e1c2c  release/kernels/vadd4.by_unit.json.gz
71dcc94b28fbfd36359cec958483c6e4fbfd49ec8cd6a13ae3ec523942286ed9  release/kernels/vadd4.ccvtrace
c3ad365e7ec5b5f114927023762c3b13beccd89e1399eb16b334dcda9f0d8c40  release/kernels/vadd4.log
225aa18fc9f38aa9ad615aa11de254337d59fa705877553d873062c68366e0db  release/kernels/vadd4.oracle.jsonl
a71e68be53bc18c5bee5bbe43a318f25eb9170681e564a97c88314e51db46764  release/kernels/vadd4.sv-hosted.log
ecbc47b080d37f90407cea1713809a9d237415a105cd11786142bc24eaa5ad4f  release/kernels/vaddslow.by_instr.json.gz
7d629b9068016aa0d141790c5c85d65650baf1245c2bc28a2e49625592ab21cb  release/kernels/vaddslow.by_unit.json.gz
f2b68db0cbdfc905931b8b63047e9e17f76d5ab8e3de1afbcdc92b6394869340  release/kernels/vaddslow.ccvtrace
5974238c77c7f40505bad1d247baecfdf7514a0ad5a1fc63483b7332f49787c0  release/kernels/vaddslow.log
e9e6218e8b8450e9f9ff6b39d659c994a1e51c527a0c5bd10d18b5658ae0e344  release/kernels/vaddslow.oracle.jsonl
ea788dc2057b4950ec0ccba79f70920d46cf37d2b0000fd4283aa8f6a9935382  release/kernels/vaddslow.sv-hosted.log
fa3392589be098f3af99d62225f23217f6a28b2d16e0d297cefd1d781f7aec39  release/verify.log
56b3d8627d79d397ca06dfb57060015391cb95e52e925d1f09a4b2a7f4147127  release/wiring.txt
```
