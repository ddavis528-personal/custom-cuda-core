//===-- atomic_smoke.sv - lockstep traffic for the atomic checker ------===//
//
// Spec: interface decisions (2026-09-24), acceptance attribute
// Reusable: a formal harness; clk/rst_n are generic formals.
//
// Free inputs, but broadcast to every slot, so traffic is lockstep by
// construction. Under sby cover mode the asserts must hold and both
// satisfiability covers must be reachable -- the covers only count if they
// are RUN (docs/fail-open-register.md), and this is where they run.
//===----------------------------------------------------------------------===//
`include "ccv_if.svh"

module atomic_smoke (
  input logic clk,
  input logic rst_n,
  input logic en,
  input logic v,
  input logic c
);
  ccv_atomic_checker #(.N(4)) u_chk (
    .clk(clk), .rst_n(rst_n), .enable(en),
    .valid({4{v}}), .credit({4{c}}));
endmodule
