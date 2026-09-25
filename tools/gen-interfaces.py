#!/usr/bin/env python3
"""Generate the channel topology into SystemVerilog and C++ from
schema/interfaces.json.

Every channel is one port on each of two blocks, so the channel list IS the
design's connectivity. The per-block port lists below are DERIVED from it
rather than maintained separately -- the source spec kept both and they
disagreed on 7 of 14 blocks, which is the failure this removes.

What is generated: the channel enum, the per-block port index, and the
common-port list. What is NOT: payload structs, because field widths mostly
firm up in the per-block session that owns the interface. Inventing them here
would put a number in a generated typedef that nobody decided, and generated
numbers are believed.
"""
import json
import os
import re
import sys

ROOT = os.path.dirname(os.path.dirname(os.path.abspath(__file__)))
SRC = os.path.join(ROOT, "schema", "interfaces.json")
BLOCKS = os.path.join(ROOT, "params", "blocks.json")
PARAMS = os.path.join(ROOT, "params", "ccv_params.json")

BANNER = """// GENERATED FILE -- DO NOT EDIT.
//
// Produced by tools/gen-interfaces.py from schema/interfaces.json.
// Edit the source and regenerate; tools/verify.sh fails if this file is stale.
"""


def block_names():
    with open(BLOCKS) as f:
        d = json.load(f)
    return {b["name"]: b for b in d["blocks"] if b.get("instances", 0) > 0}


def ports_per_block(d, blocks):
    """Derived, never stated. src and dst each gain one port per channel."""
    out = {b: {"in": [], "out": []} for b in blocks}
    for c in d["channels"]:
        if c["src"] in out:
            out[c["src"]]["out"].append(c["name"])
        if c["dst"] in out:
            out[c["dst"]]["in"].append(c["name"])
        elif c["dst"] == "EXTERNAL" and c["src"] in out:
            pass          # already counted as an out on the bridge
    return out


def sized(d, c):
    """Fields with a decided width, or None if any is missing."""
    fw = d.get("field_widths", {})
    miss = [f for f in c["payload_fields"] if f not in fw]
    return None if miss else [(f, fw[f]) for f in c["payload_fields"]]


def unresolved(d):
    """Every field still without a width, and which channels want it. This is
    the ask to the per-block sessions, kept as a list rather than guessed."""
    fw = d.get("field_widths", {})
    out = {}
    for c in d["channels"]:
        for f in c["payload_fields"]:
            if f not in fw:
                out.setdefault(f, []).append(c["name"])
    return out


# SystemVerilog reserved words that are plausible as a payload field name. A
# struct member called `class` or `type` elaborates nowhere, and the error
# points at the generated file rather than at the schema that caused it --
# which is a bad half hour for whoever hits it. Checked at generation instead.
SV_RESERVED = {
    "class", "type", "input", "output", "inout", "ref", "const", "static",
    "automatic", "signed", "unsigned", "byte", "shortint", "int", "longint",
    "integer", "time", "real", "logic", "bit", "reg", "wire", "wor", "wand",
    "event", "string", "chandle", "void", "null", "this", "super", "extends",
    "virtual", "pure", "local", "protected", "package", "import", "export",
    "interface", "modport", "program", "property", "sequence", "assert",
    "assume", "cover", "expect", "bind", "alias", "before", "randomize",
    "rand", "randc", "constraint", "solve", "dist", "inside", "with", "new",
    "extern", "context", "forkjoin", "priority", "unique", "unique0", "tagged",
    "union", "struct", "enum", "typedef", "parameter", "localparam", "genvar",
    "generate", "endgenerate", "begin", "end", "if", "else", "case", "casex",
    "casez", "default", "for", "while", "do", "repeat", "forever", "break",
    "continue", "return", "function", "task", "always", "initial", "final",
    "assign", "force", "release", "disable", "wait", "fork", "join", "posedge",
    "negedge", "edge", "or", "and", "not", "nand", "nor", "xor", "xnor", "buf",
    "cell", "config", "design", "instance", "liblist", "library", "use",
    "specify", "specparam", "table", "primitive", "defparam", "macromodule",
    "module", "endmodule", "cross", "coverpoint", "bins", "ignore_bins",
    "illegal_bins", "matches", "throughout", "intersect", "within", "first_match",
    "triggered", "let", "checker", "clocking", "global", "implements",
    "interconnect", "nettype", "soft", "untyped", "restrict",
}

# Identifier-aware, so every name in a width expression is resolved against
# the real parameter list. The previous version string-replaced on the
# CCV_W_ / CCV_P_ prefixes, which silently left anything else -- CCV_SPM_BANKS,
# every preliminary CCV_L_* -- unqualified. That fails at elaboration with a
# "size must be constant" error naming the struct member, not the parameter,
# so the cause is several steps from the symptom.
_IDENT = re.compile(r"[A-Za-z_][A-Za-z0-9_]*")
_PKG_OF = {}


