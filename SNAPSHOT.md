# Snapshot snapshot-2026-10-16-d4021fc

**A generated, read-only snapshot. Do not edit or merge it.** The source
is `claude/custom-cuda-core-infra-6msg93` at `d4021fc48e06b773662cc2d70ffb937a792dd8cb`, and this branch is rebuilt from source by
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
| Source | `claude/custom-cuda-core-infra-6msg93` @ `d4021fc48e06b773662cc2d70ffb937a792dd8cb` |
| Built | 2026-10-16 (UTC) |
| Gate | `tools/verify.sh`: PASS |
| Compiler snapshot | custom-cuda-complier `release` @ `41e32c55e11a7c85e5f0234689dc76cdd5e41283` (source `e74eea711a49e6ba071de87ba6fc743b5e7edf4a`) |
| Verilator | Verilator 5.020 2024-01-01 rev (Debian 5.020-1) |
| Icarus | Icarus Verilog version 12.0 (stable) () |
| Yosys | Yosys 0.33 (git sha1 2584903a060) |

## Kernels

| Kernel | Result |
|---|---|
| `brs` | `name=brs finished=1 cycles=92 retired=12 issue_groups=12 order=ok gpr_mismatch=0 pred_mismatch=0 mem_mismatch=0 check_failures=0 class_violations=0 overflows=0 credit_leaks=0 channels_used=19/48 violations=0` |
| `byp` | `name=byp finished=1 cycles=103 retired=14 issue_groups=14 order=ok gpr_mismatch=0 pred_mismatch=0 mem_mismatch=0 check_failures=0 class_violations=0 overflows=0 credit_leaks=0 channels_used=25/48 violations=0` |
| `gather` | `name=gather finished=1 cycles=2302 retired=16 issue_groups=16 order=ok gpr_mismatch=0 pred_mismatch=0 mem_mismatch=0 check_failures=0 class_violations=0 overflows=0 credit_leaks=0 channels_used=26/48 violations=0` |
| `hit` | `name=hit finished=1 cycles=209 retired=17 issue_groups=17 order=ok gpr_mismatch=0 pred_mismatch=0 mem_mismatch=0 check_failures=0 class_violations=0 overflows=0 credit_leaks=0 channels_used=25/48 violations=0` |
| `loop` | `name=loop finished=1 cycles=2736 retired=407 issue_groups=407 order=ok gpr_mismatch=0 pred_mismatch=0 mem_mismatch=0 check_failures=0 class_violations=0 overflows=0 credit_leaks=0 channels_used=19/48 violations=0` |
| `merge` | `name=merge finished=1 cycles=66 retired=9 issue_groups=9 order=ok gpr_mismatch=0 pred_mismatch=0 mem_mismatch=0 check_failures=0 class_violations=0 overflows=0 credit_leaks=0 channels_used=17/48 violations=0` |
| `mload` | `name=mload finished=1 cycles=99 retired=11 issue_groups=11 order=ok gpr_mismatch=0 pred_mismatch=0 mem_mismatch=0 check_failures=0 class_violations=0 overflows=0 credit_leaks=0 channels_used=25/48 violations=0` |
| `pguard` | `name=pguard finished=1 cycles=125 retired=12 issue_groups=12 order=ok gpr_mismatch=0 pred_mismatch=0 mem_mismatch=0 check_failures=0 class_violations=0 overflows=0 credit_leaks=0 channels_used=25/48 violations=0` |
| `plog` | `name=plog finished=1 cycles=65 retired=10 issue_groups=10 order=ok gpr_mismatch=0 pred_mismatch=0 mem_mismatch=0 check_failures=0 class_violations=0 overflows=0 credit_leaks=0 channels_used=17/48 violations=0` |
| `sel` | `name=sel finished=1 cycles=117 retired=8 issue_groups=8 order=ok gpr_mismatch=0 pred_mismatch=0 mem_mismatch=0 check_failures=0 class_violations=0 overflows=0 credit_leaks=0 channels_used=25/48 violations=0` |
| `srd` | `name=srd finished=1 cycles=110 retired=6 issue_groups=6 order=ok gpr_mismatch=0 pred_mismatch=0 mem_mismatch=0 check_failures=0 class_violations=0 overflows=0 credit_leaks=0 channels_used=25/48 violations=0` |
| `unal` | `name=unal finished=1 cycles=222 retired=9 issue_groups=9 order=ok gpr_mismatch=0 pred_mismatch=0 mem_mismatch=0 check_failures=0 class_violations=0 overflows=0 credit_leaks=0 channels_used=26/48 violations=0` |
| `vadd` | `name=vadd finished=1 cycles=222 retired=17 issue_groups=17 order=ok gpr_mismatch=0 pred_mismatch=0 mem_mismatch=0 check_failures=0 class_violations=0 overflows=0 credit_leaks=0 channels_used=27/48 violations=0` |

