"""params/links.json: which hardening wrapper holds how many repeater stages
of each channel instance. The one parser, shared by tools/gen-skel.py (the C++
skeleton's link latency, the checker bank's parameters) and tools/gen-top.py
(the wrappers and the top), so the two realisations cannot read it apart.

The format is documented in the file itself. Every problem is collected and
reported together, by entry, rather than stopping at the first.
"""
import json
import os
import re

ROOT = os.path.dirname(os.path.dirname(os.path.abspath(__file__)))
DEFAULT = os.path.join(ROOT, "params", "links.json")
MAX_STAGES = 16
HOP = re.compile(r"^\s*([a-z][a-z0-9_]*)\s*:\s*(\d+)\s*$")


def path():
    """The links file in force: CCV_LINKS overrides the default, which is
    how a check builds the machine with a different split."""
    return os.environ.get("CCV_LINKS", DEFAULT)


def inst_name(btype, idx, ninst):
    """A block instance's (and its wrapper's) name, without the u_ prefix."""
    return btype if ninst == 1 else "%s_%02d" % (btype, idx)


def load(chans, cinst, binst, ninst, links_path=None):
    """Per channel instance (index into cinst): a list of hops
    [(wrapper index or None for EXTERNAL, stages)], src first, dst last.

    `binst` is [(type, n)]; a wrapper index is a block-instance index."""
    p = links_path or path()
    with open(p) as f:
        d = json.load(f)
    names = {inst_name(t, n, ninst[t]): k for k, (t, n) in enumerate(binst)}
    by_chan = {c["name"][4:]: c for c in chans}
    errs = []
    chosen = {}          # cinst index -> (specific?, entry no, hops)
    for no, e in enumerate(d.get("links", []), 1):
        where = "links[%d]" % no
        unknown = set(e) - {"channel", "copies", "route", "why"}
        if unknown:
            errs.append("%s: unknown key(s) %s" % (where, ", ".join(sorted(unknown))))
        c = by_chan.get(e.get("channel", ""))
        if c is None:
            errs.append("%s: no channel %r (names are without ccv_)"
                        % (where, e.get("channel")))
            continue
        where = "%s (%s)" % (where, e["channel"])
        cps = e.get("copies", "all")
        specific = cps != "all"
        if cps == "all":
            cps = list(range(c["ninst"]))
        elif not (isinstance(cps, list) and cps and
                  all(isinstance(x, int) and 0 <= x < c["ninst"] for x in cps)):
            errs.append("%s: copies must be \"all\" or a list of copies 0..%d"
                        % (where, c["ninst"] - 1))
            continue
        hops = []
        for h in str(e.get("route", "")).split(">"):
            m = HOP.match(h)
            if not m:
                errs.append("%s: hop %r is not 'wrapper:stages'" % (where, h.strip()))
                hops = None
                break
            hops.append((m.group(1), int(m.group(2))))
        if not hops:
            continue
        if len(hops) < 2 or hops[0][0] != "src" or hops[-1][0] != "dst":
            errs.append("%s: a route runs 'src:n > ... > dst:n'" % where)
            continue
        for w, s in hops:
            if s > MAX_STAGES:
                errs.append("%s: %s:%d is more than %d stages" % (where, w, s, MAX_STAGES))
        for copy in cps:
            ci = next(i for i, x in enumerate(cinst)
                      if x["chan"] is c and x["inst"] == copy)
            ends = (cinst[ci]["src"], cinst[ci]["dst"])
            resolved = []
            for j, (w, s) in enumerate(hops):
                if j == 0 or j == len(hops) - 1:
                    k = ends[0] if j == 0 else ends[1]
                    if k is None and s:
                        errs.append("%s: the %s end is EXTERNAL, which has no "
                                    "wrapper to hold stages" % (where, w))
                    resolved.append((k, s))
                    continue
                if w not in names:
                    errs.append("%s: no wrapper %r" % (where, w))
                    continue
                k = names[w]
                if k in ends or k in [r[0] for r in resolved]:
                    errs.append("%s copy %d: the route passes %s twice, or its own end"
                                % (where, copy, w))
                resolved.append((k, s))
            prev = chosen.get(ci)
            if prev and prev[0] == specific:
                errs.append("%s copy %d: also set by links[%d]"
                            % (where, copy, prev[1]))
            if prev is None or specific:
                chosen[ci] = (specific, no, resolved)
    out = {}
    for i, x in enumerate(cinst):
        out[i] = chosen[i][2] if i in chosen else [(x["src"], 0), (x["dst"], 0)]
    for c in chans:
        if not c["attrs"]["lockstep"]:
            continue
        totals = {sum(s for _, s in out[i]) for i, x in enumerate(cinst)
                  if x["chan"] is c}
        if len(totals) > 1:
            errs.append("%s is lockstep, but its copies' totals differ: %s"
                        % (c["name"][4:], sorted(totals)))
        # The checker bank watches each link where it leaves the source's
        # wrapper; lockstep copies must be level there too, or their checker
        # sees a skew that the receivers never do.
        heads = {out[i][0][1] for i, x in enumerate(cinst) if x["chan"] is c}
        if len(heads) > 1:
            errs.append("%s is lockstep, but its copies' src stages differ: %s"
                        % (c["name"][4:], sorted(heads)))
    if errs:
        raise SystemExit("%s: %d problem(s)\n  %s"
                         % (os.path.relpath(p, ROOT), len(errs), "\n  ".join(errs)))
    return out


def hard_reuse(block_types, links_path=None):
    """Block types whose wrappers are built as the minimal set of hard-reuse
    templates (params/links.json "hard_reuse")."""
    p = links_path or path()
    with open(p) as f:
        d = json.load(f)
    r = d.get("hard_reuse", [])
    bad = [t for t in r if t not in block_types] if isinstance(r, list) else [r]
    if bad:
        raise SystemExit("%s: hard_reuse names no block type: %s (types: %s)"
                         % (os.path.relpath(p, ROOT), ", ".join(map(str, bad)),
                            ", ".join(block_types)))
    return set(r)


def total(hops):
    return sum(s for _, s in hops)
