// tools/check-skel.sh's way-fold lockstep (test/vl/vl_wayfold_tb.cpp): the
// fold (rtl/common/ccv_common_wayfold.sv) at K = 4, the built one (8 whole
// chunks of PA[47:16]), and K = 5, whose last chunk is zero-extended, for
// the C++ fold in sim/skel/wayfold.h to match bit for bit. Combinational.
module vl_wayfold_top (
  input  logic [31:0] tag,
  output logic [3:0]  f4,
  output logic [4:0]  f5
);
  ccv_common_wayfold #(.K(4), .W(32)) u_f4 (.tag(tag), .fold(f4));
  ccv_common_wayfold #(.K(5), .W(32)) u_f5 (.tag(tag), .fold(f5));
endmodule
