# Snapshot snapshot-2026-10-31-3fbb402

**A generated, read-only snapshot. Do not edit or merge it.** The source
is `ti-ret` at `3fbb402a3ba38498510b859e2dd190e132918001`, and this branch is rebuilt from source by
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
| Source | `ti-ret` @ `3fbb402a3ba38498510b859e2dd190e132918001` |
| Built | 2026-10-31 (UTC) |
| Gate | `tools/verify.sh`: PASS |
| Compiler snapshot | custom-cuda-complier `release` @ `d9ddd2c5c57fc99d8aabfad847d0be963830e212` (source `f5fa03032348a7318a51946fbcd89bd9caa46caf`) |
| Verilator | Verilator 5.052 2026-09-05 rev v5.052 |
| Icarus | Icarus Verilog version 12.0 (stable) () |
| Yosys | Yosys 0.33 (git sha1 2584903a060) |

## Kernels

| Kernel | Result |
|---|---|
| `addrhigh` | `name=addrhigh finished=1 cycles=71 from_fetch=40 retired=5 issue_groups=6 order=ok gpr_mismatch=0 pred_mismatch=0 mem_mismatch=0 check_failures=0 class_violations=0 overflows=0 credit_leaks=0 channels_used=26/55 violations=0` |
| `addrlimit` | `name=addrlimit finished=1 cycles=1071 from_fetch=1040 retired=5 issue_groups=5 order=ok gpr_mismatch=0 pred_mismatch=0 mem_mismatch=0 check_failures=0 class_violations=0 overflows=0 credit_leaks=0 channels_used=27/55 violations=0` |
| `addrneg` | `name=addrneg finished=1 cycles=69 from_fetch=38 retired=1 issue_groups=2 order=ok gpr_mismatch=0 pred_mismatch=0 mem_mismatch=0 check_failures=0 class_violations=0 overflows=0 credit_leaks=0 channels_used=23/55 violations=0` |
| `borrow` | `name=borrow finished=1 cycles=102 from_fetch=71 retired=7 issue_groups=7 order=ok gpr_mismatch=0 pred_mismatch=0 mem_mismatch=0 check_failures=0 class_violations=0 overflows=0 credit_leaks=0 channels_used=21/55 violations=0` |
| `brs` | `name=brs finished=1 cycles=100 from_fetch=69 retired=12 issue_groups=12 order=ok gpr_mismatch=0 pred_mismatch=0 mem_mismatch=0 check_failures=0 class_violations=0 overflows=0 credit_leaks=0 channels_used=23/55 violations=0` |
| `byp` | `name=byp finished=1 cycles=119 from_fetch=88 retired=14 issue_groups=14 order=ok gpr_mismatch=0 pred_mismatch=0 mem_mismatch=0 check_failures=0 class_violations=0 overflows=0 credit_leaks=0 channels_used=31/55 violations=0` |
| `callret` | `name=callret finished=1 cycles=274 from_fetch=243 retired=40 issue_groups=40 order=ok gpr_mismatch=0 pred_mismatch=0 mem_mismatch=0 check_failures=0 class_violations=0 overflows=0 credit_leaks=0 channels_used=30/55 violations=0` |
| `chains` | `name=chains finished=1 cycles=97 from_fetch=66 retired=29 issue_groups=29 order=ok gpr_mismatch=0 pred_mismatch=0 mem_mismatch=0 check_failures=0 class_violations=0 overflows=0 credit_leaks=0 channels_used=21/55 violations=0` |
| `div` | `name=div finished=1 cycles=977 from_fetch=946 retired=144 issue_groups=144 order=ok gpr_mismatch=0 pred_mismatch=0 mem_mismatch=0 check_failures=0 class_violations=0 overflows=0 credit_leaks=0 channels_used=23/55 violations=0` |
| `divchw` | `name=divchw finished=1 cycles=99 from_fetch=68 retired=5 issue_groups=6 order=ok gpr_mismatch=0 pred_mismatch=0 mem_mismatch=0 check_failures=0 class_violations=0 overflows=0 credit_leaks=0 channels_used=22/55 violations=0` |
| `divtail` | `name=divtail finished=1 cycles=641 from_fetch=610 retired=96 issue_groups=96 order=ok gpr_mismatch=0 pred_mismatch=0 mem_mismatch=0 check_failures=0 class_violations=0 overflows=0 credit_leaks=0 channels_used=23/55 violations=0` |
| `divtail2` | `name=divtail2 finished=1 cycles=1516 from_fetch=1485 retired=366 issue_groups=366 order=ok gpr_mismatch=0 pred_mismatch=0 mem_mismatch=0 check_failures=0 class_violations=0 overflows=0 credit_leaks=0 channels_used=23/55 violations=0` |
| `fence` | `name=fence finished=1 cycles=82 from_fetch=51 retired=7 issue_groups=7 order=ok gpr_mismatch=0 pred_mismatch=0 mem_mismatch=0 check_failures=0 class_violations=0 overflows=0 credit_leaks=0 channels_used=30/55 violations=0` |
| `gather` | `name=gather finished=1 cycles=265 from_fetch=234 retired=16 issue_groups=16 order=ok gpr_mismatch=0 pred_mismatch=0 mem_mismatch=0 check_failures=0 class_violations=0 overflows=0 credit_leaks=0 channels_used=31/55 violations=0` |
| `hit` | `name=hit finished=1 cycles=228 from_fetch=197 retired=17 issue_groups=17 order=ok gpr_mismatch=0 pred_mismatch=0 mem_mismatch=0 check_failures=0 class_violations=0 overflows=0 credit_leaks=0 channels_used=31/55 violations=0` |
| `lanectx` | `name=lanectx finished=1 cycles=69 from_fetch=38 retired=10 issue_groups=10 order=ok gpr_mismatch=0 pred_mismatch=0 mem_mismatch=0 check_failures=0 class_violations=0 overflows=0 credit_leaks=0 channels_used=29/55 violations=0` |
| `lanectx2` | `name=lanectx2 finished=1 cycles=69 from_fetch=38 retired=10 issue_groups=10 order=ok gpr_mismatch=0 pred_mismatch=0 mem_mismatch=0 check_failures=0 class_violations=0 overflows=0 credit_leaks=0 channels_used=29/55 violations=0` |
| `late` | `name=late finished=1 cycles=172 from_fetch=141 retired=16 issue_groups=16 order=ok gpr_mismatch=0 pred_mismatch=0 mem_mismatch=0 check_failures=0 class_violations=0 overflows=0 credit_leaks=0 channels_used=31/55 violations=0` |
| `ldpar` | `name=ldpar finished=1 cycles=155 from_fetch=124 retired=17 issue_groups=17 order=ok gpr_mismatch=0 pred_mismatch=0 mem_mismatch=0 check_failures=0 class_violations=0 overflows=0 credit_leaks=0 channels_used=31/55 violations=0` |
| `lnorm1` | `name=lnorm1 finished=1 cycles=2592 from_fetch=2561 retired=526 issue_groups=526 order=ok gpr_mismatch=0 pred_mismatch=0 mem_mismatch=0 check_failures=0 class_violations=0 overflows=0 credit_leaks=0 channels_used=37/55 violations=0` |
| `localsp` | `name=localsp finished=1 cycles=4238 from_fetch=4207 retired=40 issue_groups=40 order=ok gpr_mismatch=0 pred_mismatch=0 mem_mismatch=0 check_failures=0 class_violations=0 overflows=0 credit_leaks=0 channels_used=32/55 violations=0` |
| `loop` | `name=loop finished=1 cycles=2841 from_fetch=2810 retired=407 issue_groups=407 order=ok gpr_mismatch=0 pred_mismatch=0 mem_mismatch=0 check_failures=0 class_violations=0 overflows=0 credit_leaks=0 channels_used=23/55 violations=0` |
| `merge` | `name=merge finished=1 cycles=72 from_fetch=41 retired=9 issue_groups=9 order=ok gpr_mismatch=0 pred_mismatch=0 mem_mismatch=0 check_failures=0 class_violations=0 overflows=0 credit_leaks=0 channels_used=21/55 violations=0` |
| `missrun` | `name=missrun finished=1 cycles=122 from_fetch=91 retired=28 issue_groups=28 order=ok gpr_mismatch=0 pred_mismatch=0 mem_mismatch=0 check_failures=0 class_violations=0 overflows=0 credit_leaks=0 channels_used=31/55 violations=0` |
| `mload` | `name=mload finished=1 cycles=112 from_fetch=81 retired=11 issue_groups=11 order=ok gpr_mismatch=0 pred_mismatch=0 mem_mismatch=0 check_failures=0 class_violations=0 overflows=0 credit_leaks=0 channels_used=31/55 violations=0` |
| `mlp` | `name=mlp finished=1 cycles=127 from_fetch=96 retired=21 issue_groups=21 order=ok gpr_mismatch=0 pred_mismatch=0 mem_mismatch=0 check_failures=0 class_violations=0 overflows=0 credit_leaks=0 channels_used=31/55 violations=0` |
| `mwmiss` | `name=mwmiss finished=1 cycles=131 from_fetch=100 retired=88 issue_groups=88 order=ok gpr_mismatch=0 pred_mismatch=0 mem_mismatch=0 check_failures=0 class_violations=0 overflows=0 credit_leaks=0 channels_used=31/55 violations=0` |
| `narrowadd` | `name=narrowadd finished=1 cycles=230 from_fetch=199 retired=21 issue_groups=21 order=ok gpr_mismatch=0 pred_mismatch=0 mem_mismatch=0 check_failures=0 class_violations=0 overflows=0 credit_leaks=0 channels_used=32/55 violations=0` |
| `pguard` | `name=pguard finished=1 cycles=86 from_fetch=55 retired=12 issue_groups=12 order=ok gpr_mismatch=0 pred_mismatch=0 mem_mismatch=0 check_failures=0 class_violations=0 overflows=0 credit_leaks=0 channels_used=29/55 violations=0` |
| `plog` | `name=plog finished=1 cycles=71 from_fetch=40 retired=10 issue_groups=10 order=ok gpr_mismatch=0 pred_mismatch=0 mem_mismatch=0 check_failures=0 class_violations=0 overflows=0 credit_leaks=0 channels_used=21/55 violations=0` |
| `predlane` | `name=predlane finished=1 cycles=927 from_fetch=896 retired=10 issue_groups=10 order=ok gpr_mismatch=0 pred_mismatch=0 mem_mismatch=0 check_failures=0 class_violations=0 overflows=0 credit_leaks=0 channels_used=31/55 violations=0` |
| `predmerge` | `name=predmerge finished=1 cycles=939 from_fetch=908 retired=9 issue_groups=9 order=ok gpr_mismatch=0 pred_mismatch=0 mem_mismatch=0 check_failures=0 class_violations=0 overflows=0 credit_leaks=0 channels_used=33/55 violations=0` |
| `predspill` | `name=predspill finished=1 cycles=966 from_fetch=935 retired=12 issue_groups=12 order=ok gpr_mismatch=0 pred_mismatch=0 mem_mismatch=0 check_failures=0 class_violations=0 overflows=0 credit_leaks=0 channels_used=31/55 violations=0` |
| `predswap` | `name=predswap finished=1 cycles=1178 from_fetch=1147 retired=46 issue_groups=46 order=ok gpr_mismatch=0 pred_mismatch=0 mem_mismatch=0 check_failures=0 class_violations=0 overflows=0 credit_leaks=0 channels_used=33/55 violations=0` |
| `privwin` | `name=privwin finished=1 cycles=2215 from_fetch=2184 retired=52 issue_groups=52 order=ok gpr_mismatch=0 pred_mismatch=0 mem_mismatch=0 check_failures=0 class_violations=0 overflows=0 credit_leaks=0 channels_used=34/55 violations=0` |
| `provswap` | `name=provswap finished=1 cycles=2325 from_fetch=2294 retired=978 issue_groups=978 order=ok gpr_mismatch=0 pred_mismatch=0 mem_mismatch=0 check_failures=0 class_violations=0 overflows=0 credit_leaks=0 channels_used=33/55 violations=0` |
| `roconst` | `name=roconst finished=1 cycles=64 from_fetch=33 retired=4 issue_groups=5 order=ok gpr_mismatch=0 pred_mismatch=0 mem_mismatch=0 check_failures=0 class_violations=0 overflows=0 credit_leaks=0 channels_used=26/55 violations=0` |
| `rogated` | `name=rogated finished=1 cycles=84 from_fetch=53 retired=7 issue_groups=8 order=ok gpr_mismatch=0 pred_mismatch=0 mem_mismatch=0 check_failures=0 class_violations=0 overflows=0 credit_leaks=0 channels_used=26/55 violations=0` |
| `rokill` | `name=rokill finished=1 cycles=93 from_fetch=62 retired=41 issue_groups=4536 order=ok gpr_mismatch=0 pred_mismatch=0 mem_mismatch=0 check_failures=0 class_violations=0 overflows=0 credit_leaks=0 channels_used=27/55 violations=0` |
| `rolaunch` | `name=rolaunch finished=1 cycles=62 from_fetch=31 retired=4 issue_groups=5 order=ok gpr_mismatch=0 pred_mismatch=0 mem_mismatch=0 check_failures=0 class_violations=0 overflows=0 credit_leaks=0 channels_used=24/55 violations=0` |
| `rolimit` | `name=rolimit finished=1 cycles=64 from_fetch=33 retired=4 issue_groups=5 order=ok gpr_mismatch=0 pred_mismatch=0 mem_mismatch=0 check_failures=0 class_violations=0 overflows=0 credit_leaks=0 channels_used=26/55 violations=0` |
| `roload` | `name=roload finished=1 cycles=106 from_fetch=75 retired=8 issue_groups=8 order=ok gpr_mismatch=0 pred_mismatch=0 mem_mismatch=0 check_failures=0 class_violations=0 overflows=0 credit_leaks=0 channels_used=31/55 violations=0` |
| `rope` | `name=rope finished=1 cycles=6763 from_fetch=6732 retired=354 issue_groups=354 order=ok gpr_mismatch=0 pred_mismatch=0 mem_mismatch=0 check_failures=0 class_violations=0 overflows=0 credit_leaks=0 channels_used=34/55 violations=0` |
| `ropediv` | `name=ropediv finished=1 cycles=1118 from_fetch=1087 retired=203 issue_groups=203 order=ok gpr_mismatch=0 pred_mismatch=0 mem_mismatch=0 check_failures=0 class_violations=0 overflows=0 credit_leaks=0 channels_used=34/55 violations=0` |
| `sel` | `name=sel finished=1 cycles=76 from_fetch=45 retired=8 issue_groups=8 order=ok gpr_mismatch=0 pred_mismatch=0 mem_mismatch=0 check_failures=0 class_violations=0 overflows=0 credit_leaks=0 channels_used=29/55 violations=0` |
| `sized` | `name=sized finished=1 cycles=2641 from_fetch=2610 retired=25 issue_groups=25 order=ok gpr_mismatch=0 pred_mismatch=0 mem_mismatch=0 check_failures=0 class_violations=0 overflows=0 credit_leaks=0 channels_used=32/55 violations=0` |
| `slotform` | `name=slotform finished=1 cycles=4365 from_fetch=4334 retired=12 issue_groups=12 order=ok gpr_mismatch=0 pred_mismatch=0 mem_mismatch=0 check_failures=0 class_violations=0 overflows=0 credit_leaks=0 channels_used=32/55 violations=0` |
| `spinwait` | `name=spinwait finished=1 cycles=2180 from_fetch=2149 retired=211 issue_groups=211 order=ok gpr_mismatch=0 pred_mismatch=0 mem_mismatch=0 check_failures=0 class_violations=0 overflows=0 credit_leaks=0 channels_used=34/55 violations=0` |
| `spmbank` | `name=spmbank finished=1 cycles=185 from_fetch=154 retired=13 issue_groups=13 order=ok gpr_mismatch=0 pred_mismatch=0 mem_mismatch=0 check_failures=0 class_violations=0 overflows=0 credit_leaks=0 channels_used=28/55 violations=0` |
| `srd` | `name=srd finished=1 cycles=69 from_fetch=38 retired=6 issue_groups=6 order=ok gpr_mismatch=0 pred_mismatch=0 mem_mismatch=0 check_failures=0 class_violations=0 overflows=0 credit_leaks=0 channels_used=29/55 violations=0` |
| `stall` | `name=stall finished=1 cycles=557 from_fetch=526 retired=116 issue_groups=116 order=ok gpr_mismatch=0 pred_mismatch=0 mem_mismatch=0 check_failures=0 class_violations=0 overflows=0 credit_leaks=0 channels_used=31/55 violations=0` |
| `swap` | `name=swap finished=1 cycles=557 from_fetch=526 retired=174 issue_groups=174 order=ok gpr_mismatch=0 pred_mismatch=0 mem_mismatch=0 check_failures=0 class_violations=0 overflows=0 credit_leaks=0 channels_used=31/55 violations=0` |
| `transp4` | `name=transp4 finished=1 cycles=1137 from_fetch=1106 retired=976 issue_groups=976 order=ok gpr_mismatch=0 pred_mismatch=0 mem_mismatch=0 check_failures=0 class_violations=0 overflows=0 credit_leaks=0 channels_used=37/55 violations=0` |
| `unal` | `name=unal finished=1 cycles=136 from_fetch=105 retired=9 issue_groups=9 order=ok gpr_mismatch=0 pred_mismatch=0 mem_mismatch=0 check_failures=0 class_violations=0 overflows=0 credit_leaks=0 channels_used=31/55 violations=0` |
| `vadd` | `name=vadd finished=1 cycles=157 from_fetch=126 retired=17 issue_groups=17 order=ok gpr_mismatch=0 pred_mismatch=0 mem_mismatch=0 check_failures=0 class_violations=0 overflows=0 credit_leaks=0 channels_used=33/55 violations=0` |
| `vadd4` | `name=vadd4 finished=1 cycles=208 from_fetch=177 retired=68 issue_groups=68 order=ok gpr_mismatch=0 pred_mismatch=0 mem_mismatch=0 check_failures=0 class_violations=0 overflows=0 credit_leaks=0 channels_used=33/55 violations=0` |
| `vaddslow` | `name=vaddslow finished=1 cycles=546 from_fetch=515 retired=17 issue_groups=17 order=ok gpr_mismatch=0 pred_mismatch=0 mem_mismatch=0 check_failures=0 class_violations=0 overflows=0 credit_leaks=0 channels_used=33/55 violations=0` |

