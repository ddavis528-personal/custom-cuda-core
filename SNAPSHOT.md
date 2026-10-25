# Snapshot snapshot-2026-10-25-90c9639

**A generated, read-only snapshot. Do not edit or merge it.** The source
is `ti-ret` at `90c96393713b2f422b10bc6b700dcd5ef665113b`, and this branch is rebuilt from source by
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
| Source | `ti-ret` @ `90c96393713b2f422b10bc6b700dcd5ef665113b` |
| Built | 2026-10-25 (UTC) |
| Gate | `tools/verify.sh`: PASS |
| Compiler snapshot | custom-cuda-complier `release` @ `13b4cfd1acd6a36439812ba88cfaeb52c3e4a301` (source `c15dc9671709b818851419830cf71bb0513ef592`) |
| Verilator | Verilator 5.052 2026-09-05 rev v5.052 |
| Icarus | Icarus Verilog version 12.0 (stable) () |
| Yosys | Yosys 0.33 (git sha1 2584903a060) |

## Kernels

| Kernel | Result |
|---|---|
| `addrhigh` | `name=addrhigh finished=1 cycles=71 from_fetch=40 retired=5 issue_groups=6 order=ok gpr_mismatch=0 pred_mismatch=0 mem_mismatch=0 check_failures=0 class_violations=0 overflows=0 credit_leaks=0 channels_used=25/54 violations=0` |
| `addrlimit` | `name=addrlimit finished=1 cycles=1071 from_fetch=1040 retired=5 issue_groups=5 order=ok gpr_mismatch=0 pred_mismatch=0 mem_mismatch=0 check_failures=0 class_violations=0 overflows=0 credit_leaks=0 channels_used=26/54 violations=0` |
| `addrneg` | `name=addrneg finished=1 cycles=69 from_fetch=38 retired=1 issue_groups=2 order=ok gpr_mismatch=0 pred_mismatch=0 mem_mismatch=0 check_failures=0 class_violations=0 overflows=0 credit_leaks=0 channels_used=22/54 violations=0` |
| `brs` | `name=brs finished=1 cycles=100 from_fetch=69 retired=12 issue_groups=12 order=ok gpr_mismatch=0 pred_mismatch=0 mem_mismatch=0 check_failures=0 class_violations=0 overflows=0 credit_leaks=0 channels_used=22/54 violations=0` |
| `byp` | `name=byp finished=1 cycles=117 from_fetch=86 retired=14 issue_groups=14 order=ok gpr_mismatch=0 pred_mismatch=0 mem_mismatch=0 check_failures=0 class_violations=0 overflows=0 credit_leaks=0 channels_used=30/54 violations=0` |
| `callret` | `name=callret finished=1 cycles=270 from_fetch=239 retired=40 issue_groups=40 order=ok gpr_mismatch=0 pred_mismatch=0 mem_mismatch=0 check_failures=0 class_violations=0 overflows=0 credit_leaks=0 channels_used=29/54 violations=0` |
| `chains` | `name=chains finished=1 cycles=97 from_fetch=66 retired=29 issue_groups=29 order=ok gpr_mismatch=0 pred_mismatch=0 mem_mismatch=0 check_failures=0 class_violations=0 overflows=0 credit_leaks=0 channels_used=20/54 violations=0` |
| `div` | `name=div finished=1 cycles=977 from_fetch=946 retired=144 issue_groups=144 order=ok gpr_mismatch=0 pred_mismatch=0 mem_mismatch=0 check_failures=0 class_violations=0 overflows=0 credit_leaks=0 channels_used=22/54 violations=0` |
| `divchw` | `name=divchw finished=1 cycles=99 from_fetch=68 retired=5 issue_groups=6 order=ok gpr_mismatch=0 pred_mismatch=0 mem_mismatch=0 check_failures=0 class_violations=0 overflows=0 credit_leaks=0 channels_used=21/54 violations=0` |
| `divtail` | `name=divtail finished=1 cycles=641 from_fetch=610 retired=96 issue_groups=96 order=ok gpr_mismatch=0 pred_mismatch=0 mem_mismatch=0 check_failures=0 class_violations=0 overflows=0 credit_leaks=0 channels_used=22/54 violations=0` |
| `divtail2` | `name=divtail2 finished=1 cycles=1516 from_fetch=1485 retired=366 issue_groups=366 order=ok gpr_mismatch=0 pred_mismatch=0 mem_mismatch=0 check_failures=0 class_violations=0 overflows=0 credit_leaks=0 channels_used=22/54 violations=0` |
| `fence` | `name=fence finished=1 cycles=82 from_fetch=51 retired=7 issue_groups=7 order=ok gpr_mismatch=0 pred_mismatch=0 mem_mismatch=0 check_failures=0 class_violations=0 overflows=0 credit_leaks=0 channels_used=29/54 violations=0` |
| `gather` | `name=gather finished=1 cycles=265 from_fetch=234 retired=16 issue_groups=16 order=ok gpr_mismatch=0 pred_mismatch=0 mem_mismatch=0 check_failures=0 class_violations=0 overflows=0 credit_leaks=0 channels_used=30/54 violations=0` |
| `hit` | `name=hit finished=1 cycles=228 from_fetch=197 retired=17 issue_groups=17 order=ok gpr_mismatch=0 pred_mismatch=0 mem_mismatch=0 check_failures=0 class_violations=0 overflows=0 credit_leaks=0 channels_used=30/54 violations=0` |
| `lanectx` | `name=lanectx finished=1 cycles=69 from_fetch=38 retired=10 issue_groups=10 order=ok gpr_mismatch=0 pred_mismatch=0 mem_mismatch=0 check_failures=0 class_violations=0 overflows=0 credit_leaks=0 channels_used=28/54 violations=0` |
| `lanectx2` | `name=lanectx2 finished=1 cycles=69 from_fetch=38 retired=10 issue_groups=10 order=ok gpr_mismatch=0 pred_mismatch=0 mem_mismatch=0 check_failures=0 class_violations=0 overflows=0 credit_leaks=0 channels_used=28/54 violations=0` |
| `late` | `name=late finished=1 cycles=172 from_fetch=141 retired=16 issue_groups=16 order=ok gpr_mismatch=0 pred_mismatch=0 mem_mismatch=0 check_failures=0 class_violations=0 overflows=0 credit_leaks=0 channels_used=30/54 violations=0` |
| `ldpar` | `name=ldpar finished=1 cycles=155 from_fetch=124 retired=17 issue_groups=17 order=ok gpr_mismatch=0 pred_mismatch=0 mem_mismatch=0 check_failures=0 class_violations=0 overflows=0 credit_leaks=0 channels_used=30/54 violations=0` |
| `localsp` | `name=localsp finished=1 cycles=4274 from_fetch=4243 retired=40 issue_groups=40 order=ok gpr_mismatch=0 pred_mismatch=0 mem_mismatch=0 check_failures=0 class_violations=0 overflows=0 credit_leaks=0 channels_used=30/54 violations=0` |
| `loop` | `name=loop finished=1 cycles=2839 from_fetch=2808 retired=407 issue_groups=407 order=ok gpr_mismatch=0 pred_mismatch=0 mem_mismatch=0 check_failures=0 class_violations=0 overflows=0 credit_leaks=0 channels_used=22/54 violations=0` |
| `merge` | `name=merge finished=1 cycles=72 from_fetch=41 retired=9 issue_groups=9 order=ok gpr_mismatch=0 pred_mismatch=0 mem_mismatch=0 check_failures=0 class_violations=0 overflows=0 credit_leaks=0 channels_used=20/54 violations=0` |
| `missrun` | `name=missrun finished=1 cycles=122 from_fetch=91 retired=28 issue_groups=28 order=ok gpr_mismatch=0 pred_mismatch=0 mem_mismatch=0 check_failures=0 class_violations=0 overflows=0 credit_leaks=0 channels_used=30/54 violations=0` |
| `mload` | `name=mload finished=1 cycles=112 from_fetch=81 retired=11 issue_groups=11 order=ok gpr_mismatch=0 pred_mismatch=0 mem_mismatch=0 check_failures=0 class_violations=0 overflows=0 credit_leaks=0 channels_used=30/54 violations=0` |
| `mlp` | `name=mlp finished=1 cycles=120 from_fetch=89 retired=21 issue_groups=21 order=ok gpr_mismatch=0 pred_mismatch=0 mem_mismatch=0 check_failures=0 class_violations=0 overflows=0 credit_leaks=0 channels_used=30/54 violations=0` |
| `mwmiss` | `name=mwmiss finished=1 cycles=130 from_fetch=99 retired=88 issue_groups=88 order=ok gpr_mismatch=0 pred_mismatch=0 mem_mismatch=0 check_failures=0 class_violations=0 overflows=0 credit_leaks=0 channels_used=30/54 violations=0` |
| `narrowadd` | `name=narrowadd finished=1 cycles=230 from_fetch=199 retired=21 issue_groups=21 order=ok gpr_mismatch=0 pred_mismatch=0 mem_mismatch=0 check_failures=0 class_violations=0 overflows=0 credit_leaks=0 channels_used=31/54 violations=0` |
| `pguard` | `name=pguard finished=1 cycles=84 from_fetch=53 retired=12 issue_groups=12 order=ok gpr_mismatch=0 pred_mismatch=0 mem_mismatch=0 check_failures=0 class_violations=0 overflows=0 credit_leaks=0 channels_used=28/54 violations=0` |
| `plog` | `name=plog finished=1 cycles=71 from_fetch=40 retired=10 issue_groups=10 order=ok gpr_mismatch=0 pred_mismatch=0 mem_mismatch=0 check_failures=0 class_violations=0 overflows=0 credit_leaks=0 channels_used=20/54 violations=0` |
| `predlane` | `name=predlane finished=1 cycles=927 from_fetch=896 retired=10 issue_groups=10 order=ok gpr_mismatch=0 pred_mismatch=0 mem_mismatch=0 check_failures=0 class_violations=0 overflows=0 credit_leaks=0 channels_used=30/54 violations=0` |
| `predmerge` | `name=predmerge finished=1 cycles=939 from_fetch=908 retired=9 issue_groups=9 order=ok gpr_mismatch=0 pred_mismatch=0 mem_mismatch=0 check_failures=0 class_violations=0 overflows=0 credit_leaks=0 channels_used=32/54 violations=0` |
| `predspill` | `name=predspill finished=1 cycles=966 from_fetch=935 retired=12 issue_groups=12 order=ok gpr_mismatch=0 pred_mismatch=0 mem_mismatch=0 check_failures=0 class_violations=0 overflows=0 credit_leaks=0 channels_used=30/54 violations=0` |
| `predswap` | `name=predswap finished=1 cycles=1178 from_fetch=1147 retired=46 issue_groups=46 order=ok gpr_mismatch=0 pred_mismatch=0 mem_mismatch=0 check_failures=0 class_violations=0 overflows=0 credit_leaks=0 channels_used=32/54 violations=0` |
| `provswap` | `name=provswap finished=1 cycles=2333 from_fetch=2302 retired=978 issue_groups=978 order=ok gpr_mismatch=0 pred_mismatch=0 mem_mismatch=0 check_failures=0 class_violations=0 overflows=0 credit_leaks=0 channels_used=32/54 violations=0` |
| `roconst` | `name=roconst finished=1 cycles=64 from_fetch=33 retired=4 issue_groups=5 order=ok gpr_mismatch=0 pred_mismatch=0 mem_mismatch=0 check_failures=0 class_violations=0 overflows=0 credit_leaks=0 channels_used=25/54 violations=0` |
| `rogated` | `name=rogated finished=1 cycles=84 from_fetch=53 retired=7 issue_groups=8 order=ok gpr_mismatch=0 pred_mismatch=0 mem_mismatch=0 check_failures=0 class_violations=0 overflows=0 credit_leaks=0 channels_used=25/54 violations=0` |
| `rokill` | `name=rokill finished=1 cycles=98 from_fetch=67 retired=41 issue_groups=4536 order=ok gpr_mismatch=0 pred_mismatch=0 mem_mismatch=0 check_failures=0 class_violations=0 overflows=0 credit_leaks=0 channels_used=26/54 violations=0` |
| `rolaunch` | `name=rolaunch finished=1 cycles=62 from_fetch=31 retired=4 issue_groups=5 order=ok gpr_mismatch=0 pred_mismatch=0 mem_mismatch=0 check_failures=0 class_violations=0 overflows=0 credit_leaks=0 channels_used=23/54 violations=0` |
| `rolimit` | `name=rolimit finished=1 cycles=64 from_fetch=33 retired=4 issue_groups=5 order=ok gpr_mismatch=0 pred_mismatch=0 mem_mismatch=0 check_failures=0 class_violations=0 overflows=0 credit_leaks=0 channels_used=25/54 violations=0` |
| `roload` | `name=roload finished=1 cycles=106 from_fetch=75 retired=8 issue_groups=8 order=ok gpr_mismatch=0 pred_mismatch=0 mem_mismatch=0 check_failures=0 class_violations=0 overflows=0 credit_leaks=0 channels_used=30/54 violations=0` |
| `rope` | `name=rope finished=1 cycles=7771 from_fetch=7740 retired=354 issue_groups=354 order=ok gpr_mismatch=0 pred_mismatch=0 mem_mismatch=0 check_failures=0 class_violations=0 overflows=0 credit_leaks=0 channels_used=33/54 violations=0` |
| `ropediv` | `name=ropediv finished=1 cycles=1121 from_fetch=1090 retired=203 issue_groups=203 order=ok gpr_mismatch=0 pred_mismatch=0 mem_mismatch=0 check_failures=0 class_violations=0 overflows=0 credit_leaks=0 channels_used=33/54 violations=0` |
| `sel` | `name=sel finished=1 cycles=76 from_fetch=45 retired=8 issue_groups=8 order=ok gpr_mismatch=0 pred_mismatch=0 mem_mismatch=0 check_failures=0 class_violations=0 overflows=0 credit_leaks=0 channels_used=28/54 violations=0` |
| `sized` | `name=sized finished=1 cycles=2641 from_fetch=2610 retired=25 issue_groups=25 order=ok gpr_mismatch=0 pred_mismatch=0 mem_mismatch=0 check_failures=0 class_violations=0 overflows=0 credit_leaks=0 channels_used=31/54 violations=0` |
| `slotform` | `name=slotform finished=1 cycles=4365 from_fetch=4334 retired=12 issue_groups=12 order=ok gpr_mismatch=0 pred_mismatch=0 mem_mismatch=0 check_failures=0 class_violations=0 overflows=0 credit_leaks=0 channels_used=31/54 violations=0` |
| `spinwait` | `name=spinwait finished=1 cycles=2179 from_fetch=2148 retired=211 issue_groups=211 order=ok gpr_mismatch=0 pred_mismatch=0 mem_mismatch=0 check_failures=0 class_violations=0 overflows=0 credit_leaks=0 channels_used=33/54 violations=0` |
| `srd` | `name=srd finished=1 cycles=69 from_fetch=38 retired=6 issue_groups=6 order=ok gpr_mismatch=0 pred_mismatch=0 mem_mismatch=0 check_failures=0 class_violations=0 overflows=0 credit_leaks=0 channels_used=28/54 violations=0` |
| `stall` | `name=stall finished=1 cycles=557 from_fetch=526 retired=116 issue_groups=116 order=ok gpr_mismatch=0 pred_mismatch=0 mem_mismatch=0 check_failures=0 class_violations=0 overflows=0 credit_leaks=0 channels_used=30/54 violations=0` |
| `swap` | `name=swap finished=1 cycles=557 from_fetch=526 retired=174 issue_groups=174 order=ok gpr_mismatch=0 pred_mismatch=0 mem_mismatch=0 check_failures=0 class_violations=0 overflows=0 credit_leaks=0 channels_used=30/54 violations=0` |
| `unal` | `name=unal finished=1 cycles=136 from_fetch=105 retired=9 issue_groups=9 order=ok gpr_mismatch=0 pred_mismatch=0 mem_mismatch=0 check_failures=0 class_violations=0 overflows=0 credit_leaks=0 channels_used=30/54 violations=0` |
| `vadd` | `name=vadd finished=1 cycles=157 from_fetch=126 retired=17 issue_groups=17 order=ok gpr_mismatch=0 pred_mismatch=0 mem_mismatch=0 check_failures=0 class_violations=0 overflows=0 credit_leaks=0 channels_used=32/54 violations=0` |
| `vadd4` | `name=vadd4 finished=1 cycles=208 from_fetch=177 retired=68 issue_groups=68 order=ok gpr_mismatch=0 pred_mismatch=0 mem_mismatch=0 check_failures=0 class_violations=0 overflows=0 credit_leaks=0 channels_used=32/54 violations=0` |
| `vaddslow` | `name=vaddslow finished=1 cycles=546 from_fetch=515 retired=17 issue_groups=17 order=ok gpr_mismatch=0 pred_mismatch=0 mem_mismatch=0 check_failures=0 class_violations=0 overflows=0 credit_leaks=0 channels_used=32/54 violations=0` |

