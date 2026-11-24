set -u; cd /home/user/wt-sw; seeds=25; fail=0; say(){ printf "%-50s %s\n" "$1" "$2"; }
# ooe_ratmap (OA 435 (8)): ccv_ooe_rcu_map and the parked layout, against
# the model's maps as the adapter queues them and its parked layout,
# through the scenario ratmap (demotes, restores, kills, sectioned).
read -r rmap_g rmap_d < <(python3 test/ooe/ratmap-params.py)
dir=build/ooe-rtl/ratmap
mkdir -p "$dir"
if ! verilator --cc --exe --build -j 0 -O2 --assert -Wall -Wno-UNUSEDSIGNAL -Wno-DECLFILENAME \
      --trace -DCCV_CHECK_RATMAP ${rmap_g//,/ } --top-module ooe_ratmap --Mdir "$dir" -o ratmap_tb \
      -I"$PWD/rtl/include" -I"$PWD/rtl/generated" \
      -CFLAGS "-std=c++17 -O2 ${rmap_d//,/ } -DOOE_TEST_AS_LIBRARY -I$PWD/sim/generated -I$PWD/sim/ooe -I$PWD/test/ooe" \
      "$PWD/rtl/ccv_assert_pkg.sv" "$PWD/rtl/ooe/ooe_ratmap.sv" "$PWD/test/ooe/ratmap_tb.cpp" \
      "$PWD/sim/ooe/ooe_core.cpp" "$PWD/sim/ooe/ooe_test.cpp" >"$dir/build.log" 2>&1; then
  say "ratmap: builds" "FAIL (see $dir/build.log)"; tail -5 "$dir/build.log"; exit 1
fi
if out=$("$dir/ratmap_tb" "$seeds" 2>&1); then
  say "ratmap (rcu_map, parked layout) == model, live" "PASS ($(echo "$out" | tail -1 | sed 's/.*seeds=//'))"
else
  say "ratmap == model, live" "FAIL"; echo "$out" | tail -8; fail=1
fi
for c in wrong-slot cw-shift no-read-lead restore-first read-at-write; do
  if RATMAP_CONTROL=$c "$dir/ratmap_tb" 3 >/dev/null 2>&1; then
    say "  control $c (ratmap)" "MISSED"; fail=1
  else
    say "  control $c (ratmap)" "caught"
  fi
done

echo fail=$fail
