//===-- reference_csh.sv - a register-free helper with two outputs ---===//
//
// Spec: docs/rtl-coding-style.md, CCV-L23 across a connection (OA-488 (1),
//       OI-226 (b))
//
// Child of reference_csp.sv and bad_conn8.sv's reference_lcsp; see there.
//===----------------------------------------------------------------------===//

`define CCV_CLK reference_core_clk
`define CCV_RST ref_rst_r00h

module reference_csh (
  input  logic [3:0] a,
  output logic [3:0] y,
  output logic [3:0] p
);
  assign y = a + 4'd1;
  assign p = a ^ 4'd5;
endmodule

`undef CCV_CLK
`undef CCV_RST
