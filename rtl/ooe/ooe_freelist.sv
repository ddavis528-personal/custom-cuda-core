//===-- ooe_freelist.sv - OOE free list: a bit-vector, rotating start -===//
//
// Spec: docs/design-snapshots/ooe-microarchitecture.md, Rename: Free lists
//       (live: OOE microarchitecture, Free lists; OI-22; DA's response
//       OI-36 for the reset line)
//
// One free list: a bit per pool entry, set while it is free. Up to A
// allocations a cycle take the first A free entries in rotating order from
// a pointer, and the pointer moves past the last one taken, so a freed
// entry comes back late. Any number of frees a cycle cost nothing: they OR
// into the vector at the clock edge, so an entry freed in cycle t can be
// allocated from t + 1.
//
// The reference is the model's FreeVec (sim/ooe/ooe_core.h), which the
// GPR-row and predicate pools use; test/ooe/freelist_tb.cpp drives this
// module from the live model's allocations and frees, cycle by cycle.
//
// Reset line (DA's response OI-36): the free bits reset to all free and the
// pointer to 0, both reset state. Nothing here is un-reset payload.
//
// State is one register, st = {pointer, free bits}, and its next value is a
// function of st and this cycle's inputs alone. That is how a one-cycle loop
// over several fields is written under CCV-L23: the flop's only same-stage
// input is its own previous value.
//
// Requests are a prefix: port k asks only if ports 0 to k-1 do, the order
// rename allocates in. Rename checks the count first, so every port that
// asks is granted (an assertion).
//===----------------------------------------------------------------------===//
`include "ccv_assert.svh"
`define CCV_CLK ooe_core_clk
`define CCV_RST ooe_rst_r00h
module ooe_freelist #(
  parameter int N = 192,   // pool entries (CCV_P_PHYS_REGS rows, or CCV_P_PRED_REGS)
  parameter int A = 4,     // allocation ports (CCV_ISSUE_WIDTH)
  localparam int W = $clog2(N)
) (
  input  logic           ooe_core_clk,
  input  logic           ooe_rst_r00h,
  input  logic [A-1:0]   alloc_req_cq01h,    // port k asks for an entry
  input  logic [N-1:0]   free_mask_cq01h,    // entries freed this cycle
  output logic [A-1:0]   alloc_v_cq02h,      // port k granted
  output logic [A*W-1:0] alloc_idx_cq02h,    // port k's entry
  output logic [N-1:0]   free_cq02h,         // the free bits
  output logic [W-1:0]   ptr_cq02h           // the rotating start
);

  `CCV_ASSERT_KNOWN(alloc_req_known, alloc_req_cq01h)
  `CCV_ASSERT_KNOWN(free_mask_known, free_mask_cq01h)

  // The first free entry at or after the pointer, wrapping: {hit, index}.
  function automatic logic [W:0] first_free(input logic [N-1:0] avail, input logic [W-1:0] ptr);
    logic         hit;
    logic [W-1:0] pick;
    hit  = 1'b0;
    pick = '0;
    for (int i = N - 1; i >= 0; i--) begin
      int p;
      p = 32'(ptr) + i;
      if (p >= N) p = p - N;
      if (avail[p]) begin
        hit  = 1'b1;
        pick = W'(p);
      end
    end
    first_free = {hit, pick};
  endfunction

  // The grants for state s = {pointer, free bits} and requests req: the
  // first A free entries in rotating order. {valid[A], index[A*W]}.
  function automatic logic [A+A*W-1:0] grants(input logic [W+N-1:0] s, input logic [A-1:0] req);
    logic [N-1:0]   avail;
    logic [A-1:0]   v;
    logic [A*W-1:0] idx;
    avail = s[N-1:0];
    v     = '0;
    idx   = '0;
    for (int k = 0; k < A; k++) begin
      logic [W:0] f;
      f = first_free(avail, s[W+N-1:N]);
      if (req[k] & f[W]) begin
        v[k]          = 1'b1;
        idx[k*W +: W] = f[W-1:0];
        avail[f[W-1:0]] = 1'b0;
      end
    end
    grants = {v, idx};
  endfunction

  // The next state: the entries granted leave, the freed ones join, and the
  // pointer moves past the last entry granted.
  function automatic logic [W+N-1:0] next_state(input logic [W+N-1:0] s, input logic [A-1:0] req,
                                                 input logic [N-1:0] freed);
    logic [N-1:0] avail;
    logic [W-1:0] ptr;
    avail = s[N-1:0];
    ptr   = s[W+N-1:N];
    for (int k = 0; k < A; k++) begin
      logic [W:0] f;
      f = first_free(avail, s[W+N-1:N]);
      if (req[k] & f[W]) begin
        avail[f[W-1:0]] = 1'b0;
        ptr = (f[W-1:0] == W'(N - 1)) ? '0 : f[W-1:0] + W'(1);
      end
    end
    next_state = {ptr, avail | freed};
  endfunction

  logic [W+N-1:0] st_cq02h;
  always_comb {alloc_v_cq02h, alloc_idx_cq02h} = grants(st_cq02h, alloc_req_cq01h);
  assign free_cq02h = st_cq02h[N-1:0];
  assign ptr_cq02h  = st_cq02h[W+N-1:N];

  // Rename checked the count, so every port that asks is granted.
  `CCV_ASSERT(alloc_granted, (alloc_req_cq01h & ~alloc_v_cq02h) == '0)
  // A free names an entry that is allocated, or one granted this same cycle
  // (renamed and squashed within one edge): anything else is a double free,
  // a bug upstream.
  logic [N-1:0] granted_cq02h;
  always_comb begin
    granted_cq02h = '0;
    for (int k = 0; k < A; k++)
      if (alloc_v_cq02h[k]) granted_cq02h[alloc_idx_cq02h[k*W +: W]] = 1'b1;
  end
  `CCV_ASSERT(no_double_free, (free_mask_cq01h & free_cq02h & ~granted_cq02h) == '0)

  always_ff @(posedge ooe_core_clk) begin
    if (ooe_rst_r00h) st_cq02h <= {W'(0), {N{1'b1}}};
    else              st_cq02h <= next_state(st_cq02h, alloc_req_cq01h, free_mask_cq01h);
  end

endmodule
`undef CCV_CLK
`undef CCV_RST
