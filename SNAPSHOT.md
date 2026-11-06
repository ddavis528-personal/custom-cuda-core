# Snapshot snapshot-2026-11-06-a722ef6

**A generated, read-only snapshot. Do not edit or merge it.** The source
is `ccr-9eb50716-lecnjf` at `a722ef673ff888f0ef2a28b7a7db7b2cee081eb2`, and this branch is rebuilt from source by
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
| Source | `ccr-9eb50716-lecnjf` @ `a722ef673ff888f0ef2a28b7a7db7b2cee081eb2` |
| Built | 2026-11-06 (UTC) |
| Gate | `tools/verify.sh`: PASS |
| Compiler snapshot | custom-cuda-complier `release` @ `e533ecdfabd1aa267e4cffd49a4d7e1e8c13b263` (source `45ce995c923e7267feb71d87f8f9c5edfefcf0df`) |
| Verilator | Verilator 5.052 2026-09-05 rev v5.052 |
| Icarus | Icarus Verilog version 12.0 (stable) () |
| Yosys | Yosys 0.33 (git sha1 2584903a060) |

## Kernels

| Kernel | Result |
|---|---|
| `addrhigh` | `name=addrhigh finished=1 cycles=84 from_fetch=53 retired=5 issue_groups=6 order=ok gpr_mismatch=0 pred_mismatch=0 mem_mismatch=0 check_failures=0 class_violations=0 overflows=0 credit_leaks=0 channels_used=26/55 violations=0` |
| `addrlimit` | `name=addrlimit finished=1 cycles=1071 from_fetch=1040 retired=5 issue_groups=5 order=ok gpr_mismatch=0 pred_mismatch=0 mem_mismatch=0 check_failures=0 class_violations=0 overflows=0 credit_leaks=0 channels_used=27/55 violations=0` |
| `addrneg` | `name=addrneg finished=1 cycles=84 from_fetch=53 retired=1 issue_groups=2 order=ok gpr_mismatch=0 pred_mismatch=0 mem_mismatch=0 check_failures=0 class_violations=0 overflows=0 credit_leaks=0 channels_used=23/55 violations=0` |
| `borrow` | `name=borrow finished=1 cycles=102 from_fetch=71 retired=7 issue_groups=7 order=ok gpr_mismatch=0 pred_mismatch=0 mem_mismatch=0 check_failures=0 class_violations=0 overflows=0 credit_leaks=0 channels_used=21/55 violations=0` |
| `brs` | `name=brs finished=1 cycles=101 from_fetch=70 retired=12 issue_groups=12 order=ok gpr_mismatch=0 pred_mismatch=0 mem_mismatch=0 check_failures=0 class_violations=0 overflows=0 credit_leaks=0 channels_used=23/55 violations=0` |
| `byp` | `name=byp finished=1 cycles=120 from_fetch=89 retired=14 issue_groups=14 order=ok gpr_mismatch=0 pred_mismatch=0 mem_mismatch=0 check_failures=0 class_violations=0 overflows=0 credit_leaks=0 channels_used=31/55 violations=0` |
| `callret` | `name=callret finished=1 cycles=280 from_fetch=249 retired=40 issue_groups=40 order=ok gpr_mismatch=0 pred_mismatch=0 mem_mismatch=0 check_failures=0 class_violations=0 overflows=0 credit_leaks=0 channels_used=30/55 violations=0` |
| `chains` | `name=chains finished=1 cycles=97 from_fetch=66 retired=29 issue_groups=29 order=ok gpr_mismatch=0 pred_mismatch=0 mem_mismatch=0 check_failures=0 class_violations=0 overflows=0 credit_leaks=0 channels_used=21/55 violations=0` |
| `div` | `name=div finished=1 cycles=1011 from_fetch=980 retired=144 issue_groups=144 order=ok gpr_mismatch=0 pred_mismatch=0 mem_mismatch=0 check_failures=0 class_violations=0 overflows=0 credit_leaks=0 channels_used=23/55 violations=0` |
| `divchw` | `name=divchw finished=1 cycles=114 from_fetch=83 retired=5 issue_groups=6 order=ok gpr_mismatch=0 pred_mismatch=0 mem_mismatch=0 check_failures=0 class_violations=0 overflows=0 credit_leaks=0 channels_used=22/55 violations=0` |
| `divtail` | `name=divtail finished=1 cycles=663 from_fetch=632 retired=96 issue_groups=96 order=ok gpr_mismatch=0 pred_mismatch=0 mem_mismatch=0 check_failures=0 class_violations=0 overflows=0 credit_leaks=0 channels_used=23/55 violations=0` |
| `divtail2` | `name=divtail2 finished=1 cycles=1569 from_fetch=1538 retired=366 issue_groups=366 order=ok gpr_mismatch=0 pred_mismatch=0 mem_mismatch=0 check_failures=0 class_violations=0 overflows=0 credit_leaks=0 channels_used=23/55 violations=0` |
| `fence` | `name=fence finished=1 cycles=83 from_fetch=52 retired=7 issue_groups=7 order=ok gpr_mismatch=0 pred_mismatch=0 mem_mismatch=0 check_failures=0 class_violations=0 overflows=0 credit_leaks=0 channels_used=30/55 violations=0` |
| `gather` | `name=gather finished=1 cycles=267 from_fetch=236 retired=16 issue_groups=16 order=ok gpr_mismatch=0 pred_mismatch=0 mem_mismatch=0 check_failures=0 class_violations=0 overflows=0 credit_leaks=0 channels_used=31/55 violations=0` |
| `hit` | `name=hit finished=1 cycles=234 from_fetch=203 retired=17 issue_groups=17 order=ok gpr_mismatch=0 pred_mismatch=0 mem_mismatch=0 check_failures=0 class_violations=0 overflows=0 credit_leaks=0 channels_used=31/55 violations=0` |
| `lanectx` | `name=lanectx finished=1 cycles=70 from_fetch=39 retired=10 issue_groups=10 order=ok gpr_mismatch=0 pred_mismatch=0 mem_mismatch=0 check_failures=0 class_violations=0 overflows=0 credit_leaks=0 channels_used=29/55 violations=0` |
| `lanectx2` | `name=lanectx2 finished=1 cycles=70 from_fetch=39 retired=10 issue_groups=10 order=ok gpr_mismatch=0 pred_mismatch=0 mem_mismatch=0 check_failures=0 class_violations=0 overflows=0 credit_leaks=0 channels_used=29/55 violations=0` |
| `late` | `name=late finished=1 cycles=175 from_fetch=144 retired=16 issue_groups=16 order=ok gpr_mismatch=0 pred_mismatch=0 mem_mismatch=0 check_failures=0 class_violations=0 overflows=0 credit_leaks=0 channels_used=31/55 violations=0` |
| `ldpar` | `name=ldpar finished=1 cycles=157 from_fetch=126 retired=17 issue_groups=17 order=ok gpr_mismatch=0 pred_mismatch=0 mem_mismatch=0 check_failures=0 class_violations=0 overflows=0 credit_leaks=0 channels_used=31/55 violations=0` |
| `lnorm1` | `name=lnorm1 finished=1 cycles=2631 from_fetch=2600 retired=526 issue_groups=526 order=ok gpr_mismatch=0 pred_mismatch=0 mem_mismatch=0 check_failures=0 class_violations=0 overflows=0 credit_leaks=0 channels_used=37/55 violations=0` |
| `localsp` | `name=localsp finished=1 cycles=4237 from_fetch=4206 retired=40 issue_groups=40 order=ok gpr_mismatch=0 pred_mismatch=0 mem_mismatch=0 check_failures=0 class_violations=0 overflows=0 credit_leaks=0 channels_used=32/55 violations=0` |
| `loop` | `name=loop finished=1 cycles=2942 from_fetch=2911 retired=407 issue_groups=407 order=ok gpr_mismatch=0 pred_mismatch=0 mem_mismatch=0 check_failures=0 class_violations=0 overflows=0 credit_leaks=0 channels_used=23/55 violations=0` |
| `merge` | `name=merge finished=1 cycles=73 from_fetch=42 retired=9 issue_groups=9 order=ok gpr_mismatch=0 pred_mismatch=0 mem_mismatch=0 check_failures=0 class_violations=0 overflows=0 credit_leaks=0 channels_used=21/55 violations=0` |
| `missrun` | `name=missrun finished=1 cycles=123 from_fetch=92 retired=28 issue_groups=28 order=ok gpr_mismatch=0 pred_mismatch=0 mem_mismatch=0 check_failures=0 class_violations=0 overflows=0 credit_leaks=0 channels_used=31/55 violations=0` |
| `mload` | `name=mload finished=1 cycles=113 from_fetch=82 retired=11 issue_groups=11 order=ok gpr_mismatch=0 pred_mismatch=0 mem_mismatch=0 check_failures=0 class_violations=0 overflows=0 credit_leaks=0 channels_used=31/55 violations=0` |
| `mlp` | `name=mlp finished=1 cycles=128 from_fetch=97 retired=21 issue_groups=21 order=ok gpr_mismatch=0 pred_mismatch=0 mem_mismatch=0 check_failures=0 class_violations=0 overflows=0 credit_leaks=0 channels_used=31/55 violations=0` |
| `mwmiss` | `name=mwmiss finished=1 cycles=131 from_fetch=100 retired=88 issue_groups=88 order=ok gpr_mismatch=0 pred_mismatch=0 mem_mismatch=0 check_failures=0 class_violations=0 overflows=0 credit_leaks=0 channels_used=31/55 violations=0` |
| `narrowadd` | `name=narrowadd finished=1 cycles=232 from_fetch=201 retired=21 issue_groups=21 order=ok gpr_mismatch=0 pred_mismatch=0 mem_mismatch=0 check_failures=0 class_violations=0 overflows=0 credit_leaks=0 channels_used=32/55 violations=0` |
| `pguard` | `name=pguard finished=1 cycles=89 from_fetch=58 retired=12 issue_groups=12 order=ok gpr_mismatch=0 pred_mismatch=0 mem_mismatch=0 check_failures=0 class_violations=0 overflows=0 credit_leaks=0 channels_used=29/55 violations=0` |
| `plog` | `name=plog finished=1 cycles=72 from_fetch=41 retired=10 issue_groups=10 order=ok gpr_mismatch=0 pred_mismatch=0 mem_mismatch=0 check_failures=0 class_violations=0 overflows=0 credit_leaks=0 channels_used=21/55 violations=0` |
| `pmovdiv` | `name=pmovdiv finished=1 cycles=106 from_fetch=75 retired=12 issue_groups=12 order=ok gpr_mismatch=0 pred_mismatch=0 mem_mismatch=0 check_failures=0 class_violations=0 overflows=0 credit_leaks=0 channels_used=22/55 violations=0` |
| `predlane` | `name=predlane finished=1 cycles=928 from_fetch=897 retired=10 issue_groups=10 order=ok gpr_mismatch=0 pred_mismatch=0 mem_mismatch=0 check_failures=0 class_violations=0 overflows=0 credit_leaks=0 channels_used=31/55 violations=0` |
| `predmerge` | `name=predmerge finished=1 cycles=940 from_fetch=909 retired=9 issue_groups=9 order=ok gpr_mismatch=0 pred_mismatch=0 mem_mismatch=0 check_failures=0 class_violations=0 overflows=0 credit_leaks=0 channels_used=33/55 violations=0` |
| `predspill` | `name=predspill finished=1 cycles=967 from_fetch=936 retired=12 issue_groups=12 order=ok gpr_mismatch=0 pred_mismatch=0 mem_mismatch=0 check_failures=0 class_violations=0 overflows=0 credit_leaks=0 channels_used=31/55 violations=0` |
| `predswap` | `name=predswap finished=1 cycles=1179 from_fetch=1148 retired=46 issue_groups=46 order=ok gpr_mismatch=0 pred_mismatch=0 mem_mismatch=0 check_failures=0 class_violations=0 overflows=0 credit_leaks=0 channels_used=33/55 violations=0` |
| `privwin` | `name=privwin finished=1 cycles=2217 from_fetch=2186 retired=52 issue_groups=52 order=ok gpr_mismatch=0 pred_mismatch=0 mem_mismatch=0 check_failures=0 class_violations=0 overflows=0 credit_leaks=0 channels_used=34/55 violations=0` |
| `provswap` | `name=provswap finished=1 cycles=2386 from_fetch=2355 retired=978 issue_groups=978 order=ok gpr_mismatch=0 pred_mismatch=0 mem_mismatch=0 check_failures=0 class_violations=0 overflows=0 credit_leaks=0 channels_used=33/55 violations=0` |
| `roconst` | `name=roconst finished=1 cycles=77 from_fetch=46 retired=4 issue_groups=5 order=ok gpr_mismatch=0 pred_mismatch=0 mem_mismatch=0 check_failures=0 class_violations=0 overflows=0 credit_leaks=0 channels_used=26/55 violations=0` |
| `rogated` | `name=rogated finished=1 cycles=97 from_fetch=66 retired=7 issue_groups=8 order=ok gpr_mismatch=0 pred_mismatch=0 mem_mismatch=0 check_failures=0 class_violations=0 overflows=0 credit_leaks=0 channels_used=26/55 violations=0` |
| `rokill` | `name=rokill finished=1 cycles=106 from_fetch=75 retired=41 issue_groups=4536 order=ok gpr_mismatch=0 pred_mismatch=0 mem_mismatch=0 check_failures=0 class_violations=0 overflows=0 credit_leaks=0 channels_used=27/55 violations=0` |
| `rolaunch` | `name=rolaunch finished=1 cycles=74 from_fetch=43 retired=4 issue_groups=5 order=ok gpr_mismatch=0 pred_mismatch=0 mem_mismatch=0 check_failures=0 class_violations=0 overflows=0 credit_leaks=0 channels_used=24/55 violations=0` |
| `rolimit` | `name=rolimit finished=1 cycles=77 from_fetch=46 retired=4 issue_groups=5 order=ok gpr_mismatch=0 pred_mismatch=0 mem_mismatch=0 check_failures=0 class_violations=0 overflows=0 credit_leaks=0 channels_used=26/55 violations=0` |
| `roload` | `name=roload finished=1 cycles=107 from_fetch=76 retired=8 issue_groups=8 order=ok gpr_mismatch=0 pred_mismatch=0 mem_mismatch=0 check_failures=0 class_violations=0 overflows=0 credit_leaks=0 channels_used=31/55 violations=0` |
| `rope` | `name=rope finished=1 cycles=7762 from_fetch=7731 retired=354 issue_groups=354 order=ok gpr_mismatch=0 pred_mismatch=0 mem_mismatch=0 check_failures=0 class_violations=0 overflows=0 credit_leaks=0 channels_used=34/55 violations=0` |
| `ropediv` | `name=ropediv finished=1 cycles=1151 from_fetch=1120 retired=203 issue_groups=203 order=ok gpr_mismatch=0 pred_mismatch=0 mem_mismatch=0 check_failures=0 class_violations=0 overflows=0 credit_leaks=0 channels_used=34/55 violations=0` |
| `sel` | `name=sel finished=1 cycles=78 from_fetch=47 retired=8 issue_groups=8 order=ok gpr_mismatch=0 pred_mismatch=0 mem_mismatch=0 check_failures=0 class_violations=0 overflows=0 credit_leaks=0 channels_used=29/55 violations=0` |
| `sized` | `name=sized finished=1 cycles=2641 from_fetch=2610 retired=25 issue_groups=25 order=ok gpr_mismatch=0 pred_mismatch=0 mem_mismatch=0 check_failures=0 class_violations=0 overflows=0 credit_leaks=0 channels_used=32/55 violations=0` |
| `slotform` | `name=slotform finished=1 cycles=4368 from_fetch=4337 retired=12 issue_groups=12 order=ok gpr_mismatch=0 pred_mismatch=0 mem_mismatch=0 check_failures=0 class_violations=0 overflows=0 credit_leaks=0 channels_used=32/55 violations=0` |
| `spinwait` | `name=spinwait finished=1 cycles=2276 from_fetch=2245 retired=211 issue_groups=211 order=ok gpr_mismatch=0 pred_mismatch=0 mem_mismatch=0 check_failures=0 class_violations=0 overflows=0 credit_leaks=0 channels_used=34/55 violations=0` |
| `spmbank` | `name=spmbank finished=1 cycles=186 from_fetch=155 retired=13 issue_groups=13 order=ok gpr_mismatch=0 pred_mismatch=0 mem_mismatch=0 check_failures=0 class_violations=0 overflows=0 credit_leaks=0 channels_used=28/55 violations=0` |
| `srd` | `name=srd finished=1 cycles=70 from_fetch=39 retired=6 issue_groups=6 order=ok gpr_mismatch=0 pred_mismatch=0 mem_mismatch=0 check_failures=0 class_violations=0 overflows=0 credit_leaks=0 channels_used=29/55 violations=0` |
| `stall` | `name=stall finished=1 cycles=558 from_fetch=527 retired=116 issue_groups=116 order=ok gpr_mismatch=0 pred_mismatch=0 mem_mismatch=0 check_failures=0 class_violations=0 overflows=0 credit_leaks=0 channels_used=31/55 violations=0` |
| `swap` | `name=swap finished=1 cycles=558 from_fetch=527 retired=174 issue_groups=174 order=ok gpr_mismatch=0 pred_mismatch=0 mem_mismatch=0 check_failures=0 class_violations=0 overflows=0 credit_leaks=0 channels_used=31/55 violations=0` |
| `transp4` | `name=transp4 finished=1 cycles=1183 from_fetch=1152 retired=976 issue_groups=976 order=ok gpr_mismatch=0 pred_mismatch=0 mem_mismatch=0 check_failures=0 class_violations=0 overflows=0 credit_leaks=0 channels_used=37/55 violations=0` |
| `unal` | `name=unal finished=1 cycles=138 from_fetch=107 retired=9 issue_groups=9 order=ok gpr_mismatch=0 pred_mismatch=0 mem_mismatch=0 check_failures=0 class_violations=0 overflows=0 credit_leaks=0 channels_used=31/55 violations=0` |
| `vadd` | `name=vadd finished=1 cycles=159 from_fetch=128 retired=17 issue_groups=17 order=ok gpr_mismatch=0 pred_mismatch=0 mem_mismatch=0 check_failures=0 class_violations=0 overflows=0 credit_leaks=0 channels_used=33/55 violations=0` |
| `vadd4` | `name=vadd4 finished=1 cycles=204 from_fetch=173 retired=68 issue_groups=68 order=ok gpr_mismatch=0 pred_mismatch=0 mem_mismatch=0 check_failures=0 class_violations=0 overflows=0 credit_leaks=0 channels_used=33/55 violations=0` |
| `vaddslow` | `name=vaddslow finished=1 cycles=548 from_fetch=517 retired=17 issue_groups=17 order=ok gpr_mismatch=0 pred_mismatch=0 mem_mismatch=0 check_failures=0 class_violations=0 overflows=0 credit_leaks=0 channels_used=33/55 violations=0` |

