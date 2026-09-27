#!/usr/bin/env bash
# The ctech layer and the block clock gate built on it (docs/clock-gate.md).
#
# A ctech cell is one module, ccv_ctech_<cell>, with a definition per view:
# rtl/ctech/sim/ for simulation and formal, rtl/ctech/<library>/ per process
# library, chosen by the file list (tools/ccv_ctech.py). What must hold:
#
#   views agree       every view defines the same cells with the same ports,
#                     and a library view's lib_cells.v matches the vendor's
#                     own cell model where one is vendored (sky130)
#   synthesis         ccv_clk_gate with each library view is ONE library ICG,
#                     driving gclk straight, and no latch; the simulation
#                     view is refused by name
#   simulation        test/ctech/tb_ctech_icg.sv -- enable moving in either
#                     phase, 2000 cycles -- no runt pulse and the right edges,
#                     on Icarus and Verilator; the sky130 view through the
#                     vendor's cell model; the simulation view beside that
#                     model, sample for sample
#   mutants           the simulation view with no latch, and with its latch
#                     open on the high phase: the testbench must fail both
#
# The gate's own behaviour -- hysteresis, wake within a cycle, the Q-33 hold
# -- is proved in tools/check-formal.sh, on this same simulation view.
set -uo pipefail
cd "$(dirname "$0")/.."
R=$(pwd)
B="$R/build/ctech"
rm -rf "$B" && mkdir -p "$B"
fail=0
say() { printf '  %-46s %s\n' "$1" "$2"; }
bad() { say "$1" "FAIL -- $2"; fail=1; }

VIEWS=$(python3 tools/ccv_ctech.py --views)
LIBS=$(echo "$VIEWS" | grep -vx sim)
VENDOR=test/ctech/vendor/sky130_fd_sc_hd
TB=test/ctech/tb_ctech_icg.sv

if ! command -v yosys >/dev/null 2>&1; then
  say "ctech" "SKIP -- yosys not installed"
  exit 0
fi

# -- the views agree ----------------------------------------------------------
# Ports as Yosys elaborates them: name, direction, width, per ccv_ctech_ cell.
ports_of() {  # VIEW -> "cell port dir width" lines
  local v=$1 lib=""
  [ -f "rtl/ctech/$v/lib_cells.v" ] && lib="read_verilog -lib rtl/ctech/$v/lib_cells.v;"
  yosys -q -p "$lib read_verilog -sv $(python3 tools/ccv_ctech.py "$v" --synth | tr '\n' ' ');
               write_json $B/ports_$v.json" >"$B/ports_$v.log" 2>&1 || { echo ERROR; return; }
  python3 - "$B/ports_$v.json" <<'PY'
import json, sys
m = json.load(open(sys.argv[1]))["modules"]
for n in sorted(m):
    if n.startswith("ccv_ctech_"):
        for p, v in sorted(m[n]["ports"].items()):
            print(n, p, v["direction"], len(v["bits"]))
PY
}
ports_of sim >"$B/ports_sim.txt"
agree=1
for v in $LIBS; do
  ports_of "$v" >"$B/ports_$v.txt"
  if ! diff -q "$B/ports_sim.txt" "$B/ports_$v.txt" >/dev/null; then
    agree=0
    bad "view $v: same cells and ports as sim" "$(diff "$B/ports_sim.txt" "$B/ports_$v.txt" | head -3 | tr '\n' ' ')"
  fi
done
ncell=$(cut -d' ' -f1 "$B/ports_sim.txt" | sort -u | wc -l)
[ $agree = 1 ] && [ -s "$B/ports_sim.txt" ] && ! grep -q ERROR "$B/ports_sim.txt" &&
  say "$(echo $VIEWS | wc -w) views, $ncell cell(s), identical ports" "PASS ($(echo $VIEWS | tr '\n' ' '))"

