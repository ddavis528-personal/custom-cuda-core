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

section "documentation"
# Docs decay more quietly than code: a drifted count or a dangling reference
# still reads as authoritative. Both happened during Stage 1.
run "docs consistent" ./tools/check-docs.sh

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
run "generate payload spec" python3 tools/gen-payload-spec.py
run "event schema stable"   python3 tools/gen-event-schema.py --check
run "parameters stable"     python3 tools/gen-params.py --check
run "interfaces stable"     python3 tools/gen-interfaces.py --check
# docs/payload-spec.md is generated but TRACKED, unlike the rtl/sim ones --
# it is the per-block sessions' worklist, so it has to be readable on GitHub
# without running anything. Being generated is what stops it disagreeing with
# the schema, which is the failure that would make it worse than no spec.
run "payload spec stable"   python3 tools/gen-payload-spec.py --check
# Which numbers are still made up is a BUILD ARTIFACT rather than something
# anyone has to remember -- the payload-widths pass made that a requirement,
# and a requirement nobody can forget to meet is one the gate produces.
run "generate trust report" python3 tools/gen-trust-report.py
run "trust report stable"   python3 tools/gen-trust-report.py --check
run "generate skel wiring"  python3 tools/gen-skel.py
run "skel wiring stable"    python3 tools/gen-skel.py --check
run "generate SV top"       python3 tools/gen-top.py
run "SV top stable"         python3 tools/gen-top.py --check

section "Stage 1a -- tool-support spike"
# Every Stage 1 conclusion is a measurement of a third-party tool, and some
# decisions exist BECAUSE of a limitation. Two cheap checks here; the full
# re-measure is --full, and runs in CI on a schedule.
run "toolchain versions pinned" ./tools/check-toolchain.sh
run "1a exit criteria" ./tools/check-1a.sh
if [ "$FULL" = "1" ]; then
  run "matrix unchanged since last measured" python3 tools/check-matrix-drift.py
fi

section "Stage 1b -- assertion primitive library"
run "1b exit criteria" ./tools/check-1b.sh

section "Stage 1c -- event schema mechanism"
run "1c exit criteria" ./tools/check-1c.sh
# A test catches a broken emit path; only calibration catches a systematic
# one-cycle offset, which at correlation reads as a design divergence.
run "emit-path calibration" ./tools/check-emit-calib.sh

run "trace identity view" python3 tools/check-trace-ids.py

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

section "Stage 3 -- skeleton (S0: plumbing)"
# The whole machine wired from the schema, every block an exerciser stub,
# every slot judged by the Verilated SV checker. S0 proves the machine is
# connected before any block does anything real; vadd end to end is S1.
run "skeleton plumbing" ./tools/check-skel.sh

section "Stage 3 -- skeleton (S1: vadd)"
# vadd on functional stubs over the real channel path, final register file
# and memory compared with ccv-sim's, each clean result paired with a control
# that must fail. After S0, which builds the binary.
run "vadd through the machine" ./tools/check-kernel.sh

section "SV top -- rtl/top/ (generated, tracked)"
# The same machine as SystemVerilog: 45 stub blocks wired by the 103 channel
# instances, with the checker bank under CCV_CHECK. After the skeleton, which
# builds the binary whose wiring this is compared against.
run "SV top" ./tools/check-top.sh

section "Verilator lint"
# The generic checks the project linter deliberately does not reimplement:
# width mismatches, inferred latches, unused and undriven signals.
if command -v verilator >/dev/null 2>&1; then
  vfail=0
  # file:define -- the credit checker is linted with and without CCV_TRACE,
  # because the trace sideband changes its port list and each variant is a
  # build someone will run.
  for spec in test/smoke/ccv_assert_smoke.sv: rtl/if/ccv_credit_checker.sv: \
              rtl/if/ccv_credit_checker.sv:CCV_TRACE rtl/if/ccv_atomic_checker.sv: \
              rtl/if/ccv_lockstep_checker.sv: rtl/if/ccv_lockstep_checker.sv:CCV_TRACE \
              rtl/if/ccv_binding_checker.sv: rtl/if/ccv_outstanding_checker.sv:; do
    f=${spec%%:*}; def=${spec#*:}
    top=$(basename "$f" .sv)
    [ "$top" = "ccv_assert_smoke" ] && top=dut
    if ! verilator --lint-only --assert -Wall -Wno-DECLFILENAME \
         -Wno-TIMESCALEMOD ${def:+-D$def} \
         -Irtl/include -Irtl/generated --top-module "$top" \
         rtl/ccv_assert_pkg.sv "$f" >/tmp/vlint.$$ 2>&1; then
      echo "  $f${def:+ (+$def)}:"; sed 's/^/    /' /tmp/vlint.$$ | head -12; vfail=1
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
  Stage 2  partition CLOSED (14 blocks, 45 instances, 46 channels); topology,
           block letters, machine parameters and the credit checker encoded.
           Round trip CLOSED at 2 (flops both sides + abutment); it stays a
           per-instance parameter, defaulted to that minimum and not expected
           to move before floorplan.
           Payload widths: every field sized, tiered settled/prov/prelim.
           Rate>1: independent slots, with acceptance / ordering / binding
           per channel. Remaining: per-interface NGD budgets
  Stage 3  S0 plumbing DONE: 45 blocks, 108 channel instances, 345 slots,
           checker bank Verilated in, trace identity carried, Perfetto
           trace, layout cross-checked, slot count re-derived.
           S1 DONE: vadd end to end on functional stubs, final state
           identical to ccv-sim, 0 violations, 26 of 46 channels carrying
           it. Open items: docs/open-items.md, by Q-number.
           S2 next: a kernel that diverges, loops, or uses SPM/barriers
  Stage 4+ per-block cycle                          -- after the skeleton
PENDING

section "result"
if [ "$fail" = "0" ]; then
  echo "  PASS"
else
  echo "  FAIL"
fi
exit $fail
