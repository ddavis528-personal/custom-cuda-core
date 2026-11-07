# Snapshot snapshot-2026-11-07-24d17a4

**A generated, read-only snapshot. Do not edit or merge it.** The source
is `ti-b2` at `24d17a42e43e498ef9e514339083843f143aa7c6`, and this branch is rebuilt from source by
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
| Source | `ti-b2` @ `24d17a42e43e498ef9e514339083843f143aa7c6` |
| Built | 2026-11-07 (UTC) |
| Gate | `tools/verify.sh`: PASS |
| Compiler snapshot | custom-cuda-complier `release` @ `e533ecdfabd1aa267e4cffd49a4d7e1e8c13b263` (source `45ce995c923e7267feb71d87f8f9c5edfefcf0df`) |
| Verilator | Verilator 5.052 2026-09-05 rev v5.052 |
| Icarus | Icarus Verilog version 12.0 (stable) () |
| Yosys | Yosys 0.33 (git sha1 2584903a060) |

## Kernels

| Kernel | Result |
|---|---|
| `addrhigh` | `name=addrhigh finished=1 cycles=85 from_fetch=54 retired=5 issue_groups=6 order=ok gpr_mismatch=0 pred_mismatch=0 mem_mismatch=0 check_failures=0 class_violations=0 overflows=0 credit_leaks=0 channels_used=26/55 violations=0` |
| `addrlimit` | `name=addrlimit finished=1 cycles=1073 from_fetch=1042 retired=5 issue_groups=5 order=ok gpr_mismatch=0 pred_mismatch=0 mem_mismatch=0 check_failures=0 class_violations=0 overflows=0 credit_leaks=0 channels_used=27/55 violations=0` |
| `addrneg` | `name=addrneg finished=1 cycles=85 from_fetch=54 retired=1 issue_groups=2 order=ok gpr_mismatch=0 pred_mismatch=0 mem_mismatch=0 check_failures=0 class_violations=0 overflows=0 credit_leaks=0 channels_used=23/55 violations=0` |
| `borrow` | `name=borrow finished=1 cycles=102 from_fetch=71 retired=7 issue_groups=7 order=ok gpr_mismatch=0 pred_mismatch=0 mem_mismatch=0 check_failures=0 class_violations=0 overflows=0 credit_leaks=0 channels_used=21/55 violations=0` |
| `brs` | `name=brs finished=1 cycles=102 from_fetch=71 retired=12 issue_groups=12 order=ok gpr_mismatch=0 pred_mismatch=0 mem_mismatch=0 check_failures=0 class_violations=0 overflows=0 credit_leaks=0 channels_used=23/55 violations=0` |
| `byp` | `name=byp finished=1 cycles=120 from_fetch=89 retired=14 issue_groups=14 order=ok gpr_mismatch=0 pred_mismatch=0 mem_mismatch=0 check_failures=0 class_violations=0 overflows=0 credit_leaks=0 channels_used=31/55 violations=0` |
| `callret` | `name=callret finished=1 cycles=292 from_fetch=261 retired=40 issue_groups=40 order=ok gpr_mismatch=0 pred_mismatch=0 mem_mismatch=0 check_failures=0 class_violations=0 overflows=0 credit_leaks=0 channels_used=30/55 violations=0` |
| `chains` | `name=chains finished=1 cycles=97 from_fetch=66 retired=29 issue_groups=29 order=ok gpr_mismatch=0 pred_mismatch=0 mem_mismatch=0 check_failures=0 class_violations=0 overflows=0 credit_leaks=0 channels_used=21/55 violations=0` |
| `div` | `name=div finished=1 cycles=1012 from_fetch=981 retired=144 issue_groups=144 order=ok gpr_mismatch=0 pred_mismatch=0 mem_mismatch=0 check_failures=0 class_violations=0 overflows=0 credit_leaks=0 channels_used=23/55 violations=0` |
| `divchw` | `name=divchw finished=1 cycles=114 from_fetch=83 retired=5 issue_groups=6 order=ok gpr_mismatch=0 pred_mismatch=0 mem_mismatch=0 check_failures=0 class_violations=0 overflows=0 credit_leaks=0 channels_used=22/55 violations=0` |
| `divtail` | `name=divtail finished=1 cycles=664 from_fetch=633 retired=96 issue_groups=96 order=ok gpr_mismatch=0 pred_mismatch=0 mem_mismatch=0 check_failures=0 class_violations=0 overflows=0 credit_leaks=0 channels_used=23/55 violations=0` |
| `divtail2` | `name=divtail2 finished=1 cycles=1570 from_fetch=1539 retired=366 issue_groups=366 order=ok gpr_mismatch=0 pred_mismatch=0 mem_mismatch=0 check_failures=0 class_violations=0 overflows=0 credit_leaks=0 channels_used=23/55 violations=0` |
| `fence` | `name=fence finished=1 cycles=84 from_fetch=53 retired=7 issue_groups=7 order=ok gpr_mismatch=0 pred_mismatch=0 mem_mismatch=0 check_failures=0 class_violations=0 overflows=0 credit_leaks=0 channels_used=30/55 violations=0` |
| `gather` | `name=gather finished=1 cycles=268 from_fetch=237 retired=16 issue_groups=16 order=ok gpr_mismatch=0 pred_mismatch=0 mem_mismatch=0 check_failures=0 class_violations=0 overflows=0 credit_leaks=0 channels_used=31/55 violations=0` |
| `hit` | `name=hit finished=1 cycles=234 from_fetch=203 retired=17 issue_groups=17 order=ok gpr_mismatch=0 pred_mismatch=0 mem_mismatch=0 check_failures=0 class_violations=0 overflows=0 credit_leaks=0 channels_used=31/55 violations=0` |
| `lanectx` | `name=lanectx finished=1 cycles=71 from_fetch=40 retired=10 issue_groups=10 order=ok gpr_mismatch=0 pred_mismatch=0 mem_mismatch=0 check_failures=0 class_violations=0 overflows=0 credit_leaks=0 channels_used=29/55 violations=0` |
| `lanectx2` | `name=lanectx2 finished=1 cycles=71 from_fetch=40 retired=10 issue_groups=10 order=ok gpr_mismatch=0 pred_mismatch=0 mem_mismatch=0 check_failures=0 class_violations=0 overflows=0 credit_leaks=0 channels_used=29/55 violations=0` |
| `late` | `name=late finished=1 cycles=175 from_fetch=144 retired=16 issue_groups=16 order=ok gpr_mismatch=0 pred_mismatch=0 mem_mismatch=0 check_failures=0 class_violations=0 overflows=0 credit_leaks=0 channels_used=31/55 violations=0` |
| `ldpar` | `name=ldpar finished=1 cycles=157 from_fetch=126 retired=17 issue_groups=17 order=ok gpr_mismatch=0 pred_mismatch=0 mem_mismatch=0 check_failures=0 class_violations=0 overflows=0 credit_leaks=0 channels_used=31/55 violations=0` |
| `lnorm1` | `name=lnorm1 finished=1 cycles=2645 from_fetch=2614 retired=526 issue_groups=526 order=ok gpr_mismatch=0 pred_mismatch=0 mem_mismatch=0 check_failures=0 class_violations=0 overflows=0 credit_leaks=0 channels_used=37/55 violations=0` |
| `localsp` | `name=localsp finished=1 cycles=4245 from_fetch=4214 retired=40 issue_groups=40 order=ok gpr_mismatch=0 pred_mismatch=0 mem_mismatch=0 check_failures=0 class_violations=0 overflows=0 credit_leaks=0 channels_used=32/55 violations=0` |
| `loop` | `name=loop finished=1 cycles=2942 from_fetch=2911 retired=407 issue_groups=407 order=ok gpr_mismatch=0 pred_mismatch=0 mem_mismatch=0 check_failures=0 class_violations=0 overflows=0 credit_leaks=0 channels_used=23/55 violations=0` |
| `merge` | `name=merge finished=1 cycles=72 from_fetch=41 retired=9 issue_groups=9 order=ok gpr_mismatch=0 pred_mismatch=0 mem_mismatch=0 check_failures=0 class_violations=0 overflows=0 credit_leaks=0 channels_used=21/55 violations=0` |
| `missrun` | `name=missrun finished=1 cycles=123 from_fetch=92 retired=28 issue_groups=28 order=ok gpr_mismatch=0 pred_mismatch=0 mem_mismatch=0 check_failures=0 class_violations=0 overflows=0 credit_leaks=0 channels_used=31/55 violations=0` |
| `mload` | `name=mload finished=1 cycles=113 from_fetch=82 retired=11 issue_groups=11 order=ok gpr_mismatch=0 pred_mismatch=0 mem_mismatch=0 check_failures=0 class_violations=0 overflows=0 credit_leaks=0 channels_used=31/55 violations=0` |
| `mlp` | `name=mlp finished=1 cycles=128 from_fetch=97 retired=21 issue_groups=21 order=ok gpr_mismatch=0 pred_mismatch=0 mem_mismatch=0 check_failures=0 class_violations=0 overflows=0 credit_leaks=0 channels_used=31/55 violations=0` |
| `mwmiss` | `name=mwmiss finished=1 cycles=131 from_fetch=100 retired=88 issue_groups=88 order=ok gpr_mismatch=0 pred_mismatch=0 mem_mismatch=0 check_failures=0 class_violations=0 overflows=0 credit_leaks=0 channels_used=31/55 violations=0` |
| `narrowadd` | `name=narrowadd finished=1 cycles=237 from_fetch=206 retired=21 issue_groups=21 order=ok gpr_mismatch=0 pred_mismatch=0 mem_mismatch=0 check_failures=0 class_violations=0 overflows=0 credit_leaks=0 channels_used=32/55 violations=0` |
| `pguard` | `name=pguard finished=1 cycles=88 from_fetch=57 retired=12 issue_groups=12 order=ok gpr_mismatch=0 pred_mismatch=0 mem_mismatch=0 check_failures=0 class_violations=0 overflows=0 credit_leaks=0 channels_used=29/55 violations=0` |
| `plog` | `name=plog finished=1 cycles=71 from_fetch=40 retired=10 issue_groups=10 order=ok gpr_mismatch=0 pred_mismatch=0 mem_mismatch=0 check_failures=0 class_violations=0 overflows=0 credit_leaks=0 channels_used=21/55 violations=0` |
| `pmovdiv` | `name=pmovdiv finished=1 cycles=107 from_fetch=76 retired=12 issue_groups=12 order=ok gpr_mismatch=0 pred_mismatch=0 mem_mismatch=0 check_failures=0 class_violations=0 overflows=0 credit_leaks=0 channels_used=22/55 violations=0` |
| `predlane` | `name=predlane finished=1 cycles=930 from_fetch=899 retired=10 issue_groups=10 order=ok gpr_mismatch=0 pred_mismatch=0 mem_mismatch=0 check_failures=0 class_violations=0 overflows=0 credit_leaks=0 channels_used=31/55 violations=0` |
| `predmerge` | `name=predmerge finished=1 cycles=943 from_fetch=912 retired=9 issue_groups=9 order=ok gpr_mismatch=0 pred_mismatch=0 mem_mismatch=0 check_failures=0 class_violations=0 overflows=0 credit_leaks=0 channels_used=33/55 violations=0` |
| `predspill` | `name=predspill finished=1 cycles=970 from_fetch=939 retired=12 issue_groups=12 order=ok gpr_mismatch=0 pred_mismatch=0 mem_mismatch=0 check_failures=0 class_violations=0 overflows=0 credit_leaks=0 channels_used=31/55 violations=0` |
| `predswap` | `name=predswap finished=1 cycles=1194 from_fetch=1163 retired=46 issue_groups=46 order=ok gpr_mismatch=0 pred_mismatch=0 mem_mismatch=0 check_failures=0 class_violations=0 overflows=0 credit_leaks=0 channels_used=33/55 violations=0` |
| `privwin` | `name=privwin finished=1 cycles=2220 from_fetch=2189 retired=52 issue_groups=52 order=ok gpr_mismatch=0 pred_mismatch=0 mem_mismatch=0 check_failures=0 class_violations=0 overflows=0 credit_leaks=0 channels_used=34/55 violations=0` |
| `provswap` | `name=provswap finished=1 cycles=2384 from_fetch=2353 retired=978 issue_groups=978 order=ok gpr_mismatch=0 pred_mismatch=0 mem_mismatch=0 check_failures=0 class_violations=0 overflows=0 credit_leaks=0 channels_used=33/55 violations=0` |
| `retmiss` | `name=retmiss finished=1 cycles=189 from_fetch=158 retired=19 issue_groups=19 order=ok gpr_mismatch=0 pred_mismatch=0 mem_mismatch=0 check_failures=0 class_violations=0 overflows=0 credit_leaks=0 channels_used=33/55 violations=0` |
| `roconst` | `name=roconst finished=1 cycles=78 from_fetch=47 retired=4 issue_groups=5 order=ok gpr_mismatch=0 pred_mismatch=0 mem_mismatch=0 check_failures=0 class_violations=0 overflows=0 credit_leaks=0 channels_used=26/55 violations=0` |
| `rogated` | `name=rogated finished=1 cycles=99 from_fetch=68 retired=7 issue_groups=8 order=ok gpr_mismatch=0 pred_mismatch=0 mem_mismatch=0 check_failures=0 class_violations=0 overflows=0 credit_leaks=0 channels_used=26/55 violations=0` |
| `rokill` | `name=rokill finished=1 cycles=107 from_fetch=76 retired=41 issue_groups=4536 order=ok gpr_mismatch=0 pred_mismatch=0 mem_mismatch=0 check_failures=0 class_violations=0 overflows=0 credit_leaks=0 channels_used=27/55 violations=0` |
| `rolaunch` | `name=rolaunch finished=1 cycles=76 from_fetch=45 retired=4 issue_groups=5 order=ok gpr_mismatch=0 pred_mismatch=0 mem_mismatch=0 check_failures=0 class_violations=0 overflows=0 credit_leaks=0 channels_used=24/55 violations=0` |
| `rolimit` | `name=rolimit finished=1 cycles=78 from_fetch=47 retired=4 issue_groups=5 order=ok gpr_mismatch=0 pred_mismatch=0 mem_mismatch=0 check_failures=0 class_violations=0 overflows=0 credit_leaks=0 channels_used=26/55 violations=0` |
| `roload` | `name=roload finished=1 cycles=107 from_fetch=76 retired=8 issue_groups=8 order=ok gpr_mismatch=0 pred_mismatch=0 mem_mismatch=0 check_failures=0 class_violations=0 overflows=0 credit_leaks=0 channels_used=31/55 violations=0` |
| `rope` | `name=rope finished=1 cycles=7760 from_fetch=7729 retired=354 issue_groups=354 order=ok gpr_mismatch=0 pred_mismatch=0 mem_mismatch=0 check_failures=0 class_violations=0 overflows=0 credit_leaks=0 channels_used=34/55 violations=0` |
| `ropediv` | `name=ropediv finished=1 cycles=1152 from_fetch=1121 retired=203 issue_groups=203 order=ok gpr_mismatch=0 pred_mismatch=0 mem_mismatch=0 check_failures=0 class_violations=0 overflows=0 credit_leaks=0 channels_used=34/55 violations=0` |
| `sel` | `name=sel finished=1 cycles=78 from_fetch=47 retired=8 issue_groups=8 order=ok gpr_mismatch=0 pred_mismatch=0 mem_mismatch=0 check_failures=0 class_violations=0 overflows=0 credit_leaks=0 channels_used=29/55 violations=0` |
| `sized` | `name=sized finished=1 cycles=2648 from_fetch=2617 retired=25 issue_groups=25 order=ok gpr_mismatch=0 pred_mismatch=0 mem_mismatch=0 check_failures=0 class_violations=0 overflows=0 credit_leaks=0 channels_used=32/55 violations=0` |
| `slotform` | `name=slotform finished=1 cycles=4370 from_fetch=4339 retired=12 issue_groups=12 order=ok gpr_mismatch=0 pred_mismatch=0 mem_mismatch=0 check_failures=0 class_violations=0 overflows=0 credit_leaks=0 channels_used=32/55 violations=0` |
| `spinwait` | `name=spinwait finished=1 cycles=2280 from_fetch=2249 retired=211 issue_groups=211 order=ok gpr_mismatch=0 pred_mismatch=0 mem_mismatch=0 check_failures=0 class_violations=0 overflows=0 credit_leaks=0 channels_used=34/55 violations=0` |
| `spmbank` | `name=spmbank finished=1 cycles=187 from_fetch=156 retired=13 issue_groups=13 order=ok gpr_mismatch=0 pred_mismatch=0 mem_mismatch=0 check_failures=0 class_violations=0 overflows=0 credit_leaks=0 channels_used=28/55 violations=0` |
| `srd` | `name=srd finished=1 cycles=71 from_fetch=40 retired=6 issue_groups=6 order=ok gpr_mismatch=0 pred_mismatch=0 mem_mismatch=0 check_failures=0 class_violations=0 overflows=0 credit_leaks=0 channels_used=29/55 violations=0` |
| `stall` | `name=stall finished=1 cycles=559 from_fetch=528 retired=116 issue_groups=116 order=ok gpr_mismatch=0 pred_mismatch=0 mem_mismatch=0 check_failures=0 class_violations=0 overflows=0 credit_leaks=0 channels_used=31/55 violations=0` |
| `swap` | `name=swap finished=1 cycles=559 from_fetch=528 retired=174 issue_groups=174 order=ok gpr_mismatch=0 pred_mismatch=0 mem_mismatch=0 check_failures=0 class_violations=0 overflows=0 credit_leaks=0 channels_used=31/55 violations=0` |
| `transp4` | `name=transp4 finished=1 cycles=1189 from_fetch=1158 retired=976 issue_groups=976 order=ok gpr_mismatch=0 pred_mismatch=0 mem_mismatch=0 check_failures=0 class_violations=0 overflows=0 credit_leaks=0 channels_used=37/55 violations=0` |
| `unal` | `name=unal finished=1 cycles=139 from_fetch=108 retired=9 issue_groups=9 order=ok gpr_mismatch=0 pred_mismatch=0 mem_mismatch=0 check_failures=0 class_violations=0 overflows=0 credit_leaks=0 channels_used=31/55 violations=0` |
| `vadd` | `name=vadd finished=1 cycles=161 from_fetch=130 retired=17 issue_groups=17 order=ok gpr_mismatch=0 pred_mismatch=0 mem_mismatch=0 check_failures=0 class_violations=0 overflows=0 credit_leaks=0 channels_used=33/55 violations=0` |
| `vadd4` | `name=vadd4 finished=1 cycles=241 from_fetch=210 retired=68 issue_groups=68 order=ok gpr_mismatch=0 pred_mismatch=0 mem_mismatch=0 check_failures=0 class_violations=0 overflows=0 credit_leaks=0 channels_used=33/55 violations=0` |
| `vaddslow` | `name=vaddslow finished=1 cycles=550 from_fetch=519 retired=17 issue_groups=17 order=ok gpr_mismatch=0 pred_mismatch=0 mem_mismatch=0 check_failures=0 class_violations=0 overflows=0 credit_leaks=0 channels_used=33/55 violations=0` |

