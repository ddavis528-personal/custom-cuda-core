#!/usr/bin/env python3
"""Local clock gating: form, enable depth and DCGE (Daniel, 2026-10-16).

    tools/check-cg.py              every unit, the waivers, the ratchet
    tools/check-cg.py --selftest   the negative controls (test/cg/fixtures/)
    tools/check-cg.py --unit NAME  one unit, every group listed

The rules are docs/rtl-coding-style.md, "Local clock gating":

  CG-1  form: every non-reset statement of an always_ff is `if (<enable>)`
        with no `else`, the enable a named signal. A register written outside
        one is accepted by measurement when, clocked every cycle, it changes
        in at least CCV_DCGE_MIN_PCT of non-reset cycles in every scenario:
        a gate would save it little.
  CG-2  enable depth: every enable group's enable cone is at most
        CCV_NGD_CG_EN NGD, and so is every explicit ICG's.
  CG-3  DCGE: every enable group changes value in at least CCV_DCGE_MIN_PCT
        of the cycles its clock is enabled, in each of the idle, medium and
        high scenarios. A scenario that never enables the group passes.

An enable group is what synthesis would gate: the flops Yosys infers one
enable for. CG-2 and CG-3 measure the netlist, not the source, so they hold
whichever way the RTL is written. CG-1 is what makes the enable deliberate.

A unit is one module at one parameterization, with a bench that runs the
three scenarios and dumps a VCD (test/**/cg-units.json). The bench's port
trace is replayed into the unit's netlist, which must reproduce the bench's
outputs on every cycle, so what is measured is what the bench ran.

Exceptions: rtl/cg-waivers.json, one entry per (module, rule, register),
each with a reason; a waiver that excuses nothing is refused. The ratchet,
rtl/cg-ratchet.json, holds the modules written before the rule. It can only
shrink: an entry outside RATCHET_BASELINE is refused, and so is a listed
module with nothing left to excuse.
"""
import argparse
import collections
import glob
import importlib.util
import json
import os
import re
import shlex
import shutil
import subprocess
import sys

ROOT = os.path.dirname(os.path.dirname(os.path.abspath(__file__)))
BUILD = os.path.join(ROOT, "build", "cg")
GENLIB = os.path.join(ROOT, "test", "ooe", "ngd.genlib")
SCENARIOS = ("idle", "medium", "high")
# A scenario shorter than this says little about an enable's quality.
MIN_CYCLES = 1000
WAIVERS = os.path.join(ROOT, "rtl", "cg-waivers.json")
RATCHET = os.path.join(ROOT, "rtl", "cg-ratchet.json")
# The modules that existed, non-compliant, when the rule was made
# (2026-10-16), ooe_confirm and ooe_rs then on OI's branch. Never add to
# this: a module written since meets the rule or carries waivers.
RATCHET_BASELINE = {"ooe_age", "ooe_decq", "ooe_freelist", "ooe_wake",
                    "ooe_confirm", "ooe_rs"}
# Where design RTL lives, and what in it is not design: generated files,
# the top level (instances and nets only), the ctech views, lint fixtures.
DESIGN_SKIP = ("rtl/include/", "rtl/generated/", "rtl/top/", "rtl/ctech/",
               "rtl/lint/")
ICG = "ccv_common_ctech_icg"

_spec = importlib.util.spec_from_file_location(
    "lint_rtl", os.path.join(ROOT, "tools", "lint-rtl.py"))
lint = importlib.util.module_from_spec(_spec)
_spec.loader.exec_module(lint)


def param(name):
    for p in json.load(open(os.path.join(ROOT, "params", "ccv_params.json")))["params"]:
        if p["name"] == name:
            return p["value"]
    raise KeyError(name)


NGD_MAX = float(param("CCV_NGD_CG_EN"))
DCGE_MIN = float(param("CCV_DCGE_MIN_PCT"))


def run(cmd, cwd=ROOT, **kw):
    return subprocess.run(cmd, cwd=cwd, shell=isinstance(cmd, str),
                          capture_output=True, text=True, **kw)


# == CG-1: the form, from the source ==========================================

TOK_RE = re.compile(r"\s*(`?[A-Za-z_][\w$]*|\d+'[sS]?[bBoOdDhH][0-9a-fA-FxXzZ_?]+|"
                    r"'[01xXzZ]|\d[\d_]*|<=|==|!=|===|!==|&&|\|\||<<|>>|>=|"
                    r"\+:|-:|::|.)", re.S)


def tokens(text):
    out = []
    for m in TOK_RE.finditer(text):
        t = m.group(1)
        if not t.isspace():
            out.append(t)
    return out


class Parser:
    """The statement subset an always_ff body is written in: begin/end,
    if/else, for, case, assignments and macro calls. Anything it cannot read
    is an assignment-shaped statement, which CG-1 then reports: unreadable
    is never compliant."""

    def __init__(self, toks):
        self.t, self.i = toks, 0

    def peek(self, k=0):
        j = self.i + k
        return self.t[j] if j < len(self.t) else None

    def take(self):
        tok = self.peek()
        self.i += 1
        return tok

    def group(self):
        """The text of a parenthesised group starting at the current '('."""
        assert self.take() == "("
        depth, out = 1, []
        while self.peek() is not None:
            tok = self.take()
            if tok == "(":
                depth += 1
            elif tok == ")":
                depth -= 1
                if depth == 0:
                    break
            out.append(tok)
        return " ".join(out)

    def stmt(self):
        tok = self.peek()
        if tok is None:
            return ("empty",)
        if tok in ("unique", "priority", "unique0"):
            self.take()
            return self.stmt()
        if tok == "begin":
            self.take()
            if self.peek() == ":":
                self.take(); self.take()
            body = []
            while self.peek() not in (None, "end"):
                body.append(self.stmt())
            self.take()
            if self.peek() == ":":
                self.take(); self.take()
            return ("block", body)
        if tok == "if":
            self.take()
            cond = self.group() if self.peek() == "(" else ""
            then = self.stmt()
            other = None
            if self.peek() == "else":
                self.take()
                other = self.stmt()
            return ("if", cond, then, other)
        if tok == "for":
            self.take()
            if self.peek() == "(":
                self.group()
            return ("for", self.stmt())
        if tok in ("case", "casez", "casex"):
            self.take()
            depth, regs = 1, set()
            start = self.i
            while self.peek() is not None and depth:
                t = self.take()
                if t in ("case", "casez", "casex"):
                    depth += 1
                elif t == "endcase":
                    depth -= 1
            regs = assigned(self.t[start:self.i])
            return ("case", regs)
        if tok.startswith("`"):
            self.take()
            if self.peek() == "(":
                self.group()
            if self.peek() == ";":
                self.take()
            return ("macro",)
        if tok == ";":
            self.take()
            return ("empty",)
        start, depth = self.i, 0
        while self.peek() is not None:
            t = self.take()
            if t in ("(", "[", "{"):
                depth += 1
            elif t in (")", "]", "}"):
                depth -= 1
            elif t == ";" and depth <= 0:
                break
        return ("assign", assigned(self.t[start:self.i]))


