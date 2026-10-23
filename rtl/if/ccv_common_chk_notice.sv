//===-- ccv_common_chk_notice.sv - a notice's message follows on time --------===//
//
// Spec: OA's response OA-23; AR's response TI-23 (schema notice_of)
// One instance per slot of every notice channel, paired with the same slot
// of its partner; clk/rst_n are generic formals.
//
// A notice is a promise: its partner's valid on the same slot exactly AHEAD
// cycles after the notice's payload lands, and the partner's key fields
// equal to the notice's. A notice is optional, so a partner message with no
// notice is legal and nothing here looks at it. Both are probed where they
// leave the source's wrapper, and tools/ccv_links.py holds the two links'
// stages equal, so the count is the receiver's too.
//
//   cycle t              notice valid
//   t + 1                notice payload (its keys)
//   t + 1 + AHEAD        partner valid       -- on_time
//   t + 2 + AHEAD        partner payload     -- same_keys
//
// `enable` as in ccv_common_chk_outstanding: the S0 exerciser's synthetic
// traffic sends on each channel independently.
//===----------------------------------------------------------------------===//
`include "ccv_if.svh"

`define CCV_CLK clk
`define CCV_RST !rst_n

module ccv_common_chk_notice #(
  parameter int MODE  = `CCV_MODE_ASSERT,
  parameter int AHEAD = 2,
  parameter int KW    = 1
) (
  input logic          clk,
  input logic          rst_n,
  input logic          enable,
  input logic          ntc_valid,
  input logic [KW-1:0] ntc_keys,     // the notice's key fields, from its payload
  input logic          msg_valid,
  input logic [KW-1:0] msg_keys      // the partner's key fields, from its payload
);

  // The notice's valid, a cycle on, when its keys are on the wire.
  logic ntc_q;
  always_ff @(posedge clk) begin
    if (!rst_n) ntc_q <= 1'b0;
    else        ntc_q <= ntc_valid;
  end

  // Promises in flight: entry k is due k + 1 cycles from now. A notice's
  // keys enter at AHEAD - 1 and reach 0 the cycle its partner's valid is due.
  logic [AHEAD-1:0]    due_q;
  logic [AHEAD*KW-1:0] key_q;
  always_ff @(posedge clk) begin
    if (!rst_n) due_q <= '0;
    else        due_q <= {ntc_q, due_q[AHEAD-1:1]};
  end
  always_ff @(posedge clk) begin
    key_q <= {ntc_keys, key_q[AHEAD*KW-1:KW]};
  end
  wire          due     = due_q[0];
  wire [KW-1:0] due_key = key_q[KW-1:0];

  // The partner's payload lands a cycle after its valid: compare then.
  logic          cmp_q;
  logic [KW-1:0] want_q;
  always_ff @(posedge clk) begin
    if (!rst_n) cmp_q <= 1'b0;
    else        cmp_q <= due && msg_valid;
  end
  always_ff @(posedge clk) begin
    if (due) want_q <= due_key;
  end

  `CCV_CONTRACT_M(MODE, on_time,   !enable || !(due && !msg_valid))
  `CCV_CONTRACT_M(MODE, same_keys, !enable || !(cmp_q && msg_keys != want_q))

  // -- satisfiability (§3.3): a promise kept, and one made while another is
  // still in flight on the slot.
  `CCV_IF_SAT(kept, enable && cmp_q && msg_keys == want_q)
  `CCV_IF_SAT(overlapping, enable && ntc_q && |due_q)

endmodule

`undef CCV_CLK
`undef CCV_RST
