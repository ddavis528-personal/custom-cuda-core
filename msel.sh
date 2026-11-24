#!/bin/bash
for t in /tmp/claude-0/-home-user/f45e5bc5-a4af-595e-a4dd-e1d6ad6f715c/scratchpad/wt-sel; do
 cd $t; echo "== $t"
 PATH=$t/tools/shim:$PATH CCV_ROOT=$t python3 /tmp/claude-0/-home-user/f45e5bc5-a4af-595e-a4dd-e1d6ad6f715c/scratchpad/check-ngd4.py --unit ooe_sched 2>&1 | tr '\r' '\n' | grep -i "ooe_sched\|error" | tail -14
done
echo MSEL-DONE
