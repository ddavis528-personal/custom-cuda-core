# Snapshot snapshot-2026-11-09-169f187

**A generated, read-only snapshot. Do not edit or merge it.** The source
is `sweep-try` at `169f18734491e72cddf19aa5bcc7892ab6df4fb5`, and this branch is rebuilt from source by
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
| Source | `sweep-try` @ `169f18734491e72cddf19aa5bcc7892ab6df4fb5` |
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
83ef827a98c008f4bfcc1cb6a998b36bc7d9e4a89b11fb65468de30aeba20c6a  release/kernels/addrhigh.by_instr.json.gz
3474a754b46b64cdbb1eea06bdcfc4036e33711ec1048ae27b19d7f9cb7c030c  release/kernels/addrhigh.by_unit.json.gz
26024c086b98c667eb6ff4ab07d9bb2b407953b72a2433e8bb2a0d0f590cfc08  release/kernels/addrhigh.ccvtrace
27240e2037e268e0eb06b1d826d900fa924c27faf55adf36860aeb04bdc1cea0  release/kernels/addrhigh.log
569f2e22883fad5f0956c57ec734e6afbdd4b8a854e50277425172d6c0cbd766  release/kernels/addrhigh.oracle.jsonl
f67dd092579a670a4239bddc756833d31b02be297d00da757897bced6274bb20  release/kernels/addrhigh.sv-hosted.log
c9699bdd745f08f65a2b611666d16b99a9232b78dfd4047c87adf2e373d85361  release/kernels/addrlimit.by_instr.json
300c1f4f04a25ce5cbf865a1665ee1fdced9355099dd4fe1a776970da3820ebe  release/kernels/addrlimit.by_unit.json
646dd11cf7744b4941083731a2cb0a8ce7b94cbdf53f708cf2adef6ad684a061  release/kernels/addrlimit.ccvtrace
9cf9efd6482b990e089b34bf8b39a7821f8f46d28f9c16a407bb8daf6339f60d  release/kernels/addrlimit.log
bc660b0b40359a2c5a2478cb0eb4950b73fd22db50ea76b80052bc195a1920f4  release/kernels/addrlimit.oracle.jsonl
e9fd6bd6e22ef3d904819fe8dad8ac8331a8f00c510ddc909250f6844b240883  release/kernels/addrlimit.sv-hosted.log
b879f56d333c5039bb7f282658f0ca09589d2fe56531c13b684dd0893a4c9163  release/kernels/addrneg.by_instr.json
fec1fb96615feb68f26d8db7ed553f19cef1691f96dfc97666b271b4cfcaaeb4  release/kernels/addrneg.by_unit.json
401cb1b720323c75cebe1be95fb7e9736f1a40d7f0d02a7651c85f92e387bb9f  release/kernels/addrneg.ccvtrace
1e13c092179509033a5cd30bff752dd977913c9cec73d53baf24c1ed303149c9  release/kernels/addrneg.log
16f5b0707ae44492a1efd67bb9dd38a7e79a7bbd354fa9207b9e7d150ff2f107  release/kernels/addrneg.oracle.jsonl
0482696e9d65a0f0a9c19a39a856e11a8a5b6d8433c4acf6d9af742c21b0b100  release/kernels/addrneg.sv-hosted.log
614148b40ba3745c6fb21ddc6ef07847827f2dc2561fa75d951e8660945107ad  release/kernels/atom.by_instr.json.gz
9744c46367ec978fe299602b472277ab184198450e88f1f9cb150f018267108b  release/kernels/atom.by_unit.json.gz
1ad23250d393836aac4caa0748ad25772082b017a2700dc9d43196ddd46030fb  release/kernels/atom.ccvtrace
2bba398ae8c90e1b42560318118d1b69e92904b17fe91cdc57cfeaffcb0f6ee0  release/kernels/atom.log
504f5b6e9d25114dc35f2c70b21bb7b3f3c508c691de12dc0e87d12a74285361  release/kernels/atom.oracle.jsonl
026e473bfb0b1cc3a2cb13b814da2565a297f0915373e20d0df830b24ac65f43  release/kernels/atom.sv-hosted.log
b43803e156b100569dd373d1bcd921d4fde92ed78e9d972f0eba8ed11817f1f8  release/kernels/atomf.by_instr.json.gz
21656ab5af8fc242c98e7f3956aa6001fb4405cc594a891cde79b20257dd4663  release/kernels/atomf.by_unit.json.gz
ead6946f45250c234003b3c3d18a61765b5136bb5ca9bce30fc4e1b68403f586  release/kernels/atomf.ccvtrace
977980468bb913164283628fa958797c01953312a70ecb48024fea550c7191a0  release/kernels/atomf.log
cfd1179edf4061a33ab2f75d7a6dec61decfe629000198189a7bfc2647b34238  release/kernels/atomf.oracle.jsonl
1abcc30280264eb06cc48bff6fab44b5196d0ad0c76cdd3da6148e51e1dc55d0  release/kernels/atomf.sv-hosted.log
babc211043cbd7ea18504409b5388e45a898583a295d9e4bd43b3d66a62f3af6  release/kernels/borrow.by_instr.json.gz
24f9b4eb41a059e30d9671bd7284b977f1c3503036ab79299a093a3ad24a3805  release/kernels/borrow.by_unit.json.gz
8eee0c50216f1eef61b0098241e98cee6f7c406c05849d0c1a4a2be835a5cfa5  release/kernels/borrow.ccvtrace
4786fdc81633a7e164dbd794685e0d722bd11c6cc913ab97d20ceefe74c70f87  release/kernels/borrow.log
4c565e1ce0b3baee36e158694b32c8defb5cd662b2f9af75cb5d8c26cb1168ed  release/kernels/borrow.oracle.jsonl
7a82b41fa694d4e906e397b63250b14a5099d68171cd650c60d4582444e521b3  release/kernels/borrow.sv-hosted.log
1f146b4c2b1ad1700c32c7f17f4747988de92d5f59dc1a8a3fe5f62207726adc  release/kernels/brs.by_instr.json.gz
217bdeb5587eaec10f36bcb9eaccf7584b99d21954887076c817e0be35053dec  release/kernels/brs.by_unit.json.gz
88a57ff042363bd7048526f4c13a55eefd7eaa18be159b61f466819827d06d8a  release/kernels/brs.ccvtrace
a19bd76fb1181d09b31c61f7135684ff2af7747979e2a8760d8281eefcb55323  release/kernels/brs.log
e3c1cb3379580cf1aae44e8ddc8e846ef6fd661a573cfe0a8d4444b18a14dc56  release/kernels/brs.oracle.jsonl
4a32403a1c82a672fad289e696b99716979c30ced9c8e0a50ff8fe0acbb1eda2  release/kernels/brs.sv-hosted.log
2f17c29f654fbe5120d4e77c63dd170f171b72adb9939cb68f5a397c7e077fab  release/kernels/byp.by_instr.json.gz
74f4afc75fc788e4e7a3488c5ccfd6371a47f9ba104ce73b8c2dd77d8147573f  release/kernels/byp.by_unit.json.gz
8a572315c9d52778bafa71f96e4423500137a20efb80bc35014ecfb631f91125  release/kernels/byp.ccvtrace
b8467b758102880af68fda8812b0ff4d28f5a0384fba734ed5dd2de4e8433771  release/kernels/byp.log
5a03dfa4f3603fef49f1e3639e74e34152ca3ca5ef8e41eb959f8323040fa2d5  release/kernels/byp.oracle.jsonl
aba3419249208764479b7584db12db8721a0a513c1dcdac167095cefdf420bea  release/kernels/byp.sv-hosted.log
2214814c2e4742dbe825b2106e460255452c92d0567f9b2a1ec7684047b13079  release/kernels/callret.by_instr.json.gz
7fcd97c394f4c1bf93481e442500c06ffcb8532ce84a8633c697923e9e1e4ed2  release/kernels/callret.by_unit.json.gz
046e92fbd4ca386af15041fe2d714aa45c58fd1cbd6562b55c7f53d80fcd82b3  release/kernels/callret.ccvtrace
a9a9771e1f6004b107c82c5d53e813b95b0bb95146a88e0c7e50cc8d715a0a49  release/kernels/callret.log
9b1d1b50b527f732362f837250aa2f26dabf3e76e16a4794856ebd8f105635b8  release/kernels/callret.oracle.jsonl
76df876b329a68e035db63064dee0866302aee8a6375b0ef9378e12da15cce4c  release/kernels/callret.sv-hosted.log
e8efaab460751bce00f28281bb8dfe0a3290107cf196fea66c11e37018f439b1  release/kernels/cas.by_instr.json.gz
0012e049212e74eec494534fbc603d832177c901265a074d7cde8e45c344b71f  release/kernels/cas.by_unit.json.gz
2f8710781ba48bbf53e054ee39b2acd2423bf9f26797f034ed2cb18d10a58fe6  release/kernels/cas.ccvtrace
f9ed36c4ac7797a4635793f89c44910f7f2b63a9a3d491e6a03cee8459a5d051  release/kernels/cas.log
0ab31a9443336fe5d08e1a5fa5fcba3bc279b19022f7c5007908d39d8ef39536  release/kernels/cas.oracle.jsonl
8d4abc5d5449a694f77469e52795b189323cc9301552269190e8f0373059d6f6  release/kernels/cas.sv-hosted.log
16a47d67f2c4a02af9faf31b5ba8db23c2258b55abef6a63e50f383c698fb2e3  release/kernels/chains.by_instr.json.gz
6a0a502f5ac31dbc9266243f23e92b7e32863a86b7a240fa23ac921e1c298353  release/kernels/chains.by_unit.json.gz
6e0d095321f97cf86811fb152219d5b6a4e887fc54ad1f4fd5e559f32145cf64  release/kernels/chains.ccvtrace
17038086c82eede07c9b11c8984a145cc6c6151e5280902f9ade357e56901816  release/kernels/chains.log
26a4cc5c5524c7219d8706c2582c80357dea60be9d6ffdec99dac7d0365e2264  release/kernels/chains.oracle.jsonl
310075cbeb0f50ad0429c48665e9f02b8e153ec917a9e07422dfd013253de667  release/kernels/chains.sv-hosted.log
6b77b648cd5bf3ca7716f11d418f93aa08460c069467abf56f4a74d3e70c439a  release/kernels/coll.by_instr.json.gz
94dd3156fa646505d67d59f67c8deffb759861cc30747b79c364186aa33ea33b  release/kernels/coll.by_unit.json.gz
3762b3824dc9a96c20d7dc82947e7bf8e6b1dd318f73c9bdeca10d8f86d9944d  release/kernels/coll.ccvtrace
0e6a0ad8c11fde3f73a7a9336deff59f1c647ac0a8c0c4f3664f642d2aade93b  release/kernels/coll.log
dd718d23c88df5dc7d92b055d8542865aa0e029118486af127312a8a578cfcbc  release/kernels/coll.oracle.jsonl
c90ab374dea959f233c546f1365bc86516a478a6ab644d12b96bec0aabeb7945  release/kernels/coll.sv-hosted.log
d0b02788dde0d8e76c8695c549dd2b53587e08013aa97d6ce9d0281618cde162  release/kernels/div.by_instr.json.gz
217827ad505de30cbb7f800114f6ffba6f04b136cad2aecca689ac19dd45a07c  release/kernels/div.by_unit.json.gz
afa661d89a3f00449cb5bda98fedabd73fae73279bf3192ce9eb9f55c9bb6ea1  release/kernels/div.ccvtrace
a4462adfc79ec3d45f8b1110d29ba7ec90563d91eaa481c4e653ace4e5b06acf  release/kernels/div.log
71a567b85cf85622631490187563de9a5661099c78a590adff4ed0a0c3d24c16  release/kernels/div.oracle.jsonl
a6bb05ac4d04d7bb8e4158087ab1d16c679179ee714cfc5d06d3c4b3e8d2a80a  release/kernels/div.sv-hosted.log
4973282e20b9ee70a64293afebc2aab0be72537d5fb98dc64d883e07654b34f7  release/kernels/divchw.by_instr.json.gz
b63899a73dda4cc8d2d24d658f6e022fa80f8cc90408a57e033fd66976681c21  release/kernels/divchw.by_unit.json.gz
9ce148460eb5a8d5b7a5a9e3515e0312f4506c687a04798281130666885620e4  release/kernels/divchw.ccvtrace
ec3288779cf35de1931359664969c8760225430b8998588f3fec4f283399689a  release/kernels/divchw.log
58a541797f7a2df0a1c7528ae6a3edec212db90c7d3eb20656806f38b5c10b3d  release/kernels/divchw.oracle.jsonl
b8a7ad79854f1a20e98376dd13b223960055ec8dfce02e0b643c087553372ad8  release/kernels/divchw.sv-hosted.log
2a22f02be094e7c18b47be9692ad7bbfd70c858c1b8eac7b006343234855271b  release/kernels/divtail.by_instr.json.gz
f8b7d76f3b547af66a490bb78f31326c4d3b57939f4995759f06cf1589cc009f  release/kernels/divtail.by_unit.json.gz
423d1be0830b8eb1f8dcb237ab56f5a611e27b4c61b3b14452a4cc5bece0d65b  release/kernels/divtail.ccvtrace
efcbc091c0052371a944535e887d9d2eaf262e919351fb7cd64cd12abceab439  release/kernels/divtail.log
75f11a75c9b3b336e446140af4579f05b46c363a76b7aab3ec88154a07ba097d  release/kernels/divtail.oracle.jsonl
2affff75df217ca338f3d0d0f52c0dd42b404d4119b26004956880da0799c33a  release/kernels/divtail.sv-hosted.log
42694388291c7b41036a25c69e912d663cb576b15852f235f7e23f24a9e87bf6  release/kernels/divtail2.by_instr.json.gz
b8284bfe4f45e52f4e40d77ce9222caf553d79a5c816b556371c3aa5d733012c  release/kernels/divtail2.by_unit.json.gz
7318a5b63e5a0376137977677b7bfd8830283bfac1c9e4d2d3fbe8af9a4ee8ff  release/kernels/divtail2.ccvtrace
e79718018ddc531b9d42364bf06628a117dab83f08c2920bf4e7cec446b5720a  release/kernels/divtail2.log
b2db6b05eb6cf4a0a7677e31d0c6c2952d5cab49d353f0bb1883fe0b2a20ed14  release/kernels/divtail2.oracle.jsonl
194a1241cee71db2365e4497641d78b41b4cdbedc552c1091f135981c0c165e7  release/kernels/divtail2.sv-hosted.log
6b88b23d84714fd1ff7da47e6c5662c87e3e54b35a835d57d1d54d08b5f0df34  release/kernels/fence.by_instr.json
c7e179b957586d3270a536eed8a2ae0b7ac1d898d97780e51c479710aab8387d  release/kernels/fence.by_unit.json.gz
851b82839626dd37b6325743a29c7a07ad5deb97a52fc9f9278827cb0255b8a4  release/kernels/fence.ccvtrace
4fb3b513ac3706d718bee29502d215d5d252a9bfc51e742dc47431201dea0f46  release/kernels/fence.log
d1d40317f6cf5bfb430cda1f9c0ef676609e59cabe2a11623c42ffbeca93142b  release/kernels/fence.oracle.jsonl
16e0f9abd6106a7629b570acc58b77a216c3d24a5cca6cf36784fcb0f9a91ff5  release/kernels/fence.sv-hosted.log
41342f7d7ad248717ecae04dc2c78054aefb464299b902874ec66846879167de  release/kernels/gather.by_instr.json.gz
3bd213111bbe76ed781fd629dead859416c1f6fbb4ba1662197c40784adb42fc  release/kernels/gather.by_unit.json.gz
bfbbdf573c0e26acfaca5b68c3a5c19bad1ba21717392d05966451f86a4822dc  release/kernels/gather.ccvtrace
4ea5fb8a6e8787c085a6eb5d3b1d91dab4e506417f461820f9d2c76bc7c05efa  release/kernels/gather.log
0413e781d8d6ff578c64eb1f800b7931e66f676d5cdabb97b94a4033e6037662  release/kernels/gather.oracle.jsonl
85feb83be9311bdca7c16a66e51a8d5f9eec9ee5e712170532634e1b4b218c13  release/kernels/gather.sv-hosted.log
f51376368c8657d65bee3a66d24431f4139f3948adb66120158600f81d68aeff  release/kernels/hit.by_instr.json.gz
3b8f29493014c98aa0dac534b44c6fb5a8d4aea05b10e5a7aeee3d9a5e7475d2  release/kernels/hit.by_unit.json.gz
bc422f237fb22e88a2a634b3f14c87e3cf50c1ea1bbc09032578c55dbcf7068f  release/kernels/hit.ccvtrace
4d2023614dc4afb7fe24088c5e6b47191985a47b92d1c5604aaa5d6a5c1307f0  release/kernels/hit.log
7ba9603e0088d9164de6528f16ef6a7fa9ce5821c8c12b52cbb3734e39b9fd52  release/kernels/hit.oracle.jsonl
d743df95137c16d1ce6be2d15200ae2a9f04a40639b0211f1068a1edf6587945  release/kernels/hit.sv-hosted.log
20ff8ba92ecf85178b61af0f0e866979c4f8d518e976849d0ab2871e11e3f4e4  release/kernels/lanectx.by_instr.json.gz
0ef6964794acf63a7c0a13e0f21e3266efe188a9a45d2ce5ac0af74a20c49a01  release/kernels/lanectx.by_unit.json.gz
d5b66b1134115801e4e2af05622d5b6575d1aa782fd32acab13e61775f0ace4a  release/kernels/lanectx.ccvtrace
17303dfed26ab81c0d23a0ff6c0b705da05bb945b8b9a6da5f596f859bfe75db  release/kernels/lanectx.log
888551babf540db8e3025b82e65ca655013f93eba3c8a65689d069d52a7e6039  release/kernels/lanectx.oracle.jsonl
4b45c1257fb991dcbc1b12c9de60a3587fc0e8319d4e62f704ea876e6a847b7d  release/kernels/lanectx.sv-hosted.log
5589b23d01f7c0fb4363ffc3f5f21be353abd3764c7ee380f410bbf851350a65  release/kernels/lanectx2.by_instr.json.gz
c620a4004d495fd7bbc084654786ef8a70675ea4a4047ce9b2b9d6126c3e315a  release/kernels/lanectx2.by_unit.json.gz
5ee1b7149af6046c44f881e22661045fc31433c819b136451b42ca921a0092da  release/kernels/lanectx2.ccvtrace
d95a004ae6acdbea5426d50f16a989bf99ccb1649efa633146852636840067c3  release/kernels/lanectx2.log
45c13056dff5c73ed0c9ece56cc36f929bf335322193c7d5eb38710b1d1dfb02  release/kernels/lanectx2.oracle.jsonl
30e6cf5b9dae5a8070d51ee083356502dcb09bacd42b031668c246916078f74f  release/kernels/lanectx2.sv-hosted.log
ca813f1d227e0bf819609d02e90a383bcbb2e35d3cbc0a079b2d1ac672df2839  release/kernels/late.by_instr.json.gz
affcc61aabfd5899424a7072d8f3cc3a318aaa2dcc17c9d7ed7413f326c409cc  release/kernels/late.by_unit.json.gz
a75891694f84bb5e60092f6767802e9651fcb425a2cfb438dd5bacac07980a16  release/kernels/late.ccvtrace
1a1bcf07749573fe53943ff499b7d89c2cea909e9f08760c8f28079ee89fdf8e  release/kernels/late.log
86084f6bd747a2cf32acbc0ebd96ebd3e4ef2d8d9e21be49e3ae49290d7927f3  release/kernels/late.oracle.jsonl
97e3aa97432d14e32b8604448835430fbb400e668506ed042879562ba0566e7c  release/kernels/late.sv-hosted.log
9cd94e99780fd8e4546d83c5215bb59c2551310fd03d8dcd517e3a74213c3e36  release/kernels/ldpar.by_instr.json.gz
990af5537c049df7d98cfaa45d32d0cdc8314be1050234ee12282365cdd4e1ca  release/kernels/ldpar.by_unit.json.gz
7e40f4ed8e582ab74173079682342cb738d83d39a97c7ca4ca1beac0d97e1497  release/kernels/ldpar.ccvtrace
05abd79fe8e3c055712ee8af3438b645e63c18a60f3b23d6f729c23599cb8ef3  release/kernels/ldpar.log
8ac08538e9c807637babd61b31e340f7461878ada31f0c0b83cd66331cfaf486  release/kernels/ldpar.oracle.jsonl
6326830c98a341264122e263b0dbab414ff8f1a449861dcc732cec1c54910e06  release/kernels/ldpar.sv-hosted.log
3ab06ddfb4d369af411ec8079e5d6d244a9b159de7c17451f6e87e418cb9d6e7  release/kernels/lnorm1.by_instr.json.gz
58453469f4ad7a0c540e245cf06cc4f7ec76529d050507a1043c8bfee166e913  release/kernels/lnorm1.by_unit.json.gz
477c69e023134c5db665626ddd1f77d9b4c7cf909003a7baa04cdf473c12df5e  release/kernels/lnorm1.ccvtrace
0ba51447e579ab5edf752c2a1092e7f9df4324c6ab72379065f9ce3eb4a3fa73  release/kernels/lnorm1.log
a8d85811af988a1b9fc00db1517300af3d93ec8e589e403d3b9113fa9e0ffc86  release/kernels/lnorm1.oracle.jsonl
797e3d9392df665a7429f418a6d73fe6871f484acd68748587a393fe50acd6b3  release/kernels/lnorm1.sv-hosted.log
78cb4fa3cfa514303d1ea8a5b9258b21692bb5da4d36e1459913e064a138af16  release/kernels/localsp.by_instr.json.gz
d78dd9ce60a28a54a4e119c694c85efaec78272283f3d0b7c83f7f4e5bee242a  release/kernels/localsp.by_unit.json.gz
7548335b65034560aee57a2368fcb8c86eac66d19ff8ca69fc0794ace801d21f  release/kernels/localsp.ccvtrace
145d81b566740c3c48acc4ea417a5518b0a1a2d2e91771f1c7ec8704bdf8afa3  release/kernels/localsp.log
55e3c9f36e7f7d38c0ddd38903aff4bb4509ae862015c592e6b937ea258042ca  release/kernels/localsp.oracle.jsonl
0cb4656c6af20f912dfe86479a443f32cfa57c03234d03719ba0e3f1e9917c16  release/kernels/localsp.sv-hosted.log
0fc8fcf1c482aa710011c2691330d4a9c1ee373c93c37ed87209a09e082fd2e1  release/kernels/loop.by_instr.json.gz
f49dc003c978d61561ae2d58a1a6649daafb51643522f8406f957080ace90811  release/kernels/loop.by_unit.json.gz
72abd321dfbd0f37886b1bba86b88fd77245016c27b4d87e6a56043567e2c98d  release/kernels/loop.ccvtrace
95577315961e0d18064c954d82b7100f3a7dc26da98851d7725e0d4e2339200b  release/kernels/loop.log
03ce5920c06c93e93516d8e53c3f7169f14e3593de204eacceffc0b8a3e32016  release/kernels/loop.oracle.jsonl
a0f17e2bd629d7b6ed54f2c6fd8e34fdbf5b07cf8dd7b261c74fc74e489a4f3f  release/kernels/loop.sv-hosted.log
d09672d593daa3b7709a0340a5904331a311574aa2fa5dd12075447111aa8a77  release/kernels/merge.by_instr.json.gz
07ad0ffc974801da344b447dcf20ce0759abcbf7af3b0951430b0fdda546369d  release/kernels/merge.by_unit.json.gz
a8d74967144ee4b4bd6ad87a20e05aac0925ba5f442e0f085929e688aed95403  release/kernels/merge.ccvtrace
0c4e8c75c740e2d3583b6a3b1ccdf9df16fd6d1a9ae859b2d93b269eb7124d12  release/kernels/merge.log
f96d28815f8756b1f5a45ded53e6170883d2dfa10f9eef0d14b8050b1318164a  release/kernels/merge.oracle.jsonl
21b6fdbc96a26ef95dc0cab47d68df82f8fb3da99b4d60339c040cdbb2d355c0  release/kernels/merge.sv-hosted.log
322291ca496b0d01a00889a88e7830f75a91c23589ae112f99b023ed9ab5cd1f  release/kernels/missrun.by_instr.json.gz
7af9e2c4a26c762d5d945f2f3f5c635c28392454f8557a8d3ba0954fd0870172  release/kernels/missrun.by_unit.json.gz
60a010274d29769ba20803a40bb136e7153e845726e9bb47d6bc0216fe4efb88  release/kernels/missrun.ccvtrace
b21f82b9228e087a7f62888d2b9999a9bbfd07c22e9c7d68743ff4bf90c4cb1a  release/kernels/missrun.log
531bdaf281e5590774bd2775427f25e4cc0419cf8e3d5b6999843ffe9ef87258  release/kernels/missrun.oracle.jsonl
62517e8cac8c744b7d74316e6b362df4ffaad98f18ffde5f856266933e0ad924  release/kernels/missrun.sv-hosted.log
3a5537ec274e1fae4bcd35a02889cf8525390cc1b0b0f2b2fa55de2be142c7d9  release/kernels/mload.by_instr.json.gz
81f9c57dfe3750cd178a282b9ccf97b217de197e69b0da07fcf340f6c1dab03a  release/kernels/mload.by_unit.json.gz
0fdf9d0866cdc67d5437adb8641b5705f50fc9b10a2b2aa7c9b7b89d863fe438  release/kernels/mload.ccvtrace
dc12e5fe4a8f4275055cdb173d4f205468f5c79c05fb0e2df3f8d185b3f86229  release/kernels/mload.log
8000e477b9a95dfb9f0af964e8346acb9d36f1358fd06ffc4ff7cf599d2b8868  release/kernels/mload.oracle.jsonl
487ce018908557f34bb05efc73716f7b1a8f472ee280f193ab81375e4ccc1f8a  release/kernels/mload.sv-hosted.log
ea99b33e1e8caeaf065613345d1c68759a00d3ad0820dd328c2df0adf17be9ae  release/kernels/mlp.by_instr.json.gz
edf9ab8ebaa92343d4c34f769fa8e652fa1d3c3469557f8db8dda86144314f15  release/kernels/mlp.by_unit.json.gz
fa560bf9bd386288984616514f3301db3de5626bb78cd85975c4379dfcaa7d6c  release/kernels/mlp.ccvtrace
663e5791fa4a2595c8c2d4dbd78a97c15bdc59d9aa4963acfac6e10ba521927e  release/kernels/mlp.log
138d282f88d56c8ad648a91af0a983254b55d9fa22942c00d47b327f516a6e44  release/kernels/mlp.oracle.jsonl
48571934948b046be12a6bc65264987c94d9d05113097f3f8f984fb0996b7c99  release/kernels/mlp.sv-hosted.log
f9ddc5e59b7d547682250481181d04a1494cd1d195eb9589bdaa26dab27d9f30  release/kernels/mwmiss.by_instr.json.gz
b7e69f676eb9044544ebe0342b415882925e53a0deb32f43d6983adc8996f6b1  release/kernels/mwmiss.by_unit.json.gz
72968f2e3116db34104c799396a03347daf62f241e626f6a1ee89cc493f433e9  release/kernels/mwmiss.ccvtrace
4495e1483809dbd02df4a66cf83a33963ab3438062664aeda37fbc12fcabd5c7  release/kernels/mwmiss.log
8abe8e8997456a2a6711ee72da54d854b24e20abbdab28e4b7271c0d28418de8  release/kernels/mwmiss.oracle.jsonl
d285addcff22adc1edfe2251f4e7f7e84ea98a9b084345f4f968b0c139c201bb  release/kernels/mwmiss.sv-hosted.log
9775814042a7c48ec4a6fa1fec63230f9b48e2f77ae46b75544869ebc4bece9c  release/kernels/narrowadd.by_instr.json.gz
99ffc2b99f0bf664b7f4ca1e730317ac33779c42be053c7ad3da802be75fa09e  release/kernels/narrowadd.by_unit.json.gz
eaba990031d661ae76dd290f0f3c794a7955c1fac7ddfa5928186094b8abd950  release/kernels/narrowadd.ccvtrace
2184ff8b5c34a5079d953ec22a0261e335af6fbdbee6a454b89916ff5d62c021  release/kernels/narrowadd.log
40a2cf629853dd404bb06b4a07e35abde3d12efc13f26ffe28f923daf2994574  release/kernels/narrowadd.oracle.jsonl
d3c7099bdebe9da21e0a7f86d05d2b77ad629271e79bf9bce1cc97d0892e3808  release/kernels/narrowadd.sv-hosted.log
27caf4403a79090e157d21abbbea45c07c82b19d56f8c4604aff23eb81a3ac2a  release/kernels/pguard.by_instr.json.gz
9c5397038aa037e843b2a6fd2e6e1b881a83615c52987feaea62dd85c2b17960  release/kernels/pguard.by_unit.json.gz
3b56006868b45f582561dccb435ba57ea8d800e4dcbebcac798bed592041dee0  release/kernels/pguard.ccvtrace
d78c48c368ed6b5d4cecb33d8b6bf4a849ddf729870a54f4f11e1932982af933  release/kernels/pguard.log
690e56f1cb8d97cbf67124b7dff3ad0a90cb8981814cd1709cf0cd0e035b3bd9  release/kernels/pguard.oracle.jsonl
00cbab9fa33f199b1f02fa317d321cdd0bdb24c5ea9dc7ed2288901163169968  release/kernels/pguard.sv-hosted.log
b67c94e39182da59d5623047940bcb570f422071f7024964ed648c26e2f9403f  release/kernels/plog.by_instr.json.gz
d861aa4b9d58e65c43d8a1651196bf8f866ec01ef56ab918178df05519f89962  release/kernels/plog.by_unit.json.gz
0cc33f3066dd4ae74b2296e7d22a3ce494836416ce6f69536758b97df8e156bf  release/kernels/plog.ccvtrace
950e21ab65d30856daf26671cf6bf7ac47b78552e17e8c1aa5c47e83eabc7b94  release/kernels/plog.log
0c99915e2da60f4670da00504a6371d7d17701d4431e733a3ff8fa98a2030d6a  release/kernels/plog.oracle.jsonl
e8140d6882e6ecc60db7b1089d50fa818cc5a8ed44fb2f5055807d7183dd82d4  release/kernels/plog.sv-hosted.log
8b83ae9a7ad8d11f685c5fe556267d1365cc5384c15cc26a76f4172b7bcfafed  release/kernels/pmovdiv.by_instr.json.gz
020b4f5c8f766816903347a7a55186b6b5f37b73c7cced04917ea821b495373b  release/kernels/pmovdiv.by_unit.json.gz
231a3dd81b74fa2103ab2345699f1f0e0f4e412e85827b5e835d5d1c952eb6ae  release/kernels/pmovdiv.ccvtrace
165329c19f2cd1b4682252353a170783f76de7b8ccd1edae6e2ba00ee80780db  release/kernels/pmovdiv.log
7bc646cff6166a51bdce03d7c1b7209e871f0a91d743083a9b910a80bcd0b33f  release/kernels/pmovdiv.oracle.jsonl
d77feda800c6cb7b0957f84ca47f7b6bdc5c55c57d2a482f8e8d28847e6e04ce  release/kernels/pmovdiv.sv-hosted.log
6e65c78e0129b441934c38de9da726b6ae66a5f6d1fcbc5ad23c2cef2c066175  release/kernels/predlane.by_instr.json.gz
3336867d6a108bfe2cae49a01595034ac595943774ca6bc020459cdd89083eb2  release/kernels/predlane.by_unit.json.gz
eb789d73b076373515f510599083b24f2501a0bd4e20bbd32f09b292b112c02d  release/kernels/predlane.ccvtrace
8c4a653f5294a203cf3b88e7da6b1eaa04ecd0faf3131afe7551db0e1d10289e  release/kernels/predlane.log
c45f4177b9e84fc8a6e36b13534a0c7636eb30a3f8531847100ce5e23bf404b1  release/kernels/predlane.oracle.jsonl
1cc416bbaa75ccdc2354068a077ea2b903f198f79f6fdeccc1866923a0c902d6  release/kernels/predlane.sv-hosted.log
08541ac7313d8490e19d23cccfb01feb4fe2ec1c546f4cf59d97f18fdd4d271d  release/kernels/predmerge.by_instr.json.gz
5826e9a0122af2ca3533624fe4d4826605d6768ef752d42587960a1e0ef9c2a9  release/kernels/predmerge.by_unit.json.gz
992d9ed5bc1841229c645570617d50962aaf497fbb55d502a1af8aab6dc39499  release/kernels/predmerge.ccvtrace
8f067d385cf0afab6e862f2a895b3405188d7a4cca304332b86c5b7960e58982  release/kernels/predmerge.log
6c737c49434bcd08e3e0814c8b1dbf15c586ae74f7929ba3148ddcee2c62c845  release/kernels/predmerge.oracle.jsonl
e0f4882eadb1692e296c6c2973ffe28d0f838a2795f130c2f2546e05fe770fb7  release/kernels/predmerge.sv-hosted.log
e39c0d97dd4c6acb7b8c296c744e8f28ecb20c141924ba3cf2b1807a35185190  release/kernels/predspill.by_instr.json.gz
dfd3da83a10ddfbea1360b9a2db32c4239b206e5768e06de55c3454116e0debe  release/kernels/predspill.by_unit.json.gz
92f4a10d221f22f74ceb7c73372973b49d10dfe6e1fdb646f84723de6004b45a  release/kernels/predspill.ccvtrace
e96494394e32dba75c3eb8f93ca5fb4743d861a8ef33c5ca4e96f4d2dfce016a  release/kernels/predspill.log
b7c84c6478117ffa0f06da0e6ad1e4628e2683426a7911080810e78e06a5242e  release/kernels/predspill.oracle.jsonl
1f6bd5bcfe73ec13ced5241a3c078f2c33591eba3e80db49633f61b83b79befd  release/kernels/predspill.sv-hosted.log
ce56f32150d2c2dac7ae3722386f3f10dcd22a290821ed1641f47e1dd117540e  release/kernels/predswap.by_instr.json.gz
df4bee2385fddd110e3d9c98b32a6359d5aabe3aa2b43ab8b9f68db1b13eb79b  release/kernels/predswap.by_unit.json.gz
f793d03da341396628fefdbbe49d9e5ed50de9cb68b64b7c74b5bf0fd183925e  release/kernels/predswap.ccvtrace
253ff10981635ad5684e9ef9818f3d383312e940e65cb6477edfc9002b9b5be5  release/kernels/predswap.log
a6d4f7ed517553816d889c7c9eeb6bcfd1f6c973fbf682ecb69f3c2de619f7bb  release/kernels/predswap.oracle.jsonl
437815edb6860abd63224b7ba7dcdc6bb4f2c855cf09539fd16f35b524d56202  release/kernels/predswap.sv-hosted.log
7984fab26d460b3924ed822acad60bd276e641a5a8c047f88d8fc2de830b10a3  release/kernels/privwin.by_instr.json.gz
5a0811651c2816dd1cb99a9b856632b54d0710626cdba626b736d6619200b4bc  release/kernels/privwin.by_unit.json.gz
325bce511eb4675b8e5bd663900b9a72dbd36c66caebd7a33c5d8ce939241e87  release/kernels/privwin.ccvtrace
c5df1f91d99233fca8df94ade4f20dda846e5658fb5fe8897f8a41d60e086b39  release/kernels/privwin.log
861f686fc4480363472908d679d8815e8c957d768e7ab32c826930527b0fb7a8  release/kernels/privwin.oracle.jsonl
2dbfe1f3f54ed2de722f5c68052ae9586c0065dc80be9305c0c99dfd5388d059  release/kernels/privwin.sv-hosted.log
72d9ce91d08546d9345b24f27ed1ab345c7e726fe7a32c0c47f3e85b6d62a334  release/kernels/provswap.by_instr.json.gz
dc430025c604171dbcc084b016e9f2b8dcddc8a98c38b4f52e94562d7a180e64  release/kernels/provswap.by_unit.json.gz
0fec44b3b5cb0562290746e2d1014c88182c6a33b0dc84b07f704fbc7dc2aa46  release/kernels/provswap.ccvtrace
0ccca9556ddb76b513877830f163d0a225dc04ea17d3832eaffacc29e8ad73a1  release/kernels/provswap.log
c9c32a793d54cc7401477f582487f7e8b345b2669a75337b8d6327120d98e5dc  release/kernels/provswap.oracle.jsonl
aec7025e872871f5ccf02b34a3e012b73fe3036fc962b88da7f283d973894dc5  release/kernels/provswap.sv-hosted.log
379ff11726c4947d42f505515c21af375c66820729f50047a5c57e519b7d6798  release/kernels/retmiss.by_instr.json.gz
4811eeb216b110d6e70c9befd593cfabfa2c4c0ed7a01882e1b05e37374b1224  release/kernels/retmiss.by_unit.json.gz
a94b952d7ddf4182c6bddd62106ee6e7d5afd002a8c763335f5d4120dacbb931  release/kernels/retmiss.ccvtrace
745020f73edb3b989781696be4734528346e677e484a36702ed84a5ca2bca571  release/kernels/retmiss.log
e5ef8538e838c6cff7febfc679dd091cf5e002f82d34f1009b1948ce22bc3649  release/kernels/retmiss.oracle.jsonl
ed58359a7b62b06bee9d248418c414ac94e83d064303cb1640e984ef46a44e3c  release/kernels/retmiss.sv-hosted.log
c5ff1730f30873e277e5d962073b2f8a2ea8e82cbf83d046b24cb75b68797210  release/kernels/roconst.by_instr.json
aff2f6ba374c4b2edc0b4b13d953a14148d131286d30cc55dea555cb22b1b61e  release/kernels/roconst.by_unit.json
24e16ea5a89c0da7406ac67010ed1e91278e7e70007de5fd3c5e0e848c30ca5a  release/kernels/roconst.ccvtrace
494fc327cd7db4bbda75ead1a960b5cc2c6390a9eb632c53d924434c0ef4f183  release/kernels/roconst.log
8087c0671de620162881aecd38cd6114b78e7be6bd71201e3ec02c9a2e2e750e  release/kernels/roconst.oracle.jsonl
99ad2f33e1569c2887b7223733fdc3bf074e8f572934f7ec11dc6d9c3691f884  release/kernels/roconst.sv-hosted.log
8a379537853667bb0ec4c1843eee518dc465010710d108f3e114d66d4c6cfb3e  release/kernels/rogated.by_instr.json
34acc428fb482de390ab0827e633cc0d75a230738ec05422151f95d96d3ae784  release/kernels/rogated.by_unit.json.gz
631b1ab4d97f56e9c4e84621330223c13a652a9ba99663e4543231ef82086049  release/kernels/rogated.ccvtrace
967b63b0779565534ed14849e12e764c85fa1d5d58327962314628713d519d91  release/kernels/rogated.log
7cd02bd4cceec5a044d6b4d6a80df1e68ed0ae71b0b2a953143636d5b809ea6c  release/kernels/rogated.oracle.jsonl
fcda50278ce68c33658da946cc89f55bc16d9098866239e274dd689056fc9352  release/kernels/rogated.sv-hosted.log
e267a46d443f511c71220e1cb22e37a6daaefdba58b8be9afb7bc1aca752dc4c  release/kernels/rokill.by_instr.json.gz
85249dec7ff1610a44a60bb56faa95088292d472ec2abac4ee77bf7e0cbbe4ee  release/kernels/rokill.by_unit.json.gz
55f1d311748482da87a37d632ef2903bd8d8cbb08eaf1fa08128d9d4b4fc6657  release/kernels/rokill.ccvtrace
0a224446371827af3aa6e2a2ff7bc3015355c20c5b05026f0fe7d9491095620d  release/kernels/rokill.log
94efcef96af469a512d346ce61623980fe86383188eaebd55120f716db596f14  release/kernels/rokill.oracle.jsonl
5713e1d3a903079e53eb375e62d87d0c7764e2e7131f3a4eb5341fafc9433d1b  release/kernels/rokill.sv-hosted.log
4ce3274ce40204c6adc0e06032de0b5f3a9af30d7eb9f93cd6a4341e23a1ba5c  release/kernels/rolaunch.by_instr.json
32a781755aabdaf1378a6e47b5d441c07dbeae5411b40e2456cddab84c3d9377  release/kernels/rolaunch.by_unit.json
c9423aa368141c32db86d8f3699fc646239c555b49d5d1a4c2e3e8b3042c37e1  release/kernels/rolaunch.ccvtrace
815a52d7fef6048024bb21899b0c6bfa2f645b3324c929f7e39485deda041c84  release/kernels/rolaunch.log
e7dad585c3e70615de04330fd03f4f282c29a005dc1732a35655fb261d51139e  release/kernels/rolaunch.oracle.jsonl
aca56a9b5d90dba8f6bdf1409e04476200d23731d6418a99e0b6fe5cf0cd46a2  release/kernels/rolaunch.sv-hosted.log
c5ff1730f30873e277e5d962073b2f8a2ea8e82cbf83d046b24cb75b68797210  release/kernels/rolimit.by_instr.json
43430520f2f8de48bd6a6b0c767269a2ca31c6f08350cf47cc0beb21e8cb2eed  release/kernels/rolimit.by_unit.json
da82ea8ac380b275123303019058883c223ccdb993176d9f14ffa9730f395f89  release/kernels/rolimit.ccvtrace
e0fe2aef239b29aa5c5a9beab75d32011361fe49e69b6efe59169eed5c4b061c  release/kernels/rolimit.log
1c5bc0cb8e8b2e69505fb5a551a16d5d10c56f232b88da7a27e336ad7d962de2  release/kernels/rolimit.oracle.jsonl
ac09561a27be10f7e4a02edd2e11c39b4f34d7d34179f7208059eacaa6b51503  release/kernels/rolimit.sv-hosted.log
82c86f649e52e0f5d5a4b062877dcf12770a4c5da9afcbcf68a729cf986e5fb0  release/kernels/roload.by_instr.json.gz
6e1938f30d1cf4c4216c2978d3eac339ff25f120a2a782c2d4731e3ee374fc20  release/kernels/roload.by_unit.json.gz
9db58d0519c28e63306793107831abcac7824ecabeef0820a22e280b39799cd1  release/kernels/roload.ccvtrace
3e8adaeaab7710c41cc0cbee77cd72198bbc26b2d187bf70cbc2f17d635dfc25  release/kernels/roload.log
f7c1309cc9764769fb5803f6fd0f2f5e1eb418f2d23fbe5e17cf5f9106869fdf  release/kernels/roload.oracle.jsonl
e410ca92a61389fd06dff8de4880f99cba0828b5acd6cb9dfc0ad6d8f2e615bc  release/kernels/roload.sv-hosted.log
7d7703ea5bea8c2af79bbb7346c783aeef84a854e7aa9dc57fefec89a5246287  release/kernels/rope.by_instr.json.gz
a0e6e239620a9739531a0af038ea6a948826948ac26445435084b1138febfbae  release/kernels/rope.by_unit.json.gz
1a9e2f663f827ca30a249aa74cdf970c81348d8ed41c1a9499bc8573ec861b6a  release/kernels/rope.ccvtrace
bed846f2d8b5551840fdd0d9a83995feb63ea64b60a892f6a2bef1ffa41d0512  release/kernels/rope.log
d55f9efae392dc8877c102c01c0810e7654b666b6ede386328108164c6cf88f3  release/kernels/rope.oracle.jsonl
6a5c39b5c46b74e171ce5e7e6c21de7aa5a5512132086c5694981b4b0c1c5c03  release/kernels/rope.sv-hosted.log
6114092aae60800028bfb4770d1fac787687279641b9226815c7bb8dddd28e45  release/kernels/ropediv.by_instr.json.gz
dfa332a99cb8e628818ac29fc6be17ee350c5082cd413adffa7d711e21b67d56  release/kernels/ropediv.by_unit.json.gz
e0f90b60cb5893cc5e9839a74708848bc8b5409e2af972fca5b128129a3c2614  release/kernels/ropediv.ccvtrace
b14725c2f548caa6cb4fdd5b44469f1a7b022967f180f528421f43036d91fcab  release/kernels/ropediv.log
10c0ec6ec18b7b44638c790033109198c079d07c1537bf193353ccedd00a920f  release/kernels/ropediv.oracle.jsonl
995e08bbf1f932bb36f3beefdca0c3d71b1b0c6623a9ee964eda957145ddf030  release/kernels/ropediv.sv-hosted.log
3f023f89ea428a383286e6cdda6638e811742b5e4633a44cd4878ea560f9cd8c  release/kernels/sel.by_instr.json.gz
2547aefa8ed9a230f5cd1ceca635078a3acd0040bef47e3296dc80d8ceb2b22e  release/kernels/sel.by_unit.json.gz
688c1614887034251601256381778a5d9009dc4bed01e11890a584f2cfaaf665  release/kernels/sel.ccvtrace
5020df1161245c5960188582d1d73b4580faaeb7bd6fe2e7900aaddf2d45d8df  release/kernels/sel.log
87f6a81e8afa004c8039bf2f61c90176fcf29ab29bb17ac44aa016a5cc8438fe  release/kernels/sel.oracle.jsonl
6475a1fb2f7af6178bdb1f028199db390727db26cd366510c0e141fbe0d7c252  release/kernels/sel.sv-hosted.log
5b240f9ab77539bbdd8185e297c603366778278417b3ba1e152d1dc17fdce220  release/kernels/sized.by_instr.json.gz
ac359baa9e0e1e2ac1077c95728b9c8a6b40c50322c9ce2fb6e0616760eaad0b  release/kernels/sized.by_unit.json.gz
1f80ee055c71f4da0b1411cd91f6b849d72a032b87e76f6d9b448fc37e51b495  release/kernels/sized.ccvtrace
63f95636d5d4c0425862898cffb0b89812d2105c0d6bec2db19f6b3468c7237b  release/kernels/sized.log
36d903ba1618bd1faa437c9812a6ee6c0c966a63196c796267d74bf2695ebc3d  release/kernels/sized.oracle.jsonl
4e6bac00f93a4d098180544e4b4006f702a09e4e8b5e4041d8c9cc158fb55eae  release/kernels/sized.sv-hosted.log
ad90805347ba53120bac6babb1b41425822c72d10bf573f9016ea672924df706  release/kernels/slotform.by_instr.json.gz
c3daf14dea1ea8e02eab08dfa0ffbe7d9c484fd26879ed5b9e46074100f29b21  release/kernels/slotform.by_unit.json.gz
f93d62ae47498b83f4d72cb6de0cd18792372a17deb2fc2de7e5244c075f1e89  release/kernels/slotform.ccvtrace
1f79c19db62bb0c0f9eef1d7e97e2eb1a5fe780391d71e42f62c56982c546a63  release/kernels/slotform.log
8b61db7419b18cea8a646fb628218447e72e84a18a9891ffb73b441736138ab9  release/kernels/slotform.oracle.jsonl
7b54b5d9959df5d904c1bae3e25808aa45f517c49de8371eaa80ed66f591de20  release/kernels/slotform.sv-hosted.log
68534f50c28a8af8833a1e36df48bc275f29df5469cc43395fbeea00c53f55e4  release/kernels/spinwait.by_instr.json.gz
a082e2aed07f4345d2a8e5c6e63ddbfa9258953df654eed8cdd91fd11f60fbd3  release/kernels/spinwait.by_unit.json.gz
3961613ec80a3fbc0f5a67f9ba71fd78ed20ed0c29180ab124e8ff6aa8e0e5ea  release/kernels/spinwait.ccvtrace
65130011661c53771d8073cd3c89a6bb63bb29883971f906c17fc2135184bdd1  release/kernels/spinwait.log
868920637236c878b33779bd450439466fc3626996a3164573dc11d437d5c709  release/kernels/spinwait.oracle.jsonl
e1f6e07afd011a905185df5c29bb9a006be3efe7a1c15faed1861cbf4bb1f310  release/kernels/spinwait.sv-hosted.log
e677f9c8f0ac1c319b533db2c093686f1a0efad765c978d85238b2b23942c12b  release/kernels/spmbank.by_instr.json.gz
5f13913e781e7d994ba14adc9a5058db2940c42d7d2a91542908b2a461537e7f  release/kernels/spmbank.by_unit.json.gz
b41fbea616795bbf29c9e5a4fe7149db44bf3ded02d7a7358c49516a5bf360c1  release/kernels/spmbank.ccvtrace
4546faaf18deb38edf8b0645a03b1bfb927d2a82fec857f975035486fd49ee91  release/kernels/spmbank.log
3af490cc37d7a92dbe719b57de216b648536eb301ff9d13de9a39f50d150d725  release/kernels/spmbank.oracle.jsonl
82f62d71dabbbee837b1812137751813d2d5dacc44bb9cadcf678b808eb1764c  release/kernels/spmbank.sv-hosted.log
1e3b8ffc44ac0aab6ed314745c931a23d080ace4e1dd8ecc9758a07c5012ec34  release/kernels/srd.by_instr.json.gz
439fca42a45f4cf0b85ca5153d155b4d73bf999fb6a159aa1c09ddfff2d07521  release/kernels/srd.by_unit.json.gz
95badb026ccf14f957d3f0590ff6b6d3e65a1e3529a41b23e4826ee4473679f4  release/kernels/srd.ccvtrace
e4c2a3098a0a7ac41c6a3c9cf643e1b947dfbeaa12a8a55f779ec0165e9ff8b9  release/kernels/srd.log
b08eb5e3673cac7eebb8b72af5ed3783c8e70a9e96592e76bf3722551bc79473  release/kernels/srd.oracle.jsonl
851bb1703582573535adc9dd7ff06a113105a3b8c30815a8230e11b37c09781f  release/kernels/srd.sv-hosted.log
2fe5188a58ec4323c52473b06423c99e20c21e30c965595cef24014f236db8ba  release/kernels/stall.by_instr.json.gz
94b7c3bf0733e87220327ef05e3afbe3c990db3f28c8a2ec5eb828606ac4c8c2  release/kernels/stall.by_unit.json.gz
34f78c0c08b929b8c250af4c5aa11d6fd5e810a7d837af1098d0e45a41aad0d1  release/kernels/stall.ccvtrace
51d1fc31172956fbbcfa61cac85819c6f71c4214bca5f7bda9358d14809295e1  release/kernels/stall.log
500db2c482b07a0706583422cd68878301d0146c1f872ccc1f11bfdcf5c993ef  release/kernels/stall.oracle.jsonl
8c12a03c5f0dab5ffd7c73fdbb474da24ba1dfdfc62c95e4b6cb78223f3d9800  release/kernels/stall.sv-hosted.log
dbbf1e2f6be1876dd470d9212059bb18bdd6a2daf7e058ec550d2569beb4e35c  release/kernels/swap.by_instr.json.gz
25c03d6de36b6edc950aadefa0cc2b13fafa488adcb0833d929b574d01b5b490  release/kernels/swap.by_unit.json.gz
892028773069382947669a8565e89ad81350b28f6e8861ba3b60e0babc696519  release/kernels/swap.ccvtrace
39aa781f6e8deef7e28a814007e1dbf2ef7fe429494665ab1ec14b27beeeb96b  release/kernels/swap.log
3658a26316c1ff7bc1744304a42f736e930fcde2865c8913e6cc67a22ce96667  release/kernels/swap.oracle.jsonl
9ee7343e9f41a1d8419d1986dbb3bacaf630655d00228c84abe65956c19e711e  release/kernels/swap.sv-hosted.log
4199f09063fcd1830fdf42b7de9b364a3f6c9cf3064fe5c061a2cd62f0f63905  release/kernels/transp4.by_instr.json.gz
aa231b36fead585ba00ba05fa95372c35124d10231a740d87a29a18d49570e43  release/kernels/transp4.by_unit.json.gz
9c9f7435ce6e77777f6a8ab434e91b737f9a2ba7ebb3638dca45840e9251af08  release/kernels/transp4.ccvtrace
e01552b32817b0d63f545b48dd079cc66f0ed0dcc40d1f5e2f8f44c306131244  release/kernels/transp4.log
06396ace3ac19677fd39c700e408606e5bdbacb24997d663bbe8872e63dd74fc  release/kernels/transp4.oracle.jsonl
16d32aa4a01c14464df25d9f1f4feacb272838c7d73ddd0c1774ebb5aa5bfea4  release/kernels/transp4.sv-hosted.log
2a2947b2bf49cdc7b2b429cf437ca343a4195e0f2db4485f35efea719a1106d8  release/kernels/unal.by_instr.json.gz
9d166b9dbc94efc739ae0e9439fd42ffdf26226b73ca84b97be62c7f762c579a  release/kernels/unal.by_unit.json.gz
1b3b224b0cca3352113bed47b586be34cf167a632ec031dfb10da1d35f0aed73  release/kernels/unal.ccvtrace
77e80513a79f1c7b20a6006c87b3fd770f00670e027195a964383123beb004c5  release/kernels/unal.log
c3d484bb160657a563df983d9a2532eac27f556636617960aa1e72183ac2b299  release/kernels/unal.oracle.jsonl
1fd690ffae543aafbbf034eac6d2f1930bac6ba60632ad8905bf33d8d692a9cf  release/kernels/unal.sv-hosted.log
6f16571614c68771c8e06b92b68143a278fda275f1ed5f452089ef74a9fa2b28  release/kernels/vadd.by_instr.json.gz
8770f89f6f32cc89d856799c8d2507706e5a9ef127c6cd902aec51a815065ff8  release/kernels/vadd.by_unit.json.gz
0d57e0309bcd01a4cf1a43b5a5da28010c962d44c0d5fb2046cfddbd736f81ae  release/kernels/vadd.ccvtrace
dae5bc48b1509c91e324b4bcb79e9a7c9ce3b348b9d6450fe1a5bcd7f4c47cdc  release/kernels/vadd.log
0276b6d0611a4bbcdc004ab3987214aea138245bc7217504147331689a9c0880  release/kernels/vadd.oracle.jsonl
baed4642bbc351b1db22f17ee8c3daddb4fe9d53304423e1f5098932c5975d95  release/kernels/vadd.sv-hosted.log
f0f1fcb339ff8d4dc2bf2361f11701d114b38ad5ca783f4cf4c98d569e736bc7  release/kernels/vadd4.by_instr.json.gz
74ea3bab72bd705b043326f3cbb75b62b5c4e62dc6c3df671260de305a5d5718  release/kernels/vadd4.by_unit.json.gz
3fdfa61b755ca9388dce7259081cda7ad6559ac7394e1956261e72504e3ba118  release/kernels/vadd4.ccvtrace
420872d019327f5b0a3db4f84d73fb02d153f8b1de5b754e771d75a62261af14  release/kernels/vadd4.log
225aa18fc9f38aa9ad615aa11de254337d59fa705877553d873062c68366e0db  release/kernels/vadd4.oracle.jsonl
b49a54e5d762972ba051fe10542b44e43ec109f40f0a4a08894cb5e0f19cb32a  release/kernels/vadd4.sv-hosted.log
e25a45b9294bd4932d4a1aea3758d22ec62bff9a563a26b70dbe3ddb48918a71  release/kernels/vaddslow.by_instr.json.gz
564c7b106afc4ab30f47faea84f55ad59d3e82eedc4c7e8e5748e43ac9fbd82c  release/kernels/vaddslow.by_unit.json.gz
324681a8412fa64ad998c3cb9eba5313ac695459354299dd5947c322f0c80321  release/kernels/vaddslow.ccvtrace
99ff1bd7c07c011552c0503b940b3957c35c15338ca9260650cc3cbc20dd309f  release/kernels/vaddslow.log
e9e6218e8b8450e9f9ff6b39d659c994a1e51c527a0c5bd10d18b5658ae0e344  release/kernels/vaddslow.oracle.jsonl
583b05a34857a3502dcfc189119cc15cb84517094a5c369618fd083798c7133e  release/kernels/vaddslow.sv-hosted.log
056057299fd50805b037e3d3f444614914097e738c482c0022fe39e65e8b26cc  release/verify.log
56b3d8627d79d397ca06dfb57060015391cb95e52e925d1f09a4b2a7f4147127  release/wiring.txt
```
