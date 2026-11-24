#!/bin/bash
SP=/tmp/claude-0/-home-user/f45e5bc5-a4af-595e-a4dd-e1d6ad6f715c/scratchpad
cd /home/user/custom-cuda-core
export PATH=$PWD/tools/shim:$PATH
echo "== ngd"; CCV_ROOT=$PWD python3 $SP/check-ngd3.py --unit ooe_rob_w 2>&1 | tr '\r' '\n' | grep "unit ooe_rob_w\|NGD-[0-9] ooe_rob_w\|rror"
echo "== cg"; python3 tools/check-cg.py --unit ooe_rob_w 2>&1 | tr '\r' '\n' | grep -v "^\s*$" | grep "ooe_rob_w\|rror\|FAIL\|budget\|allow" | head -30
echo "== END"
