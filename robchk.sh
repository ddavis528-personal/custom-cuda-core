#!/bin/bash
cd /tmp/claude-0/-home-user/f45e5bc5-a4af-595e-a4dd-e1d6ad6f715c/scratchpad/wrob
export PATH="$PWD/tools/shim:$PATH"
echo "== ngd"; python3 tools/check-ngd.py --unit ooe_rob_w 2>&1 | tail -25
echo "== cg"; python3 tools/check-cg.py --unit ooe_rob_w 2>&1 | tail -25
echo "== END"