# sky130: lib_cells.v declares what the vendor's model has.
cellports() {  # FILE MODULE -> sorted "port dir"; ports only (-lib), since
               # Yosys does not read the vendor's UDP latch
  yosys -q -p "read_verilog -lib $1; write_json $B/cp.json" >/dev/null 2>&1 &&
  python3 -c "
import json; m=json.load(open('$B/cp.json'))['modules']['$2']
print(' '.join(sorted('%s:%s' % (p, v['direction']) for p, v in m['ports'].items())))"
}
a=$(cellports rtl/ctech/sky130_fd_sc_hd/lib_cells.v sky130_fd_sc_hd__sdlclkp_1)
b=$(cellports "$VENDOR/sky130_fd_sc_hd__sdlclkp_1.v" sky130_fd_sc_hd__sdlclkp_1)
[ -n "$a" ] && [ "$a" = "$b" ] &&
  say "sky130 lib_cells.v == the vendor cell's ports" "PASS ($a)" ||
  bad "sky130 lib_cells.v vs the vendor cell" "{$a} vs {$b}"

# -- synthesis: the library's ICG, and only it -------------------------------
# Assertions are stripped (chformal -remove), as synthesis ignores them.
synth_gate() {  # VIEW
  local v=$1 lib=""
  [ -f "rtl/ctech/$v/lib_cells.v" ] && lib="read_verilog -lib rtl/ctech/$v/lib_cells.v;"
  yosys -q -p "read_verilog -sv -formal -DSYNTHESIS -Irtl/include -Irtl/generated \
                 rtl/ccv_assert_pkg.sv $(python3 tools/ccv_ctech.py "$v" --synth | tr '\n' ' ') \
                 rtl/clk/ccv_clk_gate.sv; $lib
               hierarchy -check -top ccv_clk_gate; chformal -remove;
               synth -top ccv_clk_gate -flatten; write_json $B/cg_$v.json" >"$B/synth_$v.log" 2>&1
}
for v in $LIBS; do
  if ! synth_gate "$v"; then
    bad "synthesis with $v" "$(grep -m1 -i error "$B/synth_$v.log")"
    continue
  fi
  verdict=$(python3 - "$B/cg_$v.json" <<'PY'
import json, sys
m = json.load(open(sys.argv[1]))["modules"]["ccv_clk_gate"]
cells = m["cells"]
lib = [(n, c) for n, c in cells.items() if not c["type"].startswith("$")]
latch = [n for n, c in cells.items() if "LATCH" in c["type"].upper()]
if len(lib) != 1:
    print("want exactly one library cell, got %s" % sorted(c["type"] for _, c in lib)); sys.exit()
if latch:
    print("latch(es) in the netlist: %s" % latch); sys.exit()
n, c = lib[0]
outs = [p for p, d in c["port_directions"].items() if d == "output"]
if len(outs) != 1 or c["connections"][outs[0]] != m["ports"]["gclk"]["bits"]:
    print("gclk is not the cell's output, straight"); sys.exit()
ins = {p: c["connections"][p] for p, d in c["port_directions"].items() if d == "input"}
clkbits = m["ports"]["clk"]["bits"]
if clkbits not in ins.values():
    print("the cell's clock pin is not the gate's clk, straight"); sys.exit()
print("ok %s" % c["type"])
PY
)
  case "$verdict" in
    ok*) say "synthesis, $v: one ${verdict#ok }" "PASS (no latch; clk and gclk straight)" ;;
    *)   bad "synthesis, $v" "$verdict" ;;
  esac
done
if synth_gate sim; then
  bad "synthesis refuses the simulation view" "it synthesised"
elif grep -q ccv_ctech_sim_view_in_synthesis "$B/synth_sim.log"; then
  say "  ...and refuses the simulation view, by name" "PASS"
else
  bad "synthesis refuses the simulation view" "$(grep -m1 -i error "$B/synth_sim.log")"
fi

