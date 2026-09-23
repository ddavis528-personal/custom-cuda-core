`timescale 1ns/1ps
`include "ccv_if.svh"
// Drives the pair with bursts and stalls, so the stall path and the
// satisfiability covers are genuinely exercised rather than merely present.
module tb;
  logic clk = 1'b0, rst_n = 1'b0, want_send = 1'b0, rx_stall = 1'b0;
  logic ch_valid, ch_credit, ch_stall;
  int   c;

  credit_smoke u_dut (.clk(clk), .rst_n(rst_n), .want_send(want_send),
                      .rx_stall(rx_stall), .ch_valid(ch_valid),
                      .ch_credit(ch_credit), .ch_stall(ch_stall));
  always #5 clk = ~clk;

  initial begin
    $display("SPIKE_BEGIN");
`ifdef VERILATOR
    if (ccv_trace_open("credit.ccvtrace") == 0)
      $display("CCV: could not open trace");
`endif
    for (c = 0; c < 40; c++) begin
      rst_n     = (c >= 2);
      want_send = (c >= 4);              // sustained offered load
      rx_stall  = (c >= 10) && (c < 13); // a stall window mid-stream
      @(posedge clk);
      #1;
    end
    $display("SPIKE_END");
`ifdef VERILATOR
    $display("TRACE_EVENTS %0d", ccv_trace_count());
    ccv_trace_close();
`endif
    $finish;
  end
endmodule
