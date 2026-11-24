#!/bin/bash
cd /tmp/claude-0/-home-user/f45e5bc5-a4af-595e-a4dd-e1d6ad6f715c/scratchpad/wtf
slots=4; width=4
dir=build/ooe-rtl/go; mkdir -p $dir
verilator --cc --exe --build -j 4 -O2 --assert -Wall -Wno-UNUSEDSIGNAL -Wno-DECLFILENAME \
      --trace -GS="$slots" -GR="$width" --top-module ooe_go \
      --Mdir "$dir" -o go_tb -I"$PWD/rtl/include" -I"$PWD/rtl/generated" \
      -CFLAGS "-std=c++17 -O2 -I$PWD/test/ooe -DGO_S=$slots -DGO_R=$width -DOOE_TEST_AS_LIBRARY -I$PWD/sim/generated -I$PWD/sim/ooe" \
      "$PWD/rtl/ccv_assert_pkg.sv" "$PWD/rtl/ooe/ooe_go.sv" "$PWD/test/ooe/go_tb.cpp" \
      "$PWD/sim/ooe/ooe_core.cpp" "$PWD/sim/ooe/ooe_test.cpp" >"$dir/build.log" 2>&1 || { echo BUILD FAIL; grep -E "%Error|error:" $dir/build.log | head -20; exit 1; }
echo built
$dir/go_tb 25 2>&1 | tail -4
echo "--- scarce"; GO_NAMES=144,24 $dir/go_tb 5 2>&1 | tail -4
for c in floor-take-now; do echo "--- $c"; GO_NAMES=144,24 GO_CONTROL=$c $dir/go_tb 3 2>&1 | tail -3; done
echo END
