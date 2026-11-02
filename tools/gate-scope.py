#!/usr/bin/env python3
"""Which of the gate's sections a change needs (OI-95; DA, 2026-10-31).

    tools/gate-scope.py <base>       the sections for HEAD and the tree since <base>
    tools/gate-scope.py --paths p..  the sections for these paths
    tools/gate-scope.py --selftest   the map's negative controls

Prints `ALL` or the section names (tools/verify.sh's jobs), one line, then
one `# <path>: <sections>` line per changed path. verify.sh --changed <base>
runs those sections and the ones they wait on; the generators, the staleness
check, the toolchain, lint and the interface checks run every time
(ALWAYS). The map is a list of path prefixes, the first match wins. A path
it does not name, and anything under schema/ or params/ or the gate's own
tools, runs the whole gate: a gap in the map costs a gate's time, never a
check. The daily sweep's merge, every release and the nightly run the full
clean gate whatever this says.
"""
import os
import re
import subprocess
import sys

ROOT = os.path.dirname(os.path.dirname(os.path.abspath(__file__)))
ALL = "ALL"
ALWAYS = ["s1a", "s1d", "iface", "vlint"]
# Every section that reads RTL, its benches or its synthesis flow.
RTL = ["s1b", "xprop", "ctech", "cg", "ngd", "clockgate", "ooe_rtl", "top",
       "formal", "phys", "svh", "links"]
# First match wins: the more specific prefix comes first.
MAP = [
    # The sources of truth everything is generated from, and the gate itself.
    ("schema/", ALL),
    ("params/", ALL),
    ("tools/verify.sh", ALL),
    ("tools/gate-scope.py", ALL),
    ("tools/shim/", ALL),
    ("tools/genout.py", ALL),
    ("tools/check-ngd.py", ["ngd"]),
    ("tools/check-cg.py", ["cg", "ngd"]),          # check-ngd imports it
    ("tools/heavy-units.json", ["cg", "ngd"]),     # both read it, through check-cg
    ("tools/check-kernel.sh", ["kernel", "svh"]),
    ("tools/check-sv-hosted.sh", ["svh"]),
    ("tools/check-skel.sh", ["skel", "kernel", "svh", "top"]),
    ("tools/check-if.sh", ["iface"]),
    ("tools/check-ooe-unit.sh", ["ooe_unit"]),
    ("tools/check-formal.sh", ["formal"]),
    ("tools/check-phys.sh", ["phys"]),
    ("tools/check-links.sh", ["links"]),
    ("tools/check-top.sh", ["top"]),
    ("tools/check-xprop.sh", ["xprop"]),
    ("tools/check-ctech.sh", ["ctech"]),
    ("tools/check-clockgate.sh", ["clockgate"]),
    # Not the gate's: the push, sweep and release scripts and the summary.
    ("tools/gate-combine.py", ["iface"]),         # its selftest runs there
    ("tools/gate-export.sh", []),
    ("tools/gate-scratch.sh", []),
    ("tools/gate-push.sh", []),
    ("tools/gate-summary.py", []),
    ("tools/bg-run.sh", []),
    ("tools/daily-sweep.sh", []),
    ("tools/push-lib.sh", []),
    ("tools/make-release.sh", []),
    ("tools/setup-session-home.py", []),
    ("tools/", ALL),
    # The OOE model is the reference the OOE RTL is compared against.
    ("sim/ooe/", ["skel", "kernel", "ooe_unit", "ooe_rtl", "svh"]),
    ("sim/skel/", ["skel", "kernel", "svh", "top"]),
    ("sim/", ALL),
    ("rtl/lint/", ["s1d"] + RTL),
    ("rtl/", RTL),
    ("test/kernels/", ["kernel", "svh"]),
    ("test/ooe/", ["ooe_rtl", "cg", "ngd"]),
    ("test/cg/", ["cg"]),
    ("test/ngd/", ["ngd"]),
    ("test/neg/", ["iface"]),
    ("test/formal/", ["formal"]),
    ("test/phys/", ["phys", "cg"]),
    ("test/top/", ["top", "svh"]),
    ("test/", ALL),
    # Prose and the register's own files: no section reads them. The
    # generated docs are the staleness check's, which always runs.
    ("docs/", []),
    (".claude/", []),
    ("CLAUDE.md", []),
    ("README.md", []),
]


