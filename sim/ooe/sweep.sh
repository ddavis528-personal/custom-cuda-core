#!/usr/bin/env bash
# The OOE sizing sweep (strategy §8 4b; docs/ooe-model.md, "Sweeps"):
#   1. every S1 kernel on the C++ skeleton, the stub against the model, and
#      the model across its knobs (CCV_OOE_CONFIG), in cycles;
#   2. synthetic four-warp traces on the core alone (ooe-test --sweep).
# Needs build/skel/ccv-skel (tools/check-skel.sh) and the oracles
# (tools/gen-oracle.sh). Writes markdown to stdout.
set -euo pipefail
cd "$(dirname "$0")/../.."
SKEL=build/skel/ccv-skel
KERNELS="vadd sel srd pguard merge mload unal gather loop brs"
cyc() { "$SKEL" --kernel "build/oracle/$1/oracle.jsonl" 2>/dev/null |
        tr ' ' '\n' | sed -n 's/^cycles=//p'; }
echo "### S1 kernels: cycles"
echo
printf '| config |'; for k in $KERNELS; do printf ' %s |' "$k"; done; echo
printf '|---|'; for k in $KERNELS; do printf -- '---|'; done; echo
row() {
  printf '| %s |' "$1"
  for k in $KERNELS; do printf ' %s |' "$(cyc "$k")"; done; echo
}
CCV_OOE_IMPL=stub row "S1 stub (in order)"
row "model, S1 modes"
for kv in rs_rcu=4 rs_rcu=8 rs_miu=2 rob_depth=8 rob_depth=16 decq=4 rename_width=1 \
          rename_width=2 retire_per_rob=1 lat_lane=9 lat_rcu=5; do
  CCV_OOE_CONFIG=$kv row "model, $kv"
done
echo
echo "### Synthetic, four warps, bypass and L1 speculation on (core alone)"
echo
mkdir -p build/ooe
g++ -std=c++17 -O2 -Isim/generated -Isim/ooe sim/ooe/ooe_core.cpp sim/ooe/ooe_test.cpp \
    -o build/ooe/ooe-test
build/ooe/ooe-test --sweep
