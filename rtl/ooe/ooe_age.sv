//===-- ooe_age.sv - OOE RS age matrix, one per RS class --------------===//
//
// Spec: docs/design-snapshots/ooe-microarchitecture.md, Select (the age
//       matrix, V-13); docs/ooe-rtl-plan.md, decision 6 (reset line)
//
// One bit per ordered pair of entries: older[e*N + j] is set when entry j
// was allocated before entry e. Select reads a row as "these entries are
// older than me" (ooe_pick's older_cq03h). An allocation writes its whole
// row and clears its column:
//
//   - its row: every entry valid besides this group, and every entry
//     allocated on a lower port in this group, is older than it;
//   - its column: it is older than nothing.
//
// Up to A allocations a group, in port order, port 0 oldest. A free writes
// nothing: the row and column of an invalid entry are never read, and its
// next allocation rewrites both.
//
// The update is one edge after the RS writes the group's rows (OA's response
// OI-58, V-75): it takes ooe_rs's registered grants (gnt_v, gnt_idx) and the
// RS's valid bits after that edge, both data. Select cannot see the edge's
// delay: a new entry reaches the request register an edge after its
// allocation at the earliest, so its row and column are in place for the
// first select that could pick it, and no select reads an older row's
// column of an entry not yet past rename's stages (vel).
//
// The reference is the model's RsEntry::age (sim/ooe/ooe_core.h), a global
// allocation count; test/ooe/age_tb.cpp drives this module from the live
// model's allocations and compares every valid pair after every edge.
//
// Reset line (decision 6): the matrix is un-reset payload, its guard the
// RS valid bits. Row e and column e are read only while entry e is valid;
// the antisymmetry assertion below is that read-valid property, stated over
// pairs of valid entries not awaiting this edge's update.
//
// State is one register and its next value a function of it and this
// cycle's inputs alone (CCV-L23, as ooe_freelist). Local clock gating
// (docs/rtl-coding-style.md): a cycle with no group writes nothing, so the
// matrix is clocked only on a group's update (older_en). Its enable is this
// module's flop of rename's Rename 3 valid for the class (CG-5: the lead,
// L2, a stage ahead of the grants), and the reset is flopped before use
// (RST-1).
//===----------------------------------------------------------------------===//
`include "ccv_assert.svh"
`define CCV_CLK ooe_core_clk
`define CCV_RST rst_r01h
module ooe_age #(
  parameter int N = 30,    // entries in this class (CCV_P_RS_RCU or CCV_P_RS_MIU)
  parameter int A = 4,     // allocation ports (CCV_ISSUE_WIDTH)
  localparam int W = $clog2(N)
) (
  input  logic           ooe_core_clk,
  input  logic           ooe_rst_r00h,
  input  logic           alloc_l_cq01h,     // the class allocates at this edge (rename's Rename 3 valid)
  input  logic [N-1:0]   valid_cq02h,       // the RS's valid bits, this group's included
  input  logic [A-1:0]   gnt_v_cq02h,       // port k allocated at the last edge (ooe_rs's grant register)
  input  logic [A*W-1:0] gnt_idx_cq02h,     // port k's entry
  output logic [N*N-1:0] older_cq03h        // row e: the entries older than e
);

  logic rst_r01h;
  always_ff @(posedge ooe_core_clk) begin
    rst_r01h <= ooe_rst_r00h;
  end

  `CCV_ASSERT_KNOWN(valid_known, valid_cq02h)
  `CCV_ASSERT_KNOWN(alloc_l_known, alloc_l_cq01h)
  `CCV_ASSERT_KNOWN(gnt_v_known, gnt_v_cq02h)
  `CCV_ASSERT_KNOWN_IF(gnt_idx_known, |gnt_v_cq02h, gnt_idx_cq02h)

  // One-hot of each port's entry, zero when the port is idle.
  function automatic logic [A*N-1:0] decode(input logic [A-1:0] v, input logic [A*W-1:0] idx);
    logic [A*N-1:0] oh;
    oh = '0;
    for (int k = 0; k < A; k++)
      for (int e = 0; e < N; e++)
        if (v[k] && idx[k*W +: W] == W'(e)) oh[k*N + e] = 1'b1;
    decode = oh;
  endfunction

  // The next matrix. For an entry allocated on port k, its row is the valid
  // entries less this group's, plus those of ports below k; every allocated
  // entry's column is cleared in the other rows.
  function automatic logic [N*N-1:0] next_state(input logic [N*N-1:0] s, input logic [N-1:0] valid,
                                                input logic [A*N-1:0] oh);
    logic [N*N-1:0] m;
    logic [N-1:0]   below, any;
    m   = s;
    any = '0;
    for (int k = 0; k < A; k++) any = any | oh[k*N +: N];
    for (int e = 0; e < N; e++) m[e*N +: N] = s[e*N +: N] & ~any;
    below = valid & ~any;
    for (int k = 0; k < A; k++) begin
      for (int e = 0; e < N; e++)
        if (oh[k*N + e]) m[e*N +: N] = below;
      below = below | oh[k*N +: N];
    end
    next_state = m;
  endfunction

  logic [A*N-1:0] oh_cq02h;
  assign oh_cq02h = decode(gnt_v_cq02h, gnt_idx_cq02h);

  // A group takes entries now valid, and no two ports the same one.
  logic [N-1:0] taken_cq02h;
  logic         clash_cq02h;
  always_comb begin
    taken_cq02h = '0;
    clash_cq02h = 1'b0;
    for (int k = 0; k < A; k++) begin
      clash_cq02h = clash_cq02h | |(taken_cq02h & oh_cq02h[k*N +: N]);
      taken_cq02h = taken_cq02h | oh_cq02h[k*N +: N];
    end
  end
  logic older_en_cq02h;
  `CCV_ASSERT(alloc_valid, (taken_cq02h & ~valid_cq02h) == '0)
  `CCV_ASSERT(alloc_distinct, !clash_cq02h)
  // The lead is the grants' a stage early: the enable is set exactly when a
  // grant is.
  `CCV_ASSERT(lead_exact, older_en_cq02h == |gnt_v_cq02h)

  // V-13 on the read side: of two valid entries past this edge's update,
  // exactly one is older.
  logic [N-1:0] seen_cq02h;
  logic         asym_cq03h;
  assign seen_cq02h = valid_cq02h & ~taken_cq02h;
  always_comb begin
    asym_cq03h = 1'b1;
    for (int e = 0; e < N; e++)
      for (int j = 0; j < N; j++)
        if (seen_cq02h[e] && seen_cq02h[j])
          asym_cq03h = asym_cq03h & ((e == j) ? !older_cq03h[e*N + j]
                                              : (older_cq03h[e*N + j] ^ older_cq03h[j*N + e]));
  end
  `CCV_ASSERT(antisymmetric, asym_cq03h)

  always_ff @(posedge ooe_core_clk) begin
    if (rst_r01h) older_en_cq02h <= 1'b0;
    else          older_en_cq02h <= alloc_l_cq01h;
  end
  always_ff @(posedge ooe_core_clk) begin
    if (older_en_cq02h) older_cq03h <= next_state(older_cq03h, valid_cq02h, oh_cq02h);
  end

endmodule
`undef CCV_CLK
`undef CCV_RST
