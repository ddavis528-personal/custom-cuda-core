#!/usr/bin/env bash
# Logic depth of OOE RTL in NGD, against OA's paper estimate (OA-1, the
# OOE microarchitecture doc's "Scheduler timing estimate"). Yosys
# synthesises, ABC maps to test/ooe/ngd.genlib (each gate at its
# fanout-of-4 delay over a NAND2's, so 1.00 is one NAND-equivalent stage)
# and reports the critical path. Flops, broadcast fanout and wire are not
# in it: compare against the estimate's logic terms only.
# A clock-gated flop is mapped as the design has it (test/ooe/ungate.py):
# its D is the next value, its enable timed apart, to its ICG.
# Usage: test/ooe/depth.sh
set -euo pipefail
cd "$(dirname "$0")/../.."
# Yosys through TI's shim: a warning that means the netlist is not the RTL
# fails the run (tools/check-yosys-strict.sh, OI-44).
export PATH="$PWD/tools/shim:$PATH"
pkg=rtl/generated/ccv_params_pkg.sv
val() { sed -n "s/.*localparam int $1 = \([0-9]*\);.*/\1/p" "$pkg"; }
n_rcu=$(val CCV_P_RS_RCU) n_miu=$(val CCV_P_RS_MIU) secs=$(val CCV_SECTIONS) pipes=$(val CCV_MIU_PIPES)
out=build/ooe-rtl/depth
mkdir -p "$out"
# A clock-gated flop takes its next value straight from its D; its enable
# is timed apart, to its ICG (test/ooe/ungate.py). <base>.json to <base>.blif.
ungate() {
  python3 test/ooe/ungate.py "$1.json" "$1.ug.json" 2>/dev/null
  yosys -q -p "read_json $1.ug.json; dfflegalize -cell \$_DFF_P_ x; opt_clean; write_blif $1.blif"
}
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
             write_json $out/age.json"; ungate $out/age
line=$(yosys-abc -c "read_blif $out/age.blif; read_library test/ooe/ngd.genlib; strash; dch; map; print_stats" 2>&1 | tail -1)
d=$(echo "$line" | sed -n 's/.*delay = *\([0-9.]*\).*/\1/p')
l=$(echo "$line" | sed -n 's/.*lev = *\([0-9]*\).*/\1/p')
printf '  %-10s %3s entries, 4 ports:     %5s NGD in %s levels (no estimate; one stage)\n' age "$n_rcu" "$d" "$l"
# ooe_decq at its parameters, the payload cut to 16 bits (its width adds
# fanout, not depth): no estimate in OA-1; one stage is the budget, met
# because an entry freed at an edge takes no arrival until the next
# (DA's response OI-39).
slots=$(val CCV_TIER1_WARPS) decq=$(val CCV_P_DECQ) decq_warp=$(val CCV_P_DECQ_WARP_MAX) width=$(val CCV_ISSUE_WIDTH)
uops=$(python3 -c "import json; print(next(c['rate'] for c in json.load(open('schema/interfaces.json'))['channels'] if c['name'] == 'ccv_dec_ooe_uop'))")
yosys -q -p "read_verilog -sv -formal -Irtl/include -Irtl/generated rtl/ccv_assert_pkg.sv rtl/ooe/ooe_decq.sv;
             chparam -set S $slots -set Q $decq -set D $decq_warp -set E $uops -set R $width -set P 16 ooe_decq;
             chformal -remove; synth -flatten -top ooe_decq; write_json $out/decq.json"; ungate $out/decq