# -- simulation: no runt, the right edges, and the vendor's cell -------------
icarus() {  # NAME "FILES" [DEFINES]
  iverilog -g2012 ${3:-} -o "$B/$1.vvp" -s tb $2 $TB >"$B/$1.ib.log" 2>&1 &&
    vvp -n "$B/$1.vvp" >"$B/$1.log" 2>&1
  grep -h "ICG_OK\|ICG_FAIL\|ICG_ERR" "$B/$1.log" "$B/$1.ib.log" 2>/dev/null | head -1
}
verilate() {  # NAME "FILES"
  verilator --binary -j 0 --timing -Wno-fatal -Wno-TIMESCALEMOD --top-module tb \
    --Mdir "$B/$1_vo" $2 $TB >"$B/$1.vb.log" 2>&1 &&
    "$B/$1_vo/Vtb" >"$B/$1.log" 2>&1
  grep -h "ICG_OK\|ICG_FAIL\|ICG_ERR" "$B/$1.log" 2>/dev/null | head -1
}
SIMV=rtl/ctech/sim/ccv_ctech_icg.sv
VFILES="$VENDOR/sky130_fd_sc_hd__sdlclkp_1.v $VENDOR/sky130_fd_sc_hd__sdlclkp.functional.v $VENDOR/sky130_fd_sc_hd__udp_dlatch_p.v"
if command -v iverilog >/dev/null 2>&1; then
  r=$(icarus sim_iv "$SIMV")
  [[ "$r" == ICG_OK* ]] && say "icarus: sim view, enable in either phase" "PASS (${r#ICG_OK })" ||
    bad "icarus: sim view" "${r:-no result ($B/sim_iv.ib.log)}"
  r=$(icarus sky130_iv "rtl/ctech/sky130_fd_sc_hd/ccv_ctech_icg.sv $VFILES")
  [[ "$r" == ICG_OK* ]] && say "icarus: sky130 view through the vendor cell" "PASS" ||
    bad "icarus: sky130 view" "${r:-no result}"
  r=$(icarus ref_iv "$SIMV $VFILES" -DVENDOR_REF)
  [[ "$r" == ICG_OK* ]] && say "icarus: sim view == sky130 cell, every sample" "PASS (${r##*ref_samples=} samples)" ||
    bad "icarus: sim view vs the sky130 cell" "${r:-no result}"
fi
if command -v verilator >/dev/null 2>&1; then
  if verilator --lint-only -Wall -Wno-DECLFILENAME --top-module ccv_ctech_icg $SIMV \
       >"$B/lint.log" 2>&1; then
    say "verilator -Wall: sim view" "PASS"
  else
    bad "verilator -Wall: sim view" "$(grep -m1 '%' "$B/lint.log")"
  fi
  r=$(verilate sim_v "$SIMV")
  [[ "$r" == ICG_OK* ]] && say "verilator: sim view, enable in either phase" "PASS (${r#ICG_OK })" ||
    bad "verilator: sim view" "${r:-no result ($B/sim_v.vb.log)}"
fi

# -- mutants: the testbench must catch an ICG that is not one ----------------
mkdir -p "$B/mut"
awk '/always_latch begin/{print "  assign en_l = en | te;"; skip=2; next} skip>0{skip--; next} {print}' \
  $SIMV >"$B/mut/no_latch.sv"
sed 's/    if (!clk) en_l = en | te;/    if (clk) en_l = en | te;/' $SIMV >"$B/mut/high_latch.sv"
for m in no_latch high_latch; do
  if cmp -s $SIMV "$B/mut/$m.sv"; then bad "ctech mutant $m" "did not apply"; continue; fi
  why=""
  if command -v iverilog >/dev/null 2>&1; then
    r=$(icarus "m_${m}_iv" "$B/mut/$m.sv")
    [[ "$r" == ICG_FAIL* || "$r" == ICG_ERR* ]] || why="icarus: ${r:-no result}"
  fi
  if [ -z "$why" ] && command -v verilator >/dev/null 2>&1; then
    r=$(verilate "m_${m}_v" "$B/mut/$m.sv")
    [[ "$r" == ICG_FAIL* || "$r" == ICG_ERR* ]] || why="verilator: ${r:-no result}"
  fi
  case $m in no_latch) what="an ICG with no latch" ;; *) what="a latch open on the high phase" ;; esac
  [ -z "$why" ] && say "  ...$what: caught" "PASS (both simulators)" ||
    bad "ctech mutant $m not caught" "$why"
done

exit $fail
