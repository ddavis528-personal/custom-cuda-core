#!/usr/bin/env python3
"""The sections a killed gate passed, which tools/verify.sh --resume carries
over (IS-27: container restarts killed the ~3 h full gate before it ended).

    tools/gate-resume.py <earlier build/verify> <runid> <dirty>
    tools/gate-resume.py --selftest

<runid> is this run's commit, tree and arguments (verify.sh writes the same
to build/verify/runid). Prints, one a line, each section the earlier run
passed whose log is still the one it hashed, and nothing at all unless:
  - this tree has no uncommitted change (<dirty> is 0);
  - the earlier run's runid is this one's: the same commit, tree and
    arguments (--resume aside);
  - its progress record exists (verify.sh appends a line, `<section>
    <outcome> <log sha256>`, as each section ends).
A section whose last line is not `pass`, or whose log no longer matches, is
not printed: it runs again.
"""
import hashlib
import os
import sys
import tempfile


def carried(prev, runid, dirty):
    if dirty != "0":
        return []
    try:
        with open(os.path.join(prev, "runid")) as fh:
            if fh.read().strip() != runid.strip():
                return []
        lines = open(os.path.join(prev, "progress")).read().splitlines()
    except OSError:
        return []
    last = {}
    for l in lines:
        f = l.split()
        if len(f) == 3:
            last[f[0]] = (f[1], f[2])
    out = []
    for j, (outcome, h) in last.items():
        if outcome != "pass":
            continue
        try:
            body = open(os.path.join(prev, j + ".log"), "rb").read()
        except OSError:
            continue
        if hashlib.sha256(body).hexdigest() == h:
            out.append(j)
    return sorted(out)


def selftest():
    bad = []
    with tempfile.TemporaryDirectory() as d:
        rid = "c0ffee 7ree --only a,b"

        def setup(runid=rid, logs=None, prog=None):
            for f in os.listdir(d):
                os.remove(os.path.join(d, f))
            open(os.path.join(d, "runid"), "w").write(runid + "\n")
            logs = logs if logs is not None else {"a": b"== a ==\n ok\n", "b": b"== b ==\n ok\n"}
            for j, body in logs.items():
                open(os.path.join(d, j + ".log"), "wb").write(body)
            if prog is None:
                prog = ["%s pass %s" % (j, hashlib.sha256(b).hexdigest()) for j, b in logs.items()]
            open(os.path.join(d, "progress"), "w").write("\n".join(prog) + "\n")

        def want(name, got, exp):
            if got != exp:
                bad.append("%s: %s, not %s" % (name, got, exp))

        setup()
        want("clean resume", carried(d, rid, "0"), ["a", "b"])
        # Controls: each must carry nothing, or less.
        want("dirty tree", carried(d, rid, "1"), [])
        want("another commit", carried(d, "beef 7ree --only a,b", "0"), [])
        want("other arguments", carried(d, "c0ffee 7ree --only a", "0"), [])
        setup()
        open(os.path.join(d, "a.log"), "ab").write(b"x")
        want("a log changed after its hash", carried(d, rid, "0"), ["b"])
        setup(prog=["a pass %s" % hashlib.sha256(b"== a ==\n ok\n").hexdigest(),
                    "b fail %s" % hashlib.sha256(b"== b ==\n ok\n").hexdigest()])
        want("a failed section", carried(d, rid, "0"), ["a"])
        setup(prog=["a pass %s" % hashlib.sha256(b"== a ==\n ok\n").hexdigest(),
                    "a fail %s" % hashlib.sha256(b"== a ==\n ok\n").hexdigest()])
        want("a section whose last record failed", carried(d, rid, "0"), [])
        os.remove(os.path.join(d, "progress"))
        want("no progress record", carried(d, rid, "0"), [])
    for b in bad:
        print("gate-resume selftest: " + b)
    print("gate-resume selftest: %s (8 cases, 7 controls)" % ("FAIL" if bad else "ok"))
    return 1 if bad else 0


if __name__ == "__main__":
    if sys.argv[1:] == ["--selftest"]:
        sys.exit(selftest())
    if len(sys.argv) != 4:
        print(__doc__, file=sys.stderr)
        sys.exit(2)
    print("\n".join(carried(*sys.argv[1:])))
