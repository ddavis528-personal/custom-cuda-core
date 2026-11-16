#!/usr/bin/env bash
# Build the skeleton (ccv-skel) into a Verilator directory: the checker bank
# as its top, every block of sim/skel/blocks.list beside it.
#   tools/build-skel.sh <mdir> [<bank.sv>]
# <bank.sv> replaces rtl/generated/ccv_common_chk_bank.sv, for a control that
# needs a bank built otherwise (check-kernel's bounded coremark128 at 8192).
# Copy a built <mdir> first and only what changed recompiles. Verilator's
# output goes to <mdir>.log; exit 1 if it does not build.
set -uo pipefail
cd "$(dirname "$0")/.."
R=$(pwd)
M=$1
BANK=${2:-rtl/generated/ccv_common_chk_bank.sv}
BLOCKS=$(grep -v '^#' sim/skel/blocks.list | sed "s|^|$R/|" | tr '\n' ' ')
verilator --cc --exe --build -j 0 -Wno-fatal -Wno-TIMESCALEMOD -Irtl/include -Irtl/generated \
  --assert -DCCV_TRACE --top-module ccv_common_chk_bank \
  --Mdir "$M" -o ccv-skel \
  -CFLAGS "-std=c++17 -O1 -I$R/sim/include -I$R/sim/generated -I$R/sim/skel" \
  rtl/ccv_assert_pkg.sv rtl/if/ccv_common_chk_credit.sv \
  rtl/if/ccv_common_chk_atomic.sv rtl/if/ccv_common_chk_lockstep.sv \
  rtl/if/ccv_common_chk_binding.sv rtl/if/ccv_common_chk_outstanding.sv rtl/if/ccv_common_chk_notice.sv \
  rtl/if/ccv_common_chk_wake.sv \
  "$BANK" \
  "$R/sim/skel/main.cpp" "$R/sim/skel/machine.cpp" "$R/sim/skel/portdump.cpp" \
  "$R/sim/skel/exerciser.cpp" $BLOCKS \
  "$R/sim/skel/oracle.cpp" "$R/sim/src/event.cpp" \
  "$R/sim/dpi/ccv_event_dpi.cpp" >"$M.log" 2>&1
