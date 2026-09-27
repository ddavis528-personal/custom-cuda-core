#!/usr/bin/env python3
"""Compare two CCV event traces as the same run, whatever the host.

  tools/compare-traces.py A.ccvtrace B.ccvtrace

Equal means: the same schema hash, and the same MULTISET of records within
every cycle. Order within a cycle is not compared -- it is the order the host
happened to call emitters in (the C++ loop runs blocks by index, a simulator
runs always-blocks as it schedules them), and nothing in the schema gives it
meaning. Order ACROSS cycles is compared, because a record's cycle is part of
it: an event one cycle late is a different record, and is reported as a
difference in both cycles.

Prints one line, `TRACES records=N equal=yes|no byte_identical=yes|no`, and on
a difference the first cycle that differs with what only each side has.
Exit 0 if equal, 1 if not.
"""
import collections
import os
import sys

sys.path.insert(0, os.path.dirname(os.path.abspath(__file__)))
from trace2perfetto import read_trace  # noqa: E402


def main():
    if len(sys.argv) != 3:
        sys.exit(__doc__)
    a, b = sys.argv[1], sys.argv[2]
    ha, ra = read_trace(a)
    hb, rb = read_trace(b)
    same_bytes = open(a, "rb").read() == open(b, "rb").read()
    if ha["hash"] != hb["hash"]:
        print("TRACES records=%d/%d equal=no byte_identical=no (schema hash %s vs %s)"
              % (len(ra), len(rb), ha["hash"], hb["hash"]))
        return 1
    # A record is (cycle, uid, event, unit, a, b, c): cycle first.
    ca = collections.defaultdict(collections.Counter)
    cb = collections.defaultdict(collections.Counter)
    for r in ra:
        ca[r[0]][r] += 1
    for r in rb:
        cb[r[0]][r] += 1
    bad = sorted(c for c in set(ca) | set(cb) if ca[c] != cb[c])
    print("TRACES records=%d/%d equal=%s byte_identical=%s differing_cycles=%d"
          % (len(ra), len(rb), "no" if bad else "yes",
             "yes" if same_bytes else "no", len(bad)))
    if bad:
        c = bad[0]
        only_a = ca[c] - cb[c]
        only_b = cb[c] - ca[c]
        print("  first differing cycle %d: %d record(s) only in %s, %d only in %s"
              % (c, sum(only_a.values()), a, sum(only_b.values()), b))
        for r in list(only_a)[:3]:
            print("    <", r)
        for r in list(only_b)[:3]:
            print("    >", r)
        return 1
    return 0


if __name__ == "__main__":
    sys.exit(main())
