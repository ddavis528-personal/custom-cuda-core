#!/bin/bash
d=/tmp/claude-0/-home-user/f45e5bc5-a4af-595e-a4dd-e1d6ad6f715c/scratchpad
until grep -q "push rc=" ~/ccv-logs/oi-push-0703.log 2>/dev/null; do sleep 30; done
cd $d/wtf; export PATH="$PWD/tools/shim:$PATH"
for v in r3a r3c; do
  cp $d/ren.$v.sv rtl/ooe/ooe_rename.sv
  echo "== $v"; python3 tools/check-ngd.py --unit ooe_rename 2>&1 | grep -iE "NGD-|error|failed"
done
cp $d/ren.r3.sv rtl/ooe/ooe_rename.sv
echo "== END"
