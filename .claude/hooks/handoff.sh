#!/bin/sh
# SessionStart (matcher "compact"): print this session's handoff so it is the
# first thing in the context after a compaction. The session's prefix comes
# from the register roster, which lives in custom-cuda-core
# (docs/register/roster.json); the handoff is .claude/handoff/<PREFIX>.md,
# which its agent keeps current. Copied unchanged into another repo, the
# script reads the roster from $CCV_ROSTER, then that repo's own
# docs/register/roster.json (a copy its owner checks against core's in the
# daily sweep), then a custom-cuda-core checkout beside the repo.
# Usage: handoff.sh [session-id]; default $CLAUDE_CODE_REMOTE_SESSION_ID.
root=$(cd "$(dirname "$0")/../.." && pwd)
sid=${1:-${CLAUDE_CODE_REMOTE_SESSION_ID:-}}
exec python3 -I - "$root" "$sid" <<'PY'
import json, os, sys
from pathlib import Path
root, sid = Path(sys.argv[1]), sys.argv[2]
# A cloud session's id reads cse_X in its own environment, session_X elsewhere.
sid = "session_" + sid.split("_", 1)[1] if "_" in sid else sid
paths = [os.environ.get("CCV_ROSTER", ""), root / "docs/register/roster.json",
         root.parent / "custom-cuda-core/docs/register/roster.json"]
roster = next((Path(p) for p in paths if p and Path(p).is_file()), None)
if roster is None:
    print("handoff: no register roster found (see .claude/hooks/handoff.sh); no handoff loaded.")
    sys.exit(0)
try:
    agents = json.loads(roster.read_text())["agents"]
except (OSError, ValueError, KeyError):
    agents = {}
prefix = next((p for p, a in agents.items() if a.get("session") == sid), None)
if prefix is None:
    print(f"handoff: session {sid or '(unknown)'} is not in the register roster ({roster}); no handoff loaded.")
    sys.exit(0)
f = root / ".claude/handoff" / f"{prefix}.md"
if not f.is_file():
    print(f"handoff: no {f.relative_to(root)} for {prefix}. Write it now (custom-cuda-core CLAUDE.md, Context and handoff).")
    sys.exit(0)
print(f"handoff: {prefix}'s handoff, {f.relative_to(root)}, re-read after compaction.\n")
print(f.read_text())
PY
