// case: restrict property
// expect_sim: PARSE
// expect_formal: PARSE
// Formal-only environment narrowing. Lower value than `assume`, listed because
// if it is available it keeps sim-inert constraints out of the `assume` class,
// which matters once §7's assert/assume role swap is being done at call sites.
module dut (input logic clk, input logic rst, input logic a, input logic b, output logic o);
  assign o = a & b;
  r_env: restrict property (@(posedge clk) disable iff (rst) !(a && b));
endmodule
