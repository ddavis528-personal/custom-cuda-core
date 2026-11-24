#!/bin/bash
cd /home/user/custom-cuda-core; SP=/tmp/claude-0/-home-user/f45e5bc5-a4af-595e-a4dd-e1d6ad6f715c/scratchpad
export PATH="$PWD/tools/shim:$PATH"
python3 tools/check-ngd.py --unit ooe_rs > $SP/ngd-rs-$1.log 2>&1; echo "ngd rc $?"
grep -E "ooe_rs|flop-flop|NGD-" $SP/ngd-rs-$1.log | head -20
for f in $(grep -l "hh_cq02h" $(ls -t build/synth-cache/abc-*.blif) | head -2); do echo "== $f"; python3 $SP/fo/path3.py rr $PWD/$f 2>&1 | grep -E "over25|  rr " | head -12; done
