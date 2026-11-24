#!/bin/bash
cd /home/user/custom-cuda-core
say(){ printf "%-55s %s\n" "$1" "$2"; }; seeds=${SEEDS:-20}; fail=0
read -r ren1_g ren1_d < <(python3 test/ooe/ren1-params.py)
dir=build/ooe-rtl/ren1
mkdir -p "$dir"
if ! verilator --cc --exe --build -j 0 -O2 --assert -Wall -Wno-UNUSEDSIGNAL -Wno-DECLFILENAME \
      --trace ${ren1_g//,/ } --top-module ooe_ren1_tb --Mdir "$dir" -o ren1_tb \
      -I"$PWD/rtl/include" -I"$PWD/rtl/generated" \
      -CFLAGS "-std=c++17 -O2 ${ren1_d//,/ } -DOOE_TEST_AS_LIBRARY -I$PWD/sim/generated -I$PWD/sim/ooe" \
      "$PWD/rtl/ccv_assert_pkg.sv" "$PWD/rtl/ooe/ooe_rat.sv" "$PWD/rtl/ooe/ooe_headrd.sv" \
      "$PWD/rtl/ooe/ooe_ren1.sv" "$PWD/rtl/ooe/ooe_ren1n.sv" "$PWD/test/ooe/ooe_ren1_tb.sv" \
      "$PWD/test/ooe/ren1_tb.cpp" "$PWD/sim/ooe/ooe_core.cpp" "$PWD/sim/ooe/ooe_test.cpp" >"$dir/build.log" 2>&1; then
  say "ren1: builds" "FAIL (see $dir/build.log)"; tail -5 "$dir/build.log"; exit 1
fi
if out=$("$dir/ren1_tb" "$seeds" 2>&1); then
  say "Rename 1 (lanes, names, reads) == model, live" "PASS ($(echo "$out" | tail -1 | sed 's/.*seeds=//'))"
else
  say "Rename 1 == model, live" "FAIL"; echo "$out" | tail -8; fail=1
fi
for c in lane-swap name-reverse drop-restore; do
  if REN1_CONTROL=$c "$dir/ren1_tb" 3 >/dev/null 2>&1; then
    say "  control $c (ren1)" "MISSED"; fail=1
  else
    say "  control $c (ren1)" "caught"
  fi
done

echo "fail=$fail"
