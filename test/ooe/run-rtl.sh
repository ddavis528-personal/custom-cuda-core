#!/usr/bin/env bash
# OOE RTL in lockstep with the model, each harness's negative controls
# caught:
# - ooe_pick against ooe::pickResources (test/ooe/pick_tb.cpp), at both
#   RS classes' sizes: the lane-and-RCU class (CCV_P_RS_RCU entries, S0-S3
#   and R) and the MIU class (CCV_P_RS_MIU entries, P0-P3);
# - ooe_ready against the live model through its random unit tests
#   (test/ooe/ready_tb.cpp);
# - ooe_freelist against the model's own free lists, live, for the GPR rows
#   and the predicates (test/ooe/freelist_tb.cpp);
# - ooe_age against the model's RS ages, live, for both RS classes
#   (test/ooe/age_tb.cpp);
# - ooe_decq against the model's decode queue, live (test/ooe/decq_tb.cpp).
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

# ooe_freelist, driven from the model's own free lists after every cycle:
# the GPR rows and the predicates.
phys=$(sed -n 's/.*localparam int CCV_P_PHYS_REGS = \([0-9]*\);.*/\1/p' rtl/generated/ccv_params_pkg.sv)
preds=$(sed -n 's/.*localparam int CCV_P_PRED_REGS = \([0-9]*\);.*/\1/p' rtl/generated/ccv_params_pkg.sv)
width=$(sed -n 's/.*localparam int CCV_ISSUE_WIDTH = \([0-9]*\);.*/\1/p' rtl/generated/ccv_params_pkg.sv)
for cfg in "gpr 0 $phys" "pred 1 $preds"; do
  set -- $cfg
  name=$1 pool=$2 n=$3
  dir=build/ooe-rtl/freelist_$name
  mkdir -p "$dir"
  if ! verilator --cc --exe --build -j 0 -O2 --assert -Wall -Wno-UNUSEDSIGNAL -Wno-DECLFILENAME \
        -GN="$n" -GA="$width" --top-module ooe_freelist --Mdir "$dir" -o freelist_tb \
        -I"$PWD/rtl/include" -I"$PWD/rtl/generated" \
        -CFLAGS "-std=c++17 -O2 -DFL_N=$n -DFL_A=$width -DFL_POOL=$pool -DOOE_TEST_AS_LIBRARY -I$PWD/sim/generated -I$PWD/sim/ooe" \
        "$PWD/rtl/ccv_assert_pkg.sv" "$PWD/rtl/ooe/ooe_freelist.sv" "$PWD/test/ooe/freelist_tb.cpp" \
        "$PWD/sim/ooe/ooe_core.cpp" "$PWD/sim/ooe/ooe_test.cpp" >"$dir/build.log" 2>&1; then
    say "freelist $name: builds" "FAIL (see $dir/build.log)"; tail -5 "$dir/build.log"; fail=1; continue
  fi
  if out=$("$dir/freelist_tb" "$seeds" 2>&1); then
    say "freelist $name ($n entries, $width ports) == model, live" "PASS ($(echo "$out" | tail -1 | sed 's/.*seeds=//'))"
  else
    say "freelist $name == model, live" "FAIL"; echo "$out" | tail -8; fail=1
  fi
  for c in drop-free extra-alloc; do
    if FL_CONTROL=$c "$dir/freelist_tb" 3 >/dev/null 2>&1; then
      say "  control $c (freelist $name)" "MISSED"; fail=1
    else
      say "  control $c (freelist $name)" "caught"
    fi
  done
done

