#!/usr/bin/env bash
# Interface checker convention -- exit criteria.
#
# docs/interface-checker-convention.md, scheduled as part of §8 Stage 1d.
# Checks the MECHANISM, using the reference `issue_t` checker; the real
# interface list is Stage 2's and follows from the partition.
#
# The reference producer is protocol-CORRECT, so the polarity here is the
# opposite of the spike's: nothing may fire. The spike cases prove the
# machinery CAN fire; this proves it does not fire at everything, which a
# checker with an inverted property would also do and which a "does it fire"
# test alone would call a pass.
set -uo pipefail
cd "$(dirname "$0")/.."

TMP=$(mktemp -d); trap 'rm -rf "$TMP"' EXIT
R=$(pwd)
fail=0
say() { printf '  %-46s %s\n' "$1" "$2"; }
bad() { say "$1" "FAIL -- $2"; fail=1; }

RTL="rtl/ccv_assert_pkg.sv rtl/if/ccv_credit_checker.sv test/smoke/credit_smoke.sv"
TB="test/smoke/tb_credit.sv"
# TIMESCALEMOD: the testbench declares a timescale and the design does not,
# which is correct -- §9 keeps delays out of design RTL - and benign.
VFLAGS="-Wno-fatal -Wno-TIMESCALEMOD -Irtl/include -Irtl/generated"

# -- how much of the topology is actually sized --------------------------
# A census, not a gate. Reported every run because "payload widths pending"
# decays into nobody remembering which ones; a number that moves as sessions
# close is harder to lose than a note.
python3 - <<'PY'
import json
d = json.load(open("schema/interfaces.json"))
fw = d.get("field_widths", {})
sized = [c for c in d["channels"]
         if all(f in fw for f in c["payload_fields"])]
ur = {}
for c in d["channels"]:
    for f in c["payload_fields"]:
        if f not in fw:
            ur.setdefault(f, []).append(c["name"])
print("  %-46s %d of %d channels, %d field(s) open"
      % ("payload structs generated", len(sized), len(d["channels"]), len(ur)))
PY

