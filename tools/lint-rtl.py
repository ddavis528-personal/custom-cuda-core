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

    # -- CCV-L02: clock and reset ports named clk and rst -------------------
    # §9: identically named in every module so instantiation and the swap
    # harness are mechanical. Reasonable given the single-domain,
    # global-synchronous-reset decision (§6).
    for i, l in enumerate(lines):
        m = re.search(r"\binput\s+(?:logic\s+|wire\s+)?(\w*(?:clock|clk)\w*)\b",
                      l, re.I)
        if m and m.group(1) != "clk":
            add("CCV-L02", i + 1,
                "clock port named %r; every module uses `clk`" % m.group(1))
        m = re.search(r"\binput\s+(?:logic\s+|wire\s+)?"
                      r"(\w*(?:reset|rst)\w*)\b", l, re.I)
        if m and m.group(1) != "rst":
            add("CCV-L02", i + 1,
                "reset port named %r; every module uses `rst` (active high, "
                "synchronous -- §6)" % m.group(1))

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

    # -- CCV-L07: every case statement has a default ------------------------
    # §6's first listed rule: an unreachable state assigns X rather than
    # holding, so the bug is loud instead of silently squashed.
    for i, l in enumerate(lines):
        m = re.match(r"\s*(unique\s+|priority\s+)?(case[zx]?)\s*\(", l)
        if not m:
            continue
        j, found_default, endline = i + 1, False, None
        while j < len(lines):
            if re.match(r"\s*endcase\b", lines[j]):
                endline = j
                break
            if re.match(r"\s*default\s*:", lines[j]):
                found_default = True
            j += 1
        if not found_default:
            add("CCV-L07", i + 1,
                "case without a default; §6 requires an explicit "
                "`default: <= 'x` so an unreachable state is loud rather than "
                "an implicit hold")

    # -- CCV-L08: X on control must be asserted against ---------------------
    # §6's central rule, and the one no stock lint rule expresses: it is a
    # relationship between a case selector and an assertion elsewhere in the
    # file, not a property of either alone.
    if not is_tb and not is_header:
        known = set(re.findall(r"CCV_ASSERT_KNOWN\w*\s*\(\s*\w+\s*,\s*([\w.\[\]]+)",
                               raw))
        known |= set(re.findall(r"CCV_ASSUME_KNOWN\s*\(\s*\w+\s*,\s*([\w.\[\]]+)",
                                raw))
        known = {k.split("[")[0] for k in known}
        for i, l in enumerate(lines):
            m = re.match(r"\s*(?:unique\s+|priority\s+)?case[zx]?\s*\(\s*"
                         r"([A-Za-z_]\w*)\s*\)", l)
            if m and m.group(1) not in known:
                add("CCV-L08", i + 1,
                    "case selector %r has no CCV_ASSERT_KNOWN/CCV_ASSUME_KNOWN; "
                    "§6 prohibits X on control rather than propagating it, "
                    "because `if (x)` silently takes the false branch in every "
                    "4-state simulator" % m.group(1))

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
