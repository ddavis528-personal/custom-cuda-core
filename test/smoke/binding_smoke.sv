//===-- binding_smoke.sv - correctly keyed traffic for the binding checker -===//
//
// Spec: skeleton review response (2026-09-25), binding_key
// Reusable: a formal harness; clk/rst_n are generic formals.
//
// Free valids; each slot's key is its own group, so the traffic is legal by
// construction. Under sby cover mode the assert must hold and the cover must
// be reachable.
//===----------------------------------------------------------------------===//
`include "ccv_if.svh"

module binding_smoke (
  input logic       clk,
  input logic       rst_n,
  input logic [3:0] v
);
  ccv_binding_checker #(.N(4), .GROUP(2), .W(2)) u_chk (
    .clk(clk), .rst_n(rst_n), .valid(v), .key({2'd1, 2'd1, 2'd0, 2'd0}));
endmodule
