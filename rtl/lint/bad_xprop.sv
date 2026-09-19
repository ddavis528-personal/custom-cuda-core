//===-- bad_xprop.sv - lint fixture for the X-determinism rules ---------===//
//
// Spec: docs/rtl-coding-style.md, X-propagation section
//
// Every violation is intentional. tools/check-1d.sh fails if any rule stops
// firing here. DO NOT FIX THE VIOLATIONS IN THIS FILE.
//===----------------------------------------------------------------------===//
`include "ccv_assert.svh"

// Reusable modules -- interface checkers and primitives -- take `clk`/`rst` as
// generic FORMALS, because one checker is instantiated inside many blocks and
// binds to each block's own uniquified clock. Design blocks use the real net
// names (`<blk>_core_clk`, `<blk>_rst_r<NN>h`); a formal named for one block
// would read as a lie in every other.
`define CCV_CLK clk
`define CCV_RST rst

module bad_xprop (
  input  logic       clk,
  input  logic       rst,
  input  logic       ctrl_in,
  input  logic [1:0] sel_in,
  input  logic [3:0] idx_in,
  input  logic [7:0] a_in,
  input  logic [7:0] b_in,
  output logic [7:0] y,
  output logic [7:0] z,
  output logic [7:0] w
);

  logic [7:0] mem [0:15];

  // CCV-L08: `if` on a control input with no KNOWN assertion. An unknown
  // condition silently takes the else branch.
  always_comb begin
    if (ctrl_in) y = a_in;
    else         y = b_in;
  end

  // CCV-L08: case selector is a control input with no KNOWN assertion, and
  // the case is not X-defaulted -- neither legal route is taken.
  always_comb begin
    case (sel_in)
      2'd0: z = a_in;
      2'd1: z = b_in;
      2'd2: z = 8'd0;
      2'd3: z = 8'hff;
    endcase
  end

  // CCV-L16: casex treats an unknown selector as a don't-care and silently
  // matches the first branch.
  always_comb begin
    casex (sel_in)
      2'b0?: w = a_in;
      2'b1?: w = b_in;
      default: w = 'x;
    endcase
  end

  // CCV-L18: an unknown index does not propagate X, it silently DROPS the
  // write. No construction fixes this; the index must be prohibited from X.
  always_ff @(posedge clk) begin
    mem[idx_in] <= a_in;
  end

endmodule

// CCV-L17: partially X-defaulted. `p` is covered and `r` is not, so on an
// unreachable branch `r` silently holds -- the implicit hold §6's explicit-X
// rule exists to remove. The selector IS known-asserted here, so this is the
// prohibition route; the partial default is a slip rather than a second
// mechanism.
// Reusable: lint fixture for the X-determinism rules; the naming rules
//           are exercised separately by rtl/lint/bad_naming.sv.
module bad_xprop_partial (
  input  logic       clk,
  input  logic       rst,
  input  logic [1:0] mode_in,
  output logic [7:0] p,
  output logic [7:0] r
);
  `CCV_ASSERT_KNOWN(mode_known, mode_in)
  always_comb begin
    case (mode_in)
      2'd0:    begin p = 8'd1; r = 8'd2; end
      2'd1:    begin p = 8'd3; r = 8'd4; end
      default: begin p = 'x;             end
    endcase
  end
endmodule

`undef CCV_CLK
`undef CCV_RST
