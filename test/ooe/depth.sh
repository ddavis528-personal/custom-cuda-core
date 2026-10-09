#!/usr/bin/env bash
# Logic depth of OOE RTL in NGD, against OA's paper estimate (OA-1, the
# OOE microarchitecture doc's "Scheduler timing estimate"). Yosys
# synthesises, ABC maps to test/ooe/ngd.genlib (each gate at its
# fanout-of-4 delay over a NAND2's, so 1.00 is one NAND-equivalent stage)
# and reports the critical path. Flops, broadcast fanout and wire are not
# in it: compare against the estimate's logic terms only.
# Usage: test/ooe/depth.sh
set -euo pipefail
cd "$(dirname "$0")/../.."
pkg=rtl/generated/ccv_params_pkg.sv
val() { sed -n "s/.*localparam int $1 = \([0-9]*\);.*/\1/p" "$pkg"; }
n_rcu=$(val CCV_P_RS_RCU) n_miu=$(val CCV_P_RS_MIU) secs=$(val CCV_SECTIONS) pipes=$(val CCV_MIU_PIPES)
out=build/ooe-rtl/depth
mkdir -p "$out"
# name, N, R, OA's logic terms in NGD (age AND, OR of older requests, win,
# footprint AND; the issued mask is the caller's)
for cfg in "pick_rcu $n_rcu $((secs + 1)) 9.1" "pick_miu $n_miu $pipes 7.7"; do
  set -- $cfg
  yosys -q -p "read_verilog -sv rtl/ooe/ooe_pick.sv; chparam -set N $2 -set R $3 ooe_pick;
               synth -flatten -top ooe_pick; write_blif $out/$1.blif"
  line=$(yosys-abc -c "read_blif $out/$1.blif; read_library test/ooe/ngd.genlib; strash; dch; map; print_stats" 2>&1 | tail -1)
  d=$(echo "$line" | sed -n 's/.*delay = *\([0-9.]*\).*/\1/p')
  l=$(echo "$line" | sed -n 's/.*lev = *\([0-9]*\).*/\1/p')
  printf '  %-10s %3s entries, %s resources: %5s NGD in %s levels (estimate %s)\n' "$1" "$2" "$3" "$d" "$l" "$4"
done
# ooe_ready over both classes: the estimate's logic terms are the cell
# select and dependency gate (3.5) and the row-wide AND (5.6).
n=$((n_rcu + n_miu))
yosys -q -p "read_verilog -sv rtl/ooe/ooe_ready.sv; chparam -set N $n ooe_ready;
             synth -flatten -top ooe_ready; write_blif $out/ready.blif"
line=$(yosys-abc -c "read_blif $out/ready.blif; read_library test/ooe/ngd.genlib; strash; dch; map; print_stats" 2>&1 | tail -1)
d=$(echo "$line" | sed -n 's/.*delay = *\([0-9.]*\).*/\1/p')
l=$(echo "$line" | sed -n 's/.*lev = *\([0-9]*\).*/\1/p')
printf '  %-10s %3s entries, 4 wake lines: %5s NGD in %s levels (estimate 9.1)\n' ready "$n" "$d" "$l"
