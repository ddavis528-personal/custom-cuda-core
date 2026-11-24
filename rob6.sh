#!/bin/bash
SP=/tmp/claude-0/-home-user/f45e5bc5-a4af-595e-a4dd-e1d6ad6f715c/scratchpad
$SP/robrun5.sh > $SP/rr6.log 2>&1
grep -q "MISSED\|BUILD FAIL\|mismatches=[1-9]" $SP/rr6.log && { echo BENCH-BAD; exit 1; }
$SP/robchk5.sh
