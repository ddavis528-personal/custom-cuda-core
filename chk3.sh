#!/bin/bash
S=/tmp/claude-0/-home-user/f45e5bc5-a4af-595e-a4dd-e1d6ad6f715c/scratchpad
cd $S/wtf; export PATH="$PWD/tools/shim:$PATH"
echo "== ngd go"; python3 tools/check-ngd.py --unit ooe_go 2>&1 | tail -30
cd /home/user/custom-cuda-core; git status --short | head -3; git log --oneline -1
export PATH="$PWD/tools/shim:$PATH"
echo "== ngd rob base"; python3 tools/check-ngd.py --unit ooe_rob_w 2>&1 | grep -E "NGD-|rror" | head
echo "== END"
