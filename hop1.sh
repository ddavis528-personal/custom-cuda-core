#!/usr/bin/env bash
cd /home/user/wt-hop
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
say(){ printf "%-60s %s\n" "$1" "$2"; }; fail=0

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
seeds=3
for cfg in "rename - 25 no-prv"; do
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
    co=$(RENAME_CONTROL=$c "$dir/rename_tb" 3 2>&1); rc=$?; echo "$co" | grep -m2 "Assertion failed\|mismatch\|FAIL" | cut -c1-200
    if [ $rc = 0 ]; then
      say "  control $c ($name)" "MISSED"; fail=1
    else
      say "  control $c ($name)" "caught"
    fi
  done
done
echo "fail=$fail"
