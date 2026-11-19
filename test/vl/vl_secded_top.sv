// tools/check-skel.sh's SECDED lockstep (test/vl/vl_secded_tb.cpp): the
// encoder and the decoder's two halves, syndrome then fix (rtl/common/), at two widths, an odd one (37 data bits,
// 7 check bits) and the widest an SRAM word holds (128, 9; MACRO-1), for
// the C++ code in sim/skel/secded.h to match bit for bit. Combinational:
// the bench sets the inputs and reads the outputs after eval.
module vl_secded_top (
  input  logic [36:0]  d1,
  output logic [6:0]   e1,
  input  logic [6:0]   c1,
  output logic [36:0]  q1,
  output logic         sec1,
  output logic         ded1,
  output logic [6:0]   syn1,
  input  logic [127:0] d2,
  output logic [8:0]   e2,
  input  logic [8:0]   c2,
  output logic [127:0] q2,
  output logic         sec2,
  output logic         ded2,
  output logic [8:0]   syn2
);
  ccv_common_secded_enc #(.K(37))  u_enc1 (.data(d1), .chk(e1));
  ccv_common_secded_syn #(.K(37))  u_syn1 (.data(d1), .chk(c1), .syn(syn1));
  ccv_common_secded_fix #(.K(37))  u_fix1 (.data(d1), .syn(syn1), .q(q1), .sec(sec1), .ded(ded1));
  ccv_common_secded_enc #(.K(128)) u_enc2 (.data(d2), .chk(e2));
  ccv_common_secded_syn #(.K(128)) u_syn2 (.data(d2), .chk(c2), .syn(syn2));
  ccv_common_secded_fix #(.K(128)) u_fix2 (.data(d2), .syn(syn2), .q(q2), .sec(sec2), .ded(ded2));
endmodule
