#!/usr/bin/env bash
# Stage 1d exit criteria (§8):
#
#   "style guide written (§9); lint rules FAIL a deliberately non-compliant
#    sample module -- demonstrated to bite, not merely configured;
#    shared-parameter generation produces matching C++ and RTL definitions
#    from one source"
#
# The middle criterion is checked per RULE, not in aggregate. A fixture that
# trips eight of eleven rules still "fails lint", and the three that went quiet
# would not be noticed until a block relied on one of them.
set -uo pipefail
cd "$(dirname "$0")/.."

TMP=$(mktemp -d); trap 'rm -rf "$TMP"' EXIT
fail=0
say() { printf '  %-46s %s\n' "$1" "$2"; }
bad() { say "$1" "FAIL -- $2"; fail=1; }

# -- the style guide exists and documents every rule -----------------------
GUIDE=docs/rtl-coding-style.md
if [ -f "$GUIDE" ]; then
  say "style guide present" "PASS"
else
  bad "style guide present" "$GUIDE missing"
fi

# -- lint bites, rule by rule ---------------------------------------------
# Both fixtures, and CCV-L12 pointed at the fixture schema -- it is a
# cross-file rule keyed on schema/interfaces.json, so it cannot be
# counter-exampled by a .sv file alone.
python3 tools/lint-rtl.py rtl/lint/bad_module.sv >"$TMP/bad.log" 2>&1
python3 tools/lint-rtl.py --schema=rtl/lint/bad_interfaces.json \
  rtl/lint/bad_if_checker.sv >>"$TMP/bad.log" 2>&1
python3 tools/lint-rtl.py rtl/lint/bad_xprop.sv >>"$TMP/bad.log" 2>&1
if grep -q "CCV-L" "$TMP/bad.log"; then false; else true; fi
if [ $? -eq 0 ]; then
  bad "lint fails the non-compliant sample" "it passed"
else
  say "lint fails the non-compliant sample" "PASS"
fi

# Every rule the linter defines must be demonstrated by the fixture. Deriving
# the expected list from the source rather than hardcoding it means a new rule
# added without a counter-example fails here, instead of shipping unexercised.
# Both construction forms: add("CCV-Lnn", ...) for per-file rules and
# Finding("CCV-Lnn", ...) for the cross-file ones. Matching only the first
# silently excused CCV-L12 from ever being verified.
RULES=$(grep -oP '(?:add|Finding)\("\KCCV-L\d+' tools/lint-rtl.py | sort -u)
missing=""
for r in $RULES; do
  grep -q "$r" "$TMP/bad.log" || missing="$missing $r"
done
if [ -n "$missing" ]; then
  bad "every lint rule has a counter-example" "never fired:$missing"
else
  say "every lint rule fires on the fixture ($(echo "$RULES" | wc -w) rules)" "PASS"
fi

# Every rule must also be documented, or a failure points at a regex rather
# than at the paragraph explaining why the rule exists.
undoc=""
for r in $RULES; do
  grep -q "$r" "$GUIDE" 2>/dev/null || undoc="$undoc $r"
done
if [ -n "$undoc" ]; then
  bad "every lint rule is documented" "not in the style guide:$undoc"
else
  say "every lint rule is documented in the guide" "PASS"
fi

# -- compliant code must be SILENT -----------------------------------------
# The false-positive regression, and it matters more than usual for the
# X-determinism rules: a rule that fires on correct code gets switched off, and
# a rule that is switched off protects nothing. good_xprop.sv exercises all
# three legal routes on control inputs exactly as suspicious as the fixture's.
if python3 tools/lint-rtl.py rtl/lint/good_xprop.sv >"$TMP/good.log" 2>&1; then
  say "compliant X-determinism code is silent" "PASS"
else
  bad "compliant X-determinism code is silent" \
      "$(grep -m1 'CCV-L' "$TMP/good.log")"
fi

# -- the real tree is clean ------------------------------------------------
if python3 tools/lint-rtl.py -q >"$TMP/clean.log" 2>&1; then
  say "lint clean across rtl/, test/, spike/" "PASS"
else
  bad "lint clean across the tree" "$(head -3 "$TMP/clean.log" | tr '\n' ' ')"
fi

# -- shared parameters: one source, two languages, same values -------------
if python3 tools/gen-params.py --check >"$TMP/gen.log" 2>&1; then
  say "generated parameter files current" "PASS"
else
  bad "generated parameter files current" "$(head -1 "$TMP/gen.log")"
fi

# §9's actual concern is not that the files exist but that they cannot DRIFT.
# So compare the values, in both languages, against the source of truth --
# which is the check that would have caught the failure §9 describes, "a
# correlation run silently comparing two differently-sized machines".
if python3 - >/dev/null <<'PY'
import json, re, sys, os
root = os.getcwd()
src = json.load(open(os.path.join(root, "params/ccv_params.json")))
sv = open(os.path.join(root, "rtl/generated/ccv_params_pkg.sv")).read()
h = open(os.path.join(root, "sim/generated/ccv_params.h")).read()

def camel(n):
    parts = [p for p in n.split("_") if p != "CCV"]
    return "".join(p.capitalize() for p in parts)

bad = []
for p in src["params"]:
    name, val = p["name"], p["value"]
    m = re.search(r"localparam\s+int\s+%s\s*=\s*(\d+)\s*;" % re.escape(name), sv)
    if not m:
        bad.append("%s missing from SystemVerilog" % name)
    elif int(m.group(1)) != val:
        bad.append("%s: SV %s vs source %d" % (name, m.group(1), val))
    cn = "k" + camel(name)
    m = re.search(r"constexpr\s+uint32_t\s+%s\s*=\s*(\d+)\s*;" % re.escape(cn), h)
    if not m:
        bad.append("%s missing from C++ (as %s)" % (name, cn))
    elif int(m.group(1)) != val:
        bad.append("%s: C++ %s vs source %d" % (name, m.group(1), val))
if bad:
    sys.exit("; ".join(bad))
print("PARAMS MATCH")
PY
then
  say "C++ and RTL parameter values agree with source" "PASS"
else
  bad "C++ and RTL parameter values agree" "see above"
fi

exit $fail
