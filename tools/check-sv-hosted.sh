#!/usr/bin/env bash
# The C++ skeleton's blocks, hosted by the SV top.
#
# ccv_top built from rtl/top/dpi/ -- a DPI shim per block type, same
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
BLOCKS=$(grep -v '^#' sim/skel/blocks.list | sed "s|^|$R/|" | tr '\n' ' ')
if [ ! -x "$SKEL" ] || [ ! -f "$B/oracle/vadd/oracle.jsonl" ]; then
  bad "SV-hosted C++" "no $SKEL or oracles -- tools/check-skel.sh and check-kernel.sh first"
  exit 1
fi

CHK="rtl/if/ccv_common_chk_credit.sv rtl/if/ccv_common_chk_atomic.sv rtl/if/ccv_common_chk_lockstep.sv rtl/if/ccv_common_chk_binding.sv rtl/if/ccv_common_chk_outstanding.sv rtl/if/ccv_common_chk_notice.sv rtl/if/ccv_common_chk_wake.sv rtl/generated/ccv_common_chk_bank.sv"
GATE="rtl/clk/ccv_common_clk.sv $(python3 tools/ccv_ctech.py | tr '\n' ' ')"
SV="rtl/ccv_assert_pkg.sv $CHK $GATE rtl/top/dpi/*.sv rtl/phys/ccv_common_rpt.sv rtl/top/wrap/*.sv rtl/top/ccv_top.sv test/top/tb_ext.sv test/top/tb_sv_hosted.sv"
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
     $SV "$R/sim/skel/dpi_host.cpp" $BLOCKS \
     "$R/sim/skel/oracle.cpp" "$R/sim/skel/machine.cpp" "$R/sim/skel/portdump.cpp" \
     "$R/sim/skel/exerciser.cpp" "$R/sim/src/event.cpp" \
     "$R/sim/dpi/ccv_event_dpi.cpp" >"$B/svh_build.log" 2>&1; then
  bad "SV-hosted build" "$(grep -m1 -iE '%Error|error:' "$B/svh_build.log")"
  exit 1
fi
SVH="$B/svh_vo/ccv-svh"
say "SV-hosted build: 45 blocks + EXTERNAL as shims" "PASS"
# --build-only: the binary alone, for tools/regen.sh (the walkthrough runs it).
[ "${1:-}" = "--build-only" ] && exit $fail

# One run on each host. $1 kernel, $2 tag, then extra args as "cpp|sv" pairs.
cpp() { "$SKEL" --kernel "$B/oracle/$1/oracle.jsonl" "${@:2}" 2>/dev/null; }
svh() { "$SVH" "+ccv_oracle=$B/oracle/$1/oracle.jsonl" "${@:2}" 2>/dev/null; }
lines() { grep -E '^(KERNEL|UNUSED|XFER|COVER) ' "$1"; }
field() { tr ' ' '\n' <"$1" | sed -n "s/^$2=//p" | head -1; }

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

# -- the swap (TI-24), both hosts: RAU, OOE, RCU, FET and PCA each move a
# warp out and back through their own ports only, so the SV top must agree
# event for event. stall and swap are built to park and restore their warp
# 0, so they must; vadd4 parks only where its stalls reach the threshold,
# and the hosts must agree on it either way (their summary lines). provswap
# restores provisionally and demotes the provisional warp again
# (CCV_RAU_READY=0, RAU spec rev 25), at OOE's thresholds as check-kernel
# runs it.
for k in stall vadd4 swap provswap; do
  t="${k}_demote"
  cfg=""
  rdy=1
  [ "$k" = provswap ] && cfg=demote_mlc_miss=150,demote_fallback=150 rdy=0
  CCV_RAU_READY=$rdy CCV_OOE_CONFIG=$cfg CCV_RAU_DEMOTE=mlc cpp "$k" --trace "$B/svh_cpp_$t.ccvtrace" >"$B/svh_cpp_$t.log"
  CCV_RAU_READY=$rdy CCV_OOE_CONFIG=$cfg CCV_RAU_DEMOTE=mlc svh "$k" "+ccv_trace=$B/svh_sv_$t.ccvtrace" >"$B/svh_sv_$t.log"
  why=""
  grep -q " violations=0$" "$B/svh_sv_$t.log" || why="$why; checker violations"
  [ "$k" = vadd4 ] || grep -qE '(^| )restored=[1-9]' "$B/svh_sv_$t.log" || why="$why; nothing restored"
  [ "$(lines "$B/svh_cpp_$t.log")" = "$(lines "$B/svh_sv_$t.log")" ] ||
    why="$why; summary lines differ"
  tr=$(python3 tools/compare-traces.py "$B/svh_cpp_$t.ccvtrace" "$B/svh_sv_$t.ccvtrace")
  echo "$tr" | head -1 | grep -q "equal=yes" || why="$why; $(echo "$tr" | sed -n 2p | xargs)"
  n=$(echo "$tr" | head -1 | grep -oE 'records=[0-9]+' | cut -d= -f2)
  if [ -z "$why" ]; then
    say "$k swapping: SV-hosted == C++-hosted" "PASS ($n events, $(grep -oE 'restored=[0-9]+' "$B/svh_sv_$t.log" | head -1))"
  else
    bad "$k swapping: SV-hosted == C++-hosted" "${why#; }"
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
            vadd:late-lead pguard:ignore-mask pguard:conflate-pred \
            vadd:corrupt-ckpt vadd:stale-free vadd:attr-store-as-load:3000 \
            merge:dirty-zero merge:wrong-merge mload:skip-copy \
            mload:late-copy mload:copy-from-new unal:one-line unal:skip-read-partial loop:free-new \
            vadd:corrupt-group-mask loop:stale-epoch pguard:swap-prat0 \
            hit:early-hit hit:late-hit-data hit:no-rcu-bypass \
            vadd:drop-src-valid plog:arch-pred-srcs vadd:no-resource-cap \
            vadd:bad-pos vadd:narrow-pipes vadd:ordering-on-load vadd:memop-ordering \
            callret:slot-field-aux callret:lead-corrupt vadd:sfu-valid-stray vadd:nop-real-op \
            vadd:cor-late vadd:cor-drop; do
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

