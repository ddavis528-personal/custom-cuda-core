#!/usr/bin/env bash
# Physical-implementation primitives: the sequential repeater
# (rtl/phys/ccv_seq_rpt.sv, docs/physical.md).
#
#   clean                                        negative control
#   lint -Wall, every shape (0/1/3 stages,       --
#     lead or not, trace or not)
#   N = 0..4, Icarus and Verilator: checker      enable-now: the payload taken
#     quiet at sender, mid-link and receiver;      with valid, not after it --
#     every message, lead slice and trace id       data errors
#     intact; every signal exactly N cycles     lead-late: the lead taken a
#   rate = depth / (4 + 2N), exactly:              cycle late -- data errors
#     full loop (default), round trip, abutted  credit-short: credit skips a
#                                                  stage -- latency errors
#   the receiver-end checker told its distance  told it sits at the sender:
#     from the sender (SRC_STAGES = N) is quiet    stall_honoured fires
#   payload enabled by the previous cycle's     free-run: payload loads every
#     valid, lead by the same cycle's, pulses      cycle. Simulation CANNOT see
#     reset and never enabled -- on the Yosys      it (clean run, asserted);
#     netlist                                      the netlist check refuses it
set -uo pipefail
cd "$(dirname "$0")/.."
B=build/phys
mkdir -p "$B/mut"
fail=0
say() { printf '  %-46s %s\n' "$1" "$2"; }
bad() { say "$1" "FAIL -- $2"; fail=1; }
field() { tr ' ' '\n' <<<"$1" | sed -n "s/^$2=//p" | head -1; }

RPT=rtl/phys/ccv_seq_rpt.sv
SRC="rtl/ccv_assert_pkg.sv rtl/if/ccv_credit_checker.sv"
TB=test/phys/tb_seq_rpt.sv
INC="-Irtl/include -Irtl/generated"

# -- lint --------------------------------------------------------------------
if command -v verilator >/dev/null 2>&1; then
  lf=""
  for G in "-GSTAGES=0" "-GSTAGES=1 -GPAYLOAD_W=8" "-GSTAGES=3 -GPAYLOAD_W=20 -GLEAD_MASK=20'hf"; do
    for D in "" "-DCCV_TRACE"; do
      verilator --lint-only --assert -Wall -Wno-DECLFILENAME $D $INC \
        --top-module ccv_seq_rpt $G rtl/ccv_assert_pkg.sv $RPT >"$B/lint.log" 2>&1 ||
        lf="$lf [$G $D]"
    done
  done
  [ -z "$lf" ] && say "repeater: verilator -Wall, six shapes" "PASS" ||
    bad "repeater: verilator -Wall" "$lf: $(grep -m1 '^%' "$B/lint.log")"
fi

# One run: $1 simulator (iv|vl), $2 N, $3 rpt source, $4 extra defines, then
# plusargs. Prints the RPT line and any checker failure.
build() {   # $1 sim, $2 N, $3 rpt file, $4 defines, $5 tag
  local out="$B/$1_$5_n$2"
  if [ "$1" = iv ]; then
    iverilog -g2012 -gassertions -DCCV_TRACE -DRPT_N="$2" $4 $INC \
      -o "$out.vvp" -s tb $SRC "$3" $TB >"$out.log" 2>&1 && echo "vvp -n $out.vvp"
  else
    # The checker's trace hook is DPI-C: link the event library it calls.
    verilator --binary -j 0 --assert --timing -Wno-fatal -Wno-TIMESCALEMOD \
      -DCCV_TRACE -DRPT_N="$2" $4 $INC --top-module tb --Mdir "$out.vo" \
      -CFLAGS "-I$PWD/sim/include -I$PWD/sim/generated" \
      -o sim $SRC "$3" $TB "$PWD/sim/src/event.cpp" "$PWD/sim/dpi/ccv_event_dpi.cpp" \
      >"$out.log" 2>&1 && echo "$out.vo/sim"
  fi
}
# The RPT line and each checker failure with its scope (Icarus prints the
# scope on the line after the failure, Verilator on the same one).
run() { local cmd=$1; shift; $cmd "$@" 2>&1 | grep -E '^RPT |CCV .* failed|Scope:' ; }

