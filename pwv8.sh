#!/bin/bash
SP=/tmp/claude-0/-home-user/f45e5bc5-a4af-595e-a4dd-e1d6ad6f715c/scratchpad
cd /home/user/wt-pwv; export PATH="$PWD/tools/shim:$PATH" CCV_JOBS=1
o=$SP/pwvm8; mkdir -p $o
python3 tools/check-ngd.py --unit ooe_rob_w > $o/ngd.ooe_rob_w.log 2>&1; echo "ngd rob_w rc=$?"
grep -E "NGD-(1|3|7) " $o/ngd.ooe_rob_w.log
