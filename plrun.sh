set -u
say(){ printf "  %-60s %s\n" "$1" "$2"; }
seeds=10 fail=0
secs=$(sed -n 's/.*localparam int CCV_SECTIONS = \([0-9]*\);.*/\1/p' rtl/generated/ccv_params_pkg.sv)
dir=build/ooe-rtl/pl
mkdir -p "$dir"
if ! python3 test/ooe/pl-fields.py "$dir/pl_fields.h" >"$dir/build.log" 2>&1 ||
   ! verilator --cc --exe --build -j 0 -O2 --assert -Wall -Wno-UNUSEDSIGNAL -Wno-DECLFILENAME \
      --trace -GNS="$secs" --top-module ooe_pl_tb \
      --Mdir "$dir" -o pl_tb -I"$PWD/rtl/include" -I"$PWD/rtl/generated" \
      -CFLAGS "-std=c++17 -O2 -I$PWD/test/ooe -I$PWD/$dir -DPL_NS=$secs -DOOE_TEST_AS_LIBRARY -I$PWD/sim/generated -I$PWD/sim/ooe" \
      "$PWD/rtl/ccv_assert_pkg.sv" "$PWD/rtl/generated/ccv_params_pkg.sv" "$PWD/rtl/ooe/ooe_rcupl.sv" \
      "$PWD/rtl/ooe/ooe_mempl.sv" "$PWD/test/ooe/ooe_pl_tb.sv" "$PWD/test/ooe/pl_tb.cpp" \
      "$PWD/sim/ooe/ooe_core.cpp" "$PWD/sim/ooe/ooe_test.cpp" >>"$dir/build.log" 2>&1; then
  say "pl: builds" "FAIL (see $dir/build.log)"; tail -5 "$dir/build.log"; exit 1
fi
if out=$("$dir/pl_tb" "$seeds" 2>&1); then
  say "rcupl, mempl ($secs sections) == model, live" "PASS ($(echo "$out" | tail -1 | sed 's/.*seeds=//'))"
else
  say "rcupl, mempl == model, live" "FAIL"; echo "$out" | tail -8; fail=1
fi
for c in no-gnt-lead no-mem-lead no-dsc-lead early-pe no-cok no-fp; do
  if PL_CONTROL=$c "$dir/pl_tb" 3 >/dev/null 2>&1; then
    say "  control $c (pl)" "MISSED"; fail=1
  else
    say "  control $c (pl)" "caught"
  fi
done

echo fail=$fail
