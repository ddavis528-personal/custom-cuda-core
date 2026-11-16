# Snapshot snapshot-2026-11-16-3b3db12

**A generated, read-only snapshot. Do not edit or merge it.** The source
is `ccr-9eb50716-lecnjf` at `3b3db12790d0479fc3ec8708de72f522fa4a7453`, and this branch is rebuilt from source by
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
| Source | `ccr-9eb50716-lecnjf` @ `3b3db12790d0479fc3ec8708de72f522fa4a7453` |
| Built | 2026-11-16 (UTC) |
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
7ba1c6516399ef0da662417d4b7a56547be999fdeb80f49af60e7e49008cb0d2  release/kernels/addrhigh.by_instr.json.gz
8586a44095b0576ae425ca685644e65febac74cb0068e98a6f30b5e761b73f3c  release/kernels/addrhigh.by_unit.json.gz
7f4025bfdc4a9e67d17c349cc2031239027d3a614a0080c15e41212d388f6c80  release/kernels/addrhigh.ccvtrace
3b0ba2ead6f76e810063a2a17050240c9f3b9f48bb045a50ee7198af614c03d7  release/kernels/addrhigh.log
569f2e22883fad5f0956c57ec734e6afbdd4b8a854e50277425172d6c0cbd766  release/kernels/addrhigh.oracle.jsonl
0bca3b9c5e26744f6a6eb5b961026a8cb81c8b69c8f495d578de55ebe3364428  release/kernels/addrhigh.sv-hosted.log
aa6bd6c7702e490cd7eae601a706684bc0640f4fe834615ae4961ecd37d5df16  release/kernels/addrlimit.by_instr.json
42bb950e04bb0f066e20acd0374d22536e63c7bef57ad72b2cd313d3c78cf728  release/kernels/addrlimit.by_unit.json
ffcff00f0a036e8c3c68ea35f6e73be90d63fca4dc588f21e07ef1de819feec4  release/kernels/addrlimit.ccvtrace
7fd89b25e70bda38a01b805b3a8970ffc0944114f9df216ab473da6182fce26c  release/kernels/addrlimit.log
bc660b0b40359a2c5a2478cb0eb4950b73fd22db50ea76b80052bc195a1920f4  release/kernels/addrlimit.oracle.jsonl
4ed89e1d8918b12a4d68ed8503db2293c091fd14e54f09741d4c66e49c2b6bf5  release/kernels/addrlimit.sv-hosted.log
e7abe7817b399a7c2517f35ab48166e57586a5f46b99d90f11550210332bc0fd  release/kernels/addrneg.by_instr.json
55ad70974dc8a9ea0533a37b55ae47f2ab3280b5eeb9e4f5f56b2a2d355031f6  release/kernels/addrneg.by_unit.json
34b171591ba4b885fa0d843ce2817d49eb6638f478e426eb5b2947e4aabce7cc  release/kernels/addrneg.ccvtrace
cb76c221bafb8f41877a91800b250ef2ee8206686a948d5617a65fa2ad9d2589  release/kernels/addrneg.log
16f5b0707ae44492a1efd67bb9dd38a7e79a7bbd354fa9207b9e7d150ff2f107  release/kernels/addrneg.oracle.jsonl
7c33e1bff857a82df7cc593900cc8b725d4f0ff4108e404b66e0c696cef3d01c  release/kernels/addrneg.sv-hosted.log
aabb6610579188de0e9a718b9f5485615620c4c31a4a68e2f50f7dbd34a68272  release/kernels/atom.by_instr.json.gz
d7260df107a9e4de6677b706462b44d1aabb0737a37915393cb531dcc49952f6  release/kernels/atom.by_unit.json.gz
4500c016bf0278a67e1d50d49cb86f16de299aff114e07694aebfed8873308da  release/kernels/atom.ccvtrace
c4c7dfc3f4ba93c5fcfaad8a95e68157595d3ad3a1e22e1f58731ac1d4bcedbb  release/kernels/atom.log
504f5b6e9d25114dc35f2c70b21bb7b3f3c508c691de12dc0e87d12a74285361  release/kernels/atom.oracle.jsonl
b143c77c459cbaa44fed0b28e127ba978d30ca3006e70ebace2f3037aa278bf6  release/kernels/atom.sv-hosted.log
d770a6a3033dda191edfea87e6b4840ffafc5229aefd48b90a3dc48550460557  release/kernels/atomf.by_instr.json.gz
3357f621639ed4800fbbda2bed14a4b4f96360cbda00daa7f19620e67d8ec377  release/kernels/atomf.by_unit.json.gz
0596cca74325b111984dd5d02b7f7a32aa3c3ddc84366d89e48a0b66dba91770  release/kernels/atomf.ccvtrace
5f1ccdab0f993280350ea17f0c84b8898aa5ed23b7cf79c26bef6b5602c31170  release/kernels/atomf.log
cfd1179edf4061a33ab2f75d7a6dec61decfe629000198189a7bfc2647b34238  release/kernels/atomf.oracle.jsonl
5498143857abfe83aedf373955fcd5f2e408e24c7c3732eb455a259bb17f33cc  release/kernels/atomf.sv-hosted.log
6ad5df9e77fa7f791ee5456d25a3fb4a7d2d340502e9ac30f2d110a72e020fc3  release/kernels/borrow.by_instr.json.gz
8aeac1d6fdafd40deba52e228129e0206ba31dccd7a5533d96598578f6330590  release/kernels/borrow.by_unit.json.gz
f47ba0ff76f39020aec6e50deb887c83af18cb9efde597aa3d2ebc7261eb3139  release/kernels/borrow.ccvtrace
26beeb89f04d82175714bd4acb7546bb221e9ceb43017b5b97fe6641abc4c012  release/kernels/borrow.log
4c565e1ce0b3baee36e158694b32c8defb5cd662b2f9af75cb5d8c26cb1168ed  release/kernels/borrow.oracle.jsonl
680be4cfa79ff0fbba598d1e7b8afc353c442153d4f9e8984deae5675e0301da  release/kernels/borrow.sv-hosted.log
820a0516aebf744fa39353115bbbdc3e48be8d6fd6d467f95b0ec6e91e3eea87  release/kernels/brs.by_instr.json.gz
4fad78de8726a3e4a6abf2f57f57c1f97b574f2393b57c38cc2a12c13f0ab8c2  release/kernels/brs.by_unit.json.gz
0efbd34762b9bb839d84507973259b9161e0b6b94498eb217ab8eb280dacf7b3  release/kernels/brs.ccvtrace
cb17ed0677736560732e75dcb651ac14a763dc0fd1648ae8800c808a12b2f838  release/kernels/brs.log
e3c1cb3379580cf1aae44e8ddc8e846ef6fd661a573cfe0a8d4444b18a14dc56  release/kernels/brs.oracle.jsonl
9f426c2eb98e23ff2938b51b45acfa31c8c8c7416704ebc332eae5a9ccd0746a  release/kernels/brs.sv-hosted.log
7c3134966d053c38163df98e36dd4e9027364dff416f28953be6acf42387c5ad  release/kernels/byp.by_instr.json.gz
a01dc1c294b743ad5d0c3f8d4d65da3e90e0ed23256a19a11f526575d2a36dfc  release/kernels/byp.by_unit.json.gz
eeaeecbeffcfabb26607ba4cd6b679e552bee7dc964f95f3f62f7662d3bf9781  release/kernels/byp.ccvtrace
7d97811cab9c5847731cbb54d6cc941201757919cda1576d668c6a250a524341  release/kernels/byp.log
5a03dfa4f3603fef49f1e3639e74e34152ca3ca5ef8e41eb959f8323040fa2d5  release/kernels/byp.oracle.jsonl
c5dccb125aa628d1488d8320c9b526628561494df54c873a729513876be22938  release/kernels/byp.sv-hosted.log
3e72e52da8370fda5707020c08460e3668bae52991796700b39a64c4f8ba34eb  release/kernels/callret.by_instr.json.gz
30016fc8dd4f4544aec35e870222421e6cc4b9a3813f348f705042d88ab422eb  release/kernels/callret.by_unit.json.gz
5c2087e66850074105fdfb60b9a6053764189e68f098a29346ea888c00482482  release/kernels/callret.ccvtrace
741543e45c44a542372048967f11dc18a449d06d0505083fb483e188d60c6ed9  release/kernels/callret.log
9b1d1b50b527f732362f837250aa2f26dabf3e76e16a4794856ebd8f105635b8  release/kernels/callret.oracle.jsonl
96c66019397bead3b43531c0c04e9f42d248ba2b39eb2e5f13fcdc40b16f49ff  release/kernels/callret.sv-hosted.log
ceee6504724f9388059f90776dfd8aa46d62e218beee4a70fc8bc769dd41a066  release/kernels/cas.by_instr.json.gz
bcb722344a326761c836cc183cec9bff7142b6a9e1d477dd2c894242a531689e  release/kernels/cas.by_unit.json.gz
2d44cbfee68c094cd7aa22da1d471e60b8d0307b865fa742dca84489a3dde7da  release/kernels/cas.ccvtrace
5e436248a56365e46b581bd3d0515933e31598689d0a748cca45ee1c8ecca14e  release/kernels/cas.log
0ab31a9443336fe5d08e1a5fa5fcba3bc279b19022f7c5007908d39d8ef39536  release/kernels/cas.oracle.jsonl
8802029ec4d00ed55395d188a12a2ad62659ffe752763b9b0d3dd1aa31cd99ad  release/kernels/cas.sv-hosted.log
3872866c117636ff481bcb2cac1feba3792c3e966962c2b69ac2e9f47dc5e4f9  release/kernels/chains.by_instr.json.gz
1d0a4653ebb156509ae966ae491fc0f23d7b37e0ccf6235f456bd93b91ede8b6  release/kernels/chains.by_unit.json.gz
b47e10902de830c337bf591bfc2daf06098880741b67957d8e8dd9c45208dc56  release/kernels/chains.ccvtrace
4376e415a48b7603e66a622bbb788ae4aca34971c6e70ecb97100beda6a01636  release/kernels/chains.log
26a4cc5c5524c7219d8706c2582c80357dea60be9d6ffdec99dac7d0365e2264  release/kernels/chains.oracle.jsonl
a8334feb3b824c64ca26674c046db3c1fa24f0bb5919388f699dc0c5bc365045  release/kernels/chains.sv-hosted.log
b3352dd0c7ecfdc8f9b514204570c2f8d353494bca9807344020529e85353f4b  release/kernels/coll.by_instr.json.gz
1b904f9933c40229b46979340bd05a9a18edd21dae1ac9d87807b699ac7674b7  release/kernels/coll.by_unit.json.gz
9b2defbca3a81f102a07f1fb1a9473253e58da6ab1e7375a8d81f4d1fe098bae  release/kernels/coll.ccvtrace
94cf62f16465d91b5adf7a138b6594098595998aee9231c92f6619207d3d8aca  release/kernels/coll.log
dd718d23c88df5dc7d92b055d8542865aa0e029118486af127312a8a578cfcbc  release/kernels/coll.oracle.jsonl
890200852b1350018d5fabea1796f45d7d2681df4791f013f38fbaa2dd8f8d64  release/kernels/coll.sv-hosted.log
955d19e8e2b0e4472539b492d4ab6f14b1ca6c706c0eadad6cfb0fe090041924  release/kernels/div.by_instr.json.gz
74ac9dcd76f0aeb0c1db7ef48e17799348f9774544004e80f4ef9ee81cb4cf31  release/kernels/div.by_unit.json.gz
182346c5baad147767effbea67248ccbc6e5c35582f0590ab266ce10e6e9dbc8  release/kernels/div.ccvtrace
f0c0a3699f7e53dbca6129a8df9becce34ac4ba14a5386c32ba31d99e5f33574  release/kernels/div.log
71a567b85cf85622631490187563de9a5661099c78a590adff4ed0a0c3d24c16  release/kernels/div.oracle.jsonl
bebf419e8078825b9475ebe797f5125777ecd8e06eb908e7d3291474793bdbff  release/kernels/div.sv-hosted.log
5c4971ea27bab32e49ba65b9ee3fa0d0a5137414c59b7e563690f5281baa0948  release/kernels/divchw.by_instr.json.gz
88861a416993108ba6ccdb42e805d23f325fc50d79d1a368fd80e09248ff147e  release/kernels/divchw.by_unit.json.gz
4471a48e9f9555ec3ff526316b30290fb0ff75d28588185a2a52382020681eb5  release/kernels/divchw.ccvtrace
7f2bd115ee6e895f92d8b55b54e7fd0030d0188ab034d6c0c12ba76de2a9759b  release/kernels/divchw.log
58a541797f7a2df0a1c7528ae6a3edec212db90c7d3eb20656806f38b5c10b3d  release/kernels/divchw.oracle.jsonl
0d73e89818085b288c8da365c187c1274f1a220117549674e3bd62825e8c808f  release/kernels/divchw.sv-hosted.log
6e8a6ee38f70efd99a45ef982200047573781946148b48634e4f601df494cac8  release/kernels/divtail.by_instr.json.gz
d03cdeb072bc1612d90cb631a58c4218ccb0acc6b300e662161ad84a209f8c40  release/kernels/divtail.by_unit.json.gz
2ade202d8c5fc071687f18239b0573f55461d1606452ff6daa16db3738442f2c  release/kernels/divtail.ccvtrace
1b866129f2ef661cfadcc78285ed02dde5517745afc7f614ef91b2144224c0b3  release/kernels/divtail.log
75f11a75c9b3b336e446140af4579f05b46c363a76b7aab3ec88154a07ba097d  release/kernels/divtail.oracle.jsonl
cded3c93d7f30df78e3c7845e3c3d23b580dabc267e272bcd5d9f12f830ad2dc  release/kernels/divtail.sv-hosted.log
7cd1869a37db79adc66ff0ccfc3999008e4185ab82c51f00db4ebfdd442566fc  release/kernels/divtail2.by_instr.json.gz
ea0943e4c5fa0f9e1b030c3e0eebcbcd53bf73736effd904b99da1cd923040c8  release/kernels/divtail2.by_unit.json.gz
e27413844716e2c50ee7f69833576c60a6fb7bc226660dfe365677c387affdcd  release/kernels/divtail2.ccvtrace
3e5675af188ca2adad8310f5bc9280154e104ef89f9599e67dc2046e3943e223  release/kernels/divtail2.log
b2db6b05eb6cf4a0a7677e31d0c6c2952d5cab49d353f0bb1883fe0b2a20ed14  release/kernels/divtail2.oracle.jsonl
9181a59e4b072b3f332641c7fdb4bca001973d4e8993ffea8f01a866540450ea  release/kernels/divtail2.sv-hosted.log
a68dfd8f1acbbc2624a69a75f111df4dbc3bb3130bc91a198c5e281868765065  release/kernels/fence.by_instr.json
5f81b5e0849e9cff47f45e19aede69f20497967fcf16c416d0e58fbb71742888  release/kernels/fence.by_unit.json.gz
75d288101524697c62b629766796f3bda9ede1d58f5f69e04cc62a8b44880886  release/kernels/fence.ccvtrace
26bc41b47fea35f145d7a612cdc031725d191e6bbcaf01d73d4e7d3e438fb36b  release/kernels/fence.log
d1d40317f6cf5bfb430cda1f9c0ef676609e59cabe2a11623c42ffbeca93142b  release/kernels/fence.oracle.jsonl
242774cee163153ca6d50e62a2526a981ac42995dc89b1e786c6ae4a1c5ba9ff  release/kernels/fence.sv-hosted.log
ef0c5ddcfd497f4ef6a34cdf30919f90e84a112fcc9720a5dbdd6137c3e9297e  release/kernels/gather.by_instr.json.gz
6bcf8ba1d0d4c41227db983ccce8be7b36cf7533daf0599ea8a8206d327d3c00  release/kernels/gather.by_unit.json.gz
47ca404b23eb64de1adbcfe57bc2b361c77c990fa2b712cc708b348461ce7d25  release/kernels/gather.ccvtrace
cc1b70f4a79475fd982e031c9b5aefb5c6d772f9036c6639cc0f8a624a3067fd  release/kernels/gather.log
0413e781d8d6ff578c64eb1f800b7931e66f676d5cdabb97b94a4033e6037662  release/kernels/gather.oracle.jsonl
2dfdc810bf4ba20187ab4a549ef51a19159ca54196c7340d16f1e623812b5885  release/kernels/gather.sv-hosted.log
cca02037842115267073c365fc34b7460d73977b169557d4d17d0a12e4766ec2  release/kernels/hit.by_instr.json.gz
a95d36bf795f526d8fe046f9b42f5f88acc8c4c57ae04dac53722b64c23b47f5  release/kernels/hit.by_unit.json.gz
5011d098cba3f4cc0117cae56d925a5a6c11b6c9ad8e4df7283b855bc4c1e3d0  release/kernels/hit.ccvtrace
fffe60ed6068f4a0b3ac426b8e124270e58c7d0a0d91edf1c7c3b54c209b12a7  release/kernels/hit.log
7ba9603e0088d9164de6528f16ef6a7fa9ce5821c8c12b52cbb3734e39b9fd52  release/kernels/hit.oracle.jsonl
cc946ebf363301f0f1159f246c103f1089179db88c8d2120769868e57f74f98c  release/kernels/hit.sv-hosted.log
d6ef123cfb9f0e1ed7eda52ed6f1d8faa02fdbff26ae5d01df0ea32bb2b6322d  release/kernels/lanectx.by_instr.json.gz
99693b427135f8d069355af6bedcc4b5e233205e984001b69b87950fdeb32eb8  release/kernels/lanectx.by_unit.json.gz
38b638138d49789a0114a19069fca3c638317e1ed3cfcae93e790c1879f31134  release/kernels/lanectx.ccvtrace
ca0b24c9ec28ecc2e7ddb1b64b5d92b63a715ef959ce05e88461481581220b85  release/kernels/lanectx.log
888551babf540db8e3025b82e65ca655013f93eba3c8a65689d069d52a7e6039  release/kernels/lanectx.oracle.jsonl
efc2440308d88617e95f979a1252fd06cab9489e9ead2c16e6833398ba62f935  release/kernels/lanectx.sv-hosted.log
da6f528c17e19fd0d6f5c1469ea088373942357d18aa72c670d15d72190812a3  release/kernels/lanectx2.by_instr.json.gz
60c064716515edbc478741449607241226a2b6727849635d861ddc0c7a11521b  release/kernels/lanectx2.by_unit.json.gz
55a38537956e68cb89c80901bab5d4f647d2d051271228725d420f98b3d6f965  release/kernels/lanectx2.ccvtrace
cfcf0c8a8abe27216eec525b29642513c9e33b4b562bfc2ee12a879ec833a069  release/kernels/lanectx2.log
45c13056dff5c73ed0c9ece56cc36f929bf335322193c7d5eb38710b1d1dfb02  release/kernels/lanectx2.oracle.jsonl
c13323b618bd1986afb84a428bafd738d35d6faa78a06f1769a9c9bf83a6ecfe  release/kernels/lanectx2.sv-hosted.log
e88f0bf050e2a3dd09551d90c9b8252aa31ea3397c1b424c32b22a128a80d09b  release/kernels/late.by_instr.json.gz
549fe6a67ed1e7b810a559b47e82fd3b019930d5f43c8f23ee7236fe3ec7ec60  release/kernels/late.by_unit.json.gz
708eab59ff19a6088e42faa385d3680726020772f96cfff92c7ab8b3ef0fe3ac  release/kernels/late.ccvtrace
4025e5239d503bbeae5280cd4d4131792dd306e9dd588d8cb8a3e9ca1b1ae2d9  release/kernels/late.log
86084f6bd747a2cf32acbc0ebd96ebd3e4ef2d8d9e21be49e3ae49290d7927f3  release/kernels/late.oracle.jsonl
00074220e34e46067b8fb28c04d2fa3455d410d3702a6358169c368e36fd648b  release/kernels/late.sv-hosted.log
a7670c5f203353db79a092946b13292879e8c0efd9e440e40425881e1def3e1e  release/kernels/ldpar.by_instr.json.gz
23c54270b4b8a0fb824e373b70ab625f9d08b0c91f724f817f53acffc7160d78  release/kernels/ldpar.by_unit.json.gz
8b80f0644ce546519b2907f4eaa06ccf24dacfb174a0929ae5b16e41cca94a47  release/kernels/ldpar.ccvtrace
90d84a5b28ebf44dd4ec3e0e01196137a489ea1363b0dee2921c19c0873a2258  release/kernels/ldpar.log
8ac08538e9c807637babd61b31e340f7461878ada31f0c0b83cd66331cfaf486  release/kernels/ldpar.oracle.jsonl
8d4a29fe55cdcc4b28dbb1f2bea9a5066319cea89c041042d1e3db7956e3aa26  release/kernels/ldpar.sv-hosted.log
b228a174884cec9d837b196a8d05d94ffe4c12664f93e718b142acbc838c0081  release/kernels/lnorm1.by_instr.json.gz
85baa4857c73069f67a317fdf52b67dc58aafdbe00666d1b8b033654441f63fb  release/kernels/lnorm1.by_unit.json.gz
41cefbf6fc216f42006bc6d78b47ff712bfe8e07655d8ff0eda29ae1ce48cb14  release/kernels/lnorm1.ccvtrace
f8b5035dcba212be56d977387f29d1b367c902e701f26fbf809da0ef81c66a5a  release/kernels/lnorm1.log
a8d85811af988a1b9fc00db1517300af3d93ec8e589e403d3b9113fa9e0ffc86  release/kernels/lnorm1.oracle.jsonl
a9c3880113c33bb14745ba09d3721a1d7963257756475aa22f94d160b9276a9c  release/kernels/lnorm1.sv-hosted.log
feee699a8b1778d10d02fd2f0ccd3b1bd3f6c087f5e55ec4e3892f4a7f4a30cb  release/kernels/localsp.by_instr.json.gz
71d5322ac22e1fe6793a2b5c1f96f6441b50b5ef58301763f92fdf9490680ebe  release/kernels/localsp.by_unit.json.gz
840a02860217e94676ce0f9b4f7deaa171f545040a1e151a6180092e5c350102  release/kernels/localsp.ccvtrace
f9bd1e64dee7c39d81367e795bedcb202f51ffa2eaaa3a2eb3d952ddd8661171  release/kernels/localsp.log
55e3c9f36e7f7d38c0ddd38903aff4bb4509ae862015c592e6b937ea258042ca  release/kernels/localsp.oracle.jsonl
91a50e5d1b78016f2bfa69a84f44d49acdbd176f1db96a3dd80839fe203138c5  release/kernels/localsp.sv-hosted.log
43498b19daf122240c0a5d091d634441f0d8d97279cce566d9bd2ed1e4dca67f  release/kernels/loop.by_instr.json.gz
8003e89cdb64e3e5938607180b9c633a293e7f4168aeac36745ca54d95e2fc9a  release/kernels/loop.by_unit.json.gz
05599f989c0d60da6bbedde81701aa56ae1c2a56bbb878bbddeca9829b14e167  release/kernels/loop.ccvtrace
256e0fc77999fb09eea7482846dc514f454777470a8e0ba53808598172661bbb  release/kernels/loop.log
03ce5920c06c93e93516d8e53c3f7169f14e3593de204eacceffc0b8a3e32016  release/kernels/loop.oracle.jsonl
3acc917ebdaf256abc03a2b3d905a4229ac65e934d62bf38eaffa732910e2be3  release/kernels/loop.sv-hosted.log
14b2a28f0f41857f8c4563ea7bd4af3e7836157a8ac43ca4760388e722120939  release/kernels/merge.by_instr.json.gz
24d7b472271883fbf8aa7567e9045be6e6f46c4533ab2fbf817cb715f3a68bef  release/kernels/merge.by_unit.json.gz
2f43408ff2d9fff8512adaa9e24aae50158636b35dd1778e07d3a003df283170  release/kernels/merge.ccvtrace
375f01929c8125d0a18070e38b6bb4bd2bb33d23e49f7807eb46e902189877a2  release/kernels/merge.log
f96d28815f8756b1f5a45ded53e6170883d2dfa10f9eef0d14b8050b1318164a  release/kernels/merge.oracle.jsonl
5f40f62a3386c63c6a4273a7e1a04128130b161519467bae970b4f3a49c205c6  release/kernels/merge.sv-hosted.log
26d24196063c11963967459b1d0ee47bdc294caf0b2066834d73a050062ddf4f  release/kernels/missrun.by_instr.json.gz
2136e811835cfcef59175d805aa2ab6aaaa89d6d34ebf78fe6e462cf2fe96f84  release/kernels/missrun.by_unit.json.gz
9b9e962099b538ac683b0f9ee8745062f8642478667cdaed17c5bc301fa4b958  release/kernels/missrun.ccvtrace
51be92a006f6c859bc64c9a6e1da5d2e503f470ff4fb287feda40d0230c0ecb2  release/kernels/missrun.log
531bdaf281e5590774bd2775427f25e4cc0419cf8e3d5b6999843ffe9ef87258  release/kernels/missrun.oracle.jsonl
ea0485f0df4dba324d42726a70758c52b75af334c1ec9b8bceb1dc2b40aa61ee  release/kernels/missrun.sv-hosted.log
17f796c38e707c5bc487f3f876a90ac581d42083d529e3df1fca4e1c45804cee  release/kernels/mload.by_instr.json.gz
fe561943836085a749566b2ce0088a4c26f9661ee3370f3202c33dd13d1cd6b2  release/kernels/mload.by_unit.json.gz
063b6cceb78f323833fbe9eb0ae6ddab36c499214e9f131972fb171c4a6635c1  release/kernels/mload.ccvtrace
bbe3e79ad469f0f8b1bcb7df084847ddb97240b037bff88ae6833da011f2cae6  release/kernels/mload.log
8000e477b9a95dfb9f0af964e8346acb9d36f1358fd06ffc4ff7cf599d2b8868  release/kernels/mload.oracle.jsonl
cc7479c3cda2b779a843d6496b3bab5070b70f685f202a931c80e5b4d4ab2d0a  release/kernels/mload.sv-hosted.log
bd7666bc57427c68d99fa1f86eee084ec68f02cc115844e10624210c939b8889  release/kernels/mlp.by_instr.json.gz
a6b9d21178f84bff531fc151a8b169e8b69d7f1ea57266e7e445830b55c9a8c0  release/kernels/mlp.by_unit.json.gz
aede18b99a8ef2fd3eb1a13a65eaf43d36ff06abb3a58918e09fc2b96603f970  release/kernels/mlp.ccvtrace
04e279d2d37d4d7f97654089f1c95fa9500920adb0f93863d929ac401b51226b  release/kernels/mlp.log
138d282f88d56c8ad648a91af0a983254b55d9fa22942c00d47b327f516a6e44  release/kernels/mlp.oracle.jsonl
05e17d4b00d469dcedc65948c8c2503f75165cf7d2b90437ed9f22ab89e50c27  release/kernels/mlp.sv-hosted.log
610b07309687f410da4f420a3cf17d537dc5dbfc56bda4511b747dc20bbacfa7  release/kernels/mwmiss.by_instr.json.gz
9c645798d2524913a9e51a76a8c287f5f0256e01f62bbb44012c81e69459669b  release/kernels/mwmiss.by_unit.json.gz
07115621016b81197a7d82243ea67b0e4ffb1c62234943a6cb1ebb0f5754f97b  release/kernels/mwmiss.ccvtrace
9fac590f862630cafa0d3492e5bc88510e1969c78f56452a5f549baecded3e05  release/kernels/mwmiss.log
8abe8e8997456a2a6711ee72da54d854b24e20abbdab28e4b7271c0d28418de8  release/kernels/mwmiss.oracle.jsonl
7dc6e2699213b42d67af7677999ad9636aef34bec6cdb447355db3b2157e3e8f  release/kernels/mwmiss.sv-hosted.log
1dcc9f36a07242fd3c4b3b8b831417b70f58af19e5d947ebba0ad1c41436e5a8  release/kernels/narrowadd.by_instr.json.gz
777dc95bece1f1dffcf2ae137d385f40d5d2a6702af206447fa7e6d47a48a688  release/kernels/narrowadd.by_unit.json.gz
9fb6b0e4fd44c50cddfb175667f0007ea22477bc19dac16c69044d29166a3e94  release/kernels/narrowadd.ccvtrace
d94533b906218997681e67b9b8407368bcfd514ebc213c2754dea8951277d82e  release/kernels/narrowadd.log
40a2cf629853dd404bb06b4a07e35abde3d12efc13f26ffe28f923daf2994574  release/kernels/narrowadd.oracle.jsonl
d6b3bfc9e2296cdcd15387ecdaf4dd8fae6bdda97b6d1061fabd55a1a5876cce  release/kernels/narrowadd.sv-hosted.log
f69c2784459c495d92568c84121ed52ea34b97eb0e05187a14c96f3506e7ac24  release/kernels/pguard.by_instr.json.gz
fb7869b6e3582f9bc07dc66e46b9436155fc5394105e8e7bec759fe2eff66d15  release/kernels/pguard.by_unit.json.gz
76c80d9b923da749e657472c323bb7925457bf6ca0b9d035e7be2d6c43f865c2  release/kernels/pguard.ccvtrace
da6603e9bed1b50e54822b68f8a28019877a582e38eef3f5955dcb207d44cdcb  release/kernels/pguard.log
690e56f1cb8d97cbf67124b7dff3ad0a90cb8981814cd1709cf0cd0e035b3bd9  release/kernels/pguard.oracle.jsonl
57b3c5468ecd1e0f098ef5dc98ce510e0bde23b934814abba2c70b602c4ce394  release/kernels/pguard.sv-hosted.log
4ad61a01b3c6bfee3b3ab2f0a7576d44f0078428344594edbb87fab390f5932e  release/kernels/plog.by_instr.json.gz
6ea0089d989cc62eeb23eb8859a3ea403d937aced5c175b00a7c490194a494cd  release/kernels/plog.by_unit.json.gz
ce4aec9a797ce6e24a9082c3c4e22e4cc45d2bd6d9cf47ffadb3e8da5e251eb9  release/kernels/plog.ccvtrace
054b469b99d56f1fa81e8491200ea9be1e4ee54ab6708f01a8db452a73babb17  release/kernels/plog.log
0c99915e2da60f4670da00504a6371d7d17701d4431e733a3ff8fa98a2030d6a  release/kernels/plog.oracle.jsonl
ee957f5593c4b80dba62bbb6316d942d85b19e1920e865fceaade9e36f3cf546  release/kernels/plog.sv-hosted.log
1ecab93b94bfc559b4a6b52563baef7f198530c4c22e80045fb6ac39ef37906b  release/kernels/pmovdiv.by_instr.json.gz
63185413b96547002cfb4637dbc80262f6775e1e1512d74fab7ca3082d7282ae  release/kernels/pmovdiv.by_unit.json.gz
4fe481c67584f36b72d1f510fbace5f75fa34ca8d76713e16d393f8638f099f9  release/kernels/pmovdiv.ccvtrace
af96e4d8848e73cf6b688b0c6d971a5450e537faa98433d244a17d1eb6595898  release/kernels/pmovdiv.log
7bc646cff6166a51bdce03d7c1b7209e871f0a91d743083a9b910a80bcd0b33f  release/kernels/pmovdiv.oracle.jsonl
73b2fab0a86f52ec4eac2e210effda63ea9e7cf1e21df9b96443cab3d4074b8b  release/kernels/pmovdiv.sv-hosted.log
787bcf56738ab47aae05a0e46b56144d809aa42ed264915b2b336d8d573067f6  release/kernels/predlane.by_instr.json.gz
5e3bc1b0e7ab16c03d9e8f037fee78cad48c2e01a8e161b59412cdb426669fe7  release/kernels/predlane.by_unit.json.gz
31e398c8ca9e00b52f34775614df2a8f6907d972802170125e143a8f5a44630a  release/kernels/predlane.ccvtrace
17f54e2aba6dc046dd258f061642b1b59964ea6ad1866439e694e2b7bc669abe  release/kernels/predlane.log
c45f4177b9e84fc8a6e36b13534a0c7636eb30a3f8531847100ce5e23bf404b1  release/kernels/predlane.oracle.jsonl
202650fb8a20c5804cb899ca9e48679c1270ee66e303ca3504ac3faf49911f1e  release/kernels/predlane.sv-hosted.log
fdf0b319ccd4ecedfbc752037d7091fe77a040e026ba02300827252e73463156  release/kernels/predmerge.by_instr.json.gz
acb8967a0d647e76880190a67a33cd95d385e7e8603899c0cb3c1efdae850503  release/kernels/predmerge.by_unit.json.gz
d773aa91af7cfa2400e67801a569c10b730b800848cf39adce1a17e4661f83d2  release/kernels/predmerge.ccvtrace
1fdf842dabeaf22cc077ca39dbddefabba7b36c5aced69d84c94e73c897f9565  release/kernels/predmerge.log
6c737c49434bcd08e3e0814c8b1dbf15c586ae74f7929ba3148ddcee2c62c845  release/kernels/predmerge.oracle.jsonl
81e56b02228ea60a13811d24b302921784fbe54254e6ca584ad8174efdf80ecd  release/kernels/predmerge.sv-hosted.log
eac73df7d1b67bb4cdbd1a8b80d65a71ea128269bf219b1ac67be31d829a88aa  release/kernels/predspill.by_instr.json.gz
b82e4c6ec6d6da417dab2cf82b384bc1c22b3e2850cc0f1a22be11cdd71ebac2  release/kernels/predspill.by_unit.json.gz
cdfce89e12c318ef72106f545ec9b013ded5ce6f4872962abdc1a3f1d2709672  release/kernels/predspill.ccvtrace
450b9cbbf39805b4557c47de50b1b444db852862b79f41b15afbbc884180abbc  release/kernels/predspill.log
b7c84c6478117ffa0f06da0e6ad1e4628e2683426a7911080810e78e06a5242e  release/kernels/predspill.oracle.jsonl
7ae4c7f575987d672fd95136bbd8213a67172675b5759ef056a2b4a21c01ce8e  release/kernels/predspill.sv-hosted.log
4a0b8576dd7f9d4f7b95277d12db1419d42bb19576090a211bc2617f969140b3  release/kernels/predswap.by_instr.json.gz
da427247d7ada43ba3fbf38a11d1e2641bcb0b7333adb0753a71c3a596a2bc29  release/kernels/predswap.by_unit.json.gz
f4fd6e17f0b13b345cc0f5960d1c2b7b01e970ce9d633f1f64766cc3e71777a8  release/kernels/predswap.ccvtrace
db2952a8ec5708c97cafc46d4284382cbda98b9b26f36d2e07fa7143e8afef97  release/kernels/predswap.log
a6d4f7ed517553816d889c7c9eeb6bcfd1f6c973fbf682ecb69f3c2de619f7bb  release/kernels/predswap.oracle.jsonl
218e3d60106d10b0a1868cb079887c02449f0209edb5fb905abcc536d0a8dbc2  release/kernels/predswap.sv-hosted.log
a6e82af938d79bed04b28ea36943ee5fa869a4b99d44d1550cf4b9e6f303cca7  release/kernels/privwin.by_instr.json.gz
ddd057b1775e6539d1c6255c2280b114cd8c96cf3efc6b5fac0555aa41b835e8  release/kernels/privwin.by_unit.json.gz
06bcfd4da72397acae9618efbdadb649360bf9a1d8a2870e8abea67a46acd86c  release/kernels/privwin.ccvtrace
3f0a5445240fa5203152b45333bd05f88f63ddeea31382698b1d08a9c37c6244  release/kernels/privwin.log
861f686fc4480363472908d679d8815e8c957d768e7ab32c826930527b0fb7a8  release/kernels/privwin.oracle.jsonl
b26385ea71be00164112d67e92fd9f27af15e1052e0eb46343acf4a3d300b285  release/kernels/privwin.sv-hosted.log
0da646aac0434362dab6ded6e38f3eea5e16d1efb448af561f0f48897613c12c  release/kernels/provswap.by_instr.json.gz
1bdb21527ef7dfefbea456210f4ce5afe923286072a9d168940021b84ec9e113  release/kernels/provswap.by_unit.json.gz
da6430684752e474c41f1faa18c499203a31eff2b1095c219a0528bd52f74318  release/kernels/provswap.ccvtrace
480825beeb45a56b0295c65f26169fdd8d812451759042055008003e0b6d30c4  release/kernels/provswap.log
c9c32a793d54cc7401477f582487f7e8b345b2669a75337b8d6327120d98e5dc  release/kernels/provswap.oracle.jsonl
ff1b65d90b49c68133b75856631970c6a93286798f85d1370835f7e0f74d9d10  release/kernels/provswap.sv-hosted.log
57ab5ccc521083e0eea9bc99d8c572b91ff8b242cbb780576f93c18bb70f03df  release/kernels/retmiss.by_instr.json.gz
ed64cbf6c5ae1570ac451b4e385b2d7279d4f0e92a2184d72db67594dcbc3aaf  release/kernels/retmiss.by_unit.json.gz
5985cba81aeacec538cf723cdcd560c10f311f11f2c202b71bed4594317f580a  release/kernels/retmiss.ccvtrace
aed7c50dd6185269cb08f3a8ad4b4c227d971fefebf93e0dc8e7cd8cf70ebe3e  release/kernels/retmiss.log
e5ef8538e838c6cff7febfc679dd091cf5e002f82d34f1009b1948ce22bc3649  release/kernels/retmiss.oracle.jsonl
62f8c6432e075e8f631dfdfa922da82b216db4a2d258a3b74ddd37f99883e2c7  release/kernels/retmiss.sv-hosted.log
d45b064f90b496adbbbf3be694a8cc4f6af4ea41825c8bb83b0c4042da5a369a  release/kernels/roconst.by_instr.json
b38b6900712bfd3ada68a6b3627c4ea3fe521aef042fc47dd43dfb23bb1283cf  release/kernels/roconst.by_unit.json
f3713f83ec2f195b035033bdb47cfd76ef95bbcac2a975d18c8e17e3b3ccda49  release/kernels/roconst.ccvtrace
0679746b04f95ce63254b2210d5202556fa081637456fc1f06fa8ca4c726fb45  release/kernels/roconst.log
8087c0671de620162881aecd38cd6114b78e7be6bd71201e3ec02c9a2e2e750e  release/kernels/roconst.oracle.jsonl
a032fc22369a122c82a03d3791bc191cb6f977bb4882ec365850819f73463fe9  release/kernels/roconst.sv-hosted.log
7d213047dc11229803ff907bc5a2192cad3a16f993fe7f5ae66bdd5e6ec74442  release/kernels/rogated.by_instr.json
6f96b62fdc570d2fe4d80f2075136b9ca957b2ffd1a5e3ac0b16187892eae163  release/kernels/rogated.by_unit.json.gz
e0022bd67a6d629144891b56607860fafa98ac1de5fa80dc411be11a44c9a890  release/kernels/rogated.ccvtrace
97d1fa9a351298710442acd8a8a64c647124fdb49fc01d2c16712447a7ea1ee4  release/kernels/rogated.log
7cd02bd4cceec5a044d6b4d6a80df1e68ed0ae71b0b2a953143636d5b809ea6c  release/kernels/rogated.oracle.jsonl
5b01d2f225e511eb144a5c125b73aa9e0a34dd130757d51be65633762c09172b  release/kernels/rogated.sv-hosted.log
50e4aaa4f75c2ce3a9aecfa35aeeeaa59d2526b5bb6b4a3aecb9c336f8f9ca62  release/kernels/rokill.by_instr.json.gz
82006c15d417934a8ba51ce3e3158c179f92db4506695be5bb5026d71bbc50a4  release/kernels/rokill.by_unit.json.gz
cb434c89178bda63feb85c508e8cbd1b00bffd6b69525ab858d2b11b6cf16c17  release/kernels/rokill.ccvtrace
e8aa5d4a86e610c9a6b2e75d71c3427d12a4b8c6b21031f10499a92662c6049c  release/kernels/rokill.log
94efcef96af469a512d346ce61623980fe86383188eaebd55120f716db596f14  release/kernels/rokill.oracle.jsonl
2210cad6ebcf19ccc60606130362dd650fb7ea076de761aa80ba96368d15c1bf  release/kernels/rokill.sv-hosted.log
f8fe604241644b224e6431d16e4fad889c99826b82f49205e4c9014b9ae62e8a  release/kernels/rolaunch.by_instr.json
12e5281971b0a06ca95d953aa22a6d6b481d8fee948f50ab777c87877757fe46  release/kernels/rolaunch.by_unit.json
32fbf77dc8fb17f0113b068b5a00568b6ea97be3ad8e5bd1c69b7cae2f04a946  release/kernels/rolaunch.ccvtrace
c541b5c2d635f6b9d434c80e47a74957ca07abe2f9db96d0ed7a960368e006c6  release/kernels/rolaunch.log
e7dad585c3e70615de04330fd03f4f282c29a005dc1732a35655fb261d51139e  release/kernels/rolaunch.oracle.jsonl
1a9f17d8b8f4e5031863e6a2e4655cc9872221b2ac0ba651c438918bcd366e2c  release/kernels/rolaunch.sv-hosted.log
d45b064f90b496adbbbf3be694a8cc4f6af4ea41825c8bb83b0c4042da5a369a  release/kernels/rolimit.by_instr.json
e8822066a61bf10f59647aa7240a3044f25d2eba55ac5f7ebacbf1901974dd8f  release/kernels/rolimit.by_unit.json
0e8db555321feaf0fded659de3d7ab35b3dadb15ccef4bf8dabfaec2e87a5563  release/kernels/rolimit.ccvtrace
47076f3b03c56884130ff8e7dd2383c00f0a550b719a9318c26582c32063f268  release/kernels/rolimit.log
1c5bc0cb8e8b2e69505fb5a551a16d5d10c56f232b88da7a27e336ad7d962de2  release/kernels/rolimit.oracle.jsonl
9ff9e92089e5eca82dee2fbed5d593a828abf644ef6c2b34b22b316dfd422826  release/kernels/rolimit.sv-hosted.log
6748072145b054f24fa5e3ad8ac86d4d868b668f778acb94c505c8a265ff2eca  release/kernels/roload.by_instr.json.gz
b55c390e03068179f82c45c9cff7b0990909604ab61ee67c21afd578a3297428  release/kernels/roload.by_unit.json.gz
d030ac67b1dcde0dcc21aad32d53d84415c253aeea08ff0736e55b0472fc9a6e  release/kernels/roload.ccvtrace
137454b84a47de56574f45b3f14ce6784a30ee7a48eaba3479dfabfdb2c1a153  release/kernels/roload.log
f7c1309cc9764769fb5803f6fd0f2f5e1eb418f2d23fbe5e17cf5f9106869fdf  release/kernels/roload.oracle.jsonl
1681c93bfad9d5d476e82e4abfa637420ffbe123330f1fca3cbdc71c3628bbc3  release/kernels/roload.sv-hosted.log
7295e0b9da87f17d5b4d4011a74647cd70888813364d393ed730d8beae90a000  release/kernels/rope.by_instr.json.gz
5822c598d47044f2b20783ecc534f928f0cb2beee3a3d88a1fbd00535abaf95a  release/kernels/rope.by_unit.json.gz
90db2134b4e357edfb11d04eab1db3bac1df8d49147062f0b2261bd67c98d329  release/kernels/rope.ccvtrace
a33f6f198ba133998bd621ce66e773ad0b5ae01c307663c0bf82f3808c55c3f7  release/kernels/rope.log
d55f9efae392dc8877c102c01c0810e7654b666b6ede386328108164c6cf88f3  release/kernels/rope.oracle.jsonl
0a901c33c32b82ff0f4bf6aedec4133c0323efef610bdd789dec31dd2cf4bb50  release/kernels/rope.sv-hosted.log
77c7d19d5d057cd70f0fbb9adbb96225ef188520804ba5dd7a23d1ea8923352e  release/kernels/ropediv.by_instr.json.gz
f7a760eb240473797739a684b633c95bf76ae648d97cded0d096e61823f0ae61  release/kernels/ropediv.by_unit.json.gz
59ed4987e87f7a8d3d8cc3e44d0d4c7656d4e4141d93fad181f6ab787cbfc1f4  release/kernels/ropediv.ccvtrace
d5ef8d06e5617bc4ae151e34472bfd34a6e0570767f42ff18e803c8da5305f21  release/kernels/ropediv.log
10c0ec6ec18b7b44638c790033109198c079d07c1537bf193353ccedd00a920f  release/kernels/ropediv.oracle.jsonl
97daffd0c2b989757d9909439786abb433da43657052c37f92e02d827100093d  release/kernels/ropediv.sv-hosted.log
dba246cde3b1bff02687b0c75e90fb49b76400580df150dc3b1e9048c08a3e58  release/kernels/sel.by_instr.json.gz
5a412c8bb46e65d184d268880c3e3d51362202abcc457f31d2880f9aaba2d4b6  release/kernels/sel.by_unit.json.gz
f69acddacc3125d3e11fd4aafb2fc5b261c80835845fb78b60f67f64a5c8e306  release/kernels/sel.ccvtrace
7ea474b0a7db96b32e539c989cfb85430bcf1e7ab13d9bcaede8a1c55157841b  release/kernels/sel.log
87f6a81e8afa004c8039bf2f61c90176fcf29ab29bb17ac44aa016a5cc8438fe  release/kernels/sel.oracle.jsonl
dfa1d5a0d2808d0406d42113d4e6f1a80d054aaa21e4298612524c0d3853a5dc  release/kernels/sel.sv-hosted.log
37d315b0d59c7289bb4a5b7ad94fa6707520aa4cc840d312cae5940cc40d6368  release/kernels/sized.by_instr.json.gz
55e2e431bc0fa0f47ff8883e5679a8d2144f2ca90a6c25732ccd53d4fd58815a  release/kernels/sized.by_unit.json.gz
83699a01b9287225cb5e3f2d7dd42d973dd28f7f8a19ac0e7f5d79ea579c3a87  release/kernels/sized.ccvtrace
0f35b188f3f0022a98c4c22095904057434e1f3fb18a011af958ee02733c25ed  release/kernels/sized.log
36d903ba1618bd1faa437c9812a6ee6c0c966a63196c796267d74bf2695ebc3d  release/kernels/sized.oracle.jsonl
f1aead3d046e790087bc23a31bb5b911e3e983abe79f6ef29f3c69bc10562ca8  release/kernels/sized.sv-hosted.log
2a73bcd44b24cdbf315fa118dd49719066e625365a09f90c6c016a4a350b08cd  release/kernels/slotform.by_instr.json.gz
b6184aaf759f368d92f74706468045657f0265a38b43471a65a237071829c9fd  release/kernels/slotform.by_unit.json.gz
0be187f819f74f94910916a1406ab9d374eb386431e1c0bc67bd2ec80c1ade76  release/kernels/slotform.ccvtrace
5a6a7faa54a71a0189741fbbd2d72a93bc21d16be38d617a05a220622a8f4596  release/kernels/slotform.log
8b61db7419b18cea8a646fb628218447e72e84a18a9891ffb73b441736138ab9  release/kernels/slotform.oracle.jsonl
f8c3c82efb96e3d19b9ff1400bd0401e4f18c2eeb4f23c4b2a7ee0c173d55b2f  release/kernels/slotform.sv-hosted.log
b0c55b983a490228025bb29fc34280d2b9d608680001e9361310dc3d8cf6b4f1  release/kernels/spinwait.by_instr.json.gz
4cb0a0e7a1f94096925ea8fbd3f8b429c0e201b3998f6bfd93f38eb1c94dc6d8  release/kernels/spinwait.by_unit.json.gz
a61af4122d1ae273dc004961623affdefbd80e34f3b1e4068886b24192819437  release/kernels/spinwait.ccvtrace
16d817efc81d99df1ac7fea7ec1baa32f81d0d30c924145167108e595d55187b  release/kernels/spinwait.log
868920637236c878b33779bd450439466fc3626996a3164573dc11d437d5c709  release/kernels/spinwait.oracle.jsonl
3117038af8452e4f8d30188a7c5fb7d40013d76ca843478fd2e3bb1f6cd6b292  release/kernels/spinwait.sv-hosted.log
9cd5dc29c71c02c9f1ba6f67df051406769b332f1d1c4f141885b79590492489  release/kernels/spmbank.by_instr.json.gz
87e8e09e5d9fb342cb9246a18806e9815606cd033887758605642886ac5b32f8  release/kernels/spmbank.by_unit.json.gz
c9e0541d73a86ace0be2c7140b58c219c67cdc59ea3c535408d630297cbaaec6  release/kernels/spmbank.ccvtrace
5a27f49a76e0b563c234096843d2a131c876e95ef694858e9f3a467f519cacfd  release/kernels/spmbank.log
3af490cc37d7a92dbe719b57de216b648536eb301ff9d13de9a39f50d150d725  release/kernels/spmbank.oracle.jsonl
9dc207d1f4c73d690159b7ba46b72704a9f5a7af583923ce0844738dd6869918  release/kernels/spmbank.sv-hosted.log
e148eb53bf6998caff682ed16676fbe09ab35dfcee04ee8115cdb0e98b26d5df  release/kernels/srd.by_instr.json.gz
62360a0d3b3b0104892f3e401a21741f2f418e8c2f6eea8833b6bb081083ce97  release/kernels/srd.by_unit.json.gz
2d529edd3797ce92d489467d9dc64d33cf3c55188eb37a0a9950bb4ba92bf638  release/kernels/srd.ccvtrace
0b69dc82bfaf09c0e82282981d8d3c47c229cad6cab9fb4fee9158d62f97f825  release/kernels/srd.log
b08eb5e3673cac7eebb8b72af5ed3783c8e70a9e96592e76bf3722551bc79473  release/kernels/srd.oracle.jsonl
149c5a2e3d4477d373cb4d9dc96b76b58f486076ea169c4edd8a7b451a863c9d  release/kernels/srd.sv-hosted.log
6bed35bb07619a16152b31d9c7e6ec69434c9b98210601f0d2a3c90786a07d26  release/kernels/stall.by_instr.json.gz
315438eedfd53f9bed38f7ba35902c4823c5cf5f7c200579aa5399a1a13182cb  release/kernels/stall.by_unit.json.gz
22e627fc2dd72bcd88079ffab67b7916764ae53c67157e94b7fafb4213ddb79f  release/kernels/stall.ccvtrace
0d48398181b3095b3412dda23066a6340eb3ba8e8628ba38d35a96f92dfbba11  release/kernels/stall.log
500db2c482b07a0706583422cd68878301d0146c1f872ccc1f11bfdcf5c993ef  release/kernels/stall.oracle.jsonl
26629951c8a79dc4c78ac6b4fd35d30d62f7e3512f5f040a64282fb8a514e8c4  release/kernels/stall.sv-hosted.log
8e3c0fabecb047e9a195400a82c9be3874c3129624e20dd47854136ca0d2bd15  release/kernels/swap.by_instr.json.gz
cdb0c52b217ee1395e8f965deb71b5d564da939941ff3800f2ad61304dbbad1f  release/kernels/swap.by_unit.json.gz
112836ce22e7701dcc5ac587a0e46de205b080e21d770981443b853e2b028237  release/kernels/swap.ccvtrace
37c4274f0a2dde4611fcd3a8a66b671babf146b5a6539c05c0766125f09d9630  release/kernels/swap.log
3658a26316c1ff7bc1744304a42f736e930fcde2865c8913e6cc67a22ce96667  release/kernels/swap.oracle.jsonl
666dc0d42bd8dd6787b91e7be03164dbf4cecc19891f6ed6b5f6dc8ddddff862  release/kernels/swap.sv-hosted.log
82dde4666b373f34b6352da20b8a95bf941445c6e0220a789569d2c534d188da  release/kernels/transp4.by_instr.json.gz
2f56891c96841c139182ff3734bcab7bc77e697dc31f1ee33370653a8afdb5de  release/kernels/transp4.by_unit.json.gz
c31135f959534a20391942c9f7f659aa72c0ffe3e55398e0e82172cb97c9588e  release/kernels/transp4.ccvtrace
12ec525f23e67bca3701839670cf73f4670d995e9448fe8c8b0131b975f2f85f  release/kernels/transp4.log
06396ace3ac19677fd39c700e408606e5bdbacb24997d663bbe8872e63dd74fc  release/kernels/transp4.oracle.jsonl
5a1c8e980ea2b8a76c1e23270d81849d87e37cf29fbb46d7fcfe51262c1c02a0  release/kernels/transp4.sv-hosted.log
7fbcc5d11ce8aee299309812e07b85df658b3d764c88747ce6f8b249e463a60b  release/kernels/unal.by_instr.json.gz
873747454476709c7651a581bfd18a72ed673ee12af201fa99ce5ff736f279ca  release/kernels/unal.by_unit.json.gz
4c7196f44fe5fc262a3839f2465d765f9cd1a1945b6ae7f014dc9913a109610a  release/kernels/unal.ccvtrace
f53f0084f111ee3f5d8c0fee21516f5f3e30094938d7563b0cbd3160657bcd4c  release/kernels/unal.log
c3d484bb160657a563df983d9a2532eac27f556636617960aa1e72183ac2b299  release/kernels/unal.oracle.jsonl
67c14c23ac52a9519b31cb4c1dd0d5629865af36bf72570f89159fb748492b9b  release/kernels/unal.sv-hosted.log
c77d6edade9a5a1f45ff702343e03a88e739fb7899ad6c13fd451899f4e9d7ef  release/kernels/vadd.by_instr.json.gz
fe1d1086a82eefcf97d6a7cdd3c8e3ce0f81345503c08cc374c81369b8f5a143  release/kernels/vadd.by_unit.json.gz
337fa4548c95bc12220b38090639724e1dc9783efa9a15bba082252055c0ba5f  release/kernels/vadd.ccvtrace
99efae4dc9607e5e4943bb939d141eb78c396b79a8fbef8c485b2ce1ca272026  release/kernels/vadd.log
0276b6d0611a4bbcdc004ab3987214aea138245bc7217504147331689a9c0880  release/kernels/vadd.oracle.jsonl
36c568299c92d5640dba8988714180d5bbd46841253273c4f3558c170076d7bc  release/kernels/vadd.sv-hosted.log
8ab9c9735ef90f74fec10df394e0ccfa61d2849143f8eaffb14297bace56fa06  release/kernels/vadd4.by_instr.json.gz
09c1811f7f632e1c2d0fefbbc5d1fb1503295dfc6cf474a41ca472d7f86c57af  release/kernels/vadd4.by_unit.json.gz
cd543cad1585892ea9f01ae905930c371885ca4ec521038fe6cf46634cb21851  release/kernels/vadd4.ccvtrace
47b1f380b357ffbd4fdb2462674dbdecdc2c0edb444852fb7313279583d257ba  release/kernels/vadd4.log
225aa18fc9f38aa9ad615aa11de254337d59fa705877553d873062c68366e0db  release/kernels/vadd4.oracle.jsonl
6c68b7169d8155807972462d350ce0f7a266fc2f9d71cfff254e7a18d7e416d4  release/kernels/vadd4.sv-hosted.log
e8709a7ae8fe2f0d0676e78683b59c9145a64563832fc3fece57469d9bf54108  release/kernels/vaddslow.by_instr.json.gz
c2703ecbd93f4d74bb36dc1d1ccbf77161828dc6bbf5ca6c6cc7a2133811e0c7  release/kernels/vaddslow.by_unit.json.gz
9df6278f2274ae9c2e8b755a825a1fbcff72d152b8d86ae3a0b0924b3a4ceb96  release/kernels/vaddslow.ccvtrace
ef49d0cd5ec87a39a822d748267af44a31360916f079ceebf904180db9b4d387  release/kernels/vaddslow.log
e9e6218e8b8450e9f9ff6b39d659c994a1e51c527a0c5bd10d18b5658ae0e344  release/kernels/vaddslow.oracle.jsonl
ed5917bb9c1902dd12122a5d6e973b72b79db6c82f73805506c57a19f04ad74c  release/kernels/vaddslow.sv-hosted.log
1204cfcc09078311bd7c5113ce28aec5d657976364b6638a5bbccad7409f27f6  release/verify.log
56b3d8627d79d397ca06dfb57060015391cb95e52e925d1f09a4b2a7f4147127  release/wiring.txt
```
