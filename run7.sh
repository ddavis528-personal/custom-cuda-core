#!/usr/bin/env bash
SP=/tmp/claude-0/-home-user/f45e5bc5-a4af-595e-a4dd-e1d6ad6f715c/scratchpad
cd /home/user/custom-cuda-core
cp $SP/rn-only.sh test/ooe/zz-rn-only.sh
bash test/ooe/zz-rn-only.sh > $SP/rn7.log 2>&1; echo "EXIT $?" >> $SP/rn7.log
rm -f /home/user/custom-cuda-core/test/ooe/zz-rn-only.sh
PATH=$PWD/tools/shim:$PATH python3 tools/check-cg.py --unit ooe_rename > $SP/cg7-full.log 2>&1; echo "EXIT $?" >> $SP/cg7-full.log
grep -E 'ooe_rename|budget|EXIT' $SP/cg7-full.log > $SP/cg7.log
echo DONE >> $SP/cg7.log
