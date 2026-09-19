// case: s_eventually (strong/liveness operator)
// expect_sim: PARSE
// expect_formal: PARSE
// runners: iverilog,verilator,sby
// Liveness is how "a request is eventually answered" gets stated -- the
// deadlock class §8 Stage 5 exists to find. BMC cannot discharge it (that
// needs unbounded proof), so this cell asks only whether it survives the
// front end; a PARSE-FAIL means deadlock freedom has to be restated as a
// bounded-response property instead.
module dut (input logic clk, input logic rst, input logic a, input logic b, output logic o);
  assign o = a | b;
  a_live: assert property (@(posedge clk) disable iff (rst) a |-> s_eventually o);
endmodule
