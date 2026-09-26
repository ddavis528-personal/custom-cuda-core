//===-- tb_seq_rpt.sv - a credited channel through sequential repeaters ---===//
//
// Spec: docs/physical.md, "Sequential repeaters"; rtl/phys/ccv_seq_rpt.sv
//
// A sender and a receiver that follow the channel protocol at their own
// ports, with N repeater stages between them, split into two repeaters so a
// checker can also sit mid-link. The credit depth is the repeated round trip,
// CCV_RT_ABUT + 2N. What must hold, for N = 0..4, on both simulators:
//
//   - the credit checker is quiet at the sender (SRC_STAGES 0), mid-link
//     (M) and at the receiver (N), all with the link's ROUND_TRIP;
//   - every message arrives, in order, with every payload bit, its lead
//     slice and its trace id;
//   - valid, wake, payload and tid arrive exactly N cycles later, and
//     credit and stall return exactly N cycles later;
//   - +full (always send, always consume, never stall) measures the rate.
//     A credit's whole loop is 2 + CCV_RT_ABUT + 2N cycles: valid, payload
//     landing, credit registered, credit usable, plus the wire both ways.
//     So the rate is depth / (4 + 2N):
//       depth CCV_CREDIT_DEPTH + 2N, the whole loop    one message a cycle:
//         (the default, Q-43)                          full bandwidth
//       +rtdepth: depth CCV_RT_ABUT + 2N, the round    (2 + 2N) / (4 + 2N):
//         trip, as depth was before Q-43               the old half rate
//       +shallow: depth CCV_RT_ABUT, as if nobody        2 / (4 + 2N): what a
//         deepened the credits for the link              repeated link that
//                                                      forgot does, with no
//                                                      protocol violation
//
// Printed: RPT N=.. sent=.. received=.. data_errors=.. latency_errors=..
// overflow=.. rate_x1000=..
//===----------------------------------------------------------------------===//
`timescale 1ns/1ps
module tb;
`ifndef RPT_N
  `define RPT_N 2
`endif
  localparam int N  = `RPT_N;
  localparam int M  = N / 2;              // mid-link checker after M stages
  localparam int W  = 20;
  localparam logic [W-1:0] LEAD = 20'h0000f;   // a 4-bit lead slice
  localparam int RT = ccv_params_pkg::CCV_RT_ABUT + 2 * N;
  // The response bound grows with the link as well: 2N more cycles of wire.
  localparam int TO = ccv_prov_pkg::CCV_P_TIMEOUT_N + 2 * N;
  localparam int CYCLES = 3000;

  logic clk = 1'b0, rst_n = 1'b0;
  always #5 clk = ~clk;

  // -- the sender, at its own port -------------------------------------------
  logic         s_valid, s_wake, s_credit, s_stall;
  logic [W-1:0] s_payload, promised;
  logic [63:0]  s_tid, promised_tid;
  int           credits, depth, sent;
  bit           full, shallow, rtdepth;
  function automatic logic [W-1:0] msg_of(int seq);
    return W'(seq * 32'h9e3779b1 ^ (seq << 7));
  endfunction

  // Testbench models, not design: blocking temporaries at module scope
  // (Icarus has no `automatic` inside an always block).
  bit           go;
  logic [W-1:0] m, pay;
  always @(posedge clk) begin
    if (!rst_n) begin
      s_valid <= 1'b0; s_wake <= 1'b0; credits <= depth; sent <= 0;
      s_payload <= '0; s_tid <= '0;
    end else begin
      go = (full || $urandom % 3 != 0) && credits != 0 && !s_stall;
      m = msg_of(sent);
      pay = s_payload;
      // The payload promised by the valid up THIS cycle lands next cycle...
      if (s_valid) begin
        pay = (pay & LEAD) | (promised & ~LEAD);
        s_tid <= promised_tid;
      end
      // ...and a new message's lead slice goes out WITH its valid.
      if (go) begin
        pay = (pay & ~LEAD) | (m & LEAD);
        promised <= m;
        promised_tid <= 64'(sent);
        sent <= sent + 1;
      end
      s_payload <= pay;
      s_valid <= go;
      s_wake <= ($urandom % 11 == 0);
      if (go && !s_credit) credits <= credits - 1;
      else if (!go && s_credit) credits <= credits + 1;
    end
  end

  // -- the link: M stages, a checker point, N - M stages ---------------------
  logic         m_valid, m_wake, m_credit, m_stall;
  logic [W-1:0] m_payload;
  logic [63:0]  m_tid;
  logic         r_valid, r_wake, r_credit, r_stall;
  logic [W-1:0] r_payload;
  logic [63:0]  r_tid;

  ccv_seq_rpt #(.STAGES(M), .PAYLOAD_W(W), .LEAD_MASK(LEAD)) u_rpt_a (
    .clk, .rst_n,
    .src_valid(s_valid), .src_payload(s_payload), .src_wake(s_wake),
    .src_credit(s_credit), .src_stall(s_stall),
    .dst_valid(m_valid), .dst_payload(m_payload), .dst_wake(m_wake),
    .dst_credit(m_credit), .dst_stall(m_stall),
    .src_tid(s_tid), .dst_tid(m_tid));
  ccv_seq_rpt #(.STAGES(N - M), .PAYLOAD_W(W), .LEAD_MASK(LEAD)) u_rpt_b (
    .clk, .rst_n,
    .src_valid(m_valid), .src_payload(m_payload), .src_wake(m_wake),
    .src_credit(m_credit), .src_stall(m_stall),
    .dst_valid(r_valid), .dst_payload(r_payload), .dst_wake(r_wake),
    .dst_credit(r_credit), .dst_stall(r_stall),
    .src_tid(m_tid), .dst_tid(r_tid));

  // -- the checker, at three points along the link ---------------------------
`ifdef RPT_WRONG_SKID
  // Negative control: the receiver-end checker told it sits at the sender.
  // The valids already in flight when the receiver stalls must trip it.
  localparam int RX_SRC = 0;
