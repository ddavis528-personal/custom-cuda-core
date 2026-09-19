#!/usr/bin/env python3
"""Generate the C++ and SystemVerilog event-schema headers from schema/events.json.

§9 requires that names be mechanically consistent across the C++ timing model
and the RTL, *including the event schema's field names*, because §5 correlation
diffs the two against each other and a rename tax is paid at every 4d debug
session. Generating both from one file makes that true by construction rather
than by discipline, which is the only version of it that survives a solo
project.

It also produces the schema HASH that goes in every trace file's header. A
trace written under one schema and read under another is a correlation run
silently comparing two different machines -- §9 flags exactly this failure mode
for parameters, and it applies identically here.
"""
import hashlib
import json
import os
import sys

ROOT = os.path.dirname(os.path.dirname(os.path.abspath(__file__)))
SCHEMA = os.path.join(ROOT, "schema", "events.json")

BANNER = """// GENERATED FILE -- DO NOT EDIT.
//
// Produced by tools/gen-event-schema.py from schema/events.json.
// Edit the schema and regenerate; tools/verify.sh fails if this file is stale.
"""


def load():
    with open(SCHEMA) as f:
        return json.load(f)


def schema_hash(raw_bytes):
    """Hash the schema's SEMANTIC content, not the file bytes.

    Reformatting the JSON or editing a doc string must not invalidate every
    trace ever written; changing an event's id, class or field names must.
    """
    d = json.loads(raw_bytes)
    sig = {
        "schema_version": d["schema_version"],
        "units": d["units"],
        "events": [
            {"name": e["name"], "id": e["id"], "class": e["class"],
             "fields": e["fields"]}
            for e in sorted(d["events"], key=lambda e: e["id"])
        ],
    }
    blob = json.dumps(sig, sort_keys=True, separators=(",", ":")).encode()
    return hashlib.sha256(blob).hexdigest()[:16]


def gen_cpp(d, h):
    L = [BANNER, "#ifndef CCV_EVENT_IDS_H", "#define CCV_EVENT_IDS_H", "",
         "#include <cstdint>", "", "namespace ccv {", ""]
    L.append("/// Bumped whenever the schema's semantic content changes.")
    L.append("static constexpr uint32_t kSchemaVersion = %d;"
             % d["schema_version"])
    L.append("/// Semantic hash of the schema. Written into every trace header")
    L.append("/// and checked on read, so a trace can never be silently")
    L.append("/// interpreted against a schema it was not written under.")
    L.append('static constexpr const char *kSchemaHash = "%s";' % h)
    L.append("")
    L.append("enum class EventClass : uint16_t {")
    L.append("  kLoadBearing = 0,          ///< exact match required (§1)")
    L.append("  kArbitrationSensitive = 1, ///< comparable only against a "
             "faithful arbiter model")
    L.append("};")
    L.append("")
    L.append("enum Unit : uint16_t {")
    for k, v in sorted(d["units"].items(), key=lambda kv: kv[1]
                       if isinstance(kv[1], int) else -1):
        if k.startswith("_"):
            continue
        L.append("  %s = %d," % (k, v))
    L.append("};")
    L.append("")
    L.append("enum EventId : uint16_t {")
    for e in sorted(d["events"], key=lambda e: e["id"]):
        L.append("  /// %s" % e["doc"])
        L.append("  %s = %d," % (e["name"], e["id"]))
    L.append("  kEventIdCount = %d," % (max(e["id"] for e in d["events"]) + 1))
    L.append("};")
    L.append("")
    L.append("/// Class of each event id, for the §5 correlation split.")
    L.append("inline EventClass eventClass(EventId id) {")
    L.append("  switch (id) {")
    for e in sorted(d["events"], key=lambda e: e["id"]):
        cls = ("EventClass::kArbitrationSensitive"
               if e["class"] == "arbitration_sensitive"
               else "EventClass::kLoadBearing")
        L.append("  case %s: return %s;" % (e["name"], cls))
    L.append("  default: return EventClass::kLoadBearing;")
    L.append("  }")
    L.append("}")
    L.append("")
    L.append("inline const char *eventName(EventId id) {")
    L.append("  switch (id) {")
    for e in sorted(d["events"], key=lambda e: e["id"]):
        L.append('  case %s: return "%s";' % (e["name"], e["name"]))
    L.append('  default: return "EV_UNKNOWN";')
    L.append("  }")
    L.append("}")
    L.append("")
    L.append("inline const char *unitName(uint16_t u) {")
    L.append("  switch (u) {")
    for k, v in sorted(((k, v) for k, v in d["units"].items()
                        if not k.startswith("_")), key=lambda kv: kv[1]):
        L.append('  case %d: return "%s";' % (v, k))
    L.append('  default: return "UNIT_UNKNOWN";')
    L.append("  }")
    L.append("}")
    L.append("")
    L.append("/// Field names per event, in payload order (a, b, c). These are")
    L.append("/// the names §9 requires the RTL to use for the same signals.")
    L.append("inline const char *fieldName(EventId id, unsigned slot) {")
    L.append("  switch (id) {")
    for e in sorted(d["events"], key=lambda e: e["id"]):
        f = e["fields"]
        L.append("  case %s:" % e["name"])
        L.append('    return slot == 0 ? "%s" : slot == 1 ? "%s" : "%s";'
                 % (f["a"], f["b"], f["c"]))
    L.append('  default: return "unused";')
    L.append("  }")
    L.append("}")
    L.append("")
    L.append("} // namespace ccv")
    L.append("#endif // CCV_EVENT_IDS_H")
    return "\n".join(L) + "\n"


