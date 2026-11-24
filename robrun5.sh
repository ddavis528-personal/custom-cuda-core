#!/bin/bash
cd /home/user/wt-rob
slots=$(sed -n 's/.*localparam int CCV_TIER1_WARPS = \([0-9]*\);.*/\1/p' rtl/generated/ccv_params_pkg.sv)
width=$(sed -n 's/.*localparam int CCV_ISSUE_WIDTH = \([0-9]*\);.*/\1/p' rtl/generated/ccv_params_pkg.sv)
dir=build/ooe-rtl/rob
mkdir -p "$dir"
rv() { sed -n "s/.*localparam int $1 = \([0-9]*\);.*/\1/p" rtl/generated/ccv_params_pkg.sv; }
rob_p="S=$slots D=$(rv CCV_P_ROB_DEPTH) RP=$(rv CCV_RETIRE_PER_ROB) A=$width ND=7 NM=4 NK=$(rv CCV_P_BR_CKPTS) PCW=$(rv CCV_ADDR_BITS)"
rob_p="$rob_p GW=$(( $(rv CCV_P_W_PHYS_REG) + $(rv CCV_W_PHYS_POS) )) GR=$(rv CCV_P_W_PHYS_REG) NG=$(rv CCV_P_PHYS_REGS)"
rob_p="$rob_p CW=$(rv CCV_W_FAULT_CAUSE) NS=$(( 1 << $(rv CCV_W_PHYS_POS) )) PW=$(rv CCV_P_W_PHYS_PRED) NP=$(rv CCV_P_PRED_REGS)"
verilator --cc --exe --build -j 2 -O2 --assert -Wall -Wno-UNUSEDSIGNAL -Wno-DECLFILENAME \
      --trace $(for kv in $rob_p; do printf -- '-G%s ' "$kv"; done) --top-module ooe_rob_tb \
      --Mdir "$dir" -o rob_tb -I"$PWD/rtl/include" -I"$PWD/rtl/generated" \
      -CFLAGS "-std=c++17 -O2 -I$PWD/test/ooe $(for kv in $rob_p; do printf -- '-DRB_%s ' "$kv"; done) -DOOE_TEST_AS_LIBRARY -I$PWD/sim/generated -I$PWD/sim/ooe" \
      "$PWD/rtl/ccv_assert_pkg.sv" "$PWD/rtl/ooe/ooe_rob_w.sv" "$PWD/test/ooe/ooe_rob_tb.sv" "$PWD/test/ooe/rob_tb.cpp" \
      "$PWD/sim/ooe/ooe_core.cpp" "$PWD/sim/ooe/ooe_test.cpp" >"$dir/build.log" 2>&1 || { echo BUILD FAIL; tail -20 $dir/build.log; exit 1; }
echo built
$dir/rob_tb 25 2>&1 | tail -14
echo "--- mispredict"
ROB_MISPREDICT=1 $dir/rob_tb 25 2>&1 | tail -12
for c in drop-free no-copy no-lead fill-order nop-real two-in-a-cycle wrong-row flip-taken right-always branch-off-slot \
         no-branch-lead no-miu no-store drop-killed-fill late-fill shared-ports store-shift no-fault fault-cause fault-any-port fault-port0 no-fault-lead fault-addr; do
  if ROB_CONTROL=$c $dir/rob_tb 25 >/dev/null 2>&1; then echo "MISSED $c"; else echo "caught $c"; fi
done
out=$(ROB_CONTROL=two-resolutions $dir/rob_tb 3 2>&1); grep -q one_resolution <<<"$out" && echo "caught two-resolutions" || echo "MISSED two-resolutions"
echo EXIT
