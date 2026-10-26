# Snapshot snapshot-2026-10-26-291fb2f

**A generated, read-only snapshot. Do not edit or merge it.** The source
is `ti-ret` at `291fb2f84b053c223d65f68528a063f1cd60585a`, and this branch is rebuilt from source by
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
| Source | `ti-ret` @ `291fb2f84b053c223d65f68528a063f1cd60585a` |
| Built | 2026-10-26 (UTC) |
| Gate | `tools/verify.sh`: PASS |
| Compiler snapshot | custom-cuda-complier `release` @ `9d5db50105c695ac683ff8af8f345490cb5dd67f` (source `ef4b4adfb8980dfb1d02df73b7626ee983448bc9`) |
| Verilator | Verilator 5.052 2026-09-05 rev v5.052 |
| Icarus | Icarus Verilog version 12.0 (stable) () |
| Yosys | Yosys 0.33 (git sha1 2584903a060) |

## Kernels

| Kernel | Result |
|---|---|
| `addrhigh` | `name=addrhigh finished=1 cycles=71 from_fetch=40 retired=5 issue_groups=6 order=ok gpr_mismatch=0 pred_mismatch=0 mem_mismatch=0 check_failures=0 class_violations=0 overflows=0 credit_leaks=0 channels_used=26/55 violations=0` |
| `addrlimit` | `name=addrlimit finished=1 cycles=1071 from_fetch=1040 retired=5 issue_groups=5 order=ok gpr_mismatch=0 pred_mismatch=0 mem_mismatch=0 check_failures=0 class_violations=0 overflows=0 credit_leaks=0 channels_used=27/55 violations=0` |
| `addrneg` | `name=addrneg finished=1 cycles=69 from_fetch=38 retired=1 issue_groups=2 order=ok gpr_mismatch=0 pred_mismatch=0 mem_mismatch=0 check_failures=0 class_violations=0 overflows=0 credit_leaks=0 channels_used=23/55 violations=0` |
| `borrow` | `name=borrow finished=1 cycles=102 from_fetch=71 retired=7 issue_groups=7 order=ok gpr_mismatch=0 pred_mismatch=0 mem_mismatch=0 check_failures=0 class_violations=0 overflows=0 credit_leaks=0 channels_used=21/55 violations=0` |
| `brs` | `name=brs finished=1 cycles=100 from_fetch=69 retired=12 issue_groups=12 order=ok gpr_mismatch=0 pred_mismatch=0 mem_mismatch=0 check_failures=0 class_violations=0 overflows=0 credit_leaks=0 channels_used=23/55 violations=0` |
| `byp` | `name=byp finished=1 cycles=119 from_fetch=88 retired=14 issue_groups=14 order=ok gpr_mismatch=0 pred_mismatch=0 mem_mismatch=0 check_failures=0 class_violations=0 overflows=0 credit_leaks=0 channels_used=31/55 violations=0` |
| `callret` | `name=callret finished=1 cycles=274 from_fetch=243 retired=40 issue_groups=40 order=ok gpr_mismatch=0 pred_mismatch=0 mem_mismatch=0 check_failures=0 class_violations=0 overflows=0 credit_leaks=0 channels_used=30/55 violations=0` |
| `chains` | `name=chains finished=1 cycles=97 from_fetch=66 retired=29 issue_groups=29 order=ok gpr_mismatch=0 pred_mismatch=0 mem_mismatch=0 check_failures=0 class_violations=0 overflows=0 credit_leaks=0 channels_used=21/55 violations=0` |
| `div` | `name=div finished=1 cycles=977 from_fetch=946 retired=144 issue_groups=144 order=ok gpr_mismatch=0 pred_mismatch=0 mem_mismatch=0 check_failures=0 class_violations=0 overflows=0 credit_leaks=0 channels_used=23/55 violations=0` |
| `divchw` | `name=divchw finished=1 cycles=99 from_fetch=68 retired=5 issue_groups=6 order=ok gpr_mismatch=0 pred_mismatch=0 mem_mismatch=0 check_failures=0 class_violations=0 overflows=0 credit_leaks=0 channels_used=22/55 violations=0` |
| `divtail` | `name=divtail finished=1 cycles=641 from_fetch=610 retired=96 issue_groups=96 order=ok gpr_mismatch=0 pred_mismatch=0 mem_mismatch=0 check_failures=0 class_violations=0 overflows=0 credit_leaks=0 channels_used=23/55 violations=0` |
| `divtail2` | `name=divtail2 finished=1 cycles=1516 from_fetch=1485 retired=366 issue_groups=366 order=ok gpr_mismatch=0 pred_mismatch=0 mem_mismatch=0 check_failures=0 class_violations=0 overflows=0 credit_leaks=0 channels_used=23/55 violations=0` |
| `fence` | `name=fence finished=1 cycles=82 from_fetch=51 retired=7 issue_groups=7 order=ok gpr_mismatch=0 pred_mismatch=0 mem_mismatch=0 check_failures=0 class_violations=0 overflows=0 credit_leaks=0 channels_used=30/55 violations=0` |
| `gather` | `name=gather finished=1 cycles=265 from_fetch=234 retired=16 issue_groups=16 order=ok gpr_mismatch=0 pred_mismatch=0 mem_mismatch=0 check_failures=0 class_violations=0 overflows=0 credit_leaks=0 channels_used=31/55 violations=0` |
| `hit` | `name=hit finished=1 cycles=228 from_fetch=197 retired=17 issue_groups=17 order=ok gpr_mismatch=0 pred_mismatch=0 mem_mismatch=0 check_failures=0 class_violations=0 overflows=0 credit_leaks=0 channels_used=31/55 violations=0` |
| `lanectx` | `name=lanectx finished=1 cycles=69 from_fetch=38 retired=10 issue_groups=10 order=ok gpr_mismatch=0 pred_mismatch=0 mem_mismatch=0 check_failures=0 class_violations=0 overflows=0 credit_leaks=0 channels_used=29/55 violations=0` |
| `lanectx2` | `name=lanectx2 finished=1 cycles=69 from_fetch=38 retired=10 issue_groups=10 order=ok gpr_mismatch=0 pred_mismatch=0 mem_mismatch=0 check_failures=0 class_violations=0 overflows=0 credit_leaks=0 channels_used=29/55 violations=0` |
| `late` | `name=late finished=1 cycles=172 from_fetch=141 retired=16 issue_groups=16 order=ok gpr_mismatch=0 pred_mismatch=0 mem_mismatch=0 check_failures=0 class_violations=0 overflows=0 credit_leaks=0 channels_used=31/55 violations=0` |
| `ldpar` | `name=ldpar finished=1 cycles=155 from_fetch=124 retired=17 issue_groups=17 order=ok gpr_mismatch=0 pred_mismatch=0 mem_mismatch=0 check_failures=0 class_violations=0 overflows=0 credit_leaks=0 channels_used=31/55 violations=0` |
| `lnorm1` | `name=lnorm1 finished=1 cycles=2592 from_fetch=2561 retired=526 issue_groups=526 order=ok gpr_mismatch=0 pred_mismatch=0 mem_mismatch=0 check_failures=0 class_violations=0 overflows=0 credit_leaks=0 channels_used=37/55 violations=0` |
| `localsp` | `name=localsp finished=1 cycles=4275 from_fetch=4244 retired=40 issue_groups=40 order=ok gpr_mismatch=0 pred_mismatch=0 mem_mismatch=0 check_failures=0 class_violations=0 overflows=0 credit_leaks=0 channels_used=32/55 violations=0` |
| `loop` | `name=loop finished=1 cycles=2841 from_fetch=2810 retired=407 issue_groups=407 order=ok gpr_mismatch=0 pred_mismatch=0 mem_mismatch=0 check_failures=0 class_violations=0 overflows=0 credit_leaks=0 channels_used=23/55 violations=0` |
| `merge` | `name=merge finished=1 cycles=72 from_fetch=41 retired=9 issue_groups=9 order=ok gpr_mismatch=0 pred_mismatch=0 mem_mismatch=0 check_failures=0 class_violations=0 overflows=0 credit_leaks=0 channels_used=21/55 violations=0` |
| `missrun` | `name=missrun finished=1 cycles=122 from_fetch=91 retired=28 issue_groups=28 order=ok gpr_mismatch=0 pred_mismatch=0 mem_mismatch=0 check_failures=0 class_violations=0 overflows=0 credit_leaks=0 channels_used=31/55 violations=0` |
| `mload` | `name=mload finished=1 cycles=112 from_fetch=81 retired=11 issue_groups=11 order=ok gpr_mismatch=0 pred_mismatch=0 mem_mismatch=0 check_failures=0 class_violations=0 overflows=0 credit_leaks=0 channels_used=31/55 violations=0` |
| `mlp` | `name=mlp finished=1 cycles=127 from_fetch=96 retired=21 issue_groups=21 order=ok gpr_mismatch=0 pred_mismatch=0 mem_mismatch=0 check_failures=0 class_violations=0 overflows=0 credit_leaks=0 channels_used=31/55 violations=0` |
| `mwmiss` | `name=mwmiss finished=1 cycles=131 from_fetch=100 retired=88 issue_groups=88 order=ok gpr_mismatch=0 pred_mismatch=0 mem_mismatch=0 check_failures=0 class_violations=0 overflows=0 credit_leaks=0 channels_used=31/55 violations=0` |
| `narrowadd` | `name=narrowadd finished=1 cycles=230 from_fetch=199 retired=21 issue_groups=21 order=ok gpr_mismatch=0 pred_mismatch=0 mem_mismatch=0 check_failures=0 class_violations=0 overflows=0 credit_leaks=0 channels_used=32/55 violations=0` |
| `pguard` | `name=pguard finished=1 cycles=86 from_fetch=55 retired=12 issue_groups=12 order=ok gpr_mismatch=0 pred_mismatch=0 mem_mismatch=0 check_failures=0 class_violations=0 overflows=0 credit_leaks=0 channels_used=29/55 violations=0` |
| `plog` | `name=plog finished=1 cycles=71 from_fetch=40 retired=10 issue_groups=10 order=ok gpr_mismatch=0 pred_mismatch=0 mem_mismatch=0 check_failures=0 class_violations=0 overflows=0 credit_leaks=0 channels_used=21/55 violations=0` |
| `predlane` | `name=predlane finished=1 cycles=927 from_fetch=896 retired=10 issue_groups=10 order=ok gpr_mismatch=0 pred_mismatch=0 mem_mismatch=0 check_failures=0 class_violations=0 overflows=0 credit_leaks=0 channels_used=31/55 violations=0` |
| `predmerge` | `name=predmerge finished=1 cycles=939 from_fetch=908 retired=9 issue_groups=9 order=ok gpr_mismatch=0 pred_mismatch=0 mem_mismatch=0 check_failures=0 class_violations=0 overflows=0 credit_leaks=0 channels_used=33/55 violations=0` |
| `predspill` | `name=predspill finished=1 cycles=966 from_fetch=935 retired=12 issue_groups=12 order=ok gpr_mismatch=0 pred_mismatch=0 mem_mismatch=0 check_failures=0 class_violations=0 overflows=0 credit_leaks=0 channels_used=31/55 violations=0` |
| `predswap` | `name=predswap finished=1 cycles=1178 from_fetch=1147 retired=46 issue_groups=46 order=ok gpr_mismatch=0 pred_mismatch=0 mem_mismatch=0 check_failures=0 class_violations=0 overflows=0 credit_leaks=0 channels_used=33/55 violations=0` |
| `provswap` | `name=provswap finished=1 cycles=2325 from_fetch=2294 retired=978 issue_groups=978 order=ok gpr_mismatch=0 pred_mismatch=0 mem_mismatch=0 check_failures=0 class_violations=0 overflows=0 credit_leaks=0 channels_used=33/55 violations=0` |
| `roconst` | `name=roconst finished=1 cycles=64 from_fetch=33 retired=4 issue_groups=5 order=ok gpr_mismatch=0 pred_mismatch=0 mem_mismatch=0 check_failures=0 class_violations=0 overflows=0 credit_leaks=0 channels_used=26/55 violations=0` |
| `rogated` | `name=rogated finished=1 cycles=84 from_fetch=53 retired=7 issue_groups=8 order=ok gpr_mismatch=0 pred_mismatch=0 mem_mismatch=0 check_failures=0 class_violations=0 overflows=0 credit_leaks=0 channels_used=26/55 violations=0` |
| `rokill` | `name=rokill finished=1 cycles=93 from_fetch=62 retired=41 issue_groups=4536 order=ok gpr_mismatch=0 pred_mismatch=0 mem_mismatch=0 check_failures=0 class_violations=0 overflows=0 credit_leaks=0 channels_used=27/55 violations=0` |
| `rolaunch` | `name=rolaunch finished=1 cycles=62 from_fetch=31 retired=4 issue_groups=5 order=ok gpr_mismatch=0 pred_mismatch=0 mem_mismatch=0 check_failures=0 class_violations=0 overflows=0 credit_leaks=0 channels_used=24/55 violations=0` |
| `rolimit` | `name=rolimit finished=1 cycles=64 from_fetch=33 retired=4 issue_groups=5 order=ok gpr_mismatch=0 pred_mismatch=0 mem_mismatch=0 check_failures=0 class_violations=0 overflows=0 credit_leaks=0 channels_used=26/55 violations=0` |
| `roload` | `name=roload finished=1 cycles=106 from_fetch=75 retired=8 issue_groups=8 order=ok gpr_mismatch=0 pred_mismatch=0 mem_mismatch=0 check_failures=0 class_violations=0 overflows=0 credit_leaks=0 channels_used=31/55 violations=0` |
| `rope` | `name=rope finished=1 cycles=7751 from_fetch=7720 retired=354 issue_groups=354 order=ok gpr_mismatch=0 pred_mismatch=0 mem_mismatch=0 check_failures=0 class_violations=0 overflows=0 credit_leaks=0 channels_used=34/55 violations=0` |
| `ropediv` | `name=ropediv finished=1 cycles=1118 from_fetch=1087 retired=203 issue_groups=203 order=ok gpr_mismatch=0 pred_mismatch=0 mem_mismatch=0 check_failures=0 class_violations=0 overflows=0 credit_leaks=0 channels_used=34/55 violations=0` |
| `sel` | `name=sel finished=1 cycles=76 from_fetch=45 retired=8 issue_groups=8 order=ok gpr_mismatch=0 pred_mismatch=0 mem_mismatch=0 check_failures=0 class_violations=0 overflows=0 credit_leaks=0 channels_used=29/55 violations=0` |
| `sized` | `name=sized finished=1 cycles=2641 from_fetch=2610 retired=25 issue_groups=25 order=ok gpr_mismatch=0 pred_mismatch=0 mem_mismatch=0 check_failures=0 class_violations=0 overflows=0 credit_leaks=0 channels_used=32/55 violations=0` |
| `slotform` | `name=slotform finished=1 cycles=4365 from_fetch=4334 retired=12 issue_groups=12 order=ok gpr_mismatch=0 pred_mismatch=0 mem_mismatch=0 check_failures=0 class_violations=0 overflows=0 credit_leaks=0 channels_used=32/55 violations=0` |
| `spinwait` | `name=spinwait finished=1 cycles=2180 from_fetch=2149 retired=211 issue_groups=211 order=ok gpr_mismatch=0 pred_mismatch=0 mem_mismatch=0 check_failures=0 class_violations=0 overflows=0 credit_leaks=0 channels_used=34/55 violations=0` |
| `spmbank` | `name=spmbank finished=1 cycles=185 from_fetch=154 retired=13 issue_groups=13 order=ok gpr_mismatch=0 pred_mismatch=0 mem_mismatch=0 check_failures=0 class_violations=0 overflows=0 credit_leaks=0 channels_used=28/55 violations=0` |
| `srd` | `name=srd finished=1 cycles=69 from_fetch=38 retired=6 issue_groups=6 order=ok gpr_mismatch=0 pred_mismatch=0 mem_mismatch=0 check_failures=0 class_violations=0 overflows=0 credit_leaks=0 channels_used=29/55 violations=0` |
| `stall` | `name=stall finished=1 cycles=557 from_fetch=526 retired=116 issue_groups=116 order=ok gpr_mismatch=0 pred_mismatch=0 mem_mismatch=0 check_failures=0 class_violations=0 overflows=0 credit_leaks=0 channels_used=31/55 violations=0` |
| `swap` | `name=swap finished=1 cycles=557 from_fetch=526 retired=174 issue_groups=174 order=ok gpr_mismatch=0 pred_mismatch=0 mem_mismatch=0 check_failures=0 class_violations=0 overflows=0 credit_leaks=0 channels_used=31/55 violations=0` |
| `transp4` | `name=transp4 finished=1 cycles=1137 from_fetch=1106 retired=976 issue_groups=976 order=ok gpr_mismatch=0 pred_mismatch=0 mem_mismatch=0 check_failures=0 class_violations=0 overflows=0 credit_leaks=0 channels_used=37/55 violations=0` |
| `unal` | `name=unal finished=1 cycles=136 from_fetch=105 retired=9 issue_groups=9 order=ok gpr_mismatch=0 pred_mismatch=0 mem_mismatch=0 check_failures=0 class_violations=0 overflows=0 credit_leaks=0 channels_used=31/55 violations=0` |
| `vadd` | `name=vadd finished=1 cycles=157 from_fetch=126 retired=17 issue_groups=17 order=ok gpr_mismatch=0 pred_mismatch=0 mem_mismatch=0 check_failures=0 class_violations=0 overflows=0 credit_leaks=0 channels_used=33/55 violations=0` |
| `vadd4` | `name=vadd4 finished=1 cycles=208 from_fetch=177 retired=68 issue_groups=68 order=ok gpr_mismatch=0 pred_mismatch=0 mem_mismatch=0 check_failures=0 class_violations=0 overflows=0 credit_leaks=0 channels_used=33/55 violations=0` |
| `vaddslow` | `name=vaddslow finished=1 cycles=546 from_fetch=515 retired=17 issue_groups=17 order=ok gpr_mismatch=0 pred_mismatch=0 mem_mismatch=0 check_failures=0 class_violations=0 overflows=0 credit_leaks=0 channels_used=33/55 violations=0` |

