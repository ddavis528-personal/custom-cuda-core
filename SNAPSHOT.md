# Snapshot snapshot-2026-11-05-76f0190

**A generated, read-only snapshot. Do not edit or merge it.** The source
is `ccr-9eb50716-lecnjf` at `76f0190407d3da92ca8254a31e95b7f4e56b102c`, and this branch is rebuilt from source by
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
| Source | `ccr-9eb50716-lecnjf` @ `76f0190407d3da92ca8254a31e95b7f4e56b102c` |
| Built | 2026-11-05 (UTC) |
| Gate | `tools/verify.sh`: PASS |
| Compiler snapshot | custom-cuda-complier `release` @ `e533ecdfabd1aa267e4cffd49a4d7e1e8c13b263` (source `45ce995c923e7267feb71d87f8f9c5edfefcf0df`) |
| Verilator | Verilator 5.052 2026-09-05 rev v5.052 |
| Icarus | Icarus Verilog version 12.0 (stable) () |
| Yosys | Yosys 0.33 (git sha1 2584903a060) |

## Kernels

| Kernel | Result |
|---|---|
| `addrhigh` | `name=addrhigh finished=1 cycles=82 from_fetch=51 retired=5 issue_groups=6 order=ok gpr_mismatch=0 pred_mismatch=0 mem_mismatch=0 check_failures=0 class_violations=0 overflows=0 credit_leaks=0 channels_used=26/55 violations=0` |
| `addrlimit` | `name=addrlimit finished=1 cycles=1071 from_fetch=1040 retired=5 issue_groups=5 order=ok gpr_mismatch=0 pred_mismatch=0 mem_mismatch=0 check_failures=0 class_violations=0 overflows=0 credit_leaks=0 channels_used=27/55 violations=0` |
| `addrneg` | `name=addrneg finished=1 cycles=82 from_fetch=51 retired=1 issue_groups=2 order=ok gpr_mismatch=0 pred_mismatch=0 mem_mismatch=0 check_failures=0 class_violations=0 overflows=0 credit_leaks=0 channels_used=23/55 violations=0` |
| `borrow` | `name=borrow finished=1 cycles=99 from_fetch=68 retired=7 issue_groups=7 order=ok gpr_mismatch=0 pred_mismatch=0 mem_mismatch=0 check_failures=0 class_violations=0 overflows=0 credit_leaks=0 channels_used=21/55 violations=0` |
| `brs` | `name=brs finished=1 cycles=99 from_fetch=68 retired=12 issue_groups=12 order=ok gpr_mismatch=0 pred_mismatch=0 mem_mismatch=0 check_failures=0 class_violations=0 overflows=0 credit_leaks=0 channels_used=23/55 violations=0` |
| `byp` | `name=byp finished=1 cycles=118 from_fetch=87 retired=14 issue_groups=14 order=ok gpr_mismatch=0 pred_mismatch=0 mem_mismatch=0 check_failures=0 class_violations=0 overflows=0 credit_leaks=0 channels_used=31/55 violations=0` |
| `callret` | `name=callret finished=1 cycles=280 from_fetch=249 retired=40 issue_groups=40 order=ok gpr_mismatch=0 pred_mismatch=0 mem_mismatch=0 check_failures=0 class_violations=0 overflows=0 credit_leaks=0 channels_used=30/55 violations=0` |
| `chains` | `name=chains finished=1 cycles=96 from_fetch=65 retired=29 issue_groups=29 order=ok gpr_mismatch=0 pred_mismatch=0 mem_mismatch=0 check_failures=0 class_violations=0 overflows=0 credit_leaks=0 channels_used=21/55 violations=0` |
| `div` | `name=div finished=1 cycles=978 from_fetch=947 retired=144 issue_groups=144 order=ok gpr_mismatch=0 pred_mismatch=0 mem_mismatch=0 check_failures=0 class_violations=0 overflows=0 credit_leaks=0 channels_used=23/55 violations=0` |
| `divchw` | `name=divchw finished=1 cycles=110 from_fetch=79 retired=5 issue_groups=6 order=ok gpr_mismatch=0 pred_mismatch=0 mem_mismatch=0 check_failures=0 class_violations=0 overflows=0 credit_leaks=0 channels_used=22/55 violations=0` |
| `divtail` | `name=divtail finished=1 cycles=642 from_fetch=611 retired=96 issue_groups=96 order=ok gpr_mismatch=0 pred_mismatch=0 mem_mismatch=0 check_failures=0 class_violations=0 overflows=0 credit_leaks=0 channels_used=23/55 violations=0` |
| `divtail2` | `name=divtail2 finished=1 cycles=1517 from_fetch=1486 retired=366 issue_groups=366 order=ok gpr_mismatch=0 pred_mismatch=0 mem_mismatch=0 check_failures=0 class_violations=0 overflows=0 credit_leaks=0 channels_used=23/55 violations=0` |
| `fence` | `name=fence finished=1 cycles=82 from_fetch=51 retired=7 issue_groups=7 order=ok gpr_mismatch=0 pred_mismatch=0 mem_mismatch=0 check_failures=0 class_violations=0 overflows=0 credit_leaks=0 channels_used=30/55 violations=0` |
| `gather` | `name=gather finished=1 cycles=265 from_fetch=234 retired=16 issue_groups=16 order=ok gpr_mismatch=0 pred_mismatch=0 mem_mismatch=0 check_failures=0 class_violations=0 overflows=0 credit_leaks=0 channels_used=31/55 violations=0` |
| `hit` | `name=hit finished=1 cycles=227 from_fetch=196 retired=17 issue_groups=17 order=ok gpr_mismatch=0 pred_mismatch=0 mem_mismatch=0 check_failures=0 class_violations=0 overflows=0 credit_leaks=0 channels_used=31/55 violations=0` |
| `lanectx` | `name=lanectx finished=1 cycles=69 from_fetch=38 retired=10 issue_groups=10 order=ok gpr_mismatch=0 pred_mismatch=0 mem_mismatch=0 check_failures=0 class_violations=0 overflows=0 credit_leaks=0 channels_used=29/55 violations=0` |
| `lanectx2` | `name=lanectx2 finished=1 cycles=69 from_fetch=38 retired=10 issue_groups=10 order=ok gpr_mismatch=0 pred_mismatch=0 mem_mismatch=0 check_failures=0 class_violations=0 overflows=0 credit_leaks=0 channels_used=29/55 violations=0` |
| `late` | `name=late finished=1 cycles=171 from_fetch=140 retired=16 issue_groups=16 order=ok gpr_mismatch=0 pred_mismatch=0 mem_mismatch=0 check_failures=0 class_violations=0 overflows=0 credit_leaks=0 channels_used=31/55 violations=0` |
| `ldpar` | `name=ldpar finished=1 cycles=154 from_fetch=123 retired=17 issue_groups=17 order=ok gpr_mismatch=0 pred_mismatch=0 mem_mismatch=0 check_failures=0 class_violations=0 overflows=0 credit_leaks=0 channels_used=31/55 violations=0` |
| `lnorm1` | `name=lnorm1 finished=1 cycles=2593 from_fetch=2562 retired=526 issue_groups=526 order=ok gpr_mismatch=0 pred_mismatch=0 mem_mismatch=0 check_failures=0 class_violations=0 overflows=0 credit_leaks=0 channels_used=37/55 violations=0` |
| `localsp` | `name=localsp finished=1 cycles=4238 from_fetch=4207 retired=40 issue_groups=40 order=ok gpr_mismatch=0 pred_mismatch=0 mem_mismatch=0 check_failures=0 class_violations=0 overflows=0 credit_leaks=0 channels_used=32/55 violations=0` |
| `loop` | `name=loop finished=1 cycles=2842 from_fetch=2811 retired=407 issue_groups=407 order=ok gpr_mismatch=0 pred_mismatch=0 mem_mismatch=0 check_failures=0 class_violations=0 overflows=0 credit_leaks=0 channels_used=23/55 violations=0` |
| `merge` | `name=merge finished=1 cycles=71 from_fetch=40 retired=9 issue_groups=9 order=ok gpr_mismatch=0 pred_mismatch=0 mem_mismatch=0 check_failures=0 class_violations=0 overflows=0 credit_leaks=0 channels_used=21/55 violations=0` |
| `missrun` | `name=missrun finished=1 cycles=121 from_fetch=90 retired=28 issue_groups=28 order=ok gpr_mismatch=0 pred_mismatch=0 mem_mismatch=0 check_failures=0 class_violations=0 overflows=0 credit_leaks=0 channels_used=31/55 violations=0` |
| `mload` | `name=mload finished=1 cycles=111 from_fetch=80 retired=11 issue_groups=11 order=ok gpr_mismatch=0 pred_mismatch=0 mem_mismatch=0 check_failures=0 class_violations=0 overflows=0 credit_leaks=0 channels_used=31/55 violations=0` |
| `mlp` | `name=mlp finished=1 cycles=126 from_fetch=95 retired=21 issue_groups=21 order=ok gpr_mismatch=0 pred_mismatch=0 mem_mismatch=0 check_failures=0 class_violations=0 overflows=0 credit_leaks=0 channels_used=31/55 violations=0` |
| `mwmiss` | `name=mwmiss finished=1 cycles=129 from_fetch=98 retired=88 issue_groups=88 order=ok gpr_mismatch=0 pred_mismatch=0 mem_mismatch=0 check_failures=0 class_violations=0 overflows=0 credit_leaks=0 channels_used=31/55 violations=0` |
| `narrowadd` | `name=narrowadd finished=1 cycles=226 from_fetch=195 retired=21 issue_groups=21 order=ok gpr_mismatch=0 pred_mismatch=0 mem_mismatch=0 check_failures=0 class_violations=0 overflows=0 credit_leaks=0 channels_used=32/55 violations=0` |
| `pguard` | `name=pguard finished=1 cycles=86 from_fetch=55 retired=12 issue_groups=12 order=ok gpr_mismatch=0 pred_mismatch=0 mem_mismatch=0 check_failures=0 class_violations=0 overflows=0 credit_leaks=0 channels_used=29/55 violations=0` |
| `plog` | `name=plog finished=1 cycles=70 from_fetch=39 retired=10 issue_groups=10 order=ok gpr_mismatch=0 pred_mismatch=0 mem_mismatch=0 check_failures=0 class_violations=0 overflows=0 credit_leaks=0 channels_used=21/55 violations=0` |
| `pmovdiv` | `name=pmovdiv finished=1 cycles=104 from_fetch=73 retired=12 issue_groups=12 order=ok gpr_mismatch=0 pred_mismatch=0 mem_mismatch=0 check_failures=0 class_violations=0 overflows=0 credit_leaks=0 channels_used=22/55 violations=0` |
| `predlane` | `name=predlane finished=1 cycles=927 from_fetch=896 retired=10 issue_groups=10 order=ok gpr_mismatch=0 pred_mismatch=0 mem_mismatch=0 check_failures=0 class_violations=0 overflows=0 credit_leaks=0 channels_used=31/55 violations=0` |
| `predmerge` | `name=predmerge finished=1 cycles=939 from_fetch=908 retired=9 issue_groups=9 order=ok gpr_mismatch=0 pred_mismatch=0 mem_mismatch=0 check_failures=0 class_violations=0 overflows=0 credit_leaks=0 channels_used=33/55 violations=0` |
| `predspill` | `name=predspill finished=1 cycles=966 from_fetch=935 retired=12 issue_groups=12 order=ok gpr_mismatch=0 pred_mismatch=0 mem_mismatch=0 check_failures=0 class_violations=0 overflows=0 credit_leaks=0 channels_used=31/55 violations=0` |
| `predswap` | `name=predswap finished=1 cycles=1178 from_fetch=1147 retired=46 issue_groups=46 order=ok gpr_mismatch=0 pred_mismatch=0 mem_mismatch=0 check_failures=0 class_violations=0 overflows=0 credit_leaks=0 channels_used=33/55 violations=0` |
| `privwin` | `name=privwin finished=1 cycles=2215 from_fetch=2184 retired=52 issue_groups=52 order=ok gpr_mismatch=0 pred_mismatch=0 mem_mismatch=0 check_failures=0 class_violations=0 overflows=0 credit_leaks=0 channels_used=34/55 violations=0` |
| `provswap` | `name=provswap finished=1 cycles=2313 from_fetch=2282 retired=978 issue_groups=978 order=ok gpr_mismatch=0 pred_mismatch=0 mem_mismatch=0 check_failures=0 class_violations=0 overflows=0 credit_leaks=0 channels_used=33/55 violations=0` |
| `roconst` | `name=roconst finished=1 cycles=75 from_fetch=44 retired=4 issue_groups=5 order=ok gpr_mismatch=0 pred_mismatch=0 mem_mismatch=0 check_failures=0 class_violations=0 overflows=0 credit_leaks=0 channels_used=26/55 violations=0` |
| `rogated` | `name=rogated finished=1 cycles=95 from_fetch=64 retired=7 issue_groups=8 order=ok gpr_mismatch=0 pred_mismatch=0 mem_mismatch=0 check_failures=0 class_violations=0 overflows=0 credit_leaks=0 channels_used=26/55 violations=0` |
| `rokill` | `name=rokill finished=1 cycles=103 from_fetch=72 retired=41 issue_groups=4536 order=ok gpr_mismatch=0 pred_mismatch=0 mem_mismatch=0 check_failures=0 class_violations=0 overflows=0 credit_leaks=0 channels_used=27/55 violations=0` |
| `rolaunch` | `name=rolaunch finished=1 cycles=73 from_fetch=42 retired=4 issue_groups=5 order=ok gpr_mismatch=0 pred_mismatch=0 mem_mismatch=0 check_failures=0 class_violations=0 overflows=0 credit_leaks=0 channels_used=24/55 violations=0` |
| `rolimit` | `name=rolimit finished=1 cycles=75 from_fetch=44 retired=4 issue_groups=5 order=ok gpr_mismatch=0 pred_mismatch=0 mem_mismatch=0 check_failures=0 class_violations=0 overflows=0 credit_leaks=0 channels_used=26/55 violations=0` |
| `roload` | `name=roload finished=1 cycles=105 from_fetch=74 retired=8 issue_groups=8 order=ok gpr_mismatch=0 pred_mismatch=0 mem_mismatch=0 check_failures=0 class_violations=0 overflows=0 credit_leaks=0 channels_used=31/55 violations=0` |
| `rope` | `name=rope finished=1 cycles=7753 from_fetch=7722 retired=354 issue_groups=354 order=ok gpr_mismatch=0 pred_mismatch=0 mem_mismatch=0 check_failures=0 class_violations=0 overflows=0 credit_leaks=0 channels_used=34/55 violations=0` |
| `ropediv` | `name=ropediv finished=1 cycles=1120 from_fetch=1089 retired=203 issue_groups=203 order=ok gpr_mismatch=0 pred_mismatch=0 mem_mismatch=0 check_failures=0 class_violations=0 overflows=0 credit_leaks=0 channels_used=34/55 violations=0` |
| `sel` | `name=sel finished=1 cycles=76 from_fetch=45 retired=8 issue_groups=8 order=ok gpr_mismatch=0 pred_mismatch=0 mem_mismatch=0 check_failures=0 class_violations=0 overflows=0 credit_leaks=0 channels_used=29/55 violations=0` |
| `sized` | `name=sized finished=1 cycles=2640 from_fetch=2609 retired=25 issue_groups=25 order=ok gpr_mismatch=0 pred_mismatch=0 mem_mismatch=0 check_failures=0 class_violations=0 overflows=0 credit_leaks=0 channels_used=32/55 violations=0` |
| `slotform` | `name=slotform finished=1 cycles=4365 from_fetch=4334 retired=12 issue_groups=12 order=ok gpr_mismatch=0 pred_mismatch=0 mem_mismatch=0 check_failures=0 class_violations=0 overflows=0 credit_leaks=0 channels_used=32/55 violations=0` |
| `spinwait` | `name=spinwait finished=1 cycles=2181 from_fetch=2150 retired=211 issue_groups=211 order=ok gpr_mismatch=0 pred_mismatch=0 mem_mismatch=0 check_failures=0 class_violations=0 overflows=0 credit_leaks=0 channels_used=34/55 violations=0` |
| `spmbank` | `name=spmbank finished=1 cycles=185 from_fetch=154 retired=13 issue_groups=13 order=ok gpr_mismatch=0 pred_mismatch=0 mem_mismatch=0 check_failures=0 class_violations=0 overflows=0 credit_leaks=0 channels_used=28/55 violations=0` |
| `srd` | `name=srd finished=1 cycles=69 from_fetch=38 retired=6 issue_groups=6 order=ok gpr_mismatch=0 pred_mismatch=0 mem_mismatch=0 check_failures=0 class_violations=0 overflows=0 credit_leaks=0 channels_used=29/55 violations=0` |
| `stall` | `name=stall finished=1 cycles=556 from_fetch=525 retired=116 issue_groups=116 order=ok gpr_mismatch=0 pred_mismatch=0 mem_mismatch=0 check_failures=0 class_violations=0 overflows=0 credit_leaks=0 channels_used=31/55 violations=0` |
| `swap` | `name=swap finished=1 cycles=556 from_fetch=525 retired=174 issue_groups=174 order=ok gpr_mismatch=0 pred_mismatch=0 mem_mismatch=0 check_failures=0 class_violations=0 overflows=0 credit_leaks=0 channels_used=31/55 violations=0` |
| `transp4` | `name=transp4 finished=1 cycles=1169 from_fetch=1138 retired=976 issue_groups=976 order=ok gpr_mismatch=0 pred_mismatch=0 mem_mismatch=0 check_failures=0 class_violations=0 overflows=0 credit_leaks=0 channels_used=37/55 violations=0` |
| `unal` | `name=unal finished=1 cycles=136 from_fetch=105 retired=9 issue_groups=9 order=ok gpr_mismatch=0 pred_mismatch=0 mem_mismatch=0 check_failures=0 class_violations=0 overflows=0 credit_leaks=0 channels_used=31/55 violations=0` |
| `vadd` | `name=vadd finished=1 cycles=157 from_fetch=126 retired=17 issue_groups=17 order=ok gpr_mismatch=0 pred_mismatch=0 mem_mismatch=0 check_failures=0 class_violations=0 overflows=0 credit_leaks=0 channels_used=33/55 violations=0` |
| `vadd4` | `name=vadd4 finished=1 cycles=203 from_fetch=172 retired=68 issue_groups=68 order=ok gpr_mismatch=0 pred_mismatch=0 mem_mismatch=0 check_failures=0 class_violations=0 overflows=0 credit_leaks=0 channels_used=33/55 violations=0` |
| `vaddslow` | `name=vaddslow finished=1 cycles=546 from_fetch=515 retired=17 issue_groups=17 order=ok gpr_mismatch=0 pred_mismatch=0 mem_mismatch=0 check_failures=0 class_violations=0 overflows=0 credit_leaks=0 channels_used=33/55 violations=0` |

