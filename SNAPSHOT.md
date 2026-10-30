# Snapshot snapshot-2026-10-30-d42d4b4

**A generated, read-only snapshot. Do not edit or merge it.** The source
is `ti-ret` at `d42d4b4575b49b560100d633e8d8721ed0794430`, and this branch is rebuilt from source by
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
| Source | `ti-ret` @ `d42d4b4575b49b560100d633e8d8721ed0794430` |
| Built | 2026-10-30 (UTC) |
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
1cd9dd35ed74aae09ccee9b1e561ecf6a6b7071a3b39c1b7f7f64c1ecd4b7098  release/kernels/addrhigh.by_instr.json.gz
24781a8909d056df8b34240361585aa23eedd7e563a38994592094233b2113c1  release/kernels/addrhigh.by_unit.json.gz
6a83ee549bc2b620731911123a4ffc5e1ff680d3882bbd4127604ae03aec34c0  release/kernels/addrhigh.ccvtrace
c12b4be2d5129bd11813c18a5df6a92425c4d8b6206cac93c3e97c2aa417e46d  release/kernels/addrhigh.log
569f2e22883fad5f0956c57ec734e6afbdd4b8a854e50277425172d6c0cbd766  release/kernels/addrhigh.oracle.jsonl
0627841d557e63d5f39c486fa44f8c9b6b1654a9e0e94f818754f83c9070a673  release/kernels/addrhigh.sv-hosted.log
28dc69325fbf2e934fd86658223b48a8cb92053952c06eb87d3d34b4706decbc  release/kernels/addrlimit.by_instr.json
f6461e7e8081e79750a0a358ce2ee174a0174a909ffc7998aa7542e4f963d0bf  release/kernels/addrlimit.by_unit.json
d0275ae1473e1f86fd56e1553d6e6cb67f83eb67dc23e27159a63e3cf3f3f0fa  release/kernels/addrlimit.ccvtrace
b92e5074f6a578ee39326458201ba1791a48000c73a281ca343da4d5420a5bf5  release/kernels/addrlimit.log
bc660b0b40359a2c5a2478cb0eb4950b73fd22db50ea76b80052bc195a1920f4  release/kernels/addrlimit.oracle.jsonl
df30c7bfaac0e6b4b78bdf773f83943fc6748f3ee0f3152195cd7179b1481008  release/kernels/addrlimit.sv-hosted.log
002eb9f49b1db791a8001012fccd9f16bd62772dd9f663bd1a841e07061ce16c  release/kernels/addrneg.by_instr.json
ada96822553635b5282a2fb7c64ddaf92933ad7c066099ad0dd4205e98f8b381  release/kernels/addrneg.by_unit.json
5cb0374d21bf1240216d039ca378d384e50df24c7c9a4dd00b14448e75084b34  release/kernels/addrneg.ccvtrace
528ebf549ed59eaf727699009afc33c68daa341e88d25f604d098d8c7562e07f  release/kernels/addrneg.log
16f5b0707ae44492a1efd67bb9dd38a7e79a7bbd354fa9207b9e7d150ff2f107  release/kernels/addrneg.oracle.jsonl
fbc271055c1a144855d8b76903c9f3159964d414bbd10a82551c736e86718aab  release/kernels/addrneg.sv-hosted.log
77009de6cb4d7056124e859cc96d3a671c55b557ff0b4c992f0706bb5a0d6207  release/kernels/borrow.by_instr.json.gz
c51da02d6cecd8bed5d84d17958fb35bb97684bc16397ee1f7ecf6138985c17d  release/kernels/borrow.by_unit.json.gz
f1f862776f5dfc78e83e1d331944227363a821f4e49be68c0527294b55f42091  release/kernels/borrow.ccvtrace
86ea261f07bc9c29bbd875107073031458cc424f3be02d179a00fbde37f847e6  release/kernels/borrow.log
4c565e1ce0b3baee36e158694b32c8defb5cd662b2f9af75cb5d8c26cb1168ed  release/kernels/borrow.oracle.jsonl
b5bfe7537d125db9ab5e8750a0c49d2a274fd8e6bda4c971b4ee013fcdf2dcab  release/kernels/borrow.sv-hosted.log
87d4e8e0318e014ecb18664f6cb21c06e2eb551a5d2a88e54333d4e5d5bf957f  release/kernels/brs.by_instr.json.gz
2b51d3baba7e2e716da23d8f1f0c208fc26edc76a9109b6b05a253e6051f4108  release/kernels/brs.by_unit.json.gz
5dc140ea49c98a2c34b741f82308100619a4698b3734262ba4d3417c10d722cc  release/kernels/brs.ccvtrace
0fe0bfe4fb0430b2cdae802f0d093c70ccbd2b8e43080f3ffd3e1bb17bb413a1  release/kernels/brs.log
e3c1cb3379580cf1aae44e8ddc8e846ef6fd661a573cfe0a8d4444b18a14dc56  release/kernels/brs.oracle.jsonl
6ec4ae7ab8a7893c6489af03af25fe6009ad6b63bb3e1be175c9a1e9ae5467d2  release/kernels/brs.sv-hosted.log
d58a79cf523ef0e6697e93153d1a1202cec7595a8dee9e6755af34984211419c  release/kernels/byp.by_instr.json.gz
6ff847c7630050505fed8fedb8c6b5a0eb7334086bab8683fabaf76d3a1c4af4  release/kernels/byp.by_unit.json.gz
e3480a496b7a1d2881af43ee09b2bb764b871eb942bd66bcbbaa3b537f536d6b  release/kernels/byp.ccvtrace
225cf1e7663b6d12f51936dba831960ac3c9ad10699db5c97fc2a1be3c11f43d  release/kernels/byp.log
5a03dfa4f3603fef49f1e3639e74e34152ca3ca5ef8e41eb959f8323040fa2d5  release/kernels/byp.oracle.jsonl
37a1a738ad427ee1d65dee0e7d8fe5ba0646234494d217f90500e52727806cbb  release/kernels/byp.sv-hosted.log
c6be7649fa1653af7c860296cee138884db6cf1bd590e570f10dc930301546a9  release/kernels/callret.by_instr.json.gz
b1bb26299736338e6f0d9cf6546ddc2f5cd2379186cff9c01268b7a5c794fe02  release/kernels/callret.by_unit.json.gz
5c916dd80f288b2e715c882c446ac317f3341d84638afb42c6d58461c0ae83da  release/kernels/callret.ccvtrace
de0f6d270390fb4c2e652bf91a289512b6f1bdd83eba63bb1b7a2509d577bf60  release/kernels/callret.log
9b1d1b50b527f732362f837250aa2f26dabf3e76e16a4794856ebd8f105635b8  release/kernels/callret.oracle.jsonl
110cdce631327608ba7e235f0ee36b01b019f0d6772d35aba6196650060a52a8  release/kernels/callret.sv-hosted.log
5c743a94d616adbf0b45d541ab38226c8e0d4be7c895141fc994dc685555cdaf  release/kernels/chains.by_instr.json.gz
146b9a71c7461fb33bf578aa9d70db102e6b44dd897de54ca07ccf9e1c4000ac  release/kernels/chains.by_unit.json.gz
94291c1a3431b8b84b1171b04f2fe0f6eb3300cd344c7e7e60928898254e9d63  release/kernels/chains.ccvtrace
ae1ddd5b5937f0ee9cbe35237ee22a50ed28e32865668dfae0124d454b74696b  release/kernels/chains.log
26a4cc5c5524c7219d8706c2582c80357dea60be9d6ffdec99dac7d0365e2264  release/kernels/chains.oracle.jsonl
b29d1a5917756fd696e7a447282a6ac1a36deecdd347902b2eb1fbe649d4432a  release/kernels/chains.sv-hosted.log
3b6c1decd3bed9814135ad3ae0164cfb782845b2751005bcb76dc23831ad0b26  release/kernels/div.by_instr.json.gz
05b526a54811f52b268c0f1a8646cbf0c4a7c6357f14d1b0e4df3f37b6877e3a  release/kernels/div.by_unit.json.gz
d4e3cf776f53afaf1f121e89f0ac7e7acf46db83e299dffc3a1f6992c2d0763e  release/kernels/div.ccvtrace
3f19524e7aa346347d10db07c74706b4331ce58023eb94eb63218cbb0f61d0b1  release/kernels/div.log
71a567b85cf85622631490187563de9a5661099c78a590adff4ed0a0c3d24c16  release/kernels/div.oracle.jsonl
72f225fab0d25e927fc5bf4ff7a02ea5b0a73761764efa506c625d700fce1c7d  release/kernels/div.sv-hosted.log
c102d5a8ad3cb49071d03c51e6b606971e1595cf62cd6d1a586234b4284ba65b  release/kernels/divchw.by_instr.json.gz
42b725bccb9044d04bbe1af79b13656af7d2993f138568e4880c7d0cfe14f9f5  release/kernels/divchw.by_unit.json.gz
36165621c49d40f4c9d967b694e162d58ca01a786ed79d7e9be7360be19a0bb9  release/kernels/divchw.ccvtrace
fb75e9aac96d7b72d56f88fad08738eeae02b10ce4ce734f9d078a496e6994be  release/kernels/divchw.log
58a541797f7a2df0a1c7528ae6a3edec212db90c7d3eb20656806f38b5c10b3d  release/kernels/divchw.oracle.jsonl
1809cf788bc2cbfd70dad9a09be19fb17857fb87322baa681d58b9215ed8af81  release/kernels/divchw.sv-hosted.log
472ef88f203c03321353155e2b69d824046e1831fce43189fda2bda66addaea1  release/kernels/divtail.by_instr.json.gz
f1caa3793cedfafe361215902dc9186c5d004f560d5762296cc316939156c910  release/kernels/divtail.by_unit.json.gz
038d13deb3b5c08bc95b16b8877467a9451dcffc9bc53d333486bf978cfb01d1  release/kernels/divtail.ccvtrace
928c41bdc4e7ec9fb17976fcaa49f082a314307fef345d55c32fa431d8c2fef6  release/kernels/divtail.log
75f11a75c9b3b336e446140af4579f05b46c363a76b7aab3ec88154a07ba097d  release/kernels/divtail.oracle.jsonl
0d5a667f9c7bb2a67c08c603ebae12d9152b48089ddb2e7499d0f493153980d3  release/kernels/divtail.sv-hosted.log
1ced4d9a6f709981b9d0393e791096ced92a84a0c99ad7ba0e5f79ac0b8d6008  release/kernels/divtail2.by_instr.json.gz
1f00fdb439dacf82abc28b347970a528ba2be4bb0a9f28af4b2af00c9091120f  release/kernels/divtail2.by_unit.json.gz
f5760eb6378cc178b8c80585c076b817040a0af3545f8eba2b17362e0aba7441  release/kernels/divtail2.ccvtrace
a0e19d19a924d3431f453087f2038044e30c4ca8acf4b97e0102599151505333  release/kernels/divtail2.log
b2db6b05eb6cf4a0a7677e31d0c6c2952d5cab49d353f0bb1883fe0b2a20ed14  release/kernels/divtail2.oracle.jsonl
3599905e182e3d22a0eff4a033c5847a118d64c1b2cfa9a11505f703de3fc07f  release/kernels/divtail2.sv-hosted.log
1bdb14678e268d41aa9f9188b720f0d000f020b26699909dba100055dc8e3778  release/kernels/fence.by_instr.json
0c03b0cbaafc9532a5f91fafe06643f139d14278b66a2998569785fa679b5c10  release/kernels/fence.by_unit.json.gz
f3de39e962c433133d04452e595dddfb100cd50cddbf4c626711c9236cc6afa0  release/kernels/fence.ccvtrace
07fe6be8c5c620669d1ca943b40884507e12ccf2054c6e8b5489a8aaabd04552  release/kernels/fence.log
d1d40317f6cf5bfb430cda1f9c0ef676609e59cabe2a11623c42ffbeca93142b  release/kernels/fence.oracle.jsonl
475f3457f3cb2652abe9ce5806f5019092674543ef105d852472fb5f08de5efa  release/kernels/fence.sv-hosted.log
71dfb61248d096dd8e7f789e0b06f0d64ad30b3e3b9d3360027cd779205426f1  release/kernels/gather.by_instr.json.gz
7b88341f5fd609917a8fd4dc21804dd8d70d6a7c4e658cd19a03b41786c8eba9  release/kernels/gather.by_unit.json.gz
9264d807aab095cd4ce3141f4fbc6a661ef5bd72ed384a647e735f1f1d294258  release/kernels/gather.ccvtrace
ec409c6760af7277f3f2cd4391061e54b0a30863e59520d8dad801c3685f31c5  release/kernels/gather.log
0413e781d8d6ff578c64eb1f800b7931e66f676d5cdabb97b94a4033e6037662  release/kernels/gather.oracle.jsonl
838586e1941141b8def1a2d42953d47aec408665d581f11610608f757b9f7a75  release/kernels/gather.sv-hosted.log
1185359bf02f998d783e05c23f2f6a79f54485308a2012649b7e1b9afcba1ced  release/kernels/hit.by_instr.json.gz
3bd390108b109fe7ae976fb7c3b9861f95b302935bda2b7c66b5b01b043b27a2  release/kernels/hit.by_unit.json.gz
a21884ff3a5bc45b0719725c1b08b9dafcb896df33e9129726b0a6f8f2f62c5a  release/kernels/hit.ccvtrace
675664064d88067c20cdffe72f4accca7d89ad4042ac8405952ce7d48d43c1ae  release/kernels/hit.log
7ba9603e0088d9164de6528f16ef6a7fa9ce5821c8c12b52cbb3734e39b9fd52  release/kernels/hit.oracle.jsonl
2408aa7608569453939b76fcbc49524f58ac8bedccece5b306c36b3a1fa8f125  release/kernels/hit.sv-hosted.log
36413b927523f1fcc9b160138aade2d79ddd8c21fbeb0aee0227c9b8ae4fd04a  release/kernels/lanectx.by_instr.json.gz
e4a536a3ad1bba519b99a540ff0295e5074eecbbb8f142f065b0cb906827d5fa  release/kernels/lanectx.by_unit.json.gz
b8113fd30054885d1c08728f37eeadc557ec3ed260e5f572d8275925e2ec625b  release/kernels/lanectx.ccvtrace
d61de36f67a23d7f6bf6ecc47e74582f85f7ed5848d23b747188e31f4acf3e5b  release/kernels/lanectx.log
888551babf540db8e3025b82e65ca655013f93eba3c8a65689d069d52a7e6039  release/kernels/lanectx.oracle.jsonl
c76d2b4a1b37a3ba6fde2eae0e477e1a3b73fbbf4b245f186fc0b61d71fdb43a  release/kernels/lanectx.sv-hosted.log
f4e65bf2a63c1af9a60bc88d19c656136e197a966d146456f36b0d2692fd3493  release/kernels/lanectx2.by_instr.json.gz
a423947eeb00737a9c011844c3a02debb8cc28ba00af3cf5b8e135d352bb4f1a  release/kernels/lanectx2.by_unit.json.gz
2fc4e806b0251780aab41e915640af360d2330e7985ab9f857a899d30401a43a  release/kernels/lanectx2.ccvtrace
d0229a8ba7e051b55f149b59f9fbd8b028d4124dbf7d0d7330079d2b2f784bf5  release/kernels/lanectx2.log
45c13056dff5c73ed0c9ece56cc36f929bf335322193c7d5eb38710b1d1dfb02  release/kernels/lanectx2.oracle.jsonl
6690c45e528c330382e9bf4d1ebec490747144cc025bbd23f3cdbc4499333d85  release/kernels/lanectx2.sv-hosted.log
eb5584db5141a74921b09473bfe501630c57af32b8db76e2c005dfcc90e29c49  release/kernels/late.by_instr.json.gz
5f88975bcde94b0313a088e24ae113ecdd1f29429b05d1e24c7d0f27decf75ee  release/kernels/late.by_unit.json.gz
f4fc47fe3ad032977a338a3981b96518a799d313c6ccc4880908bf3646f55aa2  release/kernels/late.ccvtrace
dcbf1e40beaf1927586e65026574899c50a833f190188649659b2982f776a8f3  release/kernels/late.log
86084f6bd747a2cf32acbc0ebd96ebd3e4ef2d8d9e21be49e3ae49290d7927f3  release/kernels/late.oracle.jsonl
e7e4ba0aa831f4f12862c8dae48e8451ade4de3fe30054c5f9da81096bfa7857  release/kernels/late.sv-hosted.log
d4feb823331a765d91d21af4202d5b3dda661b6250df34a19d6a6bef59edcdab  release/kernels/ldpar.by_instr.json.gz
3d08eaaca9b4d6d956c5a1cb016993758a059ed291be2644f9429f666c031e06  release/kernels/ldpar.by_unit.json.gz
859d131606c248d7feeee7753a2df6702437f1bd1b61f3073ba90cb84b7d3eb5  release/kernels/ldpar.ccvtrace
f085f2b1b21842ab2fa128c5503ba5c8ec1f9d76d926e376af4798bb255d60eb  release/kernels/ldpar.log
8ac08538e9c807637babd61b31e340f7461878ada31f0c0b83cd66331cfaf486  release/kernels/ldpar.oracle.jsonl
a9205ddac43767f206f5d7b41a9be1a26ca7f8c15c3037050e7fd48ca2eeeae8  release/kernels/ldpar.sv-hosted.log
61a8393f3a35a3a577071eafdc1e20d057e04635810727c83d8a7f5aed53afd3  release/kernels/lnorm1.by_instr.json.gz
7a4faa394c1a3cbc5ef6b75c35b2b80489db158d4973d8038382303be83c2c84  release/kernels/lnorm1.by_unit.json.gz
84b6565d96bb9bf341ec04a2d92c081195ced87a88377e3da93d9e288b49c9aa  release/kernels/lnorm1.ccvtrace
e24e2e9d79a4afddaa027efb8f52c00404e7137bbd4ad045ebc769c74b0b6136  release/kernels/lnorm1.log
a8d85811af988a1b9fc00db1517300af3d93ec8e589e403d3b9113fa9e0ffc86  release/kernels/lnorm1.oracle.jsonl
a9d084345d737ebcf581f7d3b111439a13deefde0a3384b28f23246b1a10604a  release/kernels/lnorm1.sv-hosted.log
a9af6eebdf8067c15ef05854ab658ea4fa91a318a75300a059490506323a0828  release/kernels/localsp.by_instr.json.gz
286eb0f0a34ac967f7bd7c69f3b336959511ee920eb981f611d289fcf38975a1  release/kernels/localsp.by_unit.json.gz
994efce3ffb67f5fc232b7542d2ffb40a1b1ccdd5ca42dcc35a95ae5836eed55  release/kernels/localsp.ccvtrace
1f1644be5da2e1f2d0ce0321a5f047f4f6a2a1ae7fb62ea6a608b3837eed43af  release/kernels/localsp.log
55e3c9f36e7f7d38c0ddd38903aff4bb4509ae862015c592e6b937ea258042ca  release/kernels/localsp.oracle.jsonl
2a98d287cb82dc0c4e057904be6ab421d86f831deb27ea9bfd91f3e90c0e390b  release/kernels/localsp.sv-hosted.log
cee6c56de1f36bbc7ef38a2392d1692a1bf969705e195e98f773b04df83c85a4  release/kernels/loop.by_instr.json.gz
f7fc74ce1c243da93076e44887d7f0c32ee0e7ef8d5f74204640282a7d0db186  release/kernels/loop.by_unit.json.gz
d97f745235554b110bb5181b2194e2a3227871552817968e4dfba9de82d8ce40  release/kernels/loop.ccvtrace
23a1e4d0ea3abad280ea43c7045d8c2b4bb5f255a59e38561e280e7e260641bc  release/kernels/loop.log
03ce5920c06c93e93516d8e53c3f7169f14e3593de204eacceffc0b8a3e32016  release/kernels/loop.oracle.jsonl
c1200c9e41dcf46aece3d3644c752d40a12e1aef085f3c8ada614579261b55f7  release/kernels/loop.sv-hosted.log
034cc68409b60960ed71db3094f9cab7780def05ef3a0aba1ff1e2c819672a21  release/kernels/merge.by_instr.json.gz
26eec2bc3175b608343e876c2613baf2c8b11fbdb208609dd8f783c246ad437a  release/kernels/merge.by_unit.json.gz
fb3738c6d842e8baf329dbebf4968b4945e0a3fc632251d675b1b2e098ab48fb  release/kernels/merge.ccvtrace
cdf5c066c6904bd3aaf1dd1e0b86bfec3f59c6e0cd31df488f196b341ed0122b  release/kernels/merge.log
f96d28815f8756b1f5a45ded53e6170883d2dfa10f9eef0d14b8050b1318164a  release/kernels/merge.oracle.jsonl
377ce8971ab05458a3fe363a980d029ca8fafae5977667c3a2a5f1f6a04d4f07  release/kernels/merge.sv-hosted.log
9977a469d5ab153d0935a43479c462368f6cb39d3c606bdcb66e1b3650f98b20  release/kernels/missrun.by_instr.json.gz
b057a033ae1122efa2e7762a529d7c11d0a13379faa16d87c31295fe01b792a0  release/kernels/missrun.by_unit.json.gz
95dcccf10f536cd7452f5d2e81951df113faa65567f9f0d4d0c5dda4fd3bb89b  release/kernels/missrun.ccvtrace
5fb6b4640dfd77185544aaef5ddaad59d29ecc05cf4b5891c4e0d0904edbd887  release/kernels/missrun.log
531bdaf281e5590774bd2775427f25e4cc0419cf8e3d5b6999843ffe9ef87258  release/kernels/missrun.oracle.jsonl
29d2fa2b03ca1d6a9fc4905fe4ea2189957ae348d2822101be033c0f3fc80a49  release/kernels/missrun.sv-hosted.log
5a566aa66b5f1672778d145240b355dbda7b25f86713cd3f2e8c4c49b45bdd3c  release/kernels/mload.by_instr.json.gz
548c83f8e6e70fa88b63ff20cef154aaeaae4ffc70687eab9c7c354518f68c67  release/kernels/mload.by_unit.json.gz
6c51ae125f57419af5b4a0b83e312c614f1a11addd8fc8b6fad836734c264ead  release/kernels/mload.ccvtrace
fd7507cbc396aae4e1d93ee616b04429233d882f0e43afab4e11a1f2533411ef  release/kernels/mload.log
8000e477b9a95dfb9f0af964e8346acb9d36f1358fd06ffc4ff7cf599d2b8868  release/kernels/mload.oracle.jsonl
86e27c53cf117e1e737bb73c739029c026dc0e47eae288b6b92fb25771008be1  release/kernels/mload.sv-hosted.log
ce0ed818bb52d8bbb3ecf03fbbeaaa20e2136efddf0ef50fd39ad9d18fd7b63b  release/kernels/mlp.by_instr.json.gz
c7f2bb967a88c6a5392bac915acb1e682c276010a402147663b0adb83e93e975  release/kernels/mlp.by_unit.json.gz
0b70f24e8ccd473fc49b62f1ef3a71388265aafe5823ca8528243e53bfc4b8cd  release/kernels/mlp.ccvtrace
f006e4046b851e506d21ca735f7b53ad8cef896db9a04c3fa500f28788d1183a  release/kernels/mlp.log
138d282f88d56c8ad648a91af0a983254b55d9fa22942c00d47b327f516a6e44  release/kernels/mlp.oracle.jsonl
b2b5fe2df7e129631b460012f2b1f262f23ab0fe0cffb8375a5907fa0fbff271  release/kernels/mlp.sv-hosted.log
3687b47aecf7a0e5d48df77d0558d667c4da03debfcfda9d24f383836539727e  release/kernels/mwmiss.by_instr.json.gz
e7cd678c9745ae9583f9797bc7ebe222bc4d3adf0844a50832ec13decf3d4456  release/kernels/mwmiss.by_unit.json.gz
bf58bf5dd2a060867fee471eef821369e5780d47733556f608fac4a4eb24cce6  release/kernels/mwmiss.ccvtrace
6ceb1aa542a6b2155c23999b7a57838cc3b2c5f9ae235110cf203d285f99a748  release/kernels/mwmiss.log
8abe8e8997456a2a6711ee72da54d854b24e20abbdab28e4b7271c0d28418de8  release/kernels/mwmiss.oracle.jsonl
efa7151322d80b8336dd92a7f5c7120948e365a96bb6469adf9f200cd1ba6387  release/kernels/mwmiss.sv-hosted.log
0e34b5f3553486268b8505860afd129372f8a3d5a449987eb9a5f140be5f01ba  release/kernels/narrowadd.by_instr.json.gz
b6d5e01ca27246c897dd00f0fa913af0328d39376e3e83ae8122b42ea6010cb6  release/kernels/narrowadd.by_unit.json.gz
43094e3dfb54bbdccbd1486b3af3b739fbdc6e2c5672b5dcce010be51613c42a  release/kernels/narrowadd.ccvtrace
78f1bb621f4a30dae9bd0e8c0953fc7606bf0d32789e3c29c29a5536f35b41e1  release/kernels/narrowadd.log
40a2cf629853dd404bb06b4a07e35abde3d12efc13f26ffe28f923daf2994574  release/kernels/narrowadd.oracle.jsonl
606dba0fe2e35e1afe207604650d6718f8222799d04b25268b1f8a32467568a5  release/kernels/narrowadd.sv-hosted.log
14aea5dcccd5382f1d60ae801f849291420b467871cb32a660fca1e390de3612  release/kernels/pguard.by_instr.json.gz
690f1405824a510940f0e2876ceafa100ad74514e339def289c1a2d4af2feb25  release/kernels/pguard.by_unit.json.gz
b84232a13c63382123e18ec951dd642cb132eefd21b44fff8f49c69c7339a3fd  release/kernels/pguard.ccvtrace
7cd9b0ce896540cc1f269e57005b01708880f447fc2f7a59baff8c257b189ca8  release/kernels/pguard.log
690e56f1cb8d97cbf67124b7dff3ad0a90cb8981814cd1709cf0cd0e035b3bd9  release/kernels/pguard.oracle.jsonl
a1918608ed67bbfdfc00c7fc9beb3c958c3a7b3812eec7d37ef62ee0e32a8f08  release/kernels/pguard.sv-hosted.log
4ea240813b3dc2d9049575861799c6e15da23af45c567e62a180ace793ba6824  release/kernels/plog.by_instr.json.gz
5d04bfbaa7446fb9d059f20e2b971f0d3cadefaa60b509c580c60313ec74ebe1  release/kernels/plog.by_unit.json.gz
e32ed8b48729d559c9d9c92968577d8f87099c9bea1562de23e434a7e966bd69  release/kernels/plog.ccvtrace
0bc0e407ba83624434e0271242283312e78976eeec5effd4adb93715334373e1  release/kernels/plog.log
c230f13f2e1082b306a9c5ab7809ff36cf5c1b2e47dca6b7a71f741524d403f5  release/kernels/plog.oracle.jsonl
3c4415b9041db753e081a91a72bb6dca5bc37e13da6dc637071a208a2c92d869  release/kernels/plog.sv-hosted.log
11f39739d060ea9d36863ab80427b1753cfe096f23e1891593c68e27d0577d42  release/kernels/predlane.by_instr.json.gz
d0742113d6956528f58d1d643ddb3f3fa7e059c08267729e0a4308ebed230f76  release/kernels/predlane.by_unit.json.gz
641cf1d52a695531f36a20efddbbf13f4b148c2b9f86e004659ef2817c6c9e20  release/kernels/predlane.ccvtrace
48e23a22553128cf727f38cdab3f925391b68829edec1860d00cf08cab894473  release/kernels/predlane.log
c45f4177b9e84fc8a6e36b13534a0c7636eb30a3f8531847100ce5e23bf404b1  release/kernels/predlane.oracle.jsonl
182a7f3412859eef03bff045a7a32576ce979486d4b1117b375086970456c74d  release/kernels/predlane.sv-hosted.log
7e9b60eef9d0bc9a89cf244634938789678e5790f015129e0f578ca6d5820482  release/kernels/predmerge.by_instr.json.gz
519f3a454a3021a933b292767e495a6cb244c510c29810efc273c6e8d4538ba0  release/kernels/predmerge.by_unit.json.gz
a67d904d96ccfdbf5147b5795b7089099b2717cd21113c27b69c379c41e20e3b  release/kernels/predmerge.ccvtrace
4fb58fcb0c6f5a70de101bdd16ba56181174b39fd14ec75a351a125a226cc9e4  release/kernels/predmerge.log
6c737c49434bcd08e3e0814c8b1dbf15c586ae74f7929ba3148ddcee2c62c845  release/kernels/predmerge.oracle.jsonl
c8c0fd1691273184d4e343639651e1559352c9c2c41ff5c72ee73b352cf13816  release/kernels/predmerge.sv-hosted.log
f6bcdd411b1e0c0378bbd34232d8659788489e2a37edee60420cd5b020df10d4  release/kernels/predspill.by_instr.json.gz
39607c2ea8a53c0e45d04abc6ded1f3ab7311aa01676a26990fd646b97489996  release/kernels/predspill.by_unit.json.gz
01824e6ce8be6f51721d98514eaa04cc22e23ff2a0259f56af167900f52f96ab  release/kernels/predspill.ccvtrace
9ea5cbf026d07d6e2a27fd8e44c73207f33085368e3bc45290a58b7f4efce5d6  release/kernels/predspill.log
b7c84c6478117ffa0f06da0e6ad1e4628e2683426a7911080810e78e06a5242e  release/kernels/predspill.oracle.jsonl
76565bf27f2ee87231f533c3c017b1a009346c5dff583e15f5755d904fb90651  release/kernels/predspill.sv-hosted.log
70e10a029fda89e75c3627fdbbda42fb7eb8601fd21675eef8e7d0eec691b8a7  release/kernels/predswap.by_instr.json.gz
90b3209bd1c466f232dbfd77dc261465010df5196daf71290e51e959bae583f3  release/kernels/predswap.by_unit.json.gz
b000a4a9d47b149ec19f0b41262ee400c37d8c757114b5e964f26941976a4b0f  release/kernels/predswap.ccvtrace
cb25e92c8bb95e3ee0492a3550857382e599e7f6e8becfc8e852c85f486130c4  release/kernels/predswap.log
a6d4f7ed517553816d889c7c9eeb6bcfd1f6c973fbf682ecb69f3c2de619f7bb  release/kernels/predswap.oracle.jsonl
4462c764d0503e68446478a7eef39d2236d0dd34c605c6b869f15173c0565a26  release/kernels/predswap.sv-hosted.log
3189d48d9a2c1ea0a36c8db3d82942cded82ca1379540e4fd032ed95e1c2796d  release/kernels/provswap.by_instr.json.gz
76986aa1699dd95f0de913e284eea2499553ef04458a6518e1ac8320f94d88cf  release/kernels/provswap.by_unit.json.gz
2d8fa3a3fae9bcaed3c82f6aed6f17bfb22492c1448d16b2ee2d3f108b8fb0a1  release/kernels/provswap.ccvtrace
be20ce6abc3bec2fa47e1e303717f3aa3a41cc1a10d9b1a6e0e8f16a426302db  release/kernels/provswap.log
c9c32a793d54cc7401477f582487f7e8b345b2669a75337b8d6327120d98e5dc  release/kernels/provswap.oracle.jsonl
4799a111c3907e382216c3e1b418125fcb2567bbf87dd16309927413d4459798  release/kernels/provswap.sv-hosted.log
bc78212fb3eb25a011a8123c4c1f4f52a37579dfba964059b435dacf71198f47  release/kernels/roconst.by_instr.json
79d82b16fc17f58fb96fe049401a9ae376289313248707f0a00f02a0bfee4cbe  release/kernels/roconst.by_unit.json
67cb3eae07ee5e7c2b5189ab3ae0b9f61a2288b3587134e3f81c30c1a2e1b664  release/kernels/roconst.ccvtrace
16c1f519f57131c584079ad7d0846c07d3b2c9e93b101976c817d1637b60c9dc  release/kernels/roconst.log
8087c0671de620162881aecd38cd6114b78e7be6bd71201e3ec02c9a2e2e750e  release/kernels/roconst.oracle.jsonl
80ea591922e882a4b906e0ea00ab2dc4b9630ddf7bef84eb19d8128d5a4fe54d  release/kernels/roconst.sv-hosted.log
97f33ebd4e213b24c8fd8e9a1a66978cbec05d458b20e52d6c64cb884a9eca98  release/kernels/rogated.by_instr.json
ed567c5f77b1e1a63fa01209f942f88e530a78f891305f15366c7ee48d670ee5  release/kernels/rogated.by_unit.json.gz
f66f987d8fc2f520bd60b6879774625aca083d99cc945d4f9f642fbd07bfb4a6  release/kernels/rogated.ccvtrace
4d38c293a5ff52300bb38857ceda8b927cfc5ef560a70064526071aa84f189f4  release/kernels/rogated.log
7cd02bd4cceec5a044d6b4d6a80df1e68ed0ae71b0b2a953143636d5b809ea6c  release/kernels/rogated.oracle.jsonl
4cca1f58be0ef20858a30ab9dee38c04e3a9bff68b3ffdf014509b84cbc5ed4a  release/kernels/rogated.sv-hosted.log
30695e6b1bd0150ab35f8f28222e001a67b22240981b5ad972b51ce631829a36  release/kernels/rokill.by_instr.json.gz
b37b081876b3eaf55a688289c44cf751bacbeff768da73a82143d01497a2ce25  release/kernels/rokill.by_unit.json.gz
786bc1acff229f74556953efe75f61182febcc4d0bd523b01e3877be3bd197ce  release/kernels/rokill.ccvtrace
ef6f3b7e640b4212980efe9727baed2fb9b021dbbc4d278bf21a96df5ea86263  release/kernels/rokill.log
94efcef96af469a512d346ce61623980fe86383188eaebd55120f716db596f14  release/kernels/rokill.oracle.jsonl
1ba17a6bee87e38b997b7fe3fd06568006701e8908c2591ace9a0a1a4b52c26f  release/kernels/rokill.sv-hosted.log
f41e6e2e961cd580d1cb70c2a7f4b0d5a5009c7d936e611e401b661c48745392  release/kernels/rolaunch.by_instr.json
7deb59c3a34a6ad597d362605214b2f8c5608fe4b96916c8fab8e2368db4c3cb  release/kernels/rolaunch.by_unit.json
03c1532e55928161a52bd3a508207e2590d1e4a67091d7be62e55942c13bca02  release/kernels/rolaunch.ccvtrace
c3f1c59be348fb933e9a77e3525b1d78bbf4f378a5d73a9c52d0f9c69ed0e0a6  release/kernels/rolaunch.log
e7dad585c3e70615de04330fd03f4f282c29a005dc1732a35655fb261d51139e  release/kernels/rolaunch.oracle.jsonl
c6489619d84bf66f65f48d3ab4d42ab969d7295565c49f409cabfe985b549d39  release/kernels/rolaunch.sv-hosted.log
bc78212fb3eb25a011a8123c4c1f4f52a37579dfba964059b435dacf71198f47  release/kernels/rolimit.by_instr.json
7025b72667e0598aa0fd20e979b43d7742034750ff615788ee249cc2f71e2106  release/kernels/rolimit.by_unit.json
7fd9c08101c7d3d6da8773714425093d1d1306293c81245e32587716c2d3c044  release/kernels/rolimit.ccvtrace
152848f5b56555bc4202d44c78a529ccefdcd38ef3e55551ab8991e06a6fff2b  release/kernels/rolimit.log
1c5bc0cb8e8b2e69505fb5a551a16d5d10c56f232b88da7a27e336ad7d962de2  release/kernels/rolimit.oracle.jsonl
68e89b56bdf505bd3d715c99daf2140733bc4e019d48c9ffae952d6ed9293b0a  release/kernels/rolimit.sv-hosted.log
3dd0b7f7b43cc8234c2ac488d6685f524b7cea4bb5e087e646d4dfd046ee5cd4  release/kernels/roload.by_instr.json.gz
45fc133ef27051df4b9a3b03dec0ecfa9fbe785ce484a8d425ba47d2b1c84495  release/kernels/roload.by_unit.json.gz
211940a7f07b77fa9bb7955c575e00dea06e88b50e1e452d1e6254218513c542  release/kernels/roload.ccvtrace
db4c5f5668737588efecebcf741099ce7d3870c886452af467e190f75aa00767  release/kernels/roload.log
f7c1309cc9764769fb5803f6fd0f2f5e1eb418f2d23fbe5e17cf5f9106869fdf  release/kernels/roload.oracle.jsonl
cef0b5b3f0ad66c811d7b42d0add8b8b15569412bd471bad591041c509c4c1e7  release/kernels/roload.sv-hosted.log
3d6c6320745e4b4209c0c7d919a99b4256139273981ab1decfcbf7a57910fa4c  release/kernels/rope.by_instr.json.gz
2d25784539e5b44e230eb3e6b45337f1a8d052df6427d035c9e75db9f1d493b9  release/kernels/rope.by_unit.json.gz
ff40280d90650dbd0771b074cc22c93bc9d95b053e0b2ae7bfca85af6924419d  release/kernels/rope.ccvtrace
0baf9ee9a5460966e74824d4b12f5a8d9ecc6fb0eabd7e1635bda11b35ef50dc  release/kernels/rope.log
d55f9efae392dc8877c102c01c0810e7654b666b6ede386328108164c6cf88f3  release/kernels/rope.oracle.jsonl
da10bcfaee414dde5a466b20e6606c3d1c2b0755108504f8a588c64ce6f04e40  release/kernels/rope.sv-hosted.log
75781262d53548ef38ef57c97b5305ebdfa3c658a001b4437150717b2b8f88a7  release/kernels/ropediv.by_instr.json.gz
7c24b4a9957e59bf8bd614544834abebcc750eae5e01e35e314b2eb709a54ffc  release/kernels/ropediv.by_unit.json.gz
b85ca78f64f20b2220b3c38074936ef5edfa8dda0ed4cf07bb6266aa7a3df6ce  release/kernels/ropediv.ccvtrace
3e5368f9ade64a07c4f5fed2e501c81917fbb0585bb38e43741911fc711f3ed2  release/kernels/ropediv.log
10c0ec6ec18b7b44638c790033109198c079d07c1537bf193353ccedd00a920f  release/kernels/ropediv.oracle.jsonl
e5f6b9e2fd4a49da92dff67862c109b910c638a1cbbb5f5885d33510115aa497  release/kernels/ropediv.sv-hosted.log
9413862204b3f0bf78e204423998b2099eb6f91111a32cd73bc2ad7beaafaa35  release/kernels/sel.by_instr.json.gz
9e61386e8ae63eb053514d77060836ff37de4b30424dd499e0489c737078ddfd  release/kernels/sel.by_unit.json.gz
d647e23e18e16512cc2061f4c5ef8fde687a47a2e11482fb7dfecd77a7745778  release/kernels/sel.ccvtrace
88e2ee81dfd0c40864d57563ba2cd91818339bd473f134a0b23e4a39f3c7b90c  release/kernels/sel.log
87f6a81e8afa004c8039bf2f61c90176fcf29ab29bb17ac44aa016a5cc8438fe  release/kernels/sel.oracle.jsonl
266578598cb4d7998236ce70f0495e73931c239fba019cd05b39b0d4b2fcefb1  release/kernels/sel.sv-hosted.log
60c58ac71e25d9f79c2c0cd679eb2a7303efade878b14010399067c4c6bd9da1  release/kernels/sized.by_instr.json.gz
611026d1d2d6639c6a9c9d10ebd2ddda9d807693a919d7f7a5c3b4c54cf94b32  release/kernels/sized.by_unit.json.gz
3680714c49bfe395699a4b7dd792e1e24407e9b1147f6d87455a820a0e896d46  release/kernels/sized.ccvtrace
6f6b291da87887735107aeafd012331af82ef09e807fdc906eff72b45344fd4e  release/kernels/sized.log
36d903ba1618bd1faa437c9812a6ee6c0c966a63196c796267d74bf2695ebc3d  release/kernels/sized.oracle.jsonl
8ad80a3c349444bfa0ee813cd53ab2f09a70b56d75c002cda4aa4c01c8fab093  release/kernels/sized.sv-hosted.log
49471fd9dd62482320317883128d858cd1811cab55ab7508b4b650ab9b8027bd  release/kernels/slotform.by_instr.json.gz
0ccd4a6ab7c743604b723154f8623a164c228f336e83996f6bc597a1f4a33c3c  release/kernels/slotform.by_unit.json.gz
888c7f098d91898c85e0a75eb80bbd7cab64b2c8726c1dd7843e3c1c30642169  release/kernels/slotform.ccvtrace
d2525843d0dc07fe375248bca2bbd166b54a9ad13e5c76568ea30abe1f67fb7b  release/kernels/slotform.log
8b61db7419b18cea8a646fb628218447e72e84a18a9891ffb73b441736138ab9  release/kernels/slotform.oracle.jsonl
3088d3559fdd829de8bae500e849592b1df27124a3fe468f58b7acd0ef246e88  release/kernels/slotform.sv-hosted.log
3813429439bd71d8294dc637cd83aca8862e2f129eca4854bb2cb9e5e3b71c85  release/kernels/spinwait.by_instr.json.gz
6ded3059f71347510298b955990cd6eb11743364a149c8e0e31463b266baf3a5  release/kernels/spinwait.by_unit.json.gz
11b2ce9ea1695c9698cd05836e17ba1d27993c2b93ffb4367499d3d83ae14bb6  release/kernels/spinwait.ccvtrace
5e587e376c444fca04d80f59e88a8df0031306c85ab4bb511183e01b8beea9ad  release/kernels/spinwait.log
868920637236c878b33779bd450439466fc3626996a3164573dc11d437d5c709  release/kernels/spinwait.oracle.jsonl
3f609b53336eda08ca1dab099bd686984f1cdafcde00991612476b6d62cdcba3  release/kernels/spinwait.sv-hosted.log
5ae66329774c45e1bf5d68a3bacfadb62ce9260babce6cf500142b4b98346643  release/kernels/spmbank.by_instr.json.gz
0e5694627c136756e28f2b78c1ef469225850431380c7b12c1a257c5b512b21f  release/kernels/spmbank.by_unit.json.gz
04b3dbe95ec991b471ee85d502128c2b90ddcce0609e1de27b77e4bdb5ba4042  release/kernels/spmbank.ccvtrace
51e217926e744123c60ea897913cb5eba755e973fbab21ea11700aacfb636f69  release/kernels/spmbank.log
3af490cc37d7a92dbe719b57de216b648536eb301ff9d13de9a39f50d150d725  release/kernels/spmbank.oracle.jsonl
101970f84345474e9d57911984ba633fc0cd6fbfac5f8e675f26a8798f52264b  release/kernels/spmbank.sv-hosted.log
c24f23a734d4fa8e4fc21c5fa30722bd222dbf1be1586fc5a8b9c291911df72f  release/kernels/srd.by_instr.json.gz
859f8fb7f19a727732dadad8018566ce32e73529ba4ef461872c9e31e58b390e  release/kernels/srd.by_unit.json.gz
0de6fcb70c02376f30c7eed67f0cabf4cd00fc874e9d95f24465e7d79129b3e4  release/kernels/srd.ccvtrace
53e2f8ba8404d0e414d1b76f77099ce0c03d6b4a4ea4e2ba8f729c641c003772  release/kernels/srd.log
b08eb5e3673cac7eebb8b72af5ed3783c8e70a9e96592e76bf3722551bc79473  release/kernels/srd.oracle.jsonl
47a65e3635907842ba98b51cd78ae62b79eb4743abe30a4b2de38799ce3ab918  release/kernels/srd.sv-hosted.log
e57d32c20475dc2ddedbeedfc13bdf7f817eee39f1366d5fcfb8edf05a5058c5  release/kernels/stall.by_instr.json.gz
24b0c4d1a813c828656d519eef594a77b22b76a20f9948f996c8fb0076d61478  release/kernels/stall.by_unit.json.gz
31de6d003020b11ea8584ad619db344145f01e01a531105af995c6143075253f  release/kernels/stall.ccvtrace
80781eec16f4e0230a97e0e533ac2f523e5c360fe779c689cfe4edb30fa31e53  release/kernels/stall.log
500db2c482b07a0706583422cd68878301d0146c1f872ccc1f11bfdcf5c993ef  release/kernels/stall.oracle.jsonl
352c414fa907246906c34ccc24c544ce491e29c85a7bf596449f6a555e997017  release/kernels/stall.sv-hosted.log
d143b3bffc3f2425088ed1dcf944f251dc19e52bdc649d7bfc62490a2cbadbec  release/kernels/swap.by_instr.json.gz
a4f497e7511d6a0d9777d840457c3ecf5ac767da2e0e6f7f9ca0db65d8459e87  release/kernels/swap.by_unit.json.gz
98e5250ea60a91a2e8a4d31e840a523ba270776e134dff62868d4060cb59ef1e  release/kernels/swap.ccvtrace
d128d587bd09789650fcdc4511bd8fe8439e93796e23db2932564604d2f68ace  release/kernels/swap.log
3658a26316c1ff7bc1744304a42f736e930fcde2865c8913e6cc67a22ce96667  release/kernels/swap.oracle.jsonl
dbf558a290eb56ac24ff617b54b2efe475ed104b856ba9aeef07d64c98b28bc6  release/kernels/swap.sv-hosted.log
df424567f60f458c89870ae635eb2f6289d7059572876bd8cde601200441550f  release/kernels/transp4.by_instr.json.gz
2534afcfd2c5fd0c8f86e4293988713fc6cec47ff0a54a5492415033780c2429  release/kernels/transp4.by_unit.json.gz
a0a8df7657550fdb1bee331e8df19475a93a60d6c46710060c0c68c2c74cf484  release/kernels/transp4.ccvtrace
d574e91770a8457bc2bfc06c1c302564409154943471f131baae30dd5327c4d2  release/kernels/transp4.log
06396ace3ac19677fd39c700e408606e5bdbacb24997d663bbe8872e63dd74fc  release/kernels/transp4.oracle.jsonl
2b069904274151483f443deee3a37378d73d97ebb294104f5cff53778b814496  release/kernels/transp4.sv-hosted.log
87c24406436052f8e943c0fba2115ed70b53b6f218dc7288425ebc8f43afe62b  release/kernels/unal.by_instr.json.gz
bf0cd17b00cb9c730687b53038e1218bb5a5cce1ae5b41f208b60d737840b51e  release/kernels/unal.by_unit.json.gz
96227d2f550b50685353013980833df74e6e32c1b243ab11c0247caf0bd95e0f  release/kernels/unal.ccvtrace
a750273deb9671fed42ee1b936d88211530f906043d6f5f79742cbd1101557e2  release/kernels/unal.log
c3d484bb160657a563df983d9a2532eac27f556636617960aa1e72183ac2b299  release/kernels/unal.oracle.jsonl
c5985881be191fe30cb033fc8be42234bba77babe558e266ea968988bc898eb9  release/kernels/unal.sv-hosted.log
ddbc4346ba7e944cfed0eca73dd1c647da425ea329543f69ec84e5eecfdb9575  release/kernels/vadd.by_instr.json.gz
6631d92669fe06e2317f3a27744be60793c76dd1c920f89e853a24742e09bc68  release/kernels/vadd.by_unit.json.gz
ceabf8fd66127f2fb44be921451fbb1d44658725452efd82cefbf5e4f412af3e  release/kernels/vadd.ccvtrace
9ab479a142f1ef8a2a1d304420661b5cbe6f1bab8089daf18927deb1bea896de  release/kernels/vadd.log
0276b6d0611a4bbcdc004ab3987214aea138245bc7217504147331689a9c0880  release/kernels/vadd.oracle.jsonl
69fe3581711e11c25860d3971fa6398d07e16474fe84ae1f1d139830c89c55e2  release/kernels/vadd.sv-hosted.log
ee3a4de203d44d6f9f817907d3644f36f06aa4329e7a0a7347b9853dc79ca6d3  release/kernels/vadd4.by_instr.json.gz
30e7c281e6a257a1d6727f30e9b53142d7cc68fe12f8a1d98d218717e0eadc9b  release/kernels/vadd4.by_unit.json.gz
6fea84732d60ebf4629c215114af5415cb3f386ef71f38f6bb503e52c4bd1b56  release/kernels/vadd4.ccvtrace
daeef6e0be7652f64d9e98447616867de79c76fafe14a78e1065fde9b96bc626  release/kernels/vadd4.log
225aa18fc9f38aa9ad615aa11de254337d59fa705877553d873062c68366e0db  release/kernels/vadd4.oracle.jsonl
75edb426424270cd96c3c217dc6d98204dbfa454c411c4e05779db4dfdc5b860  release/kernels/vadd4.sv-hosted.log
38a52754730936e166c05334618b33be3642a01083499377e5d910de7ce7bc64  release/kernels/vaddslow.by_instr.json.gz
cc633b46e32df17f59de633fc4409bb1be1025c0754ff8d92ea101dc0bf7088a  release/kernels/vaddslow.by_unit.json.gz
e1c7ff119caa439602b0926aabcda0d2d1907861a3d0c780857cfeb2c239151a  release/kernels/vaddslow.ccvtrace
bd5bbd179b96d96cdc22abe599acd34eac956aaf0601970a5e3972c8bbfe7d45  release/kernels/vaddslow.log
e9e6218e8b8450e9f9ff6b39d659c994a1e51c527a0c5bd10d18b5658ae0e344  release/kernels/vaddslow.oracle.jsonl
f5d95ffa55bd63e2d97ac6b57d0783773b4ec37c424e4b147fea970998675dc7  release/kernels/vaddslow.sv-hosted.log
bdaffac495decc983d8c8c4e58a52ea03155d2e75fcf2a4101709482d5b0598a  release/verify.log
1f3a2eff14dbda0754e19cbf72bc5003c950fc7d1691d527ce3a8d427fb583d7  release/wiring.txt
```
