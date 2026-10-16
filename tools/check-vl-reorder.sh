#!/usr/bin/env bash
# The pinned Verilator compiles OI's 5.020 miscompile correctly (OI-40, TI).
#
# Verilator 5.020 miscompiled ooe_decq's flop when it was written as an
# if/else of two function calls: statement reordering dropped two arrivals'
# payloads (OI, 2026-10-10; -fno-reorder, Icarus and 5.052 all agreed on the
# right result). OI's RTL now folds reset into one function, which 5.020
# compiles right, so nothing in rtl/ would show a regression in a later
# Verilator. This does: test/vl/vl_decq.sv is that queue frozen with its flop
# in both forms, and test/vl/vl_reorder_tb.cpp drives the two from the same
# random, legal stimulus and compares every output before every edge.
#
#   tools/check-vl-reorder.sh                 the pinned Verilator, and the control
#   VERILATOR=/opt/verilator-5.020/bin/verilator tools/check-vl-reorder.sh --expect-fail
#                                             another Verilator, expected to miscompile
#
# The control plants one wrong payload into the if/else copy, which must be
# caught. Measured 2026-10-16: 5.052 agrees over 200,000 cycles; 5.020
# differs on cycle 1 (an arrival lost) and trips the queue's own
# head_reads_busy assertion.
set -uo pipefail
cd "$(dirname "$0")/.."
V=${VERILATOR:-verilator}
expect_fail=0
[ "${1:-}" = --expect-fail ] && expect_fail=1
ver=$("$V" --version | awk '{print $2}')
dir=build/vl-reorder/$ver
rm -rf "$dir"
mkdir -p "$dir"
say() { printf '  %-52s %s\n' "$1" "$2"; }
if ! "$V" --cc --exe --build -j 0 -O2 --assert -Wno-fatal -Wno-lint -Wno-style \
      -I"$PWD/rtl/include" -I"$PWD/rtl/generated" --top-module vl_reorder_top --Mdir "$dir" -o vl_reorder \
      "$PWD/rtl/ccv_assert_pkg.sv" "$PWD/test/vl/vl_decq.sv" "$PWD/test/vl/vl_reorder_top.sv" \
      "$PWD/test/vl/vl_reorder_tb.cpp" >"$dir/build.log" 2>&1; then
  say "Verilator $ver: the guard builds" "FAIL (see $dir/build.log)"; tail -5 "$dir/build.log"; exit 1
fi
out=$("$dir/vl_reorder" 200000 2>&1); rc=$?
if [ $expect_fail = 1 ]; then
  if [ $rc -ne 0 ]; then
    say "Verilator $ver miscompiles the if/else form" "as expected ($(echo "$out" | head -1))"; exit 0
  fi
  say "Verilator $ver miscompiles the if/else form" "NOT SEEN: the guard did not catch it"; exit 1
fi
if [ $rc -ne 0 ]; then
  say "Verilator $ver: step() and if/else flops agree" "FAIL"; echo "$out" | tail -5; exit 1
fi
say "Verilator $ver: step() and if/else flops agree" "PASS ($(echo "$out" | tail -1 | sed 's/.*cycles=//'))"
if VL_CONTROL=plant "$dir/vl_reorder" 20000 >/dev/null 2>&1; then
  say "  control: one planted payload" "MISSED"; exit 1
fi
say "  control: one planted payload" "caught"
