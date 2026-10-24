# Snapshot snapshot-2026-10-24-d0df670

**A generated, read-only snapshot. Do not edit or merge it.** The source
is `ti-xor` at `d0df670059f405ce74674b06e6f43fd79cca005c`, and this branch is rebuilt from source by
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
| Source | `ti-xor` @ `d0df670059f405ce74674b06e6f43fd79cca005c` |
| Built | 2026-10-24 (UTC) |
| Gate | `tools/verify.sh`:  |
| Compiler snapshot | custom-cuda-complier `release` @ `f99190e002dde43344354c6a5a16a6c8f6b56fad` (source `d080beb2085d41d009b3d62d1b6cd43824fd4acf`) |
| Verilator | Verilator 5.052 2026-09-05 rev v5.052 |
| Icarus | Icarus Verilog version 12.0 (stable) () |
| Yosys | Yosys 0.33 (git sha1 2584903a060) |

## Kernels

| Kernel | Result |
|---|---|
| `addrhigh` | `name=addrhigh finished=1 cycles=71 from_fetch=40 retired=5 issue_groups=6 order=ok gpr_mismatch=0 pred_mismatch=0 mem_mismatch=0 check_failures=0 class_violations=0 overflows=0 credit_leaks=0 channels_used=25/54 violations=0` |
| `addrlimit` | `name=addrlimit finished=1 cycles=1071 from_fetch=1040 retired=5 issue_groups=5 order=ok gpr_mismatch=0 pred_mismatch=0 mem_mismatch=0 check_failures=0 class_violations=0 overflows=0 credit_leaks=0 channels_used=25/54 violations=0` |
| `addrneg` | `name=addrneg finished=1 cycles=69 from_fetch=38 retired=1 issue_groups=2 order=ok gpr_mismatch=0 pred_mismatch=0 mem_mismatch=0 check_failures=0 class_violations=0 overflows=0 credit_leaks=0 channels_used=22/54 violations=0` |
| `brs` | `name=brs finished=1 cycles=100 from_fetch=69 retired=12 issue_groups=12 order=ok gpr_mismatch=0 pred_mismatch=0 mem_mismatch=0 check_failures=0 class_violations=0 overflows=0 credit_leaks=0 channels_used=21/54 violations=0` |
| `byp` | `name=byp finished=1 cycles=117 from_fetch=86 retired=14 issue_groups=14 order=ok gpr_mismatch=0 pred_mismatch=0 mem_mismatch=0 check_failures=0 class_violations=0 overflows=0 credit_leaks=0 channels_used=29/54 violations=0` |
| `chains` | `name=chains finished=1 cycles=97 from_fetch=66 retired=29 issue_groups=29 order=ok gpr_mismatch=0 pred_mismatch=0 mem_mismatch=0 check_failures=0 class_violations=0 overflows=0 credit_leaks=0 channels_used=19/54 violations=0` |
| `div` | `name=div finished=1 cycles=977 from_fetch=946 retired=144 issue_groups=144 order=ok gpr_mismatch=0 pred_mismatch=0 mem_mismatch=0 check_failures=0 class_violations=0 overflows=0 credit_leaks=0 channels_used=21/54 violations=0` |
| `divtail` | `name=divtail finished=1 cycles=641 from_fetch=610 retired=96 issue_groups=96 order=ok gpr_mismatch=0 pred_mismatch=0 mem_mismatch=0 check_failures=0 class_violations=0 overflows=0 credit_leaks=0 channels_used=21/54 violations=0` |
| `divtail2` | `name=divtail2 finished=1 cycles=1516 from_fetch=1485 retired=366 issue_groups=366 order=ok gpr_mismatch=0 pred_mismatch=0 mem_mismatch=0 check_failures=0 class_violations=0 overflows=0 credit_leaks=0 channels_used=21/54 violations=0` |
| `fence` | `name=fence finished=1 cycles=82 from_fetch=51 retired=7 issue_groups=7 order=ok gpr_mismatch=0 pred_mismatch=0 mem_mismatch=0 check_failures=0 class_violations=0 overflows=0 credit_leaks=0 channels_used=28/54 violations=0` |
| `gather` | `name=gather finished=1 cycles=265 from_fetch=234 retired=16 issue_groups=16 order=ok gpr_mismatch=0 pred_mismatch=0 mem_mismatch=0 check_failures=0 class_violations=0 overflows=0 credit_leaks=0 channels_used=29/54 violations=0` |
| `hit` | `name=hit finished=1 cycles=228 from_fetch=197 retired=17 issue_groups=17 order=ok gpr_mismatch=0 pred_mismatch=0 mem_mismatch=0 check_failures=0 class_violations=0 overflows=0 credit_leaks=0 channels_used=29/54 violations=0` |
| `lanectx` | `name=lanectx finished=1 cycles=69 from_fetch=38 retired=10 issue_groups=10 order=ok gpr_mismatch=0 pred_mismatch=0 mem_mismatch=0 check_failures=0 class_violations=0 overflows=0 credit_leaks=0 channels_used=27/54 violations=0` |
| `lanectx2` | `name=lanectx2 finished=1 cycles=69 from_fetch=38 retired=10 issue_groups=10 order=ok gpr_mismatch=0 pred_mismatch=0 mem_mismatch=0 check_failures=0 class_violations=0 overflows=0 credit_leaks=0 channels_used=27/54 violations=0` |
| `late` | `name=late finished=1 cycles=172 from_fetch=141 retired=16 issue_groups=16 order=ok gpr_mismatch=0 pred_mismatch=0 mem_mismatch=0 check_failures=0 class_violations=0 overflows=0 credit_leaks=0 channels_used=29/54 violations=0` |
| `ldpar` | `name=ldpar finished=1 cycles=155 from_fetch=124 retired=17 issue_groups=17 order=ok gpr_mismatch=0 pred_mismatch=0 mem_mismatch=0 check_failures=0 class_violations=0 overflows=0 credit_leaks=0 channels_used=29/54 violations=0` |
| `localsp` | `name=localsp finished=1 cycles=4274 from_fetch=4243 retired=40 issue_groups=40 order=ok gpr_mismatch=0 pred_mismatch=0 mem_mismatch=0 check_failures=0 class_violations=0 overflows=0 credit_leaks=0 channels_used=29/54 violations=0` |
| `loop` | `name=loop finished=1 cycles=2839 from_fetch=2808 retired=407 issue_groups=407 order=ok gpr_mismatch=0 pred_mismatch=0 mem_mismatch=0 check_failures=0 class_violations=0 overflows=0 credit_leaks=0 channels_used=21/54 violations=0` |
| `merge` | `name=merge finished=1 cycles=72 from_fetch=41 retired=9 issue_groups=9 order=ok gpr_mismatch=0 pred_mismatch=0 mem_mismatch=0 check_failures=0 class_violations=0 overflows=0 credit_leaks=0 channels_used=19/54 violations=0` |
| `missrun` | `name=missrun finished=1 cycles=122 from_fetch=91 retired=28 issue_groups=28 order=ok gpr_mismatch=0 pred_mismatch=0 mem_mismatch=0 check_failures=0 class_violations=0 overflows=0 credit_leaks=0 channels_used=29/54 violations=0` |
| `mload` | `name=mload finished=1 cycles=112 from_fetch=81 retired=11 issue_groups=11 order=ok gpr_mismatch=0 pred_mismatch=0 mem_mismatch=0 check_failures=0 class_violations=0 overflows=0 credit_leaks=0 channels_used=29/54 violations=0` |
| `mlp` | `name=mlp finished=1 cycles=120 from_fetch=89 retired=21 issue_groups=21 order=ok gpr_mismatch=0 pred_mismatch=0 mem_mismatch=0 check_failures=0 class_violations=0 overflows=0 credit_leaks=0 channels_used=29/54 violations=0` |
| `mwmiss` | `name=mwmiss finished=1 cycles=130 from_fetch=99 retired=88 issue_groups=88 order=ok gpr_mismatch=0 pred_mismatch=0 mem_mismatch=0 check_failures=0 class_violations=0 overflows=0 credit_leaks=0 channels_used=29/54 violations=0` |
| `pguard` | `name=pguard finished=1 cycles=84 from_fetch=53 retired=12 issue_groups=12 order=ok gpr_mismatch=0 pred_mismatch=0 mem_mismatch=0 check_failures=0 class_violations=0 overflows=0 credit_leaks=0 channels_used=27/54 violations=0` |
| `plog` | `name=plog finished=1 cycles=71 from_fetch=40 retired=10 issue_groups=10 order=ok gpr_mismatch=0 pred_mismatch=0 mem_mismatch=0 check_failures=0 class_violations=0 overflows=0 credit_leaks=0 channels_used=19/54 violations=0` |
| `predlane` | `name=predlane finished=1 cycles=927 from_fetch=896 retired=10 issue_groups=10 order=ok gpr_mismatch=0 pred_mismatch=0 mem_mismatch=0 check_failures=0 class_violations=0 overflows=0 credit_leaks=0 channels_used=29/54 violations=0` |
| `predmerge` | `name=predmerge finished=1 cycles=939 from_fetch=908 retired=9 issue_groups=9 order=ok gpr_mismatch=0 pred_mismatch=0 mem_mismatch=0 check_failures=0 class_violations=0 overflows=0 credit_leaks=0 channels_used=31/54 violations=0` |
| `predspill` | `name=predspill finished=1 cycles=966 from_fetch=935 retired=12 issue_groups=12 order=ok gpr_mismatch=0 pred_mismatch=0 mem_mismatch=0 check_failures=0 class_violations=0 overflows=0 credit_leaks=0 channels_used=29/54 violations=0` |
| `predswap` | `name=predswap finished=1 cycles=1178 from_fetch=1147 retired=46 issue_groups=46 order=ok gpr_mismatch=0 pred_mismatch=0 mem_mismatch=0 check_failures=0 class_violations=0 overflows=0 credit_leaks=0 channels_used=31/54 violations=0` |
| `provswap` | `name=provswap finished=1 cycles=2333 from_fetch=2302 retired=978 issue_groups=978 order=ok gpr_mismatch=0 pred_mismatch=0 mem_mismatch=0 check_failures=0 class_violations=0 overflows=0 credit_leaks=0 channels_used=31/54 violations=0` |
| `roconst` | `name=roconst finished=1 cycles=64 from_fetch=33 retired=4 issue_groups=5 order=ok gpr_mismatch=0 pred_mismatch=0 mem_mismatch=0 check_failures=0 class_violations=0 overflows=0 credit_leaks=0 channels_used=25/54 violations=0` |
| `rogated` | `name=rogated finished=1 cycles=84 from_fetch=53 retired=7 issue_groups=8 order=ok gpr_mismatch=0 pred_mismatch=0 mem_mismatch=0 check_failures=0 class_violations=0 overflows=0 credit_leaks=0 channels_used=25/54 violations=0` |
| `rokill` | `name=rokill finished=1 cycles=98 from_fetch=67 retired=41 issue_groups=4536 order=ok gpr_mismatch=0 pred_mismatch=0 mem_mismatch=0 check_failures=0 class_violations=0 overflows=0 credit_leaks=0 channels_used=26/54 violations=0` |
| `rolaunch` | `name=rolaunch finished=1 cycles=62 from_fetch=31 retired=4 issue_groups=5 order=ok gpr_mismatch=0 pred_mismatch=0 mem_mismatch=0 check_failures=0 class_violations=0 overflows=0 credit_leaks=0 channels_used=23/54 violations=0` |
| `rolimit` | `name=rolimit finished=1 cycles=64 from_fetch=33 retired=4 issue_groups=5 order=ok gpr_mismatch=0 pred_mismatch=0 mem_mismatch=0 check_failures=0 class_violations=0 overflows=0 credit_leaks=0 channels_used=25/54 violations=0` |
| `roload` | `name=roload finished=1 cycles=106 from_fetch=75 retired=8 issue_groups=8 order=ok gpr_mismatch=0 pred_mismatch=0 mem_mismatch=0 check_failures=0 class_violations=0 overflows=0 credit_leaks=0 channels_used=29/54 violations=0` |
| `rope` | `name=rope finished=1 cycles=7771 from_fetch=7740 retired=354 issue_groups=354 order=ok gpr_mismatch=0 pred_mismatch=0 mem_mismatch=0 check_failures=0 class_violations=0 overflows=0 credit_leaks=0 channels_used=32/54 violations=0` |
| `ropediv` | `name=ropediv finished=1 cycles=1121 from_fetch=1090 retired=203 issue_groups=203 order=ok gpr_mismatch=0 pred_mismatch=0 mem_mismatch=0 check_failures=0 class_violations=0 overflows=0 credit_leaks=0 channels_used=32/54 violations=0` |
| `sel` | `name=sel finished=1 cycles=76 from_fetch=45 retired=8 issue_groups=8 order=ok gpr_mismatch=0 pred_mismatch=0 mem_mismatch=0 check_failures=0 class_violations=0 overflows=0 credit_leaks=0 channels_used=27/54 violations=0` |
| `slotform` | `name=slotform finished=1 cycles=4365 from_fetch=4334 retired=12 issue_groups=12 order=ok gpr_mismatch=0 pred_mismatch=0 mem_mismatch=0 check_failures=0 class_violations=0 overflows=0 credit_leaks=0 channels_used=30/54 violations=0` |
| `spinwait` | `name=spinwait finished=1 cycles=2179 from_fetch=2148 retired=211 issue_groups=211 order=ok gpr_mismatch=0 pred_mismatch=0 mem_mismatch=0 check_failures=0 class_violations=0 overflows=0 credit_leaks=0 channels_used=32/54 violations=0` |
| `srd` | `name=srd finished=1 cycles=69 from_fetch=38 retired=6 issue_groups=6 order=ok gpr_mismatch=0 pred_mismatch=0 mem_mismatch=0 check_failures=0 class_violations=0 overflows=0 credit_leaks=0 channels_used=27/54 violations=0` |
| `stall` | `name=stall finished=1 cycles=557 from_fetch=526 retired=116 issue_groups=116 order=ok gpr_mismatch=0 pred_mismatch=0 mem_mismatch=0 check_failures=0 class_violations=0 overflows=0 credit_leaks=0 channels_used=29/54 violations=0` |
| `swap` | `name=swap finished=1 cycles=557 from_fetch=526 retired=174 issue_groups=174 order=ok gpr_mismatch=0 pred_mismatch=0 mem_mismatch=0 check_failures=0 class_violations=0 overflows=0 credit_leaks=0 channels_used=29/54 violations=0` |
| `unal` | `name=unal finished=1 cycles=136 from_fetch=105 retired=9 issue_groups=9 order=ok gpr_mismatch=0 pred_mismatch=0 mem_mismatch=0 check_failures=0 class_violations=0 overflows=0 credit_leaks=0 channels_used=29/54 violations=0` |
| `vadd` | `name=vadd finished=1 cycles=157 from_fetch=126 retired=17 issue_groups=17 order=ok gpr_mismatch=0 pred_mismatch=0 mem_mismatch=0 check_failures=0 class_violations=0 overflows=0 credit_leaks=0 channels_used=31/54 violations=0` |
| `vadd4` | `name=vadd4 finished=1 cycles=208 from_fetch=177 retired=68 issue_groups=68 order=ok gpr_mismatch=0 pred_mismatch=0 mem_mismatch=0 check_failures=0 class_violations=0 overflows=0 credit_leaks=0 channels_used=31/54 violations=0` |
| `vaddslow` | `name=vaddslow finished=1 cycles=546 from_fetch=515 retired=17 issue_groups=17 order=ok gpr_mismatch=0 pred_mismatch=0 mem_mismatch=0 check_failures=0 class_violations=0 overflows=0 credit_leaks=0 channels_used=31/54 violations=0` |

