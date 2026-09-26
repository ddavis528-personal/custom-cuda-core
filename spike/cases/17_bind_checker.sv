// case: bind of an external checker
// expect_sim: CHECK
// expect_formal: CHECK
// aux: 17_bind_checker.aux.sv
//
// §9 prefers `bind` so properties live outside the RTL and stay naturally
// excluded from synthesis. The DUT below carries NO assertion; every check in
// this case arrives from the aux file. If a tool reports nothing here, `bind`
// silently dropped the checker and §9's placement rule cannot be used.
module dut (input logic clk, input logic rst, input logic a, input logic b, output logic o);
  assign o = a & b;
endmodule
