# Snapshot snapshot-2026-11-13-21d64a7

**A generated, read-only snapshot. Do not edit or merge it.** The source
is `ti-ls` at `21d64a76fa7e3dabe444f1b58c740b2171e57d4e`, and this branch is rebuilt from source by
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
| Source | `ti-ls` @ `21d64a76fa7e3dabe444f1b58c740b2171e57d4e` |
| Built | 2026-11-13 (UTC) |
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
529a1bc62039f5bcc79bafae541626e48d97b4709d1825145df70c3bc60cef65  release/kernels/addrhigh.by_instr.json.gz
31dcabffc52b109f38c4a61c7813c29ae5b123aab106cf8deea128582f08e01a  release/kernels/addrhigh.by_unit.json.gz
26024c086b98c667eb6ff4ab07d9bb2b407953b72a2433e8bb2a0d0f590cfc08  release/kernels/addrhigh.ccvtrace
27240e2037e268e0eb06b1d826d900fa924c27faf55adf36860aeb04bdc1cea0  release/kernels/addrhigh.log
569f2e22883fad5f0956c57ec734e6afbdd4b8a854e50277425172d6c0cbd766  release/kernels/addrhigh.oracle.jsonl
2e578fc7399659ca6ced2bf5e6e377ab741bcbb29caf15f25d99d1bbe02ecc6a  release/kernels/addrhigh.sv-hosted.log
c9699bdd745f08f65a2b611666d16b99a9232b78dfd4047c87adf2e373d85361  release/kernels/addrlimit.by_instr.json
300c1f4f04a25ce5cbf865a1665ee1fdced9355099dd4fe1a776970da3820ebe  release/kernels/addrlimit.by_unit.json
646dd11cf7744b4941083731a2cb0a8ce7b94cbdf53f708cf2adef6ad684a061  release/kernels/addrlimit.ccvtrace
9cf9efd6482b990e089b34bf8b39a7821f8f46d28f9c16a407bb8daf6339f60d  release/kernels/addrlimit.log
bc660b0b40359a2c5a2478cb0eb4950b73fd22db50ea76b80052bc195a1920f4  release/kernels/addrlimit.oracle.jsonl
9bd113a737c39e371e827b3b1b167a71bcbd139c82796922802de449c17264b6  release/kernels/addrlimit.sv-hosted.log
b879f56d333c5039bb7f282658f0ca09589d2fe56531c13b684dd0893a4c9163  release/kernels/addrneg.by_instr.json
fec1fb96615feb68f26d8db7ed553f19cef1691f96dfc97666b271b4cfcaaeb4  release/kernels/addrneg.by_unit.json
401cb1b720323c75cebe1be95fb7e9736f1a40d7f0d02a7651c85f92e387bb9f  release/kernels/addrneg.ccvtrace
1e13c092179509033a5cd30bff752dd977913c9cec73d53baf24c1ed303149c9  release/kernels/addrneg.log
16f5b0707ae44492a1efd67bb9dd38a7e79a7bbd354fa9207b9e7d150ff2f107  release/kernels/addrneg.oracle.jsonl
b5c03f504fd08bf37b3dbfc12f5fea2174640070503bc03ce35faec1580152e7  release/kernels/addrneg.sv-hosted.log
b3cac3b82a5e7b585bf46d12019dedfad7e0a33786f20b977017acec4cae34df  release/kernels/atom.by_instr.json.gz
f052c636b742c6ad5594cf2cc06adcfc40f80cd366ed23df9081d57cc026fb79  release/kernels/atom.by_unit.json.gz
1ad23250d393836aac4caa0748ad25772082b017a2700dc9d43196ddd46030fb  release/kernels/atom.ccvtrace
2bba398ae8c90e1b42560318118d1b69e92904b17fe91cdc57cfeaffcb0f6ee0  release/kernels/atom.log
504f5b6e9d25114dc35f2c70b21bb7b3f3c508c691de12dc0e87d12a74285361  release/kernels/atom.oracle.jsonl
47c2dff2201901089f61a02e8a0c6167f51b5f2063bee6338712314412f99bf3  release/kernels/atom.sv-hosted.log
f2943de84979f1fa92bf3a3ff9e094a85065c7c2c36a04078b826db15b4660f1  release/kernels/atomf.by_instr.json.gz
c41501f8f315c4dc36467dd6504132422525561b9e22d3b263d8462de01d8196  release/kernels/atomf.by_unit.json.gz
ead6946f45250c234003b3c3d18a61765b5136bb5ca9bce30fc4e1b68403f586  release/kernels/atomf.ccvtrace
977980468bb913164283628fa958797c01953312a70ecb48024fea550c7191a0  release/kernels/atomf.log
cfd1179edf4061a33ab2f75d7a6dec61decfe629000198189a7bfc2647b34238  release/kernels/atomf.oracle.jsonl
60bd101320797ddaf0fd7eedaa19dd0aeac9c952f7da2b6171900828790a98dd  release/kernels/atomf.sv-hosted.log
7bf356b3d5df455696de263df58e6728cab72992479388ac59122ee83eacbfd6  release/kernels/borrow.by_instr.json.gz
f8ce3fe23ff9fa67bdb07140d98d097bbb1df0ff9dd7ee86cad64ce757655562  release/kernels/borrow.by_unit.json.gz
8eee0c50216f1eef61b0098241e98cee6f7c406c05849d0c1a4a2be835a5cfa5  release/kernels/borrow.ccvtrace
4786fdc81633a7e164dbd794685e0d722bd11c6cc913ab97d20ceefe74c70f87  release/kernels/borrow.log
4c565e1ce0b3baee36e158694b32c8defb5cd662b2f9af75cb5d8c26cb1168ed  release/kernels/borrow.oracle.jsonl
94b5ebb9930e17bd182b80a5bdf98e93018d76de77d3fcf9462f867c52561190  release/kernels/borrow.sv-hosted.log
3fa64dde9d5a7a712c92059d659c2929b35b9313fb20151a6e07f876a136778f  release/kernels/brs.by_instr.json.gz
ca26f95bde6516bf92794eb8a599443af71e7bb67a5fa068b9912943ce5c596f  release/kernels/brs.by_unit.json.gz
88a57ff042363bd7048526f4c13a55eefd7eaa18be159b61f466819827d06d8a  release/kernels/brs.ccvtrace
a19bd76fb1181d09b31c61f7135684ff2af7747979e2a8760d8281eefcb55323  release/kernels/brs.log
e3c1cb3379580cf1aae44e8ddc8e846ef6fd661a573cfe0a8d4444b18a14dc56  release/kernels/brs.oracle.jsonl
3756645b4f703abfe72de99a0f0a0f105faa76dae8f9a9296b33bea61ec29c36  release/kernels/brs.sv-hosted.log
0c2c806d26981a82e6d1a520fa7081367121b7526699e99666f6e288f9734df9  release/kernels/byp.by_instr.json.gz
135304507db4448baa384fa715f0e72e8167f9a8482223a721d2b0306fe9a383  release/kernels/byp.by_unit.json.gz
8a572315c9d52778bafa71f96e4423500137a20efb80bc35014ecfb631f91125  release/kernels/byp.ccvtrace
b8467b758102880af68fda8812b0ff4d28f5a0384fba734ed5dd2de4e8433771  release/kernels/byp.log
5a03dfa4f3603fef49f1e3639e74e34152ca3ca5ef8e41eb959f8323040fa2d5  release/kernels/byp.oracle.jsonl
f0e9fb483d4990caae9111b9de73809bd3b3c99704a8f2a143977c3ba486bc8e  release/kernels/byp.sv-hosted.log
3ce7dbd70ca0585607ddde1f4c0ca325da6cf5cf4e76df008f1f64fe1d3a4da7  release/kernels/callret.by_instr.json.gz
a310bdf1b1945f5ddccc81ae08a400d574b33f084f68dc7c9f2cd23b2f94dad0  release/kernels/callret.by_unit.json.gz
046e92fbd4ca386af15041fe2d714aa45c58fd1cbd6562b55c7f53d80fcd82b3  release/kernels/callret.ccvtrace
a9a9771e1f6004b107c82c5d53e813b95b0bb95146a88e0c7e50cc8d715a0a49  release/kernels/callret.log
9b1d1b50b527f732362f837250aa2f26dabf3e76e16a4794856ebd8f105635b8  release/kernels/callret.oracle.jsonl
9608f43d555ac35d1818b19e25ff92edcd721f5c0e3cc02800ef3a22716dd0e1  release/kernels/callret.sv-hosted.log
0a21dc086146c4d896260d9b81358e5f3624f1c5dbba5d45908f19944eb00bb5  release/kernels/cas.by_instr.json.gz
655b113cc97f3fe2454f4c8e611158ac03d1230df0c4e94eaf015a3a2ff2484c  release/kernels/cas.by_unit.json.gz
2f8710781ba48bbf53e054ee39b2acd2423bf9f26797f034ed2cb18d10a58fe6  release/kernels/cas.ccvtrace
f9ed36c4ac7797a4635793f89c44910f7f2b63a9a3d491e6a03cee8459a5d051  release/kernels/cas.log
0ab31a9443336fe5d08e1a5fa5fcba3bc279b19022f7c5007908d39d8ef39536  release/kernels/cas.oracle.jsonl
07a9a2c74729632c437b5bfc931b9b5585be7a892387e660cb127045c53014a2  release/kernels/cas.sv-hosted.log
58ea88e6696cf680a51a52518d2ce8b453d96ec59e999c7683c4154ceb39d8df  release/kernels/chains.by_instr.json.gz
e1d4c5b6f6553d7d2458af92e286e0ce5bac83f313f2002c4c4b4f40740042a2  release/kernels/chains.by_unit.json.gz
6e0d095321f97cf86811fb152219d5b6a4e887fc54ad1f4fd5e559f32145cf64  release/kernels/chains.ccvtrace
17038086c82eede07c9b11c8984a145cc6c6151e5280902f9ade357e56901816  release/kernels/chains.log
26a4cc5c5524c7219d8706c2582c80357dea60be9d6ffdec99dac7d0365e2264  release/kernels/chains.oracle.jsonl
a8e299388a18b7382c912e75c892897e9fbfefb2c1a503de2a3eb07e1efa18ea  release/kernels/chains.sv-hosted.log
6bc2fc24032aecceb307781153c57f8fcbfbbf4eadf59fbb1a6c1d3272872df5  release/kernels/coll.by_instr.json.gz
bfbd5eb9fd309cc0bd27536d3569e216a46759595a927c65897fcdccc91298f4  release/kernels/coll.by_unit.json.gz
3762b3824dc9a96c20d7dc82947e7bf8e6b1dd318f73c9bdeca10d8f86d9944d  release/kernels/coll.ccvtrace
0e6a0ad8c11fde3f73a7a9336deff59f1c647ac0a8c0c4f3664f642d2aade93b  release/kernels/coll.log
dd718d23c88df5dc7d92b055d8542865aa0e029118486af127312a8a578cfcbc  release/kernels/coll.oracle.jsonl
f55cea9b4f030adcd5fb63702f1c413325eb862c1a7cb49994a6aaee0786beb7  release/kernels/coll.sv-hosted.log
d60642eb2f78d8396be9bfc13c606f5bd32959e98ea72e02ccd181bd22913aeb  release/kernels/div.by_instr.json.gz
3c953172b650730ef95926e2c896cb42ef67616cc62f265b55c86f8ea03e4761  release/kernels/div.by_unit.json.gz
afa661d89a3f00449cb5bda98fedabd73fae73279bf3192ce9eb9f55c9bb6ea1  release/kernels/div.ccvtrace
a4462adfc79ec3d45f8b1110d29ba7ec90563d91eaa481c4e653ace4e5b06acf  release/kernels/div.log
71a567b85cf85622631490187563de9a5661099c78a590adff4ed0a0c3d24c16  release/kernels/div.oracle.jsonl
01a741d3ddf76d39290662fa987f73de22139b966195556877e51e3f72508635  release/kernels/div.sv-hosted.log
1cd256a107895d13328f63936687e609decbcf37249bc6e646823e4088851409  release/kernels/divchw.by_instr.json.gz
193a22b79563b069c018ae211aac4ddf34bc84e18d7dad0227938cc61da80991  release/kernels/divchw.by_unit.json.gz
9ce148460eb5a8d5b7a5a9e3515e0312f4506c687a04798281130666885620e4  release/kernels/divchw.ccvtrace
ec3288779cf35de1931359664969c8760225430b8998588f3fec4f283399689a  release/kernels/divchw.log
58a541797f7a2df0a1c7528ae6a3edec212db90c7d3eb20656806f38b5c10b3d  release/kernels/divchw.oracle.jsonl
63b277ec14a7049d31d3f24802f6cc7beaec3c82360de819732040421b9e5c1c  release/kernels/divchw.sv-hosted.log
34307eecd86ffa88ed37371185a9407e63a364f3bc4020456e075ded09deb432  release/kernels/divtail.by_instr.json.gz
91971d9d2c04291e84ce427b9a3c81c33c6cf16bc267ec1a0d8b5498e9614eb0  release/kernels/divtail.by_unit.json.gz
423d1be0830b8eb1f8dcb237ab56f5a611e27b4c61b3b14452a4cc5bece0d65b  release/kernels/divtail.ccvtrace
efcbc091c0052371a944535e887d9d2eaf262e919351fb7cd64cd12abceab439  release/kernels/divtail.log
75f11a75c9b3b336e446140af4579f05b46c363a76b7aab3ec88154a07ba097d  release/kernels/divtail.oracle.jsonl
22912b83498f6db5bae1d283217380cf8a161953cea9a98b814723a847e63fc4  release/kernels/divtail.sv-hosted.log
adf2bbe55dc6cdd764a065b6d6b8e7a4b4663bca967208d9c34e87595128dac3  release/kernels/divtail2.by_instr.json.gz
d950f12836c6006e60181fa111ca809add461aefa0ed2be796be48242bbb12f6  release/kernels/divtail2.by_unit.json.gz
7318a5b63e5a0376137977677b7bfd8830283bfac1c9e4d2d3fbe8af9a4ee8ff  release/kernels/divtail2.ccvtrace
e79718018ddc531b9d42364bf06628a117dab83f08c2920bf4e7cec446b5720a  release/kernels/divtail2.log
b2db6b05eb6cf4a0a7677e31d0c6c2952d5cab49d353f0bb1883fe0b2a20ed14  release/kernels/divtail2.oracle.jsonl
a7624ea135187fcf8109c01fd92c32c0c7d69cec168d85e3d551cac7016ed77d  release/kernels/divtail2.sv-hosted.log
6b88b23d84714fd1ff7da47e6c5662c87e3e54b35a835d57d1d54d08b5f0df34  release/kernels/fence.by_instr.json
f5d98470202a1df2ea0405e8349475016e4e5e9ab1a4fc09de6fb98b4df68316  release/kernels/fence.by_unit.json.gz
851b82839626dd37b6325743a29c7a07ad5deb97a52fc9f9278827cb0255b8a4  release/kernels/fence.ccvtrace
4fb3b513ac3706d718bee29502d215d5d252a9bfc51e742dc47431201dea0f46  release/kernels/fence.log
d1d40317f6cf5bfb430cda1f9c0ef676609e59cabe2a11623c42ffbeca93142b  release/kernels/fence.oracle.jsonl
1ebd80944e080470c0d87ea672deb04509f59848d7eeba3583f28f0fe41c1979  release/kernels/fence.sv-hosted.log
d140e924831930fa737e94bb66e109b49a0fbbca6c5cfd7b8305167e9c94bba9  release/kernels/gather.by_instr.json.gz
b6383de3b57c71aa659f6620551491311d337f37005cd24ff534c616b21ef4e4  release/kernels/gather.by_unit.json.gz
bfbbdf573c0e26acfaca5b68c3a5c19bad1ba21717392d05966451f86a4822dc  release/kernels/gather.ccvtrace
4ea5fb8a6e8787c085a6eb5d3b1d91dab4e506417f461820f9d2c76bc7c05efa  release/kernels/gather.log
0413e781d8d6ff578c64eb1f800b7931e66f676d5cdabb97b94a4033e6037662  release/kernels/gather.oracle.jsonl
4a64f566b8b3118a7e41dc377b133f3e973b07856cff633ad6ae5515f395be88  release/kernels/gather.sv-hosted.log
df901d1241e3ac72b103d655042ae2881cf9ecc638a406afb759b1629c2a8bd6  release/kernels/hit.by_instr.json.gz
ef776701e0b44fbe5d0f07368b6be6e6f46f2757aab3ea3eb18192b6601f2f9c  release/kernels/hit.by_unit.json.gz
bc422f237fb22e88a2a634b3f14c87e3cf50c1ea1bbc09032578c55dbcf7068f  release/kernels/hit.ccvtrace
4d2023614dc4afb7fe24088c5e6b47191985a47b92d1c5604aaa5d6a5c1307f0  release/kernels/hit.log
7ba9603e0088d9164de6528f16ef6a7fa9ce5821c8c12b52cbb3734e39b9fd52  release/kernels/hit.oracle.jsonl
67864748b194ec11b6fba5f65eb7b9b4e0c673bdfc4f3a662f940d8b5c04f68f  release/kernels/hit.sv-hosted.log
f7ac4ff4a191edbacca080d02fd55809b1e948714d31e7fa06108a04f0510534  release/kernels/lanectx.by_instr.json.gz
3c18c2eb80be31cb5974c8874173abb846bab51b466b3ca4f64185b4e51ef449  release/kernels/lanectx.by_unit.json.gz
d5b66b1134115801e4e2af05622d5b6575d1aa782fd32acab13e61775f0ace4a  release/kernels/lanectx.ccvtrace
17303dfed26ab81c0d23a0ff6c0b705da05bb945b8b9a6da5f596f859bfe75db  release/kernels/lanectx.log
888551babf540db8e3025b82e65ca655013f93eba3c8a65689d069d52a7e6039  release/kernels/lanectx.oracle.jsonl
226fe85c0f53b1b2d884f8e0e29267883ab8666c4146171a238e63fb03cfcfea  release/kernels/lanectx.sv-hosted.log
cf7d0d28e05a53e7a6a3cacfa3906ccd3c031af84330761ba9aee9a3f6bcc369  release/kernels/lanectx2.by_instr.json.gz
b01c65d76ab91f110743ab3afe81d2c4b0919823966487f2c22e717ef378c88c  release/kernels/lanectx2.by_unit.json.gz
5ee1b7149af6046c44f881e22661045fc31433c819b136451b42ca921a0092da  release/kernels/lanectx2.ccvtrace
d95a004ae6acdbea5426d50f16a989bf99ccb1649efa633146852636840067c3  release/kernels/lanectx2.log
45c13056dff5c73ed0c9ece56cc36f929bf335322193c7d5eb38710b1d1dfb02  release/kernels/lanectx2.oracle.jsonl
7fac6969ffd532075c3d29f742b84d519ba2926b20fda618c8aa2792ecad7254  release/kernels/lanectx2.sv-hosted.log
dc4e8242fa086ca97c9f5a426f10e9f7a0213f7cdfb55e968faf0ff9605e994d  release/kernels/late.by_instr.json.gz
776be6b68efa70b24c2daa00335c4eb9ee99356c3e08e633d2b2c8b16ee13b83  release/kernels/late.by_unit.json.gz
a75891694f84bb5e60092f6767802e9651fcb425a2cfb438dd5bacac07980a16  release/kernels/late.ccvtrace
1a1bcf07749573fe53943ff499b7d89c2cea909e9f08760c8f28079ee89fdf8e  release/kernels/late.log
86084f6bd747a2cf32acbc0ebd96ebd3e4ef2d8d9e21be49e3ae49290d7927f3  release/kernels/late.oracle.jsonl
f05d97e4d40ac7dd18cd7f935715cf1cb9d1494f702cbfccea2e0293d8279456  release/kernels/late.sv-hosted.log
710dc41debb343edd0ad4ef8ba4c09596dea428c2c278981a19ef83490bda8c5  release/kernels/ldpar.by_instr.json.gz
cc5b3b6091d50d4815c028910dbb0a2bab16aea1276ef4e45eec11742b8e65cd  release/kernels/ldpar.by_unit.json.gz
7e40f4ed8e582ab74173079682342cb738d83d39a97c7ca4ca1beac0d97e1497  release/kernels/ldpar.ccvtrace
05abd79fe8e3c055712ee8af3438b645e63c18a60f3b23d6f729c23599cb8ef3  release/kernels/ldpar.log
8ac08538e9c807637babd61b31e340f7461878ada31f0c0b83cd66331cfaf486  release/kernels/ldpar.oracle.jsonl
825177d59a4cf222fdca7829b789b3797a89dfb2f8c16b0bf0cb683dc2b56ff3  release/kernels/ldpar.sv-hosted.log
51ab3ee2c6fcc17ece6bf739a010f3f37a71fc21a06b937aa67260db469fc9cf  release/kernels/lnorm1.by_instr.json.gz
7cfea4d413f241c59716e0b802804664c940f21dd581c447d4c4591d66957f4b  release/kernels/lnorm1.by_unit.json.gz
477c69e023134c5db665626ddd1f77d9b4c7cf909003a7baa04cdf473c12df5e  release/kernels/lnorm1.ccvtrace
0ba51447e579ab5edf752c2a1092e7f9df4324c6ab72379065f9ce3eb4a3fa73  release/kernels/lnorm1.log
a8d85811af988a1b9fc00db1517300af3d93ec8e589e403d3b9113fa9e0ffc86  release/kernels/lnorm1.oracle.jsonl
80a0f974cd32c6b1190ec88015de10bc68ef7e3a92875599b722c8e5d34a1149  release/kernels/lnorm1.sv-hosted.log
9ae42434660363db566ef509cde28d60d4b497b91f4c687017e60def769ebc7f  release/kernels/localsp.by_instr.json.gz
ed3afb24e5096f547394ac355755f875ae7d1af934b159b289440f6978afbae8  release/kernels/localsp.by_unit.json.gz
7548335b65034560aee57a2368fcb8c86eac66d19ff8ca69fc0794ace801d21f  release/kernels/localsp.ccvtrace
145d81b566740c3c48acc4ea417a5518b0a1a2d2e91771f1c7ec8704bdf8afa3  release/kernels/localsp.log
55e3c9f36e7f7d38c0ddd38903aff4bb4509ae862015c592e6b937ea258042ca  release/kernels/localsp.oracle.jsonl
9e2652d92fc748aa3a1088ae8e1d9e945b6bb38b4bef345834885427bb8ffc5f  release/kernels/localsp.sv-hosted.log
5ac61b6ff903d7ee7b456727d98535b10109df4755cc8249733cb0b87df0c2bc  release/kernels/loop.by_instr.json.gz
0ac67e433baa82c4599b24f6613b9862d774691402f5c7333696ed3f7915b5d5  release/kernels/loop.by_unit.json.gz
72abd321dfbd0f37886b1bba86b88fd77245016c27b4d87e6a56043567e2c98d  release/kernels/loop.ccvtrace
95577315961e0d18064c954d82b7100f3a7dc26da98851d7725e0d4e2339200b  release/kernels/loop.log
03ce5920c06c93e93516d8e53c3f7169f14e3593de204eacceffc0b8a3e32016  release/kernels/loop.oracle.jsonl
67df270a60d65cc748da8871ae706f8f99ee4f8a8da7b70dfeba74ec473fbefd  release/kernels/loop.sv-hosted.log
de3d55b712bf591220a2f8b9b331cf0532e664687a512ea74ef0cf187b561b37  release/kernels/merge.by_instr.json.gz
3c9a6319a624cece52dc39d80ce3e040e2b2f887c32bec27c0304041e915ab2f  release/kernels/merge.by_unit.json.gz
a8d74967144ee4b4bd6ad87a20e05aac0925ba5f442e0f085929e688aed95403  release/kernels/merge.ccvtrace
0c4e8c75c740e2d3583b6a3b1ccdf9df16fd6d1a9ae859b2d93b269eb7124d12  release/kernels/merge.log
f96d28815f8756b1f5a45ded53e6170883d2dfa10f9eef0d14b8050b1318164a  release/kernels/merge.oracle.jsonl
6fa3fd383eb0d6739482594c544a0775f01bd8406df1c3127d4102c1ecc65f7e  release/kernels/merge.sv-hosted.log
d992fb71d3c1c6d4c0c777b0028ae1167670e0315c85f3df5dbd7b7a635c61fc  release/kernels/missrun.by_instr.json.gz
7e8a1afa6fcf33935a5cdc10cbf8540ba7a1f053f0a8a6bba27d7b11dcb81c1d  release/kernels/missrun.by_unit.json.gz
60a010274d29769ba20803a40bb136e7153e845726e9bb47d6bc0216fe4efb88  release/kernels/missrun.ccvtrace
b21f82b9228e087a7f62888d2b9999a9bbfd07c22e9c7d68743ff4bf90c4cb1a  release/kernels/missrun.log
531bdaf281e5590774bd2775427f25e4cc0419cf8e3d5b6999843ffe9ef87258  release/kernels/missrun.oracle.jsonl
ffa5afa7436dad0b9cef368d3ae970fd1316f2386471910b2d79e7a5ecd6df93  release/kernels/missrun.sv-hosted.log
42be6b8acd3c4135ef51f7bdac8492187666b746c43e9c7e74681200ff9f718a  release/kernels/mload.by_instr.json.gz
29e201fa19ea24fb15c217c9cf293fab1da4ec9bc56d030c96f415f8b76c668c  release/kernels/mload.by_unit.json.gz
0fdf9d0866cdc67d5437adb8641b5705f50fc9b10a2b2aa7c9b7b89d863fe438  release/kernels/mload.ccvtrace
dc12e5fe4a8f4275055cdb173d4f205468f5c79c05fb0e2df3f8d185b3f86229  release/kernels/mload.log
8000e477b9a95dfb9f0af964e8346acb9d36f1358fd06ffc4ff7cf599d2b8868  release/kernels/mload.oracle.jsonl
468cf269c4c06d0930d1755e4ce047d2c5222501fc2c237791a3e987df28d1fb  release/kernels/mload.sv-hosted.log
ca9b5a956a216a7bdca04f47d39ce836d57843363cc20b9c950a85261d0cae30  release/kernels/mlp.by_instr.json.gz
d239e29e7f34b07d0792eea449c961d9a9e4b5c39b8f91e97462ece54d6cf482  release/kernels/mlp.by_unit.json.gz
fa560bf9bd386288984616514f3301db3de5626bb78cd85975c4379dfcaa7d6c  release/kernels/mlp.ccvtrace
663e5791fa4a2595c8c2d4dbd78a97c15bdc59d9aa4963acfac6e10ba521927e  release/kernels/mlp.log
138d282f88d56c8ad648a91af0a983254b55d9fa22942c00d47b327f516a6e44  release/kernels/mlp.oracle.jsonl
ce28a3131a3c57b135b34788ee114345118a60bd861f91217edbfe84da501ce1  release/kernels/mlp.sv-hosted.log
f5d12791ff9ca8a232c7804d29e8f5d865586989369d1a028ae64e97d71ff0bc  release/kernels/mwmiss.by_instr.json.gz
7939c2d38c04e3390c2cd38b274ba37c730da7004b33d5a7ca5df72796ef4b3a  release/kernels/mwmiss.by_unit.json.gz
72968f2e3116db34104c799396a03347daf62f241e626f6a1ee89cc493f433e9  release/kernels/mwmiss.ccvtrace
4495e1483809dbd02df4a66cf83a33963ab3438062664aeda37fbc12fcabd5c7  release/kernels/mwmiss.log
8abe8e8997456a2a6711ee72da54d854b24e20abbdab28e4b7271c0d28418de8  release/kernels/mwmiss.oracle.jsonl
16e95f6c7fcfb91d7f03404626da06b7c2a8d2e1983b2d08a25dc7cf644bafb6  release/kernels/mwmiss.sv-hosted.log
30052add4683ac13603d859308fa14c26f8fdc758d71c07a05d3db46b6fd7121  release/kernels/narrowadd.by_instr.json.gz
f14e08c0e5bd2aedabe1bdcdda19493dabc1dcb12948d332584301fe759d5fb9  release/kernels/narrowadd.by_unit.json.gz
eaba990031d661ae76dd290f0f3c794a7955c1fac7ddfa5928186094b8abd950  release/kernels/narrowadd.ccvtrace
2184ff8b5c34a5079d953ec22a0261e335af6fbdbee6a454b89916ff5d62c021  release/kernels/narrowadd.log
40a2cf629853dd404bb06b4a07e35abde3d12efc13f26ffe28f923daf2994574  release/kernels/narrowadd.oracle.jsonl
b5470da13601e0fcfb7f0b7c901d1155be203505727564880008160c195fac95  release/kernels/narrowadd.sv-hosted.log
99ca7200013e1c8a7d0eeb0069f1bdb82f7c443d3af19491b15e7458f7855590  release/kernels/pguard.by_instr.json.gz
32871f73359ee5bb0d0c789a60e2b79286ea00cf867c5251ab9623e5fb94a0d5  release/kernels/pguard.by_unit.json.gz
3b56006868b45f582561dccb435ba57ea8d800e4dcbebcac798bed592041dee0  release/kernels/pguard.ccvtrace
d78c48c368ed6b5d4cecb33d8b6bf4a849ddf729870a54f4f11e1932982af933  release/kernels/pguard.log
690e56f1cb8d97cbf67124b7dff3ad0a90cb8981814cd1709cf0cd0e035b3bd9  release/kernels/pguard.oracle.jsonl
cac9b908a0b11295e6b268293fb6405a256e7ad21b1e1654f4b22abf24792792  release/kernels/pguard.sv-hosted.log
ccc56e458d6df3e2a4b1832631e4950d5c4127b47a97ca701994ebbc8001560f  release/kernels/plog.by_instr.json.gz
6069a0955dd208858b751ace5c724b96ac70544b3a85ba33ab0c078d12990428  release/kernels/plog.by_unit.json.gz
0cc33f3066dd4ae74b2296e7d22a3ce494836416ce6f69536758b97df8e156bf  release/kernels/plog.ccvtrace
950e21ab65d30856daf26671cf6bf7ac47b78552e17e8c1aa5c47e83eabc7b94  release/kernels/plog.log
0c99915e2da60f4670da00504a6371d7d17701d4431e733a3ff8fa98a2030d6a  release/kernels/plog.oracle.jsonl
f475e4d67a0c2d4fd345581c8193d11a3803c410ea739d321b04994d2018756e  release/kernels/plog.sv-hosted.log
094a862ca16fcdf5a42f91d363d221ce0a2feb4b53657a20a3962cfccf0f8235  release/kernels/pmovdiv.by_instr.json.gz
6da6e81ac30ba225dd514145e5c5c1a7817d12ce6afc5b84ba77c83ed365c3b0  release/kernels/pmovdiv.by_unit.json.gz
231a3dd81b74fa2103ab2345699f1f0e0f4e412e85827b5e835d5d1c952eb6ae  release/kernels/pmovdiv.ccvtrace
165329c19f2cd1b4682252353a170783f76de7b8ccd1edae6e2ba00ee80780db  release/kernels/pmovdiv.log
7bc646cff6166a51bdce03d7c1b7209e871f0a91d743083a9b910a80bcd0b33f  release/kernels/pmovdiv.oracle.jsonl
2d8d6fb1cd47ca243e90690336239742f4b0569942bc127ad0847653c5c4167a  release/kernels/pmovdiv.sv-hosted.log
85a9e2a4e5aa6e0394ebf3661cb76f13c1b67afa09e4118be1073ac335a5f4f9  release/kernels/predlane.by_instr.json.gz
244256fc04d66b67dcd057e7ef148aee4ad0a8b014f6cd8b6c9cadb409607110  release/kernels/predlane.by_unit.json.gz
eb789d73b076373515f510599083b24f2501a0bd4e20bbd32f09b292b112c02d  release/kernels/predlane.ccvtrace
8c4a653f5294a203cf3b88e7da6b1eaa04ecd0faf3131afe7551db0e1d10289e  release/kernels/predlane.log
c45f4177b9e84fc8a6e36b13534a0c7636eb30a3f8531847100ce5e23bf404b1  release/kernels/predlane.oracle.jsonl
64cfe90f65962aae2fe956df3f0287c1c0a487a310d2e76a3713f31638ab04df  release/kernels/predlane.sv-hosted.log
0bc1b62e6a7358b919d17c86d0a12666ec14ff0be574e9874d3622cc2159294f  release/kernels/predmerge.by_instr.json.gz
adce4a8dd68654c84ecb94783cf94df59305e742f1d81c7ffe4817f17bc208cc  release/kernels/predmerge.by_unit.json.gz
992d9ed5bc1841229c645570617d50962aaf497fbb55d502a1af8aab6dc39499  release/kernels/predmerge.ccvtrace
8f067d385cf0afab6e862f2a895b3405188d7a4cca304332b86c5b7960e58982  release/kernels/predmerge.log
6c737c49434bcd08e3e0814c8b1dbf15c586ae74f7929ba3148ddcee2c62c845  release/kernels/predmerge.oracle.jsonl
6538ffad814f2a3bb6f55f1bef5ae11e7f85c9a01ce6a28290f4d7df180274ec  release/kernels/predmerge.sv-hosted.log
8d5f6e07515345555ea7753bba0ae8dba211c950c3c1f7a568869d2f18a0590c  release/kernels/predspill.by_instr.json.gz
e27bf32debae088f9c3f5ea49bf5ae847f52f53a571a7af5c2c7eafc78558abf  release/kernels/predspill.by_unit.json.gz
92f4a10d221f22f74ceb7c73372973b49d10dfe6e1fdb646f84723de6004b45a  release/kernels/predspill.ccvtrace
e96494394e32dba75c3eb8f93ca5fb4743d861a8ef33c5ca4e96f4d2dfce016a  release/kernels/predspill.log
b7c84c6478117ffa0f06da0e6ad1e4628e2683426a7911080810e78e06a5242e  release/kernels/predspill.oracle.jsonl
578906b0ac989d3e3872bd8febeb44f255a1181aa37b0a7cf93e8a285015b203  release/kernels/predspill.sv-hosted.log
91436207bd2183e661b1503bd098b17056e0fd7e99bc13bab4663e19b6e1e656  release/kernels/predswap.by_instr.json.gz
ce940427f475a5bc1913e4b0097c28924bccbcd8bcb6602bc91ebdb4f5f69e21  release/kernels/predswap.by_unit.json.gz
f793d03da341396628fefdbbe49d9e5ed50de9cb68b64b7c74b5bf0fd183925e  release/kernels/predswap.ccvtrace
253ff10981635ad5684e9ef9818f3d383312e940e65cb6477edfc9002b9b5be5  release/kernels/predswap.log
a6d4f7ed517553816d889c7c9eeb6bcfd1f6c973fbf682ecb69f3c2de619f7bb  release/kernels/predswap.oracle.jsonl
8cca0f57e23ca8ab4f23b94cda764a44a8a26ada23067a2b3a818014899e6582  release/kernels/predswap.sv-hosted.log
27d7c8071fcedf4644942e1fcc530c36a5341b3313b8f7208b82fcbe9f7f5668  release/kernels/privwin.by_instr.json.gz
e9a20d211d41f8e6ace6d57b22f453ffbc71b9948c511e4b18ea67986bfef53e  release/kernels/privwin.by_unit.json.gz
325bce511eb4675b8e5bd663900b9a72dbd36c66caebd7a33c5d8ce939241e87  release/kernels/privwin.ccvtrace
c5df1f91d99233fca8df94ade4f20dda846e5658fb5fe8897f8a41d60e086b39  release/kernels/privwin.log
861f686fc4480363472908d679d8815e8c957d768e7ab32c826930527b0fb7a8  release/kernels/privwin.oracle.jsonl
171bc5bd144ed86472c6fb2c215aef3a30f4b8268291b1f8d52b9ff617f574f8  release/kernels/privwin.sv-hosted.log
cd4026cb507c11f70f2673101c022699bd42dc69444dc1313b2c8cc42466495a  release/kernels/provswap.by_instr.json.gz
5babfc839b59035d8ea26585aba662d207db381aaddb37f0b61dd2b22bc6e945  release/kernels/provswap.by_unit.json.gz
0fec44b3b5cb0562290746e2d1014c88182c6a33b0dc84b07f704fbc7dc2aa46  release/kernels/provswap.ccvtrace
0ccca9556ddb76b513877830f163d0a225dc04ea17d3832eaffacc29e8ad73a1  release/kernels/provswap.log
c9c32a793d54cc7401477f582487f7e8b345b2669a75337b8d6327120d98e5dc  release/kernels/provswap.oracle.jsonl
cf95c6b540ec748a502138926666db67c6785f5fe9b1518f5b5805d670a96259  release/kernels/provswap.sv-hosted.log
57e11d5e54e9acf355fd8ce7d607196d566a240231bfd3ec54f112747a5223c1  release/kernels/retmiss.by_instr.json.gz
fb207c9471bab5b9d47c382d3e7cc3179a4a494c902b2edd94c45a64e55cfa36  release/kernels/retmiss.by_unit.json.gz
a94b952d7ddf4182c6bddd62106ee6e7d5afd002a8c763335f5d4120dacbb931  release/kernels/retmiss.ccvtrace
745020f73edb3b989781696be4734528346e677e484a36702ed84a5ca2bca571  release/kernels/retmiss.log
e5ef8538e838c6cff7febfc679dd091cf5e002f82d34f1009b1948ce22bc3649  release/kernels/retmiss.oracle.jsonl
941accd941b5f3fe99aa75e4c29b777dbb1dca1b9f7e4ac32a5bae7a756fc31d  release/kernels/retmiss.sv-hosted.log
c5ff1730f30873e277e5d962073b2f8a2ea8e82cbf83d046b24cb75b68797210  release/kernels/roconst.by_instr.json
aff2f6ba374c4b2edc0b4b13d953a14148d131286d30cc55dea555cb22b1b61e  release/kernels/roconst.by_unit.json
24e16ea5a89c0da7406ac67010ed1e91278e7e70007de5fd3c5e0e848c30ca5a  release/kernels/roconst.ccvtrace
494fc327cd7db4bbda75ead1a960b5cc2c6390a9eb632c53d924434c0ef4f183  release/kernels/roconst.log
8087c0671de620162881aecd38cd6114b78e7be6bd71201e3ec02c9a2e2e750e  release/kernels/roconst.oracle.jsonl
95742cfb0a895000922ac838bc0c807e48843a5b48264c32be75a269fd02cb9f  release/kernels/roconst.sv-hosted.log
8a379537853667bb0ec4c1843eee518dc465010710d108f3e114d66d4c6cfb3e  release/kernels/rogated.by_instr.json
c8d225736624bd39129e4faa756578f2bc5befdb805e6e2a3b24fdb617a895ed  release/kernels/rogated.by_unit.json.gz
631b1ab4d97f56e9c4e84621330223c13a652a9ba99663e4543231ef82086049  release/kernels/rogated.ccvtrace
967b63b0779565534ed14849e12e764c85fa1d5d58327962314628713d519d91  release/kernels/rogated.log
7cd02bd4cceec5a044d6b4d6a80df1e68ed0ae71b0b2a953143636d5b809ea6c  release/kernels/rogated.oracle.jsonl
d0f1168c673660e2f43182c320ffd4d5824cb65aac9eedb3bbe3a1276dd2d4cb  release/kernels/rogated.sv-hosted.log
514cf0c73191b826cb2177c2c317459f3ded2cc48ee61ed4ed2f8cf712afb283  release/kernels/rokill.by_instr.json.gz
550e4583f37de3b6933c58f52579f0c4aa943ed90fef49932aef72c3f1bc371a  release/kernels/rokill.by_unit.json.gz
55f1d311748482da87a37d632ef2903bd8d8cbb08eaf1fa08128d9d4b4fc6657  release/kernels/rokill.ccvtrace
0a224446371827af3aa6e2a2ff7bc3015355c20c5b05026f0fe7d9491095620d  release/kernels/rokill.log
94efcef96af469a512d346ce61623980fe86383188eaebd55120f716db596f14  release/kernels/rokill.oracle.jsonl
5a67ca3a2a1d7da30e1a0009030e8fac735cd7f25aab73097a2c3a2cb1334cf5  release/kernels/rokill.sv-hosted.log
4ce3274ce40204c6adc0e06032de0b5f3a9af30d7eb9f93cd6a4341e23a1ba5c  release/kernels/rolaunch.by_instr.json
32a781755aabdaf1378a6e47b5d441c07dbeae5411b40e2456cddab84c3d9377  release/kernels/rolaunch.by_unit.json
c9423aa368141c32db86d8f3699fc646239c555b49d5d1a4c2e3e8b3042c37e1  release/kernels/rolaunch.ccvtrace
815a52d7fef6048024bb21899b0c6bfa2f645b3324c929f7e39485deda041c84  release/kernels/rolaunch.log
e7dad585c3e70615de04330fd03f4f282c29a005dc1732a35655fb261d51139e  release/kernels/rolaunch.oracle.jsonl
de169c15ff4ffe4b27e792ef8514937add4b95cbade8714190ca03586622ca19  release/kernels/rolaunch.sv-hosted.log
c5ff1730f30873e277e5d962073b2f8a2ea8e82cbf83d046b24cb75b68797210  release/kernels/rolimit.by_instr.json
43430520f2f8de48bd6a6b0c767269a2ca31c6f08350cf47cc0beb21e8cb2eed  release/kernels/rolimit.by_unit.json
da82ea8ac380b275123303019058883c223ccdb993176d9f14ffa9730f395f89  release/kernels/rolimit.ccvtrace
e0fe2aef239b29aa5c5a9beab75d32011361fe49e69b6efe59169eed5c4b061c  release/kernels/rolimit.log
1c5bc0cb8e8b2e69505fb5a551a16d5d10c56f232b88da7a27e336ad7d962de2  release/kernels/rolimit.oracle.jsonl
f7c55f05f049183564836ec28454d90670f068222d67ad2ab5bd36e20b98c22b  release/kernels/rolimit.sv-hosted.log
10120bb9ffb3ded1ecf776672715545e41770f1d0c3ff10e652261fcd64dec82  release/kernels/roload.by_instr.json.gz
c541689edbb1438ae5b2186da9d4c7b97a489621a01a685d5ba71f436eb9f82a  release/kernels/roload.by_unit.json.gz
9db58d0519c28e63306793107831abcac7824ecabeef0820a22e280b39799cd1  release/kernels/roload.ccvtrace
3e8adaeaab7710c41cc0cbee77cd72198bbc26b2d187bf70cbc2f17d635dfc25  release/kernels/roload.log
f7c1309cc9764769fb5803f6fd0f2f5e1eb418f2d23fbe5e17cf5f9106869fdf  release/kernels/roload.oracle.jsonl
ef65ee70ee511187845bf8d55f5b65bcef7ba2168508bbb900b452eb85b376e8  release/kernels/roload.sv-hosted.log
bcc34d55690a71a7c723654aa927bd1fa9a15fcb2acdcd555477a62c4741f06c  release/kernels/rope.by_instr.json.gz
08e3ce8095fb8dbececc17ec3b7060a9ca1a512f04d6bf051ef679a39ab01b83  release/kernels/rope.by_unit.json.gz
1a9e2f663f827ca30a249aa74cdf970c81348d8ed41c1a9499bc8573ec861b6a  release/kernels/rope.ccvtrace
bed846f2d8b5551840fdd0d9a83995feb63ea64b60a892f6a2bef1ffa41d0512  release/kernels/rope.log
d55f9efae392dc8877c102c01c0810e7654b666b6ede386328108164c6cf88f3  release/kernels/rope.oracle.jsonl
356ded303396742d82635fd7226479eaec9e2f602c5cdcd7fb33d0fc0bdb1182  release/kernels/rope.sv-hosted.log
4cad773c8f275b2f6d1ff0e8bd17c442662f5111f32f2e1536542e6d8f877be9  release/kernels/ropediv.by_instr.json.gz
8548280ec211c27e3d64676b208599dd54e9b98c7a68b80d81c40e1b67b0f040  release/kernels/ropediv.by_unit.json.gz
e0f90b60cb5893cc5e9839a74708848bc8b5409e2af972fca5b128129a3c2614  release/kernels/ropediv.ccvtrace
b14725c2f548caa6cb4fdd5b44469f1a7b022967f180f528421f43036d91fcab  release/kernels/ropediv.log
10c0ec6ec18b7b44638c790033109198c079d07c1537bf193353ccedd00a920f  release/kernels/ropediv.oracle.jsonl
48cc6c3a53e44bab58d572dd2721ef2abfcc6c406fb1103226b7c23a157c1ec7  release/kernels/ropediv.sv-hosted.log
ececf444c5daad6d65d2071f41dbd3b7e6f84dbdfad7784da2335d2d14532353  release/kernels/sel.by_instr.json.gz
9e94e37158c15134c35f1aee3dc461fb4e6a76686b36f225b0dddbfeb2893e50  release/kernels/sel.by_unit.json.gz
688c1614887034251601256381778a5d9009dc4bed01e11890a584f2cfaaf665  release/kernels/sel.ccvtrace
5020df1161245c5960188582d1d73b4580faaeb7bd6fe2e7900aaddf2d45d8df  release/kernels/sel.log
87f6a81e8afa004c8039bf2f61c90176fcf29ab29bb17ac44aa016a5cc8438fe  release/kernels/sel.oracle.jsonl
e4fef35b2df2ac61fb1142de561f84b7db9a6949ed361d06c2503c6374076992  release/kernels/sel.sv-hosted.log
c8c573862891e2f4d213e2751d3ace9ef223e6ac14eca8233422e19926ac8dbf  release/kernels/sized.by_instr.json.gz
3fd4642649f34298df3f35cf37753395974bb4864da6268447d6c379f44520d1  release/kernels/sized.by_unit.json.gz
1f80ee055c71f4da0b1411cd91f6b849d72a032b87e76f6d9b448fc37e51b495  release/kernels/sized.ccvtrace
63f95636d5d4c0425862898cffb0b89812d2105c0d6bec2db19f6b3468c7237b  release/kernels/sized.log
36d903ba1618bd1faa437c9812a6ee6c0c966a63196c796267d74bf2695ebc3d  release/kernels/sized.oracle.jsonl
9f2b96531fc62fe91852f45ff21bf37d7548ac9ae656a31053512770811e7227  release/kernels/sized.sv-hosted.log
514f8d4d30ad5733b218aec9d89651f4d0fa6505b309a500e7d696ce40cf964e  release/kernels/slotform.by_instr.json.gz
66b9f31a3b5bef3e9957a87af850e8767f9e9838184af615ee80bca9e48d4a5e  release/kernels/slotform.by_unit.json.gz
f93d62ae47498b83f4d72cb6de0cd18792372a17deb2fc2de7e5244c075f1e89  release/kernels/slotform.ccvtrace
1f79c19db62bb0c0f9eef1d7e97e2eb1a5fe780391d71e42f62c56982c546a63  release/kernels/slotform.log
8b61db7419b18cea8a646fb628218447e72e84a18a9891ffb73b441736138ab9  release/kernels/slotform.oracle.jsonl
135e3dcea84e8a6104c043a609cca91cf763846ed8d1d8eab8432e431e7e987e  release/kernels/slotform.sv-hosted.log
858f62388c8911cb989c7b1147a938a7709820d130e507ad79b3f4a2ec667a1f  release/kernels/spinwait.by_instr.json.gz
580ec4e34b72e0a559d0cf0515ee8871d5cc152a1465ba2818718e1c1b245cc0  release/kernels/spinwait.by_unit.json.gz
3961613ec80a3fbc0f5a67f9ba71fd78ed20ed0c29180ab124e8ff6aa8e0e5ea  release/kernels/spinwait.ccvtrace
65130011661c53771d8073cd3c89a6bb63bb29883971f906c17fc2135184bdd1  release/kernels/spinwait.log
868920637236c878b33779bd450439466fc3626996a3164573dc11d437d5c709  release/kernels/spinwait.oracle.jsonl
54b889770d58de32dd2321d1873e64ac5cb3dae48cac96b2141a831d7880d52b  release/kernels/spinwait.sv-hosted.log
eda5c55b8931906eb1a657fc6336928f2e7be9b3f8cfef947bcc06a19e51e4ab  release/kernels/spmbank.by_instr.json.gz
6359cd8e090ab661b18577fbfab56ea7928c1c0e6aed05427550cb85bc9e1657  release/kernels/spmbank.by_unit.json.gz
b41fbea616795bbf29c9e5a4fe7149db44bf3ded02d7a7358c49516a5bf360c1  release/kernels/spmbank.ccvtrace
4546faaf18deb38edf8b0645a03b1bfb927d2a82fec857f975035486fd49ee91  release/kernels/spmbank.log
3af490cc37d7a92dbe719b57de216b648536eb301ff9d13de9a39f50d150d725  release/kernels/spmbank.oracle.jsonl
30d08bcd47c7dd205b617576c1e750003a7d535208ef845b29a72aff03f70cba  release/kernels/spmbank.sv-hosted.log
10ee4d63f140a7a0ac263c45dc13226e19d7dcd015f23f7aee92ffad0d36eaec  release/kernels/srd.by_instr.json.gz
a6de0daeb1af930b32c5724b256e820573415b57975060aab5e0a9f5ea1d5691  release/kernels/srd.by_unit.json.gz
95badb026ccf14f957d3f0590ff6b6d3e65a1e3529a41b23e4826ee4473679f4  release/kernels/srd.ccvtrace
e4c2a3098a0a7ac41c6a3c9cf643e1b947dfbeaa12a8a55f779ec0165e9ff8b9  release/kernels/srd.log
b08eb5e3673cac7eebb8b72af5ed3783c8e70a9e96592e76bf3722551bc79473  release/kernels/srd.oracle.jsonl
07ca6d774e00dd17259a04b5139bd95ea30d961a77fe02c09d13454c4a35d4b5  release/kernels/srd.sv-hosted.log
8d886f0573d0f39150f4010e66e9a9c53f1d8001e4d7a93cf0ce027106d2a028  release/kernels/stall.by_instr.json.gz
234445a86cce53ca3c0a8e8c98fd50702e5db7008f84f9f06a1328fe2faefb57  release/kernels/stall.by_unit.json.gz
34f78c0c08b929b8c250af4c5aa11d6fd5e810a7d837af1098d0e45a41aad0d1  release/kernels/stall.ccvtrace
51d1fc31172956fbbcfa61cac85819c6f71c4214bca5f7bda9358d14809295e1  release/kernels/stall.log
500db2c482b07a0706583422cd68878301d0146c1f872ccc1f11bfdcf5c993ef  release/kernels/stall.oracle.jsonl
fd23ec8dbce5a06b48085b013d1b7bc3b89d95017f06ac3016f423d9e1e81a39  release/kernels/stall.sv-hosted.log
3e601d9bc26a2bd4b3afcaa8f4337784e24fcd587db277e430981e76dc6ab03e  release/kernels/swap.by_instr.json.gz
2b717ae6fa15aa0299f4a8e19454305fe83c16ed323099b0a2c3ba9ef1ae7f87  release/kernels/swap.by_unit.json.gz
892028773069382947669a8565e89ad81350b28f6e8861ba3b60e0babc696519  release/kernels/swap.ccvtrace
39aa781f6e8deef7e28a814007e1dbf2ef7fe429494665ab1ec14b27beeeb96b  release/kernels/swap.log
3658a26316c1ff7bc1744304a42f736e930fcde2865c8913e6cc67a22ce96667  release/kernels/swap.oracle.jsonl
2a4f047b911a1863fa1b9aa5d7218916776e6da9b051889c30ba1b028af4a7c8  release/kernels/swap.sv-hosted.log
5b7e67e832e2bd3554f2780260cad762fe3dd113d31a986480e0ef5f69af2533  release/kernels/transp4.by_instr.json.gz
542b206e52214c0f5bba1291eec7cdf17d901d8b09a974642eba55a13c2be90e  release/kernels/transp4.by_unit.json.gz
9c9f7435ce6e77777f6a8ab434e91b737f9a2ba7ebb3638dca45840e9251af08  release/kernels/transp4.ccvtrace
e01552b32817b0d63f545b48dd079cc66f0ed0dcc40d1f5e2f8f44c306131244  release/kernels/transp4.log
06396ace3ac19677fd39c700e408606e5bdbacb24997d663bbe8872e63dd74fc  release/kernels/transp4.oracle.jsonl
33075b66cf4a53e73250899eec75a3e3936f8b5f15b5a83f6680471c86f658eb  release/kernels/transp4.sv-hosted.log
2bcf56f0f6e5fa07a1a08bd24c6124a2c5b34c6bb001808edd88165c6b46d9e0  release/kernels/unal.by_instr.json.gz
f8863d232d43c773be3735d640ceab6522a9d305d216ffaa4ab6031b03364ac8  release/kernels/unal.by_unit.json.gz
1b3b224b0cca3352113bed47b586be34cf167a632ec031dfb10da1d35f0aed73  release/kernels/unal.ccvtrace
77e80513a79f1c7b20a6006c87b3fd770f00670e027195a964383123beb004c5  release/kernels/unal.log
c3d484bb160657a563df983d9a2532eac27f556636617960aa1e72183ac2b299  release/kernels/unal.oracle.jsonl
21ba44ab947f448bc249bf3a645a43cf18dedea53ad083961c771a4e7af83242  release/kernels/unal.sv-hosted.log
e6968ad5da976a41dbba69535ad8b5319b0723c845c13538448f7588b018bab5  release/kernels/vadd.by_instr.json.gz
a1949922dd2cd5d11d9d0bb350c657587e5c9aec1060c04c69dff4ef91e2fb82  release/kernels/vadd.by_unit.json.gz
0d57e0309bcd01a4cf1a43b5a5da28010c962d44c0d5fb2046cfddbd736f81ae  release/kernels/vadd.ccvtrace
dae5bc48b1509c91e324b4bcb79e9a7c9ce3b348b9d6450fe1a5bcd7f4c47cdc  release/kernels/vadd.log
0276b6d0611a4bbcdc004ab3987214aea138245bc7217504147331689a9c0880  release/kernels/vadd.oracle.jsonl
fefa99a4080a5817643ac0958fdca0effa692e45d09c47fc5c833ed454979832  release/kernels/vadd.sv-hosted.log
fb6b35be6f73c671e074186c1e9029e840130f7ac5b207357a59ac5782c93137  release/kernels/vadd4.by_instr.json.gz
4ef8c2ec0e975c4d4ca132dd1b99808bd84518dffe1870a9fdfdaabd7e2b8582  release/kernels/vadd4.by_unit.json.gz
3fdfa61b755ca9388dce7259081cda7ad6559ac7394e1956261e72504e3ba118  release/kernels/vadd4.ccvtrace
420872d019327f5b0a3db4f84d73fb02d153f8b1de5b754e771d75a62261af14  release/kernels/vadd4.log
225aa18fc9f38aa9ad615aa11de254337d59fa705877553d873062c68366e0db  release/kernels/vadd4.oracle.jsonl
bb8ea7682fb1359c4611b4e7ad2bf29b9b7bddf86bb8d37f2299a3662295bf2b  release/kernels/vadd4.sv-hosted.log
4cb10458909db8e7844a27af8a6b18b860311759b0d5e42ecae3f047c88d9401  release/kernels/vaddslow.by_instr.json.gz
f251bd14d0cf7410b7e97591826c440fb209c64ec73add99851811bb1cb9a460  release/kernels/vaddslow.by_unit.json.gz
324681a8412fa64ad998c3cb9eba5313ac695459354299dd5947c322f0c80321  release/kernels/vaddslow.ccvtrace
99ff1bd7c07c011552c0503b940b3957c35c15338ca9260650cc3cbc20dd309f  release/kernels/vaddslow.log
e9e6218e8b8450e9f9ff6b39d659c994a1e51c527a0c5bd10d18b5658ae0e344  release/kernels/vaddslow.oracle.jsonl
6f993763707b0a4d02d87d7e9636c89bcd0ec99883734d1457ca80d91714356d  release/kernels/vaddslow.sv-hosted.log
419731db9af163d1eddca865e9ce887a3361ff911a6bc78459eaedab62f47252  release/verify.log
56b3d8627d79d397ca06dfb57060015391cb95e52e925d1f09a4b2a7f4147127  release/wiring.txt
```
