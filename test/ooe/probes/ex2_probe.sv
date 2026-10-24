// Depth probe (OA-21 (2)): the two-pick go with exact shared credits. From
// registered state: fits_s (0..R, each warp's prefix against the full
// credits); nd[s][l][k], the shared credits warp s's first l + 1 uops need
// (k: RS RCU, RS MIU, GPR names, predicate names); cr[k], the credits. The
// first pick takes t1 = its fits; the second takes the longest prefix
// within its fits and R - t1 whose needs fit the credits less the first's.
module ex2_probe #(parameter int S = 4, parameter int R = 4, parameter int K = 4, parameter int LN = 4,
                   parameter int LC = 5, localparam int LR = $clog2(R + 1)) (
  input  logic [S*LR-1:0]     fits,
  input  logic [S-1:0]        prio,
  input  logic [S*R*K*LN-1:0] nd,
  input  logic [K*LC-1:0]     cr,
  output logic [S*LR-1:0]     take
);
  logic [S-1:0] nz, first, second;
  logic [LR-1:0] f1, f2, room;
  logic [K*LC-1:0] rem;
  logic [R-1:0] ok;
  always_comb begin
    for (int s = 0; s < S; s++) nz[s] = fits[s * LR +: LR] != '0;
    for (int s = 0; s < S; s++) begin
      logic any1, any2;
      any1 = 1'b0; any2 = 1'b0;
      for (int st = 0; st < S; st++) begin
        logic a1, a2;
        a1 = 1'b0; a2 = 1'b0;
        for (int o = 0; o < S; o++)
          if (o < ((s - st + S) % S)) begin
            a2 = a2 | (a1 & nz[(st + o) % S]);
            a1 = a1 | nz[(st + o) % S];
          end
        any1 = any1 | (prio[st] & a1);
        any2 = any2 | (prio[st] & a2);
      end
      first[s]  = nz[s] & !any1;
      second[s] = nz[s] & any1 & !any2;
    end
    f1 = '0;
    f2 = '0;
    for (int s = 0; s < S; s++) f1 = f1 | ({LR{first[s]}} & fits[s * LR +: LR]);
    for (int s = 0; s < S; s++) f2 = f2 | ({LR{second[s]}} & fits[s * LR +: LR]);
    // The credits left after the first warp's prefix.
    for (int k = 0; k < K; k++) begin
      logic [LN-1:0] u;
      u = '0;
      for (int s = 0; s < S; s++)
        for (int l = 0; l < R; l++)
          if (first[s] && f1 == LR'(l + 1)) u = u | nd[((s * R + l) * K + k) * LN +: LN];
      rem[k * LC +: LC] = cr[k * LC +: LC] - LC'(u);
    end
    room = LR'(R) - f1;
    // The second warp's prefixes: length l + 1 fits every credit.
    for (int l = 0; l < R; l++) begin
      logic fit;
      fit = f2 >= LR'(l + 1) && room >= LR'(l + 1);
      for (int k = 0; k < K; k++) begin
        logic [LN-1:0] n;
        n = '0;
        for (int s = 0; s < S; s++) if (second[s]) n = n | nd[((s * R + l) * K + k) * LN +: LN];
        fit = fit && rem[k * LC +: LC] >= LC'(n);
      end
      ok[l] = fit;
    end
    take = '0;
    for (int s = 0; s < S; s++) begin
      logic [LR-1:0] t2;
      t2 = '0;
      for (int l = 0; l < R; l++) if (ok[l]) t2 = LR'(l + 1);   // needs grow with l: the longest that fits
      take[s * LR +: LR] = ({LR{first[s]}} & fits[s * LR +: LR]) | ({LR{second[s]}} & t2);
    end
  end
endmodule
