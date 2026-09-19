//===-- issue_if_smoke.sv - interface convention exit criteria ----------===//
//
// Spec: docs/interface-checker-convention.md
//
// A protocol-CORRECT producer, so the checker's properties must all hold. That
// polarity is the point: the spike cases prove the machinery can fire, and this
// proves it does not fire at everything, which a checker with a botched
// polarity would also do and which a "does it fire" test alone would pass.
//
// Exercises, in one module, every part of the convention that has a mechanism:
// the packed-struct port (§2), the checker instantiated rather than bound (§4,
// F-9), the mode parameter (§3.1), the satisfiability covers (§3.3), and
// emission from the checker (§5).
//===----------------------------------------------------------------------===//
`include "ccv_if.svh"

module issue_producer (
  input  logic   clk,
  input  logic   rst,
  input  logic   iss_ready,
  output issue_t iss
);

  logic [5:0] next_tag;

  always_ff @(posedge clk) begin
    if (rst) begin
      iss      <= '0;
      next_tag <= 6'd0;
    end else if (!iss.valid || iss_ready) begin
      // Only move when the current beat is not stalled. That is what makes
      // valid-stability and payload-stability hold rather than being asserted
      // and hoped for.
      iss.valid   <= 1'b1;
      iss.payload <= iss.payload + 32'd1;
      iss.tag     <= next_tag;
      next_tag    <= next_tag + 6'd1;
    end
  end

  // Checker instantiated, not bound (F-9). Mode comes from the side macro, so
  // a standalone formal run re-roles it without this source being edited.
  `CCV_CHECKER(issue_if_checker, u_iss_chk, `CCV_IF_MODE_OUT) (
    .clk(clk), .rst(rst), .iss(iss), .iss_ready(iss_ready)
  );

endmodule
