// Depth probe (OI-65, shares without a remainder): share_probe's split
// (REM 0: every warp with a head the quotient) feeding the per-offset fits
// (fitsk2_probe with the shares: RS RCU and MIU, GPR and predicate names),
// on one D, from registered counters, head valids and decq's heads.
module sharefits_probe #(parameter int REM = 0, parameter int TAB = 0, parameter int S = 4, parameter int R = 4, parameter int E = 6, parameter int D = 13,
                         localparam int LR = $clog2(R + 1), localparam int H = 2 * R - 1,
                         localparam int LC = $clog2(D + 1)) (
  input  logic [4*5-1:0]   cred,
  input  logic [S-1:0]     head,
  input  logic [S-1:0]     prio,
  input  logic [S*H-1:0]   hv,
  input  logic [S*H*6-1:0] ha,
  input  logic [S*6-1:0]   rob,
  input  logic [S*2-1:0]   ret,
  input  logic [S*3-1:0]   ckf,
  input  logic [S-1:0]     hold,
  output logic [S*(R+1)*R-1:0] fits
);
  logic [S*4*5-1:0] share;
  logic [S*7-1:0]   gal;
  logic [S*5-1:0]   pal, shr;
  logic [S*4-1:0]   shm;
  share_probe #(.S(S), .LC(5), .REM(REM), .TAB(TAB)) u_s (.cred(cred), .head(head), .prio(prio), .share(share));
  always_comb
    for (int s = 0; s < S; s++) begin
      shr[s * 5 +: 5] = share[(s * 4 + 0) * 5 +: 5];
      shm[s * 4 +: 4] = share[(s * 4 + 1) * 5 +: 4];
      gal[s * 7 +: 7] = 7'(share[(s * 4 + 2) * 5 +: 5]);
      pal[s * 5 +: 5] = share[(s * 4 + 3) * 5 +: 5];
    end
  fitsk2_probe #(.S(S), .R(R), .E(E), .D(D), .AR(0), .CAP(0), .RET(1), .SHR(1)) u_f (
    .hv(hv), .cnt('0), .ha(ha), .ev('0), .es('0), .ea('0), .rob(rob), .ret(ret), .cap('0), .shr(shr), .shm(shm),
    .gal(gal), .pal(pal), .ckf(ckf), .hold(hold), .fits(fits));
endmodule
