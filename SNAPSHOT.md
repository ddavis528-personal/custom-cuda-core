# Snapshot snapshot-2026-11-01-1afee59

**A generated, read-only snapshot. Do not edit or merge it.** The source
is `ti-ret` at `1afee5975de1757aef5b06f0ea08e7da2d378381`, and this branch is rebuilt from source by
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
| Source | `ti-ret` @ `1afee5975de1757aef5b06f0ea08e7da2d378381` |
| Built | 2026-11-01 (UTC) |
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
| `lnorm1` | `name=lnorm1 finished=1 cycles=2593 from_fetch=2562 retired=526 issue_groups=526 order=ok gpr_mismatch=0 pred_mismatch=0 mem_mismatch=0 check_failures=0 class_violations=0 overflows=0 credit_leaks=0 channels_used=37/55 violations=0` |
| `localsp` | `name=localsp finished=1 cycles=4238 from_fetch=4207 retired=40 issue_groups=40 order=ok gpr_mismatch=0 pred_mismatch=0 mem_mismatch=0 check_failures=0 class_violations=0 overflows=0 credit_leaks=0 channels_used=32/55 violations=0` |
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
| `privwin` | `name=privwin finished=1 cycles=2215 from_fetch=2184 retired=52 issue_groups=52 order=ok gpr_mismatch=0 pred_mismatch=0 mem_mismatch=0 check_failures=0 class_violations=0 overflows=0 credit_leaks=0 channels_used=34/55 violations=0` |
| `provswap` | `name=provswap finished=1 cycles=2325 from_fetch=2294 retired=978 issue_groups=978 order=ok gpr_mismatch=0 pred_mismatch=0 mem_mismatch=0 check_failures=0 class_violations=0 overflows=0 credit_leaks=0 channels_used=33/55 violations=0` |
| `roconst` | `name=roconst finished=1 cycles=64 from_fetch=33 retired=4 issue_groups=5 order=ok gpr_mismatch=0 pred_mismatch=0 mem_mismatch=0 check_failures=0 class_violations=0 overflows=0 credit_leaks=0 channels_used=26/55 violations=0` |
| `rogated` | `name=rogated finished=1 cycles=84 from_fetch=53 retired=7 issue_groups=8 order=ok gpr_mismatch=0 pred_mismatch=0 mem_mismatch=0 check_failures=0 class_violations=0 overflows=0 credit_leaks=0 channels_used=26/55 violations=0` |
| `rokill` | `name=rokill finished=1 cycles=93 from_fetch=62 retired=41 issue_groups=4536 order=ok gpr_mismatch=0 pred_mismatch=0 mem_mismatch=0 check_failures=0 class_violations=0 overflows=0 credit_leaks=0 channels_used=27/55 violations=0` |
| `rolaunch` | `name=rolaunch finished=1 cycles=62 from_fetch=31 retired=4 issue_groups=5 order=ok gpr_mismatch=0 pred_mismatch=0 mem_mismatch=0 check_failures=0 class_violations=0 overflows=0 credit_leaks=0 channels_used=24/55 violations=0` |
| `rolimit` | `name=rolimit finished=1 cycles=64 from_fetch=33 retired=4 issue_groups=5 order=ok gpr_mismatch=0 pred_mismatch=0 mem_mismatch=0 check_failures=0 class_violations=0 overflows=0 credit_leaks=0 channels_used=26/55 violations=0` |
| `roload` | `name=roload finished=1 cycles=106 from_fetch=75 retired=8 issue_groups=8 order=ok gpr_mismatch=0 pred_mismatch=0 mem_mismatch=0 check_failures=0 class_violations=0 overflows=0 credit_leaks=0 channels_used=31/55 violations=0` |
| `rope` | `name=rope finished=1 cycles=7757 from_fetch=7726 retired=354 issue_groups=354 order=ok gpr_mismatch=0 pred_mismatch=0 mem_mismatch=0 check_failures=0 class_violations=0 overflows=0 credit_leaks=0 channels_used=34/55 violations=0` |
| `ropediv` | `name=ropediv finished=1 cycles=1121 from_fetch=1090 retired=203 issue_groups=203 order=ok gpr_mismatch=0 pred_mismatch=0 mem_mismatch=0 check_failures=0 class_violations=0 overflows=0 credit_leaks=0 channels_used=34/55 violations=0` |
| `sel` | `name=sel finished=1 cycles=76 from_fetch=45 retired=8 issue_groups=8 order=ok gpr_mismatch=0 pred_mismatch=0 mem_mismatch=0 check_failures=0 class_violations=0 overflows=0 credit_leaks=0 channels_used=29/55 violations=0` |
| `sized` | `name=sized finished=1 cycles=2641 from_fetch=2610 retired=25 issue_groups=25 order=ok gpr_mismatch=0 pred_mismatch=0 mem_mismatch=0 check_failures=0 class_violations=0 overflows=0 credit_leaks=0 channels_used=32/55 violations=0` |
| `slotform` | `name=slotform finished=1 cycles=4365 from_fetch=4334 retired=12 issue_groups=12 order=ok gpr_mismatch=0 pred_mismatch=0 mem_mismatch=0 check_failures=0 class_violations=0 overflows=0 credit_leaks=0 channels_used=32/55 violations=0` |
| `spinwait` | `name=spinwait finished=1 cycles=2180 from_fetch=2149 retired=211 issue_groups=211 order=ok gpr_mismatch=0 pred_mismatch=0 mem_mismatch=0 check_failures=0 class_violations=0 overflows=0 credit_leaks=0 channels_used=34/55 violations=0` |
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
641b52187379e834b0ff2a92359a78975abd63b0da0d16fc75f54f46b869947e  release/kernels/addrhigh.by_instr.json.gz
84fad3dacfc555f00620811f39d601e99e9c035dae8b8c456f35a125d4a01010  release/kernels/addrhigh.by_unit.json.gz
163af1503f2683466e244d0ab6b60fb98af5082e75b6031e1c371b28d213a152  release/kernels/addrhigh.ccvtrace
ff1a566fb8e68d676754999a9b737d08893c2e3e825bd77ebabd7cd069d50d18  release/kernels/addrhigh.log
569f2e22883fad5f0956c57ec734e6afbdd4b8a854e50277425172d6c0cbd766  release/kernels/addrhigh.oracle.jsonl
2aae6dccbbca5b1ab32135b9cb11f2c6a3c691b6d6f54931309850cc791b9bc2  release/kernels/addrhigh.sv-hosted.log
28dc69325fbf2e934fd86658223b48a8cb92053952c06eb87d3d34b4706decbc  release/kernels/addrlimit.by_instr.json
f6461e7e8081e79750a0a358ce2ee174a0174a909ffc7998aa7542e4f963d0bf  release/kernels/addrlimit.by_unit.json
d0275ae1473e1f86fd56e1553d6e6cb67f83eb67dc23e27159a63e3cf3f3f0fa  release/kernels/addrlimit.ccvtrace
3f89a5d2e6430edac81b5b5b379b38a8917d1f6b297be15bade8355f5e6b2134  release/kernels/addrlimit.log
bc660b0b40359a2c5a2478cb0eb4950b73fd22db50ea76b80052bc195a1920f4  release/kernels/addrlimit.oracle.jsonl
dd9e437c171ea4b12993ff7a936c4d7373c7524954d5b691925c982fbbb2163b  release/kernels/addrlimit.sv-hosted.log
002eb9f49b1db791a8001012fccd9f16bd62772dd9f663bd1a841e07061ce16c  release/kernels/addrneg.by_instr.json
ada96822553635b5282a2fb7c64ddaf92933ad7c066099ad0dd4205e98f8b381  release/kernels/addrneg.by_unit.json
5cb0374d21bf1240216d039ca378d384e50df24c7c9a4dd00b14448e75084b34  release/kernels/addrneg.ccvtrace
7bb437c6e4c3deb1676dbcc5bc81fea0a87bd56f500bd98fdbeeb67e565062af  release/kernels/addrneg.log
16f5b0707ae44492a1efd67bb9dd38a7e79a7bbd354fa9207b9e7d150ff2f107  release/kernels/addrneg.oracle.jsonl
fe5085c4c15fe38c147e40c35a42889653c0f4f8ef757eda696fb2aaeab6cb95  release/kernels/addrneg.sv-hosted.log
e14a9c5b02489c92e94530234fbcaa211d867471fd329e7908682e5a018909b8  release/kernels/borrow.by_instr.json.gz
acf297d59904a8ea5af188350468486f400f999f07a760b4336fdaa48c8d8238  release/kernels/borrow.by_unit.json.gz
10e9bfea858aba4bab8d5aaf2bad10e3af61da1cd5eafe1a2fab60c0932a4746  release/kernels/borrow.ccvtrace
e54c1cce9f8f2c8f6d7f701ea694634d992a92081ee73c0ae02deeb3be3fc549  release/kernels/borrow.log
4c565e1ce0b3baee36e158694b32c8defb5cd662b2f9af75cb5d8c26cb1168ed  release/kernels/borrow.oracle.jsonl
e09e657a2facd789099903e9baa533b8f9f3558c5501630e14bbfff769b3fca3  release/kernels/borrow.sv-hosted.log
78f13b9984ef192514908374455d79498a61abe23f86b8b1397e9150fa9f6c2a  release/kernels/brs.by_instr.json.gz
0033daf2f0974fc5f51f2ad82f7f65df9e5dc022a7b48fce1d13ece2b7815ccc  release/kernels/brs.by_unit.json.gz
a522dd52d4c708a8c4fdfab4c38de4bab59654de14cef5102ca0de7e13f56996  release/kernels/brs.ccvtrace
fcd91700239fdbd9dac9df127805106f37578b60b328c703bdbf84797f9d4eda  release/kernels/brs.log
e3c1cb3379580cf1aae44e8ddc8e846ef6fd661a573cfe0a8d4444b18a14dc56  release/kernels/brs.oracle.jsonl
d2066937e9b4035c738719908d46cab1dc5f78bbd5b860bf54574a8253621d31  release/kernels/brs.sv-hosted.log
edd2e320d3cc06d3daf1f6b18ea72d0b101fdf61981f8158d9736fa97f54b9ce  release/kernels/byp.by_instr.json.gz
a3d5f43430e3308fade67fafda94b69d841dc741858b37496ff4a4090e6203d4  release/kernels/byp.by_unit.json.gz
d9e50451c8e050a7a82027bee3b9315ce295f1c108b0528a92806d82c570f9fa  release/kernels/byp.ccvtrace
89be1bd58b45079ce4e0e6a1d709319c7d3feebfcb5c45e188bae1388282002d  release/kernels/byp.log
5a03dfa4f3603fef49f1e3639e74e34152ca3ca5ef8e41eb959f8323040fa2d5  release/kernels/byp.oracle.jsonl
bb231ab352f6bc8730eb6baed75dda27c3d000f81d774cd047c6a1a9b5a262b1  release/kernels/byp.sv-hosted.log
9da7c51646acff0854c4c16e234a3b091c57d726c3c0fafc29ec4436bedbb97e  release/kernels/callret.by_instr.json.gz
36e777fb40ebd0d5702fbbc00bbb67e1632e9e0ea80c2006cea351b57f5e2962  release/kernels/callret.by_unit.json.gz
e96a669fee9fd01b5662e405f6c00da59f25b07d1e0c4a5d7dba482b7fa7f6fb  release/kernels/callret.ccvtrace
7b6c500e44fef5f267b9ac4820a2c51d8f8ada16857564496544356825aea323  release/kernels/callret.log
9b1d1b50b527f732362f837250aa2f26dabf3e76e16a4794856ebd8f105635b8  release/kernels/callret.oracle.jsonl
acb49a4f86ae989bb141ac40c3fbb127be3415612f2cb063367ec675d5f090d9  release/kernels/callret.sv-hosted.log
2874f1091ba0ae8be9ad36b2c897e81ce6876d4909b864aaa1542f88483111c6  release/kernels/chains.by_instr.json.gz
e079825b319e86d2c8552498ccd97158976e31591b082f855fa20f367f2eea7b  release/kernels/chains.by_unit.json.gz
1401a8d67d4dddab91ed5ca7fbf0938b6d8c66b81b82ee852b2674ff0d00d866  release/kernels/chains.ccvtrace
9b998cf0ec83a7105cadaadf149b69ed4b3d32ef38d58ebeba51d579f9f65627  release/kernels/chains.log
26a4cc5c5524c7219d8706c2582c80357dea60be9d6ffdec99dac7d0365e2264  release/kernels/chains.oracle.jsonl
9d22486caf4faa21ff04a78686ab2d1aa7cfc4d743d79290e971ac3e354a925a  release/kernels/chains.sv-hosted.log
e6db1fdb2e8f8adfc8ffaeb8e95a09c3858a0d96f9e48604b0f2b890eaa8d599  release/kernels/div.by_instr.json.gz
83b25d7c8476d0e62fdb93b4807bd13e8dc3482cfcd9bf0d2d363eff63666769  release/kernels/div.by_unit.json.gz
ee11b37decec689a911f4ed19182bb5a356342366d938898e92a1061c7f84e62  release/kernels/div.ccvtrace
5bf8eaaccf348078a86d6c6b2045f6d7ea8695e7df12b885e1151d5b619f0d5a  release/kernels/div.log
71a567b85cf85622631490187563de9a5661099c78a590adff4ed0a0c3d24c16  release/kernels/div.oracle.jsonl
cb30dff0871dd683ad168e1cc0ea13d7596040c1ad175ffc1596da62def01761  release/kernels/div.sv-hosted.log
8b87458e3a8b6a66a4d83857b5ea13d2f349f1f445d601b6ff2756748a3babd1  release/kernels/divchw.by_instr.json.gz
ec7db2c2d19880aed377fcb6af8a912b77e419ae0052e1bf68a935b3012eec8d  release/kernels/divchw.by_unit.json.gz
6bde74c71dff4c98bf6bb8d6d6cdd5efcfe70f43fa6df822c6aceef89fb74784  release/kernels/divchw.ccvtrace
5b92766896f7f7ab5e314fb4c836a98f3fede3ab882917d95eddde354efc82d0  release/kernels/divchw.log
58a541797f7a2df0a1c7528ae6a3edec212db90c7d3eb20656806f38b5c10b3d  release/kernels/divchw.oracle.jsonl
654fd0136ac56c05ab88f125b63951c9fb1c4996b113fd1b8f77662a08f2cd57  release/kernels/divchw.sv-hosted.log
e204d29eae266af492645c1989d1ae9e637704ed66f84e670d4ba4abaa34a3ec  release/kernels/divtail.by_instr.json.gz
3e8a92074b860928dc569fcfd4c7b9ee3358cf58f9e3233604d39030d6020bd7  release/kernels/divtail.by_unit.json.gz
2bcba39707c6ad21ae3cbd0bb513d9bcf68d91cd1fa4a0d4ed8ed98ab1e9ed33  release/kernels/divtail.ccvtrace
c8fbb86ee156f3eba03a118ff281bbbee67380ccb51501623b9377b4fe61beb5  release/kernels/divtail.log
75f11a75c9b3b336e446140af4579f05b46c363a76b7aab3ec88154a07ba097d  release/kernels/divtail.oracle.jsonl
5a67c20827ee239c6b9835b8b6a3e5e07ca3929fa4713c62c550180035f9c61f  release/kernels/divtail.sv-hosted.log
6ec44bab6e485cb1f4655a848462670bfbf4164afcd63e003f671ed57fd299e9  release/kernels/divtail2.by_instr.json.gz
32f0ee46a041ca0ff1f6bcd76c7b37ec66e9d729bceeaddf78cc60359fc314a0  release/kernels/divtail2.by_unit.json.gz
d066e7fe43974e52b687a6cb1a1ee3a39c9c5088130a65a5a8c9ac6926f8ff89  release/kernels/divtail2.ccvtrace
0dad5a349a52e577a1eb67fde21495e2b35921770c51acdec2f1cd0fd2e8496b  release/kernels/divtail2.log
b2db6b05eb6cf4a0a7677e31d0c6c2952d5cab49d353f0bb1883fe0b2a20ed14  release/kernels/divtail2.oracle.jsonl
81c6f644f4b4f8f47f93c80bee342157a99d78d5ea3176f358597dd110818d49  release/kernels/divtail2.sv-hosted.log
7d64d59344c012a8c199a03ee6e97445c273f5b8a4b110ba133945403ac82f94  release/kernels/fence.by_instr.json
3c00199b9a30f377d4d123e2531b0e3ad2ff119e3395b1f68b8dc766a0c6338c  release/kernels/fence.by_unit.json.gz
d46fd67f0c96470ef3c746ee6ecd695d757e14b442e227ae799c8d9b983b0462  release/kernels/fence.ccvtrace
fe5a49e72d619b2a3a88aecffc29b9a6b6df02101e70e0eabdfbf59a3b6bdac2  release/kernels/fence.log
d1d40317f6cf5bfb430cda1f9c0ef676609e59cabe2a11623c42ffbeca93142b  release/kernels/fence.oracle.jsonl
9bda04508c562b139e0276bfbb0b8a0f7e49fc2b93e543031b0466356333b16a  release/kernels/fence.sv-hosted.log
f87ee1be680805de9b87e41a1ef559957a69d5f6e70a66d4a52d092a5577b03b  release/kernels/gather.by_instr.json.gz
047711bc1145e6b85721752abb2ccc6799684050a7b3634b3d2d6ce297897f0a  release/kernels/gather.by_unit.json.gz
2557d7a3a876116a86501c37e09dcd85b2640f62bfbe3ece292ffd693de533fe  release/kernels/gather.ccvtrace
d4f0fca4fcebaca14bb9b03951c63ac21b5a171854c8b4cda12cfb2b2d5badec  release/kernels/gather.log
0413e781d8d6ff578c64eb1f800b7931e66f676d5cdabb97b94a4033e6037662  release/kernels/gather.oracle.jsonl
636fee1f0258c6d66fe4c62749646124fd1df64fe9e9fe4f5863b894f9687f96  release/kernels/gather.sv-hosted.log
f99fb7aeba43036df451ccfae0f8aaba519720bf85855d65aeed1bad93a63774  release/kernels/hit.by_instr.json.gz
f960ea773ff8e3171838bd7f06ea39c1f1bcbce65f8cd99b2db5a5640e2e1f6e  release/kernels/hit.by_unit.json.gz
6a020da22877bb02eefc5970498ae1c61a2bf4e38841577f7693add521b9e483  release/kernels/hit.ccvtrace
75b66a4a4786b36fedeac055b493ee8b91234999eff47227edadb60f86253f12  release/kernels/hit.log
7ba9603e0088d9164de6528f16ef6a7fa9ce5821c8c12b52cbb3734e39b9fd52  release/kernels/hit.oracle.jsonl
c55d159265ffddc0c3a3fc77de1d2d53c3d8e8472f20786a99ab6016cb915306  release/kernels/hit.sv-hosted.log
ea58a63719195483008a49c634ed03d7627002e420d39037c7420930a5f686a4  release/kernels/lanectx.by_instr.json.gz
e63c77d1a17207c15953c2989a68436f268b45c5d892c3c7225c6733013257bb  release/kernels/lanectx.by_unit.json.gz
881f0b06008c79414440c5a87be1273d45d0afae941c766627e76f5df1d334ae  release/kernels/lanectx.ccvtrace
6c841c3febc6e69b975f5a8b2372b9387e9a25b0ba175778f395913a96d6e1de  release/kernels/lanectx.log
888551babf540db8e3025b82e65ca655013f93eba3c8a65689d069d52a7e6039  release/kernels/lanectx.oracle.jsonl
03cdc1935092c91a44b86291787ba0a401e3e27cfa07a47e6baa1abfc2b5b45c  release/kernels/lanectx.sv-hosted.log
f2eb34ba1272748a79d2053fb4ae926627dbb3b32421b034d8d507a5af946406  release/kernels/lanectx2.by_instr.json.gz
baf570b389a3ad2af2b3823aad49e9834993db6acd8a3c7dfbf7dd63bcaecd4d  release/kernels/lanectx2.by_unit.json.gz
17e02915fcacdeca7462c0899aec83fccbf01c7e3234d321681b6c27267e171a  release/kernels/lanectx2.ccvtrace
644caa717cbc5ffc82ca7b7ac7b4c5cdf9ac030a8beb9e9aa08dbe16fc572592  release/kernels/lanectx2.log
45c13056dff5c73ed0c9ece56cc36f929bf335322193c7d5eb38710b1d1dfb02  release/kernels/lanectx2.oracle.jsonl
299b366edb2459db15680992ceddd702f6b7b883fd2e6519f587acf0b0b367ab  release/kernels/lanectx2.sv-hosted.log
7db455be31e2cdc9fb8c3f4beeb33d6f06a6ec3ba80e531a49fc2a4258e4d7df  release/kernels/late.by_instr.json.gz
09adf97a7c837f6d8ded4a4139c012c9d625a7af653febb4a213371b8b4e97b9  release/kernels/late.by_unit.json.gz
5415b5d890c45235be41b556a79e409afdbffd5a8f841ffb1e6f84157dfeb404  release/kernels/late.ccvtrace
e78e405835d33dff5d2d9043380e1f64bc864f373a1a5cafef413a2d1783266f  release/kernels/late.log
86084f6bd747a2cf32acbc0ebd96ebd3e4ef2d8d9e21be49e3ae49290d7927f3  release/kernels/late.oracle.jsonl
03ed60e28780b76749d968572a2e4459d2d72e0a2fb9132599b469c67a3be597  release/kernels/late.sv-hosted.log
49f4962e9d61cdb63632c5a5cd6f55a4c473ddc627bc339432bcd8979ae1e896  release/kernels/ldpar.by_instr.json.gz
b2a6b21a35c22d9397868e4688be7b55373b18d7af0bbf82dbc68389bac7260e  release/kernels/ldpar.by_unit.json.gz
3224c43e3d1f453edab7571fa566c74963c30499b5106ca9619e10fd8dddb287  release/kernels/ldpar.ccvtrace
3e6e4135b8389ed3768b461aae465ddbedd8efec05b2c372d64fe77096730d91  release/kernels/ldpar.log
8ac08538e9c807637babd61b31e340f7461878ada31f0c0b83cd66331cfaf486  release/kernels/ldpar.oracle.jsonl
89fd9459b7d1a0723592e5e9646d5cd9425c1d0572cee4b0e39ddd9e2a142305  release/kernels/ldpar.sv-hosted.log
c3ac2e894c305b3e4a10688228bf2d3304ba1ba48db89f984effcfc0b6ee5142  release/kernels/lnorm1.by_instr.json.gz
c1ca9c36d6a94a58c68f3d68d8272fce2f6f18a3c9998c124db05f2b5c7a4327  release/kernels/lnorm1.by_unit.json.gz
c549d4531cb215ded7009944c2f9bc84ff68bc017f70820b9b32971d0b174c60  release/kernels/lnorm1.ccvtrace
1a647b0b0eadce600f80a1e446ec57e73e9ab22e1c33f97366f652d5b2466c5d  release/kernels/lnorm1.log
a8d85811af988a1b9fc00db1517300af3d93ec8e589e403d3b9113fa9e0ffc86  release/kernels/lnorm1.oracle.jsonl
5edd54065fae8cb84fe47f80e7a73806792d6e99e6f4066a5c94b70674e22fbb  release/kernels/lnorm1.sv-hosted.log
db4c57ef2b16d82a7ed1dd161a650a7756900e0bb6c19f37f9bcae81b43723f0  release/kernels/localsp.by_instr.json.gz
38487df900f643e00fef5487a3c300852d903605a42bcc262801cbc08f72ae42  release/kernels/localsp.by_unit.json.gz
db05bcc06cf6fc38724b1310c300dfce3fd6d2c52b6b5ff40876c0ff8774eadb  release/kernels/localsp.ccvtrace
32d5a644998c97ae739956a7f5c456db798b0119c2aed0b07db325404212bb9e  release/kernels/localsp.log
55e3c9f36e7f7d38c0ddd38903aff4bb4509ae862015c592e6b937ea258042ca  release/kernels/localsp.oracle.jsonl
3d8eb700b8726bd1d5fd03b6758ea6a232b51e117f8c2bb3c22a3b9ab2b07099  release/kernels/localsp.sv-hosted.log
25453848920595848b10454d5b66ac1464f6190eb203503a9cf375e80b517631  release/kernels/loop.by_instr.json.gz
64fa9293993e37d72823d820d65a19a6845a3b06e8a9ef84dd02387821c1a3ac  release/kernels/loop.by_unit.json.gz
07e485ca8c195c6ad97a4bab386350fbb3cd608c60693317b97b6fe5b39dacda  release/kernels/loop.ccvtrace
b04f06a4fa31bb24d89e4d70ef906d0494f64b663163bb7817ad31b816f0cc3f  release/kernels/loop.log
03ce5920c06c93e93516d8e53c3f7169f14e3593de204eacceffc0b8a3e32016  release/kernels/loop.oracle.jsonl
107a838dfeae6d62e8a0aaf45372ac58e3c22b00d176560f1363f8cb7d923d75  release/kernels/loop.sv-hosted.log
a29a76658d272e483a22d33630f8ff6a5f77d53204bda48519358b56ff06830d  release/kernels/merge.by_instr.json.gz
fcddd17c3dba9162c16642479c4c0df8ad3cddaf1806f10b32e3f100ec84056e  release/kernels/merge.by_unit.json.gz
fb3738c6d842e8baf329dbebf4968b4945e0a3fc632251d675b1b2e098ab48fb  release/kernels/merge.ccvtrace
f8d17ca3da5849bde321420f242c0d38da7622e0fcdb8502c9700bcb49d3d6f3  release/kernels/merge.log
f96d28815f8756b1f5a45ded53e6170883d2dfa10f9eef0d14b8050b1318164a  release/kernels/merge.oracle.jsonl
057cab61fee57e1ab5b8ce4c25ae17a92fb5e6c6cea2c63e449d4b172792258d  release/kernels/merge.sv-hosted.log
bb9f4b6272efc812d6fda6695aa4a9c8cc9d961cc29897c26423ac1b4c29819f  release/kernels/missrun.by_instr.json.gz
1e0b08f227b08b5a08d970abfd79efa33f75d1ad1c224695be198a3283cf175b  release/kernels/missrun.by_unit.json.gz
ca9434192696fd39f118bbef6270144f6067b68583748cce7773c45b77f79d3d  release/kernels/missrun.ccvtrace
aeae866bbba55da369e0922633309fe44a0049fc68fb8041213521dceef32bef  release/kernels/missrun.log
531bdaf281e5590774bd2775427f25e4cc0419cf8e3d5b6999843ffe9ef87258  release/kernels/missrun.oracle.jsonl
0a087e5d60caba6ef5c976d21b02af0411ea508323cb64a439f5a70a4f2d55ff  release/kernels/missrun.sv-hosted.log
1f6b75818680969b940462ad1c62a2c91ba32381880359d671a77d7e7efc8242  release/kernels/mload.by_instr.json.gz
99927bcdca69bb3a626830e08d64c6279b9e56fbe36d96e01ff2ff7bb8097484  release/kernels/mload.by_unit.json.gz
a59040b63ea89f6d77073f9f1bb04dc54e7ade463c043d66b0123b1f7f0bb4dc  release/kernels/mload.ccvtrace
9099d27f3567aac469d58e2cda4614cf82704f44659db51941c64760f4f36f44  release/kernels/mload.log
8000e477b9a95dfb9f0af964e8346acb9d36f1358fd06ffc4ff7cf599d2b8868  release/kernels/mload.oracle.jsonl
521eac5a171993a04a9717a243fed687a2c22ac48755d29d03ad2ae072455042  release/kernels/mload.sv-hosted.log
076c1dac67cb3bac25be2011cc7f6d6057196f052d697dba81549d692b04a8fb  release/kernels/mlp.by_instr.json.gz
f9ef1abe33b5ee7e5eba20b85c4b23cb051542621acec775f22bd037d58a3836  release/kernels/mlp.by_unit.json.gz
a11384d36f946f4f5b94d7a50dcf48417cec5e6d20adc8c33071301830d99ee6  release/kernels/mlp.ccvtrace
7cfb7d1c06bddcd1bebb1167bd6c6660d2ed3bf4d7cc23a01dc47f0d4c3caf79  release/kernels/mlp.log
138d282f88d56c8ad648a91af0a983254b55d9fa22942c00d47b327f516a6e44  release/kernels/mlp.oracle.jsonl
cf0e52eed7a913dd843d7183b15e8834156ae022886403ff8c029a76257e8441  release/kernels/mlp.sv-hosted.log
b4dccaa40cabaac0f43b5235174a846426ebbc6b7aa80ad916929b04d6ac3ed3  release/kernels/mwmiss.by_instr.json.gz
aa53f832ad7c75a1f7a2fa5666d5bce165eb349b9ab8f6395b3b4f917b3872dc  release/kernels/mwmiss.by_unit.json.gz
df6456cae4a2ea306a3f6dad8d6a1c9aeb336f2216d889ae5e3490b6640143a0  release/kernels/mwmiss.ccvtrace
270151e00848ed34edc207bcfd2f1da5fa3e2895e9c126ed21283b647c4d66cd  release/kernels/mwmiss.log
8abe8e8997456a2a6711ee72da54d854b24e20abbdab28e4b7271c0d28418de8  release/kernels/mwmiss.oracle.jsonl
c7086bf861e61fcf9aadf9d6313725384e223158befc3a339d53f63afb08cd8a  release/kernels/mwmiss.sv-hosted.log
d8493338956d1420959e4b7d912f197f7a1604631152272ceae6737c1207351e  release/kernels/narrowadd.by_instr.json.gz
c25b84a8c16d5e9949e0fc2287461b7f2f5d6c88e28016d8dc792d9ea0988ec1  release/kernels/narrowadd.by_unit.json.gz
d7c47cd1ae8bdaedb1f4961154d4c27ee24bb587d32bbc8b28a3c51766d74796  release/kernels/narrowadd.ccvtrace
6a32a3576a92ed994a6cf77b0a337ba9b58b816b18b4782e203532d7c40d6145  release/kernels/narrowadd.log
40a2cf629853dd404bb06b4a07e35abde3d12efc13f26ffe28f923daf2994574  release/kernels/narrowadd.oracle.jsonl
c43b2af8342ebdd0eb3410e757ab942716658a835d3fd7b1c4c95918ffb92b78  release/kernels/narrowadd.sv-hosted.log
66a22c63f33f37273b783d0c876fa4d9299ba83805fa4f9b452efa0d99f839a8  release/kernels/pguard.by_instr.json.gz
a9dad2a1722dd8c625635a2f3e1e84631ea514915957edf9824a06ab2cb58705  release/kernels/pguard.by_unit.json.gz
428fc176cfc83b436b7e309848cac50b6573bb0a29005c29c0a5e1e917651539  release/kernels/pguard.ccvtrace
e8f7bab52a4d41b10a8eeea5fbf91555a5ab551bba3432408e562a6808ea183a  release/kernels/pguard.log
690e56f1cb8d97cbf67124b7dff3ad0a90cb8981814cd1709cf0cd0e035b3bd9  release/kernels/pguard.oracle.jsonl
44507ac29dcabcd3c0063505d6e8925156524ac54a546541fc61129cc2673ba7  release/kernels/pguard.sv-hosted.log
7f82f37d137861e81969e85c5d4f9c5bdee51911d92af35fc49ed02f5193dc87  release/kernels/plog.by_instr.json.gz
85b61d54cd0b4356b7656bbe15dcf6162e7ffc23302df4c7644a73028260742a  release/kernels/plog.by_unit.json.gz
e32ed8b48729d559c9d9c92968577d8f87099c9bea1562de23e434a7e966bd69  release/kernels/plog.ccvtrace
cde64746d910ab39cec1ff6b736218cd460694a8624fdc8a03b8b54f478d279b  release/kernels/plog.log
c230f13f2e1082b306a9c5ab7809ff36cf5c1b2e47dca6b7a71f741524d403f5  release/kernels/plog.oracle.jsonl
7bc4b723bbd7637a44a2aa400255bf8f236c92373bd58618f482b93279ef649f  release/kernels/plog.sv-hosted.log
493b3ffd1ac0e38400091f6194b07f880efbd56bb162c964b65872158a690635  release/kernels/predlane.by_instr.json.gz
f03670f7b0ddfb17abf530c3c3a564b36e5406129ae137bdfa74cab402eb834b  release/kernels/predlane.by_unit.json.gz
d53e73e88ba3b7f0ab9e1ad0279aaccf84e73d22c0c9077a46ce452c23b161de  release/kernels/predlane.ccvtrace
1cb8ec30517a04f5d717d8797ce9ce1dd1c92580d1f87801eab0d037f9961614  release/kernels/predlane.log
c45f4177b9e84fc8a6e36b13534a0c7636eb30a3f8531847100ce5e23bf404b1  release/kernels/predlane.oracle.jsonl
c6a63d9983143bd430d55670978deb658717e4797164f063f75cedfe0e6fece5  release/kernels/predlane.sv-hosted.log
f62b9d9ec59f2e551a657a6329c9aad468340c44328d3c1b9bf94f16b944d1e0  release/kernels/predmerge.by_instr.json.gz
dabf27c8046a5aa84e0cfc1913982c219ba860643dd735a067b6ea6ec3a15807  release/kernels/predmerge.by_unit.json.gz
86a8f6896af91a600be30e5488b09312c178052c567f5e3666f508428547d8e4  release/kernels/predmerge.ccvtrace
ac6873d8042472952f98f914b7ad753ef71e651f9a1ac344ed8c66a8e22acfc9  release/kernels/predmerge.log
6c737c49434bcd08e3e0814c8b1dbf15c586ae74f7929ba3148ddcee2c62c845  release/kernels/predmerge.oracle.jsonl
33633fe48f59692fef1eb138bee3f35fe41f44028168b7d3bd4cc94b00a22929  release/kernels/predmerge.sv-hosted.log
f7adf23199a1a2b222b825173dc706e8344d585553883a1df414433f57698814  release/kernels/predspill.by_instr.json.gz
c7950ba16cd74f6fc782816153509c5522c05cf7b6455fbc22fe53769e1bd592  release/kernels/predspill.by_unit.json.gz
cb184425369fdeeff94e95da1b8b0eba7772a0243f545afc0a0a81d545508d87  release/kernels/predspill.ccvtrace
67a09735d2d3341de2a1b0032c0c5d30349e38bc4d9595ac3c7868358bcbfdb7  release/kernels/predspill.log
b7c84c6478117ffa0f06da0e6ad1e4628e2683426a7911080810e78e06a5242e  release/kernels/predspill.oracle.jsonl
a5656684e9f63f8f2e14387518be530ce397bd8e4e6bf2eab36e502836a07615  release/kernels/predspill.sv-hosted.log
aeb76bda64f0c9d18e8bc060fb1a46fb46024b3ea9e7bea3ec4a55e846f6828b  release/kernels/predswap.by_instr.json.gz
dac2d987229f790fc97805428fa256e1cd7833bce90fcf97bb28dd216379548f  release/kernels/predswap.by_unit.json.gz
11bafa788a80bd17b83f311b4aa96b356d3b5628c41939e322d7430947951ee0  release/kernels/predswap.ccvtrace
886a3021139144176557fc372d3287f9707b62f18a62de3dbc02b081504428ce  release/kernels/predswap.log
a6d4f7ed517553816d889c7c9eeb6bcfd1f6c973fbf682ecb69f3c2de619f7bb  release/kernels/predswap.oracle.jsonl
8c259c97013f47ae995c9841b70387f3e5fc149d70295465ee4d191acd2305ea  release/kernels/predswap.sv-hosted.log
c61d8eea91e37ab0989bd5cf8ed4a66e017bf5e438c41016d43e9fd7eec56851  release/kernels/privwin.by_instr.json.gz
84b6fdefb0fd28e76663850666f338c0b7237116eb5938915fdcf12f99a7f6c1  release/kernels/privwin.by_unit.json.gz
24fc45643051f2a43ba2e818a39e084a3bca8ee4ac3bc93c71c7242d76dab7ab  release/kernels/privwin.ccvtrace
42fd8262ee50eadfea18d8add8570c8a694b69be9e3abe1c94cb8de6c13050b4  release/kernels/privwin.log
861f686fc4480363472908d679d8815e8c957d768e7ab32c826930527b0fb7a8  release/kernels/privwin.oracle.jsonl
7ba3adbc89ac1eb5c6cefb7e936c75382db89d9be2d155e0026b1aedaaf030fe  release/kernels/privwin.sv-hosted.log
0e0c99629eea7cb752becedc1a60da140ca5805ea46bf66a57d216372bf0aaab  release/kernels/provswap.by_instr.json.gz
1570e9644c33f18b8b3a72084ee044f3153a5410501cd515762b6bd46ec4dd83  release/kernels/provswap.by_unit.json.gz
e34b970fdc2a6574afd45e92bd74ec6cc3840d60cb596e3b581e25f2b2178a3d  release/kernels/provswap.ccvtrace
93fdde1ac3ddb88648967163c59afcf9d0266ff755f960ad136384d8a34064d5  release/kernels/provswap.log
c9c32a793d54cc7401477f582487f7e8b345b2669a75337b8d6327120d98e5dc  release/kernels/provswap.oracle.jsonl
65e227395fd22e3f213f21e51e31a817d6c85c0f878b081e80d331bbe3ba3860  release/kernels/provswap.sv-hosted.log
bc78212fb3eb25a011a8123c4c1f4f52a37579dfba964059b435dacf71198f47  release/kernels/roconst.by_instr.json
66b59f460abe69a673e77950a40ffab16961f574aadd62b81c50d75b9dc421c5  release/kernels/roconst.by_unit.json
a4285881bc085f22a043d9584b7b6a66e0504beb0e0398a7e1d188c3a2814147  release/kernels/roconst.ccvtrace
eb9ed3f3498a72dbce0287767d192fa90e177b792900cabd8f5ad09394f906db  release/kernels/roconst.log
8087c0671de620162881aecd38cd6114b78e7be6bd71201e3ec02c9a2e2e750e  release/kernels/roconst.oracle.jsonl
06ca2e0c43e4e5950de2283b7151cb437c61d6fd425a8155fbb342cf866a6225  release/kernels/roconst.sv-hosted.log
500fa0cd958f1e29b126638b2309a0237824dedaf9c53f2970fed512bb4691c4  release/kernels/rogated.by_instr.json
5f383ef9e611c84d58747b811893863341350ca55b527b3c931111d3f2c1e215  release/kernels/rogated.by_unit.json.gz
7d6f41b4ffe6119282eb2881e903ae2a287752b1c44f5be46312284f131d200d  release/kernels/rogated.ccvtrace
af1747c724f6daedcee8e44b309a394d8aaa68d2fc3cde03a431e16c99461829  release/kernels/rogated.log
7cd02bd4cceec5a044d6b4d6a80df1e68ed0ae71b0b2a953143636d5b809ea6c  release/kernels/rogated.oracle.jsonl
68b6cfae8186e82393730acc83b68a8abc2745cb4a3e22683a57af1250bc169c  release/kernels/rogated.sv-hosted.log
f8451a3c65e31539b327ac832cbf53b7f9fdaf839b2cd14f738728e0aabf68b8  release/kernels/rokill.by_instr.json.gz
1ca32ea291bb47f15a5736a94bf5c36d2a0abede061d2cee768c21ab054cfc5c  release/kernels/rokill.by_unit.json.gz
f69b0409a4af5f6cb31113459c521d49b43c292660f38a5ba53f64962975a1b1  release/kernels/rokill.ccvtrace
3b511ba7a6aa9a955b81a78c22a7c0e54652f11cb5a4da9a6c3c241a4afc15a6  release/kernels/rokill.log
94efcef96af469a512d346ce61623980fe86383188eaebd55120f716db596f14  release/kernels/rokill.oracle.jsonl
583c4af357178abc38ea655e51312a829b9f8b52af82e30ab739ee9f26b56ded  release/kernels/rokill.sv-hosted.log
f41e6e2e961cd580d1cb70c2a7f4b0d5a5009c7d936e611e401b661c48745392  release/kernels/rolaunch.by_instr.json
7deb59c3a34a6ad597d362605214b2f8c5608fe4b96916c8fab8e2368db4c3cb  release/kernels/rolaunch.by_unit.json
03c1532e55928161a52bd3a508207e2590d1e4a67091d7be62e55942c13bca02  release/kernels/rolaunch.ccvtrace
0655cff219a34da53f691c62d67e0d5a1534c79d593d1a70ac106d8e09988c27  release/kernels/rolaunch.log
e7dad585c3e70615de04330fd03f4f282c29a005dc1732a35655fb261d51139e  release/kernels/rolaunch.oracle.jsonl
fc33552a3f49fc922825e3246606af366b617690bfa55ac2e4c76b859b0d1b33  release/kernels/rolaunch.sv-hosted.log
bc78212fb3eb25a011a8123c4c1f4f52a37579dfba964059b435dacf71198f47  release/kernels/rolimit.by_instr.json
fb382121fe57e8df4fe50333b431a10ac569d036916a50f7a5ad605d71e79a80  release/kernels/rolimit.by_unit.json
c9ff94e1b40948672222ab793c3a457e9c0e028ffb6c9685fa372aa1ae7bc2ca  release/kernels/rolimit.ccvtrace
77407a923cd14faf9efaa7fe990b2bd844872a3a1a25b654c62e84b32e8d6734  release/kernels/rolimit.log
1c5bc0cb8e8b2e69505fb5a551a16d5d10c56f232b88da7a27e336ad7d962de2  release/kernels/rolimit.oracle.jsonl
03d5a9ee64d57a4f6dc8e54626fde0d5a14037977b4c4a66dfc7f10da766f730  release/kernels/rolimit.sv-hosted.log
5713699aaf55283c3790eec0135b30555e929fb198ba7adc33c839bcc9d6f673  release/kernels/roload.by_instr.json.gz
d9945742843ccaa5aecdeb3efa2bc774be78581091dd65f1d2b8ff8703d49532  release/kernels/roload.by_unit.json.gz
bc1742e748a53254bacc2e74d53d04676984dbe88f2a4de5e91c4153fa6e59e4  release/kernels/roload.ccvtrace
9602b313459715ce29b3e216b062add2645670f18db21b1c54690746e09324d8  release/kernels/roload.log
f7c1309cc9764769fb5803f6fd0f2f5e1eb418f2d23fbe5e17cf5f9106869fdf  release/kernels/roload.oracle.jsonl
6b63472213582184bc8277459389feaf92d9e884453838010cf248ec2332bdac  release/kernels/roload.sv-hosted.log
84c51156ce946ed5b250d74a379ecb730da61cf90f5d1a1d2c33004608117d4e  release/kernels/rope.by_instr.json.gz
b4bf57a179ad9696ba8f03656655fca1a65c099100f347bbabb55ab4122d0e01  release/kernels/rope.by_unit.json.gz
1ac8e4719055eba41bb937c9b21e48b0b74053d3335f009395ec5089c807e992  release/kernels/rope.ccvtrace
7ad3751b943a41d1ff43a2893ef82523e9eb3fc92c1303ed11ceb016d0e3c168  release/kernels/rope.log
d55f9efae392dc8877c102c01c0810e7654b666b6ede386328108164c6cf88f3  release/kernels/rope.oracle.jsonl
7cc7ec1851c782dd6251fa7ef0c1cd1efcb70a5217eb38946764380563e27c40  release/kernels/rope.sv-hosted.log
87b66b944944e36f3be6cbaf60eacece4797c9130453732d6221d70ac6811939  release/kernels/ropediv.by_instr.json.gz
a9a63f3c8206c813544c146fb2c4368c8e770a4bef9cdddeee3bd8f49f0c423a  release/kernels/ropediv.by_unit.json.gz
d3bca64da38c300cb22df607ecca3217e5caa9445b92cd4fb7fc39011bd27738  release/kernels/ropediv.ccvtrace
d2c5c8333210649ff8aaa0832540daa3efededa5802958424838d086ce576686  release/kernels/ropediv.log
10c0ec6ec18b7b44638c790033109198c079d07c1537bf193353ccedd00a920f  release/kernels/ropediv.oracle.jsonl
53a36d26fcb1e2ec964f49aa436dd776000ad9fa2603a68932baf2b5f771d375  release/kernels/ropediv.sv-hosted.log
a21f392fc462c717988ab93cd22233d6099096326ad9e29bb9db3ef1d746fa15  release/kernels/sel.by_instr.json.gz
4e910c144cf3b28174e0d1cb1ce5a07c6ac7d360d536f5859bdc9c8cf9b264e5  release/kernels/sel.by_unit.json.gz
d647e23e18e16512cc2061f4c5ef8fde687a47a2e11482fb7dfecd77a7745778  release/kernels/sel.ccvtrace
2ffff753751a9f25a6d5f4ed8905ade2ac2da89b9c661e8c359cc64bc84af1b4  release/kernels/sel.log
87f6a81e8afa004c8039bf2f61c90176fcf29ab29bb17ac44aa016a5cc8438fe  release/kernels/sel.oracle.jsonl
a12f09e9c85ed1ec16e7b6cc8d6652f3e5d80c3a8d9d0c7e91837e25c98e4969  release/kernels/sel.sv-hosted.log
7e2c18bdcdae0f5f51d2cbd7885584ea8354d20a80b4b32d23f5f76eed8a17a0  release/kernels/sized.by_instr.json.gz
ef2eeceb2fd529b7002e54c74379e11e6cccccb5ff77c79d285018888d0c3ef1  release/kernels/sized.by_unit.json.gz
1c04430288a5cbc545ed55ba2d9b47a9dc4ead0bbca4afe172696e7906251fe0  release/kernels/sized.ccvtrace
8fc106e9a439e79c9dcfa643929482e04109c6a2d9e2530b65a6de918fb7780d  release/kernels/sized.log
36d903ba1618bd1faa437c9812a6ee6c0c966a63196c796267d74bf2695ebc3d  release/kernels/sized.oracle.jsonl
b63d0c2bc4aa139538b0d90d06cae3487e44d37f423d7a212ce1a0b785809a4d  release/kernels/sized.sv-hosted.log
869a6b7d45042596a8377a22c15fa12cd019408b492d262174b8cea49436fe88  release/kernels/slotform.by_instr.json.gz
d215a143d018f293dd367a790fce4865b584feae71085772fe20f1d54754b7a4  release/kernels/slotform.by_unit.json.gz
9770404d684039e51e42075cf0ecf3492cc7e662f2c3919671ee55578e44551a  release/kernels/slotform.ccvtrace
2a8657d3bfff91176ebfc4fdd18aa6cc529d8fcb93ce6e0b10d1a8f3c0d4f629  release/kernels/slotform.log
8b61db7419b18cea8a646fb628218447e72e84a18a9891ffb73b441736138ab9  release/kernels/slotform.oracle.jsonl
cb920b9d587eac863c54e898d0b5b32ae72c154796d584219b04bf67423b7388  release/kernels/slotform.sv-hosted.log
321b9ba1ebfe7740788194fe03365bf1f5970091ebb0f56145f7fbfbf7721304  release/kernels/spinwait.by_instr.json.gz
c35c9685a07a59f50c2d0bcd382b5e0dec10ea8f9b64c1e2e7953ab21e7725de  release/kernels/spinwait.by_unit.json.gz
277d2190db5dd184a188b7146709bb21d08eda4ad23b59ea8e4e5cae941fb880  release/kernels/spinwait.ccvtrace
a30d13543aa58703b87bc7443487d1b08cd6e4fe47d9d7577666d7d0e9be6829  release/kernels/spinwait.log
868920637236c878b33779bd450439466fc3626996a3164573dc11d437d5c709  release/kernels/spinwait.oracle.jsonl
67da1e1f4b0e8e077c5d9dc1c115bc6aa3ffefe2a845934d28130017aefb8d5d  release/kernels/spinwait.sv-hosted.log
a99dedfac5d06855088520b380f50c537b3b68c0c66453e553a08fb093686ebd  release/kernels/spmbank.by_instr.json.gz
7e0e1924b79568f1a359824b21b3f85a1fe42f95131eb10646ba185e1f38000e  release/kernels/spmbank.by_unit.json.gz
ac25334168e686fac2a75c34223eda65ce0d66b02fbff870b8e713e12bd16875  release/kernels/spmbank.ccvtrace
761bb1e0c7d7df7629144f445c4200b04adb61be28b6d7aa58e705ab8316ab8a  release/kernels/spmbank.log
3af490cc37d7a92dbe719b57de216b648536eb301ff9d13de9a39f50d150d725  release/kernels/spmbank.oracle.jsonl
dd6801894667c9642e9e5689b38f32c3a56e8a27660d59ee4384ddd53447f506  release/kernels/spmbank.sv-hosted.log
218f2ef8d8b12fa3c2dd47bd7307c1c8a4ea1636f587e8d401a205e1df059240  release/kernels/srd.by_instr.json.gz
06afec677836b21fbe4f74c18be98bc2be3463137809a50f75a58497c9893e38  release/kernels/srd.by_unit.json.gz
0de6fcb70c02376f30c7eed67f0cabf4cd00fc874e9d95f24465e7d79129b3e4  release/kernels/srd.ccvtrace
7deac1f8f9838907e6a6f3870753c7335c6201e78fb87421f03a6b74dad0e4fb  release/kernels/srd.log
b08eb5e3673cac7eebb8b72af5ed3783c8e70a9e96592e76bf3722551bc79473  release/kernels/srd.oracle.jsonl
b1ee5a89ddef2b74d95890966be81a087dcf651748f296981f1c34760d903221  release/kernels/srd.sv-hosted.log
41bc85ba38ab35d2da7390bafb0f2c6ee8a7bbc5b27b87a3e3af8e15c94708b8  release/kernels/stall.by_instr.json.gz
711fbeb89b4609fc1493a46e6868ca07affdd3adbaf1ad635137c95fa8200f1f  release/kernels/stall.by_unit.json.gz
b3433bbeadf45f6b92b035d4c99f68eededf963182e32aeac109105835b2befc  release/kernels/stall.ccvtrace
6254c1624e80252aafdbe7e776953583ac0bad2195c5d615509e1edfddf36600  release/kernels/stall.log
500db2c482b07a0706583422cd68878301d0146c1f872ccc1f11bfdcf5c993ef  release/kernels/stall.oracle.jsonl
0b69382269bb630a4ce6a2dfae7279dd35e342259746f98f4a2699e3dc1cd28b  release/kernels/stall.sv-hosted.log
8bf3b97ce79c5ebc7080e3b4fc2f8fe81f2c711f5d24c00a2267433fdc8236fa  release/kernels/swap.by_instr.json.gz
e4d0b4ff769cc34f8b9b6d51ebe18cc2c74ab3071dcba1493de578e2c2373dfd  release/kernels/swap.by_unit.json.gz
6a6c9b5164f4b8864dc27b6b6abe1226ba4eedd6c62140bc48f790e45d78319c  release/kernels/swap.ccvtrace
325dd5d3ae702a740cc903bf0589707a2835b952bf851fd01c01dfd74abea113  release/kernels/swap.log
3658a26316c1ff7bc1744304a42f736e930fcde2865c8913e6cc67a22ce96667  release/kernels/swap.oracle.jsonl
e3edd116f2978415ed81aa5a27a68ac43effbd5f4f7db2a9c72c6f6a3a17db4d  release/kernels/swap.sv-hosted.log
fd45336e40ec03f099fda26becd5d338a730bb0930e7a1c2b9a560bd0e256336  release/kernels/transp4.by_instr.json.gz
e0a29b3a4a07a6078cd366e16f4808dfafdc88f569387dec85111dc6b41e05bb  release/kernels/transp4.by_unit.json.gz
aa9b823dac936b3e22e2621e701cea3c3c0fdafab04cffa5ac6b6287af2d87c3  release/kernels/transp4.ccvtrace
52a92d0532edea2b7182b3007c53d0ba464afac070fa4da4a1e401b82ac80777  release/kernels/transp4.log
06396ace3ac19677fd39c700e408606e5bdbacb24997d663bbe8872e63dd74fc  release/kernels/transp4.oracle.jsonl
bc5249e90dd046749a5c6d2f859141dbdbab1b9d686916088d46d4c2887ce1f4  release/kernels/transp4.sv-hosted.log
c1338ade006adc8de3d09f389d5b6492b56d39760efa97cb9fb71532182c3b8a  release/kernels/unal.by_instr.json.gz
c55509421e77ec7f5f4ba997499be286ae29c7aa17cb5c0fd9f98647232bac49  release/kernels/unal.by_unit.json.gz
4b88c544a427409d4dffa8919e05bf2cce43e8866a6ef0a69d52b5d58e1d14ae  release/kernels/unal.ccvtrace
5e819dec65b50673ac6121fce6719df4d88be72143e4b9f144c9689b5e729f55  release/kernels/unal.log
c3d484bb160657a563df983d9a2532eac27f556636617960aa1e72183ac2b299  release/kernels/unal.oracle.jsonl
e435716aab6aed97fdfc8187f969596afdc9338cc5785b75510156a699fa9808  release/kernels/unal.sv-hosted.log
5469cb2530659d7ac40439a9b2565314fb26350efb1431830e097149f06653e2  release/kernels/vadd.by_instr.json.gz
4c02579e307fa66913305474864ef85c0585b1620a2299d5bad9c7f01e90af3a  release/kernels/vadd.by_unit.json.gz
790ee7967765802d5f08551b6688b5780942907fad992e10c4902ff20def6be1  release/kernels/vadd.ccvtrace
ad45d6e6d0e07bc73d3bb634c9d44b7b2de3af3d6c5aeedb6dca3f1866694ad2  release/kernels/vadd.log
0276b6d0611a4bbcdc004ab3987214aea138245bc7217504147331689a9c0880  release/kernels/vadd.oracle.jsonl
6b58367da333ed823fc438d1be2b7942d4092166d5292f7e681761a7fa4e7ae7  release/kernels/vadd.sv-hosted.log
566e038cea273e9174161009766b11a269c6e0c40592bd7e9612c9c359672301  release/kernels/vadd4.by_instr.json.gz
3a172d748d2dbbbe91f65e9ce64c3954479abf112f0f8c2bb51ff8154f23a4a8  release/kernels/vadd4.by_unit.json.gz
bc7513885e5e976255a72bc4679136dd1a839961e855710cb7861c54820a680c  release/kernels/vadd4.ccvtrace
20e9ba1ae61b40c45ec387ec0f9964ba3bf8b03dc535ee570be9881cf621d6eb  release/kernels/vadd4.log
225aa18fc9f38aa9ad615aa11de254337d59fa705877553d873062c68366e0db  release/kernels/vadd4.oracle.jsonl
5bd2710e257bf3e7e445962abae2bd6d197651603cb42aa90b3677083cc4b5d7  release/kernels/vadd4.sv-hosted.log
2db8b798e7486851b93d7463442b0d4736a1614a87c09b77e50e92383e81d4b7  release/kernels/vaddslow.by_instr.json.gz
1159095d034fd916b5c2e9c00e28fc611dc37c26510c25855f68d06dcd6d71e2  release/kernels/vaddslow.by_unit.json.gz
5a24e7f0ab4c461d0eda69bb96bb5b0fd958b684dcf3eeb3c5b1ecd30a582b6c  release/kernels/vaddslow.ccvtrace
5fb43ad1d163320b67b762ac98f83d174ac56c3f189e3593e7780bc84f061ba2  release/kernels/vaddslow.log
e9e6218e8b8450e9f9ff6b39d659c994a1e51c527a0c5bd10d18b5658ae0e344  release/kernels/vaddslow.oracle.jsonl
7f6c24d30e1e881231622e321dad270e33823a0ef9374ad688705537d06b25f9  release/kernels/vaddslow.sv-hosted.log
be7ed311fb1af567bfc846e7a072b546d970e2f24e92bbdd8c3fab4803f55885  release/verify.log
1f3a2eff14dbda0754e19cbf72bc5003c950fc7d1691d527ce3a8d427fb583d7  release/wiring.txt
```
