#!/usr/bin/env python3
"""Local clock gating: form, enable depth and DCGE (Daniel, 2026-10-16).

    tools/check-cg.py              every unit, the waivers, the ratchet
    tools/check-cg.py --selftest   the negative controls (test/cg/fixtures/)
    tools/check-cg.py --unit NAME  one unit, every group listed

The rules are docs/rtl-coding-style.md, "Local clock gating":

  CG-1  form: every non-reset statement of an always_ff is `if (<enable>)`
        with no `else`, the enable a net named <name>_en[_<stage>][_n|_b]. A
        register written outside one is accepted by measurement when,
        clocked every cycle, it changes in at least CCV_DCGE_MIN_PCT of
        non-reset cycles in every scenario: a gate would save it little.
  CG-2  enable depth: every clock gate's enable cone is at most
        CCV_NGD_CG_EN NGD, and so is every explicit ICG's.
  CG-3  DCGE: every clock gate changes value in at least CCV_DCGE_MIN_PCT
        of the cycles its clock is enabled, in each of the idle, medium and
        high scenarios. A scenario that never enables the gate passes.
  CG-4  coverage: every flop is in a clock gate, or changes in at least
        CCV_DCGE_MIN_PCT of counted cycles in every scenario.
  CG-5  enable sources (2026-10-18): every clock gate's and ICG's enable
        cone starts only at the module's own flops, never an input.
  RST-1 the reset (2026-10-18): the reset port reaches nothing but the D
        pins of plain flops that capture it; every use is from those.

A clock gate is a group of at least CCV_CG_MIN_FLOPS flops that Yosys infers
one enable for; the unit's own reset does not split a group. A smaller group
gets no ICG, and its flops count as ungated (CG-4). CG-2 to CG-4 measure the
netlist, not the source, so they hold whichever way the RTL is written; CG-1
is what makes the enable deliberate.

A unit is one module at one parameterization, with a bench that runs the
three scenarios and dumps a VCD (test/**/cg-units.json), and every repeater
the design instantiates is one (rtl/top/rpt-units.json, from gen-top). The bench's port
trace is replayed into the unit's netlist, which must reproduce the bench's
outputs on every cycle, so what is measured is what the bench ran.

Exceptions, in order: the budgets, then the waivers, then the ratchet.
CG-5 and RST-1 are structural: no budget takes them. Each module may leave the larger of CCV_CG_BUDGET_PCT of its
flops and fewer than CCV_CG_MODULE_FLOPS flops outside the rules, smallest
findings first, findings about flops only; what the modules take counts,
per instance, against CCV_CG_BUDGET_PCT of each block with RTL. A
repeater's control pulses (valid, wake, credit and stall at every stage, and
its flopped reset) are the channel's own, captured every cycle like any
receiver's: they go straight to the block's budget, its hardening wrapper
being the partition, and not to the repeater's own allowance, which its
lead slice still meets (Daniel, 2026-10-19). Then rtl/cg-waivers.json:
one entry per (module, rule, register), a rule of WAIVER_RULES (CG-1 to CG-5
and RST-1), each with a reason; a waiver that excuses nothing, including one
for what a budget already takes, is refused. A CG-5 waiver also names the
input ports it lets into the enable and states the enable's total depth,
enable_ngd: the latest port's arrival (its <module>.ngd.json, else
CCV_NGD_BUDGET - CCV_NGD_PORT) plus the mapped cone. It is refused when an
unnamed input reaches the enable, when the total is over CCV_NGD_CG_EN, or
when it states less than measured (OI-58, OI-59): CG-2 times the cone alone,
which is exact only where no input reaches it. A waiver carries its
threshold and fails again past it (Daniel; OA's response OI-66): a CG-3
waiver states floor_pct and measured_pct by scenario, the floor no higher
than the measurement, and clears a gate only while its DCGE holds at the
floor, and may name one gate of its register by its enable (enable); an allowance waiver, for CG-1's registers written every cycle or
CG-4's ungated flops, states max_flops and measured_flops, and one flop more
fails. A waiver without its threshold is refused. Last, the ratchet,
rtl/cg-ratchet.json, holds the modules written before the rule, and the
CG-5 and RST-1 findings that stood when those were made; it only shrinks: an
entry outside its baseline is refused, and so is one with nothing left to
excuse. A waiver takes effect with no ratchet edit: a ratchet entry whose
findings a waiver now takes is reported as superseded, not failed.
"""
import argparse
import collections
import concurrent.futures
import fcntl
import glob
import hashlib
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
# Yosys, strict (tools/shim/yosys, OI-44): run alone, as under the gate.
SHIM = os.path.join(ROOT, "tools", "shim")
if SHIM not in os.environ.get("PATH", "").split(os.pathsep):
    os.environ["PATH"] = SHIM + os.pathsep + os.environ.get("PATH", "")
GENLIB = os.path.join(ROOT, "tools", "ngd.genlib")
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
# CG-5 and RST-1 (2026-10-18) are ratcheted per finding, not per module, so
# a module on this list is still held to CG-1 to CG-4: the findings that
# stood when the rules were made, as "<rule> <register or port>" in the
# ratchet's "findings", ooe_rat's then on OI's branch (b9c3a44). Never add
# to this.
FINDING_RULES = ("CG-5", "RST-1")
FINDINGS_BASELINE = {(m, k) for m, ks in {
    "ooe_age": ["CG-5 older_cq02h"],
    "ooe_confirm": ["CG-5 rep_cq02h", "RST-1 ooe_rst_r00h"],
    "ooe_decq": ["CG-5 st_cq02h", "RST-1 ooe_rst_r00h"],
    "ooe_freelist": ["CG-5 st_cq02h", "RST-1 ooe_rst_r00h"],
    "ooe_rat": ["CG-5 ckpt_cq02h", "CG-5 crat_cq02h", "CG-5 rat_cq02h", "RST-1 ooe_rst_r00h"],
    "ooe_rs": ["CG-5 code_cq02h", "CG-5 dep2", "CG-5 hm_cq02h", "CG-5 hr_cq02h", "CG-5 valid_cq02h", "RST-1 ooe_rst_r00h"],
    "ooe_wake": ["CG-5 iss_cq02h", "CG-5 st_cq02h", "RST-1 ooe_rst_r00h"],
}.items() for k in ks}
# Where design RTL lives, and what in it is not design: generated files,
# the top level (instances and nets only), the ctech views, lint fixtures.
DESIGN_SKIP = ("rtl/include/", "rtl/generated/", "rtl/top/", "rtl/ctech/",
               "rtl/lint/")
ICG = "ccv_common_ctech_icg"
# A repeater's control pulses and its flopped reset, by register name
# (rtl/phys/ccv_common_rpt.sv): counted against the hardening wrapper's
# CCV_CG_BUDGET_PCT, not the repeater's own allowance (Daniel, 2026-10-19).
# Its lead slice, lead_q, is not among them.
RPT = "ccv_common_rpt"
# A register declared (* keep *) keeps its flops through synthesis: a copy
# made to part an output's flop from the module's own paths (check-ngd's
# NGD-7) is merged back into its original otherwise, as a real flow merges
# one not marked to be preserved. Every flow here and in check-ngd reads the
# RTL this way, so all count the same flops.
KEEP_FLOPS = ["proc", "setattr -set keep 1 a:keep %ci1 t:$*dff* %i"]
RPT_CONTROL = ("valid_q", "wake_q", "credit_q", "stall_q", "rst_n_q")

_spec = importlib.util.spec_from_file_location(
    "lint_rtl", os.path.join(ROOT, "tools", "lint-rtl.py"))
lint = importlib.util.module_from_spec(_spec)
_spec.loader.exec_module(lint)


def reg_is(name, reg):
    """Whether a netlist name is register `reg`: at any scope (a generate
    block, an instance), and any element of it if it is an array."""
    base = re.sub(r"(\[\d+\])+$", "", name)
    return base == reg or base.endswith("." + reg)


def param(name):
    for p in json.load(open(os.path.join(ROOT, "params", "ccv_params.json")))["params"]:
        if p["name"] == name:
            return p["value"]
    raise KeyError(name)


NGD_MAX = float(param("CCV_NGD_CG_EN"))
# An input with no architect's budget arrives where check-ngd assumes it
# does: the stage less the default port side (OI-58).
NGD_DEFAULT_ARRIVAL = float(param("CCV_NGD_BUDGET")) - float(param("CCV_NGD_PORT"))
# The rules a waiver may name, and what a CG-5 waiver must also carry
# (OI-59): the input ports it lets into an enable, and that enable's total
# depth, the latest port's arrival plus the cone, which must be within
# CCV_NGD_CG_EN.
WAIVER_RULES = ("CG-1", "CG-2", "CG-3", "CG-4", "CG-5", "RST-1")
WAIVER_KEYS = ("module", "rule", "target", "why", "by", "date")
CG5_WAIVER_KEYS = ("ports", "enable_ngd")
# A waiver carries its threshold, failing again past it (Daniel's decision,
# OA's response OI-66): a CG-3 waiver a DCGE floor per scenario, an
# allowance waiver -- CG-1's written every cycle, CG-4 -- a flop count. Each
# states what was measured when it was written, so a gain can tighten it.
CG3_WAIVER_KEYS = ("floor_pct", "measured_pct")
FLOPS_WAIVER_KEYS = ("max_flops", "measured_flops")
DCGE_MIN = float(param("CCV_DCGE_MIN_PCT"))
MIN_FLOPS = int(param("CCV_CG_MIN_FLOPS"))
BUDGET_PCT = float(param("CCV_CG_BUDGET_PCT"))
MODULE_FLOPS = int(param("CCV_CG_MODULE_FLOPS"))


def run(cmd, cwd=ROOT, **kw):
    return subprocess.run(cmd, cwd=cwd, shell=isinstance(cmd, str),
                          capture_output=True, text=True, **kw)


# A Yosys netlist, once per gate: check-cg and check-ngd synthesise each
# shared unit with the same script, and a big one takes minutes. The key is
# everything the run reads -- the script, whitespace aside, the files it
# names, every file in its -I directories, the strict shim and the Yosys
# version -- so a hit is the netlist the run would write. verify.sh clears
# the cache before its sections, so the gate synthesises everything itself.
SYNTH_CACHE = os.path.join(ROOT, "build", "synth-cache")
_YOSYS_VERSION = []


