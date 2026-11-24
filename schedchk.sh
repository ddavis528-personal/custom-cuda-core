#!/bin/bash
cd /home/user/custom-cuda-core
export PATH="$PWD/tools/shim:$PATH"
echo "== cg"; python3 tools/check-cg.py --unit ooe_sched 2>&1 | tail -40
echo "== ngd"; python3 tools/check-ngd.py --unit ooe_sched 2>&1 | tail -60
