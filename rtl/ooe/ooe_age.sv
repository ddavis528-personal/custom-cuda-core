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
//   - its row: every entry still valid, and every entry allocated on a
//     lower port this same cycle, is older than it;
//   - its column: it is older than nothing.
//
// Up to A allocations a cycle, in port order, port 0 oldest. A free writes
// nothing: the row and column of an invalid entry are never read, and its
// next allocation rewrites both.
//
// The reference is the model's RsEntry::age (sim/ooe/ooe_core.h), a global
// allocation count; test/ooe/age_tb.cpp drives this module from the live
// model's allocations and compares every valid pair after every edge.
//
// Reset line (decision 6): the matrix is un-reset payload, its guard the
// RS valid bits (valid_cq01h, reset state held by the RS). Row e and column
// e are read only while entry e is valid; the antisymmetry assertion below
// is that read-valid property, stated over pairs of valid entries.
//
// State is one register and its next value a function of it and this
// cycle's inputs alone (CCV-L23, as ooe_freelist).
//===----------------------------------------------------------------------===//
`include "ccv_assert.svh"
`define CCV_CLK ooe_core_clk
`define CCV_RST ooe_rst_r00h
module ooe_age #(
  parameter int N = 30,    // entries in this class (CCV_P_RS_RCU or CCV_P_RS_MIU)
  parameter int A = 4,     // allocation ports (CCV_ISSUE_WIDTH)
  localparam int W = $clog2(N)
) (
  input  logic           ooe_core_clk,
  input  logic           ooe_rst_r00h,
  input  logic [N-1:0]   valid_cq01h,       // entries valid, none of this cycle's allocations
  input  logic [A-1:0]   alloc_v_cq01h,     // port k allocates
  input  logic [A*W-1:0] alloc_idx_cq01h,   // port k's entry
  output logic [N*N-1:0] older_cq02h        // row e: the entries older than e
);

  `CCV_ASSERT_KNOWN(valid_known, valid_cq01h)
  `CCV_ASSERT_KNOWN(alloc_v_known, alloc_v_cq01h)
  `CCV_ASSERT_KNOWN_IF(alloc_idx_known, |alloc_v_cq01h, alloc_idx_cq01h)

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
  // entries plus those of ports below k; every allocated entry's column is
  // cleared in the other rows.
  function automatic logic [N*N-1:0] next_state(input logic [N*N-1:0] s, input logic [N-1:0] valid,
                                                input logic [A*N-1:0] oh);
    logic [N*N-1:0] m;
    logic [N-1:0]   below, any;
    m   = s;
    any = '0;
    for (int k = 0; k < A; k++) any = any | oh[k*N +: N];
    for (int e = 0; e < N; e++)
      for (int j = 0; j < N; j++)
        if (any[j]) m[e*N + j] = 1'b0;
    below = valid;
    for (int k = 0; k < A; k++) begin
      for (int e = 0; e < N; e++)
        if (oh[k*N + e]) m[e*N +: N] = below;
      below = below | oh[k*N +: N];
    end
    next_state = m;
  endfunction

  logic [A*N-1:0] oh_cq01h;
  assign oh_cq01h = decode(alloc_v_cq01h, alloc_idx_cq01h);

  // An allocation takes an invalid entry, and no two ports the same one.
  logic [N-1:0] taken_cq01h;
  logic         clash_cq01h;
  always_comb begin
    taken_cq01h = '0;
    clash_cq01h = 1'b0;
    for (int k = 0; k < A; k++) begin
      clash_cq01h = clash_cq01h | |(taken_cq01h & oh_cq01h[k*N +: N]);
      taken_cq01h = taken_cq01h | oh_cq01h[k*N +: N];
    end
  end
  `CCV_ASSERT(alloc_invalid, (taken_cq01h & valid_cq01h) == '0)
  `CCV_ASSERT(alloc_distinct, !clash_cq01h)

  // V-13 on the read side: of two valid entries, exactly one is older.
  logic asym_cq02h;
  always_comb begin
    asym_cq02h = 1'b1;
    for (int e = 0; e < N; e++)
      for (int j = 0; j < N; j++)
        if (valid_cq01h[e] && valid_cq01h[j])
          asym_cq02h = asym_cq02h & ((e == j) ? !older_cq02h[e*N + j]
                                              : (older_cq02h[e*N + j] ^ older_cq02h[j*N + e]));
  end
  `CCV_ASSERT(antisymmetric, asym_cq02h)

  always_ff @(posedge ooe_core_clk)
    older_cq02h <= next_state(older_cq02h, valid_cq01h, oh_cq01h);

endmodule
`undef CCV_CLK
`undef CCV_RST
