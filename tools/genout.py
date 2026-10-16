#!/usr/bin/env python3
"""What the generators own in the generated directories, and the stale
files nobody does (OI-40).

    tools/genout.py              remove every file no generator owns
    tools/genout.py --check      fail if one exists; remove nothing
    tools/genout.py --selftest   the mechanism's own negative controls

The generated directories (GENERATED below) hold nothing hand-written, and
several generators write into each: rtl/generated/ takes the parameters, the
interfaces, the event ids and the checker bank. A generator that stops
writing a file (a rename, a removed block) used to leave the old one where
it was, and the globs that build from those directories went on compiling
it. A fresh checkout never sees it, so the gate passed where the stale copy
was the only thing wrong.

So each directory keeps a manifest, `.generated`, of which generator wrote
which file. A generator calls sync() with what it writes this run. Whatever
it wrote last run and no longer does, it removes, or reports under --check;
another generator's files are never its business. A file in no generator's
entry (left by a generator that predates the manifests, or one since
deleted) is a stray: this script's pass, after every generator has run,
removes or reports it. The manifests in tracked directories (rtl/top/,
test/top/) are tracked with the files they describe.
"""
import json
import os
import shutil
import sys
import tempfile

ROOT = os.path.dirname(os.path.dirname(os.path.abspath(__file__)))
GENERATED = ["rtl/generated", "sim/generated", "rtl/top", "rtl/top/dpi",
             "rtl/top/ports", "rtl/top/stubs", "rtl/top/wrap", "test/top"]
MANIFEST = ".generated"


def _load(d):
    p = os.path.join(d, MANIFEST)
    return json.load(open(p)) if os.path.exists(p) else {}


def _text(m):
    return json.dumps({k: sorted(v) for k, v in sorted(m.items()) if v},
                      indent=1) + "\n"


def sync(owner, paths, check, root=ROOT, dirs=GENERATED):
    """Record that `owner` writes `paths`. Each file it wrote last run and no
    longer does is removed, or, under check, reported; so is a manifest that
    does not yet say what the owner writes. Returns the stale paths,
    relative to root. Paths outside the generated directories (a doc) are
    the generator's own business and pass through untouched."""
    want = {}
    for p in paths:
        d = os.path.relpath(os.path.dirname(os.path.abspath(p)), root)
        want.setdefault(d, set()).add(os.path.basename(p))
    stale = []
    for d in dirs:
        full = os.path.join(root, d)
        m = _load(full)
        new = want.get(d, set())
        for f in sorted(set(m.get(owner, [])) - new):
            if os.path.exists(os.path.join(full, f)):
                stale.append(os.path.join(d, f))
                if not check:
                    os.remove(os.path.join(full, f))
        if set(m.get(owner, [])) == new:
            continue
        m[owner] = sorted(new)
        if check:
            stale.append(os.path.join(d, MANIFEST))
        else:
            os.makedirs(full, exist_ok=True)
            open(os.path.join(full, MANIFEST), "w").write(_text(m))
    return stale


def strays(root=ROOT, dirs=GENERATED, owners=None):
    """Files in the generated directories that no generator owns. An entry
    for a generator that no longer exists owns nothing."""
    if owners is None:
        owners = {f[:-3] for f in os.listdir(os.path.join(root, "tools"))
                  if f.startswith("gen-") and f.endswith(".py")}
    out = []
    for d in dirs:
        full = os.path.join(root, d)
        if not os.path.isdir(full):
            continue
        m = _load(full)
        owned = set().union(*[set(v) for k, v in m.items() if k in owners])
        for f in sorted(os.listdir(full)):
            if f != MANIFEST and f not in owned and \
                    os.path.isfile(os.path.join(full, f)):
                out.append(os.path.join(d, f))
    return out


def selftest():
    """The controls, on a scratch tree: each case is a way a stale file
    survives, and each must be caught."""
    bad = []
    t = tempfile.mkdtemp()
    try:
        os.makedirs(os.path.join(t, "tools"))
        for o in ("gen-a", "gen-b"):
            open(os.path.join(t, "tools", o + ".py"), "w").close()
        d = os.path.join(t, "g")
        os.makedirs(d)
        dirs = ["g"]

        def put(*names):
            for n in names:
                open(os.path.join(d, n), "w").write(n)
            return [os.path.join(d, n) for n in names]

        def run(owner, names, check=False):
            return sync(owner, put(*names) if not check else
                        [os.path.join(d, n) for n in names], check, t, dirs)

        run("gen-a", ["a1", "a2"])
        run("gen-b", ["b1"])
        # 1. A file its generator no longer writes is reported under check,
        #    and nothing is removed while checking.
        got = run("gen-a", ["a1"], check=True)
        if "g/a2" not in got or not os.path.exists(os.path.join(d, "a2")):
            bad.append("a dropped output went unreported under --check: %s" % got)
        # 2. ...and removed when the generator runs.
        run("gen-a", ["a1"])
        if os.path.exists(os.path.join(d, "a2")):
            bad.append("a dropped output survived its generator's run")
        # 3. Another generator's file is never removed.
        if not os.path.exists(os.path.join(d, "b1")):
            bad.append("gen-a removed gen-b's output")
        # 4. A file in no generator's entry is a stray.
        put("old")
        if strays(t, dirs) != ["g/old"]:
            bad.append("an unowned file was not a stray: %s" % strays(t, dirs))
        # 5. So is one whose generator no longer exists.
        os.remove(os.path.join(t, "tools", "gen-b.py"))
        if "g/b1" not in strays(t, dirs):
            bad.append("a deleted generator's file was not a stray")
        # 6. A manifest that does not say what its generator writes is stale.
        if "g/" + MANIFEST not in run("gen-a", ["a1", "a3"], check=True):
            bad.append("a manifest missing a new output was not reported")
    finally:
        shutil.rmtree(t)
    for b in bad:
        sys.stderr.write("genout selftest: %s\n" % b)
    if not bad:
        print("  stale generated files refused (6 controls)")
    return 1 if bad else 0


def main():
    if "--selftest" in sys.argv:
        return selftest()
    check = "--check" in sys.argv
    s = strays()
    if check:
        if s:
            sys.stderr.write("in no generator's outputs: %s\n"
                             "  run tools/genout.py to remove them\n"
                             % ", ".join(s))
            return 1
        print("  generated directories hold only generated files")
        return 0
    for f in s:
        os.remove(os.path.join(ROOT, f))
    print("  removed %d stale generated file(s)%s"
          % (len(s), ": " + ", ".join(s) if s else ""))
    return 0


if __name__ == "__main__":
    sys.exit(main())
