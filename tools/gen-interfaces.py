#!/usr/bin/env python3
"""Generate SystemVerilog typedefs and matching C++ accessors from
schema/interfaces.json.

Interface checker convention §2 chooses packed structs over SystemVerilog
`interface` constructs, and Stage 1a confirmed the choice works: a struct port
surfaces in the C++ model as one packed signal (F-12). What it does NOT do is
expose the field offsets, so the C++ side of a block swap has to know the
layout independently -- and a field reordered on one side only gives a harness
reading the wrong bits, which looks like a functional bug rather than a
mismatch.

So both sides come from here. This is the same argument §9 of the strategy doc
makes for parameters, applied to the one boundary §1's swap mechanism runs
across.

Packed-struct bit order: the FIRST field declared occupies the MOST significant
bits. The offsets below are computed from that rule, which is worth stating
because getting it backwards produces a C++ view that is wrong in a way that
still decodes to plausible values.
"""
import json
import os
import sys

ROOT = os.path.dirname(os.path.dirname(os.path.abspath(__file__)))
SRC = os.path.join(ROOT, "schema", "interfaces.json")

BANNER = """// GENERATED FILE -- DO NOT EDIT.
//
// Produced by tools/gen-interfaces.py from schema/interfaces.json.
// Edit the source and regenerate; tools/verify.sh fails if this file is stale.
"""


def layout(iface):
    """Field offsets, MSB-first, as a packed struct lays them out."""
    total = sum(f["bits"] for f in iface["fields"])
    out, msb = [], total - 1
    for f in iface["fields"]:
        lsb = msb - f["bits"] + 1
        out.append((f, msb, lsb))
        msb = lsb - 1
    return total, out


def camel(name):
    base = name[:-2] if name.endswith("_t") else name
    return "".join(p.capitalize() for p in base.split("_"))


def gen_sv(d):
    L = [BANNER, "`ifndef CCV_INTERFACES_SVH", "`define CCV_INTERFACES_SVH", "",
         "// A generated header is a CATALOGUE: it declares every interface's width and\n// layout, and no single consumer uses all of them. That is the intended\n// shape, not an oversight, so the unused-parameter warning is turned off for\n// this file only -- narrowly, and here rather than at the call site, so a\n// genuinely unused parameter in hand-written RTL still gets caught.\n/* verilator lint_off UNUSEDPARAM */"]
    for i in d["interfaces"]:
        total, fields = layout(i)
        L.append("// %s" % i["doc"])
        L.append("// direction: %s, backpressure: %s, width: %d bits"
                 % (i["direction"], i["backpressure"], total))
        if i.get("provisional"):
            L.append("// PROVISIONAL -- the interface list is Stage 2's, and "
                     "follows from the partition.")
        L.append("typedef struct packed {")
        for f, msb, lsb in fields:
            w = "logic" if f["bits"] == 1 else "logic [%d:0]" % (f["bits"] - 1)
            L.append("  %-16s %-10s // [%d:%d]%s -- %s"
                     % (w, f["name"] + ";", msb, lsb,
                        " CONTROL" if f["control"] else "", f["doc"]))
        L.append("} %s;" % i["name"])
        L.append("")
        L.append("localparam int %s_W = %d;" % (i["name"].upper()[:-2], total))
        L.append("")
    L.append("/* verilator lint_on UNUSEDPARAM */")
    L.append("")
    L.append("`endif // CCV_INTERFACES_SVH")
    return "\n".join(L) + "\n"


def gen_cpp(d):
    L = [BANNER, "#ifndef CCV_INTERFACES_H", "#define CCV_INTERFACES_H", "",
         "#include <cstdint>", "", "namespace ccv {", ""]
    L.append("/// Field accessors for the packed-struct interfaces the RTL")
    L.append("/// carries. A Verilated struct port arrives as one packed")
    L.append("/// integer with no field information (finding F-12); these")
    L.append("/// decompose it, from the same source the typedef came from.")
    L.append("")
    for i in d["interfaces"]:
        total, fields = layout(i)
        cn = camel(i["name"])
        L.append("/// %s" % i["doc"])
        L.append("/// direction: %s, backpressure: %s"
                 % (i["direction"], i["backpressure"]))
        L.append("struct %s {" % cn)
        L.append("  static constexpr unsigned kWidth = %d;" % total)
        for f, msb, lsb in fields:
            L.append("  /// [%d:%d]%s %s" % (msb, lsb,
                                             " CONTROL" if f["control"] else "",
                                             f["doc"]))
            L.append("  static constexpr unsigned k%sLsb = %d;"
                     % (camel(f["name"]), lsb))
            L.append("  static constexpr unsigned k%sBits = %d;"
                     % (camel(f["name"]), f["bits"]))
        L.append("")
        for f, msb, lsb in fields:
            cf = camel(f["name"])
            mask = (1 << f["bits"]) - 1
            L.append("  static uint32_t %s(uint64_t raw) {" % f["name"])
            L.append("    return static_cast<uint32_t>((raw >> k%sLsb) & 0x%xull);"
                     % (cf, mask))
            L.append("  }")
        L.append("};")
        L.append("")
    L.append("} // namespace ccv")
    L.append("#endif // CCV_INTERFACES_H")
    return "\n".join(L) + "\n"


def main():
    check = "--check" in sys.argv
    with open(SRC) as f:
        d = json.load(f)

    names = [i["name"] for i in d["interfaces"]]
    if len(set(names)) != len(names):
        sys.stderr.write("duplicate interface names\n")
        return 1
    for i in d["interfaces"]:
        if not i["name"].endswith("_t"):
            sys.stderr.write("%s: interface typedefs end in _t\n" % i["name"])
            return 1
        if not i["fields"]:
            sys.stderr.write("%s: no fields\n" % i["name"])
            return 1
        # A struct wider than 64 bits stops being one VL_OUT64 and becomes a
        # word array in the generated C++, which the accessors here do not
        # model. Catching it at generation is much cheaper than at the first
        # swap.
        total = sum(f["bits"] for f in i["fields"])
        if total > 64:
            sys.stderr.write(
                "%s: %d bits. Above 64 the Verilated port becomes a word "
                "array rather than a single integer, and these accessors "
                "assume one integer. Split the interface or widen the "
                "generator first.\n" % (i["name"], total))
            return 1
        fn = [f["name"] for f in i["fields"]]
        if len(set(fn)) != len(fn):
            sys.stderr.write("%s: duplicate field names\n" % i["name"])
            return 1

    targets = [
        (os.path.join(ROOT, "rtl", "generated", "ccv_interfaces.svh"), gen_sv(d)),
        (os.path.join(ROOT, "sim", "generated", "ccv_interfaces.h"), gen_cpp(d)),
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
            sys.stderr.write("generated interface files are stale: %s\n"
                             "  run tools/gen-interfaces.py\n" % ", ".join(stale))
            return 1
        print("  interface typedefs up to date (%d interface(s))"
              % len(d["interfaces"]))
        return 0
    print("  generated interface typedefs from schema/interfaces.json "
          "(%d interface(s))" % len(d["interfaces"]))
    return 0


if __name__ == "__main__":
    sys.exit(main())
