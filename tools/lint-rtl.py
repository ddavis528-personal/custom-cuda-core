#!/usr/bin/env python3
"""CCV RTL lint -- §8 Stage 1d.

§6 is explicit that "lint enforces it" is load-bearing for the whole X-safety
approach, and §9 that style set before RTL exists is the cheap path because
rules added late mostly generate backlog rather than catching bugs. This runs
before the first block exists.

WHY THIS IS NOT VERIBLE. §6 adds Verible as a fourth tool. The Stage 1a spike
found it unobtainable here (finding F-5), and more importantly found the
dependency poorly motivated: the central rule -- no bare `if`/`case` on control
without a paired $isunknown assert -- is a RELATIONSHIP between two constructs,
not a property of one, so stock Verible rules never expressed it and custom
rules would have had to be written against its API regardless. Taking a
heavyweight fourth-tool dependency to end up writing custom rules anyway is a
poor trade for a solo project. The rules are the artifact; the tool is an
implementation detail.

Verilator's --lint-only carries what it already does well -- width mismatches,
inferred latches, unused and undriven signals -- and tools/verify.sh runs both.
There is no reason to reimplement that here, and every reason not to.

Each rule has an id (CCV-Lnn) that docs/rtl-coding-style.md cites, so a
failure points at the paragraph that explains it rather than at a regex.
"""
import json
import os
import re
import sys

ROOT = os.path.dirname(os.path.dirname(os.path.abspath(__file__)))

# SCOPES
#
# Not every rule applies to every file, and pretending otherwise is how a lint
# layer gets switched off wholesale. Three scopes, each with a reason:
#
#   design  -- rtl/, excluding include/ and generated/. Everything applies.
#   tb      -- testbenches and instrumentation. `initial`, delays and DPI are
#              exactly what these are FOR, and one module per file is a
#              convention for build automation the testbenches do not feed.
#   probe   -- spike/cases/. These are tool probes whose entire job is to write
#              bare, deliberately non-portable assertions and find out what
#              each tool does with them. Linting them for style would be
#              linting the measurement instrument. Only CCV-L10 applies, since
#              a metacomment collision breaks the probe itself.
#
# A single file can opt out with a marker that requires a reason:
#
#     // ccv-lint: exempt CCV-L03 -- <why>
#
# The reason is not decoration. An exemption without one is a rule quietly
# disabled, which is worse than no rule at all because it still looks enforced.
SCOPE_PROBE = ("spike/cases/",)
SCOPE_TB = ("spike/", "test/")

# Rules that apply in each scope. `design` gets everything not listed here.
PROBE_RULES = {"CCV-L10"}
TB_RULES = {"CCV-L02", "CCV-L04", "CCV-L07", "CCV-L10"}

EXEMPT_RE = re.compile(r"//\s*ccv-lint:\s*exempt\s+([\w\-,\s]+?)\s*--\s*(\S.*)")


def scope_of(rel):
    if any(rel.startswith(r) for r in SCOPE_PROBE):
        return "probe"
    if any(rel.startswith(r) for r in SCOPE_TB):
        return "tb"
    return "design"


def allowed_rules(scope):
    if scope == "probe":
        return PROBE_RULES
    if scope == "tb":
        return TB_RULES
    return None  # design: everything


SV_KEYWORDS = {
    "if", "else", "case", "casez", "casex", "endcase", "begin", "end", "and",
    "or", "not", "xor", "logic", "wire", "reg", "input", "output", "inout",
    "always", "always_ff", "always_comb", "assign", "posedge", "negedge",
    "default", "int", "bit", "byte", "signed", "unsigned", "parameter",
    "localparam", "for", "while", "return", "function", "task", "generate",
    "endgenerate", "module", "endmodule", "unique", "priority", "begin",
}


def balanced(text, start):
    """Text inside the parenthesis group beginning at `start`, which must index
    the opening paren. Returns (inner, index_after_close)."""
    depth, i = 0, start
    while i < len(text):
        if text[i] == "(":
            depth += 1
        elif text[i] == ")":
            depth -= 1
            if depth == 0:
                return text[start + 1:i], i + 1
        i += 1
    return "", len(text)


def idents(expr):
    out = set()
    for m in re.finditer(r"[A-Za-z_]\w*", expr):
        w = m.group(0)
        if w in SV_KEYWORDS or re.match(r"^\d", w):
            continue
        out.add(w)
    return out


def input_ports(text):
    """Input port names from an ANSI-style port list."""
    m = re.search(r"\bmodule\s+\w+\s*(?:#\s*\([^)]*\)\s*)?\(", text)
    if not m:
        return set()
    inner, _ = balanced(text, m.end() - 1)
    ports = set()
    for decl in inner.split(","):
        d = decl.strip()
        if not re.match(r"^(input|inout)\b", d):
            continue
        name = re.findall(r"[A-Za-z_]\w*", d)
        if name:
            ports.add(name[-1])
    return ports


def known_signals(raw):
    """Signals covered by a KNOWN assertion anywhere in the file."""
    k = set()
    for pat in (r"CCV_ASSERT_KNOWN\w*\s*\(\s*\w+\s*,\s*([\w.\[\]]+)",
                r"CCV_ASSUME_KNOWN\s*\(\s*\w+\s*,\s*([\w.\[\]]+)"):
        for m in re.finditer(pat, raw):
            k.add(m.group(1).split("[")[0].split(".")[0])
            k.add(m.group(1).split("[")[0])
    return k


def line_of(text, pos):
    return text.count("\n", 0, pos) + 1


# --------------------------------------------------------------------------
# Net naming (docs/rtl-coding-style.md, net naming section)
#
#   signals   <name>[_<stage>][_n|_b]
#   clocks    [<block>_]<domain>_clk[_b]
#   stage     <domain><block><NN><l|h>
#
# `_n`/`_b` are always the outermost suffix, which is why the stage tag is
# matched with them optionally following rather than at the end of the string.
# --------------------------------------------------------------------------
STAGE_RE = re.compile(r"_([a-z])([a-z])(\d{2})([lh])(?:_[nb])?$")
CLK_RE = re.compile(r"^(?:([a-z]\w*?)_)?([a-z]\w*)_clk(?:_b)?$")


def load_blocks():
    path = os.path.join(ROOT, "params", "blocks.json")
    if not os.path.exists(path):
        return {}, {}
    with open(path) as f:
        d = json.load(f)
    doms = {x["letter"]: x for x in d.get("domains", [])}
    seg2let = {x["segment"]: x["letter"] for x in d.get("domains", [])}
    blks = {x["letter"]: x for x in d.get("blocks", [])}
    return {"by_letter": doms, "by_segment": seg2let}, blks


def stage_of(name):
    """(domain, block, number, edge) or None if the net carries no stage tag."""
    m = STAGE_RE.search(name)
    if not m:
        return None
    return m.group(1), m.group(2), int(m.group(3)), m.group(4)


# CCV-L29's reading of a module body. Brace-free HDL again, so a small scan
# of the tokens that open and close a scope: a declaration inside a
# procedural block (an always, initial or final block's begin or case, a
# function, a task) is a local variable, and inside a struct's braces a
# field; anywhere else, at module level or in a generate block, it is a net.
SCOPE_TOK = re.compile(r"\b(always_ff|always_comb|always_latch|always|initial|final|"
                       r"function|endfunction|task|endtask|begin|end|case|casez|"
                       r"casex|endcase)\b|[(){};]")
NET_DECL = re.compile(r"(?:\b(?:logic|wire|reg)\b|\b[a-z]\w*_t\b)([^;]*);")
# What carries no stage tag by its own rules: a clock (CCV-L20) and a reset
# tap, which counts distance in its own space (`<block>_rst_r<NN><l|h>`).
UNSTAGED_RE = re.compile(r"(?:_clk(?:_b)?|(?:^|_)rst_r\d\d[lh](?:_n)?)$")


def module_nets(body, start):
    """(pos, name) for each net a module body declares from start: at module
    level or in a generate block, never a procedural local or a struct
    field, and never a port or a parameter."""
    stack, pending, paren, brace, marks = [], False, 0, 0, []
    for m in SCOPE_TOK.finditer(body, start):
        t = m.group(1) or m.group(0)
        in_proc = bool(stack) and stack[-1] == "proc"
        if t == "(":
            paren += 1
        elif t == ")":
            paren -= 1
        elif t == "{":
            brace += 1
        elif t == "}":
            brace -= 1
        elif t in ("always_ff", "always_comb", "always_latch", "always", "initial", "final"):
            pending = True
        elif t in ("function", "task"):
            stack.append("proc")
        elif t in ("begin", "case", "casez", "casex"):
            stack.append("proc" if pending or in_proc else "gen")
            pending = False
        elif t in ("end", "endcase", "endfunction", "endtask"):
            if stack:
                stack.pop()
        elif t == ";" and paren == 0 and not in_proc:
            pending = False   # a procedural block of one statement ended
        marks.append((m.start(), "proc" in stack, brace))
    out, k, ctx = [], 0, (False, 0)
    for m in NET_DECL.finditer(body, start):
        while k < len(marks) and marks[k][0] <= m.start():
            ctx = marks[k][1:]
            k += 1
        if ctx[0] or ctx[1]:
            continue
        ls = body.rfind("\n", 0, m.start()) + 1
        if re.search(r"\b(?:parameter|localparam|input|output|inout|typedef|function|"
                     r"automatic)\b", body[ls:m.start()]):
            continue
        decl = re.sub(r"=[^,]*", "", re.sub(r"\[[^\]]*\]", "", m.group(1)))
        for n in re.findall(r"\b([a-z]\w*)\b", decl):
            if n not in ("signed", "unsigned", "logic"):
                out.append((m.start(), n))
    return out


# CCV-L29's ratchet: untagged nets that stood when the rule was made, which
# their owner tags or removes, and its frozen baseline, which only the
# rule's owner (TI) writes. Read once a run; the findings excused and the
# modules seen are kept for the cross-file half (check_stage_ratchet).
STAGE_RATCHET = os.path.join(ROOT, "rtl", "stage-ratchet.json")
STAGE_BASELINE = os.path.join(ROOT, "tools", "stage-ratchet-baseline.json")
_stage_ratchet = {"path": STAGE_RATCHET, "baseline": STAGE_BASELINE, "mods": None,
                  "found": set(), "seen": set()}


def stage_ratchet():
    if _stage_ratchet["mods"] is None:
        p = _stage_ratchet["path"]
        _stage_ratchet["mods"] = (json.load(open(p)).get("modules", {})
                                  if os.path.exists(p) else {})
    return _stage_ratchet["mods"]


# CCV-L23's declared feedback (OA's ruling on TI-38, 2026-10-23): a read
# whose stage the arithmetic skips, because it is the back edge of a real
# register loop -- a select loop whose request register reads the grant
# register its own next value feeds. Declared per module, beside the RTL, in
# <module>.feedback.json: {"reads": {reader: {"from": [read, ...], "by": an
# architect, "date", "why"}}}. The lint finds the loop itself and refuses a
# declaration it cannot find, so the exemption is no wider than the loop.
FEEDBACK_BY = ("OA", "AR", "DA")
# MA is the MIU and DCU architect (MA-32): it signs a declaration of a module
# under rtl/miu/ or rtl/dcu/ only, and nowhere else.
FEEDBACK_BY_DIR = {"MA": ("rtl/miu/", "rtl/dcu/")}


# check-1d reads a fixture as if it stood at this repo path (--signer-path=).
_signer_path = {"rel": None}


def feedback_signers(path):
    """The architects who may sign a CCV-L23 declaration beside this module."""
    rel = (_signer_path["rel"] or
           os.path.relpath(os.path.abspath(path), ROOT)).replace(os.sep, "/").rstrip("/") + "/"
    return FEEDBACK_BY + tuple(b for b, dirs in sorted(FEEDBACK_BY_DIR.items())
                               if any(rel.startswith(d) for d in dirs))
IDENT_RE = re.compile(r"\b[a-z]\w*\b")


def feedback_decls(dirpath, module):
    """(path, reads, bypass, table) from <module>.feedback.json."""
    p = os.path.join(dirpath, module + ".feedback.json")
    if not os.path.exists(p):
        return None, {}, {}, {}
    d = json.load(open(p))
    # "tables" (OA-492) is the same form's spelling for an input port.
    return (os.path.relpath(p, ROOT), d.get("reads", {}), d.get("bypass", {}),
            dict(d.get("table", {}), **d.get("tables", {})))


# CCV-L23's declared table (DA rev 131, OA 452 with its seven conditions;
# OI-187): an array written at its writer's stage and read long after, through
# an index at the reader's own stage, as ooe_ratmap's parked table is (a
# demotion parks a word, a restore reads it). The read counts at the reader's
# stage, as a bypass read does. Declared in <module>.feedback.json:
# {"table": {"<array>": {"readers": ["<reader>", ...], "by", "date", "why"}}}.
def two_writers(d, sa, arr):
    """(writers, their signals, why) for a declared table's "writers" (OA-479
    (b)): None, set(), None when it has none (one writer, the plain form).
    Each is {"name", "stage", "loop": true} for the one loop writer, at the
    table's stage less one, or {"name", "stage", "enable": [...], "from":
    [...]} for a later writer from another pipeline; every writer names its
    enable, and a non-loop writer's registers reaching the port are its
    enable and "from"."""
    ws = d.get("writers")
    if ws is None:
        return None, set(), None
    if not isinstance(ws, list) or len(ws) < 2:
        return None, set(), ("\"writers\" lists every writer, one loop writer and at "
                             "least one other: a single writer is the plain form")
    out, sig = [], set()
    for i, w in enumerate(ws):
        if not isinstance(w, dict) or not isinstance(w.get("stage"), int):
            return None, set(), "writer %d gives no stage" % i
        en = w.get("enable") or []
        en = [en] if isinstance(en, str) else list(en)
        fr = list(w.get("from") or [])
        if not en:
            return None, set(), "writer %s names no enable" % w.get("name", i)
        out.append(dict(w, name=w.get("name", str(i)), enable=en,
                        sigs=sorted(set(en) | set(fr))))
    loops = [w for w in out if w.get("loop")]
    if len(loops) != 1:
        return None, set(), ("%d loop writers: a table has exactly one (its back edge "
                             "the table's own read)" % len(loops))
    if loops[0]["stage"] != sa[2] - 1:
        return None, set(), ("its loop writer %s is at stage %02d, not %02d, one before "
                             "the table's tag" % (loops[0]["name"], loops[0]["stage"],
                                                  sa[2] - 1))
    for w in out:
        if not w.get("loop"):
            if w["stage"] <= sa[2] - 1:
                return None, set(), ("writer %s is at stage %02d, not past the loop "
                                     "writer's %02d: an earlier writer is the plain "
                                     "arithmetic's" % (w["name"], w["stage"], sa[2] - 1))
            sig |= set(w["sigs"])
    return out, sig, None


def loop_vars(body):
    """The genvars and procedural loop variables of a module body: a row
    number, never a tagged net."""
    out = set(re.findall(r"\bgenvar\s+([a-z]\w*)", body))
    out |= set(re.findall(r"\bfor\s*\(\s*(?:genvar|int|integer|int\s+unsigned)?\s*"
                          r"([a-z]\w*)\s*=", body))
    return out


def row_index(expr, ctx, loopv):
    """The index a read of a row-register table goes through (DI-51): expr
    itself when it reads anything but loop variables; else the tagged side of
    each compare, in the read's conditions or right-hand side, of a tagged
    index with the row's number."""
    ws = re.findall(r"[a-z]\w*", expr)
    rv = [w for w in ws if w in loopv]
    if not rv or any(w not in loopv for w in ws):
        return expr
    sides = []
    for c in ctx:
        for clause in re.split(r"&&|\|\||\?|:", c):
            if "==" not in clause or not any(re.search(r"\b%s\b" % v, clause) for v in rv):
                continue
            tagged = [w for w in re.findall(r"[a-z]\w*", clause) if stage_of(w)]
            if tagged:
                sides.append(" ".join(tagged))
    return " ".join(sides) if sides else expr


ASSERT_RE = re.compile(r"(?:`CCV_ASSERT(?:_AT)?|\bassert\s+property|\bassert)\s*\(")


def array_decl(body, name):
    """(words, decl text) for name's declaration in a module body: words is its
    unpacked dimension's count (None for a plain register or vector)."""
    m = re.search(r"\b(?:logic|reg|bit)\b[^;]*?\b%s\b\s*(\[[^\]]*\])?[^;]*;" % re.escape(name), body)
    if not m:
        return None, None
    if not m.group(1):
        return None, m.group(0)
    dim = m.group(1)[1:-1]
    r = re.fullmatch(r"\s*(\d+)\s*:\s*(\d+)\s*", dim)
    if r:
        return abs(int(r.group(1)) - int(r.group(2))) + 1, m.group(0)
    r = re.fullmatch(r"\s*(\d+)\s*", dim)
    return (int(r.group(1)) if r else 2), m.group(0)


def index_reads(text, name):
    """The index expressions name is read through in text, and whether every
    read of it is indexed."""
    idx, bare = [], False
    for m in re.finditer(r"\b%s\b" % re.escape(name), text):
        nxt = text[m.end():]
        if re.match(r"\s*\[", nxt):
            j = m.end() + nxt.index("[")
            depth = 0
            for k in range(j, len(text)):
                if text[k] == "[":
                    depth += 1
                elif text[k] == "]":
                    depth -= 1
                    if not depth:
                        idx.append(text[j + 1:k])
                        break
        else:
            bare = True
    return idx, bare


def data_graph(src):
    """deps[net]: the names its assignments' right-hand sides read, and no
    condition: the data a register is loaded with, apart from its enable."""
    deps = {}
    for kind, clk, body, ln, pos in always_blocks(src):
        for _, lhs, _, rhs in assignments(body):
            deps.setdefault(lhs, set()).update(IDENT_RE.findall(rhs))
    for m in re.finditer(r"\bassign\s+[^;]+;", src):
        for _, lhs, _, rhs in assignments(m.group(0)[len("assign"):]):
            deps.setdefault(lhs, set()).update(IDENT_RE.findall(rhs))
    return deps


