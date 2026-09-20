`timescale 1ns/1ps
`include "ccv_if.svh"
// Drives one launch and prints the cycle at which it was observed, so the
// checker can derive the three correct event cycles on paper rather than
// trusting the instrument to describe itself.
module tb;
  logic clk = 1'b0, rst = 1'b1, go = 1'b0;
  logic done;
  int   launch_cycle = -1;
  int   c;

  emit_calib u_dut (.clk(clk), .rst(rst), .go(go), .done(done));
  always #5 clk = ~clk;

  initial begin
    $display("SPIKE_BEGIN");
`ifdef VERILATOR
    if (ccv_trace_open("emit_calib.ccvtrace") == 0)
      $display("CALIB: could not open trace");
`endif
    for (c = 0; c < 16; c++) begin
      rst = (c < 2);
      go  = (c == 4);
      if (c == 4) launch_cycle = c - 2;   // cycles counted from reset release
      @(posedge clk);
      #1;
    end
    $display("CALIB launch_cycle=%0d", launch_cycle);
`ifdef VERILATOR
    $display("CALIB events=%0d", ccv_trace_count());
    ccv_trace_close();
`endif
    $display("SPIKE_END");
    $finish;
  end
endmodule
