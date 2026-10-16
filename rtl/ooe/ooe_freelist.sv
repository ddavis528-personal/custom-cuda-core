//===-- ooe_freelist.sv - OOE free list: candidate buffer, banked refill -===//
//
// Spec: OA's response OI-38 (the design doc's Free lists section): an
//       8-entry candidate buffer refilled from four interleaved banks;
//       DA's response OI-39 for when a freed entry may be reused; DA's
//       response OI-36 for the reset line.
//
// One free list: a bit per pool entry, set while it is free, and a buffer
// of up to B free entries in order, the only source of allocations. Up to
// A allocations a cycle take the buffer's first k entries: the grant is the
// buffer's head, with no search on the allocation path.
//
// At each clock edge the buffer is refilled. The N entries form K
// interleaved banks (entry mod K). Each bank finds its first free entry
// that is not already buffered, at or after its own rotating pointer, a
// find-first over N/K entries. The banks append in a rotating order, at
// most one entry each, while there is room behind the entries this cycle
// did not take. A bank with no candidate appends nothing. The bank order
// advances by one every edge, and a bank's pointer moves past the entry it
// appended.
//
// Frees OR into the free bits at the edge. Refill reads the bits as they
// stood before that edge, so an entry freed in cycle t is visible to
// refill in t + 1 and to allocation in t + 2: the free list takes the
// one-cycle hold, because its allocation does not fit a stage without it
// (OI-38; reuse is decided per structure, DA's response OI-39). Buffered
// entries stay set in the free bits, so the admission floors count them.
//
// The reference is the model's FreeVec in its buffered form
// (sim/ooe/ooe_core.h); test/ooe/freelist_tb.cpp drives this module from
// the live model's allocations and frees and compares the buffer, bits,
// bank pointers and bank order after every edge.
//
// Reset line (decision 6): the free bits reset to all free, the buffer to
// empty, the bank pointers and bank order to 0, all reset state. The
// buffer's entries are payload guarded by the count: an entry at or past
// the count is never granted or matched.
//
// State is one register, and its next value a function of it and this
// cycle's inputs alone (CCV-L23); the flop takes one function, step(),
// with reset folded in (see ooe_decq).
//===----------------------------------------------------------------------===//
`include "ccv_assert.svh"
`define CCV_CLK ooe_core_clk
`define CCV_RST ooe_rst_r00h
module ooe_freelist #(
  parameter int N = 192,   // pool entries (CCV_P_PHYS_REGS rows, or CCV_P_PRED_REGS)
  parameter int A = 4,     // allocation ports (CCV_ISSUE_WIDTH)
  parameter int B = 8,     // candidate buffer entries (OI-38)
  parameter int K = 4,     // refill banks (OI-38); divides N
  localparam int W  = $clog2(N),
  localparam int M  = N / K,
  localparam int LM = $clog2(M),
  localparam int LB = $clog2(B + 1),
  localparam int LK = (K > 1) ? $clog2(K) : 1,
  localparam int LP = (M > 1) ? $clog2(M) : 1,   // tree levels over a bank
  localparam int P  = 1 << LP                    // a bank, padded to a power of 2
) (
  input  logic           ooe_core_clk,
  input  logic           ooe_rst_r00h,
  input  logic [A-1:0]   alloc_req_cq01h,    // port k asks for an entry
  input  logic [N-1:0]   free_mask_cq01h,    // entries freed this cycle
  output logic [A-1:0]   alloc_v_cq02h,      // port k granted
  output logic [A*W-1:0] alloc_idx_cq02h,    // port k's entry
  output logic [N-1:0]   free_cq02h,         // the free bits
  output logic [B*W-1:0] buf_cq02h,          // the buffer, head first
  output logic [LB-1:0]  cnt_cq02h,          // entries in the buffer
  output logic [K*LM-1:0] bptr_cq02h,        // each bank's pointer, within the bank
  output logic [LK-1:0]  rot_cq02h           // the bank refill starts with
);

  // The state's fields.
  localparam int OBITS = 0;
  localparam int OBUF  = OBITS + N;
  localparam int OCNT  = OBUF + B * W;
  localparam int OPTR  = OCNT + LB;
  localparam int OROT  = OPTR + K * LM;
  localparam int OIN   = OROT + LK;         // N bits: entry is in the buffer
  localparam int SW    = OIN + N;

  `CCV_ASSERT_KNOWN(alloc_req_known, alloc_req_cq01h)
  `CCV_ASSERT_KNOWN(free_mask_known, free_mask_cq01h)

  // Allocation takes the buffer's head: port k gets entry k.
  function automatic logic [A+A*W-1:0] grants(input logic [SW-1:0] st, input logic [A-1:0] req);
    logic [A-1:0]   v;
    logic [A*W-1:0] idx;
    for (int k = 0; k < A; k++) begin
      v[k]          = req[k] && k < 32'(st[OCNT +: LB]);
      idx[k*W +: W] = v[k] ? st[OBUF + k * W +: W] : '0;
    end
    grants = {v, idx};
  endfunction

  // The lowest set bit of a bank's M bits, as a balanced tree: {hit, index}.
  function automatic logic [LM:0] ffs(input logic [M-1:0] v);
    logic [P-1:0]    h, hn;
    logic [P*LM-1:0] x, xn;
    h = '0;
    x = '0;
    for (int i = 0; i < M; i++) begin
      h[i]          = v[i];
      x[i*LM +: LM] = LM'(i);
    end
    for (int l = 0; l < LP; l++) begin
      hn = '0;
      xn = '0;
      for (int i = 0; i < P / 2; i++) begin
        hn[i]          = h[2*i] | h[2*i+1];
        xn[i*LM +: LM] = h[2*i] ? x[2*i*LM +: LM] : x[(2*i+1)*LM +: LM];
      end
      h = hn;
      x = xn;
    end
    ffs = {h[0], x[LM-1:0]};
  endfunction

  // A bank's candidate: its first entry in v at or after pointer ptr,
  // wrapping. The entries at or after the pointer and all of them are
  // searched at once, and the first wins when it hits. {found, index}.
  function automatic logic [LM:0] first_from(input logic [M-1:0] v, input logic [LM-1:0] ptr);
    logic [M-1:0] ge;
    logic [LM:0]  hi, all;
    for (int i = 0; i < M; i++) ge[i] = LM'(i) >= ptr;
    hi  = ffs(v & ge);
    all = ffs(v);
    first_from = hi[LM] ? hi : all;
  endfunction

  // The same first entry as a one-hot, from a log-depth prefix OR, so the
  // buffered mask is updated without decoding the index back.
  function automatic logic [M-1:0] first_oh(input logic [M-1:0] v, input logic [LM-1:0] ptr);
    logic [M-1:0] ge, hi, below_hi, below_all, t;
    for (int i = 0; i < M; i++) ge[i] = LM'(i) >= ptr;
    hi = v & ge;
    // below[i]: some bit under i is set (exclusive prefix OR, Kogge-Stone).
    below_hi  = hi << 1;
    below_all = v << 1;
    for (int d = 1; d < M; d = d * 2) begin
      t         = below_hi << d;
      below_hi  = below_hi | t;
      t         = below_all << d;
      below_all = below_all | t;
    end
    first_oh = (|hi) ? (hi & ~below_hi) : (v & ~below_all);
  endfunction

  // The next state. Every value on the edge's path is a narrow field:
  // the buffer is rebuilt slot by slot (a gather), each slot either an
  // entry this cycle did not take or the r-th candidate of the banks in
  // rotating order, so no position is computed and then written through.
  function automatic logic [SW-1:0] next_state(input logic [SW-1:0] st, input logic [A-1:0] req,
                                               input logic [N-1:0] freed);
    logic [N-1:0]      bits, inbuf, taken, added;
    logic [M-1:0]      bank;
    logic [LM:0]       fc;
    logic [B*W-1:0]    buf_q, nbuf;
    logic [K*LM-1:0]   bptr, cand;
    logic [K-1:0]      found, ord_ok;
    logic [K*W-1:0]    ent;                // each bank's candidate entry
    logic [K*M-1:0]    oh;                 // and as a one-hot within its bank
    logic [K*LK-1:0]   ord_bank;              // the r-th found bank, in rotating order
    logic [K*LB-1:0]   rank;               // each bank's rank among the found
    logic [LB-1:0]     cnt, kk, rem, nfound, room, r;
    logic [LK-1:0]     rot, bj;
    bits  = st[OBITS +: N];
    buf_q = st[OBUF +: B * W];
    cnt   = st[OCNT +: LB];
    bptr  = st[OPTR +: K * LM];
    rot   = st[OROT +: LK];
    inbuf = st[OIN +: N];
    // Taken this cycle: the buffer's first kk entries. The requests are a
    // prefix (req_prefix), so their number is where the prefix ends: a
    // one-hot encode, not a running count.
    taken = '0;
    for (int i = 0; i < A; i++)
      if (req[i] && LB'(i) < cnt) taken[buf_q[i * W +: W]] = 1'b1;
    kk = '0;
    for (int i = 1; i <= A; i++)
      if (req[i-1] && (i == A || !req[i % A])) kk = kk | LB'(i);
    if (kk > cnt) kk = cnt;   // never: alloc_granted
    rem = cnt - kk;
    // Each bank's candidate: its first free, unbuffered entry at or after
    // its pointer. State only, so it runs beside the requests.
    found = '0;
    cand  = '0;
    ent   = '0;
    oh    = '0;
    for (int bb = 0; bb < K; bb++) begin
      for (int i = 0; i < M; i++) bank[i] = bits[i * K + bb] && !inbuf[i * K + bb];
      fc                  = first_from(bank, bptr[bb * LM +: LM]);
      found[bb]           = fc[LM];

      cand[bb * LM +: LM] = fc[LM-1:0];
      ent[bb * W +: W]    = W'(32'(fc[LM-1:0]) * K + bb);
      oh[bb * M +: M]     = first_oh(bank, bptr[bb * LM +: LM]);
    end
    // The found banks in rotating order: each one's rank, and the r-th.
    rank   = '0;
    ord_ok  = '0;
    ord_bank  = '0;
    nfound = '0;
    for (int j = 0; j < K; j++) begin
      bj = rot + LK'(j);
      if (K > 1 && 32'(rot) + j >= K) bj = LK'(32'(rot) + j - K);
      if (found[bj]) begin
        rank[32'(bj) * LB +: LB] = nfound;
        nfound = nfound + LB'(1);
      end
    end
    for (int rr = 0; rr < K; rr++)
      for (int bb = 0; bb < K; bb++)
        if (found[bb] && rank[bb * LB +: LB] == LB'(rr)) begin
          ord_ok[rr]             = 1'b1;
          ord_bank[rr * LK +: LK]  = LK'(bb);
        end
    // The room behind the entries this cycle did not take.
    room = LB'(B) - rem;
    // The buffer, slot by slot.
    nbuf = '0;
    for (int i = 0; i < B; i++) begin
      if (LB'(i) < rem) begin
        for (int q = 0; q <= A; q++)
          if (kk == LB'(q) && i + q < B) nbuf[i * W +: W] = buf_q[(i + q) * W +: W];
      end else begin
        r = LB'(i) - rem;
        for (int rr = 0; rr < K; rr++)
          if (r == LB'(rr) && ord_ok[rr]) nbuf[i * W +: W] = ent[32'(ord_bank[rr * LK +: LK]) * W +: W];
      end
    end
    // A bank whose candidate went in moves its pointer past it.
    added = '0;
    for (int bb = 0; bb < K; bb++)
      if (found[bb] && rank[bb * LB +: LB] < room) begin   // rank < nfound already
        for (int i = 0; i < M; i++) added[i * K + bb] = oh[bb * M + i];
        bptr[bb * LM +: LM]     = (32'(cand[bb * LM +: LM]) == M - 1) ? '0 : cand[bb * LM +: LM] + LM'(1);
      end
    rot = (32'(rot) == K - 1) ? '0 : rot + LK'(1);
    next_state = {(inbuf & ~taken) | added, rot, bptr,
                  (32'(rem) + 32'(nfound) > B) ? LB'(B) : rem + nfound,
                  nbuf, (bits & ~taken) | freed};
  endfunction

  // The reset state: all free, the buffer empty, pointers and order at 0.
  function automatic logic [SW-1:0] reset_of(input logic [SW-1:0] st);
    logic [SW-1:0] m;
    m = st;
    m[OBITS +: N]          = '1;
    m[OCNT +: LB]          = '0;
    m[OPTR +: K * LM + LK] = '0;
    m[OIN +: N]            = '0;
    reset_of = m;
  endfunction

  // One edge: reset, or the update.
  function automatic logic [SW-1:0] step(input logic [SW-1:0] st, input logic rst,
                                         input logic [A-1:0] req, input logic [N-1:0] freed);
    step = rst ? reset_of(st) : next_state(st, req, freed);
  endfunction

  logic [SW-1:0] st_cq02h;
  always_comb {alloc_v_cq02h, alloc_idx_cq02h} = grants(st_cq02h, alloc_req_cq01h);
  assign free_cq02h = st_cq02h[OBITS +: N];
  assign buf_cq02h  = st_cq02h[OBUF +: B * W];
  assign cnt_cq02h  = st_cq02h[OCNT +: LB];
  assign bptr_cq02h = st_cq02h[OPTR +: K * LM];
  assign rot_cq02h  = st_cq02h[OROT +: LK];

  // Rename checks the buffer's count first, so every port that asks is
  // granted.
  `CCV_ASSERT(alloc_granted, (alloc_req_cq01h & ~alloc_v_cq02h) == '0)
  // Port k asks only if ports 0 to k-1 do, the order rename allocates in.
  `CCV_ASSERT(req_prefix, (alloc_req_cq01h & (alloc_req_cq01h + A'(1))) == '0)
  // A free names an entry that is allocated, or one granted this same
  // cycle (renamed and squashed within one edge): anything else free or
  // buffered is a double free, a bug upstream.
  logic [N-1:0] granted_cq02h;
  always_comb begin
    granted_cq02h = '0;
    for (int k = 0; k < A; k++)
      if (alloc_v_cq02h[k]) granted_cq02h[alloc_idx_cq02h[k*W +: W]] = 1'b1;
  end
  `CCV_ASSERT(no_double_free, (free_mask_cq01h & free_cq02h & ~granted_cq02h) == '0)

  always_ff @(posedge ooe_core_clk) begin
    st_cq02h <= step(st_cq02h, ooe_rst_r00h, alloc_req_cq01h, free_mask_cq01h);
  end

endmodule
`undef CCV_CLK
`undef CCV_RST
