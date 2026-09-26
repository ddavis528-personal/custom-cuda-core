// case: default: <= 'x  X-injection
// expect_sim: CHECK
// expect_formal: SKIP
// runners: iverilog,verilator
// §6's first listed lint rule: an unreachable state assigns X rather than
// holding, so the bug is loud instead of silent. This case checks the X is
// really injected and really observable -- paired with an $isunknown guard,
// which is the combination §6 actually prescribes.
module dut (input logic clk, input logic rst, input logic a, input logic b, output logic o);
  logic [1:0] selc;
  logic       y;
  assign selc = {a, b};
  always_comb begin
    case (selc)
      2'b10:   y = 1'b1;
      2'b01:   y = 1'b0;
      default: y = 1'bx;          // explicit injection, not an implicit hold
    endcase
  end
  assign o = y;
  always @(posedge clk) if (!rst) begin
    assert (!$isunknown(y)) else $error("28: injected X observed");
  end
endmodule
