// case: $past as a system function in an immediate assert
// expect_sim: CHECK
// expect_formal: CHECK
// §7 names a "$past-based sequence" as one of the three properties the spike
// must confirm. Case 07 asks it in concurrent form; this asks it in the
// immediate form, because if the concurrent form is unavailable this is the
// only way the same property can be stated.
module dut (input logic clk, input logic rst, input logic a, input logic b, output logic o);
  assign o = a & b;
  always @(posedge clk) if (!rst) begin
    assert (!($past(a) && !b)) else $error("24: $past fired");
  end
endmodule
