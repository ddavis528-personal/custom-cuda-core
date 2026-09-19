#!/usr/bin/env bash
# Stage 1a exit criteria (§8), checked cheaply.
#
#   "written matrix of SVA constructs x three tools, pass/fail per cell, with
#    a named usable subset; Verible's rule-authoring story and Verilator's
#    X-randomization flag behaviour both confirmed"
#
# Re-running the spike takes minutes, so this validates the RECORDED matrix
# instead: that it covers every case on disk, that the probes ran, and that
# its verdicts are still internally consistent. `tools/verify.sh --full`
# regenerates it from the tools themselves.
#
# Checking coverage matters more than it looks: a case added without rerunning
# the spike would otherwise sit in the tree claiming to measure something that
# was never measured.
set -uo pipefail
cd "$(dirname "$0")/.."

fail=0
say() { printf '  %-46s %s\n' "$1" "$2"; }
bad() { say "$1" "FAIL -- $2"; fail=1; }

M=test/golden/stage1a-matrix.json
D=docs/stage1a-tool-support.md

[ -f "$M" ] || { bad "matrix recorded" "$M missing"; exit 1; }
[ -f "$D" ] || bad "matrix document present" "$D missing"

if python3 - >/dev/null <<'PY'
import json, os, sys
d = json.load(open("test/golden/stage1a-matrix.json"))
recorded = {c["file"] for c in d["cases"]}
on_disk = {f for f in os.listdir("spike/cases")
           if f.endswith(".sv") and ".aux." not in f}
missing = on_disk - recorded
if missing:
    sys.exit("case(s) never measured: %s -- rerun tools/run-spike-1a.py"
             % ", ".join(sorted(missing)))
stale = recorded - on_disk
if stale:
    sys.exit("matrix records case(s) no longer on disk: %s"
             % ", ".join(sorted(stale)))

for t in ("iverilog", "verilator", "sby"):
    for c in d["cases"]:
        if t not in c["cells"]:
            sys.exit("%s has no %s cell" % (c["file"], t))

probes = d.get("probes", {})
for k in ("x_randomization", "interface_boundary", "verible"):
    if k not in probes or "result" not in probes[k]:
        sys.exit("out-of-band probe %r was not run" % k)

# The two findings the rest of the flow is built on. If either flips, several
# decisions recorded in docs/stage1a-findings.md need revisiting, and that
# should be loud rather than discovered later.
cutpoint = next((c for c in d["cases"] if c["file"].startswith("25_")), None)
if not cutpoint or cutpoint["cells"]["sby"]["verdict"] != "PROVE-PASS":
    sys.exit("case 25 no longer proves the assume cut-point works; §7's "
             "formal posture rests on it")
gate = next((c for c in d["cases"] if c["file"].startswith("29_")), None)
if not gate or gate["cells"]["sby"]["verdict"] != "CHECK":
    sys.exit("case 29 no longer bites under formal; the assertion enable "
             "gate may be disarming the formal flow")
print("1A OK")
PY
then
  say "matrix covers every case, probes recorded" "PASS"
else
  bad "matrix consistent with spike/cases" "see above"
fi

grep -q "## The usable subset" "$D" 2>/dev/null \
  && say "usable subset named in the document" "PASS" \
  || bad "usable subset named" "section missing from $D"

exit $fail
