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


def main():
    check = "--check" in sys.argv
    with open(SRC) as f:
        d = json.load(f)

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
