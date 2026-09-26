#!/usr/bin/env bash
# The SystemVerilog top level: rtl/top/ccv_core_top.sv, its generated block
# port lists and stubs, and test/top/tb_core_top.sv -- all from
# tools/gen-top.py.
#
# With stub blocks nothing moves, so what this proves is structural:
#   - it elaborates clean in all three tools, with and without the checker
#     bank and the trace sideband;
#   - it simulates, in Icarus and in Verilator, with the bank attached;
#   - synthesis sees no checker at all unless CCV_CHECK is defined (B-1);
#   - it holds block instances and nets and nothing else -- no gate, flop,
#     constant or clock gate -- and five deliberately impure copies are
#     refused (tools/check-top-pure.py);
#   - its connectivity, EXTRACTED from the elaborated netlist, is bit for bit
#     the C++ skeleton's -- and a deliberately miswired copy is rejected.
set -uo pipefail
cd "$(dirname "$0")/.."
R=$(pwd)
B="$R/build"
mkdir -p "$B"
fail=0
say() { printf '  %-46s %s\n' "$1" "$2"; }
bad() { say "$1" "FAIL -- $2"; fail=1; }

CHK="rtl/if/ccv_credit_checker.sv rtl/if/ccv_atomic_checker.sv rtl/if/ccv_lockstep_checker.sv rtl/if/ccv_binding_checker.sv rtl/if/ccv_outstanding_checker.sv rtl/if/ccv_wake_checker.sv rtl/generated/ccv_skel_checkers.sv"
STUBS=$(ls rtl/top/stubs/*.sv | tr '\n' ' ')
# The assertion package first: the checkers import it, and every tool wants a
# package declared before its first use.
PKG="rtl/ccv_assert_pkg.sv"
# The hardening wrappers, and the repeater they instantiate at every end.
WRAP="rtl/phys/ccv_seq_rpt.sv $(ls rtl/top/wrap/*.sv | tr '\n' ' ')"
TOP="$STUBS $WRAP rtl/top/ccv_core_top.sv"
INC="-Irtl/include -Irtl/generated -Irtl/top/ports"

# -- Verilator -Wall, three builds people will actually run -----------------
if command -v verilator >/dev/null 2>&1; then
  for D in "" "-DCCV_CHECK" "-DCCV_CHECK -DCCV_TRACE"; do
    if verilator --lint-only --assert -Wall -Wno-DECLFILENAME -Wno-TIMESCALEMOD \
         $D $INC --top-module ccv_core_top $PKG $CHK $TOP >"$B/top_lint.log" 2>&1; then
      say "verilator -Wall: top ${D:-(synthesis view)}" "PASS"
    else
      bad "verilator -Wall: top ${D:-(synthesis view)}" \
          "$(grep -m1 -E '%(Warning|Error)' "$B/top_lint.log")"
    fi
  done
  # ...and it RUNS under Verilator with the bank and trace sideband attached.
  if verilator --binary -j 0 --assert --timing -Wno-fatal -Wno-TIMESCALEMOD \
       -DCCV_CHECK -DCCV_TRACE $INC --top-module tb --Mdir "$B/top_vo" \
       -CFLAGS "-I$R/sim/include -I$R/sim/generated" \
       $PKG $CHK $TOP test/top/tb_core_top.sv \
       "$R/sim/src/event.cpp" "$R/sim/dpi/ccv_event_dpi.cpp" \
       >"$B/top_vb.log" 2>&1; then
    out=$({ "$B/top_vo/Vtb" 2>&1 || true; } 2>/dev/null)
    if echo "$out" | grep -q TOP_OK && ! echo "$out" | grep -q "CCV .* failed"; then
      say "verilator: top + checker bank simulates quiet" "PASS"
    else
      bad "verilator: top simulates" "$(echo "$out" | grep -m1 -E 'failed|Error')"
    fi
    # The partner: a phantom credit on the outbound external port must be
    # reported by THAT channel's checker, by name -- so the bank in the SV top
    # is live and wired to the top's own ports.
    out=$({ "$B/top_vo/Vtb" +phantom 2>&1 || true; } 2>/dev/null)
    if echo "$out" | grep -q "u_exb_ext_out_s0.*no_phantom_credit"; then
      say "  ...+phantom: the bank in the top fires" "PASS"
    else
      bad "checker bank live in the SV top" "+phantom was not reported"
    fi
  else
    bad "verilator: top builds with checkers" "$(grep -m1 -i error "$B/top_vb.log")"
  fi
fi

# -- Icarus: the same top, both ways ----------------------------------------
if command -v iverilog >/dev/null 2>&1; then
  for D in "" "-DCCV_CHECK"; do
    if iverilog -g2012 -gassertions $D $INC -o "$B/top.vvp" -s tb \
         $PKG $CHK $TOP test/top/tb_core_top.sv >"$B/top_iv.log" 2>&1; then
      out=$(vvp "$B/top.vvp" 2>&1)
      if echo "$out" | grep -q TOP_OK && ! echo "$out" | grep -q "CCV .* failed"; then
        say "icarus: top simulates ${D:-(no checkers)}" "PASS"
      else
        bad "icarus: top simulates ${D:-}" "$(echo "$out" | grep -m1 -E 'failed|ERROR')"
      fi
    else
      bad "icarus: top compiles ${D:-}" "$(head -1 "$B/top_iv.log")"
    fi
  done
fi

# -- Yosys: the synthesis view has every block and no checker ---------------
if command -v yosys >/dev/null 2>&1; then
  view() {   # $1 = defines, $2 = extra files; prints "<blocks> <checkers>"
    yosys -p "read_verilog -sv -formal $1 $INC $PKG $2 $TOP; \
              hierarchy -check -top ccv_core_top; select -list t:ccv_*" \
      2>&1 | awk '/^ccv_core_top\/u_/ {n++} /^ccv_core_top\/u_checkers$/ {c++}
                  END {print n+0, c+0}'
  }
  read -r nb nc <<<"$(view "" "")"
  read -r nb2 nc2 <<<"$(view "-DCCV_CHECK" "$CHK")"
  if [ "$nb" = "45" ] && [ "$nc" = "0" ] && [ "$nc2" = "1" ]; then
    say "yosys: 45 blocks; checkers only under CCV_CHECK" "PASS"
  else
    bad "yosys synthesis view" \
        "blocks $nb, checkers $nc without CCV_CHECK / $nc2 with (want 45, 0, 1)"
  fi
fi

# -- the top-level rule: block instances and nets, nothing else -------------
# No gate, flop, constant or clock gate at the top: each block gates core_clk
# inside itself. Checked on the elaborated netlist, both views, and each
# mutant -- the clock gate the top used to have among them -- must be refused
# for the rule it breaks.
if command -v yosys >/dev/null 2>&1; then
  if out=$(python3 tools/check-top-pure.py 2>&1); then
    say "top and wrappers: only instances and nets" "PASS (both views)"
  else
    bad "top: only block instances and nets" "$(echo "$out" | grep -m1 -E '^  R[0-9]')"
  fi
  refused=""
  for m in gate tie flop float unloaded wrapgate wraptie dupreuse paramreuse; do
    python3 tools/check-top-pure.py --mutate=$m >"$B/top_pure_$m.log" 2>&1
    rc=$?
    [ $rc -eq 1 ] && refused="$refused $m" ||
      bad "top rule refuses a $m" "$(grep -m1 -E 'MUTANT|TOP_PURE ok|mutation' "$B/top_pure_$m.log")"
  done
  [ "$refused" = " gate tie flop float unloaded wrapgate wraptie dupreuse paramreuse" ] &&
    say "  ...and refuses 9 impure copies: top, wrapper, reuse" "PASS"
fi

# -- connectivity: the elaborated SV top IS the C++ skeleton's wiring -------
if [ -x "$B/skel/ccv-skel" ] && "$B/skel/ccv-skel" --dump-wiring "$B/wiring.txt"; then
  if out=$(python3 tools/check-top-wiring.py --wiring="$B/wiring.txt" 2>&1); then
    say "SV top wiring == C++ skeleton wiring" \
        "PASS ($(echo "$out" | grep -oE '[0-9]+ bits'))"
  else
    bad "SV top wiring == C++ skeleton wiring" "$(echo "$out" | sed -n 2p)"
  fi
  if python3 tools/check-top-wiring.py --wiring="$B/wiring.txt" --mutate >/dev/null 2>&1; then
    bad "wiring check rejects a miswired top" "the mutated top passed"
  else
    say "  ...and rejects a lane swapped in a copy" "PASS"
  fi
else
  bad "SV top wiring == C++ skeleton wiring" \
      "no skeleton binary -- run tools/check-skel.sh first"
fi

exit $fail
