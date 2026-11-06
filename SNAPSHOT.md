# Snapshot snapshot-2026-11-06-2281ab8

**A generated, read-only snapshot. Do not edit or merge it.** The source
is `ti-b2` at `2281ab885bf97241169f1e69a0ee87bbc00eb458`, and this branch is rebuilt from source by
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
| Source | `ti-b2` @ `2281ab885bf97241169f1e69a0ee87bbc00eb458` |
| Built | 2026-11-06 (UTC) |
| Gate | `tools/verify.sh`: PASS |
| Compiler snapshot | custom-cuda-complier `release` @ `e533ecdfabd1aa267e4cffd49a4d7e1e8c13b263` (source `45ce995c923e7267feb71d87f8f9c5edfefcf0df`) |
| Verilator | Verilator 5.052 2026-09-05 rev v5.052 |
| Icarus | Icarus Verilog version 12.0 (stable) () |
| Yosys | Yosys 0.33 (git sha1 2584903a060) |

## Kernels

| Kernel | Result |
|---|---|
| `addrhigh` | `name=addrhigh finished=1 cycles=86 from_fetch=55 retired=5 issue_groups=6 order=ok gpr_mismatch=0 pred_mismatch=0 mem_mismatch=0 check_failures=0 class_violations=0 overflows=0 credit_leaks=0 channels_used=26/55 violations=0` |
| `addrlimit` | `name=addrlimit finished=1 cycles=1072 from_fetch=1041 retired=5 issue_groups=5 order=ok gpr_mismatch=0 pred_mismatch=0 mem_mismatch=0 check_failures=0 class_violations=0 overflows=0 credit_leaks=0 channels_used=27/55 violations=0` |
| `addrneg` | `name=addrneg finished=1 cycles=85 from_fetch=54 retired=1 issue_groups=2 order=ok gpr_mismatch=0 pred_mismatch=0 mem_mismatch=0 check_failures=0 class_violations=0 overflows=0 credit_leaks=0 channels_used=23/55 violations=0` |
| `borrow` | `name=borrow finished=1 cycles=105 from_fetch=74 retired=7 issue_groups=7 order=ok gpr_mismatch=0 pred_mismatch=0 mem_mismatch=0 check_failures=0 class_violations=0 overflows=0 credit_leaks=0 channels_used=21/55 violations=0` |
| `brs` | `name=brs finished=1 cycles=104 from_fetch=73 retired=12 issue_groups=12 order=ok gpr_mismatch=0 pred_mismatch=0 mem_mismatch=0 check_failures=0 class_violations=0 overflows=0 credit_leaks=0 channels_used=23/55 violations=0` |
| `byp` | `name=byp finished=1 cycles=122 from_fetch=91 retired=14 issue_groups=14 order=ok gpr_mismatch=0 pred_mismatch=0 mem_mismatch=0 check_failures=0 class_violations=0 overflows=0 credit_leaks=0 channels_used=31/55 violations=0` |
| `callret` | `name=callret finished=1 cycles=291 from_fetch=260 retired=40 issue_groups=40 order=ok gpr_mismatch=0 pred_mismatch=0 mem_mismatch=0 check_failures=0 class_violations=0 overflows=0 credit_leaks=0 channels_used=30/55 violations=0` |
| `chains` | `name=chains finished=1 cycles=98 from_fetch=67 retired=29 issue_groups=29 order=ok gpr_mismatch=0 pred_mismatch=0 mem_mismatch=0 check_failures=0 class_violations=0 overflows=0 credit_leaks=0 channels_used=21/55 violations=0` |
| `div` | `name=div finished=1 cycles=1045 from_fetch=1014 retired=144 issue_groups=144 order=ok gpr_mismatch=0 pred_mismatch=0 mem_mismatch=0 check_failures=0 class_violations=0 overflows=0 credit_leaks=0 channels_used=23/55 violations=0` |
| `divchw` | `name=divchw finished=1 cycles=118 from_fetch=87 retired=5 issue_groups=6 order=ok gpr_mismatch=0 pred_mismatch=0 mem_mismatch=0 check_failures=0 class_violations=0 overflows=0 credit_leaks=0 channels_used=22/55 violations=0` |
| `divtail` | `name=divtail finished=1 cycles=685 from_fetch=654 retired=96 issue_groups=96 order=ok gpr_mismatch=0 pred_mismatch=0 mem_mismatch=0 check_failures=0 class_violations=0 overflows=0 credit_leaks=0 channels_used=23/55 violations=0` |
| `divtail2` | `name=divtail2 finished=1 cycles=1622 from_fetch=1591 retired=366 issue_groups=366 order=ok gpr_mismatch=0 pred_mismatch=0 mem_mismatch=0 check_failures=0 class_violations=0 overflows=0 credit_leaks=0 channels_used=23/55 violations=0` |
| `fence` | `name=fence finished=1 cycles=84 from_fetch=53 retired=7 issue_groups=7 order=ok gpr_mismatch=0 pred_mismatch=0 mem_mismatch=0 check_failures=0 class_violations=0 overflows=0 credit_leaks=0 channels_used=30/55 violations=0` |
| `gather` | `name=gather finished=1 cycles=269 from_fetch=238 retired=16 issue_groups=16 order=ok gpr_mismatch=0 pred_mismatch=0 mem_mismatch=0 check_failures=0 class_violations=0 overflows=0 credit_leaks=0 channels_used=31/55 violations=0` |
| `hit` | `name=hit finished=1 cycles=237 from_fetch=206 retired=17 issue_groups=17 order=ok gpr_mismatch=0 pred_mismatch=0 mem_mismatch=0 check_failures=0 class_violations=0 overflows=0 credit_leaks=0 channels_used=31/55 violations=0` |
| `lanectx` | `name=lanectx finished=1 cycles=71 from_fetch=40 retired=10 issue_groups=10 order=ok gpr_mismatch=0 pred_mismatch=0 mem_mismatch=0 check_failures=0 class_violations=0 overflows=0 credit_leaks=0 channels_used=29/55 violations=0` |
| `lanectx2` | `name=lanectx2 finished=1 cycles=71 from_fetch=40 retired=10 issue_groups=10 order=ok gpr_mismatch=0 pred_mismatch=0 mem_mismatch=0 check_failures=0 class_violations=0 overflows=0 credit_leaks=0 channels_used=29/55 violations=0` |
| `late` | `name=late finished=1 cycles=178 from_fetch=147 retired=16 issue_groups=16 order=ok gpr_mismatch=0 pred_mismatch=0 mem_mismatch=0 check_failures=0 class_violations=0 overflows=0 credit_leaks=0 channels_used=31/55 violations=0` |
| `ldpar` | `name=ldpar finished=1 cycles=160 from_fetch=129 retired=17 issue_groups=17 order=ok gpr_mismatch=0 pred_mismatch=0 mem_mismatch=0 check_failures=0 class_violations=0 overflows=0 credit_leaks=0 channels_used=31/55 violations=0` |
| `lnorm1` | `name=lnorm1 finished=1 cycles=2668 from_fetch=2637 retired=526 issue_groups=526 order=ok gpr_mismatch=0 pred_mismatch=0 mem_mismatch=0 check_failures=0 class_violations=0 overflows=0 credit_leaks=0 channels_used=37/55 violations=0` |
| `localsp` | `name=localsp finished=1 cycles=4244 from_fetch=4213 retired=40 issue_groups=40 order=ok gpr_mismatch=0 pred_mismatch=0 mem_mismatch=0 check_failures=0 class_violations=0 overflows=0 credit_leaks=0 channels_used=32/55 violations=0` |
| `loop` | `name=loop finished=1 cycles=3042 from_fetch=3011 retired=407 issue_groups=407 order=ok gpr_mismatch=0 pred_mismatch=0 mem_mismatch=0 check_failures=0 class_violations=0 overflows=0 credit_leaks=0 channels_used=23/55 violations=0` |
| `merge` | `name=merge finished=1 cycles=74 from_fetch=43 retired=9 issue_groups=9 order=ok gpr_mismatch=0 pred_mismatch=0 mem_mismatch=0 check_failures=0 class_violations=0 overflows=0 credit_leaks=0 channels_used=21/55 violations=0` |
| `missrun` | `name=missrun finished=1 cycles=125 from_fetch=94 retired=28 issue_groups=28 order=ok gpr_mismatch=0 pred_mismatch=0 mem_mismatch=0 check_failures=0 class_violations=0 overflows=0 credit_leaks=0 channels_used=31/55 violations=0` |
| `mload` | `name=mload finished=1 cycles=115 from_fetch=84 retired=11 issue_groups=11 order=ok gpr_mismatch=0 pred_mismatch=0 mem_mismatch=0 check_failures=0 class_violations=0 overflows=0 credit_leaks=0 channels_used=31/55 violations=0` |
| `mlp` | `name=mlp finished=1 cycles=130 from_fetch=99 retired=21 issue_groups=21 order=ok gpr_mismatch=0 pred_mismatch=0 mem_mismatch=0 check_failures=0 class_violations=0 overflows=0 credit_leaks=0 channels_used=31/55 violations=0` |
| `mwmiss` | `name=mwmiss finished=1 cycles=133 from_fetch=102 retired=88 issue_groups=88 order=ok gpr_mismatch=0 pred_mismatch=0 mem_mismatch=0 check_failures=0 class_violations=0 overflows=0 credit_leaks=0 channels_used=31/55 violations=0` |
| `narrowadd` | `name=narrowadd finished=1 cycles=239 from_fetch=208 retired=21 issue_groups=21 order=ok gpr_mismatch=0 pred_mismatch=0 mem_mismatch=0 check_failures=0 class_violations=0 overflows=0 credit_leaks=0 channels_used=32/55 violations=0` |
| `pguard` | `name=pguard finished=1 cycles=90 from_fetch=59 retired=12 issue_groups=12 order=ok gpr_mismatch=0 pred_mismatch=0 mem_mismatch=0 check_failures=0 class_violations=0 overflows=0 credit_leaks=0 channels_used=29/55 violations=0` |
| `plog` | `name=plog finished=1 cycles=73 from_fetch=42 retired=10 issue_groups=10 order=ok gpr_mismatch=0 pred_mismatch=0 mem_mismatch=0 check_failures=0 class_violations=0 overflows=0 credit_leaks=0 channels_used=21/55 violations=0` |
| `pmovdiv` | `name=pmovdiv finished=1 cycles=109 from_fetch=78 retired=12 issue_groups=12 order=ok gpr_mismatch=0 pred_mismatch=0 mem_mismatch=0 check_failures=0 class_violations=0 overflows=0 credit_leaks=0 channels_used=22/55 violations=0` |
| `predlane` | `name=predlane finished=1 cycles=930 from_fetch=899 retired=10 issue_groups=10 order=ok gpr_mismatch=0 pred_mismatch=0 mem_mismatch=0 check_failures=0 class_violations=0 overflows=0 credit_leaks=0 channels_used=31/55 violations=0` |
| `predmerge` | `name=predmerge finished=1 cycles=943 from_fetch=912 retired=9 issue_groups=9 order=ok gpr_mismatch=0 pred_mismatch=0 mem_mismatch=0 check_failures=0 class_violations=0 overflows=0 credit_leaks=0 channels_used=33/55 violations=0` |
| `predspill` | `name=predspill finished=1 cycles=969 from_fetch=938 retired=12 issue_groups=12 order=ok gpr_mismatch=0 pred_mismatch=0 mem_mismatch=0 check_failures=0 class_violations=0 overflows=0 credit_leaks=0 channels_used=31/55 violations=0` |
| `predswap` | `name=predswap finished=1 cycles=1187 from_fetch=1156 retired=46 issue_groups=46 order=ok gpr_mismatch=0 pred_mismatch=0 mem_mismatch=0 check_failures=0 class_violations=0 overflows=0 credit_leaks=0 channels_used=33/55 violations=0` |
| `privwin` | `name=privwin finished=1 cycles=2220 from_fetch=2189 retired=52 issue_groups=52 order=ok gpr_mismatch=0 pred_mismatch=0 mem_mismatch=0 check_failures=0 class_violations=0 overflows=0 credit_leaks=0 channels_used=34/55 violations=0` |
| `provswap` | `name=provswap finished=1 cycles=2448 from_fetch=2417 retired=978 issue_groups=978 order=ok gpr_mismatch=0 pred_mismatch=0 mem_mismatch=0 check_failures=0 class_violations=0 overflows=0 credit_leaks=0 channels_used=33/55 violations=0` |
| `roconst` | `name=roconst finished=1 cycles=79 from_fetch=48 retired=4 issue_groups=5 order=ok gpr_mismatch=0 pred_mismatch=0 mem_mismatch=0 check_failures=0 class_violations=0 overflows=0 credit_leaks=0 channels_used=26/55 violations=0` |
| `rogated` | `name=rogated finished=1 cycles=100 from_fetch=69 retired=7 issue_groups=8 order=ok gpr_mismatch=0 pred_mismatch=0 mem_mismatch=0 check_failures=0 class_violations=0 overflows=0 credit_leaks=0 channels_used=26/55 violations=0` |
| `rokill` | `name=rokill finished=1 cycles=109 from_fetch=78 retired=41 issue_groups=4536 order=ok gpr_mismatch=0 pred_mismatch=0 mem_mismatch=0 check_failures=0 class_violations=0 overflows=0 credit_leaks=0 channels_used=27/55 violations=0` |
| `rolaunch` | `name=rolaunch finished=1 cycles=76 from_fetch=45 retired=4 issue_groups=5 order=ok gpr_mismatch=0 pred_mismatch=0 mem_mismatch=0 check_failures=0 class_violations=0 overflows=0 credit_leaks=0 channels_used=24/55 violations=0` |
| `rolimit` | `name=rolimit finished=1 cycles=79 from_fetch=48 retired=4 issue_groups=5 order=ok gpr_mismatch=0 pred_mismatch=0 mem_mismatch=0 check_failures=0 class_violations=0 overflows=0 credit_leaks=0 channels_used=26/55 violations=0` |
| `roload` | `name=roload finished=1 cycles=109 from_fetch=78 retired=8 issue_groups=8 order=ok gpr_mismatch=0 pred_mismatch=0 mem_mismatch=0 check_failures=0 class_violations=0 overflows=0 credit_leaks=0 channels_used=31/55 violations=0` |
| `rope` | `name=rope finished=1 cycles=7797 from_fetch=7766 retired=354 issue_groups=354 order=ok gpr_mismatch=0 pred_mismatch=0 mem_mismatch=0 check_failures=0 class_violations=0 overflows=0 credit_leaks=0 channels_used=34/55 violations=0` |
| `ropediv` | `name=ropediv finished=1 cycles=1169 from_fetch=1138 retired=203 issue_groups=203 order=ok gpr_mismatch=0 pred_mismatch=0 mem_mismatch=0 check_failures=0 class_violations=0 overflows=0 credit_leaks=0 channels_used=34/55 violations=0` |
| `sel` | `name=sel finished=1 cycles=79 from_fetch=48 retired=8 issue_groups=8 order=ok gpr_mismatch=0 pred_mismatch=0 mem_mismatch=0 check_failures=0 class_violations=0 overflows=0 credit_leaks=0 channels_used=29/55 violations=0` |
| `sized` | `name=sized finished=1 cycles=2646 from_fetch=2615 retired=25 issue_groups=25 order=ok gpr_mismatch=0 pred_mismatch=0 mem_mismatch=0 check_failures=0 class_violations=0 overflows=0 credit_leaks=0 channels_used=32/55 violations=0` |
| `slotform` | `name=slotform finished=1 cycles=4371 from_fetch=4340 retired=12 issue_groups=12 order=ok gpr_mismatch=0 pred_mismatch=0 mem_mismatch=0 check_failures=0 class_violations=0 overflows=0 credit_leaks=0 channels_used=32/55 violations=0` |
| `spinwait` | `name=spinwait finished=1 cycles=2329 from_fetch=2298 retired=211 issue_groups=211 order=ok gpr_mismatch=0 pred_mismatch=0 mem_mismatch=0 check_failures=0 class_violations=0 overflows=0 credit_leaks=0 channels_used=34/55 violations=0` |
| `spmbank` | `name=spmbank finished=1 cycles=187 from_fetch=156 retired=13 issue_groups=13 order=ok gpr_mismatch=0 pred_mismatch=0 mem_mismatch=0 check_failures=0 class_violations=0 overflows=0 credit_leaks=0 channels_used=28/55 violations=0` |
| `srd` | `name=srd finished=1 cycles=71 from_fetch=40 retired=6 issue_groups=6 order=ok gpr_mismatch=0 pred_mismatch=0 mem_mismatch=0 check_failures=0 class_violations=0 overflows=0 credit_leaks=0 channels_used=29/55 violations=0` |
| `stall` | `name=stall finished=1 cycles=561 from_fetch=530 retired=116 issue_groups=116 order=ok gpr_mismatch=0 pred_mismatch=0 mem_mismatch=0 check_failures=0 class_violations=0 overflows=0 credit_leaks=0 channels_used=31/55 violations=0` |
| `swap` | `name=swap finished=1 cycles=561 from_fetch=530 retired=174 issue_groups=174 order=ok gpr_mismatch=0 pred_mismatch=0 mem_mismatch=0 check_failures=0 class_violations=0 overflows=0 credit_leaks=0 channels_used=31/55 violations=0` |
| `transp4` | `name=transp4 finished=1 cycles=1199 from_fetch=1168 retired=976 issue_groups=976 order=ok gpr_mismatch=0 pred_mismatch=0 mem_mismatch=0 check_failures=0 class_violations=0 overflows=0 credit_leaks=0 channels_used=37/55 violations=0` |
| `unal` | `name=unal finished=1 cycles=140 from_fetch=109 retired=9 issue_groups=9 order=ok gpr_mismatch=0 pred_mismatch=0 mem_mismatch=0 check_failures=0 class_violations=0 overflows=0 credit_leaks=0 channels_used=31/55 violations=0` |
| `vadd` | `name=vadd finished=1 cycles=162 from_fetch=131 retired=17 issue_groups=17 order=ok gpr_mismatch=0 pred_mismatch=0 mem_mismatch=0 check_failures=0 class_violations=0 overflows=0 credit_leaks=0 channels_used=33/55 violations=0` |
| `vadd4` | `name=vadd4 finished=1 cycles=241 from_fetch=210 retired=68 issue_groups=68 order=ok gpr_mismatch=0 pred_mismatch=0 mem_mismatch=0 check_failures=0 class_violations=0 overflows=0 credit_leaks=0 channels_used=33/55 violations=0` |
| `vaddslow` | `name=vaddslow finished=1 cycles=551 from_fetch=520 retired=17 issue_groups=17 order=ok gpr_mismatch=0 pred_mismatch=0 mem_mismatch=0 check_failures=0 class_violations=0 overflows=0 credit_leaks=0 channels_used=33/55 violations=0` |