def assigned(toks):
    """Registers a token run assigns with `<=`: in each statement (split at
    `;` outside brackets), the target of its first `<=` outside brackets, a
    name with any selects and fields, or every name of a `{...}` target.
    A `<=` inside an expression is a comparison, not an assignment."""
    regs, seg, depth = set(), [], 0
    ident = re.compile(r"[A-Za-z_]\w*$")
    for t in toks + [";"]:
        if t in ("(", "[", "{"):
            depth += 1
        elif t in (")", "]", "}"):
            depth -= 1
        if t == ";" and depth <= 0:
            depth = 0
            k = next((n for n, (x, d) in enumerate(seg) if x == "<=" and d == 0), None)
            if k is not None:
                j = k - 1
                while j >= 0:
                    x, d0 = seg[j]
                    if x == "]":                        # a select: skip it
                        while j >= 0 and not (seg[j][0] == "[" and seg[j][1] == d0):
                            j -= 1
                        j -= 1
                    elif x == "}":                      # a concatenation
                        e = j
                        while j >= 0 and not (seg[j][0] == "{" and seg[j][1] == d0):
                            j -= 1
                        regs |= {y for y, _ in seg[j:e] if ident.match(y)}
                        break
                    elif ident.match(x) and j >= 1 and seg[j - 1][0] == ".":
                        j -= 2                          # a field: its struct
                    else:
                        if ident.match(x):
                            regs.add(x)
                        break
            seg = []
            continue
        # A bracket's own depth is the depth outside it.
        seg.append((t, depth - (1 if t in ("(", "[", "{") else 0)))
    return regs


def regs_of(node):
    kind = node[0]
    if kind == "assign" or kind == "case":
        return set(node[1])
    if kind == "block":
        out = set()
        for s in node[1]:
            out |= regs_of(s)
        return out
    if kind == "if":
        out = regs_of(node[2])
        if node[3] is not None:
            out |= regs_of(node[3])
        return out
    if kind == "for":
        return regs_of(node[1])
    return set()


NAMED_RE = re.compile(r"^[!~]?\s*[A-Za-z_]\w*(\s*\[[^\[\]]*\])*(\s*\.\s*\w+)*$")
RESET_RE = re.compile(r"`CCV_RST|\b(rst\w*|\w*_rst(_\w*)?|reset\w*)\b")


def named(cond):
    return bool(NAMED_RE.match(cond.replace(" ", "")))


def nonreset(node, out):
    """Each statement of the non-reset part must be an enable `if`."""
    kind = node[0]
    if kind == "block":
        for s in node[1]:
            nonreset(s, out)
    elif kind == "for":
        nonreset(node[1], out)
    elif kind == "if":
        _, cond, _, other = node
        if other is not None:
            out.append(("an enable `if` has an `else`, so the register "
                        "is written on both paths", regs_of(node)))
        elif not named(cond):
            out.append(("the enable is an expression (%s), not a named signal"
                        % cond.replace(" ", ""), regs_of(node)))
    elif kind in ("assign", "case"):
        if node[1]:
            out.append(("written every cycle, under no enable", set(node[1])))


def form_findings(text, first=1):
    """(line, why, registers) for each CG-1 violation in comment-stripped
    module text that starts on line `first` of its file."""
    out = []
    for kind, _, body, line, _ in lint.always_blocks(text):
        line += first - 1
        if kind != "ff":
            continue
        toks = tokens(body)
        # Past the event control.
        i = 0
        if toks and toks[0] == "@":
            i = 1
            if i < len(toks) and toks[i] == "(":
                depth = 0
                while i < len(toks):
                    if toks[i] == "(":
                        depth += 1
                    elif toks[i] == ")":
                        depth -= 1
                        if depth == 0:
                            i += 1
                            break
                    i += 1
        p = Parser(toks[i:])
        top = p.stmt()
        items = [s for s in top[1] if s[0] not in ("macro", "empty")] \
            if top[0] == "block" else [top]
        bad = []
        if len(items) == 1 and items[0][0] == "if" and RESET_RE.search(items[0][1]):
            if items[0][3] is not None:
                nonreset(items[0][3], bad)
        else:
            for s in items:
                nonreset(s, bad)
        for why, regs in bad:
            out.append((line, why, sorted(regs)))
    return out


def design_modules():
    """{module: (rel path, comment-stripped text, first line)} for every design module
    with an always_ff, less what is not silicon: checkers (CCV_CHECK only)
    and ctech cells."""
    _, by_letter = lint.load_blocks()
    blocknames = {b["name"] for b in by_letter.values()}
    out = {}
    for path in sorted(glob.glob(os.path.join(ROOT, "rtl", "**", "*.sv"), recursive=True)):
        rel = os.path.relpath(path, ROOT)
        if rel.startswith(DESIGN_SKIP):
            continue
        src = lint.strip_comments(open(path).read())
        for s, e, name, first in lint.module_spans(src):
            text = src[s:e]
            if not re.search(r"\balways_ff\b", text):
                continue
            if lint.classify(name, blocknames).typ in ("chk", "ctech"):
                continue
            out[name] = (rel, text, first)
    return out


# == The netlist ===============================================================

# The flop cells this covers, each spelled out: an asynchronous reset or a
# latch matches none of them and stops the run.
FLOP_RE = re.compile(r"^\$_(?:(DFF)_([NP])()()|(DFFE)_([NP][NP])()()|(SDFF)_([NP][NP])([01])()|"
                     r"(SDFFE|SDFFCE)_([NP][NP])([01])([NP]))_$")
