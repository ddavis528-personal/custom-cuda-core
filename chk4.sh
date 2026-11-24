#!/bin/bash
S=/tmp/claude-0/-home-user/f45e5bc5-a4af-595e-a4dd-e1d6ad6f715c/scratchpad
$S/gorun.sh 2>&1 | grep -iE "^go_tb|BUILD|error"
cd $S/wtf; export PATH="$PWD/tools/shim:$PATH"
echo "== ngd go"; python3 tools/check-ngd.py --unit ooe_go 2>&1 | grep -iE "NGD-|error|failed"
echo "== END"
