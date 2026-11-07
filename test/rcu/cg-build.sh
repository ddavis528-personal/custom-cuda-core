#!/usr/bin/env bash
# Builds an RCU RTL unit's bench (test/rcu/cg-units.json) under Verilator,
# assertions on, at the unit's parameters.
# Usage: test/rcu/cg-build.sh <unit> <dir>   (the bench is <dir>/tb)
set -euo pipefail
cd "$(dirname "$0")/../.."
unit=$1 dir=$2
mkdir -p "$dir"
vl() {   # top, -G params, -D defines, RTL files..., bench
  local top=$1 g=$2 d=$3; shift 3
  verilator --cc --exe --build --trace -j 0 -O2 --assert -Wno-fatal -Wno-lint -Wno-style $g \
    --top-module "$top" --Mdir "$dir" -o tb -I"$PWD/rtl/include" -I"$PWD/rtl/generated" \
    -CFLAGS "-std=c++17 -O2 $d" \
    "$PWD/rtl/generated/ccv_params_pkg.sv" "$PWD/rtl/ccv_assert_pkg.sv" "$@"
}
case "$unit" in
  rcu_bank_slice_r32|rcu_bank_slice|rcu_bank_slice_r32_sec)
    rows=192 k=1 fr=1
    case "$unit" in *_r32*) rows=32 ;; esac
    case "$unit" in *_sec) fr=0 ;; esac
    vl rcu_bank_slice "-GROWS=$rows -GK=$k -GFULL_ROW=$fr" \
      "-DBS_ROWS=$rows -DBS_K=$k -DBS_FULL_ROW=$fr" \
      "$PWD/rtl/rcu/rcu_bank_slice.sv" "$PWD/test/rcu/bank_slice_tb.cpp" ;;
  rcu_r)
    vl rcu_r "" "" "$PWD/rtl/rcu/rcu_xbar.sv" "$PWD/rtl/rcu/rcu_r.sv" "$PWD/test/rcu/r_tb.cpp" ;;
  rcu_pred)
    vl rcu_pred "" "" "$PWD/rtl/rcu/rcu_pred.sv" "$PWD/test/rcu/pred_tb.cpp" ;;
  rcu_kill)
    vl rcu_kill "" "-I$PWD/sim/generated" "$PWD/rtl/rcu/rcu_kill.sv" "$PWD/test/rcu/kill_tb.cpp" ;;
  rcu_mig)
    vl rcu_mig "" "-I$PWD/sim/generated" "$PWD/rtl/rcu/rcu_mig.sv" "$PWD/test/rcu/mig_tb.cpp" ;;
  rcu_mem|rcu_mem_c4)
    cp=32; [ "$unit" = rcu_mem_c4 ] && cp=4
    vl rcu_mem "-GCOPIES=$cp" "-DMM_COPIES=$cp" \
      "$PWD/rtl/rcu/rcu_mem.sv" "$PWD/test/rcu/mem_tb.cpp" ;;
  rcu_lanes|rcu_lanes_c4)
    cp=32; [ "$unit" = rcu_lanes_c4 ] && cp=4
    vl rcu_lanes "-GCOPIES=$cp" "-I$PWD/sim/generated -DLN_COPIES=$cp" \
      "$PWD/rtl/rcu/rcu_lanes.sv" "$PWD/test/rcu/lanes_tb.cpp" ;;
  *) echo "cg-build: no unit $unit" >&2; exit 2 ;;
esac
