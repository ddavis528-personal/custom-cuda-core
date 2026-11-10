#!/usr/bin/env bash
# The RCU's RTL block (rtl/rcu/ccv_rcu.sv) in lock-step with RI's C++ model
# at the block's ports (TI rev 394; RI-24 (3)). For each kernel:
#   ccv-skel --kernel ... --port-dump rcu=FILE (RA-34) writes what the model
#   saw and drove, a sample a cycle; tools/check-rcu-block.py drives every
#   input of ccv_rcu from it and compares every output each cycle, stopping
#   at the first cycle that differs (its every mismatched port printed).
# One line a kernel: "<kernel>: N cycles, M outputs checked each cycle: PASS".
#
# A known divergence (test/rcublk/expected-fail.txt) is REPORTED, not failed:
# the RTL block is not yet the model, and the job's purpose is to hand RI the
# first diverging cycle. A kernel listed there must fail with exactly the
# listed first divergence: a new one, a different one, or a listed kernel
# that now passes (remove its line) fails the job.
#
# Negative control corrupt-output: one output's expected value flipped at a
# cycle the clean run matched (the first cycle the model sends a valid, else
# the last before the first divergence) must FAIL at exactly that cycle and
# port. It is enforced whatever expected-fail.txt says.
#
# Usage: tools/check-rcu-block.sh [kernel...]   (default: the list below)
#        CCV_RCUBLK_REUSE=1 keeps a harness already built (a local loop only;
#        the gate builds it fresh)
set -uo pipefail
cd "$(dirname "$0")/.."
B=build/rcu-blk
EXP=test/rcublk/expected-fail.txt
SKEL=build/skel/ccv-skel
mkdir -p "$B"
fail=0
say() { printf '  %-58s %s\n' "$1" "$2"; }
# vadd; predlane under its predicate copy as a pmov (check-kernel's form);
# plog; vadd4, four warps side by side.
kernels=("$@")
[ ${#kernels[@]} -gt 0 ] || kernels=(vadd predlane plog vadd4)
env_of() { case "$1" in predlane) echo "CCV_DEC_POR_COPY_AS_PMOV=1" ;; esac; }

if [ ! -x "$SKEL" ]; then
  tools/check-skel.sh >"$B/skel.log" 2>&1 || true
  [ -x "$SKEL" ] || { say "ccv-skel" "FAIL (not built; $B/skel.log)"; exit 1; }
fi
dirs=(); for k in "${kernels[@]}"; do dirs+=("test/kernels/$k"); done
if ! CCV_ORACLE_DIR="$B/oracle" tools/gen-oracle.sh "${dirs[@]}" >"$B/oracle.log" 2>&1; then
  say "oracles" "FAIL ($B/oracle.log)"; exit 1
fi

# The harness, once: ccv_rcu under Verilator, assertions on.
t0=$(date +%s)
if [ "${CCV_RCUBLK_REUSE:-0}" = 1 ] && [ -x "$B/harness/tb" ]; then   # a local loop's reuse
  say "harness: ccv_rcu under Verilator" "reused (CCV_RCUBLK_REUSE=1)"
elif python3 tools/rss-run.py 3 python3 tools/check-rcu-block.py build "$B/harness" \
     >"$B/build.log" 2>&1 3>"$B/build.rss"; then
  say "harness: ccv_rcu under Verilator" \
      "built ($(( $(date +%s) - t0 ))s, peak $(( $(cat "$B/build.rss") / 1024 )) MiB)"
  sed -n 's/^harness: /    /p' "$B/build.log"
else
  say "harness: ccv_rcu under Verilator" "FAIL ($B/build.log)"; tail -5 "$B/build.log" | sed 's/^/    /'; exit 1
fi

# The first divergence as one line: the first failing cycle's mismatches, or
# the assertion that stopped the run.
signature() {
  local log=$1 c
  c=$(sed -n 's/^RCUBLK MISMATCH cycle \([0-9]*\) .*/\1/p' "$log" | head -1)
  if [ -n "$c" ]; then
    echo "cycle $c: $(sed -n "s/^RCUBLK MISMATCH cycle $c port \([^ ]*\) expected \([^ ]*\) got \([^ ]*\)$/\1 \2\/\3/p" "$log" |
                      paste -sd, - | sed 's/,/, /g')"
  else
    grep -m1 -o 'Assertion failed in [^:]*' "$log" || echo "no result"
  fi
}
first_cycle() { sed -n 's/^RCUBLK MISMATCH cycle \([0-9]*\) .*/\1/p' "$1" | head -1; }

