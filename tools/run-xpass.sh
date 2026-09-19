#!/usr/bin/env bash
# The periodic 4-state X-cleanliness pass (§6).
#
# §6 runs this as a milestone gate rather than a per-change default, because
# Icarus is meaningfully slower than Verilator and early bring-up bugs are
# overwhelmingly functional ones that 2-state catches just as well. §6 also
# pulls it forward from closure to ONCE PER BLOCK AT STAGE 4C, because
# selective reset makes Verilator structurally blind to un-reset-payload bugs.
#
# Two things this pass does NOT cover, printed on every run rather than left
# to be remembered:
#
#   1. Tier-2 temporal properties are absent. Icarus has no $past (Stage 1a
#      finding F-1), so `CCV_ASSERT_T` compiles to nothing here. This is the
#      one place the library varies a property's PRESENCE rather than its
#      spelling, and it is why Icarus is the X-pass and not the assertion
#      regression.
#
#   2. Icarus cannot close the X gap alone. Verilog's X-optimism means a
#      4-state simulator also HIDES X bugs: `if (x)` silently takes the false
#      branch rather than flagging ambiguity. Commercial tools have a
#      dedicated X-propagation mode; Icarus has no equivalent. It catches X
#      that propagates visibly, not X silently resolved at a branch. That gap
#      is closed by CCV-L08 ($isunknown on control) and by formal, not here.
set -uo pipefail
cd "$(dirname "$0")/.."

if ! command -v iverilog >/dev/null 2>&1; then
  echo "  SKIP -- iverilog not installed (tools/setup-toolchain.sh)"
  exit 0
fi

FILES=("$@")
if [ ${#FILES[@]} -eq 0 ]; then
  # No design RTL exists before Stage 3, and there is nothing honest to run
  # this against yet. The 1b smoke module is not a stand-in: it contains a
  # property written to FIRE, so pointing the X-pass at it would produce a
  # red result that means nothing and would train everyone to ignore it.
  #
  # The library's Icarus path is already covered by tools/check-1b.sh, which
  # checks the firing and the silencing separately and knows which is which.
  echo "  SKIP -- no design RTL yet; this gate arrives per block at Stage 4c"
  echo "          (usage: tools/run-xpass.sh <tb.sv> <block.sv> ...)"
  exit 0
fi

cat <<'NOTE'
  X-cleanliness pass (Icarus, 4-state)
    NOTE: tier-2 temporal properties are NOT carried in this flow -- Icarus
    has no $past, so CCV_ASSERT_T compiles to nothing here.
    NOTE: this pass catches X that propagates visibly, not X silently
    resolved at a branch. CCV-L08 and formal cover that.
NOTE

TMP=$(mktemp -d); trap 'rm -rf "$TMP"' EXIT
if ! iverilog -g2012 -gassertions -Irtl/include -Irtl/generated \
     -o "$TMP/x.out" -s tb "${FILES[@]}" >"$TMP/c.log" 2>&1; then
  echo "  FAIL -- compile:"; sed 's/^/    /' "$TMP/c.log" | head -10
  exit 1
fi

out=$(vvp "$TMP/x.out" 2>&1)
# An X reaching control is reported by CCV_ASSERT_KNOWN, which is the point of
# this pass; any other assertion failure is a functional bug and equally worth
# stopping on.
if echo "$out" | grep -qE "ERROR|X reached control"; then
  echo "  FAIL -- assertions fired:"
  echo "$out" | grep -E "ERROR|X reached" | sed 's/^/    /' | head -10
  exit 1
fi
echo "  clean"
exit 0
