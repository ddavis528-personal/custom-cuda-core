// Probe testbench for X-randomization under Verilator (§6, §8 Stage 1a).
//
// §6 records that 2-state simulation gives un-reset state a defined value, so
// a design that accidentally depends on un-reset payload passes every default
// run -- a structural blind spot, given 2-state-first sequencing. The stated
// mitigation is X-randomization across seeds: divergence between seeds
// indicates a real dependency on uninitialized state.
//
// "Confirm current flag behaviour in the 1a spike rather than assuming it" is
// what §6 asks for. This testbench prints the DUT output every cycle so the
// runner can diff two seeds byte for byte. Identical output across seeds with
// randomization requested means the mitigation is NOT in place, which would
// leave the blind spot open between the Icarus X-passes.
//
// Style note for anyone editing this file: no comment line here may BEGIN
// with the simulator's own name, because a leading `// <toolname> ...` is
// parsed as a metacomment pragma and rejected as an unknown one. That cost a
// build during the spike, and it is the sort of thing §9's style guide should
// carry so it costs nobody a second one.
`timescale 1ns/1ps
module tb;
  logic clk = 1'b0, rst = 1'b1, a = 1'b0, b = 1'b0;
  logic o;
  dut u_dut (.clk(clk), .rst(rst), .a(a), .b(b), .o(o));
  always #5 clk = ~clk;
  initial begin
    $display("SPIKE_BEGIN");
    for (int c = 0; c < 12; c++) begin
      rst = (c < 2);
      a   = (c == 3);
      b   = 1'b0;
      @(posedge clk);
      #1;
      $display("cyc=%0d o=%b", c, o);
    end
    $display("SPIKE_END");
    $finish;
  end
endmodule
