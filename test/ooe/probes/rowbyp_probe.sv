// Depth probe (OA's response OI-45, the front-end cycle): ooe_sched's ready
// register's D with Rename 3's rows bypassed in, so an entry is in the ready
// and request registers at the edge its row is written. Each allocating
// port's row (row_dep, row_code from rename's stage register, by 10; its
// in-group terms, grp_dep) is readied over the wake lines in parallel with
// the RS's own rows, and each entry takes its writing port's (sel, from the
// RS's allocation pick, a one-hot per port) or its own. A producer in the
// same group was allocated with it, so is not issued and its lines are low:
// any in-group dependency is not ready.
module rowbyp_probe #(parameter int N = 45, parameter int P = 8, parameter int W = 4,
                      localparam int CW = 2) (
  input  logic [N*N-1:0]    dep,     // the RS's rows (flops)
  input  logic [N*N*CW-1:0] code,
  input  logic [N*W-1:0]    wake,    // ooe_wake's lines (flops)
  input  logic [P*N-1:0]    rdep,    // each port's row (rename's stage register)
  input  logic [P*N*CW-1:0] rcode,
  input  logic [P*P-1:0]    rgrp,    // and its in-group terms
  input  logic [P*N-1:0]    sel,     // port p writes entry i
  output logic [N-1:0]      ready
);
  function automatic logic row_ready(input logic [N-1:0] d, input logic [N*CW-1:0] c, input logic [N*W-1:0] l);
    logic r;
    r = 1'b1;
    for (int j = 0; j < N; j++)
      if (d[j]) r = r & l[j * W + c[j * CW +: CW]];
    row_ready = r;
  endfunction
  logic [P-1:0] pr;
  always_comb begin
    for (int p = 0; p < P; p++)
      pr[p] = row_ready(rdep[p * N +: N], rcode[p * N * CW +: N * CW], wake) && rgrp[p * P +: P] == '0;
    for (int i = 0; i < N; i++) begin
      logic hit, br;
      hit = 1'b0;
      br  = 1'b0;
      for (int p = 0; p < P; p++)
        if (sel[p * N + i]) begin
          hit = 1'b1;
          br  = br | pr[p];
        end
      ready[i] = hit ? br : row_ready(dep[i * N +: N], code[i * N * CW +: N * CW], wake);
    end
  end
endmodule
