# Snapshot snapshot-2026-10-05-fe587c3

**A generated, read-only snapshot. Do not edit or merge it.** The source
is `claude/custom-cuda-core-infra-6msg93` at `fe587c392e21dde0abd04647ca5179194d0c1d32`, and this branch is rebuilt from source by
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
| Source | `claude/custom-cuda-core-infra-6msg93` @ `fe587c392e21dde0abd04647ca5179194d0c1d32` |
| Built | 2026-10-05 (UTC) |
| Gate | `tools/verify.sh`: PASS |
| Compiler snapshot | custom-cuda-complier `release` @ `41e32c55e11a7c85e5f0234689dc76cdd5e41283` (source `e74eea711a49e6ba071de87ba6fc743b5e7edf4a`) |
| Verilator | Verilator 5.020 2024-01-01 rev (Debian 5.020-1) |
| Icarus | Icarus Verilog version 12.0 (stable) () |
| Yosys | Yosys 0.33 (git sha1 2584903a060) |

## Kernels

| Kernel | Result |
|---|---|
| `brs` | `name=brs finished=1 cycles=83 retired=12 issue_groups=12 order=ok gpr_mismatch=0 pred_mismatch=0 mem_mismatch=0 check_failures=0 class_violations=0 overflows=0 credit_leaks=0 channels_used=19/48 violations=0` |
| `gather` | `name=gather finished=1 cycles=2345 retired=16 issue_groups=16 order=ok gpr_mismatch=0 pred_mismatch=0 mem_mismatch=0 check_failures=0 class_violations=0 overflows=0 credit_leaks=0 channels_used=26/48 violations=0` |
| `loop` | `name=loop finished=1 cycles=2636 retired=407 issue_groups=407 order=ok gpr_mismatch=0 pred_mismatch=0 mem_mismatch=0 check_failures=0 class_violations=0 overflows=0 credit_leaks=0 channels_used=19/48 violations=0` |
| `merge` | `name=merge finished=1 cycles=67 retired=9 issue_groups=9 order=ok gpr_mismatch=0 pred_mismatch=0 mem_mismatch=0 check_failures=0 class_violations=0 overflows=0 credit_leaks=0 channels_used=17/48 violations=0` |
| `mload` | `name=mload finished=1 cycles=116 retired=11 issue_groups=11 order=ok gpr_mismatch=0 pred_mismatch=0 mem_mismatch=0 check_failures=0 class_violations=0 overflows=0 credit_leaks=0 channels_used=25/48 violations=0` |
| `pguard` | `name=pguard finished=1 cycles=125 retired=12 issue_groups=12 order=ok gpr_mismatch=0 pred_mismatch=0 mem_mismatch=0 check_failures=0 class_violations=0 overflows=0 credit_leaks=0 channels_used=25/48 violations=0` |
| `sel` | `name=sel finished=1 cycles=117 retired=8 issue_groups=8 order=ok gpr_mismatch=0 pred_mismatch=0 mem_mismatch=0 check_failures=0 class_violations=0 overflows=0 credit_leaks=0 channels_used=25/48 violations=0` |
| `srd` | `name=srd finished=1 cycles=110 retired=6 issue_groups=6 order=ok gpr_mismatch=0 pred_mismatch=0 mem_mismatch=0 check_failures=0 class_violations=0 overflows=0 credit_leaks=0 channels_used=25/48 violations=0` |
| `unal` | `name=unal finished=1 cycles=263 retired=9 issue_groups=9 order=ok gpr_mismatch=0 pred_mismatch=0 mem_mismatch=0 check_failures=0 class_violations=0 overflows=0 credit_leaks=0 channels_used=26/48 violations=0` |
| `vadd` | `name=vadd finished=1 cycles=306 retired=17 issue_groups=17 order=ok gpr_mismatch=0 pred_mismatch=0 mem_mismatch=0 check_failures=0 class_violations=0 overflows=0 credit_leaks=0 channels_used=27/48 violations=0` |

## Manifest of release/

