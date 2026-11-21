# Snapshot snapshot-2026-11-21-55f24ec

**A generated, read-only snapshot. Do not edit or merge it.** The source
is `ccr-9eb50716-lecnjf` at `55f24ecef6513a2ef434918cb0162cce2a529a76`, and this branch is rebuilt from source by
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
| Source | `ccr-9eb50716-lecnjf` @ `55f24ecef6513a2ef434918cb0162cce2a529a76` |
| Built | 2026-11-21 (UTC) |
| Gate | `tools/verify.sh`: PASS |
| Compiler snapshot | custom-cuda-complier `release` @ `a293afe7d7873fb5d3fac70d8deca980e119b19f` (source `b9ae2c9d5d3b838d5d982d842b558e2d290185ea`) |
| Verilator | Verilator 5.052 2026-09-05 rev v5.052 |
| Icarus | Icarus Verilog version 12.0 (stable) () |
| Yosys | Yosys 0.33 (git sha1 2584903a060) |

## Kernels

| Kernel | Result |
|---|---|
| `addrhigh` | `name=addrhigh finished=1 cycles=83 from_fetch=52 retired=5 issue_groups=6 order=ok gpr_mismatch=0 pred_mismatch=0 mem_mismatch=0 check_failures=0 class_violations=0 overflows=0 credit_leaks=0 cor_late=0 channels_used=26/57 violations=0` |
| `addrlimit` | `name=addrlimit finished=1 cycles=82 from_fetch=51 retired=5 issue_groups=5 order=ok gpr_mismatch=0 pred_mismatch=0 mem_mismatch=0 check_failures=0 class_violations=0 overflows=0 credit_leaks=0 cor_late=0 channels_used=28/57 violations=0` |
| `addrneg` | `name=addrneg finished=1 cycles=81 from_fetch=50 retired=1 issue_groups=2 order=ok gpr_mismatch=0 pred_mismatch=0 mem_mismatch=0 check_failures=0 class_violations=0 overflows=0 credit_leaks=0 cor_late=0 channels_used=23/57 violations=0` |
| `atom` | `name=atom finished=1 cycles=8732 from_fetch=8701 retired=29 issue_groups=29 order=ok gpr_mismatch=0 pred_mismatch=0 mem_mismatch=0 check_failures=0 class_violations=0 overflows=0 credit_leaks=0 cor_late=0 channels_used=33/57 violations=0` |
| `atomf` | `name=atomf finished=1 cycles=4640 from_fetch=4609 retired=12 issue_groups=12 order=ok gpr_mismatch=0 pred_mismatch=0 mem_mismatch=0 check_failures=0 class_violations=0 overflows=0 credit_leaks=0 cor_late=0 channels_used=35/57 violations=0` |
| `borrow` | `name=borrow finished=1 cycles=99 from_fetch=68 retired=7 issue_groups=7 order=ok gpr_mismatch=0 pred_mismatch=0 mem_mismatch=0 check_failures=0 class_violations=0 overflows=0 credit_leaks=0 cor_late=0 channels_used=21/57 violations=0` |
| `brs` | `name=brs finished=1 cycles=99 from_fetch=68 retired=12 issue_groups=12 order=ok gpr_mismatch=0 pred_mismatch=0 mem_mismatch=0 check_failures=0 class_violations=0 overflows=0 credit_leaks=0 cor_late=0 channels_used=23/57 violations=0` |
| `byp` | `name=byp finished=1 cycles=118 from_fetch=87 retired=14 issue_groups=14 order=ok gpr_mismatch=0 pred_mismatch=0 mem_mismatch=0 check_failures=0 class_violations=0 overflows=0 credit_leaks=0 cor_late=0 channels_used=32/57 violations=0` |
| `callret` | `name=callret finished=1 cycles=265 from_fetch=234 retired=40 issue_groups=40 order=ok gpr_mismatch=0 pred_mismatch=0 mem_mismatch=0 check_failures=0 class_violations=0 overflows=0 credit_leaks=0 cor_late=0 channels_used=31/57 violations=0` |
| `cas` | `name=cas finished=1 cycles=6972 from_fetch=6941 retired=56 issue_groups=56 order=ok gpr_mismatch=0 pred_mismatch=0 mem_mismatch=0 check_failures=0 class_violations=0 overflows=0 credit_leaks=0 cor_late=0 channels_used=33/57 violations=0` |
| `chains` | `name=chains finished=1 cycles=96 from_fetch=65 retired=29 issue_groups=29 order=ok gpr_mismatch=0 pred_mismatch=0 mem_mismatch=0 check_failures=0 class_violations=0 overflows=0 credit_leaks=0 cor_late=0 channels_used=21/57 violations=0` |
| `coll` | `name=coll finished=1 cycles=78 from_fetch=47 retired=24 issue_groups=24 order=ok gpr_mismatch=0 pred_mismatch=0 mem_mismatch=0 check_failures=0 class_violations=0 overflows=0 credit_leaks=0 cor_late=0 channels_used=21/57 violations=0` |
| `div` | `name=div finished=1 cycles=978 from_fetch=947 retired=144 issue_groups=144 order=ok gpr_mismatch=0 pred_mismatch=0 mem_mismatch=0 check_failures=0 class_violations=0 overflows=0 credit_leaks=0 cor_late=0 channels_used=23/57 violations=0` |
| `divchw` | `name=divchw finished=1 cycles=111 from_fetch=80 retired=5 issue_groups=6 order=ok gpr_mismatch=0 pred_mismatch=0 mem_mismatch=0 check_failures=0 class_violations=0 overflows=0 credit_leaks=0 cor_late=0 channels_used=22/57 violations=0` |
| `divtail` | `name=divtail finished=1 cycles=642 from_fetch=611 retired=96 issue_groups=96 order=ok gpr_mismatch=0 pred_mismatch=0 mem_mismatch=0 check_failures=0 class_violations=0 overflows=0 credit_leaks=0 cor_late=0 channels_used=23/57 violations=0` |
| `divtail2` | `name=divtail2 finished=1 cycles=1517 from_fetch=1486 retired=366 issue_groups=366 order=ok gpr_mismatch=0 pred_mismatch=0 mem_mismatch=0 check_failures=0 class_violations=0 overflows=0 credit_leaks=0 cor_late=0 channels_used=23/57 violations=0` |
| `fence` | `name=fence finished=1 cycles=83 from_fetch=52 retired=7 issue_groups=7 order=ok gpr_mismatch=0 pred_mismatch=0 mem_mismatch=0 check_failures=0 class_violations=0 overflows=0 credit_leaks=0 cor_late=0 channels_used=31/57 violations=0` |
| `gather` | `name=gather finished=1 cycles=265 from_fetch=234 retired=16 issue_groups=16 order=ok gpr_mismatch=0 pred_mismatch=0 mem_mismatch=0 check_failures=0 class_violations=0 overflows=0 credit_leaks=0 cor_late=0 channels_used=33/57 violations=0` |
| `hit` | `name=hit finished=1 cycles=219 from_fetch=188 retired=17 issue_groups=17 order=ok gpr_mismatch=0 pred_mismatch=0 mem_mismatch=0 check_failures=0 class_violations=0 overflows=0 credit_leaks=0 cor_late=0 channels_used=32/57 violations=0` |
| `lanectx` | `name=lanectx finished=1 cycles=70 from_fetch=39 retired=10 issue_groups=10 order=ok gpr_mismatch=0 pred_mismatch=0 mem_mismatch=0 check_failures=0 class_violations=0 overflows=0 credit_leaks=0 cor_late=0 channels_used=30/57 violations=0` |
| `lanectx2` | `name=lanectx2 finished=1 cycles=70 from_fetch=39 retired=10 issue_groups=10 order=ok gpr_mismatch=0 pred_mismatch=0 mem_mismatch=0 check_failures=0 class_violations=0 overflows=0 credit_leaks=0 cor_late=0 channels_used=30/57 violations=0` |
| `late` | `name=late finished=1 cycles=169 from_fetch=138 retired=16 issue_groups=16 order=ok gpr_mismatch=0 pred_mismatch=0 mem_mismatch=0 check_failures=0 class_violations=0 overflows=0 credit_leaks=0 cor_late=0 channels_used=32/57 violations=0` |
| `ldpar` | `name=ldpar finished=1 cycles=154 from_fetch=123 retired=17 issue_groups=17 order=ok gpr_mismatch=0 pred_mismatch=0 mem_mismatch=0 check_failures=0 class_violations=0 overflows=0 credit_leaks=0 cor_late=0 channels_used=32/57 violations=0` |
| `lnorm1` | `name=lnorm1 finished=1 cycles=2531 from_fetch=2500 retired=526 issue_groups=526 order=ok gpr_mismatch=0 pred_mismatch=0 mem_mismatch=0 check_failures=0 class_violations=0 overflows=0 credit_leaks=0 cor_late=0 channels_used=38/57 violations=0` |
| `localsp` | `name=localsp finished=1 cycles=2175 from_fetch=2144 retired=40 issue_groups=40 order=ok gpr_mismatch=0 pred_mismatch=0 mem_mismatch=0 check_failures=0 class_violations=0 overflows=0 credit_leaks=0 cor_late=0 channels_used=32/57 violations=0` |
| `loop` | `name=loop finished=1 cycles=2842 from_fetch=2811 retired=407 issue_groups=407 order=ok gpr_mismatch=0 pred_mismatch=0 mem_mismatch=0 check_failures=0 class_violations=0 overflows=0 credit_leaks=0 cor_late=0 channels_used=23/57 violations=0` |
| `merge` | `name=merge finished=1 cycles=71 from_fetch=40 retired=9 issue_groups=9 order=ok gpr_mismatch=0 pred_mismatch=0 mem_mismatch=0 check_failures=0 class_violations=0 overflows=0 credit_leaks=0 cor_late=0 channels_used=21/57 violations=0` |
| `missrun` | `name=missrun finished=1 cycles=121 from_fetch=90 retired=28 issue_groups=28 order=ok gpr_mismatch=0 pred_mismatch=0 mem_mismatch=0 check_failures=0 class_violations=0 overflows=0 credit_leaks=0 cor_late=0 channels_used=32/57 violations=0` |
| `mload` | `name=mload finished=1 cycles=111 from_fetch=80 retired=11 issue_groups=11 order=ok gpr_mismatch=0 pred_mismatch=0 mem_mismatch=0 check_failures=0 class_violations=0 overflows=0 credit_leaks=0 cor_late=0 channels_used=32/57 violations=0` |
| `mlp` | `name=mlp finished=1 cycles=126 from_fetch=95 retired=21 issue_groups=21 order=ok gpr_mismatch=0 pred_mismatch=0 mem_mismatch=0 check_failures=0 class_violations=0 overflows=0 credit_leaks=0 cor_late=0 channels_used=32/57 violations=0` |
| `mwmiss` | `name=mwmiss finished=1 cycles=129 from_fetch=98 retired=88 issue_groups=88 order=ok gpr_mismatch=0 pred_mismatch=0 mem_mismatch=0 check_failures=0 class_violations=0 overflows=0 credit_leaks=0 cor_late=0 channels_used=32/57 violations=0` |
| `narrowadd` | `name=narrowadd finished=1 cycles=227 from_fetch=196 retired=21 issue_groups=21 order=ok gpr_mismatch=0 pred_mismatch=0 mem_mismatch=0 check_failures=0 class_violations=0 overflows=0 credit_leaks=0 cor_late=0 channels_used=33/57 violations=0` |
| `pgcross` | `name=pgcross finished=1 cycles=162 from_fetch=131 retired=8 issue_groups=8 order=ok gpr_mismatch=0 pred_mismatch=0 mem_mismatch=0 check_failures=0 class_violations=0 overflows=0 credit_leaks=0 cor_late=0 channels_used=32/57 violations=0` |
| `pguard` | `name=pguard finished=1 cycles=87 from_fetch=56 retired=12 issue_groups=12 order=ok gpr_mismatch=0 pred_mismatch=0 mem_mismatch=0 check_failures=0 class_violations=0 overflows=0 credit_leaks=0 cor_late=0 channels_used=30/57 violations=0` |
| `plog` | `name=plog finished=1 cycles=71 from_fetch=40 retired=11 issue_groups=11 order=ok gpr_mismatch=0 pred_mismatch=0 mem_mismatch=0 check_failures=0 class_violations=0 overflows=0 credit_leaks=0 cor_late=0 channels_used=21/57 violations=0` |
| `pmovdiv` | `name=pmovdiv finished=1 cycles=104 from_fetch=73 retired=12 issue_groups=12 order=ok gpr_mismatch=0 pred_mismatch=0 mem_mismatch=0 check_failures=0 class_violations=0 overflows=0 credit_leaks=0 cor_late=0 channels_used=22/57 violations=0` |
| `predlane` | `name=predlane finished=1 cycles=928 from_fetch=897 retired=10 issue_groups=10 order=ok gpr_mismatch=0 pred_mismatch=0 mem_mismatch=0 check_failures=0 class_violations=0 overflows=0 credit_leaks=0 cor_late=0 channels_used=32/57 violations=0` |
| `predmerge` | `name=predmerge finished=1 cycles=940 from_fetch=909 retired=9 issue_groups=9 order=ok gpr_mismatch=0 pred_mismatch=0 mem_mismatch=0 check_failures=0 class_violations=0 overflows=0 credit_leaks=0 cor_late=0 channels_used=34/57 violations=0` |
| `predspill` | `name=predspill finished=1 cycles=968 from_fetch=937 retired=12 issue_groups=12 order=ok gpr_mismatch=0 pred_mismatch=0 mem_mismatch=0 check_failures=0 class_violations=0 overflows=0 credit_leaks=0 cor_late=0 channels_used=32/57 violations=0` |
| `predswap` | `name=predswap finished=1 cycles=1186 from_fetch=1155 retired=46 issue_groups=46 order=ok gpr_mismatch=0 pred_mismatch=0 mem_mismatch=0 check_failures=0 class_violations=0 overflows=0 credit_leaks=0 cor_late=0 channels_used=34/57 violations=0` |
| `privwin` | `name=privwin finished=1 cycles=1161 from_fetch=1130 retired=52 issue_groups=52 order=ok gpr_mismatch=0 pred_mismatch=0 mem_mismatch=0 check_failures=0 class_violations=0 overflows=0 credit_leaks=0 cor_late=0 channels_used=35/57 violations=0` |
| `provswap` | `name=provswap finished=1 cycles=2286 from_fetch=2255 retired=978 issue_groups=978 order=ok gpr_mismatch=0 pred_mismatch=0 mem_mismatch=0 check_failures=0 class_violations=0 overflows=0 credit_leaks=0 cor_late=0 channels_used=34/57 violations=0` |
| `retmiss` | `name=retmiss finished=1 cycles=184 from_fetch=153 retired=19 issue_groups=19 order=ok gpr_mismatch=0 pred_mismatch=0 mem_mismatch=0 check_failures=0 class_violations=0 overflows=0 credit_leaks=0 cor_late=0 channels_used=34/57 violations=0` |
| `roconst` | `name=roconst finished=1 cycles=76 from_fetch=45 retired=4 issue_groups=5 order=ok gpr_mismatch=0 pred_mismatch=0 mem_mismatch=0 check_failures=0 class_violations=0 overflows=0 credit_leaks=0 cor_late=0 channels_used=26/57 violations=0` |
| `rogated` | `name=rogated finished=1 cycles=96 from_fetch=65 retired=7 issue_groups=8 order=ok gpr_mismatch=0 pred_mismatch=0 mem_mismatch=0 check_failures=0 class_violations=0 overflows=0 credit_leaks=0 cor_late=0 channels_used=26/57 violations=0` |
| `rokill` | `name=rokill finished=1 cycles=104 from_fetch=73 retired=41 issue_groups=4536 order=ok gpr_mismatch=0 pred_mismatch=0 mem_mismatch=0 check_failures=0 class_violations=0 overflows=0 credit_leaks=0 cor_late=0 channels_used=27/57 violations=0` |
| `rokilllane` | `name=rokilllane finished=1 cycles=1214 from_fetch=1183 retired=924 issue_groups=10674 order=ok gpr_mismatch=0 pred_mismatch=0 mem_mismatch=0 check_failures=0 class_violations=0 overflows=0 credit_leaks=0 cor_late=0 channels_used=27/57 violations=0` |
| `rolaunch` | `name=rolaunch finished=1 cycles=74 from_fetch=43 retired=4 issue_groups=5 order=ok gpr_mismatch=0 pred_mismatch=0 mem_mismatch=0 check_failures=0 class_violations=0 overflows=0 credit_leaks=0 cor_late=0 channels_used=24/57 violations=0` |
| `rolimit` | `name=rolimit finished=1 cycles=76 from_fetch=45 retired=4 issue_groups=5 order=ok gpr_mismatch=0 pred_mismatch=0 mem_mismatch=0 check_failures=0 class_violations=0 overflows=0 credit_leaks=0 cor_late=0 channels_used=26/57 violations=0` |
| `roload` | `name=roload finished=1 cycles=105 from_fetch=74 retired=8 issue_groups=8 order=ok gpr_mismatch=0 pred_mismatch=0 mem_mismatch=0 check_failures=0 class_violations=0 overflows=0 credit_leaks=0 cor_late=0 channels_used=32/57 violations=0` |
| `rope` | `name=rope finished=1 cycles=677 from_fetch=646 retired=354 issue_groups=354 order=ok gpr_mismatch=0 pred_mismatch=0 mem_mismatch=0 check_failures=0 class_violations=0 overflows=0 credit_leaks=0 cor_late=0 channels_used=35/57 violations=0` |
| `ropediv` | `name=ropediv finished=1 cycles=982 from_fetch=951 retired=203 issue_groups=203 order=ok gpr_mismatch=0 pred_mismatch=0 mem_mismatch=0 check_failures=0 class_violations=0 overflows=0 credit_leaks=0 cor_late=0 channels_used=35/57 violations=0` |
| `sel` | `name=sel finished=1 cycles=77 from_fetch=46 retired=8 issue_groups=8 order=ok gpr_mismatch=0 pred_mismatch=0 mem_mismatch=0 check_failures=0 class_violations=0 overflows=0 credit_leaks=0 cor_late=0 channels_used=30/57 violations=0` |
| `sized` | `name=sized finished=1 cycles=987 from_fetch=956 retired=25 issue_groups=25 order=ok gpr_mismatch=0 pred_mismatch=0 mem_mismatch=0 check_failures=0 class_violations=0 overflows=0 credit_leaks=0 cor_late=0 channels_used=33/57 violations=0` |
| `slotform` | `name=slotform finished=1 cycles=4348 from_fetch=4317 retired=12 issue_groups=12 order=ok gpr_mismatch=0 pred_mismatch=0 mem_mismatch=0 check_failures=0 class_violations=0 overflows=0 credit_leaks=0 cor_late=0 channels_used=33/57 violations=0` |
| `spinwait` | `name=spinwait finished=1 cycles=2022 from_fetch=1991 retired=211 issue_groups=211 order=ok gpr_mismatch=0 pred_mismatch=0 mem_mismatch=0 check_failures=0 class_violations=0 overflows=0 credit_leaks=0 cor_late=0 channels_used=35/57 violations=0` |
| `spmbank` | `name=spmbank finished=1 cycles=186 from_fetch=155 retired=13 issue_groups=13 order=ok gpr_mismatch=0 pred_mismatch=0 mem_mismatch=0 check_failures=0 class_violations=0 overflows=0 credit_leaks=0 cor_late=0 channels_used=28/57 violations=0` |
| `srd` | `name=srd finished=1 cycles=70 from_fetch=39 retired=6 issue_groups=6 order=ok gpr_mismatch=0 pred_mismatch=0 mem_mismatch=0 check_failures=0 class_violations=0 overflows=0 credit_leaks=0 cor_late=0 channels_used=30/57 violations=0` |
| `stall` | `name=stall finished=1 cycles=556 from_fetch=525 retired=116 issue_groups=116 order=ok gpr_mismatch=0 pred_mismatch=0 mem_mismatch=0 check_failures=0 class_violations=0 overflows=0 credit_leaks=0 cor_late=0 channels_used=32/57 violations=0` |
| `swap` | `name=swap finished=1 cycles=556 from_fetch=525 retired=174 issue_groups=174 order=ok gpr_mismatch=0 pred_mismatch=0 mem_mismatch=0 check_failures=0 class_violations=0 overflows=0 credit_leaks=0 cor_late=0 channels_used=32/57 violations=0` |
| `transp4` | `name=transp4 finished=1 cycles=1133 from_fetch=1102 retired=976 issue_groups=976 order=ok gpr_mismatch=0 pred_mismatch=0 mem_mismatch=0 check_failures=0 class_violations=0 overflows=0 credit_leaks=0 cor_late=0 channels_used=38/57 violations=0` |
| `unal` | `name=unal finished=1 cycles=137 from_fetch=106 retired=9 issue_groups=9 order=ok gpr_mismatch=0 pred_mismatch=0 mem_mismatch=0 check_failures=0 class_violations=0 overflows=0 credit_leaks=0 cor_late=0 channels_used=33/57 violations=0` |
| `vadd` | `name=vadd finished=1 cycles=158 from_fetch=127 retired=17 issue_groups=17 order=ok gpr_mismatch=0 pred_mismatch=0 mem_mismatch=0 check_failures=0 class_violations=0 overflows=0 credit_leaks=0 cor_late=0 channels_used=34/57 violations=0` |
| `vadd4` | `name=vadd4 finished=1 cycles=204 from_fetch=173 retired=68 issue_groups=68 order=ok gpr_mismatch=0 pred_mismatch=0 mem_mismatch=0 check_failures=0 class_violations=0 overflows=0 credit_leaks=0 cor_late=0 channels_used=34/57 violations=0` |
| `vaddslow` | `name=vaddslow finished=1 cycles=547 from_fetch=516 retired=17 issue_groups=17 order=ok gpr_mismatch=0 pred_mismatch=0 mem_mismatch=0 check_failures=0 class_violations=0 overflows=0 credit_leaks=0 cor_late=0 channels_used=34/57 violations=0` |
| `waypred` | `name=waypred finished=1 cycles=1211 from_fetch=1180 retired=18 issue_groups=18 order=ok gpr_mismatch=0 pred_mismatch=0 mem_mismatch=0 check_failures=0 class_violations=0 overflows=0 credit_leaks=0 cor_late=0 channels_used=32/57 violations=0` |

