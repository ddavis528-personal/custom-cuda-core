#!/usr/bin/env bash
SP=/tmp/claude-0/-home-user/f45e5bc5-a4af-595e-a4dd-e1d6ad6f715c/scratchpad
cd /home/user/custom-cuda-core
export PATH=$PWD/tools/shim:$PATH
for u in ooe_freelist_gsec_fs1 ooe_freelist_pred_fs1; do
  python3 tools/check-cg.py --unit $u > $SP/cg-$u.log 2>&1; echo "EXIT $?" >> $SP/cg-$u.log
  python3 $SP/check-ngd3.py --unit $u > $SP/ngd-$u.log 2>&1; echo "EXIT $?" >> $SP/ngd-$u.log
done
echo DONE > $SP/fs1.done
