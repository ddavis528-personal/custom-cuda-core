//===-- tb_wake_neg.sv - the wake contract, one case per boundary --------===//
//
// Spec: open item Q-33; rtl/if/ccv_wake_checker.sv
//
// Drives the checker's ports directly, written from the contract rather than
// from the checker: valid toward a gated receiver at T needs this channel's
// wake at or before T - LAT. Each FIRE case must trip wake_leads_valid and
// nothing else; each QUIET case sits at a legal limit and must stay silent.
// tools/check-if.sh runs every case on Icarus and Verilator.
//
// The receiver here is a model with a fixed wake latency: it gates at S and
// ungates LAT cycles after a wake -- except where a case says a DIFFERENT
// wake (another channel's) brought it up, which this checker cannot see.
//===----------------------------------------------------------------------===//
`timescale 1ns/1ps
module tb;
  localparam int LAT = ccv_params_pkg::CCV_WAKE_LAT;
  localparam int S = 4;                     // the receiver gates here
  localparam int T = S + 12;                // the valid

  logic  clk = 1'b0, rst_n = 1'b0;
  logic  g = 1'b0, w = 1'b0, v = 1'b0;
  string cname;
  int    c, wk, up;

  ccv_wake_checker u_chk (.clk(clk), .rst_n(rst_n), .rx_gated(g), .wake(w),
                          .valid(v));

  always #5 clk = ~clk;

  initial begin
    if (!$value$plusargs("case=%s", cname)) cname = "none";
    wk = -1;           // this channel's wake, if any
    up = 1 << 30;      // when the receiver's clock is running again
    if (cname == "wake_t3")               begin wk = T - 3; up = wk + LAT; end
    else if (cname == "wake_t4")          begin wk = T - 4; up = wk + LAT; end
    else if (cname == "early_wake")       begin wk = S - 2; end
    else if (cname == "other_wake")       begin up = T - LAT; end
    else if (cname == "other_wake_short") begin up = T - LAT + 1; end
    else if (cname == "resleep")          begin wk = S + 1; end

    $display("NEG_BEGIN %s LAT=%0d", cname, LAT);
    for (c = 0; c <= T + 3; c++) begin
      rst_n = (c >= 2);
      // Awake: never gates. Resleep: gated at S, woken, up, gated again at
      // S + 8 with no second wake. Everything else gates at S until `up`.
      if (cname == "awake")        g = 1'b0;
      else if (cname == "resleep") g = (c >= S && c < wk + LAT) || (c >= S + 8);
      else                         g = (c >= S && c < up);
      w = (c == wk);
      v = (c == T);
      @(posedge clk);
      #1;
    end
    $display("NEG_END %s", cname);
    $finish;
  end
endmodule
