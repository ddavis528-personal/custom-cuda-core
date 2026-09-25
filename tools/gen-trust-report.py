#!/usr/bin/env python3
"""Report every module that references a number nobody has decided.

The payload-widths pass makes this a build requirement: which numbers are
still made up should be a build ARTIFACT rather than something anyone has to
remember. Three tiers of trust exist (tools/gen-params.py), and the bottom two
are the ones that matter here:

    ccv_prov_pkg     the NUMBER is a placeholder
    ccv_prelim_pkg   the ENCODING is undecided; the FIELD may change shape

A SOURCE SCAN, not elaboration. The spec says "elaboration emits a report",
and that is the right instinct, but on this toolchain it would be three
different mechanisms with three different output formats and no coverage of
the C++ side at all -- and a report that only Verilator produces is a report
that goes missing exactly when someone builds with Icarus. Scanning source
gets both languages, needs no build, and cannot be skipped by a tool that
elaborated a module away. What it gives up is transitive reach: a module that
references a struct whose FIELD is preliminary is not caught unless the module
names the package itself. That gap is reported below rather than papered over,
because a report that quietly under-counts is worse than none.
"""
import json
import os
import re
import sys

ROOT = os.path.dirname(os.path.dirname(os.path.abspath(__file__)))
PARAMS = os.path.join(ROOT, "params", "ccv_params.json")
SCHEMA = os.path.join(ROOT, "schema", "interfaces.json")
OUT = os.path.join(ROOT, "docs", "trust-report.md")

SCAN = ["rtl", "sim", "test"]
SKIP = ("generated", "__pycache__", "obj_dir")
EXT = (".sv", ".svh", ".v", ".vh", ".cpp", ".h", ".hpp")

BANNER = """<!-- GENERATED FILE -- DO NOT EDIT.
     Produced by tools/gen-trust-report.py. Edit a source and regenerate;
     tools/verify.sh fails if this file is stale. -->
"""

# Strip comments before matching, so a file DISCUSSING the package does not
# count as a file depending on it. Without this the report's own explanatory
# comments would inflate it, which is the CCV-L11/L14 lesson applied here.
BLOCK = re.compile(r"/\*.*?\*/", re.S)
LINE = re.compile(r"//[^\n]*")


def strip(src):
    return LINE.sub("", BLOCK.sub("", src))


def files():
    for top in SCAN:
        for dp, dns, fns in os.walk(os.path.join(ROOT, top)):
            dns[:] = [x for x in dns if x not in SKIP]
            for fn in sorted(fns):
                if fn.endswith(EXT):
                    yield os.path.relpath(os.path.join(dp, fn), ROOT)


def main():
    check = "--check" in sys.argv
    with open(PARAMS) as f:
        pd = json.load(f)
    with open(SCHEMA) as f:
        sd = json.load(f)

    prov = {x["name"]: x for x in pd["params"]
            if x["status"] in ("provisional", "tunable")}
    prelim = {x["name"]: x for x in pd["params"] if x["status"] == "preliminary"}

    hits = {}
    for rel in files():
        with open(os.path.join(ROOT, rel), errors="replace") as f:
            src = strip(f.read())
        names = set(re.findall(r"[A-Za-z_][A-Za-z0-9_]*", src))
        p = sorted(names & set(prov))
        q = sorted(names & set(prelim))
        pkg = []
        for k in ("ccv_prov_pkg", "ccv_prelim_pkg", "ccv::prov", "ccv::prelim"):
            if k in src:
                pkg.append(k)
        if p or q or pkg:
            hits[rel] = (p, q, pkg)

    # Which channels carry a preliminary field: the transitive reach a source
    # scan cannot see, stated so the gap is visible rather than implied.
    fw = sd["field_widths"]
    ident = re.compile(r"[A-Za-z_][A-Za-z0-9_]*")
    tainted = {}
    for c in sd["channels"]:
        bad = []
        for fld in c["payload_fields"]:
            for n in ident.findall(str(fw.get(fld, ""))):
                if n in prelim:
                    bad.append((fld, n))
        if bad:
            tainted[c["name"]] = bad

    L = [BANNER, "# Trust report — which numbers are still made up", ""]
    L.append("Generated. Every module referencing a width nobody has decided,")
    L.append("so this is a build artifact rather than something to remember.")
    L.append("")
    L.append("| Tier | Meaning | What moves |")
    L.append("|---|---|---|")
    L.append("| `ccv_params_pkg` | follows from a settled decision | nothing |")
    L.append("| `ccv_prov_pkg` | a sizing placeholder | the number |")
    L.append("| `ccv_prelim_pkg` | no decided encoding at all | the field's shape |")
    L.append("")
    L.append("## Direct references")
    L.append("")
    if not hits:
        L.append("None. Every referenced width is settled.")
    else:
        L.append("| File | Preliminary | Provisional |")
        L.append("|---|---|---|")
        for rel in sorted(hits):
            p, q, pkg = hits[rel]
            L.append("| `%s` | %s | %s |"
                     % (rel,
                        ", ".join("`%s`" % x for x in q) or "—",
                        ", ".join("`%s`" % x for x in p) or "—"))
    L.append("")
    L.append("## Reach a source scan cannot see")
    L.append("")
    L.append("A module that carries one of these payload structs depends on a")
    L.append("preliminary width without naming the package, so it does not")
    L.append("appear above. **%d of %d channels** carry at least one"
             % (len(tainted), len(sd["channels"])))
    L.append("preliminary field:")
    L.append("")
    L.append("| Channel | Preliminary fields |")
    L.append("|---|---|")
    for c in sorted(tainted):
        L.append("| `%s` | %s |"
                 % (c, ", ".join("`%s`" % f for f, _ in tainted[c])))
    L.append("")
    L.append("## High-churn parameters")
    L.append("")
    L.append("Churn rates the FIELD, not the number. **High** means a per-block")
    L.append("session is likely to change the field's shape, so code that")
    L.append("pattern-matches on its contents will need rewriting — as opposed")
    L.append("to code that merely carries it, which will not.")
    L.append("")
    L.append("| Parameter | Value | Churn | Decided by |")
    L.append("|---|---|---|---|")
    order = {"high": 0, "med": 1, "low": 2}
    for n in sorted(prelim, key=lambda k: (order.get(prelim[k].get("churn"), 9), k)):
        x = prelim[n]
        c = x.get("churn", "?")
        L.append("| `%s` | %d | %s | %s |"
                 % (n, x["value"], "**HIGH**" if c == "high" else c,
                    x.get("decided_at", "—")))
    L.append("")

    text = "\n".join(L).rstrip() + "\n"
    cur = open(OUT).read() if os.path.exists(OUT) else None
    rel = os.path.relpath(OUT, ROOT)
    if check:
        if cur != text:
            sys.stderr.write("%s is stale\n  run tools/gen-trust-report.py\n" % rel)
            return 1
        print("  trust report up to date (%d files, %d/%d channels tainted)"
              % (len(hits), len(tainted), len(sd["channels"])))
        return 0
    with open(OUT, "w") as f:
        f.write(text)
    print("  generated %s (%d files reference an undecided width)"
          % (rel, len(hits)))
    return 0


if __name__ == "__main__":
    sys.exit(main())
