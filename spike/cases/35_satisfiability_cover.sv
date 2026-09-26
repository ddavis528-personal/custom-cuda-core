// case: satisfiability cover catches the vacuous assume set
// expect_sim: PARSE
// expect_formal: COVER
//
// The guard §3.3 makes mandatory, against the failure case 34 demonstrates.
// Same contradictory assume set; instead of an assert, a cover asking whether
// the assumed state is reachable at all.
//
// COVER-MISS is the PASS condition here, and it is the whole point: the cover
// is unreachable precisely because the assumptions contradict each other. A
// cover that cannot be reached is the only signal available that a green
// proof was green for the wrong reason.
//
// This is why the convention requires covers to run ALONGSIDE any proof that
// relies on the assumption set, not as a separate optional pass -- a proof
// whose guard was never run carries exactly as much information as no proof.
module dut (input logic clk, input logic rst, input logic a, input logic b, output logic o);
  assign o = a & b;
  always @(posedge clk) if (!rst) begin
    assume (a == 1'b1);
    assume (a == 1'b0);      // contradictory, as in case 34
    cover (a == 1'b1);       // unreachable: the guard fires
  end
endmodule
