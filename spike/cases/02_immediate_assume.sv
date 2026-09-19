// case: immediate assume
// expect_sim: PARSE
// expect_formal: PARSE
// Largely inert in simulation by design (§7) -- this cell only establishes that
// it does not break the compile, so that one source can feed both flows.
module dut (input logic clk, input logic rst, input logic a, input logic b, output logic o);
  assign o = a & b;
  always @(posedge clk) if (!rst) begin
    assume (b == 1'b0);
  end
endmodule
