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
# Interface checkers are design-scope, plus four rules of their own from
# docs/interface-checker-convention.md.
SCOPE_CHECKER = ("rtl/if/", "rtl/lint/")

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


def clk_domain(name):
    """The domain segment of a clock net -- the segment immediately before
    `_clk`. `sched_core_clk` -> 'core'; `core_clk` -> 'core'; `test_clk` ->
    'test'. That placement is what makes the `_core_` marker mechanically
    checkable rather than a reading convention."""
    m = CLK_RE.match(name)
    return m.group(2) if m else None


def always_blocks(src):
    """(kind, clock_or_None, body, line) for each always block.

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
        out.append((kind, clk, body, line_of(src, m.start())))
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
            reset, so it is the one control signal that cannot be X."""
            return sorted(n for n in (idents(expr) & ins) - known
                          if not is_reset(n))

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
    is_checker = (any(rel.startswith(r) for r in SCOPE_CHECKER)
                  and mods and mods[0][1].endswith("_checker"))
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
        declared = re.search(r"^\s*//\s*Block:\s*(\w+)", raw, re.M)
        blk_name = declared.group(1) if declared else None

        # A REUSABLE module -- an interface checker, a primitive -- takes
        # `clk`/`rst` as generic formals, because one instance of it lives
        # inside many blocks and binds to each block's own uniquified clock. A
        # formal named for one block would read as a lie in every other, so
        # the clock-name and stage rules do not apply to it.
        #
        # This is DECLARED, never inferred. Inferring it from "the clock is
        # not named like a clock" would let every non-compliant file exempt
        # itself by being non-compliant.
        reusable = re.search(r"^\s*//\s*Reusable:\s*(\S.*)", raw, re.M)

        if not reusable and not blk_name and re.search(r"\balways_ff\b", src):
            add("CCV-L21", 1,
                "design RTL with sequential logic declares neither "
                "`// Block: <name>` nor `// Reusable: <why>`. The block name "
                "is what the stage tag's block letter is checked against, so "
                "without it the naming rules cannot be applied at all")
        blk_letter = None
        for L, b in blocks.items():
            if b["name"] == blk_name:
                blk_letter = L

        # -- CCV-L19: lowercase, underscore-separated ----------------------
        # Parameters keep UPPER_SNAKE; everything else is lower_snake_case.
        for m in re.finditer(r"\b(?:logic|wire|reg)\b[^;\n]*?\b([A-Za-z_]\w*)\s*[;,=\)]",
                             src):
            n = m.group(1)
            if re.search(r"[A-Z]", n):
                add("CCV-L19", line_of(src, m.start()),
                    "net %r is not lower_snake_case; only parameters and "
                    "localparams carry upper case" % n)

        # -- CCV-L20: clocks are named for it, and only clocks are clocks ---
        for kind, clk, body, ln in (() if reusable else always_blocks(src)):
            if not clk:
                continue
            cname, edge = clk
            base = cname.split(".")[-1]
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

            # -- CCV-L22: blocks run on their own gated clock ---------------
            # Each block gates core_clk on entry. Using the ungated clock
            # inside a block silently defeats that gating, and nothing in
            # simulation shows it -- the design works, it just never saves
            # any power.
            if base == "core_clk" and blk_name:
                add("CCV-L22", ln,
                    "block %r clocks logic on the ungated `core_clk`. Use the "
                    "block's uniquified `<block>_core_clk`; the ungated clock "
                    "defeats the block's global gate, and simulation cannot "
                    "show it" % blk_name)

        # A clock net may feed an edge expression, a port map, or ANOTHER
        # CLOCK NET -- that last one is the block's gate, which is the whole
        # reason `<block>_core_clk` exists. Anything else is a clock read as
        # data, which is how a clock ends up in a datapath unnoticed.
        if not reusable:
            for m in re.finditer(r"(?:assign\s+)?([a-z]\w*)\s*(?:<=|=)\s*([^;]+);",
                                 src):
                lhs, rhs = m.group(1), m.group(2)
                if clk_domain(lhs):
                    continue        # building a clock from a clock: the gate
                for cm in re.finditer(r"\b([a-z]\w*_clk(?:_b)?)\b", rhs):
                    add("CCV-L20", line_of(src, m.start()),
                        "clock %r is read as data by %r. A clock belongs in "
                        "an edge expression, a port map, or the right-hand "
                        "side of another clock -- nowhere else"
                        % (cm.group(1), lhs))

        # -- CCV-L21: stage tags are well formed and consistent -------------
        for kind, clk, body, ln in (() if reusable else always_blocks(src)):
            if kind != "ff" or not clk:
                continue
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
                        "%s carries block letter %r but this file declares "
                        "`// Block: %s` (letter %r). A block may only generate "
                        "signals in its own numbering space"
                        % (lhs, b, blk_name, blk_letter))

        # -- CCV-L23: stage arithmetic --------------------------------------
        # The rule the whole convention exists to make checkable:
        #   flop output  = max(input stages) + 1
        #   combinational = max(input stages)
        #
        # Exempt: the net's own previous value (a hold or a counter is a
        # self-reference at the SAME stage, not a stage violation), reset nets
        # (block letter `r` -- the reset tree has its own numbering because it
        # is pipelined by physical distance, not by datapath depth), and any
        # right-hand side with no tagged signals at all.
        def rhs_stages(expr, lhs):
            out = []
            for w in re.findall(r"[a-z]\w*", expr):
                if w == lhs:
                    continue
                st = stage_of(w)
                if st and st[1] != "r":
                    out.append(st[2])
            return out

        for kind, clk, body, ln in (() if reusable else always_blocks(src)):
            seq = (kind == "ff")
            for am in re.finditer(
                    r"([a-z]\w*)\s*(?:\[[^\]]*\])?\s*(<=|=)\s*([^;]+);", body):
                lhs, op, rhs = am.group(1), am.group(2), am.group(3)
                st = stage_of(lhs)
                if st is None or st[1] == "r":
                    continue
                ins = rhs_stages(rhs, lhs)
                if not ins:
                    continue
                want = max(ins) + (1 if seq else 0)
                if st[2] != want:
                    aln = ln + body[:am.start()].count("\n")
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
        for kind, clk, body, ln in (() if reusable else always_blocks(src)):
            if kind != "ff":
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

        # -- CCV-L24: `_b` is a derived complement --------------------------
        # `_n` is a semantic property of a signal that is DEFINED active-low
        # and carries no obligation. `_b` claims to be the complement of a net
        # that exists, which is checkable and worth checking: a `_b` that is
        # not actually inverted is a sign flip nobody sees.
        for m in re.finditer(r"\b([a-z]\w*)_b\b\s*(?:<=|=)([^;]+);", src):
            sib = m.group(1)
            rhs = m.group(2)
            ln = line_of(src, m.start())
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
        path = os.path.join(ROOT, "rtl", "if", "%s_if_checker.sv" % base)
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
            dirnames[:] = [d for d in dirnames
                           if d not in ("generated", "__pycache__", "lint")]
            for fn in sorted(filenames):
                if fn.endswith((".sv", ".svh", ".v", ".vh")):
                    full = os.path.join(dirpath, fn)
                    yield full, os.path.relpath(full, ROOT)


def main():
    args = [a for a in sys.argv[1:] if not a.startswith("-")]
    quiet = "-q" in sys.argv
    # Lets tools/check-1d.sh point CCV-L12 at a fixture schema, since a
    # cross-file rule cannot be counter-exampled by a .sv file alone.
    schema = None
    for a in sys.argv[1:]:
        if a.startswith("--schema="):
            schema = a.split("=", 1)[1]
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
    for f in sorted(findings, key=lambda f: (f.path, f.line)):
        print(f)
    if not quiet:
        print("  lint: %d file(s), %d finding(s)" % (n, len(findings)))
    return 1 if findings else 0


if __name__ == "__main__":
    sys.exit(main())
