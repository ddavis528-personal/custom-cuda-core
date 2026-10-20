module th_only #(parameter int N = 45, parameter int NR = 30, parameter int C = 4) (
  input logic [N-1:0] conf, output logic [2*C-1:0] fth);
  always_comb begin
    logic [$clog2(N + 1)-1:0] n0, n1;
    n0 = '0; n1 = '0;
    for (int i = 0; i < NR; i++) n0 = n0 + conf[i];
    for (int i = NR; i < N; i++) n1 = n1 + conf[i];
    for (int i = 0; i < C; i++) begin fth[i] = n0 > i; fth[C + i] = n1 > i; end
  end
endmodule
// The same, as a tree of capped thermometers (more than i in a + b).
module th_sat #(parameter int N = 45, parameter int NR = 30, parameter int C = 4) (
  input logic [N-1:0] conf, output logic [2*C-1:0] fth);
  logic [C-1:0] v [2][64];
  always_comb begin
    for (int c = 0; c < 2; c++) begin
      int lo, n;
      lo = c ? NR : 0;
      n = c ? N - NR : NR;
      for (int i = 0; i < 64; i++) v[c][i] = i < n ? C'(conf[lo + i]) : '0;
      for (int w = 1; w < 64; w = w * 2)
        for (int i = 0; i + w < 64; i = i + 2 * w) begin
          logic [C-1:0] a, b, m;
          a = v[c][i]; b = v[c][i + w];
          for (int k = 0; k < C; k++) begin
            m[k] = a[k] | b[k];
            for (int j = 0; j < k; j++) m[k] = m[k] | (a[j] & b[k - 1 - j]);
          end
          v[c][i] = m;
        end
      fth[c * C +: C] = v[c][0];
    end
  end
endmodule
