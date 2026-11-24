#!/bin/bash
d=/tmp/claude-0/-home-user/f45e5bc5-a4af-595e-a4dd-e1d6ad6f715c/scratchpad
until grep -q "== END\|BUILD FAIL" $d/chk13.out 2>/dev/null; do sleep 15; done
$d/gorun.sh 2>&1 | grep -iE "^go_tb|BUILD|error"
cd $d/wtf; export PATH="$PWD/tools/shim:$PATH"
echo "== ngd go"; python3 tools/check-ngd.py --unit ooe_go 2>&1 | grep -iE "NGD-|error|failed"
echo "== ngd rename"; python3 tools/check-ngd.py --unit ooe_rename 2>&1 | grep -iE "NGD-|error|failed"
echo "== unit"; tools/check-ooe-unit.sh 2>&1 | tail -3
echo "== END"
