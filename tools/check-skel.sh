#!/usr/bin/env bash
# Stage 3 skeleton -- S0, the plumbing milestone.
#
# The whole machine wired from the schema -- 45 block instances, 103 channel
# instances, 340 credited slots -- every block running the exerciser stub,
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
#   0 violations, 3 seeds                       phantom-all: all 341 fire
#                                               stall-all:   all 341 fire
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
if ! verilator $VCOMMON --assert -DCCV_TRACE --top-module ccv_skel_checkers \
     --Mdir "$B/skel" -o ccv-skel \
     -CFLAGS "-std=c++17 -O1 -I$R/sim/include -I$R/sim/generated -I$R/sim/skel" \
     rtl/ccv_assert_pkg.sv rtl/if/ccv_credit_checker.sv \
     rtl/if/ccv_atomic_checker.sv rtl/if/ccv_lockstep_checker.sv \
     rtl/if/ccv_binding_checker.sv rtl/if/ccv_outstanding_checker.sv \
     rtl/generated/ccv_skel_checkers.sv \
     "$R/sim/skel/main.cpp" "$R/sim/skel/machine.cpp" \
     "$R/sim/skel/exerciser.cpp" "$R/sim/skel/kernel.cpp" \
     "$R/sim/skel/oracle.cpp" "$R/sim/src/event.cpp" \
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

# Keys are matched WHOLE -- preceded by a space or the line start. A bare
# `violations=` also matches inside `class_violations=`, which comes first on
# the line, so a run with 186 checker violations read as 0: this gate would
# have failed OPEN. (The same trap caught `slots=` inside `idle_slots=`.)
field() {
  grep -oE "(^| )$2=[0-9a-z]+" "$1" | head -1 | sed 's/.*=//'
}

# -- every expected count, re-derived INDEPENDENTLY of tools/gen-skel.py ---
# The slot count is the one number a clean run does not validate: a wrong
# rate on a times-32 channel inflates it and every slot that exists is still
# checked. So it is recomputed here from the schema by separate code, and the
# binary, the generated bank and the derivation document must all agree.
eval "$(python3 tools/skel-expect.py)"
bank_cc=$(grep -c "^  ccv_credit_checker #" rtl/generated/ccv_skel_checkers.sv)
bank_ac=$(grep -c "^  ccv_atomic_checker #" rtl/generated/ccv_skel_checkers.sv)
bank_lc=$(grep -c "^  ccv_lockstep_checker #" rtl/generated/ccv_skel_checkers.sv)
bank_bc=$(grep -c "^  ccv_binding_checker #" rtl/generated/ccv_skel_checkers.sv)
bank_oc=$(grep -c "^  ccv_outstanding_checker #" rtl/generated/ccv_skel_checkers.sv)
doc_n=$(grep -oE "\*\*[0-9]+ slots\*\*" docs/skeleton-slots.md | grep -oE "[0-9]+")
"$SKEL" --cycles 4 >"$B/skel_count.log" 2>&1
bin_n=$(field "$B/skel_count.log" slots)
if [ "$bank_cc" = "$X_SLOTS" ] && [ "$bin_n" = "$X_SLOTS" ] &&
   [ "$doc_n" = "$X_SLOTS" ] && [ "$bank_ac" = "$X_MULTI" ] &&
   [ "$bank_lc" = "$X_LOCKSTEP" ] && [ "$bank_bc" = "$X_BINDING" ] &&
   [ "$bank_oc" = "$X_OUTSTANDING" ] &&
   [ "$(field "$B/skel_count.log" chan_insts)" = "$X_INSTS" ] &&
   [ "$(field "$B/skel_count.log" chan_types)" = "$X_TYPES" ]; then
  say "slots re-derived: $X_TYPES types, $X_INSTS instances" \
      "PASS ($X_SLOTS slots, $X_MULTI groups)"