line=$(yosys-abc -c "read_blif $out/decq.blif; read_library test/ooe/ngd.genlib; strash; dch; map; print_stats" 2>&1 | tail -1)
d=$(echo "$line" | sed -n 's/.*delay = *\([0-9.]*\).*/\1/p')
l=$(echo "$line" | sed -n 's/.*lev = *\([0-9]*\).*/\1/p')
printf '  %-10s %3s entries, %s in:       %5s NGD in %s levels (budget 25)\n' decq "$decq" "$uops" "$d" "$l"
# ooe_freelist at both pools, in its buffered form (OA's response OI-38):
# the grant is the buffer's head; the loop is the banked refill.
phys=$(val CCV_P_PHYS_REGS) preds=$(val CCV_P_PRED_REGS)
fl_buf=$(sed -n 's/.*unsigned fl_buf = \([0-9]*\);.*/\1/p' sim/ooe/ooe_core.h)
fl_banks=$(sed -n 's/.*unsigned fl_banks = \([0-9]*\);.*/\1/p' sim/ooe/ooe_core.h)
for cfg in "freelist_g $phys" "freelist_p $preds"; do
  set -- $cfg
  yosys -q -p "read_verilog -sv -formal -Irtl/include -Irtl/generated rtl/ccv_assert_pkg.sv rtl/ooe/ooe_freelist.sv;
               chparam -set N $2 -set A $width -set B $fl_buf -set K $fl_banks ooe_freelist;
               chformal -remove; synth -flatten -top ooe_freelist; write_json $out/$1.json"; ungate $out/$1
  line=$(yosys-abc -c "read_blif $out/$1.blif; read_library test/ooe/ngd.genlib; strash; dch; map; print_stats" 2>&1 | tail -1)
  d=$(echo "$line" | sed -n 's/.*delay = *\([0-9.]*\).*/\1/p')
  l=$(echo "$line" | sed -n 's/.*lev = *\([0-9]*\).*/\1/p')
  printf '  %-10s %3s entries, %s-entry buffer: %5s NGD in %s levels (budget 25)\n' "$1" "$2" "$fl_buf" "$d" "$l"
done
# ooe_wake over both classes, at its default latencies (the parameters'
# values; run-rtl.sh passes the same): no estimate in OA-1, whose ready
# stage takes the lines from flops ("wake generation is registered timers,
# off this path"); the timers' own update must fit a stage.
yosys -q -p "read_verilog -sv -formal -Irtl/include -Irtl/generated rtl/ccv_assert_pkg.sv rtl/ooe/ooe_wake.sv;
             chparam -set N $n ooe_wake;
             chformal -remove; synth -flatten -top ooe_wake; write_json $out/wake.json"; ungate $out/wake
line=$(yosys-abc -c "read_blif $out/wake.blif; read_library test/ooe/ngd.genlib; strash; dch; map; print_stats" 2>&1 | tail -1)
d=$(echo "$line" | sed -n 's/.*delay = *\([0-9.]*\).*/\1/p')
l=$(echo "$line" | sed -n 's/.*lev = *\([0-9]*\).*/\1/p')
printf '  %-10s %3s timers, 4 lines:     %5s NGD in %s levels (budget 25)\n' wake "$n" "$d" "$l"
# ooe_confirm over both classes: one cancel hop and one level of
# confirmation a cycle, each a row-wide OR over the dependency matrix. No
# estimate in OA-1; it must fit a stage.
yosys -q -p "read_verilog -sv -formal -Irtl/include -Irtl/generated rtl/ccv_assert_pkg.sv rtl/ooe/ooe_confirm.sv;
             chparam -set N $n ooe_confirm;
             chformal -remove; synth -flatten -top ooe_confirm; write_json $out/confirm.json"; ungate $out/confirm
