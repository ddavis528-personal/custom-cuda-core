#!/usr/bin/env bash
# params/links.json: the repeater split across hardening wrappers
# (docs/physical.md, "Wrappers and links").
#
# The design's own file repeats nothing yet, so everything else in the gate
# runs at STAGES 0. This is where a split is exercised, twice over:
#
#   1. Malformed configurations, each refused by tools/ccv_links.py with its
#      reason named -- a validator that accepts a bad file builds a machine
#      nobody specified.
#
#   2. test/phys/links_split.json -- every feature at once: a link split
#      between both ends, feedthroughs across MIU, SPM and a neighbouring
#      lane, the lockstep lane channels, both EXTERNAL links -- built into a
#      copy of the tree and put through what the real one gets:
#        - the top-level rule, top and wrappers, both views;
#        - the S0 suite: clean seeds, every credit home, every control;
#        - the wiring, traced flop by flop, equal to the C++ skeleton's,
#          stage counts included;
#        - every S1 kernel's final state equal to ccv-sim's;
#        - the SV-hosted run equal to the C++-hosted one, cycle for cycle,
#          kernels and controls: the SV repeaters in the wrappers and the C++
#          skeleton's link model are the same machine.
set -uo pipefail
cd "$(dirname "$0")/.."
R=$(pwd)
B="$R/build"
fail=0
say() { printf '  %-46s %s\n' "$1" "$2"; }
bad() { say "$1" "FAIL -- $2"; fail=1; }
field() { tr ' ' '\n' <"$1" | sed -n "s/^$2=//p" | head -1; }

# -- 1. the validator ---------------------------------------------------------
T=$(mktemp -d); trap 'rm -rf "$T"' EXIT
refused=0; missed=""
while IFS='|' read -r want json; do
  [ -z "$want" ] && continue
  printf '{"links": [%s]}\n' "$json" >"$T/bad.json"
  if out=$(CCV_LINKS="$T/bad.json" python3 tools/gen-skel.py --check 2>&1); then
    missed="$missed [accepted: $json]"
  elif ! grep -q -- "$want" <<<"$out"; then
    missed="$missed [$want: $(grep -m1 -v problem <<<"$out" | xargs)]"
  else
    refused=$((refused + 1))
  fi
done <<'CASES'
no channel|{"channel": "nope", "route": "src:0 > dst:0"}
not 'wrapper:stages'|{"channel": "fet_dec_instr", "route": "src:1 > miu > dst:0"}
a route runs|{"channel": "fet_dec_instr", "route": "miu:1 > dst:0"}
EXTERNAL|{"channel": "exb_ext_out", "route": "src:0 > dst:2"}
its own end|{"channel": "fet_dec_instr", "route": "src:0 > dec:1 > dst:0"}
no wrapper|{"channel": "fet_dec_instr", "route": "src:0 > nope:1 > dst:0"}
more than 16|{"channel": "fet_dec_instr", "route": "src:17 > dst:0"}
unknown key|{"channel": "fet_dec_instr", "stage": 1, "route": "src:0 > dst:0"}
also set by|{"channel": "fet_dec_instr", "route": "src:1 > dst:0"}, {"channel": "fet_dec_instr", "route": "src:0 > dst:1"}
totals differ|{"channel": "rcu_lane_ops", "copies": [3], "route": "src:0 > dst:1"}
src stages differ|{"channel": "rcu_lane_ops", "route": "src:0 > dst:1"}, {"channel": "rcu_lane_ops", "copies": [3], "route": "src:1 > dst:0"}
CASES
if [ -z "$missed" ]; then
  say "links.json: malformed configurations refused" "PASS ($refused cases, each by name)"
else
  bad "links.json validator" "${missed# }"
fi

# -- 2. a busy split, end to end -------------------------------------------------
if ! command -v verilator >/dev/null 2>&1 || ! command -v yosys >/dev/null 2>&1; then
  say "split configuration" "SKIP -- needs verilator and yosys"
  exit $fail
fi
if [ ! -f "$B/oracle/vadd/oracle.jsonl" ]; then
  bad "split configuration" "no oracles -- tools/check-kernel.sh first"
  exit 1
fi
S="$B/links_split"
rm -rf "$S" && mkdir -p "$S/build"
for d in rtl sim tools params schema test docs; do cp -r "$d" "$S/"; done
cp -r "$B/oracle" "$S/build/"
cp test/phys/links_split.json "$S/params/links.json"
cd "$S"
if ! { PYTHONPATH=tools python3 tools/gen-skel.py && PYTHONPATH=tools python3 tools/gen-top.py; } \
     >build/gen.log 2>&1; then
  bad "split: generate" "$(tail -2 build/gen.log | xargs)"
  exit 1
fi
say "split: generated" "PASS ($(ls rtl/top/wrap | wc -l) wrapper modules)"

if out=$(python3 tools/check-top-pure.py 2>&1); then
  say "split: top and wrappers hold instances and nets" "PASS (both views)"
else
  bad "split: top-level rule" "$(grep -m1 -E '^  R[0-9]' <<<"$out")"
fi
# Hard reuse under a divergent split: the lanes hold three different things
# -- 30 the common split, lane 07 its own route, lane 06 a feedthrough -- so
# exactly three templates, parameter-free, none the same circuit.
if grep -q "lane: hard reuse, 3 template(s) for 32 instances" <<<"$out"; then
  say "split: lanes hard-reused, 3 templates for 32" "PASS (ccv_lane_w, _v1, _v2)"
else
  bad "split: lane hard reuse" "$(grep -m1 'hard reuse' <<<"$out")"
fi

./tools/check-skel.sh >build/skel_suite.log 2>&1
if grep -q "FAIL" build/skel_suite.log; then
  bad "split: S0 suite" "$(grep -m1 FAIL build/skel_suite.log | xargs)"
else
  say "split: S0 suite, every control, every credit home" "PASS"
fi

./build/skel/ccv-skel --dump-wiring build/wiring.txt
if out=$(python3 tools/check-top-wiring.py --wiring=build/wiring.txt 2>&1); then
  say "split: wiring traced flop by flop == C++" \
      "PASS ($(grep -oE '[0-9]+ slot\(s\) repeated, [0-9]+ flop' <<<"$out" | sed 's/ flop/ stages/'))"
else
  bad "split: wiring through repeaters" "$(sed -n 2p <<<"$out")"
fi

why=""
for k in $(ls -d test/kernels/*/ | xargs -n1 basename); do
  ./build/skel/ccv-skel --kernel "build/oracle/$k/oracle.jsonl" >"build/k_$k.log" 2>&1
  for kv in finished=1 order=ok gpr_mismatch=0 pred_mismatch=0 mem_mismatch=0 \
            check_failures=0 overflows=0 credit_leaks=0 violations=0; do
    [ "$(field "build/k_$k.log" "${kv%%=*}")" = "${kv#*=}" ] || why="$why $k:$kv"
  done
done
[ -z "$why" ] && say "split: every S1 kernel == ccv-sim" "PASS (vadd $(field build/k_vadd.log cycles) cycles)" ||
  bad "split: S1 kernels" "${why# }"

./tools/check-sv-hosted.sh >build/svh_suite.log 2>&1
if grep -q "FAIL" build/svh_suite.log; then
  bad "split: SV-hosted == C++-hosted" "$(grep -m1 FAIL build/svh_suite.log | xargs)"
else
  say "split: SV repeaters == C++ link model" "PASS (4 kernels, 15 controls, skew caught)"
fi

exit $fail
