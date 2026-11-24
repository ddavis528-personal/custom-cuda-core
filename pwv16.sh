#!/bin/bash
SP=/tmp/claude-0/-home-user/f45e5bc5-a4af-595e-a4dd-e1d6ad6f715c/scratchpad
cd /home/user/wt-pwv; export PATH="$PWD/tools/shim:$PATH" CCV_JOBS=1
o=$SP/pwvm16; mkdir -p $o
bash $SP/rob.sh > $o/rob.log 2>&1; echo "rob: $(tail -1 $o/rob.log)"
grep -q 'fail=0' $o/rob.log || exit 1
