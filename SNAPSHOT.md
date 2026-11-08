# Snapshot snapshot-2026-11-08-fd3b0aa

**A generated, read-only snapshot. Do not edit or merge it.** The source
is `ccr-9eb50716-lecnjf` at `fd3b0aace281df871c731968f9646ae06baad411`, and this branch is rebuilt from source by
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
| Source | `ccr-9eb50716-lecnjf` @ `fd3b0aace281df871c731968f9646ae06baad411` |
| Built | 2026-11-08 (UTC) |
| Gate | `tools/verify.sh`: PASS |
| Compiler snapshot | custom-cuda-complier `release` @ `e533ecdfabd1aa267e4cffd49a4d7e1e8c13b263` (source `45ce995c923e7267feb71d87f8f9c5edfefcf0df`) |
| Verilator | Verilator 5.052 2026-09-05 rev v5.052 |
| Icarus | Icarus Verilog version 12.0 (stable) () |
| Yosys | Yosys 0.33 (git sha1 2584903a060) |

## Kernels

| Kernel | Result |
|---|---|
| `addrhigh` | `name=addrhigh finished=1 cycles=85 from_fetch=54 retired=5 issue_groups=6 order=ok gpr_mismatch=0 pred_mismatch=0 mem_mismatch=0 check_failures=0 class_violations=0 overflows=0 credit_leaks=0 cor_late=0 channels_used=26/55 violations=0` |
| `addrlimit` | `name=addrlimit finished=1 cycles=1073 from_fetch=1042 retired=5 issue_groups=5 order=ok gpr_mismatch=0 pred_mismatch=0 mem_mismatch=0 check_failures=0 class_violations=0 overflows=0 credit_leaks=0 cor_late=0 channels_used=27/55 violations=0` |
| `addrneg` | `name=addrneg finished=1 cycles=85 from_fetch=54 retired=1 issue_groups=2 order=ok gpr_mismatch=0 pred_mismatch=0 mem_mismatch=0 check_failures=0 class_violations=0 overflows=0 credit_leaks=0 cor_late=0 channels_used=23/55 violations=0` |
| `atom` | `name=atom finished=1 cycles=8235 from_fetch=8204 retired=29 issue_groups=29 order=ok gpr_mismatch=0 pred_mismatch=0 mem_mismatch=0 check_failures=0 class_violations=0 overflows=0 credit_leaks=0 cor_late=0 channels_used=32/55 violations=0` |
| `atomf` | `name=atomf finished=1 cycles=4555 from_fetch=4524 retired=12 issue_groups=12 order=ok gpr_mismatch=0 pred_mismatch=0 mem_mismatch=0 check_failures=0 class_violations=0 overflows=0 credit_leaks=0 cor_late=0 channels_used=34/55 violations=0` |
| `borrow` | `name=borrow finished=1 cycles=102 from_fetch=71 retired=7 issue_groups=7 order=ok gpr_mismatch=0 pred_mismatch=0 mem_mismatch=0 check_failures=0 class_violations=0 overflows=0 credit_leaks=0 cor_late=0 channels_used=21/55 violations=0` |
| `brs` | `name=brs finished=1 cycles=102 from_fetch=71 retired=12 issue_groups=12 order=ok gpr_mismatch=0 pred_mismatch=0 mem_mismatch=0 check_failures=0 class_violations=0 overflows=0 credit_leaks=0 cor_late=0 channels_used=23/55 violations=0` |
| `byp` | `name=byp finished=1 cycles=120 from_fetch=89 retired=14 issue_groups=14 order=ok gpr_mismatch=0 pred_mismatch=0 mem_mismatch=0 check_failures=0 class_violations=0 overflows=0 credit_leaks=0 cor_late=0 channels_used=31/55 violations=0` |
| `callret` | `name=callret finished=1 cycles=276 from_fetch=245 retired=40 issue_groups=40 order=ok gpr_mismatch=0 pred_mismatch=0 mem_mismatch=0 check_failures=0 class_violations=0 overflows=0 credit_leaks=0 cor_late=0 channels_used=30/55 violations=0` |
| `cas` | `name=cas finished=1 cycles=6792 from_fetch=6761 retired=56 issue_groups=56 order=ok gpr_mismatch=0 pred_mismatch=0 mem_mismatch=0 check_failures=0 class_violations=0 overflows=0 credit_leaks=0 cor_late=0 channels_used=32/55 violations=0` |
| `chains` | `name=chains finished=1 cycles=97 from_fetch=66 retired=29 issue_groups=29 order=ok gpr_mismatch=0 pred_mismatch=0 mem_mismatch=0 check_failures=0 class_violations=0 overflows=0 credit_leaks=0 cor_late=0 channels_used=21/55 violations=0` |
| `coll` | `name=coll finished=1 cycles=79 from_fetch=48 retired=24 issue_groups=24 order=ok gpr_mismatch=0 pred_mismatch=0 mem_mismatch=0 check_failures=0 class_violations=0 overflows=0 credit_leaks=0 cor_late=0 channels_used=21/55 violations=0` |
| `div` | `name=div finished=1 cycles=1012 from_fetch=981 retired=144 issue_groups=144 order=ok gpr_mismatch=0 pred_mismatch=0 mem_mismatch=0 check_failures=0 class_violations=0 overflows=0 credit_leaks=0 cor_late=0 channels_used=23/55 violations=0` |
| `divchw` | `name=divchw finished=1 cycles=115 from_fetch=84 retired=5 issue_groups=6 order=ok gpr_mismatch=0 pred_mismatch=0 mem_mismatch=0 check_failures=0 class_violations=0 overflows=0 credit_leaks=0 cor_late=0 channels_used=22/55 violations=0` |
| `divtail` | `name=divtail finished=1 cycles=664 from_fetch=633 retired=96 issue_groups=96 order=ok gpr_mismatch=0 pred_mismatch=0 mem_mismatch=0 check_failures=0 class_violations=0 overflows=0 credit_leaks=0 cor_late=0 channels_used=23/55 violations=0` |
| `divtail2` | `name=divtail2 finished=1 cycles=1570 from_fetch=1539 retired=366 issue_groups=366 order=ok gpr_mismatch=0 pred_mismatch=0 mem_mismatch=0 check_failures=0 class_violations=0 overflows=0 credit_leaks=0 cor_late=0 channels_used=23/55 violations=0` |
| `fence` | `name=fence finished=1 cycles=84 from_fetch=53 retired=7 issue_groups=7 order=ok gpr_mismatch=0 pred_mismatch=0 mem_mismatch=0 check_failures=0 class_violations=0 overflows=0 credit_leaks=0 cor_late=0 channels_used=30/55 violations=0` |
| `gather` | `name=gather finished=1 cycles=268 from_fetch=237 retired=16 issue_groups=16 order=ok gpr_mismatch=0 pred_mismatch=0 mem_mismatch=0 check_failures=0 class_violations=0 overflows=0 credit_leaks=0 cor_late=0 channels_used=31/55 violations=0` |
| `hit` | `name=hit finished=1 cycles=234 from_fetch=203 retired=17 issue_groups=17 order=ok gpr_mismatch=0 pred_mismatch=0 mem_mismatch=0 check_failures=0 class_violations=0 overflows=0 credit_leaks=0 cor_late=0 channels_used=31/55 violations=0` |
| `lanectx` | `name=lanectx finished=1 cycles=71 from_fetch=40 retired=10 issue_groups=10 order=ok gpr_mismatch=0 pred_mismatch=0 mem_mismatch=0 check_failures=0 class_violations=0 overflows=0 credit_leaks=0 cor_late=0 channels_used=29/55 violations=0` |
| `lanectx2` | `name=lanectx2 finished=1 cycles=71 from_fetch=40 retired=10 issue_groups=10 order=ok gpr_mismatch=0 pred_mismatch=0 mem_mismatch=0 check_failures=0 class_violations=0 overflows=0 credit_leaks=0 cor_late=0 channels_used=29/55 violations=0` |
| `late` | `name=late finished=1 cycles=175 from_fetch=144 retired=16 issue_groups=16 order=ok gpr_mismatch=0 pred_mismatch=0 mem_mismatch=0 check_failures=0 class_violations=0 overflows=0 credit_leaks=0 cor_late=0 channels_used=31/55 violations=0` |
| `ldpar` | `name=ldpar finished=1 cycles=157 from_fetch=126 retired=17 issue_groups=17 order=ok gpr_mismatch=0 pred_mismatch=0 mem_mismatch=0 check_failures=0 class_violations=0 overflows=0 credit_leaks=0 cor_late=0 channels_used=31/55 violations=0` |
| `lnorm1` | `name=lnorm1 finished=1 cycles=2571 from_fetch=2540 retired=526 issue_groups=526 order=ok gpr_mismatch=0 pred_mismatch=0 mem_mismatch=0 check_failures=0 class_violations=0 overflows=0 credit_leaks=0 cor_late=0 channels_used=37/55 violations=0` |
| `localsp` | `name=localsp finished=1 cycles=2178 from_fetch=2147 retired=40 issue_groups=40 order=ok gpr_mismatch=0 pred_mismatch=0 mem_mismatch=0 check_failures=0 class_violations=0 overflows=0 credit_leaks=0 cor_late=0 channels_used=31/55 violations=0` |
| `loop` | `name=loop finished=1 cycles=2942 from_fetch=2911 retired=407 issue_groups=407 order=ok gpr_mismatch=0 pred_mismatch=0 mem_mismatch=0 check_failures=0 class_violations=0 overflows=0 credit_leaks=0 cor_late=0 channels_used=23/55 violations=0` |
| `merge` | `name=merge finished=1 cycles=72 from_fetch=41 retired=9 issue_groups=9 order=ok gpr_mismatch=0 pred_mismatch=0 mem_mismatch=0 check_failures=0 class_violations=0 overflows=0 credit_leaks=0 cor_late=0 channels_used=21/55 violations=0` |
| `missrun` | `name=missrun finished=1 cycles=123 from_fetch=92 retired=28 issue_groups=28 order=ok gpr_mismatch=0 pred_mismatch=0 mem_mismatch=0 check_failures=0 class_violations=0 overflows=0 credit_leaks=0 cor_late=0 channels_used=31/55 violations=0` |
| `mload` | `name=mload finished=1 cycles=113 from_fetch=82 retired=11 issue_groups=11 order=ok gpr_mismatch=0 pred_mismatch=0 mem_mismatch=0 check_failures=0 class_violations=0 overflows=0 credit_leaks=0 cor_late=0 channels_used=31/55 violations=0` |
| `mlp` | `name=mlp finished=1 cycles=128 from_fetch=97 retired=21 issue_groups=21 order=ok gpr_mismatch=0 pred_mismatch=0 mem_mismatch=0 check_failures=0 class_violations=0 overflows=0 credit_leaks=0 cor_late=0 channels_used=31/55 violations=0` |
| `mwmiss` | `name=mwmiss finished=1 cycles=131 from_fetch=100 retired=88 issue_groups=88 order=ok gpr_mismatch=0 pred_mismatch=0 mem_mismatch=0 check_failures=0 class_violations=0 overflows=0 credit_leaks=0 cor_late=0 channels_used=31/55 violations=0` |
| `narrowadd` | `name=narrowadd finished=1 cycles=237 from_fetch=206 retired=21 issue_groups=21 order=ok gpr_mismatch=0 pred_mismatch=0 mem_mismatch=0 check_failures=0 class_violations=0 overflows=0 credit_leaks=0 cor_late=0 channels_used=32/55 violations=0` |
| `pguard` | `name=pguard finished=1 cycles=88 from_fetch=57 retired=12 issue_groups=12 order=ok gpr_mismatch=0 pred_mismatch=0 mem_mismatch=0 check_failures=0 class_violations=0 overflows=0 credit_leaks=0 cor_late=0 channels_used=29/55 violations=0` |
| `plog` | `name=plog finished=1 cycles=72 from_fetch=41 retired=11 issue_groups=11 order=ok gpr_mismatch=0 pred_mismatch=0 mem_mismatch=0 check_failures=0 class_violations=0 overflows=0 credit_leaks=0 cor_late=0 channels_used=21/55 violations=0` |
| `pmovdiv` | `name=pmovdiv finished=1 cycles=107 from_fetch=76 retired=12 issue_groups=12 order=ok gpr_mismatch=0 pred_mismatch=0 mem_mismatch=0 check_failures=0 class_violations=0 overflows=0 credit_leaks=0 cor_late=0 channels_used=22/55 violations=0` |
| `predlane` | `name=predlane finished=1 cycles=930 from_fetch=899 retired=10 issue_groups=10 order=ok gpr_mismatch=0 pred_mismatch=0 mem_mismatch=0 check_failures=0 class_violations=0 overflows=0 credit_leaks=0 cor_late=0 channels_used=31/55 violations=0` |
| `predmerge` | `name=predmerge finished=1 cycles=943 from_fetch=912 retired=9 issue_groups=9 order=ok gpr_mismatch=0 pred_mismatch=0 mem_mismatch=0 check_failures=0 class_violations=0 overflows=0 credit_leaks=0 cor_late=0 channels_used=33/55 violations=0` |
| `predspill` | `name=predspill finished=1 cycles=970 from_fetch=939 retired=12 issue_groups=12 order=ok gpr_mismatch=0 pred_mismatch=0 mem_mismatch=0 check_failures=0 class_violations=0 overflows=0 credit_leaks=0 cor_late=0 channels_used=31/55 violations=0` |
| `predswap` | `name=predswap finished=1 cycles=1194 from_fetch=1163 retired=46 issue_groups=46 order=ok gpr_mismatch=0 pred_mismatch=0 mem_mismatch=0 check_failures=0 class_violations=0 overflows=0 credit_leaks=0 cor_late=0 channels_used=33/55 violations=0` |
| `privwin` | `name=privwin finished=1 cycles=1164 from_fetch=1133 retired=52 issue_groups=52 order=ok gpr_mismatch=0 pred_mismatch=0 mem_mismatch=0 check_failures=0 class_violations=0 overflows=0 credit_leaks=0 cor_late=0 channels_used=34/55 violations=0` |
| `provswap` | `name=provswap finished=1 cycles=2357 from_fetch=2326 retired=978 issue_groups=978 order=ok gpr_mismatch=0 pred_mismatch=0 mem_mismatch=0 check_failures=0 class_violations=0 overflows=0 credit_leaks=0 cor_late=0 channels_used=33/55 violations=0` |
| `retmiss` | `name=retmiss finished=1 cycles=189 from_fetch=158 retired=19 issue_groups=19 order=ok gpr_mismatch=0 pred_mismatch=0 mem_mismatch=0 check_failures=0 class_violations=0 overflows=0 credit_leaks=0 cor_late=0 channels_used=33/55 violations=0` |
| `roconst` | `name=roconst finished=1 cycles=78 from_fetch=47 retired=4 issue_groups=5 order=ok gpr_mismatch=0 pred_mismatch=0 mem_mismatch=0 check_failures=0 class_violations=0 overflows=0 credit_leaks=0 cor_late=0 channels_used=26/55 violations=0` |
| `rogated` | `name=rogated finished=1 cycles=99 from_fetch=68 retired=7 issue_groups=8 order=ok gpr_mismatch=0 pred_mismatch=0 mem_mismatch=0 check_failures=0 class_violations=0 overflows=0 credit_leaks=0 cor_late=0 channels_used=26/55 violations=0` |
| `rokill` | `name=rokill finished=1 cycles=107 from_fetch=76 retired=41 issue_groups=4536 order=ok gpr_mismatch=0 pred_mismatch=0 mem_mismatch=0 check_failures=0 class_violations=0 overflows=0 credit_leaks=0 cor_late=0 channels_used=27/55 violations=0` |
| `rolaunch` | `name=rolaunch finished=1 cycles=76 from_fetch=45 retired=4 issue_groups=5 order=ok gpr_mismatch=0 pred_mismatch=0 mem_mismatch=0 check_failures=0 class_violations=0 overflows=0 credit_leaks=0 cor_late=0 channels_used=24/55 violations=0` |
| `rolimit` | `name=rolimit finished=1 cycles=78 from_fetch=47 retired=4 issue_groups=5 order=ok gpr_mismatch=0 pred_mismatch=0 mem_mismatch=0 check_failures=0 class_violations=0 overflows=0 credit_leaks=0 cor_late=0 channels_used=26/55 violations=0` |
| `roload` | `name=roload finished=1 cycles=107 from_fetch=76 retired=8 issue_groups=8 order=ok gpr_mismatch=0 pred_mismatch=0 mem_mismatch=0 check_failures=0 class_violations=0 overflows=0 credit_leaks=0 cor_late=0 channels_used=31/55 violations=0` |
| `rope` | `name=rope finished=1 cycles=688 from_fetch=657 retired=354 issue_groups=354 order=ok gpr_mismatch=0 pred_mismatch=0 mem_mismatch=0 check_failures=0 class_violations=0 overflows=0 credit_leaks=0 cor_late=0 channels_used=34/55 violations=0` |
| `ropediv` | `name=ropediv finished=1 cycles=1042 from_fetch=1011 retired=203 issue_groups=203 order=ok gpr_mismatch=0 pred_mismatch=0 mem_mismatch=0 check_failures=0 class_violations=0 overflows=0 credit_leaks=0 cor_late=0 channels_used=34/55 violations=0` |
| `sel` | `name=sel finished=1 cycles=78 from_fetch=47 retired=8 issue_groups=8 order=ok gpr_mismatch=0 pred_mismatch=0 mem_mismatch=0 check_failures=0 class_violations=0 overflows=0 credit_leaks=0 cor_late=0 channels_used=29/55 violations=0` |
| `sized` | `name=sized finished=1 cycles=998 from_fetch=967 retired=25 issue_groups=25 order=ok gpr_mismatch=0 pred_mismatch=0 mem_mismatch=0 check_failures=0 class_violations=0 overflows=0 credit_leaks=0 cor_late=0 channels_used=32/55 violations=0` |
| `slotform` | `name=slotform finished=1 cycles=4372 from_fetch=4341 retired=12 issue_groups=12 order=ok gpr_mismatch=0 pred_mismatch=0 mem_mismatch=0 check_failures=0 class_violations=0 overflows=0 credit_leaks=0 cor_late=0 channels_used=32/55 violations=0` |
| `spinwait` | `name=spinwait finished=1 cycles=2212 from_fetch=2181 retired=211 issue_groups=211 order=ok gpr_mismatch=0 pred_mismatch=0 mem_mismatch=0 check_failures=0 class_violations=0 overflows=0 credit_leaks=0 cor_late=0 channels_used=34/55 violations=0` |
| `spmbank` | `name=spmbank finished=1 cycles=187 from_fetch=156 retired=13 issue_groups=13 order=ok gpr_mismatch=0 pred_mismatch=0 mem_mismatch=0 check_failures=0 class_violations=0 overflows=0 credit_leaks=0 cor_late=0 channels_used=28/55 violations=0` |
| `srd` | `name=srd finished=1 cycles=71 from_fetch=40 retired=6 issue_groups=6 order=ok gpr_mismatch=0 pred_mismatch=0 mem_mismatch=0 check_failures=0 class_violations=0 overflows=0 credit_leaks=0 cor_late=0 channels_used=29/55 violations=0` |
| `stall` | `name=stall finished=1 cycles=559 from_fetch=528 retired=116 issue_groups=116 order=ok gpr_mismatch=0 pred_mismatch=0 mem_mismatch=0 check_failures=0 class_violations=0 overflows=0 credit_leaks=0 cor_late=0 channels_used=31/55 violations=0` |
| `swap` | `name=swap finished=1 cycles=559 from_fetch=528 retired=174 issue_groups=174 order=ok gpr_mismatch=0 pred_mismatch=0 mem_mismatch=0 check_failures=0 class_violations=0 overflows=0 credit_leaks=0 cor_late=0 channels_used=31/55 violations=0` |
| `transp4` | `name=transp4 finished=1 cycles=1163 from_fetch=1132 retired=976 issue_groups=976 order=ok gpr_mismatch=0 pred_mismatch=0 mem_mismatch=0 check_failures=0 class_violations=0 overflows=0 credit_leaks=0 cor_late=0 channels_used=37/55 violations=0` |
| `unal` | `name=unal finished=1 cycles=139 from_fetch=108 retired=9 issue_groups=9 order=ok gpr_mismatch=0 pred_mismatch=0 mem_mismatch=0 check_failures=0 class_violations=0 overflows=0 credit_leaks=0 cor_late=0 channels_used=31/55 violations=0` |
| `vadd` | `name=vadd finished=1 cycles=161 from_fetch=130 retired=17 issue_groups=17 order=ok gpr_mismatch=0 pred_mismatch=0 mem_mismatch=0 check_failures=0 class_violations=0 overflows=0 credit_leaks=0 cor_late=0 channels_used=33/55 violations=0` |
| `vadd4` | `name=vadd4 finished=1 cycles=212 from_fetch=181 retired=68 issue_groups=68 order=ok gpr_mismatch=0 pred_mismatch=0 mem_mismatch=0 check_failures=0 class_violations=0 overflows=0 credit_leaks=0 cor_late=0 channels_used=33/55 violations=0` |
| `vaddslow` | `name=vaddslow finished=1 cycles=550 from_fetch=519 retired=17 issue_groups=17 order=ok gpr_mismatch=0 pred_mismatch=0 mem_mismatch=0 check_failures=0 class_violations=0 overflows=0 credit_leaks=0 cor_late=0 channels_used=33/55 violations=0` |

