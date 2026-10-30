//===-- distinct_smoke.sv - distinctly keyed traffic for the distinct checker -===//
//
// Spec: OA's rev 279 (OI-85), distinct_key
// A formal harness; clk/rst_n are generic formals.
//
// Free valids; each slot's key is its own index, so no two slots of a cycle
// share one and the traffic is legal by construction. Under sby cover mode
// the assert must hold and the cover must be reachable.
//===----------------------------------------------------------------------===//
`include "ccv_if.svh"

module distinct_smoke (
  input logic       clk,
  input logic       rst_n,
  input logic [3:0] v
);
  ccv_common_chk_distinct #(.N(4), .W(2)) u_chk (
    .clk(clk), .rst_n(rst_n), .valid(v), .key({2'd3, 2'd2, 2'd1, 2'd0}));
endmodule
