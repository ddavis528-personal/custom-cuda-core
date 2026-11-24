#!/bin/bash
# usage: strag.sh <outdir> [break]
cd /home/user/wt-5b; O=$1; B=$2; mkdir -p $O
for k in build/oracle/*/; do n=$(basename $k)
  CCV_RAU_DEMOTE=mlc timeout 600 build/skel/ccv-skel --kernel $k/oracle.jsonl ${B:+--break $B} > $O/$n.log 2>&1
  echo "$n $(grep -o 'finished=[01].*check_failures=[0-9]*' $O/$n.log | head -1) strag=$(grep -o 'decq_straggler=[0-9]*' $O/$n.log|head -1) beat=$(grep -o 'decq_straggler_beat=[0-9]*' $O/$n.log|head -1) demote=$(grep -o ' demote=[0-9]*' $O/$n.log|head -1)"
done > $O/summary.txt
