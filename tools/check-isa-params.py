#!/usr/bin/env python3
"""ISA-sourced parameters agree with the pinned ISA (IS-11).

    tools/check-isa-params.py              every status-isa parameter
    tools/check-isa-params.py --selftest   the negative controls

A parameter whose status is isa or isa_provisional states a fact the ISA
owns. IS-11 found four that had drifted from it, with nothing to say so:
a fact stated in two repositories disagrees with itself. So each carries an
`isa` citation, and this checks it against the ISA document in the compiler
snapshot tools/compiler.lock pins (tools/fetch-compiler.sh):

    "isa": {"doc": "isa-v1.9-operation-map-and-encoding.md",
            "quote": "| D (base+offset) | 13 | **29** | `[31:19]` | `[47:32]` |",
            "value": "q[1]"}

  ISA-1  the quote appears verbatim in the document. When the ISA rewords or
         changes that text the check fails, and whoever re-cites it reviews
         the parameter against the new text.
  ISA-2  the parameter's value equals `value`, an expression over the quote
         alone: q[i] is the quote's i-th integer, r[i] the width of its i-th
         bit range `[hi:lo]`, and clog2, len, max and min are allowed.
  ISA-3  every status-isa parameter has a citation, and every citation names
         the document the pinned snapshot carries for the current version.

A value that follows from the quote by argument rather than arithmetic (two
spaces need one bit) is written as that arithmetic, `clog2(2)`, with the
argument in the parameter's doc.
"""
import argparse
import ast
import copy
import json
import math
import os
import re
import subprocess
import sys

ROOT = os.path.dirname(os.path.dirname(os.path.abspath(__file__)))
PARAMS = os.path.join(ROOT, "params", "ccv_params.json")
ISA_DOC = "isa-v1.9-operation-map-and-encoding.md"
ISA_STATUSES = ("isa", "isa_provisional")


def snapshot_dir():
    out = subprocess.run([os.path.join(ROOT, "tools", "fetch-compiler.sh")],
                         capture_output=True, text=True)
    if out.returncode != 0:
        sys.exit("check-isa-params: " + (out.stderr.strip() or "fetch-compiler failed"))
    return os.path.join(ROOT, out.stdout.strip())


def params(tree):
    found = []

    def walk(o):
        if isinstance(o, dict):
            if "name" in o and "value" in o:
                found.append(o)
            for v in o.values():
                walk(v)
        elif isinstance(o, list):
            for v in o:
                walk(v)
    walk(tree)
    return found


def clog2(n):
    return max(0, math.ceil(math.log2(n)))


SAFE = {"clog2": clog2, "len": len, "max": max, "min": min}
ALLOWED = (ast.Expression, ast.BinOp, ast.UnaryOp, ast.Constant, ast.Name,
           ast.Load, ast.Subscript, ast.Slice, ast.Call, ast.Add, ast.Sub,
           ast.Mult, ast.FloorDiv, ast.Pow, ast.USub)


def evaluate(expr, quote):
    tree = ast.parse(expr, mode="eval")
    for n in ast.walk(tree):
        if not isinstance(n, ALLOWED):
            raise ValueError("not allowed in a value: %s" % type(n).__name__)
        if isinstance(n, ast.Name) and n.id not in ("q", "r") and n.id not in SAFE:
            raise ValueError("unknown name %r" % n.id)
    q = [int(x) for x in re.findall(r"\d+", quote)]
    r = [int(hi) - int(lo) + 1 for hi, lo in re.findall(r"\[(\d+):(\d+)\]", quote)]
    return eval(compile(tree, "<value>", "eval"), {"__builtins__": {}},
                dict(SAFE, q=q, r=r))


def check(plist, docs):
    """Findings, one string each, for the parameters `plist` against the
    ISA documents `docs` (name -> text)."""
    bad = []
    for p in plist:
        if p.get("status") not in ISA_STATUSES:
            continue
        name, cite = p["name"], p.get("isa")
        if not cite:
            bad.append("ISA-3 %s: status %s but no isa citation" % (name, p["status"]))
            continue
        doc = cite.get("doc")
        if doc != ISA_DOC or doc not in docs:
            bad.append("ISA-3 %s: cites %r, not the pinned %s" % (name, doc, ISA_DOC))
            continue
        if cite["quote"] not in docs[doc]:
            bad.append("ISA-1 %s: quote not in %s: %r" % (name, doc, cite["quote"]))
            continue
        try:
            want = evaluate(cite["value"], cite["quote"])
        except (ValueError, IndexError, SyntaxError) as e:
            bad.append("ISA-2 %s: value %r: %s" % (name, cite["value"], e))
            continue
        if want != p["value"]:
            bad.append("ISA-2 %s = %s, but the ISA gives %s (%s over %r)"
                       % (name, p["value"], want, cite["value"], cite["quote"]))
    return bad


def selftest(plist, docs):
    """Each control must produce exactly the finding it names."""
    def named(ps, name):
        return next(p for p in ps if p["name"] == name)

    def reword(ps, ds):
        quote = named(ps, "CCV_W_DISP")["isa"]["quote"]
        ds[ISA_DOC] = ds[ISA_DOC].replace(quote, quote.replace("29", "30"))

    controls = [
        ("a parameter one bit narrower (IS-11's CCV_W_DISP at 16)", "ISA-2",
         lambda ps, ds: named(ps, "CCV_W_DISP").__setitem__("value", 16)),
        ("a field one bit wider than the ISA's (CCV_L_W_ORDERING at 6)", "ISA-2",
         lambda ps, ds: named(ps, "CCV_L_W_ORDERING").__setitem__("value", 6)),
        ("the ISA rewords the cited text", "ISA-1", reword),
        ("a status-isa parameter with no citation", "ISA-3",
         lambda ps, ds: named(ps, "CCV_W_DISP").pop("isa")),
        ("a citation of the superseded v1.7", "ISA-3",
         lambda ps, ds: named(ps, "CCV_W_DISP")["isa"].__setitem__(
             "doc", "isa-v1.7-operation-map-and-encoding.md")),
        ("a value that is not arithmetic over the quote", "ISA-2",
         lambda ps, ds: named(ps, "CCV_W_DISP")["isa"].__setitem__("value", "__import__('os')")),
    ]
    fails = 0
    for what, rule, mutate in controls:
        ps, ds = copy.deepcopy(plist), dict(docs)
        mutate(ps, ds)
        got = check(ps, ds)
        if len(got) == 1 and got[0].startswith(rule):
            continue
        fails += 1
        print("  control not caught as %s: %s -> %s" % (rule, what, got))
    print("  %d controls%s" % (len(controls), "" if not fails else ", %d not caught" % fails))
    return fails


def main():
    ap = argparse.ArgumentParser()
    ap.add_argument("--selftest", action="store_true")
    args = ap.parse_args()
    snap = snapshot_dir()
    docs = {}
    for fn in os.listdir(os.path.join(snap, "docs")):
        if fn.startswith("isa-v") and fn.endswith(".md"):
            with open(os.path.join(snap, "docs", fn)) as f:
                docs[fn] = f.read()
    with open(PARAMS) as f:
        plist = params(json.load(f))
    if args.selftest:
        return 1 if selftest(plist, docs) else 0
    bad = check(plist, docs)
    for b in bad:
        print("  " + b)
    n = sum(1 for p in plist if p.get("status") in ISA_STATUSES)
    print("  %d ISA-sourced parameters against %s" % (n, ISA_DOC) if not bad else
          "  %d finding(s)" % len(bad))
    return 1 if bad else 0


if __name__ == "__main__":
    sys.exit(main())
