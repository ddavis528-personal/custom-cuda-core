// case: immediate cover
// expect_sim: COVER
// expect_formal: COVER
module dut (input logic clk, input logic rst, input logic a, input logic b, output logic o);
  assign o = a & b;
  always @(posedge clk) if (!rst) begin
    cover (a);
  end
endmodule
