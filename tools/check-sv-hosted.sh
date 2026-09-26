#!/usr/bin/env bash
# The C++ skeleton's blocks, hosted by the SV top.
#
# ccv_core_top built from rtl/top/dpi/ -- a DPI shim per block type, same
# module names and port lists as the stubs -- so every block is the C++
# skeleton's functional stub and every connection between two blocks is a net
# in the generated Verilog. The same kernels, run by the C++ skeleton's own
# loop (build/skel/ccv-skel), must come out the same:
#
#   clean                                        negative control
#   every S1 kernel: KERNEL, UNUSED and XFER     +ccv_shim_delay=u_dec: DEC's
#     lines identical, event trace the same        outputs one cycle late --
#     records cycle by cycle                       every port still obeys the
#   every S1 kernel control (--break): the         protocol, and the run must
#     same KERNEL line from both hosts             not compare equal
#   the build refuses to elaborate without       +ccv_shim_delay=u_lane_05:
#     CCV_TRACE                                    one lane of 32
#
# What it proves: the swap boundary is the SV port list. A C++ block reads
# only what the Verilog carried to its ports, so a shim, a stub and a real RTL
# block are interchangeable one file at a time -- and a C++ block that
# depended on sharing state with another behind the ports would diverge here.
# The skew control is the partner that makes "the same" mean something: a
# comparison too coarse to see a block running one cycle late would pass it.
#
# Verilator only: Icarus has no DPI-C.
set -uo pipefail
cd "$(dirname "$0")/.."
R=$(pwd)
B="$R/build"
fail=0
say() { printf '  %-46s %s\n' "$1" "$2"; }
bad() { say "$1" "FAIL -- $2"; fail=1; }

if ! command -v verilator >/dev/null 2>&1; then
  say "SV-hosted C++" "SKIP -- verilator not installed"
  exit 0
fi
SKEL="$B/skel/ccv-skel"
if [ ! -x "$SKEL" ] || [ ! -f "$B/oracle/vadd/oracle.jsonl" ]; then
  bad "SV-hosted C++" "no $SKEL or oracles -- tools/check-skel.sh and check-kernel.sh first"
  exit 1
fi

CHK="rtl/if/ccv_credit_checker.sv rtl/if/ccv_atomic_checker.sv rtl/if/ccv_lockstep_checker.sv rtl/if/ccv_binding_checker.sv rtl/if/ccv_outstanding_checker.sv rtl/if/ccv_wake_checker.sv rtl/generated/ccv_skel_checkers.sv"
SV="rtl/ccv_assert_pkg.sv $CHK rtl/top/dpi/*.sv rtl/phys/ccv_seq_rpt.sv rtl/top/wrap/*.sv rtl/top/ccv_core_top.sv test/top/tb_sv_hosted.sv"
INC="-Irtl/include -Irtl/generated -Irtl/top/ports"

# -- lint and build ----------------------------------------------------------
if verilator --lint-only --assert --timing -Wall -Wno-DECLFILENAME -Wno-TIMESCALEMOD \
     -DCCV_CHECK -DCCV_TRACE $INC --top-module tb $SV >"$B/svh_lint.log" 2>&1; then
  say "verilator -Wall: shims, top, testbench" "PASS"
else
  bad "verilator -Wall: shims, top, testbench" "$(grep -m1 -E '%(Warning|Error)' "$B/svh_lint.log")"
fi
if verilator --lint-only --timing -Wno-fatal -DCCV_CHECK $INC --top-module tb $SV \
     >"$B/svh_notrace.log" 2>&1; then
  bad "shims refuse a build without CCV_TRACE" "it elaborated"
else
  grep -q "ccv_sv_hosted_needs_CCV_TRACE" "$B/svh_notrace.log" &&
    say "  ...and refuse a build without CCV_TRACE" "PASS" ||
    bad "shims refuse a build without CCV_TRACE" "$(grep -m1 %Error "$B/svh_notrace.log")"
fi
if ! verilator --binary -j 0 --assert --timing -Wno-fatal -Wno-TIMESCALEMOD \
     -DCCV_CHECK -DCCV_TRACE $INC --top-module tb --Mdir "$B/svh_vo" -o ccv-svh \
     -CFLAGS "-std=c++17 -O1 -I$R/sim/include -I$R/sim/generated -I$R/sim/skel" \
     $SV "$R/sim/skel/dpi_host.cpp" "$R/sim/skel/kernel.cpp" \
     "$R/sim/skel/oracle.cpp" "$R/sim/skel/machine.cpp" \
     "$R/sim/skel/exerciser.cpp" "$R/sim/src/event.cpp" \
     "$R/sim/dpi/ccv_event_dpi.cpp" >"$B/svh_build.log" 2>&1; then
  bad "SV-hosted build" "$(grep -m1 -iE '%Error|error:' "$B/svh_build.log")"
  exit 1
