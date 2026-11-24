cd /home/user/wt-5b
read -r g d < <(python3 test/ooe/ratmap-params.py); dir=build/ooe-rtl/ratmap
verilator --cc --exe --build -j 0 -O2 --assert -Wall -Wno-UNUSEDSIGNAL -Wno-DECLFILENAME \
      --trace -DCCV_CHECK_RATMAP ${g//,/ } --top-module ooe_ratmap --Mdir "$dir" -o ratmap_tb \
      -I"$PWD/rtl/include" -I"$PWD/rtl/generated" \
      -CFLAGS "-std=c++17 -O2 ${d//,/ } -DOOE_TEST_AS_LIBRARY -I$PWD/sim/generated -I$PWD/sim/ooe -I$PWD/test/ooe" \
      "$PWD/rtl/ccv_assert_pkg.sv" "$PWD/rtl/ooe/ooe_ratmap.sv" "$PWD/test/ooe/ratmap_tb.cpp" \
      "$PWD/sim/ooe/ooe_core.cpp" "$PWD/sim/ooe/ooe_test.cpp" > $dir/build.log 2>&1; echo rc $?; grep -E "%(Error|Warning)|error:" $dir/build.log | head
