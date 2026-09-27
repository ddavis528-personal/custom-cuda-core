//===-- fv_link.sv - one credited link, for formal proof ------------------===//
//
// Spec: docs/interface-checker-convention.md; docs/physical.md; Q-43
// Reusable: a formal harness; clk is the solver's clock.
//
// A sender and a receiver that follow the channel protocol at their own
// ports, joined by N sequential repeater stages (rtl/phys/ccv_seq_rpt.sv),
// with the credit checker asserting at both ends. Every input is free: what
// the sender wants to send, when the receiver drains, when it stalls. The
// endpoints do what the C++ skeleton's Sender and Receiver do (channel.h),
// cycle for cycle -- the timing every block's RTL will inherit:
//   - a credit is spent on valid, and one that arrives is usable next cycle;
//   - the lead slice goes out with valid, the rest of the payload a cycle
//     later; the receiver takes the lead in the valid cycle;
//   - a message may be consumed in the cycle it lands, and its credit goes
//     back the cycle after.
//
// Proved, with no assumption beyond reset (tools/check-formal.sh, `safety`):
//   data_in_order     every message arrives, in order, lead slice and all
//   no_overflow       the receiver never holds more than DEPTH
//   credit_per_msg    one credit goes back per message consumed -- the
//                     property the S0 exerciser's receiver broke for months
//                     without a report (docs/fail-open-register.md)
//   conservation      credits at the sender + messages on the link + in the
//                     buffer + credits on the way back == DEPTH, always
//   ...plus every property of the credit checker, at both ends.
// And under FV_GREEDY -- the sender always wants to send, the receiver always
// drains and never stalls (`bandwidth`):
//   full_bandwidth    a message launches EVERY cycle out of reset: the credit
//                     depth covers the credit loop, 4 + 2N (Q-43)
//
// Mutants that must break a proof: FV_MUT_DOUBLE_POP (the S0 bug: two
// consumed, one credit), a DEPTH one short (full_bandwidth), and the
// repeater's own mutants from tools/check-phys.sh (data_in_order).
//===----------------------------------------------------------------------===//
`include "ccv_if.svh"
`include "ccv_params_pkg.sv"

`define CCV_CLK clk
`define CCV_RST !rst_n

