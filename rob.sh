set -u; cd /home/user/wt-pwv; seeds=25; fail=0; say(){ printf "%-50s %s\n" "$1" "$2"; }
width=$(sed -n 's/.*localparam int CCV_ISSUE_WIDTH = \([0-9]*\);.*/\1/p' rtl/generated/ccv_params_pkg.sv)
slots=$(sed -n 's/.*localparam int CCV_TIER1_WARPS = \([0-9]*\);.*/\1/p' rtl/generated/ccv_params_pkg.sv)
# ooe_rob, the ROB (slices 1, 2 and 3, OI-85), driven from the model's ROB log
# (Core::robLog) a model cycle behind, with retire_lag 1: its retirements,
# resolutions and squashes, their leads and frees, the discard, the store
# commits (slice 3, one a slot a cycle) and the room rename's go reads
# compared exactly. A core stops at the first thing the
# ROB does not build yet (a squash not a branch's, a fault, a retire port,
# an atomic).
dir=build/ooe-rtl/rob
mkdir -p "$dir"
rv() { sed -n "s/.*localparam int $1 = \([0-9]*\);.*/\1/p" rtl/generated/ccv_params_pkg.sv; }
rob_p="S=$slots D=$(rv CCV_P_ROB_DEPTH) RP=$(rv CCV_RETIRE_PER_ROB) A=$width ND=7 NM=4 NK=$(rv CCV_P_BR_CKPTS) PCW=$(rv CCV_ADDR_BITS)"
rob_p="$rob_p GW=$(( $(rv CCV_P_W_PHYS_REG) + $(rv CCV_W_PHYS_POS) )) GR=$(rv CCV_P_W_PHYS_REG) NG=$(rv CCV_P_PHYS_REGS)"
rob_p="$rob_p NS=$(( 1 << $(rv CCV_W_PHYS_POS) )) PW=$(rv CCV_P_W_PHYS_PRED) NP=$(rv CCV_P_PRED_REGS) CW=$(rv CCV_W_FAULT_CAUSE)"
if ! verilator --cc --exe --build -j 0 -O2 --assert -Wall -Wno-UNUSEDSIGNAL -Wno-DECLFILENAME \
      --trace $(for kv in $rob_p; do printf -- '-G%s ' "$kv"; done) -DCCV_CHECK_REDIR --top-module ooe_rob_tb \
      --Mdir "$dir" -o rob_tb -I"$PWD/rtl/include" -I"$PWD/rtl/generated" \
      -CFLAGS "-std=c++17 -O2 -I$PWD/test/ooe $(for kv in $rob_p; do printf -- '-DRB_%s ' "$kv"; done) -DOOE_TEST_AS_LIBRARY -DCCV_CHECK_REDIR -I$PWD/sim/generated -I$PWD/sim/ooe" \
      "$PWD/rtl/ccv_assert_pkg.sv" "$PWD/rtl/ooe/ooe_rob_w.sv" "$PWD/rtl/ooe/ooe_redir.sv" "$PWD/test/ooe/ooe_rob_tb.sv" "$PWD/test/ooe/rob_tb.cpp" \
      "$PWD/sim/ooe/ooe_core.cpp" "$PWD/sim/ooe/ooe_test.cpp" >"$dir/build.log" 2>&1; then
  say "rob: builds" "FAIL (see $dir/build.log)"; tail -5 "$dir/build.log"; exit 1
fi
if out=$("$dir/rob_tb" "$seeds" 2>&1) && grep -q "mismatches=0 model_failures=0" <<<"$out"; then
  say "rob ($slots slots) == model, live" "PASS ($(grep '^rob_tb' <<<"$out" | sed 's/.*seeds=//'))"
else
  say "rob == model, live" "FAIL"; echo "$out" | tail -8; fail=1
fi
# The random programs as drawn (slice 2): mispredicts, their squashes, held
# entries and killed fills.
if out=$(ROB_MISPREDICT=1 "$dir/rob_tb" "$seeds" 2>&1) && grep -q "mismatches=0 model_failures=0" <<<"$out"; then
  say "rob == model, mispredicting" "PASS ($(grep '^rob_tb' <<<"$out" | sed 's/.*seeds=//'))"
else
  say "rob == model, mispredicting" "FAIL"; echo "$out" | tail -8; fail=1
fi
# The controls run every seed the bench does: a control caught only by a
# trace the first few seeds happen to draw stops being caught when the
# traces move (no-copy, at CCV_P_DECQ 15: first caught at seed 6).
for c in drop-free no-copy no-lead fill-order nop-real two-in-a-cycle wrong-row flip-taken right-always branch-off-slot \
         no-branch-lead no-miu no-store drop-killed-fill late-fill shared-ports store-shift no-fault fault-cause fault-any-port fault-port0 no-fault-lead fault-addr no-alloc-lag no-free-lag \
         redir-warp redir-epoch redir-ntm rd-unled ckf-unled; do
  if ROB_CONTROL=$c "$dir/rob_tb" "$seeds" >/dev/null 2>&1; then
    say "  control $c (rob)" "MISSED"; fail=1
  else
    say "  control $c (rob)" "caught"
  fi
done
# two-resolutions: two candidates in a cycle, forced; one_resolution itself
# must catch it (no other check sees it first).
if out=$(ROB_CONTROL=two-resolutions "$dir/rob_tb" 3 2>&1) || ! grep -q "one_resolution" <<<"$out"; then
  say "  control two-resolutions (rob)" "MISSED"; fail=1
else
  say "  control two-resolutions (rob)" "caught"
fi
# pw-at-res (OA 492): every pick read as a waiting one, so a pick in its
# slot's resolution cycle reads ooe_rob_w's hold word as it is written;
# hd_read_not_written itself must catch it.
if out=$(ROB_MISPREDICT=1 ROB_CONTROL=pw-at-res "$dir/rob_tb" "$seeds" 2>&1) || ! grep -q "hd_read_not_written" <<<"$out"; then
  say "  control pw-at-res (rob)" "MISSED"; fail=1
else
  say "  control pw-at-res (rob)" "caught"
fi
# OI-184's lag-1 redirect (DA 130; the two-cycle form retired, OA 492): the
# payload leaves with the valid, two cycles after the model's send. pwv-late
# checks it as the two-cycle form.
if ROB_MISPREDICT=1 ROB_CONTROL=pwv-late "$dir/rob_tb" "$seeds" >/dev/null 2>&1; then
  say "  control pwv-late (rob)" "MISSED"; fail=1
else
  say "  control pwv-late (rob)" "caught"
fi
echo "fail=$fail"
