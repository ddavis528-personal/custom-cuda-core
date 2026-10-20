// Depth probe (OA-21 (c)): the interleave's go over registered fits. S
// slots, fits 0..R each, a rotating priority (one-hot). Round r (1..R):
// every slot with fits >= r takes one uop, in rotation order; the events
// fill ports 0..R-1 in order, the last round partial. Event (s, r) lands
// on port idx(s, r) = sum over s' of min(fits_s', r - 1) + the slots ahead
// of s in rotation with fits >= r. take_s counts its events below R; port j
// takes uop r - 1 of slot s where idx(s, r) == j (a 16:1 per port).
// OUT 0: take counts only; 1: lanes only.
module il_probe #(parameter int S = 4, parameter int R = 4, parameter int W = 16, parameter int OUT = 0,
                  localparam int LR = $clog2(R + 1), localparam int LI = $clog2(S * R + 1)) (
  input  logic [S*LR-1:0]  fits,
  input  logic [S-1:0]     prio,
  input  logic [S*R*W-1:0] uops,
  output logic [S*LR-1:0]  take,
  output logic [R*W-1:0]   lane,
  output logic [R*2-1:0]   lane_w
);
  logic [LI-1:0] idx [S][R];
  logic          ev  [S][R];
  always_comb begin
    for (int s = 0; s < S; s++)
      for (int r = 1; r <= R; r++) begin
        logic [LI-1:0] base, ahd;
        base = '0;
        for (int t = 0; t < S; t++)
          base = base + LI'(fits[t * LR +: LR] < LR'(r - 1) ? fits[t * LR +: LR] : LR'(r - 1));
        ahd = '0;
        for (int st = 0; st < S; st++) begin
          logic [LI-1:0] a;
          a = '0;
          for (int o = 0; o < S; o++)
            if (o < ((s - st + S) % S)) a = a + LI'(fits[((st + o) % S) * LR +: LR] >= LR'(r));
          if (prio[st]) ahd = a;
        end
        ev[s][r - 1]  = fits[s * LR +: LR] >= LR'(r);
        idx[s][r - 1] = base + ahd;
      end
    take = '0;
    lane = '0;
    lane_w = '0;
    for (int s = 0; s < S; s++)
      for (int r = 0; r < R; r++)
        if (ev[s][r] && idx[s][r] < LI'(R)) take[s * LR +: LR] = take[s * LR +: LR] + LR'(1);
    for (int j = 0; j < R; j++)
      for (int s = 0; s < S; s++)
        for (int r = 0; r < R; r++)
          if (ev[s][r] && idx[s][r] == LI'(j)) begin
            lane[j * W +: W] = lane[j * W +: W] | uops[(s * R + r) * W +: W];
            lane_w[j * 2 +: 2] = lane_w[j * 2 +: 2] | 2'(s);
          end
    if (OUT == 0) begin lane = '0; lane_w = '0; end
    else take = '0;
  end
endmodule
