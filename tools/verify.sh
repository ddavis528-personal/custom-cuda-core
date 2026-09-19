#!/usr/bin/env bash
# The gate. Everything that can be checked, checked.
#
# §8: "CI is a Stage 1 concern, not a Stage 7 one... Stand up the harness
# alongside Stage 1c (it needs the event schema and nothing else), and add
# each stage's exit criteria to it as that stage defines them. On a solo
# project this is the single piece of infrastructure whose absence compounds
# fastest."
#
# And: "A stage is not done because it feels done. ANYTHING THAT CAN BE A
# SCRIPT SHOULD BE -- on a solo project, criteria requiring a manual checklist
# decay to nothing, so exit checks belong in the regression, not in
# discipline."
#
# So this file grows one section per stage as that stage defines its criteria.
# Stages not yet reached are listed as pending rather than omitted, because a
# gate that silently covers less than it appears to is worse than a short one.
#
# Usage:
#   tools/verify.sh          the gate
#   tools/verify.sh --full   also regenerate the Stage 1a matrix from the
#                            tools themselves (minutes, not seconds)
set -uo pipefail
cd "$(dirname "$0")/.."

FULL=0
[ "${1:-}" = "--full" ] && FULL=1

fail=0
section() { printf '\n== %s ==\n' "$1"; }
run() {
  local name="$1"; shift
  if "$@"; then :; else
    printf '  -> %s FAILED\n' "$name"
    fail=1
  fi
}

section "toolchain"
missing=""
for t in verilator iverilog yosys sby cvc5 python3 g++; do
  printf '  %-12s ' "$t"
  if command -v "$t" >/dev/null 2>&1; then
    echo present
  else
    echo MISSING
    missing="$missing $t"
  fi
done
if [ -n "$missing" ]; then
  echo "  run tools/setup-toolchain.sh --$missing"
  echo "  (checks needing a missing tool SKIP rather than fail, so a partial"
  echo "   environment still gates what it can)"
fi

section "generated artifacts"
# Generate first, then check. Two reasons for doing both rather than either:
#
#   * Generated files are gitignored build products, so a fresh clone has
#     none. Checking alone would fail on every new container, which is the
#     fastest way to teach someone to skip the gate.
#   * Running the generator and THEN asserting nothing further changed also
#     catches a non-deterministic generator -- one whose output depends on
#     dict ordering, say. That would show up downstream as a schema hash that
#     drifts on its own, which is a genuinely confusing thing to debug.
run "generate event schema" python3 tools/gen-event-schema.py
run "generate parameters"   python3 tools/gen-params.py
run "generate interfaces"   python3 tools/gen-interfaces.py
run "event schema stable"   python3 tools/gen-event-schema.py --check
run "parameters stable"     python3 tools/gen-params.py --check
run "interfaces stable"     python3 tools/gen-interfaces.py --check

section "Stage 1a -- tool-support spike"
if [ "$FULL" = "1" ]; then
  run "spike regenerates" python3 tools/run-spike-1a.py
  if ! git diff --quiet -- docs/stage1a-tool-support.md test/golden/stage1a-matrix.json 2>/dev/null; then
    echo "  -> the spike produced a DIFFERENT matrix than the one recorded."
    echo "     That is a real finding, not a test failure: a tool changed"
    echo "     under the flow. Read the diff before committing it, and check"
    echo "     docs/stage1a-findings.md still holds."
    fail=1
  fi
fi
run "1a exit criteria" ./tools/check-1a.sh

section "Stage 1b -- assertion primitive library"
run "1b exit criteria" ./tools/check-1b.sh

section "Stage 1c -- event schema mechanism"
run "1c exit criteria" ./tools/check-1c.sh

section "Stage 1d -- coding style and lint"
run "1d exit criteria" ./tools/check-1d.sh

section "Interface checker convention"
run "interface convention" ./tools/check-if.sh

section "X-propagation"
run "x-prop differential" ./tools/check-xprop.sh

section "Clock gating (exploratory)"
# Synthesis is deferred (§6), and nothing depends on this. It is in the gate
# for two seconds of runtime because an artifact outside the gate rots, and
# what it protects is a design direction rather than a build product.
run "clock gating" ./tools/check-clockgate.sh

section "Verilator lint"
# The generic checks the project linter deliberately does not reimplement:
# width mismatches, inferred latches, unused and undriven signals.
if command -v verilator >/dev/null 2>&1; then
  vfail=0
  for f in test/smoke/ccv_assert_smoke.sv rtl/if/issue_if_checker.sv; do
    top=$(basename "$f" .sv)
    [ "$top" = "ccv_assert_smoke" ] && top=dut
    if ! verilator --lint-only --assert -Wall -Wno-DECLFILENAME \
         -Wno-TIMESCALEMOD \
         -Irtl/include -Irtl/generated --top-module "$top" \
         rtl/ccv_assert_pkg.sv "$f" >/tmp/vlint.$$ 2>&1; then
      echo "  $f:"; sed 's/^/    /' /tmp/vlint.$$ | head -12; vfail=1
    fi
    rm -f /tmp/vlint.$$
  done
  [ "$vfail" = "0" ] && echo "  clean" || fail=1
else
  echo "  SKIP -- verilator not installed"
fi

section "pending stages"
# Listed rather than omitted. A gate that appears to cover the whole flow
# while covering only part of it is worse than one that says what it does not.
cat <<'PENDING'
  Stage 2  interface contracts, load-bearing event list, interface assertions,
           per-block NGD budgets                    -- not started
  Stage 3  vadd end-to-end through the skeleton, state identical to ccv-sim,
           event stream loads in Perfetto, zero interface assertion violations
                                                    -- blocked on Stage 2
  Stage 4+ per-block cycle                          -- blocked on Stage 2
PENDING

section "result"
if [ "$fail" = "0" ]; then
  echo "  PASS"
else
  echo "  FAIL"
fi
exit $fail