## Manifest of release/

```
40c53e1e5a18f8e30c65cc1d614d5bbc7dc0fbdd4bae6bc59920e83c711c1279  release/kernels/addrhigh.by_instr.json.gz
9785eed6e4c81014005f4d72c974be689667dfade701380c7d387d5bdfaee154  release/kernels/addrhigh.by_unit.json.gz
86f1fd5a311484959b79e84df1df3990f38692eaa8ba6b443bc240bae9793ccc  release/kernels/addrhigh.ccvtrace
6a32524682f196cd6d2e8a94600f523c43e489032bdac64fe6c59dbd2d2da403  release/kernels/addrhigh.log
569f2e22883fad5f0956c57ec734e6afbdd4b8a854e50277425172d6c0cbd766  release/kernels/addrhigh.oracle.jsonl
ed72298a38376419a96a295cd31be71a2812f50da3df103b71690fc24ae8d931  release/kernels/addrhigh.sv-hosted.log
3eaa485386e36d7d8704e06575c3875e96b19e2c1c237530fe7d6f124ef47586  release/kernels/addrlimit.by_instr.json
8893c1a3b9fa3ca2995253327412a9e254deae9d0e9fb2af0b2cbc2ab3cb1986  release/kernels/addrlimit.by_unit.json
f4b22196a2c390189dd38b6de114d7aff99921bc615d4f929d12d2340df0dfbe  release/kernels/addrlimit.ccvtrace
451e42e7b83060168f65eb3989aeb2739e5ad05436d60820cd3ddbbd21929134  release/kernels/addrlimit.log
bc660b0b40359a2c5a2478cb0eb4950b73fd22db50ea76b80052bc195a1920f4  release/kernels/addrlimit.oracle.jsonl
79287ec34c12f61dd0c2c18c956a25f865738188a5d111116762805bdba95a00  release/kernels/addrlimit.sv-hosted.log
46ff6dda8533ab29575c4b113ef0435efc9b9c1d66f47a21c7fef6728f0d552c  release/kernels/addrneg.by_instr.json
a91a846099c9b90e7d129bcbc436717aed9e7703b7ba1b6c0a8f64817ceae7c2  release/kernels/addrneg.by_unit.json
a27b0ae292d1d3858779cecba1a1d0d5ea4fb3b849e135fef35376ff6c920774  release/kernels/addrneg.ccvtrace
cbef8613cc02da714bcfd13557d1fbe02702cf86ccca6813eaef3fe71d61a482  release/kernels/addrneg.log
16f5b0707ae44492a1efd67bb9dd38a7e79a7bbd354fa9207b9e7d150ff2f107  release/kernels/addrneg.oracle.jsonl
19a419def5558124d6efc2d21c4f5d22401c02a38984e03c97a3910361bb7000  release/kernels/addrneg.sv-hosted.log
e59f6f7df3b133ca0a4ab66ce8c20c87a7d1de92e5e0d69a508b27b95c570585  release/kernels/brs.by_instr.json.gz
98f77b2a3f4ae78b9600b4a362400c463636b0b6cd740a9686023b04379055ab  release/kernels/brs.by_unit.json.gz
98b5548730049769c640575bc581cf36f0dbdebcba6fd55cb75340f205dcabed  release/kernels/brs.ccvtrace
6bd3955c5fbdd433e8637186a02b830c837557a86295ca591426a5d889a4893a  release/kernels/brs.log
e3c1cb3379580cf1aae44e8ddc8e846ef6fd661a573cfe0a8d4444b18a14dc56  release/kernels/brs.oracle.jsonl
9fef8577a748894dfcea811907a733656be612909bad8e51f22345c2956ddca4  release/kernels/brs.sv-hosted.log
3251288472ac6b3183a70a71a1685d15ccb06a1319f3d5d28bc30b2e7d5b0536  release/kernels/byp.by_instr.json.gz
439a8dd96514c62e8c21e930d8633fac62999fbc641a2edcc5ecde13bdb935fb  release/kernels/byp.by_unit.json.gz
048b7af9716603f6006b5171cb66e297ea939847023234d1a51790d3cef9f482  release/kernels/byp.ccvtrace
7668a2995a9853fdccb83b75665362a7923263228e3218b8efc354fb9e219424  release/kernels/byp.log
5a03dfa4f3603fef49f1e3639e74e34152ca3ca5ef8e41eb959f8323040fa2d5  release/kernels/byp.oracle.jsonl
bb341747e7ade200c44a51a4cf828fdb0aeeae5630e0b2a4cf73e3e1aa47ba0b  release/kernels/byp.sv-hosted.log
3b4223e5a2e2f731751ddde96814d50bef41d307adf699856720b858e597ca19  release/kernels/callret.by_instr.json.gz
b91201ffedac0d2e0d845243b1ddb7d4f0cf90f9ac77fbb7671b89e03f17f7c4  release/kernels/callret.by_unit.json.gz
f82b124789c973fcc38d22974108893af2800cae5ba9d7d75bff2a7fff2c27ab  release/kernels/callret.ccvtrace
ac9ada9722d7c091a24f0c8fd7aa39dc23a720291a2c9529d24717e375fc6a08  release/kernels/callret.log
9b1d1b50b527f732362f837250aa2f26dabf3e76e16a4794856ebd8f105635b8  release/kernels/callret.oracle.jsonl
8f2da012b846c00f3c0b31faaa93bbc81a8570f4487276ee66dcba5504005938  release/kernels/callret.sv-hosted.log
43c565a7d6499099ffa73788dac71ec508165affd54de0db58c791be46298eae  release/kernels/chains.by_instr.json.gz
e70555be571e9dc0d2a55b4da41d2e8d10f7965c3b16e3de513f595929485391  release/kernels/chains.by_unit.json.gz
4d49e2983bc6e90b8f7f6636dae864e3f63dde80733d34907fe966bf16725a31  release/kernels/chains.ccvtrace
a6c82f9c54e1a07794cb4b5173b3415d0f24a11f11ffc84d96732e4608ac18da  release/kernels/chains.log
26a4cc5c5524c7219d8706c2582c80357dea60be9d6ffdec99dac7d0365e2264  release/kernels/chains.oracle.jsonl
34252a9474a5173678d5f7890ff1827bd49cc9b45b397b87d0be92efacea065e  release/kernels/chains.sv-hosted.log
b97a2f7b3ce60c5f879114b5f4bcbf2520ad9f0d6979c0c7d7ae6027c61d8f2e  release/kernels/div.by_instr.json.gz
63b90eae6ee4f920de36b75406ab108c3b0c9bca2fa6e2e1b9fd04fc8c70ec49  release/kernels/div.by_unit.json.gz
47f3428e3f5d033b7e055fe3ffa81a68286ca1bb7f134e3e136f289346209c35  release/kernels/div.ccvtrace
ec8a0ec5e0d4656c19f96c78e13ba9c5cba670180ea6578bad7d807f327c8471  release/kernels/div.log
71a567b85cf85622631490187563de9a5661099c78a590adff4ed0a0c3d24c16  release/kernels/div.oracle.jsonl
4527d099db68bd8e7846d9dfbcad8a78d24b6819e7647edd45d1cf0ba121eed3  release/kernels/div.sv-hosted.log
c91a8123a20093da91827963fd1ef850345e2811f4a754dc3abb88b333371914  release/kernels/divchw.by_instr.json.gz
c7767de80005777a341ff9f8702d14eed9bd58287d4696f1187d731e0af903a8  release/kernels/divchw.by_unit.json.gz
e1d6452987a395cfc62a985856afeec8522ee2499dd27800febbdd41163fe7ea  release/kernels/divchw.ccvtrace
d7a78a687a6ee3fcce8a5285c4a903c5281f9a1145a137cf276dffced34faee2  release/kernels/divchw.log
58a541797f7a2df0a1c7528ae6a3edec212db90c7d3eb20656806f38b5c10b3d  release/kernels/divchw.oracle.jsonl
121dc24fcad3965166eb2647f94af8d3dde518239e89c6154177764b420ea7a5  release/kernels/divchw.sv-hosted.log
21ffd97e9066173e308e5d6267f49cf838c3bedba8c50cb93e7e202d60e0a281  release/kernels/divtail.by_instr.json.gz
9896486d7c5b1b7b17842007524a1889050ed09b4ab43861522f89d137926703  release/kernels/divtail.by_unit.json.gz
76eb16f9416d13e7a7e9709467780925e7e9288957cf0ab259ad1b1567764482  release/kernels/divtail.ccvtrace
d3548b1cac24f4ae0ea687578d41c599e8a1499ee733a125ac9c3043cdfd9ba2  release/kernels/divtail.log
75f11a75c9b3b336e446140af4579f05b46c363a76b7aab3ec88154a07ba097d  release/kernels/divtail.oracle.jsonl
e9525a411691b5a46a58e2455b3dede9f5c2141170b0c26d2c0bedd91d0ff3c5  release/kernels/divtail.sv-hosted.log
97d1483a50e00ebc8e259346d48c44bd098e3d784c1934fd522e32a96558aaf9  release/kernels/divtail2.by_instr.json.gz
e4213fade2e003e74d69fbbf0c236f17767b77597cbc125218d1a2110015f7ca  release/kernels/divtail2.by_unit.json.gz
6a71793a790fe47c3a8cdbff8624ccce5bb3f4323c7460ae4327e12b031cc720  release/kernels/divtail2.ccvtrace
fc8b0edc143ccfa3288f2492c1aebceddff7b9ad967804f59e5e3c22432454e3  release/kernels/divtail2.log
b2db6b05eb6cf4a0a7677e31d0c6c2952d5cab49d353f0bb1883fe0b2a20ed14  release/kernels/divtail2.oracle.jsonl
65339e0efe98e1d749c50b723edb3d7ae7ab4ef6fff5f31364ce6e4b5535c70e  release/kernels/divtail2.sv-hosted.log
5edf3b0fc68e4f0e59e5bb6dd0b750035edaf5469db7399797897cac351d468a  release/kernels/fence.by_instr.json
b24d9ef181adea716325f350b631658f5faa4a7d57c904cdee129853ba37c781  release/kernels/fence.by_unit.json.gz
a27962a33007f198adcec9d5cd8fac503712d8d674355cefb5ad021a48cf4af8  release/kernels/fence.ccvtrace
f74d7c8752f0049a69123369f612d2014bb32fb45cf867013642719d16b9be78  release/kernels/fence.log
d1d40317f6cf5bfb430cda1f9c0ef676609e59cabe2a11623c42ffbeca93142b  release/kernels/fence.oracle.jsonl
baeb29d213b3c7a3493900a183d925b9db1f35e36869848363401570114c7038  release/kernels/fence.sv-hosted.log
9f7aeebaddd5810acb6f8f9b82ae042e06e49b791101fcc0dfcedbb5a2b9556c  release/kernels/gather.by_instr.json.gz
581c8f05229f97f328ad01178cba13861816c224cf21563097f93cff85dc8b4e  release/kernels/gather.by_unit.json.gz
09cac069b4821bb6ae41d151e8adccfb3a9e2fc6064a3b575530d5dad7ac9aa5  release/kernels/gather.ccvtrace
b3cbfa2d41b29a831c25657f5d27d5ec7641c0a8adbcf1379ef5f1cc1f166b18  release/kernels/gather.log
0413e781d8d6ff578c64eb1f800b7931e66f676d5cdabb97b94a4033e6037662  release/kernels/gather.oracle.jsonl
8ab21baa1dad0760e25dc87c392cae87e933942431b4e10f428a301f9d66eceb  release/kernels/gather.sv-hosted.log
4814b01dfe5b8ec353bbfb9e9ea99c519af4591c081902128d790dd4ca17e5c2  release/kernels/hit.by_instr.json.gz
ae6c23d1dd0748d065be9241d88bc1110ef6fad2d08cc2b433962b5734999d07  release/kernels/hit.by_unit.json.gz
648fb68dfa7abd02c326a57b805a77faf7ee3e8dcf1ee9576533a784198deae9  release/kernels/hit.ccvtrace
3a2b270b63025df78f992f7ebb622dea71c72e29b7fa68a5ddf7ba8d4e469f14  release/kernels/hit.log
7ba9603e0088d9164de6528f16ef6a7fa9ce5821c8c12b52cbb3734e39b9fd52  release/kernels/hit.oracle.jsonl
29d658c571d67509d926834deaa154cee94b146ea78602e2a9d0f911a6ae2adc  release/kernels/hit.sv-hosted.log
e37bfdd359c7d41ae3787331b91565e6e4dec295f625d5195f900e2b96f6eb76  release/kernels/lanectx.by_instr.json.gz
853eeafedbbbb45604a7c8aa414aa41f9608d30c092f3b6ef19f4e2917d89873  release/kernels/lanectx.by_unit.json.gz
4ee58faa10bc00135a6e8e288fed75b2ecd90743da51c12a20c9c468a3110b44  release/kernels/lanectx.ccvtrace
367b107dae15eba32edf40b66402ed1cb56f371f7a5ae929a01f6d0917d940d4  release/kernels/lanectx.log
888551babf540db8e3025b82e65ca655013f93eba3c8a65689d069d52a7e6039  release/kernels/lanectx.oracle.jsonl
d9e6b821219471b074ad5995290a1243b4faf696d2b27ec68ad27479e41d5b03  release/kernels/lanectx.sv-hosted.log
6b8eba7e854bb31a52cfe1991f25055ce9f67f9bf2356d2e294f1d0ef778bbcb  release/kernels/lanectx2.by_instr.json.gz
3d35c3383fc5fc39b7776406b941317f08c78f747719202be1f91bd22da10428  release/kernels/lanectx2.by_unit.json.gz
18e2182e0c3832077858de80b3f8c9da89a7a331d6c867184c850e52b1bbbccb  release/kernels/lanectx2.ccvtrace
ab282932434000037cfde47b48fc4d684b38a4bb05dcf9a42aeae74758cbed3b  release/kernels/lanectx2.log
45c13056dff5c73ed0c9ece56cc36f929bf335322193c7d5eb38710b1d1dfb02  release/kernels/lanectx2.oracle.jsonl
a8fc745748064ae832df31a8458cce0068f3ce2f48fe45e3481b3c0d569c8b51  release/kernels/lanectx2.sv-hosted.log
1d6166b68df123d418481e73c40eb6e107d30860466f19eb4e4eafbfaf241beb  release/kernels/late.by_instr.json.gz
24f5d3cca27d4268e3b0aa9901d8603c479c49162094847a1b2759aebe157f9c  release/kernels/late.by_unit.json.gz
1af2340e3e96ac71ff2ceadf30b63bf5f5f5b9c618a06d1bfddad00da8bd16d2  release/kernels/late.ccvtrace
995caa6313c0e475465d6b95bdb90e5c2709ded10431e434416602d3d4db7277  release/kernels/late.log
86084f6bd747a2cf32acbc0ebd96ebd3e4ef2d8d9e21be49e3ae49290d7927f3  release/kernels/late.oracle.jsonl
6ae9d8460191f8a8b1de8e240046ee390424f8f1834a6824d1da93e25db0ad93  release/kernels/late.sv-hosted.log
5641fbe3b201e384382d59cbdad2da7fa4cb22c76f0b3fee85465a5e704eeb90  release/kernels/ldpar.by_instr.json.gz
29aa5aae23486044cffdb31f3326e4a297edfe7d5b15ce4b18f01f2ba7b3d359  release/kernels/ldpar.by_unit.json.gz
8a6e697257e2009c69f0b0dd98ec309999d811c307ce39a6ba1d64ceb7bad667  release/kernels/ldpar.ccvtrace
14b38de87105695e44657510d40f66c02cba1cd4c7c79c66ff37f099e2b59add  release/kernels/ldpar.log
8ac08538e9c807637babd61b31e340f7461878ada31f0c0b83cd66331cfaf486  release/kernels/ldpar.oracle.jsonl
8fa2eab1c74e057af586f31b2bb3dd35f142772983602d4fb22d5250e9785460  release/kernels/ldpar.sv-hosted.log
8264979eaff18106580710920ce5ca3c2accca2b7be8d0eeb3fc76229766ec50  release/kernels/localsp.by_instr.json.gz
4e3dad93140eec41c1ad29b0aa79b1402b8679eb8dada037e37da66185b83c63  release/kernels/localsp.by_unit.json.gz
2b1121ba37e95ce42c2ceb906760a2446099d9bdee4e03669c4da0138692f37a  release/kernels/localsp.ccvtrace
4705bfaaa11e3fe020af3b542d494eca05506dbaf34e17a344803a21ebd97829  release/kernels/localsp.log
55e3c9f36e7f7d38c0ddd38903aff4bb4509ae862015c592e6b937ea258042ca  release/kernels/localsp.oracle.jsonl
d433988e6df7f543943d27d38103dd8e745303bf20357c5f61b88098cbf820cc  release/kernels/localsp.sv-hosted.log
9f0827117e388d543c9d8f2d5dcafb78ad98a71c3bc0854d65280b1a9b561aef  release/kernels/loop.by_instr.json.gz
554b330ea7c87c402b61336496e53122af1df351fbd0e54b45530c4c4366977a  release/kernels/loop.by_unit.json.gz
fbc0a4082a57ff1f9cedc7ed6632c8f803564a37c8fcc84c5c1258b8397e373d  release/kernels/loop.ccvtrace
13984737b1d2a2b74390d4237cb0f5639efbac2f48845fd5b49e6d8a13f28b1f  release/kernels/loop.log
03ce5920c06c93e93516d8e53c3f7169f14e3593de204eacceffc0b8a3e32016  release/kernels/loop.oracle.jsonl
41609e57eaf596baa45c0fcc406ffa3ea8309ffcb92283f9a483688710767532  release/kernels/loop.sv-hosted.log
c9d93bf3491d357729ac6ab91112be1aebfec61da57befeadebe331dade7bea3  release/kernels/merge.by_instr.json.gz
f84c77a2d538d8459f25668e77c191f9dd3faa43cf0a994e5b74df1067bc8f32  release/kernels/merge.by_unit.json.gz
0504b935f44eebdf23da2231af56b314abeb8d4c07745258d02d4aeb8e2ed85a  release/kernels/merge.ccvtrace
79c7652ae63bc99daeaf752144a2c95a77e332d4ec6f8f56922603cbad4dd9ec  release/kernels/merge.log
f96d28815f8756b1f5a45ded53e6170883d2dfa10f9eef0d14b8050b1318164a  release/kernels/merge.oracle.jsonl
fbce61f12a1d47740ae6f87304e0324ced859666c04f63bfd3554a6c4a431323  release/kernels/merge.sv-hosted.log
cfa71afda04f826a9c4f1447991644cd5f10411f857938c54347048031e827b0  release/kernels/missrun.by_instr.json.gz
90569df11704dc871ce7581274f6c1d28f62c676404c20732bb2329bfc9e224b  release/kernels/missrun.by_unit.json.gz
7094390ff02b065819cc9dc928f8646dccb61d9a3200e43b866ba8697307d907  release/kernels/missrun.ccvtrace
51991a9d75e172073ccbdf80d0ed90c5414ddcb18448c7430a54777d38e0d345  release/kernels/missrun.log
531bdaf281e5590774bd2775427f25e4cc0419cf8e3d5b6999843ffe9ef87258  release/kernels/missrun.oracle.jsonl
6ce46c135278b352f1dff801dc2c61a83010338eabc46fd81f4ca5c28e795c3c  release/kernels/missrun.sv-hosted.log
55435f5da127f600a1487b739008e51cea6019f777a2e625a2139ffc67a212cb  release/kernels/mload.by_instr.json.gz
98ad5704ab0240a38deac0c155c6ee924fc13e32cfc3a4a54b34d4c860f15c17  release/kernels/mload.by_unit.json.gz
4634fab679dd79287efacbeaca89a23456745ba6cc074f2c6a764ab60d3f0948  release/kernels/mload.ccvtrace
b1405c126a112b8346e526ebefc4569d35881e0ac1ec760ec457458b44418c67  release/kernels/mload.log
8000e477b9a95dfb9f0af964e8346acb9d36f1358fd06ffc4ff7cf599d2b8868  release/kernels/mload.oracle.jsonl
21fac6fcc0e9ca5f5e819345ca052b70d41e30154842cf755006d21107d7b81b  release/kernels/mload.sv-hosted.log
50c744918de5e42459085bd3d40c07fe2f36ffbbc9f2de5c824ed490ed06dedd  release/kernels/mlp.by_instr.json.gz
cdccb14a3b52e4a62318de0935963c477be9a8a654b404885d250e814aaecc18  release/kernels/mlp.by_unit.json.gz
760db9603526e904796031e5a77def64b37ff19a07b6778a2f78b82cca6e18ea  release/kernels/mlp.ccvtrace
2071d68ad0024b0bd28ce1266f819cfa53855a7670bb1988e710fe56baf2d1f3  release/kernels/mlp.log
138d282f88d56c8ad648a91af0a983254b55d9fa22942c00d47b327f516a6e44  release/kernels/mlp.oracle.jsonl
22dc534701f3d3b1c1f6b9415bc27a85b2fdb1284c77953763276930b4094d1f  release/kernels/mlp.sv-hosted.log
24777ac208cc6c1eb255b93f61a11df7d6b136bfddaed10ef0453683d74e3e12  release/kernels/mwmiss.by_instr.json.gz
f359be32b380803e6d438984236274a803b7fc0c62026c788d23f1e1bc4d8abf  release/kernels/mwmiss.by_unit.json.gz
cc00bcad0c9fc069433259e6600710060de9dabd8aaa6631a9076e3fa5dd668d  release/kernels/mwmiss.ccvtrace
359401ee979d2c69ec57ccae1b5aecc7fcedca97e9340e1a79e128a72bde04ac  release/kernels/mwmiss.log
8abe8e8997456a2a6711ee72da54d854b24e20abbdab28e4b7271c0d28418de8  release/kernels/mwmiss.oracle.jsonl
ab3702fa2a235873192dad69a1f4fd35ae8fd3588e3dde61fd96a4cf2a8fa3e8  release/kernels/mwmiss.sv-hosted.log
3c13a04581da5e66a96c96358ece35b717432bec7a4f26caa569893bd9381019  release/kernels/narrowadd.by_instr.json.gz
455e690b7d7192b684a4a44313194b955e1146debb4a3a6992f4d1c435741840  release/kernels/narrowadd.by_unit.json.gz
7ae6622ca9fd43164d0774ea693d09e2959d3880cb019530d8dfa104685c3c9b  release/kernels/narrowadd.ccvtrace
658c3668cbfa5883c439069278f5837f9d2eb9e060e6ec48e7112bc4380cfe6c  release/kernels/narrowadd.log
40a2cf629853dd404bb06b4a07e35abde3d12efc13f26ffe28f923daf2994574  release/kernels/narrowadd.oracle.jsonl
43b5134e814411c43f0e9a1c2c56182c01600884f985ccc5097b42d5e17749b0  release/kernels/narrowadd.sv-hosted.log
3d42b650d9a5d5f55b1478d16eb0034a6f77efd43227a64d32146d6823c4b58b  release/kernels/pguard.by_instr.json.gz
e2812389e21bd23ce11721cdc8d70707e48ad948df78cdbfed4834032839e7de  release/kernels/pguard.by_unit.json.gz
8e0ddf61510cae358b25b6af738fbf7b08c24b8c304d8b702321615b3a8cbfcf  release/kernels/pguard.ccvtrace
e6a15aef5608814964ad5ba99b053eb993f2b9e156396a44a517cd9d54f02c78  release/kernels/pguard.log
690e56f1cb8d97cbf67124b7dff3ad0a90cb8981814cd1709cf0cd0e035b3bd9  release/kernels/pguard.oracle.jsonl
5b5fd8ccdd03937d071b7585da9253fa84adcc2401cc5f637e849f27cb7afbd6  release/kernels/pguard.sv-hosted.log
23d67c80b91a4d44cafe2449452bd7e9958d3ac44aa58914410af6337cdf9d10  release/kernels/plog.by_instr.json.gz
3db6a4be99afa0fbf76fdbac20a328f709b542ca4eae2112ac7c125588593b3d  release/kernels/plog.by_unit.json.gz
77fdbe92376d1a86e4c8f2757b6755389303521cc1aba3d5e1500a26c4b99567  release/kernels/plog.ccvtrace
33da945286e445b95e6bad4fd9e8fb5b60f33cc48afdc5ea11f57fa4c3b830ee  release/kernels/plog.log
c230f13f2e1082b306a9c5ab7809ff36cf5c1b2e47dca6b7a71f741524d403f5  release/kernels/plog.oracle.jsonl
3b52721959c36a8d6addf5c05b2af0feb96b452a8b64ee82ecf94bae06f28a64  release/kernels/plog.sv-hosted.log
22db68dfa286b488623acf2394c6e01e6a35a165553542b3e1deaba2882b76cf  release/kernels/predlane.by_instr.json.gz
12c561315f5e70614e8483752a7e28cc6ec1d4ee368493ae1468dd9d11a77f0b  release/kernels/predlane.by_unit.json.gz
a6bda6129d8640d9bdaa22f7144c00f5e4ce5a11805fe22deb6bd99746ebcd0f  release/kernels/predlane.ccvtrace
8d5ed1a3754a5727ac596f896b3ccde91449540438806d9c7e8140ba08eff06a  release/kernels/predlane.log
c45f4177b9e84fc8a6e36b13534a0c7636eb30a3f8531847100ce5e23bf404b1  release/kernels/predlane.oracle.jsonl
4f1860760922c84884771326039d7c8b62ccf6164db33ea99cacb744472ac224  release/kernels/predlane.sv-hosted.log
3ecae6e2bc1ecb58eb627f08f3e6f69d411f560ce00499aadb90db0655a567a3  release/kernels/predmerge.by_instr.json.gz
2ddd1d6a0044d2e9785f3b626641883b6d6e24691aea560a15030a9e365956af  release/kernels/predmerge.by_unit.json.gz
08329254985a14685eab34a242a972e0d5197600b2dab1c453004476995ba68b  release/kernels/predmerge.ccvtrace
d83664330a6199c7e39a1d0ad075d7a3957ff7d83a87a5396f80124f03fb2bc1  release/kernels/predmerge.log
6c737c49434bcd08e3e0814c8b1dbf15c586ae74f7929ba3148ddcee2c62c845  release/kernels/predmerge.oracle.jsonl
27332f20cfbb9e9f606f530fd8a5c4f191a02dc63d182379f2e752ae9692b6e9  release/kernels/predmerge.sv-hosted.log
54365a6579b82cb4d5f7e01e0b8f9e5df7556c0ed6eff51171422bd647cf06da  release/kernels/predspill.by_instr.json.gz
c9c62ec75fbfb5adc9d229f5ccfd4624ba97da4e7b4f59dc7f2f20affd88671f  release/kernels/predspill.by_unit.json.gz
42c3806fc01e48386a56957e117fe1d4ad46180569727f0826a20ac47ee6c4f6  release/kernels/predspill.ccvtrace
766bcb71a99d26d78fb17665426dbb0d6416dc2fcc25d27c88c3bbdbcf2e10aa  release/kernels/predspill.log
b7c84c6478117ffa0f06da0e6ad1e4628e2683426a7911080810e78e06a5242e  release/kernels/predspill.oracle.jsonl
9e79a271c01baf3620e1103faf12a23891d9be0f1c7a0de81c588838c6299532  release/kernels/predspill.sv-hosted.log
53b64648a0495054acaf6b5520be20e98b88f27a24e93b96d5dcd9e4b0464246  release/kernels/predswap.by_instr.json.gz
3f594f904eac7d7a855098402b3af9d60811368b2a956c7587f416d423fc34d3  release/kernels/predswap.by_unit.json.gz
0c1a843443169755fc108bfd527732178265a3a038f714e078e857a0541c6da2  release/kernels/predswap.ccvtrace
76083b8f7b203cdd40beb6acf326f17ee35212ab783bdb3610b24a16675ac64e  release/kernels/predswap.log
a6d4f7ed517553816d889c7c9eeb6bcfd1f6c973fbf682ecb69f3c2de619f7bb  release/kernels/predswap.oracle.jsonl
754e05367933cd73496aedcadb00fc17ce9fd4ad3a059d9b7c7c41c9e1a6badb  release/kernels/predswap.sv-hosted.log
f0bf8b72d89548bd2e9f33e7ad1bde14875b7524fda05d7aa2dcf3db16a9ec8f  release/kernels/provswap.by_instr.json.gz
3c41ef851ef85825cd2b4b4b100f20c4d6c2469cea14b7081ac654f99625c539  release/kernels/provswap.by_unit.json.gz
cf9b2ed602c5ab4cb91be16cefe19eb767bc86f59ca744ec1445975deb291b55  release/kernels/provswap.ccvtrace
9222e09f4a4602526e41044e2e276633e7b00f78fb4f19bccf1e314e1ebb6c21  release/kernels/provswap.log
c9c32a793d54cc7401477f582487f7e8b345b2669a75337b8d6327120d98e5dc  release/kernels/provswap.oracle.jsonl
5adcf9fd25846a7e1253e0d68e088be4f64aa60e35f853867ca20f19c13b9c05  release/kernels/provswap.sv-hosted.log
a3fe9c5f912a696c460e584977c869cbe92f31b66cc83e94da4fb0197cd8fcdd  release/kernels/roconst.by_instr.json
543759b72b201d3c27db4c00b3ddc307fec9c384d29c7c8bf2451587365078c4  release/kernels/roconst.by_unit.json
e1a684f96fe305bec7376091124d596b3f1e2311f387470677412691d00b1d36  release/kernels/roconst.ccvtrace
f1f74a5309bd4328ecb3b70cfee5f48c4855b76769921ccc3a25a1ece7203d74  release/kernels/roconst.log
8087c0671de620162881aecd38cd6114b78e7be6bd71201e3ec02c9a2e2e750e  release/kernels/roconst.oracle.jsonl
842240140c586020419e10bd2d6749352a16262b1bc8f63d044ce07afbe35f1f  release/kernels/roconst.sv-hosted.log
b5bea8b0d87da8c6dc49ddb4f14df19134c1d9cb454440a2382d65caba163a46  release/kernels/rogated.by_instr.json
faa28edb7ad5765530d1cf429c21e1411822d50376bdb69326f3c51abba2fa19  release/kernels/rogated.by_unit.json
bc62797c4ab3e8bcb791bcc6f4b6ea6d90b913dc2bf8ffd1eee03d4433e74c58  release/kernels/rogated.ccvtrace
ee551e4ac3f55e2dd154743b5ff004dc7ed33b635e8760eefaa1e926b5df4be6  release/kernels/rogated.log
7cd02bd4cceec5a044d6b4d6a80df1e68ed0ae71b0b2a953143636d5b809ea6c  release/kernels/rogated.oracle.jsonl
2562ca063a9b5efde24c9043398192cb16a23cb421029756c4ad2e4156150254  release/kernels/rogated.sv-hosted.log
846098fd8a53ba61d280336c7ba91725ec14a57e0a485b55b3bc6abcb0638ece  release/kernels/rokill.by_instr.json.gz
0e7dc5e9a6bade5bfd66cb7fbb14e434fe05c736107d4b62eb72a9891943b830  release/kernels/rokill.by_unit.json.gz
459bf5c06b4fab0a8097feb51e148be56e3562e128366ef2a0de4e6bfc767276  release/kernels/rokill.ccvtrace
e14a22e59a37a1023aa62c29a75dcca8a672f2c36fef88403f81564ca27a2a62  release/kernels/rokill.log
94efcef96af469a512d346ce61623980fe86383188eaebd55120f716db596f14  release/kernels/rokill.oracle.jsonl
34aa8c563a7c2ab13b855b2eb8d9804cb1bca8a9a3adba5150406c6408fba80a  release/kernels/rokill.sv-hosted.log
3055de0abee640a539b3b63f3957c947d081270d8eb7f757f46f9e0f520761d3  release/kernels/rolaunch.by_instr.json
8f14ef72ef93ad34e3748d8b68033c4f388a1b7f28f4685a83e0af26300da921  release/kernels/rolaunch.by_unit.json
fba440e00a2db687c7cb42d10654f56f2aed156771a8f64fe73dafb40bc18cff  release/kernels/rolaunch.ccvtrace
20d7d2267cd550d219d6a187aa762dac96639e8d99621b92d2a98a9ffac487c3  release/kernels/rolaunch.log
e7dad585c3e70615de04330fd03f4f282c29a005dc1732a35655fb261d51139e  release/kernels/rolaunch.oracle.jsonl
fc8f4356ef3c17477222c371dbbb466abcd52fc923eee2e8fbf5cf76317c162c  release/kernels/rolaunch.sv-hosted.log
a3fe9c5f912a696c460e584977c869cbe92f31b66cc83e94da4fb0197cd8fcdd  release/kernels/rolimit.by_instr.json
bfd79171f041cfa00dbcc495f733c9503e4c6585dcda8bdf735242f664188a44  release/kernels/rolimit.by_unit.json
9982c4cf071c4e1cac5d09bb2e5d3c968ecf0b01312d75c5c93a278621f3af05  release/kernels/rolimit.ccvtrace
851e8ef3de140134fa1f0b8ce9a259cabb363d24acb99b33424e781402986693  release/kernels/rolimit.log
1c5bc0cb8e8b2e69505fb5a551a16d5d10c56f232b88da7a27e336ad7d962de2  release/kernels/rolimit.oracle.jsonl
eb31a392e4ede5a308d2bc2a4c1e35049832c43151f2cdadad7f16467383e120  release/kernels/rolimit.sv-hosted.log
d87062e5e3cf181acc4fb993aad0223b03710fb0bc6cc1b608ef9483f16a25a9  release/kernels/roload.by_instr.json.gz
9b4625721ecf41197286a4d295b17e34bcd0a620ac985807715ee401f824879c  release/kernels/roload.by_unit.json.gz
1232f337c38a1a9c6c9b771aef300fe985aa9c55a1ffbc9ecd5c96ca3adc78d7  release/kernels/roload.ccvtrace
487926ef38243252d7f3660cc4ae4d81a7cb390052bb07392247edb233566897  release/kernels/roload.log
f7c1309cc9764769fb5803f6fd0f2f5e1eb418f2d23fbe5e17cf5f9106869fdf  release/kernels/roload.oracle.jsonl
feb6844ef9728388c44b7b3469a036a75d84356fd9b8393dc9532929e7f869d5  release/kernels/roload.sv-hosted.log
d8145a0522b677bfd1c4b253fccc7fbaa7688661823808f1305e5186df1d2531  release/kernels/rope.by_instr.json.gz
570be7548858c28296aec2f3e53b1e8086892d1a0b9032faf6ee9599216bce3e  release/kernels/rope.by_unit.json.gz
ecdbbab928d510a8e94936ecb3befccd859b1663a1e61af8e7ad1ba83f9b00e8  release/kernels/rope.ccvtrace
b8f025b3c43de1893a70cf31b877c1d01e179e91b1bf49c5ec58304c2105bda1  release/kernels/rope.log
d55f9efae392dc8877c102c01c0810e7654b666b6ede386328108164c6cf88f3  release/kernels/rope.oracle.jsonl
3272392ae5da75e4757afdc3a58289b16a00984d178e3e075ee31d73348c4c54  release/kernels/rope.sv-hosted.log
33770fef99de5c0dbe072068d9a1d858ec18401f1cdb726c325c3d100af7d18f  release/kernels/ropediv.by_instr.json.gz
43dd29147571abed9d3475dbf1bc23efd0649cd7dfac8eba3c251569837a9687  release/kernels/ropediv.by_unit.json.gz
2a4c1fc727f3a7f4a7c2f2e494360cf6072bfbe78f1040b4843feccef28ff41f  release/kernels/ropediv.ccvtrace
8cada2dd2f64611f4a3588ee8c88a3ae77c5a01f0b50140ae599e51293707942  release/kernels/ropediv.log
10c0ec6ec18b7b44638c790033109198c079d07c1537bf193353ccedd00a920f  release/kernels/ropediv.oracle.jsonl
c52c803eb2ab2a70e884b182c1a1712e76c8cf519e358c792bb4e0ae4130aad7  release/kernels/ropediv.sv-hosted.log
565ff81a15b5f1f8018ea09294599f6186bbe90d29510a4e719d05402b20479b  release/kernels/sel.by_instr.json.gz
b52605404b44e288af192939483ee6367373a88236a08149970eeb0c76aed70a  release/kernels/sel.by_unit.json.gz
e389fea6d462ab2ba80d76520712eaac7f6d472a03e569e5c49b8ea76e2231f2  release/kernels/sel.ccvtrace
4c2ca08157c074760bd48e4c0dec2ed0af3cfbe5fc351ac00c8febe8442cc1df  release/kernels/sel.log
87f6a81e8afa004c8039bf2f61c90176fcf29ab29bb17ac44aa016a5cc8438fe  release/kernels/sel.oracle.jsonl
772c72a880414f205ec4e12dd230a94289fb7b26e0e688e7fbb12332401ebfd7  release/kernels/sel.sv-hosted.log
bb6d8956eb518490175c243613198ed1395e7ecab745b998ad5161d9db74b731  release/kernels/sized.by_instr.json.gz
1d8bfdd6a44b4dde5f69a22c230ac002e1ff40a19e841aabb5aaa72d80898703  release/kernels/sized.by_unit.json.gz
eb7f07bd8e571a54944baaa78c82ea2b1ac050cfdf5b7c030d5e6588cd817c73  release/kernels/sized.ccvtrace
8dd8a286076e9a6ef9c07c51ffb548bb13c349615697e72e8110f89329cc05fe  release/kernels/sized.log
36d903ba1618bd1faa437c9812a6ee6c0c966a63196c796267d74bf2695ebc3d  release/kernels/sized.oracle.jsonl
408464c545f1a55e20f74e7c53cd7d906541ae87f4c5bacc15cca385bdbe36c8  release/kernels/sized.sv-hosted.log
2c32f36277d83e1b38735f8d26ad090cad9cca54db8f0a1d1db5458eb54e9299  release/kernels/slotform.by_instr.json.gz
f4192f7eacc82fdc67a7eb1f89c0afc37320b05d1258e8ecc4a62f5c2c2e3fc2  release/kernels/slotform.by_unit.json.gz
449ceccfef265b69357e241d8e3636233f2a9e27767fe0c6595b116ca5a2262c  release/kernels/slotform.ccvtrace
46b0a1732511d8740be8bcb2a1f4b8c6eb021e5e01396fd96a68ca34f78fd15d  release/kernels/slotform.log
8b61db7419b18cea8a646fb628218447e72e84a18a9891ffb73b441736138ab9  release/kernels/slotform.oracle.jsonl
78484a54c0d40ce18887f9a9c8619660105a740c20b5c47215fca4bb4dca280a  release/kernels/slotform.sv-hosted.log
b146475c31d40b265da6f70c436a9d56854ae391ef30a4b1b258159dd781dbe7  release/kernels/spinwait.by_instr.json.gz
5b80a9fb5afc59f246f83a1bd36daefa884fc6c4175e983f673031e1644ef5a1  release/kernels/spinwait.by_unit.json.gz
5ffd31e0083ca78c012dddedf47b2ddc3552d6faf11bfe784c032e053280fad4  release/kernels/spinwait.ccvtrace
485e00b353884357930b058398e02d879eca0169ed782e634b193e76ae3385d9  release/kernels/spinwait.log
868920637236c878b33779bd450439466fc3626996a3164573dc11d437d5c709  release/kernels/spinwait.oracle.jsonl
892615610b3684dd8dfe4e769ff33ebaa1d8d78985a267a33fe7ffb091c87365  release/kernels/spinwait.sv-hosted.log
112ac7242f52bc1454f0d03f25ce33dd2e778bf34e655c1dc1c98f0b438506d6  release/kernels/srd.by_instr.json.gz
8c5e073dae3bd25fc8d50fc18a4cb12a36e9c85f2b98400eb75401e58ee8f325  release/kernels/srd.by_unit.json.gz
437d266aa25ca5cf30503d6a900e9d511e60be91afdffe60b24f8ca853eb33dc  release/kernels/srd.ccvtrace
bbc15a7231660a82be15865cb1815121f7ddcee7007a9a89914e22d48ddf9943  release/kernels/srd.log
b08eb5e3673cac7eebb8b72af5ed3783c8e70a9e96592e76bf3722551bc79473  release/kernels/srd.oracle.jsonl
a7ae72e7fd1d80cb90f12e40515b48a1dd0bede28344b51ec087c5714b8183ed  release/kernels/srd.sv-hosted.log
7b8d2e3c860d44d478973bc68b7fd73613db3bc58447aae1addbc340dc84a6cc  release/kernels/stall.by_instr.json.gz
eac20d125afcf86d5ac0cf2feb29aaf8a558b16a98bd560220bc5155b0ef555c  release/kernels/stall.by_unit.json.gz
c9646c0992f30d0a191d03c70e3ced4fe2315a59247600b9715c77a4fed470cf  release/kernels/stall.ccvtrace
8033ded023d08ee7fcc951baaf9df96d3ccf776b541fad079d5a7828757622d6  release/kernels/stall.log
500db2c482b07a0706583422cd68878301d0146c1f872ccc1f11bfdcf5c993ef  release/kernels/stall.oracle.jsonl
ef684081585deb43a414d208f104cdfaf99b3e3821261376b37d945d14dc06e5  release/kernels/stall.sv-hosted.log
750d229ab6c9289c8ea2050bf1966898d7c0e9155dddcaf7d8827efa84f2b807  release/kernels/swap.by_instr.json.gz
3529c181e37b6621107dd443abb4fbac637da18a7715e604ebc7b7c5591b252d  release/kernels/swap.by_unit.json.gz
a31efe076681cc8ecc92f47fb3111f989a53c4bcaf977c9f3abbac9788876a08  release/kernels/swap.ccvtrace
1415b7ef18fe0d853dcd0d6a3ae994bfa164e027953ac6a283a9c775623f4add  release/kernels/swap.log
3658a26316c1ff7bc1744304a42f736e930fcde2865c8913e6cc67a22ce96667  release/kernels/swap.oracle.jsonl
3bc6e75557b8b3ae78473d33417bee35457e0690e105a6c1dd95e90e6a7a8739  release/kernels/swap.sv-hosted.log
e16082cd3d83d786b8610477716992a7dd015fc6cbcdb3622fbe7fd722bae188  release/kernels/unal.by_instr.json.gz
62cc824a861b3ae4d66c58ea410f3abf8ff11405aeaacad374ed27d792dc2ba2  release/kernels/unal.by_unit.json.gz
46622995e02c0910880dbc2f7f0d6788ab8cab9e8a4a87031bea3c9a76cc1c71  release/kernels/unal.ccvtrace
74849092f3d1e283d9ad3b291c1115cb46dac32b768eae6791f9cd70b6a2f47c  release/kernels/unal.log
c3d484bb160657a563df983d9a2532eac27f556636617960aa1e72183ac2b299  release/kernels/unal.oracle.jsonl
6df7013bc384feea8abafc12e7f58571406d081ee4bd8e24ba4928a84a7f66bc  release/kernels/unal.sv-hosted.log
45b11b3210d143828e7535846a3e480ebb82ecbc5fb22802762962d602ceef94  release/kernels/vadd.by_instr.json.gz
09368cd5144ee2dbae68c9146e927075d754c6e37bd864dafc21452b63096adb  release/kernels/vadd.by_unit.json.gz
96950677a640071d3325fedbfccbe4e35f5a7c7e82d4d00c31ec253a38bec8bb  release/kernels/vadd.ccvtrace
034e4d31ffcc893371123c1169840c9c7d3bda969f3ae45650d928937827305c  release/kernels/vadd.log
0276b6d0611a4bbcdc004ab3987214aea138245bc7217504147331689a9c0880  release/kernels/vadd.oracle.jsonl
2b43f7c4c35ecaad138d70d7203883ba35b90086a0efed4a104105a9bae0ea59  release/kernels/vadd.sv-hosted.log
3b737aad5e62bdfdc30f4e3f9b7c7dfc12e59bd42ec379429e554a305b93803a  release/kernels/vadd4.by_instr.json.gz
be59138912ed75e70872f5e98fa7c21066da4ec7c4b81f99008f6cf06a441d07  release/kernels/vadd4.by_unit.json.gz
99c6e52f0b5531096998c32f72ff5681fd195a636de8d19200dbbf328bf46012  release/kernels/vadd4.ccvtrace
4b729378baa43bf3f197e0850f1e75c96880d78f4de9c7eeb9ecd5326740384b  release/kernels/vadd4.log
225aa18fc9f38aa9ad615aa11de254337d59fa705877553d873062c68366e0db  release/kernels/vadd4.oracle.jsonl
ccbca7b4fe79f06d625ab7f77e52e50e5a634dd3081c2ae8b76bb7c5fd566403  release/kernels/vadd4.sv-hosted.log
436f51c307c5d1c4dde04d9724cdf6514403f80a7f2bb0e7a104438ed39f336a  release/kernels/vaddslow.by_instr.json.gz
6ad75e94ddfaf122ebd6847ad00c5f3dfd80fd058a01a91832fbd61cd0ff8901  release/kernels/vaddslow.by_unit.json.gz
3ee904ca1684d50af38dea9b42cb6783ff43fd38a3fd9f58cf8575ced9cc0724  release/kernels/vaddslow.ccvtrace
0bbd1edf035d26c2cde7cc7d06abb638ee59e2e8057fd1e4c2927007324977fc  release/kernels/vaddslow.log
e9e6218e8b8450e9f9ff6b39d659c994a1e51c527a0c5bd10d18b5658ae0e344  release/kernels/vaddslow.oracle.jsonl
ac1c09290c55aa88bf03e02d3fed611ec8aae685d9052a74b774b791c4fabf09  release/kernels/vaddslow.sv-hosted.log
8dc5e27e199245420ffc02e29af4836424434a7449e9f208bf5d83feda67ca63  release/verify.log
5b64efcaa59f79d1195d81bf2258b07471e763766cb6e0afab614c072ac3aa09  release/wiring.txt
```
