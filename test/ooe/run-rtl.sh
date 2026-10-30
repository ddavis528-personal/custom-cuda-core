#!/usr/bin/env bash
# OOE RTL in lockstep with the model, each harness's negative controls
# caught:
# - ooe_pick against ooe::pickResources (test/ooe/pick_tb.cpp), at both
#   RS classes' sizes: the lane-and-RCU class (CCV_P_RS_RCU entries, S0-S3
#   and R) and the MIU class (CCV_P_RS_MIU entries, P0-P3);
# - ooe_ready against the live model through its random unit tests
#   (test/ooe/ready_tb.cpp);
# - ccv_common_csa against arithmetic (test/common/csa_tb.cpp);
# - ooe_freelist against the model's own free lists, live, for the GPR rows,
#   the GPR rows with their sections and home candidates (OI-81, OI-82),
#   and the predicates, in its buffered form (test/ooe/freelist_tb.cpp);
# - ooe_age against the model's RS ages, live, for both RS classes
#   (test/ooe/age_tb.cpp);
# - ooe_decq against the model's decode queue, live (test/ooe/decq_tb.cpp);
# - ooe_go, rename's go, against the model's go log, live (test/ooe/go_tb.cpp);
# - ooe_wake against the model's wake lines and L1 miss cancels, live
#   (test/ooe/wake_tb.cpp);
# - ooe_confirm against the model's cancel hops and confirmations, live
#   (test/ooe/confirm_tb.cpp);
# - ooe_rs against the model's RS allocations, frees and dependency cells,
#   live (test/ooe/rs_tb.cpp);
# - ooe_select against the model's sectioned select, live
#   (test/ooe/select_tb.cpp);
# - ooe_rs, ooe_wake and ooe_sched assembled (ooe_sched: ooe_ready, its
#   ready and request registers, ooe_select and its grant register)
#   against the model's registers and grants, live, under its composed
#   timing (test/ooe/trio_tb.cpp, test/ooe/ooe_trio.sv);
# - ooe_rendep (with ooe_prodmap) against the model's renames and
#   dependency cells, live (test/ooe/rendep_tb.cpp);
# - ooe_prodmap, ooe_rendep and ooe_rs assembled, against the model's RS
#   rows, with the surviving-bit assertion (test/ooe/rnrs_tb.cpp);
# - ooe_rencred against the model's rename credits, live (test/ooe/rencred_tb.cpp);
# - ooe_rat against the model's alias tables and checkpoints, live, through
#   its directed and random unit tests (test/ooe/rat_tb.cpp);
# - Rename 1 (ooe_headrd, ooe_ren1, its register, ooe_ren1n) against the
#   model's renames, live (test/ooe/ren1_tb.cpp);
# - ooe_rename (the go, Rename 1 and 2, the free lists) beside ooe_rat
#   against the model's takes, renames, names and RS rows, live
#   (test/ooe/rename_tb.cpp).
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

