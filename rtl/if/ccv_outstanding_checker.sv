//===-- ccv_outstanding_checker.sv - at most MAX requests unanswered -----===//
//
// Spec: skeleton review response (2026-09-25), outstanding attribute;
//       docs/skeleton.md
// Reusable: one instance per request/response channel pair with an
//           `outstanding` limit; clk/rst_n are generic formals.
//
// A response channel with no correlation tag is correct only if the
// requester never has more outstanding than the pair can tell apart. For
// the ITLB (fet->miu request, miu->fet refill) the decision is ONE: fetch
// stalls on a miss anyway, so a tag would buy nothing. That is asserted
// here rather than trusted.
//
// Counted at valid, the edge a message is committed on, on both channels.
// A response with nothing outstanding is its own violation: the round trip
// is at least 2, so it cannot belong to a request launched the same cycle.
//
// `enable` exists because the S0 exerciser's traffic is synthetic -- it
// sends on each channel independently -- and would violate a pairing it
// knows nothing about. The functional stubs (S1) and every RTL build run
// it on.
//===----------------------------------------------------------------------===//
`include "ccv_if.svh"

`define CCV_CLK clk
`define CCV_RST !rst_n

module ccv_outstanding_checker #(
  parameter int MODE = `CCV_MODE_ASSERT,
  parameter int MAX  = 1
) (
  input logic clk,
  input logic rst_n,
  input logic enable,
  input logic req_valid,
  input logic rsp_valid
);

  localparam int CW = $clog2(MAX + 2);
  localparam int CW_MAX = MAX;
  wire [CW-1:0] limit = CW_MAX[CW-1:0];

  // Ternary selects, not `if` on the two inputs (CCV-L08): a ternary merges
  // an X rather than silently taking one branch. The credit checker pairs its
  // `if`s with CCV_ASSUME_KNOWN instead, but here that assumption made every
  // cover in the formal harness unreachable -- the harness drives these
  // inputs from a register -- so the covers caught a vacuous setup
  // (docs/fail-open-register.md).
  logic [CW-1:0] out_q;
  wire inc = req_valid && !rsp_valid && out_q != {CW{1'b1}};
  wire dec = rsp_valid && !req_valid && out_q != '0;

  always_ff @(posedge clk) begin
    if (!rst_n) out_q <= '0;
    else        out_q <= inc ? out_q + 1'b1 : dec ? out_q - 1'b1 : out_q;
  end

  `CCV_CONTRACT_M(MODE, within_limit,
                  !enable || !(req_valid && !rsp_valid && out_q >= limit))
  `CCV_CONTRACT_M(MODE, answers_a_request,
                  !enable || !(rsp_valid && out_q == '0))

  // -- satisfiability (§3.3): the limit can be reached, and answered ------
  `CCV_IF_SAT(at_limit, enable && out_q == limit)
  `CCV_IF_SAT(answered, enable && rsp_valid && out_q == limit)

endmodule

`undef CCV_CLK
`undef CCV_RST
