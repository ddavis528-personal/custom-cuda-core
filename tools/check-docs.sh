#!/usr/bin/env bash
# Documentation consistency.
#
# §8: "anything that can be a script should be -- on a solo project, criteria
# requiring a manual checklist decay to nothing." Documentation decays the same
# way, and more quietly: a count that drifts or a finding reference that points
# nowhere still reads as authoritative.
#
# Five things, all of which drifted at least once:
#   - every F-nn referenced anywhere is defined, and the numbering has no holes
#   - the open-items register (Q-n) is numbered without holes, its summary
#     matches its rows, the schema's open questions name live rows, and every
#     Q-n referenced anywhere is defined
#   - every lint rule is implemented, documented, and numbered without holes
#   - every repo path named in a doc exists
#   - counts stated in prose match what is on disk
set -uo pipefail
cd "$(dirname "$0")/.."

fail=0
say() { printf '  %-46s %s\n' "$1" "$2"; }
bad() { say "$1" "FAIL -- $2"; fail=1; }

out=$(python3 - <<'PY'
import glob, json, os, re, sys

docs = sorted(glob.glob("docs/*.md")) + ["README.md"]
text = {f: open(f).read() for f in docs}
problems = []

# -- findings ----------------------------------------------------------------
F = "docs/stage1a-findings.md"
defined = set(re.findall(r"^## (F-\d+)", text[F], re.M))
used = set()
for t in text.values():
    # "compiler F-141" is the compiler repo's numbering, checked there.
    used |= set(re.findall(r"(?<![Cc]ompiler )\bF-\d+\b", t))
for r in sorted(used - defined, key=lambda x: int(x[2:])):
    problems.append("finding %s is referenced but never defined" % r)
if defined:
    top = max(int(x[2:]) for x in defined)
    for i in range(1, top + 1):
        if "F-%d" % i not in defined:
            problems.append("finding F-%d is missing: the numbering has a hole, "
                            "which usually means one was deleted rather than "
                            "marked superseded" % i)

# -- open items --------------------------------------------------------------
# Running numbering, never reused: the point is that "Q-21" means the same
# thing in every review round, which only holds if nothing renumbers.
Q = "docs/open-items.md"
STATUSES = ("open", "awaiting confirmation", "scheduled", "closed")
rows = {}
for m in re.finditer(r"^\| Q-(\d+) (.*)$", text[Q], re.M):
    n = int(m.group(1))
    cells = [c.strip() for c in m.group(2).split(" | ")]
    st = re.match(r"\*\*(%s)\b" % "|".join(STATUSES), cells[-1])
    if n in rows:
        problems.append("Q-%d has two rows: IDs are never reused" % n)
    if not st:
        problems.append("Q-%d's status does not start with one of: %s"
                        % (n, ", ".join(STATUSES)))
    rows[n] = (st.group(1) if st else "?", m.group(0))
for i in range(1, max(rows, default=0) + 1):
    if i not in rows:
        problems.append("Q-%d is missing: the numbering has a hole, which "
                        "means one was deleted rather than closed" % i)
# The summary lists every live item under its status, and nothing else.
for label in ("Awaiting confirmation", "Open", "Scheduled"):
    m = re.search(r"^- \*\*%s:\*\* (.*)$" % label, text[Q], re.M)
    said = set(int(x) for x in re.findall(r"Q-(\d+)", m.group(1))) if m else set()
    want = {n for n, (st, _) in rows.items() if st == label.lower()}
    if not m:
        problems.append("%s has no '%s' summary line" % (Q, label))
    elif said != want:
        problems.append("%s's '%s' summary says %s, the rows say %s"
                        % (Q, label, sorted(said), sorted(want)))
# Schema open questions and register rows name each other, and agree.
oq = json.load(open("schema/interfaces.json")).get("open_questions", {})
named = {}
for n, (st, row) in rows.items():
    for k in re.findall(r"Schema: `(\w+)`", row):
        named[k] = n
        if st == "closed":
            problems.append("Q-%d is closed but still names schema question "
                            "%s: delete the schema entry, or reopen" % (n, k))
for k, e in oq.items():
    q = e.get("id", "")
    if not re.fullmatch(r"Q-\d+", q):
        problems.append("schema open question %s carries no Q-id" % k)
    elif named.get(k) != int(q[2:]):
        problems.append("schema open question %s says %s, but %s"
                        % (k, q, "Q-%d names it" % named[k] if k in named
                           else "no register row names it"))
for k in sorted(set(named) - set(oq)):
    problems.append("Q-%d names schema question %s, which does not exist"
                    % (named[k], k))
# Every reference resolves. The schema's own text counts as a doc here.
refs = dict(text)
for f in glob.glob("schema/*.json"):
    refs[f] = open(f).read()
for f, t in refs.items():
    for r in sorted(set(int(x) for x in re.findall(r"\bQ-(\d+)\b", t))):
        if r not in rows:
            problems.append("%s refers to Q-%d, which is not in %s" % (f, r, Q))
counts = {st: sum(1 for s, _ in rows.values() if s == st) for st in STATUSES}
print("SUMMARY %d items: %d open, %d awaiting confirmation, %d scheduled, "
      "%d closed" % (len(rows), counts["open"], counts["awaiting confirmation"],
                     counts["scheduled"], counts["closed"]))

# -- lint rules --------------------------------------------------------------
lint = open("tools/lint-rtl.py").read()
impl = set(re.findall(r'(?:add|Finding)\("(CCV-L\d+)"', lint))
guide = set(re.findall(r"\bCCV-L\d+\b", text["docs/rtl-coding-style.md"]))
for r in sorted(guide - impl):
    problems.append("%s is documented but not implemented" % r)
for r in sorted(impl - guide):
    problems.append("%s is implemented but not in the style guide" % r)
if impl:
    top = max(int(x[5:]) for x in impl)
    for i in range(1, top + 1):
        if "CCV-L%02d" % i not in impl:
            problems.append("CCV-L%02d is missing: rule numbers are cited in "
                            "failure messages and must not be reused" % i)

# -- paths -------------------------------------------------------------------
# Sibling-repo paths are written with the repo name in front, so a bare
# top-level directory is always meant to be local.
local = ("docs/", "tools/", "rtl/", "sim/", "test/", "spike/", "schema/",
         "params/", "synth/", ".github/")
# Anything under a generated/ directory is a build product: gitignored, and
# absent from a fresh clone until the generators run. Checking it would make
# this script depend on having been run after them, and a check whose result
# depends on build order is a check nobody trusts. The generators verify their
# own outputs (--check), which is the right place for it.
for f, t in text.items():
    for m in re.finditer(r"`([\w./-]+)`", t):
        pth = m.group(1)
        if not pth.startswith(local) or "*" in pth or "generated/" in pth:
            continue
        if not os.path.exists(pth):
            problems.append("%s refers to %s, which does not exist" % (f, pth))

# -- counts ------------------------------------------------------------------
cases = len([x for x in glob.glob("spike/cases/*.sv") if ".aux." not in x])
probes = len(json.load(open("test/golden/stage1a-matrix.json")).get("probes", {}))
checks = [
    (r"(\d+) cases × 3 tools", cases, "spike cases"),
    (r"tool probes -- (\d+) cases", cases, "spike cases"),
    (r"plus (\d+) out-of-band probes", probes, "out-of-band probes"),
]
for pat, actual, what in checks:
    for f, t in text.items():
        for m in re.finditer(pat, t):
            if int(m.group(1)) != actual:
                problems.append("%s says %s %s, but there are %d"
                                % (f, m.group(1), what, actual))

for p in problems:
    print(p)
sys.exit(1 if problems else 0)
PY
)
rc=$?
summary=$(sed -n 's/^SUMMARY //p' <<< "$out")
out=$(grep -v '^SUMMARY ' <<< "$out")
if [ $rc -eq 0 ]; then
  say "findings, rules, paths and counts consistent" "PASS"
  say "open items (docs/open-items.md)" "PASS ($summary)"
else
  while IFS= read -r l; do [ -n "$l" ] && bad "docs consistent" "$l"; done <<< "$out"
fi

exit $fail
