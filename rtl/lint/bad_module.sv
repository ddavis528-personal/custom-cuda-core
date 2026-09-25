//===-- bad_module.sv - lint fixture: deliberately non-compliant --------===//
//
// §8's Stage 1d exit criterion: "lint rules FAIL a deliberately non-compliant
// sample module -- demonstrated to bite, not merely configured."
//
// This file is that sample. Every violation below is intentional and is
// referenced by rule id in docs/rtl-coding-style.md. tools/check-1d.sh fails
// if any of them stops being caught, which makes this a regression test for
// the lint layer rather than a one-time demonstration.
//
// DO NOT FIX THE VIOLATIONS IN THIS FILE. That is the one thing that would
// break it. It is excluded from the ordinary lint run for that reason and
// linted explicitly, expecting failure.
//===----------------------------------------------------------------------===//

// CCV-L01: module name does not match the filename.
module badly_named_module (
  input  logic        clock,      // CCV-L02: clock port must be `clk`
  input  logic        reset_n,    // CCV-L02: reset port must be `rst`
  input  logic [1:0]  mode,
  input  logic        din,
  output logic        dout
);

  // CCV-L06: DPI import in design RTL.
  import "DPI-C" function void some_external_hook(input int x);

  logic       q;
  logic [1:0] state;

  // CCV-L03: `initial` in design RTL.
  initial begin
    q = 1'b0;
  end

  always_ff @(posedge clock) begin
    // CCV-L04: blocking assignment inside always_ff.
    q = din;
  end

  // CCV-L07: case with no default, so an unreachable state silently holds.
  // CCV-L08: `mode` is a case selector with no CCV_ASSERT_KNOWN.
  always_comb begin
    case (mode)
      2'b00: dout = q;
      2'b01: dout = ~q;
    endcase
  end

  // CCV-L05: bare assertion rather than the CCV_ macros.
  always_ff @(posedge clock) begin
    assert (!(mode == 2'b11)) else $error("bare");
  end

  // CCV-L10: comment line opening with a tool name.
// verilator this line is prose, not a pragma, and is rejected as an unknown one

endmodule

// CCV-L01: a second module in the same file.
module second_module_in_same_file (input logic clk, input logic rst);
endmodule

// CCV-L09: an interface/modport on a port list. Block boundaries are swap
// boundaries (§2) and Verilator cannot expose an interfaced port at top level
// (Stage 1a finding F-4), so this is a settled prohibition, not a preference.
module iface_on_boundary (some_bus.consumer up, some_bus.producer dn);
endmodule

// CCV-L26: constructs both simulators accept and Yosys 0.33 rejects, so the
// file is green until it reaches formal. A 2-D packed port and declaration,
// a keyword cast, and a cast to a typedef name.
module yosys_rejects (input logic [1:0][3:0] lanes, output logic [5:0] q);
  typedef logic [5:0] w_t;
  logic [2:0][5:0] ages;
  always_comb begin
    ages = '0;
    q    = w_t'(int'(lanes[0]));
  end
endmodule

// CCV-L11 is violated by omission: there is no `Spec:` reference anywhere.
