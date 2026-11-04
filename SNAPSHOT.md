# Snapshot snapshot-2026-11-04-ebd3692

**A generated, read-only snapshot. Do not edit or merge it.** The source
is `ccr-9eb50716-lecnjf` at `ebd3692cc48a4ce0052b08668914d5fa1e48f5e5`, and this branch is rebuilt from source by
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
| Source | `ccr-9eb50716-lecnjf` @ `ebd3692cc48a4ce0052b08668914d5fa1e48f5e5` |
| Built | 2026-11-04 (UTC) |
| Gate | `tools/verify.sh`: PASS |
| Compiler snapshot | custom-cuda-complier `release` @ `d9ddd2c5c57fc99d8aabfad847d0be963830e212` (source `f5fa03032348a7318a51946fbcd89bd9caa46caf`) |
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
| `callret` | `name=callret finished=1 cycles=280 from_fetch=249 retired=40 issue_groups=40 order=ok gpr_mismatch=0 pred_mismatch=0 mem_mismatch=0 check_failures=0 class_violations=0 overflows=0 credit_leaks=0 channels_used=30/55 violations=0` |
| `chains` | `name=chains finished=1 cycles=97 from_fetch=66 retired=29 issue_groups=29 order=ok gpr_mismatch=0 pred_mismatch=0 mem_mismatch=0 check_failures=0 class_violations=0 overflows=0 credit_leaks=0 channels_used=21/55 violations=0` |
| `div` | `name=div finished=1 cycles=978 from_fetch=947 retired=144 issue_groups=144 order=ok gpr_mismatch=0 pred_mismatch=0 mem_mismatch=0 check_failures=0 class_violations=0 overflows=0 credit_leaks=0 channels_used=23/55 violations=0` |
| `divchw` | `name=divchw finished=1 cycles=99 from_fetch=68 retired=5 issue_groups=6 order=ok gpr_mismatch=0 pred_mismatch=0 mem_mismatch=0 check_failures=0 class_violations=0 overflows=0 credit_leaks=0 channels_used=22/55 violations=0` |
| `divtail` | `name=divtail finished=1 cycles=642 from_fetch=611 retired=96 issue_groups=96 order=ok gpr_mismatch=0 pred_mismatch=0 mem_mismatch=0 check_failures=0 class_violations=0 overflows=0 credit_leaks=0 channels_used=23/55 violations=0` |
| `divtail2` | `name=divtail2 finished=1 cycles=1517 from_fetch=1486 retired=366 issue_groups=366 order=ok gpr_mismatch=0 pred_mismatch=0 mem_mismatch=0 check_failures=0 class_violations=0 overflows=0 credit_leaks=0 channels_used=23/55 violations=0` |
| `fence` | `name=fence finished=1 cycles=82 from_fetch=51 retired=7 issue_groups=7 order=ok gpr_mismatch=0 pred_mismatch=0 mem_mismatch=0 check_failures=0 class_violations=0 overflows=0 credit_leaks=0 channels_used=30/55 violations=0` |
| `gather` | `name=gather finished=1 cycles=265 from_fetch=234 retired=16 issue_groups=16 order=ok gpr_mismatch=0 pred_mismatch=0 mem_mismatch=0 check_failures=0 class_violations=0 overflows=0 credit_leaks=0 channels_used=31/55 violations=0` |
| `hit` | `name=hit finished=1 cycles=228 from_fetch=197 retired=17 issue_groups=17 order=ok gpr_mismatch=0 pred_mismatch=0 mem_mismatch=0 check_failures=0 class_violations=0 overflows=0 credit_leaks=0 channels_used=31/55 violations=0` |
| `lanectx` | `name=lanectx finished=1 cycles=69 from_fetch=38 retired=10 issue_groups=10 order=ok gpr_mismatch=0 pred_mismatch=0 mem_mismatch=0 check_failures=0 class_violations=0 overflows=0 credit_leaks=0 channels_used=29/55 violations=0` |
| `lanectx2` | `name=lanectx2 finished=1 cycles=69 from_fetch=38 retired=10 issue_groups=10 order=ok gpr_mismatch=0 pred_mismatch=0 mem_mismatch=0 check_failures=0 class_violations=0 overflows=0 credit_leaks=0 channels_used=29/55 violations=0` |
| `late` | `name=late finished=1 cycles=172 from_fetch=141 retired=16 issue_groups=16 order=ok gpr_mismatch=0 pred_mismatch=0 mem_mismatch=0 check_failures=0 class_violations=0 overflows=0 credit_leaks=0 channels_used=31/55 violations=0` |
| `ldpar` | `name=ldpar finished=1 cycles=155 from_fetch=124 retired=17 issue_groups=17 order=ok gpr_mismatch=0 pred_mismatch=0 mem_mismatch=0 check_failures=0 class_violations=0 overflows=0 credit_leaks=0 channels_used=31/55 violations=0` |
| `lnorm1` | `name=lnorm1 finished=1 cycles=2593 from_fetch=2562 retired=526 issue_groups=526 order=ok gpr_mismatch=0 pred_mismatch=0 mem_mismatch=0 check_failures=0 class_violations=0 overflows=0 credit_leaks=0 channels_used=37/55 violations=0` |
| `localsp` | `name=localsp finished=1 cycles=4238 from_fetch=4207 retired=40 issue_groups=40 order=ok gpr_mismatch=0 pred_mismatch=0 mem_mismatch=0 check_failures=0 class_violations=0 overflows=0 credit_leaks=0 channels_used=32/55 violations=0` |
| `loop` | `name=loop finished=1 cycles=2842 from_fetch=2811 retired=407 issue_groups=407 order=ok gpr_mismatch=0 pred_mismatch=0 mem_mismatch=0 check_failures=0 class_violations=0 overflows=0 credit_leaks=0 channels_used=23/55 violations=0` |
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
| `privwin` | `name=privwin finished=1 cycles=2215 from_fetch=2184 retired=52 issue_groups=52 order=ok gpr_mismatch=0 pred_mismatch=0 mem_mismatch=0 check_failures=0 class_violations=0 overflows=0 credit_leaks=0 channels_used=34/55 violations=0` |
| `provswap` | `name=provswap finished=1 cycles=2327 from_fetch=2296 retired=978 issue_groups=978 order=ok gpr_mismatch=0 pred_mismatch=0 mem_mismatch=0 check_failures=0 class_violations=0 overflows=0 credit_leaks=0 channels_used=33/55 violations=0` |
| `roconst` | `name=roconst finished=1 cycles=64 from_fetch=33 retired=4 issue_groups=5 order=ok gpr_mismatch=0 pred_mismatch=0 mem_mismatch=0 check_failures=0 class_violations=0 overflows=0 credit_leaks=0 channels_used=26/55 violations=0` |
| `rogated` | `name=rogated finished=1 cycles=84 from_fetch=53 retired=7 issue_groups=8 order=ok gpr_mismatch=0 pred_mismatch=0 mem_mismatch=0 check_failures=0 class_violations=0 overflows=0 credit_leaks=0 channels_used=26/55 violations=0` |
| `rokill` | `name=rokill finished=1 cycles=93 from_fetch=62 retired=41 issue_groups=4536 order=ok gpr_mismatch=0 pred_mismatch=0 mem_mismatch=0 check_failures=0 class_violations=0 overflows=0 credit_leaks=0 channels_used=27/55 violations=0` |
| `rolaunch` | `name=rolaunch finished=1 cycles=62 from_fetch=31 retired=4 issue_groups=5 order=ok gpr_mismatch=0 pred_mismatch=0 mem_mismatch=0 check_failures=0 class_violations=0 overflows=0 credit_leaks=0 channels_used=24/55 violations=0` |
| `rolimit` | `name=rolimit finished=1 cycles=64 from_fetch=33 retired=4 issue_groups=5 order=ok gpr_mismatch=0 pred_mismatch=0 mem_mismatch=0 check_failures=0 class_violations=0 overflows=0 credit_leaks=0 channels_used=26/55 violations=0` |
| `roload` | `name=roload finished=1 cycles=106 from_fetch=75 retired=8 issue_groups=8 order=ok gpr_mismatch=0 pred_mismatch=0 mem_mismatch=0 check_failures=0 class_violations=0 overflows=0 credit_leaks=0 channels_used=31/55 violations=0` |
| `rope` | `name=rope finished=1 cycles=7758 from_fetch=7727 retired=354 issue_groups=354 order=ok gpr_mismatch=0 pred_mismatch=0 mem_mismatch=0 check_failures=0 class_violations=0 overflows=0 credit_leaks=0 channels_used=34/55 violations=0` |
| `ropediv` | `name=ropediv finished=1 cycles=1121 from_fetch=1090 retired=203 issue_groups=203 order=ok gpr_mismatch=0 pred_mismatch=0 mem_mismatch=0 check_failures=0 class_violations=0 overflows=0 credit_leaks=0 channels_used=34/55 violations=0` |
| `sel` | `name=sel finished=1 cycles=76 from_fetch=45 retired=8 issue_groups=8 order=ok gpr_mismatch=0 pred_mismatch=0 mem_mismatch=0 check_failures=0 class_violations=0 overflows=0 credit_leaks=0 channels_used=29/55 violations=0` |
| `sized` | `name=sized finished=1 cycles=2641 from_fetch=2610 retired=25 issue_groups=25 order=ok gpr_mismatch=0 pred_mismatch=0 mem_mismatch=0 check_failures=0 class_violations=0 overflows=0 credit_leaks=0 channels_used=32/55 violations=0` |
| `slotform` | `name=slotform finished=1 cycles=4365 from_fetch=4334 retired=12 issue_groups=12 order=ok gpr_mismatch=0 pred_mismatch=0 mem_mismatch=0 check_failures=0 class_violations=0 overflows=0 credit_leaks=0 channels_used=32/55 violations=0` |
| `spinwait` | `name=spinwait finished=1 cycles=2181 from_fetch=2150 retired=211 issue_groups=211 order=ok gpr_mismatch=0 pred_mismatch=0 mem_mismatch=0 check_failures=0 class_violations=0 overflows=0 credit_leaks=0 channels_used=34/55 violations=0` |
| `spmbank` | `name=spmbank finished=1 cycles=185 from_fetch=154 retired=13 issue_groups=13 order=ok gpr_mismatch=0 pred_mismatch=0 mem_mismatch=0 check_failures=0 class_violations=0 overflows=0 credit_leaks=0 channels_used=28/55 violations=0` |
| `srd` | `name=srd finished=1 cycles=69 from_fetch=38 retired=6 issue_groups=6 order=ok gpr_mismatch=0 pred_mismatch=0 mem_mismatch=0 check_failures=0 class_violations=0 overflows=0 credit_leaks=0 channels_used=29/55 violations=0` |
| `stall` | `name=stall finished=1 cycles=557 from_fetch=526 retired=116 issue_groups=116 order=ok gpr_mismatch=0 pred_mismatch=0 mem_mismatch=0 check_failures=0 class_violations=0 overflows=0 credit_leaks=0 channels_used=31/55 violations=0` |
| `swap` | `name=swap finished=1 cycles=557 from_fetch=526 retired=174 issue_groups=174 order=ok gpr_mismatch=0 pred_mismatch=0 mem_mismatch=0 check_failures=0 class_violations=0 overflows=0 credit_leaks=0 channels_used=31/55 violations=0` |
| `transp4` | `name=transp4 finished=1 cycles=1162 from_fetch=1131 retired=976 issue_groups=976 order=ok gpr_mismatch=0 pred_mismatch=0 mem_mismatch=0 check_failures=0 class_violations=0 overflows=0 credit_leaks=0 channels_used=37/55 violations=0` |
| `unal` | `name=unal finished=1 cycles=136 from_fetch=105 retired=9 issue_groups=9 order=ok gpr_mismatch=0 pred_mismatch=0 mem_mismatch=0 check_failures=0 class_violations=0 overflows=0 credit_leaks=0 channels_used=31/55 violations=0` |
| `vadd` | `name=vadd finished=1 cycles=157 from_fetch=126 retired=17 issue_groups=17 order=ok gpr_mismatch=0 pred_mismatch=0 mem_mismatch=0 check_failures=0 class_violations=0 overflows=0 credit_leaks=0 channels_used=33/55 violations=0` |
| `vadd4` | `name=vadd4 finished=1 cycles=208 from_fetch=177 retired=68 issue_groups=68 order=ok gpr_mismatch=0 pred_mismatch=0 mem_mismatch=0 check_failures=0 class_violations=0 overflows=0 credit_leaks=0 channels_used=33/55 violations=0` |
| `vaddslow` | `name=vaddslow finished=1 cycles=546 from_fetch=515 retired=17 issue_groups=17 order=ok gpr_mismatch=0 pred_mismatch=0 mem_mismatch=0 check_failures=0 class_violations=0 overflows=0 credit_leaks=0 channels_used=33/55 violations=0` |

