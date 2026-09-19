#!/usr/bin/env bash
# X-propagation: the constructions, and the evidence that choosing between
# them matters.
#
# docs/rtl-coding-style.md, X-propagation section.
#
# ICARUS ONLY, and that is the finding as much as the method: Verilator is
# 2-state and cannot see X at all, and under formal an un-reset register is a
# free TWO-state value (F-8), so $isunknown is identically false there. The
# whole X-propagation posture has exactly one witness in this flow, which is
# why prohibition -- assertions, which fire in Icarus AND prove under formal --
# is the primary mechanism and propagation is the fallback.
set -uo pipefail
cd "$(dirname "$0")/.."

fail=0
say() { printf '  %-46s %s\n' "$1" "$2"; }
bad() { say "$1" "FAIL -- $2"; fail=1; }

if ! command -v iverilog >/dev/null 2>&1; then
  say "x-propagation differential" "SKIP -- iverilog not installed"
  exit 0
fi

TMP=$(mktemp -d); trap 'rm -rf "$TMP"' EXIT

if ! iverilog -g2012 -gassertions -Irtl/include -o "$TMP/x.out" -s tb \
     test/smoke/xprop_diff.sv test/smoke/tb_xprop_diff.sv \
     >"$TMP/c.log" 2>&1; then
  bad "differential builds" "$(head -2 "$TMP/c.log" | tr '\n' ' ')"
  exit $fail
fi

out=$(vvp "$TMP/x.out" 2>&1)
get() { echo "$out" | grep "^XPROP $1 " | awk '{print $'"$2"'}'; }

# sel = xx
# An if-chain with an unknown selector fails EVERY comparison and falls
# through to the final else -- so it returns the LAST branch, I3. Which branch
# it lands on is an artifact of the ordering rather than of the design, and
# that is the point: the answer is definite, arbitrary, and indistinguishable
# from a correct one.
o=$(get xx 3); t=$(get xx 4); x=$(get xx 5)
if [ "$o" = "1101" ]; then
  say "optimistic if-chain: definite, arbitrary answer" "PASS (=$o, the last branch)"
else
  bad "optimistic if-chain falls through to the last branch" \
      "got $o, expected 1101"
fi
if [ "$t" = "11xx" ]; then
  say "ternary merges: agreeing bits kept, rest X" "PASS (=$t)"
else
  bad "ternary gives tmerge" "got $t, expected 11xx"
fi
if [ "$x" = "xxxx" ]; then
  say "case + X-default gives xmerge" "PASS (=$x)"
else
  bad "case + X-default gives xmerge" "got $x, expected xxxx"
fi

# The premise itself: the three constructions must DISAGREE on an unknown
# selector. If they ever agree, the rules are ceremony.
if [ "$o" != "$t" ] && [ "$t" != "$x" ] && [ "$o" != "$x" ]; then
  say "the three constructions disagree on X" "PASS"
else
  bad "the three constructions disagree on X" \
      "opt=$o tmerge=$t xmerge=$x -- construct choice no longer matters"
fi

# Partial X must narrow rather than collapse: tmerge should resolve MORE bits
# at sel=1x than at sel=xx. This is what distinguishes a real merge from a
# blanket X, and it is the reason tmerge is preferred where either is allowed.
t1=$(get 1x 4)
if [ "$t1" = "110x" ]; then
  say "ternary narrows on a partially-unknown select" "PASS (=$t1)"
else
  bad "ternary narrows on partial X" "got $t1, expected 110x"
fi

# And all three must agree once the selector is known, or one of them is
# simply broken rather than pessimistic.
ok=$(get 10 3); tk=$(get 10 4); xk=$(get 10 5)
if [ "$ok" = "1100" ] && [ "$tk" = "1100" ] && [ "$xk" = "1100" ]; then
  say "all three agree when the select is known" "PASS"
else
  bad "all three agree when the select is known" \
      "opt=$ok tmerge=$tk xmerge=$xk"
fi

exit $fail
