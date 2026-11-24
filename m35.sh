#!/bin/bash
cd /home/user/custom-cuda-core
export PATH=$PWD/tools/shim:$PATH
echo "== ngd"; CCV_ROOT=$PWD python3 /tmp/claude-0/-home-user/f45e5bc5-a4af-595e-a4dd-e1d6ad6f715c/scratchpad/check-ngd3.py --unit ooe_rename 2>&1 | tr '\r' '\n' | grep -i "ooe_rename\|error" | tail -10
echo "== rentb"; bash /tmp/claude-0/-home-user/f45e5bc5-a4af-595e-a4dd-e1d6ad6f715c/scratchpad/rentb.sh 2>&1 | grep -E "PASS|FAIL|missed|fail=" | tail -8
echo "M35-DONE"
