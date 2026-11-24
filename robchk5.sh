#!/bin/bash
cd /home/user/wt-rob
export PATH="$PWD/tools/shim:$PATH"
echo "== ngd"; python3 tools/check-ngd.py --unit ooe_rob_w 2>&1 | tail -25
echo "== cg"; python3 tools/check-cg.py --unit ooe_rob_w 2>&1 | tail -25
echo "== END"
