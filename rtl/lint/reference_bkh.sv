//===-- reference_bkh.sv - a register-free head read ---===//
//
// Spec: docs/rtl-coding-style.md, CCV-L23 across a connection (OA 513)
//
// Child of reference_bkp.sv and bad_conn10.sv's reference_ckp; see there.
//===----------------------------------------------------------------------===//

`define CCV_CLK reference_core_clk
`define CCV_RST ref_rst_r00h

module reference_bkh (
  input  logic a,
  output logic y
);
  assign y = a;
endmodule

`undef CCV_CLK
`undef CCV_RST
