#!/usr/bin/env python3
"""Generate docs/payload-spec.md from schema/interfaces.json and
params/ccv_params.json.

The payload spec is the per-block sessions' worklist: what every channel
carries, which fields have a decided width and where that width came from, and
for the undecided ones, the specific question that has to be answered.

GENERATED rather than written, for the same reason the typedefs are. A
hand-written table of 40 channels and 66 field widths agrees with the schema on
the day it is written and drifts by the end of the week, and a spec that
disagrees with the generator is worse than no spec -- the reader cannot tell
which one the RTL was built against. Here the schema is the single source and
this file is a view of it, so the census at the top cannot be wrong.

Width RATIONALE is judgment and lives in params/ccv_params.json as each
parameter's doc; this pulls it through rather than restating it. The open
fields' QUESTIONS are judgment too and live in schema/interfaces.json under
open_fields.
"""
import json
import os
import re
import sys

ROOT = os.path.dirname(os.path.dirname(os.path.abspath(__file__)))
SRC = os.path.join(ROOT, "schema", "interfaces.json")
PARAMS = os.path.join(ROOT, "params", "ccv_params.json")
OUT = os.path.join(ROOT, "docs", "payload-spec.md")

BANNER = """<!-- GENERATED FILE -- DO NOT EDIT.
     Produced by tools/gen-payload-spec.py from schema/interfaces.json and
     params/ccv_params.json. Edit a source and regenerate; tools/verify.sh
     fails if this file is stale. -->
"""

# A width expression is a sum of parameter names and integer literals. Only
# the names are looked up, so `CCV_W_VA * 4` and `8` both resolve.
NAME_RE = re.compile(r"[A-Za-z_][A-Za-z0-9_]*")


def resolve(expr, pv):
    """Evaluate a width expression over the parameter values.

    Returns (bits, unresolved_names). An expression naming a parameter that
    does not exist resolves to None rather than raising, so a typo in the
    schema surfaces as a visible gap in the table instead of a traceback that
    stops the whole document being generated.
    """
    names = set(NAME_RE.findall(str(expr)))
    unknown = sorted(n for n in names if n not in pv)
    if unknown:
        return None, unknown
    try:
        return int(eval(str(expr), {"__builtins__": {}}, dict(pv))), []
    except Exception:
        return None, sorted(names)


def load():
    with open(SRC) as f:
        d = json.load(f)
    with open(PARAMS) as f:
        p = json.load(f)
    params = {x["name"]: x for x in p["params"]}
    # Provisional parameters land in a separate package, and the distinction
    # is the whole point of the split -- so it has to survive into the table.
    pv = {k: v["value"] for k, v in params.items()}
    return d, params, pv


def pkg_of(name, params):
    st = params[name]["status"] if name in params else None
    return "ccv_prov_pkg" if st == "provisional" else "ccv_params_pkg"


def fmt_width(expr, params, pv):
    """One table cell: the expression, its resolved bit count, and its source."""
    bits, unknown = resolve(expr, pv)
    if unknown:
        return "`%s`" % expr, "?", "**unresolved: %s**" % ", ".join(unknown)
    names = [n for n in NAME_RE.findall(str(expr)) if n in params]
    if not names:
        return "`%s`" % expr, str(bits), "literal"
    srcs = []
    for n in names:
        st = params[n]["status"]
        srcs.append("%s (%s)" % (n, st))
    prov = any(params[n]["status"] == "provisional" for n in names)
    tag = " ⚠️" if prov else ""
    return "`%s`" % expr, str(bits) + tag, "; ".join(srcs)


def channel_rows(d, params, pv):
    fw = d["field_widths"]
    sized, partial = [], []
    for c in d["channels"]:
        open_f = [f for f in c["payload_fields"] if f not in fw]
        (partial if open_f else sized).append((c, open_f))
    return sized, partial


