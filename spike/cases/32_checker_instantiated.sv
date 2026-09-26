// case: checker instantiated directly (the adopted alternative to bind)
// expect_sim: CHECK
// expect_formal: CHECK
// aux: 32_checker_instantiated.aux.sv
//
// The same checker and the same property as case 31, connected by ordinary
// instantiation instead of `bind`. Read the two cases side by side: this is
// the evidence for the convention's §4 fallback, which the convention doc
// itself anticipated ("if support is uneven, checkers may need conditional
// instantiation inside design modules instead").
//
// Green in all three, and under formal the counterexample names the property
// through the instance path -- dut.u_chk.<name> -- which is what §5's
// divergence triage needs and what the bind path silently loses.
module dut (input logic clk, input logic rst, input logic a, input logic b, output logic o);
  assign o = a & b;
  chk u_chk (.clk(clk), .rst(rst), .a(a), .b(b));
endmodule
