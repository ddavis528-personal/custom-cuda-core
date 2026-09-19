// case: SystemVerilog interface on the TOP-LEVEL port list
// expect_sim: SKIP
// expect_formal: SKIP
// runners: none
// aux: 30_iface_top_boundary.aux.sv
//
// Probed out of band by the runner, not through the common testbench -- a tool
// that cannot elaborate this also cannot be handed that testbench.
//
// This is the half of §9's interface question that actually matters. §2 makes
// block boundaries swap boundaries, and §1's swap mechanism requires that a
// hand-written C++ timing-model block and a Verilated RTL block sit behind the
// SAME interface in one executable. That only works if Verilator can expose
// this module's boundary to C++. If it cannot, §9's fallback -- plain ports
// with suffix conventions, or packed structs -- is not a style preference, it
// is the only option, and that has to be settled at 1d before any RTL exists.
module blk (ccv_rv_if.consumer up, ccv_rv_if.producer dn);
  assign dn.valid = up.valid;
  assign up.ready = dn.ready;
endmodule
