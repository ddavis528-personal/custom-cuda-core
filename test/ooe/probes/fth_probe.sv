// Depth probe (OA-22): free_th's real arrival. ooe_confirm's frees, from
// flops, as a thermometer per RS class, capped at C (bit i: more than i
// frees), as ooe_rs would send it to rename.
module fth_probe #(parameter int N = 45, parameter int NR = 30, parameter int C = 4) (
  input  logic [N-1:0] iss, input logic [N*N-1:0] dep, input logic [N-1:0] msd,
  input  logic [N-1:0] fin, input logic [N-1:0] prod,
  output logic [2*C-1:0] fth
);
  logic [N-1:0] conf;
  ooe_confirm #(.N(N)) cf(.iss_cq01h(iss), .dep_cq01h(dep), .msd_cq01h(msd), .fin_cq01h(fin), .prod_cq01h(prod),
                          .replay_cq01h(), .conf_cq01h(conf));
  always_comb begin
    logic [$clog2(N + 1)-1:0] n0, n1;
    n0 = '0; n1 = '0;
    for (int i = 0; i < NR; i++) n0 = n0 + conf[i];
    for (int i = NR; i < N; i++) n1 = n1 + conf[i];
    for (int i = 0; i < C; i++) begin
      fth[i]     = n0 > i;
      fth[C + i] = n1 > i;
    end
  end
endmodule
// ret_n's real arrival: a ROB of D entries, its head registered one-hot,
// retires up to K a cycle, each done and unfaulted in order from the head.
module ret_probe #(parameter int D = 32, parameter int K = 2) (
  input  logic [D-1:0] head_oh, input logic [D-1:0] done, input logic [D-1:0] flt,
  output logic [K-1:0] ret_th
);
  always_comb begin
    logic ok;
    ok = 1'b1;
    for (int k = 0; k < K; k++) begin
      logic d;
      d = 1'b0;
      for (int e = 0; e < D; e++) d = d | (head_oh[e] & done[(e + k) % D] & !flt[(e + k) % D]);
      ok = ok & d;
      ret_th[k] = ok;
    end
  end
endmodule
