#!/usr/bin/env bash
cd /home/user/custom-cuda-core
export PATH="$PWD/tools/shim:$PATH"
for u in ooe_rob_w_3 ooe_rob_w_2 ooe_rob_w_1; do
  echo "== ngd $u"; python3 tools/check-ngd.py --unit $u 2>&1 | tail -25
done
for u in ooe_rob_w_3 ooe_rob_w_2 ooe_rob_w_1; do
  echo "== cg $u"; python3 tools/check-cg.py --unit $u 2>&1 | tail -10
done
