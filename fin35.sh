#!/bin/bash
cd /home/user/custom-cuda-core
export PATH=$PWD/tools/shim:$PATH
echo "== ooe-unit"; bash tools/check-ooe-unit.sh 2>&1 | tail -6
echo "== cg"; python3 tools/check-cg.py --unit ooe_rename 2>&1 | tr '\r' '\n' | grep -v "^\s*$" | tail -15
echo "== ngd"; CCV_ROOT=$PWD python3 /tmp/claude-0/-home-user/f45e5bc5-a4af-595e-a4dd-e1d6ad6f715c/scratchpad/check-ngd3.py --unit ooe_rename 2>&1 | tr '\r' '\n' | grep -i "ooe_rename\|error\|fail" | tail -10
echo "EXIT-FIN"
