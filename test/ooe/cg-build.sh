#!/usr/bin/env bash
# Builds an OOE clock-gating unit's bench (test/ooe/cg-units.json): the
# module's live-model bench with tracing on, at the parameters
# test/ooe/run-rtl.sh derives, so a unit and the lockstep run cannot drift.
# Usage: test/ooe/cg-build.sh <unit> <dir>   (the bench is <dir>/tb)
set -euo pipefail
cd "$(dirname "$0")/../.."
unit=$1 dir=$2
pkg=rtl/generated/ccv_params_pkg.sv
val() { sed -n "s/.*localparam int $1 = \([0-9]*\);.*/\1/p" "$pkg"; }
n_rcu=$(val CCV_P_RS_RCU) n_miu=$(val CCV_P_RS_MIU) width=$(val CCV_ISSUE_WIDTH)
n=$((n_rcu + n_miu))
mkdir -p "$dir"
vl() {   # top, -G params, -D defines, RTL files..., bench
  local top=$1 g=$2 d=$3; shift 3
  verilator --cc --exe --build --trace -j 0 -O2 --assert -Wno-fatal -Wno-lint -Wno-style $g \
    --top-module "$top" --Mdir "$dir" -o tb -I"$PWD/rtl/include" -I"$PWD/rtl/generated" \
    -CFLAGS "-std=c++17 -O2 $d -DOOE_TEST_AS_LIBRARY -I$PWD/sim/generated -I$PWD/sim/ooe -I$PWD/test/ooe" \
    "$PWD/rtl/ccv_assert_pkg.sv" "$@" "$PWD/sim/ooe/ooe_core.cpp" "$PWD/sim/ooe/ooe_test.cpp"
}
case "$unit" in
  ooe_confirm)
    vl ooe_confirm "-GN=$n" "-DCONFIRM_N=$n" "$PWD/rtl/ooe/ooe_confirm.sv" "$PWD/test/ooe/confirm_tb.cpp" ;;
  ooe_wake)
    read -r g d < <(python3 test/ooe/wake-params.py)
    vl ooe_wake "${g//,/ }" "${d//,/ }" "$PWD/rtl/ooe/ooe_wake.sv" "$PWD/test/ooe/wake_tb.cpp" ;;
  ooe_age_rcu|ooe_age_miu)
    if [ "$unit" = ooe_age_rcu ]; then cls=0 na=$n_rcu; else cls=1 na=$n_miu; fi
    vl ooe_age "-GN=$na -GA=$width" "-DAGE_N=$na -DAGE_A=$width -DAGE_CLS=$cls" \
      "$PWD/rtl/ooe/ooe_age.sv" "$PWD/test/ooe/age_tb.cpp" ;;
  ooe_rs)
    vl ooe_rs "-GN=$n -GNR=$n_rcu -GA=$width" "-DRS_N=$n -DRS_NR=$n_rcu -DRS_A=$width" \
      "$PWD/rtl/ooe/ooe_rs.sv" "$PWD/test/ooe/rs_tb.cpp" ;;
  *) echo "cg-build: no unit $unit" >&2; exit 2 ;;
esac
