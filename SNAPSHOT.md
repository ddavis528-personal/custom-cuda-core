# Snapshot snapshot-2026-10-21-df67b7c

**A generated, read-only snapshot. Do not edit or merge it.** The source
is `claude/custom-cuda-core-infra-6msg93` at `df67b7ccf83faeb11a6a751272075d59bd1450f4`, and this branch is rebuilt from source by
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
| Source | `claude/custom-cuda-core-infra-6msg93` @ `df67b7ccf83faeb11a6a751272075d59bd1450f4` |
| Built | 2026-10-21 (UTC) |
| Gate | `tools/verify.sh`: PASS |
| Compiler snapshot | custom-cuda-complier `release` @ `7a28c679ebf1aca8682b34c60971b79349a53245` (source `43a948add98563fa6f78792dcddf9d41b100193d`) |
| Verilator | Verilator 5.052 2026-09-05 rev v5.052 |
| Icarus | Icarus Verilog version 12.0 (stable) () |
| Yosys | Yosys 0.33 (git sha1 2584903a060) |

## Kernels

| Kernel | Result |
|---|---|
| `brs` | `name=brs finished=1 cycles=92 from_fetch=61 retired=12 issue_groups=12 order=ok gpr_mismatch=0 pred_mismatch=0 mem_mismatch=0 check_failures=0 class_violations=0 overflows=0 credit_leaks=0 channels_used=19/48 violations=0` |
| `byp` | `name=byp finished=1 cycles=105 from_fetch=74 retired=14 issue_groups=14 order=ok gpr_mismatch=0 pred_mismatch=0 mem_mismatch=0 check_failures=0 class_violations=0 overflows=0 credit_leaks=0 channels_used=25/48 violations=0` |
| `gather` | `name=gather finished=1 cycles=2296 from_fetch=2265 retired=16 issue_groups=16 order=ok gpr_mismatch=0 pred_mismatch=0 mem_mismatch=0 check_failures=0 class_violations=0 overflows=0 credit_leaks=0 channels_used=26/48 violations=0` |
| `hit` | `name=hit finished=1 cycles=209 from_fetch=178 retired=17 issue_groups=17 order=ok gpr_mismatch=0 pred_mismatch=0 mem_mismatch=0 check_failures=0 class_violations=0 overflows=0 credit_leaks=0 channels_used=25/48 violations=0` |
| `late` | `name=late finished=1 cycles=156 from_fetch=125 retired=16 issue_groups=16 order=ok gpr_mismatch=0 pred_mismatch=0 mem_mismatch=0 check_failures=0 class_violations=0 overflows=0 credit_leaks=0 channels_used=25/48 violations=0` |
| `loop` | `name=loop finished=1 cycles=2736 from_fetch=2705 retired=407 issue_groups=407 order=ok gpr_mismatch=0 pred_mismatch=0 mem_mismatch=0 check_failures=0 class_violations=0 overflows=0 credit_leaks=0 channels_used=19/48 violations=0` |
| `merge` | `name=merge finished=1 cycles=66 from_fetch=35 retired=9 issue_groups=9 order=ok gpr_mismatch=0 pred_mismatch=0 mem_mismatch=0 check_failures=0 class_violations=0 overflows=0 credit_leaks=0 channels_used=17/48 violations=0` |
| `mload` | `name=mload finished=1 cycles=100 from_fetch=69 retired=11 issue_groups=11 order=ok gpr_mismatch=0 pred_mismatch=0 mem_mismatch=0 check_failures=0 class_violations=0 overflows=0 credit_leaks=0 channels_used=25/48 violations=0` |
| `pguard` | `name=pguard finished=1 cycles=102 from_fetch=71 retired=12 issue_groups=12 order=ok gpr_mismatch=0 pred_mismatch=0 mem_mismatch=0 check_failures=0 class_violations=0 overflows=0 credit_leaks=0 channels_used=25/48 violations=0` |
| `plog` | `name=plog finished=1 cycles=65 from_fetch=34 retired=10 issue_groups=10 order=ok gpr_mismatch=0 pred_mismatch=0 mem_mismatch=0 check_failures=0 class_violations=0 overflows=0 credit_leaks=0 channels_used=17/48 violations=0` |
| `sel` | `name=sel finished=1 cycles=94 from_fetch=63 retired=8 issue_groups=8 order=ok gpr_mismatch=0 pred_mismatch=0 mem_mismatch=0 check_failures=0 class_violations=0 overflows=0 credit_leaks=0 channels_used=25/48 violations=0` |
| `srd` | `name=srd finished=1 cycles=87 from_fetch=56 retired=6 issue_groups=6 order=ok gpr_mismatch=0 pred_mismatch=0 mem_mismatch=0 check_failures=0 class_violations=0 overflows=0 credit_leaks=0 channels_used=25/48 violations=0` |
| `unal` | `name=unal finished=1 cycles=218 from_fetch=187 retired=9 issue_groups=9 order=ok gpr_mismatch=0 pred_mismatch=0 mem_mismatch=0 check_failures=0 class_violations=0 overflows=0 credit_leaks=0 channels_used=26/48 violations=0` |
| `vadd` | `name=vadd finished=1 cycles=186 from_fetch=155 retired=17 issue_groups=17 order=ok gpr_mismatch=0 pred_mismatch=0 mem_mismatch=0 check_failures=0 class_violations=0 overflows=0 credit_leaks=0 channels_used=27/48 violations=0` |