GATES = {
    "$_BUF_": ("A",), "$_NOT_": ("A",),
    "$_AND_": ("A", "B"), "$_NAND_": ("A", "B"), "$_OR_": ("A", "B"),
    "$_NOR_": ("A", "B"), "$_XOR_": ("A", "B"), "$_XNOR_": ("A", "B"),
    "$_ANDNOT_": ("A", "B"), "$_ORNOT_": ("A", "B"),
    "$_MUX_": ("A", "B", "S"), "$_NMUX_": ("A", "B", "S"),
    "$_AOI3_": ("A", "B", "C"), "$_OAI3_": ("A", "B", "C"),
    "$_AOI4_": ("A", "B", "C", "D"), "$_OAI4_": ("A", "B", "C", "D"),
}
FUNC = {
    "$_BUF_": lambda a: a, "$_NOT_": lambda a: 1 - a,
    "$_AND_": lambda a, b: a & b, "$_NAND_": lambda a, b: 1 - (a & b),
    "$_OR_": lambda a, b: a | b, "$_NOR_": lambda a, b: 1 - (a | b),
    "$_XOR_": lambda a, b: a ^ b, "$_XNOR_": lambda a, b: 1 - (a ^ b),
    "$_ANDNOT_": lambda a, b: a & (1 - b), "$_ORNOT_": lambda a, b: a | (1 - b),
    "$_MUX_": lambda a, b, s: b if s else a,
    "$_NMUX_": lambda a, b, s: 1 - (b if s else a),
    "$_AOI3_": lambda a, b, c: 1 - ((a & b) | c),
    "$_OAI3_": lambda a, b, c: 1 - ((a | b) & c),
    "$_AOI4_": lambda a, b, c, d: 1 - ((a & b) | (c & d)),
    "$_OAI4_": lambda a, b, c, d: 1 - ((a | b) & (c | d)),
}


class Group:
    """Flops one clock enable drives. kind: 'E' (enable), 'ER' (enable,
    or a synchronous reset that overrides it), or 'ungated'."""

    def __init__(self, key, kind, e, epol, r, rpol):
        self.key, self.kind = key, kind
        self.e, self.epol, self.r, self.rpol = e, epol, r, rpol
        self.q = []          # Q nets
        self.depth = 0.0
        self.name = ""
        self.regs = set()    # full register names with bits in the group
        self.en_name = ""


class Netlist:
    def __init__(self, path, top):
        d = json.load(open(path))
        m = d["modules"][top]
        self.ports = m["ports"]
        self.cells = m["cells"]
        self.alias = collections.defaultdict(list)    # net -> [(name, idx)]
        for name, nn in m["netnames"].items():
            if nn["hide_name"] or "$" in name:
                continue
            for i, b in enumerate(nn["bits"]):
                if isinstance(b, int):
                    self.alias[b].append((name, i))
        self.driver = {}
        self.flops, self.icgs, self.groups = [], [], {}
        for cname, c in self.cells.items():
            t = c["type"]
            con = c["connections"]
            if t in GATES:
                self.driver[con["Y"][0]] = (t, [con[p][0] for p in GATES[t]])
                continue
            if t == ICG:
                self.icgs.append((cname, con["en"][0]))
                continue
            fm = FLOP_RE.match(t)
            if fm:
                g = [x for x in fm.groups()]
                k0 = next(n for n in range(0, 16, 4) if g[n])
                fm = g[k0:k0 + 4]
            if not fm:
                if t.startswith("$"):
                    raise SystemExit("check-cg: %s: cell %s is a %s, which the "
                                     "clock-gating rules do not cover (a latch or an "
                                     "asynchronous reset)" % (path, cname, t))
                continue
            kind, pols = fm[0], fm[1]
            # Pin polarity letters: C, then R (SDFF*) and E, as Yosys names them.
            if kind == "DFF":
                k, e, ep, r, rp = "ungated", None, None, None, None
            elif kind == "DFFE":
                k, e, ep, r, rp = "E", con["E"][0], pols[1] == "P", None, None
            elif kind == "SDFF":
                k, e, ep, r, rp = "ungated", None, None, None, None
            else:
                ep = fm[3] == "P"
                k = "ER" if kind == "SDFFE" else "E"
                e, r, rp = con["E"][0], con["R"][0], pols[1] == "P"
                if kind == "SDFFCE":
                    r, rp = None, None
            q = con["Q"][0]
            self.flops.append(q)
            if k == "ungated":
                key = ("ungated", self.best(q)[0])
            else:
                key = (k, e, ep, r, rp)
            g = self.groups.get(key)
            if g is None:
                g = self.groups[key] = Group(key, k, e, ep, r, rp)
            g.q.append(q)
        for g in self.groups.values():
            byreg = collections.defaultdict(list)
            for q in g.q:
                n, i = self.best(q)
                byreg[n].append(i)
                g.regs |= {a[0] for a in self.alias[q]}
            g.name = ", ".join("%s%s" % (n, ranges(ix)) for n, ix in sorted(byreg.items()))
            if g.kind != "ungated":
                g.en_name = self.net_name(g.e, g.epol)
                if g.kind == "ER":
                    g.en_name += " | " + self.net_name(g.r, g.rpol)

    def best(self, net):
        al = self.alias.get(net)
        if not al:
            return ("<net %s>" % net, 0)
        # The register, not a bus it feeds: the narrowest name, then the
        # shortest, and a port last.
        ports = set(self.ports)
        return sorted(al, key=lambda a: (a[0] in ports, self.width(a[0]), len(a[0]), a))[0]

    def net_name(self, net, pol):
        if isinstance(net, str):
            return net
        n, i = self.best(net)
        w = None
        for name, idx in self.alias.get(net, []):
            if name == n:
                w = idx
        txt = n if not n.startswith("<") else "<logic>"
        if not n.startswith("<") and self.width(n) > 1:
            txt += "[%d]" % w
        return txt if pol else "!" + txt

    def width(self, name):
        if not hasattr(self, "_width"):
            self._width = collections.Counter()
            for al in self.alias.values():
                for n, _ in al:
                    self._width[n] += 1
        return self._width[name]

    def inputs(self):
        return {n: p["bits"] for n, p in self.ports.items() if p["direction"] == "input"}

    def outputs(self):
        return {n: p["bits"] for n, p in self.ports.items() if p["direction"] == "output"}


def ranges(ix):
    ix = sorted(set(ix))
    if len(ix) == 1 and ix[0] == 0:
        return ""
    out, s = [], ix[0]
    for a, b in zip(ix, ix[1:] + [None]):
        if b != a + 1:
            out.append("%d" % a if a == s else "%d:%d" % (a, s))
            s = b
    return "[" + ",".join(reversed(out)) + "]"


# == CG-2: enable depth ========================================================