## Manifest of release/

```
0f49cfe9dfd3730096b7dc3dbd4b78b227636c1ccd3f1f7464c3a13f75cd732b  release/kernels/brs.by_instr.json
2525dc479de85bea7f10e8a9a76267d2a5c3819514235fc01d5f5ab7253b4600  release/kernels/brs.by_unit.json
8e887f87823102205cb9b15c70d477a39889213d1363f2ce5c8d669dda65bf24  release/kernels/brs.ccvtrace
d08c4bc73cf46064de87ae9189057ca64e3b8de7bf1ec3e15d6096c3a9a64aa2  release/kernels/brs.log
e3c1cb3379580cf1aae44e8ddc8e846ef6fd661a573cfe0a8d4444b18a14dc56  release/kernels/brs.oracle.jsonl
6bf6fe0f38521aaa958e128a7490cd413fa7fd7b35987a59561200d0d705b55d  release/kernels/brs.sv-hosted.log
b040540050f2751027cce2f0ab73921fb090ddda340b3e13e5242b078a19a659  release/kernels/byp.by_instr.json
f6ebccce15a72486bb03379eb6e0cc5d0563021e12c536291a33bcd30f21aa44  release/kernels/byp.by_unit.json
3ae19567bf95ef6895522bde9405cbcd32633853b18f0b88c1185a0f4f59ca68  release/kernels/byp.ccvtrace
1aaa81ef89b04803e7a2e33a221d58228e44f87c5ec44e9b0c458442ba416b86  release/kernels/byp.log
5a03dfa4f3603fef49f1e3639e74e34152ca3ca5ef8e41eb959f8323040fa2d5  release/kernels/byp.oracle.jsonl
e6959260b72cec58365d0da758ddd7266891eb03af9547dc7fc9285d0c64e3bb  release/kernels/byp.sv-hosted.log
d934846bfdbef160d48ac67272c89a9e39cb2c5d9a50959b7779203eb88e9e9a  release/kernels/gather.by_instr.json
951e9bf7b25f4fcb1584b70320eadeada21a02063cb926ba7eb3a09d0ba1970a  release/kernels/gather.by_unit.json
916a31e8403d6a305162e03c6de87d470f5abefbdfa5da7513dcddea63f4a95f  release/kernels/gather.ccvtrace
ab4403fc7ac8071462ef0d8f8f357fad7a070032edc8d09b67279b503382a8fe  release/kernels/gather.log
0413e781d8d6ff578c64eb1f800b7931e66f676d5cdabb97b94a4033e6037662  release/kernels/gather.oracle.jsonl
e91544250acb7db08e75bff71b3c0915aff8e65d8a1fe53bce38f09c7acee0e5  release/kernels/gather.sv-hosted.log
1fcae252b9f4412bf1379e0bef9883c005006c3cfeb1440465221f746bfeab79  release/kernels/hit.by_instr.json
6cfdb22d3dd638746b25fa71aab24450393cc8f91c4c2867f9728df8aa0bdc84  release/kernels/hit.by_unit.json
ae070d6d1fe348d3cec4a71f8a845870eb7bb4aa5ee80496c9ee384f0d4b7b44  release/kernels/hit.ccvtrace
3c6c963043b63ed52db88bfe2695c918d094772f397b13eee100e66386065562  release/kernels/hit.log
7ba9603e0088d9164de6528f16ef6a7fa9ce5821c8c12b52cbb3734e39b9fd52  release/kernels/hit.oracle.jsonl
cf138f2df2b06bf6d757764055427533630f1cfc26503e0a809d98427295bec6  release/kernels/hit.sv-hosted.log
047fa35059372382d40c16f2a1c4bf93894d71dad3b70d08a8c6538c98949a71  release/kernels/loop.by_instr.json.gz
bba63a920fa7185aa601a6e3577f5550fa627e99df8581abd576cc36acb1e430  release/kernels/loop.by_unit.json.gz
052c2cb83d8d84c7040753e5749053aa363080059495971e69010791487728e0  release/kernels/loop.ccvtrace
dba50f1280ce606e37884bb0ec34ca9e03c8de282d01ff183a23a18628f5f5bf  release/kernels/loop.log
03ce5920c06c93e93516d8e53c3f7169f14e3593de204eacceffc0b8a3e32016  release/kernels/loop.oracle.jsonl
32db946e49c3f21ea73853b866935ad4bb6e2c28701bd3b116193854ee05d65c  release/kernels/loop.sv-hosted.log
64624f605a62d3c37bfe859ae57e7f32d865ebc9721fea8c77b47029337ac22c  release/kernels/merge.by_instr.json
3e15e63cb93d95fa92533dee8b8dedd9aa285627370d2d06beb945dced1863e5  release/kernels/merge.by_unit.json
af9f88d655fb7ab5962c0ae40412c3800cf643f380958119cad729f33cbfd0b7  release/kernels/merge.ccvtrace
a723e44c58bb3ee2eaba286aabe2b2ab82b257f9da983ba16873c50dc6d81044  release/kernels/merge.log
f96d28815f8756b1f5a45ded53e6170883d2dfa10f9eef0d14b8050b1318164a  release/kernels/merge.oracle.jsonl
4bfcfea203e6e2d31a3ff332128d089cc742b5beb40e104b8eb25c333bb3e15a  release/kernels/merge.sv-hosted.log
dbe77bf15f300f0782658b802295ee8ded6d4ec67f3c2481b4c29edb096b0ae4  release/kernels/mload.by_instr.json
2c50a00091dee40acfa9ccf1fde5617660c62cbe7b6777784061bf9d773134b9  release/kernels/mload.by_unit.json
93744db7a886cc92018add92e0abee980590a682f3061ed916e776319ae38988  release/kernels/mload.ccvtrace
7742a1040fe3e9cf035ea40cfbc9c1d9bdb139e4a4a459a73ea2a09491e1e805  release/kernels/mload.log
8000e477b9a95dfb9f0af964e8346acb9d36f1358fd06ffc4ff7cf599d2b8868  release/kernels/mload.oracle.jsonl
83b50c4f8e87701c8a90b1bc46528923a339b4f4d937e79c2ea253d65101ee84  release/kernels/mload.sv-hosted.log
63408fea900d0077c60446e5bb90f9eab563bca5d60840f7fa4f9915291a2111  release/kernels/pguard.by_instr.json
7662702ffbcea69aca80bd9ee1bf1c6aafefc5c7de50d23a4c5d781532bb705a  release/kernels/pguard.by_unit.json
dc463457883504b60a10ab6221c997e973646e31a04db4714ada6de034335776  release/kernels/pguard.ccvtrace
c717460ae1d98cbb5801b9d4de2b46721bc8593644be86015f748e767ccb2046  release/kernels/pguard.log
690e56f1cb8d97cbf67124b7dff3ad0a90cb8981814cd1709cf0cd0e035b3bd9  release/kernels/pguard.oracle.jsonl
063258aa2245bd3d8ae16ca5ab96cd28e8a657191b290b85bc475f5698047f82  release/kernels/pguard.sv-hosted.log
3033c95dbbd4baf5c3ec6f8b4b4a68ceaf2d2f4e40cc0a832e86fd4b3660cf82  release/kernels/plog.by_instr.json
9f4693cea39480da5d1f021e4ea8fd240668c2ab55675246f51e023ed7841c74  release/kernels/plog.by_unit.json
af555b497fcec210a50d07e2ab736b9f18fb3aedcb557baee01951a9bd09daa9  release/kernels/plog.ccvtrace
9f1664d4ba8d5d98b306343ded9961920fdbf36d88d37c97f94691238bc6879b  release/kernels/plog.log
c230f13f2e1082b306a9c5ab7809ff36cf5c1b2e47dca6b7a71f741524d403f5  release/kernels/plog.oracle.jsonl
19dfc074ddd17f0a7c348dee5993d134b0ff5bcaa61f2c8652f45d613fb2c954  release/kernels/plog.sv-hosted.log
b24063793297cd6523945a9132a9a9af960fbe2eb06ef24fe5af2ea7bad48c69  release/kernels/sel.by_instr.json
5e6b7a5afd31ba0f1ec4bf1c2c3971853f973bd12e74629fa4bcda5a1d8514ad  release/kernels/sel.by_unit.json
5252066e5bc243844ef25991fc53693e1892c8de382c009b65e8f1de2c8b7463  release/kernels/sel.ccvtrace
0f3570dbd980a10be706587f559c01917e13528d83aa96ab2a29db6e4d954884  release/kernels/sel.log
87f6a81e8afa004c8039bf2f61c90176fcf29ab29bb17ac44aa016a5cc8438fe  release/kernels/sel.oracle.jsonl
5fb80444757f51925b8b29f3ba7aa08feca239cd4c9e5e65f6ca7924393c564b  release/kernels/sel.sv-hosted.log
4e04b55a1e355580a502acac2c9b51fbc911f042a5d95e3d8f39ce9afdef90d1  release/kernels/srd.by_instr.json
5aed64b2c239561b3ac5d60c2ae30dee94801b682e145c1272065720f963f5e1  release/kernels/srd.by_unit.json
695a8b268308abf2971fe6deb7cf72c65a651db91a59cfebdd3d12d20954bbfc  release/kernels/srd.ccvtrace
b1202272017f65242d282e0c8f4874440748a963dfea25ca15c2748418321e72  release/kernels/srd.log
b08eb5e3673cac7eebb8b72af5ed3783c8e70a9e96592e76bf3722551bc79473  release/kernels/srd.oracle.jsonl
ccb83f1489fd9684fd2c3b6996473ad562cc972d2c3e7d476db4ff945aa79bd1  release/kernels/srd.sv-hosted.log
238035cbaee710ebc2c1c33e9334f29ae5115e7e3fd0a924c423fed911fc89ae  release/kernels/unal.by_instr.json
3f510a867b2e05230dc1f9f028ca956f91c771f7ab5a29970c415e362d7c4443  release/kernels/unal.by_unit.json
a358f4a6f96fd16a78c3cd0ce1af6b0ef5fe7f695602f24a0549b716b6cd5204  release/kernels/unal.ccvtrace
bbb04f51ce96d38394240f83c4f961c256e744ca6e1a0071bb4f8c05ab953eb9  release/kernels/unal.log
95c7843c969a36d56099170e7aeb27a1cbed6d2d69cc471b44be9593bf0d8362  release/kernels/unal.oracle.jsonl
1bf25aff0715e700cf5f4c5c46a3189af86a5c61e53a0278e425f9af02bdafe8  release/kernels/unal.sv-hosted.log
992725c443275553d3d60a7fbb24ae4364ff6223395157aefa1b688f1ca58b13  release/kernels/vadd.by_instr.json
a17058c9c7c351ee90bd1fbe27d82adaf445bdbc15f27ad3182aea80df1fccd8  release/kernels/vadd.by_unit.json
43110d994ca54d1cd4928197aa094a121c852cbb8c5a9cb07d144ba07cd95a8a  release/kernels/vadd.ccvtrace
80ab40d70571706339637ebb71dbfca7b00f980e50c8d7623949f747a62dba6a  release/kernels/vadd.log
0276b6d0611a4bbcdc004ab3987214aea138245bc7217504147331689a9c0880  release/kernels/vadd.oracle.jsonl
f78d25848f07cc7066673cb9e60bc377610a6af43492aa5ea997ac4c8792c813  release/kernels/vadd.sv-hosted.log
591c7536332333f09849f35d36917a1667a046b166c504b359854080b6d749b3  release/verify.log
efec12fa3875516bd93eb483139bd285209552bf4ca91a899c12def9830305e8  release/wiring.txt
```
