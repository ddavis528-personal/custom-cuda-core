#!/bin/bash
cd /home/user/custom-cuda-core; SP=/tmp/claude-0/-home-user/f45e5bc5-a4af-595e-a4dd-e1d6ad6f715c/scratchpad
export PATH="$PWD/tools/shim:$PATH"
python3 tools/check-ngd.py --unit ooe_rob_w > $SP/ngd-rob-$1.log 2>&1; echo "ngd rc $?"
grep -E "unit ooe_rob_w|without|to flops +(2[0-9])|NGD-|stale" $SP/ngd-rob-$1.log | head -30
for f in $(grep -l "fl_v_cq02h" $(ls -t build/synth-cache/abc-*.blif) | head -2); do echo "== $f"
 echo "-- rr"; timeout 900 python3 $SP/fo/path3.py rr $PWD/$f 2>&1 | head -24
 for s in al_n_cq02h dn_tag_cq02h fl_slot_cq02h fl_v_cq02h; do echo "-- $s"; START=$s timeout 900 python3 $SP/fo/path3.py ir $PWD/$f 2>&1 | head -22; done; done
