#!/bin/bash
d=/tmp/claude-0/-home-user/f45e5bc5-a4af-595e-a4dd-e1d6ad6f715c/scratchpad
until grep -q "== END" $d/chk15.out 2>/dev/null; do sleep 15; done
cd $d/wtf; export PATH="$PWD/tools/shim:$PATH"
echo "== ngd rename"; python3 tools/check-ngd.py --unit ooe_rename > $d/ngdren16.log 2>&1; echo "rc=$?"; grep -iE "NGD-|error|failed" $d/ngdren16.log
echo "== unit"; tools/check-ooe-unit.sh > $d/unit16.log 2>&1; echo "rc=$?"; grep -iE "PASS|FAIL|not caught|mismatch" $d/unit16.log | tail -8
echo "== END"
