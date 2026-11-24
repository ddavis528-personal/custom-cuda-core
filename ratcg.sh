#!/bin/bash
cd /home/user/custom-cuda-core
export PATH="$PWD/tools/shim:$PATH"
python3 tools/check-cg.py --unit ooe_rat 2>&1 | tail -15
echo "cg rc ${PIPESTATUS[0]}"
