// Depth probe (OA-21 (c)): the in-group override for port j's source, from
// rename's registered group: the youngest earlier port i < j writing it,
// and (WARP) of the same warp, since an interleaved group's warps are not
// on adjacent ports.
module ovr_probe #(parameter int R = 4, parameter int LG = 6, parameter int WARP = 1) (
  input  logic [R*LG-1:0] dst,
  input  logic [R-1:0]    we,
  input  logic [R*2-1:0]  wid,
  input  logic [R*LG-1:0] src,
  output logic [R*R-1:0]  sel     // port j's source from port i (one-hot)
);
  always_comb begin
    sel = '0;
    for (int j = 0; j < R; j++) begin
      logic hit;
      hit = 1'b0;
      for (int i = j - 1; i >= 0; i--) begin
        logic m;
        m = we[i] && dst[i * LG +: LG] == src[j * LG +: LG] && (WARP == 0 || wid[i * 2 +: 2] == wid[j * 2 +: 2]);
        sel[j * R + i] = m && !hit;
        hit = hit | m;
      end
    end
  end
endmodule
