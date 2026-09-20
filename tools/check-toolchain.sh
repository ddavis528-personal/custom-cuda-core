#!/usr/bin/env bash
# Toolchain drift.
#
# Every Stage 1 conclusion is a measurement of third-party tool behaviour at
# one point in time -- $assertoff unsupported, `bind` silently dropped, no
# multi-cycle SVA, interfaces refused at top level. All four are things the
# upstream projects could change, and several replacements were adopted
# BECAUSE of a limitation. If a limitation lifts and nobody notices, the
# workaround stays in the flow forever and the decision behind it is quietly
# wrong.
#
# So the versions the results are attributable to are pinned, and a change is
# reported rather than absorbed. This does not pin what apt installs -- it
# cannot -- it states what was measured and notices when that stops being what
# is present.
#
#   tools/check-toolchain.sh            compare installed against the lock
#   tools/check-toolchain.sh --update   re-pin, after deliberately upgrading
set -uo pipefail
cd "$(dirname "$0")/.."

LOCK=tools/toolchain.lock.json
MODE="${1:-}"

probe() {
  case "$1" in
    verilator) verilator --version 2>/dev/null | head -1 ;;
    iverilog)  iverilog -V 2>/dev/null | head -1 ;;
    yosys)     yosys -V 2>/dev/null | head -1 ;;
    sby)       sby --version 2>/dev/null | head -1 ;;
    cvc5)      cvc5 --version 2>/dev/null | head -1 ;;
  esac
}

TOOLS="verilator iverilog yosys sby cvc5"

if [ "$MODE" = "--update" ]; then
  {
    echo "{"
    echo '  "_comment": ['
    echo '    "Tool versions the Stage 1 results are attributable to.",'
    echo '    "",'
    echo '    "Regenerate with tools/check-toolchain.sh --update, and ONLY after",'
    echo '    "deliberately upgrading and re-running the tool matrix -- the",'
    echo '    "matrix is the thing these versions make meaningful, and a lock",'
    echo '    "updated without it claims a measurement nobody took."'
    echo '  ],'
    echo '  "tools": {'
    first=1
    for t in $TOOLS; do
      v=$(probe "$t"); [ -z "$v" ] && v="NOT INSTALLED"
      [ $first -eq 0 ] && echo ","
      printf '    "%s": "%s"' "$t" "$(echo "$v" | sed 's/"/\\"/g')"
      first=0
    done
    echo
    echo "  }"
    echo "}"
  } > "$LOCK"
  echo "  re-pinned $LOCK -- now re-run tools/run-spike-1a.py"
  exit 0
fi

fail=0
say() { printf '  %-46s %s\n' "$1" "$2"; }

if [ ! -f "$LOCK" ]; then
  say "toolchain lock present" "FAIL -- $LOCK missing"
  exit 1
fi

drift=0
for t in $TOOLS; do
  want=$(python3 -c "import json;print(json.load(open('$LOCK'))['tools'].get('$t','?'))")
  have=$(probe "$t"); [ -z "$have" ] && have="NOT INSTALLED"
  if [ "$want" != "$have" ]; then
    printf '  %-12s pinned: %s\n' "$t" "$want"
    printf '  %-12s found : %s\n' "" "$have"
    drift=1
  fi
done

if [ "$drift" = "0" ]; then
  say "toolchain matches the pinned versions" "PASS"
else
  say "toolchain matches the pinned versions" "FAIL -- see above"
  cat <<'NOTE'
    A tool changed under the flow. That is a FINDING, not a build break:
    several Stage 1 decisions exist because of a limitation, and a limitation
    that lifted silently leaves the workaround in place and the reasoning
    behind it wrong.

      1. python3 tools/run-spike-1a.py     re-measure
      2. read the matrix diff -- a cell going FAIL -> PASS matters as much as
         the reverse, and is much easier to miss
      3. check docs/stage1a-findings.md still holds
      4. tools/check-toolchain.sh --update  re-pin, last
NOTE
  fail=1
fi

exit $fail