# -- Verilator: builds, stays quiet, emits -------------------------------
if command -v verilator >/dev/null 2>&1; then
  if verilator --binary -j 0 --assert --timing $VFLAGS \
       -CFLAGS "-I$R/sim/include -I$R/sim/generated" \
       --top-module tb --Mdir "$TMP/vo" \
       $RTL $TB "$R/sim/src/event.cpp" "$R/sim/dpi/ccv_event_dpi.cpp" \
       >"$TMP/v.log" 2>&1 && [ -x "$TMP/vo/Vtb" ]; then
    out=$(cd "$TMP" && ./vo/Vtb 2>&1)
    fired=$(echo "$out" | grep -c "CCV .* failed")
    if [ "$fired" -ne 0 ]; then
      bad "verilator: protocol-correct producer stays quiet" \
          "$(echo "$out" | grep -m1 'CCV .* failed')"
    else
      say "verilator: checker builds, nothing fires" "PASS"
    fi

    # Emission from the checker (convention §5, F-13).
    n=$(cd "$TMP" && ls -l credit.ccvtrace 2>/dev/null | awk '{print $5}')
    if [ -n "${n:-}" ] && [ "$n" -gt 40 ]; then
      say "verilator: checker emits events via DPI-C" "PASS"
    else
      bad "checker emits events via DPI-C" "no trace, or header only"
    fi

    # The trace knob is SEPARATE from the assertion knob (convention §6).
    # Checking they are independent is the point: one knob could not express
    # "check the protocol but do not pay for the trace", which is what a
    # bring-up run wants.
    on=$(cd "$TMP" && ./vo/Vtb 2>&1 | grep -c "TRACE_EVENTS" || true)
    rm -f "$TMP/credit.ccvtrace"
    (cd "$TMP" && ./vo/Vtb +ccv_trace_off=1 >/dev/null 2>&1)
    n2=$(cd "$TMP" && ls -l credit.ccvtrace 2>/dev/null | awk '{print $5}')
    if [ "${n2:-0}" -le 40 ]; then
      say "verilator: +ccv_trace_off silences emission only" "PASS"
    else
      bad "+ccv_trace_off silences emission" "still emitted ($n2 bytes)"
    fi

  # -- negative control: the CONFIGURATION checks still bite ---------------
  # cfg_depth_covers_round_trip and cfg_timeout_covers_round_trip guard the two
  # misconfigurations that produce no protocol violation, so if either one
  # ever stopped firing nothing above would notice -- every other check here
  # is a "stays quiet" check, and a check that has been deleted is very quiet.
  # Each build breaks ONE parameter and the assertion NAME is matched, so a
  # different property firing does not count as a pass.
  for probe in "DEPTH:1:cfg_depth_covers_round_trip" \
               "TIMEOUT_N:1:cfg_timeout_covers_round_trip"; do
    par=${probe%%:*}; rest=${probe#*:}; val=${rest%%:*}; want=${rest##*:}
    sed -E "s/\\.${par}\\([^)]*\\)/.${par}(${val})/" \
        test/smoke/credit_smoke.sv > "$TMP/neg_$par.sv"
    if verilator --binary -j 0 --assert --timing $VFLAGS \
         -CFLAGS "-I$R/sim/include -I$R/sim/generated" \
         --top-module tb --Mdir "$TMP/neg_$par" \
         rtl/ccv_assert_pkg.sv rtl/if/ccv_credit_checker.sv \
         "$TMP/neg_$par.sv" $TB \
         "$R/sim/src/event.cpp" "$R/sim/dpi/ccv_event_dpi.cpp" \
         >"$TMP/neg_$par.log" 2>&1 && [ -x "$TMP/neg_$par/Vtb" ]; then
      # Run to a FILE, not through a pipe. A tripped assertion calls $stop
      # and the binary aborts (F-15), and under `set -o pipefail` that abort
      # status becomes the pipeline's -- so `Vtb | grep -q` reports failure on
      # the very run that is supposed to fail. Which is exactly backwards.
      # The outer 2>/dev/null suppresses the shell's own "Aborted" job notice
      # about that death -- the abort is the expected result here, and a line
      # of alarming-looking noise next to a PASS teaches people to skim.
      { (cd "$TMP" && "./neg_$par/Vtb" >"neg_$par.out" 2>&1) || true; } \
        2>/dev/null
      if grep -q "$want" "$TMP/neg_$par.out"; then
        say "verilator: bad $par trips $want" "PASS"
      else
        bad "bad $par trips $want" "misconfiguration went unreported"
      fi
    else
      bad "bad $par trips $want" "negative-control build failed"
    fi
  done
  else
    bad "verilator: checker builds" "$(grep -m1 '%Error' "$TMP/v.log" || echo '?')"
  fi
else
  say "verilator" "SKIP -- not installed"
fi

# -- the reference producer obeys the stall rule at EVERY phase -----------
# A single-cycle stall at each cycle 3..30 in turn. The smoke stimulus above
# stalls for one window at one phase, and the producer used to react to a
# stall one cycle late -- which violated the rule at half of all phases while
# the one window happened to land where it was out of credits anyway. So it
# passed for months. One run per phase costs milliseconds on Icarus.
#
# And the sweep gets its own negative control: CCV_NEG_LATE_STALL rebuilds the
# producer with the old bug, and the sweep must catch it. Without that, this
# is one more "stays quiet" check, and quiet is what a sweep that tests
# nothing also looks like.
sweep() {   # $1 = compiled vvp image; prints the phases that fired
  for p in $(seq 3 30); do
    vvp "$1" +pulse=$p 2>&1 | grep -q "CCV .* failed" && printf '%s ' "$p"
  done
}
if command -v iverilog >/dev/null 2>&1; then
  if iverilog -g2012 -gassertions -Irtl/include -Irtl/generated \
       -o "$TMP/sw.out" -s tb $RTL $TB >"$TMP/sw.log" 2>&1 &&
     iverilog -g2012 -gassertions -DCCV_NEG_LATE_STALL -Irtl/include \
       -Irtl/generated -o "$TMP/sw_bug.out" -s tb $RTL $TB \
       >>"$TMP/sw.log" 2>&1; then
    good=$(sweep "$TMP/sw.out"); buggy=$(sweep "$TMP/sw_bug.out")
    if [ -n "$good" ]; then
      bad "producer honours stall at every phase" "fires at phase(s) $good"
    elif [ -z "$buggy" ]; then
      bad "stall sweep catches a late-stall producer" \
          "the old bug passed the sweep -- it has no teeth"
    else
      say "producer honours stall at all 28 phases" "PASS"
      say "  ...and the sweep catches the old late stall" \
          "PASS ($(echo $buggy | wc -w) phases)"
    fi
  else
    bad "stall sweep builds" "$(head -1 "$TMP/sw.log")"
  fi
fi

# -- negative controls: the PROTOCOL properties bite, and only them --------
# test/neg/tb_credit_neg.sv drives the checker's ports directly, one protocol
# violation per case, written from the protocol rather than from the checker.
# Each FIRE case must trip exactly its property and nothing else; each QUIET
# case sits exactly at a legal limit and must stay silent. The pairs bracket
# every counter, because an off-by-one in a tracking register is invisible to
# a case that overshoots by a mile.
#
# Both simulators, for different reasons. Icarus does not stop on a failure,
# so its result is the EXACT set of properties that fired -- that is what
# proves a case trips one property rather than one first. Verilator $stops on
# the first failure (F-15), so it proves the target fires first, and it is the
# simulator the skeleton runs on.
#
# These cases found four bugs in the checker when first written: a timeout
# loose by one cycle, a per-message bound that was really ~2N for anything
# but the oldest message, a phantom credit that corrupted the count into a
# bogus overrun, and a same-edge phantom the property excused. That is the
# argument for keeping them: the "stays quiet" checks above passed throughout.
NEG_CASES="overrun:no_overrun at_depth:- phantom:no_phantom_credit
  phantom_with_send:no_phantom_credit stall:stall_honoured
  xpayload:payload_known_when_due timeout:response_within_n timeout_at_n:-
  timeout_n1:response_within_n timeout_second:response_within_n
  second_late:response_within_n"
NEG_SRC="rtl/ccv_assert_pkg.sv rtl/if/ccv_credit_checker.sv test/neg/tb_credit_neg.sv"

fired() {   # the sorted, de-duplicated set of properties named in a log
  grep -o "CCV [a-z_0-9]* failed" "$1" 2>/dev/null | awk '{print $2}' \
    | sort -u | tr '\n' ' ' | sed 's/ $//'
}

have_v=0; have_i=0
if command -v verilator >/dev/null 2>&1 && \
   verilator --binary -j 0 --assert --timing $VFLAGS \
     -CFLAGS "-I$R/sim/include -I$R/sim/generated" \
     --top-module tb --Mdir "$TMP/neg_vo" $NEG_SRC \
     "$R/sim/src/event.cpp" "$R/sim/dpi/ccv_event_dpi.cpp" \
     >"$TMP/neg_vb.log" 2>&1 && [ -x "$TMP/neg_vo/Vtb" ]; then
  have_v=1
fi
if command -v iverilog >/dev/null 2>&1 && \
   iverilog -g2012 -gassertions -Irtl/include -Irtl/generated \
     -o "$TMP/neg_iv.out" -s tb $NEG_SRC >"$TMP/neg_ib.log" 2>&1; then
  have_i=1
fi
[ "$have_v" = 1 ] || bad "negative controls: verilator build" \
  "$(grep -m1 '%Error' "$TMP/neg_vb.log" 2>/dev/null || echo 'not installed')"
[ "$have_i" = 1 ] || bad "negative controls: icarus build" \
  "$(head -1 "$TMP/neg_ib.log" 2>/dev/null || echo 'not installed')"

for pair in $NEG_CASES; do
  cs=${pair%%:*}; want=${pair#*:}; [ "$want" = "-" ] && want=""
  why=""

  if [ "$have_i" = 1 ]; then
    vvp "$TMP/neg_iv.out" +case="$cs" >"$TMP/neg_i_$cs.log" 2>&1
    got=$(fired "$TMP/neg_i_$cs.log")
    # A run that died early is silent, and silence is what a QUIET case is
    # looking for -- so reaching the end marker is part of passing.
    if ! grep -q "NEG_END $cs" "$TMP/neg_i_$cs.log"; then
      why="icarus run did not complete"
    elif [ "$got" != "$want" ]; then
      why="icarus fired {${got:-nothing}}, want {${want:-nothing}}"
    fi
  fi

  if [ -z "$why" ] && [ "$have_v" = 1 ]; then
    # To a file, not a pipe: the tripped assertion aborts the binary, and
    # under pipefail that abort would become the pipeline's status.
    { (cd "$TMP" && "./neg_vo/Vtb" +case="$cs" >"neg_v_$cs.log" 2>&1) || true; } \
      2>/dev/null
    got=$(fired "$TMP/neg_v_$cs.log")
    vwant=$want
    # Verilator is two-state: an X on the payload is a 0 or a 1 by the time
    # anything can look at it, so $isunknown cannot fire there at all. That is
    # a property of the tool (F-6), not of the checker, and it is why Icarus
    # is a required witness above rather than a redundant one.
    [ "$cs" = "xpayload" ] && vwant=""
    if [ -z "$vwant" ] && ! grep -q "NEG_END $cs" "$TMP/neg_v_$cs.log"; then
      why="verilator run did not complete"
    elif [ "$got" != "$vwant" ]; then
      why="verilator fired {${got:-nothing}}, want {${vwant:-nothing}}"
    fi
  fi

  if [ -n "$why" ]; then
    bad "neg: $cs" "$why"
  elif [ -n "$want" ]; then
    note=""; [ "$cs" = "xpayload" ] && note=" (icarus only; 2-state blind)"
    say "neg: $cs trips only $want" "PASS$note"
  else
    say "neg: $cs stays quiet at the limit" "PASS"
  fi
done

# -- Icarus: the SAME checker source still compiles without DPI -----------
# F-13: Icarus has no DPI at all. The emission guard exists so the X-pass can
# still run the checker with its properties fully intact, and this is the
# check that the guard actually achieves that.
if command -v iverilog >/dev/null 2>&1; then
  if iverilog -g2012 -gassertions -Irtl/include -Irtl/generated \
       -o "$TMP/iv.out" -s tb $RTL $TB >"$TMP/i.log" 2>&1; then
    out=$(vvp "$TMP/iv.out" 2>&1)
    if echo "$out" | grep -q "CCV .* failed"; then
      bad "icarus: protocol-correct producer stays quiet" \
          "$(echo "$out" | grep -m1 'CCV')"
    else
      say "icarus: same checker compiles without DPI, quiet" "PASS"
    fi
  else
    bad "icarus: checker compiles without DPI" \
        "$(head -2 "$TMP/i.log" | tr '\n' ' ')"
  fi
else
  say "icarus" "SKIP -- not installed"
fi

# -- Formal: the satisfiability covers are REACHABLE ----------------------
# Convention §3.3. This is the guard against a vacuous assume set, and a guard
# that is never run carries no information -- so it runs here, on the real
# checker, not only as spike cases 34/35.
if command -v sby >/dev/null 2>&1 && command -v yosys >/dev/null 2>&1; then
  mkdir -p "$TMP/f"
  cp rtl/ccv_assert_pkg.sv rtl/if/ccv_credit_checker.sv \
     test/smoke/credit_smoke.sv "$TMP/f/"
  cp rtl/include/*.svh rtl/generated/*.svh rtl/generated/*.sv "$TMP/f/"
  cat > "$TMP/f/c.sby" <<SBY
[options]
mode cover
depth 12

[engines]
smtbmc cvc5

[script]
read_verilog -sv -formal -I. ccv_assert_pkg.sv
read_verilog -sv -formal -I. ccv_credit_checker.sv
read_verilog -sv -formal -I. credit_smoke.sv
prep -top credit_smoke

[files]
ccv_assert_pkg.sv
ccv_credit_checker.sv
credit_smoke.sv
ccv_assert.svh
ccv_if.svh
ccv_trace.svh
ccv_interfaces.svh
ccv_event_ids.svh
ccv_params_pkg.sv
SBY
  out=$(cd "$TMP/f" && sby -f c.sby 2>&1)
  if echo "$out" | grep -q "DONE (PASS"; then
    say "formal: satisfiability covers all reachable" "PASS"
  elif echo "$out" | grep -qE "Unreached cover|DONE \(FAIL"; then
    bad "formal: satisfiability covers reachable" \
        "a cover is UNREACHABLE -- the assumption set may be contradictory, which would make every proof over it vacuously true"
  else
    bad "formal: checker elaborates under sby" \
        "$(echo "$out" | grep -m1 ERROR || echo '?')"
  fi
else
  say "sby/yosys" "SKIP -- not installed"
fi

exit $fail
