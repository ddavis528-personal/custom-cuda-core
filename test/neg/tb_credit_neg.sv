`timescale 1ns/1ps
`include "ccv_if.svh"
`include "ccv_params_pkg.sv"
// Negative controls for the credit checker's PROTOCOL properties.
//
// Each case breaks exactly one rule of the credited protocol and must trip
// exactly one property, by name. The cases are written from the PROTOCOL
// (docs/interface-checker-convention.md, schema/interfaces.json) rather than
// from reading the checker: a control written from the implementation gets
// written to match whatever the implementation already does, which is the
// failure docs/fail-open-register.md names in advance.
//
// Two kinds of case:
//   FIRE   one rule broken; the named property must fire, nothing else
//   QUIET  a legal extreme -- exactly at a limit; nothing may fire
// A pair of them brackets each counter, because an off-by-one in a tracking
// register is invisible to a case that only ever overshoots by a mile.
//
// Drives the checker's ports directly, one case per run, selected by
// +case=<name>. Cycle c's values are sampled at the posedge ending cycle c.
// The protocol, stated once so each case can be read against it:
//   - a credit is consumed at the edge that samples valid
//   - the payload is due one cycle after valid
//   - at most DEPTH messages outstanding
//   - no valid in the cycle after a stall
//   - a credit returned with nothing outstanding is an error
//   - a message outstanding for MORE than N cycles is an error, counting
//     from the edge that consumed its credit
module tb;
  localparam int D = ccv_params_pkg::CCV_CREDIT_DEPTH;
  localparam int N = ccv_prov_pkg::CCV_P_TIMEOUT_N;
  localparam int S = 4;                     // first cycle after reset settles

  logic        clk = 1'b0, rst_n = 1'b0;
  logic        v = 1'b0, cr = 1'b0, st = 1'b0;
  logic [31:0] pl = '0;
  string       cname;
  int          c, last;

  // The low byte LEADS: it is due with valid (lead_known_at_valid). No other
  // case drives it unknown, so the mask changes no other case's result.
  ccv_credit_checker #(.PAYLOAD_W(32), .LEAD_MASK(32'h0000_00ff)) u_chk (
    .clk(clk), .rst_n(rst_n), .ch_valid(v), .ch_payload(pl),
    .ch_credit(cr), .ch_stall(st));

  always #5 clk = ~clk;

  initial begin
    if (!$value$plusargs("case=%s", cname)) cname = "none";

    // How long each case runs. For a FIRE case this is the protocol's
    // deadline plus at most ONE cycle of detection latency -- a check that
    // fires later than that is late, and late is a failure here. For a QUIET
    // case it runs past the limit far enough that a late fire would show.
    if      (cname == "overrun")        last = S + D + 4;
    else if (cname == "at_depth")       last = S + 2*D + 8;
    else if (cname == "phantom")        last = S + 4;
    else if (cname == "phantom_with_send") last = S + 4;
    else if (cname == "stall")          last = S + 6;
    else if (cname == "xpayload")       last = S + 6;
    else if (cname == "xlead")          last = S + 6;
    else if (cname == "xlead_before")   last = S + 6;
    else if (cname == "timeout")        last = S + N + 2;
    else if (cname == "timeout_at_n")   last = S + N + 6;
    else if (cname == "timeout_n1")     last = S + N + 2;
    else if (cname == "timeout_second") last = S + N + 3;
    else if (cname == "second_late")    last = S + N + 3;
    else                                last = S + 8;

    $display("NEG_BEGIN %s D=%0d N=%0d", cname, D, N);
    for (c = 0; c <= last; c++) begin
      rst_n = (c >= 2);
      v  = 1'b0;
      cr = 1'b0;
      st = 1'b0;
      pl = 32'hd0d0_0000 + c;               // known, unless a case says not

      // D+1 sends with no credit back: one more than may be outstanding.
      if (cname == "overrun")
        v = (c >= S && c < S + D + 1);

      // Exactly D outstanding, held, then all returned. The legal extreme.
      else if (cname == "at_depth") begin
        v  = (c >= S && c < S + D);
        cr = (c >= S + D + 4 && c < S + 2*D + 4);
      end

      // A credit back with nothing ever sent.
      else if (cname == "phantom")
        cr = (c == S);

      // A credit on the SAME edge that consumes a send, nothing outstanding
      // before it. The round trip is at least 2, so this credit cannot belong
      // to that message: it is a phantom that happens to coincide with a send.
      else if (cname == "phantom_with_send") begin
        v  = (c == S);
        cr = (c == S);
      end

      // Stall, then a send in the very next cycle.
      else if (cname == "stall") begin
        st = (c == S);
        v  = (c == S + 1);
        cr = (c == S + 3);
      end

      // Valid is binding: the payload due the cycle after is unknown.
      else if (cname == "xpayload") begin
        v  = (c == S);
        if (c == S + 1) pl = 'x;
        cr = (c == S + 3);
      end

      // A lead field is due WITH valid: unknown in the valid cycle, known
      // after, and the rest of the payload always known.
      else if (cname == "xlead") begin
        v  = (c == S);
        if (c == S) pl[7:0] = 'x;
        cr = (c == S + 3);
      end

      // The legal limit: the lead bits unknown the cycle BEFORE valid, and
      // known from valid on. Must be quiet.
      else if (cname == "xlead_before") begin
        v  = (c == S);
        if (c == S - 1) pl[7:0] = 'x;
        cr = (c == S + 3);
      end

      // One send, credit never comes back.
      else if (cname == "timeout")
        v = (c == S);

      // Credit back exactly N cycles after the send: outstanding for N,
      // which is not MORE than N. Must be quiet.
      else if (cname == "timeout_at_n") begin
        v  = (c == S);
        cr = (c == S + N);
      end

      // Credit back N+1 cycles after the send: one cycle too late.
      else if (cname == "timeout_n1") begin
        v  = (c == S);
        cr = (c == S + N + 1);
      end

      // Two sends; the FIRST is answered promptly, the SECOND never is. The
      // bound is per message, so the second must trip on its own clock.
      else if (cname == "timeout_second") begin
        v  = (c == S || c == S + 1);
        cr = (c == S + 2);
      end

      // As above, but the first answer arrives at exactly N -- legal -- which
      // is the worst case for a counter that restarts when the oldest message
      // is answered: the second message's clock would restart at N.
      else if (cname == "second_late") begin
        v  = (c == S || c == S + 1);
        cr = (c == S + N);
      end

      @(posedge clk);
      #1;
    end
    $display("NEG_END %s", cname);
    $finish;
  end
endmodule