## Manifest of release/

```
8566a20d1929dfd64db874c795ba4fe34c8383f097a1889978a5b761835e4b97  release/kernels/addrhigh.by_instr.json.gz
ed19552db8cde66a33ba1adc73f94e519c0846548d4a99acccc07842b438e0d5  release/kernels/addrhigh.by_unit.json.gz
c93aeb9dc8f285f326db15a94e97192d8a3fc733c02fd2bc3bbd5e1f4e3f9e0c  release/kernels/addrhigh.ccvtrace
c4de99b46beb6cdc791818290654ad0bd99ff0237ccebeed03364298886ef536  release/kernels/addrhigh.log
569f2e22883fad5f0956c57ec734e6afbdd4b8a854e50277425172d6c0cbd766  release/kernels/addrhigh.oracle.jsonl
6a86633a46da388f63bc88a933536aa3e05aa736b9537c93f4b0d84bc63cfc67  release/kernels/addrhigh.sv-hosted.log
853da840aa2b403572ee6174b356aee0444dfeaa9b2e6dfb21880fccaecbb4c0  release/kernels/addrlimit.by_instr.json
a5c1faeee86a00d7b6941ea3d04f18c8481284cd3fe332694db840efc1843541  release/kernels/addrlimit.by_unit.json
bec60a73b8b115293fa37ec0b4ec228c873e343c6c0771c8c2f26997b3427a69  release/kernels/addrlimit.ccvtrace
f70bb92224ececd426e418835e39ffa2cc9d586d5d73841dcae54a9b142d214d  release/kernels/addrlimit.log
bc660b0b40359a2c5a2478cb0eb4950b73fd22db50ea76b80052bc195a1920f4  release/kernels/addrlimit.oracle.jsonl
1f3d370e04fcf1e0d2c2d47daf741de443275ea5c058dc4f53a71d07a377f5f0  release/kernels/addrlimit.sv-hosted.log
ef76b3f5396f978b7ab85fbe69cf3e073601448a0093ea883e319f93331a4b4a  release/kernels/addrneg.by_instr.json
2dad823ed6aecc7f81449d20c7072f7d2b2eed4eefcf082a4b6175f692107004  release/kernels/addrneg.by_unit.json
288efd73edd0254ee3ad953a82a0a7a1942d7233c41e1533bb65bf4f23e47b2f  release/kernels/addrneg.ccvtrace
c1045ad729fe443904eb8e1b8693d7174aa6ccee28b803e4f9a3e6631608ed62  release/kernels/addrneg.log
16f5b0707ae44492a1efd67bb9dd38a7e79a7bbd354fa9207b9e7d150ff2f107  release/kernels/addrneg.oracle.jsonl
44f65c97c48f8eba4c02106e176b9dc7feae510de860c1da1cf66b0def462da7  release/kernels/addrneg.sv-hosted.log
6d127a0a43c4f7211be024393f5c6c2eacfd5984ca62f430a8470a5d4d2d9417  release/kernels/borrow.by_instr.json.gz
13589f270d9166761425cc920bb567bb1d9a2e57379878cafcde6ba8af44e951  release/kernels/borrow.by_unit.json.gz
60d4a4907e35d3efdcb8b9aa284916caa6c739cd8d30e61a20793a637c363a12  release/kernels/borrow.ccvtrace
e8d328fa2e7a7cd5b1bf21cbcd30d15b8cbffce1eeec2b97c63078066a7f16b0  release/kernels/borrow.log
4c565e1ce0b3baee36e158694b32c8defb5cd662b2f9af75cb5d8c26cb1168ed  release/kernels/borrow.oracle.jsonl
2a1ae9b7247f0fe1e9699654c344e8e31ee749132823447fe4c299d052109053  release/kernels/borrow.sv-hosted.log
8cc132cb42cfa824530214187fd4f2cd4dc8ec72039f90ec1a6732f1093c4046  release/kernels/brs.by_instr.json.gz
9bb80738d74796d603d6d5d2be857b71c8b3d70621efba624d1c85afd08c3058  release/kernels/brs.by_unit.json.gz
3c159ed22ceb8ed90511b03aa2e714d22e3a4b32ad405ffb8c2b1d4025b2fa0f  release/kernels/brs.ccvtrace
769f0088d8745773e1c8fac881e015b8957d2eea17d023ffe0dd16b7742dd725  release/kernels/brs.log
e3c1cb3379580cf1aae44e8ddc8e846ef6fd661a573cfe0a8d4444b18a14dc56  release/kernels/brs.oracle.jsonl
645d9bab0050962db3ed2a192823b65b3f6e4f03261f2828ec1150d513c79801  release/kernels/brs.sv-hosted.log
033ba2f9b3dab6d275628cda6657b63f3aa5c6bcba945bb1126b934724349845  release/kernels/byp.by_instr.json.gz
43a70ef3c42c1ca4bdf6acbdbd52324afe4d2c6c8218223650036472dfa876bf  release/kernels/byp.by_unit.json.gz
97d93b632fb837c4f847a7264ba0c549f87cce3f1ddefe3ffe19a0d07ecc526e  release/kernels/byp.ccvtrace
a8800ada062b131dd5c9a0b8d67de398c01bb815d9aee177be43937babf23f68  release/kernels/byp.log
5a03dfa4f3603fef49f1e3639e74e34152ca3ca5ef8e41eb959f8323040fa2d5  release/kernels/byp.oracle.jsonl
c46c4fe08593acacc0fa09143e4cb3f30cc61cda8e521bfe07a72d710dd88f04  release/kernels/byp.sv-hosted.log
5e3571ce22a1264b5705d7584bd1cb1d8ebfc8bd7a945c7914433aa15601d13d  release/kernels/callret.by_instr.json.gz
e6e8b24842ca702f5789924b153015f57b12483c4b5289e440b5b1f8706e0cf4  release/kernels/callret.by_unit.json.gz
983bc82bb7530e3948b98674dfc5485f8f162f94ba27c22f777b1b36055c8854  release/kernels/callret.ccvtrace
76dbc8205501c1f10c85e56e35084c5853f0a5683091c8a9e5e6af1f7796cec5  release/kernels/callret.log
9b1d1b50b527f732362f837250aa2f26dabf3e76e16a4794856ebd8f105635b8  release/kernels/callret.oracle.jsonl
fe72a6e65a14a307a371f715a09e1e9e72921dcd8ef21e3e6d1debc1aea3826d  release/kernels/callret.sv-hosted.log
1cfb5fa70df9016c3b327a18bcdd83535658012a0398ea4fcef789e766de7eac  release/kernels/chains.by_instr.json.gz
d7774739335dae8a63574d788ac2185555cfe7ee6bc1fd515242a49f01935135  release/kernels/chains.by_unit.json.gz
313b202fd14fdd42517b3b1d8b8c235b947afc3ceba603b365cf65c1818e5fd2  release/kernels/chains.ccvtrace
af2dd0060c95f64a1f99286bc6a9ed1bf273e493c9396eb7b4393ae519ddee3f  release/kernels/chains.log
26a4cc5c5524c7219d8706c2582c80357dea60be9d6ffdec99dac7d0365e2264  release/kernels/chains.oracle.jsonl
1e9b9c6bf155304bf2f16117607f3cc26753124f365af26da5a33e5072d1a95a  release/kernels/chains.sv-hosted.log
2dd86bc37d86e0900e73f62beea46a9250596abc5e1a9a66421a5cf37566304d  release/kernels/div.by_instr.json.gz
6d7a4adf84e58c05f735a863267d1d16d0cbf0bb30436ce93ec7ae2e71db2976  release/kernels/div.by_unit.json.gz
03f7a080135786fc6c51737ca125b335109d4802270839b37a1c6d796702f8c4  release/kernels/div.ccvtrace
d7f39d97801875b770eec9e53c3f23996cc0befb4f4788ccb9169d9a987b4d88  release/kernels/div.log
71a567b85cf85622631490187563de9a5661099c78a590adff4ed0a0c3d24c16  release/kernels/div.oracle.jsonl
276b83d6bd502ecf651973a265d1a706e26c105431929c278fa8224c55472ce7  release/kernels/div.sv-hosted.log
baf47832d9cf6ede155859053201345e16d713a62aaa1324fd1233c772ebcfab  release/kernels/divchw.by_instr.json.gz
2a574c6eb213b1d45a0dbb22b8bd5b96433de45df2c86accd1f4845a506866ff  release/kernels/divchw.by_unit.json.gz
dea85525a98956d8e6f00fd4c3dd9a3beacdf911e9f8cbdc1e218629b147de3b  release/kernels/divchw.ccvtrace
fd50bc0e032c88a43e3145d4b0766d8365c487699ab68c090d5551776c015c23  release/kernels/divchw.log
58a541797f7a2df0a1c7528ae6a3edec212db90c7d3eb20656806f38b5c10b3d  release/kernels/divchw.oracle.jsonl
baf0a4cd3804174d7ef3efd1ecac5b557b638813213a0019e6418e1643d746fa  release/kernels/divchw.sv-hosted.log
21abb0edc89f1c649b12412196fa0ce94ee510f6b10f44adb11b10ae99e66482  release/kernels/divtail.by_instr.json.gz
bca95cd2caf9c1c39868ed266b7e7d35fb2d381643dea04fe4c3b50653338cf5  release/kernels/divtail.by_unit.json.gz
104f3503128d1075c595daded22cf7676320753b5deb157d0c2ffaf8a5d667e6  release/kernels/divtail.ccvtrace
30d6535ae9fdd805baa09b9b3dff36aa903308fa74eaac4502d40d974a103b73  release/kernels/divtail.log
75f11a75c9b3b336e446140af4579f05b46c363a76b7aab3ec88154a07ba097d  release/kernels/divtail.oracle.jsonl
6e327a615617ad1e0647f08b8c1638ace739dd14aa1d69f45b291ad280e638d2  release/kernels/divtail.sv-hosted.log
2ad72eccef599fb7c1ea26b304b56c7f5844a9cb33561477584e01ac0c69196e  release/kernels/divtail2.by_instr.json.gz
847fd6ec32e00b026d24eaeee028be2b8832bd49a80e53d4384ed4e53f94d75b  release/kernels/divtail2.by_unit.json.gz
f463165bebe816dbba999e0e37027aed61a9c12602f537bba4e9863e2f2fa70c  release/kernels/divtail2.ccvtrace
6d8d528b2918aa851245808d20519ca21ec034c4c2f03081c8ab9192a7a11597  release/kernels/divtail2.log
b2db6b05eb6cf4a0a7677e31d0c6c2952d5cab49d353f0bb1883fe0b2a20ed14  release/kernels/divtail2.oracle.jsonl
6c77eb2a1c4fa6b64af6fce5fa2bf77dceb3df4118f0153592f99cfb846d8881  release/kernels/divtail2.sv-hosted.log
fdb51b4e28d2eb5134ee9b2f40f7e1624607077ed5143096f82066b4281e4d89  release/kernels/fence.by_instr.json
250272c41588a0f22d7deb05fde8d57599e3de98080ea3d92f416841d60679a8  release/kernels/fence.by_unit.json.gz
a30b49fd18cb7e3ad727e83998a48a973aa750e77cab68b043baa3929214be0a  release/kernels/fence.ccvtrace
f9b513638f101a7847edf043e1c3b79e490ab7bb3885e11152dee27900e1eca5  release/kernels/fence.log
d1d40317f6cf5bfb430cda1f9c0ef676609e59cabe2a11623c42ffbeca93142b  release/kernels/fence.oracle.jsonl
7a5a26e9b1048966e5c247c423e6c23d30a6f5383ef2d52e84e77c00b42f0339  release/kernels/fence.sv-hosted.log
8650e959204a8e0265fd095a1353202fac5d02cbc1b17c21a100c80a889fe09d  release/kernels/gather.by_instr.json.gz
0d3b8c6d5647c10432170a2d10daad9e109f3497160107d226adc6a40720f651  release/kernels/gather.by_unit.json.gz
937976d4db694d23a93f82e15f626c9aa79ecb0615350355abe4385d3ab80716  release/kernels/gather.ccvtrace
9cdb805b15c5dce6c16090361e7011e21c9ee609b47561a612e028f343d9452c  release/kernels/gather.log
0413e781d8d6ff578c64eb1f800b7931e66f676d5cdabb97b94a4033e6037662  release/kernels/gather.oracle.jsonl
06e85b1a40644dfb6dee403e163e6ca9670acfbd743926c240552849ba130d37  release/kernels/gather.sv-hosted.log
2f7fc91e88dbcab66521cbd221f8a019d5d7fbb4735f07709a1155f2296d2ce3  release/kernels/hit.by_instr.json.gz
44097007a4e2433ae2cd1eac852f86aacd43004ba001e13422eb5fd9500fe080  release/kernels/hit.by_unit.json.gz
5a922c12010856027dffb96da7571d025dc309a3aac34b425a6a2208d6023f40  release/kernels/hit.ccvtrace
aa53cdce0cc0905bf18affce4b8dd63e3ce9e897386b95c014fcc4bab087b16e  release/kernels/hit.log
7ba9603e0088d9164de6528f16ef6a7fa9ce5821c8c12b52cbb3734e39b9fd52  release/kernels/hit.oracle.jsonl
135e9de8494fb245c94e8b9418c4c0615e92132605d3b362331b0e0994cba19b  release/kernels/hit.sv-hosted.log
329d4656300aabeda8e465a34f356afdd970a5d06d289344331d1448979904fc  release/kernels/lanectx.by_instr.json.gz
4d454de14bb28872dc9a94fa8fb46c676c227977b816140fbeaf4c06edc7f2d9  release/kernels/lanectx.by_unit.json.gz
83beebb1cb18c2c64939dcbb1d7bb6ec5187cae00195b643ec933942ad4a5ace  release/kernels/lanectx.ccvtrace
aafb2576913342a19fb9a96914b6743607acd65100a7f6e778757cf54f2e2be7  release/kernels/lanectx.log
888551babf540db8e3025b82e65ca655013f93eba3c8a65689d069d52a7e6039  release/kernels/lanectx.oracle.jsonl
7490bf2b4b6fa099266dacc4dc6b83c1d82b7226cccaf764526ae45a45ba4ec3  release/kernels/lanectx.sv-hosted.log
6b6341f706e5be9402b0d72b01eff9e89207756498a6cee6ce9661305d8691c8  release/kernels/lanectx2.by_instr.json.gz
25d3d49a51f7cfc0e3bdc71cfb1f9c4f94d8d98ea98484758c2d796391d1a17d  release/kernels/lanectx2.by_unit.json.gz
b98113570507141cbd7f696fe5e5e73111d833163f395b5b89c8daa00326fc7b  release/kernels/lanectx2.ccvtrace
8b07b5ad6609873ff065cfea94209307c80b2cc234fed860dc646f31cc603804  release/kernels/lanectx2.log
45c13056dff5c73ed0c9ece56cc36f929bf335322193c7d5eb38710b1d1dfb02  release/kernels/lanectx2.oracle.jsonl
e959184427763f37c42db202d5f8fe9d1259e39182f6bbe35c6f14c4169cad89  release/kernels/lanectx2.sv-hosted.log
d1e1f3fa992bea23f2938b5d5b730fcf845f477711143983d32376f2c9ee8b67  release/kernels/late.by_instr.json.gz
845d5fc8043fe8610f0adf16f7cf426c8a13a3b21754c570a9280d4eb658ee9d  release/kernels/late.by_unit.json.gz
9c5f095ee55bbaa73ab9deebb149296fc920aaf72557ed69eea374f6a1d62cb6  release/kernels/late.ccvtrace
5d7b628e42a238d93276e518b842baa545f72913fec5b4531f53adb2e783e96b  release/kernels/late.log
86084f6bd747a2cf32acbc0ebd96ebd3e4ef2d8d9e21be49e3ae49290d7927f3  release/kernels/late.oracle.jsonl
27885b57a12110f18939956c83953087f221d283a4f3d3b3b7ad2638d90bb984  release/kernels/late.sv-hosted.log
cbce3717b3c7c36cc5bc686e03bed3e1a75f712a5cf1ed9a02ceebe2c4ab259a  release/kernels/ldpar.by_instr.json.gz
2eb658980931096000746d97a094f6e30954832b11ee569966a99e6a50b8a995  release/kernels/ldpar.by_unit.json.gz
90a13bbb1b4a73967c6a12c9a0ddf0691c58bfce7721e567dc12f98d60fe8bb6  release/kernels/ldpar.ccvtrace
fd72966795a08c323731bab52368755ff6507f07fe7c4b95afacc29bf32bed96  release/kernels/ldpar.log
8ac08538e9c807637babd61b31e340f7461878ada31f0c0b83cd66331cfaf486  release/kernels/ldpar.oracle.jsonl
ed46a28fe88e2fc8e5adadf636e154ba4c995d8b2c5afd4ec8c1100a77836921  release/kernels/ldpar.sv-hosted.log
0e03d4c045d6f9b8d5c831973752165618b5f4509bae6be668b525d02da9d809  release/kernels/lnorm1.by_instr.json.gz
418c58b0c2bdc3eda65b1713cf53cab5a321338661f37c7498a84135d973faaa  release/kernels/lnorm1.by_unit.json.gz
c1442c6dedba8b28de99dd330fa3e602cbfd38abc87e69304704dc24c72cba6c  release/kernels/lnorm1.ccvtrace
cca9e4e81534875b7a13fef2621267a2571bb8da44921352cf8a011969e8f06c  release/kernels/lnorm1.log
a8d85811af988a1b9fc00db1517300af3d93ec8e589e403d3b9113fa9e0ffc86  release/kernels/lnorm1.oracle.jsonl
adb5cc2a40621041a41341a5e951c2fed825288efa3f3a18933f5e32b571b486  release/kernels/lnorm1.sv-hosted.log
003ea7717f988dffa94195d797be76ed11a06d5bdd8d7a228914f082dc111d2b  release/kernels/localsp.by_instr.json.gz
33c92ad416e841b80685cf49d159d0db9cb3e115cc2ff9e91ecd3a4a5163f858  release/kernels/localsp.by_unit.json.gz
d2e97823475653c0b0e65966a7c462221710b8a68d68c57962c31b429106698c  release/kernels/localsp.ccvtrace
e135b23b40fd28c7841f16b8fcf2f16bbf51b43f4a9a2c2fa2ef0c31f24b4447  release/kernels/localsp.log
55e3c9f36e7f7d38c0ddd38903aff4bb4509ae862015c592e6b937ea258042ca  release/kernels/localsp.oracle.jsonl
7c9aa9ccbf7d1252df18781d2fc4a13d302cb7c3fe8900b6b45dbe816a6e3bf3  release/kernels/localsp.sv-hosted.log
53d3162e20ffecfad9d65eda9bd12398a90e4ddce327a1a4d6459d4f0b01afb3  release/kernels/loop.by_instr.json.gz
3ffc973c5169400e26b26d91eaf2e910343d8b29ba8f247da9861be56f9295a2  release/kernels/loop.by_unit.json.gz
17f3e2f84ce1fb9b323a46604c530deea7c450d90455e7cee2124ab5801e1562  release/kernels/loop.ccvtrace
6d3e101d401a8d86b59c9ce8d59e74989ced056aca24241f5e85b0d677c71f1b  release/kernels/loop.log
03ce5920c06c93e93516d8e53c3f7169f14e3593de204eacceffc0b8a3e32016  release/kernels/loop.oracle.jsonl
d989cb57c2b8655bdd620158cf893fae349bdba9e97133e5568496d684e740bd  release/kernels/loop.sv-hosted.log
df4ab473e12b233410ce2d5cafcdd22536f0a7789b6ab926d03db9f7040e94e0  release/kernels/merge.by_instr.json.gz
303169051789dd529609f755adfa3813d0eddcbd6dadde914364d97355409115  release/kernels/merge.by_unit.json.gz
e00c16dee608a887d2d4e4fac629f8f99216d3ee046b249b61873232abefa6aa  release/kernels/merge.ccvtrace
ef8bfd88f899085bba5f5b89f12579b02b7ff68e7b2311d9be409cd6c4d11469  release/kernels/merge.log
f96d28815f8756b1f5a45ded53e6170883d2dfa10f9eef0d14b8050b1318164a  release/kernels/merge.oracle.jsonl
fefa45224c71e76cae8f233475012d13f89e0a7a6b5277966a7ece161f84e1ca  release/kernels/merge.sv-hosted.log
e92fb026b53cda6cf6ce3603078ae9e309b418f53e261ac83d0285297c99347b  release/kernels/missrun.by_instr.json.gz
e00488cd28c325be7482a2fdcad8d9893df025dd0ab0a7a0d9e63f869d3991d8  release/kernels/missrun.by_unit.json.gz
49a8d751837e485556ec3f0c525008cbf1c5029c3278f83dee84e60f994a6bff  release/kernels/missrun.ccvtrace
5967832e3809a48a10ec9ac29334d8ab73f6293ef3bd8fd5374412322c72a455  release/kernels/missrun.log
531bdaf281e5590774bd2775427f25e4cc0419cf8e3d5b6999843ffe9ef87258  release/kernels/missrun.oracle.jsonl
68bb0b57b5a74b400ed537321bf64e86808150b3fa15c659aef3c5f1d0297cd9  release/kernels/missrun.sv-hosted.log
c23d46e24a2a90305b20d0a68e3703c8eef8df09ac413390a58d00d34485e8b8  release/kernels/mload.by_instr.json.gz
1c6ba7fd2efd754894b76bd944f9540c053c13d248400e1a4f05a804a1314b5d  release/kernels/mload.by_unit.json.gz
55da27088b1003b4129ae54d6dcf1f3edb0ad6337af65fe429ea6633d47bebea  release/kernels/mload.ccvtrace
248cc4f91c1040cf9fdb856109538247067583cdd6314c46b254c6ea55349747  release/kernels/mload.log
8000e477b9a95dfb9f0af964e8346acb9d36f1358fd06ffc4ff7cf599d2b8868  release/kernels/mload.oracle.jsonl
4e2b6394a8bd4852a0ce952602d78b70646662c246a789ae47d60ec5ed434e3d  release/kernels/mload.sv-hosted.log
5f77f5aa34a89ab785603519d02df24eca46816193d0cb6986702527b7f732e2  release/kernels/mlp.by_instr.json.gz
9369c212ed6cc6c39fa6cbb29f36c32b25f4fdbdcb5421dd4d494644827e162f  release/kernels/mlp.by_unit.json.gz
b1f3877e43af67ad0f4e579da8122d8833737c2ce3a41d70fc32c394cdb3a8e6  release/kernels/mlp.ccvtrace
38420e603511c20cdbcba11b9bd2c569ade43155e57d535dfa4f4efd60d04126  release/kernels/mlp.log
138d282f88d56c8ad648a91af0a983254b55d9fa22942c00d47b327f516a6e44  release/kernels/mlp.oracle.jsonl
7c1eea1d7bf2c305483e93cdabc9bfaf8f61ac57f68c6dfead8a2f8b3767f05e  release/kernels/mlp.sv-hosted.log
f900ad439e82a3e04edf9046302514df1cab11e3d978b48354a485354d35a2a4  release/kernels/mwmiss.by_instr.json.gz
5c266d3f75542d7a6e757a0112f7aa6f8167a703fd1816d537c2c834414b5149  release/kernels/mwmiss.by_unit.json.gz
f559e0d8883122f74f7b036ef2ec548913c39414caf683dfb22bed0b1f2037a6  release/kernels/mwmiss.ccvtrace
d87f72ca5ada370e2c370f89d42adaf5b808eded006676af321c4f18c3b8233b  release/kernels/mwmiss.log
8abe8e8997456a2a6711ee72da54d854b24e20abbdab28e4b7271c0d28418de8  release/kernels/mwmiss.oracle.jsonl
97255f78ef503c931327d2111a0545e66c79c4d373ebed38296370db9e0c0c00  release/kernels/mwmiss.sv-hosted.log
57de65575d808f22724246aa8821473708d7db5a717622c29f77a0f17e541759  release/kernels/narrowadd.by_instr.json.gz
f55aa9fdb1055771a69322b7c81a440df07f4030d12d020b221c673da9b72006  release/kernels/narrowadd.by_unit.json.gz
89768caed29d80b84051d7a0db9c259baff0e5e86554d670b8ed2542b1b8240a  release/kernels/narrowadd.ccvtrace
ae81fbe9e878aeaa98d849f220a2910dd78a463830b4d66ca5db2cde8131c62c  release/kernels/narrowadd.log
40a2cf629853dd404bb06b4a07e35abde3d12efc13f26ffe28f923daf2994574  release/kernels/narrowadd.oracle.jsonl
593a5ac7ceddee70a1f2ced17f99d557a17b11f7a95b87275f8885577615055a  release/kernels/narrowadd.sv-hosted.log
cf96f3ee626407a2f22b1bbe2481db7e581a759f403f962f068b371c4cf6aa05  release/kernels/pguard.by_instr.json.gz
afd3d5d23e1ac98b034e66173bba4611acfde9bb81f541a9d83342ab9b96ce75  release/kernels/pguard.by_unit.json.gz
a38f130d253c05c533f204d4870f1bd4b8e39f9f9f07236034b56737b161e7b7  release/kernels/pguard.ccvtrace
396d94e4d3e4421e560e87ddd6d0670b711bf56bc7f14463a3b985a9c912dcc9  release/kernels/pguard.log
690e56f1cb8d97cbf67124b7dff3ad0a90cb8981814cd1709cf0cd0e035b3bd9  release/kernels/pguard.oracle.jsonl
371443618d44eab6620ecb2ac496cec3754229ec875cc6846ceb24db98304336  release/kernels/pguard.sv-hosted.log
593a676d8109eeaa8bd4c646890831a88c764a4764d65b41cbed48d5afc6a23b  release/kernels/plog.by_instr.json.gz
cda772b0abbaed6c8de5446bd8baaf69d6be8ad0a295713799796c8f3b200591  release/kernels/plog.by_unit.json.gz
a63bade7370eb7774bd954fd5a0a79ca928bff9fdc0502b1da37a204b8ee1aeb  release/kernels/plog.ccvtrace
d6381c92c3f7999eff283fc95ce573a9089dee54f2445ddca8c469ba370885ec  release/kernels/plog.log
c230f13f2e1082b306a9c5ab7809ff36cf5c1b2e47dca6b7a71f741524d403f5  release/kernels/plog.oracle.jsonl
816c9a02a8a673bcb41817629badd5d19aa09e6f4ff5dfad062bd8aceacced5f  release/kernels/plog.sv-hosted.log
4f531f3e99ac3939d9fce123aa836007d23acbdcbadefe3b1220bb99c8475ae3  release/kernels/pmovdiv.by_instr.json.gz
ec63ae676b6b97def4b66d1815a977448bbf1eecaaf21392913c1dc8b7548dd1  release/kernels/pmovdiv.by_unit.json.gz
82b5a40f01be204d368a4a4e3da18b9d4da8e65755305215b8181887e213c40a  release/kernels/pmovdiv.ccvtrace
30d10a2204eb205f909e9f4e0b41e1263637797f5c406175a2b873f63d028f8b  release/kernels/pmovdiv.log
7bc646cff6166a51bdce03d7c1b7209e871f0a91d743083a9b910a80bcd0b33f  release/kernels/pmovdiv.oracle.jsonl
dcad617985854cd64d24816f2ef37508a007f7596d818d38a032979731f11dae  release/kernels/pmovdiv.sv-hosted.log
1eeda76d2c56b8adc56451306016efa1328d605fe075c38d8317fca98a0d0f9e  release/kernels/predlane.by_instr.json.gz
d5f75b883a920af767a1b3e8331614e2556d3550a8359cdc5dafe333dbb34f39  release/kernels/predlane.by_unit.json.gz
ec76703472edc9de24902d04f52b6f564854b6c082c1068334496aaf0ae3770a  release/kernels/predlane.ccvtrace
c67899bf1e6097cfa516e7b81c84b3942254393906b733fc07681e26c3204c7f  release/kernels/predlane.log
c45f4177b9e84fc8a6e36b13534a0c7636eb30a3f8531847100ce5e23bf404b1  release/kernels/predlane.oracle.jsonl
c483d38f48208a035a26fb18c9ea41fb163c4b5fe82336e03de900323866d8a9  release/kernels/predlane.sv-hosted.log
6d153a360113d8d8112d2afc30f0d9f79577b749330ac42db1c3ed4039285c28  release/kernels/predmerge.by_instr.json.gz
14722da25ff4795c34d158191f58517a6f6f7b1653ab24f079a0939e0f0f0b62  release/kernels/predmerge.by_unit.json.gz
9e1cfb8b2502ca9d658ea557fcfcd6f0cf85e7d2d0549cdc9dff6ae89d5250b1  release/kernels/predmerge.ccvtrace
575675336be3430de400dc4520328a35542b9689fb7607249b8d697b01c0e2d7  release/kernels/predmerge.log
6c737c49434bcd08e3e0814c8b1dbf15c586ae74f7929ba3148ddcee2c62c845  release/kernels/predmerge.oracle.jsonl
dcfc4c334ad48b64742a361b4cb7b56d09ce2e9fedf2658ab2b1359d5197ae75  release/kernels/predmerge.sv-hosted.log
eb2ff7f2ffbc63b72a3bcd8c567c00945c7700cf90d90b430415e7d1989e5b14  release/kernels/predspill.by_instr.json.gz
218f38e7da51d533158c74d6df4de00d7d806e2c7893278d6b6e9f4136ce44e6  release/kernels/predspill.by_unit.json.gz
538a6cdfd4a9a3cac26d8076c4b8ee3271693fd0403e8ccf00fb52c1c8ac9a49  release/kernels/predspill.ccvtrace
d55e9b337c25be9c97bde603365b2073da69e4c129fc366af8aa6ae03a3523ee  release/kernels/predspill.log
b7c84c6478117ffa0f06da0e6ad1e4628e2683426a7911080810e78e06a5242e  release/kernels/predspill.oracle.jsonl
25b89168fbef36a931d1f97147273f81cefb9bbd33d88a3eb230384ec6282999  release/kernels/predspill.sv-hosted.log
92e045496bc4cbd45ba028733d531265f6ab45934ec6cba514b502c68f1f3bb6  release/kernels/predswap.by_instr.json.gz
5f4135ca145655c852081ef87d6d2328c6a616dc16aa0420e63885deb34d57e5  release/kernels/predswap.by_unit.json.gz
fc438bea55696ecef7147f04be5a4a38d4e981d8b5da61b73a14da4bdfbdfe94  release/kernels/predswap.ccvtrace
2b5088900d031306a9f5d6b2d06f18bebfdc1cc4926ec4dd9314c60935d1f26e  release/kernels/predswap.log
a6d4f7ed517553816d889c7c9eeb6bcfd1f6c973fbf682ecb69f3c2de619f7bb  release/kernels/predswap.oracle.jsonl
35f5939b7c3da2b984da0c7456ac8a8442bcfd22fc25a2e9b18eca4840c2ce72  release/kernels/predswap.sv-hosted.log
d726dc12562a98b0a3baac5d1c0449b0edcd243ed335c95e459759ce9f5b593f  release/kernels/privwin.by_instr.json.gz
5c0b95a8444314c35c541cb5e250f318c21df1964e3884f23ac5977f24589a61  release/kernels/privwin.by_unit.json.gz
95d8431fec72ec4d8a9285fab6980efa1594dd03e2685e421b67cec228b32553  release/kernels/privwin.ccvtrace
050bcd19f491fb5fa012d2e53131a4bb423207b7591d639d1860895e781e575e  release/kernels/privwin.log
861f686fc4480363472908d679d8815e8c957d768e7ab32c826930527b0fb7a8  release/kernels/privwin.oracle.jsonl
85f06fa65d15bf39c3f1f05d0a6d4b37762e45da939f1584998b7d85be6010c3  release/kernels/privwin.sv-hosted.log
c131d9281adf1aa71207a6bfaf978138be77bcf9a922dbe5101f41170917f66a  release/kernels/provswap.by_instr.json.gz
399f5078a9b1c9c44711a9e4e470a4a3d599a6bd121f078538967b78cee8a7c8  release/kernels/provswap.by_unit.json.gz
924974a1e67f2b797466395a5629f833b0037978d8954b065b76ff76e2248d97  release/kernels/provswap.ccvtrace
483a49beb329ccbc6c0136c64b4315c45a132492a6101841d266135180221037  release/kernels/provswap.log
c9c32a793d54cc7401477f582487f7e8b345b2669a75337b8d6327120d98e5dc  release/kernels/provswap.oracle.jsonl
b43075bca07ba6166e2587b486093e27e3156faa06103a01ec50154b5269e6db  release/kernels/provswap.sv-hosted.log
8db196a96df6a9f2216b5860c860f850108cd5c350942c9a52a5aa7f2938ffa9  release/kernels/retmiss.by_instr.json.gz
feaebed652b1a8db729244247fbfced122231eb17d0ab9897be0fe6ed29103e0  release/kernels/retmiss.by_unit.json.gz
5b3e5028830a0135b02467ff904bb4a636445b2756eb5bb69fa4a4964ced701f  release/kernels/retmiss.ccvtrace
25e8e48d90bacfb1c43ec7d9c8cc49b129d5f86df276922f813acfc9edec1af9  release/kernels/retmiss.log
e5ef8538e838c6cff7febfc679dd091cf5e002f82d34f1009b1948ce22bc3649  release/kernels/retmiss.oracle.jsonl
e67b18329227c49aa891a64c4250a530632074043d0d43a413b6dd14747ffc3d  release/kernels/retmiss.sv-hosted.log
74a1a6f3ea4ffd4d81ee66ed959cd63465a231a3f183d4bc73a1eafa8d614747  release/kernels/roconst.by_instr.json
f4bfe41abf263c57202eeaa306f93d91410a2ab00eca953731902e669a7f660c  release/kernels/roconst.by_unit.json
4b1dd563bc6fa92c5b2eea552e1788c14dd677aec4f90a9cb3d33ca25ec5784d  release/kernels/roconst.ccvtrace
901c69ac3a3d7105787fe5f12195ab8418ede5e51ebc9f9ff0c7bec74837c807  release/kernels/roconst.log
8087c0671de620162881aecd38cd6114b78e7be6bd71201e3ec02c9a2e2e750e  release/kernels/roconst.oracle.jsonl
ef802a553c30258258e35d1f7c8544bc5d0dc1678253384a8ff1231a3aa7d5ac  release/kernels/roconst.sv-hosted.log
5852940e352c331418b4a27c17fadb640966080d8a7b7726319869ece3e3ab06  release/kernels/rogated.by_instr.json
3aeff4532017df894222f56a8c44389dc17c77d6e9fca6971458fea1c6da48eb  release/kernels/rogated.by_unit.json.gz
f4da3effae59a971083ca36a1f97a9fb0ef15161596937ecf10954785f4afc34  release/kernels/rogated.ccvtrace
65ed7a3465f6dee4a78a839168cf7d3d35c01bf4d109c9335350c382332b6d4c  release/kernels/rogated.log
7cd02bd4cceec5a044d6b4d6a80df1e68ed0ae71b0b2a953143636d5b809ea6c  release/kernels/rogated.oracle.jsonl
964e7325c04f6218db9b64cff261183a25bf922c1547db5b21c0d5565d4d0de1  release/kernels/rogated.sv-hosted.log
c7f90a36f138e1076ecfc235aa62c98e5e18b1e83662eaac14f38136e1b92d20  release/kernels/rokill.by_instr.json.gz
d965bdbc1670f682c8d4248ada61db92296ef1c956330568871d76eb5b062f13  release/kernels/rokill.by_unit.json.gz
af1e24074ce5a43cedfede66d1ae3db0c8d7a8c88268df75467575bfa313f0e0  release/kernels/rokill.ccvtrace
07093084b306f167c632e8bb7c1ca7ed7cf68fa2be6aa1fb3ad0cfec20dedf18  release/kernels/rokill.log
94efcef96af469a512d346ce61623980fe86383188eaebd55120f716db596f14  release/kernels/rokill.oracle.jsonl
91e02603218612372e066989a379fee160e4c00f07a72ba0844535f8e9a57c21  release/kernels/rokill.sv-hosted.log
9edfb2939fe367a0b43cc7672f64b30efae8b8eb8dce8cf7a28021a55ac9ca7d  release/kernels/rolaunch.by_instr.json
2d8db50db98e25664c65712aff155d4c58890f24b6dff040e39d86575eecc8e2  release/kernels/rolaunch.by_unit.json
2722b0180c5571af28c5d5e57ac84a49b48d2d9c911b2384eaedb5a991c3bfdd  release/kernels/rolaunch.ccvtrace
12af9c237e657fa8123e45f5a2bcc063449a0c9fb261f20856b1c460d88a19db  release/kernels/rolaunch.log
e7dad585c3e70615de04330fd03f4f282c29a005dc1732a35655fb261d51139e  release/kernels/rolaunch.oracle.jsonl
33ae7f5d507ee6e623214f53263f8316582e03db8ad12eced4aca339f91c0dec  release/kernels/rolaunch.sv-hosted.log
74a1a6f3ea4ffd4d81ee66ed959cd63465a231a3f183d4bc73a1eafa8d614747  release/kernels/rolimit.by_instr.json
7dc8e0b1feb72fc32f336cc9276ff3023f83a4bd67f05b1c1d2db5bb5c43778d  release/kernels/rolimit.by_unit.json
77a7f0cd42431f4de36af6652e5a915198a183814cac386918ec5f96f10c4693  release/kernels/rolimit.ccvtrace
67d43a5429607cb6967f7736b6bdf1f3075e7213bb05695ab3837a92a0f89175  release/kernels/rolimit.log
1c5bc0cb8e8b2e69505fb5a551a16d5d10c56f232b88da7a27e336ad7d962de2  release/kernels/rolimit.oracle.jsonl
d8efcf6e72994376f9bc715f9daf339282c9fe2d08851bdd911bbf2dc53c8e02  release/kernels/rolimit.sv-hosted.log
29b581af746c35e6eb6bf33f37e0804edfecfe6b2c39453d004480b68813efe3  release/kernels/roload.by_instr.json.gz
3ed0c059840f6c8a9703180f6d597e0d048b37dd0c6629dca156631ec1c0164a  release/kernels/roload.by_unit.json.gz
b4483eaa4bad1c697a50d109b3f8c939d9b3dae7824a7627c6f31ead219ad9c0  release/kernels/roload.ccvtrace
61cc06259965d5a06963e4bc8f5a0475f725e72a632782719cfe46937199a705  release/kernels/roload.log
f7c1309cc9764769fb5803f6fd0f2f5e1eb418f2d23fbe5e17cf5f9106869fdf  release/kernels/roload.oracle.jsonl
c64402814f7b14440b1c4a9eff08ba3ced133a01acbc0dc6da5c117ea482530e  release/kernels/roload.sv-hosted.log
5d5e88da7106b37d492b1daa2ef9552ee0f4e9f41347201d8f899ae6c64eb43d  release/kernels/rope.by_instr.json.gz
8bc61dc5f1f2d66db1c47b95e5ca937be06d73137f4380902a666640e9f29e45  release/kernels/rope.by_unit.json.gz
91d75829f82e283c0ca83e00945473c8c688b469781827324692490cec771dfc  release/kernels/rope.ccvtrace
16e345dc961d55efd54018d3005a461c7af9923e8235fab3a91a83cfbafc717e  release/kernels/rope.log
d55f9efae392dc8877c102c01c0810e7654b666b6ede386328108164c6cf88f3  release/kernels/rope.oracle.jsonl
c2e1fd4976f602f95d2792956a0044d4848a13f4c43f939ccb7bcf0eeb2ccb3f  release/kernels/rope.sv-hosted.log
8f06bf76b726bd5d061516e5b6f9017b28f812011f6771d58ef075c72d3c0587  release/kernels/ropediv.by_instr.json.gz
44285403d488e41de04524655ef5d02857c7618a0342203f2ae26d17f84f7990  release/kernels/ropediv.by_unit.json.gz
d8d0a61ec48c92329965f2f4db0fb1e939cae365decf5062e88b66705b7ddb40  release/kernels/ropediv.ccvtrace
cdfd882e26ddf2ad2ca5866f78873a70a8ebc06bdebca1a16b1ae39590fbde86  release/kernels/ropediv.log
10c0ec6ec18b7b44638c790033109198c079d07c1537bf193353ccedd00a920f  release/kernels/ropediv.oracle.jsonl
6efee20923891e635a6940c659de455ce3adc3839d3c2e0ca3c454a6ca4e3797  release/kernels/ropediv.sv-hosted.log
44762a20fae74a641306a271000f400732fef79382a264803830fe7cc20e6d28  release/kernels/sel.by_instr.json.gz
de44873592a373bd8f38f9f9febab339e08c7a5a0ebe16aa46c7590e41719ed9  release/kernels/sel.by_unit.json.gz
80aba30dd18a9d75d96a88ac75ff3ea1cadb303b06ecda90d74fb7a6e39c65e2  release/kernels/sel.ccvtrace
37da397e775475bbda707671bdfd940993e68147a99941b97bde250a0f84f06e  release/kernels/sel.log
87f6a81e8afa004c8039bf2f61c90176fcf29ab29bb17ac44aa016a5cc8438fe  release/kernels/sel.oracle.jsonl
6b64b5f8c1ae79cea293eaa4aab2514246833f027be29a1d476d912f650845fd  release/kernels/sel.sv-hosted.log
54021f4574c995a4fe8a0c7f4f55f337039863bc5550ca63d38bb5528906c307  release/kernels/sized.by_instr.json.gz
adf5a3426b20ce64eca918cc68e3eee20172e0ae9637d5c29316c9cbd78a2a5b  release/kernels/sized.by_unit.json.gz
6dde89d5e7817b7db61492d7430942e54177d0423f619dbb1c341f427d0cf094  release/kernels/sized.ccvtrace
04002e6df15d5d1d740c53b29444b7def9bf03c86dbef3fb589a969f8709b96a  release/kernels/sized.log
36d903ba1618bd1faa437c9812a6ee6c0c966a63196c796267d74bf2695ebc3d  release/kernels/sized.oracle.jsonl
e943ff75e9474bde68754aa7f2045b73defdb06d327f81f8f2b92fe2eeec08b3  release/kernels/sized.sv-hosted.log
5de08e910373687f3303ddcd0aa43df0af9fb821e02064a8958a5da08a876996  release/kernels/slotform.by_instr.json.gz
aa18e20af4dce0f5fe983ea6ea342e4a25162fe25eff028b3b53943a5ff35615  release/kernels/slotform.by_unit.json.gz
f4df59634e4ad36e24b0c8e5ebefd28e6587e4f8c7b363cf3c755dd60c8a37d2  release/kernels/slotform.ccvtrace
986298dff4eba98ae593c5eb2940640da8bca6671cadbc8327afabb0d35069c5  release/kernels/slotform.log
8b61db7419b18cea8a646fb628218447e72e84a18a9891ffb73b441736138ab9  release/kernels/slotform.oracle.jsonl
96a4a2d7fc59865caec7b739befdbc143f636178fafc2b356e3e3316ef23aa1b  release/kernels/slotform.sv-hosted.log
f0bd01e55bb1843a0aa6e4a2e93f855694a21c02ad5c750df31d46a0bbda2b65  release/kernels/spinwait.by_instr.json.gz
6ad6979adc34ef2ff917640443133efa0302fb5d275544c2a059cecc371f0c2b  release/kernels/spinwait.by_unit.json.gz
bfe5aecb3cdc71cca10153e0980ad45e1c5a5d1faacf84c8bac7843156328dad  release/kernels/spinwait.ccvtrace
8e0229a6d789f1a57cb0dbdce986bbc4ca60a7550483aa8318479cb3e93144ed  release/kernels/spinwait.log
868920637236c878b33779bd450439466fc3626996a3164573dc11d437d5c709  release/kernels/spinwait.oracle.jsonl
421937b0c52f957af26d50eb2f736b72dbe7e0c32d1c5905725c40eab3a8f50c  release/kernels/spinwait.sv-hosted.log
17eda36707a87011338eca26a1072099d1cb2bc5bf8a06a23edda4e9f2239731  release/kernels/spmbank.by_instr.json.gz
05fe3f576f3f91c1035c790b6133ca6d4f2a2f6cf4f16a3ccd20fb32f6f9ad17  release/kernels/spmbank.by_unit.json.gz
cad89d3bced160d71dee0f982dc2ce8828c67d8d5c3af43949ad3f47d7e0fe80  release/kernels/spmbank.ccvtrace
8b67af2fc0757a32837f6cdedcd3983cf202074d59e4b52a4d4b5245b93e5227  release/kernels/spmbank.log
3af490cc37d7a92dbe719b57de216b648536eb301ff9d13de9a39f50d150d725  release/kernels/spmbank.oracle.jsonl
6974dc71c617fc1bd729e438ab86e4d247f483f72fe11874b28b4de942dce9db  release/kernels/spmbank.sv-hosted.log
db644d0fd5692394301d59dfa8bb94e39c618df7282ced038984fac605d7addf  release/kernels/srd.by_instr.json.gz
463fe6bacbd1be9173ec1dfd7eba813f17f3f3d80f0207a0c97367551758e67c  release/kernels/srd.by_unit.json.gz
2ed6893819d8ee78dba28ae7a71416001b231ef39034f3daec396a29b14d69eb  release/kernels/srd.ccvtrace
46cd18e402a70d5b9f5268dcdf6a899c3f3030a3db5b45f813d4052e5ba1dabc  release/kernels/srd.log
b08eb5e3673cac7eebb8b72af5ed3783c8e70a9e96592e76bf3722551bc79473  release/kernels/srd.oracle.jsonl
011ad538ae47893c2ab11f4a894c32ad99f9a7bd1fc7aaf40a03a88a27896813  release/kernels/srd.sv-hosted.log
e1267260b050ba378fb5fbc09f24e658daa4e39202b31fc01ad09835a8627c72  release/kernels/stall.by_instr.json.gz
f5a6ce7ba086c61f33bf2500613bf205b549e01182b473c538fa1113d1a8bd14  release/kernels/stall.by_unit.json.gz
75f1c68583b9cf383462b43b83f3af5fd58306507689c20af7fc14c878d27776  release/kernels/stall.ccvtrace
e454bed6d2c3767fdfe66bba2e6caeebbd13969c6a26a869cc83452e0c5c3c6f  release/kernels/stall.log
500db2c482b07a0706583422cd68878301d0146c1f872ccc1f11bfdcf5c993ef  release/kernels/stall.oracle.jsonl
6a18ba82e5be5074943e10c7de6ac6645e0daaec2a076ead7530ebc5b9a41ead  release/kernels/stall.sv-hosted.log
ce5f07ca002f9ddf8deb9a913344b65c39153d8c27e2f593b871b8fb19cc4316  release/kernels/swap.by_instr.json.gz
c28f53499a86ccad35e95eb4f4bd22614588348ad7541d985d4e2b751845bf76  release/kernels/swap.by_unit.json.gz
4c1a000f481d85090a2989daee5c41bbffb9004d0a83f993333f3db41adcf340  release/kernels/swap.ccvtrace
e528e0f8232056102a3b1b51b2c76c90e2504e031438aa88de142e44f4751f03  release/kernels/swap.log
3658a26316c1ff7bc1744304a42f736e930fcde2865c8913e6cc67a22ce96667  release/kernels/swap.oracle.jsonl
ac4781836e1577b57de7a65f3035b9316186c76212ce9edcc3e62c2d624b035e  release/kernels/swap.sv-hosted.log
ec09dab8327f88c4eefff5a69ab06bdd250806a8886aa0f71edb7eb521ae3d84  release/kernels/transp4.by_instr.json.gz
0239a94707deb2c708a3c1f2cfafe24102e9ff3ed935c0f3ac564d5021c1b3e7  release/kernels/transp4.by_unit.json.gz
60e38fa2a268d4a615cbd37e3ec4497a81b0ce0194c08acfae8978a92134d99a  release/kernels/transp4.ccvtrace
f3910eebf96e68788ab352c67b4a76fca41bde653280651f7f955be5625e3b1b  release/kernels/transp4.log
06396ace3ac19677fd39c700e408606e5bdbacb24997d663bbe8872e63dd74fc  release/kernels/transp4.oracle.jsonl
f815b446a26673d6285ef61aab5fd8516cad1e9f93e28b6d974ee6ada9ff697b  release/kernels/transp4.sv-hosted.log
750ce9b07f75bc24b62942360124b406437467997b753b3c6737f77de3ad4a19  release/kernels/unal.by_instr.json.gz
4fa06155fc4d956d3757d85fa07861ec62596f6b6fde60f3b044186d177ef322  release/kernels/unal.by_unit.json.gz
6e679da0bff69301043a53b7c50d12b8a1d0326adb67b6af1d533bd179b3ea66  release/kernels/unal.ccvtrace
f0c82d70afd4d4efa467df3185f3145026e9f8f41816273da8a83a70d804b876  release/kernels/unal.log
c3d484bb160657a563df983d9a2532eac27f556636617960aa1e72183ac2b299  release/kernels/unal.oracle.jsonl
5c05f7466064ac0af7ab5eb85b9abacf2252ccd23dcc601ec48ad52266bc714a  release/kernels/unal.sv-hosted.log
b975fd387e1bcaba50b9ef822415c7557974b369578d2023d8066f2e7e15f695  release/kernels/vadd.by_instr.json.gz
c0240cd70a88720a0b0951ed8d13ed9f50574a36936ef6689a4dbeca76850ed1  release/kernels/vadd.by_unit.json.gz
f7962ce1224483b0575629ae56cdfb8fb8d7fc66abbb2bc54367ad021923cd4b  release/kernels/vadd.ccvtrace
5861cb65b34f6ad1ec8f515cbdc2fd846a70edd31cab202455efec344da72d3a  release/kernels/vadd.log
0276b6d0611a4bbcdc004ab3987214aea138245bc7217504147331689a9c0880  release/kernels/vadd.oracle.jsonl
d65001aa35e821e0b7268f5dc9140ff6625eff33f2402c7b55c422bf529ad4eb  release/kernels/vadd.sv-hosted.log
9b18452748f6bbb186dac53e3881fe8ec4e3f9c86910ec1190600eed669e2659  release/kernels/vadd4.by_instr.json.gz
763e3de241aa1642b64050cb65b9d3dca491a8fc3f41bdb76f423829c7cc9fba  release/kernels/vadd4.by_unit.json.gz
db0b4df38279c0f577786bc2aeec0a29fc004d91cc104b525b7183e73084d8d9  release/kernels/vadd4.ccvtrace
f6fe33076ec19cfef5bb23508f4ffa0cff856b92eac7d9378e63df3c752fce42  release/kernels/vadd4.log
225aa18fc9f38aa9ad615aa11de254337d59fa705877553d873062c68366e0db  release/kernels/vadd4.oracle.jsonl
b4e41e46e2e8b63e515479c55dd60e9f9004bbed620bec9eee1fe38b2f3fef5d  release/kernels/vadd4.sv-hosted.log
b9d8e2f8b94afc4f4a25fb5f4eb4627cfca4bf60fc0f0518f3feb05597bbe9ea  release/kernels/vaddslow.by_instr.json.gz
c3bd7941f9e308d69e1f46a595a7841fd06677fec33e0e40d749ba67724f69a7  release/kernels/vaddslow.by_unit.json.gz
95fe3d753a3f9fbb9cd7f7c224b21426296afaac6ee2a0525b9d9d9ddd9e4d2d  release/kernels/vaddslow.ccvtrace
57d477979f85d5253b09f53839a57e8937dc3738cdae7a842748024e4f6b23cc  release/kernels/vaddslow.log
e9e6218e8b8450e9f9ff6b39d659c994a1e51c527a0c5bd10d18b5658ae0e344  release/kernels/vaddslow.oracle.jsonl
f38591b3c5ea9cfbc72dc6d74649fa9590c64f208a87d97cfd29ca92d73fc23f  release/kernels/vaddslow.sv-hosted.log
e2da4d9fe3d94a57757b71fbcf39603f97880acdd96d6cf259d5567f8325f1b5  release/verify.log
ecec1a37173b3e9e46a989946881f9d4639255fd582c7a2cbb350aa8629c0401  release/wiring.txt
```
