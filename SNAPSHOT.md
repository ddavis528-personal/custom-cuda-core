# Snapshot snapshot-2026-11-15-6aa0c40

**A generated, read-only snapshot. Do not edit or merge it.** The source
is `ccr-9eb50716-lecnjf` at `6aa0c4031a48b07ffca82efc1e347df37eb156f0`, and this branch is rebuilt from source by
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
| Source | `ccr-9eb50716-lecnjf` @ `6aa0c4031a48b07ffca82efc1e347df37eb156f0` |
| Built | 2026-11-15 (UTC) |
| Gate | `tools/verify.sh`: PASS |
| Compiler snapshot | custom-cuda-complier `release` @ `e533ecdfabd1aa267e4cffd49a4d7e1e8c13b263` (source `45ce995c923e7267feb71d87f8f9c5edfefcf0df`) |
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
| `gather` | `name=gather finished=1 cycles=265 from_fetch=234 retired=16 issue_groups=16 order=ok gpr_mismatch=0 pred_mismatch=0 mem_mismatch=0 check_failures=0 class_violations=0 overflows=0 credit_leaks=0 cor_late=0 channels_used=31/55 violations=0` |
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
| `unal` | `name=unal finished=1 cycles=137 from_fetch=106 retired=9 issue_groups=9 order=ok gpr_mismatch=0 pred_mismatch=0 mem_mismatch=0 check_failures=0 class_violations=0 overflows=0 credit_leaks=0 cor_late=0 channels_used=31/55 violations=0` |
| `vadd` | `name=vadd finished=1 cycles=158 from_fetch=127 retired=17 issue_groups=17 order=ok gpr_mismatch=0 pred_mismatch=0 mem_mismatch=0 check_failures=0 class_violations=0 overflows=0 credit_leaks=0 cor_late=0 channels_used=33/55 violations=0` |
| `vadd4` | `name=vadd4 finished=1 cycles=204 from_fetch=173 retired=68 issue_groups=68 order=ok gpr_mismatch=0 pred_mismatch=0 mem_mismatch=0 check_failures=0 class_violations=0 overflows=0 credit_leaks=0 cor_late=0 channels_used=33/55 violations=0` |
| `vaddslow` | `name=vaddslow finished=1 cycles=547 from_fetch=516 retired=17 issue_groups=17 order=ok gpr_mismatch=0 pred_mismatch=0 mem_mismatch=0 check_failures=0 class_violations=0 overflows=0 credit_leaks=0 cor_late=0 channels_used=33/55 violations=0` |

## Manifest of release/

