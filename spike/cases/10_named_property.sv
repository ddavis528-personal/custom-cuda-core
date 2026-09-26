// case: named sequence/property
// expect_sim: CHECK
// expect_formal: CHECK
// The primitive library (1b) is unusable if properties cannot be named and
// reused, so this cell gates the library's whole shape, not just a construct.
module dut (input logic clk, input logic rst, input logic a, input logic b, output logic o);
  assign o = a & b;
  sequence s_req; a; endsequence
  property p_req_then_ack; @(posedge clk) disable iff (rst) s_req |-> b; endproperty
  a_named: assert property (p_req_then_ack) else $error("10: named property fired");
endmodule
