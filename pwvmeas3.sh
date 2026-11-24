#!/bin/bash
cd /home/user/wt-pwv
export PATH="$PWD/tools/shim:$PATH" CCV_JOBS=1
o=/tmp/claude-0/-home-user/f45e5bc5-a4af-595e-a4dd-e1d6ad6f715c/scratchpad/pwvm3; mkdir -p $o
for u in ooe_redir ooe_rob_w ooe_rob_w_1 ooe_rob_w_2 ooe_rob_w_3; do
  for c in ngd cg; do
    [ -s $o/$c.$u.rc ] && continue
    python3 tools/check-$c.py --unit $u > $o/$c.$u.log 2>&1; echo $? > $o/$c.$u.rc
    echo "$c $u rc=$(cat $o/$c.$u.rc)"
  done
done
