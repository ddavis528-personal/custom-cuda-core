// case: label on an immediate assert
// expect_sim: CHECK
// expect_formal: CHECK
// Labels are not cosmetic here. §7's runtime knob targets a scope, failure
// reports name the property, and §5's divergence triage needs a mismatch to
// say WHICH property. If a tool rejects labels, the primitive library has to
// synthesise the name some other way -- which is a library design constraint,
// not a style preference.
module dut (input logic clk, input logic rst, input logic a, input logic b, output logic o);
  assign o = a & b;
  always @(posedge clk) if (!rst) begin
    a_labelled: assert (!(a && !b)) else $error("23: labelled assert fired");
  end
endmodule
