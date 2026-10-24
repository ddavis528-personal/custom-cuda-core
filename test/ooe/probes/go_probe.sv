// Depth probe (OI-63): rename's go over registered per-slot fits, built in
// parallel. S slots, fits (0..R uops) each, a rotating priority (one-hot).
// One pick: the first slot in priority order with fits > 0 takes fits.
// Two picks: the second such slot takes min(fits, R - the first's).
module go_probe #(parameter int S = 4, parameter int R = 4, parameter int TWO = 1,
                  localparam int LR = $clog2(R + 1)) (
  input  logic [S*LR-1:0] fits,
  input  logic [S-1:0]    prio,
  output logic [S*LR-1:0] take
);
  logic [S-1:0] nz, first, second;
  logic [LR-1:0] f1;
  always_comb begin
    for (int s = 0; s < S; s++) nz[s] = fits[s * LR +: LR] != '0;
    // Slots ahead of s in the order starting at st: st, st+1, ... s-1.
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
    for (int s = 0; s < S; s++) f1 = f1 | ({LR{first[s]}} & fits[s * LR +: LR]);
    for (int s = 0; s < S; s++) begin
      logic [LR-1:0] room, t2;
      room = LR'(R) - f1;
      t2   = fits[s * LR +: LR] < room ? fits[s * LR +: LR] : room;
      take[s * LR +: LR] = ({LR{first[s]}} & fits[s * LR +: LR]) | ({LR{TWO != 0 && second[s]}} & t2);
    end
  end
endmodule