def cone_blif(nl, target, path):
    """The fan-in cone of one net, as a BLIF ABC can map. Returns False when
    the net is a flop, an input or a constant: depth 0."""
    if not isinstance(target, int) or target not in nl.driver:
        return False
    gates, leaves, seen, stack = [], set(), set(), [target]
    while stack:
        n = stack.pop()
        if n in seen:
            continue
        seen.add(n)
        if isinstance(n, int) and n in nl.driver:
            t, ins = nl.driver[n]
            gates.append((n, t, ins))
            stack.extend(ins)
        elif isinstance(n, int):
            leaves.add(n)

    def nm(x):
        return "n%d" % x if isinstance(x, int) else ("c1" if x == "1" else "c0")
    lines = [".model cone", ".inputs " + " ".join(nm(x) for x in sorted(leaves)) if leaves
             else ".inputs", ".outputs " + nm(target), ".names c0", ".names c1", "1"]
    for n, t, ins in gates:
        lines.append(".names " + " ".join(nm(x) for x in ins) + " " + nm(n))
        k = len(ins)
        for v in range(1 << k):
            bits = [(v >> (k - 1 - j)) & 1 for j in range(k)]
            if FUNC[t](*bits):
                lines.append("".join(str(b) for b in bits) + " 1")
    lines.append(".end")
    open(path, "w").write("\n".join(lines) + "\n")
    return True


def depths(nl, nets, work):
    """{net: NGD} for each net: one ABC run, each cone mapped in turn."""
    out, todo = {}, []
    for k, n in enumerate(sorted(set(nets), key=str)):
        f = os.path.join(work, "cone%d.blif" % k)
        if cone_blif(nl, n, f):
            todo.append((n, f))
        else:
            out[n] = 0.0
    if todo:
        script = "read_library %s; " % GENLIB + " ".join(
            "read_blif %s; strash; dch; map; print_stats;" % f for _, f in todo)
        r = run(["yosys-abc", "-c", script])
        vals = re.findall(r"delay\s*=\s*([0-9.]+)", r.stdout)
        if len(vals) != len(todo):
            raise SystemExit("check-cg: ABC returned %d depths for %d cones:\n%s"
                             % (len(vals), len(todo), r.stdout[-2000:]))
        for (n, _), v in zip(todo, vals):
            out[n] = float(v)
    return out


# == CG-3: the replay ===========================================================

def read_vcd(path, scope, ports, clock):
    """Each port's value just before every rising edge of `clock`, read from
    the VCD's `scope` (matched as a suffix of the scope path)."""
    ids, want = {}, set(ports) | {clock}
    path_stack, snaps = [], []
    cur, start = {}, {}
    with open(path) as f:
        header = True
        for line in f:
            line = line.strip()
            if not line:
                continue
            if header:
                if line.startswith("$scope"):
                    path_stack.append(line.split()[2])
                elif line.startswith("$upscope"):
                    path_stack.pop()
                elif line.startswith("$var"):
                    parts = line.split()
                    name = parts[4]
                    sp = ".".join(path_stack)
                    if (sp == scope or sp.endswith("." + scope)) and name in want:
                        ids.setdefault(parts[3], []).append(name)
                elif line.startswith("$enddefinitions"):
                    header = False
                    if clock not in {n for v in ids.values() for n in v}:
                        raise SystemExit("check-cg: %s: no clock %s in scope %s"
                                         % (path, clock, scope))
                continue
            c = line[0]
            if c == "#":
                start = dict(cur)
                continue
            if c == "$":
                continue
            if c in "bB":
                val, vid = line[1:].split()
            elif c in "01xXzZ":
                val, vid = c, line[1:]
            else:
                continue
            names = ids.get(vid)
            if not names:
                continue
            v = int(re.sub(r"[xXzZ]", "0", val), 2)
            for name in names:
                if name == clock and v == 1 and cur.get(clock, 0) == 0 and start:
                    snaps.append(dict(start))
                cur[name] = v
    missing = set(ports) - {n for v in ids.values() for n in v}
    if missing:
        raise SystemExit("check-cg: %s: ports %s not in scope %s"
                         % (path, ", ".join(sorted(missing)), scope))
    return snaps


def pack(snap, names, widths):
    v, off = 0, 0
    for n in names:
        v |= (snap.get(n, 0) & ((1 << widths[n]) - 1)) << off
        off += widths[n]
    return v