def yosys_json(cmds, out):
    """Yosys `cmds`, then write_json `out`; from the cache if this script on
    these files has run before. One run per key at a time, so a second
    caller waits for the first's netlist instead of making its own. Returns
    the CompletedProcess of the run (returncode 0 for a hit)."""
    if not _YOSYS_VERSION:
        _YOSYS_VERSION.append(run(["yosys", "-V"]).stdout.strip())
    h = hashlib.sha256()
    h.update(("\n".join(" ".join(c.split()) for c in cmds) + "\n" + _YOSYS_VERSION[0]).encode())
    paths = set()
    shim = shutil.which("yosys")
    if shim:
        paths.add(shim)
    for c in cmds:
        for t in c.split():
            if t.startswith("-I") and os.path.isdir(os.path.join(ROOT, t[2:])):
                d = os.path.join(ROOT, t[2:])
                paths |= {os.path.join(d, f) for f in os.listdir(d)
                          if os.path.isfile(os.path.join(d, f))}
            elif os.path.isfile(os.path.join(ROOT, t)):
                paths.add(os.path.join(ROOT, t))
    for f in sorted(paths):
        h.update(f.encode() + b"\0")
        with open(f, "rb") as fh:
            h.update(hashlib.sha256(fh.read()).digest())
    os.makedirs(SYNTH_CACHE, exist_ok=True)
    hit = os.path.join(SYNTH_CACHE, h.hexdigest() + ".json")
    with open(hit + ".lock", "w") as lk:
        fcntl.flock(lk, fcntl.LOCK_EX)
        if not os.path.exists(hit):
            r = run(["yosys", "-q", "-p", "; ".join(list(cmds) + ["write_json %s" % out])])
            if r.returncode:
                return r
            shutil.copyfile(out, hit + ".tmp")
            os.replace(hit + ".tmp", hit)
            return r
    shutil.copyfile(hit, out)
    return subprocess.CompletedProcess([], 0, "", "")


def jobs():
    """CCV_JOBS at a time, as the gate runs its sections; every core if unset."""
    n = os.environ.get("CCV_JOBS", "")
    return max(1, int(n)) if n.isdigit() else (os.cpu_count() or 1)


def measured(units, measure, pool=None, also=None):
    """Each unit measured, jobs() at a time (the work is Yosys, Verilator and
    the benches, each in the unit's own directory), handed back in order as it
    is done, so the report reads as a serial run's. A unit that raises raises
    here, in its turn. `also(pool, u)`, if given, queues more of a unit's work
    right behind its measurement, on the same pool."""
    own = pool is None
    pool = pool or concurrent.futures.ThreadPoolExecutor(jobs())
    try:
        fs = []
        for u in units:
            fs.append((u, pool.submit(measure, u)))
            if also:
                also(pool, u)
        for u, f in fs:
            f.result()
            yield u
    finally:
        if own:
            pool.shutdown(cancel_futures=True)


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


# An enable's name: <what>_en, then a stage tag and _n or _b if it has them
# (docs/rtl-coding-style.md, "Net naming").
EN_NAME_RE = re.compile(r"^[a-z]\w*_en(_[a-z][a-z]\d{2}[lh])?(_[nb])?$")


def named(cond):
    return bool(NAMED_RE.match(cond.replace(" ", "")))


def enable_name(cond):
    return re.match(r"[A-Za-z_]\w*", cond.replace(" ", "").lstrip("!~")).group(0)


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
        elif not EN_NAME_RE.match(enable_name(cond)):
            out.append(("the enable %s is not named <what>_en[_<stage>][_n|_b]"
                        % enable_name(cond), regs_of(node)))
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


def module_regs(text):
    """Every register an always_ff in the module text assigns."""
    out = set()
    for kind, _, body, _, _ in lint.always_blocks(text):
        if kind == "ff":
            out |= assigned(tokens(body))
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
    or a synchronous reset that overrides it), or 'ungated'. A group is a
    clock gate only at CCV_CG_MIN_FLOPS flops or more: below that no ICG is
    built for it, and its flops are clocked every cycle."""

    @property
    def gated(self):
        return self.kind != "ungated" and len(self.q) >= MIN_FLOPS

    def __init__(self, key, kind, e, epol, r, rpol):
        self.key, self.kind = key, kind
        self.e, self.epol, self.r, self.rpol = e, epol, r, rpol
        self.q = []          # Q nets
        self.depth = 0.0
        self.best = set()    # each Q net's register name
        self.name = ""
        self.regs = set()    # full register names with bits in the group
        self.en_name = ""


class Netlist:
    def __init__(self, path, top, reset=None):
        """reset: the unit's reset port as "name" or "!name", or None."""
        d = json.load(open(path))
        m = d["modules"][top]
        self.ports = m["ports"]
        rbit = rhigh = None
        if reset:
            rbit = self.ports[reset.lstrip("!")]["bits"][0]
            rhigh = not reset.startswith("!")
        self.cells = m["cells"]
        # The module's reset: its port, and the flops that capture it
        # straight, plain flops in a chain from the port (RST-1), each net
        # with its stage. A synchronous reset on any of them, at the port's
        # polarity, is the module's reset.
        self.rbit, self.rhigh = rbit, rhigh
        self.reset_nets = {}
        if rbit is not None:
            plain = collections.defaultdict(list)
            for c in self.cells.values():
                if c["type"] == "$_DFF_P_":
                    plain[c["connections"]["D"][0]].append(c["connections"]["Q"][0])
            self.reset_nets[rbit] = 0
            frontier, k = [rbit], 0
            while frontier:
                k += 1
                frontier = [q for n in frontier for q in plain.get(n, [])
                            if q not in self.reset_nets]
                for q in frontier:
                    self.reset_nets[q] = k
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
            # A synchronous reset that is the unit's reset (its port, or a
            # flop that captures it) acts only in reset cycles, which are
            # never counted: outside them the clock runs on the enable alone,
            # so it does not split a group, and a register with that reset
            # shares a gate with one without.
            if k == "ER" and r in self.reset_nets and rp == rhigh:
                k, r, rp = "E", None, None
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
                g.best.add(n)
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

    def cone_inputs(self, net):
        """The input ports a net's combinational fan-in cone reaches; its
        other leaves are flops and constants."""
        if not hasattr(self, "_inbit"):
            self._inbit = {b: n for n, bits in self.inputs().items() for b in bits
                           if isinstance(b, int)}
        out, seen, stack = set(), set(), [net]
        while stack:
            x = stack.pop()
            if x in seen or not isinstance(x, int):
                continue
            seen.add(x)
            if x in self.driver:
                stack.extend(self.driver[x][1])
            elif x in self._inbit:
                out.add(self._inbit[x])
        return out

    def reset_loads(self, child_resets=None):
        """Where the reset port is used other than on the D pin of a plain
        flop that captures it, one entry per kind and register, sorted.
        child_resets: {module: its reset port} for the design modules with a
        unit of their own: a blackboxed child taking the reset on that port
        flops it itself, and its unit's RST-1 holds it to that (OI-71)."""
        child_resets = child_resets or {}
        out = collections.Counter()
        for n, p in self.ports.items():
            if p["direction"] == "output" and self.rbit in p["bits"]:
                out["output port %s" % n] += 1
        for cn, c in self.cells.items():
            dirs = c.get("port_directions", {})
            for pin, bits in c["connections"].items():
                if self.rbit not in bits or dirs.get(pin, "input") != "input":
                    continue
                if c["type"] == "$_DFF_P_" and pin == "D":
                    continue
                if c["type"] in GATES:
                    what = "logic into %s" % self.net_name(c["connections"]["Y"][0], True)
                elif FLOP_RE.match(c["type"]):
                    reg = re.sub(r"\[\d+\]$", "", self.best(c["connections"]["Q"][0])[0])
                    what = "%s pin of %s" % ({"R": "reset", "E": "enable"}.get(pin, pin), reg)
                else:
                    mm = re.match(r"^\\?\$paramod(?:\$[0-9a-f]+)?\\([^\\]+)", c["type"])
                    mod = mm.group(1) if mm else c["type"].lstrip("\\")
                    if child_resets.get(mod) == pin:
                        continue
                    what = "%s pin %s of %s" % (c["type"].lstrip("\\"), pin, cn)
                out[what] += 1
        return ["%s%s" % (k, " (%d bits)" % v if v > 1 else "") for k, v in sorted(out.items())]

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
        # From a file: a module with many gates makes a script longer than
        # the command line takes (ooe_prodmap's 792).
        sf = os.path.join(work, "cones.abc")
        open(sf, "w").write(script.replace("; ", "\n") + "\n")
        r = run(["yosys-abc", "-f", sf])
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
        cmds += ["hierarchy -top %s" % self.module, "chformal -remove"] + KEEP_FLOPS + [
                 "synth -flatten -top %s" % self.module]
        r = yosys_json(cmds, os.path.join(self.dir, "net.json"))
        if r.returncode:
            raise SystemExit("check-cg: unit %s: yosys failed:\n%s"
                             % (self.name, (r.stdout + r.stderr)[-2000:]))
        self.nl = Netlist(os.path.join(self.dir, "net.json"), self.module, s.get("reset"))

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
                 "-Wno-style", "-Irtl/include", "-Irtl/generated", "--top-module", "cg_tb"]
                # A blackboxed child may instantiate a shared cell (OI-77: ooe_freelist's
                # ccv_common_csa). A library directory resolves only modules still
                # missing, so the netlist's flattened copy never clashes.
                + [x for d in ("rtl/common",) if os.path.isdir(os.path.join(ROOT, d))
                   for x in ("-y", d)]
                # A blackboxed design child's assertions name the package (OI-71).
                + ["--Mdir", hd, "-o", "cg_tb", "rtl/ccv_assert_pkg.sv", tf, nv]
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
        # A reset flopped locally (RST-1) holds the flops behind it in reset
        # for as many cycles after the port lets go as it has stages.
        depth = max(self.nl.reset_nets.values(), default=0)
        for sc, (snaps, obs) in replays.items():
            live, seen, ons = [], not rst, []
            for snap in snaps:
                on = bool(snap.get(rname, 0)) != neg if rst else False
                seen = seen or on
                ons.append(on)
                live.append(seen and not any(ons[-1 - depth:]))
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

    def reg_qs(self, reg):
        """The Q nets of every register named `reg`, at any scope."""
        return [q for q in self.nl.flops if any(reg_is(n, reg) for n, _ in self.nl.alias.get(q, []))]

    def reg_rate(self, reg, sc):
        """For each full register name ending in `reg`: the share of counted
        cycles in which any of its bits changes, clocked every cycle."""
        out = {}
        byname = collections.defaultdict(int)
        for q in self.nl.flops:
            for name, _ in self.nl.alias.get(q, []):
                if reg_is(name, reg):
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
    """budgetable: about flops that are ungated or badly gated (CG-1's
    written every cycle, CG-2, CG-3 on a gate, CG-4), which a budget may
    take. A form or name finding, or one about the scenarios, never is."""

    def __init__(self, rule, module, regs, msg, unit=None, flops=0, budgetable=False):
        self.rule, self.module, self.regs, self.msg, self.unit = rule, module, set(regs), msg, unit
        self.flops, self.budgetable = flops, budgetable
        self.status = "open"
        self.inputs, self.cone = set(), None    # CG-5: input ports and cone depth
        self.scenario, self.pct = None, None    # CG-3 on a gate: where, and its DCGE
        self.enable = None                      # CG-3 on a gate: its enable's name

    def __str__(self):
        where = "%s (unit %s)" % (self.module, self.unit) if self.unit else self.module
        return "%s %s: %s" % (self.rule, where, self.msg)


