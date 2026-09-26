//===-- outstanding_smoke.sv - a single-outstanding requester -------------===//
//
// Spec: skeleton review response (2026-09-25), outstanding attribute
// Reusable: a formal harness; clk/rst_n are generic formals.
//
// A requester that sends only when nothing is outstanding and a responder
// that answers only what was asked, both free in their timing. The asserts
// must hold and both covers must be reachable.
//===----------------------------------------------------------------------===//
`include "ccv_if.svh"

`define CCV_CLK clk
`define CCV_RST !rst_n

module outstanding_smoke (
  input logic clk,
  input logic rst_n,
  input logic want_req,
  input logic want_rsp
);
  logic busy_q;
  wire  req = want_req && !busy_q;
  wire  rsp = want_rsp && busy_q;
  always_ff @(posedge clk) begin
    if (!rst_n)   busy_q <= 1'b0;
    else if (req) busy_q <= 1'b1;
    else if (rsp) busy_q <= 1'b0;
  end
  ccv_outstanding_checker #(.MAX(1)) u_chk (
    .clk(clk), .rst_n(rst_n), .enable(1'b1), .req_valid(req), .rsp_valid(rsp));
endmodule

`undef CCV_CLK
`undef CCV_RST
