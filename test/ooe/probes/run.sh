#!/usr/bin/env bash
# Logic-depth probes behind OA-21 (the go: one warp, two warps or the
# interleave; the take registered in decq and popped late; shared credits).
# Each probe is a combinational module over registered inputs, synthesised
# and mapped as test/ooe/depth.sh does; the figure is ABC's longest path in
# NGD. Not part of the gate: the evidence for a decision, kept so it can be
# re-run. Usage: test/ooe/probes/run.sh
#
#   go_probe     the go over registered per-slot fits: take counts (TWO 0: one
#                pick, the first warp; 1: two picks)
#   steer_probe  the go, then the steer into rename's stage register: lane j
#                takes the first warp's uop j, else the second's uop j - f1
#   il_probe     the interleave: take counts (OUT 0) and the 16:1 steer per
#                port (OUT 1)
#   ovr_probe    the in-group override from rename's registered group, without
#                (WARP 0) and with (WARP 1) the warp compare the interleave needs
#   ex2_probe    two picks with exact shared credits: take counts
#   exi_probe    the interleave with exact shared credits: take counts
#   ild_probe    OA-22: the interleave with this cycle's frees compared in front
#                (OA's deficit form): take counts (OUT 0), lanes (OUT 1)
#   ilsr_probe   OA-22: the split go, frees only on the short cycle's one-warp
#                path (map -r for per-input figures: tools ignore arrivals)
#   ilfin_probe  OA-22: the split go with the short path from registered
#                state, the short bit from the frees: per-input, map -r
#   fth_probe    free_th's arrival: ooe_confirm into a counted thermometer;
#   fth2_probe   the same through th_sat, a tree of capped thermometers
#                (th_only.sv), cap 4 and 2; ret_probe, ret_n's arrival
#
# decq-take-late.patch is ooe_decq with rename's take registered (tk_q) and
# popped at the next edge, its heads read at the take's offset into an
# output register from kept copies of the state. Apply it to
# rtl/ooe/ooe_decq.sv and run tools/check-ngd.py --unit ooe_decq: in-flop
# reads 22.6, ABC's area recovery relaxing the arrival cone to the head
# read's 22.6 (OI-64); the same netlist mapped with map -r puts the
# arrival at 18.6.
set -euo pipefail
cd "$(dirname "$0")/../../.."
export PATH="$PWD/tools/shim:$PATH"
out=build/ooe-rtl/probes
mkdir -p "$out"
# file, module, chparam arguments, label
while read -r f m p label; do
  [ -n "$f" ] || continue
  [ "$p" = "-" ] && p=""
  yosys -q -p "read_verilog -sv test/ooe/probes/$f; ${p:+chparam ${p//,/ } $m;} synth -flatten -top $m;
               abc -g AND,NAND,OR,NOR,XOR,XNOR,MUX; opt_clean; write_blif $out/$label.blif" 2>&1 |
    grep -v "Replacing memory" || true
  line=$(yosys-abc -c "read_blif $out/$label.blif; read_library test/ooe/ngd.genlib; strash; dch; map; print_stats" 2>&1 | tail -1)
  printf '  %-24s %5s NGD\n' "$label" "$(echo "$line" | sed -n 's/.*delay = *\([0-9.]*\).*/\1/p')"
done <<'T'
go_probe.sv    go_probe    -set,TWO,0   go-one-warp
go_probe.sv    go_probe    -set,TWO,1   go-two-warps
steer_probe.sv steer_probe -set,TWO,0   steer-one-warp
steer_probe.sv steer_probe -set,TWO,1   steer-two-warps
il_probe.sv    il_probe    -set,OUT,0   interleave-take
il_probe.sv    il_probe    -set,OUT,1   interleave-steer
ovr_probe.sv   ovr_probe   -set,WARP,0  override
ovr_probe.sv   ovr_probe   -set,WARP,1  override-warp
ex2_probe.sv   ex2_probe   -            exact-two-warps-take
exi_probe.sv   exi_probe   -            exact-interleave-take
ild_probe.sv   ild_probe   -set,OUT,0   deficit-front-take
ild_probe.sv   ild_probe   -set,OUT,1   deficit-front-lanes
T
