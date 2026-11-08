#!/usr/bin/env python3
"""Holds a ccv-skel --port-dump VCD (RA-34) to the block's generated port list.

    check-port-dump.py DUMP.vcd [DUMP.vcd ...]
    check-port-dump.py --selftest DUMP.vcd

The dump names a block's ports by its own rule (sim/skel/portdump.cpp), on
purpose apart from tools/gen-top.py's, as --dump-wiring restates the
instance names: a replay bench reads the dump by the names the RTL top uses,
so the two rules are checked against each other here. Every port of
rtl/top/ports/ccv_<blk>_ports.svh outside `ifdef` must be in the dump at its
width, and nothing else may be, except the common ports the skeleton does
not carry (the CSR fabric; not modelled, tied idle by a replay), which must
be absent. A dump must also hold at least one sample, with core_clk rising.

The values: ccv-skel ends every run drained (nothing outstanding), so at
each of the block's slots, in or out, the credits seen equal the valids
seen, one per message. That shows each valid and credit is the signal it
is named for, sampled every cycle: a credit read as the stall, a cycle
dropped or doubled, or a slot's signals crossed with another's leaves a slot
unbalanced. Which END of a repeated link a signal is sampled at is
portdump.cpp's to get right (its header says which); a drained run balances
at both.

--selftest: the dump passes, and each of a dropped port, a renamed port, a
wrong width and a port the block lacks is refused (negative controls)."""
import importlib.util
import os
import re
import sys

ROOT = os.path.dirname(os.path.dirname(os.path.abspath(__file__)))
sys.path.insert(0, os.path.join(ROOT, "tools"))


def gen_top():
    spec = importlib.util.spec_from_file_location("gen_top", os.path.join(ROOT, "tools", "gen-top.py"))
    m = importlib.util.module_from_spec(spec)
    cwd = os.getcwd()
    os.chdir(ROOT)
    try:
        spec.loader.exec_module(m)
    finally:
        os.chdir(cwd)
    return m


def expected(gt, btype):
    """{port: width} the dump must hold, and the ports it must not."""
    cwd = os.getcwd()
    os.chdir(ROOT)
    try:
        d, blocks, binst, chans, cinst, ninst, common = gt.load()
    finally:
        os.chdir(cwd)
    if btype not in ninst:
        raise SystemExit("check-port-dump: no block type %s" % btype)
    P = gt.block_ports(btype, chans, ninst, common, len(binst))
    want, absent = {}, set()
    carried = set(gt.FAB)
    common_names = {c[0] for c in common} | {c[3].get("port") for c in common if c[3].get("port")}
    for dr, w, name, guard, _doc, _typ, _m in P:
        if guard:
            continue
        if name in common_names and name not in carried and name not in ("core_clk", "rst_n"):
            absent.add(name)
            continue
        want[name] = w
    want.setdefault("core_clk", 1)
    want.setdefault("rst_n", 1)
    return want, absent


def read_dump(path):
    """(scope, {name: width}, rising edges, {valid/credit port: highs}):
    the dump's one scope, its vars, and how many cycles each 1-bit valid and
    credit port was high, as sampled before each rising edge."""
    scope, vars_, ids, rises = None, {}, {}, 0
    clk_id, clk = None, 0
    cur, highs = {}, {}
    with open(path) as f:
        header = True
        for line in f:
            line = line.strip()
            if header:
                if line.startswith("$scope"):
                    if scope is not None:
                        raise SystemExit("check-port-dump: %s: more than one scope" % path)
                    scope = line.split()[2]
                elif line.startswith("$var"):
                    p = line.split()
                    vars_[p[4]] = int(p[2])
                    if p[4] == "core_clk":
                        clk_id = p[3]
                    elif p[4].endswith(("_valid", "_credit")) and p[2] == "1":
                        ids.setdefault(p[3], []).append(p[4])
                        highs[p[4]] = 0
                elif line.startswith("$enddefinitions"):
                    header = False
                continue
            if clk_id and line in ("1" + clk_id, "0" + clk_id):
                v = int(line[0])
                if v == 1 and clk == 0:
                    rises += 1
                    for n, x in cur.items():
                        highs[n] += x
                clk = v
            elif line[:1] in ("0", "1") and line[1:] in ids:
                for n in ids[line[1:]]:
                    cur[n] = int(line[0])
    return scope, vars_, rises, highs


