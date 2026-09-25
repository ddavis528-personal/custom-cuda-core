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
from ccv_schema import field_width

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


TIER_MARK = {"settled": "", "prov": " ⚠️", "prelim": " ⛔"}


def tier_of(name, params):
    st = params[name]["status"] if name in params else None
    if st == "preliminary":
        return "prelim"
    if st in ("provisional", "tunable"):
        return "prov"
    return "settled"


def worst_tier(expr, params):
    t = "settled"
    for n in NAME_RE.findall(str(expr)):
        if n in params:
            k = tier_of(n, params)
            if k == "prelim":
                return "prelim"
            if k == "prov":
                t = "prov"
    return t


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
        x = params[n]
        extra = ""
        if x["status"] == "preliminary":
            c = x.get("churn", "?")
            extra = ", churn %s" % ("**HIGH**" if c == "high" else c)
        srcs.append("%s (%s%s)" % (n, x["status"], extra))
    return ("`%s`" % expr, str(bits) + TIER_MARK[worst_tier(expr, params)],
            "; ".join(srcs))


def channel_rows(d, params, pv):
    fw = d["field_widths"]
    sized, partial = [], []
    for c in d["channels"]:
        open_f = [f for f in c["payload_fields"] if field_width(d, c, f) is None]
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
    prelim_bits = 0
    known = True
    for f in c["payload_fields"]:
        if f not in fw:
            L.append("| `%s` | — | — | **OPEN — see below** |" % f)
            known = False
            continue
        e, b, s = fmt_width(fw[f], params, pv)
        L.append("| `%s` | %s | %s | %s |" % (f, e, b, s))
        digits = b.rstrip(" ⚠️⛔")
        if digits.isdigit():
            total += int(digits)
            if "⛔" in b:
                prelim_bits += int(digits)
            elif "⚠️" in b:
                prov_bits += int(digits)
        else:
            known = False
    if known:
        bits = []
        if prelim_bits:
            bits.append("⛔ %d preliminary" % prelim_bits)
        if prov_bits:
            bits.append("⚠️ %d provisional" % prov_bits)
        note = (" " + ", ".join(bits)) if bits else ""
        L.append("| **total** | | **%d** |%s |" % (total, note))
    return L, (total if known else None), (prov_bits, prelim_bits)


