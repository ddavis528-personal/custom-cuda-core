set -e; cd /tmp/claude-0/-home-user/f45e5bc5-a4af-595e-a4dd-e1d6ad6f715c/scratchpad/wri; R=$(pwd); B=$R/build; mkdir -p $B

# -- build ---------------------------------------------------------------
# Block implementations, one list for both hosts (sim/skel/blocks.list).
BLOCKS=$(grep -v '^#' sim/skel/blocks.list | sed "s|^|$R/|" | tr '\n' ' ')
VCOMMON="--cc --exe --build -j 0 -Wno-fatal -Wno-TIMESCALEMOD -Irtl/include -Irtl/generated"
if ! verilator $VCOMMON --assert -DCCV_TRACE --top-module ccv_common_chk_bank \
     --Mdir "$B/skel" -o ccv-skel \
     -CFLAGS "-std=c++17 -O1 -I$R/sim/include -I$R/sim/generated -I$R/sim/skel" \
     rtl/ccv_assert_pkg.sv rtl/if/ccv_common_chk_credit.sv \
     rtl/if/ccv_common_chk_atomic.sv rtl/if/ccv_common_chk_lockstep.sv \
     rtl/if/ccv_common_chk_binding.sv rtl/if/ccv_common_chk_outstanding.sv rtl/if/ccv_common_chk_notice.sv \
     rtl/if/ccv_common_chk_wake.sv \
     rtl/generated/ccv_common_chk_bank.sv \
     "$R/sim/skel/main.cpp" "$R/sim/skel/machine.cpp" \
     "$R/sim/skel/exerciser.cpp" $BLOCKS \
     "$R/sim/skel/oracle.cpp" "$R/sim/src/event.cpp" \
     "$R/sim/dpi/ccv_event_dpi.cpp" >"$B/skel.log" 2>&1; then
  echo "skeleton build FAIL"; grep -m3 -i error "$B/skel.log" # "$(grep -m1 -i error "$B/skel.log")"
  exit 1
fi
echo built
