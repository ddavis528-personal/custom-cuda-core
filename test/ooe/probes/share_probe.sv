// Depth probe (OI-65, OA's per-warp shares): each cycle every shared credit
// is split equally among the warps with a head, the remainder to the first
// such warp in rotation. From registered counters (RS RCU, RS MIU, GPR and
// predicate names) and decq's registered head valids; out, each warp's
// shares, which the per-offset fits compare against.
module share_probe #(parameter int S = 4, parameter int LC = 5,
                     parameter int P2 = 0) (   // 1: the count rounded up to 1, 2 or 4: shifts, the first warp the rest
  input  logic [4*LC-1:0]  cred,      // the four shared credits
  input  logic [S-1:0]     head,      // warp s has a head
  input  logic [S-1:0]     prio,      // the rotation, one-hot
  output logic [S*4*LC-1:0] share
);
  always_comb begin
    logic [2:0] k;
    logic [S-1:0] first;
    k = '0;
    for (int s = 0; s < S; s++) k = k + 3'(head[s]);
    for (int s = 0; s < S; s++) begin
      logic any;
      any = 1'b0;
      for (int st = 0; st < S; st++) begin
        logic a;
        a = 1'b0;
        for (int o = 0; o < S; o++) if (o < ((s - st + S) % S)) a = a | head[(st + o) % S];
        any = any | (prio[st] & a);
      end
      first[s] = head[s] & !any;
    end
    share = '0;
    for (int r = 0; r < 4; r++) begin
      logic [LC-1:0] c, q, m;
      c = cred[r * LC +: LC];
      if (P2 == 0)
        case (k)
          3'd1: begin q = c; m = '0; end
          3'd2: begin q = c >> 1; m = LC'(c[0]); end
          3'd3: begin q = LC'(c / 3); m = LC'(c % 3); end
          3'd4: begin q = c >> 2; m = LC'(c[1:0]); end
          default: begin q = '0; m = '0; end
        endcase
      else
        // q = c / 2^ceil(log2 k); the first warp takes the rest, c - (k-1)q.
        case (k)
          3'd1: begin q = c; m = '0; end
          3'd2: begin q = c >> 1; m = LC'(c[0]); end
          3'd3: begin q = c >> 2; m = c - (q << 1) - q; end
          3'd4: begin q = c >> 2; m = LC'(c[1:0]); end
          default: begin q = '0; m = '0; end
        endcase
      for (int s = 0; s < S; s++)
        share[(s * 4 + r) * LC +: LC] = head[s] ? q + (first[s] ? m : '0) : '0;
    end
  end
endmodule
