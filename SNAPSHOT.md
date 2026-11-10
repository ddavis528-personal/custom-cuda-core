# Snapshot snapshot-2026-11-10-8dccb77

**A generated, read-only snapshot. Do not edit or merge it.** The source
is `sweep-1110` at `8dccb77d8369c531be5d0b3a699f2aa49c99816b`, and this branch is rebuilt from source by
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
| Source | `sweep-1110` @ `8dccb77d8369c531be5d0b3a699f2aa49c99816b` |
| Built | 2026-11-10 (UTC) |
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
| `gather` | `name=gather finished=1 cycles=266 from_fetch=235 retired=16 issue_groups=16 order=ok gpr_mismatch=0 pred_mismatch=0 mem_mismatch=0 check_failures=0 class_violations=0 overflows=0 credit_leaks=0 cor_late=0 channels_used=31/55 violations=0` |
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
| `slotform` | `name=slotform finished=1 cycles=4369 from_fetch=4338 retired=12 issue_groups=12 order=ok gpr_mismatch=0 pred_mismatch=0 mem_mismatch=0 check_failures=0 class_violations=0 overflows=0 credit_leaks=0 cor_late=0 channels_used=32/55 violations=0` |
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
c87d5ff24b0ebedc6acfdaff2c5d81685ecc9395474c67000dbf0f44553f4aa7  release/kernels/addrhigh.by_instr.json.gz
69979106eb36a1ed8db2805e0b7b1499f7dd3f2f27df9f1e8e3181ceaa3815aa  release/kernels/addrhigh.by_unit.json.gz
26024c086b98c667eb6ff4ab07d9bb2b407953b72a2433e8bb2a0d0f590cfc08  release/kernels/addrhigh.ccvtrace
27240e2037e268e0eb06b1d826d900fa924c27faf55adf36860aeb04bdc1cea0  release/kernels/addrhigh.log
569f2e22883fad5f0956c57ec734e6afbdd4b8a854e50277425172d6c0cbd766  release/kernels/addrhigh.oracle.jsonl
8e001e2ae228244a64d46158e2d879c2e3cf8ce6334a82449ae561e7f4257a7c  release/kernels/addrhigh.sv-hosted.log
c9699bdd745f08f65a2b611666d16b99a9232b78dfd4047c87adf2e373d85361  release/kernels/addrlimit.by_instr.json
300c1f4f04a25ce5cbf865a1665ee1fdced9355099dd4fe1a776970da3820ebe  release/kernels/addrlimit.by_unit.json
646dd11cf7744b4941083731a2cb0a8ce7b94cbdf53f708cf2adef6ad684a061  release/kernels/addrlimit.ccvtrace
9cf9efd6482b990e089b34bf8b39a7821f8f46d28f9c16a407bb8daf6339f60d  release/kernels/addrlimit.log
bc660b0b40359a2c5a2478cb0eb4950b73fd22db50ea76b80052bc195a1920f4  release/kernels/addrlimit.oracle.jsonl
d0f3d4b6d7c394ec59a2f690b0104202a6af9f33949de2a7a618533759a4a37c  release/kernels/addrlimit.sv-hosted.log
b879f56d333c5039bb7f282658f0ca09589d2fe56531c13b684dd0893a4c9163  release/kernels/addrneg.by_instr.json
fec1fb96615feb68f26d8db7ed553f19cef1691f96dfc97666b271b4cfcaaeb4  release/kernels/addrneg.by_unit.json
401cb1b720323c75cebe1be95fb7e9736f1a40d7f0d02a7651c85f92e387bb9f  release/kernels/addrneg.ccvtrace
1e13c092179509033a5cd30bff752dd977913c9cec73d53baf24c1ed303149c9  release/kernels/addrneg.log
16f5b0707ae44492a1efd67bb9dd38a7e79a7bbd354fa9207b9e7d150ff2f107  release/kernels/addrneg.oracle.jsonl
86e2676057bc7dffa53f9dd8bf00e1548100507f1efa808d4ac932718f1cd3f3  release/kernels/addrneg.sv-hosted.log
02bb3b104e364b684b3fcf9367ddde36dd339466431a8fc82f17ee6cdf336238  release/kernels/atom.by_instr.json.gz
c915e05acf657d701ac157f29077f94816a70dcb9575e0fd602540aa16d4828c  release/kernels/atom.by_unit.json.gz
1ad23250d393836aac4caa0748ad25772082b017a2700dc9d43196ddd46030fb  release/kernels/atom.ccvtrace
2bba398ae8c90e1b42560318118d1b69e92904b17fe91cdc57cfeaffcb0f6ee0  release/kernels/atom.log
504f5b6e9d25114dc35f2c70b21bb7b3f3c508c691de12dc0e87d12a74285361  release/kernels/atom.oracle.jsonl
166c7ee0dc6840074ffe9d8857c4cfad729525c63b613ec345eebc8a0246724b  release/kernels/atom.sv-hosted.log
6852bd18abea3a83efe4dcb4a39f185a8fd25497b172113ff2a62daae6731474  release/kernels/atomf.by_instr.json.gz
195813e69a4aaf73c52262e9b0250d51a0954e56a3f89d40080f755d6b866ed4  release/kernels/atomf.by_unit.json.gz
ead6946f45250c234003b3c3d18a61765b5136bb5ca9bce30fc4e1b68403f586  release/kernels/atomf.ccvtrace
977980468bb913164283628fa958797c01953312a70ecb48024fea550c7191a0  release/kernels/atomf.log
cfd1179edf4061a33ab2f75d7a6dec61decfe629000198189a7bfc2647b34238  release/kernels/atomf.oracle.jsonl
7976313b6d6d2d178c9ea1285096b27217522cfb5ba5c142329acfa96fcd4e7f  release/kernels/atomf.sv-hosted.log
cb78e473ffc266a671b9f6e831a1962fe76a9c74bf3850e9ff092ca4e7372420  release/kernels/borrow.by_instr.json.gz
e80be8e6df75ecf61c6ff39b683c5e20b5b2d912a5d3a106b6f5a06cfa42161d  release/kernels/borrow.by_unit.json.gz
8eee0c50216f1eef61b0098241e98cee6f7c406c05849d0c1a4a2be835a5cfa5  release/kernels/borrow.ccvtrace
4786fdc81633a7e164dbd794685e0d722bd11c6cc913ab97d20ceefe74c70f87  release/kernels/borrow.log
4c565e1ce0b3baee36e158694b32c8defb5cd662b2f9af75cb5d8c26cb1168ed  release/kernels/borrow.oracle.jsonl
87d960d127a2646fccd831cb3081a2ee67a9d121b20aefa3e12c6021bf9579ab  release/kernels/borrow.sv-hosted.log
ef4596f420397602919673066c452e1e49a6ca00d7cb85dcfb47642f6acb44b9  release/kernels/brs.by_instr.json.gz
41d76e4feebdb74ac67d5b17fb3f42fb5b340e774f2f1779bf7776bd2ac8aa7e  release/kernels/brs.by_unit.json.gz
88a57ff042363bd7048526f4c13a55eefd7eaa18be159b61f466819827d06d8a  release/kernels/brs.ccvtrace
a19bd76fb1181d09b31c61f7135684ff2af7747979e2a8760d8281eefcb55323  release/kernels/brs.log
e3c1cb3379580cf1aae44e8ddc8e846ef6fd661a573cfe0a8d4444b18a14dc56  release/kernels/brs.oracle.jsonl
769e1f00d054ec6facc52d1ddb741a0bf7c2ee711456e1ee107418bf7ec7fc0b  release/kernels/brs.sv-hosted.log
a5e8f09ee05bacd285d9c6dcccdb8832352fc612bcd43b7fad00e87762aa424c  release/kernels/byp.by_instr.json.gz
5e80484d0ee337c6a050d0a0247a8b0b58f5f9955b1be1599d328aaae34a39eb  release/kernels/byp.by_unit.json.gz
8a572315c9d52778bafa71f96e4423500137a20efb80bc35014ecfb631f91125  release/kernels/byp.ccvtrace
b8467b758102880af68fda8812b0ff4d28f5a0384fba734ed5dd2de4e8433771  release/kernels/byp.log
5a03dfa4f3603fef49f1e3639e74e34152ca3ca5ef8e41eb959f8323040fa2d5  release/kernels/byp.oracle.jsonl
3284813cd328ec9db43009ec6b1154128f36d041f0651d94453f83b01d4a1bab  release/kernels/byp.sv-hosted.log
123f9a404645da92f8aca935ad78794bcb1d0fe78f79599081428a098e93e5f1  release/kernels/callret.by_instr.json.gz
0cd262922af26b8a03cbf07ee3acdc4e03260d2e1dd31418755da1ef95f92c4f  release/kernels/callret.by_unit.json.gz
046e92fbd4ca386af15041fe2d714aa45c58fd1cbd6562b55c7f53d80fcd82b3  release/kernels/callret.ccvtrace
a9a9771e1f6004b107c82c5d53e813b95b0bb95146a88e0c7e50cc8d715a0a49  release/kernels/callret.log
9b1d1b50b527f732362f837250aa2f26dabf3e76e16a4794856ebd8f105635b8  release/kernels/callret.oracle.jsonl
174dffd7bbacf1c04f35c960d51905793880d885ac0e05ecae5cd308bbecea38  release/kernels/callret.sv-hosted.log
8c7d3c54eb9a66575db2b4b205cf7043e3eb79f652c98af1e61150967cea3053  release/kernels/cas.by_instr.json.gz
7bd07ede86ddbfdb78fcd620825be21676e3b950f2fd623631f661ea0ca2d55c  release/kernels/cas.by_unit.json.gz
2f8710781ba48bbf53e054ee39b2acd2423bf9f26797f034ed2cb18d10a58fe6  release/kernels/cas.ccvtrace
f9ed36c4ac7797a4635793f89c44910f7f2b63a9a3d491e6a03cee8459a5d051  release/kernels/cas.log
0ab31a9443336fe5d08e1a5fa5fcba3bc279b19022f7c5007908d39d8ef39536  release/kernels/cas.oracle.jsonl
d6f83f2a257d6bb23fa83bbb6774510d5dc985b854242b32165ac1b96f2f5f0a  release/kernels/cas.sv-hosted.log
4b71bd06b42be21c2aa3641b801e11dc40adcad2bc9d53179f1c55da20764995  release/kernels/chains.by_instr.json.gz
f85dd46554df2510c26133cb58b84d6f18ec240ac293cac88381ef931982822f  release/kernels/chains.by_unit.json.gz
6e0d095321f97cf86811fb152219d5b6a4e887fc54ad1f4fd5e559f32145cf64  release/kernels/chains.ccvtrace
17038086c82eede07c9b11c8984a145cc6c6151e5280902f9ade357e56901816  release/kernels/chains.log
26a4cc5c5524c7219d8706c2582c80357dea60be9d6ffdec99dac7d0365e2264  release/kernels/chains.oracle.jsonl
672bc393491f512b203991120aaa4ef27509f0bcbdb9fe81cd043f0d7489ce5c  release/kernels/chains.sv-hosted.log
422d9c0dc15408cfdf78396136e06d5188d28334c8322eec0088bac25d9a3413  release/kernels/coll.by_instr.json.gz
63084c72e779ca5800f635c20dd41003d5e03d0f058e1e9a2b1276e4778862ec  release/kernels/coll.by_unit.json.gz
3762b3824dc9a96c20d7dc82947e7bf8e6b1dd318f73c9bdeca10d8f86d9944d  release/kernels/coll.ccvtrace
0e6a0ad8c11fde3f73a7a9336deff59f1c647ac0a8c0c4f3664f642d2aade93b  release/kernels/coll.log
dd718d23c88df5dc7d92b055d8542865aa0e029118486af127312a8a578cfcbc  release/kernels/coll.oracle.jsonl
dfdc0ccfb7126d8242e3af4fc288221e07592992eaed7ee79e7499222e1f2245  release/kernels/coll.sv-hosted.log
7d4664031b62749239c5ab5a27366297458c4f8982858741a70d73f5c852dc40  release/kernels/div.by_instr.json.gz
f5660fd2d6f1573fb73fb095de1a011c9d9ce8b217ec397c7734e28f24bbc29a  release/kernels/div.by_unit.json.gz
afa661d89a3f00449cb5bda98fedabd73fae73279bf3192ce9eb9f55c9bb6ea1  release/kernels/div.ccvtrace
a4462adfc79ec3d45f8b1110d29ba7ec90563d91eaa481c4e653ace4e5b06acf  release/kernels/div.log
71a567b85cf85622631490187563de9a5661099c78a590adff4ed0a0c3d24c16  release/kernels/div.oracle.jsonl
ed95333c8c72108151afcd87788f40bb125aede42e330998bee60aae7d94c6d7  release/kernels/div.sv-hosted.log
063c2660d479dc2b70a388e0710fa0076b2a9f8ea26d81498a95ba604e1e3d88  release/kernels/divchw.by_instr.json.gz
1d78b44bac169944241e7f269531a92360738b67da125f1f9d650c0659dfbc98  release/kernels/divchw.by_unit.json.gz
9ce148460eb5a8d5b7a5a9e3515e0312f4506c687a04798281130666885620e4  release/kernels/divchw.ccvtrace
ec3288779cf35de1931359664969c8760225430b8998588f3fec4f283399689a  release/kernels/divchw.log
58a541797f7a2df0a1c7528ae6a3edec212db90c7d3eb20656806f38b5c10b3d  release/kernels/divchw.oracle.jsonl
72c7813e28161f9c4fb2bd135ea203448ca48822eace01b5cadc2e6007de7c5c  release/kernels/divchw.sv-hosted.log
7475e704f0afee29ee0633f8c12129b64af41cc95b8c6f3a626853cf1bb24169  release/kernels/divtail.by_instr.json.gz
ee061971e4d3cac4c4fe11dd29d13958f047517bed72c4e664bd899fcb7fde6d  release/kernels/divtail.by_unit.json.gz
423d1be0830b8eb1f8dcb237ab56f5a611e27b4c61b3b14452a4cc5bece0d65b  release/kernels/divtail.ccvtrace
efcbc091c0052371a944535e887d9d2eaf262e919351fb7cd64cd12abceab439  release/kernels/divtail.log
75f11a75c9b3b336e446140af4579f05b46c363a76b7aab3ec88154a07ba097d  release/kernels/divtail.oracle.jsonl
c4da4e3b7a77dbb535af304b18c26c802c50b50e8e8837c5a8c4729d083e28a8  release/kernels/divtail.sv-hosted.log
e435b28a27392603af600583c343036e9c9c4ded6c7b49589a11c093b9ede326  release/kernels/divtail2.by_instr.json.gz
8e1ba43689e7dc68e15265f9681b38c404beb0efb0766ccef0c1964711f534ba  release/kernels/divtail2.by_unit.json.gz
7318a5b63e5a0376137977677b7bfd8830283bfac1c9e4d2d3fbe8af9a4ee8ff  release/kernels/divtail2.ccvtrace
e79718018ddc531b9d42364bf06628a117dab83f08c2920bf4e7cec446b5720a  release/kernels/divtail2.log
b2db6b05eb6cf4a0a7677e31d0c6c2952d5cab49d353f0bb1883fe0b2a20ed14  release/kernels/divtail2.oracle.jsonl
bf5be1127965f999c05e671a542c6af9c9ffe086d1ad3f22f105d69293e6f2be  release/kernels/divtail2.sv-hosted.log
6b88b23d84714fd1ff7da47e6c5662c87e3e54b35a835d57d1d54d08b5f0df34  release/kernels/fence.by_instr.json
73bad6f70e858aaf3c713b3558711d6d0e9be9efe85d7965d897094c489a882c  release/kernels/fence.by_unit.json.gz
851b82839626dd37b6325743a29c7a07ad5deb97a52fc9f9278827cb0255b8a4  release/kernels/fence.ccvtrace
4fb3b513ac3706d718bee29502d215d5d252a9bfc51e742dc47431201dea0f46  release/kernels/fence.log
d1d40317f6cf5bfb430cda1f9c0ef676609e59cabe2a11623c42ffbeca93142b  release/kernels/fence.oracle.jsonl
11a33e979e16fc9f0967677f5c88693e6d2262674a4927e17989858cb14a3ad1  release/kernels/fence.sv-hosted.log
7b21fcef0841d101e688f5d30777ebc7d937a7243905d0ca0179c9b60c87948a  release/kernels/gather.by_instr.json.gz
588485d37ecc10ea7b14e3c556bab38d00940e18d9158b74fb3041ef75fe13c4  release/kernels/gather.by_unit.json.gz
bfbbdf573c0e26acfaca5b68c3a5c19bad1ba21717392d05966451f86a4822dc  release/kernels/gather.ccvtrace
4ea5fb8a6e8787c085a6eb5d3b1d91dab4e506417f461820f9d2c76bc7c05efa  release/kernels/gather.log
0413e781d8d6ff578c64eb1f800b7931e66f676d5cdabb97b94a4033e6037662  release/kernels/gather.oracle.jsonl
173b5a2d804302813d7fc7dbc2905395255d3608693d8de98ddd6e4f56243e3c  release/kernels/gather.sv-hosted.log
165bc199ffab70894283b6cb7bfc7de438eeea19842732edd9db882216ad9385  release/kernels/hit.by_instr.json.gz
f11654ece0d7d77a9960650ca8fd8e5a458fd2b2df0637973a245c6d93614c2b  release/kernels/hit.by_unit.json.gz
bc422f237fb22e88a2a634b3f14c87e3cf50c1ea1bbc09032578c55dbcf7068f  release/kernels/hit.ccvtrace
4d2023614dc4afb7fe24088c5e6b47191985a47b92d1c5604aaa5d6a5c1307f0  release/kernels/hit.log
7ba9603e0088d9164de6528f16ef6a7fa9ce5821c8c12b52cbb3734e39b9fd52  release/kernels/hit.oracle.jsonl
8ad68015cbc51a77cde2ab0cf3ebc4a432fbc7f2bd49a1788e6a8375b8aac3d0  release/kernels/hit.sv-hosted.log
4669a36fa133d3ab619585f178133826489714bd57ee5632438a23a578af29be  release/kernels/lanectx.by_instr.json.gz
1100c4ba609b6af6481ef06356f0e67dcd64cfd642971f82d2c2e81fd2e30cb3  release/kernels/lanectx.by_unit.json.gz
d5b66b1134115801e4e2af05622d5b6575d1aa782fd32acab13e61775f0ace4a  release/kernels/lanectx.ccvtrace
17303dfed26ab81c0d23a0ff6c0b705da05bb945b8b9a6da5f596f859bfe75db  release/kernels/lanectx.log
888551babf540db8e3025b82e65ca655013f93eba3c8a65689d069d52a7e6039  release/kernels/lanectx.oracle.jsonl
e8284a3d3d59a55f5939f62ec91465e5da535987eb25234c2d812170ec1dcd71  release/kernels/lanectx.sv-hosted.log
2b8055fdf0a633a613f3c20f87dab1632cd3615a3f1f3a927dcec8f627f47e69  release/kernels/lanectx2.by_instr.json.gz
92b488fc992bf9f2fc96852aaa554fbb036b60df64b1b9e017aeaddf1fc8e8d9  release/kernels/lanectx2.by_unit.json.gz
5ee1b7149af6046c44f881e22661045fc31433c819b136451b42ca921a0092da  release/kernels/lanectx2.ccvtrace
d95a004ae6acdbea5426d50f16a989bf99ccb1649efa633146852636840067c3  release/kernels/lanectx2.log
45c13056dff5c73ed0c9ece56cc36f929bf335322193c7d5eb38710b1d1dfb02  release/kernels/lanectx2.oracle.jsonl
d44557a453841a46b462415ca91a866bcd98a6bf6f710f1afd57b900e97499e0  release/kernels/lanectx2.sv-hosted.log
3906c35fced97b406533e59586bfcf6aa7947e5809bb2b330924b2e344d5e7ee  release/kernels/late.by_instr.json.gz
108a4780800eb06e06ff273a378a00ac9133349039dcd5de6e48d3c9e1a96bc1  release/kernels/late.by_unit.json.gz
a75891694f84bb5e60092f6767802e9651fcb425a2cfb438dd5bacac07980a16  release/kernels/late.ccvtrace
1a1bcf07749573fe53943ff499b7d89c2cea909e9f08760c8f28079ee89fdf8e  release/kernels/late.log
86084f6bd747a2cf32acbc0ebd96ebd3e4ef2d8d9e21be49e3ae49290d7927f3  release/kernels/late.oracle.jsonl
ac7fa0b78174f339d149aae4ab8c985d177c02c8560f564dc5539010aac12284  release/kernels/late.sv-hosted.log
4084f8c87a9e8203d8a86531cc5ea767f7d3dacccf3ed248a04f851d3d0114e3  release/kernels/ldpar.by_instr.json.gz
058fea4f74b27533ca1f006579e2c597f6411e9d3670fed987a726a410aa3055  release/kernels/ldpar.by_unit.json.gz
7e40f4ed8e582ab74173079682342cb738d83d39a97c7ca4ca1beac0d97e1497  release/kernels/ldpar.ccvtrace
05abd79fe8e3c055712ee8af3438b645e63c18a60f3b23d6f729c23599cb8ef3  release/kernels/ldpar.log
8ac08538e9c807637babd61b31e340f7461878ada31f0c0b83cd66331cfaf486  release/kernels/ldpar.oracle.jsonl
ef5c8b784779566aa016868bdea370be5351b2406df9d15caa2271c87e262f4d  release/kernels/ldpar.sv-hosted.log
9d3af6ec8ff466060cdb16d7eb7c89e6a7121b768632ca76d742c0722bc6881c  release/kernels/lnorm1.by_instr.json.gz
cc9a2128ba0e7b9cbde1fb270ed59632c209240d0c06e9a1ac16fcc388db2915  release/kernels/lnorm1.by_unit.json.gz
477c69e023134c5db665626ddd1f77d9b4c7cf909003a7baa04cdf473c12df5e  release/kernels/lnorm1.ccvtrace
0ba51447e579ab5edf752c2a1092e7f9df4324c6ab72379065f9ce3eb4a3fa73  release/kernels/lnorm1.log
a8d85811af988a1b9fc00db1517300af3d93ec8e589e403d3b9113fa9e0ffc86  release/kernels/lnorm1.oracle.jsonl
7151ba01d30807c237c931174c6f452dbcd7ceb37d017472ae8195ddc6aab35e  release/kernels/lnorm1.sv-hosted.log
796dc39f4da82a4acd2569179811c8973b1004aa74680ef41766ed164ad7091c  release/kernels/localsp.by_instr.json.gz
d4307768000811aea72831b9194d5847267fdc531219baa379c069c5149aeea4  release/kernels/localsp.by_unit.json.gz
7548335b65034560aee57a2368fcb8c86eac66d19ff8ca69fc0794ace801d21f  release/kernels/localsp.ccvtrace
145d81b566740c3c48acc4ea417a5518b0a1a2d2e91771f1c7ec8704bdf8afa3  release/kernels/localsp.log
55e3c9f36e7f7d38c0ddd38903aff4bb4509ae862015c592e6b937ea258042ca  release/kernels/localsp.oracle.jsonl
ba4477e3eba5a02de6dc49eda40dc40fd9c09c3f6bb87e2bcd6fddd30c6dd278  release/kernels/localsp.sv-hosted.log
fc0c353c5d93d18c7d5635637e4477b121c36cd987dda469af6e635b59e0f108  release/kernels/loop.by_instr.json.gz
2f0f2b856966943ebec822337f8cf5e2cf76da7a9881b71102b5d417024a5aca  release/kernels/loop.by_unit.json.gz
72abd321dfbd0f37886b1bba86b88fd77245016c27b4d87e6a56043567e2c98d  release/kernels/loop.ccvtrace
95577315961e0d18064c954d82b7100f3a7dc26da98851d7725e0d4e2339200b  release/kernels/loop.log
03ce5920c06c93e93516d8e53c3f7169f14e3593de204eacceffc0b8a3e32016  release/kernels/loop.oracle.jsonl
4c4e40dde56a6113e1133b4814db129ff78ddec001e425be4922ad61fd4a4003  release/kernels/loop.sv-hosted.log
7180a6dd88a1916e7ee184eb963cc944fad5f5c5f43e512762e5989fb59cb28e  release/kernels/merge.by_instr.json.gz
a706961bb247c4cd023088e95b76b2abae3652a95dc21f5e49a60ee8124e7d2e  release/kernels/merge.by_unit.json.gz
a8d74967144ee4b4bd6ad87a20e05aac0925ba5f442e0f085929e688aed95403  release/kernels/merge.ccvtrace
0c4e8c75c740e2d3583b6a3b1ccdf9df16fd6d1a9ae859b2d93b269eb7124d12  release/kernels/merge.log
f96d28815f8756b1f5a45ded53e6170883d2dfa10f9eef0d14b8050b1318164a  release/kernels/merge.oracle.jsonl
df5fe284f006a49188edc67511d292231f01325344f4366da52ef50c230c5387  release/kernels/merge.sv-hosted.log
14e4ab6f71b3495cba487aef492ce87b9cf61bfa5fa08d1459eec66279a63c0e  release/kernels/missrun.by_instr.json.gz
c281b01f8d1fc6017115fc312383213f99afb6788fd991b6305d386f4768c88c  release/kernels/missrun.by_unit.json.gz
60a010274d29769ba20803a40bb136e7153e845726e9bb47d6bc0216fe4efb88  release/kernels/missrun.ccvtrace
b21f82b9228e087a7f62888d2b9999a9bbfd07c22e9c7d68743ff4bf90c4cb1a  release/kernels/missrun.log
531bdaf281e5590774bd2775427f25e4cc0419cf8e3d5b6999843ffe9ef87258  release/kernels/missrun.oracle.jsonl
5fb76d333e25f6e487dbe1834a790f17fb1ba7b15b608382337bd7ff102143dd  release/kernels/missrun.sv-hosted.log
db9f3c8cf8d97f64d208093c433032ae6e1eef1b9c6bff7f06b4967c265d1103  release/kernels/mload.by_instr.json.gz
ed632e27f7fb558d7ed0aee5cf5176b670a14eeec8f0e9c164ea10400410ac9b  release/kernels/mload.by_unit.json.gz
0fdf9d0866cdc67d5437adb8641b5705f50fc9b10a2b2aa7c9b7b89d863fe438  release/kernels/mload.ccvtrace
dc12e5fe4a8f4275055cdb173d4f205468f5c79c05fb0e2df3f8d185b3f86229  release/kernels/mload.log
8000e477b9a95dfb9f0af964e8346acb9d36f1358fd06ffc4ff7cf599d2b8868  release/kernels/mload.oracle.jsonl
0e38772d7a53e2abd2bc4adc576265338f344d4559f570705e3e0bb9773d96f4  release/kernels/mload.sv-hosted.log
5c24bf282dd75bb8206d39ad30847aaea82d4a0038494021ccded23e7f9a5cc6  release/kernels/mlp.by_instr.json.gz
1e32bc3d091a59aa3c9d2cb577b437960f10c54a486823a97963d9c3166a4761  release/kernels/mlp.by_unit.json.gz
fa560bf9bd386288984616514f3301db3de5626bb78cd85975c4379dfcaa7d6c  release/kernels/mlp.ccvtrace
663e5791fa4a2595c8c2d4dbd78a97c15bdc59d9aa4963acfac6e10ba521927e  release/kernels/mlp.log
138d282f88d56c8ad648a91af0a983254b55d9fa22942c00d47b327f516a6e44  release/kernels/mlp.oracle.jsonl
984d09b8bff32c82fcff4232b920f46c47524bb57a43e1214a11efae3d5c9742  release/kernels/mlp.sv-hosted.log
022e6a94f36dc32e1b8cfd98dfb677870a7fdab4f5d2e3be2104eb3ae6d9d734  release/kernels/mwmiss.by_instr.json.gz
58b3ab898652ee74071ab9a6f191e52dd6836870996760360a91705bada82aa3  release/kernels/mwmiss.by_unit.json.gz
72968f2e3116db34104c799396a03347daf62f241e626f6a1ee89cc493f433e9  release/kernels/mwmiss.ccvtrace
4495e1483809dbd02df4a66cf83a33963ab3438062664aeda37fbc12fcabd5c7  release/kernels/mwmiss.log
8abe8e8997456a2a6711ee72da54d854b24e20abbdab28e4b7271c0d28418de8  release/kernels/mwmiss.oracle.jsonl
1940627a6e070cb6a318b8e0dea7849f09a3435a3551e35a0cf87c189104b562  release/kernels/mwmiss.sv-hosted.log
9f3c86147fd0b417681fcc5ec085b03cc31a85c00980cca5cb081837b3c7387d  release/kernels/narrowadd.by_instr.json.gz
c8da7f61894b2654af0f4f701d2cc66598c3a9cf60f467f6dad06b6ca4db9c6f  release/kernels/narrowadd.by_unit.json.gz
eaba990031d661ae76dd290f0f3c794a7955c1fac7ddfa5928186094b8abd950  release/kernels/narrowadd.ccvtrace
2184ff8b5c34a5079d953ec22a0261e335af6fbdbee6a454b89916ff5d62c021  release/kernels/narrowadd.log
40a2cf629853dd404bb06b4a07e35abde3d12efc13f26ffe28f923daf2994574  release/kernels/narrowadd.oracle.jsonl
3866edaed8c800e69b787254fba11236d82812eb2241b4defbf364d680c26593  release/kernels/narrowadd.sv-hosted.log
30bee7ae4a3996f55a8e90922e9963ace39cbc3e30d1188907e5e80fc8be5f94  release/kernels/pguard.by_instr.json.gz
a3ebc9ab6673759f8cc2d87f2a4f9fdbf2fd6fb5cee11bd23c7d7e5886f553cb  release/kernels/pguard.by_unit.json.gz
3b56006868b45f582561dccb435ba57ea8d800e4dcbebcac798bed592041dee0  release/kernels/pguard.ccvtrace
d78c48c368ed6b5d4cecb33d8b6bf4a849ddf729870a54f4f11e1932982af933  release/kernels/pguard.log
690e56f1cb8d97cbf67124b7dff3ad0a90cb8981814cd1709cf0cd0e035b3bd9  release/kernels/pguard.oracle.jsonl
2360f5959513b55b1e67ad196bd9c112ce32a2cb6b503ea26c5a4da6d1583545  release/kernels/pguard.sv-hosted.log
6e7912b826d2e5780d61cc64580120df9663f1b0fd3ecf1530e12caec171b34c  release/kernels/plog.by_instr.json.gz
b56252e9b2585022b04a4bbc455c08b2fdc32d33253f50de4512e04671426385  release/kernels/plog.by_unit.json.gz
0cc33f3066dd4ae74b2296e7d22a3ce494836416ce6f69536758b97df8e156bf  release/kernels/plog.ccvtrace
950e21ab65d30856daf26671cf6bf7ac47b78552e17e8c1aa5c47e83eabc7b94  release/kernels/plog.log
0c99915e2da60f4670da00504a6371d7d17701d4431e733a3ff8fa98a2030d6a  release/kernels/plog.oracle.jsonl
fec5948f48b8bf23ca465bec3fd6df9a2a4b68539abc4317865effaac19c5976  release/kernels/plog.sv-hosted.log
c861a7a40ddb5965b05123a36b354d8aca311879bb9dd729f891441d14f53519  release/kernels/pmovdiv.by_instr.json.gz
962db3412cdaad09a77b1e9352335ff258bd1cf37c2f78ba381569cfdb0889bd  release/kernels/pmovdiv.by_unit.json.gz
231a3dd81b74fa2103ab2345699f1f0e0f4e412e85827b5e835d5d1c952eb6ae  release/kernels/pmovdiv.ccvtrace
165329c19f2cd1b4682252353a170783f76de7b8ccd1edae6e2ba00ee80780db  release/kernels/pmovdiv.log
7bc646cff6166a51bdce03d7c1b7209e871f0a91d743083a9b910a80bcd0b33f  release/kernels/pmovdiv.oracle.jsonl
4dc013a037108d4ce9f2b20494add9eb64a5574c76e6e557131eaac3ae98d20f  release/kernels/pmovdiv.sv-hosted.log
133fc0b6db6df0b567f75745f6cc1d3ec43de97008a7d539c2b5bfc0f5bb3499  release/kernels/predlane.by_instr.json.gz
0c44cd3cd6bbc626ebde8f9e6b4042aa6de7dc864ca353bd09f40d5216dee87b  release/kernels/predlane.by_unit.json.gz
eb789d73b076373515f510599083b24f2501a0bd4e20bbd32f09b292b112c02d  release/kernels/predlane.ccvtrace
8c4a653f5294a203cf3b88e7da6b1eaa04ecd0faf3131afe7551db0e1d10289e  release/kernels/predlane.log
c45f4177b9e84fc8a6e36b13534a0c7636eb30a3f8531847100ce5e23bf404b1  release/kernels/predlane.oracle.jsonl
6714e2522f53a5d1551cb75df2a1f62b10544820a4b665b80a67507c6cff5027  release/kernels/predlane.sv-hosted.log
13e6b7d2865a2aae54c207dde94a2b929b622cdd42cd7fc3af379ae579310236  release/kernels/predmerge.by_instr.json.gz
241394b2192d1c554fc3383edef61fface92390c1addfc352b040c9c47cfc110  release/kernels/predmerge.by_unit.json.gz
992d9ed5bc1841229c645570617d50962aaf497fbb55d502a1af8aab6dc39499  release/kernels/predmerge.ccvtrace
8f067d385cf0afab6e862f2a895b3405188d7a4cca304332b86c5b7960e58982  release/kernels/predmerge.log
6c737c49434bcd08e3e0814c8b1dbf15c586ae74f7929ba3148ddcee2c62c845  release/kernels/predmerge.oracle.jsonl
1cede91ed32a1906c0646e9e96d6636832cd148e1e9d8090d744acdcbc949a96  release/kernels/predmerge.sv-hosted.log
a8fb6070f4b4ca2f2aa424692ad0c1c485030526da21287a6243036f914d6916  release/kernels/predspill.by_instr.json.gz
aa575873626399bb6e003570d7671e9021b209a7979744056bad4babb0de7047  release/kernels/predspill.by_unit.json.gz
92f4a10d221f22f74ceb7c73372973b49d10dfe6e1fdb646f84723de6004b45a  release/kernels/predspill.ccvtrace
e96494394e32dba75c3eb8f93ca5fb4743d861a8ef33c5ca4e96f4d2dfce016a  release/kernels/predspill.log
b7c84c6478117ffa0f06da0e6ad1e4628e2683426a7911080810e78e06a5242e  release/kernels/predspill.oracle.jsonl
7baf0bb0d534ecb2fb51e0c5886d369c5d1560fcf86d5bc2c5a0e51f3e23bbc5  release/kernels/predspill.sv-hosted.log
84e62d672da901c1f73241fd09610d46e5a06d8560be69ee12901d3717b0cfea  release/kernels/predswap.by_instr.json.gz
c93ad248da4717f8119bffdbb95c00993514347ad6ab392954e8fa21d66888da  release/kernels/predswap.by_unit.json.gz
f793d03da341396628fefdbbe49d9e5ed50de9cb68b64b7c74b5bf0fd183925e  release/kernels/predswap.ccvtrace
253ff10981635ad5684e9ef9818f3d383312e940e65cb6477edfc9002b9b5be5  release/kernels/predswap.log
a6d4f7ed517553816d889c7c9eeb6bcfd1f6c973fbf682ecb69f3c2de619f7bb  release/kernels/predswap.oracle.jsonl
3bd15b401508f8c5f9d2c0d547bd96c38edbd441951985b44a3ae624464904f2  release/kernels/predswap.sv-hosted.log
2f18fd0d3dd62642811b35105ce52424640bf6e67c698f79d1e5bc32798b204c  release/kernels/privwin.by_instr.json.gz
66a1bc97e75a17dbcddb3bcefbc0a612670053ae357b9273348eb691c8b2c515  release/kernels/privwin.by_unit.json.gz
325bce511eb4675b8e5bd663900b9a72dbd36c66caebd7a33c5d8ce939241e87  release/kernels/privwin.ccvtrace
c5df1f91d99233fca8df94ade4f20dda846e5658fb5fe8897f8a41d60e086b39  release/kernels/privwin.log
861f686fc4480363472908d679d8815e8c957d768e7ab32c826930527b0fb7a8  release/kernels/privwin.oracle.jsonl
124270a9fb11f7710712a08920834d25f38cbc206c5c298f7ff30271059783d7  release/kernels/privwin.sv-hosted.log
74a8172b8f8d9b07bb6ca2cd4ab3acde0d7b7f1cd370265ef650395a6d740372  release/kernels/provswap.by_instr.json.gz
3230d97fc8fe6a08b9e659a5726c10a6f439ed50a09b24961fe6935b003956af  release/kernels/provswap.by_unit.json.gz
0fec44b3b5cb0562290746e2d1014c88182c6a33b0dc84b07f704fbc7dc2aa46  release/kernels/provswap.ccvtrace
0ccca9556ddb76b513877830f163d0a225dc04ea17d3832eaffacc29e8ad73a1  release/kernels/provswap.log
c9c32a793d54cc7401477f582487f7e8b345b2669a75337b8d6327120d98e5dc  release/kernels/provswap.oracle.jsonl
e585ce0c31ab9efba6e0f441c8da281daeb3124c59b3f91da85a2b9e6cd9a67d  release/kernels/provswap.sv-hosted.log
46c3f2c0e4c0f45de92e724356c021f0a8a7da8e858af0820eb083614d1061eb  release/kernels/retmiss.by_instr.json.gz
8007fad37809aff29f1f99cef2e5ca85126b69cee2a8e1128a07b6456ede3897  release/kernels/retmiss.by_unit.json.gz
a94b952d7ddf4182c6bddd62106ee6e7d5afd002a8c763335f5d4120dacbb931  release/kernels/retmiss.ccvtrace
745020f73edb3b989781696be4734528346e677e484a36702ed84a5ca2bca571  release/kernels/retmiss.log
e5ef8538e838c6cff7febfc679dd091cf5e002f82d34f1009b1948ce22bc3649  release/kernels/retmiss.oracle.jsonl
6d8a41156cd8d5b83f4f1eee73d05910cd6ccf60b89a690ef13a53d53af761b3  release/kernels/retmiss.sv-hosted.log
c5ff1730f30873e277e5d962073b2f8a2ea8e82cbf83d046b24cb75b68797210  release/kernels/roconst.by_instr.json
aff2f6ba374c4b2edc0b4b13d953a14148d131286d30cc55dea555cb22b1b61e  release/kernels/roconst.by_unit.json
24e16ea5a89c0da7406ac67010ed1e91278e7e70007de5fd3c5e0e848c30ca5a  release/kernels/roconst.ccvtrace
494fc327cd7db4bbda75ead1a960b5cc2c6390a9eb632c53d924434c0ef4f183  release/kernels/roconst.log
8087c0671de620162881aecd38cd6114b78e7be6bd71201e3ec02c9a2e2e750e  release/kernels/roconst.oracle.jsonl
56579af552f6b5932154e4416ed8a9009080507b06585d1ee845cc5b6645a95b  release/kernels/roconst.sv-hosted.log
8a379537853667bb0ec4c1843eee518dc465010710d108f3e114d66d4c6cfb3e  release/kernels/rogated.by_instr.json
469d090cd66f6502269e67ef550e902fdf7526e750b62b8dbc3f799b51902f44  release/kernels/rogated.by_unit.json.gz
631b1ab4d97f56e9c4e84621330223c13a652a9ba99663e4543231ef82086049  release/kernels/rogated.ccvtrace
967b63b0779565534ed14849e12e764c85fa1d5d58327962314628713d519d91  release/kernels/rogated.log
7cd02bd4cceec5a044d6b4d6a80df1e68ed0ae71b0b2a953143636d5b809ea6c  release/kernels/rogated.oracle.jsonl
6d1a95fcc9b3f720f5e5557edb0c5c1b590ec11d72bc2b54abb58902e1ff9c5b  release/kernels/rogated.sv-hosted.log
8e03905ccb03545b0749ce81bf1b58c1b8d2060c70f7818427945859eafd14ba  release/kernels/rokill.by_instr.json.gz
3235bf6138a6c941bbb1d0384cd005e20346455d5913886194391108c1c33394  release/kernels/rokill.by_unit.json.gz
55f1d311748482da87a37d632ef2903bd8d8cbb08eaf1fa08128d9d4b4fc6657  release/kernels/rokill.ccvtrace
0a224446371827af3aa6e2a2ff7bc3015355c20c5b05026f0fe7d9491095620d  release/kernels/rokill.log
94efcef96af469a512d346ce61623980fe86383188eaebd55120f716db596f14  release/kernels/rokill.oracle.jsonl
67ab2b818e4dda339b61051df7ea2e35bb86505062af1041d6fa3bd043b5de43  release/kernels/rokill.sv-hosted.log
4ce3274ce40204c6adc0e06032de0b5f3a9af30d7eb9f93cd6a4341e23a1ba5c  release/kernels/rolaunch.by_instr.json
32a781755aabdaf1378a6e47b5d441c07dbeae5411b40e2456cddab84c3d9377  release/kernels/rolaunch.by_unit.json
c9423aa368141c32db86d8f3699fc646239c555b49d5d1a4c2e3e8b3042c37e1  release/kernels/rolaunch.ccvtrace
815a52d7fef6048024bb21899b0c6bfa2f645b3324c929f7e39485deda041c84  release/kernels/rolaunch.log
e7dad585c3e70615de04330fd03f4f282c29a005dc1732a35655fb261d51139e  release/kernels/rolaunch.oracle.jsonl
77f8c530442f2da48ebec3b30fe454fefdab59cbc020eb1fc698bf3c74e15495  release/kernels/rolaunch.sv-hosted.log
c5ff1730f30873e277e5d962073b2f8a2ea8e82cbf83d046b24cb75b68797210  release/kernels/rolimit.by_instr.json
43430520f2f8de48bd6a6b0c767269a2ca31c6f08350cf47cc0beb21e8cb2eed  release/kernels/rolimit.by_unit.json
da82ea8ac380b275123303019058883c223ccdb993176d9f14ffa9730f395f89  release/kernels/rolimit.ccvtrace
e0fe2aef239b29aa5c5a9beab75d32011361fe49e69b6efe59169eed5c4b061c  release/kernels/rolimit.log
1c5bc0cb8e8b2e69505fb5a551a16d5d10c56f232b88da7a27e336ad7d962de2  release/kernels/rolimit.oracle.jsonl
0fb553ede2cb04d17ef5ede39020ea0ecd0d29643895bcd84c9c0fca9f763b5e  release/kernels/rolimit.sv-hosted.log
570e71246801634f309f80198750d925fcf7e9bc3d63de8423206c0bdf73a037  release/kernels/roload.by_instr.json.gz
94495180464181796d290fc6c7be140f8bfcd03fe9bd1b94d66dafeb9e89ecd8  release/kernels/roload.by_unit.json.gz
9db58d0519c28e63306793107831abcac7824ecabeef0820a22e280b39799cd1  release/kernels/roload.ccvtrace
3e8adaeaab7710c41cc0cbee77cd72198bbc26b2d187bf70cbc2f17d635dfc25  release/kernels/roload.log
f7c1309cc9764769fb5803f6fd0f2f5e1eb418f2d23fbe5e17cf5f9106869fdf  release/kernels/roload.oracle.jsonl
36e9d05e1bc2376b84e48a2b5296ccb16d8882697ed2c392bb6e8129c9c8a17a  release/kernels/roload.sv-hosted.log
e45b7f79dd99d29859a3231484d4f3640b5e47a3632435f5ce0f52d3851af26d  release/kernels/rope.by_instr.json.gz
a2927279fbacc8e060870cd5d7ff48517870737929cfe2a17eadfa2e8c31aca4  release/kernels/rope.by_unit.json.gz
1a9e2f663f827ca30a249aa74cdf970c81348d8ed41c1a9499bc8573ec861b6a  release/kernels/rope.ccvtrace
bed846f2d8b5551840fdd0d9a83995feb63ea64b60a892f6a2bef1ffa41d0512  release/kernels/rope.log
d55f9efae392dc8877c102c01c0810e7654b666b6ede386328108164c6cf88f3  release/kernels/rope.oracle.jsonl
72eb025850a5e7afe535a234ca98c60763f5cb58da41b8b930f438f75034871d  release/kernels/rope.sv-hosted.log
6d459e3368542fca8a4b2f9f085115c8d30c28ac0d83963341714da677186936  release/kernels/ropediv.by_instr.json.gz
8fbdb2f6a04fb58b36352fa34339827863813fa20b351c0a46638e27e2e6d069  release/kernels/ropediv.by_unit.json.gz
e0f90b60cb5893cc5e9839a74708848bc8b5409e2af972fca5b128129a3c2614  release/kernels/ropediv.ccvtrace
b14725c2f548caa6cb4fdd5b44469f1a7b022967f180f528421f43036d91fcab  release/kernels/ropediv.log
10c0ec6ec18b7b44638c790033109198c079d07c1537bf193353ccedd00a920f  release/kernels/ropediv.oracle.jsonl
f9669cfb3406d325c4d151cd902b5946455cf2ba490939631fff4bcd9bbbaee5  release/kernels/ropediv.sv-hosted.log
9665194f5a48f4afc0696c248a164cc4efa7f3112d5f5f331e39c206e5598c26  release/kernels/sel.by_instr.json.gz
4af6a9afc30d3e73435284cb530c38bfe5ed15486b05c0a058ccf04e400db94c  release/kernels/sel.by_unit.json.gz
688c1614887034251601256381778a5d9009dc4bed01e11890a584f2cfaaf665  release/kernels/sel.ccvtrace
5020df1161245c5960188582d1d73b4580faaeb7bd6fe2e7900aaddf2d45d8df  release/kernels/sel.log
87f6a81e8afa004c8039bf2f61c90176fcf29ab29bb17ac44aa016a5cc8438fe  release/kernels/sel.oracle.jsonl
6d9ff7780190157b3ac909641f6f1155f66c3cf9336c1717d121801b3c2b7bcf  release/kernels/sel.sv-hosted.log
1ef10f61f5bd2078baef310d6eb371fb2e8548e25b777e9748f8b4dd082568c7  release/kernels/sized.by_instr.json.gz
1d6048480121d816ea8d42985e77f3a086cd96bd33415c027b7a485c98edc271  release/kernels/sized.by_unit.json.gz
1f80ee055c71f4da0b1411cd91f6b849d72a032b87e76f6d9b448fc37e51b495  release/kernels/sized.ccvtrace
63f95636d5d4c0425862898cffb0b89812d2105c0d6bec2db19f6b3468c7237b  release/kernels/sized.log
36d903ba1618bd1faa437c9812a6ee6c0c966a63196c796267d74bf2695ebc3d  release/kernels/sized.oracle.jsonl
37b1fe51b771dab01ef4656ceb45355f194730089f4edc08441dfb742fb3d541  release/kernels/sized.sv-hosted.log
afec87f42d5a5d33e941fb46317b8c7d3998080c4cdffb3aaefb7988ab6bda88  release/kernels/slotform.by_instr.json.gz
82353e048db73bd3ca14aae35e8869a282106845873bb884133268a94232c79f  release/kernels/slotform.by_unit.json.gz
f93d62ae47498b83f4d72cb6de0cd18792372a17deb2fc2de7e5244c075f1e89  release/kernels/slotform.ccvtrace
1f79c19db62bb0c0f9eef1d7e97e2eb1a5fe780391d71e42f62c56982c546a63  release/kernels/slotform.log
8b61db7419b18cea8a646fb628218447e72e84a18a9891ffb73b441736138ab9  release/kernels/slotform.oracle.jsonl
35bbb0af73474b7cc1b0d8b4c105b42cd9d4614d9c8c9151315f9a18c7b0c4aa  release/kernels/slotform.sv-hosted.log
23cabf1f7ab7ead5c67c885d65e26fcd200992f2a846ff709dd5240941cc961c  release/kernels/spinwait.by_instr.json.gz
28ecd48c68884c60f876dad26038f47ee0b68f91de7ca774baae405da0d05901  release/kernels/spinwait.by_unit.json.gz
3961613ec80a3fbc0f5a67f9ba71fd78ed20ed0c29180ab124e8ff6aa8e0e5ea  release/kernels/spinwait.ccvtrace
65130011661c53771d8073cd3c89a6bb63bb29883971f906c17fc2135184bdd1  release/kernels/spinwait.log
868920637236c878b33779bd450439466fc3626996a3164573dc11d437d5c709  release/kernels/spinwait.oracle.jsonl
a5f1a49b608a37ba33b194c002353cd48deb501577581c44b5a0861e607ce456  release/kernels/spinwait.sv-hosted.log
0757bb333b7fba67892fe29bee83427cc0930b45616a1ed49214e12fe2fec470  release/kernels/spmbank.by_instr.json.gz
b410428405bcec08ab75ec5efebf09a1efd4c4acb8445aa6e60286abc75344a9  release/kernels/spmbank.by_unit.json.gz
b41fbea616795bbf29c9e5a4fe7149db44bf3ded02d7a7358c49516a5bf360c1  release/kernels/spmbank.ccvtrace
4546faaf18deb38edf8b0645a03b1bfb927d2a82fec857f975035486fd49ee91  release/kernels/spmbank.log
3af490cc37d7a92dbe719b57de216b648536eb301ff9d13de9a39f50d150d725  release/kernels/spmbank.oracle.jsonl
cf6802ea5dfc30cc65cb5dad7b0c15ebac84875d3e44db79a817dbadfa123f78  release/kernels/spmbank.sv-hosted.log
b8d049bb3806f42238ec8838497a2cc8927ea20dd46a8d8d25404657bdd14263  release/kernels/srd.by_instr.json.gz
e5957c61e9c78edbdcc269a444cac74ff1650046c318217a306bfc17dce19b2a  release/kernels/srd.by_unit.json.gz
95badb026ccf14f957d3f0590ff6b6d3e65a1e3529a41b23e4826ee4473679f4  release/kernels/srd.ccvtrace
e4c2a3098a0a7ac41c6a3c9cf643e1b947dfbeaa12a8a55f779ec0165e9ff8b9  release/kernels/srd.log
b08eb5e3673cac7eebb8b72af5ed3783c8e70a9e96592e76bf3722551bc79473  release/kernels/srd.oracle.jsonl
7acea6b11f429e655d7921ddbef6c0c55c09760148f98e040ea9074049799ad7  release/kernels/srd.sv-hosted.log
9c8ca0dfa9c554275c4d19e044a8889bfd06976715696b52eace0b19c00804a5  release/kernels/stall.by_instr.json.gz
0658b983a18e8d0beec9bd5e542bc355e08820f9886a4c74d4c134eb3aacc1da  release/kernels/stall.by_unit.json.gz
34f78c0c08b929b8c250af4c5aa11d6fd5e810a7d837af1098d0e45a41aad0d1  release/kernels/stall.ccvtrace
51d1fc31172956fbbcfa61cac85819c6f71c4214bca5f7bda9358d14809295e1  release/kernels/stall.log
500db2c482b07a0706583422cd68878301d0146c1f872ccc1f11bfdcf5c993ef  release/kernels/stall.oracle.jsonl
819ff653eb4bd6eabb5bbaaaebe21135c8edae2e2dcd9de6d94520757ac305e8  release/kernels/stall.sv-hosted.log
3da3e3aa0b8ef17103b6d7e54d2605e9e5bbde4861676eea378fe6409cf18aac  release/kernels/swap.by_instr.json.gz
e41708d3b251c9a7a8c05453301021f3cce021dc9b5195190c5aae5519869c52  release/kernels/swap.by_unit.json.gz
892028773069382947669a8565e89ad81350b28f6e8861ba3b60e0babc696519  release/kernels/swap.ccvtrace
39aa781f6e8deef7e28a814007e1dbf2ef7fe429494665ab1ec14b27beeeb96b  release/kernels/swap.log
3658a26316c1ff7bc1744304a42f736e930fcde2865c8913e6cc67a22ce96667  release/kernels/swap.oracle.jsonl
c5bf780332db8784bfe209325ec06a96213886cbd547472bd5f19df79d22a6c5  release/kernels/swap.sv-hosted.log
e83c0787db625ef69f7cc6c3d12db0e1373693417eec1fdce47866ce423e1a84  release/kernels/transp4.by_instr.json.gz
6ee68f95d35bc206671d9f5f814316dd55933b593925518665901ae2fb1d81a5  release/kernels/transp4.by_unit.json.gz
9c9f7435ce6e77777f6a8ab434e91b737f9a2ba7ebb3638dca45840e9251af08  release/kernels/transp4.ccvtrace
e01552b32817b0d63f545b48dd079cc66f0ed0dcc40d1f5e2f8f44c306131244  release/kernels/transp4.log
06396ace3ac19677fd39c700e408606e5bdbacb24997d663bbe8872e63dd74fc  release/kernels/transp4.oracle.jsonl
b67505f12091943be46fd3eed8d05f554dca5a70c557efc4dc7d59e321c09205  release/kernels/transp4.sv-hosted.log
2299b6d74d5db5a1b906df9ebf68bf2e8d2142776920ca01db32482398fd5c97  release/kernels/unal.by_instr.json.gz
b579a5088620c2ce5428a8d180ef1141e12d96462a293a961449d4f01b35d28c  release/kernels/unal.by_unit.json.gz
1b3b224b0cca3352113bed47b586be34cf167a632ec031dfb10da1d35f0aed73  release/kernels/unal.ccvtrace
77e80513a79f1c7b20a6006c87b3fd770f00670e027195a964383123beb004c5  release/kernels/unal.log
c3d484bb160657a563df983d9a2532eac27f556636617960aa1e72183ac2b299  release/kernels/unal.oracle.jsonl
60a38e310d93f30e5f1b66c8c571412d3a0a020705dee6b3670d9b193171fb25  release/kernels/unal.sv-hosted.log
109868b29d4092a4326ff965d746d45154fab08a80c97292cfa33d3bebf36d22  release/kernels/vadd.by_instr.json.gz
813d4006b515df78651cbade47ba6ff6ef34f321c636b0b60d28e84b71ba599a  release/kernels/vadd.by_unit.json.gz
0d57e0309bcd01a4cf1a43b5a5da28010c962d44c0d5fb2046cfddbd736f81ae  release/kernels/vadd.ccvtrace
dae5bc48b1509c91e324b4bcb79e9a7c9ce3b348b9d6450fe1a5bcd7f4c47cdc  release/kernels/vadd.log
0276b6d0611a4bbcdc004ab3987214aea138245bc7217504147331689a9c0880  release/kernels/vadd.oracle.jsonl
b51c34f62fe8f74d33c4ac219d8dd42132fde0c36ef976d37836761a0c2b3daa  release/kernels/vadd.sv-hosted.log
612370dc453fc42f93538015f2efb557977eff05a953340c81f55224c4f197c2  release/kernels/vadd4.by_instr.json.gz
a1f6bea4098ec914e158ccfa537b7eaf71a6192de2d8c0190fb90a331638098e  release/kernels/vadd4.by_unit.json.gz
3fdfa61b755ca9388dce7259081cda7ad6559ac7394e1956261e72504e3ba118  release/kernels/vadd4.ccvtrace
420872d019327f5b0a3db4f84d73fb02d153f8b1de5b754e771d75a62261af14  release/kernels/vadd4.log
225aa18fc9f38aa9ad615aa11de254337d59fa705877553d873062c68366e0db  release/kernels/vadd4.oracle.jsonl
c697f1e0bd1f1178902bf166cbe44cf7fc1d362a1b79c9dae0cdd3e11e1f0ea9  release/kernels/vadd4.sv-hosted.log
d025c579756c3bba01a051b96a4f306b383f26bc216ebdca6e18613df2c84045  release/kernels/vaddslow.by_instr.json.gz
509a61072da29bbe5009cd558edfcee02714d2b2e1062b06addc765b09a8687e  release/kernels/vaddslow.by_unit.json.gz
324681a8412fa64ad998c3cb9eba5313ac695459354299dd5947c322f0c80321  release/kernels/vaddslow.ccvtrace
99ff1bd7c07c011552c0503b940b3957c35c15338ca9260650cc3cbc20dd309f  release/kernels/vaddslow.log
e9e6218e8b8450e9f9ff6b39d659c994a1e51c527a0c5bd10d18b5658ae0e344  release/kernels/vaddslow.oracle.jsonl
027420fa8e08a7217f26d77c4dcf2531584fac7ce47e8a288b5d1a834ed31246  release/kernels/vaddslow.sv-hosted.log
44721e713d820d628e5f0a54f8a43b792f4b3c4f68c0118921a6d405e5e7b5f0  release/verify.log
56b3d8627d79d397ca06dfb57060015391cb95e52e925d1f09a4b2a7f4147127  release/wiring.txt
```
