// Depth probe (OA-21 (2)): the interleave with exact shared credits. Events
// (s, r) on ports as in il_probe; port j's event is kept while every
// credit covers the cumulative need of the events on ports 0..j: per warp,
// the need of its prefix up to its events so far (nd, registered).
module exi_probe #(parameter int S = 4, parameter int R = 4, parameter int K = 4, parameter int LN = 4,
                   parameter int LC = 5, localparam int LR = $clog2(R + 1), localparam int LI = $clog2(S * R + 1)) (
  input  logic [S*LR-1:0]     fits,
  input  logic [S-1:0]        prio,
  input  logic [S*R*K*LN-1:0] nd,
  input  logic [K*LC-1:0]     cr,
  output logic [S*LR-1:0]     take
);
  logic [LI-1:0] idx [S][R];
  logic          ev  [S][R];
  logic [R-1:0]  keep;
  always_comb begin
    for (int s = 0; s < S; s++)
      for (int r = 1; r < R + 1; r++) begin
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
    // Port j keeps its event while the events on ports 0..j fit.
    for (int j = 0; j < R; j++) begin
      logic fit;
      fit = 1'b1;
      for (int k = 0; k < K; k++) begin
        logic [LC-1:0] cum;
        cum = '0;
        for (int s = 0; s < S; s++) begin
          logic [LN-1:0] n;
          n = '0;
          for (int r = 0; r < R; r++)   // warp s's last event at or below port j
            if (ev[s][r] && idx[s][r] <= LI'(j) && (r == R - 1 || !ev[s][r + 1] || idx[s][r + 1] > LI'(j)))
              n = nd[((s * R + r) * K + k) * LN +: LN];
          cum = cum + LC'(n);
        end
        fit = fit && cr[k * LC +: LC] >= cum;
      end
      if (j == 0) keep[j] = fit;
      else        keep[j] = fit && keep[j > 0 ? j - 1 : 0];
    end
    take = '0;
    for (int s = 0; s < S; s++)
      for (int r = 0; r < R; r++)
        if (ev[s][r] && idx[s][r] < LI'(R) && keep[idx[s][r][$clog2(R) - 1:0]])
          take[s * LR +: LR] = take[s * LR +: LR] + LR'(1);
  end
endmodule