def main():
    check = "--check" in sys.argv
    d, params, pv = load()
    fw = d["field_widths"]
    chans = d["channels"]

    # Classify each channel by the WEAKEST width it carries. A channel is only
    # as trustworthy as its least-decided field, so taking the worst is the
    # honest summary -- an average would let one settled field hide a
    # preliminary one.
    buckets = {"settled": [], "prov": [], "prelim": []}
    for c in chans:
        worst = "settled"
        for f in c["payload_fields"]:
            t = worst_tier(field_width(d, c, f), params)
            if t == "prelim":
                worst = "prelim"
                break
            if t == "prov":
                worst = "prov"
        buckets[worst].append(c)

    prelim_params = {x["name"]: x for x in params.values()
                     if x["status"] == "preliminary"}

    L = [BANNER, "# Payload specification — all 40 channels", ""]
    L.append("Every payload field has a width, so **every one of the %d"
             % len(chans))
    L.append("channels generates a packed struct** and the skeleton can be")
    L.append("wired end to end. The cost is that some widths are guesses, and")
    L.append("the job of this document is to make sure a guess can never be")
    L.append("mistaken for a decision.")
    L.append("")
    L.append("## Three tiers of trust")
    L.append("")
    L.append("Every width resolves through one of three packages, and the")
    L.append("package name is visible at the use site. That is the whole")
    L.append("mechanism: a reader of any struct definition can tell how much")
    L.append("trust the number deserves without looking anything up.")
    L.append("")
    L.append("| Package | Meaning | Expected to move | Mark |")
    L.append("|---|---|---|---|")
    L.append("| `ccv_params_pkg` | follows from a settled decision, traceable to the ISA or a partitioning choice | no | |")
    L.append("| `ccv_prov_pkg` | a sizing placeholder awaiting a per-block session | the number | ⚠️ |")
    L.append("| `ccv_prelim_pkg` | no decided encoding at all; the width is a first guess | possibly the **field itself** | ⛔ |")
    L.append("")
    L.append("`ccv_prelim_pkg` exists so skeleton coding is unblocked without")
    L.append("pretending the encodings are known. A preliminary width says the")
    L.append("field is real and roughly this big; it does **not** say the")
    L.append("encoding, the field count or the semantics are settled.")
    L.append("")
    L.append("**Churn** rates the field, not the number. *High* means a")
    L.append("per-block session is likely to change the field's shape, so code")
    L.append("that pattern-matches on its contents will need rewriting; *low*")
    L.append("means only the number moves. `docs/trust-report.md` is the")
    L.append("build artifact listing everything that references either of the")
    L.append("bottom two tiers.")
    L.append("")

    L.append("## Summary")
    L.append("")
    L.append("Each channel is classified by the **weakest** width it carries,")
    L.append("since a struct is only as settled as its least-decided field.")
    L.append("")
    L.append("| Weakest width on the channel | Channels | Fields |")
    L.append("|---|---|---|")
    for k, label in (("settled", "All decided"),
                     ("prov", "⚠️ Some provisional"),
                     ("prelim", "⛔ Some preliminary")):
        L.append("| %s | %d | %d |"
                 % (label, len(buckets[k]),
                    sum(len(c["payload_fields"]) for c in buckets[k])))
    L.append("| **Total** | **%d** | **%d** |"
             % (len(chans), sum(len(c["payload_fields"]) for c in chans)))
    L.append("")

    L.append("## What still has to be decided")
    L.append("")
    L.append("Grouped by who decides. Highest churn first within each group,")
    L.append("because those are the ones where a skeleton that reads the field")
    L.append("— rather than merely carrying it — will need rework.")
    L.append("")
    by_owner = {}
    for n, x in prelim_params.items():
        by_owner.setdefault(x.get("decided_at", "unassigned"), []).append(n)
    order = {"high": 0, "med": 1, "low": 2}
    for owner in sorted(by_owner):
        L.append("### %s" % owner)
        L.append("")
        L.append("| Parameter | Value | Churn | Basis |")
        L.append("|---|---|---|---|")
        for n in sorted(by_owner[owner],
                        key=lambda k: (order.get(prelim_params[k].get("churn"), 9), k)):
            x = prelim_params[n]
            c = x.get("churn", "?")
            L.append("| `%s` | %d | %s | %s |"
                     % (n, x["value"], "**HIGH**" if c == "high" else c,
                        x["doc"].replace("\n", " ")))
        L.append("")

    oq = d.get("open_questions", {})
    if oq:
        L.append("## Open questions that no width can close")
        L.append("")
        for k in sorted(oq):
            e = oq[k]
            L.append("### %s" % k.replace("_", " "))
            L.append("")
            L.append("*%s — %s*" % (e.get("kind", "?"), e.get("owner", "?")))
            L.append("")
            L.append(e["question"])
            L.append("")
            L.append("**Blocks:** %s" % e["blocks"])
            L.append("")

    L.append("---")
    L.append("")
    L.append("## Every channel")
    L.append("")
    for k, label in (("settled", "All widths decided"),
                     ("prov", "⚠️ Carries a provisional width"),
                     ("prelim", "⛔ Carries a preliminary width")):
        if not buckets[k]:
            continue
        L.append("## %s" % label)
        L.append("")
        for c in buckets[k]:
            L.append("### `%s`" % c["name"])
            L.append("")
            if c.get("doc"):
                L.append("%s" % c["doc"])
                L.append("")
            L.append("%s → %s · rate %s · %s"
                     % (c["src"], c["dst"], c.get("rate", "?"),
                        c.get("group", "?")))
            L.append("")
            rows, _, _ = field_table(c, {**fw, **c.get("field_widths", {})},
                                    params, pv)
            L.extend(rows)
            L.append("")

    text = "\n".join(L).rstrip() + "\n"
    cur = open(OUT).read() if os.path.exists(OUT) else None
    rel = os.path.relpath(OUT, ROOT)
    if check:
        if cur != text:
            sys.stderr.write("%s is stale\n  run tools/gen-payload-spec.py\n"
                             % rel)
            return 1
        print("  payload spec up to date (%d settled, %d prov, %d prelim)"
              % (len(buckets["settled"]), len(buckets["prov"]),
                 len(buckets["prelim"])))
        return 0
    with open(OUT, "w") as f:
        f.write(text)
    print("  generated %s (%d settled, %d prov, %d prelim channels)"
          % (rel, len(buckets["settled"]), len(buckets["prov"]),
             len(buckets["prelim"])))
    return 0


if __name__ == "__main__":
    sys.exit(main())
