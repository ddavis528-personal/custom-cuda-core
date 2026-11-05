//===-- rcu_xbar.sv - RCU collective crossbar: out[l] = src[idx[l]] ------===//
//
// Spec: docs/design-snapshots/rcu-arch-r-unit.md (live: CCV RCU
//       Architecture, R unit and crossbar tab: Crossbar, Depth)
//
// The shfl crossbar of the R pipe's A+1 compute: each output lane decodes
// its 5-bit source index to a one-hot and takes a 32:1 AND-OR of the source
// lanes' words. Every lane's index equal is the immediate-index form; the
// register-index form takes each lane's index from v(R1). A combinational
// inner helper of rcu_r, timed as its parent's logic (rcu_xbar.ngd.json);
// alone it is held to CCV_NGD_INNER, 16.
//
// The reference is the RCU model's shfl (sim/rcu/rcu_core.cpp, the shfl
// lambda); test/rcu/xbar_tb.cpp holds the two together.
//===----------------------------------------------------------------------===//
module rcu_xbar #(
  parameter int LANES = 32,   // lanes (CCV_LANES)
  parameter int W = 32,       // bits a lane's word
  localparam int LI = $clog2(LANES)
) (
  input  logic [LANES*W-1:0]  src,   // lane l's word at l*W
  input  logic [LANES*LI-1:0] idx,   // output lane l's source lane at l*LI
  output logic [LANES*W-1:0]  out    // out[l] = src[idx[l]]
);

  always_comb begin
    for (int l = 0; l < LANES; l++) begin
      logic [W-1:0] acc;
      acc = '0;
      for (int s = 0; s < LANES; s++)
        acc = acc | ({W{idx[l*LI +: LI] == LI'(s)}} & src[s*W +: W]);
      out[l*W +: W] = acc;
    end
  end

endmodule