## Manifest of release/

```
2b58f78c00b1b510450372189980da212d2cf223bed862b297f4735843651f64  release/kernels/addrhigh.by_instr.json
f6ffd413ffd7932a3b7c4f9234807bd3137626fa4cd26f89c07f9242acb0c81e  release/kernels/addrhigh.by_unit.json
c83cdc884b967a9606462f0d9b1f0abaec98af1d3ffbc374b5a2270a15ff5198  release/kernels/addrhigh.ccvtrace
2d76af250c8ab4408bca786cebc4f18e7d7174f0b49b848f215ca9ec7d3b5976  release/kernels/addrhigh.log
569f2e22883fad5f0956c57ec734e6afbdd4b8a854e50277425172d6c0cbd766  release/kernels/addrhigh.oracle.jsonl
9ea40a234784eace5beeb3630808325a9b9aa5fb35692f326516c305bc4249e6  release/kernels/addrhigh.sv-hosted.log
5a25a4973c30db7173a1e7280758d0dd330b35fa080dfcb3b1ea5c3048c3ade5  release/kernels/addrlimit.by_instr.json
368b76603c6a22ee810c84221561bf8550ed29be1dd15bce49abf491f502fb38  release/kernels/addrlimit.by_unit.json
3366409090f2b28362018c3d5b344d1cbb03b65ddeeae56e933dcc7c804540dd  release/kernels/addrlimit.ccvtrace
f131c1c5a0eec1c862905d56bdf553196db6bec3676138efebaa0a4b2aa38f11  release/kernels/addrlimit.log
bc660b0b40359a2c5a2478cb0eb4950b73fd22db50ea76b80052bc195a1920f4  release/kernels/addrlimit.oracle.jsonl
42547c2e4285fd3df81211896a11dde376a481cb9355a0005b0db010a097e656  release/kernels/addrlimit.sv-hosted.log
918748b90d1152c68c3482f9afa85db4a85df5a6423d552022dfe82c05d7960c  release/kernels/addrneg.by_instr.json
25be98515999042cbec5f15d968ea5ebc6b9ef07a216645df7b0471e0300590d  release/kernels/addrneg.by_unit.json
7826d16bfba4cb284860cc7fb4bdb00858cb004d6a5e7205cd5243c326856455  release/kernels/addrneg.ccvtrace
5b98b834c670a62767f17ae367627cc1456ba1da9a0f25ada040aa8b1d57bb6d  release/kernels/addrneg.log
16f5b0707ae44492a1efd67bb9dd38a7e79a7bbd354fa9207b9e7d150ff2f107  release/kernels/addrneg.oracle.jsonl
0aee19e3a54388fca95f651cc43e50e06d087ceb02505dd1aae395b789226986  release/kernels/addrneg.sv-hosted.log
fe19653bc4ddc1fa2c26f44801f7dacc0f8ab5aa0b9e3a920e2fe7d4906c01a6  release/kernels/brs.by_instr.json
6bde77678511627e20368efb955c620ed9ca83948085f23317f084aabae4d118  release/kernels/brs.by_unit.json
fb42009b9b85e2df72523f63d9445cfe1aff4d6419f1853bc7ef3e4b390857ca  release/kernels/brs.ccvtrace
d097fe382b0ba82da1908140c0b55ddaeede836b91ae0724dcf3b4c32206b95f  release/kernels/brs.log
e3c1cb3379580cf1aae44e8ddc8e846ef6fd661a573cfe0a8d4444b18a14dc56  release/kernels/brs.oracle.jsonl
568a008f3f9ad24bc124579f0e3e3f8e7c8a6c4fa1abd3b24f563ce45f8f6881  release/kernels/brs.sv-hosted.log
a7a3d2b87cd1a240d861a1417ede80e86add45f826aa024b1f8a5d4bb7654452  release/kernels/byp.by_instr.json
4b25933bd025372aecee24dd98c00fcec0f97dddb16fa02f22fb6e83b3aa9464  release/kernels/byp.by_unit.json
6908390fdec89c45337be71b3ebd758945fbbca2eb83cc15a95fcf709acaed17  release/kernels/byp.ccvtrace
a0e74f464dbe2fa77a11dbf1edbdf2c60baabee12cf51f6c1dc5e69c2c3dfb26  release/kernels/byp.log
5a03dfa4f3603fef49f1e3639e74e34152ca3ca5ef8e41eb959f8323040fa2d5  release/kernels/byp.oracle.jsonl
b49b29e5d135dafeb40883b9dcc09e20b29c42cc40546b4b4fd0a81a7bf0c4c7  release/kernels/byp.sv-hosted.log
7da1c18971b9f8ff2a89f79b59436026e00e5e73edb7259ddf0cf932d3478484  release/kernels/chains.by_instr.json
a2c1c7fecd4850db0930fa158b5e3daef8235f638fd3c7ed775be93cecaff967  release/kernels/chains.by_unit.json
c3ea749bc8fe0c489c442e1f99347195af196006c9f3658e0ec5655bb62d6135  release/kernels/chains.ccvtrace
8064f799d49d8a30339c85734658c91ea3cf3ab68479d300e3377da2a9a192d6  release/kernels/chains.log
26a4cc5c5524c7219d8706c2582c80357dea60be9d6ffdec99dac7d0365e2264  release/kernels/chains.oracle.jsonl
b28fe61733f2bbc1733aeba2c42a048b16cb5d160e934717b692e289bedf2557  release/kernels/chains.sv-hosted.log
325d5a6be9c3bb04d0e02873904de652aecd401c44d98080810a2242e07d8834  release/kernels/div.by_instr.json.gz
c9f082f65d11b3c928afaeb4dc2099c90251484d1c08ef3c3a799d1d73870fb5  release/kernels/div.by_unit.json.gz
0e3d855a7fb35e3e3b5c5a831ef71db255133c70862239fa051f109187061b7a  release/kernels/div.ccvtrace
22944ed0742aa29fcc398935c48ab8a655a46de3c8905c7d61639a3e6af5fd03  release/kernels/div.log
71a567b85cf85622631490187563de9a5661099c78a590adff4ed0a0c3d24c16  release/kernels/div.oracle.jsonl
5017fe5979a97fc2e8a1e9a43394cc02dec9c716e96c3cffe436de2fc65f6ac9  release/kernels/div.sv-hosted.log
4cbf740ed28a94e9df7096181dc67fe01ed05dc5cae4839cec5d6b057c6164b4  release/kernels/divtail.by_instr.json.gz
60f041892bc4263e6b636f47685584319e1eaee7dd067a171f96d0ea15fb30e7  release/kernels/divtail.by_unit.json.gz
05758e0539dd11cff70d95cc0d2034786405eba687bba1ebe445a010e6f7bb38  release/kernels/divtail.ccvtrace
c9119cb6c0a1a727f3217dcd9da4fbadcdd7dc879cac27ac49bff6de3c7613fe  release/kernels/divtail.log
75f11a75c9b3b336e446140af4579f05b46c363a76b7aab3ec88154a07ba097d  release/kernels/divtail.oracle.jsonl
dddb082935567f424933e5663c9f894720ddfad9712f4e5e713e7bdc0bc7868a  release/kernels/divtail.sv-hosted.log
1456f71de1009500b974718166bb36666c2f74270810e8650073273ab51afcf8  release/kernels/divtail2.by_instr.json.gz
30ca905a78971105379fd7a7f0192618ba648a597195eeb5afebe266b9ea1d74  release/kernels/divtail2.by_unit.json.gz
0dcbad605bafb9f4f1dd1b6dff736dd42a5e8bc907402d9c3b5b6aa6549fe883  release/kernels/divtail2.ccvtrace
03f90b63683581d820e6b0018e101e002bb9caf9d26c6c07c576ee5cbf1b69a5  release/kernels/divtail2.log
b2db6b05eb6cf4a0a7677e31d0c6c2952d5cab49d353f0bb1883fe0b2a20ed14  release/kernels/divtail2.oracle.jsonl
241d1292d19918cd679c50ec3a8235f11324ce2697385250b56a3115c37e5c33  release/kernels/divtail2.sv-hosted.log
ce61543a59a8145bd375e50c2f5abdac074afd7eb4e17a2fb66883556b437c4b  release/kernels/fence.by_instr.json
d098d6985b386080e2b4bf4fb5bae4593f20b92c5a6ed1f81bb4602888f4d978  release/kernels/fence.by_unit.json
bf3e337166d40bd281db328c002f04af93e1235c860be6683498c94d4162dba5  release/kernels/fence.ccvtrace
afe2bb76c332ad9dff80134528383cb990885cd57fbca2074f9825a62de3bb56  release/kernels/fence.log
d1d40317f6cf5bfb430cda1f9c0ef676609e59cabe2a11623c42ffbeca93142b  release/kernels/fence.oracle.jsonl
b68cc24c9093ea608fb7a8d220c5cd9d238a4d2558faac1c42af33fb95ea817c  release/kernels/fence.sv-hosted.log
4563a83bdfa28d4ced36865f01005217f2ddd962f34d84701a55793414a1c978  release/kernels/gather.by_instr.json
2c50d05f47e718d68a0e1fe0864a721e2a4041c65055f5f64e85d2de88cb66e9  release/kernels/gather.by_unit.json
50e9d5199af07897f74281549a9203b520e1a0f155e35b68260e46ed50d8e878  release/kernels/gather.ccvtrace
dc37992dc26fb9bb214e7e08de4568b2dd09f08fa28160119829fbef91812ebd  release/kernels/gather.log
0413e781d8d6ff578c64eb1f800b7931e66f676d5cdabb97b94a4033e6037662  release/kernels/gather.oracle.jsonl
488bb3d1877ed874b8a76225c55750fa6ddc84b8a3a1a2ea2b11a2f406af70cf  release/kernels/gather.sv-hosted.log
aab8bcdb7ff3c9630e51c6e55e56bb11f37b2b1c982b9a48388b8bdeed8047b1  release/kernels/hit.by_instr.json
6ac2bad8285a6286eb7e4777771036382f370820f5974db1f6632213eefb5ecb  release/kernels/hit.by_unit.json
56546987ec2f1496c4f7cd38c53d1dc419a0df50b4747966d4b4d76e04dd7547  release/kernels/hit.ccvtrace
8e17c37c5a0de79f4c87181f48ae9450ea6d04ba5a101e71e8c3562543265024  release/kernels/hit.log
7ba9603e0088d9164de6528f16ef6a7fa9ce5821c8c12b52cbb3734e39b9fd52  release/kernels/hit.oracle.jsonl
23fd845396176ab0633ebd9322fdf428ad0c1d33da352cf355cd20c93aae37ae  release/kernels/hit.sv-hosted.log
6d80166e9edb5caa785a1239bcfd6bc33bf614c87b0e586cf25081e347e6ee79  release/kernels/lanectx.by_instr.json
5420758a1836147a0a7c92f9b8a3b9ed3009bc9993cd5624b5fe435427683cc6  release/kernels/lanectx.by_unit.json
562179d008d4b4a511fcd55ea4a194db35ed97869d5f2d76851cb1d3184efb15  release/kernels/lanectx.ccvtrace
1d8b33279814c5761d2423e63545735aadf052b52644dd8ed9dcacf5d626cbce  release/kernels/lanectx.log
888551babf540db8e3025b82e65ca655013f93eba3c8a65689d069d52a7e6039  release/kernels/lanectx.oracle.jsonl
ec8467774491efeb2f391649e04df885568e073d8a70054910eb3253f789a114  release/kernels/lanectx.sv-hosted.log
e26cd0686ef472396b62c4aed9220fd659112d7d0ac72afbeb9094789c79d855  release/kernels/lanectx2.by_instr.json
1e0c0885eb302cb564a65adeb1d1b3c9205332a1b39653f056653034261167da  release/kernels/lanectx2.by_unit.json
0cc65d38651fca5db3224d51f16aa6cef8bf9cd78dd784efdc868cd8032c3a0e  release/kernels/lanectx2.ccvtrace
49705188f4531effb97662c664533537cf487dcddcfbdab2e76922c6a34e8e12  release/kernels/lanectx2.log
45c13056dff5c73ed0c9ece56cc36f929bf335322193c7d5eb38710b1d1dfb02  release/kernels/lanectx2.oracle.jsonl
9b21cf36b12191e383e9b9e76165837b90b36fddcc7b9a2db0bd64ba55f063f1  release/kernels/lanectx2.sv-hosted.log
f706ce3c16d74211f8c253cc48377c4d12b87be4296910a3b3235cf2b1371f20  release/kernels/late.by_instr.json
2090a40a5bafbca35cb35e0728554ffee18311d7d5b9ff85c278d31d4c0020ea  release/kernels/late.by_unit.json
e3bc54bf1012703f13ba6ac4ab0ea32f94878403a23d0d222c292de893c11e95  release/kernels/late.ccvtrace
7551d1eb62a3a1902937c8bc0a36c641f6f350d03f1642c1f1768023578a0822  release/kernels/late.log
86084f6bd747a2cf32acbc0ebd96ebd3e4ef2d8d9e21be49e3ae49290d7927f3  release/kernels/late.oracle.jsonl
6f150cac8c4954f74ae0f954ea6388b19022e2ef6425b8bca6ccced5aa923d09  release/kernels/late.sv-hosted.log
69216d01c2f7a133e7a2ff83615168cd7884c0ec0c058c9a3dc23a62ef28f8d1  release/kernels/ldpar.by_instr.json
48bbb3019256e11d9cf3ec47c43afc40ad3fd38b26b5008ef2d9a283ac22a31f  release/kernels/ldpar.by_unit.json
f8910cc30261260a9736eb87a3620426e4a27d540e949a39c8f00bec84254a1b  release/kernels/ldpar.ccvtrace
69ff69b0503c6b2e3e53752a34ad35421aa16ce69b3f6000cec3f7408e2f6c83  release/kernels/ldpar.log
8ac08538e9c807637babd61b31e340f7461878ada31f0c0b83cd66331cfaf486  release/kernels/ldpar.oracle.jsonl
8e8ba229e4343ef06abafaa781be1dd9fa04bf598bd4c0c0480bee180ecc26df  release/kernels/ldpar.sv-hosted.log
459e9738b7a9124bdb9f13b0d5c15e6430c2fdb51852155199767b24e17b9101  release/kernels/localsp.by_instr.json
a55652cb9ca50701b0a5a490ff6443df0447707086b691f5ca916f9613501a74  release/kernels/localsp.by_unit.json
409767cd058f24483376b26256cd8e33ce368e12efdf2abd235bfff05f943dce  release/kernels/localsp.ccvtrace
17066d9b49a21ad16a6b8ae1a713881bc4e76922fb5a1b3c625f0bf389681746  release/kernels/localsp.log
55e3c9f36e7f7d38c0ddd38903aff4bb4509ae862015c592e6b937ea258042ca  release/kernels/localsp.oracle.jsonl
aa8f054908a0c5573879da74345d0fe1c73c211240dff18b4e96d98b23ab4c39  release/kernels/localsp.sv-hosted.log
75939561e364e95dd365f3527851c2c7c745e2823abce8fde50212c72a6df22f  release/kernels/loop.by_instr.json.gz
489d596f836b78f4dadba5cb4dbf144aaa554bec8356c87e80e235f860204032  release/kernels/loop.by_unit.json.gz
1f14fd7fb0c254ff64ad658a7c8853130942f1bf2b90475f3b2ed967a7e48780  release/kernels/loop.ccvtrace
ffc81ce3b9792e8097f92f72749b282d5e3eae588e7618bc5c2251711ace59fe  release/kernels/loop.log
03ce5920c06c93e93516d8e53c3f7169f14e3593de204eacceffc0b8a3e32016  release/kernels/loop.oracle.jsonl
53d1fe0a9850907c325d61c22adf360151d604c88d3285d31b671ba9844c7ae5  release/kernels/loop.sv-hosted.log
7695e79b26c7643454bd11eb90cf58ea26e52b0c8247fb562030216c34ac124c  release/kernels/merge.by_instr.json
bcd11367912b59e58aaf4373e36a38f21de6b910310eac5b05e7822d67bdec80  release/kernels/merge.by_unit.json
8b648dcbc53ceced5ebbe17909d511a46af125536e12fc23e08d662ba912e961  release/kernels/merge.ccvtrace
7ee948779326da91f1930ef449ff2dd6d11b2e68876bcc6721994a36de75bb91  release/kernels/merge.log
f96d28815f8756b1f5a45ded53e6170883d2dfa10f9eef0d14b8050b1318164a  release/kernels/merge.oracle.jsonl
a64c121eb40b0d5977ad5c126ee87edbe2cac8529efb6fd3ec8a0b6d8626bcc7  release/kernels/merge.sv-hosted.log
ea9abd61e11c5ed36fc1bfc1e5b7e1f53fb32f19aa57def9cc0cd9d75e883521  release/kernels/missrun.by_instr.json
df80f6625854f5a80aefeeaa733dedf47b5203d1882a6b858070dd2cda258072  release/kernels/missrun.by_unit.json
0325f4041b83df391d334d1cc4faf665e569a9792968c99a2c6ca957fb3a1faa  release/kernels/missrun.ccvtrace
5e69ad919a8d1f96953817415a115354dbeeebc0192ff3ad76d5c16eebacb35f  release/kernels/missrun.log
531bdaf281e5590774bd2775427f25e4cc0419cf8e3d5b6999843ffe9ef87258  release/kernels/missrun.oracle.jsonl
c00ffa5fb65106af9a5b110e847dc709a7f5ccee367604abfbec6a3a042759bb  release/kernels/missrun.sv-hosted.log
642f8277f67ae10aa03c00b3b323944a9edee676e56f3c09c30200ee6dfd8ac3  release/kernels/mload.by_instr.json
77307a450638bd26f3a9c9e82d098c1fd1a48195594dd3c6c113ac7a9adfc294  release/kernels/mload.by_unit.json
6768426392dc3f36bb334dced65c2d5b9be0fff7951518afb0196e2549b87404  release/kernels/mload.ccvtrace
06b5d3cbf9b25cf9a9e42feb1377346d679b7fada431ab1187d0b0a923615e51  release/kernels/mload.log
8000e477b9a95dfb9f0af964e8346acb9d36f1358fd06ffc4ff7cf599d2b8868  release/kernels/mload.oracle.jsonl
5047e68cb5faf863d05982e0dfe8042a93f5116262002e2a59254abf7d4248c6  release/kernels/mload.sv-hosted.log
e647616c52dd363b2fd8f9f0b18ca827015ff4795f3d2cc4eba33e4a09b71f2f  release/kernels/mlp.by_instr.json
00154913a45b7f402b08ab8da8fec4e3f8bc5164a2de41034c2f928f09b4a3b9  release/kernels/mlp.by_unit.json
bfe7d7b8d74638e5ac9d8a1223c5faacf805e581f44329d24c2bc981e58ca93b  release/kernels/mlp.ccvtrace
707552b037d04e4b87c25f23644515f73292d7a160e4fedc066993bf2792e01f  release/kernels/mlp.log
138d282f88d56c8ad648a91af0a983254b55d9fa22942c00d47b327f516a6e44  release/kernels/mlp.oracle.jsonl
eb6eaa8da056c533ead0d2e4baff93b7036645952609a9ab970a6f83ec44000a  release/kernels/mlp.sv-hosted.log
db5bb1e7e5b8b0051891e2f1416e2cb7c62d7803f803059b91c4a9975a90fe4e  release/kernels/mwmiss.by_instr.json.gz
c9addd49903ad05c48f86aabecf2ac375b9bbd61c4db522120aacf3bfe2bf060  release/kernels/mwmiss.by_unit.json.gz
78a517089229d5100b786a37309e36e21b1bb24fddefd56e665cc994bcea03f4  release/kernels/mwmiss.ccvtrace
0a71010e17a9cbec8cd080640628d9ece75481f6ad9d4ffff07b1639f019381e  release/kernels/mwmiss.log
8abe8e8997456a2a6711ee72da54d854b24e20abbdab28e4b7271c0d28418de8  release/kernels/mwmiss.oracle.jsonl
213b3ee07ccf5e4f62713592b671b158f4c12b30907e08e53685b92a22f6f5eb  release/kernels/mwmiss.sv-hosted.log
afe2c2e72c940609c91b8c2b9a0561589463c7e22b5f56b23f922ba56adc5449  release/kernels/pguard.by_instr.json
9bcc7a10c07327acd06b118f6f4ae6da34d5b0e12b321e42194c9ffdade7349c  release/kernels/pguard.by_unit.json
46f841c8cff7749a9ef67543c8013547a6f1ecc62bb94ce209fc92f18036eafc  release/kernels/pguard.ccvtrace
a4907e84e98ec16ac9c45e51598be3f2fe10e3aa7a24829c4be2ff19c4ebab28  release/kernels/pguard.log
690e56f1cb8d97cbf67124b7dff3ad0a90cb8981814cd1709cf0cd0e035b3bd9  release/kernels/pguard.oracle.jsonl
46d04497d33af4b7332c968d74d959a129bde278faaca52937ed70dc71e678b5  release/kernels/pguard.sv-hosted.log
44a30ae97d33250fb7e0c469a55f2a9b4868b20d4503f4c484ebb148237de1c5  release/kernels/plog.by_instr.json
8aaa681d0ef8222d6fdced764adcee40e341a5d1333e36979cdaaafaf88855c3  release/kernels/plog.by_unit.json
d6238864e0273ef60610795fdbefcc20593f320ede9028322a37180f9f61025a  release/kernels/plog.ccvtrace
9fd7e01e65a7644cb3362a35cb42ed8beed930501388f8b0ca64e3fe2f484e53  release/kernels/plog.log
c230f13f2e1082b306a9c5ab7809ff36cf5c1b2e47dca6b7a71f741524d403f5  release/kernels/plog.oracle.jsonl
f059be5936e9b0509aeaca7b6d1e7791b7973aab515af7cf3b2dfba20cd89617  release/kernels/plog.sv-hosted.log
eaf63d00c57033519613a8117d065f259b2be59ddf2bf6052dd25315d11cda16  release/kernels/predlane.by_instr.json
b64055d7faec58b32fdab070c3fe29335f3b5f28b7e0ef465a34127e10130288  release/kernels/predlane.by_unit.json
7d85861ae70977be261e250045781f870da18bf258c0c9d9eddb213330efe370  release/kernels/predlane.ccvtrace
ceccf3f191c43204fc3cf1d589e25ca86f2ee9a8a64192d647c4af180b0b16b8  release/kernels/predlane.log
c45f4177b9e84fc8a6e36b13534a0c7636eb30a3f8531847100ce5e23bf404b1  release/kernels/predlane.oracle.jsonl
00917c082f57fe63179613b23e61995611680a4ca9525dedd58ecaecef44a95e  release/kernels/predlane.sv-hosted.log
af6a93d7e99656835491c44fc9f7d054fd95485226b8cc522af790c1a223be67  release/kernels/predmerge.by_instr.json
eed9a655978bbbfd0ca7162813e8c28f28b00b6a73c02dde8eb0e1dd91747f6a  release/kernels/predmerge.by_unit.json
f3cd4cdbcf05011f053212a4c11689578e06248909fb459f62722de54ea2a37a  release/kernels/predmerge.ccvtrace
2094ebce0d6ccd1dbd131b32dd924d98926762df9f99334ae09fdacedba5a68e  release/kernels/predmerge.log
6c737c49434bcd08e3e0814c8b1dbf15c586ae74f7929ba3148ddcee2c62c845  release/kernels/predmerge.oracle.jsonl
cb9fc8ff622b079c359a99ef19149015282ff4ec06883628381854a7b13483f6  release/kernels/predmerge.sv-hosted.log
480a36c3c95f8b70c92145815b09480a885bea0adc7864a293a48c1ed96fd9e1  release/kernels/predspill.by_instr.json
2bbb7603e0a3b3c34b06c875bf2bc152a1a809a0cfa9398bacea0d4986380b97  release/kernels/predspill.by_unit.json
9497543c5ebb19f944de33a1e835118f003de4d93802bf5a04746e99c6cf7b99  release/kernels/predspill.ccvtrace
46e9f72b1ca07937de428b940bc3b80f49d5d805566991580ff08cf5997055cc  release/kernels/predspill.log
b7c84c6478117ffa0f06da0e6ad1e4628e2683426a7911080810e78e06a5242e  release/kernels/predspill.oracle.jsonl
5fed2c2fe5c8913710be52a114753aa655884dd8c5e76d3629e00a26ee5335f5  release/kernels/predspill.sv-hosted.log
fdd14c989823581dd978d4d6d43530e86518b42dc5c18ecca3f8fd7fa303c33d  release/kernels/predswap.by_instr.json
8fc305cf4da741e2080f253893754884e046b95cf91b7123064ffbd3b25172ca  release/kernels/predswap.by_unit.json
48c93b63d0bdfdb7213f35dfd54633e175fefd59a3f4ae88bcb0b3560ab78776  release/kernels/predswap.ccvtrace
23ecca2e66a41f0d779413bfd21fee94a4c89f8680bdaf631d58dc77672b0d07  release/kernels/predswap.log
a6d4f7ed517553816d889c7c9eeb6bcfd1f6c973fbf682ecb69f3c2de619f7bb  release/kernels/predswap.oracle.jsonl
440c789ae679d1f6d692297912cad1e7ba36be08b9b2db06b9ffa3530ea7ce6e  release/kernels/predswap.sv-hosted.log
399e3bcf483450eddff6ca4b1d24ff349792e885f0915ea7ab8e5e155da3d2e3  release/kernels/provswap.by_instr.json.gz
838b89ba5f4f8d6b5f7a334eb0bea92cfee104260f2338a03ec1b699a4e5ff3a  release/kernels/provswap.by_unit.json.gz
4891e58ef27cba6537652224844642b8145a0b3ff6496ba929b4aca41b360bed  release/kernels/provswap.ccvtrace
003fdf1713685a408ad39f16aba2fc5978461c57a39015325f69bc78be478121  release/kernels/provswap.log
c9c32a793d54cc7401477f582487f7e8b345b2669a75337b8d6327120d98e5dc  release/kernels/provswap.oracle.jsonl
c401c606ac63d90fff5414c60e401383b2ab2d1920f86ba23d8d914d04e70550  release/kernels/provswap.sv-hosted.log
0abee8ba02e94d25203dd1bbc6611c55c65071b468c4bb6d6c1ef600dd1479a2  release/kernels/roconst.by_instr.json
17965a859b81318f739deb4fdaf72403876875c6817e1fa31370cf333b28c3da  release/kernels/roconst.by_unit.json
c3a5aa50b5a4bd942d9cb331ae09919b3538febecdec92ec7929b95b684e4e67  release/kernels/roconst.ccvtrace
7dfb6a8240bade2ef19c976da8064326abd376c895fadbe274a885c37a4c2eb5  release/kernels/roconst.log
8087c0671de620162881aecd38cd6114b78e7be6bd71201e3ec02c9a2e2e750e  release/kernels/roconst.oracle.jsonl
559d3d25b3ab11946f660b979ee9d66e4cea5e9c376f77b5e2fa411b7ae923d6  release/kernels/roconst.sv-hosted.log
62609acb9c7dca04d571291ca5877a0150a713e195452d39e65d63ba5cca323a  release/kernels/rogated.by_instr.json
07cd870c0f21f6bc9f1a90aafbcf57d12d60a5a0b7c719a584ca8465272e6356  release/kernels/rogated.by_unit.json
a0bebe5fb26e902ed4e6987990946999dcb97933348abaa78a06759f5a2c9e59  release/kernels/rogated.ccvtrace
4fced9f6967b583526eb5813c442e45df3cc889cd48b40fc2f2fb0c6ce58a036  release/kernels/rogated.log
7cd02bd4cceec5a044d6b4d6a80df1e68ed0ae71b0b2a953143636d5b809ea6c  release/kernels/rogated.oracle.jsonl
6999b0e75d13306257dd6fc10f808b732b205fecfa70ce8717cc2a83c58a0d2d  release/kernels/rogated.sv-hosted.log
49d939eaa4635de1842045bc0dee6fbce1e13de29c3d739ab3b48d03702cd489  release/kernels/rokill.by_instr.json
018d919e124c0ea7252a15ba69ee6d76d2e31331c537fa0ee0c375f611a7bc8e  release/kernels/rokill.by_unit.json
978cf2c92fc50ad79472abcc60ca43ff3a36999169254e7bef8fc02e3f671c25  release/kernels/rokill.ccvtrace
fca340509a21445af72dd1a978c0fc2106fe24d5edcaa219c2f53ba20914faef  release/kernels/rokill.log
94efcef96af469a512d346ce61623980fe86383188eaebd55120f716db596f14  release/kernels/rokill.oracle.jsonl
f6098293e71c66b3d11c73b9d8bda163726fe023b7ee6f71922d84359a25cfe6  release/kernels/rokill.sv-hosted.log
fdc711d88326a1b1000445f46796eb6f29edb64db30605fe661ec88f2c56d918  release/kernels/rolaunch.by_instr.json
1da82c40a535127d7b4fc1c95d29280c1946fbe5892326b86cd989c86a8010d1  release/kernels/rolaunch.by_unit.json
08efe5da32f0d460a6d36b60a6ce380b6615e2b7f21b7327cf52e07e2bdbf6c7  release/kernels/rolaunch.ccvtrace
ff64130b2f508255193d427e2c353d3e213ad8e981cb797d6edca4d8cdb05f68  release/kernels/rolaunch.log
e7dad585c3e70615de04330fd03f4f282c29a005dc1732a35655fb261d51139e  release/kernels/rolaunch.oracle.jsonl
24cc4c32b7b454f53973aec7b27c09f440b6958707c596c0c6556ce1c36e2203  release/kernels/rolaunch.sv-hosted.log
0abee8ba02e94d25203dd1bbc6611c55c65071b468c4bb6d6c1ef600dd1479a2  release/kernels/rolimit.by_instr.json
74d24d2c752af3bca5173ae2e4111b7f12c15f55d0554c915c94969f66533e41  release/kernels/rolimit.by_unit.json
7ce7b0690978e5ed2aa4388466d2e54b17446b7b8a2a022f85b7748323865fac  release/kernels/rolimit.ccvtrace
d5d61caf745001ff8acda58012caf744ad47b3cfaa67e7f78735ba1d6868b84d  release/kernels/rolimit.log
1c5bc0cb8e8b2e69505fb5a551a16d5d10c56f232b88da7a27e336ad7d962de2  release/kernels/rolimit.oracle.jsonl
2bc69cc6b8929d3d87d6a4712756ecac4e18d4a400e8df9f2b5ad194e144566e  release/kernels/rolimit.sv-hosted.log
0101c51d43d34fd7351dc76ef0e3d126078d66a5f2e07aa9f32aca63e95e617e  release/kernels/roload.by_instr.json
9be97a5066adcb6e9241d6de023f7be2a03192307e7172d86a0df8a1d966e41e  release/kernels/roload.by_unit.json
d15f1c17cb72af46c0cd9586823679fe5f86e9a4cc7a8f4e384643ee5b0fae91  release/kernels/roload.ccvtrace
7fa3c63a14d42a1d7a4b5808cfc0897e1de3f8da090df45186dd74a73a7caa4e  release/kernels/roload.log
f7c1309cc9764769fb5803f6fd0f2f5e1eb418f2d23fbe5e17cf5f9106869fdf  release/kernels/roload.oracle.jsonl
bd2e988e52a18ab9e1e308f2e76233f4afa498aec54d8135aaf9b4db558bc4ec  release/kernels/roload.sv-hosted.log
6156de360d542729cd6cd6aaf88b63b5526a49748990241b4917f5a9d4f82425  release/kernels/rope.by_instr.json.gz
a6df29cef5fe65b036c40dc397df0650c9e6f5e34adcacca7c3b2b4809848af0  release/kernels/rope.by_unit.json.gz
b6ddb4104d2dc3df7afe4c84ec92fb506b455dc7b73e1d04704c7130a9beb912  release/kernels/rope.ccvtrace
f00fd3ac3fe4d6a1319e5995a03ba10618da6543411085ab9979dd2901d3e282  release/kernels/rope.log
d55f9efae392dc8877c102c01c0810e7654b666b6ede386328108164c6cf88f3  release/kernels/rope.oracle.jsonl
73a84a31cc8b420f9d886bd3bfe15fdad9f8bb6493e3736d1602d5ecbb4b45bf  release/kernels/rope.sv-hosted.log
0296154cbedc27c935f960feb66098dd6f77afb44d1a01ebf2f251708441503a  release/kernels/ropediv.by_instr.json.gz
67080d5aaa46e39be815af0c50b3d2b23a2f6fe31e502c7f0fbeee8719aabb9b  release/kernels/ropediv.by_unit.json.gz
5a23195ea3814131fbddcb67ec4df1a06a60c0017ed914186bdbe3cf742da040  release/kernels/ropediv.ccvtrace
4ca3943667f54f89a1f62bdac48bb1f6ec1d2c0035f123face3e0fa4d794244b  release/kernels/ropediv.log
10c0ec6ec18b7b44638c790033109198c079d07c1537bf193353ccedd00a920f  release/kernels/ropediv.oracle.jsonl
cbd4b033045e7d640a1a22a5f4d18d58da8bc7189a581cb9f7ea05fb4453d0c5  release/kernels/ropediv.sv-hosted.log
74a26fc296ac2e3e9e413331993799e0517b830b187685e54696ae4af3536d3f  release/kernels/sel.by_instr.json
e2409925f9a19a07cf2a97118ebd04228a84de97ca58a85a385f50394f201f23  release/kernels/sel.by_unit.json
b0212ca8efa50901ec7eb6dc527851d792a7c185171d96ad34fd3de38585a0c0  release/kernels/sel.ccvtrace
6a3e22fcc8622ce46f00b7cefecd56bd3252e3cf3430611eb9f2bcf4065add21  release/kernels/sel.log
87f6a81e8afa004c8039bf2f61c90176fcf29ab29bb17ac44aa016a5cc8438fe  release/kernels/sel.oracle.jsonl
9bb4c72f2c1bb68c2e8aad281bfdb093348f35913d868c1299712b7f00d42597  release/kernels/sel.sv-hosted.log
5540ad2f05cb1759cb2fd1433fd68754017d9d9ded1a66a13207ee416f0265ff  release/kernels/slotform.by_instr.json
2c32ef4201bbe625152c6595d355399cbd415401948d0c05e8c08caf6f460929  release/kernels/slotform.by_unit.json
8d107923a467f89de254481c34a896ba99b9d1ea40306c019d6480651a0c4b65  release/kernels/slotform.ccvtrace
12d24687d7c32a9c0985feaff4ab5d5e976c73fb47d58588a573679a272b2e36  release/kernels/slotform.log
8b61db7419b18cea8a646fb628218447e72e84a18a9891ffb73b441736138ab9  release/kernels/slotform.oracle.jsonl
0a28944e6331733da6bad53d089d076259c98e02e62f39a19b90f54b2092f23b  release/kernels/slotform.sv-hosted.log
cbe19e1a13badc28d9895aa0144dc3cbe448f36d5e59a69ec6942b9714902180  release/kernels/spinwait.by_instr.json.gz
de5740702f3e14237b37e67d25fae99480788aeaf0f960f05c7dc98dfa3e4904  release/kernels/spinwait.by_unit.json.gz
02df2d056adab949a5f28be093e834d66488ef8be369b66d9986a98ed9e7a0e7  release/kernels/spinwait.ccvtrace
104496d3f3b42d11342698b969a375a2a44b983c5bca40921d11bdf8bab33df0  release/kernels/spinwait.log
868920637236c878b33779bd450439466fc3626996a3164573dc11d437d5c709  release/kernels/spinwait.oracle.jsonl
8e092080dc8d6c214af29fb9b42b4b4fa082ce09dd19235000ef12770d2ccc96  release/kernels/spinwait.sv-hosted.log
01c0539dbd211c3e004736ff09d036a40fe064235e645a4c199ba4746aefe015  release/kernels/srd.by_instr.json
ca244bd14fec2f0d8a3aafd4d8767d04689c5c1641fb0461f6fa4e1e7cb7b3f6  release/kernels/srd.by_unit.json
16e2271ca75064c029afc8d2a136585c83390ab3355bde9e41417749d55589e2  release/kernels/srd.ccvtrace
7c5654fe9141bdd27be0aaf2f6779b92f77520115d983bd264c2cffb71fa0cf7  release/kernels/srd.log
b08eb5e3673cac7eebb8b72af5ed3783c8e70a9e96592e76bf3722551bc79473  release/kernels/srd.oracle.jsonl
0a88fa73c284a8e4d9a47b4947fa46b2afcf3c4bc566eb1bb972a437bb6d451e  release/kernels/srd.sv-hosted.log
c30bdffd8655a29576ccc58a43f683e257f75562f8ccc8cb5d3792d783526101  release/kernels/stall.by_instr.json.gz
a7016a29dc92b066ffb8d7c9bcc00c2431bd1c41bb3d111b80061fc768d38f51  release/kernels/stall.by_unit.json.gz
b7e16257e992a8f46a75c4a71277b2b5041e8e5be4338aa81e92d711ac1ba1a8  release/kernels/stall.ccvtrace
1dfe7ea04c087966e3d05271ed790af239e117bbb5d8202561d0bea5193bd80a  release/kernels/stall.log
500db2c482b07a0706583422cd68878301d0146c1f872ccc1f11bfdcf5c993ef  release/kernels/stall.oracle.jsonl
cbd6b4c4f43ab0331171f5c10b70b266168131734e84f0d92d3103febf1fb22f  release/kernels/stall.sv-hosted.log
d560472aa34524eb9be077c83419c332ba567d393661283288e61798cc5bef15  release/kernels/swap.by_instr.json.gz
31d04c7c5c826a095d519b411bab540ea64ec267eaf0a60ddcb255c69195bdd5  release/kernels/swap.by_unit.json.gz
0c75978f14b3c8e6ecd1de4c37165b489b5f7e506dc712b4415c26af4e11944c  release/kernels/swap.ccvtrace
7b9becdab408d77518f2e76b65a1a04a7227c8b2baa3eb47763090e4286634b8  release/kernels/swap.log
3658a26316c1ff7bc1744304a42f736e930fcde2865c8913e6cc67a22ce96667  release/kernels/swap.oracle.jsonl
071ce8dd24e9fae14b33f353df29ade81878d0d7c7382c4b412356975ccad9ba  release/kernels/swap.sv-hosted.log
bcd5de7a6dacd47e738a6391c0cd525bf945a8cd39819976a713a2fd61c35870  release/kernels/unal.by_instr.json
a2dc8be622206a4809db273cb2c04742980044d4454918566451b54ce988e04e  release/kernels/unal.by_unit.json
2bb24c1f36428a5ed977bfa618185497b7ec36a650af3a8215d602ab1d1aa71f  release/kernels/unal.ccvtrace
bc649d58e0c77c53b585f7c70438a985e0a92a5a5e941ab8b8ad7dcff3b4322e  release/kernels/unal.log
c3d484bb160657a563df983d9a2532eac27f556636617960aa1e72183ac2b299  release/kernels/unal.oracle.jsonl
17ef8f61055d12e7843c8870282eb1dc18e4039cbe4e472a431674cd87f413a7  release/kernels/unal.sv-hosted.log
24372d75f356062fbeb4096931469258551f176a33c25b276bcfd96ae3b2b3d0  release/kernels/vadd.by_instr.json
bbf5c85ba697da9a4b209a6a4987692b3c7956398bd5c5af5be313a877c970ef  release/kernels/vadd.by_unit.json
5a18e2292f75344bb6fb21064a23b6238a7d706b2fa522eb07155424147bc730  release/kernels/vadd.ccvtrace
63e96fd9d9b832965b302aa5f32d5aa3cd0aa77f1357fc5e26010c24895bd372  release/kernels/vadd.log
0276b6d0611a4bbcdc004ab3987214aea138245bc7217504147331689a9c0880  release/kernels/vadd.oracle.jsonl
f91583b33ab25f04c8281df0187c5a05912bb0be6914171ac2941346eb56cc2d  release/kernels/vadd.sv-hosted.log
ab619733ce66c4d63b707883b46b2f0ef44de216d5ebca29053bba8eee7bbfaa  release/kernels/vadd4.by_instr.json
4f98859e256e2ed4e7627d15ea51248708469164719dc6ba99f420cff43b78b2  release/kernels/vadd4.by_unit.json
28621a54af3162e415c7b08ae6e631f7bf2a862a2617d87af89535fff0385db3  release/kernels/vadd4.ccvtrace
042de92db23097fd5f3ae51f5ba326774fcf5e7160164d2e854e0d65dba893f9  release/kernels/vadd4.log
225aa18fc9f38aa9ad615aa11de254337d59fa705877553d873062c68366e0db  release/kernels/vadd4.oracle.jsonl
a14610a108adef8a5f7e1fafd139089bf174fd89c8ad723cc33d89e5c9e42b67  release/kernels/vadd4.sv-hosted.log
c7df0f2070f9aeb4aae238b104cd01941549ec5ff93bbf3d6cbad024f48b8ad5  release/kernels/vaddslow.by_instr.json
3ea8b10f96dc2d6b4e440abee7af1172b06bfc0668c44313e8aba478cae3a417  release/kernels/vaddslow.by_unit.json
b9091ec8d54928d3de24ade1562574c4167c4a6a7c738dd53676dcf35a31e84e  release/kernels/vaddslow.ccvtrace
4c958f72b79c53a608b3ff93d0af34d4954b6e8570fba09f9fc9ab79da5c1399  release/kernels/vaddslow.log
e9e6218e8b8450e9f9ff6b39d659c994a1e51c527a0c5bd10d18b5658ae0e344  release/kernels/vaddslow.oracle.jsonl
77eb70b535433660f92259a0343fe3724fabd20244efbf7f9f1e8fd906b3a4bf  release/kernels/vaddslow.sv-hosted.log
5b64efcaa59f79d1195d81bf2258b07471e763766cb6e0afab614c072ac3aa09  release/wiring.txt
```
