#!/bin/bash
cd /home/user/wt-61
dir=build/ooe-rtl/decrx; mkdir -p $dir
verilator --cc --exe --build -j 4 -O2 --assert -Wall -Wno-UNUSEDSIGNAL -Wno-DECLFILENAME --trace -GS=4 -GE=6 -GNW=32 -GEP=3 --top-module ooe_decrx_tb --Mdir "$dir" -o decrx_tb -I"$PWD/rtl/include" -I"$PWD/rtl/generated" -CFLAGS "-std=c++17 -O2 -DRX_S=4 -DRX_E=6 -DOOE_TEST_AS_LIBRARY -I$PWD/sim/generated -I$PWD/sim/ooe" $PWD/rtl/ccv_assert_pkg.sv $PWD/rtl/ooe/ooe_decrx.sv $PWD/rtl/ooe/ooe_decrx_keep.sv $PWD/test/ooe/ooe_decrx_tb.sv $PWD/test/ooe/decrx_tb.cpp $PWD/sim/ooe/ooe_core.cpp $PWD/sim/ooe/ooe_test.cpp > $dir/build.log 2>&1
r=$?; echo build=$r; grep -E "%Warning|%Error|error:" $dir/build.log | head -5
