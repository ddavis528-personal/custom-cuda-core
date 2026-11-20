# Snapshot snapshot-2026-11-20-154eef3

**A generated, read-only snapshot. Do not edit or merge it.** The source
is `ti-ma26` at `154eef3a69132fc98152a90bdaa890e76f1a9d4f`, and this branch is rebuilt from source by
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
| Source | `ti-ma26` @ `154eef3a69132fc98152a90bdaa890e76f1a9d4f` |
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
95b99a9b6716f5be6550c8cad6c002da35f86fc5632edfa138c1e5570627d2c1  release/kernels/addrhigh.by_instr.json.gz
10ba4e3996cc34bb758bfd8fb9cdff03a3a69799282d89f73efa62e8037a8a24  release/kernels/addrhigh.by_unit.json.gz
4dac1317d6fd6a40770d4e703058827a4e591e1673c43c6fd30755d00d10825f  release/kernels/addrhigh.ccvtrace
fa46bcd9a5088f228c969cfec9304f17afeebc4a33daa9677f827592d3a2236b  release/kernels/addrhigh.log
569f2e22883fad5f0956c57ec734e6afbdd4b8a854e50277425172d6c0cbd766  release/kernels/addrhigh.oracle.jsonl
56daf4259960dfa72f7eba8cea2d77e615ceb6bd2d61011c6bebcc96154561c8  release/kernels/addrhigh.sv-hosted.log
5a8a04498f620c64d134e6e0d01e8db1cae0cedd41b9d7b57b83ff23877c4dcd  release/kernels/addrlimit.by_instr.json
761a3abeeebc4495d5de7c453b33f8234654d922c8669085185e010356412e8d  release/kernels/addrlimit.by_unit.json
a53be191c4e9c5a3a90b0569d777cfc0d4974f156e702139cd0a3cbe5e4a5045  release/kernels/addrlimit.ccvtrace
038288f91c887f83d2f9576cf5ac5acaa87bdcebfefb77275c2021b8b7352f0d  release/kernels/addrlimit.log
bc660b0b40359a2c5a2478cb0eb4950b73fd22db50ea76b80052bc195a1920f4  release/kernels/addrlimit.oracle.jsonl
943286c6bef83c30f9a9561a0bbc22637b75e494fa153585a5f44d52475b358c  release/kernels/addrlimit.sv-hosted.log
d5ee993d0a633a3a0837df8a1267138a4a90d71b0f13f2964db1fac129be4751  release/kernels/addrneg.by_instr.json
104adae31ce78cc2cbcccb238d2e68f6944a9e3a7d1009f4c3a2eaca0df41bc4  release/kernels/addrneg.by_unit.json
0446b0e2d2af5b36c5a5ea6f83f1deb34ff1fd1fa93229fd0e9aab5274ba454e  release/kernels/addrneg.ccvtrace
0857bc896422ea13b682599b6e1bf53a7997598fef7f3ec30f6570ddb5f991e7  release/kernels/addrneg.log
16f5b0707ae44492a1efd67bb9dd38a7e79a7bbd354fa9207b9e7d150ff2f107  release/kernels/addrneg.oracle.jsonl
d38d20d22afe5d2514b9097d85ddd2e201925b7fa688c818c30ae4746fa1405c  release/kernels/addrneg.sv-hosted.log
8ce82f732bee2f9a96995ef5137ce8fd0c1ccbbb7a59b5f0af85fc778310514e  release/kernels/atom.by_instr.json.gz
2669215fc5ad4c07f6914e393983286391365e3ae58e0896a909387189ee8839  release/kernels/atom.by_unit.json.gz
0efec9401f542375a590011cc55578411be218ed9a6aa16ed4e2cff66f5f5352  release/kernels/atom.ccvtrace
27dc40204949f50266417ec2c20e5cf88ae6874bfc86cd3982d836d89a622a8c  release/kernels/atom.log
504f5b6e9d25114dc35f2c70b21bb7b3f3c508c691de12dc0e87d12a74285361  release/kernels/atom.oracle.jsonl
54bc1a89fd33ed087b2ebb16593074b9e055ec7d0cc7a35c094f7725c406c871  release/kernels/atom.sv-hosted.log
239f85ac0de11bf6447f0889a884d67e2dea0d2d91b608f71d07b54984ea5ed0  release/kernels/atomf.by_instr.json.gz
cce0de9f80804a3bc444ce5640ab307243063b5b27ad8f02cc902feb22f9873e  release/kernels/atomf.by_unit.json.gz
35585bbd0deab31f1d8022e6ca44de0a62c59364d9524eb19562473c7e745908  release/kernels/atomf.ccvtrace
3be17514f8af420be71f711aac95ffdd7cd90e85597225e55834b6985cd31053  release/kernels/atomf.log
cfd1179edf4061a33ab2f75d7a6dec61decfe629000198189a7bfc2647b34238  release/kernels/atomf.oracle.jsonl
26a8d1f38abce6e8f4e4f9ce2ad058b11f6cbde1b7f9720a26d20243d140c139  release/kernels/atomf.sv-hosted.log
37c46cbe3488356525300db2f76bdfb2f5621d7f39eac8c01a2fe816c62f4b32  release/kernels/borrow.by_instr.json.gz
5eeac3e07f3e66c85ad919692797e9faaa02638e4e5f696e49a529626b37bd19  release/kernels/borrow.by_unit.json.gz
675e87f1c0e15b984bee253fff4849e79de6b07f83e6e28edfa102cf07f93b18  release/kernels/borrow.ccvtrace
f500343e555384b26a8c3fc102eb7bf952853a9a39632783e31f00834aa9d141  release/kernels/borrow.log
4c565e1ce0b3baee36e158694b32c8defb5cd662b2f9af75cb5d8c26cb1168ed  release/kernels/borrow.oracle.jsonl
ca306ba3c566208d0aae8d36a18265c5dbf6f20796f17e91c175805bf46f2e42  release/kernels/borrow.sv-hosted.log
2023460df9684d1d2e0937baccd47672e5721b4d92b51e35d86f655dd7be3a68  release/kernels/brs.by_instr.json.gz
317ecd103acc290f927dc67f5c54105cd6b262fdbf0931758e4359d702d33250  release/kernels/brs.by_unit.json.gz
dfdc00e3f7e638e036c8544c04704d8c1d4cca764d189ea7aa1e0739036dbfac  release/kernels/brs.ccvtrace
9f25c640fdc5b0622626b9bc3638e49831755ee9dec3b8870c4dac09481171e6  release/kernels/brs.log
e3c1cb3379580cf1aae44e8ddc8e846ef6fd661a573cfe0a8d4444b18a14dc56  release/kernels/brs.oracle.jsonl
75ab1441d47d2edd9448d4b9ed4d40c7102d84cbbe67ebfc6ca1476d677c2fbf  release/kernels/brs.sv-hosted.log
68c005c224764078dc691d2524cbe6b294c4d41815479bad56ce9732284ae621  release/kernels/byp.by_instr.json.gz
d9e6f3b7d21fe509e518a053e7870d77690f408594c9774cfad1308a287cfeeb  release/kernels/byp.by_unit.json.gz
7854d91e6d95d752645f7e735dcc1e962a38d1bb09ec6fb48206a278bbb3e2b3  release/kernels/byp.ccvtrace
3ecc9c08f7cfde2a0f6b8ee1f2a1952f59f35822cba4f8969e86a430e7e2031f  release/kernels/byp.log
5a03dfa4f3603fef49f1e3639e74e34152ca3ca5ef8e41eb959f8323040fa2d5  release/kernels/byp.oracle.jsonl
f0ff15f0598bb9a41b9f97d1d2cc08d437742567d9ab859678009d004b0febc6  release/kernels/byp.sv-hosted.log
cb078e0dd1f3d3b21f1f7f264797c64df2923c8ea1b4b605da7ad61659f9fdfa  release/kernels/callret.by_instr.json.gz
8ada5d5bafd79f902e98d0ccdeee90a40540e5be07f892635b6cb5add91319d9  release/kernels/callret.by_unit.json.gz
504e99d94b3e643cfd5ebe2a52859ea41ad8f70b9e4e4cf9b67c7951146680a3  release/kernels/callret.ccvtrace
aefd8eaf1e669bbff782b3744a6bbafac19388c63b48f852a6b15fbd7d8ff3ca  release/kernels/callret.log
9b1d1b50b527f732362f837250aa2f26dabf3e76e16a4794856ebd8f105635b8  release/kernels/callret.oracle.jsonl
7f7bdeba9c3436577ffecf9066e3f75f8528ffdea417fda2dc9cbaa886546755  release/kernels/callret.sv-hosted.log
800d3e45f06cfe07f8ec643e038df358e5f1aa2235144f102ee45b72fb435a64  release/kernels/cas.by_instr.json.gz
0daff883581aa807f5e06b1a7e9ebabd4f0a55fa076049ab19da930b05dfac9a  release/kernels/cas.by_unit.json.gz
1893b3c82dc7c02406c7199cfffb3adfc635b66ebd3b96d501e6cc36847f41e5  release/kernels/cas.ccvtrace
39ec35d29a1c9715bccdb97a259919de9598f7c2b9e51249d1426cbe7da9055e  release/kernels/cas.log
0ab31a9443336fe5d08e1a5fa5fcba3bc279b19022f7c5007908d39d8ef39536  release/kernels/cas.oracle.jsonl
7c02239914a6371aa2bb42101f4593546b4a46a40c3bfecbef6175137b443fb5  release/kernels/cas.sv-hosted.log
facbfb79a3c61d87690c660f6df3165e3252c57900be9e0073e582055914b39d  release/kernels/chains.by_instr.json.gz
785d77825e0071f132327be270e69402f328e3c7b4f925b2e46a11dcdeee8d42  release/kernels/chains.by_unit.json.gz
f3c7f719a83f93768af61373514062f1b4654c87caae7a6fd23d0307b7b7ca0d  release/kernels/chains.ccvtrace
1071a08f47b9278b831b63fd5c105b61c5dca451f9473f488a453351fd63b419  release/kernels/chains.log
26a4cc5c5524c7219d8706c2582c80357dea60be9d6ffdec99dac7d0365e2264  release/kernels/chains.oracle.jsonl
8650e8693c7492cf38ab7c27f9109e44ca504c26343d36c65e6b290a3a2153c7  release/kernels/chains.sv-hosted.log
320c5edc4fa3985fc813a46dbb91dd4c89a766f723387de39ab40392f789c6fe  release/kernels/coll.by_instr.json.gz
254a139d6db40a994a5e985de19cb05381f9a4e60a302a3d30038d0e892582ae  release/kernels/coll.by_unit.json.gz
b9d0aa1fba37d6865c6e65310ddfdec12b1a406436489ff0c4ce6a811c10cdbf  release/kernels/coll.ccvtrace
285cefd4c50fdbc81824e4b65d29164d2590be9af0411b25455e69fdc96dc914  release/kernels/coll.log
dd718d23c88df5dc7d92b055d8542865aa0e029118486af127312a8a578cfcbc  release/kernels/coll.oracle.jsonl
e88b10a77607c552f892a66f1679d0a43d14f8cbade505afdcc64f40627b502b  release/kernels/coll.sv-hosted.log
309f8f0e2fd680f2c84e275c6243f300441ace3c1f6d6352bfccca75558ad6d6  release/kernels/div.by_instr.json.gz
a9feb99b9dad78dc7542cef8c9d362afb9f5c59d642060a60eb1bfd263520174  release/kernels/div.by_unit.json.gz
0fa59319a49569c81f33bc11b669b5cff44d54af88e0e1a0318682d79a62911e  release/kernels/div.ccvtrace
81615197f54ed6b269be92b506e7362398b4fa8a683d072efd1f36b07d7a92aa  release/kernels/div.log
71a567b85cf85622631490187563de9a5661099c78a590adff4ed0a0c3d24c16  release/kernels/div.oracle.jsonl
31e7770f5c72b040d621ce8e9c3bde6dd7115988e6820b39800b9e92d66d272d  release/kernels/div.sv-hosted.log
a7839041a988db193f8c82be969baa5b8b6ef493db95e78e746bd8765144fb33  release/kernels/divchw.by_instr.json.gz
f8c0ae4e3e14d535cb347dd4824c47988ef6dd6f5542b71be1c1fa781fba7cd7  release/kernels/divchw.by_unit.json.gz
8e7c80075a58e2178ec583e92431374c169c69d30bb59740a5b1c545673b781a  release/kernels/divchw.ccvtrace
997142462f2c25c12d713636ea7832bf4332c9f3cb56cac3d739b17e91c23a03  release/kernels/divchw.log
58a541797f7a2df0a1c7528ae6a3edec212db90c7d3eb20656806f38b5c10b3d  release/kernels/divchw.oracle.jsonl
0960b88614e3e6f89071b35fdc6f7ba1e102376cb41d6014bad163cfabd0ee7c  release/kernels/divchw.sv-hosted.log
bf47f2d3c8e51b1dc9b389336481a22088e99553d2132761a415c71c001194f9  release/kernels/divtail.by_instr.json.gz
7ce82183aed0844649e246f2bcb81afbcc55231cfd61ba4c1b6972961a65b471  release/kernels/divtail.by_unit.json.gz
db804fbb5ad528ab14845763f37b3761a0b667c3bab40606320e4d62853ca751  release/kernels/divtail.ccvtrace
31e67bf14a0bb05d7220ebedd87360f548ffb9d319b8b9babaccaa3194a8838c  release/kernels/divtail.log
75f11a75c9b3b336e446140af4579f05b46c363a76b7aab3ec88154a07ba097d  release/kernels/divtail.oracle.jsonl
812d4cd87e2508e87a44bf0aea452a46191d07321532f98e26a4222f75fbab51  release/kernels/divtail.sv-hosted.log
a9131fcabb88fe2834163c03972cb5375cdb54f9ba7354a8dd4a108c1a990441  release/kernels/divtail2.by_instr.json.gz
42df078955e8cbcdf257d0f8bae9cb003bc2cb11604223f9add10cd6a27e52c4  release/kernels/divtail2.by_unit.json.gz
a75fe12547373cd47764249a890c8e2cff1203790b37cff1678beeeb1c5b2c44  release/kernels/divtail2.ccvtrace
0695ddbf13a2be63bcb5b8469e479d029efb3becbade6b06837af876d5671ed9  release/kernels/divtail2.log
b2db6b05eb6cf4a0a7677e31d0c6c2952d5cab49d353f0bb1883fe0b2a20ed14  release/kernels/divtail2.oracle.jsonl
3aa490d5378bc87173c41d341555813d8210b05719766685df1b2f3b7512b5d6  release/kernels/divtail2.sv-hosted.log
05486780da0b81de104065f943e5b0638beb06bf879319a1fca9513e577806d4  release/kernels/fence.by_instr.json
a8f00613557a2ae3bd48a002b1fbcd17ed9abebe06c4015d9ca4c5a8d025da3e  release/kernels/fence.by_unit.json.gz
4bbbc9787ee5f29e98ad0c7908f70e6a6b6e4343c3e9b31c9a2bb7800310a3fc  release/kernels/fence.ccvtrace
d5c151eba49a8a9fd2bcaed529c99bf9712f0eb060c7d79f0647be940d8112a5  release/kernels/fence.log
d1d40317f6cf5bfb430cda1f9c0ef676609e59cabe2a11623c42ffbeca93142b  release/kernels/fence.oracle.jsonl
7021b7214514eec87c3aab28081c7f6b6cee3a8711ebb127b2b1dfeec30a30b1  release/kernels/fence.sv-hosted.log
24c17cf8450f68bd2004eec35c65f0d2bddc04a36a3dee41ac18a0786b3ad48e  release/kernels/gather.by_instr.json.gz
51edfa59e6b79e64296914778829daa4f1d61f8cb72f9bea84d853c1c6a3d658  release/kernels/gather.by_unit.json.gz
c5bd60bc143ef04b1753cc3f90ffa792a0973077cbbb702413053a2365fba7e9  release/kernels/gather.ccvtrace
d5194010aea10c4dd169c8348a2c07fac2461c72f203f854cd46f09f26e369bc  release/kernels/gather.log
0413e781d8d6ff578c64eb1f800b7931e66f676d5cdabb97b94a4033e6037662  release/kernels/gather.oracle.jsonl
cf2f1804d33a17beafd600d1fe4a3f3d49b84eb81ee354ff14f418f78721a818  release/kernels/gather.sv-hosted.log
89b977a31f61c7a9dfec9f7416e93f02fd8f9e6d6c1ba2a4fe51a3cefcaf4090  release/kernels/hit.by_instr.json.gz
73ad1d9f0518de1cc08d65ec3a6e91ab7cf7caaeff98b5496e3af52cd7a548a9  release/kernels/hit.by_unit.json.gz
0dc38e18c8017b5df9c1e13f492952b8a32856a50ca7c93e09588648ac8ba525  release/kernels/hit.ccvtrace
1fc44bf0be1fd389e457d8ccea383e1301e8a003d164ee37e68cf0ee33b5f113  release/kernels/hit.log
7ba9603e0088d9164de6528f16ef6a7fa9ce5821c8c12b52cbb3734e39b9fd52  release/kernels/hit.oracle.jsonl
529e046cd658e3d57b0edd630753bf73204c961d73602ebbf7227fa63f3a9e3f  release/kernels/hit.sv-hosted.log
67cac2be2cdfbb1f3f40d053f1911e9a752aa7ae1f6f401e6aadded3efd897df  release/kernels/lanectx.by_instr.json.gz
560ec7f9087be6c21e580f812298af494627da399cd2ab3c9cd17194da955c14  release/kernels/lanectx.by_unit.json.gz
6f40f9ecca919305d45cc11467d071512e6eb9efc128c723c14440493b76aa88  release/kernels/lanectx.ccvtrace
e735311ace496e3d768c1ee355632d8126bc1a3e4cd8dc2ddd29904ffa63c420  release/kernels/lanectx.log
888551babf540db8e3025b82e65ca655013f93eba3c8a65689d069d52a7e6039  release/kernels/lanectx.oracle.jsonl
50ce4f868900b0cb3f58aacab71bef17cec74533789f054f267df73391bef2e5  release/kernels/lanectx.sv-hosted.log
fbe64a97e31d79a4e3fee5ce418ed737e21aed14ac59179b1f4ff96815f0faa5  release/kernels/lanectx2.by_instr.json.gz
fa1a5026e5ef2305f1d288b5fe754e49f6263fc2eeca094d2827b00af1a6f80b  release/kernels/lanectx2.by_unit.json.gz
b89c18d4e448ff832f7302ca5d5fbab66b09559f9da51bfd638adf0988de3b08  release/kernels/lanectx2.ccvtrace
48b773d19501950666e66006f4b94e561237239c6604d84b566c69eb634a0b02  release/kernels/lanectx2.log
45c13056dff5c73ed0c9ece56cc36f929bf335322193c7d5eb38710b1d1dfb02  release/kernels/lanectx2.oracle.jsonl
1e1db517a9aa1e618a971d6e4af6d87ccc3fee4787271e90724653ac31f88973  release/kernels/lanectx2.sv-hosted.log
f5b07cfc2262b02c6f8ed0cbc99bb2ccd44398af6d08093b28c5499d69123de0  release/kernels/late.by_instr.json.gz
3a8e074f01591a55a0bb431d09f729d93146b8db0f60b31b6b8ab4cfc52a06d0  release/kernels/late.by_unit.json.gz
3150d1a14537818979a2f7f026d60cd6438ca3c55b9b0412d08e1e30f3fbd1a6  release/kernels/late.ccvtrace
9491bea32f65526c2e0b8a7a2a29a0d831a0357edcc5c5df9e063f94d6f9ed01  release/kernels/late.log
86084f6bd747a2cf32acbc0ebd96ebd3e4ef2d8d9e21be49e3ae49290d7927f3  release/kernels/late.oracle.jsonl
4981f64567cf022100f46fef5e134ee21cb8a27fee7a2671c65e860d8e4d7b5c  release/kernels/late.sv-hosted.log
e2b56df8a15a903fc0f463cd25d8c0bc3cb315fcd3b51ecd0b3c0d46c902993d  release/kernels/ldpar.by_instr.json.gz
ec1f9fa3869f95961520e703c9398529412437fc22a9082b7f4e5c40a4d8fd11  release/kernels/ldpar.by_unit.json.gz
a2b5e71b0f55105c2e96369cfd9dfb104815f40746116d9d47271d86acdc8022  release/kernels/ldpar.ccvtrace
a4cdc99c9de7681c985278c21e36eaee4f9cc2faeb05f3c9eeb77ac25ebdea0a  release/kernels/ldpar.log
8ac08538e9c807637babd61b31e340f7461878ada31f0c0b83cd66331cfaf486  release/kernels/ldpar.oracle.jsonl
75310bc2b1de0d18ca038f34e808b5fa430e6e980aca3718ffcb3ee3feadfab0  release/kernels/ldpar.sv-hosted.log
665802e2713a914df886943128a23e9707999b314bac64f7b3e4bc2d8a39b150  release/kernels/lnorm1.by_instr.json.gz
e33d0e12aa31b031bc5b661b497b094b56ce036af3bb64781d384967e153e011  release/kernels/lnorm1.by_unit.json.gz
d422c136cbd36b101f834f19319ce9a6e5659ddaf311bf94c7fd1080c1693161  release/kernels/lnorm1.ccvtrace
d0a739d93639c819bc8fe49f7fe9ad3e9c2ec684967f11b88b29aa058999f000  release/kernels/lnorm1.log
a8d85811af988a1b9fc00db1517300af3d93ec8e589e403d3b9113fa9e0ffc86  release/kernels/lnorm1.oracle.jsonl
06e852a046c37a81603e2fc33798a9af8831f35d4ac024db901b163f568223a2  release/kernels/lnorm1.sv-hosted.log
ca3b214bdb6a6b8fc66092b4d85f7da2fe7e7c57b6f42be583c0f13e42d83406  release/kernels/localsp.by_instr.json.gz
8d45551e26232ebe17f2a6a38c3751c1174023b57d99e199a1233b3965d44747  release/kernels/localsp.by_unit.json.gz
04fd316f6ebb8d5f4656a1856afade1df3e44437c376c5981096b7efc62cc31a  release/kernels/localsp.ccvtrace
3214492c213370e4120ea36ba507fc0ceaba473843d18aabfc281c10df1fa849  release/kernels/localsp.log
55e3c9f36e7f7d38c0ddd38903aff4bb4509ae862015c592e6b937ea258042ca  release/kernels/localsp.oracle.jsonl
6b3110d5aafd7371f6cadb46f9d9824949b4b056c9cee447c13977f582cb3edf  release/kernels/localsp.sv-hosted.log
17293ba25ad81c78e3786855e8e26f792c803dfa3ba49c8eb69189b7e3d6ed80  release/kernels/loop.by_instr.json.gz
e828c32fe02d37dc757e49d41d23982cbd04fa0353144d4e205d259320207d58  release/kernels/loop.by_unit.json.gz
5ccb5d5561bc9782d51b12dc868841eac5d24e8def511a456e1670f8ad04f248  release/kernels/loop.ccvtrace
e94a187ada160d65d5bcd3c8f06f5041b92a1e8051e5bc30eae916488e0fdec8  release/kernels/loop.log
03ce5920c06c93e93516d8e53c3f7169f14e3593de204eacceffc0b8a3e32016  release/kernels/loop.oracle.jsonl
f408522aed49c5d6ba76fd7567fc8c173dedec8859c7c587f2d4eaf0e7b11df7  release/kernels/loop.sv-hosted.log
9decc5e05edf761647ffc2eafe019978c38fe90bc02908dbd01c2b088ed77a62  release/kernels/merge.by_instr.json.gz
943895a87ded2d18c0e04c22e2a3d5bbdc085c895c24f888c3dd8de0387a5679  release/kernels/merge.by_unit.json.gz
7c5c27b8590c634e6a6fa0ce6ebc8afed33e3101ca7690ecc2efe7cde41a32b3  release/kernels/merge.ccvtrace
08201903687955e0ed2d413ff714d06510114e44e5e2f0308d13698319898ebf  release/kernels/merge.log
f96d28815f8756b1f5a45ded53e6170883d2dfa10f9eef0d14b8050b1318164a  release/kernels/merge.oracle.jsonl
47c1bf571ec21ff6f43197464f831e423a3940014e868c360eb7cac00bc2a543  release/kernels/merge.sv-hosted.log
9b5756b89d35b323035688dadff2b1a05cdd73f74c50e1f9eb4293ac87a919c3  release/kernels/missrun.by_instr.json.gz
24681723d9366a2c7d2198babed5f7e30d511fa6428c83f66454408a2a70a79c  release/kernels/missrun.by_unit.json.gz
d0717cfc4e7e14e0a0320cd8119b57998e3d090c3d2a71b04969bfb560b0feca  release/kernels/missrun.ccvtrace
3ad2f6adc5744c343514396462da023bef5266bebc0f5ce69c769effeb53dd48  release/kernels/missrun.log
531bdaf281e5590774bd2775427f25e4cc0419cf8e3d5b6999843ffe9ef87258  release/kernels/missrun.oracle.jsonl
b0930f126cc620c82c61135d69f0d96efeeb7b4efedc4c117b6108c435f0efa5  release/kernels/missrun.sv-hosted.log
dc99c017432ba2e9be5699c274c3f6bfaa37e99f6ab2a8560cfd1ad51f5852b8  release/kernels/mload.by_instr.json.gz
e7f45ddc4e59887aa90f0924ceb6537c216a3f87544a8fc12f18ca1fba8dc218  release/kernels/mload.by_unit.json.gz
577a3a3b4df199ff847ae882b5c5a50fcd83c74e63da8ba04754d5c6e1775f22  release/kernels/mload.ccvtrace
64d159017070f72bd72824b61e12eef86183d307bdf37e69eed59a8b7d0f1c38  release/kernels/mload.log
8000e477b9a95dfb9f0af964e8346acb9d36f1358fd06ffc4ff7cf599d2b8868  release/kernels/mload.oracle.jsonl
b732bd6fecd810b4955775a034c11acdf518a09ad96e35fa5d40e7a8d3da37d4  release/kernels/mload.sv-hosted.log
44ad7743efcbd087d33d7ccee350b7da947f302f27f3f9b1c17798a754c5e3db  release/kernels/mlp.by_instr.json.gz
3135224532edcb180939fd3ca2b0eb8f29ccb5e9717670b1fbac8857d0c08ce2  release/kernels/mlp.by_unit.json.gz
3e6e19508e5cec05b2b2e22e9e847b4f99c95bbfe76ba26fef100f54e2682075  release/kernels/mlp.ccvtrace
23f04dff2a940426d3d6d47cae4842a6d52bd995e2ae4a647046233bb7388949  release/kernels/mlp.log
138d282f88d56c8ad648a91af0a983254b55d9fa22942c00d47b327f516a6e44  release/kernels/mlp.oracle.jsonl
09d2f853d8a1be534d875e985b06a2b26a641da9a72eb353b6ac5888ac0b72e3  release/kernels/mlp.sv-hosted.log
16e416fec0f13c3d7958c265f7bdfb036cb44f7c6685a6aea8e3936f29937a3b  release/kernels/mwmiss.by_instr.json.gz
181ed9fd68534ee4304c2c188c89257a8351c58bb98def11d2cb11e6fce26a57  release/kernels/mwmiss.by_unit.json.gz
a4a5e0dea6edc9552a29effd74f49f1ad3d2279d61d60a0680a50e5ec98ca3f1  release/kernels/mwmiss.ccvtrace
20f35346c66bdbdd919144912946177e2696bd32a6cf1f06b41f6f1999ea052d  release/kernels/mwmiss.log
8abe8e8997456a2a6711ee72da54d854b24e20abbdab28e4b7271c0d28418de8  release/kernels/mwmiss.oracle.jsonl
7e50a72b03b0be7dd628bf4cfd742bdcaaec75450b6526c668a227434e8b9759  release/kernels/mwmiss.sv-hosted.log
93ced0a6e74d329bab6e76778a5ddfa0229c24873768ab4687663d61a8da41f8  release/kernels/narrowadd.by_instr.json.gz
5c5d13a4680dbb91e654ef2710ff4278290f63497e1b4bc7e4d52024ef14342b  release/kernels/narrowadd.by_unit.json.gz
37d15e65cb02bccc001898996b6f8c4fbaaf3c7bf6f33f5629f7e1d886be38f0  release/kernels/narrowadd.ccvtrace
31424be14048d656b6701cd7e694b0f4f7d8baf2da2954f0359d592406461012  release/kernels/narrowadd.log
40a2cf629853dd404bb06b4a07e35abde3d12efc13f26ffe28f923daf2994574  release/kernels/narrowadd.oracle.jsonl
53df20b9cd63e840f5ac6b5240ceb32f582db4226040d4852b7d99c10e5eeb99  release/kernels/narrowadd.sv-hosted.log
319c3e07aa30de687b1f9e6312d7fc22efae0be326f0c15eeb66dbeee5536705  release/kernels/pguard.by_instr.json.gz
d2d7ff3c723aaecdb1745a2a82a2a4753b684781e7432631dea21724e942a390  release/kernels/pguard.by_unit.json.gz
f4d640eb3c718814f8a0082210a5b32b641049e7be155f3aeb43314a46416b2d  release/kernels/pguard.ccvtrace
14a7f102a969b1be10ea00f9adfb163b0adcc81cfa931f1743034b12fb04e937  release/kernels/pguard.log
690e56f1cb8d97cbf67124b7dff3ad0a90cb8981814cd1709cf0cd0e035b3bd9  release/kernels/pguard.oracle.jsonl
0be7511c8120dcf827c361843cfe490c028dc87083c625b78b182a891806af45  release/kernels/pguard.sv-hosted.log
317e3fb78f30a00ece092f03c31423be3d71d0fb854ee0776364f0e6d6f64297  release/kernels/plog.by_instr.json.gz
6c5985a7ce02936ef266925d138e0d850a4473774708c04e3c5bac0f2eff634b  release/kernels/plog.by_unit.json.gz
7823562f75147705b01f772471b6175774023d19935926703e158062b24cf94d  release/kernels/plog.ccvtrace
fce73792136c0b2420473d2c7d32e764eb7a5448713443f6f96626c5a833fcba  release/kernels/plog.log
0c99915e2da60f4670da00504a6371d7d17701d4431e733a3ff8fa98a2030d6a  release/kernels/plog.oracle.jsonl
e67d1c409316c6d60e951300c8f8468d06c8abd5952818c7fdeac7ffbfab437a  release/kernels/plog.sv-hosted.log
4e49905ec2e473a36367e9fc998bf4d5dd4ca0fc5daf1bb597067500fe8d0b3c  release/kernels/pmovdiv.by_instr.json.gz
8ddc22137f290205aed7d4de0555b9718cbf630ee7ff5e5c7ef4e2c21f2586c5  release/kernels/pmovdiv.by_unit.json.gz
da1865544271c3c70d3eab1061f5060d833a856975f75b28d0921880ec954a97  release/kernels/pmovdiv.ccvtrace
f9642dcbf3eabed260ae93977e524cee52d2c34c29742a1eaa48818051383980  release/kernels/pmovdiv.log
7bc646cff6166a51bdce03d7c1b7209e871f0a91d743083a9b910a80bcd0b33f  release/kernels/pmovdiv.oracle.jsonl
361cc77df1d8ed54890b5e5ab8ad07608282e483706c4989a334b737c6678e47  release/kernels/pmovdiv.sv-hosted.log
e396234a268597a330445331608c3440cee99132f32733a26001d59b435e2952  release/kernels/predlane.by_instr.json.gz
cec5ddbd26550f167eba5c26c22bc4632366b3663c2d1c5356fbce8abd1fc9c1  release/kernels/predlane.by_unit.json.gz
92b2b1101f673248f8b28d88093d2a180c8d0f30d92fbd57a2fbdbf50e68708e  release/kernels/predlane.ccvtrace
b127e57136cba295f9c0ab48654782b23339ebe3ce02196e146200daf6ad9ad6  release/kernels/predlane.log
c45f4177b9e84fc8a6e36b13534a0c7636eb30a3f8531847100ce5e23bf404b1  release/kernels/predlane.oracle.jsonl
8258f8e93e58e75554da697ca50231b3b76d8e363d661cfa0e1d01b918ddeba0  release/kernels/predlane.sv-hosted.log
3c568c0f76d099adae092f6a0fc415019b2d3d4cf3167c656ecc4ee718bda53b  release/kernels/predmerge.by_instr.json.gz
69e414ad84169c4c15839f14ff7db100244aa344d6ed7a8c937d95a9462bd4ba  release/kernels/predmerge.by_unit.json.gz
bb3488ce2d30e744c014d06bb81053f2bc8f09237e4066530c9459a0da2002af  release/kernels/predmerge.ccvtrace
3117c04836f584acb570dfe23790f0d639cd186dcf2bbe6292c808b31a72910b  release/kernels/predmerge.log
6c737c49434bcd08e3e0814c8b1dbf15c586ae74f7929ba3148ddcee2c62c845  release/kernels/predmerge.oracle.jsonl
761474858cd7f2e504138fc656309c6d0a13fbf28c1b9226c227fe977d48400b  release/kernels/predmerge.sv-hosted.log
948c8318b2c429f9e55a3a85316b4822f73eea73992045d3751698e5e78f3c84  release/kernels/predspill.by_instr.json.gz
8ca2c128e06ad9c8d2eb07081f99a5330ea5e4524baf5111457790d44faecbe0  release/kernels/predspill.by_unit.json.gz
bd36b4bae813afe5b9524ef4c5e637d94c88c266a7d87c83da36c64de27ab139  release/kernels/predspill.ccvtrace
c8884c336011166faa597dfeec678a09bfbdebd846877c0a58608c0d70a0194b  release/kernels/predspill.log
b7c84c6478117ffa0f06da0e6ad1e4628e2683426a7911080810e78e06a5242e  release/kernels/predspill.oracle.jsonl
fc702695e32778f022c651c0a22b8f3a8580761c0537cdf5d486540799209582  release/kernels/predspill.sv-hosted.log
970b37ac48aabbaab23c5e15cb5a0b83aa92ebda0fcecf6994d2b232013c9f37  release/kernels/predswap.by_instr.json.gz
3e4ccaaa5282e08528b868aa0f296e9e34e8bc694336416535f260cd0bafdd71  release/kernels/predswap.by_unit.json.gz
1b895deff4b6c3b0086288d4122e89896df7658dddd19c63f5de3cf16964591d  release/kernels/predswap.ccvtrace
c6975938db0f93308dfcd1124d846026c2de585426cab634c79b3d50bfb06229  release/kernels/predswap.log
a6d4f7ed517553816d889c7c9eeb6bcfd1f6c973fbf682ecb69f3c2de619f7bb  release/kernels/predswap.oracle.jsonl
9c62f9edf48359ed26aa8d54c9d9551e5064aec28ad7e116193088f0f880c39b  release/kernels/predswap.sv-hosted.log
b73eba69094de0e59936c4a8ef1d31914b340c55e56b9f84985504c78ee0695e  release/kernels/privwin.by_instr.json.gz
f92ed1e14fb1c6152c1d49b4142f4388d9a00ac22948701132a10edfb60eac72  release/kernels/privwin.by_unit.json.gz
2339e4f77834724f7ca0b9a0d955b1c914624b8490b494ffd185c449c385e7d0  release/kernels/privwin.ccvtrace
f1aaebbc4c1f2edbb5b2bad353d56fd62228273e6a633e65bacf3dc42ad35be2  release/kernels/privwin.log
861f686fc4480363472908d679d8815e8c957d768e7ab32c826930527b0fb7a8  release/kernels/privwin.oracle.jsonl
765353e1b72ba23261b210e0e34fca86a328d52915ed5a7ba18d55e55bbf2794  release/kernels/privwin.sv-hosted.log
82fa50926dd5b6678783e73752c3929118f62206a4e09e079401d17dbb511dc6  release/kernels/provswap.by_instr.json.gz
13169879b67fb704b6a0d83eea4c548d66b49795e6fa7db1b331445e85cba309  release/kernels/provswap.by_unit.json.gz
02e0c17e77e0ab083cd97178c0672cfddb701e2cfff0917244168e93eaa88ec7  release/kernels/provswap.ccvtrace
cbb21fcfb5a6bb46af2371254ba273a19453914a8bbc7bfb6005a2edfc0e4bb8  release/kernels/provswap.log
c9c32a793d54cc7401477f582487f7e8b345b2669a75337b8d6327120d98e5dc  release/kernels/provswap.oracle.jsonl
5ed399469572839c775fa937715d4b2988e25c5d1587633da741d47c9143c110  release/kernels/provswap.sv-hosted.log
7f93cdb29d3f4bf4bcba44d5bd3fb9809dc7f486c2982729d6d21797057f0c7a  release/kernels/retmiss.by_instr.json.gz
d7ce173a44361f61092d2ecb0f3c27a455eea156008169422686466d7414ff18  release/kernels/retmiss.by_unit.json.gz
6f094a4f42860ec13c8ed55dea19af83f02ec10f90dd9c8821ddc2541fb1a78f  release/kernels/retmiss.ccvtrace
3f8dd47fc4baf85f388823b2e1439fb26d24fd5783b0177f10c0aac6f28451d9  release/kernels/retmiss.log
e5ef8538e838c6cff7febfc679dd091cf5e002f82d34f1009b1948ce22bc3649  release/kernels/retmiss.oracle.jsonl
a1dcd56cc699162db8afa83bf42fb389dbe0c19800bf49959fd3872dbfbe6872  release/kernels/retmiss.sv-hosted.log
b8af37455b33a1b36ab55a477d4761f76bdf9dd3edd8eab5fb7f2c3731ac8ec5  release/kernels/roconst.by_instr.json
357217c72037a713eac0a6b7379bf3c587e1d0ebddf2552663b36be17a4792dd  release/kernels/roconst.by_unit.json
47b4c352cdd47d93bee09cc71530c77fe68e1a5ae74bb3ca0570b6874a7e15f9  release/kernels/roconst.ccvtrace
57b85fe6cf8d26e82ba1e0140a261974de617c80d9176502efb483f36c6f66c8  release/kernels/roconst.log
8087c0671de620162881aecd38cd6114b78e7be6bd71201e3ec02c9a2e2e750e  release/kernels/roconst.oracle.jsonl
e796058f48405191f8d9afcc0d499f0739b54f398446e4a6ffe248271732e628  release/kernels/roconst.sv-hosted.log
10c797fb8d044649f6d3dee9c07281c225794258b33e21124d781108ba92c747  release/kernels/rogated.by_instr.json
2fe96a27af8bc59f9d9b4d3c8784ddca5d0af3b6155e18bcbc0b78e18012fb0d  release/kernels/rogated.by_unit.json.gz
0ab8c9db689bf21fd56c52f465a6c5f8c69b0be064eeb18df72dd1a19a76d664  release/kernels/rogated.ccvtrace
051300c448c5db42fcc04213a167241b230dfe5d748d6f26e468553992c8b4a3  release/kernels/rogated.log
7cd02bd4cceec5a044d6b4d6a80df1e68ed0ae71b0b2a953143636d5b809ea6c  release/kernels/rogated.oracle.jsonl
1c42c9bdba0c465234ca9a572a196a698fba8e4169576984dc3f142a7aa50e68  release/kernels/rogated.sv-hosted.log
0066697712e51357fac29035b677bdfa2777690164b58ee4b2924f3fddb7dff2  release/kernels/rokill.by_instr.json.gz
882c08f7a143e36dbb2aa99a750ee61198a0845741ef79e4d80f4e1e0bae5857  release/kernels/rokill.by_unit.json.gz
f6f31e59954f2b7c0208dff6d34443ba005176245081f039702dcc2576a7b35d  release/kernels/rokill.ccvtrace
9a596a570b9099f28c78a55d33ed622aa35b66b87c3fb592309edd1880c98cd3  release/kernels/rokill.log
94efcef96af469a512d346ce61623980fe86383188eaebd55120f716db596f14  release/kernels/rokill.oracle.jsonl
f637476f0c344dba551c9de87d869355b484e18e05223b77d610e9ff615a39f4  release/kernels/rokill.sv-hosted.log
c2445a2b4f69fd127887e9d9f4f931c91ff4f80dcfa731420632ca601e4781b8  release/kernels/rokilllane.by_instr.json.gz
4cdfb3035b39cbc1436cec495727bcaaa8d8cfa8052638c6e52abc53e3ed3045  release/kernels/rokilllane.by_unit.json.gz
6385817a65c730b80aae4122e3d074d9e66b3cded81d6590e7d00efd695ee3a6  release/kernels/rokilllane.ccvtrace
0ccba8f24327da4d13b46d89757e59742604e3c1d879430171f9734f9d759221  release/kernels/rokilllane.log
f5ca6e666eff2f44894df74a291b43b3c0e7be0a63a47d795fdefd7b22016f45  release/kernels/rokilllane.oracle.jsonl
00ffd69b44010788a604bf45ecd091f728bf5a456e1b92b6fa6b5118c663833d  release/kernels/rokilllane.sv-hosted.log
6018676757a05a45231fba12ff6df60d07f415338c1d836cc09d99465b73577e  release/kernels/rolaunch.by_instr.json
c157f1e2326322de8cacaafbdba5687d5c865c70a997834aacd3bdccdd2c43c2  release/kernels/rolaunch.by_unit.json
0ea08323eca54b8dd88d2d98eca12c9667af542f5d0e0ca282ee2d5f57ebbbb9  release/kernels/rolaunch.ccvtrace
84ff79f5706a00d46455306ece0a4ea316b71215093870b47f9e597d50d1807d  release/kernels/rolaunch.log
e7dad585c3e70615de04330fd03f4f282c29a005dc1732a35655fb261d51139e  release/kernels/rolaunch.oracle.jsonl
5391c48a4fc8936eef35670a47e08d2268de1b96f03c4341c7c0dd5dbc6e413d  release/kernels/rolaunch.sv-hosted.log
b8af37455b33a1b36ab55a477d4761f76bdf9dd3edd8eab5fb7f2c3731ac8ec5  release/kernels/rolimit.by_instr.json
0358cfd1bb137c960487c6e1fa8b074623c904e538ad55b630bec3c9f7fdeaaf  release/kernels/rolimit.by_unit.json
bec85876888b4ea67e5cf81aa88f160350e676db544d7e6924a539ed277454d7  release/kernels/rolimit.ccvtrace
1e3180dbee8f4902314542b2f96b6c40105d08f23e5fd895969379a15af7b64a  release/kernels/rolimit.log
1c5bc0cb8e8b2e69505fb5a551a16d5d10c56f232b88da7a27e336ad7d962de2  release/kernels/rolimit.oracle.jsonl
227598fd5f83fb39d0df481faee2e8c2f5dca868ef6057564660dcd6bded2ef8  release/kernels/rolimit.sv-hosted.log
51b1b4d07788e3e33ca0fcc6d4548105eca529cfb3002f67f8bcb82a613b9e4e  release/kernels/roload.by_instr.json.gz
65cc979b74f2f8c2c3e4188d60fcccca69a1a55147c6222a3504feba79cf4156  release/kernels/roload.by_unit.json.gz
554fe7b6e3b718a63b278da46b9e3604fa927d3d8c9ffefa5bbfeb7a4dc44b1d  release/kernels/roload.ccvtrace
96c4b129eff5414d204212def54c586380f3c05cbd9951164ad72502fd3a2222  release/kernels/roload.log
f7c1309cc9764769fb5803f6fd0f2f5e1eb418f2d23fbe5e17cf5f9106869fdf  release/kernels/roload.oracle.jsonl
e2bf2ac41fdc1f777fa21ddc270cad43e7b7c05f2a1da497166ea5961f374ef7  release/kernels/roload.sv-hosted.log
e8baeee5f5b0f2fae10c2be2655856192e21aadfebfe889d6705d6c9202fecc6  release/kernels/rope.by_instr.json.gz
50fa9f61c998eb469d2693d2635e3eabee9509c8c7a1da4d55e7df7241c18ab1  release/kernels/rope.by_unit.json.gz
f6ad18f23cbb4f20646d227ccdfacf36a783264a77ec6b93da0c847ff2ec40cf  release/kernels/rope.ccvtrace
380567657c67674a5924c8de3142bb1cfcdce170b9b6d6c6d7d70ba0ac9e1d0e  release/kernels/rope.log
d55f9efae392dc8877c102c01c0810e7654b666b6ede386328108164c6cf88f3  release/kernels/rope.oracle.jsonl
e99c81111fd1e52b43bb7454a40363552830c144aa19608fb5f7a7b58c0acd9d  release/kernels/rope.sv-hosted.log
c3e81c9bfcd5cf85b3d93075d58f08cac7700f52949defadd706c910272033e6  release/kernels/ropediv.by_instr.json.gz
e37221a4ff8ef6ea7d5d17608106bd4042761a2bd7a2bf95048ea57643cf5dcd  release/kernels/ropediv.by_unit.json.gz
10270e50bee5a26190cc449f04d57fe36983c509a3d0bb7ac7691f51d85d29d7  release/kernels/ropediv.ccvtrace
b5b3bb080662995c1e82d44788fcd18c85ab7330784a9c87d0a7c65f2fa6b49d  release/kernels/ropediv.log
10c0ec6ec18b7b44638c790033109198c079d07c1537bf193353ccedd00a920f  release/kernels/ropediv.oracle.jsonl
329e74515a433e959c54e5073f45fb53b8a888a61783156f3d31c2b29210d735  release/kernels/ropediv.sv-hosted.log
1498dcebdc51c9f01e28649dacb4cd3c117b55c51148ecfcc2e1e8d785401d46  release/kernels/sel.by_instr.json.gz
713dffe736bd564d87caf7691e86033016b7b2d21feb6295fa493033340190e3  release/kernels/sel.by_unit.json.gz
b7e938279e58c029f621fbf246c3b68cf5aaa826d23ced0b0a274ede1db13213  release/kernels/sel.ccvtrace
76bfcf4f67ade9999d2e200cb11c6e2760b56784e251e72bd3f2c879e302d63f  release/kernels/sel.log
87f6a81e8afa004c8039bf2f61c90176fcf29ab29bb17ac44aa016a5cc8438fe  release/kernels/sel.oracle.jsonl
ad61fb9082172d7da42d8b1c32211a4c27b01ef11ba47fbce1b36575e51f62cf  release/kernels/sel.sv-hosted.log
fc1d247eab0ff4b0a7834307b8cdd6e41db0f7424de33c8d617b69cd33c5d358  release/kernels/sized.by_instr.json.gz
b0aaf428aa25e3a1a8618057aea4ae7a31e606829dabd7fae0ef09cab1dc381c  release/kernels/sized.by_unit.json.gz
a9843b2c4b46306b93b260315a2e25662fe5ac93fba6fa497b21ab3c58384183  release/kernels/sized.ccvtrace
f870ef947cb0604135716c661909ef8498fe8df114fdaa33ca39c34a5942b179  release/kernels/sized.log
36d903ba1618bd1faa437c9812a6ee6c0c966a63196c796267d74bf2695ebc3d  release/kernels/sized.oracle.jsonl
0f6fd429759989e8bdabec138f6e583ef416edfc934cc92626f3f5ea2c688d01  release/kernels/sized.sv-hosted.log
aa806a9b3716b8d7bbd5102b8494732ae8becd0aa54a3aa0a26eb2846e28b591  release/kernels/slotform.by_instr.json.gz
39fd31e32aa27960db660191e217eb9ec4b8d8f6dc375d468b7788c1da26c7a7  release/kernels/slotform.by_unit.json.gz
49d5e947563620dcb299762eb88ade65677dd870ace74045f1b273538b7454c4  release/kernels/slotform.ccvtrace
b4040cd098f4e0f0e565120d4d30c0aa17e1e98546d2f6a7483d1c15b7059816  release/kernels/slotform.log
8b61db7419b18cea8a646fb628218447e72e84a18a9891ffb73b441736138ab9  release/kernels/slotform.oracle.jsonl
b97e6e63187b54b3c4a8a5c0e150244955b902c2824fa1ac3af2928d52f2aada  release/kernels/slotform.sv-hosted.log
ccdebbf733b5391b586e41bed55dc444de987fc850d3459e5322d20f68bc85fd  release/kernels/spinwait.by_instr.json.gz
bfa200767372ba66ab8de1a85e633959181ca7b4000c7eea867c2ac44e9d3e10  release/kernels/spinwait.by_unit.json.gz
25d95e4507c45c2c4ab004660dde0c9b71c5459ff3d1e80dab0c1cdf325b7c7a  release/kernels/spinwait.ccvtrace
71955d7ef2a895c5f9040efa64b99fc3f99817216f17d7697f7a9fa3fbe5ce41  release/kernels/spinwait.log
868920637236c878b33779bd450439466fc3626996a3164573dc11d437d5c709  release/kernels/spinwait.oracle.jsonl
2535686904cbaf21ac037418db3bd1d77d208aa49102767ebc1ea65a38b56047  release/kernels/spinwait.sv-hosted.log
eddeaaa7c434767a8a83d6b6f5996974eaff89274e20cf2058c1f3db3b25adfb  release/kernels/spmbank.by_instr.json.gz
e1d560f471208d49a5085d9e5cd9d6d194e4c9e6b20705e51695fc646a7aebb8  release/kernels/spmbank.by_unit.json.gz
0b63ddd199108d5d57dacf8da3b47f37f0c4b36c8ae2b2605a61415aba0d0ef1  release/kernels/spmbank.ccvtrace
47a51d46324799a1441299d963ac682668e5144511f0c6adbc7c5f05cfde90b4  release/kernels/spmbank.log
3af490cc37d7a92dbe719b57de216b648536eb301ff9d13de9a39f50d150d725  release/kernels/spmbank.oracle.jsonl
9123c98c6abdd3c29f778cf2a27dc0718b0e76be58254a4c4390688111b0ea98  release/kernels/spmbank.sv-hosted.log
900c454d52d6d26062f82cf54b7ded930e5ea399be230f9186724b19dad79094  release/kernels/srd.by_instr.json.gz
e32388493621fd933983863fb245ad3fddf5b3ca68ca6999a9a611b41aaf4b52  release/kernels/srd.by_unit.json.gz
12ffc6ad91eddcde92d30ac0bc8db4c6cf9ae295413afaa6724b94542c6a18dd  release/kernels/srd.ccvtrace
f6416314b973f09e784698fbd512b5d507663d6289fda66ef3a373507db4c579  release/kernels/srd.log
b08eb5e3673cac7eebb8b72af5ed3783c8e70a9e96592e76bf3722551bc79473  release/kernels/srd.oracle.jsonl
22780556d2a2ff2d09b9b12c75e03f78f4b96aa2693e740c4d4c64fbe176b8ab  release/kernels/srd.sv-hosted.log
4a5583d5a99919ac97a3ef941e23d2fe3bc5ec90abb54163c3665698dd75d59c  release/kernels/stall.by_instr.json.gz
f7dc1b0616c1a572d4f4934a3e65fec08e56436595177a09a34d6cbf8d9664d9  release/kernels/stall.by_unit.json.gz
23d7fe29679d4f66c856d1f3771699f36fc83063bc591f46dcf0b1bbd72faef5  release/kernels/stall.ccvtrace
c8706ff35c555867b855941d01bae477836c6066dcc21162690cefa859eb6ca5  release/kernels/stall.log
500db2c482b07a0706583422cd68878301d0146c1f872ccc1f11bfdcf5c993ef  release/kernels/stall.oracle.jsonl
70ba7eddc00307cfdba3e8eb71c4d2560093d1e4a576d69c3c40c3c1663230dc  release/kernels/stall.sv-hosted.log
577c61cdadecde8e38a6ae9557fdf0f78468923330c44865cd027ff081098c5e  release/kernels/swap.by_instr.json.gz
bf9079a5c571a6e4ad3d1f838dd3e5e8e090d76ae44b90e16908e2934941db60  release/kernels/swap.by_unit.json.gz
73f0439a3c3728b551849a9dd1cc3ca4f6e7f7aab68ba4084ce43f4f711edff6  release/kernels/swap.ccvtrace
aa7f9c5fca7a2cd62cac9a0852deb8d7a78eaa8bd9558253470bd1ddef368509  release/kernels/swap.log
3658a26316c1ff7bc1744304a42f736e930fcde2865c8913e6cc67a22ce96667  release/kernels/swap.oracle.jsonl
c145b72e0dd64ba0a2410f9a94934c92f85017311b36c85f4d325b6fd1d04f93  release/kernels/swap.sv-hosted.log
199690411073de0ea8241d70aa561e4100c0405b5ab7f2d964265e16cffa0a6f  release/kernels/transp4.by_instr.json.gz
7d0506e5179217ad1180d51fefffc55ab08b05b00314f13b10099fa3c7080a9b  release/kernels/transp4.by_unit.json.gz
93e614f4cfab174fd368a701d37df0ffac14cf302353169a720ab414e9ac2c16  release/kernels/transp4.ccvtrace
0492ffd3401a4091d9edb60ba7d6acbf27725f2fba2c7a16b3ca5756304092fc  release/kernels/transp4.log
06396ace3ac19677fd39c700e408606e5bdbacb24997d663bbe8872e63dd74fc  release/kernels/transp4.oracle.jsonl
acbbcd561a93464499a8b5b0d32d01dd1cbcff8b65f341215d596f52c60e32a2  release/kernels/transp4.sv-hosted.log
174218abb41b024a827e792de4c7aa25b907cf507263db5fbb3b8f75b79e7a7d  release/kernels/unal.by_instr.json.gz
634147b9be829140e45dc5c69111d3e25bfa3b2f89de71959c1b1bd1d17ea88b  release/kernels/unal.by_unit.json.gz
52b05699065211ddb8b1c31f92005de7dc6eee7a77092aa25a03d8405c81c852  release/kernels/unal.ccvtrace
447df54bf2c8892997579702b96c4c6715ed968b0a2a42e46a5ab81ec9bd89de  release/kernels/unal.log
c3d484bb160657a563df983d9a2532eac27f556636617960aa1e72183ac2b299  release/kernels/unal.oracle.jsonl
fd807c61b8dccff5895c22032e0d47d49f939fac5351fe2be1179e37ac4d4710  release/kernels/unal.sv-hosted.log
6dd663630fa2f3b42222a6ac8cf93d5e15aac4edf1db05ab25e842f0fcd63268  release/kernels/vadd.by_instr.json.gz
7d1a5456c3d828005e06974d77aa1479c037a0a143a0cdad2fff16aacc7b56c1  release/kernels/vadd.by_unit.json.gz
4c225b6185d0ef923f0c26ccd6d22a7277ea8914d97d1e2a458467ad4812f40b  release/kernels/vadd.ccvtrace
816ca8b1fc9981ad0fbf1cbc3106a550567fc1dc29cc91f693c46cd12b1e218f  release/kernels/vadd.log
0276b6d0611a4bbcdc004ab3987214aea138245bc7217504147331689a9c0880  release/kernels/vadd.oracle.jsonl
dfae9bea862fe721a4da8bf4b94d4384e28699f11396251da18e3c839dd73345  release/kernels/vadd.sv-hosted.log
7383713dd70df655d6777ddf8eee24afdcc63f61772e2b8cb247c64e97dae9e7  release/kernels/vadd4.by_instr.json.gz
cc8f1c64ccc4e07838955b186fe4f3dcb3e5a89e5251114d68bceea1e19fe91b  release/kernels/vadd4.by_unit.json.gz
5dfa2ef9e17a34e3ebcd6851b1dfdd50fbe9981700aa8d4a493a13572ba48f9c  release/kernels/vadd4.ccvtrace
e967c36af6f8a33691250d8aad601a0e7d3a6a6677efe534bcf2b869f60fa321  release/kernels/vadd4.log
225aa18fc9f38aa9ad615aa11de254337d59fa705877553d873062c68366e0db  release/kernels/vadd4.oracle.jsonl
c40a5be788c6aaf439a6e01977446f2b8f68b56135ad074114922b00776f746a  release/kernels/vadd4.sv-hosted.log
cf36e2216b79b1f6c9651c865cb258627e3ca4aa71a5267c4693e9497b55a11c  release/kernels/vaddslow.by_instr.json.gz
776764f83da4a735ec78bc39c2c8ca64fd0d0c8e9f0899707dc54b162c93dbb8  release/kernels/vaddslow.by_unit.json.gz
25a16a9885807c4eb4ae66a1bde936ded34fef447aeca62f3277e0d4cd4766c7  release/kernels/vaddslow.ccvtrace
f5a5be824623d30d105cb768713256e36a0d8e6e0e5d3aba3771c362fa382d9d  release/kernels/vaddslow.log
e9e6218e8b8450e9f9ff6b39d659c994a1e51c527a0c5bd10d18b5658ae0e344  release/kernels/vaddslow.oracle.jsonl
a8bba42d5195298e3ead202b9bdfda05416ed5b98c3d8f6740a62669fc38d682  release/kernels/vaddslow.sv-hosted.log
498a2534f60db10c745424ab662d0f50eea3edc3a581cb406c377d2f7b0dbdbc  release/verify.log
fe1c1a586828f0fa7b9b7bb7e659648607ea83cfff7664dc3507dc413f8b11b1  release/wiring.txt
```
