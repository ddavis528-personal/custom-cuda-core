# Snapshot snapshot-2026-11-21-b681ce3

**A generated, read-only snapshot. Do not edit or merge it.** The source
is `ti-drop` at `b681ce3d06028780db91b004c75207609b618595`, and this branch is rebuilt from source by
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
| Source | `ti-drop` @ `b681ce3d06028780db91b004c75207609b618595` |
| Built | 2026-11-21 (UTC) |
| Gate | `tools/verify.sh`: RESUMED PASS (25 of 26 sections carried over from an earlier run of this commit and tree) |
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
f9fd8c7f3301a226f1c77f06ef272ed2e7b018834e0cd0c5fd71067a3eee46a3  release/kernels/addrhigh.by_instr.json.gz
45a96ae9501dc7b9d23f3aab744ae0e764efe16fc4ba2f18a5ae8bd6fb657050  release/kernels/addrhigh.by_unit.json.gz
77bc0c3be8e830d8723acdd7c4f9eb29f4078b3115874372bc60e68aa53b7183  release/kernels/addrhigh.ccvtrace
4a4c4ddefad62dd1d282fc68830907f1ef2ef53d2813ccf09451d7c3179f9989  release/kernels/addrhigh.log
569f2e22883fad5f0956c57ec734e6afbdd4b8a854e50277425172d6c0cbd766  release/kernels/addrhigh.oracle.jsonl
c69879280342e825f84b15010fa19b7e7fb4ff7429b10892f3b548b547d50bb6  release/kernels/addrhigh.sv-hosted.log
32a11e6c63c10e002e92d55eecd4c03ed5a665fb9bd4817e1f94a15264c96010  release/kernels/addrlimit.by_instr.json
85186aa3b401b5167e046a30f2ae0d04b84e1039b985e951672289388f9efc3f  release/kernels/addrlimit.by_unit.json
d8f758a9ea0bb7fc9f4b2e3e6de970d00e0ed7699ff2a1a062d133c10932c23f  release/kernels/addrlimit.ccvtrace
b2dc457e9293de385f3d65c013a1de7f94b7c22ddcab160c1634f29d03a06f61  release/kernels/addrlimit.log
bc660b0b40359a2c5a2478cb0eb4950b73fd22db50ea76b80052bc195a1920f4  release/kernels/addrlimit.oracle.jsonl
6e1388c607f92e2e075c6d5b79b31bdc31e57f2f834a7b03d3af28b0c4618373  release/kernels/addrlimit.sv-hosted.log
d5ee993d0a633a3a0837df8a1267138a4a90d71b0f13f2964db1fac129be4751  release/kernels/addrneg.by_instr.json
d4575a0211ba3cad70a041dab45c9876f749ac9173cd91604056151f0cb47c9b  release/kernels/addrneg.by_unit.json
b64cab0cffa732e5e0822d4d5e4704e4625cec46309de4e9af4fa929274a37fb  release/kernels/addrneg.ccvtrace
5fe710faea2bbaff65e35d140719023a419da1a2aabedb55a56f9222c7071fc7  release/kernels/addrneg.log
16f5b0707ae44492a1efd67bb9dd38a7e79a7bbd354fa9207b9e7d150ff2f107  release/kernels/addrneg.oracle.jsonl
b8fff8d1b448db7d91352bdec10dcb8ca09d441824d3d75da2a5a92e005beb20  release/kernels/addrneg.sv-hosted.log
083142a4a6de8938636d8f02aec2279f09e68b52efd3dd5a17df2bb5a21767e2  release/kernels/atom.by_instr.json.gz
ee9c4ea53cf2fea77157fe45dee9e3cfd26f4e8c69e4461a5f0fd2173f7820fa  release/kernels/atom.by_unit.json.gz
6bf8efbc87cb170a849f4136fedb66cbde931ddeb0aeb3a6ba308817c41f6fbc  release/kernels/atom.ccvtrace
1a5cbd260179b55a68fca93f0da3599eb3523cb7cabfce9ebaa0b4a6b663e882  release/kernels/atom.log
504f5b6e9d25114dc35f2c70b21bb7b3f3c508c691de12dc0e87d12a74285361  release/kernels/atom.oracle.jsonl
21285d6e8e2685a7ab72abdcea6b3a19b44364a45e141d66d80393b8147f70a4  release/kernels/atom.sv-hosted.log
d7064f9c572c12ac0533617e722455a85df0d2fa84d8e6efdb53b97eda9423e1  release/kernels/atomf.by_instr.json.gz
7b336b411e7a90270a0f6653733435222a5dc66f198735a1d633e624212de7ab  release/kernels/atomf.by_unit.json.gz
8c86a7d6d776cc48c76d6420a63279ee35bb149f6f68c22a2a4cf9f5a89c9e77  release/kernels/atomf.ccvtrace
144740d7b18e5004ecc753719443f483dfec1c62fccbb62793a78a9251834439  release/kernels/atomf.log
cfd1179edf4061a33ab2f75d7a6dec61decfe629000198189a7bfc2647b34238  release/kernels/atomf.oracle.jsonl
01152c15915ac1af1f3eca01b81bddc1ef6ee577b697c24617a29c2ee028d208  release/kernels/atomf.sv-hosted.log
8b661e38598bd4e4cb9ace21d923b1198ae81faaae907a1456116ad2add118af  release/kernels/borrow.by_instr.json.gz
b02c5bd035452ca1fcf14393d750f9f3a441901bd8ba5c5df9d3b518cea91984  release/kernels/borrow.by_unit.json.gz
675e87f1c0e15b984bee253fff4849e79de6b07f83e6e28edfa102cf07f93b18  release/kernels/borrow.ccvtrace
8b80d936bfb5a6a60cbe286213f80e31b9ec6b7c210d1d543ff30c807ff2f890  release/kernels/borrow.log
4c565e1ce0b3baee36e158694b32c8defb5cd662b2f9af75cb5d8c26cb1168ed  release/kernels/borrow.oracle.jsonl
fb00dc5f3bd037fd7e214ebaad60da436ffdf9a432772d74e2b1fb83e2a113c9  release/kernels/borrow.sv-hosted.log
e8a0461f9214cd959e8a7db1ee2c76bf3c760b984cb188a680dbb301c6d2fc59  release/kernels/brs.by_instr.json.gz
d7b26a3c536b87ba3d7200ef052eb914f03230a7d1001a066b88a5fa08697a61  release/kernels/brs.by_unit.json.gz
dfdc00e3f7e638e036c8544c04704d8c1d4cca764d189ea7aa1e0739036dbfac  release/kernels/brs.ccvtrace
5e167af93ec43444ec4f671e3b35b43f5bf867fe74c8727bb56ddd5a04f12c7e  release/kernels/brs.log
e3c1cb3379580cf1aae44e8ddc8e846ef6fd661a573cfe0a8d4444b18a14dc56  release/kernels/brs.oracle.jsonl
ddd9d16397687f3cc9ec6b1a954c3015a68a3266afff4d278ef43770261aee89  release/kernels/brs.sv-hosted.log
99584a97dc8751a6a182d3892134b9988ba89a6bc18985a9b630832d94be0e92  release/kernels/byp.by_instr.json.gz
28e9897c79750a940462916c1840d659c871307e457e7373e3054b0b48a24037  release/kernels/byp.by_unit.json.gz
70e707155bf385f9a85a1245aa2bfff68d571c7723cb190f1b3dc06795570c25  release/kernels/byp.ccvtrace
684180b85c89aa11dc1e7fbb30ff4b92c30eb4ff4cdf388c75fa9b97c6d2197b  release/kernels/byp.log
5a03dfa4f3603fef49f1e3639e74e34152ca3ca5ef8e41eb959f8323040fa2d5  release/kernels/byp.oracle.jsonl
752339a4c81568f38b4b85f2c51404b725537f676116662a33a9abc77530f93f  release/kernels/byp.sv-hosted.log
da9f9668f5ea6c8815bf9bdd1c947cb95bf93dd6058c9e8aa3e878181195f61c  release/kernels/callret.by_instr.json.gz
ce75d8eca0c683aea0049e117eec6f643b5e1d220094d23ce9c6a73ec3e2c317  release/kernels/callret.by_unit.json.gz
b9b05ccbb7a867bb47673194bf89bd27d15ff6cf8067ded59577632268aafe52  release/kernels/callret.ccvtrace
2c0f904e2caa2ee78d33bd850eea68448cb9537badda461cddc3c7251d701b89  release/kernels/callret.log
9b1d1b50b527f732362f837250aa2f26dabf3e76e16a4794856ebd8f105635b8  release/kernels/callret.oracle.jsonl
44e60039bf8577a132e429a9461c069f69584e30d3926bbcdf3fa3a79db24a44  release/kernels/callret.sv-hosted.log
0b21bd7d9b27c042ab8a1d4610003ae59529e580ad26987e31d3e34f9e3acc81  release/kernels/cas.by_instr.json.gz
af15be9e55423e837e2a6b71f173195c0dd75aac860436b3c5c1780cff40cf69  release/kernels/cas.by_unit.json.gz
85b41a4d812de1c3af19d4f9cf94612c4a49247259e2bba24080a0932bd88fa8  release/kernels/cas.ccvtrace
92810ff2b5e5b52cff6b089e5a2f12230372c02ba8b91dc8f5a50bc31001e21c  release/kernels/cas.log
0ab31a9443336fe5d08e1a5fa5fcba3bc279b19022f7c5007908d39d8ef39536  release/kernels/cas.oracle.jsonl
b76e0150892b8337667ae985327ff0a473b2184741825f40550e876eaf49459b  release/kernels/cas.sv-hosted.log
7fd783e4c254fdaecca73ec00260d7bf2d26aacf5923563ee48a076b12e052f3  release/kernels/chains.by_instr.json.gz
9d8a4a1332d40e50e74cfc28e1c2ea69f5c24f98b521acf81cddf04a4a622b79  release/kernels/chains.by_unit.json.gz
f3c7f719a83f93768af61373514062f1b4654c87caae7a6fd23d0307b7b7ca0d  release/kernels/chains.ccvtrace
75a77a76c1d5e9f8f4777e3b28270c21a19d72afb8dff5755dd9e7b0281b7ba1  release/kernels/chains.log
26a4cc5c5524c7219d8706c2582c80357dea60be9d6ffdec99dac7d0365e2264  release/kernels/chains.oracle.jsonl
b6b550c98e0f23ae12d2277bbc10148c306ef7febd9c4da91f75546bf2cc9cc2  release/kernels/chains.sv-hosted.log
9542fe5ade4843b1f90cf5933f66c2cb7224fdc20a0e515739047616e6292f61  release/kernels/coll.by_instr.json.gz
6ce9e4bd79d63651a5dfd525bb931bbea58fd0d5729aac849a8f2a442c33e5cf  release/kernels/coll.by_unit.json.gz
b9d0aa1fba37d6865c6e65310ddfdec12b1a406436489ff0c4ce6a811c10cdbf  release/kernels/coll.ccvtrace
fbae6259451785f0230c461784d6fb18d2602508c54ab60941d012b3e464d2be  release/kernels/coll.log
dd718d23c88df5dc7d92b055d8542865aa0e029118486af127312a8a578cfcbc  release/kernels/coll.oracle.jsonl
78e35eb565e2c175dc0bafd380b7b46ac493a2ead095af1ae21fa4c8b702f4cd  release/kernels/coll.sv-hosted.log
be3d1abe970c3787f9a41d71e48f166bc74e9ca5167d8b5815d2808eac7e19c4  release/kernels/div.by_instr.json.gz
7c3373ac8cdeb1004dc0b1752f795d3a6f3d0fcaf0d0a2b4ccd1b8e41dc95d08  release/kernels/div.by_unit.json.gz
0fa59319a49569c81f33bc11b669b5cff44d54af88e0e1a0318682d79a62911e  release/kernels/div.ccvtrace
34b679d1c3ad3d2b5ab454412748ea8123a484b3dd821af4c073cabb7f8d8b8e  release/kernels/div.log
71a567b85cf85622631490187563de9a5661099c78a590adff4ed0a0c3d24c16  release/kernels/div.oracle.jsonl
a2c0b23c074391a21fd86ad03e7962f7e88660c2c1a6bb073cf28dd6b92a20f8  release/kernels/div.sv-hosted.log
3b033c4484bd6809361eb6b561f920632b7f63749f3c5319def2152987b2c1bd  release/kernels/divchw.by_instr.json.gz
9803511bc5196d7cab82371d60b77a696e0f57d2716ec43d0c5fab50c7d99a57  release/kernels/divchw.by_unit.json.gz
7171a5600e2647cfdb103881ce1d051b67e5c0f4b5522ff75b05208ed6ee3d4c  release/kernels/divchw.ccvtrace
fb7a68d1fe67c1bf5473c1da691f2ded3c617cd01507516ebc54dc63d48fa62c  release/kernels/divchw.log
58a541797f7a2df0a1c7528ae6a3edec212db90c7d3eb20656806f38b5c10b3d  release/kernels/divchw.oracle.jsonl
6dff277d375022d7004d58a23cb985f29ed8936ff08c88d6bba9ff185d888ce7  release/kernels/divchw.sv-hosted.log
9ab80bc072b6e91ffd5b00651f603ddc57dcdee5a61664880c49f49b9f6e798e  release/kernels/divtail.by_instr.json.gz
b6d7d9fa477e36f6bb749b56dfe8a6bf03ddce9363841ac1af9ae013d82fbc82  release/kernels/divtail.by_unit.json.gz
db804fbb5ad528ab14845763f37b3761a0b667c3bab40606320e4d62853ca751  release/kernels/divtail.ccvtrace
48678bf518174b1b1a83d43de0622166240bba01bd75c6c2399c03f2d31d2b22  release/kernels/divtail.log
75f11a75c9b3b336e446140af4579f05b46c363a76b7aab3ec88154a07ba097d  release/kernels/divtail.oracle.jsonl
b0371caec2309caae73b685fa4ae147bea8191c081c767443d557e3ba6c64de5  release/kernels/divtail.sv-hosted.log
a8fefdfb092c98c15ee68c07d9aa3e6a13b30cab94f5b8b7103a36940bfa02ea  release/kernels/divtail2.by_instr.json.gz
b2b9d34f5c894645b7af2c1c1541414006d9d91fc9aba1933ce04ea659cedc8d  release/kernels/divtail2.by_unit.json.gz
a75fe12547373cd47764249a890c8e2cff1203790b37cff1678beeeb1c5b2c44  release/kernels/divtail2.ccvtrace
fda7dcc5b150c06c13e0cf3776275c66d4c5e75c345512fb8be501c7f5a8297c  release/kernels/divtail2.log
b2db6b05eb6cf4a0a7677e31d0c6c2952d5cab49d353f0bb1883fe0b2a20ed14  release/kernels/divtail2.oracle.jsonl
6c81ee21d8348952919905ca70e89108e7867e84d77f7b03a28af312e087a0aa  release/kernels/divtail2.sv-hosted.log
ad91e85899d2b46f88a0476d6936b081bf2cc69829f55378982e9b17dfce6801  release/kernels/fence.by_instr.json
3296deab82d6861f356139568db3af6b08a653e9104c80c6dd820a90f112df55  release/kernels/fence.by_unit.json.gz
2c35b83cb4bbd2ad110f669b3875dd196ded5d1b6799c95e1f8975440612e558  release/kernels/fence.ccvtrace
d8c05089e2d9c44ed98a10d42c7c1cb71a1738592e9009ad1ee8807726f16bab  release/kernels/fence.log
d1d40317f6cf5bfb430cda1f9c0ef676609e59cabe2a11623c42ffbeca93142b  release/kernels/fence.oracle.jsonl
55eef23893e079cb9b1ff669f118df605cf076685d6e0aa5c91244ef8006584d  release/kernels/fence.sv-hosted.log
69625712c607ee24f533e09c81c4befe8b1c81c3a8af5557a9d41cd1fcdeead1  release/kernels/gather.by_instr.json.gz
3bb8bc3bafd14f7b9bd01b84f308f7efdb818b9e0b2f3ada739e1ded4a0bcbd4  release/kernels/gather.by_unit.json.gz
c0355230da0846af8bee5298eb5979f43f09beb4ee204fa5d9b77f82da72696b  release/kernels/gather.ccvtrace
4c9034956ab8996a5ca7dcf0ea982be1453a774ea7862226858d455833d3e3df  release/kernels/gather.log
0413e781d8d6ff578c64eb1f800b7931e66f676d5cdabb97b94a4033e6037662  release/kernels/gather.oracle.jsonl
c3e164e9c286e189cfac7a11d004d0b21eca79f62c6ff8413180836e06d02530  release/kernels/gather.sv-hosted.log
da446d453a0a3013175ff20a5c541af8b8b21314dba986f938ca4c3189e6f7a9  release/kernels/hit.by_instr.json.gz
08baae0f212883872da2342ca703fc247ee25efa8463b4c0eec60bd5f7d6b38b  release/kernels/hit.by_unit.json.gz
a473755ad9c6175d9e6b01c1dc66644aca8cb4e42249b87e4b759b693e0751f3  release/kernels/hit.ccvtrace
4b588fa3eee2d8a7ac9472702b74e4565629a7c3edd63dfac4219b509ad4e324  release/kernels/hit.log
7ba9603e0088d9164de6528f16ef6a7fa9ce5821c8c12b52cbb3734e39b9fd52  release/kernels/hit.oracle.jsonl
d80a15b644af30975220fdde8af006e004473d7ea4f33fb63b199c67cc6578cd  release/kernels/hit.sv-hosted.log
c5933181cda88b916b033bd3269996dd0beb14b86afc6e7e92d78413844acea8  release/kernels/lanectx.by_instr.json.gz
afc2bd5b2c3475921f0ed22b3316ef862f91ffd92669862b782ecf444917aa1c  release/kernels/lanectx.by_unit.json.gz
676e0a1c1bfb92259e47e4441214679e0336f5ccce97baf948d1a0ea33cf0c39  release/kernels/lanectx.ccvtrace
938c05ea161f491989efd7c9f13b9f0788331145920a299dc6b05186410fe23e  release/kernels/lanectx.log
888551babf540db8e3025b82e65ca655013f93eba3c8a65689d069d52a7e6039  release/kernels/lanectx.oracle.jsonl
2ef7918fa58223d609d9a4e416910ce910b4e97b0a68f810c2f445c6e80f5ea1  release/kernels/lanectx.sv-hosted.log
d9069252654140e7640d3041c3d518e5d765301bfe90417ed38f74cfccd45012  release/kernels/lanectx2.by_instr.json.gz
14366d378f9b212fc5d05a51dcaaf20c67497197694295feec6a138a6a176fde  release/kernels/lanectx2.by_unit.json.gz
ee7739ee3adfbdc677d7a3ae0ec74c87d0214968514e51cc5743dc73210f7a86  release/kernels/lanectx2.ccvtrace
1b8a63975d703d2e8bac20dc5cba6c120837dd3596f41b22032aa5d754d78504  release/kernels/lanectx2.log
45c13056dff5c73ed0c9ece56cc36f929bf335322193c7d5eb38710b1d1dfb02  release/kernels/lanectx2.oracle.jsonl
91d6be06cad6d9caf3270a5b39a98596cd21f438d96a80250ac6213dc631ba91  release/kernels/lanectx2.sv-hosted.log
930719e4e3b050cd0eb856916a408fe456deb4bca3fe1bfe135633bc156b3257  release/kernels/late.by_instr.json.gz
4236a6a1166319167a3349633e5c2055dfcf6d310b5bb8b2e22abddb4f2ba302  release/kernels/late.by_unit.json.gz
c8bcf643291f8b0fd4ce5f94c991b1752d3cc0afd1fe961d79a0c4527396dfbf  release/kernels/late.ccvtrace
7bbc08683213142b0dae6430361eaa7238592e30b3e52d59a3995c43016622d7  release/kernels/late.log
86084f6bd747a2cf32acbc0ebd96ebd3e4ef2d8d9e21be49e3ae49290d7927f3  release/kernels/late.oracle.jsonl
42d99bbabeb33605eaa5585ec4c306891494d70307453502ff2c74bf4341e62c  release/kernels/late.sv-hosted.log
3603e0bcc7424f6bc0494dee6c482fb424e46613603ee50cdbb8f871d734991f  release/kernels/ldpar.by_instr.json.gz
656cbbd60ac6af9bbcbcc4a8e5f0ff2550022de4b05130e9856ef14a8e709bea  release/kernels/ldpar.by_unit.json.gz
ea6e760d829ce449b64ee020bbaa49ac98a6e237265398a33f4d2f7dbcd2fd7f  release/kernels/ldpar.ccvtrace
9f52c37eb307bded7d09b799c6a75351c43542a93da8e795dfed057eaabae313  release/kernels/ldpar.log
8ac08538e9c807637babd61b31e340f7461878ada31f0c0b83cd66331cfaf486  release/kernels/ldpar.oracle.jsonl
7ec2580408f540ec0b381445f09fcef43621c8e974a720846534f65c9ffe78aa  release/kernels/ldpar.sv-hosted.log
d1066fc1f5ca100a0d6318f4871e0bc3f025d9e54b0c1eace8d19844feb055e0  release/kernels/lnorm1.by_instr.json.gz
51211fb39e4bc6d76fc1e644b128249613ac675c3d4437ac55a531f4f74d1643  release/kernels/lnorm1.by_unit.json.gz
15965ea9c3aa44aa10bedb0bad8451ec538aa59c745a7914e664613cd64df06a  release/kernels/lnorm1.ccvtrace
94a983b1b87b00a5383384192d75c28f8b12b9325f92f7483dd79795d07bd222  release/kernels/lnorm1.log
a8d85811af988a1b9fc00db1517300af3d93ec8e589e403d3b9113fa9e0ffc86  release/kernels/lnorm1.oracle.jsonl
01b558ea2e83c90de1ed9dbf6c938583ea80a280a3ebadf29417f7f502331b17  release/kernels/lnorm1.sv-hosted.log
f3a8a98a04bcfa0c13777fc130cb2f77f28435f950f6128ea78b5f3233da59d6  release/kernels/localsp.by_instr.json.gz
f7b76b6fcdbd210b13a0568730b94362fb054221009e1dd02689bc4f7e9deccf  release/kernels/localsp.by_unit.json.gz
f071e20365747d7c7dceb9a95f90f3d33ba21d11a5d4db440da24fd58bc69112  release/kernels/localsp.ccvtrace
409398211acac6ca33c070cc63a59165c24d5d26dad4d7f5a63f0812b3b0079f  release/kernels/localsp.log
55e3c9f36e7f7d38c0ddd38903aff4bb4509ae862015c592e6b937ea258042ca  release/kernels/localsp.oracle.jsonl
842bebfc3397dabf16d0011d711e3c6b6a2efc6dc2e88e3887fce343dd00ae06  release/kernels/localsp.sv-hosted.log
2c10b818484943ac602db627081f1f1a7a85a7dce4b973e78ad4ed93242a934f  release/kernels/loop.by_instr.json.gz
f00233be959787b2277f739f5891b29e5435042a68c51540b76b87da45822510  release/kernels/loop.by_unit.json.gz
8e6c9417e35af8bbae117adade5b9d2de71420fc35abe4aae7df581e61dd52a5  release/kernels/loop.ccvtrace
f866d8a4749354e95816291f3c5889b929e80f35dfcb082fbc11fda7ea14042b  release/kernels/loop.log
03ce5920c06c93e93516d8e53c3f7169f14e3593de204eacceffc0b8a3e32016  release/kernels/loop.oracle.jsonl
09a136b859ea6153ad81290747bfb28f109e8c62b0ad3a24686b0b53a24fdaa3  release/kernels/loop.sv-hosted.log
1c910d7568279d68d7e4663dcccbc2c1c2a62175896138ee0ef61d1569c19e14  release/kernels/merge.by_instr.json.gz
27107a98b8f6bb00d0d670e76872729ab9218f2bd5fab9836c441a6a2b7342e1  release/kernels/merge.by_unit.json.gz
7c5c27b8590c634e6a6fa0ce6ebc8afed33e3101ca7690ecc2efe7cde41a32b3  release/kernels/merge.ccvtrace
33e93c9c0c53e8efb684052041ab2cb0e4bcbaa6f7de81b2a0c08e514f458420  release/kernels/merge.log
f96d28815f8756b1f5a45ded53e6170883d2dfa10f9eef0d14b8050b1318164a  release/kernels/merge.oracle.jsonl
da6b4c49cc5d4e2c46f2c672eaa1649b3a5d93d40430c39d74cfab18fd5ebf1a  release/kernels/merge.sv-hosted.log
17bbf599fcd3cec3b78ff9e148abde30d6e64841afc4994b75de58229878253f  release/kernels/missrun.by_instr.json.gz
488e34c7fe2d9905d462d303d59a456273d3353b8c3a57871aae2810713a87b7  release/kernels/missrun.by_unit.json.gz
2316c988d3f5f9a81a1330c9f8cb3d4a6df11a470f97e887ac9683d923949b59  release/kernels/missrun.ccvtrace
4782ff541659b0a3fa7be602db5b132e0c8024719642729ae881606e40904ece  release/kernels/missrun.log
531bdaf281e5590774bd2775427f25e4cc0419cf8e3d5b6999843ffe9ef87258  release/kernels/missrun.oracle.jsonl
dfc1562fefaa6c2837e46af56f5456aba3b147a708a14311a9f3feaf721ecf7f  release/kernels/missrun.sv-hosted.log
ef49362d5468ef1659370bf3e28faa869f41ce83a4d2e62cfcc8f25e19586a52  release/kernels/mload.by_instr.json.gz
8a7d28007098fb06ac511aeaf102609284c6ee407164eb2cf39e01ff09d6e589  release/kernels/mload.by_unit.json.gz
790adbcad540ada593e57f65e351bee486eb890fd1c8b57658c360e427adb7f9  release/kernels/mload.ccvtrace
2e1e63b5d1878fc3bfe5e38a97e4210c5905dc4ed76238e0781e0c1b9e013ac5  release/kernels/mload.log
8000e477b9a95dfb9f0af964e8346acb9d36f1358fd06ffc4ff7cf599d2b8868  release/kernels/mload.oracle.jsonl
89f2486ba9843ebeb1b3f5e895ebc82b727a77921435db14bbdb2d601f5eb4c5  release/kernels/mload.sv-hosted.log
4537cfa277b7269965c34e054f7df8d20da4fd5f37390bc95a7273049b7126fa  release/kernels/mlp.by_instr.json.gz
8e7224655b6c8e3c3771aa05a80659906bfae1cefffa2f0b6cc943b9af29f65a  release/kernels/mlp.by_unit.json.gz
8f613f012a674348a38e2299a56dcd01b023537766a8cc5ad7676a145dfb1e9d  release/kernels/mlp.ccvtrace
e2114712ae56119c74d1725c8ebb2604aa0822dd5648d9c3dfc568342d046c85  release/kernels/mlp.log
138d282f88d56c8ad648a91af0a983254b55d9fa22942c00d47b327f516a6e44  release/kernels/mlp.oracle.jsonl
df0b22e39ec866faa6f65b5a4ffbbd74353d0669a4213ae739cf8f65de79dc12  release/kernels/mlp.sv-hosted.log
80881c6e772487d0515aa2400e3470d6b6e3859ec0167090c560f16394f86571  release/kernels/mwmiss.by_instr.json.gz
8b89ca39bedadf50d9693f38879d46c307ebb739f1fad25b74a31f28547a0329  release/kernels/mwmiss.by_unit.json.gz
184fd08a855c3bba8e0f7e34b3575242ec8e3081d36f978ad004ccd65846b322  release/kernels/mwmiss.ccvtrace
c62f5039a65e7587ef8c3a44bc659ccd318d97e6472e460c2c25a76e798006c1  release/kernels/mwmiss.log
8abe8e8997456a2a6711ee72da54d854b24e20abbdab28e4b7271c0d28418de8  release/kernels/mwmiss.oracle.jsonl
9e606b02a46af8205645269d328e2cbae78c0f099c3ec42ee2123da28818becd  release/kernels/mwmiss.sv-hosted.log
7dc4b34b467773afa676ca2f452220908913a3f726d088ec3a0bafcae13a6094  release/kernels/narrowadd.by_instr.json.gz
d1795a4cae1294e5e6ec2b36f19766747f6b07a7829743e2e20c97112ea296de  release/kernels/narrowadd.by_unit.json.gz
8d1124e67681c4b786f5e56b41ad0f19fcdd6ab00d6faefed39eecfdf5bb665c  release/kernels/narrowadd.ccvtrace
7996f0a3c636f81c340eb845035b44eecf28ff087ae83510fa2c2b3cfa8743d2  release/kernels/narrowadd.log
40a2cf629853dd404bb06b4a07e35abde3d12efc13f26ffe28f923daf2994574  release/kernels/narrowadd.oracle.jsonl
6107065f788b3e6ac875e1a192e335640abcb27d1ee2fa2f0b5e395255f86720  release/kernels/narrowadd.sv-hosted.log
a3a1aaa9b8f2f2ec26cd4b64b4548fd7f924b418080b77a16514550077069aa1  release/kernels/pgcross.by_instr.json.gz
bc26d8bc80fecfed94ea408e95b8bac74dc395053c265c04566529f1d1f9ddf9  release/kernels/pgcross.by_unit.json.gz
dcdffd56a3b379f51e9572c3708ff20342baf27119f8915a260bc2ffd95e2002  release/kernels/pgcross.ccvtrace
455fe9c66bbc12ad338315206c8a3cd2de560cf97049d79d0a614a1fdf4be3a3  release/kernels/pgcross.log
58aba9ba5ec6a72271191c0249014802cdc7e4470d27491f499a077f17ecc039  release/kernels/pgcross.oracle.jsonl
203f3fa46302455ad8d436fb76627f766972750766c1a60f1857e983c9d5a8d5  release/kernels/pgcross.sv-hosted.log
4c57b5dd6ee736e5e6bfbc0d9798b90fd1fa1ce793290b17bf4f43bfe3b3fd82  release/kernels/pguard.by_instr.json.gz
631f63337c966ab423f2050d4ccead919e3659c696fc846202aa7f94b5af7d2b  release/kernels/pguard.by_unit.json.gz
ac59e51c29dd4a8d1179fee1fe87d5778cf214fe591f41a36596e881a2601566  release/kernels/pguard.ccvtrace
2e514be55c95ff3d12900a08b3aebbaee27987059b21659637bc19cf708eb851  release/kernels/pguard.log
690e56f1cb8d97cbf67124b7dff3ad0a90cb8981814cd1709cf0cd0e035b3bd9  release/kernels/pguard.oracle.jsonl
c16896b4e36b11cf1de8c2e2315b3fdc9a0009d79c9af583fef3b165811e866d  release/kernels/pguard.sv-hosted.log
b30f7c633902107d185c80231bcdace5576dc670a79fd1557b843f2ee05d9ea6  release/kernels/plog.by_instr.json.gz
1f32a89bee2a9d3d66e1a0dfbc721f9fd1ad2e5f30e7f5357a6ffadd13b42ef8  release/kernels/plog.by_unit.json.gz
7823562f75147705b01f772471b6175774023d19935926703e158062b24cf94d  release/kernels/plog.ccvtrace
5dd800c35e450251b77b9013e871ed605a01b3b79d999d146ceaa0132460cb94  release/kernels/plog.log
0c99915e2da60f4670da00504a6371d7d17701d4431e733a3ff8fa98a2030d6a  release/kernels/plog.oracle.jsonl
41b2decbce9b0c1f01e2a0efd7a7841f53aefbbcb1c91d04eec1044359948de2  release/kernels/plog.sv-hosted.log
cc380b84f0b91142ea51731b47459e9dd36c4c66023931f9b6b3e3f77980d28f  release/kernels/pmovdiv.by_instr.json.gz
e2d7ccbd4d07e02b381382d436769c254281896c12139a02014911f9151385f9  release/kernels/pmovdiv.by_unit.json.gz
da1865544271c3c70d3eab1061f5060d833a856975f75b28d0921880ec954a97  release/kernels/pmovdiv.ccvtrace
1fb7bbeb928dfa33ad6976c7ff0885380d55798d1f12a3986ee5bcb1a2a90d25  release/kernels/pmovdiv.log
7bc646cff6166a51bdce03d7c1b7209e871f0a91d743083a9b910a80bcd0b33f  release/kernels/pmovdiv.oracle.jsonl
b95283181b8b55ae8c8693c1226db69b86692625dfdd493a424473c6357b191f  release/kernels/pmovdiv.sv-hosted.log
3534f0e27bf9270e3a5a5944d39537944335f4f16dae07df5b111284e617e3ff  release/kernels/predlane.by_instr.json.gz
8b6df396e64b22c6f5cf07e4e181b0d3c3bdc7a826320964e2709b2d8b74e879  release/kernels/predlane.by_unit.json.gz
9dbd510f7be3a2077606f9f8674dfe46dc26cfe13fc16733902127ce2beee92f  release/kernels/predlane.ccvtrace
4f5c315278af5d7b7cd1745f5fa1c9586b79966aac23429b40df2a6c11bb04e5  release/kernels/predlane.log
c45f4177b9e84fc8a6e36b13534a0c7636eb30a3f8531847100ce5e23bf404b1  release/kernels/predlane.oracle.jsonl
22562ec6cec94905d4402f4f5948d3c74608d51bb386c3da425abde9869b60d4  release/kernels/predlane.sv-hosted.log
dabe9800a2c87c6c1a3743cfe37767b33c762ec9caa404be8cde99001733f479  release/kernels/predmerge.by_instr.json.gz
2bedb23b9138c68a97b52397c58d2205530c0c0197716fe2adddf51819b5890e  release/kernels/predmerge.by_unit.json.gz
745a2074a86865f389cc443817052e25d3d5938b6d845c443ea59b15f1d05b2b  release/kernels/predmerge.ccvtrace
7faf372c46056a939f4fb2c6eae629cae2f49cc35e1788960b99e85ebeae48d3  release/kernels/predmerge.log
6c737c49434bcd08e3e0814c8b1dbf15c586ae74f7929ba3148ddcee2c62c845  release/kernels/predmerge.oracle.jsonl
458733c334030e06dc47278e9dbf237491351a54b060ecca21a0e0bd7a6af31a  release/kernels/predmerge.sv-hosted.log
fe68b079b95b4dc825fac11c30d362b45b67836498e2167bc1aa4849a245a2d8  release/kernels/predspill.by_instr.json.gz
d1bd9bac4271832f43dbb8d04e21563c8b8888eec19531b089b1414b95d34997  release/kernels/predspill.by_unit.json.gz
75a57265c96bdda2564b4dd31052310aa58f9e79df46511fe7c6ae0bab0aff6d  release/kernels/predspill.ccvtrace
ce9e896c491b96b3f48d4dd3ced4510e123f4ea336826c1c8cf36006816667fc  release/kernels/predspill.log
b7c84c6478117ffa0f06da0e6ad1e4628e2683426a7911080810e78e06a5242e  release/kernels/predspill.oracle.jsonl
67c2eabee1c90c9334a3e369c6e57546cdd001b0454da214034b34811140e3f7  release/kernels/predspill.sv-hosted.log
0d00ef5152d71de70b9f8c01795c94e5e925baae37b4126d867648975f6f7bcc  release/kernels/predswap.by_instr.json.gz
4202dd8dad10f5a447f6719d6972c362509cb76f2e45c02d6f7992b739247e32  release/kernels/predswap.by_unit.json.gz
c26aae306b8e7b8a7b34b1f1af0b103094c9689c1125529c3483410c8ab600fa  release/kernels/predswap.ccvtrace
367395ec06f0de718c1c19353cda3dc36a9252302f0fb689b37cb916384c05db  release/kernels/predswap.log
a6d4f7ed517553816d889c7c9eeb6bcfd1f6c973fbf682ecb69f3c2de619f7bb  release/kernels/predswap.oracle.jsonl
da43aba06fa2faa759a164235108bf2ade274f094e5e7c7d309b5de33c1dcc3f  release/kernels/predswap.sv-hosted.log
77fc9878b770339cfcc1097614348c45d9ff30f812735b3cc71ebbd426d0afd7  release/kernels/privwin.by_instr.json.gz
81c4aa90d2813ae635ad3195b5fcb77fb3a902d87ace3512275f9d62db219e55  release/kernels/privwin.by_unit.json.gz
7a22936f42c5c20e2e195002a044826a8194ed8c8ffd10c8eb59c29858d20330  release/kernels/privwin.ccvtrace
4d2979ac4ab0ee9cd7c8cda5ad46d9dc2ca40440c2859d8c1730dab1a5ef056b  release/kernels/privwin.log
861f686fc4480363472908d679d8815e8c957d768e7ab32c826930527b0fb7a8  release/kernels/privwin.oracle.jsonl
3d30513456ef86cbb80b18107fcc2f7eeb60db7e68777714c92a9a6bd9824338  release/kernels/privwin.sv-hosted.log
ede7774600c62a0f70cdfbb0837ffe870510fd33d7babbb1973f0425594f5798  release/kernels/provswap.by_instr.json.gz
242f97f7b6dcca6eedd786e1067ff381d733af87eb572c06d0fdf64cd23a377b  release/kernels/provswap.by_unit.json.gz
a4df2c680eb6b16b6029511cb938a74944abe1b53f37864bb42600f73abedb71  release/kernels/provswap.ccvtrace
c51a2d0144d451f0d0bd5c7f01097960b965f1a2a021cf9523c04f8eeb55e5f5  release/kernels/provswap.log
c9c32a793d54cc7401477f582487f7e8b345b2669a75337b8d6327120d98e5dc  release/kernels/provswap.oracle.jsonl
6b18430577be4cef0fb19d7a4f4a1cea4fb913c507b0fe170d2788181db5d048  release/kernels/provswap.sv-hosted.log
c062634d871744f7896a38a6a762543bafb9d09fbb12594b155475ed6ff30e6d  release/kernels/retmiss.by_instr.json.gz
0db8fd67f1e0857e5b19e5884f487dad5f75a9af49632ee66b67b4a907aa9976  release/kernels/retmiss.by_unit.json.gz
9b32640175418812c588928ee0140ca656047699a9b8e6b62701a6469f56f9c8  release/kernels/retmiss.ccvtrace
6741cdcef6adde227ee6f6ae609171e0f30860fc63bd14047ede6239fc8b34e6  release/kernels/retmiss.log
e5ef8538e838c6cff7febfc679dd091cf5e002f82d34f1009b1948ce22bc3649  release/kernels/retmiss.oracle.jsonl
7eefac800bf75a8d0428fda124e136778973f9d4e6dc64411caee38dabb62879  release/kernels/retmiss.sv-hosted.log
b8af37455b33a1b36ab55a477d4761f76bdf9dd3edd8eab5fb7f2c3731ac8ec5  release/kernels/roconst.by_instr.json
1bd6e3d57918f6dc12f88a90fbad3431d9d6ab8123f8959ed02ca7c9430da7dc  release/kernels/roconst.by_unit.json
55981e07a1a8d3ed8b7a9f6797e5f718e3161cc5f6e1218171db77f9b6115f18  release/kernels/roconst.ccvtrace
ff94a2918fb8a411a7bca72900e139969eb9788e56c8839af7eae053dd9185e7  release/kernels/roconst.log
8087c0671de620162881aecd38cd6114b78e7be6bd71201e3ec02c9a2e2e750e  release/kernels/roconst.oracle.jsonl
eac5ddfc67a7dc39f690a74fb0100d6a14ed33b7db9b4d2a341900213903b1d3  release/kernels/roconst.sv-hosted.log
10c797fb8d044649f6d3dee9c07281c225794258b33e21124d781108ba92c747  release/kernels/rogated.by_instr.json
150aa16446ce719c1a197d00be3b4dbcb6e6ed9a3220239227dd18231181e76b  release/kernels/rogated.by_unit.json.gz
efce29ea7c5e82d9ca9f5522549f4958218e9ae67a9114f6c26c60f34501ba52  release/kernels/rogated.ccvtrace
123202deab65d07ae58b4f5e0d3e057b8240c73d133d058df16afbdf7b8d1355  release/kernels/rogated.log
7cd02bd4cceec5a044d6b4d6a80df1e68ed0ae71b0b2a953143636d5b809ea6c  release/kernels/rogated.oracle.jsonl
537f53cdbb150601d4540f566cad24b5685a605edcf7101ec9bb0fa6ec4c0696  release/kernels/rogated.sv-hosted.log
c96af8dd5ea2e2eb149ea5d071018a5b71426573d1299a8aa8ba827a6515f69b  release/kernels/rokill.by_instr.json.gz
80e80a2e1b16b827d544bcc6b58edd13fe193c092d0c3f19a76aeb0dde9ea6a9  release/kernels/rokill.by_unit.json.gz
8a540e1a67dce0d3845964ab547fce4b1c674a042f6be8c8d8c8b7dd46f4663e  release/kernels/rokill.ccvtrace
a79d727e80bb32b05293ca69e95d1b3946c235aaa107095c53edf9419f0202e5  release/kernels/rokill.log
94efcef96af469a512d346ce61623980fe86383188eaebd55120f716db596f14  release/kernels/rokill.oracle.jsonl
cc9f198a222e041f5b121aa761270156884340295819dbc1846ede589d3f44b3  release/kernels/rokill.sv-hosted.log
318a8b6b92fb74299acdcc41512a0e46b452dda4bfe5270fe3e294b5959c032d  release/kernels/rokilllane.by_instr.json.gz
cb1ad389b15d62f1ace6d677fecda66c9c261455c747d8be1164ba837e2e7f74  release/kernels/rokilllane.by_unit.json.gz
c54a973f624a7ad5b95499138a725ad2287a564534121f4f568394896b3522b8  release/kernels/rokilllane.ccvtrace
f595321fb7ad42f9333ba3e2a7cb9bef3dabcfa3db38e03b6675eec8f9bb84dd  release/kernels/rokilllane.log
f5ca6e666eff2f44894df74a291b43b3c0e7be0a63a47d795fdefd7b22016f45  release/kernels/rokilllane.oracle.jsonl
55573dd85f586e8573e887f632b46f90ffeb85e486c78f4a89a45cb7776e51bd  release/kernels/rokilllane.sv-hosted.log
6018676757a05a45231fba12ff6df60d07f415338c1d836cc09d99465b73577e  release/kernels/rolaunch.by_instr.json
8512780fe1bbc0571a43ff91654c0ffdb7545b9c1ac040c907e50a29bfbd10d3  release/kernels/rolaunch.by_unit.json
289a78e36e414127402cf1c2f9514ddf7965e2988e5c5c2c172bf77c872262d4  release/kernels/rolaunch.ccvtrace
371d15ae379840f4207401ff871dfc5ae5deffff3e4b1034c83ddbc66f6a3d0d  release/kernels/rolaunch.log
e7dad585c3e70615de04330fd03f4f282c29a005dc1732a35655fb261d51139e  release/kernels/rolaunch.oracle.jsonl
47454e8d0a0357ac09e97ab9f143d4039faeccb0168866e670bd395b23f7531f  release/kernels/rolaunch.sv-hosted.log
b8af37455b33a1b36ab55a477d4761f76bdf9dd3edd8eab5fb7f2c3731ac8ec5  release/kernels/rolimit.by_instr.json
0e20aabf7e39b687a2ade0f80fd977c9d7bd313c2cebdac11d43f35296e7d911  release/kernels/rolimit.by_unit.json
6105e32f751a15c0875d0d2a30a1e054656c0475286b5e2739728e13fa4d3e83  release/kernels/rolimit.ccvtrace
7832f04ccde4ecad3e94da09fd6ef61a15bcf77b29a10fd6cda4cb4c1313b48c  release/kernels/rolimit.log
1c5bc0cb8e8b2e69505fb5a551a16d5d10c56f232b88da7a27e336ad7d962de2  release/kernels/rolimit.oracle.jsonl
018ed0198aee15d3e23eedd3b85406fa4d6aedf6264c0ca90ad6461dccad3c2c  release/kernels/rolimit.sv-hosted.log
b572a4c88160160e2673f69f560d3d36c819b2c874d25f134fb0c809e4426616  release/kernels/roload.by_instr.json.gz
f6ca5c5e345027211ee257371164e7a20a049b9c792f40a1445af0c173c54e31  release/kernels/roload.by_unit.json.gz
0194db79692e1ecf3808cdb94cae8661210c638970d53bbfa7df11bc0d70ed6d  release/kernels/roload.ccvtrace
fcc3b2d334bdcfcae1f619e84883ff1eac360f81c71aa48b3075b0f907b9b302  release/kernels/roload.log
f7c1309cc9764769fb5803f6fd0f2f5e1eb418f2d23fbe5e17cf5f9106869fdf  release/kernels/roload.oracle.jsonl
a0d83f92b9b88a4f117b424d925a6bc7e9c798a881eabaf6b2da6e077f019c70  release/kernels/roload.sv-hosted.log
0c128612f2e2b405ca078c4260b1759aaee0f63177674ed3051f046d89500623  release/kernels/rope.by_instr.json.gz
b043e9d902543d375cbcd6a181252494fc0f1fe2087bf3f41bac9cdf0cef3da0  release/kernels/rope.by_unit.json.gz
48fa7a9db2de917c046b21900d6d599012d973181049f75c6fcd2a961b92cf16  release/kernels/rope.ccvtrace
6098bf8f8f071afefe0454906467e7a51b3c29236881e4ac7f18575e79c401b2  release/kernels/rope.log
d55f9efae392dc8877c102c01c0810e7654b666b6ede386328108164c6cf88f3  release/kernels/rope.oracle.jsonl
5fbd30ae5194d1aed9457db345556725306768048cc7d3a901eee19955c9321b  release/kernels/rope.sv-hosted.log
c9d6d374150c6028c259846f30c528cacb0ed13cf9b8a85c776cbb338f3ecd7b  release/kernels/ropediv.by_instr.json.gz
6a83d302937967b9e38602f110dfd3ca609c009e78dd09b05e520e53189e4134  release/kernels/ropediv.by_unit.json.gz
ad4ff8f81d987dc6f592c4e128fe5cd3d012d0c05f1c222fe2dda221b31a6584  release/kernels/ropediv.ccvtrace
d2435c5275e9e649d73142c96b6858d14a471b268a944dad943def4be7e1a6e1  release/kernels/ropediv.log
10c0ec6ec18b7b44638c790033109198c079d07c1537bf193353ccedd00a920f  release/kernels/ropediv.oracle.jsonl
b782ccd23062f43cc4fcb4c83e49b4eec4966dd03a225d9cbf5dbb115c5585b8  release/kernels/ropediv.sv-hosted.log
d0e975f90c4fc8bf31369b7515d13e6efa8f7e46f993844d93d4c07d1f9d6b83  release/kernels/sel.by_instr.json.gz
de389fb90e6c2e98b221ead07e2e0105e97229f19846ea91fc68ad3b0425f903  release/kernels/sel.by_unit.json.gz
9c53eebe2b618f054a586665b1b4ded69152979d8a322800f723264581b649f8  release/kernels/sel.ccvtrace
b8f0aea93813d06d71ed246ad987d811e6fdcd29ac2f40c242efe42c9dcf0f24  release/kernels/sel.log
87f6a81e8afa004c8039bf2f61c90176fcf29ab29bb17ac44aa016a5cc8438fe  release/kernels/sel.oracle.jsonl
ff5c86754eb63f613260745e2e54d03e86910aa91d921e77549eb0804041c723  release/kernels/sel.sv-hosted.log
edba16838fa851f78c02a3573a5ddf8ef97281603ad1466343d1e3d4580d6950  release/kernels/sized.by_instr.json.gz
38d1d59492c5ba52bcd5965fc75ac6d394d35a1286f3866f7f3846be1c45f271  release/kernels/sized.by_unit.json.gz
9ddf8dc62025f1e52adc724455b9c71ac8280d0996df3a3927d43ed75986b2ef  release/kernels/sized.ccvtrace
bc2fbc1e9089cb3762a267e1c109b3f0b5eb570ae43e1298d73406da9c1e9db2  release/kernels/sized.log
36d903ba1618bd1faa437c9812a6ee6c0c966a63196c796267d74bf2695ebc3d  release/kernels/sized.oracle.jsonl
e87db3e176f27ce83a5a7a43c134fa99c5dfbb78f198d69df13a025a88890944  release/kernels/sized.sv-hosted.log
3fc59cb3bcebb7cecd6b1589c3302e03900ad32234e20eabcb89c6b2ef35ab1a  release/kernels/slotform.by_instr.json.gz
e9e5e5feba704e5a4fcb268a1c8d8598c651ec9e94bd72b6efa573af4ec00fad  release/kernels/slotform.by_unit.json.gz
a7e897022bcd940e8be44f31a241721c04168993394969a2009cdff90396e234  release/kernels/slotform.ccvtrace
a6b73850ce6cfb796b5cc1f1d7753f4dedb584e9c17f3b7aff79eb4db6a1a52a  release/kernels/slotform.log
8b61db7419b18cea8a646fb628218447e72e84a18a9891ffb73b441736138ab9  release/kernels/slotform.oracle.jsonl
4a4b224b6f36d937e04a3dac6510451f898bc488604993707fd855956372318d  release/kernels/slotform.sv-hosted.log
020c5d86899161f5d85420b09c0aac1ea9528d5b1d16678e7f0173dda3892292  release/kernels/spinwait.by_instr.json.gz
1af747902e28f20b922d187170d61fdeb4679d074a82cd4c4ab850fc8538b997  release/kernels/spinwait.by_unit.json.gz
d862f76f68698bc1a90901e48cb7aa5bd0f3c5251402ba2c3ed246791d83eb33  release/kernels/spinwait.ccvtrace
714ad6121a5cc9b9a35d0abaa7ff923ce127a2ea957acc01451dad385cf1545a  release/kernels/spinwait.log
868920637236c878b33779bd450439466fc3626996a3164573dc11d437d5c709  release/kernels/spinwait.oracle.jsonl
86fb890540594b4e3f4476b3784f24af4f999ac660e60608eba5c1c46cb4d609  release/kernels/spinwait.sv-hosted.log
7233939132492cf5d1e93ca9826fa26d0efea57ab55db3ac0c7e87fc568efe5d  release/kernels/spmbank.by_instr.json.gz
1d8533c133a30079b3766ff7a55199a94568d10731feefd01d49ea1ddabe3d5b  release/kernels/spmbank.by_unit.json.gz
0b63ddd199108d5d57dacf8da3b47f37f0c4b36c8ae2b2605a61415aba0d0ef1  release/kernels/spmbank.ccvtrace
6097b6dacb597c0bd06c7e502815be57848570f1c9de4541c4f4618e1025ba1f  release/kernels/spmbank.log
3af490cc37d7a92dbe719b57de216b648536eb301ff9d13de9a39f50d150d725  release/kernels/spmbank.oracle.jsonl
49ca954a548cb671ed6caa50c825a3312bac4e14b6323765d382a3cf9a6f7f7b  release/kernels/spmbank.sv-hosted.log
667ae988d9166fc82786cce450f70235cf923edfc733c34cf44bfe881e945114  release/kernels/srd.by_instr.json.gz
fff0af0e1bce555ddad14cf74c94b08c702f4bbfb3c38e3e2c9ab9f09884b7d9  release/kernels/srd.by_unit.json.gz
d0cdd0ba564115a18c44c0930bbb53b299072ff23d43f1accf29a4ebf90d01b3  release/kernels/srd.ccvtrace
3457e8d78f7b3da9840d7885eb9b6c0a0244ea0ddda73e0067bffe9e9c98d744  release/kernels/srd.log
b08eb5e3673cac7eebb8b72af5ed3783c8e70a9e96592e76bf3722551bc79473  release/kernels/srd.oracle.jsonl
8a2c6b7e9da0a4de59a384ee3f9c429d28fcab36ed0b6a689cbd88ecf04a8a2e  release/kernels/srd.sv-hosted.log
460c68092ae7e0fbaed85e31f30e5f076d5c59a083aab14c295b8efcd9db5681  release/kernels/stall.by_instr.json.gz
cee8563aeec31c8131ca9af6c8c6543390d4dc999e79f221b9d23f261254f4f5  release/kernels/stall.by_unit.json.gz
19e4afb25a58f4b07f481ecf92285f72b1466db2214362da4746125232c318ce  release/kernels/stall.ccvtrace
0e83017402b6ebfc90193c3fe1ec1c57697746a8c92242d3bfbbb54e526ce698  release/kernels/stall.log
500db2c482b07a0706583422cd68878301d0146c1f872ccc1f11bfdcf5c993ef  release/kernels/stall.oracle.jsonl
fc534e89f4c924edd40dcc5e078f117f9b45c923a3af222b029fbe2a22dbb86b  release/kernels/stall.sv-hosted.log
455273f7851045aedba921a335bb74a80f06edb1624a0a13d84611c596f04666  release/kernels/swap.by_instr.json.gz
5629ee6c13f2a7a5ce4169475d06a07b87f7b16f94e9dbbef0b57127576ca5f0  release/kernels/swap.by_unit.json.gz
5133728a04eef5956e18e875a30cd0151cbd76c048d9eaef0332ca5b3f60b096  release/kernels/swap.ccvtrace
51b7d55aa98bb09dd8f550da4e6be54998204c11fa0dc48faa94ab523c754bd4  release/kernels/swap.log
3658a26316c1ff7bc1744304a42f736e930fcde2865c8913e6cc67a22ce96667  release/kernels/swap.oracle.jsonl
62d7fb6ef89ca3e35874d7bd2bd7070782db6ca48abb50fbcc7d94df6ef4a48c  release/kernels/swap.sv-hosted.log
f3b5f52fd67d6d1be9e6b21b0ec7563663418ce914e6e816bdd9873a6fc68448  release/kernels/transp4.by_instr.json.gz
1856ebf5b75e0eef307f8ba421da92a327c6d79d4fd7eeb616b1a2624ee5c165  release/kernels/transp4.by_unit.json.gz
1e2c5bfad6df6df1b43a24ecb5c578463907141aaac4068c15bb15e72b12ada3  release/kernels/transp4.ccvtrace
a344611b3b1d958cf39c497cdc7f7dbf191db1be0a201f3dad4ae1e756f8a4d6  release/kernels/transp4.log
06396ace3ac19677fd39c700e408606e5bdbacb24997d663bbe8872e63dd74fc  release/kernels/transp4.oracle.jsonl
79e0207dd25a8b1de1acd42932d9c23885d9ccb3e7ce5aa936ca97ff886ee6c7  release/kernels/transp4.sv-hosted.log
dc9185ad743b0b1f28a24d65dffa8165a442d0705ebf2741941b539a11db5910  release/kernels/unal.by_instr.json.gz
07b0485a2b853f2a9c9d956a2675b2a5ef8ffa37ab4cb8dfd4bf0a49200c9c13  release/kernels/unal.by_unit.json.gz
e1d03a41dc5752c2878da70bdc2828fdcc21e350f9304be6bb765f0f559dfaf4  release/kernels/unal.ccvtrace
2e3869bbbfb2eaaa261b4d85139f6600a6d0cf6045cc4da02c08f924f14b421a  release/kernels/unal.log
c3d484bb160657a563df983d9a2532eac27f556636617960aa1e72183ac2b299  release/kernels/unal.oracle.jsonl
3c5fbf0a381bc67d605fd0c033aad85459757d241d1dab844bf1f7cd4ec42602  release/kernels/unal.sv-hosted.log
a9fdd254f2bf113e23e4890892b8c3e63480a72de9e854abc2f943b98393fc06  release/kernels/vadd.by_instr.json.gz
164de1f9f82b7c1856ba337ec0c071985be02518716940add1c57036c7f98351  release/kernels/vadd.by_unit.json.gz
27de65c3b4173f319c6f480e076d489caa51439f77a77b95b6394c07e37c4324  release/kernels/vadd.ccvtrace
c7d3eabb67601c4c8601f04d4973f022abb56802b1e9542d7547b74980329a69  release/kernels/vadd.log
0276b6d0611a4bbcdc004ab3987214aea138245bc7217504147331689a9c0880  release/kernels/vadd.oracle.jsonl
677810ac6ee15e37550c701db3b87b085cb4ca7980b464a7683f412e6191ef08  release/kernels/vadd.sv-hosted.log
94f066cd9b9e32a095ed887c9fe27611d3169c12f5b834e6da1b3e3e6c74c5ff  release/kernels/vadd4.by_instr.json.gz
32a191a88aebcd544c3bf1149fce84ea12af7d189912160b65388d15a659f592  release/kernels/vadd4.by_unit.json.gz
03a7a5a11d3ee7385b0cdbd6adcc6748b74b00a477c9f41ba5cbe9b1d06e7dc4  release/kernels/vadd4.ccvtrace
75772c0dbc8470d0fbcd62f27f3f9acf9dead3028d2cdb4d80bddcc6fa784795  release/kernels/vadd4.log
225aa18fc9f38aa9ad615aa11de254337d59fa705877553d873062c68366e0db  release/kernels/vadd4.oracle.jsonl
d62f94a165c3dc138aba9525d43c97efb29a0587d623a66bb7b0e9da49d094d8  release/kernels/vadd4.sv-hosted.log
0b20b1ac5bb3ecce1fa88d5fb149a618fa1965993bf5a7d1ccf4e17e827a58ed  release/kernels/vaddslow.by_instr.json.gz
54ba86681d4a2b44623bac3308daa4bcaf7293635618e1e8d68a686084327199  release/kernels/vaddslow.by_unit.json.gz
5e0899afba8d2b8fc087a2ebcadb3e6192d3c5f050d8acdf37b63d9fb3d359be  release/kernels/vaddslow.ccvtrace
3611036e09ac427e98ab9914f8a5a2844abd86e5a4e128e6138044a2eb15db56  release/kernels/vaddslow.log
e9e6218e8b8450e9f9ff6b39d659c994a1e51c527a0c5bd10d18b5658ae0e344  release/kernels/vaddslow.oracle.jsonl
7d5656909e0a787be3388389bbb69b38639e2393bd05aa1a97eb5464e83fadbc  release/kernels/vaddslow.sv-hosted.log
2a7cc9bf1a70c519e23b081ce4cb97aa65b0da0f37bf3bc4b5cfff1014f125b7  release/kernels/waypred.by_instr.json.gz
9ee88e58877f1dde270609847180fb8bc9ff044c3adcd1268977597d29ca50ce  release/kernels/waypred.by_unit.json.gz
4101b89e74fbadc1de50aae27176efc152d15547aafa56d08e337ec93519b063  release/kernels/waypred.ccvtrace
95697c664cbe3a63d683b0e9851efd403eaecb424a41620bb106842bc7ea833b  release/kernels/waypred.log
c8833938fa0199fa850184f9c93413283b4148a4bd7f1763d5597c544f14ad5e  release/kernels/waypred.oracle.jsonl
fc97f33ceaf8efaf1b8ea5d2de703f3c055fef5cda8fbb6b1657374f24c46894  release/kernels/waypred.sv-hosted.log
bf8fa372dae644b75f8fd9e65929778a0542ddfe1d3235cb0be312a7982d30eb  release/verify.log
f78197fa73514d4391564b6dbfda61c3c03a38e2134c9ddc2d24180f29c72e6c  release/wiring.txt
```
