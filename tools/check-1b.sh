#!/usr/bin/env bash
# Stage 1b exit criteria (§8):
#
#   "primitive library compiles in all three tools; a smoke property
#    demonstrably fires, and is demonstrably silenced at runtime"
#
# The runtime knob is the plusarg guard, not $assertoff -- Stage 1a found the
# latter unavailable across the whole free stack (docs/stage1a-findings.md F-3).
#
# Three things are checked, not one. That a property fires proves the library
# checks; that another does NOT fire proves it is not simply firing at
# everything; that the first goes quiet under +ccv_assert_off=1 proves the knob
# gates firing rather than doing nothing.
set -uo pipefail
cd "$(dirname "$0")/.."

SMOKE=test/smoke/ccv_assert_smoke.sv
TB=spike/tb/tb_sim.sv
INC=rtl/include
PKG=rtl/ccv_assert_pkg.sv
TMP=$(mktemp -d); trap 'rm -rf "$TMP"' EXIT
fail=0

say()  { printf '  %-46s %s\n' "$1" "$2"; }
bad()  { say "$1" "FAIL -- $2"; fail=1; }

# -- Icarus ----------------------------------------------------------------
if command -v iverilog >/dev/null 2>&1; then
  if iverilog -g2012 -gassertions -I "$INC" -o "$TMP/iv.out" -s tb \
       "$PKG" "$SMOKE" "$TB" >"$TMP/iv.log" 2>&1; then
    on=$(vvp "$TMP/iv.out" 2>&1 | grep -c "smoke_fires")
    off=$(vvp "$TMP/iv.out" +ccv_assert_off=1 2>&1 | grep -c "smoke_fires")
    other=$(vvp "$TMP/iv.out" 2>&1 | grep -c "smoke_holds")
    if   [ "$on"    -lt 1 ]; then bad "icarus: smoke property fires" "never fired"
    elif [ "$off"   -ne 0 ]; then bad "icarus: silenced at runtime" "still fired ($off)"
    elif [ "$other" -ne 0 ]; then bad "icarus: passing property stays quiet" "fired"
    else say "icarus: compiles, fires, silences" "PASS"
    fi
  else
    bad "icarus: library compiles" "$(head -2 "$TMP/iv.log" | tr '\n' ' ')"
  fi
else
  say "icarus" "SKIP -- not installed"
fi

# -- Verilator -------------------------------------------------------------
if command -v verilator >/dev/null 2>&1; then
  if verilator --binary -j 0 --assert --timing -Wno-fatal -I"$INC" \
       --top-module tb --Mdir "$TMP/vobj" "$PKG" "$SMOKE" "$TB" \
       >"$TMP/vl.log" 2>&1 && [ -x "$TMP/vobj/Vtb" ]; then
    on=$("$TMP/vobj/Vtb" 2>&1 | grep -c "smoke_fires")
    off=$("$TMP/vobj/Vtb" +ccv_assert_off=1 2>&1 | grep -c "smoke_fires")
    other=$("$TMP/vobj/Vtb" 2>&1 | grep -c "smoke_holds")
    if   [ "$on"    -lt 1 ]; then bad "verilator: smoke property fires" "never fired"
    elif [ "$off"   -ne 0 ]; then bad "verilator: silenced at runtime" "still fired ($off)"
    elif [ "$other" -ne 0 ]; then bad "verilator: passing property stays quiet" "fired"
    else say "verilator: compiles, fires, silences" "PASS"
    fi
  else
    bad "verilator: library compiles" "$(grep -m1 '%Error' "$TMP/vl.log" || echo '?')"
  fi
else
  say "verilator" "SKIP -- not installed"
fi

# -- sby / Yosys -----------------------------------------------------------
# Formal gets the third check the simulators cannot give: that the property
# still BITES through the enable gate. If the guard were a free variable the
# solver would set it to 0 and everything would pass vacuously, so a FAIL here
# is the pass condition.
if command -v sby >/dev/null 2>&1 && command -v yosys >/dev/null 2>&1; then
  mkdir -p "$TMP/f"
  cp "$PKG" "$SMOKE" "$TMP/f/"
  cp "$INC/ccv_assert.svh" "$TMP/f/"
  cat > "$TMP/f/s.sby" <<SBY
[options]
mode bmc
depth 8
expect fail

[engines]
smtbmc cvc5

[script]
read_verilog -sv -formal ccv_assert_pkg.sv
read_verilog -sv -formal ccv_assert_smoke.sv
prep -top dut

[files]
ccv_assert_pkg.sv
ccv_assert_smoke.sv
ccv_assert.svh
SBY
  out=$(cd "$TMP/f" && sby -f s.sby 2>&1)
  if echo "$out" | grep -q "DONE (FAIL"; then
    if echo "$out" | grep -q "smoke_fires"; then
      say "sby: library elaborates, property bites, named" "PASS"
    else
      say "sby: library elaborates and property bites" "PASS (label not in report)"
    fi
  elif echo "$out" | grep -q "DONE (PASS"; then
    bad "sby: property bites through the enable gate" \
        "BMC passed a property written to be false -- the guard may be disarming formal"
  else
    bad "sby: library elaborates" "$(echo "$out" | grep -m1 ERROR || echo '?')"
  fi
else
  say "sby/yosys" "SKIP -- not installed"
fi

exit $fail
