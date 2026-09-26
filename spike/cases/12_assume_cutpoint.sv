// case: assume as formal cut-point
// expect_sim: PARSE
// expect_formal: PROVE
// runners: iverilog,verilator,sby
//
// The §7 cut-point mechanism, in miniature. `b` stands in for a black-boxed
// neighbour's output; the `assume` is the contract that neighbour would have
// guaranteed. With the assume honoured the assert is provable; with the assume
// dropped it is trivially false. So PASS here is positive evidence that
// `assume` restricts the search space -- which no parse check can establish.
module dut (input logic clk, input logic rst, input logic a, input logic b, output logic o);
  assign o = a & b;
  m_neighbour: assume property (@(posedge clk) disable iff (rst) a |-> b);
  a_cut:       assert property (@(posedge clk) disable iff (rst) a |-> o);
endmodule
