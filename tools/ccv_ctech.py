#!/usr/bin/env python3
"""The ctech views, and the files that make one up.

A ctech cell (docs/clock-gate.md) is a module with one port list and one
definition per VIEW: rtl/ctech/sim/ for simulation and formal, and
rtl/ctech/<library>/ per process library. Every build takes its view from
here, so which cells a design is built with is one choice in one place:

    python3 tools/ccv_ctech.py [VIEW] [--synth]

prints the view's files, one per line. VIEW defaults to $CCV_CTECH, then
`sim`. A library view also lists lib_cells.v, the port declarations of the
cells it instantiates, so the view elaborates here without the PDK; --synth
leaves those out, since in synthesis the library supplies the real cells.
"""
import os
import sys

ROOT = os.path.dirname(os.path.dirname(os.path.abspath(__file__)))
CTECH = os.path.join(ROOT, "rtl", "ctech")
SIM = "sim"


def views():
    return sorted(d for d in os.listdir(CTECH)
                  if os.path.isdir(os.path.join(CTECH, d)))


def cells(view):
    """The ccv_ctech_* modules a view defines, by file name."""
    d = os.path.join(CTECH, view)
    return sorted(f[:-3] for f in os.listdir(d)
                  if f.startswith("ccv_ctech_") and f.endswith(".sv"))


def files(view=None, synth=False, rel=False):
    view = view or os.environ.get("CCV_CTECH") or SIM
    if view not in views():
        sys.exit("ccv_ctech: no view %r (have: %s)" % (view, ", ".join(views())))
    d = os.path.join(CTECH, view)
    out = [os.path.join(d, c + ".sv") for c in cells(view)]
    lib = os.path.join(d, "lib_cells.v")
    if not synth and os.path.exists(lib):
        out.append(lib)
    return [os.path.relpath(f, ROOT) for f in out] if rel else out


def main():
    args = [a for a in sys.argv[1:] if not a.startswith("-")]
    if "--views" in sys.argv:
        print("\n".join(views()))
        return
    for f in files(args[0] if args else None, synth="--synth" in sys.argv,
                   rel=True):
        print(f)


if __name__ == "__main__":
    main()