```
b684697c7d9d315b9ed266f4175a816352ce5c519faa9c4506948827eed6fbb0  release/kernels/brs.by_instr.json
b227d07ae5de3c1e3bd94e7c3430afabf2e079c9ef5aac1348d8dcec6e2c3e74  release/kernels/brs.by_unit.json
3b06ae60d2915bae76733aa9c1c49725b2c4061a26d0b8605a4c03312a4bbc23  release/kernels/brs.ccvtrace
c599396c2eebddb55524bc2137596f117be10769eb13efe70d7883df9a46bb3e  release/kernels/brs.log
e3c1cb3379580cf1aae44e8ddc8e846ef6fd661a573cfe0a8d4444b18a14dc56  release/kernels/brs.oracle.jsonl
70fa28e43bac7debdb9834a280e1b4dac1f5203313bf5c615ac2b44e52e38654  release/kernels/brs.sv-hosted.log
e12710e2a7e33c386a143db63b375c1449a821740737aa9a3f88bd13b20034e3  release/kernels/gather.by_instr.json
3317ba6260f7d3ef36e95c37c12e8e124ebb204467c8857e624f81ca8f7093e6  release/kernels/gather.by_unit.json
e71711bc60d773037169f9b7bcfac0340392d50e0cf0778a457836354cd2a5c4  release/kernels/gather.ccvtrace
0f10353222d82f6daa937d5b90a7acbd842270dfd2c958beee30449812eed719  release/kernels/gather.log
0413e781d8d6ff578c64eb1f800b7931e66f676d5cdabb97b94a4033e6037662  release/kernels/gather.oracle.jsonl
754f4dd9edf73d73543357d83a6750b2707410245045544e072dce172cf0536d  release/kernels/gather.sv-hosted.log
36713284916ffe146545197946ff286409d89d75e338523e74b6ca58acfb1617  release/kernels/loop.by_instr.json.gz
b4e95ea9676e85b8caaee93bce956cb2210bcdcff63115bd6080bc0f638d0aef  release/kernels/loop.by_unit.json.gz
dce694e019e9096beb474a907f1670df8ac21f77c6c4f64fa1df232e834c926c  release/kernels/loop.ccvtrace
6420e3f8334e69cee7b4a16cbcfee74d815661634e4f0f89078f6b6cf92e9057  release/kernels/loop.log
03ce5920c06c93e93516d8e53c3f7169f14e3593de204eacceffc0b8a3e32016  release/kernels/loop.oracle.jsonl
f4fe984a16a8208d234b2228afe660111995cbd0ab5c96975aa5f9d4747500e5  release/kernels/loop.sv-hosted.log
2a7515d5c1a56f974c8cc7b612cd31d09aa80443679e0b1d8f448ad1c05475f4  release/kernels/merge.by_instr.json
122badd214644c341c110ef543b86b7f0dc4cf4c93532d1e14495a07c815f8e0  release/kernels/merge.by_unit.json
4383e8651dd4c1f53bd044d336f9be70cbf4d29418f06f31f8422b68a86c70d9  release/kernels/merge.ccvtrace
75ce73f506674ba000cabe27ba66254722874e7378211cfa682e7c48cf4f10a3  release/kernels/merge.log
f96d28815f8756b1f5a45ded53e6170883d2dfa10f9eef0d14b8050b1318164a  release/kernels/merge.oracle.jsonl
9e8bdcf18a5ddda46e346d69524cf165624b2114fffb763c8c2b96f7f8afd42d  release/kernels/merge.sv-hosted.log
5ac7df7f5a90500ed818015ea67b843203d35b7d8ff58d631c514265f2efb9fb  release/kernels/mload.by_instr.json
db1edf1201848670b9150abfa0bd7034200da94035e62ae5e598ecc5ff944193  release/kernels/mload.by_unit.json
27b685d32d8097cf5df6faa770fd6ab017db58265fd69618c26e89a32108b981  release/kernels/mload.ccvtrace
8a5dd55e14d1986e472260e9d06c661397adee16970ec165630ae0c5dc586de5  release/kernels/mload.log
8000e477b9a95dfb9f0af964e8346acb9d36f1358fd06ffc4ff7cf599d2b8868  release/kernels/mload.oracle.jsonl
3853c5ed10718fbdc40f37f36674ecb9a1e5d929f78fe41b54d0c0a12a701ab8  release/kernels/mload.sv-hosted.log
59f79d012efefaaaf10b592c8b2680651fd802ec1b6be8a48e1080816f5697d8  release/kernels/pguard.by_instr.json
0a80cd770fe4fea9cf4dc24a7c8a95896195f557653796dac0e4b67066937225  release/kernels/pguard.by_unit.json
83e1a9623dfc161fb4c563906d678784757a4adae36ba69fe6507bafe01b016f  release/kernels/pguard.ccvtrace
4fca0a6c5d89f5a13690e9db4a0c2a66107d3af0369ec0e35c6c0cbc74d4c99f  release/kernels/pguard.log
690e56f1cb8d97cbf67124b7dff3ad0a90cb8981814cd1709cf0cd0e035b3bd9  release/kernels/pguard.oracle.jsonl
06480859f788c20165da48528c2092f8879dd390a4abd99e7221864f0643d3dd  release/kernels/pguard.sv-hosted.log
fdd35c58e356cf29a39f75544267646ee9e4e4ade6390c97d1112bebd925c869  release/kernels/sel.by_instr.json
a70620725eac1b5071e823eae343bb9df35f653fb0dfa0216e02f1ae69694136  release/kernels/sel.by_unit.json
a07614d7e8a3323820e5a3b092edf07bf77bbce50eaaf7d8750f30f8de306e76  release/kernels/sel.ccvtrace
4006494483b5eb96711b9c2ba046447778d424b64fa073843145ff8a6543aaff  release/kernels/sel.log
87f6a81e8afa004c8039bf2f61c90176fcf29ab29bb17ac44aa016a5cc8438fe  release/kernels/sel.oracle.jsonl
ce4f84007a544995db9597acb915fe279fb09f23eb0557584b8e384abe7e6f5f  release/kernels/sel.sv-hosted.log
05a95e12d2d37dd3dd94032893c0c7791fced3aaa01badb2bb67586cbeaf6561  release/kernels/srd.by_instr.json
4edcb4f444c204c231c49731075e89e49bedea920680030a9376c125932efa90  release/kernels/srd.by_unit.json
1e46ac77ce9fc86af4eb43e5a261196fa9dc39591167215368e2d0867876170d  release/kernels/srd.ccvtrace
4094aee8d70af46da1328a04dd9c4e94dad56096cb1f2bd8d5ee37703a825108  release/kernels/srd.log
b08eb5e3673cac7eebb8b72af5ed3783c8e70a9e96592e76bf3722551bc79473  release/kernels/srd.oracle.jsonl
2fc02c55cdceb9eb12e04883cbe1fd775380d83cb3e0e52cd771f55b81eff863  release/kernels/srd.sv-hosted.log
a2e7241c26c08e09681463abce2297bc9a3d8f37c3982ca54cf68eb2f24bccec  release/kernels/unal.by_instr.json
37d07a02fdc1a0bda46910076f23c6498750bbebc5c7cd20cfa3c3dc482ffed3  release/kernels/unal.by_unit.json
bce2a78a48d54619bc02d23c4312ecf45f152b93e9fdd3954bcb43774e899ece  release/kernels/unal.ccvtrace
6b6aab18bbcc7387f9fc4cfb2909147a42e673d7b7c51664b3757bed10aa5e5a  release/kernels/unal.log
95c7843c969a36d56099170e7aeb27a1cbed6d2d69cc471b44be9593bf0d8362  release/kernels/unal.oracle.jsonl
81a9ff554fd4a4783c6e80e2752d434b855beadd6ee7b036c5daf43ed057deb1  release/kernels/unal.sv-hosted.log
37c6963b0f0004600d3f7a254d2cd00ccbea1bb493cbaf488e34ed1dbd09aa1f  release/kernels/vadd.by_instr.json
b833a5f683b3eb836828f3aa9424199eec4e7a2945b4b5b61e17eba79cbca7b0  release/kernels/vadd.by_unit.json
257cb0eee1c7484d339dc75dc53a96e8c5ab415d7a1f1da7accf31c20f86c4ec  release/kernels/vadd.ccvtrace
45e5b76300c04b3934891d34aecc7d8c6bfde60ca085d0f2a5ecb180cbdd849d  release/kernels/vadd.log
0276b6d0611a4bbcdc004ab3987214aea138245bc7217504147331689a9c0880  release/kernels/vadd.oracle.jsonl
61f472d0a459122149fda0d88f8ce818e958fe52a01330c29ff34f41b8d3f26a  release/kernels/vadd.sv-hosted.log
05188f3ed5216a12f04dcd79e8c8cc48130eb06fc317815cb32032c4e1f6ab44  release/verify.log
aedadc484be8db1b52aebecdaee7bee11c84c294efd67e26f5fd7dcce46bbf47  release/wiring.txt
```