def bypass_path(ddeps, flops, reader, read, ahead):
    """A declared bypass (DA, 2026-10-23, OI-72 (A)): read is a register
    `ahead` pipeline stages on from a register at reader's stage, in reader's
    pipeline (its block letter), each hop through the data a register is
    loaded with. Returns why it does not hold, or None."""
    if read not in flops:
        return "%s is not a register" % read
    sr = stage_of(reader)
    frontier = {read}
    for _ in range(ahead):
        nxt = set()
        for f in frontier:
            nxt |= cone(ddeps, flops, ddeps.get(f, ()))[1]
        frontier = nxt
    on = [r for r in frontier if stage_of(r) and stage_of(r)[1] == sr[1] and stage_of(r)[2] == sr[2]]
    if not on:
        return ("%s is not loaded, %d register(s) back, from a register at %s's stage %02d "
                "in its pipeline: the source is off the reader's path" % (read, ahead, reader, sr[2]))
    return None


def dep_graph(src):
    """(deps, flops) over a comment-stripped file: deps[net] is every name its
    assignments read, conditions included (an if's or a case's selector
    steers the value as much as its right-hand side does); flops are the
    names an always_ff assigns."""
    deps, flops = {}, set()
    def conds(body):
        out = set()
        for m in re.finditer(r"\b(?:if|case|casez|casex)\s*\(", body):
            out |= set(IDENT_RE.findall(balanced(body, m.end() - 1)[0]))
        return out
    for kind, clk, body, ln, pos in always_blocks(src):
        c = conds(body)
        for _, lhs, _, rhs in assignments(body):
            deps.setdefault(lhs, set()).update(IDENT_RE.findall(rhs), c)
            if kind == "ff":
                flops.add(lhs)
    for m in re.finditer(r"\bassign\s+[^;]+;", src):
        for _, lhs, _, rhs in assignments(m.group(0)[len("assign"):]):
            deps.setdefault(lhs, set()).update(IDENT_RE.findall(rhs))
    return deps, flops


def cone(deps, flops, roots):
    """The nets and the registers reached from roots through combinational
    logic: (nets, regs). A register stops the walk."""
    nets, regs, todo = set(), set(), list(roots)
    while todo:
        n = todo.pop()
        if n in nets or n in regs:
            continue
        if n in flops:
            regs.add(n)
            continue
        nets.add(n)
        todo.extend(deps.get(n, ()))
    return nets, regs


def feedback_loop(deps, flops, reader, read):
    """Whether reader's read of read closes a two-register loop: a register G
    that read comes from, combinationally, whose next value depends,
    combinationally, on a register R that reader is part of (R itself, or R's
    next value reads reader)."""
    _, gs = cone(deps, flops, [read])
    rs = {reader} if reader in flops else \
         {f for f in flops if reader in cone(deps, flops, deps.get(f, ()))[0]}
    return any(r in cone(deps, flops, deps.get(g, ()))[1] for g in gs for r in rs)


def loop_path(deps, flops, reader, read, loop):
    """A loop of any length, declared by its registers in order (OA's rev
    191): reader is loop[0] or feeds its next value, each register's next
    value depends combinationally on the one before it, and read comes from
    the last. Returns why it does not hold, or None."""
    if len(loop) < 2:
        return "a loop names two registers or more"
    for q in loop:
        if q not in flops:
            return "%s is not a register" % q
    if reader != loop[0] and reader not in cone(deps, flops, deps.get(loop[0], ()))[0]:
        return "%s is not %s and does not feed its next value" % (reader, loop[0])
    for a, b in zip(loop, loop[1:]):
        if a not in cone(deps, flops, deps.get(b, ()))[1]:
            return "no hop from %s to %s: %s's next value does not depend on it" % (a, b, b)
    if loop[-1] not in cone(deps, flops, [read])[1]:
        return "%s does not come from %s" % (read, loop[-1])
    return None


# The common ports every block declares, generated rather than hand-written.
# They are deliberately UNIFORM across blocks -- which is the same argument
# that made the original CCV-L02 want one name everywhere: a swap harness that
# must look up a different clock name per block is not mechanical. The naming
# convention governs the NET AT THE PARENT that drives these (`ooe_core_clk`),
# not the formal here.
COMMON_CLK_PORTS = {"core_clk"}


def clk_domain(name):
    """The domain segment of a clock net -- the segment immediately before
    `_clk`. `sched_core_clk` -> 'core'; `core_clk` -> 'core'; `test_clk` ->
    'test'. That placement is what makes the `_core_` marker mechanically
    checkable rather than a reading convention."""
    m = CLK_RE.match(name)
    return m.group(2) if m else None


def always_blocks(src):
    """(kind, clock_or_None, body, line, pos) for each always block.

    Brace-free HDL, so the body runs to the next block-level construct rather
    than to a matched delimiter. Good enough to attribute assignments to a
    clock, which is all the stage rules need."""
    out = []
    for m in re.finditer(r"\balways(_ff|_comb|_latch)?\b", src):
        kind = (m.group(1) or "")[1:] or "plain"
        rest = src[m.end():]
        clk = None
        em = re.match(r"\s*@\s*\(\s*(pos|neg)edge\s+([\w.]+)", rest)
        if em:
            clk = (em.group(2), em.group(1))
        nxt = re.search(r"\balways(_ff|_comb|_latch)?\b|\bassign\b|\bendmodule\b",
                        rest)
        body = rest[:nxt.start()] if nxt else rest
        out.append((kind, clk, body, line_of(src, m.start()), m.start()))
    return out


def _stmt_end(t, i):
    """Index just past the statement starting at or after i in an always body:
    a begin-end block, an if with its else, a case to its endcase, or a
    simple statement to its semicolon."""
    m = re.match(r"\s*(?:(?:unique0?|priority)\s+)?(begin|if|case[zx]?)\b", t[i:])
    if not m:
        j = t.find(";", i)
        return len(t) if j < 0 else j + 1
    kw, k = m.group(1), i + m.end()
    if kw == "begin":
        depth = 1
        for w in re.finditer(r"\b(begin|end)\b", t[k:]):
            depth += 1 if w.group(1) == "begin" else -1
            if depth == 0:
                e = k + w.end()
                lbl = re.match(r"\s*:\s*\w+", t[e:])
                return e + (lbl.end() if lbl else 0)
        return len(t)
    p = t.find("(", k)
    if p < 0:
        return len(t)
    _, j = balanced(t, p)
    if kw == "if":
        e = _stmt_end(t, j)
        el = re.match(r"\s*else\b", t[e:])
        return _stmt_end(t, e + el.end()) if el else e
    depth = 1
    for w in re.finditer(r"\b(case[zx]?|endcase)\b", t[j:]):
        depth += -1 if w.group(1) == "endcase" else 1
        if depth == 0:
            return j + w.end()
    return len(t)


def cond_regions(body):
    """(start, end, condition) for each if and case in an always body: the
    text its condition or selector steers, an if's else arm included. An
    assignment inside one reads its condition as surely as its right-hand side
    (OI's rev 188: a cq02h net assigned under an if that read cq03h registers
    passed CCV-L23 unseen)."""
    out = []
    for m in re.finditer(r"\b(if|case[zx]?)\s*\(", body):
        cond, j = balanced(body, m.end() - 1)
        if m.group(1) == "if":
            e = _stmt_end(body, j)
            el = re.match(r"\s*else\b", body[e:])
            e = _stmt_end(body, e + el.end()) if el else e
        else:
            e = _stmt_end(body, m.start())
        out.append((j, e, cond))
    return out


ASSIGN_RE = re.compile(r"([a-z]\w*)\s*(?:\[[^\]]*\])?\s*(<=|=)(?!=)\s*([^;]+);")


def assignments(text):
    """(pos, lhs, op, rhs) for each assignment in text: continuous, blocking
    or nonblocking. CCV-L20, L23 and L24 read assignments only through here.

    Read as a pattern, `a == b` and `a <= b` look like assignments too, and a
    match runs to the next semicolon. So a macro call with no semicolon after
    it, `CCV_ASSERT(n, a == b)`, took everything up to the next one as its
    right-hand side, the always_ff after it included, and a rule reported that
    block's clock as read as data by `a` (OI-40). Three things keep a
    comparison out. An `=` that starts `==` is not an assignment. A candidate
    inside parentheses (an if-condition, a macro's or a function's arguments)
    is never an assignment's left-hand side, nor is one after `return`. And a
    candidate so refused consumes nothing past its own name, so the
    assignment after it is still read, with its own left-hand side."""
    depth, d = [], 0
    for ch in text:
        depth.append(d)
        if ch == "(":
            d += 1
        elif ch == ")" and d:
            d -= 1
    pos = 0
    while True:
        m = ASSIGN_RE.search(text, pos)
        if not m:
            return
        if depth[m.start()] or \
                re.search(r"\breturn\s*$", text[max(0, m.start() - 16):m.start()]):
            pos = m.end(1)
            continue
        yield m.start(), m.group(1), m.group(2), m.group(3)
        pos = m.end()


# --------------------------------------------------------------------------
# Module names (docs/rtl-coding-style.md, Module names; DA's response OI-37)
#
# A module's name says what it is. No marker comment and no directory does:
# a marker is a pragma, and a directory is where a file happens to sit. The
# namespace has six shapes, each decidable from the name and the block list
# in params/blocks.json alone:
#
#   ccv_<block>                      block top: gates core_clk (CCV-L22)
#   ccv_<block>_w[_v<N>|_<NN>]       hardening wrapper: the block, its repeaters
#   <block>_<name>                   sub-block: inside one block, on its clock
#   ccv_common_<type>[_<name>]       common module, global
#   <block>_common_<type>[_<name>]   common module, one block's
#   ccv_top                          the core top, the one named exception
#
# Anything else is CCV-L28. A block name is one token, so a name splits at
# its first underscore; "common" and "top" are not block names. Both are
# refused in params/blocks.json (check_blocks), so no two shapes can match
# one name. The <type> of a common module is what some rules key on: `chk`
# is an interface checker (CCV-L14, L15), `ctech` a ctech cell (CCV-L27).
# --------------------------------------------------------------------------
class Cls:
    def __init__(self, kind=None, block=None, typ=None, why=None):
        self.kind, self.block, self.typ, self.why = kind, block, typ, why


# Hard macros (AR's register rev 344; docs/rtl-coding-style.md, "Hard
# macros"): a large data or tag array is a library macro, never a flop
# array. Each is a common module of a macro type, ccv_common_<sram|rf>_<ports>,
# whose behavioural view is in rtl/macro/ (CCV-L27): the name is what lets
# check-ngd time its pins (inputs endpoints, outputs start points, each at
# its macro's setup or launch; Daniel, 2026-11-17) and check-cg count none
# of its storage, so only that
# directory may carry one. Each is listed with its enables, the pins CG-5
# holds to the instantiating module's own flops. An SRAM is one port, every
# other cycle; a read and a write together, or every cycle, is a register
# file, 3 times an SRAM's area per bit (DA tab rev 123, MA-16). Only a
# register file has byte enables, the _be one, at 1.5 times its area per
# bit (Daniel, 2026-11-17): an SRAM writes whole words.
MACROS = {
    "ccv_common_sram_1rw": ("ce", "we"),
    "ccv_common_rf_1r1w": ("re", "we"),
    "ccv_common_rf_1r1w_be": ("re", "we"),
}
MACRO_TYPES = ("sram", "rf")


def is_macro(name):
    """Whether a module (by its source name) is a hard macro."""
    return name in MACROS


SHAPES = ("ccv_<block>, ccv_<block>_w, <block>_<name>, ccv_common_<type>, "
          "<block>_common_<type> or ccv_top")


def classify(name, blocknames):
    if name == "ccv_top":
        return Cls("top")
    m = re.match(r"^ccv_common(?:_([a-z0-9]+)(?:_[a-z0-9_]+)?)?$", name)
    if m:
        if not m.group(1):
            return Cls(why="a common module carries its type: ccv_common_<type>")
        return Cls("common", None, m.group(1))
    m = re.match(r"^ccv_([a-z0-9]+)(?:_(\w+))?$", name)
    if m:
        b, rest = m.group(1), m.group(2)
        if b not in blocknames:
            return Cls(why="%r is not a block in params/blocks.json, so ccv_%s "
                       "is no block's top, wrapper or common module" % (b, b))
        if rest is None:
            return Cls("block", b)
        if re.fullmatch(r"w(?:_v?\d+)?", rest):
            return Cls("wrapper", b)
        return Cls(why="after ccv_%s only a wrapper's _w may follow; a "
                   "sub-block of %s is %s_<name>" % (b, b, b))
    m = re.match(r"^([a-z0-9]+)_(\w+)$", name)
    if m and m.group(1) in blocknames:
        b, rest = m.group(1), m.group(2)
        cm = re.match(r"^common(?:_([a-z0-9]+)(?:_[a-z0-9_]+)?)?$", rest)
        if cm:
            if not cm.group(1):
                return Cls(why="a common module carries its type: "
                           "%s_common_<type>" % b)
            return Cls("common", b, cm.group(1))
        return Cls("sub", b)
    return Cls(why="it takes none of the shapes " + SHAPES)


def module_spans(src):
    """(start, end, name, line) for each module in comment-stripped text."""
    out = []
    for m in re.finditer(r"^[ \t]*module\s+([A-Za-z_]\w*)", src, re.M):
        e = re.search(r"\bendmodule\b", src[m.end():])
        end = m.end() + e.end() if e else len(src)
        out.append((m.start(), end, m.group(1), line_of(src, m.start())))
    return out


class Finding:
    def __init__(self, rule, path, line, msg):
        self.rule, self.path, self.line, self.msg = rule, path, line, msg

    def __str__(self):
        return "%s:%d: %s: %s" % (self.path, self.line, self.rule, self.msg)


def strip_comments(text):
    """Blank out comments and string literals, preserving line structure, so
    rules never fire on prose. Keeping the line count identical is what lets
    findings report the real line number."""
    out = []
    in_block = False
    for line in text.split("\n"):
        res, i, n = [], 0, len(line)
        while i < n:
            if in_block:
                j = line.find("*/", i)
                if j < 0:
                    res.append(" " * (n - i)); i = n
                else:
                    res.append(" " * (j + 2 - i)); i = j + 2; in_block = False
            elif line.startswith("//", i):
                res.append(" " * (n - i)); i = n
            elif line.startswith("/*", i):
                in_block = True; res.append("  "); i += 2
            elif line[i] == '"':
                j = i + 1
                while j < n and line[j] != '"':
                    j += 2 if line[j] == "\\" else 1
                res.append(" " * (min(j + 1, n) - i)); i = min(j + 1, n)
            else:
                res.append(line[i]); i += 1
        out.append("".join(res))
    return "\n".join(out)


