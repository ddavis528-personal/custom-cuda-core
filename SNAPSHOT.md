# Snapshot snapshot-2026-11-09-df28d0c

**A generated, read-only snapshot. Do not edit or merge it.** The source
is `ccr-9eb50716-lecnjf` at `df28d0c35769f7d79ec886a2e90e695692fc8a8f`, and this branch is rebuilt from source by
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
| Source | `ccr-9eb50716-lecnjf` @ `df28d0c35769f7d79ec886a2e90e695692fc8a8f` |
| Built | 2026-11-09 (UTC) |
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
bcbd3c5ce6759b12920adddad9e3eb6f559f9882ac3029e198c92b9ff2463cb5  release/kernels/addrhigh.by_instr.json.gz
402007af0b7f76bab6860aae22e3d1ca1124d6ff07af4f17a0edf5aac61a83de  release/kernels/addrhigh.by_unit.json.gz
26024c086b98c667eb6ff4ab07d9bb2b407953b72a2433e8bb2a0d0f590cfc08  release/kernels/addrhigh.ccvtrace
27240e2037e268e0eb06b1d826d900fa924c27faf55adf36860aeb04bdc1cea0  release/kernels/addrhigh.log
569f2e22883fad5f0956c57ec734e6afbdd4b8a854e50277425172d6c0cbd766  release/kernels/addrhigh.oracle.jsonl
757bcd0ba11dc2e656278a1adfb49b653b660eea8a4c142bd4c5fd86f332eb7e  release/kernels/addrhigh.sv-hosted.log
c9699bdd745f08f65a2b611666d16b99a9232b78dfd4047c87adf2e373d85361  release/kernels/addrlimit.by_instr.json
300c1f4f04a25ce5cbf865a1665ee1fdced9355099dd4fe1a776970da3820ebe  release/kernels/addrlimit.by_unit.json
646dd11cf7744b4941083731a2cb0a8ce7b94cbdf53f708cf2adef6ad684a061  release/kernels/addrlimit.ccvtrace
9cf9efd6482b990e089b34bf8b39a7821f8f46d28f9c16a407bb8daf6339f60d  release/kernels/addrlimit.log
bc660b0b40359a2c5a2478cb0eb4950b73fd22db50ea76b80052bc195a1920f4  release/kernels/addrlimit.oracle.jsonl
75217b8bfa4368b90b644d4153e497ad4aa2b97e97005dfeee109b20ced04c6c  release/kernels/addrlimit.sv-hosted.log
b879f56d333c5039bb7f282658f0ca09589d2fe56531c13b684dd0893a4c9163  release/kernels/addrneg.by_instr.json
fec1fb96615feb68f26d8db7ed553f19cef1691f96dfc97666b271b4cfcaaeb4  release/kernels/addrneg.by_unit.json
401cb1b720323c75cebe1be95fb7e9736f1a40d7f0d02a7651c85f92e387bb9f  release/kernels/addrneg.ccvtrace
1e13c092179509033a5cd30bff752dd977913c9cec73d53baf24c1ed303149c9  release/kernels/addrneg.log
16f5b0707ae44492a1efd67bb9dd38a7e79a7bbd354fa9207b9e7d150ff2f107  release/kernels/addrneg.oracle.jsonl
f6ce688db1242524435c67835b64211489df98ddf9b9c109859aacebbb147866  release/kernels/addrneg.sv-hosted.log
88fc0730fd5f553ab2eeeb777c9cde2abf071e64a22e4cff9e7a6277f09a1d61  release/kernels/atom.by_instr.json.gz
5e7fd237e0119b307016393763606be15a857e6d14bad7991de2d9d375a260d3  release/kernels/atom.by_unit.json.gz
1ad23250d393836aac4caa0748ad25772082b017a2700dc9d43196ddd46030fb  release/kernels/atom.ccvtrace
2bba398ae8c90e1b42560318118d1b69e92904b17fe91cdc57cfeaffcb0f6ee0  release/kernels/atom.log
504f5b6e9d25114dc35f2c70b21bb7b3f3c508c691de12dc0e87d12a74285361  release/kernels/atom.oracle.jsonl
880e70183c56646f4db227a6630eb6e0a902ab6d2b1f45c1f628fc761cadef5c  release/kernels/atom.sv-hosted.log
bb72318a83ed1335fb886adffd79b1a2e1cadf9a2a15d7e18f378789d56fc6a9  release/kernels/atomf.by_instr.json.gz
5469d68a0528351e84a98c255f275d49ccc2c1ab70ac1857fc29b0f6fbc8bb9e  release/kernels/atomf.by_unit.json.gz
ead6946f45250c234003b3c3d18a61765b5136bb5ca9bce30fc4e1b68403f586  release/kernels/atomf.ccvtrace
977980468bb913164283628fa958797c01953312a70ecb48024fea550c7191a0  release/kernels/atomf.log
cfd1179edf4061a33ab2f75d7a6dec61decfe629000198189a7bfc2647b34238  release/kernels/atomf.oracle.jsonl
f9bf1400a1fd2119e86a3fc84d864847e65bd5d27e7f2211f74b9ee62f2d0190  release/kernels/atomf.sv-hosted.log
ea841265bf116a9c4917c92b1d0102f6fc2aa799cabb451e37b1602d6b2f8a0c  release/kernels/borrow.by_instr.json.gz
fb93c30785fbcc44116ab8546bb0f1a07cded203c08138deeca5201380ca1558  release/kernels/borrow.by_unit.json.gz
8eee0c50216f1eef61b0098241e98cee6f7c406c05849d0c1a4a2be835a5cfa5  release/kernels/borrow.ccvtrace
4786fdc81633a7e164dbd794685e0d722bd11c6cc913ab97d20ceefe74c70f87  release/kernels/borrow.log
4c565e1ce0b3baee36e158694b32c8defb5cd662b2f9af75cb5d8c26cb1168ed  release/kernels/borrow.oracle.jsonl
a2618b06b4b5529a9c2f7e2c87901bb3566e2e1d140757bacba7e67d50beddb9  release/kernels/borrow.sv-hosted.log
966c954494ff9a000f2404640ba634b863953b8e34e9680c96caeb70a5855e08  release/kernels/brs.by_instr.json.gz
f05af177c5711321103d02d3ccff1c2a0118b004c6629b7881c6758e578d54cb  release/kernels/brs.by_unit.json.gz
88a57ff042363bd7048526f4c13a55eefd7eaa18be159b61f466819827d06d8a  release/kernels/brs.ccvtrace
a19bd76fb1181d09b31c61f7135684ff2af7747979e2a8760d8281eefcb55323  release/kernels/brs.log
e3c1cb3379580cf1aae44e8ddc8e846ef6fd661a573cfe0a8d4444b18a14dc56  release/kernels/brs.oracle.jsonl
a6c9945985d439b99f4968034fdd39fe36ce8872f0e363aa91b6bf3d014cf131  release/kernels/brs.sv-hosted.log
58cd163b0a5f42c5131f263c4532caf70a78c04269582ccd7a9a546fc900ff21  release/kernels/byp.by_instr.json.gz
d4cc62eb569e19c88f54b8fd5fb7fd4f5b3559e1bb861411566f69e61948984d  release/kernels/byp.by_unit.json.gz
8a572315c9d52778bafa71f96e4423500137a20efb80bc35014ecfb631f91125  release/kernels/byp.ccvtrace
b8467b758102880af68fda8812b0ff4d28f5a0384fba734ed5dd2de4e8433771  release/kernels/byp.log
5a03dfa4f3603fef49f1e3639e74e34152ca3ca5ef8e41eb959f8323040fa2d5  release/kernels/byp.oracle.jsonl
560f009c4f3f2027ac73a1c73e3842052973e5929a700abc8e2f475e7ea00fa5  release/kernels/byp.sv-hosted.log
9a95e131f8e88d1b15dda521274ad6b4b213dbb6f62e0a5ca8ab08ba9d8b6b14  release/kernels/callret.by_instr.json.gz
7d6ba43a49cccd5a24371d06b0bf3474cec08afbb4780cd2ffd91bcfb64605ec  release/kernels/callret.by_unit.json.gz
046e92fbd4ca386af15041fe2d714aa45c58fd1cbd6562b55c7f53d80fcd82b3  release/kernels/callret.ccvtrace
a9a9771e1f6004b107c82c5d53e813b95b0bb95146a88e0c7e50cc8d715a0a49  release/kernels/callret.log
9b1d1b50b527f732362f837250aa2f26dabf3e76e16a4794856ebd8f105635b8  release/kernels/callret.oracle.jsonl
a56b5b190b4da617a43a80e15380487d4ad67d8fb466ff397572e78764821be9  release/kernels/callret.sv-hosted.log
fa9c5818ec73a3bca5ed6cecb60e20516fcd269bc853e2a470d61106ee5962ab  release/kernels/cas.by_instr.json.gz
ad9bb66edbc2a47a409418c282ee362f5c2574b491b1b1e877663319d635d5d8  release/kernels/cas.by_unit.json.gz
2f8710781ba48bbf53e054ee39b2acd2423bf9f26797f034ed2cb18d10a58fe6  release/kernels/cas.ccvtrace
f9ed36c4ac7797a4635793f89c44910f7f2b63a9a3d491e6a03cee8459a5d051  release/kernels/cas.log
0ab31a9443336fe5d08e1a5fa5fcba3bc279b19022f7c5007908d39d8ef39536  release/kernels/cas.oracle.jsonl
2fe7c44d4f6f42fd55c914818d204f577f4b04a5bb0173c56938a9def8d1420c  release/kernels/cas.sv-hosted.log
59393cf041da5b392811f5f13618f2b86f05d377bcfd72c8fee6096ef029070c  release/kernels/chains.by_instr.json.gz
2360c503fd7005f5cc94157319a4b56836bf16178fc3bd3c05c8d16f5416f5a8  release/kernels/chains.by_unit.json.gz
6e0d095321f97cf86811fb152219d5b6a4e887fc54ad1f4fd5e559f32145cf64  release/kernels/chains.ccvtrace
17038086c82eede07c9b11c8984a145cc6c6151e5280902f9ade357e56901816  release/kernels/chains.log
26a4cc5c5524c7219d8706c2582c80357dea60be9d6ffdec99dac7d0365e2264  release/kernels/chains.oracle.jsonl
125a9f0ca5d0109a2a37a53f502a983d03532cdb8f56f4b2b59ba5a050f019a3  release/kernels/chains.sv-hosted.log
f515345d939a7e19aa13ee08645072c197b240a9fbeb03efb1b4ebccc76c8f40  release/kernels/coll.by_instr.json.gz
9a7e7609dbb8e707aa2d645221001ad3fb8963470fd60789a225f5a3392acdc5  release/kernels/coll.by_unit.json.gz
3762b3824dc9a96c20d7dc82947e7bf8e6b1dd318f73c9bdeca10d8f86d9944d  release/kernels/coll.ccvtrace
0e6a0ad8c11fde3f73a7a9336deff59f1c647ac0a8c0c4f3664f642d2aade93b  release/kernels/coll.log
dd718d23c88df5dc7d92b055d8542865aa0e029118486af127312a8a578cfcbc  release/kernels/coll.oracle.jsonl
e38b3373b248fffbae5681ca183f4402cb79054ec693ad2fcabf7c4ca957d2a3  release/kernels/coll.sv-hosted.log
bd88639f4162c8a637d154d1f2db4fc9d3238b67ae805c750c738ae67338334f  release/kernels/div.by_instr.json.gz
507a934c384f75f3e2eb80c392846d246ecef82b64d3a9b070d4c80b3e7ffe26  release/kernels/div.by_unit.json.gz
afa661d89a3f00449cb5bda98fedabd73fae73279bf3192ce9eb9f55c9bb6ea1  release/kernels/div.ccvtrace
a4462adfc79ec3d45f8b1110d29ba7ec90563d91eaa481c4e653ace4e5b06acf  release/kernels/div.log
71a567b85cf85622631490187563de9a5661099c78a590adff4ed0a0c3d24c16  release/kernels/div.oracle.jsonl
00255dd06fbf8292e76d3583e5a73ed7034e2ff3243b1e994b93847de2e046a4  release/kernels/div.sv-hosted.log
10b39ca6aa6941f7d583ce0212b0b616ca48049da6cb6e88c2131e194d74fe1b  release/kernels/divchw.by_instr.json.gz
1abe3ea44c7499c70d68117be6f907322c83fe7db289c4e1bfab3cc15590a1fb  release/kernels/divchw.by_unit.json.gz
9ce148460eb5a8d5b7a5a9e3515e0312f4506c687a04798281130666885620e4  release/kernels/divchw.ccvtrace
ec3288779cf35de1931359664969c8760225430b8998588f3fec4f283399689a  release/kernels/divchw.log
58a541797f7a2df0a1c7528ae6a3edec212db90c7d3eb20656806f38b5c10b3d  release/kernels/divchw.oracle.jsonl
2d48f981ea08101378926bc905b791e82be17f01e263ff88c67fcc7deba12ed7  release/kernels/divchw.sv-hosted.log
1302862a153f03287b9c07216d2bb814046e7fe99047d3610def93fca15b0a7f  release/kernels/divtail.by_instr.json.gz
967b2152b918ee0ec9abbe62af798d9e6110d2758b359fb4cca994fe5315e35d  release/kernels/divtail.by_unit.json.gz
423d1be0830b8eb1f8dcb237ab56f5a611e27b4c61b3b14452a4cc5bece0d65b  release/kernels/divtail.ccvtrace
efcbc091c0052371a944535e887d9d2eaf262e919351fb7cd64cd12abceab439  release/kernels/divtail.log
75f11a75c9b3b336e446140af4579f05b46c363a76b7aab3ec88154a07ba097d  release/kernels/divtail.oracle.jsonl
379b82274423cad05453577f7a66abc8e7c27eb22c061b0a6600e80e19a4f3c1  release/kernels/divtail.sv-hosted.log
1c797a53f20907e7e2d2d8fec969246232f83a535a84a492e161aed60a7304fb  release/kernels/divtail2.by_instr.json.gz
d548ea041f1db8212e3f64ead15b8d8eb9e03b844a8c400e140bae0d50b164ba  release/kernels/divtail2.by_unit.json.gz
7318a5b63e5a0376137977677b7bfd8830283bfac1c9e4d2d3fbe8af9a4ee8ff  release/kernels/divtail2.ccvtrace
e79718018ddc531b9d42364bf06628a117dab83f08c2920bf4e7cec446b5720a  release/kernels/divtail2.log
b2db6b05eb6cf4a0a7677e31d0c6c2952d5cab49d353f0bb1883fe0b2a20ed14  release/kernels/divtail2.oracle.jsonl
242acda302ded79433f53642a03b7c08cb9878f0bc434624e74bb065b9079039  release/kernels/divtail2.sv-hosted.log
6b88b23d84714fd1ff7da47e6c5662c87e3e54b35a835d57d1d54d08b5f0df34  release/kernels/fence.by_instr.json
25bd8e613dfb3a3977f27a7c86020285fca2dec21a612057049ba4fb042e74e3  release/kernels/fence.by_unit.json.gz
851b82839626dd37b6325743a29c7a07ad5deb97a52fc9f9278827cb0255b8a4  release/kernels/fence.ccvtrace
4fb3b513ac3706d718bee29502d215d5d252a9bfc51e742dc47431201dea0f46  release/kernels/fence.log
d1d40317f6cf5bfb430cda1f9c0ef676609e59cabe2a11623c42ffbeca93142b  release/kernels/fence.oracle.jsonl
29854a2c72306d79ceb881cf9ad36d58403ccd473a95a06dd34a05f308bb6b4c  release/kernels/fence.sv-hosted.log
1b589c014fd7902aa377ddfd6a49ace17a050886515459fac6327db58417f45c  release/kernels/gather.by_instr.json.gz
02953853e2519bb31cfa938f45b8df370c32f1c36846fa689e9e921c5b2eadb1  release/kernels/gather.by_unit.json.gz
bfbbdf573c0e26acfaca5b68c3a5c19bad1ba21717392d05966451f86a4822dc  release/kernels/gather.ccvtrace
4ea5fb8a6e8787c085a6eb5d3b1d91dab4e506417f461820f9d2c76bc7c05efa  release/kernels/gather.log
0413e781d8d6ff578c64eb1f800b7931e66f676d5cdabb97b94a4033e6037662  release/kernels/gather.oracle.jsonl
d75d096527c100b009b50170227a96d68cbe3980bdd2bc3bde528d98c52fb026  release/kernels/gather.sv-hosted.log
3c551beebd83ddd622f84e1e81baedf7c1c1692d4d048bc6f77d69e3376e8001  release/kernels/hit.by_instr.json.gz
7fc08f87772c5e2443f6ab5c6447b74067f312ceafdde9b13f1405afe1cdfbe1  release/kernels/hit.by_unit.json.gz
bc422f237fb22e88a2a634b3f14c87e3cf50c1ea1bbc09032578c55dbcf7068f  release/kernels/hit.ccvtrace
4d2023614dc4afb7fe24088c5e6b47191985a47b92d1c5604aaa5d6a5c1307f0  release/kernels/hit.log
7ba9603e0088d9164de6528f16ef6a7fa9ce5821c8c12b52cbb3734e39b9fd52  release/kernels/hit.oracle.jsonl
500e55aaa71b52ccc5a0532b72f4d402ac1343ddb5b19dd0ad16ace38f452cbb  release/kernels/hit.sv-hosted.log
9fab27482eae6d771630ef96ba6026760a7c67eac25c1d9b4ba74fb72e28a182  release/kernels/lanectx.by_instr.json.gz
60700da0be2575e67bfcf543ad2232cba5c3cbe41d3aef942bc9a2da5167eb73  release/kernels/lanectx.by_unit.json.gz
d5b66b1134115801e4e2af05622d5b6575d1aa782fd32acab13e61775f0ace4a  release/kernels/lanectx.ccvtrace
17303dfed26ab81c0d23a0ff6c0b705da05bb945b8b9a6da5f596f859bfe75db  release/kernels/lanectx.log
888551babf540db8e3025b82e65ca655013f93eba3c8a65689d069d52a7e6039  release/kernels/lanectx.oracle.jsonl
fe49f1df57ca0dcbe6d3f874053416207f5e5031c0ba773734605afc661767ed  release/kernels/lanectx.sv-hosted.log
4f3a7cf09bb5575e8aca88c7d556917a6e94ac8eb1b233dee6486546872efa1c  release/kernels/lanectx2.by_instr.json.gz
4fc39e5f53325c3e0ffa30f9584cc132bdc3349286eaf87499de4f61132b67ac  release/kernels/lanectx2.by_unit.json.gz
5ee1b7149af6046c44f881e22661045fc31433c819b136451b42ca921a0092da  release/kernels/lanectx2.ccvtrace
d95a004ae6acdbea5426d50f16a989bf99ccb1649efa633146852636840067c3  release/kernels/lanectx2.log
45c13056dff5c73ed0c9ece56cc36f929bf335322193c7d5eb38710b1d1dfb02  release/kernels/lanectx2.oracle.jsonl
c55dd26dc4c167a708857e8407f1446cf8a6aeb97563211cc394d69472b5f1a6  release/kernels/lanectx2.sv-hosted.log
dd41401b6858654fac8c853a960ef336a15bee2246f5ed41dc08efe35f28880b  release/kernels/late.by_instr.json.gz
aa5bb23b30297d6d48bd10f9ed0f5dacaf54399ab605acdb390eaf0ecaef79f0  release/kernels/late.by_unit.json.gz
a75891694f84bb5e60092f6767802e9651fcb425a2cfb438dd5bacac07980a16  release/kernels/late.ccvtrace
1a1bcf07749573fe53943ff499b7d89c2cea909e9f08760c8f28079ee89fdf8e  release/kernels/late.log
86084f6bd747a2cf32acbc0ebd96ebd3e4ef2d8d9e21be49e3ae49290d7927f3  release/kernels/late.oracle.jsonl
9ef1ca99a2f2a3a8701f117da626cd47fa62c99ec4fe6cc9b5931011d3a0c4bd  release/kernels/late.sv-hosted.log
d25b5ff4adce044f4e7d295347ac6678a7f15034e45a5adf20f28f325603cd3b  release/kernels/ldpar.by_instr.json.gz
7dde248bc1947fda10a6b7d0792d5e5be49290d5dabb15b125c05b25ea2ead14  release/kernels/ldpar.by_unit.json.gz
7e40f4ed8e582ab74173079682342cb738d83d39a97c7ca4ca1beac0d97e1497  release/kernels/ldpar.ccvtrace
05abd79fe8e3c055712ee8af3438b645e63c18a60f3b23d6f729c23599cb8ef3  release/kernels/ldpar.log
8ac08538e9c807637babd61b31e340f7461878ada31f0c0b83cd66331cfaf486  release/kernels/ldpar.oracle.jsonl
1479f11f1aa9c90276a504af587fa42cf01385543e47a91ee85c570fe440dafb  release/kernels/ldpar.sv-hosted.log
28938c89b6ef51e5c6408dcec713120c9033f5a8355643499ed0c9f4357d0961  release/kernels/lnorm1.by_instr.json.gz
d62fc1afaea3c5a36ec51932c49bd65a4ea86f77647be9dc40ab00f3483a6620  release/kernels/lnorm1.by_unit.json.gz
477c69e023134c5db665626ddd1f77d9b4c7cf909003a7baa04cdf473c12df5e  release/kernels/lnorm1.ccvtrace
0ba51447e579ab5edf752c2a1092e7f9df4324c6ab72379065f9ce3eb4a3fa73  release/kernels/lnorm1.log
a8d85811af988a1b9fc00db1517300af3d93ec8e589e403d3b9113fa9e0ffc86  release/kernels/lnorm1.oracle.jsonl
dbce777248a5b62a77320ab0813a5b19233842d61d59e1b4467d3246396332b7  release/kernels/lnorm1.sv-hosted.log
cf7e7784f7cb267efca43c74282871e334d4b91bbacf01134ca7a9e8f25c6a0a  release/kernels/localsp.by_instr.json.gz
21929aa948e71dd2fe7a28adef2a8b8e40d1f45db85b8d0cf24482664dab5abe  release/kernels/localsp.by_unit.json.gz
7548335b65034560aee57a2368fcb8c86eac66d19ff8ca69fc0794ace801d21f  release/kernels/localsp.ccvtrace
145d81b566740c3c48acc4ea417a5518b0a1a2d2e91771f1c7ec8704bdf8afa3  release/kernels/localsp.log
55e3c9f36e7f7d38c0ddd38903aff4bb4509ae862015c592e6b937ea258042ca  release/kernels/localsp.oracle.jsonl
c05b316086375b9ad9411741307420483cf8bb7a9a98d6562f1e79588987529d  release/kernels/localsp.sv-hosted.log
c9b8bee0af2ea7d86f97c5d6ed8ee162aaaacec64d2dc9f8e2da61282592c0e6  release/kernels/loop.by_instr.json.gz
cd3979b94c850e5032fffe3f38bcf5a05cd737c26b6320843981152e06820477  release/kernels/loop.by_unit.json.gz
72abd321dfbd0f37886b1bba86b88fd77245016c27b4d87e6a56043567e2c98d  release/kernels/loop.ccvtrace
95577315961e0d18064c954d82b7100f3a7dc26da98851d7725e0d4e2339200b  release/kernels/loop.log
03ce5920c06c93e93516d8e53c3f7169f14e3593de204eacceffc0b8a3e32016  release/kernels/loop.oracle.jsonl
e20b511340d390877e304c3e761b4493ef70ef1a60802f2317454719e8c202c5  release/kernels/loop.sv-hosted.log
c99450ead1271e671a0cc0d70e4434ab60a5e50b5c2cc0d3c625d5f1083a9072  release/kernels/merge.by_instr.json.gz
711293b4dd34ad92c6e3e6eb7e181e1431706f7e3766b5b11f9fbaf9abf058cc  release/kernels/merge.by_unit.json.gz
a8d74967144ee4b4bd6ad87a20e05aac0925ba5f442e0f085929e688aed95403  release/kernels/merge.ccvtrace
0c4e8c75c740e2d3583b6a3b1ccdf9df16fd6d1a9ae859b2d93b269eb7124d12  release/kernels/merge.log
f96d28815f8756b1f5a45ded53e6170883d2dfa10f9eef0d14b8050b1318164a  release/kernels/merge.oracle.jsonl
2229ea1dda45b0e625bb0fd0df9e6de93af849e8282cb12845b3460311beb90f  release/kernels/merge.sv-hosted.log
f13acc624fe0664eac9183f0b289ea2bae19dfea0884bedb9f780f2cbefaec62  release/kernels/missrun.by_instr.json.gz
5c607f0e1613c28a5c238c32ce4ba8e6142d89afd88b5adb55dd0b5fde42916f  release/kernels/missrun.by_unit.json.gz
60a010274d29769ba20803a40bb136e7153e845726e9bb47d6bc0216fe4efb88  release/kernels/missrun.ccvtrace
b21f82b9228e087a7f62888d2b9999a9bbfd07c22e9c7d68743ff4bf90c4cb1a  release/kernels/missrun.log
531bdaf281e5590774bd2775427f25e4cc0419cf8e3d5b6999843ffe9ef87258  release/kernels/missrun.oracle.jsonl
e17012c7b8a72503352a94ffa64b70aa5f742870e036cfe96c5df7b9de5adcfc  release/kernels/missrun.sv-hosted.log
8736c7a7b09aa933dd8bf3e1ae02a912ed0b16539be97db0c73a96e872d779e6  release/kernels/mload.by_instr.json.gz
970d16f1b82a5d12d237afc78269ce95b99b427c6017fa4188b2474c628b9c9c  release/kernels/mload.by_unit.json.gz
0fdf9d0866cdc67d5437adb8641b5705f50fc9b10a2b2aa7c9b7b89d863fe438  release/kernels/mload.ccvtrace
dc12e5fe4a8f4275055cdb173d4f205468f5c79c05fb0e2df3f8d185b3f86229  release/kernels/mload.log
8000e477b9a95dfb9f0af964e8346acb9d36f1358fd06ffc4ff7cf599d2b8868  release/kernels/mload.oracle.jsonl
c5aeb537aea3f35ebfb8f2dbd8d527c96ff38ba25eb09b7f4bf17b0602cae9a7  release/kernels/mload.sv-hosted.log
e2e77b79015939cb922efc47e0b209b743762288fabf9253d0864d94feaf1600  release/kernels/mlp.by_instr.json.gz
972bc3abfd54f30746ac48e887b86c56ac006092d08bb672fabae0553b766180  release/kernels/mlp.by_unit.json.gz
fa560bf9bd386288984616514f3301db3de5626bb78cd85975c4379dfcaa7d6c  release/kernels/mlp.ccvtrace
663e5791fa4a2595c8c2d4dbd78a97c15bdc59d9aa4963acfac6e10ba521927e  release/kernels/mlp.log
138d282f88d56c8ad648a91af0a983254b55d9fa22942c00d47b327f516a6e44  release/kernels/mlp.oracle.jsonl
74b25eaae1e08062e9567aab8b6e2ac921bf034da8e27da1b0b9f084feeb6dad  release/kernels/mlp.sv-hosted.log
078828535226fb109ab8b3c327a68b48205ae613a071ffda695d36323652b844  release/kernels/mwmiss.by_instr.json.gz
cec89d91e4fbe0fbfb456174fc90fe4319eb9ab9731774f0ef83bf1a7c021c41  release/kernels/mwmiss.by_unit.json.gz
72968f2e3116db34104c799396a03347daf62f241e626f6a1ee89cc493f433e9  release/kernels/mwmiss.ccvtrace
4495e1483809dbd02df4a66cf83a33963ab3438062664aeda37fbc12fcabd5c7  release/kernels/mwmiss.log
8abe8e8997456a2a6711ee72da54d854b24e20abbdab28e4b7271c0d28418de8  release/kernels/mwmiss.oracle.jsonl
fe02339226dbe7008a7be5dbb5074ccb6ec7be5259b5a9d7ef2c29e465037161  release/kernels/mwmiss.sv-hosted.log
2a98a27b2a257602d0802ddc3ed91784b2d346c535612a1009bd156c688008fb  release/kernels/narrowadd.by_instr.json.gz
8e400a4f8cb0ce5ca428ff725f4567a7708e5863e30ce092ecadb15864f2fd32  release/kernels/narrowadd.by_unit.json.gz
eaba990031d661ae76dd290f0f3c794a7955c1fac7ddfa5928186094b8abd950  release/kernels/narrowadd.ccvtrace
2184ff8b5c34a5079d953ec22a0261e335af6fbdbee6a454b89916ff5d62c021  release/kernels/narrowadd.log
40a2cf629853dd404bb06b4a07e35abde3d12efc13f26ffe28f923daf2994574  release/kernels/narrowadd.oracle.jsonl
25e6631694698987ccd974c123fcbe35fa73ff83b77d44a2beb377734b474bd2  release/kernels/narrowadd.sv-hosted.log
de916c0f63b3903468c6a6fc4336436b05f4ff42d9c46d2b9a35df93f94b0339  release/kernels/pguard.by_instr.json.gz
4582a7fb47d80614737ce64eabc65ff73946e0b77d94173d91207e7716a9c95c  release/kernels/pguard.by_unit.json.gz
3b56006868b45f582561dccb435ba57ea8d800e4dcbebcac798bed592041dee0  release/kernels/pguard.ccvtrace
d78c48c368ed6b5d4cecb33d8b6bf4a849ddf729870a54f4f11e1932982af933  release/kernels/pguard.log
690e56f1cb8d97cbf67124b7dff3ad0a90cb8981814cd1709cf0cd0e035b3bd9  release/kernels/pguard.oracle.jsonl
11dbc98b6aa8e5d42dadb0e6fe5fe1b0ae43f4a13fd7a9139e99b768f2e9976f  release/kernels/pguard.sv-hosted.log
23632199f04aa1951d0a41c8762b8c3b2e7b83a836683aa991b5f3e7ac8c0022  release/kernels/plog.by_instr.json.gz
14691a9482fcb11ae6243e0ddda3e5a4308110b3f69bfae393aa2640478a63e1  release/kernels/plog.by_unit.json.gz
0cc33f3066dd4ae74b2296e7d22a3ce494836416ce6f69536758b97df8e156bf  release/kernels/plog.ccvtrace
950e21ab65d30856daf26671cf6bf7ac47b78552e17e8c1aa5c47e83eabc7b94  release/kernels/plog.log
0c99915e2da60f4670da00504a6371d7d17701d4431e733a3ff8fa98a2030d6a  release/kernels/plog.oracle.jsonl
7aecfe5aec0d83e07064d583f66dc6bb5b68c9e528d3a81e21b6b48e25094b83  release/kernels/plog.sv-hosted.log
d0b34ae5e0416f35aecb697fe56bf84dc48667c8ce189e719eddd9b05e7e9ddf  release/kernels/pmovdiv.by_instr.json.gz
2a032905d60669411124f6f2b415d53fad5911901a4094c5a73cb1fab0c9cb87  release/kernels/pmovdiv.by_unit.json.gz
231a3dd81b74fa2103ab2345699f1f0e0f4e412e85827b5e835d5d1c952eb6ae  release/kernels/pmovdiv.ccvtrace
165329c19f2cd1b4682252353a170783f76de7b8ccd1edae6e2ba00ee80780db  release/kernels/pmovdiv.log
7bc646cff6166a51bdce03d7c1b7209e871f0a91d743083a9b910a80bcd0b33f  release/kernels/pmovdiv.oracle.jsonl
19795341de8902142e6e38af883f96a9837991a2a112301cdd99c5eb84eef383  release/kernels/pmovdiv.sv-hosted.log
f8dcf0f0dbe7bf8a170b288487f309b160a9b325f39a391743eb030e8db8ec07  release/kernels/predlane.by_instr.json.gz
1413ef9d08d0ad3f643600364bc9db0edcb2ba27e9edd20a209c9d9e1037605e  release/kernels/predlane.by_unit.json.gz
eb789d73b076373515f510599083b24f2501a0bd4e20bbd32f09b292b112c02d  release/kernels/predlane.ccvtrace
8c4a653f5294a203cf3b88e7da6b1eaa04ecd0faf3131afe7551db0e1d10289e  release/kernels/predlane.log
c45f4177b9e84fc8a6e36b13534a0c7636eb30a3f8531847100ce5e23bf404b1  release/kernels/predlane.oracle.jsonl
14f9be06d493b79b1ae7ee179c8a6167d0c495889bb8f93eaf17c15a67246fe2  release/kernels/predlane.sv-hosted.log
9562c3ac48bfb28b2d1e153567b89cdb4778d47fec0343b7d4533de0ca28cd8e  release/kernels/predmerge.by_instr.json.gz
1ce413ee559ac3c47728795b3931c6f418833f4c5660bc8116c7c76718dbb3e6  release/kernels/predmerge.by_unit.json.gz
992d9ed5bc1841229c645570617d50962aaf497fbb55d502a1af8aab6dc39499  release/kernels/predmerge.ccvtrace
8f067d385cf0afab6e862f2a895b3405188d7a4cca304332b86c5b7960e58982  release/kernels/predmerge.log
6c737c49434bcd08e3e0814c8b1dbf15c586ae74f7929ba3148ddcee2c62c845  release/kernels/predmerge.oracle.jsonl
033cdcc2d0c64a4b71fe97e065657e63050672d91ef43f166395bf4ad57b7fcc  release/kernels/predmerge.sv-hosted.log
8158ccab9dbac15d0ba0e90150a4c7cca21571f6af3def188a4eaeb4c3801b88  release/kernels/predspill.by_instr.json.gz
9fa0b2c41ea2ab92223c06cf42f3dab30890b7315cd856aeb52b90d0988c5e57  release/kernels/predspill.by_unit.json.gz
92f4a10d221f22f74ceb7c73372973b49d10dfe6e1fdb646f84723de6004b45a  release/kernels/predspill.ccvtrace
e96494394e32dba75c3eb8f93ca5fb4743d861a8ef33c5ca4e96f4d2dfce016a  release/kernels/predspill.log
b7c84c6478117ffa0f06da0e6ad1e4628e2683426a7911080810e78e06a5242e  release/kernels/predspill.oracle.jsonl
383923699116eae29223d6b394075bdee47c34aead6cab48fd3543a5fb185996  release/kernels/predspill.sv-hosted.log
21bf3b74326b35eedf8ebe2ad7d00002befd746da845fb17b6400f07c98d9585  release/kernels/predswap.by_instr.json.gz
66576c061a6825c9e71204b3c035ab8304652a8a8799102fc4e04f1f56dc727a  release/kernels/predswap.by_unit.json.gz
f793d03da341396628fefdbbe49d9e5ed50de9cb68b64b7c74b5bf0fd183925e  release/kernels/predswap.ccvtrace
253ff10981635ad5684e9ef9818f3d383312e940e65cb6477edfc9002b9b5be5  release/kernels/predswap.log
a6d4f7ed517553816d889c7c9eeb6bcfd1f6c973fbf682ecb69f3c2de619f7bb  release/kernels/predswap.oracle.jsonl
c06e6016ee787296c5dbb4efe64340f08f7c76fad0f7f57fe7b7b5b6e12d1a76  release/kernels/predswap.sv-hosted.log
e60063ae95465f1e4387445d470161150e7c3231fd6dde97c065081ab728c92a  release/kernels/privwin.by_instr.json.gz
ecbb6bdf98b81803bad94d3c25b011b4ec790f8f74ea8779b74f87d4a4a1f70b  release/kernels/privwin.by_unit.json.gz
325bce511eb4675b8e5bd663900b9a72dbd36c66caebd7a33c5d8ce939241e87  release/kernels/privwin.ccvtrace
c5df1f91d99233fca8df94ade4f20dda846e5658fb5fe8897f8a41d60e086b39  release/kernels/privwin.log
861f686fc4480363472908d679d8815e8c957d768e7ab32c826930527b0fb7a8  release/kernels/privwin.oracle.jsonl
e0d1b28dc8638ffbe4d6e677b04574688f7626c1599e6291c0fa3c46d1e81b15  release/kernels/privwin.sv-hosted.log
992948769dbc9b7c53b6358c9fef0f23864b390e8d1fe96443595b3dc2ba60ec  release/kernels/provswap.by_instr.json.gz
1873b932a07ed18a6915f2cf0b443190923ceebb5d04ff5c7212bb9f02df86f5  release/kernels/provswap.by_unit.json.gz
0fec44b3b5cb0562290746e2d1014c88182c6a33b0dc84b07f704fbc7dc2aa46  release/kernels/provswap.ccvtrace
0ccca9556ddb76b513877830f163d0a225dc04ea17d3832eaffacc29e8ad73a1  release/kernels/provswap.log
c9c32a793d54cc7401477f582487f7e8b345b2669a75337b8d6327120d98e5dc  release/kernels/provswap.oracle.jsonl
539ff3e45fc7560a7d396771048d471742925b2d82fd806c8d8c10f03f2f2cbb  release/kernels/provswap.sv-hosted.log
27aaee5a07b6fc6b7d458b2fa7b12332457ad45ce205dd057ab84bbb7aa6f6ea  release/kernels/retmiss.by_instr.json.gz
cb6bbc14c414c04aee671b6d8d8ee150917ba2fc8e6300215089c6313847f357  release/kernels/retmiss.by_unit.json.gz
a94b952d7ddf4182c6bddd62106ee6e7d5afd002a8c763335f5d4120dacbb931  release/kernels/retmiss.ccvtrace
745020f73edb3b989781696be4734528346e677e484a36702ed84a5ca2bca571  release/kernels/retmiss.log
e5ef8538e838c6cff7febfc679dd091cf5e002f82d34f1009b1948ce22bc3649  release/kernels/retmiss.oracle.jsonl
c2da3c445d5688041397a7229fa81f57ec05980b05e0efed8d8f04b8be335863  release/kernels/retmiss.sv-hosted.log
c5ff1730f30873e277e5d962073b2f8a2ea8e82cbf83d046b24cb75b68797210  release/kernels/roconst.by_instr.json
aff2f6ba374c4b2edc0b4b13d953a14148d131286d30cc55dea555cb22b1b61e  release/kernels/roconst.by_unit.json
24e16ea5a89c0da7406ac67010ed1e91278e7e70007de5fd3c5e0e848c30ca5a  release/kernels/roconst.ccvtrace
494fc327cd7db4bbda75ead1a960b5cc2c6390a9eb632c53d924434c0ef4f183  release/kernels/roconst.log
8087c0671de620162881aecd38cd6114b78e7be6bd71201e3ec02c9a2e2e750e  release/kernels/roconst.oracle.jsonl
fa632d189b65d288cbb9171c78b117ac469fd0d1f68c42521ef6caafe56de1a8  release/kernels/roconst.sv-hosted.log
8a379537853667bb0ec4c1843eee518dc465010710d108f3e114d66d4c6cfb3e  release/kernels/rogated.by_instr.json
7c824756bb6561857a623e183d50d35f3e6976020dcc9f345c1e72b3ef13f27d  release/kernels/rogated.by_unit.json.gz
631b1ab4d97f56e9c4e84621330223c13a652a9ba99663e4543231ef82086049  release/kernels/rogated.ccvtrace
967b63b0779565534ed14849e12e764c85fa1d5d58327962314628713d519d91  release/kernels/rogated.log
7cd02bd4cceec5a044d6b4d6a80df1e68ed0ae71b0b2a953143636d5b809ea6c  release/kernels/rogated.oracle.jsonl
f50e4c5fc99a2e737b8c9e16321afd51ca02a79a26223bb949b1dd87cdcba92e  release/kernels/rogated.sv-hosted.log
47868461f2107be963060633301d947c064761c5b57283b9b476a9842f488238  release/kernels/rokill.by_instr.json.gz
9e40bb028d6f4fa14b3c9396287f2cd0e77d4b71ab57619132e0027f145092e4  release/kernels/rokill.by_unit.json.gz
55f1d311748482da87a37d632ef2903bd8d8cbb08eaf1fa08128d9d4b4fc6657  release/kernels/rokill.ccvtrace
0a224446371827af3aa6e2a2ff7bc3015355c20c5b05026f0fe7d9491095620d  release/kernels/rokill.log
94efcef96af469a512d346ce61623980fe86383188eaebd55120f716db596f14  release/kernels/rokill.oracle.jsonl
ad42cbaa17b86fa04de49cbfbf279c5621df4d7b72acdf925d81e42bd789862b  release/kernels/rokill.sv-hosted.log
4ce3274ce40204c6adc0e06032de0b5f3a9af30d7eb9f93cd6a4341e23a1ba5c  release/kernels/rolaunch.by_instr.json
32a781755aabdaf1378a6e47b5d441c07dbeae5411b40e2456cddab84c3d9377  release/kernels/rolaunch.by_unit.json
c9423aa368141c32db86d8f3699fc646239c555b49d5d1a4c2e3e8b3042c37e1  release/kernels/rolaunch.ccvtrace
815a52d7fef6048024bb21899b0c6bfa2f645b3324c929f7e39485deda041c84  release/kernels/rolaunch.log
e7dad585c3e70615de04330fd03f4f282c29a005dc1732a35655fb261d51139e  release/kernels/rolaunch.oracle.jsonl
432a38d6eb45f3495d3fe1036077acde26079f1c42ef9be88844d6c45fca7bbd  release/kernels/rolaunch.sv-hosted.log
c5ff1730f30873e277e5d962073b2f8a2ea8e82cbf83d046b24cb75b68797210  release/kernels/rolimit.by_instr.json
43430520f2f8de48bd6a6b0c767269a2ca31c6f08350cf47cc0beb21e8cb2eed  release/kernels/rolimit.by_unit.json
da82ea8ac380b275123303019058883c223ccdb993176d9f14ffa9730f395f89  release/kernels/rolimit.ccvtrace
e0fe2aef239b29aa5c5a9beab75d32011361fe49e69b6efe59169eed5c4b061c  release/kernels/rolimit.log
1c5bc0cb8e8b2e69505fb5a551a16d5d10c56f232b88da7a27e336ad7d962de2  release/kernels/rolimit.oracle.jsonl
b5a34c82c22714f00e2e891041d1ff29985e5810074dea4febe3132b1f5b9ed2  release/kernels/rolimit.sv-hosted.log
4148f12f593afb5671af486c6d719365191470f26ed57c6dde665fcacadc6bd7  release/kernels/roload.by_instr.json.gz
7508303b99dfa5ee940ecf3368ce839839e9767159d79bcc16ecec4d5fd842f8  release/kernels/roload.by_unit.json.gz
9db58d0519c28e63306793107831abcac7824ecabeef0820a22e280b39799cd1  release/kernels/roload.ccvtrace
3e8adaeaab7710c41cc0cbee77cd72198bbc26b2d187bf70cbc2f17d635dfc25  release/kernels/roload.log
f7c1309cc9764769fb5803f6fd0f2f5e1eb418f2d23fbe5e17cf5f9106869fdf  release/kernels/roload.oracle.jsonl
0b3f06082613fd2691c4a6fe3e3b3fae39f26628f4dda6848e3c8c85bf56f4ab  release/kernels/roload.sv-hosted.log
db048f9c8167d2925caa3bdf1196aa5cc4dcc107bc325b82246ce4b197219664  release/kernels/rope.by_instr.json.gz
f654818d54e70aa611742f712f31876457d3db07380f51c9f6cc66781b0f5ac5  release/kernels/rope.by_unit.json.gz
1a9e2f663f827ca30a249aa74cdf970c81348d8ed41c1a9499bc8573ec861b6a  release/kernels/rope.ccvtrace
bed846f2d8b5551840fdd0d9a83995feb63ea64b60a892f6a2bef1ffa41d0512  release/kernels/rope.log
d55f9efae392dc8877c102c01c0810e7654b666b6ede386328108164c6cf88f3  release/kernels/rope.oracle.jsonl
8a2ef1a9de11878700f65772f0812fad1ae2d2c800ea359b4f1a4ca7ef5a3ab8  release/kernels/rope.sv-hosted.log
433174194e3c7174a0144a0202d45a6162a27975474f6e52f4bd11f06bfae0a5  release/kernels/ropediv.by_instr.json.gz
e1dc3c0d5a0398110bc1869c610e6c4a7d0e9b95e234fdbe18899c3b3a11749c  release/kernels/ropediv.by_unit.json.gz
e0f90b60cb5893cc5e9839a74708848bc8b5409e2af972fca5b128129a3c2614  release/kernels/ropediv.ccvtrace
b14725c2f548caa6cb4fdd5b44469f1a7b022967f180f528421f43036d91fcab  release/kernels/ropediv.log
10c0ec6ec18b7b44638c790033109198c079d07c1537bf193353ccedd00a920f  release/kernels/ropediv.oracle.jsonl
9cbb40a648313b150ba1e4bc427eea334f296041d3265c0d58d9f72cfce90abf  release/kernels/ropediv.sv-hosted.log
035649dd3a3bc98e4f83a86ff837c30f4bdac580f2cb33313d9102ffcbba53f8  release/kernels/sel.by_instr.json.gz
0e3b81f72cad8c85ad269c2fc212610363673768990c6d0845ef843b14abf99e  release/kernels/sel.by_unit.json.gz
688c1614887034251601256381778a5d9009dc4bed01e11890a584f2cfaaf665  release/kernels/sel.ccvtrace
5020df1161245c5960188582d1d73b4580faaeb7bd6fe2e7900aaddf2d45d8df  release/kernels/sel.log
87f6a81e8afa004c8039bf2f61c90176fcf29ab29bb17ac44aa016a5cc8438fe  release/kernels/sel.oracle.jsonl
1fc7c989b82b230377ec4f806cbfdaf8c407df0838a103ea9908bf8e0dd73724  release/kernels/sel.sv-hosted.log
30dc084050e4e46bb05d97cd1ee28bc51c6174adb21b81ee0b660e3b0a0aa1ad  release/kernels/sized.by_instr.json.gz
fdec1bed74460f1b02b58452a2bb6557adb4d5ce71112ebb22cd203f6bdc48b6  release/kernels/sized.by_unit.json.gz
1f80ee055c71f4da0b1411cd91f6b849d72a032b87e76f6d9b448fc37e51b495  release/kernels/sized.ccvtrace
63f95636d5d4c0425862898cffb0b89812d2105c0d6bec2db19f6b3468c7237b  release/kernels/sized.log
36d903ba1618bd1faa437c9812a6ee6c0c966a63196c796267d74bf2695ebc3d  release/kernels/sized.oracle.jsonl
daec3f1020a14371bf74644f5bfdd95ed7b1b1ea103bd4b6ce15b2960ddf9328  release/kernels/sized.sv-hosted.log
a0e356161a0a26e9b04ba25b36ef9e10298154c65f1de40a37750580cbba6e07  release/kernels/slotform.by_instr.json.gz
fff81a7b1e0eb8b702ed6c85c3f39d7755c8e015851223d39986ecf22d31adf9  release/kernels/slotform.by_unit.json.gz
f93d62ae47498b83f4d72cb6de0cd18792372a17deb2fc2de7e5244c075f1e89  release/kernels/slotform.ccvtrace
1f79c19db62bb0c0f9eef1d7e97e2eb1a5fe780391d71e42f62c56982c546a63  release/kernels/slotform.log
8b61db7419b18cea8a646fb628218447e72e84a18a9891ffb73b441736138ab9  release/kernels/slotform.oracle.jsonl
e7dc2470c5e52b937b84852bf0f9acb9bfef83bf309be4b06d7c61982e92bfe0  release/kernels/slotform.sv-hosted.log
b3bfb218d230068ea860d262c844e7b3acec6e38c51fea7bc47e8bdd58aee7c7  release/kernels/spinwait.by_instr.json.gz
b8c5dd0b71f5da11ea44f1b4f8bc6220d3d9c6549f1037604cea98f4301ae1ac  release/kernels/spinwait.by_unit.json.gz
3961613ec80a3fbc0f5a67f9ba71fd78ed20ed0c29180ab124e8ff6aa8e0e5ea  release/kernels/spinwait.ccvtrace
65130011661c53771d8073cd3c89a6bb63bb29883971f906c17fc2135184bdd1  release/kernels/spinwait.log
868920637236c878b33779bd450439466fc3626996a3164573dc11d437d5c709  release/kernels/spinwait.oracle.jsonl
5a5f361b89df699bc5c674cbba641ebc3c2005ae84b0526c61caf442f39034a7  release/kernels/spinwait.sv-hosted.log
84d2002f41d3466638c5ff9f16720ee1d531d01c0e3220a15624531f7d9325a2  release/kernels/spmbank.by_instr.json.gz
6a1e57045157b942bb73bc1ff5f1ccaecfe1aaa7a62324ae6d3cf2942fcfc4a9  release/kernels/spmbank.by_unit.json.gz
b41fbea616795bbf29c9e5a4fe7149db44bf3ded02d7a7358c49516a5bf360c1  release/kernels/spmbank.ccvtrace
4546faaf18deb38edf8b0645a03b1bfb927d2a82fec857f975035486fd49ee91  release/kernels/spmbank.log
3af490cc37d7a92dbe719b57de216b648536eb301ff9d13de9a39f50d150d725  release/kernels/spmbank.oracle.jsonl
267d79fed42944fbc55ddf89ad229cd1bb97a453818e86dfcdf2a945e1bddf48  release/kernels/spmbank.sv-hosted.log
3295cf3e4580af63828acf089601c8168e5b259118741007f3c2f122e8c855b1  release/kernels/srd.by_instr.json.gz
2fa6106f6d8371cea84790ec86de13e5cae32e078c6d5346b0fecd5f27d6dc18  release/kernels/srd.by_unit.json.gz
95badb026ccf14f957d3f0590ff6b6d3e65a1e3529a41b23e4826ee4473679f4  release/kernels/srd.ccvtrace
e4c2a3098a0a7ac41c6a3c9cf643e1b947dfbeaa12a8a55f779ec0165e9ff8b9  release/kernels/srd.log
b08eb5e3673cac7eebb8b72af5ed3783c8e70a9e96592e76bf3722551bc79473  release/kernels/srd.oracle.jsonl
737dfc3305fffabbc01f1ea2d665ae767340c53cfef39c528f4961ffdef7d37c  release/kernels/srd.sv-hosted.log
c4dffefd48c3ef1e6a10169cfc455b34e4c18beed773fbfd0663487ce3ca91a6  release/kernels/stall.by_instr.json.gz
35b06eb817cb8072a236ebcbd151cc1eba8d3aa2017484935ae039c1c64a080f  release/kernels/stall.by_unit.json.gz
34f78c0c08b929b8c250af4c5aa11d6fd5e810a7d837af1098d0e45a41aad0d1  release/kernels/stall.ccvtrace
51d1fc31172956fbbcfa61cac85819c6f71c4214bca5f7bda9358d14809295e1  release/kernels/stall.log
500db2c482b07a0706583422cd68878301d0146c1f872ccc1f11bfdcf5c993ef  release/kernels/stall.oracle.jsonl
75e34e5fe99b00a99e4935058a9dbaf125270c7541cfc6c0afe6bd1ae61d3d43  release/kernels/stall.sv-hosted.log
5fb7632e0dc62d48b199d53dc008e9919d98bda21e12be10e1653252357951b8  release/kernels/swap.by_instr.json.gz
d488b9d7cf31ce04964f3d5832747bd43d1c9759694765dcbb13aacfc15ba60c  release/kernels/swap.by_unit.json.gz
892028773069382947669a8565e89ad81350b28f6e8861ba3b60e0babc696519  release/kernels/swap.ccvtrace
39aa781f6e8deef7e28a814007e1dbf2ef7fe429494665ab1ec14b27beeeb96b  release/kernels/swap.log
3658a26316c1ff7bc1744304a42f736e930fcde2865c8913e6cc67a22ce96667  release/kernels/swap.oracle.jsonl
9c8742409a2f9c91a538c7998d7eb6dd43a115e6128232eb4f1135313ae5dfd1  release/kernels/swap.sv-hosted.log
ae6d371fba4aa07fc1a5bafc28a1fcade7cd895b74d0929932b7eedc8ae4f78c  release/kernels/transp4.by_instr.json.gz
657c218781798b5a344bd7aaeb0a1c9e455b5d0a11a3d371e8518b7848ffa5fc  release/kernels/transp4.by_unit.json.gz
9c9f7435ce6e77777f6a8ab434e91b737f9a2ba7ebb3638dca45840e9251af08  release/kernels/transp4.ccvtrace
e01552b32817b0d63f545b48dd079cc66f0ed0dcc40d1f5e2f8f44c306131244  release/kernels/transp4.log
06396ace3ac19677fd39c700e408606e5bdbacb24997d663bbe8872e63dd74fc  release/kernels/transp4.oracle.jsonl
5cc6e2c8132c9f13a94ed98c3e53875cd4a6ec994e8ed8ae05717b3cbbd1837a  release/kernels/transp4.sv-hosted.log
6b54d71c2b85269b344bb3276ee93fa3ae52102ccf894ba669cc52fd1d3672c1  release/kernels/unal.by_instr.json.gz
5fdfb180c9c44d32c8019f4b38835783cfb27f6859b5e22798f36c3b02bb82ed  release/kernels/unal.by_unit.json.gz
1b3b224b0cca3352113bed47b586be34cf167a632ec031dfb10da1d35f0aed73  release/kernels/unal.ccvtrace
77e80513a79f1c7b20a6006c87b3fd770f00670e027195a964383123beb004c5  release/kernels/unal.log
c3d484bb160657a563df983d9a2532eac27f556636617960aa1e72183ac2b299  release/kernels/unal.oracle.jsonl
a2791b746026df3fcd39341d0b49c93110bc7893201f0836321eab3473150834  release/kernels/unal.sv-hosted.log
378e68bee24c3747f7f9670d35f118b3f779453f5f9816ec2d65ad232960ded7  release/kernels/vadd.by_instr.json.gz
da45616d0112f1a8853c145a3027c3089c75658749066823195d4edf202eb3ac  release/kernels/vadd.by_unit.json.gz
0d57e0309bcd01a4cf1a43b5a5da28010c962d44c0d5fb2046cfddbd736f81ae  release/kernels/vadd.ccvtrace
dae5bc48b1509c91e324b4bcb79e9a7c9ce3b348b9d6450fe1a5bcd7f4c47cdc  release/kernels/vadd.log
0276b6d0611a4bbcdc004ab3987214aea138245bc7217504147331689a9c0880  release/kernels/vadd.oracle.jsonl
03f92a642accaa91e5d9d7f94e9256109f7e44000a9e8e11ea619b150f6cbcd6  release/kernels/vadd.sv-hosted.log
6ba07d9de04cca84e8eb2d049f28bc39ae5a7822914980414ee1009829793cda  release/kernels/vadd4.by_instr.json.gz
4b195de29959cf36ef636d45dde816b770d7ab45ab58ff1fd09d247b55509098  release/kernels/vadd4.by_unit.json.gz
3fdfa61b755ca9388dce7259081cda7ad6559ac7394e1956261e72504e3ba118  release/kernels/vadd4.ccvtrace
420872d019327f5b0a3db4f84d73fb02d153f8b1de5b754e771d75a62261af14  release/kernels/vadd4.log
225aa18fc9f38aa9ad615aa11de254337d59fa705877553d873062c68366e0db  release/kernels/vadd4.oracle.jsonl
5e5c46a3f1d5c16d1f6a460a5f0adc532610c4ff427fe8b5cdeed11c72fd6c44  release/kernels/vadd4.sv-hosted.log
15ba2130421a8bfb6b2293520b359116fe6269968ae15e7489530ab51843bcc0  release/kernels/vaddslow.by_instr.json.gz
bc1f31de2afb568c721d6983774598dea6433c37bccce227ec2434e012da3c03  release/kernels/vaddslow.by_unit.json.gz
324681a8412fa64ad998c3cb9eba5313ac695459354299dd5947c322f0c80321  release/kernels/vaddslow.ccvtrace
99ff1bd7c07c011552c0503b940b3957c35c15338ca9260650cc3cbc20dd309f  release/kernels/vaddslow.log
e9e6218e8b8450e9f9ff6b39d659c994a1e51c527a0c5bd10d18b5658ae0e344  release/kernels/vaddslow.oracle.jsonl
4746b17bd1f664d1645efa2499609390efba1ea2dc46d5bc051ebafc3a90c7d5  release/kernels/vaddslow.sv-hosted.log
8a0684eb686e5d58c716462d7b57affe5c8d70580d7c3ce7583bfdb64a6f4552  release/verify.log
56b3d8627d79d397ca06dfb57060015391cb95e52e925d1f09a4b2a7f4147127  release/wiring.txt
```