class Unit:
    def __init__(self, spec, src):
        self.spec, self.src = spec, src
        self.name, self.module = spec["name"], spec["module"]
        self.dir = os.path.join(BUILD, self.name)
        self.nl = None
        self.data = {}       # scenario -> dict(stats)
        self.errors = []     # measurement failures: the unit is not measured

    # -- synthesis ----------------------------------------------------------
    def synth(self):
        os.makedirs(self.dir, exist_ok=True)
        s = self.spec
        defs = " ".join("-D%s" % d for d in s.get("defines", []))
        files = ["rtl/ccv_assert_pkg.sv"] + s["files"]
        cmds = ["read_verilog -sv -formal %s -Irtl/include -Irtl/generated %s"
                % (defs, " ".join(files))]
        for bb in sorted(s.get("blackbox", {})):
            cmds.append("read_verilog -sv -lib -Irtl/include -Irtl/generated %s"
                        % s["blackbox"][bb])
        if s.get("params"):
            cmds.append("chparam %s %s" % (" ".join(
                "-set %s %s" % (k, v) for k, v in sorted(s["params"].items())), self.module))
        cmds += ["hierarchy -top %s" % self.module, "chformal -remove",
                 "synth -flatten -top %s" % self.module,
                 "write_json %s" % os.path.join(self.dir, "net.json")]
        r = run(["yosys", "-q", "-p", "; ".join(cmds)])
        if r.returncode:
            raise SystemExit("check-cg: unit %s: yosys failed:\n%s"
                             % (self.name, (r.stdout + r.stderr)[-2000:]))
        self.nl = Netlist(os.path.join(self.dir, "net.json"), self.module)

    # -- CG-2 -----------------------------------------------------------------
    def measure_depth(self):
        nets = []
        for g in self.nl.groups.values():
            if g.kind != "ungated":
                nets.append(g.e)
                if g.kind == "ER":
                    nets.append(g.r)
        nets += [en for _, en in self.nl.icgs]
        d = depths(self.nl, nets, self.dir)
        for g in self.nl.groups.values():
            if g.kind != "ungated":
                g.depth = max(d[g.e], d[g.r] if g.kind == "ER" else 0.0)
        self.icg_depth = {c: d[en] for c, en in self.nl.icgs}

    # -- CG-3 -----------------------------------------------------------------
    def bench(self, scenarios=SCENARIOS, vcds=None):
        """Build the bench and run each scenario, unless VCDs are given."""
        b = self.spec["bench"]
        vcds = dict(vcds or {})
        todo = [s for s in scenarios if s not in vcds]
        if not todo:
            return vcds
        fill = {"dir": os.path.join(self.dir, "bench"), "root": ROOT}
        os.makedirs(fill["dir"], exist_ok=True)
        if b.get("build"):
            r = run(b["build"].format(**fill))
            if r.returncode:
                self.errors.append("bench build failed:\n" + (r.stdout + r.stderr)[-1500:])
                return vcds
        for sc in todo:
            vcd = os.path.join(self.dir, "%s.vcd" % sc)
            r = run(b["run"].format(scenario=sc, vcd=vcd, **fill))
            if r.returncode or not os.path.exists(vcd):
                self.errors.append("bench scenario %s failed:\n%s"
                                   % (sc, (r.stdout + r.stderr)[-1500:]))
                continue
            vcds[sc] = vcd
        return vcds

    def harness(self, n):
        """The netlist with every flop's Q and every group's enable brought
        out on cg_obs, under a testbench that replays a port trace."""
        nl = self.nl
        d = json.load(open(os.path.join(self.dir, "net.json")))
        m = d["modules"][self.module]
        obs, self.layout = [], {}
        for key, g in sorted(nl.groups.items(), key=lambda kv: str(kv[0])):
            lay = {}
            if g.kind != "ungated":
                lay["e"] = len(obs); obs.append(g.e)
                if g.kind == "ER":
                    lay["r"] = len(obs); obs.append(g.r)
            lay["q"] = list(range(len(obs), len(obs) + len(g.q)))
            obs.extend(g.q)
            self.layout[key] = lay
        self.qpos = {}
        for key, lay in self.layout.items():
            for q, pos in zip(nl.groups[key].q, lay["q"]):
                self.qpos[q] = pos
        m["ports"]["cg_obs"] = {"direction": "output", "bits": obs}
        m["netnames"]["cg_obs"] = {"hide_name": 0, "bits": obs, "attributes": {}}
        jf = os.path.join(self.dir, "obs.json")
        json.dump(d, open(jf, "w"))
        nv = os.path.join(self.dir, "net.v")
        r = run(["yosys", "-q", "-p", "read_json %s; write_verilog -noattr %s" % (jf, nv)])
        if r.returncode:
            raise SystemExit("check-cg: unit %s: write_verilog failed:\n%s"
                             % (self.name, r.stderr[-1500:]))
        clock = self.spec["clock"]
        self.ins = sorted(n for n in nl.inputs() if n != clock)
        self.outs = sorted(nl.outputs())
        self.widths = {n: len(b) for n, b in list(nl.inputs().items()) + list(nl.outputs().items())}
        iw = max(1, sum(self.widths[n] for n in self.ins))
        ow = max(1, sum(self.widths[n] for n in self.outs))
        conns, off = [".%s(clk)" % clock], 0
        for p in self.ins:
            conns.append(".%s(in_v[%d +: %d])" % (p, off, self.widths[p]))
            off += self.widths[p]
        off = 0
        for p in self.outs:
            conns.append(".%s(out_v[%d +: %d])" % (p, off, self.widths[p]))
            off += self.widths[p]
        conns.append(".cg_obs(obs)")
        tb = """// Generated by tools/check-cg.py: replays one port trace into the
// netlist of unit %(unit)s, checks every output against the bench's, and
// writes the observed flops and enables one line a cycle.
module cg_tb;
  logic clk = 1'b0;
  logic [%(iw)d-1:0] stim [%(n)d];
  logic [%(ow)d-1:0] want [%(n)d];
  logic [%(iw)d-1:0] in_v = '0;
  wire  [%(ow)d-1:0] out_v;
  wire  [%(bw)d-1:0] obs;
  %(mod)s dut (%(conns)s);
  int n, fd, bad = 0;
  string base;
  initial begin
    void'($value$plusargs("n=%%d", n));
    void'($value$plusargs("base=%%s", base));
    $readmemh({base, ".in"}, stim);
    $readmemh({base, ".out"}, want);
    fd = $fopen({base, ".obs"}, "w");
    for (int t = 0; t < n; t++) begin
      in_v = stim[t];
      #1;
      if (out_v != want[t]) begin
        bad++;
        if (bad <= 3) $display("CG-REPLAY cycle %%0d: outputs %%h, bench %%h", t, out_v, want[t]);
      end
      $fdisplay(fd, "%%h", obs);
      clk = 1'b1; #1; clk = 1'b0; #1;
    end
    $fclose(fd);
    $display("CG-REPLAY done %%0d %%0d", n, bad);
    $finish;
  end
endmodule
""" % {"unit": self.name, "iw": iw, "ow": ow, "bw": max(1, len(obs)), "n": max(1, n),
       "mod": self.module, "conns": ", ".join(conns)}
        tf = os.path.join(self.dir, "cg_tb.sv")
        open(tf, "w").write(tb)
        hd = os.path.join(self.dir, "harness")
        shutil.rmtree(hd, ignore_errors=True)
        r = run(["verilator", "--binary", "--timing", "-Wno-fatal", "-Wno-lint",
                 "-Wno-style", "-Irtl/include", "-Irtl/generated", "--top-module", "cg_tb",
                 "--Mdir", hd, "-o", "cg_tb", tf, nv]
                + [self.spec["blackbox"][k] for k in sorted(self.spec.get("blackbox", {}))])
        if r.returncode:
            raise SystemExit("check-cg: unit %s: harness build failed:\n%s"
                             % (self.name, (r.stdout + r.stderr)[-2000:]))
        self.harness_bin = os.path.join(hd, "cg_tb")

    def traces(self, vcds):
        """Port snapshots per scenario, from the bench's VCDs."""
        out = {}
        ports = sorted(set(self.nl.inputs()) | set(self.nl.outputs()))
        for sc, vcd in vcds.items():
            out[sc] = read_vcd(vcd, self.spec["bench"]["scope"], ports, self.spec["clock"])
        return out

    def replay(self, traces):
        """Run each scenario's trace through the harness; returns
        {scenario: (snaps, obs lines)} or records an error."""
        n = max([len(s) for s in traces.values()] + [1])
        self.harness(n)
        res = {}
        for sc, snaps in traces.items():
            base = os.path.join(self.dir, "replay_%s" % sc)
            with open(base + ".in", "w") as fi, open(base + ".out", "w") as fo:
                for snap in snaps:
                    fi.write("%x\n" % pack(snap, self.ins, self.widths))
                    fo.write("%x\n" % pack(snap, self.outs, self.widths))
            r = run([self.harness_bin, "+n=%d" % len(snaps), "+base=%s" % base])
            m = re.search(r"CG-REPLAY done (\d+) (\d+)", r.stdout)
            if r.returncode or not m:
                self.errors.append("replay of %s did not finish:\n%s"
                                   % (sc, (r.stdout + r.stderr)[-1500:]))
                continue
            if int(m.group(2)):
                self.errors.append(
                    "replay of %s: the netlist's outputs differ from the bench's on %s "
                    "of %s cycles, so the trace is not what was measured\n    %s"
                    % (sc, m.group(2), m.group(1),
                       "\n    ".join(l for l in r.stdout.splitlines() if "cycle" in l)))
                continue
            obs = [int(l, 16) for l in open(base + ".obs").read().split()]
            res[sc] = (snaps, obs)
        return res

    def stats(self, replays):
        """Per scenario: counted cycles, input activity, and each group's
        enabled and changing cycles. Reset cycles, and cycles before the
        first reset, are not counted."""
        rst = self.spec.get("reset")
        neg = bool(rst) and rst.startswith("!")
        rname = rst.lstrip("!") if rst else None
        iw = max(1, sum(self.widths[n] for n in self.ins))
        for sc, (snaps, obs) in replays.items():
            live, seen = [], not rst
            for snap in snaps:
                on = bool(snap.get(rname, 0)) != neg if rst else False
                seen = seen or on
                live.append(seen and not on)
            ins = [pack(s, self.ins, self.widths) for s in snaps]
            toggles = sum(bin(ins[t] ^ ins[t - 1]).count("1")
                          for t in range(1, len(ins)) if live[t] and live[t - 1])
            counted = [t for t in range(len(obs) - 1) if live[t]]
            g_en, g_use = collections.Counter(), collections.Counter()
            masks = {}
            for key, lay in self.layout.items():
                masks[key] = sum(1 << p for p in lay["q"])
            for t in counted:
                a, b = obs[t], obs[t + 1]
                diff = a ^ b
                for key, lay in self.layout.items():
                    g = self.nl.groups[key]
                    if g.kind == "ungated":
                        en = True
                    else:
                        en = ((a >> lay["e"]) & 1) == g.epol
                        if g.kind == "ER":
                            en = en or ((a >> lay["r"]) & 1) == g.rpol
                    if en:
                        g_en[key] += 1
                        if diff & masks[key]:
                            g_use[key] += 1
            self.data[sc] = {"cycles": len(counted), "obs": obs, "counted": counted,
                             "activity": toggles / float(iw * max(1, len(counted))),
                             "en": g_en, "use": g_use}

    def reg_rate(self, reg, sc):
        """For each full register name ending in `reg`: the share of counted
        cycles in which any of its bits changes, clocked every cycle."""
        out = {}
        byname = collections.defaultdict(int)
        for q in self.nl.flops:
            for name, _ in self.nl.alias.get(q, []):
                if name == reg or name.endswith("." + reg):
                    byname[name] |= 1 << self.qpos[q]
        dat = self.data[sc]
        obs = dat["obs"]
        for name, mask in byname.items():
            ch = sum(1 for t in dat["counted"] if (obs[t] ^ obs[t + 1]) & mask)
            out[name] = 100.0 * ch / max(1, dat["cycles"])
        return out

    def measure(self, vcds=None):
        self.synth()
        self.measure_depth()
        vcds = self.bench(vcds=vcds)
        if self.errors:
            return
        traces = self.traces(vcds)
        replays = self.replay(traces)
        if self.errors:
            return
        self.stats(replays)


