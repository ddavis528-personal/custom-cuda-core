#!/bin/bash
cd /home/user/custom-cuda-core
git show HEAD:rtl/ooe/ooe_select.sv > rtl/ooe/ooe_select.sv; git show HEAD:rtl/ooe/ooe_sched.sv > rtl/ooe/ooe_sched.sv
/tmp/claude-0/-home-user/f45e5bc5-a4af-595e-a4dd-e1d6ad6f715c/scratchpad/ngdv.sh base
cp /tmp/claude-0/-home-user/f45e5bc5-a4af-595e-a4dd-e1d6ad6f715c/scratchpad/sel_v2.sv rtl/ooe/ooe_select.sv; cp /tmp/claude-0/-home-user/f45e5bc5-a4af-595e-a4dd-e1d6ad6f715c/scratchpad/sched_cur.sv rtl/ooe/ooe_sched.sv
echo EXIT
