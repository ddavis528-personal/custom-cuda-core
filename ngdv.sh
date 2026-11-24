#!/bin/bash
# usage: ngdv.sh <tag> : check-ngd ooe_sched, then exact depths
cd /home/user/custom-cuda-core; SP=/tmp/claude-0/-home-user/f45e5bc5-a4af-595e-a4dd-e1d6ad6f715c/scratchpad
export PATH="$PWD/tools/shim:$PATH"
python3 tools/check-ngd.py --unit ooe_sched > $SP/ngd-$1.log 2>&1
grep -E "flop-flop|NGD-" $SP/ngd-$1.log
f=$(grep -l "cret_cq02h" $(ls -t build/synth-cache/abc-*.blif) | head -1)
for s in cidx_cq03h chas_cq03h sdep_cq03h res_cq03h vel_cq03h siss_cq03h sslot_cq03h; do echo "$s $(START=$s python3 $SP/fo/path3.py ir $f 2>&1 | grep '  ir ' | head -1)"; done