def jobs():
    """verify.sh's sections, from its ORDER, so the map cannot name one
    that does not exist."""
    s = open(os.path.join(ROOT, "tools", "verify.sh")).read()
    m = re.search(r'^ORDER="([^"]*)"', s, re.M)
    return m.group(1).split()


def scope_of(path):
    for pre, js in MAP:
        if path == pre or path.startswith(pre):
            return js
    return ALL


def scope(paths):
    """(ALL or a sorted list of sections, per-path detail)."""
    out, detail = set(ALWAYS), []
    whole = False
    for p in paths:
        js = scope_of(p)
        detail.append((p, js))
        if js == ALL:
            whole = True
        else:
            out |= set(js)
    if whole:
        return ALL, detail
    order = jobs()
    return [j for j in order if j in out], detail


def changed(base):
    git = ["git", "-C", ROOT]
    r = subprocess.run(git + ["diff", "--name-only", "--no-renames", base + "...HEAD"],
                       capture_output=True, text=True)
    if r.returncode:
        sys.exit("gate-scope: cannot diff against %s: %s" % (base, r.stderr.strip()))
    paths = set(r.stdout.split())
    # The tree too: verify.sh checks what is on disk, not only what is committed.
    st = subprocess.run(git + ["status", "--porcelain", "--no-renames", "-uall"],
                        capture_output=True, text=True).stdout
    paths |= {l[3:] for l in st.splitlines() if len(l) > 3}
    return sorted(paths)


def selftest():
    bad = []
    order = jobs()

    def expect(c, what):
        if not c:
            bad.append(what)
    for pre, js in MAP:
        if js != ALL:
            for j in js:
                expect(j in order, "the map names a section verify.sh has not: %s (%s)" % (j, pre))
    for j in ALWAYS + RTL:
        expect(j in order, "ALWAYS or RTL names a section verify.sh has not: %s" % j)
    # Each a control: the map must answer ALL here, or the named sections.
    expect(scope(["schema/interfaces.json"])[0] == ALL, "a schema change was scoped")
    expect(scope(["params/ccv_params.json"])[0] == ALL, "a params change was scoped")
    expect(scope(["somewhere/new.txt"])[0] == ALL, "a path the map does not name was scoped")
    expect(scope(["tools/verify.sh"])[0] == ALL, "a change to the gate itself was scoped")
    expect(scope(["tools/new-check.py"])[0] == ALL, "a new tool was scoped")
    expect(scope(["test/new/x.sv"])[0] == ALL, "a new test directory was scoped")
    expect(scope(["sim/src/x.cpp"])[0] == ALL, "ccv-sim's side of sim/ was scoped")
    s, _ = scope(["rtl/ooe/ooe_rob.sv"])
    expect(s != ALL and {"cg", "ngd", "ooe_rtl", "svh", "top"} <= set(s),
           "an OOE RTL change skips a section that reads it: %s" % s)
    s, _ = scope(["sim/ooe/ooe_core.cpp"])
    expect(s != ALL and {"kernel", "ooe_unit", "ooe_rtl", "skel", "svh"} <= set(s),
           "an OOE model change skips a section that reads it: %s" % s)
    s, _ = scope(["docs/roadmap.md"])
    expect(s == [j for j in order if j in ALWAYS], "a prose change ran more than ALWAYS: %s" % s)
    s, _ = scope(["docs/roadmap.md", "params/links.json"])
    expect(s == ALL, "ALL lost to a scoped path beside it")
    for x in bad:
        sys.stderr.write("gate-scope selftest: %s\n" % x)
    if not bad:
        print("  gate scope: every section named exists; schema, params, the gate, "
              "unmapped paths run all; RTL and model changes reach their sections")
    return 1 if bad else 0


def main():
    a = sys.argv[1:]
    if a == ["--selftest"]:
        return selftest()
    if a[:1] == ["--paths"]:
        paths = a[1:]
    elif len(a) == 1:
        paths = changed(a[0])
    else:
        sys.exit(__doc__)
    s, detail = scope(paths)
    print(ALL if s == ALL else " ".join(s))
    for p, js in detail:
        print("# %s: %s" % (p, js if js == ALL else " ".join(js) or "(none)"))
    return 0


if __name__ == "__main__":
    sys.exit(main())