## Manifest of release/

```
b6394253607cb7676224b32747e58a6cfde8913623d8e6fad56ec445f0ac2b53  release/kernels/brs.by_instr.json
c205a72485ee147487f10065f4723c33f9494a2a5c21832b339e57ea2f593436  release/kernels/brs.by_unit.json
be17b769b3188b4c2d1e6085e1ab8be3a1eb6037028b4014a4c26c2fd446cc92  release/kernels/brs.ccvtrace
10525a949cbdf843aff7cf84a76a0db0f31fa0e2b261ee29381ea0953c83b02c  release/kernels/brs.log
e3c1cb3379580cf1aae44e8ddc8e846ef6fd661a573cfe0a8d4444b18a14dc56  release/kernels/brs.oracle.jsonl
261ab69899138baf83eff4acbfb813d515e0e928f7f288708815a028e2a5c3c7  release/kernels/brs.sv-hosted.log
bfbfb0629fdde24492deefa45760c922150d06c607c3ea76e62927d5de404631  release/kernels/byp.by_instr.json
70d1ae5d03e27a8cb944f52922d70ceae70fe0e6bac8d120e64e0b00b4f737b4  release/kernels/byp.by_unit.json
de7c0a9f7c24a0875751b472dc1e9dae13a366d0a86e155acc3bdad96aacd592  release/kernels/byp.ccvtrace
b3b8a109edb907ddbe05d0f64bac3f0c31b104e69b0c640e75bae45034e63f8e  release/kernels/byp.log
5a03dfa4f3603fef49f1e3639e74e34152ca3ca5ef8e41eb959f8323040fa2d5  release/kernels/byp.oracle.jsonl
0447a7e1ba1f636b8a1e103d561883de3406b1e01a3ca0820712ac32579b895d  release/kernels/byp.sv-hosted.log
43be805db463edb0151ec3503c5d2f7764a89e0ea87116e8d067ba62f0c6ecc0  release/kernels/gather.by_instr.json
748c2544cc556d75326472e36dc7bde7b75a302b3a64f4b6ffa105c740197e98  release/kernels/gather.by_unit.json
fd240deeeb11704da5d79397833abacc1a1c10d3ab9917de26df6f41aa017d48  release/kernels/gather.ccvtrace
042c524d1c8387467df6cdadf23c7a39c142ec5559e6c10108fae66c40aeb8c6  release/kernels/gather.log
0413e781d8d6ff578c64eb1f800b7931e66f676d5cdabb97b94a4033e6037662  release/kernels/gather.oracle.jsonl
b958667da34850857bf51348528f5827eeca83c533f1e6d29ca6bd462948beeb  release/kernels/gather.sv-hosted.log
84ca62bb10698776de9f53f6d121d634c6ed0862a9701023aa0277d63f41b19f  release/kernels/hit.by_instr.json
c49e8eeb21f4c0ef8288b0f2c1f26f54d7925f9beeee94b88017dd5faa2a8a9e  release/kernels/hit.by_unit.json
4c56def17a2dfc55df71999c1f015b719e9bfb88d53576d15631c4a6fada8c71  release/kernels/hit.ccvtrace
65b7ba4e434935315ed279107a4f6316615ce4ec19984a4350b16bcc5572746d  release/kernels/hit.log
7ba9603e0088d9164de6528f16ef6a7fa9ce5821c8c12b52cbb3734e39b9fd52  release/kernels/hit.oracle.jsonl
0d5a50c1bc7f0c331dd545343dcbe8149e0c1c48d50a733bd7ebbdda8164f974  release/kernels/hit.sv-hosted.log
1551b5353cfc337def12e59754ff17a8971289f7a16dfdf47a4594dd4c1b0713  release/kernels/late.by_instr.json
588a942e3244777cd472937c5f458d6bff6495732893d53d5c1bae0d9a662d08  release/kernels/late.by_unit.json
b17d63d5b4fd946ff2ec3119e47197e973d5725d208a193ac4b16a9f72e88e9b  release/kernels/late.ccvtrace
23ce8ed48ec6917ce0c1f91c5be0884000b4688fd7cdfe315e350e257eb14201  release/kernels/late.log
86084f6bd747a2cf32acbc0ebd96ebd3e4ef2d8d9e21be49e3ae49290d7927f3  release/kernels/late.oracle.jsonl
ac76f567f9efc901adb5a8df1397e3e6a3434c80d77ca38073c685c4da264c7a  release/kernels/late.sv-hosted.log
e54a0335b010809afee57a5974097009618af9dccf0bb58ee9af0506e198675b  release/kernels/loop.by_instr.json.gz
81b5f488727871b194985229a74a8b660f6da348cf56223a230b07fa8cbec6b6  release/kernels/loop.by_unit.json.gz
784f70f72ce91ef604d46c29268d639d32aa286120624ac5c19c4715ba9e03f2  release/kernels/loop.ccvtrace
2b2fdb2d90d7426a756215917b41601ebe8b713d263a0509c63d0ca1a9663f0d  release/kernels/loop.log
03ce5920c06c93e93516d8e53c3f7169f14e3593de204eacceffc0b8a3e32016  release/kernels/loop.oracle.jsonl
cc97daf6322ce4a108fe38b9b5a6f0fb1c09f47062e1438f79cb18384fa953b9  release/kernels/loop.sv-hosted.log
ab687753cd747f95658b8df5d035aceef03cafabbb620a4beb091db033cc92b9  release/kernels/merge.by_instr.json
f47b8feb9881244a6c3d3d49a2567f0852290d1b0bd8c5fe5973199c03b4fac5  release/kernels/merge.by_unit.json
149a3b2f4772637514375a7e0926bd13beebea614974e3fdbdb0ba04d342ab58  release/kernels/merge.ccvtrace
b6392cbfd275585c3a7cd8cf5e20fb8e6f3023f522343ecbf06854999277e31b  release/kernels/merge.log
f96d28815f8756b1f5a45ded53e6170883d2dfa10f9eef0d14b8050b1318164a  release/kernels/merge.oracle.jsonl
74019e2ecc337e3317f33eea86f3a7c48b7f8c586443a81a9850e6b9493b0571  release/kernels/merge.sv-hosted.log
c14d2fda0bc1eafc15bedff9a9f05d1c44421c086a01d73369f4065ec96a0272  release/kernels/mload.by_instr.json
2eb70ca4e7aaeb305daa08b708dfde99d97422170ca1b6b2a5b2ac72aaffda3a  release/kernels/mload.by_unit.json
39f8c79c086fd4fb4a13bb5c5b50f914cf12f8bbab96bfb6f47e47658c03d5ca  release/kernels/mload.ccvtrace
7d936fd6e3b22215d888af5ed22baefcc03e99e680f6af5478f47e0ee88ba4e0  release/kernels/mload.log
8000e477b9a95dfb9f0af964e8346acb9d36f1358fd06ffc4ff7cf599d2b8868  release/kernels/mload.oracle.jsonl
5f6982d4dab491157e80b240ddfed8a28e723c2c563c78631592e06a6c38f9fd  release/kernels/mload.sv-hosted.log
e6de4a4e9c30eaea66b1bda1386315569932fae4e39f348599ed1fd24347adbc  release/kernels/pguard.by_instr.json
1a55707eecf40d029def0e3517fd922213d56f75c5a012f1c3804e256873915f  release/kernels/pguard.by_unit.json
b15bf575bb1ed3daa1d936a6e9a495a19ba09fd96040c0674c408c03f3189d5f  release/kernels/pguard.ccvtrace
d4d03ce03f20b4429a86979b5f64596b3bec9fa9634e0e62fc089755095baeac  release/kernels/pguard.log
690e56f1cb8d97cbf67124b7dff3ad0a90cb8981814cd1709cf0cd0e035b3bd9  release/kernels/pguard.oracle.jsonl
e8d565751e4b940549f195c7aa5cca593797f8357e89a7e03215609435863979  release/kernels/pguard.sv-hosted.log
08aa6df03bdf6857e689a78421c4bf1af6e5d9dd8e353216a27223350866ff68  release/kernels/plog.by_instr.json
440f1b741787405ab70ae8031e8285c79fdb783de14818a6fe1819d4800eb952  release/kernels/plog.by_unit.json
932dd0b2bd64ae4f4a1a4451c599ec8235fab701ab54e986deab1314bcdd2fa7  release/kernels/plog.ccvtrace
11cc6aea9048f69f2c7befbf8272a34048e732d4dcfcf8c83f3d72d82d1f2d4d  release/kernels/plog.log
c230f13f2e1082b306a9c5ab7809ff36cf5c1b2e47dca6b7a71f741524d403f5  release/kernels/plog.oracle.jsonl
fcfcce23c290953fa2d8c62a511509943121fea4f2671734c61b9a7d4ea39fe1  release/kernels/plog.sv-hosted.log
2dadc0c82488a0cb052d1cd30c6599e802bf36c9bdeb762d01be550605f316e1  release/kernels/sel.by_instr.json
2c917baeb1ed45e6dddff40c230bcc7290ce0a24c55be9e7f366e6f851e51193  release/kernels/sel.by_unit.json
5ff52eb23e87b59f26f97f9a1de4efbed6f8f2cc239cc4b0c3b762fec676328e  release/kernels/sel.ccvtrace
4c1510db86202f64d6f38bb12161fbd57d4c64227eb32c66d3749bc6d49a9533  release/kernels/sel.log
87f6a81e8afa004c8039bf2f61c90176fcf29ab29bb17ac44aa016a5cc8438fe  release/kernels/sel.oracle.jsonl
9f839dc9a7f779bb571302d78d70b48f27ed3d37f9c29b0ef37dae0a636ae1bc  release/kernels/sel.sv-hosted.log
d47711f676b435ae1a3aae52bbb0b6b08cd4a15178ea54b6a40aefd687283d79  release/kernels/srd.by_instr.json
d1ba46c352c83931acaa151aafed403aea3a9031f75cec46770c46e8ed3ff265  release/kernels/srd.by_unit.json
89f8f0d07007d646e5c456bdb829c1ec7fb1b2eb053cad5d9d961eb02ad31671  release/kernels/srd.ccvtrace
bbad9003ff09e09e4e6c3fea313126b5f8821f71e88a0c911a8f14fd10d41b1f  release/kernels/srd.log
b08eb5e3673cac7eebb8b72af5ed3783c8e70a9e96592e76bf3722551bc79473  release/kernels/srd.oracle.jsonl
96eb3ed0232f82e0f0ca0ac0442682d6ec9f6b206129e2fca0d521a1e464a971  release/kernels/srd.sv-hosted.log
ce11e3d19f3320d6713866ac492871e782c2ccd6efc2024fb590e113da39ebe3  release/kernels/unal.by_instr.json
fbe9e9e828a837b8a853b365355023f1ea42a26c8483c9ba1dfe83a4f4c17ae6  release/kernels/unal.by_unit.json
8f8d2f1fd618dc425afb8a7dc7f9a98df01eb1f78f58a6c808032fbf403369e7  release/kernels/unal.ccvtrace
8ac651a3977581f95a3655ddbad51de7c785cccc5f3e3b571e8594208a9344ec  release/kernels/unal.log
c3d484bb160657a563df983d9a2532eac27f556636617960aa1e72183ac2b299  release/kernels/unal.oracle.jsonl
6edb131021668048f593ca1fbf88ab322f74fdb220e112c61daa105faef632b2  release/kernels/unal.sv-hosted.log
ca5b4d11eba35ec1c46f2294eb59a69058c7c97fb75d99af3d13916ee58205bc  release/kernels/vadd.by_instr.json
438bc53796f723004d442d911ebd85a5beca8ec164a498157bb342470a7a3077  release/kernels/vadd.by_unit.json
ce85ae2302339903d7433f914b45fbaab133b1eaa8e7486ddf37115c67c7199a  release/kernels/vadd.ccvtrace
399f46f9b164f7242dc563951ded1ccd987e61e133e79a22ed2601a4fd80d8e7  release/kernels/vadd.log
0276b6d0611a4bbcdc004ab3987214aea138245bc7217504147331689a9c0880  release/kernels/vadd.oracle.jsonl
8ef118cf6a3207af60576a65c9eec14741591a1b235b5616129b024807f7ee2e  release/kernels/vadd.sv-hosted.log
49dba4c164d0b0d34b39bac765792dd28395245942f7dd1287998bd489eb7888  release/verify.log
efec12fa3875516bd93eb483139bd285209552bf4ca91a899c12def9830305e8  release/wiring.txt
```
