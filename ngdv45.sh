#!/bin/bash
cd /home/user/custom-cuda-core
for v in v4 v5; do cp /tmp/claude-0/-home-user/f45e5bc5-a4af-595e-a4dd-e1d6ad6f715c/scratchpad/sel_$v.sv rtl/ooe/ooe_select.sv; echo "#### $v"; /tmp/claude-0/-home-user/f45e5bc5-a4af-595e-a4dd-e1d6ad6f715c/scratchpad/ngdv.sh $v; done
echo EXIT
