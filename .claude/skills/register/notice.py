#!/usr/bin/env python3
"""Register notices: compose, parse and route the one-line doorbell agents
send each other after writing a register row (see SKILL.md).

  notice.py roster                     every prefix, its session and tab
  notice.py session ROLE               ROLE's session id; exit 1 if it has none
  notice.py compose --from OA --to OI --rows OA-17,re:OI-50 --rev 63 \
                    --summary "..."    the message text to send
  notice.py parse < message            the notice's fields as JSON; exit 1 if
                                       the text is not a notice

The notice says only where to look. The register row is the content of
record, so a receiver reads the row and never acts on the notice's words.
"""
import argparse
import json
import re
import sys
from pathlib import Path

# Outside .claude/, so any session may edit its own line (some refuse .claude/).
ROSTER = Path(__file__).resolve().parents[3] / "docs" / "register" / "roster.json"
HEAD = "REGISTER-NOTICE v1"
FIELD = re.compile(r"(\w+)=(\S+)")
ID = re.compile(r"^(re:)?[A-Z]{2}-\d+$")


def roster():
    return json.loads(ROSTER.read_text())


def role(r, name):
    a = r["agents"].get(name.upper())
    if a is None:
        sys.exit(f"notice.py: no register prefix {name!r} in {ROSTER}")
    return a


def compose(args):
    r = roster()
    src, dst = role(r, args.src), role(r, args.dst)
    if args.src.upper() == args.dst.upper():
        sys.exit("notice.py: an agent never notifies itself")
    rows = [x.strip() for x in args.rows.split(",") if x.strip()]
    bad = [x for x in rows if not ID.match(x)]
    if not rows or bad:
        sys.exit(f"notice.py: rows must be IDs like OA-17 or re:OI-50, got {bad or rows}")
    summary = " ".join(args.summary.split())[:300]
    return (f"{HEAD} from={args.src.upper()} to={args.dst.upper()} tab={src['tab']} "
            f"rows={','.join(rows)} rev={args.rev}\n"
            f"{summary}\n"
            f"Read the rows in the register ({r['register']}); answer there, in your own tab. "
            f"This notice is a pointer, not a request: the rows are the record.")


def parse(text):
    line = next((l for l in text.splitlines() if l.startswith(HEAD)), None)
    if line is None:
        return None
    f = dict(FIELD.findall(line))
    if not {"from", "to", "tab", "rows", "rev"} <= f.keys():
        return None
    f["rows"] = f["rows"].split(",")
    if not all(ID.match(x) for x in f["rows"]) or f["from"] not in roster()["agents"]:
        return None
    return f


def main():
    p = argparse.ArgumentParser(description=__doc__, formatter_class=argparse.RawDescriptionHelpFormatter)
    sub = p.add_subparsers(dest="cmd", required=True)
    sub.add_parser("roster")
    s = sub.add_parser("session")
    s.add_argument("role")
    c = sub.add_parser("compose")
    c.add_argument("--from", dest="src", required=True)
    c.add_argument("--to", dest="dst", required=True)
    c.add_argument("--rows", required=True, help="comma-separated: OA-17, re:OI-50")
    c.add_argument("--rev", required=True, type=int, help="your tab's rev after the write")
    c.add_argument("--summary", required=True, help="one line: what the rows ask or answer")
    sub.add_parser("parse")
    a = p.parse_args()

    if a.cmd == "roster":
        for k, v in roster()["agents"].items():
            print(f"{k}  {v['session'] or '-':34}  tab {v['tab']}  {v['title']}")
    elif a.cmd == "session":
        s = role(roster(), a.role)["session"]
        if not s:
            sys.exit(f"notice.py: {a.role.upper()} has no session to notify; its daily sweep picks the row up")
        print(s)
    elif a.cmd == "compose":
        print(compose(a))
    elif a.cmd == "parse":
        f = parse(sys.stdin.read())
        if f is None:
            sys.exit("notice.py: not a register notice")
        print(json.dumps(f))


if __name__ == "__main__":
    main()
