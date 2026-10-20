#!/usr/bin/env bash
# OOE RTL in lockstep with the model, each harness's negative controls
# caught:
# - ooe_pick against ooe::pickResources (test/ooe/pick_tb.cpp), at both
#   RS classes' sizes: the lane-and-RCU class (CCV_P_RS_RCU entries, S0-S3
#   and R) and the MIU class (CCV_P_RS_MIU entries, P0-P3);
# - ooe_ready against the live model through its random unit tests
#   (test/ooe/ready_tb.cpp);
# - ooe_freelist against the model's own free lists, live, for the GPR rows
#   and the predicates, in its buffered form (test/ooe/freelist_tb.cpp);
# - ooe_age against the model's RS ages, live, for both RS classes
#   (test/ooe/age_tb.cpp);
# - ooe_decq against the model's decode queue, live (test/ooe/decq_tb.cpp);
# - ooe_wake against the model's wake lines and L1 miss cancels, live
#   (test/ooe/wake_tb.cpp);
# - ooe_confirm against the model's cancel hops and confirmations, live
#   (test/ooe/confirm_tb.cpp);
# - ooe_rs against the model's RS allocations, frees and dependency cells,
#   live (test/ooe/rs_tb.cpp);
# - ooe_select against the model's sectioned select, live
#   (test/ooe/select_tb.cpp);
# - ooe_rat against the model's alias tables and checkpoints, live, through
#   its directed and random unit tests (test/ooe/rat_tb.cpp).
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
# The RCU class with the section fallback ooe_select gives it (FB 1, OA's
# response IS-9), and with the aligned-half pick too (FB 2, measured but
# over the stage), so both stay held to the model; the MIU pipes take none.
for cfg in "rcu $n_rcu $((secs + 1)) 1" "rcuh $n_rcu $((secs + 1)) 2" "miu $n_miu $pipes 0"; do
  set -- $cfg
  name=$1 n=$2 r=$3 fb=$4
  dir=build/ooe-rtl/pick_$name
  mkdir -p "$dir"
  if ! verilator --cc --exe --build -j 0 -O2 -Wall -Wno-UNUSEDSIGNAL \
        -GN="$n" -GR="$r" -GFB="$fb" --top-module ooe_pick --Mdir "$dir" -o pick_tb \
        -CFLAGS "-std=c++17 -O2 -DPICK_N=$n -DPICK_R=$r -DPICK_FB=$fb -I$PWD/sim/generated -I$PWD/sim/ooe" \
        "$PWD/rtl/ooe/ooe_pick.sv" "$PWD/test/ooe/pick_tb.cpp" "$PWD/sim/ooe/ooe_core.cpp" \
        >"$dir/build.log" 2>&1; then
    say "pick $name: builds" "FAIL (see $dir/build.log)"; tail -5 "$dir/build.log"; fail=1; continue
  fi
  if out=$("$dir/pick_tb" "$vectors" 1 2>&1); then
    say "pick $name ($n entries, $r resources) == model" "PASS ($(echo "$out" | tail -1 | sed 's/.*vectors=//'))"
  else
    say "pick $name == model" "FAIL"; echo "$out" | tail -8; fail=1
  fi
  ctls="youngest-wins any-wins no-mask"
  [ "$fb" -ge 1 ] && ctls="$ctls no-fallback"
  [ "$fb" -ge 2 ] && ctls="$ctls no-half"
  for c in $ctls; do
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
# The candidate buffer and refill banks: the model's defaults (OA's response
# OI-38), read from its Config so the two cannot drift.
fl_buf=$(sed -n 's/.*unsigned fl_buf = \([0-9]*\);.*/\1/p' sim/ooe/ooe_core.h)
fl_banks=$(sed -n 's/.*unsigned fl_banks = \([0-9]*\);.*/\1/p' sim/ooe/ooe_core.h)
for cfg in "gpr 0 $phys" "pred 1 $preds"; do
  set -- $cfg
  name=$1 pool=$2 n=$3
  dir=build/ooe-rtl/freelist_$name
  mkdir -p "$dir"
  if ! verilator --cc --exe --build -j 0 -O2 --assert -Wall -Wno-UNUSEDSIGNAL -Wno-DECLFILENAME \
        --trace -DCCV_CHECK -GN="$n" -GA="$width" -GB="$fl_buf" -GK="$fl_banks" --top-module ooe_freelist --Mdir "$dir" -o freelist_tb \
        -I"$PWD/rtl/include" -I"$PWD/rtl/generated" \
        -CFLAGS "-std=c++17 -O2 -DFL_N=$n -DFL_A=$width -DFL_B=$fl_buf -DFL_K=$fl_banks -DFL_POOL=$pool -DOOE_TEST_AS_LIBRARY -I$PWD/sim/generated -I$PWD/sim/ooe" \
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
        --trace -GN="$n" -GA="$width" --top-module ooe_age --Mdir "$dir" -o age_tb \
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
      --trace -GS="$slots" -GQ="$decq" -GD="$decq_warp" -GE="$uops" -GR="$width" -GP=16 --top-module ooe_decq \
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

