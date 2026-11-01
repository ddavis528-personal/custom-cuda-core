#!/usr/bin/env python3
"""Join a gate split across containers (OI-101; DA, 2026-11-01).

    tools/gate-combine.py <local build/verify> <imported build/verify>...
    tools/gate-combine.py --selftest

Each directory holds a run's manifest.json (tools/verify.sh writes one every
run) and its section logs. The joined gate passes only if:
  - every run is of the same commit and tree, with no uncommitted change;
  - every section the local run's scope needs (all but those outside its
    --changed scope) passed in exactly one run: in the local run, or in one
    imported run with the local run marking it `elsewhere`;
  - each imported section's log is the one its manifest hashed, and reads
    no FAILED line.
Prints `SPLIT PASS -- ...` (or `SPLIT SCOPED PASS` beside --changed) and
exits 0, or names every refusal and exits 1. Never a plain PASS.
"""
import hashlib
import json
import os
import re
import sys


def load(d):
    with open(os.path.join(d, "manifest.json")) as fh:
        return json.load(fh)


def combine(local_dir, imported_dirs):
    bad = []
    loc = load(local_dir)
    imps = [(d, load(d)) for d in imported_dirs]
    for d, m in [(local_dir, loc)] + imps:
        if m["commit"] != loc["commit"] or m["tree"] != loc["tree"]:
            bad.append("%s ran %s (tree %s), not %s (tree %s)"
                       % (d, m["commit"][:7], m["tree"][:7], loc["commit"][:7], loc["tree"][:7]))
        if m.get("dirty"):
            bad.append("%s ran on a tree with uncommitted changes" % d)
    covered = {}
    for d, m in imps:
        for j, v in m["sections"].items():
            if v["outcome"] not in ("pass", "fail"):
                continue
            if v["outcome"] == "fail":
                bad.append("%s: section %s failed there" % (d, j))
                continue
            log = os.path.join(d, j + ".log")
            try:
                body = open(log, "rb").read()
            except OSError:
                bad.append("%s: section %s has no log" % (d, j))
                continue
            if hashlib.sha256(body).hexdigest() != v["log"]:
                bad.append("%s: section %s's log is not the one its manifest hashed" % (d, j))
            if re.search(rb"^\s*-> .* FAILED$", body, re.M):
                bad.append("%s: section %s's log reads a FAILED line" % (d, j))
            covered.setdefault(j, []).append(d)
    need, here, there = [], [], []
    for j, v in loc["sections"].items():
        o = v["outcome"]
        if o == "scope":
            continue
        need.append(j)
        n = len(covered.get(j, []))
        if o == "pass":
            here.append(j)
            if n:
                bad.append("section %s ran here and in %s: covered twice" % (j, ", ".join(covered[j])))
        elif o == "elsewhere":
            there.append(j)
            if n != 1:
                bad.append("section %s is left to another run, and %s" %
                           (j, "no imported run passed it" if n == 0 else
                            "%d imported runs did (%s)" % (n, ", ".join(covered[j]))))
        else:
            bad.append("section %s failed here" % j)
    if bad:
        return False, bad
    kind = "SPLIT SCOPED PASS" if loc.get("base") else "SPLIT PASS"
    return True, ["%s -- %d of %d sections: here %s; imported %s; commit %s"
                  % (kind, len(need), len(loc["sections"]), " ".join(here) or "-",
                     " ".join("%s(%s)" % (j, covered[j][0]) for j in there) or "-",
                     loc["commit"][:7])]


def selftest():
    import tempfile
    bad = []
    root = tempfile.mkdtemp(prefix="gate-combine-")

    def run(name, commit="c1", tree="t1", dirty=False, base="", secs=None, logs=None):
        d = os.path.join(root, name)
        os.makedirs(d)
        s = {}
        for j, o in (secs or {}).items():
            body = (logs or {}).get(j, "== %s ==\n  ok PASS\n" % j).encode()
            with open(os.path.join(d, j + ".log"), "wb") as fh:
                fh.write(body)
            s[j] = {"outcome": o, "log": hashlib.sha256(body).hexdigest()}
        with open(os.path.join(d, "manifest.json"), "w") as fh:
            json.dump({"commit": commit, "tree": tree, "dirty": dirty, "base": base,
                       "cached": True, "sections": s}, fh)
        return d

    def expect(ok, want, what):
        if ok != want:
            bad.append(what)
    L = run("L", secs={"a": "pass", "ngd": "pass", "cg": "elsewhere", "x": "scope"})
    R = run("R", secs={"a": "elsewhere", "ngd": "elsewhere", "cg": "pass", "x": "scope"})
    expect(combine(L, [R])[0], True, "a clean split was refused: %s" % combine(L, [R])[1])
    R2 = run("R2", commit="c2", secs={"cg": "pass"})
    expect(combine(L, [R2])[0], False, "another commit's section was accepted")
    R3 = run("R3", tree="t2", secs={"cg": "pass"})
    expect(combine(L, [R3])[0], False, "another tree's section was accepted")
    R4 = run("R4", dirty=True, secs={"cg": "pass"})
    expect(combine(L, [R4])[0], False, "a dirty tree's section was accepted")
    expect(combine(L, [])[0], False, "a section left elsewhere and never run was accepted")
    expect(combine(L, [R, run("R5", secs={"cg": "pass"})])[0], False,
           "a section two imports ran was accepted")
    R6 = run("R6", secs={"cg": "pass", "ngd": "pass"})
    expect(combine(L, [R6])[0], False, "a section run here and imported was accepted")
    R7 = run("R7", secs={"cg": "fail"})
    expect(combine(L, [R7])[0], False, "an imported failure was accepted")
    R8 = run("R8", secs={"cg": "pass"}, logs={"cg": "== cg ==\n  -> local clock gating FAILED\n"})
    expect(combine(L, [R8])[0], False, "an imported log with a FAILED line was accepted")
    R9 = run("R9", secs={"cg": "pass"})
    with open(os.path.join(R9, "cg.log"), "a") as fh:
        fh.write("edited\n")
    expect(combine(L, [R9])[0], False, "an imported log edited after its manifest was accepted")
    L2 = run("L2", secs={"a": "pass", "cg": "fail"})
    expect(combine(L2, [])[0], False, "a local failure was accepted")
    for x in bad:
        sys.stderr.write("gate-combine selftest: %s\n" % x)
    if not bad:
        print("  split gate: another commit, tree or dirty run, a gap, a double, an imported "
              "failure or edited log are each refused (11 controls)")
    return 1 if bad else 0


def main():
    a = sys.argv[1:]
    if a == ["--selftest"]:
        return selftest()
    if len(a) < 1:
        sys.exit(__doc__)
    ok, lines = combine(a[0], a[1:])
    for l in lines:
        print(("  " if ok else "  refused: ") + l)
    return 0 if ok else 1


if __name__ == "__main__":
    sys.exit(main())