def unit_findings(u):
    """CG-2 and CG-3 for one measured unit: its clock gates, the groups of
    CCV_CG_MIN_FLOPS flops or more."""
    out = []
    for key, g in sorted(u.nl.groups.items(), key=lambda kv: kv[1].name):
        if not g.gated:
            continue
        if g.depth > NGD_MAX:
            out.append(Finding("CG-2", u.module, g.best,
                               "enable of %s is %.1f NGD deep, over %g (en: %s)"
                               % (g.name, g.depth, NGD_MAX, g.en_name), u.name, len(g.q), True))
        for sc in SCENARIOS:
            if sc not in u.data:
                continue
            v = dcge(u, key, sc)
            if v is not None and v < DCGE_MIN:
                f = Finding("CG-3", u.module, g.best,
                            "%s changes on %.0f%% of its %d enabled cycles in %s, "
                            "under %g%% (en: %s)"
                            % (g.name, v, u.data[sc]["en"][key], sc, DCGE_MIN,
                               g.en_name), u.name, len(g.q), True)
                f.scenario, f.pct, f.enable = sc, v, g.en_name
                out.append(f)
    for c, dep in sorted(u.icg_depth.items()):
        if dep > NGD_MAX:
            out.append(Finding("CG-2", u.module, {c},
                               "ICG %s's enable is %.1f NGD deep, over %g"
                               % (c, dep, NGD_MAX), u.name))
    return out


def child_resets(units):
    """{module: its reset port} for every unit's module (OI-71)."""
    return {x.module: x.spec["reset"].lstrip("!") for x in units if x.spec.get("reset")}


def source_findings(u, resets=None):
    """CG-5 and RST-1, from the netlist alone (Daniel, 2026-10-18).
    CG-5: every clock gate's enable cone, and every explicit ICG's, starts
    only at the module's own flops. An input there is another module's
    logic on a path to a clock gate, whose enable must settle early, and
    that module cannot know it. RST-1: the reset port reaches nothing but the
    D pins of plain flops that capture it; every use of reset is from those."""
    nl, out = u.nl, []
    for key, g in sorted(nl.groups.items(), key=lambda kv: kv[1].name):
        if not g.gated:
            continue
        ins = nl.cone_inputs(g.e) | (nl.cone_inputs(g.r) if g.kind == "ER" else set())
        if ins:
            f = Finding("CG-5", u.module, g.best,
                        "enable of %s comes from input %s, not only from the module's "
                        "own flops (en: %s)" % (g.name, ", ".join(sorted(ins)),
                                                g.en_name), u.name, len(g.q))
            f.inputs, f.cone = set(ins), getattr(g, "depth", None)
            out.append(f)
    for c, en in sorted(nl.icgs):
        ins = nl.cone_inputs(en)
        if ins:
            f = Finding("CG-5", u.module, {c}, "ICG %s's enable comes from input %s, not "
                        "only from the module's own flops" % (c, ", ".join(sorted(ins))), u.name)
            f.inputs, f.cone = set(ins), getattr(u, "icg_depth", {}).get(c)
            out.append(f)
    if nl.rbit is not None:
        loads = nl.reset_loads(resets)
        if loads:
            name = u.spec["reset"].lstrip("!")
            out.append(Finding("RST-1", u.module, {name}, "reset %s is used before it is "
                               "flopped: %s" % (name, "; ".join(loads)), u.name))
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
                ok, notes, flops = bool(by_mod.get(mod)), [], 0
                for u in by_mod.get(mod, []):
                    if u.errors or not all(sc in u.data for sc in SCENARIOS):
                        ok = False
                        continue
                    flops = max(flops, len(u.reg_qs(reg)))
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
                out.append(Finding("CG-1", mod, {reg}, msg, flops=flops, budgetable=every))
    return out


def coverage_check(modules, units):
    """CG-4: every flop is in a clock gate of CCV_CG_MIN_FLOPS or more, or,
    clocked every cycle, changes in at least CCV_DCGE_MIN_PCT of counted
    cycles in every scenario. Registers CG-1 already reports as written
    every cycle are judged there, not again here."""
    every, regs_of_mod = collections.defaultdict(set), {}
    for mod, (rel, text, first) in modules.items():
        regs_of_mod[mod] = module_regs(text)
        for _, why, regs in form_findings(text, first):
            if why.startswith("written every cycle"):
                every[mod] |= set(regs)
    out = []
    for u in units:
        if u.errors or not all(sc in u.data for sc in SCENARIOS):
            continue
        assigned_here = regs_of_mod.get(u.module, set())

        def name_of(q):
            # The register the RTL assigns, not a wire that aliases it.
            for n, _ in sorted(u.nl.alias.get(q, []), key=lambda a: (len(a[0]), a)):
                if any(reg_is(n, r) for r in assigned_here):
                    return n
            return u.nl.best(q)[0]
        loose = collections.defaultdict(list)
        for g in u.nl.groups.values():
            if not g.gated:
                for q in g.q:
                    loose[name_of(q)].append(q)
        for reg, qs in sorted(loose.items()):
            if any(reg_is(reg, r) for r in every.get(u.module, ())):
                continue
            mask = sum(1 << u.qpos[q] for q in qs)
            worst = None
            for sc in SCENARIOS:
                dat = u.data[sc]
                obs = dat["obs"]
                ch = sum(1 for t in dat["counted"] if (obs[t] ^ obs[t + 1]) & mask)
                rate = 100.0 * ch / max(1, dat["cycles"])
                if rate < DCGE_MIN and (worst is None or rate < worst[1]):
                    worst = (sc, rate)
            if worst:
                out.append(Finding("CG-4", u.module, {reg},
                                   "%s: %d flop(s) in no clock gate of %d or more, changing "
                                   "on %.0f%% of %s cycles" % (reg, len(qs), MIN_FLOPS,
                                                               worst[1], worst[0]),
                                   u.name, len(qs), True))
    return out


# == The budget ================================================================

_INNER = None


def inner_helpers():
    """The modules declared inner helpers: a <module>.ngd.json beside the RTL
    with "inner": true (check-ngd's NGD-4), timed as their parents' logic."""
    global _INNER
    if _INNER is None:
        _INNER = set()
        for f in glob.glob(os.path.join(ROOT, "rtl", "**", "*.ngd.json"), recursive=True):
            d = json.load(open(f))
            if d.get("inner"):
                _INNER.add(d["module"])
    return _INNER


def elaborate(name, top, files, blackbox=(), known=(), params=None, defines=(), inner=None):
    """A partition's flops, instance by instance: synthesised with its
    hierarchy kept, each module's flops counted once and multiplied by how
    many times the partition instantiates it. An inner helper (`inner`,
    default inner_helpers()) is flattened into its parent first, as
    check-ngd's synth does: it is its parent's logic, so a constant it makes
    reaches its parent's flops as it does in the replayed netlist (OI-78). Returns the total and, per
    instantiated module (by its source name), its multiplicity and its flop
    count per register name. Nothing replays this netlist, so crosscheck()
    holds it to the replayed one wherever a unit measures the same module."""
    work = os.path.join(BUILD, "part_" + name)
    os.makedirs(work, exist_ok=True)
    jf = os.path.join(work, "part.json")
    cmds = ["read_verilog -sv -formal %s -Irtl/include -Irtl/generated %s"
            % (" ".join("-D%s" % d for d in defines),
               " ".join(["rtl/ccv_assert_pkg.sv"] + list(files)))]
    for bb in blackbox:
        cmds.append("read_verilog -sv -lib -Irtl/include -Irtl/generated %s" % bb)
    if params:
        cmds.append("chparam %s %s" % (" ".join(
            "-set %s %s" % (k, v) for k, v in sorted(params.items())), top))
    inner = inner_helpers() if inner is None else inner
    cmds += ["hierarchy -top %s" % top, "chformal -remove"] + KEEP_FLOPS
    if inner:
        cmds += ["setattr -mod -set keep_hierarchy 1 *",
                 "setattr -mod -unset keep_hierarchy %s" % " ".join(
                     "%s $paramod\\%s\\* $paramod$*\\%s" % (m, m, m) for m in sorted(inner))]
    cmds += ["synth %s-top %s" % ("-flatten " if inner else "", top), "write_json %s" % jf]
    r = run(["yosys", "-q", "-p", "; ".join(cmds)])
    if r.returncode:
        raise SystemExit("check-cg: partition %s: yosys failed:\n%s"
                         % (name, (r.stdout + r.stderr)[-2000:]))
    mods = json.load(open(jf))["modules"]
    per = {}
    for mn, m in mods.items():
        alias = collections.defaultdict(set)
        for nn, v in m["netnames"].items():
            if v["hide_name"] or "$" in nn:
                continue
            for b in v["bits"]:
                if isinstance(b, int):
                    alias[b].add(re.sub(r"(\[\d+\])+$", "", nn.split(".")[-1]))
        cnt, regs, kids = 0, collections.Counter(), []
        for c in m["cells"].values():
            t = c["type"]
            if t in mods:
                kids.append(t)
            elif FLOP_RE.match(t):
                cnt += 1
                for nn in alias.get(c["connections"]["Q"][0], ()):
                    regs[nn] += 1
        per[mn] = (cnt, regs, kids)
    known = set(known) | {top}

    def base(mn):
        if not mn.startswith("$paramod"):
            return mn
        for tok in mn.split("\\"):
            if tok in known:
                return tok
        return mn

    mult = collections.Counter()

    def walk(mn, k):
        mult[mn] += k
        for kid in per[mn][2]:
            walk(kid, k)
    walk(next(mn for mn in mods if base(mn) == top), 1)
    return {"total": sum(per[mn][0] * k for mn, k in mult.items()),
            "inst": [(base(mn), k, per[mn][1]) for mn, k in mult.items()]}


