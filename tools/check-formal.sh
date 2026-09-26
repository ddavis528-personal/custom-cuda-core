#!/usr/bin/env bash
# Formal PROOFS of the channel protocol, in the gate (test/formal/fv_link.sv).
#
# Until this, formal in the regression meant cover runs on the checkers --
# a vacuity guard, proving nothing about any design. This proves, for ALL
# time, not a bounded window: unbounded model checking by PDR (ABC), on one
# credited link -- a protocol-following sender and receiver, N sequential
# repeater stages (rtl/phys/ccv_seq_rpt.sv), the credit checker at both ends.
#
#   proved                                     must fail (counterexample)
#   safety, N = 0, 1, 2, any traffic: data     a receiver consuming two for
#     in order, no overflow, one credit per      one credit (the S0 bug):
#     message, conservation, and every           credit_per_msg, conservation
#     credit-checker property at both ends     the repeater's enable-now and
#                                                lead-late mutants:
#                                                data_in_order
#   full_bandwidth, N = 0, 1, 2: a launch      the same at a credit depth one
#     every cycle at the credit-loop depth       short of the loop (Q-43)
#     (Q-43)
#   non-vacuity: messages flow and the         (reach_* are asserted false:
#     buffer fills, under the safety proofs'     their counterexamples ARE
#     (absent) assumptions                       the witnesses)
#   bounded response, under a receiver that
#     drains (FV_FAIR) -- the ONE property that
#     needs an assumption, proved on its own
#
# SBY 0.69's ABC integration crashes on Yosys 0.33's witness files, even on a
# trivially true property, so the model is built the way SBY builds it and
# yosys-abc runs PDR directly. PDR reports only THAT the miter fired, so a
# control keeps just the assertion it targets (chformal), and the verdict is
# about that property by name.
set -uo pipefail
cd "$(dirname "$0")/.."
R=$(pwd)
B="$R/build/formal"
fail=0
say() { printf '  %-46s %s\n' "$1" "$2"; }
bad() { say "$1" "FAIL -- $2"; fail=1; }

if ! command -v yosys >/dev/null 2>&1 || ! command -v yosys-abc >/dev/null 2>&1; then
  say "formal proofs" "SKIP -- needs yosys and yosys-abc"
  exit 0
fi
rm -rf "$B" && mkdir -p "$B"
LOOP=$(sed -n 's/.*localparam int CCV_CREDIT_DEPTH = \([0-9]*\);/\1/p' rtl/generated/ccv_params_pkg.sv)

# prove NAME N DEPTH "DEFINES" TARGET [RPT_FILE]
#   TARGET "all" keeps every assertion, "-PAT" every one but those ending in
#   PAT, "PAT" only those. Prints "proved", "cex <frame>", or "error".
prove() {
  local name=$1 n=$2 depth=$3 defs=$4 target=$5 rpt=${6:-$R/rtl/phys/ccv_seq_rpt.sv}
  local d="$B/$name"
  mkdir -p "$d"
  local keep=""
  case "$target" in
    all) ;;
    -*)  keep="chformal -assert -remove t:\$assert c:*${target#-} %i" ;;
    *)   keep="chformal -assert -remove t:\$assert c:*$target %d" ;;
  esac
  local dflags=""
  for x in $defs; do dflags="$dflags -D$x"; done
  cat >"$d/m.ys" <<YS
read_verilog -sv -formal $dflags -I$R/rtl/include -I$R/rtl/generated $R/rtl/ccv_assert_pkg.sv
read_verilog -sv -formal $dflags -I$R/rtl/include -I$R/rtl/generated $R/rtl/if/ccv_credit_checker.sv
read_verilog -sv -formal $dflags -I$R/rtl/include -I$R/rtl/generated $rpt
read_verilog -sv -formal $dflags -I$R/rtl/include -I$R/rtl/generated $R/test/formal/fv_link.sv
chparam -set N $n -set DEPTH $depth fv_link
prep -top fv_link
hierarchy -smtcheck
flatten
$keep
chformal -cover -remove
async2sync
formalff -assume
setundef -undriven -anyseq
setattr -unset keep
opt -full
techmap
opt -fast
memory_map -formal
formalff -clk2ff -ff2anyinit
simplemap
dffunmap
aigmap
opt_clean
select -assert-min 1 t:\$_AND_ t:\$_NOT_
write_aiger -I -B -zinit -no-startoffset $d/m.aig
YS
  if ! yosys -q "$d/m.ys" >"$d/yosys.log" 2>&1; then echo error; return; fi
  timeout 900 yosys-abc -c "read_aiger $d/m.aig; fold; strash; pdr" >"$d/abc.log" 2>&1
  if grep -q "Property proved" "$d/abc.log"; then echo proved
  elif f=$(grep -oE "asserted in frame [0-9]+" "$d/abc.log"); then echo "cex ${f##* }"
  else echo error; fi
}

