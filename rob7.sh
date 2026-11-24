#!/bin/bash
SP=/tmp/claude-0/-home-user/f45e5bc5-a4af-595e-a4dd-e1d6ad6f715c/scratchpad
$SP/robrun5.sh > $SP/rr7.log 2>&1
grep -q "MISSED\|BUILD FAIL\|mismatches=[1-9]" $SP/rr7.log && { echo BENCH-BAD; exit 1; }
echo BENCH-OK
cd /home/user/wt-rob
PATH=$PWD/tools/shim:$PATH CCV_ROOT=$PWD python3 $SP/check-ngd3.py --unit ooe_rob_w 2>&1 | tr '\r' '\n' | grep "unit ooe_rob_w\|NGD-[0-9] ooe_rob_w"
echo "== END"