## Manifest of release/

```
ff8d9f14d7d652be1961e75609d3c7e15e317a6c9a023949ac7dbaee8c652388  release/kernels/addrhigh.by_instr.json.gz
87418c153efc8628e2ebd5bf2bf1342ae72bce8d91f0b2f93b725936e9ad4fef  release/kernels/addrhigh.by_unit.json.gz
3d57c3c80bdfe50a4f4dddf680df2ce49109f79739b331fb5ad3d5be4d1574bf  release/kernels/addrhigh.ccvtrace
a48f60a52fe5aeb1903a9e9c15d71416ce11534e592ff18187c35823bb640ddf  release/kernels/addrhigh.log
569f2e22883fad5f0956c57ec734e6afbdd4b8a854e50277425172d6c0cbd766  release/kernels/addrhigh.oracle.jsonl
a20dee4a8273ae2f33c81b5e0a31f05d48f6e0a2d80a3f76823295ba2d217d9d  release/kernels/addrhigh.sv-hosted.log
a70a1f0b1e0fc13b6caf8e317c8dbd513b56bc89775267abdd5954509df4804f  release/kernels/addrlimit.by_instr.json
381b6d70a34fdb58940ef08a7a620b70043ecacf61360a9e3e493503ee75a82f  release/kernels/addrlimit.by_unit.json
63c9132a847bbb7ec335d8b0f8f4eb6e7e913f2285cbbec90e3156bc1d2ec1ee  release/kernels/addrlimit.ccvtrace
132cad1c1478cabda86d0ef8c48a283e33826bd7a8f6c8a7a18639cc02a46ce9  release/kernels/addrlimit.log
bc660b0b40359a2c5a2478cb0eb4950b73fd22db50ea76b80052bc195a1920f4  release/kernels/addrlimit.oracle.jsonl
d3dab5f70d669f739678e70740e330074e1a9bae566f089d7c536e9394c43c6d  release/kernels/addrlimit.sv-hosted.log
a9c40fd6bc1ee0d6d95d07476f2267cddf922b0acc400e3d0629ccf8bc6630de  release/kernels/addrneg.by_instr.json
b7d07e2708e4774f5675a44cc0563eb285d2334436b9e9a72711a209945dc55e  release/kernels/addrneg.by_unit.json
309ee6ff1f874ddaf8d6be29bf6462a355d1c6025ab957e1e9adedc9ea4d5ded  release/kernels/addrneg.ccvtrace
37c8e2005c543571b0e4a313cf2e9d48d61c07d52d2dac1560006745722ae274  release/kernels/addrneg.log
16f5b0707ae44492a1efd67bb9dd38a7e79a7bbd354fa9207b9e7d150ff2f107  release/kernels/addrneg.oracle.jsonl
89bc64bc1263b9c0979b446ee2039f5138d2b2b2c15adce70f8d507393d57f27  release/kernels/addrneg.sv-hosted.log
293758adce47996ca26fb77a08145aeeb6d853c33a315698dbcc7557edebc635  release/kernels/atom.by_instr.json.gz
496158e5f930fe7fd0d67ede8b92d4bd63eb99f4b7295c7a08ac559c67c92694  release/kernels/atom.by_unit.json.gz
13d902754ab7c74ab69b53ff6a14d44ecc662abccc680a31dfe8d1ecdaee0a46  release/kernels/atom.ccvtrace
a5333781c2a12e17c19fec8b3f7a9b1f4448d0dd205e0d293754b60c73436617  release/kernels/atom.log
504f5b6e9d25114dc35f2c70b21bb7b3f3c508c691de12dc0e87d12a74285361  release/kernels/atom.oracle.jsonl
41ec4fc93be6ee67035e848591150009bf08ce1fff72eac20fa3f77d220f6957  release/kernels/atom.sv-hosted.log
c9e82f599a8f4615ce8947ae7e259237b211fbe7f8ac444e679b9f1c9a92926e  release/kernels/atomf.by_instr.json.gz
9338fed03154bb0a12c201dc9c519beb47fa7f9de8dfa8db5d388ced750fb536  release/kernels/atomf.by_unit.json.gz
5cb9207ab0a723e18be2aa58e551285f9abdd1964160e7f806bc33b6fb701c7f  release/kernels/atomf.ccvtrace
09c4661b54ab487a59fd41091b2574ce6b82b01fd9dc37b938045985d6cd1275  release/kernels/atomf.log
cfd1179edf4061a33ab2f75d7a6dec61decfe629000198189a7bfc2647b34238  release/kernels/atomf.oracle.jsonl
792a7863c5a66c17da8a93acbc97191c0a4d9cb7b18e5fa24a2ff1fc5838ec64  release/kernels/atomf.sv-hosted.log
920b1de573e05bdf29c452e9227dec272af9c6228c84124fecee90408542bee9  release/kernels/borrow.by_instr.json.gz
f2b51243b3766221d9e6ef7c6ff99d215f832465e6247a3e3e731dba17215b5d  release/kernels/borrow.by_unit.json.gz
a88323798cead36e6bd43ca98678dc3c9aa1918feeccff6885d3d7052d79cc97  release/kernels/borrow.ccvtrace
5c4e960613f628bdcbb3b2cd4afdab6969163cc40396196600635d240681016a  release/kernels/borrow.log
4c565e1ce0b3baee36e158694b32c8defb5cd662b2f9af75cb5d8c26cb1168ed  release/kernels/borrow.oracle.jsonl
d112771fb5fcc181d1f0c16aa513e9d91af08fe1358073d2936c959ad19eca26  release/kernels/borrow.sv-hosted.log
385d362985b83a2814a229c08460bd287a7057b2ffd9aaa71dcc193562a77add  release/kernels/brs.by_instr.json.gz
1326f064301a8ce1420c6a81261262703b9a5e62921e9b6f411ec5ee70b028fd  release/kernels/brs.by_unit.json.gz
af1e3498d7888615659f600c29df6585e76cbfc3cc6e3255f0b3c5435d60aee3  release/kernels/brs.ccvtrace
96922277877cec0a6d39c713dfdf0ee50c12ea887c506b744291bf5838ad24a0  release/kernels/brs.log
e3c1cb3379580cf1aae44e8ddc8e846ef6fd661a573cfe0a8d4444b18a14dc56  release/kernels/brs.oracle.jsonl
c3aef7b1a4e4ee61c51a9573d88fa922ec30ad097d0bf8b1e07da8d02707b161  release/kernels/brs.sv-hosted.log
f9c3d6028d02cc988afe49ec5866258475a1e133be57facdeea01ba6cc459e09  release/kernels/byp.by_instr.json.gz
e5cb9e12264449c7f8dffbc1ee81274f88d4e4c70d008f2f37c67b22a4925373  release/kernels/byp.by_unit.json.gz
3152ded19deda5be34daf3f4fd386ed1d8ae33cfd4127815a40c6daeab8076da  release/kernels/byp.ccvtrace
599ecd017e5a99aabfcea91ab2196961c381a2a01953656cef456d64733d220c  release/kernels/byp.log
5a03dfa4f3603fef49f1e3639e74e34152ca3ca5ef8e41eb959f8323040fa2d5  release/kernels/byp.oracle.jsonl
8eab37ec81ab7a2d1144f31b13fad6f1e17acd0ef8980ecceca3fbde988c8a69  release/kernels/byp.sv-hosted.log
0d429514d656559fd891e403e623689210c806d7dcba27cbe93267f69dfd2200  release/kernels/callret.by_instr.json.gz
da888561f6eb8214005c98d573ab158b371a9be99eab088e2985d526a74e1f40  release/kernels/callret.by_unit.json.gz
f25dad2c5b3aaba302ebe8f598ff7a87b94db454fc87263670f33799a99b640d  release/kernels/callret.ccvtrace
163b50487284e3e6a17c5cc8ec5737d56637ea1b5b9ed2aa158d33c59f81ec41  release/kernels/callret.log
9b1d1b50b527f732362f837250aa2f26dabf3e76e16a4794856ebd8f105635b8  release/kernels/callret.oracle.jsonl
d74858558fb841dcb6a0c9171e2adabaa5c44cbb08bfba35167338023df9e44c  release/kernels/callret.sv-hosted.log
62ee1a79217f80b7ab62f91c7d97c5f040c1c034b6f490aa972c2b0a9d561b67  release/kernels/cas.by_instr.json.gz
5bd5070576e58f9d4e29ce36b1e118e5fe9e21bab6819db5bb6ccfc25464ce18  release/kernels/cas.by_unit.json.gz
6505fc078765042bbafacacb50c25b95867931a27fb628bdcb037e4b1ff7fe9e  release/kernels/cas.ccvtrace
ccbc392dd3b6fbbebbb2aaa8a919fe6b96b7eb8e899ccaeb8abb94751db68796  release/kernels/cas.log
0ab31a9443336fe5d08e1a5fa5fcba3bc279b19022f7c5007908d39d8ef39536  release/kernels/cas.oracle.jsonl
cabc762b68dd317f99f7da2d16077e6bf41865985d1bc9a48dccfb7b9d686ecd  release/kernels/cas.sv-hosted.log
632579031f39b9f7162b0e56cfca84f33cd165fe93abb958d02ec13f0628f7b7  release/kernels/chains.by_instr.json.gz
929f52e0550f6d702301f163ffa2ed864ef8b98022eccb5885f927c85336225a  release/kernels/chains.by_unit.json.gz
f540e971dbc6151a7a468f71ce51054bf252605a661e03dbbb1bfbc130722132  release/kernels/chains.ccvtrace
4b61d82ccd28e568baa6d6e11926b10cc0473c88077e9d6b81331818e1a9b4fe  release/kernels/chains.log
26a4cc5c5524c7219d8706c2582c80357dea60be9d6ffdec99dac7d0365e2264  release/kernels/chains.oracle.jsonl
a498a8fd1478057a4f1025ce10cbee32cec5845ec1d13249d287df0b6fd6f9e0  release/kernels/chains.sv-hosted.log
09e12c8c77fed5267eb71d94ef2fc33aecb37945adc3e58811705f8da136e911  release/kernels/coll.by_instr.json.gz
56bfb5ac69dca28d85970bcca0cf7fa3c970f1b38197ac11e7b400b200d553c0  release/kernels/coll.by_unit.json.gz
2c8ea6b1194e403806229f413a546b371a7e3c6b2d395355691fb700e8d8397f  release/kernels/coll.ccvtrace
7db8b3523d7d72ed3e8b4146787a272bb5eb282b2963ac6cd4582288df050fec  release/kernels/coll.log
dd718d23c88df5dc7d92b055d8542865aa0e029118486af127312a8a578cfcbc  release/kernels/coll.oracle.jsonl
fc585b138c563aaf0845f835c8bf11b77e7c28e5625b639928eb9c67654e1e67  release/kernels/coll.sv-hosted.log
82e069cdc865f2aedd895e2850e9b9a9abf51a584f5f76e18c912eed34c92248  release/kernels/div.by_instr.json.gz
a9f294c37c6b9b1399b98f818fee75926de7908757318e94f483eb86eb74e9ba  release/kernels/div.by_unit.json.gz
dcfc85567e91bb512739a56791b6060fbee51c4cd061880f275fcbbc1a44ef02  release/kernels/div.ccvtrace
a964a957b711d9d076c9b61af1b61a20adb93fec212e8772ec833812a13e2e02  release/kernels/div.log
71a567b85cf85622631490187563de9a5661099c78a590adff4ed0a0c3d24c16  release/kernels/div.oracle.jsonl
f3d2820b602d584998caf29f1003ed0da485e391691e4fdd370b7869df300dd5  release/kernels/div.sv-hosted.log
4c009abe4717b48a331ea437c753e312ab2a58af615309bf5e1402ed60ed6105  release/kernels/divchw.by_instr.json.gz
82b0d36718b9670c1bb4b6c14325aee6380f2ae3f675ec6992f34e13771dce1c  release/kernels/divchw.by_unit.json.gz
076b78a5599e9d55ef7f8241ce4284c7540c5c565e85e507feb40483de0efda6  release/kernels/divchw.ccvtrace
1604ea79991a1d61f1c002fdd8a0ee2f127d39b931c0bc490dae3e036c243908  release/kernels/divchw.log
58a541797f7a2df0a1c7528ae6a3edec212db90c7d3eb20656806f38b5c10b3d  release/kernels/divchw.oracle.jsonl
c485e35e753ea07a397b5314eb524c3f8d1d9250256542fc281631147cde6ebc  release/kernels/divchw.sv-hosted.log
cf3e5422b7115b3cbcf48735eba5c90441d1ad50869a8ca2fd9b339d87e08275  release/kernels/divtail.by_instr.json.gz
f4ca5626e293c3959df240494eb0d07d14e3842c33871551dbb9542c643e9b8e  release/kernels/divtail.by_unit.json.gz
2c621cdde1eaf96fefd220c89c88c20128a265ff7f1347d338c4e140cbed9339  release/kernels/divtail.ccvtrace
b44f2ab2ab9df2de18d41f302e574556d1ca42b3830e8f6b838a6b48d535f899  release/kernels/divtail.log
75f11a75c9b3b336e446140af4579f05b46c363a76b7aab3ec88154a07ba097d  release/kernels/divtail.oracle.jsonl
5e330d08537eaf91f059f644d0592290e975076e0b16f678b80c537a9f5f3297  release/kernels/divtail.sv-hosted.log
102b580827a071263a76239f1acab085d004509466a6464cedc72d8679b6b907  release/kernels/divtail2.by_instr.json.gz
36a2407698e33496593da5a1e9662cfed0db5dec9a6336d826c1d53c6d13ff48  release/kernels/divtail2.by_unit.json.gz
719fd65e1d7bb2459f32be08f0b50feb8d40a74a8e06189f7bc2ac250bc26f31  release/kernels/divtail2.ccvtrace
917a68522fdbfa8cea40bac2317a7529a6bdd7d4c1e629dad68f9bb961f92399  release/kernels/divtail2.log
b2db6b05eb6cf4a0a7677e31d0c6c2952d5cab49d353f0bb1883fe0b2a20ed14  release/kernels/divtail2.oracle.jsonl
1e85f14faf0309e88e1348c6f3446f2983c9e7f59e293c49a38df4f20249a9d5  release/kernels/divtail2.sv-hosted.log
07288a9889b25c35239bf5b4f1fffa72bdbbfa96a44de8c824ae3786b97e5022  release/kernels/fence.by_instr.json
6c09776f7b7f7071fda0c82d7b2741d3547990f8c54b37a00a8ac2cc05871768  release/kernels/fence.by_unit.json.gz
38a21bdf35ebeb31c6055185f5de6c3bad35d119858720433df2a4ff628a63ad  release/kernels/fence.ccvtrace
7ee94ae40c541fa19fc08aa3d1499bc7d22ba8051863c9051c0f7671f2b906bf  release/kernels/fence.log
d1d40317f6cf5bfb430cda1f9c0ef676609e59cabe2a11623c42ffbeca93142b  release/kernels/fence.oracle.jsonl
3ebd1a767343d609a477bf2fae75f3a4c69a55e9ee04010a21d584a52f297bfb  release/kernels/fence.sv-hosted.log
22259f01c5aae2ac948e395ab7002d0b6d68705fbdfa880f73b3b2dae8e80130  release/kernels/gather.by_instr.json.gz
e6c732f5dafc056e0172b2413271208fbc96b55a4200676e95e25910f7947e1b  release/kernels/gather.by_unit.json.gz
f1bd6873f4d8c5a8a1d710a609e94776b72b1265a46fae293ce3dd8ca3f5b930  release/kernels/gather.ccvtrace
9184e4f5348195b51e68838cdb7b09e59976a1e3a96ea4fb71bb382a74b6b5f2  release/kernels/gather.log
0413e781d8d6ff578c64eb1f800b7931e66f676d5cdabb97b94a4033e6037662  release/kernels/gather.oracle.jsonl
55ac106686ead82f6c57a7b10a1f7da9bfd1ffb8f346afacdcb7a3277bb83984  release/kernels/gather.sv-hosted.log
14efbba9c38a4bf312000eac1b52ac0b46eabac7cbcc02c7b02de822d6f884ab  release/kernels/hit.by_instr.json.gz
a1c028a7ee844d6930abfa8d4e8133ac1876b89fcb1fc88f48b23cd9e5cd55b9  release/kernels/hit.by_unit.json.gz
3ad9b029b0978dfdec0a8af33a7d6c79cc458e330a468d9f3e017a557956b6aa  release/kernels/hit.ccvtrace
469e283f5cd1319e1b22d7d2755c8997d42ea2863ddffc68983992f7207e92be  release/kernels/hit.log
7ba9603e0088d9164de6528f16ef6a7fa9ce5821c8c12b52cbb3734e39b9fd52  release/kernels/hit.oracle.jsonl
8fe468f75e0d4254dc53621569033180f5853d7137b3fc6b284bbc59e105bc8d  release/kernels/hit.sv-hosted.log
3f755997e4e9f9d6c99b397c1d26c931e2bded1b0a026b8ce96e00e1fe6d860f  release/kernels/lanectx.by_instr.json.gz
b683e91f84887d718063990ce99126d250856d5d9e1e25deefb05be132718a6e  release/kernels/lanectx.by_unit.json.gz
e2d850a58ea1e4b34c5ea5d152b621496f32e709201f898ef7f3b40e6d9e2f59  release/kernels/lanectx.ccvtrace
e9a87a76e76baeadbb3620153361a84eccfe3477e04fa91edfc6965619d762a2  release/kernels/lanectx.log
888551babf540db8e3025b82e65ca655013f93eba3c8a65689d069d52a7e6039  release/kernels/lanectx.oracle.jsonl
3558f6f3faa442239ccb30357fb19cda34410801331973d904c9a06b377628c7  release/kernels/lanectx.sv-hosted.log
643276240fceddd0a828d78ce00e17735cd752e0127ba9ae68c1521009488277  release/kernels/lanectx2.by_instr.json.gz
2c29d3f3328963cb53c71fc8c900925b17db1814d87044721f66ed42ba7c55e7  release/kernels/lanectx2.by_unit.json.gz
3c19d7ad7fc1ca1d823f230592a1e43322df4dec2d12eec5206033fd0f481924  release/kernels/lanectx2.ccvtrace
7e35a86c151bb0b61ea407576acfe764b88292e38fe2d1a0b6904312cee646c1  release/kernels/lanectx2.log
45c13056dff5c73ed0c9ece56cc36f929bf335322193c7d5eb38710b1d1dfb02  release/kernels/lanectx2.oracle.jsonl
31c0667bf937db11776bafbff27cea2868639208cb20491115c99bc62f9f5bf6  release/kernels/lanectx2.sv-hosted.log
e30e0c943ad7f271cbc0f876d3c2abaf43acda0dfbc4596adeb4f67ad76811e1  release/kernels/late.by_instr.json.gz
8f9619f75d9c3c201f430195e5b13ebc2142f1c15d07524398817f8d42190058  release/kernels/late.by_unit.json.gz
b9f7f39c82e2c3da6a3ec41dd455f7913c88bf36b4d01ef32559023fc9378fd9  release/kernels/late.ccvtrace
6d92936b415a67881edfdb92880bfa2c21c3e7e3d8771254bb01c81bfcf1db7c  release/kernels/late.log
86084f6bd747a2cf32acbc0ebd96ebd3e4ef2d8d9e21be49e3ae49290d7927f3  release/kernels/late.oracle.jsonl
d73c3bf0d3c74aa3def7ad2d390b283768245bf57d97c28bb9df99fa1ab72afa  release/kernels/late.sv-hosted.log
1a5a5704f7f5966ddbfc78a0ce3cc8a079ea86cae4a9b784d8e11bcb0b7e2d9b  release/kernels/ldpar.by_instr.json.gz
5a44ce21df945eeacc42d04f824d7e20c9e8d61b188ba9d7a6f408c2385611c9  release/kernels/ldpar.by_unit.json.gz
dc9181a5fd0d3841b61776a2c991fe7553d0d7b56ecc6beb9175e01ad6c33247  release/kernels/ldpar.ccvtrace
d94499e82d676f3582063a59c7181f94b643a048d3473e29683bb0366b5abbaa  release/kernels/ldpar.log
8ac08538e9c807637babd61b31e340f7461878ada31f0c0b83cd66331cfaf486  release/kernels/ldpar.oracle.jsonl
5f5af5744786f2a00b01a3e016dba24586429a4eec8098a01fc7de7cd68ba4fc  release/kernels/ldpar.sv-hosted.log
f9d3762ce818184cbd272913017038f9c89dc2733f47d10ac9fa55b999e2d52b  release/kernels/lnorm1.by_instr.json.gz
1558762d4689fb267f4444a446a8696cec16b61b9dfed86772e96aac12fb899e  release/kernels/lnorm1.by_unit.json.gz
427b8e18825c063e26b754a26286711058df0afad175cc8eeab3ccb76bebf4a2  release/kernels/lnorm1.ccvtrace
5a50f29c9fb484af30edd56e94c0b8b95e230fb1574a71e87d998e44f18f4fb0  release/kernels/lnorm1.log
a8d85811af988a1b9fc00db1517300af3d93ec8e589e403d3b9113fa9e0ffc86  release/kernels/lnorm1.oracle.jsonl
a67c75ecfd15714517da6d74fc6083bf01c69dea8df3a7dddddc6b235d0bd4c6  release/kernels/lnorm1.sv-hosted.log
061aa18e16e63c4556593b55189a30d5ec95df0ce60bf73280bd82949a052591  release/kernels/localsp.by_instr.json.gz
55c4641f866a04a2b763a0462eb85a8c030d3dfcf36cf0814335e69b83c6bfe2  release/kernels/localsp.by_unit.json.gz
174017da346ab4244206203d8808649dde72028ebb52f4e058c1748bc5d06b01  release/kernels/localsp.ccvtrace
391a3cf9c7bd9f3105d7aa8b903d24eb57e09b0140a838aa87f8a5826140bf66  release/kernels/localsp.log
55e3c9f36e7f7d38c0ddd38903aff4bb4509ae862015c592e6b937ea258042ca  release/kernels/localsp.oracle.jsonl
cebf4c934b1d40844ff890b3e9371f7269b098bf9f8f9350fbabe88fbc02415d  release/kernels/localsp.sv-hosted.log
21694f2c83d66a44bdbcbe7eecc7a75cfee26f6954694923e9f6c3eaaa9b87ff  release/kernels/loop.by_instr.json.gz
0e5f25e6c9204d5ea47965ee37ef3d518d47b1c43661b8217451b2f246320109  release/kernels/loop.by_unit.json.gz
97d1eb05954d7f89d5f1659a19003df0876e64b5b62d08e04f784ab588050283  release/kernels/loop.ccvtrace
cbe88e086bd32d0d148700e8e7a6ec70cf99e3ed839c254afaf45c24bb726977  release/kernels/loop.log
03ce5920c06c93e93516d8e53c3f7169f14e3593de204eacceffc0b8a3e32016  release/kernels/loop.oracle.jsonl
f37e809f75d3c5683e0cb0efdb302666972e5809c4ffb77897a160bd2957a255  release/kernels/loop.sv-hosted.log
3c92257a26a425d7ed58b9a6923f05f6bd172decde2fdf16985a0a07425e4a9d  release/kernels/merge.by_instr.json.gz
0837f1307f1b6597682f0da382c161e2fc1aec3fd39707cd6e32fa3ed340f13b  release/kernels/merge.by_unit.json.gz
81a812c872035d9ffc0e9930db5a485e840923fd1fe1d2236931ee270d2c36dc  release/kernels/merge.ccvtrace
abaf77c677778bce03552e47e09e6a465479d7f6f96da38ebbac8614e51d2938  release/kernels/merge.log
f96d28815f8756b1f5a45ded53e6170883d2dfa10f9eef0d14b8050b1318164a  release/kernels/merge.oracle.jsonl
7fa7a905a407611e95c575c342aa592e7c8dfa79f13d4936915d2a70c1783a31  release/kernels/merge.sv-hosted.log
f12f35704e3f755092fcf3cff58747c223a06ee451ab421871ed0fc2481c2f12  release/kernels/missrun.by_instr.json.gz
9fd86d8d13c45ac1f412999c9e6ac1ef078856a37ebbd154e86b6039ba5c010f  release/kernels/missrun.by_unit.json.gz
1e8f68cb459775e9e9a81cb8113fde787f3445191275a65dd33659393df5b95e  release/kernels/missrun.ccvtrace
f4016f68ec76d3ecec0f329dd1dbdb7ea890c6329d105384a7fcde2c017ccd37  release/kernels/missrun.log
531bdaf281e5590774bd2775427f25e4cc0419cf8e3d5b6999843ffe9ef87258  release/kernels/missrun.oracle.jsonl
df24ffff26874646d5756c7e9d634314c045cd71040677dda9f4e1a395c6cba8  release/kernels/missrun.sv-hosted.log
e1cc675a4381559c713b9c52def759c602ffa0132991264ae8f22c1f35c27c15  release/kernels/mload.by_instr.json.gz
8684e6e87121b092966a335b3dc764d2c348472a7ce391df80d047bf685437e0  release/kernels/mload.by_unit.json.gz
417144dff34ef2e24db13212b1472276798ae2324e76272692c0bc1eae1c39a6  release/kernels/mload.ccvtrace
4929c8a4efc811188b5768ce4c0bce136bfa4d5af839c090a1b999ead0baf4ff  release/kernels/mload.log
8000e477b9a95dfb9f0af964e8346acb9d36f1358fd06ffc4ff7cf599d2b8868  release/kernels/mload.oracle.jsonl
26e3d642a6638544711a320e5f5407e081448424fbe76f67e4a2771f178452db  release/kernels/mload.sv-hosted.log
351b77319d69d915e0f7de920c42d5813648b58d35507cce9645012b7a81b072  release/kernels/mlp.by_instr.json.gz
75414ad2b599fb79950df747e1f93adc75fee30363e3b77f4b81cacc3ef61ef4  release/kernels/mlp.by_unit.json.gz
6cd55771ba471f0760bdf8d7e094cf62c2b2c529df673ec8c48be26954431005  release/kernels/mlp.ccvtrace
c70dfb47ab485f9d8485611eff5038f328e2e511f23953935fc22a8b7bc83213  release/kernels/mlp.log
138d282f88d56c8ad648a91af0a983254b55d9fa22942c00d47b327f516a6e44  release/kernels/mlp.oracle.jsonl
148518576598eec386157c03eb9bd3d0515a80f061185827fa85b383d31a4f49  release/kernels/mlp.sv-hosted.log
9dafb3bf5df0abddafb067555c6ef4b7ed239994bd3f1fefa25385c74f2b0d04  release/kernels/mwmiss.by_instr.json.gz
3b9341c34350c12401101e1e2b4a37fc5700f41abd29922c47942832f1731fae  release/kernels/mwmiss.by_unit.json.gz
1c8abe3ef83d70722ddb9bb13b2758f1f3e5b51b20a7bedd6b410ea906fe1cbc  release/kernels/mwmiss.ccvtrace
acfbe6b363484ca16bc71579d2eae81746951acdcaeab21462b358056a50e9c3  release/kernels/mwmiss.log
8abe8e8997456a2a6711ee72da54d854b24e20abbdab28e4b7271c0d28418de8  release/kernels/mwmiss.oracle.jsonl
2773289d0dad21dbf059dea1ad7f8f2e266ceb42f0df946dd521d75fee72e62d  release/kernels/mwmiss.sv-hosted.log
a1ddaec4cb2f6c9510d9a588441fb4415eccabee50082c81d9603cf58c809a05  release/kernels/narrowadd.by_instr.json.gz
c0f558fccc4eefd4ff4264d841fd506963bab7ce683602b50ab3395b2e27be3d  release/kernels/narrowadd.by_unit.json.gz
5695db585d4f624aeb509be5c67c54d2ba97ffae95da060231b13b3de9094c4f  release/kernels/narrowadd.ccvtrace
27025f0357ed7d7595eb5b6cf73fa3ea4ceeff3c62611fac4c2af366234dd275  release/kernels/narrowadd.log
40a2cf629853dd404bb06b4a07e35abde3d12efc13f26ffe28f923daf2994574  release/kernels/narrowadd.oracle.jsonl
d49e8e820259214b297111ae0f96b1c9b8325e8b1987b1a6b118544f6c15874b  release/kernels/narrowadd.sv-hosted.log
a7d3ffac4b536649d6986fe98c9f5a8d879da795c73fe580cf76369dcf97d721  release/kernels/pguard.by_instr.json.gz
b35ccca48a3ee019096b2f39575aa4c4dae1b6780d564fecb357a0108a3e746f  release/kernels/pguard.by_unit.json.gz
2fe2d3a5aace68f42de1c4313b116c29fbf827a9e4f45848f5c0e9025c0f9113  release/kernels/pguard.ccvtrace
2f22a4d79c5beaa0d866a08130e33179f10b75489d62e6981b20d3d08d512310  release/kernels/pguard.log
690e56f1cb8d97cbf67124b7dff3ad0a90cb8981814cd1709cf0cd0e035b3bd9  release/kernels/pguard.oracle.jsonl
bd369844731711a2ec310b1c979b983598834ce051a995ca5a1cb0b191a33584  release/kernels/pguard.sv-hosted.log
7fd80fdfe3c3ec60ba212976124cc97f1ee0ca85beb6735881c07c79371d92c7  release/kernels/plog.by_instr.json.gz
fa0bb1686374838c3987ac6b0d3db35bc13404fbb20f7b6598a7230df51f5252  release/kernels/plog.by_unit.json.gz
9700cccdc5a4631cf36c27ee7ed2e15fd5cbce4dbcd62db5f3f0a459341780f9  release/kernels/plog.ccvtrace
6cdb22a1a6055f0a62ee6e23021c4c0466c11a2e55625dd288c310bd92a45c13  release/kernels/plog.log
0c99915e2da60f4670da00504a6371d7d17701d4431e733a3ff8fa98a2030d6a  release/kernels/plog.oracle.jsonl
7b1f24f47cab489a659bdc703110ea77838c8bd6666d3bd2ff032d2e1ac4bd11  release/kernels/plog.sv-hosted.log
6fc155d1ff67ece0981deccfbc52b612cd0494d38ba7e81402ad6234ed233eab  release/kernels/pmovdiv.by_instr.json.gz
ae5ebea29d84286c4f5581ecb53f6ad04d8c7f098e30de6a965bdca28c1991cc  release/kernels/pmovdiv.by_unit.json.gz
6ece2ff3810474c9e60072071c6ae63f914a306a2c4305fa895f1a0eea22351f  release/kernels/pmovdiv.ccvtrace
7db2dccfaf9817ebf76e83f2b402a9cba7be26ae2526564cd638cc90c28633f7  release/kernels/pmovdiv.log
7bc646cff6166a51bdce03d7c1b7209e871f0a91d743083a9b910a80bcd0b33f  release/kernels/pmovdiv.oracle.jsonl
a2995686acf3d9b06a1162338a130cfc7c71f93aa16021484f23ed6fd34ff958  release/kernels/pmovdiv.sv-hosted.log
2cc2d5744053245c6ffa2d18f95a8ee8df66ecf8aae28c12c00d8f950def4635  release/kernels/predlane.by_instr.json.gz
49dd936bc36419d506551f5d1545028c0f9d493f0caf5a7c8f5f14d19ded5fe6  release/kernels/predlane.by_unit.json.gz
14dcef1fb4ecec3b41eb68eea100c4c924f58d8208b3e25e3823f8beffb5a89b  release/kernels/predlane.ccvtrace
052d42986e8440a937fe106076521eae358367293784f953703fd8acb2db41d3  release/kernels/predlane.log
c45f4177b9e84fc8a6e36b13534a0c7636eb30a3f8531847100ce5e23bf404b1  release/kernels/predlane.oracle.jsonl
bd4c99927799c5f6c62a91a42233580e3570ccca33d68f10cdae8075251a5afb  release/kernels/predlane.sv-hosted.log
2be76631f220adc8d54ec6787baa879372a0b6d2ed155e58e1cff7ad8963effe  release/kernels/predmerge.by_instr.json.gz
f0a46d5f61fec24b8f7902fb9341ddf4100c96b22e147fc589b946491246f404  release/kernels/predmerge.by_unit.json.gz
029ae0437bb86254236f636e509624280a9f14a40ff69aadd97bfd4a24eb4bb4  release/kernels/predmerge.ccvtrace
4443cd96e2c1a4201a15dba5fcf3980df38099cf0eda49bd2c92c51a9cf6bf1a  release/kernels/predmerge.log
6c737c49434bcd08e3e0814c8b1dbf15c586ae74f7929ba3148ddcee2c62c845  release/kernels/predmerge.oracle.jsonl
18a466f1e0d1c06fd079f17e9106f83425eaaa3bfc556e44b40ec1bbd1e4cb18  release/kernels/predmerge.sv-hosted.log
f7e185cc52b4baf319d49ff2aa69454d0a5dc3bc89ec820e334f8db02001b7f3  release/kernels/predspill.by_instr.json.gz
4d3e51db38c96d6e09eaa55ca467d170263a8f83ce0121254d9c3206f39a14f8  release/kernels/predspill.by_unit.json.gz
349f32b3f925cf76caf11b10b8b37d2d942950b500bd2cd744502733da0d2b23  release/kernels/predspill.ccvtrace
5b064fa2c5dffb566d4443fbd25a391f8c956ade48e576ffbeb5fc1d9110f46b  release/kernels/predspill.log
b7c84c6478117ffa0f06da0e6ad1e4628e2683426a7911080810e78e06a5242e  release/kernels/predspill.oracle.jsonl
e3160df75edfc7ea831290252cb833c70c9dc66439a069deaabe0d3cd60862b3  release/kernels/predspill.sv-hosted.log
de95708f76c8d40656b6c8c0a32539a551616b9bb6c8cfaffefe2898e0afa108  release/kernels/predswap.by_instr.json.gz
25a890166b3a1e6f786032d8fbf6359ac3a37664bbeee6f835bc7d3642b532d0  release/kernels/predswap.by_unit.json.gz
2ea280110f495df264f6b0eac6439699e16a0915062c2b6d24ca99765417f79f  release/kernels/predswap.ccvtrace
98d8c4a70a1582d33544e30a277719439ec1debf371713bddafe3b66bd128316  release/kernels/predswap.log
a6d4f7ed517553816d889c7c9eeb6bcfd1f6c973fbf682ecb69f3c2de619f7bb  release/kernels/predswap.oracle.jsonl
4a589be2d1e65362bd4b093862b3be30801ebf30a88b5d746a7694778b1e9061  release/kernels/predswap.sv-hosted.log
9417a0ff1e589cc54718f93d66e1d448d6e70332a3a3817410c3e68994807b70  release/kernels/privwin.by_instr.json.gz
4aab3b550f29c8f7e3bde63a8355433b695ab4bfea99a76d95d05f69dd644229  release/kernels/privwin.by_unit.json.gz
e0fd0eb9b9baa6bdcf71c83091dc5d28233ac6378f0940ab1f9eb0816c86838d  release/kernels/privwin.ccvtrace
fb6f4f9f67fe4c1c8bb62f6330e06d1c374103b72eaacdeb962f929d3b9e81f8  release/kernels/privwin.log
861f686fc4480363472908d679d8815e8c957d768e7ab32c826930527b0fb7a8  release/kernels/privwin.oracle.jsonl
5e79c0679814e7dd397890b9209660d3b73205c7792a64ade56b4ccbb5aa5890  release/kernels/privwin.sv-hosted.log
701b6503352b30ba1f41cd1afb6ab0763875d82e631cc59f0773b7c6cc1d07c5  release/kernels/provswap.by_instr.json.gz
e2480e4e017b4cb6497e4e2529832a3ada7ffb7526d51ef10de488b83fd84679  release/kernels/provswap.by_unit.json.gz
d07f457ebcd381b9e754c95c295c0e1d3bf6e4871db552bf7497f1155adea396  release/kernels/provswap.ccvtrace
a253a9d97aeeb541b1a1e534635be8cc7d63e427e8151fb4bd8a492538d3c7fd  release/kernels/provswap.log
c9c32a793d54cc7401477f582487f7e8b345b2669a75337b8d6327120d98e5dc  release/kernels/provswap.oracle.jsonl
498e6835e43f4bd5b6c0d7af5344bb127072fa8ed8e54d99d98184c8f4ff97ce  release/kernels/provswap.sv-hosted.log
44219962f2bf3c00a6ca78006c987fa0a665371e87fb4489f33647489cb24a12  release/kernels/retmiss.by_instr.json.gz
341f1fad27614bf2f363dbcb5108665f9f68a9a56ac7f7b828436898b4a90f68  release/kernels/retmiss.by_unit.json.gz
bfe0834de490ce58d0e47687df42aa1372c12f648abbce2a23d30ff90a2df53a  release/kernels/retmiss.ccvtrace
c55aa55f59e9dacafca3e597e8456cadd2cd0c3c1956e088e7a49ee239812d09  release/kernels/retmiss.log
e5ef8538e838c6cff7febfc679dd091cf5e002f82d34f1009b1948ce22bc3649  release/kernels/retmiss.oracle.jsonl
98ccfdb189f8bd1093909d46cd9f33fdfb82d3557b547a7b1a39c7687f459a89  release/kernels/retmiss.sv-hosted.log
9d60227eaf49c14fd3b4f0e72b439220de297ee6c7a1b8ffb23c9e5eeb2952d5  release/kernels/roconst.by_instr.json
a0e25d5a3229313a2b66d996866af59d79e8a27ceedc6a4193409e0f4fed73db  release/kernels/roconst.by_unit.json
26a99d074054f18545f2ec650525eb1bb56ae2d016da2e2fe4be4e6a73dc2887  release/kernels/roconst.ccvtrace
39377a33966c83010c1b42f69901de7c835a16e3603849a91e46ede8c32b7973  release/kernels/roconst.log
8087c0671de620162881aecd38cd6114b78e7be6bd71201e3ec02c9a2e2e750e  release/kernels/roconst.oracle.jsonl
28050e37701a530950d260ebd7a08cd533d398f69e217146a8c0e3121b869593  release/kernels/roconst.sv-hosted.log
63c496d2b878801f75243a30d802879b4bad83495b9cafe3805c826cf78b8ea4  release/kernels/rogated.by_instr.json
89066c4e53905c12c5cb3701a860537e097d0efb2ec954fa28b84e40cd3f0ba8  release/kernels/rogated.by_unit.json.gz
b7b062e4fea63ee62851afa2ff61089f42dbc5b14814c50942f35f20731764e0  release/kernels/rogated.ccvtrace
68f4bb27e3b1d39c4bebb07a0b12a82bab4d1f8cf08339aa67f32f7c34dba197  release/kernels/rogated.log
7cd02bd4cceec5a044d6b4d6a80df1e68ed0ae71b0b2a953143636d5b809ea6c  release/kernels/rogated.oracle.jsonl
d425cd76dc125c2fcec44f34624934c61e08e76b1d9aac33b6d4c32c049bdf03  release/kernels/rogated.sv-hosted.log
36c2922466286e29ed98c9b29a87d1d9b10d64c1eee1e332afffe6d27d19bacb  release/kernels/rokill.by_instr.json.gz
c525fd219a062f39fc85464f7a966dbccc4191ddda67b48c6f83252c87b8b194  release/kernels/rokill.by_unit.json.gz
d8b9c1f21f6efe23b6cff5aa55d9a09ecafda7fa4d39d082181cb062f26c4cca  release/kernels/rokill.ccvtrace
d42eadcef384eb9cf3accb8b7a4d8501aa35e9bceab6a1f52eca079fd3e3955f  release/kernels/rokill.log
94efcef96af469a512d346ce61623980fe86383188eaebd55120f716db596f14  release/kernels/rokill.oracle.jsonl
00d4a3cc05b6fcd38089bcbcb279190a61d0e8c10a9889558a370ae566a17154  release/kernels/rokill.sv-hosted.log
f80922811fcf7fe0c95e691706befe832ff25e683d067e3aaac983cd4a5c477e  release/kernels/rolaunch.by_instr.json
ff6608cc88b28562c03443b78dcbbc8a430693ac68dfaa9c536c53e978f3d0af  release/kernels/rolaunch.by_unit.json
b749e9e281548ed432afb2649de661925532c37ae72e4ce89e9668c11eb51556  release/kernels/rolaunch.ccvtrace
0794be969f859653dacaa9f5033da35754dc709a51180974155b1f0f2297dc1f  release/kernels/rolaunch.log
e7dad585c3e70615de04330fd03f4f282c29a005dc1732a35655fb261d51139e  release/kernels/rolaunch.oracle.jsonl
cfaec78525f99049699b37bb2e0d2565126fb8364a97b84f4a593d7dc815df85  release/kernels/rolaunch.sv-hosted.log
9d60227eaf49c14fd3b4f0e72b439220de297ee6c7a1b8ffb23c9e5eeb2952d5  release/kernels/rolimit.by_instr.json
0e422748b925e81608f2a231594655574afcd39fd1edf26617f2057c864d97dc  release/kernels/rolimit.by_unit.json
9ec963609fa3c37cb858dde3d38651cdae972b3a9e3f38781000ec2f594a9bd4  release/kernels/rolimit.ccvtrace
6df6d54c7205fd7d35c80269b0720be95ed140196ed3caf40b847a312a0c81e6  release/kernels/rolimit.log
1c5bc0cb8e8b2e69505fb5a551a16d5d10c56f232b88da7a27e336ad7d962de2  release/kernels/rolimit.oracle.jsonl
c3813bc992e7b3d0eb0b5d5e373deceec5fd1d00c7114e2ce5f6bee946351a87  release/kernels/rolimit.sv-hosted.log
f67bc1c7f492d45f85c320e89b9f9d0ee854dd2396e890dc7234c9c5e4cba0e9  release/kernels/roload.by_instr.json.gz
e3167f4e3ecad1ccefcf6d0f4ee99b8a2a15c90ccb77dea4b52fa7832dff0e6c  release/kernels/roload.by_unit.json.gz
1fd0b83b3827c844bfbea0eed7be6aa9e73c494efbda9a1a72ff4d6d37443941  release/kernels/roload.ccvtrace
0b12bc05e1f7456525d7faa8459631e8ee709aa8f167f5ef62c1cd5452b2d3d4  release/kernels/roload.log
f7c1309cc9764769fb5803f6fd0f2f5e1eb418f2d23fbe5e17cf5f9106869fdf  release/kernels/roload.oracle.jsonl
fdb4691f6944907b0c5b2cb61fac9050e6ba3b924e5c174996043c1c208fe6ba  release/kernels/roload.sv-hosted.log
9d90eb76ba263a13ac5dca4f2f36ec3fb5c323035cd8d3f112a4c1d11852b2f2  release/kernels/rope.by_instr.json.gz
795d1150d0ef6c38d8a5f513d778e894438a9ced38a5847754be6696f23f0b86  release/kernels/rope.by_unit.json.gz
4c91f7caa8d7fda9718921b6642e231f2d6812cbf5a69468fc09c4ed86685d10  release/kernels/rope.ccvtrace
43c281e95df67b8a6f2666953c3aebbbec3b7b3cfeafbb6239cd4e76c178165b  release/kernels/rope.log
d55f9efae392dc8877c102c01c0810e7654b666b6ede386328108164c6cf88f3  release/kernels/rope.oracle.jsonl
46cdbc9d626d79e6f5da8ba63217ed7deefb63d3caa8585ea5f48a7e75609660  release/kernels/rope.sv-hosted.log
96a9e52fab1cbe3fc95ac53144c17ef84f03ecd045e7aeb9363dee732a09ccba  release/kernels/ropediv.by_instr.json.gz
e89ab82f28827bf9df17517f67c3482988de4e14abf491964d0bbed14abc188c  release/kernels/ropediv.by_unit.json.gz
838eeddd0834f80d5a04096f4d9569ebff21459a4d40d54d49500765874dac8e  release/kernels/ropediv.ccvtrace
93814b2503ac8f2daf825ba71827653ec66259cabc2c3fa0cf51d5113c7ac862  release/kernels/ropediv.log
10c0ec6ec18b7b44638c790033109198c079d07c1537bf193353ccedd00a920f  release/kernels/ropediv.oracle.jsonl
f73906ce2e229ea5ad33d4c9323d49f84e448c0929ad2ae1194ec559871c9469  release/kernels/ropediv.sv-hosted.log
a1b58403e156fd9e672776c6180656061701e7c1bb68f599afc64a5496c79816  release/kernels/sel.by_instr.json.gz
6761baf03b1501b07368846158d6a6715cfc03ffd825601a9a957bc0aa680bea  release/kernels/sel.by_unit.json.gz
cf56791412bcbdba8dec6c78ce5aab270d09d252a7cf409a5915afeea86e5dda  release/kernels/sel.ccvtrace
9018b4eae20ccce1fbfbb42e8e4b0ab3be136d1f7bf67c1a11a71cabf626fb7c  release/kernels/sel.log
87f6a81e8afa004c8039bf2f61c90176fcf29ab29bb17ac44aa016a5cc8438fe  release/kernels/sel.oracle.jsonl
099adf6a85cea6a79e42120e04380ef84dabd4b38aa7903704c300551949dc31  release/kernels/sel.sv-hosted.log
c8d1caf618ad1d17b2a3d6c16e27092c627ee093552b8bc3013f9dba862e421b  release/kernels/sized.by_instr.json.gz
c81ed227c99096af50f39a83e9411fee1b473ecb1dfecde1bacf81f8e08b7a7c  release/kernels/sized.by_unit.json.gz
95ff99b9a0efafaec4b59b944360d3664912cf64d3c038f58bcbd67fab2bf4e5  release/kernels/sized.ccvtrace
d3b35090963e4cdf5676eb6b19aca4f8042b6cb13a99b8f76d946140549fa04b  release/kernels/sized.log
36d903ba1618bd1faa437c9812a6ee6c0c966a63196c796267d74bf2695ebc3d  release/kernels/sized.oracle.jsonl
851ff5f7c018f6e0f266a8f06bea0a314979a63009453fe61032f38aafcc5f17  release/kernels/sized.sv-hosted.log
dac9ab1fcc360e3f5dbf392b57cb0768d430cdba287462e93cb1ecf63367c4cd  release/kernels/slotform.by_instr.json.gz
fcf1b68babba5646aa283294697bdcd2d120992f19ada09052653c945454796e  release/kernels/slotform.by_unit.json.gz
b159e417b57396749dd6592fdb8c9286f0ba652f2a3ad71a9c540ce1ddf44b6a  release/kernels/slotform.ccvtrace
85360b0d3f16d505346b056542e0a8b6a6c8012dff9661d4e42b367d3980b3d2  release/kernels/slotform.log
8b61db7419b18cea8a646fb628218447e72e84a18a9891ffb73b441736138ab9  release/kernels/slotform.oracle.jsonl
c92b7aecc0915434d52769e4b69d32dea034fa85e1f155ad1e5bd75e1489f0db  release/kernels/slotform.sv-hosted.log
ebd5113721af0aacdb5a9831aac94eab301eb911e783e434b8cee61528e3f011  release/kernels/spinwait.by_instr.json.gz
1629141ee6fa570ce8489302eaf4129e013dd0d6f6d72a78052dde07d2817a12  release/kernels/spinwait.by_unit.json.gz
3c2209e38fbcbbf27c15503b099f11344e8e2a2270160a8530a39b832435b9bd  release/kernels/spinwait.ccvtrace
7173af1a828e6c30833774ad060588e138e1637c8e0562eaa42b0b6ebb4bdd12  release/kernels/spinwait.log
868920637236c878b33779bd450439466fc3626996a3164573dc11d437d5c709  release/kernels/spinwait.oracle.jsonl
d97e9d98ceea217aa1d242c364ebc2a830a0f4da7b8077e2c40c6a445c379d6e  release/kernels/spinwait.sv-hosted.log
9fd7f88addd22564ee234faca06a40a60c9b878a3d0caf2c8cc3029a1ac5aaeb  release/kernels/spmbank.by_instr.json.gz
08bac50ea34a7f13224a9531602530dd9e42d9cf43ac54ba48e2219700ec548d  release/kernels/spmbank.by_unit.json.gz
c0c97013dd2c20868a7a738ecef09f385045d505ec7dde13a17fb5535d6286a1  release/kernels/spmbank.ccvtrace
dd07383890c91ce57f645ca56f0ccac366edc0ca84bb25e67461fb342bbac1f2  release/kernels/spmbank.log
3af490cc37d7a92dbe719b57de216b648536eb301ff9d13de9a39f50d150d725  release/kernels/spmbank.oracle.jsonl
7132bca783a1910f8be37367e66ff39e91f792db7da8a7359d02d80e0ee543a0  release/kernels/spmbank.sv-hosted.log
d69219783c0c036fff965122253d5c55f51ec1365a8a2f507ef6d6ffcbd51fc2  release/kernels/srd.by_instr.json.gz
773767b212bc1de68dc5c1badb86c7cbfceacce534f3fdf9706fbe80d04e6a2c  release/kernels/srd.by_unit.json.gz
120e1319cd456c4df852934811be1da60dc62491e8712908c82e235990afb825  release/kernels/srd.ccvtrace
62cf800e508077a895f441f3ab160b66ce5ca80a7394e19a033e9017b39f4b5c  release/kernels/srd.log
b08eb5e3673cac7eebb8b72af5ed3783c8e70a9e96592e76bf3722551bc79473  release/kernels/srd.oracle.jsonl
200e21164b3abec72fbf151ca2b6a9b2173e682b5085b1d607478f1cd8bbc948  release/kernels/srd.sv-hosted.log
a76ded0b2ac3cc2aaa47a00d648f6bf22080a39ea6844d7a8b88f68c26b315fd  release/kernels/stall.by_instr.json.gz
3ddea789a095a903956f2d4f39cc0a8880bd409c6fca2b63da1a929760debc86  release/kernels/stall.by_unit.json.gz
ee8a34eaa00d8d74698a829a37dcd3b6aec9f7281289a39cea60de789455faf7  release/kernels/stall.ccvtrace
b1969ff98f2e3bc0c419cb2c560e63132280c13c01d0c5dd1cfa207dd3561ae3  release/kernels/stall.log
500db2c482b07a0706583422cd68878301d0146c1f872ccc1f11bfdcf5c993ef  release/kernels/stall.oracle.jsonl
54fa3011ff88ef960f389bacc5127e3ae125936910817faeafefc6896ffee7d2  release/kernels/stall.sv-hosted.log
e510032203d4282b6a2a5c98b60949599c8d04851d31f247851641dc744ffa8e  release/kernels/swap.by_instr.json.gz
b0eaa61b9a2ad9413d2631e6f9915b82302b86e896a6a7be8c0131f3f3a7fbbb  release/kernels/swap.by_unit.json.gz
28b0809be1ebae9fe1ae03b9d0ab0da2f0e11706818c5e01b53a7d1eb098d5ad  release/kernels/swap.ccvtrace
6c77c37879e86b67aeafe3bb61d9ec9d0abad27956a0b47e6d3dd95705c4828f  release/kernels/swap.log
3658a26316c1ff7bc1744304a42f736e930fcde2865c8913e6cc67a22ce96667  release/kernels/swap.oracle.jsonl
9df44ab537d2434cba00721d7e05b4b63f640cc671711f5eb8e6e2ba260c852e  release/kernels/swap.sv-hosted.log
a065c7e8b07c91188150d43a01ca09c2eed810615442d4b337e7a38419a356f4  release/kernels/transp4.by_instr.json.gz
c9cc5121f0425a4d306661fe99119ddb2ebc3f190a1e1545f81343c2996d8823  release/kernels/transp4.by_unit.json.gz
8c76d925e89c874e5ccb725e80f9fa90d51661f7959b849cc7a4c9f90b049008  release/kernels/transp4.ccvtrace
9563d3e8232a1c714d03b40ff2bc257caba3f18fd063d4d43e751db7e3c5c78c  release/kernels/transp4.log
06396ace3ac19677fd39c700e408606e5bdbacb24997d663bbe8872e63dd74fc  release/kernels/transp4.oracle.jsonl
0fa996cd2624bfb522f76280054ca61436a02431a6a62ca523477c007014bf11  release/kernels/transp4.sv-hosted.log
dcebdde3362ef5ffc93057463ba5a74084f49cab4c830107716b7ba9c9f6d6d5  release/kernels/unal.by_instr.json.gz
735f389ebb00078050091b1c68a3bbae469364fabc3269fa04b74038ae5c5045  release/kernels/unal.by_unit.json.gz
babb3fc621937e909e0825c3c091260117abc00f1b040156d22b9d4279b9df5f  release/kernels/unal.ccvtrace
823f188815feaac6c1cf0a992e004dea5f4595fc61e7d2b709016a0ae74baade  release/kernels/unal.log
c3d484bb160657a563df983d9a2532eac27f556636617960aa1e72183ac2b299  release/kernels/unal.oracle.jsonl
3d273371a953d48f646a851d525d4042028bdb3251d2664b7cc8e25b0b9e717c  release/kernels/unal.sv-hosted.log
3e5aa26c01d74078ef311c598703e4bfa45c4c7dab9a6339bc8efe9ed2ccae54  release/kernels/vadd.by_instr.json.gz
5a77cf1c9745151ea0626e3d488de55ae837324ec82dc593bb5a905c9f76dc6b  release/kernels/vadd.by_unit.json.gz
10fe32ed353f074dc2b10c8fe441f722069c023ff22b12d5b17e829cab6ba730  release/kernels/vadd.ccvtrace
08ad1a693d469fd398861e51937138ce170576bf4ec7a816f155c4cf48d366e3  release/kernels/vadd.log
0276b6d0611a4bbcdc004ab3987214aea138245bc7217504147331689a9c0880  release/kernels/vadd.oracle.jsonl
908267d473fc160da5894735d8eef75aa12876537b9528894c7c3d6b29f518fe  release/kernels/vadd.sv-hosted.log
4a447943e50953eeef352add8edaa7f86d3e0fadc5f4e92689f84cd69d6b4260  release/kernels/vadd4.by_instr.json.gz
a2e5075c8d50ae23073cc8e5d992f0ad7bad48e3c04c24205490ef5ee44b9d7b  release/kernels/vadd4.by_unit.json.gz
3b2b955f6822e731f7058ac9d4d95139332970a77740107437bdabf5363e5f1f  release/kernels/vadd4.ccvtrace
22d0eef993a5a3802ae30a1ed9b33466de0ad7f3535c7bedf78875415d929bb6  release/kernels/vadd4.log
225aa18fc9f38aa9ad615aa11de254337d59fa705877553d873062c68366e0db  release/kernels/vadd4.oracle.jsonl
99ca3fa7b7f235110295d64aea1a3c88114e0502a2fcb222fa925f7a15726830  release/kernels/vadd4.sv-hosted.log
a9a1899d863144a5241952632709be3ffa34f2d90f3c093ceeee637b41c6d545  release/kernels/vaddslow.by_instr.json.gz
0afae3cff819670f3d1eb160f5d2d9d8084af2766d60b60c744d50c458a9785d  release/kernels/vaddslow.by_unit.json.gz
790212170c180645568e37c971d2e0acadd013967e87c7254204c61cad9cd5ce  release/kernels/vaddslow.ccvtrace
8765ae06aa8a4d812dd086f81796bd921214f009f9ee5e241f382313b6fbfa94  release/kernels/vaddslow.log
e9e6218e8b8450e9f9ff6b39d659c994a1e51c527a0c5bd10d18b5658ae0e344  release/kernels/vaddslow.oracle.jsonl
5015e4fe04e5091738f9ab7c6bf3d330c1174adc30311f71b48d488582c33319  release/kernels/vaddslow.sv-hosted.log
38c4a437870705dcb9370a133612c132256aa3a6a2ec1cd2162a7e097c871cf2  release/verify.log
ecec1a37173b3e9e46a989946881f9d4639255fd582c7a2cbb350aa8629c0401  release/wiring.txt
```
