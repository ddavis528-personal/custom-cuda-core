# Snapshot snapshot-2026-11-04-36e2049

**A generated, read-only snapshot. Do not edit or merge it.** The source
is `ti-ret` at `36e204928fe3290d17502bdd145bc31ef9d1ee1c`, and this branch is rebuilt from source by
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
| Source | `ti-ret` @ `36e204928fe3290d17502bdd145bc31ef9d1ee1c` |
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
557772b8a47f5e8f8abf1f2ab55a27feb9aa37ef262422b970a822803c5ec013  release/kernels/addrhigh.by_instr.json.gz
82e355ac1e2e52b7214cc881890e810b8873a7b482abddcf8e231c5d84a6a9ab  release/kernels/addrhigh.by_unit.json.gz
0661ac42f0a88fab0abe16dd618203786ac21b3032787954dd5c7236c598e446  release/kernels/addrhigh.ccvtrace
ff1a566fb8e68d676754999a9b737d08893c2e3e825bd77ebabd7cd069d50d18  release/kernels/addrhigh.log
569f2e22883fad5f0956c57ec734e6afbdd4b8a854e50277425172d6c0cbd766  release/kernels/addrhigh.oracle.jsonl
a4e8c7dc55b3d62ccfa9b58d30817e86d40a4fb3c8b4cba9d8bdcbda0b420345  release/kernels/addrhigh.sv-hosted.log
89657fdaa19b5aed66f1bc00f2ca0c95986b020155e35077475dc28a643d98b0  release/kernels/addrlimit.by_instr.json
aec7c9bfed1544ae6953f0d4b9ac9d2735375c03ab4cca6fec0f952968707785  release/kernels/addrlimit.by_unit.json
393c0da8622a4a55b4a1c25a7ccfb9226947ca91903cff94db8d69e6c012c3f1  release/kernels/addrlimit.ccvtrace
3f89a5d2e6430edac81b5b5b379b38a8917d1f6b297be15bade8355f5e6b2134  release/kernels/addrlimit.log
bc660b0b40359a2c5a2478cb0eb4950b73fd22db50ea76b80052bc195a1920f4  release/kernels/addrlimit.oracle.jsonl
5871dd4fdc824f1124ea5b8092e3d036fe78e624122f532c51e585a2f5d8cd2e  release/kernels/addrlimit.sv-hosted.log
ea8c34b3706590b020eeb2c15130ef52a55bf630a8d18c03356cb840c2c44ad9  release/kernels/addrneg.by_instr.json
9d04e045b564b5eb98e168a2d717da9b30745b8e7f2c05c3b20e93e4d589ee2d  release/kernels/addrneg.by_unit.json
1856f3c088174d4d7fe55002b7a6bcf5788aea5a2a0e341aaca981ff22c6640f  release/kernels/addrneg.ccvtrace
7bb437c6e4c3deb1676dbcc5bc81fea0a87bd56f500bd98fdbeeb67e565062af  release/kernels/addrneg.log
16f5b0707ae44492a1efd67bb9dd38a7e79a7bbd354fa9207b9e7d150ff2f107  release/kernels/addrneg.oracle.jsonl
47c55ff7c2aa4b0474bd04141fcb17610848a6c55a07781ae3ae1d8c3dd735a3  release/kernels/addrneg.sv-hosted.log
3d300c34b7bda51d0d0974578c8a68b39d358c8db1b745dba93d89ddb39c9854  release/kernels/borrow.by_instr.json.gz
546274b0975f58474134b676b480e23fb85bd0f93e82e0beea2b38e252c5e3a1  release/kernels/borrow.by_unit.json.gz
53bf3d4b18a0414b481f5a80b52b155d57294c1387b373d1dbc26cf573d429a2  release/kernels/borrow.ccvtrace
e54c1cce9f8f2c8f6d7f701ea694634d992a92081ee73c0ae02deeb3be3fc549  release/kernels/borrow.log
4c565e1ce0b3baee36e158694b32c8defb5cd662b2f9af75cb5d8c26cb1168ed  release/kernels/borrow.oracle.jsonl
584b815d2e6c862c991495d6cb4bef59b5d4f4b07942058e878de92103ba2628  release/kernels/borrow.sv-hosted.log
33a7c6ec0c6d0f5d97e5e16be35df5f28025ee23db8bf2593a4e1d9b6ab1325a  release/kernels/brs.by_instr.json.gz
dbc5477878d89a10f7b7ba32735e78aa0bf2c97a3c782b346e5c4939dbecac00  release/kernels/brs.by_unit.json.gz
3429cd31fc2da452b73157c653ccd63095c4243f61fb18ae98d290c33a09e928  release/kernels/brs.ccvtrace
fcd91700239fdbd9dac9df127805106f37578b60b328c703bdbf84797f9d4eda  release/kernels/brs.log
e3c1cb3379580cf1aae44e8ddc8e846ef6fd661a573cfe0a8d4444b18a14dc56  release/kernels/brs.oracle.jsonl
f5e51befd99947bd3e9f330004db019a2eb6e7bc384d8de22b92ef123d631904  release/kernels/brs.sv-hosted.log
2fd21154e9af26dd4a4945def20c153274e828f439e0fb21acbaf7b857436cba  release/kernels/byp.by_instr.json.gz
e3da2411aa69114571d027125714e77e3977120db8a8471db9eae9aa3db650f6  release/kernels/byp.by_unit.json.gz
097c7e5692b7350d9087235b51ac02338448abefeb08a7d9d68e990adb1c69f8  release/kernels/byp.ccvtrace
89be1bd58b45079ce4e0e6a1d709319c7d3feebfcb5c45e188bae1388282002d  release/kernels/byp.log
5a03dfa4f3603fef49f1e3639e74e34152ca3ca5ef8e41eb959f8323040fa2d5  release/kernels/byp.oracle.jsonl
a701589c3b0c6983ed5e685e2ea93c7137c8ca32abf111b0b3cf856a20eb07f5  release/kernels/byp.sv-hosted.log
d990d20cdea28f525479bf875b7e045d36a01f2f06b2be24a31167cd2476ec13  release/kernels/callret.by_instr.json.gz
3ad814863e1dd61a6c284f5f0735f6025be2ab66fa88fac6e9e66f323d5dface  release/kernels/callret.by_unit.json.gz
abf594e26b52c7ca113101c570e23da8ef87dfa7da51a43c43a3cc13687f4ca9  release/kernels/callret.ccvtrace
6c034e79ccbc4251f43b7e3a58602849671657f330fb19d54a3d562986b8e4fc  release/kernels/callret.log
9b1d1b50b527f732362f837250aa2f26dabf3e76e16a4794856ebd8f105635b8  release/kernels/callret.oracle.jsonl
73b8f099736b1fceb28192c1d49cb5174a22b59d6d10f732771a9d296a96e199  release/kernels/callret.sv-hosted.log
eb9463b7f1bd8df57dfd2c4f0e9c22d4ec14a4f1b2604ff0801d987dcf81fca8  release/kernels/chains.by_instr.json.gz
ced9ce7b992f45b8c8a33a11ec090ddf17b5149c18320b6e656d627f1027cf1f  release/kernels/chains.by_unit.json.gz
7b28b89e2edf15702229dbd78c0c7d20978e2e96e8c74a8b07beb1f2d2b04f94  release/kernels/chains.ccvtrace
9b998cf0ec83a7105cadaadf149b69ed4b3d32ef38d58ebeba51d579f9f65627  release/kernels/chains.log
26a4cc5c5524c7219d8706c2582c80357dea60be9d6ffdec99dac7d0365e2264  release/kernels/chains.oracle.jsonl
76df96fdd55edf6aeee8bcd5414c0be2d654da3b9b1e743324912d1a193109bc  release/kernels/chains.sv-hosted.log
86c1dc9dad7db3d29d2a5d9d954f6827976fb6ebab532e30692b41da52728250  release/kernels/div.by_instr.json.gz
6e4ffd3a815993cc7d44d19367fd6d6446ce4ddcd9fd86a54f5d3cead1301e1a  release/kernels/div.by_unit.json.gz
a3d42ac7be5398fc431eae060a399fd521a6404d3b788786d0860c223aa2d677  release/kernels/div.ccvtrace
3bba5084c1174f888e2d018438939b1c7ca5c5829b1e2e455f02d36809c046fe  release/kernels/div.log
71a567b85cf85622631490187563de9a5661099c78a590adff4ed0a0c3d24c16  release/kernels/div.oracle.jsonl
c51ba416278354d4a503888e05652eb4b32a4aebcb61a89fcf08889b0269e029  release/kernels/div.sv-hosted.log
15781c26b5198188bc30a98308caf2ec558ab6e8a09e19022cfc5d26dc8f34db  release/kernels/divchw.by_instr.json.gz
7a39f97a1b0c70baea07403e7262121dfe50ea1d237442c243bf81a6cc6d4a83  release/kernels/divchw.by_unit.json.gz
64e79dbe863bcf54a416bd395ac9390bafd483d533df4fab093ce412854146ab  release/kernels/divchw.ccvtrace
5b92766896f7f7ab5e314fb4c836a98f3fede3ab882917d95eddde354efc82d0  release/kernels/divchw.log
58a541797f7a2df0a1c7528ae6a3edec212db90c7d3eb20656806f38b5c10b3d  release/kernels/divchw.oracle.jsonl
ff3ccd3f436871321406202853bf45fa3d1209f082468e5007ad2527892b2b2c  release/kernels/divchw.sv-hosted.log
a66c231b27eb0a196fb3be41ca32f02c84946a8c3f5c26556d8eb61c1e3bcf1f  release/kernels/divtail.by_instr.json.gz
4aa4f84ab8855b5a2ce74a8540f3c890e0c774972e2da213e9215f72f8a2055c  release/kernels/divtail.by_unit.json.gz
9316548aa587ac844a5a1c523088f650cb2f9414746d4bc01fbcdc7e398ae8b4  release/kernels/divtail.ccvtrace
4d09d25ece97e63a8fbf9c5279fe701affe6bd7586cdc58db6fcb8a66ec6baa2  release/kernels/divtail.log
75f11a75c9b3b336e446140af4579f05b46c363a76b7aab3ec88154a07ba097d  release/kernels/divtail.oracle.jsonl
bed69aafd68925d04b7a385bf4e4e41d3ddd8858677e9a34b6e1d603e1a1d99a  release/kernels/divtail.sv-hosted.log
7b24cbb17967a5865b0041c192ce22d964d67a8cba1fee594a6c563d4709c521  release/kernels/divtail2.by_instr.json.gz
4f933d97106c586965be5a29cfae6d03c6cbd6a84250a7bc12529a63d83755a8  release/kernels/divtail2.by_unit.json.gz
34da6548abc858b5b6be931bea26853813584f4e2298c0589c5b92effb352edb  release/kernels/divtail2.ccvtrace
ba11514b5f430645b473ecb41e25e59aaf4040b00cbe1db91a0cf78532d1f628  release/kernels/divtail2.log
b2db6b05eb6cf4a0a7677e31d0c6c2952d5cab49d353f0bb1883fe0b2a20ed14  release/kernels/divtail2.oracle.jsonl
c76aa137f1b595de5d6c4068d82f5d95898e876e162647bb99844363504089ad  release/kernels/divtail2.sv-hosted.log
df4ac9c21ee9e911e2dcc9d4c2cf9ab5d017d6aa1f3999a16fde27d7234c730f  release/kernels/fence.by_instr.json
b0e3c171f37855d4265a61894cc2b64b8ef4ab6872a68f20562092cbef033637  release/kernels/fence.by_unit.json.gz
aba03523ed2138041961a6e7de252e88686ff4ee8fca27e3d426bd4dafedd7af  release/kernels/fence.ccvtrace
fe5a49e72d619b2a3a88aecffc29b9a6b6df02101e70e0eabdfbf59a3b6bdac2  release/kernels/fence.log
d1d40317f6cf5bfb430cda1f9c0ef676609e59cabe2a11623c42ffbeca93142b  release/kernels/fence.oracle.jsonl
f478a9fc1b14a68f31a8c150aa3b40d393d20bead7ddc539d1f7bfb6750b95ee  release/kernels/fence.sv-hosted.log
f5c22252ca17a9dcb20bf24a453c3fe71babd7dbd73442d48a29595c7ba67056  release/kernels/gather.by_instr.json.gz
c5b4f812401ba647c27852ddec04e156931834dcf0b46ad9b90ed330269893be  release/kernels/gather.by_unit.json.gz
54ef7aaacace62b402a68ebad3887326470a82eae52f92b208ac7140d76b784b  release/kernels/gather.ccvtrace
d4f0fca4fcebaca14bb9b03951c63ac21b5a171854c8b4cda12cfb2b2d5badec  release/kernels/gather.log
0413e781d8d6ff578c64eb1f800b7931e66f676d5cdabb97b94a4033e6037662  release/kernels/gather.oracle.jsonl
57b68c75fd7fdf221b6b2074ebd393b574e81cddc8b813ad88f634ea3cd7fca2  release/kernels/gather.sv-hosted.log
600a9c398aec69f36212ffced221af76da4cd65f8a65fd4f84a10d2497416b80  release/kernels/hit.by_instr.json.gz
a8cf0e95b55940acdf759cfd62b16ab8a9aeff782f8ae92bf04780ff6c94b862  release/kernels/hit.by_unit.json.gz
1ce490ae78b2216bef3b662a2af3599a189e7adbbbeee3c94437fe761a23b63f  release/kernels/hit.ccvtrace
75b66a4a4786b36fedeac055b493ee8b91234999eff47227edadb60f86253f12  release/kernels/hit.log
7ba9603e0088d9164de6528f16ef6a7fa9ce5821c8c12b52cbb3734e39b9fd52  release/kernels/hit.oracle.jsonl
bc63ba140e2b5eac9766dc713ac51e44e8db37589d209036a09779320e35e786  release/kernels/hit.sv-hosted.log
89554599c2a4c6213202d7038534c88ef29446256ba2e0945424b9cf7add1313  release/kernels/lanectx.by_instr.json.gz
94e090a74cdaf0d77299f12b69be95a3b252920e54c32f9bb6dd13d91bb0132d  release/kernels/lanectx.by_unit.json.gz
2119a6d9ac7beafe1a70d893ba377d3a3a40321c947a753c4e2d41a2092f20df  release/kernels/lanectx.ccvtrace
6c841c3febc6e69b975f5a8b2372b9387e9a25b0ba175778f395913a96d6e1de  release/kernels/lanectx.log
888551babf540db8e3025b82e65ca655013f93eba3c8a65689d069d52a7e6039  release/kernels/lanectx.oracle.jsonl
4adfc63a01d3e6064df7dab427423c1d5801cebea72b19ef47ce823150e999e8  release/kernels/lanectx.sv-hosted.log
3061c0c76a4e9d07fc8618bba0ed56d9b1484b16832870f60e18d0b73d38405d  release/kernels/lanectx2.by_instr.json.gz
fbd9853843e1e358d2b221610dfa3b1098276d93f442391417cb4ef0f7c1ed0f  release/kernels/lanectx2.by_unit.json.gz
394c48337bde53cdc91d6c2264f547b03abff4aca0718988d6e4a75b05d5d197  release/kernels/lanectx2.ccvtrace
644caa717cbc5ffc82ca7b7ac7b4c5cdf9ac030a8beb9e9aa08dbe16fc572592  release/kernels/lanectx2.log
45c13056dff5c73ed0c9ece56cc36f929bf335322193c7d5eb38710b1d1dfb02  release/kernels/lanectx2.oracle.jsonl
c936af875f92854d4cd54633829e162e2438af76743e07d74e00032b0b74cbfa  release/kernels/lanectx2.sv-hosted.log
4510e2d98166862784700c84f11647f0f827e8927855fdf8197a284a26e22e3e  release/kernels/late.by_instr.json.gz
8b485cd7bd541eccc7336182cb739952d3e46ca6997b158c159ef9e06960b61a  release/kernels/late.by_unit.json.gz
115085fa283eaf72359f40ae50a5ed2e3feadc7e0eedf694a611494042846f35  release/kernels/late.ccvtrace
e78e405835d33dff5d2d9043380e1f64bc864f373a1a5cafef413a2d1783266f  release/kernels/late.log
86084f6bd747a2cf32acbc0ebd96ebd3e4ef2d8d9e21be49e3ae49290d7927f3  release/kernels/late.oracle.jsonl
4573fe079fca01058e6b86858a115cd437c0ad5c11b0b2b0ee7f1c31c8a62903  release/kernels/late.sv-hosted.log
fbd9264cc0b416b550ce764c729be71d05da9db6052a9fb0da40fddf6e4ec0dc  release/kernels/ldpar.by_instr.json.gz
1ee11aeda7487ae814648ed6efd35cacaef3a3412c39cf47a9ec0cf624a1d3db  release/kernels/ldpar.by_unit.json.gz
8595a89fd61743b14b53c46d151d81bfcd88d15c88695ca218fec5e2ad706746  release/kernels/ldpar.ccvtrace
3e6e4135b8389ed3768b461aae465ddbedd8efec05b2c372d64fe77096730d91  release/kernels/ldpar.log
8ac08538e9c807637babd61b31e340f7461878ada31f0c0b83cd66331cfaf486  release/kernels/ldpar.oracle.jsonl
c0167a6c6d33751197243f0091cd207f8cc5139bf783d7b2fde27acf15980196  release/kernels/ldpar.sv-hosted.log
a30c093a581cadda71430126b15116372d494db728e5a838a5125bb98748811f  release/kernels/lnorm1.by_instr.json.gz
a309401599ce66916ae93f5b80a1297b37d193e5d6b454d362400089f8cbd3e2  release/kernels/lnorm1.by_unit.json.gz
b2350d199bb4eb7d24bfeaf1b538d56cecbe64c5af275e5e95dbeb2b97c376e7  release/kernels/lnorm1.ccvtrace
1a647b0b0eadce600f80a1e446ec57e73e9ab22e1c33f97366f652d5b2466c5d  release/kernels/lnorm1.log
a8d85811af988a1b9fc00db1517300af3d93ec8e589e403d3b9113fa9e0ffc86  release/kernels/lnorm1.oracle.jsonl
e00ed5c72d775d394691224ed11d475abac401f65117d557be4c347d940ca355  release/kernels/lnorm1.sv-hosted.log
9e6eeac8de03aaeec9bd06ac50c63dadd915fc8a259008e50401fc5adda66312  release/kernels/localsp.by_instr.json.gz
c42d0791f20f4dec49727a161aa21d87c0bd0b294aabcdfc7c89fce86afc6d7a  release/kernels/localsp.by_unit.json.gz
38184fb5cab0c4b1266021ba6a922bc81e601fa502682b6e23a027fbe9c50759  release/kernels/localsp.ccvtrace
32d5a644998c97ae739956a7f5c456db798b0119c2aed0b07db325404212bb9e  release/kernels/localsp.log
55e3c9f36e7f7d38c0ddd38903aff4bb4509ae862015c592e6b937ea258042ca  release/kernels/localsp.oracle.jsonl
1cba1a947c3180e6e73a70308f5853a18c0861fe44db70f94ae47b24bc209f95  release/kernels/localsp.sv-hosted.log
d3f7a5fbe1b4d0901e21422b1200c5b243e8153bab8496004757d6de3d363ff2  release/kernels/loop.by_instr.json.gz
aa8e5c7aba109cd45db03b41fcdef3a9396696079c623fbdb0b0f5f8f700a191  release/kernels/loop.by_unit.json.gz
b5415c9d6d5fbceb4c9ff083c5996da715acad9b893b83a8e0dc8708caffbc44  release/kernels/loop.ccvtrace
185de009ef38ea64b165a6fc6c14e8c958f050a995517496202c83cde85e7f91  release/kernels/loop.log
03ce5920c06c93e93516d8e53c3f7169f14e3593de204eacceffc0b8a3e32016  release/kernels/loop.oracle.jsonl
05166fcaee7b72b3af2d0c1e0c618f23532a3ae1a19ecbb5aa89f2f4be0b1158  release/kernels/loop.sv-hosted.log
1d81ebbe889e947c1e53a49a7c2e90c8b559b08c79e88340440b318172a027aa  release/kernels/merge.by_instr.json.gz
1ccec4c978bdc3d9b5e31f08bc01743e4ebb1a6f6b583f222363493d89443ec9  release/kernels/merge.by_unit.json.gz
f03b5b8724e00e74c9cb603221ebcb45271d5787fa8675d733085d71f8b0e307  release/kernels/merge.ccvtrace
f8d17ca3da5849bde321420f242c0d38da7622e0fcdb8502c9700bcb49d3d6f3  release/kernels/merge.log
f96d28815f8756b1f5a45ded53e6170883d2dfa10f9eef0d14b8050b1318164a  release/kernels/merge.oracle.jsonl
0d8d8b511779d87642701ba4dbcb6091c80897a364cea1686d23821c55b42a36  release/kernels/merge.sv-hosted.log
88d8c572bc53e65facc92b345890c0f91870e2219fd2556f91fdffcff7599747  release/kernels/missrun.by_instr.json.gz
1b8ff25a5fcd4ba5f06f2a14739d06e0c997ff748343884083e431df5f7569f3  release/kernels/missrun.by_unit.json.gz
1f25502382ab70df5f849c555ceae405bb1339d095932ce00f1d5448d573593c  release/kernels/missrun.ccvtrace
aeae866bbba55da369e0922633309fe44a0049fc68fb8041213521dceef32bef  release/kernels/missrun.log
531bdaf281e5590774bd2775427f25e4cc0419cf8e3d5b6999843ffe9ef87258  release/kernels/missrun.oracle.jsonl
6b26397bcd5707e82f50e879221f914fe918774642286d2fde9ddc79ac21958b  release/kernels/missrun.sv-hosted.log
c3c28c6f8801b3d2c20cf75550096d3dbd46c450fc4d49f29da7f0d32ca36f31  release/kernels/mload.by_instr.json.gz
d8fc0c054aad75b95d5a713de8488a22b5a595df3b7db3d11256463c85fd34bf  release/kernels/mload.by_unit.json.gz
9fec8b9122e6e1293201cbc39b39ffa20f615df0f3e5df5e8ca3160af98f735b  release/kernels/mload.ccvtrace
9099d27f3567aac469d58e2cda4614cf82704f44659db51941c64760f4f36f44  release/kernels/mload.log
8000e477b9a95dfb9f0af964e8346acb9d36f1358fd06ffc4ff7cf599d2b8868  release/kernels/mload.oracle.jsonl
46f24a69ce8c2cdf7e66fb12184023f8160fdcea431755ebb25a38d589dd60ed  release/kernels/mload.sv-hosted.log
4d229f8d1d181bc3b654965045b8adbabec37becd71e1f5b6a1c11acc757c500  release/kernels/mlp.by_instr.json.gz
7025de9a8be125df2409d6e87318fde7c26c77869ea56fdcea821785cf30d325  release/kernels/mlp.by_unit.json.gz
efb84392c7d90847dd248fbce31bb95e9de05aed82f3f7defdd08c1806240d4c  release/kernels/mlp.ccvtrace
7cfb7d1c06bddcd1bebb1167bd6c6660d2ed3bf4d7cc23a01dc47f0d4c3caf79  release/kernels/mlp.log
138d282f88d56c8ad648a91af0a983254b55d9fa22942c00d47b327f516a6e44  release/kernels/mlp.oracle.jsonl
277a8f7c8231d821205247cffa1992d8881415707e487ddb3bcc42e9f069f62a  release/kernels/mlp.sv-hosted.log
c3fcf74a812f55150bfbe09f1f99170302c2ad8abe44da145c9a284cd33174bb  release/kernels/mwmiss.by_instr.json.gz
bda662d8394918067dfb1bfc2968338bab66ae1fb9ff2105059f0ff080de90de  release/kernels/mwmiss.by_unit.json.gz
3db6d9460bb9660ee4c47f2bbdaff9c3d4eea5a50f1fcc1fbf91f26cbabf7c6d  release/kernels/mwmiss.ccvtrace
270151e00848ed34edc207bcfd2f1da5fa3e2895e9c126ed21283b647c4d66cd  release/kernels/mwmiss.log
8abe8e8997456a2a6711ee72da54d854b24e20abbdab28e4b7271c0d28418de8  release/kernels/mwmiss.oracle.jsonl
0165a2c0e5f698534761fb324aefb4aa280b4683ae5bb2b1137368d0cf9b08e4  release/kernels/mwmiss.sv-hosted.log
656199b5335bbd27bcfaeb9afb1890b68ea43cdb4c60b504daf55ff882d6c7b2  release/kernels/narrowadd.by_instr.json.gz
4b54a86bd6f2797f509b45211a1ca5717ffb1230bad88dae8ec54075d964692c  release/kernels/narrowadd.by_unit.json.gz
c694438d74fae482899c34004c2faf5940249fd99ddff07b91d4f0efc392c687  release/kernels/narrowadd.ccvtrace
6a32a3576a92ed994a6cf77b0a337ba9b58b816b18b4782e203532d7c40d6145  release/kernels/narrowadd.log
40a2cf629853dd404bb06b4a07e35abde3d12efc13f26ffe28f923daf2994574  release/kernels/narrowadd.oracle.jsonl
ee645a6d9f94f59f492be54a2902a7af49d211aae655c1ee30b306890f7c1683  release/kernels/narrowadd.sv-hosted.log
349de9bdda2030b7c7b1b431c81d2d9bbf01cb879b1a87c08c1e619c805bc660  release/kernels/pguard.by_instr.json.gz
62a6c0e2df95718bad482b25d93d82e2ba05170d94635f0ebd492bdf9435e18f  release/kernels/pguard.by_unit.json.gz
d10835277946646e5c8525db1ab4eec371d368e8c7fd12edc30ec901d0d2f132  release/kernels/pguard.ccvtrace
e8f7bab52a4d41b10a8eeea5fbf91555a5ab551bba3432408e562a6808ea183a  release/kernels/pguard.log
690e56f1cb8d97cbf67124b7dff3ad0a90cb8981814cd1709cf0cd0e035b3bd9  release/kernels/pguard.oracle.jsonl
8a5fdf07888415cb32f8a7650e33d9842d96f13f10442327c02cf523ed6d63b4  release/kernels/pguard.sv-hosted.log
fcd22bb8725c2e604db243c46f6a7d8e32c0d01174a77cfe93b65e8fd7d6d9a1  release/kernels/plog.by_instr.json.gz
85f68998561ebaad79443a2366165010230866b61dc644863297559cb7bf3d70  release/kernels/plog.by_unit.json.gz
13e1078a9590b035eac19432548487fe382c12db4e8cba163df97c474cff5f5d  release/kernels/plog.ccvtrace
cde64746d910ab39cec1ff6b736218cd460694a8624fdc8a03b8b54f478d279b  release/kernels/plog.log
c230f13f2e1082b306a9c5ab7809ff36cf5c1b2e47dca6b7a71f741524d403f5  release/kernels/plog.oracle.jsonl
fdf8b835ce92948dd295406e7c11968ecf2ce9e60a94d2a267aae509fd52c39d  release/kernels/plog.sv-hosted.log
f0c216e7e13579046170b362accc697d547b9e4a942cfd6455bdf83f40852f2d  release/kernels/predlane.by_instr.json.gz
1147c6a588429ff1fd843e13384975a0f93d875c8ec2d8f4df7d003133f55e02  release/kernels/predlane.by_unit.json.gz
cc231b4a097822e6f4f7430cb533ce75633d7125aa0b5011ff12e4dd564d5011  release/kernels/predlane.ccvtrace
1cb8ec30517a04f5d717d8797ce9ce1dd1c92580d1f87801eab0d037f9961614  release/kernels/predlane.log
c45f4177b9e84fc8a6e36b13534a0c7636eb30a3f8531847100ce5e23bf404b1  release/kernels/predlane.oracle.jsonl
916805f2725d8ec98df74e1bc6da60a94b83f7503bb4c8de482a6daa1af977de  release/kernels/predlane.sv-hosted.log
ba2628071687c2c26b0852cd24be37456eee2e1b2d87f16566d7f7039d099c42  release/kernels/predmerge.by_instr.json.gz
61ecaa497cb6596aa587a4fc05b75e77adab889f385b5e4f49064dfe3f4db031  release/kernels/predmerge.by_unit.json.gz
bb4693d2c39bea3e0f2f15d45b29760e080fe3be2b6c38e233b7216ed5a297b3  release/kernels/predmerge.ccvtrace
ac6873d8042472952f98f914b7ad753ef71e651f9a1ac344ed8c66a8e22acfc9  release/kernels/predmerge.log
6c737c49434bcd08e3e0814c8b1dbf15c586ae74f7929ba3148ddcee2c62c845  release/kernels/predmerge.oracle.jsonl
4b46d0246b7bb90b3471c431de889b6ee9442a01d1feb490af15bc2fa9d952f7  release/kernels/predmerge.sv-hosted.log
072caae806aa8ad6db99e030c9b108ef455bf7dedc875869609c51f92cb45b5c  release/kernels/predspill.by_instr.json.gz
e2ac95e7817c75efcfd347d714e91917f97c3b7bb787178a88d19375ac395433  release/kernels/predspill.by_unit.json.gz
7c385a4beaae881b3f225c8564397cf7ffa0ce9a6f76e7db526e05518597e301  release/kernels/predspill.ccvtrace
67a09735d2d3341de2a1b0032c0c5d30349e38bc4d9595ac3c7868358bcbfdb7  release/kernels/predspill.log
b7c84c6478117ffa0f06da0e6ad1e4628e2683426a7911080810e78e06a5242e  release/kernels/predspill.oracle.jsonl
2afa526ef6105437ed655c93a9b3d75dc12be98306fafe9ff74faa94d48c6195  release/kernels/predspill.sv-hosted.log
dba0e57f60b9e0bb9dc9d1a8eee24152491aa4f3e076271234c81158a44aa951  release/kernels/predswap.by_instr.json.gz
045b20d0fe35f2977460d57bf831e89db989ac8bcda4b700a380127ac05e1fac  release/kernels/predswap.by_unit.json.gz
1c6e4ccf2fdd48726b02ca1ede078b6c0cc705cc57b231bb54913935eae84748  release/kernels/predswap.ccvtrace
886a3021139144176557fc372d3287f9707b62f18a62de3dbc02b081504428ce  release/kernels/predswap.log
a6d4f7ed517553816d889c7c9eeb6bcfd1f6c973fbf682ecb69f3c2de619f7bb  release/kernels/predswap.oracle.jsonl
831ea654f592e83258d5181aeac4ac4e86f2fa84e23a2fd96788c32c6b5f8de7  release/kernels/predswap.sv-hosted.log
ea9cf531668e97f841a7009a62a44b46eb5e7f43714978e2c9fa2d5f27c45d3e  release/kernels/privwin.by_instr.json.gz
2795ad38974f1f98a8c8df0b2d3188a6d78fd1671e8fb09b2b707802a3c7d4a0  release/kernels/privwin.by_unit.json.gz
0e5a184a91c7cb75d2ccb15aa6639482cfa45cdd170edbaeac02ba568e3a80a0  release/kernels/privwin.ccvtrace
42fd8262ee50eadfea18d8add8570c8a694b69be9e3abe1c94cb8de6c13050b4  release/kernels/privwin.log
861f686fc4480363472908d679d8815e8c957d768e7ab32c826930527b0fb7a8  release/kernels/privwin.oracle.jsonl
86a59c9f59f010ff9dcd33e9ba87446af1d195cc4ec44f6f741d388a4d38ac6c  release/kernels/privwin.sv-hosted.log
e2ea2484482b8a6bcfa7fdd9f3ee8e47a2be840107d917a2f8d613e5c5734c12  release/kernels/provswap.by_instr.json.gz
b5a33c1d4a89cd9474877628a18341070df3c261744ef832775886186759be3a  release/kernels/provswap.by_unit.json.gz
8e0f9cbbbef7338e78cbe7663c36776d47723c7298b6c0129f4b187df774b0ad  release/kernels/provswap.ccvtrace
911ac0cb48dabee2e48408a2e744f3cd0a5f1366879a95ca0f8368b7f080f03f  release/kernels/provswap.log
c9c32a793d54cc7401477f582487f7e8b345b2669a75337b8d6327120d98e5dc  release/kernels/provswap.oracle.jsonl
62c7ac725126263e2744a288b02160243af37fff2cfd4429ffd3a9e053514896  release/kernels/provswap.sv-hosted.log
3deec25603f4678ecd60db614c346c0962673ab15e8d542da773a8c9439f64b5  release/kernels/roconst.by_instr.json
2a50edcbd759185f72fc91862bb229331434c4521c249a516f376ff01cd05b97  release/kernels/roconst.by_unit.json
70c8714a871ccdbe32b451e084397362b6f285aaa37b7e1f3057d5f90dc725fa  release/kernels/roconst.ccvtrace
eb9ed3f3498a72dbce0287767d192fa90e177b792900cabd8f5ad09394f906db  release/kernels/roconst.log
8087c0671de620162881aecd38cd6114b78e7be6bd71201e3ec02c9a2e2e750e  release/kernels/roconst.oracle.jsonl
22c5e7cfc4a26c55d42c5bbe27c3d9068e7d8100e8ac24af5c06354fb9b909ee  release/kernels/roconst.sv-hosted.log
5455c96ec6019aeabc4b0e908502f85c22715b40bb112d54d730015142b437f4  release/kernels/rogated.by_instr.json
c792f8a4f23cb86ff981ab5da2c2a4cd6a98a14156f7b92406cd8473dd3ed012  release/kernels/rogated.by_unit.json.gz
79677d54069f8da637fa2b969079bf339e73219ad3f8f414b3f2669765fb7196  release/kernels/rogated.ccvtrace
af1747c724f6daedcee8e44b309a394d8aaa68d2fc3cde03a431e16c99461829  release/kernels/rogated.log
7cd02bd4cceec5a044d6b4d6a80df1e68ed0ae71b0b2a953143636d5b809ea6c  release/kernels/rogated.oracle.jsonl
cffc8d32e1d8fbc03ed2ad3ab819321e8fdd9b96b3e089239603ed8480cd0429  release/kernels/rogated.sv-hosted.log
280927ee1ed997a413c188cc7941fdb2fb5f51cfe3bc91d5dffab6c79656586b  release/kernels/rokill.by_instr.json.gz
26e5d4c6b5ec05962c07559c909de84f535bd2fd8e1c0348984b09af920827f2  release/kernels/rokill.by_unit.json.gz
e7d52215b4f7a360d0cb9e3a54302a910394e58699360723c21cebcaefbcdc32  release/kernels/rokill.ccvtrace
3b511ba7a6aa9a955b81a78c22a7c0e54652f11cb5a4da9a6c3c241a4afc15a6  release/kernels/rokill.log
94efcef96af469a512d346ce61623980fe86383188eaebd55120f716db596f14  release/kernels/rokill.oracle.jsonl
2515ba09f9a351ff20a291fbf4ee4e14211d765fee9740bbb057561aebaa3580  release/kernels/rokill.sv-hosted.log
3fcc245491973c3a5f2c2381fe40befa68cac75951bb61a37828ad002f5e5c3f  release/kernels/rolaunch.by_instr.json
c6e03215507cac2dc6fc62be8fe152a55cdc9d3d0ee6787002406efee4d8a4f2  release/kernels/rolaunch.by_unit.json
b4dd2dc854bda367aa808413c5b8fed0ca0854268c3716fff7cbe1ba3c1c0ddf  release/kernels/rolaunch.ccvtrace
0655cff219a34da53f691c62d67e0d5a1534c79d593d1a70ac106d8e09988c27  release/kernels/rolaunch.log
e7dad585c3e70615de04330fd03f4f282c29a005dc1732a35655fb261d51139e  release/kernels/rolaunch.oracle.jsonl
8eeb7348649f9136b7c73094b7f693c6b20bf549a82e57313f989744cb91870f  release/kernels/rolaunch.sv-hosted.log
3deec25603f4678ecd60db614c346c0962673ab15e8d542da773a8c9439f64b5  release/kernels/rolimit.by_instr.json
b8e5135eade5114a9ab5bb645d085744e17b63e5da86da36a10d912b2422e875  release/kernels/rolimit.by_unit.json
aca523a99aadf608795952b24add4be71849a9d8e1fe0f394bce73d168d5bd4d  release/kernels/rolimit.ccvtrace
77407a923cd14faf9efaa7fe990b2bd844872a3a1a25b654c62e84b32e8d6734  release/kernels/rolimit.log
1c5bc0cb8e8b2e69505fb5a551a16d5d10c56f232b88da7a27e336ad7d962de2  release/kernels/rolimit.oracle.jsonl
54912734bb1333f00407f9d1e11dea58c13abd349319bc3c48d032c1bdd4d61f  release/kernels/rolimit.sv-hosted.log
a04aca3bef9806af6e649b3df57f9531b867723c5a4308606af2d18d1f18310c  release/kernels/roload.by_instr.json.gz
15065441a8911f98fb49e63a6da617e26307a135df5e03069ce89fe3da1112d3  release/kernels/roload.by_unit.json.gz
960103e5efe7da29a60f461e6e5f1ca3ec6a8e47b573f50f1af14e025e33ffda  release/kernels/roload.ccvtrace
9602b313459715ce29b3e216b062add2645670f18db21b1c54690746e09324d8  release/kernels/roload.log
f7c1309cc9764769fb5803f6fd0f2f5e1eb418f2d23fbe5e17cf5f9106869fdf  release/kernels/roload.oracle.jsonl
3789b122482ddd26c737238678af1ed9ec95f103b0feb0880be25553959b850c  release/kernels/roload.sv-hosted.log
acd388d81ad96445a982b7ecf6debacdf1486f7f582c845baa239e9fc736b2e5  release/kernels/rope.by_instr.json.gz
4a2bcb15543acb565de110fa0a1651a65e4ab982eed3a99e796d0ef77b598865  release/kernels/rope.by_unit.json.gz
6f4b490b3c66592bbab396641f7cfb72f0baea9e5404554687117211f5767565  release/kernels/rope.ccvtrace
d61225b791d581568a356e74fc17470972be9e0c4656053b3a6f05454f2e52ec  release/kernels/rope.log
d55f9efae392dc8877c102c01c0810e7654b666b6ede386328108164c6cf88f3  release/kernels/rope.oracle.jsonl
b6e228ae9ff2293c7d0b1224acab00b3e74c45ee7ea8362f5589831a84a884ba  release/kernels/rope.sv-hosted.log
f467f14bf5d4520d0c5bd4193573017f50cef4e9831df05443ef27418441a192  release/kernels/ropediv.by_instr.json.gz
1f81abb8ea9820ae669468b38405934727e343abda09c4df1cdc8257428bf150  release/kernels/ropediv.by_unit.json.gz
bc190506cb91d3cd6343195c7e22289f9dedbbf7bdeb08407fadda4f3d3c82de  release/kernels/ropediv.ccvtrace
d2c5c8333210649ff8aaa0832540daa3efededa5802958424838d086ce576686  release/kernels/ropediv.log
10c0ec6ec18b7b44638c790033109198c079d07c1537bf193353ccedd00a920f  release/kernels/ropediv.oracle.jsonl
03cd39bd75163cdc90de6f2a4922c1f436086c10e45f96a62361d0512fa8aed9  release/kernels/ropediv.sv-hosted.log
efd4ce675748eba42a72cacac148275bb3bd057dd9394415d1c3c15f4c07a771  release/kernels/sel.by_instr.json.gz
7bf5d52b45519263659a42ab579566464faafa519960b681bea803a44af683dd  release/kernels/sel.by_unit.json.gz
513bff50a3b9d1f25156aee2aa31bd9f0aebdfded39e1b819d56577fc9ee8c68  release/kernels/sel.ccvtrace
2ffff753751a9f25a6d5f4ed8905ade2ac2da89b9c661e8c359cc64bc84af1b4  release/kernels/sel.log
87f6a81e8afa004c8039bf2f61c90176fcf29ab29bb17ac44aa016a5cc8438fe  release/kernels/sel.oracle.jsonl
e9cc9a37a97b9a1a965e4d741c02fb499aaacaf3c44e52b90e333e74719fcd3e  release/kernels/sel.sv-hosted.log
36864259fd89ff43830870c48f88297122ac1b4a3cc15ab9f9abd5f9642bd770  release/kernels/sized.by_instr.json.gz
d3915d726dcb0ee72d991b5b31c53957e1fb2394bd3b65504ca1cf952a82dca2  release/kernels/sized.by_unit.json.gz
a42720ce662969b08724bafe0b0a56cf6723624aa37728b92f4e54868f9b33bb  release/kernels/sized.ccvtrace
8fc106e9a439e79c9dcfa643929482e04109c6a2d9e2530b65a6de918fb7780d  release/kernels/sized.log
36d903ba1618bd1faa437c9812a6ee6c0c966a63196c796267d74bf2695ebc3d  release/kernels/sized.oracle.jsonl
2422d7591515dc0d5843cb4fdc1db18aefbb54aea09ec0e0dde1f6d35e81bc24  release/kernels/sized.sv-hosted.log
d9bd17f143f81601fa1bb6c41ef288465c02ca79279cd4d2078775a7a85470b6  release/kernels/slotform.by_instr.json.gz
06c241582b6c49988e05ec7b075469870d582f795c313bfe754a538409307213  release/kernels/slotform.by_unit.json.gz
203c4ca7b8ebb213247d154049a8ee95ef5073fe218313b20d4ec4f60f539c29  release/kernels/slotform.ccvtrace
2a8657d3bfff91176ebfc4fdd18aa6cc529d8fcb93ce6e0b10d1a8f3c0d4f629  release/kernels/slotform.log
8b61db7419b18cea8a646fb628218447e72e84a18a9891ffb73b441736138ab9  release/kernels/slotform.oracle.jsonl
ffcd05ff9222d1570938fe95fa5ca8b0f7abb2dc9307f7f882b263f71aab019b  release/kernels/slotform.sv-hosted.log
abfb3e88d6e6b869c820c4ffd53b0f83bc5fa5ed0bb7443da1b522b67c3bdead  release/kernels/spinwait.by_instr.json.gz
3707a838f50cac85535421c34835e01b8d7b3d867074c8e2431ab62e4900fb5f  release/kernels/spinwait.by_unit.json.gz
781c06446f2a1aa2e354348caa0f1906004de6dfc50e8337bcff4f76b4619bd1  release/kernels/spinwait.ccvtrace
47a11ecf899c2180ce2f36740bfd49afc8c54bf0737ca08d8b3caec678c950a7  release/kernels/spinwait.log
868920637236c878b33779bd450439466fc3626996a3164573dc11d437d5c709  release/kernels/spinwait.oracle.jsonl
f4e3fad61af64be7816d7ad24f8ed7c9e16c87ceb7fa5a0246f7c23c3f5d7701  release/kernels/spinwait.sv-hosted.log
5a4726161d63d80ec18fd54d5e955cf863ae1e4350d4a71d47cbd708fc331824  release/kernels/spmbank.by_instr.json.gz
a33e1d4b07d75fb45a1bd2943592ecb0405961d8179985f1cae6db359984431a  release/kernels/spmbank.by_unit.json.gz
39672a44aa542e5b9767367b822dc9521e3027107de485be10a88f60b434b80d  release/kernels/spmbank.ccvtrace
761bb1e0c7d7df7629144f445c4200b04adb61be28b6d7aa58e705ab8316ab8a  release/kernels/spmbank.log
3af490cc37d7a92dbe719b57de216b648536eb301ff9d13de9a39f50d150d725  release/kernels/spmbank.oracle.jsonl
38a59a5e864dd2defc801838289e520b338e900e0a482e0a1c2f7614de880e40  release/kernels/spmbank.sv-hosted.log
e96acbebac659ae2aada2a4b2a5d545f05e104555be1ed123a8d2e5e577a1d56  release/kernels/srd.by_instr.json.gz
ee1acd7db9391d6864992f951b0e5bfa1e55a9692e01fa0fbfa41f9ce6eaa25c  release/kernels/srd.by_unit.json.gz
55571873a8edbf1842b885de5576dd16a2db3e96874611acf35ac479f17bb607  release/kernels/srd.ccvtrace
7deac1f8f9838907e6a6f3870753c7335c6201e78fb87421f03a6b74dad0e4fb  release/kernels/srd.log
b08eb5e3673cac7eebb8b72af5ed3783c8e70a9e96592e76bf3722551bc79473  release/kernels/srd.oracle.jsonl
892eee964f3773792c7327e57f5b74761dcb338e2907f3df1bc70142344efe31  release/kernels/srd.sv-hosted.log
33eef527ce0c4d672f34644d58340f29349492421a6bc33d146f59bf6a835a43  release/kernels/stall.by_instr.json.gz
4a4fd366f10ee3ac3f08ee8c954c63b210cc50ad930a7118b7eb9a7b4a1b8b03  release/kernels/stall.by_unit.json.gz
0b42dce13b3a8101a3aa6898554badcff147a1692c257b9898b40f6bac8611e1  release/kernels/stall.ccvtrace
6254c1624e80252aafdbe7e776953583ac0bad2195c5d615509e1edfddf36600  release/kernels/stall.log
500db2c482b07a0706583422cd68878301d0146c1f872ccc1f11bfdcf5c993ef  release/kernels/stall.oracle.jsonl
640e24646702091d7530eab0095f81c218025a8faaf6deee61d360cfdc0d9d8d  release/kernels/stall.sv-hosted.log
d7003e9c24d6e88d7f1da57b095459f043642f0316f64723d03146dd0619c278  release/kernels/swap.by_instr.json.gz
ee69b9fcb693d6320916df7a3dedab620d176b2cf10f86bc3181e138e7b2d410  release/kernels/swap.by_unit.json.gz
82916c2de51772fb0d96433fedfe26432355f19f5f8a17a673c92f2e9b474688  release/kernels/swap.ccvtrace
325dd5d3ae702a740cc903bf0589707a2835b952bf851fd01c01dfd74abea113  release/kernels/swap.log
3658a26316c1ff7bc1744304a42f736e930fcde2865c8913e6cc67a22ce96667  release/kernels/swap.oracle.jsonl
7bfa06791a4d38ae6fac230fff50e703464d3c15c758c83c41f0c5b58bd08bd5  release/kernels/swap.sv-hosted.log
b3ab84e370a6704e1d3a24e2591ba9af671936fb193d4ec3a0b35fa5af9ea6f6  release/kernels/transp4.by_instr.json.gz
3f049cb16a39e11f0dbb7f06c2c6815574798a5920a181d029efd5d48a6fa3c0  release/kernels/transp4.by_unit.json.gz
8795534f4782071b1a222e6e581e136fa80fc484eac7455a3fa815d28cd0fd18  release/kernels/transp4.ccvtrace
52a92d0532edea2b7182b3007c53d0ba464afac070fa4da4a1e401b82ac80777  release/kernels/transp4.log
06396ace3ac19677fd39c700e408606e5bdbacb24997d663bbe8872e63dd74fc  release/kernels/transp4.oracle.jsonl
ad99ed24f2f5e736dbf4d91f229bc91b34c7e5d779158abfde9dd8ce629bb792  release/kernels/transp4.sv-hosted.log
ebce6521b9568c86ab1d992cf3239a2844846602901d54952fdfae941b0d95f7  release/kernels/unal.by_instr.json.gz
5613050962aa81789abb0d6f1eb7486d69ec49090d1a2773773ac22ec81e2dd7  release/kernels/unal.by_unit.json.gz
7ceed4ab7208c7f77607806d0a2b1909e45ed6cf7b840306bf2052f85cb5cd6e  release/kernels/unal.ccvtrace
5e819dec65b50673ac6121fce6719df4d88be72143e4b9f144c9689b5e729f55  release/kernels/unal.log
c3d484bb160657a563df983d9a2532eac27f556636617960aa1e72183ac2b299  release/kernels/unal.oracle.jsonl
7610d4fd467fc553fb6b2ff928727f731512a5a02ffcb1cf28b96cfbf4b692d3  release/kernels/unal.sv-hosted.log
57e6f1e4980a1c628333d23f025d77457624fbb1310fc9ab0940814f8cce2895  release/kernels/vadd.by_instr.json.gz
fcb78b1a1cbac1088b03215343bf050a9100a40ca8dcf6384571560df9fe14a9  release/kernels/vadd.by_unit.json.gz
fb9a7f3c5e4ceba14a306f5f846fdb22ff89bde2bb8890367a7d2f611a2e756d  release/kernels/vadd.ccvtrace
ad45d6e6d0e07bc73d3bb634c9d44b7b2de3af3d6c5aeedb6dca3f1866694ad2  release/kernels/vadd.log
0276b6d0611a4bbcdc004ab3987214aea138245bc7217504147331689a9c0880  release/kernels/vadd.oracle.jsonl
da8c59137599466e7dec0aea51836cf21aef1113501126f12f0c7f51bc5a828d  release/kernels/vadd.sv-hosted.log
e8a4158961768c5ffe0b18b81d77488feb90757ea49e3a31a543a7219137a49c  release/kernels/vadd4.by_instr.json.gz
15d4614bdbe762de9be6dd5d701b4ed9e68ed9ace34796f7ad13e09602eff537  release/kernels/vadd4.by_unit.json.gz
4ee86c942053702a22735c21f983633fb5c9e4d02d4ad142e36704e4321de918  release/kernels/vadd4.ccvtrace
20e9ba1ae61b40c45ec387ec0f9964ba3bf8b03dc535ee570be9881cf621d6eb  release/kernels/vadd4.log
225aa18fc9f38aa9ad615aa11de254337d59fa705877553d873062c68366e0db  release/kernels/vadd4.oracle.jsonl
485b46cd1d7ebe54fa68f1ebd640650600418cea1c76d39ad0bed8dac87aa483  release/kernels/vadd4.sv-hosted.log
f1f632a2e70b78244a0be31b89b465fa0b9aef9182413a8c54b4b8ff1b75961a  release/kernels/vaddslow.by_instr.json.gz
14d4af4bafe518c59c702483ea3bd776728786906e6e5c1857e446f98e3d0dc6  release/kernels/vaddslow.by_unit.json.gz
952c2a4c044d60b860146c5346c612284450a1487e56afc0afe79419e848fee7  release/kernels/vaddslow.ccvtrace
5fb43ad1d163320b67b762ac98f83d174ac56c3f189e3593e7780bc84f061ba2  release/kernels/vaddslow.log
e9e6218e8b8450e9f9ff6b39d659c994a1e51c527a0c5bd10d18b5658ae0e344  release/kernels/vaddslow.oracle.jsonl
1f30a8ef8c525b3f1ef25ee24ba323f914bc8832bf72a43324322c84c4b7d213  release/kernels/vaddslow.sv-hosted.log
d28c221b89c7a06896d866d495f14c627ce7750da60af03ccf4c28001e48d308  release/verify.log
1f3a2eff14dbda0754e19cbf72bc5003c950fc7d1691d527ce3a8d427fb583d7  release/wiring.txt
```