def check_file(path, rel):
    with open(path) as f:
        raw = f.read()
    src = strip_comments(raw)
    lines = src.split("\n")
    raw_lines = raw.split("\n")
    F = []
    scope = scope_of(rel)
    allow = allowed_rules(scope)
    is_tb = scope != "design"
    is_header = rel.endswith((".svh", ".vh"))

    # A library view's lib_cells.v declares the ports of a PROCESS LIBRARY's
    # cells so the view elaborates without the PDK. It is the library's
    # naming, not ours, and it is never synthesised.
    if re.match(r"rtl/ctech/[^/]+/lib_cells\.v$", rel):
        return []
    # A file's modules and what each one's name makes it (OI-37). One module
    # a file is CCV-L01, so the first is the file's; a fixture holding
    # several is still judged module by module, where it matters.
    _, blocks_by_letter = load_blocks()
    blocknames = {b["name"] for b in blocks_by_letter.values()}
    spans = module_spans(src)
    cls = {n: classify(n, blocknames) for _, _, n, _ in spans}
    file_cls = cls[spans[0][2]] if spans else Cls()

    def cls_at(pos):
        for s0, e0, n, _ in spans:
            if s0 <= pos < e0:
                return cls[n]
        return file_cls

    # A ctech cell (docs/clock-gate.md): the one place a latch, a clock read
    # as data, a clock built from a clock, or a library cell may appear. It
    # is a ccv_common_ctech_<cell> in rtl/ctech/<view>/, both or neither
    # (CCV-L27): the name says what it is, the directory which view.
    in_ctech = rel.startswith("rtl/ctech/")
    ctech = in_ctech and file_cls.typ == "ctech"

    exempt = {}
    for m in EXEMPT_RE.finditer(raw):
        for r in re.split(r"[,\s]+", m.group(1).strip()):
            if r:
                exempt[r] = m.group(2).strip()

    def add(rule, ln, msg):
        if allow is not None and rule not in allow:
            return
        if rule in exempt:
            return
        F.append(Finding(rule, rel, ln, msg))

    # -- CCV-L01: one module per file, filename matches module name ---------
    mods = [(i + 1, m.group(1))
            for i, l in enumerate(lines)
            for m in [re.match(r"\s*module\s+([A-Za-z_]\w*)", l)] if m]
    if not is_header:
        if len(mods) > 1:
            add("CCV-L01", mods[1][0],
                "more than one module in a file (%s); build automation and "
                "most lint tooling assume one per file"
                % ", ".join(m[1] for m in mods))
        if len(mods) == 1:
            want = os.path.splitext(os.path.basename(rel))[0]
            if mods[0][1] != want:
                add("CCV-L01", mods[0][0],
                    "module %s is in %s.sv; filename must match module name"
                    % (mods[0][1], want))

    # -- CCV-L02: every macro user names its own clock and reset -----------
    # Each block gates core_clk on entry and uses the uniquified result, and
    # reset is pipelined so which stage reaches a block depends on physical
    # distance. There is therefore no single clock or reset name the assertion
    # macros could hardcode; each file supplies its own through two defines,
    # and clears them so one file's clock cannot leak into the next.
    if not is_header and re.search(r"`CCV_(ASSERT|ASSUME|COVER|CONTRACT)", raw):
        for sym in ("CCV_CLK", "CCV_RST"):
            if not re.search(r"`define\s+%s\b" % sym, raw):
                add("CCV-L02", 1,
                    "file uses the assertion macros but never defines `%s. "
                    "The macros take clock and reset from `CCV_CLK/`CCV_RST, "
                    "because per-block gating and a pipelined reset mean no "
                    "single name could be hardcoded" % sym)
            elif not re.search(r"`undef\s+%s\b" % sym, raw):
                add("CCV-L02", 1,
                    "`%s is defined but never `undef'd. A macro outlives the "
                    "file in a shared compilation unit, so the next file "
                    "silently inherits this one's clock" % sym)

    # -- CCV-L03: no `initial`, no delays in design RTL ---------------------
    if not is_tb:
        for i, l in enumerate(lines):
            if re.search(r"^\s*initial\b", l):
                add("CCV-L03", i + 1,
                    "`initial` in design RTL; reset behaviour comes from the "
                    "synchronous reset, not from initial blocks")
            if re.search(r"#\s*\d", l) and "`" not in l:
                add("CCV-L03", i + 1, "delay in design RTL")

    # -- CCV-L04: blocking/nonblocking discipline ---------------------------
    # Tracked by enclosing always_ff / always_comb rather than by guessing
    # from the assignment alone.
    blk = None
    depth = 0
    for i, l in enumerate(lines):
        if re.search(r"\balways_ff\b", l):
            blk, depth = "ff", 0
        elif re.search(r"\balways_comb\b|\balways_latch\b", l):
            blk, depth = "comb", 0
        elif re.search(r"\balways\b\s*@", l):
            blk, depth = "plain", 0
        if blk:
            depth += len(re.findall(r"\bbegin\b", l))
            depth -= len(re.findall(r"\bend\b(?!case|function|module|package)", l))
        if blk == "ff" and re.search(r"[^<>=!+\-*/&|^%]=[^=]", l) \
           and not re.search(r"<=", l) and not re.search(r"\bassign\b", l) \
           and not re.search(r"\bfor\b|\bint\b|\blocalparam\b|\bparameter\b", l):
            add("CCV-L04", i + 1,
                "blocking `=` inside always_ff; sequential logic uses `<=`")
        if blk == "comb" and re.search(r"<=", l) \
           and not re.search(r"[<>!=]=|<<|>>", l.replace("<=", "\x00")) \
           and "\x00" in l.replace("<=", "\x00"):
            add("CCV-L04", i + 1,
                "nonblocking `<=` inside always_comb; combinational logic "
                "uses `=`")
        if blk and depth <= 0 and re.search(r"\bend\b", l):
            blk = None

    # -- CCV-L05: no bare assertions; everything through the 1b library -----
    # Stage 1a finding F-1: the three tools accept three dialects and no two
    # overlap, so a hand-written property is broken in at least one tool.
    for i, l in enumerate(lines):
        if re.search(r"^\s*(?:\w+\s*:\s*)?(assert|assume|cover)\s*[\(( ]", l) \
           and "`" not in l and rel != "rtl/include/ccv_assert.svh":
            add("CCV-L05", i + 1,
                "bare `%s`; use the CCV_ASSERT / CCV_ASSUME / CCV_COVER macros "
                "so one property source serves all three tools"
                % re.search(r"(assert|assume|cover)", l).group(1))

    # -- CCV-L06: no DPI imports in design RTL ------------------------------
    if not is_tb and rel != "rtl/include/ccv_trace.svh":
        # Matched on the RAW line: strip_comments blanks string literals, so
        # the "DPI-C" that identifies the import is gone from the stripped
        # text. The stripped line is still consulted, to confirm this is a
        # real import rather than a commented-out one.
        for i, l in enumerate(raw_lines):
            if 'import "DPI-C"' in l and lines[i].strip().startswith("import"):
                add("CCV-L06", i + 1,
                    "DPI import in design RTL; event instrumentation is bound "
                    "from outside the design (§9 assertion placement)")


    # -- CCV-L08 / L16 / L17 / L18: X-determinism on control ---------------
    #
    # §6's central rule, and the one no stock rule set expresses: it is a
    # relationship between a control expression and an assertion elsewhere in
    # the file, not a property of either alone.
    #
    # A selection on control must be X-DETERMINISTIC by one of three routes
    # (docs/rtl-coding-style.md, and rtl/include/ccv_xprop.svh for the measured
    # behaviour of each):
    #
    #   PROHIBITION  the control inputs carry a KNOWN assertion
    #   TMERGE       the selection is a ternary, which is not an if/case and so
    #                never reaches these rules at all
    #   XMERGE       a case with an X-default covering everything it assigns
    #
    # WHY ONLY INPUT PORTS ARE REQUIRED TO CARRY THE ASSERTION. X enters a
    # module through its ports or through un-reset state. A locally derived
    # signal is X-free whenever the inputs it derives from are, so asserting at
    # the boundary discharges the interior -- which is the same compositional
    # argument F-8 makes for CCV_ASSUME_KNOWN, one level down. Un-reset state
    # is the other source and is covered separately, by the reset line at Stage
    # 4a and by CCV_ASSERT_READ_VALID.
    #
    # LIMITS, stated because a lint rule that is trusted beyond its reach is
    # worse than one that is not trusted at all: this reads ANSI port lists,
    # matches identifiers textually, and does not follow hierarchy, `include
    # boundaries or non-ANSI declarations. It is a net, not a proof. The proof
    # is the formal run.
    if not is_tb and not is_header:
        known = known_signals(raw)
        ins = input_ports(src)

        def is_reset(n):
            """A reset net: the literal `rst` in a reusable module's formals,
            or any net in the reset distribution tree, which carries block
            letter `r` in its stage tag."""
            st = stage_of(n)
            return n == "rst" or (st is not None and st[1] == "r") or \
                   re.search(r"(^|_)rst(_|$)", n) is not None

        def uncovered(expr):
            """Input-port identifiers in `expr` with no KNOWN assertion.
            Reset is exempt: §6 makes it globally synchronous and always
            reset, so it is the one control signal that cannot be X. So is
            the clock inside a ctech cell, whose latch is `if (!clk)`."""
            return sorted(n for n in (idents(expr) & ins) - known
                          if not is_reset(n)
                          and not (ctech and (n == "clk" or clk_domain(n))))

        # -- CCV-L16: casex is banned outright ------------------------------
        # Measured (F-16): with an unknown selector, casex treats X as a
        # don't-care and matches the FIRST branch. Not pessimism, not
        # optimism -- an arbitrary answer that looks like a real one.
        for m in re.finditer(r"\bcasex\b", src):
            add("CCV-L16", line_of(src, m.start()),
                "`casex` is banned: with an unknown selector it treats X as a "
                "don't-care and silently matches the first branch. Use `case` "
                "with an X-default, or a ternary")

        # -- if statements: prohibition is the only route -------------------
        for m in re.finditer(r"(?<![\w.])if\s*\(", src):
            expr, _ = balanced(src, m.end() - 1)
            bad_ids = uncovered(expr)
            if bad_ids:
                add("CCV-L08", line_of(src, m.start()),
                    "`if` on control input(s) %s with no "
                    "CCV_ASSERT_KNOWN/CCV_ASSUME_KNOWN. An unknown condition "
                    "silently takes the else branch in every 4-state "
                    "simulator. Assert the input known, or select with a "
                    "ternary, which merges instead"
                    % ", ".join(repr(x) for x in bad_ids))

        # -- case / casez: prohibition OR an X-default ----------------------
        for m in re.finditer(r"\bcase(z?)\s*\(", src):
            expr, after = balanced(src, m.end() - 1)
            end = src.find("endcase", after)
            body = src[after:end if end > 0 else len(src)]
            ln = line_of(src, m.start())

            # Signals the case assigns, and the X-default that would cover
            # them -- either in a `default:` branch or as a prologue before
            # the case in the same always block.
            assigned = set(re.findall(r"([A-Za-z_]\w*)\s*(?:<=|=)[^=]", body))
            dm = re.search(r"\bdefault\s*:", body)
            xcov = set()
            if dm:
                for a, rhs in re.findall(
                        r"([A-Za-z_]\w*)\s*(?:<=|=)\s*([^;]+);",
                        body[dm.end():]):
                    if re.search(r"'\s*[bdh]?x|'x", rhs, re.I):
                        xcov.add(a)
            pro = src.rfind("always", 0, m.start())
            if pro >= 0:
                for a, rhs in re.findall(
                        r"([A-Za-z_]\w*)\s*(?:<=|=)\s*([^;]+);",
                        src[pro:m.start()]):
                    if re.search(r"'\s*[bdh]?x|'x", rhs, re.I):
                        xcov.add(a)

            x_defaulted = bool(assigned) and assigned <= xcov
            bad_ids = uncovered(expr)

            # -- CCV-L07: an unreachable state must be loud -----------------
            # §6's first listed rule. Either route satisfies it: a `default:`
            # branch, or an X prologue before the case. Demanding the branch
            # specifically would reject the prologue form, which is the more
            # natural style and reaches the same guarantee.
            if not dm and not x_defaulted:
                add("CCV-L07", ln,
                    "case with neither a `default:` branch nor an X prologue "
                    "covering %s; §6 requires an unreachable state to assign "
                    "'x rather than hold its previous value"
                    % (", ".join(sorted(assigned - xcov)) or "its outputs"))

            if bad_ids and not x_defaulted:
                missing = sorted(assigned - xcov)
                add("CCV-L08", ln,
                    "case selector uses control input(s) %s with no KNOWN "
                    "assertion, and the case is not X-defaulted%s. Take one of "
                    "the two legal routes: assert the input known, or assign "
                    "'x to every signal the case writes (in `default:` or as a "
                    "prologue)"
                    % (", ".join(repr(x) for x in bad_ids),
                       " (uncovered: %s)" % ", ".join(missing) if missing
                       else ""))
            elif not bad_ids and assigned and not x_defaulted and xcov:
                # Partially X-defaulted while relying on prohibition is fine,
                # but a partial X-default is usually a slip rather than intent.
                add("CCV-L17", ln,
                    "case is partially X-defaulted: %s covered, %s not. A "
                    "signal left out holds its previous value on an "
                    "unreachable branch, which is the implicit hold §6's "
                    "explicit-X rule exists to remove"
                    % (", ".join(sorted(xcov & assigned)) or "none",
                       ", ".join(sorted(assigned - xcov))))

        # -- CCV-L18: array write with an unknown index is DROPPED ----------
        # LRM semantics silently discard a write whose index is X. No
        # construction fixes that, so the index must be prohibited from
        # being X.
        for m in re.finditer(r"([A-Za-z_]\w*)\s*\[([^\]]+)\]\s*<=", src):
            bad_ids = uncovered(m.group(2))
            if bad_ids:
                add("CCV-L18", line_of(src, m.start()),
                    "write to %s[] indexed by control input(s) %s with no "
                    "KNOWN assertion. An unknown index does not propagate X -- "
                    "the write is silently DROPPED, and no coding construct "
                    "changes that"
                    % (m.group(1), ", ".join(repr(x) for x in bad_ids)))

    # -- CCV-L09: no SystemVerilog interface on a port boundary -------------
    # Settled by Stage 1a finding F-4, not a preference: Verilator reports
    # "Interfaced port on top level module" as unsupported, and §2 makes block
    # boundaries swap boundaries.
    for i, l in enumerate(lines):
        if re.search(r"module\s+\w+\s*\(", l) or re.match(r"\s*\w+\.\w+\s+\w+\s*[,)]", l):
            if re.search(r"\b(\w+)\.(\w+)\s+\w+\s*[,)]", l):
                add("CCV-L09", i + 1,
                    "interface/modport on a port list; block boundaries are "
                    "swap boundaries and Verilator cannot expose an interfaced "
                    "port at top level (F-4). Use plain ports or packed structs")

    # -- CCV-L10: no comment line opening with a tool's own name ------------
    # A `// <toolname> ...` comment is parsed as a metacomment pragma and
    # rejected as an unknown one. This cost three builds while Stage 1a and 1b
    # were being written, which is exactly the argument for a lint rule.
    for i, l in enumerate(raw_lines):
        if re.match(r"\s*//\s*(verilator|verilog_format|verible)\b", l, re.I) \
           and not re.match(r"\s*//\s*verilator\s+(lint_off|lint_on|"
                            r"lint_save|lint_restore|coverage_off|coverage_on|"
                            r"tracing_off|tracing_on|public|no_inline|"
                            r"isolate_assignments|clock_enable|split_var|"
                            r"timing_on|timing_off)\b", l):
            add("CCV-L10", i + 1,
                "comment line opens with a tool name, which is parsed as a "
                "metacomment pragma and rejected; reword so the line does not "
                "start with it")

    # -- CCV-L11: every design module cites the spec it implements ----------
    # §9: "Each module references the spec artifact it implements -- its Stage
    # 4a internal-behavior spec -- so RTL and spec stay traceable to each other
    # as both evolve."
    if not is_tb and not is_header and mods:
        # A DEDICATED comment line, not a mention anywhere in the file.
        # Searching the whole text matched the lint fixture's own prose
        # explaining that the reference was missing, which is the rule
        # marking its own counter-example compliant.
        if not re.search(r"(?im)^\s*//\s*Spec:\s*\S+", raw):
            add("CCV-L11", mods[0][0],
                "no `Spec:` reference; every design module cites the Stage 4a "
                "internal-behaviour spec it implements, so the two stay "
                "traceable as both evolve")

    # -- CCV-L13: no `bind` at a design boundary ---------------------------
    # Stage 1a finding F-9, and the reason is the failure MODE rather than the
    # missing feature: Yosys parses a bind, ignores it, and garbage-collects
    # the checker. A standalone block proof would then be empty and green.
    if not is_tb:
        for i, l in enumerate(lines):
            if re.match(r"\s*bind\s+\w+\s+\w+", l):
                add("CCV-L13", i + 1,
                    "`bind` at a design boundary; Yosys parses it, ignores it "
                    "and drops the checker, so the proof passes having checked "
                    "nothing (F-9). Instantiate with `CCV_CHECKER instead")

    # -- interface checker rules (docs/interface-checker-convention.md) -----
    is_checker = (not is_tb and file_cls.kind == "common"
                  and file_cls.typ == "chk")
    if is_checker:
        name = mods[0][1]

        # -- CCV-L14: satisfiability covers are mandatory, not optional -----
        # Convention §3.3. A contradictory `assume` set makes every dependent
        # proof vacuously true and does it SILENTLY -- spike cases 34 and 35
        # demonstrate exactly that. The covers are the only available signal.
        # Searched in the COMMENT-STRIPPED source. Against `raw` the rule
        # matches its own counter-example's explanatory comment and reports
        # the fixture compliant -- the same way CCV-L11 did during 1d. A rule
        # that reads prose as code is a rule that quietly stops working.
        if "`CCV_IF_SAT" not in src:
            add("CCV-L14", mods[0][0],
                "checker %s has no `CCV_IF_SAT satisfiability cover; §3.3 "
                "makes them mandatory because a contradictory assume set "
                "makes every proof over it vacuously true, silently" % name)

        # -- CCV-L15: protocol properties must be mode-resolved -------------
        # A bare `CCV_ASSERT in a checker ignores the MODE parameter, so the
        # checker cannot act as a cut-point and the ASSUME side is silently
        # absent -- which looks like a proof that succeeded.
        for i, l in enumerate(lines):
            if re.search(r"`CCV_(ASSERT|ASSUME)\s*\(", l):
                add("CCV-L15", i + 1,
                    "bare `CCV_ASSERT/`CCV_ASSUME in a checker; use "
                    "`CCV_CONTRACT_M so the MODE parameter is honoured, or "
                    "the ASSUME side of a cut-point is silently absent")


    # -- net naming --------------------------------------------------------
    if not is_tb and not is_header:
        domains, blocks = load_blocks()
        letter_of = {b["name"]: L for L, b in blocks.items()}

        # A COMMON module -- an interface checker, a primitive -- takes
        # `clk`/`rst` as generic formals, because one instance of it lives
        # inside many blocks and binds to each block's own uniquified clock. A
        # formal named for one block would read as a lie in every other, so
        # the clock-name and stage rules do not apply to it.
        #
        # Its NAME says so (ccv_common_<type>, <block>_common_<type>), never
        # an inference from the code: inferring it from "the clock is not
        # named like a clock" would let every non-compliant file exempt
        # itself by being non-compliant.
        def reusable(pos):
            return cls_at(pos).kind == "common"

        def blk_name_at(pos):
            c = cls_at(pos)
            return c.block if c.kind in ("block", "wrapper", "sub") else None

        # -- CCV-L28: every module takes one of the namespace's shapes -----
        for s0, e0, n, ln in spans:
            c = cls[n]
            if c.kind is None:
                add("CCV-L28", ln, "module %s: %s (OI-37)" % (n, c.why))

        # -- CCV-L27: a ctech cell is named one, in a view's directory -----
        for s0, e0, n, ln in spans:
            if cls[n].typ == "ctech" and not in_ctech:
                add("CCV-L27", ln,
                    "module %s is named as a ctech cell outside rtl/ctech/. "
                    "The name is what lets a file hold a latch or a "
                    "hand-built clock, so only a view may carry it: "
                    "rtl/ctech/<view>/ccv_common_ctech_<cell>.sv" % n)
        if in_ctech and spans and file_cls.typ != "ctech":
            add("CCV-L27", spans[0][3],
                "module %s in rtl/ctech/ is not a ctech cell. A view holds "
                "only ccv_common_ctech_<cell>, one per cell" % spans[0][2])

        # -- CCV-L27: a hard macro is named one, in rtl/macro/ ------------
        # Like a ctech cell, a macro is a library cell: its name is what
        # takes its storage out of check-cg's counts and its inside out of
        # check-ngd's, so a module of a macro type is one of MACROS, in
        # rtl/macro/, and that directory holds nothing else.
        in_macro = rel.startswith("rtl/macro/")
        for s0, e0, n, ln in spans:
            if cls[n].typ in MACRO_TYPES and not (in_macro and is_macro(n)):
                add("CCV-L27", ln,
                    "module %s is named as a hard macro %s. A macro is one of "
                    "the cells tools/lint-rtl.py MACROS lists, with its "
                    "enables, in rtl/macro/<macro>.sv"
                    % (n, "outside rtl/macro/" if not in_macro else
                       "MACROS does not list"))
        if in_macro and spans and not is_macro(spans[0][2]):
            add("CCV-L27", spans[0][3],
                "module %s in rtl/macro/ is not a hard macro: the directory "
                "holds only the cells MACROS lists" % spans[0][2])

        # -- CCV-L22: only a block top gates, and a sub-block never sees
        # the ungated clock --------------------------------------------------
        # The gate belongs to the block top, which takes core_clk and hands
        # its gated clock down. A second gate inside the block would put a
        # sleep decision where the block's quiescence and stall are not
        # visible; a sub-block clocked on core_clk escapes the block's gate
        # silently; and a sub-block on another block's clock is a crossing
        # nothing declared. All three work in simulation.
        for s0, e0, n, ln in spans:
            c = cls[n]
            body = src[s0:e0]
            gm = re.search(r"\bccv_common_clk\b", body)
            if c.kind in ("wrapper", "sub", "common") and gm and n != "ccv_common_clk":
                add("CCV-L22", ln + body[:gm.start()].count("\n"),
                    "module %s instantiates ccv_common_clk, but only a block "
                    "top gates (OI-37). %s" % (n, {
                        "wrapper": "A wrapper's block gates core_clk itself, "
                                   "inside the wrapper",
                        "sub": "A sub-block runs on the clock its block "
                               "top's gate makes",
                        "common": "A common module runs on the clock the "
                                  "block instantiating it hands it"}[c.kind]))
            if c.kind != "sub":
                continue
            um = re.search(r"\bcore_clk\b", body)
            if um:
                add("CCV-L22", ln + body[:um.start()].count("\n"),
                    "module %s is a sub-block of %s and names core_clk, the "
                    "UNGATED clock. A sub-block takes %s_core_clk, which its "
                    "block top's gate makes; on core_clk it escapes the gate "
                    "with nothing in simulation to show it" % (n, c.block, c.block))
            for cm in re.finditer(r"\b([a-z]\w*_clk(?:_b)?)\b", body):
                pm = CLK_RE.match(cm.group(1))
                pre = pm.group(1) if pm else None
                if pre and pre in letter_of and pre != c.block:
                    add("CCV-L22", ln + body[:cm.start()].count("\n"),
                        "module %s is a sub-block of %s but runs on %s, block "
                        "%s's clock. A sub-block runs on its own block's gated "
                        "clock, %s_core_clk" % (n, c.block, cm.group(1), pre, c.block))
                    break

        # -- CCV-L19: lowercase, underscore-separated ----------------------
        # Parameters keep UPPER_SNAKE; everything else is lower_snake_case.
        # A TYPED parameter (`parameter logic [W-1:0] NAME = ...`) is still a
        # parameter: the type keyword is not a net declaration. Reading it as
        # one forced width-typed constants into `int`, which cannot hold a
        # mask wider than 32 bits.
        for m in re.finditer(r"\b(?:logic|wire|reg)\b[^;\n]*?\b([A-Za-z_]\w*)\s*[;,=\)]",
                             src):
            n = m.group(1)
            ls = src.rfind("\n", 0, m.start()) + 1
            if re.search(r"\b(?:parameter|localparam)\s+$", src[ls:m.start()]):
                continue
            if re.search(r"[A-Z]", n):
                add("CCV-L19", line_of(src, m.start()),
                    "net %r is not lower_snake_case; only parameters and "
                    "localparams carry upper case" % n)

        # -- CCV-L20: clocks are named for it, and only clocks are clocks ---
        for kind, clk, body, ln, pos in always_blocks(src):
            if not clk or reusable(pos):
                continue
            cname, edge = clk
            base = cname.split(".")[-1]
            if base in COMMON_CLK_PORTS:
                dom = "core"          # a common port, by definition core-domain
            else:
                dom = clk_domain(base)
            if dom is None:
                add("CCV-L20", ln,
                    "%r drives a clock edge but is not named as a clock. A "
                    "clock net is [<block>_]<domain>_clk, and the domain is "
                    "the segment before `_clk` -- which is what makes "
                    "`_core_` mean synchronous-to-core mechanically rather "
                    "than by reading" % base)
            elif domains and dom not in domains["by_segment"]:
                add("CCV-L20", ln,
                    "clock %r has domain segment %r, which is not in "
                    "params/blocks.json. An unregistered domain is either a "
                    "typo or a new clock nobody declared" % (base, dom))

            # -- CCV-L22: blocks run on their gated clock -------------------
            # A block receives ONE clock, `core_clk`, ungated, and gates it
            # itself as its first act: the gate is inside the block, never at
            # the top (the top holds only instances and nets). Only the gate
            # and the wake detector, which watches for traffic while the block
            # sleeps, may run on the ungated net. Clocking anything else on it
            # silently defeats the gate: the design works, produces identical
            # results, and never saves the power. Nothing in simulation shows it.
            if base == "core_clk" and cls_at(pos).kind == "block":
                body_names = set(re.findall(r"[a-z]\w*", body))
                if not any("wake" in n or "detect" in n for n in body_names):
                    add("CCV-L22", ln,
                        "block %r clocks logic on %r, which is the UNGATED "
                        "clock. Only the wake detector may use it; everything "
                        "else runs on the gate's clock, or the block's gate "
                        "is defeated with nothing in simulation to show it"
                        % (cls_at(pos).block, base))

        # A clock net may feed an edge expression, a port map, or ANOTHER
        # CLOCK NET -- that last one is the block's gate, which is the whole
        # reason `<block>_core_clk` exists. Anything else is a clock read as
        # data, which is how a clock ends up in a datapath unnoticed.
        for apos, lhs, _, rhs in assignments(src):
            if reusable(apos):
                continue        # a common module's generic formals
            if clk_domain(lhs):
                continue        # a clock from a clock: CCV-L27's business
            for cm in re.finditer(r"\b([a-z]\w*_clk(?:_b)?)\b", rhs):
                add("CCV-L20", line_of(src, apos),
                    "clock %r is read as data by %r. A clock belongs in "
                    "an edge expression, a port map, or the right-hand "
                    "side of another clock -- nowhere else"
                    % (cm.group(1), lhs))

        # -- CCV-L22, the other half: a block top HAS its gate -------------
        # A block top with sequential logic gates core_clk through
        # ccv_common_clk, which is where the sleep policy, the wake guarantee
        # and the ctech ICG live. Checked textually: an instance of it taking
        # core_clk. Only the top of a block: its sub-blocks run on the clock
        # it makes (OI-37). ccv_top, which holds no logic, would gate too.
        for s0, e0, n, ln in spans:
            body = src[s0:e0]
            if cls[n].kind not in ("block", "top") or \
                    not re.search(r"\balways_ff\b", body):
                continue
            gm = re.search(r"\bccv_common_clk\b[^;]*?\.clk\s*\(\s*core_clk\s*\)",
                           body, re.S)
            if not gm:
                add("CCV-L22", ln,
                    "module %s is %s with sequential logic but no "
                    "ccv_common_clk taking core_clk. Every block's first act "
                    "is its gate: the sleep policy, the wake path and the "
                    "ctech ICG are all inside it (docs/clock-gate.md)"
                    % (n, "the core top" if cls[n].kind == "top" else "a block top"))

        # -- CCV-L27: clock gates are ctech cells ---------------------------
        # Every clock gate in the design is ccv_common_ctech_icg, reached through
        # ccv_common_clk, so that synthesis gets the library's ICG rather than
        # whatever it infers from an AND -- which glitches when its enable
        # moves while the clock is high, and which nothing in RTL simulation
        # shows. So outside rtl/ctech/: no clock built from a clock with
        # logic, and no latch. Renaming a clock (`assign a_clk = b_clk;`) is
        # wiring and is fine.
        if not ctech:
            for m in re.finditer(r"\bassign\s+([a-z]\w*)\s*=\s*([^;]+);", src):
                lhs, rhs = m.group(1), m.group(2).strip()
                if not (clk_domain(lhs) or lhs in ("clk", "gclk")):
                    continue
                if re.fullmatch(r"[a-z]\w*", rhs):
                    continue        # a rename
                if re.search(r"\b(?:[a-z]\w*_clk|clk)\b", rhs):
                    add("CCV-L27", line_of(src, m.start()),
                        "clock %r is built from a clock by hand (%s). Every "
                        "clock gate is the ctech ICG: instantiate "
                        "ccv_common_clk, whose ccv_common_ctech_icg becomes the "
                        "library's cell in synthesis. An AND gate glitches "
                        "when its enable moves while the clock is high, and "
                        "no RTL simulation shows it" % (lhs, rhs[:40]))
            for m in re.finditer(r"\balways_latch\b", src):
                add("CCV-L27", line_of(src, m.start()),
                    "a latch outside rtl/ctech/. The only latch in the design "
                    "is the one inside the ctech ICG's simulation view; "
                    "anything else that needs one is a ctech cell")

        # -- CCV-L21: stage tags are well formed and consistent -------------
        for kind, clk, body, ln, pos in always_blocks(src):
            if kind != "ff" or not clk or reusable(pos):
                continue
            blk_name = blk_name_at(pos)
            blk_letter = letter_of.get(blk_name)
            cbase, edge = clk[0].split(".")[-1], clk[1]
            dom_seg = clk_domain(cbase)
            want_dom = domains["by_segment"].get(dom_seg) if domains else None
            want_edge = "h" if edge == "pos" else "l"
            for am in re.finditer(r"([a-z]\w*)\s*(?:\[[^\]]*\])?\s*<=", body):
                lhs = am.group(1)
                st = stage_of(lhs)
                if st is None:
                    continue
                d, b, num, e = st
                aln = ln + body[:am.start()].count("\n")
                if want_dom and d != want_dom:
                    add("CCV-L21", aln,
                        "%s is tagged domain %r but is generated by %s, whose "
                        "domain is %r (%s). A signal labelled for the wrong "
                        "domain is how a crossing hides"
                        % (lhs, d, cbase, want_dom, dom_seg))
                if e != want_edge:
                    add("CCV-L21", aln,
                        "%s is tagged edge %r but is generated on %sedge %s"
                        % (lhs, e, edge, cbase))
                if blocks and b not in blocks:
                    add("CCV-L21", aln,
                        "%s carries block letter %r, which is not registered "
                        "in params/blocks.json" % (lhs, b))
                elif blk_letter and b != blk_letter and b != "r":
                    add("CCV-L21", aln,
                        "%s carries block letter %r but is generated in block "
                        "%s (letter %r), by its module's name. A block may "
                        "only generate signals in its own numbering space"
                        % (lhs, b, blk_name, blk_letter))

        # -- CCV-L29: every net of a sequential block module is tagged ------
        # The stage rules above key on the tag, so a net without one is a
        # net they never check: a register on it escapes L21, and anything
        # that reads it escapes L23 (DA, 2026-10-23). A module with no
        # register is exempt: an inner helper is timed as its parent's logic
        # and may sit at any stage, as a struct type may.
        for s0, e0, n, _ in spans:
            if cls[n].kind not in ("block", "wrapper", "sub"):
                continue
            body = src[s0:e0]
            hdr = re.search(r"\)\s*;", body)
            if not hdr or not re.search(r"\balways_ff\b", body):
                continue
            _stage_ratchet["seen"].add(n)
            listed = set(stage_ratchet().get(n, []))
            for pos, net in module_nets(body, hdr.end()):
                if UNSTAGED_RE.search(net) or stage_of(net):
                    continue
                if net in listed:
                    _stage_ratchet["found"].add((n, net))
                    continue
                add("CCV-L29", line_of(src, s0 + pos),
                    "net %s of module %s carries no stage tag. Every net of a "
                    "block's sequential module says when it is valid, "
                    "<name>_<domain><block><NN><l|h>; untagged, CCV-L21 and "
                    "CCV-L23 never check it, nor anything it reaches" % (net, n))

        # -- CCV-L23: stage arithmetic --------------------------------------
        # The rule the whole convention exists to make checkable:
        #   flop output  = max(input stages) + 1
        #   combinational = max(input stages)
        #
        # Exempt: a register's own stage in its next value (OI's question,
        # OI-65, 2026-10-21): a register at stage N that reads state at stage
        # N -- itself, a hold or a counter, or another register of the same
        # stage, a queue's next value reading its own count -- is a state
        # machine's feedback, not a stage skip; everything else it reads
        # must be at N - 1. Reset nets (block letter `r` -- the reset tree
        # has its own numbering because it is pipelined by physical distance,
        # not by datapath depth), and any right-hand side with no tagged
        # signals at all. Continuous assignments are combinational and held
        # to the same arithmetic: a tagged net driven by an assign was once
        # unchecked, which invited untagged nets to carry a stage mix.
        # The same feedback seen from the D side: a combinational net at
        # stage N - 1 that is read only by flops (a stage-N register's next
        # value or enable, built apart from its always_ff) may read the
        # stage-N state it updates. Read anywhere else, it is held to the
        # plain arithmetic.
        # Declared feedback (OA's ruling on TI-38): verified here, each against
        # the loop it claims; only a verified read leaves the arithmetic.
        graph = dep_graph(src)
        fb_ok = {}
        ddeps = data_graph(src)
        byp_ok = {}
        for s0, e0, n, ln0 in spans:
            fp, decl, byp, tbl = feedback_decls(os.path.dirname(path), n)
            signers = feedback_signers(os.path.dirname(path))
            body = src[s0:e0]
            # A declared table (DA rev 131, OA 452): verified against all seven
            # conditions, the timing's (6) being check-ngd's, which measures
            # the read whatever the tags say, and the fixtures' (7) check-1d's.
            mports = module_headers(src).get(n, ({}, ""))[0]
            for arr, d in sorted(tbl.items()):
                # A table read through an input port (OA-492 (3)): the words
                # are a register of a sibling, written at its stage and read
                # here earlier, never in a cycle it is written.
                if mports.get(arr) == "input":
                    why = verify_port_table(n, arr, d, body, graph, signers, path)
                    if why:
                        add("CCV-L23", ln0, "%s: table %s (an input port) is refused: %s"
                            % (fp, arr, why))
                    else:
                        fb_ok.setdefault(d.get("reader"), set()).add(arr)
                    continue
                readers = d.get("readers", [])
                why = None
                sa = stage_of(arr)
                words, dtext = array_decl(body, arr)
                if d.get("by") not in signers:                  # (1)
                    why = ("not an architect's (by %r, not one of %s): each is reviewed "
                           "alone before it is listed" % (d.get("by"), ", ".join(signers)))
                elif not isinstance(readers, list) or not readers:
                    why = "it names no reader: write \"readers\": [\"<reader>\", ...]"
                elif dtext is None:
                    why = "%s is not declared in %s" % (arr, n)
                elif words is None or words < 2:                # (2)
                    why = ("%s is not an array: a table is an unpacked dimension of 2 or "
                           "more words, read only through an index, never a plain register"
                           % arr)
                elif sa is None:
                    why = "%s carries no stage tag: a table keeps its writer's" % arr
                if why:
                    add("CCV-L23", ln0, "%s: table %s is refused: %s" % (fp, arr, why))
                    continue
                # (2) read only through an index; (3) written only in an
                # always_ff, under an enable, one stage past its write data,
                # index and enable.
                wr, rd_bare = [], False
                for kind, clk, b, bl, bpos in always_blocks(body):
                    regions = cond_regions(b)
                    for apos, lhs, op, rhs in assignments(b):
                        if lhs != arr:
                            continue
                        lidx = re.match(r"\s*%s\s*\[([^\]]*)\]" % re.escape(arr), b[apos:])
                        conds = [c for a0, a1, c in regions if a0 <= apos < a1]
                        wr.append((kind, rhs, lidx.group(1) if lidx else "", conds))
                for m in re.finditer(r"\bassign\s+[^;]+;", body):
                    for _, lhs, _, _ in assignments(m.group(0)[len("assign"):]):
                        if lhs == arr:
                            wr.append(("assign", "", "", []))
                # OA-479 (b) (Daniel, 2026-11-24): one loop writer and later
                # writers from other pipelines, every one listed with its
                # stage; each non-loop writer's own registers (its data, index
                # and enable) are held to the arithmetic up to the write port,
                # where the port's nets may read them.
                wl, wsig, why = two_writers(d, sa, arr)
                cnets, leaves = set(), set()
                if not why and wl is not None:
                    roots = set(w for k, rhs, li, c in wr
                                for w in IDENT_RE.findall(" ".join([rhs, li] + c))) - {arr}
                    cnets, cregs = cone(graph[0], graph[1], roots)
                    leaves = cregs | set(x for x in cnets if x not in graph[0])
                    cnets -= leaves
                    loopw = [w for w in wl if w.get("loop")][0]
                    for w in wl:
                        for x in w["sigs"]:
                            sx = stage_of(x)
                            if sx is None or sx[2] != w["stage"]:
                                why = ("writer %s's %s is not tagged at its stage %02d: a "
                                       "writer's data, index and enable are its own, held to "
                                       "the arithmetic up to the write port"
                                       % (w["name"], x, w["stage"]))
                            elif x not in leaves and x not in cnets:
                                why = ("writer %s's %s does not reach the write port of %s "
                                       "(a stale writer is refused)" % (w["name"], x, arr))
                            if why:
                                break
                        if why:
                            break
                    owned = set()
                    for w in wl:
                        if w.get("loop"):
                            continue
                        for x in w["sigs"]:
                            if x in cnets:
                                owned |= set(y for y in cone(graph[0], graph[1], [x])[1]
                                             if stage_of(y) and stage_of(y)[2] == w["stage"])
                    if not why:
                        und = sorted(x for x in leaves
                                     if x not in wsig and x not in owned and x != arr
                                     and stage_of(x) and stage_of(x)[1] != "r"
                                     and stage_of(x)[2] > sa[2] - 1)
                        if und:
                            why = ("an undeclared writer reaches its write port: %s, at stage "
                                   "%s, past the loop writer's %02d; list every writer with "
                                   "its stage" % (", ".join(und), ",".join(
                                       sorted(set("%02d" % stage_of(x)[2] for x in und))),
                                       sa[2] - 1))
                    if not why and not (set(readers) & cnets or set(readers) & leaves):
                        why = ("its loop writer %s reads no listed reader: a loop writer "
                               "writes back what the table's own read gave" % loopw["name"])
                if why:
                    pass
                elif not wr:
                    why = "%s is never written" % arr
                elif any(k != "ff" for k, _, _, _ in wr):
                    why = "%s is written outside an always_ff" % arr
                elif any(not c for _, _, _, c in wr):
                    why = "%s is written without an enable: write it only under an if" % arr
                else:
                    ins = [stage_of(w)[2] for k, rhs, li, c in wr
                           for w in re.findall(r"[a-z]\w*", " ".join([rhs, li] + c))
                           if stage_of(w) and stage_of(w)[1] != "r" and w != arr
                           and w not in wsig]
                    if not ins:
                        why = "%s's writes read no tagged signal, so its tag is no writer's" % arr
                    elif sa[2] != max(ins) + 1:
                        why = ("%s is tagged stage %02d, but its writes' data, index and enable "
                               "reach stage %02d: a table keeps its writer's tag, one past it"
                               % (arr, sa[2], max(ins)))
                outside = re.sub(r"\b%s\s*\[[^\]]*\]\s*(<=|=)(?!=)" % re.escape(arr), "", body)
                if not why and index_reads(outside, arr)[1]:
                    why = "%s is read whole somewhere: a table is read only through an index" % arr
                if why:
                    add("CCV-L23", ln0, "%s: table %s is refused: %s" % (fp, arr, why))
                    continue
                # (1) every reader reads it; (4) through an index at its own stage.
                # A row-register table (DI-51) is read by a loop over its rows,
                # each selected by a compare of a tagged index with the row's
                # number: that compare's tagged side is the read's index.
                loopv = loop_vars(body)
                wen = set(w for _, _, _, c in wr for w in IDENT_RE.findall(" ".join(c)))
                ridx = set()
                okr = []
                for reader in readers:
                    sr = stage_of(reader)
                    if arr not in graph[0].get(reader, ()):
                        add("CCV-L23", ln0, "%s: table %s lists reader %s, which does not read "
                            "it: remove it (a stale reader is refused)" % (fp, arr, reader))
                        continue
                    if sr is None:
                        add("CCV-L23", ln0, "%s: table %s's reader %s carries no stage tag"
                            % (fp, arr, reader))
                        continue
                    seqr = reader in graph[1]
                    at = sr[2] - 1 if seqr else sr[2]
                    exprs = []
                    for kind, clk, b, bl, bpos in always_blocks(body):
                        regions = cond_regions(b)
                        for apos, lhs, op, rhs in assignments(b):
                            if lhs == reader:
                                ctx = [c for a0, a1, c in regions if a0 <= apos < a1] + [rhs]
                                exprs += [row_index(e, ctx, loopv)
                                          for e in index_reads(rhs, arr)[0]]
                    for m in re.finditer(r"\bassign\s+[^;]+;", body):
                        for _, lhs, _, rhs in assignments(m.group(0)[len("assign"):]):
                            if lhs == reader:
                                exprs += [row_index(e, [rhs], loopv)
                                          for e in index_reads(rhs, arr)[0]]
                    # A row's own read-modify-write (DI-53): the row's value is
                    # read through its loop variable and written back to the
                    # same row; its compare is in the write's enable.
                    wctx = []
                    for k, rhs, li, c in wr:
                        if reader in IDENT_RE.findall(rhs) and li.strip() in loopv:
                            for cc in c:
                                wctx.append(cc)
                                for nm in IDENT_RE.findall(cc):
                                    for m in re.finditer(r"\bassign\s+%s\s*=\s*([^;]+);"
                                                         % re.escape(nm), body):
                                        wctx.append(m.group(1))
                    if wctx:
                        exprs = [row_index(e, wctx, loopv) for e in exprs]
                    bad_ix = None
                    for e in exprs:
                        ridx.update(re.findall(r"[a-z]\w*", e))
                    for e in exprs or [""]:
                        ws = [w for w in re.findall(r"[a-z]\w*", e)]
                        tags = [stage_of(w) for w in ws]
                        if not ws or any(t is None for t in tags):
                            bad_ix = "its index %r is not a tagged register" % e.strip()
                        elif max(t[2] for t in tags) != at or \
                                not any(w in graph[1] or (stage_of(w)[2] == at) for w in ws):
                            bad_ix = ("its index %r is at stage %02d, not the reader's own "
                                      "(%02d%s)" % (e.strip(), max(t[2] for t in tags), at,
                                                    ", its D side" if seqr else ""))
                        if bad_ix:
                            break
                    if bad_ix:
                        add("CCV-L23", ln0, "%s: table %s's read by %s is refused: %s"
                            % (fp, arr, reader, bad_ix))
                        continue
                    okr.append(reader)
                # (5), two writers (OA-479 (iii)): every non-loop writer's
                # enable is asserted against the read (no read of a word in
                # the cycle it writes it, nor the next) and against the loop
                # writer's enable (no write conflict at the port).
                if wl is not None:
                    asserts = [set(IDENT_RE.findall(balanced(body, m.end() - 1)[0]))
                               for m in ASSERT_RE.finditer(body)]
                    le = set(loopw["enable"])
                    for w in wl:
                        if w.get("loop"):
                            continue
                        we = set(w["enable"])
                        if not any(ids & we and (arr in ids or ids & ridx) for ids in asserts):
                            why = ("writer %s's enable (%s) is named in no assertion with "
                                   "the read: no lookup reads a word it wrote in that cycle "
                                   "or the next (a forward is a bypass, declared as one)"
                                   % (w["name"], ", ".join(sorted(we))))
                        elif not any(ids & we and ids & le for ids in asserts):
                            why = ("writer %s's enable (%s) is named in no assertion with "
                                   "the loop writer's (%s): no write conflict at the port"
                                   % (w["name"], ", ".join(sorted(we)), ", ".join(sorted(le))))
                        if why:
                            break
                    if why:
                        add("CCV-L23", ln0, "%s: table %s is refused: %s" % (fp, arr, why))
                        continue
                    for x in cnets:
                        hit = graph[0].get(x, set()) & wsig
                        if hit:
                            fb_ok.setdefault(x, set()).update(hit)
                    for reader in okr:
                        fb_ok.setdefault(reader, set()).add(arr)
                    continue
                # (5) an assertion naming the write enable and the read.
                named = False
                for m in ASSERT_RE.finditer(body):
                    txt = balanced(body, m.end() - 1)[0]
                    ids = set(IDENT_RE.findall(txt))
                    if ids & wen and (arr in ids or ids & ridx):
                        named = True
                        break
                if not named:
                    add("CCV-L23", ln0,
                        "%s: table %s is refused: %s holds no assertion naming its write "
                        "enable (%s) and its read, that a word is never read in the cycle it "
                        "is written (a same-cycle forward is a bypass, declared as one)"
                        % (fp, arr, n, ", ".join(sorted(wen)) or "none"))
                    continue
                for reader in okr:
                    fb_ok.setdefault(reader, set()).add(arr)
            # A declared bypass (DA, 2026-10-23; OI-72 (A)): a reader at stage
            # N that reads a later pipeline copy of its own stage's register,
            # a bypass mux around a table written late. Each is reviewed, and
            # the lint holds it to the copy it claims: the tags give exactly
            # the declared offset, and the register read is that many stages
            # on from a register at the reader's stage in its pipeline.
            for reader, d in sorted(byp.items()):
                reads = d.get("from", {})
                if d.get("by") not in signers:
                    add("CCV-L23", ln0,
                        "%s: %s's declared bypass is not an architect's (by %r, not one of "
                        "%s): each is reviewed before it is listed"
                        % (fp, reader, d.get("by"), ", ".join(signers)))
                    continue
                if not isinstance(reads, dict) or not reads:
                    add("CCV-L23", ln0,
                        "%s: %s's declared bypass names no read: write \"from\": "
                        "{\"<register>\": <stages ahead>, ...}" % (fp, reader))
                    continue
                for rd, ahead in sorted(reads.items()):
                    sr, sx = stage_of(reader), stage_of(rd)
                    if rd not in graph[0].get(reader, ()):
                        add("CCV-L23", ln0,
                            "%s: %s is declared to read %s as a bypass, but does not "
                            "read it: remove the declaration" % (fp, reader, rd))
                    elif sr is None or sx is None:
                        add("CCV-L23", ln0,
                            "%s: %s's bypass read of %s is checked by their stage tags, "
                            "and %s carries none" % (fp, reader, rd, reader if sr is None else rd))
                    elif not isinstance(ahead, int) or ahead < 1:
                        add("CCV-L23", ln0,
                            "%s: %s's bypass read of %s is declared %r stages ahead: a "
                            "bypass reads a later stage's copy" % (fp, reader, rd, ahead))
                    elif sx[2] - sr[2] != ahead:
                        add("CCV-L23", ln0,
                            "%s: %s (stage %02d) reads %s (stage %02d), %d stage(s) ahead, "
                            "but its bypass is declared %d ahead" % (fp, reader, sr[2], rd, sx[2],
                                                                   sx[2] - sr[2], ahead))
                    else:
                        why = bypass_path(ddeps, graph[1], reader, rd, ahead)
                        if why:
                            add("CCV-L23", ln0, "%s: %s's declared bypass of %s does not hold: %s"
                                % (fp, reader, rd, why))
                        else:
                            # Counted at the stage it stands for, the register's
                            # less its offset: the reader's own (OI's rev 189,
                            # OA's rev 212), so its other inputs stay checked.
                            byp_ok.setdefault(reader, {})[rd] = ahead
            for reader, d in sorted((k, v) for k, v in decl.items() if "." not in k):
                reads = d.get("from", [])
                if d.get("by") not in signers:
                    add("CCV-L23", ln0,
                        "%s: %s's declared feedback reads are not an architect's (by %r, "
                        "not one of %s): each is reviewed before it is listed"
                        % (fp, reader, d.get("by"), ", ".join(signers)))
                    continue
                # Each read with the alignment it is declared at (DA, 2026-10-23):
                # how many stages its tag lies ahead of its reader's. The
                # declaration does not take the read out of the alignment
                # check; it states the alignment the loop has, and the tags
                # must give exactly that.
                if not isinstance(reads, dict):
                    add("CCV-L23", ln0,
                        "%s: %s's declared feedback reads give no alignment: write "
                        "\"from\": {\"<read>\": <stages ahead>, ...}, which the "
                        "tags must match" % (fp, reader))
                    continue
                for rd, ahead in sorted(reads.items()):
                    sr, sx = stage_of(reader), stage_of(rd)
                    if rd not in graph[0].get(reader, ()):
                        add("CCV-L23", ln0,
                            "%s: %s is declared to read %s as feedback, but does not "
                            "read it: remove the declaration" % (fp, reader, rd))
                    elif sr is None or sx is None:
                        add("CCV-L23", ln0,
                            "%s: %s's feedback read of %s is checked by their stage "
                            "tags, and %s carries none" % (fp, reader, rd,
                                                           reader if sr is None else rd))
                    elif not isinstance(ahead, int) or ahead < 1:
                        add("CCV-L23", ln0,
                            "%s: %s's read of %s is declared %r stages ahead: a "
                            "feedback read lies one stage or more ahead of its reader, "
                            "and one that does not needs no declaration"
                            % (fp, reader, rd, ahead))
                    elif sx[2] - sr[2] != ahead:
                        add("CCV-L23", ln0,
                            "%s: %s (stage %02d) reads %s (stage %02d), %d stage(s) "
                            "ahead, but is declared %d ahead: the loop's tags do not "
                            "give the alignment declared" % (fp, reader, sr[2], rd, sx[2],
                                                             sx[2] - sr[2], ahead))
                    elif "loop" in d:
                        why = loop_path(graph[0], graph[1], reader, rd, d["loop"])
                        if why:
                            add("CCV-L23", ln0,
                                "%s: %s's declared loop %s for its read of %s does not "
                                "hold: %s" % (fp, reader, " -> ".join(d["loop"]), rd, why))
                        else:
                            fb_ok.setdefault(reader, set()).add(rd)
                    elif not feedback_loop(graph[0], graph[1], reader, rd):
                        add("CCV-L23", ln0,
                            "%s: %s reads %s as declared feedback, but no register "
                            "%s comes from has a next value that depends on %s's "
                            "register: there is no loop for the read to close (a "
                            "longer loop is declared by its registers, \"loop\")"
                            % (fp, reader, rd, rd, reader))
                    else:
                        fb_ok.setdefault(reader, set()).add(rd)

        def rhs_stages(expr, lhs, own=None):
            out = []
            for w in re.findall(r"[a-z]\w*", expr):
                if w == lhs or w in fb_ok.get(lhs, ()):
                    continue
                st = stage_of(w)
                if st and st[1] != "r" and st[2] != own:
                    out.append(st[2] - byp_ok.get(lhs, {}).get(w, 0))
            return out

        ff_spans = [(pos, pos + len(body)) for kind, clk, body, ln, pos in always_blocks(src)
                    if kind == "ff"]
        def d_side(net):
            """Every read of net is inside an always_ff."""
            reads = [m.start() for m in re.finditer(r"\b%s\b" % re.escape(net), src)
                     if not re.match(r"\s*(?:\[[^\]]*\]\s*)?=(?!=)", src[m.end():])]
            reads = [r for r in reads if not re.search(r"\blogic\b[^;]*$", src[max(0, r - 200):r])]
            return bool(reads) and all(any(a <= r < b for a, b in ff_spans) for r in reads)

        blocks = [(kind, body, ln, pos) for kind, clk, body, ln, pos in always_blocks(src)]
        for m in re.finditer(r"\bassign\s+[^;]+;", src):
            blocks.append(("assign", m.group(0)[len("assign"):], line_of(src, m.start()),
                           m.start()))
        for kind, body, ln, pos in blocks:
            if reusable(pos):
                continue
            seq = (kind == "ff")
            regions = cond_regions(body) if kind != "assign" else []
            for apos, lhs, op, rhs in assignments(body):
                st = stage_of(lhs)
                if st is None or st[1] == "r":
                    continue
                # The conditions it is assigned under count as its inputs.
                rhs = " ".join([rhs] + [c for a0, a1, c in regions if a0 <= apos < a1])
                ins = rhs_stages(rhs, lhs, st[2] if seq else
                                 st[2] + 1 if kind in ("assign", "comb") and d_side(lhs) else None)
                if not ins:
                    continue
                want = max(ins) + (1 if seq else 0)
                if st[2] != want:
                    aln = ln + body[:apos].count("\n")
                    add("CCV-L23", aln,
                        "%s is at stage %02d but %s logic over stage(s) %s "
                        "gives %02d. %s"
                        % (lhs, st[2], "sequential" if seq else "combinational",
                           ",".join("%02d" % i for i in sorted(set(ins))), want,
                           "A flop advances exactly one stage."
                           if seq else
                           "Combinational logic does not advance a stage."))

        # -- CCV-L25: sequential enables are `if`, not a feedback mux -------
        #
        # Both spellings synthesise to the same enable flop in Yosys (F-17),
        # so this is NOT a correctness rule -- it is a statement of intent.
        # An `if` says "this is a gating candidate"; a feedback mux says
        # "this is a mux". Commercial gating insertion is more reliably
        # triggered by the former, and the project has chosen to write RTL for
        # where the flow is going rather than for what Yosys does today.
        #
        # I argued against linting this one revision ago, on the grounds that
        # it would enforce tool behaviour nobody here can measure. That was
        # right about the evidence and wrong about the rule: what is being
        # enforced is a design decision, not a belief about a tool, and a
        # design decision is exactly the kind of thing lint is for.
        #
        # `CCV_XHOLD is the sanctioned escape and is naturally exempt -- a
        # macro call carries no ternary for this to match.
        for kind, clk, body, ln, pos in always_blocks(src):
            if kind != "ff" or reusable(pos):
                continue
            for am in re.finditer(
                    r"([a-z]\w*)\s*<=\s*([^;]*\?[^;]*);", body):
                lhs, rhs = am.group(1), am.group(2)
                if not re.search(r"[:?]\s*%s\s*$" % re.escape(lhs), rhs.strip()):
                    continue
                add("CCV-L25", ln + body[:am.start()].count("\n"),
                    "%s is held by a feedback mux inside always_ff. Write the "
                    "enable as `if`, which states that it is a clock-gating "
                    "candidate; use `CCV_XHOLD only where the enable cannot "
                    "be proven X-free" % lhs)

        # -- CCV-L26: nothing Yosys cannot parse ---------------------------
        #
        # Verilator and Icarus both accept these, so simulation is green and
        # the file only dies when it reaches formal -- the one flow whose
        # failure a designer is least likely to be running while writing. The
        # checker hit exactly this (2026-09-25): its first per-message age
        # queue was a 2-D packed array with int'() casts, and it took down the
        # sby cover run. Measured against Yosys 0.33, not assumed:
        #
        #   REJECTED  logic [A][B] x;   as a declaration or a PORT
        #             int'(e) integer'(e) shortint'(e) longint'(e) byte'(e)
        #             foo_t'(e)         a cast to a typedef name
        #   ACCEPTED  logic [A][B] f;   as a member INSIDE a packed struct
        #             signed'(e) unsigned'(e) W'(e) 6'(e)
        #             logic [A] x [B];  an unpacked array
        #
        # So packed-struct bodies are removed before matching, and only the
        # rejected cast spellings are flagged. A rule that flags what the tool
        # accepts gets exempted, and an exemption habit is how rules die.
        nostruct = re.sub(r"struct\s+packed\s*\{.*?\}", "", src, flags=re.S)
        for m in re.finditer(
                r"\b(?:logic|bit|reg|wire)\s+(?:signed\s+|unsigned\s+)?"
                r"\[[^\]]+\]\s*\[[^\]]+\]\s*[A-Za-z_]", nostruct):
            add("CCV-L26", line_of(nostruct, m.start()),
                "multi-dimensional packed array: Yosys 0.33 rejects it as a "
                "declaration or port, so this passes both simulators and "
                "fails formal. Flatten to one vector and index with "
                "part-selects (x[i*W +: W]), or wrap it in a packed struct")
        # A packed array of a typedef'd type (`slot_t [N] x`). Worse than a
        # rejection: Yosys ACCEPTS it as a port, sizes it by the array bound
        # alone, and turns the struct's fields into implicit 1-bit nets, with
        # only warnings (measured 2026-09-26). One port per element instead,
        # each of the struct type -- which is what the generated top does.
        for m in re.finditer(r"\b([a-z]\w*_t)\s*\[[^\]]+\]\s*[A-Za-z_]", nostruct):
            add("CCV-L26", line_of(nostruct, m.start()),
                "packed array of %s: Yosys 0.33 accepts it and mis-elaborates "
                "it silently (the port is sized by the array bound, the fields "
                "become implicit nets). Use one %s-typed port or net per "
                "element" % (m.group(1), m.group(1)))
        for m in re.finditer(
                r"\b(int|integer|shortint|longint|byte|[a-z]\w*_t)\s*'\s*\(",
                src):
            add("CCV-L26", line_of(src, m.start()),
                "%s'(...) cast: Yosys 0.33 rejects casts to a type keyword or "
                "a typedef name. Size casts (W'(x), 6'(x)) and "
                "signed'/unsigned' are accepted" % m.group(1))

        # -- CCV-L24: `_b` is a derived complement --------------------------
        # `_n` is a semantic property of a signal that is DEFINED active-low
        # and carries no obligation. `_b` claims to be the complement of a net
        # that exists, which is checkable and worth checking: a `_b` that is
        # not actually inverted is a sign flip nobody sees.
        for apos, lhs, _, rhs in assignments(src):
            if not lhs.endswith("_b"):
                continue
            sib = lhs[:-2]
            ln = line_of(src, apos)
            # Only the inversion is required. An earlier version also
            # demanded a same-named sibling net, which is wrong: `_b` is the
            # complement of a VALUE, and that value is frequently an
            # expression or a bit-select rather than a net of its own.
            if not re.search(r"[~!]", rhs):
                add("CCV-L24", ln,
                    "%s_b is driven without an inversion. `_b` names a "
                    "complement; if this is not inverted it is either a sign "
                    "flip or the wrong suffix -- use `_n` for a signal that "
                    "is simply defined active-low" % sib)

    # -- CCV-L23 across a connection (OA 481-483) --------------------------
    if scope == "design" and not rel.startswith(("rtl/top/", "rtl/generated/")):
        check_connections(src, rel, add, feedback_signers(os.path.dirname(path)),
                          os.path.dirname(path))

    return F


