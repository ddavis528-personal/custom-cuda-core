set -u
cd /home/user/wt-sw
phys=$(sed -n 's/.*localparam int CCV_P_PHYS_REGS = \([0-9]*\);.*/\1/p' rtl/generated/ccv_params_pkg.sv)
width=$(sed -n 's/.*localparam int CCV_ISSUE_WIDTH = \([0-9]*\);.*/\1/p' rtl/generated/ccv_params_pkg.sv)
fl_buf=$(sed -n 's/.*unsigned fl_buf = \([0-9]*\);.*/\1/p' sim/ooe/ooe_core.h)
fl_banks=$(sed -n 's/.*unsigned fl_banks = \([0-9]*\);.*/\1/p' sim/ooe/ooe_core.h)
fl_slots=$(sed -n 's/.*localparam int CCV_TIER1_WARPS = \([0-9]*\);.*/\1/p' rtl/generated/ccv_params_pkg.sv)
ns=$((1 << $(sed -n 's/.*localparam int CCV_W_PHYS_POS = \([0-9]*\);.*/\1/p' rtl/generated/ccv_params_pkg.sv)))
n=$phys sec=$ns pool=0
dir=build/ooe-rtl/freelist_gsec; mkdir -p $dir
verilator --cc --exe --build -j 0 -O2 --assert -Wall -Wno-UNUSEDSIGNAL -Wno-DECLFILENAME \
  --trace -DCCV_CHECK -GN="$n" -GA="$width" -GB="$fl_buf" -GK="$fl_banks" -GS="$fl_slots" -GFS="$fl_slots" -GNS="$sec" --top-module ooe_freelist --Mdir "$dir" -o freelist_tb \
  -I"$PWD/rtl/include" -I"$PWD/rtl/generated" \
  -CFLAGS "-std=c++17 -O2 -DFL_N=$n -DFL_A=$width -DFL_B=$fl_buf -DFL_K=$fl_banks -DFL_S=$fl_slots -DFL_FS=$fl_slots -DFL_POOL=$pool -DFL_NS=$sec -DOOE_TEST_AS_LIBRARY -I$PWD/sim/generated -I$PWD/sim/ooe" \
  "$PWD/rtl/ccv_assert_pkg.sv" "$PWD/rtl/common/ccv_common_csa.sv" "$PWD/rtl/ooe/ooe_freelist.sv" "$PWD/test/ooe/freelist_tb.cpp" \
  "$PWD/sim/ooe/ooe_core.cpp" "$PWD/sim/ooe/ooe_test.cpp" > $dir/build.log 2>&1 || { echo BUILD FAIL; tail -5 $dir/build.log; exit 1; }
for c in none rt-late sa-late sal-late rtl-late; do
  echo "== $c"; FL_CONTROL=$c $dir/freelist_tb 3 2>&1 | grep -E "PROBE|Assertion failed|mismatches=" | head -4 
done
