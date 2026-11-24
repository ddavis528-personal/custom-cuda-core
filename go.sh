set -uo pipefail
cd /tmp/claude-0/-home-user/f45e5bc5-a4af-595e-a4dd-e1d6ad6f715c/scratchpad/wtgo
seeds=${1:-25}; fail=0
say() { printf '  %-52s %s\n' "$1" "$2"; }
width=$(sed -n "s/.*localparam int CCV_ISSUE_WIDTH = \([0-9]*\);.*/\1/p" rtl/generated/ccv_params_pkg.sv)
slots=$(sed -n "s/.*localparam int CCV_TIER1_WARPS = \([0-9]*\);.*/\1/p" rtl/generated/ccv_params_pkg.sv)
dir=build/ooe-rtl/go
mkdir -p "$dir"
if ! verilator --cc --exe --build -j 0 -O2 --assert -Wall -Wno-UNUSEDSIGNAL -Wno-DECLFILENAME \
      --trace -GS="$slots" -GR="$width" --top-module ooe_go \
      --Mdir "$dir" -o go_tb -I"$PWD/rtl/include" -I"$PWD/rtl/generated" \
      -CFLAGS "-std=c++17 -O2 -I$PWD/test/ooe -DGO_S=$slots -DGO_R=$width -DOOE_TEST_AS_LIBRARY -I$PWD/sim/generated -I$PWD/sim/ooe" \
      "$PWD/rtl/ccv_assert_pkg.sv" "$PWD/rtl/ooe/ooe_go.sv" "$PWD/test/ooe/go_tb.cpp" \
      "$PWD/sim/ooe/ooe_core.cpp" "$PWD/sim/ooe/ooe_test.cpp" >"$dir/build.log" 2>&1; then
  say "go: builds" "FAIL (see $dir/build.log)"; tail -5 "$dir/build.log"; exit 1
fi
if out=$("$dir/go_tb" "$seeds" 2>&1); then
  say "go ($slots slots, $width a cycle) == model, live" "PASS ($(echo "$out" | tail -1 | sed 's/.*seeds=//'))"
else
  say "go == model, live" "FAIL"; echo "$out" | tail -8; fail=1
fi
for c in no-hold no-rbusy no-squash no-dq-ev no-rob-en no-pool-en no-ret adm-shift no-write-bits no-room no-corr no-pair-bit pair-rounds; do
  if GO_CONTROL=$c "$dir/go_tb" 3 >/dev/null 2>&1; then
    say "  control $c (go)" "MISSED"; fail=1
  else
    say "  control $c (go)" "caught"
  fi
done

# ooe_rob, the ROB (slices 1 and 2, OI-85), driven from the model's ROB log
# (Core::robLog) a model cycle behind, with retire_lag 1: its retirements,
exit $fail
