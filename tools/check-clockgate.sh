#!/usr/bin/env bash
# Clock gating: does the enable survive to a shareable gate?
#
# EXPLORATORY, not a synthesis commitment. Synthesis is deferred (§6 resolved
# scope decisions) and nothing in the flow depends on this. It is in the gate
# anyway, for two seconds of runtime, because an artifact outside the gate
# rots -- and the thing it protects is a DESIGN DIRECTION: RTL written so that
# enables reach synthesis as gating candidates.
#
# Yosys has no `clockgate` pass (F-17). synth/ccv_clockgate_map.v stands in
# for one, and this checks the whole path: enable inferred, gate substituted,
# and -- the part that actually matters -- ONE gate shared across the register
# rather than one per bit.
set -uo pipefail
cd "$(dirname "$0")/.."

fail=0
say() { printf '  %-46s %s\n' "$1" "$2"; }
bad() { say "$1" "FAIL -- $2"; fail=1; }

if ! command -v yosys >/dev/null 2>&1; then
  say "clock gating" "SKIP -- yosys not installed"
  exit 0
fi

TMP=$(mktemp -d); trap 'rm -rf "$TMP"' EXIT

# An 8-bit register with a synchronous reset and a load enable, written the
# way docs/rtl-coding-style.md says to write one.
cat > "$TMP/dut.sv" <<'SV'
module gated_reg (input logic clk, input logic rst, input logic en,
                  input logic [7:0] d, output logic [7:0] q);
  always_ff @(posedge clk) begin
    if (rst)     q <= '0;
    else if (en) q <= d;
  end
endmodule
SV

stat_of() {
  yosys -p "
    # -lib reads the real cell as a blackbox, so its ports are checked
    # against synth/ccv_icg.v rather than against a copy that can drift, and
    # opt_merge can still share it.
    read_verilog -lib synth/ccv_icg.v
    read_verilog -sv $TMP/dut.sv
    synth -top gated_reg
    $1
    select gated_reg
    stat
  " 2>&1 | sed -n '/Printing statistics/,$p'
}

# 1. The enable is inferred at all.
base=$(stat_of "")
if echo "$base" | grep -qE '\$_SDFFE_'; then
  say "enable inferred from the if-enable form" "PASS"
else
  bad "enable inferred" "no enable flop in the netlist"
fi

# 2. The gate is substituted, and SHARED.
gated=$(stat_of "techmap -map synth/ccv_clockgate_map.v
    opt_merge -share_all
    opt_clean")
icg=$(echo "$gated" | grep -oP '\s+ccv_icg\s+\K\d+' || echo 0)
ff=$(echo "$gated" | grep -oP '\s+\$_DFF_P_\s+\K\d+' || echo 0)

if [ "$ff" -ne 8 ]; then
  bad "8 plain flops after gating" "got ${ff:-0}"
elif [ "$icg" -eq 1 ]; then
  say "one ICG shared across all 8 flops" "PASS"
elif [ "$icg" -gt 1 ]; then
  bad "one ICG shared across the register" \
      "got $icg gates for 8 flops -- per-bit gating costs area and clock load and saves nothing. Is opt_merge -share_all still running?"
else
  bad "ICG substituted" "no ccv_icg in the netlist"
fi

# 3. Does the installed Yosys have a real pass yet? Recorded rather than
#    required, so that the day it gains one, this says so instead of the
#    techmap quietly staying in the flow forever.
if yosys -p "clockgate -help" >/dev/null 2>&1; then
  say "yosys now HAS a clockgate pass" "NOTE -- retire the techmap (F-17)"
else
  say "yosys still has no clockgate pass" "as expected (F-17)"
fi

exit $fail
