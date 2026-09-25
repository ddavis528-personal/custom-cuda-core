//===-- good_yosys_subset.sv - every form CCV-L26 permits ----------------===//
//
// Spec: docs/rtl-coding-style.md, CCV-L26
// Reusable: a lint fixture, not a design block; clk is a generic formal.
//
// The false-positive regression for CCV-L26, and more than that: the gate also
// reads this file with Yosys. A form the rule PERMITS but Yosys cannot parse
// would be a fail-open -- simulation green, formal dead, lint silent -- so it
// is the permitted side that gets checked against the tool, not just the
// rejected side.
//===----------------------------------------------------------------------===//

module good_yosys_subset #(
  parameter int W = 6
) (
  input  logic [W-1:0]   a,
  input  logic [3:0]     b,
  output logic [3*W-1:0] q,
  output logic [3:0]     r
);

  // A 2-D packed array is accepted as a member INSIDE a packed struct.
  typedef struct packed {
    logic [1:0][3:0] f;
  } pair_t;

  pair_t        p;
  logic [W-1:0] m [0:2];        // an unpacked array

  always_comb begin
    p      = '0;
    p.f[0] = b;
    r      = p.f[0];
    m[0]   = a;
    m[1]   = unsigned'(a);
    m[2]   = signed'(a);
    q      = '0;
    // The flat-vector idiom CCV-L26 recommends: one vector, part-selects.
    for (int i = 0; i < 3; i++)
      q[i*W +: W] = W'(i) + m[i];
  end

endmodule
