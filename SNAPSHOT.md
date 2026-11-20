# Snapshot snapshot-2026-11-20-8c378e1

**A generated, read-only snapshot. Do not edit or merge it.** The source
is `ti-mi9b` at `8c378e126f071cd524728c865d8b4afaaeccddc6`, and this branch is rebuilt from source by
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
| Source | `ti-mi9b` @ `8c378e126f071cd524728c865d8b4afaaeccddc6` |
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
| `addrlimit` | `name=addrlimit finished=1 cycles=82 from_fetch=51 retired=5 issue_groups=5 order=ok gpr_mismatch=0 pred_mismatch=0 mem_mismatch=0 check_failures=0 class_violations=0 overflows=0 credit_leaks=0 cor_late=0 channels_used=27/56 violations=0` |
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
19b25b0e88b51b7d247159e71b338fdff27e2a42e8a3614e7da7f2f191ab705d  release/kernels/addrhigh.by_instr.json.gz
d879cb1ed41a331757371e0d82db8999f324276527fa48b52663f14b92054706  release/kernels/addrhigh.by_unit.json.gz
77bc0c3be8e830d8723acdd7c4f9eb29f4078b3115874372bc60e68aa53b7183  release/kernels/addrhigh.ccvtrace
cd80c6fc71770f7c4716a1d8f48409e70569c2764478253079df1545dc5cd2bd  release/kernels/addrhigh.log
569f2e22883fad5f0956c57ec734e6afbdd4b8a854e50277425172d6c0cbd766  release/kernels/addrhigh.oracle.jsonl
a8e1975577f06637db843ca501f4a7aa0f9c7ef9f45a7efc213193e07d680498  release/kernels/addrhigh.sv-hosted.log
e8b4f5e8af898d99f4ce858ef12650e9293f10d771c0562c2391aff6523dde05  release/kernels/addrlimit.by_instr.json
0f492a636900526a4b0317e8ff0aa01d04b4296962fb7f6c8e7e56d9bdc29f61  release/kernels/addrlimit.by_unit.json
2ea5194b29ca45199abdbc4833072881c3bbae331b4ae9cfea59d7d7daf5cdc3  release/kernels/addrlimit.ccvtrace
dc44479c7f0d23213dc943dbc7c54647cbf1083cf59a4312cd56636f0412a592  release/kernels/addrlimit.log
bc660b0b40359a2c5a2478cb0eb4950b73fd22db50ea76b80052bc195a1920f4  release/kernels/addrlimit.oracle.jsonl
046be5dd1c52d923a302ae147631b5c0386181376f6a25c891a1254edbc8ee00  release/kernels/addrlimit.sv-hosted.log
d5ee993d0a633a3a0837df8a1267138a4a90d71b0f13f2964db1fac129be4751  release/kernels/addrneg.by_instr.json
d4575a0211ba3cad70a041dab45c9876f749ac9173cd91604056151f0cb47c9b  release/kernels/addrneg.by_unit.json
b64cab0cffa732e5e0822d4d5e4704e4625cec46309de4e9af4fa929274a37fb  release/kernels/addrneg.ccvtrace
ef868475f5e0d71d05a68724b6822df1cd65101846265e32d6dadb05f7b24620  release/kernels/addrneg.log
16f5b0707ae44492a1efd67bb9dd38a7e79a7bbd354fa9207b9e7d150ff2f107  release/kernels/addrneg.oracle.jsonl
624acdb73b34351a10ae369fbbf7ba0ff3e370fc500d3d6edbb93c56bb09daa8  release/kernels/addrneg.sv-hosted.log
f0fcaedcec3b25f5fecde1efad11fdf0fffe5484b2998b2efa42bfede51b3711  release/kernels/atom.by_instr.json.gz
d516aee57d0e0f2eb672f38d3c3152e73b94d7e67a18db703d2ebc7a2aa3d1c9  release/kernels/atom.by_unit.json.gz
0efec9401f542375a590011cc55578411be218ed9a6aa16ed4e2cff66f5f5352  release/kernels/atom.ccvtrace
a8b50d8adb97839852a47b46d9d399ad28f542d6316199e1092c909a13678dfd  release/kernels/atom.log
504f5b6e9d25114dc35f2c70b21bb7b3f3c508c691de12dc0e87d12a74285361  release/kernels/atom.oracle.jsonl
d985092f2e7ca40c3d0d49f5324548e25f71b87994c0597793470c956e74690c  release/kernels/atom.sv-hosted.log
931b4ce8186b2c166ca1548d07d184d2ec49ae4da45cea5bbfcaa427326ceba0  release/kernels/atomf.by_instr.json.gz
7198abb0ea2f427cd92e9350764d294f267bffae27bb1558587b380b6a7a69a5  release/kernels/atomf.by_unit.json.gz
35585bbd0deab31f1d8022e6ca44de0a62c59364d9524eb19562473c7e745908  release/kernels/atomf.ccvtrace
5c8f5fe92c85bfc468cab7b7e6eff3ea4c39c00c77023e14253cce9b8982cd11  release/kernels/atomf.log
cfd1179edf4061a33ab2f75d7a6dec61decfe629000198189a7bfc2647b34238  release/kernels/atomf.oracle.jsonl
89ae9720e436b8609259478819aa830561c66ca9b5b210adc8cca88b98621e55  release/kernels/atomf.sv-hosted.log
ae40acfead4e9e6757bc0492311c92437fb756a972f1adcfca2d6156ab14d073  release/kernels/borrow.by_instr.json.gz
e96be70dc8ecdd627f5195639a7102ed6b7055d1a56b447fca538260bb907553  release/kernels/borrow.by_unit.json.gz
675e87f1c0e15b984bee253fff4849e79de6b07f83e6e28edfa102cf07f93b18  release/kernels/borrow.ccvtrace
68e8ff5adc24dc1f0bf3df3717758a858ceff01dd4e67179d2e9e770b63f70f8  release/kernels/borrow.log
4c565e1ce0b3baee36e158694b32c8defb5cd662b2f9af75cb5d8c26cb1168ed  release/kernels/borrow.oracle.jsonl
871fbc51a5176c56eefb044ce35c6372103d618b1daa1d74e439887b664a2ec0  release/kernels/borrow.sv-hosted.log
d40d95a07b17ad1a67fdaa733e9736d5fff5e0c452f0f63d4728d7cfd2ed8f26  release/kernels/brs.by_instr.json.gz
a41414d76e5b2a2234d7a6b517e4bbfbbe5722269f49c9b93a721b7a4d2cb325  release/kernels/brs.by_unit.json.gz
dfdc00e3f7e638e036c8544c04704d8c1d4cca764d189ea7aa1e0739036dbfac  release/kernels/brs.ccvtrace
df81f0be723baad1ea8c424e30c65a7bd101a8db033e3ef0f684c3b5c6e234cd  release/kernels/brs.log
e3c1cb3379580cf1aae44e8ddc8e846ef6fd661a573cfe0a8d4444b18a14dc56  release/kernels/brs.oracle.jsonl
ce2e82b6a722b36505b2ba1afc6a4af80c119f62b477e23466fc06ac449837f0  release/kernels/brs.sv-hosted.log
7173e00d907fe61f0abe2e2005c0d8619140deb3b406a01efc6211877a1ff95f  release/kernels/byp.by_instr.json.gz
54762723dc9c025d92cb74f0d7c135f0e13378785626d0c0ec9dc24873cf6c53  release/kernels/byp.by_unit.json.gz
7854d91e6d95d752645f7e735dcc1e962a38d1bb09ec6fb48206a278bbb3e2b3  release/kernels/byp.ccvtrace
ed8379acc8c086862d5f2f5c1471fef9684183d981dd5ae75f0ef43e0364b9f8  release/kernels/byp.log
5a03dfa4f3603fef49f1e3639e74e34152ca3ca5ef8e41eb959f8323040fa2d5  release/kernels/byp.oracle.jsonl
7e8b3fe58602ff14b84cbc364464c72e587c06641206b80a074d4501aea1f699  release/kernels/byp.sv-hosted.log
1eb1fa2ae632f72aa7281a45378e5886b3dc5233419e24b1bb46744febd50efc  release/kernels/callret.by_instr.json.gz
e51f574da31ddaeb895cb6c2b9bc8ab4dd48926827de7aa3c4ad38d6ab0eef4c  release/kernels/callret.by_unit.json.gz
504e99d94b3e643cfd5ebe2a52859ea41ad8f70b9e4e4cf9b67c7951146680a3  release/kernels/callret.ccvtrace
318a1c1ccd5e0851ff38f73471390ddfb45d9868f900c1823d55d078b9374834  release/kernels/callret.log
9b1d1b50b527f732362f837250aa2f26dabf3e76e16a4794856ebd8f105635b8  release/kernels/callret.oracle.jsonl
e5daf0b130c356fd628a788dc673c9404212e655aab50aab3597bb6a1fe905ea  release/kernels/callret.sv-hosted.log
19c99130bf2eb6d789bcd049329fff7cb31a2fc8843f9e52f51c131d0781ecd9  release/kernels/cas.by_instr.json.gz
b24dcaab8bcdfb80a135ad1325e0b4115d305571d4a9e039a4df1db4ac9e3865  release/kernels/cas.by_unit.json.gz
1893b3c82dc7c02406c7199cfffb3adfc635b66ebd3b96d501e6cc36847f41e5  release/kernels/cas.ccvtrace
5f402a316acd76b6d3d2dc2bacc8a56375d523d9b3216fcb9fd66079f5715890  release/kernels/cas.log
0ab31a9443336fe5d08e1a5fa5fcba3bc279b19022f7c5007908d39d8ef39536  release/kernels/cas.oracle.jsonl
9f62d05b5e005f4784f4f9fb787b972618933f4c2d1e2a018b7c0ea6d36af6aa  release/kernels/cas.sv-hosted.log
d0f6ae859be5438ae12aca6fee26ebb346bfc7b996ec4b0301d504580df38c85  release/kernels/chains.by_instr.json.gz
b164e4ca801a8e3a6cdb07450a7eaf06faca6515fba8224ca971cc925e5e0e70  release/kernels/chains.by_unit.json.gz
f3c7f719a83f93768af61373514062f1b4654c87caae7a6fd23d0307b7b7ca0d  release/kernels/chains.ccvtrace
a132549b1bd34b476a7c487f96734f0d27545b358c55e0c32b6d273e25593bae  release/kernels/chains.log
26a4cc5c5524c7219d8706c2582c80357dea60be9d6ffdec99dac7d0365e2264  release/kernels/chains.oracle.jsonl
a0df6bf64cc89f6341a6acac7e60bd60d2aeaadbba436a7f0cfdf8688c2ea871  release/kernels/chains.sv-hosted.log
149a7ed08932e2f05a317dc7961708104a49dfebb3ede5aeaf2216a8ab0989f0  release/kernels/coll.by_instr.json.gz
0c039ab0c3be7deb75a6b50543c54af1eb191291073c61c02fb38ce3f2b05a70  release/kernels/coll.by_unit.json.gz
b9d0aa1fba37d6865c6e65310ddfdec12b1a406436489ff0c4ce6a811c10cdbf  release/kernels/coll.ccvtrace
ac67c7fe82eac514974601ecf2db9b62a89e67130c1cf58cbe2b739bc3401057  release/kernels/coll.log
dd718d23c88df5dc7d92b055d8542865aa0e029118486af127312a8a578cfcbc  release/kernels/coll.oracle.jsonl
c0d7a85aaf62429060d38a98f5c5dbfb37f18db992855075ba1026d320b79004  release/kernels/coll.sv-hosted.log
9ffcb5cf737d8e29fe09997b3fbbccf0dff0acc30525272b38827284f2c2ff68  release/kernels/div.by_instr.json.gz
5156e929cb7b6b1144298a7c76cd1a64e245014b0b5f95e8f841f60f81a5ec5e  release/kernels/div.by_unit.json.gz
0fa59319a49569c81f33bc11b669b5cff44d54af88e0e1a0318682d79a62911e  release/kernels/div.ccvtrace
879a98baa389a7aee60d2b5ddfb5aef8ecf4093df71bb41feeb12100e92b40d4  release/kernels/div.log
71a567b85cf85622631490187563de9a5661099c78a590adff4ed0a0c3d24c16  release/kernels/div.oracle.jsonl
034d2be8e081ca9aa264a655166d9f89fad5cc682fb87e1e0a983790221d9ce0  release/kernels/div.sv-hosted.log
4f0dada90e73aaa0da65a46eb91576719f27ba6b72e8198b3583f0cee91cb032  release/kernels/divchw.by_instr.json.gz
9385325564efd457b30308c625aef4fd9f829aa1751cf8f10768580bdd32fc52  release/kernels/divchw.by_unit.json.gz
7171a5600e2647cfdb103881ce1d051b67e5c0f4b5522ff75b05208ed6ee3d4c  release/kernels/divchw.ccvtrace
f50180f6cc0dca1525e0ba156d673ac40c49999539a22f58db26edabd209a45d  release/kernels/divchw.log
58a541797f7a2df0a1c7528ae6a3edec212db90c7d3eb20656806f38b5c10b3d  release/kernels/divchw.oracle.jsonl
7c40b34091ebca0bdaf1b13b6adc7e0eeb67f0863b6a90a072ab79360eb3432b  release/kernels/divchw.sv-hosted.log
4f1fc5a9570a13b88608568982a6f0a61a400b41008a8f8674e0c27c24c3b759  release/kernels/divtail.by_instr.json.gz
ea6ef74bdea3416441504c0334c9d9cd9d91c0ca088ec113293543a1e2c26924  release/kernels/divtail.by_unit.json.gz
db804fbb5ad528ab14845763f37b3761a0b667c3bab40606320e4d62853ca751  release/kernels/divtail.ccvtrace
55bce275bbc98e737f5df0d35dd9c6ed7cb6529889e01cd4f6bdb513adc511bc  release/kernels/divtail.log
75f11a75c9b3b336e446140af4579f05b46c363a76b7aab3ec88154a07ba097d  release/kernels/divtail.oracle.jsonl
3721f00de6c92088062c21657f5cf0bcd2cf7e45910b25cbd126f8db67e34fd0  release/kernels/divtail.sv-hosted.log
463c7b5a4165cdfcb522ee4c45640b4c0697654188c6c78c4aa6459cf39024d8  release/kernels/divtail2.by_instr.json.gz
468c46716ba75d97dc5998860471e77b331cea962c2aecec00a26a0f925a399e  release/kernels/divtail2.by_unit.json.gz
a75fe12547373cd47764249a890c8e2cff1203790b37cff1678beeeb1c5b2c44  release/kernels/divtail2.ccvtrace
2ed3df505dcda5ba746a5c07d8b474253895510672f0d0ed354e283df8062aef  release/kernels/divtail2.log
b2db6b05eb6cf4a0a7677e31d0c6c2952d5cab49d353f0bb1883fe0b2a20ed14  release/kernels/divtail2.oracle.jsonl
65f925f6ca969187d665725d6cf5de1be17685a49759702c07e4c3b6aad461b5  release/kernels/divtail2.sv-hosted.log
05486780da0b81de104065f943e5b0638beb06bf879319a1fca9513e577806d4  release/kernels/fence.by_instr.json
cd768d40c99bd355bf5f20fced4bfe6e3b1b708a6ae62f887615fc9ba818e20f  release/kernels/fence.by_unit.json.gz
4bbbc9787ee5f29e98ad0c7908f70e6a6b6e4343c3e9b31c9a2bb7800310a3fc  release/kernels/fence.ccvtrace
88c21a2eb2e5635391fec362e89e8c55a40a0923c209187c9d965c37a06dfcb7  release/kernels/fence.log
d1d40317f6cf5bfb430cda1f9c0ef676609e59cabe2a11623c42ffbeca93142b  release/kernels/fence.oracle.jsonl
6e09e4d3c2897538f39b86af30f00a4608a8cb3cf47e7e936e67fe6e17b07559  release/kernels/fence.sv-hosted.log
a397a5b1a33fc57dc1b131c71c7a582350fa771e6dde839878a396c820f29191  release/kernels/gather.by_instr.json.gz
54ba3795795b28b549c404a73cd33768183c42f991cfa45083c1ee5517132dfe  release/kernels/gather.by_unit.json.gz
c5bd60bc143ef04b1753cc3f90ffa792a0973077cbbb702413053a2365fba7e9  release/kernels/gather.ccvtrace
c8b16e09277dee4f86473afa119a8373768a02f7b18416a82ba146b5772317d7  release/kernels/gather.log
0413e781d8d6ff578c64eb1f800b7931e66f676d5cdabb97b94a4033e6037662  release/kernels/gather.oracle.jsonl
c8f944f5c80f4476de3906091019533c27aca1c21fcf6852b963bb6e5339ae5e  release/kernels/gather.sv-hosted.log
0782a3bfcce5d97c692b154ce078b5141e260b867de12d3d0216b1624503389e  release/kernels/hit.by_instr.json.gz
826c6ad49aca10ef53bc1bcc227bd552fe090f3841878997a55c716329040f8c  release/kernels/hit.by_unit.json.gz
0dc38e18c8017b5df9c1e13f492952b8a32856a50ca7c93e09588648ac8ba525  release/kernels/hit.ccvtrace
c880d028e14d880e21e8afd0c70a56c2daa755438935883c24caa1ad9f88a547  release/kernels/hit.log
7ba9603e0088d9164de6528f16ef6a7fa9ce5821c8c12b52cbb3734e39b9fd52  release/kernels/hit.oracle.jsonl
4fe2918df77047f8369d21ae67260c8d68af73fc06edf3a63108fdaa66cabccd  release/kernels/hit.sv-hosted.log
a1f2b23159b88952481cebf2de6b514fcc48e5498d49970f7a413713eb917227  release/kernels/lanectx.by_instr.json.gz
feb0ffe8e44a4b51536888c0896e8cee9e1625e6559bc60ec9a9d2c97661cb56  release/kernels/lanectx.by_unit.json.gz
6f40f9ecca919305d45cc11467d071512e6eb9efc128c723c14440493b76aa88  release/kernels/lanectx.ccvtrace
b2e0b19bbd780f2502a350bdf554c942704b613c2ecdf4f6dfcdd9daec6c20e7  release/kernels/lanectx.log
888551babf540db8e3025b82e65ca655013f93eba3c8a65689d069d52a7e6039  release/kernels/lanectx.oracle.jsonl
8ff5abb7593a89c4421ea06dd5a3d745cd7c003d9606e81d621517ead771dd6f  release/kernels/lanectx.sv-hosted.log
27a300fbc6f6f502c7706b71f132e034871c6eabfe6eeafb0adbcf88a2b73d4c  release/kernels/lanectx2.by_instr.json.gz
7c21ae32e385cfd5f4336689331379a3bf4efcc37edd02b7eb8a5676ea776b04  release/kernels/lanectx2.by_unit.json.gz
b89c18d4e448ff832f7302ca5d5fbab66b09559f9da51bfd638adf0988de3b08  release/kernels/lanectx2.ccvtrace
558a67081a0b21beb7a92137709f5fc2bff9343271c2b49afa4a8bd1ee8e84e7  release/kernels/lanectx2.log
45c13056dff5c73ed0c9ece56cc36f929bf335322193c7d5eb38710b1d1dfb02  release/kernels/lanectx2.oracle.jsonl
05032ea6276d4b4aae1224ba45bdcbce1f51967d036d4db7b5294310faebc061  release/kernels/lanectx2.sv-hosted.log
de75a86a0ba524654270f1c07716ff9b3ad7f9de3088d9eab92299fa377082e4  release/kernels/late.by_instr.json.gz
938e339b356ff4177fcdab283d2916d0619f747d359ddb8d783d8998c07e434f  release/kernels/late.by_unit.json.gz
3150d1a14537818979a2f7f026d60cd6438ca3c55b9b0412d08e1e30f3fbd1a6  release/kernels/late.ccvtrace
19359fe033f4efe25314c53f1b2e70f99cb683be8910984c843bf88fddbf31cb  release/kernels/late.log
86084f6bd747a2cf32acbc0ebd96ebd3e4ef2d8d9e21be49e3ae49290d7927f3  release/kernels/late.oracle.jsonl
84c098289d0cac50892e3dfeb1addd4d6f62a72b69947257ca587a1e0ad4dbc9  release/kernels/late.sv-hosted.log
52dd352f44403e9a9e5dfd4305e5bfe56b761b5f9adc98ce889f3eb8dcb53fa3  release/kernels/ldpar.by_instr.json.gz
7423de99dbde22a850bb4151730a2219ef38e5938dd0014b9c22b90bfe50fbb1  release/kernels/ldpar.by_unit.json.gz
a2b5e71b0f55105c2e96369cfd9dfb104815f40746116d9d47271d86acdc8022  release/kernels/ldpar.ccvtrace
ecd89062f3a6257fd8b41e6a78e54d9645071390fa9685671fe437ca53f8b789  release/kernels/ldpar.log
8ac08538e9c807637babd61b31e340f7461878ada31f0c0b83cd66331cfaf486  release/kernels/ldpar.oracle.jsonl
516e5ef5f24967fc46ce5c155ce5d6ba3eb9fe5f75ba50e6238f8c7c1db216a4  release/kernels/ldpar.sv-hosted.log
9fdb4c081f2cea7b81e2087052755c0f615d318890b485ccb6b60fc857ac5477  release/kernels/lnorm1.by_instr.json.gz
aeb4d75734a1b7c34d29263a4cba66954e83fc695c017eacfcadbe8b8245de91  release/kernels/lnorm1.by_unit.json.gz
4623c4a7be69f0567875fd50203ac53ffe191dfa01e82e8b7ce919af93ca5490  release/kernels/lnorm1.ccvtrace
2f7114d70147b38db48201c61fac3c6ff0788e43b4527dd64175a59d55f46a09  release/kernels/lnorm1.log
a8d85811af988a1b9fc00db1517300af3d93ec8e589e403d3b9113fa9e0ffc86  release/kernels/lnorm1.oracle.jsonl
ce86fce3a43e535ecdc775492ecbf4662042fb307c12d196db1a1998b97d1edc  release/kernels/lnorm1.sv-hosted.log
e264a7e5de80f942074f93bcf52f4c4410e0e95fc344f1784542c236c741d8a9  release/kernels/localsp.by_instr.json.gz
72d01e718ca39d6d40aa0ae0ef63b450d120621ce7f02927c00ab6cdfc3c534b  release/kernels/localsp.by_unit.json.gz
04fd316f6ebb8d5f4656a1856afade1df3e44437c376c5981096b7efc62cc31a  release/kernels/localsp.ccvtrace
f76dd75d505846d8aeccc953bdf832af4be609cda414d210d2b09e799a575c75  release/kernels/localsp.log
55e3c9f36e7f7d38c0ddd38903aff4bb4509ae862015c592e6b937ea258042ca  release/kernels/localsp.oracle.jsonl
5b40eaacc8a1dbcaa947054b01ab154bd33080ac631ff65655b6e0f228d14fd2  release/kernels/localsp.sv-hosted.log
44e58ca542dfa6b5abf8296d5414721dc15549170d56dc0b64ab2834ab617e9e  release/kernels/loop.by_instr.json.gz
d85f55ff363f0829a37996a2327a5549279e1d362eb7aa83212aed31ef93476f  release/kernels/loop.by_unit.json.gz
8e6c9417e35af8bbae117adade5b9d2de71420fc35abe4aae7df581e61dd52a5  release/kernels/loop.ccvtrace
991459859dc0bb12ae773f70355826b5f2dc45bc9bfeaad74d342ff7b3f89e19  release/kernels/loop.log
03ce5920c06c93e93516d8e53c3f7169f14e3593de204eacceffc0b8a3e32016  release/kernels/loop.oracle.jsonl
f4c46d2db44184872967aea9d5ea46a9a6a133c2caffc418aff223f9f03e342b  release/kernels/loop.sv-hosted.log
201591a80ff4878738a43c19faa328ad1ecdfc517b043c69a6d8b84fd10e6e0f  release/kernels/merge.by_instr.json.gz
fbcabbadc572469cafac4cd4c0dd0eaf4c9254c1701b9963a61a399ccf84e557  release/kernels/merge.by_unit.json.gz
7c5c27b8590c634e6a6fa0ce6ebc8afed33e3101ca7690ecc2efe7cde41a32b3  release/kernels/merge.ccvtrace
ec3cba409f272d5ed927418edb8cf7d8b0861f1626e59291946a4ce59410a6a8  release/kernels/merge.log
f96d28815f8756b1f5a45ded53e6170883d2dfa10f9eef0d14b8050b1318164a  release/kernels/merge.oracle.jsonl
de7cd36dccbf0f5ed9a2d63a527f15ef9ff0e21a9a7966bf3a6269049fa82aa7  release/kernels/merge.sv-hosted.log
aa40ff0634df0d925f2db184c38ce4dfc6f9e604a0527eeebf12a003558d2565  release/kernels/missrun.by_instr.json.gz
a0875e3451892a3d9de17f6922a7ca3bbdd52f1038d3d8f1cbeecafde30af7af  release/kernels/missrun.by_unit.json.gz
d0717cfc4e7e14e0a0320cd8119b57998e3d090c3d2a71b04969bfb560b0feca  release/kernels/missrun.ccvtrace
a72b200335999b2ef81fc36aea9f418c4c33516c1e1c2402db2fea6745f130b8  release/kernels/missrun.log
531bdaf281e5590774bd2775427f25e4cc0419cf8e3d5b6999843ffe9ef87258  release/kernels/missrun.oracle.jsonl
94aa6dfda09768da55d91a99144d99fac3bdd7f2dcd72e966d46e691178b9a15  release/kernels/missrun.sv-hosted.log
5454d1dd633468c11cc4a61c88d3b853fd30d70921117d1f2623b871a6a94de8  release/kernels/mload.by_instr.json.gz
5f2345c5c7cd4a758fe9df6bf20683bde8f0790aadc9bbd6b71b5e3897973403  release/kernels/mload.by_unit.json.gz
577a3a3b4df199ff847ae882b5c5a50fcd83c74e63da8ba04754d5c6e1775f22  release/kernels/mload.ccvtrace
230a3748b06f757c4a444d28f553b684f43161e5a9d0ba6ca98aad2aaffb9094  release/kernels/mload.log
8000e477b9a95dfb9f0af964e8346acb9d36f1358fd06ffc4ff7cf599d2b8868  release/kernels/mload.oracle.jsonl
0a8c832f2499739e1254a92b748d5b964c5cf206e966a09305aa2d75eb4da9a1  release/kernels/mload.sv-hosted.log
74833f37672be3b66e865dac41e62cc95567a9d90092f030df6ffec59550ec7c  release/kernels/mlp.by_instr.json.gz
8059d780e0e8c08345bea9e404732770bc01cf213ee4e8eb6e0bec8532a32e3a  release/kernels/mlp.by_unit.json.gz
3e6e19508e5cec05b2b2e22e9e847b4f99c95bbfe76ba26fef100f54e2682075  release/kernels/mlp.ccvtrace
e00d35c28480c9720691609a43952852b12928d54b428d4b093692ad66c947d3  release/kernels/mlp.log
138d282f88d56c8ad648a91af0a983254b55d9fa22942c00d47b327f516a6e44  release/kernels/mlp.oracle.jsonl
166ae941f176a87a58ef4693b7c64991ed2947b2383613865cf9db74fdf163c3  release/kernels/mlp.sv-hosted.log
81a0983be805b32537e44354af88441203aefbd51039fecd38a280614bf71912  release/kernels/mwmiss.by_instr.json.gz
588a49d6862abdefeff2f423bf76da9ce2d6af288373a5ffc340ef9883c40ab8  release/kernels/mwmiss.by_unit.json.gz
a4a5e0dea6edc9552a29effd74f49f1ad3d2279d61d60a0680a50e5ec98ca3f1  release/kernels/mwmiss.ccvtrace
44e6a2669a13706796094d75a73c4b05098f3428152802b05d9a0394eeb72bea  release/kernels/mwmiss.log
8abe8e8997456a2a6711ee72da54d854b24e20abbdab28e4b7271c0d28418de8  release/kernels/mwmiss.oracle.jsonl
d75336123642659d27867a8ac18d4d8c0ff7b7fb1ddce6336a27b4ae5c007c1d  release/kernels/mwmiss.sv-hosted.log
fc8211520f5e4c0c3e00ba36e91957bcd6025480931e785fbe91c367ceeba661  release/kernels/narrowadd.by_instr.json.gz
c78b86d82fafc931757ed8621de4a18a4f809a6f07143b393a4c35394f5fd1a9  release/kernels/narrowadd.by_unit.json.gz
37d15e65cb02bccc001898996b6f8c4fbaaf3c7bf6f33f5629f7e1d886be38f0  release/kernels/narrowadd.ccvtrace
8f837b6aa003402aba3fefa0b74f1f4354af981cdb08c039e29e003be963b959  release/kernels/narrowadd.log
40a2cf629853dd404bb06b4a07e35abde3d12efc13f26ffe28f923daf2994574  release/kernels/narrowadd.oracle.jsonl
b520db0fd7e0ee997d9a705dfc36cef83abd9c4a7e3913cd5a338c886c0c7b75  release/kernels/narrowadd.sv-hosted.log
6763399187932d9a093bbdb30fea31dfbeab621b1279676b47ee287bf70a7b3b  release/kernels/pguard.by_instr.json.gz
e4172c4e2e38b28ae0b97e124db2010b4eeb124c58709fa6bcfb9c9a105a3f73  release/kernels/pguard.by_unit.json.gz
f4d640eb3c718814f8a0082210a5b32b641049e7be155f3aeb43314a46416b2d  release/kernels/pguard.ccvtrace
16be501ac903d7679477f7c3347756c377aae5a208980b7c92e8e9aebccb19bc  release/kernels/pguard.log
690e56f1cb8d97cbf67124b7dff3ad0a90cb8981814cd1709cf0cd0e035b3bd9  release/kernels/pguard.oracle.jsonl
efec14a4e171b7d5c317436449c7ee3bc6aa7206e7b9c08d937757c4a15535ee  release/kernels/pguard.sv-hosted.log
908dc2358c8566bb2dc1c74099674527ce4983fc3bff503db65e82e3932fea5c  release/kernels/plog.by_instr.json.gz
defe6fb3457bee8f8163d83f2fb33e6723283dd11513e59af4f47bc3b44ad5e7  release/kernels/plog.by_unit.json.gz
7823562f75147705b01f772471b6175774023d19935926703e158062b24cf94d  release/kernels/plog.ccvtrace
7f86f1b67fad70b3833768e450f935e8af30c54178e4e5aaa3b3afa76366f9b6  release/kernels/plog.log
0c99915e2da60f4670da00504a6371d7d17701d4431e733a3ff8fa98a2030d6a  release/kernels/plog.oracle.jsonl
ba9941655aec605601863b834c9d7f118c06bef51196e23914d2228d4814ff3f  release/kernels/plog.sv-hosted.log
0044dc4d7eedbf0352f1d36ec4a3529ff8e837a3aec5f3afc8d0b2d42fbcda2e  release/kernels/pmovdiv.by_instr.json.gz
30180d1b1da110eef5aa71179c34083654bb40fb7642960164f4cf29e0884286  release/kernels/pmovdiv.by_unit.json.gz
da1865544271c3c70d3eab1061f5060d833a856975f75b28d0921880ec954a97  release/kernels/pmovdiv.ccvtrace
de970cdfb6998133335dbe8cd3a4d00ff7f7bce979a2cc2718d069f013eb72d5  release/kernels/pmovdiv.log
7bc646cff6166a51bdce03d7c1b7209e871f0a91d743083a9b910a80bcd0b33f  release/kernels/pmovdiv.oracle.jsonl
2161deeb42e7959fc6e7bf6b6f8e3884ccfefc7a6ae38eed5bb2e13342c4ffb0  release/kernels/pmovdiv.sv-hosted.log
59a035b7458be6ac70f8e395144075b3a7afe695483405345c82c1a92a1edc2a  release/kernels/predlane.by_instr.json.gz
4ac2f99040fe70e2baf8f59dd26ec461efbe6fffa994652300e454351da2510d  release/kernels/predlane.by_unit.json.gz
92b2b1101f673248f8b28d88093d2a180c8d0f30d92fbd57a2fbdbf50e68708e  release/kernels/predlane.ccvtrace
c74e089706eeb8a57a666afb7058ad7c6c48181f2b212eb42440261e2d06e5b7  release/kernels/predlane.log
c45f4177b9e84fc8a6e36b13534a0c7636eb30a3f8531847100ce5e23bf404b1  release/kernels/predlane.oracle.jsonl
4c860bee0279c8a15f12bf5d5d5bbbbc4b0344a79ad267efac93f23f5af95acd  release/kernels/predlane.sv-hosted.log
ce9909c7c2f300f29bd75d4873e7387fa72ba350452e203332e9909df4e47a73  release/kernels/predmerge.by_instr.json.gz
7ed23a00ff03a20b816bce71cc89cc2a19560e5ec85df2b54acc42c929f92a03  release/kernels/predmerge.by_unit.json.gz
bb3488ce2d30e744c014d06bb81053f2bc8f09237e4066530c9459a0da2002af  release/kernels/predmerge.ccvtrace
e7db48605a473475f56fdf0a3a2c1f4d31aabc1a89b2a624ef9b96e4601aff8c  release/kernels/predmerge.log
6c737c49434bcd08e3e0814c8b1dbf15c586ae74f7929ba3148ddcee2c62c845  release/kernels/predmerge.oracle.jsonl
b473a0a07d0beb9008945bab3bdb4386e19b8d380a9ac322cb879b1ff636727c  release/kernels/predmerge.sv-hosted.log
9375ccaf527610a4bade49e4a2cc784712d3553548509672eda75bbc81defbb7  release/kernels/predspill.by_instr.json.gz
15752cc0cd6faa58ea013538efb719cd4719716a355980fa0e02fd7acb272b45  release/kernels/predspill.by_unit.json.gz
bd36b4bae813afe5b9524ef4c5e637d94c88c266a7d87c83da36c64de27ab139  release/kernels/predspill.ccvtrace
b00d09c57a5b0bf24f1e9139e6f23596f9546c7e4e81c78bb78acee378576403  release/kernels/predspill.log
b7c84c6478117ffa0f06da0e6ad1e4628e2683426a7911080810e78e06a5242e  release/kernels/predspill.oracle.jsonl
7084777718990257e20109feef6498c30925b749b6e69748fd4e14a26bb4faf6  release/kernels/predspill.sv-hosted.log
9662094b2f29880a12c1e6e58577fd1ecb320ce3703f33245e532d69e3893679  release/kernels/predswap.by_instr.json.gz
4a79acfa66de6d601f53dd70b6d287dc1c0820eded1f319944bfee82d44ef1aa  release/kernels/predswap.by_unit.json.gz
1b895deff4b6c3b0086288d4122e89896df7658dddd19c63f5de3cf16964591d  release/kernels/predswap.ccvtrace
63dc6b28e28d408f434c57f86999a83c1a9593b9e99a0e4debff415f36bfbf8e  release/kernels/predswap.log
a6d4f7ed517553816d889c7c9eeb6bcfd1f6c973fbf682ecb69f3c2de619f7bb  release/kernels/predswap.oracle.jsonl
748dbe10e8268ec1545913ce675bc73225e40e0796e275c1f914637fbb35a5ac  release/kernels/predswap.sv-hosted.log
b78c090128df9549251ac724fc749fde20f285fede8678f79184f8ee3a6144a2  release/kernels/privwin.by_instr.json.gz
d2e6dff45a2dc0a5b2f3cf093b0abe2d13260b0caa334cf4479c6b2426e7aeab  release/kernels/privwin.by_unit.json.gz
2339e4f77834724f7ca0b9a0d955b1c914624b8490b494ffd185c449c385e7d0  release/kernels/privwin.ccvtrace
a6fae42b0c1e6b8f6fbde62cee2ac2e45bf5c6b6d1a975b2c6bcce8041cd6afc  release/kernels/privwin.log
861f686fc4480363472908d679d8815e8c957d768e7ab32c826930527b0fb7a8  release/kernels/privwin.oracle.jsonl
d196bc4830a53ff1c501a660363e2fbbec546c95fb300de99bf5d0e67b5e3a11  release/kernels/privwin.sv-hosted.log
d1a30ec24b2b9bdf1ef092f8f120cc6685cda6abbc9e3176a3e8f9ca925d77d7  release/kernels/provswap.by_instr.json.gz
cb3a2849c9dd2c66a654c990992566b4c61f3fe5b94883d414ca22413d26f15c  release/kernels/provswap.by_unit.json.gz
ea8187c2e44a1decff2e82aae937af023c4cac05b4db555900b7ecc9b6d7c54f  release/kernels/provswap.ccvtrace
f8396d7f1a7b362e5af13b620559bd72efc126df04729fd129621b1de388f92e  release/kernels/provswap.log
c9c32a793d54cc7401477f582487f7e8b345b2669a75337b8d6327120d98e5dc  release/kernels/provswap.oracle.jsonl
51351a6ffb452f78dc55e9a91cbea897290acf17283b0cc100d55b1e79bf2c58  release/kernels/provswap.sv-hosted.log
c577f0e2772a904b55bc926b4941d36651fd5879a72d9f557feec899a8033e6a  release/kernels/retmiss.by_instr.json.gz
abf1d2de7ab90a6c6d0686f39c78bae7c98185598aaa64e0cb4a98725770f6ff  release/kernels/retmiss.by_unit.json.gz
6f094a4f42860ec13c8ed55dea19af83f02ec10f90dd9c8821ddc2541fb1a78f  release/kernels/retmiss.ccvtrace
1067c4e8406af3143458d533edd4721ee69696863d8da7368d314cf981c0fb1e  release/kernels/retmiss.log
e5ef8538e838c6cff7febfc679dd091cf5e002f82d34f1009b1948ce22bc3649  release/kernels/retmiss.oracle.jsonl
e399cae600598f91d78751db712b7a22fc3bc6015d581b4d6ea8d5a860ced577  release/kernels/retmiss.sv-hosted.log
b8af37455b33a1b36ab55a477d4761f76bdf9dd3edd8eab5fb7f2c3731ac8ec5  release/kernels/roconst.by_instr.json
1bd6e3d57918f6dc12f88a90fbad3431d9d6ab8123f8959ed02ca7c9430da7dc  release/kernels/roconst.by_unit.json
55981e07a1a8d3ed8b7a9f6797e5f718e3161cc5f6e1218171db77f9b6115f18  release/kernels/roconst.ccvtrace
51eb240ea49eabfd65159276025a4889a3b520572e4044725f402363e2bffba4  release/kernels/roconst.log
8087c0671de620162881aecd38cd6114b78e7be6bd71201e3ec02c9a2e2e750e  release/kernels/roconst.oracle.jsonl
3fe04c7b245313621ab0caf410bec7da5bc399fb0e6a07617d11d81276d17f05  release/kernels/roconst.sv-hosted.log
10c797fb8d044649f6d3dee9c07281c225794258b33e21124d781108ba92c747  release/kernels/rogated.by_instr.json
fd42a088eaccd364eaa32838664361b98e7ae54bcff0980bf323cfc7fa3898c4  release/kernels/rogated.by_unit.json.gz
efce29ea7c5e82d9ca9f5522549f4958218e9ae67a9114f6c26c60f34501ba52  release/kernels/rogated.ccvtrace
e1f1e9513f853a2d7d916e0262aa0b8bc43f1163ae1c780ff140ef2deedc0ba4  release/kernels/rogated.log
7cd02bd4cceec5a044d6b4d6a80df1e68ed0ae71b0b2a953143636d5b809ea6c  release/kernels/rogated.oracle.jsonl
fa36f233a15c359fc6280745cbc49247d1543b0a29239f951d771874b9fd3cb1  release/kernels/rogated.sv-hosted.log
41ab5a9b69cc9dae05ae43cdaa34d9512ee21ebbdebf9c982b57e0be2b59d447  release/kernels/rokill.by_instr.json.gz
1e8197fe804a8360bace7a6f47bec5e3b2d68ed1e0eec77cf4d94e5ae17cd345  release/kernels/rokill.by_unit.json.gz
8a540e1a67dce0d3845964ab547fce4b1c674a042f6be8c8d8c8b7dd46f4663e  release/kernels/rokill.ccvtrace
681db22c8f6b460aa7e5a4a38fd988f902211ec5334e546f47eb29dfca18ee85  release/kernels/rokill.log
94efcef96af469a512d346ce61623980fe86383188eaebd55120f716db596f14  release/kernels/rokill.oracle.jsonl
e0bea6e3d25d292197e57e6b64a7cb3f8e8decc8a6d12c14b48c3504cd2ba527  release/kernels/rokill.sv-hosted.log
d780697fc4b32619da011ecbf282f69bcebffab759b18b835ec13ac2c4ef0373  release/kernels/rokilllane.by_instr.json.gz
2249d219c3c93294788ba00c30a19d3b7d4aee2beb11844bcacc7d968afe2f28  release/kernels/rokilllane.by_unit.json.gz
c54a973f624a7ad5b95499138a725ad2287a564534121f4f568394896b3522b8  release/kernels/rokilllane.ccvtrace
d4115c9e6f47ed4495ec0be6ad7e6f448d233bfa16b74f647c803039bcab404d  release/kernels/rokilllane.log
f5ca6e666eff2f44894df74a291b43b3c0e7be0a63a47d795fdefd7b22016f45  release/kernels/rokilllane.oracle.jsonl
b83ccfb3edbb6dd001f63c1ec6d4b6e1456f7ee43d1fea79f459e5570ea9aead  release/kernels/rokilllane.sv-hosted.log
6018676757a05a45231fba12ff6df60d07f415338c1d836cc09d99465b73577e  release/kernels/rolaunch.by_instr.json
8512780fe1bbc0571a43ff91654c0ffdb7545b9c1ac040c907e50a29bfbd10d3  release/kernels/rolaunch.by_unit.json
289a78e36e414127402cf1c2f9514ddf7965e2988e5c5c2c172bf77c872262d4  release/kernels/rolaunch.ccvtrace
b68a88c7bc3290311ea470296fa8f1bf78d919a07b2308ad6b49017db06e765d  release/kernels/rolaunch.log
e7dad585c3e70615de04330fd03f4f282c29a005dc1732a35655fb261d51139e  release/kernels/rolaunch.oracle.jsonl
86a7ab5df50542a6303e08b877b76d5921e302a4b7f6f347245fad431a7e489c  release/kernels/rolaunch.sv-hosted.log
b8af37455b33a1b36ab55a477d4761f76bdf9dd3edd8eab5fb7f2c3731ac8ec5  release/kernels/rolimit.by_instr.json
0e20aabf7e39b687a2ade0f80fd977c9d7bd313c2cebdac11d43f35296e7d911  release/kernels/rolimit.by_unit.json
6105e32f751a15c0875d0d2a30a1e054656c0475286b5e2739728e13fa4d3e83  release/kernels/rolimit.ccvtrace
013ae6b2db8a6099b9b284ac76d7e3b28e518e36df3a739fbe845198b433a9da  release/kernels/rolimit.log
1c5bc0cb8e8b2e69505fb5a551a16d5d10c56f232b88da7a27e336ad7d962de2  release/kernels/rolimit.oracle.jsonl
ca7939435e0d2e0e6d84abab24892b067e9d155942c94dc50eb0315ac44e8570  release/kernels/rolimit.sv-hosted.log
557f9dbc8775955b7fa3e6eefd0b3305910917e278bcacdba9881a48aab1dcc1  release/kernels/roload.by_instr.json.gz
0a6f44c8ab448debf3ea1ab083616defe34d92fe916724d128fa0d786daf2cc2  release/kernels/roload.by_unit.json.gz
554fe7b6e3b718a63b278da46b9e3604fa927d3d8c9ffefa5bbfeb7a4dc44b1d  release/kernels/roload.ccvtrace
c68396b88b3e97ba9a5ba9bacb1e12fa072b0cd0a7475d6f66b3f4a4fc524702  release/kernels/roload.log
f7c1309cc9764769fb5803f6fd0f2f5e1eb418f2d23fbe5e17cf5f9106869fdf  release/kernels/roload.oracle.jsonl
b59ca4cca49e9fa6f7d5dba21998068ac070f60a83037323d71636a3d8ccf367  release/kernels/roload.sv-hosted.log
1c1ebd662fb596b3347b0d948d77def6ab839a9b58610bec8a17a5f9e4dd5eaf  release/kernels/rope.by_instr.json.gz
f258e924c76443a1d3abda79533e9ac2485756941d4a50d87e5f30ea0eeb2856  release/kernels/rope.by_unit.json.gz
f6ad18f23cbb4f20646d227ccdfacf36a783264a77ec6b93da0c847ff2ec40cf  release/kernels/rope.ccvtrace
1c1cb753ed766d77c7014de5e3b45f86d98bc65d89ee3376fb96672bf8fffaf9  release/kernels/rope.log
d55f9efae392dc8877c102c01c0810e7654b666b6ede386328108164c6cf88f3  release/kernels/rope.oracle.jsonl
9667ab1d3d7c27e13939021ca13d339bd88acc04592d607dbe53adc01d9c17ad  release/kernels/rope.sv-hosted.log
f6f22959a17da2d37a2512543139089e7a91091b34c4861c7f7489e505eaacbd  release/kernels/ropediv.by_instr.json.gz
84f513d54b8793ba2842e7fbcea077636169ef31255f82f9e91736f5836ad653  release/kernels/ropediv.by_unit.json.gz
10270e50bee5a26190cc449f04d57fe36983c509a3d0bb7ac7691f51d85d29d7  release/kernels/ropediv.ccvtrace
9d894f121d147acd8703b09e36f5a9a5643548d002a4ec2bf4b7c6d52e4137fb  release/kernels/ropediv.log
10c0ec6ec18b7b44638c790033109198c079d07c1537bf193353ccedd00a920f  release/kernels/ropediv.oracle.jsonl
f8e18aac4b8e80ed6f00d8f78e9a7351530c314235d3c29f90d7d1bb23fa4e00  release/kernels/ropediv.sv-hosted.log
d4957cc01ef74032d62fa968a7f4e7a6b847cf35dde7b9a151f62aef0486beb0  release/kernels/sel.by_instr.json.gz
3472a44b7977e2d03419bb123e5053ab1afd5b0195e89df95a854bab772a5333  release/kernels/sel.by_unit.json.gz
b7e938279e58c029f621fbf246c3b68cf5aaa826d23ced0b0a274ede1db13213  release/kernels/sel.ccvtrace
e550d5a9f343bd2d264f8a0fb2e65a732758291a77ed6a7b56cf7d3d6da8c3a2  release/kernels/sel.log
87f6a81e8afa004c8039bf2f61c90176fcf29ab29bb17ac44aa016a5cc8438fe  release/kernels/sel.oracle.jsonl
3ae9573b12d3fa63ca9919c3ac8eff07d8f8ba63da0221ccb9ccfb80bca72e1f  release/kernels/sel.sv-hosted.log
4746921f51c2965a90bc7696107a3209b7b1008d3ba42bf7e00b113aa318d6bc  release/kernels/sized.by_instr.json.gz
cef7649244bda69a6461d9576a2872b731279b193ad58e922e24bbbea6ab929f  release/kernels/sized.by_unit.json.gz
a9843b2c4b46306b93b260315a2e25662fe5ac93fba6fa497b21ab3c58384183  release/kernels/sized.ccvtrace
8c3fb30e7ffd88f2cd3842194af4d22290c106b416ddc958047c62836c290629  release/kernels/sized.log
36d903ba1618bd1faa437c9812a6ee6c0c966a63196c796267d74bf2695ebc3d  release/kernels/sized.oracle.jsonl
ab7bdffa1c76f54e9e18c436896b4e90b69e728b46ad7f03687d0afefe74946b  release/kernels/sized.sv-hosted.log
e56896693dd776a48a04dfdac5f9e9385250494b15cee6d1c178649e2cecd2c2  release/kernels/slotform.by_instr.json.gz
d860d19fae388bae440e7ee73a1cb36edf038338a24ae30678d913f922051df9  release/kernels/slotform.by_unit.json.gz
49d5e947563620dcb299762eb88ade65677dd870ace74045f1b273538b7454c4  release/kernels/slotform.ccvtrace
379850468b0c46841b201b27929d797c503b5b29035331337e050186a4dd2da4  release/kernels/slotform.log
8b61db7419b18cea8a646fb628218447e72e84a18a9891ffb73b441736138ab9  release/kernels/slotform.oracle.jsonl
bee862f740ee993d5a3aa0dece14ef797042553a491519b76c77ab9d5b73e1ce  release/kernels/slotform.sv-hosted.log
aae57d4e70302b738210b94c28db082660494e515235ea6b6c1d8066f179380e  release/kernels/spinwait.by_instr.json.gz
b908ea61393f9b08fbe471a710108c17deb9bd5e72165d1a973679f84ad5f48c  release/kernels/spinwait.by_unit.json.gz
25d95e4507c45c2c4ab004660dde0c9b71c5459ff3d1e80dab0c1cdf325b7c7a  release/kernels/spinwait.ccvtrace
60fc3d545367b06d72954de059a4b515769084d1d4ad26ae9ad81b72e081e882  release/kernels/spinwait.log
868920637236c878b33779bd450439466fc3626996a3164573dc11d437d5c709  release/kernels/spinwait.oracle.jsonl
6d89746cb4fd8159cabe1e1dd409fb2498a985bd9add183ec5895a060af61367  release/kernels/spinwait.sv-hosted.log
569b74b302622f391f56125ae8db0a8bbb00d274de58ebd30b9980f5be33d519  release/kernels/spmbank.by_instr.json.gz
16ee336cea892ab58d14db8bc98f589eb4af7fc29486d0bdd7bd52b6d16bc35c  release/kernels/spmbank.by_unit.json.gz
0b63ddd199108d5d57dacf8da3b47f37f0c4b36c8ae2b2605a61415aba0d0ef1  release/kernels/spmbank.ccvtrace
e2a617b7b8b37313f1a75b1e106cc2e95403ae2a20fd5290288eb96fae5c1159  release/kernels/spmbank.log
3af490cc37d7a92dbe719b57de216b648536eb301ff9d13de9a39f50d150d725  release/kernels/spmbank.oracle.jsonl
509ef5438f774231869ae1fba97b20f16e8165530a4323c4ead5444acc5d24a9  release/kernels/spmbank.sv-hosted.log
e4845b843ed75e53945cdfcb81f889febb227c747ccac398a75200d7f6d205a1  release/kernels/srd.by_instr.json.gz
71dd57030db503b21209c52a6e0292ed82150129bb3f5ca03593905197451b16  release/kernels/srd.by_unit.json.gz
12ffc6ad91eddcde92d30ac0bc8db4c6cf9ae295413afaa6724b94542c6a18dd  release/kernels/srd.ccvtrace
e558da756e2e2c2f91ecc992c05837d615ac24204a205d3869a444db8684256a  release/kernels/srd.log
b08eb5e3673cac7eebb8b72af5ed3783c8e70a9e96592e76bf3722551bc79473  release/kernels/srd.oracle.jsonl
e1d5d872dc92a585acb301a2339ba9db4b85f4896fc4ce4140ffb590827134f6  release/kernels/srd.sv-hosted.log
7b2dbcc6664b60903f98507a5979db8ea6b9f8533d997cfc67526f7c909ad58f  release/kernels/stall.by_instr.json.gz
a4f83ea549a152ac2fe46f8c28f8f12260b8622f94c9d5e2000d9eb3b1cf025b  release/kernels/stall.by_unit.json.gz
23d7fe29679d4f66c856d1f3771699f36fc83063bc591f46dcf0b1bbd72faef5  release/kernels/stall.ccvtrace
c8b00018b97d3cc3a313f175756ffd3f99707382195a14f2cbb59619e9f59eb5  release/kernels/stall.log
500db2c482b07a0706583422cd68878301d0146c1f872ccc1f11bfdcf5c993ef  release/kernels/stall.oracle.jsonl
344ea3ee5ace8419114da1e693791af3a07f74355f166c4a8c69fd8f6d6e93a6  release/kernels/stall.sv-hosted.log
aec83d2565b4251f6f3788814ead8edad0ef26b49c64ea010af169a49f43f78c  release/kernels/swap.by_instr.json.gz
969255e09e48711fd9db000f70692bc57ebb198af47aa3f4e72618afdaf6616e  release/kernels/swap.by_unit.json.gz
73f0439a3c3728b551849a9dd1cc3ca4f6e7f7aab68ba4084ce43f4f711edff6  release/kernels/swap.ccvtrace
fa8823f0dc7e5720fd46a1ac97fbdf814a5ef7ce54c14e8b6de43d8d973a329c  release/kernels/swap.log
3658a26316c1ff7bc1744304a42f736e930fcde2865c8913e6cc67a22ce96667  release/kernels/swap.oracle.jsonl
99865657a5ee1f2d1218529367e1fe141159556074f9f7f36a4c68d200285a3c  release/kernels/swap.sv-hosted.log
a657d4cff1983afb8b48d98cf36cfb17451d75e35eeaf1efbe7284c1aaec8147  release/kernels/transp4.by_instr.json.gz
fcbfc497139a1d10677970263780c0a3f95a1c81111ef4495ebd1b78ffffba1c  release/kernels/transp4.by_unit.json.gz
93e614f4cfab174fd368a701d37df0ffac14cf302353169a720ab414e9ac2c16  release/kernels/transp4.ccvtrace
1397b1c8db77defd1a66b6e0a59b24541b2112982246fc3658211ed0acf19955  release/kernels/transp4.log
06396ace3ac19677fd39c700e408606e5bdbacb24997d663bbe8872e63dd74fc  release/kernels/transp4.oracle.jsonl
a3928b875ee596bff7cf1065a658a1efa3fdacd71c147acdfccddbbfdabd89dc  release/kernels/transp4.sv-hosted.log
8cc869b14c4e68694fa83c1dd4243fdce8aa524d6d727f25dba733d1a78c1ed2  release/kernels/unal.by_instr.json.gz
b105e0bcb085fe02611b3612e2f48547449e95ce61768771d460dbdafb8a153e  release/kernels/unal.by_unit.json.gz
52b05699065211ddb8b1c31f92005de7dc6eee7a77092aa25a03d8405c81c852  release/kernels/unal.ccvtrace
7ad8dc88eb7859f2733c4d10985683151caa67e01c7ec7410cd2008f3cf6a070  release/kernels/unal.log
c3d484bb160657a563df983d9a2532eac27f556636617960aa1e72183ac2b299  release/kernels/unal.oracle.jsonl
f19bd627b4d4e812e9e4d70a49a47e0aa053c358469b632bbd4e060102c4572c  release/kernels/unal.sv-hosted.log
f92dc5f201c8d4c7611b231493776293dfa476366790d6fb80f66d75dc978107  release/kernels/vadd.by_instr.json.gz
8b3094ff4ce6409b407217829ed299930a69e8d3fa4fccdc0fe3001417c91c13  release/kernels/vadd.by_unit.json.gz
4c225b6185d0ef923f0c26ccd6d22a7277ea8914d97d1e2a458467ad4812f40b  release/kernels/vadd.ccvtrace
c438a80862e533eb7970b9a8acafc6503931bb42f7978cefa4def6df842d9a48  release/kernels/vadd.log
0276b6d0611a4bbcdc004ab3987214aea138245bc7217504147331689a9c0880  release/kernels/vadd.oracle.jsonl
10897ce5c997a2378ad36bc18b3b654cfa3e797bc7ec9f4739d872a055654322  release/kernels/vadd.sv-hosted.log
24c94ebdacb8074a8a1bf8b180308a1c3dd8821be8f770aac8d32d66e5e30813  release/kernels/vadd4.by_instr.json.gz
940cfe2e3758e94e3d3a10d881be0b4f31dff2745fc3dcbbd57c39badd9ef3fc  release/kernels/vadd4.by_unit.json.gz
5dfa2ef9e17a34e3ebcd6851b1dfdd50fbe9981700aa8d4a493a13572ba48f9c  release/kernels/vadd4.ccvtrace
9cd17c674410f013c238b63d909e5dc72f33545a34825474c5e3fa2ac3f0bd51  release/kernels/vadd4.log
225aa18fc9f38aa9ad615aa11de254337d59fa705877553d873062c68366e0db  release/kernels/vadd4.oracle.jsonl
38030797328778735eb558e7e12323952cda7f2e1a90bea80da1fb76a3e519a0  release/kernels/vadd4.sv-hosted.log
5ad54fd498f57f801c4d5abd2e071b2ea1b22de01c43e7390a21b866c48b3c05  release/kernels/vaddslow.by_instr.json.gz
ee79c86087a053de9765ea0d65515ebf0fe11630b2efd56c58f229d3742af77b  release/kernels/vaddslow.by_unit.json.gz
25a16a9885807c4eb4ae66a1bde936ded34fef447aeca62f3277e0d4cd4766c7  release/kernels/vaddslow.ccvtrace
110402eee06c060027460ef05eae7a3d51d61a748f0bc48ec8019aa7dfe3a592  release/kernels/vaddslow.log
e9e6218e8b8450e9f9ff6b39d659c994a1e51c527a0c5bd10d18b5658ae0e344  release/kernels/vaddslow.oracle.jsonl
56a80a072af6355683c9d31ce5128289fd331acd4f282e1676fd9cfc5a15aa7b  release/kernels/vaddslow.sv-hosted.log
81d6f909d4afa1a884b091bd2f5a87a16aa4ad18d8ab44b61bcf5c78e7be440b  release/verify.log
fe1c1a586828f0fa7b9b7bb7e659648607ea83cfff7664dc3507dc413f8b11b1  release/wiring.txt
```
