set -u; cd /home/user/wt-slot; seeds=10; fail=0
say() { printf '  %-52s %s\n' "$1" "$2"; }
read -r wake_g wake_d < <(python3 test/ooe/wake-params.py)
dir=build/ooe-rtl/wake-oa444; mkdir -p "$dir"
verilator --cc --exe --build -j 2 -O2 --assert -Wall -Wno-UNUSEDSIGNAL -Wno-DECLFILENAME \
      --trace ${wake_g//,/ } --top-module ooe_wake --Mdir "$dir" -o wake_tb \
      -I"$PWD/rtl/include" -I"$PWD/rtl/generated" \
      -CFLAGS "-std=c++17 -O2 ${wake_d//,/ } -DOOE_TEST_AS_LIBRARY -I$PWD/sim/generated -I$PWD/sim/ooe" \
      "$PWD/rtl/ccv_assert_pkg.sv" "$PWD/rtl/generated/ccv_params_pkg.sv" "$PWD/rtl/ooe/ooe_wake.sv" "$PWD/rtl/ooe/ooe_confirm.sv" "$PWD/test/ooe/wake_tb.cpp" \
      "$PWD/sim/ooe/ooe_core.cpp" "$PWD/sim/ooe/ooe_test.cpp" >"$dir/build.log" 2>&1 || { echo BUILD FAIL; tail -5 $dir/build.log; exit 1; }
"$dir/wake_tb" $seeds 2>&1 | tail -1
for c in late-grant drop-cmpl no-dep drop-squash-free no-cmpl-lead no-sq-lead no-hint; do
  if WAKE_CONTROL=$c "$dir/wake_tb" 3 >/dev/null 2>&1; then echo "$c MISSED"; else echo "$c caught"; fi; done
# also without -G for LAT_SPEC/LAT_MISS: package defaults must equal what wake-params passes
echo "$wake_g" | tr ' ,' '\n\n' | grep -E "LAT_SPEC|LAT_MISS"
