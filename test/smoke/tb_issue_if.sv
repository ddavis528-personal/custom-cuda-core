`timescale 1ns/1ps
`include "ccv_if.svh"
// Drives the producer with stalls, so the stall-dependent properties and the
// stall satisfiability cover are actually exercised rather than merely present.
module tb;
  logic clk = 1'b0;
  logic rst = 1'b1;
  logic iss_ready;
  issue_t iss;

  issue_producer u_dut (.clk(clk), .rst(rst), .iss_ready(iss_ready), .iss(iss));

  always #5 clk = ~clk;

  initial begin
    $display("SPIKE_BEGIN");
    // Guarded: Icarus has no DPI at all (F-13), so the same testbench has to
    // run there too, without a trace. That is the X-pass configuration.
`ifdef VERILATOR
    if (ccv_trace_open("issue_if.ccvtrace") == 0)
      $display("CCV: could not open trace");
`endif
    for (int c = 0; c < 24; c++) begin
      rst = (c < 2);
      // Stall every third cycle once running, so stalls are reached.
      iss_ready = (c >= 2) && ((c % 3) != 0);
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
