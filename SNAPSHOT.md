# Snapshot snapshot-2026-11-28-80e2e2b

**A generated, read-only snapshot. Do not edit or merge it.** The source
is `ti-rp` at `80e2e2b7573ec101c45fa74a6278f0744afe72a7`, and this branch is rebuilt from source by
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
| Source | `ti-rp` @ `80e2e2b7573ec101c45fa74a6278f0744afe72a7` |
| Built | 2026-11-28 (UTC) |
| Gate | `tools/verify.sh`: PASS |
| Compiler snapshot | custom-cuda-complier `release` @ `a293afe7d7873fb5d3fac70d8deca980e119b19f` (source `b9ae2c9d5d3b838d5d982d842b558e2d290185ea`) |
| Verilator | Verilator 5.052 2026-09-05 rev v5.052 |
| Icarus | Icarus Verilog version 12.0 (stable) () |
| Yosys | Yosys 0.33 (git sha1 2584903a060) |

## Kernels

| Kernel | Result |
|---|---|
| `addrhigh` | `name=addrhigh finished=1 cycles=97 from_fetch=52 retired=5 issue_groups=6 order=ok gpr_mismatch=0 pred_mismatch=0 mem_mismatch=0 check_failures=0 class_violations=0 overflows=0 credit_leaks=0 cor_late=0 channels_used=26/57 violations=0` |
| `addrlimit` | `name=addrlimit finished=1 cycles=107 from_fetch=62 retired=5 issue_groups=5 order=ok gpr_mismatch=0 pred_mismatch=0 mem_mismatch=0 check_failures=0 class_violations=0 overflows=0 credit_leaks=0 cor_late=0 channels_used=28/57 violations=0` |
| `addrneg` | `name=addrneg finished=1 cycles=95 from_fetch=50 retired=1 issue_groups=2 order=ok gpr_mismatch=0 pred_mismatch=0 mem_mismatch=0 check_failures=0 class_violations=0 overflows=0 credit_leaks=0 cor_late=0 channels_used=23/57 violations=0` |
| `atom` | `name=atom finished=1 cycles=8746 from_fetch=8701 retired=29 issue_groups=29 order=ok gpr_mismatch=0 pred_mismatch=0 mem_mismatch=0 check_failures=0 class_violations=0 overflows=0 credit_leaks=0 cor_late=0 channels_used=33/57 violations=0` |
| `atomf` | `name=atomf finished=1 cycles=4654 from_fetch=4609 retired=12 issue_groups=12 order=ok gpr_mismatch=0 pred_mismatch=0 mem_mismatch=0 check_failures=0 class_violations=0 overflows=0 credit_leaks=0 cor_late=0 channels_used=35/57 violations=0` |
| `borrow` | `name=borrow finished=1 cycles=113 from_fetch=68 retired=7 issue_groups=7 order=ok gpr_mismatch=0 pred_mismatch=0 mem_mismatch=0 check_failures=0 class_violations=0 overflows=0 credit_leaks=0 cor_late=0 channels_used=21/57 violations=0` |
| `brs` | `name=brs finished=1 cycles=113 from_fetch=68 retired=12 issue_groups=12 order=ok gpr_mismatch=0 pred_mismatch=0 mem_mismatch=0 check_failures=0 class_violations=0 overflows=0 credit_leaks=0 cor_late=0 channels_used=23/57 violations=0` |
| `byp` | `name=byp finished=1 cycles=143 from_fetch=98 retired=14 issue_groups=14 order=ok gpr_mismatch=0 pred_mismatch=0 mem_mismatch=0 check_failures=0 class_violations=0 overflows=0 credit_leaks=0 cor_late=0 channels_used=32/57 violations=0` |
| `callret` | `name=callret finished=1 cycles=290 from_fetch=245 retired=40 issue_groups=40 order=ok gpr_mismatch=0 pred_mismatch=0 mem_mismatch=0 check_failures=0 class_violations=0 overflows=0 credit_leaks=0 cor_late=0 channels_used=31/57 violations=0` |
| `cas` | `name=cas finished=1 cycles=6986 from_fetch=6941 retired=56 issue_groups=56 order=ok gpr_mismatch=0 pred_mismatch=0 mem_mismatch=0 check_failures=0 class_violations=0 overflows=0 credit_leaks=0 cor_late=0 channels_used=33/57 violations=0` |
| `chains` | `name=chains finished=1 cycles=110 from_fetch=65 retired=29 issue_groups=29 order=ok gpr_mismatch=0 pred_mismatch=0 mem_mismatch=0 check_failures=0 class_violations=0 overflows=0 credit_leaks=0 cor_late=0 channels_used=21/57 violations=0` |
| `coll` | `name=coll finished=1 cycles=92 from_fetch=47 retired=24 issue_groups=24 order=ok gpr_mismatch=0 pred_mismatch=0 mem_mismatch=0 check_failures=0 class_violations=0 overflows=0 credit_leaks=0 cor_late=0 channels_used=21/57 violations=0` |
| `div` | `name=div finished=1 cycles=992 from_fetch=947 retired=144 issue_groups=144 order=ok gpr_mismatch=0 pred_mismatch=0 mem_mismatch=0 check_failures=0 class_violations=0 overflows=0 credit_leaks=0 cor_late=0 channels_used=23/57 violations=0` |
| `divchw` | `name=divchw finished=1 cycles=125 from_fetch=80 retired=5 issue_groups=6 order=ok gpr_mismatch=0 pred_mismatch=0 mem_mismatch=0 check_failures=0 class_violations=0 overflows=0 credit_leaks=0 cor_late=0 channels_used=22/57 violations=0` |
| `divtail` | `name=divtail finished=1 cycles=656 from_fetch=611 retired=96 issue_groups=96 order=ok gpr_mismatch=0 pred_mismatch=0 mem_mismatch=0 check_failures=0 class_violations=0 overflows=0 credit_leaks=0 cor_late=0 channels_used=23/57 violations=0` |
| `divtail2` | `name=divtail2 finished=1 cycles=1531 from_fetch=1486 retired=366 issue_groups=366 order=ok gpr_mismatch=0 pred_mismatch=0 mem_mismatch=0 check_failures=0 class_violations=0 overflows=0 credit_leaks=0 cor_late=0 channels_used=23/57 violations=0` |
| `fence` | `name=fence finished=1 cycles=97 from_fetch=52 retired=7 issue_groups=7 order=ok gpr_mismatch=0 pred_mismatch=0 mem_mismatch=0 check_failures=0 class_violations=0 overflows=0 credit_leaks=0 cor_late=0 channels_used=31/57 violations=0` |
| `gather` | `name=gather finished=1 cycles=296 from_fetch=251 retired=16 issue_groups=16 order=ok gpr_mismatch=0 pred_mismatch=0 mem_mismatch=0 check_failures=0 class_violations=0 overflows=0 credit_leaks=0 cor_late=0 channels_used=33/57 violations=0` |
| `hit` | `name=hit finished=1 cycles=253 from_fetch=208 retired=17 issue_groups=17 order=ok gpr_mismatch=0 pred_mismatch=0 mem_mismatch=0 check_failures=0 class_violations=0 overflows=0 credit_leaks=0 cor_late=0 channels_used=32/57 violations=0` |
| `lanectx` | `name=lanectx finished=1 cycles=84 from_fetch=39 retired=10 issue_groups=10 order=ok gpr_mismatch=0 pred_mismatch=0 mem_mismatch=0 check_failures=0 class_violations=0 overflows=0 credit_leaks=0 cor_late=0 channels_used=30/57 violations=0` |
| `lanectx2` | `name=lanectx2 finished=1 cycles=84 from_fetch=39 retired=10 issue_groups=10 order=ok gpr_mismatch=0 pred_mismatch=0 mem_mismatch=0 check_failures=0 class_violations=0 overflows=0 credit_leaks=0 cor_late=0 channels_used=30/57 violations=0` |
| `late` | `name=late finished=1 cycles=203 from_fetch=158 retired=16 issue_groups=16 order=ok gpr_mismatch=0 pred_mismatch=0 mem_mismatch=0 check_failures=0 class_violations=0 overflows=0 credit_leaks=0 cor_late=0 channels_used=32/57 violations=0` |
| `ldpar` | `name=ldpar finished=1 cycles=188 from_fetch=143 retired=17 issue_groups=17 order=ok gpr_mismatch=0 pred_mismatch=0 mem_mismatch=0 check_failures=0 class_violations=0 overflows=0 credit_leaks=0 cor_late=0 channels_used=32/57 violations=0` |
| `lnorm1` | `name=lnorm1 finished=1 cycles=2583 from_fetch=2538 retired=526 issue_groups=526 order=ok gpr_mismatch=0 pred_mismatch=0 mem_mismatch=0 check_failures=0 class_violations=0 overflows=0 credit_leaks=0 cor_late=0 channels_used=38/57 violations=0` |
| `localsp` | `name=localsp finished=1 cycles=233 from_fetch=188 retired=40 issue_groups=40 order=ok gpr_mismatch=0 pred_mismatch=0 mem_mismatch=0 check_failures=0 class_violations=0 overflows=0 credit_leaks=0 cor_late=0 channels_used=32/57 violations=0` |
| `loop` | `name=loop finished=1 cycles=2856 from_fetch=2811 retired=407 issue_groups=407 order=ok gpr_mismatch=0 pred_mismatch=0 mem_mismatch=0 check_failures=0 class_violations=0 overflows=0 credit_leaks=0 cor_late=0 channels_used=23/57 violations=0` |
| `merge` | `name=merge finished=1 cycles=85 from_fetch=40 retired=9 issue_groups=9 order=ok gpr_mismatch=0 pred_mismatch=0 mem_mismatch=0 check_failures=0 class_violations=0 overflows=0 credit_leaks=0 cor_late=0 channels_used=21/57 violations=0` |
| `missrun` | `name=missrun finished=1 cycles=146 from_fetch=101 retired=28 issue_groups=28 order=ok gpr_mismatch=0 pred_mismatch=0 mem_mismatch=0 check_failures=0 class_violations=0 overflows=0 credit_leaks=0 cor_late=0 channels_used=32/57 violations=0` |
| `mload` | `name=mload finished=1 cycles=136 from_fetch=91 retired=11 issue_groups=11 order=ok gpr_mismatch=0 pred_mismatch=0 mem_mismatch=0 check_failures=0 class_violations=0 overflows=0 credit_leaks=0 cor_late=0 channels_used=32/57 violations=0` |
| `mlp` | `name=mlp finished=1 cycles=151 from_fetch=106 retired=21 issue_groups=21 order=ok gpr_mismatch=0 pred_mismatch=0 mem_mismatch=0 check_failures=0 class_violations=0 overflows=0 credit_leaks=0 cor_late=0 channels_used=32/57 violations=0` |
| `mwmiss` | `name=mwmiss finished=1 cycles=155 from_fetch=110 retired=88 issue_groups=88 order=ok gpr_mismatch=0 pred_mismatch=0 mem_mismatch=0 check_failures=0 class_violations=0 overflows=0 credit_leaks=0 cor_late=0 channels_used=32/57 violations=0` |
| `narrowadd` | `name=narrowadd finished=1 cycles=261 from_fetch=216 retired=21 issue_groups=21 order=ok gpr_mismatch=0 pred_mismatch=0 mem_mismatch=0 check_failures=0 class_violations=0 overflows=0 credit_leaks=0 cor_late=0 channels_used=33/57 violations=0` |
| `pgcross` | `name=pgcross finished=1 cycles=196 from_fetch=151 retired=8 issue_groups=8 order=ok gpr_mismatch=0 pred_mismatch=0 mem_mismatch=0 check_failures=0 class_violations=0 overflows=0 credit_leaks=0 cor_late=0 channels_used=32/57 violations=0` |
| `pguard` | `name=pguard finished=1 cycles=101 from_fetch=56 retired=12 issue_groups=12 order=ok gpr_mismatch=0 pred_mismatch=0 mem_mismatch=0 check_failures=0 class_violations=0 overflows=0 credit_leaks=0 cor_late=0 channels_used=30/57 violations=0` |
| `plog` | `name=plog finished=1 cycles=85 from_fetch=40 retired=11 issue_groups=11 order=ok gpr_mismatch=0 pred_mismatch=0 mem_mismatch=0 check_failures=0 class_violations=0 overflows=0 credit_leaks=0 cor_late=0 channels_used=21/57 violations=0` |
| `pmovdiv` | `name=pmovdiv finished=1 cycles=118 from_fetch=73 retired=12 issue_groups=12 order=ok gpr_mismatch=0 pred_mismatch=0 mem_mismatch=0 check_failures=0 class_violations=0 overflows=0 credit_leaks=0 cor_late=0 channels_used=22/57 violations=0` |
| `predlane` | `name=predlane finished=1 cycles=942 from_fetch=897 retired=10 issue_groups=10 order=ok gpr_mismatch=0 pred_mismatch=0 mem_mismatch=0 check_failures=0 class_violations=0 overflows=0 credit_leaks=0 cor_late=0 channels_used=32/57 violations=0` |
| `predmerge` | `name=predmerge finished=1 cycles=954 from_fetch=909 retired=9 issue_groups=9 order=ok gpr_mismatch=0 pred_mismatch=0 mem_mismatch=0 check_failures=0 class_violations=0 overflows=0 credit_leaks=0 cor_late=0 channels_used=34/57 violations=0` |
| `predspill` | `name=predspill finished=1 cycles=982 from_fetch=937 retired=12 issue_groups=12 order=ok gpr_mismatch=0 pred_mismatch=0 mem_mismatch=0 check_failures=0 class_violations=0 overflows=0 credit_leaks=0 cor_late=0 channels_used=32/57 violations=0` |
| `predswap` | `name=predswap finished=1 cycles=1200 from_fetch=1155 retired=46 issue_groups=46 order=ok gpr_mismatch=0 pred_mismatch=0 mem_mismatch=0 check_failures=0 class_violations=0 overflows=0 credit_leaks=0 cor_late=0 channels_used=34/57 violations=0` |
| `privwin` | `name=privwin finished=1 cycles=203 from_fetch=158 retired=52 issue_groups=52 order=ok gpr_mismatch=0 pred_mismatch=0 mem_mismatch=0 check_failures=0 class_violations=0 overflows=0 credit_leaks=0 cor_late=0 channels_used=35/57 violations=0` |
| `provswap` | `name=provswap finished=1 cycles=2285 from_fetch=2240 retired=978 issue_groups=978 order=ok gpr_mismatch=0 pred_mismatch=0 mem_mismatch=0 check_failures=0 class_violations=0 overflows=0 credit_leaks=0 cor_late=0 channels_used=34/57 violations=0` |
| `retmiss` | `name=retmiss finished=1 cycles=218 from_fetch=173 retired=19 issue_groups=19 order=ok gpr_mismatch=0 pred_mismatch=0 mem_mismatch=0 check_failures=0 class_violations=0 overflows=0 credit_leaks=0 cor_late=0 channels_used=34/57 violations=0` |
| `roconst` | `name=roconst finished=1 cycles=90 from_fetch=45 retired=4 issue_groups=5 order=ok gpr_mismatch=0 pred_mismatch=0 mem_mismatch=0 check_failures=0 class_violations=0 overflows=0 credit_leaks=0 cor_late=0 channels_used=26/57 violations=0` |
| `rogated` | `name=rogated finished=1 cycles=110 from_fetch=65 retired=7 issue_groups=8 order=ok gpr_mismatch=0 pred_mismatch=0 mem_mismatch=0 check_failures=0 class_violations=0 overflows=0 credit_leaks=0 cor_late=0 channels_used=26/57 violations=0` |
| `rokill` | `name=rokill finished=1 cycles=120 from_fetch=75 retired=41 issue_groups=4536 order=ok gpr_mismatch=0 pred_mismatch=0 mem_mismatch=0 check_failures=0 class_violations=0 overflows=0 credit_leaks=0 cor_late=0 channels_used=27/57 violations=0` |
| `rokilllane` | `name=rokilllane finished=1 cycles=1228 from_fetch=1183 retired=924 issue_groups=10674 order=ok gpr_mismatch=0 pred_mismatch=0 mem_mismatch=0 check_failures=0 class_violations=0 overflows=0 credit_leaks=0 cor_late=0 channels_used=27/57 violations=0` |
| `rolaunch` | `name=rolaunch finished=1 cycles=88 from_fetch=43 retired=4 issue_groups=5 order=ok gpr_mismatch=0 pred_mismatch=0 mem_mismatch=0 check_failures=0 class_violations=0 overflows=0 credit_leaks=0 cor_late=0 channels_used=24/57 violations=0` |
| `rolimit` | `name=rolimit finished=1 cycles=90 from_fetch=45 retired=4 issue_groups=5 order=ok gpr_mismatch=0 pred_mismatch=0 mem_mismatch=0 check_failures=0 class_violations=0 overflows=0 credit_leaks=0 cor_late=0 channels_used=26/57 violations=0` |
| `roload` | `name=roload finished=1 cycles=129 from_fetch=84 retired=8 issue_groups=8 order=ok gpr_mismatch=0 pred_mismatch=0 mem_mismatch=0 check_failures=0 class_violations=0 overflows=0 credit_leaks=0 cor_late=0 channels_used=32/57 violations=0` |
| `rope` | `name=rope finished=1 cycles=749 from_fetch=704 retired=354 issue_groups=354 order=ok gpr_mismatch=0 pred_mismatch=0 mem_mismatch=0 check_failures=0 class_violations=0 overflows=0 credit_leaks=0 cor_late=0 channels_used=35/57 violations=0` |
| `ropediv` | `name=ropediv finished=1 cycles=1062 from_fetch=1017 retired=203 issue_groups=203 order=ok gpr_mismatch=0 pred_mismatch=0 mem_mismatch=0 check_failures=0 class_violations=0 overflows=0 credit_leaks=0 cor_late=0 channels_used=35/57 violations=0` |
| `sel` | `name=sel finished=1 cycles=91 from_fetch=46 retired=8 issue_groups=8 order=ok gpr_mismatch=0 pred_mismatch=0 mem_mismatch=0 check_failures=0 class_violations=0 overflows=0 credit_leaks=0 cor_late=0 channels_used=30/57 violations=0` |
| `sized` | `name=sized finished=1 cycles=1001 from_fetch=956 retired=25 issue_groups=25 order=ok gpr_mismatch=0 pred_mismatch=0 mem_mismatch=0 check_failures=0 class_violations=0 overflows=0 credit_leaks=0 cor_late=0 channels_used=33/57 violations=0` |
| `slotform` | `name=slotform finished=1 cycles=431 from_fetch=386 retired=12 issue_groups=12 order=ok gpr_mismatch=0 pred_mismatch=0 mem_mismatch=0 check_failures=0 class_violations=0 overflows=0 credit_leaks=0 cor_late=0 channels_used=33/57 violations=0` |
| `spinwait` | `name=spinwait finished=1 cycles=2062 from_fetch=2017 retired=211 issue_groups=211 order=ok gpr_mismatch=0 pred_mismatch=0 mem_mismatch=0 check_failures=0 class_violations=0 overflows=0 credit_leaks=0 cor_late=0 channels_used=35/57 violations=0` |
| `spmbank` | `name=spmbank finished=1 cycles=200 from_fetch=155 retired=13 issue_groups=13 order=ok gpr_mismatch=0 pred_mismatch=0 mem_mismatch=0 check_failures=0 class_violations=0 overflows=0 credit_leaks=0 cor_late=0 channels_used=28/57 violations=0` |
| `srd` | `name=srd finished=1 cycles=84 from_fetch=39 retired=6 issue_groups=6 order=ok gpr_mismatch=0 pred_mismatch=0 mem_mismatch=0 check_failures=0 class_violations=0 overflows=0 credit_leaks=0 cor_late=0 channels_used=30/57 violations=0` |
| `stall` | `name=stall finished=1 cycles=581 from_fetch=536 retired=116 issue_groups=116 order=ok gpr_mismatch=0 pred_mismatch=0 mem_mismatch=0 check_failures=0 class_violations=0 overflows=0 credit_leaks=0 cor_late=0 channels_used=32/57 violations=0` |
| `swap` | `name=swap finished=1 cycles=581 from_fetch=536 retired=174 issue_groups=174 order=ok gpr_mismatch=0 pred_mismatch=0 mem_mismatch=0 check_failures=0 class_violations=0 overflows=0 credit_leaks=0 cor_late=0 channels_used=32/57 violations=0` |
| `transp4` | `name=transp4 finished=1 cycles=1248 from_fetch=1203 retired=976 issue_groups=976 order=ok gpr_mismatch=0 pred_mismatch=0 mem_mismatch=0 check_failures=0 class_violations=0 overflows=0 credit_leaks=0 cor_late=0 channels_used=38/57 violations=0` |
| `unal` | `name=unal finished=1 cycles=174 from_fetch=129 retired=9 issue_groups=9 order=ok gpr_mismatch=0 pred_mismatch=0 mem_mismatch=0 check_failures=0 class_violations=0 overflows=0 credit_leaks=0 cor_late=0 channels_used=33/57 violations=0` |
| `vadd` | `name=vadd finished=1 cycles=197 from_fetch=152 retired=17 issue_groups=17 order=ok gpr_mismatch=0 pred_mismatch=0 mem_mismatch=0 check_failures=0 class_violations=0 overflows=0 credit_leaks=0 cor_late=0 channels_used=34/57 violations=0` |
| `vadd4` | `name=vadd4 finished=1 cycles=214 from_fetch=169 retired=68 issue_groups=68 order=ok gpr_mismatch=0 pred_mismatch=0 mem_mismatch=0 check_failures=0 class_violations=0 overflows=0 credit_leaks=0 cor_late=0 channels_used=34/57 violations=0` |
| `vadd6` | `name=vadd6 finished=1 cycles=319 from_fetch=274 retired=102 issue_groups=102 order=ok gpr_mismatch=0 pred_mismatch=0 mem_mismatch=0 check_failures=0 class_violations=0 overflows=0 credit_leaks=0 cor_late=0 channels_used=34/57 violations=0` |
| `vaddslow` | `name=vaddslow finished=1 cycles=572 from_fetch=527 retired=17 issue_groups=17 order=ok gpr_mismatch=0 pred_mismatch=0 mem_mismatch=0 check_failures=0 class_violations=0 overflows=0 credit_leaks=0 cor_late=0 channels_used=34/57 violations=0` |
| `waypred` | `name=waypred finished=1 cycles=255 from_fetch=210 retired=18 issue_groups=18 order=ok gpr_mismatch=0 pred_mismatch=0 mem_mismatch=0 check_failures=0 class_violations=0 overflows=0 credit_leaks=0 cor_late=0 channels_used=32/57 violations=0` |

