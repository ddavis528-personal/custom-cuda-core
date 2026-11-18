# Snapshot snapshot-2026-11-18-36866ec

**A generated, read-only snapshot. Do not edit or merge it.** The source
is `ti-next` at `36866ec73993660e2eef2e7c5daf670a333736b0`, and this branch is rebuilt from source by
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
| Source | `ti-next` @ `36866ec73993660e2eef2e7c5daf670a333736b0` |
| Built | 2026-11-18 (UTC) |
| Gate | `tools/verify.sh`: PASS |
| Compiler snapshot | custom-cuda-complier `release` @ `a293afe7d7873fb5d3fac70d8deca980e119b19f` (source `b9ae2c9d5d3b838d5d982d842b558e2d290185ea`) |
| Verilator | Verilator 5.052 2026-09-05 rev v5.052 |
| Icarus | Icarus Verilog version 12.0 (stable) () |
| Yosys | Yosys 0.33 (git sha1 2584903a060) |

## Kernels

| Kernel | Result |
|---|---|
| `addrhigh` | `name=addrhigh finished=1 cycles=83 from_fetch=52 retired=5 issue_groups=6 order=ok gpr_mismatch=0 pred_mismatch=0 mem_mismatch=0 check_failures=0 class_violations=0 overflows=0 credit_leaks=0 cor_late=0 channels_used=26/55 violations=0` |
| `addrlimit` | `name=addrlimit finished=1 cycles=1072 from_fetch=1041 retired=5 issue_groups=5 order=ok gpr_mismatch=0 pred_mismatch=0 mem_mismatch=0 check_failures=0 class_violations=0 overflows=0 credit_leaks=0 cor_late=0 channels_used=27/55 violations=0` |
| `addrneg` | `name=addrneg finished=1 cycles=80 from_fetch=49 retired=1 issue_groups=2 order=ok gpr_mismatch=0 pred_mismatch=0 mem_mismatch=0 check_failures=0 class_violations=0 overflows=0 credit_leaks=0 cor_late=0 channels_used=23/55 violations=0` |
| `atom` | `name=atom finished=1 cycles=8605 from_fetch=8574 retired=29 issue_groups=29 order=ok gpr_mismatch=0 pred_mismatch=0 mem_mismatch=0 check_failures=0 class_violations=0 overflows=0 credit_leaks=0 cor_late=0 channels_used=32/55 violations=0` |
| `atomf` | `name=atomf finished=1 cycles=4609 from_fetch=4578 retired=12 issue_groups=12 order=ok gpr_mismatch=0 pred_mismatch=0 mem_mismatch=0 check_failures=0 class_violations=0 overflows=0 credit_leaks=0 cor_late=0 channels_used=34/55 violations=0` |
| `borrow` | `name=borrow finished=1 cycles=99 from_fetch=68 retired=7 issue_groups=7 order=ok gpr_mismatch=0 pred_mismatch=0 mem_mismatch=0 check_failures=0 class_violations=0 overflows=0 credit_leaks=0 cor_late=0 channels_used=21/55 violations=0` |
| `brs` | `name=brs finished=1 cycles=99 from_fetch=68 retired=12 issue_groups=12 order=ok gpr_mismatch=0 pred_mismatch=0 mem_mismatch=0 check_failures=0 class_violations=0 overflows=0 credit_leaks=0 cor_late=0 channels_used=23/55 violations=0` |
| `byp` | `name=byp finished=1 cycles=118 from_fetch=87 retired=14 issue_groups=14 order=ok gpr_mismatch=0 pred_mismatch=0 mem_mismatch=0 check_failures=0 class_violations=0 overflows=0 credit_leaks=0 cor_late=0 channels_used=31/55 violations=0` |
| `callret` | `name=callret finished=1 cycles=265 from_fetch=234 retired=40 issue_groups=40 order=ok gpr_mismatch=0 pred_mismatch=0 mem_mismatch=0 check_failures=0 class_violations=0 overflows=0 credit_leaks=0 cor_late=0 channels_used=30/55 violations=0` |
| `cas` | `name=cas finished=1 cycles=6908 from_fetch=6877 retired=56 issue_groups=56 order=ok gpr_mismatch=0 pred_mismatch=0 mem_mismatch=0 check_failures=0 class_violations=0 overflows=0 credit_leaks=0 cor_late=0 channels_used=32/55 violations=0` |
| `chains` | `name=chains finished=1 cycles=96 from_fetch=65 retired=29 issue_groups=29 order=ok gpr_mismatch=0 pred_mismatch=0 mem_mismatch=0 check_failures=0 class_violations=0 overflows=0 credit_leaks=0 cor_late=0 channels_used=21/55 violations=0` |
| `coll` | `name=coll finished=1 cycles=78 from_fetch=47 retired=24 issue_groups=24 order=ok gpr_mismatch=0 pred_mismatch=0 mem_mismatch=0 check_failures=0 class_violations=0 overflows=0 credit_leaks=0 cor_late=0 channels_used=21/55 violations=0` |
| `div` | `name=div finished=1 cycles=978 from_fetch=947 retired=144 issue_groups=144 order=ok gpr_mismatch=0 pred_mismatch=0 mem_mismatch=0 check_failures=0 class_violations=0 overflows=0 credit_leaks=0 cor_late=0 channels_used=23/55 violations=0` |
| `divchw` | `name=divchw finished=1 cycles=111 from_fetch=80 retired=5 issue_groups=6 order=ok gpr_mismatch=0 pred_mismatch=0 mem_mismatch=0 check_failures=0 class_violations=0 overflows=0 credit_leaks=0 cor_late=0 channels_used=22/55 violations=0` |
| `divtail` | `name=divtail finished=1 cycles=642 from_fetch=611 retired=96 issue_groups=96 order=ok gpr_mismatch=0 pred_mismatch=0 mem_mismatch=0 check_failures=0 class_violations=0 overflows=0 credit_leaks=0 cor_late=0 channels_used=23/55 violations=0` |
| `divtail2` | `name=divtail2 finished=1 cycles=1517 from_fetch=1486 retired=366 issue_groups=366 order=ok gpr_mismatch=0 pred_mismatch=0 mem_mismatch=0 check_failures=0 class_violations=0 overflows=0 credit_leaks=0 cor_late=0 channels_used=23/55 violations=0` |
| `fence` | `name=fence finished=1 cycles=83 from_fetch=52 retired=7 issue_groups=7 order=ok gpr_mismatch=0 pred_mismatch=0 mem_mismatch=0 check_failures=0 class_violations=0 overflows=0 credit_leaks=0 cor_late=0 channels_used=30/55 violations=0` |
| `gather` | `name=gather finished=1 cycles=265 from_fetch=234 retired=16 issue_groups=16 order=ok gpr_mismatch=0 pred_mismatch=0 mem_mismatch=0 check_failures=0 class_violations=0 overflows=0 credit_leaks=0 cor_late=0 channels_used=32/55 violations=0` |
| `hit` | `name=hit finished=1 cycles=215 from_fetch=184 retired=17 issue_groups=17 order=ok gpr_mismatch=0 pred_mismatch=0 mem_mismatch=0 check_failures=0 class_violations=0 overflows=0 credit_leaks=0 cor_late=0 channels_used=31/55 violations=0` |
| `lanectx` | `name=lanectx finished=1 cycles=70 from_fetch=39 retired=10 issue_groups=10 order=ok gpr_mismatch=0 pred_mismatch=0 mem_mismatch=0 check_failures=0 class_violations=0 overflows=0 credit_leaks=0 cor_late=0 channels_used=29/55 violations=0` |
| `lanectx2` | `name=lanectx2 finished=1 cycles=70 from_fetch=39 retired=10 issue_groups=10 order=ok gpr_mismatch=0 pred_mismatch=0 mem_mismatch=0 check_failures=0 class_violations=0 overflows=0 credit_leaks=0 cor_late=0 channels_used=29/55 violations=0` |
| `late` | `name=late finished=1 cycles=168 from_fetch=137 retired=16 issue_groups=16 order=ok gpr_mismatch=0 pred_mismatch=0 mem_mismatch=0 check_failures=0 class_violations=0 overflows=0 credit_leaks=0 cor_late=0 channels_used=31/55 violations=0` |
| `ldpar` | `name=ldpar finished=1 cycles=154 from_fetch=123 retired=17 issue_groups=17 order=ok gpr_mismatch=0 pred_mismatch=0 mem_mismatch=0 check_failures=0 class_violations=0 overflows=0 credit_leaks=0 cor_late=0 channels_used=31/55 violations=0` |
| `lnorm1` | `name=lnorm1 finished=1 cycles=2515 from_fetch=2484 retired=526 issue_groups=526 order=ok gpr_mismatch=0 pred_mismatch=0 mem_mismatch=0 check_failures=0 class_violations=0 overflows=0 credit_leaks=0 cor_late=0 channels_used=37/55 violations=0` |
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
| `rope` | `name=rope finished=1 cycles=675 from_fetch=644 retired=354 issue_groups=354 order=ok gpr_mismatch=0 pred_mismatch=0 mem_mismatch=0 check_failures=0 class_violations=0 overflows=0 credit_leaks=0 cor_late=0 channels_used=34/55 violations=0` |
| `ropediv` | `name=ropediv finished=1 cycles=973 from_fetch=942 retired=203 issue_groups=203 order=ok gpr_mismatch=0 pred_mismatch=0 mem_mismatch=0 check_failures=0 class_violations=0 overflows=0 credit_leaks=0 cor_late=0 channels_used=34/55 violations=0` |
| `sel` | `name=sel finished=1 cycles=77 from_fetch=46 retired=8 issue_groups=8 order=ok gpr_mismatch=0 pred_mismatch=0 mem_mismatch=0 check_failures=0 class_violations=0 overflows=0 credit_leaks=0 cor_late=0 channels_used=29/55 violations=0` |
| `sized` | `name=sized finished=1 cycles=985 from_fetch=954 retired=25 issue_groups=25 order=ok gpr_mismatch=0 pred_mismatch=0 mem_mismatch=0 check_failures=0 class_violations=0 overflows=0 credit_leaks=0 cor_late=0 channels_used=32/55 violations=0` |
| `slotform` | `name=slotform finished=1 cycles=4350 from_fetch=4319 retired=12 issue_groups=12 order=ok gpr_mismatch=0 pred_mismatch=0 mem_mismatch=0 check_failures=0 class_violations=0 overflows=0 credit_leaks=0 cor_late=0 channels_used=32/55 violations=0` |
| `spinwait` | `name=spinwait finished=1 cycles=1976 from_fetch=1945 retired=211 issue_groups=211 order=ok gpr_mismatch=0 pred_mismatch=0 mem_mismatch=0 check_failures=0 class_violations=0 overflows=0 credit_leaks=0 cor_late=0 channels_used=34/55 violations=0` |
| `spmbank` | `name=spmbank finished=1 cycles=186 from_fetch=155 retired=13 issue_groups=13 order=ok gpr_mismatch=0 pred_mismatch=0 mem_mismatch=0 check_failures=0 class_violations=0 overflows=0 credit_leaks=0 cor_late=0 channels_used=28/55 violations=0` |
| `srd` | `name=srd finished=1 cycles=70 from_fetch=39 retired=6 issue_groups=6 order=ok gpr_mismatch=0 pred_mismatch=0 mem_mismatch=0 check_failures=0 class_violations=0 overflows=0 credit_leaks=0 cor_late=0 channels_used=29/55 violations=0` |
| `stall` | `name=stall finished=1 cycles=556 from_fetch=525 retired=116 issue_groups=116 order=ok gpr_mismatch=0 pred_mismatch=0 mem_mismatch=0 check_failures=0 class_violations=0 overflows=0 credit_leaks=0 cor_late=0 channels_used=31/55 violations=0` |
| `swap` | `name=swap finished=1 cycles=556 from_fetch=525 retired=174 issue_groups=174 order=ok gpr_mismatch=0 pred_mismatch=0 mem_mismatch=0 check_failures=0 class_violations=0 overflows=0 credit_leaks=0 cor_late=0 channels_used=31/55 violations=0` |
| `transp4` | `name=transp4 finished=1 cycles=1123 from_fetch=1092 retired=976 issue_groups=976 order=ok gpr_mismatch=0 pred_mismatch=0 mem_mismatch=0 check_failures=0 class_violations=0 overflows=0 credit_leaks=0 cor_late=0 channels_used=37/55 violations=0` |
| `unal` | `name=unal finished=1 cycles=137 from_fetch=106 retired=9 issue_groups=9 order=ok gpr_mismatch=0 pred_mismatch=0 mem_mismatch=0 check_failures=0 class_violations=0 overflows=0 credit_leaks=0 cor_late=0 channels_used=32/55 violations=0` |
| `vadd` | `name=vadd finished=1 cycles=158 from_fetch=127 retired=17 issue_groups=17 order=ok gpr_mismatch=0 pred_mismatch=0 mem_mismatch=0 check_failures=0 class_violations=0 overflows=0 credit_leaks=0 cor_late=0 channels_used=33/55 violations=0` |
| `vadd4` | `name=vadd4 finished=1 cycles=204 from_fetch=173 retired=68 issue_groups=68 order=ok gpr_mismatch=0 pred_mismatch=0 mem_mismatch=0 check_failures=0 class_violations=0 overflows=0 credit_leaks=0 cor_late=0 channels_used=33/55 violations=0` |
| `vaddslow` | `name=vaddslow finished=1 cycles=547 from_fetch=516 retired=17 issue_groups=17 order=ok gpr_mismatch=0 pred_mismatch=0 mem_mismatch=0 check_failures=0 class_violations=0 overflows=0 credit_leaks=0 cor_late=0 channels_used=33/55 violations=0` |