## Manifest of release/

```
e4687cae19470ad461b3a6c82d52dc68ee9903728c378ba884dc4131db287589  release/kernels/addrhigh.by_instr.json.gz
b6e21f1d60de31c8095f9059e4fe10976dc281a3dc77426765d870e2482a51ac  release/kernels/addrhigh.by_unit.json.gz
0661ac42f0a88fab0abe16dd618203786ac21b3032787954dd5c7236c598e446  release/kernels/addrhigh.ccvtrace
ff1a566fb8e68d676754999a9b737d08893c2e3e825bd77ebabd7cd069d50d18  release/kernels/addrhigh.log
569f2e22883fad5f0956c57ec734e6afbdd4b8a854e50277425172d6c0cbd766  release/kernels/addrhigh.oracle.jsonl
29811ab56b0e93a3fc194da026a869644295b896490dc5c11099a7c9ac054b5c  release/kernels/addrhigh.sv-hosted.log
89657fdaa19b5aed66f1bc00f2ca0c95986b020155e35077475dc28a643d98b0  release/kernels/addrlimit.by_instr.json
aec7c9bfed1544ae6953f0d4b9ac9d2735375c03ab4cca6fec0f952968707785  release/kernels/addrlimit.by_unit.json
393c0da8622a4a55b4a1c25a7ccfb9226947ca91903cff94db8d69e6c012c3f1  release/kernels/addrlimit.ccvtrace
3f89a5d2e6430edac81b5b5b379b38a8917d1f6b297be15bade8355f5e6b2134  release/kernels/addrlimit.log
bc660b0b40359a2c5a2478cb0eb4950b73fd22db50ea76b80052bc195a1920f4  release/kernels/addrlimit.oracle.jsonl
93f3aca246ef087dd76d1b900ec4694f0ef4fd393f0259c44c5fa69b27b6c004  release/kernels/addrlimit.sv-hosted.log
ea8c34b3706590b020eeb2c15130ef52a55bf630a8d18c03356cb840c2c44ad9  release/kernels/addrneg.by_instr.json
9d04e045b564b5eb98e168a2d717da9b30745b8e7f2c05c3b20e93e4d589ee2d  release/kernels/addrneg.by_unit.json
1856f3c088174d4d7fe55002b7a6bcf5788aea5a2a0e341aaca981ff22c6640f  release/kernels/addrneg.ccvtrace
7bb437c6e4c3deb1676dbcc5bc81fea0a87bd56f500bd98fdbeeb67e565062af  release/kernels/addrneg.log
16f5b0707ae44492a1efd67bb9dd38a7e79a7bbd354fa9207b9e7d150ff2f107  release/kernels/addrneg.oracle.jsonl
8ccbcfd6eee3fcb0daad62703e6d6b20393210ee562ae4e5ffbc021967042118  release/kernels/addrneg.sv-hosted.log
0950ae74f10572c047349adb2ce2c2eda100d7904cec512f3a01e4f50222da5e  release/kernels/borrow.by_instr.json.gz
ec3595a962bff4b66c09b24dd4a5f5ee8a988106f9172562fbbe7bdf10991fbe  release/kernels/borrow.by_unit.json.gz
53bf3d4b18a0414b481f5a80b52b155d57294c1387b373d1dbc26cf573d429a2  release/kernels/borrow.ccvtrace
e54c1cce9f8f2c8f6d7f701ea694634d992a92081ee73c0ae02deeb3be3fc549  release/kernels/borrow.log
4c565e1ce0b3baee36e158694b32c8defb5cd662b2f9af75cb5d8c26cb1168ed  release/kernels/borrow.oracle.jsonl
c59ced98c9e5b32b6b1b41ff9040eaa96f6c1363f2ca1478642519f8b637e0be  release/kernels/borrow.sv-hosted.log
48841ecdb4d65ff29e2bf038e93d8f31685c0e0323e575097c883703eab3b598  release/kernels/brs.by_instr.json.gz
a2315145ee2cce8ec915f00e3d129684897dafdc5cf0fb99878607b7808344b1  release/kernels/brs.by_unit.json.gz
3429cd31fc2da452b73157c653ccd63095c4243f61fb18ae98d290c33a09e928  release/kernels/brs.ccvtrace
fcd91700239fdbd9dac9df127805106f37578b60b328c703bdbf84797f9d4eda  release/kernels/brs.log
e3c1cb3379580cf1aae44e8ddc8e846ef6fd661a573cfe0a8d4444b18a14dc56  release/kernels/brs.oracle.jsonl
af9cb8b767af0f20af8867abe0960a943577945df257702ef5c47517b8b9bda7  release/kernels/brs.sv-hosted.log
a046b90880cc1853c80311006110ac73e4448b1560d5e54e32a542d4b7a08f79  release/kernels/byp.by_instr.json.gz
5da95fe6bee3769d9cd36ca250ec728e23f1f265dc5ac64b1abc2ce9d2246c97  release/kernels/byp.by_unit.json.gz
097c7e5692b7350d9087235b51ac02338448abefeb08a7d9d68e990adb1c69f8  release/kernels/byp.ccvtrace
89be1bd58b45079ce4e0e6a1d709319c7d3feebfcb5c45e188bae1388282002d  release/kernels/byp.log
5a03dfa4f3603fef49f1e3639e74e34152ca3ca5ef8e41eb959f8323040fa2d5  release/kernels/byp.oracle.jsonl
340bb1ff5c30c4989f90cd45db87a5450a69af386e3ce375ffbdfa552cd37ae0  release/kernels/byp.sv-hosted.log
0c49fb3da9548a074f771b4aaa1744a91b12f1f1eda38102e0de770abf3b5dd8  release/kernels/callret.by_instr.json.gz
e4085616ab03375ec7b85f5a66509a05a482722fb052834e8d9b7a6274c6d937  release/kernels/callret.by_unit.json.gz
abf594e26b52c7ca113101c570e23da8ef87dfa7da51a43c43a3cc13687f4ca9  release/kernels/callret.ccvtrace
6c034e79ccbc4251f43b7e3a58602849671657f330fb19d54a3d562986b8e4fc  release/kernels/callret.log
9b1d1b50b527f732362f837250aa2f26dabf3e76e16a4794856ebd8f105635b8  release/kernels/callret.oracle.jsonl
7f86034576414f8f2087becc4061489694aea9628cfde1b8fb1414968118b023  release/kernels/callret.sv-hosted.log
157685b10af8922a8a1981467ad57697ede8f57d4dca0913bdabc2ef63ddfb71  release/kernels/chains.by_instr.json.gz
4bb3208f84c082d3dba746b1d5f929c41ac8931b1e39fea4048b4da9af128330  release/kernels/chains.by_unit.json.gz
7b28b89e2edf15702229dbd78c0c7d20978e2e96e8c74a8b07beb1f2d2b04f94  release/kernels/chains.ccvtrace
9b998cf0ec83a7105cadaadf149b69ed4b3d32ef38d58ebeba51d579f9f65627  release/kernels/chains.log
26a4cc5c5524c7219d8706c2582c80357dea60be9d6ffdec99dac7d0365e2264  release/kernels/chains.oracle.jsonl
cbb623f6e0355dcddf9de27871e9c9b02d3c8502d760ac88aab335a17e01341f  release/kernels/chains.sv-hosted.log
652c6f05eaf6809a55a5bd26bc0697352833697c1de5a42cf852e4a2db7f94f2  release/kernels/div.by_instr.json.gz
6d524ba4dc01c9cb6eba80ab226ae301f3520a782550e4286ef702560716c9f1  release/kernels/div.by_unit.json.gz
a3d42ac7be5398fc431eae060a399fd521a6404d3b788786d0860c223aa2d677  release/kernels/div.ccvtrace
3bba5084c1174f888e2d018438939b1c7ca5c5829b1e2e455f02d36809c046fe  release/kernels/div.log
71a567b85cf85622631490187563de9a5661099c78a590adff4ed0a0c3d24c16  release/kernels/div.oracle.jsonl
b3330ce5b07c6c0025312f843c6922c8ab6856bceff18bbedc170bfddaad8211  release/kernels/div.sv-hosted.log
20474411d5b2ed8cd96837928ac29bc4811c426dfb446b0109357548b87c88d8  release/kernels/divchw.by_instr.json.gz
b20048f69bfaa6f4cd0fa649662530117ee493c3a657e9d82377990346b1ad46  release/kernels/divchw.by_unit.json.gz
64e79dbe863bcf54a416bd395ac9390bafd483d533df4fab093ce412854146ab  release/kernels/divchw.ccvtrace
5b92766896f7f7ab5e314fb4c836a98f3fede3ab882917d95eddde354efc82d0  release/kernels/divchw.log
58a541797f7a2df0a1c7528ae6a3edec212db90c7d3eb20656806f38b5c10b3d  release/kernels/divchw.oracle.jsonl
9cf20c404340d23ff061ee8830b5a26513639cd4cc334267a1861c874cfe464a  release/kernels/divchw.sv-hosted.log
8471da4bb14841fffc7f233154f02f16dfb5d4969912f73f1b0ea3c87ae79377  release/kernels/divtail.by_instr.json.gz
b6df9164f51181ffecfd18faa75fde79515a8d9619be7a89180c5a00473ffc00  release/kernels/divtail.by_unit.json.gz
9316548aa587ac844a5a1c523088f650cb2f9414746d4bc01fbcdc7e398ae8b4  release/kernels/divtail.ccvtrace
4d09d25ece97e63a8fbf9c5279fe701affe6bd7586cdc58db6fcb8a66ec6baa2  release/kernels/divtail.log
75f11a75c9b3b336e446140af4579f05b46c363a76b7aab3ec88154a07ba097d  release/kernels/divtail.oracle.jsonl
c2efa1b65c5e113209952dd7f40f438739c216a0764fd048d20faa414a8ea863  release/kernels/divtail.sv-hosted.log
7d406b367286f30185a8d5e027bb4d51fbbdd21e6d5223878f629c608cb0419a  release/kernels/divtail2.by_instr.json.gz
7facaeca1e722f45a242f52d285fb7be68658ef0e6cf4801cf2d465978cd5b30  release/kernels/divtail2.by_unit.json.gz
34da6548abc858b5b6be931bea26853813584f4e2298c0589c5b92effb352edb  release/kernels/divtail2.ccvtrace
ba11514b5f430645b473ecb41e25e59aaf4040b00cbe1db91a0cf78532d1f628  release/kernels/divtail2.log
b2db6b05eb6cf4a0a7677e31d0c6c2952d5cab49d353f0bb1883fe0b2a20ed14  release/kernels/divtail2.oracle.jsonl
5cd243849ee32e853961898cbb72ee3c925baef16362da9b6ec0d8f4d846351c  release/kernels/divtail2.sv-hosted.log
df4ac9c21ee9e911e2dcc9d4c2cf9ab5d017d6aa1f3999a16fde27d7234c730f  release/kernels/fence.by_instr.json
22652d3edfbd571623c1acefca359a173468022b730eb11888c34c3e39fed75a  release/kernels/fence.by_unit.json.gz
aba03523ed2138041961a6e7de252e88686ff4ee8fca27e3d426bd4dafedd7af  release/kernels/fence.ccvtrace
fe5a49e72d619b2a3a88aecffc29b9a6b6df02101e70e0eabdfbf59a3b6bdac2  release/kernels/fence.log
d1d40317f6cf5bfb430cda1f9c0ef676609e59cabe2a11623c42ffbeca93142b  release/kernels/fence.oracle.jsonl
b07e4a23d29f0614da0e7f97708fdbd0f9c3b61509b101c081b0fe0e50a41419  release/kernels/fence.sv-hosted.log
42d2548bc291ec3465a607775a5cc7c39646f886b367b48781aa8ce93ad05399  release/kernels/gather.by_instr.json.gz
89f950210c7cd2a8fc997403165ad266fdc22469fca799dffbcffe14617dce52  release/kernels/gather.by_unit.json.gz
54ef7aaacace62b402a68ebad3887326470a82eae52f92b208ac7140d76b784b  release/kernels/gather.ccvtrace
d4f0fca4fcebaca14bb9b03951c63ac21b5a171854c8b4cda12cfb2b2d5badec  release/kernels/gather.log
0413e781d8d6ff578c64eb1f800b7931e66f676d5cdabb97b94a4033e6037662  release/kernels/gather.oracle.jsonl
d32043de58f7f03e50db08bfa422254b10ae21f38fd1b8c982ff009ed0cb8774  release/kernels/gather.sv-hosted.log
0fc5900b0e05afa07e3973b2575c6dc16b8cb730630609f5c72082de33c4cf8f  release/kernels/hit.by_instr.json.gz
2c16e6d0e4340ece807e7bb06ab06648776cbad9feb67f35cdfdcbce57270f5b  release/kernels/hit.by_unit.json.gz
1ce490ae78b2216bef3b662a2af3599a189e7adbbbeee3c94437fe761a23b63f  release/kernels/hit.ccvtrace
75b66a4a4786b36fedeac055b493ee8b91234999eff47227edadb60f86253f12  release/kernels/hit.log
7ba9603e0088d9164de6528f16ef6a7fa9ce5821c8c12b52cbb3734e39b9fd52  release/kernels/hit.oracle.jsonl
5d58cd84f6ff7a63e13326646a934822c5059bcdde41df10e95c40b5952e9be7  release/kernels/hit.sv-hosted.log
db4f01b4b58d361bd18b31d33c07e8f2d818e20ce8515fef400ae9d4e31518e1  release/kernels/lanectx.by_instr.json.gz
5a01cddb7e370590b6c67a2489081c9baa9dee39272440762f156d9f4fa156dc  release/kernels/lanectx.by_unit.json.gz
2119a6d9ac7beafe1a70d893ba377d3a3a40321c947a753c4e2d41a2092f20df  release/kernels/lanectx.ccvtrace
6c841c3febc6e69b975f5a8b2372b9387e9a25b0ba175778f395913a96d6e1de  release/kernels/lanectx.log
888551babf540db8e3025b82e65ca655013f93eba3c8a65689d069d52a7e6039  release/kernels/lanectx.oracle.jsonl
641c910a2cd0912e8e4d36e1598a798648d2e539a590d74ca85823396e83351b  release/kernels/lanectx.sv-hosted.log
a96990929834adfeb300341a90d147da39039b94413bc4feea6853ca2003bc94  release/kernels/lanectx2.by_instr.json.gz
2b126ce5d1752e1469e566883cfd17aa300f2e642ba968e008d365c34414626d  release/kernels/lanectx2.by_unit.json.gz
394c48337bde53cdc91d6c2264f547b03abff4aca0718988d6e4a75b05d5d197  release/kernels/lanectx2.ccvtrace
644caa717cbc5ffc82ca7b7ac7b4c5cdf9ac030a8beb9e9aa08dbe16fc572592  release/kernels/lanectx2.log
45c13056dff5c73ed0c9ece56cc36f929bf335322193c7d5eb38710b1d1dfb02  release/kernels/lanectx2.oracle.jsonl
67fa6915b2da088a270be1bad1dba2ecfbb8a5d49b814e85a5f52b590d225c5d  release/kernels/lanectx2.sv-hosted.log
0e9d3ba6568c14ae18576c0e01d20426db6b7ad02a9f317420b8cc8c77db88b6  release/kernels/late.by_instr.json.gz
a73919865e9664ae41f0e3694140bdb79f5859fb0b06923a2faa534147d20824  release/kernels/late.by_unit.json.gz
115085fa283eaf72359f40ae50a5ed2e3feadc7e0eedf694a611494042846f35  release/kernels/late.ccvtrace
e78e405835d33dff5d2d9043380e1f64bc864f373a1a5cafef413a2d1783266f  release/kernels/late.log
86084f6bd747a2cf32acbc0ebd96ebd3e4ef2d8d9e21be49e3ae49290d7927f3  release/kernels/late.oracle.jsonl
cd5a44793cc7d14d3e66068005d2a0c785f120fac577888d22ad7d36c0b2e8cd  release/kernels/late.sv-hosted.log
1cee1ee4a3dfdafd8e7b5160ae72c9ac39649287e478beeea25052fd6e5e0a96  release/kernels/ldpar.by_instr.json.gz
84ac1ba465d3586910404bf2f4b0bc07793cb66f282a63f1d7d12f0773a71022  release/kernels/ldpar.by_unit.json.gz
8595a89fd61743b14b53c46d151d81bfcd88d15c88695ca218fec5e2ad706746  release/kernels/ldpar.ccvtrace
3e6e4135b8389ed3768b461aae465ddbedd8efec05b2c372d64fe77096730d91  release/kernels/ldpar.log
8ac08538e9c807637babd61b31e340f7461878ada31f0c0b83cd66331cfaf486  release/kernels/ldpar.oracle.jsonl
3a4435338d0c65f07b62d2b229d8972f1ac8e7847e92df55d76cb9b1b7ee5e1b  release/kernels/ldpar.sv-hosted.log
3901ec53b6995503b9d8a301a0f311e31025dc4568ecdbd320bfe75ab0ca5522  release/kernels/lnorm1.by_instr.json.gz
0c4198402117932d391da79e16d330ad78f85f8928da98b6b2f1736c65192c65  release/kernels/lnorm1.by_unit.json.gz
b2350d199bb4eb7d24bfeaf1b538d56cecbe64c5af275e5e95dbeb2b97c376e7  release/kernels/lnorm1.ccvtrace
1a647b0b0eadce600f80a1e446ec57e73e9ab22e1c33f97366f652d5b2466c5d  release/kernels/lnorm1.log
a8d85811af988a1b9fc00db1517300af3d93ec8e589e403d3b9113fa9e0ffc86  release/kernels/lnorm1.oracle.jsonl
1993408e90d162e988ef2dcc3be42a47abf7df3d58d2aa177f3025bc9cf91ca2  release/kernels/lnorm1.sv-hosted.log
75abb1e89d387abd1a5d5f5fd1bafa837a880d5ba6966eeb0c0fb2b7cbad0dd1  release/kernels/localsp.by_instr.json.gz
d70c2303b0911bad5caf9493b4422aa4642d4e6fbd8dca6b630e3ac5d21183a0  release/kernels/localsp.by_unit.json.gz
38184fb5cab0c4b1266021ba6a922bc81e601fa502682b6e23a027fbe9c50759  release/kernels/localsp.ccvtrace
32d5a644998c97ae739956a7f5c456db798b0119c2aed0b07db325404212bb9e  release/kernels/localsp.log
55e3c9f36e7f7d38c0ddd38903aff4bb4509ae862015c592e6b937ea258042ca  release/kernels/localsp.oracle.jsonl
de1985063722e928898a1f35d945fafed66358b5b6d7e98aa2f61de03d617408  release/kernels/localsp.sv-hosted.log
77c8261ef8ea64b00d1989be15f1a9feb8c0999d238a7e2c6eafcb5ba37d939f  release/kernels/loop.by_instr.json.gz
400884a689ecb30859322458fee22e9367b793319e276b22c5b0443d331bc071  release/kernels/loop.by_unit.json.gz
b5415c9d6d5fbceb4c9ff083c5996da715acad9b893b83a8e0dc8708caffbc44  release/kernels/loop.ccvtrace
185de009ef38ea64b165a6fc6c14e8c958f050a995517496202c83cde85e7f91  release/kernels/loop.log
03ce5920c06c93e93516d8e53c3f7169f14e3593de204eacceffc0b8a3e32016  release/kernels/loop.oracle.jsonl
e50cbfeb81892c54ec991f06216421fdb6380f830e2fbcba85b18b146d136141  release/kernels/loop.sv-hosted.log
5d63ab8574a0bedc903fb12678a35793cae271d26c49681f4200425c793200b8  release/kernels/merge.by_instr.json.gz
294b068350eac888c073c97c657c25f9a2d485e2f18cbda7ec782cf5af35679a  release/kernels/merge.by_unit.json.gz
f03b5b8724e00e74c9cb603221ebcb45271d5787fa8675d733085d71f8b0e307  release/kernels/merge.ccvtrace
f8d17ca3da5849bde321420f242c0d38da7622e0fcdb8502c9700bcb49d3d6f3  release/kernels/merge.log
f96d28815f8756b1f5a45ded53e6170883d2dfa10f9eef0d14b8050b1318164a  release/kernels/merge.oracle.jsonl
e16209aef95ec25c07d6ad48f47e9901700dfb5b9af1457b31b8a0d6772e4f15  release/kernels/merge.sv-hosted.log
fa0176819dd7376508af7dfbb82dfb0862ab0bcf7b50f2b9c08c9c6cefb0242a  release/kernels/missrun.by_instr.json.gz
e10248c318fd65f5905f0ce8738da28e492c7aa61a407d1cc26ad1317a7b9aa1  release/kernels/missrun.by_unit.json.gz
1f25502382ab70df5f849c555ceae405bb1339d095932ce00f1d5448d573593c  release/kernels/missrun.ccvtrace
aeae866bbba55da369e0922633309fe44a0049fc68fb8041213521dceef32bef  release/kernels/missrun.log
531bdaf281e5590774bd2775427f25e4cc0419cf8e3d5b6999843ffe9ef87258  release/kernels/missrun.oracle.jsonl
a8924cf9121cc535815c71163548422e5af933884fc973b9cb8675ccc79928bd  release/kernels/missrun.sv-hosted.log
7ac33724c7d2f88b3f903e8a67f62740b5a1ac3294bd8e82c23c6c5ddeb8fadc  release/kernels/mload.by_instr.json.gz
d4a909b17602b0da8e30550635cf477f47e2319678be08b170d5ba49ac14118b  release/kernels/mload.by_unit.json.gz
9fec8b9122e6e1293201cbc39b39ffa20f615df0f3e5df5e8ca3160af98f735b  release/kernels/mload.ccvtrace
9099d27f3567aac469d58e2cda4614cf82704f44659db51941c64760f4f36f44  release/kernels/mload.log
8000e477b9a95dfb9f0af964e8346acb9d36f1358fd06ffc4ff7cf599d2b8868  release/kernels/mload.oracle.jsonl
c54aafed0548f77550743133c77d941a70d82082f39ea978741dc933f6919486  release/kernels/mload.sv-hosted.log
252c9c2684cc2b3a6874fea96c41dbd56c56a362aaeeaefc615ed2f1779df3fb  release/kernels/mlp.by_instr.json.gz
06393bd06a6c8103f3fc78ac662c3b5c64f0aa1a2c609f977bc182e56307de36  release/kernels/mlp.by_unit.json.gz
efb84392c7d90847dd248fbce31bb95e9de05aed82f3f7defdd08c1806240d4c  release/kernels/mlp.ccvtrace
7cfb7d1c06bddcd1bebb1167bd6c6660d2ed3bf4d7cc23a01dc47f0d4c3caf79  release/kernels/mlp.log
138d282f88d56c8ad648a91af0a983254b55d9fa22942c00d47b327f516a6e44  release/kernels/mlp.oracle.jsonl
65f8f41c2ad900b29027e3acf13dc364778aaaf675107785f818b8d56f8eb82f  release/kernels/mlp.sv-hosted.log
6a0a2e61f1e8c559c8d816315b4c7f84aea0ae5334721d9ec6f6252ed6e8f924  release/kernels/mwmiss.by_instr.json.gz
0c087313869a2e6a5aaacbff9c1df9d7ddf49a4e848de924314bd63441b6c23a  release/kernels/mwmiss.by_unit.json.gz
3db6d9460bb9660ee4c47f2bbdaff9c3d4eea5a50f1fcc1fbf91f26cbabf7c6d  release/kernels/mwmiss.ccvtrace
270151e00848ed34edc207bcfd2f1da5fa3e2895e9c126ed21283b647c4d66cd  release/kernels/mwmiss.log
8abe8e8997456a2a6711ee72da54d854b24e20abbdab28e4b7271c0d28418de8  release/kernels/mwmiss.oracle.jsonl
6941616dffaa5d2ecda2bdac4e53f52b4b56a0eba5db3247209339a1903d247a  release/kernels/mwmiss.sv-hosted.log
3dd7077fcdd850b3a8e34362a939bbabf720333d9f2f5dde85500f021f843c05  release/kernels/narrowadd.by_instr.json.gz
a7bf6e8526b8cfc47e594c096e984012492f64bae185d3cb0b87708d0c20bf76  release/kernels/narrowadd.by_unit.json.gz
c694438d74fae482899c34004c2faf5940249fd99ddff07b91d4f0efc392c687  release/kernels/narrowadd.ccvtrace
6a32a3576a92ed994a6cf77b0a337ba9b58b816b18b4782e203532d7c40d6145  release/kernels/narrowadd.log
40a2cf629853dd404bb06b4a07e35abde3d12efc13f26ffe28f923daf2994574  release/kernels/narrowadd.oracle.jsonl
ba9738cf21031e7bb4964714a6fc949574eb6a60ea5ad62799bcbfa77d084021  release/kernels/narrowadd.sv-hosted.log
131f95e2da68d7a674e2313a33b9e36dd7f705d0e1195a741e263f09cf852a20  release/kernels/pguard.by_instr.json.gz
37f0abe7d0dc3e4eeb72a2f12a79aa0ac3c89a47a2a3d9e35adb204fb5eff99c  release/kernels/pguard.by_unit.json.gz
d10835277946646e5c8525db1ab4eec371d368e8c7fd12edc30ec901d0d2f132  release/kernels/pguard.ccvtrace
e8f7bab52a4d41b10a8eeea5fbf91555a5ab551bba3432408e562a6808ea183a  release/kernels/pguard.log
690e56f1cb8d97cbf67124b7dff3ad0a90cb8981814cd1709cf0cd0e035b3bd9  release/kernels/pguard.oracle.jsonl
ac8744f9d37e4a5d1d2e9a30e9055f480db697d45ee2f93f8ca8169548a2beff  release/kernels/pguard.sv-hosted.log
44065d212a7fd83e1365ab948aa302372d26c381f2d9755ec090ca3dc50ace65  release/kernels/plog.by_instr.json.gz
81372ccb1a0863d4cfe13b03d1c31bc2d6d1bf877b8f2f3a3e4f05128d77dac7  release/kernels/plog.by_unit.json.gz
13e1078a9590b035eac19432548487fe382c12db4e8cba163df97c474cff5f5d  release/kernels/plog.ccvtrace
cde64746d910ab39cec1ff6b736218cd460694a8624fdc8a03b8b54f478d279b  release/kernels/plog.log
c230f13f2e1082b306a9c5ab7809ff36cf5c1b2e47dca6b7a71f741524d403f5  release/kernels/plog.oracle.jsonl
cedcdb56233c6df97f9f67370c8e065277ddfb40c2197dd0efeab07dd3841c5e  release/kernels/plog.sv-hosted.log
2859396feec26519b88d1b32cd87275c751a6718722cdf7b7e7d788ec5d1bf21  release/kernels/predlane.by_instr.json.gz
6f166713b0b7f80654e39dc5ca9c1032a7074b98ee3120701d9c9dc3a989fbeb  release/kernels/predlane.by_unit.json.gz
cc231b4a097822e6f4f7430cb533ce75633d7125aa0b5011ff12e4dd564d5011  release/kernels/predlane.ccvtrace
1cb8ec30517a04f5d717d8797ce9ce1dd1c92580d1f87801eab0d037f9961614  release/kernels/predlane.log
c45f4177b9e84fc8a6e36b13534a0c7636eb30a3f8531847100ce5e23bf404b1  release/kernels/predlane.oracle.jsonl
85bad5fa84012f3ebe91cff74947e03ded6637b117b09d6c161db194b2ec303a  release/kernels/predlane.sv-hosted.log
bcdcd4760f790f0ffaac06ed8f085d2c07ac78046312701c18f1ab463e8b06ee  release/kernels/predmerge.by_instr.json.gz
0d22ed459134c94b79376182243e282d3783d01de71468dc51268e31c72656df  release/kernels/predmerge.by_unit.json.gz
bb4693d2c39bea3e0f2f15d45b29760e080fe3be2b6c38e233b7216ed5a297b3  release/kernels/predmerge.ccvtrace
ac6873d8042472952f98f914b7ad753ef71e651f9a1ac344ed8c66a8e22acfc9  release/kernels/predmerge.log
6c737c49434bcd08e3e0814c8b1dbf15c586ae74f7929ba3148ddcee2c62c845  release/kernels/predmerge.oracle.jsonl
031d34947a6012caa5dd4fc6a7be18758fa47ce194d6a7a7496e0831f40373f3  release/kernels/predmerge.sv-hosted.log
ac6875f86683d31a8d20490df75eff67170198e5cd30b74ca001dee6bb898bf3  release/kernels/predspill.by_instr.json.gz
60e655147ce4f6eaf960d84d99e9377ebca2e26a508e4a7ab7a263cc71a85353  release/kernels/predspill.by_unit.json.gz
7c385a4beaae881b3f225c8564397cf7ffa0ce9a6f76e7db526e05518597e301  release/kernels/predspill.ccvtrace
67a09735d2d3341de2a1b0032c0c5d30349e38bc4d9595ac3c7868358bcbfdb7  release/kernels/predspill.log
b7c84c6478117ffa0f06da0e6ad1e4628e2683426a7911080810e78e06a5242e  release/kernels/predspill.oracle.jsonl
d59c739e70b168ae112df9d767238b74a77d3a7dc66f79c9aa8b82a578339fb5  release/kernels/predspill.sv-hosted.log
3d7166469446bdce659bf6fbf6f53af10a3a83e58c45baead971a6e3f9052860  release/kernels/predswap.by_instr.json.gz
a4528b228e9d6cddd2d070c7b893b95e94d848c29d49db56fc3fa23df005d7a7  release/kernels/predswap.by_unit.json.gz
1c6e4ccf2fdd48726b02ca1ede078b6c0cc705cc57b231bb54913935eae84748  release/kernels/predswap.ccvtrace
886a3021139144176557fc372d3287f9707b62f18a62de3dbc02b081504428ce  release/kernels/predswap.log
a6d4f7ed517553816d889c7c9eeb6bcfd1f6c973fbf682ecb69f3c2de619f7bb  release/kernels/predswap.oracle.jsonl
ee4826e74f8ce7c9be5404446cd3e6039fb0e3b2d325f9b02f8a922b2cf725a3  release/kernels/predswap.sv-hosted.log
a3d5301894080c1f75e1f179c0260cec45a94e16aeabc13345beef3a0624f6e4  release/kernels/privwin.by_instr.json.gz
85622a8749294503495cc8066f6ab88be99226fab23901b9879bf114bf4264d7  release/kernels/privwin.by_unit.json.gz
0e5a184a91c7cb75d2ccb15aa6639482cfa45cdd170edbaeac02ba568e3a80a0  release/kernels/privwin.ccvtrace
42fd8262ee50eadfea18d8add8570c8a694b69be9e3abe1c94cb8de6c13050b4  release/kernels/privwin.log
861f686fc4480363472908d679d8815e8c957d768e7ab32c826930527b0fb7a8  release/kernels/privwin.oracle.jsonl
279d2dfc2392c77c64b315a6ae9e56a13c344f56a56c386e7dbe6109ff47348f  release/kernels/privwin.sv-hosted.log
d6161ff7ced6d55966bd4dbf1033205fe7bc465a3f20aa772471a25c2f22c105  release/kernels/provswap.by_instr.json.gz
89d3065477c529b85b092af12f2a2d9a64b7769653341f29cfc6d3001a32f426  release/kernels/provswap.by_unit.json.gz
8e0f9cbbbef7338e78cbe7663c36776d47723c7298b6c0129f4b187df774b0ad  release/kernels/provswap.ccvtrace
911ac0cb48dabee2e48408a2e744f3cd0a5f1366879a95ca0f8368b7f080f03f  release/kernels/provswap.log
c9c32a793d54cc7401477f582487f7e8b345b2669a75337b8d6327120d98e5dc  release/kernels/provswap.oracle.jsonl
fff0b2ef803d7ac96c7cb0781f01bcda2bc22bb51b93124f8cd03c5b32628010  release/kernels/provswap.sv-hosted.log
3deec25603f4678ecd60db614c346c0962673ab15e8d542da773a8c9439f64b5  release/kernels/roconst.by_instr.json
2a50edcbd759185f72fc91862bb229331434c4521c249a516f376ff01cd05b97  release/kernels/roconst.by_unit.json
70c8714a871ccdbe32b451e084397362b6f285aaa37b7e1f3057d5f90dc725fa  release/kernels/roconst.ccvtrace
eb9ed3f3498a72dbce0287767d192fa90e177b792900cabd8f5ad09394f906db  release/kernels/roconst.log
8087c0671de620162881aecd38cd6114b78e7be6bd71201e3ec02c9a2e2e750e  release/kernels/roconst.oracle.jsonl
a1e12d1a358a0c2e34f707adc6a8bd3afacaca9263c72e9d0aa2e4ba94eed29e  release/kernels/roconst.sv-hosted.log
5455c96ec6019aeabc4b0e908502f85c22715b40bb112d54d730015142b437f4  release/kernels/rogated.by_instr.json
ac48446e6231aa36ec0c86f3e1da62c971deedf6d4cd7aad0d988a334e7c07a8  release/kernels/rogated.by_unit.json.gz
79677d54069f8da637fa2b969079bf339e73219ad3f8f414b3f2669765fb7196  release/kernels/rogated.ccvtrace
af1747c724f6daedcee8e44b309a394d8aaa68d2fc3cde03a431e16c99461829  release/kernels/rogated.log
7cd02bd4cceec5a044d6b4d6a80df1e68ed0ae71b0b2a953143636d5b809ea6c  release/kernels/rogated.oracle.jsonl
8decfacf8ffc7a1e042ba74e3444f3ff5dd02cd53c3436dc7097c60b21f988c3  release/kernels/rogated.sv-hosted.log
ebd9cfe42d183e54d65c853fd9ea35cc4254645085ccfcd3bd33aec592b8ad8a  release/kernels/rokill.by_instr.json.gz
191572087d2d349b31d3c4a35a8e34929d48963801beaa28c4d347bf9f811861  release/kernels/rokill.by_unit.json.gz
e7d52215b4f7a360d0cb9e3a54302a910394e58699360723c21cebcaefbcdc32  release/kernels/rokill.ccvtrace
3b511ba7a6aa9a955b81a78c22a7c0e54652f11cb5a4da9a6c3c241a4afc15a6  release/kernels/rokill.log
94efcef96af469a512d346ce61623980fe86383188eaebd55120f716db596f14  release/kernels/rokill.oracle.jsonl
917b1f196f86180f0adf784b7bbb8659e5457db8fc5f0211d2fcc0f55fbb105d  release/kernels/rokill.sv-hosted.log
3fcc245491973c3a5f2c2381fe40befa68cac75951bb61a37828ad002f5e5c3f  release/kernels/rolaunch.by_instr.json
c6e03215507cac2dc6fc62be8fe152a55cdc9d3d0ee6787002406efee4d8a4f2  release/kernels/rolaunch.by_unit.json
b4dd2dc854bda367aa808413c5b8fed0ca0854268c3716fff7cbe1ba3c1c0ddf  release/kernels/rolaunch.ccvtrace
0655cff219a34da53f691c62d67e0d5a1534c79d593d1a70ac106d8e09988c27  release/kernels/rolaunch.log
e7dad585c3e70615de04330fd03f4f282c29a005dc1732a35655fb261d51139e  release/kernels/rolaunch.oracle.jsonl
dee41a227dfe1afae7283f6fce964de94a318852fdc4153b74645b75d470d144  release/kernels/rolaunch.sv-hosted.log
3deec25603f4678ecd60db614c346c0962673ab15e8d542da773a8c9439f64b5  release/kernels/rolimit.by_instr.json
b8e5135eade5114a9ab5bb645d085744e17b63e5da86da36a10d912b2422e875  release/kernels/rolimit.by_unit.json
aca523a99aadf608795952b24add4be71849a9d8e1fe0f394bce73d168d5bd4d  release/kernels/rolimit.ccvtrace
77407a923cd14faf9efaa7fe990b2bd844872a3a1a25b654c62e84b32e8d6734  release/kernels/rolimit.log
1c5bc0cb8e8b2e69505fb5a551a16d5d10c56f232b88da7a27e336ad7d962de2  release/kernels/rolimit.oracle.jsonl
979248fb22d1a337db65a11a54c83752dece8ebeb65f341ecca31b378607a889  release/kernels/rolimit.sv-hosted.log
ddfee3d64dfc0c9bbed90d1dd6761f5b3ee1a3b98b315f8a935e4543b45d8505  release/kernels/roload.by_instr.json.gz
43c570c292e1b16b723c317048232f4b598fea4a57d9cc6b814aab569ae4de69  release/kernels/roload.by_unit.json.gz
960103e5efe7da29a60f461e6e5f1ca3ec6a8e47b573f50f1af14e025e33ffda  release/kernels/roload.ccvtrace
9602b313459715ce29b3e216b062add2645670f18db21b1c54690746e09324d8  release/kernels/roload.log
f7c1309cc9764769fb5803f6fd0f2f5e1eb418f2d23fbe5e17cf5f9106869fdf  release/kernels/roload.oracle.jsonl
d64f06ce478051db3f672d27f8ea5d376c95ef463064ec3ded3d45c15130fad5  release/kernels/roload.sv-hosted.log
36d94fc5c390ddd1917b9a843f187d8af800326398d486ed0fc1502674fdb2f4  release/kernels/rope.by_instr.json.gz
d477c2198f6de64e24e52939f5edc3d3d31a3ce14c0498ff8887ddb801ed00ad  release/kernels/rope.by_unit.json.gz
6f4b490b3c66592bbab396641f7cfb72f0baea9e5404554687117211f5767565  release/kernels/rope.ccvtrace
d61225b791d581568a356e74fc17470972be9e0c4656053b3a6f05454f2e52ec  release/kernels/rope.log
d55f9efae392dc8877c102c01c0810e7654b666b6ede386328108164c6cf88f3  release/kernels/rope.oracle.jsonl
8df22ff0a3424741ecbfed2cf30bedb189b0269a528698a79fdcab6189855c4a  release/kernels/rope.sv-hosted.log
b07c6057be33652bccd6b18d84bd47fffdd04771959d9d25641f5e1d0df4bd09  release/kernels/ropediv.by_instr.json.gz
a1b546fc0b09702d9c935c4aa49f4d91dce6c0c43b054f72ed463c4d636b6185  release/kernels/ropediv.by_unit.json.gz
bc190506cb91d3cd6343195c7e22289f9dedbbf7bdeb08407fadda4f3d3c82de  release/kernels/ropediv.ccvtrace
d2c5c8333210649ff8aaa0832540daa3efededa5802958424838d086ce576686  release/kernels/ropediv.log
10c0ec6ec18b7b44638c790033109198c079d07c1537bf193353ccedd00a920f  release/kernels/ropediv.oracle.jsonl
c107bc8e57237dc10a0d1057a59baf1eb8aa1cd5642e6af6562656fe20f60baa  release/kernels/ropediv.sv-hosted.log
cbc9a1026722b23624dc28cc50c6e4b28a79ceab875974c43d96d4d15786e772  release/kernels/sel.by_instr.json.gz
368a5e83ae1348c8038258980c354a17a5b45597c47ca7ac84ce23289fec7ed4  release/kernels/sel.by_unit.json.gz
513bff50a3b9d1f25156aee2aa31bd9f0aebdfded39e1b819d56577fc9ee8c68  release/kernels/sel.ccvtrace
2ffff753751a9f25a6d5f4ed8905ade2ac2da89b9c661e8c359cc64bc84af1b4  release/kernels/sel.log
87f6a81e8afa004c8039bf2f61c90176fcf29ab29bb17ac44aa016a5cc8438fe  release/kernels/sel.oracle.jsonl
18cdecce58c4f290b55efc87caae4cf4b51b0668c2faca536618e30fe783215c  release/kernels/sel.sv-hosted.log
58bcf0b4d56ba71def185c028a09ab46fd5f3c5a582b5ab40f322d7b9348a1d5  release/kernels/sized.by_instr.json.gz
02904c5ccc800a5a59b9ba553689a580ae03523939110104295b251fc5c9701f  release/kernels/sized.by_unit.json.gz
a42720ce662969b08724bafe0b0a56cf6723624aa37728b92f4e54868f9b33bb  release/kernels/sized.ccvtrace
8fc106e9a439e79c9dcfa643929482e04109c6a2d9e2530b65a6de918fb7780d  release/kernels/sized.log
36d903ba1618bd1faa437c9812a6ee6c0c966a63196c796267d74bf2695ebc3d  release/kernels/sized.oracle.jsonl
7a71852807f64ffda09ae80b1a96b2252ee0195f8b7a1dac504cd59f793b38b9  release/kernels/sized.sv-hosted.log
850ced6de6246dfb9acb3d0b07c83dc13161bcfe0294e14b085c8c96e13454e7  release/kernels/slotform.by_instr.json.gz
f44bab62c19f83145742e0e6aa3582d6dd580b7bd27f3f190b735b95963bf77c  release/kernels/slotform.by_unit.json.gz
203c4ca7b8ebb213247d154049a8ee95ef5073fe218313b20d4ec4f60f539c29  release/kernels/slotform.ccvtrace
2a8657d3bfff91176ebfc4fdd18aa6cc529d8fcb93ce6e0b10d1a8f3c0d4f629  release/kernels/slotform.log
8b61db7419b18cea8a646fb628218447e72e84a18a9891ffb73b441736138ab9  release/kernels/slotform.oracle.jsonl
085c89287dfdd790611bd897875fd333c8f763ed08d27b32bbe45058dff01367  release/kernels/slotform.sv-hosted.log
d50999f36ed4fe9f0b53aa750941a2a82d4d62865cc6955eec226291520d0397  release/kernels/spinwait.by_instr.json.gz
545c1aba20ff5c791b64cd41cb4775e66ded8b5163251e7f74d48d5939100bdf  release/kernels/spinwait.by_unit.json.gz
781c06446f2a1aa2e354348caa0f1906004de6dfc50e8337bcff4f76b4619bd1  release/kernels/spinwait.ccvtrace
47a11ecf899c2180ce2f36740bfd49afc8c54bf0737ca08d8b3caec678c950a7  release/kernels/spinwait.log
868920637236c878b33779bd450439466fc3626996a3164573dc11d437d5c709  release/kernels/spinwait.oracle.jsonl
e601557046d5f611cbd83102c3b85deb8e18733bf4a8fca2fd8bcbf901160b17  release/kernels/spinwait.sv-hosted.log
95d061b7d64e7d2cb6200fa9d22f983e7a5b14d8b09f6dce36984c0b16550d60  release/kernels/spmbank.by_instr.json.gz
0fac60cbe3ba65db51f91bb37bf9c34b7c61b4b6747d310afbf9d442dbd35b50  release/kernels/spmbank.by_unit.json.gz
39672a44aa542e5b9767367b822dc9521e3027107de485be10a88f60b434b80d  release/kernels/spmbank.ccvtrace
761bb1e0c7d7df7629144f445c4200b04adb61be28b6d7aa58e705ab8316ab8a  release/kernels/spmbank.log
3af490cc37d7a92dbe719b57de216b648536eb301ff9d13de9a39f50d150d725  release/kernels/spmbank.oracle.jsonl
1555e4887653c19fdffb8094993f6248c8e21d2c6dd89e5706b0279bf47450e0  release/kernels/spmbank.sv-hosted.log
6f7e379b1362f6a3770e0bdb7e983c5d584a9fe1a7eb6336086365ed5ceebd9f  release/kernels/srd.by_instr.json.gz
accd1f6c93c9680255ed7f3bd7a4acb56d4bed098de11570396ad96ecb81f359  release/kernels/srd.by_unit.json.gz
55571873a8edbf1842b885de5576dd16a2db3e96874611acf35ac479f17bb607  release/kernels/srd.ccvtrace
7deac1f8f9838907e6a6f3870753c7335c6201e78fb87421f03a6b74dad0e4fb  release/kernels/srd.log
b08eb5e3673cac7eebb8b72af5ed3783c8e70a9e96592e76bf3722551bc79473  release/kernels/srd.oracle.jsonl
a966a23989dab0b03c0b0f41bdd4082fefdd3b99083860f5efe26435cb68b6cd  release/kernels/srd.sv-hosted.log
4f658ba342e7281a55df9e9d25a36db5b7b65c156180d5ae74afebfa0079897e  release/kernels/stall.by_instr.json.gz
346450cd66bc7308d7068b0da79d4a321fe715353f1f65185343337063dcae44  release/kernels/stall.by_unit.json.gz
0b42dce13b3a8101a3aa6898554badcff147a1692c257b9898b40f6bac8611e1  release/kernels/stall.ccvtrace
6254c1624e80252aafdbe7e776953583ac0bad2195c5d615509e1edfddf36600  release/kernels/stall.log
500db2c482b07a0706583422cd68878301d0146c1f872ccc1f11bfdcf5c993ef  release/kernels/stall.oracle.jsonl
53a85f249b05e9a058f57b4f1c8acf91b40f79b26edcdda66a75fe0d471d1b38  release/kernels/stall.sv-hosted.log
32cd935090b36a00a8cfc003919cf5b00838c51edf6f305adf06a28cbd9504d4  release/kernels/swap.by_instr.json.gz
b48e541851e779131d6b175cd28c5b64f8f574aa50ea2c6f01c2ff5a78522085  release/kernels/swap.by_unit.json.gz
82916c2de51772fb0d96433fedfe26432355f19f5f8a17a673c92f2e9b474688  release/kernels/swap.ccvtrace
325dd5d3ae702a740cc903bf0589707a2835b952bf851fd01c01dfd74abea113  release/kernels/swap.log
3658a26316c1ff7bc1744304a42f736e930fcde2865c8913e6cc67a22ce96667  release/kernels/swap.oracle.jsonl
5d14254203d390d1ea429d78f4fb3b1f42a079a42adbd0860a79ff948573bb8c  release/kernels/swap.sv-hosted.log
3ad674bf936690d5c70bf9a3c58fe13a5a4105b5d6003742f7f0a312070beb69  release/kernels/transp4.by_instr.json.gz
6ed2c9028de1de4d0fba88f29ab1891cbf5aedd484caca67b8e66e80c84135fb  release/kernels/transp4.by_unit.json.gz
8795534f4782071b1a222e6e581e136fa80fc484eac7455a3fa815d28cd0fd18  release/kernels/transp4.ccvtrace
52a92d0532edea2b7182b3007c53d0ba464afac070fa4da4a1e401b82ac80777  release/kernels/transp4.log
06396ace3ac19677fd39c700e408606e5bdbacb24997d663bbe8872e63dd74fc  release/kernels/transp4.oracle.jsonl
8a6e263240357dca265f97d079e8761b20f2b5c747947dd8762768c964388929  release/kernels/transp4.sv-hosted.log
6b178bd0c73a086cff135a3b64fad4f0068b101d934f282923889c669ce2ef7d  release/kernels/unal.by_instr.json.gz
c5761e1b832f82be57f5d76a4c9f6f3337f9205d9ef684be5e6377ec875d462d  release/kernels/unal.by_unit.json.gz
7ceed4ab7208c7f77607806d0a2b1909e45ed6cf7b840306bf2052f85cb5cd6e  release/kernels/unal.ccvtrace
5e819dec65b50673ac6121fce6719df4d88be72143e4b9f144c9689b5e729f55  release/kernels/unal.log
c3d484bb160657a563df983d9a2532eac27f556636617960aa1e72183ac2b299  release/kernels/unal.oracle.jsonl
f67d2ac9e953588ccccace21c2d93c94c59cba29b183637b7d4d0c4733c74a4a  release/kernels/unal.sv-hosted.log
a48225d258e3c834ccf340085e453b80d2c0e778390e382c10ecf7294aa98115  release/kernels/vadd.by_instr.json.gz
4a1e9634f94f47c000afe5794364696b8e52f7ad98405bf48eb94a2b17af060f  release/kernels/vadd.by_unit.json.gz
fb9a7f3c5e4ceba14a306f5f846fdb22ff89bde2bb8890367a7d2f611a2e756d  release/kernels/vadd.ccvtrace
ad45d6e6d0e07bc73d3bb634c9d44b7b2de3af3d6c5aeedb6dca3f1866694ad2  release/kernels/vadd.log
0276b6d0611a4bbcdc004ab3987214aea138245bc7217504147331689a9c0880  release/kernels/vadd.oracle.jsonl
7e7101b1d2f21eadf0d42d823de509ac8ff33f974f0e0773c8db575d65c0a7d8  release/kernels/vadd.sv-hosted.log
f8ff10f03e9a5643309a0e50184090977c8ed272619efe017a322817184269eb  release/kernels/vadd4.by_instr.json.gz
dbd11593170293b34542a6e683adeff7077836f590d533257eb90ab420d6e30c  release/kernels/vadd4.by_unit.json.gz
4ee86c942053702a22735c21f983633fb5c9e4d02d4ad142e36704e4321de918  release/kernels/vadd4.ccvtrace
20e9ba1ae61b40c45ec387ec0f9964ba3bf8b03dc535ee570be9881cf621d6eb  release/kernels/vadd4.log
225aa18fc9f38aa9ad615aa11de254337d59fa705877553d873062c68366e0db  release/kernels/vadd4.oracle.jsonl
edfa017468946dc3bf0695ea1f1c0f1794daed5ca7b84ff757b145b97704f2f7  release/kernels/vadd4.sv-hosted.log
c6f8fc3d2bd42d5d072bc52c658803060b7130b764bd1c5099f440f15200f36d  release/kernels/vaddslow.by_instr.json.gz
396600752a668a38336926476fc42f1364730d0fd650f84f0a4168ab6f490b9c  release/kernels/vaddslow.by_unit.json.gz
952c2a4c044d60b860146c5346c612284450a1487e56afc0afe79419e848fee7  release/kernels/vaddslow.ccvtrace
5fb43ad1d163320b67b762ac98f83d174ac56c3f189e3593e7780bc84f061ba2  release/kernels/vaddslow.log
e9e6218e8b8450e9f9ff6b39d659c994a1e51c527a0c5bd10d18b5658ae0e344  release/kernels/vaddslow.oracle.jsonl
03639cfc7eb22f125dce6c504dd2ebc7acea503d303d0470f5639e97cade2426  release/kernels/vaddslow.sv-hosted.log
47ee2a33ecd8ae0943e0857d836a73d64703a580a534ba7feb3bd3eb7c7edb19  release/verify.log
1f3a2eff14dbda0754e19cbf72bc5003c950fc7d1691d527ce3a8d427fb583d7  release/wiring.txt
```
