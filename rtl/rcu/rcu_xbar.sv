//===-- rcu_xbar.sv - RCU collective crossbar: out[l] = src[s], sel[l][s] -===//
//
// Spec: docs/design-snapshots/rcu-arch-r-unit.md (live: CCV RCU
//       Architecture, R unit and crossbar tab: Crossbar, Depth)
//
// The shfl crossbar of the R pipe's A+1 compute: each output lane takes a
// 32:1 AND-OR of the source lanes' words under its one-hot select. rcu_r
// makes the selects: the immediate forms' from a decoded index, the
// register forms' (idx, up, down and butterfly by v(R1)) by rewiring the
// decode of each lane's own amount, so no index is added before the
// decode (the register up and down forms' adder put A+1 at 32.3 NGD). A combinational
// inner helper of rcu_r, timed as its parent's logic (rcu_xbar.ngd.json);
// alone it is held to CCV_NGD_INNER, 16.
//
// The reference is the RCU model's shfl (sim/rcu/rcu_core.cpp, the shfl
// lambda); test/rcu/xbar_tb.cpp holds the two together.
//===----------------------------------------------------------------------===//
module rcu_xbar #(
  parameter int LANES = 32,   // lanes (CCV_LANES)
  parameter int W = 32        // bits a lane's word
) (
  input  logic [LANES*W-1:0]  src,   // lane l's word at l*W
  input  logic [LANES*LANES-1:0] sel,   // output lane l's source lane, one-hot at l*LANES
  output logic [LANES*W-1:0]  out    // out[l] = src[s], sel[l*LANES + s]
);

  always_comb begin
    for (int l = 0; l < LANES; l++) begin
      logic [W-1:0] acc;
      acc = '0;
      for (int s = 0; s < LANES; s++)
        acc = acc | ({W{sel[l*LANES + s]}} & src[s*W +: W]);
      out[l*W +: W] = acc;
    end
  end

endmodule