## Manifest of release/

```
f580ee7217f8fc013fa42dcb3c07512a85b6d5a9c01deabd9f1b526952d79d10  release/kernels/addrhigh.by_instr.json.gz
c60ff0458dc4327eb6fef852dfcd7fd83670ceb86ad7efee4d1c268a535180b7  release/kernels/addrhigh.by_unit.json.gz
6a83ee549bc2b620731911123a4ffc5e1ff680d3882bbd4127604ae03aec34c0  release/kernels/addrhigh.ccvtrace
c12b4be2d5129bd11813c18a5df6a92425c4d8b6206cac93c3e97c2aa417e46d  release/kernels/addrhigh.log
569f2e22883fad5f0956c57ec734e6afbdd4b8a854e50277425172d6c0cbd766  release/kernels/addrhigh.oracle.jsonl
d456e9ac708048d489cc38cc0596924907ac82e3568f64df30f2b2934a06a17a  release/kernels/addrhigh.sv-hosted.log
28dc69325fbf2e934fd86658223b48a8cb92053952c06eb87d3d34b4706decbc  release/kernels/addrlimit.by_instr.json
f6461e7e8081e79750a0a358ce2ee174a0174a909ffc7998aa7542e4f963d0bf  release/kernels/addrlimit.by_unit.json
d0275ae1473e1f86fd56e1553d6e6cb67f83eb67dc23e27159a63e3cf3f3f0fa  release/kernels/addrlimit.ccvtrace
b92e5074f6a578ee39326458201ba1791a48000c73a281ca343da4d5420a5bf5  release/kernels/addrlimit.log
bc660b0b40359a2c5a2478cb0eb4950b73fd22db50ea76b80052bc195a1920f4  release/kernels/addrlimit.oracle.jsonl
f49be2c5585627cc230883d3c141d55c3df92ae0bf7a4819b30ebc9cc353370b  release/kernels/addrlimit.sv-hosted.log
002eb9f49b1db791a8001012fccd9f16bd62772dd9f663bd1a841e07061ce16c  release/kernels/addrneg.by_instr.json
ada96822553635b5282a2fb7c64ddaf92933ad7c066099ad0dd4205e98f8b381  release/kernels/addrneg.by_unit.json
5cb0374d21bf1240216d039ca378d384e50df24c7c9a4dd00b14448e75084b34  release/kernels/addrneg.ccvtrace
528ebf549ed59eaf727699009afc33c68daa341e88d25f604d098d8c7562e07f  release/kernels/addrneg.log
16f5b0707ae44492a1efd67bb9dd38a7e79a7bbd354fa9207b9e7d150ff2f107  release/kernels/addrneg.oracle.jsonl
0f4179c372957428237bf9f629bf2adf1d092e0935a63aeb5e4fbc840ea6afe0  release/kernels/addrneg.sv-hosted.log
002bff07241983ec3119c70f128958d7e5b3db7ad9c398fcf1ffe5b36b02a394  release/kernels/borrow.by_instr.json.gz
0d5ff6971434492763a7168c4e694eec1ff340e17dce20de087b95d98d14951e  release/kernels/borrow.by_unit.json.gz
f1f862776f5dfc78e83e1d331944227363a821f4e49be68c0527294b55f42091  release/kernels/borrow.ccvtrace
86ea261f07bc9c29bbd875107073031458cc424f3be02d179a00fbde37f847e6  release/kernels/borrow.log
4c565e1ce0b3baee36e158694b32c8defb5cd662b2f9af75cb5d8c26cb1168ed  release/kernels/borrow.oracle.jsonl
ef84c556317c8ff78b602e85151fe87c4d60283db905fc1e3e279421f894f174  release/kernels/borrow.sv-hosted.log
c288f22a1f9022f4c6944d4e9fc5d82a76ecbaf12616e2323dd5c98ba606bb9d  release/kernels/brs.by_instr.json.gz
d8aac879b1aa01c62cb5c387e1b64a4b52946c463ca3cd063fd5ffd1a6cd8ca2  release/kernels/brs.by_unit.json.gz
5dc140ea49c98a2c34b741f82308100619a4698b3734262ba4d3417c10d722cc  release/kernels/brs.ccvtrace
0fe0bfe4fb0430b2cdae802f0d093c70ccbd2b8e43080f3ffd3e1bb17bb413a1  release/kernels/brs.log
e3c1cb3379580cf1aae44e8ddc8e846ef6fd661a573cfe0a8d4444b18a14dc56  release/kernels/brs.oracle.jsonl
64a3537676557b419ca3f6ae71fd2955a02390b6fb36329394e0664a9f39bfa0  release/kernels/brs.sv-hosted.log
13ccac91e7b522fa44fdeab40e96c37148e3bb96d390f58bdf8f483db01cac88  release/kernels/byp.by_instr.json.gz
337767fd3fc9761f1cf32475ea84726f297e1bd1d1672e1f92812e3528b1cf37  release/kernels/byp.by_unit.json.gz
e3480a496b7a1d2881af43ee09b2bb764b871eb942bd66bcbbaa3b537f536d6b  release/kernels/byp.ccvtrace
225cf1e7663b6d12f51936dba831960ac3c9ad10699db5c97fc2a1be3c11f43d  release/kernels/byp.log
5a03dfa4f3603fef49f1e3639e74e34152ca3ca5ef8e41eb959f8323040fa2d5  release/kernels/byp.oracle.jsonl
8a369624a07d3947b9d52b3c2599797a6645be920272bc5e8c1d08c0e9686318  release/kernels/byp.sv-hosted.log
4fd53f940624ef9ca5d498deee199ceae046b0db465a6cd7c22388d87c80de45  release/kernels/callret.by_instr.json.gz
5784c1fc280080bdc2aa7c6860d11dc2114ae48a57ba03722083c4998e489a8c  release/kernels/callret.by_unit.json.gz
5c916dd80f288b2e715c882c446ac317f3341d84638afb42c6d58461c0ae83da  release/kernels/callret.ccvtrace
de0f6d270390fb4c2e652bf91a289512b6f1bdd83eba63bb1b7a2509d577bf60  release/kernels/callret.log
9b1d1b50b527f732362f837250aa2f26dabf3e76e16a4794856ebd8f105635b8  release/kernels/callret.oracle.jsonl
e4a27ca3830701e0016df404a92ef015fc2d2e71a1ac699d1b393fcb7be77d7f  release/kernels/callret.sv-hosted.log
48099e3eb0a238ad400e7587fcbf5f4c5882c9bdd7d8dcb31bf5de55e6fb46a9  release/kernels/chains.by_instr.json.gz
3bf1346020a24fcd91d524ccbd6cc315a731198147378614890e73bde7531a7c  release/kernels/chains.by_unit.json.gz
94291c1a3431b8b84b1171b04f2fe0f6eb3300cd344c7e7e60928898254e9d63  release/kernels/chains.ccvtrace
ae1ddd5b5937f0ee9cbe35237ee22a50ed28e32865668dfae0124d454b74696b  release/kernels/chains.log
26a4cc5c5524c7219d8706c2582c80357dea60be9d6ffdec99dac7d0365e2264  release/kernels/chains.oracle.jsonl
0c743111e2110cf02fa2861e20e8f80afe57b228e0344ce21eb3b022d689b93d  release/kernels/chains.sv-hosted.log
e86c8b42b92a885be569209aaa94b9fcf9af402a585e41069caaf85fea7decee  release/kernels/div.by_instr.json.gz
4fdf2f5e152e77bd8430c242b7b6298dfe29630425d9d74b0f53c495bfd710b3  release/kernels/div.by_unit.json.gz
d4e3cf776f53afaf1f121e89f0ac7e7acf46db83e299dffc3a1f6992c2d0763e  release/kernels/div.ccvtrace
3f19524e7aa346347d10db07c74706b4331ce58023eb94eb63218cbb0f61d0b1  release/kernels/div.log
71a567b85cf85622631490187563de9a5661099c78a590adff4ed0a0c3d24c16  release/kernels/div.oracle.jsonl
e158ef3a06e128e6a4f6f22786424c3710d7eaf8db8466589dc30b691581a2e6  release/kernels/div.sv-hosted.log
ccde62c66835daa098336f629a873e5548d67749a4be45f3bcc70353c893e3f7  release/kernels/divchw.by_instr.json.gz
e6d63a5a6b998c759195e88208b87c47a314ebf3f8ff565e513329b23a18ffac  release/kernels/divchw.by_unit.json.gz
36165621c49d40f4c9d967b694e162d58ca01a786ed79d7e9be7360be19a0bb9  release/kernels/divchw.ccvtrace
fb75e9aac96d7b72d56f88fad08738eeae02b10ce4ce734f9d078a496e6994be  release/kernels/divchw.log
58a541797f7a2df0a1c7528ae6a3edec212db90c7d3eb20656806f38b5c10b3d  release/kernels/divchw.oracle.jsonl
a8eac1f9747c4ad1c4cfc22389b1fc77e4c2e676c7745a2fee21afe0e01ffb74  release/kernels/divchw.sv-hosted.log
1427fdd32acd6b6f22ca8bbde4d9cb5183214d4a6bcdbe3d3bc6b4ab4a68e677  release/kernels/divtail.by_instr.json.gz
30664ed458b7f00270662e3da7f785c0b6b0358bf9710787e6aaf7261e913ab8  release/kernels/divtail.by_unit.json.gz
038d13deb3b5c08bc95b16b8877467a9451dcffc9bc53d333486bf978cfb01d1  release/kernels/divtail.ccvtrace
928c41bdc4e7ec9fb17976fcaa49f082a314307fef345d55c32fa431d8c2fef6  release/kernels/divtail.log
75f11a75c9b3b336e446140af4579f05b46c363a76b7aab3ec88154a07ba097d  release/kernels/divtail.oracle.jsonl
bed07585f1f1fcbf5d691df22339075d2251834fc60938f4edcf1e9b4962140a  release/kernels/divtail.sv-hosted.log
897ebe4584f1f8d285f3b3a08ec0b1d2280843afa53ac971a5122e7e37109c75  release/kernels/divtail2.by_instr.json.gz
0f6731a347320be8467cd39391fa45cacdc56967a2edc500503110808d10d3bc  release/kernels/divtail2.by_unit.json.gz
f5760eb6378cc178b8c80585c076b817040a0af3545f8eba2b17362e0aba7441  release/kernels/divtail2.ccvtrace
a0e19d19a924d3431f453087f2038044e30c4ca8acf4b97e0102599151505333  release/kernels/divtail2.log
b2db6b05eb6cf4a0a7677e31d0c6c2952d5cab49d353f0bb1883fe0b2a20ed14  release/kernels/divtail2.oracle.jsonl
73735079652ec09472cbec6e15bff5b32f04e5e91b316cf2c1871b09b5f5809e  release/kernels/divtail2.sv-hosted.log
1bdb14678e268d41aa9f9188b720f0d000f020b26699909dba100055dc8e3778  release/kernels/fence.by_instr.json
963c6e416a38b9d9c4f59e64792d2d9bc84aa1a66eb04720fac291d068ebb0a5  release/kernels/fence.by_unit.json.gz
f3de39e962c433133d04452e595dddfb100cd50cddbf4c626711c9236cc6afa0  release/kernels/fence.ccvtrace
07fe6be8c5c620669d1ca943b40884507e12ccf2054c6e8b5489a8aaabd04552  release/kernels/fence.log
d1d40317f6cf5bfb430cda1f9c0ef676609e59cabe2a11623c42ffbeca93142b  release/kernels/fence.oracle.jsonl
118528c0e83fed564e33a15c3e039c021fab43c8ff844d5dbf91c7acafffb67b  release/kernels/fence.sv-hosted.log
509733dbbf0ca00393a4f1fe6ecea54892499523bd3479957d8660972369eb9c  release/kernels/gather.by_instr.json.gz
bd3e673165840474d5b8f4a181a29e3e600a77e5dfab908f8841e7d56e02ad2c  release/kernels/gather.by_unit.json.gz
9264d807aab095cd4ce3141f4fbc6a661ef5bd72ed384a647e735f1f1d294258  release/kernels/gather.ccvtrace
ec409c6760af7277f3f2cd4391061e54b0a30863e59520d8dad801c3685f31c5  release/kernels/gather.log
0413e781d8d6ff578c64eb1f800b7931e66f676d5cdabb97b94a4033e6037662  release/kernels/gather.oracle.jsonl
892886f99d5aef8a5fcf0ad15365d6b548693d9d57188fccca40b5879331f171  release/kernels/gather.sv-hosted.log
33e49e4cd0546afc87fe435d520bb328e6119e13850ac8a3a77c93d7cd661585  release/kernels/hit.by_instr.json.gz
0b164fb76d83cc4e2aa8145f001ee23e20231a1f0386cb75ce76bc8a638d06ba  release/kernels/hit.by_unit.json.gz
a21884ff3a5bc45b0719725c1b08b9dafcb896df33e9129726b0a6f8f2f62c5a  release/kernels/hit.ccvtrace
675664064d88067c20cdffe72f4accca7d89ad4042ac8405952ce7d48d43c1ae  release/kernels/hit.log
7ba9603e0088d9164de6528f16ef6a7fa9ce5821c8c12b52cbb3734e39b9fd52  release/kernels/hit.oracle.jsonl
d43fa755129550bcb1db601ea9c101d47561c9d81b78059d92b391767ce3b74b  release/kernels/hit.sv-hosted.log
f6a1487d44546c120c2119bd0b4c2476c12d1a867c229701687b8f13557e38df  release/kernels/lanectx.by_instr.json.gz
82982f3319ce38e5390b09e34109a49472664848769e090da35c50a2ee8043ec  release/kernels/lanectx.by_unit.json.gz
b8113fd30054885d1c08728f37eeadc557ec3ed260e5f572d8275925e2ec625b  release/kernels/lanectx.ccvtrace
d61de36f67a23d7f6bf6ecc47e74582f85f7ed5848d23b747188e31f4acf3e5b  release/kernels/lanectx.log
888551babf540db8e3025b82e65ca655013f93eba3c8a65689d069d52a7e6039  release/kernels/lanectx.oracle.jsonl
d72b3cd739ddb4bd166cde221910cf7f859c1d4097b742aefae6e1dcce1b2c97  release/kernels/lanectx.sv-hosted.log
748ce019c5f86d1c3af88347f446473c8ec725e6dc50c230cf30dc38bf80732a  release/kernels/lanectx2.by_instr.json.gz
bd06dce603d8a15c2adc3abbe329713328e0887b8dbbd8ca8135fed4c18f9e4e  release/kernels/lanectx2.by_unit.json.gz
2fc4e806b0251780aab41e915640af360d2330e7985ab9f857a899d30401a43a  release/kernels/lanectx2.ccvtrace
d0229a8ba7e051b55f149b59f9fbd8b028d4124dbf7d0d7330079d2b2f784bf5  release/kernels/lanectx2.log
45c13056dff5c73ed0c9ece56cc36f929bf335322193c7d5eb38710b1d1dfb02  release/kernels/lanectx2.oracle.jsonl
14fd129bc410caad633e5a06df6fa8512808c16988f6daad4ff19fa1e6c1abc4  release/kernels/lanectx2.sv-hosted.log
e45e1f02b985ad5a8bec3633206743d40cdc4c328a9be15cbadfdc7de8ad0970  release/kernels/late.by_instr.json.gz
9649dbf7bd0a33945af81d58b3d0c912156bb42c39fd704109ffa3cb7107e7d9  release/kernels/late.by_unit.json.gz
f4fc47fe3ad032977a338a3981b96518a799d313c6ccc4880908bf3646f55aa2  release/kernels/late.ccvtrace
dcbf1e40beaf1927586e65026574899c50a833f190188649659b2982f776a8f3  release/kernels/late.log
86084f6bd747a2cf32acbc0ebd96ebd3e4ef2d8d9e21be49e3ae49290d7927f3  release/kernels/late.oracle.jsonl
ec79420cbcc8a81f0cfbfee9cb2460cfe2a0bc4ad2a63af759b02d13c528a3db  release/kernels/late.sv-hosted.log
f7c3655ebd190b5c50328b0bc206a5a74c956d1284c048e1b0aaf52e085e92a9  release/kernels/ldpar.by_instr.json.gz
3e04087f56435dd3609b15d7efc0ae2563473847d9506f5faf2e0a1b7ef4f290  release/kernels/ldpar.by_unit.json.gz
859d131606c248d7feeee7753a2df6702437f1bd1b61f3073ba90cb84b7d3eb5  release/kernels/ldpar.ccvtrace
f085f2b1b21842ab2fa128c5503ba5c8ec1f9d76d926e376af4798bb255d60eb  release/kernels/ldpar.log
8ac08538e9c807637babd61b31e340f7461878ada31f0c0b83cd66331cfaf486  release/kernels/ldpar.oracle.jsonl
83fd426e68a806fac36bac6a35e2fcafe5751dbe92f529c237079262ef0a997c  release/kernels/ldpar.sv-hosted.log
ed69c8ea2fa3bc335710917e8b89dbac1fac35e000e9cfaf95def92c61d94d25  release/kernels/lnorm1.by_instr.json.gz
d3d7d124cf87f40b9d240dc7dd195f16172ed1472f8135db4fde02396a6e3fcd  release/kernels/lnorm1.by_unit.json.gz
84b6565d96bb9bf341ec04a2d92c081195ced87a88377e3da93d9e288b49c9aa  release/kernels/lnorm1.ccvtrace
e24e2e9d79a4afddaa027efb8f52c00404e7137bbd4ad045ebc769c74b0b6136  release/kernels/lnorm1.log
a8d85811af988a1b9fc00db1517300af3d93ec8e589e403d3b9113fa9e0ffc86  release/kernels/lnorm1.oracle.jsonl
a1a851fb701170d5e4951043270e07f96c3f96341fb506f39f3d733c5fc8b562  release/kernels/lnorm1.sv-hosted.log
d94f4fe32f9b41896e7cb3e910d2bcd28890acfb81fd7a05eb9b6147da0b820e  release/kernels/localsp.by_instr.json.gz
5d7a33f4ee515402ed6e9da7ffcd620a1f14f909177b295b901ad0906d7543b4  release/kernels/localsp.by_unit.json.gz
994efce3ffb67f5fc232b7542d2ffb40a1b1ccdd5ca42dcc35a95ae5836eed55  release/kernels/localsp.ccvtrace
1f1644be5da2e1f2d0ce0321a5f047f4f6a2a1ae7fb62ea6a608b3837eed43af  release/kernels/localsp.log
55e3c9f36e7f7d38c0ddd38903aff4bb4509ae862015c592e6b937ea258042ca  release/kernels/localsp.oracle.jsonl
412de687e2cb17fb6f919323cf47a60243b55d2174342557a55665020b05cf3f  release/kernels/localsp.sv-hosted.log
ff2108f4921e94bc1a0919d358084e45768f3f06bdc8bb820cb9960758a30259  release/kernels/loop.by_instr.json.gz
0335454e140111870175ef5b244618c21f6ad666f034c728a345c00ae90eb4d4  release/kernels/loop.by_unit.json.gz
d97f745235554b110bb5181b2194e2a3227871552817968e4dfba9de82d8ce40  release/kernels/loop.ccvtrace
23a1e4d0ea3abad280ea43c7045d8c2b4bb5f255a59e38561e280e7e260641bc  release/kernels/loop.log
03ce5920c06c93e93516d8e53c3f7169f14e3593de204eacceffc0b8a3e32016  release/kernels/loop.oracle.jsonl
c2ab41387ef3f99b3d9b26ed287770d11abf1029ce85ff10c96df10c849c1fff  release/kernels/loop.sv-hosted.log
02e41d9754f3230283afd0e8598baf24e454e678793436c29a391b00d6d27c41  release/kernels/merge.by_instr.json.gz
e0fc0ed1dd67ba8dc7d9ef53d195aba28ba720c0cfb9bd122d5638fc9e43e95f  release/kernels/merge.by_unit.json.gz
fb3738c6d842e8baf329dbebf4968b4945e0a3fc632251d675b1b2e098ab48fb  release/kernels/merge.ccvtrace
cdf5c066c6904bd3aaf1dd1e0b86bfec3f59c6e0cd31df488f196b341ed0122b  release/kernels/merge.log
f96d28815f8756b1f5a45ded53e6170883d2dfa10f9eef0d14b8050b1318164a  release/kernels/merge.oracle.jsonl
3cc5be682a3f89cb8f1a9eb8ccd31b4a1747e570dca245618b612b71ea0d48cf  release/kernels/merge.sv-hosted.log
7d1f000c6f3fe55f85fde4f3b03a79a8360c27f017833a037cf360c5375c66cf  release/kernels/missrun.by_instr.json.gz
e7b237ddc5000e47bb2ae044cea6099435c90e5c2a40cdf3ae82f1427575a5b7  release/kernels/missrun.by_unit.json.gz
95dcccf10f536cd7452f5d2e81951df113faa65567f9f0d4d0c5dda4fd3bb89b  release/kernels/missrun.ccvtrace
5fb6b4640dfd77185544aaef5ddaad59d29ecc05cf4b5891c4e0d0904edbd887  release/kernels/missrun.log
531bdaf281e5590774bd2775427f25e4cc0419cf8e3d5b6999843ffe9ef87258  release/kernels/missrun.oracle.jsonl
91d64388c4e1beab6405164d90ceaa1fc123ed874ab6ec1dfd8e450d0068604e  release/kernels/missrun.sv-hosted.log
b975cd3207ca618f52fdc7b1c9abe8e8b20c394eaa2c10115e28ac74ca5cbc92  release/kernels/mload.by_instr.json.gz
77c974ccfb794281cd311a02cb62a305b4d077c894bd7b896010afe957e1a3ba  release/kernels/mload.by_unit.json.gz
6c51ae125f57419af5b4a0b83e312c614f1a11addd8fc8b6fad836734c264ead  release/kernels/mload.ccvtrace
fd7507cbc396aae4e1d93ee616b04429233d882f0e43afab4e11a1f2533411ef  release/kernels/mload.log
8000e477b9a95dfb9f0af964e8346acb9d36f1358fd06ffc4ff7cf599d2b8868  release/kernels/mload.oracle.jsonl
149a5dacf76e4c9f5890da683c4ac8b96c29d85b23938f309a281b190fd2c4b4  release/kernels/mload.sv-hosted.log
ad99637caef84d46c3bbfd533beded726193aa5478cc1b72a7fceca93022f8ea  release/kernels/mlp.by_instr.json.gz
6c785ef22b8bd382d5550478efe7bb70ea8bf8bc6f908c75949b5ea19b789c91  release/kernels/mlp.by_unit.json.gz
0b70f24e8ccd473fc49b62f1ef3a71388265aafe5823ca8528243e53bfc4b8cd  release/kernels/mlp.ccvtrace
f006e4046b851e506d21ca735f7b53ad8cef896db9a04c3fa500f28788d1183a  release/kernels/mlp.log
138d282f88d56c8ad648a91af0a983254b55d9fa22942c00d47b327f516a6e44  release/kernels/mlp.oracle.jsonl
75bf85bf95bae56502994baad88f98ce7f8b7ffbc46e1f8d8600397e44f56577  release/kernels/mlp.sv-hosted.log
64685230a895b291a95b9430e33f3a8fa6540d37ae7750b2ab323911a8e12911  release/kernels/mwmiss.by_instr.json.gz
d670dcb817d3f1ec7ec3634d9cc6bfd4c24054a04188619b7774e1a3ae387c94  release/kernels/mwmiss.by_unit.json.gz
bf58bf5dd2a060867fee471eef821369e5780d47733556f608fac4a4eb24cce6  release/kernels/mwmiss.ccvtrace
6ceb1aa542a6b2155c23999b7a57838cc3b2c5f9ae235110cf203d285f99a748  release/kernels/mwmiss.log
8abe8e8997456a2a6711ee72da54d854b24e20abbdab28e4b7271c0d28418de8  release/kernels/mwmiss.oracle.jsonl
3bc5121b9d611c9e89c6d6a65e8056582a22774dd91148ff816699c911b564b4  release/kernels/mwmiss.sv-hosted.log
5d10333fa7b165adbfe8d6a692b364c753de1dbe882ac61f67388c1420d7d1b7  release/kernels/narrowadd.by_instr.json.gz
ed6a62ef246989987f34c8f0e0b84dcd3865049ed59985de34b1d2177a723900  release/kernels/narrowadd.by_unit.json.gz
43094e3dfb54bbdccbd1486b3af3b739fbdc6e2c5672b5dcce010be51613c42a  release/kernels/narrowadd.ccvtrace
78f1bb621f4a30dae9bd0e8c0953fc7606bf0d32789e3c29c29a5536f35b41e1  release/kernels/narrowadd.log
40a2cf629853dd404bb06b4a07e35abde3d12efc13f26ffe28f923daf2994574  release/kernels/narrowadd.oracle.jsonl
04047ce243cbe0e91d55a210f4ac7d95d1a7820d79ca812b7ea45bc6a8725d55  release/kernels/narrowadd.sv-hosted.log
8782695c4f2c77b11e78a332823e59bb6e2fe108fc5287e06ab3ff31e80815f4  release/kernels/pguard.by_instr.json.gz
a47f97a4b6d0ca86f0097b98ba84b0a37704d7986a3f450823ba74adec9d6f7d  release/kernels/pguard.by_unit.json.gz
b84232a13c63382123e18ec951dd642cb132eefd21b44fff8f49c69c7339a3fd  release/kernels/pguard.ccvtrace
7cd9b0ce896540cc1f269e57005b01708880f447fc2f7a59baff8c257b189ca8  release/kernels/pguard.log
690e56f1cb8d97cbf67124b7dff3ad0a90cb8981814cd1709cf0cd0e035b3bd9  release/kernels/pguard.oracle.jsonl
08aec502c4ee9af5f55af01d38142010e660c21e1e819ff195a287b9fdc57ab7  release/kernels/pguard.sv-hosted.log
6a3316c6f5ffa4a529e176c8f33169d84a65e142023ae2d8b0c4a61b19e24d71  release/kernels/plog.by_instr.json.gz
4a512a84e74f3c7956a04a01edd015d2a2c30539cefed998eb65611bca0e4259  release/kernels/plog.by_unit.json.gz
e32ed8b48729d559c9d9c92968577d8f87099c9bea1562de23e434a7e966bd69  release/kernels/plog.ccvtrace
0bc0e407ba83624434e0271242283312e78976eeec5effd4adb93715334373e1  release/kernels/plog.log
c230f13f2e1082b306a9c5ab7809ff36cf5c1b2e47dca6b7a71f741524d403f5  release/kernels/plog.oracle.jsonl
bc263e010a64770a972e1b79a4d6bf6858ef2adb863bc28eae8984323d666bc8  release/kernels/plog.sv-hosted.log
3979f097adf54404d486f6babc88e21883596b377d9f2ac649a76b14b07aa5f3  release/kernels/predlane.by_instr.json.gz
b2542fb109fb1a3619cf6164da0284bdd00a1361a0248d13f93659434ed2df70  release/kernels/predlane.by_unit.json.gz
641cf1d52a695531f36a20efddbbf13f4b148c2b9f86e004659ef2817c6c9e20  release/kernels/predlane.ccvtrace
48e23a22553128cf727f38cdab3f925391b68829edec1860d00cf08cab894473  release/kernels/predlane.log
c45f4177b9e84fc8a6e36b13534a0c7636eb30a3f8531847100ce5e23bf404b1  release/kernels/predlane.oracle.jsonl
49b09b74a5fff223fc02e5acc7ec3bc2895b227652f978ea402fc7032fe32530  release/kernels/predlane.sv-hosted.log
f9a32f0d0e83a25346df2ceaa25f50d742ecd828c8f6d4c1bc94b60f2a54e7d0  release/kernels/predmerge.by_instr.json.gz
b26cb837cc027f5d3e2f7925e93d5c7e768eadaa91d2cfcb82db38d546678339  release/kernels/predmerge.by_unit.json.gz
a67d904d96ccfdbf5147b5795b7089099b2717cd21113c27b69c379c41e20e3b  release/kernels/predmerge.ccvtrace
4fb58fcb0c6f5a70de101bdd16ba56181174b39fd14ec75a351a125a226cc9e4  release/kernels/predmerge.log
6c737c49434bcd08e3e0814c8b1dbf15c586ae74f7929ba3148ddcee2c62c845  release/kernels/predmerge.oracle.jsonl
452feec272cee173d3845ca43f23368cb368a3f92bf72b80ac48a2d90b9430ee  release/kernels/predmerge.sv-hosted.log
ab96c1e5b8aa4b78bc1ae3a298776f45e1f43bb07dc357b56423a16240aa8dda  release/kernels/predspill.by_instr.json.gz
9b26826f1433e195bb29a72aa64508946e579a459ff680e5679078690ecc8d6f  release/kernels/predspill.by_unit.json.gz
01824e6ce8be6f51721d98514eaa04cc22e23ff2a0259f56af167900f52f96ab  release/kernels/predspill.ccvtrace
9ea5cbf026d07d6e2a27fd8e44c73207f33085368e3bc45290a58b7f4efce5d6  release/kernels/predspill.log
b7c84c6478117ffa0f06da0e6ad1e4628e2683426a7911080810e78e06a5242e  release/kernels/predspill.oracle.jsonl
2213c569fdbe510e2a1638ae6435c209732cba8888af9767019e7746ec9fd724  release/kernels/predspill.sv-hosted.log
1ff25e74eeefa7b7adda08eaabfd5757dd9f5b61f0e9e383a57f67761b298140  release/kernels/predswap.by_instr.json.gz
2227a119454f29a3a4604898ac1cbc646d199a1df15cf69c5d4774d308f4c550  release/kernels/predswap.by_unit.json.gz
b000a4a9d47b149ec19f0b41262ee400c37d8c757114b5e964f26941976a4b0f  release/kernels/predswap.ccvtrace
cb25e92c8bb95e3ee0492a3550857382e599e7f6e8becfc8e852c85f486130c4  release/kernels/predswap.log
a6d4f7ed517553816d889c7c9eeb6bcfd1f6c973fbf682ecb69f3c2de619f7bb  release/kernels/predswap.oracle.jsonl
6ac885816ecb95d4d82b3e157c9f2924017eb4ea8aa6b35bddd110a5118fc44c  release/kernels/predswap.sv-hosted.log
52bd7d3f53176a3303476c63cb970cf0e44eb539d6d50ca98d80d84a52543ef1  release/kernels/provswap.by_instr.json.gz
de433ba76ec15e42046dcaf63cd55a2897ac44c71adeed151c6855d3f9bf1713  release/kernels/provswap.by_unit.json.gz
2d8fa3a3fae9bcaed3c82f6aed6f17bfb22492c1448d16b2ee2d3f108b8fb0a1  release/kernels/provswap.ccvtrace
be20ce6abc3bec2fa47e1e303717f3aa3a41cc1a10d9b1a6e0e8f16a426302db  release/kernels/provswap.log
c9c32a793d54cc7401477f582487f7e8b345b2669a75337b8d6327120d98e5dc  release/kernels/provswap.oracle.jsonl
d65a6d082175ded02838c4b405a6f13d6198ce0be38295976170e6487b70a834  release/kernels/provswap.sv-hosted.log
bc78212fb3eb25a011a8123c4c1f4f52a37579dfba964059b435dacf71198f47  release/kernels/roconst.by_instr.json
79d82b16fc17f58fb96fe049401a9ae376289313248707f0a00f02a0bfee4cbe  release/kernels/roconst.by_unit.json
67cb3eae07ee5e7c2b5189ab3ae0b9f61a2288b3587134e3f81c30c1a2e1b664  release/kernels/roconst.ccvtrace
16c1f519f57131c584079ad7d0846c07d3b2c9e93b101976c817d1637b60c9dc  release/kernels/roconst.log
8087c0671de620162881aecd38cd6114b78e7be6bd71201e3ec02c9a2e2e750e  release/kernels/roconst.oracle.jsonl
0b6497d1e391e07f485bee271664f1dffe6801450bc15c0cc345eaf2643ddbb3  release/kernels/roconst.sv-hosted.log
97f33ebd4e213b24c8fd8e9a1a66978cbec05d458b20e52d6c64cb884a9eca98  release/kernels/rogated.by_instr.json
b8ff4223edf49071923fad1831ed78411f5721c8f1ab6b1542e2747318e27ad5  release/kernels/rogated.by_unit.json.gz
f66f987d8fc2f520bd60b6879774625aca083d99cc945d4f9f642fbd07bfb4a6  release/kernels/rogated.ccvtrace
4d38c293a5ff52300bb38857ceda8b927cfc5ef560a70064526071aa84f189f4  release/kernels/rogated.log
7cd02bd4cceec5a044d6b4d6a80df1e68ed0ae71b0b2a953143636d5b809ea6c  release/kernels/rogated.oracle.jsonl
9212248b3033827e789c9b60f98f7e5103eccdef07d8fcf248a396656b480665  release/kernels/rogated.sv-hosted.log
86972d9d1004a54034d1d8a47887163fa81d683445ef4d83f4b90cf569571ee7  release/kernels/rokill.by_instr.json.gz
60460046003c3d389f5b89875e58a2371956413f752c294428fa6e26d189f1d3  release/kernels/rokill.by_unit.json.gz
786bc1acff229f74556953efe75f61182febcc4d0bd523b01e3877be3bd197ce  release/kernels/rokill.ccvtrace
ef6f3b7e640b4212980efe9727baed2fb9b021dbbc4d278bf21a96df5ea86263  release/kernels/rokill.log
94efcef96af469a512d346ce61623980fe86383188eaebd55120f716db596f14  release/kernels/rokill.oracle.jsonl
fd3aa0bfb400ddd5f859394ecacae61967ade66e697a68e0c3f15f1aca505ec2  release/kernels/rokill.sv-hosted.log
f41e6e2e961cd580d1cb70c2a7f4b0d5a5009c7d936e611e401b661c48745392  release/kernels/rolaunch.by_instr.json
7deb59c3a34a6ad597d362605214b2f8c5608fe4b96916c8fab8e2368db4c3cb  release/kernels/rolaunch.by_unit.json
03c1532e55928161a52bd3a508207e2590d1e4a67091d7be62e55942c13bca02  release/kernels/rolaunch.ccvtrace
c3f1c59be348fb933e9a77e3525b1d78bbf4f378a5d73a9c52d0f9c69ed0e0a6  release/kernels/rolaunch.log
e7dad585c3e70615de04330fd03f4f282c29a005dc1732a35655fb261d51139e  release/kernels/rolaunch.oracle.jsonl
7436bea90d4ea6d2e2b23bb7feab4b2b858f6e2081b15b8e38c30da77154776a  release/kernels/rolaunch.sv-hosted.log
bc78212fb3eb25a011a8123c4c1f4f52a37579dfba964059b435dacf71198f47  release/kernels/rolimit.by_instr.json
7025b72667e0598aa0fd20e979b43d7742034750ff615788ee249cc2f71e2106  release/kernels/rolimit.by_unit.json
7fd9c08101c7d3d6da8773714425093d1d1306293c81245e32587716c2d3c044  release/kernels/rolimit.ccvtrace
152848f5b56555bc4202d44c78a529ccefdcd38ef3e55551ab8991e06a6fff2b  release/kernels/rolimit.log
1c5bc0cb8e8b2e69505fb5a551a16d5d10c56f232b88da7a27e336ad7d962de2  release/kernels/rolimit.oracle.jsonl
b3bb3b6ddd109064d47eb3286b5f183e4ad1e26f3db4945cc94d0ed07f0a67a9  release/kernels/rolimit.sv-hosted.log
44c4ab0e312b79dc2cebc265e03244c2d8ceff823d1ff49ed2a5d1ea10b52097  release/kernels/roload.by_instr.json.gz
5f41045429acc26f8d8d2f285cb1dd4a24abb50279a369c2844a946330420b83  release/kernels/roload.by_unit.json.gz
211940a7f07b77fa9bb7955c575e00dea06e88b50e1e452d1e6254218513c542  release/kernels/roload.ccvtrace
db4c5f5668737588efecebcf741099ce7d3870c886452af467e190f75aa00767  release/kernels/roload.log
f7c1309cc9764769fb5803f6fd0f2f5e1eb418f2d23fbe5e17cf5f9106869fdf  release/kernels/roload.oracle.jsonl
4dac1e015bb2a57eeb196ad86459c2db78def0bdb3fdb0162ada0dc0ecdbe0f2  release/kernels/roload.sv-hosted.log
eb525ba2ea5591d9b8106feb339d598944fd9011544ff7e317b8b1cfbe6bffbb  release/kernels/rope.by_instr.json.gz
cc3f1e64b07ada306869915aa0ef9e71012ce24ab0fb9b0d08b5bf0a54b8c060  release/kernels/rope.by_unit.json.gz
ff40280d90650dbd0771b074cc22c93bc9d95b053e0b2ae7bfca85af6924419d  release/kernels/rope.ccvtrace
0baf9ee9a5460966e74824d4b12f5a8d9ecc6fb0eabd7e1635bda11b35ef50dc  release/kernels/rope.log
d55f9efae392dc8877c102c01c0810e7654b666b6ede386328108164c6cf88f3  release/kernels/rope.oracle.jsonl
87c118c437978ae78bd334fa3e4d81a0e541cc673776a0b2a6d148268bbb1a37  release/kernels/rope.sv-hosted.log
131cf66125d00065db18fffc278a9defff26c06a196863521eee8ecd5e2efd98  release/kernels/ropediv.by_instr.json.gz
099af60013b03cfeb145cdc6af09cf1e79926657e133f7ea8ca15468d26eb8b9  release/kernels/ropediv.by_unit.json.gz
b85ca78f64f20b2220b3c38074936ef5edfa8dda0ed4cf07bb6266aa7a3df6ce  release/kernels/ropediv.ccvtrace
3e5368f9ade64a07c4f5fed2e501c81917fbb0585bb38e43741911fc711f3ed2  release/kernels/ropediv.log
10c0ec6ec18b7b44638c790033109198c079d07c1537bf193353ccedd00a920f  release/kernels/ropediv.oracle.jsonl
932f1b1e77d399764a2be91cbe8727755ca4dbd8b50e21478035778094ec059f  release/kernels/ropediv.sv-hosted.log
46165878550cc33ef9cfefc4e73d8352cbd4399d97880540a5ff163e0fdb63a8  release/kernels/sel.by_instr.json.gz
56c0bcc5ea7ff16e3728c9ace156a82f051c2bf9b1f9a6a7e4cd9fc224900e1b  release/kernels/sel.by_unit.json.gz
d647e23e18e16512cc2061f4c5ef8fde687a47a2e11482fb7dfecd77a7745778  release/kernels/sel.ccvtrace
88e2ee81dfd0c40864d57563ba2cd91818339bd473f134a0b23e4a39f3c7b90c  release/kernels/sel.log
87f6a81e8afa004c8039bf2f61c90176fcf29ab29bb17ac44aa016a5cc8438fe  release/kernels/sel.oracle.jsonl
af04d0ceb7e542b7877f4280c2e32db84c536a47c822f99f7d154a006d0485fc  release/kernels/sel.sv-hosted.log
ba4824f0e22dcc44ebb80fc2a64b0a88ef36e52e4bcb59dcaa9591fa1dc708ff  release/kernels/sized.by_instr.json.gz
a9f0f76ee92fccecfecb055affe78588ee7914ba4654a2404aed6dea170f7501  release/kernels/sized.by_unit.json.gz
3680714c49bfe395699a4b7dd792e1e24407e9b1147f6d87455a820a0e896d46  release/kernels/sized.ccvtrace
6f6b291da87887735107aeafd012331af82ef09e807fdc906eff72b45344fd4e  release/kernels/sized.log
36d903ba1618bd1faa437c9812a6ee6c0c966a63196c796267d74bf2695ebc3d  release/kernels/sized.oracle.jsonl
078b21d50ec85e696cab6bcd6a926169e51661ca842ee54ed766742a2eb1cd40  release/kernels/sized.sv-hosted.log
69fc2c5e71a65feab3a6ed938b88b549941ce201dd1fcb8810d637a637cfae53  release/kernels/slotform.by_instr.json.gz
0fc874dc214144a07dcc255fa1121a4b6b645db2b28e86d12a00db43349dcfec  release/kernels/slotform.by_unit.json.gz
888c7f098d91898c85e0a75eb80bbd7cab64b2c8726c1dd7843e3c1c30642169  release/kernels/slotform.ccvtrace
d2525843d0dc07fe375248bca2bbd166b54a9ad13e5c76568ea30abe1f67fb7b  release/kernels/slotform.log
8b61db7419b18cea8a646fb628218447e72e84a18a9891ffb73b441736138ab9  release/kernels/slotform.oracle.jsonl
4d5565ba5d9a985b8c4d83026a4e9e2b36b5c3b53ccf0a554d1fad37eda2ca77  release/kernels/slotform.sv-hosted.log
68e1a2f1d3fc39b26b43c417d6f0ee896206fe898b7f94a14e69ec0b92748586  release/kernels/spinwait.by_instr.json.gz
5685ca8ea4aafb74476f507cdc5a713793a1883618150277c136b7f5af95be9b  release/kernels/spinwait.by_unit.json.gz
11b2ce9ea1695c9698cd05836e17ba1d27993c2b93ffb4367499d3d83ae14bb6  release/kernels/spinwait.ccvtrace
5e587e376c444fca04d80f59e88a8df0031306c85ab4bb511183e01b8beea9ad  release/kernels/spinwait.log
868920637236c878b33779bd450439466fc3626996a3164573dc11d437d5c709  release/kernels/spinwait.oracle.jsonl
4053c52906e6b5dec298b7d1208927794b603cd47137e339b157211fbc81c7b0  release/kernels/spinwait.sv-hosted.log
5411f3ac91258dbe903c34680f475f44826c6ea78eab19736768ec77c86e32d4  release/kernels/spmbank.by_instr.json.gz
0866741fd5a60b62245ad25719e10c979201fe4ba11ec010b005834598261b48  release/kernels/spmbank.by_unit.json.gz
04b3dbe95ec991b471ee85d502128c2b90ddcce0609e1de27b77e4bdb5ba4042  release/kernels/spmbank.ccvtrace
51e217926e744123c60ea897913cb5eba755e973fbab21ea11700aacfb636f69  release/kernels/spmbank.log
3af490cc37d7a92dbe719b57de216b648536eb301ff9d13de9a39f50d150d725  release/kernels/spmbank.oracle.jsonl
ccc92cbec820fe168fefdcfa1d382a782bead49ddc5867d58a3051cd7949d4e3  release/kernels/spmbank.sv-hosted.log
ac61d3637023b973328b096f386f045c24eaa063c8ad3b7b4b971b3d0f1a60b2  release/kernels/srd.by_instr.json.gz
584b2a3bfc6b46e98b5ef1a475adf5a0102e83baa224e5199756fe17146d957e  release/kernels/srd.by_unit.json.gz
0de6fcb70c02376f30c7eed67f0cabf4cd00fc874e9d95f24465e7d79129b3e4  release/kernels/srd.ccvtrace
53e2f8ba8404d0e414d1b76f77099ce0c03d6b4a4ea4e2ba8f729c641c003772  release/kernels/srd.log
b08eb5e3673cac7eebb8b72af5ed3783c8e70a9e96592e76bf3722551bc79473  release/kernels/srd.oracle.jsonl
24b153673d817f3d996e2fa367c6243143aae74b430c4317db816a018f6ee40f  release/kernels/srd.sv-hosted.log
97aa2784981dd6ea8062472ed46e6af296874efeda6e17a2e1b1cdf0f0fe6482  release/kernels/stall.by_instr.json.gz
4afd79108b765718d09dab47827e76c65600ccf3c5a1c6d87fc83a4b6dc98452  release/kernels/stall.by_unit.json.gz
31de6d003020b11ea8584ad619db344145f01e01a531105af995c6143075253f  release/kernels/stall.ccvtrace
80781eec16f4e0230a97e0e533ac2f523e5c360fe779c689cfe4edb30fa31e53  release/kernels/stall.log
500db2c482b07a0706583422cd68878301d0146c1f872ccc1f11bfdcf5c993ef  release/kernels/stall.oracle.jsonl
adf7db08059ad460a04921417ac208d77cb17e862230d6bb4fad6576ad1d39dd  release/kernels/stall.sv-hosted.log
f988790d1925f3e52f3fe46fe6263de41c317835a5ed04b2f01a5c5a1ceabd36  release/kernels/swap.by_instr.json.gz
1c6376efc8feec0a137f8a3a17582d775ebb90c0da21b4d72a61c46d4c2282b8  release/kernels/swap.by_unit.json.gz
98e5250ea60a91a2e8a4d31e840a523ba270776e134dff62868d4060cb59ef1e  release/kernels/swap.ccvtrace
d128d587bd09789650fcdc4511bd8fe8439e93796e23db2932564604d2f68ace  release/kernels/swap.log
3658a26316c1ff7bc1744304a42f736e930fcde2865c8913e6cc67a22ce96667  release/kernels/swap.oracle.jsonl
2b2e5bbf5d3598e94066be070654f710841e1a9c96d5770d5b0a5e72deb1688e  release/kernels/swap.sv-hosted.log
6212998cd2be4d91ff4b70ebdfd45c10f5b648075bca260766b8f2e7ee00657e  release/kernels/transp4.by_instr.json.gz
8ba1f6f4ceb783a24f8ff4787034ca8519ef9fded52a31d022eadbe5806de301  release/kernels/transp4.by_unit.json.gz
a0a8df7657550fdb1bee331e8df19475a93a60d6c46710060c0c68c2c74cf484  release/kernels/transp4.ccvtrace
d574e91770a8457bc2bfc06c1c302564409154943471f131baae30dd5327c4d2  release/kernels/transp4.log
06396ace3ac19677fd39c700e408606e5bdbacb24997d663bbe8872e63dd74fc  release/kernels/transp4.oracle.jsonl
4af774be107e6a49cd1dd332343f3af61b9fe6d78f7c824594d17aa3e25498d8  release/kernels/transp4.sv-hosted.log
0b164350cb407baca6fd6711c5f56200bac2c68bc30752a4e8eee6bcc10f6310  release/kernels/unal.by_instr.json.gz
894c292b28344def36753b1b45a8e29decb88c4bc03a3dc1a286dd0db664b3de  release/kernels/unal.by_unit.json.gz
96227d2f550b50685353013980833df74e6e32c1b243ab11c0247caf0bd95e0f  release/kernels/unal.ccvtrace
a750273deb9671fed42ee1b936d88211530f906043d6f5f79742cbd1101557e2  release/kernels/unal.log
c3d484bb160657a563df983d9a2532eac27f556636617960aa1e72183ac2b299  release/kernels/unal.oracle.jsonl
64815b89389c60b712571345392bc34ee4f1eb6430f8ae9260e0794dbb0074af  release/kernels/unal.sv-hosted.log
b020bf33623b004fd7a441f0288b93f5086903902b48337c4fabf2ad056efb2c  release/kernels/vadd.by_instr.json.gz
9db507db87ea3846b50272fd49ec69b9dc268b482c8c6e5a51cffd305eb02b82  release/kernels/vadd.by_unit.json.gz
ceabf8fd66127f2fb44be921451fbb1d44658725452efd82cefbf5e4f412af3e  release/kernels/vadd.ccvtrace
9ab479a142f1ef8a2a1d304420661b5cbe6f1bab8089daf18927deb1bea896de  release/kernels/vadd.log
0276b6d0611a4bbcdc004ab3987214aea138245bc7217504147331689a9c0880  release/kernels/vadd.oracle.jsonl
18b3f20d278f78049bc33526e86964a9786f0991684803227afde44929b99c6b  release/kernels/vadd.sv-hosted.log
b68511f8ff5b535e3943c4b74a5e1316e72563c39334155f1db0e1633bba553b  release/kernels/vadd4.by_instr.json.gz
303d357f0b2903d2fc09b7f36de07e1a4a170bc9f68532b644dac5d6932a0805  release/kernels/vadd4.by_unit.json.gz
6fea84732d60ebf4629c215114af5415cb3f386ef71f38f6bb503e52c4bd1b56  release/kernels/vadd4.ccvtrace
daeef6e0be7652f64d9e98447616867de79c76fafe14a78e1065fde9b96bc626  release/kernels/vadd4.log
225aa18fc9f38aa9ad615aa11de254337d59fa705877553d873062c68366e0db  release/kernels/vadd4.oracle.jsonl
ce304dc8a114e771391081303a921b48e8fbde7182e4c2c7bf37302ecbd655d1  release/kernels/vadd4.sv-hosted.log
1c1e010a779019dbae88e9d7d5520ddbf858a3d9af5800ead441b75de48a0ebb  release/kernels/vaddslow.by_instr.json.gz
1447351fb8d8a68df0a5815a9082c083d8f140dd2c34d7a74b2c882bd7edf3fa  release/kernels/vaddslow.by_unit.json.gz
e1c7ff119caa439602b0926aabcda0d2d1907861a3d0c780857cfeb2c239151a  release/kernels/vaddslow.ccvtrace
bd5bbd179b96d96cdc22abe599acd34eac956aaf0601970a5e3972c8bbfe7d45  release/kernels/vaddslow.log
e9e6218e8b8450e9f9ff6b39d659c994a1e51c527a0c5bd10d18b5658ae0e344  release/kernels/vaddslow.oracle.jsonl
d40bd68f6a766cf022447905f99836042d74e35ae9967c9b701f3fe2b22bf777  release/kernels/vaddslow.sv-hosted.log
f81dcf0c1befe8bd80d71d7f3d08aa3bcf0c80c6caa0b85cb3c1ae73f8572c09  release/verify.log
1f3a2eff14dbda0754e19cbf72bc5003c950fc7d1691d527ce3a8d427fb583d7  release/wiring.txt
```
