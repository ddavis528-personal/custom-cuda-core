//===-- ooe_pick.sv - OOE per-resource select ---------------------===//
//
// Spec: docs/design-snapshots/ooe-microarchitecture.md, Scheduling: Select
//       (live: OOE microarchitecture, Select; DA's response OI-31)
//
// One RS class's select. Each resource (a lane section, an MIU pipe, or the
// RCU unit) grants its oldest requester, and an entry issues only if it wins
// every resource it requests. Co-issued footprints are disjoint by
// construction (V-60): no grant count feeds another pick, so the R picks run
// in parallel and the depth is one oldest-of-N plus an AND over R.
//
// The reference is ooe::pickResources (sim/ooe/ooe_core.cpp), which the
// model's select calls; test/ooe/pick_tb.cpp holds the two in lockstep.
//
// req[e*R + k]: entry e requests resource k. A requester is a valid, ready
// entry: the caller ANDs valid and ready into req, so an invalid entry's
// row of `older` (un-reset payload) is never read unmasked.
// older[e*N + j]: entry j is older than entry e. Meaningful only when both
// are valid, which req guarantees for every term that reaches a grant.
//===----------------------------------------------------------------------===//

module ooe_pick #(
  parameter int N = 30,   // entries in the class (CCV_P_RS_RCU or CCV_P_RS_MIU)
  parameter int R = 5     // resources the class picks (S0-S3 and R, or P0-P3)
) (
  input  logic [N*R-1:0] req_cq03h,
  input  logic [N*N-1:0] older_cq03h,
  output logic [N-1:0]   issue_cq03h,   // wins every resource it requests
  output logic [N-1:0]   lost_cq03h,    // won some resource, lost another
  output logic [N*R-1:0] win_cq03h      // win[e*R + k]: e is k's oldest requester
);

  // win: e requests k and no older entry requests k. One oldest-of-N per
  // resource, all R in parallel.
  always_comb begin
    for (int k = 0; k < R; k++) begin
      for (int e = 0; e < N; e++) begin
        logic beaten;
        beaten = 1'b0;
        for (int j = 0; j < N; j++)
          beaten = beaten | (req_cq03h[j*R + k] & older_cq03h[e*N + j]);
        win_cq03h[e*R + k] = req_cq03h[e*R + k] & ~beaten;
      end
    end
  end

  // An entry issues when it requests something and wins all it requests.
  always_comb begin
    for (int e = 0; e < N; e++) begin
      logic any_req, all_won, some_won;
      any_req  = |req_cq03h[e*R +: R];
      all_won  = &(~req_cq03h[e*R +: R] | win_cq03h[e*R +: R]);
      some_won = |win_cq03h[e*R +: R];
      issue_cq03h[e] = any_req & all_won;
      lost_cq03h[e]  = some_won & ~all_won;
    end
  end

endmodule
