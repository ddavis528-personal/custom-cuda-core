//===-- ccv_common_wayfold.sv - the L1 way predictor's fold of a tag -------===//
//
// Spec: MA-30, AR 405 and MA's response to it (register, MA tab rev 155);
//       schema/interfaces.json, ccv_miu_dcu_req's pa_fold.
//
// An inner helper (ccv_common_wayfold.ngd.json): combinational, no flops,
// timed in its parent. The fold of the page, PA[47:16] (W = 32): MIU's TLB
// keeps fold(PFN) beside each PFN, written at the fill. In RTL only MIU
// folds: DCU keeps MIU's pa_fold in its miss entry and writes its fold table
// with it at the fill. fold is the XOR of tag's K-bit chunks from bit 0
// upward, the last zero-extended. Below 512 sets the tag also holds page
// offset bits, PA[15:7+log2 sets], whose fold miu_a2 XORs in (MA-33 (3)).
// sim/skel/wayfold.h is its C++ twin, held to it by tools/check-skel.sh.
//===----------------------------------------------------------------------===//
module ccv_common_wayfold #(
  parameter int K = 4,                        // fold bits, 1 or more
  parameter int W = 32,                       // tag bits
  localparam int N = (W + K - 1) / K          // chunks
) (
  input  logic [W-1:0] tag,
  output logic [K-1:0] fold
);
  logic [N*K-1:0] ext;
  assign ext = {{(N*K-W){1'b0}}, tag};
  always_comb begin
    fold = '0;
    for (int c = 0; c < N; c++) fold = fold ^ ext[c*K +: K];
  end
endmodule