# -- CCV-L23 across a connection (OA 481-483, TI-554..556; MI-35) -----------
# A child's port tags are its own numbering, not the parent's: a parent may
# feed a child's cq01h input from a cq04h net. So a connection is held to the
# arithmetic relatively. For each instance and each child output O that
# depends, through the child's own nets and registers, on a child input I, the
# parent's nets must give P(O) - P(I) >= S(O) - S(I): no output is tagged
# earlier than the child's own latency from that input allows. The deficit
# (S(O) - S(I)) - (P(O) - P(I)) of 1 through a register is OI-65's same-stage
# feedback, exempt as it is inside a module (OA 482); anything else is fixed,
# declared as a cross-module loop in the parent's <parent>.feedback.json, or
# stood when the check was made (rtl/conn-ratchet.json, shrink-only). A
# connection with an untagged port or net is a finding too (OA 481 (1)).
# Out of scope, by name: children with a register under rtl/common,
# rtl/ctech, rtl/macro and rtl/clk (library modules, whose ports carry no
# stage: CCV-L29 holds a block's sequential modules only); a register-free
# one there is a helper like any other, traced at zero latency (OA 485). And
# the generated design
# (rtl/top, rtl/generated), outside the per-file walk, whose channels cross
# repeaters by params/links.json and are held there by check-links.
CONN_RATCHET = os.path.join(ROOT, "rtl", "conn-ratchet.json")
CONN_BASELINE = os.path.join(ROOT, "tools", "conn-ratchet-baseline.json")
CONN_OUT = ("rtl/common/", "rtl/ctech/", "rtl/macro/", "rtl/clk/")
_conn = {"path": CONN_RATCHET, "baseline": CONN_BASELINE, "entries": None,
         "found": set(), "seen": set(), "index": None}


