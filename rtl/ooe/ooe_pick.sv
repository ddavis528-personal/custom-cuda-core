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
//
// The fallback (FB > 0; OA's response IS-9), on resources 0-3, the lane
// sections: a section whose winner does not issue grants instead its
// oldest requester naming that section alone (FB 1); with FB 2, an aligned
// half (sections 0-1, 2-3) whose sections both fall through grants its
// oldest half-footprint requester, if that is the oldest of the half's
// pair and single-section requesters. Each is one more oldest-of-N over
// the same ages, beside the main pick; only "did this section's winner
// issue" waits for it, so the fallback adds an OR and a 2:1 select after
// the issue AND. A fallback grant takes only sections no issued entry
// holds, one requester a section or a half, so V-60 still holds; the
// oldest requester still wins all it names (V-12). fb marks those grants.
//===----------------------------------------------------------------------===//

module ooe_pick #(
  parameter int N = 30,   // entries in the class (CCV_P_RS_RCU or CCV_P_RS_MIU)
  parameter int R = 5,    // resources the class picks (S0-S3 and R, or P0-P3)
  parameter int FB = 0    // the section fallback: 0 none, 1 section, 2 section and half (needs R >= 4)
) (
  input  logic [N*R-1:0] req_cq03h,
  input  logic [N*N-1:0] older_cq03h,
  output logic [N-1:0]   issue_cq03h,   // wins every resource it requests
  output logic [N-1:0]   lost_cq03h,    // won some resource, lost another
  output logic [N*R-1:0] win_cq03h,     // win[e*R + k]: e is k's oldest requester
  output logic [N-1:0]   fb_cq03h       // issues by the fallback, not the main pick
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

  // An entry wins the main pick when it requests something and wins all it
  // requests.
  logic [N-1:0] main;
  always_comb begin
    for (int e = 0; e < N; e++) begin
      logic any_req, all_won, some_won;
      any_req  = |req_cq03h[e*R +: R];
      all_won  = &(~req_cq03h[e*R +: R] | win_cq03h[e*R +: R]);
      some_won = |win_cq03h[e*R +: R];
      main[e]        = any_req & all_won;
      lost_cq03h[e]  = some_won & ~all_won;
    end
  end

  if (FB == 0) begin : g_nofb
    assign issue_cq03h = main;
    assign fb_cq03h    = '0;
  end else begin : g_fb
    // The fallback's requesters, from the request rows alone: one[e*4+k],
    // e names section k and nothing else; two[e*2+h], e names half h's two
    // sections and nothing else; uni[e*2+h], either, within half h.
    logic [N*4-1:0] one, f1;
    logic [N*2-1:0] two, uni, fu;
    logic [3:0]     free_s;
    logic [1:0]     pair, half;
    always_comb begin
      for (int e = 0; e < N; e++) begin
        for (int k = 0; k < 4; k++)
          one[e*4 + k] = req_cq03h[e*R +: R] == R'(1 << k);
        for (int h = 0; h < 2; h++) begin
          two[e*2 + h] = FB >= 2 && req_cq03h[e*R +: R] == R'(3 << (2 * h));
          uni[e*2 + h] = one[e*4 + 2*h] | one[e*4 + 2*h + 1] | two[e*2 + h];
        end
      end
      // Each pick's oldest requester, beside the main pick.
      for (int e = 0; e < N; e++) begin
        for (int k = 0; k < 4; k++) begin
          logic beaten;
          beaten = 1'b0;
          for (int j = 0; j < N; j++) beaten = beaten | (one[j*4 + k] & older_cq03h[e*N + j]);
          f1[e*4 + k] = one[e*4 + k] & ~beaten;
        end
        for (int h = 0; h < 2; h++) begin
          logic beaten;
          beaten = 1'b0;
          for (int j = 0; j < N; j++) beaten = beaten | (uni[j*2 + h] & older_cq03h[e*N + j]);
          fu[e*2 + h] = uni[e*2 + h] & ~beaten;
        end
      end
      // Half h's oldest is a pair: from the requests and ages alone.
      for (int h = 0; h < 2; h++) begin
        pair[h] = 1'b0;
        for (int e = 0; e < N; e++) pair[h] = pair[h] | (fu[e*2 + h] & two[e*2 + h]);
      end
      // A section falls through when its winner does not issue.
      for (int k = 0; k < 4; k++) begin
        free_s[k] = 1'b1;
        for (int e = 0; e < N; e++) free_s[k] = free_s[k] & ~(win_cq03h[e*R + k] & main[e]);
      end
      for (int h = 0; h < 2; h++) half[h] = pair[h] & free_s[2*h] & free_s[2*h + 1];
      for (int e = 0; e < N; e++) begin
        fb_cq03h[e] = 1'b0;
        for (int h = 0; h < 2; h++) begin
          fb_cq03h[e] = fb_cq03h[e] | (half[h] & fu[e*2 + h] & two[e*2 + h]);
          for (int k = 2*h; k < 2*h + 2; k++)
            fb_cq03h[e] = fb_cq03h[e] | (~half[h] & free_s[k] & f1[e*4 + k]);
        end
      end
    end
    assign issue_cq03h = main | fb_cq03h;
  end

endmodule