# ccv_common_csa (rtl/common/; test/common/csa_tb.cpp), the carry-save
# adder OOE's counters use, against arithmetic at the sizes they and the
# free lists use and the corners: one operand, two, a single level, 16
# groups and 18.
for nw in 1,8 2,8 3,5 4,9 5,9 6,8 16,8 18,9; do
  cn=${nw%,*} cw=${nw#*,}
  dir=build/ooe-rtl/csa_${cn}_$cw
  mkdir -p "$dir"
  if ! verilator --cc --exe --build -j 0 -O2 -Wall -Wno-UNUSEDSIGNAL -Wno-DECLFILENAME -GN="$cn" -GW="$cw" \
        --top-module ccv_common_csa --Mdir "$dir" -o csa_tb -CFLAGS "-std=c++17 -O2 -DCSA_N=$cn -DCSA_W=$cw" \
        "$PWD/rtl/common/ccv_common_csa.sv" "$PWD/test/common/csa_tb.cpp" >"$dir/build.log" 2>&1; then
    say "csa $cn x $cw: builds" "FAIL (see $dir/build.log)"; tail -5 "$dir/build.log"; fail=1; continue
  fi
  if out=$("$dir/csa_tb" 2>&1); then
    say "csa ($cn operands of $cw bits) == arithmetic" "PASS ($(echo "$out" | tail -1 | sed 's/.*tests=//'))"
  else
    say "csa $cn x $cw == arithmetic" "FAIL"; echo "$out" | tail -4; fail=1
  fi
  if CSA_CONTROL=drop-op "$dir/csa_tb" 1000 >/dev/null 2>&1; then
    say "  control drop-op (csa $cn x $cw)" "MISSED"; fail=1
  else
    say "  control drop-op (csa $cn x $cw)" "caught"
  fi
done

# ooe_freelist, driven from the model's own free lists after every cycle:
# the GPR rows, the GPR rows with their sections, and the predicates.
phys=$(sed -n 's/.*localparam int CCV_P_PHYS_REGS = \([0-9]*\);.*/\1/p' rtl/generated/ccv_params_pkg.sv)
preds=$(sed -n 's/.*localparam int CCV_P_PRED_REGS = \([0-9]*\);.*/\1/p' rtl/generated/ccv_params_pkg.sv)
width=$(sed -n 's/.*localparam int CCV_ISSUE_WIDTH = \([0-9]*\);.*/\1/p' rtl/generated/ccv_params_pkg.sv)
# The candidate buffer and refill banks: the model's defaults (OA's response
# OI-38), read from its Config so the two cannot drift.
fl_buf=$(sed -n 's/.*unsigned fl_buf = \([0-9]*\);.*/\1/p' sim/ooe/ooe_core.h)
fl_banks=$(sed -n 's/.*unsigned fl_banks = \([0-9]*\);.*/\1/p' sim/ooe/ooe_core.h)
fl_slots=$(sed -n 's/.*localparam int CCV_TIER1_WARPS = \([0-9]*\);.*/\1/p' rtl/generated/ccv_params_pkg.sv)
# gsec: the GPR rows with their sections and candidates (NS 4, OI-81/82), a
# section per position (CCV_W_PHYS_POS bits).
ns=$((1 << $(sed -n 's/.*localparam int CCV_W_PHYS_POS = \([0-9]*\);.*/\1/p' rtl/generated/ccv_params_pkg.sv)))
for cfg in "gpr 0 $phys 0" "gsec 0 $phys $ns" "pred 1 $preds 0"; do
  set -- $cfg
  name=$1 pool=$2 n=$3 sec=$4
  dir=build/ooe-rtl/freelist_$name
  mkdir -p "$dir"
  if ! verilator --cc --exe --build -j 0 -O2 --assert -Wall -Wno-UNUSEDSIGNAL -Wno-DECLFILENAME \
        --trace -DCCV_CHECK -GN="$n" -GA="$width" -GB="$fl_buf" -GK="$fl_banks" -GS="$fl_slots" -GNS="$sec" --top-module ooe_freelist --Mdir "$dir" -o freelist_tb \
        -I"$PWD/rtl/include" -I"$PWD/rtl/generated" \
        -CFLAGS "-std=c++17 -O2 -DFL_N=$n -DFL_A=$width -DFL_B=$fl_buf -DFL_K=$fl_banks -DFL_S=$fl_slots -DFL_POOL=$pool -DFL_NS=$sec -DOOE_TEST_AS_LIBRARY -I$PWD/sim/generated -I$PWD/sim/ooe" \
        "$PWD/rtl/ccv_assert_pkg.sv" "$PWD/rtl/common/ccv_common_csa.sv" "$PWD/rtl/ooe/ooe_freelist.sv" "$PWD/test/ooe/freelist_tb.cpp" \
        "$PWD/sim/ooe/ooe_core.cpp" "$PWD/sim/ooe/ooe_test.cpp" >"$dir/build.log" 2>&1; then
    say "freelist $name: builds" "FAIL (see $dir/build.log)"; tail -5 "$dir/build.log"; fail=1; continue
  fi
  if out=$("$dir/freelist_tb" "$seeds" 2>&1); then
    say "freelist $name ($n entries, $width ports) == model, live" "PASS ($(echo "$out" | tail -1 | sed 's/.*seeds=//'))"
  else
    say "freelist $name == model, live" "FAIL"; echo "$out" | tail -8; fail=1
  fi
  ctl="drop-free extra-alloc no-lead wrong-owner"
  [ "$sec" != 0 ] && ctl="drop-sec-free sa-early no-lead"
  for c in $ctl; do
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
  for c in no-valid port-reverse no-lead; do
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
for c in drop-flush enq-swap no-enq-lead no-take-enable; do
  if DECQ_CONTROL=$c "$dir/decq_tb" 3 >/dev/null 2>&1; then
    say "  control $c (decq)" "MISSED"; fail=1
  else
    say "  control $c (decq)" "caught"
  fi
done

# ooe_go, rename's go, driven from the model's go log (Core::goLog) every
# cycle a model cycle behind (its leads are the next cycle's log), its takes
# and lanes compared exactly. Cores with other than its slots are skipped.
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

# ooe_rob, the ROB (slice 1, OI-85), driven from the model's ROB log
# (Core::robLog) a model cycle behind, with retire_lag 1: its retirements,
# their leads and frees, and the room rename's go reads compared exactly.
# A core stops at the first thing slice 1 does not build (a squash, a fault,
# a retire port, an atomic).
dir=build/ooe-rtl/rob
mkdir -p "$dir"
rv() { sed -n "s/.*localparam int $1 = \([0-9]*\);.*/\1/p" rtl/generated/ccv_params_pkg.sv; }
rob_p="S=$slots D=$(rv CCV_P_ROB_DEPTH) RP=$(rv CCV_RETIRE_PER_ROB) A=$width ND=7 NM=4"
rob_p="$rob_p GW=$(( $(rv CCV_P_W_PHYS_REG) + $(rv CCV_W_PHYS_POS) )) GR=$(rv CCV_P_W_PHYS_REG) NG=$(rv CCV_P_PHYS_REGS)"
rob_p="$rob_p NS=$(( 1 << $(rv CCV_W_PHYS_POS) )) PW=$(rv CCV_P_W_PHYS_PRED) NP=$(rv CCV_P_PRED_REGS)"
if ! verilator --cc --exe --build -j 0 -O2 --assert -Wall -Wno-UNUSEDSIGNAL -Wno-DECLFILENAME \
      --trace $(for kv in $rob_p; do printf -- '-G%s ' "$kv"; done) --top-module ooe_rob \
      --Mdir "$dir" -o rob_tb -I"$PWD/rtl/include" -I"$PWD/rtl/generated" \
      -CFLAGS "-std=c++17 -O2 -I$PWD/test/ooe $(for kv in $rob_p; do printf -- '-DRB_%s ' "$kv"; done) -DOOE_TEST_AS_LIBRARY -I$PWD/sim/generated -I$PWD/sim/ooe" \
      "$PWD/rtl/ccv_assert_pkg.sv" "$PWD/rtl/ooe/ooe_rob.sv" "$PWD/test/ooe/rob_tb.cpp" \
      "$PWD/sim/ooe/ooe_core.cpp" "$PWD/sim/ooe/ooe_test.cpp" >"$dir/build.log" 2>&1; then
  say "rob: builds" "FAIL (see $dir/build.log)"; tail -5 "$dir/build.log"; exit 1
fi
if out=$("$dir/rob_tb" "$seeds" 2>&1) && grep -q "mismatches=0 model_failures=0" <<<"$out"; then
  say "rob ($slots slots) == model, live" "PASS ($(grep '^rob_tb' <<<"$out" | sed 's/.*seeds=//'))"
else
  say "rob == model, live" "FAIL"; echo "$out" | tail -8; fail=1
fi
for c in drop-free no-copy no-lead fill-order nop-real two-in-a-cycle; do
  if ROB_CONTROL=$c "$dir/rob_tb" 3 >/dev/null 2>&1; then
    say "  control $c (rob)" "MISSED"; fail=1
  else
    say "  control $c (rob)" "caught"
  fi
done

# ooe_wake, driven from the model's wake log after every cycle. Its
# latencies, bypass points and penalties are the parameters'; the model's
# payload stages come from its Config. wake_tb skips a core configured
# otherwise. It replays and confirms on its own (OI-45), with ooe_confirm
# inside, from ooe_rs's matrix as the model's hop read it. Its bench and
# confirm's carry the clock-gating trace (cg_trace.h), so they link
# Verilator's VCD writer.
read -r wake_g wake_d < <(python3 test/ooe/wake-params.py)
dir=build/ooe-rtl/wake
mkdir -p "$dir"
if ! verilator --cc --exe --build -j 0 -O2 --assert -Wall -Wno-UNUSEDSIGNAL -Wno-DECLFILENAME \
      --trace ${wake_g//,/ } --top-module ooe_wake --Mdir "$dir" -o wake_tb \
      -I"$PWD/rtl/include" -I"$PWD/rtl/generated" \
      -CFLAGS "-std=c++17 -O2 ${wake_d//,/ } -DOOE_TEST_AS_LIBRARY -I$PWD/sim/generated -I$PWD/sim/ooe" \
      "$PWD/rtl/ccv_assert_pkg.sv" "$PWD/rtl/ooe/ooe_wake.sv" "$PWD/rtl/ooe/ooe_confirm.sv" "$PWD/test/ooe/wake_tb.cpp" \
      "$PWD/sim/ooe/ooe_core.cpp" "$PWD/sim/ooe/ooe_test.cpp" >"$dir/build.log" 2>&1; then
  say "wake: builds" "FAIL (see $dir/build.log)"; tail -5 "$dir/build.log"; exit 1
fi
n=$((n_rcu + n_miu))
if out=$("$dir/wake_tb" "$seeds" 2>&1); then
  say "wake ($n timers, 4 lines) == model, live" "PASS ($(echo "$out" | tail -1 | sed 's/.*seeds=//'))"
else
  say "wake == model, live" "FAIL"; echo "$out" | tail -8; fail=1
fi
for c in late-grant drop-cmpl no-dep drop-squash-free no-cmpl-lead no-sq-lead no-hint; do
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

# ooe_prodmap, the RS entries' names rename compares a source with, driven
# from the model's renames after every cycle, two cycles behind.
dir=build/ooe-rtl/prodmap
mkdir -p "$dir"
ng=$(( $(sed -n 's/.*localparam int CCV_P_PHYS_REGS = \([0-9]*\);.*/\1/p' rtl/generated/ccv_params_pkg.sv) * 4 ))
np=$(sed -n 's/.*localparam int CCV_P_PRED_REGS = \([0-9]*\);.*/\1/p' rtl/generated/ccv_params_pkg.sv)
if ! verilator --cc --exe --build -j 0 -O2 --assert -Wall -Wno-UNUSEDSIGNAL -Wno-DECLFILENAME \
      --trace -GN="$n" -GNR="$n_rcu" -GA="$width" -GNG="$ng" -GNP="$np" --top-module ooe_prodmap --Mdir "$dir" \
      -o prodmap_tb -I"$PWD/rtl/include" -I"$PWD/rtl/generated" \
      -CFLAGS "-std=c++17 -O2 -DPM_N=$n -DPM_NR=$n_rcu -DPM_A=$width -DPM_NG=$ng -DPM_NP=$np -DOOE_TEST_AS_LIBRARY -I$PWD/sim/generated -I$PWD/sim/ooe -I$PWD/test/ooe" \
      "$PWD/rtl/ccv_assert_pkg.sv" "$PWD/rtl/ooe/ooe_prodmap.sv" "$PWD/test/ooe/prodmap_tb.cpp" \
      "$PWD/sim/ooe/ooe_core.cpp" "$PWD/sim/ooe/ooe_test.cpp" >"$dir/build.log" 2>&1; then
  say "prodmap: builds" "FAIL (see $dir/build.log)"; tail -5 "$dir/build.log"; exit 1
fi
if out=$("$dir/prodmap_tb" "$seeds" 2>&1); then
  say "prodmap ($n entries, $ng GPR names) == model, live" "PASS ($(echo "$out" | tail -1 | sed 's/.*seeds=//'))"
else
  say "prodmap == model, live" "FAIL"; echo "$out" | tail -8; fail=1
fi
for c in no-ename port-swap no-lead; do
  if PM_CONTROL=$c "$dir/prodmap_tb" 3 >/dev/null 2>&1; then
    say "  control $c (prodmap)" "MISSED"; fail=1
  else
    say "  control $c (prodmap)" "caught"
  fi
done

# ooe_rendep, rename's producer lookup and stage register into ooe_rs,
# beside the ooe_prodmap whose names it reads (test/ooe/ooe_rendep_tb.sv),
# driven from the model's renames after every cycle. Its bypass table's
# default is rendep-params.py's, from the parameters, and must stay so: the
# bench compares codes only on cores that run that table.
ct_gen=$(python3 test/ooe/rendep-params.py | tr ',' '\n' | sed -n "s/^-GCT=//p")
ct_rtl=$(sed -n "s/.*parameter logic \[2\*NU\*G\*G-1:0\] CT *= *\([0-9]*'h[0-9a-f]*\).*/\1/p" rtl/ooe/ooe_rendep.sv)
if [ -n "$ct_gen" ] && [ "$ct_gen" = "$ct_rtl" ]; then
  say "rendep: CT default == rendep-params.py" "PASS"
else
  say "rendep: CT default == rendep-params.py" "FAIL"; fail=1
fi
dir=build/ooe-rtl/rendep
mkdir -p "$dir"
if ! verilator --cc --exe --build -j 0 -O2 --assert -Wall -Wno-UNUSEDSIGNAL -Wno-DECLFILENAME \
      --trace -GN="$n" -GNR="$n_rcu" -GA="$width" -GNG="$ng" -GNP="$np" --top-module ooe_rendep_tb --Mdir "$dir" \
      -o rendep_tb -I"$PWD/rtl/include" -I"$PWD/rtl/generated" \
      -CFLAGS "-std=c++17 -O1 -DRD_N=$n -DRD_NR=$n_rcu -DRD_A=$width -DRD_NG=$ng -DRD_NP=$np -DOOE_TEST_AS_LIBRARY -I$PWD/sim/generated -I$PWD/sim/ooe -I$PWD/test/ooe" \
      "$PWD/rtl/ccv_assert_pkg.sv" "$PWD/rtl/ooe/ooe_prodmap.sv" "$PWD/rtl/ooe/ooe_rendep.sv" \
      "$PWD/test/ooe/ooe_rendep_tb.sv" "$PWD/test/ooe/rendep_tb.cpp" \
      "$PWD/sim/ooe/ooe_core.cpp" "$PWD/sim/ooe/ooe_test.cpp" >"$dir/build.log" 2>&1; then
  say "rendep: builds" "FAIL (see $dir/build.log)"; tail -5 "$dir/build.log"; exit 1
fi
if out=$("$dir/rendep_tb" "$seeds" 2>&1); then
  say "rendep ($n entries, $width uops) == model, live" "PASS ($(echo "$out" | tail -1 | sed 's/.*seeds=//'))"
else
  say "rendep == model, live" "FAIL"; echo "$out" | tail -8; fail=1
fi
for c in no-map late-code no-copy-src; do
  if RD_CONTROL=$c "$dir/rendep_tb" 3 >/dev/null 2>&1; then
    say "  control $c (rendep)" "MISSED"; fail=1
  else
    say "  control $c (rendep)" "caught"
  fi
done

# ooe_prodmap, ooe_rendep and ooe_rs assembled as rename and the RS wire
# them (test/ooe/ooe_rnrs.sv; OA's rev 168): rename's stage register is
# ooe_rs's rows and ooe_rs's registered grant is rename's. The model drives
# rename's fields and the RS's other inputs, and ooe_rs's rows are held to
# its own; the wrapper's assertion holds every row bit written to a name of
# its row's sources (surviving_named). Both controls must fire it.
dir=build/ooe-rtl/rnrs
mkdir -p "$dir"
nc=$(python3 -c "import json; print(next(c['rate'] for c in json.load(open('schema/interfaces.json'))['channels'] if c['name'] == 'ccv_miu_ooe_cmpl'))")
if ! verilator --cc --exe --build -j 0 -O2 --assert -Wall -Wno-UNUSEDSIGNAL -Wno-DECLFILENAME \
      --trace -GN="$n" -GNR="$n_rcu" -GA="$width" -GNG="$ng" -GNP="$np" -GNC="$nc" --top-module ooe_rnrs --Mdir "$dir" \
      -o rnrs_tb -I"$PWD/rtl/include" -I"$PWD/rtl/generated" \
      -CFLAGS "-std=c++17 -O1 -DRN_N=$n -DRN_NR=$n_rcu -DRN_A=$width -DRN_NG=$ng -DRN_NP=$np -DRN_NC=$nc -DOOE_TEST_AS_LIBRARY -I$PWD/sim/generated -I$PWD/sim/ooe -I$PWD/test/ooe" \
      "$PWD/rtl/ccv_assert_pkg.sv" "$PWD/rtl/ooe/ooe_prodmap.sv" "$PWD/rtl/ooe/ooe_rendep.sv" \
      "$PWD/rtl/ooe/ooe_rs.sv" "$PWD/test/ooe/ooe_rnrs.sv" "$PWD/test/ooe/rnrs_tb.cpp" \
      "$PWD/sim/ooe/ooe_core.cpp" "$PWD/sim/ooe/ooe_test.cpp" >"$dir/build.log" 2>&1; then
  say "rnrs: builds" "FAIL (see $dir/build.log)"; tail -5 "$dir/build.log"; exit 1
fi
if out=$("$dir/rnrs_tb" "$seeds" 2>&1); then
  say "rename lookup + ooe_rs assembled == model" "PASS ($(echo "$out" | tail -1 | sed 's/.*seeds=//'))"
else
  say "rename lookup + ooe_rs assembled == model" "FAIL"; echo "$out" | tail -8; fail=1
fi
for c in stale-live wrong-names; do
  out=$(RNRS_CONTROL=$c "$dir/rnrs_tb" 3 2>&1)
  if echo "$out" | grep -q "surviving_named failed"; then
    say "  control $c (rnrs)" "caught"
  else
    say "  control $c (rnrs)" "MISSED (the assertion did not fire)"; fail=1
  fi
done

# ooe_rencred, the next value of rename's credit counters, driven from the
# model's events after every cycle under the go they serve (fits_stale 6),
# through the random tests and the directed ones (a restore-allocate draws
# names). The bench holds the counters.
dir=build/ooe-rtl/rencred
mkdir -p "$dir"
rob=$(sed -n 's/.*localparam int CCV_P_ROB_DEPTH = \([0-9]*\);.*/\1/p' rtl/generated/ccv_params_pkg.sv)
fcap=$(sed -n 's/.*unsigned ren_free_cap = \([0-9]*\);.*/\1/p' sim/ooe/ooe_core.h)
rc_ld=$(python3 -c "import math; print(math.ceil(math.log2($rob + 1)))")
rc_lg=$(python3 -c "import math; print(math.ceil(math.log2($phys + 1)))")
rc_lp=$(python3 -c "import math; print(math.ceil(math.log2($preds + 1)))")
if ! verilator --cc --exe --build -j 0 -O2 --assert -Wall -Wno-UNUSEDSIGNAL -Wno-DECLFILENAME \
      -GS="$slots" -GA="$width" -GNR="$n_rcu" -GNM="$n_miu" -GNG="$phys" -GNP="$preds" -GRD="$rob" -GF="$fcap" \
      --top-module ooe_rencred --Mdir "$dir" -o rencred_tb -I"$PWD/rtl/include" -I"$PWD/rtl/generated" \
      -CFLAGS "-std=c++17 -O2 -DRC_S=$slots -DRC_A=$width -DRC_F=$fcap -DRC_LD=$rc_ld -DRC_LG=$rc_lg -DRC_LP=$rc_lp -DOOE_TEST_AS_LIBRARY -I$PWD/sim/generated -I$PWD/sim/ooe" \
      "$PWD/rtl/ooe/ooe_rencred.sv" "$PWD/test/ooe/rencred_tb.cpp" \
      "$PWD/sim/ooe/ooe_core.cpp" "$PWD/sim/ooe/ooe_test.cpp" >"$dir/build.log" 2>&1; then
  say "rencred: builds" "FAIL (see $dir/build.log)"; tail -5 "$dir/build.log"; exit 1
fi
if out=$("$dir/rencred_tb" "$seeds" 2>&1); then
  say "rencred (rename's credits) == model, live" "PASS ($(echo "$out" | tail -1 | sed 's/.*cycles=//'))"
else
  say "rencred == model, live" "FAIL"; echo "$out" | tail -8; fail=1
fi
for c in no-late no-draw no-rob-free; do
  if RENCRED_CONTROL=$c "$dir/rencred_tb" 3 >/dev/null 2>&1; then
    say "  control $c (rencred)" "MISSED"; fail=1
  else
    say "  control $c (rencred)" "caught"
  fi
done

# ooe_rs, driven from the model's RS allocations and frees after every
# cycle. A control may be caught by the RTL's own assertion before the
# comparison: either fails the run.
dir=build/ooe-rtl/rs
mkdir -p "$dir"
nc=$(python3 -c "import json; print(next(c['rate'] for c in json.load(open('schema/interfaces.json'))['channels'] if c['name'] == 'ccv_miu_ooe_cmpl'))")
if ! verilator --cc --exe --build -j 0 -O2 --assert -Wall -Wno-UNUSEDSIGNAL -Wno-DECLFILENAME \
      --trace -GN="$n" -GNR="$n_rcu" -GA="$width" -GNC="$nc" --top-module ooe_rs --Mdir "$dir" -o rs_tb \
      -I"$PWD/rtl/include" -I"$PWD/rtl/generated" \
      -CFLAGS "-std=c++17 -O2 -DRS_N=$n -DRS_NR=$n_rcu -DRS_A=$width -DRS_NC=$nc -DOOE_TEST_AS_LIBRARY -I$PWD/sim/generated -I$PWD/sim/ooe" \
      "$PWD/rtl/ccv_assert_pkg.sv" "$PWD/rtl/ooe/ooe_rs.sv" "$PWD/test/ooe/rs_tb.cpp" \
      "$PWD/sim/ooe/ooe_core.cpp" "$PWD/sim/ooe/ooe_test.cpp" >"$dir/build.log" 2>&1; then
  say "rs: builds" "FAIL (see $dir/build.log)"; tail -5 "$dir/build.log"; exit 1
fi
if out=$("$dir/rs_tb" "$seeds" 2>&1); then
  say "rs ($n entries, $width ports a class) == model, live" "PASS ($(echo "$out" | tail -1 | sed 's/.*seeds=//'))"
else
  say "rs == model, live" "FAIL"; echo "$out" | tail -8; fail=1
fi
# no-msd runs the bench's seeds: a replay in ooe_rs only clears its issued
# bit, and a replayed producer is not final until it reissues, so a lost
# miss shows only where a non-producer would confirm early (3 seeds miss
# it; a caught control stops at its first difference).
for c in no-msd drop-squash-free drop-group drop-prv stale-live stale-hcol no-req-lead no-sq-lead no-cmpl-lead no-fin; do
  cs=3; [ "$c" = no-msd ] && cs=$seeds
  if RS_CONTROL=$c "$dir/rs_tb" $cs >/dev/null 2>&1; then
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
      --trace -DCCV_CHECK_RAT ${rat_g//,/ } --top-module ooe_rat_read --Mdir "$dir" -o rat_tb \
      -I"$PWD/rtl/include" -I"$PWD/rtl/generated" \
      -CFLAGS "-std=c++17 -O2 ${rat_d//,/ } -DOOE_TEST_AS_LIBRARY -I$PWD/sim/generated -I$PWD/sim/ooe" \
      "$PWD/rtl/ccv_assert_pkg.sv" "$PWD/rtl/ooe/ooe_rat.sv" "$PWD/rtl/ooe/ooe_ratread.sv" \
      "$PWD/test/ooe/ooe_rat_read.sv" "$PWD/test/ooe/rat_tb.cpp" \
      "$PWD/sim/ooe/ooe_core.cpp" "$PWD/sim/ooe/ooe_test.cpp" >"$dir/build.log" 2>&1; then
  say "rat: builds" "FAIL (see $dir/build.log)"; tail -5 "$dir/build.log"; exit 1
fi
if out=$("$dir/rat_tb" "$seeds" 2>&1); then
  say "rat (4 slots, 4 ports) == model, live" "PASS ($(echo "$out" | tail -1 | sed 's/.*seeds=//'))"
else
  say "rat == model, live" "FAIL"; echo "$out" | tail -8; fail=1
fi
for c in port-reverse drop-restore drop-retire drop-squash no-pending no-lead pend-over-event; do
  if RAT_CONTROL=$c "$dir/rat_tb" 3 >/dev/null 2>&1; then
    say "  control $c (rat)" "MISSED"; fail=1
  else
    say "  control $c (rat)" "caught"
  fi
done

# Rename 1 (OI-67): ooe_headrd per slot, ooe_ren1, the Rename 1 register and
# ooe_ren1n beside ooe_rat (test/ooe/ooe_ren1_tb.sv), driven from the
# model's renames after every cycle, each lane in the register compared.
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

# ooe_rename (slice 7's first step, 7c and 7b: the go, Rename 1 and 2, the
# free lists, rename's counters) beside ooe_rat (test/ooe/ooe_rename_tb.sv),
# driven from the model's go log, its renames' fields, its frees a model
# cycle behind and ooe_rs's grant and frees; its takes, lanes, names, reads,
# RS request and rows, and its counters as the go reads them, compared.
# Nothing tells it what was taken. Four builds: the design's parameters;
# the ceiling test's floor and ceiling (its directed core alone); and
# scarce names, 144 rows and a ceiling of 24, where the names' pool binds
# (its correction's controls, OA's revs 208 and 219); and the design's
# sectioned rows (NS 4, slice 6: the narrow allocator), its random cores
# held to the decided form (its directed cores, timed for whole rows, are
# the first build's).
for cfg in "rename - 25 drop-free,no-lead,no-write-bits,no-hold,drop-restore,no-reads,no-grant,no-cw-write" \
           "rename_ceil RENAME_FLOORS=4,8 0 -" \
           "rename_scarce RENAME_NAMES=144,24 25 no-take-q,no-take-q2" \
           "rename_sec RENAME_SECTIONS=1 25 drop-free,no-lead,no-reads,no-merge,no-cw-write"; do
  set -- $cfg
  name=$1 env=$2 nseeds=$3 ctls=$4
  [ "$nseeds" = 25 ] && nseeds=$seeds
  if [ "$env" = - ]; then
    read -r rename_g rename_d < <(python3 test/ooe/rename-params.py)
  else
    read -r rename_g rename_d < <(env "$env" python3 test/ooe/rename-params.py)
  fi
  dir=build/ooe-rtl/$name
  mkdir -p "$dir"
  if ! verilator --cc --exe --build -j 0 -O2 --assert -Wall -Wno-UNUSEDSIGNAL -Wno-DECLFILENAME \
        --trace -DCCV_CHECK_RENAME -DCCV_CHECK_RAT ${rename_g//,/ } --top-module ooe_rename_tb --Mdir "$dir" -o rename_tb \
        -I"$PWD/rtl/include" -I"$PWD/rtl/generated" \
        -CFLAGS "-std=c++17 -O2 ${rename_d//,/ } -DOOE_TEST_AS_LIBRARY -I$PWD/sim/generated -I$PWD/sim/ooe -I$PWD/test/ooe" \
        "$PWD/rtl/ccv_assert_pkg.sv" "$PWD/rtl/ooe/ooe_rat.sv" "$PWD/rtl/ooe/ooe_go.sv" "$PWD/rtl/common/ccv_common_csa.sv" "$PWD/rtl/ooe/ooe_freelist.sv" \
        "$PWD/rtl/ooe/ooe_headrd.sv" "$PWD/rtl/ooe/ooe_ren1.sv" "$PWD/rtl/ooe/ooe_ren1n.sv" "$PWD/rtl/ooe/ooe_rendep.sv" \
        "$PWD/rtl/ooe/ooe_prodmap.sv" "$PWD/rtl/ooe/ooe_rename.sv" "$PWD/test/ooe/ooe_rename_tb.sv" "$PWD/test/ooe/rename_tb.cpp" "$PWD/sim/ooe/ooe_core.cpp" \
        "$PWD/sim/ooe/ooe_test.cpp" >"$dir/build.log" 2>&1; then
    say "$name: builds" "FAIL (see $dir/build.log)"; tail -5 "$dir/build.log"; exit 1
  fi
  if out=$("$dir/rename_tb" "$nseeds" 2>&1); then
    say "$name (go, Rename 1 and 2, free lists) == model, live" "PASS ($(echo "$out" | grep '^rename_tb control' | sed 's/.*seeds=//'))"
  else
    say "$name == model, live" "FAIL"; echo "$out" | tail -8; fail=1
  fi
  [ "$ctls" = - ] && continue
  for c in ${ctls//,/ }; do
    if RENAME_CONTROL=$c "$dir/rename_tb" 3 >/dev/null 2>&1; then
      say "  control $c ($name)" "MISSED"; fail=1
    else
      say "  control $c ($name)" "caught"
    fi
  done
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
# The controls run the bench's seeds: a bulk discard beside a candidate
# memop (no-busy) is rare, and 3 seeds stopped reaching one when rename's
# go changed (OA-21); a caught control stops at its first difference.
for c in no-order no-conf no-busy; do
  if SELECT_CONTROL=$c "$dir/select_tb" "$seeds" >/dev/null 2>&1; then
    say "  control $c (select)" "MISSED"; fail=1
  else
    say "  control $c (select)" "caught"
  fi
done

# ooe_rs, ooe_wake and ooe_sched assembled (test/ooe/ooe_trio.sv; OA's
# response OI-45): every link between them as the design wires it, the model
# only at their outer ports, each module at its own lag. ooe_sched's ready,
# request and grant registers, ooe_rs's valid bits and rows and ooe_wake's
# issued bits and lead lines are held to the model under its composed
# timing (Config::req_rows_late, miss_lead, ready_rep_late). This replaces
# sched_tb's comparison, which drove ooe_sched from model-emulated
# neighbours; trio_tb is ooe_sched's clock-gating bench too (cg_trace.h), so
# it links Verilator's VCD writer.
dir=build/ooe-rtl/trio
mkdir -p "$dir"
cdly=$(echo "$wake_d" | tr ',' '\n' | sed -n 's/-DWAKE_CMPL_DLY=//p')
lmiss=$(echo "$wake_d" | tr ',' '\n' | sed -n 's/-DWAKE_LAT_MISS=//p')
if ! verilator --cc --exe --build -j 0 -O2 --assert --public-flat-rw --trace -Wall -Wno-UNUSEDSIGNAL -Wno-DECLFILENAME \
      -Wno-PINCONNECTEMPTY ${wake_g//,/ } -GNR="$n_rcu" -GA="$width" -GS="$slots" -GFB="$pick_fb" \
      --top-module ooe_trio --Mdir "$dir" -o trio_tb -I"$PWD/rtl/include" -I"$PWD/rtl/generated" \
      -CFLAGS "-std=c++17 -O2 -I$PWD/test/ooe -DTR_N=$n -DTR_NR=$n_rcu -DTR_A=$width -DTR_S=$slots -DTR_NC=$nc -DTR_CMPL_DLY=$cdly -DTR_LAT_MISS=$lmiss -DOOE_TEST_AS_LIBRARY -I$PWD/sim/generated -I$PWD/sim/ooe" \
      "$PWD/rtl/ccv_assert_pkg.sv" "$PWD/rtl/ooe/ooe_confirm.sv" "$PWD/rtl/ooe/ooe_rs.sv" "$PWD/rtl/ooe/ooe_wake.sv" \
      "$PWD/rtl/ooe/ooe_ready.sv" "$PWD/rtl/ooe/ooe_pick.sv" "$PWD/rtl/ooe/ooe_select.sv" "$PWD/rtl/ooe/ooe_sched.sv" \
      "$PWD/test/ooe/ooe_trio.sv" "$PWD/test/ooe/trio_tb.cpp" "$PWD/sim/ooe/ooe_core.cpp" "$PWD/sim/ooe/ooe_test.cpp" \
      >"$dir/build.log" 2>&1; then
  say "trio: builds" "FAIL (see $dir/build.log)"; tail -5 "$dir/build.log"; exit 1
fi
if out=$("$dir/trio_tb" "$seeds" 2>&1); then
  say "rs + wake + sched assembled == model" "PASS ($(echo "$out" | tail -1 | sed 's/.*seeds=//'))"
else
  say "rs + wake + sched assembled == model" "FAIL"; echo "$out" | tail -8; fail=1
fi
for c in no-msd no-miss-lead late-leads no-alloc-lead; do
  if TRIO_CONTROL=$c "$dir/trio_tb" 6 >/dev/null 2>&1; then
    say "  control $c (trio)" "MISSED"; fail=1
  else
    say "  control $c (trio)" "caught"
  fi
done
exit $fail