# -- N = 0..4, both simulators ---------------------------------------------
for sim in iv vl; do
  [ $sim = iv ] && ! command -v iverilog >/dev/null 2>&1 && continue
  [ $sim = vl ] && ! command -v verilator >/dev/null 2>&1 && continue
  why=""
  for n in 0 1 2 3 4; do
    cmd=$(build $sim $n $RPT "" clean) || { why="$why N=$n: build failed"; continue; }
    out=$(run "$cmd")
    grep -q "failed" <<<"$out" && why="$why N=$n: $(grep -m1 failed <<<"$out")"
    for k in data_errors latency_errors overflow; do
      [ "$(field "$out" $k)" = "0" ] || why="$why N=$n: $k=$(field "$out" $k)"
    done
    s=$(field "$out" sent); r=$(field "$out" received)
    [ -n "$s" ] && [ $((s - r)) -le $((2 + 2 * n)) ] && [ "$r" -gt 500 ] ||
      why="$why N=$n: sent=$s received=$r"
    # The rate, exactly as the loop predicts, for three credit depths.
    # Full bandwidth at the credit-loop depth (Q-43); the two depths it
    # replaced, measured to the formula, so the table in physical.md stands.
    for mode in "full:1000" "full rtdepth:$(( (2 + 2*n) * 1000 / (4 + 2*n) ))" \
                "full shallow:$(( 2000 / (4 + 2*n) ))"; do
      args=$(sed 's/\([a-z]*\)/+\1/g' <<<"${mode%%:*}")
      want=${mode##*:}
      o=$(run "$cmd" $args)
      got=$(field "$o" rate_x1000)
      [ -n "$got" ] && [ $((got - want)) -le 2 ] && [ $((want - got)) -le 2 ] &&
        ! grep -q failed <<<"$o" ||
        why="$why N=$n ${mode%%:*}: rate $got, want $want"
    done
  done
  name=$([ $sim = iv ] && echo icarus || echo verilator)
  if [ -z "$why" ]; then
    say "$name: N=0..4 intact, exact latency and rate" "PASS"
  else
    bad "$name: repeated link" "${why# }"
  fi
done

# -- the checker's position along the link ------------------------------------
if command -v iverilog >/dev/null 2>&1; then
  cmd=$(build iv 2 $RPT "-DRPT_WRONG_SKID" skid)
  o=$(run "$cmd")
  if grep -q "u_chk_dst.g_stall_honoured" <<<"$o" &&
     ! grep -qE "u_chk_(src|mid)" <<<"$o"; then
    say "  ...receiver-end checker as if at the sender" "PASS (stall_honoured, there only)"
  else
    bad "receiver-end checker needs SRC_STAGES" \
        "want stall_honoured at u_chk_dst alone; got: $(grep -m2 Scope <<<"$o" | xargs)"
  fi
fi

# -- the enables, on the netlist ---------------------------------------------
if command -v yosys >/dev/null 2>&1; then
  if out=$(python3 tools/check-rpt-enables.py 2>&1); then
    say "enables on the netlist: payload, lead, pulses" "PASS (5 shapes)"
  else
    bad "repeater enables on the netlist" "$(echo "$out" | grep -m1 '^  ')"
  fi
fi

# -- mutants ------------------------------------------------------------------
mut() {   # $1 name, $2 sed expression
  sed "$2" $RPT >"$B/mut/$1.sv"
  cmp -s $RPT "$B/mut/$1.sv" && { bad "mutant $1" "did not apply"; return 1; }
}
mut enable-now 's/        if (valid_q\[j\]) pay_q <= /        if (v[k*S+j]) pay_q <= /'
mut lead-late  's/          if (v\[k\*S+j\]) lead_q <= /          if (valid_q[j]) lead_q <= /'
mut credit-short 's/    assign cr\[k\*S +: S\]    = credit_q;/    assign cr[k*S +: S]    = cr[(k+1)*S +: S];/'
mut free-run   's/        if (valid_q\[j\]) pay_q <= /        pay_q <= /'
if command -v iverilog >/dev/null 2>&1; then
  caught=""
  for spec in enable-now:data_errors lead-late:data_errors credit-short:latency_errors; do
    m=${spec%%:*}; k=${spec##*:}
    cmd=$(build iv 2 "$B/mut/$m.sv" "" "$m")
    v=$(field "$(run "$cmd")" "$k")
    [ -n "$v" ] && [ "$v" != "0" ] && caught="$caught $m" ||
      bad "mutant $m" "$k=$v: not caught in simulation"
  done
  [ "$caught" = " enable-now lead-late credit-short" ] &&
    say "  ...enable-now, lead-late, credit-short caught" "PASS"
  # free-run is functionally identical: the run must be CLEAN, which is why
  # the netlist check exists.
  cmd=$(build iv 2 "$B/mut/free-run.sv" "" free-run)
  o=$(run "$cmd")
  if [ "$(field "$o" data_errors)" = "0" ] && ! grep -q failed <<<"$o" &&
     ! python3 tools/check-rpt-enables.py --file="$B/mut/free-run.sv" >/dev/null 2>&1; then
    say "  ...free-run: invisible in sim, refused by netlist" "PASS"
  else
    bad "mutant free-run" "want a clean simulation and a refused netlist"
  fi
  if ! python3 tools/check-rpt-enables.py --file="$B/mut/lead-late.sv" >/dev/null 2>&1; then
    say "  ...lead-late also refused by the netlist check" "PASS"
  else
    bad "mutant lead-late" "the netlist check passed it"
  fi
fi

exit $fail
