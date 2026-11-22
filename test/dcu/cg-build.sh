#!/usr/bin/env bash
# Builds a DCU RTL unit's bench (test/dcu/cg-units.json) under Verilator,
# assertions on, at the unit's parameters.
# Usage: test/dcu/cg-build.sh <unit> <dir>   (the bench is <dir>/tb)
set -euo pipefail
cd "$(dirname "$0")/../.."
unit=$1 dir=$2
mkdir -p "$dir"
vl() {   # top, -G params, -D defines, RTL files..., bench
  local top=$1 g=$2 d=$3; shift 3
  verilator --cc --exe --build --trace -j 0 -O2 --assert -Wno-fatal -Wno-lint -Wno-style $g \
    --top-module "$top" --Mdir "$dir" -o tb -I"$PWD/rtl/include" -I"$PWD/rtl/generated" \
    -CFLAGS "-std=c++17 -O2 -I$PWD/sim/generated -I$PWD/sim/skel -I$PWD/sim/dcu -I$PWD/sim/include $d" \
    "$PWD/rtl/generated/ccv_params_pkg.sv" "$PWD/rtl/ccv_assert_pkg.sv" "$@"
}
case "$unit" in
  dcu_cap)
    vl dcu_cap "" "" "$PWD/rtl/dcu/dcu_cap.sv" "$PWD/test/dcu/cap_tb.cpp" ;;
  *) echo "cg-build: no unit $unit" >&2; exit 2 ;;
esac
