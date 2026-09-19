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
    "provisional": "PLACEHOLDER -- sized at Stage 4a, swept at 4b",
    "target": "physical target, not a structure size",
}


def gen_cpp(d):
    L = [BANNER, "#ifndef CCV_PARAMS_H", "#define CCV_PARAMS_H", "",
         "#include <cstdint>", "", "namespace ccv {", ""]
    for p in d["params"]:
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


def gen_sv(d):
    L = [BANNER, "`ifndef CCV_PARAMS_PKG_SV", "`define CCV_PARAMS_PKG_SV", "",
         "package ccv_params_pkg;", ""]
    for p in d["params"]:
        L.append("  // %s" % p["doc"])
        note = STATUS_NOTE.get(p["status"], p["status"])
        L.append("  // %s%s" % (note,
                                (" (%s)" % p["source"]) if p.get("source") else ""))
        L.append("  localparam int %s = %d;" % (p["name"], p["value"]))
        L.append("")
    L.append("endpackage")
    L.append("")
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
        if p["status"] == "provisional" and not p.get("decided_at"):
            sys.stderr.write("%s: provisional parameters must say which stage "
                             "decides them\n" % p["name"])
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
