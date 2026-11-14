// RCU's RTL in the SV top, the model beside it (CCV_RCU_RTL; RI-42, TI rev
// 422; docs/rcu-impl.md section 5, step 4; M6, M7).
//
// Under CCV_RCU_RTL the top's ccv_rcu is this wrapper, in place of the DPI
// shim rtl/top/dpi/ccv_rcu.sv. It holds two blocks on the same inputs:
//   u_rtl     rtl/rcu/ccv_rcu.sv (as ccv_rcu_rtl, test/rcu/svh.py prep), whose
//             outputs drive the top's nets: the machine runs on the RTL. The
//             trace ids alone (CCV_TRACE's _tid, which the RTL ties to 0)
//             are the shadow's, so the host's checks find each message's
//             oracle record;
//   u_shadow  the C++ RCU through its DPI shim (gen-top's rcu_dpi), whose
//             outputs drive nothing. It does what the model does behind its
//             ports (Kernel::gpr/pred, the RAT on a map, the per-instruction
//             oracle checks, the coverage bins), on what the RTL's
//             neighbours sent.
// Each cycle the wrapper writes, with +ccv_rcu_svh=BASE:
//   BASE.vcd     every port, the inputs and the shadow's outputs, as ccv-skel's
//                --port-dump rcu= writes them: the model's side of the compare;
//   BASE.obs     the RTL's outputs, one line a cycle;
//   BASE.rtl.ev  the RTL's events (test/rcu/evmon.py's monitor on u_rtl);
// and with CCV_RCU_EVLOG=BASE.ev the shadow writes the model's events.
// `test/rcu/svh.py compare BASE` holds the RTL to the model on them every
// cycle, by the block lock-step's rules (test/rcu/lockstep.py --replayed:
// its care masks, the wake rule, the events, the clock gate closed only where
// the model is idle), and prints "rcu=rtl divergences=N".
//
// The final-state compare (TI rev 422): the shadow is what writes
// Kernel::gpr/pred, so a host that read them would compare the model's
// registers, not the RTL's. The host reads the RTL's instead, through
// ccv_rcu_rtl_gpr and ccv_rcu_rtl_pred below (exported; scope
// tb.u_top.u_rcu.u_blk), wherever it reads the physical files for that
// compare: a warp's snapshot as it exits and the compare at the end. The
// architectural view is the host's (its RAT, its prat), as for the model.
// Control +ccv_rcu_svh_flip: the host's first read finds lane bit 0 of the
// RTL's row flipped, and the stored row takes the flip at the next edge: a
// GPR value wrong in the RTL that nothing reads before the compare, which
// must fail.
//
// The power-up: the RTL's rows hold the model's (0xdead0000 | p << 5 | l),
// as in the block lock-step, unless +ccv_rcu_svh_noinit.
//
// Simulation only; Verilator, with CCV_TRACE (the shim needs it).
`include "ccv_interfaces.svh"

/* verilator lint_off UNUSEDSIGNAL */
/* verilator lint_off MULTIDRIVEN */
module ccv_rcu (
  `include "ccv_rcu_ports.svh"
);
  // The RTL's clock gate held open (cg_override): in this top every block
  // but RCU is a DPI shim, whose wake ports sit inactive (gen-top), so a
  // gate that slept would sleep through its neighbours' first message, and
  // the top's wake checkers would name the shims. The gate itself is held to
  // the model in the block lock-step (test/rcu/run-lockstep.sh: the gate
  // closed only where the model is idle, its control `gate`), where the
  // dump's wakes are derived. -DCCV_RCU_SVH_GATE keeps it, for a top whose
  // neighbours drive their wakes.
`ifndef CCV_RCU_SVH_GATE
  initial force u_rtl.u_cg.cg_override = 1'b1;
`endif

`include "ccv_rcu_svh_gen.svh"

  // ---- the RTL's register files, for the host's final compare ---------------
  export "DPI-C" function ccv_rcu_rtl_gpr;
  export "DPI-C" function ccv_rcu_rtl_pred;
  bit flip_armed = 1'b0;
  initial flip_armed = $test$plusargs("ccv_rcu_svh_flip");
  // Physical GPR `row`, lane `lane`, as the RTL reads it now. The hardwired
  // zero rows (CCV_P_PHYS_ZERO, CCV_P_PRED_ZERO) are not stored: the RTL's
  // read path forces them to zero, and so do these. Any other row outside
  // the files is an error, not a value.
  localparam int GROWS = ccv_prov_pkg::CCV_P_PHYS_REGS;
  localparam int PROWS = ccv_prov_pkg::CCV_P_PRED_REGS;
  function automatic int unsigned ccv_rcu_rtl_gpr(input int row, input int lane);
    if (row == ccv_prov_pkg::CCV_P_PHYS_ZERO) return 0;
    if (row < 0 || row >= GROWS || lane < 0 || lane >= 32) begin
      $error("ccv_rcu_rtl_gpr: no physical GPR %0d lane %0d", row, lane);
      return 32'hxxxxxxxx;
    end
    // The control flips the first stored row the host reads.
    if (flip_armed) begin
      flip_armed = 1'b0;
      flip_row = row;
      flip_lane = lane;
      flip_req = 1'b1;
      $display("CCV_RCU_SVH control flip: RTL row %0d lane %0d bit 0 flipped in place", row, lane);
      return rtl_gpr[row][lane] ^ 32'h1;   // the stored flip lands at the next edge
    end
    return rtl_gpr[row][lane];
  endfunction
  // Physical predicate `row`, a bit a lane, as the RTL reads it now.
  function automatic int unsigned ccv_rcu_rtl_pred(input int row);
    if (row == ccv_prov_pkg::CCV_P_PRED_ZERO) return 0;
    if (row < 0 || row >= PROWS) begin
      $error("ccv_rcu_rtl_pred: no physical predicate %0d", row);
      return 32'hxxxxxxxx;
    end
    return rtl_pred[row];
  endfunction
endmodule
