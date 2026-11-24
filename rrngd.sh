#!/bin/bash
cd /home/user/custom-cuda-core; SP=/tmp/claude-0/-home-user/f45e5bc5-a4af-595e-a4dd-e1d6ad6f715c/scratchpad
export PATH="$PWD/tools/shim:$PATH"
python3 tools/check-ngd.py --unit ooe_ratread > $SP/ngd-rr-$1.log 2>&1; echo "ngd rc $?"
grep -E "ooe_ratread|NGD-|ratchet|stale" $SP/ngd-rr-$1.log | head -60
