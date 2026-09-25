//===-- lockstep_smoke.sv - instances in step, for the lockstep checker --===//
//
// Spec: interface decisions (revised 2026-09-25), lockstep attribute
// Reusable: a formal harness; clk/rst_n are generic formals.
//
// Free per-slot values broadcast to every instance, so the instances are in
// step by construction. Under sby cover mode the asserts must hold and both
// satisfiability covers must be reachable. Four instances of two slots: the
// property is the same at 32 x 4, and the proof is cheaper.
//===----------------------------------------------------------------------===//
`include "ccv_if.svh"

module lockstep_smoke (
  input logic       clk,
  input logic       rst_n,
  input logic [1:0] v,
  input logic [1:0] c
);
  ccv_lockstep_checker #(.INSTS(4), .N(2)) u_chk (
    .clk(clk), .rst_n(rst_n), .valid({4{v}}), .credit({4{c}}));
endmodule
