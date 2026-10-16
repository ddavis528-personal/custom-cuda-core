#!/usr/bin/env python3
"""build/ is made by one Verilator; another one starts it clean (OI-40).

    tools/build-stamp.py              clear build/ if another Verilator made it
    tools/build-stamp.py --selftest   the mechanism's own negative controls

Make tracks sources, not the tool that compiled them. After a Verilator
change the build directories under build/ still hold the old version's
generated C++, its objects and their dependency files, and two things
follow. If the old version's headers are gone (setup-toolchain.sh removes
Debian's package), every Verilator build stops on "No rule to make target
.../verilated.h", which is loud. If they are still there (a later version
under its own /opt prefix leaves the earlier one in place), make finds every
dependency, rebuilds nothing, and links objects the old version made, which
is not.

So build/.verilator records the `verilator --version` the directory was
made with. verify.sh runs this first: when the record differs, or there is
none, everything in build/ is removed except what no Verilator made (the
fetched compiler snapshot and the oracles generated from it), and the
record is rewritten.
"""
import os
import shutil
import subprocess
import sys
import tempfile

ROOT = os.path.dirname(os.path.dirname(os.path.abspath(__file__)))
BUILD = os.path.join(ROOT, "build")
STAMP = ".verilator"
# Made without Verilator, and slow to remake: the compiler snapshot is
# fetched and built by tools/fetch-compiler.sh, the oracles run from it.
KEEP = {"compiler", "compiler.git", "oracle"}


def version():
    try:
        out = subprocess.run(["verilator", "--version"], capture_output=True,
                             text=True).stdout
    except FileNotFoundError:
        return "none"
    return (out.splitlines() or ["none"])[0].strip()


def stamp(build, ver):
    """Clear `build` unless its record says `ver` made it. Returns what was
    removed."""
    p = os.path.join(build, STAMP)
    have = open(p).read().strip() if os.path.exists(p) else None
    if have == ver:
        return []
    gone = []
    if os.path.isdir(build):
        for f in sorted(os.listdir(build)):
            if f in KEEP or f == STAMP:
                continue
            path = os.path.join(build, f)
            if os.path.isdir(path) and not os.path.islink(path):
                shutil.rmtree(path)
            else:
                os.remove(path)
            gone.append(f)
    os.makedirs(build, exist_ok=True)
    open(p, "w").write(ver + "\n")
    return gone


def selftest():
    bad = []
    t = tempfile.mkdtemp()
    try:
        b = os.path.join(t, "build")

        def fill():
            for d in ("skel", "compiler", "oracle"):
                os.makedirs(os.path.join(b, d), exist_ok=True)
                open(os.path.join(b, d, "f"), "w").write(d)
            open(os.path.join(b, "top.log"), "w").write("x")

        fill()
        # 1. No record: whatever made build/ is unknown, so it is cleared,
        #    and the compiler snapshot and the oracles stay.
        stamp(b, "Verilator 1")
        left = sorted(os.listdir(b))
        if left != sorted(["compiler", "oracle", STAMP]):
            bad.append("a build/ with no record kept %s" % left)
        # 2. The same version clears nothing.
        fill()
        if stamp(b, "Verilator 1"):
            bad.append("the recorded version cleared build/")
        # 3. Another version clears what it made, keeps the rest.
        if stamp(b, "Verilator 2") != ["skel", "top.log"]:
            bad.append("another Verilator's build/ was not cleared")
        if not os.path.exists(os.path.join(b, "compiler", "f")):
            bad.append("the compiler snapshot was cleared with it")
        rec = os.path.join(b, STAMP)
        if not os.path.exists(rec) or open(rec).read().strip() != "Verilator 2":
            bad.append("the record was not rewritten")
    finally:
        shutil.rmtree(t)
    for x in bad:
        sys.stderr.write("build-stamp selftest: %s\n" % x)
    if not bad:
        print("  a build/ made by another Verilator is cleared (3 controls)")
    return 1 if bad else 0


def main():
    if "--selftest" in sys.argv:
        return selftest()
    ver = version()
    gone = stamp(BUILD, ver)
    if gone:
        print("  build/ was not made by %s: cleared %d entries" % (ver, len(gone)))
    else:
        print("  build/ made by %s" % ver)
    return 0


if __name__ == "__main__":
    sys.exit(main())