_units = {"mods": None}


def unit_modules():
    """Modules with a timing unit (test/**/cg-units.json or ngd-units.json)."""
    if _units["mods"] is None:
        mods = set()
        for d, _, fns in os.walk(os.path.join(ROOT, "test")):
            for fn in fns:
                if fn in ("cg-units.json", "ngd-units.json"):
                    try:
                        u = json.load(open(os.path.join(d, fn))).get("units", [])
                    except (OSError, ValueError):
                        continue
                    for e in (u.values() if isinstance(u, dict) else u):
                        if isinstance(e, dict) and e.get("module"):
                            mods.add(e["module"])
        # check-1d's fixtures have no timing unit; CCV_LINT_FIXTURE_UNITS
        # names those it treats as verified, and only reference_* fixture
        # modules (rtl/lint/), never the design's.
        for m in os.environ.get("CCV_LINT_FIXTURE_UNITS", "").split(","):
            if m.strip().startswith("reference_"):
                mods.add(m.strip())
        _units["mods"] = mods
    return _units["mods"]


def conn_ratchet():
    if _conn["entries"] is None:
        p = _conn["path"]
        _conn["entries"] = (json.load(open(p)).get("entries", []) if os.path.exists(p) else [])
    return _conn["entries"]


def conn_key(e):
    return tuple(e.get(k) for k in ("parent", "instance", "port", "net", "net_stage",
                                    "port_stage", "deficit", "kind"))