## Manifest of release/

```
1b66ea489addeaaaceb4fff98f56f9a57709ebaa046ec1856b94dbfce0918d49  release/kernels/addrhigh.by_instr.json.gz
b2aded85e679d86865f790b37138f8e8748699dd35a8bd04cf2916e67fefbf82  release/kernels/addrhigh.by_unit.json.gz
00aa9f51998bb9626c92b99976dd5d7c69de3f61b760968761b82ec90c505a5a  release/kernels/addrhigh.ccvtrace
92e2aecda02effc982678cb466567e0f43d3f5d314b95b18e8a354845df469b6  release/kernels/addrhigh.log
569f2e22883fad5f0956c57ec734e6afbdd4b8a854e50277425172d6c0cbd766  release/kernels/addrhigh.oracle.jsonl
0c30e836f5d51b85f267450e06d39f24c0fb0a587dfca68ac7b0088b447b2c5c  release/kernels/addrhigh.sv-hosted.log
6f10978c0d2bd2310db94413467c8192cf3405769ad19e4433cace98a196a795  release/kernels/addrlimit.by_instr.json
c9b8824ec76c0493a6e3f51a0c5aaa410581aac6b011c5157178ba5a2a4f4d1d  release/kernels/addrlimit.by_unit.json
020fba3b967ac88b1009f3f689ec377a7d962cf63f31f9c59ec8053ae96508b2  release/kernels/addrlimit.ccvtrace
b0f881cf485b3bef7e15f1ea2629ccf61472055a0099dad3d6e879a327fa521e  release/kernels/addrlimit.log
bc660b0b40359a2c5a2478cb0eb4950b73fd22db50ea76b80052bc195a1920f4  release/kernels/addrlimit.oracle.jsonl
732effe30ba9a9d18c8dcc3a7c1e5d65e8d971473e011bfbab44a2d06f9fe4e0  release/kernels/addrlimit.sv-hosted.log
10f790f623c1988a4a701b2ed1f204612448086208931a7456e0648c455e87a6  release/kernels/addrneg.by_instr.json
6cc01cc7db43eefe2161b7fe13797f4b45c7b10c95bdc3155e57503425c4b5c0  release/kernels/addrneg.by_unit.json
66fe93895419e62fd3c292424e693819bae503553e64c4bc92c6ed729179d869  release/kernels/addrneg.ccvtrace
0330a6a734392006f0d6e7efa2eb9d4d7edd04fbd6b379e26a508abeab669f3e  release/kernels/addrneg.log
16f5b0707ae44492a1efd67bb9dd38a7e79a7bbd354fa9207b9e7d150ff2f107  release/kernels/addrneg.oracle.jsonl
ee26b2a23cdbda0f8f23eaef2cf2b9e39b079ce8fd9a8e4d122cdcfe679f7296  release/kernels/addrneg.sv-hosted.log
809ab8aeb25d730714297edf8c5af40463dbc8f421bfd83461e62feba97c6e91  release/kernels/atom.by_instr.json.gz
737d94a20078397590cf18e2c2396b9ed785dcb0cad30453032b8a90b6dbfb63  release/kernels/atom.by_unit.json.gz
66317cddfd6e2c68a4fe4a7ceaac59358d16c75f4c2e8f6d47e23238287919da  release/kernels/atom.ccvtrace
55893b530a83e2ce45b27274064d5bcff2b37e40d5179bf8756a9e005b1c48a7  release/kernels/atom.log
504f5b6e9d25114dc35f2c70b21bb7b3f3c508c691de12dc0e87d12a74285361  release/kernels/atom.oracle.jsonl
d88c28c6bba86db38b1ffe8b969fadacd80fc9d057999c6d9b2f8a8ed6d6bc70  release/kernels/atom.sv-hosted.log
1ce5f8e7b55619752d699bdfd8f9e9fb34598b46423e12fcfa1509cf66342413  release/kernels/atomf.by_instr.json.gz
9858339c394a93d69123db229976b927ca2df0e11e4d6c92196a465e39784e6b  release/kernels/atomf.by_unit.json.gz
dec336dba4dda0da039100750f613725d07b5a6c61bc703bdeccafd4266ed5a7  release/kernels/atomf.ccvtrace
8afd4c8b59dd8fcc71f92d8607c7881d6feae1bd3e351e25e67db34fa695e6d2  release/kernels/atomf.log
cfd1179edf4061a33ab2f75d7a6dec61decfe629000198189a7bfc2647b34238  release/kernels/atomf.oracle.jsonl
960cd783328000d1301eb562fe58f492604bf962945903a11441239ae03636ff  release/kernels/atomf.sv-hosted.log
51bb43e975b82c9ae4e8f9a3bae7011756e227f1c2be230043eefc72a03b8028  release/kernels/borrow.by_instr.json.gz
137b30768dec8be53ec58769f72836def15056b1d08587c1f8e8cb48db281e0c  release/kernels/borrow.by_unit.json.gz
c162f4ee979318135abee3d266de57454e5bb84ab973a74730ab811eb7e245d6  release/kernels/borrow.ccvtrace
f1813ef125fc3deba0750fef079148c27c229ab1605ed6a5b5d4f4ce6dc4519a  release/kernels/borrow.log
4c565e1ce0b3baee36e158694b32c8defb5cd662b2f9af75cb5d8c26cb1168ed  release/kernels/borrow.oracle.jsonl
095e8dd5f48a88a704ebea044b8e3892e34796d6f6895987697a84f5bde90818  release/kernels/borrow.sv-hosted.log
d0b1641317157a51f21358c96b19bb4ad50d49e7a42d239dee358bf930a7fd50  release/kernels/brs.by_instr.json.gz
de0394648f984a4b82f157d7fe5cdf7481d5d982aff9e3defdeb6a705813e796  release/kernels/brs.by_unit.json.gz
dcae433e5ec770eafe8f8de176cb5e74dff81f2342d0c58f9f7050cd86f73e51  release/kernels/brs.ccvtrace
0b083a297d87774c1f8ef01cb87b20fc202f400c48ab69a79849ff418c071822  release/kernels/brs.log
e3c1cb3379580cf1aae44e8ddc8e846ef6fd661a573cfe0a8d4444b18a14dc56  release/kernels/brs.oracle.jsonl
19418d95a1c987c6548827eeb79b52e072947ba0d2d353d290e82a21146f5e00  release/kernels/brs.sv-hosted.log
153e80d93102c5a592f4599f0124a901ce904ab1f901ee2f749616c4184ccdc2  release/kernels/byp.by_instr.json.gz
cc200dc70e249260448d2faa4644fa6933016a7b4da6a17cf7b2a65e6bdb089c  release/kernels/byp.by_unit.json.gz
fe3aeae66e69efed04c08c783f324da8c7da50e92863154f874f2b10b2fef80f  release/kernels/byp.ccvtrace
55cdb677a6ac2a4a56c3fbf6414a6dfb18c635ac05c78cc74eaa1fe4b066e9dd  release/kernels/byp.log
5a03dfa4f3603fef49f1e3639e74e34152ca3ca5ef8e41eb959f8323040fa2d5  release/kernels/byp.oracle.jsonl
fc17495779a6fb306666ea4a3919d67adebc47aaf633e3a21adb3b802ad7f35a  release/kernels/byp.sv-hosted.log
43b5b272742a2d7bac7454c48adaf75d14372cf8002447859776ecd751f26ffd  release/kernels/callret.by_instr.json.gz
afd5da5f65b289cc6c2a58bbb78731d5599fccfd0b9461b99cc663357b81ceb5  release/kernels/callret.by_unit.json.gz
a634c93c02419e38c904a3e03403f22a4f60897ef7fdf77ad2872956e77a422a  release/kernels/callret.ccvtrace
d809673c05efeb5a8eadf7e5df25730e9a4ecfe50a6dcce4e6b2e59090b4f704  release/kernels/callret.log
9b1d1b50b527f732362f837250aa2f26dabf3e76e16a4794856ebd8f105635b8  release/kernels/callret.oracle.jsonl
ec68ab5c63d42385936a7bfd248d0affe83fdd8a288c5a21db6488db8c686e15  release/kernels/callret.sv-hosted.log
72c015638c3ef07cf83528c8d05be4feda2e037ad8e8c360179cdf7781efad14  release/kernels/cas.by_instr.json.gz
a324084841bf0309f5d3be744f0b10989931c2cc2f31add9cff4b91017a23e3b  release/kernels/cas.by_unit.json.gz
99847c8ddbe72f92b5286f2292ccba324b846976d7f44f571d7c9c096b0e1d5d  release/kernels/cas.ccvtrace
c6b3cf3a0d7077da5259e3566665a500e55a60b2500eda26b2bdfef2d8427b41  release/kernels/cas.log
0ab31a9443336fe5d08e1a5fa5fcba3bc279b19022f7c5007908d39d8ef39536  release/kernels/cas.oracle.jsonl
0c2513bead5be73e8d3abac4e1eb8238598256a4d9297b2416ad6bff7952f547  release/kernels/cas.sv-hosted.log
e979945448640c4b81fc269ead4f4f12ab7bae7055297a69fec930a5a9cef12e  release/kernels/chains.by_instr.json.gz
4b4114af1a95c18d8c32e25b60101a6c69ca619507561150c0a1a1b2ed866dd3  release/kernels/chains.by_unit.json.gz
f0ad6748d7e0809133787f5d672363e8bae7c700f2aa200f9cd057ad8060fef7  release/kernels/chains.ccvtrace
a6bfabbb9bf680943f7b641ec43a04340b0774378cc3a50b4e948f2839d2473f  release/kernels/chains.log
26a4cc5c5524c7219d8706c2582c80357dea60be9d6ffdec99dac7d0365e2264  release/kernels/chains.oracle.jsonl
52a5a5c2b79ff20273b2a07244d2481342da252796ed52397730c757022213a7  release/kernels/chains.sv-hosted.log
1dd86a6b25a8c8c02978ecb71899606a4fe07fa25fa9aa6e770022efd23bed03  release/kernels/coll.by_instr.json.gz
a491de39240da2ddf1737f1a54932a927339a5c06f19d3f4a5c28854aad82cf2  release/kernels/coll.by_unit.json.gz
b75fa7bcc42e58f6bf4fb8cbbe71ed872b553a772affc2eb2ef51dc12c1a52c5  release/kernels/coll.ccvtrace
b39a8cadc87bc32f28c08b9a73c3261de8f11c3b6dcdb04bfd0d4e397c99abe8  release/kernels/coll.log
dd718d23c88df5dc7d92b055d8542865aa0e029118486af127312a8a578cfcbc  release/kernels/coll.oracle.jsonl
b7faba4534f40ce4168de8812dd55182a6c61c8fffa3e9f0c3dfec921a25df02  release/kernels/coll.sv-hosted.log
d14ec30aaeeaff1dad9b85c128c044cb98239678366005c3d108a67ea825a568  release/kernels/div.by_instr.json.gz
4dd8dd0ba888d6ef60d35664e00281a546bcf287eee5ea68f0db304f2e584c2a  release/kernels/div.by_unit.json.gz
8d99973e50f9afeb5d145583eb1ce13934a3fb75d2b7f2f5e247df23ac8de41b  release/kernels/div.ccvtrace
d7919df9247d6a0d8fa99dbef73f6afe51fae529cfd37938dbef0fda024c1668  release/kernels/div.log
71a567b85cf85622631490187563de9a5661099c78a590adff4ed0a0c3d24c16  release/kernels/div.oracle.jsonl
d69504c821b69a0afb122e3f9a955406725dfbde9cf098eee9bdcc55d8f8f69a  release/kernels/div.sv-hosted.log
4d943c7394b37ee89a81660b28eea77ae56992a97dcdc10bb59636221fb5119f  release/kernels/divchw.by_instr.json.gz
026bac955e5814a10c5e11c7eff59627e5069e03867581da7b794b7bf57d2a6b  release/kernels/divchw.by_unit.json.gz
b586c3d04326fe6df68acc9c5ca6cf0ef96d2f691b57c37141ca67ab39ee0ada  release/kernels/divchw.ccvtrace
8e98bc61fd8e3606912d8093d549804966389e299e8dde9c498799a804b85dc9  release/kernels/divchw.log
58a541797f7a2df0a1c7528ae6a3edec212db90c7d3eb20656806f38b5c10b3d  release/kernels/divchw.oracle.jsonl
db6e0f1c12d47fea91da0e6f0a0cb7bf0c591dd2f79871dded266ba9533bd49f  release/kernels/divchw.sv-hosted.log
6d5e5157df642d7528a045cfc54613b1a3be06f810da9275c16487583af0d201  release/kernels/divtail.by_instr.json.gz
a2298d5f442796d8f277b85a7a54f93fa78c9d0d40c9a3131777124316ebba28  release/kernels/divtail.by_unit.json.gz
749943c90ca6381984c767ddf1e730d5f0bfa9c89b79f6bc65412000033b77fb  release/kernels/divtail.ccvtrace
677d94b0f55cd660441139fea35d214065419ef1b010e967e033c5442e7c6c2b  release/kernels/divtail.log
75f11a75c9b3b336e446140af4579f05b46c363a76b7aab3ec88154a07ba097d  release/kernels/divtail.oracle.jsonl
00f7fd0ed89f03aafd3620f6a63b0cad0c812081ec6d0c6d85368422736b5e85  release/kernels/divtail.sv-hosted.log
bf7ef2953c343f8f78bcf1987ac1bac5c636c57211093d5354dbb5b68c938dfe  release/kernels/divtail2.by_instr.json.gz
06e4a607cd90447e915eddfac7a805d04fa8df9cd09a3282544610025962b902  release/kernels/divtail2.by_unit.json.gz
b409d4c368805e11a470d0fc0ba1ea8c8e14005a0119c058a648485abfdf5cf6  release/kernels/divtail2.ccvtrace
d8375bb9de932f1df9be9a1af04b6184b3e9ff0b0a12c1aed0fd2d410c35ff59  release/kernels/divtail2.log
b2db6b05eb6cf4a0a7677e31d0c6c2952d5cab49d353f0bb1883fe0b2a20ed14  release/kernels/divtail2.oracle.jsonl
673be634870d7049870db565a470495490942c97c6c7d74f6fdb735da81376ce  release/kernels/divtail2.sv-hosted.log
89f180ab50b0800e573e41f47badbf93b78a6627d7c18c5029a3ebb03079d5a1  release/kernels/fence.by_instr.json
1c3615bf90f3b353a9b185573772cae3596f412e6be48bd1fd0d20e8275673d8  release/kernels/fence.by_unit.json.gz
527d7838739ba7af7bdde873fe9e9b17db1d33b715e56ec4fe213a940b792cdf  release/kernels/fence.ccvtrace
b8fd3aa74abdfa82c892f6252498affa357d62a15f5402049641835997e3bebd  release/kernels/fence.log
d1d40317f6cf5bfb430cda1f9c0ef676609e59cabe2a11623c42ffbeca93142b  release/kernels/fence.oracle.jsonl
62d96f3c2497fb8fc215772db6eb2a418100c1bc06ca2eec37558bb501546819  release/kernels/fence.sv-hosted.log
a4cd6bba433f50c83bed55dc498b4d9140c713c116919ed025b871646085939c  release/kernels/gather.by_instr.json.gz
01505c53dc9aae7bd9af42c4fa01124af42f4a64513bd0844b865cd384a29c56  release/kernels/gather.by_unit.json.gz
b99395a37af3f9984a8a5ecf1d762e60da2ad9727302b9e2a7b2266490383a61  release/kernels/gather.ccvtrace
2e31806bb0a0a3306396e515d9369e19eccfea6dbfcc7b45240dbf7702db24df  release/kernels/gather.log
0413e781d8d6ff578c64eb1f800b7931e66f676d5cdabb97b94a4033e6037662  release/kernels/gather.oracle.jsonl
8f085dd40a9041a87f3dd02390c791ef87fd6e356004cd944a9c2b37ce780da0  release/kernels/gather.sv-hosted.log
76b7364164f690d7f6a2ccb4a013dfee76363eee36bf309f2748fb7391ab9455  release/kernels/hit.by_instr.json.gz
cc6072216881ee9d6d3e8cb0454263c43c7a0ca4dab3a89ceffd5555329b41e8  release/kernels/hit.by_unit.json.gz
a74b37a23cb2bd91815bfa2cc3ef0e2eda66a061dc4408be84eb9c176a30104b  release/kernels/hit.ccvtrace
8a0af00d41dfe9f95b13b253369c11335a1427a8be909908291919726c8a6ded  release/kernels/hit.log
7ba9603e0088d9164de6528f16ef6a7fa9ce5821c8c12b52cbb3734e39b9fd52  release/kernels/hit.oracle.jsonl
36e27d2de5d7242113050eb518411a5b5d89d1a64b069fe53dc1cb9d1829714f  release/kernels/hit.sv-hosted.log
498738c81cfd620eff152d136d0963f2b20c457b3bdfaf05e28824e6fa31b6b4  release/kernels/lanectx.by_instr.json.gz
f7275ac3380fe4cbce6612fa08fe6a119968b9f8c855579ab64084c7cfea4a9b  release/kernels/lanectx.by_unit.json.gz
019f350c5b82a674093d01edd79ba4b214a7d9b24cda3eeeaeb7a9dbcad4f248  release/kernels/lanectx.ccvtrace
d551dcca72038197184922378ab3cb3fc18c3e852773864ac686d46985beeb47  release/kernels/lanectx.log
888551babf540db8e3025b82e65ca655013f93eba3c8a65689d069d52a7e6039  release/kernels/lanectx.oracle.jsonl
59feb5e8e6370ff3aeb7dbedd53af5c67d9f1baf5a9b4ed22d7dc26ec23a067d  release/kernels/lanectx.sv-hosted.log
b850b8481b79b020465349ec7e9429e8f01527f4b0d77eef862df8cc6c1162aa  release/kernels/lanectx2.by_instr.json.gz
a59c8e751caed0592323a2c3656fbfa086a6857a6d295d2584e2f60620557a73  release/kernels/lanectx2.by_unit.json.gz
8e240ee934df5ee507e1a24ca759a52dcef71613c51a5fec463e17d1791418b7  release/kernels/lanectx2.ccvtrace
28e8c3040dd32e765e6e34f7078a318b85e80237edb4622b9e67d3cfb49c8a6f  release/kernels/lanectx2.log
45c13056dff5c73ed0c9ece56cc36f929bf335322193c7d5eb38710b1d1dfb02  release/kernels/lanectx2.oracle.jsonl
abbfe649c1dbcc95e86fdfaa93a275b304b01d91a04f3c37762c2f6e1db5e2f0  release/kernels/lanectx2.sv-hosted.log
b61c5dcaa092a20c20001f90b14658625aa8d3d9a64088279910b8bc0810afde  release/kernels/late.by_instr.json.gz
4e8238c5b0dd6c1d102269e02d8e3147205d7c22b638f04c302c2fb5956530d3  release/kernels/late.by_unit.json.gz
b004681de98ac30f08888801e20cc7e79f91e6d6426dab59c7b23723336edf59  release/kernels/late.ccvtrace
fa5365170fad79e804cf9ee2a59a56438d007da7c1f48ad144c4130f74a73297  release/kernels/late.log
86084f6bd747a2cf32acbc0ebd96ebd3e4ef2d8d9e21be49e3ae49290d7927f3  release/kernels/late.oracle.jsonl
94a61a4c700b1f9346b694df8025e05c9e5c12d658626b34b71e109d78cf25a8  release/kernels/late.sv-hosted.log
21f389e00edfdc33e40d2bd10c1deaf49e367432d09d369f0ec1cd5d1b136340  release/kernels/ldpar.by_instr.json.gz
e27645d03406679cfb23589745ed15d9ce87d82aee6b0ec1b5bf0db1148cf0aa  release/kernels/ldpar.by_unit.json.gz
aa2fc2e76a50927b9bab6719b58e1029c0c179ee20fa974c0da734d750de4b6e  release/kernels/ldpar.ccvtrace
9505f34d83863b7dfc23649bb22bfd32d8ecd4eed7011554b840d7581834fb11  release/kernels/ldpar.log
8ac08538e9c807637babd61b31e340f7461878ada31f0c0b83cd66331cfaf486  release/kernels/ldpar.oracle.jsonl
aa9aeaee8017b4183bcd6b4239cffae4c909210987f8a64801b43dd2a752ac54  release/kernels/ldpar.sv-hosted.log
7444e82463b46aa8c0d0b84c4accdf7fa31dd8717040ccdabe6b0519ddb3c493  release/kernels/lnorm1.by_instr.json.gz
f771f2834eb8e1c4e58fb61615cacc0064ff51fd19b6899fc4ef60f7ca188d57  release/kernels/lnorm1.by_unit.json.gz
05b46d026bd44afb1b50d7235276d41fe4c810e728c7421df9711beb90d6d0f2  release/kernels/lnorm1.ccvtrace
a2e9db2d56f1adc50dd9a277cfca6e30124a1f369a8f3026a4002603b0453e30  release/kernels/lnorm1.log
a8d85811af988a1b9fc00db1517300af3d93ec8e589e403d3b9113fa9e0ffc86  release/kernels/lnorm1.oracle.jsonl
7c22d336c50fe3f660f6b1950640266a5213e1f481acb56d9675fa86fb3a8499  release/kernels/lnorm1.sv-hosted.log
a064658f403458c51f7788b6ad8599f3acf6b950097cee1472e76b0a889fa490  release/kernels/localsp.by_instr.json.gz
87783dc959f60409828ada7c421ed85c5e0a94d56e7ee70b24f61b76a2b2c803  release/kernels/localsp.by_unit.json.gz
d729d72f91cb10b2cb4572c39668fe5dd28872996aec230fb5e116c0300b3c41  release/kernels/localsp.ccvtrace
a0510a72040183d3597ac688417e57cacc35b3fff958fcf39b95fe18a499d802  release/kernels/localsp.log
55e3c9f36e7f7d38c0ddd38903aff4bb4509ae862015c592e6b937ea258042ca  release/kernels/localsp.oracle.jsonl
df615f1a79028327115befa64394c51934723a697fbf012bbc72efbd1826fb94  release/kernels/localsp.sv-hosted.log
8e446c16437d5874d2b9cbe33214e173e3b5abaa80ad3f8d63803b7f58e6cbeb  release/kernels/loop.by_instr.json.gz
fadacc856421fd1a3e72336cf4934b9266545c53c79b9e38eab0abd9c38df201  release/kernels/loop.by_unit.json.gz
74b9f2e50c9a86a19eb43f81e823c8eec68401f745933b7e2c8280f07eedbfbb  release/kernels/loop.ccvtrace
3765b35721051959e066760294f5310c677fa8ca0914c28b19d5aea8c272be68  release/kernels/loop.log
03ce5920c06c93e93516d8e53c3f7169f14e3593de204eacceffc0b8a3e32016  release/kernels/loop.oracle.jsonl
dca72445285bb1d54a18e1a62cfb17cb675125a58f6a13c2b03cacecfb956890  release/kernels/loop.sv-hosted.log
3c8bd92731594983808429749c1a5a943e38befd8f64de5f91c81595be874450  release/kernels/merge.by_instr.json.gz
02693ac4da125d8e80e1bfc76db5a6fa424ba62c578d5a8d6ed423b37024f83c  release/kernels/merge.by_unit.json.gz
16a07404e2ac320f4a41c6090712201a670d5820c1fec3fa9b2e2b1f5ae87489  release/kernels/merge.ccvtrace
b7c2d3026453b60afbd59daffdfe119774598bc96f4c3d6d8b78f12fba330528  release/kernels/merge.log
f96d28815f8756b1f5a45ded53e6170883d2dfa10f9eef0d14b8050b1318164a  release/kernels/merge.oracle.jsonl
a14b8c4244d31e9e3d9c2965b515212e460e6b71161f94f11bbe3ce04e1a95e8  release/kernels/merge.sv-hosted.log
9df7f9598c37913a6ce404a6ab14c6aa6e797bf2d779c9047f20e7dcb2253152  release/kernels/missrun.by_instr.json.gz
fcfecb83f9307e0449bea925c8b46ec23e7c61d2087e2b33a8194cd94ad1eddb  release/kernels/missrun.by_unit.json.gz
e0b95b2a02c9c64dc947e737831489359ec7afa20f837d5cb5385f3a4554be2b  release/kernels/missrun.ccvtrace
20ffef0ccc98e0abd6605ba7f18c56c8b6668b7bf04fb1d88044df793f8f3741  release/kernels/missrun.log
531bdaf281e5590774bd2775427f25e4cc0419cf8e3d5b6999843ffe9ef87258  release/kernels/missrun.oracle.jsonl
3b2d13e1557357da3d3f404299ab0f7976cda851206b53ef7bc8ed24532c3df9  release/kernels/missrun.sv-hosted.log
efb772f316612987b41485b2f22d2fc096f23e43610c17c78eb61cfa686a36c0  release/kernels/mload.by_instr.json.gz
294d26cf4baa817d19bf840c2de339ee0f12165ad3b7bbcc7430441e8933fad2  release/kernels/mload.by_unit.json.gz
a8d174b478a4b3d1b1664710cf3acd91c711252fb4860893007c0bd40013a41a  release/kernels/mload.ccvtrace
74b7d36c845a6e39c5c1f90c461281c372eb05b0402ad815de689020cb5ef8d2  release/kernels/mload.log
8000e477b9a95dfb9f0af964e8346acb9d36f1358fd06ffc4ff7cf599d2b8868  release/kernels/mload.oracle.jsonl
767169fdff1432b7d1e2461a489979474712e5c0dfb44ffbd9a3d7ad7aaf5674  release/kernels/mload.sv-hosted.log
38d65df8f1011fab30c1ca0d47b996dd7296583c47edfaf6e89fe5aa6d6721cf  release/kernels/mlp.by_instr.json.gz
380b24528ebd420dc08e6f89ea1a52e975f8bd4c1ed09b0b773fa1e4fcd22109  release/kernels/mlp.by_unit.json.gz
529fabf8fb1baa707088f0521496a79ba91f54c538c9a2ffc2c14c07d52d726b  release/kernels/mlp.ccvtrace
991f0502b84b02382619851e83386e257588c0a84b094ddad15f934176400756  release/kernels/mlp.log
138d282f88d56c8ad648a91af0a983254b55d9fa22942c00d47b327f516a6e44  release/kernels/mlp.oracle.jsonl
1d5cba8ad9f8d70aa88c3a2ccf5f5471eb0df1405984f039961713ee7c8d0e82  release/kernels/mlp.sv-hosted.log
7f74b3620f3480f7a5aea9153617fd2e8974f4742fd506fb0aa8a9623896d7b0  release/kernels/mwmiss.by_instr.json.gz
81c9f64f77025949b714f67f486787e1660cc170a5032fbe4c04573fa1963764  release/kernels/mwmiss.by_unit.json.gz
e57a4e49ca70cc1e10f290797099f6031cbf90bea00de551bc124c97b17eba38  release/kernels/mwmiss.ccvtrace
50beebc354590cf7b8e71b5f9a6fbcd7454424bc062d14bdeb1ebf26a4d401dd  release/kernels/mwmiss.log
8abe8e8997456a2a6711ee72da54d854b24e20abbdab28e4b7271c0d28418de8  release/kernels/mwmiss.oracle.jsonl
c2149d53390eabee6e79fc3b798eece6401cb3e6cb6b972fd79c1ce94d8e9e6b  release/kernels/mwmiss.sv-hosted.log
0df78b67f8f97c5f5dbcaa0df0ea646bf499523b4d75259d1fc09b18da392a57  release/kernels/narrowadd.by_instr.json.gz
74a8b836d3e53bf0c70a61761ba96354128814ee45dd968d2ebb1107ef2f2963  release/kernels/narrowadd.by_unit.json.gz
c0bfdc446933b7e543814b458c49f8c90e34d7431b0e29fd1013f942a91d74e8  release/kernels/narrowadd.ccvtrace
3f46aabe318f3a0d59182bb02c5d6897b0f6177f08c2120b68607c86c97f4e89  release/kernels/narrowadd.log
40a2cf629853dd404bb06b4a07e35abde3d12efc13f26ffe28f923daf2994574  release/kernels/narrowadd.oracle.jsonl
0faf9c2119b5365fcebc761e5e51d7e97464b3ab8151d1b25a8a85d38ec1d6ef  release/kernels/narrowadd.sv-hosted.log
a534ae142d925e5cdd9b160a963c315b9995d77386dec824e3b84d68182606ad  release/kernels/pgcross.by_instr.json.gz
34d4e5f9dc9af5cffc8ead636e724bdb831a6906778c64ff3548b4b437a017cb  release/kernels/pgcross.by_unit.json.gz
766a838d10365215d3d9a89ce421fed2ba6526c5ef7046514acc18eddc78aec2  release/kernels/pgcross.ccvtrace
da552950b7bce0e061082cdeadbc1e71168f079b65b39f207be984ebdaf121db  release/kernels/pgcross.log
58aba9ba5ec6a72271191c0249014802cdc7e4470d27491f499a077f17ecc039  release/kernels/pgcross.oracle.jsonl
87443d6cbb092fb498025b22afab19dbf4310c424499caf2ca8546a2edc18d33  release/kernels/pgcross.sv-hosted.log
16cd09b15e1054b0ba092372042035756f8c588704f3d99ddf4c868c2a55f131  release/kernels/pguard.by_instr.json.gz
7dbcae99704a529d3e3c560b7554b19db80eaa9d37e03542732169227ee4bf6d  release/kernels/pguard.by_unit.json.gz
6fd5d014c3c108d474d24c6b7a79fb796e4279692b33eefb21962f56d6c7981f  release/kernels/pguard.ccvtrace
3a740ffc4ca4a5eaa98190f6412560b4f783c0ae4a1aa9cb43b41acc9690ce09  release/kernels/pguard.log
690e56f1cb8d97cbf67124b7dff3ad0a90cb8981814cd1709cf0cd0e035b3bd9  release/kernels/pguard.oracle.jsonl
89b9954102a68144112864f8b099833cfd68efb09ba90aa156db2ffe0cd647a9  release/kernels/pguard.sv-hosted.log
6e05603ff17387ea621036eb9b896f8c40ff0383612755e3c56855ba35d1a520  release/kernels/plog.by_instr.json.gz
0717f64c703181c7784111265c8f8c5fc80bf9fbc8d12565fc3d32f22652ec44  release/kernels/plog.by_unit.json.gz
e8bbf197bd772c214ea56a64eaa168c48dd5567c595a3865d1b48c638c317196  release/kernels/plog.ccvtrace
058d5ca2c8aba169bbfbe682e6d6b3804654347dfe79a348c25363936da6d7b0  release/kernels/plog.log
0c99915e2da60f4670da00504a6371d7d17701d4431e733a3ff8fa98a2030d6a  release/kernels/plog.oracle.jsonl
b3a0955abf43002d227fd87cdd35648c06b14597e315ad12175f0bfe7c42845b  release/kernels/plog.sv-hosted.log
357966a456b38895c93b9992bb80178c768318227060385782e613599c9956fe  release/kernels/pmovdiv.by_instr.json.gz
a01c26373d634d20d87e1a98ea26619ff7bc1457ea3039010e10a8360dc8bf2c  release/kernels/pmovdiv.by_unit.json.gz
c738ef1a8aafb2e2961378ffb44b60776e1aec6b52067efef14fa332b46653ce  release/kernels/pmovdiv.ccvtrace
95b409843aa9b97c9e1074bb6f5c3a3bdba1d626cce1a9234f96de33e5f0b1de  release/kernels/pmovdiv.log
7bc646cff6166a51bdce03d7c1b7209e871f0a91d743083a9b910a80bcd0b33f  release/kernels/pmovdiv.oracle.jsonl
093fd1c9499dfabe95f8fbcc86c6cbfe66a07803f41a70259c463ec20336019a  release/kernels/pmovdiv.sv-hosted.log
5e0f4a309baa5dc92f5426f33b714514ed1c0a8e5e21a79e69820b1d2d33a2b3  release/kernels/predlane.by_instr.json.gz
f45664172624e14c28ae7663b74382b7714c834f9165572828c8f4689871fb01  release/kernels/predlane.by_unit.json.gz
b484ff674c5d5c62efcdbbf021c53608ad93bce7e109325607d503007afe1f92  release/kernels/predlane.ccvtrace
dc17455b0d57c8acf1cbcae1a1e4ceb065d72fa9a5a2490fcadc6c597dc95c61  release/kernels/predlane.log
c45f4177b9e84fc8a6e36b13534a0c7636eb30a3f8531847100ce5e23bf404b1  release/kernels/predlane.oracle.jsonl
4e5b0faa855e31f2ed98c3d40376a70689ea7bae74c801ac79a99233fcc6446b  release/kernels/predlane.sv-hosted.log
a67eedc98c4ed598a02a2cc8355628475a8812e8338504c92700dc926fead92d  release/kernels/predmerge.by_instr.json.gz
9dad6a6ad513300c2dbf11e791d4fd4d9d7cd6b1939cbdd0052771b7d7957844  release/kernels/predmerge.by_unit.json.gz
b19090334b40704b9762155133f2368a5635406f7cec125532c2b7606de91dbc  release/kernels/predmerge.ccvtrace
3da3f91843daab657ebda8556d86eb3ee9135f502e59096e3ca8c12d7a7f3b28  release/kernels/predmerge.log
6c737c49434bcd08e3e0814c8b1dbf15c586ae74f7929ba3148ddcee2c62c845  release/kernels/predmerge.oracle.jsonl
ad20259046b5b3a10161ff9e96e4bd83742eeacd0738bd5f6e932fa22c3e5327  release/kernels/predmerge.sv-hosted.log
3b1cff0a398361088d14dd5d2cf9639dc051216e1a34006fe492fe4623acb789  release/kernels/predspill.by_instr.json.gz
be9845a0a380f93cf556050a4301dc0783087b72dd7c919aa6e36ece5b8c0354  release/kernels/predspill.by_unit.json.gz
53f8c25a7b7cd82ea629dae53fed971c3d2043efe6c3caa983d1a22b0cc49df2  release/kernels/predspill.ccvtrace
f431e4dcae3b5165c1cfe5ae6f6e61c6684651ccd03dace13c9eedc8b7420172  release/kernels/predspill.log
b7c84c6478117ffa0f06da0e6ad1e4628e2683426a7911080810e78e06a5242e  release/kernels/predspill.oracle.jsonl
041c6e3da43950347246ab53169d829a8cdf3faf0adb6e6ddf2c64f7a89b94f5  release/kernels/predspill.sv-hosted.log
38db7b1db20b1ab20f5e1524a47c0f87771c0d37644b398c0cfcd70171a2abdb  release/kernels/predswap.by_instr.json.gz
1526fa61b34dfaedc13419907535acd363acc3bb9ccbf4a758033abfbefac4bd  release/kernels/predswap.by_unit.json.gz
b7799fbe150ad3930e4d98869fcb0e5a6d5d50d70beaf976076f7a0a2f610619  release/kernels/predswap.ccvtrace
1ae2c95728f8573d7acab1f5e3d5b0640b754e6d2c9ce44ae6d4700af8fecdc9  release/kernels/predswap.log
a6d4f7ed517553816d889c7c9eeb6bcfd1f6c973fbf682ecb69f3c2de619f7bb  release/kernels/predswap.oracle.jsonl
dea71bc8c476da4faefd6c056773de1a6a9d938bbb0f4505d17a51e87f3296d3  release/kernels/predswap.sv-hosted.log
324b55f938f0df5a6754b29b032d54e14e0f74759a298fec227498e65f08986a  release/kernels/privwin.by_instr.json.gz
f2bff8a5cc5acfd4c8a9afabc9c0ae1a0dafc1d98d8595328e5ca3497323e2d7  release/kernels/privwin.by_unit.json.gz
35895703a6c78660094f91b1d65e3b2d7c5e0a7fd81c6413683c60102708af82  release/kernels/privwin.ccvtrace
e86e980d7d1258695cc545cdbb04261ef1914f4143251e307194ab406337bd9f  release/kernels/privwin.log
861f686fc4480363472908d679d8815e8c957d768e7ab32c826930527b0fb7a8  release/kernels/privwin.oracle.jsonl
440f4d8079a0703ba81a8bbd6e686f28e98bbdc0b6e9650d09e4785023310475  release/kernels/privwin.sv-hosted.log
b33a0d479b918de048ba2b96461e8e2f23426e95865ff14dfd5d2703016743ce  release/kernels/provswap.by_instr.json.gz
285975acf2470b043e2c45ff919d22b2c6002e0edf08eee5ef2e3fa0286688c7  release/kernels/provswap.by_unit.json.gz
4d579672be0b4a1adba204682b5d9bc15900e502a378ec3ee58e16ec771ac95a  release/kernels/provswap.ccvtrace
e4ff5f75c0489d5ab17a0d460031f1a6810d9ee401f960563b1f0236cdb4b045  release/kernels/provswap.log
c9c32a793d54cc7401477f582487f7e8b345b2669a75337b8d6327120d98e5dc  release/kernels/provswap.oracle.jsonl
a42974ef4c9e74ee5be536ff9f320a6e6cd1556c7963d197500396355bb5cae2  release/kernels/provswap.sv-hosted.log
20c3581f188264e7ac4a9e72b80e17a2333dc181b65909fa905456f1c4f86369  release/kernels/retmiss.by_instr.json.gz
65e2d959edd83af9448094c9c369740a79dc79d8e5e1c904ac253d5d5bf8a1c8  release/kernels/retmiss.by_unit.json.gz
02c50e62284ba5c6510254c43bae6d27c6bf72c98f495f3c1a21a6f574fd59f9  release/kernels/retmiss.ccvtrace
f02bf819fd7a822b264885666bd83c3a95ad0f29dec77452d620d99c71f26468  release/kernels/retmiss.log
e5ef8538e838c6cff7febfc679dd091cf5e002f82d34f1009b1948ce22bc3649  release/kernels/retmiss.oracle.jsonl
5adfd1730e50f54a8f3083a8c20f95a2102ec1a65cdd6a138aa6f5b82ec1e1c8  release/kernels/retmiss.sv-hosted.log
bafcc75269772f69cc6a89e833b1e3e5b399a536121b9889709f78e7d8405a09  release/kernels/roconst.by_instr.json
ecae62f001689d6db6b667c7a567866101d63dad7f57abe73e77862a9706c35a  release/kernels/roconst.by_unit.json
3041ab5bc88dd35be6c67aab1ef4b9b67a454e0f17914b2060070ef5da3c7a7a  release/kernels/roconst.ccvtrace
f1e18c76b28ff1b33105798a03685ae77da610e7d7d18aeffd4562076416c6d7  release/kernels/roconst.log
8087c0671de620162881aecd38cd6114b78e7be6bd71201e3ec02c9a2e2e750e  release/kernels/roconst.oracle.jsonl
0d5c2c0122521d2d28e3ba34368a0d882c066989fd59ba4cd6734e499ff0666f  release/kernels/roconst.sv-hosted.log
d7978a58a9ed70a2859d2e237a1c2df9e1074d1aa9de5fdac2bd9e9e4e2925d4  release/kernels/rogated.by_instr.json
58b3409b3fe56c96acef8f5a14df32ceb519e8beb9f29a14c632bb0fe46a2459  release/kernels/rogated.by_unit.json.gz
639e5aa87836c9ecbee582674b45dd4dbfd620120a21851850be5588a3cc210e  release/kernels/rogated.ccvtrace
356090631bde4c2dfc9af586b2deeef7d4db4edcc7ca960aae7e8ffeb14cc8d1  release/kernels/rogated.log
7cd02bd4cceec5a044d6b4d6a80df1e68ed0ae71b0b2a953143636d5b809ea6c  release/kernels/rogated.oracle.jsonl
31379db9a2581f6232cd8cc12aa3cc36f8e4ed6b48f54506524c44b63e9e2381  release/kernels/rogated.sv-hosted.log
6c05498f3478297f4ac1d9b6bdd998efb39981bfcaf15249563c604aef961efd  release/kernels/rokill.by_instr.json.gz
e8a19d930e0a915ae84b660111c1714eb9c22f4bd0755b632d1027208e086f4c  release/kernels/rokill.by_unit.json.gz
252fd85df65ee93e64807728cf2ef8498904136f76bfb78a413518f04203fc21  release/kernels/rokill.ccvtrace
18a673e5f8e05c0e44553d606e892a7947213c968715e773066b99c721be8a7e  release/kernels/rokill.log
94efcef96af469a512d346ce61623980fe86383188eaebd55120f716db596f14  release/kernels/rokill.oracle.jsonl
c56ee51a7e88379b8bbc95cbb86db6f3f57375bfe2415a431ece9789e8faa02d  release/kernels/rokill.sv-hosted.log
e988dd13f8c78b16781f62943cd243e3e5a8a2cc0f7138e5d84d1e935cca5cc2  release/kernels/rokilllane.by_instr.json.gz
041170ba819f077970aef6d6c96e8e8b05b4eac470ce3c8e74cfc54006af1046  release/kernels/rokilllane.by_unit.json.gz
18457748f3a10ad45348d861e2b0a155dc57d06d8d4be65691596aae62af46cb  release/kernels/rokilllane.ccvtrace
e571f89dc9f1d7ceb26edce6ba171e937c9933a63c4e322fdcdfc67183010954  release/kernels/rokilllane.log
f5ca6e666eff2f44894df74a291b43b3c0e7be0a63a47d795fdefd7b22016f45  release/kernels/rokilllane.oracle.jsonl
d22e4e3495a5e74d4cd6ad98ff91bf382e6b9b1dc9b12f44f516d4bfd12d13d4  release/kernels/rokilllane.sv-hosted.log
fe81a58560151c8ff253f74922ca0066dfcc0d03b906cc7699ef32f75adae23e  release/kernels/rolaunch.by_instr.json
e67038adcabf20bc2e751707128a879d3339930fc63ef2663c138c8c777cc1f7  release/kernels/rolaunch.by_unit.json
cdb1bfcd866ec71dc9af6efbf59373b10e5aa2fc42298fc5040b4fd17cc1af99  release/kernels/rolaunch.ccvtrace
226e929e77b439095e52ca77cd6dbb2f25431ee27e35de96b6e2041abad785c8  release/kernels/rolaunch.log
e7dad585c3e70615de04330fd03f4f282c29a005dc1732a35655fb261d51139e  release/kernels/rolaunch.oracle.jsonl
c3286d84dacc43eb1a1915ee3856d39746f944a324eff235890c1e7c8a02df0f  release/kernels/rolaunch.sv-hosted.log
bafcc75269772f69cc6a89e833b1e3e5b399a536121b9889709f78e7d8405a09  release/kernels/rolimit.by_instr.json
864284d58733a808e1c266543cafaca40d5b353cf78d1f81075dc2a0e391b8ca  release/kernels/rolimit.by_unit.json
e74d95d8ef33bac3ece62941eb325714edfbb227a54dd5a1df1688138eeb7aaa  release/kernels/rolimit.ccvtrace
21205613e34c1fec0627c636a789ae047cb64c37b78399c19a0ef571b8f53c01  release/kernels/rolimit.log
1c5bc0cb8e8b2e69505fb5a551a16d5d10c56f232b88da7a27e336ad7d962de2  release/kernels/rolimit.oracle.jsonl
26f07c5d4bd942e8f6b10af2425cc62e5c8762a89ffe233c35b81fb975cdad4b  release/kernels/rolimit.sv-hosted.log
c750aaf766b4ffb934fe61fa9af28c64b21b1a87d3f2aedb4f9fdf1008d5078d  release/kernels/roload.by_instr.json.gz
faa208adcd716c35fa8df87c61652b197c5ad7a39cadf531a32f9d0f881154a7  release/kernels/roload.by_unit.json.gz
e9fc03480273c1c79f8c397c62177035ea35b4737f406ad1ec3d420c7d6eb54f  release/kernels/roload.ccvtrace
549c900ab24e6c4933fa61064574e9d1ff46f97a368c49b1dbf0ffc56b436309  release/kernels/roload.log
f7c1309cc9764769fb5803f6fd0f2f5e1eb418f2d23fbe5e17cf5f9106869fdf  release/kernels/roload.oracle.jsonl
4a799f554a369b41c441c61e6e6f381038a407dcef1eb8f415a5751a7aea65b1  release/kernels/roload.sv-hosted.log
e12036070ce4e067347115c295a956df7a526ad063749eb51c9a2e32fc4968f7  release/kernels/rope.by_instr.json.gz
75e41a65258a05afd9423be709ea315a3e52a147f081e50619d1e1e5c0cc573f  release/kernels/rope.by_unit.json.gz
14829181e04e3828c82bed6845ec8488544d88bb28c2819ebbcab737b1c21273  release/kernels/rope.ccvtrace
1d9169edb0b3f3fb2301a4df0e30ba0d19fa1c6284a2d18b6d77ed42c3e62a02  release/kernels/rope.log
d55f9efae392dc8877c102c01c0810e7654b666b6ede386328108164c6cf88f3  release/kernels/rope.oracle.jsonl
469728e4f5a215ad49acd55a4da2de5e52697ae9e47839d3f37c83efa409940f  release/kernels/rope.sv-hosted.log
761e8114180a99bbff7d94caa27defd092abd2dd7bf5dbb0b2d74510e27208f8  release/kernels/ropediv.by_instr.json.gz
d951d83813c9698e10798f32d7686c8795f8e981c62b0032fde0ffd4692a559b  release/kernels/ropediv.by_unit.json.gz
1925c339d6c2c9ab9c85c2492ff798158f40a7aef3a19801e92b9328ff3266da  release/kernels/ropediv.ccvtrace
c8409b89121c67f234ed1a8e7999839431a61d79ef642a4eb531b76fc079c8e3  release/kernels/ropediv.log
10c0ec6ec18b7b44638c790033109198c079d07c1537bf193353ccedd00a920f  release/kernels/ropediv.oracle.jsonl
452ba6f698e6940da5540119dcac7e219031d8ea789da19eaa17e7cf3ff2c884  release/kernels/ropediv.sv-hosted.log
1ef04e3cb1ba5336ccc47e224bd42bba2d41e001d33c37bca249205721e7160b  release/kernels/sel.by_instr.json.gz
b965eb83677e8bb395cf5dd6d9b1deed9944436625d33531aebc79d4492d330e  release/kernels/sel.by_unit.json.gz
acf5344b353833a01a9fb4ee3523f673eeace199c0ad663a8ab6b392886c1c30  release/kernels/sel.ccvtrace
31398647de798ca4fc27f40a93d5ee413fca6aabf6d7b1efaf7ccbfff556ae8b  release/kernels/sel.log
87f6a81e8afa004c8039bf2f61c90176fcf29ab29bb17ac44aa016a5cc8438fe  release/kernels/sel.oracle.jsonl
1a1d93439c946247b2b2a9b3c79251ef84241db96a9b1e068bb0d016da0220c2  release/kernels/sel.sv-hosted.log
ed5d5e9e8b61a6545fba02cf8b12c352e27996acbac4094494da21f338d560c2  release/kernels/sized.by_instr.json.gz
1fcf233a652e9d08a8ab80cbb9174b06ef6e156a069f92f0270c0a0bd17cc22c  release/kernels/sized.by_unit.json.gz
992c8e7a3e8e0239f20f021cabcfd4bcaa3d7654b433b0fd800946eeea48dca3  release/kernels/sized.ccvtrace
ec4d252102ead2e70de8cffc3d750aa1f6edf83ca4d4e2eae523c718d8e38529  release/kernels/sized.log
36d903ba1618bd1faa437c9812a6ee6c0c966a63196c796267d74bf2695ebc3d  release/kernels/sized.oracle.jsonl
a2d50f442bbf566def3ea9ebe5afbfb9a943a64e6935d167f9b5d90f706ee43a  release/kernels/sized.sv-hosted.log
a9701aa9498f8ca311cdfddb7130699070d7506496cbf11cfce22ccae3c452db  release/kernels/slotform.by_instr.json.gz
9ff712f09d51caafc9aa335313a29498f43303fddeb694393b16b1629a2be939  release/kernels/slotform.by_unit.json.gz
be84a5aba5dda4c4c31728cd270f4210d25b76cc8682f9e954fbbf12712c4a24  release/kernels/slotform.ccvtrace
2bef212d9e1a9fefdbd259176b5ccf9e6b69b34a4d1a6e62f9c7d0ea4233cf51  release/kernels/slotform.log
8b61db7419b18cea8a646fb628218447e72e84a18a9891ffb73b441736138ab9  release/kernels/slotform.oracle.jsonl
090059931af7978da7fc3919fb9d46fcea958247d84fcc243dc5795155c7f209  release/kernels/slotform.sv-hosted.log
f09c2301925b78c247b8af30687ab1ea8ad0841e6c226c7d7286961258a8417b  release/kernels/spinwait.by_instr.json.gz
c6b4b8b796de32be9b25e6fa60cfff5f56b143a5f67fd922045ed14c95e7ab68  release/kernels/spinwait.by_unit.json.gz
277a4a18697dad1bb63695b1e20e1536e023b96c1d34bc22b0a8c3a3ef015499  release/kernels/spinwait.ccvtrace
d1a52af44eb49ec3140bb48ac589551907795a69f6bc08366a1f18d07a937f7f  release/kernels/spinwait.log
868920637236c878b33779bd450439466fc3626996a3164573dc11d437d5c709  release/kernels/spinwait.oracle.jsonl
32540c3fe9106a847d2bffc9853198df8304daeb939f607ecd1af170654d0a9d  release/kernels/spinwait.sv-hosted.log
aaa81b8f665e4c35226cbea43f21cc8c7d11b6b8111309ec35562af59cd0368a  release/kernels/spmbank.by_instr.json.gz
8a9a118720ac4017c459b471a98686f48cb1ca980dff21aa9df01f11523939f4  release/kernels/spmbank.by_unit.json.gz
febabca872eb01a4b7c0cbaab7a0876f5808df2426c9d1583a9a2c252be96285  release/kernels/spmbank.ccvtrace
4bc11f12bc653af5a0dc67bbeb0e3988af7ee42026fd8f1418f78d2d4bf431c3  release/kernels/spmbank.log
3af490cc37d7a92dbe719b57de216b648536eb301ff9d13de9a39f50d150d725  release/kernels/spmbank.oracle.jsonl
a2de2f8bcf11182bec49a3e4e19418ab1d20768c8b846ffb62d7ea6b88cde2f1  release/kernels/spmbank.sv-hosted.log
a7b19367871da10e0496c62df8097da20c7245b410e94ce39245b7ea422ffc9e  release/kernels/srd.by_instr.json.gz
65fd7e91f9f8ec1e2fd80309fda76af1c90c9d8e3db3c50283ab45d9efb58d02  release/kernels/srd.by_unit.json.gz
369a7ac6ca2cac89fdb22b1fd41e570bf73c41f665e14a6f301c395d78c1a4d6  release/kernels/srd.ccvtrace
13c265707266560522348ec1f354a67170be06a065f067aaecc8aa9cd40db9a4  release/kernels/srd.log
b08eb5e3673cac7eebb8b72af5ed3783c8e70a9e96592e76bf3722551bc79473  release/kernels/srd.oracle.jsonl
75d320f2b5244f7f2120c907527062a1c1eec8d0d88f5bea23ea1d126a4f034f  release/kernels/srd.sv-hosted.log
0008d6fce1b857eb7a301b6ae8b3ac1adb1824c0c769c8d1f09d8df9e329aa5f  release/kernels/stall.by_instr.json.gz
3cbe13ba0db630e4cccd61aa55c09ba10f13106d67746567b5fa32d8b8971dcd  release/kernels/stall.by_unit.json.gz
2e93fe0f28b44df41319cb9df58eb2361839b71647a7c5f7e62d6db2804d6e89  release/kernels/stall.ccvtrace
9b252e8fd5ccd491b62b10a532858a55d20d1431193d850365dcb7c6e52bdf6f  release/kernels/stall.log
500db2c482b07a0706583422cd68878301d0146c1f872ccc1f11bfdcf5c993ef  release/kernels/stall.oracle.jsonl
419cd18e168d21de986aed6c432dfdc2310b51b97d0d4a162e3e94ad2dee207f  release/kernels/stall.sv-hosted.log
63b2ece607c8939b5069426cedcb39167a46ba7ee1abde2347d4a5f1944d6398  release/kernels/swap.by_instr.json.gz
4050426f298d382ba1491eb007d0afc684b503374c386d79bbfd8f199d77ffcd  release/kernels/swap.by_unit.json.gz
4f99621184f8e20f1ce293a7892bc7e85a0cf2fc52318f71c011e665e4917ccd  release/kernels/swap.ccvtrace
9eec949efacf2118a437caf774b7cc971af0a4a280595eafed7ad83f3a1e42a0  release/kernels/swap.log
3658a26316c1ff7bc1744304a42f736e930fcde2865c8913e6cc67a22ce96667  release/kernels/swap.oracle.jsonl
057d941cff21c8cb423180bca60bafdd226fcc72110921682486f28c00222c42  release/kernels/swap.sv-hosted.log
f0c33a400b27087bd2209c507e1e1c919ca7a9c00dcd0e6e4e93a90b88c69a5a  release/kernels/transp4.by_instr.json.gz
1a29ae8a86e036559612ac97fd2dfc1b513e180e08e906b72495118d4bf38c2c  release/kernels/transp4.by_unit.json.gz
2ee16eb17dead12146378f4ccadb227ea4487e321af9ef1410b690fb45f7126a  release/kernels/transp4.ccvtrace
6c318609a02200da159ac5dfd8b43ac7ac2dd6c7a95a00814543e7c280190b56  release/kernels/transp4.log
06396ace3ac19677fd39c700e408606e5bdbacb24997d663bbe8872e63dd74fc  release/kernels/transp4.oracle.jsonl
3c460a17f6a74d86e80e40f073b85c341768315e85d4043327b3b7628eaad595  release/kernels/transp4.sv-hosted.log
305b66d0e533e8cd03a16e2df17ebcdc40ccad703c1b259fd22d0eb72507ed6a  release/kernels/unal.by_instr.json.gz
dc7de922c3324ad2b75972f2344f3783cef065169ba0c92f700dc697fd197702  release/kernels/unal.by_unit.json.gz
ba611dde8556689a403a4509b9c9ff897d38b9c173cf4bd4ac01d10fb19b8b64  release/kernels/unal.ccvtrace
0b1b4073a52e2a7ce0fd7582ecbc857e3ecdff63ec9f3cbbc51f091582590b96  release/kernels/unal.log
c3d484bb160657a563df983d9a2532eac27f556636617960aa1e72183ac2b299  release/kernels/unal.oracle.jsonl
f8e3eca106574ff3884ac2034c25350548cfb0a771cad6e7f6841079ef655835  release/kernels/unal.sv-hosted.log
377ea49884ed895b5e78788a61b048bd7575974f2420644da01a893a92238ec9  release/kernels/vadd.by_instr.json.gz
edebecab1eddcd394b07ff2779b5f688436ebcff048422ffbd0d62d7f693b93f  release/kernels/vadd.by_unit.json.gz
1da80e2eae0492a2823f171859a32d0ecd84580f6801dd19a18ff90154de5644  release/kernels/vadd.ccvtrace
b13f24a3c7a6d4cc4b62889b6a85e56df3a75c62b0b366cc0e27c355ee29335d  release/kernels/vadd.log
0276b6d0611a4bbcdc004ab3987214aea138245bc7217504147331689a9c0880  release/kernels/vadd.oracle.jsonl
6303beced6269086420c43638c5e70c42f207d591dac9bd3962342c1677dfb26  release/kernels/vadd.sv-hosted.log
aa2379a530e4e590655d454c2495eff992bbad3ec2561e782a32c94cfec3cdbd  release/kernels/vadd4.by_instr.json.gz
32bcded0c7d99df783b404d06ea7250c26cd42650dff60b316f1b6ef0ae80c1e  release/kernels/vadd4.by_unit.json.gz
711475dc3c022d70e146adec377d74442c56a0dbbec408fb3361bf548cf7c47a  release/kernels/vadd4.ccvtrace
c68d648afa47ec6c6dff3e93c24e2556fe63e048accdee5ddba730d083d20476  release/kernels/vadd4.log
225aa18fc9f38aa9ad615aa11de254337d59fa705877553d873062c68366e0db  release/kernels/vadd4.oracle.jsonl
0f05ca26836b7635a4959a2782b950c50ecbdf348cc1bce4c85b6041fc356f47  release/kernels/vadd4.sv-hosted.log
75b072e1a5b18d3fbeff5fd85d7a601730e7fd79bc5616be9cfa0ead37ceaea6  release/kernels/vadd6.by_instr.json.gz
e62d58323f406aec520fb68d8f73c38e7c128fb83966323d0508bb28492d4ce0  release/kernels/vadd6.by_unit.json.gz
a367c4f27d1fe8a2fdb0b104749d4368d1acdbbf0b87fcaf106f711a7ff1672d  release/kernels/vadd6.ccvtrace
296722180e7760def2bd9f22f481138bdeeb7f4c2cc5003311708cdc10eb0ae7  release/kernels/vadd6.log
10335385a8b6359c5e8310565561a4a5febfe318ef4ea0a6e537be2d372c54f4  release/kernels/vadd6.oracle.jsonl
ac23bf48d4304b36de401a5109b061c9932c5d4787864f96878f9a43c5d1b2b4  release/kernels/vadd6.sv-hosted.log
850a5cba717b4c07f2bbd2ff24eedde6feabc38e7573c0a12a1faacd4478ad73  release/kernels/vaddslow.by_instr.json.gz
a00b055ff8cdc996e9d92ee44117da52a4f533b44f292ddb646710d3b99f8fcc  release/kernels/vaddslow.by_unit.json.gz
1d25b61a639423d3208303a38fa45cce6c4bf5b44ee8e0061c5e0837696362e4  release/kernels/vaddslow.ccvtrace
ef3d9b3096f853f04af2d16f3bd637056af3d9227058eca6732a40857e380a78  release/kernels/vaddslow.log
e9e6218e8b8450e9f9ff6b39d659c994a1e51c527a0c5bd10d18b5658ae0e344  release/kernels/vaddslow.oracle.jsonl
74508b159f0b0bc0fca9bd72a84f6f275946ee466cdd3409ac9eb6d00189d315  release/kernels/vaddslow.sv-hosted.log
540f0f949d4f789920fefd4b93522973995d2a92e30c7a532c3e3d8a2b045cf9  release/kernels/waypred.by_instr.json.gz
715436c8a698f6dcf5be8dbf4e6649fc754513ca37f94c8774a67b8e41ad0e38  release/kernels/waypred.by_unit.json.gz
9c99928fe20da842a9d703185b3c074bd001b51026f8b108b537b557c0dff703  release/kernels/waypred.ccvtrace
567d8f15b8cf30875e5e48c4e2238fdca83e2d720d5bd7e8f6f8bcbda3567f44  release/kernels/waypred.log
54fb803ce85c4458b8687bb0f61adc32a9d798448b914b06261dc49c2bb841c8  release/kernels/waypred.oracle.jsonl
e9be7832c32e05bf012b67211b00099d22a0b64cb336d216c0fffe6ad43eed03  release/kernels/waypred.sv-hosted.log
912380814287161bac7e4f7385cfe0b09f42609160435f1d2df6fa2614f08c5e  release/verify.log
f78197fa73514d4391564b6dbfda61c3c03a38e2134c9ddc2d24180f29c72e6c  release/wiring.txt
```
