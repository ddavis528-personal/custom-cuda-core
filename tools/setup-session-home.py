#!/usr/bin/env python3
"""Install a repo's Claude Code settings where a cloud session reads them.

    python3 tools/setup-session-home.py [--repo DIR] [--target DIR] [--check]

A session with several repositories runs from /home/user, not a repo root,
so it never reads <repo>/.claude/settings.json or <repo>/.claude/agents: the
400k compaction window, the handoff hook and the subagents all sat unused
(2026-10-31). This writes them where that session looks, its project
directory's .claude/ (--target, default $CLAUDE_PROJECT_DIR or /home/user):

  settings.json   the repo's settings, with each hook command that names
                  "$CLAUDE_PROJECT_DIR"/.claude/... pointed at --repo instead,
                  and env CLAUDE_CODE_AUTO_COMPACT_WINDOW set from the repo's
                  autoCompactWindow. Keys the repo does not set are kept.
  agents          a link to <repo>/.claude/agents.
  ccv-setup.json  what was installed, from where, so --check can compare.

--repo is the checkout that holds this agent's handoff (its own worktree);
default, the checkout this script is in. The compiler repo's sessions run
this same script with --repo naming their compiler checkout.
--check changes nothing: it exits 1 and says what differs when the target
does not hold what the repo's settings would install.

Writing a session's own settings is a change to its own permissions surface,
so a person approves the run (the session-home skill says how).
"""
import argparse
import json
import os
import sys
from pathlib import Path

ap = argparse.ArgumentParser()
ap.add_argument("--repo", default=str(Path(__file__).resolve().parent.parent))
ap.add_argument("--target", default=os.environ.get("CLAUDE_PROJECT_DIR") or "/home/user")
ap.add_argument("--check", action="store_true")
a = ap.parse_args()

repo = Path(a.repo).resolve()
src = repo / ".claude/settings.json"
if not src.is_file():
    sys.exit(f"setup-session-home: no {src}")
dot = Path(a.target).resolve() / ".claude"
if dot.resolve() == (repo / ".claude").resolve():
    sys.exit("setup-session-home: the target is the repo itself; nothing to install")

want = json.loads(src.read_text())


def repoint(cmd: str) -> str:
    for form in ('"$CLAUDE_PROJECT_DIR"/', "$CLAUDE_PROJECT_DIR/", "${CLAUDE_PROJECT_DIR}/"):
        cmd = cmd.replace(form, str(repo) + "/")
    return cmd


for groups in want.get("hooks", {}).values():
    for g in groups:
        for h in g.get("hooks", []):
            if "command" in h:
                h["command"] = repoint(h["command"])
if "autoCompactWindow" in want:
    want.setdefault("env", {})["CLAUDE_CODE_AUTO_COMPACT_WINDOW"] = str(want["autoCompactWindow"])

dest = dot / "settings.json"
have = json.loads(dest.read_text()) if dest.is_file() else {}
merged = {**have, **want}
if "env" in have and "env" in want:
    merged["env"] = {**have["env"], **want["env"]}
agents_src = repo / ".claude/agents"
agents = dot / "agents"
record = {"repo": str(repo), "settings": str(src),
          "agents": str(agents_src) if agents_src.is_dir() else None}

if a.check:
    diffs = []
    if have != merged:
        diffs.append(f"{dest} differs from {src} (keys: "
                     + ", ".join(sorted(k for k in merged if have.get(k) != merged[k])) + ")")
    if record["agents"] and not (agents.is_symlink() and agents.resolve() == agents_src.resolve()):
        diffs.append(f"{agents} is not a link to {agents_src}")
    for d in diffs:
        print("setup-session-home: " + d)
    if not diffs:
        print(f"setup-session-home: {dot} matches {repo}")
    sys.exit(1 if diffs else 0)

dot.mkdir(parents=True, exist_ok=True)
dest.write_text(json.dumps(merged, indent=2) + "\n")
if record["agents"]:
    if agents.is_symlink():
        agents.unlink()
    elif agents.exists():
        sys.exit(f"setup-session-home: {agents} exists and is not a link; move it aside first")
    agents.symlink_to(agents_src)
(dot / "ccv-setup.json").write_text(json.dumps(record, indent=2) + "\n")
print(f"setup-session-home: {dest} from {src}"
      + (f"; {agents} -> {agents_src}" if record["agents"] else "")
      + ". The window and hooks apply from the next session start or compaction"
        " this version of Claude Code reloads at; the agents from the next start.")