def module_headers(src):
    """{module: (ports {name: direction}, body)} for comment-stripped text."""
    out = {}
    for m in re.finditer(r"\bmodule\s+([a-z]\w*)\b", src):
        j = m.end()
        k = re.match(r"\s*#\s*\(", src[j:])
        if k:
            _, j = balanced(src, j + k.end() - 1)
        k = re.match(r"\s*\(", src[j:])
        if not k:
            continue
        plist, j = balanced(src, j + k.end() - 1)
        # A block top's port list is generated and included (`include
        # "<top>_ports.svh", rtl/generated/): read it in place.
        # (strip_comments blanks the string, so it is found by its name).
        if "`include" in plist:
            q = os.path.join(ROOT, "rtl", "top", "ports", m.group(1) + "_ports.svh")
            if os.path.exists(q):
                plist = plist.replace("`include", strip_comments(open(q).read()), 1)
        e = src.find("endmodule", j)
        ports, d = {}, None
        for tok in re.finditer(r"\b(input|output|inout)\b|\[[^\]]*\]|([a-z]\w*)\s*(?=,|$)",
                               plist.replace("\n", " ")):
            if tok.group(1):
                d = tok.group(1)
            elif tok.group(2) and d:
                ports[tok.group(2)] = d
        out[m.group(1)] = (ports, src[j:e if e >= 0 else len(src)])
    return out


def module_index():
    """{module: (rel path, ports, body)} over rtl/ (the generated design and
    the lint fixtures aside), read once a run."""
    if _conn["index"] is None:
        idx = {}
        for d, _, fns in os.walk(os.path.join(ROOT, "rtl")):
            reld = os.path.relpath(d, ROOT).replace(os.sep, "/") + "/"
            if reld.startswith(("rtl/top/", "rtl/generated/", "rtl/lint/")):
                continue
            for fn in fns:
                if fn.endswith(".sv"):
                    full = os.path.join(d, fn)
                    for n, (ports, body) in module_headers(strip_comments(open(full).read())).items():
                        idx.setdefault(n, (reld + fn, ports, body))
        _conn["index"] = idx
    return _conn["index"]


def conn_ids(expr):
    """The nets an instance connection reads: base names, never an index,
    a member after a dot, a constant or a parameter."""
    expr = re.sub(r"\[[^\]]*\]", " ", expr)
    return [w for w in re.findall(r"(?<![.\w'])[a-z]\w*", expr)
            if not UNSTAGED_RE.search(w) and w not in ("rst_n",)]


def port_paths(body, ports):
    """({output: {input: comb}}): for each output, the inputs it depends on,
    through the module's nets and registers, and whether some path is
    combinational (no register on it)."""
    deps, flops = dep_graph(body)
    ins = {p for p, d in ports.items() if d == "input"}
    out = {}
    for o, d in ports.items():
        if d != "output":
            continue
        reach = {}
        todo, seen = [(o, o not in flops)], set()
        while todo:
            n, comb = todo.pop()
            for x in deps.get(n, ()):
                c = comb and x not in flops
                if x in ins:
                    reach[x] = reach.get(x, False) or c
                if (x, c) in seen or x in ins:
                    continue
                seen.add((x, c))
                todo.append((x, c))
        if reach:
            out[o] = reach
    return out


def check_connections(src, rel, add, signers, fbdir):
    """CCV-L23 across each instance connection of the file's modules."""
    local = module_headers(src)
    idx = module_index()
    entries = {conn_key(e) for e in conn_ratchet()}
    for parent, (pports, pbody) in local.items():
        _conn["seen"].add(parent)
        # A module with no register of its own is its parent's logic (an
        # inner helper; CCV-L29 tags a block's sequential modules only): its
        # ports and nets carry no stage, and a path through it is the
        # parent's combinational logic, held to the plain arithmetic.
        pseq = bool(dep_graph(pbody)[1])
        fp, decl, _, _ = feedback_decls(fbdir, parent)
        xdecl = {k: v for k, v in decl.items() if "." in k}
        table_regs = sibling_tables(pbody, local, idx, fbdir)
        used = set()
        for m in re.finditer(r"\b([a-z]\w*)\s*(#\s*\()?", pbody):
            child = m.group(1)
            if child == parent:
                continue
            if child in local:
                crel, cports, cbody = rel, local[child][0], local[child][1]
            elif child in idx:
                crel, cports, cbody = idx[child]
            elif os.path.exists(os.path.join(fbdir, child + ".sv")):
                sib = module_headers(strip_comments(open(os.path.join(fbdir, child + ".sv")).read()))
                if child not in sib:
                    continue
                crel = os.path.relpath(os.path.join(fbdir, child + ".sv"), ROOT)
                cports, cbody = sib[child]
            else:
                continue
            # A library module with a register (a macro, a clock gate) is out of
            # scope; one with none is a helper like any other (OA 485).
            if crel.startswith(CONN_OUT) and (dep_graph(cbody)[1] or
                                              re.search(r"\balways_latch\b", cbody)):
                continue
            j = m.end()
            if m.group(2):
                _, j = balanced(pbody, j - 1)
            k = re.match(r"\s*([a-z]\w*)\s*(?:\[[^\]]*\]\s*)?\(\s*\.", pbody[j:])
            if not k:
                continue
            inst = k.group(1)
            cseq = bool(dep_graph(cbody)[1])
            txt, _ = balanced(pbody, pbody.index("(", j + k.end(1)))
            ln = line_of(src, src.find(pbody) + m.start()) if pbody in src else 1
            pt = {}
            # An output whose net the parent never reads (unconnected, or
            # connected to a net nothing else names) reaches nothing (OI-219).
            read_outs = set()
            rest = pbody.replace(txt, " ")
            rest = re.sub(r"\b(?:logic|wire|reg)\b[^;]*;", " ", rest)
            for c in re.finditer(r"\.([a-z]\w*)\s*(\()?", txt):
                if cports.get(c.group(1)) == "output":
                    ex = balanced(txt, c.end() - 1)[0] if c.group(2) else c.group(1)
                    if any(n in pports or re.search(r"\b%s\b" % re.escape(n), rest)
                           for n in conn_ids(ex)):
                        read_outs.add(c.group(1))
            for c in re.finditer(r"\.([a-z]\w*)\s*(\()?", txt):
                port = c.group(1)
                if UNSTAGED_RE.search(port) or port not in cports:
                    continue
                expr = balanced(txt, c.end() - 1)[0] if c.group(2) else port
                ids = conn_ids(expr)
                if not ids:
                    continue
                for w in ids:
                    # A block top's own boundary ports carry the schema's channel
                    # names, untagged by design; the channel's timing is the
                    # interface's (excluded by name, OA 481 (2)).
                    bad = ("port" if stage_of(port) is None and cseq else
                           "net" if stage_of(w) is None and pseq and
                           not (parent.startswith("ccv_") and w in pports) else None)
                    if bad:
                        e = (parent, inst, port, w, None, None, None, "untagged " + bad)
                        if e in entries:
                            _conn["found"].add(e)
                        else:
                            add("CCV-L23", ln,
                                "%s's %s.%s is connected to %s, and the %s carries no stage "
                                "tag: a connection is held to the arithmetic, so both sides "
                                "say their stage (OA 481 (1))"
                                % (parent, inst, port, w, "child's port" if bad == "port" else "net"))
                st = [stage_of(w)[2] for w in ids if stage_of(w) and stage_of(w)[1] != "r"]
                if st:
                    pt[port] = (min(st), max(st), ids)
            for o, reach in port_paths(cbody, cports).items():
                so = stage_of(o) if cseq else (None, None, 0, None)
                if o not in pt or not so:
                    continue
                for i, comb in sorted(reach.items()):
                    si = stage_of(i) if cseq else (None, "c", 0, None)
                    if i not in pt or not si or si[1] == "r":
                        continue
                    deficit = (so[2] - si[2]) - (pt[o][0] - pt[i][1])
                    if deficit <= 0 or (deficit == 1 and not comb):
                        continue
                    # OA-488 (1): through a register-free helper, a deficit of 1
                    # is OI-65's same-stage feedback when the helper's output
                    # feeds only the next value or enable of the register its
                    # input reads, and nothing else.
                    if deficit == 1 and not cseq and \
                            helper_self_loop(pbody, pt[i][2], pt[o][2], inst):
                        continue
                    key = "%s.%s" % (inst, i)
                    if key in xdecl:
                        used.add(key)
                        continue
                    # A verified table (OI-217, OA-496): this child is a
                    # sibling's declared table writer, and its input reaches
                    # the output only through the table register.
                    if inst in table_regs and only_into(cbody, cports, i, table_regs[inst], read_outs):
                        continue
                    e = (parent, inst, i, None, pt[i][1], si[2], deficit,
                         "combinational" if comb else "register")
                    hit = [x for x in entries if x[:3] == e[:3] and x[3] is None]
                    if hit:
                        _conn["found"].update(hit)
                        if any(x[6] >= deficit and (x[7] == "combinational" or not comb)
                               for x in hit):
                            continue
                    add("CCV-L23", ln,
                        "%s's %s (%s): output %s (its stage %s, the parent's %02d) depends "
                        "on input %s (its stage %s, fed at %02d)%s, so the parent tags it %d "
                        "stage(s) earlier than %s's own latency allows: a back edge across "
                        "the boundary. Fix it, or declare the loop in %s.feedback.json as "
                        "\"%s\" (CCV-L23, a cross-module loop)"
                        % (parent, inst, child, o, "%02d" % so[2] if cseq else "none",
                           pt[o][0], i, "%02d" % si[2] if cseq else "none", pt[i][1],
                           " combinationally" if comb else "", deficit, child, parent, key))
        for key, d in sorted(xdecl.items()):
            why = verify_xloop(key, d, pbody, local, idx, signers, src, fbdir)
            if why:
                add("CCV-L23", 1, "%s: cross-module loop %s is refused: %s" % (fp, key, why))
            elif key not in used:
                add("CCV-L23", 1, "%s: cross-module loop %s names no back edge the "
                    "connections show (a stale declaration is refused)" % (fp, key))


