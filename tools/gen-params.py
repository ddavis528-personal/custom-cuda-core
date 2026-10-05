#!/usr/bin/env python3
"""Generate matching C++ and SystemVerilog parameter definitions from
params/ccv_params.json.

§9's Stage 1d mechanism decision, verbatim: "ROB depth exists as a swept knob
in the model (Stage 4b) AND as an RTL parameter. Nothing currently prevents
them from drifting, and drift would mean a correlation run silently comparing
two differently-sized machines -- a failure that looks like a timing bug.
Generate both from one shared definition rather than maintaining two."

Run with --check to fail when the generated files are stale, which is how
tools/verify.sh keeps the two from drifting between edits.

--settle rewrites derived values from their inputs and saves the source: for
the scratch tree tools/check-links.sh builds with another links.json, never for
the design's own file.
"""
import json
import os
import sys

ROOT = os.path.dirname(os.path.dirname(os.path.abspath(__file__)))
SRC = os.path.join(ROOT, "params", "ccv_params.json")

BANNER = """// GENERATED FILE -- DO NOT EDIT.
//
// Produced by tools/gen-params.py from params/ccv_params.json.
// Edit the source and regenerate; tools/verify.sh fails if this file is stale.
"""

# A parameter's status travels with it into both languages. A sweep that
# varies an `isa` parameter is varying something the compiler already depends
# on, and the generated comment is where that gets noticed.
STATUS_NOTE = {
    "isa": "settled by the ISA -- not a knob",
    "isa_provisional": "ISA-level, still provisional",
    "arch": "decided at the block-level grill-me",
    "tunable": "provisional -- expected to move once the timing model runs",
    "provisional": "PLACEHOLDER -- sized at Stage 4a, swept at 4b",
    "preliminary": "PRELIMINARY -- the ENCODING is undecided, not just the size",
    "target": "physical target, not a structure size",
}


def gen_cpp(d):
    L = [BANNER, "#ifndef CCV_PARAMS_H", "#define CCV_PARAMS_H", "",
         "#include <cstdint>", "", "namespace ccv {", "",
         "/// Values that follow from decisions already made.", ""]
    for p in d["params"]:
        if tier(p) != "settled":
            continue
        L.append("/// %s" % p["doc"])
        note = STATUS_NOTE.get(p["status"], p["status"])
        if p.get("source"):
            L.append("/// %s (%s)" % (note, p["source"]))
        elif p.get("decided_at"):
            L.append("/// %s" % note)
        else:
            L.append("/// %s" % note)
        L.append("static constexpr uint32_t k%s = %d;"
                 % (camel(p["name"]), p["value"]))
        L.append("")
    L.append("/// PLACEHOLDERS awaiting a per-block session. Code referencing")
    L.append("/// ccv::prov is KNOWN UNFINISHED; the nested namespace is what")
    L.append("/// keeps that visible at the use site.")
    L.append("namespace prov {")
    L.append("")
    for p in d["params"]:
        if tier(p) != "prov":
            continue
        L.append("/// %s" % p["doc"])
        L.append("/// PROVISIONAL -- decided by: %s"
                 % p.get("decided_at", "unstated"))
        L.append("static constexpr uint32_t k%s = %d;"
                 % (camel(p["name"].replace("CCV_P_", "")), p["value"]))
        L.append("")
    L.append("} // namespace prov")
    L.append("")
    L.append("/// PRELIMINARY -- the field's ENCODING is undecided, not merely")
    L.append("/// its size. Code referencing ccv::prelim that pattern-matches on")
    L.append("/// a value, rather than just carrying it, is code that will be")
    L.append("/// rewritten. The churn rating on each says how much.")
    L.append("namespace prelim {")
    L.append("")
    for p in d["params"]:
        if tier(p) != "prelim":
            continue
        L.append("/// %s" % p["doc"])
        L.append("/// PRELIMINARY -- churn: %s" % p.get("churn", "unrated").upper())
        L.append("static constexpr uint32_t k%s = %d;"
                 % (camel(p["name"].replace("CCV_L_", "")), p["value"]))
        L.append("")
    L.append("} // namespace prelim")
    L.append("")
    L.append("} // namespace ccv")
    L.append("#endif // CCV_PARAMS_H")
    return "\n".join(L) + "\n"


