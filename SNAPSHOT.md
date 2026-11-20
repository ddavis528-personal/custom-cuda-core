# Snapshot snapshot-2026-11-20-677852a

**A generated, read-only snapshot. Do not edit or merge it.** The source
is `ccr-9eb50716-lecnjf` at `677852a875fd43bad4388d1cd9461585de21d6d3`, and this branch is rebuilt from source by
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
| Source | `ccr-9eb50716-lecnjf` @ `677852a875fd43bad4388d1cd9461585de21d6d3` |
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
2f6f2389ae6b5bdadf499d898516e6a5083311a3a2fb79cb9c9514302f7033bd  release/kernels/addrhigh.by_instr.json.gz
9de8f36080b75c76395de439660d8c3c1e8380842dfa0c71c479780b0e53d76b  release/kernels/addrhigh.by_unit.json.gz
4dac1317d6fd6a40770d4e703058827a4e591e1673c43c6fd30755d00d10825f  release/kernels/addrhigh.ccvtrace
fa46bcd9a5088f228c969cfec9304f17afeebc4a33daa9677f827592d3a2236b  release/kernels/addrhigh.log
569f2e22883fad5f0956c57ec734e6afbdd4b8a854e50277425172d6c0cbd766  release/kernels/addrhigh.oracle.jsonl
d446f4c7b64f7c96fe1023b527c27e6210233a227c4ebbd829fe9aa3bc643d63  release/kernels/addrhigh.sv-hosted.log
5a8a04498f620c64d134e6e0d01e8db1cae0cedd41b9d7b57b83ff23877c4dcd  release/kernels/addrlimit.by_instr.json
761a3abeeebc4495d5de7c453b33f8234654d922c8669085185e010356412e8d  release/kernels/addrlimit.by_unit.json
a53be191c4e9c5a3a90b0569d777cfc0d4974f156e702139cd0a3cbe5e4a5045  release/kernels/addrlimit.ccvtrace
038288f91c887f83d2f9576cf5ac5acaa87bdcebfefb77275c2021b8b7352f0d  release/kernels/addrlimit.log
bc660b0b40359a2c5a2478cb0eb4950b73fd22db50ea76b80052bc195a1920f4  release/kernels/addrlimit.oracle.jsonl
289ca590f34c559018f6c2def1be8f4983fbd6dbbc2c362cb89ec0132c6dfcef  release/kernels/addrlimit.sv-hosted.log
d5ee993d0a633a3a0837df8a1267138a4a90d71b0f13f2964db1fac129be4751  release/kernels/addrneg.by_instr.json
104adae31ce78cc2cbcccb238d2e68f6944a9e3a7d1009f4c3a2eaca0df41bc4  release/kernels/addrneg.by_unit.json
0446b0e2d2af5b36c5a5ea6f83f1deb34ff1fd1fa93229fd0e9aab5274ba454e  release/kernels/addrneg.ccvtrace
0857bc896422ea13b682599b6e1bf53a7997598fef7f3ec30f6570ddb5f991e7  release/kernels/addrneg.log
16f5b0707ae44492a1efd67bb9dd38a7e79a7bbd354fa9207b9e7d150ff2f107  release/kernels/addrneg.oracle.jsonl
fc3b0ef8461c77ec54b17d78032fc693708009eb2cd8c9b707d0407b1e5ef9af  release/kernels/addrneg.sv-hosted.log
7fcc666c3351f2a12db21582412662324369ff061a6481229c7f9b450c05369a  release/kernels/atom.by_instr.json.gz
eead5f12719afdbf24bdb4fce92279cd531a1bc8d6fec27f52e3796eb22762fa  release/kernels/atom.by_unit.json.gz
0efec9401f542375a590011cc55578411be218ed9a6aa16ed4e2cff66f5f5352  release/kernels/atom.ccvtrace
27dc40204949f50266417ec2c20e5cf88ae6874bfc86cd3982d836d89a622a8c  release/kernels/atom.log
504f5b6e9d25114dc35f2c70b21bb7b3f3c508c691de12dc0e87d12a74285361  release/kernels/atom.oracle.jsonl
aeb2f4afc8b3b4674c183817811e82b2dc6740b9892fc289c34e86e3a4538dc6  release/kernels/atom.sv-hosted.log
cfb5621c8a654601f6ec45746da662ce8a1078ea558292da46438037319bcd18  release/kernels/atomf.by_instr.json.gz
7b8bc4d496d7bb798fbb979d7a9f91ef277d13d1d8b22dd3724c0c7d436d742f  release/kernels/atomf.by_unit.json.gz
35585bbd0deab31f1d8022e6ca44de0a62c59364d9524eb19562473c7e745908  release/kernels/atomf.ccvtrace
3be17514f8af420be71f711aac95ffdd7cd90e85597225e55834b6985cd31053  release/kernels/atomf.log
cfd1179edf4061a33ab2f75d7a6dec61decfe629000198189a7bfc2647b34238  release/kernels/atomf.oracle.jsonl
5a1a3dc5551778c61fe727f015e3f85de531d3a5938f50f8b075780ff82a781c  release/kernels/atomf.sv-hosted.log
9742ddb71fbc62cbf66092efa693ad9f8e0e5681b5ed7cdc0d48276f9c0997b7  release/kernels/borrow.by_instr.json.gz
9a5d8bf79512cc67a29265a5cacca028b5237cf68ab5f7e745112f96d8cfa46e  release/kernels/borrow.by_unit.json.gz
675e87f1c0e15b984bee253fff4849e79de6b07f83e6e28edfa102cf07f93b18  release/kernels/borrow.ccvtrace
f500343e555384b26a8c3fc102eb7bf952853a9a39632783e31f00834aa9d141  release/kernels/borrow.log
4c565e1ce0b3baee36e158694b32c8defb5cd662b2f9af75cb5d8c26cb1168ed  release/kernels/borrow.oracle.jsonl
0bb9452b8a6ab3224236dd67a34b394cb0c1ae620490e3d6a1d02fccb4edd2d6  release/kernels/borrow.sv-hosted.log
99503d5fa692df16af4e293339090c7d9bd5c6dc7061ad70751547d46c561ece  release/kernels/brs.by_instr.json.gz
39dc60fdf8171d191e1b0f79a622e481963c7cf7243c4698cbcbbb56d93864fa  release/kernels/brs.by_unit.json.gz
dfdc00e3f7e638e036c8544c04704d8c1d4cca764d189ea7aa1e0739036dbfac  release/kernels/brs.ccvtrace
9f25c640fdc5b0622626b9bc3638e49831755ee9dec3b8870c4dac09481171e6  release/kernels/brs.log
e3c1cb3379580cf1aae44e8ddc8e846ef6fd661a573cfe0a8d4444b18a14dc56  release/kernels/brs.oracle.jsonl
5d272e40d45b82e6c1afac60765487b59aa9832b146bef690b0e1e5b8b313ebf  release/kernels/brs.sv-hosted.log
03d30d5de26968ca1ac039ed23c12d88da18b0174f56702e156f05a303408efa  release/kernels/byp.by_instr.json.gz
cac448ec833f2d02a44fff16258ea15c4d38c5fb3d8eab86d1a29f5bbc4c1422  release/kernels/byp.by_unit.json.gz
7854d91e6d95d752645f7e735dcc1e962a38d1bb09ec6fb48206a278bbb3e2b3  release/kernels/byp.ccvtrace
3ecc9c08f7cfde2a0f6b8ee1f2a1952f59f35822cba4f8969e86a430e7e2031f  release/kernels/byp.log
5a03dfa4f3603fef49f1e3639e74e34152ca3ca5ef8e41eb959f8323040fa2d5  release/kernels/byp.oracle.jsonl
6f65156c0a95ad325a002301cb4d83881659bcd2b2277ebbb842160d71b4d6e9  release/kernels/byp.sv-hosted.log
ba0f26f8b393cee6fb7a0e6c7470b627f4664ffebb973ca30db96402a520eaec  release/kernels/callret.by_instr.json.gz
b10501564db828f6c06d8589954310c422e2fd55dea34e9384935a9a2731dd68  release/kernels/callret.by_unit.json.gz
504e99d94b3e643cfd5ebe2a52859ea41ad8f70b9e4e4cf9b67c7951146680a3  release/kernels/callret.ccvtrace
aefd8eaf1e669bbff782b3744a6bbafac19388c63b48f852a6b15fbd7d8ff3ca  release/kernels/callret.log
9b1d1b50b527f732362f837250aa2f26dabf3e76e16a4794856ebd8f105635b8  release/kernels/callret.oracle.jsonl
a47c9ce37852f8b6f48a07b71406af3d57d3bde73fc9c9b0efd60eb087966106  release/kernels/callret.sv-hosted.log
02d9e4c5ad0c9bcc2a77c069de1acf63248fe2e33613d0b49ec6b790e520880f  release/kernels/cas.by_instr.json.gz
c91d1a3bbb9b2b69c2d4424055ca02c466e7ecad7b4696516495d82460c502c2  release/kernels/cas.by_unit.json.gz
1893b3c82dc7c02406c7199cfffb3adfc635b66ebd3b96d501e6cc36847f41e5  release/kernels/cas.ccvtrace
39ec35d29a1c9715bccdb97a259919de9598f7c2b9e51249d1426cbe7da9055e  release/kernels/cas.log
0ab31a9443336fe5d08e1a5fa5fcba3bc279b19022f7c5007908d39d8ef39536  release/kernels/cas.oracle.jsonl
4c36c7388c1af9a754bf7963bdf8c569944ed16e38c933b24bfc4eeaff3ec78e  release/kernels/cas.sv-hosted.log
8ce2739d9fc8f4f8d14155fdf91f54ee9e1bd931e4762863a288bec7936da867  release/kernels/chains.by_instr.json.gz
b0319690b2b42750014bd89ee561789ae1bd374b83503e236362808fdeaaefbc  release/kernels/chains.by_unit.json.gz
f3c7f719a83f93768af61373514062f1b4654c87caae7a6fd23d0307b7b7ca0d  release/kernels/chains.ccvtrace
1071a08f47b9278b831b63fd5c105b61c5dca451f9473f488a453351fd63b419  release/kernels/chains.log
26a4cc5c5524c7219d8706c2582c80357dea60be9d6ffdec99dac7d0365e2264  release/kernels/chains.oracle.jsonl
005636cb750a7dbeefd7d682b7cf4be5764d8f3f70988e1efda1e73912e3c24e  release/kernels/chains.sv-hosted.log
58184f91cd55447e8814ffa4e446f5caf8a07f03fca7f0d619ee8b74d2f94d13  release/kernels/coll.by_instr.json.gz
5c3410ba345fd7e9054079eb94c2117ec2a326e25e0fe1f52d66d2f2899a0166  release/kernels/coll.by_unit.json.gz
b9d0aa1fba37d6865c6e65310ddfdec12b1a406436489ff0c4ce6a811c10cdbf  release/kernels/coll.ccvtrace
285cefd4c50fdbc81824e4b65d29164d2590be9af0411b25455e69fdc96dc914  release/kernels/coll.log
dd718d23c88df5dc7d92b055d8542865aa0e029118486af127312a8a578cfcbc  release/kernels/coll.oracle.jsonl
0c4ab6c7669770f1251de2af155cf0fe99a82bd7738d65b696d4ee9f45ca396f  release/kernels/coll.sv-hosted.log
7c603c1ce6672c8393f1672485848bf8aa5e9100c2b4ff9d521b24bccfbb7d3c  release/kernels/div.by_instr.json.gz
1b4880cbe1c4f1c7235700a6fe8625e923acfc0d12f45c18412415fa44ecb5d9  release/kernels/div.by_unit.json.gz
0fa59319a49569c81f33bc11b669b5cff44d54af88e0e1a0318682d79a62911e  release/kernels/div.ccvtrace
81615197f54ed6b269be92b506e7362398b4fa8a683d072efd1f36b07d7a92aa  release/kernels/div.log
71a567b85cf85622631490187563de9a5661099c78a590adff4ed0a0c3d24c16  release/kernels/div.oracle.jsonl
8894801f1989bafaa4e10ead3ea1d0b25b4a95bb03e8803557e8d711be65d014  release/kernels/div.sv-hosted.log
4e4d81be656f8b1ee0bcbf8fdcf4541e504cac373ed7c10b08b2ae08751ef519  release/kernels/divchw.by_instr.json.gz
1099c789cfb01ea90fe3d5fa05d00d01b641ac85a62d82cd17eec256dd9ccfeb  release/kernels/divchw.by_unit.json.gz
8e7c80075a58e2178ec583e92431374c169c69d30bb59740a5b1c545673b781a  release/kernels/divchw.ccvtrace
997142462f2c25c12d713636ea7832bf4332c9f3cb56cac3d739b17e91c23a03  release/kernels/divchw.log
58a541797f7a2df0a1c7528ae6a3edec212db90c7d3eb20656806f38b5c10b3d  release/kernels/divchw.oracle.jsonl
23fa3c7e69e0d218769660d638e807e1e0602f6c2b1748f5872e18dae4198167  release/kernels/divchw.sv-hosted.log
d1e2cb97ecbb4f541b621a7c95f743af13adb4087e962b82b5700de9c57ab7f4  release/kernels/divtail.by_instr.json.gz
4b2f51d85e1b67d13572f065059b9a997518ab3cfae175a581dfddc2c9a0da0e  release/kernels/divtail.by_unit.json.gz
db804fbb5ad528ab14845763f37b3761a0b667c3bab40606320e4d62853ca751  release/kernels/divtail.ccvtrace
31e67bf14a0bb05d7220ebedd87360f548ffb9d319b8b9babaccaa3194a8838c  release/kernels/divtail.log
75f11a75c9b3b336e446140af4579f05b46c363a76b7aab3ec88154a07ba097d  release/kernels/divtail.oracle.jsonl
696acbe577ab444d4056d332851798a0b073522b91253042c83ff5ef3dda2eee  release/kernels/divtail.sv-hosted.log
21437d899327264ab9314029c2e21f95989894e8a066a6b4dab57146dc4c6f1d  release/kernels/divtail2.by_instr.json.gz
88c3f3e70495117a36f9a6f626de775df6fa02c467719f66a9126b2917c8a59b  release/kernels/divtail2.by_unit.json.gz
a75fe12547373cd47764249a890c8e2cff1203790b37cff1678beeeb1c5b2c44  release/kernels/divtail2.ccvtrace
0695ddbf13a2be63bcb5b8469e479d029efb3becbade6b06837af876d5671ed9  release/kernels/divtail2.log
b2db6b05eb6cf4a0a7677e31d0c6c2952d5cab49d353f0bb1883fe0b2a20ed14  release/kernels/divtail2.oracle.jsonl
9737c2a63ebe0d106ef3b1065d3f1ba713cb69aa22d5c75a3ef6b73c7befb19b  release/kernels/divtail2.sv-hosted.log
05486780da0b81de104065f943e5b0638beb06bf879319a1fca9513e577806d4  release/kernels/fence.by_instr.json
ca23eeff4b70f08598b508465df482d8973b5c731c9a6f49ee685fb1ff8b6052  release/kernels/fence.by_unit.json.gz
4bbbc9787ee5f29e98ad0c7908f70e6a6b6e4343c3e9b31c9a2bb7800310a3fc  release/kernels/fence.ccvtrace
d5c151eba49a8a9fd2bcaed529c99bf9712f0eb060c7d79f0647be940d8112a5  release/kernels/fence.log
d1d40317f6cf5bfb430cda1f9c0ef676609e59cabe2a11623c42ffbeca93142b  release/kernels/fence.oracle.jsonl
81b454c1ad6b2bef3f3a3b795304519fef76d95273674f975b503fb60019d2d7  release/kernels/fence.sv-hosted.log
6cea44ac256c328ff43767a19d5d7baf52398466641ac54e4881a47ff3eacd90  release/kernels/gather.by_instr.json.gz
31424b906dd466494e3735154e07179952400cdc3b35efc47a070bc69f1da4a2  release/kernels/gather.by_unit.json.gz
c5bd60bc143ef04b1753cc3f90ffa792a0973077cbbb702413053a2365fba7e9  release/kernels/gather.ccvtrace
d5194010aea10c4dd169c8348a2c07fac2461c72f203f854cd46f09f26e369bc  release/kernels/gather.log
0413e781d8d6ff578c64eb1f800b7931e66f676d5cdabb97b94a4033e6037662  release/kernels/gather.oracle.jsonl
fbdbcb39be87801a7d449567163ca6a7de453bcf8538b53d7fe0584cb234484b  release/kernels/gather.sv-hosted.log
d1b97ee3e2a2e7214ff715b3e010439ee198fbc8894ffafd03fbc5b07fa10eed  release/kernels/hit.by_instr.json.gz
ed381e2da5da227aaf5f2c5108665c536005ef72c4c47ccfd427a4d2e186917b  release/kernels/hit.by_unit.json.gz
0dc38e18c8017b5df9c1e13f492952b8a32856a50ca7c93e09588648ac8ba525  release/kernels/hit.ccvtrace
1fc44bf0be1fd389e457d8ccea383e1301e8a003d164ee37e68cf0ee33b5f113  release/kernels/hit.log
7ba9603e0088d9164de6528f16ef6a7fa9ce5821c8c12b52cbb3734e39b9fd52  release/kernels/hit.oracle.jsonl
68569cbcf9abd0fe4e32bcf755682fd73401db110e1ee87ab3e8df0378faf12b  release/kernels/hit.sv-hosted.log
52f88b7d8b1b77077e1bfb03c5a500ee893aba236e4070cf47042a0dcc8c0bcc  release/kernels/lanectx.by_instr.json.gz
9b297904a3107dd9223d3673f27ebed1ea82a8579432f8ed2ed99927a2824b8a  release/kernels/lanectx.by_unit.json.gz
6f40f9ecca919305d45cc11467d071512e6eb9efc128c723c14440493b76aa88  release/kernels/lanectx.ccvtrace
e735311ace496e3d768c1ee355632d8126bc1a3e4cd8dc2ddd29904ffa63c420  release/kernels/lanectx.log
888551babf540db8e3025b82e65ca655013f93eba3c8a65689d069d52a7e6039  release/kernels/lanectx.oracle.jsonl
217da40170482ad93f0f34068afd4f5ccd1c6acfb521a118275c292821471f9d  release/kernels/lanectx.sv-hosted.log
bd9d9bc8dcfe8e63880f2dba6e19ee0eb14e2f502b7eb64406c859a8a7322724  release/kernels/lanectx2.by_instr.json.gz
16e3ea205447a02e2f15f197faf3a4f99707bad308c38131e629743a40e57721  release/kernels/lanectx2.by_unit.json.gz
b89c18d4e448ff832f7302ca5d5fbab66b09559f9da51bfd638adf0988de3b08  release/kernels/lanectx2.ccvtrace
48b773d19501950666e66006f4b94e561237239c6604d84b566c69eb634a0b02  release/kernels/lanectx2.log
45c13056dff5c73ed0c9ece56cc36f929bf335322193c7d5eb38710b1d1dfb02  release/kernels/lanectx2.oracle.jsonl
c720da391c98199b8fe1ceec92dcea4b35938de01e7ac218c35168a44c91c8fe  release/kernels/lanectx2.sv-hosted.log
87e7893e4d56959f1fbe6faef97f6c41cbcf5c123a920c05ba24f893586c041e  release/kernels/late.by_instr.json.gz
8949abed31d752e3ebb7ec0ac2571fcd3147f1226c378d55e00f822f48279906  release/kernels/late.by_unit.json.gz
3150d1a14537818979a2f7f026d60cd6438ca3c55b9b0412d08e1e30f3fbd1a6  release/kernels/late.ccvtrace
9491bea32f65526c2e0b8a7a2a29a0d831a0357edcc5c5df9e063f94d6f9ed01  release/kernels/late.log
86084f6bd747a2cf32acbc0ebd96ebd3e4ef2d8d9e21be49e3ae49290d7927f3  release/kernels/late.oracle.jsonl
9380739bcc78ad3063433ae84f83ce5abe12b11b6704c442ecd1f06996c6f6e6  release/kernels/late.sv-hosted.log
85d8c4345d27b3bd2ab3f8dabfdf057c7eb77128abed75a5834299cca644f35d  release/kernels/ldpar.by_instr.json.gz
af398cbcf8e160fd371b8eb13405535637eaa797066de959cfb5c915c02f47a1  release/kernels/ldpar.by_unit.json.gz
a2b5e71b0f55105c2e96369cfd9dfb104815f40746116d9d47271d86acdc8022  release/kernels/ldpar.ccvtrace
a4cdc99c9de7681c985278c21e36eaee4f9cc2faeb05f3c9eeb77ac25ebdea0a  release/kernels/ldpar.log
8ac08538e9c807637babd61b31e340f7461878ada31f0c0b83cd66331cfaf486  release/kernels/ldpar.oracle.jsonl
6aa8c400d2327ee455fbdaa7f96c7876842af61334d9489aed17d45c3955a6bc  release/kernels/ldpar.sv-hosted.log
f1c818f239619befffa71b3e90b317af72f9fc749497909eb3111c8a9791ebd5  release/kernels/lnorm1.by_instr.json.gz
433691d11e821b4b837641b99ffc52151e1ff746ba4c84ebafa054f1378f8e6a  release/kernels/lnorm1.by_unit.json.gz
d422c136cbd36b101f834f19319ce9a6e5659ddaf311bf94c7fd1080c1693161  release/kernels/lnorm1.ccvtrace
d0a739d93639c819bc8fe49f7fe9ad3e9c2ec684967f11b88b29aa058999f000  release/kernels/lnorm1.log
a8d85811af988a1b9fc00db1517300af3d93ec8e589e403d3b9113fa9e0ffc86  release/kernels/lnorm1.oracle.jsonl
d78a58872be788de17af82ff2985503914bfd0361c0e461c75835ae493d871af  release/kernels/lnorm1.sv-hosted.log
58cd3186a93ab510042f911f4f24d3fc60f3f7c858f5b010c89006f0a3360a53  release/kernels/localsp.by_instr.json.gz
693395ecea8edd5d96e703a3171c3376350f8d0ec60e27ed8d28f132637dcbd6  release/kernels/localsp.by_unit.json.gz
04fd316f6ebb8d5f4656a1856afade1df3e44437c376c5981096b7efc62cc31a  release/kernels/localsp.ccvtrace
3214492c213370e4120ea36ba507fc0ceaba473843d18aabfc281c10df1fa849  release/kernels/localsp.log
55e3c9f36e7f7d38c0ddd38903aff4bb4509ae862015c592e6b937ea258042ca  release/kernels/localsp.oracle.jsonl
79ea7d5f15dff44279d7bc448dc9d91afafd994d058d98a2ee4fc9de2ee5a9f6  release/kernels/localsp.sv-hosted.log
bafaa4fe70bc0a74c2457cecb7eac86cd4756b996bcbb164ac1b631911e9844b  release/kernels/loop.by_instr.json.gz
aad533180b7f5898a0ae2c0b77fc6bc69dcf843f6dc792426d595bbcde96977a  release/kernels/loop.by_unit.json.gz
5ccb5d5561bc9782d51b12dc868841eac5d24e8def511a456e1670f8ad04f248  release/kernels/loop.ccvtrace
e94a187ada160d65d5bcd3c8f06f5041b92a1e8051e5bc30eae916488e0fdec8  release/kernels/loop.log
03ce5920c06c93e93516d8e53c3f7169f14e3593de204eacceffc0b8a3e32016  release/kernels/loop.oracle.jsonl
4fe4a7f792c22b50ac539c660c1986ca0a9243d09cfc114e2530e2fd516045d3  release/kernels/loop.sv-hosted.log
53771c381ac92c4ce1b5c4c7b72709b5070dffb02a91dd8a8ee921e7557b77c7  release/kernels/merge.by_instr.json.gz
b206aefe53f6ca9838fb975edca317d597dad01748f9c08cf1d5454000eaceee  release/kernels/merge.by_unit.json.gz
7c5c27b8590c634e6a6fa0ce6ebc8afed33e3101ca7690ecc2efe7cde41a32b3  release/kernels/merge.ccvtrace
08201903687955e0ed2d413ff714d06510114e44e5e2f0308d13698319898ebf  release/kernels/merge.log
f96d28815f8756b1f5a45ded53e6170883d2dfa10f9eef0d14b8050b1318164a  release/kernels/merge.oracle.jsonl
9ed0d7a5fac4bc4576a802df8dc14ac66594b9affb1605ab70c7e1725148dd1b  release/kernels/merge.sv-hosted.log
357d9bf65214060454e31e93542b6b80dda91c8b0cebff95c71022821ee22e45  release/kernels/missrun.by_instr.json.gz
9e0d27e29d0f95678360f251bebf1cfa01a073c319e4fee499f6ce83a217d225  release/kernels/missrun.by_unit.json.gz
d0717cfc4e7e14e0a0320cd8119b57998e3d090c3d2a71b04969bfb560b0feca  release/kernels/missrun.ccvtrace
3ad2f6adc5744c343514396462da023bef5266bebc0f5ce69c769effeb53dd48  release/kernels/missrun.log
531bdaf281e5590774bd2775427f25e4cc0419cf8e3d5b6999843ffe9ef87258  release/kernels/missrun.oracle.jsonl
c79a288a366c6eb9d379b99f9885b6e329903d20f7ed21b73e7971ccbac3ffbc  release/kernels/missrun.sv-hosted.log
d148d26112c1727c27d78f6ec7cbdd46b1799a9de40d1ce10623e95231b113e2  release/kernels/mload.by_instr.json.gz
6e7688e6811fd1884e69dc7e018d67c05191a6636cebe5e4794d1c67942421e4  release/kernels/mload.by_unit.json.gz
577a3a3b4df199ff847ae882b5c5a50fcd83c74e63da8ba04754d5c6e1775f22  release/kernels/mload.ccvtrace
64d159017070f72bd72824b61e12eef86183d307bdf37e69eed59a8b7d0f1c38  release/kernels/mload.log
8000e477b9a95dfb9f0af964e8346acb9d36f1358fd06ffc4ff7cf599d2b8868  release/kernels/mload.oracle.jsonl
dd85a67b5b447d455d21d41b494c4d222a869b8962e5f5b8f5d3c4433b4095ad  release/kernels/mload.sv-hosted.log
8be505e545a15e0113be90c36c530e3d0f79b2cb5d2c103e671e22debbb51c89  release/kernels/mlp.by_instr.json.gz
bc67f6c9659b052b459c686859d6ed69dc04fc11e8b7e8e99040ac26c7867530  release/kernels/mlp.by_unit.json.gz
3e6e19508e5cec05b2b2e22e9e847b4f99c95bbfe76ba26fef100f54e2682075  release/kernels/mlp.ccvtrace
23f04dff2a940426d3d6d47cae4842a6d52bd995e2ae4a647046233bb7388949  release/kernels/mlp.log
138d282f88d56c8ad648a91af0a983254b55d9fa22942c00d47b327f516a6e44  release/kernels/mlp.oracle.jsonl
8e22d731df5bdec2bbbece9f49899789a35f68479ac527b25f96938ef801eb97  release/kernels/mlp.sv-hosted.log
b52021bfc45516854918dea34358e7f3d1d12d9767ab58a7431bb63faec8040f  release/kernels/mwmiss.by_instr.json.gz
95c92be222aa8fcbe4e80d8be3185599b5d2086d5142b3344c26a2e5fb9596ef  release/kernels/mwmiss.by_unit.json.gz
a4a5e0dea6edc9552a29effd74f49f1ad3d2279d61d60a0680a50e5ec98ca3f1  release/kernels/mwmiss.ccvtrace
20f35346c66bdbdd919144912946177e2696bd32a6cf1f06b41f6f1999ea052d  release/kernels/mwmiss.log
8abe8e8997456a2a6711ee72da54d854b24e20abbdab28e4b7271c0d28418de8  release/kernels/mwmiss.oracle.jsonl
b243ebc1f384af930d86e0571b740d96f48e611674a1816c1c7ab1caac970ddc  release/kernels/mwmiss.sv-hosted.log
75e50d1630df50feb37ce2e8ff8ad43e4cad163dd26ef5b39ce1732603c5e349  release/kernels/narrowadd.by_instr.json.gz
51fb75903b7206329fc3d56c8bc3d252950ad8744ab680bd22e1358087725c85  release/kernels/narrowadd.by_unit.json.gz
37d15e65cb02bccc001898996b6f8c4fbaaf3c7bf6f33f5629f7e1d886be38f0  release/kernels/narrowadd.ccvtrace
31424be14048d656b6701cd7e694b0f4f7d8baf2da2954f0359d592406461012  release/kernels/narrowadd.log
40a2cf629853dd404bb06b4a07e35abde3d12efc13f26ffe28f923daf2994574  release/kernels/narrowadd.oracle.jsonl
e28e8de36adcf5f6f8a4c4982d17da8805c5d0290f044376893bc8bbbea21482  release/kernels/narrowadd.sv-hosted.log
75f7d6446770c9d0e3e11a9ecca93ef199ab18883752bea5fe07f00e37df593e  release/kernels/pguard.by_instr.json.gz
e4c11004e7ee487482334909e14fac8393e08d5b0dc3319de27021de738c129e  release/kernels/pguard.by_unit.json.gz
f4d640eb3c718814f8a0082210a5b32b641049e7be155f3aeb43314a46416b2d  release/kernels/pguard.ccvtrace
14a7f102a969b1be10ea00f9adfb163b0adcc81cfa931f1743034b12fb04e937  release/kernels/pguard.log
690e56f1cb8d97cbf67124b7dff3ad0a90cb8981814cd1709cf0cd0e035b3bd9  release/kernels/pguard.oracle.jsonl
f9ba81a251a6100c7167ec3c46c9be07e0c350b73d7d1edd82a09886bd4f6b54  release/kernels/pguard.sv-hosted.log
169f1110a9441581bfd6a18dd532f87a8528dc841030a33151278c22e8da3490  release/kernels/plog.by_instr.json.gz
2a7c0f1347aa3c0b5113d4532a7d753466c5b37ad890250fe87ef3695ec46d7b  release/kernels/plog.by_unit.json.gz
7823562f75147705b01f772471b6175774023d19935926703e158062b24cf94d  release/kernels/plog.ccvtrace
fce73792136c0b2420473d2c7d32e764eb7a5448713443f6f96626c5a833fcba  release/kernels/plog.log
0c99915e2da60f4670da00504a6371d7d17701d4431e733a3ff8fa98a2030d6a  release/kernels/plog.oracle.jsonl
8a7bec8176993c344a485918ecbb03c3e6ecad1de1a3ca86d72f1730c6091954  release/kernels/plog.sv-hosted.log
01afd43e44511e66b6b380a8d30342fc8c5f90bdf24d5f895458a4dfe18da737  release/kernels/pmovdiv.by_instr.json.gz
e96f105f22dae1c5921f4f96db392c15dc74ec8ebe51a60fcf1032418a62322b  release/kernels/pmovdiv.by_unit.json.gz
da1865544271c3c70d3eab1061f5060d833a856975f75b28d0921880ec954a97  release/kernels/pmovdiv.ccvtrace
f9642dcbf3eabed260ae93977e524cee52d2c34c29742a1eaa48818051383980  release/kernels/pmovdiv.log
7bc646cff6166a51bdce03d7c1b7209e871f0a91d743083a9b910a80bcd0b33f  release/kernels/pmovdiv.oracle.jsonl
b8f64518798122e3bf0533bb8f623c2604f4e03d1500e62c6df1bbf96351f142  release/kernels/pmovdiv.sv-hosted.log
21986b6c0872e5ad0072db6a45e859d95b5ada9bfdd3a4a19377862da9de2e12  release/kernels/predlane.by_instr.json.gz
a569c0182b4021168a4e6c7ac754167467fcfeb7c6d1d2622fe2fc4c0506f88c  release/kernels/predlane.by_unit.json.gz
92b2b1101f673248f8b28d88093d2a180c8d0f30d92fbd57a2fbdbf50e68708e  release/kernels/predlane.ccvtrace
b127e57136cba295f9c0ab48654782b23339ebe3ce02196e146200daf6ad9ad6  release/kernels/predlane.log
c45f4177b9e84fc8a6e36b13534a0c7636eb30a3f8531847100ce5e23bf404b1  release/kernels/predlane.oracle.jsonl
281bbff9007b193943482306e44f711e14837b4d5b2200fb96023524b9034d38  release/kernels/predlane.sv-hosted.log
ea730456dbcfe6516b1cc1e254dff1c5ba720a091934840c7118255443b10a01  release/kernels/predmerge.by_instr.json.gz
1a010849a4088c2a469d5e98e94d204b537c43234f5496e30e241d0eea90732c  release/kernels/predmerge.by_unit.json.gz
bb3488ce2d30e744c014d06bb81053f2bc8f09237e4066530c9459a0da2002af  release/kernels/predmerge.ccvtrace
3117c04836f584acb570dfe23790f0d639cd186dcf2bbe6292c808b31a72910b  release/kernels/predmerge.log
6c737c49434bcd08e3e0814c8b1dbf15c586ae74f7929ba3148ddcee2c62c845  release/kernels/predmerge.oracle.jsonl
c62c4a46e61fefbf9aa3e57bfc88efe9bbebb1df0d9dca975399de16522dabdb  release/kernels/predmerge.sv-hosted.log
ceba1eb9b23f38ee00d25d9c2e035e3840f9b2712ac32fe703601988d37c1949  release/kernels/predspill.by_instr.json.gz
7b368a611e1af25b482bd2fa38594081a8d031f16049e868f50dc069d47fc647  release/kernels/predspill.by_unit.json.gz
bd36b4bae813afe5b9524ef4c5e637d94c88c266a7d87c83da36c64de27ab139  release/kernels/predspill.ccvtrace
c8884c336011166faa597dfeec678a09bfbdebd846877c0a58608c0d70a0194b  release/kernels/predspill.log
b7c84c6478117ffa0f06da0e6ad1e4628e2683426a7911080810e78e06a5242e  release/kernels/predspill.oracle.jsonl
370236bbaf43856dcba74e918786dbe6d558647b6c3da238261ff327a5b1a4e8  release/kernels/predspill.sv-hosted.log
6410daaba62c8201e146e07c2838c6094fab281af06ce25cf32873dde537d291  release/kernels/predswap.by_instr.json.gz
d181427519fe7f7664bcdf0fba781fdc5b5c79376be0757f89803568186a7d03  release/kernels/predswap.by_unit.json.gz
1b895deff4b6c3b0086288d4122e89896df7658dddd19c63f5de3cf16964591d  release/kernels/predswap.ccvtrace
c6975938db0f93308dfcd1124d846026c2de585426cab634c79b3d50bfb06229  release/kernels/predswap.log
a6d4f7ed517553816d889c7c9eeb6bcfd1f6c973fbf682ecb69f3c2de619f7bb  release/kernels/predswap.oracle.jsonl
dcf92d02a079f5bf9d04c0cf315b8abd2439fd13f5216ca5206e4e9e3ebae834  release/kernels/predswap.sv-hosted.log
20b3dd449bc88860e89785d316b99b83c9564fb2366a713d7a39ab7b9752b683  release/kernels/privwin.by_instr.json.gz
b2829d630eb159b1b4197af7ffb33963e0e29e1b160012c8d664759b6608c64c  release/kernels/privwin.by_unit.json.gz
2339e4f77834724f7ca0b9a0d955b1c914624b8490b494ffd185c449c385e7d0  release/kernels/privwin.ccvtrace
f1aaebbc4c1f2edbb5b2bad353d56fd62228273e6a633e65bacf3dc42ad35be2  release/kernels/privwin.log
861f686fc4480363472908d679d8815e8c957d768e7ab32c826930527b0fb7a8  release/kernels/privwin.oracle.jsonl
22d4714d6ab8fb881589c9886641caac9ec28610fe04b5efdd88a00ba099bc15  release/kernels/privwin.sv-hosted.log
4426dbfd5d0b54f3e5577d3b4f141b7af4b190b50a8572915f5e15454a031b2d  release/kernels/provswap.by_instr.json.gz
968ee2970955b9a0c8dd98a377a20712553140d30b111ea44b886236e4403640  release/kernels/provswap.by_unit.json.gz
02e0c17e77e0ab083cd97178c0672cfddb701e2cfff0917244168e93eaa88ec7  release/kernels/provswap.ccvtrace
cbb21fcfb5a6bb46af2371254ba273a19453914a8bbc7bfb6005a2edfc0e4bb8  release/kernels/provswap.log
c9c32a793d54cc7401477f582487f7e8b345b2669a75337b8d6327120d98e5dc  release/kernels/provswap.oracle.jsonl
dd0bf995d85e8e4ef54db2f5e4d2bb0ba553e62e8e79f31d18d50546d21afa88  release/kernels/provswap.sv-hosted.log
f29d78bb368998343c9f29e035ab0089f79ab5ac08205bea1035236d302313dd  release/kernels/retmiss.by_instr.json.gz
6c8eeb227b7df88d482ab9c70925e9f16ae3967bd76988668c442984ebd99a83  release/kernels/retmiss.by_unit.json.gz
6f094a4f42860ec13c8ed55dea19af83f02ec10f90dd9c8821ddc2541fb1a78f  release/kernels/retmiss.ccvtrace
3f8dd47fc4baf85f388823b2e1439fb26d24fd5783b0177f10c0aac6f28451d9  release/kernels/retmiss.log
e5ef8538e838c6cff7febfc679dd091cf5e002f82d34f1009b1948ce22bc3649  release/kernels/retmiss.oracle.jsonl
90981b265eb44db4258389fe96a12603145be4c42af36589550c6663cac9a8e7  release/kernels/retmiss.sv-hosted.log
b8af37455b33a1b36ab55a477d4761f76bdf9dd3edd8eab5fb7f2c3731ac8ec5  release/kernels/roconst.by_instr.json
357217c72037a713eac0a6b7379bf3c587e1d0ebddf2552663b36be17a4792dd  release/kernels/roconst.by_unit.json
47b4c352cdd47d93bee09cc71530c77fe68e1a5ae74bb3ca0570b6874a7e15f9  release/kernels/roconst.ccvtrace
57b85fe6cf8d26e82ba1e0140a261974de617c80d9176502efb483f36c6f66c8  release/kernels/roconst.log
8087c0671de620162881aecd38cd6114b78e7be6bd71201e3ec02c9a2e2e750e  release/kernels/roconst.oracle.jsonl
63385b9763a65cfb0388532182a0bc117acfecdc0e2002599ad08c478f610d6e  release/kernels/roconst.sv-hosted.log
10c797fb8d044649f6d3dee9c07281c225794258b33e21124d781108ba92c747  release/kernels/rogated.by_instr.json
fccda17315d416d2070549afdf69db60a1c9480f29fa055afc486cdb5f52a623  release/kernels/rogated.by_unit.json.gz
0ab8c9db689bf21fd56c52f465a6c5f8c69b0be064eeb18df72dd1a19a76d664  release/kernels/rogated.ccvtrace
051300c448c5db42fcc04213a167241b230dfe5d748d6f26e468553992c8b4a3  release/kernels/rogated.log
7cd02bd4cceec5a044d6b4d6a80df1e68ed0ae71b0b2a953143636d5b809ea6c  release/kernels/rogated.oracle.jsonl
067b6dbc93c3f4838cf8a084a71b616fe98feef6458539f851b56284d0729e68  release/kernels/rogated.sv-hosted.log
f9c770f65eaa062ea179b9aa73f14776d77eae0bb1e17d82cbbc17a7394a31a4  release/kernels/rokill.by_instr.json.gz
defea407f53e5a75377eaa318d6be9fbe471e93446b5cee544b05abd1aa72430  release/kernels/rokill.by_unit.json.gz
f6f31e59954f2b7c0208dff6d34443ba005176245081f039702dcc2576a7b35d  release/kernels/rokill.ccvtrace
9a596a570b9099f28c78a55d33ed622aa35b66b87c3fb592309edd1880c98cd3  release/kernels/rokill.log
94efcef96af469a512d346ce61623980fe86383188eaebd55120f716db596f14  release/kernels/rokill.oracle.jsonl
4ee7172f2000340f287a46df51a88dc1c11f17786eaed45d023dea6847d556a9  release/kernels/rokill.sv-hosted.log
a629f085ead80c34ca4d10b33f28f79fd43cc2fd60a137f97dd64da0eea27083  release/kernels/rokilllane.by_instr.json.gz
f2a54f144012cbdd99c0b511be1385aa2a61cce281082f4e20f9157d69ec3193  release/kernels/rokilllane.by_unit.json.gz
6385817a65c730b80aae4122e3d074d9e66b3cded81d6590e7d00efd695ee3a6  release/kernels/rokilllane.ccvtrace
0ccba8f24327da4d13b46d89757e59742604e3c1d879430171f9734f9d759221  release/kernels/rokilllane.log
f5ca6e666eff2f44894df74a291b43b3c0e7be0a63a47d795fdefd7b22016f45  release/kernels/rokilllane.oracle.jsonl
9d829d3d0def021da8a6b89502d678fd92e97841051ff292d4c8548a9745a0ae  release/kernels/rokilllane.sv-hosted.log
6018676757a05a45231fba12ff6df60d07f415338c1d836cc09d99465b73577e  release/kernels/rolaunch.by_instr.json
c157f1e2326322de8cacaafbdba5687d5c865c70a997834aacd3bdccdd2c43c2  release/kernels/rolaunch.by_unit.json
0ea08323eca54b8dd88d2d98eca12c9667af542f5d0e0ca282ee2d5f57ebbbb9  release/kernels/rolaunch.ccvtrace
84ff79f5706a00d46455306ece0a4ea316b71215093870b47f9e597d50d1807d  release/kernels/rolaunch.log
e7dad585c3e70615de04330fd03f4f282c29a005dc1732a35655fb261d51139e  release/kernels/rolaunch.oracle.jsonl
e3b444bfab4f52b77bc0b59a8e9a855caeef6cf801a2988dd2054bdc00d08523  release/kernels/rolaunch.sv-hosted.log
b8af37455b33a1b36ab55a477d4761f76bdf9dd3edd8eab5fb7f2c3731ac8ec5  release/kernels/rolimit.by_instr.json
0358cfd1bb137c960487c6e1fa8b074623c904e538ad55b630bec3c9f7fdeaaf  release/kernels/rolimit.by_unit.json
bec85876888b4ea67e5cf81aa88f160350e676db544d7e6924a539ed277454d7  release/kernels/rolimit.ccvtrace
1e3180dbee8f4902314542b2f96b6c40105d08f23e5fd895969379a15af7b64a  release/kernels/rolimit.log
1c5bc0cb8e8b2e69505fb5a551a16d5d10c56f232b88da7a27e336ad7d962de2  release/kernels/rolimit.oracle.jsonl
7681850a7cff6abf1ac3b2fe668df9950722f4aa9ca6648cd5c8ae4d79b07640  release/kernels/rolimit.sv-hosted.log
7097164a93214755bfeb3f8f1f9ee314a9f996a90afcfa0d04217e519c8a3acb  release/kernels/roload.by_instr.json.gz
986b605bfa14cdab1ddd5e6927e2331476e081933af5c4554b2629b43e1914f4  release/kernels/roload.by_unit.json.gz
554fe7b6e3b718a63b278da46b9e3604fa927d3d8c9ffefa5bbfeb7a4dc44b1d  release/kernels/roload.ccvtrace
96c4b129eff5414d204212def54c586380f3c05cbd9951164ad72502fd3a2222  release/kernels/roload.log
f7c1309cc9764769fb5803f6fd0f2f5e1eb418f2d23fbe5e17cf5f9106869fdf  release/kernels/roload.oracle.jsonl
4592571f06c9410c22673024d49ca3f1ef646afb513d2fff07bae47a896d0f09  release/kernels/roload.sv-hosted.log
d522cad700d999d4c99cb1926416ef1ea5bece4621e1dafd32f86578f89fe6d0  release/kernels/rope.by_instr.json.gz
5e0c1da45f8d6617b5ecf305fa439523444d727577e335a862b223fb518ac9b6  release/kernels/rope.by_unit.json.gz
f6ad18f23cbb4f20646d227ccdfacf36a783264a77ec6b93da0c847ff2ec40cf  release/kernels/rope.ccvtrace
380567657c67674a5924c8de3142bb1cfcdce170b9b6d6c6d7d70ba0ac9e1d0e  release/kernels/rope.log
d55f9efae392dc8877c102c01c0810e7654b666b6ede386328108164c6cf88f3  release/kernels/rope.oracle.jsonl
f8efa98fbe2f49dd4c8744fffb0d5631daf186363b8e64ba74aeab85169d7a7e  release/kernels/rope.sv-hosted.log
23139097e6b5166b4c312fb93d8bccbb31e62d065a82602b122fa48f6ac805a8  release/kernels/ropediv.by_instr.json.gz
b7db8d8097d3bb650d56ab46964e693b59553625a53e53c2927d2302ae1aa96e  release/kernels/ropediv.by_unit.json.gz
10270e50bee5a26190cc449f04d57fe36983c509a3d0bb7ac7691f51d85d29d7  release/kernels/ropediv.ccvtrace
b5b3bb080662995c1e82d44788fcd18c85ab7330784a9c87d0a7c65f2fa6b49d  release/kernels/ropediv.log
10c0ec6ec18b7b44638c790033109198c079d07c1537bf193353ccedd00a920f  release/kernels/ropediv.oracle.jsonl
8733f7fd3cac3c9c5b9b106fdfba8c801885e394c1d169033541975b560c700f  release/kernels/ropediv.sv-hosted.log
f5b8aad5e44c6dd265c231aae03f219dbd091a3860ff5e7cf093e202d981db7b  release/kernels/sel.by_instr.json.gz
0447c399e5802f75a998fe71773bd7f63d40f8e96d2f7000090d5cc17dbc0662  release/kernels/sel.by_unit.json.gz
b7e938279e58c029f621fbf246c3b68cf5aaa826d23ced0b0a274ede1db13213  release/kernels/sel.ccvtrace
76bfcf4f67ade9999d2e200cb11c6e2760b56784e251e72bd3f2c879e302d63f  release/kernels/sel.log
87f6a81e8afa004c8039bf2f61c90176fcf29ab29bb17ac44aa016a5cc8438fe  release/kernels/sel.oracle.jsonl
fd81b996d9227a2f58a2af2a06d509ad3bb9de2a9baeb93a3d2a2976ed25ec94  release/kernels/sel.sv-hosted.log
a70691242b082402585e3c1afe8745cdbae351ff331fc0c5c36b940eb64b729c  release/kernels/sized.by_instr.json.gz
47cdb50f1c1989c97855cf69e10d8acc4eb870e5c9b7df2a718947a6992c9edd  release/kernels/sized.by_unit.json.gz
a9843b2c4b46306b93b260315a2e25662fe5ac93fba6fa497b21ab3c58384183  release/kernels/sized.ccvtrace
f870ef947cb0604135716c661909ef8498fe8df114fdaa33ca39c34a5942b179  release/kernels/sized.log
36d903ba1618bd1faa437c9812a6ee6c0c966a63196c796267d74bf2695ebc3d  release/kernels/sized.oracle.jsonl
b077ecdd0ea0193e4eec92afc24ee05d494e9039860713f0cc2fad444a18f6ef  release/kernels/sized.sv-hosted.log
0fa49cff0ef73347b4534648b6a9c008312965a4f55bbb6ab3dc226ab68b0cb5  release/kernels/slotform.by_instr.json.gz
4e034bfccadf6c0301e75b251d6420a9ddf2e0e02d57090ae8a7b4e78c1d829d  release/kernels/slotform.by_unit.json.gz
49d5e947563620dcb299762eb88ade65677dd870ace74045f1b273538b7454c4  release/kernels/slotform.ccvtrace
b4040cd098f4e0f0e565120d4d30c0aa17e1e98546d2f6a7483d1c15b7059816  release/kernels/slotform.log
8b61db7419b18cea8a646fb628218447e72e84a18a9891ffb73b441736138ab9  release/kernels/slotform.oracle.jsonl
6dd5b236fec1372325cee0f3e43a8307361e85699ae4178b4e4cda09bccda83d  release/kernels/slotform.sv-hosted.log
c826ded386b5a5465922958511c65c75c6bfedcf38e16e1fe19ac7ddd9b31788  release/kernels/spinwait.by_instr.json.gz
3b97953f92510ce0ee42d9eada41ba404373369a5e8996ca5065ad2adfc9d379  release/kernels/spinwait.by_unit.json.gz
25d95e4507c45c2c4ab004660dde0c9b71c5459ff3d1e80dab0c1cdf325b7c7a  release/kernels/spinwait.ccvtrace
71955d7ef2a895c5f9040efa64b99fc3f99817216f17d7697f7a9fa3fbe5ce41  release/kernels/spinwait.log
868920637236c878b33779bd450439466fc3626996a3164573dc11d437d5c709  release/kernels/spinwait.oracle.jsonl
6e6abffb89f7ddd97634001a11581c79bce0c9dbc223cf1f079c678ad86ebb7d  release/kernels/spinwait.sv-hosted.log
561498095f7baf14d2e02765709bb622e6a5d884e72449bb98152513a4b1d9e5  release/kernels/spmbank.by_instr.json.gz
fd815f6b28a40a015661433ec511a94e4fbdbe10f16c16c3881f778dcc375514  release/kernels/spmbank.by_unit.json.gz
0b63ddd199108d5d57dacf8da3b47f37f0c4b36c8ae2b2605a61415aba0d0ef1  release/kernels/spmbank.ccvtrace
47a51d46324799a1441299d963ac682668e5144511f0c6adbc7c5f05cfde90b4  release/kernels/spmbank.log
3af490cc37d7a92dbe719b57de216b648536eb301ff9d13de9a39f50d150d725  release/kernels/spmbank.oracle.jsonl
da2230b98ae783e83fe7bec07f267e8590cc160f62fdb99a7354d8d53adb7b65  release/kernels/spmbank.sv-hosted.log
425c0a853fff07e5824d1f24230a37abeb6ac8cecf32757626fa56bb47d13733  release/kernels/srd.by_instr.json.gz
ecf52dfde704cfc5a7b93fa65f766fe90fdd15c5e0b9f149ba29a2fd5587e7fc  release/kernels/srd.by_unit.json.gz
12ffc6ad91eddcde92d30ac0bc8db4c6cf9ae295413afaa6724b94542c6a18dd  release/kernels/srd.ccvtrace
f6416314b973f09e784698fbd512b5d507663d6289fda66ef3a373507db4c579  release/kernels/srd.log
b08eb5e3673cac7eebb8b72af5ed3783c8e70a9e96592e76bf3722551bc79473  release/kernels/srd.oracle.jsonl
ee98fc559b7b0533474480f850f42c46291730c4f19d0021f8fddb47836001bd  release/kernels/srd.sv-hosted.log
444eb93c6e1d2107aa18baf023b4a90524ce80aa0e119513ab153e9e1bd386cd  release/kernels/stall.by_instr.json.gz
39205eae91972532a3f68e2e5f2a6010c30cf538e9d01d3c2d80dca4f8885f53  release/kernels/stall.by_unit.json.gz
23d7fe29679d4f66c856d1f3771699f36fc83063bc591f46dcf0b1bbd72faef5  release/kernels/stall.ccvtrace
c8706ff35c555867b855941d01bae477836c6066dcc21162690cefa859eb6ca5  release/kernels/stall.log
500db2c482b07a0706583422cd68878301d0146c1f872ccc1f11bfdcf5c993ef  release/kernels/stall.oracle.jsonl
fe6dffdcead74195ca2413e9f471e87fd1a3191a0a5cab7688ca2c81af204e91  release/kernels/stall.sv-hosted.log
bde4d4d4ec63ef65f1be0bdff0053468ea377c6ccb5df421c1eb232540496a61  release/kernels/swap.by_instr.json.gz
29edf7291d290a4065c734e072276355b65718dcfd0b027fb5a43523d6efdadb  release/kernels/swap.by_unit.json.gz
73f0439a3c3728b551849a9dd1cc3ca4f6e7f7aab68ba4084ce43f4f711edff6  release/kernels/swap.ccvtrace
aa7f9c5fca7a2cd62cac9a0852deb8d7a78eaa8bd9558253470bd1ddef368509  release/kernels/swap.log
3658a26316c1ff7bc1744304a42f736e930fcde2865c8913e6cc67a22ce96667  release/kernels/swap.oracle.jsonl
26389be13ab94af007ad63900d7ecbaafc224939e0a0997136f6b1cee11020ac  release/kernels/swap.sv-hosted.log
51fce63cd4ce82adcda043478f40b9786305c60c550641d5fabb723ddca398f2  release/kernels/transp4.by_instr.json.gz
2d83907711d0b4d70f2934ab4cf4a79d10c7e4b44c047605a39f2dd44e80aa49  release/kernels/transp4.by_unit.json.gz
93e614f4cfab174fd368a701d37df0ffac14cf302353169a720ab414e9ac2c16  release/kernels/transp4.ccvtrace
0492ffd3401a4091d9edb60ba7d6acbf27725f2fba2c7a16b3ca5756304092fc  release/kernels/transp4.log
06396ace3ac19677fd39c700e408606e5bdbacb24997d663bbe8872e63dd74fc  release/kernels/transp4.oracle.jsonl
dc3eda8fac0af993df44ba551dd6ad5ab7f1f98a08b72c64cb0516ed8ae77735  release/kernels/transp4.sv-hosted.log
508c9976d3fa02a8d9e6a16493a425616123fcf4eac42d30db34888ab1a28052  release/kernels/unal.by_instr.json.gz
2abe5f2a810bdd645ad84a6345178bc202b496abfd624ae4a5943c66b9d50de2  release/kernels/unal.by_unit.json.gz
52b05699065211ddb8b1c31f92005de7dc6eee7a77092aa25a03d8405c81c852  release/kernels/unal.ccvtrace
447df54bf2c8892997579702b96c4c6715ed968b0a2a42e46a5ab81ec9bd89de  release/kernels/unal.log
c3d484bb160657a563df983d9a2532eac27f556636617960aa1e72183ac2b299  release/kernels/unal.oracle.jsonl
5553b520f7d59b23777f3749496c81e3d3156f4cba18b820f6c079903d3fdec5  release/kernels/unal.sv-hosted.log
9ed5b0528b1a3911145deb79ab10697ef4ac4ac3585acd59a79a7416861acea8  release/kernels/vadd.by_instr.json.gz
efe05639098b65353c45230b8299c2d4e735e82ee0e1d502c7135f7f9d588a81  release/kernels/vadd.by_unit.json.gz
4c225b6185d0ef923f0c26ccd6d22a7277ea8914d97d1e2a458467ad4812f40b  release/kernels/vadd.ccvtrace
816ca8b1fc9981ad0fbf1cbc3106a550567fc1dc29cc91f693c46cd12b1e218f  release/kernels/vadd.log
0276b6d0611a4bbcdc004ab3987214aea138245bc7217504147331689a9c0880  release/kernels/vadd.oracle.jsonl
a227a33b79708dd6c1fbf848f79d61e105372ef9c9ace877d7765c2ed86e79b2  release/kernels/vadd.sv-hosted.log
667af9ba4f587f9ed01ac5063d55b95573783bc46c0032c455371c06f499243f  release/kernels/vadd4.by_instr.json.gz
4a5b050c458812c275b5a10d97be268025da716988990491edeb0836b083dcfc  release/kernels/vadd4.by_unit.json.gz
5dfa2ef9e17a34e3ebcd6851b1dfdd50fbe9981700aa8d4a493a13572ba48f9c  release/kernels/vadd4.ccvtrace
e967c36af6f8a33691250d8aad601a0e7d3a6a6677efe534bcf2b869f60fa321  release/kernels/vadd4.log
225aa18fc9f38aa9ad615aa11de254337d59fa705877553d873062c68366e0db  release/kernels/vadd4.oracle.jsonl
7ec5ae0878565338e15ba4a7605b9252db16d28bf7a4c8a62d8dbda37242c3e9  release/kernels/vadd4.sv-hosted.log
654efb3e4874b723e21f1e7a931547bc9bb1aff94a4cc67d13b1cecd9343cb7b  release/kernels/vaddslow.by_instr.json.gz
ac09c4612168b6ecdab21ddbc06518711ed75c41d26dabae98b49023a4af290a  release/kernels/vaddslow.by_unit.json.gz
25a16a9885807c4eb4ae66a1bde936ded34fef447aeca62f3277e0d4cd4766c7  release/kernels/vaddslow.ccvtrace
f5a5be824623d30d105cb768713256e36a0d8e6e0e5d3aba3771c362fa382d9d  release/kernels/vaddslow.log
e9e6218e8b8450e9f9ff6b39d659c994a1e51c527a0c5bd10d18b5658ae0e344  release/kernels/vaddslow.oracle.jsonl
d02f98086501c646668433ce17817f49bb1c0e9282acf521342fe245dfca38a0  release/kernels/vaddslow.sv-hosted.log
c7710e7be7bfe489ca8d30143a5379ae1adbc13f06c9772469cb5c654e8afd3d  release/verify.log
fe1c1a586828f0fa7b9b7bb7e659648607ea83cfff7664dc3507dc413f8b11b1  release/wiring.txt
```
