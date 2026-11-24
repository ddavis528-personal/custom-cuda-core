#!/bin/bash
cd /tmp/claude-0/-home-user/f45e5bc5-a4af-595e-a4dd-e1d6ad6f715c/scratchpad/wrob && CCV_PUSH_BRANCHES=ccr-57eff422-5tdecg tools/gate-push.sh --full > ~/ccv-logs/oi-push-sweep1106.log 2>&1
echo "push rc=$?" >> ~/ccv-logs/oi-push-sweep1106.log
