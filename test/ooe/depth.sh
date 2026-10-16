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
# ooe_age at the larger class, with its allocation ports: no estimate in
# OA-1 (the update is off select's loop); it must fit a stage.
yosys -q -p "read_verilog -sv -formal -Irtl/include -Irtl/generated rtl/ccv_assert_pkg.sv rtl/ooe/ooe_age.sv;
             chparam -set N $n_rcu ooe_age; chformal -remove; synth -flatten -top ooe_age;
             dfflegalize -cell \$_DFF_P_ x; write_blif $out/age.blif"
line=$(yosys-abc -c "read_blif $out/age.blif; read_library test/ooe/ngd.genlib; strash; dch; map; print_stats" 2>&1 | tail -1)
d=$(echo "$line" | sed -n 's/.*delay = *\([0-9.]*\).*/\1/p')
l=$(echo "$line" | sed -n 's/.*lev = *\([0-9]*\).*/\1/p')
printf '  %-10s %3s entries, 4 ports:     %5s NGD in %s levels (no estimate; one stage)\n' age "$n_rcu" "$d" "$l"
# ooe_decq at its parameters, the payload cut to 16 bits (its width adds
# fanout, not depth): no estimate in OA-1; one stage is the budget, and it
# is not met while an entry freed at an edge can take an arrival at that
# edge (OI-39).
slots=$(val CCV_TIER1_WARPS) decq=$(val CCV_P_DECQ) decq_warp=$(val CCV_P_DECQ_WARP_MAX) width=$(val CCV_ISSUE_WIDTH)
uops=$(python3 -c "import json; print(next(c['rate'] for c in json.load(open('schema/interfaces.json'))['channels'] if c['name'] == 'ccv_dec_ooe_uop'))")
yosys -q -p "read_verilog -sv -formal -Irtl/include -Irtl/generated rtl/ccv_assert_pkg.sv rtl/ooe/ooe_decq.sv;
             chparam -set S $slots -set Q $decq -set D $decq_warp -set E $uops -set R $width -set P 16 ooe_decq;
             chformal -remove; synth -flatten -top ooe_decq; dfflegalize -cell \$_DFF_P_ x; write_blif $out/decq.blif"
line=$(yosys-abc -c "read_blif $out/decq.blif; read_library test/ooe/ngd.genlib; strash; dch; map; print_stats" 2>&1 | tail -1)
d=$(echo "$line" | sed -n 's/.*delay = *\([0-9.]*\).*/\1/p')
l=$(echo "$line" | sed -n 's/.*lev = *\([0-9]*\).*/\1/p')
printf '  %-10s %3s entries, %s in:       %5s NGD in %s levels (budget 25; OI-39)\n' decq "$decq" "$uops" "$d" "$l"