def camel(name):
    """CCV_ROB_ENTRIES -> RobEntries.

    §9 requires naming to be mechanically consistent across the two languages.
    Mechanically consistent is not the same as identical: each language keeps
    its own idiom, and the MAPPING is what has to be total and reversible. It
    is applied here rather than left to whoever writes the next block.
    """
    parts = name.split("_")
    if parts and parts[0] == "CCV":
        parts = parts[1:]
    return "".join(p.capitalize() for p in parts)


# Which package a parameter lands in. THREE tiers, and the package name is
# visible at every use site -- that is the whole mechanism. A reader of any
# struct definition can tell how much trust the number deserves without
# looking anything up.
#
#   ccv_params_pkg   follows from a settled decision      does not move
#   ccv_prov_pkg     a sizing placeholder                 the NUMBER moves
#   ccv_prelim_pkg   no decided ENCODING at all           the FIELD may move
#
# The third tier is what lets skeleton coding proceed without pretending the
# encodings are known. A preliminary width says the field is real and roughly
# this big; it says nothing about the encoding, the field count or the
# semantics. Conflating it with `provisional` would lose exactly that
# distinction -- "we will pick a number" versus "we do not yet know what this
# field IS".
PROV = {"provisional", "tunable"}
PRELIM = {"preliminary"}


def tier(p):
    if p["status"] in PRELIM:
        return "prelim"
    if p["status"] in PROV:
        return "prov"
    return "settled"


def gen_sv(d):
    L = [BANNER, "`ifndef CCV_PARAMS_PKG_SV", "`define CCV_PARAMS_PKG_SV", ""]
    L.append("// A parameter package is a CATALOGUE: it declares every machine")
    L.append("// parameter, and no single module uses all of them. That is the")
    L.append("// intended shape, not an oversight, so the unused-parameter")
    L.append("// warning is turned off for this file only -- narrowly, and here")
    L.append("// rather than at the instantiation site, so a genuinely unused")
    L.append("// parameter on a hand-written module still gets caught.")
    L.append("/* verilator lint_off UNUSEDPARAM */")
    L.append("")
    L.append("// Values that follow from decisions already made. Nothing here")
    L.append("// is expected to move.")
    L.append("package ccv_params_pkg;")
    L.append("")
    for p in d["params"]:
        if tier(p) != "settled":
            continue
        L.append("  // %s" % p["doc"])
        note = STATUS_NOTE.get(p["status"], p["status"])
        L.append("  // %s%s" % (note,
                                (" (%s)" % p["source"]) if p.get("source") else ""))
        L.append("  localparam int %s = %d;" % (p["name"], p["value"]))
        L.append("")
    L.append("endpackage")
    L.append("")
    L.append("// PLACEHOLDERS awaiting a per-block session. A module that")
    L.append("// references this package is KNOWN UNFINISHED -- that is the")
    L.append("// whole reason it is a separate package rather than a comment.")
    L.append("// Everything here is expected to move, and a change should be a")
    L.append("// one-line edit propagating through the generated typedefs, the")
    L.append("// checkers and the C++ model together.")
    L.append("package ccv_prov_pkg;")
    L.append("")
    for p in d["params"]:
        if tier(p) != "prov":
            continue
        L.append("  // %s" % p["doc"])
        L.append("  // PROVISIONAL -- decided by: %s"
                 % p.get("decided_at", "unstated"))
        L.append("  localparam int %s = %d;" % (p["name"], p["value"]))
        L.append("")
    L.append("endpackage")
    L.append("")
    L.append("// PRELIMINARY -- a width good enough to WIRE, for a field whose")
    L.append("// encoding is not decided at all. Referencing this package says")
    L.append("// more than that a number will move: the field's SHAPE may move,")
    L.append("// so code that pattern-matches on its contents is code that will")
    L.append("// be rewritten. The churn rating on each says how much.")
    L.append("//")
    L.append("// This tier exists so the skeleton can be wired end to end")
    L.append("// without anyone having to pretend the encodings are known.")
    L.append("package ccv_prelim_pkg;")
    L.append("")
    for p in d["params"]:
        if tier(p) != "prelim":
            continue
        L.append("  // %s" % p["doc"])
        L.append("  // PRELIMINARY -- churn: %s%s"
                 % (p.get("churn", "unrated").upper(),
                    "  (the FIELD may change shape, not just this number)"
                    if p.get("churn") == "high" else ""))
        L.append("  localparam int %s = %d;" % (p["name"], p["value"]))
        L.append("")
    L.append("endpackage")
    L.append("")
    L.append("/* verilator lint_on UNUSEDPARAM */")
    L.append("`endif // CCV_PARAMS_PKG_SV")
    return "\n".join(L) + "\n"


