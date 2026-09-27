# Snapshot snapshot-2026-09-27-ddab7f8

**A generated, read-only snapshot. Do not edit or merge it.** The source
is `claude/custom-cuda-core-infra-6msg93` at `ddab7f896d8a2cc5feddc018dff7d1cd87d4b653`, and this branch is rebuilt from source by
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
  https://ui.perfetto.dev -- and the ccv-sim oracle record it ran
  against, generated from the pinned compiler snapshot, and the
  same kernel's run with every block hosted by the SV top
  (`.sv-hosted.log`).

| | |
|---|---|
| Source | `claude/custom-cuda-core-infra-6msg93` @ `ddab7f896d8a2cc5feddc018dff7d1cd87d4b653` |
| Built | 2026-09-27 (UTC) |
| Gate | `tools/verify.sh`: PASS |
| Compiler snapshot | custom-cuda-complier `release` @ `b64fc61a5257970aa47973da0fbdcf458b59417a` (source `b00ba89118ef40d62476232a8f65d6eaf4f3b99f`) |
| Verilator | Verilator 5.020 2024-01-01 rev (Debian 5.020-1) |
| Icarus | Icarus Verilog version 12.0 (stable) () |
| Yosys | Yosys 0.33 (git sha1 2584903a060) |

## Kernels

| Kernel | Result |
|---|---|
| `pguard` | `name=pguard finished=1 cycles=128 retired=12 issue_groups=12 order=ok gpr_mismatch=0 pred_mismatch=0 mem_mismatch=0 check_failures=0 class_violations=0 overflows=0 credit_leaks=0 channels_used=25/46 violations=0` |
| `sel` | `name=sel finished=1 cycles=119 retired=8 issue_groups=8 order=ok gpr_mismatch=0 pred_mismatch=0 mem_mismatch=0 check_failures=0 class_violations=0 overflows=0 credit_leaks=0 channels_used=25/46 violations=0` |
| `srd` | `name=srd finished=1 cycles=111 retired=6 issue_groups=6 order=ok gpr_mismatch=0 pred_mismatch=0 mem_mismatch=0 check_failures=0 class_violations=0 overflows=0 credit_leaks=0 channels_used=25/46 violations=0` |
| `vadd` | `name=vadd finished=1 cycles=361 retired=17 issue_groups=17 order=ok gpr_mismatch=0 pred_mismatch=0 mem_mismatch=0 check_failures=0 class_violations=0 overflows=0 credit_leaks=0 channels_used=26/46 violations=0` |

## Manifest of release/

```
156a4b6265f5a4ea5296959133e357a10220154f7ac2761b691c2b44cbf83ead  release/kernels/pguard.by_instr.json
1ca66573ee80ca91f00e8228c556e4d86839ec2557a475b74b62294ebeebdfaa  release/kernels/pguard.by_unit.json
66215d0a8e267255bd3d870542d6e174708e439bd199b39ffd343ffed13686ba  release/kernels/pguard.ccvtrace
b00ad7f7c83e4d85f0f5a0fb236d4c8826b3a0babef60ea5123ab1016c6a01a9  release/kernels/pguard.log
690e56f1cb8d97cbf67124b7dff3ad0a90cb8981814cd1709cf0cd0e035b3bd9  release/kernels/pguard.oracle.jsonl
65f3c150aad7b274d793aa81bb45890439639b4c70f7fed816d2d61258e11795  release/kernels/pguard.sv-hosted.log
5024800090987fb9a477e8352b706d98a7e5aed76c261c69571c5224c99fe2cf  release/kernels/sel.by_instr.json
42e5845ee5c296c176aa2e9907543702e5726bdc509a58e6268cd2a08d83e7e4  release/kernels/sel.by_unit.json
f309e49ca75f24b728730e0c3203160e9e0e2ced30c66687084f54b237ec41fc  release/kernels/sel.ccvtrace
4b2ebe1b69561aad46171b9a65a1f36b1557f1de74307055658658bfe6eacae4  release/kernels/sel.log
87f6a81e8afa004c8039bf2f61c90176fcf29ab29bb17ac44aa016a5cc8438fe  release/kernels/sel.oracle.jsonl
7ef0cc51349b97d4b304fe3b2c56ec9c16556a5236dcbebfbf850c67bd3410f2  release/kernels/sel.sv-hosted.log
d79a05ee3e4bd24690889a464be27dbd7e178a25f1d054f5dacd87976f50bb82  release/kernels/srd.by_instr.json
f43edbc31edcc755e00f0c83f9ba9ea5386abf181f7724edbe4349e90965491e  release/kernels/srd.by_unit.json
2cc640743d982050e52df9bedcb61968ba56324a33b30d30a92efa986bdb26dd  release/kernels/srd.ccvtrace
4ec8a7521c35a9a1c9b99dfc7a9ac9f835325885c502a5331639feb1e8aa73b0  release/kernels/srd.log
b08eb5e3673cac7eebb8b72af5ed3783c8e70a9e96592e76bf3722551bc79473  release/kernels/srd.oracle.jsonl
3c048c3c250b81ca7e8cada3ac1d66c236e65b5143c4f85ef42e781de5511cde  release/kernels/srd.sv-hosted.log
4958d958c83f1c72e56d9f0d6edcbca843cfa26dcdb0175638d55c98987c5122  release/kernels/vadd.by_instr.json
0acf03f92015ae78bf46f46f61c58644321f913186d72834d79d36bbc84d2252  release/kernels/vadd.by_unit.json
cb4b8b86df23b2ad337860bd027e5da9282a4bf8cdfb0a62c036ed62c1951980  release/kernels/vadd.ccvtrace
d7a232015dca37b0bc1445379611e0b4d890837a27c54983645ab1c0e6538622  release/kernels/vadd.log
0276b6d0611a4bbcdc004ab3987214aea138245bc7217504147331689a9c0880  release/kernels/vadd.oracle.jsonl
4f305dadb1eef23c8245498ba0a692c5d96c1e4bcb496f8f57b3d55f3016abe9  release/kernels/vadd.sv-hosted.log
1ea6bd8a4537a4ab68826134d07f036cd366d5f0eb8a9ff7ee2f07fe824091c6  release/verify.log
7594d01b3c6e1922bde7b4528f75c9c35c13b859b95d799a2fb58d972194368e  release/wiring.txt
```
