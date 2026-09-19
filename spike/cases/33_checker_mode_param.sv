// case: MODE parameter resolving assert / assume / cover
// expect_sim: CHECK
// expect_formal: PROVE
// aux: 33_checker_mode_param.aux.sv
//
// The interface convention §3.1 mechanism: one checker per interface type,
// instantiated in ASSERT mode on a block's outputs and ASSUME mode on its
// inputs, so formal cut-points fall out of the convention rather than being
// hand-built per block.
//
// The assert/assume/cover KEYWORD cannot be selected by a parameter directly.
// A `generate` picks the branch at elaboration, which is what makes the mode
// parameter implementable at all -- and it works in all three tools.
//
// The formal column is the real check. PROVE-PASS means the input-side ASSUME
// genuinely constrained the solver: the output-side assert is false without
// it. The negative control (input checker in ASSERT mode instead) returns
// FAIL, which is what makes the PASS meaningful rather than trivial.
module dut (input logic clk, input logic rst, input logic a, input logic b, output logic o);
  assign o = a & b;
  chk #(.MODE(1)) u_in  (.clk(clk), .rst(rst), .a(a), .b(b));   // ASSUME
  chk #(.MODE(0)) u_out (.clk(clk), .rst(rst), .a(a), .b(o));   // ASSERT
endmodule