## Manifest of release/

```
40a2256ceadab9b59d7bcd9642277ade94f893cbd4d064d36b9323cc39d580a6  release/kernels/addrhigh.by_instr.json.gz
4d947c515d428c386d83d724fff3da8d7a25e6e734f6aca1bfcecf970840e1b0  release/kernels/addrhigh.by_unit.json.gz
d4fcb5474987e9775eff9e3c2d8a9cf39c7a248537b18a9393bb29a89d7b2db6  release/kernels/addrhigh.ccvtrace
3cb804922b628c5dc485f69154610f664c8902485669e7f9e67b06e4698c5da6  release/kernels/addrhigh.log
569f2e22883fad5f0956c57ec734e6afbdd4b8a854e50277425172d6c0cbd766  release/kernels/addrhigh.oracle.jsonl
dd6d36c506b3e54de10eeb2c76520c174f573ef940786c3f40c6bd89fecb8d46  release/kernels/addrhigh.sv-hosted.log
9a9f6000c80fea57a7b33c9bedb0ece3cd00c4782e9d3e5876189a0868e3ef40  release/kernels/addrlimit.by_instr.json
4e0ca9eda5d81f71a1537c110418d6d182b6d9f9f428ac4f0482eb96ae9a8131  release/kernels/addrlimit.by_unit.json
51b15e6cef986d7625910f902f5b1fadd70865eb6369a4d6611dbd9969afd6c6  release/kernels/addrlimit.ccvtrace
98a911118a1940ea48ae33a6138572910c5dd7d37b2bc8e39eaeee5dc08a1382  release/kernels/addrlimit.log
bc660b0b40359a2c5a2478cb0eb4950b73fd22db50ea76b80052bc195a1920f4  release/kernels/addrlimit.oracle.jsonl
9b529fde69556b5b28b850dbc5de149c8f8f692727e245ec261b06e59d6d3a21  release/kernels/addrlimit.sv-hosted.log
9b81bbeb54364562418fd0f14b866efe1e984f395e7441df0120ba318258f3ff  release/kernels/addrneg.by_instr.json
72ee2a0838bac0f15c7d3fb08a32c25a2054e3e0de898bc08aaac910100327eb  release/kernels/addrneg.by_unit.json
43b7b0d70169a6ae81ad23f767ddeb937621b0ea64614727b1c732c8c31de36d  release/kernels/addrneg.ccvtrace
c1045ad729fe443904eb8e1b8693d7174aa6ccee28b803e4f9a3e6631608ed62  release/kernels/addrneg.log
16f5b0707ae44492a1efd67bb9dd38a7e79a7bbd354fa9207b9e7d150ff2f107  release/kernels/addrneg.oracle.jsonl
12f0722abb108ef10d43d67bf75122f7339629ee70122290af064bc6f3b46b76  release/kernels/addrneg.sv-hosted.log
0ff13118cf08c6b6fd6f41975c9b3090be661659017f74ea5f1ae4ff0da7efe8  release/kernels/borrow.by_instr.json.gz
383587b6c8ae535e6fbc117621eef04d3f50d99d9d92dd89d245c2a367c5c4ca  release/kernels/borrow.by_unit.json.gz
67240ef149be30cf5a74e9429579b796ee44516a418a868e3849b203176a31e5  release/kernels/borrow.ccvtrace
858b163092ebc40c0caf2937e12ce36727361d3b2cfabb156883f4564ef7d813  release/kernels/borrow.log
4c565e1ce0b3baee36e158694b32c8defb5cd662b2f9af75cb5d8c26cb1168ed  release/kernels/borrow.oracle.jsonl
d0f7eb906c625c99990ceff769c96bb8d7af63671799ae794cee274f0ad63008  release/kernels/borrow.sv-hosted.log
249651d5574abd453ed1f9ae2e73ca6092ca7f756966dbf2ba9e5d99bacf0de8  release/kernels/brs.by_instr.json.gz
860784a734617d84f7f29aad55ef49fefb4f9f15643e1dc57e7d106e64a8347e  release/kernels/brs.by_unit.json.gz
128edb172327d712bc88579703ec070d4f8b915f017de6375983865c9cfbba1d  release/kernels/brs.ccvtrace
4791d3936b414db75de27fa1b2a42ab3d776e3f805a71a6f431e9bf4b88ae6d0  release/kernels/brs.log
e3c1cb3379580cf1aae44e8ddc8e846ef6fd661a573cfe0a8d4444b18a14dc56  release/kernels/brs.oracle.jsonl
e2e4b3c74e6924a0d73ab038814c7fe206097c58ea91fda1a89245184b24c7e5  release/kernels/brs.sv-hosted.log
1b3754fbfd3a4a720b18ff8647be9162d7481877d0dfa934176af392adad8131  release/kernels/byp.by_instr.json.gz
5e72cf030e4ad282821d23fa6fd9af07d98974022e872138c6cd737d0db5498f  release/kernels/byp.by_unit.json.gz
e2a496e279eacddda7c7a24d70292942d4fea280a4729222d9a852ce06ac29f8  release/kernels/byp.ccvtrace
acc1cb249c6b84159ddc2b661bea107546af66663d37666de33713300ebc70e4  release/kernels/byp.log
5a03dfa4f3603fef49f1e3639e74e34152ca3ca5ef8e41eb959f8323040fa2d5  release/kernels/byp.oracle.jsonl
1bcf44d342e261099da001c41c0e4980d5c77d23d445b1231887aa0068923353  release/kernels/byp.sv-hosted.log
936ee6e4b5b48297891a49769e4863831a7bae09111566cbe34676583cb0fe26  release/kernels/callret.by_instr.json.gz
5184a7d8c15ed56e4f610417efa59815fec6ecc5701a1983ede10f5a5e0dd516  release/kernels/callret.by_unit.json.gz
8a0822decad8c272e00ce024a229f7954747766595a1202a948042b98237107d  release/kernels/callret.ccvtrace
3940a922331253aa5f658257d89511c24fed2a057542f569813f6cc6baa9829e  release/kernels/callret.log
9b1d1b50b527f732362f837250aa2f26dabf3e76e16a4794856ebd8f105635b8  release/kernels/callret.oracle.jsonl
d23e7dbbf02121d101142b6ef582e1cc6dbcfe9432e178892d4acda96d2fc7a6  release/kernels/callret.sv-hosted.log
a937e528bc6091ee441de07bb4ce575813f3d9ed9adaa179337f8c1401abcaa8  release/kernels/chains.by_instr.json.gz
35b8fd49874ab903cc0cfb26917848956c40a964d3ec92a28e7058aded0ec6db  release/kernels/chains.by_unit.json.gz
d5da85bb6c56a83920cd42792ac6c0ab066bb32ed9706fc08f36079f6066f572  release/kernels/chains.ccvtrace
941305ff424f9fb3aa074f7a94aaf4856232e34152dd0c4d825041f6cc47c964  release/kernels/chains.log
26a4cc5c5524c7219d8706c2582c80357dea60be9d6ffdec99dac7d0365e2264  release/kernels/chains.oracle.jsonl
c2408b5e7f1d6dda6b2afff54cbf398cf7e8d2442ab86267593a3c63ad1fc65e  release/kernels/chains.sv-hosted.log
97cee80563b21797fce0fa21dcce97f78a7cfb2753dce8ffa004e5d20067db48  release/kernels/div.by_instr.json.gz
89aaa8035138d652c948d21a19ac869eed4807a91b33c06a38b41609cb3f4687  release/kernels/div.by_unit.json.gz
ad3d8c23101d30ebbe88bfec4190a2c8ccf010d52a5c29e137d423c275e80af6  release/kernels/div.ccvtrace
93d9d2a00c2c8d087ae346068ddc705c5b75e43b16f6c20a12d56f38c1d32c54  release/kernels/div.log
71a567b85cf85622631490187563de9a5661099c78a590adff4ed0a0c3d24c16  release/kernels/div.oracle.jsonl
f67157ebcad249d84f4b6dfe4fa0ee210a6c0ae6873d5d2ab3babd230a220ccc  release/kernels/div.sv-hosted.log
765f8e33bb36178ecd0ca974295c5c176063f1e48d9b1966434236f85d7621e0  release/kernels/divchw.by_instr.json.gz
8a4a7bbaa581a5405e2dc7b6e4cdb73ab4c9d53b09fa4c8d94a7b2a99306b917  release/kernels/divchw.by_unit.json.gz
229b9f82ad8a571d5b4b60eb8f51f09df323e3f66e82bc1e17b1fbed1c158fed  release/kernels/divchw.ccvtrace
6e65af408d259bbff3afab9e32589633b84910b879f20fcf40b4ac9dbc432401  release/kernels/divchw.log
58a541797f7a2df0a1c7528ae6a3edec212db90c7d3eb20656806f38b5c10b3d  release/kernels/divchw.oracle.jsonl
a0139004efedf7e7a1ceaee1206a50b5dbcaf9d846517d09954ad9a3faa0e4ca  release/kernels/divchw.sv-hosted.log
3a985a127e9f49852e99bf586db09c32d0c0d44010bc359c09df06c7e4bb5782  release/kernels/divtail.by_instr.json.gz
88881246b581a864bffe5e4e1176ab5927748548cd395e856f2d7081c508f314  release/kernels/divtail.by_unit.json.gz
eca0b84f92c5a7adf933bd26d401bd912ac1aab5b45afe7030246f719cd91c6b  release/kernels/divtail.ccvtrace
5928c3edf3d807733e3bdf1324f622418cfc2c060e30ed6084c9a7a345d060e7  release/kernels/divtail.log
75f11a75c9b3b336e446140af4579f05b46c363a76b7aab3ec88154a07ba097d  release/kernels/divtail.oracle.jsonl
12cd12849c20b3b762951e1abd53909e5652ff2d5471c81689323355286bd496  release/kernels/divtail.sv-hosted.log
1fc43c0101d8a8bcfe998096669e1acfec33d4dc629da271a37f5d1248f9cc22  release/kernels/divtail2.by_instr.json.gz
d8575b23a943efe1837e1c3de686614475967ab3ccac26049fc0f6438a63dc23  release/kernels/divtail2.by_unit.json.gz
413102892697f586d8cf9a008ccb6be62c1fda6dbc189683ce55f68c4da1722d  release/kernels/divtail2.ccvtrace
e785c0511344ab20e96673a049f93ba9e09a3732f41d5e9eb4e9ce31e444fa8f  release/kernels/divtail2.log
b2db6b05eb6cf4a0a7677e31d0c6c2952d5cab49d353f0bb1883fe0b2a20ed14  release/kernels/divtail2.oracle.jsonl
22dda7b85606f0e9af5f84317ab48707f46aa66015362a65f645da0dfa7d6186  release/kernels/divtail2.sv-hosted.log
ca249ae2172ea1923714e1138ba344b36348b754454b330279f3a917f34a7479  release/kernels/fence.by_instr.json
4e35ba3c3d2e85069be50ea94c76507b6ceaf0309239a7d716c3164fcec28dcf  release/kernels/fence.by_unit.json.gz
efa3071722e0c1b855b8daa163ca4639b52bba555700bf9bcc9cfa0043a0d0b1  release/kernels/fence.ccvtrace
95c56152413c0a05041b71e6e668343b71ebac2316a9bc9352217bb4c9593684  release/kernels/fence.log
d1d40317f6cf5bfb430cda1f9c0ef676609e59cabe2a11623c42ffbeca93142b  release/kernels/fence.oracle.jsonl
b8a832e7e68ae259a2d8937e17742de445c1b48e7529d42f568b97a7fa265b4d  release/kernels/fence.sv-hosted.log
e0017ade14f86a22fcf09b3c1eeb969a292d2f9d28d67f0e51524b3602425820  release/kernels/gather.by_instr.json.gz
47afb22ab1766e7be94620329e8c8a22b4278dae025d4f2672e4a8c594e256f2  release/kernels/gather.by_unit.json.gz
746d9b1600917d07ec12d01185ba2bb3cee7b2ff84c05eec01feb6327eb1243a  release/kernels/gather.ccvtrace
1b760a3e22d8dde2fd8b77884b01515a1abeb793f915b2d4ab1c2fc13a481721  release/kernels/gather.log
0413e781d8d6ff578c64eb1f800b7931e66f676d5cdabb97b94a4033e6037662  release/kernels/gather.oracle.jsonl
c1c932b5368a17fd8b060af2216fd32ab1f2fc411ded29fb1bbae002322aa6d3  release/kernels/gather.sv-hosted.log
61ec68d460ca39ead045bcf83cddfe00481fcff4757d97c93fca063fffdd4b95  release/kernels/hit.by_instr.json.gz
e91db5d1725be009ed3fe54fd9aad5abf025856cac1bbbd15cb002d01eccdc3a  release/kernels/hit.by_unit.json.gz
f889cae01bf9443a12978ae4f8c36064e8ff37014d68e0fecf0c8443c1883727  release/kernels/hit.ccvtrace
ef6d0de32d7a1bdf9093d8e4c910b11c32167a3539187cc732266300fee9a26c  release/kernels/hit.log
7ba9603e0088d9164de6528f16ef6a7fa9ce5821c8c12b52cbb3734e39b9fd52  release/kernels/hit.oracle.jsonl
f01e04b9ba2d411304f9716d6cc783e36c193a667dbd77a67a84d44ed83e33d1  release/kernels/hit.sv-hosted.log
613b7055b0ac2e16306d28b8f652a9980eebbac540a249bfba75ddb57a3a1ff2  release/kernels/lanectx.by_instr.json.gz
e9dc7879222ea96eb979af3d22d66538040e213a65bf4570b66e4ce0968ea085  release/kernels/lanectx.by_unit.json.gz
4012e2d1cd5183524baabd6763b62d346e3a2a261d8b63e40ad9b46540418690  release/kernels/lanectx.ccvtrace
aafb2576913342a19fb9a96914b6743607acd65100a7f6e778757cf54f2e2be7  release/kernels/lanectx.log
888551babf540db8e3025b82e65ca655013f93eba3c8a65689d069d52a7e6039  release/kernels/lanectx.oracle.jsonl
716d6eb7fe537c8088c87d2532437c33a7ebc0bf433d6f66e381367098f6c3c8  release/kernels/lanectx.sv-hosted.log
553988fbb200afb3a13532069ba37493b678a7c306b5a2dede9de8b5dead5d35  release/kernels/lanectx2.by_instr.json.gz
fb3803e79c980ef8d67de9afeb0e2f303f5469472d7a7950b3e0b00ae56979b8  release/kernels/lanectx2.by_unit.json.gz
abf099c0a477310ab367ffedf34a7bc77457a761c5435cbd0b36aef6f1053ea5  release/kernels/lanectx2.ccvtrace
8b07b5ad6609873ff065cfea94209307c80b2cc234fed860dc646f31cc603804  release/kernels/lanectx2.log
45c13056dff5c73ed0c9ece56cc36f929bf335322193c7d5eb38710b1d1dfb02  release/kernels/lanectx2.oracle.jsonl
5a8455d1c69cfa4494d1ea6a94b2b30dc1fa82c82737b40dd038a943eca4f1f4  release/kernels/lanectx2.sv-hosted.log
f20d53df49b0eaa83c0f1c68b00e92e5388cd9d93ac5e86fa27ee5f001ee4e5e  release/kernels/late.by_instr.json.gz
2379e1e5ed4bbed75d58ddd171926ebbc3bee2e54b48f3656bfccaf0f17e47e8  release/kernels/late.by_unit.json.gz
f1c37ace6764a0c60f77248ec6fc4da414dddef589def2606ec1ad931e0d121f  release/kernels/late.ccvtrace
73c2ccfe6f4767ac28c70e98e844c24dcefdb4620187b9ba583c723a1046fb2a  release/kernels/late.log
86084f6bd747a2cf32acbc0ebd96ebd3e4ef2d8d9e21be49e3ae49290d7927f3  release/kernels/late.oracle.jsonl
95c97a9bd9ee14b49fb382e00acb3f487e25c6b3194c27546c9c417223b1e287  release/kernels/late.sv-hosted.log
10d78477d2cafa915f0e79d02b0339ac55289d4da3565ad6336cc7e3d07ee824  release/kernels/ldpar.by_instr.json.gz
fc5125234b90c1b7846a96a68d3caf130aa53c7c374ebe8743006671ae84024d  release/kernels/ldpar.by_unit.json.gz
8ec10d8166af2ac5f30e10be605166e2551d1b82a6b43118931ff5ebe72a074a  release/kernels/ldpar.ccvtrace
f49af9595e67a0b8f885ce8c4d9cc303256901e73c5be73009035b92b7cfd974  release/kernels/ldpar.log
8ac08538e9c807637babd61b31e340f7461878ada31f0c0b83cd66331cfaf486  release/kernels/ldpar.oracle.jsonl
1c1709505ac4eda140e22e21d001923aba1e2bf3d3587486eb713bc3dd021416  release/kernels/ldpar.sv-hosted.log
11ca092b9db25ec5fe14c37261f3d0985fdf95c718626f9507ab4bde8f055db9  release/kernels/lnorm1.by_instr.json.gz
b36502ac3dcdfe343f6e65188b10f8a7a861e863664701352f5d640d658be580  release/kernels/lnorm1.by_unit.json.gz
3034f651ccf2326d49a4c2afd65ed97622dd826841872f4cbb07c98d7b3b2ba7  release/kernels/lnorm1.ccvtrace
f5e91c23908bb4f08b6880bca40b4a0646b80ddc8058f53f913c360e8fefaad5  release/kernels/lnorm1.log
a8d85811af988a1b9fc00db1517300af3d93ec8e589e403d3b9113fa9e0ffc86  release/kernels/lnorm1.oracle.jsonl
9174e24490460eabc01ea8e7021ae4d06f8c72e62b9b03fb6bbaeb816c2b5956  release/kernels/lnorm1.sv-hosted.log
18cc801cb2d21dabaf421e61f046de88106f9877ea8cc2a949dcf13f50c30e50  release/kernels/localsp.by_instr.json.gz
8a991860872be66b140236c4a49bb7986d528b93568de102536d715b1f39364f  release/kernels/localsp.by_unit.json.gz
01bbca903a02bdd886fec0bba6bc50acfef835a156ed8ed51dff9ae35b2bf787  release/kernels/localsp.ccvtrace
6abfc86c2adc8c1bac1e7c474bfd3ca1317748649996c37c77af4252cab4a40d  release/kernels/localsp.log
55e3c9f36e7f7d38c0ddd38903aff4bb4509ae862015c592e6b937ea258042ca  release/kernels/localsp.oracle.jsonl
6b65878071cba8048c230f3a73a6003b7a185f1bb77285c9d47f5099fd65327e  release/kernels/localsp.sv-hosted.log
4d69f220a47ffd378bdc605ddb897acfc44c603b86597d99ac354b3de833f03a  release/kernels/loop.by_instr.json.gz
f7a40300bc5caae913f1cbefe3f6f111a1edeebf5983440eaccc352b28c606c9  release/kernels/loop.by_unit.json.gz
b35505b1033ebfbda34e4ba33566f8881e23f8f12575de30696fad54ad656b49  release/kernels/loop.ccvtrace
4c7098dad37d1b5a337d0d33cd9195a7b066df892b18f11564e77de92b3ddb7b  release/kernels/loop.log
03ce5920c06c93e93516d8e53c3f7169f14e3593de204eacceffc0b8a3e32016  release/kernels/loop.oracle.jsonl
12db8ea21c8d80577e398a8bde1aab812d3ebe283abf889a4e23cf20c969da4d  release/kernels/loop.sv-hosted.log
5e34e12f1dcf56d73e043fce1cb76f57213edce0c82d56d094f76b4063bb93fa  release/kernels/merge.by_instr.json.gz
b4957493014d89bf60a9fe53c644b48eb33ece4ca3f485baa127dfa4b967e0c3  release/kernels/merge.by_unit.json.gz
5ad9a63e08acf17e6f99997099cd0e1dec5d81d01e1901bd8718e735b25605d1  release/kernels/merge.ccvtrace
bac84e231e9c9bd5a0032fba08496d7a4635e71187ad58415ae3d33c968b18ef  release/kernels/merge.log
f96d28815f8756b1f5a45ded53e6170883d2dfa10f9eef0d14b8050b1318164a  release/kernels/merge.oracle.jsonl
e4d918366b868a2b160a015f6bd25f8893054b5178686b7f165f31d045d1defd  release/kernels/merge.sv-hosted.log
d52d9f015feb5cb1afcbba16c00393ba85323aa0d71e91db97ae0888e1087f83  release/kernels/missrun.by_instr.json.gz
8d32ea08959b507763a641cb61869366d2b6fa917dab8bab1ca6aabbd6f7d4e5  release/kernels/missrun.by_unit.json.gz
0b2a3e7bb8ede8cf8e41e7fae87fae24e55ae088f450c9985caa90233a9c51e8  release/kernels/missrun.ccvtrace
98a18dd17b2b00ffeb559cb0ce8910f76359425e812023cec1fcf61e5a54309c  release/kernels/missrun.log
531bdaf281e5590774bd2775427f25e4cc0419cf8e3d5b6999843ffe9ef87258  release/kernels/missrun.oracle.jsonl
1a66fb13516894e7dc620c8bf99b0e548fca35142c0a146cc4c078479ae5fdb1  release/kernels/missrun.sv-hosted.log
78ad704f7c8654a6bdb967331eede5e1cfdddab569b5b70ca815fce40fa69824  release/kernels/mload.by_instr.json.gz
9c96bbbae3ddf155e67ffb07ec7b6e87f1e64c119744a570c04c68fa858acd25  release/kernels/mload.by_unit.json.gz
7535f2907cb49ba77e5593dc14e6662824432989cddcd9276be4aa0b57d156ff  release/kernels/mload.ccvtrace
22cd26e00f066278d8302f6422ba9de65fb6c4765ff0b94c075ce1890edda173  release/kernels/mload.log
8000e477b9a95dfb9f0af964e8346acb9d36f1358fd06ffc4ff7cf599d2b8868  release/kernels/mload.oracle.jsonl
35f16162bdfc2cb2f879cf2ac3f737e4324655f858291bac57a97722228d289b  release/kernels/mload.sv-hosted.log
60b36c39cf953b6ee1499ac9207ff7be1897a3d96e87bc645e442fa2f88f8bf8  release/kernels/mlp.by_instr.json.gz
88405954fc5fe756418fb80e7acaf1fd8d78523e2ff13232d8afb757bf95a9f4  release/kernels/mlp.by_unit.json.gz
2ee2e44969de80336602cb1cb0e0585099e01721bf82898129e9b6fd488f2c81  release/kernels/mlp.ccvtrace
084a2d5b12552e4fda4d8940abbeae5e36a604c7349496a5c3959fc8f1b8cd72  release/kernels/mlp.log
138d282f88d56c8ad648a91af0a983254b55d9fa22942c00d47b327f516a6e44  release/kernels/mlp.oracle.jsonl
b5ff8660fb619f24cd963a1ed854d45f74f497562e99ae38eda92e8b9174db18  release/kernels/mlp.sv-hosted.log
419ecde3d25a65b6d4e3a6dc87e8bfd6dfab2d852ad3bb7d2e22ce836deee75f  release/kernels/mwmiss.by_instr.json.gz
b65c91ea0c10d39957cd4963a28ee8193e497cba52ce397f1114332d0faf64ec  release/kernels/mwmiss.by_unit.json.gz
aa0ffd5ad7d5e2b56a1f583f0286a4210f61a87bc4483604614e8d613e75b594  release/kernels/mwmiss.ccvtrace
a5d01fe74f88190adf2cbfb45ef4e4eac818d0ccf0f0bc5ed37252878543dd53  release/kernels/mwmiss.log
8abe8e8997456a2a6711ee72da54d854b24e20abbdab28e4b7271c0d28418de8  release/kernels/mwmiss.oracle.jsonl
744a333854e8a13e64c74b5576c9478d97746d9cb99430e457367510a4c52070  release/kernels/mwmiss.sv-hosted.log
797147b512036d144b1ddf90d7a6c56f1c4269e6f987c4c6ec2e09cb3505cc75  release/kernels/narrowadd.by_instr.json.gz
36098843028976f0de44d398a1642e9bbe2877c50dc05f9803373f7c3133c7b0  release/kernels/narrowadd.by_unit.json.gz
646f37003b6197f246300fcebebe5c1265c9a914618d7a34ac402e36b9954040  release/kernels/narrowadd.ccvtrace
f84e0b9b5a7425eb4b49e09bf9efad042cff99c3142d9d6217ab544437f93d12  release/kernels/narrowadd.log
40a2cf629853dd404bb06b4a07e35abde3d12efc13f26ffe28f923daf2994574  release/kernels/narrowadd.oracle.jsonl
5a8d5c493a4b15823461dacd95dbedeff9d5209d155968808169ff64a5322f5f  release/kernels/narrowadd.sv-hosted.log
ab79315f2ac24e01117133cb57f590dc0cf710233d93efa9e72b1c87c1718576  release/kernels/pguard.by_instr.json.gz
a7d22ac10b41ea8beaf7c626e03eb5e3cb6f02c776079cab9a0a065e24b9b037  release/kernels/pguard.by_unit.json.gz
0500b2a9006a638783cf2d7ab34bb47573d2f8057703fd8b00d1aa68efee0275  release/kernels/pguard.ccvtrace
bc5209a37eb6960e8c259f16761fe1d9ea5ddda93387889834cbbe5a7d5b594c  release/kernels/pguard.log
690e56f1cb8d97cbf67124b7dff3ad0a90cb8981814cd1709cf0cd0e035b3bd9  release/kernels/pguard.oracle.jsonl
b60be8ac531955af3db1acef2416bac0488ecd6caddfaec93734fb44f9a7dd90  release/kernels/pguard.sv-hosted.log
cd65f8697333d63fea092af22287da2e5965be9be7153dec029068e26295c9b9  release/kernels/plog.by_instr.json.gz
9bc6adaf722d29935782229a6e29c3de9096a5c9441f76c6bc54f79d825231ad  release/kernels/plog.by_unit.json.gz
ffdc6b0c42deb958e0e7dad59d420d828f89ee7b5c84276c9c5f0cd8aaff140b  release/kernels/plog.ccvtrace
025a00d49b50a6e56940e9c06fda4a513c7f027714abd50a82abad0559e3e7e4  release/kernels/plog.log
c230f13f2e1082b306a9c5ab7809ff36cf5c1b2e47dca6b7a71f741524d403f5  release/kernels/plog.oracle.jsonl
001f5969cf67e8b7b809c3d0a243a19266486b10954cf536f2d1674094be6360  release/kernels/plog.sv-hosted.log
9f31e478a1c14782e4b0f8454ba000e0d9ebc11203692bc33a719a6ea2b8d5f5  release/kernels/pmovdiv.by_instr.json.gz
1aa10bc8216b8f574d2b7f28b90f0b535f71842394b0d1dbc89759b9c9e1ff9f  release/kernels/pmovdiv.by_unit.json.gz
db95f4f3737f43900edabeef54830e11854e693ab8e94d3102bb9736ea7778e0  release/kernels/pmovdiv.ccvtrace
6b53bc65803607fd701c9c0b111d22e79411f969704da3589bc2d965f0597fb9  release/kernels/pmovdiv.log
7bc646cff6166a51bdce03d7c1b7209e871f0a91d743083a9b910a80bcd0b33f  release/kernels/pmovdiv.oracle.jsonl
ba0ec22467dc87e4012b7f234084d6481e1ce40d1c0871e26aab52356c69ee31  release/kernels/pmovdiv.sv-hosted.log
fddf9a29e611da1bf8e40dd593fcf584b9ebcaf0258a8ff4d3cfefbc4a6bcef1  release/kernels/predlane.by_instr.json.gz
491781982df47bfb0651b59b89d344af65b1597408355bee1abf3401bad9ea43  release/kernels/predlane.by_unit.json.gz
9fea5119fe559b105ab7d1dc97ab56d7af400542acf4fdcc2b8bb120bedd6091  release/kernels/predlane.ccvtrace
3a3b17993a77de1bcb3b221aadcd1f294be9f5c8301043c471cce789b55132f4  release/kernels/predlane.log
c45f4177b9e84fc8a6e36b13534a0c7636eb30a3f8531847100ce5e23bf404b1  release/kernels/predlane.oracle.jsonl
587e9d02e8780a6a6d5f918277c2010f04d75873f9ef49f3b3a2010b755ed722  release/kernels/predlane.sv-hosted.log
233a1784c3c4d1b6aee9d7ff107aa43792c9ce43c7b023bf92e52837c4e4cda6  release/kernels/predmerge.by_instr.json.gz
b3b7b8cdb6372892addfff3f8b57493fe42d0e27144f48e5dce1e011938105f4  release/kernels/predmerge.by_unit.json.gz
f91a8f729274c9538ac11b9d3fbdf1bb1eb2c619b6dfa8e8333eb6c346523b80  release/kernels/predmerge.ccvtrace
3dfa9c0d1e5d83f1096bda4b670801b1a85e9e7932ae837825c1f91e2426a097  release/kernels/predmerge.log
6c737c49434bcd08e3e0814c8b1dbf15c586ae74f7929ba3148ddcee2c62c845  release/kernels/predmerge.oracle.jsonl
8b9879d50bba09bc9459849a31189020756abab6bab0d111b849cc41d33ce086  release/kernels/predmerge.sv-hosted.log
84ab64a7a6d499ab8b543fc3f21a7d728bf69dd11abb54aca4bcab7a9659dfc5  release/kernels/predspill.by_instr.json.gz
452439eb35af6e38c2c2a589fc8dd33d78856a508d87c2ed16dc4d2e1639a3e7  release/kernels/predspill.by_unit.json.gz
1dd9bcc3656cf0306d9f1bd3120cf3685118dd576d076c94fb12a9cf43685c35  release/kernels/predspill.ccvtrace
2f71aed81324c6d59ed028386238b2455b15327d8ee9705f3c586a99201e4077  release/kernels/predspill.log
b7c84c6478117ffa0f06da0e6ad1e4628e2683426a7911080810e78e06a5242e  release/kernels/predspill.oracle.jsonl
5de88fed840924eeafdd203fc909594cca5cd6914a886e07396f2c5e402ff2c0  release/kernels/predspill.sv-hosted.log
60da5d7de43f9968099740dcaf567307b1ef35c7bbf446b7a4458d34e9c8e017  release/kernels/predswap.by_instr.json.gz
7dbe9d414761ef1dd907c59df90c3544df3b22e17af4845ae1eb28dc304c3f93  release/kernels/predswap.by_unit.json.gz
cb69bdbe02c02f4dcbf1051bd26722d7980c5ac17e949b6d1898ffdd4f12caca  release/kernels/predswap.ccvtrace
3cc8dc5c14d5b9536ad55bc333af7bb7d9c46b2c82a4ab88e0681364a91fec68  release/kernels/predswap.log
a6d4f7ed517553816d889c7c9eeb6bcfd1f6c973fbf682ecb69f3c2de619f7bb  release/kernels/predswap.oracle.jsonl
4493e140d970991cb6665877d12af330405248b70dfe865b403dc12893a52a15  release/kernels/predswap.sv-hosted.log
5e54c1299c86b65f4d83c8cecfc640d8f0a262eb69f38c4091d1426a7ff1709a  release/kernels/privwin.by_instr.json.gz
37fc9d25ca9eed5aad907de3f3213e3cdd0260a28d5497f32178fd040cffd1eb  release/kernels/privwin.by_unit.json.gz
fbe60bf5f4c544acbe90d34c2dc3557aec4249b0d7b78a7f8ac932d75ef58f00  release/kernels/privwin.ccvtrace
d24abf1bb991edee041fe9565721a8f5118ae445c05bc10e9ceb6de9fb0d89da  release/kernels/privwin.log
861f686fc4480363472908d679d8815e8c957d768e7ab32c826930527b0fb7a8  release/kernels/privwin.oracle.jsonl
c13932b66452d8dd000f332ee8d3be2ac2ea02a829284a872391703338f95a44  release/kernels/privwin.sv-hosted.log
cfbcf37a8532ae6cc5ec79bd8e65a4ffa8c8ea073806d2534514ed00f18676d5  release/kernels/provswap.by_instr.json.gz
bcc2951fcbcadeb604ded28a75e495817b357b3c912a9dec98d3e78ad13553fe  release/kernels/provswap.by_unit.json.gz
fffe64aab63dcf7334ccb242e1455064d177f0b9807ad0b01214243d95aa0207  release/kernels/provswap.ccvtrace
8d6cbe15f3a070078a344dfcc28527dbcb71204a6798357eb3bdc33ec9cb94a8  release/kernels/provswap.log
c9c32a793d54cc7401477f582487f7e8b345b2669a75337b8d6327120d98e5dc  release/kernels/provswap.oracle.jsonl
5ab1ec9f5df89a3de38188d960fb8b258d907cf7e2ca8912d76328aa024b0225  release/kernels/provswap.sv-hosted.log
dc55602d0682201174a82c2d0fd8faeef4d1a7c108fcc9d802cdf92609698448  release/kernels/roconst.by_instr.json
ab4f4cbf1099b39a9a5b6c25d847ed64911aa302afabbf30b3e0b3e565dbe366  release/kernels/roconst.by_unit.json
f894e9891d538c0e78e9cb63afb66bef6e6b867c0e0ef118ea2d8cf7db0377fd  release/kernels/roconst.ccvtrace
15135aaa80ce10e46ef246e32079076cc6558f8682cad99fba8adc323d77e667  release/kernels/roconst.log
8087c0671de620162881aecd38cd6114b78e7be6bd71201e3ec02c9a2e2e750e  release/kernels/roconst.oracle.jsonl
76e5d6b93dc11c104dfea88ee1bc7c5638f9c31c08c4208fb579d41f83027b17  release/kernels/roconst.sv-hosted.log
ca1b80ff4e3f1b1bb4ca1cca38e031cf1b19398ecf4e3df4b9f73b404df98562  release/kernels/rogated.by_instr.json
6238a36cdfeb60e747720b60360247cb851fd6a8b123fa7fb5eaaa60d9ae9e88  release/kernels/rogated.by_unit.json.gz
68d28ee66534984bc41ecce047dadf73e8d3545033fef283e47b4255e210f190  release/kernels/rogated.ccvtrace
d9507f79634f7cefb49c8af4f12af728e614bd252387514571bf11fab38bfd4a  release/kernels/rogated.log
7cd02bd4cceec5a044d6b4d6a80df1e68ed0ae71b0b2a953143636d5b809ea6c  release/kernels/rogated.oracle.jsonl
e86a806e3e5eb7cc6f7e5f1ebdc57f57577d5bf5562feeace7ef3d0a3cc37517  release/kernels/rogated.sv-hosted.log
f71de11a1f1c7fa3007ef033aea1fdac22e85b6b241e2c7e9c58e462becd1955  release/kernels/rokill.by_instr.json.gz
8e978ecf6178fe4746012129d6512045c6d1226518b7653d25444d75a95114e5  release/kernels/rokill.by_unit.json.gz
540c7f20c619f5c1c20d2e25139e5925a164d2e3c1ff27182b833c22dc004e31  release/kernels/rokill.ccvtrace
5b06748e33907435804c89043e32ca3883cfa23894d443b539088fd4e6abd4fa  release/kernels/rokill.log
94efcef96af469a512d346ce61623980fe86383188eaebd55120f716db596f14  release/kernels/rokill.oracle.jsonl
3ff28f469c8bb08d968e8a1903f83bc5a7f41e646542d77849f64a3fea3a06c9  release/kernels/rokill.sv-hosted.log
51d0acfffbebae936250c77e136bd854b9e2ec7e600bf649da6bc1c63b738219  release/kernels/rolaunch.by_instr.json
d6225f926bf8f649ade8bcc40d00e521ef13e4d12fb23c295f647b5e736cc9d0  release/kernels/rolaunch.by_unit.json
fac31379cbdd1149691e5f6b825b09ce4be6684dbef756c9899b6296d3e5cfc2  release/kernels/rolaunch.ccvtrace
12af9c237e657fa8123e45f5a2bcc063449a0c9fb261f20856b1c460d88a19db  release/kernels/rolaunch.log
e7dad585c3e70615de04330fd03f4f282c29a005dc1732a35655fb261d51139e  release/kernels/rolaunch.oracle.jsonl
9e0ffe0e00413535185b7e8372e66fde2fb40d3afd2e031669fa2f07c7aca43b  release/kernels/rolaunch.sv-hosted.log
dc55602d0682201174a82c2d0fd8faeef4d1a7c108fcc9d802cdf92609698448  release/kernels/rolimit.by_instr.json
aa44984a69a69d7aa047c4a7f0d54babe40d5435d04beb87ac6e43766cd596c4  release/kernels/rolimit.by_unit.json
11dfc06ccf93d49d763e035901024eb5b8b93bc8a25063b530af25d7c10cc908  release/kernels/rolimit.ccvtrace
c4882d3d9ea6477a8f92e27dc423f0d1bb110a07f21af3a751bdf8a2b8bdf376  release/kernels/rolimit.log
1c5bc0cb8e8b2e69505fb5a551a16d5d10c56f232b88da7a27e336ad7d962de2  release/kernels/rolimit.oracle.jsonl
36b8844e108657c5f3dbb63e2cafb80a501100c05dca8605b04f04b46a7e3267  release/kernels/rolimit.sv-hosted.log
a5294a96965a3862ec15d9177ddd58b3e419f22970710dbd25f0784ef60f44b2  release/kernels/roload.by_instr.json.gz
50f7de4a2614e3781cae9b805b796d86cd973b18c95a89f6dd748e68321fd240  release/kernels/roload.by_unit.json.gz
8a2019ce1fabd508e5cc57d310747bd043463203d450feb41c75bd468dd5e2ec  release/kernels/roload.ccvtrace
440d3f1dd32011bf107d57ead89c7df2092534d8cd76380dc42553af33f08131  release/kernels/roload.log
f7c1309cc9764769fb5803f6fd0f2f5e1eb418f2d23fbe5e17cf5f9106869fdf  release/kernels/roload.oracle.jsonl
0d41bd548ffb36c2d9b96927845fca2273f3ae0989f226b30194257ce41430e6  release/kernels/roload.sv-hosted.log
9b527727b653b61f69a34d24c6ba450765cbd69802ed671996b02b894ed95d26  release/kernels/rope.by_instr.json.gz
f30ff1945bce0788f5827aeac31ed564e9aac0210b63f4c6099d87a31b2397a9  release/kernels/rope.by_unit.json.gz
494d09b227b6022cfdb2cad6838c5a1337c421dcaed69f26250d15a2aed66eed  release/kernels/rope.ccvtrace
4fd98c22d6a311c17c369a00dcc88bff4a9503590d9869a15ea1d06ecbc6ed3e  release/kernels/rope.log
d55f9efae392dc8877c102c01c0810e7654b666b6ede386328108164c6cf88f3  release/kernels/rope.oracle.jsonl
5f7fe2cd6d98f5c3a080a839d88b7ca1f9f0f9d5737172a8828e1e7cbcc85eed  release/kernels/rope.sv-hosted.log
b01850a5a39476743d3fcdc161bb985a6925067afe10f22d009b5b208ff04e1e  release/kernels/ropediv.by_instr.json.gz
0a28c3206db714680774fc2848a9029d5dda3a81fe5ab1d426ac43d5cc423db5  release/kernels/ropediv.by_unit.json.gz
21b64abe827446a876a9a065b1772ab83554281bc2271458d148f83d49ec87d8  release/kernels/ropediv.ccvtrace
0c0129042f37761fe46fc74ebd6ef631f8b2d2f29700154df50bf650c0f4bf22  release/kernels/ropediv.log
10c0ec6ec18b7b44638c790033109198c079d07c1537bf193353ccedd00a920f  release/kernels/ropediv.oracle.jsonl
b4936c7e4289e5e238558e475843cb335c30160d80eb82b26aa2ffc5441124d4  release/kernels/ropediv.sv-hosted.log
9b95569293bee5cb4b7746f93dffc6eb965fd82dd0abf1c7ed405d5a5ea43d96  release/kernels/sel.by_instr.json.gz
862386576604e04e883c665efa6f08c2571ff3f456b6dd8fb7d26fb1a285e572  release/kernels/sel.by_unit.json.gz
f18a0d72d694b763849ac25b17f82c7bf36381e0455d41febf75d6510c9cc868  release/kernels/sel.ccvtrace
9cdece29e821a0153a5889cc83a7c3b83d49de053572ca20873b9b7c2a36bf28  release/kernels/sel.log
87f6a81e8afa004c8039bf2f61c90176fcf29ab29bb17ac44aa016a5cc8438fe  release/kernels/sel.oracle.jsonl
4a0315d074d3678f4947d90af7b4997a3478f8a4a80bac46dd3044c1a03a1821  release/kernels/sel.sv-hosted.log
fe64cd8e3933650d9c0a1eaad20828f8b382b8b8be177559365ce4d60ded3464  release/kernels/sized.by_instr.json.gz
38a14c43b92050295e5cd92f3ca6717f91a8e0d97edebfb9d28847ef03c2a460  release/kernels/sized.by_unit.json.gz
dbebd49ee96b335775b575b8e4b22b012267ee9d3ae7e0365cbd65ad9c669852  release/kernels/sized.ccvtrace
6cbfe15ec66cf26d6ef5a3556649affe115d12fabfc32027211486619e3c2055  release/kernels/sized.log
36d903ba1618bd1faa437c9812a6ee6c0c966a63196c796267d74bf2695ebc3d  release/kernels/sized.oracle.jsonl
12cd6bbab7dda7dab6c57e45551d475b163463f952e79b5222312de0e9fd6dd4  release/kernels/sized.sv-hosted.log
03358f5c92a9210e7c58714ee7279ee2f0c08dd534de8ee66228f1f17646eedb  release/kernels/slotform.by_instr.json.gz
4f0b5be52116dde752292f2616203bd066dea18669a4fb46d78387cb93a96af2  release/kernels/slotform.by_unit.json.gz
485ce94144326733859d13a293d5a0a07d8753f4ce2fcbb55a474acc2bcb8114  release/kernels/slotform.ccvtrace
908cd664e3a781cf7223bd7fe4a863cae3d56bc1b3ab08e180c45125ed2aa224  release/kernels/slotform.log
8b61db7419b18cea8a646fb628218447e72e84a18a9891ffb73b441736138ab9  release/kernels/slotform.oracle.jsonl
fd3f00970e18dbb8834c0c2dcbc4191035e9125669faf6b0dbc3c6339f0baad5  release/kernels/slotform.sv-hosted.log
2d545b2d7a588712e0eaccf0aaa64e9353cf6ad6cd359c08cace6fe78f6fe744  release/kernels/spinwait.by_instr.json.gz
c2d457de377d594140f7940176325925b6cb45fa8bd7b27aedea7bd4a8c2d0b2  release/kernels/spinwait.by_unit.json.gz
e0b4a03bae53a6faded635f14655b9cff168fc3775071a34c407cde8e62feab2  release/kernels/spinwait.ccvtrace
f94444f92dc68d6df37738572620822128cecd2ab8ea8d74d8b82dfcb79ebf5c  release/kernels/spinwait.log
868920637236c878b33779bd450439466fc3626996a3164573dc11d437d5c709  release/kernels/spinwait.oracle.jsonl
8de82a2082aba50b9a22c765fe47b8080538d9b764bc3d651ed04b6a79dd2a80  release/kernels/spinwait.sv-hosted.log
55e36d0af3153309521d76cd1cb3bef68c44a03ee76cb325411726f6d6e81af6  release/kernels/spmbank.by_instr.json.gz
6c685c30b0988a80ce3d31a51036e32fcc7d58538a94a8855cb2c1540bdf7bf5  release/kernels/spmbank.by_unit.json.gz
f1c940ebf07e9a5e0aadba3e91d05552eacbd96df0c3de31ab1004348301136b  release/kernels/spmbank.ccvtrace
1b4a52cac444fe3725117e14b9b35b3614017eb7c7ba1dbcf389c5925600da3e  release/kernels/spmbank.log
3af490cc37d7a92dbe719b57de216b648536eb301ff9d13de9a39f50d150d725  release/kernels/spmbank.oracle.jsonl
254cdd4a1cdb882d0564149b56bca5815668e11fe3e3cb6c12415365a463a504  release/kernels/spmbank.sv-hosted.log
0af599ab2eb0cf15b87b76d33817eba9eec4b6a7a17e1e28d192dbae87719c6c  release/kernels/srd.by_instr.json.gz
883e31bd5c774a7b41afee53d30bf1602a69115c18f2392b24e4978b0175dcc0  release/kernels/srd.by_unit.json.gz
cf890d82e00211430de288b1a5bd0ad77ed12ddaf445acb1e2ec2ba8e49e7c4f  release/kernels/srd.ccvtrace
46cd18e402a70d5b9f5268dcdf6a899c3f3030a3db5b45f813d4052e5ba1dabc  release/kernels/srd.log
b08eb5e3673cac7eebb8b72af5ed3783c8e70a9e96592e76bf3722551bc79473  release/kernels/srd.oracle.jsonl
a56847072bc073a043e9a1ce85e2839189c5109b38e2ae4a196861a78d12e27d  release/kernels/srd.sv-hosted.log
390a72c2aa56684b4063aedac8234768ed923f09d030bb127c23fe8809b3ebce  release/kernels/stall.by_instr.json.gz
4d05da0110ef4df84dbbafa80e01712bf9671d98676bd0327cf01cf72a3c4a09  release/kernels/stall.by_unit.json.gz
c9f05c331ebf3d5961336e441936588a31be7b440bbe4262765e336d9714a431  release/kernels/stall.ccvtrace
fbab8314601b6e685608b60e99049240c98a1d0e92a81c2b5bb4cb56422428a9  release/kernels/stall.log
500db2c482b07a0706583422cd68878301d0146c1f872ccc1f11bfdcf5c993ef  release/kernels/stall.oracle.jsonl
cf6860048544d075a8b95b5d247451bcb7e55cba73568099fdc633848e6d0c1f  release/kernels/stall.sv-hosted.log
7a981fcd86b7e4d0eae234dc5c519d9d9334f5497e97207f1cc7dac81b777ab8  release/kernels/swap.by_instr.json.gz
38ab124b46a8014bd846fc0f85582682f6f39d5e2f857717c9c51f7a573ee2a6  release/kernels/swap.by_unit.json.gz
49514523ff642d27136fb4fc5f3291f19baac0c64bed9e14dcc975385c1853d7  release/kernels/swap.ccvtrace
5d748fe8b2573db1e22bfd9922bf2269d74a8871793241a53f2f4a225b81243e  release/kernels/swap.log
3658a26316c1ff7bc1744304a42f736e930fcde2865c8913e6cc67a22ce96667  release/kernels/swap.oracle.jsonl
8b5c2ab34d2b2fe4a62bfd9e4c29be9e9894e60e216f2fc949455d7fac70869e  release/kernels/swap.sv-hosted.log
27cf9c52ce959b639bd382ef6a4dedd22ba687b144e3403b372714f1744b2298  release/kernels/transp4.by_instr.json.gz
4cd0da341741a64746755a8760cb2f2dd79a88475a868d1dfd655cab0709ead9  release/kernels/transp4.by_unit.json.gz
3c56dd003b6a4f261fa4b5d7053deef2e1b96e81b0b5d901bacafd9e074bb25e  release/kernels/transp4.ccvtrace
a57dd219e288b4b9888a6d2a332184f66f5af3d33919dd3c91edb7afeb1f85ce  release/kernels/transp4.log
06396ace3ac19677fd39c700e408606e5bdbacb24997d663bbe8872e63dd74fc  release/kernels/transp4.oracle.jsonl
92247d0c9d2bab13be9274c926a7b2e7997772ce7f03ee5a01a194e4296c6727  release/kernels/transp4.sv-hosted.log
b52a83be919d34015ce5f88089f25685430907bdc954f04bc43ea793b6924dcb  release/kernels/unal.by_instr.json.gz
fee1a83f822c8de48ee124010e0106f6e82a882d63648eb2903902ee98267da3  release/kernels/unal.by_unit.json.gz
c4a43409a50de46f08f99543d28fc6bf3af08bb600a73146a90eb82a5df3f1c2  release/kernels/unal.ccvtrace
e5ecc53ed442f8ced638c3fbd862f76d647402580b777c5efd303e4d9e53d02d  release/kernels/unal.log
c3d484bb160657a563df983d9a2532eac27f556636617960aa1e72183ac2b299  release/kernels/unal.oracle.jsonl
8c050bbdc901e67fe7df8c359bcca2bf2f48a6b2e45236463eac9acf36844b09  release/kernels/unal.sv-hosted.log
1d584eeb0f27c2514b0e840ebf88cc701cb31c3d74b8945ff6762595e9e9c78d  release/kernels/vadd.by_instr.json.gz
b11ff26a667bf2d65a13ec5c49d29f6a80cd3f4cc8d9d23404d01220d774b79e  release/kernels/vadd.by_unit.json.gz
aec7002f388f361e00043adaa768672e5ee85872b285a4e758b81c8072aee766  release/kernels/vadd.ccvtrace
63d0250b1c9056b1c2fd1fe3757a4b0e2eea6a821e92bbdae161f32a6dde722e  release/kernels/vadd.log
0276b6d0611a4bbcdc004ab3987214aea138245bc7217504147331689a9c0880  release/kernels/vadd.oracle.jsonl
063ad631c54458339f4ee8dba8bdcf7e5ca3e5dbadb86cf9f6a6b80da683e3c3  release/kernels/vadd.sv-hosted.log
e0c442d79e460d03216611118e98cbfc39cd6d4fabaa204b7c97315198ea52f9  release/kernels/vadd4.by_instr.json.gz
0b4a5eb5f7d36c26399d0c6313fffdfc8fe58ab546cbebb10b1d55c740de4b44  release/kernels/vadd4.by_unit.json.gz
5d7a5785a850b42296f89f50fcd2ac823712dc1013f4d1835a1b2962f8ad89d7  release/kernels/vadd4.ccvtrace
a6aed5cd42aa6b1982135b6a69c9618b089e7d3871f97836d6a13294a3a9a20c  release/kernels/vadd4.log
225aa18fc9f38aa9ad615aa11de254337d59fa705877553d873062c68366e0db  release/kernels/vadd4.oracle.jsonl
3415c8b3521b122eda226087321beb60c45c2c3d372c67bc8bae9ced16f970a4  release/kernels/vadd4.sv-hosted.log
36f0e2bb01edfd0f7190f798ee8f510363e8559e9c31fa6d5ee915a30c52942f  release/kernels/vaddslow.by_instr.json.gz
02de0e1c8f8512ce3fd086eec7a938ba58774eb6ccb5fe0a4511943add9325e9  release/kernels/vaddslow.by_unit.json.gz
7cf8fa5dca7d8999dc20de137e87e4fa47bec2433a999219d51d4d877d2d5d0c  release/kernels/vaddslow.ccvtrace
1cf5dd3d3ba95f00e05dfe9cc2b577ba361a82843311ac05c598a8a39ddebdfb  release/kernels/vaddslow.log
e9e6218e8b8450e9f9ff6b39d659c994a1e51c527a0c5bd10d18b5658ae0e344  release/kernels/vaddslow.oracle.jsonl
8b6d854c732f3d9aedbc2af8ca9abae81b7e824d4c80a6ac535dd2a56f907cd5  release/kernels/vaddslow.sv-hosted.log
41474795da3d536a5953a340df126385dc0b6043fd6232e724b8bc870c2b77f3  release/verify.log
e8d44d712348b775043a5359ac491899a92eab82d1583d6d323ac2c809e03f77  release/wiring.txt
```
