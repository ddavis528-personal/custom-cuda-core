#!/bin/bash
# Archived (RCU bank sizing, 2026-11-03): run by hand only; nothing in tools/
# or test/ reads archive/. Each run is one cold unit through check-ngd's own
# synthesis and ABC timing; builds and caches go to build/rcu-bank-sizing/.
#   run.sh            the figures in README.md (about 20 minutes, 2.7 GB peak)
#   run.sh NAME K=V…  one unit, e.g. run.sh s4 ROWS=192 LANES=4
set -uo pipefail
A=$(cd "$(dirname "$0")" && pwd); R=$(cd "$A/../.." && pwd); cd "$R"
m() { python3 "$A/measure.py" "$1" rcu_bank_sz "$A/rcu_bank_sz.sv" "${@:2}"; }
if [ $# -gt 0 ]; then m "$@"; exit; fi
m bank_r32_l8   ROWS=32  LANES=8          # reduced unit for loops
m bank_r192_l2  ROWS=192 LANES=2          # byte slice, 2 lanes
m bank_r192_l4  ROWS=192 LANES=4          # byte slice, 4 lanes (chosen)
m bank_r192_l8  ROWS=192 LANES=8          # byte slice, 8 lanes (heavy)
m lane1_r192    ROWS=192 LANES=4 SECW=8   # lane slice: 1 lane x 4 sections
m r3_oh0        ROWS=192 LANES=4 SECW=32 RP=3 WP=1 ONEHOT=0  # R ports, predecoded
m r3_oh1        ROWS=192 LANES=4 SECW=32 RP=3 WP=1 ONEHOT=1  # R ports, one-hot
