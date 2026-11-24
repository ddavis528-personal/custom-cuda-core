#!/bin/bash
cd /home/user/custom-cuda-core; SP=/tmp/claude-0/-home-user/f45e5bc5-a4af-595e-a4dd-e1d6ad6f715c/scratchpad
bash test/ooe/run-rtl.sh > $SP/rtl-b.log 2>&1; echo "rtl rc $?"; grep -iE "rat|FAIL|MISSED" $SP/rtl-b.log | head -20; tail -2 $SP/rtl-b.log