def load_param_packages():
    """name -> the package that declares it. Mirrors tools/gen-params.py."""
    with open(PARAMS) as f:
        pd = json.load(f)
    out = {}
    for x in pd["params"]:
        st = x["status"]
        if st == "preliminary":
            out[x["name"]] = "ccv_prelim_pkg"
        elif st in ("provisional", "tunable"):
            out[x["name"]] = "ccv_prov_pkg"
        else:
            out[x["name"]] = "ccv_params_pkg"
    return out


def qualify(expr):
    def sub(m):
        n = m.group(0)
        pkg = _PKG_OF.get(n)
        return "%s::%s" % (pkg, n) if pkg else n
    return _IDENT.sub(sub, str(expr))


def unknown_names(expr):
    return [n for n in _IDENT.findall(str(expr)) if n not in _PKG_OF]


def gen_sv(d, blocks, pp):
    L = [BANNER, "`ifndef CCV_INTERFACES_SVH", "`define CCV_INTERFACES_SVH", "",
         "// The payload structs below are sized from both parameter",
         "// packages, so this header pulls them in rather than relying on a",
         "// consumer having included them first.",
         '`include "ccv_params_pkg.sv"', "",
         "/* verilator lint_off UNUSEDPARAM */", ""]
    L.append("// Every channel carries four signals in the same shape:")
    for s in d["channel_signals"]:
        L.append("//   <name>%-9s %s" % (s["suffix"], s["doc"].split(".")[0] + "."))
    L.append("//")
    L.append("// Common ports, on every block:")
    for p in d["common_ports"]:
        L.append("//   %-16s %-4s %s" % (p["name"], p["dir"], p["doc"].split(".")[0] + "."))
    L.append("")
    L.append("localparam int CCV_NUM_CHANNELS = %d;" % len(d["channels"]))
    L.append("")
    for i, c in enumerate(d["channels"]):
        L.append("// %s -> %s, %s/cycle" % (c["src"], c["dst"], c["rate"]))
        L.append("localparam int CCV_CH_%s = %d;" % (c["name"][4:].upper(), i))
    L.append("")
    L.append("// Payload structs, for channels whose every field has a")
    L.append("// decided width. A channel missing one generates no struct --")
    L.append("// see the list at the end of this file.")
    L.append("")
    for c in d["channels"]:
        f = sized(d, c)
        if not f:
            continue
        nm = c["name"][4:]
        L.append("typedef struct packed {")
        for fld, w in f:
            ww = "logic" if w == "1" else "logic [%s-1:0]" % qualify(w)
            L.append("  %-46s %s;" % (ww, fld))
        L.append("} ccv_%s_t;" % nm)
        L.append("")
    L.append("// Ports per block, derived from the channel list.")
    for b in sorted(pp):
        n = len(pp[b]["in"]) + len(pp[b]["out"])
        L.append("localparam int CCV_PORTS_%s = %d;  // %d in, %d out"
                 % (b.upper(), n, len(pp[b]["in"]), len(pp[b]["out"])))
    L.append("")
    ur = unresolved(d)
    if ur:
        L.append("// ---------------------------------------------------------")
        L.append("// %d payload field(s) still have no decided width, across"
                 % len(ur))
        L.append("// %d channel(s). Those channels generate no struct. Each is"
                 % sum(1 for c in d["channels"] if not sized(d, c)))
        L.append("// a per-block-session decision; guessing here would put a")
        L.append("// number nobody chose into a generated typedef.")
        for f, chs in sorted(ur.items()):
            L.append("//   %-24s wanted by %s" % (f, ", ".join(c[4:] for c in chs)))
        L.append("// ---------------------------------------------------------")
        L.append("")
    L.append("/* verilator lint_on UNUSEDPARAM */")
    L.append("")
    L.append("`endif // CCV_INTERFACES_SVH")
    return "\n".join(L) + "\n"


def gen_cpp(d, blocks, pp):
    L = [BANNER, "#ifndef CCV_INTERFACES_H", "#define CCV_INTERFACES_H", "",
         "#include <cstdint>", "", "namespace ccv {", ""]
    L.append("/// Channel topology. The skeleton wires blocks from this, so a")
    L.append("/// connection that exists in the model and not in the RTL is a")
    L.append("/// generation error rather than a wiring mistake.")
    L.append("enum Channel : uint16_t {")
    for i, c in enumerate(d["channels"]):
        L.append("  /// %s -> %s, %s/cycle" % (c["src"], c["dst"], c["rate"]))
        L.append("  CH_%s = %d," % (c["name"][4:].upper(), i))
    L.append("  kChannelCount = %d," % len(d["channels"]))
    L.append("};")
    L.append("")
    L.append("struct ChannelInfo {")
    L.append("  const char *name;")
    L.append("  const char *src;")
    L.append("  const char *dst;")
    L.append("  unsigned    rate;")
    L.append("};")
    L.append("")
    L.append("inline const ChannelInfo &channelInfo(Channel c) {")
    L.append("  static const ChannelInfo kInfo[] = {")
    for c in d["channels"]:
        L.append('      {"%s", "%s", "%s", %s},'
                 % (c["name"], c["src"], c["dst"], c["rate"]))
    L.append("  };")
    L.append("  return kInfo[static_cast<unsigned>(c)];")
    L.append("}")
    L.append("")
    for b in sorted(pp):
        n = len(pp[b]["in"]) + len(pp[b]["out"])
        L.append("static constexpr unsigned kPorts%s = %d;  // %d in, %d out"
                 % (b.capitalize(), n, len(pp[b]["in"]), len(pp[b]["out"])))
    L.append("")
    L.append("} // namespace ccv")
    L.append("#endif // CCV_INTERFACES_H")
    return "\n".join(L) + "\n"


