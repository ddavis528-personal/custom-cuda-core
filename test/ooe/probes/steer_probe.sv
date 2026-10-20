// Depth probe (OA-21 item 3): rename's go over registered per-slot fits
// (go_probe's two picks), then the port steering into the stage register:
// lane j takes the first warp's uop j while j < f1, else the second warp's
// uop j - f1. uops: the decode queue's R oldest per slot, W bits each.
module steer_probe #(parameter int S = 4, parameter int R = 4, parameter int W = 16, parameter int TWO = 1,
                     localparam int LR = $clog2(R + 1)) (
  input  logic [S*LR-1:0]  fits,
  input  logic [S-1:0]     prio,
  input  logic [S*R*W-1:0] uops,
  output logic [R*W-1:0]   lane,
  output logic [R-1:0]     lane_v
);
  logic [S-1:0] nz, first, second;
  logic [LR-1:0] f1, f2;
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
      second[s] = TWO != 0 && nz[s] & any1 & !any2;
    end
    f1 = '0;
    f2 = '0;
    for (int s = 0; s < S; s++) f1 = f1 | ({LR{first[s]}} & fits[s * LR +: LR]);
    for (int s = 0; s < S; s++) f2 = f2 | ({LR{second[s]}} & fits[s * LR +: LR]);
    for (int j = 0; j < R; j++) begin
      logic [W-1:0] a, b;
      a = '0;
      b = '0;
      for (int s = 0; s < S; s++) a = a | ({W{first[s]}} & uops[(s * R + j) * W +: W]);
      // The second warp's uop j - f1, f1 = 0..j.
      for (int k = 0; k < j + 1; k++)
        for (int s = 0; s < S; s++)
          b = b | ({W{second[s] && f1 == LR'(j - k)}} & uops[(s * R + k) * W +: W]);
      lane[j * W +: W] = LR'(j) < f1 ? a : b;
      lane_v[j] = LR'(j) < f1 || (LR'(j) < f1 + f2 && LR'(j) < LR'(R));
    end
  end
endmodule
