#!/usr/bin/env bash
# OOE RTL in lockstep with the model, each harness's negative controls
# caught:
# - ooe_pick against ooe::pickResources (test/ooe/pick_tb.cpp), at both
#   RS classes' sizes: the lane-and-RCU class (CCV_P_RS_RCU entries, S0-S3
#   and R) and the MIU class (CCV_P_RS_MIU entries, P0-P3);
# - ooe_ready against the live model through its random unit tests
#   (test/ooe/ready_tb.cpp).
# Usage: test/ooe/run-rtl.sh [vectors] [seeds]
set -uo pipefail
cd "$(dirname "$0")/../.."
vectors="${1:-200000}"
seeds="${2:-25}"
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
        -GN="$n" -GR="$r" --top-module ooe_pick --Mdir "$dir" -o pick_tb \
        -CFLAGS "-std=c++17 -O2 -DPICK_N=$n -DPICK_R=$r -I$PWD/sim/generated -I$PWD/sim/ooe" \
        "$PWD/rtl/ooe/ooe_pick.sv" "$PWD/test/ooe/pick_tb.cpp" "$PWD/sim/ooe/ooe_core.cpp" \
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

# ooe_ready, driven from the core after every cycle of the unit tests.
n=$((n_rcu + n_miu))
dir=build/ooe-rtl/ready
mkdir -p "$dir"
if ! verilator --cc --exe --build -j 0 -O2 -Wall -Wno-UNUSEDSIGNAL \
      -GN="$n" --top-module ooe_ready --Mdir "$dir" -o ready_tb \
      -CFLAGS "-std=c++17 -O2 -DREADY_N=$n -DOOE_TEST_AS_LIBRARY -I$PWD/sim/generated -I$PWD/sim/ooe" \
      "$PWD/rtl/ooe/ooe_ready.sv" "$PWD/test/ooe/ready_tb.cpp" "$PWD/sim/ooe/ooe_core.cpp" \
      "$PWD/sim/ooe/ooe_test.cpp" >"$dir/build.log" 2>&1; then
  say "ready: builds" "FAIL (see $dir/build.log)"; tail -5 "$dir/build.log"; exit 1
fi
if out=$("$dir/ready_tb" "$seeds" 2>&1); then
  say "ready ($n entries) == model, live" "PASS ($(echo "$out" | tail -1 | sed 's/.*seeds=//'))"
else
  say "ready == model, live" "FAIL"; echo "$out" | tail -8; fail=1
fi
for c in code-shift no-late; do
  if READY_CONTROL=$c "$dir/ready_tb" 3 >/dev/null 2>&1; then
    say "  control $c (ready)" "MISSED"; fail=1
  else
    say "  control $c (ready)" "caught"
  fi
done
exit $fail
