// Depth probe (OI-65 (a)): the per-offset fits from registered state only,
// by prefixes. Warp s's credits less its first k uops' needs cover the
// next j exactly when the first k + j uops' needs fit the credits, so each
// window is one test per position m = k + j: g[m], the first m uops are
// present and fit. fits_s[k] counts the leading trues of g[k+1..k+R].
// Registered: each slot's count and its 2R-1 oldest uops' admission bits
// (rcu, miu, copy, gpr, pred, branch), the per-warp credits and holds.
// AR (1): uops arriving at this edge into a slot short of 2R-1 are added
// by position (ev, es, ea by 5); 0, only the uops already held.
module fitsk2_probe #(parameter int S = 4, parameter int R = 4, parameter int E = 6, parameter int D = 13,
                      parameter int AR = 0,
                      parameter int CAP = 1,   // 0: the warp cap is the whole RS (CCV_P_RS_WARP_CAP 45), no check
                      parameter int RET = 0,   // 1: this cycle's retirements (ret_n, a thermometer by 8) in the ROB term
                      parameter int SHR = 0,   // 1: each warp's registered shares of RS RCU and MIU (OI-65's shares)
                      localparam int LR = $clog2(R + 1), localparam int H = 2 * R - 1,
                      localparam int LC = $clog2(D + 1), localparam int LS = $clog2(S)) (
  input  logic [S*H-1:0]   hv,       // decq's head valids
  input  logic [S*LC-1:0]  cnt,
  input  logic [S*H*6-1:0] ha,
  input  logic [E-1:0]     ev,
  input  logic [E*LS-1:0]  es,
  input  logic [E*6-1:0]   ea,
  input  logic [S*6-1:0]   rob,
  input  logic [S*2-1:0]   ret,       // per warp: more than 0, more than 1 retired now
  input  logic [S*6-1:0]   cap,
  input  logic [S*5-1:0]   shr,       // per warp: its RS RCU share
  input  logic [S*4-1:0]   shm,       // and MIU share
  input  logic [S*7-1:0]   gal,
  input  logic [S*5-1:0]   pal,
  input  logic [S*3-1:0]   ckf,
  input  logic [S-1:0]     hold,
  output logic [S*(R+1)*R-1:0] fits   // thermometers: bit j-1, the first j past k fit
);
  always_comb begin
    fits = '0;
    for (int s = 0; s < S; s++) begin
      logic [5:0] a [H];
      logic       v [H];
      logic       g [H + 1];
      logic [LC-1:0] c;
      c = cnt[s * LC +: LC];
      for (int p = 0; p < H; p++) begin
        v[p] = hv[s * H + p];
        a[p] = ha[(s * H + p) * 6 +: 6];   // decq clears an absent head's bits
      end
      if (AR != 0) begin
        // An arriving uop takes the slot's next position: its rank among
        // this cycle's arrivals for the slot, past the count.
        for (int q = 0; q < E; q++) begin
          logic [2:0] rk;
          rk = '0;
          for (int o = 0; o < q; o++) rk = rk + 3'(ev[o] && es[o * LS +: LS] == LS'(s));
          if (ev[q] && es[q * LS +: LS] == LS'(s))
            for (int p = 0; p < H; p++)
              if (LC'(p) == c + LC'(rk)) begin
                v[p] = 1'b1;
                a[p] = ea[q * 6 +: 6];
              end
        end
      end
      g[0] = !hold[s];
      for (int m = 1; m < H + 1; m++) begin
        // The first m uops' needs, each a balanced tree over positions.
        logic [4:0] t1 [8], t2 [4], t3 [2];
        logic [4:0] nk, ng, np, nb, nr, nm;
        for (int r = 0; r < 6; r++) begin
          for (int i = 0; i < 8; i++)
            if (i < m)
              t1[i] = r == 0 ? 5'(a[i][0]) + 5'(a[i][1]) + 5'(a[i][2]) : r == 4 ? 5'(a[i][0]) + 5'(a[i][2]) :
                      r == 5 ? 5'(a[i][1]) : 5'(a[i][r + 2]);
            else
              t1[i] = '0;
          for (int i = 0; i < 4; i++) t2[i] = t1[2 * i] + t1[2 * i + 1];
          for (int i = 0; i < 2; i++) t3[i] = t2[2 * i] + t2[2 * i + 1];
          case (r)
            0: nk = t3[0] + t3[1];
            1: ng = t3[0] + t3[1];
            2: np = t3[0] + t3[1];
            3: nb = t3[0] + t3[1];
            4: nr = t3[0] + t3[1];
            default: nm = t3[0] + t3[1];
          endcase
        end
        logic robok;
        robok = rob[s * 6 +: 6] >= 6'(m);
        if (RET != 0)
          robok = robok || (rob[s * 6 +: 6] >= 6'(m - 1) && ret[s * 2]) ||
                  (m >= 2 && rob[s * 6 +: 6] >= 6'(m - 2) && ret[s * 2 + 1]);
        g[m] = v[m - 1] && robok && (CAP == 0 || cap[s * 6 +: 6] >= 6'(nk)) &&
               gal[s * 7 +: 7] >= 7'(ng) && pal[s * 5 +: 5] >= np && ckf[s * 3 +: 3] >= 3'(nb) &&
               nb < 5'd8 && (SHR == 0 || (shr[s * 5 +: 5] >= nr && 5'(shm[s * 4 +: 4]) >= nm));
      end
      for (int k = 0; k < R + 1; k++) begin
        logic run;
        run = g[0];
        for (int j = 1; j < R + 1; j++)
          if (k + j < H + 1) begin
            run = run && g[k + j];
            fits[(s * (R + 1) + k) * R + j - 1] = run;
          end
      end
    end
  end
endmodule
