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
  ooe_decq)
    slots=$(val CCV_TIER1_WARPS) dq=$(val CCV_P_DECQ) dqw=$(val CCV_P_DECQ_WARP_MAX)
    uops=$(python3 -c "import json; print(next(c['rate'] for c in json.load(open('schema/interfaces.json'))['channels'] if c['name'] == 'ccv_dec_ooe_uop'))")
    vl ooe_decq "-GS=$slots -GQ=$dq -GD=$dqw -GE=$uops -GR=$width -GP=16" \
      "-DDQ_S=$slots -DDQ_Q=$dq -DDQ_D=$dqw -DDQ_E=$uops -DDQ_R=$width" \
      "$PWD/rtl/ooe/ooe_decq.sv" "$PWD/test/ooe/decq_tb.cpp" ;;
  ooe_freelist_gpr|ooe_freelist_pred)
    if [ "$unit" = ooe_freelist_gpr ]; then pool=0 nf=$(val CCV_P_PHYS_REGS); else pool=1 nf=$(val CCV_P_PRED_REGS); fi
    fb=$(sed -n 's/.*unsigned fl_buf = \([0-9]*\);.*/\1/p' sim/ooe/ooe_core.h)
    fk=$(sed -n 's/.*unsigned fl_banks = \([0-9]*\);.*/\1/p' sim/ooe/ooe_core.h)
    vl ooe_freelist "-DCCV_CHECK -GN=$nf -GA=$width -GB=$fb -GK=$fk" "-DFL_N=$nf -DFL_A=$width -DFL_B=$fb -DFL_K=$fk -DFL_POOL=$pool" \
      "$PWD/rtl/ooe/ooe_freelist.sv" "$PWD/test/ooe/freelist_tb.cpp" ;;
  ooe_rat)
    read -r g d < <(python3 test/ooe/rat-params.py)
    vl ooe_rat_read "${g//,/ }" "${d//,/ }" "$PWD/rtl/ooe/ooe_rat.sv" "$PWD/rtl/ooe/ooe_ratread.sv" \
      "$PWD/test/ooe/ooe_rat_read.sv" "$PWD/test/ooe/rat_tb.cpp" ;;
  ooe_sched)
    slots=$(val CCV_TIER1_WARPS)
    fb=$(sed -n 's/.*unsigned pick_fallback = \([0-9]*\);.*/\1/p' sim/ooe/ooe_core.h)
    vl ooe_sched "--public-flat-rw -GN=$n -GNR=$n_rcu -GS=$slots -GFB=$fb" "-DSCH_N=$n -DSCH_NR=$n_rcu -DSCH_S=$slots" \
      "$PWD/rtl/ooe/ooe_ready.sv" "$PWD/rtl/ooe/ooe_pick.sv" "$PWD/rtl/ooe/ooe_select.sv" "$PWD/rtl/ooe/ooe_sched.sv" \
      "$PWD/test/ooe/sched_tb.cpp" ;;
  *) echo "cg-build: no unit $unit" >&2; exit 2 ;;
esac