## Manifest of release/

```
0b3872cbbdc6be93873bfd130b8ad9b3436715de4d820cfc20975b4b20c502fa  release/kernels/addrhigh.by_instr.json.gz
0d020473a5d7c15a8d96ca27f024e612f296aae6063b114610165baf1170125a  release/kernels/addrhigh.by_unit.json.gz
163af1503f2683466e244d0ab6b60fb98af5082e75b6031e1c371b28d213a152  release/kernels/addrhigh.ccvtrace
ff1a566fb8e68d676754999a9b737d08893c2e3e825bd77ebabd7cd069d50d18  release/kernels/addrhigh.log
569f2e22883fad5f0956c57ec734e6afbdd4b8a854e50277425172d6c0cbd766  release/kernels/addrhigh.oracle.jsonl
784524ace9bce864a781c8cd3623614e78cf8f3ca8b90b8c98c25fdafee79514  release/kernels/addrhigh.sv-hosted.log
28dc69325fbf2e934fd86658223b48a8cb92053952c06eb87d3d34b4706decbc  release/kernels/addrlimit.by_instr.json
f6461e7e8081e79750a0a358ce2ee174a0174a909ffc7998aa7542e4f963d0bf  release/kernels/addrlimit.by_unit.json
d0275ae1473e1f86fd56e1553d6e6cb67f83eb67dc23e27159a63e3cf3f3f0fa  release/kernels/addrlimit.ccvtrace
3f89a5d2e6430edac81b5b5b379b38a8917d1f6b297be15bade8355f5e6b2134  release/kernels/addrlimit.log
bc660b0b40359a2c5a2478cb0eb4950b73fd22db50ea76b80052bc195a1920f4  release/kernels/addrlimit.oracle.jsonl
d0ab7a2c5869cd72f3c47304cb7c1f8b90e09940dd46a54eb7abdb493eb5e3a2  release/kernels/addrlimit.sv-hosted.log
002eb9f49b1db791a8001012fccd9f16bd62772dd9f663bd1a841e07061ce16c  release/kernels/addrneg.by_instr.json
ada96822553635b5282a2fb7c64ddaf92933ad7c066099ad0dd4205e98f8b381  release/kernels/addrneg.by_unit.json
5cb0374d21bf1240216d039ca378d384e50df24c7c9a4dd00b14448e75084b34  release/kernels/addrneg.ccvtrace
7bb437c6e4c3deb1676dbcc5bc81fea0a87bd56f500bd98fdbeeb67e565062af  release/kernels/addrneg.log
16f5b0707ae44492a1efd67bb9dd38a7e79a7bbd354fa9207b9e7d150ff2f107  release/kernels/addrneg.oracle.jsonl
ed9de92047510551a53a8432c1cb236ecd3ded88d2838fe4818d49bf8e6e018e  release/kernels/addrneg.sv-hosted.log
4fb07d2d10d74fe74e6af5c54d9c56590ff015e6c349f8253f2245377dc01e2a  release/kernels/borrow.by_instr.json.gz
7337c1b5c438a79641bd973a2dbd3f6b3501bf2817df2ed7681b8a9cbce085a2  release/kernels/borrow.by_unit.json.gz
eb3b65227b3efa8df2a36eeae47e514081c2f089bf69197f82fff60ef101d137  release/kernels/borrow.ccvtrace
e54c1cce9f8f2c8f6d7f701ea694634d992a92081ee73c0ae02deeb3be3fc549  release/kernels/borrow.log
4c565e1ce0b3baee36e158694b32c8defb5cd662b2f9af75cb5d8c26cb1168ed  release/kernels/borrow.oracle.jsonl
02671ba7c96517c4feb47104e7d7c113703ab6e479194bd32bcc8a513cf4d0cb  release/kernels/borrow.sv-hosted.log
9e4b10c351a101ca8ba9347dee218a7aea8adf30081869c02bacdea2543b132d  release/kernels/brs.by_instr.json.gz
53de8ab646dbb801e99b84940d3aff457391bd537c731c18ce2a54ec9024e682  release/kernels/brs.by_unit.json.gz
5dc140ea49c98a2c34b741f82308100619a4698b3734262ba4d3417c10d722cc  release/kernels/brs.ccvtrace
fcd91700239fdbd9dac9df127805106f37578b60b328c703bdbf84797f9d4eda  release/kernels/brs.log
e3c1cb3379580cf1aae44e8ddc8e846ef6fd661a573cfe0a8d4444b18a14dc56  release/kernels/brs.oracle.jsonl
f2eef5d6426a8604afc15dad416e399225a57af21654b670d62e03af93569d60  release/kernels/brs.sv-hosted.log
54373176caa9d7ef97bbebabb1c0c051e2200e88e6d014d109a6b1c22ee4685e  release/kernels/byp.by_instr.json.gz
f43c6d8d82b2aaae2a8e40a92da4f94ff387d5dee5086fbd80739eba0495db4d  release/kernels/byp.by_unit.json.gz
e8358c094777066e640565137d9fb8b94362ca96d2acb558cba7239260138cb1  release/kernels/byp.ccvtrace
89be1bd58b45079ce4e0e6a1d709319c7d3feebfcb5c45e188bae1388282002d  release/kernels/byp.log
5a03dfa4f3603fef49f1e3639e74e34152ca3ca5ef8e41eb959f8323040fa2d5  release/kernels/byp.oracle.jsonl
3a86be6e734b73a3b57e555b498c4cb8cf490d9884dbf5d3a5c7b023bf46e16d  release/kernels/byp.sv-hosted.log
5f42d0cbb73a20b28d5cd894ac81f3bc8b6ee807d889e43c22522b15daa2fe89  release/kernels/callret.by_instr.json.gz
fbf3713531a9dfb4cc0f6112c7fd6f36275fb35ccb0f7d3b12321799e2a93ae4  release/kernels/callret.by_unit.json.gz
e1e5f8d7c3c56e99e4bb9a9cd071d397dae08daf3aad4f0adef95e2f829593d8  release/kernels/callret.ccvtrace
7b6c500e44fef5f267b9ac4820a2c51d8f8ada16857564496544356825aea323  release/kernels/callret.log
9b1d1b50b527f732362f837250aa2f26dabf3e76e16a4794856ebd8f105635b8  release/kernels/callret.oracle.jsonl
0bac708e73b9042fcf9a2e38bf3ad5a7db56616019d8d8264bfe91736cb73159  release/kernels/callret.sv-hosted.log
f0aee04955a5ebd4d8fc55c7bb9a5e0a38371be98922907d593bb482e5028052  release/kernels/chains.by_instr.json.gz
01fcd02480d943b8e5d4a0145853e475227d2a6c0a294f3e5385ec51a3e63408  release/kernels/chains.by_unit.json.gz
94291c1a3431b8b84b1171b04f2fe0f6eb3300cd344c7e7e60928898254e9d63  release/kernels/chains.ccvtrace
9b998cf0ec83a7105cadaadf149b69ed4b3d32ef38d58ebeba51d579f9f65627  release/kernels/chains.log
26a4cc5c5524c7219d8706c2582c80357dea60be9d6ffdec99dac7d0365e2264  release/kernels/chains.oracle.jsonl
5e4796225cad4631de0f6aae1607d9aba5a511d13eaac00245bb0d930429ba78  release/kernels/chains.sv-hosted.log
39d9a5ed6ca2dcdb2cda8d73badbe868f6f0d99824ca4fd9eb8107ce9b5f0c0c  release/kernels/div.by_instr.json.gz
962cc2e3cc61ef516c3cc78f717cbc62f864a07020175d69b93a7d78930ba6f4  release/kernels/div.by_unit.json.gz
d4e3cf776f53afaf1f121e89f0ac7e7acf46db83e299dffc3a1f6992c2d0763e  release/kernels/div.ccvtrace
5bf8eaaccf348078a86d6c6b2045f6d7ea8695e7df12b885e1151d5b619f0d5a  release/kernels/div.log
71a567b85cf85622631490187563de9a5661099c78a590adff4ed0a0c3d24c16  release/kernels/div.oracle.jsonl
521ceeb1872d8a1c16d12c7b713cbe179dc02b43a08afde2caa658b6a808b0e9  release/kernels/div.sv-hosted.log
27d8b946a98f2c28536a7f1f9d0b10fcaa219d9caf5674e1308ee7870ff0eda4  release/kernels/divchw.by_instr.json.gz
3b5976469e62fa619de4bde9ed0617d0386cc6e65c4713567a698362205ac67d  release/kernels/divchw.by_unit.json.gz
4eb31c15341a73e98da915dbf635673fa48b66391cab8d59ed6c01b2e002da6b  release/kernels/divchw.ccvtrace
5b92766896f7f7ab5e314fb4c836a98f3fede3ab882917d95eddde354efc82d0  release/kernels/divchw.log
58a541797f7a2df0a1c7528ae6a3edec212db90c7d3eb20656806f38b5c10b3d  release/kernels/divchw.oracle.jsonl
b2263ee13d38874d9b675a720b50726e9d3d73634f0bf06f0db84419b19876fc  release/kernels/divchw.sv-hosted.log
354a0f28a0952555d49131ca796684cd13170832f90bdf2b88169eb1249363c1  release/kernels/divtail.by_instr.json.gz
390f7fc50978577ef625c07f03f33f516b96e2237f2246b6909f432976872d3c  release/kernels/divtail.by_unit.json.gz
038d13deb3b5c08bc95b16b8877467a9451dcffc9bc53d333486bf978cfb01d1  release/kernels/divtail.ccvtrace
c8fbb86ee156f3eba03a118ff281bbbee67380ccb51501623b9377b4fe61beb5  release/kernels/divtail.log
75f11a75c9b3b336e446140af4579f05b46c363a76b7aab3ec88154a07ba097d  release/kernels/divtail.oracle.jsonl
915fc074a6231c6aaf75ebcfe5db13381e9a5312cb6551f95f63a371af842ea5  release/kernels/divtail.sv-hosted.log
b25a1972ad890059407163e2d98659e88889c48011a2aecda6a4144a980f5d4f  release/kernels/divtail2.by_instr.json.gz
6af623ce369ae1d3ecaecda628a7f6355d0148e86ccd4aa682ae83cee52bbbed  release/kernels/divtail2.by_unit.json.gz
f5760eb6378cc178b8c80585c076b817040a0af3545f8eba2b17362e0aba7441  release/kernels/divtail2.ccvtrace
0dad5a349a52e577a1eb67fde21495e2b35921770c51acdec2f1cd0fd2e8496b  release/kernels/divtail2.log
b2db6b05eb6cf4a0a7677e31d0c6c2952d5cab49d353f0bb1883fe0b2a20ed14  release/kernels/divtail2.oracle.jsonl
21174c25d36c834e30aefa50a96c3f363f3e55f0b0b4131d2de9d0f06ea66ab0  release/kernels/divtail2.sv-hosted.log
4c3e071b75fa73311893f23b17c6984f76ad67c5ea9f9ff28b5a0e8499f8269c  release/kernels/fence.by_instr.json
c584e7a15181c2dd8001eeae7b7af3a0aa19d5b6d8cbf0efa12033ced673e54c  release/kernels/fence.by_unit.json.gz
dd6cdf6ee2f703f8646f1ad60070316ad8f7e38614efb690a7f3185649252bca  release/kernels/fence.ccvtrace
fe5a49e72d619b2a3a88aecffc29b9a6b6df02101e70e0eabdfbf59a3b6bdac2  release/kernels/fence.log
d1d40317f6cf5bfb430cda1f9c0ef676609e59cabe2a11623c42ffbeca93142b  release/kernels/fence.oracle.jsonl
4b6c6687777271f0b7f84a31ca22f1714fd8eef43c2ef58c4a605c6b4f853c9a  release/kernels/fence.sv-hosted.log
e109f987a8792aaa1d78ae680fa991da5f9c53aee93e335409dd89b86e8242f9  release/kernels/gather.by_instr.json.gz
b85827352983a554408efc35d6f68570195bcacc0a5ffe60232446a89e9aeac1  release/kernels/gather.by_unit.json.gz
9264d807aab095cd4ce3141f4fbc6a661ef5bd72ed384a647e735f1f1d294258  release/kernels/gather.ccvtrace
d4f0fca4fcebaca14bb9b03951c63ac21b5a171854c8b4cda12cfb2b2d5badec  release/kernels/gather.log
0413e781d8d6ff578c64eb1f800b7931e66f676d5cdabb97b94a4033e6037662  release/kernels/gather.oracle.jsonl
4a71819116c39d004f240b397e3596aa363438cfcf7306dd31eef4e4758c5029  release/kernels/gather.sv-hosted.log
0a4e3e8f76af5461a0a51ac1d9bb20b6268a7c3f2d60d1057e212ab38055f433  release/kernels/hit.by_instr.json.gz
c74cdf82d4445ed4c106c667896afaf23f9d74e3b3cba4e37771d527a578e78a  release/kernels/hit.by_unit.json.gz
a21884ff3a5bc45b0719725c1b08b9dafcb896df33e9129726b0a6f8f2f62c5a  release/kernels/hit.ccvtrace
75b66a4a4786b36fedeac055b493ee8b91234999eff47227edadb60f86253f12  release/kernels/hit.log
7ba9603e0088d9164de6528f16ef6a7fa9ce5821c8c12b52cbb3734e39b9fd52  release/kernels/hit.oracle.jsonl
422cc4a1ae568dfa3072a1e72fedecd2444fbe768328bf52886081bf63ff6c50  release/kernels/hit.sv-hosted.log
e296aab95127c8f45c89abd42993931c47d6a0aed8594cc583fc3a1304f5925b  release/kernels/lanectx.by_instr.json.gz
cd47015d32b267b46d61c1d0349ae8e25debb09260161810a3fdbd1e501f500f  release/kernels/lanectx.by_unit.json.gz
1162970d2d2720434d90c357c929e14cbbaa242fc271970fe5abf75e69ea0ae0  release/kernels/lanectx.ccvtrace
6c841c3febc6e69b975f5a8b2372b9387e9a25b0ba175778f395913a96d6e1de  release/kernels/lanectx.log
888551babf540db8e3025b82e65ca655013f93eba3c8a65689d069d52a7e6039  release/kernels/lanectx.oracle.jsonl
806172318079bb441ec8bf6ca5246feee592188f540d731ad73ec6092d1255ca  release/kernels/lanectx.sv-hosted.log
8a3b34e1b53a5f1e1fddf726121c3bd6db0dc2b56e31f4d9d64ab34949bee844  release/kernels/lanectx2.by_instr.json.gz
d3fbf1fc43538cfcf87145b5179dc6d7d4e8e976323fa33474584e8384136ca8  release/kernels/lanectx2.by_unit.json.gz
b1a396f8c11ef2be7709dc82936374421c94613cde531b4736be4947942e62a1  release/kernels/lanectx2.ccvtrace
644caa717cbc5ffc82ca7b7ac7b4c5cdf9ac030a8beb9e9aa08dbe16fc572592  release/kernels/lanectx2.log
45c13056dff5c73ed0c9ece56cc36f929bf335322193c7d5eb38710b1d1dfb02  release/kernels/lanectx2.oracle.jsonl
1f37782f5654f97e8217429e7bf010621ea31bb1b8a33ea2cc7eaae771dc59cb  release/kernels/lanectx2.sv-hosted.log
99f5fe35bc5bb569841ae0f93efc71a763b82eaadc033fdae098017557132d09  release/kernels/late.by_instr.json.gz
cbf4357cad6de39cdcd458f59d3231537ad1fa70852bfa246ac50d5f7ee5b93a  release/kernels/late.by_unit.json.gz
f4fc47fe3ad032977a338a3981b96518a799d313c6ccc4880908bf3646f55aa2  release/kernels/late.ccvtrace
e78e405835d33dff5d2d9043380e1f64bc864f373a1a5cafef413a2d1783266f  release/kernels/late.log
86084f6bd747a2cf32acbc0ebd96ebd3e4ef2d8d9e21be49e3ae49290d7927f3  release/kernels/late.oracle.jsonl
7245854dfe2e8d5285ad80bbdea95dfba10b128aff8938e7424b0a933d84f5c2  release/kernels/late.sv-hosted.log
20c83b14b576e5b6cd72f811362c6656d1f319a76b5c10beca95a58f590425f8  release/kernels/ldpar.by_instr.json.gz
bec0dba041fdf5110ebe90b204d7bad27487488229773bab1347bf15ec7e61b1  release/kernels/ldpar.by_unit.json.gz
859d131606c248d7feeee7753a2df6702437f1bd1b61f3073ba90cb84b7d3eb5  release/kernels/ldpar.ccvtrace
3e6e4135b8389ed3768b461aae465ddbedd8efec05b2c372d64fe77096730d91  release/kernels/ldpar.log
8ac08538e9c807637babd61b31e340f7461878ada31f0c0b83cd66331cfaf486  release/kernels/ldpar.oracle.jsonl
3db74fa02158a8cd7bc2c20d4f77b82ad826f107a26a5c9098c9e4709970dbea  release/kernels/ldpar.sv-hosted.log
0ac75ce539e13a4d9159feb3da4a932992bfbe82179774b8c16b4f6bee937016  release/kernels/lnorm1.by_instr.json.gz
7738bce46e90528e1904a8ab6dad728ff93acabf890fc8b5567607cbddc47208  release/kernels/lnorm1.by_unit.json.gz
3b9019154acf4dc469bd2911839e41b29723b946f8d279c7c5376feee45f1dba  release/kernels/lnorm1.ccvtrace
6fc5dcb8b77b0d066a07debfcfd0c26ef50fa058f7b8e94afb72af182ac0f89c  release/kernels/lnorm1.log
a8d85811af988a1b9fc00db1517300af3d93ec8e589e403d3b9113fa9e0ffc86  release/kernels/lnorm1.oracle.jsonl
93d6b237dc7927042692865fd8de6f036f03531352f7291904bcff40f9fb6e19  release/kernels/lnorm1.sv-hosted.log
77fda9bde8d58f575ee3efe4155e0696c22984ba06f6e08a90f896083349fb37  release/kernels/localsp.by_instr.json.gz
4fd3ef73678a5db59c8df70b20934d3d4c13715c7f1987dd4d0a9e52f2250125  release/kernels/localsp.by_unit.json.gz
35bb20753ec5a7b38421fff461d40e7f2be0ae2fba0c47526ebd379fc06608ff  release/kernels/localsp.ccvtrace
32d5a644998c97ae739956a7f5c456db798b0119c2aed0b07db325404212bb9e  release/kernels/localsp.log
55e3c9f36e7f7d38c0ddd38903aff4bb4509ae862015c592e6b937ea258042ca  release/kernels/localsp.oracle.jsonl
2eebbc76fdc58d1c545abe6e80129f9ec39b44ba55222d2f9949f11096d4ebce  release/kernels/localsp.sv-hosted.log
ebb9d874ca591b6999d2c4a1e53d540aeb37e872c30b5c5ca5f58eab106c6788  release/kernels/loop.by_instr.json.gz
1727550f797e3a9ce81c0d3a3fdff10c39a646695e9aa1b4316f289a54bb8be0  release/kernels/loop.by_unit.json.gz
d97f745235554b110bb5181b2194e2a3227871552817968e4dfba9de82d8ce40  release/kernels/loop.ccvtrace
b04f06a4fa31bb24d89e4d70ef906d0494f64b663163bb7817ad31b816f0cc3f  release/kernels/loop.log
03ce5920c06c93e93516d8e53c3f7169f14e3593de204eacceffc0b8a3e32016  release/kernels/loop.oracle.jsonl
02f5178a02882ce8d4b0b8846dfde981aa5c2edb296e5cdf4f097261cbb51053  release/kernels/loop.sv-hosted.log
4a4077b99c37a80505baf147edcba4353153a5d18c9aaf4a6f5bab9174415aeb  release/kernels/merge.by_instr.json.gz
63eafa78094527a7ae5295a9673fb4015c50a9daee246b1dfe582de174b91d2d  release/kernels/merge.by_unit.json.gz
fb3738c6d842e8baf329dbebf4968b4945e0a3fc632251d675b1b2e098ab48fb  release/kernels/merge.ccvtrace
f8d17ca3da5849bde321420f242c0d38da7622e0fcdb8502c9700bcb49d3d6f3  release/kernels/merge.log
f96d28815f8756b1f5a45ded53e6170883d2dfa10f9eef0d14b8050b1318164a  release/kernels/merge.oracle.jsonl
a3178ba222c4d1d865ef5ce669c88193df3a151bd658b4ec5cc1caf3ea418a9d  release/kernels/merge.sv-hosted.log
f0564ca84dd503a2f678d42c498d4ee831005e9416a78e0c8b0b7e9beb443fa8  release/kernels/missrun.by_instr.json.gz
d875d8e5d59a5e644a1ac3f30ba2bcaa59e8458027d5b155fd862d9eb93a0ef1  release/kernels/missrun.by_unit.json.gz
95dcccf10f536cd7452f5d2e81951df113faa65567f9f0d4d0c5dda4fd3bb89b  release/kernels/missrun.ccvtrace
aeae866bbba55da369e0922633309fe44a0049fc68fb8041213521dceef32bef  release/kernels/missrun.log
531bdaf281e5590774bd2775427f25e4cc0419cf8e3d5b6999843ffe9ef87258  release/kernels/missrun.oracle.jsonl
18c4ac532159888ea2fa5dadbdf22335be6fec38d3caa5354338fa7c0f56d968  release/kernels/missrun.sv-hosted.log
a5f823bff0869f9b200108d0e704a60803e25063c61b1e61ee8cb4aaafb1e651  release/kernels/mload.by_instr.json.gz
a10c72a224c4d37978b8a7a40d083422a51edc53e51f2e2b17f4b4f976c3cc24  release/kernels/mload.by_unit.json.gz
a59040b63ea89f6d77073f9f1bb04dc54e7ade463c043d66b0123b1f7f0bb4dc  release/kernels/mload.ccvtrace
9099d27f3567aac469d58e2cda4614cf82704f44659db51941c64760f4f36f44  release/kernels/mload.log
8000e477b9a95dfb9f0af964e8346acb9d36f1358fd06ffc4ff7cf599d2b8868  release/kernels/mload.oracle.jsonl
2c6318d2b4602b499da044dea6af9925e0590cdf33867304f9393782c1b9d64c  release/kernels/mload.sv-hosted.log
4bfb29c8b26878a15da8444c666a4ad6f7c4352bd0358cbab19321feba033928  release/kernels/mlp.by_instr.json.gz
4f81ee0acdef5749a8fcafac8dc5993277a62114027a36903afea1a6bcd91364  release/kernels/mlp.by_unit.json.gz
0b70f24e8ccd473fc49b62f1ef3a71388265aafe5823ca8528243e53bfc4b8cd  release/kernels/mlp.ccvtrace
7cfb7d1c06bddcd1bebb1167bd6c6660d2ed3bf4d7cc23a01dc47f0d4c3caf79  release/kernels/mlp.log
138d282f88d56c8ad648a91af0a983254b55d9fa22942c00d47b327f516a6e44  release/kernels/mlp.oracle.jsonl
ec0d3a4976cf11fceac72e02d03789d2da8e6f70161382dc96359a373593c33e  release/kernels/mlp.sv-hosted.log
272e6ad342697f43bdfa9733f68aa0e70352ec5023fcaeabefaec09953e0edab  release/kernels/mwmiss.by_instr.json.gz
9da6318eb62a0d62940121ac04dce67bc3a12a2916a9983e96c035a76d6b4f62  release/kernels/mwmiss.by_unit.json.gz
bf58bf5dd2a060867fee471eef821369e5780d47733556f608fac4a4eb24cce6  release/kernels/mwmiss.ccvtrace
270151e00848ed34edc207bcfd2f1da5fa3e2895e9c126ed21283b647c4d66cd  release/kernels/mwmiss.log
8abe8e8997456a2a6711ee72da54d854b24e20abbdab28e4b7271c0d28418de8  release/kernels/mwmiss.oracle.jsonl
c5834aa06ecc5f732aa9afce42dd21dbb03cc09a593b3565901f0406f64ea387  release/kernels/mwmiss.sv-hosted.log
a99c55575b2b8edd5a57e97c293f914a931d29723fb424b6e0cac4911c752259  release/kernels/narrowadd.by_instr.json.gz
cc65027da8858e0b0dec48312797e4140b74710d9f7c4b02ea855f10982b554a  release/kernels/narrowadd.by_unit.json.gz
de75c7adc4ff03cb0d5afae233a91376988da4d349fa455db94f8ab512f4a4ae  release/kernels/narrowadd.ccvtrace
6a32a3576a92ed994a6cf77b0a337ba9b58b816b18b4782e203532d7c40d6145  release/kernels/narrowadd.log
40a2cf629853dd404bb06b4a07e35abde3d12efc13f26ffe28f923daf2994574  release/kernels/narrowadd.oracle.jsonl
2f079ce88f11324531da127929cf4e86d883fdb31d328519ab638b339e0bcebc  release/kernels/narrowadd.sv-hosted.log
5ec71558b9c5e74e15dffb906675b539e6c87be896498f1b631386837d6962bd  release/kernels/pguard.by_instr.json.gz
7d852f8b8de91025ede4a9d0fbac7cc74bf003d902d98aa60974c9ee6a4cb19a  release/kernels/pguard.by_unit.json.gz
b84232a13c63382123e18ec951dd642cb132eefd21b44fff8f49c69c7339a3fd  release/kernels/pguard.ccvtrace
e8f7bab52a4d41b10a8eeea5fbf91555a5ab551bba3432408e562a6808ea183a  release/kernels/pguard.log
690e56f1cb8d97cbf67124b7dff3ad0a90cb8981814cd1709cf0cd0e035b3bd9  release/kernels/pguard.oracle.jsonl
e1b3d05b80d05a6984a3c3027b50113c563894dd2293b452e4b49e668c648c64  release/kernels/pguard.sv-hosted.log
abb8f42125c008aeda72b1cce2019e69d420d3f37b24b5bdf38d2b6803c669b3  release/kernels/plog.by_instr.json.gz
82ce372217248fc5adaa1b02536e00fea69ac106fc56a3347611a2efba11d6bc  release/kernels/plog.by_unit.json.gz
e32ed8b48729d559c9d9c92968577d8f87099c9bea1562de23e434a7e966bd69  release/kernels/plog.ccvtrace
cde64746d910ab39cec1ff6b736218cd460694a8624fdc8a03b8b54f478d279b  release/kernels/plog.log
c230f13f2e1082b306a9c5ab7809ff36cf5c1b2e47dca6b7a71f741524d403f5  release/kernels/plog.oracle.jsonl
cdf7aa38655886b49dff03536af1b23768b6bf822506c4b63d50e75b7e2c231b  release/kernels/plog.sv-hosted.log
a7d260c263c66100b45843ac2a98abfb6874655b66213249f0a7b004e4669750  release/kernels/predlane.by_instr.json.gz
73809681ad9b138d67965f14d21cbfc50e22bec66910252c9ef7b879a85c00ac  release/kernels/predlane.by_unit.json.gz
65a59e00054daf4f267b6259529f9cf98c780e2dedd4e36a663c717a18b2eeaa  release/kernels/predlane.ccvtrace
1cb8ec30517a04f5d717d8797ce9ce1dd1c92580d1f87801eab0d037f9961614  release/kernels/predlane.log
c45f4177b9e84fc8a6e36b13534a0c7636eb30a3f8531847100ce5e23bf404b1  release/kernels/predlane.oracle.jsonl
8874e8bf9f7da2c1d76d60a46d9119856dd89d4c24f4903af820698a7b586b41  release/kernels/predlane.sv-hosted.log
a8660a01e0a4a8efa4552bc61e82912b49015534cdc8cad5fc8340a839f5b475  release/kernels/predmerge.by_instr.json.gz
fbe1f5eed742bbe53d4423742f66b82e5215a44b88732a2eabab093b02fbcb5d  release/kernels/predmerge.by_unit.json.gz
3e071cccb92f2701bdf2a84ba1492387a2703453b3352625c3a8d729f61e2e1d  release/kernels/predmerge.ccvtrace
ac6873d8042472952f98f914b7ad753ef71e651f9a1ac344ed8c66a8e22acfc9  release/kernels/predmerge.log
6c737c49434bcd08e3e0814c8b1dbf15c586ae74f7929ba3148ddcee2c62c845  release/kernels/predmerge.oracle.jsonl
8e48d61318914ff556d32552b2f2c21414546c0533178db44c8705485572063f  release/kernels/predmerge.sv-hosted.log
1e6bec554477c2c821ee739bb3f5869e95616e5c0a68b1a28c36f9cdc4f910ed  release/kernels/predspill.by_instr.json.gz
ff1e550c19139e3ff79bdd6e29de68526503c0b9f0f7ef994ce88485a7a1c346  release/kernels/predspill.by_unit.json.gz
75f6de4a014870e1f3915b29fec9e8b4630ab3fa9088d1f2fc9c2f586dc90132  release/kernels/predspill.ccvtrace
67a09735d2d3341de2a1b0032c0c5d30349e38bc4d9595ac3c7868358bcbfdb7  release/kernels/predspill.log
b7c84c6478117ffa0f06da0e6ad1e4628e2683426a7911080810e78e06a5242e  release/kernels/predspill.oracle.jsonl
81125868b200ce0048655f4936a36f63a71fb73739b9f9868880630c82747ecf  release/kernels/predspill.sv-hosted.log
07feaebbf81e97ce77a64c43c37296a80e7abedcdf64fcbdb7ed8d4914a4b804  release/kernels/predswap.by_instr.json.gz
d6a9cf0b9d0526c60cf7440b6232fab8ee12607b18c7c6945ffefb3da6e73db3  release/kernels/predswap.by_unit.json.gz
ba10f490b17208ec7aea633e8a7b16c6059c8374a941796b8315a4eade749f19  release/kernels/predswap.ccvtrace
886a3021139144176557fc372d3287f9707b62f18a62de3dbc02b081504428ce  release/kernels/predswap.log
a6d4f7ed517553816d889c7c9eeb6bcfd1f6c973fbf682ecb69f3c2de619f7bb  release/kernels/predswap.oracle.jsonl
24d80c295e4194fa279147dbda69d18d6bc6ff951e695688b6a9ed7000dcce33  release/kernels/predswap.sv-hosted.log
56928deaab45a0daa627ebf497a2ad0ec01c1df852d3f3a79a8dd262bd0095a7  release/kernels/privwin.by_instr.json.gz
194f6c63d9b24f20338f47e8b17a6c4733f17e1414a199c3dd77222bf11343e0  release/kernels/privwin.by_unit.json.gz
861ea297727c70b497b08586b11a19bbf1d57faa8017113901f455602d2eb3a4  release/kernels/privwin.ccvtrace
42fd8262ee50eadfea18d8add8570c8a694b69be9e3abe1c94cb8de6c13050b4  release/kernels/privwin.log
861f686fc4480363472908d679d8815e8c957d768e7ab32c826930527b0fb7a8  release/kernels/privwin.oracle.jsonl
3fe5634ba568568b4e45c8fdf0207b0cabff03d6ffdcef2047f323185b2195c8  release/kernels/privwin.sv-hosted.log
1dd3985d06e94ceef73ba5b160d5f772f86fd4f5ca324e3146531ebe1b3086b9  release/kernels/provswap.by_instr.json.gz
7c4bd7fe8cf0e7840abcd6accd4401e10bbe19133c019b4b2d9ed985500a7d09  release/kernels/provswap.by_unit.json.gz
2d8fa3a3fae9bcaed3c82f6aed6f17bfb22492c1448d16b2ee2d3f108b8fb0a1  release/kernels/provswap.ccvtrace
93fdde1ac3ddb88648967163c59afcf9d0266ff755f960ad136384d8a34064d5  release/kernels/provswap.log
c9c32a793d54cc7401477f582487f7e8b345b2669a75337b8d6327120d98e5dc  release/kernels/provswap.oracle.jsonl
9bdf0aabd7e5ea92fb3f2aa9a5501ea36194de507361203f562a2139d8166d23  release/kernels/provswap.sv-hosted.log
bc78212fb3eb25a011a8123c4c1f4f52a37579dfba964059b435dacf71198f47  release/kernels/roconst.by_instr.json
66b59f460abe69a673e77950a40ffab16961f574aadd62b81c50d75b9dc421c5  release/kernels/roconst.by_unit.json
a4285881bc085f22a043d9584b7b6a66e0504beb0e0398a7e1d188c3a2814147  release/kernels/roconst.ccvtrace
eb9ed3f3498a72dbce0287767d192fa90e177b792900cabd8f5ad09394f906db  release/kernels/roconst.log
8087c0671de620162881aecd38cd6114b78e7be6bd71201e3ec02c9a2e2e750e  release/kernels/roconst.oracle.jsonl
1cf32d1fec1f1ab86155526da25962056593f1a8e62e3a348fd6248a0b27efba  release/kernels/roconst.sv-hosted.log
97f33ebd4e213b24c8fd8e9a1a66978cbec05d458b20e52d6c64cb884a9eca98  release/kernels/rogated.by_instr.json
4c64b863a347d7c1340eb095650541b00603520c14239f67615787eb2aff0fb5  release/kernels/rogated.by_unit.json.gz
033ea8958e7c63791199d5196345ca159653026ab225d55c626e70962aaf1d5c  release/kernels/rogated.ccvtrace
af1747c724f6daedcee8e44b309a394d8aaa68d2fc3cde03a431e16c99461829  release/kernels/rogated.log
7cd02bd4cceec5a044d6b4d6a80df1e68ed0ae71b0b2a953143636d5b809ea6c  release/kernels/rogated.oracle.jsonl
cf2b5a0395592bfed3eb76cd516b7898047892ccc3c914d18313984a4c01f3c5  release/kernels/rogated.sv-hosted.log
1f3f9b8bee86f396c7199481fc70597eec6490fcb324538bf501480b4df925bc  release/kernels/rokill.by_instr.json.gz
f2fba3cdf84ae3803a4fbe19e1ebd6e3a308d7dfd51efe2561ece0ed41c59487  release/kernels/rokill.by_unit.json.gz
52274cbc695cb5cc6cf85af0fb4f07021966f1b2afca2dae89239493add40d9d  release/kernels/rokill.ccvtrace
3b511ba7a6aa9a955b81a78c22a7c0e54652f11cb5a4da9a6c3c241a4afc15a6  release/kernels/rokill.log
94efcef96af469a512d346ce61623980fe86383188eaebd55120f716db596f14  release/kernels/rokill.oracle.jsonl
a54633b578d159a06cce53dd668f4e18b99dba554793a19749e69cb59eb69e25  release/kernels/rokill.sv-hosted.log
f41e6e2e961cd580d1cb70c2a7f4b0d5a5009c7d936e611e401b661c48745392  release/kernels/rolaunch.by_instr.json
7deb59c3a34a6ad597d362605214b2f8c5608fe4b96916c8fab8e2368db4c3cb  release/kernels/rolaunch.by_unit.json
03c1532e55928161a52bd3a508207e2590d1e4a67091d7be62e55942c13bca02  release/kernels/rolaunch.ccvtrace
0655cff219a34da53f691c62d67e0d5a1534c79d593d1a70ac106d8e09988c27  release/kernels/rolaunch.log
e7dad585c3e70615de04330fd03f4f282c29a005dc1732a35655fb261d51139e  release/kernels/rolaunch.oracle.jsonl
48943c20e15479ca721eaf1af633f7919100c7d491da4c496e6bb9699e52d44f  release/kernels/rolaunch.sv-hosted.log
bc78212fb3eb25a011a8123c4c1f4f52a37579dfba964059b435dacf71198f47  release/kernels/rolimit.by_instr.json
fb382121fe57e8df4fe50333b431a10ac569d036916a50f7a5ad605d71e79a80  release/kernels/rolimit.by_unit.json
c9ff94e1b40948672222ab793c3a457e9c0e028ffb6c9685fa372aa1ae7bc2ca  release/kernels/rolimit.ccvtrace
77407a923cd14faf9efaa7fe990b2bd844872a3a1a25b654c62e84b32e8d6734  release/kernels/rolimit.log
1c5bc0cb8e8b2e69505fb5a551a16d5d10c56f232b88da7a27e336ad7d962de2  release/kernels/rolimit.oracle.jsonl
a86aab48692dcfe0fed1a6863407ea5a2ddf0cf9d95c6d206c5ef46a638d5553  release/kernels/rolimit.sv-hosted.log
f27d51c262816a45ed9f3cc579e87815c4535285d166795aa870c7c787c36af6  release/kernels/roload.by_instr.json.gz
cf2eb4f197ea42ad6d9a12786442a50b8ff86af10a9e8ab391749d4ccbd5ebd3  release/kernels/roload.by_unit.json.gz
5940c2a8eae5995fa7e4b01a1bce3dab6e432332d54fd46c30ca3afe3c77585f  release/kernels/roload.ccvtrace
9602b313459715ce29b3e216b062add2645670f18db21b1c54690746e09324d8  release/kernels/roload.log
f7c1309cc9764769fb5803f6fd0f2f5e1eb418f2d23fbe5e17cf5f9106869fdf  release/kernels/roload.oracle.jsonl
eef1750733ab145be737e14df96a19f7c81a6def7f307a4bb75c0e07af9d1e15  release/kernels/roload.sv-hosted.log
24838567034768a1b293d735b331079acbb728fb3075dde681256225ace956bb  release/kernels/rope.by_instr.json.gz
fb9960f43e4b6ddf5882defbfbf550b08f09c8aeb29d1a659a3d2d5c3afcdd38  release/kernels/rope.by_unit.json.gz
6613dc39443c01c9d62f69d2e0eb0f0fe48077e0e3afb498c5790229edf7ce8b  release/kernels/rope.ccvtrace
7ff5d4cb309a19f886fa8c7c735a0f354c69b2b7ba24489d16ecd549d4bf7efb  release/kernels/rope.log
d55f9efae392dc8877c102c01c0810e7654b666b6ede386328108164c6cf88f3  release/kernels/rope.oracle.jsonl
ff9f5d744acd545e73e2a154901f9273c85c580deccd10cad8902007dbe7be9a  release/kernels/rope.sv-hosted.log
fc44faed623cd44f2cb6039e3a3242110445b7e5acfb2a650989680d2032fba4  release/kernels/ropediv.by_instr.json.gz
0a9bad1206ca7035abd707c93db9b8cc06babced2db53b6331d0601a1947f3c5  release/kernels/ropediv.by_unit.json.gz
1233cbb23e9b7eae0e1cf83abcceb274e7798a181717e8cf12c935b18a7182a1  release/kernels/ropediv.ccvtrace
a4b04f9afafba4d8e567b5614ff84554adb1c7ba4b1285a4dc0d94ed0258ac2f  release/kernels/ropediv.log
10c0ec6ec18b7b44638c790033109198c079d07c1537bf193353ccedd00a920f  release/kernels/ropediv.oracle.jsonl
a0bd42f834c73759d76703e9db1831182b0cdc75272ccd89ac4c510b0f44e050  release/kernels/ropediv.sv-hosted.log
433bf3c614de6be0782ab5395124edd11531f10af48eb7f19be8241e1a6668eb  release/kernels/sel.by_instr.json.gz
548775216573bafd9b3202ecb2d35f2c6aae5564608555c43efc6b7d201a1cbc  release/kernels/sel.by_unit.json.gz
d647e23e18e16512cc2061f4c5ef8fde687a47a2e11482fb7dfecd77a7745778  release/kernels/sel.ccvtrace
2ffff753751a9f25a6d5f4ed8905ade2ac2da89b9c661e8c359cc64bc84af1b4  release/kernels/sel.log
87f6a81e8afa004c8039bf2f61c90176fcf29ab29bb17ac44aa016a5cc8438fe  release/kernels/sel.oracle.jsonl
022605afd3320b220c9e77059b63dcfc3f70206ee5a39383b17b5a235cd7a9d9  release/kernels/sel.sv-hosted.log
5dcd7fd06de3e951b606b2280cd823c92f97a5e3dd3514040aae9afc166a5aa0  release/kernels/sized.by_instr.json.gz
b58f6c3dad01117242db46be9a1c88718aa432bca3fe47c8ecdab4ef3d59387d  release/kernels/sized.by_unit.json.gz
2419b9d353fdfd79a2c63b22c1e8b91a98fe433b7da6ca2c3df50baffbd8a0c4  release/kernels/sized.ccvtrace
8fc106e9a439e79c9dcfa643929482e04109c6a2d9e2530b65a6de918fb7780d  release/kernels/sized.log
36d903ba1618bd1faa437c9812a6ee6c0c966a63196c796267d74bf2695ebc3d  release/kernels/sized.oracle.jsonl
7f6c7983492ff60f95741c0fc966d011f2a5e38adf12e3b52c9f0207a29af735  release/kernels/sized.sv-hosted.log
514afe4c8ea9b1552e7edbf4b5e91130ab94100b6ce7007996c51be2212b5758  release/kernels/slotform.by_instr.json.gz
39c5cd8894ace538ca7215232b711cb4dfffdc44afefee0178538aa9dc8c50d3  release/kernels/slotform.by_unit.json.gz
4ffb5ac64bf609700dd0659c0c4393bc4571ddc033ceca707daa5a047068634f  release/kernels/slotform.ccvtrace
2a8657d3bfff91176ebfc4fdd18aa6cc529d8fcb93ce6e0b10d1a8f3c0d4f629  release/kernels/slotform.log
8b61db7419b18cea8a646fb628218447e72e84a18a9891ffb73b441736138ab9  release/kernels/slotform.oracle.jsonl
568d4176f032944ef14e261e6fda3f59bda04f1f005c042f486e61945fd2209f  release/kernels/slotform.sv-hosted.log
784ddeea8e003ab3f41522219d20bca91890abb17b63e7c787cc48c7f62161be  release/kernels/spinwait.by_instr.json.gz
0501668d6731ba0ae789bb19ede3cc5b2873d72f5bdbfb224d324647afddb3f7  release/kernels/spinwait.by_unit.json.gz
11b2ce9ea1695c9698cd05836e17ba1d27993c2b93ffb4367499d3d83ae14bb6  release/kernels/spinwait.ccvtrace
a30d13543aa58703b87bc7443487d1b08cd6e4fe47d9d7577666d7d0e9be6829  release/kernels/spinwait.log
868920637236c878b33779bd450439466fc3626996a3164573dc11d437d5c709  release/kernels/spinwait.oracle.jsonl
6e9ed26a31d489480933aebada352890a401cdfced7cb4be5874b52ada8696e2  release/kernels/spinwait.sv-hosted.log
cf8f7fbdf1c20c8eaec1251be487b3dbb557f038d5fb59486c3165cc3cb5af59  release/kernels/spmbank.by_instr.json.gz
f2d7e7428786e7f51dbf7421146260e21df60fc6f496300645fd55351605e769  release/kernels/spmbank.by_unit.json.gz
db0e8c273eafc33c29bfa53c7a6623d8a9d1e5c5b3bcd0729859a0cc6dd4a189  release/kernels/spmbank.ccvtrace
761bb1e0c7d7df7629144f445c4200b04adb61be28b6d7aa58e705ab8316ab8a  release/kernels/spmbank.log
3af490cc37d7a92dbe719b57de216b648536eb301ff9d13de9a39f50d150d725  release/kernels/spmbank.oracle.jsonl
0b9f66d5fc2aff6b604b0f30bd0fe42b424fd7851d03989d323840809cf431b1  release/kernels/spmbank.sv-hosted.log
9519ffd40dcac5cedebb92e7e9c9bdf96e1787f4b82876e9a480cde3b015fd81  release/kernels/srd.by_instr.json.gz
c23da07a095440eb5269ea91d6e1893f1fc83db16c57766c40eb26cb3282998d  release/kernels/srd.by_unit.json.gz
0de6fcb70c02376f30c7eed67f0cabf4cd00fc874e9d95f24465e7d79129b3e4  release/kernels/srd.ccvtrace
7deac1f8f9838907e6a6f3870753c7335c6201e78fb87421f03a6b74dad0e4fb  release/kernels/srd.log
b08eb5e3673cac7eebb8b72af5ed3783c8e70a9e96592e76bf3722551bc79473  release/kernels/srd.oracle.jsonl
3c3e2f6ab4a0e61c448f306b81235d1f0d6d843704181ffe821e2ff0562d97cd  release/kernels/srd.sv-hosted.log
44751ef3a872fe7050e134d76ea11094b59ee313bb596d8ab14ca1ebf71ef6b4  release/kernels/stall.by_instr.json.gz
f1e895d89537ab4278126f663ae7be6fb0d293efaf44799f61bd55063791f24d  release/kernels/stall.by_unit.json.gz
31de6d003020b11ea8584ad619db344145f01e01a531105af995c6143075253f  release/kernels/stall.ccvtrace
6254c1624e80252aafdbe7e776953583ac0bad2195c5d615509e1edfddf36600  release/kernels/stall.log
500db2c482b07a0706583422cd68878301d0146c1f872ccc1f11bfdcf5c993ef  release/kernels/stall.oracle.jsonl
70ccff2f9abea652f146ba5a38fcca1bcc16b023db81ac9b48a427bfc9fcbc32  release/kernels/stall.sv-hosted.log
ddf3736df77e7c956459879e11d30fad249f2e525109521e39a731b62257c8b7  release/kernels/swap.by_instr.json.gz
b4ee27be26341efa43a414381a758afa45b98543cd3ece34d018df9874376de7  release/kernels/swap.by_unit.json.gz
98e5250ea60a91a2e8a4d31e840a523ba270776e134dff62868d4060cb59ef1e  release/kernels/swap.ccvtrace
325dd5d3ae702a740cc903bf0589707a2835b952bf851fd01c01dfd74abea113  release/kernels/swap.log
3658a26316c1ff7bc1744304a42f736e930fcde2865c8913e6cc67a22ce96667  release/kernels/swap.oracle.jsonl
674d521013bdf6f1a892e17b19d73b01eb3cacf6622041cad29fa30e5a754826  release/kernels/swap.sv-hosted.log
10153e767694442d7f9abc041fdde5721c7b1e940a11371b1c64e16fcf4fc758  release/kernels/transp4.by_instr.json.gz
492792c20c55326e89dda8175264f20af75641adcf2d98332b42cca1111e38fd  release/kernels/transp4.by_unit.json.gz
d0288973fd92b62e826d7ca04a5751ef239fb924e4e18ac244101ec20479c212  release/kernels/transp4.ccvtrace
9b0489e5697e48a293dc6503a7b63a1920320f7ada73dc393009227a8c56f960  release/kernels/transp4.log
06396ace3ac19677fd39c700e408606e5bdbacb24997d663bbe8872e63dd74fc  release/kernels/transp4.oracle.jsonl
f3324b0e9e71026197450eb8d8b2d776d22caa44201c2aec532466fa91855ecb  release/kernels/transp4.sv-hosted.log
0ddb4f78af33964de3096cd03c007eed5fc918c5ba2a8a40330ea2b20946f5ce  release/kernels/unal.by_instr.json.gz
69024669c981d2de9b45b6ce5e27005e9e9dc21186dd3325873f74fa453f3b67  release/kernels/unal.by_unit.json.gz
96227d2f550b50685353013980833df74e6e32c1b243ab11c0247caf0bd95e0f  release/kernels/unal.ccvtrace
5e819dec65b50673ac6121fce6719df4d88be72143e4b9f144c9689b5e729f55  release/kernels/unal.log
c3d484bb160657a563df983d9a2532eac27f556636617960aa1e72183ac2b299  release/kernels/unal.oracle.jsonl
6a76e0f123d592cc79e939952f38c9e79f99e5aed3298970d80d00b45725a5f9  release/kernels/unal.sv-hosted.log
9564110b8d258cbccf50c6119e6ef5e3cc6e9c2bbedcf038526551666d9cdbe8  release/kernels/vadd.by_instr.json.gz
eae28082eac1e6955299520b5c4023a5e853bd9ac1c1c07412b0bf1111b2bbe4  release/kernels/vadd.by_unit.json.gz
ceabf8fd66127f2fb44be921451fbb1d44658725452efd82cefbf5e4f412af3e  release/kernels/vadd.ccvtrace
ad45d6e6d0e07bc73d3bb634c9d44b7b2de3af3d6c5aeedb6dca3f1866694ad2  release/kernels/vadd.log
0276b6d0611a4bbcdc004ab3987214aea138245bc7217504147331689a9c0880  release/kernels/vadd.oracle.jsonl
7281823d0528822b772f8a1b8bbd734ac3632733efadbe279f38c5cdfec4dfd2  release/kernels/vadd.sv-hosted.log
0b4b565bbd3fe1c1d360c4a95958a99d054b3d7fabd6a4c3a7467d415e5ea0f5  release/kernels/vadd4.by_instr.json.gz
d5f4d7afc51c8fb6ca7c4b2580ad0a7522eb48eafefd5023e00a7f82af3558d3  release/kernels/vadd4.by_unit.json.gz
6fea84732d60ebf4629c215114af5415cb3f386ef71f38f6bb503e52c4bd1b56  release/kernels/vadd4.ccvtrace
20e9ba1ae61b40c45ec387ec0f9964ba3bf8b03dc535ee570be9881cf621d6eb  release/kernels/vadd4.log
225aa18fc9f38aa9ad615aa11de254337d59fa705877553d873062c68366e0db  release/kernels/vadd4.oracle.jsonl
986724233fdac78736c790740ddfa2a286e33d29dc843ab72c10cbe6d65c9e33  release/kernels/vadd4.sv-hosted.log
b3c357c2ccc2a57cec98d3d254e06ceeca21d87567e7a05caf4708e8d495fb14  release/kernels/vaddslow.by_instr.json.gz
b3201f9ee05c7d45603e7dc7f2d9a043afa5315f05d05f0e7271a28eab4c3aff  release/kernels/vaddslow.by_unit.json.gz
e1c7ff119caa439602b0926aabcda0d2d1907861a3d0c780857cfeb2c239151a  release/kernels/vaddslow.ccvtrace
5fb43ad1d163320b67b762ac98f83d174ac56c3f189e3593e7780bc84f061ba2  release/kernels/vaddslow.log
e9e6218e8b8450e9f9ff6b39d659c994a1e51c527a0c5bd10d18b5658ae0e344  release/kernels/vaddslow.oracle.jsonl
61d3a3ba8a925708cf46c5de93e80a8401810d8515f10eae477ce15ec5ef0108  release/kernels/vaddslow.sv-hosted.log
daecc8ff0c20aa022009c46e4d085747c7cf1c3dc53051c45c16105fb67896a2  release/verify.log
1f3a2eff14dbda0754e19cbf72bc5003c950fc7d1691d527ce3a8d427fb583d7  release/wiring.txt
```
