#!/bin/bash
cd /home/user/custom-cuda-core; SP=/tmp/claude-0/-home-user/f45e5bc5-a4af-595e-a4dd-e1d6ad6f715c/scratchpad
export PATH="$PWD/tools/shim:$PATH"
echo "== cg"; python3 tools/check-cg.py --unit ooe_rs > $SP/cg-rs2.log 2>&1; echo "cg rc $?"; grep -vE "^\s+CG-1 .*written every cycle" $SP/cg-rs2.log | head -20
echo "== ngd"; python3 tools/check-ngd.py --unit ooe_rs > $SP/ngd-rs-final2.log 2>&1; echo "ngd rc $?"; grep -E "flop-flop|NGD-" $SP/ngd-rs-final2.log | head
