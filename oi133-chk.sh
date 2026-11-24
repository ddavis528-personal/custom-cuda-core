#!/bin/bash
cd /home/user/custom-cuda-core
export PATH="$PWD/tools/shim:$PATH"
S=/tmp/claude-0/-home-user/f45e5bc5-a4af-595e-a4dd-e1d6ad6f715c/scratchpad
test/ooe/run-rtl.sh > $S/m-rtl.log 2>&1; echo "RTL EXIT $?" >> $S/m-rtl.log
for u in ooe_rs ooe_wake ooe_sched; do python3 tools/check-ngd.py --unit $u > $S/m-ngd-$u.log 2>&1; echo "EXIT $?" >> $S/m-ngd-$u.log; done
for u in ooe_rs ooe_wake; do python3 tools/check-cg.py --unit $u > $S/m-cg-$u.log 2>&1; echo "EXIT $?" >> $S/m-cg-$u.log; done
echo ALLDONE > $S/m-done
