set -u; cd /home/user/wt-sw; seeds=25; fail=0; say(){ printf "%-50s %s\n" "$1" "$2"; }
width=$(sed -n 's/.*localparam int CCV_ISSUE_WIDTH = \([0-9]*\);.*/\1/p' rtl/generated/ccv_params_pkg.sv)
slots=$(sed -n 's/.*localparam int CCV_TIER1_WARPS = \([0-9]*\);.*/\1/p' rtl/generated/ccv_params_pkg.sv)
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
# Scarce names (144 rows, a ceiling of 24), where the names' pool binds and
# the floor term less the go's own take (OI-114) decides takes, a cycle late
# (OA's rev 369 (b)): the go reads the unmet on time, which holds the names
# its last take wrote. Its control takes the go's own take in the split
# cycle as well (the model's floor_take_lag 0); floor-held-off splits the
# floor term again under an allowance that holds one (TI 360).
if out=$(GO_NAMES=144,24 "$dir/go_tb" 5 2>&1); then
  say "go == model, live, scarce names" "PASS ($(echo "$out" | tail -1 | sed 's/.*seeds=//'))"
else
  say "go == model, live, scarce names" "FAIL"; echo "$out" | tail -8; fail=1
fi
for c in floor-take-now floor-held-off; do
  if GO_NAMES=144,24 GO_CONTROL=$c "$dir/go_tb" 3 >/dev/null 2>&1; then
    say "  control $c (go, scarce)" "MISSED"; fail=1
  else
    say "  control $c (go, scarce)" "caught"
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
for cfg in "rename - 25 drop-free,no-lead,no-write-bits,no-hold,drop-restore,no-reads,no-grant,no-cw-write,no-spec" \
           "rename_ceil RENAME_FLOORS=4,8 0 -" \
           "rename_scarce RENAME_NAMES=144,24 25 no-take-q,no-take-q2,unmet-now,no-last-take" \
           "rename_sec RENAME_SECTIONS=1 25 drop-free,no-lead,no-reads,no-merge,no-cw-write,pend-follows"; do
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
echo "fail=$fail"