def balance(highs):
    """Slots whose valids and credits differ."""
    errs = []
    for n in sorted(highs):
        c = n[:-len("_valid")] + "_credit"
        if n.endswith("_valid") and c in highs:   # a channel slot, not kill_valid
            if highs[n] != highs.get(c, -1):
                errs.append("%s: %d valids, %d credits; a drained run credits each message"
                            % (n[:-len("_valid")], highs[n], highs.get(c, 0)))
    return errs


def judge(btype, vars_, want, absent):
    errs = []
    for n, w in sorted(want.items()):
        if n not in vars_:
            errs.append("missing port %s" % n)
        elif vars_[n] != w:
            errs.append("%s is %d bits; the port is %d" % (n, vars_[n], w))
    for n in sorted(set(vars_) - set(want)):
        errs.append("%s: %s" % (n, "not carried by the skeleton, so not dumped" if n in absent
                                else "no such port on ccv_%s" % btype))
    return errs


def check(path, gt):
    scope, vars_, rises, highs = read_dump(path)
    m = re.fullmatch(r"u_([a-z]+)(?:_\d\d)?", scope or "")
    if not m:
        return ["scope %r is not a block instance" % scope], None
    btype = m.group(1)
    want, absent = expected(gt, btype)
    errs = judge(btype, vars_, want, absent)
    if rises == 0:
        errs.append("no sample: core_clk never rises")
    errs += balance(highs)
    return errs, (btype, vars_, want, absent, scope, highs)


def main(argv):
    selftest = "--selftest" in argv
    paths = [a for a in argv if a != "--selftest"]
    if not paths:
        print(__doc__)
        return 2
    gt = gen_top()
    bad = 0
    for path in paths:
        errs, info = check(path, gt)
        name = info[4] if info else path
        if errs:
            bad += 1
            print("port dump %s: FAIL" % name)
            for e in errs[:10]:
                print("  " + e)
            continue
        print("port dump %s: PASS (%d ports, names and widths as ccv_%s's)"
              % (name, len(info[1]), info[0]))
        if not selftest:
            continue
        btype, vars_, want, absent, _, highs = info
        some = sorted(n for n in vars_ if n.endswith("_payload"))[0]
        controls = {
            "dropped port": {k: v for k, v in vars_.items() if k != some},
            "renamed port": {(k.replace("_payload", "_paylod") if k == some else k): v
                             for k, v in vars_.items()},
            "wrong width": dict(vars_, **{some: vars_[some] + 1}),
            "extra port": dict(vars_, **{"no_such_port": 1}),
        }
        if absent:
            controls["uncarried port dumped"] = dict(vars_, **{sorted(absent)[0]: 1})
        busy = sorted((n for n in highs if n.endswith("_valid") and highs[n]
                       and n[:-len("_valid")] + "_credit" in highs), key=lambda n: -highs[n])
        if busy:
            print("  busiest slot %s: %d messages" % (busy[0][:-len("_valid")], highs[busy[0]]))
            c = busy[0][:-len("_valid")] + "_credit"
            if balance(dict(highs, **{c: highs[c] - 1})):
                print("  control one credit short: refused PASS")
            else:
                bad += 1
                print("  control one credit short: accepted FAIL")
        else:
            bad += 1
            print("  no traffic at all: the balance check would be empty FAIL")
        for what, vs in controls.items():
            if judge(btype, vs, want, absent):
                print("  control %s: refused PASS" % what)
            else:
                bad += 1
                print("  control %s: accepted FAIL" % what)
    return 1 if bad else 0


if __name__ == "__main__":
    sys.exit(main(sys.argv[1:]))
