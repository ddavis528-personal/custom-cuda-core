# Snapshot snapshot-2026-11-12-5f2a432

**A generated, read-only snapshot. Do not edit or merge it.** The source
is `ccr-9eb50716-lecnjf` at `5f2a4323b9bcaf4e7824306c090b791aced9d763`, and this branch is rebuilt from source by
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
| Source | `ccr-9eb50716-lecnjf` @ `5f2a4323b9bcaf4e7824306c090b791aced9d763` |
| Built | 2026-11-12 (UTC) |
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
e843dd81b153d0b8f0092c21402fb19fbd66ad2a9d8b8912c7bf1e001caa0997  release/kernels/addrhigh.by_instr.json.gz
c767407f7cafbfd487d2c68767d062f5a4237dfd1f408a4fe1cccb895f84b907  release/kernels/addrhigh.by_unit.json.gz
26024c086b98c667eb6ff4ab07d9bb2b407953b72a2433e8bb2a0d0f590cfc08  release/kernels/addrhigh.ccvtrace
27240e2037e268e0eb06b1d826d900fa924c27faf55adf36860aeb04bdc1cea0  release/kernels/addrhigh.log
569f2e22883fad5f0956c57ec734e6afbdd4b8a854e50277425172d6c0cbd766  release/kernels/addrhigh.oracle.jsonl
7d6c95ef38a0f338f179839dfdd3e8b04b70a53649d47f0b12176c6a856d2f97  release/kernels/addrhigh.sv-hosted.log
c9699bdd745f08f65a2b611666d16b99a9232b78dfd4047c87adf2e373d85361  release/kernels/addrlimit.by_instr.json
300c1f4f04a25ce5cbf865a1665ee1fdced9355099dd4fe1a776970da3820ebe  release/kernels/addrlimit.by_unit.json
646dd11cf7744b4941083731a2cb0a8ce7b94cbdf53f708cf2adef6ad684a061  release/kernels/addrlimit.ccvtrace
9cf9efd6482b990e089b34bf8b39a7821f8f46d28f9c16a407bb8daf6339f60d  release/kernels/addrlimit.log
bc660b0b40359a2c5a2478cb0eb4950b73fd22db50ea76b80052bc195a1920f4  release/kernels/addrlimit.oracle.jsonl
f07731109acc4a9edb73035cc8003e908710567f526eca5a686e9750d289cae1  release/kernels/addrlimit.sv-hosted.log
b879f56d333c5039bb7f282658f0ca09589d2fe56531c13b684dd0893a4c9163  release/kernels/addrneg.by_instr.json
fec1fb96615feb68f26d8db7ed553f19cef1691f96dfc97666b271b4cfcaaeb4  release/kernels/addrneg.by_unit.json
401cb1b720323c75cebe1be95fb7e9736f1a40d7f0d02a7651c85f92e387bb9f  release/kernels/addrneg.ccvtrace
1e13c092179509033a5cd30bff752dd977913c9cec73d53baf24c1ed303149c9  release/kernels/addrneg.log
16f5b0707ae44492a1efd67bb9dd38a7e79a7bbd354fa9207b9e7d150ff2f107  release/kernels/addrneg.oracle.jsonl
26dcc1613587785812d27001d6d7b6692eafd7345ebb26503e60f76d16ed4f9e  release/kernels/addrneg.sv-hosted.log
edb600b7f7b647130e405956f375f0444a2d6180ca6e1080181d23cd6df2b8ed  release/kernels/atom.by_instr.json.gz
97c00d239f9c2853a4fe785e8f849f7de650509325601e39c3683770d5f93395  release/kernels/atom.by_unit.json.gz
1ad23250d393836aac4caa0748ad25772082b017a2700dc9d43196ddd46030fb  release/kernels/atom.ccvtrace
2bba398ae8c90e1b42560318118d1b69e92904b17fe91cdc57cfeaffcb0f6ee0  release/kernels/atom.log
504f5b6e9d25114dc35f2c70b21bb7b3f3c508c691de12dc0e87d12a74285361  release/kernels/atom.oracle.jsonl
c6a289f28df658f238e65079c1c8e3ae0850c496b479fac240d1a40149398415  release/kernels/atom.sv-hosted.log
62b3a52c8e0cda9fcff6c4de6ac465f54b1561481a33c302e61bd400c9255683  release/kernels/atomf.by_instr.json.gz
1473b4192a3dcba77dfac83b4d77a708f86315a8775822aaccccff4c9d575aca  release/kernels/atomf.by_unit.json.gz
ead6946f45250c234003b3c3d18a61765b5136bb5ca9bce30fc4e1b68403f586  release/kernels/atomf.ccvtrace
977980468bb913164283628fa958797c01953312a70ecb48024fea550c7191a0  release/kernels/atomf.log
cfd1179edf4061a33ab2f75d7a6dec61decfe629000198189a7bfc2647b34238  release/kernels/atomf.oracle.jsonl
50c978dff35572473bd277d834ad0c18b96658d6517e708e05da1547814190b6  release/kernels/atomf.sv-hosted.log
c079abac9ea1fae2113a8e7295a3dfb6b0de590545a5ba9f39cd93a2e1134757  release/kernels/borrow.by_instr.json.gz
c9b06eaf2c96f05862a6c824cf3ee11d922ed6f66ae0983bef5d347f338ee489  release/kernels/borrow.by_unit.json.gz
8eee0c50216f1eef61b0098241e98cee6f7c406c05849d0c1a4a2be835a5cfa5  release/kernels/borrow.ccvtrace
4786fdc81633a7e164dbd794685e0d722bd11c6cc913ab97d20ceefe74c70f87  release/kernels/borrow.log
4c565e1ce0b3baee36e158694b32c8defb5cd662b2f9af75cb5d8c26cb1168ed  release/kernels/borrow.oracle.jsonl
87f0269b266dcf4c326c7dd9f735d0a1e723553b13d9295121e5b7c1a6e7a927  release/kernels/borrow.sv-hosted.log
b612fd00df3acf7280e977a7a111162cc0619f6752ce069f35e81daeacd1060b  release/kernels/brs.by_instr.json.gz
d71b0eb3078125aac4d284eb615abd64ec0961f4dd57476faea12989bdef352c  release/kernels/brs.by_unit.json.gz
88a57ff042363bd7048526f4c13a55eefd7eaa18be159b61f466819827d06d8a  release/kernels/brs.ccvtrace
a19bd76fb1181d09b31c61f7135684ff2af7747979e2a8760d8281eefcb55323  release/kernels/brs.log
e3c1cb3379580cf1aae44e8ddc8e846ef6fd661a573cfe0a8d4444b18a14dc56  release/kernels/brs.oracle.jsonl
7a302be4bcc5253c61d5208a0b242b5f3b58c9c8d0b139e6b2e73b3ecfa4e667  release/kernels/brs.sv-hosted.log
a5ffebbf8a205b631d93f60d773442e56a46bbf39e007636c26ef92d688a2024  release/kernels/byp.by_instr.json.gz
9d0828fabd9f93f6a4f6c7367a513f9abfb5069d98fba9c214cbf08ad0010736  release/kernels/byp.by_unit.json.gz
8a572315c9d52778bafa71f96e4423500137a20efb80bc35014ecfb631f91125  release/kernels/byp.ccvtrace
b8467b758102880af68fda8812b0ff4d28f5a0384fba734ed5dd2de4e8433771  release/kernels/byp.log
5a03dfa4f3603fef49f1e3639e74e34152ca3ca5ef8e41eb959f8323040fa2d5  release/kernels/byp.oracle.jsonl
d0935c391d601d6062c2e5cac9a2e73e4963f8848a9b5d2e8b237726ba3b175f  release/kernels/byp.sv-hosted.log
cf26986377bd499dd475081bee49333fb8fb5f3c102b2312309a3d327d8491be  release/kernels/callret.by_instr.json.gz
6d0ce9ecb5f66bfaac0f0d9797b72e7dbb9e9b46671a9157affe2883997f030c  release/kernels/callret.by_unit.json.gz
046e92fbd4ca386af15041fe2d714aa45c58fd1cbd6562b55c7f53d80fcd82b3  release/kernels/callret.ccvtrace
a9a9771e1f6004b107c82c5d53e813b95b0bb95146a88e0c7e50cc8d715a0a49  release/kernels/callret.log
9b1d1b50b527f732362f837250aa2f26dabf3e76e16a4794856ebd8f105635b8  release/kernels/callret.oracle.jsonl
4c2162f1299cd7bb7aa9135fc18c9a97fe964fc8857f73422a4b1915e1ea6933  release/kernels/callret.sv-hosted.log
8782166e14c5e683eb13f908b69e9e72990d173ad3fbbab9fa16733f447a43e6  release/kernels/cas.by_instr.json.gz
e1526b3aeca4b2e9ac14ab716409d70f9350bc6e2822807d03dc57e3ac0dbb53  release/kernels/cas.by_unit.json.gz
2f8710781ba48bbf53e054ee39b2acd2423bf9f26797f034ed2cb18d10a58fe6  release/kernels/cas.ccvtrace
f9ed36c4ac7797a4635793f89c44910f7f2b63a9a3d491e6a03cee8459a5d051  release/kernels/cas.log
0ab31a9443336fe5d08e1a5fa5fcba3bc279b19022f7c5007908d39d8ef39536  release/kernels/cas.oracle.jsonl
7fd3ec797c98d80811291f138c9ab7c5b5bbaecf48f5422c7d1343879866d42f  release/kernels/cas.sv-hosted.log
d8527d74afa577f3376e4497b71f36d6b83eff166d01a96a69a5394d974d6292  release/kernels/chains.by_instr.json.gz
c4e4b6f979ccc500c189ba7582f85bbf8e911657a32fff845966480d667a7f9c  release/kernels/chains.by_unit.json.gz
6e0d095321f97cf86811fb152219d5b6a4e887fc54ad1f4fd5e559f32145cf64  release/kernels/chains.ccvtrace
17038086c82eede07c9b11c8984a145cc6c6151e5280902f9ade357e56901816  release/kernels/chains.log
26a4cc5c5524c7219d8706c2582c80357dea60be9d6ffdec99dac7d0365e2264  release/kernels/chains.oracle.jsonl
c0b053641913cc049ff7272f82faae6ec1056ab2e99c457c4b3a36f24d8e0a70  release/kernels/chains.sv-hosted.log
770283bd454fd2c88d48cb87a58a9c7251a12313738390e96860ab0c4f5bd713  release/kernels/coll.by_instr.json.gz
8a39ef25a3c8b7f565f1e47137c9543a6ced4f0f431da0c2eccbc4a26ccb2863  release/kernels/coll.by_unit.json.gz
3762b3824dc9a96c20d7dc82947e7bf8e6b1dd318f73c9bdeca10d8f86d9944d  release/kernels/coll.ccvtrace
0e6a0ad8c11fde3f73a7a9336deff59f1c647ac0a8c0c4f3664f642d2aade93b  release/kernels/coll.log
dd718d23c88df5dc7d92b055d8542865aa0e029118486af127312a8a578cfcbc  release/kernels/coll.oracle.jsonl
b326937b4e3c6f76b94e8434b11db0bd28037cfe4bb11b757f1f0c98fa3dcd48  release/kernels/coll.sv-hosted.log
d0fb8d58c7b6dc263b1274d7ea5137ab88d414b7aa3cd6714b2b28035b31360c  release/kernels/div.by_instr.json.gz
e7a754075b1d829c8a1d264e2e878170c18f7fabfbfcf1cf7db7db5e7cdaa4c1  release/kernels/div.by_unit.json.gz
afa661d89a3f00449cb5bda98fedabd73fae73279bf3192ce9eb9f55c9bb6ea1  release/kernels/div.ccvtrace
a4462adfc79ec3d45f8b1110d29ba7ec90563d91eaa481c4e653ace4e5b06acf  release/kernels/div.log
71a567b85cf85622631490187563de9a5661099c78a590adff4ed0a0c3d24c16  release/kernels/div.oracle.jsonl
c207f26b1b168059839d46467618f31ccab8383962fa83785957141fdf37f16f  release/kernels/div.sv-hosted.log
d9e4de29e5bc514ec3ef4be112c0df0c24d73fe5e47e14a473847c9ba6815db9  release/kernels/divchw.by_instr.json.gz
e039125dad05a83f98fbbb1f0efd61fbe7ba26c69bd7a840b76b5e32f2546614  release/kernels/divchw.by_unit.json.gz
9ce148460eb5a8d5b7a5a9e3515e0312f4506c687a04798281130666885620e4  release/kernels/divchw.ccvtrace
ec3288779cf35de1931359664969c8760225430b8998588f3fec4f283399689a  release/kernels/divchw.log
58a541797f7a2df0a1c7528ae6a3edec212db90c7d3eb20656806f38b5c10b3d  release/kernels/divchw.oracle.jsonl
65b6ff5a5a3a65538582cd2f6f2cc3c69ba8f73552c3ba1be329154b3179abfe  release/kernels/divchw.sv-hosted.log
d18d6dc9230554e1f967f4363fa2788afd2d4c54d53cff9f56dab3bfa12e75d9  release/kernels/divtail.by_instr.json.gz
fc564be2ccde0ca13aa2daf3e413abdbccfabf41863154af52e81583509e5a44  release/kernels/divtail.by_unit.json.gz
423d1be0830b8eb1f8dcb237ab56f5a611e27b4c61b3b14452a4cc5bece0d65b  release/kernels/divtail.ccvtrace
efcbc091c0052371a944535e887d9d2eaf262e919351fb7cd64cd12abceab439  release/kernels/divtail.log
75f11a75c9b3b336e446140af4579f05b46c363a76b7aab3ec88154a07ba097d  release/kernels/divtail.oracle.jsonl
11a4efcfa629bfd6ed8fa8b103aea6d945010e8397f2eadc244b29641b6f0ec7  release/kernels/divtail.sv-hosted.log
adbf0ea179df83b939073a6749739bfd7384307a7ecce757f8b32d32242255e9  release/kernels/divtail2.by_instr.json.gz
1267286dca53dbafe9cf3e6fc5e6a80d2c52e2ad3cfb6b38172131ec696d70ad  release/kernels/divtail2.by_unit.json.gz
7318a5b63e5a0376137977677b7bfd8830283bfac1c9e4d2d3fbe8af9a4ee8ff  release/kernels/divtail2.ccvtrace
e79718018ddc531b9d42364bf06628a117dab83f08c2920bf4e7cec446b5720a  release/kernels/divtail2.log
b2db6b05eb6cf4a0a7677e31d0c6c2952d5cab49d353f0bb1883fe0b2a20ed14  release/kernels/divtail2.oracle.jsonl
ebe428803fe16151094f88253530bb55ce2b89edefbd9ce2af15ab5928713c56  release/kernels/divtail2.sv-hosted.log
6b88b23d84714fd1ff7da47e6c5662c87e3e54b35a835d57d1d54d08b5f0df34  release/kernels/fence.by_instr.json
6d8665f9de66bc8b779842681a4d556fd913a4e3fc39bf21c15dfa467a69c84a  release/kernels/fence.by_unit.json.gz
851b82839626dd37b6325743a29c7a07ad5deb97a52fc9f9278827cb0255b8a4  release/kernels/fence.ccvtrace
4fb3b513ac3706d718bee29502d215d5d252a9bfc51e742dc47431201dea0f46  release/kernels/fence.log
d1d40317f6cf5bfb430cda1f9c0ef676609e59cabe2a11623c42ffbeca93142b  release/kernels/fence.oracle.jsonl
0b85da0dde7a0057bd9cc14eb1321ee154c60f3cc77bc0520f2e1dbfb975ad38  release/kernels/fence.sv-hosted.log
9cec299c6cdd1180933a63a55210cded77bd42986f3fd837b7ac0e59290afb1d  release/kernels/gather.by_instr.json.gz
5225e32eb179816f58279361084625565d3a4179d485637ad0497db513c56068  release/kernels/gather.by_unit.json.gz
bfbbdf573c0e26acfaca5b68c3a5c19bad1ba21717392d05966451f86a4822dc  release/kernels/gather.ccvtrace
4ea5fb8a6e8787c085a6eb5d3b1d91dab4e506417f461820f9d2c76bc7c05efa  release/kernels/gather.log
0413e781d8d6ff578c64eb1f800b7931e66f676d5cdabb97b94a4033e6037662  release/kernels/gather.oracle.jsonl
793f2a309e2737e4fec8b2129dce43b5cd1a543c1dc52f9d0c108018e24f6312  release/kernels/gather.sv-hosted.log
c26f4c9675419e3a29e346c316bac92e80f31c1e4a26410b0038c69ef85fa008  release/kernels/hit.by_instr.json.gz
659ce530c65e8258477d8c5a828e178b0e4a82c2a23a5ad830cd1bff83f3055e  release/kernels/hit.by_unit.json.gz
bc422f237fb22e88a2a634b3f14c87e3cf50c1ea1bbc09032578c55dbcf7068f  release/kernels/hit.ccvtrace
4d2023614dc4afb7fe24088c5e6b47191985a47b92d1c5604aaa5d6a5c1307f0  release/kernels/hit.log
7ba9603e0088d9164de6528f16ef6a7fa9ce5821c8c12b52cbb3734e39b9fd52  release/kernels/hit.oracle.jsonl
05dcd5e4cf8373efb641beae08f9bf02bd94734da7a8ce11aa16912af55cefbd  release/kernels/hit.sv-hosted.log
8d49d5c28e08fa36a868ce61aa9fbb7a30abd7254df038e06a1f5844e6cc7ed8  release/kernels/lanectx.by_instr.json.gz
273b1572fde8eda386cc99411252a35ff1784c962cbf711e88980f4ac9c81a84  release/kernels/lanectx.by_unit.json.gz
d5b66b1134115801e4e2af05622d5b6575d1aa782fd32acab13e61775f0ace4a  release/kernels/lanectx.ccvtrace
17303dfed26ab81c0d23a0ff6c0b705da05bb945b8b9a6da5f596f859bfe75db  release/kernels/lanectx.log
888551babf540db8e3025b82e65ca655013f93eba3c8a65689d069d52a7e6039  release/kernels/lanectx.oracle.jsonl
922322167f80704fe35d26e8764cb9b0593fad7afd817ab40540f4449cf8c9fa  release/kernels/lanectx.sv-hosted.log
ee8773d8b6d6a5ff5760336bfda62347e2a590bb934ecf4f28fb88821cb410e8  release/kernels/lanectx2.by_instr.json.gz
db99766919d67e9614c8b56361b13d0410a24a40a8e727bd34cd5fc68eb06d89  release/kernels/lanectx2.by_unit.json.gz
5ee1b7149af6046c44f881e22661045fc31433c819b136451b42ca921a0092da  release/kernels/lanectx2.ccvtrace
d95a004ae6acdbea5426d50f16a989bf99ccb1649efa633146852636840067c3  release/kernels/lanectx2.log
45c13056dff5c73ed0c9ece56cc36f929bf335322193c7d5eb38710b1d1dfb02  release/kernels/lanectx2.oracle.jsonl
757e2b32e8001c2b05e78f40b5c54214f90c30c198578d6ea723839a2dea6490  release/kernels/lanectx2.sv-hosted.log
062ac8e0f35c831cf9f12d07899898c28a4deaea3592d867d7337b5ec9fb299e  release/kernels/late.by_instr.json.gz
232cf1098b178a2417f5b6d660deff21c6d94a171024a059a45da625f664a919  release/kernels/late.by_unit.json.gz
a75891694f84bb5e60092f6767802e9651fcb425a2cfb438dd5bacac07980a16  release/kernels/late.ccvtrace
1a1bcf07749573fe53943ff499b7d89c2cea909e9f08760c8f28079ee89fdf8e  release/kernels/late.log
86084f6bd747a2cf32acbc0ebd96ebd3e4ef2d8d9e21be49e3ae49290d7927f3  release/kernels/late.oracle.jsonl
4935467b5fe078bec9b6316fd4adcee371bb0f6270133fab756e323a3c46cb20  release/kernels/late.sv-hosted.log
d7214e6d081c7142933a3867d702fbf52aa59e61cdfabb3d422a0f4a13688451  release/kernels/ldpar.by_instr.json.gz
0caab6e30bf49c170afd0477e7b0dcf3874ad5c6d9939fa1a2b27f98f68b56f9  release/kernels/ldpar.by_unit.json.gz
7e40f4ed8e582ab74173079682342cb738d83d39a97c7ca4ca1beac0d97e1497  release/kernels/ldpar.ccvtrace
05abd79fe8e3c055712ee8af3438b645e63c18a60f3b23d6f729c23599cb8ef3  release/kernels/ldpar.log
8ac08538e9c807637babd61b31e340f7461878ada31f0c0b83cd66331cfaf486  release/kernels/ldpar.oracle.jsonl
e9dba4ca4d2ee2915071a3b8c0165dac15f8cf26ce420102b532cc916322bc0a  release/kernels/ldpar.sv-hosted.log
00c4642b46d5ed97bed91f817ccb1ce9948f3fcc7a43c753165df10774c64bb9  release/kernels/lnorm1.by_instr.json.gz
12b8dddd4aef520ee1c881099f08f7141d92f8dd83d801f111e72721bd99d80f  release/kernels/lnorm1.by_unit.json.gz
477c69e023134c5db665626ddd1f77d9b4c7cf909003a7baa04cdf473c12df5e  release/kernels/lnorm1.ccvtrace
0ba51447e579ab5edf752c2a1092e7f9df4324c6ab72379065f9ce3eb4a3fa73  release/kernels/lnorm1.log
a8d85811af988a1b9fc00db1517300af3d93ec8e589e403d3b9113fa9e0ffc86  release/kernels/lnorm1.oracle.jsonl
977c52660ccc883c0eff82ad352717b43af26ed9816faff4d424df98d165f043  release/kernels/lnorm1.sv-hosted.log
81077b2b3f4600c0a9a76a3966e35000d7d4f6ed78cd50bcf73364c0c7099b70  release/kernels/localsp.by_instr.json.gz
ed681ee898a23101ae62351ffd0a97ecb3d0db3d8a79e86817a279aa8628fc49  release/kernels/localsp.by_unit.json.gz
7548335b65034560aee57a2368fcb8c86eac66d19ff8ca69fc0794ace801d21f  release/kernels/localsp.ccvtrace
145d81b566740c3c48acc4ea417a5518b0a1a2d2e91771f1c7ec8704bdf8afa3  release/kernels/localsp.log
55e3c9f36e7f7d38c0ddd38903aff4bb4509ae862015c592e6b937ea258042ca  release/kernels/localsp.oracle.jsonl
1bfe7857486a161cbf66f61fde2289654c2ea81bdc90a56e0f6c0932e06382cf  release/kernels/localsp.sv-hosted.log
8da17172806a01bbb59101db09f6390f31963d458ea314251b964270d804f656  release/kernels/loop.by_instr.json.gz
10711f8466e7ca028a23259918db08e5355c84f93a10d8355ad157fc685e0af6  release/kernels/loop.by_unit.json.gz
72abd321dfbd0f37886b1bba86b88fd77245016c27b4d87e6a56043567e2c98d  release/kernels/loop.ccvtrace
95577315961e0d18064c954d82b7100f3a7dc26da98851d7725e0d4e2339200b  release/kernels/loop.log
03ce5920c06c93e93516d8e53c3f7169f14e3593de204eacceffc0b8a3e32016  release/kernels/loop.oracle.jsonl
3360d89dae8f631403b3dc7fb3265eddd1420c2387b43c914cdee31107d5a623  release/kernels/loop.sv-hosted.log
bc10d0a0c46eb9dda9446dae1f085c54a91eef6cfef07afc0c84d059ac6a2623  release/kernels/merge.by_instr.json.gz
13c588a6158567d4cd090dc3924fcd9e24df065e80747f60bf0258a568f6af16  release/kernels/merge.by_unit.json.gz
a8d74967144ee4b4bd6ad87a20e05aac0925ba5f442e0f085929e688aed95403  release/kernels/merge.ccvtrace
0c4e8c75c740e2d3583b6a3b1ccdf9df16fd6d1a9ae859b2d93b269eb7124d12  release/kernels/merge.log
f96d28815f8756b1f5a45ded53e6170883d2dfa10f9eef0d14b8050b1318164a  release/kernels/merge.oracle.jsonl
dc41a3dac102b8e99e0923906164db9eb3598a693a4c43133cfdb3e0de4cd2c5  release/kernels/merge.sv-hosted.log
36bd483488b45e065fe7d8ee052de66326d71e686e4f93c4137ec67f999f8612  release/kernels/missrun.by_instr.json.gz
c5250840135f40aa95515baf0e183f9df035a699133c5c94d3418b04fb4419b6  release/kernels/missrun.by_unit.json.gz
60a010274d29769ba20803a40bb136e7153e845726e9bb47d6bc0216fe4efb88  release/kernels/missrun.ccvtrace
b21f82b9228e087a7f62888d2b9999a9bbfd07c22e9c7d68743ff4bf90c4cb1a  release/kernels/missrun.log
531bdaf281e5590774bd2775427f25e4cc0419cf8e3d5b6999843ffe9ef87258  release/kernels/missrun.oracle.jsonl
12a823450f96104b2047c22bc318247240a90027905e8b4f8c92527108d53e93  release/kernels/missrun.sv-hosted.log
7e3960641d182398139ab33b0305a9068888a527482012bc18237a481367d9f0  release/kernels/mload.by_instr.json.gz
71fb9cebbe649d7d92bf64656685bc070a4b1a5e7905ccaa24814f23255a5ee3  release/kernels/mload.by_unit.json.gz
0fdf9d0866cdc67d5437adb8641b5705f50fc9b10a2b2aa7c9b7b89d863fe438  release/kernels/mload.ccvtrace
dc12e5fe4a8f4275055cdb173d4f205468f5c79c05fb0e2df3f8d185b3f86229  release/kernels/mload.log
8000e477b9a95dfb9f0af964e8346acb9d36f1358fd06ffc4ff7cf599d2b8868  release/kernels/mload.oracle.jsonl
c407d06f432b8920f90b8028dc49d923fab7a4abcb2c65c534fa76eed899d195  release/kernels/mload.sv-hosted.log
786798d5df9f4c8e481fb08b9908ba219a90231a9c484246da27fc3581b69402  release/kernels/mlp.by_instr.json.gz
2ff39320bc14d8c64cb4c48260172a7ba90ce0ed5bf9d7bbf9234d8a0dc25e4d  release/kernels/mlp.by_unit.json.gz
fa560bf9bd386288984616514f3301db3de5626bb78cd85975c4379dfcaa7d6c  release/kernels/mlp.ccvtrace
663e5791fa4a2595c8c2d4dbd78a97c15bdc59d9aa4963acfac6e10ba521927e  release/kernels/mlp.log
138d282f88d56c8ad648a91af0a983254b55d9fa22942c00d47b327f516a6e44  release/kernels/mlp.oracle.jsonl
36ad587d956b539d0ca5adb6e9cdcb1c550ecc947c5af0b0cdf179756fbd4189  release/kernels/mlp.sv-hosted.log
4c0db296a5eac226fa360ffdfd15772e41c95a6b40a1365e2f33de54d300f98a  release/kernels/mwmiss.by_instr.json.gz
60468560b463b35c9f813584417bf3e287b967a9d8baaab927008235d2e17391  release/kernels/mwmiss.by_unit.json.gz
72968f2e3116db34104c799396a03347daf62f241e626f6a1ee89cc493f433e9  release/kernels/mwmiss.ccvtrace
4495e1483809dbd02df4a66cf83a33963ab3438062664aeda37fbc12fcabd5c7  release/kernels/mwmiss.log
8abe8e8997456a2a6711ee72da54d854b24e20abbdab28e4b7271c0d28418de8  release/kernels/mwmiss.oracle.jsonl
e7c80c494cb1a0f95a41824976fdb25491d7a1b7c729951a85905f4cfd3d8d9b  release/kernels/mwmiss.sv-hosted.log
e32e5e3b9f66db612f3873c73a1eb52b241ce7a72ef010952f68dccb690793d7  release/kernels/narrowadd.by_instr.json.gz
12135458a3cbad81c2a7436ced35a1ad12cdbcc8f4cd6d09dac7ac0cbdcb0b47  release/kernels/narrowadd.by_unit.json.gz
eaba990031d661ae76dd290f0f3c794a7955c1fac7ddfa5928186094b8abd950  release/kernels/narrowadd.ccvtrace
2184ff8b5c34a5079d953ec22a0261e335af6fbdbee6a454b89916ff5d62c021  release/kernels/narrowadd.log
40a2cf629853dd404bb06b4a07e35abde3d12efc13f26ffe28f923daf2994574  release/kernels/narrowadd.oracle.jsonl
f4858728186e93cfd069af8862bdf4cabf982abdcb02f9de6c9fed1f5b125058  release/kernels/narrowadd.sv-hosted.log
b1feece4037257159e334b013f830706af878499ad9eb62b5f0acca98d2f63f7  release/kernels/pguard.by_instr.json.gz
a0f51f107aeac8e27b382ab7b0bf05630b61d447bd0a21699aaebd25b37bbc62  release/kernels/pguard.by_unit.json.gz
3b56006868b45f582561dccb435ba57ea8d800e4dcbebcac798bed592041dee0  release/kernels/pguard.ccvtrace
d78c48c368ed6b5d4cecb33d8b6bf4a849ddf729870a54f4f11e1932982af933  release/kernels/pguard.log
690e56f1cb8d97cbf67124b7dff3ad0a90cb8981814cd1709cf0cd0e035b3bd9  release/kernels/pguard.oracle.jsonl
583a45dae9e05e0bb34bed7316fab9b259efe2188b8b7fc1aa22ae49d73e3ff2  release/kernels/pguard.sv-hosted.log
c7afb643e09656caaac1944e0a8e9a7e82d56b3ffbafc7c57155c16f077d2e84  release/kernels/plog.by_instr.json.gz
90d1764260f86f101419211e2e3962e2b82fd806155269cb1549ca81b3b1581a  release/kernels/plog.by_unit.json.gz
0cc33f3066dd4ae74b2296e7d22a3ce494836416ce6f69536758b97df8e156bf  release/kernels/plog.ccvtrace
950e21ab65d30856daf26671cf6bf7ac47b78552e17e8c1aa5c47e83eabc7b94  release/kernels/plog.log
0c99915e2da60f4670da00504a6371d7d17701d4431e733a3ff8fa98a2030d6a  release/kernels/plog.oracle.jsonl
140986cc530dca6105d11d47251e927d50c6eb54b89bd6bc12dffcf25dbc4c9a  release/kernels/plog.sv-hosted.log
034cc900672c5c020f2476af1f4d79affb3225f57af747a0f4313e27d3e5eb40  release/kernels/pmovdiv.by_instr.json.gz
7ba75376487c1b8c949a0f0df8777650f542a19347e1e25e293254029e268821  release/kernels/pmovdiv.by_unit.json.gz
231a3dd81b74fa2103ab2345699f1f0e0f4e412e85827b5e835d5d1c952eb6ae  release/kernels/pmovdiv.ccvtrace
165329c19f2cd1b4682252353a170783f76de7b8ccd1edae6e2ba00ee80780db  release/kernels/pmovdiv.log
7bc646cff6166a51bdce03d7c1b7209e871f0a91d743083a9b910a80bcd0b33f  release/kernels/pmovdiv.oracle.jsonl
9673561a6c902b392ac830253bae47233b3b13ba1f66ddaa92543e61350f6664  release/kernels/pmovdiv.sv-hosted.log
54ef4b92d2ba68a37829b7c23b3a727b9aae0cbcbab3c4cf91215406796a9392  release/kernels/predlane.by_instr.json.gz
4507cd116b02606a747d555807fca7845171b17e49ba6a813a6862c021f89948  release/kernels/predlane.by_unit.json.gz
eb789d73b076373515f510599083b24f2501a0bd4e20bbd32f09b292b112c02d  release/kernels/predlane.ccvtrace
8c4a653f5294a203cf3b88e7da6b1eaa04ecd0faf3131afe7551db0e1d10289e  release/kernels/predlane.log
c45f4177b9e84fc8a6e36b13534a0c7636eb30a3f8531847100ce5e23bf404b1  release/kernels/predlane.oracle.jsonl
06aedc73feed564a87fb8509c989779497b169ab4a5e96b4f2ae7343e9ef8ab7  release/kernels/predlane.sv-hosted.log
faf896512eefd386caccf15ea6cf1d21ab40daca2ca2be40c8015b7496ccd940  release/kernels/predmerge.by_instr.json.gz
81b7721a8cb8c190cd0ec590a84f4e0fe4354d343a21ab4c432e20f5a9d82a03  release/kernels/predmerge.by_unit.json.gz
992d9ed5bc1841229c645570617d50962aaf497fbb55d502a1af8aab6dc39499  release/kernels/predmerge.ccvtrace
8f067d385cf0afab6e862f2a895b3405188d7a4cca304332b86c5b7960e58982  release/kernels/predmerge.log
6c737c49434bcd08e3e0814c8b1dbf15c586ae74f7929ba3148ddcee2c62c845  release/kernels/predmerge.oracle.jsonl
199f910c857f6d1040b13e0ffd193cc8199dcf814fc3621e19a7dcf89557d8c4  release/kernels/predmerge.sv-hosted.log
1665638621931d2836b7a68713f33de79d2608596fcab058dd9e4931d1e73164  release/kernels/predspill.by_instr.json.gz
f05cdf4214241cd18042c4019b82858d2c22b0a2626646f362ff86d350f45e33  release/kernels/predspill.by_unit.json.gz
92f4a10d221f22f74ceb7c73372973b49d10dfe6e1fdb646f84723de6004b45a  release/kernels/predspill.ccvtrace
e96494394e32dba75c3eb8f93ca5fb4743d861a8ef33c5ca4e96f4d2dfce016a  release/kernels/predspill.log
b7c84c6478117ffa0f06da0e6ad1e4628e2683426a7911080810e78e06a5242e  release/kernels/predspill.oracle.jsonl
a03b76683b1b8e016f28f990e1e390e0a75d957b22c1ef359e42e1c99b28bfb0  release/kernels/predspill.sv-hosted.log
b8974931a9cb56a650c8e92c609464a1ef7a17885975041505c636411a020447  release/kernels/predswap.by_instr.json.gz
1f219a8bc986fbeab4c55e614057725d6dfc0d7f0c1a0cd5f4eed322a4017be9  release/kernels/predswap.by_unit.json.gz
f793d03da341396628fefdbbe49d9e5ed50de9cb68b64b7c74b5bf0fd183925e  release/kernels/predswap.ccvtrace
253ff10981635ad5684e9ef9818f3d383312e940e65cb6477edfc9002b9b5be5  release/kernels/predswap.log
a6d4f7ed517553816d889c7c9eeb6bcfd1f6c973fbf682ecb69f3c2de619f7bb  release/kernels/predswap.oracle.jsonl
2ccf067cac62b722407fb10c79d7a2f83a8d974e3315974f1249d228a09ebda9  release/kernels/predswap.sv-hosted.log
9cca85468c3b96f2954c74fdf6a7119b507c17c8e72d57a86aac54c319ebd9c3  release/kernels/privwin.by_instr.json.gz
f3974cadb9f4c5359bfddff9f7578b1b4ff93495114ba7bd7ddf1349ec5b19d2  release/kernels/privwin.by_unit.json.gz
325bce511eb4675b8e5bd663900b9a72dbd36c66caebd7a33c5d8ce939241e87  release/kernels/privwin.ccvtrace
c5df1f91d99233fca8df94ade4f20dda846e5658fb5fe8897f8a41d60e086b39  release/kernels/privwin.log
861f686fc4480363472908d679d8815e8c957d768e7ab32c826930527b0fb7a8  release/kernels/privwin.oracle.jsonl
a4a0ca7a313ae7848d211f8dd65eb8619031c91c21efbb2c46215fcef0328edd  release/kernels/privwin.sv-hosted.log
086ffd3e27668f6fd9d5ef1a85e932a4657f18f87e09e5d1f069f8028bea60fe  release/kernels/provswap.by_instr.json.gz
a25c0da8094cd68f0d63fb93ce87eee83c2ae1026a1af1aba8d218eac26c2631  release/kernels/provswap.by_unit.json.gz
0fec44b3b5cb0562290746e2d1014c88182c6a33b0dc84b07f704fbc7dc2aa46  release/kernels/provswap.ccvtrace
0ccca9556ddb76b513877830f163d0a225dc04ea17d3832eaffacc29e8ad73a1  release/kernels/provswap.log
c9c32a793d54cc7401477f582487f7e8b345b2669a75337b8d6327120d98e5dc  release/kernels/provswap.oracle.jsonl
32c3dd5f25c9785335c96124c7292c78d22fcd16c99b160ae0b4c9f87a2c44fd  release/kernels/provswap.sv-hosted.log
766ebbc9b2a25d1d1395f4c2e27b67af7559e2f643c9d44e66606225972b6537  release/kernels/retmiss.by_instr.json.gz
852fa61cc444cc7fd3d593acf71b3872a1644ec0ef083c4d63f1ada3950c7b90  release/kernels/retmiss.by_unit.json.gz
a94b952d7ddf4182c6bddd62106ee6e7d5afd002a8c763335f5d4120dacbb931  release/kernels/retmiss.ccvtrace
745020f73edb3b989781696be4734528346e677e484a36702ed84a5ca2bca571  release/kernels/retmiss.log
e5ef8538e838c6cff7febfc679dd091cf5e002f82d34f1009b1948ce22bc3649  release/kernels/retmiss.oracle.jsonl
c7da2a75fd0a390e638083b9facfe29e68b74725c53f88b1917695542e210597  release/kernels/retmiss.sv-hosted.log
c5ff1730f30873e277e5d962073b2f8a2ea8e82cbf83d046b24cb75b68797210  release/kernels/roconst.by_instr.json
aff2f6ba374c4b2edc0b4b13d953a14148d131286d30cc55dea555cb22b1b61e  release/kernels/roconst.by_unit.json
24e16ea5a89c0da7406ac67010ed1e91278e7e70007de5fd3c5e0e848c30ca5a  release/kernels/roconst.ccvtrace
494fc327cd7db4bbda75ead1a960b5cc2c6390a9eb632c53d924434c0ef4f183  release/kernels/roconst.log
8087c0671de620162881aecd38cd6114b78e7be6bd71201e3ec02c9a2e2e750e  release/kernels/roconst.oracle.jsonl
e4c396201cd76ad1e6225e56b7a2ba313719d44d18f69fe4e846b1fad8b0eb23  release/kernels/roconst.sv-hosted.log
8a379537853667bb0ec4c1843eee518dc465010710d108f3e114d66d4c6cfb3e  release/kernels/rogated.by_instr.json
85cfc22029c0ee0a1c5d366575bc26a288bc410fd55098184beaf8c0102abb30  release/kernels/rogated.by_unit.json.gz
631b1ab4d97f56e9c4e84621330223c13a652a9ba99663e4543231ef82086049  release/kernels/rogated.ccvtrace
967b63b0779565534ed14849e12e764c85fa1d5d58327962314628713d519d91  release/kernels/rogated.log
7cd02bd4cceec5a044d6b4d6a80df1e68ed0ae71b0b2a953143636d5b809ea6c  release/kernels/rogated.oracle.jsonl
2c385634ca1e8516ca4ab0f4fe1b698fb095808a8077f281092ae60d74fc3051  release/kernels/rogated.sv-hosted.log
abc13e713aa8351b046a1fd05d7f2ca3439afd6f1ec64ba4e2e4e696df6c7d34  release/kernels/rokill.by_instr.json.gz
2974c8f6f0b535b003bd9456665cbd1261b8429f3131086f33bbf8d384185b7a  release/kernels/rokill.by_unit.json.gz
55f1d311748482da87a37d632ef2903bd8d8cbb08eaf1fa08128d9d4b4fc6657  release/kernels/rokill.ccvtrace
0a224446371827af3aa6e2a2ff7bc3015355c20c5b05026f0fe7d9491095620d  release/kernels/rokill.log
94efcef96af469a512d346ce61623980fe86383188eaebd55120f716db596f14  release/kernels/rokill.oracle.jsonl
b3e58fc104f34cce7fbdb4dea335cc301e408f6b9563705aa1a27b68e3065195  release/kernels/rokill.sv-hosted.log
4ce3274ce40204c6adc0e06032de0b5f3a9af30d7eb9f93cd6a4341e23a1ba5c  release/kernels/rolaunch.by_instr.json
32a781755aabdaf1378a6e47b5d441c07dbeae5411b40e2456cddab84c3d9377  release/kernels/rolaunch.by_unit.json
c9423aa368141c32db86d8f3699fc646239c555b49d5d1a4c2e3e8b3042c37e1  release/kernels/rolaunch.ccvtrace
815a52d7fef6048024bb21899b0c6bfa2f645b3324c929f7e39485deda041c84  release/kernels/rolaunch.log
e7dad585c3e70615de04330fd03f4f282c29a005dc1732a35655fb261d51139e  release/kernels/rolaunch.oracle.jsonl
4f32783ba29404ef1707ee6a4d27de09a3c8a51961d024af01a3fdbc2160ef14  release/kernels/rolaunch.sv-hosted.log
c5ff1730f30873e277e5d962073b2f8a2ea8e82cbf83d046b24cb75b68797210  release/kernels/rolimit.by_instr.json
43430520f2f8de48bd6a6b0c767269a2ca31c6f08350cf47cc0beb21e8cb2eed  release/kernels/rolimit.by_unit.json
da82ea8ac380b275123303019058883c223ccdb993176d9f14ffa9730f395f89  release/kernels/rolimit.ccvtrace
e0fe2aef239b29aa5c5a9beab75d32011361fe49e69b6efe59169eed5c4b061c  release/kernels/rolimit.log
1c5bc0cb8e8b2e69505fb5a551a16d5d10c56f232b88da7a27e336ad7d962de2  release/kernels/rolimit.oracle.jsonl
3e8beb3937b2b016e170a5be6f321fba0c590a7054000b8d470d0ba995d6f5f3  release/kernels/rolimit.sv-hosted.log
b0d108df5bd3a6eebd9dcbace06322613d0bce86a45dd75a4a9b520c2f6ce6d7  release/kernels/roload.by_instr.json.gz
b78714de8e1279c16b5a09c489b55517207fd6b8fa2a7e13b6f693b21a1f270c  release/kernels/roload.by_unit.json.gz
9db58d0519c28e63306793107831abcac7824ecabeef0820a22e280b39799cd1  release/kernels/roload.ccvtrace
3e8adaeaab7710c41cc0cbee77cd72198bbc26b2d187bf70cbc2f17d635dfc25  release/kernels/roload.log
f7c1309cc9764769fb5803f6fd0f2f5e1eb418f2d23fbe5e17cf5f9106869fdf  release/kernels/roload.oracle.jsonl
8c91a5c292ee32469354ed6b9280e8ed71a97c3156568d84af16bbf7868336c6  release/kernels/roload.sv-hosted.log
ec8d2eaf167ec003ec93e5d3cf43e9a3944cd901b50a0b21353e96fb391e1de2  release/kernels/rope.by_instr.json.gz
9d5db163dc0bcc9e6718d2135ff7e3b9e9780880d90b0cc84185a7f1f028ceea  release/kernels/rope.by_unit.json.gz
1a9e2f663f827ca30a249aa74cdf970c81348d8ed41c1a9499bc8573ec861b6a  release/kernels/rope.ccvtrace
bed846f2d8b5551840fdd0d9a83995feb63ea64b60a892f6a2bef1ffa41d0512  release/kernels/rope.log
d55f9efae392dc8877c102c01c0810e7654b666b6ede386328108164c6cf88f3  release/kernels/rope.oracle.jsonl
0d42aba7e0047eb2a865bc1052a77a89f643ebaac9483cd01221c928e50a5d47  release/kernels/rope.sv-hosted.log
2897c2b0ec8d9b6f97ac22d792c200412a8d2df9e12e1c2b97e683e203d3ac26  release/kernels/ropediv.by_instr.json.gz
ce28b9224d8dc3c735611b68ad7283d5c2666b00a0c6e1cab5f3c651968e98d2  release/kernels/ropediv.by_unit.json.gz
e0f90b60cb5893cc5e9839a74708848bc8b5409e2af972fca5b128129a3c2614  release/kernels/ropediv.ccvtrace
b14725c2f548caa6cb4fdd5b44469f1a7b022967f180f528421f43036d91fcab  release/kernels/ropediv.log
10c0ec6ec18b7b44638c790033109198c079d07c1537bf193353ccedd00a920f  release/kernels/ropediv.oracle.jsonl
eb9bf5725ec3749e811c6a587e1940bf2f670507c7487b2bb1c8dd05d2731348  release/kernels/ropediv.sv-hosted.log
ee3593e11861f2ab9d5f944760c5f78071a1ad32264d604896ce0841e81a7071  release/kernels/sel.by_instr.json.gz
749fa15747e97850079e263a0a88289a54c42abe07715d170b84cb586fa504f6  release/kernels/sel.by_unit.json.gz
688c1614887034251601256381778a5d9009dc4bed01e11890a584f2cfaaf665  release/kernels/sel.ccvtrace
5020df1161245c5960188582d1d73b4580faaeb7bd6fe2e7900aaddf2d45d8df  release/kernels/sel.log
87f6a81e8afa004c8039bf2f61c90176fcf29ab29bb17ac44aa016a5cc8438fe  release/kernels/sel.oracle.jsonl
ab28a5c289779df7ffa669b133241aedd827ae7ba67112da95a096196d126fae  release/kernels/sel.sv-hosted.log
3eaae93542be2f9f657285b5f2e28df8dde395c70f6a12bfbec92194e50e2348  release/kernels/sized.by_instr.json.gz
6f3075f700af747902861968ee45a65e5f79522eba4ad99b6dd552f6277e7267  release/kernels/sized.by_unit.json.gz
1f80ee055c71f4da0b1411cd91f6b849d72a032b87e76f6d9b448fc37e51b495  release/kernels/sized.ccvtrace
63f95636d5d4c0425862898cffb0b89812d2105c0d6bec2db19f6b3468c7237b  release/kernels/sized.log
36d903ba1618bd1faa437c9812a6ee6c0c966a63196c796267d74bf2695ebc3d  release/kernels/sized.oracle.jsonl
b84bd9f39621bb69fff02206756dbc49bd10e4dd364d590031ff8f4faf51cc9a  release/kernels/sized.sv-hosted.log
73cc16be47a7be8a5e7292ae18c93ded2e8b1ed53cfa2651678faba5f6049748  release/kernels/slotform.by_instr.json.gz
9fbd4c1f82ce79c73e9dd14de83654f88b9c3f935a836a6f4e0394f3a07e2755  release/kernels/slotform.by_unit.json.gz
f93d62ae47498b83f4d72cb6de0cd18792372a17deb2fc2de7e5244c075f1e89  release/kernels/slotform.ccvtrace
1f79c19db62bb0c0f9eef1d7e97e2eb1a5fe780391d71e42f62c56982c546a63  release/kernels/slotform.log
8b61db7419b18cea8a646fb628218447e72e84a18a9891ffb73b441736138ab9  release/kernels/slotform.oracle.jsonl
02f1e2d361c41dc6a377674c1e7ec9a8be91eea319a2f2807585b3a05545d5be  release/kernels/slotform.sv-hosted.log
0f7c123913376f36aefc85017654e9c26151427c005725d2267d26384d3b0f03  release/kernels/spinwait.by_instr.json.gz
4c8f416686d2b291cd82d767373b58f60a5e1808d01714bba28e191aa18e9832  release/kernels/spinwait.by_unit.json.gz
3961613ec80a3fbc0f5a67f9ba71fd78ed20ed0c29180ab124e8ff6aa8e0e5ea  release/kernels/spinwait.ccvtrace
65130011661c53771d8073cd3c89a6bb63bb29883971f906c17fc2135184bdd1  release/kernels/spinwait.log
868920637236c878b33779bd450439466fc3626996a3164573dc11d437d5c709  release/kernels/spinwait.oracle.jsonl
c5541289ee0d674a87e1eb9d4b7275aaa8195c8102de0f2f4df1040f09c868dd  release/kernels/spinwait.sv-hosted.log
41e3e759f5bdf473d894fff18d1cd72a6895a612d872878055d658b4a07a7d51  release/kernels/spmbank.by_instr.json.gz
7b063466a66b24b1d8293410f81efb454c052424aefbe25276a60d78f028a8b4  release/kernels/spmbank.by_unit.json.gz
b41fbea616795bbf29c9e5a4fe7149db44bf3ded02d7a7358c49516a5bf360c1  release/kernels/spmbank.ccvtrace
4546faaf18deb38edf8b0645a03b1bfb927d2a82fec857f975035486fd49ee91  release/kernels/spmbank.log
3af490cc37d7a92dbe719b57de216b648536eb301ff9d13de9a39f50d150d725  release/kernels/spmbank.oracle.jsonl
645511a4adae2b5795f7d6cd1b98c3e8c0cecee5212c9a1354f4130125865bb9  release/kernels/spmbank.sv-hosted.log
dbc7b58fcfa2883b6b913c4d51305b82bd5da2c7a74914ea41e06bd260486e25  release/kernels/srd.by_instr.json.gz
81822e2eb8e55266b5241b8f92767a2009ad8f38e159b3754839e150c5ebedd5  release/kernels/srd.by_unit.json.gz
95badb026ccf14f957d3f0590ff6b6d3e65a1e3529a41b23e4826ee4473679f4  release/kernels/srd.ccvtrace
e4c2a3098a0a7ac41c6a3c9cf643e1b947dfbeaa12a8a55f779ec0165e9ff8b9  release/kernels/srd.log
b08eb5e3673cac7eebb8b72af5ed3783c8e70a9e96592e76bf3722551bc79473  release/kernels/srd.oracle.jsonl
ccd922536f3071cba5a3c6f727efe8815925c3497e12ed0116f5b13c0b23ab65  release/kernels/srd.sv-hosted.log
932aab2dd8ffaa5fffb45d08850cbdbedf6eafe53af8a2d5f0a4fcd950bb8c4b  release/kernels/stall.by_instr.json.gz
aebaacb1d5a4b45a17ff09fc04186f85452d0c53a9d5c7cd827089699fadc194  release/kernels/stall.by_unit.json.gz
34f78c0c08b929b8c250af4c5aa11d6fd5e810a7d837af1098d0e45a41aad0d1  release/kernels/stall.ccvtrace
51d1fc31172956fbbcfa61cac85819c6f71c4214bca5f7bda9358d14809295e1  release/kernels/stall.log
500db2c482b07a0706583422cd68878301d0146c1f872ccc1f11bfdcf5c993ef  release/kernels/stall.oracle.jsonl
2f1e2bfac00e92b683db098ceca489828b80657337b227c08a7d1778f491ab55  release/kernels/stall.sv-hosted.log
9f238393ea0cf7792fb86b5b304babeeb96ee7b3a77d6d180cf51a451c1d0098  release/kernels/swap.by_instr.json.gz
0ac59ecbc64fe108f8abc35592c7895351556f0f64c92212d293a6aba0651002  release/kernels/swap.by_unit.json.gz
892028773069382947669a8565e89ad81350b28f6e8861ba3b60e0babc696519  release/kernels/swap.ccvtrace
39aa781f6e8deef7e28a814007e1dbf2ef7fe429494665ab1ec14b27beeeb96b  release/kernels/swap.log
3658a26316c1ff7bc1744304a42f736e930fcde2865c8913e6cc67a22ce96667  release/kernels/swap.oracle.jsonl
e64f50806118a8db5941ed4ce79a131cecf30c1368b49b018fa48be020ce2f46  release/kernels/swap.sv-hosted.log
e4bcf8496e4b0465bacc88df7e83f6d10bd53a5fdb45eba9be0c6e4361a44b1f  release/kernels/transp4.by_instr.json.gz
e9ac4a73a5540e1521af3880d24110b72927d3767926f40f740fac832700d4cf  release/kernels/transp4.by_unit.json.gz
9c9f7435ce6e77777f6a8ab434e91b737f9a2ba7ebb3638dca45840e9251af08  release/kernels/transp4.ccvtrace
e01552b32817b0d63f545b48dd079cc66f0ed0dcc40d1f5e2f8f44c306131244  release/kernels/transp4.log
06396ace3ac19677fd39c700e408606e5bdbacb24997d663bbe8872e63dd74fc  release/kernels/transp4.oracle.jsonl
ef24335153e8f25ec5f3f5140fa69cb37aedc287e25f9e2caf8c36392fb3433f  release/kernels/transp4.sv-hosted.log
0b9b5b570ccba067cf13e7e460d0d054138331e65ff3b956f629303dc521fded  release/kernels/unal.by_instr.json.gz
7da752061d1f9842e54d55425fbc5bc3e7c0f6662dfebc8e3d6d198fb7c8fd62  release/kernels/unal.by_unit.json.gz
1b3b224b0cca3352113bed47b586be34cf167a632ec031dfb10da1d35f0aed73  release/kernels/unal.ccvtrace
77e80513a79f1c7b20a6006c87b3fd770f00670e027195a964383123beb004c5  release/kernels/unal.log
c3d484bb160657a563df983d9a2532eac27f556636617960aa1e72183ac2b299  release/kernels/unal.oracle.jsonl
05d7a2e40dfe5c5735825915276fa7faeb38173844b1285816984ef79cefac0a  release/kernels/unal.sv-hosted.log
523a3ec87182a5ba3cdf3c408dd6f60dc00b23ddc02ed6df8ee858cc5fdfde96  release/kernels/vadd.by_instr.json.gz
72a82cf3ea5a0b18668cc24b54bbf3fa655d4d3643e2b70562d6203e8967a55b  release/kernels/vadd.by_unit.json.gz
0d57e0309bcd01a4cf1a43b5a5da28010c962d44c0d5fb2046cfddbd736f81ae  release/kernels/vadd.ccvtrace
dae5bc48b1509c91e324b4bcb79e9a7c9ce3b348b9d6450fe1a5bcd7f4c47cdc  release/kernels/vadd.log
0276b6d0611a4bbcdc004ab3987214aea138245bc7217504147331689a9c0880  release/kernels/vadd.oracle.jsonl
0ba9e9f499ddd64af756f972ed12acbc87b82c6fc3356f7c1fda55332e264047  release/kernels/vadd.sv-hosted.log
51daf6698380b2bac2a48d83414fe1d4542fe8b717ea5bb161a920c009cac6db  release/kernels/vadd4.by_instr.json.gz
51d026c7f2838b855f2dce90af5957daa1669eec0243b498c7f62d037fc8d1ec  release/kernels/vadd4.by_unit.json.gz
3fdfa61b755ca9388dce7259081cda7ad6559ac7394e1956261e72504e3ba118  release/kernels/vadd4.ccvtrace
420872d019327f5b0a3db4f84d73fb02d153f8b1de5b754e771d75a62261af14  release/kernels/vadd4.log
225aa18fc9f38aa9ad615aa11de254337d59fa705877553d873062c68366e0db  release/kernels/vadd4.oracle.jsonl
e920db9121175781ae410a5133e527859a089e7290bb5d0a90ecb44479647345  release/kernels/vadd4.sv-hosted.log
245c115c32272539886aa1c31fcebf804527debd6ade8427e905fda498f052da  release/kernels/vaddslow.by_instr.json.gz
0488e855f127913fe84f1b2b67ade6993e99e55509b414e19c091a6452bb15f6  release/kernels/vaddslow.by_unit.json.gz
324681a8412fa64ad998c3cb9eba5313ac695459354299dd5947c322f0c80321  release/kernels/vaddslow.ccvtrace
99ff1bd7c07c011552c0503b940b3957c35c15338ca9260650cc3cbc20dd309f  release/kernels/vaddslow.log
e9e6218e8b8450e9f9ff6b39d659c994a1e51c527a0c5bd10d18b5658ae0e344  release/kernels/vaddslow.oracle.jsonl
5179734ae5686c9f13f300780bb58d318dba153d9cb245f58c1fe65b927d5339  release/kernels/vaddslow.sv-hosted.log
a9a5c9fb3a89fe7e9d44ae14c1beb6d57518e75ed78bb2038f0f7fcdfd8db605  release/verify.log
56b3d8627d79d397ca06dfb57060015391cb95e52e925d1f09a4b2a7f4147127  release/wiring.txt
```
