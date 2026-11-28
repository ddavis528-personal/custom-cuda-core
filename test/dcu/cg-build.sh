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
  dcu_btag)
    vl dcu_btag "" "" "$PWD/rtl/macro/ccv_common_rf_1r1w.sv" "$PWD/rtl/dcu/dcu_btag.sv" \
      "$PWD/test/dcu/btag_tb.cpp" ;;
  dcu_bctl)
    vl dcu_bctl "" "" "$PWD/rtl/dcu/dcu_bctl.sv" "$PWD/test/dcu/bctl_tb.cpp" ;;
  dcu_bctl_rel)   # the control build: a write's reservation released at its grant
    vl dcu_bctl "+define+CCV_CTL_BCTL_REL_AT_GRANT" "" "$PWD/rtl/dcu/dcu_bctl.sv" \
      "$PWD/test/dcu/bctl_tb.cpp" ;;
  dcu_bctl_ayl)   # the control build: a held fill yields to the port every time
    vl dcu_bctl "+define+CCV_CTL_BCTL_ALWAYS_YIELD" "" "$PWD/rtl/dcu/dcu_bctl.sv" \
      "$PWD/test/dcu/bctl_tb.cpp" ;;
  dcu_bctl_pnw)   # the control build: the port's head writes over the fill's
    vl dcu_bctl "+define+CCV_CTL_BCTL_PORT_NOWAIT" "" "$PWD/rtl/dcu/dcu_bctl.sv" \
      "$PWD/test/dcu/bctl_tb.cpp" ;;
  dcu_mshr)
    vl dcu_mshr "" "" "$PWD/rtl/dcu/dcu_mshr.sv" "$PWD/test/dcu/mshr_tb.cpp" ;;
  dcu_mshr_bk5)   # bank 5's instance (MA-34): the bank in its ids and lines
    vl dcu_mshr "-GBK=5" "-DMSHR_BK=5" "$PWD/rtl/dcu/dcu_mshr.sv" "$PWD/test/dcu/mshr_tb.cpp" ;;
  dcu_fill_mpick)   # dcu_fill's cross-bank picks (g_mpick; DI-67, MA rev 229)
    vl dcu_fill "" "" "$PWD/rtl/common/ccv_common_secded_enc.sv" "$PWD/rtl/dcu/dcu_fill.sv" \
      "$PWD/test/dcu/mpick_tb.cpp" ;;
  dcu_fill)
    vl dcu_fill "" "" "$PWD/rtl/common/ccv_common_secded_enc.sv" "$PWD/rtl/dcu/dcu_fill.sv" \
      "$PWD/test/dcu/fill_tb.cpp" ;;
  *) echo "cg-build: no unit $unit" >&2; exit 2 ;;
esac
