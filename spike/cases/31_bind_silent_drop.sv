// case: bind of a checker (interface convention §4)
// expect_sim: CHECK
// expect_formal: CHECK
// aux: 31_bind_silent_drop.aux.sv
//
// Supersedes case 17, which asked the same question and could not answer it:
// 17's checker used a LABELLED CONCURRENT property, which Icarus and Yosys
// reject on their own account, so its PARSE-FAIL cells said nothing about
// `bind`. This checker uses only the all-three intersection, so every verdict
// here is about binding and nothing else.
//
// The interface checker convention §4 rests entirely on this: "Connection via
// `bind`, not instantiation inside design modules."
//
// Read the sby column carefully. Yosys PARSES the bind, ignores it, and then
// garbage-collects the checker -- `Removing unused module '\chk'` -- so BMC
// passes a property written to be false. That is a SILENT drop, not a parse
// error: a formal run would be green and mean nothing. Compare case 32.
module dut (input logic clk, input logic rst, input logic a, input logic b, output logic o);
  assign o = a & b;
endmodule
