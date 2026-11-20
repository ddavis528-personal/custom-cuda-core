# Snapshot snapshot-2026-11-20-723bf64

**A generated, read-only snapshot. Do not edit or merge it.** The source
is `ccr-9eb50716-lecnjf` at `723bf6440def31399a8857efbd081e2e1fb14cbc`, and this branch is rebuilt from source by
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
| Source | `ccr-9eb50716-lecnjf` @ `723bf6440def31399a8857efbd081e2e1fb14cbc` |
| Built | 2026-11-20 (UTC) |
| Gate | `tools/verify.sh`: PASS |
| Compiler snapshot | custom-cuda-complier `release` @ `a293afe7d7873fb5d3fac70d8deca980e119b19f` (source `b9ae2c9d5d3b838d5d982d842b558e2d290185ea`) |
| Verilator | Verilator 5.052 2026-09-05 rev v5.052 |
| Icarus | Icarus Verilog version 12.0 (stable) () |
| Yosys | Yosys 0.33 (git sha1 2584903a060) |

## Kernels

| Kernel | Result |
|---|---|
| `addrhigh` | `name=addrhigh finished=1 cycles=83 from_fetch=52 retired=5 issue_groups=6 order=ok gpr_mismatch=0 pred_mismatch=0 mem_mismatch=0 check_failures=0 class_violations=0 overflows=0 credit_leaks=0 cor_late=0 channels_used=26/56 violations=0` |
| `addrlimit` | `name=addrlimit finished=1 cycles=1072 from_fetch=1041 retired=5 issue_groups=5 order=ok gpr_mismatch=0 pred_mismatch=0 mem_mismatch=0 check_failures=0 class_violations=0 overflows=0 credit_leaks=0 cor_late=0 channels_used=27/56 violations=0` |
| `addrneg` | `name=addrneg finished=1 cycles=81 from_fetch=50 retired=1 issue_groups=2 order=ok gpr_mismatch=0 pred_mismatch=0 mem_mismatch=0 check_failures=0 class_violations=0 overflows=0 credit_leaks=0 cor_late=0 channels_used=23/56 violations=0` |
| `atom` | `name=atom finished=1 cycles=8732 from_fetch=8701 retired=29 issue_groups=29 order=ok gpr_mismatch=0 pred_mismatch=0 mem_mismatch=0 check_failures=0 class_violations=0 overflows=0 credit_leaks=0 cor_late=0 channels_used=32/56 violations=0` |
| `atomf` | `name=atomf finished=1 cycles=4640 from_fetch=4609 retired=12 issue_groups=12 order=ok gpr_mismatch=0 pred_mismatch=0 mem_mismatch=0 check_failures=0 class_violations=0 overflows=0 credit_leaks=0 cor_late=0 channels_used=34/56 violations=0` |
| `borrow` | `name=borrow finished=1 cycles=99 from_fetch=68 retired=7 issue_groups=7 order=ok gpr_mismatch=0 pred_mismatch=0 mem_mismatch=0 check_failures=0 class_violations=0 overflows=0 credit_leaks=0 cor_late=0 channels_used=21/56 violations=0` |
| `brs` | `name=brs finished=1 cycles=99 from_fetch=68 retired=12 issue_groups=12 order=ok gpr_mismatch=0 pred_mismatch=0 mem_mismatch=0 check_failures=0 class_violations=0 overflows=0 credit_leaks=0 cor_late=0 channels_used=23/56 violations=0` |
| `byp` | `name=byp finished=1 cycles=118 from_fetch=87 retired=14 issue_groups=14 order=ok gpr_mismatch=0 pred_mismatch=0 mem_mismatch=0 check_failures=0 class_violations=0 overflows=0 credit_leaks=0 cor_late=0 channels_used=31/56 violations=0` |
| `callret` | `name=callret finished=1 cycles=265 from_fetch=234 retired=40 issue_groups=40 order=ok gpr_mismatch=0 pred_mismatch=0 mem_mismatch=0 check_failures=0 class_violations=0 overflows=0 credit_leaks=0 cor_late=0 channels_used=30/56 violations=0` |
| `cas` | `name=cas finished=1 cycles=6972 from_fetch=6941 retired=56 issue_groups=56 order=ok gpr_mismatch=0 pred_mismatch=0 mem_mismatch=0 check_failures=0 class_violations=0 overflows=0 credit_leaks=0 cor_late=0 channels_used=32/56 violations=0` |
| `chains` | `name=chains finished=1 cycles=96 from_fetch=65 retired=29 issue_groups=29 order=ok gpr_mismatch=0 pred_mismatch=0 mem_mismatch=0 check_failures=0 class_violations=0 overflows=0 credit_leaks=0 cor_late=0 channels_used=21/56 violations=0` |
| `coll` | `name=coll finished=1 cycles=78 from_fetch=47 retired=24 issue_groups=24 order=ok gpr_mismatch=0 pred_mismatch=0 mem_mismatch=0 check_failures=0 class_violations=0 overflows=0 credit_leaks=0 cor_late=0 channels_used=21/56 violations=0` |
| `div` | `name=div finished=1 cycles=978 from_fetch=947 retired=144 issue_groups=144 order=ok gpr_mismatch=0 pred_mismatch=0 mem_mismatch=0 check_failures=0 class_violations=0 overflows=0 credit_leaks=0 cor_late=0 channels_used=23/56 violations=0` |
| `divchw` | `name=divchw finished=1 cycles=111 from_fetch=80 retired=5 issue_groups=6 order=ok gpr_mismatch=0 pred_mismatch=0 mem_mismatch=0 check_failures=0 class_violations=0 overflows=0 credit_leaks=0 cor_late=0 channels_used=22/56 violations=0` |
| `divtail` | `name=divtail finished=1 cycles=642 from_fetch=611 retired=96 issue_groups=96 order=ok gpr_mismatch=0 pred_mismatch=0 mem_mismatch=0 check_failures=0 class_violations=0 overflows=0 credit_leaks=0 cor_late=0 channels_used=23/56 violations=0` |
| `divtail2` | `name=divtail2 finished=1 cycles=1517 from_fetch=1486 retired=366 issue_groups=366 order=ok gpr_mismatch=0 pred_mismatch=0 mem_mismatch=0 check_failures=0 class_violations=0 overflows=0 credit_leaks=0 cor_late=0 channels_used=23/56 violations=0` |
| `fence` | `name=fence finished=1 cycles=83 from_fetch=52 retired=7 issue_groups=7 order=ok gpr_mismatch=0 pred_mismatch=0 mem_mismatch=0 check_failures=0 class_violations=0 overflows=0 credit_leaks=0 cor_late=0 channels_used=30/56 violations=0` |
| `gather` | `name=gather finished=1 cycles=265 from_fetch=234 retired=16 issue_groups=16 order=ok gpr_mismatch=0 pred_mismatch=0 mem_mismatch=0 check_failures=0 class_violations=0 overflows=0 credit_leaks=0 cor_late=0 channels_used=32/56 violations=0` |
| `hit` | `name=hit finished=1 cycles=219 from_fetch=188 retired=17 issue_groups=17 order=ok gpr_mismatch=0 pred_mismatch=0 mem_mismatch=0 check_failures=0 class_violations=0 overflows=0 credit_leaks=0 cor_late=0 channels_used=31/56 violations=0` |
| `lanectx` | `name=lanectx finished=1 cycles=70 from_fetch=39 retired=10 issue_groups=10 order=ok gpr_mismatch=0 pred_mismatch=0 mem_mismatch=0 check_failures=0 class_violations=0 overflows=0 credit_leaks=0 cor_late=0 channels_used=29/56 violations=0` |
| `lanectx2` | `name=lanectx2 finished=1 cycles=70 from_fetch=39 retired=10 issue_groups=10 order=ok gpr_mismatch=0 pred_mismatch=0 mem_mismatch=0 check_failures=0 class_violations=0 overflows=0 credit_leaks=0 cor_late=0 channels_used=29/56 violations=0` |
| `late` | `name=late finished=1 cycles=169 from_fetch=138 retired=16 issue_groups=16 order=ok gpr_mismatch=0 pred_mismatch=0 mem_mismatch=0 check_failures=0 class_violations=0 overflows=0 credit_leaks=0 cor_late=0 channels_used=31/56 violations=0` |
| `ldpar` | `name=ldpar finished=1 cycles=154 from_fetch=123 retired=17 issue_groups=17 order=ok gpr_mismatch=0 pred_mismatch=0 mem_mismatch=0 check_failures=0 class_violations=0 overflows=0 credit_leaks=0 cor_late=0 channels_used=31/56 violations=0` |
| `lnorm1` | `name=lnorm1 finished=1 cycles=2531 from_fetch=2500 retired=526 issue_groups=526 order=ok gpr_mismatch=0 pred_mismatch=0 mem_mismatch=0 check_failures=0 class_violations=0 overflows=0 credit_leaks=0 cor_late=0 channels_used=37/56 violations=0` |
| `localsp` | `name=localsp finished=1 cycles=2175 from_fetch=2144 retired=40 issue_groups=40 order=ok gpr_mismatch=0 pred_mismatch=0 mem_mismatch=0 check_failures=0 class_violations=0 overflows=0 credit_leaks=0 cor_late=0 channels_used=31/56 violations=0` |
| `loop` | `name=loop finished=1 cycles=2842 from_fetch=2811 retired=407 issue_groups=407 order=ok gpr_mismatch=0 pred_mismatch=0 mem_mismatch=0 check_failures=0 class_violations=0 overflows=0 credit_leaks=0 cor_late=0 channels_used=23/56 violations=0` |
| `merge` | `name=merge finished=1 cycles=71 from_fetch=40 retired=9 issue_groups=9 order=ok gpr_mismatch=0 pred_mismatch=0 mem_mismatch=0 check_failures=0 class_violations=0 overflows=0 credit_leaks=0 cor_late=0 channels_used=21/56 violations=0` |
| `missrun` | `name=missrun finished=1 cycles=121 from_fetch=90 retired=28 issue_groups=28 order=ok gpr_mismatch=0 pred_mismatch=0 mem_mismatch=0 check_failures=0 class_violations=0 overflows=0 credit_leaks=0 cor_late=0 channels_used=31/56 violations=0` |
| `mload` | `name=mload finished=1 cycles=111 from_fetch=80 retired=11 issue_groups=11 order=ok gpr_mismatch=0 pred_mismatch=0 mem_mismatch=0 check_failures=0 class_violations=0 overflows=0 credit_leaks=0 cor_late=0 channels_used=31/56 violations=0` |
| `mlp` | `name=mlp finished=1 cycles=126 from_fetch=95 retired=21 issue_groups=21 order=ok gpr_mismatch=0 pred_mismatch=0 mem_mismatch=0 check_failures=0 class_violations=0 overflows=0 credit_leaks=0 cor_late=0 channels_used=31/56 violations=0` |
| `mwmiss` | `name=mwmiss finished=1 cycles=129 from_fetch=98 retired=88 issue_groups=88 order=ok gpr_mismatch=0 pred_mismatch=0 mem_mismatch=0 check_failures=0 class_violations=0 overflows=0 credit_leaks=0 cor_late=0 channels_used=31/56 violations=0` |
| `narrowadd` | `name=narrowadd finished=1 cycles=227 from_fetch=196 retired=21 issue_groups=21 order=ok gpr_mismatch=0 pred_mismatch=0 mem_mismatch=0 check_failures=0 class_violations=0 overflows=0 credit_leaks=0 cor_late=0 channels_used=32/56 violations=0` |
| `pguard` | `name=pguard finished=1 cycles=87 from_fetch=56 retired=12 issue_groups=12 order=ok gpr_mismatch=0 pred_mismatch=0 mem_mismatch=0 check_failures=0 class_violations=0 overflows=0 credit_leaks=0 cor_late=0 channels_used=29/56 violations=0` |
| `plog` | `name=plog finished=1 cycles=71 from_fetch=40 retired=11 issue_groups=11 order=ok gpr_mismatch=0 pred_mismatch=0 mem_mismatch=0 check_failures=0 class_violations=0 overflows=0 credit_leaks=0 cor_late=0 channels_used=21/56 violations=0` |
| `pmovdiv` | `name=pmovdiv finished=1 cycles=104 from_fetch=73 retired=12 issue_groups=12 order=ok gpr_mismatch=0 pred_mismatch=0 mem_mismatch=0 check_failures=0 class_violations=0 overflows=0 credit_leaks=0 cor_late=0 channels_used=22/56 violations=0` |
| `predlane` | `name=predlane finished=1 cycles=928 from_fetch=897 retired=10 issue_groups=10 order=ok gpr_mismatch=0 pred_mismatch=0 mem_mismatch=0 check_failures=0 class_violations=0 overflows=0 credit_leaks=0 cor_late=0 channels_used=31/56 violations=0` |
| `predmerge` | `name=predmerge finished=1 cycles=940 from_fetch=909 retired=9 issue_groups=9 order=ok gpr_mismatch=0 pred_mismatch=0 mem_mismatch=0 check_failures=0 class_violations=0 overflows=0 credit_leaks=0 cor_late=0 channels_used=33/56 violations=0` |
| `predspill` | `name=predspill finished=1 cycles=968 from_fetch=937 retired=12 issue_groups=12 order=ok gpr_mismatch=0 pred_mismatch=0 mem_mismatch=0 check_failures=0 class_violations=0 overflows=0 credit_leaks=0 cor_late=0 channels_used=31/56 violations=0` |
| `predswap` | `name=predswap finished=1 cycles=1186 from_fetch=1155 retired=46 issue_groups=46 order=ok gpr_mismatch=0 pred_mismatch=0 mem_mismatch=0 check_failures=0 class_violations=0 overflows=0 credit_leaks=0 cor_late=0 channels_used=33/56 violations=0` |
| `privwin` | `name=privwin finished=1 cycles=1161 from_fetch=1130 retired=52 issue_groups=52 order=ok gpr_mismatch=0 pred_mismatch=0 mem_mismatch=0 check_failures=0 class_violations=0 overflows=0 credit_leaks=0 cor_late=0 channels_used=34/56 violations=0` |
| `provswap` | `name=provswap finished=1 cycles=2286 from_fetch=2255 retired=978 issue_groups=978 order=ok gpr_mismatch=0 pred_mismatch=0 mem_mismatch=0 check_failures=0 class_violations=0 overflows=0 credit_leaks=0 cor_late=0 channels_used=33/56 violations=0` |
| `retmiss` | `name=retmiss finished=1 cycles=184 from_fetch=153 retired=19 issue_groups=19 order=ok gpr_mismatch=0 pred_mismatch=0 mem_mismatch=0 check_failures=0 class_violations=0 overflows=0 credit_leaks=0 cor_late=0 channels_used=33/56 violations=0` |
| `roconst` | `name=roconst finished=1 cycles=76 from_fetch=45 retired=4 issue_groups=5 order=ok gpr_mismatch=0 pred_mismatch=0 mem_mismatch=0 check_failures=0 class_violations=0 overflows=0 credit_leaks=0 cor_late=0 channels_used=26/56 violations=0` |
| `rogated` | `name=rogated finished=1 cycles=96 from_fetch=65 retired=7 issue_groups=8 order=ok gpr_mismatch=0 pred_mismatch=0 mem_mismatch=0 check_failures=0 class_violations=0 overflows=0 credit_leaks=0 cor_late=0 channels_used=26/56 violations=0` |
| `rokill` | `name=rokill finished=1 cycles=104 from_fetch=73 retired=41 issue_groups=4536 order=ok gpr_mismatch=0 pred_mismatch=0 mem_mismatch=0 check_failures=0 class_violations=0 overflows=0 credit_leaks=0 cor_late=0 channels_used=27/56 violations=0` |
| `rokilllane` | `name=rokilllane finished=1 cycles=1214 from_fetch=1183 retired=924 issue_groups=10674 order=ok gpr_mismatch=0 pred_mismatch=0 mem_mismatch=0 check_failures=0 class_violations=0 overflows=0 credit_leaks=0 cor_late=0 channels_used=27/56 violations=0` |
| `rolaunch` | `name=rolaunch finished=1 cycles=74 from_fetch=43 retired=4 issue_groups=5 order=ok gpr_mismatch=0 pred_mismatch=0 mem_mismatch=0 check_failures=0 class_violations=0 overflows=0 credit_leaks=0 cor_late=0 channels_used=24/56 violations=0` |
| `rolimit` | `name=rolimit finished=1 cycles=76 from_fetch=45 retired=4 issue_groups=5 order=ok gpr_mismatch=0 pred_mismatch=0 mem_mismatch=0 check_failures=0 class_violations=0 overflows=0 credit_leaks=0 cor_late=0 channels_used=26/56 violations=0` |
| `roload` | `name=roload finished=1 cycles=105 from_fetch=74 retired=8 issue_groups=8 order=ok gpr_mismatch=0 pred_mismatch=0 mem_mismatch=0 check_failures=0 class_violations=0 overflows=0 credit_leaks=0 cor_late=0 channels_used=31/56 violations=0` |
| `rope` | `name=rope finished=1 cycles=677 from_fetch=646 retired=354 issue_groups=354 order=ok gpr_mismatch=0 pred_mismatch=0 mem_mismatch=0 check_failures=0 class_violations=0 overflows=0 credit_leaks=0 cor_late=0 channels_used=34/56 violations=0` |
| `ropediv` | `name=ropediv finished=1 cycles=982 from_fetch=951 retired=203 issue_groups=203 order=ok gpr_mismatch=0 pred_mismatch=0 mem_mismatch=0 check_failures=0 class_violations=0 overflows=0 credit_leaks=0 cor_late=0 channels_used=34/56 violations=0` |
| `sel` | `name=sel finished=1 cycles=77 from_fetch=46 retired=8 issue_groups=8 order=ok gpr_mismatch=0 pred_mismatch=0 mem_mismatch=0 check_failures=0 class_violations=0 overflows=0 credit_leaks=0 cor_late=0 channels_used=29/56 violations=0` |
| `sized` | `name=sized finished=1 cycles=987 from_fetch=956 retired=25 issue_groups=25 order=ok gpr_mismatch=0 pred_mismatch=0 mem_mismatch=0 check_failures=0 class_violations=0 overflows=0 credit_leaks=0 cor_late=0 channels_used=32/56 violations=0` |
| `slotform` | `name=slotform finished=1 cycles=4350 from_fetch=4319 retired=12 issue_groups=12 order=ok gpr_mismatch=0 pred_mismatch=0 mem_mismatch=0 check_failures=0 class_violations=0 overflows=0 credit_leaks=0 cor_late=0 channels_used=32/56 violations=0` |
| `spinwait` | `name=spinwait finished=1 cycles=2022 from_fetch=1991 retired=211 issue_groups=211 order=ok gpr_mismatch=0 pred_mismatch=0 mem_mismatch=0 check_failures=0 class_violations=0 overflows=0 credit_leaks=0 cor_late=0 channels_used=34/56 violations=0` |
| `spmbank` | `name=spmbank finished=1 cycles=186 from_fetch=155 retired=13 issue_groups=13 order=ok gpr_mismatch=0 pred_mismatch=0 mem_mismatch=0 check_failures=0 class_violations=0 overflows=0 credit_leaks=0 cor_late=0 channels_used=28/56 violations=0` |
| `srd` | `name=srd finished=1 cycles=70 from_fetch=39 retired=6 issue_groups=6 order=ok gpr_mismatch=0 pred_mismatch=0 mem_mismatch=0 check_failures=0 class_violations=0 overflows=0 credit_leaks=0 cor_late=0 channels_used=29/56 violations=0` |
| `stall` | `name=stall finished=1 cycles=556 from_fetch=525 retired=116 issue_groups=116 order=ok gpr_mismatch=0 pred_mismatch=0 mem_mismatch=0 check_failures=0 class_violations=0 overflows=0 credit_leaks=0 cor_late=0 channels_used=31/56 violations=0` |
| `swap` | `name=swap finished=1 cycles=556 from_fetch=525 retired=174 issue_groups=174 order=ok gpr_mismatch=0 pred_mismatch=0 mem_mismatch=0 check_failures=0 class_violations=0 overflows=0 credit_leaks=0 cor_late=0 channels_used=31/56 violations=0` |
| `transp4` | `name=transp4 finished=1 cycles=1133 from_fetch=1102 retired=976 issue_groups=976 order=ok gpr_mismatch=0 pred_mismatch=0 mem_mismatch=0 check_failures=0 class_violations=0 overflows=0 credit_leaks=0 cor_late=0 channels_used=37/56 violations=0` |
| `unal` | `name=unal finished=1 cycles=137 from_fetch=106 retired=9 issue_groups=9 order=ok gpr_mismatch=0 pred_mismatch=0 mem_mismatch=0 check_failures=0 class_violations=0 overflows=0 credit_leaks=0 cor_late=0 channels_used=32/56 violations=0` |
| `vadd` | `name=vadd finished=1 cycles=158 from_fetch=127 retired=17 issue_groups=17 order=ok gpr_mismatch=0 pred_mismatch=0 mem_mismatch=0 check_failures=0 class_violations=0 overflows=0 credit_leaks=0 cor_late=0 channels_used=33/56 violations=0` |
| `vadd4` | `name=vadd4 finished=1 cycles=204 from_fetch=173 retired=68 issue_groups=68 order=ok gpr_mismatch=0 pred_mismatch=0 mem_mismatch=0 check_failures=0 class_violations=0 overflows=0 credit_leaks=0 cor_late=0 channels_used=33/56 violations=0` |
| `vaddslow` | `name=vaddslow finished=1 cycles=547 from_fetch=516 retired=17 issue_groups=17 order=ok gpr_mismatch=0 pred_mismatch=0 mem_mismatch=0 check_failures=0 class_violations=0 overflows=0 credit_leaks=0 cor_late=0 channels_used=33/56 violations=0` |

