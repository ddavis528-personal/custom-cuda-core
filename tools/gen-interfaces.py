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
import sys

ROOT = os.path.dirname(os.path.dirname(os.path.abspath(__file__)))
SRC = os.path.join(ROOT, "schema", "interfaces.json")
BLOCKS = os.path.join(ROOT, "params", "blocks.json")

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


def gen_sv(d, blocks, pp):
    L = [BANNER, "`ifndef CCV_INTERFACES_SVH", "`define CCV_INTERFACES_SVH", "",
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
    L.append("// Ports per block, derived from the channel list.")
    for b in sorted(pp):
        n = len(pp[b]["in"]) + len(pp[b]["out"])
        L.append("localparam int CCV_PORTS_%s = %d;  // %d in, %d out"
                 % (b.upper(), n, len(pp[b]["in"]), len(pp[b]["out"])))
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
        # the name drift and the name is what everyone reads.
        want = "ccv_%s_%s_" % (c["src"], c["dst"])
        if c["dst"] != "EXTERNAL" and not c["name"].startswith(want):
            sys.stderr.write("channel %s does not match its endpoints "
                             "(expected %s...)\n" % (c["name"], want))
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
