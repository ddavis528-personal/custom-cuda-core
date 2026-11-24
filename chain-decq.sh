#!/bin/bash
while [ "$(ps -eo args | grep -c '[g]ate-push.sh')" != 0 ]; do sleep 60; done
cd /tmp/claude-0/-home-user/f45e5bc5-a4af-595e-a4dd-e1d6ad6f715c/scratchpad/wtd
git fetch -q origin ccr-57eff422-5tdecg
if ! git merge-base --is-ancestor origin/ccr-57eff422-5tdecg HEAD; then
  git merge -q --no-edit origin/ccr-57eff422-5tdecg -m "Merge origin/ccr-57eff422-5tdecg into oi-decq-lag

Co-Authored-By: Claude Opus 5.5 <noreply@anthropic.com>
Claude-Session: https://claude.ai/code/session_01DMw4FtFbGoVboMGxWpLBuv" || { echo "chain: merge of the branch tip conflicted; stopped"; exit 3; }
fi
CCV_PUSH_BRANCHES=ccr-57eff422-5tdecg tools/gate-push.sh