```
f81a2d3dde260074e410168f8bfdd419fe30e4bbe9327b36f0a28c6cb83a746d  release/kernels/addrhigh.by_instr.json.gz
9bb1150a90180f4cc8cf9b7cc35c0febb01faf8185a3bec50a96e04cd6cbf4bb  release/kernels/addrhigh.by_unit.json.gz
7f4025bfdc4a9e67d17c349cc2031239027d3a614a0080c15e41212d388f6c80  release/kernels/addrhigh.ccvtrace
8fc39a76ce864203492bca0206088e199fe5d936d4f1d95e04475f3e1c7d8576  release/kernels/addrhigh.log
569f2e22883fad5f0956c57ec734e6afbdd4b8a854e50277425172d6c0cbd766  release/kernels/addrhigh.oracle.jsonl
4d382cd58b833fd1582a421aff05009fe57b94c8be8d939722574afb28db49f5  release/kernels/addrhigh.sv-hosted.log
7ff7a6bd65a25659a8a1b815d8504fb8b139b110df665a4bbe86e8b5816d6d4f  release/kernels/addrlimit.by_instr.json
ec825e1aa533db01d6778b4cedc3d0b6d2a4485af86d802037be182be141b2f7  release/kernels/addrlimit.by_unit.json
2415076357c13d532727f342d8d78f9769f3996b44e4d63253d5779fe61d8f1b  release/kernels/addrlimit.ccvtrace
8626213454a3bb48b69a62bc05d5eb6f9ae8cd695f5c02a6264d03de63e3f5ae  release/kernels/addrlimit.log
bc660b0b40359a2c5a2478cb0eb4950b73fd22db50ea76b80052bc195a1920f4  release/kernels/addrlimit.oracle.jsonl
bca765360bd5257c51736d6cbd2cc049d9252f8e4ad402a7924cc6894cc145d0  release/kernels/addrlimit.sv-hosted.log
e7abe7817b399a7c2517f35ab48166e57586a5f46b99d90f11550210332bc0fd  release/kernels/addrneg.by_instr.json
55ad70974dc8a9ea0533a37b55ae47f2ab3280b5eeb9e4f5f56b2a2d355031f6  release/kernels/addrneg.by_unit.json
34b171591ba4b885fa0d843ce2817d49eb6638f478e426eb5b2947e4aabce7cc  release/kernels/addrneg.ccvtrace
3ebb3dbb566f6eea76965f1cb733a892e949b5cccef6b4d1b8219cc9c62824ff  release/kernels/addrneg.log
16f5b0707ae44492a1efd67bb9dd38a7e79a7bbd354fa9207b9e7d150ff2f107  release/kernels/addrneg.oracle.jsonl
d287e2be1c72a5ef173b002d3f70f87d9d3062cda161c550cb3dc113004d3d7d  release/kernels/addrneg.sv-hosted.log
bd6b14a7cf0f7a6c6b1b29975bb1c1fe00bdd0ec0e7eaf521b5d085c1b747327  release/kernels/atom.by_instr.json.gz
a5c9732b1f8598aa07407a321961c0ed67d62b1de08d2904ae49b44657ed3a74  release/kernels/atom.by_unit.json.gz
0bc740f47ce8f01033071f6055bec13f279a8d85482563042171f4c1dcde13c5  release/kernels/atom.ccvtrace
dd4061d6a91a4d5ce32cf36e38b4cb9a6b6380fe67254130919ea50497548a23  release/kernels/atom.log
504f5b6e9d25114dc35f2c70b21bb7b3f3c508c691de12dc0e87d12a74285361  release/kernels/atom.oracle.jsonl
367148423a86c8287215e9b65f1316885c5f7b64ae6adc3bf0ed2816f1a3c6fe  release/kernels/atom.sv-hosted.log
0b7179edda7bcedf817975dbcf697c7399ea28d2fe057aaf6ad58032c0777891  release/kernels/atomf.by_instr.json.gz
4c8f996e6e1f6014abfeefef586cf5e0000485253dbe99639563e4a58afd28e9  release/kernels/atomf.by_unit.json.gz
e5653fb345da7d3c5011117f46821bc6c2867d1d4c0f62e29a457666800da03e  release/kernels/atomf.ccvtrace
7dae64646feed8f6d7f187b616f220d985fe13d686d0b17cd35b4dd0a3da0143  release/kernels/atomf.log
cfd1179edf4061a33ab2f75d7a6dec61decfe629000198189a7bfc2647b34238  release/kernels/atomf.oracle.jsonl
eefb4b3fc46f9fadc0a996ccf62c7bcbb70c125c78da1bc47adbff7fee75f57b  release/kernels/atomf.sv-hosted.log
0a48f6095ff43b90d240ca336408765beda853b9c6b88beb99cf30b5cf47fe82  release/kernels/borrow.by_instr.json.gz
7a57ed66c9ed1e1199d7ac3f391257901a49b185c780b463dc797a54c20b866d  release/kernels/borrow.by_unit.json.gz
f47ba0ff76f39020aec6e50deb887c83af18cb9efde597aa3d2ebc7261eb3139  release/kernels/borrow.ccvtrace
23ce7e18d00e2f5caf1c531c6f748dd1f132602d1287a90f354686a875eca34f  release/kernels/borrow.log
4c565e1ce0b3baee36e158694b32c8defb5cd662b2f9af75cb5d8c26cb1168ed  release/kernels/borrow.oracle.jsonl
5b2fe921b9efa38425fb0c2783596f6ca954f661b64ad465a8312014129bc1dd  release/kernels/borrow.sv-hosted.log
b931b0e440983d2e0a91189dffb05993aa2eed0a58f5f210a17c482b71868665  release/kernels/brs.by_instr.json.gz
cdf6da2b6cbb9103726c5c61013500f00129a5a89bdcd6cdb52b3d60f06e65b9  release/kernels/brs.by_unit.json.gz
0efbd34762b9bb839d84507973259b9161e0b6b94498eb217ab8eb280dacf7b3  release/kernels/brs.ccvtrace
df3eb27c1f6e8e55fab463eaf4e865d024303a99797fb5b3c8d067de8cbbbdd3  release/kernels/brs.log
e3c1cb3379580cf1aae44e8ddc8e846ef6fd661a573cfe0a8d4444b18a14dc56  release/kernels/brs.oracle.jsonl
2169d67b01db74c239201b891ff178ebc6d785e597f4e86e67814bac5ed9bc65  release/kernels/brs.sv-hosted.log
7aaf1a4710a90b306350f266e09174a41876af253fbc041157001580e467ddfb  release/kernels/byp.by_instr.json.gz
598c7b4b196bc0f4874796411dc2ada1fcc86e22696e3bb7b7e1d0c98d715b74  release/kernels/byp.by_unit.json.gz
eeaeecbeffcfabb26607ba4cd6b679e552bee7dc964f95f3f62f7662d3bf9781  release/kernels/byp.ccvtrace
dcb4a5c5de4a68c1b48c242c100eb2d31d58000e487bf511229c2f16263806cd  release/kernels/byp.log
5a03dfa4f3603fef49f1e3639e74e34152ca3ca5ef8e41eb959f8323040fa2d5  release/kernels/byp.oracle.jsonl
a5c13a96c7022845008c00d95ae942111bde2ed2d7bf2c55e152cce85b59933f  release/kernels/byp.sv-hosted.log
2b28e0d76a1671de0f78840f16869438a75cf69413674ed00f432eb488ee794b  release/kernels/callret.by_instr.json.gz
a239fa3d98ad64ec605909776332a7c5f543a01bffd3ec06fc996187f338b526  release/kernels/callret.by_unit.json.gz
b7b7eeb3e6d53aa18dca668f0bd9f2a6a499f69105bd8e0b4f645473e8e03fc4  release/kernels/callret.ccvtrace
a17231739bb74bd5fd8e0f39351d43653cae2ded95692db2a4ca8a9aec9b09ba  release/kernels/callret.log
9b1d1b50b527f732362f837250aa2f26dabf3e76e16a4794856ebd8f105635b8  release/kernels/callret.oracle.jsonl
2fe37479392cf64f9698d0677c8e9974f91496facbc7fb51390d7a1587e13a6d  release/kernels/callret.sv-hosted.log
be24d901f5b21c7e993f3bd02b7092a0d4d356d52cd5a3db34dd04847fd1ab74  release/kernels/cas.by_instr.json.gz
cfe44135030c24b1c34307e8307c16da7060192314f2234b0eb297fc4dce161f  release/kernels/cas.by_unit.json.gz
5877d648cbd8cd3344bbeb0cdc1aab3baf484763a7027f4a0402a924a8efc846  release/kernels/cas.ccvtrace
2d7c6f6ef04d945e3138fb70669d159f0beab8ad85bbfa653f7270a7915fbf00  release/kernels/cas.log
0ab31a9443336fe5d08e1a5fa5fcba3bc279b19022f7c5007908d39d8ef39536  release/kernels/cas.oracle.jsonl
9e3137c2fe50023a119be6b02d5beafeb7033d2af8fe437554304fe81998d5c0  release/kernels/cas.sv-hosted.log
53d5376de9da7633d95cdb95030aeb70d78772477b6f5b5d3add7d400db7d4fd  release/kernels/chains.by_instr.json.gz
d1d3f425138fd295b21c2a37d8e1ac929fa0e5b28a2ba106a9bf77837cec36ab  release/kernels/chains.by_unit.json.gz
b47e10902de830c337bf591bfc2daf06098880741b67957d8e8dd9c45208dc56  release/kernels/chains.ccvtrace
e3819e3f364853c265cc5dc6cb81812601e137cf927f8840228956462b0048d3  release/kernels/chains.log
26a4cc5c5524c7219d8706c2582c80357dea60be9d6ffdec99dac7d0365e2264  release/kernels/chains.oracle.jsonl
36e99b0e5f5f056e2b8fe9c40ee9b6683a032807e479ea34acac43d5b417010c  release/kernels/chains.sv-hosted.log
05cf822d77af0187b72ebf816acf9ec9e68729c721f4b25f8bb7880fb1246ee8  release/kernels/coll.by_instr.json.gz
7510e1e67f0954388225403db8d6b8c73212ab088a9aeca1686ac417080f12ee  release/kernels/coll.by_unit.json.gz
9b2defbca3a81f102a07f1fb1a9473253e58da6ab1e7375a8d81f4d1fe098bae  release/kernels/coll.ccvtrace
ff279df467d30f0ad82df233495730bb4bb1d1b94ae04867ff22832e38be77c2  release/kernels/coll.log
dd718d23c88df5dc7d92b055d8542865aa0e029118486af127312a8a578cfcbc  release/kernels/coll.oracle.jsonl
1c5457d53fd12bfd99e22bbf161404782a9a1ef0e1ca3321e715646669f88abc  release/kernels/coll.sv-hosted.log
29b145b3b157f1d614b9a94f6183f815581bd7f433e1f4ce740f078acf7bab59  release/kernels/div.by_instr.json.gz
d2e18c7948159e8690af40566a52610a2f2adb1715bea0b3f9b47a092fd65f1e  release/kernels/div.by_unit.json.gz
182346c5baad147767effbea67248ccbc6e5c35582f0590ab266ce10e6e9dbc8  release/kernels/div.ccvtrace
37702de9efbc7f119b4292747e12b73268b5441558318dfa5cbe4970c06dcbbf  release/kernels/div.log
71a567b85cf85622631490187563de9a5661099c78a590adff4ed0a0c3d24c16  release/kernels/div.oracle.jsonl
238cf2d5423149e6dabb9368996d5c10ceaad890f5cf610d44c9e09362abeef4  release/kernels/div.sv-hosted.log
62048da58e8ce43ec121b0756ac706a7484b4c08f10ab840baaa0358c81dee67  release/kernels/divchw.by_instr.json.gz
92b1c2d6ea0faad5d617082be102d31eef27614f20a9d3620db783024c983772  release/kernels/divchw.by_unit.json.gz
4471a48e9f9555ec3ff526316b30290fb0ff75d28588185a2a52382020681eb5  release/kernels/divchw.ccvtrace
2c6a9b8837746742f3d693d4e2bbc2028201afbbbd78936a8c87dd3e7b7711a5  release/kernels/divchw.log
58a541797f7a2df0a1c7528ae6a3edec212db90c7d3eb20656806f38b5c10b3d  release/kernels/divchw.oracle.jsonl
47c7ad3c45467c2cde7c9e4abec4bb2a3a063584cc9567ba2799b104f4341691  release/kernels/divchw.sv-hosted.log
fbeb8ff0272eff35bd9708d541f5cdb7bbce8c5a08454086ed9dafd95fb3a8ea  release/kernels/divtail.by_instr.json.gz
80ab25b0fdfb9c26ee68134b4b5f4ddcef23a7c1624dc40d61c9d2f64c95e1f0  release/kernels/divtail.by_unit.json.gz
2ade202d8c5fc071687f18239b0573f55461d1606452ff6daa16db3738442f2c  release/kernels/divtail.ccvtrace
61fa0687051eed473ec82783c8a26497b41cddabc072eb05f7de6aa06f87daee  release/kernels/divtail.log
75f11a75c9b3b336e446140af4579f05b46c363a76b7aab3ec88154a07ba097d  release/kernels/divtail.oracle.jsonl
6ddfebe09af2c7eb4d8a927563e9ccdee76d19f6b45a2da488afa235ca6eeda0  release/kernels/divtail.sv-hosted.log
0dcf41e25a20f89b8246e24344708c5dded8969503d9dc8eee97475bfd0235a4  release/kernels/divtail2.by_instr.json.gz
4da7275c8db4cd51b4fe8d579e080907cd973917018604b33df4b11f070b5203  release/kernels/divtail2.by_unit.json.gz
e27413844716e2c50ee7f69833576c60a6fb7bc226660dfe365677c387affdcd  release/kernels/divtail2.ccvtrace
f4f6582891ac7c4b7afd42828ac709775e8b974ae565b34ee71a77c68e2bb1ac  release/kernels/divtail2.log
b2db6b05eb6cf4a0a7677e31d0c6c2952d5cab49d353f0bb1883fe0b2a20ed14  release/kernels/divtail2.oracle.jsonl
092e54505e02e67af56085b5e40df75e3af8114014ee0e803a09793de6e803ad  release/kernels/divtail2.sv-hosted.log
7ed7898e468f05a58ee4a868919f8464ca5a672cbb98c6e9d739843a64cc4af3  release/kernels/fence.by_instr.json
22bd5447f8421a0541f356635009ae76e762913513f698616bb19e968974399c  release/kernels/fence.by_unit.json.gz
902d571234711aa609de8947a424a60e599755724ff6b2bf6bdf1550cf10ecf6  release/kernels/fence.ccvtrace
7f4ed869a9de68ed0b21f41a40c6df884e821161e0195728d97cd1438380528d  release/kernels/fence.log
d1d40317f6cf5bfb430cda1f9c0ef676609e59cabe2a11623c42ffbeca93142b  release/kernels/fence.oracle.jsonl
06894a4ba0064538bf12f4942b2f977b2a2a03755a3029dbfee8de8aa3edf2e8  release/kernels/fence.sv-hosted.log
e41ffd1c3edd52ff097b27ace840e49e317774341343ac4b97350c2caeca36a8  release/kernels/gather.by_instr.json.gz
be3fe03d5c500e0b2b6afc701957fd0ae633d418abe1f7f8cac3bdbd600f1ca1  release/kernels/gather.by_unit.json.gz
b18f6858fab89811b536e7fcfc1ae27ab085da4e8b5d315aea9e2977b70c6d77  release/kernels/gather.ccvtrace
fd29e163b7ed58b43884e6ab23d41619f574a114db23536f198e7d78ac503555  release/kernels/gather.log
0413e781d8d6ff578c64eb1f800b7931e66f676d5cdabb97b94a4033e6037662  release/kernels/gather.oracle.jsonl
1dc3cc3cc9d5f93015876405ea18f33348851d6916ea10d9b99c25aacd0335e7  release/kernels/gather.sv-hosted.log
c1fc79b7bf73ea4dab4a7a3ba5af8963073f10e5d1c3cdabd6dd5262841c61c2  release/kernels/hit.by_instr.json.gz
521c5dbed6ddd2b664bcce3f4cbd5cfc3d47b89608f38eca3a077c4d233aec01  release/kernels/hit.by_unit.json.gz
98c9906228e2e5518aa7236d91a3a7bca159d7e359394877c1f58464b6cddacf  release/kernels/hit.ccvtrace
9b822bb8bfb5db34caf529058345bdebb78be9e7e9b1291a183f646ab71d372a  release/kernels/hit.log
7ba9603e0088d9164de6528f16ef6a7fa9ce5821c8c12b52cbb3734e39b9fd52  release/kernels/hit.oracle.jsonl
5f273e32edbd42bec6ddd2251a4e605bc9237fdd1fed6a47959f0d020799690e  release/kernels/hit.sv-hosted.log
1467de125c1e66b10ef930cbbd69bfabca87d3f0f7d39094a5c6b42b845f0d8c  release/kernels/lanectx.by_instr.json.gz
50ac31980ef3b5ff75c671405b406b3ec63706d0e794ec4bfa6c981a20794eee  release/kernels/lanectx.by_unit.json.gz
04cb909321122accc72a84a88ce06c11e76a20160502594b50a562bafe82b1a5  release/kernels/lanectx.ccvtrace
972895cbee194aca65505ec2550b33357a4c53ce7353dbd93e10c2b346786d7f  release/kernels/lanectx.log
888551babf540db8e3025b82e65ca655013f93eba3c8a65689d069d52a7e6039  release/kernels/lanectx.oracle.jsonl
0af17d546585af8330705c82a12e6f1e7a4649df1d9e8d51bbc7e797db571ae7  release/kernels/lanectx.sv-hosted.log
37363f6ad33f3532da3fbacac5b5c3605e56f0c16f7b194ca296fa797de91711  release/kernels/lanectx2.by_instr.json.gz
e48c93719112cdcb3dd734dbbcf095d0db7974bce1d82873357e95a4c76163f7  release/kernels/lanectx2.by_unit.json.gz
ef023c0267cd5d07b71c47b7a7879f569ee3c013aa6d0e14a776bf7dd08e305f  release/kernels/lanectx2.ccvtrace
416c8425f24a9b8074128daf673b47ca65f9dae806a2d3a03b4f1adbb92f6bb5  release/kernels/lanectx2.log
45c13056dff5c73ed0c9ece56cc36f929bf335322193c7d5eb38710b1d1dfb02  release/kernels/lanectx2.oracle.jsonl
5988c99f8f5e17e37d5d6317a4ff431123ff752b243fc087f7e4e8c83db620ca  release/kernels/lanectx2.sv-hosted.log
a352fe65207e03357d0c0a691ff7e4a73f251c34ebf2c0a8eb7161ec82e5326a  release/kernels/late.by_instr.json.gz
543c348ff35155d44a4856989e9dcee3c44919492e206e43229f32e00eb0f90a  release/kernels/late.by_unit.json.gz
ed17289225ed3941140e1a934ee991f52da48ced93786696293f28335ea79d5f  release/kernels/late.ccvtrace
fca8c182a5d9921d92eca9f301b83fbfc22f353058c1dcb703ca44a97939914a  release/kernels/late.log
86084f6bd747a2cf32acbc0ebd96ebd3e4ef2d8d9e21be49e3ae49290d7927f3  release/kernels/late.oracle.jsonl
306401df85e229c298b76cc8c8742faa1edc7427dfc6b4c744ec4927272b2d2b  release/kernels/late.sv-hosted.log
e267d4a30e1cc73dd9f9aa2206a7514d9481bed7fe780a0e0c4631fd357f56d2  release/kernels/ldpar.by_instr.json.gz
5a440a296acd62fb06cb8c2241d57480b26dcbc20ea91bd98404e4a08e74a340  release/kernels/ldpar.by_unit.json.gz
8b80f0644ce546519b2907f4eaa06ccf24dacfb174a0929ae5b16e41cca94a47  release/kernels/ldpar.ccvtrace
5b64d1d6a7f4491ec36c90af394fe8e846a7844d75e6fbefec612fa0126db058  release/kernels/ldpar.log
8ac08538e9c807637babd61b31e340f7461878ada31f0c0b83cd66331cfaf486  release/kernels/ldpar.oracle.jsonl
dd94f6195a8f86165b767fb013585c8ec39d62b461816fc632cb5de900c1285a  release/kernels/ldpar.sv-hosted.log
01c73f83d7326d08e21b73ed92aa3a6181caac8be13f0edd931395fe9e14e8ef  release/kernels/lnorm1.by_instr.json.gz
78a7aede01aaa1ed742ec99a10b8ee1a649af30865408a492a9f06009c78ff72  release/kernels/lnorm1.by_unit.json.gz
65de4500bfb6a167ee95cb6995bf66e65d29de1cbf42795cd9705bf1e8114b86  release/kernels/lnorm1.ccvtrace
2c6476abf2a64389b39f5b66038623a7bde1816ae81cd814d5f70e315e3ad5e2  release/kernels/lnorm1.log
a8d85811af988a1b9fc00db1517300af3d93ec8e589e403d3b9113fa9e0ffc86  release/kernels/lnorm1.oracle.jsonl
fda1c4a49b207a21b2c233bf2c0cacb3a241d716843ba165f9eaefc066b06a17  release/kernels/lnorm1.sv-hosted.log
f537afda18a1e2f9f3dcc150cf4b51612f527f220e4940349c97c8df2e7cec80  release/kernels/localsp.by_instr.json.gz
da13d9dc1d05c941045a6afcc453607a3f191b66840e6b80f22ccdc53914bd94  release/kernels/localsp.by_unit.json.gz
c3afacbf731348687ea8114bbaa2a069115ae8e09d8c2c6f758f2a001ad1189a  release/kernels/localsp.ccvtrace
1b57910d2fd5fd4b24255b169ef5042028a08cb76a74920892975b78916f9d11  release/kernels/localsp.log
55e3c9f36e7f7d38c0ddd38903aff4bb4509ae862015c592e6b937ea258042ca  release/kernels/localsp.oracle.jsonl
a8b27dee3b76cdda0011c5fd5f4fac6602566cd08aab5a63a399232a3343d20f  release/kernels/localsp.sv-hosted.log
49abfa2ea5a923a2b570ec6adda7744d599a07000dccec1075fe6631f9384149  release/kernels/loop.by_instr.json.gz
3084669f9e82ba38652c6be1d9bd064803d974de2a3ac5bf5e9d027a3d5be62b  release/kernels/loop.by_unit.json.gz
05599f989c0d60da6bbedde81701aa56ae1c2a56bbb878bbddeca9829b14e167  release/kernels/loop.ccvtrace
aa058d27d67448675d390b0f65190c66017d19a6a80316f893f1572bc646db14  release/kernels/loop.log
03ce5920c06c93e93516d8e53c3f7169f14e3593de204eacceffc0b8a3e32016  release/kernels/loop.oracle.jsonl
210f7382791fee845dded69fba83d9f95e5ef2482bbdc2902612d3b4949e6372  release/kernels/loop.sv-hosted.log
8c59593995f7ca20aece085e90b072353cf38cd8eee9253d2dad06d181295d7b  release/kernels/merge.by_instr.json.gz
50d09bde36c192bdbca058575d9c50b062424617d43d12d01f85f69e1c73c0c9  release/kernels/merge.by_unit.json.gz
2f43408ff2d9fff8512adaa9e24aae50158636b35dd1778e07d3a003df283170  release/kernels/merge.ccvtrace
f1e339a51d707c8ce0e58f44d7bf6b454c96e396c7554ae7837861b5014f38d4  release/kernels/merge.log
f96d28815f8756b1f5a45ded53e6170883d2dfa10f9eef0d14b8050b1318164a  release/kernels/merge.oracle.jsonl
310e921ca29341f31868a10297b0b56002b6682dcddbca010fd1ddfb048a1a0d  release/kernels/merge.sv-hosted.log
949880bf3edd766020cc375013a39bf3907bf6cb144071315aeb5f84235de4e0  release/kernels/missrun.by_instr.json.gz
ff9fc2cf6f5658f7646768d6b3b4bcb291c3c5ed7b990d0c44d20df5fe851bc4  release/kernels/missrun.by_unit.json.gz
9b9e962099b538ac683b0f9ee8745062f8642478667cdaed17c5bc301fa4b958  release/kernels/missrun.ccvtrace
43755fd1c79d1754535db79f20857cef98090146df155e5692ba419918f8b894  release/kernels/missrun.log
531bdaf281e5590774bd2775427f25e4cc0419cf8e3d5b6999843ffe9ef87258  release/kernels/missrun.oracle.jsonl
cb0ac5860c88e30b9215638efd29eb006a036bec8d731e8db0c9102101d7e8f3  release/kernels/missrun.sv-hosted.log
1a97e132ba45407f7aadf8632998877362e7664c6ab77817708c590fc7b8ad34  release/kernels/mload.by_instr.json.gz
0d9c78b50dfda3bdfdbc57b91663e732c4c418af58a377818a09fae7c87ed4a3  release/kernels/mload.by_unit.json.gz
063b6cceb78f323833fbe9eb0ae6ddab36c499214e9f131972fb171c4a6635c1  release/kernels/mload.ccvtrace
5f068e8d278c796ff0b294102462834f70393eec1e3d8d9fa0ae86539873c65e  release/kernels/mload.log
8000e477b9a95dfb9f0af964e8346acb9d36f1358fd06ffc4ff7cf599d2b8868  release/kernels/mload.oracle.jsonl
8b344b0fc3c71db147d836d06e7709c11e1d0019e9ddefd4001b64369e44a9ea  release/kernels/mload.sv-hosted.log
e0c832a9553fb7c6624326cf0433a36cc6716c669e5427bc4eb446019b29f690  release/kernels/mlp.by_instr.json.gz
724a3b541177c684ce719bee1a94333506283ed2c7e67265cdd2b236f50ffbfb  release/kernels/mlp.by_unit.json.gz
0daece386ec56c1668841f0834cd6563f3578ff85d563e13c245840f9686066b  release/kernels/mlp.ccvtrace
0e5e6edac5168c672a7bd80c7985c86e8d4e8985abb0cd05b4db89d039d2d26f  release/kernels/mlp.log
138d282f88d56c8ad648a91af0a983254b55d9fa22942c00d47b327f516a6e44  release/kernels/mlp.oracle.jsonl
74609003ef01efb4fa1e1b067eb5041920b2ddd9bbabfb48ff290f35e1f48962  release/kernels/mlp.sv-hosted.log
f2e60f707ae5fffe26bfdbfc56ad4c660bff37aa2fe2c81efa0bb6681e121aff  release/kernels/mwmiss.by_instr.json.gz
b658cac219ba8de944a98d06defb1ae3934ddddd1087596135fb53eaf10c46ee  release/kernels/mwmiss.by_unit.json.gz
e7fbd5fccc236270780030692f3c7aca61d880121c841441200fdea549df8b74  release/kernels/mwmiss.ccvtrace
812aabd879a913ef2bc71da17ddee0554fed6a6c4f53b8e6915bb9f87fdab1a3  release/kernels/mwmiss.log
8abe8e8997456a2a6711ee72da54d854b24e20abbdab28e4b7271c0d28418de8  release/kernels/mwmiss.oracle.jsonl
c5332bbb674fc416e44f07910220ff74c20fd5e46c651d1d5e0ee6cd7d247718  release/kernels/mwmiss.sv-hosted.log
a42e3c5edc1807e216a34529a8c4c4e017b9f35a0e9887859a19db40627d9ab8  release/kernels/narrowadd.by_instr.json.gz
f24c306da0d100179a6d9719d29eca9dabc82ddc4b86390710fa2af551e857f6  release/kernels/narrowadd.by_unit.json.gz
8e7ce71f99dcc0f630366e8031dd77757986d48470a933980e2b91eda4d0f133  release/kernels/narrowadd.ccvtrace
9189d1a597b75764ce706a78e988f545049cb31901299fc4dbeacb2ed42a273c  release/kernels/narrowadd.log
40a2cf629853dd404bb06b4a07e35abde3d12efc13f26ffe28f923daf2994574  release/kernels/narrowadd.oracle.jsonl
99ee0dad703ca822210b44c0af6243b100bad2e503e3ecc9cb35d64328427817  release/kernels/narrowadd.sv-hosted.log
1b653616402aac0b54a95d503932912fac0c2d247696ac0b7d8a03019d4c7300  release/kernels/pguard.by_instr.json.gz
039ff9c6a5b8617dbda0f9909966de8979fc9abce09ce8b447b4924b121cd68f  release/kernels/pguard.by_unit.json.gz
1be32dfaa56dbde149ff08e78810d1e8adfc2d6b199d31a352930ba7859d0d18  release/kernels/pguard.ccvtrace
d0cdc08e87a8915efd855b3213bc045c3fb66f5bdb9521d658f022896c1ebf23  release/kernels/pguard.log
690e56f1cb8d97cbf67124b7dff3ad0a90cb8981814cd1709cf0cd0e035b3bd9  release/kernels/pguard.oracle.jsonl
f88aa0da94c2c51746afd378afb207cd456e237e9c6dfb259e21b067016cd120  release/kernels/pguard.sv-hosted.log
41dbd6d2e48e2fcf7876a99c4191da08da9b982d5b4e9e214647be37e65aa7d2  release/kernels/plog.by_instr.json.gz
dd656347e60311f6d1ddd02a7770c41bf3c4afaa0733b79177fdded808b71954  release/kernels/plog.by_unit.json.gz
ce4aec9a797ce6e24a9082c3c4e22e4cc45d2bd6d9cf47ffadb3e8da5e251eb9  release/kernels/plog.ccvtrace
5aeafa54bc4562ce3707e1af58c1aec772df79f21bb047d1a5df69a3d6bd201b  release/kernels/plog.log
0c99915e2da60f4670da00504a6371d7d17701d4431e733a3ff8fa98a2030d6a  release/kernels/plog.oracle.jsonl
c49c46221bd78a4c8e6e3534ad10b5304433df3e70e341f8d74de8fd3ede6a40  release/kernels/plog.sv-hosted.log
cc171d3a785eae806bb375a82d61d2a40db194da2bdf9272b8b7d6c906e34f25  release/kernels/pmovdiv.by_instr.json.gz
304f25de71fec1249cdc808d03582803a6b1e648c5cf250bfeafc773ac7abf4f  release/kernels/pmovdiv.by_unit.json.gz
4fe481c67584f36b72d1f510fbace5f75fa34ca8d76713e16d393f8638f099f9  release/kernels/pmovdiv.ccvtrace
4afbe8d976b891c0a974d3fd60cd85009a612b79879390fa70cc2813df80b18f  release/kernels/pmovdiv.log
7bc646cff6166a51bdce03d7c1b7209e871f0a91d743083a9b910a80bcd0b33f  release/kernels/pmovdiv.oracle.jsonl
7d6b535ec9a5b9806ded1da0404d9740ea62621ba0ba768232ab361c57922222  release/kernels/pmovdiv.sv-hosted.log
240e21f76fbb33c0c11df5536fe459b40880070940266098030d1878028eb58f  release/kernels/predlane.by_instr.json.gz
0eaab5ee82ee7c1f72bc8902fccc3ce441f38f01e375a9953ba44e589b6a8533  release/kernels/predlane.by_unit.json.gz
532a8a0c9135721ab0526accc4358e8fdb1ef57c82585686a0c80705acd1e51b  release/kernels/predlane.ccvtrace
cc464fcd6098e66133b8a715c0b347faa10784d98db7ae1de63adffe0948aee0  release/kernels/predlane.log
c45f4177b9e84fc8a6e36b13534a0c7636eb30a3f8531847100ce5e23bf404b1  release/kernels/predlane.oracle.jsonl
0701ad4537a6daad840dd9fabe888ab396e511c2d9d15557256806cb18ca36c1  release/kernels/predlane.sv-hosted.log
b221ca4d2ba6ff55784f72faeb4d5e0f16d4f2d69ff69dc5630cc2adc8f1d79f  release/kernels/predmerge.by_instr.json.gz
bf122c62d4d690e43cb1e4b1d6730c06e82ab5d3adf48d584e6b58fb740f3389  release/kernels/predmerge.by_unit.json.gz
d773aa91af7cfa2400e67801a569c10b730b800848cf39adce1a17e4661f83d2  release/kernels/predmerge.ccvtrace
87f0b3ca7e2ca2f9df55506e1a5dcfa22704a04a2b9885eed98e3cd754b6e421  release/kernels/predmerge.log
6c737c49434bcd08e3e0814c8b1dbf15c586ae74f7929ba3148ddcee2c62c845  release/kernels/predmerge.oracle.jsonl
f8ce4327955a9e2d9f68e034ec7e284bd79f5b66de430de4b1bdbe98892f2ab7  release/kernels/predmerge.sv-hosted.log
8203cbb3c396cb776fb45253bc16feec58ba52a36b1150f1cb3420fa5e598590  release/kernels/predspill.by_instr.json.gz
83ea14e26aa067eadf9d00cd54a57d0004d0d8e7b02321f43ddc8c3bd91c45b5  release/kernels/predspill.by_unit.json.gz
16f9f7de2fc64fca6f08e5e8adb61d48bffe5c691e60f1fc0d4431d744442294  release/kernels/predspill.ccvtrace
16181408a318661af407284750594db6c7aef7bc9d00f5947c6bec0f1c10a381  release/kernels/predspill.log
b7c84c6478117ffa0f06da0e6ad1e4628e2683426a7911080810e78e06a5242e  release/kernels/predspill.oracle.jsonl
b1b9352a1b3eaacb9a5551c5328c6d9621146add2c59e24f9f5963127ff74816  release/kernels/predspill.sv-hosted.log
13eaeabfc8a0bcd2145606a5913e0a7a93a7d3b7c6e50eed9fb48add59a64de2  release/kernels/predswap.by_instr.json.gz
72f33b897c11cc04605546d1a609d4b03858a2898ba64b80e0a455eefe3c322a  release/kernels/predswap.by_unit.json.gz
4e9508786e96eb05efa7b8430de268460957fb3c2f309bf753f6f1f2fe90967e  release/kernels/predswap.ccvtrace
39b2d447a2f74258e84c7d9604bea23eebc4bcfa6645035427f4d5de11c2f62f  release/kernels/predswap.log
a6d4f7ed517553816d889c7c9eeb6bcfd1f6c973fbf682ecb69f3c2de619f7bb  release/kernels/predswap.oracle.jsonl
71a3142ced1c7738f0b8715db4afc6c6f6c72ffff4e650df68b468a481d9e683  release/kernels/predswap.sv-hosted.log
8a11c5bca7a766bf4959c69cf9b2a05f439bf6e0dc4a129858206e24fa74670c  release/kernels/privwin.by_instr.json.gz
094930b46e6015555815c72b8efc15b374e621ae11659e98216454f2fb9d0ff7  release/kernels/privwin.by_unit.json.gz
5a26c95cf8ae0fd61ee2c9451346a7802325aab2e90a257156448e57f9ef655d  release/kernels/privwin.ccvtrace
9b86557f17904e27081360e0e79eddb90ed636aa0658f5ce6033016f38d703b1  release/kernels/privwin.log
861f686fc4480363472908d679d8815e8c957d768e7ab32c826930527b0fb7a8  release/kernels/privwin.oracle.jsonl
e130c665bd9799eabb27f695ab651ae06ad3459cd9f7aa6cdc5e905fbd356899  release/kernels/privwin.sv-hosted.log
686c388116aeca6236ad0326186a94526ea9533755d3ef8bf5a72fa0377b0aa9  release/kernels/provswap.by_instr.json.gz
7d1cfbde6ef0bd94a9390a8f21641b3799120fb180c97aee663bf1cc739ad484  release/kernels/provswap.by_unit.json.gz
4592f424d69e7ef4d0fdd224035e4488309b96bdb4b9a862a5016ab5a9aea5ef  release/kernels/provswap.ccvtrace
7f622436e46cc8229fa7fb965342b61b8c37f3c9c8a731a8e189436c0a036798  release/kernels/provswap.log
c9c32a793d54cc7401477f582487f7e8b345b2669a75337b8d6327120d98e5dc  release/kernels/provswap.oracle.jsonl
5ff01bbbec79c5ded6356348b80446ce32ac287ac64c484fdd397fa1ac1cad81  release/kernels/provswap.sv-hosted.log
2e304e3d9478cc08fcb2d4bdf9c2c7fd69af012aa71c1840b92dbbccc1256bcc  release/kernels/retmiss.by_instr.json.gz
7c47f130bedb7427986400302cd63aad0e94e0aabcecfc1ae7c6e02f6abb3182  release/kernels/retmiss.by_unit.json.gz
e045f7f1300e188d894150ea9a0611be8c011616f91acc5ddb51a953afbca960  release/kernels/retmiss.ccvtrace
83e1d553fa70bb1ed69fd6262d31ad7ce49d4408cb49cf2d1ef1c283ab114bea  release/kernels/retmiss.log
e5ef8538e838c6cff7febfc679dd091cf5e002f82d34f1009b1948ce22bc3649  release/kernels/retmiss.oracle.jsonl
93d6244c68d2b821d977973208ce1d03148ff0a347ecc75e1c2d02de6c896fa2  release/kernels/retmiss.sv-hosted.log
d45b064f90b496adbbbf3be694a8cc4f6af4ea41825c8bb83b0c4042da5a369a  release/kernels/roconst.by_instr.json
b38b6900712bfd3ada68a6b3627c4ea3fe521aef042fc47dd43dfb23bb1283cf  release/kernels/roconst.by_unit.json
f3713f83ec2f195b035033bdb47cfd76ef95bbcac2a975d18c8e17e3b3ccda49  release/kernels/roconst.ccvtrace
f80da2ccf4b10220be14ba529f33ac7da9323e1c06c8dbd27567e22d94007cad  release/kernels/roconst.log
8087c0671de620162881aecd38cd6114b78e7be6bd71201e3ec02c9a2e2e750e  release/kernels/roconst.oracle.jsonl
9e47a8b1c8b2e18d9d74e8491c70305bc451026388c395a49adaf60c125ccf62  release/kernels/roconst.sv-hosted.log
7d213047dc11229803ff907bc5a2192cad3a16f993fe7f5ae66bdd5e6ec74442  release/kernels/rogated.by_instr.json
c786c28108493e18742aa2a449bc5566c23adea5f69a8e68e80c72d088a74f8d  release/kernels/rogated.by_unit.json.gz
e0022bd67a6d629144891b56607860fafa98ac1de5fa80dc411be11a44c9a890  release/kernels/rogated.ccvtrace
89ab8cf0162df4277f3fd95656f995c4b1a4285a0a4817c2169f1b4cd7aedfce  release/kernels/rogated.log
7cd02bd4cceec5a044d6b4d6a80df1e68ed0ae71b0b2a953143636d5b809ea6c  release/kernels/rogated.oracle.jsonl
184c9993523265bccddbe02c0c9b2e8bf517f6f49ed64e9c2a68c1eb650374d0  release/kernels/rogated.sv-hosted.log
ddff5d988ebf5af6159efdbe831de14ecf6fbdcd21be8227bb03b8e4280cd43e  release/kernels/rokill.by_instr.json.gz
3d5c5cc14f28b7f42261d73b2cba566af805ca5e6c71ef2c7168a602c8649088  release/kernels/rokill.by_unit.json.gz
cb434c89178bda63feb85c508e8cbd1b00bffd6b69525ab858d2b11b6cf16c17  release/kernels/rokill.ccvtrace
5d8e2ee0544f40e1e3ad8ca8ba431fe5f3b0a6dbb34cfd2febe2aa957e505208  release/kernels/rokill.log
94efcef96af469a512d346ce61623980fe86383188eaebd55120f716db596f14  release/kernels/rokill.oracle.jsonl
fe97c667bea7318a72ae3a3a7dbba35392a3485c170aa5ec407497d5871f5144  release/kernels/rokill.sv-hosted.log
f8fe604241644b224e6431d16e4fad889c99826b82f49205e4c9014b9ae62e8a  release/kernels/rolaunch.by_instr.json
12e5281971b0a06ca95d953aa22a6d6b481d8fee948f50ab777c87877757fe46  release/kernels/rolaunch.by_unit.json
32fbf77dc8fb17f0113b068b5a00568b6ea97be3ad8e5bd1c69b7cae2f04a946  release/kernels/rolaunch.ccvtrace
6f5b143f479f66161354ecfeab97f8d6621f77befc260a4c373af7dc17bec137  release/kernels/rolaunch.log
e7dad585c3e70615de04330fd03f4f282c29a005dc1732a35655fb261d51139e  release/kernels/rolaunch.oracle.jsonl
9dad5a6be141ec9eccb362790abcb62b91a6ebf8ad38bf1922d26a448c9ea90f  release/kernels/rolaunch.sv-hosted.log
d45b064f90b496adbbbf3be694a8cc4f6af4ea41825c8bb83b0c4042da5a369a  release/kernels/rolimit.by_instr.json
e8822066a61bf10f59647aa7240a3044f25d2eba55ac5f7ebacbf1901974dd8f  release/kernels/rolimit.by_unit.json
0e8db555321feaf0fded659de3d7ab35b3dadb15ccef4bf8dabfaec2e87a5563  release/kernels/rolimit.ccvtrace
17f9164deaee08ab156a3962fc5be1133dd5376ffc832b32eb36284506561286  release/kernels/rolimit.log
1c5bc0cb8e8b2e69505fb5a551a16d5d10c56f232b88da7a27e336ad7d962de2  release/kernels/rolimit.oracle.jsonl
d9d1673022987d5148ee9e23fdc9bf84a29a2c57036beb5ed1ef3eaa948f1734  release/kernels/rolimit.sv-hosted.log
8c0529757cce7af46b8dc13aed536ffcfafecdcd7b4ec7474fb265978a8416fe  release/kernels/roload.by_instr.json.gz
d8dccc0392cd739bef3d6db652aceea5218890ef364f0dba43b858932602eb46  release/kernels/roload.by_unit.json.gz
d030ac67b1dcde0dcc21aad32d53d84415c253aeea08ff0736e55b0472fc9a6e  release/kernels/roload.ccvtrace
b3f5cc0e601bf5ab02ce4726834fbedb46558d864ea2397e1ba96e591164365a  release/kernels/roload.log
f7c1309cc9764769fb5803f6fd0f2f5e1eb418f2d23fbe5e17cf5f9106869fdf  release/kernels/roload.oracle.jsonl
57ff1d00cb9d374ac2486ac2585b234c58d75bdecc1b6e4288ce16de9e9f8a66  release/kernels/roload.sv-hosted.log
84b3d894f14532d1e60a63d9c6ff0c146d4570379c1ee7951463eccbcb8d5960  release/kernels/rope.by_instr.json.gz
917c1175756eb0c6daf63f79495191e55b5c47fd65b170603f37aeac0689b2a5  release/kernels/rope.by_unit.json.gz
584891d26d23d0fba957e57b7dbb5495f8910ff501588d852593e29a24214a3a  release/kernels/rope.ccvtrace
02a9900b673f9e95b51196c6a8f02cc75d9207891b07bc093da4bf4dad787d72  release/kernels/rope.log
d55f9efae392dc8877c102c01c0810e7654b666b6ede386328108164c6cf88f3  release/kernels/rope.oracle.jsonl
11052eeeec09c9f2618d1315fceeb2603ee7a6779c295406f77de6b9dbce4c64  release/kernels/rope.sv-hosted.log
29e517067c9e4a9a319998ed02c810e47214b97e0b6b16be068d9a666a3c9951  release/kernels/ropediv.by_instr.json.gz
4ff7a171bfab3bc3f9a5e1e52afa2b00edf24d3a8ecfc147871c83fdb3c7e594  release/kernels/ropediv.by_unit.json.gz
9db18a33f02c871696464eb48671e0197a922251c16e2c6490c74fa8636926e8  release/kernels/ropediv.ccvtrace
def0303ccb3744aaea75574f95c8291e33d1577ca9370c7f1359f35007ab6c41  release/kernels/ropediv.log
10c0ec6ec18b7b44638c790033109198c079d07c1537bf193353ccedd00a920f  release/kernels/ropediv.oracle.jsonl
a818811bd9eb33604ecf52453bae1b327f4283afec19fd4c13728d46ae78db07  release/kernels/ropediv.sv-hosted.log
3049e90222af8e8b69e2e90cf449d5ef4a1017c522b06283d1b05be4b98f782c  release/kernels/sel.by_instr.json.gz
116fc177b35f5b5bb99774671a52f7d28b9765b85172369274ea0e01ccc4b4b6  release/kernels/sel.by_unit.json.gz
bfbdf6055affcc6f1da5e0ca404d70f0e1ba25424943b4357452b1e5ed16df5c  release/kernels/sel.ccvtrace
4695ad783eac823af61bdc3dcb090fe133b823ed6c2cac00443153f9b1b4008c  release/kernels/sel.log
87f6a81e8afa004c8039bf2f61c90176fcf29ab29bb17ac44aa016a5cc8438fe  release/kernels/sel.oracle.jsonl
acf83859e70e54273e80ce62dbad6e051bfbb2d9fa724797e61b97fc995dda0d  release/kernels/sel.sv-hosted.log
2138b38fc2a88029c73cca15bb1e4df740b07db469dbe2337b6c9f1fd9ea95b5  release/kernels/sized.by_instr.json.gz
1c430ea2fa0dd7cae13748e191c131e365974d4b0f1dc9b859663ed8ca9afd58  release/kernels/sized.by_unit.json.gz
57bf5f53ed5983796fba2b24f6a7def647fa293dedcabf0e5d5433119d46339d  release/kernels/sized.ccvtrace
16195143bbe2712887b6d1c984829958a33e89cc84045e579d050b9637e5726b  release/kernels/sized.log
36d903ba1618bd1faa437c9812a6ee6c0c966a63196c796267d74bf2695ebc3d  release/kernels/sized.oracle.jsonl
d4d7f7d2e7c3f7d6671bb5c348a4ec1f13ce183cbd15db5fd2279ce8e4f23623  release/kernels/sized.sv-hosted.log
b67a933f240aed4f404930f7869c9a585666c7b1cd068bfc74bbd69c15ca8f16  release/kernels/slotform.by_instr.json.gz
9815438be82559dda0f380f7b91f765df38d8d3147019b424a16bbcdba91cbea  release/kernels/slotform.by_unit.json.gz
11724589fb8206925f7175a40dcf56f45a12a773807a16f6ee5b1aacb729e1e0  release/kernels/slotform.ccvtrace
0a428faf21b33aaf75db4ad29215333d9db8b6ad112b109a324f9bb3c3db5f64  release/kernels/slotform.log
8b61db7419b18cea8a646fb628218447e72e84a18a9891ffb73b441736138ab9  release/kernels/slotform.oracle.jsonl
b5df567f06e935a2546a03f5035394bb35299dd7c96825d54dc7dabff3e7229f  release/kernels/slotform.sv-hosted.log
b6f98a89568e8a4ce012a52eedebbdb270dbbed7a7bdb13221341d046b985b0d  release/kernels/spinwait.by_instr.json.gz
943fafc5bdcb39379546d0f9ca9573cd48565dbebf099dc8dd9d3d79d8b4a263  release/kernels/spinwait.by_unit.json.gz
68b1b41d270ff152174967335f750fee2aba326fd1b9f639b47db3e1a65da696  release/kernels/spinwait.ccvtrace
4deb84cbd405aae24e8a814a63eb94eab48ac3b0feb88cc6e57c0f12fa78492e  release/kernels/spinwait.log
868920637236c878b33779bd450439466fc3626996a3164573dc11d437d5c709  release/kernels/spinwait.oracle.jsonl
d560334ea45b71329ba74344c19f0dfc845a879d232f46bacd1e59bb7ae227ed  release/kernels/spinwait.sv-hosted.log
870baa8d85d0bec6ff5c6e890c553d6f7a35158587c678a2060cd3a13c1acee7  release/kernels/spmbank.by_instr.json.gz
21d379f861d3114c0cce03be7c4f2c566fe32b4e167ba13ad9d6da6697534d89  release/kernels/spmbank.by_unit.json.gz
c9e0541d73a86ace0be2c7140b58c219c67cdc59ea3c535408d630297cbaaec6  release/kernels/spmbank.ccvtrace
d235155ee2ff035a4f42c9edbf4f0f7157af805d4ffbf1c9910b2de6a3e6ebbd  release/kernels/spmbank.log
3af490cc37d7a92dbe719b57de216b648536eb301ff9d13de9a39f50d150d725  release/kernels/spmbank.oracle.jsonl
3d1cd5416d39efbfbaf7a5f3764b6d1ab5578c6b949dbbcecf0cb5289a73febc  release/kernels/spmbank.sv-hosted.log
c8bbfc8b1980abbd320ec3e1c045622320fe355a216c51e176115accdceeaa1a  release/kernels/srd.by_instr.json.gz
aaf529866aad1d6b822c649c8e13de02be4616d142fd1afd0556d70c2a8b41a6  release/kernels/srd.by_unit.json.gz
d238546574b90fbe0c75cbf57797cc2895661a7fe80c064873a7564e05062e66  release/kernels/srd.ccvtrace
3fc50d53bbbed49c8d2000d7c7287f8cc8a2d339604fab86ed6527021cefaa79  release/kernels/srd.log
b08eb5e3673cac7eebb8b72af5ed3783c8e70a9e96592e76bf3722551bc79473  release/kernels/srd.oracle.jsonl
f42fe40c60268d6741cd3d8540b34bca8b6c017afc74f37b9525e7f822f14aa9  release/kernels/srd.sv-hosted.log
e4c04d36c2d04add8ba0127b91678873c2ada2abc15751d658a5adbdfca9d442  release/kernels/stall.by_instr.json.gz
2b55a6b3b2bf5522874711f0a6f8da92565fd44d5fec37e6f52afe872db276fa  release/kernels/stall.by_unit.json.gz
31b3bf34b30210fffcfe0b18af39d30c58c6baf475adc93b02b20ba1a63de364  release/kernels/stall.ccvtrace
05fc2bdd969088b0b721d1e7397afc87a585a9f0fa50efcb1ab405b771cabc45  release/kernels/stall.log
500db2c482b07a0706583422cd68878301d0146c1f872ccc1f11bfdcf5c993ef  release/kernels/stall.oracle.jsonl
689c6c751e94c2949f5daf557fff36e23a1fa2cf0cf67af325718309482e9a1c  release/kernels/stall.sv-hosted.log
273a33b0a819a67ef1df421057d8a9628c4c8b38ae37ae6e345b55300a64df71  release/kernels/swap.by_instr.json.gz
5ac400622b4e0c9092e8536fa0625d6a42ee04c5996bec19e05da532b38ba6ac  release/kernels/swap.by_unit.json.gz
179a1988a2b645a3688357ccd83f3b651a1a5c831394420f2d247395886790d8  release/kernels/swap.ccvtrace
8b0ed167047b85220456277f5398f21ea0c243a87ddb901ace5def9c1a31e1ca  release/kernels/swap.log
3658a26316c1ff7bc1744304a42f736e930fcde2865c8913e6cc67a22ce96667  release/kernels/swap.oracle.jsonl
34335d3b0c9a08f033fda48420bfd44c075b3bf756676a6263965acb6417c5c0  release/kernels/swap.sv-hosted.log
e860619714fe8374bf3e8f07f7648d54433cd5b14bfd423121b923c334132c44  release/kernels/transp4.by_instr.json.gz
ebbd7cb6bed1bbc3a520d78ed9755279a3fe18894859a7a1d05fef5f8f372b75  release/kernels/transp4.by_unit.json.gz
c69297cf6b1d869a4c3a4862bb809be66003c458e9b6688d813a73b2b20e2138  release/kernels/transp4.ccvtrace
6c63ce7d759429092d8815550560042633d303a29a9d67d0c06329d2c6381426  release/kernels/transp4.log
06396ace3ac19677fd39c700e408606e5bdbacb24997d663bbe8872e63dd74fc  release/kernels/transp4.oracle.jsonl
eb0677925a127f106f65124499a8e372c40a98d7abb21dff57317597d3ac4d76  release/kernels/transp4.sv-hosted.log
896bc0ed64fbe03a1364b8df54b8234a0af1e55828a0aad7950a2bc3c775325f  release/kernels/unal.by_instr.json.gz
7259140ea8ef0d0f5051a848be980c555d9f35aa20517b3c285bb7f4bc03af9e  release/kernels/unal.by_unit.json.gz
459165935d7675da32b55b7c6131d903c0af1e6a4315d1c0cb30d77d0c0236e6  release/kernels/unal.ccvtrace
0aa827664af9d920e5320787d7d6a363ce3ad3d5da2fe2235b70053065665ecd  release/kernels/unal.log
c3d484bb160657a563df983d9a2532eac27f556636617960aa1e72183ac2b299  release/kernels/unal.oracle.jsonl
81be800834463776ad0a406bb6a1ac15c4cda67da5b6b31eb0da063c47194b71  release/kernels/unal.sv-hosted.log
4e882b8eb05c58622c3a3d706e7d2d79a2cee6e6ab5229a6a9ecd42c7609fda8  release/kernels/vadd.by_instr.json.gz
e19e6cbc5d05fe11a038673b3d1afeabab2ab550aa3cc69298b0297d9e7643b2  release/kernels/vadd.by_unit.json.gz
1950f0c6d6f11d2fd5a3b92d476e6f7a29a6da0150fd1ea3e0d8db7f60de3c39  release/kernels/vadd.ccvtrace
08492f7cf75fb32c65d73e738254806a79d84dd30cbfa737791113d0898b04db  release/kernels/vadd.log
0276b6d0611a4bbcdc004ab3987214aea138245bc7217504147331689a9c0880  release/kernels/vadd.oracle.jsonl
f76834c4063a7aec743c6e9059ea1406cbf99749e7666059ba7e632f8412b6c3  release/kernels/vadd.sv-hosted.log
a711c75286fe823bb0c7946a55949972f62810e2b06473022c3d23cecdda5afb  release/kernels/vadd4.by_instr.json.gz
1b056f9e9eb1c73465a39f7d44be0062ded97aa9f9a7ed4e1926653e70472482  release/kernels/vadd4.by_unit.json.gz
393f80312111a139a165706359cebd78a31d3d04139d4ae40fa29f8b2a8cd3d0  release/kernels/vadd4.ccvtrace
a7834c8897d00c47af7f11ac66be543325c0fcb3fb7df058163c59dc4a156c99  release/kernels/vadd4.log
225aa18fc9f38aa9ad615aa11de254337d59fa705877553d873062c68366e0db  release/kernels/vadd4.oracle.jsonl
e2ebedf6766c22bee4d9558448b2be5d1daed2ecd7fad3256337c4b4c07e0ba7  release/kernels/vadd4.sv-hosted.log
e31e1080843f2ae32842f20ef623a6e5f5f328c22f4a04820777e8f4d2ef82ef  release/kernels/vaddslow.by_instr.json.gz
a119447be48f0cf201fc80a62fedb403e8d1184bbf549835e3c38c7ad8dae1bb  release/kernels/vaddslow.by_unit.json.gz
1566691682a5da05ddb2adffd089a6baaee2143401a99bdbf0462da9c5c78b2b  release/kernels/vaddslow.ccvtrace
229a669a07d476f5d6f2d62897f60ecb5a2ce772678446f46d4fb7ddb873b82b  release/kernels/vaddslow.log
e9e6218e8b8450e9f9ff6b39d659c994a1e51c527a0c5bd10d18b5658ae0e344  release/kernels/vaddslow.oracle.jsonl
c90e03c3cb669b4971f95fa9a93d1b26fa3cb01be6492892773dd3c2b75ac811  release/kernels/vaddslow.sv-hosted.log
4938ca89043f255dcc0ae577a7fdb0b71b392181223c8785b2df95c05774a0dc  release/verify.log
56b3d8627d79d397ca06dfb57060015391cb95e52e925d1f09a4b2a7f4147127  release/wiring.txt
```
