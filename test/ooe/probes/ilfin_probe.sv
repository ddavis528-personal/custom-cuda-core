// Depth probe (OA-22): the split go as costed. Registered: fits (the
// interleave's, ROB with retirement frees a cycle late) and take_q, lane
// inputs of the short path (one warp, from registered state, OA-22 (iii)).
// Arriving: fr, each RS class's free thermometer (ooe_rs's, cap 4); the
// short bit compares them with registered one-hot R - avail (RCU against
// twice R when a head uop is a copy), and selects the path.
module ilfin_probe #(parameter int S = 4, parameter int R = 4, parameter int W = 16, parameter int OUT = 0,
                     localparam int LR = $clog2(R + 1)) (
  input  logic [S*LR-1:0]  fits,
  input  logic [S-1:0]     prio,
  input  logic [S*R*W-1:0] uops,
  input  logic [S*LR-1:0]  take1,      // the short path, from registered state
  input  logic [S-1:0]     pick1,
  input  logic [2*9-1:0]   sdf,        // one-hot 0..8, R - avail or 2R - avail
  input  logic             short_q,
  input  logic [2*4-1:0]   fr,
  output logic [S*LR-1:0]  take,
  output logic [R*W-1:0]   lane
);
  logic [S*LR-1:0] take_i;
  logic [R*W-1:0]  lane_i, lane_1;
  logic            shrt;
  il_probe #(.S(S), .R(R), .W(W), .OUT(0)) u_t (.fits(fits), .prio(prio), .uops(uops), .take(take_i), .lane(), .lane_w());
  il_probe #(.S(S), .R(R), .W(W), .OUT(1)) u_l (.fits(fits), .prio(prio), .uops(uops), .take(), .lane(lane_i), .lane_w());
  function automatic logic cov(input logic [8:0] d, input logic [3:0] t);
    cov = d[0] | (d[1] & t[0]) | (d[2] & t[1]) | (d[3] & t[2]) | (d[4] & t[3]);
  endfunction
  always_comb begin
    shrt = short_q || !cov(sdf[0 +: 9], fr[0 +: 4]) || !cov(sdf[9 +: 9], fr[4 +: 4]);
    lane_1 = '0;
    for (int s = 0; s < S; s++)
      for (int j = 0; j < R; j++)
        if (pick1[s] && LR'(j) < take1[s * LR +: LR]) lane_1[j * W +: W] = lane_1[j * W +: W] | uops[(s * R + j) * W +: W];
    take = shrt ? take1 : take_i;
    lane = shrt ? lane_1 : lane_i;
    if (OUT == 0) lane = '0;
    else take = '0;
  end
endmodule
