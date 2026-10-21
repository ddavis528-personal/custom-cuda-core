//===-- ccv_common_rpt.sv - sequential repeater for one channel instance -----===//
//
// Spec: docs/physical.md, "Sequential repeaters"
// One instance per channel end in every hardening wrapper; clk is
// whatever that link is clocked by (core_clk today), so clk/rst_n
// are generic formals.
//
// STAGES flops in every direction of one credited channel instance -- its
// SLOTS slots and its one wake -- so a link can span more distance than one
// cycle allows while every block keeps its flops-on-both-sides boundary.
// Forward: valid, payload (with its lead slice) and trace id per slot, and
// wake. Backward: credit and stall per slot. STAGES = 0 is wires, which is
// how every hardening wrapper holds one of these for every channel end
// whether or not the link is repeated: the hierarchy does not change when a
// stage count does (params/links.json).
//
// THE ENABLES, which are the point of the widget beyond "some flops". A
// clock enable comes only from this module's own flops (CG-5, Daniel,
// 2026-10-18), which is why valid leads the payload by a cycle:
//
//   - payload (and trace id): enabled by the PREVIOUS cycle's valid. The
//     payload follows valid by one cycle, so the cycle it is on this stage's
//     input is exactly the cycle this stage's own valid flop is high. That
//     flop is the enable: the payload register loads once per message and
//     holds otherwise, a clock-gating candidate with one shared enable per
//     stage -- no toggling on a link carrying nothing.
//   - lead slice (schema lead_fields): it travels WITH valid, a cycle ahead
//     of the rest (Q-40), so it is taken in valid's cycle. At the first
//     stage that valid is the input, so the lead is written every cycle like
//     valid itself, with no enable, and counts against the module's ungated
//     allowance (Daniel, 2026-10-18: that is what limits leads). At a later
//     stage it is the previous stage's valid flop, a clock enable. Taken a
//     cycle late it would be the late-lead failure the skeleton's --break
//     late-lead demonstrates. Channels without lead fields have no such
//     register.
//   - valid, wake, credit, stall: pulses, registered every cycle, reset low.
//   - the reset: flopped once, here, before any use (RST-1).
//   The pulses and the flopped reset are the channel's own control, captured
//   every cycle as any receiver's: they count against the hardening
//   wrapper's ungated budget, not this module's (Daniel, 2026-10-19); the
//   first stage's lead counts against this module's.
//
// What a repeated link changes, which the widget itself cannot: the round
// trip grows by 2 * STAGES, and credit depth, drain wait and every checker's
// ROUND_TRIP grow with it (docs/physical.md). Every slot of a channel
// instance moves together because they share this module; every copy of a
// lockstep channel takes the same total, which params/links.json enforces.
//===----------------------------------------------------------------------===//
`include "ccv_assert.svh"

`define CCV_CLK clk
`define CCV_RST !rst_n_q

module ccv_common_rpt #(
  parameter int STAGES    = 1,
  parameter int SLOTS     = 1,
  parameter int PAYLOAD_W = 32,
  parameter logic [PAYLOAD_W-1:0] LEAD_MASK = '0
) (
  input  logic                       clk,
  input  logic                       rst_n,
  // the sender's side; slot j is bits [j] and [j*PAYLOAD_W +: PAYLOAD_W]
  input  logic [SLOTS-1:0]           src_valid,
  input  logic [SLOTS*PAYLOAD_W-1:0] src_payload,
  input  logic                       src_wake,
  output logic [SLOTS-1:0]           src_credit,
  output logic [SLOTS-1:0]           src_stall,
  // the receiver's side
  output logic [SLOTS-1:0]           dst_valid,
  output logic [SLOTS*PAYLOAD_W-1:0] dst_payload,
  output logic                       dst_wake,
  input  logic [SLOTS-1:0]           dst_credit,
  input  logic [SLOTS-1:0]           dst_stall
`ifdef CCV_TRACE
  ,
  input  logic [SLOTS*64-1:0]        src_tid,
  output logic [SLOTS*64-1:0]        dst_tid