## Manifest of release/

```
674f0c626ec528deee6039eda62b290d60ed5af002e5bb37c2a8f679ac6e5a33  release/kernels/addrhigh.by_instr.json.gz
0743bde72b4ca626679b1e5ee6cc500ba9741e391aa965c7aea375c2aff22fbb  release/kernels/addrhigh.by_unit.json.gz
7196d869d494a2426270ad07c984b52a11c1fcf9153cd9098e981d0a8db50f70  release/kernels/addrhigh.ccvtrace
91208dbf4b0f1fb1ea685128b42ae766299622bd22354c78b92b0cd9615e1a82  release/kernels/addrhigh.log
569f2e22883fad5f0956c57ec734e6afbdd4b8a854e50277425172d6c0cbd766  release/kernels/addrhigh.oracle.jsonl
3b7ce1405ab66295bc73065817528384bea0bfcbd772107c1dc1c19b11413243  release/kernels/addrhigh.sv-hosted.log
324c5ee0b5d69196019059717eb183c62f2e6556381aee1d2e9ec8fc15c94e25  release/kernels/addrlimit.by_instr.json
37138197deaadc65235fafcbd14dbf2667e1fcb6d1aa10864cdf975bdf46bc5d  release/kernels/addrlimit.by_unit.json
d5dbe16b24fadb69a590b2fef7ec9b31a5f87c5f68044dff13ffc3207480069a  release/kernels/addrlimit.ccvtrace
06a21b0e3c33fb90f58a4ab19a8e78308e1dca6ecb1857fec6841faa8873b827  release/kernels/addrlimit.log
bc660b0b40359a2c5a2478cb0eb4950b73fd22db50ea76b80052bc195a1920f4  release/kernels/addrlimit.oracle.jsonl
9b97f3001306ba501606fbf136e28849e96a464a22e0f6d936c6e169fc34497e  release/kernels/addrlimit.sv-hosted.log
3c8c45fccab83e8165b16ec8415fdcf1455246873842ba41f33010eb13f1bd69  release/kernels/addrneg.by_instr.json
ea11b4a0c7183697584aae14d450b7abcea1f2c8a43575d2f25fd447e9fc7465  release/kernels/addrneg.by_unit.json
e5b5a9c39e3a200652eb5b87636140f29ae5e864472614cb4d8e5ea3b9d36ce9  release/kernels/addrneg.ccvtrace
c81f29db1ce0d219156f2d2f8f939cf7043c14126feebdf169f1e3e4d4a65333  release/kernels/addrneg.log
16f5b0707ae44492a1efd67bb9dd38a7e79a7bbd354fa9207b9e7d150ff2f107  release/kernels/addrneg.oracle.jsonl
be8d912d7b5411c857f048278c4fefba9f24cd560742b8d524e38430752ed717  release/kernels/addrneg.sv-hosted.log
609a69283dc50242a3896b2575256b1f673c7db70cef76e9f9566853463d5d37  release/kernels/borrow.by_instr.json.gz
e34dd4a99d866f0504b1e21a7b08053882cf52f1dfe3486f6f4be88873053c18  release/kernels/borrow.by_unit.json.gz
cda39dcc0e2c6e00aadf5819be5ef4750820ad6f1e2e31c6b71463bf3c77b966  release/kernels/borrow.ccvtrace
e8d328fa2e7a7cd5b1bf21cbcd30d15b8cbffce1eeec2b97c63078066a7f16b0  release/kernels/borrow.log
4c565e1ce0b3baee36e158694b32c8defb5cd662b2f9af75cb5d8c26cb1168ed  release/kernels/borrow.oracle.jsonl
8dc4e9ac6bf44c69ea8bbd670329a0d162dabc75928d0c78968fbafab91ad3f1  release/kernels/borrow.sv-hosted.log
b914102e172b1aa2b584572d8faa6c23428e45e7f46d37b646dc7f44c7c8e250  release/kernels/brs.by_instr.json.gz
ce4e495a3bdb6423a3757420a516220e02ae21d4babc99e3690bbbf96125c1b5  release/kernels/brs.by_unit.json.gz
6f698af8376910bd120c56976427063646da36e221324b15fc468b721469b98b  release/kernels/brs.ccvtrace
76dbbc953e19196e71c0714a9a1a8f6e507f1bcbc8fb5d72aba31d2d3ec9bd96  release/kernels/brs.log
e3c1cb3379580cf1aae44e8ddc8e846ef6fd661a573cfe0a8d4444b18a14dc56  release/kernels/brs.oracle.jsonl
af81d026994999663f62f8face7d2057086106c40d58afd706da388a9425b205  release/kernels/brs.sv-hosted.log
656c999dfe0e87c05c7062205b05b2a4e24d3249210d2e428bd98ce84b4c9c77  release/kernels/byp.by_instr.json.gz
5da7b59189a2d3d1107018edca5296e2ba3f9f4cbfcd3755aef624422de846c6  release/kernels/byp.by_unit.json.gz
c5fb00d49e385113c0018e484de8284e072496ac54fbe20542a910c142c84343  release/kernels/byp.ccvtrace
a8800ada062b131dd5c9a0b8d67de398c01bb815d9aee177be43937babf23f68  release/kernels/byp.log
5a03dfa4f3603fef49f1e3639e74e34152ca3ca5ef8e41eb959f8323040fa2d5  release/kernels/byp.oracle.jsonl
bab2efde30e2729da64b5b245f1d4d0c82dfb924ca0c7da5757769c8535c4699  release/kernels/byp.sv-hosted.log
5584dc26d3acae7fee9d375527dde7156d9ad4e82fd24d478fbb724b175fb280  release/kernels/callret.by_instr.json.gz
a9b167b423d8044fa5771295fb26ae95f6caeaefc3036a668a18e774bfe9758e  release/kernels/callret.by_unit.json.gz
98679db94a565dfd66c0316afce2d4d693a8c6f6cba8108c53510f772efb80a4  release/kernels/callret.ccvtrace
0c80e6ee86fdcffd4087370b45f3b793405bd0f8729f829c8455519e3f1cfad6  release/kernels/callret.log
9b1d1b50b527f732362f837250aa2f26dabf3e76e16a4794856ebd8f105635b8  release/kernels/callret.oracle.jsonl
1a20bc2435334db5f7c9c89e551208f002fee938bea8d8a9b81fba1d805caa2f  release/kernels/callret.sv-hosted.log
1f887d85c9e9fd418556a571aca3b8589ff95712a134eef346488f05bfea6813  release/kernels/chains.by_instr.json.gz
27327c146f51b029530a10c2a4f3321bd8a57c3c9d38f1bbdfd4b5bba2693788  release/kernels/chains.by_unit.json.gz
9c68ae58880d96ffa82cf35d6127cff29f08f2505fa1d508dc74cde1993452a0  release/kernels/chains.ccvtrace
af2dd0060c95f64a1f99286bc6a9ed1bf273e493c9396eb7b4393ae519ddee3f  release/kernels/chains.log
26a4cc5c5524c7219d8706c2582c80357dea60be9d6ffdec99dac7d0365e2264  release/kernels/chains.oracle.jsonl
3655af476c048d3ffc4042de3df63070a5b23a57cc43e946d0e579aa812137c4  release/kernels/chains.sv-hosted.log
f1aff30f4fe13189b66144f81c653fa5e15336feafb0de2089f85556bce1ab53  release/kernels/div.by_instr.json.gz
c8282d21b4ae4a1503442f46e6810eae8db6794a9186052afc7f74aa32f31c20  release/kernels/div.by_unit.json.gz
8608a0dd1b7f9ec94d62196f03d73630dc360aaebd0fd29ac6ece768e74d5f96  release/kernels/div.ccvtrace
035a6000619f643640b2ae7d304b99915a39ee35c0d08a3b5aa68fd273675dca  release/kernels/div.log
71a567b85cf85622631490187563de9a5661099c78a590adff4ed0a0c3d24c16  release/kernels/div.oracle.jsonl
90a2a6a2c6f19055f1248fcbf4ea31471217fcaa5f66f91157aaa6211b046ccc  release/kernels/div.sv-hosted.log
56c823cc4665de1fd1aeeb496d73bbc9f960bb741fc0869a06e1080575accf19  release/kernels/divchw.by_instr.json.gz
ad71467e3a81ebe5dab4c51822bc303a256cfca956babe56ab6bd15930317e14  release/kernels/divchw.by_unit.json.gz
53ac8978fd7a89ea761c83df36541d8ec5ca474f1251d7fdaa5227bec49854d6  release/kernels/divchw.ccvtrace
fd50bc0e032c88a43e3145d4b0766d8365c487699ab68c090d5551776c015c23  release/kernels/divchw.log
58a541797f7a2df0a1c7528ae6a3edec212db90c7d3eb20656806f38b5c10b3d  release/kernels/divchw.oracle.jsonl
1c450f0aa899394f6f4c277b01786d36d799ffc75e5710fecb9e4aa4760f4b5c  release/kernels/divchw.sv-hosted.log
5e84c70219fdd2cdc93e14420c176111581ea0878a532086454c72c22545aad4  release/kernels/divtail.by_instr.json.gz
21cd90f7cbca8817462085b6e92c354a3ec6a09b19b23c0665bb3d516e89285c  release/kernels/divtail.by_unit.json.gz
d59e8b4e9fff223566806997057fe829f6a822cd4314794cd5256e70d9bc40dc  release/kernels/divtail.ccvtrace
922ab9b60b464b4f73ad6233d0e0eaac12f852620913a45594b988f86c62465b  release/kernels/divtail.log
75f11a75c9b3b336e446140af4579f05b46c363a76b7aab3ec88154a07ba097d  release/kernels/divtail.oracle.jsonl
73152b59b4f35656b4323a3afa5a088948735ce526a74cec4c82e2ef2786ad9d  release/kernels/divtail.sv-hosted.log
87bd3c87bd25da7a3fbdfcf9405e32230f8fa6e9f75e916bedaa64b1a19f6cb4  release/kernels/divtail2.by_instr.json.gz
420f5bfe6fe816e203b614cbb64701b4fbf4cd04589e0d916ccdb87deec94beb  release/kernels/divtail2.by_unit.json.gz
e4944d1ef25f4beed26a38f8c04bd7d5108dec433cef20406f61f8f58fe6597a  release/kernels/divtail2.ccvtrace
39c581d6e19d16d34e5aaa424d951477d77df5d5c694fa73545cc422c9a16d5a  release/kernels/divtail2.log
b2db6b05eb6cf4a0a7677e31d0c6c2952d5cab49d353f0bb1883fe0b2a20ed14  release/kernels/divtail2.oracle.jsonl
976dc09913fde21ef3ed6a3c1f7700564aa34f643f1637c4dd94a9d99ff8f703  release/kernels/divtail2.sv-hosted.log
28acc66d26fe050b68d5e65b1af5f653c4eff8e817547b007b3e2fc12a9c1d59  release/kernels/fence.by_instr.json
32a384369a08f92af6675c454e2df6173f893c290b21dbe94df4164b9a95229f  release/kernels/fence.by_unit.json.gz
5bf0547438767cf7d25c330ef42015a2e4acfb45ab96f0a8c2586c8bfe0fefc9  release/kernels/fence.ccvtrace
c0c62e7557e7ac514ea9ba8d60d1031317e7d20c158b13a2bb7d1ee448189273  release/kernels/fence.log
d1d40317f6cf5bfb430cda1f9c0ef676609e59cabe2a11623c42ffbeca93142b  release/kernels/fence.oracle.jsonl
e5e62a985d1df550b76d21a88e50c4176b1c884376ecc426655788057712208e  release/kernels/fence.sv-hosted.log
4ca3643e0648b1ec74f366ea79feee5e0266b1337b3a3aa91a705c4e74f81dbe  release/kernels/gather.by_instr.json.gz
c654c5c627d816d0c5670f0e6c9bc3ab3fa227ba0dc8da434dd8a41737199084  release/kernels/gather.by_unit.json.gz
d5a55922b72e4e95226d534c13b8ca6960c4981aa8923faaa4656c4b7f4f38b9  release/kernels/gather.ccvtrace
a702170b741d70d457b05773e332c34353aae72da72c9bc4ba3d0992ccfd5808  release/kernels/gather.log
0413e781d8d6ff578c64eb1f800b7931e66f676d5cdabb97b94a4033e6037662  release/kernels/gather.oracle.jsonl
e18f010157f18595c1a8a07d6e114ffa7e1650ba3e3413795b94b17cc119b2d1  release/kernels/gather.sv-hosted.log
ab481ffcd54c1fa54e7994e4d1d9fbca1073e3cbb95298df9028a1e4d55f3e4a  release/kernels/hit.by_instr.json.gz
37772ec0be81c4d5fcd18405a33b4b12bb7fd80f4b2810e41597c7af5286912f  release/kernels/hit.by_unit.json.gz
c292923137bee684323dcfeceeb092fa03f6c7c0b67ccac892a593455db31c24  release/kernels/hit.ccvtrace
aa53cdce0cc0905bf18affce4b8dd63e3ce9e897386b95c014fcc4bab087b16e  release/kernels/hit.log
7ba9603e0088d9164de6528f16ef6a7fa9ce5821c8c12b52cbb3734e39b9fd52  release/kernels/hit.oracle.jsonl
8d0b2e5c3c2bbf4a90cb37acf0309b3f244468c23d7dca196af6dfa43cb82f4f  release/kernels/hit.sv-hosted.log
2b17fb622bbb5aafa777a4ee336ad6c6a032a4966ee102e03f9b3d3ddb644078  release/kernels/lanectx.by_instr.json.gz
ae6b9647fa0c81f7e0618b21b46cd17e42af74836d4f286e69ce23f0a72c8772  release/kernels/lanectx.by_unit.json.gz
94451bb43886ee60d994faf24fa4251161244b5c5d5a69c10f21ae7cb5574c69  release/kernels/lanectx.ccvtrace
f00c4f36bea87a518ac3d4ca03cf22e7f8afa411fbc40150639d9f02ce4f4987  release/kernels/lanectx.log
888551babf540db8e3025b82e65ca655013f93eba3c8a65689d069d52a7e6039  release/kernels/lanectx.oracle.jsonl
50f68e2761c8e01de84587d950aac6cdc101c9d7864b9d518042d41d323fd0e1  release/kernels/lanectx.sv-hosted.log
98d417718f3d395456fb5fcd3e5924bebfe97281c0170b0e42c821cc5494df68  release/kernels/lanectx2.by_instr.json.gz
a9b4ef1679daec6b175aa7f240ac80a083197f9fd3f0de53db1cce5e2f6c0c68  release/kernels/lanectx2.by_unit.json.gz
2df9f3060e5e40d0949ba909174b84aebf6dd8abc5847d2cb484d9718deead03  release/kernels/lanectx2.ccvtrace
3a76c0e00b165564e66a357e6399c92cacfabb8b7334b3008a0a17859a4e4896  release/kernels/lanectx2.log
45c13056dff5c73ed0c9ece56cc36f929bf335322193c7d5eb38710b1d1dfb02  release/kernels/lanectx2.oracle.jsonl
d07bfb77421907c97917e9a9131be7039807ff19e62a7ad9f455f6037782c1d7  release/kernels/lanectx2.sv-hosted.log
c882e6548e27fbb2ca276adc4f1b1e2b83c4d8328738bf59a28a70f982de26d8  release/kernels/late.by_instr.json.gz
41fd6bf5d11dbb1d9e18c5c1a09f89e4d0eb0295110030bc75d9a740ebd73db4  release/kernels/late.by_unit.json.gz
f084d9aab0033d2e91a1762d5356ad1983ac53de003ee4333f4a3871230fdc87  release/kernels/late.ccvtrace
5d7b628e42a238d93276e518b842baa545f72913fec5b4531f53adb2e783e96b  release/kernels/late.log
86084f6bd747a2cf32acbc0ebd96ebd3e4ef2d8d9e21be49e3ae49290d7927f3  release/kernels/late.oracle.jsonl
faeb12f08671104c7b8268d210220ba226a938d2298be2546fd34c3f138be803  release/kernels/late.sv-hosted.log
4353b6b7904512f13253dc0d7d5ad101a4e8e37ea71261500a148f71f8fb205d  release/kernels/ldpar.by_instr.json.gz
7437a91d525bc7d46c48d45ba0c0917a9ac35d86e07437ec1402466d9f05dbdc  release/kernels/ldpar.by_unit.json.gz
4540c1ce99840917994db05a989868e1c0d90c2724710ac207adaf6e8a36d8ba  release/kernels/ldpar.ccvtrace
fd72966795a08c323731bab52368755ff6507f07fe7c4b95afacc29bf32bed96  release/kernels/ldpar.log
8ac08538e9c807637babd61b31e340f7461878ada31f0c0b83cd66331cfaf486  release/kernels/ldpar.oracle.jsonl
4b9491939dcbffee187187cecb58be03e4efee5bcd7de29008ea3c5eeec9b9cd  release/kernels/ldpar.sv-hosted.log
86b2439a15b30bd23b428bb9e9a249608f0b3ffdd45bbd4d33a1258c25b839d8  release/kernels/lnorm1.by_instr.json.gz
da2f253fafb6172cd7e32cc4bbf052d4481e2e4e29e059fc7019562c34982bcb  release/kernels/lnorm1.by_unit.json.gz
a6b9da7304b5aedead59bfa9b5cf4faa0e6e633013697e49e84e0fa8042ae98a  release/kernels/lnorm1.ccvtrace
04fed839b8ef4296dc5c8469734c1f9f14af8f55d911c7123805839d4a2b2ed5  release/kernels/lnorm1.log
a8d85811af988a1b9fc00db1517300af3d93ec8e589e403d3b9113fa9e0ffc86  release/kernels/lnorm1.oracle.jsonl
0b7511af095dd5880e28df91956de56949b7b1629e9b42fd2944fe6c53eb9486  release/kernels/lnorm1.sv-hosted.log
dbc7f6a753f1b9939550003c7cb5cd920e2abbf329e750a3af8cc57aa9af1840  release/kernels/localsp.by_instr.json.gz
ce94fba786ea1aabba1eb4abae9d9e0af848e2a01532b4525f2cd431871ac0e8  release/kernels/localsp.by_unit.json.gz
154924beab7721c8f391a4cc17b906b48a792600c870e6376d649cb0d429847e  release/kernels/localsp.ccvtrace
4b4fd16a2c2be947ad05bbca347b2e83fa52c10e6539240af1ef3cd0a537e280  release/kernels/localsp.log
55e3c9f36e7f7d38c0ddd38903aff4bb4509ae862015c592e6b937ea258042ca  release/kernels/localsp.oracle.jsonl
66290e8e133ba5843717594a6e6dd6633b066fea66af58c173dc9188b8ca36a3  release/kernels/localsp.sv-hosted.log
113524fb395050ac1bd5796d463a5ea73d28b356b7258766f219f254ce7af3b9  release/kernels/loop.by_instr.json.gz
d398db3a8717a31c42dcb692047e7fbb51ffa3550d88bc0d733f663dbeb86743  release/kernels/loop.by_unit.json.gz
31266d0d827f96da561423dbec57d5d25ad859512e6aa307f1f9cbe6a075fab4  release/kernels/loop.ccvtrace
6d3e101d401a8d86b59c9ce8d59e74989ced056aca24241f5e85b0d677c71f1b  release/kernels/loop.log
03ce5920c06c93e93516d8e53c3f7169f14e3593de204eacceffc0b8a3e32016  release/kernels/loop.oracle.jsonl
58e74b7d1b6e4ff90dd54c3dbb77d89ed75af24fe9b270c37c3714bc3f82e2cc  release/kernels/loop.sv-hosted.log
c69fc8cb5c57bc8bd57244f95a51434b2e42f6f6cb8cd338c4923ce41d96da9e  release/kernels/merge.by_instr.json.gz
60d73045b76227d76eb9be622cc375dda6482e141daa3c1d78cdd606c928804f  release/kernels/merge.by_unit.json.gz
79ba8f499eae69ac611e5429b80b8dea1581045e0d17277e39dac8f7c66d6c81  release/kernels/merge.ccvtrace
751a3f2a2868b4764f7aab6114363ee4f6f284fa7a9f7baea0cc597bfc46606d  release/kernels/merge.log
f96d28815f8756b1f5a45ded53e6170883d2dfa10f9eef0d14b8050b1318164a  release/kernels/merge.oracle.jsonl
51680ddf2895d1a8a0580adb46cebc1ea8ecca2948a38f555bb104210067b3ad  release/kernels/merge.sv-hosted.log
2ec8281725bdf991489022d818b54e766e98fef629fa6790fb939c9b4a7157e3  release/kernels/missrun.by_instr.json.gz
41793d0b63e215d572c1f093a0f93b36792d706b80c157077c033b40bb418a93  release/kernels/missrun.by_unit.json.gz
1514b965351e44ffd0444c39878a68a6b80b0018034e97d7b09bffe28a445bc5  release/kernels/missrun.ccvtrace
5967832e3809a48a10ec9ac29334d8ab73f6293ef3bd8fd5374412322c72a455  release/kernels/missrun.log
531bdaf281e5590774bd2775427f25e4cc0419cf8e3d5b6999843ffe9ef87258  release/kernels/missrun.oracle.jsonl
08f985d1d45c88ed58980c4ed2c0e8d2b44290ab6684aa42b31d27fc49d423ed  release/kernels/missrun.sv-hosted.log
5771fbdcc25a1b75834556fbc7efc7e11141fd34826e29da1b85d7179e79f7fb  release/kernels/mload.by_instr.json.gz
12a3748eb94a88bc058e784b33d6364c4082909d9b6c03638952a957b2cff7e1  release/kernels/mload.by_unit.json.gz
b8d576d8cc33dc5652d5d7571a395a4318fa9ce8d4fecc2cb49003b3bff43cea  release/kernels/mload.ccvtrace
248cc4f91c1040cf9fdb856109538247067583cdd6314c46b254c6ea55349747  release/kernels/mload.log
8000e477b9a95dfb9f0af964e8346acb9d36f1358fd06ffc4ff7cf599d2b8868  release/kernels/mload.oracle.jsonl
50ede3c27c16bd2c768112712c5a89a3bd203b9375675c31fbe8139225cae9e4  release/kernels/mload.sv-hosted.log
7e5737753126f24678f53be3653b6c54839ae4449e0b030401195aa2ec98108c  release/kernels/mlp.by_instr.json.gz
12725ae7ed9f65f2991c84d142eff197210fd3560988b0f7a3fd7722fbf55d4b  release/kernels/mlp.by_unit.json.gz
8196c90fdb07dd19888dee93670a82676be82e7c2d34a1e6350e4c44f8547d7d  release/kernels/mlp.ccvtrace
38420e603511c20cdbcba11b9bd2c569ade43155e57d535dfa4f4efd60d04126  release/kernels/mlp.log
138d282f88d56c8ad648a91af0a983254b55d9fa22942c00d47b327f516a6e44  release/kernels/mlp.oracle.jsonl
036fa6d91727eb5c0f6f1894551cd5e3edd222f677b22d72f161d6c57a3f9722  release/kernels/mlp.sv-hosted.log
a0e38a898588bf0b7923eec25b51ea7930280767b83b716cd20d095417bf99d1  release/kernels/mwmiss.by_instr.json.gz
5382a3248fa721922922593c2e478e9cf8a7462c48ca9420541ec13e79e6b364  release/kernels/mwmiss.by_unit.json.gz
4418d8468dea3b1c5efe284086f5c72e6476f516e10787fc12cb5e621f8d39ff  release/kernels/mwmiss.ccvtrace
b30492bd0ddbfe0e356c9ee6cf8d62c2e42c50726532109a2b2b2c62cd5f6a49  release/kernels/mwmiss.log
8abe8e8997456a2a6711ee72da54d854b24e20abbdab28e4b7271c0d28418de8  release/kernels/mwmiss.oracle.jsonl
d1eec93cddfee617cd48c82d731d2481c9f74e6bed331f03d6555e058983a4f0  release/kernels/mwmiss.sv-hosted.log
52007fe076abc2182ea6ef3abf7d859d483f3b88f5a9b16e578acb419f0e47e5  release/kernels/narrowadd.by_instr.json.gz
547151ef7672d2ade4988eb0bd8d1e4c7e81af2452d8af5cb8d0549c88366086  release/kernels/narrowadd.by_unit.json.gz
3c6f1dd4078904e6cbde0bee236610741fda1f7b1dbcf4f926e8921fe4d3502a  release/kernels/narrowadd.ccvtrace
763dc636d7921dff7104b3ee7db23cd87d9493064c64f2c4b2310b835d8107d6  release/kernels/narrowadd.log
40a2cf629853dd404bb06b4a07e35abde3d12efc13f26ffe28f923daf2994574  release/kernels/narrowadd.oracle.jsonl
5f9c7da052a687b0effbab031eae2a7e54299da4526496cf5a1db9163e5be560  release/kernels/narrowadd.sv-hosted.log
48e40f1256f8b8e905d625117a02ab029a221356d01bed1b5c276b56869458d9  release/kernels/pguard.by_instr.json.gz
7b8910bfe4d2d3b2b25f9b2b08fd177f9f1d89ffc698468973c7f8db4730a795  release/kernels/pguard.by_unit.json.gz
0a32216a57d80258b643e6672f94908ff5eb67e7cc4e73949899c6364640120d  release/kernels/pguard.ccvtrace
0b0a5c2677e54829b00e9b576a4bea3ed1e0f0fc5929e4a250dcf5e1b9bd3458  release/kernels/pguard.log
690e56f1cb8d97cbf67124b7dff3ad0a90cb8981814cd1709cf0cd0e035b3bd9  release/kernels/pguard.oracle.jsonl
3543408f67dcf2d02644ea1bcc66303c40f2c8af56a49c39721d56afc2db1038  release/kernels/pguard.sv-hosted.log
2a8f57e2f027ae0298429d095215a0bf6d14f979007cd5041de2acfbabdd6644  release/kernels/plog.by_instr.json.gz
9a26c935c70c08c8ec4219bcbde75042e5ec329b60d4228bc886ae9e13b2a59e  release/kernels/plog.by_unit.json.gz
c12c5c3d3b719a1cd5b7787383a999711c3649b9b177d133a669693cdf2bc8c7  release/kernels/plog.ccvtrace
d6d35c51fcd98ebf05ce3c48c25a8339f0f3e13ec4efa480e5b53062e5c21407  release/kernels/plog.log
c230f13f2e1082b306a9c5ab7809ff36cf5c1b2e47dca6b7a71f741524d403f5  release/kernels/plog.oracle.jsonl
9a113b83a652c9a3296790f99d901a8a3f6d55f1e8722742a5b17df5dc5a0581  release/kernels/plog.sv-hosted.log
d477666be9f0122b0d3d7a894a3c662032015e3a233b21611489612370a81bf2  release/kernels/pmovdiv.by_instr.json.gz
c4c0364cf8a50a046b2343bc7d1b88198f7c00fbc0ba66b218c99cede1129f45  release/kernels/pmovdiv.by_unit.json.gz
cdf7c6d9a9ba1d3c6fe413110f34340497591bb196b8c5408a3d3ce15efb584a  release/kernels/pmovdiv.ccvtrace
6babd2f66ce42d3916653f78440ee1787762fc9ca8298f87593c3a1224e742aa  release/kernels/pmovdiv.log
7bc646cff6166a51bdce03d7c1b7209e871f0a91d743083a9b910a80bcd0b33f  release/kernels/pmovdiv.oracle.jsonl
85c276bf854f46c1cf3ca40b235ce64f67abfdeb682b8f09dee42c93a685233f  release/kernels/pmovdiv.sv-hosted.log
d22a66ab8c392a2278bfbdb47406ef2c22172374b6cc91373a009ac3ddef0f03  release/kernels/predlane.by_instr.json.gz
a92d13c3e3f52d4266321417549d8388038c235ace344b1338e34e0e7dd87eff  release/kernels/predlane.by_unit.json.gz
f80ea0e51a241607711c2a0cb3dce51b825c65cf9f07abad84c790bd8b07e59d  release/kernels/predlane.ccvtrace
d81e397e5fbdb3796944918235bb27b8c5ebdca61d90eb21054310695efb22bc  release/kernels/predlane.log
c45f4177b9e84fc8a6e36b13534a0c7636eb30a3f8531847100ce5e23bf404b1  release/kernels/predlane.oracle.jsonl
8420f11f3c360314aa1b0039c0fd663f449812af1d1e1a667921537a9d40250c  release/kernels/predlane.sv-hosted.log
9ee1636c79a482c926b4f213fda528ae4a0c08d61ae2e8920c46f4afb341e758  release/kernels/predmerge.by_instr.json.gz
780128ac3f36746875802c4c0a3556d266e89b59e7b80387ab2cce324d4da75f  release/kernels/predmerge.by_unit.json.gz
6f2a687ec8d0d9543d0022d3dd0f2eb54fa39059db0bae09d06899b80f77605e  release/kernels/predmerge.ccvtrace
8a3a470759ae3461c7be07866d4b9edb0e2a476aab10a7ca84f0d67be85adccd  release/kernels/predmerge.log
6c737c49434bcd08e3e0814c8b1dbf15c586ae74f7929ba3148ddcee2c62c845  release/kernels/predmerge.oracle.jsonl
0973891090b2746a8d9e76f44e8a4b8252c970d1d656e6bcd7b69ba246a14ce6  release/kernels/predmerge.sv-hosted.log
9dec5500dbbe5cf93f493162d87928c296d083725cb6d135e38c0b5abf79b7ea  release/kernels/predspill.by_instr.json.gz
6d702d33fac1b7e12f9669c541ae30bab6c7219906c20a62e352ec31451bdb3f  release/kernels/predspill.by_unit.json.gz
a4f8854c2556f3b63342170c41e0b8af6d44511c41a531c6435aa79d81115a40  release/kernels/predspill.ccvtrace
dd25f67248a4af09ec74f350f82152d3d3e4c12c1501d2b950e10e705fff2e5b  release/kernels/predspill.log
b7c84c6478117ffa0f06da0e6ad1e4628e2683426a7911080810e78e06a5242e  release/kernels/predspill.oracle.jsonl
2afbf80658dd08683d643b349de416d0650b2e73a5764015bffb5b9bbcf367f8  release/kernels/predspill.sv-hosted.log
1408eae40100c6c456ca5bedbdcb2ed39085e0cfe0e23f501735d775baedd151  release/kernels/predswap.by_instr.json.gz
546ba0d8ad53a129b3e269e33bb923b6b91ea78b0ffb9aaca521e37978c02cca  release/kernels/predswap.by_unit.json.gz
7758ccb29a706dea92f4ef7292425d43d24175be7657e9e1946a329cdcbd8d42  release/kernels/predswap.ccvtrace
ecc85e0e41a97d6f5c45ba2d35c96b285681875abf5ed65086305afec4567cff  release/kernels/predswap.log
a6d4f7ed517553816d889c7c9eeb6bcfd1f6c973fbf682ecb69f3c2de619f7bb  release/kernels/predswap.oracle.jsonl
b8552da69a1b1f70c5d7a421a270b10397bfd395e64b5fa2531080f483c79396  release/kernels/predswap.sv-hosted.log
da015e3efc43d45c9eedb7c61cc70c327963a4e630bdaa19de5377457bdc7895  release/kernels/privwin.by_instr.json.gz
2949f0cfe151ac9d2dfa89e86a55e005d1635e596e693af24e8e24d655532ba4  release/kernels/privwin.by_unit.json.gz
6e21b4c8f0ebb33c35b7e8708eb16d7cca7229109f73b78193288072387bde47  release/kernels/privwin.ccvtrace
c2e20944f57c6e4b9a9ef4d21bd971154758ce5f6998c77391787bb633becb5d  release/kernels/privwin.log
861f686fc4480363472908d679d8815e8c957d768e7ab32c826930527b0fb7a8  release/kernels/privwin.oracle.jsonl
e3fd3c8c82c165161c8bb805bb3649face588ab4dc52189e32a77dac27b02ce8  release/kernels/privwin.sv-hosted.log
8c1653ae8ac8f200e1e2c052b53464adc0d2004f1a516c07926305c705e78693  release/kernels/provswap.by_instr.json.gz
db50878e379c6ac477059fdf380c42fcf5b65b9c94bc39fd27ff10b60085340f  release/kernels/provswap.by_unit.json.gz
7fa32ec026c0c7defc6bd29652d08d0a801ba17a1a7c71b2e03f265f4b53f8f9  release/kernels/provswap.ccvtrace
81083657092331f85eea610a6a85a60cc7e93d1f28d81dc9c5a64517ec8713f7  release/kernels/provswap.log
c9c32a793d54cc7401477f582487f7e8b345b2669a75337b8d6327120d98e5dc  release/kernels/provswap.oracle.jsonl
e626f51d9b5a85c823c078074047f45b17f0131a104af4a9f21f0cf5202a2564  release/kernels/provswap.sv-hosted.log
776e6a7fd862f5f21887d031eeb1fbf71851add5097cfce8ed12047da6ee03f0  release/kernels/roconst.by_instr.json
9a5376983a17bd5e33fc3cc62017b0d2a05cbf3c82675b263203980dae5ead9f  release/kernels/roconst.by_unit.json
162353aa4b450227d1131d34bc2b2060977047e199113ca02866cc019c213f70  release/kernels/roconst.ccvtrace
3be78d736368a85e7d8e0cf571079f3c9b1a18e695dbcd920b2425408da2c6b7  release/kernels/roconst.log
8087c0671de620162881aecd38cd6114b78e7be6bd71201e3ec02c9a2e2e750e  release/kernels/roconst.oracle.jsonl
d14d048091f34b1ad9368b7d564aa05f3646a9bce2552a43c2700f8af0aa2712  release/kernels/roconst.sv-hosted.log
f74c73d8cec58586d0e7903386ebc54e02375bac83a654ed745eb07255efa376  release/kernels/rogated.by_instr.json
156b6f381b5ddecc178e8bda7ab2b90e3d26e898a135f3997a25614e2fedfaae  release/kernels/rogated.by_unit.json.gz
138bce3c14373a6d3049b1c613d4c55ccff70d7f650d704366ec7da8eadd5990  release/kernels/rogated.ccvtrace
4060ae2f46d4dcc52187af67ac9743c7d733932bf5d0ceb49f6445ab7ae6f1f3  release/kernels/rogated.log
7cd02bd4cceec5a044d6b4d6a80df1e68ed0ae71b0b2a953143636d5b809ea6c  release/kernels/rogated.oracle.jsonl
4622d2bebd29d087cecda9064c0059ec248450b36ff45ecf07a8762debae7856  release/kernels/rogated.sv-hosted.log
cf098ea54d0069571ec2764aa379dd737b0e94388a145cac04af0ba799776cc7  release/kernels/rokill.by_instr.json.gz
f8c2feea82726b07848dc5180ddda8439ab66e6684616cf0fa06abd98c6a9644  release/kernels/rokill.by_unit.json.gz
e21aeb1f6d8b6afdfe39c7e695141a7def9b5c25dc092bb7dd67b897279a5ac3  release/kernels/rokill.ccvtrace
34d00f18d6255401ba33c44f65919c9003e030470ca09f3de978df3c70c69c90  release/kernels/rokill.log
94efcef96af469a512d346ce61623980fe86383188eaebd55120f716db596f14  release/kernels/rokill.oracle.jsonl
17a9e0025eafdbdd1eb99877de75b0e5a95a5f148046ad94f6beda60c8f0578c  release/kernels/rokill.sv-hosted.log
d79047b009857071779a693f850c1075f9f16d3c5b710fd4b210c63f992958e3  release/kernels/rolaunch.by_instr.json
3f6152f308ca82382a9e85358d732ae3ccd8f74f1285cd5b1911761c346d28bb  release/kernels/rolaunch.by_unit.json
900b59130f8df122f51090cedd4e0efa61a5bce7fc340aa60184bf16ddec6f69  release/kernels/rolaunch.ccvtrace
6b45e9fe6c3d0c588b03490e36f37f30b03c40791b0cdf2bd4e55e1988963374  release/kernels/rolaunch.log
e7dad585c3e70615de04330fd03f4f282c29a005dc1732a35655fb261d51139e  release/kernels/rolaunch.oracle.jsonl
dcb7b1563e41905e076ffc33773648f7568eec6f6635ec2dd1a79abd80eca2b0  release/kernels/rolaunch.sv-hosted.log
776e6a7fd862f5f21887d031eeb1fbf71851add5097cfce8ed12047da6ee03f0  release/kernels/rolimit.by_instr.json
647182480c7cfb565600659789a1cf0fb54d328a3c1bd2d9b11645ab22a19673  release/kernels/rolimit.by_unit.json
f9cf22e07e26b81969e350f959b3cebe854e9f3606b86fead8e6aad5628d43a6  release/kernels/rolimit.ccvtrace
9629e977669fcc2288a307bfe3ed14d88e56c993fb63a848a83f4d560d76a780  release/kernels/rolimit.log
1c5bc0cb8e8b2e69505fb5a551a16d5d10c56f232b88da7a27e336ad7d962de2  release/kernels/rolimit.oracle.jsonl
500743edf3fa94f3f65c1c66753efb560379d790cc7211af6612a1936abc579c  release/kernels/rolimit.sv-hosted.log
37a6404c685bae01114f10fc2adee2d5627218a74e769933dfaf849c6862249f  release/kernels/roload.by_instr.json.gz
f779f02bb83d3cd4f88d32dcffd453c4262d68248dfcaa2832c327ecbbb5856e  release/kernels/roload.by_unit.json.gz
281316818b45777881fc68b792a2a682d74ec4770caf12e72972536dbbf0b5f2  release/kernels/roload.ccvtrace
61cc06259965d5a06963e4bc8f5a0475f725e72a632782719cfe46937199a705  release/kernels/roload.log
f7c1309cc9764769fb5803f6fd0f2f5e1eb418f2d23fbe5e17cf5f9106869fdf  release/kernels/roload.oracle.jsonl
a7e371f34f14952fc9110766dd4e3872471ac72c05fc41c9372d915ab0e7b514  release/kernels/roload.sv-hosted.log
6bb6ae95b546811a1671647a4af7e97fb5ac7057986fb0a4c045db6eb32ac71d  release/kernels/rope.by_instr.json.gz
463787256b7828f4a29dfffd912c964f5bf520b4a7a99df00000bbc91930170e  release/kernels/rope.by_unit.json.gz
ae8e2b64c3017439e488a7e13917af45a8456bbb7a1a1901344323fffe69c2e3  release/kernels/rope.ccvtrace
40b6fa9767799474fc6186adb145d7530b9b60e3172be259ffc73d40127040a2  release/kernels/rope.log
d55f9efae392dc8877c102c01c0810e7654b666b6ede386328108164c6cf88f3  release/kernels/rope.oracle.jsonl
093914a085d23681aa166c8fa5a2f02885da760cfc40f4ef2d8e577fec730a2c  release/kernels/rope.sv-hosted.log
3b589a5d2f4ba50764743648c44db6eeca78ff9ef70e5a23e079866fccb36400  release/kernels/ropediv.by_instr.json.gz
fd5a0b45a56f0ee590400e934995401515e9e4c6ebb4bd32f4203c717461aa53  release/kernels/ropediv.by_unit.json.gz
a2188a09c628769debead4e096a382d54e9caf8f900701f9245207ec43e37d0a  release/kernels/ropediv.ccvtrace
9767227914b822c8bfa79a3afd359dfb330159bc92404140da5d7e918d5cbaf9  release/kernels/ropediv.log
10c0ec6ec18b7b44638c790033109198c079d07c1537bf193353ccedd00a920f  release/kernels/ropediv.oracle.jsonl
bdb34e86383705ad674b6f1ddd94df3efb43d32e323aebe7d5408c3f69472b57  release/kernels/ropediv.sv-hosted.log
c4d3c8136726b596a90a8de03f00b94473d4ae15e45b9256c1bf953533653c4f  release/kernels/sel.by_instr.json.gz
d9c1b7959d8e291bca23bf51859bf6c02fdada9522059cc9950138f32ddea0a5  release/kernels/sel.by_unit.json.gz
66ad83374c3584cb56b28d240ffec216e66a1407e20919de92f35cbc1e339b48  release/kernels/sel.ccvtrace
37da397e775475bbda707671bdfd940993e68147a99941b97bde250a0f84f06e  release/kernels/sel.log
87f6a81e8afa004c8039bf2f61c90176fcf29ab29bb17ac44aa016a5cc8438fe  release/kernels/sel.oracle.jsonl
f79a972e2edc8fa894e54d994ef5c045af33581d4da7419e1cabce87cca88a41  release/kernels/sel.sv-hosted.log
0e0be3006dc97a5afab6db500e06a88be3de431ced1c1dc54b0feb221a323dfa  release/kernels/sized.by_instr.json.gz
fb5293076cf3e43d539f75ae016630f184969d52f970ea2ab4e693a58a6ed4d2  release/kernels/sized.by_unit.json.gz
dd919d4633e5505228ba24a6283c664882f396a4e0ec0466a6dee89c48442333  release/kernels/sized.ccvtrace
c9f50bd67a9d6ab292fa2bf56994149313ef8227855f167d0d495e009b90e6d9  release/kernels/sized.log
36d903ba1618bd1faa437c9812a6ee6c0c966a63196c796267d74bf2695ebc3d  release/kernels/sized.oracle.jsonl
5e71bc57a51cc9cb0676b33bc5907861b86156c22acc3d9febbd19ad6d488a3a  release/kernels/sized.sv-hosted.log
5694cb372613f61d75c04c6761679f703cee7e80ab43a2c7d2db9058de0db5f8  release/kernels/slotform.by_instr.json.gz
0e60e3c1a58016a8d0e76140ad1a61819ccf05c1fc32a7f68bc3dbced34bd182  release/kernels/slotform.by_unit.json.gz
777745644e3cf8554e7c01721d44ccf24504d3a4a8c465ccf637892cfd591acf  release/kernels/slotform.ccvtrace
2e631766f1348e0d5a8db76667da2ba34704f7fc5581ed1d463cd334efbc3f34  release/kernels/slotform.log
8b61db7419b18cea8a646fb628218447e72e84a18a9891ffb73b441736138ab9  release/kernels/slotform.oracle.jsonl
38e00e9b64af31dccec14168069bdff78d07c90998ac509265075b676163e8aa  release/kernels/slotform.sv-hosted.log
36530fef81fe0cda1b3dbc552d86cc76a2bbae0ac7419d9ba7fd3f6a8ab973a1  release/kernels/spinwait.by_instr.json.gz
43fee1d891313189daf2ebedd39ad8781ea61cd618bfea4bd8534245e8274850  release/kernels/spinwait.by_unit.json.gz
14e3c76cbdce4d98684088a93cee8246f50b6748014b51ada85f416703fe10b2  release/kernels/spinwait.ccvtrace
c04f70a9adebec7746dd4e18e70a7688ed4027ca05ed210bebf521f18de685f6  release/kernels/spinwait.log
868920637236c878b33779bd450439466fc3626996a3164573dc11d437d5c709  release/kernels/spinwait.oracle.jsonl
852ec1b17342134f02eed39a9672d346edcda655c32bc0f9347c5547df8be062  release/kernels/spinwait.sv-hosted.log
8fe97c92ff3e9ffe60f4b3c52f3754469d1686abfbaf19bd044af40b56dec9a1  release/kernels/spmbank.by_instr.json.gz
8488e0eec238149254e5be2098448c1aa1cc8cb58ced5e2964fb2988c97c068e  release/kernels/spmbank.by_unit.json.gz
eb5810bce405d563204e1672df11b7a164c88aa349ce08e7bb1d70aa03bd4431  release/kernels/spmbank.ccvtrace
03b06b39e10aca7a517a242eff3ef9aa45a676ddf75e23132174374dba310174  release/kernels/spmbank.log
3af490cc37d7a92dbe719b57de216b648536eb301ff9d13de9a39f50d150d725  release/kernels/spmbank.oracle.jsonl
3c367c26c07d5c08a0134e16af41b127b67bf36808965f2f0d62e66c261a58e1  release/kernels/spmbank.sv-hosted.log
72c5094b6c237e29d9f3b3295e00af48e4fc71d0e10abdce816b6f667f1845ea  release/kernels/srd.by_instr.json.gz
614fd9152c60052b11615ce57bac9ef9a7b3a42e03d3d959bad9598467441d73  release/kernels/srd.by_unit.json.gz
f7816dff4bffb2c75f4dec97759a50512c426f93bac251f78efb99cefe78490b  release/kernels/srd.ccvtrace
4ced265b6cc4bb380256cfa92f4ba581f7bb75a1eedea1d388e763dd328e1394  release/kernels/srd.log
b08eb5e3673cac7eebb8b72af5ed3783c8e70a9e96592e76bf3722551bc79473  release/kernels/srd.oracle.jsonl
0b604c777a0cfb0b43aefd340022e53a1d00588e895cf48f280789c0f73c3185  release/kernels/srd.sv-hosted.log
5a232fc7296cef4926b3e8b4b9e17f20f0506aa06d0ed9ef9b00b142a5f13731  release/kernels/stall.by_instr.json.gz
452bef17b0a1c45d5565b97fcfa9c7db7d47429daf4163c5052093fd0b063c0c  release/kernels/stall.by_unit.json.gz
026aaa1dd08e02cd4e27d2cf29f12b44fcf40a072b40a86aa93626e5124714d1  release/kernels/stall.ccvtrace
2a1d468b2709723ac679db2b6964ab2ce588986b000b7a72ce33ae2f7199f413  release/kernels/stall.log
500db2c482b07a0706583422cd68878301d0146c1f872ccc1f11bfdcf5c993ef  release/kernels/stall.oracle.jsonl
689f127f1f2c79cdee589ef235f8c6db32ea214e703e50266c5c65ba50b155c6  release/kernels/stall.sv-hosted.log
c3da9fe2aa3cb0e959b997250dc54f9aadb12ec4f180964bdec3969fb6f40fb0  release/kernels/swap.by_instr.json.gz
2ba523a43ea4f33d8629f2d84931b1d92d1eceb26503ccb64c38b007c5af568e  release/kernels/swap.by_unit.json.gz
26bcd1d049c49f16723a580ab7035498357ecb1511a89243894c5d11a15c1181  release/kernels/swap.ccvtrace
dca294bba414fdf9e210418b3d27f427cc59db39da82745d0e1a520d44bdfae2  release/kernels/swap.log
3658a26316c1ff7bc1744304a42f736e930fcde2865c8913e6cc67a22ce96667  release/kernels/swap.oracle.jsonl
5136584bac6decafde0c0b5146e60a2988dcda688a3aa52f31051240882c5794  release/kernels/swap.sv-hosted.log
ba38209da991c86b849c119e51c67a26757d613f4c4332a83a6b6f8f85efed14  release/kernels/transp4.by_instr.json.gz
1766504900a13729a43788dbeeb8438e0c25a6191a40b7baddba3c5f41e849ef  release/kernels/transp4.by_unit.json.gz
a8fd7d37e8228f601edaa0fc7bfb150002a6ef877fbc2241f6ce573da99bce82  release/kernels/transp4.ccvtrace
a64d15012b48627b1e7c0833fcd709c060c83ef6fee2a8ebf1a03c0c485bd933  release/kernels/transp4.log
06396ace3ac19677fd39c700e408606e5bdbacb24997d663bbe8872e63dd74fc  release/kernels/transp4.oracle.jsonl
8a193ff91bf3d7d1da75c644cbaee70d0d7e05e8f73d715ebdd28e162a65d28b  release/kernels/transp4.sv-hosted.log
6c356b7e50ded681c86c49d2745cd56b70cf65e32eaabb14eedef627568ff1fa  release/kernels/unal.by_instr.json.gz
e90c91c90a4dc9e34bf1700f97746b317ae31c0c2c43fb7096789e8751fb67f2  release/kernels/unal.by_unit.json.gz
a17fa14378ccae01254caa4a5262d287ec6d703ee9eb1448180bf280cc9b01f6  release/kernels/unal.ccvtrace
456e476d0d2dc84386e870b00b11fa8bed402056f68b7b97fab1dd34f9dd45ec  release/kernels/unal.log
c3d484bb160657a563df983d9a2532eac27f556636617960aa1e72183ac2b299  release/kernels/unal.oracle.jsonl
961bc971fd510072f510aa8ab1ede3da7a06686dd4bd6e017bd4bd5045d7377b  release/kernels/unal.sv-hosted.log
98ddd39065bd1def8433aee35bc22466e9d6879168c663b1c4cf6c4f46d44bb3  release/kernels/vadd.by_instr.json.gz
d4ed4dda6e6199b3cf6d1f67d85a18066d85b0dca0a21272f85ffb1482e7babb  release/kernels/vadd.by_unit.json.gz
2729da403fa32e30087d7d40f6106ed3a63f8c596cd3390d173d38176e933889  release/kernels/vadd.ccvtrace
b13cb8a585ef338ab01129737a62243f853801215754d839e0f8cce6b7b52f88  release/kernels/vadd.log
0276b6d0611a4bbcdc004ab3987214aea138245bc7217504147331689a9c0880  release/kernels/vadd.oracle.jsonl
ffd09790d218af83f3ea7c791f74a2eb4f0f9ff3bbbfa5e572f47605da8b2898  release/kernels/vadd.sv-hosted.log
c6760b735b2f4482b43fbc1025cec4c6562ac75116bc79882d550c53e9f6b961  release/kernels/vadd4.by_instr.json.gz
57c6f1705b79de681665de506cb500f4af153e2dd5c26f543c6536fc07214a69  release/kernels/vadd4.by_unit.json.gz
09f0d897c3309efac8853234a993784a3074643c89c8f9bac2b575cd88bba8ed  release/kernels/vadd4.ccvtrace
2f047468deed4f971ee0808541c6ea0374b7bff47f73b8f6b73b8ec378409f91  release/kernels/vadd4.log
225aa18fc9f38aa9ad615aa11de254337d59fa705877553d873062c68366e0db  release/kernels/vadd4.oracle.jsonl
597a37b26ffd3897b70ade698df337294cbaae6e4c2a986be2bbd0c033555a7d  release/kernels/vadd4.sv-hosted.log
39e1018ce9adf957bc7b4d9ab4df6eb5d47db71b4f107a5ac6598daf27bd6faf  release/kernels/vaddslow.by_instr.json.gz
6dfb9ea0ba6d38a317e6da8c23fee14bf12621dbf93c6c468657fa93e6c264a7  release/kernels/vaddslow.by_unit.json.gz
43a6f57dd4068afdb9c1694aa1321b192d352148bcdb105e2c658d987842506a  release/kernels/vaddslow.ccvtrace
a4216e0565ed178d20e89abeee17c75421416ea5cf8f9c4a981cf58f49291274  release/kernels/vaddslow.log
e9e6218e8b8450e9f9ff6b39d659c994a1e51c527a0c5bd10d18b5658ae0e344  release/kernels/vaddslow.oracle.jsonl
0e34dae56db0e595a6f937b9553434a8447b10edb2ad1d0eed898a28457e485d  release/kernels/vaddslow.sv-hosted.log
ab9f305970edddb23930cd20a4becd5978168e318f950a6e699ca3fce3724cc0  release/verify.log
1f3a2eff14dbda0754e19cbf72bc5003c950fc7d1691d527ce3a8d427fb583d7  release/wiring.txt
```
