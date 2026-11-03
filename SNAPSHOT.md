# Snapshot snapshot-2026-11-02-16ab8ae

**A generated, read-only snapshot. Do not edit or merge it.** The source
is `ti-ret` at `16ab8aea480d48b016a1bd5c36a22c43c46fea99`, and this branch is rebuilt from source by
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
| Source | `ti-ret` @ `16ab8aea480d48b016a1bd5c36a22c43c46fea99` |
| Built | 2026-11-02 (UTC) |
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
f09b3749379d594991c3255cdb792036324b428b136a947d77c40190fc926f1f  release/kernels/addrhigh.by_instr.json.gz
a100a5fe1dee401a6fc76115f156a7b635e7ade39bc38e8d920a6b7fb717bb94  release/kernels/addrhigh.by_unit.json.gz
0661ac42f0a88fab0abe16dd618203786ac21b3032787954dd5c7236c598e446  release/kernels/addrhigh.ccvtrace
ff1a566fb8e68d676754999a9b737d08893c2e3e825bd77ebabd7cd069d50d18  release/kernels/addrhigh.log
569f2e22883fad5f0956c57ec734e6afbdd4b8a854e50277425172d6c0cbd766  release/kernels/addrhigh.oracle.jsonl
8e58bf7dc2e8abe937f5cc37fba3be58318986a8f49ce424faf743ea881a1bc0  release/kernels/addrhigh.sv-hosted.log
89657fdaa19b5aed66f1bc00f2ca0c95986b020155e35077475dc28a643d98b0  release/kernels/addrlimit.by_instr.json
aec7c9bfed1544ae6953f0d4b9ac9d2735375c03ab4cca6fec0f952968707785  release/kernels/addrlimit.by_unit.json
393c0da8622a4a55b4a1c25a7ccfb9226947ca91903cff94db8d69e6c012c3f1  release/kernels/addrlimit.ccvtrace
3f89a5d2e6430edac81b5b5b379b38a8917d1f6b297be15bade8355f5e6b2134  release/kernels/addrlimit.log
bc660b0b40359a2c5a2478cb0eb4950b73fd22db50ea76b80052bc195a1920f4  release/kernels/addrlimit.oracle.jsonl
320363385ab19228b0f37704e229155427c5e2da5b18b2a8aeedb35bfee7615f  release/kernels/addrlimit.sv-hosted.log
ea8c34b3706590b020eeb2c15130ef52a55bf630a8d18c03356cb840c2c44ad9  release/kernels/addrneg.by_instr.json
9d04e045b564b5eb98e168a2d717da9b30745b8e7f2c05c3b20e93e4d589ee2d  release/kernels/addrneg.by_unit.json
1856f3c088174d4d7fe55002b7a6bcf5788aea5a2a0e341aaca981ff22c6640f  release/kernels/addrneg.ccvtrace
7bb437c6e4c3deb1676dbcc5bc81fea0a87bd56f500bd98fdbeeb67e565062af  release/kernels/addrneg.log
16f5b0707ae44492a1efd67bb9dd38a7e79a7bbd354fa9207b9e7d150ff2f107  release/kernels/addrneg.oracle.jsonl
c235b3bb7dd96a0846434c005863423c6843734d5ac2293487b1e6c09c391975  release/kernels/addrneg.sv-hosted.log
6d55e0d32df81592ce1acc14e6b04d8c69305bd328c4202421a32ef7cf4ec17d  release/kernels/borrow.by_instr.json.gz
b4035fda72dcc00a43855d75630842a1f1631cf1eb133ad6ab53d9b25f533a96  release/kernels/borrow.by_unit.json.gz
53bf3d4b18a0414b481f5a80b52b155d57294c1387b373d1dbc26cf573d429a2  release/kernels/borrow.ccvtrace
e54c1cce9f8f2c8f6d7f701ea694634d992a92081ee73c0ae02deeb3be3fc549  release/kernels/borrow.log
4c565e1ce0b3baee36e158694b32c8defb5cd662b2f9af75cb5d8c26cb1168ed  release/kernels/borrow.oracle.jsonl
8dafae96070acc5a05312b96691afa3f57fe30b8d79b0f8c825378be3fcc92a8  release/kernels/borrow.sv-hosted.log
b4710eeb11bc58d2e74b65b00a71eb2961520343fccced0e81ce695f7035b300  release/kernels/brs.by_instr.json.gz
417e32c41d4fc8019f6c09be671aa62dcc4d8bd27ce0685d398c20c189ce979f  release/kernels/brs.by_unit.json.gz
f20abf3edf59228a1f86d551933ac94ec8304d9e8d50a1654ea9f6481bcfd0d2  release/kernels/brs.ccvtrace
fcd91700239fdbd9dac9df127805106f37578b60b328c703bdbf84797f9d4eda  release/kernels/brs.log
e3c1cb3379580cf1aae44e8ddc8e846ef6fd661a573cfe0a8d4444b18a14dc56  release/kernels/brs.oracle.jsonl
5688c104d63865a672aa61d6e4b99231475402915a747bb282cf17d5bb0876d7  release/kernels/brs.sv-hosted.log
800d21dea5d38f176fed6b4979291c6f4b5b9ab7393fd541b6a52bdcc3968b3c  release/kernels/byp.by_instr.json.gz
068336caff8dbdfafbe1f36fb5c49030a6f0e0d32f7140f6f3b143731b18dd1d  release/kernels/byp.by_unit.json.gz
097c7e5692b7350d9087235b51ac02338448abefeb08a7d9d68e990adb1c69f8  release/kernels/byp.ccvtrace
89be1bd58b45079ce4e0e6a1d709319c7d3feebfcb5c45e188bae1388282002d  release/kernels/byp.log
5a03dfa4f3603fef49f1e3639e74e34152ca3ca5ef8e41eb959f8323040fa2d5  release/kernels/byp.oracle.jsonl
6a3527aa61776117e0fb58def104269d9a04a31bd8114aedce387ecff79d0aa1  release/kernels/byp.sv-hosted.log
ee32188dab3e005dbd7ee358045a3941cf4f1e5065d31946eb9cad3a814aac07  release/kernels/callret.by_instr.json.gz
c597e0f6082faacf4e2dc7663b59da7a033a76cd662a7cd99b65a7fef9a17372  release/kernels/callret.by_unit.json.gz
abf594e26b52c7ca113101c570e23da8ef87dfa7da51a43c43a3cc13687f4ca9  release/kernels/callret.ccvtrace
6c034e79ccbc4251f43b7e3a58602849671657f330fb19d54a3d562986b8e4fc  release/kernels/callret.log
9b1d1b50b527f732362f837250aa2f26dabf3e76e16a4794856ebd8f105635b8  release/kernels/callret.oracle.jsonl
015663370cdb5f1a1260e8f8f5f4fad34b69f41c1b3de5c3843930cf3bdb31dc  release/kernels/callret.sv-hosted.log
87db019c6f50719396fef5f5372ddd4d30c217bc61b7aef39eeb41ba9762d8ee  release/kernels/chains.by_instr.json.gz
a141d597b71a2cab3d1e92d2cbe53ef06412f2e494c9442cac6e29b06efb6ec3  release/kernels/chains.by_unit.json.gz
7b28b89e2edf15702229dbd78c0c7d20978e2e96e8c74a8b07beb1f2d2b04f94  release/kernels/chains.ccvtrace
9b998cf0ec83a7105cadaadf149b69ed4b3d32ef38d58ebeba51d579f9f65627  release/kernels/chains.log
26a4cc5c5524c7219d8706c2582c80357dea60be9d6ffdec99dac7d0365e2264  release/kernels/chains.oracle.jsonl
97159c46213a26d72e5b464ef8920864e1ab479d797ca4b4bb2aff74055c4bc9  release/kernels/chains.sv-hosted.log
2095339660baa7f52b222c0b5cbd2f137d120cd52d388799481fe9b7ca8d2fe4  release/kernels/div.by_instr.json.gz
8bcbec0f767342354651dd17d85f4f13a696db634b44fb68d03f0fa48dcf8bd1  release/kernels/div.by_unit.json.gz
6b3666b2d6dd1c90998cd82657c4aaaedd9b4d07a43b0bd2f3c5eaaa56a22280  release/kernels/div.ccvtrace
3bba5084c1174f888e2d018438939b1c7ca5c5829b1e2e455f02d36809c046fe  release/kernels/div.log
71a567b85cf85622631490187563de9a5661099c78a590adff4ed0a0c3d24c16  release/kernels/div.oracle.jsonl
5da4dbe191c62b51e77c2eba8cbfcaaa31c64fe932e7043950c87f9b43fafb98  release/kernels/div.sv-hosted.log
de15c17b065ed33b20b3e4422b65c71f481b49fe34e25fbcbcc0b9f65032923b  release/kernels/divchw.by_instr.json.gz
aec6594379911afa6024ad0d3e832c26f99a48512935fed6f8c4000c2dfde79a  release/kernels/divchw.by_unit.json.gz
ea4f828f5be13584bde5d90a520c8c0506aec576b9fca69bb81f896009624053  release/kernels/divchw.ccvtrace
5b92766896f7f7ab5e314fb4c836a98f3fede3ab882917d95eddde354efc82d0  release/kernels/divchw.log
58a541797f7a2df0a1c7528ae6a3edec212db90c7d3eb20656806f38b5c10b3d  release/kernels/divchw.oracle.jsonl
0974d8bc91381db8ba3df792823f1bf8d5c4147fdadf1ce2f228becf3ebad433  release/kernels/divchw.sv-hosted.log
ebfc65d5a7139ee3a4a43a42b7ba0bd1f60fcacdb61234abc86beeb3038d4ffe  release/kernels/divtail.by_instr.json.gz
c12f7822d33d118cf60b8e572c15d9f004ff249cf85a4d7b64898a5a7997ba54  release/kernels/divtail.by_unit.json.gz
c52e1e64e26f2dbb09331d1d3715987248eacfc687cad4d27f4e86fb4a9f9268  release/kernels/divtail.ccvtrace
4d09d25ece97e63a8fbf9c5279fe701affe6bd7586cdc58db6fcb8a66ec6baa2  release/kernels/divtail.log
75f11a75c9b3b336e446140af4579f05b46c363a76b7aab3ec88154a07ba097d  release/kernels/divtail.oracle.jsonl
56d1b6e76e7f91db058a296a3da829004f4f6081423ec747087a376a7468663e  release/kernels/divtail.sv-hosted.log
2359546b2e527d36a2ae31686318ab30e7a83be78aa1df3b11fd7f47a7727755  release/kernels/divtail2.by_instr.json.gz
640e458cb5f4c63b19fcb33abbd4d17dd8ffb3c78aa7c6db90fa403f8f99557a  release/kernels/divtail2.by_unit.json.gz
07ea0d085a4dc9fe16bf3fdabfbcbb926cf20f1ba8949693cfa0c02e93a8a818  release/kernels/divtail2.ccvtrace
ba11514b5f430645b473ecb41e25e59aaf4040b00cbe1db91a0cf78532d1f628  release/kernels/divtail2.log
b2db6b05eb6cf4a0a7677e31d0c6c2952d5cab49d353f0bb1883fe0b2a20ed14  release/kernels/divtail2.oracle.jsonl
bcaf5a79af7f9997ab9ced7123e07649b4005fe97b28cc4a809bb64ba088360e  release/kernels/divtail2.sv-hosted.log
df4ac9c21ee9e911e2dcc9d4c2cf9ab5d017d6aa1f3999a16fde27d7234c730f  release/kernels/fence.by_instr.json
e2d04688448c8a42422e801ee8c409f00a2d87c94bd0784759d5f48f852cf94d  release/kernels/fence.by_unit.json.gz
aba03523ed2138041961a6e7de252e88686ff4ee8fca27e3d426bd4dafedd7af  release/kernels/fence.ccvtrace
fe5a49e72d619b2a3a88aecffc29b9a6b6df02101e70e0eabdfbf59a3b6bdac2  release/kernels/fence.log
d1d40317f6cf5bfb430cda1f9c0ef676609e59cabe2a11623c42ffbeca93142b  release/kernels/fence.oracle.jsonl
a8d9065ff0f4311cc6cff30246ab5b1a30c0b74721deac89b9a234714d74f3c7  release/kernels/fence.sv-hosted.log
8aa59639ef6f1a8a6b08d6b3a4e295726c22a0fbf7157fa53ad68ba1eeb16a15  release/kernels/gather.by_instr.json.gz
2dc86b320133fc13915acf4d0574db979a8cb63a9c66e647ec89cb5e53dad77e  release/kernels/gather.by_unit.json.gz
54ef7aaacace62b402a68ebad3887326470a82eae52f92b208ac7140d76b784b  release/kernels/gather.ccvtrace
d4f0fca4fcebaca14bb9b03951c63ac21b5a171854c8b4cda12cfb2b2d5badec  release/kernels/gather.log
0413e781d8d6ff578c64eb1f800b7931e66f676d5cdabb97b94a4033e6037662  release/kernels/gather.oracle.jsonl
65e58c12074d4c1d8c78308d9dc182f8c81e85729cc111f098b70cfd9cc9a13a  release/kernels/gather.sv-hosted.log
bf681fecc143b3b5c1fad76b2eaa8c783ae4154050f36c5fe73a2ef9a5756feb  release/kernels/hit.by_instr.json.gz
87253636aa766cbb143e09e1cff6f0b004d080c87b08efb29325d7014a8cf4e3  release/kernels/hit.by_unit.json.gz
1ce490ae78b2216bef3b662a2af3599a189e7adbbbeee3c94437fe761a23b63f  release/kernels/hit.ccvtrace
75b66a4a4786b36fedeac055b493ee8b91234999eff47227edadb60f86253f12  release/kernels/hit.log
7ba9603e0088d9164de6528f16ef6a7fa9ce5821c8c12b52cbb3734e39b9fd52  release/kernels/hit.oracle.jsonl
7215f15791ed57cfe6dedebf2fa09e82eb48c009114bfaa27fb5404a95ba13a5  release/kernels/hit.sv-hosted.log
d18235b9b1eaae8fa26dc4b4d3a8e8e00882616f3c28c9f3634a30e873939bbd  release/kernels/lanectx.by_instr.json.gz
9af80f59926eaa4174daf80ae1cb1e7f48ac6c2732031f7a279c334fbeb9860a  release/kernels/lanectx.by_unit.json.gz
2119a6d9ac7beafe1a70d893ba377d3a3a40321c947a753c4e2d41a2092f20df  release/kernels/lanectx.ccvtrace
6c841c3febc6e69b975f5a8b2372b9387e9a25b0ba175778f395913a96d6e1de  release/kernels/lanectx.log
888551babf540db8e3025b82e65ca655013f93eba3c8a65689d069d52a7e6039  release/kernels/lanectx.oracle.jsonl
ac9365dafebdc75534e4186a5baad86495b5ea91191bfa15ec1fff2e06f5a7a8  release/kernels/lanectx.sv-hosted.log
1602550121cb08f9e75bd1cfc83eb78f82ff122516449d72d70911f25e045029  release/kernels/lanectx2.by_instr.json.gz
e468bfc49bf113a2e2d4ab30792374e8d4cd61d13bdade90672ba059d189c2b6  release/kernels/lanectx2.by_unit.json.gz
394c48337bde53cdc91d6c2264f547b03abff4aca0718988d6e4a75b05d5d197  release/kernels/lanectx2.ccvtrace
644caa717cbc5ffc82ca7b7ac7b4c5cdf9ac030a8beb9e9aa08dbe16fc572592  release/kernels/lanectx2.log
45c13056dff5c73ed0c9ece56cc36f929bf335322193c7d5eb38710b1d1dfb02  release/kernels/lanectx2.oracle.jsonl
64b496893bf64aad9cf63c9940d1a8a09e2019ae0326f5fe4497b3274fa2320d  release/kernels/lanectx2.sv-hosted.log
3cf30773b8c0b20544684d890573cc09b122c62224dc4bf00ac9118eff184885  release/kernels/late.by_instr.json.gz
9f2cb99cd92faeb0ce1c8d8b6755929852a63e10bcb543ac2a89b7d251273f92  release/kernels/late.by_unit.json.gz
115085fa283eaf72359f40ae50a5ed2e3feadc7e0eedf694a611494042846f35  release/kernels/late.ccvtrace
e78e405835d33dff5d2d9043380e1f64bc864f373a1a5cafef413a2d1783266f  release/kernels/late.log
86084f6bd747a2cf32acbc0ebd96ebd3e4ef2d8d9e21be49e3ae49290d7927f3  release/kernels/late.oracle.jsonl
72c3a58bf6446f48c00d290c2f7e81a89e0050f9de0b8b19b30e8e1be35735ed  release/kernels/late.sv-hosted.log
913ecb5419d3b44c0913856b2ce8017f3779548b96ae4d8de4a916fb9b8a9a7a  release/kernels/ldpar.by_instr.json.gz
ab0a771b37ea2f654f03de495b9f4017bd5f12b9008f12c480f4877a03f7cc3d  release/kernels/ldpar.by_unit.json.gz
8595a89fd61743b14b53c46d151d81bfcd88d15c88695ca218fec5e2ad706746  release/kernels/ldpar.ccvtrace
3e6e4135b8389ed3768b461aae465ddbedd8efec05b2c372d64fe77096730d91  release/kernels/ldpar.log
8ac08538e9c807637babd61b31e340f7461878ada31f0c0b83cd66331cfaf486  release/kernels/ldpar.oracle.jsonl
3a5e007c463cee9bb30ce38c3feececb8be43bb0695f66ef8534188c8ad5f059  release/kernels/ldpar.sv-hosted.log
1580f3c2894ae56b97c9856283d7478bd3e85c82cf7ef55016c55e7fd2774cae  release/kernels/lnorm1.by_instr.json.gz
8d4766f310c6b0f99d41229678795c47bb0b4886ef245ccc4264c23b551e5d0c  release/kernels/lnorm1.by_unit.json.gz
019af8a07d22e9ba7212f0628cb10b7df12c8043c7a1bde63e7a7a7ff85b4e36  release/kernels/lnorm1.ccvtrace
1a647b0b0eadce600f80a1e446ec57e73e9ab22e1c33f97366f652d5b2466c5d  release/kernels/lnorm1.log
a8d85811af988a1b9fc00db1517300af3d93ec8e589e403d3b9113fa9e0ffc86  release/kernels/lnorm1.oracle.jsonl
bae01ea41aeead8eca6f2d2d8a11962ac23ba16a17730daed5b9085b35ed0cb5  release/kernels/lnorm1.sv-hosted.log
b4a92e78b0c0e095d5737a585097038286bf6937853dfd73bad29326e12fa091  release/kernels/localsp.by_instr.json.gz
949fb90fde523162f2a217f099c4e692b258f4d7e8a81e0efb588ac2d9c2cc3c  release/kernels/localsp.by_unit.json.gz
38184fb5cab0c4b1266021ba6a922bc81e601fa502682b6e23a027fbe9c50759  release/kernels/localsp.ccvtrace
32d5a644998c97ae739956a7f5c456db798b0119c2aed0b07db325404212bb9e  release/kernels/localsp.log
55e3c9f36e7f7d38c0ddd38903aff4bb4509ae862015c592e6b937ea258042ca  release/kernels/localsp.oracle.jsonl
626744b4f64f21eb6d212af961ca4131d6f020560ce22a18c2103dd3a3919541  release/kernels/localsp.sv-hosted.log
adf90b78c958bc35df8e722c67e6bc9837b3ff1b5fb69de9b338a7baed861c8b  release/kernels/loop.by_instr.json.gz
2dc94754365cee2d07b764167dd7c1a59c6e2adebb81ffbb195692c17ff04de4  release/kernels/loop.by_unit.json.gz
ee07ec54794c9a840d72c53d9e330914250276d534e42fbcac0f37434ec2897d  release/kernels/loop.ccvtrace
185de009ef38ea64b165a6fc6c14e8c958f050a995517496202c83cde85e7f91  release/kernels/loop.log
03ce5920c06c93e93516d8e53c3f7169f14e3593de204eacceffc0b8a3e32016  release/kernels/loop.oracle.jsonl
58c1e2df9b48d5429c26f8ff1cf08f3699e17d40ebed08f8ed588338dd8cc083  release/kernels/loop.sv-hosted.log
98f124c2f338dbbefbb2ff133f469a2a3c597aefa53fd6ce4fabb49e1491c4e3  release/kernels/merge.by_instr.json.gz
769406a3bceaa00971aecdc648020353ddc74f37da7f2565aaedb6efcb82d869  release/kernels/merge.by_unit.json.gz
f03b5b8724e00e74c9cb603221ebcb45271d5787fa8675d733085d71f8b0e307  release/kernels/merge.ccvtrace
f8d17ca3da5849bde321420f242c0d38da7622e0fcdb8502c9700bcb49d3d6f3  release/kernels/merge.log
f96d28815f8756b1f5a45ded53e6170883d2dfa10f9eef0d14b8050b1318164a  release/kernels/merge.oracle.jsonl
6e0bf65d5b21efc4dc12e6d5cb15796db261fa5a884e8d1beefb57cbfa075e62  release/kernels/merge.sv-hosted.log
0e13efc51d675d4f9c484e38ffd34bc30d48a8b29bb2d986f1e31f953ec7fe7b  release/kernels/missrun.by_instr.json.gz
6be8a08df166df6a82cfd6a7f0482ffbf0b13f07080beabb36f5335458338a8c  release/kernels/missrun.by_unit.json.gz
1f25502382ab70df5f849c555ceae405bb1339d095932ce00f1d5448d573593c  release/kernels/missrun.ccvtrace
aeae866bbba55da369e0922633309fe44a0049fc68fb8041213521dceef32bef  release/kernels/missrun.log
531bdaf281e5590774bd2775427f25e4cc0419cf8e3d5b6999843ffe9ef87258  release/kernels/missrun.oracle.jsonl
bfb209a8c7fa6396ebf7bd9f47fb7168c3bf814156b76645cca4352c3ec07da7  release/kernels/missrun.sv-hosted.log
0286bd5a54e04723415a2e1496a8b2ae428ab55a30405aca09346fbb1c432a5e  release/kernels/mload.by_instr.json.gz
6a89d9c3ea631a75f77a82abcc7ebb126bc52487d7843ee4230be8bdb4893f0a  release/kernels/mload.by_unit.json.gz
9fec8b9122e6e1293201cbc39b39ffa20f615df0f3e5df5e8ca3160af98f735b  release/kernels/mload.ccvtrace
9099d27f3567aac469d58e2cda4614cf82704f44659db51941c64760f4f36f44  release/kernels/mload.log
8000e477b9a95dfb9f0af964e8346acb9d36f1358fd06ffc4ff7cf599d2b8868  release/kernels/mload.oracle.jsonl
d3c3e265d8143008076b135e2cf69340cea585332295f2ab0b939505d42dea56  release/kernels/mload.sv-hosted.log
c51512d60830556aa4d6d680d6493b124e46746069650d0a56d36911c0f38d1c  release/kernels/mlp.by_instr.json.gz
66ad92ef5050cda3dcfa4edc646d61013e9a356591fcb0c1e05573c5f02e7cf6  release/kernels/mlp.by_unit.json.gz
efb84392c7d90847dd248fbce31bb95e9de05aed82f3f7defdd08c1806240d4c  release/kernels/mlp.ccvtrace
7cfb7d1c06bddcd1bebb1167bd6c6660d2ed3bf4d7cc23a01dc47f0d4c3caf79  release/kernels/mlp.log
138d282f88d56c8ad648a91af0a983254b55d9fa22942c00d47b327f516a6e44  release/kernels/mlp.oracle.jsonl
af5e8b88a3071e355060fb2dd0eda11861d049507006a117812a55255d3865e9  release/kernels/mlp.sv-hosted.log
ab84dd316429d85c97fc3635712fb2c0a774d034edcddc26fcff5bbb56d5f4b6  release/kernels/mwmiss.by_instr.json.gz
ff18bcdcae8c7541815633e1be994ea2e1ad29ecb74ad42d0271618e9fe6328b  release/kernels/mwmiss.by_unit.json.gz
3db6d9460bb9660ee4c47f2bbdaff9c3d4eea5a50f1fcc1fbf91f26cbabf7c6d  release/kernels/mwmiss.ccvtrace
270151e00848ed34edc207bcfd2f1da5fa3e2895e9c126ed21283b647c4d66cd  release/kernels/mwmiss.log
8abe8e8997456a2a6711ee72da54d854b24e20abbdab28e4b7271c0d28418de8  release/kernels/mwmiss.oracle.jsonl
e0ae920fda4da52306446b9c25535f629a7bb8ec889d895caa0e1431b8cf24cd  release/kernels/mwmiss.sv-hosted.log
994515aaa351097e3dddd2691a2a8acff5ec0a80548aa798f22d72f9321f272c  release/kernels/narrowadd.by_instr.json.gz
84951ff65f32e92e27295088203de9ecccb874fb3e58a95374cda07cde3d8e3e  release/kernels/narrowadd.by_unit.json.gz
0da3580e445e3dc3086036f036a2f12d1ceecb45e59e6f636a0fa3d822063028  release/kernels/narrowadd.ccvtrace
6a32a3576a92ed994a6cf77b0a337ba9b58b816b18b4782e203532d7c40d6145  release/kernels/narrowadd.log
40a2cf629853dd404bb06b4a07e35abde3d12efc13f26ffe28f923daf2994574  release/kernels/narrowadd.oracle.jsonl
2a7456a71093eef97d5ec4e8b7fdc87d36864de7f039cb04bf20d543d81fda1c  release/kernels/narrowadd.sv-hosted.log
cd883e5e1a3a72802560badd3a700419b7a3f8fd3aa3987a3c67b4849e9b98db  release/kernels/pguard.by_instr.json.gz
67b2ac242b2490f07df5b1ba4265d435bb57eda585012fd6400cd93561e567c3  release/kernels/pguard.by_unit.json.gz
d10835277946646e5c8525db1ab4eec371d368e8c7fd12edc30ec901d0d2f132  release/kernels/pguard.ccvtrace
e8f7bab52a4d41b10a8eeea5fbf91555a5ab551bba3432408e562a6808ea183a  release/kernels/pguard.log
690e56f1cb8d97cbf67124b7dff3ad0a90cb8981814cd1709cf0cd0e035b3bd9  release/kernels/pguard.oracle.jsonl
fc8e163652b74cfa12278ad9f347284737369f4c34223d81e032d6b65a366ee6  release/kernels/pguard.sv-hosted.log
024e4c503a429388a4bfe312369d424cfe7043904ed7d9e1f574c00e4e8ec23d  release/kernels/plog.by_instr.json.gz
7d6b2efded1ca554d5ace7fbc1d4f51db65eb699f165d8ca3e8f8f2d9018e5a7  release/kernels/plog.by_unit.json.gz
0663b3fde6247c0c7b78b17b23d9227b12815f9f48891e5bca5f06a7ad901776  release/kernels/plog.ccvtrace
cde64746d910ab39cec1ff6b736218cd460694a8624fdc8a03b8b54f478d279b  release/kernels/plog.log
c230f13f2e1082b306a9c5ab7809ff36cf5c1b2e47dca6b7a71f741524d403f5  release/kernels/plog.oracle.jsonl
affeeab5fce3efa8d8b03d5a13f6546e06debf707dc5bf6320be3cd095d2bbb9  release/kernels/plog.sv-hosted.log
d563421616886f74c84fec224648b582946f1a9fe4fabd22c693aa98f63926b0  release/kernels/predlane.by_instr.json.gz
e25206c3fcf0779d6b3255a6cef7b87681d2502494e6f54d1bf70727b1e01253  release/kernels/predlane.by_unit.json.gz
8ec769e2d14b44c63babe1399aa735b7687d413ecefcb80a0452e7670c3704d0  release/kernels/predlane.ccvtrace
1cb8ec30517a04f5d717d8797ce9ce1dd1c92580d1f87801eab0d037f9961614  release/kernels/predlane.log
c45f4177b9e84fc8a6e36b13534a0c7636eb30a3f8531847100ce5e23bf404b1  release/kernels/predlane.oracle.jsonl
e9a676f148838425b5e1da3b2e786a5e75d2792035d22f4aa7f8faea9d8ba33d  release/kernels/predlane.sv-hosted.log
319a429651f2aef826e14755c24ab029cf3cbaa32a7bffe0602c1128a6750b9d  release/kernels/predmerge.by_instr.json.gz
b54fc33d7967a4f5fc52a6ed0cfd1c2dd410f40bf7f36e44a7a3762b7735339e  release/kernels/predmerge.by_unit.json.gz
8e78231146cb13ab0fdb29f26b40dcab601f7b31a382ec2033ff796481c4dfac  release/kernels/predmerge.ccvtrace
ac6873d8042472952f98f914b7ad753ef71e651f9a1ac344ed8c66a8e22acfc9  release/kernels/predmerge.log
6c737c49434bcd08e3e0814c8b1dbf15c586ae74f7929ba3148ddcee2c62c845  release/kernels/predmerge.oracle.jsonl
6b22b61fc9a155ae18f85049808044c4063f8e6cd0538fb42a72b50947c4e357  release/kernels/predmerge.sv-hosted.log
b1477729a764b669fe2724c16b4c7710c74d1fd95bda3948a54167eb2b8f2484  release/kernels/predspill.by_instr.json.gz
6c4e3327ea19b864cde09e120d5b22a443e8da11a778e3ca22563c054cdb312f  release/kernels/predspill.by_unit.json.gz
9f371fa333bcf505ea9cc2ec86e551dc733bef9936ef4fab6ae6876d40451011  release/kernels/predspill.ccvtrace
67a09735d2d3341de2a1b0032c0c5d30349e38bc4d9595ac3c7868358bcbfdb7  release/kernels/predspill.log
b7c84c6478117ffa0f06da0e6ad1e4628e2683426a7911080810e78e06a5242e  release/kernels/predspill.oracle.jsonl
e95d02a3c9e573a49c92a514f73ac85de69561ba59171c244f96b7f100ff0a22  release/kernels/predspill.sv-hosted.log
623f45ee6a6dbc0a04cb04774618105f8febd5eb083f34b81bd653adaec5c4cf  release/kernels/predswap.by_instr.json.gz
a9316bbc5210ec7ce2ef22caccef114e4224bca0ef2537849fe280647057a9b1  release/kernels/predswap.by_unit.json.gz
988f5a4b9a8b88a35190baad05027e1f08f158a0b709112528172f222d83af9a  release/kernels/predswap.ccvtrace
886a3021139144176557fc372d3287f9707b62f18a62de3dbc02b081504428ce  release/kernels/predswap.log
a6d4f7ed517553816d889c7c9eeb6bcfd1f6c973fbf682ecb69f3c2de619f7bb  release/kernels/predswap.oracle.jsonl
873d4dd97f9729e2c2087f0fd1b103fd3b90076be7ade7009977ad140513a153  release/kernels/predswap.sv-hosted.log
a1fc8befbf934232738a2c170eaaef947d48f27fbcc9de98f02e9fc45af67466  release/kernels/privwin.by_instr.json.gz
bb588b2ed082e8ee5621f652b010981173dc7b8bb7a62c4578ac793271213129  release/kernels/privwin.by_unit.json.gz
3dcf0f452ec3b2ad6799a5e1870997019801731102ecb60a9341b0bcbbdb4ade  release/kernels/privwin.ccvtrace
42fd8262ee50eadfea18d8add8570c8a694b69be9e3abe1c94cb8de6c13050b4  release/kernels/privwin.log
861f686fc4480363472908d679d8815e8c957d768e7ab32c826930527b0fb7a8  release/kernels/privwin.oracle.jsonl
cc4db2f6611bb7f0e75d36d8a49eed62fa4d9439073cc95fe667aad55f835ee5  release/kernels/privwin.sv-hosted.log
49fbf56094332b507dbcf55ac8a14438dc2ade309fbdadff1ee58dbb2b486855  release/kernels/provswap.by_instr.json.gz
3280c64e305138cfea73b52272bf8c3601ea6064c96b0ec08aae82fcf42e050f  release/kernels/provswap.by_unit.json.gz
92b0741cdaad6c91b35c6c14b37c96eccfa1dce4f3761cddd499c258d503ed70  release/kernels/provswap.ccvtrace
911ac0cb48dabee2e48408a2e744f3cd0a5f1366879a95ca0f8368b7f080f03f  release/kernels/provswap.log
c9c32a793d54cc7401477f582487f7e8b345b2669a75337b8d6327120d98e5dc  release/kernels/provswap.oracle.jsonl
81145d922914db9f9550b0ac74fc0d1f8090d6001b7b49ee9a092c90ae6bd70c  release/kernels/provswap.sv-hosted.log
3deec25603f4678ecd60db614c346c0962673ab15e8d542da773a8c9439f64b5  release/kernels/roconst.by_instr.json
2a50edcbd759185f72fc91862bb229331434c4521c249a516f376ff01cd05b97  release/kernels/roconst.by_unit.json
70c8714a871ccdbe32b451e084397362b6f285aaa37b7e1f3057d5f90dc725fa  release/kernels/roconst.ccvtrace
eb9ed3f3498a72dbce0287767d192fa90e177b792900cabd8f5ad09394f906db  release/kernels/roconst.log
8087c0671de620162881aecd38cd6114b78e7be6bd71201e3ec02c9a2e2e750e  release/kernels/roconst.oracle.jsonl
675540a696992b94ad890fa103ce43c79c43c02b6bb97120d991fe5911e2ac5b  release/kernels/roconst.sv-hosted.log
56a1d9013480dd49d461e1d7eed5cd42d906f5b4c7f657d138058e0b72085132  release/kernels/rogated.by_instr.json
e8cf23e03ad7151135b66b8db34abe4f2abf161ebb79584766e1551dd555e62c  release/kernels/rogated.by_unit.json.gz
f90fd058de33e49e135c8e983485a2a15c6e14130c3f06cd3c5da95a51871c0d  release/kernels/rogated.ccvtrace
af1747c724f6daedcee8e44b309a394d8aaa68d2fc3cde03a431e16c99461829  release/kernels/rogated.log
7cd02bd4cceec5a044d6b4d6a80df1e68ed0ae71b0b2a953143636d5b809ea6c  release/kernels/rogated.oracle.jsonl
13d4c2fd59eafbb060584671dc4abe72068853d230e88d51cf2936b0df1fcb99  release/kernels/rogated.sv-hosted.log
7bed342fa741e3b3ed49761737209b6aa47227ca538dbafd035c73a827ac9334  release/kernels/rokill.by_instr.json.gz
e9df6740110bed621eb3b01297020f7ed82030ceb061a0de1ef6fa6422e85a36  release/kernels/rokill.by_unit.json.gz
633c443593e1971bb2142a24e698ee7af986ab12b3e6688430a8995be0df3a4b  release/kernels/rokill.ccvtrace
3b511ba7a6aa9a955b81a78c22a7c0e54652f11cb5a4da9a6c3c241a4afc15a6  release/kernels/rokill.log
94efcef96af469a512d346ce61623980fe86383188eaebd55120f716db596f14  release/kernels/rokill.oracle.jsonl
9ca96052092d6c6538d669b9f175b18de42f5036fed9ac577148132215193a10  release/kernels/rokill.sv-hosted.log
3fcc245491973c3a5f2c2381fe40befa68cac75951bb61a37828ad002f5e5c3f  release/kernels/rolaunch.by_instr.json
c6e03215507cac2dc6fc62be8fe152a55cdc9d3d0ee6787002406efee4d8a4f2  release/kernels/rolaunch.by_unit.json
b4dd2dc854bda367aa808413c5b8fed0ca0854268c3716fff7cbe1ba3c1c0ddf  release/kernels/rolaunch.ccvtrace
0655cff219a34da53f691c62d67e0d5a1534c79d593d1a70ac106d8e09988c27  release/kernels/rolaunch.log
e7dad585c3e70615de04330fd03f4f282c29a005dc1732a35655fb261d51139e  release/kernels/rolaunch.oracle.jsonl
f1d27169757acef5f04579310abd24768633fa8c4ac1cbbb3ca6c34361846274  release/kernels/rolaunch.sv-hosted.log
3deec25603f4678ecd60db614c346c0962673ab15e8d542da773a8c9439f64b5  release/kernels/rolimit.by_instr.json
b8e5135eade5114a9ab5bb645d085744e17b63e5da86da36a10d912b2422e875  release/kernels/rolimit.by_unit.json
aca523a99aadf608795952b24add4be71849a9d8e1fe0f394bce73d168d5bd4d  release/kernels/rolimit.ccvtrace
77407a923cd14faf9efaa7fe990b2bd844872a3a1a25b654c62e84b32e8d6734  release/kernels/rolimit.log
1c5bc0cb8e8b2e69505fb5a551a16d5d10c56f232b88da7a27e336ad7d962de2  release/kernels/rolimit.oracle.jsonl
1f7833b0cab9e7358eb977da8a11111829722712041e354eb4854c741ad98116  release/kernels/rolimit.sv-hosted.log
4e8bf48ba8254e4dc88e8f825472195827076e987f10fa3862b494f61a1345fc  release/kernels/roload.by_instr.json.gz
310c018acb85331528bbf24d9b03ebbdddd8bca5a9d04a95cac1980d33b10672  release/kernels/roload.by_unit.json.gz
960103e5efe7da29a60f461e6e5f1ca3ec6a8e47b573f50f1af14e025e33ffda  release/kernels/roload.ccvtrace
9602b313459715ce29b3e216b062add2645670f18db21b1c54690746e09324d8  release/kernels/roload.log
f7c1309cc9764769fb5803f6fd0f2f5e1eb418f2d23fbe5e17cf5f9106869fdf  release/kernels/roload.oracle.jsonl
19bd64c76e593116a7f13ce32099bbff3220ad3d8912db3cca93b9fa494ab008  release/kernels/roload.sv-hosted.log
24e424b8253bff1304123e8d81fb2faefa69b510906a28be203001224f0424c0  release/kernels/rope.by_instr.json.gz
e55a5c3145dd08d7c9f171bfcb94725b49c86fbaf8591179066eb7eac1af0c90  release/kernels/rope.by_unit.json.gz
5b88619693e1b5fe8046438fe6bd5c5a31e78a2da419ee1a9bef2a15f548ddec  release/kernels/rope.ccvtrace
d61225b791d581568a356e74fc17470972be9e0c4656053b3a6f05454f2e52ec  release/kernels/rope.log
d55f9efae392dc8877c102c01c0810e7654b666b6ede386328108164c6cf88f3  release/kernels/rope.oracle.jsonl
3c94d96400b3cd16d7384f6ecce2649c793d8012749da3240ef5e611f091108e  release/kernels/rope.sv-hosted.log
c3bc52de94e1b71ac6b21a1da128ba044a3e86d91059c680225b7876d28b6019  release/kernels/ropediv.by_instr.json.gz
081f485d21215495937109bef02a2f87ce4cb816ce624296deca40fa2739f90c  release/kernels/ropediv.by_unit.json.gz
6045202e0daec9fa1788442b62ea687f073701171d39d5da1fc84a14f42f0698  release/kernels/ropediv.ccvtrace
d2c5c8333210649ff8aaa0832540daa3efededa5802958424838d086ce576686  release/kernels/ropediv.log
10c0ec6ec18b7b44638c790033109198c079d07c1537bf193353ccedd00a920f  release/kernels/ropediv.oracle.jsonl
97c8a3b936b6fc91928bbf9b978c4a53f7e6f5ca22ac6cbd6a0e52fcc72095ed  release/kernels/ropediv.sv-hosted.log
292653935814709b38b9b85770ec3539fec168e87867ffef0810a5330c039f6f  release/kernels/sel.by_instr.json.gz
890463e96cb1fb088b516ad1a7fb3a7bb469b97c1b1689c32858094b5941de50  release/kernels/sel.by_unit.json.gz
513bff50a3b9d1f25156aee2aa31bd9f0aebdfded39e1b819d56577fc9ee8c68  release/kernels/sel.ccvtrace
2ffff753751a9f25a6d5f4ed8905ade2ac2da89b9c661e8c359cc64bc84af1b4  release/kernels/sel.log
87f6a81e8afa004c8039bf2f61c90176fcf29ab29bb17ac44aa016a5cc8438fe  release/kernels/sel.oracle.jsonl
aa4f0dca2a9397c96407781d79241c74975ed185e956c6a01fc9d03595b3630b  release/kernels/sel.sv-hosted.log
f8772ee7c2a74a026977be721d6e0bde82d24acc43b0de3203baf866dc289a42  release/kernels/sized.by_instr.json.gz
47fbea73804ca3b5c31858209e514e19edcb019126570d2d66c0112d46cb1d4a  release/kernels/sized.by_unit.json.gz
a42720ce662969b08724bafe0b0a56cf6723624aa37728b92f4e54868f9b33bb  release/kernels/sized.ccvtrace
8fc106e9a439e79c9dcfa643929482e04109c6a2d9e2530b65a6de918fb7780d  release/kernels/sized.log
36d903ba1618bd1faa437c9812a6ee6c0c966a63196c796267d74bf2695ebc3d  release/kernels/sized.oracle.jsonl
73ba16443e40e567f86b58d5e5c011e5bbd1daf4a792ae216632fe5f68a50040  release/kernels/sized.sv-hosted.log
e3f752ed045e012a4e6665e11e4ae9b14225aa3d1e1d538660a33378a874dd0b  release/kernels/slotform.by_instr.json.gz
205637a9d35222f48788d29d500f95c7f9b20886fc2910c4a6db07b59e855de7  release/kernels/slotform.by_unit.json.gz
203c4ca7b8ebb213247d154049a8ee95ef5073fe218313b20d4ec4f60f539c29  release/kernels/slotform.ccvtrace
2a8657d3bfff91176ebfc4fdd18aa6cc529d8fcb93ce6e0b10d1a8f3c0d4f629  release/kernels/slotform.log
8b61db7419b18cea8a646fb628218447e72e84a18a9891ffb73b441736138ab9  release/kernels/slotform.oracle.jsonl
ed8af8a6cfbe63fdd5f02045acbe2f3668093a9fa8b2517abf855256aacf2dc1  release/kernels/slotform.sv-hosted.log
0bba6bbfe07c0e5529184d26f271fa2e46ab162916df091721792c78b9c5092b  release/kernels/spinwait.by_instr.json.gz
722e7a0136b845ae4c5b03e67cac69998e28d79c81c72a6b4bc1ece1a92aae09  release/kernels/spinwait.by_unit.json.gz
f25715d6119729a6e098f2fe794cd6ae9df44be652ae647465f69b6f26cd4621  release/kernels/spinwait.ccvtrace
47a11ecf899c2180ce2f36740bfd49afc8c54bf0737ca08d8b3caec678c950a7  release/kernels/spinwait.log
868920637236c878b33779bd450439466fc3626996a3164573dc11d437d5c709  release/kernels/spinwait.oracle.jsonl
4ecf35b19d71b681c3b7c1b140029e1269db6b503c2edd655c33d72930a1ca9c  release/kernels/spinwait.sv-hosted.log
a12831b2e1b58ab9e8a7bbb31f049de3ed015049a87afca024f65f9c997fe0c0  release/kernels/spmbank.by_instr.json.gz
eb317c6b6e96efe84cd6bfc5e3d9912f23338d5765d0eab56633e8ae9ed92ffa  release/kernels/spmbank.by_unit.json.gz
39672a44aa542e5b9767367b822dc9521e3027107de485be10a88f60b434b80d  release/kernels/spmbank.ccvtrace
761bb1e0c7d7df7629144f445c4200b04adb61be28b6d7aa58e705ab8316ab8a  release/kernels/spmbank.log
3af490cc37d7a92dbe719b57de216b648536eb301ff9d13de9a39f50d150d725  release/kernels/spmbank.oracle.jsonl
b4e7044a6a43f01b0e5dcc8087cdd279ea0b43a953b5dd9b43aae7068f2c1c10  release/kernels/spmbank.sv-hosted.log
2ee81a022e30fa1471aa71ff208609124813a23eb5a55646794236e326932c66  release/kernels/srd.by_instr.json.gz
6fb5a44aa4d5e20175237d124419eb26857d1c5ffcdcd36485d36923136640a3  release/kernels/srd.by_unit.json.gz
55571873a8edbf1842b885de5576dd16a2db3e96874611acf35ac479f17bb607  release/kernels/srd.ccvtrace
7deac1f8f9838907e6a6f3870753c7335c6201e78fb87421f03a6b74dad0e4fb  release/kernels/srd.log
b08eb5e3673cac7eebb8b72af5ed3783c8e70a9e96592e76bf3722551bc79473  release/kernels/srd.oracle.jsonl
e194168408eef9498f03c87f25ad382898a860fd50b59b4e03b8439d15ccf39f  release/kernels/srd.sv-hosted.log
fe5688d6156f8b615a010a4acb10e4a065315cdc8343442f9c2709b2295cda14  release/kernels/stall.by_instr.json.gz
24a12a35baa680530c5b8ff95e9cd448c33d5fef7f06ce231c0756d7b9ad237f  release/kernels/stall.by_unit.json.gz
0b42dce13b3a8101a3aa6898554badcff147a1692c257b9898b40f6bac8611e1  release/kernels/stall.ccvtrace
6254c1624e80252aafdbe7e776953583ac0bad2195c5d615509e1edfddf36600  release/kernels/stall.log
500db2c482b07a0706583422cd68878301d0146c1f872ccc1f11bfdcf5c993ef  release/kernels/stall.oracle.jsonl
213ec31708ba61c2cda171db73eeaf4378a7ff8ef13a2bb5ed04536844707336  release/kernels/stall.sv-hosted.log
0ab201e6482c204383ee28dda26fb21439269c063d9ba63ebcbc549bd11f96d7  release/kernels/swap.by_instr.json.gz
58a4e3fd15a2dd85c31ff1f1417e8ae082380f335285fe8b7ea50a22c37f25c7  release/kernels/swap.by_unit.json.gz
82916c2de51772fb0d96433fedfe26432355f19f5f8a17a673c92f2e9b474688  release/kernels/swap.ccvtrace
325dd5d3ae702a740cc903bf0589707a2835b952bf851fd01c01dfd74abea113  release/kernels/swap.log
3658a26316c1ff7bc1744304a42f736e930fcde2865c8913e6cc67a22ce96667  release/kernels/swap.oracle.jsonl
e7ace2d031ffcb189a580c461f25c32e23ac402d998fd63458e353d92d3b27d1  release/kernels/swap.sv-hosted.log
a9572aafb73bcfb18a1bd6c9fc176741a6b2898ef3d911a448ca6ea5e3463799  release/kernels/transp4.by_instr.json.gz
4cf01ac1eba478bfa3fbdce750ba1ca7d610e24ca6c569b2d76631572fcf0495  release/kernels/transp4.by_unit.json.gz
53590f542ba44ea6dc9c94fbecd2fe31a3ae60149434bbe2bb58e0bdbe1d80be  release/kernels/transp4.ccvtrace
52a92d0532edea2b7182b3007c53d0ba464afac070fa4da4a1e401b82ac80777  release/kernels/transp4.log
06396ace3ac19677fd39c700e408606e5bdbacb24997d663bbe8872e63dd74fc  release/kernels/transp4.oracle.jsonl
293aceb7757ee4422c13ee3e9f8b2190ca3a92c050252d747cedfb9e3d335b30  release/kernels/transp4.sv-hosted.log
f8664df710de33ac372d57cec0213f2380e49be55507b038c7d844cd5965ff0d  release/kernels/unal.by_instr.json.gz
32c44f740c29227f398624cc1f5494d17921bb5c19ff4f95b5ac51ff36d67259  release/kernels/unal.by_unit.json.gz
7ceed4ab7208c7f77607806d0a2b1909e45ed6cf7b840306bf2052f85cb5cd6e  release/kernels/unal.ccvtrace
5e819dec65b50673ac6121fce6719df4d88be72143e4b9f144c9689b5e729f55  release/kernels/unal.log
c3d484bb160657a563df983d9a2532eac27f556636617960aa1e72183ac2b299  release/kernels/unal.oracle.jsonl
57620b7e8a97f48beaf2935abee8ebc6b1fb89d96293a32e9a2f08a6d3b48502  release/kernels/unal.sv-hosted.log
56e267c53af8e6d8b46411cc27985a448f3633c60afe046de6c4754fc05e57c9  release/kernels/vadd.by_instr.json.gz
e51ba250c3e2b7a94ab7fa403741720f50dee1b90aaee1cd991553bd96b90158  release/kernels/vadd.by_unit.json.gz
b467c16235a8a0e24f05e4b4f5e91b04db89f9e360b2d8d88f3a810baf69665c  release/kernels/vadd.ccvtrace
ad45d6e6d0e07bc73d3bb634c9d44b7b2de3af3d6c5aeedb6dca3f1866694ad2  release/kernels/vadd.log
0276b6d0611a4bbcdc004ab3987214aea138245bc7217504147331689a9c0880  release/kernels/vadd.oracle.jsonl
64efb60141f2d259a8ae23c779f951180d0682dfd2dc0224a62ec19b17649809  release/kernels/vadd.sv-hosted.log
ddeed28bc5551bf5d30047fc7ed09d9f80357a16466e02eb1dd186c6a62b8b76  release/kernels/vadd4.by_instr.json.gz
3b1637818dc361d3132e4b538539f6f81f3f445368ddd8e2e1a33a551bb6826f  release/kernels/vadd4.by_unit.json.gz
2a33f945ca94e70fb777a477eb459771efa459a1d0741f96804a6e6b4c6a0893  release/kernels/vadd4.ccvtrace
20e9ba1ae61b40c45ec387ec0f9964ba3bf8b03dc535ee570be9881cf621d6eb  release/kernels/vadd4.log
225aa18fc9f38aa9ad615aa11de254337d59fa705877553d873062c68366e0db  release/kernels/vadd4.oracle.jsonl
438e8c46e9ad81d908e91962facac73897f702b9c5a95ea2b5357053cc58c267  release/kernels/vadd4.sv-hosted.log
696faae00e92638d66887f43c6cbea6b89ad7fe952b0707a647abb3e999dd036  release/kernels/vaddslow.by_instr.json.gz
6272c1668cf095f8538ab938403d550b1c4ad00e4c5562e0aa4c79cc8807a79c  release/kernels/vaddslow.by_unit.json.gz
461404eda15bc435b700eb5c8b52f290bcf08cb999e5752cdf7f89fc9b66e690  release/kernels/vaddslow.ccvtrace
5fb43ad1d163320b67b762ac98f83d174ac56c3f189e3593e7780bc84f061ba2  release/kernels/vaddslow.log
e9e6218e8b8450e9f9ff6b39d659c994a1e51c527a0c5bd10d18b5658ae0e344  release/kernels/vaddslow.oracle.jsonl
fee06b31162961fb40a097e7f15f3efe524095e4dbbbf4903f3783c1ca92eb19  release/kernels/vaddslow.sv-hosted.log
fa89e2df7998f54080d2293805945706626b0840d37438e8343a9383ccef02d5  release/verify.log
1f3a2eff14dbda0754e19cbf72bc5003c950fc7d1691d527ce3a8d427fb583d7  release/wiring.txt
```