## Manifest of release/

```
8273b11e3166b81483d090cdea4df93cd316588cdde9b5f4a5181d237fa7a310  release/kernels/addrhigh.by_instr.json.gz
8e7f80fd0dd41fd95eedc9996b5c519390c8a19621d3b76ac21f0f8bae7d8ad2  release/kernels/addrhigh.by_unit.json.gz
b175798e2fd8f57c283d8fba170ec45acef11a16d99ba22e0375ccf9247e005c  release/kernels/addrhigh.ccvtrace
d4f6b7c951d7e2e5bcc8f5aee3128cc31e89bfe882afbc79b593efbf466fb604  release/kernels/addrhigh.log
569f2e22883fad5f0956c57ec734e6afbdd4b8a854e50277425172d6c0cbd766  release/kernels/addrhigh.oracle.jsonl
835b6262dd025c353e7faf84caffdaf80a5c4cc407e597b692ceb6c9abb2eb78  release/kernels/addrhigh.sv-hosted.log
324c5ee0b5d69196019059717eb183c62f2e6556381aee1d2e9ec8fc15c94e25  release/kernels/addrlimit.by_instr.json
37138197deaadc65235fafcbd14dbf2667e1fcb6d1aa10864cdf975bdf46bc5d  release/kernels/addrlimit.by_unit.json
d5dbe16b24fadb69a590b2fef7ec9b31a5f87c5f68044dff13ffc3207480069a  release/kernels/addrlimit.ccvtrace
06a21b0e3c33fb90f58a4ab19a8e78308e1dca6ecb1857fec6841faa8873b827  release/kernels/addrlimit.log
bc660b0b40359a2c5a2478cb0eb4950b73fd22db50ea76b80052bc195a1920f4  release/kernels/addrlimit.oracle.jsonl
7af569299938bd7238dfa61fcf077f72625c1044eaeed061f4b727bc99632ac1  release/kernels/addrlimit.sv-hosted.log
bdfb876c93f11bf3a31a5971cec55740751feb04d27cdaf37f8c2fab4b9888bc  release/kernels/addrneg.by_instr.json
9e7b1d7e04c98881865811ac1ec1a0b7223b16ab63012ce6363a6d2c3bb5235b  release/kernels/addrneg.by_unit.json
56a97314f220be4741d3dda7171f5edd02977a576b979a49dcc744ca0d16b8b1  release/kernels/addrneg.ccvtrace
b52160ba7a47ecafcf6751164509308614b340332c954ef7437d4817a732ffae  release/kernels/addrneg.log
16f5b0707ae44492a1efd67bb9dd38a7e79a7bbd354fa9207b9e7d150ff2f107  release/kernels/addrneg.oracle.jsonl
6735afa3f13580cff1e9cc917a729afd9fc758c3c8725c063eda7420179e5234  release/kernels/addrneg.sv-hosted.log
0c7e30b90a6856b0e4f06f9da36994154662d38c5f2eac4529dd52807b59916e  release/kernels/borrow.by_instr.json.gz
fd60e9c72826c17d4394d0f277b6d0e7ddb4ff2be13b17955ea1894bf129c2ed  release/kernels/borrow.by_unit.json.gz
b1b1de7f88ea23ed04df28b7118ff3a479e977b8ddde8ea9b3fc68521cfe0476  release/kernels/borrow.ccvtrace
1e3aa559d063a696eeb01b42f04876e6abb964be34ae688eed39fe3f2b13ec97  release/kernels/borrow.log
4c565e1ce0b3baee36e158694b32c8defb5cd662b2f9af75cb5d8c26cb1168ed  release/kernels/borrow.oracle.jsonl
61e0fb01411ceecbfd950d6e656ca4761c940d48fa9765c0ad52bdc5f70775b4  release/kernels/borrow.sv-hosted.log
235b5ab8aba0d96060a19ced89bb6041aa75e8bf138e6f4422a5b039c429c7ac  release/kernels/brs.by_instr.json.gz
d2dd2327d9668caa4d110e6c1a2ec8d8d369722e0d0cfa50955212fe1b73a2aa  release/kernels/brs.by_unit.json.gz
d5df2854702c766c74f2671b15b1d26f54af81270c8ee8506defdb7db83e7f7a  release/kernels/brs.ccvtrace
a917e8078d8c700ca64eab7fdd7899f3a42c6e0d8e0e6cc048f03c54c68e1a33  release/kernels/brs.log
e3c1cb3379580cf1aae44e8ddc8e846ef6fd661a573cfe0a8d4444b18a14dc56  release/kernels/brs.oracle.jsonl
e880011e276de696a6213bbbae7f175fb64b1f510f0135fe5f8a1798dc6cafdb  release/kernels/brs.sv-hosted.log
b040c597b6038ef8e7a098b36419434b110de24cce525f519012d61cf2e74165  release/kernels/byp.by_instr.json.gz
190cdb635cacdea72a9fcb9c09241ac89ee72c522935a5c04ebab3f5d0563910  release/kernels/byp.by_unit.json.gz
dc78591153535667e07ffb7559bb911166664c57f2596c4f83e9b83b7e2ea890  release/kernels/byp.ccvtrace
58750bde70e71a22904438964aea8df75b91480d55bc3d8f54f6644b0df7f14e  release/kernels/byp.log
5a03dfa4f3603fef49f1e3639e74e34152ca3ca5ef8e41eb959f8323040fa2d5  release/kernels/byp.oracle.jsonl
7affc487c7ce822564690a1dee961d6f6f280be1b8786f5659f758aa21bef326  release/kernels/byp.sv-hosted.log
c4924147c817862e44efdb7c9ca0beea1360fa43c13e4234618bf7395d8b7c86  release/kernels/callret.by_instr.json.gz
26fd108d882573534202bc66eb9e1fc7a6ea30dae45d8c14682797f88956cc92  release/kernels/callret.by_unit.json.gz
42badb68827317d094b74e90961ea5dfbd7baa5f52604d6a6535d9d839f2604c  release/kernels/callret.ccvtrace
0c80e6ee86fdcffd4087370b45f3b793405bd0f8729f829c8455519e3f1cfad6  release/kernels/callret.log
9b1d1b50b527f732362f837250aa2f26dabf3e76e16a4794856ebd8f105635b8  release/kernels/callret.oracle.jsonl
367b6b2443d9c220c6c509a82bf89a2c5184a918e457056d47dfd35a1a3ac51e  release/kernels/callret.sv-hosted.log
8c0c4daf97b41f293aafa6c9092927b28ba69cf4b185a48e890d0466d705f29e  release/kernels/chains.by_instr.json.gz
32cda038c16129e65ac9908809bc28ed01358230cfeb9e0f5816b0cecff0565c  release/kernels/chains.by_unit.json.gz
0f01fc6119ede7aae5700046b1bd2dbacae4a4233da67178644fcfb462d9b861  release/kernels/chains.ccvtrace
8df8a2998051cff04a0068d13f6e2ecbbffbc77303dac121ccd7ad8007a3a99e  release/kernels/chains.log
26a4cc5c5524c7219d8706c2582c80357dea60be9d6ffdec99dac7d0365e2264  release/kernels/chains.oracle.jsonl
bb5ddc9c2a0b581a1f2176a1c1f91c9c9b851293f9810528f9b5668607ea4e72  release/kernels/chains.sv-hosted.log
54cc9243c9a58bcc43cd6fb19817f4d516a7934e3146b8daa541bf042da1e84e  release/kernels/div.by_instr.json.gz
4db2f924a4fd1a683c972b98c9f1bd57b3dc2ca74b0b37a0d49b9ecfe91f6a92  release/kernels/div.by_unit.json.gz
1a87454359aacda0a3bc33c2f6cef67dbbca4d95007c0feb36992aece1fbee5b  release/kernels/div.ccvtrace
f07f06c6e8f142d9743f7d71d36399453b0b408668cdb69861fc359722f02530  release/kernels/div.log
71a567b85cf85622631490187563de9a5661099c78a590adff4ed0a0c3d24c16  release/kernels/div.oracle.jsonl
157068516cc0229e7f69515ea950ece827a4d8b3767cb6fe6bc4856b0971e66a  release/kernels/div.sv-hosted.log
5835f53e6039c014440d0d44316ed71912a30dddb6e0fe3ebe433606ed3bef4e  release/kernels/divchw.by_instr.json.gz
5d282e3382dd82c0cd693ff6d4dd54f59ac58af0163195981633c2ac04ee438f  release/kernels/divchw.by_unit.json.gz
f3c3bff856f89fdcc486184c065c0b500752b843ab459f5545639c74c5701c19  release/kernels/divchw.ccvtrace
1772c7952ebc966242c3246e746bc453bbdd474ee8fcadd1d4825c45d696a080  release/kernels/divchw.log
58a541797f7a2df0a1c7528ae6a3edec212db90c7d3eb20656806f38b5c10b3d  release/kernels/divchw.oracle.jsonl
a80f38f58a459a5898fd089701956deddfd2bb965aa1c81381eeb08cd1d0bcb6  release/kernels/divchw.sv-hosted.log
2d05502dcea9f37b3ae8d2e84c12f98662ba9834163b32fd3892028c2602d914  release/kernels/divtail.by_instr.json.gz
78c06bf8dfdf6044921f0c196a86ad9bd929395733eacc465d54697d64e97eb4  release/kernels/divtail.by_unit.json.gz
686fc80ca2368c9eea00efa35201047f9f81e383610791604b8d0dc7862a236b  release/kernels/divtail.ccvtrace
eb2bb8136ca4da0e02244388923dd9fc15a616b43aa7aff787233c34108f9f96  release/kernels/divtail.log
75f11a75c9b3b336e446140af4579f05b46c363a76b7aab3ec88154a07ba097d  release/kernels/divtail.oracle.jsonl
7386aa2fb54c21d835b0efd12bf74716f9d805d3c80c633a50b0ccdd004aa1aa  release/kernels/divtail.sv-hosted.log
db2482291b6af64202f802ed5b99b528e94053b14e143bff34b7acd2f4aa7ccf  release/kernels/divtail2.by_instr.json.gz
070914b32c2446d986b8e7dcd1d260470af78058b80f853240e4def28b6fafdf  release/kernels/divtail2.by_unit.json.gz
f58de869e6c88288c534ea64420874dcfa553236c75d77d78aea637f387a484e  release/kernels/divtail2.ccvtrace
05bf220bb7f3397673235dccd463b7d77bc2402916301771fc181ce5a77e7b6d  release/kernels/divtail2.log
b2db6b05eb6cf4a0a7677e31d0c6c2952d5cab49d353f0bb1883fe0b2a20ed14  release/kernels/divtail2.oracle.jsonl
f057ff8a5681bc50606c18b30818476e6d2aafe28c4617502a2d478c8a0c1e80  release/kernels/divtail2.sv-hosted.log
859de98b257ff94f24c33c61137e19f75b4d3a6a6366920c6e86745a9feeaf36  release/kernels/fence.by_instr.json
31122d492e09789eddee57b5a9916681e9d3095434989d3a9f30293b752ed084  release/kernels/fence.by_unit.json.gz
9ca9d5fede7f40cdc65c8a909c19d8b84bb4b05d6ca0bb963416dc1658101b35  release/kernels/fence.ccvtrace
82f0cd308e4079e7fd818b6cd508985f0b210d2694aeb16e14fd93f7f0ebc7f8  release/kernels/fence.log
d1d40317f6cf5bfb430cda1f9c0ef676609e59cabe2a11623c42ffbeca93142b  release/kernels/fence.oracle.jsonl
b2a956ef7b3fc465e4c54ca64d1e904d4333ecfe2727e86f660d280e5a4f3b5a  release/kernels/fence.sv-hosted.log
aa31c3aaabcbbc7374e712f1a3e40e7eb7c0bc8e04f95bd418f5aea2a0c141ec  release/kernels/gather.by_instr.json.gz
2a0abbf8472cc9efe4bb9a040e3faf5f1da4f4d5854971cbf1a870d4e7dfe194  release/kernels/gather.by_unit.json.gz
b6268ddf39eca13f6dd1b049d9655aa7c92b8b612afc8acbbe7fd2a80cad2213  release/kernels/gather.ccvtrace
5a13006c9ac21bc9badafb47cc41b15acf2ac8d07eb10c9403c296acf9190ac1  release/kernels/gather.log
0413e781d8d6ff578c64eb1f800b7931e66f676d5cdabb97b94a4033e6037662  release/kernels/gather.oracle.jsonl
608c5658fe2fc84d844107fbe57f253f55e652ef3947ed67b636367bf875862a  release/kernels/gather.sv-hosted.log
10cd64e32d222a3ad25e0874b29221983f7dc3e46711a3b13166898765920e3e  release/kernels/hit.by_instr.json.gz
ade50a674cf997ca91a08ad20515f58420e52073e6f8680bc69fa831d6e15800  release/kernels/hit.by_unit.json.gz
00db1dccf621b34cb1a2d0e8658d12ff4d1d45099ccb707cef776ba5019f2429  release/kernels/hit.ccvtrace
8306b82d2f80f7f6784722a9d82d65876a2bc8f3a368e643f684c2aa0b7767c8  release/kernels/hit.log
7ba9603e0088d9164de6528f16ef6a7fa9ce5821c8c12b52cbb3734e39b9fd52  release/kernels/hit.oracle.jsonl
3ab359a7962632eb04793e8a1dbeb028f2c132f8e3d75c1f99771e2e54f8f756  release/kernels/hit.sv-hosted.log
4db02f553d2eb873f2864cb6337caa2772bc9ddc5e8fe4d7e5003c41fddf7cec  release/kernels/lanectx.by_instr.json.gz
abd58a616511c4b8cd38baa32a397a923813531958325a96d1693188fc79b89e  release/kernels/lanectx.by_unit.json.gz
4e23717aa8217570ea922d3735e3658f99a05feb1042dc0a06cbe28fd9536524  release/kernels/lanectx.ccvtrace
20b16734d9c2958e1ec27c143e28f0936ebaa3f32ea3caffa4131bf97006c9c9  release/kernels/lanectx.log
888551babf540db8e3025b82e65ca655013f93eba3c8a65689d069d52a7e6039  release/kernels/lanectx.oracle.jsonl
6675fba9ed37d09c8eec1618fcd9254b0a99c288776ce59c971d361d598a145a  release/kernels/lanectx.sv-hosted.log
5d349a4b79f910df4823380b498b1409fa6e9d2037a11a334107ad9e52022189  release/kernels/lanectx2.by_instr.json.gz
447113032b74896292ce96daff425f878c61c62c0ca387256f0493f0852dc218  release/kernels/lanectx2.by_unit.json.gz
296fc72f00b53509c135dbcf1645c03f4ba0d6ee37cb688f8a3362eed27c8073  release/kernels/lanectx2.ccvtrace
ff9afbd4a2ea2a47793a7ff949de1e474e1417fe2d4beed73ec47f0999796a33  release/kernels/lanectx2.log
45c13056dff5c73ed0c9ece56cc36f929bf335322193c7d5eb38710b1d1dfb02  release/kernels/lanectx2.oracle.jsonl
c8dc4794346e0a8edd90b711157d7619e46b7e81620f2f24d8aefd6b9c14c57e  release/kernels/lanectx2.sv-hosted.log
f58d386afdde29086e38c2b88f624b8d0bb74097141c82654287e01753bac23f  release/kernels/late.by_instr.json.gz
1eb3afbfd512b652582e5a1abd65d4a49508c98f147480505b47da803a67df72  release/kernels/late.by_unit.json.gz
1db71fcebd32a4fc0f62521b4dbefcf72c1a57b1d60668f39dc7f1c4a646d819  release/kernels/late.ccvtrace
1b0199ec7c702455e47a4b52acae260390d697c6bd3ef32dbe31181745bcc74c  release/kernels/late.log
86084f6bd747a2cf32acbc0ebd96ebd3e4ef2d8d9e21be49e3ae49290d7927f3  release/kernels/late.oracle.jsonl
e7e0809f75e35742e0fc005b819bb024b74ef83c3e422c1789c680008eeda0fe  release/kernels/late.sv-hosted.log
52261bab3812390ca784d07f8d40f64c02690ef16362ebc6dd6338a1dbd38b6b  release/kernels/ldpar.by_instr.json.gz
3e677e3e5329f4f76721a67ca12718686b3b98b374276595a7cede55366ce64b  release/kernels/ldpar.by_unit.json.gz
df212098d4e934b07e4499367371561bd39c82de4dbc2d7e5de6ba3f85556813  release/kernels/ldpar.ccvtrace
b217332c9c643f7b8526611460ac1cf22f1c690a5c1959f3a6cdf7af87f39ca0  release/kernels/ldpar.log
8ac08538e9c807637babd61b31e340f7461878ada31f0c0b83cd66331cfaf486  release/kernels/ldpar.oracle.jsonl
6470f6de5c4e571dc763e6249d7123aea6ee57da37593dc7adb73397a90f1f97  release/kernels/ldpar.sv-hosted.log
2948f8e772f61e7ea09257d44e95875b3ce2bfdefc411361ace023523e71df1d  release/kernels/lnorm1.by_instr.json.gz
3931311ee5f01b01ae7ea273c6c0c681a569e020255c3c4f520c6ac2a0fccc27  release/kernels/lnorm1.by_unit.json.gz
b0527a008f1a9aa82c08c004665f95ba36e895ea91e110e641bacd7fba23b182  release/kernels/lnorm1.ccvtrace
000b95662e228ecfe9b7158a920c770d7cfcb5173a58d986858ae54d385d175b  release/kernels/lnorm1.log
a8d85811af988a1b9fc00db1517300af3d93ec8e589e403d3b9113fa9e0ffc86  release/kernels/lnorm1.oracle.jsonl
dbda7e32246a014adcebabef3cc9fe6278afe6bd7ed47e086ce39a1634909ef8  release/kernels/lnorm1.sv-hosted.log
f4e45d2b975c2151890b2ad9614e95602bc04f8b259921c023b29e564af2482c  release/kernels/localsp.by_instr.json.gz
e5a6535f48971fb1ae6104da95cffc8d84d58d28b8cbda44d89388541bf356ba  release/kernels/localsp.by_unit.json.gz
a2c7da314fc3481b21c8295fce059b51022c8bd17067fba46758ae0496d7aa5e  release/kernels/localsp.ccvtrace
cf17687e61b9f876212a59156b13e28e6253c1f3087c587e35f241c4a45bb5b5  release/kernels/localsp.log
55e3c9f36e7f7d38c0ddd38903aff4bb4509ae862015c592e6b937ea258042ca  release/kernels/localsp.oracle.jsonl
811d1ea1dc3ddf3f0e25a6bf3c823fd77fe82efd3a60e4895f9501061a7a6b0b  release/kernels/localsp.sv-hosted.log
3f8a22a39844c8419002e4f7fc3c9beb6f821e018e6a7d2b5ea567681aee46b2  release/kernels/loop.by_instr.json.gz
0f0d664c0e7fd01ea770924d68fe915eab0d7733e5010d9bc83c2ba7a4e93161  release/kernels/loop.by_unit.json.gz
cdf790e790f1c87f83dd25f530f60a735d3f0fa7d91b368132d6e6eba5d73c55  release/kernels/loop.ccvtrace
6847a9a5e551226acf3d2646a60ae4f2531ec4773cf1ed71653b0623c90144fa  release/kernels/loop.log
03ce5920c06c93e93516d8e53c3f7169f14e3593de204eacceffc0b8a3e32016  release/kernels/loop.oracle.jsonl
068f68d1b7b0f9fd4749a88af3c95d5021f89dca2ecb09fffd5925b3513ef1de  release/kernels/loop.sv-hosted.log
24576ea497b47d1816d6f77a1efbb807319d1c249c5176979a77000c39619a0a  release/kernels/merge.by_instr.json.gz
93450d4f96f0e6f87ad6042df363a4cb41464dc9a2ed257ad1fb15fe0b811f01  release/kernels/merge.by_unit.json.gz
194d9afec4cc8ef95accaaab3b029b77e1ede3a8e7b5d6322385765df5bd6a99  release/kernels/merge.ccvtrace
5f87c468b9fc9cecc7b880e54a879f99b577bf471af189c92f715ea697468c3a  release/kernels/merge.log
f96d28815f8756b1f5a45ded53e6170883d2dfa10f9eef0d14b8050b1318164a  release/kernels/merge.oracle.jsonl
9412a878fee97cf4c93001049b8cf2b7e8c99baeb0dc7a69036ab335cddd7374  release/kernels/merge.sv-hosted.log
9800426dc2cdaf3c64dbb311616fa5c97b34a4b29bb671aa60c2355a9430c696  release/kernels/missrun.by_instr.json.gz
1885cebcecb8e387510f22a1e69fdfc956e46f83a7d64af64defc412aae9611e  release/kernels/missrun.by_unit.json.gz
5591b43e28f98149940bf1b102c55aaca894fbaef339a4b408390bcce341e5c0  release/kernels/missrun.ccvtrace
65ceaa558e7bf70e73f72d025444e2899ed20b6711e57c5be4fe610f4b22380d  release/kernels/missrun.log
531bdaf281e5590774bd2775427f25e4cc0419cf8e3d5b6999843ffe9ef87258  release/kernels/missrun.oracle.jsonl
bf743cd795850300919e950cba90e9af30da667f45b475f2ba0348a118871970  release/kernels/missrun.sv-hosted.log
96a679d5b29cf3c9d97351707ceccfba4da30f9beb76fc9ca9917187636e85cf  release/kernels/mload.by_instr.json.gz
6f3665c5ca6e3094809757aeb947d396441fa9929d3a5b94414273288ce7c02c  release/kernels/mload.by_unit.json.gz
dbc74fef542f011f780d1a79cce1779f4d8efbc84521a7f3210e8e24f274f3cf  release/kernels/mload.ccvtrace
cc0d1cbfe6ff2c3add5a1b0aee4fff0a3bc0cdd2854c6f7d2be9e4eda7c48bb5  release/kernels/mload.log
8000e477b9a95dfb9f0af964e8346acb9d36f1358fd06ffc4ff7cf599d2b8868  release/kernels/mload.oracle.jsonl
a189f424cf8187874482141910983234feba9f1d393b7bd14471e8ecc49d9abd  release/kernels/mload.sv-hosted.log
209185197d8d1cd62b402be67cef3c8eee9743361fce4d931b5d3bdce78c9604  release/kernels/mlp.by_instr.json.gz
38805720fc88e9e51b5393d4867aa8bc00ebe418b867f637135b8c0edc2913fa  release/kernels/mlp.by_unit.json.gz
2fbe740fe5333cfaccd8ebe9f4efb0ec181d51f53b33c1b96e233b4a70d85103  release/kernels/mlp.ccvtrace
c35a92a37b9e4589f1256c20b7c0222e8427f5eb4e8c0bc8b3997fed0532d611  release/kernels/mlp.log
138d282f88d56c8ad648a91af0a983254b55d9fa22942c00d47b327f516a6e44  release/kernels/mlp.oracle.jsonl
9216b60f9f3ecc48a208333615de7d80244ce10ad6385aae4da41b1c8ce08ff7  release/kernels/mlp.sv-hosted.log
87fb9fd8920a78955ab26f28c226af114d00edc0a3b430fc326295f51a03988a  release/kernels/mwmiss.by_instr.json.gz
bb7cee9736dbebd7d6ce1960d54542a935ec1a4b248da306d66d3ee9ae453f2e  release/kernels/mwmiss.by_unit.json.gz
5498c205ac9ae6b0550df0fcd4046c338ab8469f03483b85181e18dba0b9fc1c  release/kernels/mwmiss.ccvtrace
cb0a40d31d6eaba0d2e40085ef7468f0a9ad7f47703717e8450f533bd9d5bb06  release/kernels/mwmiss.log
8abe8e8997456a2a6711ee72da54d854b24e20abbdab28e4b7271c0d28418de8  release/kernels/mwmiss.oracle.jsonl
8b55fadbfc2bbc81bd67bfabb0a5247692c8ce9438bd78d05e14548320a4c6eb  release/kernels/mwmiss.sv-hosted.log
308efcfcaaee8e13610b6d404fd7f53206a9c956e2773441974ed275006c3c86  release/kernels/narrowadd.by_instr.json.gz
4a116494c8187d6954bca6db3102273e769c4658eb634d4eb8f4788d1ef8f4cf  release/kernels/narrowadd.by_unit.json.gz
aed2b6677c370ec5ea1d8aad87913809cfb8bea6dc3eab672020bdf04ab57b0d  release/kernels/narrowadd.ccvtrace
1d1ae510d1011860fc7c7b3b233024e374eb4f78fb6b84b8b40562e1f386972e  release/kernels/narrowadd.log
40a2cf629853dd404bb06b4a07e35abde3d12efc13f26ffe28f923daf2994574  release/kernels/narrowadd.oracle.jsonl
1b8bb9b65d59f374e616cc4e4c05470a8c03e0dc97c7004aec8e8dbadff81a9e  release/kernels/narrowadd.sv-hosted.log
3d16143d66ad1ff49037e01be52665289f770fd89ca7bc23d4ec37a87bba88ff  release/kernels/pguard.by_instr.json.gz
ccf6b7b851a2de056b3a38c0c861e8e8993fb3adb3e93fdcfd1769c31ba48935  release/kernels/pguard.by_unit.json.gz
5f475d36ddd428254087d1e1301fbb9decfcdf8bd975697eeb903cc8892a23ce  release/kernels/pguard.ccvtrace
9ec49970bc4d0182e206ac1af69d24382d54b6785a40f21ac8f3f39348dac56e  release/kernels/pguard.log
690e56f1cb8d97cbf67124b7dff3ad0a90cb8981814cd1709cf0cd0e035b3bd9  release/kernels/pguard.oracle.jsonl
44cd95f587047809b80f9cfacf3ce3801a14237cb333f857392498e5f198dbd8  release/kernels/pguard.sv-hosted.log
f6800c1f4efad87166b28b91d8fba55081eed179fc6c1a7c1388f1ccfa75bc15  release/kernels/plog.by_instr.json.gz
5d7b885e26669737bdc3f6ac58b0f764c3a164575b835f544243eadba86ab9d4  release/kernels/plog.by_unit.json.gz
d800c229742b6bc4201c3d6d3c9aae8a23d0c17e4ed875c86600002447db071f  release/kernels/plog.ccvtrace
19a82267674b93c4f20e7246dad383701218c974645291b6bbbeac8c6c3427d3  release/kernels/plog.log
c230f13f2e1082b306a9c5ab7809ff36cf5c1b2e47dca6b7a71f741524d403f5  release/kernels/plog.oracle.jsonl
87984813bf392ed4d93072a3adbc24ca8d1093917e7a330bd1f6db172394da89  release/kernels/plog.sv-hosted.log
f718660f00cae43c7076af21290940c957da3cdc36e5110666abdb8c4f96a4cb  release/kernels/pmovdiv.by_instr.json.gz
6b8911a35067b0688ceca9da1306fcecc16bf9e26300bbca46946e09043e18f5  release/kernels/pmovdiv.by_unit.json.gz
15059a560099c16ee687d9c0e8745a9ecea8d8a2eb27ccb4a7e2f514e78be833  release/kernels/pmovdiv.ccvtrace
735e7928917d39c60bdf058cabd02d8d0795959afe1074706ceb4d6ed10d86d7  release/kernels/pmovdiv.log
7bc646cff6166a51bdce03d7c1b7209e871f0a91d743083a9b910a80bcd0b33f  release/kernels/pmovdiv.oracle.jsonl
bf86782a3c7814037cf932641b74b419222dd1c47e5c2610c8aa05a131976c4e  release/kernels/pmovdiv.sv-hosted.log
e90b02a45901da7190a58a6b66d27e0bbfd059983ddee490aee351251d7261c2  release/kernels/predlane.by_instr.json.gz
c5b9a1e7b3b5b0e5beb63c97b8536af132a46909257058bc9c1d26fbf1a1b58d  release/kernels/predlane.by_unit.json.gz
13fe3ccddbde87563cab1895aa8ba3c04648646626d07f03aa2efe52b5c24fdf  release/kernels/predlane.ccvtrace
fefadb75aae9b9c10dd75dd845627ab721d2aa867b31a726fbb8ea2bf5b0dfc6  release/kernels/predlane.log
c45f4177b9e84fc8a6e36b13534a0c7636eb30a3f8531847100ce5e23bf404b1  release/kernels/predlane.oracle.jsonl
2c2d253534e0aac76b86077a94a3c00e4ac7d0f2b1614e012020f7b2ee911a2d  release/kernels/predlane.sv-hosted.log
9eefbc5f791f8f6f35b701eec056545f665f6e043f11b6f4a4c1328cf49c1a54  release/kernels/predmerge.by_instr.json.gz
8f9078792e22ed556d5f7e83dfd12bb44d9d25d6cf01a60a8a96d3d3e11dbca1  release/kernels/predmerge.by_unit.json.gz
5d8a3be9ca47b183ba6f756e24df06cddebcde6ee1dd5f962aeacb0e4fbcea1d  release/kernels/predmerge.ccvtrace
cc3bc696c4eaa0a27effd6d9eb3d6247ae5b417cc9720e547b0a220f006e8773  release/kernels/predmerge.log
6c737c49434bcd08e3e0814c8b1dbf15c586ae74f7929ba3148ddcee2c62c845  release/kernels/predmerge.oracle.jsonl
0695a31c06b02827fbd6a5e1cd1a9f5549572d632e0627cae7304b388d698603  release/kernels/predmerge.sv-hosted.log
6a0abc0895291e855c6dea516068f3c521d1337e1268382f4ce3471874c23274  release/kernels/predspill.by_instr.json.gz
0df0138ce31f81fd719528f17f10bfa55171110f29ba46b54fe8bfb63975f504  release/kernels/predspill.by_unit.json.gz
52eb4946a26422e4f288977ab65aa38071288a4167280aa93ec0e96d5d431438  release/kernels/predspill.ccvtrace
ea3dc56cabad8c4eaf0155b636f67895dbd6eb54efd279a419061db88146408a  release/kernels/predspill.log
b7c84c6478117ffa0f06da0e6ad1e4628e2683426a7911080810e78e06a5242e  release/kernels/predspill.oracle.jsonl
e01454ec4cef783ef9b573642e9ee8599f6dd237b9e8575f977b1ba26d3a8e69  release/kernels/predspill.sv-hosted.log
991b0b3a55bc67cac5857438c76b4f8a12eef3ea7917819ff961689b21b6865a  release/kernels/predswap.by_instr.json.gz
04526a4cf45f14645b7722670edc0191e6b897f0ce81e7b0473e91c092a80800  release/kernels/predswap.by_unit.json.gz
990fcc299b26138d5f32abd5aabda00c7e9435caf998eaf9fbdc1cd7cd14429d  release/kernels/predswap.ccvtrace
a641c55c881bdf66631cf752818f35bc0842f3f1c59a3348ea8ae32805a66057  release/kernels/predswap.log
a6d4f7ed517553816d889c7c9eeb6bcfd1f6c973fbf682ecb69f3c2de619f7bb  release/kernels/predswap.oracle.jsonl
ad00b2e3fc540f59ff53d78ba6e7611849c1d42fe680e0827aa42b859173568e  release/kernels/predswap.sv-hosted.log
327e49addf13aebee58141400305bb90fecf38483b4613d032c3ab645e306980  release/kernels/privwin.by_instr.json.gz
10a70833115ea6776f68b44d65044ba2a6ce40f4c80c7b049854d4effb4b3ac9  release/kernels/privwin.by_unit.json.gz
8c58e7ee97ada661eff8d7d22aa5fd4a954f030bd45495de0d7ac14cf8c86efb  release/kernels/privwin.ccvtrace
1f15408a9d9d35c75ca07bf081eafec5d3a804c5c48a062b06021e13e59a8ce7  release/kernels/privwin.log
861f686fc4480363472908d679d8815e8c957d768e7ab32c826930527b0fb7a8  release/kernels/privwin.oracle.jsonl
0ad63fa3b04e23d7512839ee32aae30fa72cd3276fc7f5aa9b64f749fe5cc79f  release/kernels/privwin.sv-hosted.log
60f7e98ca94791a52344baf0e4b46d25735d5dae5c9c60534cb0b9bd9f291918  release/kernels/provswap.by_instr.json.gz
4d8ffcb75816169e990fb523fb8221c02994738a0e245dc84e01f3b4a0bb143d  release/kernels/provswap.by_unit.json.gz
a563ab32c8b72bc65e07575cb8f99f0fcd13821ad428eda425ff2a013df97571  release/kernels/provswap.ccvtrace
080908ba3e2312ab5b88bb61b13028f0f43fe120a627402bae236c9ee4a6e7bd  release/kernels/provswap.log
c9c32a793d54cc7401477f582487f7e8b345b2669a75337b8d6327120d98e5dc  release/kernels/provswap.oracle.jsonl
e56a0e61fa16041265c08f7de2b95f03e8d535b2bae27f152a7cabf883dc31d5  release/kernels/provswap.sv-hosted.log
855e382f9e3ec5151edd3b1ca2696c7a0132ae5466fb95aa2f94410112698523  release/kernels/roconst.by_instr.json
04442b9f834c2893cb1a62d00cc51a6b8cd14bbe9289379f1d6965b0db880ad7  release/kernels/roconst.by_unit.json
08068eb6e648de52859ae57718407f6d3b7220fbb2eca8fb04787e865e6d6233  release/kernels/roconst.ccvtrace
47e465512562be9eb167950a508a31eb445345bf51151adb39a0a437a813d09b  release/kernels/roconst.log
8087c0671de620162881aecd38cd6114b78e7be6bd71201e3ec02c9a2e2e750e  release/kernels/roconst.oracle.jsonl
a83d6c685af96445aa2b3ac1e29748b1ea9060769192ffee543432d1aa275d5f  release/kernels/roconst.sv-hosted.log
b1158101d1b9b2aadf4f0a682b0a36d6efc40850775b03a92976a9757fa44299  release/kernels/rogated.by_instr.json
eed2a3ca020872ca86e204d3fcbf62d742f86e8ad7d24311d61a731728d8fb6e  release/kernels/rogated.by_unit.json.gz
b85aefa0a92316e073d3acd172e659e9ba234fd8600773b892a9fc62ebf95ca7  release/kernels/rogated.ccvtrace
568946f4e86565fd5a0b9719ca0dd4d842e606f24b5d713f65ad641f5202d3be  release/kernels/rogated.log
7cd02bd4cceec5a044d6b4d6a80df1e68ed0ae71b0b2a953143636d5b809ea6c  release/kernels/rogated.oracle.jsonl
754bc4f8863281d490e6a242cf3284776223595e3ca568c206cc3f0e66c5f75f  release/kernels/rogated.sv-hosted.log
7b463027116074f223ccc7326025f90bf2598f3768cdd1f42fcef64e734b9e20  release/kernels/rokill.by_instr.json.gz
9318c28281a0be212ae679ad8005f5a3903667e70b6df3b841271dbfb1087c61  release/kernels/rokill.by_unit.json.gz
769df6130e6006b1dd7a726abe73ec9deb80ea13b342b37aba56eee331ef7ecd  release/kernels/rokill.ccvtrace
b685bf0d79050f08a789566e06aebfb3999db99c623383fd8d412d3645752264  release/kernels/rokill.log
94efcef96af469a512d346ce61623980fe86383188eaebd55120f716db596f14  release/kernels/rokill.oracle.jsonl
68979c04afcc361e11d25609d888b279b8cf7529bb96e58068850b22f22c2708  release/kernels/rokill.sv-hosted.log
d79047b009857071779a693f850c1075f9f16d3c5b710fd4b210c63f992958e3  release/kernels/rolaunch.by_instr.json
de5a0fe713bce030640474ae46202b1a425d2daae644aac04ef777c5de25aa7a  release/kernels/rolaunch.by_unit.json
05cda6c52ebfa8f10c8318d2142d2879c024f7ace46fa82c3fe983ac80f0dd26  release/kernels/rolaunch.ccvtrace
f769f0c0acb5a02c3f72276ec1eddef45785dde79131f90cbbe434113f500c7f  release/kernels/rolaunch.log
e7dad585c3e70615de04330fd03f4f282c29a005dc1732a35655fb261d51139e  release/kernels/rolaunch.oracle.jsonl
d4a84560e0d30c2d549ce367a3ab6e53a3decbed8d1fb272a3dfa399332c1bfa  release/kernels/rolaunch.sv-hosted.log
855e382f9e3ec5151edd3b1ca2696c7a0132ae5466fb95aa2f94410112698523  release/kernels/rolimit.by_instr.json
2af72a1dc3f9ac4697a6911ee19dfabd7c1540cf87915083b94b9c76ff4cc417  release/kernels/rolimit.by_unit.json
40924988ecbef6ea3a1b9a5a295b56287fd7bd4b89a6bcebb122f4d6d40862fe  release/kernels/rolimit.ccvtrace
a638bd0f7b80d5cc95c93c3fb9e136b0d5fb9ae6477cf622d0bf7c7f5af768da  release/kernels/rolimit.log
1c5bc0cb8e8b2e69505fb5a551a16d5d10c56f232b88da7a27e336ad7d962de2  release/kernels/rolimit.oracle.jsonl
422908d745bc5aa62417b33739f1daeb685c26b479979f335b401d8186fa80c0  release/kernels/rolimit.sv-hosted.log
c8b206c1e36d789d76dc8eb872b49d5351d00337ceb531e9426a7b13eb6a5afe  release/kernels/roload.by_instr.json.gz
a8e58b09dd6f6554bba9696a95715d8948110e7605058ec41b2b359117b44bb1  release/kernels/roload.by_unit.json.gz
673c80d51c9dd1012175f7f187cfc635a171559720f489d8c78b0e3e69f39ed6  release/kernels/roload.ccvtrace
80b286d513564531bb1c7da3eb8900f2ccd57a3461d6a91a7194a1e1975d086e  release/kernels/roload.log
f7c1309cc9764769fb5803f6fd0f2f5e1eb418f2d23fbe5e17cf5f9106869fdf  release/kernels/roload.oracle.jsonl
898a4e3b9ab5f1d87ad213b02650b89a1276fc2b9056affab7d50af51d0ef916  release/kernels/roload.sv-hosted.log
28fad01f29346478b9836fb63ed7185c8a611937c701256098caadd08f09f03b  release/kernels/rope.by_instr.json.gz
a2364fdfebb50ab7832e28823739585b8b2c4d6c1c253c187710845a2afa6e36  release/kernels/rope.by_unit.json.gz
b4502c2cbf9318d2952290a28a88e05e5c390e127b8e3a8366e280248e1d804b  release/kernels/rope.ccvtrace
618245c0807f38ae9207e724e467434588cf957bc0213a33ebdaf667b4c31a02  release/kernels/rope.log
d55f9efae392dc8877c102c01c0810e7654b666b6ede386328108164c6cf88f3  release/kernels/rope.oracle.jsonl
de948200578f4df590023f2f6ddbbc2c4d7f644d3d64f87cc7d1a47c46d164f8  release/kernels/rope.sv-hosted.log
89f7066bfcee9de340fa18f6d39c3b986b41e21cbf3ae6e4d3f2d164799ae198  release/kernels/ropediv.by_instr.json.gz
094cf2d78eac591993a32725178905ade722b1cd2c7697aae3ecbba9ecdfd751  release/kernels/ropediv.by_unit.json.gz
edffb2ee0d6f613a67871ce8681781e2f0f39c23c56d0aeca16d7710eeccd4ae  release/kernels/ropediv.ccvtrace
9ff5c913bea0bceb585039ad6a23ea322e65872a4a6d28944a3351bc454dee6c  release/kernels/ropediv.log
10c0ec6ec18b7b44638c790033109198c079d07c1537bf193353ccedd00a920f  release/kernels/ropediv.oracle.jsonl
d53df06687db980e404bd30328ec99770797da8eff967b58d23ad084dd55abae  release/kernels/ropediv.sv-hosted.log
0ffb90d44ca67f3e54c367907b3f5442bce9929678c9ac6f3afd65f8828a8d45  release/kernels/sel.by_instr.json.gz
2e5544761b7268643c5a93b132823055d6cdc58867dafc675fc93b37b26e94d3  release/kernels/sel.by_unit.json.gz
3bfdb6f779a267aef535987131e9a6b7daaaafda34639286809a12da5dd9841c  release/kernels/sel.ccvtrace
83053e7bd21fffed5a241d7dede447af992e26d9f284142cb5192da880f5745a  release/kernels/sel.log
87f6a81e8afa004c8039bf2f61c90176fcf29ab29bb17ac44aa016a5cc8438fe  release/kernels/sel.oracle.jsonl
e2932b7efba02c4d90261ceebd2470c3b05f19c7f318aeb9930e840259878464  release/kernels/sel.sv-hosted.log
f158895b9f16ec6453c9dce0bf827169e5976308752f728217ff6bc8584ef0ec  release/kernels/sized.by_instr.json.gz
fac677c21ecc429a99edb1ab0734aa78cebf789eb6cd87f0cc71348d9db83989  release/kernels/sized.by_unit.json.gz
811dd915beb81908abe7250774911710690668c93367b0f4f7e16b51124e69fd  release/kernels/sized.ccvtrace
8fd237f64b021e65e7459b79d71e7ef5bacf6abbac1c3f8a4ecfee208f8b8b4f  release/kernels/sized.log
36d903ba1618bd1faa437c9812a6ee6c0c966a63196c796267d74bf2695ebc3d  release/kernels/sized.oracle.jsonl
bb90f797a6912c61bc9748f4dcd21c1269fb860ea6e26fb2ba01d78476f91711  release/kernels/sized.sv-hosted.log
b0f3ab03f639381824333340a49a1c44b45e638f49ff593903f14647844bc505  release/kernels/slotform.by_instr.json.gz
a0c83d46cefe84c01da89c2853762ea587d84199274870a02c6302b97b5aaf2a  release/kernels/slotform.by_unit.json.gz
a18c295727e86368cf7bb3890444db8ff6c3589ad3c4b3a77d0f002ca82e784b  release/kernels/slotform.ccvtrace
d02e227fce6c84321b4b394589697a4a4ee02c10267bad89a7271df9d0eeb38f  release/kernels/slotform.log
8b61db7419b18cea8a646fb628218447e72e84a18a9891ffb73b441736138ab9  release/kernels/slotform.oracle.jsonl
99289f08f321f7fe7e0df7d90b784402a831838665859a2af8c844a4919ec112  release/kernels/slotform.sv-hosted.log
223545971f665d108704ff4bf86b951db116875884697c497d199370b54c523e  release/kernels/spinwait.by_instr.json.gz
dbe65817902799ea7b74a2b69bc07e71553062505c8c6fedb70597bc7695046c  release/kernels/spinwait.by_unit.json.gz
f1ede3f0f3ce99d61bbc1af1413a56aa24064be25cb970b82c12cdc4b6946bd1  release/kernels/spinwait.ccvtrace
fff4e64be6462187beb429ede423fa7fe2836b559f60dda20f32397225c9cae5  release/kernels/spinwait.log
868920637236c878b33779bd450439466fc3626996a3164573dc11d437d5c709  release/kernels/spinwait.oracle.jsonl
e365bc7f59206b80269ba8eb08de667b335de83f4e6601748e2397779d08b0f8  release/kernels/spinwait.sv-hosted.log
6507b98fc5a677c9f64373d334b00844f44db7c76dc4459465a3260e373fba11  release/kernels/spmbank.by_instr.json.gz
35c30b8b2ce60f6cdd76c32a77ee351fc85af212f1806ac6db07eea623636909  release/kernels/spmbank.by_unit.json.gz
b2741aee8d64db64735f24d7197a2b2b95383a59ce1daae907914f0097f4ec87  release/kernels/spmbank.ccvtrace
fa6961ec5151a8ccf960148481f10edc6ce87c5a97ab83b5f91ac2066f762d67  release/kernels/spmbank.log
3af490cc37d7a92dbe719b57de216b648536eb301ff9d13de9a39f50d150d725  release/kernels/spmbank.oracle.jsonl
818e1db5c8175cf5ff12545aa84a2fcb39f74bc93a54eafb12e6e2a9c2837ee3  release/kernels/spmbank.sv-hosted.log
4478211b237c86da4cd8a95e2844555e285eec292f968a8277d84ee45619d300  release/kernels/srd.by_instr.json.gz
82b72400f4c40073815eb876434e655a85895e9e1b393d20c6597b5239610b94  release/kernels/srd.by_unit.json.gz
d6f83ced88aed31e4f95354fd27020f4c3e51bef2db19b063dcbc6a4c32b8f6c  release/kernels/srd.ccvtrace
5c7132b06d8c214ad1c36524723c58e6024fb4da48f13d087d85969cdea1b128  release/kernels/srd.log
b08eb5e3673cac7eebb8b72af5ed3783c8e70a9e96592e76bf3722551bc79473  release/kernels/srd.oracle.jsonl
2b89509055eb6200d8f32eb7626dba4573d582e998e731409fec150c1a757dd9  release/kernels/srd.sv-hosted.log
f54bd8f9923909a9938d2129c969e98825b975c0e8ffa403b1e832df1ceea2a1  release/kernels/stall.by_instr.json.gz
00fd2d3be26f53dddfaf57266949c95c360826663ce2c76964d974c6cff4d946  release/kernels/stall.by_unit.json.gz
73a08f04342dd00debf1580856b5f875c7cc6fde71a57a322ab3e0f2a336752d  release/kernels/stall.ccvtrace
27096327f44046592aefd5bf189bfc53275048097be4002959210d5bfbba0597  release/kernels/stall.log
500db2c482b07a0706583422cd68878301d0146c1f872ccc1f11bfdcf5c993ef  release/kernels/stall.oracle.jsonl
c7e56b38630972e54a9616c4002b5b838e6e1c72845a82c52c7f08b68a4b8a49  release/kernels/stall.sv-hosted.log
d8e651d136e06be6057912603215d5c1214985ec6603a351dc5d1dee23c667de  release/kernels/swap.by_instr.json.gz
63a291b49ba1c217520a5119a38963eb479174ddf413bddcf3d72b1deb1160da  release/kernels/swap.by_unit.json.gz
504203fde969f6883c0a3252b41faebd3f4d4d121088329da7e8d00beb1b1fba  release/kernels/swap.ccvtrace
e87136f8d2106a9ba6b6cde38f534fcb16f5a591c08f022afb97f5f23c95963d  release/kernels/swap.log
3658a26316c1ff7bc1744304a42f736e930fcde2865c8913e6cc67a22ce96667  release/kernels/swap.oracle.jsonl
8c5e794432696a92f3e2807a5c763bad0315d86a2c78773a58b8aa8ca0c46934  release/kernels/swap.sv-hosted.log
14054c4898fbc8dadcd76e32f5ae81c6b63db197d5748f313598ae84ce2e3099  release/kernels/transp4.by_instr.json.gz
d7a7fa2019a415edb86e467501f87b3c6f3b97c31a98d39e4ce5096a04378c98  release/kernels/transp4.by_unit.json.gz
0b5dda8e5da6c3fa825b23ada041fd90353e49daf187e79341d2334b520e4d33  release/kernels/transp4.ccvtrace
000343ed64eb88740c71a0005f373bdc7ae589289bcb8f8ae5db57786dedff67  release/kernels/transp4.log
06396ace3ac19677fd39c700e408606e5bdbacb24997d663bbe8872e63dd74fc  release/kernels/transp4.oracle.jsonl
8bbee3660a65d650c8a9077ad7552f816e06b202d09f83866393cfc896c24bd6  release/kernels/transp4.sv-hosted.log
e726f047824e584b82cc458fe5ceb7806139665bc27ca4fb3ef3bf5bca3f266a  release/kernels/unal.by_instr.json.gz
bbcdbfe3ce7c65c0265c765fba8941b00f85c85f0fa563772272d748e1c54816  release/kernels/unal.by_unit.json.gz
cbb33f43e6faa189ae3c59c466a884541a3773d2e26b1c82b4a5e2badaef59b2  release/kernels/unal.ccvtrace
3dece94f0ef183f72f31acd807b2d307a852d7c88fcb45617d09c6ee1be48034  release/kernels/unal.log
c3d484bb160657a563df983d9a2532eac27f556636617960aa1e72183ac2b299  release/kernels/unal.oracle.jsonl
215b346d4d53c0646d37152f4574bcc65187adb65c88ebc0cd246767877addb5  release/kernels/unal.sv-hosted.log
38c44df077d85ecb801b6533f301ccb2021ff9e33c1bc1d019e598a88bb2265d  release/kernels/vadd.by_instr.json.gz
4872f6286fd6a44ef9e9d5f6e0883332168928d77a6441c7bbe7d458149e8fdc  release/kernels/vadd.by_unit.json.gz
3aed2bcb55707effafbd6b5bc20149d767f45e8de0f08545ccfeb262da484a07  release/kernels/vadd.ccvtrace
3bbcdbde98e2bb7d2a86008ffe645c151dbc5c62861eeeb5f40b39a4011eb941  release/kernels/vadd.log
0276b6d0611a4bbcdc004ab3987214aea138245bc7217504147331689a9c0880  release/kernels/vadd.oracle.jsonl
76e0d65e6f66a6dafbc7b07c81e77757ef73cd7d67b31c9b53e167740c629d18  release/kernels/vadd.sv-hosted.log
38d5fe2562d702bc0c916621c98af548cf63c874cbdfd9d11a9332bbd5ad9664  release/kernels/vadd4.by_instr.json.gz
cea0d9fc6243f174b5d2164b1a530569fe025306d841d0817f1fedc57cee1bb0  release/kernels/vadd4.by_unit.json.gz
8d13386549acde3d65386de16915dc639c58aac8e87494b584c28f50e9209aa9  release/kernels/vadd4.ccvtrace
165f1bb3a84dba73427d50866990689c192f6cca2f12e2c85fdb9c9cdc568506  release/kernels/vadd4.log
225aa18fc9f38aa9ad615aa11de254337d59fa705877553d873062c68366e0db  release/kernels/vadd4.oracle.jsonl
9287142b8af2e27aab57faf1ce8a991dfd5bbd5b104f22dc220e0925bd6d0ed4  release/kernels/vadd4.sv-hosted.log
fc416c430ab3d1645900e6b2d3d0a878d948d58b2e29d392abaebfd5d7e9b418  release/kernels/vaddslow.by_instr.json.gz
6074b3243728efab553a3ced40d89023fab04acf5df54457a83655d28feac5bb  release/kernels/vaddslow.by_unit.json.gz
4d13dce2b66d977d3767ba035bd4b50b9eb1640bf1858c34b8ad4e2f291ca65d  release/kernels/vaddslow.ccvtrace
74230330f07236ce94e9de997dc18ad0e4f6fe995c1d8667514fc22c9bf0245f  release/kernels/vaddslow.log
e9e6218e8b8450e9f9ff6b39d659c994a1e51c527a0c5bd10d18b5658ae0e344  release/kernels/vaddslow.oracle.jsonl
62e894963b2ed2193d60c2be1972909091cea94639b18ff0b48cb880595da5a7  release/kernels/vaddslow.sv-hosted.log
6c0090a56d3efa236c49b160ec2912aff423bed2df38bc8bb1b75ef2a7858e11  release/verify.log
1f3a2eff14dbda0754e19cbf72bc5003c950fc7d1691d527ce3a8d427fb583d7  release/wiring.txt
```