def partitions(modules):
    """The blocks with RTL, each as (name, top, files, blackboxes): a block
    whose top, ccv_<block>, is written by hand rather than generated as a
    stub. The partition is its hardening wrapper, the block and its
    repeaters, where one is generated. Today every block top is a stub."""
    blocks = json.load(open(os.path.join(ROOT, "params", "blocks.json")))
    names = [b["name"] for b in (blocks["blocks"] if isinstance(blocks, dict) else blocks)]
    files, defined = [], {}
    for path in sorted(glob.glob(os.path.join(ROOT, "rtl", "**", "*.sv"), recursive=True)):
        rel = os.path.relpath(path, ROOT)
        if rel.startswith(DESIGN_SKIP):
            continue
        files.append(rel)
        for _, _, n, _ in lint.module_spans(lint.strip_comments(open(path).read())):
            defined[n] = rel
    out = []
    for b in names:
        if "ccv_%s" % b not in defined:
            continue
        wrap = os.path.join("rtl", "top", "wrap", "ccv_%s_w.sv" % b)
        top = "ccv_%s_w" % b if os.path.exists(os.path.join(ROOT, wrap)) else "ccv_%s" % b
        fs = files + ([wrap] if top.endswith("_w") else [])
        out.append((b, top, fs, ["rtl/ctech/sim/%s.sv" % ICG]))
    return out


def reg_base(r):
    """A register's name without its generate scope or bit select."""
    return re.sub(r"(\[[\d:,]+\])+$", "", r.split(".")[-1])


def rpt_control(f):
    """A finding about a repeater's control pulses or its flopped reset
    only: the wrapper's budget takes it (RPT_CONTROL)."""
    return f.module == RPT and f.budgetable and f.regs and all(
        reg_base(r) in RPT_CONTROL for r in f.regs)


def module_budget(findings, units):
    """Each unit may leave the larger of CCV_CG_BUDGET_PCT of its flops and
    fewer than CCV_CG_MODULE_FLOPS flops outside the rules: its budgetable
    findings are taken smallest first while they fit. A finding of a module
    measured in several units is excused only if every one takes it. A
    repeater's control pulses are not its own to take: they count against
    its wrapper's budget (status "wrapper"). Returns a line per unit."""
    for f in findings:
        if f.status == "open" and rpt_control(f):
            f.status = "wrapper"
    cand = [f for f in findings if f.status == "open" and f.budgetable]
    seen, taken, lines = collections.defaultdict(set), collections.defaultdict(set), []
    for u in units:
        if u.errors or u.nl is None:
            continue
        total = len(u.nl.flops)
        allow = max(total * BUDGET_PCT / 100.0, MODULE_FLOPS - 1)
        items = []
        for k, f in enumerate(cand):
            if f.module != u.module or (f.unit is not None and f.unit != u.name):
                continue
            n = unit_flops(u, f)
            seen[k].add(u.name)
            items.append((n, f.rule, sorted(f.regs), k))
        used = count = 0
        for n, _, _, k in sorted(items):
            if used + n > allow:
                break
            used += n
            count += 1
            taken[k].add(u.name)
        wrap = sum(unit_flops(u, f) for f in findings if f.status == "wrapper"
                   and f.module == u.module and f.unit in (None, u.name))
        if items or wrap:
            lines.append("module budget: unit %-12s %5d flops, %4.1f allowed, %d auto-waived "
                         "in %d finding(s)%s" % (u.name, total, allow, used, count,
                                                 "; %d control flops to its wrapper's budget"
                                                 % wrap if wrap else ""))
    for k, f in enumerate(cand):
        if seen[k] and seen[k] <= taken[k]:
            f.status = "module"
    return lines


def took_flops(el, f):
    """A finding's flops in an elaborated partition: its registers, by name,
    in every instance of its module."""
    lasts = {reg_base(r) for r in f.regs}
    return sum(m * sum(regs.get(x, 0) for x in lasts)
               for b, m, regs in el["inst"] if b == f.module)


def unit_flops(u, f):
    """A finding's flops as its unit's replayed netlist counts them, as the
    module budget took them."""
    return f.flops if f.unit == u.name else sum(len(u.reg_qs(r)) for r in f.regs)


def crosscheck(findings, units, known, skew=(), elaborated=None):
    """The block budget counts flops in a netlist synthesised with its
    hierarchy kept, which nothing replays; a unit's netlist is flattened and
    replayed against the simulated RTL. Yosys can read one RTL differently
    in two flows (OI-44), so each measured unit's module is elaborated the
    block budget's way, at the unit's parameters, and must count what the
    replayed netlist counts: all its flops, and those of every finding its
    module budget took. `skew` adds defines to the elaborated read alone:
    the selftest's stand-in for such a misread. `elaborated`, unit name to a
    future, holds elaborations already queued (main_check's, beside the
    measurements). Returns the units' lines and the disagreements."""
    took = [f for f in findings if f.status in ("module", "wrapper")]
    lines, fails = [], []
    for u in units:
        if u.errors or u.nl is None:
            continue
        el = (elaborated[u.name].result() if elaborated and u.name in elaborated
              else unit_elaborate(u, known, skew))
        diff = []
        if el["total"] != len(u.nl.flops):
            diff.append("%d flops, the replayed netlist %d" % (el["total"], len(u.nl.flops)))
        n = 0
        for f in took:
            if f.module != u.module or (f.unit is not None and f.unit != u.name):
                continue
            n += 1
            got, want = took_flops(el, f), unit_flops(u, f)
            if got != want:
                diff.append("%s %s: %d flops, the replayed netlist %d"
                            % (f.rule, "/".join(sorted(f.regs)), got, want))
        if diff:
            fails.append("unit %s: synthesised with its hierarchy kept, %s counts %s; the "
                         "block budget would count the wrong design"
                         % (u.name, u.module, "; ".join(diff)))
        else:
            lines.append("flop count: unit %-12s %5d flops, and %d budgeted finding(s), "
                         "alike kept and replayed" % (u.name, el["total"], n))
    return lines, fails


def unit_elaborate(u, known, skew=()):
    """A unit's module, the block budget's way (crosscheck)."""
    s = u.spec
    return elaborate("unit_" + u.name, u.module, s["files"],
                     [s["blackbox"][b] for b in sorted(s.get("blackbox", {}))], known,
                     s.get("params"), list(s.get("defines", [])) + list(skew))


def block_budget(findings, parts, known):
    """What the module budgets took still counts against each block's
    CCV_CG_BUDGET_PCT, per instance over the block's hierarchy, its
    hardening wrapper's included, and so do its repeaters' control pulses.
    Returns the blocks' lines and the blocks over it."""
    took = [f for f in findings if f.status in ("module", "wrapper")]
    lines, fails = [], []
    for name, top, files, bbs in parts:
        el = elaborate(name, top, files, bbs, known)
        budget = el["total"] * BUDGET_PCT / 100.0
        used, ctl, items = 0, 0, []
        for f in took:
            n = took_flops(el, f)
            if n:
                used += n
                ctl += n if f.status == "wrapper" else 0
                items.append((n, f))
        lines.append("block budget: %-8s %6d flops, %.1f allowed, %d auto-waived in its modules"
                     "%s" % (name, el["total"], budget, used,
                             " (%d of them repeater control)" % ctl if ctl else ""))
        if used > budget:
            worst = ", ".join("%s %s (%d)" % (f.module, "/".join(sorted(f.regs)), n)
                              for n, f in sorted(items, key=lambda x: -x[0])[:3])
            fails.append("block %s: %d flops auto-waived in its modules, over its %g%% of %d "
                         "flops (%.1f); largest: %s" % (name, used, BUDGET_PCT, el["total"],
                                                        budget, worst))
    return lines, fails


_ARRIVALS = {}


def arrival(module, port, arrivals=None):
    """A port's arrival in NGD: from the architect's <module>.ngd.json beside
    its RTL, else NGD_DEFAULT_ARRIVAL. `arrivals`, {(module, port): NGD},
    overrides both (the selftest's)."""
    if arrivals is not None and (module, port) in arrivals:
        return arrivals[(module, port)]
    if module not in _ARRIVALS:
        ports = {}
        for f in glob.glob(os.path.join(ROOT, "rtl", "**", module + ".ngd.json"), recursive=True):
            ports.update(json.load(open(f)).get("ports", {}))
        _ARRIVALS[module] = {n: float(v["arrival"]) for n, v in ports.items() if "arrival" in v}
    return _ARRIVALS[module].get(port, NGD_DEFAULT_ARRIVAL)


def cg5_waiver_refusal(w, f, arrivals=None):
    """Why a CG-5 waiver cannot take finding f, or None (OI-59): it must name
    every input port the enable reads, and state the enable's total depth,
    the latest named port's arrival plus the cone, which must be within
    CCV_NGD_CG_EN and no less than measured."""
    if f.cone is None:
        return "its enable's cone was not timed (unit %s measures no depth)" % f.unit
    ports = set(w.get("ports") or [])
    if f.inputs - ports:
        return "it does not name input(s) %s, which reach the enable" % ", ".join(
            sorted(f.inputs - ports))
    late, at = max(((arrival(f.module, q, arrivals), q) for q in f.inputs))
    total = f.cone + late
    if total > NGD_MAX:
        return ("the enable is %.1f NGD in all (cone %.1f + %s's arrival %.1f), over %g"
                % (total, f.cone, at, late, NGD_MAX))
    try:
        stated = float(w["enable_ngd"])
    except (KeyError, TypeError, ValueError):
        return "it states no enable_ngd"
    if stated + 0.05 < total:
        return ("it states enable_ngd %.1f, under the measured %.1f (cone %.1f + %s's "
                "arrival %.1f)" % (stated, total, f.cone, at, late))
    return None


def cg3_waiver_refusal(w, f):
    """Why a CG-3 waiver cannot take gate finding f, or None (OI-66): it
    states floor_pct and measured_pct by scenario, the floor no higher than
    the measurement, and clears the gate only while its DCGE in f's scenario
    holds at the floor or above."""
    floors, meas = w.get("floor_pct"), w.get("measured_pct")
    if not isinstance(floors, dict) or not isinstance(meas, dict):
        return "it states no floor_pct and measured_pct by scenario"
    sc = f.scenario
    if sc not in floors or sc not in meas:
        return "it states no floor_pct or measured_pct for %s" % sc
    floor, at = float(floors[sc]), float(meas[sc])
    if floor > at:
        return "its %s floor %g%% is over the %g%% it was measured at" % (sc, floor, at)
    if f.pct < floor - 1e-9:
        return ("the gate changes on %.1f%% of its enabled cycles in %s, under the waiver's "
                "floor %g%%" % (f.pct, sc, floor))
    return None