def field_table(c, fw, params, pv):
    """Returns (markdown rows, total bits or None, provisional bits).

    The provisional count is tracked separately because a channel can be
    "fully sized" and still not be decided -- every field has a width, but some
    of those widths resolve through ccv_prov_pkg. Reporting only the total
    would present such a channel as settled, which is the exact mistake the
    two-package split exists to prevent.
    """
    L = ["| Field | Width expression | Bits | Source |",
         "|---|---|---|---|"]
    total = 0
    prov_bits = 0
    known = True
    for f in c["payload_fields"]:
        if f not in fw:
            L.append("| `%s` | — | — | **OPEN — see below** |" % f)
            known = False
            continue
        e, b, s = fmt_width(fw[f], params, pv)
        L.append("| `%s` | %s | %s | %s |" % (f, e, b, s))
        digits = b.rstrip(" ⚠️")
        if digits.isdigit():
            total += int(digits)
            if "⚠️" in b:
                prov_bits += int(digits)
        else:
            known = False
    if known:
        note = ""
        if prov_bits:
            note = " ⚠️ %d of these bits are provisional" % prov_bits
        L.append("| **total** | | **%d** |%s |" % (total, note))
    return L, (total if known else None), prov_bits


def main():
    check = "--check" in sys.argv
    d, params, pv = load()
    fw = d["field_widths"]
    openq = d.get("open_fields", {})
    sized, partial = channel_rows(d, params, pv)

    n_open_fields = len(openq)
    L = [BANNER, "# Payload specification — all 40 channels", ""]
    L.append("Every channel's payload, field by field. **%d of %d channels**"
             % (len(sized), len(d["channels"])))
    L.append("have every field sized and generate a packed struct today; the")
    L.append("remaining %d have at least one field with no decided width."
             % len(partial))
    L.append("")
    L.append("Two things this document is careful about:")
    L.append("")
    L.append("- A width that is **decided** shows where it came from, so a")
    L.append("  reader can tell an ISA constant from an architectural choice")
    L.append("  from a provisional placeholder. Anything marked ⚠️ resolves")
    L.append("  through `ccv_prov_pkg` and is **not** a decision.")
    L.append("- A width that is **not decided** is left open with the specific")
    L.append("  question attached. No placeholder is supplied, because a")
    L.append("  placeholder reaches a generated typedef and gets believed,")
    L.append("  whereas an open field blocks loudly.")
    L.append("")
    L.append("Channel shape is uniform and is not repeated per channel: four")
    L.append("signals — `_valid` and `_payload` from the producer, `_credit`")
    L.append("and `_stall` from the consumer — with valid one cycle ahead of")
    L.append("the payload. See `docs/interface-checker-convention.md`.")
    L.append("")

    L.append("## Summary")
    L.append("")
    L.append("| | Channels | Fields |")
    L.append("|---|---|---|")
    allf = sum(len(c["payload_fields"]) for c in d["channels"])
    settled = [ (c, o) for c, o in sized
                if field_table(c, fw, params, pv)[2] == 0 ]
    provisional = [ (c, o) for c, o in sized
                    if field_table(c, fw, params, pv)[2] > 0 ]
    L.append("| Sized, every width decided | %d | %d |"
             % (len(settled), sum(len(c["payload_fields"]) for c, _ in settled)))
    L.append("| Sized, but some width provisional | %d | %d |"
             % (len(provisional),
                sum(len(c["payload_fields"]) for c, _ in provisional)))
    L.append("| Has an open field | %d | %d |"
             % (len(partial), sum(len(c["payload_fields"]) for c, _ in partial)))
    L.append("| **Total** | **%d** | **%d** |" % (len(d["channels"]), allf))
    L.append("")
    L.append("Distinct field names with no decided width: **%d**." % n_open_fields)
    L.append("")
    L.append("**\"Sized\" is not \"decided.\"** %d of the %d channels that"
             % (len(provisional), len(sized)))
    L.append("generate a struct today do so through at least one provisional")
    L.append("width, so their layout will move when that parameter is settled.")
    L.append("Only **%d of %d** channels are decided end to end. The provisional"
             % (len(settled), len(d["channels"])))
    L.append("parameters those depend on:")
    L.append("")
    dep = {}
    for c, _ in provisional:
        for f in c["payload_fields"]:
            for n in NAME_RE.findall(str(fw.get(f, ""))):
                if n in params and params[n]["status"] == "provisional":
                    dep.setdefault(n, set()).add(c["name"])
    for n in sorted(dep, key=lambda k: (-len(dep[k]), k)):
        L.append("- `%s` = %d — %s — **%d channel%s**"
                 % (n, params[n]["value"], params[n]["doc"].rstrip("."),
                    len(dep[n]), "" if len(dep[n]) == 1 else "s"))
    L.append("")

    # -- the ask, first, because it is what the reader is here for ---------
    L.append("---")
    L.append("")
    L.append("## What is needed, by owner")
    L.append("")
    L.append("Grouped by who has to answer. A field appearing on several")
    L.append("channels is listed once; those are the ones where two sessions")
    L.append("deciding independently produce two incompatible encodings.")
    L.append("")
    by_owner = {}
    for f, e in openq.items():
        by_owner.setdefault(e.get("owner", "unassigned"), []).append(f)
    for owner in sorted(by_owner):
        fields = sorted(by_owner[owner])
        L.append("### %s" % owner)
        L.append("")
        for f in fields:
            e = openq[f]
            chans = e.get("channels", [])
            L.append("**`%s`** — %d channel%s: %s"
                     % (f, len(chans), "" if len(chans) == 1 else "s",
                        ", ".join("`%s`" % c for c in chans)))
            L.append("")
            if e.get("flag"):
                L.append("> ⚑ %s" % e["flag"])
                L.append("")
            L.append(e["question"])
            L.append("")
    L.append("---")
    L.append("")

    # -- per-channel detail ------------------------------------------------
    L.append("## Channels with every field sized")
    L.append("")
    L.append("These generate a packed struct into both languages today.")
    L.append("")
    for c, _ in sized:
        L.append("### `%s`" % c["name"])
        L.append("")
        L.append("%s → %s · rate %s · %s"
                 % (c["src"], c["dst"], c.get("rate", "?"),
                    c.get("group", "?")))
        L.append("")
        rows, total, prov_bits = field_table(c, fw, params, pv)
        L.extend(rows)
        L.append("")

    L.append("## Channels with at least one open field")
    L.append("")
    L.append("These generate topology only — no packed struct — until every")
    L.append("field is sized.")
    L.append("")
    for c, open_f in partial:
        L.append("### `%s`" % c["name"])
        L.append("")
        L.append("%s → %s · rate %s · %s · **%d open**"
                 % (c["src"], c["dst"], c.get("rate", "?"),
                    c.get("group", "?"), len(open_f)))
        L.append("")
        rows, _, _ = field_table(c, fw, params, pv)
        L.extend(rows)
        L.append("")
        L.append("Open: %s" % ", ".join("`%s`" % f for f in open_f))
        L.append("")

    text = "\n".join(L).rstrip() + "\n"
    cur = open(OUT).read() if os.path.exists(OUT) else None
    rel = os.path.relpath(OUT, ROOT)
    if check:
        if cur != text:
            sys.stderr.write("%s is stale\n  run tools/gen-payload-spec.py\n"
                             % rel)
            return 1
        print("  payload spec up to date (%d sized, %d open, %d questions)"
              % (len(sized), len(partial), n_open_fields))
        return 0
    with open(OUT, "w") as f:
        f.write(text)
    print("  generated %s (%d channels sized, %d with open fields)"
          % (rel, len(sized), len(partial)))
    return 0


if __name__ == "__main__":
    sys.exit(main())
