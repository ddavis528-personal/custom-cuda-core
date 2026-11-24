//===-- reference_ph.sv - a register-free helper ---===//
//
// Spec: docs/rtl-coding-style.md, CCV-L23 across a connection (OA 481-490,
//       OI-207)
//
// Child of reference_pp.sv; see there.
//===----------------------------------------------------------------------===//

`define CCV_CLK reference_core_clk
`define CCV_RST ref_rst_r00h

module reference_ph (
  input  logic [3:0] a,
  output logic [3:0] y
);
  assign y = a + 4'd1;
endmodule

`undef CCV_CLK
`undef CCV_RST