line=$(yosys-abc -c "read_blif $out/confirm.blif; read_library test/ooe/ngd.genlib; strash; dch; map; print_stats" 2>&1 | tail -1)
d=$(echo "$line" | sed -n 's/.*delay = *\([0-9.]*\).*/\1/p')
l=$(echo "$line" | sed -n 's/.*lev = *\([0-9]*\).*/\1/p')
printf '  %-10s %3s entries:              %5s NGD in %s levels (budget 25)\n' confirm "$n" "$d" "$l"
# ooe_rs over both classes, its allocation and matrix write; and the path
# that decides its same-edge reuse (DA's response OI-39): ooe_confirm's
# confirmations as its frees, from flops through allocation into the row
# write (test/ooe/ooe_rs_confirm.sv, a probe, not a block). Each holds the
# 45 x 45 matrix: several minutes of synthesis apiece.
for cfg in "rs rtl/ooe/ooe_rs.sv ooe_rs" "rs_confirm rtl/ooe/ooe_confirm.sv rtl/ooe/ooe_rs.sv test/ooe/ooe_rs_confirm.sv ooe_rs_confirm"; do
  set -- $cfg
  name=$1; shift
  top=${!#}
  files=${*%$top}
  yosys -q -p "read_verilog -sv -formal -Irtl/include -Irtl/generated rtl/ccv_assert_pkg.sv $files;
               chparam -set N $n -set NR $n_rcu -set A $width $top; hierarchy -top $top; flatten; chformal -remove;
               synth -flatten -top $top; attrmap -remove init; write_json $out/$name.json"; ungate $out/$name
  line=$(yosys-abc -c "read_blif $out/$name.blif; read_library test/ooe/ngd.genlib; strash; dch; map; print_stats" 2>&1 | tail -1)
  d=$(echo "$line" | sed -n 's/.*delay = *\([0-9.]*\).*/\1/p')
  l=$(echo "$line" | sed -n 's/.*lev = *\([0-9]*\).*/\1/p')
  printf '  %-10s %3s entries, %s ports a class: %5s NGD in %s levels (budget 25)\n' "$name" "$n" "$width" "$d" "$l"
done
# ooe_rat with Rename 1's read of it (ooe_ratread, OA's response OI-46):
# rename's reads, each a slot's map with the lower ports' writes over it,
# then a 16:1 read, and the maps' and checkpoints' next values. Rename's
# first stage (the design doc's Scheduler timing estimate) is this and the
# free-list grant, read from the candidate buffer's head.
read -r rat_g _ < <(python3 test/ooe/rat-params.py)
rat_set=$(echo "$rat_g" | tr ',' '\n' | sed -n 's/^-G\([A-Z]*\)=\(.*\)$/-set \1 \2/p' | tr '\n' ' ')
rat_src="rtl/ccv_assert_pkg.sv rtl/ooe/ooe_rat.sv rtl/ooe/ooe_ratread.sv test/ooe/ooe_rat_read.sv"
yosys -q -p "read_verilog -sv -formal -Irtl/include -Irtl/generated $rat_src;
             chparam $rat_set ooe_rat_read; hierarchy -top ooe_rat_read;
             chformal -remove; synth -flatten -top ooe_rat_read; write_json $out/rat.json"; ungate $out/rat
line=$(yosys-abc -c "read_blif $out/rat.blif; read_library test/ooe/ngd.genlib; strash; dch; map; print_stats" 2>&1 | tail -1)
d=$(echo "$line" | sed -n 's/.*delay = *\([0-9.]*\).*/\1/p')
l=$(echo "$line" | sed -n 's/.*lev = *\([0-9]*\).*/\1/p')
printf '  %-10s %3s slots, %s ports:       %5s NGD in %s levels (budget 25)\n' rat 4 4 "$d" "$l"
# ooe_select over both classes: the requests (warp state, confirmation,
# the memop order check as a row-wide OR over the age matrix, the copy)
# and the two picks. OA-1's select stage is 17.6 NGD with a 3.0 flop, so
# 14.6 of logic, with ready taken from a flop.
yosys -q -p "read_verilog -sv rtl/ooe/ooe_pick.sv rtl/ooe/ooe_select.sv;
             chparam -set N $n -set NR $n_rcu -set S $slots ooe_select; synth -flatten -top ooe_select;
             write_blif $out/select.blif"
line=$(yosys-abc -c "read_blif $out/select.blif; read_library test/ooe/ngd.genlib; strash; dch; map; print_stats" 2>&1 | tail -1)
d=$(echo "$line" | sed -n 's/.*delay = *\([0-9.]*\).*/\1/p')
l=$(echo "$line" | sed -n 's/.*lev = *\([0-9]*\).*/\1/p')
printf '  %-10s %3s entries, 9 resources:  %5s NGD in %s levels (estimate 14.6 of logic)\n' select "$n" "$d" "$l"