module fv_link #(
  parameter int N     = 1,
  parameter int DEPTH = ccv_params_pkg::CCV_CREDIT_DEPTH + 2 * N,
  parameter int H     = 4              // half the payload; the low half leads
) (
  input logic clk,
  input logic want,       // the sender would launch, if it may
  input logic pop_en,     // the receiver would consume, if it holds one
  input logic stall_in,   // the receiver stalls the sender
  input logic pop2        // FV_MUT_DOUBLE_POP only: consume a second
);
  localparam int W  = 2 * H;
  localparam int CW = $clog2(DEPTH + 2) + 1;
  localparam int KW = 8;               // event counters, compared modulo 2^KW
  localparam logic [W-1:0] LEAD = {{H{1'b0}}, {H{1'b1}}};

  // No assumption that the inputs are X-free: under formal nothing is X, and
  // assuming it would pin every input to all ones (F-20).

  // -- reset: two cycles, generated here so no assumption is needed --------
  logic [1:0] boot = '0;
  logic       rst_n;
  always_ff @(posedge clk) if (boot != 2'd3) boot <= boot + 2'd1;
  assign rst_n = (boot == 2'd3);

  // -- the sender ----------------------------------------------------------
  logic          s_valid, s_credit, s_stall, s_wake;
  logic [W-1:0]  s_payload;
  logic [63:0]   s_tid;
  logic [CW-1:0] credits;
  logic [H-1:0]  seq, prom;
  logic          go;
  assign go = want && (credits != '0) && !s_stall;

  always_ff @(posedge clk) begin
    if (!rst_n) begin
      s_valid <= 1'b0;
      credits <= CW'(DEPTH);
      seq     <= '0;
    end else begin
      s_valid <= go;
      if (go) begin
        prom <= seq;
        seq  <= seq + 1'b1;
      end
      if (go && !s_credit)      credits <= credits - 1'b1;
      else if (!go && s_credit) credits <= credits + 1'b1;
    end
  end
  // The lead with valid; the rest of the promised message a cycle later.
  always_ff @(posedge clk) begin
    if (!rst_n)       s_payload <= '0;
    else begin
      if (go)      s_payload[H-1:0] <= seq;
      if (s_valid) s_payload[W-1:H] <= prom;
    end
  end
  assign s_wake = 1'b0;
  assign s_tid  = '0;

  // -- the link ------------------------------------------------------------
  logic          r_valid, r_credit, r_stall, r_wake;
  logic [W-1:0]  r_payload;
  logic [63:0]   r_tid;
  ccv_seq_rpt #(.STAGES(N), .SLOTS(1), .PAYLOAD_W(W), .LEAD_MASK(LEAD)) u_rpt (
    .clk(clk), .rst_n(rst_n),
    .src_valid(s_valid), .src_payload(s_payload), .src_wake(s_wake),
    .src_credit(s_credit), .src_stall(s_stall),
    .dst_valid(r_valid), .dst_payload(r_payload), .dst_wake(r_wake),
    .dst_credit(r_credit), .dst_stall(r_stall)
`ifdef CCV_TRACE
    , .src_tid(s_tid), .dst_tid(r_tid)
`endif
  );

  // -- the receiver ----------------------------------------------------------
  logic          landing;
  logic [H-1:0]  lead_q, expect_q;
  logic [CW-1:0] occ;
  wire [CW-1:0]  avail = occ + {{(CW-1){1'b0}}, landing};
  wire           pop = pop_en && (avail != '0);
`ifdef FV_MUT_DOUBLE_POP
  wire           pop_two = pop && pop2 && (avail >= CW'(2));
`else
  wire           pop_two = 1'b0;
`endif
  always_ff @(posedge clk) begin
    if (!rst_n) begin
      landing  <= 1'b0;
      occ      <= '0;
      expect_q <= '0;
      r_credit <= 1'b0;
      r_stall  <= 1'b0;
    end else begin
      landing  <= r_valid;
      if (r_valid) lead_q <= r_payload[H-1:0];
      if (landing) expect_q <= expect_q + 1'b1;
      occ      <= avail - {{(CW-1){1'b0}}, pop} - {{(CW-1){1'b0}}, pop_two};
      r_credit <= pop;               // ONE credit, whatever was consumed
      r_stall  <= stall_in;
    end
  end

  // -- the interface checker, at both ends of the link ----------------------
  localparam int RT = ccv_params_pkg::CCV_RT_ABUT + 2 * N;
  ccv_credit_checker #(.PAYLOAD_W(W), .ROUND_TRIP(RT), .DEPTH(DEPTH),
                       .TIMEOUT_N(ccv_prov_pkg::CCV_P_TIMEOUT_N + 2 * N),
                       .LEAD_MASK(LEAD), .SRC_STAGES(0)) u_chk_src (
    .clk(clk), .rst_n(rst_n), .ch_valid(s_valid), .ch_payload(s_payload),
    .ch_credit(s_credit), .ch_stall(s_stall)
`ifdef CCV_TRACE
    , .ch_tid(s_tid)
`endif
  );
  ccv_credit_checker #(.PAYLOAD_W(W), .ROUND_TRIP(RT), .DEPTH(DEPTH),
                       .TIMEOUT_N(ccv_prov_pkg::CCV_P_TIMEOUT_N + 2 * N),
                       .LEAD_MASK(LEAD), .SRC_STAGES(N)) u_chk_dst (
    .clk(clk), .rst_n(rst_n), .ch_valid(r_valid), .ch_payload(r_payload),
    .ch_credit(r_credit), .ch_stall(r_stall)
`ifdef CCV_TRACE
    , .ch_tid(r_tid)
`endif
  );

  // -- bookkeeping for the properties: event counts, modulo 2^KW ------------
  logic [KW-1:0] n_go, n_land, n_consumed, n_credit_out, n_credit_in;
  always_ff @(posedge clk) begin
    if (!rst_n) begin
      n_go <= '0; n_land <= '0; n_consumed <= '0;
      n_credit_out <= '0; n_credit_in <= '0;
    end else begin
      n_go         <= n_go + KW'(go);
      n_land       <= n_land + KW'(landing);
      n_consumed   <= n_consumed + KW'(pop) + KW'(pop_two);
      n_credit_out <= n_credit_out + KW'(r_credit);
      n_credit_in  <= n_credit_in + KW'(s_credit);
    end
  end
  // On the link: launched, not yet landed; credits sent, not yet arrived.
  wire [KW-1:0] fwd  = n_go - n_land;
  wire [KW-1:0] back = n_credit_out - n_credit_in;
  wire [KW-1:0] owed = n_consumed - n_credit_out;   // consumed, credit not yet sent

  `CCV_ASSERT(data_in_order,
              !landing || (lead_q == expect_q && r_payload[W-1:H] == expect_q))
  `CCV_ASSERT(no_overflow, occ <= CW'(DEPTH))
  // Every message consumed before this cycle has had its credit sent, but
  // the last cycle's, which is the credit register now: exactly r_credit.
  `CCV_ASSERT(credit_per_msg, owed == KW'(r_credit))
  // The physical count: credits the sender holds, messages on the link and in
  // the buffer, the credit register, credits on the way back -- DEPTH, always.
  `CCV_ASSERT(conservation,
              KW'(credits) + fwd + KW'(occ) + KW'(r_credit) + back == KW'(DEPTH))

  // FV_FAIR, the receiver's side of response_within_n: it drains, never more
  // than two cycles in a row without trying, so a message waits at most
  // ~3 * DEPTH plus the loop -- inside TIMEOUT_N. Without it a free receiver
  // holds a message for ever and the bounded-response check is RIGHT to
  // fail. ONLY for that check: the first version assumed it everywhere, and
  // the reach_full witness came back unreachable -- the safety proofs had
  // never seen a full buffer.
  logic [1:0] idle_run;
  always_ff @(posedge clk) begin
    if (!rst_n)      idle_run <= '0;
    else if (pop_en) idle_run <= '0;
    else             idle_run <= idle_run + 2'd1;
  end
`ifdef FV_FAIR
  always @(*) if (rst_n) assume (idle_run < 2'd2 || pop_en);
`endif

`ifdef FV_GREEDY
  // The sender always has something; the receiver always drains, never stalls.
  always @(*) begin
    assume (want);
    assume (pop_en);
    assume (!stall_in);
  end
  `CCV_ASSERT(full_bandwidth, go)
`endif

  // Non-vacuity, as assertions that must FAIL (tools/check-formal.sh): a
  // counterexample to each is the witness that three messages are delivered
  // and that the buffer fills, under exactly the proofs' assumptions.
`ifdef FV_REACH
  `CCV_ASSERT(reach_three, n_land != KW'(3))
  `CCV_ASSERT(reach_full, occ != CW'(DEPTH))
`endif

endmodule

`undef CCV_CLK
`undef CCV_RST