# ooe_age, driven from the model's RS allocations before every cycle: each
# RS class.
for cfg in "rcu 0 $n_rcu" "miu 1 $n_miu"; do
  set -- $cfg
  name=$1 cls=$2 n=$3
  dir=build/ooe-rtl/age_$name
  mkdir -p "$dir"
  if ! verilator --cc --exe --build -j 0 -O2 --assert -Wall -Wno-UNUSEDSIGNAL -Wno-DECLFILENAME \
        -GN="$n" -GA="$width" --top-module ooe_age --Mdir "$dir" -o age_tb \
        -I"$PWD/rtl/include" -I"$PWD/rtl/generated" \
        -CFLAGS "-std=c++17 -O2 -DAGE_N=$n -DAGE_A=$width -DAGE_CLS=$cls -DOOE_TEST_AS_LIBRARY -I$PWD/sim/generated -I$PWD/sim/ooe" \
        "$PWD/rtl/ccv_assert_pkg.sv" "$PWD/rtl/ooe/ooe_age.sv" "$PWD/test/ooe/age_tb.cpp" \
        "$PWD/sim/ooe/ooe_core.cpp" "$PWD/sim/ooe/ooe_test.cpp" >"$dir/build.log" 2>&1; then
    say "age $name: builds" "FAIL (see $dir/build.log)"; tail -5 "$dir/build.log"; fail=1; continue
  fi
  if out=$("$dir/age_tb" "$seeds" 2>&1); then
    say "age $name ($n entries, $width ports) == model, live" "PASS ($(echo "$out" | tail -1 | sed 's/.*seeds=//'))"
  else
    say "age $name == model, live" "FAIL"; echo "$out" | tail -8; fail=1
  fi
  for c in no-valid port-reverse; do
    if AGE_CONTROL=$c "$dir/age_tb" 3 >/dev/null 2>&1; then
      say "  control $c (age $name)" "MISSED"; fail=1
    else
      say "  control $c (age $name)" "caught"
    fi
  done
done

# ooe_decq, driven from the model's decode queue before every cycle. A
# control may be caught by the RTL's own assertion before the comparison:
# either fails the run.
slots=$(sed -n 's/.*localparam int CCV_TIER1_WARPS = \([0-9]*\);.*/\1/p' rtl/generated/ccv_params_pkg.sv)
decq=$(sed -n 's/.*localparam int CCV_P_DECQ = \([0-9]*\);.*/\1/p' rtl/generated/ccv_params_pkg.sv)
decq_warp=$(sed -n 's/.*localparam int CCV_P_DECQ_WARP_MAX = \([0-9]*\);.*/\1/p' rtl/generated/ccv_params_pkg.sv)
uops=$(python3 -c "import json; print(next(c['rate'] for c in json.load(open('schema/interfaces.json'))['channels'] if c['name'] == 'ccv_dec_ooe_uop'))")
dir=build/ooe-rtl/decq
mkdir -p "$dir"
if ! verilator --cc --exe --build -j 0 -O2 --assert -Wall -Wno-UNUSEDSIGNAL -Wno-DECLFILENAME \
      -GS="$slots" -GQ="$decq" -GD="$decq_warp" -GE="$uops" -GR="$width" -GP=16 --top-module ooe_decq \
      --Mdir "$dir" -o decq_tb -I"$PWD/rtl/include" -I"$PWD/rtl/generated" \
      -CFLAGS "-std=c++17 -O2 -DDQ_S=$slots -DDQ_Q=$decq -DDQ_D=$decq_warp -DDQ_E=$uops -DDQ_R=$width -DOOE_TEST_AS_LIBRARY -I$PWD/sim/generated -I$PWD/sim/ooe" \
      "$PWD/rtl/ccv_assert_pkg.sv" "$PWD/rtl/ooe/ooe_decq.sv" "$PWD/test/ooe/decq_tb.cpp" \
      "$PWD/sim/ooe/ooe_core.cpp" "$PWD/sim/ooe/ooe_test.cpp" >"$dir/build.log" 2>&1; then
  say "decq: builds" "FAIL (see $dir/build.log)"; tail -5 "$dir/build.log"; exit 1
fi
if out=$("$dir/decq_tb" "$seeds" 2>&1); then
  say "decq ($decq entries, $slots slots, $uops in, $width out) == model, live" "PASS ($(echo "$out" | tail -1 | sed 's/.*seeds=//'))"
else
  say "decq == model, live" "FAIL"; echo "$out" | tail -8; fail=1
fi
for c in drop-flush enq-swap; do
  if DECQ_CONTROL=$c "$dir/decq_tb" 3 >/dev/null 2>&1; then
    say "  control $c (decq)" "MISSED"; fail=1
  else
    say "  control $c (decq)" "caught"
  fi
done
exit $fail
