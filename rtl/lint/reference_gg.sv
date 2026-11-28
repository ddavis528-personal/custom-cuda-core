//===-- reference_gg.sv - a register-free grandchild ---===//
//
// Spec: docs/rtl-coding-style.md, CCV-L23 across a connection (OI-227 (e))
//
// Child of reference_gc.sv; see reference_gp.sv.
//===----------------------------------------------------------------------===//

`define CCV_CLK reference_core_clk
`define CCV_RST ref_rst_r00h

module reference_gg (
  input  logic a,
  output logic y
);
  assign y = !a;
endmodule

`undef CCV_CLK
`undef CCV_RST
