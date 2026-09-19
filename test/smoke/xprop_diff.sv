//===-- xprop_diff.sv - differential X-propagation regression -----------===//
//
// Spec: docs/rtl-coding-style.md, X-propagation section
//
// ccv-lint: exempt CCV-L08 CCV-L07 CCV-L16 -- this file deliberately contains
// the ILLEGAL X-optimistic constructions, as the control against which the
// legal ones are measured. Removing them would remove the evidence.
//
// WHY A DIFFERENTIAL TEST. Every other check here asks whether a property
// fires. This asks whether the CHOICE OF CONSTRUCT changes behaviour at all --
// which no single-build test can show, and which is the entire premise of the
// X-determinism rules. If the three forms below ever produce the same answer
// for an unknown selector, the rules are ceremony and should be deleted.
//
// Inputs are chosen so agreeing and disagreeing bits are both present:
//   i0=1100 i1=1110 i2=1100 i3=1101   -> bits 3,2 agree; bits 1,0 differ
//
// Expected, and asserted by tools/check-xprop.sh:
//   optimistic (if-chain)   1101   the LAST branch -- every comparison
//                                  against an unknown selector is itself
//                                  unknown, so the chain falls through to the
//                                  final else. Which branch it lands on is an
//                                  artifact of ordering, not of the design.
//   tmerge     (ternary)    11xx   only the ambiguous bits unknown
//   xmerge     (case + 'x)  xxxx   everything unknown
//===----------------------------------------------------------------------===//
`include "ccv_xprop.svh"

module xprop_diff (
  input  logic [1:0] sel,
  output logic [3:0] y_optimistic,
  output logic [3:0] y_tmerge,
  output logic [3:0] y_xmerge
);

  localparam logic [3:0] I0 = 4'b1100;
  localparam logic [3:0] I1 = 4'b1110;
  localparam logic [3:0] I2 = 4'b1100;
  localparam logic [3:0] I3 = 4'b1101;

  // ILLEGAL. Present as the control: an unknown selector falls through every
  // comparison and lands on the final else, producing a definite value that
  // is indistinguishable from a real one.
  always_comb begin
    if      (sel == 2'd0) y_optimistic = I0;
    else if (sel == 2'd1) y_optimistic = I1;
    else if (sel == 2'd2) y_optimistic = I2;
    else                  y_optimistic = I3;
  end

  // LEGAL -- tmerge.
  assign y_tmerge = `CCV_XMUX4(sel, I0, I1, I2, I3);

  // LEGAL -- xmerge.
  always_comb begin
    y_xmerge = 'x;
    case (sel)
      2'd0: y_xmerge = I0;
      2'd1: y_xmerge = I1;
      2'd2: y_xmerge = I2;
      2'd3: y_xmerge = I3;
    endcase
  end

endmodule
