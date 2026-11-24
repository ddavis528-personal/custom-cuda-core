#!/bin/bash
cd /home/user/custom-cuda-core; SP=/tmp/claude-0/-home-user/f45e5bc5-a4af-595e-a4dd-e1d6ad6f715c/scratchpad
export PATH="$PWD/tools/shim:$PATH"
echo "== cg"; python3 tools/check-cg.py --unit ooe_rs > $SP/cg-rs.log 2>&1; echo "cg rc $?"; grep -iE "ooe_rs|FAIL|loose|over" $SP/cg-rs.log | head -20
echo "== ngd ratchet"; python3 tools/check-ngd.py --unit ooe_rs > $SP/ngd-rs-final.log 2>&1; echo "ngd rc $?"; grep -E "NGD-|ratchet|stale" $SP/ngd-rs-final.log | head
echo "== rtl benches"; bash test/ooe/run-rtl.sh > $SP/rtl-rs.log 2>&1; echo "rtl rc $?"; grep -E "FAIL|MISSED" $SP/rtl-rs.log | head; tail -3 $SP/rtl-rs.log
