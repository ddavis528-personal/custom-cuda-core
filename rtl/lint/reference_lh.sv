//===-- reference_lh.sv - a register-free helper, a wire ---===//
//
// Spec: docs/rtl-coding-style.md, CCV-L23 across a connection (OA-501)
//
// See reference_lkp.sv: u_ren1's role, crossed by name.
//===----------------------------------------------------------------------===//

module reference_lh (
  input  logic a,
  output logic z
);
  assign z = a;
endmodule
