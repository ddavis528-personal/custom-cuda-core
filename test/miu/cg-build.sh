#!/usr/bin/env bash
# Builds an MIU RTL unit's bench (test/miu/cg-units.json) under Verilator,
# assertions on, at the unit's parameters.
# Usage: test/miu/cg-build.sh <unit> <dir>   (the bench is <dir>/tb)
set -euo pipefail
cd "$(dirname "$0")/../.."
unit=$1 dir=$2
mkdir -p "$dir"
vl() {   # top, -G params, -D defines, RTL files..., bench
  local top=$1 g=$2 d=$3; shift 3
  verilator --cc --exe --build --trace -j 0 -O2 --assert -Wno-fatal -Wno-lint -Wno-style $g \
    --top-module "$top" --Mdir "$dir" -o tb -I"$PWD/rtl/include" -I"$PWD/rtl/generated" \
    -CFLAGS "-std=c++17 -O2 -I$PWD/sim/generated -I$PWD/sim/skel -I$PWD/sim/miu -I$PWD/sim/include $d" \
    "$PWD/rtl/generated/ccv_params_pkg.sv" "$PWD/rtl/ccv_assert_pkg.sv" "$@"
}
case "$unit" in
  miu_cap)
    vl miu_cap "" "" "$PWD/rtl/miu/miu_cap.sv" "$PWD/test/miu/cap_tb.cpp" ;;
  miu_pair)
    vl miu_pair "" "" "$PWD/rtl/miu/miu_pair.sv" "$PWD/test/miu/pair_tb.cpp" ;;
  miu_mq)
    vl miu_mq "--trace-max-width 16384" "" "$PWD/rtl/miu/miu_mq.sv" "$PWD/test/miu/mq_tb.cpp" ;;
  miu_agu8)
    vl miu_agu8 "" "" "$PWD/rtl/miu/miu_agu8.sv" "$PWD/test/miu/agu8_tb.cpp" ;;
  miu_agu8_lc)
    vl miu_agu8 "-GLC=1" "-DCCV_AGU8_LC=1" "$PWD/rtl/miu/miu_agu8.sv" "$PWD/test/miu/agu8_tb.cpp" ;;
  miu_cred)
    vl miu_cred "" "" "$PWD/rtl/miu/miu_cred.sv" "$PWD/test/miu/cred_tb.cpp" ;;
  miu_form)
    vl miu_form "" "" "$PWD/rtl/miu/miu_form.sv" "$PWD/test/miu/form_tb.cpp" ;;
  miu_ids)
    vl miu_ids "" "" "$PWD/rtl/miu/miu_ids.sv" "$PWD/test/miu/ids_tb.cpp" ;;
  miu_rcap)
    vl miu_rcap "" "" "$PWD/rtl/miu/miu_rcap.sv" "$PWD/test/miu/rcap_tb.cpp" ;;
  miu_hitq)
    vl miu_hitq "" "" "$PWD/rtl/miu/miu_hitq.sv" "$PWD/test/miu/hitq_tb.cpp" ;;
  miu_lead)
    vl miu_lead "" "" "$PWD/rtl/miu/miu_lead.sv" "$PWD/test/miu/lead_tb.cpp" ;;
  miu_tlb)
    vl miu_tlb "-DCCV_CHECK" "" "$PWD/rtl/miu/miu_tlb.sv" "$PWD/test/miu/tlb_tb.cpp" ;;
  miu_a2)
    vl miu_a2 "--trace-max-width 8192" "" "$PWD/rtl/miu/miu_grp.sv" "$PWD/rtl/miu/miu_a2.sv" "$PWD/test/miu/a2_tb.cpp" ;;
  miu_a2_s64)   # MA-33 (3): 64 sets, the page offset's tag bits PA[15:13] in pa_fold
    vl miu_a2 "--trace-max-width 8192 -GDS=64" "-DCCV_A2_SETS=64" "$PWD/rtl/miu/miu_grp.sv" "$PWD/rtl/miu/miu_a2.sv" "$PWD/test/miu/a2_tb.cpp" ;;
  *) echo "cg-build: no unit $unit" >&2; exit 2 ;;
esac
