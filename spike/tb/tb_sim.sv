// Common simulation testbench for every Stage 1a case.
//
// One testbench, both simulators: Verilator 5's `--binary` mode compiles a
// SystemVerilog testbench directly, so Icarus and Verilator run the IDENTICAL
// stimulus against the IDENTICAL case file. Any difference in the matrix is
// then a difference in assertion support, not a difference in how the two were
// driven -- which is the only way the matrix means anything.
//
// Stimulus contract (spike/README.md): rst high for cycles 0-1, `a` high on
// cycle 3 only, `b` low always. Every case is written to be violated by it.
`timescale 1ns/1ps
module tb;
  logic clk = 1'b0;
  logic rst = 1'b1;
  logic a   = 1'b0;
  logic b   = 1'b0;
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
    end
    $display("SPIKE_END");
    $finish;
  end
endmodule
