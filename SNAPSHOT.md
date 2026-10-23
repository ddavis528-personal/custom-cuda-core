# Snapshot snapshot-2026-10-23-8be8d9b

**A generated, read-only snapshot. Do not edit or merge it.** The source
is `claude/custom-cuda-core-infra-6msg93` at `8be8d9bb1b3165840142909b9a67c3167de869bd`, and this branch is rebuilt from source by
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
| Source | `claude/custom-cuda-core-infra-6msg93` @ `8be8d9bb1b3165840142909b9a67c3167de869bd` |
| Built | 2026-10-23 (UTC) |
| Gate | `tools/verify.sh`: PASS |
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
9f29f866f2aa1f42a978d516d37c5bdbd401119503fd562d8d8541909e5c6aa1  release/kernels/addrhigh.sv-hosted.log
5a25a4973c30db7173a1e7280758d0dd330b35fa080dfcb3b1ea5c3048c3ade5  release/kernels/addrlimit.by_instr.json
368b76603c6a22ee810c84221561bf8550ed29be1dd15bce49abf491f502fb38  release/kernels/addrlimit.by_unit.json
3366409090f2b28362018c3d5b344d1cbb03b65ddeeae56e933dcc7c804540dd  release/kernels/addrlimit.ccvtrace
f131c1c5a0eec1c862905d56bdf553196db6bec3676138efebaa0a4b2aa38f11  release/kernels/addrlimit.log
bc660b0b40359a2c5a2478cb0eb4950b73fd22db50ea76b80052bc195a1920f4  release/kernels/addrlimit.oracle.jsonl
96da605b462a695f686058a20d9c1e8d2387f8656b190899039899034b1c2857  release/kernels/addrlimit.sv-hosted.log
918748b90d1152c68c3482f9afa85db4a85df5a6423d552022dfe82c05d7960c  release/kernels/addrneg.by_instr.json
25be98515999042cbec5f15d968ea5ebc6b9ef07a216645df7b0471e0300590d  release/kernels/addrneg.by_unit.json
7826d16bfba4cb284860cc7fb4bdb00858cb004d6a5e7205cd5243c326856455  release/kernels/addrneg.ccvtrace
5b98b834c670a62767f17ae367627cc1456ba1da9a0f25ada040aa8b1d57bb6d  release/kernels/addrneg.log
16f5b0707ae44492a1efd67bb9dd38a7e79a7bbd354fa9207b9e7d150ff2f107  release/kernels/addrneg.oracle.jsonl
22f8b8aa9e6934036079bb242d36c40ff2528073cea700cfde443044c0088074  release/kernels/addrneg.sv-hosted.log
fe19653bc4ddc1fa2c26f44801f7dacc0f8ab5aa0b9e3a920e2fe7d4906c01a6  release/kernels/brs.by_instr.json
6bde77678511627e20368efb955c620ed9ca83948085f23317f084aabae4d118  release/kernels/brs.by_unit.json
fb42009b9b85e2df72523f63d9445cfe1aff4d6419f1853bc7ef3e4b390857ca  release/kernels/brs.ccvtrace
d097fe382b0ba82da1908140c0b55ddaeede836b91ae0724dcf3b4c32206b95f  release/kernels/brs.log
e3c1cb3379580cf1aae44e8ddc8e846ef6fd661a573cfe0a8d4444b18a14dc56  release/kernels/brs.oracle.jsonl
32490f033aa2004b5b9aa4bb05fd9310b30d930467181630ca1a4a55ec28a66e  release/kernels/brs.sv-hosted.log
a7a3d2b87cd1a240d861a1417ede80e86add45f826aa024b1f8a5d4bb7654452  release/kernels/byp.by_instr.json
4b25933bd025372aecee24dd98c00fcec0f97dddb16fa02f22fb6e83b3aa9464  release/kernels/byp.by_unit.json
6908390fdec89c45337be71b3ebd758945fbbca2eb83cc15a95fcf709acaed17  release/kernels/byp.ccvtrace
a0e74f464dbe2fa77a11dbf1edbdf2c60baabee12cf51f6c1dc5e69c2c3dfb26  release/kernels/byp.log
5a03dfa4f3603fef49f1e3639e74e34152ca3ca5ef8e41eb959f8323040fa2d5  release/kernels/byp.oracle.jsonl
1404d7c61f1e7690c8de4fd6cf713625d3d1c77e1ca8fb13ff8bc54186e85859  release/kernels/byp.sv-hosted.log
7da1c18971b9f8ff2a89f79b59436026e00e5e73edb7259ddf0cf932d3478484  release/kernels/chains.by_instr.json
a2c1c7fecd4850db0930fa158b5e3daef8235f638fd3c7ed775be93cecaff967  release/kernels/chains.by_unit.json
c3ea749bc8fe0c489c442e1f99347195af196006c9f3658e0ec5655bb62d6135  release/kernels/chains.ccvtrace
8064f799d49d8a30339c85734658c91ea3cf3ab68479d300e3377da2a9a192d6  release/kernels/chains.log
26a4cc5c5524c7219d8706c2582c80357dea60be9d6ffdec99dac7d0365e2264  release/kernels/chains.oracle.jsonl
95e12e7eb65ce01f26491a729b04b2642d0a47cbdc0e24f605335f7f1150c485  release/kernels/chains.sv-hosted.log
0851304fa6b8e9a1088173862bc9a87cda3ea4d1a4b404dccd973ae140076378  release/kernels/div.by_instr.json.gz
536046d5ca5c9d2fbfb4540ede74f86a6510e820ce4da937b6c33558761c2bf4  release/kernels/div.by_unit.json.gz
0e3d855a7fb35e3e3b5c5a831ef71db255133c70862239fa051f109187061b7a  release/kernels/div.ccvtrace
22944ed0742aa29fcc398935c48ab8a655a46de3c8905c7d61639a3e6af5fd03  release/kernels/div.log
71a567b85cf85622631490187563de9a5661099c78a590adff4ed0a0c3d24c16  release/kernels/div.oracle.jsonl
d731c12ca129a00fb91b3571dad20ea8b434146396024101311a1f4a757c9ea8  release/kernels/div.sv-hosted.log
ec54c8e27666b6eb14a4ded8a0b5c68d29626e041d47830508932606a6067d58  release/kernels/divtail.by_instr.json.gz
0a17b2326de565e7f5e6cdac62526cc7e8f0b4e4d4b5a87585618bda83eb1b48  release/kernels/divtail.by_unit.json.gz
05758e0539dd11cff70d95cc0d2034786405eba687bba1ebe445a010e6f7bb38  release/kernels/divtail.ccvtrace
c9119cb6c0a1a727f3217dcd9da4fbadcdd7dc879cac27ac49bff6de3c7613fe  release/kernels/divtail.log
75f11a75c9b3b336e446140af4579f05b46c363a76b7aab3ec88154a07ba097d  release/kernels/divtail.oracle.jsonl
5087c89fca40ddff8dec727db182d718e4a4e05e59494e921adf937385418621  release/kernels/divtail.sv-hosted.log
b9c5d48aedc00c20e452d81c539a113ac726dd066e405ad9cfafe505c04cf850  release/kernels/divtail2.by_instr.json.gz
da74509bcac903c7a804897439a48ddc8303182844a905c994b27563e529719b  release/kernels/divtail2.by_unit.json.gz
0dcbad605bafb9f4f1dd1b6dff736dd42a5e8bc907402d9c3b5b6aa6549fe883  release/kernels/divtail2.ccvtrace
03f90b63683581d820e6b0018e101e002bb9caf9d26c6c07c576ee5cbf1b69a5  release/kernels/divtail2.log
b2db6b05eb6cf4a0a7677e31d0c6c2952d5cab49d353f0bb1883fe0b2a20ed14  release/kernels/divtail2.oracle.jsonl
a35fb6bb501c96755a6137a8ed3b0e68a831ee996f7d486a5bc1336654c24508  release/kernels/divtail2.sv-hosted.log
ce61543a59a8145bd375e50c2f5abdac074afd7eb4e17a2fb66883556b437c4b  release/kernels/fence.by_instr.json
d098d6985b386080e2b4bf4fb5bae4593f20b92c5a6ed1f81bb4602888f4d978  release/kernels/fence.by_unit.json
bf3e337166d40bd281db328c002f04af93e1235c860be6683498c94d4162dba5  release/kernels/fence.ccvtrace
afe2bb76c332ad9dff80134528383cb990885cd57fbca2074f9825a62de3bb56  release/kernels/fence.log
d1d40317f6cf5bfb430cda1f9c0ef676609e59cabe2a11623c42ffbeca93142b  release/kernels/fence.oracle.jsonl
04b614b734db7ed69cea4c06ab45120343c4a1a45bb248fa4035e0cc9599e8dc  release/kernels/fence.sv-hosted.log
4563a83bdfa28d4ced36865f01005217f2ddd962f34d84701a55793414a1c978  release/kernels/gather.by_instr.json
2c50d05f47e718d68a0e1fe0864a721e2a4041c65055f5f64e85d2de88cb66e9  release/kernels/gather.by_unit.json
50e9d5199af07897f74281549a9203b520e1a0f155e35b68260e46ed50d8e878  release/kernels/gather.ccvtrace
dc37992dc26fb9bb214e7e08de4568b2dd09f08fa28160119829fbef91812ebd  release/kernels/gather.log
0413e781d8d6ff578c64eb1f800b7931e66f676d5cdabb97b94a4033e6037662  release/kernels/gather.oracle.jsonl
4b3d9a41b3f084d929d4056778cb8a1c986276af145f2b94547a5eecce8a5096  release/kernels/gather.sv-hosted.log
aab8bcdb7ff3c9630e51c6e55e56bb11f37b2b1c982b9a48388b8bdeed8047b1  release/kernels/hit.by_instr.json
6ac2bad8285a6286eb7e4777771036382f370820f5974db1f6632213eefb5ecb  release/kernels/hit.by_unit.json
56546987ec2f1496c4f7cd38c53d1dc419a0df50b4747966d4b4d76e04dd7547  release/kernels/hit.ccvtrace
8e17c37c5a0de79f4c87181f48ae9450ea6d04ba5a101e71e8c3562543265024  release/kernels/hit.log
7ba9603e0088d9164de6528f16ef6a7fa9ce5821c8c12b52cbb3734e39b9fd52  release/kernels/hit.oracle.jsonl
c7c2f8a641bfea0d55e771454d0a42091b5736a18a28ad2490eb350fed340916  release/kernels/hit.sv-hosted.log
6d80166e9edb5caa785a1239bcfd6bc33bf614c87b0e586cf25081e347e6ee79  release/kernels/lanectx.by_instr.json
5420758a1836147a0a7c92f9b8a3b9ed3009bc9993cd5624b5fe435427683cc6  release/kernels/lanectx.by_unit.json
562179d008d4b4a511fcd55ea4a194db35ed97869d5f2d76851cb1d3184efb15  release/kernels/lanectx.ccvtrace
1d8b33279814c5761d2423e63545735aadf052b52644dd8ed9dcacf5d626cbce  release/kernels/lanectx.log
888551babf540db8e3025b82e65ca655013f93eba3c8a65689d069d52a7e6039  release/kernels/lanectx.oracle.jsonl
2353886868f2d1c3feecec0e43e85469e6a2e540f707feb110347d4f1c516380  release/kernels/lanectx.sv-hosted.log
e26cd0686ef472396b62c4aed9220fd659112d7d0ac72afbeb9094789c79d855  release/kernels/lanectx2.by_instr.json
1e0c0885eb302cb564a65adeb1d1b3c9205332a1b39653f056653034261167da  release/kernels/lanectx2.by_unit.json
0cc65d38651fca5db3224d51f16aa6cef8bf9cd78dd784efdc868cd8032c3a0e  release/kernels/lanectx2.ccvtrace
49705188f4531effb97662c664533537cf487dcddcfbdab2e76922c6a34e8e12  release/kernels/lanectx2.log
45c13056dff5c73ed0c9ece56cc36f929bf335322193c7d5eb38710b1d1dfb02  release/kernels/lanectx2.oracle.jsonl
65b4439072047d4d4897df47c06ac49da80a92751565c179be94fc56ce3aedb9  release/kernels/lanectx2.sv-hosted.log
f706ce3c16d74211f8c253cc48377c4d12b87be4296910a3b3235cf2b1371f20  release/kernels/late.by_instr.json
2090a40a5bafbca35cb35e0728554ffee18311d7d5b9ff85c278d31d4c0020ea  release/kernels/late.by_unit.json
e3bc54bf1012703f13ba6ac4ab0ea32f94878403a23d0d222c292de893c11e95  release/kernels/late.ccvtrace
7551d1eb62a3a1902937c8bc0a36c641f6f350d03f1642c1f1768023578a0822  release/kernels/late.log
86084f6bd747a2cf32acbc0ebd96ebd3e4ef2d8d9e21be49e3ae49290d7927f3  release/kernels/late.oracle.jsonl
438a736fc7984b197db1159a4e814b92285b086001bfa66660df8ff8e7ace750  release/kernels/late.sv-hosted.log
69216d01c2f7a133e7a2ff83615168cd7884c0ec0c058c9a3dc23a62ef28f8d1  release/kernels/ldpar.by_instr.json
48bbb3019256e11d9cf3ec47c43afc40ad3fd38b26b5008ef2d9a283ac22a31f  release/kernels/ldpar.by_unit.json
f8910cc30261260a9736eb87a3620426e4a27d540e949a39c8f00bec84254a1b  release/kernels/ldpar.ccvtrace
69ff69b0503c6b2e3e53752a34ad35421aa16ce69b3f6000cec3f7408e2f6c83  release/kernels/ldpar.log
8ac08538e9c807637babd61b31e340f7461878ada31f0c0b83cd66331cfaf486  release/kernels/ldpar.oracle.jsonl
f0411306ee784c5fabd38f5ec3685351588c967d227f84b8fccecf343fbc1aa1  release/kernels/ldpar.sv-hosted.log
459e9738b7a9124bdb9f13b0d5c15e6430c2fdb51852155199767b24e17b9101  release/kernels/localsp.by_instr.json
a55652cb9ca50701b0a5a490ff6443df0447707086b691f5ca916f9613501a74  release/kernels/localsp.by_unit.json
409767cd058f24483376b26256cd8e33ce368e12efdf2abd235bfff05f943dce  release/kernels/localsp.ccvtrace
17066d9b49a21ad16a6b8ae1a713881bc4e76922fb5a1b3c625f0bf389681746  release/kernels/localsp.log
55e3c9f36e7f7d38c0ddd38903aff4bb4509ae862015c592e6b937ea258042ca  release/kernels/localsp.oracle.jsonl
8e8714a8fd83f5faee4ca13790cbf6eca108b69ad497cf169f27deeed324ec80  release/kernels/localsp.sv-hosted.log
20f3cbca75914f5a006d0320fdae32a58689d0c8b4bf0e0d902c2b46cb6fe842  release/kernels/loop.by_instr.json.gz
99c36c8e11ce27925b53b9664883218cc7687574943e30f4cfbc459eabef6d0b  release/kernels/loop.by_unit.json.gz
1f14fd7fb0c254ff64ad658a7c8853130942f1bf2b90475f3b2ed967a7e48780  release/kernels/loop.ccvtrace
ffc81ce3b9792e8097f92f72749b282d5e3eae588e7618bc5c2251711ace59fe  release/kernels/loop.log
03ce5920c06c93e93516d8e53c3f7169f14e3593de204eacceffc0b8a3e32016  release/kernels/loop.oracle.jsonl
68792b5fb3d21e8acfe7446dc6bd0403bb7ac4b300758705d28d662c5a04fdeb  release/kernels/loop.sv-hosted.log
7695e79b26c7643454bd11eb90cf58ea26e52b0c8247fb562030216c34ac124c  release/kernels/merge.by_instr.json
bcd11367912b59e58aaf4373e36a38f21de6b910310eac5b05e7822d67bdec80  release/kernels/merge.by_unit.json
8b648dcbc53ceced5ebbe17909d511a46af125536e12fc23e08d662ba912e961  release/kernels/merge.ccvtrace
7ee948779326da91f1930ef449ff2dd6d11b2e68876bcc6721994a36de75bb91  release/kernels/merge.log
f96d28815f8756b1f5a45ded53e6170883d2dfa10f9eef0d14b8050b1318164a  release/kernels/merge.oracle.jsonl
8c4351787672bcf396555420ae92c988c1152b836f327470ac77e4009a4dfd4c  release/kernels/merge.sv-hosted.log
ea9abd61e11c5ed36fc1bfc1e5b7e1f53fb32f19aa57def9cc0cd9d75e883521  release/kernels/missrun.by_instr.json
df80f6625854f5a80aefeeaa733dedf47b5203d1882a6b858070dd2cda258072  release/kernels/missrun.by_unit.json
0325f4041b83df391d334d1cc4faf665e569a9792968c99a2c6ca957fb3a1faa  release/kernels/missrun.ccvtrace
5e69ad919a8d1f96953817415a115354dbeeebc0192ff3ad76d5c16eebacb35f  release/kernels/missrun.log
531bdaf281e5590774bd2775427f25e4cc0419cf8e3d5b6999843ffe9ef87258  release/kernels/missrun.oracle.jsonl
3305c47bd89783dbbe0ae69a90771d430ec919d2e2c7b61ac617f328b30aa99e  release/kernels/missrun.sv-hosted.log
642f8277f67ae10aa03c00b3b323944a9edee676e56f3c09c30200ee6dfd8ac3  release/kernels/mload.by_instr.json
77307a450638bd26f3a9c9e82d098c1fd1a48195594dd3c6c113ac7a9adfc294  release/kernels/mload.by_unit.json
6768426392dc3f36bb334dced65c2d5b9be0fff7951518afb0196e2549b87404  release/kernels/mload.ccvtrace
06b5d3cbf9b25cf9a9e42feb1377346d679b7fada431ab1187d0b0a923615e51  release/kernels/mload.log
8000e477b9a95dfb9f0af964e8346acb9d36f1358fd06ffc4ff7cf599d2b8868  release/kernels/mload.oracle.jsonl
7fe8a5a2b773be00f3178e12997fed881802043fa92b211a6ae00d3235621415  release/kernels/mload.sv-hosted.log
e647616c52dd363b2fd8f9f0b18ca827015ff4795f3d2cc4eba33e4a09b71f2f  release/kernels/mlp.by_instr.json
00154913a45b7f402b08ab8da8fec4e3f8bc5164a2de41034c2f928f09b4a3b9  release/kernels/mlp.by_unit.json
bfe7d7b8d74638e5ac9d8a1223c5faacf805e581f44329d24c2bc981e58ca93b  release/kernels/mlp.ccvtrace
707552b037d04e4b87c25f23644515f73292d7a160e4fedc066993bf2792e01f  release/kernels/mlp.log
138d282f88d56c8ad648a91af0a983254b55d9fa22942c00d47b327f516a6e44  release/kernels/mlp.oracle.jsonl
26b722be0d2280fb2c280d1bc0e6a0355c2fc34d09a3712aba8c6d498de4fb22  release/kernels/mlp.sv-hosted.log
e3d7ebe85a32eeff4a3fc528aee6987bb42510b8fdf924ef277eeffd01b26d48  release/kernels/mwmiss.by_instr.json.gz
f2368dcec9cd4495a856bdb1c9ff6bb3e86e0e99c94b2e1610cd0b9cf739181a  release/kernels/mwmiss.by_unit.json.gz
78a517089229d5100b786a37309e36e21b1bb24fddefd56e665cc994bcea03f4  release/kernels/mwmiss.ccvtrace
0a71010e17a9cbec8cd080640628d9ece75481f6ad9d4ffff07b1639f019381e  release/kernels/mwmiss.log
8abe8e8997456a2a6711ee72da54d854b24e20abbdab28e4b7271c0d28418de8  release/kernels/mwmiss.oracle.jsonl
b7645a64074ad71d817b4a5ceaa75ab6baacbdc67ea4fbcdea05435cd5942a06  release/kernels/mwmiss.sv-hosted.log
afe2c2e72c940609c91b8c2b9a0561589463c7e22b5f56b23f922ba56adc5449  release/kernels/pguard.by_instr.json
9bcc7a10c07327acd06b118f6f4ae6da34d5b0e12b321e42194c9ffdade7349c  release/kernels/pguard.by_unit.json
46f841c8cff7749a9ef67543c8013547a6f1ecc62bb94ce209fc92f18036eafc  release/kernels/pguard.ccvtrace
a4907e84e98ec16ac9c45e51598be3f2fe10e3aa7a24829c4be2ff19c4ebab28  release/kernels/pguard.log
690e56f1cb8d97cbf67124b7dff3ad0a90cb8981814cd1709cf0cd0e035b3bd9  release/kernels/pguard.oracle.jsonl
9e829cbceacfd8c2e601a966ae02696c83f3196cfb343925d20894f31f4b7502  release/kernels/pguard.sv-hosted.log
44a30ae97d33250fb7e0c469a55f2a9b4868b20d4503f4c484ebb148237de1c5  release/kernels/plog.by_instr.json
8aaa681d0ef8222d6fdced764adcee40e341a5d1333e36979cdaaafaf88855c3  release/kernels/plog.by_unit.json
d6238864e0273ef60610795fdbefcc20593f320ede9028322a37180f9f61025a  release/kernels/plog.ccvtrace
9fd7e01e65a7644cb3362a35cb42ed8beed930501388f8b0ca64e3fe2f484e53  release/kernels/plog.log
c230f13f2e1082b306a9c5ab7809ff36cf5c1b2e47dca6b7a71f741524d403f5  release/kernels/plog.oracle.jsonl
5f8fd253eb44c8b98b66050cc9f6ff4cb899d71369a731414c6e379ebd842258  release/kernels/plog.sv-hosted.log
eaf63d00c57033519613a8117d065f259b2be59ddf2bf6052dd25315d11cda16  release/kernels/predlane.by_instr.json
b64055d7faec58b32fdab070c3fe29335f3b5f28b7e0ef465a34127e10130288  release/kernels/predlane.by_unit.json
7d85861ae70977be261e250045781f870da18bf258c0c9d9eddb213330efe370  release/kernels/predlane.ccvtrace
ceccf3f191c43204fc3cf1d589e25ca86f2ee9a8a64192d647c4af180b0b16b8  release/kernels/predlane.log
c45f4177b9e84fc8a6e36b13534a0c7636eb30a3f8531847100ce5e23bf404b1  release/kernels/predlane.oracle.jsonl
74c995ccada1f72787f8ffd1618e5a4bc760585552bbe91b0be540e2ae87057e  release/kernels/predlane.sv-hosted.log
af6a93d7e99656835491c44fc9f7d054fd95485226b8cc522af790c1a223be67  release/kernels/predmerge.by_instr.json
eed9a655978bbbfd0ca7162813e8c28f28b00b6a73c02dde8eb0e1dd91747f6a  release/kernels/predmerge.by_unit.json
f3cd4cdbcf05011f053212a4c11689578e06248909fb459f62722de54ea2a37a  release/kernels/predmerge.ccvtrace
2094ebce0d6ccd1dbd131b32dd924d98926762df9f99334ae09fdacedba5a68e  release/kernels/predmerge.log
6c737c49434bcd08e3e0814c8b1dbf15c586ae74f7929ba3148ddcee2c62c845  release/kernels/predmerge.oracle.jsonl
18a8c8b494e055fa68daf43a64ee45c8c73e0ed1ad29c8583b312dd49d3ab423  release/kernels/predmerge.sv-hosted.log
480a36c3c95f8b70c92145815b09480a885bea0adc7864a293a48c1ed96fd9e1  release/kernels/predspill.by_instr.json
2bbb7603e0a3b3c34b06c875bf2bc152a1a809a0cfa9398bacea0d4986380b97  release/kernels/predspill.by_unit.json
9497543c5ebb19f944de33a1e835118f003de4d93802bf5a04746e99c6cf7b99  release/kernels/predspill.ccvtrace
46e9f72b1ca07937de428b940bc3b80f49d5d805566991580ff08cf5997055cc  release/kernels/predspill.log
b7c84c6478117ffa0f06da0e6ad1e4628e2683426a7911080810e78e06a5242e  release/kernels/predspill.oracle.jsonl
aa7befc796ba65e2d6bcf523179db3506c5b46bdfd3de9c180a96877bd115e5a  release/kernels/predspill.sv-hosted.log
fdd14c989823581dd978d4d6d43530e86518b42dc5c18ecca3f8fd7fa303c33d  release/kernels/predswap.by_instr.json
8fc305cf4da741e2080f253893754884e046b95cf91b7123064ffbd3b25172ca  release/kernels/predswap.by_unit.json
48c93b63d0bdfdb7213f35dfd54633e175fefd59a3f4ae88bcb0b3560ab78776  release/kernels/predswap.ccvtrace
23ecca2e66a41f0d779413bfd21fee94a4c89f8680bdaf631d58dc77672b0d07  release/kernels/predswap.log
a6d4f7ed517553816d889c7c9eeb6bcfd1f6c973fbf682ecb69f3c2de619f7bb  release/kernels/predswap.oracle.jsonl
081e76af3a9505494f30344bcc07eb08bac81bbc32b3ad7545b303c7c1ffc402  release/kernels/predswap.sv-hosted.log
a9bfe5b0fd103e86ee547a224cdfc8a41aa2ce8525357de8154b5fbef2984599  release/kernels/provswap.by_instr.json.gz
a64f65641136865d25bcd0855789c096edb0097abe5ba60bef3f269f6f78f118  release/kernels/provswap.by_unit.json.gz
4891e58ef27cba6537652224844642b8145a0b3ff6496ba929b4aca41b360bed  release/kernels/provswap.ccvtrace
003fdf1713685a408ad39f16aba2fc5978461c57a39015325f69bc78be478121  release/kernels/provswap.log
c9c32a793d54cc7401477f582487f7e8b345b2669a75337b8d6327120d98e5dc  release/kernels/provswap.oracle.jsonl
fbbbce9301f906f82b6f67daa38ecc0df6b95380b79c3bb41293d76f0ed75883  release/kernels/provswap.sv-hosted.log
0abee8ba02e94d25203dd1bbc6611c55c65071b468c4bb6d6c1ef600dd1479a2  release/kernels/roconst.by_instr.json
17965a859b81318f739deb4fdaf72403876875c6817e1fa31370cf333b28c3da  release/kernels/roconst.by_unit.json
c3a5aa50b5a4bd942d9cb331ae09919b3538febecdec92ec7929b95b684e4e67  release/kernels/roconst.ccvtrace
7dfb6a8240bade2ef19c976da8064326abd376c895fadbe274a885c37a4c2eb5  release/kernels/roconst.log
8087c0671de620162881aecd38cd6114b78e7be6bd71201e3ec02c9a2e2e750e  release/kernels/roconst.oracle.jsonl
5c28e7b8299e68f641c88dcdff662760cbcd6e4c7b59893d96e0d725bd080d22  release/kernels/roconst.sv-hosted.log
62609acb9c7dca04d571291ca5877a0150a713e195452d39e65d63ba5cca323a  release/kernels/rogated.by_instr.json
07cd870c0f21f6bc9f1a90aafbcf57d12d60a5a0b7c719a584ca8465272e6356  release/kernels/rogated.by_unit.json
a0bebe5fb26e902ed4e6987990946999dcb97933348abaa78a06759f5a2c9e59  release/kernels/rogated.ccvtrace
4fced9f6967b583526eb5813c442e45df3cc889cd48b40fc2f2fb0c6ce58a036  release/kernels/rogated.log
7cd02bd4cceec5a044d6b4d6a80df1e68ed0ae71b0b2a953143636d5b809ea6c  release/kernels/rogated.oracle.jsonl
158178b56099e1a36663ea7b8ebb516cfcf8da6ea55358b5a8e32f7ad15dcd76  release/kernels/rogated.sv-hosted.log
49d939eaa4635de1842045bc0dee6fbce1e13de29c3d739ab3b48d03702cd489  release/kernels/rokill.by_instr.json
018d919e124c0ea7252a15ba69ee6d76d2e31331c537fa0ee0c375f611a7bc8e  release/kernels/rokill.by_unit.json
978cf2c92fc50ad79472abcc60ca43ff3a36999169254e7bef8fc02e3f671c25  release/kernels/rokill.ccvtrace
fca340509a21445af72dd1a978c0fc2106fe24d5edcaa219c2f53ba20914faef  release/kernels/rokill.log
94efcef96af469a512d346ce61623980fe86383188eaebd55120f716db596f14  release/kernels/rokill.oracle.jsonl
f431ca40c36db6486e4a4e406366115b91e57f494e27309dd64fbf2e7b2a0d1f  release/kernels/rokill.sv-hosted.log
fdc711d88326a1b1000445f46796eb6f29edb64db30605fe661ec88f2c56d918  release/kernels/rolaunch.by_instr.json
1da82c40a535127d7b4fc1c95d29280c1946fbe5892326b86cd989c86a8010d1  release/kernels/rolaunch.by_unit.json
08efe5da32f0d460a6d36b60a6ce380b6615e2b7f21b7327cf52e07e2bdbf6c7  release/kernels/rolaunch.ccvtrace
ff64130b2f508255193d427e2c353d3e213ad8e981cb797d6edca4d8cdb05f68  release/kernels/rolaunch.log
e7dad585c3e70615de04330fd03f4f282c29a005dc1732a35655fb261d51139e  release/kernels/rolaunch.oracle.jsonl
f23bc6677439d04a93dedb541f4e10694da2ae20759692f674aa438a444520dd  release/kernels/rolaunch.sv-hosted.log
0abee8ba02e94d25203dd1bbc6611c55c65071b468c4bb6d6c1ef600dd1479a2  release/kernels/rolimit.by_instr.json
74d24d2c752af3bca5173ae2e4111b7f12c15f55d0554c915c94969f66533e41  release/kernels/rolimit.by_unit.json
7ce7b0690978e5ed2aa4388466d2e54b17446b7b8a2a022f85b7748323865fac  release/kernels/rolimit.ccvtrace
d5d61caf745001ff8acda58012caf744ad47b3cfaa67e7f78735ba1d6868b84d  release/kernels/rolimit.log
1c5bc0cb8e8b2e69505fb5a551a16d5d10c56f232b88da7a27e336ad7d962de2  release/kernels/rolimit.oracle.jsonl
147de7f38d4bd6c021338d9cc9659757a1072c7091ca5315f7235be96ea9ccdb  release/kernels/rolimit.sv-hosted.log
0101c51d43d34fd7351dc76ef0e3d126078d66a5f2e07aa9f32aca63e95e617e  release/kernels/roload.by_instr.json
9be97a5066adcb6e9241d6de023f7be2a03192307e7172d86a0df8a1d966e41e  release/kernels/roload.by_unit.json
d15f1c17cb72af46c0cd9586823679fe5f86e9a4cc7a8f4e384643ee5b0fae91  release/kernels/roload.ccvtrace
7fa3c63a14d42a1d7a4b5808cfc0897e1de3f8da090df45186dd74a73a7caa4e  release/kernels/roload.log
f7c1309cc9764769fb5803f6fd0f2f5e1eb418f2d23fbe5e17cf5f9106869fdf  release/kernels/roload.oracle.jsonl
4aca647c1e99d48e17efcc993ab98471f6345dc2c35278abdc0693393141175d  release/kernels/roload.sv-hosted.log
36e5a71807670e355fb2030c062151a5f14f232da0ccd46ebaa75b8747d11810  release/kernels/rope.by_instr.json.gz
2c8498230a3fe8bc36c340491be122873acb1efb3b588c20602dc7cd64773ae2  release/kernels/rope.by_unit.json.gz
b6ddb4104d2dc3df7afe4c84ec92fb506b455dc7b73e1d04704c7130a9beb912  release/kernels/rope.ccvtrace
f00fd3ac3fe4d6a1319e5995a03ba10618da6543411085ab9979dd2901d3e282  release/kernels/rope.log
d55f9efae392dc8877c102c01c0810e7654b666b6ede386328108164c6cf88f3  release/kernels/rope.oracle.jsonl
77cf3def18c3e7c0ff8b7d8a712810786c2780e3644374b04f824c523a62c937  release/kernels/rope.sv-hosted.log
0e29bcebe6babb49cf42750e488ec7013b41001fad876f109153cc855d16c56b  release/kernels/ropediv.by_instr.json.gz
6296e2add0a2264637f5f4d2ae95f8480a389b7c2d292c538f06bea5253620b1  release/kernels/ropediv.by_unit.json.gz
5a23195ea3814131fbddcb67ec4df1a06a60c0017ed914186bdbe3cf742da040  release/kernels/ropediv.ccvtrace
4ca3943667f54f89a1f62bdac48bb1f6ec1d2c0035f123face3e0fa4d794244b  release/kernels/ropediv.log
10c0ec6ec18b7b44638c790033109198c079d07c1537bf193353ccedd00a920f  release/kernels/ropediv.oracle.jsonl
1a1164eadca884a35c14600528d8a9a6619e41ff246c5d92185f380e0c302bc1  release/kernels/ropediv.sv-hosted.log
74a26fc296ac2e3e9e413331993799e0517b830b187685e54696ae4af3536d3f  release/kernels/sel.by_instr.json
e2409925f9a19a07cf2a97118ebd04228a84de97ca58a85a385f50394f201f23  release/kernels/sel.by_unit.json
b0212ca8efa50901ec7eb6dc527851d792a7c185171d96ad34fd3de38585a0c0  release/kernels/sel.ccvtrace
6a3e22fcc8622ce46f00b7cefecd56bd3252e3cf3430611eb9f2bcf4065add21  release/kernels/sel.log
87f6a81e8afa004c8039bf2f61c90176fcf29ab29bb17ac44aa016a5cc8438fe  release/kernels/sel.oracle.jsonl
c933eaf57a292f9c6ba4d1d01ce5d45f1359005cbca7295b0971f0c50f8078dd  release/kernels/sel.sv-hosted.log
5540ad2f05cb1759cb2fd1433fd68754017d9d9ded1a66a13207ee416f0265ff  release/kernels/slotform.by_instr.json
2c32ef4201bbe625152c6595d355399cbd415401948d0c05e8c08caf6f460929  release/kernels/slotform.by_unit.json
8d107923a467f89de254481c34a896ba99b9d1ea40306c019d6480651a0c4b65  release/kernels/slotform.ccvtrace
12d24687d7c32a9c0985feaff4ab5d5e976c73fb47d58588a573679a272b2e36  release/kernels/slotform.log
8b61db7419b18cea8a646fb628218447e72e84a18a9891ffb73b441736138ab9  release/kernels/slotform.oracle.jsonl
6e7e7b0908b9ea74f9e067238856f39729e308f88a0761810b07af040abaa547  release/kernels/slotform.sv-hosted.log
0e280ad407e2ac956e5e6e0a668ec855a40c61442e6ee2fb4a7581a3922dcf9f  release/kernels/spinwait.by_instr.json.gz
2a34bebc22da5de8d56e4d704eafe4ba238c8d564336b64866834c7ad539bc1c  release/kernels/spinwait.by_unit.json.gz
02df2d056adab949a5f28be093e834d66488ef8be369b66d9986a98ed9e7a0e7  release/kernels/spinwait.ccvtrace
104496d3f3b42d11342698b969a375a2a44b983c5bca40921d11bdf8bab33df0  release/kernels/spinwait.log
868920637236c878b33779bd450439466fc3626996a3164573dc11d437d5c709  release/kernels/spinwait.oracle.jsonl
b9f2d0498f8ca3b54f0fd396e6fb9a7a1f3beb6d531b4c9470e0324142d47625  release/kernels/spinwait.sv-hosted.log
01c0539dbd211c3e004736ff09d036a40fe064235e645a4c199ba4746aefe015  release/kernels/srd.by_instr.json
ca244bd14fec2f0d8a3aafd4d8767d04689c5c1641fb0461f6fa4e1e7cb7b3f6  release/kernels/srd.by_unit.json
16e2271ca75064c029afc8d2a136585c83390ab3355bde9e41417749d55589e2  release/kernels/srd.ccvtrace
7c5654fe9141bdd27be0aaf2f6779b92f77520115d983bd264c2cffb71fa0cf7  release/kernels/srd.log
b08eb5e3673cac7eebb8b72af5ed3783c8e70a9e96592e76bf3722551bc79473  release/kernels/srd.oracle.jsonl
1c8d7e76a6651b0a7b7796c97b9146b37db976678c7e07715934e7bc401deb36  release/kernels/srd.sv-hosted.log
c0cedc9fb36a49956a74d155f472faca4e48f63fa9eab9cd2e3f97c4f1365129  release/kernels/stall.by_instr.json.gz
e5d68a35b9ed727e525ad8a85e250ec70a3a3d3e030862fe40ea6c5d115bf4e9  release/kernels/stall.by_unit.json.gz
b7e16257e992a8f46a75c4a71277b2b5041e8e5be4338aa81e92d711ac1ba1a8  release/kernels/stall.ccvtrace
1dfe7ea04c087966e3d05271ed790af239e117bbb5d8202561d0bea5193bd80a  release/kernels/stall.log
500db2c482b07a0706583422cd68878301d0146c1f872ccc1f11bfdcf5c993ef  release/kernels/stall.oracle.jsonl
11dab093cc53437eeba04afd5059213631eaa1f9980beb63e9202f6438e899cf  release/kernels/stall.sv-hosted.log
d43719483ec339b505d3b99ee09f9f8a3788a57fdcdb7581fd5c5c4fdc6f14c3  release/kernels/swap.by_instr.json.gz
6f8d21becffe43e1c818ab5f8f25b8a2b763ce369b573a4064be8a24586a0d66  release/kernels/swap.by_unit.json.gz
0c75978f14b3c8e6ecd1de4c37165b489b5f7e506dc712b4415c26af4e11944c  release/kernels/swap.ccvtrace
7b9becdab408d77518f2e76b65a1a04a7227c8b2baa3eb47763090e4286634b8  release/kernels/swap.log
3658a26316c1ff7bc1744304a42f736e930fcde2865c8913e6cc67a22ce96667  release/kernels/swap.oracle.jsonl
06f8c622ea291f0e6b3fd0d784ddb791777d70b69140546a94f3205ae3c08fda  release/kernels/swap.sv-hosted.log
bcd5de7a6dacd47e738a6391c0cd525bf945a8cd39819976a713a2fd61c35870  release/kernels/unal.by_instr.json
a2dc8be622206a4809db273cb2c04742980044d4454918566451b54ce988e04e  release/kernels/unal.by_unit.json
2bb24c1f36428a5ed977bfa618185497b7ec36a650af3a8215d602ab1d1aa71f  release/kernels/unal.ccvtrace
bc649d58e0c77c53b585f7c70438a985e0a92a5a5e941ab8b8ad7dcff3b4322e  release/kernels/unal.log
c3d484bb160657a563df983d9a2532eac27f556636617960aa1e72183ac2b299  release/kernels/unal.oracle.jsonl
61c821fd82010db599a741612f27d6b3c6a970a4e13d48c026ff35e93997262c  release/kernels/unal.sv-hosted.log
24372d75f356062fbeb4096931469258551f176a33c25b276bcfd96ae3b2b3d0  release/kernels/vadd.by_instr.json
bbf5c85ba697da9a4b209a6a4987692b3c7956398bd5c5af5be313a877c970ef  release/kernels/vadd.by_unit.json
5a18e2292f75344bb6fb21064a23b6238a7d706b2fa522eb07155424147bc730  release/kernels/vadd.ccvtrace
63e96fd9d9b832965b302aa5f32d5aa3cd0aa77f1357fc5e26010c24895bd372  release/kernels/vadd.log
0276b6d0611a4bbcdc004ab3987214aea138245bc7217504147331689a9c0880  release/kernels/vadd.oracle.jsonl
1034ee35c17b4e1d05729a300513223c87ab65c5edd01e1a6a4c131e0860d1b2  release/kernels/vadd.sv-hosted.log
ab619733ce66c4d63b707883b46b2f0ef44de216d5ebca29053bba8eee7bbfaa  release/kernels/vadd4.by_instr.json
4f98859e256e2ed4e7627d15ea51248708469164719dc6ba99f420cff43b78b2  release/kernels/vadd4.by_unit.json
28621a54af3162e415c7b08ae6e631f7bf2a862a2617d87af89535fff0385db3  release/kernels/vadd4.ccvtrace
042de92db23097fd5f3ae51f5ba326774fcf5e7160164d2e854e0d65dba893f9  release/kernels/vadd4.log
225aa18fc9f38aa9ad615aa11de254337d59fa705877553d873062c68366e0db  release/kernels/vadd4.oracle.jsonl
ca0f3e27fd0a86a0e8a68696a8235bdd588a0a4746493944a14f28f1abc55bb3  release/kernels/vadd4.sv-hosted.log
c7df0f2070f9aeb4aae238b104cd01941549ec5ff93bbf3d6cbad024f48b8ad5  release/kernels/vaddslow.by_instr.json
3ea8b10f96dc2d6b4e440abee7af1172b06bfc0668c44313e8aba478cae3a417  release/kernels/vaddslow.by_unit.json
b9091ec8d54928d3de24ade1562574c4167c4a6a7c738dd53676dcf35a31e84e  release/kernels/vaddslow.ccvtrace
4c958f72b79c53a608b3ff93d0af34d4954b6e8570fba09f9fc9ab79da5c1399  release/kernels/vaddslow.log
e9e6218e8b8450e9f9ff6b39d659c994a1e51c527a0c5bd10d18b5658ae0e344  release/kernels/vaddslow.oracle.jsonl
918376a19572725c96ed122ac9265df441f04e37e3353534109a5b11bd907008  release/kernels/vaddslow.sv-hosted.log
f33aa1028fa9a16241fbc9a413df77cc7b1a2d5779680bd3eaa670b4ac62f7f0  release/verify.log
5b64efcaa59f79d1195d81bf2258b07471e763766cb6e0afab614c072ac3aa09  release/wiring.txt
```
