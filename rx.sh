set -e; cd /home/user/wt-sw
slots=$(sed -n 's/.*localparam int CCV_TIER1_WARPS = \([0-9]*\);.*/\1/p' rtl/generated/ccv_params_pkg.sv)
decq=$(sed -n 's/.*localparam int CCV_P_DECQ = \([0-9]*\);.*/\1/p' rtl/generated/ccv_params_pkg.sv)
decq_warp=$(sed -n 's/.*localparam int CCV_P_DECQ_WARP_MAX = \([0-9]*\);.*/\1/p' rtl/generated/ccv_params_pkg.sv)
uops=$(python3 -c "import json; print(next(c['rate'] for c in json.load(open('schema/interfaces.json'))['channels'] if c['name'] == 'ccv_dec_ooe_uop'))")
dir=build/ooe-rtl/decq
epbits=$(sed -n 's/.*localparam int CCV_P_W_FETCH_EPOCH = \([0-9]*\);.*/\1/p' rtl/generated/ccv_params_pkg.sv)
dir=build/ooe-rtl/decrx
mkdir -p "$dir"
verilator --cc --exe --build -j 0 -O2 --assert -Wall -Wno-UNUSEDSIGNAL -Wno-DECLFILENAME \
      --trace -GS="$slots" -GE="$uops" -GNW=32 -GEP="$epbits" --top-module ooe_decrx_tb \
      --Mdir "$dir" -o decrx_tb -I"$PWD/rtl/include" -I"$PWD/rtl/generated" \
      -CFLAGS "-std=c++17 -O2 -DRX_S=$slots -DRX_E=$uops -DOOE_TEST_AS_LIBRARY -I$PWD/sim/generated -I$PWD/sim/ooe" \
      "$PWD/rtl/ccv_assert_pkg.sv" "$PWD/rtl/ooe/ooe_decrx.sv" "$PWD/rtl/ooe/ooe_decrx_keep.sv" \
      "$PWD/test/ooe/ooe_decrx_tb.sv" "$PWD/test/ooe/decrx_tb.cpp" \
      "$PWD/sim/ooe/ooe_core.cpp" "$PWD/sim/ooe/ooe_test.cpp" >"$dir/build.log" 2>&1
  say "decrx: builds" "FAIL (see $dir/build.log)"; tail -5 "$dir/build.log"; exit 1
echo built
