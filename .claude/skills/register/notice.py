#!/usr/bin/env python3
"""Register notices: compose, parse and route the one-line doorbell agents
send each other after writing a register row (see SKILL.md).

  notice.py roster                     every prefix, its session and tab
  notice.py session ROLE               ROLE's session id; exit 1 if it has none
  notice.py compose --from OA --to OI --rows OA-17,re:OI-50 --rev 63 \
                    --summary "..."    the message text to send
  notice.py parse < message            the notice's fields as JSON; exit 1 if
                                       the text is not a notice
  notice.py ping --from TI --to OI     the daily reachability ping (section 6)
  notice.py pong --me OI --session S --from-session F < ping
                                       the answer to a ping: S is your own
                                       session, F the ping's from-session
  notice.py check --from-session F < pong
                                       exit 1, naming each problem, unless the
                                       pong came from the roster's session for
                                       the prefix pinged, and all agree

The notice says only where to look. The register row is the content of
record, so a receiver reads the row and never acts on the notice's words.
"""
import argparse
import json
import re
import sys
from datetime import date
from pathlib import Path

# Outside .claude/, so any session may edit its own line (some refuse .claude/).
ROSTER = Path(__file__).resolve().parents[3] / "docs" / "register" / "roster.json"
HEAD = "REGISTER-NOTICE v1"
PING = "REGISTER-PING v1"
PONG = "REGISTER-PONG v1"
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


def fields(text, head, need):
    line = next((l for l in text.splitlines() if l.startswith(head)), None)
    f = dict(FIELD.findall(line)) if line else {}
    if not need <= f.keys():
        sys.exit(f"notice.py: not a {head} message")
    return f


def ping(args):
    r = roster()
    role(r, args.src), role(r, args.dst)
    if args.src.upper() == args.dst.upper():
        sys.exit("notice.py: an agent never pings itself")
    dst = args.dst.upper()
    return (f"{PING} from={args.src.upper()} to={dst} date={date.today().isoformat()}\n"
            f"ping, reply if you are {dst}: answer with the register skill's section 6 "
            f"(notice.py pong), once. If you are not {dst}, the pong says so.")


def pong(args, text):
    """The receiver's answer. It checks three things against its own roster:
    that the ping was meant for it, that the roster still names this session
    for its prefix (a replaced session learns it is stale), and that the
    roster names the ping's sender session for the sender's prefix (a sender
    that is itself replaced learns it from the answer)."""
    r = roster()
    f = fields(text, PING, {"from", "to", "date"})
    me = args.me.upper()
    mine = role(r, me)["session"]
    theirs = r["agents"].get(f["from"], {}).get("session")
    out = {
        "addressed": "yes" if f["to"] == me else "no",
        "me": "ok" if mine == args.session else "stale",
        "sender": "ok" if theirs == args.from_session else "stale",
    }
    words = [f"{me} here, session {args.session}."]
    if out["addressed"] == "no":
        words.append(f"This ping was for {f['to']}, not {me}: your roster sends {f['to']}'s messages here.")
    if out["me"] == "stale":
        words.append(f"My roster names {mine} for {me}, not this session: use that one.")
    if out["sender"] == "stale":
        words.append(f"My roster names {theirs} for {f['from']}, not your session {args.from_session}.")
    return (f"{PONG} from={me} to={f['from']} date={f['date']} session={args.session} "
            + " ".join(f"{k}={v}" for k, v in out.items()) + "\n"
            + " ".join(words) + " A pong is never answered.")


def check(args, text):
    r = roster()
    f = fields(text, PONG, {"from", "to", "date", "session", "addressed", "me", "sender"})
    bad = []
    want = r["agents"].get(f["from"], {}).get("session")
    if args.from_session != f["session"]:
        bad.append(f"the pong says session {f['session']} but came from {args.from_session}")
    if want != args.from_session:
        bad.append(f"the roster names {want} for {f['from']}, but {args.from_session} answered")
    for k, ok in (("addressed", "yes"), ("me", "ok"), ("sender", "ok")):
        if f[k] != ok:
            bad.append(f"{k}={f[k]}")
    return f, bad


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
    g = sub.add_parser("ping")
    g.add_argument("--from", dest="src", required=True)
    g.add_argument("--to", dest="dst", required=True)
    g = sub.add_parser("pong")
    g.add_argument("--me", required=True, help="your register prefix")
    g.add_argument("--session", required=True, help="your own session id (get_session)")
    g.add_argument("--from-session", required=True, help="the ping's from-session")
    g = sub.add_parser("check")
    g.add_argument("--from-session", required=True, help="the pong's from-session")
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
    elif a.cmd == "ping":
        print(ping(a))
    elif a.cmd == "pong":
        print(pong(a, sys.stdin.read()))
    elif a.cmd == "check":
        f, bad = check(a, sys.stdin.read())
        if bad:
            sys.exit(f"notice.py: {f['from']}'s pong of {f['date']}: " + "; ".join(bad))
        print(f"{f['from']} reached at {a.from_session} ({f['date']})")


if __name__ == "__main__":
    main()