else
  bad "slot count re-derived from the schema" \
      "schema $X_SLOTS, binary $bin_n, bank $bank_cc, doc $doc_n; groups $bank_ac/$X_MULTI; lockstep $bank_lc/$X_LOCKSTEP; binding $bank_bc/$X_BINDING; outstanding $bank_oc/$X_OUTSTANDING"
fi

# -- the trace sideband is invisible to synthesis --------------------------
# Instruction identity is trace-only: it must not exist without CCV_TRACE.
# Asked of Yosys itself, both ways round, so the check can see the port when
# it IS there.
ports() {
  yosys -p "read_verilog -sv -formal $1 -Irtl/include -Irtl/generated \
              rtl/ccv_assert_pkg.sv; \
            read_verilog -sv -formal $1 -Irtl/include -Irtl/generated \
              rtl/if/ccv_credit_checker.sv; \
            prep -top ccv_credit_checker; select -list i:*" 2>/dev/null \
    | grep -oE "ccv_credit_checker/[a-z_]+" | sed 's|.*/||' | sort | tr '\n' ' '
}
if command -v yosys >/dev/null 2>&1; then
  plain=$(ports ""); traced=$(ports "-DCCV_TRACE")
  if ! echo "$plain" | grep -qw ch_tid && echo "$traced" | grep -qw ch_tid; then
    say "trace id absent from synthesis, present in trace" "PASS"
  else
    bad "trace id gated by CCV_TRACE" "without: {$plain} with: {$traced}"
  fi
fi

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
  [ "$(field "$log" tid_mismatches)" = "0" ]   || why="$why; trace ids wrong"
  [ "$(field "$log" class_violations)" = "0" ] || why="$why; id class not in channel's set"
  [ "$(field "$log" match)" = "yes" ]    || why="$why; EV_CH_XFER payloads/ids != launched"
  [ "$(field "$log" channels_seen)" = "$X_TYPES" ] || why="$why; not all $X_TYPES channels traced"
  if [ -n "$why" ]; then
    bad "seed $seed: clean run" "${why#; }"
  else
    say "seed $seed: $(field "$log" sent) msgs, 0 violations" "PASS"
  fi
done
say "  (every slot used; sent == received; XFER == launched, ids too)" ""

# -- atomic acceptance: clean when honoured, loud when broken --------------
log="$B/skel_force_atomic.log"
"$SKEL" --cycles 2000 --seed 1 --force-atomic --trace "$B/skel_fa.ccvtrace" \
  >"$log" 2>&1
if [ "$(field "$log" violations)" = "0" ] && [ "$(field "$log" mismatches)" = "0" ] &&
   [ "$(field "$log" idle_slots)" = "0" ] && [ "$(field "$log" match)" = "yes" ]; then
  say "--force-atomic: every group moves whole, clean" "PASS ($X_MULTI groups)"
else
  bad "--force-atomic clean run" "$(grep '^SKEL' "$log")"
fi

