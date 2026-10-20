// Depth probe (OA-22): the interleaved go with this cycle's frees (TI-19)
// compared in front. Registered: base_s, warp s's prefix the unshared
// conditions allow (0..R); dfc[s][l][k], the deficit (need - avail,
// saturated at 0 and at 7) of its first l + 1 uops for k = RS RCU, RS MIU,
// its ROB; sdf[k], R - avail for the RS classes (saturated), and short_q,
// form 2's bit for the credits no free reaches this cycle (GPR, predicate
// names). Arriving: fr[k], each RS class's frees (ooe_rs's thermometer
// count, 0..4) and ret[s], warp s's ROB frees (ret_n). fits_s counts the
// prefixes whose deficits the frees cover; form 2: while any credit is
// short of R, the first warp in rotation with fits takes alone, else the
// rounds of il_probe. OUT 0: take counts; 1: lanes.
module ild_probe #(parameter int S = 4, parameter int R = 4, parameter int W = 16, parameter int OUT = 0,
                   localparam int LR = $clog2(R + 1), localparam int LI = $clog2(S * R + 1)) (
  input  logic [S*LR-1:0]    base,
  input  logic [S*R*3*3-1:0] dfc,
  input  logic [2*3-1:0]     sdf,
  input  logic               short_q,
  input  logic [2*3-1:0]     fr,
  input  logic [S*3-1:0]     ret,
  input  logic [S-1:0]       prio,
  input  logic [S*R*W-1:0]   uops,
  output logic [S*LR-1:0]    take,
  output logic [R*W-1:0]     lane
);
  logic [S*LR-1:0] fits;
  logic            shrt;
  logic [S-1:0]    nz, first;
  logic [LI-1:0]   idx [S][R];
  logic            ev  [S][R];
  always_comb begin
    for (int s = 0; s < S; s++) begin
      logic [LR-1:0] f;
      f = '0;
      for (int l = 0; l < R; l++) begin
        logic ok;
        ok = LR'(l + 1) <= base[s * LR +: LR] &&
             dfc[((s * R + l) * 3 + 0) * 3 +: 3] <= fr[0 +: 3] &&
             dfc[((s * R + l) * 3 + 1) * 3 +: 3] <= fr[3 +: 3] &&
             dfc[((s * R + l) * 3 + 2) * 3 +: 3] <= ret[s * 3 +: 3];
        f = f + LR'(ok);   // deficits grow with l: the count is the prefix
      end
      fits[s * LR +: LR] = f;
    end
    shrt = short_q || sdf[0 +: 3] > fr[0 +: 3] || sdf[3 +: 3] > fr[3 +: 3];
    for (int s = 0; s < S; s++) nz[s] = fits[s * LR +: LR] != '0;
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
    for (int s = 0; s < S; s++)
      for (int r = 1; r <= R; r++) begin
        logic [LI-1:0] bs, ahd, i1;
        bs = '0;
        for (int t = 0; t < S; t++)
          bs = bs + LI'(fits[t * LR +: LR] < LR'(r - 1) ? fits[t * LR +: LR] : LR'(r - 1));
        ahd = '0;
        for (int st = 0; st < S; st++) begin
          logic [LI-1:0] a;
          a = '0;
          for (int o = 0; o < S; o++)
            if (o < ((s - st + S) % S)) a = a + LI'(fits[((st + o) % S) * LR +: LR] >= LR'(r));
          if (prio[st]) ahd = a;
        end
        i1 = LI'(r - 1);   // one warp alone: its uop r - 1 on port r - 1
        ev[s][r - 1]  = fits[s * LR +: LR] >= LR'(r) && (!shrt || first[s]);
        idx[s][r - 1] = shrt ? i1 : bs + ahd;
      end
    take = '0;
    lane = '0;
    for (int s = 0; s < S; s++)
      for (int r = 0; r < R; r++)
        if (ev[s][r] && idx[s][r] < LI'(R)) take[s * LR +: LR] = take[s * LR +: LR] + LR'(1);
    for (int j = 0; j < R; j++)
      for (int s = 0; s < S; s++)
        for (int r = 0; r < R; r++)
          if (ev[s][r] && idx[s][r] == LI'(j)) lane[j * W +: W] = lane[j * W +: W] | uops[(s * R + r) * W +: W];
    if (OUT == 0) lane = '0;
    else take = '0;
  end
endmodule
