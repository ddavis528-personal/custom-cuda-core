#!/bin/bash
cd /home/user/wt-58
slots=$(sed -n 's/.*localparam int CCV_TIER1_WARPS = \([0-9]*\);.*/\1/p' rtl/generated/ccv_params_pkg.sv)
decq=$(sed -n 's/.*localparam int CCV_P_DECQ = \([0-9]*\);.*/\1/p' rtl/generated/ccv_params_pkg.sv)
decq_warp=$(sed -n 's/.*localparam int CCV_P_DECQ_WARP_MAX = \([0-9]*\);.*/\1/p' rtl/generated/ccv_params_pkg.sv)
width=$(sed -n 's/.*localparam int CCV_ISSUE_WIDTH = \([0-9]*\);.*/\1/p' rtl/generated/ccv_params_pkg.sv)
uops=6
dir=build/ooe-rtl/decq; mkdir -p $dir
verilator --cc --exe --build -j 4 -O2 --assert -Wall -Wno-UNUSEDSIGNAL -Wno-DECLFILENAME \
      --trace -GS="$slots" -GQ="$decq" -GD="$decq_warp" -GE="$uops" -GR="$width" -GP=16 --top-module ooe_decq \
      --Mdir "$dir" -o decq_tb -I"$PWD/rtl/include" -I"$PWD/rtl/generated" \
      -CFLAGS "-std=c++17 -O2 -DDQ_S=$slots -DDQ_Q=$decq -DDQ_D=$decq_warp -DDQ_E=$uops -DDQ_R=$width -DOOE_TEST_AS_LIBRARY -I$PWD/sim/generated -I$PWD/sim/ooe" \
      "$PWD/rtl/ccv_assert_pkg.sv" "$PWD/rtl/ooe/ooe_decq.sv" "$PWD/test/ooe/decq_tb.cpp" \
      "$PWD/sim/ooe/ooe_core.cpp" "$PWD/sim/ooe/ooe_test.cpp" >"$dir/build.log" 2>&1
r=$?; echo build=$r slots=$slots decq=$decq dw=$decq_warp R=$width; grep -E "%Warning|%Error|error:" $dir/build.log | head -5
