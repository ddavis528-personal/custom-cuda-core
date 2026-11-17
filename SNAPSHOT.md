# Snapshot snapshot-2026-11-17-f6e40f9

**A generated, read-only snapshot. Do not edit or merge it.** The source
is `ccr-9eb50716-lecnjf` at `f6e40f9af9c56890e2a153ed0fd2964fe69fc35a`, and this branch is rebuilt from source by
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
| Source | `ccr-9eb50716-lecnjf` @ `f6e40f9af9c56890e2a153ed0fd2964fe69fc35a` |
| Built | 2026-11-17 (UTC) |
| Gate | `tools/verify.sh`: PASS |
| Compiler snapshot | custom-cuda-complier `release` @ `a9241c22aee7ddb328c446b1467d71d7acc82033` (source `807056d4935cf7737caa0a89847d6bede6877e8d`) |
| Verilator | Verilator 5.052 2026-09-05 rev v5.052 |
| Icarus | Icarus Verilog version 12.0 (stable) () |
| Yosys | Yosys 0.33 (git sha1 2584903a060) |

## Kernels

| Kernel | Result |
|---|---|
| `addrhigh` | `name=addrhigh finished=1 cycles=83 from_fetch=52 retired=5 issue_groups=6 order=ok gpr_mismatch=0 pred_mismatch=0 mem_mismatch=0 check_failures=0 class_violations=0 overflows=0 credit_leaks=0 cor_late=0 channels_used=26/55 violations=0` |
| `addrlimit` | `name=addrlimit finished=1 cycles=1072 from_fetch=1041 retired=5 issue_groups=5 order=ok gpr_mismatch=0 pred_mismatch=0 mem_mismatch=0 check_failures=0 class_violations=0 overflows=0 credit_leaks=0 cor_late=0 channels_used=27/55 violations=0` |
| `addrneg` | `name=addrneg finished=1 cycles=79 from_fetch=48 retired=1 issue_groups=2 order=ok gpr_mismatch=0 pred_mismatch=0 mem_mismatch=0 check_failures=0 class_violations=0 overflows=0 credit_leaks=0 cor_late=0 channels_used=23/55 violations=0` |
| `atom` | `name=atom finished=1 cycles=7843 from_fetch=7812 retired=29 issue_groups=29 order=ok gpr_mismatch=0 pred_mismatch=0 mem_mismatch=0 check_failures=0 class_violations=0 overflows=0 credit_leaks=0 cor_late=0 channels_used=32/55 violations=0` |
| `atomf` | `name=atomf finished=1 cycles=4423 from_fetch=4392 retired=12 issue_groups=12 order=ok gpr_mismatch=0 pred_mismatch=0 mem_mismatch=0 check_failures=0 class_violations=0 overflows=0 credit_leaks=0 cor_late=0 channels_used=34/55 violations=0` |
| `borrow` | `name=borrow finished=1 cycles=99 from_fetch=68 retired=7 issue_groups=7 order=ok gpr_mismatch=0 pred_mismatch=0 mem_mismatch=0 check_failures=0 class_violations=0 overflows=0 credit_leaks=0 cor_late=0 channels_used=21/55 violations=0` |
| `brs` | `name=brs finished=1 cycles=99 from_fetch=68 retired=12 issue_groups=12 order=ok gpr_mismatch=0 pred_mismatch=0 mem_mismatch=0 check_failures=0 class_violations=0 overflows=0 credit_leaks=0 cor_late=0 channels_used=23/55 violations=0` |
| `byp` | `name=byp finished=1 cycles=118 from_fetch=87 retired=14 issue_groups=14 order=ok gpr_mismatch=0 pred_mismatch=0 mem_mismatch=0 check_failures=0 class_violations=0 overflows=0 credit_leaks=0 cor_late=0 channels_used=31/55 violations=0` |
| `callret` | `name=callret finished=1 cycles=265 from_fetch=234 retired=40 issue_groups=40 order=ok gpr_mismatch=0 pred_mismatch=0 mem_mismatch=0 check_failures=0 class_violations=0 overflows=0 credit_leaks=0 cor_late=0 channels_used=30/55 violations=0` |
| `cas` | `name=cas finished=1 cycles=6524 from_fetch=6493 retired=56 issue_groups=56 order=ok gpr_mismatch=0 pred_mismatch=0 mem_mismatch=0 check_failures=0 class_violations=0 overflows=0 credit_leaks=0 cor_late=0 channels_used=32/55 violations=0` |
| `chains` | `name=chains finished=1 cycles=96 from_fetch=65 retired=29 issue_groups=29 order=ok gpr_mismatch=0 pred_mismatch=0 mem_mismatch=0 check_failures=0 class_violations=0 overflows=0 credit_leaks=0 cor_late=0 channels_used=21/55 violations=0` |
| `coll` | `name=coll finished=1 cycles=78 from_fetch=47 retired=24 issue_groups=24 order=ok gpr_mismatch=0 pred_mismatch=0 mem_mismatch=0 check_failures=0 class_violations=0 overflows=0 credit_leaks=0 cor_late=0 channels_used=21/55 violations=0` |
| `div` | `name=div finished=1 cycles=978 from_fetch=947 retired=144 issue_groups=144 order=ok gpr_mismatch=0 pred_mismatch=0 mem_mismatch=0 check_failures=0 class_violations=0 overflows=0 credit_leaks=0 cor_late=0 channels_used=23/55 violations=0` |
| `divchw` | `name=divchw finished=1 cycles=111 from_fetch=80 retired=5 issue_groups=6 order=ok gpr_mismatch=0 pred_mismatch=0 mem_mismatch=0 check_failures=0 class_violations=0 overflows=0 credit_leaks=0 cor_late=0 channels_used=22/55 violations=0` |
| `divtail` | `name=divtail finished=1 cycles=642 from_fetch=611 retired=96 issue_groups=96 order=ok gpr_mismatch=0 pred_mismatch=0 mem_mismatch=0 check_failures=0 class_violations=0 overflows=0 credit_leaks=0 cor_late=0 channels_used=23/55 violations=0` |
| `divtail2` | `name=divtail2 finished=1 cycles=1517 from_fetch=1486 retired=366 issue_groups=366 order=ok gpr_mismatch=0 pred_mismatch=0 mem_mismatch=0 check_failures=0 class_violations=0 overflows=0 credit_leaks=0 cor_late=0 channels_used=23/55 violations=0` |
| `fence` | `name=fence finished=1 cycles=83 from_fetch=52 retired=7 issue_groups=7 order=ok gpr_mismatch=0 pred_mismatch=0 mem_mismatch=0 check_failures=0 class_violations=0 overflows=0 credit_leaks=0 cor_late=0 channels_used=30/55 violations=0` |
| `gather` | `name=gather finished=1 cycles=265 from_fetch=234 retired=16 issue_groups=16 order=ok gpr_mismatch=0 pred_mismatch=0 mem_mismatch=0 check_failures=0 class_violations=0 overflows=0 credit_leaks=0 cor_late=0 channels_used=32/55 violations=0` |
| `hit` | `name=hit finished=1 cycles=212 from_fetch=181 retired=17 issue_groups=17 order=ok gpr_mismatch=0 pred_mismatch=0 mem_mismatch=0 check_failures=0 class_violations=0 overflows=0 credit_leaks=0 cor_late=0 channels_used=31/55 violations=0` |
| `lanectx` | `name=lanectx finished=1 cycles=70 from_fetch=39 retired=10 issue_groups=10 order=ok gpr_mismatch=0 pred_mismatch=0 mem_mismatch=0 check_failures=0 class_violations=0 overflows=0 credit_leaks=0 cor_late=0 channels_used=29/55 violations=0` |
| `lanectx2` | `name=lanectx2 finished=1 cycles=70 from_fetch=39 retired=10 issue_groups=10 order=ok gpr_mismatch=0 pred_mismatch=0 mem_mismatch=0 check_failures=0 class_violations=0 overflows=0 credit_leaks=0 cor_late=0 channels_used=29/55 violations=0` |
| `late` | `name=late finished=1 cycles=168 from_fetch=137 retired=16 issue_groups=16 order=ok gpr_mismatch=0 pred_mismatch=0 mem_mismatch=0 check_failures=0 class_violations=0 overflows=0 credit_leaks=0 cor_late=0 channels_used=31/55 violations=0` |
| `ldpar` | `name=ldpar finished=1 cycles=154 from_fetch=123 retired=17 issue_groups=17 order=ok gpr_mismatch=0 pred_mismatch=0 mem_mismatch=0 check_failures=0 class_violations=0 overflows=0 credit_leaks=0 cor_late=0 channels_used=31/55 violations=0` |
| `lnorm1` | `name=lnorm1 finished=1 cycles=2516 from_fetch=2485 retired=526 issue_groups=526 order=ok gpr_mismatch=0 pred_mismatch=0 mem_mismatch=0 check_failures=0 class_violations=0 overflows=0 credit_leaks=0 cor_late=0 channels_used=37/55 violations=0` |
| `localsp` | `name=localsp finished=1 cycles=2175 from_fetch=2144 retired=40 issue_groups=40 order=ok gpr_mismatch=0 pred_mismatch=0 mem_mismatch=0 check_failures=0 class_violations=0 overflows=0 credit_leaks=0 cor_late=0 channels_used=31/55 violations=0` |
| `loop` | `name=loop finished=1 cycles=2842 from_fetch=2811 retired=407 issue_groups=407 order=ok gpr_mismatch=0 pred_mismatch=0 mem_mismatch=0 check_failures=0 class_violations=0 overflows=0 credit_leaks=0 cor_late=0 channels_used=23/55 violations=0` |
| `merge` | `name=merge finished=1 cycles=71 from_fetch=40 retired=9 issue_groups=9 order=ok gpr_mismatch=0 pred_mismatch=0 mem_mismatch=0 check_failures=0 class_violations=0 overflows=0 credit_leaks=0 cor_late=0 channels_used=21/55 violations=0` |
| `missrun` | `name=missrun finished=1 cycles=121 from_fetch=90 retired=28 issue_groups=28 order=ok gpr_mismatch=0 pred_mismatch=0 mem_mismatch=0 check_failures=0 class_violations=0 overflows=0 credit_leaks=0 cor_late=0 channels_used=31/55 violations=0` |
| `mload` | `name=mload finished=1 cycles=111 from_fetch=80 retired=11 issue_groups=11 order=ok gpr_mismatch=0 pred_mismatch=0 mem_mismatch=0 check_failures=0 class_violations=0 overflows=0 credit_leaks=0 cor_late=0 channels_used=31/55 violations=0` |
| `mlp` | `name=mlp finished=1 cycles=126 from_fetch=95 retired=21 issue_groups=21 order=ok gpr_mismatch=0 pred_mismatch=0 mem_mismatch=0 check_failures=0 class_violations=0 overflows=0 credit_leaks=0 cor_late=0 channels_used=31/55 violations=0` |
| `mwmiss` | `name=mwmiss finished=1 cycles=129 from_fetch=98 retired=88 issue_groups=88 order=ok gpr_mismatch=0 pred_mismatch=0 mem_mismatch=0 check_failures=0 class_violations=0 overflows=0 credit_leaks=0 cor_late=0 channels_used=31/55 violations=0` |
| `narrowadd` | `name=narrowadd finished=1 cycles=226 from_fetch=195 retired=21 issue_groups=21 order=ok gpr_mismatch=0 pred_mismatch=0 mem_mismatch=0 check_failures=0 class_violations=0 overflows=0 credit_leaks=0 cor_late=0 channels_used=32/55 violations=0` |
| `pguard` | `name=pguard finished=1 cycles=87 from_fetch=56 retired=12 issue_groups=12 order=ok gpr_mismatch=0 pred_mismatch=0 mem_mismatch=0 check_failures=0 class_violations=0 overflows=0 credit_leaks=0 cor_late=0 channels_used=29/55 violations=0` |
| `plog` | `name=plog finished=1 cycles=71 from_fetch=40 retired=11 issue_groups=11 order=ok gpr_mismatch=0 pred_mismatch=0 mem_mismatch=0 check_failures=0 class_violations=0 overflows=0 credit_leaks=0 cor_late=0 channels_used=21/55 violations=0` |
| `pmovdiv` | `name=pmovdiv finished=1 cycles=104 from_fetch=73 retired=12 issue_groups=12 order=ok gpr_mismatch=0 pred_mismatch=0 mem_mismatch=0 check_failures=0 class_violations=0 overflows=0 credit_leaks=0 cor_late=0 channels_used=22/55 violations=0` |
| `predlane` | `name=predlane finished=1 cycles=928 from_fetch=897 retired=10 issue_groups=10 order=ok gpr_mismatch=0 pred_mismatch=0 mem_mismatch=0 check_failures=0 class_violations=0 overflows=0 credit_leaks=0 cor_late=0 channels_used=31/55 violations=0` |
| `predmerge` | `name=predmerge finished=1 cycles=940 from_fetch=909 retired=9 issue_groups=9 order=ok gpr_mismatch=0 pred_mismatch=0 mem_mismatch=0 check_failures=0 class_violations=0 overflows=0 credit_leaks=0 cor_late=0 channels_used=33/55 violations=0` |
| `predspill` | `name=predspill finished=1 cycles=968 from_fetch=937 retired=12 issue_groups=12 order=ok gpr_mismatch=0 pred_mismatch=0 mem_mismatch=0 check_failures=0 class_violations=0 overflows=0 credit_leaks=0 cor_late=0 channels_used=31/55 violations=0` |
| `predswap` | `name=predswap finished=1 cycles=1186 from_fetch=1155 retired=46 issue_groups=46 order=ok gpr_mismatch=0 pred_mismatch=0 mem_mismatch=0 check_failures=0 class_violations=0 overflows=0 credit_leaks=0 cor_late=0 channels_used=33/55 violations=0` |
| `privwin` | `name=privwin finished=1 cycles=1161 from_fetch=1130 retired=52 issue_groups=52 order=ok gpr_mismatch=0 pred_mismatch=0 mem_mismatch=0 check_failures=0 class_violations=0 overflows=0 credit_leaks=0 cor_late=0 channels_used=34/55 violations=0` |
| `provswap` | `name=provswap finished=1 cycles=2285 from_fetch=2254 retired=978 issue_groups=978 order=ok gpr_mismatch=0 pred_mismatch=0 mem_mismatch=0 check_failures=0 class_violations=0 overflows=0 credit_leaks=0 cor_late=0 channels_used=33/55 violations=0` |
| `retmiss` | `name=retmiss finished=1 cycles=184 from_fetch=153 retired=19 issue_groups=19 order=ok gpr_mismatch=0 pred_mismatch=0 mem_mismatch=0 check_failures=0 class_violations=0 overflows=0 credit_leaks=0 cor_late=0 channels_used=33/55 violations=0` |
| `roconst` | `name=roconst finished=1 cycles=76 from_fetch=45 retired=4 issue_groups=5 order=ok gpr_mismatch=0 pred_mismatch=0 mem_mismatch=0 check_failures=0 class_violations=0 overflows=0 credit_leaks=0 cor_late=0 channels_used=26/55 violations=0` |
| `rogated` | `name=rogated finished=1 cycles=96 from_fetch=65 retired=7 issue_groups=8 order=ok gpr_mismatch=0 pred_mismatch=0 mem_mismatch=0 check_failures=0 class_violations=0 overflows=0 credit_leaks=0 cor_late=0 channels_used=26/55 violations=0` |
| `rokill` | `name=rokill finished=1 cycles=104 from_fetch=73 retired=41 issue_groups=4536 order=ok gpr_mismatch=0 pred_mismatch=0 mem_mismatch=0 check_failures=0 class_violations=0 overflows=0 credit_leaks=0 cor_late=0 channels_used=27/55 violations=0` |
| `rokilllane` | `name=rokilllane finished=1 cycles=1214 from_fetch=1183 retired=924 issue_groups=10674 order=ok gpr_mismatch=0 pred_mismatch=0 mem_mismatch=0 check_failures=0 class_violations=0 overflows=0 credit_leaks=0 cor_late=0 channels_used=27/55 violations=0` |
| `rolaunch` | `name=rolaunch finished=1 cycles=74 from_fetch=43 retired=4 issue_groups=5 order=ok gpr_mismatch=0 pred_mismatch=0 mem_mismatch=0 check_failures=0 class_violations=0 overflows=0 credit_leaks=0 cor_late=0 channels_used=24/55 violations=0` |
| `rolimit` | `name=rolimit finished=1 cycles=76 from_fetch=45 retired=4 issue_groups=5 order=ok gpr_mismatch=0 pred_mismatch=0 mem_mismatch=0 check_failures=0 class_violations=0 overflows=0 credit_leaks=0 cor_late=0 channels_used=26/55 violations=0` |
| `roload` | `name=roload finished=1 cycles=105 from_fetch=74 retired=8 issue_groups=8 order=ok gpr_mismatch=0 pred_mismatch=0 mem_mismatch=0 check_failures=0 class_violations=0 overflows=0 credit_leaks=0 cor_late=0 channels_used=31/55 violations=0` |
| `rope` | `name=rope finished=1 cycles=670 from_fetch=639 retired=354 issue_groups=354 order=ok gpr_mismatch=0 pred_mismatch=0 mem_mismatch=0 check_failures=0 class_violations=0 overflows=0 credit_leaks=0 cor_late=0 channels_used=34/55 violations=0` |
| `ropediv` | `name=ropediv finished=1 cycles=960 from_fetch=929 retired=203 issue_groups=203 order=ok gpr_mismatch=0 pred_mismatch=0 mem_mismatch=0 check_failures=0 class_violations=0 overflows=0 credit_leaks=0 cor_late=0 channels_used=34/55 violations=0` |
| `sel` | `name=sel finished=1 cycles=77 from_fetch=46 retired=8 issue_groups=8 order=ok gpr_mismatch=0 pred_mismatch=0 mem_mismatch=0 check_failures=0 class_violations=0 overflows=0 credit_leaks=0 cor_late=0 channels_used=29/55 violations=0` |
| `sized` | `name=sized finished=1 cycles=984 from_fetch=953 retired=25 issue_groups=25 order=ok gpr_mismatch=0 pred_mismatch=0 mem_mismatch=0 check_failures=0 class_violations=0 overflows=0 credit_leaks=0 cor_late=0 channels_used=32/55 violations=0` |
| `slotform` | `name=slotform finished=1 cycles=4350 from_fetch=4319 retired=12 issue_groups=12 order=ok gpr_mismatch=0 pred_mismatch=0 mem_mismatch=0 check_failures=0 class_violations=0 overflows=0 credit_leaks=0 cor_late=0 channels_used=32/55 violations=0` |
| `spinwait` | `name=spinwait finished=1 cycles=1976 from_fetch=1945 retired=211 issue_groups=211 order=ok gpr_mismatch=0 pred_mismatch=0 mem_mismatch=0 check_failures=0 class_violations=0 overflows=0 credit_leaks=0 cor_late=0 channels_used=34/55 violations=0` |
| `spmbank` | `name=spmbank finished=1 cycles=186 from_fetch=155 retired=13 issue_groups=13 order=ok gpr_mismatch=0 pred_mismatch=0 mem_mismatch=0 check_failures=0 class_violations=0 overflows=0 credit_leaks=0 cor_late=0 channels_used=28/55 violations=0` |
| `srd` | `name=srd finished=1 cycles=70 from_fetch=39 retired=6 issue_groups=6 order=ok gpr_mismatch=0 pred_mismatch=0 mem_mismatch=0 check_failures=0 class_violations=0 overflows=0 credit_leaks=0 cor_late=0 channels_used=29/55 violations=0` |
| `stall` | `name=stall finished=1 cycles=556 from_fetch=525 retired=116 issue_groups=116 order=ok gpr_mismatch=0 pred_mismatch=0 mem_mismatch=0 check_failures=0 class_violations=0 overflows=0 credit_leaks=0 cor_late=0 channels_used=31/55 violations=0` |
| `swap` | `name=swap finished=1 cycles=556 from_fetch=525 retired=174 issue_groups=174 order=ok gpr_mismatch=0 pred_mismatch=0 mem_mismatch=0 check_failures=0 class_violations=0 overflows=0 credit_leaks=0 cor_late=0 channels_used=31/55 violations=0` |
| `transp4` | `name=transp4 finished=1 cycles=1116 from_fetch=1085 retired=976 issue_groups=976 order=ok gpr_mismatch=0 pred_mismatch=0 mem_mismatch=0 check_failures=0 class_violations=0 overflows=0 credit_leaks=0 cor_late=0 channels_used=37/55 violations=0` |
| `unal` | `name=unal finished=1 cycles=137 from_fetch=106 retired=9 issue_groups=9 order=ok gpr_mismatch=0 pred_mismatch=0 mem_mismatch=0 check_failures=0 class_violations=0 overflows=0 credit_leaks=0 cor_late=0 channels_used=32/55 violations=0` |
| `vadd` | `name=vadd finished=1 cycles=158 from_fetch=127 retired=17 issue_groups=17 order=ok gpr_mismatch=0 pred_mismatch=0 mem_mismatch=0 check_failures=0 class_violations=0 overflows=0 credit_leaks=0 cor_late=0 channels_used=33/55 violations=0` |
| `vadd4` | `name=vadd4 finished=1 cycles=204 from_fetch=173 retired=68 issue_groups=68 order=ok gpr_mismatch=0 pred_mismatch=0 mem_mismatch=0 check_failures=0 class_violations=0 overflows=0 credit_leaks=0 cor_late=0 channels_used=33/55 violations=0` |
| `vaddslow` | `name=vaddslow finished=1 cycles=547 from_fetch=516 retired=17 issue_groups=17 order=ok gpr_mismatch=0 pred_mismatch=0 mem_mismatch=0 check_failures=0 class_violations=0 overflows=0 credit_leaks=0 cor_late=0 channels_used=33/55 violations=0` |

