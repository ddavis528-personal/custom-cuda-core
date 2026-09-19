// case: immediate assume, isolated
// expect_sim: PARSE
// expect_formal: PROVE
// The cut-point mechanism again (case 12), restated in the immediate form, so
// that the matrix answers "can §7's black-boxing be done at all" independently
// of whether concurrent properties are available.
module dut (input logic clk, input logic rst, input logic a, input logic b, output logic o);
  assign o = a & b;
  always @(posedge clk) if (!rst) begin
    assume (!(a && !b));          // the black-boxed neighbour's contract
    assert (!(a && !o));          // provable only if the assume is honoured
  end
endmodule