def flops_waiver_refusal(w, f):
    """Why an allowance waiver cannot take finding f, a CG-1 register
    written every cycle or CG-4's flops outside any gate, or None (OI-66):
    it states max_flops and measured_flops, and one flop more is refused."""
    try:
        most, _ = int(w["max_flops"]), int(w["measured_flops"])
    except (KeyError, TypeError, ValueError):
        return "it states no max_flops and measured_flops"
    if f.flops > most:
        return "%d flop(s), over its max_flops %d" % (f.flops, most)
    return None


def waiver_refusal(w, f, arrivals=None):
    """Why waiver w cannot take finding f, by rule, or None."""
    if f.rule == "CG-5":
        return cg5_waiver_refusal(w, f, arrivals)
    if f.rule == "CG-3" and f.scenario is not None:
        return cg3_waiver_refusal(w, f)
    if f.rule in ("CG-1", "CG-4") and f.budgetable:
        return flops_waiver_refusal(w, f)
    return None


def load(path, key):
    return json.load(open(path))[key] if os.path.exists(path) else ([] if key == "waivers" else {})


def policy(findings, modules, units, waivers, ratchet, baseline=RATCHET_BASELINE, parts=(),
           known=(), fratchet=None, fbaseline=FINDINGS_BASELINE, arrivals=None):
    """Apply each module's budget, then the waivers, then the ratchets: a
    waiver for what a budget already takes is refused as excusing nothing,
    and a waiver takes effect with no ratchet edit, the ratchet entry it
    supersedes reported but not failed (OI-59). Then check that each block's
    budget holds what its modules' took. Returns the failures and the
    budgets' lines."""
    fails = []
    fratchet = fratchet or {}
    lines = module_budget(findings, units)
    for f in findings:
        if f.status != "open":
            continue
        for w in waivers:
            if w.get("module") != f.module or w.get("rule") != f.rule:
                continue
            if not any(reg_is(r, w.get("target", "")) for r in f.regs):
                continue
            # A CG-3 waiver may name one gate of its register by its enable
            # (OA's response OI-66): one register gated per slot, each slot's
            # gate held to its own floor.
            if w.get("enable") is not None and w["enable"] != f.enable:
                continue
            w["_used"] = True
            why = waiver_refusal(w, f, arrivals)
            if why:
                fails.append("waiver %s %s %s refused: %s" % (w["module"], w["rule"],
                                                              w["target"], why))
            else:
                f.status = "waived"
                # A gain since the waiver was written: its floor may tighten.
                if f.rule == "CG-3" and f.scenario is not None:
                    at = float(w["measured_pct"][f.scenario])
                    if f.pct >= at + 1:
                        lines.append("  waiver: %s %s %s measures %.1f%% in %s, over the "
                                     "%g%% it records; its floor may tighten"
                                     % (w["module"], w["rule"], w["target"], f.pct,
                                        f.scenario, at))
            break
    for f in findings:
        if f.status == "open" and f.module in ratchet:
            f.status = "ratchet"
    found = collections.defaultdict(set)
    waived = collections.defaultdict(set)
    for f in findings:
        if f.rule not in FINDING_RULES:
            continue
        keys = {"%s %s" % (f.rule, r) for r in f.regs}
        found[f.module] |= keys
        if f.status == "waived":
            waived[f.module] |= keys
        if f.status == "open" and keys <= set(fratchet.get(f.module, [])):
            f.status = "ratchet"
    for mod, keys in sorted(fratchet.items()):
        for k in keys:
            if k in waived.get(mod, set()):
                lines.append("  ratchet: %s %s is superseded by a waiver; the entry may go"
                             % (mod, k))
    fails += [str(f) for f in findings if f.status == "open"]
    if parts:
        more, over = block_budget(findings, parts, known)
        lines += more
        fails += over
    for w in waivers:
        for k in WAIVER_KEYS + (CG5_WAIVER_KEYS if w.get("rule") == "CG-5" else ()):
            if w.get(k) in (None, "", []):
                fails.append("waiver %s: no %s" % (w, k))
        if w.get("rule") not in WAIVER_RULES:
            fails.append("waiver %s: rule %r is not one a waiver may name (%s)"
                         % (w, w.get("rule"), ", ".join(WAIVER_RULES)))
        if not w.get("_used"):
            fails.append("waiver %s %s %s excuses nothing: remove it"
                         % (w["module"], w["rule"], w["target"]))
    measured = {u.module for u in units
                if not u.errors and all(sc in u.data for sc in SCENARIOS)}
    for mod, keys in sorted(fratchet.items()):
        for k in keys:
            if (mod, k) not in fbaseline:
                fails.append("ratchet: %s %s was not on the list when its rule was made; the "
                             "list only shrinks" % (mod, k))
            elif mod in measured and k not in found.get(mod, set()):
                fails.append("ratchet: %s %s now meets the rule: remove it from %s"
                             % (mod, k, os.path.relpath(RATCHET, ROOT)))
    for mod in sorted(ratchet):
        if mod not in baseline:
            fails.append("ratchet: %s was not on the list when the rule was made; "
                         "the list only shrinks" % mod)
        elif mod not in modules:
            fails.append("ratchet: %s is not a design module with flops: remove it" % mod)
        elif mod in measured and all(f.status == "module" for f in findings if f.module == mod):
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
    return fails, lines


RPT_UNITS = os.path.join(ROOT, "rtl", "top", "rpt-units.json")


def load_units(files=None):
    """Every unit: test/**/cg-units.json, and every repeater the design
    instantiates (rtl/top/rpt-units.json, tools/gen-top.py), checked like
    any module (Daniel, 2026-10-18)."""
    out, names = [], set()
    if files is None:
        files = sorted(glob.glob(os.path.join(ROOT, "test", "**", "cg-units.json"),
                                 recursive=True)) + [RPT_UNITS]
    for f in files:
        if not os.path.exists(f):
            continue
        for spec in json.load(open(f))["units"]:
            if spec["name"] in names:
                raise SystemExit("check-cg: unit %s defined twice" % spec["name"])
            names.add(spec["name"])
            out.append(Unit(spec, os.path.relpath(f, ROOT)))
    return out


def report(u, verbose):
    gates = [g for g in u.nl.groups.values() if g.gated]
    small = [g for g in u.nl.groups.values() if g.kind != "ungated" and not g.gated]
    worst = max([g.depth for g in gates] + list(u.icg_depth.values()) + [0.0])
    flops = len(u.nl.flops)
    gflops = sum(len(g.q) for g in gates)
    print("  unit %-14s %-16s %4d flops, %4d in %2d clock gates (%d groups under %d), "
          "worst enable %4.1f NGD" % (u.name, u.module, flops, gflops, len(gates), len(small),
                                      MIN_FLOPS, worst))
    if u.errors:
        for e in u.errors:
            print("    not measured: %s" % e.splitlines()[0])
        return
    for sc in SCENARIOS:
        if sc not in u.data:
            continue
        vals = [dcge(u, k, sc) for k, g in u.nl.groups.items() if g.gated]
        vals = [v for v in vals if v is not None]
        print("    %-6s %5d cycles, activity %.3f, %2d gates enabled, lowest DCGE %s"
              % (sc, u.data[sc]["cycles"], u.data[sc]["activity"], len(vals),
                 "%.0f%%" % min(vals) if vals else "-"))
    if verbose:
        for key, g in sorted(u.nl.groups.items(), key=lambda kv: kv[1].name):
            cells = []
            for sc in SCENARIOS:
                v = dcge(u, key, sc) if sc in u.data else None
                cells.append("%5s" % ("-" if v is None else "%.0f%%" % v))
            kind = "gate" if g.gated else ("ungated" if g.kind == "ungated" else "small")
            print("    %-8s %3d flops %4.1f NGD  %s  %s  (en: %s)" % (
                kind, len(g.q), g.depth, " ".join(cells), g.name, g.en_name or "always"))
        for c, dep in sorted(u.icg_depth.items()):
            print("    ICG                %4.1f NGD  %s's enable" % (dep, c))


def unmeasured(units):
    """A unit its bench could not run fails rather than being skipped: every
    scenario is checked traffic (DA, 2026-10-21), so a bench that fails one
    has found a difference, and the unit's DCGE was never measured."""
    return ["%s not measured: %s" % (u.name, u.errors[0].splitlines()[0]) for u in units if u.errors]


def main_check(only=None, verbose=False):
    modules = design_modules()
    units = load_units()
    resets = child_resets(units)
    if only:
        units = [u for u in units if u.name == only]
        if not units:
            raise SystemExit("check-cg: no unit %s" % only)
    ratchet = load(RATCHET, "modules")
    fratchet = load(RATCHET, "findings")
    waivers = load(WAIVERS, "waivers")
    findings = []
    # Each unit's crosscheck elaboration needs nothing measured, so it is
    # queued on the same pool beside the unit's measurement, and waited for
    # only in crosscheck. A unit whose measurement fails is never asked for.
    pool = concurrent.futures.ThreadPoolExecutor(jobs())
    elaborated = {}

    def queue_el(p, u):
        if not only:
            elaborated[u.name] = p.submit(unit_elaborate, u, modules)
    for u in measured(units, lambda u: u.measure(), pool, queue_el):
        report(u, verbose)
        if u.nl is not None:
            findings += source_findings(u, resets)
        if u.errors:
            continue
        findings += unit_findings(u) + scenario_findings(u)
    findings += form_check(modules, units) + coverage_check(modules, units)
    if only:
        for f in findings:
            print("    " + str(f))
        return 1 if unmeasured(units) else 0
    parts = partitions(modules)
    fails, lines = policy(findings, modules, units, waivers, ratchet, parts=parts,
                          known=modules, fratchet=fratchet)
    more, over = crosscheck(findings, units, modules, elaborated=elaborated)
    lines += more
    fails += over
    fails += unmeasured(units)
    for l in lines:
        print("  " + l)
    if not parts:
        print("  block budget: no block has RTL yet (every block top is a generated stub), "
              "so none is checked")
    for mod in sorted(ratchet):
        n = sum(1 for f in findings if f.module == mod and f.status == "ratchet")
        print("  ratchet: %-14s %s" % (mod, "%d finding(s) excused" % n if n else
                                       "not measured: no unit"))
    for mod in sorted(fratchet):
        n = collections.Counter(f.rule for f in findings
                                if f.module == mod and f.status == "ratchet")
        print("  ratchet: %-14s %s" % (mod, ", ".join("%d %s" % (n[r], r) for r in FINDING_RULES
                                                      if n[r]) or "nothing excused"))
    nw = sum(1 for f in findings if f.status == "waived")
    nb = sum(1 for f in findings if f.status == "module")
    print("  %d module(s), %d unit(s), %d finding(s) auto-waived by a module budget, %d "
          "waiver(s) in use, %d on the ratchet" % (len(modules), len(units), nb, nw,
                                                   len(ratchet)))
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


