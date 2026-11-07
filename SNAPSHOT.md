# Snapshot snapshot-2026-11-07-1bbbd50

**A generated, read-only snapshot. Do not edit or merge it.** The source
is `ccr-9eb50716-lecnjf` at `1bbbd506b5c6ab074906bec9123650c3bd962427`, and this branch is rebuilt from source by
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
| Source | `ccr-9eb50716-lecnjf` @ `1bbbd506b5c6ab074906bec9123650c3bd962427` |
| Built | 2026-11-07 (UTC) |
| Gate | `tools/verify.sh`: PASS |
| Compiler snapshot | custom-cuda-complier `release` @ `e533ecdfabd1aa267e4cffd49a4d7e1e8c13b263` (source `45ce995c923e7267feb71d87f8f9c5edfefcf0df`) |
| Verilator | Verilator 5.052 2026-09-05 rev v5.052 |
| Icarus | Icarus Verilog version 12.0 (stable) () |
| Yosys | Yosys 0.33 (git sha1 2584903a060) |

## Kernels

| Kernel | Result |
|---|---|
| `addrhigh` | `name=addrhigh finished=1 cycles=84 from_fetch=53 retired=5 issue_groups=6 order=ok gpr_mismatch=0 pred_mismatch=0 mem_mismatch=0 check_failures=0 class_violations=0 overflows=0 credit_leaks=0 channels_used=26/55 violations=0` |
| `addrlimit` | `name=addrlimit finished=1 cycles=1072 from_fetch=1041 retired=5 issue_groups=5 order=ok gpr_mismatch=0 pred_mismatch=0 mem_mismatch=0 check_failures=0 class_violations=0 overflows=0 credit_leaks=0 channels_used=27/55 violations=0` |
| `addrneg` | `name=addrneg finished=1 cycles=84 from_fetch=53 retired=1 issue_groups=2 order=ok gpr_mismatch=0 pred_mismatch=0 mem_mismatch=0 check_failures=0 class_violations=0 overflows=0 credit_leaks=0 channels_used=23/55 violations=0` |
| `borrow` | `name=borrow finished=1 cycles=102 from_fetch=71 retired=7 issue_groups=7 order=ok gpr_mismatch=0 pred_mismatch=0 mem_mismatch=0 check_failures=0 class_violations=0 overflows=0 credit_leaks=0 channels_used=21/55 violations=0` |
| `brs` | `name=brs finished=1 cycles=102 from_fetch=71 retired=12 issue_groups=12 order=ok gpr_mismatch=0 pred_mismatch=0 mem_mismatch=0 check_failures=0 class_violations=0 overflows=0 credit_leaks=0 channels_used=23/55 violations=0` |
| `byp` | `name=byp finished=1 cycles=120 from_fetch=89 retired=14 issue_groups=14 order=ok gpr_mismatch=0 pred_mismatch=0 mem_mismatch=0 check_failures=0 class_violations=0 overflows=0 credit_leaks=0 channels_used=31/55 violations=0` |
| `callret` | `name=callret finished=1 cycles=291 from_fetch=260 retired=40 issue_groups=40 order=ok gpr_mismatch=0 pred_mismatch=0 mem_mismatch=0 check_failures=0 class_violations=0 overflows=0 credit_leaks=0 channels_used=30/55 violations=0` |
| `chains` | `name=chains finished=1 cycles=97 from_fetch=66 retired=29 issue_groups=29 order=ok gpr_mismatch=0 pred_mismatch=0 mem_mismatch=0 check_failures=0 class_violations=0 overflows=0 credit_leaks=0 channels_used=21/55 violations=0` |
| `div` | `name=div finished=1 cycles=1012 from_fetch=981 retired=144 issue_groups=144 order=ok gpr_mismatch=0 pred_mismatch=0 mem_mismatch=0 check_failures=0 class_violations=0 overflows=0 credit_leaks=0 channels_used=23/55 violations=0` |
| `divchw` | `name=divchw finished=1 cycles=114 from_fetch=83 retired=5 issue_groups=6 order=ok gpr_mismatch=0 pred_mismatch=0 mem_mismatch=0 check_failures=0 class_violations=0 overflows=0 credit_leaks=0 channels_used=22/55 violations=0` |
| `divtail` | `name=divtail finished=1 cycles=664 from_fetch=633 retired=96 issue_groups=96 order=ok gpr_mismatch=0 pred_mismatch=0 mem_mismatch=0 check_failures=0 class_violations=0 overflows=0 credit_leaks=0 channels_used=23/55 violations=0` |
| `divtail2` | `name=divtail2 finished=1 cycles=1570 from_fetch=1539 retired=366 issue_groups=366 order=ok gpr_mismatch=0 pred_mismatch=0 mem_mismatch=0 check_failures=0 class_violations=0 overflows=0 credit_leaks=0 channels_used=23/55 violations=0` |
| `fence` | `name=fence finished=1 cycles=83 from_fetch=52 retired=7 issue_groups=7 order=ok gpr_mismatch=0 pred_mismatch=0 mem_mismatch=0 check_failures=0 class_violations=0 overflows=0 credit_leaks=0 channels_used=30/55 violations=0` |
| `gather` | `name=gather finished=1 cycles=267 from_fetch=236 retired=16 issue_groups=16 order=ok gpr_mismatch=0 pred_mismatch=0 mem_mismatch=0 check_failures=0 class_violations=0 overflows=0 credit_leaks=0 channels_used=31/55 violations=0` |
| `hit` | `name=hit finished=1 cycles=234 from_fetch=203 retired=17 issue_groups=17 order=ok gpr_mismatch=0 pred_mismatch=0 mem_mismatch=0 check_failures=0 class_violations=0 overflows=0 credit_leaks=0 channels_used=31/55 violations=0` |
| `lanectx` | `name=lanectx finished=1 cycles=70 from_fetch=39 retired=10 issue_groups=10 order=ok gpr_mismatch=0 pred_mismatch=0 mem_mismatch=0 check_failures=0 class_violations=0 overflows=0 credit_leaks=0 channels_used=29/55 violations=0` |
| `lanectx2` | `name=lanectx2 finished=1 cycles=70 from_fetch=39 retired=10 issue_groups=10 order=ok gpr_mismatch=0 pred_mismatch=0 mem_mismatch=0 check_failures=0 class_violations=0 overflows=0 credit_leaks=0 channels_used=29/55 violations=0` |
| `late` | `name=late finished=1 cycles=175 from_fetch=144 retired=16 issue_groups=16 order=ok gpr_mismatch=0 pred_mismatch=0 mem_mismatch=0 check_failures=0 class_violations=0 overflows=0 credit_leaks=0 channels_used=31/55 violations=0` |
| `ldpar` | `name=ldpar finished=1 cycles=157 from_fetch=126 retired=17 issue_groups=17 order=ok gpr_mismatch=0 pred_mismatch=0 mem_mismatch=0 check_failures=0 class_violations=0 overflows=0 credit_leaks=0 channels_used=31/55 violations=0` |
| `lnorm1` | `name=lnorm1 finished=1 cycles=2637 from_fetch=2606 retired=526 issue_groups=526 order=ok gpr_mismatch=0 pred_mismatch=0 mem_mismatch=0 check_failures=0 class_violations=0 overflows=0 credit_leaks=0 channels_used=37/55 violations=0` |
| `localsp` | `name=localsp finished=1 cycles=4241 from_fetch=4210 retired=40 issue_groups=40 order=ok gpr_mismatch=0 pred_mismatch=0 mem_mismatch=0 check_failures=0 class_violations=0 overflows=0 credit_leaks=0 channels_used=32/55 violations=0` |
| `loop` | `name=loop finished=1 cycles=2942 from_fetch=2911 retired=407 issue_groups=407 order=ok gpr_mismatch=0 pred_mismatch=0 mem_mismatch=0 check_failures=0 class_violations=0 overflows=0 credit_leaks=0 channels_used=23/55 violations=0` |
| `merge` | `name=merge finished=1 cycles=72 from_fetch=41 retired=9 issue_groups=9 order=ok gpr_mismatch=0 pred_mismatch=0 mem_mismatch=0 check_failures=0 class_violations=0 overflows=0 credit_leaks=0 channels_used=21/55 violations=0` |
| `missrun` | `name=missrun finished=1 cycles=123 from_fetch=92 retired=28 issue_groups=28 order=ok gpr_mismatch=0 pred_mismatch=0 mem_mismatch=0 check_failures=0 class_violations=0 overflows=0 credit_leaks=0 channels_used=31/55 violations=0` |
| `mload` | `name=mload finished=1 cycles=113 from_fetch=82 retired=11 issue_groups=11 order=ok gpr_mismatch=0 pred_mismatch=0 mem_mismatch=0 check_failures=0 class_violations=0 overflows=0 credit_leaks=0 channels_used=31/55 violations=0` |
| `mlp` | `name=mlp finished=1 cycles=128 from_fetch=97 retired=21 issue_groups=21 order=ok gpr_mismatch=0 pred_mismatch=0 mem_mismatch=0 check_failures=0 class_violations=0 overflows=0 credit_leaks=0 channels_used=31/55 violations=0` |
| `mwmiss` | `name=mwmiss finished=1 cycles=131 from_fetch=100 retired=88 issue_groups=88 order=ok gpr_mismatch=0 pred_mismatch=0 mem_mismatch=0 check_failures=0 class_violations=0 overflows=0 credit_leaks=0 channels_used=31/55 violations=0` |
| `narrowadd` | `name=narrowadd finished=1 cycles=234 from_fetch=203 retired=21 issue_groups=21 order=ok gpr_mismatch=0 pred_mismatch=0 mem_mismatch=0 check_failures=0 class_violations=0 overflows=0 credit_leaks=0 channels_used=32/55 violations=0` |
| `pguard` | `name=pguard finished=1 cycles=87 from_fetch=56 retired=12 issue_groups=12 order=ok gpr_mismatch=0 pred_mismatch=0 mem_mismatch=0 check_failures=0 class_violations=0 overflows=0 credit_leaks=0 channels_used=29/55 violations=0` |
| `plog` | `name=plog finished=1 cycles=71 from_fetch=40 retired=10 issue_groups=10 order=ok gpr_mismatch=0 pred_mismatch=0 mem_mismatch=0 check_failures=0 class_violations=0 overflows=0 credit_leaks=0 channels_used=21/55 violations=0` |
| `pmovdiv` | `name=pmovdiv finished=1 cycles=107 from_fetch=76 retired=12 issue_groups=12 order=ok gpr_mismatch=0 pred_mismatch=0 mem_mismatch=0 check_failures=0 class_violations=0 overflows=0 credit_leaks=0 channels_used=22/55 violations=0` |
| `predlane` | `name=predlane finished=1 cycles=929 from_fetch=898 retired=10 issue_groups=10 order=ok gpr_mismatch=0 pred_mismatch=0 mem_mismatch=0 check_failures=0 class_violations=0 overflows=0 credit_leaks=0 channels_used=31/55 violations=0` |
| `predmerge` | `name=predmerge finished=1 cycles=942 from_fetch=911 retired=9 issue_groups=9 order=ok gpr_mismatch=0 pred_mismatch=0 mem_mismatch=0 check_failures=0 class_violations=0 overflows=0 credit_leaks=0 channels_used=33/55 violations=0` |
| `predspill` | `name=predspill finished=1 cycles=968 from_fetch=937 retired=12 issue_groups=12 order=ok gpr_mismatch=0 pred_mismatch=0 mem_mismatch=0 check_failures=0 class_violations=0 overflows=0 credit_leaks=0 channels_used=31/55 violations=0` |
| `predswap` | `name=predswap finished=1 cycles=1186 from_fetch=1155 retired=46 issue_groups=46 order=ok gpr_mismatch=0 pred_mismatch=0 mem_mismatch=0 check_failures=0 class_violations=0 overflows=0 credit_leaks=0 channels_used=33/55 violations=0` |
| `privwin` | `name=privwin finished=1 cycles=2218 from_fetch=2187 retired=52 issue_groups=52 order=ok gpr_mismatch=0 pred_mismatch=0 mem_mismatch=0 check_failures=0 class_violations=0 overflows=0 credit_leaks=0 channels_used=34/55 violations=0` |
| `provswap` | `name=provswap finished=1 cycles=2384 from_fetch=2353 retired=978 issue_groups=978 order=ok gpr_mismatch=0 pred_mismatch=0 mem_mismatch=0 check_failures=0 class_violations=0 overflows=0 credit_leaks=0 channels_used=33/55 violations=0` |
| `retmiss` | `name=retmiss finished=1 cycles=188 from_fetch=157 retired=19 issue_groups=19 order=ok gpr_mismatch=0 pred_mismatch=0 mem_mismatch=0 check_failures=0 class_violations=0 overflows=0 credit_leaks=0 channels_used=33/55 violations=0` |
| `roconst` | `name=roconst finished=1 cycles=77 from_fetch=46 retired=4 issue_groups=5 order=ok gpr_mismatch=0 pred_mismatch=0 mem_mismatch=0 check_failures=0 class_violations=0 overflows=0 credit_leaks=0 channels_used=26/55 violations=0` |
| `rogated` | `name=rogated finished=1 cycles=98 from_fetch=67 retired=7 issue_groups=8 order=ok gpr_mismatch=0 pred_mismatch=0 mem_mismatch=0 check_failures=0 class_violations=0 overflows=0 credit_leaks=0 channels_used=26/55 violations=0` |
| `rokill` | `name=rokill finished=1 cycles=106 from_fetch=75 retired=41 issue_groups=4536 order=ok gpr_mismatch=0 pred_mismatch=0 mem_mismatch=0 check_failures=0 class_violations=0 overflows=0 credit_leaks=0 channels_used=27/55 violations=0` |
| `rolaunch` | `name=rolaunch finished=1 cycles=75 from_fetch=44 retired=4 issue_groups=5 order=ok gpr_mismatch=0 pred_mismatch=0 mem_mismatch=0 check_failures=0 class_violations=0 overflows=0 credit_leaks=0 channels_used=24/55 violations=0` |
| `rolimit` | `name=rolimit finished=1 cycles=77 from_fetch=46 retired=4 issue_groups=5 order=ok gpr_mismatch=0 pred_mismatch=0 mem_mismatch=0 check_failures=0 class_violations=0 overflows=0 credit_leaks=0 channels_used=26/55 violations=0` |
| `roload` | `name=roload finished=1 cycles=107 from_fetch=76 retired=8 issue_groups=8 order=ok gpr_mismatch=0 pred_mismatch=0 mem_mismatch=0 check_failures=0 class_violations=0 overflows=0 credit_leaks=0 channels_used=31/55 violations=0` |
| `rope` | `name=rope finished=1 cycles=7765 from_fetch=7734 retired=354 issue_groups=354 order=ok gpr_mismatch=0 pred_mismatch=0 mem_mismatch=0 check_failures=0 class_violations=0 overflows=0 credit_leaks=0 channels_used=34/55 violations=0` |
| `ropediv` | `name=ropediv finished=1 cycles=1152 from_fetch=1121 retired=203 issue_groups=203 order=ok gpr_mismatch=0 pred_mismatch=0 mem_mismatch=0 check_failures=0 class_violations=0 overflows=0 credit_leaks=0 channels_used=34/55 violations=0` |
| `sel` | `name=sel finished=1 cycles=77 from_fetch=46 retired=8 issue_groups=8 order=ok gpr_mismatch=0 pred_mismatch=0 mem_mismatch=0 check_failures=0 class_violations=0 overflows=0 credit_leaks=0 channels_used=29/55 violations=0` |
| `sized` | `name=sized finished=1 cycles=2645 from_fetch=2614 retired=25 issue_groups=25 order=ok gpr_mismatch=0 pred_mismatch=0 mem_mismatch=0 check_failures=0 class_violations=0 overflows=0 credit_leaks=0 channels_used=32/55 violations=0` |
| `slotform` | `name=slotform finished=1 cycles=4368 from_fetch=4337 retired=12 issue_groups=12 order=ok gpr_mismatch=0 pred_mismatch=0 mem_mismatch=0 check_failures=0 class_violations=0 overflows=0 credit_leaks=0 channels_used=32/55 violations=0` |
| `spinwait` | `name=spinwait finished=1 cycles=2279 from_fetch=2248 retired=211 issue_groups=211 order=ok gpr_mismatch=0 pred_mismatch=0 mem_mismatch=0 check_failures=0 class_violations=0 overflows=0 credit_leaks=0 channels_used=34/55 violations=0` |
| `spmbank` | `name=spmbank finished=1 cycles=186 from_fetch=155 retired=13 issue_groups=13 order=ok gpr_mismatch=0 pred_mismatch=0 mem_mismatch=0 check_failures=0 class_violations=0 overflows=0 credit_leaks=0 channels_used=28/55 violations=0` |
| `srd` | `name=srd finished=1 cycles=70 from_fetch=39 retired=6 issue_groups=6 order=ok gpr_mismatch=0 pred_mismatch=0 mem_mismatch=0 check_failures=0 class_violations=0 overflows=0 credit_leaks=0 channels_used=29/55 violations=0` |
| `stall` | `name=stall finished=1 cycles=559 from_fetch=528 retired=116 issue_groups=116 order=ok gpr_mismatch=0 pred_mismatch=0 mem_mismatch=0 check_failures=0 class_violations=0 overflows=0 credit_leaks=0 channels_used=31/55 violations=0` |
| `swap` | `name=swap finished=1 cycles=559 from_fetch=528 retired=174 issue_groups=174 order=ok gpr_mismatch=0 pred_mismatch=0 mem_mismatch=0 check_failures=0 class_violations=0 overflows=0 credit_leaks=0 channels_used=31/55 violations=0` |
| `transp4` | `name=transp4 finished=1 cycles=1182 from_fetch=1151 retired=976 issue_groups=976 order=ok gpr_mismatch=0 pred_mismatch=0 mem_mismatch=0 check_failures=0 class_violations=0 overflows=0 credit_leaks=0 channels_used=37/55 violations=0` |
| `unal` | `name=unal finished=1 cycles=138 from_fetch=107 retired=9 issue_groups=9 order=ok gpr_mismatch=0 pred_mismatch=0 mem_mismatch=0 check_failures=0 class_violations=0 overflows=0 credit_leaks=0 channels_used=31/55 violations=0` |
| `vadd` | `name=vadd finished=1 cycles=160 from_fetch=129 retired=17 issue_groups=17 order=ok gpr_mismatch=0 pred_mismatch=0 mem_mismatch=0 check_failures=0 class_violations=0 overflows=0 credit_leaks=0 channels_used=33/55 violations=0` |
| `vadd4` | `name=vadd4 finished=1 cycles=240 from_fetch=209 retired=68 issue_groups=68 order=ok gpr_mismatch=0 pred_mismatch=0 mem_mismatch=0 check_failures=0 class_violations=0 overflows=0 credit_leaks=0 channels_used=33/55 violations=0` |
| `vaddslow` | `name=vaddslow finished=1 cycles=549 from_fetch=518 retired=17 issue_groups=17 order=ok gpr_mismatch=0 pred_mismatch=0 mem_mismatch=0 check_failures=0 class_violations=0 overflows=0 credit_leaks=0 channels_used=33/55 violations=0` |

