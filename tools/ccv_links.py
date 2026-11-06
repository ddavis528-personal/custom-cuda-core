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
    # A latency-matched pair (A-58): arrival order must equal send order, so
    # the two links carry the same number of stages, whatever the floorplan.
    tot = {}
    for i, x in enumerate(cinst):
        tot.setdefault(x["chan"]["name"], set()).add(sum(s for _, s in out[i]))
    for c in chans:
        lm = c.get("latency_match")
        if lm and tot.get(c["name"]) != tot.get(lm):
            errs.append("%s is latency-matched with %s, but their totals differ: "
                        "%s against %s" % (c["name"][4:], lm[4:],
                                           sorted(tot.get(c["name"], ())),
                                           sorted(tot.get(lm, ()))))
    # A notice and its partner (OA-23): the lead is counted at the bank's
    # probe, where each leaves its source's wrapper, and promised at the
    # receiver, so the two links carry the same stages segment by segment.
    segs = {}
    for i, x in enumerate(cinst):
        segs.setdefault(x["chan"]["name"], set()).add(tuple(s for _, s in out[i]))
    for c in chans:
        no = c.get("notice_of")
        if no and segs.get(c["name"]) != segs.get(no["channel"]):
            errs.append("%s is a notice of %s, but their stages differ: %s against %s"
                        % (c["name"][4:], no["channel"][4:],
                           sorted(segs.get(c["name"], ())),
                           sorted(segs.get(no["channel"], ()))))
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


def rtl_tops(root=ROOT):
    """Block types whose top, ccv_<type>, is RTL written by hand: a module of
    that name anywhere under rtl/ but the generated top (rtl/top/), whose
    stubs and DPI shims are not RTL."""
    out = set()
    pat = re.compile(r"^\s*module\s+ccv_([a-z][a-z0-9]*)\b", re.M)
    for d, _, fs in os.walk(os.path.join(root, "rtl")):
        if os.path.relpath(d, root).split(os.sep)[:2] == ["rtl", "top"]:
            continue
        for f in fs:
            if f.endswith(".sv"):
                with open(os.path.join(d, f)) as fh:
                    out.update(pat.findall(fh.read()))
    return out


def no_flop(block_types, ends, links_path=None, root=ROOT):
    """The channel ends built without a boundary flop (params/links.json
    "no_flop"): a set of (block type, channel name without ccv_). Every other
    end's repeater holds one (BOUNDARY 1, rtl/phys/ccv_common_rpt.sv;
    Daniel, 2026-11-05). `ends` maps a block type to the channels it has an
    end of.

    An entry names a block type, or a list of them, and "channels": "all" or
    a list. "all" is refused for a type whose top is RTL: an RTL block that
    replaces a stub takes the wrapper's flops in that same change, never
    inheriting the stub's no-flop (AR's rev 287 (1)); an RTL block's no-flop
    end is named, and check-ngd holds it to 0 NGD at its wrapper."""
    p = links_path or path()
    with open(p) as f:
        d = json.load(f)
    errs, out, seen = [], set(), {}
    rtl = rtl_tops(root)
    for no, e in enumerate(d.get("no_flop", []), 1):
        where = "no_flop[%d]" % no
        unknown = set(e) - {"block", "channels", "except", "why"}
        if unknown:
            errs.append("%s: unknown key(s) %s" % (where, ", ".join(sorted(unknown))))
        if not e.get("why"):
            errs.append("%s: says no why" % where)
        bs = e.get("block")
        bs = [bs] if isinstance(bs, str) else bs
        if not (isinstance(bs, list) and bs):
            errs.append("%s: block must be a block type or a list of them" % where)
            continue
        for b in bs:
            if b not in block_types:
                errs.append("%s: no block type %r" % (where, b))
                continue
            chs = e.get("channels", "all")
            if chs == "all":
                if b in rtl:
                    errs.append("%s: %s's top is RTL, so its ends take the boundary flop; "
                                "name the no-flop channels, which check-ngd holds to 0 NGD "
                                "(AR's rev 287 (1))" % (where, b))
                chs = sorted(ends.get(b, ()))
            elif not (isinstance(chs, list) and chs):
                errs.append("%s: channels must be \"all\" or a list" % where)
                continue
            exc = e.get("except", [])
            if exc and e.get("channels", "all") != "all":
                errs.append("%s: \"except\" goes only with channels \"all\"" % where)
                exc = []
            for c in exc:
                if c not in ends.get(b, ()):
                    errs.append("%s: except: %s has no end of channel %r" % (where, b, c))
            chs = [c for c in chs if c not in exc]
            for c in chs:
                if c not in ends.get(b, ()):
                    errs.append("%s: %s has no end of channel %r" % (where, b, c))
                elif (b, c) in seen:
                    errs.append("%s: %s's end of %s is already no_flop[%d]"
                                % (where, b, c, seen[(b, c)]))
                else:
                    seen[(b, c)] = no
                    out.add((b, c))
    # A DPI block's sending end stays no-flop (AR's rev 309 (1)): its posedge
    # block already is its last register, so a boundary flop there is a
    # second register in series, a repeater stage, which neither rtStages()
    # nor params' derives would count. Such a stage belongs in "links", as
    # route 'src:1'. An RTL top's sending end may leave no_flop: there the
    # flop is the block's own last register, moved into its wrapper.
    _, sd = schema_ends(root)
    for b in block_types:
        if b in rtl:
            continue
        off = sorted(c for c in ends.get(b, ())
                     if sd.get(c, (None,))[0] == b and (b, c) not in out)
        if off:
            errs.append("%s is a DPI block, so its sending end of %s stays no_flop: its "
                        "posedge block is already its last register, and a flop there "
                        "would be a second in series, a link stage no derive counts; add "
                        "it to \"links\" as route 'src:1' (AR's rev 309 (1))"
                        % (b, ", ".join(off)))
    if errs:
        raise SystemExit("%s: %d problem(s)\n  %s"
                         % (os.path.relpath(p, ROOT), len(errs), "\n  ".join(errs)))
    return out


def schema_ends(root=ROOT):
    """Block type -> the channels (without ccv_) it has an end of, and
    channel -> (src type, dst type), from schema/interfaces.json."""
    with open(os.path.join(root, "schema", "interfaces.json")) as f:
        chans = json.load(f)["channels"]
    ends, sd = {}, {}
    for c in chans:
        sd[c["name"][4:]] = (c["src"], c["dst"])
        for t in (c["src"], c["dst"]):
            if t != "EXTERNAL":
                ends.setdefault(t, set()).add(c["name"][4:])
    return ends, sd


def bnd_rx(links_path=None, root=ROOT):
    """Channel (without ccv_) -> 1 when its receiving end holds the boundary
    flop, else 0 (AR's revs 300 and 301): the term a crossing adds to
    CCV_LAT_HOP + link_n, in params' derives and both hosts alike. A
    flopped SENDING end adds nothing forward: it replaces the sender's own
    output register (AR's rev 285)."""
    ends, sd = schema_ends(root)
    nf = no_flop(sorted(ends), ends, links_path, root)
    return {ch: int(d != "EXTERNAL" and (d, ch) not in nf)
            for ch, (s, d) in sd.items()}


def total(hops):
    return sum(s for _, s in hops)