## Manifest of release/

```
596f77a091b129d76fcd4b9d93ff3a99d7ecd8151f9807da364dd0c3c1a22936  release/kernels/addrhigh.by_instr.json.gz
f4b9434a590de688466bbe5be7d0bcd44e19672aa542b406508224e43eaebfde  release/kernels/addrhigh.by_unit.json.gz
4dac1317d6fd6a40770d4e703058827a4e591e1673c43c6fd30755d00d10825f  release/kernels/addrhigh.ccvtrace
fa46bcd9a5088f228c969cfec9304f17afeebc4a33daa9677f827592d3a2236b  release/kernels/addrhigh.log
569f2e22883fad5f0956c57ec734e6afbdd4b8a854e50277425172d6c0cbd766  release/kernels/addrhigh.oracle.jsonl
91504b31624a9241c447f9ee1573a4f11d7bf78e122f5af83d636afc9e05c466  release/kernels/addrhigh.sv-hosted.log
5a8a04498f620c64d134e6e0d01e8db1cae0cedd41b9d7b57b83ff23877c4dcd  release/kernels/addrlimit.by_instr.json
761a3abeeebc4495d5de7c453b33f8234654d922c8669085185e010356412e8d  release/kernels/addrlimit.by_unit.json
a53be191c4e9c5a3a90b0569d777cfc0d4974f156e702139cd0a3cbe5e4a5045  release/kernels/addrlimit.ccvtrace
038288f91c887f83d2f9576cf5ac5acaa87bdcebfefb77275c2021b8b7352f0d  release/kernels/addrlimit.log
bc660b0b40359a2c5a2478cb0eb4950b73fd22db50ea76b80052bc195a1920f4  release/kernels/addrlimit.oracle.jsonl
0765bb71ce62eb4264fdd9a314a85eb79d6cb422da4bc4d15ff7dc0727368f12  release/kernels/addrlimit.sv-hosted.log
d5ee993d0a633a3a0837df8a1267138a4a90d71b0f13f2964db1fac129be4751  release/kernels/addrneg.by_instr.json
104adae31ce78cc2cbcccb238d2e68f6944a9e3a7d1009f4c3a2eaca0df41bc4  release/kernels/addrneg.by_unit.json
0446b0e2d2af5b36c5a5ea6f83f1deb34ff1fd1fa93229fd0e9aab5274ba454e  release/kernels/addrneg.ccvtrace
0857bc896422ea13b682599b6e1bf53a7997598fef7f3ec30f6570ddb5f991e7  release/kernels/addrneg.log
16f5b0707ae44492a1efd67bb9dd38a7e79a7bbd354fa9207b9e7d150ff2f107  release/kernels/addrneg.oracle.jsonl
cb6bd712ea9e3184577e3c81fedf8e270cf5996f57e61d73b7e4d72c7db8fce9  release/kernels/addrneg.sv-hosted.log
967bafad0091da80878fbf5a53d288e17c5386a809790c2184d32c9fc9a99d1a  release/kernels/atom.by_instr.json.gz
2fc57bc37b8da8076e12c6fcab60edad828d56eac5662830bd56a9282d71260b  release/kernels/atom.by_unit.json.gz
0efec9401f542375a590011cc55578411be218ed9a6aa16ed4e2cff66f5f5352  release/kernels/atom.ccvtrace
27dc40204949f50266417ec2c20e5cf88ae6874bfc86cd3982d836d89a622a8c  release/kernels/atom.log
504f5b6e9d25114dc35f2c70b21bb7b3f3c508c691de12dc0e87d12a74285361  release/kernels/atom.oracle.jsonl
844482334fd550519941e52cc482c31b8bde14c8aaf7b51b9e46259f67213ecb  release/kernels/atom.sv-hosted.log
24949a3685d9b2ec67661daf099937e154d2247fe4228a89fbe065a8417bcbd2  release/kernels/atomf.by_instr.json.gz
f8f0852e08c10494c802395e9cb09be84d625025899a27787d34be462855a831  release/kernels/atomf.by_unit.json.gz
35585bbd0deab31f1d8022e6ca44de0a62c59364d9524eb19562473c7e745908  release/kernels/atomf.ccvtrace
3be17514f8af420be71f711aac95ffdd7cd90e85597225e55834b6985cd31053  release/kernels/atomf.log
cfd1179edf4061a33ab2f75d7a6dec61decfe629000198189a7bfc2647b34238  release/kernels/atomf.oracle.jsonl
41c4106db34d038abff3cc05e3de33c8bab404a35e4a1b551f5efebc6dee66cd  release/kernels/atomf.sv-hosted.log
c1163458bd9385a8a3637bf891328c09635b2e91f13a194f8a638901a062cf47  release/kernels/borrow.by_instr.json.gz
32e360d36513a2c3d9694de907f4138c6b3a26862b805b82a30ac4fc28aec75f  release/kernels/borrow.by_unit.json.gz
675e87f1c0e15b984bee253fff4849e79de6b07f83e6e28edfa102cf07f93b18  release/kernels/borrow.ccvtrace
f500343e555384b26a8c3fc102eb7bf952853a9a39632783e31f00834aa9d141  release/kernels/borrow.log
4c565e1ce0b3baee36e158694b32c8defb5cd662b2f9af75cb5d8c26cb1168ed  release/kernels/borrow.oracle.jsonl
41a59548c2a344e7794aff3a5db78e0ed0a251c1493a77c13d643616cb81f707  release/kernels/borrow.sv-hosted.log
6d65f789851986168d8770e33b91a79d45a2cb9c94f016e69a9a2516ea08cc17  release/kernels/brs.by_instr.json.gz
84b4eaf32c88f29c2b57d21ee4fcf9b54338a752f93ce92c5826d7082cf3bfa8  release/kernels/brs.by_unit.json.gz
dfdc00e3f7e638e036c8544c04704d8c1d4cca764d189ea7aa1e0739036dbfac  release/kernels/brs.ccvtrace
9f25c640fdc5b0622626b9bc3638e49831755ee9dec3b8870c4dac09481171e6  release/kernels/brs.log
e3c1cb3379580cf1aae44e8ddc8e846ef6fd661a573cfe0a8d4444b18a14dc56  release/kernels/brs.oracle.jsonl
d15b19032a88f465a3f5367862f87652099edd7b9fad2787ef33298289af8b9f  release/kernels/brs.sv-hosted.log
bdf3a738268acbbca0c66649e2dbbedfb69e29693b866ef17db76d3a2f86c10b  release/kernels/byp.by_instr.json.gz
c37b0c7c5fde440f0a2b6a9058ded1528458d75cbe7dcb879c0120c3f7cd5fa9  release/kernels/byp.by_unit.json.gz
7854d91e6d95d752645f7e735dcc1e962a38d1bb09ec6fb48206a278bbb3e2b3  release/kernels/byp.ccvtrace
3ecc9c08f7cfde2a0f6b8ee1f2a1952f59f35822cba4f8969e86a430e7e2031f  release/kernels/byp.log
5a03dfa4f3603fef49f1e3639e74e34152ca3ca5ef8e41eb959f8323040fa2d5  release/kernels/byp.oracle.jsonl
bc64909b745c51f6a359477a24d7df42c66fd6381220d9c0bb5d4f5752b8b8f0  release/kernels/byp.sv-hosted.log
eca3da33f8f8f6077aab2d039fb751e6435a7cccd7de4eec0a1e9706aa17d734  release/kernels/callret.by_instr.json.gz
44cd9e0655da254e285679a532da39c2400ecb7ad6d151aca4bfa849700efab5  release/kernels/callret.by_unit.json.gz
504e99d94b3e643cfd5ebe2a52859ea41ad8f70b9e4e4cf9b67c7951146680a3  release/kernels/callret.ccvtrace
aefd8eaf1e669bbff782b3744a6bbafac19388c63b48f852a6b15fbd7d8ff3ca  release/kernels/callret.log
9b1d1b50b527f732362f837250aa2f26dabf3e76e16a4794856ebd8f105635b8  release/kernels/callret.oracle.jsonl
0a57a943bc6637cb61101f8223ebc2623796a64e7c3c88196bd52c231636981b  release/kernels/callret.sv-hosted.log
a4e262ed5774f003c9a3584433da11b227a66fd4618ccee1a31d2ad394bf37e3  release/kernels/cas.by_instr.json.gz
50d0b01d08da4d4b1e889c73a1349c53967298fdfe472e52adf687fb419c50f0  release/kernels/cas.by_unit.json.gz
1893b3c82dc7c02406c7199cfffb3adfc635b66ebd3b96d501e6cc36847f41e5  release/kernels/cas.ccvtrace
39ec35d29a1c9715bccdb97a259919de9598f7c2b9e51249d1426cbe7da9055e  release/kernels/cas.log
0ab31a9443336fe5d08e1a5fa5fcba3bc279b19022f7c5007908d39d8ef39536  release/kernels/cas.oracle.jsonl
faf977bc7bf8d377c9b510c92ad700feb7ee900adbf22125cd85ae36480f239b  release/kernels/cas.sv-hosted.log
5f4004869f52eed9d1a25a30593dd3b7d58bf677d77444a9473814b1b6f3c900  release/kernels/chains.by_instr.json.gz
9b82f937ff9f4f36b3e6074f7560915dceb294177dc7dbf2768e1d76fbb984a3  release/kernels/chains.by_unit.json.gz
f3c7f719a83f93768af61373514062f1b4654c87caae7a6fd23d0307b7b7ca0d  release/kernels/chains.ccvtrace
1071a08f47b9278b831b63fd5c105b61c5dca451f9473f488a453351fd63b419  release/kernels/chains.log
26a4cc5c5524c7219d8706c2582c80357dea60be9d6ffdec99dac7d0365e2264  release/kernels/chains.oracle.jsonl
6aec79c5b477eed734c30e4633ac8c0cabcb639f552dacfa58f20be8d449fb4c  release/kernels/chains.sv-hosted.log
297dd786b78e4dc057c81fd76facee5a888850af36c5fcee4b2362c389798bdc  release/kernels/coll.by_instr.json.gz
2aee0e9dd1012a0b51c81241210085a5b5d9e06cda2cc9f0f35f3c85f81a1ebc  release/kernels/coll.by_unit.json.gz
b9d0aa1fba37d6865c6e65310ddfdec12b1a406436489ff0c4ce6a811c10cdbf  release/kernels/coll.ccvtrace
285cefd4c50fdbc81824e4b65d29164d2590be9af0411b25455e69fdc96dc914  release/kernels/coll.log
dd718d23c88df5dc7d92b055d8542865aa0e029118486af127312a8a578cfcbc  release/kernels/coll.oracle.jsonl
40f49e2f18bbca3331dbfc60f5540c1eb7be5bb11cf2631473121048ad040f71  release/kernels/coll.sv-hosted.log
d40b5cd72df7db5999166fe8cd022e786bc3f018e9bd6721040bead1b69e93d8  release/kernels/div.by_instr.json.gz
72005770318b76654b43907075121b11c4b99e1e70480e07663141e2de74de68  release/kernels/div.by_unit.json.gz
0fa59319a49569c81f33bc11b669b5cff44d54af88e0e1a0318682d79a62911e  release/kernels/div.ccvtrace
81615197f54ed6b269be92b506e7362398b4fa8a683d072efd1f36b07d7a92aa  release/kernels/div.log
71a567b85cf85622631490187563de9a5661099c78a590adff4ed0a0c3d24c16  release/kernels/div.oracle.jsonl
49164c14d4d2c77c2f5ab6dab47bec1228bffa333e77ca066ab40f3a6d43821b  release/kernels/div.sv-hosted.log
dfcefb92e90d78b360e7142b6763e1b01e7c70f383c63398b8a17f3eff4e95dc  release/kernels/divchw.by_instr.json.gz
332784504a5babeac9863a44774bf57b8033e31c62057c159052b3e1a1ca07e5  release/kernels/divchw.by_unit.json.gz
8e7c80075a58e2178ec583e92431374c169c69d30bb59740a5b1c545673b781a  release/kernels/divchw.ccvtrace
997142462f2c25c12d713636ea7832bf4332c9f3cb56cac3d739b17e91c23a03  release/kernels/divchw.log
58a541797f7a2df0a1c7528ae6a3edec212db90c7d3eb20656806f38b5c10b3d  release/kernels/divchw.oracle.jsonl
9139544152b2e42b37262b5151bdd1f703b2155c116783a355f16bceb44c8ed1  release/kernels/divchw.sv-hosted.log
31951d1bc6562c25974b6b278d5d0ecb109a6548d34f36085983bbc578f6b721  release/kernels/divtail.by_instr.json.gz
d5e561da003148e738ffaa0fd1af9751fdb970d5ed3ca6cc083bff28b38b6e78  release/kernels/divtail.by_unit.json.gz
db804fbb5ad528ab14845763f37b3761a0b667c3bab40606320e4d62853ca751  release/kernels/divtail.ccvtrace
31e67bf14a0bb05d7220ebedd87360f548ffb9d319b8b9babaccaa3194a8838c  release/kernels/divtail.log
75f11a75c9b3b336e446140af4579f05b46c363a76b7aab3ec88154a07ba097d  release/kernels/divtail.oracle.jsonl
d31cea6546dfcadb24cb2b33b0df03c3b28f528516214b01b6c5b42a7aeaeb97  release/kernels/divtail.sv-hosted.log
f62e5a7b4cbb8541b7bef07942321cf34d2c9ecee9ab931532c5653f231c6634  release/kernels/divtail2.by_instr.json.gz
3c80ad3908628bab8aa9949e44289fd4b39b05a839bba9fabe59e7ad64885c64  release/kernels/divtail2.by_unit.json.gz
a75fe12547373cd47764249a890c8e2cff1203790b37cff1678beeeb1c5b2c44  release/kernels/divtail2.ccvtrace
0695ddbf13a2be63bcb5b8469e479d029efb3becbade6b06837af876d5671ed9  release/kernels/divtail2.log
b2db6b05eb6cf4a0a7677e31d0c6c2952d5cab49d353f0bb1883fe0b2a20ed14  release/kernels/divtail2.oracle.jsonl
7c1f58d8cf7624ee9a57e089fe3ac37d010fb7e13a6ae1a089a74c2acc3f731f  release/kernels/divtail2.sv-hosted.log
05486780da0b81de104065f943e5b0638beb06bf879319a1fca9513e577806d4  release/kernels/fence.by_instr.json
f4172a0f32465312e809120f6e614480483a3e668a1dfce4fd30219cf2add94b  release/kernels/fence.by_unit.json.gz
4bbbc9787ee5f29e98ad0c7908f70e6a6b6e4343c3e9b31c9a2bb7800310a3fc  release/kernels/fence.ccvtrace
d5c151eba49a8a9fd2bcaed529c99bf9712f0eb060c7d79f0647be940d8112a5  release/kernels/fence.log
d1d40317f6cf5bfb430cda1f9c0ef676609e59cabe2a11623c42ffbeca93142b  release/kernels/fence.oracle.jsonl
01eedf47bc33eb419b8fc2fcaaa97d4290115128913ab8f01e5ad3658649f447  release/kernels/fence.sv-hosted.log
71cef2789da301cf3b01cd3b2cc6450ed9aeebd7281d79a6b41d58886e7b8d95  release/kernels/gather.by_instr.json.gz
3c087210bb770961a6c2dcd3721e0e96c47645f1f3f33aa5d87307cf41a115f2  release/kernels/gather.by_unit.json.gz
c5bd60bc143ef04b1753cc3f90ffa792a0973077cbbb702413053a2365fba7e9  release/kernels/gather.ccvtrace
d5194010aea10c4dd169c8348a2c07fac2461c72f203f854cd46f09f26e369bc  release/kernels/gather.log
0413e781d8d6ff578c64eb1f800b7931e66f676d5cdabb97b94a4033e6037662  release/kernels/gather.oracle.jsonl
7f3c4eb76e0b6f3fa28bc6f74b822ff24dfcb36b33cb3b51ac19cf22c2686a90  release/kernels/gather.sv-hosted.log
84a0e365fa80dffa546038656ee86c7000b1a18bc945ef580651c45fedd2f712  release/kernels/hit.by_instr.json.gz
416629e8e99454d5089e8a81a872a7d2961eaa7217a1dd89a612be3264718b03  release/kernels/hit.by_unit.json.gz
0dc38e18c8017b5df9c1e13f492952b8a32856a50ca7c93e09588648ac8ba525  release/kernels/hit.ccvtrace
1fc44bf0be1fd389e457d8ccea383e1301e8a003d164ee37e68cf0ee33b5f113  release/kernels/hit.log
7ba9603e0088d9164de6528f16ef6a7fa9ce5821c8c12b52cbb3734e39b9fd52  release/kernels/hit.oracle.jsonl
c5aab37fad4cb146d42a453d199aaf0809239d2fdbbafd5c4826f6e2aa7aa51b  release/kernels/hit.sv-hosted.log
d5267a3f8dac7655aa40c855a7ce8c4085dfbfcf1d0c14f80b4a01ba2780e627  release/kernels/lanectx.by_instr.json.gz
51534e4e089458a7fd323f458b033b97dc985333f1063fc02c6f0f3583406bbd  release/kernels/lanectx.by_unit.json.gz
6f40f9ecca919305d45cc11467d071512e6eb9efc128c723c14440493b76aa88  release/kernels/lanectx.ccvtrace
e735311ace496e3d768c1ee355632d8126bc1a3e4cd8dc2ddd29904ffa63c420  release/kernels/lanectx.log
888551babf540db8e3025b82e65ca655013f93eba3c8a65689d069d52a7e6039  release/kernels/lanectx.oracle.jsonl
b08f285289a8b7344716beb9ce08cc2526fbfceba1b0dc9b6f1d22c5d150fa30  release/kernels/lanectx.sv-hosted.log
57f4f1eeb23057f4df4a46f25ca143505ce721a5ba1cca50dc1096ada485e797  release/kernels/lanectx2.by_instr.json.gz
c6b2e900a2bab9ce14c522802fc0e67b738cbd0a65651fe83469a08aedaae9ff  release/kernels/lanectx2.by_unit.json.gz
b89c18d4e448ff832f7302ca5d5fbab66b09559f9da51bfd638adf0988de3b08  release/kernels/lanectx2.ccvtrace
48b773d19501950666e66006f4b94e561237239c6604d84b566c69eb634a0b02  release/kernels/lanectx2.log
45c13056dff5c73ed0c9ece56cc36f929bf335322193c7d5eb38710b1d1dfb02  release/kernels/lanectx2.oracle.jsonl
b89f16766b4a45e61b59ef6c98ffcb04dd91602ded1fbde00ede13635847a256  release/kernels/lanectx2.sv-hosted.log
39910a4807d6f4dbabc6dfad8f82720878b1995116e9f403a4431c973c8f921f  release/kernels/late.by_instr.json.gz
a2710e2f0cd9fc48f4dbeee44a2b3848b23462dc5e203e762931b85d9de8e90c  release/kernels/late.by_unit.json.gz
3150d1a14537818979a2f7f026d60cd6438ca3c55b9b0412d08e1e30f3fbd1a6  release/kernels/late.ccvtrace
9491bea32f65526c2e0b8a7a2a29a0d831a0357edcc5c5df9e063f94d6f9ed01  release/kernels/late.log
86084f6bd747a2cf32acbc0ebd96ebd3e4ef2d8d9e21be49e3ae49290d7927f3  release/kernels/late.oracle.jsonl
a32f66f05aff2c3e04a2dc07ce0252323e730c09cc742fb55aa7db3df7fd09fb  release/kernels/late.sv-hosted.log
fe3a1059e8fabd7707f4fe3a8ac5f37e54a87949d2ac5a49b2cdc2f9a3102a20  release/kernels/ldpar.by_instr.json.gz
501adc3235b0f497bc2a805472ec7d25b0b9a023c3766d1805eaa4a46e8da767  release/kernels/ldpar.by_unit.json.gz
a2b5e71b0f55105c2e96369cfd9dfb104815f40746116d9d47271d86acdc8022  release/kernels/ldpar.ccvtrace
a4cdc99c9de7681c985278c21e36eaee4f9cc2faeb05f3c9eeb77ac25ebdea0a  release/kernels/ldpar.log
8ac08538e9c807637babd61b31e340f7461878ada31f0c0b83cd66331cfaf486  release/kernels/ldpar.oracle.jsonl
b9ac24d44d24c1fb26ca15ccf164d0dcf6481220c6ea21d6daf4c6b79016f76f  release/kernels/ldpar.sv-hosted.log
daddca7e86cc6317f15c0e22a9af21d8c6db8fc84d8a2a0ff1e3bf5c63576c7f  release/kernels/lnorm1.by_instr.json.gz
f42a74d3af7508a62ab11e51aa85361cdaf0e3093b26f375bcc85ffac92ce8d8  release/kernels/lnorm1.by_unit.json.gz
d422c136cbd36b101f834f19319ce9a6e5659ddaf311bf94c7fd1080c1693161  release/kernels/lnorm1.ccvtrace
d0a739d93639c819bc8fe49f7fe9ad3e9c2ec684967f11b88b29aa058999f000  release/kernels/lnorm1.log
a8d85811af988a1b9fc00db1517300af3d93ec8e589e403d3b9113fa9e0ffc86  release/kernels/lnorm1.oracle.jsonl
ccb4d505204e7ae45bbc1679e993d2535ee76f58c425fe552d8388714aa57ded  release/kernels/lnorm1.sv-hosted.log
6ee0b36859093d70bef0976c6fe44640668861bbe8e1f84a9e534ed26f76a2a9  release/kernels/localsp.by_instr.json.gz
93c4a29c50b108cb3fc207c2761c4858ad5e4fa3833d649089358ab08d69fe35  release/kernels/localsp.by_unit.json.gz
04fd316f6ebb8d5f4656a1856afade1df3e44437c376c5981096b7efc62cc31a  release/kernels/localsp.ccvtrace
3214492c213370e4120ea36ba507fc0ceaba473843d18aabfc281c10df1fa849  release/kernels/localsp.log
55e3c9f36e7f7d38c0ddd38903aff4bb4509ae862015c592e6b937ea258042ca  release/kernels/localsp.oracle.jsonl
a38ae87758e791f5cae3c41b0d00f30b777f6c58ebb577ae2b537f4fe8298217  release/kernels/localsp.sv-hosted.log
da64755e0a4bf23856e56a2103d82d090b56dd6882f8b420c28601775d5358dc  release/kernels/loop.by_instr.json.gz
e0884be5b7a0909774de18034af18fef69d94dcd134e89229af455544e0dd658  release/kernels/loop.by_unit.json.gz
5ccb5d5561bc9782d51b12dc868841eac5d24e8def511a456e1670f8ad04f248  release/kernels/loop.ccvtrace
e94a187ada160d65d5bcd3c8f06f5041b92a1e8051e5bc30eae916488e0fdec8  release/kernels/loop.log
03ce5920c06c93e93516d8e53c3f7169f14e3593de204eacceffc0b8a3e32016  release/kernels/loop.oracle.jsonl
87c28b693a5458c58556ca38d6bd2d872c9039020164d154ca54a9d0a6182809  release/kernels/loop.sv-hosted.log
94d5850788b3c0dcb25eade5353e21bd335712978c8b7fa1c051d043fcacd612  release/kernels/merge.by_instr.json.gz
994d167bd22f0249502ba79c5a638b0d1639838b12757a3caf382b556353f062  release/kernels/merge.by_unit.json.gz
7c5c27b8590c634e6a6fa0ce6ebc8afed33e3101ca7690ecc2efe7cde41a32b3  release/kernels/merge.ccvtrace
08201903687955e0ed2d413ff714d06510114e44e5e2f0308d13698319898ebf  release/kernels/merge.log
f96d28815f8756b1f5a45ded53e6170883d2dfa10f9eef0d14b8050b1318164a  release/kernels/merge.oracle.jsonl
ab01049f22caeaef3e33fbd823717930d0c576ba26141914ef00ba9d750dd99f  release/kernels/merge.sv-hosted.log
ae6210ac7934ce82277dbb21880e4bfd6351518dc76b12bf38c070760035a3cc  release/kernels/missrun.by_instr.json.gz
d500705317fc04257e7f0417208c211ad46caa73053742ada8df02e6330f837c  release/kernels/missrun.by_unit.json.gz
d0717cfc4e7e14e0a0320cd8119b57998e3d090c3d2a71b04969bfb560b0feca  release/kernels/missrun.ccvtrace
3ad2f6adc5744c343514396462da023bef5266bebc0f5ce69c769effeb53dd48  release/kernels/missrun.log
531bdaf281e5590774bd2775427f25e4cc0419cf8e3d5b6999843ffe9ef87258  release/kernels/missrun.oracle.jsonl
66510a2407ebca22e5e4d2db6896091e70c42befd5be0308b405ea03b0a96401  release/kernels/missrun.sv-hosted.log
3dcd44c2fd78f287790e720e548f3b9008b7e33f09c1523f9459cc2a6ca60c54  release/kernels/mload.by_instr.json.gz
3a6aa71b36d2d79a7d66e7da7ea5d6673676f889bf36dfa70b58ce634b4ff5c2  release/kernels/mload.by_unit.json.gz
577a3a3b4df199ff847ae882b5c5a50fcd83c74e63da8ba04754d5c6e1775f22  release/kernels/mload.ccvtrace
64d159017070f72bd72824b61e12eef86183d307bdf37e69eed59a8b7d0f1c38  release/kernels/mload.log
8000e477b9a95dfb9f0af964e8346acb9d36f1358fd06ffc4ff7cf599d2b8868  release/kernels/mload.oracle.jsonl
83a9774a72547fac009ff6e1295c86d5a07be01e7da4c5c194dea3cebde8c823  release/kernels/mload.sv-hosted.log
39236bb7010fcc6f092209e710f5bcc7e927c69fbc3fe6d034397125d10a17a7  release/kernels/mlp.by_instr.json.gz
ed7b60cba20f9acd7d59287141ede2f5d34a88dd65cbe594884383ffe072cf04  release/kernels/mlp.by_unit.json.gz
3e6e19508e5cec05b2b2e22e9e847b4f99c95bbfe76ba26fef100f54e2682075  release/kernels/mlp.ccvtrace
23f04dff2a940426d3d6d47cae4842a6d52bd995e2ae4a647046233bb7388949  release/kernels/mlp.log
138d282f88d56c8ad648a91af0a983254b55d9fa22942c00d47b327f516a6e44  release/kernels/mlp.oracle.jsonl
8da9ea5a772a2e912fbf30166462d31c4e780b9c72beac732ab3f2eeecd4c5d1  release/kernels/mlp.sv-hosted.log
85d448884efc53e84176694fb1f2eb4fd35796e5811198596d40ff8de3a05837  release/kernels/mwmiss.by_instr.json.gz
4219189ab367bf0ebb1b69775b2e9fd6e83d60935894f5e16aa0785615e17b13  release/kernels/mwmiss.by_unit.json.gz
a4a5e0dea6edc9552a29effd74f49f1ad3d2279d61d60a0680a50e5ec98ca3f1  release/kernels/mwmiss.ccvtrace
20f35346c66bdbdd919144912946177e2696bd32a6cf1f06b41f6f1999ea052d  release/kernels/mwmiss.log
8abe8e8997456a2a6711ee72da54d854b24e20abbdab28e4b7271c0d28418de8  release/kernels/mwmiss.oracle.jsonl
330ed473643e93911aea9041e603695ebbcf0cb655913b45caf3fc6e299210fa  release/kernels/mwmiss.sv-hosted.log
caaa2b6f8d2ba537acddc0105a268897fffbcd4e3ce9740928b7efb688174bb3  release/kernels/narrowadd.by_instr.json.gz
dacb2e80a38add6f12c4bc2570d8e60480751025ea760e076e3f8b19964b7d7d  release/kernels/narrowadd.by_unit.json.gz
37d15e65cb02bccc001898996b6f8c4fbaaf3c7bf6f33f5629f7e1d886be38f0  release/kernels/narrowadd.ccvtrace
31424be14048d656b6701cd7e694b0f4f7d8baf2da2954f0359d592406461012  release/kernels/narrowadd.log
40a2cf629853dd404bb06b4a07e35abde3d12efc13f26ffe28f923daf2994574  release/kernels/narrowadd.oracle.jsonl
5f7f94097bf1125c71c6e4b557cbcb3273268f56bd8258fadb86f6badbdbc29a  release/kernels/narrowadd.sv-hosted.log
7add4810b99538bece8d5af9ecafc2bdc72c221552769f81f082abfa10d30f00  release/kernels/pguard.by_instr.json.gz
f55f402e2d4f0cd4776e6ff9a76b4dbb5cca9ec4132abd3e5a25b724f7ca7aec  release/kernels/pguard.by_unit.json.gz
f4d640eb3c718814f8a0082210a5b32b641049e7be155f3aeb43314a46416b2d  release/kernels/pguard.ccvtrace
14a7f102a969b1be10ea00f9adfb163b0adcc81cfa931f1743034b12fb04e937  release/kernels/pguard.log
690e56f1cb8d97cbf67124b7dff3ad0a90cb8981814cd1709cf0cd0e035b3bd9  release/kernels/pguard.oracle.jsonl
11774dc386ded5ae090ad85127369786950450e232da435ad666dc897e1bde19  release/kernels/pguard.sv-hosted.log
26af52f8633a08b4fd57d3d00e73d7f6cdf85dcb3c7a7e4e8a86051fc8840cde  release/kernels/plog.by_instr.json.gz
050003588a522a54c157fd06fb8ba536a5bfd1b1ba5bd03f377b14e83b516cb7  release/kernels/plog.by_unit.json.gz
7823562f75147705b01f772471b6175774023d19935926703e158062b24cf94d  release/kernels/plog.ccvtrace
fce73792136c0b2420473d2c7d32e764eb7a5448713443f6f96626c5a833fcba  release/kernels/plog.log
0c99915e2da60f4670da00504a6371d7d17701d4431e733a3ff8fa98a2030d6a  release/kernels/plog.oracle.jsonl
1ac198bca7562534eec9fc67cd9652f785789f1cdb9c234c6cc9ceff45ad48f8  release/kernels/plog.sv-hosted.log
1f20e73493c216355797103d70e3fee9a85505c40d30880b85fd542a59fbc86a  release/kernels/pmovdiv.by_instr.json.gz
ac30a58d1e03116856245f0fd405c9c9b161e90a01e0bcd4c50b96aac0390a93  release/kernels/pmovdiv.by_unit.json.gz
da1865544271c3c70d3eab1061f5060d833a856975f75b28d0921880ec954a97  release/kernels/pmovdiv.ccvtrace
f9642dcbf3eabed260ae93977e524cee52d2c34c29742a1eaa48818051383980  release/kernels/pmovdiv.log
7bc646cff6166a51bdce03d7c1b7209e871f0a91d743083a9b910a80bcd0b33f  release/kernels/pmovdiv.oracle.jsonl
ca0e31649a9e5219f0de373f9138bb07f0be201f715830f572a5770d9bf41b32  release/kernels/pmovdiv.sv-hosted.log
3745c4694b712d3d399a5d529e0c829eed97460eaab05ac0898e69f2fa150da5  release/kernels/predlane.by_instr.json.gz
ed144fcd759aa7419c180eea2414c004aa14bf458a3fccce52c4df5172d6e6dc  release/kernels/predlane.by_unit.json.gz
92b2b1101f673248f8b28d88093d2a180c8d0f30d92fbd57a2fbdbf50e68708e  release/kernels/predlane.ccvtrace
b127e57136cba295f9c0ab48654782b23339ebe3ce02196e146200daf6ad9ad6  release/kernels/predlane.log
c45f4177b9e84fc8a6e36b13534a0c7636eb30a3f8531847100ce5e23bf404b1  release/kernels/predlane.oracle.jsonl
2632dff69d21bb64da001e706c29cc43a8e815d2fc79344f288741147efb8f53  release/kernels/predlane.sv-hosted.log
00a98481ebce16f08d18e24dd03f9b443f98fd13f0ae55f882652a91fe2885df  release/kernels/predmerge.by_instr.json.gz
e6b6611a67b308deed003fe20771c7e3f73378ba7f60abf0911fcbd280e7f096  release/kernels/predmerge.by_unit.json.gz
bb3488ce2d30e744c014d06bb81053f2bc8f09237e4066530c9459a0da2002af  release/kernels/predmerge.ccvtrace
3117c04836f584acb570dfe23790f0d639cd186dcf2bbe6292c808b31a72910b  release/kernels/predmerge.log
6c737c49434bcd08e3e0814c8b1dbf15c586ae74f7929ba3148ddcee2c62c845  release/kernels/predmerge.oracle.jsonl
3d398aabe545ef35a18adc0287f50c7d2b44a97adc9e75789b3b3f7f0af0b1d3  release/kernels/predmerge.sv-hosted.log
34386a7e5163b7ed8bbe50f8860de05e88eb3231192fcf5d3c73ad05203d7a2c  release/kernels/predspill.by_instr.json.gz
13abebe87409d978b9a09ee4d87c07361da2c41696fea7cc70b9c17154ba8516  release/kernels/predspill.by_unit.json.gz
bd36b4bae813afe5b9524ef4c5e637d94c88c266a7d87c83da36c64de27ab139  release/kernels/predspill.ccvtrace
c8884c336011166faa597dfeec678a09bfbdebd846877c0a58608c0d70a0194b  release/kernels/predspill.log
b7c84c6478117ffa0f06da0e6ad1e4628e2683426a7911080810e78e06a5242e  release/kernels/predspill.oracle.jsonl
d27e94a6952452b487a29da286bd400e99fd551eaa4910999f6ef42f955ce8da  release/kernels/predspill.sv-hosted.log
9c41e2045b80c687c69bdd1787e3bade179dd1d8438b104118ff05fc22b4d8f7  release/kernels/predswap.by_instr.json.gz
5d85821f1cbb4bbbcc7a37a51fec53f70fa2324d9baeecbaf29fb2435958532a  release/kernels/predswap.by_unit.json.gz
1b895deff4b6c3b0086288d4122e89896df7658dddd19c63f5de3cf16964591d  release/kernels/predswap.ccvtrace
c6975938db0f93308dfcd1124d846026c2de585426cab634c79b3d50bfb06229  release/kernels/predswap.log
a6d4f7ed517553816d889c7c9eeb6bcfd1f6c973fbf682ecb69f3c2de619f7bb  release/kernels/predswap.oracle.jsonl
357c4ce4edae4a871771bf32541e46a86d47459e24ff31a3837e3d0636787b4b  release/kernels/predswap.sv-hosted.log
c4ac9a73f606e0aff31248837bcb7c3c6e3bfe21b96954fd6d44e9f8a0cb375a  release/kernels/privwin.by_instr.json.gz
985256baffc549c955487b5061114bfcd437c02858af2977ddbb6347126c9d89  release/kernels/privwin.by_unit.json.gz
2339e4f77834724f7ca0b9a0d955b1c914624b8490b494ffd185c449c385e7d0  release/kernels/privwin.ccvtrace
f1aaebbc4c1f2edbb5b2bad353d56fd62228273e6a633e65bacf3dc42ad35be2  release/kernels/privwin.log
861f686fc4480363472908d679d8815e8c957d768e7ab32c826930527b0fb7a8  release/kernels/privwin.oracle.jsonl
359d269513a7e9a4c0cc6188c0c674c931041177c8307b818badb8b959f0d3e5  release/kernels/privwin.sv-hosted.log
dc6cfb3776c219ee26939e8d4dc7f34318bc293c630a840e136aa07e1ee7add9  release/kernels/provswap.by_instr.json.gz
69f5af90a4c5b8893eff0a73dfba36cdb699d8a0ec5bcbffd2aacf6f6e22ee47  release/kernels/provswap.by_unit.json.gz
02e0c17e77e0ab083cd97178c0672cfddb701e2cfff0917244168e93eaa88ec7  release/kernels/provswap.ccvtrace
cbb21fcfb5a6bb46af2371254ba273a19453914a8bbc7bfb6005a2edfc0e4bb8  release/kernels/provswap.log
c9c32a793d54cc7401477f582487f7e8b345b2669a75337b8d6327120d98e5dc  release/kernels/provswap.oracle.jsonl
1f9a3049ca436b5fae022b94ec5a55001f6e9511d60c489c240a4211594d0aeb  release/kernels/provswap.sv-hosted.log
a7355f2efce11df9b212f9fa87b81eb8e34e953dda2dc8b4e27fe0b6d1ae7a94  release/kernels/retmiss.by_instr.json.gz
b2f73100bb94682f9fae16bca6bdaa9fa4871d0ec7d16e62364235c9d980a35c  release/kernels/retmiss.by_unit.json.gz
6f094a4f42860ec13c8ed55dea19af83f02ec10f90dd9c8821ddc2541fb1a78f  release/kernels/retmiss.ccvtrace
3f8dd47fc4baf85f388823b2e1439fb26d24fd5783b0177f10c0aac6f28451d9  release/kernels/retmiss.log
e5ef8538e838c6cff7febfc679dd091cf5e002f82d34f1009b1948ce22bc3649  release/kernels/retmiss.oracle.jsonl
fd2576b393734e08caeadc266ae921e1533c210b78c0435b07eb017ebb985ec4  release/kernels/retmiss.sv-hosted.log
b8af37455b33a1b36ab55a477d4761f76bdf9dd3edd8eab5fb7f2c3731ac8ec5  release/kernels/roconst.by_instr.json
357217c72037a713eac0a6b7379bf3c587e1d0ebddf2552663b36be17a4792dd  release/kernels/roconst.by_unit.json
47b4c352cdd47d93bee09cc71530c77fe68e1a5ae74bb3ca0570b6874a7e15f9  release/kernels/roconst.ccvtrace
57b85fe6cf8d26e82ba1e0140a261974de617c80d9176502efb483f36c6f66c8  release/kernels/roconst.log
8087c0671de620162881aecd38cd6114b78e7be6bd71201e3ec02c9a2e2e750e  release/kernels/roconst.oracle.jsonl
e65cc622409c28639dd2eb710722c1a0221aeac7cebdf1536d061b06fc88f99b  release/kernels/roconst.sv-hosted.log
10c797fb8d044649f6d3dee9c07281c225794258b33e21124d781108ba92c747  release/kernels/rogated.by_instr.json
110cf8aafe29f9479e7b6bc3bfcb41f6bf526346ab11308daf8c4b76d9bf7934  release/kernels/rogated.by_unit.json.gz
0ab8c9db689bf21fd56c52f465a6c5f8c69b0be064eeb18df72dd1a19a76d664  release/kernels/rogated.ccvtrace
051300c448c5db42fcc04213a167241b230dfe5d748d6f26e468553992c8b4a3  release/kernels/rogated.log
7cd02bd4cceec5a044d6b4d6a80df1e68ed0ae71b0b2a953143636d5b809ea6c  release/kernels/rogated.oracle.jsonl
ff7bb67db96f1dd283861e7d431be3779a1cb5ed019020585b5db700a9417e8d  release/kernels/rogated.sv-hosted.log
0be5e08d884f663819cb453a3dfd8ecdd0026628bec4871ea2a78acf51d91cec  release/kernels/rokill.by_instr.json.gz
6a7b957f22a093d714e22a8a09a8c8314c5a29bee11c01431aaf990a01d3c60a  release/kernels/rokill.by_unit.json.gz
f6f31e59954f2b7c0208dff6d34443ba005176245081f039702dcc2576a7b35d  release/kernels/rokill.ccvtrace
9a596a570b9099f28c78a55d33ed622aa35b66b87c3fb592309edd1880c98cd3  release/kernels/rokill.log
94efcef96af469a512d346ce61623980fe86383188eaebd55120f716db596f14  release/kernels/rokill.oracle.jsonl
74da06953a5caa85329e6e86a53083d618c9907ee3ded586a2b944def5a24ad2  release/kernels/rokill.sv-hosted.log
9a966ebd2896463b1e530bf1d6ce8a71af91575844c447c471b9a35764d7ed8c  release/kernels/rokilllane.by_instr.json.gz
4dab3ab409e3e0ba3efac4de3974c4d3a019af3fbe87e447b6532b4f13eff110  release/kernels/rokilllane.by_unit.json.gz
6385817a65c730b80aae4122e3d074d9e66b3cded81d6590e7d00efd695ee3a6  release/kernels/rokilllane.ccvtrace
0ccba8f24327da4d13b46d89757e59742604e3c1d879430171f9734f9d759221  release/kernels/rokilllane.log
f5ca6e666eff2f44894df74a291b43b3c0e7be0a63a47d795fdefd7b22016f45  release/kernels/rokilllane.oracle.jsonl
c05907daf1d2180ba22f0e295ac5710e77bdde6c7d0f8367bef51557c099467c  release/kernels/rokilllane.sv-hosted.log
6018676757a05a45231fba12ff6df60d07f415338c1d836cc09d99465b73577e  release/kernels/rolaunch.by_instr.json
c157f1e2326322de8cacaafbdba5687d5c865c70a997834aacd3bdccdd2c43c2  release/kernels/rolaunch.by_unit.json
0ea08323eca54b8dd88d2d98eca12c9667af542f5d0e0ca282ee2d5f57ebbbb9  release/kernels/rolaunch.ccvtrace
84ff79f5706a00d46455306ece0a4ea316b71215093870b47f9e597d50d1807d  release/kernels/rolaunch.log
e7dad585c3e70615de04330fd03f4f282c29a005dc1732a35655fb261d51139e  release/kernels/rolaunch.oracle.jsonl
13ccfcf2b7abbf7c6048351d68805fe9b792bb1e6bf3caa0f68b3fe0113cd511  release/kernels/rolaunch.sv-hosted.log
b8af37455b33a1b36ab55a477d4761f76bdf9dd3edd8eab5fb7f2c3731ac8ec5  release/kernels/rolimit.by_instr.json
0358cfd1bb137c960487c6e1fa8b074623c904e538ad55b630bec3c9f7fdeaaf  release/kernels/rolimit.by_unit.json
bec85876888b4ea67e5cf81aa88f160350e676db544d7e6924a539ed277454d7  release/kernels/rolimit.ccvtrace
1e3180dbee8f4902314542b2f96b6c40105d08f23e5fd895969379a15af7b64a  release/kernels/rolimit.log
1c5bc0cb8e8b2e69505fb5a551a16d5d10c56f232b88da7a27e336ad7d962de2  release/kernels/rolimit.oracle.jsonl
185d126943dac2e572ff930108794b3097294d2b2fe124a0d36466a12a9802e3  release/kernels/rolimit.sv-hosted.log
dd3ae477367edf365b581b6c1363102de407df5ed1f08028fca9fdbfc7b958d7  release/kernels/roload.by_instr.json.gz
47b34a73d8a42890ba3e2ad6a28e51d55f5e5adb418b394f0a7c557c9fffafd7  release/kernels/roload.by_unit.json.gz
554fe7b6e3b718a63b278da46b9e3604fa927d3d8c9ffefa5bbfeb7a4dc44b1d  release/kernels/roload.ccvtrace
96c4b129eff5414d204212def54c586380f3c05cbd9951164ad72502fd3a2222  release/kernels/roload.log
f7c1309cc9764769fb5803f6fd0f2f5e1eb418f2d23fbe5e17cf5f9106869fdf  release/kernels/roload.oracle.jsonl
2a97a91ddb13606385c7e14abf21435180568e2eed1772e24ffc65fa60923e41  release/kernels/roload.sv-hosted.log
f413caf3fd063c3b4362ceeeba75e36d0b9d8c14985ddb9a8c5fcd785eb4aa9b  release/kernels/rope.by_instr.json.gz
c8b372ae1bdd7ef3a951f99e61eca8f27c8d011cdf6a7468ea4c681310340a7e  release/kernels/rope.by_unit.json.gz
f6ad18f23cbb4f20646d227ccdfacf36a783264a77ec6b93da0c847ff2ec40cf  release/kernels/rope.ccvtrace
380567657c67674a5924c8de3142bb1cfcdce170b9b6d6c6d7d70ba0ac9e1d0e  release/kernels/rope.log
d55f9efae392dc8877c102c01c0810e7654b666b6ede386328108164c6cf88f3  release/kernels/rope.oracle.jsonl
bcc821f7ade375000dd3c33604a0ba3cdd9ca7ce50eaa8f36f57a316b352c3fc  release/kernels/rope.sv-hosted.log
4bc3a79a250293051b9d828c47c3dc5397a34e64a5c96e95e4ab6ffa67f4a264  release/kernels/ropediv.by_instr.json.gz
b67011bed941a30348c8049a7cf15258a8361631ae8790285cf77005a25950b4  release/kernels/ropediv.by_unit.json.gz
10270e50bee5a26190cc449f04d57fe36983c509a3d0bb7ac7691f51d85d29d7  release/kernels/ropediv.ccvtrace
b5b3bb080662995c1e82d44788fcd18c85ab7330784a9c87d0a7c65f2fa6b49d  release/kernels/ropediv.log
10c0ec6ec18b7b44638c790033109198c079d07c1537bf193353ccedd00a920f  release/kernels/ropediv.oracle.jsonl
7c03231649a03adda459bf49e1be01b26fe0e2f9e8c5341a0ffbad53e5cf3747  release/kernels/ropediv.sv-hosted.log
95cccfcb730cb4da30859f92eaf7c1081c702cf20df2879f51a9fa0b21cd6d42  release/kernels/sel.by_instr.json.gz
88c8be772cd4ffce9cf1b0c0760d2a3a6b379bf0edc78a99112949c07d8e36ee  release/kernels/sel.by_unit.json.gz
b7e938279e58c029f621fbf246c3b68cf5aaa826d23ced0b0a274ede1db13213  release/kernels/sel.ccvtrace
76bfcf4f67ade9999d2e200cb11c6e2760b56784e251e72bd3f2c879e302d63f  release/kernels/sel.log
87f6a81e8afa004c8039bf2f61c90176fcf29ab29bb17ac44aa016a5cc8438fe  release/kernels/sel.oracle.jsonl
82e4f6341c96e9b55f8f4fa1915a6a06a59b70e5fbf806241c94cdcb4596658f  release/kernels/sel.sv-hosted.log
a34aea59083b70b918b27477d4572bd1fe46785c1eb80eb73079c3b287ec6467  release/kernels/sized.by_instr.json.gz
83de7c14538a3ffa9e1edf5082c8c6c573b025e37b715c0c4b57c19b31cb6bc7  release/kernels/sized.by_unit.json.gz
a9843b2c4b46306b93b260315a2e25662fe5ac93fba6fa497b21ab3c58384183  release/kernels/sized.ccvtrace
f870ef947cb0604135716c661909ef8498fe8df114fdaa33ca39c34a5942b179  release/kernels/sized.log
36d903ba1618bd1faa437c9812a6ee6c0c966a63196c796267d74bf2695ebc3d  release/kernels/sized.oracle.jsonl
8d21673e9ae57dc0650af73c27ca195652508523647aef37ab008bbfbd409f48  release/kernels/sized.sv-hosted.log
0efc830275f66c6158a4d7ee2c15caf9be15b33dfe071cffff2ef8407d4fd011  release/kernels/slotform.by_instr.json.gz
f4d99f3be527cb860bf84e3dae255a1eef170ea6a94f029dc1416e2df737e91b  release/kernels/slotform.by_unit.json.gz
49d5e947563620dcb299762eb88ade65677dd870ace74045f1b273538b7454c4  release/kernels/slotform.ccvtrace
b4040cd098f4e0f0e565120d4d30c0aa17e1e98546d2f6a7483d1c15b7059816  release/kernels/slotform.log
8b61db7419b18cea8a646fb628218447e72e84a18a9891ffb73b441736138ab9  release/kernels/slotform.oracle.jsonl
c89c1d67fd512c728d51d32a1412503dc2cdbd0bca9b1f83fa6e233ffbf14274  release/kernels/slotform.sv-hosted.log
c91a16da7d81e82298938e33c0f50afca3f5e3b160dcf9c7dfeb0aea021fb74b  release/kernels/spinwait.by_instr.json.gz
991f575cdacb97e630b5927ea509e903eca909508334e52fe5bafd95519f98a7  release/kernels/spinwait.by_unit.json.gz
25d95e4507c45c2c4ab004660dde0c9b71c5459ff3d1e80dab0c1cdf325b7c7a  release/kernels/spinwait.ccvtrace
71955d7ef2a895c5f9040efa64b99fc3f99817216f17d7697f7a9fa3fbe5ce41  release/kernels/spinwait.log
868920637236c878b33779bd450439466fc3626996a3164573dc11d437d5c709  release/kernels/spinwait.oracle.jsonl
9777d96e1cb9b9114b3b07dc4ff18c5658b9228ca27b4a0111b300415161da23  release/kernels/spinwait.sv-hosted.log
0478a7fd8ba745a6be7227fec93d8dbe9b60ab1e04be27bde70f4d316e8e0482  release/kernels/spmbank.by_instr.json.gz
53698c4e50d5ff25f5b0575b6c133a6b5b8a355be338668433829f2466bdd288  release/kernels/spmbank.by_unit.json.gz
0b63ddd199108d5d57dacf8da3b47f37f0c4b36c8ae2b2605a61415aba0d0ef1  release/kernels/spmbank.ccvtrace
47a51d46324799a1441299d963ac682668e5144511f0c6adbc7c5f05cfde90b4  release/kernels/spmbank.log
3af490cc37d7a92dbe719b57de216b648536eb301ff9d13de9a39f50d150d725  release/kernels/spmbank.oracle.jsonl
a100a4faa2e92040d72e68c383203e52af69d3c87b6c095d2e3743b8c238c9ce  release/kernels/spmbank.sv-hosted.log
a945ed847568438c6465aa13c7e581bb6b4d0d36e68a2bd12daa7c34edfdf52a  release/kernels/srd.by_instr.json.gz
e657ec3327afe1182120d0177e70a958ee43e6a708e89bd49b537b61e7bf8c6e  release/kernels/srd.by_unit.json.gz
12ffc6ad91eddcde92d30ac0bc8db4c6cf9ae295413afaa6724b94542c6a18dd  release/kernels/srd.ccvtrace
f6416314b973f09e784698fbd512b5d507663d6289fda66ef3a373507db4c579  release/kernels/srd.log
b08eb5e3673cac7eebb8b72af5ed3783c8e70a9e96592e76bf3722551bc79473  release/kernels/srd.oracle.jsonl
fd6794a1a3fa838e1b3c3f3ae7a7e960cd1866b143c7278b86d04d3e5b83dbb9  release/kernels/srd.sv-hosted.log
2d6d6414d8a7891565dc418ffd116f51821903b990f458c139f1f87ad50eacd0  release/kernels/stall.by_instr.json.gz
4b11a88ea1768d23ef4d9548c301b8a6f0e1b9657f18e2b064e01864d80d611e  release/kernels/stall.by_unit.json.gz
23d7fe29679d4f66c856d1f3771699f36fc83063bc591f46dcf0b1bbd72faef5  release/kernels/stall.ccvtrace
c8706ff35c555867b855941d01bae477836c6066dcc21162690cefa859eb6ca5  release/kernels/stall.log
500db2c482b07a0706583422cd68878301d0146c1f872ccc1f11bfdcf5c993ef  release/kernels/stall.oracle.jsonl
f0f8eb70092e84eeab29e8b1e2e57632e4e2e76e908d8a2074665d498b87e3ab  release/kernels/stall.sv-hosted.log
239c916f615ad075d33167dfe474378d1122c3572a690138b37e342c693794a0  release/kernels/swap.by_instr.json.gz
47d37a59f24ede212e8480381b7520e88d2785122753f223f59917c689583814  release/kernels/swap.by_unit.json.gz
73f0439a3c3728b551849a9dd1cc3ca4f6e7f7aab68ba4084ce43f4f711edff6  release/kernels/swap.ccvtrace
aa7f9c5fca7a2cd62cac9a0852deb8d7a78eaa8bd9558253470bd1ddef368509  release/kernels/swap.log
3658a26316c1ff7bc1744304a42f736e930fcde2865c8913e6cc67a22ce96667  release/kernels/swap.oracle.jsonl
00d7a7ef580d7431ea8cdff0846220cc15f46084e5e70a101832e4b87dbd4138  release/kernels/swap.sv-hosted.log
bb8cf94fca13ab0820119346503f3c0ff1c65b23a5939460390ca81e8873965a  release/kernels/transp4.by_instr.json.gz
0dc9eaa23f83e235346ac4999b83d44b610e5669c4573a3839739c2aa18eeeea  release/kernels/transp4.by_unit.json.gz
93e614f4cfab174fd368a701d37df0ffac14cf302353169a720ab414e9ac2c16  release/kernels/transp4.ccvtrace
0492ffd3401a4091d9edb60ba7d6acbf27725f2fba2c7a16b3ca5756304092fc  release/kernels/transp4.log
06396ace3ac19677fd39c700e408606e5bdbacb24997d663bbe8872e63dd74fc  release/kernels/transp4.oracle.jsonl
e9f389ab21fc1af4a5e7331c191ed15b63368ddcc440db561af0d768061f02c8  release/kernels/transp4.sv-hosted.log
a19f14cf24d35312ec1438dfc0bfec5b3b2522357787723494c81e3f19c48fcd  release/kernels/unal.by_instr.json.gz
64674ee75209c2902662be8710688881f33c8c363307d9a24d4155681b7130c1  release/kernels/unal.by_unit.json.gz
52b05699065211ddb8b1c31f92005de7dc6eee7a77092aa25a03d8405c81c852  release/kernels/unal.ccvtrace
447df54bf2c8892997579702b96c4c6715ed968b0a2a42e46a5ab81ec9bd89de  release/kernels/unal.log
c3d484bb160657a563df983d9a2532eac27f556636617960aa1e72183ac2b299  release/kernels/unal.oracle.jsonl
70b5b3232fc9e15a22b6eb3233ae0466a5efa6b00b8789974e8ff77f2dbaefe2  release/kernels/unal.sv-hosted.log
1b7b15a5d4aa82e06ecdbcf37c13a336a5760d1e720a19cbd1204a58b587fb0a  release/kernels/vadd.by_instr.json.gz
5d29c14a20395cc90d9ba8686e9c41d1e11d16d52b1fcb91b26b43578fc5f83f  release/kernels/vadd.by_unit.json.gz
4c225b6185d0ef923f0c26ccd6d22a7277ea8914d97d1e2a458467ad4812f40b  release/kernels/vadd.ccvtrace
816ca8b1fc9981ad0fbf1cbc3106a550567fc1dc29cc91f693c46cd12b1e218f  release/kernels/vadd.log
0276b6d0611a4bbcdc004ab3987214aea138245bc7217504147331689a9c0880  release/kernels/vadd.oracle.jsonl
b110984e84930e21b29a14f5e8d355fa85a43aaf3ab7e7a439e1b235a82949ab  release/kernels/vadd.sv-hosted.log
c8aa7d84bc91a47c7cad6531c465fe95f8f281617c2f590c3db626237c35fe26  release/kernels/vadd4.by_instr.json.gz
e0b7bbe3ca124bf11344fb25fdf2b9cd4b577a44a7b38100434a5bf92072a354  release/kernels/vadd4.by_unit.json.gz
5dfa2ef9e17a34e3ebcd6851b1dfdd50fbe9981700aa8d4a493a13572ba48f9c  release/kernels/vadd4.ccvtrace
e967c36af6f8a33691250d8aad601a0e7d3a6a6677efe534bcf2b869f60fa321  release/kernels/vadd4.log
225aa18fc9f38aa9ad615aa11de254337d59fa705877553d873062c68366e0db  release/kernels/vadd4.oracle.jsonl
4a1bf5850def6d8152b7e68875f939167ee0f91e2bfdba01cf3a48ade4bb3126  release/kernels/vadd4.sv-hosted.log
c9d3496ef39a334e7b4e50f2ddc13d7ca8b647f75b17e3733690fbc4f8d8f72d  release/kernels/vaddslow.by_instr.json.gz
1dcd5d3c07578bf53ed9f13be249966f5a864e48d31a55d61a0482faf7e5e2b3  release/kernels/vaddslow.by_unit.json.gz
25a16a9885807c4eb4ae66a1bde936ded34fef447aeca62f3277e0d4cd4766c7  release/kernels/vaddslow.ccvtrace
f5a5be824623d30d105cb768713256e36a0d8e6e0e5d3aba3771c362fa382d9d  release/kernels/vaddslow.log
e9e6218e8b8450e9f9ff6b39d659c994a1e51c527a0c5bd10d18b5658ae0e344  release/kernels/vaddslow.oracle.jsonl
e539371111fef7696c1ef2c8bd8bd3effc97223c297c880cfd06ab288599a857  release/kernels/vaddslow.sv-hosted.log
20c92134c8a9f0e30ef15a01f98000cd767b80bc773e7f73bb31a1b90b03156f  release/verify.log
fe1c1a586828f0fa7b9b7bb7e659648607ea83cfff7664dc3507dc413f8b11b1  release/wiring.txt
```
