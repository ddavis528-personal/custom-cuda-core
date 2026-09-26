# Snapshot snapshot-2026-09-26-0f45cb1

**A generated, read-only snapshot. Do not edit or merge it.** The source
is `claude/custom-cuda-core-infra-6msg93` at `0f45cb1c5ab0253066628d7c0160c453652ab069`, and this branch is rebuilt from source by
`tools/make-release.sh`; nothing here flows back.

What is here beyond the source tree at that commit:

- **Generated files, at their real paths:** `rtl/generated/` (interface
  typedefs in `ccv_interfaces.svh`, parameter packages, the checker
  bank, event ids) and `sim/generated/`. On the development branch
  these are build products and gitignored.
- **`release/`:** the gate log (`verify.log`), the C++ skeleton's
  wiring dump, and for each S1 kernel its run summary, event trace
  (`.ccvtrace`) and two Perfetto views -- open the `.json` files at
  https://ui.perfetto.dev -- and the ccv-sim oracle record it ran
  against, generated from the pinned compiler snapshot.

| | |
|---|---|
| Source | `claude/custom-cuda-core-infra-6msg93` @ `0f45cb1c5ab0253066628d7c0160c453652ab069` |
| Built | 2026-09-26 (UTC) |
| Gate | `tools/verify.sh`: PASS |
| Compiler snapshot | custom-cuda-complier `release` @ `b64fc61a5257970aa47973da0fbdcf458b59417a` (source `b00ba89118ef40d62476232a8f65d6eaf4f3b99f`) |
| Verilator | Verilator 5.020 2024-01-01 rev (Debian 5.020-1) |
| Icarus | Icarus Verilog version 12.0 (stable) () |
| Yosys | Yosys 0.33 (git sha1 2584903a060) |

## Kernels

| Kernel | Result |
|---|---|
| `pguard` | `name=pguard finished=1 cycles=128 retired=12 issue_groups=12 order=ok gpr_mismatch=0 pred_mismatch=0 mem_mismatch=0 check_failures=0 class_violations=0 overflows=0 channels_used=25/46 violations=0` |
| `sel` | `name=sel finished=1 cycles=119 retired=8 issue_groups=8 order=ok gpr_mismatch=0 pred_mismatch=0 mem_mismatch=0 check_failures=0 class_violations=0 overflows=0 channels_used=25/46 violations=0` |
| `srd` | `name=srd finished=1 cycles=111 retired=6 issue_groups=6 order=ok gpr_mismatch=0 pred_mismatch=0 mem_mismatch=0 check_failures=0 class_violations=0 overflows=0 channels_used=25/46 violations=0` |
| `vadd` | `name=vadd finished=1 cycles=361 retired=17 issue_groups=17 order=ok gpr_mismatch=0 pred_mismatch=0 mem_mismatch=0 check_failures=0 class_violations=0 overflows=0 channels_used=26/46 violations=0` |

## Manifest of release/

```
7eac0d22bea447a76bda5edc8aef2d1e4277be24e19b466b3d62b09937f20bb4  release/kernels/pguard.by_instr.json
6a9ef6af3afdda41bae51e00eec466def88715fd07853a8dec92876f26b3f292  release/kernels/pguard.by_unit.json
9b1ad58b143f4831e8298a5e029274a04e9185ae2150d14e5f9c54b7474bb8f1  release/kernels/pguard.ccvtrace
552f8a45bcf0439614df418101571c2226ecbd709131294293f37b7eacafcc44  release/kernels/pguard.log
690e56f1cb8d97cbf67124b7dff3ad0a90cb8981814cd1709cf0cd0e035b3bd9  release/kernels/pguard.oracle.jsonl
d6ad6807cfa645ea0815d4a30c3c79ea3292a2fe62423a33c37c879644f586f8  release/kernels/sel.by_instr.json
da7c09ab6edccb6b711e78becb6b724882076c3157f1c39eaccb7239906a7ba6  release/kernels/sel.by_unit.json
c9762e22a7edafc51e9348291caad29a0c006dffc0a4080449c67413e2e29154  release/kernels/sel.ccvtrace
606c9408baf883104902a26ea0eb5ee7f77b79a3b6ef12f0fed811ea24cf9151  release/kernels/sel.log
87f6a81e8afa004c8039bf2f61c90176fcf29ab29bb17ac44aa016a5cc8438fe  release/kernels/sel.oracle.jsonl
8492ba5abf65ea5ddd96c90212d199c9ad1688bc703e8e42ce13c6065ad6985c  release/kernels/srd.by_instr.json
284a59c56655a08f96d988d9c29a541f36a55274966fdabaea603b9ca97bd311  release/kernels/srd.by_unit.json
172515cd3efc9cd8aee1649dcddc5d46b73a338516402ff5efcf2b00620545de  release/kernels/srd.ccvtrace
fbe37652f8c753866f3831feb9783a0e44d461b88f1108f82220a3c430296894  release/kernels/srd.log
b08eb5e3673cac7eebb8b72af5ed3783c8e70a9e96592e76bf3722551bc79473  release/kernels/srd.oracle.jsonl
550e348efd88e142d560441ee5b88c4837f4f5c9ca9442a602da7835ddd5711f  release/kernels/vadd.by_instr.json
0b1cb57416d420cb1ed3235103525733e5dcdb79ae310a297b5a0d0e8e6bafb2  release/kernels/vadd.by_unit.json
13e3ce39db252c8891f32f468cbf0c9e4f69bd4d69a81270537ac6e71c28391a  release/kernels/vadd.ccvtrace
9afc5e62190bdb8ad215f25d8a967b3e8cea5bb2531c0690bf812e281661e3e1  release/kernels/vadd.log
0276b6d0611a4bbcdc004ab3987214aea138245bc7217504147331689a9c0880  release/kernels/vadd.oracle.jsonl
c602645471de10a08e81a7a09d1d0593cca643eabaf78fa2d82babb0909cebd2  release/verify.log
39261d113d3434f259e1c156cdef392ffaa04688ef0d4ea24162072578f944fa  release/wiring.txt
```
