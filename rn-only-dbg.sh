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
# - ooe_cmcap (C9's capture of ccv_miu_ooe_cmpl for the ROB) against the model's completions, live
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
for cfg in "rename - 25 drop-free,no-lead,no-write-bits,no-hold,drop-restore,no-reads,no-grant,no-cw-write,no-spec" \
           "rename_ceil RENAME_FLOORS=4,8 0 -" \
           "rename_scarce RENAME_NAMES=144,24 25 no-take-q,no-take-q2,unmet-now,no-last-take" \
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
  if ! verilator --cc --exe --build -j 0 -O2 --assert -Wall -Wno-fatal -Wno-UNUSEDSIGNAL -Wno-DECLFILENAME \
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
exit $fail
