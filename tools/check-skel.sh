#!/usr/bin/env bash
# Stage 3 skeleton -- S0, the plumbing milestone.
#
# The whole machine wired from the schema -- 45 block instances, 102 channel
# instances, 339 credited slots -- every block running the exerciser stub,
# every slot judged by the SV credit checker Verilated in beside it. Before
# any block does anything real, this proves the machine is connected, every
# slot carries traffic under backpressure, the protocol holds, and every
# payload bit lands where both languages agree it should.
#
# Every "it is clean" result here has a partner that must NOT be clean, since
# a checker bank that is not connected produces exactly the same clean run as
# one that is:
#
#   clean                                       negative control
#   0 violations, 3 seeds                       phantom-all: all 339 fire
#                                               stall-all:   all 339 fire
#   EV_CH_XFER payloads == launched payloads    (the match is exact, so a
#                                                miswired payload bit fails it)
#   C++ field offsets == SV packed structs      --mutate: every shiftable
#                                                field must disagree
set -uo pipefail
cd "$(dirname "$0")/.."
R=$(pwd)
B="$R/build"
fail=0
say() { printf '  %-46s %s\n' "$1" "$2"; }
bad() { say "$1" "FAIL -- $2"; fail=1; }

if ! command -v verilator >/dev/null 2>&1; then
  say "skeleton" "SKIP -- verilator not installed"
  exit 0
fi
mkdir -p "$B"

# -- build ---------------------------------------------------------------
VCOMMON="--cc --exe --build -j 0 -Wno-fatal -Wno-TIMESCALEMOD -Irtl/include -Irtl/generated"
if ! verilator $VCOMMON --assert --top-module ccv_skel_checkers \
     --Mdir "$B/skel" -o ccv-skel \
     -CFLAGS "-std=c++17 -O1 -I$R/sim/include -I$R/sim/generated -I$R/sim/skel" \
     rtl/ccv_assert_pkg.sv rtl/if/ccv_credit_checker.sv \
     rtl/generated/ccv_skel_checkers.sv \
     "$R/sim/skel/main.cpp" "$R/sim/skel/machine.cpp" \
     "$R/sim/skel/exerciser.cpp" "$R/sim/src/event.cpp" \
     "$R/sim/dpi/ccv_event_dpi.cpp" >"$B/skel.log" 2>&1; then
  bad "skeleton builds" "$(grep -m1 -i error "$B/skel.log")"
  exit 1
fi
if ! verilator $VCOMMON --top-module ccv_skel_layout_probe \
     --Mdir "$B/probe" -o layout-probe \
     -CFLAGS "-std=c++17 -O1 -I$R/sim/skel -I$R/sim/generated" \
     rtl/generated/ccv_skel_layout_probe.sv "$R/sim/skel/layout_probe.cpp" \
     >"$B/probe.log" 2>&1; then
  bad "layout probe builds" "$(grep -m1 -i error "$B/probe.log")"
  exit 1
fi
SKEL="$B/skel/ccv-skel"
say "skeleton builds (checker bank Verilated in)" "PASS"

field() { grep -o "$2=[0-9a-z]*" "$1" | head -1 | cut -d= -f2; }

# -- the payload layout agrees across the two languages ------------------
if out=$("$B/probe/layout-probe" 2>&1); then
  say "C++ field offsets == SV packed structs" \
      "PASS ($(echo "$out" | grep -o 'rounds=[0-9]*'))"
else
  bad "C++ field offsets == SV packed structs" "$(echo "$out" | head -2)"
fi
if out=$("$B/probe/layout-probe" --mutate 2>&1); then
  n=$(echo "$out" | grep -o 'caught=[0-9]*' | cut -d= -f2)
  say "  ...a 1-bit offset shift is caught on every field" "PASS ($n fields)"
else
  bad "layout probe catches a shifted offset" "$(echo "$out" | head -1)"
fi

# -- clean runs: three seeds ----------------------------------------------
for seed in 1 2 3; do
  log="$B/skel_seed$seed.log"
  "$SKEL" --cycles 2000 --seed $seed --trace "$B/skel_seed$seed.ccvtrace" \
    >"$log" 2>&1
  rc=$?
  why=""
  [ $rc -eq 0 ] || why="exit $rc"
  [ "$(field "$log" violations)" = "0" ] || why="$why; $(field "$log" violations) checker violations"
  [ "$(field "$log" mismatches)" = "0" ] || why="$why; payload mismatches"
  [ "$(field "$log" overflows)" = "0" ]  || why="$why; receive overflow"
  [ "$(field "$log" idle_slots)" = "0" ] || why="$why; $(field "$log" idle_slots) idle slot(s)"
  [ "$(field "$log" sent)" = "$(field "$log" received)" ] || why="$why; sent != received"
  [ "$(field "$log" match)" = "yes" ]    || why="$why; EV_CH_XFER payloads != launched"
  [ "$(field "$log" channels_seen)" = "40" ] || why="$why; not all 40 channels traced"
  if [ -n "$why" ]; then
    bad "seed $seed: clean run" "${why#; }"
  else
    say "seed $seed: $(field "$log" sent) msgs, 0 violations" "PASS"
  fi
done
say "  (every slot used; sent == received; XFER == launched)" ""

# -- negative controls: every checker instance, by name -------------------
slots=$(grep -o " slots=[0-9]*" "$B/skel_seed1.log" | cut -d= -f2)  # leading space: not idle_slots
for mode in phantom-all:no_phantom_credit stall-all:stall_honoured; do
  m=${mode%%:*}; prop=${mode#*:}
  log="$B/skel_$m.log"
  "$SKEL" --cycles 40 --break "$m" >"$log" 2>&1
  inst=$(grep -o "Assertion failed in [^:]*" "$log" \
         | sed 's/Assertion failed in //; s/\.[a-z_]*$//' | sort -u | wc -l)
  props=$(grep -o "CCV [a-z_]* failed" "$log" | awk '{print $2}' | sort -u \
          | tr '\n' ' ' | sed 's/ $//')
  if [ "$inst" = "$slots" ] && [ "$props" = "$prop" ]; then
    say "--break $m: all $slots checkers fire" "PASS"
  else
    bad "--break $m" "$inst of $slots instances fired {$props}, want {$prop}"
  fi
done

# -- the trace loads as Perfetto JSON, one track per channel -------------
if python3 tools/trace2perfetto.py "$B/skel_seed1.ccvtrace" \
     -o "$B/skel.json" >/dev/null 2>&1 &&
   tracks=$(python3 - "$B/skel.json" <<'PY'
import json, sys
d = json.load(open(sys.argv[1]))["traceEvents"]
print(len({(e["pid"], e["tid"]) for e in d if e.get("ph") == "i"}))
PY
   ) && [ "$tracks" = "40" ]; then
  say "trace -> Perfetto JSON, one track per channel" "PASS (40)"
else
  bad "trace -> Perfetto JSON" "${tracks:-conversion failed} track(s)"
fi

exit $fail
