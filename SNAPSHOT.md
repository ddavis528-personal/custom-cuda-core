# Snapshot snapshot-2026-11-10-6c094c2

**A generated, read-only snapshot. Do not edit or merge it.** The source
is `ccr-9eb50716-lecnjf` at `6c094c2886bd9449557934780903d067ddf4bfcc`, and this branch is rebuilt from source by
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
| Source | `ccr-9eb50716-lecnjf` @ `6c094c2886bd9449557934780903d067ddf4bfcc` |
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
f348a27c266f51fca866ba39346f08430cf6e0eabc46562f6e67fc7fff28d13f  release/kernels/addrhigh.by_instr.json.gz
fb91c9f2673b525e81d6dd4ecc0706f108fbcae5bf1f9cb612c42f9f406fdf51  release/kernels/addrhigh.by_unit.json.gz
26024c086b98c667eb6ff4ab07d9bb2b407953b72a2433e8bb2a0d0f590cfc08  release/kernels/addrhigh.ccvtrace
27240e2037e268e0eb06b1d826d900fa924c27faf55adf36860aeb04bdc1cea0  release/kernels/addrhigh.log
569f2e22883fad5f0956c57ec734e6afbdd4b8a854e50277425172d6c0cbd766  release/kernels/addrhigh.oracle.jsonl
e477c8063c7adb3c3786d25c7ba18174b9d3271dec7f9da388f7292f3581c15a  release/kernels/addrhigh.sv-hosted.log
c9699bdd745f08f65a2b611666d16b99a9232b78dfd4047c87adf2e373d85361  release/kernels/addrlimit.by_instr.json
300c1f4f04a25ce5cbf865a1665ee1fdced9355099dd4fe1a776970da3820ebe  release/kernels/addrlimit.by_unit.json
646dd11cf7744b4941083731a2cb0a8ce7b94cbdf53f708cf2adef6ad684a061  release/kernels/addrlimit.ccvtrace
9cf9efd6482b990e089b34bf8b39a7821f8f46d28f9c16a407bb8daf6339f60d  release/kernels/addrlimit.log
bc660b0b40359a2c5a2478cb0eb4950b73fd22db50ea76b80052bc195a1920f4  release/kernels/addrlimit.oracle.jsonl
f0b3868e21129d3b9ee32760a3c7e176bcd48637a05099e9c9b5bdc7809f7c6a  release/kernels/addrlimit.sv-hosted.log
b879f56d333c5039bb7f282658f0ca09589d2fe56531c13b684dd0893a4c9163  release/kernels/addrneg.by_instr.json
fec1fb96615feb68f26d8db7ed553f19cef1691f96dfc97666b271b4cfcaaeb4  release/kernels/addrneg.by_unit.json
401cb1b720323c75cebe1be95fb7e9736f1a40d7f0d02a7651c85f92e387bb9f  release/kernels/addrneg.ccvtrace
1e13c092179509033a5cd30bff752dd977913c9cec73d53baf24c1ed303149c9  release/kernels/addrneg.log
16f5b0707ae44492a1efd67bb9dd38a7e79a7bbd354fa9207b9e7d150ff2f107  release/kernels/addrneg.oracle.jsonl
bc812b22b813c1246e782b6d666f43ea8e9bb56fabf707ceaf9396a558f0c981  release/kernels/addrneg.sv-hosted.log
a4ef6809b3894d9d4c91c85bd6d24949e39be2bd9ee038057ee2deddbc988989  release/kernels/atom.by_instr.json.gz
a04be797b3643bbf9164b6a72fda4a76d6f59db1257351ef4593b65c003c3dfe  release/kernels/atom.by_unit.json.gz
1ad23250d393836aac4caa0748ad25772082b017a2700dc9d43196ddd46030fb  release/kernels/atom.ccvtrace
2bba398ae8c90e1b42560318118d1b69e92904b17fe91cdc57cfeaffcb0f6ee0  release/kernels/atom.log
504f5b6e9d25114dc35f2c70b21bb7b3f3c508c691de12dc0e87d12a74285361  release/kernels/atom.oracle.jsonl
539abdd6d19817d287c53368eec0db7e2a869d37c4a0c6309bb1ed7c1c7a4b45  release/kernels/atom.sv-hosted.log
8a0fcd184b29ccba571c49bd3d87349a29d296ae4b3cc97f881890fa04ef06d8  release/kernels/atomf.by_instr.json.gz
93cd2eae6131d6426df9b5bf9b7280b1ae48835de048d0263609440290725c70  release/kernels/atomf.by_unit.json.gz
ead6946f45250c234003b3c3d18a61765b5136bb5ca9bce30fc4e1b68403f586  release/kernels/atomf.ccvtrace
977980468bb913164283628fa958797c01953312a70ecb48024fea550c7191a0  release/kernels/atomf.log
cfd1179edf4061a33ab2f75d7a6dec61decfe629000198189a7bfc2647b34238  release/kernels/atomf.oracle.jsonl
daec9f2b8c8ba46ec517767409af44b90647413cae2bb7c04920668a27983aca  release/kernels/atomf.sv-hosted.log
0b11a18f91264f6047661bfa6ff5dc5048a73a91a67c3ddc463be2000f7122e0  release/kernels/borrow.by_instr.json.gz
82b6b06bd75b4545e835cb32823b6c66642b8ccfda552a67f3cec50f94da1744  release/kernels/borrow.by_unit.json.gz
8eee0c50216f1eef61b0098241e98cee6f7c406c05849d0c1a4a2be835a5cfa5  release/kernels/borrow.ccvtrace
4786fdc81633a7e164dbd794685e0d722bd11c6cc913ab97d20ceefe74c70f87  release/kernels/borrow.log
4c565e1ce0b3baee36e158694b32c8defb5cd662b2f9af75cb5d8c26cb1168ed  release/kernels/borrow.oracle.jsonl
4b19ea5bba52489dea1a9d0632dad6f8546fb6b0cbc533e6ebb4d17e209767bb  release/kernels/borrow.sv-hosted.log
1a6e15503a3d68e9b72fe95f491389f070cb6dcf98483de0356579f0a4847712  release/kernels/brs.by_instr.json.gz
c654193062ec1220b2a563317c852cf9a7de882d6558c46448e7f50229376366  release/kernels/brs.by_unit.json.gz
88a57ff042363bd7048526f4c13a55eefd7eaa18be159b61f466819827d06d8a  release/kernels/brs.ccvtrace
a19bd76fb1181d09b31c61f7135684ff2af7747979e2a8760d8281eefcb55323  release/kernels/brs.log
e3c1cb3379580cf1aae44e8ddc8e846ef6fd661a573cfe0a8d4444b18a14dc56  release/kernels/brs.oracle.jsonl
47d3e868d06e81a9735672fb8c2d8c96ed7119a9a877f1bc752b190a77e37245  release/kernels/brs.sv-hosted.log
692d850b216103fe03d71366f480b4394c80ce5dc1ed5fc1a147efe990195ad0  release/kernels/byp.by_instr.json.gz
1986da02fae3f5eae5179ebea822545132a448e361c041f335dc212f217d553b  release/kernels/byp.by_unit.json.gz
8a572315c9d52778bafa71f96e4423500137a20efb80bc35014ecfb631f91125  release/kernels/byp.ccvtrace
b8467b758102880af68fda8812b0ff4d28f5a0384fba734ed5dd2de4e8433771  release/kernels/byp.log
5a03dfa4f3603fef49f1e3639e74e34152ca3ca5ef8e41eb959f8323040fa2d5  release/kernels/byp.oracle.jsonl
4c585195a8589336fac154c7c45d5f7ddcf0bc9758b5fee522aaa1d45fd19eb2  release/kernels/byp.sv-hosted.log
27d9f9f87bb560512096e2922f17362dc814506395a70fa41483d122ce4a802d  release/kernels/callret.by_instr.json.gz
c49df064859eb2b2dfd7385f61270339f2e719f38aa130333050c7294a28b9b8  release/kernels/callret.by_unit.json.gz
046e92fbd4ca386af15041fe2d714aa45c58fd1cbd6562b55c7f53d80fcd82b3  release/kernels/callret.ccvtrace
a9a9771e1f6004b107c82c5d53e813b95b0bb95146a88e0c7e50cc8d715a0a49  release/kernels/callret.log
9b1d1b50b527f732362f837250aa2f26dabf3e76e16a4794856ebd8f105635b8  release/kernels/callret.oracle.jsonl
fd5ab2efa600b3808e2e78a91359c166340bd648027ed1dd13fbfe590a34b1dc  release/kernels/callret.sv-hosted.log
b121ae9389cf9192414c4a2616f5c64d6335e139ff397c81c8545184486fc0a3  release/kernels/cas.by_instr.json.gz
ba89eea4336a8bb657e0e7657da6347222009cc9031ca438b8e633d33bab162d  release/kernels/cas.by_unit.json.gz
2f8710781ba48bbf53e054ee39b2acd2423bf9f26797f034ed2cb18d10a58fe6  release/kernels/cas.ccvtrace
f9ed36c4ac7797a4635793f89c44910f7f2b63a9a3d491e6a03cee8459a5d051  release/kernels/cas.log
0ab31a9443336fe5d08e1a5fa5fcba3bc279b19022f7c5007908d39d8ef39536  release/kernels/cas.oracle.jsonl
25d618a1da3f03c7433c940d752a47d2bdb3419b3a27a7bb757bcdcd4dfaade7  release/kernels/cas.sv-hosted.log
a46343e5e30ba888cc3fe8559f4da0a6a872f4549200bb6991532acdca7cf0d9  release/kernels/chains.by_instr.json.gz
cb7ec7d9dca4db170d77d39817cb3a26b3112f2a4785eb28efe8bd26b0570588  release/kernels/chains.by_unit.json.gz
6e0d095321f97cf86811fb152219d5b6a4e887fc54ad1f4fd5e559f32145cf64  release/kernels/chains.ccvtrace
17038086c82eede07c9b11c8984a145cc6c6151e5280902f9ade357e56901816  release/kernels/chains.log
26a4cc5c5524c7219d8706c2582c80357dea60be9d6ffdec99dac7d0365e2264  release/kernels/chains.oracle.jsonl
ff9ba089e45af63c879ae8979a86154c25593d7224d2501ba63509c1d2794d08  release/kernels/chains.sv-hosted.log
ec3891363eadfbac6602771383fb46bf126ee17496edc634610d65a0ac8a383f  release/kernels/coll.by_instr.json.gz
dae4f1a503313834e36a60760951c964498cfbdd66a45e83de538cc6f826de41  release/kernels/coll.by_unit.json.gz
3762b3824dc9a96c20d7dc82947e7bf8e6b1dd318f73c9bdeca10d8f86d9944d  release/kernels/coll.ccvtrace
0e6a0ad8c11fde3f73a7a9336deff59f1c647ac0a8c0c4f3664f642d2aade93b  release/kernels/coll.log
dd718d23c88df5dc7d92b055d8542865aa0e029118486af127312a8a578cfcbc  release/kernels/coll.oracle.jsonl
ae9c09b583c5e2bf48f606b4a1e86eb7e0fa92fa2d24e4be160d61612874dddc  release/kernels/coll.sv-hosted.log
8c5b0143453bb1d9822347d8a4e3145cc2584a84dacaa346867413e8985e0e23  release/kernels/div.by_instr.json.gz
e0aa22ac321cf623bdafedbe9d8a4692a605547c47c0849301bf74f92ba1c4df  release/kernels/div.by_unit.json.gz
afa661d89a3f00449cb5bda98fedabd73fae73279bf3192ce9eb9f55c9bb6ea1  release/kernels/div.ccvtrace
a4462adfc79ec3d45f8b1110d29ba7ec90563d91eaa481c4e653ace4e5b06acf  release/kernels/div.log
71a567b85cf85622631490187563de9a5661099c78a590adff4ed0a0c3d24c16  release/kernels/div.oracle.jsonl
1e5bb6247c13a90ee7ebd28859754e922d450e9a16d7578bf8496a2833533646  release/kernels/div.sv-hosted.log
17e358444dcc5c149afbc99a4d1fc21c371dc9f79c65070164a2940809f94d5c  release/kernels/divchw.by_instr.json.gz
2742ae1e7235e291dee8b0151f3074bc8c38bf35e8f56f0b02126bc94f6e106b  release/kernels/divchw.by_unit.json.gz
9ce148460eb5a8d5b7a5a9e3515e0312f4506c687a04798281130666885620e4  release/kernels/divchw.ccvtrace
ec3288779cf35de1931359664969c8760225430b8998588f3fec4f283399689a  release/kernels/divchw.log
58a541797f7a2df0a1c7528ae6a3edec212db90c7d3eb20656806f38b5c10b3d  release/kernels/divchw.oracle.jsonl
b0f5ffbd7e193afa91e89461548eb0591a15d223ed5f7a04efbe497c14633bb6  release/kernels/divchw.sv-hosted.log
15a7f9d5c31597bd0d1487e5de45f9dfdfd2edc043f7e9d24e176c650e96fb7c  release/kernels/divtail.by_instr.json.gz
5af0190bcbccc912fa18e1e053b7ec289358dde22ad8a778cb3bc7a572bbd9c5  release/kernels/divtail.by_unit.json.gz
423d1be0830b8eb1f8dcb237ab56f5a611e27b4c61b3b14452a4cc5bece0d65b  release/kernels/divtail.ccvtrace
efcbc091c0052371a944535e887d9d2eaf262e919351fb7cd64cd12abceab439  release/kernels/divtail.log
75f11a75c9b3b336e446140af4579f05b46c363a76b7aab3ec88154a07ba097d  release/kernels/divtail.oracle.jsonl
153f9ef92c440f853a5b7d94cd5d3d5d3a157d389a312f1c136c9809c740ef08  release/kernels/divtail.sv-hosted.log
87fa9d7b22d339fc5351c3fea8d35435df9299efe602908357227efb0d46814a  release/kernels/divtail2.by_instr.json.gz
f51886af790ff9a0b656cfc5ad92f18215343dbdfbee14d35bf8c53a19eabd71  release/kernels/divtail2.by_unit.json.gz
7318a5b63e5a0376137977677b7bfd8830283bfac1c9e4d2d3fbe8af9a4ee8ff  release/kernels/divtail2.ccvtrace
e79718018ddc531b9d42364bf06628a117dab83f08c2920bf4e7cec446b5720a  release/kernels/divtail2.log
b2db6b05eb6cf4a0a7677e31d0c6c2952d5cab49d353f0bb1883fe0b2a20ed14  release/kernels/divtail2.oracle.jsonl
3a5e769cd740345f29cf1f1400eee41af6ddbb8d019c982d62c3d8325ec36404  release/kernels/divtail2.sv-hosted.log
6b88b23d84714fd1ff7da47e6c5662c87e3e54b35a835d57d1d54d08b5f0df34  release/kernels/fence.by_instr.json
c74f7828181bfefc675af70b337f049390d68449a09a662a010cb0746f8a0d80  release/kernels/fence.by_unit.json.gz
851b82839626dd37b6325743a29c7a07ad5deb97a52fc9f9278827cb0255b8a4  release/kernels/fence.ccvtrace
4fb3b513ac3706d718bee29502d215d5d252a9bfc51e742dc47431201dea0f46  release/kernels/fence.log
d1d40317f6cf5bfb430cda1f9c0ef676609e59cabe2a11623c42ffbeca93142b  release/kernels/fence.oracle.jsonl
a3f3cbc4b2f01192533bd259693bac119a5913209cb1e47590cc0fa60978d2dd  release/kernels/fence.sv-hosted.log
7b27bfbaa98e3c9c47200791a37a6531e14652b551e172de0fe66a704cb974a7  release/kernels/gather.by_instr.json.gz
47638e8e32d58e6f10a851ba0b378a26ecd82cf9426c6d02c0c9dcd64e150b74  release/kernels/gather.by_unit.json.gz
bfbbdf573c0e26acfaca5b68c3a5c19bad1ba21717392d05966451f86a4822dc  release/kernels/gather.ccvtrace
4ea5fb8a6e8787c085a6eb5d3b1d91dab4e506417f461820f9d2c76bc7c05efa  release/kernels/gather.log
0413e781d8d6ff578c64eb1f800b7931e66f676d5cdabb97b94a4033e6037662  release/kernels/gather.oracle.jsonl
4476ad0bd64dbfa747f6af62074b15cb49ee79005aa40a8cd94b8c7c58dad714  release/kernels/gather.sv-hosted.log
a67f8e293f0df5a5e0cdb52857820618a397e64dd31b57adcb50b5cc8e6d4b44  release/kernels/hit.by_instr.json.gz
e89d49b1bff79a101f291b8286aff1f70a95164526b7d70e06d54e72c3551f73  release/kernels/hit.by_unit.json.gz
bc422f237fb22e88a2a634b3f14c87e3cf50c1ea1bbc09032578c55dbcf7068f  release/kernels/hit.ccvtrace
4d2023614dc4afb7fe24088c5e6b47191985a47b92d1c5604aaa5d6a5c1307f0  release/kernels/hit.log
7ba9603e0088d9164de6528f16ef6a7fa9ce5821c8c12b52cbb3734e39b9fd52  release/kernels/hit.oracle.jsonl
d6c75d421fcd9cc6cb9fc38b3add5db5e3177959e738f9944abaa80724abe3a1  release/kernels/hit.sv-hosted.log
1a75e7a14dcf2718c87e36f3bab1ab2c69b6002c2933779f2273fa988d0ae088  release/kernels/lanectx.by_instr.json.gz
877e1a91100e939715f4e3fe404cd20a9b345dd9dea78b0327f9fae607b80374  release/kernels/lanectx.by_unit.json.gz
d5b66b1134115801e4e2af05622d5b6575d1aa782fd32acab13e61775f0ace4a  release/kernels/lanectx.ccvtrace
17303dfed26ab81c0d23a0ff6c0b705da05bb945b8b9a6da5f596f859bfe75db  release/kernels/lanectx.log
888551babf540db8e3025b82e65ca655013f93eba3c8a65689d069d52a7e6039  release/kernels/lanectx.oracle.jsonl
178d2660f2efe0042fab3ca740db9cb4ec5e0bf3ad02e8e9c38211f72523e1d2  release/kernels/lanectx.sv-hosted.log
948ddfbd8f0c38db499b4165789b986a90c89ae21e564a9228e04ae92060a6c3  release/kernels/lanectx2.by_instr.json.gz
0447145dbecd9a7d13e737b38bc2dff0dcac7c88c9b22ea3a25fc796c8169599  release/kernels/lanectx2.by_unit.json.gz
5ee1b7149af6046c44f881e22661045fc31433c819b136451b42ca921a0092da  release/kernels/lanectx2.ccvtrace
d95a004ae6acdbea5426d50f16a989bf99ccb1649efa633146852636840067c3  release/kernels/lanectx2.log
45c13056dff5c73ed0c9ece56cc36f929bf335322193c7d5eb38710b1d1dfb02  release/kernels/lanectx2.oracle.jsonl
23db0e2e3410f9382f1a01bfe62b143a171515e11cdbcd5da136596551e00153  release/kernels/lanectx2.sv-hosted.log
e445a21d1296a84d9414e3b3398d1864b387e28122cf0fce754d877f055d3d3f  release/kernels/late.by_instr.json.gz
c7bf7dee4733d42138f462fc1a86ac41a7e111f2de4614f1a4917702af9ace4a  release/kernels/late.by_unit.json.gz
a75891694f84bb5e60092f6767802e9651fcb425a2cfb438dd5bacac07980a16  release/kernels/late.ccvtrace
1a1bcf07749573fe53943ff499b7d89c2cea909e9f08760c8f28079ee89fdf8e  release/kernels/late.log
86084f6bd747a2cf32acbc0ebd96ebd3e4ef2d8d9e21be49e3ae49290d7927f3  release/kernels/late.oracle.jsonl
eee622869626cfc268c68626db8f4d84b9c5ee85028439b30ff1ad433fe019ae  release/kernels/late.sv-hosted.log
21c9e6bc9db8dfc3a3c8035a2d122af04e85a7b297010aad73716cbefaa480e1  release/kernels/ldpar.by_instr.json.gz
77c4a1fd6d9f18dfd6afa861c1acf6b9daa0159c0e3e45280f546bfa6f248a7f  release/kernels/ldpar.by_unit.json.gz
7e40f4ed8e582ab74173079682342cb738d83d39a97c7ca4ca1beac0d97e1497  release/kernels/ldpar.ccvtrace
05abd79fe8e3c055712ee8af3438b645e63c18a60f3b23d6f729c23599cb8ef3  release/kernels/ldpar.log
8ac08538e9c807637babd61b31e340f7461878ada31f0c0b83cd66331cfaf486  release/kernels/ldpar.oracle.jsonl
2706deac5f93a003c06257bbc073941b0f2a55e01caddfd63f9cf98e4a7df51b  release/kernels/ldpar.sv-hosted.log
d9135fe3cea069717d3f9abdad003f0e91066a3e403d27be21fb09c69f354e0f  release/kernels/lnorm1.by_instr.json.gz
6253f60a2c4fee151edebf6a83cf8879ac98a79a54d746bedcdf44eacf2cfae1  release/kernels/lnorm1.by_unit.json.gz
477c69e023134c5db665626ddd1f77d9b4c7cf909003a7baa04cdf473c12df5e  release/kernels/lnorm1.ccvtrace
0ba51447e579ab5edf752c2a1092e7f9df4324c6ab72379065f9ce3eb4a3fa73  release/kernels/lnorm1.log
a8d85811af988a1b9fc00db1517300af3d93ec8e589e403d3b9113fa9e0ffc86  release/kernels/lnorm1.oracle.jsonl
03a5b2e3ae2d50b244c5e980a0caac0e5241e5dfcb9d601daccffdf1f0793855  release/kernels/lnorm1.sv-hosted.log
dc1d66f4d4976b07c540928fdfe304cda24b24dfae8d41524c34d13d485350c6  release/kernels/localsp.by_instr.json.gz
ed03be178b8b3d6008df7fa32f98ee64368a6e070d8431665fbd79fcfc74949e  release/kernels/localsp.by_unit.json.gz
7548335b65034560aee57a2368fcb8c86eac66d19ff8ca69fc0794ace801d21f  release/kernels/localsp.ccvtrace
145d81b566740c3c48acc4ea417a5518b0a1a2d2e91771f1c7ec8704bdf8afa3  release/kernels/localsp.log
55e3c9f36e7f7d38c0ddd38903aff4bb4509ae862015c592e6b937ea258042ca  release/kernels/localsp.oracle.jsonl
6e2ff35801145278ee87ef02765d3c20fc9fffba6327046e4c1896fba888a223  release/kernels/localsp.sv-hosted.log
19eed0c53dcc643a234a5c376583c87d36d569a033bcd1777baea2b4cfaf824e  release/kernels/loop.by_instr.json.gz
6979ce1c71ace912b6ed4ba41d54c93ad8d71169d29edc46c84354f0bb18c02c  release/kernels/loop.by_unit.json.gz
72abd321dfbd0f37886b1bba86b88fd77245016c27b4d87e6a56043567e2c98d  release/kernels/loop.ccvtrace
95577315961e0d18064c954d82b7100f3a7dc26da98851d7725e0d4e2339200b  release/kernels/loop.log
03ce5920c06c93e93516d8e53c3f7169f14e3593de204eacceffc0b8a3e32016  release/kernels/loop.oracle.jsonl
89d8e7e3f374d524a06390b62c8285a895eba920203dab42bf58ef9336717f25  release/kernels/loop.sv-hosted.log
99601c34d73194d11e10860074fe352e524763e52f54fb0866c68d61f2ec83f7  release/kernels/merge.by_instr.json.gz
ccf6b8fe56ddffe7c1d642b0efa50241208a32ed9047460ad4ca810f1cb3739e  release/kernels/merge.by_unit.json.gz
a8d74967144ee4b4bd6ad87a20e05aac0925ba5f442e0f085929e688aed95403  release/kernels/merge.ccvtrace
0c4e8c75c740e2d3583b6a3b1ccdf9df16fd6d1a9ae859b2d93b269eb7124d12  release/kernels/merge.log
f96d28815f8756b1f5a45ded53e6170883d2dfa10f9eef0d14b8050b1318164a  release/kernels/merge.oracle.jsonl
c7bb5abeae00608fd3eba546985e2f76c0b8413112f709285614b3b4bbf1bb8b  release/kernels/merge.sv-hosted.log
4af3127bf29c589f0f4d04c6a66c1934d73eb927a4608b1eeb5f0bb3ac7c9ee0  release/kernels/missrun.by_instr.json.gz
52854064e9b16f9ca47e6ffcb19ebcc103b3f0ef1d7e9ed00f5f9252ac2b1af2  release/kernels/missrun.by_unit.json.gz
60a010274d29769ba20803a40bb136e7153e845726e9bb47d6bc0216fe4efb88  release/kernels/missrun.ccvtrace
b21f82b9228e087a7f62888d2b9999a9bbfd07c22e9c7d68743ff4bf90c4cb1a  release/kernels/missrun.log
531bdaf281e5590774bd2775427f25e4cc0419cf8e3d5b6999843ffe9ef87258  release/kernels/missrun.oracle.jsonl
2f092ffab9b8d882e2b1d4b9bd7ff8b6f0e4bea0e7f7a8dbb7d8acadebfa7ecc  release/kernels/missrun.sv-hosted.log
aea44d0a4715a0b0461265cf8ba246d0daa9cf4024d067b63270d817d2c01ec1  release/kernels/mload.by_instr.json.gz
c734adb4a8a3baeea2e163b331759b315b0025b6e6ef1baa08e7355105a9b2ce  release/kernels/mload.by_unit.json.gz
0fdf9d0866cdc67d5437adb8641b5705f50fc9b10a2b2aa7c9b7b89d863fe438  release/kernels/mload.ccvtrace
dc12e5fe4a8f4275055cdb173d4f205468f5c79c05fb0e2df3f8d185b3f86229  release/kernels/mload.log
8000e477b9a95dfb9f0af964e8346acb9d36f1358fd06ffc4ff7cf599d2b8868  release/kernels/mload.oracle.jsonl
be95de0fc0d0fd88af9f6023e4be3a3a0367b121e3b12b9e7852cc0c3f0efb82  release/kernels/mload.sv-hosted.log
f34c459ec45ddb71cf70a72e13cf79f879d31494c541d169bd989e853549edc9  release/kernels/mlp.by_instr.json.gz
02310a150b5209f5d2537f28b91ed9c48a68f5dd8831eded085f5df816c4ae22  release/kernels/mlp.by_unit.json.gz
fa560bf9bd386288984616514f3301db3de5626bb78cd85975c4379dfcaa7d6c  release/kernels/mlp.ccvtrace
663e5791fa4a2595c8c2d4dbd78a97c15bdc59d9aa4963acfac6e10ba521927e  release/kernels/mlp.log
138d282f88d56c8ad648a91af0a983254b55d9fa22942c00d47b327f516a6e44  release/kernels/mlp.oracle.jsonl
314196c3b65a14e8825047f797d9417f8c2f23580f88b5e578054ca4adf6b60a  release/kernels/mlp.sv-hosted.log
017168e241df12192a5c5477ec4bd36f4368ea0e72b40b768991a93f17ec8d93  release/kernels/mwmiss.by_instr.json.gz
52378e9c3933f63a11c05ac59fcdb86b21741f8e5e7537b9b590d55ea981de2f  release/kernels/mwmiss.by_unit.json.gz
72968f2e3116db34104c799396a03347daf62f241e626f6a1ee89cc493f433e9  release/kernels/mwmiss.ccvtrace
4495e1483809dbd02df4a66cf83a33963ab3438062664aeda37fbc12fcabd5c7  release/kernels/mwmiss.log
8abe8e8997456a2a6711ee72da54d854b24e20abbdab28e4b7271c0d28418de8  release/kernels/mwmiss.oracle.jsonl
b5a59bf47544eacfae32fd526e4a3c1c7e7e01f74dd1f6ef34d62acd09cb56b6  release/kernels/mwmiss.sv-hosted.log
bb0b416a5fd8ade061a6346658763ad111330261158fcdce1baaab39ecd11009  release/kernels/narrowadd.by_instr.json.gz
76ea06487fd0f89d6afc5d72c18755b06880638a7c80bb3b48bcf3389d237dd8  release/kernels/narrowadd.by_unit.json.gz
eaba990031d661ae76dd290f0f3c794a7955c1fac7ddfa5928186094b8abd950  release/kernels/narrowadd.ccvtrace
2184ff8b5c34a5079d953ec22a0261e335af6fbdbee6a454b89916ff5d62c021  release/kernels/narrowadd.log
40a2cf629853dd404bb06b4a07e35abde3d12efc13f26ffe28f923daf2994574  release/kernels/narrowadd.oracle.jsonl
889c54f508e06e165f2ba17f4878f410e291d809a1669eece80dace9bdd27cca  release/kernels/narrowadd.sv-hosted.log
bebcc7593cbc1a7f06a1c790f067f254d83a64dd069246b9a73ff2abbaa068e9  release/kernels/pguard.by_instr.json.gz
95b0eade2bc1848de516e0861ac2743ec4e5fa405a165a4dc8239d8d802be6c0  release/kernels/pguard.by_unit.json.gz
3b56006868b45f582561dccb435ba57ea8d800e4dcbebcac798bed592041dee0  release/kernels/pguard.ccvtrace
d78c48c368ed6b5d4cecb33d8b6bf4a849ddf729870a54f4f11e1932982af933  release/kernels/pguard.log
690e56f1cb8d97cbf67124b7dff3ad0a90cb8981814cd1709cf0cd0e035b3bd9  release/kernels/pguard.oracle.jsonl
d3b50ebf1e79fda5e3be2e5fb578c3cebe87b105dce04273b5948f347dcac54e  release/kernels/pguard.sv-hosted.log
e9f833f4533862c445092e77d08b24b430867d1b0091cf201dfafa5f022cb60d  release/kernels/plog.by_instr.json.gz
ffe39f97e9445ca15b4120ef9b3b8fb0d02c060580babd82bf2a295f2904708e  release/kernels/plog.by_unit.json.gz
0cc33f3066dd4ae74b2296e7d22a3ce494836416ce6f69536758b97df8e156bf  release/kernels/plog.ccvtrace
950e21ab65d30856daf26671cf6bf7ac47b78552e17e8c1aa5c47e83eabc7b94  release/kernels/plog.log
0c99915e2da60f4670da00504a6371d7d17701d4431e733a3ff8fa98a2030d6a  release/kernels/plog.oracle.jsonl
98e682eb9852fe84ac117e1e9cee01a8dd541be853731c1fc9f7f9edacb3bfc6  release/kernels/plog.sv-hosted.log
3ce49b024f553d23f3192d7bb788ba6a574c72ec1f02cafc18dfaa80c39e53be  release/kernels/pmovdiv.by_instr.json.gz
170bcca9bc6b385fc63a548d9350211a8d4aea459d1205863d36bb71c89a0186  release/kernels/pmovdiv.by_unit.json.gz
231a3dd81b74fa2103ab2345699f1f0e0f4e412e85827b5e835d5d1c952eb6ae  release/kernels/pmovdiv.ccvtrace
165329c19f2cd1b4682252353a170783f76de7b8ccd1edae6e2ba00ee80780db  release/kernels/pmovdiv.log
7bc646cff6166a51bdce03d7c1b7209e871f0a91d743083a9b910a80bcd0b33f  release/kernels/pmovdiv.oracle.jsonl
914288778e516c68c6870d6a58b016e1767316f57eb4af03233a076ff2350622  release/kernels/pmovdiv.sv-hosted.log
c178130ce12355e54a6e7c83f178f771ce13b03b076982e566e6dc1895c23207  release/kernels/predlane.by_instr.json.gz
8e42d2e289ed480cda6e2ab59277a6e1ffb2fd55b62f84bd46a40aa466634a37  release/kernels/predlane.by_unit.json.gz
eb789d73b076373515f510599083b24f2501a0bd4e20bbd32f09b292b112c02d  release/kernels/predlane.ccvtrace
8c4a653f5294a203cf3b88e7da6b1eaa04ecd0faf3131afe7551db0e1d10289e  release/kernels/predlane.log
c45f4177b9e84fc8a6e36b13534a0c7636eb30a3f8531847100ce5e23bf404b1  release/kernels/predlane.oracle.jsonl
e37ae43b1646e8b4dbe5c56db5ff8cf171f37a2ac5ea61ff37623b4bfd17ef09  release/kernels/predlane.sv-hosted.log
ad87b419e2ca122e4142a8e80133b7be7fba7d43f1935e966bfee533e499c66b  release/kernels/predmerge.by_instr.json.gz
54c01130f47cb50211e48a33ffc1a9159083d9e75b49bc454f35e837deb0381d  release/kernels/predmerge.by_unit.json.gz
992d9ed5bc1841229c645570617d50962aaf497fbb55d502a1af8aab6dc39499  release/kernels/predmerge.ccvtrace
8f067d385cf0afab6e862f2a895b3405188d7a4cca304332b86c5b7960e58982  release/kernels/predmerge.log
6c737c49434bcd08e3e0814c8b1dbf15c586ae74f7929ba3148ddcee2c62c845  release/kernels/predmerge.oracle.jsonl
3c115e2190a6190dfb4bc0efdbf846c6ba4ce13eb15f268318b817f9c397fba7  release/kernels/predmerge.sv-hosted.log
96ab70694026636c9a82da5e3fc00aad3e373cd7bca71526c03b0813e6cd7109  release/kernels/predspill.by_instr.json.gz
0416de5ae9e781d3f99e63dce8aaae606c8b234933640bd46fda3f6244a30926  release/kernels/predspill.by_unit.json.gz
92f4a10d221f22f74ceb7c73372973b49d10dfe6e1fdb646f84723de6004b45a  release/kernels/predspill.ccvtrace
e96494394e32dba75c3eb8f93ca5fb4743d861a8ef33c5ca4e96f4d2dfce016a  release/kernels/predspill.log
b7c84c6478117ffa0f06da0e6ad1e4628e2683426a7911080810e78e06a5242e  release/kernels/predspill.oracle.jsonl
46890d13b30cc559959b1a4e09cc1daa20c24d14417211f0524c0f72f638d66a  release/kernels/predspill.sv-hosted.log
98ad669bd902bb389672ba131ab05c734ce4d43a003c67b20f1866eadc3e8264  release/kernels/predswap.by_instr.json.gz
c03c80aa3e605b2353e4687806c2cf2522d45d1825be711fa6248da5bc4808c4  release/kernels/predswap.by_unit.json.gz
f793d03da341396628fefdbbe49d9e5ed50de9cb68b64b7c74b5bf0fd183925e  release/kernels/predswap.ccvtrace
253ff10981635ad5684e9ef9818f3d383312e940e65cb6477edfc9002b9b5be5  release/kernels/predswap.log
a6d4f7ed517553816d889c7c9eeb6bcfd1f6c973fbf682ecb69f3c2de619f7bb  release/kernels/predswap.oracle.jsonl
8d26970b469eff9641e75b33261d58a61c45ec13ece431f2c3720fd6a6401e6d  release/kernels/predswap.sv-hosted.log
d316d241f05b9ac873d3eb80881828764fed1440f5d36ebd657eec98caa66348  release/kernels/privwin.by_instr.json.gz
8b5dc55aa903540c7b91ef9f823a43b6008367c933d31833e70bfb2ce443f66e  release/kernels/privwin.by_unit.json.gz
325bce511eb4675b8e5bd663900b9a72dbd36c66caebd7a33c5d8ce939241e87  release/kernels/privwin.ccvtrace
c5df1f91d99233fca8df94ade4f20dda846e5658fb5fe8897f8a41d60e086b39  release/kernels/privwin.log
861f686fc4480363472908d679d8815e8c957d768e7ab32c826930527b0fb7a8  release/kernels/privwin.oracle.jsonl
979387713d83976f8ce1acd5bc4c9811be0dccb8dc4c1e52e6f4b7e7024ddf47  release/kernels/privwin.sv-hosted.log
581219105780099abec5c0d430876d315b8eb1d61d39429a67fc7e5593abea16  release/kernels/provswap.by_instr.json.gz
6d2c3e16ec9eced3ba01e1901ba813f6f114733367b8ec19ffc588331dcb0b9c  release/kernels/provswap.by_unit.json.gz
0fec44b3b5cb0562290746e2d1014c88182c6a33b0dc84b07f704fbc7dc2aa46  release/kernels/provswap.ccvtrace
0ccca9556ddb76b513877830f163d0a225dc04ea17d3832eaffacc29e8ad73a1  release/kernels/provswap.log
c9c32a793d54cc7401477f582487f7e8b345b2669a75337b8d6327120d98e5dc  release/kernels/provswap.oracle.jsonl
8d94cd1b3219d1d173592f0983292b980584fca2f510243c218964fed76e93d7  release/kernels/provswap.sv-hosted.log
db35e99a87b8ce9b7595e1891c65da2f681d68bcab79939fde43da05c8c900a3  release/kernels/retmiss.by_instr.json.gz
2cca400f354aa8300033f55d80d202ca22ed1da0aa47c6838ca13a0b00ae605a  release/kernels/retmiss.by_unit.json.gz
a94b952d7ddf4182c6bddd62106ee6e7d5afd002a8c763335f5d4120dacbb931  release/kernels/retmiss.ccvtrace
745020f73edb3b989781696be4734528346e677e484a36702ed84a5ca2bca571  release/kernels/retmiss.log
e5ef8538e838c6cff7febfc679dd091cf5e002f82d34f1009b1948ce22bc3649  release/kernels/retmiss.oracle.jsonl
a73930a61b8e1dfbf657267a9085655100bf8d19c6de588ebfe459e2cbcbc8e8  release/kernels/retmiss.sv-hosted.log
c5ff1730f30873e277e5d962073b2f8a2ea8e82cbf83d046b24cb75b68797210  release/kernels/roconst.by_instr.json
aff2f6ba374c4b2edc0b4b13d953a14148d131286d30cc55dea555cb22b1b61e  release/kernels/roconst.by_unit.json
24e16ea5a89c0da7406ac67010ed1e91278e7e70007de5fd3c5e0e848c30ca5a  release/kernels/roconst.ccvtrace
494fc327cd7db4bbda75ead1a960b5cc2c6390a9eb632c53d924434c0ef4f183  release/kernels/roconst.log
8087c0671de620162881aecd38cd6114b78e7be6bd71201e3ec02c9a2e2e750e  release/kernels/roconst.oracle.jsonl
54f9c6dab1694a1aca084c8167353fe1a47e095ef5b172f96df192b3326158a2  release/kernels/roconst.sv-hosted.log
8a379537853667bb0ec4c1843eee518dc465010710d108f3e114d66d4c6cfb3e  release/kernels/rogated.by_instr.json
828dc92cfff15976c795964e18536c3bcb40138bdb9f4d3e1dde3f3af530dffb  release/kernels/rogated.by_unit.json.gz
631b1ab4d97f56e9c4e84621330223c13a652a9ba99663e4543231ef82086049  release/kernels/rogated.ccvtrace
967b63b0779565534ed14849e12e764c85fa1d5d58327962314628713d519d91  release/kernels/rogated.log
7cd02bd4cceec5a044d6b4d6a80df1e68ed0ae71b0b2a953143636d5b809ea6c  release/kernels/rogated.oracle.jsonl
1b426fc7a9c2915d18454682ed25eae66e19d845e70d63e02003d67008cfb5c9  release/kernels/rogated.sv-hosted.log
e675af47add27bd6312d1eee745a3cd9909c87cf69ac3265df09ddfa1d76dc0d  release/kernels/rokill.by_instr.json.gz
f92b3942fa769cb088223bd131279e20a4e2a3361acfea070cf9ea4de047ba5d  release/kernels/rokill.by_unit.json.gz
55f1d311748482da87a37d632ef2903bd8d8cbb08eaf1fa08128d9d4b4fc6657  release/kernels/rokill.ccvtrace
0a224446371827af3aa6e2a2ff7bc3015355c20c5b05026f0fe7d9491095620d  release/kernels/rokill.log
94efcef96af469a512d346ce61623980fe86383188eaebd55120f716db596f14  release/kernels/rokill.oracle.jsonl
f86e0286c766025d3488d44b7e5977561406052543c5ff30dcc1d497aae308e6  release/kernels/rokill.sv-hosted.log
4ce3274ce40204c6adc0e06032de0b5f3a9af30d7eb9f93cd6a4341e23a1ba5c  release/kernels/rolaunch.by_instr.json
32a781755aabdaf1378a6e47b5d441c07dbeae5411b40e2456cddab84c3d9377  release/kernels/rolaunch.by_unit.json
c9423aa368141c32db86d8f3699fc646239c555b49d5d1a4c2e3e8b3042c37e1  release/kernels/rolaunch.ccvtrace
815a52d7fef6048024bb21899b0c6bfa2f645b3324c929f7e39485deda041c84  release/kernels/rolaunch.log
e7dad585c3e70615de04330fd03f4f282c29a005dc1732a35655fb261d51139e  release/kernels/rolaunch.oracle.jsonl
0c69345e4951e73fb45369b0cbba1ddc0a54ca0893e1de4fe76a2848ca04d260  release/kernels/rolaunch.sv-hosted.log
c5ff1730f30873e277e5d962073b2f8a2ea8e82cbf83d046b24cb75b68797210  release/kernels/rolimit.by_instr.json
43430520f2f8de48bd6a6b0c767269a2ca31c6f08350cf47cc0beb21e8cb2eed  release/kernels/rolimit.by_unit.json
da82ea8ac380b275123303019058883c223ccdb993176d9f14ffa9730f395f89  release/kernels/rolimit.ccvtrace
e0fe2aef239b29aa5c5a9beab75d32011361fe49e69b6efe59169eed5c4b061c  release/kernels/rolimit.log
1c5bc0cb8e8b2e69505fb5a551a16d5d10c56f232b88da7a27e336ad7d962de2  release/kernels/rolimit.oracle.jsonl
8536803e8dcb4656986c48f6769f123030c985950595a3420cb0681ae60b8885  release/kernels/rolimit.sv-hosted.log
742e8017b2488a6f4612aa774f7a85ff2b914ce9970c9cde455d24f2b64b792e  release/kernels/roload.by_instr.json.gz
4d92668d0c7a2a7207bd992a59855b986d90b5c70bf6c4ab8c16cda72f042e26  release/kernels/roload.by_unit.json.gz
9db58d0519c28e63306793107831abcac7824ecabeef0820a22e280b39799cd1  release/kernels/roload.ccvtrace
3e8adaeaab7710c41cc0cbee77cd72198bbc26b2d187bf70cbc2f17d635dfc25  release/kernels/roload.log
f7c1309cc9764769fb5803f6fd0f2f5e1eb418f2d23fbe5e17cf5f9106869fdf  release/kernels/roload.oracle.jsonl
c75dd7efb6b7a7c3877f13f6f5fe23dcc845fb5bc965ae181d7542194344479c  release/kernels/roload.sv-hosted.log
8c41a1f70dca197beb75c193e351559f8c119e639771c8ce24c6b1f3c3e5cce1  release/kernels/rope.by_instr.json.gz
ec1ff429ff27f8bfc86e10bd061d9f09ada259fa13c1eceed42b3e02e1cbe578  release/kernels/rope.by_unit.json.gz
1a9e2f663f827ca30a249aa74cdf970c81348d8ed41c1a9499bc8573ec861b6a  release/kernels/rope.ccvtrace
bed846f2d8b5551840fdd0d9a83995feb63ea64b60a892f6a2bef1ffa41d0512  release/kernels/rope.log
d55f9efae392dc8877c102c01c0810e7654b666b6ede386328108164c6cf88f3  release/kernels/rope.oracle.jsonl
90062a44b7fab996b5244b5f765e5d2809e38333ecf6056c41a75f7339546de2  release/kernels/rope.sv-hosted.log
4b656e4231314e85c3f4fb487a37f9f7644ec0ecbb794e133530f434cfec9f25  release/kernels/ropediv.by_instr.json.gz
7e3095c39895c0991cc0625981d4d444df4726fa8caee0623f38116a9fa3bd16  release/kernels/ropediv.by_unit.json.gz
e0f90b60cb5893cc5e9839a74708848bc8b5409e2af972fca5b128129a3c2614  release/kernels/ropediv.ccvtrace
b14725c2f548caa6cb4fdd5b44469f1a7b022967f180f528421f43036d91fcab  release/kernels/ropediv.log
10c0ec6ec18b7b44638c790033109198c079d07c1537bf193353ccedd00a920f  release/kernels/ropediv.oracle.jsonl
d4f31726d942de5af25bb94ba0fde0f5dbd0cc09fdbd0101f2b50d08c651d25a  release/kernels/ropediv.sv-hosted.log
aa8c7a832501950ec33596dd74d2dc1ca41c636dc0f78025f0ff3759e4785342  release/kernels/sel.by_instr.json.gz
3a1db8aeea8979b04b89ea7b8b1f3e310f4e1f8db11a7e4cbdb952ca79f11cb9  release/kernels/sel.by_unit.json.gz
688c1614887034251601256381778a5d9009dc4bed01e11890a584f2cfaaf665  release/kernels/sel.ccvtrace
5020df1161245c5960188582d1d73b4580faaeb7bd6fe2e7900aaddf2d45d8df  release/kernels/sel.log
87f6a81e8afa004c8039bf2f61c90176fcf29ab29bb17ac44aa016a5cc8438fe  release/kernels/sel.oracle.jsonl
91e9bdb867d0a0ee6a05895b7734c2ca95469efafc007e906e573760a3335ac8  release/kernels/sel.sv-hosted.log
fe07a505ca56fcc5093bb67cbf92530e41c7b72c1daed5c4da632b72b871607a  release/kernels/sized.by_instr.json.gz
9d184fae6269e4f148b35edc34898ba7997e99de976abbdccea7d98952b89a50  release/kernels/sized.by_unit.json.gz
1f80ee055c71f4da0b1411cd91f6b849d72a032b87e76f6d9b448fc37e51b495  release/kernels/sized.ccvtrace
63f95636d5d4c0425862898cffb0b89812d2105c0d6bec2db19f6b3468c7237b  release/kernels/sized.log
36d903ba1618bd1faa437c9812a6ee6c0c966a63196c796267d74bf2695ebc3d  release/kernels/sized.oracle.jsonl
37110786c76531b937eb6cb7b2db9c06c46fe8e9c11781ac7d3c7f468461b305  release/kernels/sized.sv-hosted.log
1052072db6a445141ab9d90fb5151186578c68013ece21f96bb3314823eac74a  release/kernels/slotform.by_instr.json.gz
52ef850424699e1d9d7878b47d04edff14730640a8e8308f8963517f5e141646  release/kernels/slotform.by_unit.json.gz
f93d62ae47498b83f4d72cb6de0cd18792372a17deb2fc2de7e5244c075f1e89  release/kernels/slotform.ccvtrace
1f79c19db62bb0c0f9eef1d7e97e2eb1a5fe780391d71e42f62c56982c546a63  release/kernels/slotform.log
8b61db7419b18cea8a646fb628218447e72e84a18a9891ffb73b441736138ab9  release/kernels/slotform.oracle.jsonl
d430f408a7ffc12a2183cee9d05164bec88d982d5347699fef94ea0f5f6a6489  release/kernels/slotform.sv-hosted.log
4fc1f2081268476fd0c1b06b0a832f7c439084f928a3fdbea18e3272942b89db  release/kernels/spinwait.by_instr.json.gz
3ae9cc0222a2afb5d6e2b746ddfefc2d811b0ebdb7f542577b332a5e0c1b680a  release/kernels/spinwait.by_unit.json.gz
3961613ec80a3fbc0f5a67f9ba71fd78ed20ed0c29180ab124e8ff6aa8e0e5ea  release/kernels/spinwait.ccvtrace
65130011661c53771d8073cd3c89a6bb63bb29883971f906c17fc2135184bdd1  release/kernels/spinwait.log
868920637236c878b33779bd450439466fc3626996a3164573dc11d437d5c709  release/kernels/spinwait.oracle.jsonl
0d417325ecb349770c16a5b3c650a434f57146516efacc92760b181514b24895  release/kernels/spinwait.sv-hosted.log
e2d58b472a93598c7e03fa6cb9f2fcec9a4ec970d9e9e2a749bcc25683efad1c  release/kernels/spmbank.by_instr.json.gz
57f4c6bd45206622f31a4b313dbb5f58382a7a077369a9509dcbb5a4f284fe72  release/kernels/spmbank.by_unit.json.gz
b41fbea616795bbf29c9e5a4fe7149db44bf3ded02d7a7358c49516a5bf360c1  release/kernels/spmbank.ccvtrace
4546faaf18deb38edf8b0645a03b1bfb927d2a82fec857f975035486fd49ee91  release/kernels/spmbank.log
3af490cc37d7a92dbe719b57de216b648536eb301ff9d13de9a39f50d150d725  release/kernels/spmbank.oracle.jsonl
b7618b7057e0e136d8547219c3b193455de96be832ff17d51311a274caf06d59  release/kernels/spmbank.sv-hosted.log
28016f43bc407c282c7c8eb1f77075873d9bbe1a36c65053887e9aefd60a253e  release/kernels/srd.by_instr.json.gz
ddf23f68c6c7dcb206583f12992fe582b1d8afd199fa0cf95a4498ab674e4422  release/kernels/srd.by_unit.json.gz
95badb026ccf14f957d3f0590ff6b6d3e65a1e3529a41b23e4826ee4473679f4  release/kernels/srd.ccvtrace
e4c2a3098a0a7ac41c6a3c9cf643e1b947dfbeaa12a8a55f779ec0165e9ff8b9  release/kernels/srd.log
b08eb5e3673cac7eebb8b72af5ed3783c8e70a9e96592e76bf3722551bc79473  release/kernels/srd.oracle.jsonl
b5f773d575d36da5ebcd223f83e63e76cbae95111d172e6f4fbb84cdc19749de  release/kernels/srd.sv-hosted.log
cbfa792c6eff78643c967d1177cfe27075965665ef0f4034c4f6fd882346bbdc  release/kernels/stall.by_instr.json.gz
4d393c2339812b5fe7d3dd67d839f4ef9e8a1d6abe1598d54707b359a2f3c257  release/kernels/stall.by_unit.json.gz
34f78c0c08b929b8c250af4c5aa11d6fd5e810a7d837af1098d0e45a41aad0d1  release/kernels/stall.ccvtrace
51d1fc31172956fbbcfa61cac85819c6f71c4214bca5f7bda9358d14809295e1  release/kernels/stall.log
500db2c482b07a0706583422cd68878301d0146c1f872ccc1f11bfdcf5c993ef  release/kernels/stall.oracle.jsonl
4fd3d404cc29be7c844aaa52c38b9e808f05eab2993157a2a1927b1f6d907cb7  release/kernels/stall.sv-hosted.log
1b5e51915b06c14e0e14f461950080f4ed065ac3b46a8c472943e87f7034e2a2  release/kernels/swap.by_instr.json.gz
c3797a656837f75e093ef6b959b3039c217f2671558e059908be9a8d2f067b80  release/kernels/swap.by_unit.json.gz
892028773069382947669a8565e89ad81350b28f6e8861ba3b60e0babc696519  release/kernels/swap.ccvtrace
39aa781f6e8deef7e28a814007e1dbf2ef7fe429494665ab1ec14b27beeeb96b  release/kernels/swap.log
3658a26316c1ff7bc1744304a42f736e930fcde2865c8913e6cc67a22ce96667  release/kernels/swap.oracle.jsonl
0036e4e572c737e781c8081f277606cb0924c6d9dc85dd193b0738a501681f63  release/kernels/swap.sv-hosted.log
7169945199fa16648512610f374c56a56b0a5e5e7717084fde07a6b11f83e5c6  release/kernels/transp4.by_instr.json.gz
7855f01ad11cde1e24597df9db5e51a2ae78e562f5fb3d0d445acb362ae6de19  release/kernels/transp4.by_unit.json.gz
9c9f7435ce6e77777f6a8ab434e91b737f9a2ba7ebb3638dca45840e9251af08  release/kernels/transp4.ccvtrace
e01552b32817b0d63f545b48dd079cc66f0ed0dcc40d1f5e2f8f44c306131244  release/kernels/transp4.log
06396ace3ac19677fd39c700e408606e5bdbacb24997d663bbe8872e63dd74fc  release/kernels/transp4.oracle.jsonl
820820f83569536ca0e6ce46ff36bf5d088cdaa52f9dbc33d56c950d9f38f020  release/kernels/transp4.sv-hosted.log
c2465ec9510735500d5685addefb6f053a32fe1e091f23a24dcadb005bc56fc9  release/kernels/unal.by_instr.json.gz
017191be0af01c97f6053005e14cf6e0b06920b8810c3e7725b890a66db421c3  release/kernels/unal.by_unit.json.gz
1b3b224b0cca3352113bed47b586be34cf167a632ec031dfb10da1d35f0aed73  release/kernels/unal.ccvtrace
77e80513a79f1c7b20a6006c87b3fd770f00670e027195a964383123beb004c5  release/kernels/unal.log
c3d484bb160657a563df983d9a2532eac27f556636617960aa1e72183ac2b299  release/kernels/unal.oracle.jsonl
52c37125d3009d293e0e4ed69800ffd97f7e8fc708c678cd618c3eb340f5e2f9  release/kernels/unal.sv-hosted.log
db0cd2dcb69da4ae4c9ae98dfa93a026071f2333810e53fff1781e78cc509906  release/kernels/vadd.by_instr.json.gz
574e509286f992140c3883b9ca1adb289263222fec35fc53f5ceccac408dc027  release/kernels/vadd.by_unit.json.gz
0d57e0309bcd01a4cf1a43b5a5da28010c962d44c0d5fb2046cfddbd736f81ae  release/kernels/vadd.ccvtrace
dae5bc48b1509c91e324b4bcb79e9a7c9ce3b348b9d6450fe1a5bcd7f4c47cdc  release/kernels/vadd.log
0276b6d0611a4bbcdc004ab3987214aea138245bc7217504147331689a9c0880  release/kernels/vadd.oracle.jsonl
de618a5546154db85275d1c1a1b6b7f614fd5a3a3274514a00f2da3d5370524f  release/kernels/vadd.sv-hosted.log
254bd3bdb37ab065025b83019059f8043f98b91e3d823df19af69eb44059411a  release/kernels/vadd4.by_instr.json.gz
c44c013781b70a190a8174ff46fbf37079107e9b4cb540461c3161dd3dd9d4ba  release/kernels/vadd4.by_unit.json.gz
3fdfa61b755ca9388dce7259081cda7ad6559ac7394e1956261e72504e3ba118  release/kernels/vadd4.ccvtrace
420872d019327f5b0a3db4f84d73fb02d153f8b1de5b754e771d75a62261af14  release/kernels/vadd4.log
225aa18fc9f38aa9ad615aa11de254337d59fa705877553d873062c68366e0db  release/kernels/vadd4.oracle.jsonl
f9a440ad4543fd63a0c54bc4c4bc498ce40587c72d6119b0db4741939af3347d  release/kernels/vadd4.sv-hosted.log
ebcb595ca6fd9913a6e6fd412fbbc2ee85629c26ad58d7abb9f7409015bb5972  release/kernels/vaddslow.by_instr.json.gz
bf513557e8ee57e312bebbfd496e28aed56749f2b97c34272256c52b116e7843  release/kernels/vaddslow.by_unit.json.gz
324681a8412fa64ad998c3cb9eba5313ac695459354299dd5947c322f0c80321  release/kernels/vaddslow.ccvtrace
99ff1bd7c07c011552c0503b940b3957c35c15338ca9260650cc3cbc20dd309f  release/kernels/vaddslow.log
e9e6218e8b8450e9f9ff6b39d659c994a1e51c527a0c5bd10d18b5658ae0e344  release/kernels/vaddslow.oracle.jsonl
a4f75b088ed475e4d5ada175d9e10f990abf5e520157d66891221437c30aa3df  release/kernels/vaddslow.sv-hosted.log
3008fb39870cbe58733964629e8a09b363e5a3a59186f1b26ed1758e2d6c55b8  release/verify.log
56b3d8627d79d397ca06dfb57060015391cb95e52e925d1f09a4b2a7f4147127  release/wiring.txt
```
