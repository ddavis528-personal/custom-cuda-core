// case: immediate assert
// expect_sim: CHECK
// expect_formal: CHECK
// The floor. If this cell is not green in a tool, that tool is out of the flow.
module dut (input logic clk, input logic rst, input logic a, input logic b, output logic o);
  assign o = a & b;
  always @(posedge clk) if (!rst) begin
    // violated at cycle 3, where a=1 and b=0
    assert (!(a && !b)) else $error("01: immediate assert fired");
  end
endmodule