def main():
    check = "--check" in sys.argv
    with open(SRC) as f:
        d = json.load(f)
    blocks = block_names()

    names = [c["name"] for c in d["channels"]]
    if len(set(names)) != len(names):
        sys.stderr.write("duplicate channel names\n")
        return 1
    for c in d["channels"]:
        for end in ("src", "dst"):
            if c[end] not in blocks and c[end] != "EXTERNAL":
                sys.stderr.write("channel %s has %s %r, which is not a block "
                                 "in params/blocks.json\n"
                                 % (c["name"], end, c[end]))
                return 1
        # The channel name must agree with its endpoints, or the topology and
        # the name drift and the name is what everyone reads. EXTERNAL is
        # spelled `ext` in a name. It used to be exempt from this check, which
        # was harmless while the only external channel pointed outward; now
        # the port is a pair, both directions are checked.
        nm = lambda b: "ext" if b == "EXTERNAL" else b
        want = "ccv_%s_%s_" % (nm(c["src"]), nm(c["dst"]))
        if not c["name"].startswith(want):
            sys.stderr.write("channel %s does not match its endpoints "
                             "(expected %s...)\n" % (c["name"], want))
            return 1

        # Slot attributes: a known name, a legal value, and only where there
        # is more than one slot for it to describe.
        dflt = d.get("slot_attr_defaults", {})
        for a, v in c.get("slot_attrs", {}).items():
            if a not in dflt or v not in dflt[a]["values"]:
                sys.stderr.write("channel %s: slot attribute %s=%r is not "
                                 "one of %s\n" % (c["name"], a, v,
                                 dflt.get(a, {}).get("values", "(unknown)")))
                return 1
            if c["rate"] == 1:
                sys.stderr.write("channel %s: slot attribute %s on a rate-1 "
                                 "channel describes nothing\n" % (c["name"], a))
                return 1
            if a not in c.get("slot_attrs_why", {}):
                sys.stderr.write("channel %s: slot attribute %s is set with "
                                 "no reason recorded -- a decided value "
                                 "without one reads as a default\n"
                                 % (c["name"], a))
                return 1
        cls = c.get("id_classes")
        if not cls or any(k not in ("instr", "txn", "none") for k in cls):
            sys.stderr.write("channel %s: id_classes must be a non-empty set "
                             "drawn from instr, txn, none\n" % c["name"])
            return 1

    # Resolve the parameter->package map once, then validate every field name
    # and width expression against it BEFORE generating anything. Both classes
    # of error below elaborate into a message that points at the generated
    # file, several steps from the schema line that caused it.
    _PKG_OF.update(load_param_packages())
    bad = 0
    for c in d["channels"]:
        for fld in c["payload_fields"]:
            if fld in SV_RESERVED:
                sys.stderr.write("channel %s: payload field %r is a "
                                 "SystemVerilog reserved word and cannot be a "
                                 "struct member -- rename it in the schema\n"
                                 % (c["name"], fld))
                bad = 1
        for fld in c["payload_fields"]:
            w = d["field_widths"].get(fld)
            if w is None:
                continue
            unk = unknown_names(w)
            if unk:
                sys.stderr.write("channel %s field %s: width %r names %s, "
                                 "which is not in params/ccv_params.json\n"
                                 % (c["name"], fld, w, ", ".join(unk)))
                bad = 1
    if bad:
        return 1

    pp = ports_per_block(d, blocks)
    targets = [
        (os.path.join(ROOT, "rtl", "generated", "ccv_interfaces.svh"),
         gen_sv(d, blocks, pp)),
        (os.path.join(ROOT, "sim", "generated", "ccv_interfaces.h"),
         gen_cpp(d, blocks, pp)),
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
        print("  interface topology up to date (%d channels, %d blocks)"
              % (len(d["channels"]), len(pp)))
        return 0
    print("  generated interface topology from schema/interfaces.json "
          "(%d channels, %d blocks)" % (len(d["channels"]), len(pp)))
    return 0


if __name__ == "__main__":
    sys.exit(main())
