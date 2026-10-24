// Depth probe (OI-65): rename's go with fits formed in the cycle, from
// decq's output register (each slot's R oldest, their admission bits) and
// rename's registered credit counters, then OA-22's registered go (the
// interleave, or the first fitting warp alone in a short cycle).
// Per uop: rcu, miu, copy (a second RCU entry), gpr, pred, branch. Per warp:
// its ROB room, its warp-cap room, its GPR and predicate rename allowance,
// its free checkpoints, its holds. Shared: RS RCU, RS MIU, GPR and
// predicate buffer counts.
module fitsgo_probe #(parameter int S = 4, parameter int R = 4, parameter int W = 16, parameter int OUT = 0,
                      localparam int LR = $clog2(R + 1)) (
  input  logic [S*R-1:0]   hv,         // head valid
  input  logic [S*R*6-1:0] ua,         // per uop: rcu, miu, copy, gpr, pred, branch
  input  logic [S*6-1:0]   rob,        // per warp credits (counts)
  input  logic [S*6-1:0]   cap,
  input  logic [S*7-1:0]   gal,
  input  logic [S*5-1:0]   pal,
  input  logic [S*3-1:0]   ckf,
  input  logic [S-1:0]     hold,
  input  logic [4:0]       c_rcu,
  input  logic [3:0]       c_miu,
  input  logic [3:0]       c_gpr,
  input  logic [3:0]       c_pred,
  input  logic [S-1:0]     prio,
  input  logic [S*R*W-1:0] uops,
  output logic [S*LR-1:0]  take,
  output logic [R*W-1:0]   lane
);
  logic [S*LR-1:0] fits, fits1, take_i, take_1;
  logic [R*W-1:0]  lane_i, lane_1;
  logic [S-1:0]    nz1, first;
  logic            anycopy, shrt;
  il_probe #(.S(S), .R(R), .W(W), .OUT(0)) u_t (.fits(fits), .prio(prio), .uops(uops), .take(take_i), .lane(), .lane_w());
  il_probe #(.S(S), .R(R), .W(W), .OUT(1)) u_l (.fits(fits), .prio(prio), .uops(uops), .take(), .lane(lane_i), .lane_w());
  always_comb begin
    anycopy = 1'b0;
    for (int s = 0; s < S; s++) for (int k = 0; k < R; k++) anycopy = anycopy | (hv[s * R + k] & ua[(s * R + k) * 6 + 2]);
    shrt = c_rcu < (anycopy ? 5'(2 * R) : 5'(R)) || c_miu < 4'(R) || c_gpr < 4'(R) || c_pred < 4'(R);
    for (int s = 0; s < S; s++) begin
      logic [5:0] nr, nm, nk;
      logic [6:0] ng;
      logic [4:0] np;
      logic [2:0] nb;
      logic ok, ok1;
      logic [LR-1:0] f, f1;
      nr = '0; nm = '0; ng = '0; np = '0; nb = '0; nk = '0;
      ok = !hold[s]; ok1 = !hold[s];
      f = '0; f1 = '0;
      for (int k = 0; k < R; k++) begin
        logic [5:0] a;
        a  = ua[(s * R + k) * 6 +: 6];
        nr = nr + 6'(a[0]) + 6'(a[2]);
        nm = nm + 6'(a[1]);
        nk = nk + 6'(a[0]) + 6'(a[2]) + 6'(a[1]);
        ng = ng + 7'(a[3]);
        np = np + 5'(a[4]);
        nb = nb + 3'(a[5]);
        ok = ok && hv[s * R + k] && rob[s * 6 +: 6] > 6'(k) && cap[s * 6 +: 6] >= nk &&
             gal[s * 7 +: 7] >= ng && pal[s * 5 +: 5] >= np && ckf[s * 3 +: 3] >= nb;
        ok1 = ok && c_rcu >= 5'(nr) && c_miu >= 4'(nm) && c_gpr >= 4'(ng) && c_pred >= 4'(np);
        f  = f + LR'(ok);
        f1 = f1 + LR'(ok1);
      end
      fits[s * LR +: LR]  = f;
      fits1[s * LR +: LR] = f1;
      nz1[s] = f1 != '0;
    end
    for (int s = 0; s < S; s++) begin
      logic any1;
      any1 = 1'b0;
      for (int st = 0; st < S; st++) begin
        logic a1;
        a1 = 1'b0;
        for (int o = 0; o < S; o++) if (o < ((s - st + S) % S)) a1 = a1 | nz1[(st + o) % S];
        any1 = any1 | (prio[st] & a1);
      end
      first[s] = nz1[s] & !any1;
    end
    take_1 = '0;
    lane_1 = '0;
    for (int s = 0; s < S; s++) begin
      take_1[s * LR +: LR] = first[s] ? fits1[s * LR +: LR] : '0;
      for (int j = 0; j < R; j++)
        if (first[s] && LR'(j) < fits1[s * LR +: LR]) lane_1[j * W +: W] = lane_1[j * W +: W] | uops[(s * R + j) * W +: W];
    end
    take = shrt ? take_1 : take_i;
    lane = shrt ? lane_1 : lane_i;
    if (OUT == 0) lane = '0;
    else take = '0;
  end
endmodule