`endif
);

  localparam int W = PAYLOAD_W;
  localparam int S = SLOTS;
  localparam bit HAS_LEAD = (LEAD_MASK != '0);

  // The reset, flopped before any use (RST-1): every flop below leaves reset
  // a cycle after rst_n does. A repeater of no stages has nothing to reset.
  logic rst_n_q;
  if (STAGES > 0) begin : g_rst
    always_ff @(posedge clk) rst_n_q <= rst_n;
  end else begin : g_norst
    assign rst_n_q = rst_n;
  end

  // Node k is the link after k stages: node 0 is the sender's side, node
  // STAGES the receiver's. Flat vectors with part-selects (CCV-L26), node
  // major, slot minor; each stage drives its own node by continuous assign.
  wire [(STAGES+1)*S-1:0]   v, cr, st;
  wire [STAGES:0]           wk;
  wire [(STAGES+1)*S*W-1:0] p;
`ifdef CCV_TRACE
  wire [(STAGES+1)*S*64-1:0] t;
`endif

  assign v[0 +: S]          = src_valid;
  assign wk[0]              = src_wake;
  assign p[0 +: S*W]        = src_payload;
  assign cr[STAGES*S +: S]  = dst_credit;
  assign st[STAGES*S +: S]  = dst_stall;
`ifdef CCV_TRACE
  assign t[0 +: S*64]       = src_tid;
`endif

  // Every enable below is src_valid, delayed: one known-check at the source
  // covers them all (the valid flops reset low). Here rather than per stage
  // because Yosys refuses the same assertion label once per generate scope.
  `CCV_ASSERT_KNOWN(valid_known, src_valid)

  for (genvar k = 0; k < STAGES; k++) begin : g_stage
    logic [S-1:0] valid_q, credit_q, stall_q;
    logic         wake_q;
    // The payload's clock enable, named as one (docs/rtl-coding-style.md,
    // "Local clock gating"): this stage's own valid flop.
    wire  [S-1:0] pay_en = valid_q;

    always_ff @(posedge clk) begin
      if (!rst_n_q) begin
        valid_q  <= '0;
        wake_q   <= 1'b0;
        credit_q <= '0;
        stall_q  <= '0;
      end else begin
        valid_q  <= v[k*S +: S];
        wake_q   <= wk[k];
        credit_q <= cr[(k+1)*S +: S];
        stall_q  <= st[(k+1)*S +: S];
      end
    end

    for (genvar j = 0; j < S; j++) begin : g_slot
      logic [W-1:0] pay_q;

      // The payload register, enabled by the previous cycle's valid -- this
      // stage's own valid flop. No reset: it is data, meaningful only when due.
      always_ff @(posedge clk) begin
        if (pay_en[j]) pay_q <= p[(k*S+j)*W +: W];
      end

      if (HAS_LEAD) begin : g_lead
        // The lead slice, taken in its valid's cycle: it rides with it.
        logic [W-1:0] lead_q;
        if (k == 0) begin : g_in
          // Its valid is this module's input: written every cycle, as valid.
          always_ff @(posedge clk) begin
            lead_q <= p[(k*S+j)*W +: W] & LEAD_MASK;
          end
        end else begin : g_flop
          // Its valid is the previous stage's valid flop: a clock enable.
          wire lead_en = v[k*S+j];
          always_ff @(posedge clk) begin
            if (lead_en) lead_q <= p[(k*S+j)*W +: W] & LEAD_MASK;
          end
        end
        assign p[((k+1)*S+j)*W +: W] = (pay_q & ~LEAD_MASK) | lead_q;
      end else begin : g_nolead
        assign p[((k+1)*S+j)*W +: W] = pay_q;
      end

`ifdef CCV_TRACE
      // The trace id rides beside the payload and lands with it.
      logic [63:0] tid_q;
      always_ff @(posedge clk) begin
        if (pay_en[j]) tid_q <= t[(k*S+j)*64 +: 64];
      end
      assign t[((k+1)*S+j)*64 +: 64] = tid_q;
`endif
    end

    assign v[(k+1)*S +: S] = valid_q;
    assign wk[k+1]         = wake_q;
    assign cr[k*S +: S]    = credit_q;
    assign st[k*S +: S]    = stall_q;
  end

  assign dst_valid   = v[STAGES*S +: S];
  assign dst_wake    = wk[STAGES];
  assign dst_payload = p[STAGES*S*W +: S*W];
  assign src_credit  = cr[0 +: S];
  assign src_stall   = st[0 +: S];
`ifdef CCV_TRACE
  assign dst_tid     = t[STAGES*S*64 +: S*64];
`endif

endmodule

`undef CCV_CLK
`undef CCV_RST
