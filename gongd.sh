#!/bin/bash
d=/tmp/claude-0/-home-user/f45e5bc5-a4af-595e-a4dd-e1d6ad6f715c/scratchpad
until grep -q "== END" $d/chk12.out 2>/dev/null; do sleep 15; done
cd $d/wtf; export PATH="$PWD/tools/shim:$PATH"
python3 tools/check-ngd.py --unit ooe_go > $d/gongd2.out 2>&1; echo "rc=$?" >> $d/gongd2.out