def dcge(u, key, sc):
    e = u.data[sc]["en"][key]
    return None if e == 0 else 100.0 * u.data[sc]["use"][key] / e


# == The findings ==============================================================

class Finding:
    def __init__(self, rule, module, regs, msg, unit=None):
        self.rule, self.module, self.regs, self.msg, self.unit = rule, module, set(regs), msg, unit
        self.status = "open"

    def __str__(self):
        where = "%s (unit %s)" % (self.module, self.unit) if self.unit else self.module
        return "%s %s: %s" % (self.rule, where, self.msg)


def unit_findings(u):
    """CG-2 and CG-3 for one measured unit."""
    out = []
    for key, g in sorted(u.nl.groups.items(), key=lambda kv: kv[1].name):
        if g.kind == "ungated":
            continue
        if g.depth > NGD_MAX:
            out.append(Finding("CG-2", u.module, g.regs,
                               "enable of %s is %.1f NGD deep, over %g (en: %s)"
                               % (g.name, g.depth, NGD_MAX, g.en_name), u.name))
        for sc in SCENARIOS:
            if sc not in u.data:
                continue
            v = dcge(u, key, sc)
            if v is not None and v < DCGE_MIN:
                out.append(Finding("CG-3", u.module, g.regs,
                                   "%s changes on %.0f%% of its %d enabled cycles in %s, "
                                   "under %g%% (en: %s)"
                                   % (g.name, v, u.data[sc]["en"][key], sc, DCGE_MIN,
                                      g.en_name), u.name))
    for c, dep in sorted(u.icg_depth.items()):
        if dep > NGD_MAX:
            out.append(Finding("CG-2", u.module, {c},
                               "ICG %s's enable is %.1f NGD deep, over %g"
                               % (c, dep, NGD_MAX), u.name))
    return out


def scenario_findings(u):
    """The scenarios themselves: all three, long enough, and ordered by
    input activity, so idle is idle and high is high."""
    out = []
    for sc in SCENARIOS:
        if sc not in u.data:
            out.append(Finding("CG-3", u.module, set(), "no %s scenario" % sc, u.name))
        elif u.data[sc]["cycles"] < MIN_CYCLES:
            out.append(Finding("CG-3", u.module, set(),
                               "the %s scenario counts %d cycles, under %d"
                               % (sc, u.data[sc]["cycles"], MIN_CYCLES), u.name))
    if all(sc in u.data for sc in SCENARIOS):
        a = [u.data[sc]["activity"] for sc in SCENARIOS]
        if not (a[0] < a[1] < a[2]):
            out.append(Finding("CG-3", u.module, set(),
                               "input activity is not idle < medium < high "
                               "(%.3f, %.3f, %.3f toggles per input bit per cycle)"
                               % tuple(a), u.name))
    return out