## Manifest of release/

```
63b61992ac8bacb24b983760d4e72406f9ce3cd0116f49ef96f337d898e53d05  release/kernels/addrhigh.by_instr.json.gz
0bd6f89ddac8539c75e48c198f7aa7b5bf5863808da2e97531857399b6d58f80  release/kernels/addrhigh.by_unit.json.gz
77bc0c3be8e830d8723acdd7c4f9eb29f4078b3115874372bc60e68aa53b7183  release/kernels/addrhigh.ccvtrace
c6dbe78deb91642a6a5394b06355d031c4a4cdc51e31175c102e17281b6e3b20  release/kernels/addrhigh.log
569f2e22883fad5f0956c57ec734e6afbdd4b8a854e50277425172d6c0cbd766  release/kernels/addrhigh.oracle.jsonl
d992eae06cd3e8f4c834ee89aad6f99329b6c068407892847a8e3b802a8a941e  release/kernels/addrhigh.sv-hosted.log
c77a417cfff50757657a436f72648fbb822c63fa1360532538be0ee2de18f0f1  release/kernels/addrlimit.by_instr.json
50c2386f5ff9b96e43d87f29edf1ade4f514f960194199a4243695a1f4e293c2  release/kernels/addrlimit.by_unit.json
1dddee6415b00a3121e2130c716148c0f04acf2548e26acaefc91e2e20a1d6a1  release/kernels/addrlimit.ccvtrace
fae7b9c03273137ede808bafd29730603507659267ed4c3d540a5b15f206fc93  release/kernels/addrlimit.log
bc660b0b40359a2c5a2478cb0eb4950b73fd22db50ea76b80052bc195a1920f4  release/kernels/addrlimit.oracle.jsonl
222b1e8c35fdd3794578a2d56aef5730d7e2adbbbb8851489cebede3b301dbe5  release/kernels/addrlimit.sv-hosted.log
d5ee993d0a633a3a0837df8a1267138a4a90d71b0f13f2964db1fac129be4751  release/kernels/addrneg.by_instr.json
d4575a0211ba3cad70a041dab45c9876f749ac9173cd91604056151f0cb47c9b  release/kernels/addrneg.by_unit.json
b64cab0cffa732e5e0822d4d5e4704e4625cec46309de4e9af4fa929274a37fb  release/kernels/addrneg.ccvtrace
33add1a2e6e5de440e9171d986a7b5a151c47a5e56bde557d796b862a2e10ffb  release/kernels/addrneg.log
16f5b0707ae44492a1efd67bb9dd38a7e79a7bbd354fa9207b9e7d150ff2f107  release/kernels/addrneg.oracle.jsonl
6e8002e2d40b20f2072910dbaa510bb5db0b02b9259ecf0794c912fd620a5045  release/kernels/addrneg.sv-hosted.log
e1e0249ca76c034a36a8a19fb0e8eebdc62fbe864655bb167c856d150816a0df  release/kernels/atom.by_instr.json.gz
1c769fe521d8d8875c74fb11d2fff39d9ad11cbd7088dfeb550b948c126468c2  release/kernels/atom.by_unit.json.gz
f3faa8d17b0b5cc7ecad6f737a578b40f7056716a01179c38ee3599c0aee29f7  release/kernels/atom.ccvtrace
1e086b2be6867c13c855a9b35e85fb70b236bcd6102f33eacac4d708ecaef398  release/kernels/atom.log
504f5b6e9d25114dc35f2c70b21bb7b3f3c508c691de12dc0e87d12a74285361  release/kernels/atom.oracle.jsonl
21cc943fbbca739cfcba7e328efeadfc8de84faa4a6de00d8da1bf9c78dcf7e7  release/kernels/atom.sv-hosted.log
c9dbe0d415238d4297d25f557f2000152c566244c918ef26d402d1105341dbab  release/kernels/atomf.by_instr.json.gz
51b7c99ca712f39bf7c79fbe16179e63b53a9c76bb45f4d00d02f562b0b233f0  release/kernels/atomf.by_unit.json.gz
048f9ba757ddd409210225d9747aa108f3af25c16a46bcfb42df9391c8b4171a  release/kernels/atomf.ccvtrace
d62e3965eecc6b6265493eb3a9f76515c8f77f8f1f73b3806ac9619ce34bacd4  release/kernels/atomf.log
cfd1179edf4061a33ab2f75d7a6dec61decfe629000198189a7bfc2647b34238  release/kernels/atomf.oracle.jsonl
9488d6bdbd0aba3796eef407a0505acd435c046234cd158bcbd8ebb51472a1a2  release/kernels/atomf.sv-hosted.log
4f1c9ede9ec43d446bc1d5ef8d80a0980a5118c471f3ccc7988bb39742f715e6  release/kernels/borrow.by_instr.json.gz
974d07e1c9c5d5124ee353d88ac1ddf5bb0a7e7a59ec511529e285dcbba5e61a  release/kernels/borrow.by_unit.json.gz
675e87f1c0e15b984bee253fff4849e79de6b07f83e6e28edfa102cf07f93b18  release/kernels/borrow.ccvtrace
dc7007d90b7c00060255ba8bea0f164be426d4b60d257494a2802428d67fbe0a  release/kernels/borrow.log
4c565e1ce0b3baee36e158694b32c8defb5cd662b2f9af75cb5d8c26cb1168ed  release/kernels/borrow.oracle.jsonl
b76616e35a522c18eafd3faeb652b59d5609d0422d55bbf83d391b8e14025aa5  release/kernels/borrow.sv-hosted.log
611da7f27c113de5503501e26190c6f3e8506cfd04c4a00c3caca8e2110b29cb  release/kernels/brs.by_instr.json.gz
34138c6821ac0fee7884acd47562741dadb6576863c456ad71ba78b17095a853  release/kernels/brs.by_unit.json.gz
dfdc00e3f7e638e036c8544c04704d8c1d4cca764d189ea7aa1e0739036dbfac  release/kernels/brs.ccvtrace
b90cec0390717303a67c150808a86b7e2bc1df2e4737644c03118f0412de205a  release/kernels/brs.log
e3c1cb3379580cf1aae44e8ddc8e846ef6fd661a573cfe0a8d4444b18a14dc56  release/kernels/brs.oracle.jsonl
2f20a28a784ab03efd20aa9500c28eeca9dea9199b937964d7f144affd05657d  release/kernels/brs.sv-hosted.log
4f0cc91b7866ccf0472e273053795f5ddd1442caa163fc38dc477399969f5a1b  release/kernels/byp.by_instr.json.gz
65542b4a8a0f1730ebc5a5f42d51f9747022a012c4cc4d235ce889a79739b049  release/kernels/byp.by_unit.json.gz
aadf9e29a7b7fe1b25c1686964ff9e0ec384d6bc7ef3b1c3034e562b0c38a02c  release/kernels/byp.ccvtrace
3a8b62415078124554326baa91c405bdeeabf27c7f1717f6d128ff0084ae7e87  release/kernels/byp.log
5a03dfa4f3603fef49f1e3639e74e34152ca3ca5ef8e41eb959f8323040fa2d5  release/kernels/byp.oracle.jsonl
36da7ddf2a78940f0028bbde36d1cc020fb4e1ad00e1e526410a37415ba7a78b  release/kernels/byp.sv-hosted.log
0d541ad775b8538be18c29a0d31ccb8257fc6d0943d032fea23a15ed012d6f77  release/kernels/callret.by_instr.json.gz
8d09140deaaadfb28bf158e5d4a142d5d29a4a4db7a1bc1adc54d46a9d765ab5  release/kernels/callret.by_unit.json.gz
3f3e7a42049e727325a41d10189b7159f8e9ffe352c9ef3db89bab2bd3f72c3d  release/kernels/callret.ccvtrace
5957e257c7e10146dfb26f43cef93d15cf4889e0e6a1146a1903b56e3661e147  release/kernels/callret.log
9b1d1b50b527f732362f837250aa2f26dabf3e76e16a4794856ebd8f105635b8  release/kernels/callret.oracle.jsonl
7c3b7ca1d50737842a0205191dd3872f0db47babd90e134df98ed7c3ea3359ca  release/kernels/callret.sv-hosted.log
4515439c1cda23338030d38eca335652c60d20c4d887c91744597a401f9dc47f  release/kernels/cas.by_instr.json.gz
b1235cc1d45c252472ed25757ccdfc844e1ae7ce791c27ddbfce450d128791eb  release/kernels/cas.by_unit.json.gz
36f0188d6d35bee745fc6f5a09b97decff65c53e77ccaddaeeeaba194345744f  release/kernels/cas.ccvtrace
5bec5164a06affae9ef6fd3f508c2815874a3bc7c9bc55a4fd80799b6096e9a2  release/kernels/cas.log
0ab31a9443336fe5d08e1a5fa5fcba3bc279b19022f7c5007908d39d8ef39536  release/kernels/cas.oracle.jsonl
f0379a540abb3da031f226fc48da3f8fdae47c957004afc3406d5b29d7b18048  release/kernels/cas.sv-hosted.log
40bcb335f85b31c4124318ba4bf07a9338e4e901d95958d3b9804af599e967e7  release/kernels/chains.by_instr.json.gz
10cb644069d57e6829adcf91dd3ce708614082f1c4071fc963571b08cdb9927d  release/kernels/chains.by_unit.json.gz
f3c7f719a83f93768af61373514062f1b4654c87caae7a6fd23d0307b7b7ca0d  release/kernels/chains.ccvtrace
799c0f206d3826745826fe0a18a48edbdd920de161aef4bc49f462ba19d91ae5  release/kernels/chains.log
26a4cc5c5524c7219d8706c2582c80357dea60be9d6ffdec99dac7d0365e2264  release/kernels/chains.oracle.jsonl
94d8df25cfef11992cde4a2f19b2857e4042578ee3f8d28109b870e8b7ff3e4e  release/kernels/chains.sv-hosted.log
4a3bf655535bebf52eb77742d6b365933e4c300ad7c1f0290c6a8f9324127efa  release/kernels/coll.by_instr.json.gz
9e1d0fe93996e1db71b0f7c0bdf5e6bfad6f482244639dd6a674af4424039da9  release/kernels/coll.by_unit.json.gz
b9d0aa1fba37d6865c6e65310ddfdec12b1a406436489ff0c4ce6a811c10cdbf  release/kernels/coll.ccvtrace
9c73e00fdda9711ab7b98c2938c9c150b1fa3a6dace4dacedf7152515a86a34e  release/kernels/coll.log
dd718d23c88df5dc7d92b055d8542865aa0e029118486af127312a8a578cfcbc  release/kernels/coll.oracle.jsonl
2d40fa64923d966253cd7d52f243b061c995e20b8c2053023866eba47bddae7f  release/kernels/coll.sv-hosted.log
06e30f49557c3db060c6476cfedd414f610add17dcb4ebeadd0e91c0ff05eb13  release/kernels/div.by_instr.json.gz
029da443065620544844a256af5d9f2f49e9dac97dddbc67e0dd5ec2b7131742  release/kernels/div.by_unit.json.gz
0fa59319a49569c81f33bc11b669b5cff44d54af88e0e1a0318682d79a62911e  release/kernels/div.ccvtrace
3de4700f0e3f65684a1871a20a808b5c7c25a5a528949e4f4423bd1b8e2beaae  release/kernels/div.log
71a567b85cf85622631490187563de9a5661099c78a590adff4ed0a0c3d24c16  release/kernels/div.oracle.jsonl
78622c9f91d37773854e03a7f1438e3318a5fb48909bcdfecda53a25fbd72b39  release/kernels/div.sv-hosted.log
7f9cf096d842d57ac2b2f2f03cfda4cff8cc70b218732f399cca218a8cf62369  release/kernels/divchw.by_instr.json.gz
59fec34909d07754ab4ecb62acfd44570e2ae210f43bd9ac039537d63a1c1703  release/kernels/divchw.by_unit.json.gz
7171a5600e2647cfdb103881ce1d051b67e5c0f4b5522ff75b05208ed6ee3d4c  release/kernels/divchw.ccvtrace
5e7b5d7c799fa6a57209e35a5493c497e20d3adba268e53cc431f775c5efbb79  release/kernels/divchw.log
58a541797f7a2df0a1c7528ae6a3edec212db90c7d3eb20656806f38b5c10b3d  release/kernels/divchw.oracle.jsonl
a7c46a2d74b473f72add59338097d7dbc9999f17ab9a92c6d8e1bfd378b4c102  release/kernels/divchw.sv-hosted.log
f24d74ce3c68c14d2d1a43202fcb8120ed51b74475c45e51f24d3251b50c5714  release/kernels/divtail.by_instr.json.gz
2cd7cfba658ff75df0ddc9d328b607386fb5c95325211a9ea4a55683561cbafe  release/kernels/divtail.by_unit.json.gz
db804fbb5ad528ab14845763f37b3761a0b667c3bab40606320e4d62853ca751  release/kernels/divtail.ccvtrace
3c06926619f032712a88a3b46527e1d5f3b745713c545144c7df62a1615d7c98  release/kernels/divtail.log
75f11a75c9b3b336e446140af4579f05b46c363a76b7aab3ec88154a07ba097d  release/kernels/divtail.oracle.jsonl
6240c0abd2ceda3ac7ff5e0e08fc5d91556d3e83242355a2c5a7a19dc742b2e0  release/kernels/divtail.sv-hosted.log
f20c00349a1ea62101cdaa69751487330fa66144baeef50b7bc6ecd6f70090b6  release/kernels/divtail2.by_instr.json.gz
59b2c3c3bb7b7d9767d2af01e18ce565614e0191c44fc881308507ccb65294c1  release/kernels/divtail2.by_unit.json.gz
a75fe12547373cd47764249a890c8e2cff1203790b37cff1678beeeb1c5b2c44  release/kernels/divtail2.ccvtrace
cada39b6170a66823f281d8a43b7fb1453066a22e6c2071bfde2df54e8a47c8b  release/kernels/divtail2.log
b2db6b05eb6cf4a0a7677e31d0c6c2952d5cab49d353f0bb1883fe0b2a20ed14  release/kernels/divtail2.oracle.jsonl
42463cc1c9d473fe50ecac2da496f96741486ae9a545f2874ee35f60bb06622f  release/kernels/divtail2.sv-hosted.log
ae6791d2fef96f19e6832c0e468074532ce7d68f495edb3e5da0235c8657f445  release/kernels/fence.by_instr.json
4897c7b96ad421d86d1ab8a237130890fd77f0c1086592a03f40a0361f897108  release/kernels/fence.by_unit.json.gz
b7cc07b474bd238dfce516ea8f256fd781a6bae64bfc9cb94b03b06526ab6739  release/kernels/fence.ccvtrace
4ab14852c6a31dee07c436929ca12274efa92f85eb4ff986c74364a37109a1f5  release/kernels/fence.log
d1d40317f6cf5bfb430cda1f9c0ef676609e59cabe2a11623c42ffbeca93142b  release/kernels/fence.oracle.jsonl
89d1638199d8acb9eec51a3ab04660e8b84732300ecf82d99f27450ed005b15c  release/kernels/fence.sv-hosted.log
936d55d4994e6dc079aa747da393d3d45e82d4b1e4e7f6c33bc7b6d942404f70  release/kernels/gather.by_instr.json.gz
d2553ef059d08934158c09b9835202446873864118c7ecc658ea9ad8abd0b24e  release/kernels/gather.by_unit.json.gz
a5dbac2c7f10140341326a003abaaa880a3382bf82d3e2b2806b2b3a5a32f40a  release/kernels/gather.ccvtrace
09c3c4e9bbcbb3bcee4b3222b9f5266be48ac7cdc8e36583dcdc92a20c7688fc  release/kernels/gather.log
0413e781d8d6ff578c64eb1f800b7931e66f676d5cdabb97b94a4033e6037662  release/kernels/gather.oracle.jsonl
0dc539b1bd0e9cb6b7fd1f47ea0115db9fc4660cf468f241c3aeb435b16379fd  release/kernels/gather.sv-hosted.log
ee66ee08355d634e3a9f7705f32a36bdeb646c7f2c031522454adb8f7a003986  release/kernels/hit.by_instr.json.gz
ccf77c54fee593edf373f1e2e9065de57adfb170c70686d0afa51ff201abdce9  release/kernels/hit.by_unit.json.gz
a73ec08f645c15775b9bb1af778768cc1d6b49713eec8fc970798f987cfa28de  release/kernels/hit.ccvtrace
deed0289db6a6946c06bd09ea1c0946672135b21ce446d1038cc21bdfe07ffdf  release/kernels/hit.log
7ba9603e0088d9164de6528f16ef6a7fa9ce5821c8c12b52cbb3734e39b9fd52  release/kernels/hit.oracle.jsonl
9f7bd42652125e8eff917928a9d0290d91a4e53ccd06875643c0777200d84068  release/kernels/hit.sv-hosted.log
ce66b8e807902d0083c79ae233194e51f830819739745f5686d74cc86a7cf8f3  release/kernels/lanectx.by_instr.json.gz
6febe9827acca9b1851c07c852e73aff526af8c10436ef5562512bd4e7ade2a8  release/kernels/lanectx.by_unit.json.gz
3c88fc126e29350e2deb1bb3a4ffc705972c1380cde4ea3017bc78e132c92bd3  release/kernels/lanectx.ccvtrace
bbeae14c4f0f2818f4e262cfb8d59cd3422227132622a85ec6753e26b321973a  release/kernels/lanectx.log
888551babf540db8e3025b82e65ca655013f93eba3c8a65689d069d52a7e6039  release/kernels/lanectx.oracle.jsonl
6d2be270a4411727e75123122ca645a33273b2ce775a0f0ddfe4a3666c79ba59  release/kernels/lanectx.sv-hosted.log
4e200103fe2dc87ab19ecb68df8ccd5618bd5b3255dc71b77f22cff519adb6d6  release/kernels/lanectx2.by_instr.json.gz
788d4c26625ec93b343ec3b2ba5200126d7dc0822e0d3a37914dc9094efd3078  release/kernels/lanectx2.by_unit.json.gz
aea2ee33659075f157b9ded4e3ef7e7532409ec4167b5ef5982441ea924c7d58  release/kernels/lanectx2.ccvtrace
88c66076584a680071cad089796c300f872d682d3984e075e15d6eb34d25ea7e  release/kernels/lanectx2.log
45c13056dff5c73ed0c9ece56cc36f929bf335322193c7d5eb38710b1d1dfb02  release/kernels/lanectx2.oracle.jsonl
46bb413c557d90209036b392b9c9584382f0e2b14934b07a6fc47ba19c416a1d  release/kernels/lanectx2.sv-hosted.log
b19b3174c390fe45de0a9ed577762618389dbb4cb0171abf0cec486880444a67  release/kernels/late.by_instr.json.gz
98a118891b9652b7f5c4988ac8d62be02da4f5d969d41c5056e9dfdc4010a2ef  release/kernels/late.by_unit.json.gz
de00224046c89ab52fa8795e9df07bc70e386e38435e10f40400be2630580d35  release/kernels/late.ccvtrace
50a59e7e14959ea97583830918494dc82e60acbd93c3041a909b000cf2f15078  release/kernels/late.log
86084f6bd747a2cf32acbc0ebd96ebd3e4ef2d8d9e21be49e3ae49290d7927f3  release/kernels/late.oracle.jsonl
73c2934db6176c714ec259e2816373d4dd4477d6c57d934a77b4a273419f2aed  release/kernels/late.sv-hosted.log
66df834ededf09348cd931f59b8e0a4cb344b5e649eb8f929ef6e451ee6edce0  release/kernels/ldpar.by_instr.json.gz
262ff0cdf26410fd87bdd5c67588232e0f0ff1a6654a7af9810de79ac89de31a  release/kernels/ldpar.by_unit.json.gz
baf227cfa5025fb6fb1f9331d9af6fa160f1c2d0ed0a3e985d98c1e49e670c7b  release/kernels/ldpar.ccvtrace
7a76b463c5800e0bd3b5ced4c63c58a771674551d3b5beb46724d8eba9da8b27  release/kernels/ldpar.log
8ac08538e9c807637babd61b31e340f7461878ada31f0c0b83cd66331cfaf486  release/kernels/ldpar.oracle.jsonl
937661952f8bf588991b2a7b6e52d92547cc13e6cf061fba87b1983e3a122c39  release/kernels/ldpar.sv-hosted.log
dcc3b5fc2be3334dd9d443a872c482ed80877b2dbd220c61e05a48f0613dc8e9  release/kernels/lnorm1.by_instr.json.gz
99385c521a4dbeff3706d9ecaed5270e738af00258d4a17fa94fc4f04f07fa65  release/kernels/lnorm1.by_unit.json.gz
ab8902ef0408941d90dcfbb3a4f9aa713e82d2ed8fabcc00f7acce96ed0fe008  release/kernels/lnorm1.ccvtrace
48171e2fb257b056063efa86ab519ad88c667a17163fe588692a4ba801f9590f  release/kernels/lnorm1.log
a8d85811af988a1b9fc00db1517300af3d93ec8e589e403d3b9113fa9e0ffc86  release/kernels/lnorm1.oracle.jsonl
54a457b9bfe2af812146412ceaa25a764bf549d9fa2d227b6836c1a878cf71cd  release/kernels/lnorm1.sv-hosted.log
433f5b4a16e35dbd7c1bb8aab40f23605b46503d3acb2ca8fa2f3743452f5bf5  release/kernels/localsp.by_instr.json.gz
778ebc947cbcfe90d404901b00c0a1d02f5575e333e2732a14d9874b094f6b85  release/kernels/localsp.by_unit.json.gz
1345c6f4f4a757c6b7749ef89c1968581491c5a7c3ad4a23b19f6c9796856497  release/kernels/localsp.ccvtrace
bec686e7672a4182de77d1a0153deb9165975afe214518ab192b282d217886c3  release/kernels/localsp.log
55e3c9f36e7f7d38c0ddd38903aff4bb4509ae862015c592e6b937ea258042ca  release/kernels/localsp.oracle.jsonl
3e88e1b32059f3c8f99b424fd5b502711f41de0625f4c87d9f16dcca4c56e6ba  release/kernels/localsp.sv-hosted.log
b1ef82bb217df3cfa06befb0f69fca80913f85578afd634c0691d7440d341bbd  release/kernels/loop.by_instr.json.gz
5691dd5f75df37649d3ebc13bfbb2d0d93881c949a3363d82286076b6444c8e0  release/kernels/loop.by_unit.json.gz
8e6c9417e35af8bbae117adade5b9d2de71420fc35abe4aae7df581e61dd52a5  release/kernels/loop.ccvtrace
f649feadc1ad70c3a7cf4d3408171cf02cb91af1d92c5034cc0520f1df498835  release/kernels/loop.log
03ce5920c06c93e93516d8e53c3f7169f14e3593de204eacceffc0b8a3e32016  release/kernels/loop.oracle.jsonl
b0ac064a714a819e0136d015a33a3f7eed51f91d95c73215483c3a67c48fc32a  release/kernels/loop.sv-hosted.log
03fa76e1205af59ba1dca9dec78c6fc66dba93f8b5d60aa504525297ec6b824e  release/kernels/merge.by_instr.json.gz
d581c205ac949d02e3b435e5b5e5e58e95b5f5b60f6183285f7a4e35c6472adb  release/kernels/merge.by_unit.json.gz
7c5c27b8590c634e6a6fa0ce6ebc8afed33e3101ca7690ecc2efe7cde41a32b3  release/kernels/merge.ccvtrace
4dfd109864c831875841d3dc5018bcf7b2b5945bd92bd5f790baf48b8b7ae6b9  release/kernels/merge.log
f96d28815f8756b1f5a45ded53e6170883d2dfa10f9eef0d14b8050b1318164a  release/kernels/merge.oracle.jsonl
0f71dafff0e5f13f845c9857284e9db2feaa270e3a24b340690fdcdfad966a90  release/kernels/merge.sv-hosted.log
7641d213151ae058a7328d464c6061d81c82da1a3eb02b2a7be5563b2c76f045  release/kernels/missrun.by_instr.json.gz
b75f597f6796f2cc0d067a4870027b01e4e6e332f135017cd2765fd7c92f012e  release/kernels/missrun.by_unit.json.gz
ea3e9a0e4bd827012aca641a4352ce8288f18430671fa7a70d5f56913ee8da6f  release/kernels/missrun.ccvtrace
44ca8885c9d6f1b68b39bcc9e2aab313200e60b329fb3b5e46a3ec5e78b91cd0  release/kernels/missrun.log
531bdaf281e5590774bd2775427f25e4cc0419cf8e3d5b6999843ffe9ef87258  release/kernels/missrun.oracle.jsonl
114d1f1f42486fe9baece9ff9096175673788339bea787369c834ea463e3ac43  release/kernels/missrun.sv-hosted.log
550ad20b5b8b6f64c5978d2ca53eea60f61f9b9659f58826df44a9d738b2fbdc  release/kernels/mload.by_instr.json.gz
6ba5ccff0077c01af019e8d424dd7bae00a243e6bbd7f6aae1b2b512a24da4a1  release/kernels/mload.by_unit.json.gz
7c8166d7dc67da7012f456cace6da21b357fbbc126af66012532010cdb42f602  release/kernels/mload.ccvtrace
82f23b92f69e872ae055696bfbb06b8bd3d18c58c8a04601e7fbd3988b09eccd  release/kernels/mload.log
8000e477b9a95dfb9f0af964e8346acb9d36f1358fd06ffc4ff7cf599d2b8868  release/kernels/mload.oracle.jsonl
d0653829c834e58f20fe86e1f474c4def8e7fe9a0eead172e2a04f15ba830c24  release/kernels/mload.sv-hosted.log
7e07760b61544755272591c1b21bba5b7f03afd36edfc9312ee5d37ef2ea546b  release/kernels/mlp.by_instr.json.gz
fa1d4522af617f8523bba4bb826fb5617a8f4e7553812df2cf07a38f085ab14b  release/kernels/mlp.by_unit.json.gz
ad1ed0a8e6012bca2493d76a7f04b31e46eb17574aa71829c4db487a03cfc3b6  release/kernels/mlp.ccvtrace
abc5d4582216533eb8fa1506bbd60e46a637394471467c267518c1be14939dea  release/kernels/mlp.log
138d282f88d56c8ad648a91af0a983254b55d9fa22942c00d47b327f516a6e44  release/kernels/mlp.oracle.jsonl
656c8986a8681badcdfe544251a2c76c0794e7147a81d6d00496dce124680faf  release/kernels/mlp.sv-hosted.log
59e956b92d940f2118c72e8f8cbacf7c2b3714abc6076dfad0a7dd0c354e3161  release/kernels/mwmiss.by_instr.json.gz
900e1ade7513d705c2fcbbcddbb59fc2f118ed725d3f4bc5d4c59b762cbe601a  release/kernels/mwmiss.by_unit.json.gz
4bae8c91acb81138ae807b4db0ed0af3f82a21cb43a25d098c7deb2f5f12d8a3  release/kernels/mwmiss.ccvtrace
57f9e738a38eeeff2b5d96e7f27d7f9a5630103da5fb31dbc7022826ee1055c2  release/kernels/mwmiss.log
8abe8e8997456a2a6711ee72da54d854b24e20abbdab28e4b7271c0d28418de8  release/kernels/mwmiss.oracle.jsonl
b6cc3bdcad0302c6c8bcbd46d60933d7a19ff2e325991041aed41d3492489c78  release/kernels/mwmiss.sv-hosted.log
a85af943024124576a9861608a4960922f878a166a80874263c3a2c25f444bcd  release/kernels/narrowadd.by_instr.json.gz
41609dd779f77ed239e0b2457742cb1b39a38b1138f5465dd128a6ab76652c58  release/kernels/narrowadd.by_unit.json.gz
d60069faba03f1c928d8830d0f79b10d493c3ca97e80e772cc462cfa3797d3ee  release/kernels/narrowadd.ccvtrace
f5272b7d63b53cf3c873bae9fb47625989149d6d9ecddcf7921a249ca78a2eac  release/kernels/narrowadd.log
40a2cf629853dd404bb06b4a07e35abde3d12efc13f26ffe28f923daf2994574  release/kernels/narrowadd.oracle.jsonl
3e61d2a2287e3fa4c782f704b626fc52658ff3e64153cecfe211a41c71b0c36e  release/kernels/narrowadd.sv-hosted.log
fa3fca33f767b654197b053e208a78b87ff675edb0780843f88e3d07a47822fa  release/kernels/pgcross.by_instr.json.gz
aed0a3ae8ba3f813020c004f65fd71260497f37b4971830689739634dd4ce930  release/kernels/pgcross.by_unit.json.gz
c0440f25593267e4cbe80ddb88da3c5ead82fc7e1caa7189f6ad76b7a7eb7680  release/kernels/pgcross.ccvtrace
76c46ccadcd28ec88df2e525e3a899795f988dfb876119cd722df4c55c564d69  release/kernels/pgcross.log
58aba9ba5ec6a72271191c0249014802cdc7e4470d27491f499a077f17ecc039  release/kernels/pgcross.oracle.jsonl
223bec408b90a617e16ee5bf1584d74d93342f481b5af4fa164cd109bf75c51f  release/kernels/pgcross.sv-hosted.log
554b2ba13f2dfdfd739a02a3c4016cca7cc2413afa850df5c80176e240eaf614  release/kernels/pguard.by_instr.json.gz
bac1f07d3ce0d72aed4938d3eb5e14bcfd483184cded01bccf804b80f9c90938  release/kernels/pguard.by_unit.json.gz
11e5cc14da585319e412c95d70c0191a03949756af0c4bb961b113072bc29ca7  release/kernels/pguard.ccvtrace
22e1a32acc3779fe190d2586638a80fac08faa3cdb2339c1b8029baaf5b077ab  release/kernels/pguard.log
690e56f1cb8d97cbf67124b7dff3ad0a90cb8981814cd1709cf0cd0e035b3bd9  release/kernels/pguard.oracle.jsonl
3db11e6bd70309b3725765c887423f237b64175d3a9ddfa9079bc98d59176243  release/kernels/pguard.sv-hosted.log
c387ceca8d9c3c60622450731f8d6902eebd63acdba7f9fbdacfdb9bcb96233c  release/kernels/plog.by_instr.json.gz
f4df5dffbef60d356153010b3b9c5fc9a71c0449c70ea38c31ce31ea8d326515  release/kernels/plog.by_unit.json.gz
7823562f75147705b01f772471b6175774023d19935926703e158062b24cf94d  release/kernels/plog.ccvtrace
b40660d1aa5edeb825fbf920947e714d73808351c30c5fdef3b2a0888834d8d6  release/kernels/plog.log
0c99915e2da60f4670da00504a6371d7d17701d4431e733a3ff8fa98a2030d6a  release/kernels/plog.oracle.jsonl
3e43a68daf20c7e7ef2f32f9d45fc7a0a7379e5d2f1eacf3bd3bca42562e7c20  release/kernels/plog.sv-hosted.log
af7406961a90c90121fab03e329c8d338418dec44b33f58bc47764f76a14ab45  release/kernels/pmovdiv.by_instr.json.gz
6b112708131cd1a9676a7c499520d518d2c633ea8ddccc7e373d39ef6d431e94  release/kernels/pmovdiv.by_unit.json.gz
da1865544271c3c70d3eab1061f5060d833a856975f75b28d0921880ec954a97  release/kernels/pmovdiv.ccvtrace
31d270aa7cc8bd753ce0ec9d0f4cf0d4245daa49b295703fd9c892b3f7701c66  release/kernels/pmovdiv.log
7bc646cff6166a51bdce03d7c1b7209e871f0a91d743083a9b910a80bcd0b33f  release/kernels/pmovdiv.oracle.jsonl
a651cc55f7b23394c19f50f95de43fc9788dfea2bae8a3d8d20634137986e346  release/kernels/pmovdiv.sv-hosted.log
a4bcb8fca244e2ab724cc6b9ca85f099af896b33bed95ace1d7b80ce6c4915d6  release/kernels/predlane.by_instr.json.gz
774b16586ae927cbefd4d102fa2c1e5366743fb23d4bf5b0ec2c8251405a9738  release/kernels/predlane.by_unit.json.gz
ce6d6be521cde7d6fdc2e752ad15b9c91afb301384f7f427e872647beb563bff  release/kernels/predlane.ccvtrace
217f8ff683f6dc1dfd5fcbc9d822fbbd8569f08ca1a2f226aa80c507883197c9  release/kernels/predlane.log
c45f4177b9e84fc8a6e36b13534a0c7636eb30a3f8531847100ce5e23bf404b1  release/kernels/predlane.oracle.jsonl
abd59950ace62b13199146319f41b10c5504f7cc2e6f62257e4da06681bc1ec7  release/kernels/predlane.sv-hosted.log
bc775c214b5540d182a83cb5f817d294eafeed078623d8a1a2f534f446cc17ab  release/kernels/predmerge.by_instr.json.gz
e9142e5631889d97aae6801d863ea1cf7c0f0b0bb5104fec6341b5df72579d14  release/kernels/predmerge.by_unit.json.gz
09b63a91ab24fe9942dc486f86a67fbde64dbc3cfe7eb09cb9044b3ccb46e00a  release/kernels/predmerge.ccvtrace
699b4d0acb3eb7919296e06520287dee2cfaba7181bc04ccb67715c0b1d213bd  release/kernels/predmerge.log
6c737c49434bcd08e3e0814c8b1dbf15c586ae74f7929ba3148ddcee2c62c845  release/kernels/predmerge.oracle.jsonl
ea810be6c169644d73c1d094615d8d3de56cd9b31ed801da882aba7d993024b1  release/kernels/predmerge.sv-hosted.log
8c0ffba70a5f9960cd5d0b141d1365cd2775d762d5ca2481bec8ea41b6fb23ea  release/kernels/predspill.by_instr.json.gz
c088f620b47b935b9f33608f0d63300e7a960bbf6c95f742073b260acdec89e2  release/kernels/predspill.by_unit.json.gz
fa836074c4f758f04f36409a642b7dc63ef9bb28ba38b4b2fd7d4347d4597f90  release/kernels/predspill.ccvtrace
2da17552b157d667615994ffaa4291e810036acb49204fcfb2261ae6026ed871  release/kernels/predspill.log
b7c84c6478117ffa0f06da0e6ad1e4628e2683426a7911080810e78e06a5242e  release/kernels/predspill.oracle.jsonl
5bfa3c8038a6fb6363aa7a3791ab3e30dd942b6f2782f1cfe0288f3d97dc6a6c  release/kernels/predspill.sv-hosted.log
88e2074079629b5e9a73b3fe12330f0e9adb0f865d0f62951b1a1b31198c29df  release/kernels/predswap.by_instr.json.gz
87b4966a08f2d02ffc11f85389004f4aa8f0b514076d712b1f7c537b54fdf010  release/kernels/predswap.by_unit.json.gz
21d9e7730904815533759d99e11d872bf0c54d40aa50549c08718f5c10c7020b  release/kernels/predswap.ccvtrace
ea6cd954778edf62df984b20946d7fcda5324cb697a1ac7e76568db7458d8665  release/kernels/predswap.log
a6d4f7ed517553816d889c7c9eeb6bcfd1f6c973fbf682ecb69f3c2de619f7bb  release/kernels/predswap.oracle.jsonl
db3fc58a274d80e1986c339c82fa4c01c0ab2417f58b5cc47733c270cc6456fd  release/kernels/predswap.sv-hosted.log
e801b9c7c57781f8b06d14d83899b559dda5dd7779d081cd0a38bed2add76b95  release/kernels/privwin.by_instr.json.gz
4dceb95edae46d115d017666e2bea45a8d081934874f9d0b004f2b455dd91fb6  release/kernels/privwin.by_unit.json.gz
e09c4954ffe0c34332c7edf7e57333af61e2403088fba4ffbe9d71e6080b0096  release/kernels/privwin.ccvtrace
38b3e7a518795302214777ac75c513e384735423bf3671053ec4e89200a1cb9d  release/kernels/privwin.log
861f686fc4480363472908d679d8815e8c957d768e7ab32c826930527b0fb7a8  release/kernels/privwin.oracle.jsonl
b92bab026316d263b4f4eaffc6774e35e947cab981b8ee5ca9aa19a2903d093c  release/kernels/privwin.sv-hosted.log
c00fe3d0270db26c3241eaaf19453e0f32375564e0067b33ff9058b923d94e23  release/kernels/provswap.by_instr.json.gz
bcc1a7a9dd397c962f17c49ea80ea91ad7b23f709f8b4b16282e4a0e1ea414d0  release/kernels/provswap.by_unit.json.gz
f01c9b533ef81b605e43765615fc31cc3e6ae4900086ba2ba10da55e106f3e71  release/kernels/provswap.ccvtrace
e447530911e7fdb18572e4b72b2cf745833954eeda5f9b1a2643367b30e7212f  release/kernels/provswap.log
c9c32a793d54cc7401477f582487f7e8b345b2669a75337b8d6327120d98e5dc  release/kernels/provswap.oracle.jsonl
73aaf7414ac5b36216c8b278df9398e429b398d7705c4f8bf9424f229dec5d57  release/kernels/provswap.sv-hosted.log
464002e7b5d770fdcc3e329d755740a0c06cda180bd8465e48799f8e8cb56d1e  release/kernels/retmiss.by_instr.json.gz
df39cb34207799f346bf9eabcb97a7c64f93b947d216a3284c11541755feae9a  release/kernels/retmiss.by_unit.json.gz
59d84b5d188f7d8ac49de406a329707ca9452fbd649a4e76dbd53572db986db1  release/kernels/retmiss.ccvtrace
b8003acbab42f05341e96ce81494908c8b178c9d736669f3e906991e25917a34  release/kernels/retmiss.log
e5ef8538e838c6cff7febfc679dd091cf5e002f82d34f1009b1948ce22bc3649  release/kernels/retmiss.oracle.jsonl
dc6fb5808a108814c03b249d0f1901c9bc6616ff62e194d38cce73aa1c81964c  release/kernels/retmiss.sv-hosted.log
b8af37455b33a1b36ab55a477d4761f76bdf9dd3edd8eab5fb7f2c3731ac8ec5  release/kernels/roconst.by_instr.json
1bd6e3d57918f6dc12f88a90fbad3431d9d6ab8123f8959ed02ca7c9430da7dc  release/kernels/roconst.by_unit.json
55981e07a1a8d3ed8b7a9f6797e5f718e3161cc5f6e1218171db77f9b6115f18  release/kernels/roconst.ccvtrace
d586efd2c510b86b53222666ebaf25962b20b13684ff5aabca313dab7dcd59e9  release/kernels/roconst.log
8087c0671de620162881aecd38cd6114b78e7be6bd71201e3ec02c9a2e2e750e  release/kernels/roconst.oracle.jsonl
42c320666aa4fa3083c9fcb06cec2aefe21449050ebc2739919abb5a5fb077ee  release/kernels/roconst.sv-hosted.log
10c797fb8d044649f6d3dee9c07281c225794258b33e21124d781108ba92c747  release/kernels/rogated.by_instr.json
ebb5c74ba456eea7a96c451675a0f4bc48b1fdf90f14eda6b45e969abaf581c9  release/kernels/rogated.by_unit.json.gz
efce29ea7c5e82d9ca9f5522549f4958218e9ae67a9114f6c26c60f34501ba52  release/kernels/rogated.ccvtrace
cd3930003b60ebf05e766d913bc6d87c8d043ec478ac7ea8b734528dc15d734a  release/kernels/rogated.log
7cd02bd4cceec5a044d6b4d6a80df1e68ed0ae71b0b2a953143636d5b809ea6c  release/kernels/rogated.oracle.jsonl
99e98fe1721c0bf94d1b39067794a2f256b2e401adfd418c3e1a3c0e861c69ca  release/kernels/rogated.sv-hosted.log
8ec3f1982ae8060de81fd72da21e6ff579ea72160fec760a1b72d5d656b44b83  release/kernels/rokill.by_instr.json.gz
fdfe7efb5aac2a2a6566ae3321cddb2f70475ee7e8de087e001180fa9e389402  release/kernels/rokill.by_unit.json.gz
8a540e1a67dce0d3845964ab547fce4b1c674a042f6be8c8d8c8b7dd46f4663e  release/kernels/rokill.ccvtrace
f67fb71ac885f1e10c2fcf56ae3e8be59253922ab2222c7a56c2b42b31a65f31  release/kernels/rokill.log
94efcef96af469a512d346ce61623980fe86383188eaebd55120f716db596f14  release/kernels/rokill.oracle.jsonl
d1185c22ba3dfb7ac08efb4a2bc79bf24a52bfb39b7128af356538f16aa216f9  release/kernels/rokill.sv-hosted.log
999a87d40d804aa3f914fdc12786617abbd0a64b81734f91c641dbf786fc4860  release/kernels/rokilllane.by_instr.json.gz
c54596aa1be6f0824a1a5c178aec8b2326d323407bafaadbb00abceb9895b014  release/kernels/rokilllane.by_unit.json.gz
c54a973f624a7ad5b95499138a725ad2287a564534121f4f568394896b3522b8  release/kernels/rokilllane.ccvtrace
63f976e21a2c5b6719018d6bf1a40a8a757093789efe56355010a0fff8a9c5bf  release/kernels/rokilllane.log
f5ca6e666eff2f44894df74a291b43b3c0e7be0a63a47d795fdefd7b22016f45  release/kernels/rokilllane.oracle.jsonl
8c85a33bfb6629ec0468b36d4e05e484f2d4b261f213bfa1c9cbe424f00bc4c4  release/kernels/rokilllane.sv-hosted.log
6018676757a05a45231fba12ff6df60d07f415338c1d836cc09d99465b73577e  release/kernels/rolaunch.by_instr.json
8512780fe1bbc0571a43ff91654c0ffdb7545b9c1ac040c907e50a29bfbd10d3  release/kernels/rolaunch.by_unit.json
289a78e36e414127402cf1c2f9514ddf7965e2988e5c5c2c172bf77c872262d4  release/kernels/rolaunch.ccvtrace
43ba1887d7ec873e70b639f7c77a6ae618d533d9aea3cb8a3321164340889d36  release/kernels/rolaunch.log
e7dad585c3e70615de04330fd03f4f282c29a005dc1732a35655fb261d51139e  release/kernels/rolaunch.oracle.jsonl
238f414ce725c4425d807752e30207d6d3501d1b182dcf594032910d5900f0e3  release/kernels/rolaunch.sv-hosted.log
b8af37455b33a1b36ab55a477d4761f76bdf9dd3edd8eab5fb7f2c3731ac8ec5  release/kernels/rolimit.by_instr.json
0e20aabf7e39b687a2ade0f80fd977c9d7bd313c2cebdac11d43f35296e7d911  release/kernels/rolimit.by_unit.json
6105e32f751a15c0875d0d2a30a1e054656c0475286b5e2739728e13fa4d3e83  release/kernels/rolimit.ccvtrace
1fb198c1e33e4611f571da171edbbfdcb56f29b23878a4d66e02d683050f007d  release/kernels/rolimit.log
1c5bc0cb8e8b2e69505fb5a551a16d5d10c56f232b88da7a27e336ad7d962de2  release/kernels/rolimit.oracle.jsonl
4ad3fc34fbd2a56c808d212df8783e97b0c44cd0f9da7cb21761fbf506f969be  release/kernels/rolimit.sv-hosted.log
1f68b8dbf945bfc7e015aef2fa8fc72de849d064e9920258d4ffd334f1571b7f  release/kernels/roload.by_instr.json.gz
858cacc3b1f487ad1e38006b17977f2cec5136de0b74c02ed7d0b84a51bb6c95  release/kernels/roload.by_unit.json.gz
a3392e515c6b5418bfcb8808bdbe45443d3b9e3ccd8d9db33138983bc13eaa1f  release/kernels/roload.ccvtrace
4b5bde46eebca9369c5a0db84c789473d52882832915b45422eb490f39150e51  release/kernels/roload.log
f7c1309cc9764769fb5803f6fd0f2f5e1eb418f2d23fbe5e17cf5f9106869fdf  release/kernels/roload.oracle.jsonl
00f1f48c1cd03552aa734058c651073df87bf717dc302e75b9db5b7a7cf72c48  release/kernels/roload.sv-hosted.log
abac079738376585547631402bb65fdd8336fa290e2f07c54196f456f79ea126  release/kernels/rope.by_instr.json.gz
3318dbaaf54d52f155e8ae4448b18464a6bf366b83d7321b73328e923d009a32  release/kernels/rope.by_unit.json.gz
e84e07f241bc3e069816935e1c78d3e12b51ed604fcf434f0338b76f3ced70ad  release/kernels/rope.ccvtrace
3387d7ef48d343f57f5ad1b326f00c68ef6ab45ae507301e2ac59afa5c5a4b4c  release/kernels/rope.log
d55f9efae392dc8877c102c01c0810e7654b666b6ede386328108164c6cf88f3  release/kernels/rope.oracle.jsonl
a0fe48bbf4b82041382deab662e397e7c66ddb0d299f09c0e3f7dc6d81106631  release/kernels/rope.sv-hosted.log
fb796b58433c66bbc2d95c58ac171a34cfbb90363075f52b041819cb1d90fe8b  release/kernels/ropediv.by_instr.json.gz
b624ce8156dc26c864c05e159d2dd1277fd21400b67f6dd7a6cb424f7fc0ff58  release/kernels/ropediv.by_unit.json.gz
7f890fd54dac77bf6be5d1b272e7e34cd6a869056ebf6afa17557b43ed932790  release/kernels/ropediv.ccvtrace
0b16d76a706c83dfb10bde6e1902665745fd1e093364e5661a3b3edfd5ca3ed7  release/kernels/ropediv.log
10c0ec6ec18b7b44638c790033109198c079d07c1537bf193353ccedd00a920f  release/kernels/ropediv.oracle.jsonl
c90109cf23d6b53ebfe48539ac8af5e29cbce6c217000f064de82fa656931545  release/kernels/ropediv.sv-hosted.log
1a4339862b3d3d5814a03455365e5227d8e9714cfcbb455d698a9c3fa0ba969d  release/kernels/sel.by_instr.json.gz
e67abe50fac2d585daa05305aaa32ca289223083360b7753ddd55a2e97f81152  release/kernels/sel.by_unit.json.gz
a7f6f6b8207804fa8804df89614ff86c72a8c2776f044e01e8607a64bbd8e8ca  release/kernels/sel.ccvtrace
c598cc5a610dd2cc16ce3994d257378d3bdee5c9bf990e99c1d5c780c3f9b524  release/kernels/sel.log
87f6a81e8afa004c8039bf2f61c90176fcf29ab29bb17ac44aa016a5cc8438fe  release/kernels/sel.oracle.jsonl
379aad8e84749f149f0fbd588b36c3e242378479b0f068537403a20de471d6ca  release/kernels/sel.sv-hosted.log
462c68aeddb0756bc8bcc87d324a627778ca5e0bfdae581feefc0077ed404b86  release/kernels/sized.by_instr.json.gz
67f18baf04ca1f016280a113b255588221121c7d12a3d912cf3fcdf4c470c711  release/kernels/sized.by_unit.json.gz
ee6e7cb01baaff67e302091bb047d152baf37727fda5a66ac8b05b542c206c1f  release/kernels/sized.ccvtrace
421365f43410ba858322dcca940e3c3718e7eb09edf060f7282b98e5a14b6068  release/kernels/sized.log
36d903ba1618bd1faa437c9812a6ee6c0c966a63196c796267d74bf2695ebc3d  release/kernels/sized.oracle.jsonl
365587bf4b53d38dcfec05afd1da50905674892f571b6b39beb5a15ce2d68d48  release/kernels/sized.sv-hosted.log
6fe156a8b2724f9c7094b9dd4045f2d9f32fbb2ad01436ad435db9cad2c7bc09  release/kernels/slotform.by_instr.json.gz
5802b87eb1d754848d20f0b897e223b655f8ac0e7a2195a553248de20834ca71  release/kernels/slotform.by_unit.json.gz
74f4bb29a4830c5f0fdf2d70ae4f5a6687868c77777555cf494219156ebadc31  release/kernels/slotform.ccvtrace
212934f6194bc3592aa40312fc84b4ba6b6548044687d1926da74c677e6770ee  release/kernels/slotform.log
8b61db7419b18cea8a646fb628218447e72e84a18a9891ffb73b441736138ab9  release/kernels/slotform.oracle.jsonl
a82ae73a5673f799f3ebe6305f983315bfb8fd743519754943c36413e6e5e7cf  release/kernels/slotform.sv-hosted.log
66328633b718a17d015e75e93e581b8744d9de57ace1917765ee37a1f76824d1  release/kernels/spinwait.by_instr.json.gz
f810a277feb31708265bae9c5cae3342d9cbaf25721819f7f31403ed5c6fd8d6  release/kernels/spinwait.by_unit.json.gz
fade99beec1d14f854e29146318c839f89bcebbbb4edf3e7f8411a4a7dbde502  release/kernels/spinwait.ccvtrace
dded4bd57ac3173c2aebb9338993370d9b117d922d62ec52aa17d9f67309abbb  release/kernels/spinwait.log
868920637236c878b33779bd450439466fc3626996a3164573dc11d437d5c709  release/kernels/spinwait.oracle.jsonl
e914415bb76a0bb294ac3dce8ec39270af0648e6d099b36cf778725691d33044  release/kernels/spinwait.sv-hosted.log
b1df39eb5ef7e7c8ddcd5ec341248141ffd27a73b05d78293585802e9175da92  release/kernels/spmbank.by_instr.json.gz
01a0aad643d6f3b2760774d8e6566e6be7367878ebde45f5a40ed7a7f88242e2  release/kernels/spmbank.by_unit.json.gz
0b63ddd199108d5d57dacf8da3b47f37f0c4b36c8ae2b2605a61415aba0d0ef1  release/kernels/spmbank.ccvtrace
93bf32d748d3a20a258c6131243b52326b0c3718df69f92d5fff0e94b159f94d  release/kernels/spmbank.log
3af490cc37d7a92dbe719b57de216b648536eb301ff9d13de9a39f50d150d725  release/kernels/spmbank.oracle.jsonl
a023f35166cb048a6c740c7ab24e399f24e8af9087f177187cb47bd8bcdea9d5  release/kernels/spmbank.sv-hosted.log
6cdd3deb923ed6738950c0ffc1e3887e318a95871110da3a7effdb05e3062863  release/kernels/srd.by_instr.json.gz
14e7e907c63c63dfcab7d4d96d468f2af94d8a5af132147084694070becbf1fc  release/kernels/srd.by_unit.json.gz
6010258b0bd7bcce1c422078a1ca908ef32bcf25b7e4f3d37435f73c746bc894  release/kernels/srd.ccvtrace
49cab66348dfd11df1b373626035d39acca4c1a1937b6bcd7bc208ecea42a462  release/kernels/srd.log
b08eb5e3673cac7eebb8b72af5ed3783c8e70a9e96592e76bf3722551bc79473  release/kernels/srd.oracle.jsonl
9e32b683e7738ae2f020e387d4ffe8f9beaa10b9aac986fce20453761115d2ec  release/kernels/srd.sv-hosted.log
100012131504b39f741ad1eee555101fb2af75742ab157dde10984dc3e8eca65  release/kernels/stall.by_instr.json.gz
e4e5ca649a39f4ea72f1294d187f2805922ea8b8bed7e3bbf0ddf37958e16b12  release/kernels/stall.by_unit.json.gz
d64ce409018c3db8624aa7a0fd3b6c328df0e41b6abf21ac8a646676dbf17fb9  release/kernels/stall.ccvtrace
072343418a7a3c952761355ac0cca0081be09b89bdf671c77ebb5ec4fd3c9a99  release/kernels/stall.log
500db2c482b07a0706583422cd68878301d0146c1f872ccc1f11bfdcf5c993ef  release/kernels/stall.oracle.jsonl
aa25fa1a8717c76105cfb7834b8a6b4e94cda5952d344c8537fcd2c20b249162  release/kernels/stall.sv-hosted.log
9c0ef294914e2488abb5b217686d83b81b9e0fc64bd6219068e5cfdc93bdad5c  release/kernels/swap.by_instr.json.gz
abf82fec43abab1bce686978b655b1a38a8d96fd91f8f1f72a4001ffc922190b  release/kernels/swap.by_unit.json.gz
d461473386e8ac5178a5b1eda62ced016fae25baff2ee43ca7a82758e90375b8  release/kernels/swap.ccvtrace
883477a1f8854a2955ebb355f367b1c7baddeeb8be1fa7af369e6150c53402ff  release/kernels/swap.log
3658a26316c1ff7bc1744304a42f736e930fcde2865c8913e6cc67a22ce96667  release/kernels/swap.oracle.jsonl
3a28164086af17659e6626aa297da5284dee8d413ecf87e66a0bee53bef2a046  release/kernels/swap.sv-hosted.log
d29e3230e685bb93d2bfab10e292c1c7a7253228f3783b4f93d29adbff9e5d66  release/kernels/transp4.by_instr.json.gz
fec046b0ee6406f5dee1be5c83e2b85c941f5365cf522323b886c5ae3293e4bc  release/kernels/transp4.by_unit.json.gz
296b3d886498adcf28d5c80c34554b1d9b62f67dc691251453d8c2019fc68fdf  release/kernels/transp4.ccvtrace
d2ce846043d4a1489a3c0c61677cd0f20800231f0648be7c30ae4c71fa22e692  release/kernels/transp4.log
06396ace3ac19677fd39c700e408606e5bdbacb24997d663bbe8872e63dd74fc  release/kernels/transp4.oracle.jsonl
4c13dd12fc0c5d4e59e398009c4b218bf7a40741082345a9507e4a70dd8569f8  release/kernels/transp4.sv-hosted.log
d27b6873c00441d8db67e049fdc4d93f964bddd976775b6981d4f69f057f91a5  release/kernels/unal.by_instr.json.gz
bdb51da60c74c61f844d3ac5566c37eade1ece2a8457cbff02f36a839debde51  release/kernels/unal.by_unit.json.gz
cf933bef63a6604be1519d278a409ae71264c4251ccd812bf526c5daf4c1aaac  release/kernels/unal.ccvtrace
c10cd2bc769bdcb5eaa2c81c7eb540be81f72308d6e3ae323113722569e7a828  release/kernels/unal.log
c3d484bb160657a563df983d9a2532eac27f556636617960aa1e72183ac2b299  release/kernels/unal.oracle.jsonl
9dde9c8667e09dce6bc8ef5cec83b12cae5acf9e14c83cf770ef6cc9175578c6  release/kernels/unal.sv-hosted.log
4aa95d2819116eb14af4d90766b660c0dcf9b5e225d15cb8bc0dfb4fbb7c3ec6  release/kernels/vadd.by_instr.json.gz
c7c023dafb5301a6e0d9ddd3be9a6aeb2d14c54822b8140350273df248c31e2f  release/kernels/vadd.by_unit.json.gz
2dfffb27f976f8340cb3af461b263ba63673f1bd60f64d0019270f74bbec0cf3  release/kernels/vadd.ccvtrace
2572f099bed25a612f61733be2c24708c48a0583a803dc21483d8c2145d3659c  release/kernels/vadd.log
0276b6d0611a4bbcdc004ab3987214aea138245bc7217504147331689a9c0880  release/kernels/vadd.oracle.jsonl
a64f20d57f37fd8c5ebe278a8e387def8dba95292f93e7e080b5789c53fbf560  release/kernels/vadd.sv-hosted.log
0ec4421ba13a4e65c3afb8e6b83380d70d676850f12efe31dc634712b9902075  release/kernels/vadd4.by_instr.json.gz
475e142ff0ff95ef5852cc83f00bdd8f69bb2bfaadfb8277050ade4d54e4ca8e  release/kernels/vadd4.by_unit.json.gz
48e2a6bcde0a29258d7d48ba051572fc3c8be46c036769b8bbbc585171861796  release/kernels/vadd4.ccvtrace
b33a2a6929f7da696dba5d301c1e15fdab467c81221cdda316b6b43915309b47  release/kernels/vadd4.log
225aa18fc9f38aa9ad615aa11de254337d59fa705877553d873062c68366e0db  release/kernels/vadd4.oracle.jsonl
a5470f29cfa67a5f3cb48b92dc8de4dca819e871d4685b212998573d14f0c4b9  release/kernels/vadd4.sv-hosted.log
110369a7e36894e7e644b4ba122112dd21d3f714934e7aa0858f17124e7eb1af  release/kernels/vaddslow.by_instr.json.gz
5a17c75b6a132d0b5115bff48a7d2122cd028799642f579eab4941b7da2e4dca  release/kernels/vaddslow.by_unit.json.gz
3d499e39a169aca65d01504acfb7b82d558419b0081aaede37bbc693dd465f58  release/kernels/vaddslow.ccvtrace
dc7689206d81f1afa43904b4db303cdb73128c1a5c2fca64382e56e8ca92686d  release/kernels/vaddslow.log
e9e6218e8b8450e9f9ff6b39d659c994a1e51c527a0c5bd10d18b5658ae0e344  release/kernels/vaddslow.oracle.jsonl
b191e2fb3dcff7e6b87e73cf5db707835608ca4c24038460bec452817be008c6  release/kernels/vaddslow.sv-hosted.log
f1f95083cdc6047959cd047bed079394c17e2a6a8281ca861480d27a11ee0f60  release/kernels/waypred.by_instr.json.gz
9fbcabac8ae42b45a32aef7e1d8d2c298c585d3f899b4e3beadcf5153f2881c2  release/kernels/waypred.by_unit.json.gz
e499c8c4da4c49f33a7298f2e2f366172128796322cbf4800dbc21cf333ee6f7  release/kernels/waypred.ccvtrace
3af329938e3ab703b10b3cc875bcfaf11b20a3a6970516db61749fac2c4f8291  release/kernels/waypred.log
c8833938fa0199fa850184f9c93413283b4148a4bd7f1763d5597c544f14ad5e  release/kernels/waypred.oracle.jsonl
4d2c25f2947d611e3f69b5e528a42d24e46e0f452aa4b835f4fb665ba77bfcb7  release/kernels/waypred.sv-hosted.log
294667c9138fe8b736cd69f29761db837e1433751a1d9931b74288fd030a8542  release/verify.log
f78197fa73514d4391564b6dbfda61c3c03a38e2134c9ddc2d24180f29c72e6c  release/wiring.txt
```