fi
SVH="$B/svh_vo/ccv-svh"
say "SV-hosted build: 45 blocks + EXTERNAL as shims" "PASS"

# One run on each host. $1 kernel, $2 tag, then extra args as "cpp|sv" pairs.
cpp() { "$SKEL" --kernel "$B/oracle/$1/oracle.jsonl" "${@:2}" 2>/dev/null; }
svh() { "$SVH" "+ccv_oracle=$B/oracle/$1/oracle.jsonl" "${@:2}" 2>/dev/null; }
lines() { grep -E '^(KERNEL|UNUSED|XFER) ' "$1"; }

# -- every S1 kernel, both hosts --------------------------------------------
for k in $(ls -d test/kernels/*/ | xargs -n1 basename); do
  cpp "$k" --trace "$B/svh_cpp_$k.ccvtrace" >"$B/svh_cpp_$k.log"
  svh "$k" "+ccv_trace=$B/svh_sv_$k.ccvtrace" >"$B/svh_sv_$k.log"
  why=""
  grep -q "^SVHOST shims=46/46 skewed=none" "$B/svh_sv_$k.log" ||
    why="not every block hosted: $(grep ^SVHOST "$B/svh_sv_$k.log")"
  grep -q " violations=0$" "$B/svh_sv_$k.log" || why="$why; checker violations"
  grep -q "match=yes" "$B/svh_sv_$k.log" || why="$why; bank XFER != launches"
  [ "$(lines "$B/svh_cpp_$k.log")" = "$(lines "$B/svh_sv_$k.log")" ] ||
    why="$why; summary lines differ"
  tr=$(python3 tools/compare-traces.py "$B/svh_cpp_$k.ccvtrace" "$B/svh_sv_$k.ccvtrace")
  echo "$tr" | head -1 | grep -q "equal=yes" || why="$why; $(echo "$tr" | sed -n 2p | xargs)"
  n=$(echo "$tr" | head -1 | grep -oE 'records=[0-9]+' | cut -d= -f2)
  if [ -z "$why" ]; then
    say "$k: SV-hosted == C++-hosted" "PASS ($n events, $(grep -oE 'cycles=[0-9]+' "$B/svh_sv_$k.log"))"
  else
    bad "$k: SV-hosted == C++-hosted" "${why#; }"
  fi
done

# -- every kernel control, both hosts ----------------------------------------
# The failure paths too: each control's KERNEL line -- which checks fired,
# how many, what the final state compare found, the bank's violation count --
# must be the one the C++ host prints.
diffs=""
nctl=0
for spec in vadd:corrupt-fetch vadd:corrupt-load vadd:drop-store \
            vadd:corrupt-req-id:3000 vadd:corrupt-disp vadd:itlb-double:3000 \
            vadd:drop-negate vadd:corrupt-echo vadd:movi-in-lane \
            vadd:srd-selector sel:drop-pred-data srd:corrupt-ctaid \
            vadd:late-lead pguard:ignore-mask pguard:conflate-pred; do
  IFS=: read -r k brk cap <<<"$spec"
  a=$(cpp "$k" --break "$brk" ${cap:+--cycles "$cap"} | grep ^KERNEL)
  s=$(svh "$k" "+ccv_break=$brk" ${cap:++ccv_cycles=$cap} | grep ^KERNEL)
  nctl=$((nctl + 1))
  [ -n "$a" ] && [ "$a" = "$s" ] || diffs="$diffs $k:$brk"
done
if [ -z "$diffs" ]; then
  say "every kernel control: the same KERNEL line" "PASS ($nctl controls)"
else
  bad "every kernel control: the same KERNEL line" "differ:$diffs"
fi

# -- the partner: one block one cycle late must not compare equal ------------
for inst in u_dec u_lane_05; do
  svh vadd "+ccv_trace=$B/svh_skew.ccvtrace" "+ccv_shim_delay=$inst" >"$B/svh_skew.log"
  if ! grep -q "^SVHOST .* skewed=$inst$" "$B/svh_skew.log"; then
    bad "skew control: $inst one cycle late" "the delay did not reach $inst"
  elif [ "$(lines "$B/svh_cpp_vadd.log")" != "$(lines "$B/svh_skew.log")" ] &&
       ! python3 tools/compare-traces.py "$B/svh_cpp_vadd.ccvtrace" "$B/svh_skew.ccvtrace" >/dev/null; then
    say "  ...$inst one cycle late: caught" \
        "PASS ($(python3 tools/compare-traces.py "$B/svh_cpp_vadd.ccvtrace" "$B/svh_skew.ccvtrace" | grep -oE 'differing_cycles=[0-9]+'))"
  else
    bad "skew control: $inst one cycle late" "the comparison did not see it"
  fi
done

exit $fail
