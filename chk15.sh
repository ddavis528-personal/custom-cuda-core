#!/bin/bash
d=/tmp/claude-0/-home-user/f45e5bc5-a4af-595e-a4dd-e1d6ad6f715c/scratchpad
$d/robrun.sh 2>&1 | grep -E "^rob_tb|BUILD|rror|differs"
cd $d/wrob; export PATH="$PWD/tools/shim:$PATH"
echo "== cg"; python3 tools/check-cg.py --unit ooe_rob_w > $d/cg15.log 2>&1; echo "cg rc=$?"; grep "ooe_rob_w" $d/cg15.log | grep -v "^ *CG-1 " | tail -12
echo "== END"