def form_check(modules, units):
    """CG-1 for each module, with the measured exception."""
    by_mod = collections.defaultdict(list)
    for u in units:
        by_mod[u.module].append(u)
    out = []
    for mod, (rel, text, first) in sorted(modules.items()):
        for line, why, regs in form_findings(text, first):
            for reg in regs:
                ok, notes = bool(by_mod.get(mod)), []
                for u in by_mod.get(mod, []):
                    if u.errors or not all(sc in u.data for sc in SCENARIOS):
                        ok = False
                        continue
                    seen = False
                    for sc in SCENARIOS:
                        for name, rate in sorted(u.reg_rate(reg, sc).items()):
                            seen = True
                            if rate < DCGE_MIN:
                                ok = False
                                notes.append("%s changes on %.0f%% of %s cycles"
                                             % (name, rate, sc))
                    ok = ok and seen
                every = why.startswith("written every cycle")
                if every and ok:
                    continue
                msg = "%s:%d: %s %s" % (rel, line, reg, why)
                if every and notes:
                    msg += " (%s)" % notes[0]
                out.append(Finding("CG-1", mod, {reg}, msg))
    return out


def load(path, key):
    return json.load(open(path))[key] if os.path.exists(path) else ([] if key == "waivers" else {})


def policy(findings, modules, units, waivers, ratchet, baseline=RATCHET_BASELINE):
    """Apply the ratchet and the waivers. Returns the failures."""
    fails = []
    for f in findings:
        if f.module in ratchet:
            f.status = "ratchet"
            continue
        for w in waivers:
            if w["module"] != f.module or w["rule"] != f.rule:
                continue
            t = w["target"]
            if any(r == t or r.endswith("." + t) for r in f.regs):
                f.status = "waived"
                w["_used"] = True
                break
    fails += [str(f) for f in findings if f.status == "open"]
    for w in waivers:
        for k in ("module", "rule", "target", "why", "by", "date"):
            if not w.get(k):
                fails.append("waiver %s: no %s" % (w, k))
        if not w.get("_used"):
            fails.append("waiver %s %s %s excuses nothing: remove it"
                         % (w["module"], w["rule"], w["target"]))
    measured = {u.module for u in units
                if not u.errors and all(sc in u.data for sc in SCENARIOS)}
    for mod in sorted(ratchet):
        if mod not in baseline:
            fails.append("ratchet: %s was not on the list when the rule was made; "
                         "the list only shrinks" % mod)
        elif mod not in modules:
            fails.append("ratchet: %s is not a design module with flops: remove it" % mod)
        elif mod in measured and not any(f.module == mod for f in findings):
            fails.append("ratchet: %s now meets the rule: remove it from %s"
                         % (mod, os.path.relpath(RATCHET, ROOT)))
    have = {u.module for u in units}
    for mod in sorted(modules):
        if mod not in have and mod not in ratchet:
            fails.append("%s (%s) has flops and no clock-gating unit"
                         % (mod, modules[mod][0]))
    for u in units:
        if u.module not in modules:
            fails.append("unit %s measures %s, which is not a design module with flops"
                         % (u.name, u.module))
        for e in u.errors:
            if u.module not in ratchet:
                fails.append("unit %s: %s" % (u.name, e))
    return fails


def load_units():
    out, names = [], set()
    for f in sorted(glob.glob(os.path.join(ROOT, "test", "**", "cg-units.json"),
                              recursive=True)):
        for spec in json.load(open(f))["units"]:
            if spec["name"] in names:
                raise SystemExit("check-cg: unit %s defined twice" % spec["name"])
            names.add(spec["name"])
            out.append(Unit(spec, os.path.relpath(f, ROOT)))
    return out


def report(u, verbose):
    gated = [g for g in u.nl.groups.values() if g.kind != "ungated"]
    worst = max([g.depth for g in gated] + list(u.icg_depth.values()) + [0.0])
    flops = len(u.nl.flops)
    gflops = sum(len(g.q) for g in gated)
    line = "  unit %-16s %-16s %3d flops, %3d gated in %2d groups, worst enable %4.1f NGD" % (
        u.name, u.module, flops, gflops, len(gated), worst)
    print(line)
    if u.errors:
        for e in u.errors:
            print("    not measured: %s" % e.splitlines()[0])
        return
    for sc in SCENARIOS:
        if sc not in u.data:
            continue
        vals = [dcge(u, k, sc) for k, g in u.nl.groups.items() if g.kind != "ungated"]
        vals = [v for v in vals if v is not None]
        print("    %-6s %5d cycles, activity %.3f, %2d groups enabled, lowest DCGE %s"
              % (sc, u.data[sc]["cycles"], u.data[sc]["activity"], len(vals),
                 "%.0f%%" % min(vals) if vals else "-"))
    if verbose:
        for key, g in sorted(u.nl.groups.items(), key=lambda kv: kv[1].name):
            cells = []
            for sc in SCENARIOS:
                v = dcge(u, key, sc) if sc in u.data else None
                cells.append("%5s" % ("-" if v is None else "%.0f%%" % v))
            print("    %-8s %4.1f NGD  %s  %s  (en: %s)" % (
                g.kind, g.depth, " ".join(cells), g.name, g.en_name or "always"))
        for c, dep in sorted(u.icg_depth.items()):
            print("    ICG      %4.1f NGD  %s's enable" % (dep, c))


def main_check(only=None, verbose=False):
    modules = design_modules()
    units = load_units()
    if only:
        units = [u for u in units if u.name == only]
        if not units:
            raise SystemExit("check-cg: no unit %s" % only)
    ratchet = load(RATCHET, "modules")
    waivers = load(WAIVERS, "waivers")
    findings = []
    for u in units:
        u.measure()
        report(u, verbose)
        if u.errors:
            continue
        findings += unit_findings(u) + scenario_findings(u)
    findings += form_check(modules, units)
    if only:
        for f in findings:
            print("    " + str(f))
        return 0
    fails = policy(findings, modules, units, waivers, ratchet)
    for mod in sorted(ratchet):
        n = sum(1 for f in findings if f.module == mod)
        print("  ratchet: %-14s %s" % (mod, "%d finding(s) excused" % n if n else
                                       "not measured: no unit"))
    nw = sum(1 for f in findings if f.status == "waived")
    print("  %d module(s), %d unit(s), %d waiver(s) in use, %d on the ratchet"
          % (len(modules), len(units), nw, len(ratchet)))
    for f in fails:
        sys.stderr.write("check-cg: %s\n" % f)
    return 1 if fails else 0


# == The negative controls =====================================================

FIXTURE_DIR = os.path.join(ROOT, "test", "cg", "fixtures")


def fixture_unit(name, module, scope=None):
    return Unit({
        "name": name, "module": module,
        "files": ["test/cg/fixtures/%s.sv" % module],
        "clock": "clk", "reset": "rst",
        "bench": {"scope": scope or "tb_cg_fixture.u_" + module.split("_")[-1]},
    }, "selftest")


