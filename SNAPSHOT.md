# Snapshot snapshot-2026-10-30-cee7416

**A generated, read-only snapshot. Do not edit or merge it.** The source
is `ti-ret` at `cee7416e79dac2e231ea47fa9914950168f1cd6d`, and this branch is rebuilt from source by
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
| Source | `ti-ret` @ `cee7416e79dac2e231ea47fa9914950168f1cd6d` |
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
8ebcf85e62f6fadb35b8a15282bc77479d77a4dd4b9c1b4ca6d534db1bf5cdbc  release/kernels/addrhigh.by_instr.json.gz
f2c9990e7c43ffc2f46ced8a817f318be16656df96b8c465c1bc30b3374e6740  release/kernels/addrhigh.by_unit.json.gz
6a83ee549bc2b620731911123a4ffc5e1ff680d3882bbd4127604ae03aec34c0  release/kernels/addrhigh.ccvtrace
c12b4be2d5129bd11813c18a5df6a92425c4d8b6206cac93c3e97c2aa417e46d  release/kernels/addrhigh.log
569f2e22883fad5f0956c57ec734e6afbdd4b8a854e50277425172d6c0cbd766  release/kernels/addrhigh.oracle.jsonl
1efedd3e74aa1bbeb184fd026a6d96064ad5defb2c5aa2db1b43d0b68ab9d43a  release/kernels/addrhigh.sv-hosted.log
28dc69325fbf2e934fd86658223b48a8cb92053952c06eb87d3d34b4706decbc  release/kernels/addrlimit.by_instr.json
f6461e7e8081e79750a0a358ce2ee174a0174a909ffc7998aa7542e4f963d0bf  release/kernels/addrlimit.by_unit.json
d0275ae1473e1f86fd56e1553d6e6cb67f83eb67dc23e27159a63e3cf3f3f0fa  release/kernels/addrlimit.ccvtrace
b92e5074f6a578ee39326458201ba1791a48000c73a281ca343da4d5420a5bf5  release/kernels/addrlimit.log
bc660b0b40359a2c5a2478cb0eb4950b73fd22db50ea76b80052bc195a1920f4  release/kernels/addrlimit.oracle.jsonl
0f3d430b5a6ce4f3f8c5876a28881997895be2966237e676765566677bd0cd48  release/kernels/addrlimit.sv-hosted.log
002eb9f49b1db791a8001012fccd9f16bd62772dd9f663bd1a841e07061ce16c  release/kernels/addrneg.by_instr.json
ada96822553635b5282a2fb7c64ddaf92933ad7c066099ad0dd4205e98f8b381  release/kernels/addrneg.by_unit.json
5cb0374d21bf1240216d039ca378d384e50df24c7c9a4dd00b14448e75084b34  release/kernels/addrneg.ccvtrace
528ebf549ed59eaf727699009afc33c68daa341e88d25f604d098d8c7562e07f  release/kernels/addrneg.log
16f5b0707ae44492a1efd67bb9dd38a7e79a7bbd354fa9207b9e7d150ff2f107  release/kernels/addrneg.oracle.jsonl
a18dd8580288f0b9800544934d92f3d851fd2c6b6237dd8b7509f817463a3f2b  release/kernels/addrneg.sv-hosted.log
ae8b93e481627251b4103d715a80aa003b8abc40487d105c6c56388f7788c8bc  release/kernels/borrow.by_instr.json.gz
82b0efe01066b202571c80158ade436bebfd3b1bfc7dbbcf6848db56a09b0570  release/kernels/borrow.by_unit.json.gz
f1f862776f5dfc78e83e1d331944227363a821f4e49be68c0527294b55f42091  release/kernels/borrow.ccvtrace
86ea261f07bc9c29bbd875107073031458cc424f3be02d179a00fbde37f847e6  release/kernels/borrow.log
4c565e1ce0b3baee36e158694b32c8defb5cd662b2f9af75cb5d8c26cb1168ed  release/kernels/borrow.oracle.jsonl
0e596ef4c9a00284201e6466597a7a9c7888da6378e0d22da406bb561b277149  release/kernels/borrow.sv-hosted.log
d59a9793e954995f5b493218004f46c33c67a7b88d7a2cbe77646a0dd56ad08b  release/kernels/brs.by_instr.json.gz
e30749585e020a9b3bb3c72efc22d8aabbf0549a782e9db941cab27d7c38c16e  release/kernels/brs.by_unit.json.gz
5dc140ea49c98a2c34b741f82308100619a4698b3734262ba4d3417c10d722cc  release/kernels/brs.ccvtrace
0fe0bfe4fb0430b2cdae802f0d093c70ccbd2b8e43080f3ffd3e1bb17bb413a1  release/kernels/brs.log
e3c1cb3379580cf1aae44e8ddc8e846ef6fd661a573cfe0a8d4444b18a14dc56  release/kernels/brs.oracle.jsonl
f4950f6e13c86af7436ec3719ab6cc7a211d45f556d790f21e5b1d1a3cf3ae03  release/kernels/brs.sv-hosted.log
86ad0351946b566bd973f2875e728863f2ac55a6c82e2806e850a1b585b894c3  release/kernels/byp.by_instr.json.gz
c203bf8b1a61bf3c343b563063a35587b79ef2d793988acc3d59cebc60585b29  release/kernels/byp.by_unit.json.gz
e3480a496b7a1d2881af43ee09b2bb764b871eb942bd66bcbbaa3b537f536d6b  release/kernels/byp.ccvtrace
225cf1e7663b6d12f51936dba831960ac3c9ad10699db5c97fc2a1be3c11f43d  release/kernels/byp.log
5a03dfa4f3603fef49f1e3639e74e34152ca3ca5ef8e41eb959f8323040fa2d5  release/kernels/byp.oracle.jsonl
07132af4438522a45e7ff77a36378dfd98b204d189cf198f3fda21e242770967  release/kernels/byp.sv-hosted.log
2797904d05bb8690a93f0347a0debd9ef2ab9e3918c663dc7356c8641461dbdb  release/kernels/callret.by_instr.json.gz
37a8c15945ce4fc7f6c3a0da0b78d1156e17a199c6f806b0da1cae417eac38b7  release/kernels/callret.by_unit.json.gz
5c916dd80f288b2e715c882c446ac317f3341d84638afb42c6d58461c0ae83da  release/kernels/callret.ccvtrace
de0f6d270390fb4c2e652bf91a289512b6f1bdd83eba63bb1b7a2509d577bf60  release/kernels/callret.log
9b1d1b50b527f732362f837250aa2f26dabf3e76e16a4794856ebd8f105635b8  release/kernels/callret.oracle.jsonl
d1c115c64f09c2dd5830fd56e7adf43dcc8de285baf7ef3b9e0a105ca49a2dd4  release/kernels/callret.sv-hosted.log
3093a6fee1e3bb3838ad2c48cff5ebeb334620ddb0291fafe9c8090b4cad20f8  release/kernels/chains.by_instr.json.gz
bfc3e0e4892decfeb7548b6c611c585d1d7e98d2ce9fc8d6d2cebc814d491c36  release/kernels/chains.by_unit.json.gz
94291c1a3431b8b84b1171b04f2fe0f6eb3300cd344c7e7e60928898254e9d63  release/kernels/chains.ccvtrace
ae1ddd5b5937f0ee9cbe35237ee22a50ed28e32865668dfae0124d454b74696b  release/kernels/chains.log
26a4cc5c5524c7219d8706c2582c80357dea60be9d6ffdec99dac7d0365e2264  release/kernels/chains.oracle.jsonl
195ec34508edf82f16ba97a23ca259d434bd3e8de16b4d2e174fc6de16a6c557  release/kernels/chains.sv-hosted.log
44ee9a5644fa3661ee3ef2e5c102eb0fa3d6ac44088221a984f99223eb209f50  release/kernels/div.by_instr.json.gz
4e68581bd61e35145af44c44867b6a3b2a1db665ea670e1beb03e4b5f74d9005  release/kernels/div.by_unit.json.gz
d4e3cf776f53afaf1f121e89f0ac7e7acf46db83e299dffc3a1f6992c2d0763e  release/kernels/div.ccvtrace
3f19524e7aa346347d10db07c74706b4331ce58023eb94eb63218cbb0f61d0b1  release/kernels/div.log
71a567b85cf85622631490187563de9a5661099c78a590adff4ed0a0c3d24c16  release/kernels/div.oracle.jsonl
86118e89327c7c48c2bd93a5c24966155356adca62e14cd4310c10ab6e8850ec  release/kernels/div.sv-hosted.log
2c2d1be1387bcfb3f73dcafe56760a554181bfe3ef27ffe2bf7f80a9bd91de79  release/kernels/divchw.by_instr.json.gz
37a47f8bb4b3b4845dfe13d6fb754809db84578f6e8416ce1e4dd8419b4f17bf  release/kernels/divchw.by_unit.json.gz
36165621c49d40f4c9d967b694e162d58ca01a786ed79d7e9be7360be19a0bb9  release/kernels/divchw.ccvtrace
fb75e9aac96d7b72d56f88fad08738eeae02b10ce4ce734f9d078a496e6994be  release/kernels/divchw.log
58a541797f7a2df0a1c7528ae6a3edec212db90c7d3eb20656806f38b5c10b3d  release/kernels/divchw.oracle.jsonl
21ee52b2e6be79859318fae3a26c0b3dc11bc13ddfa8388f456a464f191ef310  release/kernels/divchw.sv-hosted.log
04706c482877aa08d838b5817d87817861cc2116157ba594cc6f8be118b8aff8  release/kernels/divtail.by_instr.json.gz
65184b25b1c9c02c38ddace0de60144b55cf7d9fbbe4b3765b5207209b930c81  release/kernels/divtail.by_unit.json.gz
038d13deb3b5c08bc95b16b8877467a9451dcffc9bc53d333486bf978cfb01d1  release/kernels/divtail.ccvtrace
928c41bdc4e7ec9fb17976fcaa49f082a314307fef345d55c32fa431d8c2fef6  release/kernels/divtail.log
75f11a75c9b3b336e446140af4579f05b46c363a76b7aab3ec88154a07ba097d  release/kernels/divtail.oracle.jsonl
f2bc1a1e4784e6f6fa1965d89b6d337fa24be3dced41a6fd865717038c19b42c  release/kernels/divtail.sv-hosted.log
f58257d926a8db8599897c4b8f1020dd5bded7b2609bb7a249326bb524fb7336  release/kernels/divtail2.by_instr.json.gz
40c6aa0208f5a42317caacd871ffacd4cd0bd1692eb9176663e75e7a6b6f2d4c  release/kernels/divtail2.by_unit.json.gz
f5760eb6378cc178b8c80585c076b817040a0af3545f8eba2b17362e0aba7441  release/kernels/divtail2.ccvtrace
a0e19d19a924d3431f453087f2038044e30c4ca8acf4b97e0102599151505333  release/kernels/divtail2.log
b2db6b05eb6cf4a0a7677e31d0c6c2952d5cab49d353f0bb1883fe0b2a20ed14  release/kernels/divtail2.oracle.jsonl
43233f96b815dc97a00ee913d3b07a7bca4f4c1dd07b74694de608645b906ee4  release/kernels/divtail2.sv-hosted.log
1bdb14678e268d41aa9f9188b720f0d000f020b26699909dba100055dc8e3778  release/kernels/fence.by_instr.json
e9d04092bc04db8f173a79b3965217fac1a0b402fe3e00aad58ac851bc30b5c2  release/kernels/fence.by_unit.json.gz
f3de39e962c433133d04452e595dddfb100cd50cddbf4c626711c9236cc6afa0  release/kernels/fence.ccvtrace
07fe6be8c5c620669d1ca943b40884507e12ccf2054c6e8b5489a8aaabd04552  release/kernels/fence.log
d1d40317f6cf5bfb430cda1f9c0ef676609e59cabe2a11623c42ffbeca93142b  release/kernels/fence.oracle.jsonl
c1c8fea0005167a336cd75552a14072430b199cddc1b2f2348b809fd41c12fbb  release/kernels/fence.sv-hosted.log
83dbe7f04db7cea52793536c3bce4f471cb7b0315f71d1eae01faea3b24c280e  release/kernels/gather.by_instr.json.gz
100652fdf7acc0f0ce803145f61bff0309e66f3033807b8b7b86631bffbe5dc5  release/kernels/gather.by_unit.json.gz
9264d807aab095cd4ce3141f4fbc6a661ef5bd72ed384a647e735f1f1d294258  release/kernels/gather.ccvtrace
ec409c6760af7277f3f2cd4391061e54b0a30863e59520d8dad801c3685f31c5  release/kernels/gather.log
0413e781d8d6ff578c64eb1f800b7931e66f676d5cdabb97b94a4033e6037662  release/kernels/gather.oracle.jsonl
022e73604385804a93f0eb77dec37f7ce62aad3fb4de4ee0d39ab19a932df511  release/kernels/gather.sv-hosted.log
ad92b480fa70dd7e8d71a436f1e513e1d3d5d1a1b98064079e43956791910f39  release/kernels/hit.by_instr.json.gz
e8902405a0cf725101f38670bb28dfb91fe9f277e819b9dfbcbac66c3a8ff5a9  release/kernels/hit.by_unit.json.gz
a21884ff3a5bc45b0719725c1b08b9dafcb896df33e9129726b0a6f8f2f62c5a  release/kernels/hit.ccvtrace
675664064d88067c20cdffe72f4accca7d89ad4042ac8405952ce7d48d43c1ae  release/kernels/hit.log
7ba9603e0088d9164de6528f16ef6a7fa9ce5821c8c12b52cbb3734e39b9fd52  release/kernels/hit.oracle.jsonl
74569a1a78d47f6247728f839f93f317f0ac1814552b306fdd103128944a135b  release/kernels/hit.sv-hosted.log
1965fa0dcbd75f27c5decc9bb7699e038fecd9262e054e8dcabbfbaa8c0e8164  release/kernels/lanectx.by_instr.json.gz
1ba7e47981e6ed2459c67b7f18b0982c1fc81c54c4e8e4ecac65c387d4db4a1d  release/kernels/lanectx.by_unit.json.gz
b8113fd30054885d1c08728f37eeadc557ec3ed260e5f572d8275925e2ec625b  release/kernels/lanectx.ccvtrace
d61de36f67a23d7f6bf6ecc47e74582f85f7ed5848d23b747188e31f4acf3e5b  release/kernels/lanectx.log
888551babf540db8e3025b82e65ca655013f93eba3c8a65689d069d52a7e6039  release/kernels/lanectx.oracle.jsonl
0feb95a9deaf00cfb74f06c0417427a32ad30be7b8a9393f5b912c8250592ad4  release/kernels/lanectx.sv-hosted.log
dddc5dca1db0ac557e97768cf8fc4d79e2bc7beed42c9127e8d826f60305eecf  release/kernels/lanectx2.by_instr.json.gz
eab804e9320a9426351deb94e481bace685298bbd77b9eab77fb5010c024e4ab  release/kernels/lanectx2.by_unit.json.gz
2fc4e806b0251780aab41e915640af360d2330e7985ab9f857a899d30401a43a  release/kernels/lanectx2.ccvtrace
d0229a8ba7e051b55f149b59f9fbd8b028d4124dbf7d0d7330079d2b2f784bf5  release/kernels/lanectx2.log
45c13056dff5c73ed0c9ece56cc36f929bf335322193c7d5eb38710b1d1dfb02  release/kernels/lanectx2.oracle.jsonl
cb6cf4a946792c906d61ace03e9fa46b4a00d972c74dcccaa6a326c2bad602e5  release/kernels/lanectx2.sv-hosted.log
2723142874a1da44eeca2870b2ba7816d9d527409867d09a7c2e0b7f2696cdcc  release/kernels/late.by_instr.json.gz
e2610154e5219b4ce9e86f0805845f5c5cdb32042ff483e189cc161300fd98d6  release/kernels/late.by_unit.json.gz
f4fc47fe3ad032977a338a3981b96518a799d313c6ccc4880908bf3646f55aa2  release/kernels/late.ccvtrace
dcbf1e40beaf1927586e65026574899c50a833f190188649659b2982f776a8f3  release/kernels/late.log
86084f6bd747a2cf32acbc0ebd96ebd3e4ef2d8d9e21be49e3ae49290d7927f3  release/kernels/late.oracle.jsonl
786a6b7439f906c0b425c9a74416afd91b34e8af11054395b6dbc3ef0e180018  release/kernels/late.sv-hosted.log
96b0d9003e982a3a9c6813c5c1875820f4fa468b8d6da2275e591d7b5ca29512  release/kernels/ldpar.by_instr.json.gz
ddbed2f19858ee83080d8caa209cafea10ca5333c95adfbfc2254212106e8cba  release/kernels/ldpar.by_unit.json.gz
859d131606c248d7feeee7753a2df6702437f1bd1b61f3073ba90cb84b7d3eb5  release/kernels/ldpar.ccvtrace
f085f2b1b21842ab2fa128c5503ba5c8ec1f9d76d926e376af4798bb255d60eb  release/kernels/ldpar.log
8ac08538e9c807637babd61b31e340f7461878ada31f0c0b83cd66331cfaf486  release/kernels/ldpar.oracle.jsonl
acfb35b36ab201e0b83c831b1012289dfd1d10d883bed1709b0a5fa406618c67  release/kernels/ldpar.sv-hosted.log
8fe39a08372176214f59261be9b76e19eb507257bd1666773b41bc7d9c9a5ff8  release/kernels/lnorm1.by_instr.json.gz
23a24f4e8308331e50bd858e0c6981ad48b8d365cdbe527d8989e4f2fe53c01b  release/kernels/lnorm1.by_unit.json.gz
84b6565d96bb9bf341ec04a2d92c081195ced87a88377e3da93d9e288b49c9aa  release/kernels/lnorm1.ccvtrace
e24e2e9d79a4afddaa027efb8f52c00404e7137bbd4ad045ebc769c74b0b6136  release/kernels/lnorm1.log
a8d85811af988a1b9fc00db1517300af3d93ec8e589e403d3b9113fa9e0ffc86  release/kernels/lnorm1.oracle.jsonl
630c040a21253a363dbe099edc040fef9d0a700529c932987353e7cd690caf3d  release/kernels/lnorm1.sv-hosted.log
fb14a8e40ae356fa51507399c45b8f95a6c5cc9644dab3e22e54be2befab68a2  release/kernels/localsp.by_instr.json.gz
939c165ed42cfe0b5dc00716caa0c60a78e36e615a18329992c6da56721012d7  release/kernels/localsp.by_unit.json.gz
994efce3ffb67f5fc232b7542d2ffb40a1b1ccdd5ca42dcc35a95ae5836eed55  release/kernels/localsp.ccvtrace
1f1644be5da2e1f2d0ce0321a5f047f4f6a2a1ae7fb62ea6a608b3837eed43af  release/kernels/localsp.log
55e3c9f36e7f7d38c0ddd38903aff4bb4509ae862015c592e6b937ea258042ca  release/kernels/localsp.oracle.jsonl
976a761c13f3e85995d8904fd103412eaefd5884846cfc51535aacdbe15d0f9b  release/kernels/localsp.sv-hosted.log
056586aa4e54bad57b4bcd4ed0e55e667422915ce3cce787e5c0fd745d1613c7  release/kernels/loop.by_instr.json.gz
dd3de0fe71e0b2abfee8016ef85e452e745891c23882c0e505ba7599093e846e  release/kernels/loop.by_unit.json.gz
d97f745235554b110bb5181b2194e2a3227871552817968e4dfba9de82d8ce40  release/kernels/loop.ccvtrace
23a1e4d0ea3abad280ea43c7045d8c2b4bb5f255a59e38561e280e7e260641bc  release/kernels/loop.log
03ce5920c06c93e93516d8e53c3f7169f14e3593de204eacceffc0b8a3e32016  release/kernels/loop.oracle.jsonl
e563e6f20553f4089bde5a4071d434e1c7e114fee98ec690c87636aa8d240061  release/kernels/loop.sv-hosted.log
9d0a75ea129cbdc2e97e252bc44b01452b1b1583558f2d384e685b7c6fdb8892  release/kernels/merge.by_instr.json.gz
0d7c47274708d3b4dce67f640a661f837fe81b15e758a6e5f826302d99dc80b0  release/kernels/merge.by_unit.json.gz
fb3738c6d842e8baf329dbebf4968b4945e0a3fc632251d675b1b2e098ab48fb  release/kernels/merge.ccvtrace
cdf5c066c6904bd3aaf1dd1e0b86bfec3f59c6e0cd31df488f196b341ed0122b  release/kernels/merge.log
f96d28815f8756b1f5a45ded53e6170883d2dfa10f9eef0d14b8050b1318164a  release/kernels/merge.oracle.jsonl
a28d334bb563cda09c92d52f3273c952264b1035ebc463b3352ecf57081b6b17  release/kernels/merge.sv-hosted.log
1b2e32316a285dce8941da349127ba4b151f33ab0d41a0822832026d0a11b788  release/kernels/missrun.by_instr.json.gz
d4cc2cf259bff1eecbce6267521ebb2d8e5c80231cb71ca4122c053c5b0fb396  release/kernels/missrun.by_unit.json.gz
95dcccf10f536cd7452f5d2e81951df113faa65567f9f0d4d0c5dda4fd3bb89b  release/kernels/missrun.ccvtrace
5fb6b4640dfd77185544aaef5ddaad59d29ecc05cf4b5891c4e0d0904edbd887  release/kernels/missrun.log
531bdaf281e5590774bd2775427f25e4cc0419cf8e3d5b6999843ffe9ef87258  release/kernels/missrun.oracle.jsonl
f12d542c22538496dc3f1b1161b0a54ac1efc0099cc824bb547ed4374ea3577b  release/kernels/missrun.sv-hosted.log
89eb8f3f534123d7f033258cce4f2a3fb0a6095ee04be7f275b179d28dfb6365  release/kernels/mload.by_instr.json.gz
94523e30f63bdc630125aa625ae141fe982eb7b21ed0eb55952aeb91a41e4ea1  release/kernels/mload.by_unit.json.gz
6c51ae125f57419af5b4a0b83e312c614f1a11addd8fc8b6fad836734c264ead  release/kernels/mload.ccvtrace
fd7507cbc396aae4e1d93ee616b04429233d882f0e43afab4e11a1f2533411ef  release/kernels/mload.log
8000e477b9a95dfb9f0af964e8346acb9d36f1358fd06ffc4ff7cf599d2b8868  release/kernels/mload.oracle.jsonl
2a5d4297117cdc7036422c0178352b067d01f8f7fc7fc8d0eac7ce272c5baf31  release/kernels/mload.sv-hosted.log
0c22aa9e69389a2a3b8965d76bf959a975467293d438dbbcc31b19f6876cdc86  release/kernels/mlp.by_instr.json.gz
14a843f030951ce377df49b56ccc6dc1c036ec9027b5e659739ee3ae3e3ee19b  release/kernels/mlp.by_unit.json.gz
0b70f24e8ccd473fc49b62f1ef3a71388265aafe5823ca8528243e53bfc4b8cd  release/kernels/mlp.ccvtrace
f006e4046b851e506d21ca735f7b53ad8cef896db9a04c3fa500f28788d1183a  release/kernels/mlp.log
138d282f88d56c8ad648a91af0a983254b55d9fa22942c00d47b327f516a6e44  release/kernels/mlp.oracle.jsonl
25aa4038957e1ea7c2a68ba2a5d3f143809856a7e7eac71ae44f1e4a35103bce  release/kernels/mlp.sv-hosted.log
4a31b0a5a61dae729373782d8aa0e20c623b892e9182deb8d814d6f4680a3d54  release/kernels/mwmiss.by_instr.json.gz
bb9c4d33566237c169c79efba05f119235764566b1866e76195dcc7ed8e74f20  release/kernels/mwmiss.by_unit.json.gz
bf58bf5dd2a060867fee471eef821369e5780d47733556f608fac4a4eb24cce6  release/kernels/mwmiss.ccvtrace
6ceb1aa542a6b2155c23999b7a57838cc3b2c5f9ae235110cf203d285f99a748  release/kernels/mwmiss.log
8abe8e8997456a2a6711ee72da54d854b24e20abbdab28e4b7271c0d28418de8  release/kernels/mwmiss.oracle.jsonl
e8a392e04423d1b9c1a1468629feb75d52c425804c7298ce9d8abbf5c4d6c191  release/kernels/mwmiss.sv-hosted.log
58012352d5ea9892a959f94d4e2e717587582d0abefa0299cc31b1bd9aeeb9c4  release/kernels/narrowadd.by_instr.json.gz
6e4a1ad7a65849381b564232852304cc3c18fb6a2b2a8188cc028bb6479559e3  release/kernels/narrowadd.by_unit.json.gz
43094e3dfb54bbdccbd1486b3af3b739fbdc6e2c5672b5dcce010be51613c42a  release/kernels/narrowadd.ccvtrace
78f1bb621f4a30dae9bd0e8c0953fc7606bf0d32789e3c29c29a5536f35b41e1  release/kernels/narrowadd.log
40a2cf629853dd404bb06b4a07e35abde3d12efc13f26ffe28f923daf2994574  release/kernels/narrowadd.oracle.jsonl
78a59304a7f58ea5b00ae8e7f8dcc48edd1170601fc3a82ac0f1441c285c59ca  release/kernels/narrowadd.sv-hosted.log
60cd11e94a0e4f989e086ba0ef0cd972b4f7a2e2a6cc822838b315dd270355a4  release/kernels/pguard.by_instr.json.gz
2ca0f182d1f410ce6d081503261c3533b06f66b8845762eed8c69d750951a970  release/kernels/pguard.by_unit.json.gz
b84232a13c63382123e18ec951dd642cb132eefd21b44fff8f49c69c7339a3fd  release/kernels/pguard.ccvtrace
7cd9b0ce896540cc1f269e57005b01708880f447fc2f7a59baff8c257b189ca8  release/kernels/pguard.log
690e56f1cb8d97cbf67124b7dff3ad0a90cb8981814cd1709cf0cd0e035b3bd9  release/kernels/pguard.oracle.jsonl
87a3baa3c4c4078bbf010275a9a39594cf55070d628a1e8f94099373780e2a13  release/kernels/pguard.sv-hosted.log
f9e2d01a1efbafcf0f1cffbad43f3fea97abc1eeda8d4b1648c899b4a044268b  release/kernels/plog.by_instr.json.gz
a79732a8b2dee834cd2a2ae5d690b47a33e8940e8464b0010046741720f26705  release/kernels/plog.by_unit.json.gz
e32ed8b48729d559c9d9c92968577d8f87099c9bea1562de23e434a7e966bd69  release/kernels/plog.ccvtrace
0bc0e407ba83624434e0271242283312e78976eeec5effd4adb93715334373e1  release/kernels/plog.log
c230f13f2e1082b306a9c5ab7809ff36cf5c1b2e47dca6b7a71f741524d403f5  release/kernels/plog.oracle.jsonl
df7982a7712e19ed70a11ffa81accca14bf5726ea53b7a60b3ca1edf409ac01c  release/kernels/plog.sv-hosted.log
7fb57cff24639e177b6324c7cfb54f690cc61946d1b11d52a20d3727dc15b305  release/kernels/predlane.by_instr.json.gz
29a6be9b7c36d34fff18f2349d768bb84474760064c3b8bb30128cbcf9583107  release/kernels/predlane.by_unit.json.gz
641cf1d52a695531f36a20efddbbf13f4b148c2b9f86e004659ef2817c6c9e20  release/kernels/predlane.ccvtrace
48e23a22553128cf727f38cdab3f925391b68829edec1860d00cf08cab894473  release/kernels/predlane.log
c45f4177b9e84fc8a6e36b13534a0c7636eb30a3f8531847100ce5e23bf404b1  release/kernels/predlane.oracle.jsonl
36a478b50d40d128bed1b14ac96663a1bbc0e6b1980575605056becc9e3fed4b  release/kernels/predlane.sv-hosted.log
06d85a130e29b5d0854345cec6a967d70f8fe8cf396c0dc571b51888b8fce097  release/kernels/predmerge.by_instr.json.gz
80a53ea8588ca7f1d5322f408c0f867d1156e735a914048100856bc85e7b6add  release/kernels/predmerge.by_unit.json.gz
a67d904d96ccfdbf5147b5795b7089099b2717cd21113c27b69c379c41e20e3b  release/kernels/predmerge.ccvtrace
4fb58fcb0c6f5a70de101bdd16ba56181174b39fd14ec75a351a125a226cc9e4  release/kernels/predmerge.log
6c737c49434bcd08e3e0814c8b1dbf15c586ae74f7929ba3148ddcee2c62c845  release/kernels/predmerge.oracle.jsonl
c925b6a42c22973491d102dc5f8ab12e4d1107b9128cf2935316b78cc5e87fed  release/kernels/predmerge.sv-hosted.log
0cd50027bc628e019beefdcfcdba185227ca8569921648303d6f4d37b87d70ed  release/kernels/predspill.by_instr.json.gz
6589813051622a473fea236a4ea3140e3184b4ba622fce4fdb618300ec0d3736  release/kernels/predspill.by_unit.json.gz
01824e6ce8be6f51721d98514eaa04cc22e23ff2a0259f56af167900f52f96ab  release/kernels/predspill.ccvtrace
9ea5cbf026d07d6e2a27fd8e44c73207f33085368e3bc45290a58b7f4efce5d6  release/kernels/predspill.log
b7c84c6478117ffa0f06da0e6ad1e4628e2683426a7911080810e78e06a5242e  release/kernels/predspill.oracle.jsonl
5360264f6fce4388cd16d03f934c8b4f83a8091b8b1daf9660f925690b5e0a87  release/kernels/predspill.sv-hosted.log
d2312b6d0d64f9eaed2d753458b4638cedd934b607958db3efe870f289ddaeb7  release/kernels/predswap.by_instr.json.gz
43d921250fb5682a71a10f293bcce88677d0e3fc81137e48c883c4e1c23136b4  release/kernels/predswap.by_unit.json.gz
b000a4a9d47b149ec19f0b41262ee400c37d8c757114b5e964f26941976a4b0f  release/kernels/predswap.ccvtrace
cb25e92c8bb95e3ee0492a3550857382e599e7f6e8becfc8e852c85f486130c4  release/kernels/predswap.log
a6d4f7ed517553816d889c7c9eeb6bcfd1f6c973fbf682ecb69f3c2de619f7bb  release/kernels/predswap.oracle.jsonl
4ba620261b91f33c4994d4fdad0eab8e37d498829e415dba8b363b4e56238515  release/kernels/predswap.sv-hosted.log
97503094a0d1c923a48b5c010a11f331d4f19ab0416e33c2261ffef4c6d92a84  release/kernels/provswap.by_instr.json.gz
b477169447578bcb6e70af447189f0db1b5102c79f12a0a7937d9f95c9238501  release/kernels/provswap.by_unit.json.gz
2d8fa3a3fae9bcaed3c82f6aed6f17bfb22492c1448d16b2ee2d3f108b8fb0a1  release/kernels/provswap.ccvtrace
be20ce6abc3bec2fa47e1e303717f3aa3a41cc1a10d9b1a6e0e8f16a426302db  release/kernels/provswap.log
c9c32a793d54cc7401477f582487f7e8b345b2669a75337b8d6327120d98e5dc  release/kernels/provswap.oracle.jsonl
5d4f8886e3016dc612632edb4cc85ef375e40794529fa12bffb6b1dbdb86d099  release/kernels/provswap.sv-hosted.log
bc78212fb3eb25a011a8123c4c1f4f52a37579dfba964059b435dacf71198f47  release/kernels/roconst.by_instr.json
79d82b16fc17f58fb96fe049401a9ae376289313248707f0a00f02a0bfee4cbe  release/kernels/roconst.by_unit.json
67cb3eae07ee5e7c2b5189ab3ae0b9f61a2288b3587134e3f81c30c1a2e1b664  release/kernels/roconst.ccvtrace
16c1f519f57131c584079ad7d0846c07d3b2c9e93b101976c817d1637b60c9dc  release/kernels/roconst.log
8087c0671de620162881aecd38cd6114b78e7be6bd71201e3ec02c9a2e2e750e  release/kernels/roconst.oracle.jsonl
792f0dac758b1e8e47f1604b126e688340c4226e301dbcc2b2a325a7c9dbd931  release/kernels/roconst.sv-hosted.log
97f33ebd4e213b24c8fd8e9a1a66978cbec05d458b20e52d6c64cb884a9eca98  release/kernels/rogated.by_instr.json
8f4a7fad7700fa166ca7610c540fd23064f14893f66d958cb783acac12c7f0e6  release/kernels/rogated.by_unit.json.gz
f66f987d8fc2f520bd60b6879774625aca083d99cc945d4f9f642fbd07bfb4a6  release/kernels/rogated.ccvtrace
4d38c293a5ff52300bb38857ceda8b927cfc5ef560a70064526071aa84f189f4  release/kernels/rogated.log
7cd02bd4cceec5a044d6b4d6a80df1e68ed0ae71b0b2a953143636d5b809ea6c  release/kernels/rogated.oracle.jsonl
1ee794eb2afcac495c15c02f15366ea65d3bdf49dbc01990989c83517b58f322  release/kernels/rogated.sv-hosted.log
96f03637ef0b2d25395b4675614dfa440c046049814718e86dff787e8a41eadb  release/kernels/rokill.by_instr.json.gz
2b4db48c001652f421510a8243c6612eb88c6ee96ec1d979f773bc3f9ed1ea3e  release/kernels/rokill.by_unit.json.gz
786bc1acff229f74556953efe75f61182febcc4d0bd523b01e3877be3bd197ce  release/kernels/rokill.ccvtrace
ef6f3b7e640b4212980efe9727baed2fb9b021dbbc4d278bf21a96df5ea86263  release/kernels/rokill.log
94efcef96af469a512d346ce61623980fe86383188eaebd55120f716db596f14  release/kernels/rokill.oracle.jsonl
a1fdc17a6596001cfd1b579678186a2e7093cbe7cc1976e3af32d7c7d447f6f9  release/kernels/rokill.sv-hosted.log
f41e6e2e961cd580d1cb70c2a7f4b0d5a5009c7d936e611e401b661c48745392  release/kernels/rolaunch.by_instr.json
7deb59c3a34a6ad597d362605214b2f8c5608fe4b96916c8fab8e2368db4c3cb  release/kernels/rolaunch.by_unit.json
03c1532e55928161a52bd3a508207e2590d1e4a67091d7be62e55942c13bca02  release/kernels/rolaunch.ccvtrace
c3f1c59be348fb933e9a77e3525b1d78bbf4f378a5d73a9c52d0f9c69ed0e0a6  release/kernels/rolaunch.log
e7dad585c3e70615de04330fd03f4f282c29a005dc1732a35655fb261d51139e  release/kernels/rolaunch.oracle.jsonl
af818854de35b7966366c5e421b588af05d9462041a42c0f83ac2c258892f608  release/kernels/rolaunch.sv-hosted.log
bc78212fb3eb25a011a8123c4c1f4f52a37579dfba964059b435dacf71198f47  release/kernels/rolimit.by_instr.json
7025b72667e0598aa0fd20e979b43d7742034750ff615788ee249cc2f71e2106  release/kernels/rolimit.by_unit.json
7fd9c08101c7d3d6da8773714425093d1d1306293c81245e32587716c2d3c044  release/kernels/rolimit.ccvtrace
152848f5b56555bc4202d44c78a529ccefdcd38ef3e55551ab8991e06a6fff2b  release/kernels/rolimit.log
1c5bc0cb8e8b2e69505fb5a551a16d5d10c56f232b88da7a27e336ad7d962de2  release/kernels/rolimit.oracle.jsonl
d1e690547a2bee35c11af75f3db3aae1488576956f53eebfec744714dfc59113  release/kernels/rolimit.sv-hosted.log
03c88db2deba47ecb38de5a85049dd6d6066de8aea6fc3b1825f063f31db0f58  release/kernels/roload.by_instr.json.gz
8d0ad2a4a54c3610d06adea4a2e3673a9f9aed2a53325cdb4ef26df0001dbc9a  release/kernels/roload.by_unit.json.gz
211940a7f07b77fa9bb7955c575e00dea06e88b50e1e452d1e6254218513c542  release/kernels/roload.ccvtrace
db4c5f5668737588efecebcf741099ce7d3870c886452af467e190f75aa00767  release/kernels/roload.log
f7c1309cc9764769fb5803f6fd0f2f5e1eb418f2d23fbe5e17cf5f9106869fdf  release/kernels/roload.oracle.jsonl
87fb8a6b5e1bdc09c2701cfe0e115f088af453540ce93a627c77d0bf77f22bcd  release/kernels/roload.sv-hosted.log
44e924aff1206304519766a66b5e8f3f09c0fc5bd779af911275831aa70af05d  release/kernels/rope.by_instr.json.gz
b69889fd5a1cb7e7bda9c14196dae1a3af979d3d3b2d896d8af43dc8a71be1f3  release/kernels/rope.by_unit.json.gz
ff40280d90650dbd0771b074cc22c93bc9d95b053e0b2ae7bfca85af6924419d  release/kernels/rope.ccvtrace
0baf9ee9a5460966e74824d4b12f5a8d9ecc6fb0eabd7e1635bda11b35ef50dc  release/kernels/rope.log
d55f9efae392dc8877c102c01c0810e7654b666b6ede386328108164c6cf88f3  release/kernels/rope.oracle.jsonl
3b860b222e25d65a5441ad43e444c28c429f1e2751892941ce4b6622b3574318  release/kernels/rope.sv-hosted.log
b06dab204b4271e96caba37aab316239a7804933a7f878114cc1c6f2f644fe71  release/kernels/ropediv.by_instr.json.gz
b5ce0b5546495970bb1d23f7f5e0a51a6051a76bfdfb227e0f49b5178cb743bc  release/kernels/ropediv.by_unit.json.gz
b85ca78f64f20b2220b3c38074936ef5edfa8dda0ed4cf07bb6266aa7a3df6ce  release/kernels/ropediv.ccvtrace
3e5368f9ade64a07c4f5fed2e501c81917fbb0585bb38e43741911fc711f3ed2  release/kernels/ropediv.log
10c0ec6ec18b7b44638c790033109198c079d07c1537bf193353ccedd00a920f  release/kernels/ropediv.oracle.jsonl
57c5852bba2a78b47ce27594fb73ec531749c6385afece32aa8d26cc6719ee02  release/kernels/ropediv.sv-hosted.log
12411e6d50631d1b8170d25eb3192a56a2673550f226633b1f335a58ee36382a  release/kernels/sel.by_instr.json.gz
bfb734d0745a18992629d2460aede38ea17605dcbb64997fd162521f21dfb39e  release/kernels/sel.by_unit.json.gz
d647e23e18e16512cc2061f4c5ef8fde687a47a2e11482fb7dfecd77a7745778  release/kernels/sel.ccvtrace
88e2ee81dfd0c40864d57563ba2cd91818339bd473f134a0b23e4a39f3c7b90c  release/kernels/sel.log
87f6a81e8afa004c8039bf2f61c90176fcf29ab29bb17ac44aa016a5cc8438fe  release/kernels/sel.oracle.jsonl
0080fe5a95dbf45266a98153d757e136f0fa8d6da93e13d613886ae579f817a9  release/kernels/sel.sv-hosted.log
d6767edccbf09bfe265514b9d3a6d212d1ec12388697a4c614629a6c0ddc56c8  release/kernels/sized.by_instr.json.gz
4c0ce05bc06e5e6a239fbcd3b689bdb5cf41ab2ea237951b437ce80915b57e26  release/kernels/sized.by_unit.json.gz
3680714c49bfe395699a4b7dd792e1e24407e9b1147f6d87455a820a0e896d46  release/kernels/sized.ccvtrace
6f6b291da87887735107aeafd012331af82ef09e807fdc906eff72b45344fd4e  release/kernels/sized.log
36d903ba1618bd1faa437c9812a6ee6c0c966a63196c796267d74bf2695ebc3d  release/kernels/sized.oracle.jsonl
8acab490420e6b432c35a6665f67768ef89c6a0a70fd9f9019d4b34cb9782b22  release/kernels/sized.sv-hosted.log
b715a15404e42ade2820a164ed187aacc3c78e60e866072fa95f8cb48ca44041  release/kernels/slotform.by_instr.json.gz
b70b06a9062ecdc0f9a07afc727b919a9178755a8c0d39137c49341a1b6fe9b3  release/kernels/slotform.by_unit.json.gz
888c7f098d91898c85e0a75eb80bbd7cab64b2c8726c1dd7843e3c1c30642169  release/kernels/slotform.ccvtrace
d2525843d0dc07fe375248bca2bbd166b54a9ad13e5c76568ea30abe1f67fb7b  release/kernels/slotform.log
8b61db7419b18cea8a646fb628218447e72e84a18a9891ffb73b441736138ab9  release/kernels/slotform.oracle.jsonl
cd701559a2a6160f03e6ec0935ad7cc78264d329a3aae31ebf3132b8a62521b2  release/kernels/slotform.sv-hosted.log
90b49bd78d1e70e9689a10de16fa56075680369371d41853c038866ecdfdd21b  release/kernels/spinwait.by_instr.json.gz
f6ff52184e58c9e1f9fd65aed183c960560530fd090d07855f8b313092081e21  release/kernels/spinwait.by_unit.json.gz
11b2ce9ea1695c9698cd05836e17ba1d27993c2b93ffb4367499d3d83ae14bb6  release/kernels/spinwait.ccvtrace
5e587e376c444fca04d80f59e88a8df0031306c85ab4bb511183e01b8beea9ad  release/kernels/spinwait.log
868920637236c878b33779bd450439466fc3626996a3164573dc11d437d5c709  release/kernels/spinwait.oracle.jsonl
e9d29a06182c513d1d24cdd4180edad48a8bc3c6cd944d93bbaa63cfb7a30ed2  release/kernels/spinwait.sv-hosted.log
7fb77854393946cb70c8753770265e8c4b684af3aa51e166c2200ac03417bda7  release/kernels/spmbank.by_instr.json.gz
fe7db2e041f6671b55a80bbc89ce59cb0bb6adb51ce5fbeceeb4e11d764b713d  release/kernels/spmbank.by_unit.json.gz
04b3dbe95ec991b471ee85d502128c2b90ddcce0609e1de27b77e4bdb5ba4042  release/kernels/spmbank.ccvtrace
51e217926e744123c60ea897913cb5eba755e973fbab21ea11700aacfb636f69  release/kernels/spmbank.log
3af490cc37d7a92dbe719b57de216b648536eb301ff9d13de9a39f50d150d725  release/kernels/spmbank.oracle.jsonl
3d7fb525674f3c30660fc338ee6e388696f59654459d7067f97ebc861579310c  release/kernels/spmbank.sv-hosted.log
062f963a98ac2fa39865f4aa62a0b7d69a2d7bcf91e18e21ed9894cd1229b107  release/kernels/srd.by_instr.json.gz
c07e4b5b7c0c723d8fa09746b1b3fe0e9a223198661ed533c641d7b6f174fffa  release/kernels/srd.by_unit.json.gz
0de6fcb70c02376f30c7eed67f0cabf4cd00fc874e9d95f24465e7d79129b3e4  release/kernels/srd.ccvtrace
53e2f8ba8404d0e414d1b76f77099ce0c03d6b4a4ea4e2ba8f729c641c003772  release/kernels/srd.log
b08eb5e3673cac7eebb8b72af5ed3783c8e70a9e96592e76bf3722551bc79473  release/kernels/srd.oracle.jsonl
5aa44b6ecb744cfb32523241a2b46765937efa1d2da048e83de6e89a45690729  release/kernels/srd.sv-hosted.log
f118ea3ab4d3c0e96107d6dfa321ad9561d62869b7abef36a50e6e530ec4bf31  release/kernels/stall.by_instr.json.gz
7a58bcb9f40e7ac7f2e750823d2097e7caa75524d838028d17ae140a3a1de968  release/kernels/stall.by_unit.json.gz
31de6d003020b11ea8584ad619db344145f01e01a531105af995c6143075253f  release/kernels/stall.ccvtrace
80781eec16f4e0230a97e0e533ac2f523e5c360fe779c689cfe4edb30fa31e53  release/kernels/stall.log
500db2c482b07a0706583422cd68878301d0146c1f872ccc1f11bfdcf5c993ef  release/kernels/stall.oracle.jsonl
03e73376825c89282646708929e3fc83c527f05cec8e14e238388f23e93f3aae  release/kernels/stall.sv-hosted.log
d0ffd55e3e9d20f958efc45e56c5abce28d376dc3f4781f74f8fc95d325c82ce  release/kernels/swap.by_instr.json.gz
8438ec5bfec63d67f10280a99da11069a9a34bffa608b5a31a9dc7d4591b3973  release/kernels/swap.by_unit.json.gz
98e5250ea60a91a2e8a4d31e840a523ba270776e134dff62868d4060cb59ef1e  release/kernels/swap.ccvtrace
d128d587bd09789650fcdc4511bd8fe8439e93796e23db2932564604d2f68ace  release/kernels/swap.log
3658a26316c1ff7bc1744304a42f736e930fcde2865c8913e6cc67a22ce96667  release/kernels/swap.oracle.jsonl
26072bd3f7bf18286006a89c9e4324f90047baf6494d2854bd91e3fc58296e67  release/kernels/swap.sv-hosted.log
c856b72548906e6fff8988fd42cf6c42b582e185075d343170ac537b60f038ca  release/kernels/transp4.by_instr.json.gz
d8d2bcb19cb387b8596ca6cb47372fd95ced041b725b92e9733669e5b310ee54  release/kernels/transp4.by_unit.json.gz
a0a8df7657550fdb1bee331e8df19475a93a60d6c46710060c0c68c2c74cf484  release/kernels/transp4.ccvtrace
d574e91770a8457bc2bfc06c1c302564409154943471f131baae30dd5327c4d2  release/kernels/transp4.log
06396ace3ac19677fd39c700e408606e5bdbacb24997d663bbe8872e63dd74fc  release/kernels/transp4.oracle.jsonl
f432ae7eadfdd904eaa155bc861a11231336b27b9d7e086813bdd4ff496eb029  release/kernels/transp4.sv-hosted.log
582920fc39095f540506b1f581c335234a4384559d1df8872ffc76868539a12d  release/kernels/unal.by_instr.json.gz
390ac2ef64d6674fd2f27287ad90d1d0dc21486abe7dcbea93c009c5bce8da87  release/kernels/unal.by_unit.json.gz
96227d2f550b50685353013980833df74e6e32c1b243ab11c0247caf0bd95e0f  release/kernels/unal.ccvtrace
a750273deb9671fed42ee1b936d88211530f906043d6f5f79742cbd1101557e2  release/kernels/unal.log
c3d484bb160657a563df983d9a2532eac27f556636617960aa1e72183ac2b299  release/kernels/unal.oracle.jsonl
fdfa46d497f5aacfca879c997a9664cff5cc439982f9fb77e0d9cda89757ea41  release/kernels/unal.sv-hosted.log
6e89689b38b8f4d3f084134d2aef65a6bab3ae998c61df0d6715cf1a6d4b6d47  release/kernels/vadd.by_instr.json.gz
2cbb5ac46a317fc6b432b4a2e42fad76fe8171342fee39bce5096b7d67c18424  release/kernels/vadd.by_unit.json.gz
ceabf8fd66127f2fb44be921451fbb1d44658725452efd82cefbf5e4f412af3e  release/kernels/vadd.ccvtrace
9ab479a142f1ef8a2a1d304420661b5cbe6f1bab8089daf18927deb1bea896de  release/kernels/vadd.log
0276b6d0611a4bbcdc004ab3987214aea138245bc7217504147331689a9c0880  release/kernels/vadd.oracle.jsonl
e3f187efc3e616cc27f7ca02e44ca872b8ea94587c7225b6ff7a4077d242dacf  release/kernels/vadd.sv-hosted.log
245db5f4577cb9d09cbc46b2e87c1a487b6025ed966fd6c4a32c3d16244efaf5  release/kernels/vadd4.by_instr.json.gz
96bb672e5105118bddbe49104ab60063fd8960458a14b5d92124282b7d21f045  release/kernels/vadd4.by_unit.json.gz
6fea84732d60ebf4629c215114af5415cb3f386ef71f38f6bb503e52c4bd1b56  release/kernels/vadd4.ccvtrace
daeef6e0be7652f64d9e98447616867de79c76fafe14a78e1065fde9b96bc626  release/kernels/vadd4.log
225aa18fc9f38aa9ad615aa11de254337d59fa705877553d873062c68366e0db  release/kernels/vadd4.oracle.jsonl
42a40bd4394710f330ad4b5371cf7f33e413c423ad20a3e9f49cfbeb8c68de9e  release/kernels/vadd4.sv-hosted.log
409696f9f4544fd7ef2e1dfe3c3796e6125506f5efd47e5920fe694eb118de62  release/kernels/vaddslow.by_instr.json.gz
9c9d2f6df2cf70c400e1c1e1e4a135c906492fc4329e6d6441b655361484916e  release/kernels/vaddslow.by_unit.json.gz
e1c7ff119caa439602b0926aabcda0d2d1907861a3d0c780857cfeb2c239151a  release/kernels/vaddslow.ccvtrace
bd5bbd179b96d96cdc22abe599acd34eac956aaf0601970a5e3972c8bbfe7d45  release/kernels/vaddslow.log
e9e6218e8b8450e9f9ff6b39d659c994a1e51c527a0c5bd10d18b5658ae0e344  release/kernels/vaddslow.oracle.jsonl
c9ee1a83c395c2ca85950d590e7dd1e471ae128bd3dd24ed630bc9b7d32ecb76  release/kernels/vaddslow.sv-hosted.log
ef015531afe08725688ee236b14141b947886032a53ff4f45e1b6928ff9dc165  release/verify.log
1f3a2eff14dbda0754e19cbf72bc5003c950fc7d1691d527ce3a8d427fb583d7  release/wiring.txt
```
