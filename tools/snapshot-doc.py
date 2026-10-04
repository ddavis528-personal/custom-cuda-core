#!/usr/bin/env python3
"""Wrap a Claude-doc tab's markdown export as a design snapshot.

    tools/snapshot-doc.py NAME EXPORT.md --url URL --doc DOC --tab TAB
                          --rev N --status living|closed [--diagrams FILE]

Writes docs/design-snapshots/NAME.md: a header saying what it is a snapshot
of (doc, tab, revision, date, status), then the export. An export turns each
embedded diagram into a placeholder, "[embedded content: CAPTION]". Each one
is replaced by the section of --diagrams headed "## CAPTION", the diagram as
text. A placeholder with no such section is refused, so a new or renamed
diagram cannot silently become a dead line.

The export itself needs the Claude Docs connector, so an agent session runs
it; this script only makes the result uniform. docs/design-snapshots/README.md
says when to refresh, and tools/check-docs.sh checks the headers and that the
review snapshot is no older than the A-numbers the repo cites.
"""
import argparse
import datetime
import os
import re
import sys

ROOT = os.path.dirname(os.path.dirname(os.path.abspath(__file__)))
OUT = os.path.join(ROOT, "docs", "design-snapshots")
PLACEHOLDER = re.compile(r"^&#91;embedded content: (.*?)\\?\]\s*$", re.M)


def diagrams(path):
    """Caption -> text, from '## caption' sections."""
    out, cur = {}, None
    for line in open(path):
        m = re.match(r"^## (.+?)\s*$", line)
        if m:
            cur = m.group(1)
            out[cur] = []
        elif cur is not None:
            out[cur].append(line)
    return {k: "".join(v).strip() for k, v in out.items()}


def main():
    ap = argparse.ArgumentParser()
    ap.add_argument("name")
    ap.add_argument("export")
    ap.add_argument("--url", required=True)
    ap.add_argument("--doc", required=True)
    ap.add_argument("--tab", required=True)
    ap.add_argument("--rev", required=True, type=int)
    ap.add_argument("--status", required=True, choices=("living", "closed"))
    ap.add_argument("--diagrams")
    ap.add_argument("--date", default=datetime.date.today().isoformat())
    a = ap.parse_args()

    body = open(a.export).read()
    figs = diagrams(a.diagrams) if a.diagrams else {}
    missing = []

    def fig(m):
        cap = m.group(1)
        if cap not in figs:
            missing.append(cap)
            return m.group(0)
        return ("> **Figure, as text** (drawn in the live doc): %s\n>\n" % cap +
                "\n".join("> " + l if l else ">" for l in figs[cap].splitlines()))

    body = PLACEHOLDER.sub(fig, body)
    if missing:
        sys.stderr.write("snapshot-doc: no text for these diagrams in %s:\n%s\n"
                         % (a.diagrams, "\n".join("  " + c for c in missing)))
        return 1
    state = ("it is a living document, so this copy is refreshed whenever it "
             "changes" if a.status == "living" else
             "it is a closed record, whose conversation has ended")
    head = ("<!-- design-snapshot url=%s tab=%s rev=%d exported=%s status=%s -->\n"
            "> **Snapshot: do not edit.** Exported from *%s*, tab *%s*, at "
            "revision %d on %s ([live doc](%s)). The live doc is the source; "
            "%s. This copy pins what the repo was built against; see "
            "[README.md](README.md).\n\n"
            % (a.url, a.tab.replace(" ", "_"), a.rev, a.date, a.status,
               a.doc, a.tab, a.rev, a.date, a.url, state))
    os.makedirs(OUT, exist_ok=True)
    path = os.path.join(OUT, a.name + ".md")
    with open(path, "w") as f:
        f.write(head + body.rstrip() + "\n")
    print("  wrote %s (rev %d, %s)" % (os.path.relpath(path, ROOT), a.rev, a.status))
    return 0


if __name__ == "__main__":
    sys.exit(main())