`else
  localparam int RX_SRC = N;
`endif
  ccv_credit_checker #(.PAYLOAD_W(W), .ROUND_TRIP(RT), .DEPTH(RT + 2), .TIMEOUT_N(TO), .LEAD_MASK(LEAD),
                       .SRC_STAGES(0)) u_chk_src (
    .clk, .rst_n, .ch_valid(s_valid), .ch_payload(s_payload),
    .ch_credit(s_credit), .ch_stall(s_stall), .ch_tid(s_tid));
  ccv_credit_checker #(.PAYLOAD_W(W), .ROUND_TRIP(RT), .DEPTH(RT + 2), .TIMEOUT_N(TO), .LEAD_MASK(LEAD),
                       .SRC_STAGES(M)) u_chk_mid (
    .clk, .rst_n, .ch_valid(m_valid), .ch_payload(m_payload),
    .ch_credit(m_credit), .ch_stall(m_stall), .ch_tid(m_tid));
  ccv_credit_checker #(.PAYLOAD_W(W), .ROUND_TRIP(RT), .DEPTH(RT + 2), .TIMEOUT_N(TO), .LEAD_MASK(LEAD),
                       .SRC_STAGES(RX_SRC)) u_chk_dst (
    .clk, .rst_n, .ch_valid(r_valid), .ch_payload(r_payload),
    .ch_credit(r_credit), .ch_stall(r_stall), .ch_tid(r_tid));

  // -- the receiver, at its own port ------------------------------------------
  logic [W-1:0] leads[$];
  logic         landing;
  int           buffered, received, data_errors, overflow;
  int           b;
  bit           pop;
  logic [W-1:0] got;
  always @(posedge clk) begin
    if (!rst_n) begin
      landing <= 1'b0; buffered <= 0; received <= 0; data_errors <= 0;
      overflow <= 0; r_credit <= 1'b0; r_stall <= 1'b0;
    end else begin
      b = buffered;
      if (landing) begin
        // The lead was taken in the valid cycle; the rest lands now.
        got = (r_payload & ~LEAD) | leads.pop_front();
        if (got !== msg_of(received) || r_tid !== 64'(received)) begin
          if (data_errors < 4)
            $display("RPT_DATA N=%0d message %0d: got %h tid %0d, want %h",
                     N, received, got, r_tid, msg_of(received));
          data_errors <= data_errors + 1;
        end
        received <= received + 1;
        b = b + 1;
      end
      if (r_valid) leads.push_back(r_payload & LEAD);
      landing <= r_valid;
      if (b > depth) overflow <= overflow + 1;
      pop = b != 0 && (full || $urandom % 4 != 0);
      r_credit <= pop;
      buffered <= b - (pop ? 1 : 0);
      r_stall <= !full && ($urandom % 9 == 0);
    end
  end

  // -- exactly N cycles, every signal, both directions ----------------------
  localparam int HL = N + 1;
  logic [HL-1:0] h_valid, h_wake, h_credit, h_stall;
  int latency_errors;
  always @(posedge clk) begin
    h_valid  <= HL'({h_valid, s_valid});
    h_wake   <= HL'({h_wake, s_wake});
    h_credit <= HL'({h_credit, r_credit});
    h_stall  <= HL'({h_stall, r_stall});
  end
  // Compared off the edge, once the history is full.
  int c = 0;
  logic [HL:0] hv, hw, hc, hs;
  always @(negedge clk) begin
    c <= c + 1;
    if (rst_n && c > N + 2) begin
      hv = {h_valid, s_valid}; hw = {h_wake, s_wake};
      hc = {h_credit, r_credit}; hs = {h_stall, r_stall};
      if (r_valid !== hv[N] || r_wake !== hw[N] ||
          s_credit !== hc[N] || s_stall !== hs[N]) begin
        if (latency_errors < 4)
          $display("RPT_LATENCY N=%0d cycle %0d: valid %b/%b wake %b/%b credit %b/%b stall %b/%b",
                   N, c, r_valid, hv[N], r_wake, hw[N], s_credit, hc[N], s_stall, hs[N]);
        latency_errors <= latency_errors + 1;
      end
    end
  end

  // -- the run ------------------------------------------------------------
  int t0, r0;
  initial begin
    full = $test$plusargs("full");
    shallow = $test$plusargs("shallow");
    rtdepth = $test$plusargs("rtdepth");
    depth = shallow ? ccv_params_pkg::CCV_RT_ABUT : rtdepth ? RT
          : ccv_params_pkg::CCV_CREDIT_DEPTH + 2 * N;
    latency_errors = 0;
    repeat (2) @(posedge clk);
    #1 rst_n = 1'b1;
    repeat (CYCLES / 2) @(posedge clk);
    t0 = c; r0 = received;
    repeat (CYCLES / 2) @(posedge clk);
    $display("RPT N=%0d depth=%0d sent=%0d received=%0d data_errors=%0d latency_errors=%0d overflow=%0d rate_x1000=%0d",
             N, depth, sent, received, data_errors, latency_errors, overflow,
             (received - r0) * 1000 / (c - t0));
    $finish;
  end
endmodule
