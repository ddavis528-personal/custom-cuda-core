// case: contradictory assume set makes a proof vacuously true
// expect_sim: CHECK
// expect_formal: CHECK
//
// The interface convention §3.3 calls this "the single most dangerous failure
// mode in the whole formal strategy, because it produces false confidence
// rather than a visible error". This case makes it happen on purpose, so the
// claim is demonstrated rather than asserted.
//
// The assumes below cannot both hold. Everything downstream of them is
// therefore vacuously true, INCLUDING `assert (1'b0)` -- a property that
// cannot hold under any circumstances. Read the sby column: it says SILENT,
// which in this matrix means "BMC passed a property written to be false".
// The run is green, there is no counterexample, and it means nothing.
//
// Nothing about the output distinguishes this from a real proof. That is why
// §3.3 makes satisfiability covers mandatory rather than advisory, and case
// 35 is the guard that catches exactly this.
module dut (input logic clk, input logic rst, input logic a, input logic b, output logic o);
  assign o = a & b;
  always @(posedge clk) if (!rst) begin
    assume (a == 1'b1);
    assume (a == 1'b0);      // contradictory with the line above
    assert (1'b0);           // cannot hold -- and yet the proof passes
  end
endmodule
