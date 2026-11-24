#!/bin/bash
S=/tmp/claude-0/-home-user/f45e5bc5-a4af-595e-a4dd-e1d6ad6f715c/scratchpad
$S/robrun.sh 2>&1 | grep -E "^rob_tb|BUILD|differs" | head -12
cd $S/wrob; export PATH="$PWD/tools/shim:$PATH"
echo "== ngd rob"; python3 tools/check-ngd.py --unit ooe_rob_w 2>&1 | grep -E "NGD-|PASS|FAIL|cap" | head -20
cd $S/wtf; export PATH="$PWD/tools/shim:$PATH"
echo "== ngd go"; python3 tools/check-ngd.py --unit ooe_go 2>&1 | grep -E "NGD-|PASS|FAIL|cap|flop-flop" | head -30
echo "== END"
