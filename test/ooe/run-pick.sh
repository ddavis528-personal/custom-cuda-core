#!/usr/bin/env bash
# ccv_ooe_pick against ooe::pickResources (test/ooe/pick_tb.cpp), at both
# RS classes' sizes: the lane-and-RCU class (CCV_P_RS_RCU entries, S0-S3
# and R) and the MIU class (CCV_P_RS_MIU entries, P0-P3). Each build also
# runs the harness's negative controls, each of which must fail.
# Usage: test/ooe/run-pick.sh [vectors]
set -uo pipefail
cd "$(dirname "$0")/../.."
vectors="${1:-200000}"
n_rcu=$(sed -n 's/.*localparam int CCV_P_RS_RCU = \([0-9]*\);.*/\1/p' rtl/generated/ccv_params_pkg.sv)
n_miu=$(sed -n 's/.*localparam int CCV_P_RS_MIU = \([0-9]*\);.*/\1/p' rtl/generated/ccv_params_pkg.sv)
secs=$(sed -n 's/.*localparam int CCV_SECTIONS = \([0-9]*\);.*/\1/p' rtl/generated/ccv_params_pkg.sv)
pipes=$(sed -n 's/.*localparam int CCV_MIU_PIPES = \([0-9]*\);.*/\1/p' rtl/generated/ccv_params_pkg.sv)
fail=0
say() { printf '  %-52s %s\n' "$1" "$2"; }
for cfg in "rcu $n_rcu $((secs + 1))" "miu $n_miu $pipes"; do
  set -- $cfg
  name=$1 n=$2 r=$3
  dir=build/ooe-rtl/pick_$name
  mkdir -p "$dir"
  if ! verilator --cc --exe --build -j 0 -O2 -Wall -Wno-UNUSEDSIGNAL \
        -GN="$n" -GR="$r" --top-module ccv_ooe_pick --Mdir "$dir" -o pick_tb \
        -CFLAGS "-std=c++17 -O2 -DPICK_N=$n -DPICK_R=$r -I$PWD/sim/generated -I$PWD/sim/ooe" \
        "$PWD/rtl/ooe/ccv_ooe_pick.sv" "$PWD/test/ooe/pick_tb.cpp" "$PWD/sim/ooe/ooe_core.cpp" \
        >"$dir/build.log" 2>&1; then
    say "pick $name: builds" "FAIL (see $dir/build.log)"; tail -5 "$dir/build.log"; fail=1; continue
  fi
  if out=$("$dir/pick_tb" "$vectors" 1 2>&1); then
    say "pick $name ($n entries, $r resources) == model" "PASS ($(echo "$out" | tail -1 | sed 's/.*vectors=//'))"
  else
    say "pick $name == model" "FAIL"; echo "$out" | tail -8; fail=1
  fi
  for c in youngest-wins any-wins no-mask; do
    if PICK_CONTROL=$c "$dir/pick_tb" 20000 2 >/dev/null 2>&1; then
      say "  control $c ($name)" "MISSED"; fail=1
    else
      say "  control $c ($name)" "caught"
    fi
  done
done
exit $fail
