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

RTL="rtl/ccv_assert_pkg.sv rtl/if/issue_if_checker.sv test/smoke/issue_if_smoke.sv"
TB="test/smoke/tb_issue_if.sv"
# TIMESCALEMOD: the testbench declares a timescale and the design does not,
# which is correct -- §9 keeps delays out of design RTL - and benign.
VFLAGS="-Wno-fatal -Wno-TIMESCALEMOD -Irtl/include -Irtl/generated"

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
    n=$(cd "$TMP" && ls -l issue_if.ccvtrace 2>/dev/null | awk '{print $5}')
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
    rm -f "$TMP/issue_if.ccvtrace"
    (cd "$TMP" && ./vo/Vtb +ccv_trace_off=1 >/dev/null 2>&1)
    n2=$(cd "$TMP" && ls -l issue_if.ccvtrace 2>/dev/null | awk '{print $5}')
    if [ "${n2:-0}" -le 40 ]; then
      say "verilator: +ccv_trace_off silences emission only" "PASS"
    else
      bad "+ccv_trace_off silences emission" "still emitted ($n2 bytes)"
    fi
  else
    bad "verilator: checker builds" "$(grep -m1 '%Error' "$TMP/v.log" || echo '?')"
  fi
else
  say "verilator" "SKIP -- not installed"
fi

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
  cp rtl/ccv_assert_pkg.sv rtl/if/issue_if_checker.sv \
     test/smoke/issue_if_smoke.sv "$TMP/f/"
  cp rtl/include/*.svh rtl/generated/*.svh rtl/generated/*.sv "$TMP/f/"
  cat > "$TMP/f/c.sby" <<SBY
[options]
mode cover
depth 12

[engines]
smtbmc cvc5

[script]
read_verilog -sv -formal -I. ccv_assert_pkg.sv
read_verilog -sv -formal -I. issue_if_checker.sv
read_verilog -sv -formal -I. issue_if_smoke.sv
prep -top issue_producer

[files]
ccv_assert_pkg.sv
issue_if_checker.sv
issue_if_smoke.sv
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
