cd /home/user/wt-slot && verilator --cc --exe --build -j 0 -O2 --assert -Wall -Wno-UNUSEDSIGNAL -Wno-DECLFILENAME \
  --trace -GS=4 -GA=4 -GD=1 --top-module ooe_slot_tb --Mdir build/ooe-rtl/slot -o slot_tb -I"$PWD/rtl/include" -I"$PWD/rtl/generated" \
  -CFLAGS "-std=c++17 -O2 -I$PWD/test/ooe -DSL_S=4 -DSL_A=4 -DSL_D=1 -DOOE_TEST_AS_LIBRARY -I$PWD/sim/generated -I$PWD/sim/ooe" \
  "$PWD/rtl/ccv_assert_pkg.sv" "$PWD/rtl/ooe/ooe_slot.sv" "$PWD/test/ooe/ooe_slot_tb.sv" "$PWD/test/ooe/slot_tb.cpp" "$PWD/sim/ooe/ooe_core.cpp" "$PWD/sim/ooe/ooe_test.cpp" > build/ooe-rtl/slot/build.log 2>&1 || { grep -E "%Error|error:" build/ooe-rtl/slot/build.log | head; exit 1; }