def verify_port_table(n, port, d, body, graph, signers, path):
    """{"tables": {"<input port>": {"reader", "ahead", "writer": "<inst>.<reg>",
    "assert", "control", "by", ...}}} (OA-492 (3)): by an architect; the
    reader reads the port; ahead is the port's stage less the reader's own;
    in the parent, the port is fed directly by instance <inst>'s output that
    is its register <reg>; an assertion with that label in this module, that
    the read never meets a write; and a bench control that breaks it."""
    if d.get("by") not in signers:
        return "not an architect's (by %r, not one of %s)" % (d.get("by"), ", ".join(signers))
    reader = d.get("reader")
    if not reader or port not in graph[0].get(reader, ()):
        return "its reader %r does not read %s" % (reader, port)
    sr, sp = stage_of(reader), stage_of(port)
    if not sr or not sp:
        return "the reader and the port both carry a stage tag"
    at = sr[2] - 1 if reader in graph[1] else sr[2]
    if d.get("ahead") != sp[2] - at:
        return "ahead is %r, but %s lies %d stage(s) past its reader's (%02d)" % (
            d.get("ahead"), port, sp[2] - at, at)
    w = str(d.get("writer", ""))
    if "." not in w:
        return "\"writer\" names no <instance>.<register>"
    wi, wreg = w.split(".", 1)
    fbdir = os.path.dirname(path)
    # The parent: a module, in the tree or beside this file, instantiating n.
    cands = dict((k, v[1:]) for k, v in module_index().items())
    for fn in os.listdir(fbdir):
        if fn.endswith(".sv"):
            for k, v in module_headers(strip_comments(open(os.path.join(fbdir, fn)).read())).items():
                cands.setdefault(k, v)
    parents = []
    for pn, (pports, pbody) in cands.items():
        if pn != n and re.search(r"\b%s\b\s*(?:#\s*\(|[a-z]\w*\s*\()" % re.escape(n), pbody):
            parents.append((pn, pbody))
    if not parents:
        return "no module instantiates %s, so its writer cannot be traced" % n
    for pn, pbody in parents:
        insts = instances(pbody, {}, dict((k, (None,) + v) for k, v in cands.items()), fbdir)
        rd = [v for v in insts.values() if v[0] == n]
        if wi not in insts:
            return "%s has no instance %s" % (pn, wi)
        wchild, wports, wbody, wconns = insts[wi]
        # The register reaches the writer's output through its combinational
        # logic only, no register between (OA-496): read from a sibling's
        # table, the words arrive as that register holds them.
        wdeps, wflops = dep_graph(wbody)
        wout = []
        for o, dr in wports.items():
            if dr != "output":
                continue
            if o == wreg:
                wout.append(o)
                continue
            _, rr = cone(wdeps, wflops, wdeps.get(o, ()) if o not in wflops else ())
            if o not in wflops and wreg in rr:
                wout.append(o)
        if wreg not in wflops or not wout:
            return ("%s.%s is not a register reaching an output of %s through "
                    "combinational logic only" % (wi, wreg, wchild))
        wnets = set(x for o in wout for x in conn_ids(wconns.get(o, "")))
        for _, _, _, conns in rd:
            if set(conn_ids(conns.get(port, ""))) != wnets or not wnets:
                return ("in %s, %s is not fed directly by %s's register %s"
                        % (pn, port, wi, wreg))
    labs = d.get("assert") or []
    labs = [labs] if isinstance(labs, str) else list(labs)
    if not labs or any(not re.search(r"`CCV_ASSERT(?:_AT)?\s*\(\s*%s\b" % re.escape(str(l)), body)
                       for l in labs):
        return ("no assertion %s in %s that the read never meets a write"
                % (", ".join(map(repr, labs)) or "named", n))
    ctls = d.get("control") or []
    ctls = [ctls] if isinstance(ctls, str) else list(ctls)
    blk = os.path.relpath(fbdir, ROOT).replace(os.sep, "/").split("/")
    homes = ([os.path.join(ROOT, "test", blk[1]), os.path.join(ROOT, "sim", blk[1])]
             if len(blk) > 1 and blk[0] == "rtl" and blk[1] != "lint" else [fbdir])
    if not ctls or any(not any(control_named(h, str(c)) for h in homes) for c in ctls):
        return "its control is missing or named nowhere in %s" % " or ".join(
            os.path.relpath(h, ROOT) for h in homes)
    return None


def sibling_tables(pbody, local, idx, fbdir):
    """{instance: {register}}: the table registers this parent's children
    declare a sibling writes, "writer": "<inst>.<reg>" in a child's
    feedback.json "tables" (OA-492, OA-496). The declaration itself is
    verified where its reader is linted."""
    out = {}
    for iname, (child, ports, body, conns) in instances(pbody, local, idx, fbdir).items():
        src = idx.get(child)
        cdir = os.path.join(ROOT, os.path.dirname(src[0])) if src and src[0] else fbdir
        _, _, _, tbl = feedback_decls(cdir, child)
        for port, d in tbl.items():
            w = str(d.get("writer", "")) if isinstance(d, dict) else ""
            if "." in w and ports.get(port) == "input":
                # The table must verify in this same run (OA-497).
                cpath = os.path.join(cdir, child + ".sv")
                cg = dep_graph(body)
                if verify_port_table(child, port, d, body, cg,
                                     feedback_signers(cdir), cpath):
                    continue
                wi, wreg = w.split(".", 1)
                out.setdefault(wi, set()).add(wreg)
    return out


def only_into(body, ports, i, regs, read=None):
    """OA-497/500: input i's forward cone inside the module ends solely at the
    declared table registers' next value or enable, directly or through
    write-pipeline registers whose whole fanout ends at the table registers
    (or at another such register). It reaches at least one table register,
    and no other register and no output the parent reads (an output left
    unconnected reaches nothing, OI-219)."""
    deps, flops = dep_graph(body)
    users = {}
    for n, ds in deps.items():
        for x in ds:
            users.setdefault(x, set()).add(n)

    def reach(start):
        # (registers, outputs read) one combinational step beyond start.
        seen, todo, rr, outs = set(), [start], set(), False
        while todo:
            n = todo.pop()
            for u in users.get(n, ()):
                if u in seen:
                    continue
                seen.add(u)
                if u in flops:
                    rr.add(u)
                    # A declared table register drives the output its reader
                    # takes: that is the table, not a path around it.
                    if ports.get(u) == "output" and u not in regs and \
                            (read is None or u in read):
                        outs = True
                elif ports.get(u) == "output":
                    if read is None or u in read:
                        outs = True
                else:
                    todo.append(u)
        return rr, outs

    # The write pipeline: registers whose whole fanout ends at the table
    # registers or at other pipeline registers (a fixed point; a register
    # feeding itself as well counts, a hold).
    good = set(regs)
    fan = {r: reach(r) for r in flops}
    grew = True
    while grew:
        grew = False
        for r in flops:
            if r in good:
                continue
            rr, outs = fan[r]
            # A register that feeds no other register and no output the
            # parent reads (no fanout at all, or an output the parent leaves
            # unconnected, OI-219) reaches nothing outward: a dead end.
            dead = not (rr - {r}) and (ports.get(r) != "output" or
                                       (read is not None and r not in read))
            if not outs and (dead or (rr - {r} and (rr - {r}) <= good)):
                good.add(r)
                grew = True
    rr, outs = reach(i)
    return (not outs) and bool(rr) and rr <= good

def helper_self_loop(pbody, inets, onets, inst):
    """Whether the helper's input reads one parent register R and its
    output's nets feed, through the parent's combinational nets, R's next
    value or enable and nothing else: no other register, no output port, no
    other instance."""
    deps, flops = dep_graph(pbody)
    if len(inets) != 1 or inets[0] not in flops:
        return False
    reg = inets[0]
    users = {}
    for n, ds in deps.items():
        for x in ds:
            users.setdefault(x, set()).add(n)
    seen, todo = set(), list(onets)
    sinks = set()
    while todo:
        n = todo.pop()
        if n in seen:
            continue
        seen.add(n)
        for u in users.get(n, ()):
            if u in flops:
                sinks.add(u)
            else:
                todo.append(u)
    if sinks != {reg}:
        return False
    # Read anywhere else (another instance's port, an output port's
    # assignment outside an always): not a self-loop.
    for n in seen:
        for m in re.finditer(r"\.([a-z]\w*)\s*\(([^()]*\b%s\b[^()]*)\)" % re.escape(n), pbody):
            if not re.search(r"\b%s\s*(?:#\s*\([^;]*?\))?\s*\(" % re.escape(inst),
                             pbody[max(0, m.start() - 4000):m.start()]):
                return False
    return True


def instances(pbody, local, idx, fbdir=None):
    """{instance: (child, ports, body, {port: expr})} of a parent body."""
    out = {}
    for m in re.finditer(r"\b([a-z]\w*)\s*(#\s*\()?", pbody):
        child = m.group(1)
        src = local.get(child) or (idx[child][1:] if child in idx else None)
        if not src and fbdir and os.path.exists(os.path.join(fbdir, child + ".sv")):
            src = module_headers(strip_comments(open(os.path.join(fbdir, child + ".sv")).read())).get(child)
        if not src:
            continue
        j = m.end()
        if m.group(2):
            _, j = balanced(pbody, j - 1)
        k = re.match(r"\s*([a-z]\w*)\s*(?:\[[^\]]*\]\s*)?\(\s*\.", pbody[j:])
        if not k:
            continue
        txt, _ = balanced(pbody, pbody.index("(", j + k.end(1)))
        conns = {}
        for c in re.finditer(r"\.([a-z]\w*)\s*(\()?", txt):
            conns[c.group(1)] = balanced(txt, c.end() - 1)[0] if c.group(2) else c.group(1)
        out[k.group(1)] = (child, src[0], src[1], conns)
    return out


def verify_xloop(key, d, pbody, local, idx, signers, src, fbdir=None):
    """A cross-module loop (OA 481 (3)): {"<inst>.<input>": {"from":
    "<inst>.<output>", "ahead": N, "loop": [<inst>, ...], "assert": <label>,
    "control": <name>, "by", "date", "why"}}. by an architect; ahead the
    stages the net feeding the input lies past the input's own tag; from the
    output driving that net; the loop closes through the listed instances,
    the reader's input reaching the writer's output; and an assertion with
    that label in the parent or the reader's module, for the hazard the stale
    read opens, with its bench control named."""
    if d.get("by") not in signers:
        return "not an architect's (by %r, not one of %s)" % (d.get("by"), ", ".join(signers))
    insts = instances(pbody, local, idx, fbdir)
    ri, rp = key.split(".", 1)
    fr = d.get("from", "")
    if isinstance(fr, dict) or "." not in str(fr):
        why = verify_regloop(ri, rp, fr, d, pbody, insts)
        if why:
            return why
        return verify_stale(d, pbody, insts, ri, fbdir)
    fr = str(fr)
    wi, wp = fr.split(".", 1)
    if ri not in insts or wi not in insts:
        return "%s or %s is no instance of this module" % (ri, wi)
    if rp not in insts[ri][1] or insts[ri][1][rp] != "input":
        return "%s is no input of %s" % (rp, ri)
    if wp not in insts[wi][1] or insts[wi][1][wp] != "output":
        return "%s is no output of %s" % (wp, wi)
    rnet = conn_ids(insts[ri][3].get(rp, ""))
    wnet = conn_ids(insts[wi][3].get(wp, ""))
    if not rnet or not wnet or set(rnet) != set(wnet):
        return "%s.%s is not fed by %s.%s's net" % (ri, rp, wi, wp)
    sn, sp = stage_of(rnet[0]), stage_of(rp)
    if not sn or not sp or d.get("ahead") != sn[2] - sp[2]:
        return "ahead is %r, but the net lies %s stage(s) past the input's tag" % (
            d.get("ahead"), (sn[2] - sp[2]) if sn and sp else "?")
    loop = d.get("loop") or []
    if not loop or loop[0] != ri or loop[-1] != wi:
        return "\"loop\" must list its instances from the reader (%s) to the writer (%s)" % (ri, wi)
    deps, _ = dep_graph(pbody)
    def feeds(a, b):
        # Some output of instance a reaches some input of instance b, through
        # the parent's own nets.
        outs = set()
        for o, (dr) in insts[a][1].items():
            if dr == "output":
                outs |= set(conn_ids(insts[a][3].get(o, "")))
        for i, dr in insts[b][1].items():
            if dr != "input":
                continue
            todo, seen = list(conn_ids(insts[b][3].get(i, ""))), set()
            while todo:
                n = todo.pop()
                if n in outs:
                    return True
                if n in seen:
                    continue
                seen.add(n)
                todo.extend(deps.get(n, ()))
        return False
    for a, b in zip(loop, loop[1:]):
        if a not in insts or b not in insts or not feeds(a, b):
            return "the loop does not close: no output of %s reaches an input of %s" % (a, b)
    if not port_paths(insts[ri][2], insts[ri][1]) or \
            not any(rp in r for r in port_paths(insts[ri][2], insts[ri][1]).values()):
        return "%s's input %s reaches none of its outputs" % (ri, rp)
    return verify_stale(d, pbody, insts, ri, fbdir)


def verify_regloop(ri, rp, fr, d, pbody, insts):
    """A loop closed by the parent's own registers (OI-207, OA-489): "from"
    is the parent register the child input reads; "loop" lists the reader's
    output(s) that close it, then the parent registers in order, the last
    being "from". Each hop is traced: the first register's next value or
    enable depends, through the parent's combinational nets only, on a
    listed output's net, and each later one on the register before it."""
    if ri not in insts:
        return "%s is no instance of this module" % ri
    if rp not in insts[ri][1] or insts[ri][1][rp] != "input":
        return "%s is no input of %s" % (rp, ri)
    deps, flops = dep_graph(pbody)
    # A register-free child is its parent's logic (OA 485): its in-to-out
    # paths join the parent's combinational graph, so a hop through it
    # (OI-213, u_ren1) is traced as the parent's own logic would be.
    deps = {k: set(v) for k, v in deps.items()}
    for hi, (hchild, hports, hbody, hconns) in insts.items():
        if dep_graph(hbody)[1]:
            continue
        for o, reach in port_paths(hbody, hports).items():
            for on in conn_ids(hconns.get(o, "")):
                for i in reach:
                    deps.setdefault(on, set()).update(conn_ids(hconns.get(i, "")))
    loop = [str(x) for x in (d.get("loop") or [])]
    # Named crossings join the graph too, for the cone's reach (OA-495).
    for h in loop:
        if h.count(">") == 1 and "." in h:
            ci, rest = h.split(".", 1)
            cin, cout = rest.split(">", 1)
            if ci in insts:
                for on in conn_ids(insts[ci][3].get(cout, "")):
                    deps.setdefault(on, set()).update(conn_ids(insts[ci][3].get(cin, "")))
    sp = stage_of(rp)
    if isinstance(fr, dict):
        # A combinational cone over listed parent registers (OA-495 (a)):
        # exactly the listed registers reach the input through the parent's
        # combinational nets and crossings, each ahead matching its tags.
        listed = [str(x) for x in (fr.get("cone") or [])]
        aheads = fr.get("ahead") or {}
        if not listed:
            return "a cone \"from\" lists no register"
        nets, rr = cone(deps, flops, conn_ids(insts[ri][3].get(rp, "")))
        # A cone may also list a sibling's output, "<inst>.<output>" (OI-218):
        # its net is a source as a register is, held to the same terms.
        outnet = {}
        for oi, (och, opt, obody, oconns) in insts.items():
            if not dep_graph(obody)[1]:
                continue
            for o, dr in opt.items():
                if dr == "output":
                    for nn in conn_ids(oconns.get(o, "")):
                        outnet[nn] = "%s.%s" % (oi, o)
        # A cone source may be a named crossing "<inst>.<in>><out>" of a
        # sibling (OA-498): its output's net is a source, and its input must
        # trace back, through the parent's combinational nets, only to
        # listed registers.
        cone_regs, xsrc = [], {}
        for g in listed:
            if ">" in g:
                ci, rest = g.split(".", 1)
                cin, cout = rest.split(">", 1)
                if ci not in insts or insts[ci][1].get(cin) != "input" or \
                        insts[ci][1].get(cout) != "output":
                    return "cone crossing %s names no input and output of an instance here" % g
                if not port_paths(insts[ci][2], insts[ci][1]).get(cout, {}).get(cin):
                    return ("cone crossing %s: %s has no combinational path from %s to %s"
                            % (g, insts[ci][0], cin, cout))
                xsrc["%s.%s" % (ci, cout)] = g
            elif "." in g:
                # A sibling's output named directly (TI-575, OA-499): only
                # where that sibling's tags are verified in this same run,
                # it has a timing unit and is not on the stage ratchet.
                oi, op = g.split(".", 1)
                if oi not in insts or insts[oi][1].get(op) != "output":
                    return "cone output %s is no output of an instance here" % g
                if insts[oi][0] not in unit_modules() or insts[oi][0] in stage_ratchet():
                    return ("cone output %s: %s's tags are not verified (no timing unit, or on "
                            "rtl/stage-ratchet.json): name it as a crossing traced to listed "
                            "registers instead (OA-498, OA-499)" % (g, insts[oi][0]))
                cone_regs.append(g)
            elif g not in flops:
                return "cone register %s is no register of this module" % g
            else:
                cone_regs.append(g)
        reached_out = set(outnet[nn] for nn in nets if nn in outnet)
        rr = set(rr) | (reached_out & set(cone_regs))
        for o in sorted(reached_out - set(cone_regs)):
            if o not in xsrc:
                return ("%s reaches %s.%s through the cone but no listed crossing names "
                        "it: a cone lists every source it reads" % (o, ri, rp))
        def xsources(g):
            # What a crossing's input traces back to: parent registers, and
            # verified sibling outputs (OA-501: the leads' u_go.lane_v,
            # crossed through the register-free u_ren1).
            ci, rest = g.split(".", 1)
            xn, xr = cone(deps, flops, conn_ids(insts[ci][3].get(rest.split(">", 1)[0], "")))
            return set(xr) | set(outnet[nn] for nn in xn if nn in outnet)
        for o, g in sorted(xsrc.items()):
            ci, rest = g.split(".", 1)
            cin, cout = rest.split(">", 1)
            # A register-free child's crossing is the parent's logic: its
            # output's net is reached when the cone's nets hold it.
            if o not in reached_out and not set(conn_ids(insts[ci][3].get(cout, ""))) & set(nets):
                return "cone crossing %s does not reach %s.%s" % (g, ri, rp)
            xs = xsources(g)
            if not xs or not xs <= set(cone_regs):
                return ("cone crossing %s: its input %s traces to %s, not only to listed "
                        "registers" % (g, cin, ", ".join(sorted(xs)) or "none"))
        missing = sorted(set(rr) - set(cone_regs))
        extra = sorted(set(cone_regs) - set(rr) - set().union(
            *[xsources(g) for g in xsrc.values()] or [set()]))
        if missing:
            return ("register(s) %s reach %s.%s through the cone but are not listed: a "
                    "cone lists every register it reads" % (", ".join(missing), ri, rp))
        if extra:
            return ("cone register(s) %s do not reach %s.%s through combinational logic"
                    % (", ".join(extra), ri, rp))
        for g in cone_regs:
            gn = g
            if "." in g:
                oi, op = g.split(".", 1)
                gn = (conn_ids(insts[oi][3].get(op, "")) or [op])[0]
            sg = stage_of(gn)
            if not sg or not sp or aheads.get(g) != sg[2] - sp[2]:
                return "ahead for %s is %r, but it lies %s stage(s) past the input's tag" % (
                    g, aheads.get(g), (sg[2] - sp[2]) if sg and sp else "?")
        ends = set(cone_regs) | set(xsrc)
    else:
        if fr not in flops:
            return ("\"from\" %s is neither <instance>.<output> nor a register of this "
                    "module" % fr)
        if conn_ids(insts[ri][3].get(rp, "")) != [fr]:
            return "%s.%s does not read register %s directly" % (ri, rp, fr)
        sn = stage_of(fr)
        if not sn or not sp or d.get("ahead") != sn[2] - sp[2]:
            return "ahead is %r, but %s lies %s stage(s) past the input's tag" % (
                d.get("ahead"), fr, (sn[2] - sp[2]) if sn and sp else "?")
        ends = {fr}
    # The reader's output(s) first, then hops in order: a parent register, or
    # a crossing "<inst>.<input>><output>" of a child with a combinational
    # path from that input to that output (OA-494); the last is "from".
    n_out = 0
    while n_out < len(loop) and "." in loop[n_out] and ">" not in loop[n_out]:
        n_out += 1
    outs, hops = loop[:n_out], loop[n_out:]
    last = hops[-1] if hops else ""
    last_ok = last in ends or (">" in last and "%s.%s" % (
        last.split(".", 1)[0], last.rsplit(">", 1)[-1]) in ends)
    if not outs or not hops or not last_ok or any(
            "." in h and ">" not in h for h in hops):
        return ("\"loop\" lists the reader's output(s), then the hops in order (parent "
                "registers, \"<inst>.<input>><output>\" crossings or \"<inst>.<input>>"
                "<register>><output>\" registered hops), ending at %s"
                % " or ".join(sorted(ends)))
    paths = port_paths(insts[ri][2], insts[ri][1])
    src = set()
    for x in outs:
        oi, op = x.split(".", 1)
        if oi != ri:
            return "loop output %s is not the reader's (%s)" % (x, ri)
        if insts[ri][1].get(op) != "output":
            return "%s is no output of %s" % (op, ri)
        if rp not in paths.get(op, {}):
            return "%s's input %s does not reach its output %s" % (ri, rp, op)
        src |= set(conn_ids(insts[ri][3].get(op, "")))
    prev = " / ".join(outs)
    for h in hops:
        if h.count(">") == 2:
            # A registered hop (OA-495 (c)): the child's input reaches the
            # named register's next value or enable, and the register its
            # output, each combinationally.
            ci, rest = h.split(".", 1)
            cin, creg, cout = rest.split(">")
            if ci not in insts:
                return "hop %s names no instance of this module" % h
            cports = insts[ci][1]
            cdeps, cflops = dep_graph(insts[ci][2])
            if cports.get(cin) != "input" or cports.get(cout) != "output" or creg not in cflops:
                return ("hop %s: %s is no input, %s no register or %s no output of %s"
                        % (h, cin, creg, cout, ci))
            dn, dr = cone(cdeps, cflops, cdeps.get(creg, ()))
            if cin not in dn:
                return ("hop %s: %s's input %s does not reach %s's next value or enable "
                        "combinationally" % (h, insts[ci][0], cin, creg))
            on, orr = cone(cdeps, cflops, cdeps.get(cout, ()) | ({cout} if cout in cflops else set()))
            if creg not in orr and cout != creg:
                return ("hop %s: %s's register %s does not reach its output %s "
                        "combinationally" % (h, insts[ci][0], creg, cout))
            nets, rr = cone(deps, flops, conn_ids(insts[ci][3].get(cin, "")))
            if not (src & (nets | rr)):
                return ("the loop's hop %s -> %s is not traced: %s's input %s does not read "
                        "it through combinational logic" % (prev, h, ci, cin))
            src = set(conn_ids(insts[ci][3].get(cout, "")))
        elif ">" in h:
            ci, rest = h.split(".", 1)
            cin, cout = rest.split(">", 1)
            if ci not in insts:
                return "crossing %s names no instance of this module" % h
            cports = insts[ci][1]
            if cports.get(cin) != "input" or cports.get(cout) != "output":
                return "crossing %s: %s is no input or %s no output of %s" % (h, cin, cout, ci)
            if not port_paths(insts[ci][2], cports).get(cout, {}).get(cin):
                return ("crossing %s: %s has no combinational path from %s to %s; a "
                        "registered crossing is refused" % (h, insts[ci][0], cin, cout))
            nets, rr = cone(deps, flops, conn_ids(insts[ci][3].get(cin, "")))
            if not (src & (nets | rr)):
                return ("the loop's hop %s -> %s is not traced: %s's input %s does not read "
                        "it through combinational logic" % (prev, h, ci, cin))
            src = set(conn_ids(insts[ci][3].get(cout, "")))
        else:
            if h not in flops:
                return "loop register %s is no register of this module" % h
            nets, rr = cone(deps, flops, deps.get(h, ()))
            if not (src & (nets | rr)):
                return ("the loop's hop %s -> %s is not traced: %s's next value and enable "
                        "do not read it through combinational logic" % (prev, h, h))
            src = {h}
        prev = h
    return None