## Manifest of release/

```
5b644f3cab988e33ec933e6a7468431577ae2ca281c4921ce521107573c25be2  release/kernels/addrhigh.by_instr.json.gz
ef9a0383cf882735b74b7a980aefab5d1e71f13d1259245ff25277daa6bc3f95  release/kernels/addrhigh.by_unit.json.gz
f92ccc76061283d3fecf9706bc5e3e988b92226ff8042cc4ec6bf1a12a966244  release/kernels/addrhigh.ccvtrace
91208dbf4b0f1fb1ea685128b42ae766299622bd22354c78b92b0cd9615e1a82  release/kernels/addrhigh.log
569f2e22883fad5f0956c57ec734e6afbdd4b8a854e50277425172d6c0cbd766  release/kernels/addrhigh.oracle.jsonl
5cfebd1c247b643cdc7f8f11fc1f5aec2d8ec89a219e581220db7527d1270d51  release/kernels/addrhigh.sv-hosted.log
9a9f6000c80fea57a7b33c9bedb0ece3cd00c4782e9d3e5876189a0868e3ef40  release/kernels/addrlimit.by_instr.json
4e0ca9eda5d81f71a1537c110418d6d182b6d9f9f428ac4f0482eb96ae9a8131  release/kernels/addrlimit.by_unit.json
51b15e6cef986d7625910f902f5b1fadd70865eb6369a4d6611dbd9969afd6c6  release/kernels/addrlimit.ccvtrace
98a911118a1940ea48ae33a6138572910c5dd7d37b2bc8e39eaeee5dc08a1382  release/kernels/addrlimit.log
bc660b0b40359a2c5a2478cb0eb4950b73fd22db50ea76b80052bc195a1920f4  release/kernels/addrlimit.oracle.jsonl
66e97ab05ed82d2a530a573bd9de9eda7e866a117ac670702e1195b5c4444fba  release/kernels/addrlimit.sv-hosted.log
9b81bbeb54364562418fd0f14b866efe1e984f395e7441df0120ba318258f3ff  release/kernels/addrneg.by_instr.json
6c64f73da54149bb68e1e5664b8df91d6116ac75084fd296eda8ff928f0cfc0b  release/kernels/addrneg.by_unit.json
42cc4d45def1f8c23346598415b3fd00d52aa3fcf516fbd63cef11cd2ab784cb  release/kernels/addrneg.ccvtrace
c81f29db1ce0d219156f2d2f8f939cf7043c14126feebdf169f1e3e4d4a65333  release/kernels/addrneg.log
16f5b0707ae44492a1efd67bb9dd38a7e79a7bbd354fa9207b9e7d150ff2f107  release/kernels/addrneg.oracle.jsonl
afb1e2521a61cf80eb29b97f89ba9f5655ae9e7263ca35c654983ee5a86ccfa0  release/kernels/addrneg.sv-hosted.log
f600754262198d480ef06603f6e48e0a973459a0fa9bb0154ca1c04c8bb7cc6e  release/kernels/borrow.by_instr.json.gz
81c4b8c51da199c0348246c9c695b9fcad455d49e862c335756ebdfb93555d8c  release/kernels/borrow.by_unit.json.gz
60d4a4907e35d3efdcb8b9aa284916caa6c739cd8d30e61a20793a637c363a12  release/kernels/borrow.ccvtrace
e8d328fa2e7a7cd5b1bf21cbcd30d15b8cbffce1eeec2b97c63078066a7f16b0  release/kernels/borrow.log
4c565e1ce0b3baee36e158694b32c8defb5cd662b2f9af75cb5d8c26cb1168ed  release/kernels/borrow.oracle.jsonl
eb1f75c7df2e7557079c7d590bbb770571ea7b37b6c072cf250663daed6ecc91  release/kernels/borrow.sv-hosted.log
de5c21327650b50fbb622f5a8d3e85aa46fa07a591ea3019ddc31dbe7d7e67d4  release/kernels/brs.by_instr.json.gz
8c07a5a02039a454dab8957c7f45abba8b7e75e92b2d1dd1c4842c560e35ff2a  release/kernels/brs.by_unit.json.gz
3c159ed22ceb8ed90511b03aa2e714d22e3a4b32ad405ffb8c2b1d4025b2fa0f  release/kernels/brs.ccvtrace
769f0088d8745773e1c8fac881e015b8957d2eea17d023ffe0dd16b7742dd725  release/kernels/brs.log
e3c1cb3379580cf1aae44e8ddc8e846ef6fd661a573cfe0a8d4444b18a14dc56  release/kernels/brs.oracle.jsonl
353924c6b8e1502dbb6f546282f3575e79b5aaa3f6959a406c43e13deec0c1ef  release/kernels/brs.sv-hosted.log
86551a996b9d24a6e3cbc4e1959973a6c285add80ec81eee5075188bd92ff582  release/kernels/byp.by_instr.json.gz
7137e22f6687b1c1f0e0d46ec1961cd7ee1af9e5d85d2991a3798eafcd09b270  release/kernels/byp.by_unit.json.gz
8f1e8a81ec01a2eb71ab9df265b125171ba540b5eade50dcd84d43bcecdba1ce  release/kernels/byp.ccvtrace
a8800ada062b131dd5c9a0b8d67de398c01bb815d9aee177be43937babf23f68  release/kernels/byp.log
5a03dfa4f3603fef49f1e3639e74e34152ca3ca5ef8e41eb959f8323040fa2d5  release/kernels/byp.oracle.jsonl
5bf2f44faa995ac3d7a21fa2c42aa6c940bd9088534822fc976b9ccc9442344f  release/kernels/byp.sv-hosted.log
273b75c1eb15d55a9adf51992a2fb21ed693cc08e5a08e72154086803176c353  release/kernels/callret.by_instr.json.gz
f9813e9df20eed01b3b2e5737946fd0abdf7a550587d948e19894e115b8ed35e  release/kernels/callret.by_unit.json.gz
37a147a811808ea5b7370eb795749afe77a72a6e5132f84bd1b3b90f1037d3a9  release/kernels/callret.ccvtrace
3940a922331253aa5f658257d89511c24fed2a057542f569813f6cc6baa9829e  release/kernels/callret.log
9b1d1b50b527f732362f837250aa2f26dabf3e76e16a4794856ebd8f105635b8  release/kernels/callret.oracle.jsonl
f2f9c02fb4820836ffe4143c8a225e96e4a0e4945c9bbec03493bf291e2cd352  release/kernels/callret.sv-hosted.log
42ea26b519ebea7f242961f4c575bb2dcae8a819422cdf3d3d67f3c0c797ba5b  release/kernels/chains.by_instr.json.gz
a977b9ed5faede6a6ff7e73387e618be1643b461d98963412af073c2348bd2cc  release/kernels/chains.by_unit.json.gz
313b202fd14fdd42517b3b1d8b8c235b947afc3ceba603b365cf65c1818e5fd2  release/kernels/chains.ccvtrace
af2dd0060c95f64a1f99286bc6a9ed1bf273e493c9396eb7b4393ae519ddee3f  release/kernels/chains.log
26a4cc5c5524c7219d8706c2582c80357dea60be9d6ffdec99dac7d0365e2264  release/kernels/chains.oracle.jsonl
f47cbcf6151322ee20d8a9fa3b07db33c865d5cb931789bd164a16deb86cc4e9  release/kernels/chains.sv-hosted.log
c8731178138bc3bb35651508727afb6e47cbfcf802b3e0697fe27e440cddefd6  release/kernels/div.by_instr.json.gz
d268808012b0afd369e25582a241bcd02a98024e83aa57884d9ecbf5db1bee5c  release/kernels/div.by_unit.json.gz
03f7a080135786fc6c51737ca125b335109d4802270839b37a1c6d796702f8c4  release/kernels/div.ccvtrace
d7f39d97801875b770eec9e53c3f23996cc0befb4f4788ccb9169d9a987b4d88  release/kernels/div.log
71a567b85cf85622631490187563de9a5661099c78a590adff4ed0a0c3d24c16  release/kernels/div.oracle.jsonl
5c7a05f3a981c8dc3cfa54c00f853d22f71ddda5fb6c8c942e1417f0f2e218cc  release/kernels/div.sv-hosted.log
5189e78b4162649c2336f2a4061cd10928227dddd846edec1a49d5e351c7fd17  release/kernels/divchw.by_instr.json.gz
014e1151ea8559d905b6a7da390c9e9440f3086eba306017920f542c3230b324  release/kernels/divchw.by_unit.json.gz
dea85525a98956d8e6f00fd4c3dd9a3beacdf911e9f8cbdc1e218629b147de3b  release/kernels/divchw.ccvtrace
fd50bc0e032c88a43e3145d4b0766d8365c487699ab68c090d5551776c015c23  release/kernels/divchw.log
58a541797f7a2df0a1c7528ae6a3edec212db90c7d3eb20656806f38b5c10b3d  release/kernels/divchw.oracle.jsonl
060fc2b555dc0cf70444e0a6bb1e3deabc12b9f1d902b2536af2b30572b1cd5a  release/kernels/divchw.sv-hosted.log
54fdd96855a5c3f8888985bf3f779081021f7f7a5aafc96c117c1bd62dc6b481  release/kernels/divtail.by_instr.json.gz
e890c455e890a19160e5b3bc6e2d3ae09bc8fce0eb28c8a5da61c558ad725080  release/kernels/divtail.by_unit.json.gz
104f3503128d1075c595daded22cf7676320753b5deb157d0c2ffaf8a5d667e6  release/kernels/divtail.ccvtrace
30d6535ae9fdd805baa09b9b3dff36aa903308fa74eaac4502d40d974a103b73  release/kernels/divtail.log
75f11a75c9b3b336e446140af4579f05b46c363a76b7aab3ec88154a07ba097d  release/kernels/divtail.oracle.jsonl
97741a1c0b2c44eeb4d10673f0b0c30e59df0ebf1d09d2d47ad711a84291cbcf  release/kernels/divtail.sv-hosted.log
ff30b68ba9bc24a7f08f94270a038bfad56ebff9543d5ff698f90149601692c7  release/kernels/divtail2.by_instr.json.gz
ae501d95849aef4d240f8f52e26a5a8e821e716c66073abfd5448f464dce924b  release/kernels/divtail2.by_unit.json.gz
f463165bebe816dbba999e0e37027aed61a9c12602f537bba4e9863e2f2fa70c  release/kernels/divtail2.ccvtrace
6d8d528b2918aa851245808d20519ca21ec034c4c2f03081c8ab9192a7a11597  release/kernels/divtail2.log
b2db6b05eb6cf4a0a7677e31d0c6c2952d5cab49d353f0bb1883fe0b2a20ed14  release/kernels/divtail2.oracle.jsonl
7615029c97842a90f5fb331e55d7ae3dcd3391c86cb3c2f7efa158be4407a707  release/kernels/divtail2.sv-hosted.log
864030023ec24e4c3b12ae3044d03fc73f640342c95ca356a9a2d3b98097b0f1  release/kernels/fence.by_instr.json
ddec1d21be74fa496b65bedadcb7fa25dc40d453552038e8c2892e63b71a8cda  release/kernels/fence.by_unit.json.gz
54756eda4ef31ffba82e20c573599678f5a1d7d166907c6dff59b8a7dce41ca7  release/kernels/fence.ccvtrace
c0c62e7557e7ac514ea9ba8d60d1031317e7d20c158b13a2bb7d1ee448189273  release/kernels/fence.log
d1d40317f6cf5bfb430cda1f9c0ef676609e59cabe2a11623c42ffbeca93142b  release/kernels/fence.oracle.jsonl
11b702f63e19b5b8c81c73378bf8169f174d7f9cf8e9f5eade2c209275fcffca  release/kernels/fence.sv-hosted.log
25e65ce55a2e61371d3186c0d3a325c0791b69765ab40d1badaac0823c03f88a  release/kernels/gather.by_instr.json.gz
dc4a215202c686368f6783b6f07c0abe7609079c19ba090788781ee5abc4ed88  release/kernels/gather.by_unit.json.gz
8569f555ae09c560ccedb61b1fdf8c4fc6b8c91bb03078e8e31c86e9ad511938  release/kernels/gather.ccvtrace
a702170b741d70d457b05773e332c34353aae72da72c9bc4ba3d0992ccfd5808  release/kernels/gather.log
0413e781d8d6ff578c64eb1f800b7931e66f676d5cdabb97b94a4033e6037662  release/kernels/gather.oracle.jsonl
0c0fa5a201a657d0ef3769b9f16ec973a8fe8780fb30d2b0e47cc1acf1144453  release/kernels/gather.sv-hosted.log
abffaa03eb0fc2d40e99d364899bf59574ebc3bedc5a0305ac2910cf6e3727eb  release/kernels/hit.by_instr.json.gz
63348746d164a79419e090b6798de951016df8b99f3aa3077f44ac60b7934668  release/kernels/hit.by_unit.json.gz
a33dc3b6368380915891202ae8812821822c2083f3cb4e3a36c21721b524f837  release/kernels/hit.ccvtrace
aa53cdce0cc0905bf18affce4b8dd63e3ce9e897386b95c014fcc4bab087b16e  release/kernels/hit.log
7ba9603e0088d9164de6528f16ef6a7fa9ce5821c8c12b52cbb3734e39b9fd52  release/kernels/hit.oracle.jsonl
6b36df4ff4e95c21ce5936a740cd39d7af30e0f228cc21b5bc7fb721332d98d5  release/kernels/hit.sv-hosted.log
073dd7ed68b5873cb711b1d9d2e55c1e303229f121684561399d23a7d98e0c93  release/kernels/lanectx.by_instr.json.gz
97cddd12cfb379cc519eb18cc1aaffdfbf5123d0504657179eb5b0272cca663d  release/kernels/lanectx.by_unit.json.gz
836f27f9cad92268674e49aa50403fc132ec2bd0052e795730080c81e134bf0e  release/kernels/lanectx.ccvtrace
f00c4f36bea87a518ac3d4ca03cf22e7f8afa411fbc40150639d9f02ce4f4987  release/kernels/lanectx.log
888551babf540db8e3025b82e65ca655013f93eba3c8a65689d069d52a7e6039  release/kernels/lanectx.oracle.jsonl
9291d5a5d993ccce97481d96bd18deb681b3a351ee9d6448ef49e3e1eb5a8e7e  release/kernels/lanectx.sv-hosted.log
5f2ea40d7b7e923166a38ff16e84fa5ac7da1ef442f1b1853769959891934285  release/kernels/lanectx2.by_instr.json.gz
3b87c28e08c91691784245a226dff9c43069aca02d200e159cc9f0a66030f959  release/kernels/lanectx2.by_unit.json.gz
a9d06c3d9da4693bfccc805ebf2d2c7d58b681334ccbce11a02ae00a7ad2c0bc  release/kernels/lanectx2.ccvtrace
3a76c0e00b165564e66a357e6399c92cacfabb8b7334b3008a0a17859a4e4896  release/kernels/lanectx2.log
45c13056dff5c73ed0c9ece56cc36f929bf335322193c7d5eb38710b1d1dfb02  release/kernels/lanectx2.oracle.jsonl
d64e8809b92ea1c0f8f493d1bfc5beabed085d58ac0783b0835913edd5e8f24a  release/kernels/lanectx2.sv-hosted.log
f6c1ecb3aafdf7867784117a63a91c163560d49c6901daebc1e9913c62dc9101  release/kernels/late.by_instr.json.gz
53b547700bbcdc056ba2f0a2b41d858d3b59ef9b4295c3dd1f6af1edba17c9a4  release/kernels/late.by_unit.json.gz
a65d1ca8d0773777cbcdfc67ee91009ea1af7e9d278eebaf43bb726c170f6e2f  release/kernels/late.ccvtrace
5d7b628e42a238d93276e518b842baa545f72913fec5b4531f53adb2e783e96b  release/kernels/late.log
86084f6bd747a2cf32acbc0ebd96ebd3e4ef2d8d9e21be49e3ae49290d7927f3  release/kernels/late.oracle.jsonl
8d1e37c9672e9c560a6a8f787e3fc1e1ee4177082c4a141384edbbe6c020f71e  release/kernels/late.sv-hosted.log
17f77fa2f15a70e4aca763a99b1c43ba853952cf35073de9395d7f883e389c4d  release/kernels/ldpar.by_instr.json.gz
ca01bde20c39ee7e87ca8dba24ae54fb213589d844215c75181878ffbf3ded50  release/kernels/ldpar.by_unit.json.gz
a18d5f44fed9dd44607243d95a7d493482b9c94c11f09f2de4ea0a81138976fa  release/kernels/ldpar.ccvtrace
fd72966795a08c323731bab52368755ff6507f07fe7c4b95afacc29bf32bed96  release/kernels/ldpar.log
8ac08538e9c807637babd61b31e340f7461878ada31f0c0b83cd66331cfaf486  release/kernels/ldpar.oracle.jsonl
10979ce99bb6bbd5dd6f624231dd2a92a76b6e5edda1e435db5da98fd6414b03  release/kernels/ldpar.sv-hosted.log
17c723343099bbb2002f04af399d18cf7a559878ad68a1a4c94a269eefd9f07c  release/kernels/lnorm1.by_instr.json.gz
ba5aece39da0848536d455b438ef83e3fd9fa89f683229724f502e83548ced26  release/kernels/lnorm1.by_unit.json.gz
d6c4806ae5043fde10ce6fff1e76c0e63df55ba09689cb8cb43d86747e1cc480  release/kernels/lnorm1.ccvtrace
340968f9497715ba952f0aeaa6bb7225974565efd49bdce1794bcf7e1e919ed9  release/kernels/lnorm1.log
a8d85811af988a1b9fc00db1517300af3d93ec8e589e403d3b9113fa9e0ffc86  release/kernels/lnorm1.oracle.jsonl
c8b32f2761ec7f3e41c77b7699b91a9bbd6c203e25f607f21c522f4f67218404  release/kernels/lnorm1.sv-hosted.log
76f6266cf848a064cbce8404649648a742700b554a969b129abc3f3ea760df9c  release/kernels/localsp.by_instr.json.gz
3699d65aa814b49a89b28624f0c5ff5b45c47c6bea4622afd8e307066a592372  release/kernels/localsp.by_unit.json.gz
f447ab537f5355461ef186b53067ff4202fefdf9c4795f07b2429dad5d11bca9  release/kernels/localsp.ccvtrace
d7fe7e4b325291c05090d45fcb1e1e8b58a4f1c31829c394e965826f0354fda8  release/kernels/localsp.log
55e3c9f36e7f7d38c0ddd38903aff4bb4509ae862015c592e6b937ea258042ca  release/kernels/localsp.oracle.jsonl
16859815900dd539a384991bcc23f34dfe476ad90a8e3f4e0fefaca3a824b19e  release/kernels/localsp.sv-hosted.log
5c8ccb8aa08eff98584065206910b511d9fd9f9260c1e02a36e361cdfa283a91  release/kernels/loop.by_instr.json.gz
800968bcbedc9982aeabb01f5fa84fb53a839b9c7543f2d7ec7022dff69b8a44  release/kernels/loop.by_unit.json.gz
17f3e2f84ce1fb9b323a46604c530deea7c450d90455e7cee2124ab5801e1562  release/kernels/loop.ccvtrace
6d3e101d401a8d86b59c9ce8d59e74989ced056aca24241f5e85b0d677c71f1b  release/kernels/loop.log
03ce5920c06c93e93516d8e53c3f7169f14e3593de204eacceffc0b8a3e32016  release/kernels/loop.oracle.jsonl
93cad476fcedba2ba5d28e64a8efa458f5e03f47d82f0ef7fa724f6b3cfc7a07  release/kernels/loop.sv-hosted.log
07f6eba5bf0c754b25c666ec72d12b00d6f2ba267298d62e23574e138e48a0a0  release/kernels/merge.by_instr.json.gz
2e5e407dfa825af76e7a19484428f6ebb66b988cdebe3bf50378364c83bd7cb5  release/kernels/merge.by_unit.json.gz
e00c16dee608a887d2d4e4fac629f8f99216d3ee046b249b61873232abefa6aa  release/kernels/merge.ccvtrace
ef8bfd88f899085bba5f5b89f12579b02b7ff68e7b2311d9be409cd6c4d11469  release/kernels/merge.log
f96d28815f8756b1f5a45ded53e6170883d2dfa10f9eef0d14b8050b1318164a  release/kernels/merge.oracle.jsonl
c1145dcd544cc329c66b19bf2861a794b81491c67977ae8f36983c0abf81f8b6  release/kernels/merge.sv-hosted.log
a089a56b7dce7cd3503755bc324e262fa08abf0b808f572d158c469b214a8221  release/kernels/missrun.by_instr.json.gz
b650dcd58a0e5839992d6016d5f9914b864e04043d5b2fb2f33cc402325b966f  release/kernels/missrun.by_unit.json.gz
9b592bd19e02d76d39108c7a7ddc4a4cb52d431fa2a467407bcf04c5e05d9fc0  release/kernels/missrun.ccvtrace
5967832e3809a48a10ec9ac29334d8ab73f6293ef3bd8fd5374412322c72a455  release/kernels/missrun.log
531bdaf281e5590774bd2775427f25e4cc0419cf8e3d5b6999843ffe9ef87258  release/kernels/missrun.oracle.jsonl
686970249d157802ef3bea0eacc64581aaca2a4617befb1888f9662a4b25041a  release/kernels/missrun.sv-hosted.log
e5ef7dbf943ee9a96d7640aaebf816cf0810331ce1c83e76daa2ec970739705c  release/kernels/mload.by_instr.json.gz
716ef27cd8540663d5089fdb2463d797c4f30a8cfda7e264df48c98a58bf4a28  release/kernels/mload.by_unit.json.gz
c6044404ca14f15c0b7d67bc6371e56a9610f6e61fbca22d1af92d4a05b9ba27  release/kernels/mload.ccvtrace
248cc4f91c1040cf9fdb856109538247067583cdd6314c46b254c6ea55349747  release/kernels/mload.log
8000e477b9a95dfb9f0af964e8346acb9d36f1358fd06ffc4ff7cf599d2b8868  release/kernels/mload.oracle.jsonl
ca31cdb401fc8d3cc82761f7e2a0314340c82244edd1a092db5a4af79e3a706b  release/kernels/mload.sv-hosted.log
5c2aa8529ce06aa1a0d0ddd9e08a0eb4e69b9e7eb7f17507c88d5f043bd9e8bd  release/kernels/mlp.by_instr.json.gz
ebc7fe8588ba4f1a9f147c007b984ef0d45e1c67adf03605c9fe3d84e68f4f4e  release/kernels/mlp.by_unit.json.gz
c7a66753a430fcb5a7fe44d984aefb5e2c30fecbcce10559b734fc624df4fafd  release/kernels/mlp.ccvtrace
38420e603511c20cdbcba11b9bd2c569ade43155e57d535dfa4f4efd60d04126  release/kernels/mlp.log
138d282f88d56c8ad648a91af0a983254b55d9fa22942c00d47b327f516a6e44  release/kernels/mlp.oracle.jsonl
aa60ac3ebbfcdcd68ef81dbd8fbdc70aa5fd3d0984ac5d0516ec6fabbd6c55aa  release/kernels/mlp.sv-hosted.log
c70f2d0aab2b0f9f78e95c43a4f5f77623ba16168903693c49a7bb5bcb77c45d  release/kernels/mwmiss.by_instr.json.gz
0ec1ab41f437c6776ff7849fa8569c4b7759601a476265992ff743a4132395bd  release/kernels/mwmiss.by_unit.json.gz
1b4f86ae2e637dbb724db96a88c576943f9602e2e5e1b785367ed6992cc05531  release/kernels/mwmiss.ccvtrace
d87f72ca5ada370e2c370f89d42adaf5b808eded006676af321c4f18c3b8233b  release/kernels/mwmiss.log
8abe8e8997456a2a6711ee72da54d854b24e20abbdab28e4b7271c0d28418de8  release/kernels/mwmiss.oracle.jsonl
575128583fc8f3f99167e3f2e8d6a25f63f300c72dc3f2f22a5414b9aec03c53  release/kernels/mwmiss.sv-hosted.log
287622ea8be41d335f8f01261a0fcbaaf5d3e151a8838697a6f718ed2f70bb50  release/kernels/narrowadd.by_instr.json.gz
6c4777f71c140f864de750bbf49be0d6b10ba1b91ac00f36316431e78c9c18d6  release/kernels/narrowadd.by_unit.json.gz
a332d41d6c3a8243030d4b26a2f4be50c8357c27c0bb0ce3d43a889c2aa8bf93  release/kernels/narrowadd.ccvtrace
2ee9a2b98e9f88dde5ad4a8600c7e8ee35bbfbf0b81dc1eb4b70f869776a3859  release/kernels/narrowadd.log
40a2cf629853dd404bb06b4a07e35abde3d12efc13f26ffe28f923daf2994574  release/kernels/narrowadd.oracle.jsonl
7e7946db3a5e2d48725e97177eb4b92f3186fce0e574309d206f39dc192a9ebe  release/kernels/narrowadd.sv-hosted.log
9977847f49eb4b1fb307d99d432753b815ecd79f5b65efd590f20eb4e3d2dd1c  release/kernels/pguard.by_instr.json.gz
89002789c0ad935072b93008658dd5b84040720c3e2e158c83bb78bf83e6e97f  release/kernels/pguard.by_unit.json.gz
b165cf292061ef6d107cf3e8e545189f28f26e4048e2712afa44e8b2af75b95f  release/kernels/pguard.ccvtrace
47047f8d0e5445c922fb8c468283844e8b2305ff4447f3b11a7a5d9d277872d7  release/kernels/pguard.log
690e56f1cb8d97cbf67124b7dff3ad0a90cb8981814cd1709cf0cd0e035b3bd9  release/kernels/pguard.oracle.jsonl
15f152125ae909b6da297e3ebe4e3ccb29755682db767aae9681560e0e7264d9  release/kernels/pguard.sv-hosted.log
692fbd60bea6c1ef01ba643715a68008f97db05808471cbb26adc09ac16168a6  release/kernels/plog.by_instr.json.gz
453685b74f5a7a9fe3d5bae8c98433c81eef4b7b709d9968330b1d3bab41f0bf  release/kernels/plog.by_unit.json.gz
a63bade7370eb7774bd954fd5a0a79ca928bff9fdc0502b1da37a204b8ee1aeb  release/kernels/plog.ccvtrace
d6381c92c3f7999eff283fc95ce573a9089dee54f2445ddca8c469ba370885ec  release/kernels/plog.log
c230f13f2e1082b306a9c5ab7809ff36cf5c1b2e47dca6b7a71f741524d403f5  release/kernels/plog.oracle.jsonl
a4351a083cfc74124597ea65239dbba86e2d0742ee54e3337654f72ae129628c  release/kernels/plog.sv-hosted.log
7dbf4ebbbbed4b9910b32b909171f526cd978edaa59020449e8eb1f6b0c2f7b2  release/kernels/pmovdiv.by_instr.json.gz
e224113ae4b946461d40b20480e2b66a9bd626ef80253cd4ac3b0d345d8c7586  release/kernels/pmovdiv.by_unit.json.gz
82b5a40f01be204d368a4a4e3da18b9d4da8e65755305215b8181887e213c40a  release/kernels/pmovdiv.ccvtrace
30d10a2204eb205f909e9f4e0b41e1263637797f5c406175a2b873f63d028f8b  release/kernels/pmovdiv.log
7bc646cff6166a51bdce03d7c1b7209e871f0a91d743083a9b910a80bcd0b33f  release/kernels/pmovdiv.oracle.jsonl
82a616c0c0bcbef64177e6b898bc159c23db60ee309775c43a3cad0b36240b03  release/kernels/pmovdiv.sv-hosted.log
8c94319ad01ccbaaa44aeb087cb9bec8f568f495eb00f11da27a241e54ccc759  release/kernels/predlane.by_instr.json.gz
c015d14e9098027f6391c9ec7647f271de76feff4f248b0076dfe0f6c69e9a7b  release/kernels/predlane.by_unit.json.gz
c4d49cdb7f5cf5cbae991d597439492b4400b4278f265da7ba1b40b3282fb55f  release/kernels/predlane.ccvtrace
331bf28f0a41a5eb9c46dcff7a67e191533214e53181ab0f57e9ecb37767e015  release/kernels/predlane.log
c45f4177b9e84fc8a6e36b13534a0c7636eb30a3f8531847100ce5e23bf404b1  release/kernels/predlane.oracle.jsonl
d63a716a592e566e3abb9c618ec804c0d008b334ddd05c94bc3c81f82539e69d  release/kernels/predlane.sv-hosted.log
90d07d5022eb6b6b7cd32490ad2320a29f5dd5533d35b1af0f98ab13e285f5ae  release/kernels/predmerge.by_instr.json.gz
1b1c59aedfdf5fc96df7a13a618670af3575123d335d1bd6c46d8216bc9313bb  release/kernels/predmerge.by_unit.json.gz
248d7f78fee4ee6ceb77db33e1e7c0ba3462774ee3057fa479dbbfabd08a7c77  release/kernels/predmerge.ccvtrace
da7c4aa1912bf56a457183ca255b5321c491496ad32e8b02abfd670ab6c7d3ed  release/kernels/predmerge.log
6c737c49434bcd08e3e0814c8b1dbf15c586ae74f7929ba3148ddcee2c62c845  release/kernels/predmerge.oracle.jsonl
dfeb72686c4d45281ea2e2c390eee92bdd82226b9bbd0eefb44c3ef4e4429d33  release/kernels/predmerge.sv-hosted.log
190bdc4951371c2a338995d0910e52d5e93dd5a74546ca4f55a5b98382d8b5d1  release/kernels/predspill.by_instr.json.gz
1ff707645e48520159df0c37146356388e154789c5fd634f8661a98463be91cc  release/kernels/predspill.by_unit.json.gz
701b3d68a27f03a5648c373243e08c1cf038fdfb108de82bbc7820438a97372f  release/kernels/predspill.ccvtrace
57c9254659491cbc4243f186301db5520ccef5d1722628dbcd20d0504e8ac425  release/kernels/predspill.log
b7c84c6478117ffa0f06da0e6ad1e4628e2683426a7911080810e78e06a5242e  release/kernels/predspill.oracle.jsonl
196f7cf5424ddfd21c79c01d438cf66f7d099837cbec09a40fef8250efc5da86  release/kernels/predspill.sv-hosted.log
43752c12cd3c2711e2712968839f40b3a5c8f7a8c4db0edfde1a6e0ca5ebc42a  release/kernels/predswap.by_instr.json.gz
712f9ec958c01a83997185e20ee632c635501e7f17d00a2fed51cd3f47624ef4  release/kernels/predswap.by_unit.json.gz
468356d38bbe70756cbc66b80be838418029ace4ff0ed6d1b3bc3eb61de46759  release/kernels/predswap.ccvtrace
0ee1aaab7d892229f0b6c2266cab086f2b708fa9593b30903e62089917569e2e  release/kernels/predswap.log
a6d4f7ed517553816d889c7c9eeb6bcfd1f6c973fbf682ecb69f3c2de619f7bb  release/kernels/predswap.oracle.jsonl
78e330315180ef9dc4e7e989629cba33fb750dfb7f893601a379f75d2ee2171d  release/kernels/predswap.sv-hosted.log
d0163ae827023d96c898757298a89388e8ce415c27b9dcf2499344d7841b73ed  release/kernels/privwin.by_instr.json.gz
7f0583156b6788f971eb329984f3bfc920760249d20269aa7fb2801d259bfb70  release/kernels/privwin.by_unit.json.gz
fcaa8889bdf28545a2366f76db61441caadc595273718aef6faab15a35a184eb  release/kernels/privwin.ccvtrace
be2778dd8a43fc0d35fc68841940ca478684a2624248005c573566761a399aee  release/kernels/privwin.log
861f686fc4480363472908d679d8815e8c957d768e7ab32c826930527b0fb7a8  release/kernels/privwin.oracle.jsonl
00a8492f5b783cfd982e37956a61c4d628fc3b39434bb8f7ad6a4ab6bac1128e  release/kernels/privwin.sv-hosted.log
1b575fe643b85deeeb39134fba6ae79a4948c961160f28c8ab51ac6b31ee5587  release/kernels/provswap.by_instr.json.gz
f2ee04aa10d725774228c10581f827d73dc28063de93be1056ba30be31f6864d  release/kernels/provswap.by_unit.json.gz
7a6eca8e7272f09564caadd15413d6ef08bc4f2a0f084e251c4a73ea7d937794  release/kernels/provswap.ccvtrace
483a49beb329ccbc6c0136c64b4315c45a132492a6101841d266135180221037  release/kernels/provswap.log
c9c32a793d54cc7401477f582487f7e8b345b2669a75337b8d6327120d98e5dc  release/kernels/provswap.oracle.jsonl
cc581c700e203a1ebdc23c2d54e0dbf65e5aadcf5918a5f6ace95c00da54813f  release/kernels/provswap.sv-hosted.log
2fd0266832ede2aa2e44d669907f63b9c519f77bc5f7f822194e7c45d0b8042d  release/kernels/retmiss.by_instr.json.gz
a7226f279a71edbf1343a07b7f327d64809ac811d1a92b8fe4059541e9ceaecb  release/kernels/retmiss.by_unit.json.gz
da815578dcc78a1774b3a5ec30e84dbd2af7dd35a3a033110ccc04f56378d965  release/kernels/retmiss.ccvtrace
eab6f734dfc657146286c2485e990b7cc00c9091dc0835ada12ceb089e93fdaa  release/kernels/retmiss.log
e5ef8538e838c6cff7febfc679dd091cf5e002f82d34f1009b1948ce22bc3649  release/kernels/retmiss.oracle.jsonl
6d2519c2982c61c9d61001ac0ed1578b0557ce19c2cbcb2c68e555bfb6fe580c  release/kernels/retmiss.sv-hosted.log
0dd414c6f5b4f0cfc3aed50582c2b44f0f7fee8a733dfa43a2e0a9f3f2e615da  release/kernels/roconst.by_instr.json
3c7cfe34f3fed3595818626291cc306b593455cf22ad2fab2bec5c52b9b14242  release/kernels/roconst.by_unit.json
db557b6301ac43b3fe8e055736fdd1843f4825078d2871ae2f34b691fbd0a2c5  release/kernels/roconst.ccvtrace
3be78d736368a85e7d8e0cf571079f3c9b1a18e695dbcd920b2425408da2c6b7  release/kernels/roconst.log
8087c0671de620162881aecd38cd6114b78e7be6bd71201e3ec02c9a2e2e750e  release/kernels/roconst.oracle.jsonl
1929c93bdffc9623f12c05ba59736333f90165b44251b296534508e1c0d76b2f  release/kernels/roconst.sv-hosted.log
21be2c97484557de875c454d599b5742c7c22b916e8d4e4ea78d9f2a0386f906  release/kernels/rogated.by_instr.json
eb5492d1bb264ec7242105229c2b1d019b644c83e772c3ee74354e0543fdc6e3  release/kernels/rogated.by_unit.json.gz
0d3bda67f9969c7e5bcd848f56e3a86dc04c2d351c3bd42b725db1ffe95d564c  release/kernels/rogated.ccvtrace
c1d18edea369f1128f5d8c232054010c70dff92bade597e4d437b5abe1ef059b  release/kernels/rogated.log
7cd02bd4cceec5a044d6b4d6a80df1e68ed0ae71b0b2a953143636d5b809ea6c  release/kernels/rogated.oracle.jsonl
156b44b7fc4563f0ee7ee148311f8ac0211588fa6f6f11ad302403b7533f5340  release/kernels/rogated.sv-hosted.log
b3a854ce52f1fea48f5713960e360b930279e2dc9c4299847e22fa3a9dcef638  release/kernels/rokill.by_instr.json.gz
1bf169d17310473f916586c66a7bc159134a02b31f1d3640eb4b786a7ba00749  release/kernels/rokill.by_unit.json.gz
8d697db23e7bbcc157f978e832896ac51a9350d5d89127f902c9b88c5f299cfc  release/kernels/rokill.ccvtrace
7c1b9297c0e97418b6f21ff5c13b19fb2a77c9a62419ef68fdd686494eab6a39  release/kernels/rokill.log
94efcef96af469a512d346ce61623980fe86383188eaebd55120f716db596f14  release/kernels/rokill.oracle.jsonl
c3fd4da147060ca8c4f2004feb24c0048df189c374ade9aada57fcb6924c4f7a  release/kernels/rokill.sv-hosted.log
51d0acfffbebae936250c77e136bd854b9e2ec7e600bf649da6bc1c63b738219  release/kernels/rolaunch.by_instr.json
24c3b30ffa16259873268fd312eb264155490bf9edf37d9a99f57b0a92d057a1  release/kernels/rolaunch.by_unit.json
aea4226eaa12f58b7af9be00f3b9a9c2789b887bdb7bad2cecfa160c592a8023  release/kernels/rolaunch.ccvtrace
0418c009f42eaf0b3c4dbf67d4472a100856a5d2c39419ed433926d070b3022c  release/kernels/rolaunch.log
e7dad585c3e70615de04330fd03f4f282c29a005dc1732a35655fb261d51139e  release/kernels/rolaunch.oracle.jsonl
6d76daeba85332daef676bce3eb1053c98e58345573c1a0e0349b9aef5391501  release/kernels/rolaunch.sv-hosted.log
0dd414c6f5b4f0cfc3aed50582c2b44f0f7fee8a733dfa43a2e0a9f3f2e615da  release/kernels/rolimit.by_instr.json
aeab0e2f9fe4ed138cadff19debd4b9f3f9fd3b82e44d96b2c29c8dfcdb72a64  release/kernels/rolimit.by_unit.json
aab0a43b464bbb48fa86f0cea825faf00af642ab1b6a8691dc60a5af6b11fcd5  release/kernels/rolimit.ccvtrace
9629e977669fcc2288a307bfe3ed14d88e56c993fb63a848a83f4d560d76a780  release/kernels/rolimit.log
1c5bc0cb8e8b2e69505fb5a551a16d5d10c56f232b88da7a27e336ad7d962de2  release/kernels/rolimit.oracle.jsonl
def2d056fc22c5da060828812b343a8a34b90503734c02a8a14e19db3f8b7b39  release/kernels/rolimit.sv-hosted.log
d6947d0bf49bde5ec78c3f7f65be7a7e694696eccccbe8ffa6a0002cce95efa7  release/kernels/roload.by_instr.json.gz
ebc254a1011537cf042f87f19aa518d63b35d803a447b307076e3966a26904ed  release/kernels/roload.by_unit.json.gz
c94240054cbc7d6e7ecfd3d4638aeb8e3251ec7102eb419722b20674144f6b3f  release/kernels/roload.ccvtrace
61cc06259965d5a06963e4bc8f5a0475f725e72a632782719cfe46937199a705  release/kernels/roload.log
f7c1309cc9764769fb5803f6fd0f2f5e1eb418f2d23fbe5e17cf5f9106869fdf  release/kernels/roload.oracle.jsonl
7b32be3e0977374c6bc03a6f88f39a865e8b7b45ee5d1d1609da7a20f06df60c  release/kernels/roload.sv-hosted.log
eafcd2341709f755eb27349bc5b2c603f3316790e2ecf2634a223b8497d3427e  release/kernels/rope.by_instr.json.gz
ea35451692d948f10a4b7eed69fd262e17ccae6d44350f63eaca09bbb2f21c89  release/kernels/rope.by_unit.json.gz
c7f75357869cb7defbc03c5f29287693de8a8bf05f4c88b6a86c549ccf358ff8  release/kernels/rope.ccvtrace
737cb9d487e98773f7be64023aa72116b9c576b5803dde294cff17b3b272f9c0  release/kernels/rope.log
d55f9efae392dc8877c102c01c0810e7654b666b6ede386328108164c6cf88f3  release/kernels/rope.oracle.jsonl
1e7e0f959ecf46bafce237aae0586bee773bc83b66e55b805f34edb4690887b5  release/kernels/rope.sv-hosted.log
54a724ef519bff2233243bf9d669d90874cb303736beb10be5a6feec7b0d7134  release/kernels/ropediv.by_instr.json.gz
14fe6f59d5f9ed67392766648cd8ec1251d3f7d5fd0d5e0e5529832d8b7a5e91  release/kernels/ropediv.by_unit.json.gz
b43a56b7279f07f900bb6d35a0df9a70807c286608ef4c4d921d5273a961dab3  release/kernels/ropediv.ccvtrace
cdfd882e26ddf2ad2ca5866f78873a70a8ebc06bdebca1a16b1ae39590fbde86  release/kernels/ropediv.log
10c0ec6ec18b7b44638c790033109198c079d07c1537bf193353ccedd00a920f  release/kernels/ropediv.oracle.jsonl
b80ba7496f2f7a2427f8b15c98cc7af37840c091e4a742bf05f9388e536fa123  release/kernels/ropediv.sv-hosted.log
91163bc1c3ce25748c5334cf7a3536f4931b95515eb006e6a97e8b9c1d0e3cf3  release/kernels/sel.by_instr.json.gz
37a7852db14bd6d839a229ab2aacab08c62f40a6242db8a930ea4acb216657b0  release/kernels/sel.by_unit.json.gz
0dd67c1b8cfef05ec670b5ce105d48435d69df52b8101b2b598a935cc6c81158  release/kernels/sel.ccvtrace
e7d48f7fdc0a48f654b02d64dee4039b8214d03581229789a80ecbe26750935a  release/kernels/sel.log
87f6a81e8afa004c8039bf2f61c90176fcf29ab29bb17ac44aa016a5cc8438fe  release/kernels/sel.oracle.jsonl
1d290657e4d5ac542b6d9337333f5b5d46adc93154d1d29bb5572e37e29b2139  release/kernels/sel.sv-hosted.log
47b1aefb4d0370b5cd4c74b586dc60751fd6a4668c9d50537f31ae1eba388c9a  release/kernels/sized.by_instr.json.gz
562345d1dffd0a13f7d86bc5b751950596ab19a0cf10c176810466bcdeba1b1c  release/kernels/sized.by_unit.json.gz
c1066212d946798aa364f95e36dccfdaed345caca1f1cb07bd486fe8d277e265  release/kernels/sized.ccvtrace
11dfb3a47401346ea2681604dbf7712604ef8e13e1d1324e732e7549396aaa5e  release/kernels/sized.log
36d903ba1618bd1faa437c9812a6ee6c0c966a63196c796267d74bf2695ebc3d  release/kernels/sized.oracle.jsonl
b4453d2316e12d863e8effcb0cb11408327f6a8545af7f5a1d96a4d8f21857d2  release/kernels/sized.sv-hosted.log
9ecda651e24a0b7edfa194db0d3561030cfc287cb29d3cc2f72ddd7a2c31a9a8  release/kernels/slotform.by_instr.json.gz
944dd81326e17013824fb102746839d06831b0d7be78574fb02627130a6dd83b  release/kernels/slotform.by_unit.json.gz
6cce0c0aceac7d08a67283053beb3040a219c7a8399897311540e5b5606b67cd  release/kernels/slotform.ccvtrace
2e631766f1348e0d5a8db76667da2ba34704f7fc5581ed1d463cd334efbc3f34  release/kernels/slotform.log
8b61db7419b18cea8a646fb628218447e72e84a18a9891ffb73b441736138ab9  release/kernels/slotform.oracle.jsonl
c205799a4c4c1c33ffd2198968365b3e69a8c8f3e8f6016979823dec62c8cedd  release/kernels/slotform.sv-hosted.log
591ca0dc250075cffb7950fa50715f4cc16fdf7a09b02f1bd06efbe191ded324  release/kernels/spinwait.by_instr.json.gz
dda121665542dc23ad83876b50035f2d8115d0111e34e3c0747a0366f118fdce  release/kernels/spinwait.by_unit.json.gz
0677f6c21ce6ccec49511537935924c713210f38d0551c42720144e7763cb5f2  release/kernels/spinwait.ccvtrace
87242ea8d86bb2622ac01213af0b50fc60ce399bc32efe4369532cc1d291095a  release/kernels/spinwait.log
868920637236c878b33779bd450439466fc3626996a3164573dc11d437d5c709  release/kernels/spinwait.oracle.jsonl
36530ccf8332d87df353212fce00587ffa1d2d22771a036bb22c1b933044b927  release/kernels/spinwait.sv-hosted.log
54fe19d7a410fb0c879fdef06540d8da02e84b6d082891fdd0913422a65466f7  release/kernels/spmbank.by_instr.json.gz
ea6f935a78831802ce6e27c068af3666895a555ee4ae1e28c6ac3a11d1b4ecb6  release/kernels/spmbank.by_unit.json.gz
1e65cf7ab67487354e2f97ed5720e6074d5082e4f3b5e1b5991317c880166bc5  release/kernels/spmbank.ccvtrace
03b06b39e10aca7a517a242eff3ef9aa45a676ddf75e23132174374dba310174  release/kernels/spmbank.log
3af490cc37d7a92dbe719b57de216b648536eb301ff9d13de9a39f50d150d725  release/kernels/spmbank.oracle.jsonl
ad47da7ae2452c364f56dbbbf954584e18bebaf8df83de010dfecf44ca8fda95  release/kernels/spmbank.sv-hosted.log
d9eb3c4fec8df42ec373207154993ce46b8a7f622cfd1696f0d7650638f6b3cd  release/kernels/srd.by_instr.json.gz
834d58c46f71a549e5cc06970163e4d1fb4966edc1c81ab6a74277d5e078940d  release/kernels/srd.by_unit.json.gz
d3400d1417bb1555644dc8d2f3bd1cf702db1d34aab845fa2b35b229a4f96d27  release/kernels/srd.ccvtrace
4ced265b6cc4bb380256cfa92f4ba581f7bb75a1eedea1d388e763dd328e1394  release/kernels/srd.log
b08eb5e3673cac7eebb8b72af5ed3783c8e70a9e96592e76bf3722551bc79473  release/kernels/srd.oracle.jsonl
a29577998274b2b4e2c1465888f70e880132bd9f5ea39f214f6444cb05a6a698  release/kernels/srd.sv-hosted.log
4582b8baedfbfb997892114b4952192b13db5e4878f0e8e54ecd57e81eb68e94  release/kernels/stall.by_instr.json.gz
3c7d0715ab034d9c50121fbf770aac994c28add4d551160ae3962eac8bc7bec5  release/kernels/stall.by_unit.json.gz
bc3d8b599c578eb9b52befe6f13f4116b90eaf8ec9c0ba01a928a51dfa584459  release/kernels/stall.ccvtrace
e454bed6d2c3767fdfe66bba2e6caeebbd13969c6a26a869cc83452e0c5c3c6f  release/kernels/stall.log
500db2c482b07a0706583422cd68878301d0146c1f872ccc1f11bfdcf5c993ef  release/kernels/stall.oracle.jsonl
24896d1976dcca9bd5b1e911e4b558ce2a50489c03b756943dbc38879ab7f8f7  release/kernels/stall.sv-hosted.log
5f1a8da4dbfb9a6a3a09516975a8520e204fb1fc1ed9bf7a953ec8a61d0817e5  release/kernels/swap.by_instr.json.gz
1312a26cebdce540ff72e9c048f4c54caf4fccd3540e65a45294fe3d94273c1a  release/kernels/swap.by_unit.json.gz
7a3859e6ee395a18542b2fbe60c7bf80345e562a383464ef8dbba8470284108a  release/kernels/swap.ccvtrace
e528e0f8232056102a3b1b51b2c76c90e2504e031438aa88de142e44f4751f03  release/kernels/swap.log
3658a26316c1ff7bc1744304a42f736e930fcde2865c8913e6cc67a22ce96667  release/kernels/swap.oracle.jsonl
11c9b913702877d6633908e3b0fb9a8667eacc1f70b32c1c94795878303bb7ed  release/kernels/swap.sv-hosted.log
b7a2a4adcc18f9e3f00181160c65a351fe0835ba2bb5ef18bd013b4ea9e63956  release/kernels/transp4.by_instr.json.gz
e8bb43242c81f9d484cb0db5cd9ba2170513512621f35b1f37a02c9553c70f7b  release/kernels/transp4.by_unit.json.gz
a6a5d46b09d2561ed270cf11945d09a57ce497a397ea5b96dd67ca8a16135b6d  release/kernels/transp4.ccvtrace
2bcd9ec35550bff27b9744e9e920e105c30ebd239c9320546c9adc06305423df  release/kernels/transp4.log
06396ace3ac19677fd39c700e408606e5bdbacb24997d663bbe8872e63dd74fc  release/kernels/transp4.oracle.jsonl
ac578ac573f921fc5b390e75c62b3e5ff14e0426974597309debe4270c479c20  release/kernels/transp4.sv-hosted.log
82283d1f27102906ffc87addd77ca93b3e95ba68e14c3ac2702838c974a3e07a  release/kernels/unal.by_instr.json.gz
a96e5f94db74de4f472f569ad79d731997d88ff06c44db53ad6e01c2950bc1cd  release/kernels/unal.by_unit.json.gz
c50c25fa5f648bac698f960006b3d674b26bbc6fbe20daa5d02a1fd33c87bb38  release/kernels/unal.ccvtrace
456e476d0d2dc84386e870b00b11fa8bed402056f68b7b97fab1dd34f9dd45ec  release/kernels/unal.log
c3d484bb160657a563df983d9a2532eac27f556636617960aa1e72183ac2b299  release/kernels/unal.oracle.jsonl
685f13add62041f70e3c46cb9544272f793b5dfa9e23d75fa0b9d39f71d99cd7  release/kernels/unal.sv-hosted.log
03169fcd6358f9e38f6b949a27eebc76ec7a691266fd37447e01eb17b3f90d29  release/kernels/vadd.by_instr.json.gz
5208c9563acb7f254f3478f1ada2c0bc41cc068d021c036507690bb8bae7c8cd  release/kernels/vadd.by_unit.json.gz
b5ecc10bb03978f33e96f82c533059d5792e423e17a33ecc311753fa593c4658  release/kernels/vadd.ccvtrace
a3575efb5ef682090c1f2c8e0de4480ac6e0a51130fda2961d81d80f92cf5a06  release/kernels/vadd.log
0276b6d0611a4bbcdc004ab3987214aea138245bc7217504147331689a9c0880  release/kernels/vadd.oracle.jsonl
f97347e48d4b848f577c1594495e5a16ae97122bf39b3865c97b4d5f8fef6f9e  release/kernels/vadd.sv-hosted.log
80a5a9f0ef0a679d3669d8644a99756c10f20bbc04b41f8af867c3b01cfd20e1  release/kernels/vadd4.by_instr.json.gz
00cd0cbdc0e839e84b7cfee60fbf21234113a5e9846e3a96bc9d89d8d0e33765  release/kernels/vadd4.by_unit.json.gz
b83560a84ac1e325662fa8207d558637591155c55d81016725d369d448cb1bf9  release/kernels/vadd4.ccvtrace
1223ad19ccd0c612047993ef51cd46d5a4a55dacc0cdf6e978f4ff98cc734151  release/kernels/vadd4.log
225aa18fc9f38aa9ad615aa11de254337d59fa705877553d873062c68366e0db  release/kernels/vadd4.oracle.jsonl
4a0594dff8d36792e83062e0336c664af8c3574a640833eda8ab0c7b7d0245f8  release/kernels/vadd4.sv-hosted.log
79277b3a7d4544980bc7b690dae0342808b1f283ab5ca07bcfd02a4f56ff04e3  release/kernels/vaddslow.by_instr.json.gz
df8cfd002f5d38e21d8a3f02131af28a084ef163a795c5e746aa1e6b90f20823  release/kernels/vaddslow.by_unit.json.gz
12156640a8994a6a4d385cceae8c3076c05aa0ff2efa5dc10705dbba0efeba48  release/kernels/vaddslow.ccvtrace
422b27f8b22b8a2c3b2afb564ee1a294bfeba7dd85b59bd5616e1830100737b8  release/kernels/vaddslow.log
e9e6218e8b8450e9f9ff6b39d659c994a1e51c527a0c5bd10d18b5658ae0e344  release/kernels/vaddslow.oracle.jsonl
05cf3d8693c7c342fdf8c233580104b04b621ce11c7dd97e22cbee0f1c3474dd  release/kernels/vaddslow.sv-hosted.log
5e5acc1dcdabd6a56e21b01ef46c176c6dc40a0208b9535d9f66bb8420420126  release/verify.log
ecec1a37173b3e9e46a989946881f9d4639255fd582c7a2cbb350aa8629c0401  release/wiring.txt
```
