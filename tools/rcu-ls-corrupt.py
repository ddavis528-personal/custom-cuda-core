#!/usr/bin/env python3
"""Negative control corrupt-output for RI's RCU block lock-step
(test/rcu/lockstep.py), kept TI's so RI's files stay as RI wrote them
(TI's check-rcu-block.sh control, carried over when the gate adopted RI's
lock-step; RI-36, RI-37).

    tools/rcu-ls-corrupt.py [--build DIR] DUMP.vcd

The dump is replayed clean first and must be identical. Then the expected
value of one output is flipped at a cycle the clean run matched: the first
cycle at which the model drives a message's valid (not a credit, which
--credit-lead shifts, nor a wake, compared one-sided). The replay must
diverge at exactly that cycle, and on that port. Exit 0 when it does."""
import argparse
import contextlib
import importlib.util
import io
import os
import re
import sys

ROOT = os.path.dirname(os.path.dirname(os.path.abspath(__file__)))


def load_lockstep():
    spec = importlib.util.spec_from_file_location("lockstep", os.path.join(ROOT, "test/rcu/lockstep.py"))
    m = importlib.util.module_from_spec(spec)
    spec.loader.exec_module(m)
    return m


def replay(ls, build, dump):
    """lockstep.py's own main on one dump: (exit, stdout)."""
    out, argv = io.StringIO(), sys.argv
    sys.argv = ["lockstep.py", "--build", build, dump]
    try:
        with contextlib.redirect_stdout(out):
            rc = ls.main()
    except SystemExit as e:
        rc = e.code if isinstance(e.code, int) else 1
        out.write(str(e.code) + "\n")
    finally:
        sys.argv = argv
    return rc, out.getvalue()


def main():
    ap = argparse.ArgumentParser()
    ap.add_argument("--build", default=os.path.join(ROOT, "build/rcu-ls"))
    ap.add_argument("dump")
    a = ap.parse_args()
    ls = load_lockstep()
    rc, txt = replay(ls, a.build, a.dump)
    if rc or "IDENTICAL" not in txt:
        print("control corrupt-output: the clean replay is not identical:\n" + txt[-1500:])
        return 1
    dirs = ls.port_dirs()
    widths, snaps = ls.read_dump(a.dump, set(dirs))
    point = next(((t, n) for t, s in enumerate(snaps) for n in sorted(dirs)
                  if dirs[n] == "output" and n.endswith("_valid") and s.get(n)), None)
    if point is None:
        print("control corrupt-output: no valid output in %s to corrupt" % a.dump)
        return 1
    c, p = point
    read = ls.read_dump

    def corrupted(path, names):
        w, s = read(path, names)
        s[c] = dict(s[c], **{p: s[c].get(p, 0) ^ 1})
        return w, s

    ls.read_dump = corrupted
    rc, txt = replay(ls, a.build, a.dump)
    m = re.search(r": DIVERGES at cycle (\d+) ", txt)
    caught = rc != 0 and m and int(m.group(1)) == c and re.search(r"^  %s: rtl " % re.escape(p), txt, re.M)
    print("control corrupt-output (%s, %s at cycle %d): %s"
          % (os.path.basename(a.dump), p, c, "caught" if caught else "NOT CAUGHT"))
    if not caught:
        print(txt[-1500:])
    return 0 if caught else 1


if __name__ == "__main__":
    sys.exit(main())