declare -A div
for k in "${kernels[@]}"; do
  vcd="$B/$k.vcd" stim="$B/$k.stim" log="$B/$k.log"
  if ! env $(env_of "$k") "$SKEL" --kernel "$B/oracle/$k/oracle.jsonl" --port-dump "rcu=$vcd" \
       >"$B/$k.skel.log" 2>&1; then
    say "$k" "FAIL (ccv-skel; $B/$k.skel.log)"; fail=1; continue
  fi
  if ! python3 tools/check-port-dump.py "$vcd" >"$B/$k.pd.log" 2>&1 ||
     ! python3 tools/check-rcu-block.py vectors "$vcd" "$stim" >"$B/$k.vec.log" 2>&1; then
    say "$k" "FAIL (port dump; $B/$k.pd.log, $B/$k.vec.log)"; fail=1; continue
  fi
  python3 tools/check-rcu-block.py run "$B/harness" "$stim" "$k" >"$log" 2>&1
  known=$(grep -v '^#' "$EXP" 2>/dev/null | sed -n "s/^$k  *//p" | head -1)
  if line=$(grep ": PASS$" "$log"); then
    echo "  $line"
    div[$k]=$(sed -n 's/.*: \([0-9]*\) cycles,.*/\1/p' <<<"$line")
    if [ -n "$known" ]; then
      say "$k: listed in $EXP" "FAIL (it passes now: remove its line)"; fail=1
    fi
    continue
  fi
  sig=$(signature "$log")
  div[$k]=$(first_cycle "$log")
  if [ -n "$known" ] && [ "$sig" = "$known" ]; then
    say "$k" "KNOWN DIVERGENCE ($EXP)"
    echo "    $sig"
  else
    say "$k" "FAIL (first divergence; $log)"
    echo "    $sig"
    [ -n "$known" ] && echo "    expected-fail.txt lists: $known"
    fail=1
  fi
  # For RI, past the first divergence: run on (+keep=1) and name the first
  # assertion, or mismatch on a port outside the signature's (any slot of
  # them), that follows.
  if [ -n "${div[$k]}" ]; then
    RCUBLK_MAXP=100000 python3 tools/check-rcu-block.py run "$B/harness" "$stim" "$k" --keep \
      >"$B/$k.keep.log" 2>&1
    ports_re=$(sed -n "s/^RCUBLK MISMATCH cycle ${div[$k]} port \([^ ]*\) .*/\1/p" "$log" |
               sed 's/_s[0-9]*_/_s[0-9]+_/' | sort -u | paste -sd'|' -)
    nxt=$(grep -E "Assertion failed|^RCUBLK MISMATCH" "$B/$k.keep.log" |
          grep -vE " port (${ports_re:-^$}) " | head -1)
    [ -n "$nxt" ] && echo "    after it (+keep): $(sed 's/^RCUBLK //; s/^\[[0-9]*\] //' <<<"$nxt")"
  fi
  grep -m3 'WAKE-NOTE' "$log" | sed 's/^/    note: /'
done

# Negative control corrupt-output, on the first kernel that ran.
k=${kernels[0]}
if [ -n "${div[$k]:-}" ]; then
  cp=$(python3 tools/check-rcu-block.py control-point "$B/$k.vcd" "${div[$k]}")
  if [ "$cp" = none ]; then
    say "control corrupt-output ($k)" "FAIL (no matched cycle to corrupt)"; fail=1
  else
    c=${cp%%:*} p=${cp#*:}
    python3 tools/check-rcu-block.py vectors "$B/$k.vcd" "$B/$k.ctl.stim" --corrupt "$cp" >/dev/null 2>&1
    python3 tools/check-rcu-block.py run "$B/harness" "$B/$k.ctl.stim" "$k" >"$B/$k.ctl.log" 2>&1
    if ! grep -q ": PASS$" "$B/$k.ctl.log" &&
       [ "$(first_cycle "$B/$k.ctl.log")" = "$c" ] &&
       grep -q "^RCUBLK MISMATCH cycle $c port $p " "$B/$k.ctl.log"; then
      say "control corrupt-output ($k, $p at cycle $c)" "FAIL caught"
    else
      say "control corrupt-output ($k, $p at cycle $c)" "NOT CAUGHT ($B/$k.ctl.log)"; fail=1
    fi
  fi
else
  say "control corrupt-output ($k)" "FAIL (no clean run to corrupt)"; fail=1
fi
exit $fail