## Manifest of release/

```
cb49d7360a9ed93f7524b2b21ae91ef03dced2523dca29ea0a8b944036902745  release/kernels/addrhigh.by_instr.json.gz
bbaa72c8aed3336a3cb87bfa69e42690c79f6e2bcfdd712b1a16814af11f6132  release/kernels/addrhigh.by_unit.json.gz
7f4025bfdc4a9e67d17c349cc2031239027d3a614a0080c15e41212d388f6c80  release/kernels/addrhigh.ccvtrace
d188a13da323dee296f6ad49abd1a00b75ea59792469e9b1428c440acd27f4f1  release/kernels/addrhigh.log
569f2e22883fad5f0956c57ec734e6afbdd4b8a854e50277425172d6c0cbd766  release/kernels/addrhigh.oracle.jsonl
6ea718890f6af674ac319893cda184b299a893b3415a8dee2bc0d878eb8bb1b7  release/kernels/addrhigh.sv-hosted.log
fdf05a21b8e2f633bf1762387759f685dffafe71b32f0dfe4b60ace1d1647053  release/kernels/addrlimit.by_instr.json
939d6b115a1bc45b8e75c394811a9aa84b1fb504faed4cc318d2f53cd6131e43  release/kernels/addrlimit.by_unit.json
f8287904c415dfd8f4cf0ec4a8dcdb95ef81669e365fea28a62d9f2feaa3ac8f  release/kernels/addrlimit.ccvtrace
2601caaea99b2bf4f608c2b9d2317603315571028937a17cc4314f545672835f  release/kernels/addrlimit.log
bc660b0b40359a2c5a2478cb0eb4950b73fd22db50ea76b80052bc195a1920f4  release/kernels/addrlimit.oracle.jsonl
b4a9156c7ff414ed6c96657bba551eaa17a68163d7c5505343fe5aecb003254a  release/kernels/addrlimit.sv-hosted.log
444a139be8ad3ef2636383cc788bb28ec816e5e0284123df710c7a5c06003bd5  release/kernels/addrneg.by_instr.json
cc2e8d376cbfa7fcffe6246821ac1957c7be5b157b52ec7e5b037ac37f067408  release/kernels/addrneg.by_unit.json
aaae096aee3b8e71dc063bbf880dc9562e93bac3102ea7b4a1d249bda0baa1df  release/kernels/addrneg.ccvtrace
f0e7b84ca37f444b52f48fa7d6abf472a5ccff0f7de3decc4f3c40f2961af301  release/kernels/addrneg.log
16f5b0707ae44492a1efd67bb9dd38a7e79a7bbd354fa9207b9e7d150ff2f107  release/kernels/addrneg.oracle.jsonl
e93842e5894a290d3e8b87a03c994836ec53170ea68e01b2f148716be1b0b54d  release/kernels/addrneg.sv-hosted.log
36174a43e4b119a37bb09e808e86c138db13e14c0d3f3c67081f0169c1dfb5e0  release/kernels/atom.by_instr.json.gz
d3ac8dee3205a4e3a9c94aa66f2d38174cdce5aaeaa99ed16dc57f6db4fea45f  release/kernels/atom.by_unit.json.gz
67214e5fefe2e38f320350b9f45b87cdb42d0e7d4a1a7f6072b7c57e90b8c6e2  release/kernels/atom.ccvtrace
65f76766807d3ddd308a0e8e9f05f51f6843f718a1d0818d8e3137052f06755c  release/kernels/atom.log
504f5b6e9d25114dc35f2c70b21bb7b3f3c508c691de12dc0e87d12a74285361  release/kernels/atom.oracle.jsonl
8ac02d357d7fc5bd28b86d248126ae04ed407d5275f3154669af37067eabd6b4  release/kernels/atom.sv-hosted.log
dd6b2cfaef99aafa02174951ecaed1e3a8245d832b6c721f2fd82526efcd4de3  release/kernels/atomf.by_instr.json.gz
4d63f6ac793f224295b21ae48691ce15c20f8c618c5a3d3eb2d155ade0f0fff6  release/kernels/atomf.by_unit.json.gz
098de58c0913a300162a361cc42b0f5101b06c5bd7a51f91ce63bb456800b6c2  release/kernels/atomf.ccvtrace
7ff6bc20d8fc8ad36a96b99fbeade475d42805b6c37beebeb334e422db7c183c  release/kernels/atomf.log
cfd1179edf4061a33ab2f75d7a6dec61decfe629000198189a7bfc2647b34238  release/kernels/atomf.oracle.jsonl
0a90f5cbbcc1b5d53c256e6682bf6660a23203246d8252108fb6702a9883d59f  release/kernels/atomf.sv-hosted.log
ef45926b7242b8c318059b0da9987e23451e80a5f651894185b74579e77b85cf  release/kernels/borrow.by_instr.json.gz
2a38825b9151286c504c206f72f424614e193d6c27751d1168c1d8bf594476f6  release/kernels/borrow.by_unit.json.gz
f47ba0ff76f39020aec6e50deb887c83af18cb9efde597aa3d2ebc7261eb3139  release/kernels/borrow.ccvtrace
c3d024f391d0e65117fcedb685bccadc5401855d7721ab046a343ab09a9d4bb1  release/kernels/borrow.log
4c565e1ce0b3baee36e158694b32c8defb5cd662b2f9af75cb5d8c26cb1168ed  release/kernels/borrow.oracle.jsonl
247eaaf3a3f2bc5d69ad6e3a3c91d47a4324fc351abd10577c3fb3c09c0c11f4  release/kernels/borrow.sv-hosted.log
4b142ee1f56557a08c746add5809bdff1954e707f3a47abe77a359ff2ac385d6  release/kernels/brs.by_instr.json.gz
7e9493e511dc9df2ae083010fc06ab2ea13d502def97822a6ee27b6134673be9  release/kernels/brs.by_unit.json.gz
0efbd34762b9bb839d84507973259b9161e0b6b94498eb217ab8eb280dacf7b3  release/kernels/brs.ccvtrace
fde89de0803e0cd1d0ab0f335c4ab24e713bacd0314dcbb0795f27dbe07bbadc  release/kernels/brs.log
e3c1cb3379580cf1aae44e8ddc8e846ef6fd661a573cfe0a8d4444b18a14dc56  release/kernels/brs.oracle.jsonl
f66a317db6994980d6be71f99b53eaef2a07d207f78a915838cb911acca2600a  release/kernels/brs.sv-hosted.log
99275245e73c891efc125040ffea19c2e62e47afd1bfb21a101f1c706d372614  release/kernels/byp.by_instr.json.gz
38e338e52f5219ca473b3af81df535d2edb532246b6623c66182b8e19b3a50ff  release/kernels/byp.by_unit.json.gz
d981f1490d418679982388372cc80497485d972a295ae5f1d1a60d06b0c22c67  release/kernels/byp.ccvtrace
e24483d1f6045db4572b0878fe87b7301d5c3c3fbca3efb4d1d6f5ec82aff466  release/kernels/byp.log
5a03dfa4f3603fef49f1e3639e74e34152ca3ca5ef8e41eb959f8323040fa2d5  release/kernels/byp.oracle.jsonl
d0f33c2b679b4566d44f99693cc6df211d2f52f31af8c72e44cdc598a1eb0331  release/kernels/byp.sv-hosted.log
bd8758a0b85b088b676ad7e1e2ed13c29442f852950bab0ed2791dadacb6c928  release/kernels/callret.by_instr.json.gz
55f69ad26500a66eaa31a175370b564497a838456127a7186c0023b484b33996  release/kernels/callret.by_unit.json.gz
485f5f7c964b7718cdf5f6475c30219443e9a079bfcab6718359dd789900a2c6  release/kernels/callret.ccvtrace
547fc1318d0d1c4f7a1ac5e325c26da0bc202c8a8ad51e2685b4d94b423bcb64  release/kernels/callret.log
9b1d1b50b527f732362f837250aa2f26dabf3e76e16a4794856ebd8f105635b8  release/kernels/callret.oracle.jsonl
374564bdbab54f030c718715dcdd18314d57209af94e7a1492c226e85af79a34  release/kernels/callret.sv-hosted.log
6bf6d67690ce4e17a7c8e7aab5d8a3575d8cf57d4c3b1001da43b0784b01b8fd  release/kernels/cas.by_instr.json.gz
0401866408de3ea922790d61dc59662d4c33ae898d7c28e44596413ce3618e9b  release/kernels/cas.by_unit.json.gz
df448ccfbf455fe5abd8ab9a4deac8d3b068ef26494c81dc0ebf78f22bc88684  release/kernels/cas.ccvtrace
bc653250c9c1c8826ab5d5cec08160f4dea35314b0c7d36cf76179cf6ac80358  release/kernels/cas.log
0ab31a9443336fe5d08e1a5fa5fcba3bc279b19022f7c5007908d39d8ef39536  release/kernels/cas.oracle.jsonl
bf6bb52c4eca15dfbcfc42f8fe7a6faee53327569612201b95fc082891b234a5  release/kernels/cas.sv-hosted.log
fc5f41aa3dba7389cbb1e49ed772a1bd322f4e1f5f786d3e85f2de39dc162c3f  release/kernels/chains.by_instr.json.gz
6f232d974813a7d0e75481f273a40716e1bff1ce56b83da716722c2eedb61a69  release/kernels/chains.by_unit.json.gz
b47e10902de830c337bf591bfc2daf06098880741b67957d8e8dd9c45208dc56  release/kernels/chains.ccvtrace
8d3f3d205ff9d2f9ec4b1b9153332062b1ccc2e37048430fd6fb5465c8a6adb5  release/kernels/chains.log
26a4cc5c5524c7219d8706c2582c80357dea60be9d6ffdec99dac7d0365e2264  release/kernels/chains.oracle.jsonl
72cbc02a412f4a8d01f8cf249552d37dda2b8b69c5581c36c43bb619317ade56  release/kernels/chains.sv-hosted.log
680d58853ec7a029a80297e5e87afa6bbb468cb438e12aecd24167c4894bfbdb  release/kernels/coll.by_instr.json.gz
114c0828a4bcb1adec309f830fa206626249d35dd5f63b45ca2a8216a7ba0ae8  release/kernels/coll.by_unit.json.gz
9b2defbca3a81f102a07f1fb1a9473253e58da6ab1e7375a8d81f4d1fe098bae  release/kernels/coll.ccvtrace
9a42fccf43093b9a678988d3c33fd7bade69270a538c61adff15a02b4b801fd9  release/kernels/coll.log
dd718d23c88df5dc7d92b055d8542865aa0e029118486af127312a8a578cfcbc  release/kernels/coll.oracle.jsonl
25a6594a99ad9d3854cb5a4007eeabf6e097969678debaea11bbdea3d2a0c1cd  release/kernels/coll.sv-hosted.log
647aa3adae4400f7e0ab7a1b7dc9dd55b715e7b63f664046d0af16537213793f  release/kernels/div.by_instr.json.gz
a741bc0496c1bdfa38e505fa6e7a2eb3ca5e582b9491d011f02c801c203bcc1d  release/kernels/div.by_unit.json.gz
182346c5baad147767effbea67248ccbc6e5c35582f0590ab266ce10e6e9dbc8  release/kernels/div.ccvtrace
f96c31a039f22248349177f56cc28abde17125b635030abadd5726d01dbfadbb  release/kernels/div.log
71a567b85cf85622631490187563de9a5661099c78a590adff4ed0a0c3d24c16  release/kernels/div.oracle.jsonl
c3d4dcedc56b192df2b6ad164de7e80fe1a9e45fd5631aff8ef7b02499c60464  release/kernels/div.sv-hosted.log
31f96fc3a2bdecf26439549ec3cc5c40e0fb4a29488ef052becb54e0a5075898  release/kernels/divchw.by_instr.json.gz
64d8f31f7841a456eb25707c2a70d70f1ed09ee5b516e05dddacbb7577840377  release/kernels/divchw.by_unit.json.gz
4471a48e9f9555ec3ff526316b30290fb0ff75d28588185a2a52382020681eb5  release/kernels/divchw.ccvtrace
e686e48b43b1625bb3f158f5a9ade85a9cd789adaaa348d446f1fa4007d99b8f  release/kernels/divchw.log
58a541797f7a2df0a1c7528ae6a3edec212db90c7d3eb20656806f38b5c10b3d  release/kernels/divchw.oracle.jsonl
5550ffa09fb361805af49067fe181d5d73cab3516f5549ab7c82909edc1b0988  release/kernels/divchw.sv-hosted.log
67d602783c798325a97a69de42c419c679a0ad4a92a2d1c03d599583d2a06f6f  release/kernels/divtail.by_instr.json.gz
7ba269f60a13fbd8dc1af158710edfd2a0cd0b94731844f14804dca8746e0b4d  release/kernels/divtail.by_unit.json.gz
2ade202d8c5fc071687f18239b0573f55461d1606452ff6daa16db3738442f2c  release/kernels/divtail.ccvtrace
4a032dbea80b2e7c78314abe431fc8544595ea430d15f98e405f2117d747de44  release/kernels/divtail.log
75f11a75c9b3b336e446140af4579f05b46c363a76b7aab3ec88154a07ba097d  release/kernels/divtail.oracle.jsonl
5c1255bce619d15234f894a066d09c162ce8e9385e528b0be64bc8abaaa40f2c  release/kernels/divtail.sv-hosted.log
a505d025adc2324de84848551674a4893ca5ba65caac21e28df3581dec328635  release/kernels/divtail2.by_instr.json.gz
158a09ff06834ef5a1c37f6a1d225deec7218863e80b28d7d899fcb5c4bb07e2  release/kernels/divtail2.by_unit.json.gz
e27413844716e2c50ee7f69833576c60a6fb7bc226660dfe365677c387affdcd  release/kernels/divtail2.ccvtrace
455cbb6be770850b69bd5b3ba1be7a2a27eedd5814c2e68a0b53ce98999e71ac  release/kernels/divtail2.log
b2db6b05eb6cf4a0a7677e31d0c6c2952d5cab49d353f0bb1883fe0b2a20ed14  release/kernels/divtail2.oracle.jsonl
8f1eb9309e3939472e0ff200e35ed7c620cd139bd28509062d7b64da6157ee9a  release/kernels/divtail2.sv-hosted.log
f634c829dd69a6dadc8d0f5ce33f337f02a188fa6039340fa75021cf7e855510  release/kernels/fence.by_instr.json
9275cee1e9c4b133e4e4bb4a0ac2e0643182f40990a30030c1461166209d8635  release/kernels/fence.by_unit.json.gz
937d3193ab570b47d1b195b8243ed02ee198d22a5792ddebd2ade6682955a956  release/kernels/fence.ccvtrace
e6a3f2fb6ec5d8a6d3fd2e51dc88d561d5654beca1079c310bc31c50baeefc9c  release/kernels/fence.log
d1d40317f6cf5bfb430cda1f9c0ef676609e59cabe2a11623c42ffbeca93142b  release/kernels/fence.oracle.jsonl
0c6a158994adebf68bf2a5e348b1576197c8a7ab351ce6822d08c1b3aeeeba8a  release/kernels/fence.sv-hosted.log
d7e30201d91ccbf22f2225182272db4f76b711fd7420775f3566b3184a71e96e  release/kernels/gather.by_instr.json.gz
6e1c4a3365048c22a4bcb41a6d1b21d4dc89578581a58de90bbaaa31ebe7754e  release/kernels/gather.by_unit.json.gz
579bce9756a2a49ebd6423bf0c53491401251d7e21bde54947c3723f31ce67c5  release/kernels/gather.ccvtrace
5db99c84e45b0c4f67a4a937e9cf7487a2da1e3172fa76ca9945d9f29bd5d628  release/kernels/gather.log
0413e781d8d6ff578c64eb1f800b7931e66f676d5cdabb97b94a4033e6037662  release/kernels/gather.oracle.jsonl
06cf24e2e1e4672f41cbb9364a541432460ccda784afe1088f6a611ecca3f2aa  release/kernels/gather.sv-hosted.log
229c170204fd2892f7a17d19c57e98dc5ddfddd839cc7b1c698b3ca167919ee5  release/kernels/hit.by_instr.json.gz
3c49cd1e7fcc8194040d6b6d71e157813199e9bc541b2626af007dcb4b59f2e8  release/kernels/hit.by_unit.json.gz
597cfadc23b94de41d89d5a56a23c9b9debbdf001a780374272eb2d5133e3691  release/kernels/hit.ccvtrace
9daed040f3e9532de0c428f4b76073e19c9212f4bca6375a595987dac4908bae  release/kernels/hit.log
7ba9603e0088d9164de6528f16ef6a7fa9ce5821c8c12b52cbb3734e39b9fd52  release/kernels/hit.oracle.jsonl
1827e6549465215d95bcf44462e347c74ecc78dee0c39d7eaa75c87d7a852a30  release/kernels/hit.sv-hosted.log
35ffcbf72c5dc5856ebb2831b9d0673a450c64fbc100b0b684d5d36b841da9f5  release/kernels/lanectx.by_instr.json.gz
e42a26f0b91c7209b01b1756a28724b0de6e7cce67ffba012ab441d7b05c0d3d  release/kernels/lanectx.by_unit.json.gz
bfdf212b12cc609da0b786f23ac7a775a880d9c7078d0dc1cb4ea29899191bf0  release/kernels/lanectx.ccvtrace
63907d9716f545d7b7bc0388c2f570abb6a2b5983562fe99254f8382fb376d87  release/kernels/lanectx.log
888551babf540db8e3025b82e65ca655013f93eba3c8a65689d069d52a7e6039  release/kernels/lanectx.oracle.jsonl
4a8f7de74e9279dc001da4825c42d148f71619b337591cdf6b4e52ab7162c425  release/kernels/lanectx.sv-hosted.log
0cc6a01e5d7b20f518becb29248df04d214dfc7946e10c1d05c244711957d1d0  release/kernels/lanectx2.by_instr.json.gz
9b0bcbe52e23f4dc1e9e66c4f6b0f7a80be4799175fdf5770ef701acabccf70d  release/kernels/lanectx2.by_unit.json.gz
d1c46c94b6b1d1fb2f239a45a58cc2a129820423a056374ffd66eda0640423d9  release/kernels/lanectx2.ccvtrace
2a50d44c3399be12b6677359d626a6601348f5b9863e5e102dcbf73a174016d2  release/kernels/lanectx2.log
45c13056dff5c73ed0c9ece56cc36f929bf335322193c7d5eb38710b1d1dfb02  release/kernels/lanectx2.oracle.jsonl
55bc8240b0a93101d08863a1edce133845584b1c21d7017dc64078c3d9f9147f  release/kernels/lanectx2.sv-hosted.log
214521e4eb08856c055ff5f549d3a7b20435f5f74d90d642a53db5384387e60a  release/kernels/late.by_instr.json.gz
b693a481528f108bf072a0da85c87e4de0553ead8ef2fe3e4d427dbacfa87462  release/kernels/late.by_unit.json.gz
93f58dfd71bcce521d94f02a4d2a6383df7923f6b52ef8f9af0c7695ecba0175  release/kernels/late.ccvtrace
1daa79ecbe1d5934f858a0b0addda2778ebcdd6e334221ca64fd59d83411c829  release/kernels/late.log
86084f6bd747a2cf32acbc0ebd96ebd3e4ef2d8d9e21be49e3ae49290d7927f3  release/kernels/late.oracle.jsonl
9ae7015244b23c824d12fc90010350e03d9ab3e6e95374aeeb2db1ef94686597  release/kernels/late.sv-hosted.log
0b9e65602ac3b1168a23eeecd2782539a96b2a9e1d41f2ac64eb0054cbee3509  release/kernels/ldpar.by_instr.json.gz
22a2bdcb6c0eeae42fac38796736f51e774ac21b56f4e1ec4bdf36c4ebfe71ad  release/kernels/ldpar.by_unit.json.gz
722b3b0bd4f84b30172e365d6b94c20ae6f9a6dc51fe16af1db2c1ccdedc66d1  release/kernels/ldpar.ccvtrace
29466161123b95f5461b944da79406e70878159431f7abd46955d976e3f9cc00  release/kernels/ldpar.log
8ac08538e9c807637babd61b31e340f7461878ada31f0c0b83cd66331cfaf486  release/kernels/ldpar.oracle.jsonl
03f8bbb85de4a4a4dd7d2fca50c90617363495f83d3cc6d5ce19569be64d34e7  release/kernels/ldpar.sv-hosted.log
5c5e6d4fb14aa4d39eee561bc25edefb1304f3f2139ec533093a186046190f9a  release/kernels/lnorm1.by_instr.json.gz
048073fa52a0413b2cda2e99605c4129a21ef93ec83f42c34f87d6cfe84ab6ed  release/kernels/lnorm1.by_unit.json.gz
bd93a528f262358a0d5085c0fb6ee324fe4df97ebdc0f35f512adc9840c947c8  release/kernels/lnorm1.ccvtrace
d41cf17b3d5dd0cfefabe566f2b6c87ef2f98a6f1fbe64ad94538640dbac3423  release/kernels/lnorm1.log
a8d85811af988a1b9fc00db1517300af3d93ec8e589e403d3b9113fa9e0ffc86  release/kernels/lnorm1.oracle.jsonl
712bce1ff770150aa6126b01abc72abe986573c828a1cc2cf13a98313afe3929  release/kernels/lnorm1.sv-hosted.log
ed668cc9f6867b535426ddea60b5524baeae1cbfd8c8077f146277a6b09f0503  release/kernels/localsp.by_instr.json.gz
19df53e9e56bf1f1bc9a76ae3450688e1e2e786cf82a462afdc50ad569f563f6  release/kernels/localsp.by_unit.json.gz
059709bbb46930f59c1fe5b8c2ebefc8ffbfd68ee95254593ed3b7c5f506085a  release/kernels/localsp.ccvtrace
511df7a1f716999dd53275b5cc745b3cbb87aa97a25d2ef0d3d57a2f10c478e5  release/kernels/localsp.log
55e3c9f36e7f7d38c0ddd38903aff4bb4509ae862015c592e6b937ea258042ca  release/kernels/localsp.oracle.jsonl
b78c5a21cd0723b92e3a15a5ebf21d9daa7b7c14cada8f9034244787d3c36766  release/kernels/localsp.sv-hosted.log
8b01e9038d359b5f2eda129081396a59728d778dc346ad7d660b180c0be39f02  release/kernels/loop.by_instr.json.gz
d8180d323c9d6294555adf87e589bb9f0b4f6e8a14e2b6efc76c0e816a67d3d4  release/kernels/loop.by_unit.json.gz
05599f989c0d60da6bbedde81701aa56ae1c2a56bbb878bbddeca9829b14e167  release/kernels/loop.ccvtrace
38cd3396460d72c10df25bd0ce36f34878949d68a99291e4abd3ef577e4573a6  release/kernels/loop.log
03ce5920c06c93e93516d8e53c3f7169f14e3593de204eacceffc0b8a3e32016  release/kernels/loop.oracle.jsonl
f6c907503540b6a1fef556539545df01694c267b50311717dda0a2825e7d47d8  release/kernels/loop.sv-hosted.log
ca73b8ad409ba212bde767c64e3add71dd824c8e53735c68c8b10a19e7507689  release/kernels/merge.by_instr.json.gz
37188c8109d3da81fa8ce8efa3d8b8ea65365cfe95657711ea9d1ae00dc124b0  release/kernels/merge.by_unit.json.gz
2f43408ff2d9fff8512adaa9e24aae50158636b35dd1778e07d3a003df283170  release/kernels/merge.ccvtrace
0642768dff1f7f8a9f371cdf7b183509b780fdfc50ca2791a0d3450ea9f4c845  release/kernels/merge.log
f96d28815f8756b1f5a45ded53e6170883d2dfa10f9eef0d14b8050b1318164a  release/kernels/merge.oracle.jsonl
fed2a267012c72a9b36333a87b11e1b0f2298bd00aa6bcdf80bba6d67583b6bc  release/kernels/merge.sv-hosted.log
33be73b4094cbadfe1e9e97621cde00d6c88c6f417cd2f183b891f15602055d1  release/kernels/missrun.by_instr.json.gz
c8c6d18cb7e850f35383ecf53153df8b56bdf821291cab701aa684f2f0ac1e0a  release/kernels/missrun.by_unit.json.gz
db24d680f2714f6ba755b577007c566da5cbb6d8199ef80f7238cfd6455173ff  release/kernels/missrun.ccvtrace
78a26b3f437e1fe3afb5256b2ab0d42c955f1901462b5fbead062cb4805be804  release/kernels/missrun.log
531bdaf281e5590774bd2775427f25e4cc0419cf8e3d5b6999843ffe9ef87258  release/kernels/missrun.oracle.jsonl
e539b0fcad7062bf8304299cf5d93a5cf522f1f9c6a94bd072828edb7910d5d8  release/kernels/missrun.sv-hosted.log
e53b2da1fc695a323e963edb1a1971839c9ad5a3c4a1f726442e9ca8d7588a12  release/kernels/mload.by_instr.json.gz
1bde4e83a308456c2a3ca3e5f174c5018131e9f263edda4d0f17a537627ff8af  release/kernels/mload.by_unit.json.gz
79882da1a5000197ea1770e602c7728cf915639724cfbaf1361823897ffa2e5e  release/kernels/mload.ccvtrace
9fc3bc7b25ca9569da146872a305deed1c0f2a637d7fec6129586e5bdb852452  release/kernels/mload.log
8000e477b9a95dfb9f0af964e8346acb9d36f1358fd06ffc4ff7cf599d2b8868  release/kernels/mload.oracle.jsonl
bad6659520f2681dd8e0f290a8308a227361fc7f924afec9a1fdb3dae81c39e6  release/kernels/mload.sv-hosted.log
3a9bff2e05aa5d50ac28b99158e8fc0a2067452bd961f55c70e5044576d2f781  release/kernels/mlp.by_instr.json.gz
c2739b19dbb9e955994fe476ff16ca4f258ce04a430c09879d2d4f74884866b3  release/kernels/mlp.by_unit.json.gz
44a6c1be3992aaf05a52c9c4573292650df8adef89278215be94866ccdf399c4  release/kernels/mlp.ccvtrace
91b4ef9fbec8234236cda533f0c69d6ecdf958bf0071132766743179cb18ea39  release/kernels/mlp.log
138d282f88d56c8ad648a91af0a983254b55d9fa22942c00d47b327f516a6e44  release/kernels/mlp.oracle.jsonl
26aa36b6cac612aaf4f46944ebba8f2562c9043fb42b65243578fe7a8f1c643a  release/kernels/mlp.sv-hosted.log
5114baaf7fb163b0ad3e2c9355b81a20f8da48e76e0adc97e47264f6e87fa7bc  release/kernels/mwmiss.by_instr.json.gz
f5b7f68378b53a2b735129946be5d7d3dfd2988c0e58040a96bfe9b683bbbf49  release/kernels/mwmiss.by_unit.json.gz
3c7c5c446414a8097fa212b31a8698d8c53100b6fea56b002ef7dbb232cb472d  release/kernels/mwmiss.ccvtrace
451ede22ff06e711081337a9fcc8059c0878535b8e4c6c3094d907be51350b55  release/kernels/mwmiss.log
8abe8e8997456a2a6711ee72da54d854b24e20abbdab28e4b7271c0d28418de8  release/kernels/mwmiss.oracle.jsonl
b3ee6dc1c4c414c0a212ad82597a89d118c4c4195c85ded04cb1a8c0c349265b  release/kernels/mwmiss.sv-hosted.log
d5980648ae0652b22ad61208d9eadde693a22710050963a2019c17f58c9039bd  release/kernels/narrowadd.by_instr.json.gz
7b8b2c37d907cde9eaa6dbd48b7523d0255a360c90019cf9ee76ccb7860a4f40  release/kernels/narrowadd.by_unit.json.gz
a589458c6355b0e9bbd7589bcae11dc10a6d1cac5cd0f0dda330a6d9a3dc58cd  release/kernels/narrowadd.ccvtrace
d72f59a088484011a60c4677ee6ec06af471de4c8061257966cd62d865a121b8  release/kernels/narrowadd.log
40a2cf629853dd404bb06b4a07e35abde3d12efc13f26ffe28f923daf2994574  release/kernels/narrowadd.oracle.jsonl
455657efd8241b09522b302b266284a022f46222ac3fb68533458be1545189bd  release/kernels/narrowadd.sv-hosted.log
ace7532ab3ef922e21bbb9e612abb1a1ec6d47921aebea56ac5cde1562364393  release/kernels/pguard.by_instr.json.gz
8d38808599a24d0179612406bf522dc3b385794216d668981dbe044a63bdc4f8  release/kernels/pguard.by_unit.json.gz
7ea87af30b8cfa9e54b7754dd440ef60896a0330a3e1f42f3983de79cf02bd5d  release/kernels/pguard.ccvtrace
36a8e73893e37a93d594b8ae73b09da3357a747637dd3819fbea26dea18d5caa  release/kernels/pguard.log
690e56f1cb8d97cbf67124b7dff3ad0a90cb8981814cd1709cf0cd0e035b3bd9  release/kernels/pguard.oracle.jsonl
fac141676f150943e8f563b97e29ac36e203eec2ac44284eb95c8766e1235021  release/kernels/pguard.sv-hosted.log
df758627f0d06a3a72d8a1e1a3c25aab6f74f5f4b20e39801de2b08d57bc4a0c  release/kernels/plog.by_instr.json.gz
36fcc94ca4ab75a9f227a4f590be36c45db364322be5570688702dbbc3c48340  release/kernels/plog.by_unit.json.gz
ce4aec9a797ce6e24a9082c3c4e22e4cc45d2bd6d9cf47ffadb3e8da5e251eb9  release/kernels/plog.ccvtrace
fdac345ea363af737ad946144b80db833fd50ec242049ceeb8418057a57ffad6  release/kernels/plog.log
0c99915e2da60f4670da00504a6371d7d17701d4431e733a3ff8fa98a2030d6a  release/kernels/plog.oracle.jsonl
f9ab9a405de9f1e1481a22d38809da5efa21dadab0b833c49ff1fb535feea424  release/kernels/plog.sv-hosted.log
ccc4777322dcefea7c4a00680b358d6f48a809f4b0ee4b24577e9f1a6f937a79  release/kernels/pmovdiv.by_instr.json.gz
eecacb0e0ea1f785378d6d79abbbda972f06189d22bbeb3da5561ff92c245340  release/kernels/pmovdiv.by_unit.json.gz
4fe481c67584f36b72d1f510fbace5f75fa34ca8d76713e16d393f8638f099f9  release/kernels/pmovdiv.ccvtrace
6a390bd9d495b5f2a68f393b5a0e1799379092a482f2900a3202335373391038  release/kernels/pmovdiv.log
7bc646cff6166a51bdce03d7c1b7209e871f0a91d743083a9b910a80bcd0b33f  release/kernels/pmovdiv.oracle.jsonl
65bea945ac63bc6121d380486382409475c14ad139fcac549447c195250e6b06  release/kernels/pmovdiv.sv-hosted.log
5d0987407b2a8585b448820406945260a9bafc2855722e7b82af32a9c4b45ab8  release/kernels/predlane.by_instr.json.gz
d38b4b4222b876da977c73b1c2318b96d94717b68527321fe164d7c2de7c77a1  release/kernels/predlane.by_unit.json.gz
43ffb5fd93c492e608093ee380fd91f02047a73d0d5bca90f37879a3a9b027e6  release/kernels/predlane.ccvtrace
479e3a3c99ea93e23bfe746c9f8dcd8e967aa4a4902d2fc4603d0fc5617f5de0  release/kernels/predlane.log
c45f4177b9e84fc8a6e36b13534a0c7636eb30a3f8531847100ce5e23bf404b1  release/kernels/predlane.oracle.jsonl
ae0285332ec92aa2aa1e1d221243597d449bae1ebc4b61a43bc99234de21e467  release/kernels/predlane.sv-hosted.log
e76bf21088c194c7cd3b1bbf73eb35e21a7c94d0f97b94ce240b99f4175fe09a  release/kernels/predmerge.by_instr.json.gz
67034743fc210de46abfd68753600d800a34eef59de6e19490391c0ab50e52f4  release/kernels/predmerge.by_unit.json.gz
d773aa91af7cfa2400e67801a569c10b730b800848cf39adce1a17e4661f83d2  release/kernels/predmerge.ccvtrace
0519f238adaf3a6e08771d0e2a16b56ad9c6c879708d8498869806605d09e994  release/kernels/predmerge.log
6c737c49434bcd08e3e0814c8b1dbf15c586ae74f7929ba3148ddcee2c62c845  release/kernels/predmerge.oracle.jsonl
01c3352729057c5351cec780809d5c9163935e932b17d334bc5844e489594143  release/kernels/predmerge.sv-hosted.log
606f6119fa6eea0c6bc78dc449654d95c7c261903cd29e045021db76864359c1  release/kernels/predspill.by_instr.json.gz
c129a85402d25108a56e53f13975754fc8b20cbdb7a771e47060ecd6375858c8  release/kernels/predspill.by_unit.json.gz
ef5cd45c3aca2c80a0f934209300878095623cf9fdccac71b72455d598a5cc83  release/kernels/predspill.ccvtrace
b74453365f9626a9409e6d640e53ab7e82192753459b98c362b79e73c7c443a4  release/kernels/predspill.log
b7c84c6478117ffa0f06da0e6ad1e4628e2683426a7911080810e78e06a5242e  release/kernels/predspill.oracle.jsonl
8f7fcb51cc23d06a11382a9a0b453b41311dc9998a824a76a1bf52a242a0a9e1  release/kernels/predspill.sv-hosted.log
a4e68e3dca0335a98a237cdb247a21375bd56a4e1829f346a5031c83242de8a8  release/kernels/predswap.by_instr.json.gz
e9a287899eb4a73b5f2057801febd864e90ca1eec21590750025ca5e87cbd7cf  release/kernels/predswap.by_unit.json.gz
6dde3956ce0082953ad263d923ba60c127a1dbf50b2927cd690a854dd840bac6  release/kernels/predswap.ccvtrace
69ed6f207b3cad4ac61f32b06735e6878b4f50c1802b141d303d23f863f31011  release/kernels/predswap.log
a6d4f7ed517553816d889c7c9eeb6bcfd1f6c973fbf682ecb69f3c2de619f7bb  release/kernels/predswap.oracle.jsonl
2217fe35d274ddbb55b1149b85a4500ee485f6b182516910ebdc50c16a75349e  release/kernels/predswap.sv-hosted.log
fe17fbd910857fe936574c086797270807f80d0f7c7d021b6b342c60fab4f44f  release/kernels/privwin.by_instr.json.gz
b4ce19453bd3c6cc9e8db1fade7ee33bac545757937d3af7a20323ecc14dc320  release/kernels/privwin.by_unit.json.gz
d53c8162338be0b94ef51f673abfc0f89554e08e8932971eff0d29056ca8812d  release/kernels/privwin.ccvtrace
7079891685b3eecf6e7d505c709120bf9a469665823581448d93ca8d86be2ff3  release/kernels/privwin.log
861f686fc4480363472908d679d8815e8c957d768e7ab32c826930527b0fb7a8  release/kernels/privwin.oracle.jsonl
0dc5f81ab37f13f266eba3e1ef910a53f8820d191dbc28638b4cbd9fea195840  release/kernels/privwin.sv-hosted.log
3d9589d1f269887f0fa802481cb7e05719387eff9a4f1186a30cf3b658a947b4  release/kernels/provswap.by_instr.json.gz
34db653ef3a01b406add23e5d52bd025af2aab756cd056e15eb641944bb0475e  release/kernels/provswap.by_unit.json.gz
52011821a7e778f898c918823c2e49261fea50a7278468ff0e93ab6514c207f1  release/kernels/provswap.ccvtrace
c38536ad24c43db7a89cc7345baff7e6b97972a9b5152f0120a06bfa0b2fec77  release/kernels/provswap.log
c9c32a793d54cc7401477f582487f7e8b345b2669a75337b8d6327120d98e5dc  release/kernels/provswap.oracle.jsonl
d16f696d32a9d7abe919481650121ea2f3be5942140d1138dcb0511dd3d9e2c3  release/kernels/provswap.sv-hosted.log
8456a002c9eb0fd8828f815d3c6f70f4a226742a8d28d6c085620f3d707934d5  release/kernels/retmiss.by_instr.json.gz
d61ae677bc0357e743c4629c19f2e15b536ad5bc4e65869744f2cf81bce85f46  release/kernels/retmiss.by_unit.json.gz
e01787edcae3313ceb75059412210168f0598207c4ff3b7135fd33247080941c  release/kernels/retmiss.ccvtrace
16cf0e54f6bbc6d5341141943710efe6adc74b24d9d7a8518a979e96c59dd574  release/kernels/retmiss.log
e5ef8538e838c6cff7febfc679dd091cf5e002f82d34f1009b1948ce22bc3649  release/kernels/retmiss.oracle.jsonl
f154087d58c7e0f2c30a2246dcef8e99abc78574cecbb1060821c83aef76286d  release/kernels/retmiss.sv-hosted.log
d45b064f90b496adbbbf3be694a8cc4f6af4ea41825c8bb83b0c4042da5a369a  release/kernels/roconst.by_instr.json
b38b6900712bfd3ada68a6b3627c4ea3fe521aef042fc47dd43dfb23bb1283cf  release/kernels/roconst.by_unit.json
f3713f83ec2f195b035033bdb47cfd76ef95bbcac2a975d18c8e17e3b3ccda49  release/kernels/roconst.ccvtrace
3a8dbca0fe64dc3e35a8d8b8ab3c8131a6e1fb9fe115ce6f593786597c144408  release/kernels/roconst.log
8087c0671de620162881aecd38cd6114b78e7be6bd71201e3ec02c9a2e2e750e  release/kernels/roconst.oracle.jsonl
2eb0bd76a7a1054fe0c4e05ef1b10aaeae36bcc6903b894b988e5c3d6159ec93  release/kernels/roconst.sv-hosted.log
7d213047dc11229803ff907bc5a2192cad3a16f993fe7f5ae66bdd5e6ec74442  release/kernels/rogated.by_instr.json
060263b6de3a3802760c482607986b065342b9fe34b416abb88a1031bf173988  release/kernels/rogated.by_unit.json.gz
e0022bd67a6d629144891b56607860fafa98ac1de5fa80dc411be11a44c9a890  release/kernels/rogated.ccvtrace
6ff2c0de9a74cc2c88ce562712e3c17e249f4b9bbdf2ff359bf78e9da4fcda33  release/kernels/rogated.log
7cd02bd4cceec5a044d6b4d6a80df1e68ed0ae71b0b2a953143636d5b809ea6c  release/kernels/rogated.oracle.jsonl
871f4c5e49cece605bfd4e1ec4a26c651d9fb9d7eac9f6922bd637e35b3ef130  release/kernels/rogated.sv-hosted.log
ba96088433e905d09189118c322f8efd9a17e537a19f7eb91a75c6f5ad71f38d  release/kernels/rokill.by_instr.json.gz
94253a6df6a43e1e19844e0d4ef953b615b09f3d750c87f55b7df0666ac82abb  release/kernels/rokill.by_unit.json.gz
cb434c89178bda63feb85c508e8cbd1b00bffd6b69525ab858d2b11b6cf16c17  release/kernels/rokill.ccvtrace
ea61cbe4274fdafe115b14e163dd1b38a709532704e4afc20a8bfd30b4f41add  release/kernels/rokill.log
94efcef96af469a512d346ce61623980fe86383188eaebd55120f716db596f14  release/kernels/rokill.oracle.jsonl
c07d1f0d92454aa611fdee26c1354f21b7f9f28c79a146b105b9b395ab7605ef  release/kernels/rokill.sv-hosted.log
cfe93d3d8c0978c8bb6d8f4957cbfc45e47217e240824820b472ea4200922904  release/kernels/rokilllane.by_instr.json.gz
f0ed66fd90b02e9f1a972d33d5042f1fe714559aee89be371ac1ead00824c634  release/kernels/rokilllane.by_unit.json.gz
dba628a43540510e90493dcf402203d99b3542ad6dd5a94033f0f5f1309c0d42  release/kernels/rokilllane.ccvtrace
b3c1c89ea1e6f2d421cffa5d9cf6096947f962c930ba06a48245483fac507ef8  release/kernels/rokilllane.log
f5ca6e666eff2f44894df74a291b43b3c0e7be0a63a47d795fdefd7b22016f45  release/kernels/rokilllane.oracle.jsonl
86025460bf01ee93bf79d670b0c994e7a277bc2ba7f609731b87790a29ef1f49  release/kernels/rokilllane.sv-hosted.log
f8fe604241644b224e6431d16e4fad889c99826b82f49205e4c9014b9ae62e8a  release/kernels/rolaunch.by_instr.json
12e5281971b0a06ca95d953aa22a6d6b481d8fee948f50ab777c87877757fe46  release/kernels/rolaunch.by_unit.json
32fbf77dc8fb17f0113b068b5a00568b6ea97be3ad8e5bd1c69b7cae2f04a946  release/kernels/rolaunch.ccvtrace
17eae3d99453e99b558374444cbf9f8f6c2600910a4f13fd722a13caf49fc391  release/kernels/rolaunch.log
e7dad585c3e70615de04330fd03f4f282c29a005dc1732a35655fb261d51139e  release/kernels/rolaunch.oracle.jsonl
9c2fd64eacc909e8cea9c8e060e678c805406362813c1ed4623c7012257084fa  release/kernels/rolaunch.sv-hosted.log
d45b064f90b496adbbbf3be694a8cc4f6af4ea41825c8bb83b0c4042da5a369a  release/kernels/rolimit.by_instr.json
e8822066a61bf10f59647aa7240a3044f25d2eba55ac5f7ebacbf1901974dd8f  release/kernels/rolimit.by_unit.json
0e8db555321feaf0fded659de3d7ab35b3dadb15ccef4bf8dabfaec2e87a5563  release/kernels/rolimit.ccvtrace
690b62f8e82f8a12b84214d2020eb8c2d16af9b6a6199944cc903b1f214f389e  release/kernels/rolimit.log
1c5bc0cb8e8b2e69505fb5a551a16d5d10c56f232b88da7a27e336ad7d962de2  release/kernels/rolimit.oracle.jsonl
b902033d1bd90ea2a7a19624053bb3777a07e4e863577b56da54a6f0f5bbf4a9  release/kernels/rolimit.sv-hosted.log
e90dc38930ff540b8bfcc61cb0a71a68d709e4968dd852c3a100de8e81a6a924  release/kernels/roload.by_instr.json.gz
b33ee4d3a4dfd89d6a8628528361fc5914b3638a4a557f68ca22b902ea1be039  release/kernels/roload.by_unit.json.gz
aeaec16ad191a7398d05779dae10b703ade002cfd0dc122e276602930405a40a  release/kernels/roload.ccvtrace
22ff90c31abf892048dae7d01af2653e0bba3d91f7eefdae5b1f00a17407a031  release/kernels/roload.log
f7c1309cc9764769fb5803f6fd0f2f5e1eb418f2d23fbe5e17cf5f9106869fdf  release/kernels/roload.oracle.jsonl
2aabacb84b06f9e85dc6fa37739ea129efa8c36bbcc3ab748e514f5b246d9e1c  release/kernels/roload.sv-hosted.log
2f7cc1cd0fe9b19fe54fa2978302ec8ac8ad13a4175d1d1b77b75d319da15e0b  release/kernels/rope.by_instr.json.gz
a55ec6bf11ec60c8a58baddd8b0bf285d3745eaf3f9e27aa1749086497c038ea  release/kernels/rope.by_unit.json.gz
01c05d72273a423f5463206a601cdb64c719d7094a97707467ef837b8c036602  release/kernels/rope.ccvtrace
5fdfba263e0b0cd2661b4ae962093d02b5a1c5ac10eeba1f8329407b3eed25fd  release/kernels/rope.log
d55f9efae392dc8877c102c01c0810e7654b666b6ede386328108164c6cf88f3  release/kernels/rope.oracle.jsonl
cc0f57442033839453dd64d3904cbc0d8cfc8c7039dd05f8cf68828b72618396  release/kernels/rope.sv-hosted.log
5e8daa121392a19c5fc7d02e0708cb35206c723d049c7cca56e2a29953bd6723  release/kernels/ropediv.by_instr.json.gz
8a23f00047d53f5e0fbe44a5448546a69be731a56129c2eb0a280538e070997c  release/kernels/ropediv.by_unit.json.gz
314a1adcf5bf9b94fa9b376e8492417842a1d2b334018cc1014c4df80ab63dfa  release/kernels/ropediv.ccvtrace
ac6a27099a06caf9ade548138b723475305ddbda0a8e9e3663a477ef4638d710  release/kernels/ropediv.log
10c0ec6ec18b7b44638c790033109198c079d07c1537bf193353ccedd00a920f  release/kernels/ropediv.oracle.jsonl
3f0f31296defeccafb87ccf808eddce97cc1f5a0411df880044ecca692e9188a  release/kernels/ropediv.sv-hosted.log
14793540ea9da39fc9d608303bb211c6736dc2e96019f2d354b11c046f1d2022  release/kernels/sel.by_instr.json.gz
aabd4dce43861a260466bd1473dd0687919e59ce665a03cb44a7654c0d6135d4  release/kernels/sel.by_unit.json.gz
33a33114b5167306fc24ee447399ba293a8568ed59ddc2c9e307b97a3df3638f  release/kernels/sel.ccvtrace
c9c85eb35ca8618e716376041ac183a741bb46124ed4a49d06637dca9342f8e2  release/kernels/sel.log
87f6a81e8afa004c8039bf2f61c90176fcf29ab29bb17ac44aa016a5cc8438fe  release/kernels/sel.oracle.jsonl
36a88bd0bff67134183c156e6ab25cd45438ac76c925149648c4952cda7d4b97  release/kernels/sel.sv-hosted.log
112eabd2daab4bcea2c476429a74b2e15ee43d4bc68f0aacb70c921b34d2ad75  release/kernels/sized.by_instr.json.gz
e4fabdd87001434b863c399d204b41fee904bef1193c2a04c0cc1b6e70a3648d  release/kernels/sized.by_unit.json.gz
96ab17d9315d0926a3fe12caabaecf335da5f274469ba35da2137ab19e16294a  release/kernels/sized.ccvtrace
6613b159f2e23e93daffb07ae923b058eb801746717995dfdc3d7ee04b6fcbb5  release/kernels/sized.log
36d903ba1618bd1faa437c9812a6ee6c0c966a63196c796267d74bf2695ebc3d  release/kernels/sized.oracle.jsonl
c985cb22a43ac9496b33025a88166955bff90e0a589a706c1c433898b6950eff  release/kernels/sized.sv-hosted.log
48ff57eea9252f0c0451b075e7a21c21bb48ab2de92861e7cf68c3d68d75f6fa  release/kernels/slotform.by_instr.json.gz
871fbc0db23e0f60973561ca34ef0aebdbd206fd416db0a37f50538d6a1146ae  release/kernels/slotform.by_unit.json.gz
4b489164ed494bde355d915acfca6d1c7e362baf785a511c2f9c5aa2e36d0471  release/kernels/slotform.ccvtrace
33d4c85159771243e8012d4d2802694643345bb26c9a994aa1bfc75059c5fd80  release/kernels/slotform.log
8b61db7419b18cea8a646fb628218447e72e84a18a9891ffb73b441736138ab9  release/kernels/slotform.oracle.jsonl
e815ac72040860f1ce954adb0639f1c309ccd2f9b8b387ddae0b8f10fa6a0a77  release/kernels/slotform.sv-hosted.log
81888d7a802db64517c6e92a57156671dd6f33115109f1850396ec65e77a2d34  release/kernels/spinwait.by_instr.json.gz
62bb4ba8297c20b0c5cfbc6b79172adcc93e326f62c258e9ccfb0cb4d5e649c0  release/kernels/spinwait.by_unit.json.gz
1542b9b1af9bbcf090c10f31e2ac5a965ab4fd4812810c7ed152387a80e3f9cb  release/kernels/spinwait.ccvtrace
285d630ce34fabd0d8bd1a796c7043da45033ceb5018ad55b459e80ebcfdff51  release/kernels/spinwait.log
868920637236c878b33779bd450439466fc3626996a3164573dc11d437d5c709  release/kernels/spinwait.oracle.jsonl
9c177c5b3a3b730ee5a1897f8f42288044647657ffa77babb86c53457cd13333  release/kernels/spinwait.sv-hosted.log
694c023bb559778978cec21d904d68e47d0b6bec1a609b849188862ea4d5e609  release/kernels/spmbank.by_instr.json.gz
1f9c7b87bf2eac35df900d2cec6c1a0d5342f829955332b1d687c9b713562e57  release/kernels/spmbank.by_unit.json.gz
c9e0541d73a86ace0be2c7140b58c219c67cdc59ea3c535408d630297cbaaec6  release/kernels/spmbank.ccvtrace
42557d5759bd562f8d661b42e41efe639f216a1607b0f52145012e5d8d61a576  release/kernels/spmbank.log
3af490cc37d7a92dbe719b57de216b648536eb301ff9d13de9a39f50d150d725  release/kernels/spmbank.oracle.jsonl
3ea1753182b5cadc6d5689cadf0a1edd5b23ee6d44245ecf5bcc353d1d1c8733  release/kernels/spmbank.sv-hosted.log
b39ef587cb4ff3459d5bd5e0c8b92372eeb378df32c8784ff18f3b1673bcc29b  release/kernels/srd.by_instr.json.gz
dcf4480d05e7bdaa28c40a42d2092378e8bc2e5028ea6da09cd35950941cc535  release/kernels/srd.by_unit.json.gz
f255c02a28c53c4b57a6b17bccf73852f4dfb2d06486b63be7fd69e6f3ef22dd  release/kernels/srd.ccvtrace
5e92d83bb1bef4aaf765a4b87019bbfb93e7974c037864bf12c5ee1b2ca4a90c  release/kernels/srd.log
b08eb5e3673cac7eebb8b72af5ed3783c8e70a9e96592e76bf3722551bc79473  release/kernels/srd.oracle.jsonl
81b8a725302f85e774211017dbf992278538e83a8e496f89fd98747153cb0d5a  release/kernels/srd.sv-hosted.log
c2c6bcc47f3b6bd9c732d9be39b58be9d378104b2d0f412a21bb06eb125356a6  release/kernels/stall.by_instr.json.gz
6ab18a5fdfb13ed2747175489167c9401f5039ff83a1264cd9bf43b3b5a917ea  release/kernels/stall.by_unit.json.gz
7be7622c1b3bdf30f0362f3058694550ecf66c17ded838a604d1f10d3816874e  release/kernels/stall.ccvtrace
e226193e535a7ee5074c7cd156f6b983ce594d1fb689dfef3c2395b87e60c89d  release/kernels/stall.log
500db2c482b07a0706583422cd68878301d0146c1f872ccc1f11bfdcf5c993ef  release/kernels/stall.oracle.jsonl
4229f9ad538d097bc852eace9e725ded15afd12110e1777726a628cff95386c0  release/kernels/stall.sv-hosted.log
fbd9d54ca0488442bfce9b2726d86c7668f3219b62ae810b6a9ea78285d4163d  release/kernels/swap.by_instr.json.gz
417b05c0d4d863293db8c1d5803f12c723c8588a7f320182be5bfaa797f95205  release/kernels/swap.by_unit.json.gz
03edb62824a690d4bf7f46bc9d4841c7612d9a08df8aaf6af5750971130cd3a2  release/kernels/swap.ccvtrace
94cbfab634a7e28151a3178a8c31d0e7011bde3634a665e7f6c0248b9fac4871  release/kernels/swap.log
3658a26316c1ff7bc1744304a42f736e930fcde2865c8913e6cc67a22ce96667  release/kernels/swap.oracle.jsonl
5d7da13534fff820513296ca6619b00ff80e005a7b3d53c0581569b5e4d8de60  release/kernels/swap.sv-hosted.log
c456c82a64f0fc5f175bc042ab0f5deb0bf48d2b7bbb6283b5ce9df5c3c5ea1f  release/kernels/transp4.by_instr.json.gz
71ed3669dc485191afaa02da14629418c0d0f715d250db641e08c28d086b7525  release/kernels/transp4.by_unit.json.gz
42420d45bcd9f832fbda0212608f9f12d023ad5855373035414c976b969d7d47  release/kernels/transp4.ccvtrace
969ac423919f32b7c07f2649f164171dd9bc8e049af25e92a0952234af28e7f9  release/kernels/transp4.log
06396ace3ac19677fd39c700e408606e5bdbacb24997d663bbe8872e63dd74fc  release/kernels/transp4.oracle.jsonl
926b7e8c28a1bc372d0538da377fda46a9f1f9858601ccaddf7f3c4b10b9f1a4  release/kernels/transp4.sv-hosted.log
2e5a1be6c01f47cc11dc78e3c6292ca876ad8bb8b0f8763266f69b5c09e0277e  release/kernels/unal.by_instr.json.gz
a41cf6c4e78d2c5106b2dd4ea94a6a9ac575008997e609776c37f6f2d9e6b7f6  release/kernels/unal.by_unit.json.gz
f0cc8a6483da7e1547d81822745f9513824861f37c3e59f25922c8df4895b09b  release/kernels/unal.ccvtrace
73cef6003f06c7a06cbd8dff05d46e32447275d222a44b380e6553a28d48edef  release/kernels/unal.log
c3d484bb160657a563df983d9a2532eac27f556636617960aa1e72183ac2b299  release/kernels/unal.oracle.jsonl
f9e4603284d2867ef3e965d26a4f48c1340f11b960e300e62b36abd1cc8a2435  release/kernels/unal.sv-hosted.log
ac1b044dbf0ebfdbf0585bc7581a5c3e0c3b4b1978d28511e19bb7600f214736  release/kernels/vadd.by_instr.json.gz
7806e43fed392b9479673b845b33f755aa06eb3d7559658e31af1ee70d112d3f  release/kernels/vadd.by_unit.json.gz
825febc1f9a8bc5b55bb674ac0be9eac9ba860f1958becaca4d396290e4eefb3  release/kernels/vadd.ccvtrace
ff777e4dbfa68b04069d091254550c7725243e226258bbc7e172ba2368e65ff2  release/kernels/vadd.log
0276b6d0611a4bbcdc004ab3987214aea138245bc7217504147331689a9c0880  release/kernels/vadd.oracle.jsonl
a4f33d931962d782137395899fa97259015f62a1b719cde9cc06dfe9396faa70  release/kernels/vadd.sv-hosted.log
3dc7847276297adcde96381a09ad41d88437ea40bc2dca909619cedb09dc2efc  release/kernels/vadd4.by_instr.json.gz
ef90f85f2cd15d7bf1aee4912eba655f10a12e4260433f8cfd19d50e4366ff90  release/kernels/vadd4.by_unit.json.gz
9960fe139d35d9d668e0051597af8d273d43e895a52869c29d53b486d2556f84  release/kernels/vadd4.ccvtrace
98e3343895e84c51d61f86434920c2649e1bbb7ed5a42311fdb5698afd73803e  release/kernels/vadd4.log
225aa18fc9f38aa9ad615aa11de254337d59fa705877553d873062c68366e0db  release/kernels/vadd4.oracle.jsonl
c05fee6e68006fb72887071850f6736611addd9dd333f15f896bfa73af100114  release/kernels/vadd4.sv-hosted.log
ea0219000cc483bef10544da2311ba0895d36f837a0009f5a7bc67a1cf875e63  release/kernels/vaddslow.by_instr.json.gz
91007b330d65a2292cc4b8321a268b77e6dc859dae7eafd653cca22df8c07f03  release/kernels/vaddslow.by_unit.json.gz
d87344fe4eb495874c5458634e18751f8cf89c534e99fde16c9d9771b54ae8b2  release/kernels/vaddslow.ccvtrace
d633b387442348f4a78b6110c450afa6abfcba8427cc163b7e8ac91310f4bbb2  release/kernels/vaddslow.log
e9e6218e8b8450e9f9ff6b39d659c994a1e51c527a0c5bd10d18b5658ae0e344  release/kernels/vaddslow.oracle.jsonl
fbbab172e6762e01cb37249845f0ce99ffc29a73d735551fad5249456f61dc90  release/kernels/vaddslow.sv-hosted.log
92bb97372bac6c01f76e5cefd6282d2d90c40df1d6c70121a21df631cee30c64  release/verify.log
56b3d8627d79d397ca06dfb57060015391cb95e52e925d1f09a4b2a7f4147127  release/wiring.txt
```