MEASURED_FIXTURES = ("cg_fx_good", "cg_fx_form", "cg_fx_deep", "cg_fx_dcge", "cg_fx_small",
                     "cg_fx_wide", "cg_fx_big", "cg_fx_name")


def selftest():
    bad = []
    os.makedirs(os.path.join(BUILD, "fixture"), exist_ok=True)
    bench = os.path.join(BUILD, "fixture", "bench")
    files = ["test/cg/fixtures/%s.sv" % m for m in MEASURED_FIXTURES]
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
    mods = {m: (f, lint.strip_comments(open(os.path.join(ROOT, f)).read()), 1)
            for m, f in zip(MEASURED_FIXTURES, files)}
    units = {m: fixture_unit("fx_" + m.split("_")[-1], m) for m in mods}
    for u in units.values():
        u.measure(vcds=vcds)
        if u.errors:
            bad.append("fixture %s not measured: %s" % (u.module, u.errors[0]))
    if bad:
        for x in bad:
            sys.stderr.write("check-cg selftest: %s\n" % x)
        return 1
    allu = list(units.values())
    # Control: a unit whose bench fails a scenario is a failure, not a skip.
    failing = Unit({"name": "fx_fails", "module": "cg_fx_good", "files": ["test/cg/fixtures/cg_fx_good.sv"],
                    "clock": "clk", "reset": "rst",
                    "bench": {"run": "exit 1", "scope": "tb_cg_fixture.u_good"}}, "selftest")
    failing.measure()
    if not unmeasured([failing]):
        bad.append("a unit whose bench fails was not reported")

    def findings():
        out = []
        for u in allu:
            out += source_findings(u) + unit_findings(u) + scenario_findings(u)
        return out + form_check(mods, allu) + coverage_check(mods, allu)
    every = findings()

    def has(rule, mod, reg, fs=None):
        return [f for f in (every if fs is None else fs)
                if f.rule == rule and f.module == mod and
                (reg is None or any(reg_is(r, reg) for r in f.regs))]

    checks = 0

    def expect(cond, what):
        nonlocal checks
        checks += 1
        if not cond:
            bad.append(what)

    # 1. The compliant fixtures have nothing but their flopped reset and
    #    valid, which their allowance takes: a 20-flop gate, a 256-flop gate,
    #    and a free-running LFSR, which is ungated by measurement.
    for m in ("cg_fx_good", "cg_fx_wide"):
        other = [str(f) for f in every if f.module == m and
                 not (f.rule in ("CG-1", "CG-4") and f.regs <= {"rst_q", "v_q"})]
        expect(not other, "compliant fixture %s has findings: %s" % (m, other))
    # 1b. The module's reset does not split an enable: st_q, with it, and d_q,
    #     without, are one gate.
    gs = [g for g in units["cg_fx_good"].nl.groups.values()
          if any(reg_is(r, "st_q") for r in g.best)]
    expect(len(gs) == 1 and gs[0].gated and any(reg_is(r, "d_q") for r in gs[0].best),
           "a register with the module's reset did not share its enable's gate")
    # 2. CG-1: a register written every cycle, idle when its input is.
    expect(has("CG-1", "cg_fx_form", "d_q"), "CG-1 missed a register under no enable")
    # 3. CG-1: an enable that is an expression.
    expect(any("expression" in f.msg for f in has("CG-1", "cg_fx_form", "e_q")),
           "CG-1 missed an expression enable")
    # 4. CG-1: an enable named, but not <what>_en.
    expect(any("not named" in f.msg for f in has("CG-1", "cg_fx_form", "n_q")),
           "CG-1 missed an enable not named _en")
    # 5. CG-2: an add and a compare into the gate.
    expect(has("CG-2", "cg_fx_deep", "d_q"), "CG-2 missed a deep enable")
    expect(not has("CG-2", "cg_fx_deep", "acc_q"), "CG-2 flagged a shallow enable")
    # 6. CG-3: eight flops enabled on every valid, almost never changing.
    expect(has("CG-3", "cg_fx_dcge", "hit_q"), "CG-3 missed a low-DCGE gate")
    expect(not has("CG-3", "cg_fx_wide", None), "CG-3 flagged a good gate")
    # 7. CG-4: a 4-flop group is no clock gate, and it holds still when idle.
    expect(has("CG-4", "cg_fx_small", "c_q"), "CG-4 missed flops in a group under %d"
           % MIN_FLOPS)
    expect(not has("CG-3", "cg_fx_small", None) and not has("CG-2", "cg_fx_small", None),
           "a group under %d was judged as a clock gate" % MIN_FLOPS)
    # 8. The replay: a trace from another module is refused.
    u = fixture_unit("fx_swap", "cg_fx_good", scope="tb_cg_fixture.u_dcge")
    u.measure(vcds=vcds)
    expect(any("differ" in e for e in u.errors), "a trace of another module replayed clean")
    # 9. The scenarios: swapped idle and high, and one too short.
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

    def run_policy(mods_in, waivers=(), ratchet=None, baseline=RATCHET_BASELINE, parts=(),
                   fratchet=None, fbaseline=FINDINGS_BASELINE):
        fs = [f for f in findings() if f.module in mods_in]
        us = [x for x in allu if x.module in mods_in]
        ws = [dict(w) for w in waivers]
        fails, _ = policy(fs, {m: mods[m] for m in mods_in if m in mods}, us, ws,
                          ratchet or {}, baseline=baseline, parts=parts,
                          known=set(mods) | {"cg_fx_blk_ok", "cg_fx_blk_over"},
                          fratchet=fratchet, fbaseline=fbaseline)
        return fails, fs

    # 10. Waivers: one that excuses a finding clears it; one that excuses
    #     nothing is refused. hit_q's DCGE by scenario, and d_q's flops,
    #     are the thresholds the waivers below state (OI-66).
    hit_dcge = {f.scenario: f.pct for f in has("CG-3", "cg_fx_dcge", "hit_q")}
    hit_floor = {"floor_pct": dict(hit_dcge), "measured_pct": dict(hit_dcge)}
    d_flops = max((f.flops for f in has("CG-1", "cg_fx_form", "d_q")), default=0)
    d_most = {"max_flops": d_flops, "measured_flops": d_flops}
    expect(hit_dcge and d_flops, "no CG-3 finding on hit_q or CG-1 on d_q to waive: %s, %s"
           % (hit_dcge, d_flops))
    w_ok = dict({"module": "cg_fx_dcge", "rule": "CG-3", "target": "hit_q", "why": "control",
                 "by": "TI", "date": "2026-10-16"}, **hit_floor)
    fails, _ = run_policy(("cg_fx_good", "cg_fx_dcge"), [w_ok])
    expect(not fails, "a waiver did not clear its finding: %s" % fails)
    w_stale = {"module": "cg_fx_good", "rule": "CG-3", "target": "d_q", "why": "control",
               "by": "TI", "date": "2026-10-16"}
    fails, _ = run_policy(("cg_fx_good",), [w_stale])
    expect(any("excuses nothing" in x for x in fails), "a stale waiver was accepted")
    # 11. The ratchet: a listed module that meets the rule must leave it; a
    #     module outside the baseline cannot join it.
    fails, _ = run_policy(tuple(mods), ratchet={"cg_fx_good": {}, "cg_fx_form": {}},
                          baseline={"cg_fx_good"})
    expect(any("cg_fx_good now meets the rule" in x for x in fails),
           "a ratcheted module that passes stayed on the list")
    expect(any("cg_fx_form was not on the list" in x for x in fails), "the ratchet grew")
    # 12. Coverage: a module with flops and no unit.
    fails, _ = policy([], mods, [x for x in allu if x.module != "cg_fx_form"], [], {})
    expect(any("cg_fx_form" in x and "no clock-gating unit" in x for x in fails),
           "a module with no unit passed")
    # 13. The module budget. Fewer than CCV_CG_MODULE_FLOPS flops are taken
    #     whatever the module's size; past that, 2% of its flops; past both,
    #     the finding stands; a name is never taken; a waiver for what a
    #     module budget took is refused.
    fails, fs = run_policy(("cg_fx_small",))
    expect(not fails and all(f.status == "module" for f in has("CG-4", "cg_fx_small", "c_q", fs)),
           "a module's 4 loose flops were not taken by its fixed allowance: %s" % fails)
    fails, fs = run_policy(("cg_fx_big",))
    expect(not fails and all(f.status == "module" for f in has("CG-1", "cg_fx_big", "idle_q", fs))
           and has("CG-1", "cg_fx_big", "idle_q", fs),
           "a 521-flop module's 9 loose flops were not taken by its 2%%: %s" % fails)
    fails, _ = run_policy(("cg_fx_form",))
    expect(any("CG-1 cg_fx_form" in x and "d_q" in x for x in fails),
           "16 loose flops in a small module were taken")
    fails, fs = run_policy(("cg_fx_name",))
    expect(any("not named" in x for x in fails)
           and all(f.status == "module" for f in has("CG-4", "cg_fx_name", "n_q", fs)),
           "a misnamed enable was auto-waived, or its flops were not: %s" % fails)
    w_small = {"module": "cg_fx_small", "rule": "CG-4", "target": "c_q", "why": "control",
               "by": "TI", "date": "2026-10-17"}
    fails, _ = run_policy(("cg_fx_small",), [w_small])
    expect(any("excuses nothing" in x for x in fails),
           "a waiver for what a module budget takes was accepted")
    # 14. The block budget: what the modules took counts against 2% of the
    #     block's flops, per instance. 4 of 260 holds; 8 of 136 does not.
    fx = ["test/cg/fixtures/%s.sv" % m for m in ("cg_fx_wide", "cg_fx_small")]
    p_ok = ("fx_ok", "cg_fx_blk_ok", fx + ["test/cg/fixtures/cg_fx_blk_ok.sv"], [])
    p_over = ("fx_over", "cg_fx_blk_over", fx + ["test/cg/fixtures/cg_fx_blk_over.sv"], [])
    small = ("cg_fx_small", "cg_fx_wide")
    fails, _ = run_policy(small, parts=[p_ok])
    expect(not fails, "a block within its 2%% failed: %s" % fails)
    fails, _ = run_policy(small, parts=[p_over])
    expect(any("block fx_over" in x and "over its" in x for x in fails),
           "a block over its 2% with its modules' auto-waivers passed")
    # 15. The block budget's flop counts, from netlists nothing replays,
    #     agree with the replayed ones: for every fixture, totals and what the
    #     module budgets took; and a module the elaborated read takes
    #     differently, one flop fewer in cg_fx_small's counter, is refused.
    _, fs = run_policy(tuple(mods))
    _, xf = crosscheck(fs, allu, set(mods))
    expect(not xf, "kept and replayed flop counts differ on the fixtures: %s" % xf)
    _, xf = crosscheck(fs, [units["cg_fx_small"], units["cg_fx_big"]], set(mods),
                       skew=["CG_FX_MISREAD"])
    expect(any("unit fx_small" in x and "c_q" in x and "3 flops" in x for x in xf)
           and not any("fx_big" in x for x in xf),
           "a module elaborated with one flop fewer than its replayed netlist passed: %s" % xf)
    # 16. CG-5 and RST-1, from a netlist (cg_fx_src): a gate enabled
    #     straight from an input, the reset port in a gate's enable, an ICG
    #     enabled from an input; the reset port on a flop's reset pin and
    #     straight out; and a gate on the module's own flop, which passes.
    u = Unit({"name": "fx_src", "module": "cg_fx_src",
              "files": ["test/cg/fixtures/cg_fx_src.sv"], "clock": "clk", "reset": "rst",
              "blackbox": {ICG: "rtl/ctech/sim/%s.sv" % ICG}}, "selftest")
    u.synth()
    u.measure_depth()
    sf = source_findings(u)
    expect(has("CG-5", "cg_fx_src", "a_q", sf), "CG-5 missed a gate enabled from an input")
    expect(any("rst" in f.msg for f in has("CG-5", "cg_fx_src", "d_q", sf)),
           "CG-5 missed the reset port in an enable")
    expect(has("CG-5", "cg_fx_src", "u_icg", sf), "CG-5 missed an ICG enabled from an input")
    expect(not has("CG-5", "cg_fx_src", "b_q", sf), "CG-5 flagged a gate on a flop")
    r1 = has("RST-1", "cg_fx_src", None, sf)
    expect(r1 and "reset pin of c_q" in r1[0].msg and "output port rst_o" in r1[0].msg
           and "logic into d_en" in r1[0].msg,
           "RST-1 missed the reset port used before a flop: %s" % [str(f) for f in r1])
    expect(not has("RST-1", "cg_fx_good", None) and not has("CG-5", "cg_fx_good", None),
           "a flopped reset and a flopped valid were refused")
    #     A blackboxed design child with its own unit flops the reset it takes
    #     on its own reset port (OI-71): the parent passes it there, and on
    #     any other pin still refuses it; with no unit for the child, both.
    pu = Unit({"name": "fx_parent", "module": "cg_fx_parent",
               "files": ["test/cg/fixtures/cg_fx_parent.sv"], "clock": "clk", "reset": "rst",
               "blackbox": {"cg_fx_good": "test/cg/fixtures/cg_fx_good.sv"}}, "selftest")
    pu.synth()
    pu.measure_depth()
    pr = has("RST-1", "cg_fx_parent", None, source_findings(pu, {"cg_fx_good": "rst"}))
    expect(pr and "pin in_v of u_bad" in pr[0].msg and "u_ok" not in pr[0].msg,
           "RST-1 took a child's data pin, or refused its own reset port: %s" % [str(f) for f in pr])
    pr = has("RST-1", "cg_fx_parent", None, source_findings(pu))
    expect(pr and "pin rst of u_ok" in pr[0].msg,
           "RST-1 passed a reset into a child with no unit of its own: %s" % [str(f) for f in pr])
    # 17. CG-5 and RST-1 are ratcheted per finding: one listed is excused and
    #     the module's others are not, nor a gate only some of whose
    #     registers are listed; one that now passes, or one outside the
    #     baseline, is refused.
    a5 = [f for f in has("CG-5", "cg_fx_src", "a_q", sf) if f.regs >= {"a_q", "a2_q"}]
    fails, _ = policy(a5, {"cg_fx_src": ("f", "", 1)}, [u], [], {},
                      fratchet={"cg_fx_src": ["CG-5 a_q"]}, fbaseline={("cg_fx_src", "CG-5 a_q")})
    expect(a5 and any("a2_q" in x for x in fails),
           "a gate was excused with one of its two registers listed: %s" % fails)
    fb = {("cg_fx_form", "CG-5 e_q"), ("cg_fx_good", "CG-5 d_q")}
    fails, fs = run_policy(("cg_fx_form",), fratchet={"cg_fx_form": ["CG-5 e_q"]},
                           fbaseline=fb)
    expect(all(f.status == "ratchet" for f in has("CG-5", "cg_fx_form", "e_q", fs))
           and any("CG-5 cg_fx_form" in x and "n_q" in x for x in fails),
           "the finding ratchet excused too little or too much: %s" % fails)
    fails, _ = run_policy(("cg_fx_good",), fratchet={"cg_fx_good": ["CG-5 d_q"]}, fbaseline=fb)
    expect(any("CG-5 d_q now meets the rule" in x for x in fails),
           "a ratcheted finding that passes stayed on the list")
    fails, _ = run_policy(("cg_fx_form",), fratchet={"cg_fx_form": ["CG-5 n_q"]}, fbaseline=fb)
    expect(any("CG-5 n_q was not on the list" in x for x in fails), "the finding ratchet grew")
    # 19. The waiver path (OI-59). A waiver of each rule clears its finding
    #     with no ratchet or RTL change, and a waiver on a group clears that
    #     group only. A CG-5 waiver must name every input reaching the
    #     enable and state its total depth, the latest input's arrival plus
    #     the cone, within CCV_NGD_CG_EN: a_q's enable is in_v itself (cone
    #     0), so it passes at an arrival of 2, and is refused at the default
    #     13, unnamed, understated or with no total. Beside a ratchet entry
    #     for the same registers, a waiver passes and the entry is reported
    #     as superseded; a waiver of a rule outside WAIVER_RULES is refused.
    def wv(mod, rule, target, **kw):
        return dict({"module": mod, "rule": rule, "target": target, "why": "control",
                     "by": "TI", "date": "2026-10-20"}, **kw)

    def cleared(rule, mod, reg, mods_in, w):
        fails, fs = run_policy(mods_in, [w])
        hit = has(rule, mod, reg, fs)
        return (hit and all(f.status == "waived" for f in hit)
                and not any(rule in x and reg in x for x in fails)
                and not any("waiver" in x for x in fails))
    for rule, mod, reg, kw in (("CG-1", "cg_fx_form", "d_q", d_most),
                               ("CG-2", "cg_fx_deep", "d_q", {}),
                               ("CG-3", "cg_fx_dcge", "hit_q", hit_floor)):
        expect(cleared(rule, mod, reg, (mod,), wv(mod, rule, reg, **kw)),
               "a %s waiver did not clear %s %s on its own" % (rule, mod, reg))
    # 19a. Thresholds (Daniel's decision, OA's response OI-66). A CG-3
    #      waiver at hit_q's measured DCGE clears it; one a point above in
    #      any scenario fails, the finding standing and the refusal naming
    #      the floor; a floor over what it records, or none, is refused. An
    #      allowance waiver at d_q's flop count clears it; one flop under
    #      fails; none is refused.
    sc0 = sorted(hit_dcge)[0] if hit_dcge else "idle"
    up = {sc: v + (1 if sc == sc0 else 0) for sc, v in hit_dcge.items()}
    for what, kw, want in (
            ("a point above the measurement", {"floor_pct": up, "measured_pct": up},
             "under the waiver's floor"),
            ("over what it records", {"floor_pct": up, "measured_pct": hit_dcge},
             "is over the"),
            ("with no floor", {}, "no floor_pct")):
        fails, fs = run_policy(("cg_fx_dcge",), [wv("cg_fx_dcge", "CG-3", "hit_q", **kw)])
        expect(any(want in x for x in fails)
               and any(f.status == "open" for f in has("CG-3", "cg_fx_dcge", "hit_q", fs)),
               "a CG-3 waiver %s was accepted: %s" % (what, fails))
    for what, kw, want in (
            ("one flop under", {"max_flops": d_flops - 1, "measured_flops": d_flops},
             "over its max_flops"),
            ("with no flop count", {}, "no max_flops")):
        fails, fs = run_policy(("cg_fx_form",), [wv("cg_fx_form", "CG-1", "d_q", **kw)])
        expect(any(want in x for x in fails)
               and any(f.status == "open" for f in has("CG-1", "cg_fx_form", "d_q", fs)),
               "an allowance waiver %s was accepted: %s" % (what, fails))
    #      A CG-3 waiver may name one gate by its enable (OA's response
    #      OI-66): naming hit_q's clears it; naming another leaves it open
    #      and excuses nothing.
    hit_en = {f.enable for f in has("CG-3", "cg_fx_dcge", "hit_q")}
    expect(len(hit_en) == 1, "hit_q's CG-3 findings name enables %s, not one" % hit_en)
    en = next(iter(hit_en), "")
    fails, fs = run_policy(("cg_fx_dcge",), [wv("cg_fx_dcge", "CG-3", "hit_q", enable=en, **hit_floor)])
    expect(not fails and all(f.status == "waived" for f in has("CG-3", "cg_fx_dcge", "hit_q", fs)),
           "a CG-3 waiver naming hit_q's enable %s did not clear it: %s" % (en, fails))
    fails, fs = run_policy(("cg_fx_dcge",), [wv("cg_fx_dcge", "CG-3", "hit_q", enable=en + "_other",
                                                **hit_floor)])
    expect(any("excuses nothing" in x for x in fails)
           and all(f.status == "open" for f in has("CG-3", "cg_fx_dcge", "hit_q", fs)),
           "a CG-3 waiver naming another enable cleared hit_q: %s" % fails)
    srcmod = {"cg_fx_src": ("f", "", 1)}
    a5 = [f for f in has("CG-5", "cg_fx_src", "a_q", sf) if f.regs >= {"a_q", "a2_q"}]
    d5 = has("CG-5", "cg_fx_src", "d_q", sf)
    r1 = has("RST-1", "cg_fx_src", None, sf)
    fast = {("cg_fx_src", "in_v"): 2.0}

    def src_policy(fs, ws, **kw):
        for f in fs:
            f.status = "open"
        return policy(fs, srcmod, [u], [dict(w) for w in ws], {}, arrivals=fast, **kw)
    w_a = wv("cg_fx_src", "CG-5", "a_q", ports=["in_v"], enable_ngd=2.0)
    fails, _ = src_policy(a5 + d5, [w_a])
    expect(a5 and all(f.status == "waived" for f in a5)
           and all(f.status == "open" for f in d5) and d5
           and not any("a_q" in x for x in fails) and any("d_q" in x for x in fails),
           "a CG-5 waiver on a_q's group did not clear the whole group, or cleared another: %s"
           % fails)
    expect(a5 and a5[0].cone == 0.0 and a5[0].inputs == {"in_v"},
           "a_q's enable was not timed as in_v alone: cone %s, inputs %s"
           % (a5 and a5[0].cone, a5 and a5[0].inputs))
    fails, _ = src_policy(r1, [wv("cg_fx_src", "RST-1", "rst")])
    expect(r1 and all(f.status == "waived" for f in r1) and not fails,
           "an RST-1 waiver did not clear its finding: %s" % fails)
    for what, w, arr, want in (
            ("at the default arrival", w_a, {}, "over %g" % NGD_MAX),
            ("with in_v unnamed", dict(w_a, ports=["in_d"]), fast, "does not name input(s) in_v"),
            ("understating its total", dict(w_a, enable_ngd=1.0), fast, "under the measured"),
            ("with no total", {k: v for k, v in w_a.items() if k != "enable_ngd"}, fast,
             "no enable_ngd")):
        for f in a5:
            f.status = "open"
        fails, _ = policy(a5, srcmod, [u], [dict(w)], {}, arrivals=arr)
        expect(any(want in x for x in fails) and all(f.status == "open" for f in a5),
               "a CG-5 waiver %s was accepted: %s" % (what, fails))
    fb5 = {("cg_fx_src", "CG-5 a_q"), ("cg_fx_src", "CG-5 a2_q")}
    for f in a5:
        f.status = "open"
    fails, lines = policy(a5, srcmod, [u], [dict(w_a)], {}, arrivals=fast,
                          fratchet={"cg_fx_src": ["CG-5 a_q", "CG-5 a2_q"]}, fbaseline=fb5)
    expect(not fails and any("superseded by a waiver" in x for x in lines),
           "a waiver beside a ratchet entry for the same registers failed, or the entry was "
           "not reported as superseded: %s" % fails)
    fails, _ = run_policy(("cg_fx_form",), [wv("cg_fx_form", "CG-9", "d_q")])
    expect(any("not one a waiver may name" in x for x in fails),
           "a waiver of an unknown rule was accepted")
    # 18. Every repeater instantiation is a unit, checked like any module.
    #     Its control pulses (valid, wake, credit and stall at each stage,
    #     and the flopped reset) count against its wrapper's budget, not its
    #     own allowance (Daniel, 2026-10-19): two stages of a 16-bit slot,
    #     nine of them in 41 flops, pass. Its lead slice does not: with a
    #     16-bit lead, whose first-stage flops are written every cycle, one
    #     stage of a 64-bit slot is past its allowance; without, it passes.
    rtext = lint.strip_comments(open(os.path.join(ROOT, "rtl/phys/ccv_common_rpt.sv")).read())
    rregs = {reg_base(r) for r in module_regs(rtext)}
    expect(set(RPT_CONTROL) <= rregs and "lead_q" in rregs and "lead_q" not in RPT_CONTROL,
           "RPT_CONTROL names registers the repeater lacks, or its lead slice: %s, %s"
           % (sorted(set(RPT_CONTROL) - rregs), sorted(rregs)))
    expect(not rpt_control(Finding("CG-1", "cg_fx_small", {"valid_q"}, "", flops=1,
                                   budgetable=True))
           and not rpt_control(Finding("CG-1", RPT, {"valid_q", "g_stage[0].g_slot[0].lead_q"},
                                       "", flops=2, budgetable=True))
           and rpt_control(Finding("CG-1", RPT, {"g_stage[1].valid_q"}, "", flops=1,
                                   budgetable=True)),
           "another module's register of a control pulse's name, or a repeater finding with "
           "its lead slice in it, went to the wrapper's budget, or a stage's valid did not")
    rus = load_units([os.path.join(FIXTURE_DIR, "rpt-units.json")])
    rmod = {RPT: ("rtl/phys/ccv_common_rpt.sv", rtext, 1)}
    rwaivers = [w for w in load(WAIVERS, "waivers") if w["module"] == RPT]
    rfails, rfs = {}, {}
    for ru in rus:
        ru.measure()
        fs = source_findings(ru) + unit_findings(ru) + scenario_findings(ru)
        fs += form_check(rmod, [ru]) + coverage_check(rmod, [ru])
        rfails[ru.name], _ = policy(fs, rmod, [ru], [dict(w) for w in rwaivers], {})
        rfs[ru.name] = fs
        if ru.errors:
            rfails[ru.name] += ru.errors
    expect(not rfails["fx_rpt_plain"], "a repeater instantiation within its allowance "
           "failed: %s" % rfails["fx_rpt_plain"])
    expect(any("lead_q" in x for x in rfails["fx_rpt_lead"]),
           "a repeater whose lead slice is past its allowance passed: %s" % rfails["fx_rpt_lead"])
    ctl = [f for f in rfs["fx_rpt_narrow2"] if f.status == "wrapper"]
    expect(not rfails["fx_rpt_narrow2"] and {reg_base(r) for f in ctl for r in f.regs}
           == set(RPT_CONTROL),
           "a two-stage repeater's control pulses were held to its own allowance, or not all "
           "sent to its wrapper's: %s; %s" % (rfails["fx_rpt_narrow2"],
                                               sorted(r for f in ctl for r in f.regs)))
    #     And they count against the wrapper: with one stage beside two
    #     cg_fx_wide, 7 of 535 flops hold its 2%; with two stages beside
    #     one, 10 of 298 do not.
    wide = next(x for x in allu if x.module == "cg_fx_wide")
    wfs = [f for f in findings() if f.module == "cg_fx_wide"]
    wmods = {"cg_fx_wide": mods["cg_fx_wide"], RPT: rmod[RPT]}
    wknown = set(mods) | {RPT, "cg_fx_wrap_ok", "cg_fx_wrap_over"}
    wfiles = ["rtl/phys/ccv_common_rpt.sv", "test/cg/fixtures/cg_fx_wide.sv"]
    nar = next(x for x in rus if x.name == "fx_rpt_narrow2")
    for top, want in (("cg_fx_wrap_ok", False), ("cg_fx_wrap_over", True)):
        part = (top[6:], top, wfiles + ["test/cg/fixtures/%s.sv" % top], [])
        fs = wfs + form_check(rmod, [nar]) + coverage_check(rmod, [nar]) + unit_findings(nar)
        for f in fs:
            f.status = "open"
        fails, blines = policy(fs, wmods, [wide, nar], [dict(w) for w in rwaivers], {},
                               parts=[part], known=wknown)
        if os.environ.get("CG_SELFTEST_VERBOSE"):
            print("\n".join("    " + x for x in blines))
        over = [x for x in fails if "block %s" % top[6:] in x and "over its" in x]
        expect(bool(over) == want and len(fails) == len(over),
               "a wrapper %s its 2%% with its repeater's control pulses %s: %s"
               % ((("over", "passed") if want else ("within", "failed")) + (fails,)))
    # 19. A register's (* keep *) copies (check-ngd's NGD-7) survive
    #     synthesis here too (KEEP_FLOPS): both are counted where unmarked
    #     copies merge into one, six flops fewer.
    kf = ["test/ngd/fixtures/ngd_fx_shared.sv"]
    kept = elaborate("fx_keep", "ngd_fx_split", kf)["total"]
    bare = elaborate("fx_bare", "ngd_fx_split_bare", kf)["total"]
    expect(kept == bare + 6, "(* keep *) copies of a 6-bit register were merged, or unmarked "
           "ones were not: %d flops kept, %d bare" % (kept, bare))
    # 19b. An inner helper is flattened into its parent before the count
    #      (OI-78): cg_fx_inner_h ties a bit to zero, so its parent's flop on
    #      it is constant and dropped, as in the replayed netlist. With the
    #      helper's boundary kept, the flop would stay.
    inf = ["test/cg/fixtures/cg_fx_inner.sv"]
    flat = elaborate("fx_inner", "cg_fx_inner", inf, inner={"cg_fx_inner_h"})["total"]
    kept_b = elaborate("fx_inner_kept", "cg_fx_inner", inf, inner=())["total"]
    expect(flat == 3 and kept_b == 4, "an inner helper's constant bit: %d flops flattened "
           "(want 3), %d with its boundary kept (want 4)" % (flat, kept_b))
    # 20. The synthesis cache: a header the script reads only through -I
    # changes, and the cache must miss, not hand back the old netlist.
    inc = os.path.join(BUILD, "fixture", "cache_inc")
    os.makedirs(inc, exist_ok=True)
    top = os.path.join(BUILD, "fixture", "cache_top.sv")
    with open(top, "w") as fh:
        fh.write('`include "cache_w.svh"\nmodule cache_top(input logic clk, input logic [W-1:0] d,'
                 ' output logic [W-1:0] q);\n  always_ff @(posedge clk) q <= d;\nendmodule\n')
    widths = []
    for w in (3, 5):
        with open(os.path.join(inc, "cache_w.svh"), "w") as fh:
            fh.write("localparam int W = %d;\n" % w)
        nj = os.path.join(BUILD, "fixture", "cache_%d.json" % w)
        r = yosys_json(["read_verilog -sv -I%s %s" % (os.path.relpath(inc, ROOT),
                                                     os.path.relpath(top, ROOT)),
                        "synth -flatten -top cache_top"], nj)
        widths.append(sum(1 for c in json.load(open(nj))["modules"]["cache_top"]["cells"].values()
                          if "DFF" in c["type"].upper()) if not r.returncode else -1)
    expect(widths == [3, 5], "the synthesis cache handed back a netlist after an -I header "
           "changed: %s flops, want [3, 5]" % widths)
    for x in bad:
        sys.stderr.write("check-cg selftest: %s\n" % x)
    if not bad:
        print("  form, names, enable depth, DCGE, small groups, replay, scenarios, waivers, "
              "ratchet, coverage, module and block budgets, kept and replayed flop counts, "
              "enable sources and the reset, repeater instantiations, kept copies, the "
              "synthesis cache (%d controls)" % checks)
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
