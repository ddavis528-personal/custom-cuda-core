#!/bin/bash
# Archived (OA-24 (a), OA rev 312): the ROB split's miter, run by hand only.
# run.sh NAME "DEFINES" "CHPARAMS"   e.g.  run.sh d8 "" "-set D 8 -set PCW 16"
#                                          run.sh d8mut FV_MUT_WID "-set D 8 -set PCW 16"
# Builds build/fv-rob/NAME/m.aig (Yosys, about 5.4 GB and 15 minutes at D 8;
# full size passed 12.9 GB and was stopped), then BMC to 40 frames. Not for
# the gate: nothing in tools/ or test/ reads this directory.
set -uo pipefail
R=$(cd "$(dirname "$0")/../.." && pwd); A=$R/archive/ooe-rob-split
export PATH="$R/tools/shim:$PATH"
name=$1 defs=${2:-} chp=${3:-}
d=$R/build/fv-rob/$name; mkdir -p "$d"
df=""; for x in $defs; do df="$df -D$x"; done
rv="read_verilog -sv -formal $df -I$R/rtl/include -I$R/rtl/generated"
cat >"$d/m.ys" <<YS
$rv $R/rtl/ccv_assert_pkg.sv
$rv $A/ooe_rob_ref.sv
$rv $R/rtl/ooe/ooe_rob_w.sv
$rv $A/fv_rob_split.sv
${chp:+chparam $chp fv_rob_split}
prep -top fv_rob_split
hierarchy -smtcheck
chformal -assert -assert2assume *ooe_rob_ref*
chformal -assert -remove *ooe_rob_w*
chformal -cover -remove
flatten
chformal -assert -remove t:\$assert c:*miter_* %d
async2sync
setundef -zero
setundef -undriven -anyseq
setattr -unset keep
opt -full
techmap
opt -fast
memory_map -formal
setundef -zero -init
formalff -clk2ff
simplemap
dffunmap
aigmap
opt_clean
setundef -zero
write_aiger -I -B -zinit -no-startoffset -map $d/m.map $d/m.aig
YS
python3 "$A/maxrss.py" yosys -q "$d/m.ys" >"$d/yosys.log" 2>&1 || { echo "$name: yosys error"; tail -5 "$d/yosys.log"; exit 1; }
grep peak_rss "$d/yosys.log"
cd "$d" && python3 "$A/maxrss.py" yosys-abc -c "read_aiger m.aig; fold; strash; bmc3 -F ${BMC_F:-40} -v; print_status" >abc-bmc.log 2>&1
grep -E "asserted|No output|peak_rss" abc-bmc.log | tail -3
