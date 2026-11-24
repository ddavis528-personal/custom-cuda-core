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
cd /tmp/claude-0/-home-user/f45e5bc5-a4af-595e-a4dd-e1d6ad6f715c/scratchpad/wtrs2
vectors="${1:-200000}"
seeds="${2:-25}"
n_rcu=$(sed -n 's/.*localparam int CCV_P_RS_RCU = \([0-9]*\);.*/\1/p' rtl/generated/ccv_params_pkg.sv)
n_miu=$(sed -n 's/.*localparam int CCV_P_RS_MIU = \([0-9]*\);.*/\1/p' rtl/generated/ccv_params_pkg.sv)
secs=$(sed -n 's/.*localparam int CCV_SECTIONS = \([0-9]*\);.*/\1/p' rtl/generated/ccv_params_pkg.sv)
pipes=$(sed -n 's/.*localparam int CCV_MIU_PIPES = \([0-9]*\);.*/\1/p' rtl/generated/ccv_params_pkg.sv)
fail=0
say() { printf '  %-52s %s\n' "$1" "$2"; }
n=$((n_rcu + n_miu))
width=$(sed -n 's/.*localparam int CCV_ISSUE_WIDTH = \([0-9]*\);.*/\1/p' rtl/generated/ccv_params_pkg.sv)
ng=$(( $(sed -n 's/.*localparam int CCV_P_PHYS_REGS = \([0-9]*\);.*/\1/p' rtl/generated/ccv_params_pkg.sv) * 4 ))
np=$(sed -n 's/.*localparam int CCV_P_PRED_REGS = \([0-9]*\);.*/\1/p' rtl/generated/ccv_params_pkg.sv)
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
exit $fail