# A parameter that follows from others says so: `derive` is the expression it
# must equal, `require` a condition it must meet. The value stays written out,
# because every tool reads `value`; what this adds is that a value which no
# longer follows from its inputs is refused here, by name and with the number
# it should be, instead of shipping. Grammar: parameter names, integers,
# + - * // **, comparisons, cdiv(a, b), clog2(x), max(a, b), and
# link_n('channel'): the repeater stages params/links.json puts on that
# channel (without ccv_), the most over its copies, so a latency built on the
# links follows them. link_n is the STAGES only: a whole crossing is
# CCV_LAT_HOP + link_n(...), and a latency over paths with different numbers
# of crossings (a max) has to say so, since no base can absorb the difference.
# A derived parameter is never more settled than its inputs: a settled width
# that follows a provisional count would move without its tier saying so.
FUNCS = {"cdiv": lambda a, b: -(-a // b),
         "clog2": lambda x: max(0, (x - 1).bit_length()),
         "max": lambda a, b: max(a, b)}
TIER_RANK = {"settled": 0, "prov": 1, "prelim": 2}


def link_stages(path=None):
    """Channel (without ccv_) -> most repeater stages on any copy, read
    straight from params/links.json. Validity is tools/ccv_links.py's job,
    run by every generator that builds the machine; this only sums routes."""
    import re
    sys.path.insert(0, os.path.join(ROOT, "tools"))
    import ccv_links
    with open(path or ccv_links.path()) as f:
        entries = json.load(f).get("links", [])
    out = {}
    for e in entries:
        n = sum(int(m.group(2)) for m in
                (ccv_links.HOP.match(h) for h in e.get("route", "").split(">"))
                if m)
        out[e.get("channel")] = max(out.get(e.get("channel"), 0), n)
    return out


def schema_channels():
    with open(os.path.join(ROOT, "schema", "interfaces.json")) as f:
        return {c["name"][4:] for c in json.load(f)["channels"]}


def names_in(expr):
    import ast
    return {n.id for n in ast.walk(ast.parse(expr, mode="eval"))
            if isinstance(n, ast.Name) and n.id not in FUNCS}


def evaluate(expr, values, links=None):
    import ast
    ops = {ast.Add: lambda a, b: a + b, ast.Sub: lambda a, b: a - b,
           ast.Mult: lambda a, b: a * b, ast.FloorDiv: lambda a, b: a // b,
           ast.Pow: lambda a, b: a ** b}
    cmps = {ast.Gt: lambda a, b: a > b, ast.GtE: lambda a, b: a >= b,
            ast.Lt: lambda a, b: a < b, ast.LtE: lambda a, b: a <= b,
            ast.Eq: lambda a, b: a == b}

    def ev(n):
        if isinstance(n, ast.Expression):
            return ev(n.body)
        if isinstance(n, ast.Constant) and isinstance(n.value, int):
            return n.value
        if (isinstance(n, ast.Call) and isinstance(n.func, ast.Name)
                and n.func.id == "link_n" and len(n.args) == 1
                and isinstance(n.args[0], ast.Constant)
                and isinstance(n.args[0].value, str)):
            if n.args[0].value not in schema_channels():
                raise ValueError("link_n names no channel: %r (names are "
                                 "without ccv_)" % n.args[0].value)
            return (links if links is not None else {}).get(n.args[0].value, 0)
        if isinstance(n, ast.Name):
            if n.id not in values:
                raise ValueError("unknown parameter %s" % n.id)
            return values[n.id]
        if isinstance(n, ast.BinOp) and type(n.op) in ops:
            return ops[type(n.op)](ev(n.left), ev(n.right))
        if (isinstance(n, ast.Compare) and len(n.ops) == 1
                and type(n.ops[0]) in cmps):
            return cmps[type(n.ops[0])](ev(n.left), ev(n.comparators[0]))
        if (isinstance(n, ast.Call) and isinstance(n.func, ast.Name)
                and n.func.id in FUNCS and not n.keywords):
            return FUNCS[n.func.id](*[ev(a) for a in n.args])
        raise ValueError("not allowed in a derivation: %s" % ast.dump(n))
    return ev(ast.parse(expr, mode="eval"))


def check_derived(d, links=None):
    """Every `derive` equals its value and every `require` holds, and no
    derived parameter is more settled than what it derives from."""
    values = {p["name"]: p["value"] for p in d["params"]}
    tiers = {p["name"]: tier(p) for p in d["params"]}
    if links is None:
        links = link_stages()
    bad = []
    for p in d["params"]:
        try:
            if "derive" in p:
                looser = [x for x in sorted(names_in(p["derive"]))
                          if TIER_RANK[tiers.get(x, "settled")] > TIER_RANK[tiers[p["name"]]]]
                if looser:
                    bad.append("%s is %s but derives from %s: a derived value is "
                               "never more settled than its inputs"
                               % (p["name"], tiers[p["name"]],
                                  ", ".join("%s (%s)" % (x, tiers[x]) for x in looser)))
                want = evaluate(p["derive"], values, links)
                if want != p["value"]:
                    bad.append("%s = %d, but %s gives %d: set it to %d"
                               % (p["name"], p["value"], p["derive"], want, want))
            if "require" in p and not evaluate(p["require"], values, links):
                bad.append("%s = %d breaks its requirement %s"
                           % (p["name"], p["value"], p["require"]))
        except (ValueError, SyntaxError, TypeError) as e:
            bad.append("%s: %s" % (p["name"], e))
    return bad


def selftest(d):
    """The negative control: each derivation and requirement must refuse a
    value that no longer follows from its inputs. Run in memory, on copies."""
    import copy
    links = link_stages()
    cases = [("CCV_PREDS", "value", 8, "CCV_W_PRED_STATE"),
             ("CCV_W_PRED_STATE", "value", 2048, "CCV_MIGRATION_CYCLES"),
             ("CCV_MIGRATION_CYCLES", "value", 33, "CCV_W_MIG_ROW"),
             ("CCV_PARKED_WARPS", "value", 60, "CCV_WARP_CONTEXTS"),
             ("CCV_P_PRED_REGS", "value", 16, "CCV_P_PRED_REGS"),
             ("CCV_P_PHYS_REGS", "value", 64, "CCV_P_PHYS_REGS"),
             ("CCV_P_PHYS_REGS", "value", 256, "CCV_P_REN_FLOOR"),
             ("CCV_P_REN_SLACK", "value", 0, "CCV_P_REN_CEIL"),
             ("CCV_P_PRED_REN_SLACK", "value", 30, "CCV_P_PRED_REN_CEIL"),
             ("CCV_P_ROB_DEPTH", "value", 64, "CCV_P_W_ROB_IDX"),
             ("CCV_P_BR_CKPTS", "value", 8, "CCV_P_W_CKPT_ID"),
             ("CCV_P_W_CKPT_ID", "status", "arch", "CCV_P_W_CKPT_ID"),
             ("link_n('rcu_lane_ops')", "links", 2, "CCV_LAT_LANE"),
             ("link_n('dcu_miu_rsp')", "links", 1, "CCV_LAT_L1_HIT"),
             ("link_n('rcu_miu_addr')", "links", 1, "CCV_LAT_L1_WAKE"),
             ("link_n('ooe_miu_memop')", "links", 9, "CCV_LAT_L1_WAKE"),
             ("link_n('miu_ooe_cmpl')", "links", 1, "CCV_LAT_L1_CMPL"),
             ("CCV_LAT_RCU_ADDR_BASE", "value", 5, "CCV_LAT_RCU_ADDR"),
             ("CCV_RT_ABUT", "value", 4, "CCV_LAT_HOP"),
             ("CCV_P_PHYS_ZERO", "value", 191, "CCV_P_PHYS_ZERO"),
             ("CCV_P_PRED_REGS", "value", 64, "CCV_P_W_PHYS_PRED"),
             # A-70: an epoch that can wrap within one flight is refused,
             # and more checkpoints widen it.
             ("CCV_P_W_FETCH_EPOCH", "value", 2, "CCV_P_W_FETCH_EPOCH"),
             ("CCV_P_BR_CKPTS", "value", 7, "CCV_P_W_FETCH_EPOCH"),
             ("CCV_LAT_LANE", "derive",
              "CCV_LAT_LANE_BASE + link_n('rcu_lane_opz')", "CCV_LAT_LANE")]
    missed = []
    for name, key, v, who in cases:
        m, lk = copy.deepcopy(d), dict(links)
        if key == "links":
            lk[name[len("link_n('"):-2]] = v
        for p in m["params"]:
            if p["name"] == name:
                p[key] = v
        if not any(b.split()[0].rstrip(":") == who for b in check_derived(m, lk)):
            missed.append("%s %s = %s not caught at %s" % (name, key, v, who))
    if missed:
        sys.stderr.write("".join("%s\n" % x for x in missed))
        return 1
    print("  derived parameters: %d mutation(s), each refused by name"
          % len(cases))
    return 0


def settle(d):
    """Rewrite every derived value from its inputs, to a fixed point, and save
    the source. Only for a scratch copy of the tree that runs a different
    params/links.json (tools/check-links.sh): the design's own file is never
    settled by a tool, so a floorplan change reaches it as a reviewed diff."""
    links = link_stages()
    for _ in range(len(d["params"])):
        values = {p["name"]: p["value"] for p in d["params"]}
        changed = []
        for p in d["params"]:
            if "derive" in p:
                want = evaluate(p["derive"], values, links)
                if want != p["value"]:
                    changed.append("%s %d -> %d" % (p["name"], p["value"], want))
                    p["value"] = values[p["name"]] = want
        if not changed:
            break
        for c in changed:
            print("  settled %s" % c)
    with open(SRC, "w") as f:
        json.dump(d, f, indent=2)
        f.write("\n")
    return 0


def main():
    check = "--check" in sys.argv
    with open(SRC) as f:
        d = json.load(f)
    if "--selftest" in sys.argv:
        return selftest(d)
    if "--settle" in sys.argv:
        return settle(d)

    names = [p["name"] for p in d["params"]]
    if len(set(names)) != len(names):
        sys.stderr.write("duplicate parameter names\n")
        return 1
    for p in d["params"]:
        if not p["name"].startswith("CCV_"):
            sys.stderr.write("%s: parameter names must start with CCV_\n"
                             % p["name"])
            return 1
        if p["status"] not in STATUS_NOTE:
            sys.stderr.write("%s: unknown status %r\n" % (p["name"], p["status"]))
            return 1
        if p["status"] in ("provisional", "tunable") and not p.get("decided_at"):
            sys.stderr.write("%s: provisional parameters must say which stage "
                             "decides them\n" % p["name"])
            return 1
        # The churn rating is what a skeleton author reads to decide whether
        # it is safe to pattern-match on a field or only to carry it. An
        # unrated preliminary parameter is the one that gets treated as
        # settled, so it is rejected rather than defaulted.
        if p["status"] == "preliminary":
            if p.get("churn") not in ("low", "med", "high"):
                sys.stderr.write("%s: preliminary parameters need churn "
                                 "low|med|high\n" % p["name"])
                return 1
            if not p.get("decided_at"):
                sys.stderr.write("%s: preliminary parameters must say who "
                                 "decides the encoding\n" % p["name"])
                return 1

    bad = check_derived(d)
    if bad:
        sys.stderr.write("".join("%s\n" % b for b in bad))
        return 1
    for p in d["params"]:  # the relation travels into both languages
        for k, what in (("derive", "Derived: = "), ("require", "Requires: ")):
            if k in p:
                p["doc"] = "%s  %s%s." % (p["doc"], what, p[k])

    targets = [
        (os.path.join(ROOT, "sim", "generated", "ccv_params.h"), gen_cpp(d)),
        (os.path.join(ROOT, "rtl", "generated", "ccv_params_pkg.sv"), gen_sv(d)),
    ]
    stale = []
    for path, text in targets:
        os.makedirs(os.path.dirname(path), exist_ok=True)
        cur = open(path).read() if os.path.exists(path) else None
        if cur != text:
            stale.append(os.path.relpath(path, ROOT))
            if not check:
                with open(path, "w") as f:
                    f.write(text)
    if check:
        if stale:
            sys.stderr.write("generated parameter files are stale: %s\n"
                             "  run tools/gen-params.py\n" % ", ".join(stale))
            return 1
        print("  parameter definitions up to date (%d parameters)"
              % len(d["params"]))
        return 0
    print("  generated parameter definitions from params/ccv_params.json "
          "(%d parameters)" % len(d["params"]))
    return 0


if __name__ == "__main__":
    sys.exit(main())