# -- safety: every property, any traffic, no assumption --------------------------
# All but response_within_n, which is a promise about the RECEIVER: it holds
# only for one that drains, and is proved next under that assumption. Proved
# here with no assumption at all, so the full buffer is among the states.
for n in 0 1 2; do
  depth=$((LOOP + 2 * n))
  r=$(prove "safety_n$n" $n $depth "" -response_within_n)
  [ "$r" = proved ] && say "safety, N=$n: every property, for all time" "PASS (proved)" ||
    bad "safety, N=$n" "$r ($B/safety_n$n/abc.log)"
  # Bounded response at N = 0 and 1: the checker's per-message age counters
  # make it the costly proof (~40 s and ~3.5 min; N = 2 does not converge in
  # 15), and N adds only a fixed latency the two cases already cover.
  if [ $n -lt 2 ]; then
    r=$(prove "response_n$n" $n $depth "FV_FAIR" response_within_n)
    [ "$r" = proved ] && say "  ...bounded response, receiver draining" "PASS (proved)" ||
      bad "bounded response, N=$n" "$r ($B/response_n$n/abc.log)"
  fi
done

# -- full bandwidth at the credit-loop depth, and not one short -----------------
for n in 0 1 2; do
  depth=$((LOOP + 2 * n))
  r=$(prove "bw_n$n" $n $depth "FV_GREEDY" full_bandwidth)
  r2=$(prove "bw_short_n$n" $n $((depth - 1)) "FV_GREEDY" full_bandwidth)
  if [ "$r" = proved ] && [ "${r2%% *}" = cex ]; then
    say "full bandwidth, N=$n, depth $depth" "PASS (proved; depth $((depth - 1)): cex)"
  else
    bad "full bandwidth, N=$n" "depth $depth: $r; depth $((depth - 1)): $r2"
  fi
done

# -- the properties can fail: mutants ---------------------------------------
for spec in "double_pop:FV_MUT_DOUBLE_POP:credit_per_msg" \
            "double_pop_cons:FV_MUT_DOUBLE_POP:conservation"; do
  IFS=: read -r nm def tgt <<<"$spec"
  r=$(prove "mut_$nm" 1 $((LOOP + 2)) "$def" "$tgt")
  [ "${r%% *}" = cex ] && say "  ...two consumed, one credit: $tgt fails" "PASS ($r)" ||
    bad "mutant double-pop vs $tgt" "$r: not refuted"
done
mkdir -p "$B/rpt"
sed 's/        if (valid_q\[j\]) pay_q <= /        if (v[k*S+j]) pay_q <= /' \
  rtl/phys/ccv_seq_rpt.sv >"$B/rpt/enable_now.sv"
sed 's/          if (v\[k\*S+j\]) lead_q <= /          if (valid_q[j]) lead_q <= /' \
  rtl/phys/ccv_seq_rpt.sv >"$B/rpt/lead_late.sv"
for m in enable_now lead_late; do
  if cmp -s rtl/phys/ccv_seq_rpt.sv "$B/rpt/$m.sv"; then bad "repeater mutant $m" "did not apply"; continue; fi
  r=$(prove "mut_$m" 1 $((LOOP + 2)) "" data_in_order "$B/rpt/$m.sv")
  [ "${r%% *}" = cex ] && say "  ...repeater $m: data_in_order fails" "PASS ($r)" ||
    bad "repeater mutant $m" "$r: not refuted"
done

# -- non-vacuity: the proofs are about traffic that happens ------------------
for tgt in reach_three reach_full; do
  r=$(prove "$tgt" 1 $((LOOP + 2)) "FV_REACH" "$tgt")
  [ "${r%% *}" = cex ] && say "  ...witness: $tgt" "PASS (${r#cex } frames)" ||
    bad "non-vacuity $tgt" "$r: unreachable -- the assumptions may be too strong"
done

exit $fail
