#!/bin/bash
cd /home/user/custom-cuda-core; SP=/tmp/claude-0/-home-user/f45e5bc5-a4af-595e-a4dd-e1d6ad6f715c/scratchpad
export PATH="$PWD/tools/shim:$PATH"
python3 tools/check-ngd.py --unit ooe_rendep > $SP/ngd-rd-$1.log 2>&1; echo "ngd rc $?"
grep -E "unit ooe_rendep|flop-flop|without|NGD-|  in " $SP/ngd-rd-$1.log | head -30
for f in $(grep -l "gsn_cq01h" $(ls -t build/synth-cache/abc-*.blif) | head -2); do echo "== $f"
 for s in gsn_cq01h psn_cq01h gnt_idx_cq01h gnt_v_cq01h; do echo "-- $s"; START=$s python3 $SP/fo/path3.py ir $PWD/$f 2>&1 | head -40; done; done
