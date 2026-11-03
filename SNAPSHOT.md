# Snapshot snapshot-2026-11-03-bbd23d3

**A generated, read-only snapshot. Do not edit or merge it.** The source
is `ti-ret` at `bbd23d3c0abe86f4c8345c130d0c3492a4d9a967`, and this branch is rebuilt from source by
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
| Source | `ti-ret` @ `bbd23d3c0abe86f4c8345c130d0c3492a4d9a967` |
| Built | 2026-11-03 (UTC) |
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
cb285590114a2cb4d791b7b5d7891bc210ea775137c498d95e7950fc45279d5a  release/kernels/addrhigh.by_instr.json.gz
bd681fd4ef6dee32ebd59ca77dbe48a09dc24f0021d0cfdbdce27a724aba0100  release/kernels/addrhigh.by_unit.json.gz
0661ac42f0a88fab0abe16dd618203786ac21b3032787954dd5c7236c598e446  release/kernels/addrhigh.ccvtrace
ff1a566fb8e68d676754999a9b737d08893c2e3e825bd77ebabd7cd069d50d18  release/kernels/addrhigh.log
569f2e22883fad5f0956c57ec734e6afbdd4b8a854e50277425172d6c0cbd766  release/kernels/addrhigh.oracle.jsonl
ecc1ff8cbc11300b12a6bb1de026a1feabcf0ade6a6969cc15118c8b114431b2  release/kernels/addrhigh.sv-hosted.log
89657fdaa19b5aed66f1bc00f2ca0c95986b020155e35077475dc28a643d98b0  release/kernels/addrlimit.by_instr.json
aec7c9bfed1544ae6953f0d4b9ac9d2735375c03ab4cca6fec0f952968707785  release/kernels/addrlimit.by_unit.json
393c0da8622a4a55b4a1c25a7ccfb9226947ca91903cff94db8d69e6c012c3f1  release/kernels/addrlimit.ccvtrace
3f89a5d2e6430edac81b5b5b379b38a8917d1f6b297be15bade8355f5e6b2134  release/kernels/addrlimit.log
bc660b0b40359a2c5a2478cb0eb4950b73fd22db50ea76b80052bc195a1920f4  release/kernels/addrlimit.oracle.jsonl
774c2c631dc983d260b9f0e8ac9279a06843b06f24f1766315a2084b12280498  release/kernels/addrlimit.sv-hosted.log
ea8c34b3706590b020eeb2c15130ef52a55bf630a8d18c03356cb840c2c44ad9  release/kernels/addrneg.by_instr.json
9d04e045b564b5eb98e168a2d717da9b30745b8e7f2c05c3b20e93e4d589ee2d  release/kernels/addrneg.by_unit.json
1856f3c088174d4d7fe55002b7a6bcf5788aea5a2a0e341aaca981ff22c6640f  release/kernels/addrneg.ccvtrace
7bb437c6e4c3deb1676dbcc5bc81fea0a87bd56f500bd98fdbeeb67e565062af  release/kernels/addrneg.log
16f5b0707ae44492a1efd67bb9dd38a7e79a7bbd354fa9207b9e7d150ff2f107  release/kernels/addrneg.oracle.jsonl
e3d552af3855bc2fc08fa9d70a7d358f454c55cb7bf655c3cf2a6c4fe56753cb  release/kernels/addrneg.sv-hosted.log
e5798f9f6360e4b5433b398151ec515e3d97d805a14eb50b82eaf91617c54af3  release/kernels/borrow.by_instr.json.gz
899c451bf333ae8e61b737476bb645a6b9c7c69b0c7fbcef479ab80d1d664014  release/kernels/borrow.by_unit.json.gz
53bf3d4b18a0414b481f5a80b52b155d57294c1387b373d1dbc26cf573d429a2  release/kernels/borrow.ccvtrace
e54c1cce9f8f2c8f6d7f701ea694634d992a92081ee73c0ae02deeb3be3fc549  release/kernels/borrow.log
4c565e1ce0b3baee36e158694b32c8defb5cd662b2f9af75cb5d8c26cb1168ed  release/kernels/borrow.oracle.jsonl
10ea2e8d03ed7d6a9ec7ca254199ffdb2b5ac092604dd355cc58acb152251031  release/kernels/borrow.sv-hosted.log
00ac21c8d55f97a1067a43bd177fb049a7a7b517a44b6f62cde2e5d31a5d33cb  release/kernels/brs.by_instr.json.gz
520b8f0729c67e9480ecd8a1be5f526dc794cdc233d0b5ab86e6a15a980c7910  release/kernels/brs.by_unit.json.gz
f20abf3edf59228a1f86d551933ac94ec8304d9e8d50a1654ea9f6481bcfd0d2  release/kernels/brs.ccvtrace
fcd91700239fdbd9dac9df127805106f37578b60b328c703bdbf84797f9d4eda  release/kernels/brs.log
e3c1cb3379580cf1aae44e8ddc8e846ef6fd661a573cfe0a8d4444b18a14dc56  release/kernels/brs.oracle.jsonl
9d2b816a791f7ae1df6aa4b1b39382ce59626aaf99691567482ccc603d915d2b  release/kernels/brs.sv-hosted.log
04e7a41d096966e47448b3a96d127b8bed050f435a7989893866a08b831c0e61  release/kernels/byp.by_instr.json.gz
56493ab57c6c5281e22ea88b23a2dea01d10a26bb2d1f25384fb2c9425b2f55e  release/kernels/byp.by_unit.json.gz
097c7e5692b7350d9087235b51ac02338448abefeb08a7d9d68e990adb1c69f8  release/kernels/byp.ccvtrace
89be1bd58b45079ce4e0e6a1d709319c7d3feebfcb5c45e188bae1388282002d  release/kernels/byp.log
5a03dfa4f3603fef49f1e3639e74e34152ca3ca5ef8e41eb959f8323040fa2d5  release/kernels/byp.oracle.jsonl
ee84c4ef509a55912b53fa6e83c6df9ba8c905bc7fc73ac33e360f475a2bb915  release/kernels/byp.sv-hosted.log
f7590722c3c0a12a5c163cfd5c1e15a70212072a0cf979320c9257e6c4004f63  release/kernels/callret.by_instr.json.gz
f1c509a0a0ef2785e807565d5b13400213c83e37c14e30b04f0cf8d22d5a1d48  release/kernels/callret.by_unit.json.gz
abf594e26b52c7ca113101c570e23da8ef87dfa7da51a43c43a3cc13687f4ca9  release/kernels/callret.ccvtrace
6c034e79ccbc4251f43b7e3a58602849671657f330fb19d54a3d562986b8e4fc  release/kernels/callret.log
9b1d1b50b527f732362f837250aa2f26dabf3e76e16a4794856ebd8f105635b8  release/kernels/callret.oracle.jsonl
5ba1d12a0cc04d5ec6e70c2ea90892c1a63d963d67616162ce8289d5f780bf6e  release/kernels/callret.sv-hosted.log
c50e7d51ed3f250da602ebfee1857691d462b76549c2f392fe0684053391b9ed  release/kernels/chains.by_instr.json.gz
7f02a17324140460147a4be17b13b91e6524effbc9e529b791a2b0d4c84ad3c0  release/kernels/chains.by_unit.json.gz
7b28b89e2edf15702229dbd78c0c7d20978e2e96e8c74a8b07beb1f2d2b04f94  release/kernels/chains.ccvtrace
9b998cf0ec83a7105cadaadf149b69ed4b3d32ef38d58ebeba51d579f9f65627  release/kernels/chains.log
26a4cc5c5524c7219d8706c2582c80357dea60be9d6ffdec99dac7d0365e2264  release/kernels/chains.oracle.jsonl
f6154f6ca1abd597be10b238f20c4e59889daf99d2d8e443f613e59f07898184  release/kernels/chains.sv-hosted.log
47d8700f1f52e00433b1e321cf1b1ec939c21ce6d6995f9aa6cd84aa3107cf71  release/kernels/div.by_instr.json.gz
e358fb1e17ae6f2c9d4a109b2f349b5aebc120e1ebd6a4a4119842566321509b  release/kernels/div.by_unit.json.gz
6b3666b2d6dd1c90998cd82657c4aaaedd9b4d07a43b0bd2f3c5eaaa56a22280  release/kernels/div.ccvtrace
3bba5084c1174f888e2d018438939b1c7ca5c5829b1e2e455f02d36809c046fe  release/kernels/div.log
71a567b85cf85622631490187563de9a5661099c78a590adff4ed0a0c3d24c16  release/kernels/div.oracle.jsonl
0dfb08fa2127061b9110782f60fb837a832aaef071443f0838814dabea697fe0  release/kernels/div.sv-hosted.log
a351ec68b6fb46bdb741f6941ffb042885a8425c037f10737779808c847f51f2  release/kernels/divchw.by_instr.json.gz
a6fa64612954c4b8eb30b6ddee434a17627e710204e71f9327474b0c509c04e6  release/kernels/divchw.by_unit.json.gz
ea4f828f5be13584bde5d90a520c8c0506aec576b9fca69bb81f896009624053  release/kernels/divchw.ccvtrace
5b92766896f7f7ab5e314fb4c836a98f3fede3ab882917d95eddde354efc82d0  release/kernels/divchw.log
58a541797f7a2df0a1c7528ae6a3edec212db90c7d3eb20656806f38b5c10b3d  release/kernels/divchw.oracle.jsonl
05f019bf2457ac64a73c9533332b1cea00a287ffed23f5a1cfeb8855f2470731  release/kernels/divchw.sv-hosted.log
8c3726e09a6b16b70ffac2ae3df9caaf2ff41945da82bfc1d3f1053ea602c14c  release/kernels/divtail.by_instr.json.gz
c01e4156c07f8bac0c84b6cec38ce5665570170212f583e8adc1928d17b8c78b  release/kernels/divtail.by_unit.json.gz
c52e1e64e26f2dbb09331d1d3715987248eacfc687cad4d27f4e86fb4a9f9268  release/kernels/divtail.ccvtrace
4d09d25ece97e63a8fbf9c5279fe701affe6bd7586cdc58db6fcb8a66ec6baa2  release/kernels/divtail.log
75f11a75c9b3b336e446140af4579f05b46c363a76b7aab3ec88154a07ba097d  release/kernels/divtail.oracle.jsonl
db3185a0bd44dc7d238b2d338efa42201f0d95ff1f13cf20612898b8ad81666f  release/kernels/divtail.sv-hosted.log
1a191965cb77c47f4a4fde3a47c6f29f91277769ed3d81aec53568a170e1fa39  release/kernels/divtail2.by_instr.json.gz
98b9ee82eb4609cf2057d99fba33344816ab3f9ac70c30afa01cb16444d4da3e  release/kernels/divtail2.by_unit.json.gz
07ea0d085a4dc9fe16bf3fdabfbcbb926cf20f1ba8949693cfa0c02e93a8a818  release/kernels/divtail2.ccvtrace
ba11514b5f430645b473ecb41e25e59aaf4040b00cbe1db91a0cf78532d1f628  release/kernels/divtail2.log
b2db6b05eb6cf4a0a7677e31d0c6c2952d5cab49d353f0bb1883fe0b2a20ed14  release/kernels/divtail2.oracle.jsonl
8f3c26da9640fa8eaa0a262f4ac3370c8ca1ec5e0cc16cd13c34d559efa15fd8  release/kernels/divtail2.sv-hosted.log
df4ac9c21ee9e911e2dcc9d4c2cf9ab5d017d6aa1f3999a16fde27d7234c730f  release/kernels/fence.by_instr.json
3b59505fb482c2d29df4703fdfc1ea6afa37dfcb9341a7155b60b648801c3714  release/kernels/fence.by_unit.json.gz
aba03523ed2138041961a6e7de252e88686ff4ee8fca27e3d426bd4dafedd7af  release/kernels/fence.ccvtrace
fe5a49e72d619b2a3a88aecffc29b9a6b6df02101e70e0eabdfbf59a3b6bdac2  release/kernels/fence.log
d1d40317f6cf5bfb430cda1f9c0ef676609e59cabe2a11623c42ffbeca93142b  release/kernels/fence.oracle.jsonl
367c5c89caa24b050d4d78dc2c990b392b776f4f748a05a837c8acb4eca60e10  release/kernels/fence.sv-hosted.log
d2ed20d0183674c3ac89b98804916c7cd7a724319ce4818846aa4a7bc31bad1d  release/kernels/gather.by_instr.json.gz
5fa921170dbacf1298152fc0507b6fad872c433938d9ddf42111147c7abdfdc8  release/kernels/gather.by_unit.json.gz
54ef7aaacace62b402a68ebad3887326470a82eae52f92b208ac7140d76b784b  release/kernels/gather.ccvtrace
d4f0fca4fcebaca14bb9b03951c63ac21b5a171854c8b4cda12cfb2b2d5badec  release/kernels/gather.log
0413e781d8d6ff578c64eb1f800b7931e66f676d5cdabb97b94a4033e6037662  release/kernels/gather.oracle.jsonl
5bf9e561fd59ab6219adde027e2f1cac9abf8df8989a32393aed9edfcaec3bd6  release/kernels/gather.sv-hosted.log
705bab0d3ad5c9ba197e6916e7bd17fd7ff4b21a705907a4cd29c25918118c3c  release/kernels/hit.by_instr.json.gz
2845557d1272accd0a67efd2cc2f61b9015695d6b5eab38684eaeab90dec1a37  release/kernels/hit.by_unit.json.gz
1ce490ae78b2216bef3b662a2af3599a189e7adbbbeee3c94437fe761a23b63f  release/kernels/hit.ccvtrace
75b66a4a4786b36fedeac055b493ee8b91234999eff47227edadb60f86253f12  release/kernels/hit.log
7ba9603e0088d9164de6528f16ef6a7fa9ce5821c8c12b52cbb3734e39b9fd52  release/kernels/hit.oracle.jsonl
4d616f3de9cbb98d6400912fdff050e96e66d45c1b9652df2925c74f12454fcf  release/kernels/hit.sv-hosted.log
8b5d2afa8dec0f7395456e07c95f27ca47350bcaa9d7e59b10dbe548bd458b3f  release/kernels/lanectx.by_instr.json.gz
d675176598e0cc17fd41bc13f96426e18937a2a9cff207e22379fcc6bf872736  release/kernels/lanectx.by_unit.json.gz
2119a6d9ac7beafe1a70d893ba377d3a3a40321c947a753c4e2d41a2092f20df  release/kernels/lanectx.ccvtrace
6c841c3febc6e69b975f5a8b2372b9387e9a25b0ba175778f395913a96d6e1de  release/kernels/lanectx.log
888551babf540db8e3025b82e65ca655013f93eba3c8a65689d069d52a7e6039  release/kernels/lanectx.oracle.jsonl
44edbdbb36b4a53a65816727f9404fb72d588636e7e8121bd9c504d4f9d22ded  release/kernels/lanectx.sv-hosted.log
9b2f849d23f69af26bedd412db25ad904b3541efc3ab44ba87118881c903a512  release/kernels/lanectx2.by_instr.json.gz
be4e55c6ecba6d9d6bd1065af251af84e5e037c691b544447d785a7f659f2075  release/kernels/lanectx2.by_unit.json.gz
394c48337bde53cdc91d6c2264f547b03abff4aca0718988d6e4a75b05d5d197  release/kernels/lanectx2.ccvtrace
644caa717cbc5ffc82ca7b7ac7b4c5cdf9ac030a8beb9e9aa08dbe16fc572592  release/kernels/lanectx2.log
45c13056dff5c73ed0c9ece56cc36f929bf335322193c7d5eb38710b1d1dfb02  release/kernels/lanectx2.oracle.jsonl
2c81860ffa2c6fcedd16b090673b928bcf9e886b501d5aa173668e030eafa698  release/kernels/lanectx2.sv-hosted.log
36e0181bcd38b771f23263b9b7fbd127119a1194cb31f57c6987359d5dd55100  release/kernels/late.by_instr.json.gz
43f170b082e01765a75ed175e272736902f4a4dc8136ce1f71e7f4f01d0f0fa0  release/kernels/late.by_unit.json.gz
115085fa283eaf72359f40ae50a5ed2e3feadc7e0eedf694a611494042846f35  release/kernels/late.ccvtrace
e78e405835d33dff5d2d9043380e1f64bc864f373a1a5cafef413a2d1783266f  release/kernels/late.log
86084f6bd747a2cf32acbc0ebd96ebd3e4ef2d8d9e21be49e3ae49290d7927f3  release/kernels/late.oracle.jsonl
146158b9cd4601f9c3d3c335d7e71d9ad5611af9c2f087aa4ff4cebf1d3675cf  release/kernels/late.sv-hosted.log
38f91ccd80d68836a7eb20337c3132deb542c569c9be56f75c4e7a225b62c0c2  release/kernels/ldpar.by_instr.json.gz
a3bc57bca5c0704e808e627d642df68df3a87ba1eee7f5ae8f363a3854b7aa32  release/kernels/ldpar.by_unit.json.gz
8595a89fd61743b14b53c46d151d81bfcd88d15c88695ca218fec5e2ad706746  release/kernels/ldpar.ccvtrace
3e6e4135b8389ed3768b461aae465ddbedd8efec05b2c372d64fe77096730d91  release/kernels/ldpar.log
8ac08538e9c807637babd61b31e340f7461878ada31f0c0b83cd66331cfaf486  release/kernels/ldpar.oracle.jsonl
3894a8fa14109411a41a94fe33137abbb9e3fb62028bdce04788af15857204ce  release/kernels/ldpar.sv-hosted.log
d865fe60928924d89b94500e2bf24c18ef71ca2e07229fa898409f88760c362b  release/kernels/lnorm1.by_instr.json.gz
cc9d31333e77dcc3596f0529b6b3dd83d0758af3c29d21048bc3ea0775b1bab3  release/kernels/lnorm1.by_unit.json.gz
019af8a07d22e9ba7212f0628cb10b7df12c8043c7a1bde63e7a7a7ff85b4e36  release/kernels/lnorm1.ccvtrace
1a647b0b0eadce600f80a1e446ec57e73e9ab22e1c33f97366f652d5b2466c5d  release/kernels/lnorm1.log
a8d85811af988a1b9fc00db1517300af3d93ec8e589e403d3b9113fa9e0ffc86  release/kernels/lnorm1.oracle.jsonl
24ac3a554f4f63cf7928ddefe7298cc02f8732cf38bf1edaf9dba48f8403f31d  release/kernels/lnorm1.sv-hosted.log
3d0d61181a3e5838b8857417367e2b12af0b3936cf6ac38e135389aac06cf0ee  release/kernels/localsp.by_instr.json.gz
b754c27150fe7f4c306ae6f4b21f997fea288d83634510e0d57e11d0d6ec00ed  release/kernels/localsp.by_unit.json.gz
38184fb5cab0c4b1266021ba6a922bc81e601fa502682b6e23a027fbe9c50759  release/kernels/localsp.ccvtrace
32d5a644998c97ae739956a7f5c456db798b0119c2aed0b07db325404212bb9e  release/kernels/localsp.log
55e3c9f36e7f7d38c0ddd38903aff4bb4509ae862015c592e6b937ea258042ca  release/kernels/localsp.oracle.jsonl
b9e0b90b908a9bc114ba421934438e1db92b2e5dde794d5e837535e51e2936d8  release/kernels/localsp.sv-hosted.log
e1f2bbdaca5bea232d4dd02dac2d59168f335056ef2c2eeefc45e37bd239795f  release/kernels/loop.by_instr.json.gz
cc05510c430dd3f64fb2094f29207858777cc870a3b5643bf48c6fe953a546e8  release/kernels/loop.by_unit.json.gz
ee07ec54794c9a840d72c53d9e330914250276d534e42fbcac0f37434ec2897d  release/kernels/loop.ccvtrace
185de009ef38ea64b165a6fc6c14e8c958f050a995517496202c83cde85e7f91  release/kernels/loop.log
03ce5920c06c93e93516d8e53c3f7169f14e3593de204eacceffc0b8a3e32016  release/kernels/loop.oracle.jsonl
93f373d4cac1463960a47771a175c53fb45be8c50300e26f23130f9805fb98a5  release/kernels/loop.sv-hosted.log
24f60b0969875b72f7cfa2bd761fd663a3232417a607c0a405d125fa1540158c  release/kernels/merge.by_instr.json.gz
6359dc9c22b7d21ee5be2a448fe3ef08425839b0b1b5504d4bff99e586e60ee4  release/kernels/merge.by_unit.json.gz
f03b5b8724e00e74c9cb603221ebcb45271d5787fa8675d733085d71f8b0e307  release/kernels/merge.ccvtrace
f8d17ca3da5849bde321420f242c0d38da7622e0fcdb8502c9700bcb49d3d6f3  release/kernels/merge.log
f96d28815f8756b1f5a45ded53e6170883d2dfa10f9eef0d14b8050b1318164a  release/kernels/merge.oracle.jsonl
c026bad84fd594540709ba0d776d5e4120053b7f95907c96884594365c660099  release/kernels/merge.sv-hosted.log
21867e3aec752a69dcb1d9a4e63f1d816c439f3abaff40eb339e7578177aa533  release/kernels/missrun.by_instr.json.gz
905d17e428973a1886a38451a78e5c7a84c71a20ceacbde86bc44f5d0280b725  release/kernels/missrun.by_unit.json.gz
1f25502382ab70df5f849c555ceae405bb1339d095932ce00f1d5448d573593c  release/kernels/missrun.ccvtrace
aeae866bbba55da369e0922633309fe44a0049fc68fb8041213521dceef32bef  release/kernels/missrun.log
531bdaf281e5590774bd2775427f25e4cc0419cf8e3d5b6999843ffe9ef87258  release/kernels/missrun.oracle.jsonl
1a18f8f68aa6b9cad78ed682d7cc2cdd704db4e0da13b8948c7effd755fe94bc  release/kernels/missrun.sv-hosted.log
e1629e6d909d71f7d263f3bc7a3a9307bbf34f1ffaee6b7b9e83610acc9704cb  release/kernels/mload.by_instr.json.gz
937431bf3bdf078903f6882a3589ced7bb2095ebcfef60757faa03ef1e895e9a  release/kernels/mload.by_unit.json.gz
9fec8b9122e6e1293201cbc39b39ffa20f615df0f3e5df5e8ca3160af98f735b  release/kernels/mload.ccvtrace
9099d27f3567aac469d58e2cda4614cf82704f44659db51941c64760f4f36f44  release/kernels/mload.log
8000e477b9a95dfb9f0af964e8346acb9d36f1358fd06ffc4ff7cf599d2b8868  release/kernels/mload.oracle.jsonl
7a742e75681111270e1707333755ca6941218b80391c5c3c3cd6dc160f2d892d  release/kernels/mload.sv-hosted.log
f464d6d2cf6bb1281e39884fe467d2b53cd5f88b1f3477c9319ef59204b24c4e  release/kernels/mlp.by_instr.json.gz
d45e8372fba5cf13345563e3f617f3d644249d9c1b4427fc6ba16c6134197c8c  release/kernels/mlp.by_unit.json.gz
efb84392c7d90847dd248fbce31bb95e9de05aed82f3f7defdd08c1806240d4c  release/kernels/mlp.ccvtrace
7cfb7d1c06bddcd1bebb1167bd6c6660d2ed3bf4d7cc23a01dc47f0d4c3caf79  release/kernels/mlp.log
138d282f88d56c8ad648a91af0a983254b55d9fa22942c00d47b327f516a6e44  release/kernels/mlp.oracle.jsonl
0d16a3fb7062543f79e088f8ea5169d937105c471c7b6817b8d72d0e93e07935  release/kernels/mlp.sv-hosted.log
95bfc6b962084064bff65554795dcdbb71201f8c8ff8699cd75befd34070a472  release/kernels/mwmiss.by_instr.json.gz
8b5c429b40fc3b086988b43ee4423e642aa28566cf64452f4c8db39fa3392e01  release/kernels/mwmiss.by_unit.json.gz
3db6d9460bb9660ee4c47f2bbdaff9c3d4eea5a50f1fcc1fbf91f26cbabf7c6d  release/kernels/mwmiss.ccvtrace
270151e00848ed34edc207bcfd2f1da5fa3e2895e9c126ed21283b647c4d66cd  release/kernels/mwmiss.log
8abe8e8997456a2a6711ee72da54d854b24e20abbdab28e4b7271c0d28418de8  release/kernels/mwmiss.oracle.jsonl
6aa534421d66940e1eb322b36cb1bdf2b10379987af5ec974acb7167c5f886d4  release/kernels/mwmiss.sv-hosted.log
536e1ff7345aa9e8185e2c0a774b120e04b9dbb40c9f7907fd0c4cecfdf66b7f  release/kernels/narrowadd.by_instr.json.gz
b957d84323fafc1c947451e803bd8403740ba90fb51b6aecd20fd5fae7963db3  release/kernels/narrowadd.by_unit.json.gz
0da3580e445e3dc3086036f036a2f12d1ceecb45e59e6f636a0fa3d822063028  release/kernels/narrowadd.ccvtrace
6a32a3576a92ed994a6cf77b0a337ba9b58b816b18b4782e203532d7c40d6145  release/kernels/narrowadd.log
40a2cf629853dd404bb06b4a07e35abde3d12efc13f26ffe28f923daf2994574  release/kernels/narrowadd.oracle.jsonl
7b1d6e13893e5a79a6a2f771894b843fb59aab40de5429cb2e3af51ea29258a0  release/kernels/narrowadd.sv-hosted.log
b4968b7974feadedc72a4392b392aefc8c118bd3922d73d592233a3d06191c3d  release/kernels/pguard.by_instr.json.gz
35e834b343e0aec5dfee6828c5312ece84f556819918cdb9c2985abe156bf907  release/kernels/pguard.by_unit.json.gz
d10835277946646e5c8525db1ab4eec371d368e8c7fd12edc30ec901d0d2f132  release/kernels/pguard.ccvtrace
e8f7bab52a4d41b10a8eeea5fbf91555a5ab551bba3432408e562a6808ea183a  release/kernels/pguard.log
690e56f1cb8d97cbf67124b7dff3ad0a90cb8981814cd1709cf0cd0e035b3bd9  release/kernels/pguard.oracle.jsonl
b92f52f94f149e6d814d7e7f6436c82090b09c3621084eb69536253a97469c8c  release/kernels/pguard.sv-hosted.log
8e64ac0c73e1e24269e099b13c9bd6fb6c0ceda4713a711abfe6dd65eb7256bb  release/kernels/plog.by_instr.json.gz
3a22d1a6ecc3d2a60aa3a1307e849a9cc2e63fb2bad2f2bc064257ed1c43cdae  release/kernels/plog.by_unit.json.gz
0663b3fde6247c0c7b78b17b23d9227b12815f9f48891e5bca5f06a7ad901776  release/kernels/plog.ccvtrace
cde64746d910ab39cec1ff6b736218cd460694a8624fdc8a03b8b54f478d279b  release/kernels/plog.log
c230f13f2e1082b306a9c5ab7809ff36cf5c1b2e47dca6b7a71f741524d403f5  release/kernels/plog.oracle.jsonl
9215468c83bed66ed3913bfc16606b34c9955255ee40b07d77add6220077eb0e  release/kernels/plog.sv-hosted.log
555fc4488e2b8e6986acd206888207d199823ebbffa58f1b0696e577c25b1353  release/kernels/predlane.by_instr.json.gz
ae05b17cbc6fed495c9b76b0689ea143bf56d0ffd2e718241f8807b69b2af0a6  release/kernels/predlane.by_unit.json.gz
8ec769e2d14b44c63babe1399aa735b7687d413ecefcb80a0452e7670c3704d0  release/kernels/predlane.ccvtrace
1cb8ec30517a04f5d717d8797ce9ce1dd1c92580d1f87801eab0d037f9961614  release/kernels/predlane.log
c45f4177b9e84fc8a6e36b13534a0c7636eb30a3f8531847100ce5e23bf404b1  release/kernels/predlane.oracle.jsonl
24c621c2ed6bcd94948cbe75e8e297674aebdac3ca8cb5662a6396596fc52482  release/kernels/predlane.sv-hosted.log
9ee440a3e8a5105d584737e5c4c446f59e8adcef419f26cbeab72e79149a3cf6  release/kernels/predmerge.by_instr.json.gz
63258070a196ebc34495d5662dcc0ad2482a9c6ba8c3410fb34befbdcab6a07b  release/kernels/predmerge.by_unit.json.gz
8e78231146cb13ab0fdb29f26b40dcab601f7b31a382ec2033ff796481c4dfac  release/kernels/predmerge.ccvtrace
ac6873d8042472952f98f914b7ad753ef71e651f9a1ac344ed8c66a8e22acfc9  release/kernels/predmerge.log
6c737c49434bcd08e3e0814c8b1dbf15c586ae74f7929ba3148ddcee2c62c845  release/kernels/predmerge.oracle.jsonl
64f366a007b88ab1f0fe79c9515c99fb46c971d86355f6890140ba9f3ae95e5d  release/kernels/predmerge.sv-hosted.log
7c1dd84ddcd4f7b35c6e8d790617261ee1e682b34d007661db28cba6854a912b  release/kernels/predspill.by_instr.json.gz
c9382fd11b21b649c6271177d0856c9fd1e2a187b12bfc72efce4064d3fb838b  release/kernels/predspill.by_unit.json.gz
9f371fa333bcf505ea9cc2ec86e551dc733bef9936ef4fab6ae6876d40451011  release/kernels/predspill.ccvtrace
67a09735d2d3341de2a1b0032c0c5d30349e38bc4d9595ac3c7868358bcbfdb7  release/kernels/predspill.log
b7c84c6478117ffa0f06da0e6ad1e4628e2683426a7911080810e78e06a5242e  release/kernels/predspill.oracle.jsonl
8428800859cc26ea38b11f43bd3a1dcb1b412cf92e14523e84ab92a16bdc172b  release/kernels/predspill.sv-hosted.log
25c33362a071023e51a7286b887c02e3bbc52070d0aa5871990b67e93c3aeed8  release/kernels/predswap.by_instr.json.gz
3d95f395810b02b5d3b363b14f936039c6565fd666785dd24b04602562d69f06  release/kernels/predswap.by_unit.json.gz
988f5a4b9a8b88a35190baad05027e1f08f158a0b709112528172f222d83af9a  release/kernels/predswap.ccvtrace
886a3021139144176557fc372d3287f9707b62f18a62de3dbc02b081504428ce  release/kernels/predswap.log
a6d4f7ed517553816d889c7c9eeb6bcfd1f6c973fbf682ecb69f3c2de619f7bb  release/kernels/predswap.oracle.jsonl
43726ee174d7d2a6ce2ebbe0ac593e5c3fc21d09a52c97c071787601f2ccc961  release/kernels/predswap.sv-hosted.log
51edb2e48fbe13c0aec1a365af1c8d0e8adc09a21c3d1249e8a41efe61c3826d  release/kernels/privwin.by_instr.json.gz
0a0c5afbfa518294bb9202fa87156e9eac9a1c9180162ba9c1bf55761847bd9b  release/kernels/privwin.by_unit.json.gz
3dcf0f452ec3b2ad6799a5e1870997019801731102ecb60a9341b0bcbbdb4ade  release/kernels/privwin.ccvtrace
42fd8262ee50eadfea18d8add8570c8a694b69be9e3abe1c94cb8de6c13050b4  release/kernels/privwin.log
861f686fc4480363472908d679d8815e8c957d768e7ab32c826930527b0fb7a8  release/kernels/privwin.oracle.jsonl
6b5133095087f52ca669128cfa055cee8df938b156b71b45362fa3fc55fcae6e  release/kernels/privwin.sv-hosted.log
c30f1f63b17c668b9a026bc19a62e4e9172ee4a8a8a5f514f172f897ae1be737  release/kernels/provswap.by_instr.json.gz
e3a0a2c93797d27e15fa6cd76b585bb921f30e5112cd06f3130648fd0f08a932  release/kernels/provswap.by_unit.json.gz
92b0741cdaad6c91b35c6c14b37c96eccfa1dce4f3761cddd499c258d503ed70  release/kernels/provswap.ccvtrace
911ac0cb48dabee2e48408a2e744f3cd0a5f1366879a95ca0f8368b7f080f03f  release/kernels/provswap.log
c9c32a793d54cc7401477f582487f7e8b345b2669a75337b8d6327120d98e5dc  release/kernels/provswap.oracle.jsonl
5e4ae693503804b951a56883cf0c27493bea241886314b6e636ae4250533e56b  release/kernels/provswap.sv-hosted.log
3deec25603f4678ecd60db614c346c0962673ab15e8d542da773a8c9439f64b5  release/kernels/roconst.by_instr.json
2a50edcbd759185f72fc91862bb229331434c4521c249a516f376ff01cd05b97  release/kernels/roconst.by_unit.json
70c8714a871ccdbe32b451e084397362b6f285aaa37b7e1f3057d5f90dc725fa  release/kernels/roconst.ccvtrace
eb9ed3f3498a72dbce0287767d192fa90e177b792900cabd8f5ad09394f906db  release/kernels/roconst.log
8087c0671de620162881aecd38cd6114b78e7be6bd71201e3ec02c9a2e2e750e  release/kernels/roconst.oracle.jsonl
ca404cb053d00d9a20c0e3050b95aa449d8cc2ad981ae831d40718df71026f4f  release/kernels/roconst.sv-hosted.log
56a1d9013480dd49d461e1d7eed5cd42d906f5b4c7f657d138058e0b72085132  release/kernels/rogated.by_instr.json
e11aa515f280a73572e2bc57e83cd35daec70f0d118ac8258eb0d1c8de4e7326  release/kernels/rogated.by_unit.json.gz
f90fd058de33e49e135c8e983485a2a15c6e14130c3f06cd3c5da95a51871c0d  release/kernels/rogated.ccvtrace
af1747c724f6daedcee8e44b309a394d8aaa68d2fc3cde03a431e16c99461829  release/kernels/rogated.log
7cd02bd4cceec5a044d6b4d6a80df1e68ed0ae71b0b2a953143636d5b809ea6c  release/kernels/rogated.oracle.jsonl
464c4b25949b899ffc1ee7d6d1642301135ffb65c07a4af7253a4a10bab0096d  release/kernels/rogated.sv-hosted.log
c320bd614bd5e9f8f6217c9b28c5e9d474f8aaacb2e49cf233dc63cd594f538d  release/kernels/rokill.by_instr.json.gz
c8b939f26de6a6b642699a3f23db0abcdbc958acc3bcfbc91e5ef70243294fac  release/kernels/rokill.by_unit.json.gz
633c443593e1971bb2142a24e698ee7af986ab12b3e6688430a8995be0df3a4b  release/kernels/rokill.ccvtrace
3b511ba7a6aa9a955b81a78c22a7c0e54652f11cb5a4da9a6c3c241a4afc15a6  release/kernels/rokill.log
94efcef96af469a512d346ce61623980fe86383188eaebd55120f716db596f14  release/kernels/rokill.oracle.jsonl
b1473685236daf1b0428b5be41638fbbcc52d44ba4451e829161c7acdb8ae091  release/kernels/rokill.sv-hosted.log
3fcc245491973c3a5f2c2381fe40befa68cac75951bb61a37828ad002f5e5c3f  release/kernels/rolaunch.by_instr.json
c6e03215507cac2dc6fc62be8fe152a55cdc9d3d0ee6787002406efee4d8a4f2  release/kernels/rolaunch.by_unit.json
b4dd2dc854bda367aa808413c5b8fed0ca0854268c3716fff7cbe1ba3c1c0ddf  release/kernels/rolaunch.ccvtrace
0655cff219a34da53f691c62d67e0d5a1534c79d593d1a70ac106d8e09988c27  release/kernels/rolaunch.log
e7dad585c3e70615de04330fd03f4f282c29a005dc1732a35655fb261d51139e  release/kernels/rolaunch.oracle.jsonl
b48d635a3788b958fdbacdf0a50eaa16e1779d0d8493474a704072b61179840b  release/kernels/rolaunch.sv-hosted.log
3deec25603f4678ecd60db614c346c0962673ab15e8d542da773a8c9439f64b5  release/kernels/rolimit.by_instr.json
b8e5135eade5114a9ab5bb645d085744e17b63e5da86da36a10d912b2422e875  release/kernels/rolimit.by_unit.json
aca523a99aadf608795952b24add4be71849a9d8e1fe0f394bce73d168d5bd4d  release/kernels/rolimit.ccvtrace
77407a923cd14faf9efaa7fe990b2bd844872a3a1a25b654c62e84b32e8d6734  release/kernels/rolimit.log
1c5bc0cb8e8b2e69505fb5a551a16d5d10c56f232b88da7a27e336ad7d962de2  release/kernels/rolimit.oracle.jsonl
e0c11750ce2353a3d4848eec38d55d2e4fd15192636b330c8fc608a744f7d105  release/kernels/rolimit.sv-hosted.log
fa9c1a0b252e2b0ca6c70f3e2c4394b521bb6fa3d9d211212180b327140116e2  release/kernels/roload.by_instr.json.gz
dd5222cf5070b3de84bd98d2f8d50e5c62eb2fbb72c4ef48b73e796269ad24d3  release/kernels/roload.by_unit.json.gz
960103e5efe7da29a60f461e6e5f1ca3ec6a8e47b573f50f1af14e025e33ffda  release/kernels/roload.ccvtrace
9602b313459715ce29b3e216b062add2645670f18db21b1c54690746e09324d8  release/kernels/roload.log
f7c1309cc9764769fb5803f6fd0f2f5e1eb418f2d23fbe5e17cf5f9106869fdf  release/kernels/roload.oracle.jsonl
242dbaf3df2d322826053ae1e86f17c39c7a71297524a7e6b16f2a19270bfef5  release/kernels/roload.sv-hosted.log
c0b9a755dd090d4fc7374401db6517ad896c773f353d0b06a6d7daf50d49727a  release/kernels/rope.by_instr.json.gz
ba12cdb5b6cfe9b9a9c13553fce8866587d2d025cbb19ab2e1f7acc779773a1e  release/kernels/rope.by_unit.json.gz
5b88619693e1b5fe8046438fe6bd5c5a31e78a2da419ee1a9bef2a15f548ddec  release/kernels/rope.ccvtrace
d61225b791d581568a356e74fc17470972be9e0c4656053b3a6f05454f2e52ec  release/kernels/rope.log
d55f9efae392dc8877c102c01c0810e7654b666b6ede386328108164c6cf88f3  release/kernels/rope.oracle.jsonl
fe63fd6ff9ee3525a6d2ad15c406ade268a3a99108f086add297ab1800bc52c4  release/kernels/rope.sv-hosted.log
90d459986590d870fe1bf47432783eb1af5cb69aff15a5a6d4bf0a4340cc32ff  release/kernels/ropediv.by_instr.json.gz
aadaf47de4ad3ac80a7d79379de4b62a4098fe52697e74a3151d9a78b0b84004  release/kernels/ropediv.by_unit.json.gz
6045202e0daec9fa1788442b62ea687f073701171d39d5da1fc84a14f42f0698  release/kernels/ropediv.ccvtrace
d2c5c8333210649ff8aaa0832540daa3efededa5802958424838d086ce576686  release/kernels/ropediv.log
10c0ec6ec18b7b44638c790033109198c079d07c1537bf193353ccedd00a920f  release/kernels/ropediv.oracle.jsonl
9b092761f54261eb0e3237cbed3a19903e844c2816ae201e13eb66a2bcf91f96  release/kernels/ropediv.sv-hosted.log
556a4760b78d132009346322ebf91ceebb3ad757940ccaad4d44e2a5d4567665  release/kernels/sel.by_instr.json.gz
82c4cbb633305cabe700851617bf0405a47e4f8d44bb8120d55def7ce3fa49c5  release/kernels/sel.by_unit.json.gz
513bff50a3b9d1f25156aee2aa31bd9f0aebdfded39e1b819d56577fc9ee8c68  release/kernels/sel.ccvtrace
2ffff753751a9f25a6d5f4ed8905ade2ac2da89b9c661e8c359cc64bc84af1b4  release/kernels/sel.log
87f6a81e8afa004c8039bf2f61c90176fcf29ab29bb17ac44aa016a5cc8438fe  release/kernels/sel.oracle.jsonl
d55f940f4fc793b818951aca36b6d93f009239bbbd60bbaca9bb27f51b9b5721  release/kernels/sel.sv-hosted.log
7f6787e9e35a92f7a03c1e432f728240318caaa6ac47ffcf720fbaa40f517b48  release/kernels/sized.by_instr.json.gz
aa1944ef2b8b9b97da0b6f28549680a9a17e30f11cb8ff5218b2d54f1c73f081  release/kernels/sized.by_unit.json.gz
a42720ce662969b08724bafe0b0a56cf6723624aa37728b92f4e54868f9b33bb  release/kernels/sized.ccvtrace
8fc106e9a439e79c9dcfa643929482e04109c6a2d9e2530b65a6de918fb7780d  release/kernels/sized.log
36d903ba1618bd1faa437c9812a6ee6c0c966a63196c796267d74bf2695ebc3d  release/kernels/sized.oracle.jsonl
228190e66b1eeeb3a33b6eaeebd843580faa1bf802da0e4d643ef76bb0be22f2  release/kernels/sized.sv-hosted.log
264909ccd4461ff78ba77cbd9dc32c2fe16071411c35ee61e37754f0d3123427  release/kernels/slotform.by_instr.json.gz
e21fd309e7eed348040b70b27d14bf7a4cdce4ca146c30256eba6327de7a9186  release/kernels/slotform.by_unit.json.gz
203c4ca7b8ebb213247d154049a8ee95ef5073fe218313b20d4ec4f60f539c29  release/kernels/slotform.ccvtrace
2a8657d3bfff91176ebfc4fdd18aa6cc529d8fcb93ce6e0b10d1a8f3c0d4f629  release/kernels/slotform.log
8b61db7419b18cea8a646fb628218447e72e84a18a9891ffb73b441736138ab9  release/kernels/slotform.oracle.jsonl
ad620634e738b4533c2563e08acb1b0d8cef89edc95e78dc37861f887fd6631c  release/kernels/slotform.sv-hosted.log
79997a88226a68d4d8ef8b9ebd09e42d569c4ab55940cc62ac4cde35b8a1e32d  release/kernels/spinwait.by_instr.json.gz
b37a1854ca76854135fe64952edae41c46966692696124a9af8a64d5d4a51df3  release/kernels/spinwait.by_unit.json.gz
f25715d6119729a6e098f2fe794cd6ae9df44be652ae647465f69b6f26cd4621  release/kernels/spinwait.ccvtrace
47a11ecf899c2180ce2f36740bfd49afc8c54bf0737ca08d8b3caec678c950a7  release/kernels/spinwait.log
868920637236c878b33779bd450439466fc3626996a3164573dc11d437d5c709  release/kernels/spinwait.oracle.jsonl
13b51039db96ee63d4dd993db536c4936d00d2187624be5b5b57d996d34247ea  release/kernels/spinwait.sv-hosted.log
ace28555697772ddcab98a18e7887d4fb6769a5e0c489f54f72d20a024bc9b47  release/kernels/spmbank.by_instr.json.gz
5d8f66c62fe0b4eb68cfc1b601e794e81bf42daf7743936a605a473a83d8bbce  release/kernels/spmbank.by_unit.json.gz
39672a44aa542e5b9767367b822dc9521e3027107de485be10a88f60b434b80d  release/kernels/spmbank.ccvtrace
761bb1e0c7d7df7629144f445c4200b04adb61be28b6d7aa58e705ab8316ab8a  release/kernels/spmbank.log
3af490cc37d7a92dbe719b57de216b648536eb301ff9d13de9a39f50d150d725  release/kernels/spmbank.oracle.jsonl
537613dd66f07360244f229bd2e9181707f36eb1db849a2f7966eab6ea207a03  release/kernels/spmbank.sv-hosted.log
2511570ebe0b05e9937f03eedc229cd20a7e8262d1014669445057c5c1492837  release/kernels/srd.by_instr.json.gz
6a1e302e2994aa8a3957c04032fed0e15c552e771d9572dbc10b6615a9635042  release/kernels/srd.by_unit.json.gz
55571873a8edbf1842b885de5576dd16a2db3e96874611acf35ac479f17bb607  release/kernels/srd.ccvtrace
7deac1f8f9838907e6a6f3870753c7335c6201e78fb87421f03a6b74dad0e4fb  release/kernels/srd.log
b08eb5e3673cac7eebb8b72af5ed3783c8e70a9e96592e76bf3722551bc79473  release/kernels/srd.oracle.jsonl
2d8e42964e72c0ceb836d20043ac0dd4a395a138b72ccc91f9ff76dd0a45cab6  release/kernels/srd.sv-hosted.log
b20b18257c26108aa06fc941babb4d1c36218d012ebc8a8928290803c9cc58ea  release/kernels/stall.by_instr.json.gz
1446ad41f354e9500d88f57088306fb57a7781c2088b810f1631c06dc3e1fda7  release/kernels/stall.by_unit.json.gz
0b42dce13b3a8101a3aa6898554badcff147a1692c257b9898b40f6bac8611e1  release/kernels/stall.ccvtrace
6254c1624e80252aafdbe7e776953583ac0bad2195c5d615509e1edfddf36600  release/kernels/stall.log
500db2c482b07a0706583422cd68878301d0146c1f872ccc1f11bfdcf5c993ef  release/kernels/stall.oracle.jsonl
c73960f5c580687c329d70fc0a7e47be7b7f3013e60d60ae89220c89f8c6f090  release/kernels/stall.sv-hosted.log
4a8eb61626245c20ee508db85699d452e97515ff050f5c63bda62be3a1605ac4  release/kernels/swap.by_instr.json.gz
c938a3ef67279ca8c45bb2e5678f4a10c79ec019695b07d9937750e9131498d8  release/kernels/swap.by_unit.json.gz
82916c2de51772fb0d96433fedfe26432355f19f5f8a17a673c92f2e9b474688  release/kernels/swap.ccvtrace
325dd5d3ae702a740cc903bf0589707a2835b952bf851fd01c01dfd74abea113  release/kernels/swap.log
3658a26316c1ff7bc1744304a42f736e930fcde2865c8913e6cc67a22ce96667  release/kernels/swap.oracle.jsonl
e99ad7ab763807c7b04b280644268fe2f77b4644b3c23742b45d209b4f7d6c0e  release/kernels/swap.sv-hosted.log
a388014bde4d097b83abe5c8cd1460f216b11101ddb7eab4a4f9cfe95cbda720  release/kernels/transp4.by_instr.json.gz
7eff1aecb3f0db41a0e712761c6b9c48eaad5896a06aab87506af70d19bcb2f8  release/kernels/transp4.by_unit.json.gz
53590f542ba44ea6dc9c94fbecd2fe31a3ae60149434bbe2bb58e0bdbe1d80be  release/kernels/transp4.ccvtrace
52a92d0532edea2b7182b3007c53d0ba464afac070fa4da4a1e401b82ac80777  release/kernels/transp4.log
06396ace3ac19677fd39c700e408606e5bdbacb24997d663bbe8872e63dd74fc  release/kernels/transp4.oracle.jsonl
1ceb82b70a6d12efd55dc1245366804adb09b6428bdda885da4a288e2d9673aa  release/kernels/transp4.sv-hosted.log
08ab72c6a90a04e2221958a054d5cf0e5469eee32c2332466a90fd8667886f25  release/kernels/unal.by_instr.json.gz
7800e8c52d60d26d95eb6a226ba76e6e8a4a14f57c94c1c856f862012b094f1e  release/kernels/unal.by_unit.json.gz
7ceed4ab7208c7f77607806d0a2b1909e45ed6cf7b840306bf2052f85cb5cd6e  release/kernels/unal.ccvtrace
5e819dec65b50673ac6121fce6719df4d88be72143e4b9f144c9689b5e729f55  release/kernels/unal.log
c3d484bb160657a563df983d9a2532eac27f556636617960aa1e72183ac2b299  release/kernels/unal.oracle.jsonl
a1177cc1a8d9146a46b597f9726e9112d63bcb741178759c18476823751a1343  release/kernels/unal.sv-hosted.log
3f17b2e78c5c279fb5b172d8e5cdd3f18aa30675c374ac09c2ce24fb9fda804b  release/kernels/vadd.by_instr.json.gz
b156f297e99becb096383a3efdb1adcbcab3254bd82ddb22b2fc5ebc3887ced1  release/kernels/vadd.by_unit.json.gz
b467c16235a8a0e24f05e4b4f5e91b04db89f9e360b2d8d88f3a810baf69665c  release/kernels/vadd.ccvtrace
ad45d6e6d0e07bc73d3bb634c9d44b7b2de3af3d6c5aeedb6dca3f1866694ad2  release/kernels/vadd.log
0276b6d0611a4bbcdc004ab3987214aea138245bc7217504147331689a9c0880  release/kernels/vadd.oracle.jsonl
f91bcbad09e2b29521ed3bad35d6e420c67965cb4b727ba1fd54ec4148db9668  release/kernels/vadd.sv-hosted.log
1e5be6a37db6997a2fbefdde9ed37fb095c9bcbefb0e49b61b7cf1d1c02c30e2  release/kernels/vadd4.by_instr.json.gz
e56dd1e134fb97a277613d08157666ea055081ac82f6e335269f9cdf62a28d42  release/kernels/vadd4.by_unit.json.gz
2a33f945ca94e70fb777a477eb459771efa459a1d0741f96804a6e6b4c6a0893  release/kernels/vadd4.ccvtrace
20e9ba1ae61b40c45ec387ec0f9964ba3bf8b03dc535ee570be9881cf621d6eb  release/kernels/vadd4.log
225aa18fc9f38aa9ad615aa11de254337d59fa705877553d873062c68366e0db  release/kernels/vadd4.oracle.jsonl
d4d20021729ae3c181882eed14167ae8b946276c43eead7372282de05010b2a1  release/kernels/vadd4.sv-hosted.log
675ce148fe2559e2cded53f14c53142ba5c6d079b39f0e999457ff3d1c8c22e9  release/kernels/vaddslow.by_instr.json.gz
f0360ebd0297206aa157468f1442828b986e0b014900d41b98643d2729c75499  release/kernels/vaddslow.by_unit.json.gz
461404eda15bc435b700eb5c8b52f290bcf08cb999e5752cdf7f89fc9b66e690  release/kernels/vaddslow.ccvtrace
5fb43ad1d163320b67b762ac98f83d174ac56c3f189e3593e7780bc84f061ba2  release/kernels/vaddslow.log
e9e6218e8b8450e9f9ff6b39d659c994a1e51c527a0c5bd10d18b5658ae0e344  release/kernels/vaddslow.oracle.jsonl
40bf4a20b73a818ded5dfe1465ea7a65041c5a800ba73fcc3665ac56daeb3fb8  release/kernels/vaddslow.sv-hosted.log
328618cb8ad0f6f0bfce3c0f8e6760b7f404b63b5b1fa71a8078c8f41ab6bb0a  release/verify.log
1f3a2eff14dbda0754e19cbf72bc5003c950fc7d1691d527ce3a8d427fb583d7  release/wiring.txt
```
