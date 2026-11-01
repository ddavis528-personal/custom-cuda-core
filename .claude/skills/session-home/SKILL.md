---
name: session-home
description: Install this repo's Claude Code settings (the 400k compaction window, the handoff hook, the subagents) where a cloud session actually reads them, and check they are still there. Use at session start, when `tools/setup-session-home.py --check` fails in a sweep, after `.claude/settings.json` or `.claude/agents/` change, and when a subagent type is "not found".
---

# Session home: settings a multi-repo session can see

A cloud session with more than one repository runs from `/home/user`, not
from a repo root, so it reads `/home/user/.claude/`, not
`<repo>/.claude/settings.json` or `<repo>/.claude/agents/`. Until this is
installed, the repo's `autoCompactWindow`, the handoff hook (CLAUDE.md,
Context and handoff) and the subagents do nothing in that session
(2026-10-31). Each session has its own container and its own `/home/user`,
which persists across container restarts, so each agent installs once and
checks daily.

## 1. Install (each agent, once per session)

From the checkout that holds your own handoff (your worktree):

```
python3 tools/setup-session-home.py                      # custom-cuda-core sessions
python3 /home/user/custom-cuda-core/tools/setup-session-home.py \
    --repo /home/user/<your compiler checkout>           # custom-cuda-complier sessions
```

It writes `/home/user/.claude/settings.json` (the repo's settings, hook
commands pointed at your checkout, `CLAUDE_CODE_AUTO_COMPACT_WINDOW` in
`env`, other keys kept), links `/home/user/.claude/agents` to the repo's
definitions, and records what it did in `/home/user/.claude/ccv-setup.json`.

**It needs Daniel's approval.** Writing a session's own settings is a change
to its own configuration, and the session's permission checks refuse it
without a person. Ask in your report, in one line: "session-home: approve
`python3 tools/setup-session-home.py` (writes /home/user/.claude)". Never
work around a refusal: no other tool, path or script to the same files.

## 2. Check (daily sweep, and after any merge that touches .claude/)

```
python3 tools/setup-session-home.py --check
```

Read-only: exit 0 `matches`, or exit 1 naming what differs. On 1, ask for
section 1 again in your report. A merge that changes `.claude/settings.json`
or adds a definition to `.claude/agents/` is what makes it differ.

## 3. When it takes effect

- **Subagents:** from the next session start. Until then, spawn a
  general-purpose agent with the definition's `model` and its body as the
  prompt (CLAUDE.md).
- **The window and the hook:** from the next session start at the latest;
  this version of Claude Code may also reload settings sooner. Until the
  window holds, Daniel can type `/autocompact 400000` in the session, and
  `/compact` compacts it once, now.
- Verify the hook without compacting: run the command that
  `/home/user/.claude/settings.json` names under `SessionStart`; it prints
  your handoff.

## 4. Keeping it scalable

- One source of truth: the repo's `.claude/settings.json` and
  `.claude/agents/`. Never edit `/home/user/.claude/settings.json` by hand;
  change the repo and rerun section 1.
- A new agent needs nothing new: its prefix in `docs/register/roster.json`,
  its `.claude/handoff/<PREFIX>.md`, then sections 1 and 2.
- custom-cuda-complier keeps its own `.claude/settings.json` (CP's, the same
  keys) and runs this repo's script against it.
