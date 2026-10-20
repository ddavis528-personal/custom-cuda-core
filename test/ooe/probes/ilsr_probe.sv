// Depth probe (OA-22): the split go. Not short (every shared credit and
// every warp's ROB at least R, from registered state plus this cycle's
// frees): the interleave of il_probe on registered fits, which no free can
// widen. Short: form 2, one warp takes, the first in rotation whose first
// uop fits, its prefix by the thermometer of its deficits against the
// frees (TI-19). fr, ret arrive; everything else is registered.
module ilsr_probe #(parameter int S = 4, parameter int R = 4, parameter int W = 16, parameter int OUT = 0,
                    localparam int LR = $clog2(R + 1), localparam int LI = $clog2(S * R + 1)) (
  input  logic [S*LR-1:0]    fits,      // registered: against registered avail
  input  logic [S*LR-1:0]    base,
  input  logic [S*R*3*6-1:0] dfc,       // one-hot deficits 0..4, 5: never
  input  logic [(2+S)*6-1:0] sdf,       // one-hot R - avail
  input  logic               short_q,
  input  logic [2*4-1:0]     fr,        // thermometers: bit i, more than i frees
  input  logic [S*4-1:0]     ret,
  input  logic [S-1:0]       prio,
  input  logic [S-1:0]       nzq,       // registered: warp s has a uop the unshared conditions allow
  input  logic [S*R*W-1:0]   uops,
  output logic [S*LR-1:0]    take,
  output logic [R*W-1:0]     lane
);
  logic            th [S][R];
  logic            shrt;
  logic [S-1:0]    nz, first;
  logic [S*LR-1:0] take_i, take_1;
  logic [R*W-1:0]  lane_i, lane_1;
  logic [S*R*W-1:0] u2;
  il_probe #(.S(S), .R(R), .W(W), .OUT(0)) u_t (.fits(fits), .prio(prio), .uops(uops), .take(take_i), .lane(), .lane_w());
  il_probe #(.S(S), .R(R), .W(W), .OUT(1)) u_l (.fits(fits), .prio(prio), .uops(uops), .take(), .lane(lane_i), .lane_w());
  // A deficit d (one-hot) is covered by a thermometer t: d == 0, or t[d - 1].
  function automatic logic cov(input logic [5:0] d, input logic [3:0] t);
    cov = d[0] | (d[1] & t[0]) | (d[2] & t[1]) | (d[3] & t[2]) | (d[4] & t[3]);
  endfunction
  always_comb begin
    for (int s = 0; s < S; s++)
      for (int l = 0; l < R; l++)
        th[s][l] = LR'(l + 1) <= base[s * LR +: LR] &&
                   cov(dfc[((s * R + l) * 3 + 0) * 6 +: 6], fr[0 +: 4]) &&
                   cov(dfc[((s * R + l) * 3 + 1) * 6 +: 6], fr[4 +: 4]) &&
                   cov(dfc[((s * R + l) * 3 + 2) * 6 +: 6], ret[s * 4 +: 4]);
    shrt = short_q || !cov(sdf[0 +: 6], fr[0 +: 4]) || !cov(sdf[6 +: 6], fr[4 +: 4]);
    for (int s = 0; s < S; s++) shrt = shrt || !cov(sdf[(2 + s) * 6 +: 6], ret[s * 4 +: 4]);
    for (int s = 0; s < S; s++) nz[s] = nzq[s];   // the pick is registered; frees set only the prefix
    for (int s = 0; s < S; s++) begin
      logic any1;
      any1 = 1'b0;
      for (int st = 0; st < S; st++) begin
        logic a1;
        a1 = 1'b0;
        for (int o = 0; o < S; o++) if (o < ((s - st + S) % S)) a1 = a1 | nz[(st + o) % S];
        any1 = any1 | (prio[st] & a1);
      end
      first[s] = nz[s] & !any1;
    end
    take_1 = '0;
    lane_1 = '0;
    for (int s = 0; s < S; s++) begin
      logic [LR-1:0] c;
      c = '0;
      for (int l = 0; l < R; l++) c = c + LR'(th[s][l]);
      take_1[s * LR +: LR] = first[s] ? c : '0;
      for (int j = 0; j < R; j++)
        if (first[s] && th[s][j]) lane_1[j * W +: W] = lane_1[j * W +: W] | uops[(s * R + j) * W +: W];
    end
    take = shrt ? take_1 : take_i;
    lane = shrt ? lane_1 : lane_i;
    if (OUT == 0) lane = '0;
    else take = '0;
  end
endmodule