## Manifest of release/

```
91394927823ed77c4f76ff8aae5a7ca5969f10a7f971ce7eef5194142f3fce8c  release/kernels/addrhigh.by_instr.json.gz
69d4b251eaa0fb95dffb939e6d9c4529624803569ac517a57101d07f2242272e  release/kernels/addrhigh.by_unit.json.gz
7f4025bfdc4a9e67d17c349cc2031239027d3a614a0080c15e41212d388f6c80  release/kernels/addrhigh.ccvtrace
d188a13da323dee296f6ad49abd1a00b75ea59792469e9b1428c440acd27f4f1  release/kernels/addrhigh.log
569f2e22883fad5f0956c57ec734e6afbdd4b8a854e50277425172d6c0cbd766  release/kernels/addrhigh.oracle.jsonl
e9be15e1276c36f93fb0fd4154f0fad5a615f8c6b1464a4be46c5e76f2543125  release/kernels/addrhigh.sv-hosted.log
fdf05a21b8e2f633bf1762387759f685dffafe71b32f0dfe4b60ace1d1647053  release/kernels/addrlimit.by_instr.json
939d6b115a1bc45b8e75c394811a9aa84b1fb504faed4cc318d2f53cd6131e43  release/kernels/addrlimit.by_unit.json
f8287904c415dfd8f4cf0ec4a8dcdb95ef81669e365fea28a62d9f2feaa3ac8f  release/kernels/addrlimit.ccvtrace
2601caaea99b2bf4f608c2b9d2317603315571028937a17cc4314f545672835f  release/kernels/addrlimit.log
bc660b0b40359a2c5a2478cb0eb4950b73fd22db50ea76b80052bc195a1920f4  release/kernels/addrlimit.oracle.jsonl
bb2ce1a90dd8ebb5893bf8a6c6b3a47d749e9839b8de60fc71f95105e4b40167  release/kernels/addrlimit.sv-hosted.log
e7abe7817b399a7c2517f35ab48166e57586a5f46b99d90f11550210332bc0fd  release/kernels/addrneg.by_instr.json
55ad70974dc8a9ea0533a37b55ae47f2ab3280b5eeb9e4f5f56b2a2d355031f6  release/kernels/addrneg.by_unit.json
34b171591ba4b885fa0d843ce2817d49eb6638f478e426eb5b2947e4aabce7cc  release/kernels/addrneg.ccvtrace
cb07e7d61ff57a65eee26593ad82530df254e308192a2dc53bd7334a267f9047  release/kernels/addrneg.log
16f5b0707ae44492a1efd67bb9dd38a7e79a7bbd354fa9207b9e7d150ff2f107  release/kernels/addrneg.oracle.jsonl
caa3d8249b24bc2d65ee5b922031ca57b189dafa6475482ba4e863f36144a1c1  release/kernels/addrneg.sv-hosted.log
d7450c9cdb94725fa4a4fcd95b756abda42ac16ec8a7a26f1995c025bbaecfe6  release/kernels/atom.by_instr.json.gz
cc72636c5715f4ff8762b3d3ad5188e09c9b7ae1a9e79f809ec6cd406d0f5130  release/kernels/atom.by_unit.json.gz
51878459999e6a8143a9c939d03f13cffb2bcc3133bb489ea2a99a6e129ae17a  release/kernels/atom.ccvtrace
99a8ac1abe46096f4ba29d3230893df3a57804ca75f2b6cc9bab04561efaaae8  release/kernels/atom.log
504f5b6e9d25114dc35f2c70b21bb7b3f3c508c691de12dc0e87d12a74285361  release/kernels/atom.oracle.jsonl
e94cf1724e7679d5a7c5a1c0c62ba95e9d6d47d2b57f32a451eca5194e829cec  release/kernels/atom.sv-hosted.log
391474373b8e056cb2c7cdf350aca22b9b87101d76ee6550c3ea3ffba9c96e86  release/kernels/atomf.by_instr.json.gz
5e3914e52f773f1c9325901fac8d966e0ac07b868a1ee81300a1ba492f89c877  release/kernels/atomf.by_unit.json.gz
c92618b4ca499739a0e52243245224f7df3dc31ccd8e86a8504d3bde9c6b280d  release/kernels/atomf.ccvtrace
a73a92943f9c5795127a3c0b5c1903ed4e59fa8c4a5bcb79209c81a3476fbc9c  release/kernels/atomf.log
cfd1179edf4061a33ab2f75d7a6dec61decfe629000198189a7bfc2647b34238  release/kernels/atomf.oracle.jsonl
fe51b2cc69fb360b7060f596ecea66215d9291566cf8012e3cfd204b906c8084  release/kernels/atomf.sv-hosted.log
3139a30ea9c637238408b3c2d69749839d7dcc86f4cb96e58f3bfa04a9c613cd  release/kernels/borrow.by_instr.json.gz
61b87c4c37d9b1f4c1c528caab5156e14c713b2bdd11efb9b07e58e1b1f70002  release/kernels/borrow.by_unit.json.gz
f47ba0ff76f39020aec6e50deb887c83af18cb9efde597aa3d2ebc7261eb3139  release/kernels/borrow.ccvtrace
c3d024f391d0e65117fcedb685bccadc5401855d7721ab046a343ab09a9d4bb1  release/kernels/borrow.log
4c565e1ce0b3baee36e158694b32c8defb5cd662b2f9af75cb5d8c26cb1168ed  release/kernels/borrow.oracle.jsonl
7f3d75701d29f0e35d0b42e62f264abc37ff424a262c0ac60dbe4804eff8d9e4  release/kernels/borrow.sv-hosted.log
577dc4ff52f5f4423650f8a3678d3ee2b33efc1eab6ae06ab60f27825ae5c825  release/kernels/brs.by_instr.json.gz
44b12351729d327abe323f0d3767144d9ecf7a38bdce572dfa808bf08b6e7173  release/kernels/brs.by_unit.json.gz
0efbd34762b9bb839d84507973259b9161e0b6b94498eb217ab8eb280dacf7b3  release/kernels/brs.ccvtrace
fde89de0803e0cd1d0ab0f335c4ab24e713bacd0314dcbb0795f27dbe07bbadc  release/kernels/brs.log
e3c1cb3379580cf1aae44e8ddc8e846ef6fd661a573cfe0a8d4444b18a14dc56  release/kernels/brs.oracle.jsonl
fa9beb228a6a88df36474c191ccdbbf5ebd4d6ae1d577a41567905c8e3eab67d  release/kernels/brs.sv-hosted.log
950718debd41194c3e16daac3879bf94ce8e82f0a631fc35203c74147676131d  release/kernels/byp.by_instr.json.gz
a62c0c2f6519cef68f94146cacf663d9f4b0b97bd563f022fbd3f8a624ffbf2c  release/kernels/byp.by_unit.json.gz
eeaeecbeffcfabb26607ba4cd6b679e552bee7dc964f95f3f62f7662d3bf9781  release/kernels/byp.ccvtrace
e24483d1f6045db4572b0878fe87b7301d5c3c3fbca3efb4d1d6f5ec82aff466  release/kernels/byp.log
5a03dfa4f3603fef49f1e3639e74e34152ca3ca5ef8e41eb959f8323040fa2d5  release/kernels/byp.oracle.jsonl
c461ac4e647dd3815cf93236dbe04893899eb4e3f6e9d04e33ab1b7335881d08  release/kernels/byp.sv-hosted.log
edfc7ae41b84f02da04ec51e919f398f3faf1cc472f5ae9049d88575c67f8415  release/kernels/callret.by_instr.json.gz
251e8b0fd31f22ec88a0283326ecc2cfb7da4b5039c652947e675c23b4a3ad36  release/kernels/callret.by_unit.json.gz
485f5f7c964b7718cdf5f6475c30219443e9a079bfcab6718359dd789900a2c6  release/kernels/callret.ccvtrace
547fc1318d0d1c4f7a1ac5e325c26da0bc202c8a8ad51e2685b4d94b423bcb64  release/kernels/callret.log
9b1d1b50b527f732362f837250aa2f26dabf3e76e16a4794856ebd8f105635b8  release/kernels/callret.oracle.jsonl
b8cf14de2c83e90e58bf73944e84aadcc14012348163711caee1a87e0cb56e7f  release/kernels/callret.sv-hosted.log
b64f02d3e3a0f47207b88ed80cee5245c5fb15aab08b42d2713ded9fd876e62c  release/kernels/cas.by_instr.json.gz
6579ea3fb6eddd79e0f4927558a565a1aad7202e2451c95223693ade71e73ef0  release/kernels/cas.by_unit.json.gz
19ca0d1b967f3d4b5ec6b979125ad1b2f5a3964472905a0b9e3b4204f3c646b1  release/kernels/cas.ccvtrace
9c315bdd9d4f8712096ab1f8f9dde645b5f4bd3ac3a9e1c45e15c0027d4b4124  release/kernels/cas.log
0ab31a9443336fe5d08e1a5fa5fcba3bc279b19022f7c5007908d39d8ef39536  release/kernels/cas.oracle.jsonl
dae95d2b6e2e16449facef0c5d80a29b3f9f6250d83443a79a4d91d3029e3a4c  release/kernels/cas.sv-hosted.log
e585b56be907ec2e8784bebf80c007a98e41dbeae6b5052d69dc0903d0c0f821  release/kernels/chains.by_instr.json.gz
6908540445cb07c9d731e3ebbaa3b176740ddeed8783e888bfc7f4b86928136a  release/kernels/chains.by_unit.json.gz
b47e10902de830c337bf591bfc2daf06098880741b67957d8e8dd9c45208dc56  release/kernels/chains.ccvtrace
8d3f3d205ff9d2f9ec4b1b9153332062b1ccc2e37048430fd6fb5465c8a6adb5  release/kernels/chains.log
26a4cc5c5524c7219d8706c2582c80357dea60be9d6ffdec99dac7d0365e2264  release/kernels/chains.oracle.jsonl
7c589db485f31ecbbe98f58f4035ca100983c3cdf19adb73b56806372c470b4f  release/kernels/chains.sv-hosted.log
d0c06e83d5e3ba909a5149ac664c595becf036a81a48d8d67cd65d87afb322d3  release/kernels/coll.by_instr.json.gz
ef1e0e03fc472c407fd545fb55bc176230bf5f74f025827c7d7a4d374807bf1b  release/kernels/coll.by_unit.json.gz
9b2defbca3a81f102a07f1fb1a9473253e58da6ab1e7375a8d81f4d1fe098bae  release/kernels/coll.ccvtrace
9a42fccf43093b9a678988d3c33fd7bade69270a538c61adff15a02b4b801fd9  release/kernels/coll.log
dd718d23c88df5dc7d92b055d8542865aa0e029118486af127312a8a578cfcbc  release/kernels/coll.oracle.jsonl
a37232ed6ed48d947ee0c8b76e6075d88ce521bede67022233ead1f92b7fc4a6  release/kernels/coll.sv-hosted.log
4b7cc9498085daf97882d89a6e4dd6d9cb870c9c6513c1c2330579a746996963  release/kernels/div.by_instr.json.gz
bc6b064a64cebaedab6d10f4a87b152c2de51e571f11a4011ad77a00e89b5c22  release/kernels/div.by_unit.json.gz
182346c5baad147767effbea67248ccbc6e5c35582f0590ab266ce10e6e9dbc8  release/kernels/div.ccvtrace
f96c31a039f22248349177f56cc28abde17125b635030abadd5726d01dbfadbb  release/kernels/div.log
71a567b85cf85622631490187563de9a5661099c78a590adff4ed0a0c3d24c16  release/kernels/div.oracle.jsonl
dc8125a501613938e127a216cd0a277652b94a785f4461a630f3d19606df4aec  release/kernels/div.sv-hosted.log
f058dfbb8dc9277d61ec313bd3f9ce6cff9cbc8eec0724c79a54b95a966865c1  release/kernels/divchw.by_instr.json.gz
7b9ebf20f361faa84f79c58561803992a8b293eb15fd6929d6adf72166635444  release/kernels/divchw.by_unit.json.gz
4471a48e9f9555ec3ff526316b30290fb0ff75d28588185a2a52382020681eb5  release/kernels/divchw.ccvtrace
e686e48b43b1625bb3f158f5a9ade85a9cd789adaaa348d446f1fa4007d99b8f  release/kernels/divchw.log
58a541797f7a2df0a1c7528ae6a3edec212db90c7d3eb20656806f38b5c10b3d  release/kernels/divchw.oracle.jsonl
6088a7afc2dd87483240dc60a120bfc0cc3ed049f07f0f71514416e44ee29d98  release/kernels/divchw.sv-hosted.log
aa8d6842e0b10fc8688c6990a762a298abdc56bf8b52c3ab1f60c5c655cc3b8e  release/kernels/divtail.by_instr.json.gz
7db628cde998b4d88209ba4796428c6628208c34d5c690af629454e9ef61bdc7  release/kernels/divtail.by_unit.json.gz
2ade202d8c5fc071687f18239b0573f55461d1606452ff6daa16db3738442f2c  release/kernels/divtail.ccvtrace
4a032dbea80b2e7c78314abe431fc8544595ea430d15f98e405f2117d747de44  release/kernels/divtail.log
75f11a75c9b3b336e446140af4579f05b46c363a76b7aab3ec88154a07ba097d  release/kernels/divtail.oracle.jsonl
7016545df805252b816a2d415b9b62ba23ad0419dd9fe219226d5c8919e9c33f  release/kernels/divtail.sv-hosted.log
8dae71f327623f6e23786bde6fc90ca6a84f8d8b8facd89d836b4582cd56d6f1  release/kernels/divtail2.by_instr.json.gz
3535039ca5412e4a4884d8b1f14733fb8a32ffb6fdd2b43d23fbd1662caefc6c  release/kernels/divtail2.by_unit.json.gz
e27413844716e2c50ee7f69833576c60a6fb7bc226660dfe365677c387affdcd  release/kernels/divtail2.ccvtrace
455cbb6be770850b69bd5b3ba1be7a2a27eedd5814c2e68a0b53ce98999e71ac  release/kernels/divtail2.log
b2db6b05eb6cf4a0a7677e31d0c6c2952d5cab49d353f0bb1883fe0b2a20ed14  release/kernels/divtail2.oracle.jsonl
b9dd23911e3f800f8650383f8dcc37d160818b736c113ad021403eea9773a9d2  release/kernels/divtail2.sv-hosted.log
f634c829dd69a6dadc8d0f5ce33f337f02a188fa6039340fa75021cf7e855510  release/kernels/fence.by_instr.json
d3ba775fe74272530ac90734a7bebc6e389677d0effc3b349904c0567d8e177c  release/kernels/fence.by_unit.json.gz
937d3193ab570b47d1b195b8243ed02ee198d22a5792ddebd2ade6682955a956  release/kernels/fence.ccvtrace
e6a3f2fb6ec5d8a6d3fd2e51dc88d561d5654beca1079c310bc31c50baeefc9c  release/kernels/fence.log
d1d40317f6cf5bfb430cda1f9c0ef676609e59cabe2a11623c42ffbeca93142b  release/kernels/fence.oracle.jsonl
f486df7b567fa108cc0ab1a9eb00719757218c2a60c2085e3832a82fc4539b60  release/kernels/fence.sv-hosted.log
8a8aa9a8edd1fe7cf87e3583380dabf661c3747f95b4c6008ff4a405ea861e7a  release/kernels/gather.by_instr.json.gz
be22b3a9abe6a0a873abe4662bd2be8b603841810c36f195d937ae7565a01105  release/kernels/gather.by_unit.json.gz
579bce9756a2a49ebd6423bf0c53491401251d7e21bde54947c3723f31ce67c5  release/kernels/gather.ccvtrace
5db99c84e45b0c4f67a4a937e9cf7487a2da1e3172fa76ca9945d9f29bd5d628  release/kernels/gather.log
0413e781d8d6ff578c64eb1f800b7931e66f676d5cdabb97b94a4033e6037662  release/kernels/gather.oracle.jsonl
19f6bda9af33c9461a4087b5d698bf87b9977ef23e70e24928bbe8eef5cb6760  release/kernels/gather.sv-hosted.log
c1518e96937b56f3662844ba0ac37112aa12dda016d1fc9ed801909bc39cf8eb  release/kernels/hit.by_instr.json.gz
925b7e3cc13f4101da0d9493ef48e45568cd3e449d86169c4a643493810e1183  release/kernels/hit.by_unit.json.gz
49e386589dfc6f8d5371bd908ca1002022ca80542b41ab51820ce7562e08e6dd  release/kernels/hit.ccvtrace
a83a1c8aa88a83d54109d036eab37920506a581a3404333f0d854e82c131ddf4  release/kernels/hit.log
7ba9603e0088d9164de6528f16ef6a7fa9ce5821c8c12b52cbb3734e39b9fd52  release/kernels/hit.oracle.jsonl
2b058daecdec0dbf991ce9fec0cb16468a04d3c690d13bf90325c26105bdc941  release/kernels/hit.sv-hosted.log
19493b0bb9f43296cd68ad0fbcbee2b72759062b4e13ac1006ce14b1d068b30d  release/kernels/lanectx.by_instr.json.gz
005cbe697fcb7ca5b62697352c07a12890009735a47cb0dabfe315ec5739a30e  release/kernels/lanectx.by_unit.json.gz
bfdf212b12cc609da0b786f23ac7a775a880d9c7078d0dc1cb4ea29899191bf0  release/kernels/lanectx.ccvtrace
63907d9716f545d7b7bc0388c2f570abb6a2b5983562fe99254f8382fb376d87  release/kernels/lanectx.log
888551babf540db8e3025b82e65ca655013f93eba3c8a65689d069d52a7e6039  release/kernels/lanectx.oracle.jsonl
66f7df6951ce2578de648334ea352348ff3c641eb6a4a383583e2046b813b323  release/kernels/lanectx.sv-hosted.log
13279f38689a7ef7f1b5dc2fe1e87ab410bac07972930c99b09e670387811ff1  release/kernels/lanectx2.by_instr.json.gz
bca1660c5c529366581e2d2a25e67a552885c964757045ab0a1be9dc3a76d3bc  release/kernels/lanectx2.by_unit.json.gz
d1c46c94b6b1d1fb2f239a45a58cc2a129820423a056374ffd66eda0640423d9  release/kernels/lanectx2.ccvtrace
2a50d44c3399be12b6677359d626a6601348f5b9863e5e102dcbf73a174016d2  release/kernels/lanectx2.log
45c13056dff5c73ed0c9ece56cc36f929bf335322193c7d5eb38710b1d1dfb02  release/kernels/lanectx2.oracle.jsonl
2d2ceaa7d5a6f1620c5c959e11f807ffca739e9ec14fd03dddde5998617ac98c  release/kernels/lanectx2.sv-hosted.log
68980994893788fcaf35ac8a864eac4ca3ace4687b6ef3921c44c3090eca8549  release/kernels/late.by_instr.json.gz
56eaa1f4f2c4548a8bf3062d1a4bf3c5de9065cb7553014aecdc9146d8303222  release/kernels/late.by_unit.json.gz
e2e8c328a671570ef9221f3e2a55944f588eb875ffbbf334e4fe20682a6c3ecc  release/kernels/late.ccvtrace
1daa79ecbe1d5934f858a0b0addda2778ebcdd6e334221ca64fd59d83411c829  release/kernels/late.log
86084f6bd747a2cf32acbc0ebd96ebd3e4ef2d8d9e21be49e3ae49290d7927f3  release/kernels/late.oracle.jsonl
a4182e9c8ef2db7e7a6c07af1161bccf2a9082022249f33f828e8c17be719480  release/kernels/late.sv-hosted.log
6160f0a02698a1b2d26f05a681478d94ae64b2647f40c224d60e5bc9d773d8ef  release/kernels/ldpar.by_instr.json.gz
6f1dc6a19d8620c37e523cfe2c0621f4ed6fcf6ec40d9b90e943c839f2d8301c  release/kernels/ldpar.by_unit.json.gz
8b80f0644ce546519b2907f4eaa06ccf24dacfb174a0929ae5b16e41cca94a47  release/kernels/ldpar.ccvtrace
29466161123b95f5461b944da79406e70878159431f7abd46955d976e3f9cc00  release/kernels/ldpar.log
8ac08538e9c807637babd61b31e340f7461878ada31f0c0b83cd66331cfaf486  release/kernels/ldpar.oracle.jsonl
d64f529ec544ce23314288dd059e7d17a7a117d1bc6e2c80ad0a3c49fb139479  release/kernels/ldpar.sv-hosted.log
d0d8c8f45c1eb18a4d7cfd847380401f8d2b30cde524087e90cb3a8f8a013e04  release/kernels/lnorm1.by_instr.json.gz
c7722a7ca4941f3c176a5b8943a3c3bc20eea94543b09124a9dcf10860c43907  release/kernels/lnorm1.by_unit.json.gz
5a1fb2f1c1df24b661430c0b1fff617e90148350d09e52fd054d1beb65d44d5e  release/kernels/lnorm1.ccvtrace
0d68c02fbb3ae957004ac7fc7fde9de803ec3cecbf62f32fbc1e25467bf9675d  release/kernels/lnorm1.log
a8d85811af988a1b9fc00db1517300af3d93ec8e589e403d3b9113fa9e0ffc86  release/kernels/lnorm1.oracle.jsonl
77a7828367e649ab7ead95f99bd20d721dcff7746296a8dfe958192e0dbfb62e  release/kernels/lnorm1.sv-hosted.log
7181815071ae2ce47e005a187edd793b82743768281a8e7fb2265dad556c0f70  release/kernels/localsp.by_instr.json.gz
ff16a77b8c24c472aa78251c15940bc93ff77effd5b00e5b3e931c1c25d70d9f  release/kernels/localsp.by_unit.json.gz
bd78e05909ec69aa774a212478967f904e3257a1e5cdf3edc7689cab7f3da1a7  release/kernels/localsp.ccvtrace
c03841aa7f8c45609c1c2b708f72d017d671120831e6467579ac5c0e12422659  release/kernels/localsp.log
55e3c9f36e7f7d38c0ddd38903aff4bb4509ae862015c592e6b937ea258042ca  release/kernels/localsp.oracle.jsonl
74d4ace8319ec4660bf5b59bfd733efd13d50d4208c060bbe7fd0aa77328a5b8  release/kernels/localsp.sv-hosted.log
be881bd14f8c6ec64057ae5ad6147a36873db2aa54e4a68d62633dccefe1af2f  release/kernels/loop.by_instr.json.gz
c70a9587911b463270bd25ff4ed1233212a134b890028dfaa2ead8a2c545c036  release/kernels/loop.by_unit.json.gz
05599f989c0d60da6bbedde81701aa56ae1c2a56bbb878bbddeca9829b14e167  release/kernels/loop.ccvtrace
38cd3396460d72c10df25bd0ce36f34878949d68a99291e4abd3ef577e4573a6  release/kernels/loop.log
03ce5920c06c93e93516d8e53c3f7169f14e3593de204eacceffc0b8a3e32016  release/kernels/loop.oracle.jsonl
fdb6ac90daf78dd2aa5a042d1cd41bb59d2efe161a450f1ad198f768077ea52b  release/kernels/loop.sv-hosted.log
2ab7875782e48e870cbe554e79433e562fe379098fb52a809dc22d07b1cb9904  release/kernels/merge.by_instr.json.gz
c0c3bd74239e11c92e6e329d47cba7c3c4761637b04621e42067cc2642966783  release/kernels/merge.by_unit.json.gz
2f43408ff2d9fff8512adaa9e24aae50158636b35dd1778e07d3a003df283170  release/kernels/merge.ccvtrace
0642768dff1f7f8a9f371cdf7b183509b780fdfc50ca2791a0d3450ea9f4c845  release/kernels/merge.log
f96d28815f8756b1f5a45ded53e6170883d2dfa10f9eef0d14b8050b1318164a  release/kernels/merge.oracle.jsonl
2fa7497ca8ac83919daefae24b1d4d2f93b4132b1b567173a382286d65217230  release/kernels/merge.sv-hosted.log
eade6f52a61fcd0c9f22ed133aeacb760f7075ecd735a36859a49d875dd824cb  release/kernels/missrun.by_instr.json.gz
aec3128a71efe173addc990f927f8735d332acf2bbffb8580bd369c1046d8b34  release/kernels/missrun.by_unit.json.gz
9b9e962099b538ac683b0f9ee8745062f8642478667cdaed17c5bc301fa4b958  release/kernels/missrun.ccvtrace
78a26b3f437e1fe3afb5256b2ab0d42c955f1901462b5fbead062cb4805be804  release/kernels/missrun.log
531bdaf281e5590774bd2775427f25e4cc0419cf8e3d5b6999843ffe9ef87258  release/kernels/missrun.oracle.jsonl
155cb34b4413d01f39424ff1a2b5df21622ab516b377b64fc6a2934feb360994  release/kernels/missrun.sv-hosted.log
d1ba7e85969f0815a1043848f9877c3ab8f1a9114e2d86dbb8726e4bc21ed6ee  release/kernels/mload.by_instr.json.gz
935d31230a769a01b121507bf3f0f699219120bb446161bc89c428c1b8ee58a6  release/kernels/mload.by_unit.json.gz
063b6cceb78f323833fbe9eb0ae6ddab36c499214e9f131972fb171c4a6635c1  release/kernels/mload.ccvtrace
9fc3bc7b25ca9569da146872a305deed1c0f2a637d7fec6129586e5bdb852452  release/kernels/mload.log
8000e477b9a95dfb9f0af964e8346acb9d36f1358fd06ffc4ff7cf599d2b8868  release/kernels/mload.oracle.jsonl
bbf6b06b9c08607706abe0d5d44873e61564666cff137168a817044e6a1554a6  release/kernels/mload.sv-hosted.log
0299ceae4a3e45f3982e1ffdd6dae421c45ec7b3f84b20bd254711363021e1a9  release/kernels/mlp.by_instr.json.gz
a56b48127db1f311f87d60026acdb939bdd4c7a9bb6a9d05fe3965c275b00e6e  release/kernels/mlp.by_unit.json.gz
0dcc5e88bf12bbd8f4e8841fb80413dd37c8213957342197e5cf7b89748182e1  release/kernels/mlp.ccvtrace
91b4ef9fbec8234236cda533f0c69d6ecdf958bf0071132766743179cb18ea39  release/kernels/mlp.log
138d282f88d56c8ad648a91af0a983254b55d9fa22942c00d47b327f516a6e44  release/kernels/mlp.oracle.jsonl
b830ec05bf4594903136e4fb5f847317fa98371464b0af2b755dac50a40476c9  release/kernels/mlp.sv-hosted.log
0f4ec846a037ec609561064cd2e1a5611de4a075e561f8657c42b79449066faa  release/kernels/mwmiss.by_instr.json.gz
e3b4cbe369e52bd03895bd13dc303a379c445a6901b150273affedcf5a690b6a  release/kernels/mwmiss.by_unit.json.gz
a4bdf907a65868c13182ce6e067e1dd7099fcb30b095e752d15512c05ecfbb58  release/kernels/mwmiss.ccvtrace
451ede22ff06e711081337a9fcc8059c0878535b8e4c6c3094d907be51350b55  release/kernels/mwmiss.log
8abe8e8997456a2a6711ee72da54d854b24e20abbdab28e4b7271c0d28418de8  release/kernels/mwmiss.oracle.jsonl
c782e28a713ef04861077981aa290ab9841b0b63669cab62c0dd12362dc754ad  release/kernels/mwmiss.sv-hosted.log
bfecb45e5297fba86ec44d5c7448c544eb4da9f5380e598afd28060339c6faa9  release/kernels/narrowadd.by_instr.json.gz
ca2908797a83401d5573e192984237995ca51f21f9647eb6790df641cb597196  release/kernels/narrowadd.by_unit.json.gz
e2aa3a9a060a4ea9aff1dea86739a679757392bbdd64b520c0cd72275fc6410e  release/kernels/narrowadd.ccvtrace
d72f59a088484011a60c4677ee6ec06af471de4c8061257966cd62d865a121b8  release/kernels/narrowadd.log
40a2cf629853dd404bb06b4a07e35abde3d12efc13f26ffe28f923daf2994574  release/kernels/narrowadd.oracle.jsonl
6eefae97749056dd9e7fa4f21718d95b7772bd0bd9e2754fbd0d4b0b455a22a5  release/kernels/narrowadd.sv-hosted.log
b37df1e59d6f17512f2bc28da18281cc77760e588746bf8040c67fab21b28dc1  release/kernels/pguard.by_instr.json.gz
bfea1b47562377a474fa85ed4f4dee15e969fdb805d0bd9365e3514e1910127d  release/kernels/pguard.by_unit.json.gz
7ea87af30b8cfa9e54b7754dd440ef60896a0330a3e1f42f3983de79cf02bd5d  release/kernels/pguard.ccvtrace
36a8e73893e37a93d594b8ae73b09da3357a747637dd3819fbea26dea18d5caa  release/kernels/pguard.log
690e56f1cb8d97cbf67124b7dff3ad0a90cb8981814cd1709cf0cd0e035b3bd9  release/kernels/pguard.oracle.jsonl
dd3d990249b85d8289bc7754bc136a69a041e45b3d305ab68085766515381a45  release/kernels/pguard.sv-hosted.log
53ed448b08df4242428295355d8d70f50065bb7e501e66bb0f6ec0294c555d6f  release/kernels/plog.by_instr.json.gz
c75dc1daf18227ada4e2c7846aa3ec5898c88be29b41833577a77d999ce6982d  release/kernels/plog.by_unit.json.gz
ce4aec9a797ce6e24a9082c3c4e22e4cc45d2bd6d9cf47ffadb3e8da5e251eb9  release/kernels/plog.ccvtrace
fdac345ea363af737ad946144b80db833fd50ec242049ceeb8418057a57ffad6  release/kernels/plog.log
0c99915e2da60f4670da00504a6371d7d17701d4431e733a3ff8fa98a2030d6a  release/kernels/plog.oracle.jsonl
5bc7fc94d0df6afb1539de16631791881b3884d4f07eeafdb2d28aaf19cddc3e  release/kernels/plog.sv-hosted.log
aa67c9e80b16ea2f9f5cf07fb4cd35966ceb688803055f9a9c683e6b88af193b  release/kernels/pmovdiv.by_instr.json.gz
84143f8fc4f2c6c78819481b052cb9d206e80a5a2844047f5804c60ca7775a9f  release/kernels/pmovdiv.by_unit.json.gz
4fe481c67584f36b72d1f510fbace5f75fa34ca8d76713e16d393f8638f099f9  release/kernels/pmovdiv.ccvtrace
6a390bd9d495b5f2a68f393b5a0e1799379092a482f2900a3202335373391038  release/kernels/pmovdiv.log
7bc646cff6166a51bdce03d7c1b7209e871f0a91d743083a9b910a80bcd0b33f  release/kernels/pmovdiv.oracle.jsonl
6282dab38326e87eb264e5a22f5855f35a35c1a01edf3011fabc636147a7a1a4  release/kernels/pmovdiv.sv-hosted.log
f0db3a500cb32a2024320d9c21d5384b1cab28e303c0f9ebe2019af0c3db94e9  release/kernels/predlane.by_instr.json.gz
90bb11e3840d60223cdd7b695233ca9ae9d8a01944c83d26c3511cdda1e106f0  release/kernels/predlane.by_unit.json.gz
43ffb5fd93c492e608093ee380fd91f02047a73d0d5bca90f37879a3a9b027e6  release/kernels/predlane.ccvtrace
479e3a3c99ea93e23bfe746c9f8dcd8e967aa4a4902d2fc4603d0fc5617f5de0  release/kernels/predlane.log
c45f4177b9e84fc8a6e36b13534a0c7636eb30a3f8531847100ce5e23bf404b1  release/kernels/predlane.oracle.jsonl
1b4c240b5ad09a3aaa1ebcf2a13ba7718b4d78fb91a8c4b4f013ad8634e91b58  release/kernels/predlane.sv-hosted.log
643f111f885ba9914c93661de22e99c3cd6b3ce110fcbbf4df5a62740a4664cb  release/kernels/predmerge.by_instr.json.gz
2b7ffc0885e8888ad0b0dd08ce47a93678963273bc409d4d2dd835f12d4b1883  release/kernels/predmerge.by_unit.json.gz
d773aa91af7cfa2400e67801a569c10b730b800848cf39adce1a17e4661f83d2  release/kernels/predmerge.ccvtrace
0519f238adaf3a6e08771d0e2a16b56ad9c6c879708d8498869806605d09e994  release/kernels/predmerge.log
6c737c49434bcd08e3e0814c8b1dbf15c586ae74f7929ba3148ddcee2c62c845  release/kernels/predmerge.oracle.jsonl
afd92c35d57e4aa72e10b28f77a634f876d2426dfa5cf5fda116fce99e97a094  release/kernels/predmerge.sv-hosted.log
bd6ae916b8f622055a97c27dd1ecc0af35899d3e35420c23cd387a6cda4e0ffd  release/kernels/predspill.by_instr.json.gz
87a13be8c9914c161aa069e98b44ebc93b40d343eec5589dcebc727afe37c100  release/kernels/predspill.by_unit.json.gz
ef5cd45c3aca2c80a0f934209300878095623cf9fdccac71b72455d598a5cc83  release/kernels/predspill.ccvtrace
b74453365f9626a9409e6d640e53ab7e82192753459b98c362b79e73c7c443a4  release/kernels/predspill.log
b7c84c6478117ffa0f06da0e6ad1e4628e2683426a7911080810e78e06a5242e  release/kernels/predspill.oracle.jsonl
566c2fd291dc4d4ef52bf2618388f2c35feeac9196894df8a388c45f98701a0a  release/kernels/predspill.sv-hosted.log
7c1fa9098d270d1c3d3eb85144119af180a95621b79eb7c99710b79ad8883eed  release/kernels/predswap.by_instr.json.gz
a1c80753e458ba83477a8b48647ef970cf1292917374f34210ca328567e40266  release/kernels/predswap.by_unit.json.gz
6dde3956ce0082953ad263d923ba60c127a1dbf50b2927cd690a854dd840bac6  release/kernels/predswap.ccvtrace
69ed6f207b3cad4ac61f32b06735e6878b4f50c1802b141d303d23f863f31011  release/kernels/predswap.log
a6d4f7ed517553816d889c7c9eeb6bcfd1f6c973fbf682ecb69f3c2de619f7bb  release/kernels/predswap.oracle.jsonl
2e38ac85da5c8690fe6bdf575b24faf0eef2654a53418efd24a8234df461b5ff  release/kernels/predswap.sv-hosted.log
82dfcd81c35bd6ad70f74dae5df6131f2cfe4d5e3b83f12c32e3978bb9ac0d27  release/kernels/privwin.by_instr.json.gz
8aad659342811a2d780f05ec4c84208aceb7e2fca9521872aec201345e983acb  release/kernels/privwin.by_unit.json.gz
eeb608f6ab0b70400d080d3c510895c3591c8cb7f98b9664b7579dfc372fdb75  release/kernels/privwin.ccvtrace
7079891685b3eecf6e7d505c709120bf9a469665823581448d93ca8d86be2ff3  release/kernels/privwin.log
861f686fc4480363472908d679d8815e8c957d768e7ab32c826930527b0fb7a8  release/kernels/privwin.oracle.jsonl
4f78973d4ecf10a10b54b38f70437135f5605936beb8d60bf114faeb299ec8c2  release/kernels/privwin.sv-hosted.log
d7b5874475cb868774d77761ebd48d34b5f1856f3ca8ac8fc12674517c431b88  release/kernels/provswap.by_instr.json.gz
0eaba00520f2daf11c83cb63b7cf8ec93b930631a3dc9bb489d6efeffe7543c9  release/kernels/provswap.by_unit.json.gz
5770ff85f63ab02333da388b746df768fb8608a837f5d910b09c6867fac6d8e4  release/kernels/provswap.ccvtrace
c38536ad24c43db7a89cc7345baff7e6b97972a9b5152f0120a06bfa0b2fec77  release/kernels/provswap.log
c9c32a793d54cc7401477f582487f7e8b345b2669a75337b8d6327120d98e5dc  release/kernels/provswap.oracle.jsonl
253a56f2ba76e5bb182cf459666c34e752a849b207c22f68e5e782f03fc6f364  release/kernels/provswap.sv-hosted.log
39d70582e0752a82c36cefd406bcce65d94c8e9b835aaa9cf55786f6c1765a0b  release/kernels/retmiss.by_instr.json.gz
60238dbb092d3dbda49d0066899e21aa0749abce902ac01b517a269d1fce28ee  release/kernels/retmiss.by_unit.json.gz
45e974b9faa7643f7c6b02d61ea31b5f19f83a182e6edae29a5cc9969e3de614  release/kernels/retmiss.ccvtrace
16cf0e54f6bbc6d5341141943710efe6adc74b24d9d7a8518a979e96c59dd574  release/kernels/retmiss.log
e5ef8538e838c6cff7febfc679dd091cf5e002f82d34f1009b1948ce22bc3649  release/kernels/retmiss.oracle.jsonl
cdb7ac5889ea86aecf3518439e6ad24f078ee175f20b897646024c48c3fd50c8  release/kernels/retmiss.sv-hosted.log
d45b064f90b496adbbbf3be694a8cc4f6af4ea41825c8bb83b0c4042da5a369a  release/kernels/roconst.by_instr.json
b38b6900712bfd3ada68a6b3627c4ea3fe521aef042fc47dd43dfb23bb1283cf  release/kernels/roconst.by_unit.json
f3713f83ec2f195b035033bdb47cfd76ef95bbcac2a975d18c8e17e3b3ccda49  release/kernels/roconst.ccvtrace
3a8dbca0fe64dc3e35a8d8b8ab3c8131a6e1fb9fe115ce6f593786597c144408  release/kernels/roconst.log
8087c0671de620162881aecd38cd6114b78e7be6bd71201e3ec02c9a2e2e750e  release/kernels/roconst.oracle.jsonl
32820067dcd332a9bdf7f4493345a4b10a98ffa69833d28dfd15671718ea0940  release/kernels/roconst.sv-hosted.log
7d213047dc11229803ff907bc5a2192cad3a16f993fe7f5ae66bdd5e6ec74442  release/kernels/rogated.by_instr.json
5d25bdb54971ce9f1eaa63980741338e1e102cbc9ff9c9c9b8d42b114ae1490e  release/kernels/rogated.by_unit.json.gz
e0022bd67a6d629144891b56607860fafa98ac1de5fa80dc411be11a44c9a890  release/kernels/rogated.ccvtrace
6ff2c0de9a74cc2c88ce562712e3c17e249f4b9bbdf2ff359bf78e9da4fcda33  release/kernels/rogated.log
7cd02bd4cceec5a044d6b4d6a80df1e68ed0ae71b0b2a953143636d5b809ea6c  release/kernels/rogated.oracle.jsonl
d958e11cb0fa3bafdd56293e793d26c9e18d5f97ea52eb67790f915be77917c5  release/kernels/rogated.sv-hosted.log
015f5ba057415186369699b046087255e611e89926bb0b151570b4cf07cec8b8  release/kernels/rokill.by_instr.json.gz
5ecfabbef43f8ac6842fb39757bb48d947edec2bc26dfccce17de87b3538c1bf  release/kernels/rokill.by_unit.json.gz
cb434c89178bda63feb85c508e8cbd1b00bffd6b69525ab858d2b11b6cf16c17  release/kernels/rokill.ccvtrace
ea61cbe4274fdafe115b14e163dd1b38a709532704e4afc20a8bfd30b4f41add  release/kernels/rokill.log
94efcef96af469a512d346ce61623980fe86383188eaebd55120f716db596f14  release/kernels/rokill.oracle.jsonl
45ad9b79d893cf6663343ec26f92004e16b05169cafd2fbc9e07dd7287254a4f  release/kernels/rokill.sv-hosted.log
db4dc01a13bf3bf9990b7d6a9947a5f58798ac66eb1c38de2d5228c355646912  release/kernels/rokilllane.by_instr.json.gz
766fda74a96c687cd34cc30aeea51fcf5ee2b85591b9e7b658c312bba23c5d5d  release/kernels/rokilllane.by_unit.json.gz
dba628a43540510e90493dcf402203d99b3542ad6dd5a94033f0f5f1309c0d42  release/kernels/rokilllane.ccvtrace
b3c1c89ea1e6f2d421cffa5d9cf6096947f962c930ba06a48245483fac507ef8  release/kernels/rokilllane.log
f5ca6e666eff2f44894df74a291b43b3c0e7be0a63a47d795fdefd7b22016f45  release/kernels/rokilllane.oracle.jsonl
4c0cfed02572e76fc72020d9f0fd3970f93891a0d549db9e495d96e60e1c3358  release/kernels/rokilllane.sv-hosted.log
f8fe604241644b224e6431d16e4fad889c99826b82f49205e4c9014b9ae62e8a  release/kernels/rolaunch.by_instr.json
12e5281971b0a06ca95d953aa22a6d6b481d8fee948f50ab777c87877757fe46  release/kernels/rolaunch.by_unit.json
32fbf77dc8fb17f0113b068b5a00568b6ea97be3ad8e5bd1c69b7cae2f04a946  release/kernels/rolaunch.ccvtrace
17eae3d99453e99b558374444cbf9f8f6c2600910a4f13fd722a13caf49fc391  release/kernels/rolaunch.log
e7dad585c3e70615de04330fd03f4f282c29a005dc1732a35655fb261d51139e  release/kernels/rolaunch.oracle.jsonl
57b73aebcbf5e942e0c891c5ac4ddb3a7f1aceb948e6ae46c557c58db768f50c  release/kernels/rolaunch.sv-hosted.log
d45b064f90b496adbbbf3be694a8cc4f6af4ea41825c8bb83b0c4042da5a369a  release/kernels/rolimit.by_instr.json
e8822066a61bf10f59647aa7240a3044f25d2eba55ac5f7ebacbf1901974dd8f  release/kernels/rolimit.by_unit.json
0e8db555321feaf0fded659de3d7ab35b3dadb15ccef4bf8dabfaec2e87a5563  release/kernels/rolimit.ccvtrace
690b62f8e82f8a12b84214d2020eb8c2d16af9b6a6199944cc903b1f214f389e  release/kernels/rolimit.log
1c5bc0cb8e8b2e69505fb5a551a16d5d10c56f232b88da7a27e336ad7d962de2  release/kernels/rolimit.oracle.jsonl
b307ce5b6f1f08840f0ea53342c43e543b604fdfa9d6aa6e536d4fd3147f63e4  release/kernels/rolimit.sv-hosted.log
826896dbb743de59399b01dbde6ac9987d437e210f27c25c2de848d3f4643634  release/kernels/roload.by_instr.json.gz
b76a26f5561c960ec5baf338eed752c79700449e52e770db29308d753bf129ad  release/kernels/roload.by_unit.json.gz
d030ac67b1dcde0dcc21aad32d53d84415c253aeea08ff0736e55b0472fc9a6e  release/kernels/roload.ccvtrace
22ff90c31abf892048dae7d01af2653e0bba3d91f7eefdae5b1f00a17407a031  release/kernels/roload.log
f7c1309cc9764769fb5803f6fd0f2f5e1eb418f2d23fbe5e17cf5f9106869fdf  release/kernels/roload.oracle.jsonl
c59cc28ce29d353f7996ea7786486ba4bbf78a12106992e557bc44c3469e388f  release/kernels/roload.sv-hosted.log
c8e47b4a4fe37a5cf0f0e8ff97e2ad16cbf9bb1fc37bef0111a0506c7afb52bf  release/kernels/rope.by_instr.json.gz
4acf3de04b65dea49ddb8c31b1b45428ab6c27240338f6dc9ff69cf7cd34ba80  release/kernels/rope.by_unit.json.gz
fc7ff8922f97156780744ae5b935ea98329ade9e9e7d72f2e04d088ffb65160f  release/kernels/rope.ccvtrace
c2f7c391be76fe57acc637a18b19e14697903adf4e20962531961890974139bd  release/kernels/rope.log
d55f9efae392dc8877c102c01c0810e7654b666b6ede386328108164c6cf88f3  release/kernels/rope.oracle.jsonl
10c76641e285282bce3e94b480942e6bed71213b5f306d45adcaac79afa09796  release/kernels/rope.sv-hosted.log
3645f53103437936e494d377bfe5097e08654fa24a73061e0987b35cabaac2f5  release/kernels/ropediv.by_instr.json.gz
4142dcb3efecf61394ffbd876785150356b13700e00c8eb8e83dc88c08e7c29a  release/kernels/ropediv.by_unit.json.gz
68a770673c6707faa7e6c6c87ba328fabbd4ee5bc1a1daad0064d679fa7c0c89  release/kernels/ropediv.ccvtrace
fea00e8bf23ba451fc44a507b6c7de64df095a8ce2d4f4d20fbfeba54975a630  release/kernels/ropediv.log
10c0ec6ec18b7b44638c790033109198c079d07c1537bf193353ccedd00a920f  release/kernels/ropediv.oracle.jsonl
6bd1d9dcbc435ad958b71c66603495799fe7355ecab28d61d697dd260a6760dd  release/kernels/ropediv.sv-hosted.log
a69ec23c1d4e581d5106efc75d320cc7fda164d0a7e971044fb5c5b230cc83cd  release/kernels/sel.by_instr.json.gz
7e84be4e7cd1ed3b95e5f52710bb89590b7c917f90b2af985198f36827f0cf27  release/kernels/sel.by_unit.json.gz
33a33114b5167306fc24ee447399ba293a8568ed59ddc2c9e307b97a3df3638f  release/kernels/sel.ccvtrace
c9c85eb35ca8618e716376041ac183a741bb46124ed4a49d06637dca9342f8e2  release/kernels/sel.log
87f6a81e8afa004c8039bf2f61c90176fcf29ab29bb17ac44aa016a5cc8438fe  release/kernels/sel.oracle.jsonl
cf59f99e2925052df8c71f65cf9f83d7a91739d25598217568b8a40a2321fd62  release/kernels/sel.sv-hosted.log
9b13973edebabc7f2e6d18c0d8b939b3bf049eab2ec073195f4f85cfa83048a5  release/kernels/sized.by_instr.json.gz
4402f9db031dd3b1c7558c349524e2d01279fbf49c4bb209e3887148d9fb8fc2  release/kernels/sized.by_unit.json.gz
19d51ff5b6b8460534f510632660d9c1fc7ad3ee8ff7d9b60ea78660a12e7e17  release/kernels/sized.ccvtrace
348d09e46e42c0133c3fed97dec0cc356ea5ae2588ae0539dad4de16ba393e1f  release/kernels/sized.log
36d903ba1618bd1faa437c9812a6ee6c0c966a63196c796267d74bf2695ebc3d  release/kernels/sized.oracle.jsonl
3cbed16bbd01c3fc181b745c6b52a40fa1a6527bf017f3ff38982adfbf7fb8e2  release/kernels/sized.sv-hosted.log
6159a36279a9aa789fba68669ec22eb31e8be03d7bfc4fe679c74b5969f72220  release/kernels/slotform.by_instr.json.gz
0739d5c80a84f625f11429b9c8ca2d4612738ec983860690b54c536aae0ce4ee  release/kernels/slotform.by_unit.json.gz
140f5579dac1c3408bb35a5f3bdbf309b6d065e2aaab8c64937909a79222face  release/kernels/slotform.ccvtrace
33d4c85159771243e8012d4d2802694643345bb26c9a994aa1bfc75059c5fd80  release/kernels/slotform.log
8b61db7419b18cea8a646fb628218447e72e84a18a9891ffb73b441736138ab9  release/kernels/slotform.oracle.jsonl
f862bdb1dd35d364141168f017b7e3d5137fb32bf63e2c104c9462e77214b7c2  release/kernels/slotform.sv-hosted.log
95fa6fe98638a42e8cf7c6b83e1953732f436ac34bdb29294c24dc01d22a1e1a  release/kernels/spinwait.by_instr.json.gz
a69b555dbbcc23810ec9108dd9fed718869352ecfffe3dfd35523854104457f8  release/kernels/spinwait.by_unit.json.gz
ae2744f200137504e4e16953e8b2e58f8055d8e728e2cb6ed8e4e996da5a28f2  release/kernels/spinwait.ccvtrace
285d630ce34fabd0d8bd1a796c7043da45033ceb5018ad55b459e80ebcfdff51  release/kernels/spinwait.log
868920637236c878b33779bd450439466fc3626996a3164573dc11d437d5c709  release/kernels/spinwait.oracle.jsonl
bea9753f607ad9cdc306ed636fbbdef8fbae147516c997c023bfceaf4701f665  release/kernels/spinwait.sv-hosted.log
a1849c99d96c4d920c3d1b8dd1438e753aac9502cbdc193db12941ab6014cec7  release/kernels/spmbank.by_instr.json.gz
1c985137fea67b0f128b95cc8a4585f2ff500bb92486881a38415df50bbc2ba4  release/kernels/spmbank.by_unit.json.gz
c9e0541d73a86ace0be2c7140b58c219c67cdc59ea3c535408d630297cbaaec6  release/kernels/spmbank.ccvtrace
42557d5759bd562f8d661b42e41efe639f216a1607b0f52145012e5d8d61a576  release/kernels/spmbank.log
3af490cc37d7a92dbe719b57de216b648536eb301ff9d13de9a39f50d150d725  release/kernels/spmbank.oracle.jsonl
c59da3c599dcdd56a983f97d3fb2b43851ae3a044ff15d449723894bbc376f36  release/kernels/spmbank.sv-hosted.log
0830bfe6c54bfec4ef06e33854de96c4aa67572911b7f9cb56764ee25f371647  release/kernels/srd.by_instr.json.gz
b566b78e552f6a37c31b3265dd661a769810edd2a7bb530b4c232ff00648a677  release/kernels/srd.by_unit.json.gz
f255c02a28c53c4b57a6b17bccf73852f4dfb2d06486b63be7fd69e6f3ef22dd  release/kernels/srd.ccvtrace
5e92d83bb1bef4aaf765a4b87019bbfb93e7974c037864bf12c5ee1b2ca4a90c  release/kernels/srd.log
b08eb5e3673cac7eebb8b72af5ed3783c8e70a9e96592e76bf3722551bc79473  release/kernels/srd.oracle.jsonl
69b3bfde0f1137d00f8c57351725c2d57a5b6c8352a5d097b45bea1122ac25b0  release/kernels/srd.sv-hosted.log
98cd08c19000998398974921c56042c9fe7c8dcb7b71ba3192e304440efbebce  release/kernels/stall.by_instr.json.gz
e49f8c4fc5a810bb6a7bbbe3699f5e092d616f4c6f4e174cf777c8253145a494  release/kernels/stall.by_unit.json.gz
0b1d90e2b2a1a6a0982b2fb7ffbf4faf290767e6f55e1ad096d003702d2e26ea  release/kernels/stall.ccvtrace
e226193e535a7ee5074c7cd156f6b983ce594d1fb689dfef3c2395b87e60c89d  release/kernels/stall.log
500db2c482b07a0706583422cd68878301d0146c1f872ccc1f11bfdcf5c993ef  release/kernels/stall.oracle.jsonl
e1f8451c85f90cfd65d192e6e883ce587ac5ec030be7cb89aa5969a3deb510a1  release/kernels/stall.sv-hosted.log
5662192d07efc44da481e7b99fcbe0bb29b156efaad0bd376c40f5bbd85c07d6  release/kernels/swap.by_instr.json.gz
8d61347ea6d47ff858f894ffc324153bd43e9992a4886434ba23e0e54c1012c4  release/kernels/swap.by_unit.json.gz
d4f9a6abd33a375605faaab1f07f1de4820d583ff4a9a9ba229e1cbda4f8a28f  release/kernels/swap.ccvtrace
17d665eca634f68f3e57a0ff9243950479f212b069c8e643cbb01e4a89c07eab  release/kernels/swap.log
3658a26316c1ff7bc1744304a42f736e930fcde2865c8913e6cc67a22ce96667  release/kernels/swap.oracle.jsonl
b455852d7639917e51ae02b10c2b4238ebe17fdbcdc9e2a2825345b3227312fb  release/kernels/swap.sv-hosted.log
56d536b08184be32fa727fe049c5907e32ad95e31a00976ba7df4d59dc19f7e8  release/kernels/transp4.by_instr.json.gz
c2d2aa662cc663df15a1a8512f8d0c1df3fc523775cd5408fe7cbc56019e7566  release/kernels/transp4.by_unit.json.gz
f3aa58c6b823e6d3415eb0f60bfba601890efdffb7b20e25f9d8f81c37a06054  release/kernels/transp4.ccvtrace
b6835b3995160ec1f7ffdf363728dbe89b2369ee0234633673554f911d982a1f  release/kernels/transp4.log
06396ace3ac19677fd39c700e408606e5bdbacb24997d663bbe8872e63dd74fc  release/kernels/transp4.oracle.jsonl
ab23bae93efec21a345b7843302f57c4ae307b49f0c3d1928010cd49238e582b  release/kernels/transp4.sv-hosted.log
bd8b4a978feec9792b9d026412732576d8b990ec232d8039a25208207fb8ed72  release/kernels/unal.by_instr.json.gz
b13fea47203fc6a5bf665d441822a1f8cbcd0f18ba87d2106eaad2048f33a48a  release/kernels/unal.by_unit.json.gz
f0cc8a6483da7e1547d81822745f9513824861f37c3e59f25922c8df4895b09b  release/kernels/unal.ccvtrace
73cef6003f06c7a06cbd8dff05d46e32447275d222a44b380e6553a28d48edef  release/kernels/unal.log
c3d484bb160657a563df983d9a2532eac27f556636617960aa1e72183ac2b299  release/kernels/unal.oracle.jsonl
119c9d3236f2b2f628cdc255ad1be22c0d42578998d2347ac6f2dbdbfccc4d33  release/kernels/unal.sv-hosted.log
33c9ff17b7b7be59b52639f14519efc974ca2d473bb88d569c6f39e79047e5fb  release/kernels/vadd.by_instr.json.gz
a9b81274e3198ac74190a3add88882ad6a54098c74535d05a0e4d6e54ed1871b  release/kernels/vadd.by_unit.json.gz
d60247e80c3d58b0b971253c140a1b93ebf7a3763f11e23443a9108a3199dd49  release/kernels/vadd.ccvtrace
ff777e4dbfa68b04069d091254550c7725243e226258bbc7e172ba2368e65ff2  release/kernels/vadd.log
0276b6d0611a4bbcdc004ab3987214aea138245bc7217504147331689a9c0880  release/kernels/vadd.oracle.jsonl
f698e937ce7c9c721ada836ab50a9fcba1526227a03d56afafa31ec3024b9341  release/kernels/vadd.sv-hosted.log
93ff72c51794b999fd103a7ef320102ee927a1d705da3b21d8d964825d22910e  release/kernels/vadd4.by_instr.json.gz
a7f1fd60f273c56f4dc23473197555117855db2d5ae795a3bd9c66b2cbdb83fe  release/kernels/vadd4.by_unit.json.gz
12c2c2f0d29aeeb32d687a26b8adee42605196396852a4fee675c92870f17252  release/kernels/vadd4.ccvtrace
17f69a7bef5852a6271fb360f709ee08a0ae943d42bd8cbe829ff5e6de094a13  release/kernels/vadd4.log
225aa18fc9f38aa9ad615aa11de254337d59fa705877553d873062c68366e0db  release/kernels/vadd4.oracle.jsonl
df4968010aefdbfdc2e6c275205d6f4f71f8e767e99b6c8773a42429be45eb5a  release/kernels/vadd4.sv-hosted.log
0a1d9fda899aa97a521ff900af1cce9d85b7cdafe9b8f8baa936bcbfdf69c756  release/kernels/vaddslow.by_instr.json.gz
7463bc47a5b254ca83f2a29f7fa40b1764b832e7a96a56f754d14901039574a9  release/kernels/vaddslow.by_unit.json.gz
360619055225f8897e5f13dc2ce9fc418dcbe487f70c2adb3c0452eb50912e4c  release/kernels/vaddslow.ccvtrace
d633b387442348f4a78b6110c450afa6abfcba8427cc163b7e8ac91310f4bbb2  release/kernels/vaddslow.log
e9e6218e8b8450e9f9ff6b39d659c994a1e51c527a0c5bd10d18b5658ae0e344  release/kernels/vaddslow.oracle.jsonl
e627f4bb2a463538a121cbe9e5c55fb8c26ab549452d2822cff20cb88a8eede2  release/kernels/vaddslow.sv-hosted.log
9943f49c85416e08fe8e97ded2e34c26517f58a2203a6fb5c203fb276b49c86f  release/verify.log
56b3d8627d79d397ca06dfb57060015391cb95e52e925d1f09a4b2a7f4147127  release/wiring.txt
```