# -- credit on receipt: a late or dropped take fails in the SV top itself ------
# AR's rev 322 (b) 3, RA-41: at a credit-on-receipt end (params/links.json;
# miu_rcu_data@rcu alone since RA-43)
# the wrapper's repeater returns the credit from its boundary valid flop, so
# a block that takes a landed message a cycle late, or drops it, must fail
# in the SV-hosted run by name -- not only as a divergence from the oracle.
# A configuration with no such end (test/phys/links_split.json) has nothing
# for the control to hold late: said so, never passed.
ncor=$(python3 -c 'import json, os
print(len(json.load(open(os.environ.get("CCV_LINKS", "params/links.json"))).get("credit_on_receipt", [])))')
[ "$ncor" -gt 0 ] || say "SV top: credit on receipt, late or dropped" "SKIP -- no credit_on_receipt end in this configuration"
for brk in $([ "$ncor" -gt 0 ] && echo cor-late cor-drop); do
  out=$("$SVH" "+ccv_oracle=$B/oracle/vadd/oracle.jsonl" "+ccv_break=$brk" 2>&1)
  n=$(grep ^KERNEL <<<"$out" | grep -oE ' cor_late=[0-9]+' | cut -d= -f2)
  if grep -q '^CHECK ccv_miu_rcu_data: credit on receipt, slot' <<<"$out" &&
     [ "${n:-0}" -gt 0 ] && ! grep -q ' check_failures=0 ' <<<"$(grep ^KERNEL <<<"$out")"; then
    say "SV top: --break $brk fails on credit on receipt" "PASS (cor_late=$n)"
  else
    bad "SV top: --break $brk fails on credit on receipt" "not caught: $(grep ^KERNEL <<<"$out" | grep -oE 'check_failures=[0-9]+ .*cor_late=[0-9]+')"
  fi
done

# -- OOE's bypass on, both hosts ---------------------------------------------
# The lane-local bypass (A-59, TI-8): with OOE waking lane dependants at
# CCV_LAT_LANE_BYP, the lanes forward through operand_byp. Every kernel, and
# the control that drops the forwarding, must print the same KERNEL and
# COVER lines on both hosts.
diffs=""
nbyp=0
for spec in $(ls -d test/kernels/*/ | xargs -n1 basename) byp:no-lane-bypass; do
  IFS=: read -r k brk <<<"$spec"
  a=$(CCV_OOE_CONFIG=bypass=1 cpp "$k" ${brk:+--break "$brk"} | grep -E '^(KERNEL|COVER) ')
  s=$(CCV_OOE_CONFIG=bypass=1 svh "$k" ${brk:++ccv_break=$brk} | grep -E '^(KERNEL|COVER) ')
  nbyp=$((nbyp + 1))
  [ -n "$a" ] && [ "$a" = "$s" ] || diffs="$diffs $spec"
done
if [ -z "$diffs" ]; then
  say "with OOE's bypass: the same KERNEL line" "PASS ($nbyp runs, no-lane-bypass among them)"
else
  bad "with OOE's bypass: the same KERNEL line" "differ:$diffs"
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

# -- RCU's RTL in the top (CCV_RCU_RTL; RI-42/44, TI rev 422) -----------------
# The top built with rtl/rcu/ in place of RCU's shim: test/rcu/ccv_rcu_svh.sv
# takes the name ccv_rcu, drives the top from the RTL and runs the model
# beside it as a shadow (rtl/top/dpi-shadow/ccv_rcu_dpi.sv, gen-top), whose
# outputs only the compare reads, but for the trace ids the RTL does not
# carry. Every kernel: the KERNEL line the C++ host prints (its end-of-run
# compare reads the RTL's register files, Kernel::gprAt), no checker
# violation, and RTL == shadow port for port, cycle for cycle, under the block
# lock-step's care masks, events too (test/rcu/svh.py compare: "rcu=rtl
# divergences=0"). The clock gate is overridden on in the wrapper (the shims'
# wake outputs are 0 here); the block lock-step holds it to the model.
RG="$B/svh_rtl_gen"; RV="$B/svh_rtl"
if ! RSRC=$(python3 test/rcu/svh.py prep --out "$RG" 2>"$B/svh_rtl_prep.log"); then
  bad "RCU's RTL in the SV top: builds" "svh.py prep: $(head -1 "$B/svh_rtl_prep.log")"
  exit 1
fi
SVR=$(echo "$SV" | sed 's| rtl/top/dpi/\*\.sv | |')
SVR="$SVR $(ls rtl/top/dpi/*.sv | grep -v '/ccv_rcu\.sv$' | tr '\n' ' ') rtl/top/dpi-shadow/ccv_rcu_dpi.sv $(echo "$RSRC" | tr '\n' ' ')"
if ! verilator --binary -j 0 --assert --timing -Wno-fatal -Wno-TIMESCALEMOD \
     -DCCV_CHECK -DCCV_TRACE -DCCV_RCU_RTL $INC --top-module tb --Mdir "$B/svh_rtl_vo" -o ccv-svh \
     -CFLAGS "-std=c++17 -O1 -DCCV_RCU_RTL -I$R/sim/include -I$R/sim/generated -I$R/sim/skel" \
     $SVR "$R/sim/skel/dpi_host.cpp" $BLOCKS \
     "$R/sim/skel/oracle.cpp" "$R/sim/skel/machine.cpp" "$R/sim/skel/portdump.cpp" \
     "$R/sim/skel/exerciser.cpp" "$R/sim/src/event.cpp" \
     "$R/sim/dpi/ccv_event_dpi.cpp" >"$B/svh_rtl_build.log" 2>&1; then
  bad "RCU's RTL in the SV top: builds" "$(grep -m1 -iE '%Error|error:' "$B/svh_rtl_build.log")"
  exit 1
fi
SVHR="$B/svh_rtl_vo/ccv-svh"
rm -rf "$RV"; mkdir -p "$RV"
rtl() { local k=$1 t=$2; shift 2
  CCV_RCU_EVLOG="$RV/$t.ev" "$SVHR" "+ccv_oracle=$B/oracle/$k/oracle.jsonl" "+ccv_rcu_svh=$RV/$t" "$@" >"$RV/$t.log" 2>/dev/null
  python3 test/rcu/svh.py compare "$RV/$t" 2>/dev/null | tail -1 >"$RV/$t.cmp"; }
nk=0; fails=""
for k in $(ls -d test/kernels/*/ | xargs -n1 basename); do
  rtl "$k" "$k"; nk=$((nk + 1))
  why=""
  grep -q "^SVHOST shims=46/46 skewed=none" "$RV/$k.log" || why="$why hosted"
  grep -q " violations=0$" "$RV/$k.log" || why="$why violations"
  # Not XFER: the C++ runs above are traced, these are not.
  [ "$(lines "$B/svh_cpp_$k.log" | grep -v '^XFER ')" = "$(lines "$RV/$k.log")" ] || why="$why KERNEL"
  grep -qx "rcu=rtl divergences=0" "$RV/$k.cmp" || why="$why $(cat "$RV/$k.cmp")"
  [ -z "$why" ] || fails="$fails $k:${why# }"
done
if [ -z "$fails" ]; then
  say "RCU's RTL in the SV top: == C++, == model" "PASS ($nk kernels, rcu=rtl divergences=0)"
else
  bad "RCU's RTL in the SV top" "${fails# }"
fi
# Controls, on vadd: the compare's own (an event, the gate, a row changed in
# the RTL's record: test/rcu/lockstep.py --control), the shadow a cycle late
# (one shim delay, as above), and a bit of an RTL register-file row flipped
# under the end-of-run compare (+ccv_rcu_svh_flip: the first GPR the host
# reads, and the stored row at the next edge).
missed=""
for c in ev gate row; do
  # Captured first: compare exits 1 on a divergence, and pipefail is on.
  out=$(python3 test/rcu/svh.py compare "$RV/vadd" --control "$c" 2>/dev/null)
  echo "$out" | tail -1 | grep -qx "rcu=rtl divergences=[1-9][0-9]*" || missed="$missed $c"
done
rtl vadd skew "+ccv_shim_delay=u_rcu"
grep -q "^SVHOST .* skewed=u_rcu$" "$RV/skew.log" && grep -qx "rcu=rtl divergences=[1-9][0-9]*" "$RV/skew.cmp" ||
  missed="$missed shadow-late"
rtl vadd flip "+ccv_rcu_svh_flip"
[ "$(field "$RV/flip.log" gpr_mismatch)" = 1 ] || missed="$missed flip"
if [ -z "$missed" ]; then
  say "  ...controls: ev, gate, row, shadow late, flip" "PASS (each caught)"
else
  bad "RCU's RTL in the SV top: controls" "not caught:$missed"
fi
rm -f "$RV"/*.vcd "$RV"/*.obs "$RV"/*.ev

exit $fail