# -- negative controls: every checker instance, by name -------------------
slots=$X_SLOTS
for mode in phantom-all:no_phantom_credit stall-all:stall_honoured \
            atomic-all:atomic_credit+atomic_valid \
            lockstep-all:lockstep_credit+lockstep_valid; do
  m=${mode%%:*}; prop=${mode#*:}
  log="$B/skel_$m.log"
  "$SKEL" --cycles 40 --break "$m" >"$log" 2>&1
  # An instance is the hierarchy up to the checker: drop the property name
  # and, for mode-resolved contracts, the generate block that holds it.
  inst=$(grep -o "Assertion failed in [^:]*" "$log" \
         | sed 's/Assertion failed in //; s/\.[a-z_]*$//; s/\.g_[a-z_]*$//' \
         | sort -u | wc -l)
  props=$(grep -o "CCV [a-z_]* failed" "$log" | awk '{print $2}' | sort -u \
          | tr '\n' '+' | sed 's/+$//')
  want_n=$slots; [ "$m" = "atomic-all" ] && want_n=$X_MULTI
  [ "$m" = "lockstep-all" ] && want_n=$X_LOCKSTEP
  if [ "$inst" = "$want_n" ] && [ "$props" = "$prop" ]; then
    say "--break $m: all $want_n checkers fire" "PASS"
  else
    bad "--break $m" "$inst of $want_n instances fired {$props}, want {$prop}"
  fi
done

# -- ordered channels: consuming out of order must be caught --------------
log="$B/skel_misorder.log"
"$SKEL" --cycles 400 --break misorder >"$log" 2>&1
hit=$(grep -o "MISMATCH [a-z_]*" "$log" | awk '{print $2}' | sort -u | tr '\n' ' ' | sed 's/ $//')
if [ "$(field "$log" mismatches)" != "0" ] && [ "$hit" = "$X_ORDERED" ]; then
  say "--break misorder: caught on the ordered channel" "PASS ($hit)"
else
  bad "--break misorder" "mismatches on {$hit}, want {$X_ORDERED}"
fi

# -- binding under lockstep: the same instruction in slot k on every lane ---
# Lane 7 carries slot k+1's instruction in slot k: valids and credits still
# match, so only the trace id can see it -- and only lockstep_id may fire.
log="$B/skel_misbind.log"
"$SKEL" --cycles 400 --break misbind >"$log" 2>&1
props=$(grep -o "CCV [a-z_]* failed" "$log" | awk '{print $2}' | sort -u | tr '\n' '+' | sed 's/+$//')
inst=$(grep -o "Assertion failed in [^:]*" "$log" \
       | sed 's/Assertion failed in //; s/\.[a-z_]*$//; s/\.g_[a-z_]*$//' | sort -u | wc -l)
if [ "$props" = "lockstep_id" ] && [ "$inst" = "$X_LOCKSTEP" ]; then
  say "--break misbind: lane takes another slot's instr" "PASS ($inst lockstep checkers)"
else
  bad "--break misbind" "$inst of $X_LOCKSTEP fired {$props}, want {lockstep_id}"
fi

# -- binding key: a message naming another group -------------------------
# Every fet->dec message names the NEXT tier-1 stream: valids, credits and
# ordering are all legal, so only the binding checker can see it -- and only
# binding_key may fire, on every keyed channel instance.
log="$B/skel_misgroup.log"
"$SKEL" --cycles 400 --break misgroup >"$log" 2>&1
props=$(grep -o "CCV [a-z_]* failed" "$log" | awk '{print $2}' | sort -u | tr '\n' '+' | sed 's/+$//')
inst=$(grep -o "Assertion failed in [^:]*" "$log" \
       | sed 's/Assertion failed in //; s/\.[a-z_]*$//' | sort -u | wc -l)
if [ "$props" = "binding_key" ] && [ "$inst" = "$X_BINDING" ]; then
  say "--break misgroup: slot carries another stream" "PASS ($inst binding checker)"
else
  bad "--break misgroup" "$inst of $X_BINDING fired {$props}, want {binding_key}"
fi

# -- id classes: a class a channel may not carry is caught on every one ----
log="$B/skel_wrongclass.log"
"$SKEL" --cycles 400 --break wrong-class >"$log" 2>&1
n=$(field "$log" class_violation_channels)
if [ "$n" = "$X_TYPES" ]; then
  say "--break wrong-class: every channel's set enforced" "PASS ($n channels)"
else
  bad "--break wrong-class" "$n of $X_TYPES channels reported"
fi

# -- the trace loads as Perfetto JSON, one track per channel -------------
if python3 tools/trace2perfetto.py "$B/skel_seed1.ccvtrace" \
     -o "$B/skel.json" >/dev/null 2>&1 &&
   tracks=$(python3 - "$B/skel.json" <<'PY'
import json, sys
d = json.load(open(sys.argv[1]))["traceEvents"]
print(len({(e["pid"], e["tid"]) for e in d if e.get("ph") == "i"}))
PY
   ) && [ "$tracks" = "$X_TYPES" ]; then
  say "trace -> Perfetto JSON, one track per channel" "PASS ($tracks)"
else
  bad "trace -> Perfetto JSON" "${tracks:-conversion failed} track(s)"
fi

exit $fail