# ooe_wake, driven from the model's wake log after every cycle. Its
# latencies, bypass points and penalties are the parameters'; the model's
# payload stages come from its Config. wake_tb skips a core configured
# otherwise. Its bench and confirm's carry the clock-gating trace (cg_trace.h),
# so they link Verilator's VCD writer.
read -r wake_g wake_d < <(python3 test/ooe/wake-params.py)
dir=build/ooe-rtl/wake
mkdir -p "$dir"
if ! verilator --cc --exe --build -j 0 -O2 --assert -Wall -Wno-UNUSEDSIGNAL -Wno-DECLFILENAME \
      --trace ${wake_g//,/ } --top-module ooe_wake --Mdir "$dir" -o wake_tb \
      -I"$PWD/rtl/include" -I"$PWD/rtl/generated" \
      -CFLAGS "-std=c++17 -O2 ${wake_d//,/ } -DOOE_TEST_AS_LIBRARY -I$PWD/sim/generated -I$PWD/sim/ooe" \
      "$PWD/rtl/ccv_assert_pkg.sv" "$PWD/rtl/ooe/ooe_wake.sv" "$PWD/test/ooe/wake_tb.cpp" \
      "$PWD/sim/ooe/ooe_core.cpp" "$PWD/sim/ooe/ooe_test.cpp" >"$dir/build.log" 2>&1; then
  say "wake: builds" "FAIL (see $dir/build.log)"; tail -5 "$dir/build.log"; exit 1
fi
n=$((n_rcu + n_miu))
if out=$("$dir/wake_tb" "$seeds" 2>&1); then
  say "wake ($n timers, 4 lines) == model, live" "PASS ($(echo "$out" | tail -1 | sed 's/.*seeds=//'))"
else
  say "wake == model, live" "FAIL"; echo "$out" | tail -8; fail=1
fi
for c in late-grant drop-cmpl drop-stop; do
  if WAKE_CONTROL=$c "$dir/wake_tb" 3 >/dev/null 2>&1; then
    say "  control $c (wake)" "MISSED"; fail=1
  else
    say "  control $c (wake)" "caught"
  fi
done

# ooe_confirm, driven from the model's cancel hop and confirmation pass
# after every cycle.
dir=build/ooe-rtl/confirm
mkdir -p "$dir"
if ! verilator --cc --exe --build -j 0 -O2 --assert -Wall -Wno-UNUSEDSIGNAL -Wno-DECLFILENAME \
      -GN="$n" --top-module ooe_confirm --Mdir "$dir" -o confirm_tb \
      -I"$PWD/rtl/include" -I"$PWD/rtl/generated" \
      -CFLAGS "-std=c++17 -O2 -DCONFIRM_N=$n -DOOE_TEST_AS_LIBRARY -I$PWD/sim/generated -I$PWD/sim/ooe" \
      "$PWD/rtl/ccv_assert_pkg.sv" "$PWD/rtl/ooe/ooe_confirm.sv" "$PWD/test/ooe/confirm_tb.cpp" \
      "$PWD/sim/ooe/ooe_core.cpp" "$PWD/sim/ooe/ooe_test.cpp" >"$dir/build.log" 2>&1; then
  say "confirm: builds" "FAIL (see $dir/build.log)"; tail -5 "$dir/build.log"; exit 1
fi
if out=$("$dir/confirm_tb" "$seeds" 2>&1); then
  say "confirm ($n entries) == model, live" "PASS ($(echo "$out" | tail -1 | sed 's/.*seeds=//'))"
else
  say "confirm == model, live" "FAIL"; echo "$out" | tail -8; fail=1
fi
for c in no-msd msd-pulse no-fin no-dep; do
  if CONFIRM_CONTROL=$c "$dir/confirm_tb" 3 >/dev/null 2>&1; then
    say "  control $c (confirm)" "MISSED"; fail=1
  else
    say "  control $c (confirm)" "caught"
  fi
done

# ooe_rs, driven from the model's RS allocations and frees after every
# cycle. A control may be caught by the RTL's own assertion before the
# comparison: either fails the run.
dir=build/ooe-rtl/rs
mkdir -p "$dir"
if ! verilator --cc --exe --build -j 0 -O2 --assert -Wall -Wno-UNUSEDSIGNAL -Wno-DECLFILENAME \
      --trace -GN="$n" -GNR="$n_rcu" -GA="$width" --top-module ooe_rs --Mdir "$dir" -o rs_tb \
      -I"$PWD/rtl/include" -I"$PWD/rtl/generated" \
      -CFLAGS "-std=c++17 -O2 -DRS_N=$n -DRS_NR=$n_rcu -DRS_A=$width -DOOE_TEST_AS_LIBRARY -I$PWD/sim/generated -I$PWD/sim/ooe" \
      "$PWD/rtl/ccv_assert_pkg.sv" "$PWD/rtl/ooe/ooe_rs.sv" "$PWD/test/ooe/rs_tb.cpp" \
      "$PWD/sim/ooe/ooe_core.cpp" "$PWD/sim/ooe/ooe_test.cpp" >"$dir/build.log" 2>&1; then
  say "rs: builds" "FAIL (see $dir/build.log)"; tail -5 "$dir/build.log"; exit 1
fi
if out=$("$dir/rs_tb" "$seeds" 2>&1); then
  say "rs ($n entries, $width ports a class) == model, live" "PASS ($(echo "$out" | tail -1 | sed 's/.*seeds=//'))"
else
  say "rs == model, live" "FAIL"; echo "$out" | tail -8; fail=1
fi
for c in no-same-edge drop-group stale-hcol; do
  if RS_CONTROL=$c "$dir/rs_tb" 3 >/dev/null 2>&1; then
    say "  control $c (rs)" "MISSED"; fail=1
  else
    say "  control $c (rs)" "caught"
  fi
done

# ooe_rat, driven from the model's RAT log after every cycle, through the
# directed tests (demotion, kill, restore-allocate) and the random ones. A
# GPR name is a row and a position; the zero GPR is the zero row at
# position 0.
read -r rat_g rat_d < <(python3 test/ooe/rat-params.py)
dir=build/ooe-rtl/rat
mkdir -p "$dir"
if ! verilator --cc --exe --build -j 0 -O2 --assert -Wall -Wno-UNUSEDSIGNAL -Wno-DECLFILENAME \
      --trace ${rat_g//,/ } --top-module ooe_rat --Mdir "$dir" -o rat_tb \
      -I"$PWD/rtl/include" -I"$PWD/rtl/generated" \
      -CFLAGS "-std=c++17 -O2 ${rat_d//,/ } -DOOE_TEST_AS_LIBRARY -I$PWD/sim/generated -I$PWD/sim/ooe" \
      "$PWD/rtl/ccv_assert_pkg.sv" "$PWD/rtl/ooe/ooe_rat.sv" "$PWD/test/ooe/rat_tb.cpp" \
      "$PWD/sim/ooe/ooe_core.cpp" "$PWD/sim/ooe/ooe_test.cpp" >"$dir/build.log" 2>&1; then
  say "rat: builds" "FAIL (see $dir/build.log)"; tail -5 "$dir/build.log"; exit 1
fi
if out=$("$dir/rat_tb" "$seeds" 2>&1); then
  say "rat (4 slots, 4 ports) == model, live" "PASS ($(echo "$out" | tail -1 | sed 's/.*seeds=//'))"
else
  say "rat == model, live" "FAIL"; echo "$out" | tail -8; fail=1
fi
for c in port-reverse drop-restore drop-retire drop-squash; do
  if RAT_CONTROL=$c "$dir/rat_tb" 3 >/dev/null 2>&1; then
    say "  control $c (rat)" "MISSED"; fail=1
  else
    say "  control $c (rat)" "caught"
  fi
done

# ooe_select, with its two ooe_picks, driven from the model's sectioned
# select after every cycle it ran.
# Its section fallback is the model's (Config::pick_fallback), read from
# the model so the two cannot drift.
pick_fb=$(sed -n 's/.*unsigned pick_fallback = \([0-9]*\);.*/\1/p' sim/ooe/ooe_core.h)
dir=build/ooe-rtl/select
mkdir -p "$dir"
if ! verilator --cc --exe --build -j 0 -O2 --assert -Wall -Wno-UNUSEDSIGNAL -Wno-DECLFILENAME \
      -GN="$n" -GNR="$n_rcu" -GS="$slots" -GFB="$pick_fb" --top-module ooe_select --Mdir "$dir" -o select_tb \
      -CFLAGS "-std=c++17 -O2 -DSEL_N=$n -DSEL_NR=$n_rcu -DSEL_S=$slots -DOOE_TEST_AS_LIBRARY -I$PWD/sim/generated -I$PWD/sim/ooe" \
      "$PWD/rtl/ooe/ooe_pick.sv" "$PWD/rtl/ooe/ooe_select.sv" "$PWD/test/ooe/select_tb.cpp" \
      "$PWD/sim/ooe/ooe_core.cpp" "$PWD/sim/ooe/ooe_test.cpp" >"$dir/build.log" 2>&1; then
  say "select: builds" "FAIL (see $dir/build.log)"; tail -5 "$dir/build.log"; exit 1
fi
if out=$("$dir/select_tb" "$seeds" 2>&1); then
  say "select ($n entries, 9 resources) == model, live" "PASS ($(echo "$out" | tail -1 | sed 's/.*seeds=//'))"
else
  say "select == model, live" "FAIL"; echo "$out" | tail -8; fail=1
fi
for c in no-order no-conf no-busy; do
  if SELECT_CONTROL=$c "$dir/select_tb" 3 >/dev/null 2>&1; then
    say "  control $c (select)" "MISSED"; fail=1
  else
    say "  control $c (select)" "caught"
  fi
done
exit $fail
