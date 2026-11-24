#!/usr/bin/env bash
cd /home/user/wt-sw
width=$(sed -n 's/.*localparam int CCV_ISSUE_WIDTH = \([0-9]*\);.*/\1/p' rtl/generated/ccv_params_pkg.sv)
slots=$(sed -n 's/.*localparam int CCV_TIER1_WARPS = \([0-9]*\);.*/\1/p' rtl/generated/ccv_params_pkg.sv)
dir=build/ooe-rtl/go; mkdir -p $dir
verilator --cc --exe --build -j 0 -O2 --assert -Wall -Wno-UNUSEDSIGNAL -Wno-DECLFILENAME \
      --trace -DCCV_CHECK_GO -GS="$slots" -GR="$width" --top-module ooe_go \
      --Mdir "$dir" -o go_tb -I"$PWD/rtl/include" -I"$PWD/rtl/generated" \
      -CFLAGS "-std=c++17 -O2 -I$PWD/test/ooe -DGO_S=$slots -DGO_R=$width -DOOE_TEST_AS_LIBRARY -I$PWD/sim/generated -I$PWD/sim/ooe" \
      "$PWD/rtl/ccv_assert_pkg.sv" "$PWD/rtl/ooe/ooe_go.sv" "$PWD/test/ooe/go_tb.cpp" \
      "$PWD/sim/ooe/ooe_core.cpp" "$PWD/sim/ooe/ooe_test.cpp" >"$dir/build.log" 2>&1 || { echo BUILD FAIL; tail -8 $dir/build.log; exit 1; }
echo "== none"; $dir/go_tb 10 2>&1 | tail -2 | cut -c1-200
echo "== scarce"; GO_NAMES=144,24 $dir/go_tb 5 2>&1 | tail -2 | cut -c1-200
for c in no-pool-en no-rob-en no-dq-ev no-corr; do echo "== $c"; GO_CONTROL=$c $dir/go_tb 3 2>&1 | grep -m1 "Assertion\|mismatch\|differ\|FAIL\|seeds=" | cut -c1-200; done