def gen_sv(d, h):
    L = [BANNER.replace("//", "//"), "`ifndef CCV_EVENT_IDS_SVH",
         "`define CCV_EVENT_IDS_SVH", ""]
    L.append("// Same identifiers as sim/generated/ccv_event_ids.h, from the")
    L.append("// same source. §9: a signal that is one name in RTL and another")
    L.append("// in the model imposes a translation tax on every 4d debug")
    L.append("// session, permanently.")
    L.append("")
    L.append('// A generated header is a CATALOGUE: it declares every event id and unit in\n// the schema, and no single consumer uses all of them. That is the intended\n// shape, not an oversight, so the unused-parameter warning is turned off for\n// this file only -- narrowly, and here rather than at the call site, so a\n// genuinely unused parameter in hand-written RTL still gets caught.\n/* verilator lint_off UNUSEDPARAM */')
    L.append("localparam int CCV_SCHEMA_VERSION = %d;" % d["schema_version"])
    L.append('localparam string CCV_SCHEMA_HASH = "%s";' % h)
    L.append("")
    for k, v in sorted(((k, v) for k, v in d["units"].items()
                        if not k.startswith("_")), key=lambda kv: kv[1]):
        L.append("localparam int CCV_%s = %d;" % (k, v))
    L.append("")
    for e in sorted(d["events"], key=lambda e: e["id"]):
        L.append("// %s" % e["doc"])
        L.append("localparam int CCV_%s = %d;" % (e["name"], e["id"]))
    L.append("")
    L.append("/* verilator lint_on UNUSEDPARAM */")
    L.append("")
    L.append("`endif // CCV_EVENT_IDS_SVH")
    return "\n".join(L) + "\n"


def main():
    check = "--check" in sys.argv
    with open(SCHEMA, "rb") as f:
        raw = f.read()
    d = json.loads(raw)
    h = schema_hash(raw)

    # Event ids must be unique and stable: a reused id silently reinterprets
    # every trace already written.
    ids = [e["id"] for e in d["events"]]
    if len(set(ids)) != len(ids):
        sys.stderr.write("event ids are not unique: %s\n" % sorted(ids))
        return 1
    names = [e["name"] for e in d["events"]]
    if len(set(names)) != len(names):
        sys.stderr.write("event names are not unique\n")
        return 1
    for e in d["events"]:
        if e["class"] not in d["classes"]:
            sys.stderr.write("event %s has unknown class %r\n"
                             % (e["name"], e["class"]))
            return 1
        if set(e["fields"]) != {"a", "b", "c"}:
            sys.stderr.write("event %s must define fields a, b and c\n"
                             % e["name"])
            return 1

    targets = [
        (os.path.join(ROOT, "sim", "generated", "ccv_event_ids.h"), gen_cpp(d, h)),
        (os.path.join(ROOT, "rtl", "generated", "ccv_event_ids.svh"), gen_sv(d, h)),
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
            sys.stderr.write("generated event headers are stale: %s\n"
                             "  run tools/gen-event-schema.py\n"
                             % ", ".join(stale))
            return 1
        print("  event schema headers up to date (hash %s)" % h)
        return 0
    print("  generated event headers from schema/events.json (hash %s)" % h)
    return 0


if __name__ == "__main__":
    sys.exit(main())