def verify_stale(d, pbody, insts, ri, fbdir):
    """A declared loop's stale-read assertion(s) and bench control(s)."""
    # One label or several, and one control or several (MI-40 (4)).
    labs = d.get("assert") or []
    labs = [labs] if isinstance(labs, str) else list(labs)
    rbody = insts[ri][2]
    if not labs:
        return "it names no assertion: a declared loop proves its stale read safe (OA 481 (3))"
    for lab in labs:
        if not re.search(r"`CCV_ASSERT(?:_AT)?\s*\(\s*%s\b" % re.escape(str(lab)), pbody + rbody):
            return ("no assertion %r in the parent or %s: a declared loop proves its stale "
                    "read safe (OA 481 (3))" % (lab, insts[ri][0]))
    ctls = d.get("control") or []
    ctls = [ctls] if isinstance(ctls, str) else list(ctls)
    if not ctls:
        return "it names no bench control that breaks %s" % ", ".join(map(str, labs))
    # A control is the block bench's: its name appears in test/<block>/ or
    # sim/<block>/ (a fixture's, beside it in rtl/lint/).
    blk = os.path.relpath(fbdir or ROOT, ROOT).replace(os.sep, "/").split("/")
    homes = ([os.path.join(ROOT, "test", blk[1]), os.path.join(ROOT, "sim", blk[1])]
             if len(blk) > 1 and blk[0] == "rtl" and blk[1] != "lint" else [fbdir or ROOT])
    for c in ctls:
        if not any(control_named(h, str(c)) for h in homes):
            return ("its control %r is named nowhere in %s: name the bench control that "
                    "breaks the assertion, as the bench registers it"
                    % (c, " or ".join(os.path.relpath(h, ROOT) for h in homes)))
    return None


def control_named(home, name):
    """Whether a file under home, a feedback declaration aside, names the
    bench control as a word."""
    pat = re.compile(r"(?<![\w-])%s(?![\w-])" % re.escape(name))
    for d, _, fns in os.walk(home):
        for fn in fns:
            if fn.endswith(".feedback.json"):
                continue
            try:
                if pat.search(open(os.path.join(d, fn), errors="ignore").read()):
                    return True
            except OSError:
                pass
    return False


def check_orphan_feedback(roots=("rtl",)):
    """A <module>.feedback.json the lint never reads is a silent pass
    (MI-44): its module must be defined in a .sv file beside it."""
    F = []
    for r in roots:
        for d, _, fns in os.walk(os.path.join(ROOT, r)):
            defined = None
            for fn in sorted(fns):
                if not fn.endswith(".feedback.json"):
                    continue
                if defined is None:
                    defined = set()
                    for g in fns:
                        if g.endswith((".sv", ".v")):
                            defined |= set(n for _, _, n, _ in module_spans(
                                strip_comments(open(os.path.join(d, g)).read())))
                mod = fn[:-len(".feedback.json")]
                if mod not in defined:
                    F.append(Finding("CCV-L23", os.path.relpath(os.path.join(d, fn), ROOT), 1,
                                     "%s is declared for module %s, which no .sv beside it "
                                     "defines: the lint never reads it, so it is refused "
                                     "until the module lands with it (MI-44)" % (fn, mod)))
    return F


def check_conn_ratchet():
    """rtl/conn-ratchet.json only shrinks: an entry not in the baseline is
    refused, and so is one this run no longer finds, in a module it read."""
    F = []
    rel = os.path.relpath(_conn["path"], ROOT)
    p = _conn["baseline"]
    base = {conn_key(e) for e in (json.load(open(p)).get("entries", []) if os.path.exists(p) else [])}
    for e in conn_ratchet():
        k = conn_key(e)
        if k not in base:
            F.append(Finding("CCV-L23", rel, 1, "%s.%s %s was not on the list when the "
                             "connection check was made; the list only shrinks" % k[:3]))
        elif k[0] in _conn["seen"] and k not in _conn["found"]:
            F.append(Finding("CCV-L23", rel, 1, "%s.%s %s now meets the rule, or is gone: "
                             "remove it from %s" % (k[0], k[1], k[2], rel)))
    return F


def check_interface_coverage(schema=None):
    """CCV-L12 -- every interface typedef has a checker, and every CONTROL
    field is referenced by it.

    Convention §3: "Every interface typedef has exactly one associated checker
    module. No typedef may exist without one; lint enforces this." And §4: "a
    field added to the struct and not to the checker is a lint failure."

    This is a cross-file rule, so it runs once over the schema rather than per
    file. Control fields specifically, because §6 of the strategy doc prohibits
    X on control and propagates it on data -- a data field needs no obligation,
    a control field does.
    """
    F = []
    src = schema or os.path.join(ROOT, "schema", "interfaces.json")
    if not os.path.exists(src):
        return F
    with open(src) as f:
        d = json.load(f)
    for i in d.get("interfaces", []):
        base = i["name"][:-2] if i["name"].endswith("_t") else i["name"]
        path = os.path.join(ROOT, "rtl", "if", "ccv_common_chk_%s.sv" % base)
        rel = os.path.relpath(path, ROOT)
        if not os.path.exists(path):
            F.append(Finding("CCV-L12", "schema/interfaces.json", 1,
                             "interface %s has no checker at %s; no typedef "
                             "may exist without one" % (i["name"], rel)))
            continue
        body = open(path).read()
        for fld in i["fields"]:
            if not fld["control"]:
                continue
            if not re.search(r"\b%s\b" % re.escape(fld["name"]), body):
                F.append(Finding("CCV-L12", rel, 1,
                                 "control field %r of %s is not referenced by "
                                 "its checker; a field added to the struct and "
                                 "not to the checker is a lint failure (§4)"
                                 % (fld["name"], i["name"])))
    return F


def check_stage_ratchet():
    """CCV-L29's ratchet only shrinks: an entry that was not in the baseline
    when the rule was made is refused, and so is one whose net is now
    tagged or gone, in a module this run read."""
    F = []
    rel = os.path.relpath(_stage_ratchet["path"], ROOT)
    p = _stage_ratchet["baseline"]
    base = json.load(open(p)).get("modules", {}) if os.path.exists(p) else {}
    for mod, nets in sorted(stage_ratchet().items()):
        for net in nets:
            if net not in base.get(mod, []):
                F.append(Finding("CCV-L29", rel, 1,
                                 "%s %s was not on the list when the rule was made; "
                                 "the list only shrinks" % (mod, net)))
            elif mod in _stage_ratchet["seen"] and (mod, net) not in _stage_ratchet["found"]:
                F.append(Finding("CCV-L29", rel, 1,
                                 "%s %s now meets the rule, or is gone: remove it from "
                                 "%s" % (mod, net, rel)))
    return F


def check_module_names(roots=("rtl/top", "rtl/generated")):
    """CCV-L28 over the generated design, which the per-file walk skips: the
    top, its wrappers, stubs and shims, and the checker bank are modules in
    the tree like any other, and take its shapes (OI-37)."""
    F = []
    _, blocks = load_blocks()
    names = {b["name"] for b in blocks.values()}
    for r in roots:
        for dirpath, _, filenames in os.walk(os.path.join(ROOT, r)):
            for fn in sorted(filenames):
                if not fn.endswith((".sv", ".v")):
                    continue
                full = os.path.join(dirpath, fn)
                rel = os.path.relpath(full, ROOT)
                src = strip_comments(open(full).read())
                for _, _, n, ln in module_spans(src):
                    c = classify(n, names)
                    if c.kind is None:
                        F.append(Finding("CCV-L28", rel, ln,
                                         "module %s: %s (OI-37)" % (n, c.why)))
    return F


def check_blocks(path=None):
    """CCV-L28's other half: the block list the shapes are read against.
    A block name is one lowercase token, since every shape splits at the
    first underscore: a block named ooe_w would make OOE's wrapper read as
    a block top, and one named a_b would make a's sub-block b read as a
    block. "common" and "top" would make ccv_common_* and ccv_top read as
    block tops. And a block's module, where blocks.json states one, is
    ccv_<name>: the field is what a reader of the list sees."""
    F = []
    src = path or os.path.join(ROOT, "params", "blocks.json")
    rel = os.path.relpath(src, ROOT)
    with open(src) as f:
        d = json.load(f)
    for b in d.get("blocks", []):
        n = b["name"]
        if not re.fullmatch(r"[a-z][a-z0-9]*", n):
            F.append(Finding("CCV-L28", rel, 1,
                             "block %s is not one lowercase token: every "
                             "module-name shape splits at the first "
                             "underscore, so a block named with one would "
                             "make another block's names ambiguous" % n))
        elif n in ("common", "top"):
            F.append(Finding("CCV-L28", rel, 1,
                             "block %s is a reserved name: ccv_%s would read "
                             "as its block top" % (n, n)))
        if "module" in b and b["module"] != "ccv_" + n:
            F.append(Finding("CCV-L28", rel, 1,
                             "block %s's module is %s; a block top is named "
                             "ccv_%s" % (n, b["module"], n)))
    return F


def iter_sv(paths):
    for p in paths:
        ap = os.path.join(ROOT, p)
        if os.path.isfile(ap):
            yield ap, p
            continue
        for dirpath, dirnames, filenames in os.walk(ap):
            # `generated/` is produced by the generators and holds no design
            # RTL. `lint/` is the deliberately non-compliant fixture, which is
            # SUPPOSED to fail -- tools/check-1d.sh lints it by name and fails
            # if it ever stops failing. Walking it here would make every
            # ordinary run red.
            #
            # rtl/top/ and test/top/ are generated too (tools/gen-top.py) and
            # merely TRACKED, so the top level can be read in the repo. Its
            # staleness check is what protects them, not lint: channel port
            # names cannot carry stage tags until 4a numbers the stages.
            rel = os.path.relpath(dirpath, ROOT)
            if rel in ("rtl/top", "test/top") or rel.startswith(("rtl/top/", "test/top/")):
                dirnames[:] = []
                continue
            dirnames[:] = [d for d in dirnames
                           if d not in ("generated", "__pycache__", "lint")]
            for fn in sorted(filenames):
                if fn.endswith((".sv", ".svh", ".v", ".vh")):
                    full = os.path.join(dirpath, fn)
                    yield full, os.path.relpath(full, ROOT)


def main():
    args = [a for a in sys.argv[1:] if not a.startswith("-")]
    quiet = "-q" in sys.argv
    # Lets tools/check-1d.sh point CCV-L12 at a fixture schema, CCV-L28's
    # block-list half at a fixture list, and its generated-tree half at a
    # fixture directory, since a cross-file rule cannot be counter-exampled
    # by a .sv file alone.
    schema = blocks = names = None
    ratchet_given = False
    for a in sys.argv[1:]:
        if a.startswith("--names="):
            names = a.split("=", 1)[1]
        if a.startswith("--schema="):
            schema = a.split("=", 1)[1]
        if a.startswith("--blocks="):
            blocks = a.split("=", 1)[1]
        if a.startswith("--signer-path="):
            _signer_path["rel"] = a.split("=", 1)[1]
        # CCV-L29's ratchet and baseline, pointed at fixtures by check-1d.
        if a.startswith("--stage-ratchet="):
            _stage_ratchet["path"] = os.path.join(ROOT, a.split("=", 1)[1])
            ratchet_given = True
        if a.startswith("--conn-ratchet="):
            _conn["path"] = os.path.join(ROOT, a.split("=", 1)[1])
            ratchet_given = True
        if a.startswith("--conn-baseline="):
            _conn["baseline"] = os.path.join(ROOT, a.split("=", 1)[1])
        if a.startswith("--stage-baseline="):
            _stage_ratchet["baseline"] = os.path.join(ROOT, a.split("=", 1)[1])
    targets = args or ["rtl", "test", "spike"]
    findings = []
    n = 0
    for full, rel in iter_sv(targets):
        n += 1
        findings.extend(check_file(full, rel))
    # Cross-file rule: runs once, and only on a full-tree run, since a
    # single-file invocation has no opinion about the schema.
    if not args or schema:
        findings.extend(check_interface_coverage(schema))
    if not args or blocks:
        findings.extend(check_blocks(blocks))
    if not args:
        findings.extend(check_module_names())
    if not args or ratchet_given:
        findings.extend(check_stage_ratchet())
        findings.extend(check_conn_ratchet())
    if not args:
        findings.extend(check_orphan_feedback())
    for a in sys.argv[1:]:
        if a.startswith("--orphan-root="):
            findings.extend(check_orphan_feedback((a.split("=", 1)[1],)))
    if names:
        findings.extend(check_module_names((names,)))
    for f in sorted(findings, key=lambda f: (f.path, f.line)):
        print(f)
    if not quiet:
        print("  lint: %d file(s), %d finding(s)" % (n, len(findings)))
    return 1 if findings else 0


if __name__ == "__main__":
    sys.exit(main())
