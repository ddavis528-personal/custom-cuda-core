#!/bin/bash
d=/tmp/claude-0/-home-user/f45e5bc5-a4af-595e-a4dd-e1d6ad6f715c/scratchpad
until grep -q "== END" $d/chk14.out 2>/dev/null; do sleep 15; done
cd $d/wrob; export PATH="$PWD/tools/shim:$PATH"
for v in A B; do
  cp $d/rob_w.v$v.sv rtl/ooe/ooe_rob_w.sv
  echo "== $v"; python3 tools/check-ngd.py --unit ooe_rob_w 2>&1 | grep -iE "NGD-|error|failed"
done
cp $d/rob_w.v6.sv rtl/ooe/ooe_rob_w.sv
echo "== END"
