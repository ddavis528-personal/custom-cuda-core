//===-- ccv_seq_rpt.sv - sequential repeater for one credited slot --------===//
//
// Spec: docs/physical.md, "Sequential repeaters"
// Reusable: one instance per slot of every link that needs repeating, in
//           whatever hierarchy hardens it; clk is whatever that link is
//           clocked by (core_clk today), so clk/rst_n are generic formals.
//
// STAGES flops in every direction of one slot of a credited channel, so a
// link can span more distance than one cycle allows while every block keeps
// its flops-on-both-sides boundary. Forward: valid, payload (with its lead
// slice), wake and the trace id. Backward: credit and stall. STAGES = 0 is
// wires, so a link can be declared repeated before its distance is known.
//
// THE ENABLES, which are the point of the widget beyond "some flops":
//
//   - payload (and trace id): enabled by the PREVIOUS cycle's valid. The
//     payload follows valid by one cycle, so the cycle it is on this stage's
//     input is exactly the cycle this stage's own valid flop is high. That
//     flop is the enable: the payload register loads once per message and
//     holds otherwise, a clock-gating candidate with one shared enable per
//     stage -- no toggling on a link carrying nothing.
//   - lead slice (schema lead_fields): enabled by the SAME cycle's valid,
//     because a lead travels WITH valid, a cycle ahead of the rest (Q-40).
//     Enabled by the previous cycle's valid it would be taken a cycle late:
//     the late-lead failure the skeleton's --break late-lead demonstrates.
//     Channels without lead fields have no such register.
//   - valid, wake, credit, stall: pulses, registered every cycle, reset low.
//
// What a repeated link changes, which the widget itself cannot: the round
// trip grows by 2 * STAGES, and credit depth, drain wait and every checker's
// ROUND_TRIP grow with it (docs/physical.md). Every slot of a channel
// instance, and every copy of a lockstep channel, takes the same STAGES, or
// the atomic and lockstep guarantees are lost.
//===----------------------------------------------------------------------===//
`include "ccv_assert.svh"

`define CCV_CLK clk
`define CCV_RST !rst_n

module ccv_seq_rpt #(
  parameter int STAGES    = 1,
  parameter int PAYLOAD_W = 32,
  parameter logic [PAYLOAD_W-1:0] LEAD_MASK = '0
) (
  input  logic                 clk,
  input  logic                 rst_n,
  // the sender's side
  input  logic                 src_valid,
  input  logic [PAYLOAD_W-1:0] src_payload,
  input  logic                 src_wake,
  output logic                 src_credit,
  output logic                 src_stall,
  // the receiver's side
  output logic                 dst_valid,
  output logic [PAYLOAD_W-1:0] dst_payload,
  output logic                 dst_wake,
  input  logic                 dst_credit,
  input  logic                 dst_stall
`ifdef CCV_TRACE
  ,
  input  logic [63:0]          src_tid,
  output logic [63:0]          dst_tid
`endif
);

  localparam int W = PAYLOAD_W;
  localparam bit HAS_LEAD = (LEAD_MASK != '0);

  // Node k is the link after k stages: node 0 is the sender's side, node
  // STAGES the receiver's. Flat vectors with part-selects (CCV-L26); each
  // stage drives its own node through a continuous assign.
  wire [STAGES:0]       v, wk, cr, st;
  wire [(STAGES+1)*W-1:0] p;
`ifdef CCV_TRACE
  wire [(STAGES+1)*64-1:0] t;
`endif

  assign v[0]         = src_valid;
  assign wk[0]        = src_wake;
  assign p[0 +: W]    = src_payload;
  assign cr[STAGES]   = dst_credit;
  assign st[STAGES]   = dst_stall;
`ifdef CCV_TRACE
  assign t[0 +: 64]   = src_tid;
`endif

  // Every enable below is src_valid, delayed: one known-check at the source
  // covers them all (the valid flops reset low). Here rather than per stage
  // because Yosys refuses the same assertion label once per generate scope.
  `CCV_ASSERT_KNOWN(valid_known, src_valid)

  for (genvar k = 0; k < STAGES; k++) begin : g_stage
    logic         valid_q, wake_q, credit_q, stall_q;
    logic [W-1:0] pay_q;

    always_ff @(posedge clk) begin
      if (!rst_n) begin
        valid_q  <= 1'b0;
        wake_q   <= 1'b0;
        credit_q <= 1'b0;
        stall_q  <= 1'b0;
      end else begin
        valid_q  <= v[k];
        wake_q   <= wk[k];
        credit_q <= cr[k+1];
        stall_q  <= st[k+1];
      end
    end

    // The payload register, enabled by the previous cycle's valid -- this
    // stage's own valid flop. No reset: it is data, meaningful only when due.
    always_ff @(posedge clk) begin
      if (valid_q) pay_q <= p[k*W +: W];
    end

    if (HAS_LEAD) begin : g_lead
      // The lead slice, enabled by the same cycle's valid: it rides with it.
      logic [W-1:0] lead_q;
      always_ff @(posedge clk) begin
        if (v[k]) lead_q <= p[k*W +: W] & LEAD_MASK;
      end
      assign p[(k+1)*W +: W] = (pay_q & ~LEAD_MASK) | lead_q;
    end else begin : g_nolead
      assign p[(k+1)*W +: W] = pay_q;
    end

`ifdef CCV_TRACE
    // The trace id rides beside the payload and lands with it.
    logic [63:0] tid_q;
    always_ff @(posedge clk) begin
      if (valid_q) tid_q <= t[k*64 +: 64];
    end
    assign t[(k+1)*64 +: 64] = tid_q;
`endif

    assign v[k+1]  = valid_q;
    assign wk[k+1] = wake_q;
    assign cr[k]   = credit_q;
    assign st[k]   = stall_q;
  end

  assign dst_valid   = v[STAGES];
  assign dst_wake    = wk[STAGES];
  assign dst_payload = p[STAGES*W +: W];
  assign src_credit  = cr[0];
  assign src_stall   = st[0];
`ifdef CCV_TRACE
  assign dst_tid     = t[STAGES*64 +: 64];
`endif

endmodule

`undef CCV_CLK
`undef CCV_RST