def selftest():
    bad = []
    os.makedirs(os.path.join(BUILD, "fixture"), exist_ok=True)
    bench = os.path.join(BUILD, "fixture", "bench")
    files = sorted(glob.glob(os.path.join(FIXTURE_DIR, "*.sv")))
    r = run(["verilator", "--binary", "--timing", "--trace", "-Wno-fatal", "-Wno-lint",
             "-Wno-style", "--top-module", "tb_cg_fixture", "--Mdir", bench, "-o", "tb",
             os.path.join(ROOT, "test", "cg", "tb_cg_fixture.sv")] + files)
    if r.returncode:
        sys.stderr.write(r.stdout + r.stderr)
        return 1
    vcds = {}
    for sc in SCENARIOS:
        vcds[sc] = os.path.join(BUILD, "fixture", "%s.vcd" % sc)
        r = run([os.path.join(bench, "tb"), "+scenario=" + sc, "+vcd=" + vcds[sc], "+n=1500"])
        if r.returncode:
            sys.stderr.write(r.stdout + r.stderr)
            return 1
    mods = {}
    for f in files:
        name = os.path.basename(f)[:-3]
        mods[name] = (os.path.relpath(f, ROOT), lint.strip_comments(open(f).read()), 1)
    units = {m: fixture_unit("fx_" + m.split("_")[-1], m) for m in mods}
    for u in units.values():
        u.measure(vcds=vcds)
        if u.errors:
            bad.append("fixture %s not measured: %s" % (u.module, u.errors[0]))
    if bad:
        for x in bad:
            sys.stderr.write("check-cg selftest: %s\n" % x)
        return 1
    every = []
    for u in units.values():
        every += unit_findings(u) + scenario_findings(u)
    every += form_check(mods, list(units.values()))

    def has(rule, mod, reg, fs=None):
        return [f for f in (every if fs is None else fs)
                if f.rule == rule and f.module == mod and
                (reg is None or any(r == reg or r.endswith("." + reg) for r in f.regs))]

    checks = 0

    def expect(cond, what):
        nonlocal checks
        checks += 1
        if not cond:
            bad.append(what)

    # 1. The compliant fixture has nothing, the free-running LFSR included:
    #    clocked every cycle it changes every cycle, the measured exception.
    expect(not [f for f in every if f.module == "cg_fx_good"],
           "the compliant fixture has findings: %s"
           % [str(f) for f in every if f.module == "cg_fx_good"])
    # 2. CG-1: a register written every cycle, idle when its input is.
    expect(has("CG-1", "cg_fx_form", "d_q"), "CG-1 missed a register under no enable")
    # 3. CG-1: an enable that is an expression.
    expect(any("expression" in f.msg for f in has("CG-1", "cg_fx_form", "e_q")),
           "CG-1 missed an expression enable")
    # 4. CG-2: an add and a compare into the gate.
    expect(has("CG-2", "cg_fx_deep", "d_q"), "CG-2 missed a deep enable")
    expect(not has("CG-2", "cg_fx_deep", "acc_q"), "CG-2 flagged a shallow enable")
    # 5. CG-3: enabled on every valid, almost never changing.
    expect(has("CG-3", "cg_fx_dcge", "hit_q"), "CG-3 missed a low-DCGE group")
    expect(not has("CG-3", "cg_fx_dcge", "d_q"), "CG-3 flagged a good group")
    # 6. The replay: a trace from another module is refused.
    u = fixture_unit("fx_swap", "cg_fx_good", scope="tb_cg_fixture.u_dcge")
    u.measure(vcds=vcds)
    expect(any("differ" in e for e in u.errors), "a trace of another module replayed clean")
    # 7. The scenarios: swapped idle and high, and one too short.
    g = units["cg_fx_good"]
    saved = dict(g.data)
    g.data["idle"], g.data["high"] = saved["high"], saved["idle"]
    expect(any("activity" in f.msg for f in scenario_findings(g)),
           "swapped idle and high scenarios passed")
    g.data = dict(saved)
    g.data["medium"] = dict(saved["medium"], cycles=MIN_CYCLES - 1)
    expect(any("under %d" % MIN_CYCLES in f.msg for f in scenario_findings(g)),
           "a short scenario passed")
    g.data = saved
    # 8. Waivers: one that excuses a finding clears it; one that excuses
    #    nothing is refused.
    allu = list(units.values())
    ok_mods = {m: mods[m] for m in ("cg_fx_good", "cg_fx_dcge")}
    fs = [f for f in every if f.module in ok_mods]
    for f in fs:
        f.status = "open"
    w = [{"module": "cg_fx_dcge", "rule": "CG-3", "target": "hit_q", "why": "control",
          "by": "TI", "date": "2026-10-16"}]
    fails = policy(fs, ok_mods, [x for x in allu if x.module in ok_mods], w, {})
    expect(not fails, "a waiver did not clear its finding: %s" % fails)
    for f in fs:
        f.status = "open"
    w = [{"module": "cg_fx_good", "rule": "CG-3", "target": "d_q", "why": "control",
          "by": "TI", "date": "2026-10-16"}]
    fails = policy(fs, ok_mods, [x for x in allu if x.module in ok_mods], w, {})
    expect(any("excuses nothing" in x for x in fails), "a stale waiver was accepted")
    # 9. The ratchet: a listed module that meets the rule must leave it; a
    #    module outside the baseline cannot join it.
    for f in every:
        f.status = "open"
    fails = policy(list(every), mods, allu, [], {"cg_fx_good": {}, "cg_fx_form": {}},
                   baseline={"cg_fx_good"})
    expect(any("cg_fx_good now meets the rule" in x for x in fails),
           "a ratcheted module that passes stayed on the list")
    expect(any("cg_fx_form was not on the list" in x for x in fails),
           "the ratchet grew")
    # 10. Coverage: a module with flops and no unit.
    for f in every:
        f.status = "open"
    fails = policy([], mods, [x for x in allu if x.module != "cg_fx_form"], [], {})
    expect(any("cg_fx_form" in x and "no clock-gating unit" in x for x in fails),
           "a module with no unit passed")
    for x in bad:
        sys.stderr.write("check-cg selftest: %s\n" % x)
    if not bad:
        print("  form, enable depth, DCGE, replay, scenarios, waivers, ratchet, "
              "coverage (%d controls)" % checks)
    return 1 if bad else 0


def main():
    ap = argparse.ArgumentParser()
    ap.add_argument("--selftest", action="store_true")
    ap.add_argument("--unit")
    a = ap.parse_args()
    if a.selftest:
        return selftest()
    return main_check(a.unit, verbose=bool(a.unit))


if __name__ == "__main__":
    sys.exit(main())
