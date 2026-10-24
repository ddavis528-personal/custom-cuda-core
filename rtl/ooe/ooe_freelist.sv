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
// buffer's head, with no search on the allocation path. The grant ports
// offer the head from the flops alone (OA's stage-boundary map, item 5):
// entry k is available while the buffer holds more than k, and rename's
// port k takes it when it asks, so no request reaches an output.
//
// The request is registered (OA's response OI-52): the entries a cycle
// takes leave the buffer at the following edge, not this one, so the
// buffer's next value and its clock enable come from the module's own
// flops (CG-5). Until then those entries, in transit, sit at the head: the
// grant ports offer the entries behind them (a mux on the registered
// count), and the count rename sees (avail) leaves them out. A taken
// entry's free bit clears with them, at the late edge (OA's response
// OI-58), from the registered count alone: exact, because the entries stay
// buffered until then, so refill cannot buffer them again.
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
// Frees OR into the free bits at the edge. They come from the retire
// stage's register and a registered squash (OA's response OI-58), so a
// free never names an entry granted the same cycle, and the free list
// flops their lead, the ROB's decision a cycle earlier (free_l), as the
// free bits' enable (L2). Refill reads the bits as they
// stood before that edge, so an entry freed in cycle t is visible to
// refill in t + 1 and to allocation in t + 2: the free list takes the
// one-cycle hold, because its allocation does not fit a stage without it
// (OI-38; reuse is decided per structure, DA's response OI-39). Buffered
// entries stay set in the free bits, so the admission floors count them.
//
// The reference is the model's FreeVec in its buffered form
// (sim/ooe/ooe_core.h); test/ooe/freelist_tb.cpp drives this module from
// the live model's allocations and frees and compares the buffer, its
// count and the entries in transit, the bits, the bank pointers and the
// bank order after every edge (through ports under CCV_CHECK, which
// synthesis does not see).
//
// Each entry's owner, a slot (OI-73 (1), OA's revs 207 and 216): rename
// gives the slot of the lane each port's entry goes to (own_slot, from its
// Rename 1 lanes), and every head a port offers takes its port's slot at
// the edge, asked for or not. An entry no port took is free, its owner
// unread, and written again when one takes it, so no request reaches the
// owners and no free sees an owner not yet written. Each cycle's frees are counted
// by owner and group, exactly, and registered (fs); a second stage
// compresses each slot's groups to a carry-save pair (ccv_common_csa), registered
// (fsp), and rename adds the pair into each slot's held count at the next
// edge, so held sees a free three edges after the retire stage's register
// (the model's held_late 3; OI-76, OA's rev 219).
// The counts are per group of FG consecutive entries, which keeps each
// count shallow; rename sums the groups.
//
// Reset line (decision 6): the free bits reset to all free, the buffer to
// empty, the bank pointers and bank order to 0, all reset state. The reset
// input is flopped before any use (RST-1), so the state resets a cycle
// after it rises and leaves reset a cycle after it falls. The
// buffer's entries are payload guarded by the count: an entry at or past
// the count is never granted or matched.
//
// State is one register, and its next value a function of it and this
// cycle's inputs alone (CCV-L23). Local clock gating: the free bits are
// clocked on last cycle's allocation or a free's lead, the buffer side on last cycle's
// allocation or a refill, and the two-bit bank order and the registered
// request count every edge. The grant ports read a copy of the buffer and
// its count (NGD-7: the state's own paths run through the refill, deeper
// than an output's budget). The registered count serves both, its outputs
// required at 20 (OA's response OI-60: rename takes the names as data, its
// go and credits in ooe_decq).
//===----------------------------------------------------------------------===//
`include "ccv_assert.svh"
`define CCV_CLK ooe_core_clk
`define CCV_RST rst_r01h
module ooe_freelist #(
  parameter int N = 192,   // pool entries (CCV_P_PHYS_REGS rows, or CCV_P_PRED_REGS)
  parameter int A = 4,     // allocation ports (CCV_ISSUE_WIDTH)
  parameter int B = 8,     // candidate buffer entries (OI-38)
  parameter int K = 4,     // refill banks (OI-38); divides N
  parameter int S = 4,     // owners: tier-1 slots (CCV_TIER1_WARPS)
  localparam int W  = $clog2(N),
  localparam int M  = N / K,
  localparam int LM = $clog2(M),
  localparam int LB = $clog2(B + 1),
  localparam int LK = (K > 1) ? $clog2(K) : 1,
  localparam int LA = $clog2(A + 1),
  localparam int LP = (M > 1) ? $clog2(M) : 1,   // tree levels over a bank
  localparam int P  = 1 << LP,                   // a bank, padded to a power of 2
  localparam int LS = (S > 1) ? $clog2(S) : 1,
  localparam int FG = (N % 12 == 0) ? 12 : ((N % 8 == 0) ? 8 : N),   // entries a free count covers
  localparam int NF = N / FG,
  localparam int LF = $clog2(FG + 1),            // a group's frees in a cycle
  localparam int FP = 1 << $clog2(FG),           // a group, padded to a power of 2
  localparam int LT = $clog2(N + 1)              // a slot's frees in a cycle
) (
  input  logic           ooe_core_clk,
  input  logic           ooe_rst_r00h,
  input  logic [A-1:0]   alloc_req_cq01h,    // port k takes its head entry
  input  logic           free_l_cq00h,       // a free reaches free_mask next cycle (the ROB's decision)
  input  logic [N-1:0]   free_mask_cq01h,    // entries freed this cycle (the retire stage's register)
  input  logic [A*LS-1:0] own_slot_cq01h,    // the slot of the lane port k's entry goes to this cycle
  output logic [A-1:0]   alloc_v_cq02h,      // head entry k is available to port k
  output logic [A*W-1:0] alloc_idx_cq02h,    // head entry k (meaningful while available)
  output logic [LB-1:0]  avail_cq02h,        // entries allocation can take: the buffer, less those in transit
  output logic [S*2*LT-1:0] fsp_cq03h        // the frees of two cycles ago by owner, each slot's a carry-save pair (s * 2 * LT)
`ifdef CCV_CHECK
  // Read only by test/ooe/freelist_tb.cpp, which compares the whole state
  // (OA's choice for TI-20): no design port, so synthesis sees none.
  ,
  output logic [B*W-1:0] buf_cq02h,          // the buffer, head first, those in transit included
  output logic [LB-1:0]  cnt_cq02h,          // entries in the buffer
  output logic [LA-1:0]  transit_cq02h,      // last cycle's allocations: in transit at the head
  output logic [N-1:0]   free_cq02h,         // the free bits, the entries in transit still set
  output logic [K*LM-1:0] bptr_cq02h,        // each bank's pointer, within the bank
  output logic [LK-1:0]  rot_cq02h           // the bank refill starts with
`endif
);

  // The state's fields.
  localparam int OBITS = 0;
  localparam int OBUF  = OBITS + N;
  localparam int OCNT  = OBUF + B * W;
  localparam int OPTR  = OCNT + LB;
  localparam int OROT  = OPTR + K * LM;
  localparam int OIN   = OROT + LK;         // N bits: entry is in the buffer
  localparam int SW    = OIN + N;

  // The reset, flopped before any use (RST-1).
  logic rst_r01h;
  always_ff @(posedge ooe_core_clk) begin
    rst_r01h <= ooe_rst_r00h;
  end

  `CCV_ASSERT_KNOWN(alloc_req_known, alloc_req_cq01h)
  `CCV_ASSERT_KNOWN(free_mask_known, free_mask_cq01h)

  // The registered count, one-hot.
  function automatic logic [A:0] onehot(input logic [LA-1:0] n);
    onehot = '0;
    for (int q = 0; q <= A; q++) onehot[q] = 32'(n) == q;
  endfunction

  // Allocation takes the buffer's head behind the r entries in transit:
  // port k gets entry r + k. From the output copy of the buffer and its
  // count, {count, buffer}; r one-hot, a flop, so each port is a mux
  // formed beside it.
  function automatic logic [A+A*W-1:0] grants(input logic [LB+B*W-1:0] o, input logic [A:0] rq);
    logic [A-1:0]   v;
    logic [A*W-1:0] idx;
    v   = '0;
    idx = '0;
    for (int k = 0; k < A; k++)
      for (int q = 0; q <= A; q++)
        if (k + q < B && LB'(k + q) < o[B * W +: LB] && rq[q]) begin
          v[k]          = 1'b1;
          idx[k*W +: W] = idx[k*W +: W] | o[(k + q) * W +: W];
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
  // The next state. rq (one-hot, a flop): how many entries last cycle
  // took, popped from the buffer now, their free bits cleared with them.
  function automatic logic [SW-1:0] next_state(input logic [SW-1:0] st, input logic [A:0] rq,
                                               input logic [N-1:0] freed);
    logic [N-1:0]      bits, inbuf, popped, added;
    logic [M-1:0]      bank;
    logic [LM:0]       fc;
    logic [B*W-1:0]    buf_q, nbuf;
    logic [K*LM-1:0]   bptr, cand;
    logic [K-1:0]      found, ord_ok;
    logic [K*W-1:0]    ent;                // each bank's candidate entry
    logic [K*M-1:0]    oh;                 // and as a one-hot within its bank
    logic [K*LK-1:0]   ord_bank;              // the r-th found bank, in rotating order
    logic [K*LB-1:0]   rank;               // each bank's rank among the found
    logic [LB-1:0]     cnt, rem, nfound, room, cnt_nx;
    logic [A:0]        kq;                 // how many leave the buffer now, one-hot

    logic [LK-1:0]     rot, bj;
    logic [LM-1:0]     nxp;
    logic              adv;
    bits  = st[OBITS +: N];
    buf_q = st[OBUF +: B * W];
    cnt   = st[OCNT +: LB];
    bptr  = st[OPTR +: K * LM];
    rot   = st[OROT +: LK];
    inbuf = st[OIN +: N];
    // Leaving the buffer now: last cycle's take, its first q entries. Their
    // free bits clear with them.
    kq = rq;
    popped = '0;
    for (int q = 1; q <= A; q++)
      for (int i = 0; i < q && i < B; i++)
        if (kq[q] && LB'(i) < cnt) popped[buf_q[i * W +: W]] = 1'b1;
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
    // What depends on how many this cycle takes (q, one-hot in kq) is a
    // set of selects formed for each q from the state, beside the requests,
    // then ANDed with kq: the requests reach the edge through the selects
    // alone, never through a subtract, and the deep data (the banks'
    // candidates and ranks) through one mux, as before.
    nbuf    = '0;
    for (int i = 0; i < B; i++) begin
      logic [W-1:0]    keep;
      logic [K-1:0]    take;               // slot i takes the j-th candidate in rotating order
      keep = '0;
      take = '0;
      for (int q = 0; q <= A; q++) begin
        rem = cnt - LB'(q);
        if (LB'(i) < rem) begin
          if (i + q < B) keep = keep | (buf_q[(i + q) * W +: W] & {W{kq[q]}});
        end else begin
          for (int rr = 0; rr < K; rr++)
            if (LB'(i) - rem == LB'(rr)) take[rr] = take[rr] | kq[q];
        end
      end
      nbuf[i * W +: W] = keep;
      for (int rr = 0; rr < K; rr++)
        nbuf[i * W +: W] = nbuf[i * W +: W] | (ent[32'(ord_bank[rr * LK +: LK]) * W +: W] & {W{take[rr] && ord_ok[rr]}});
    end
    // A bank whose candidate went in moves its pointer past it: its rank is
    // below the room behind the entries that stay. Written as
    // an AND-OR, not a held if, so the pointers share the buffer's clock
    // gate rather than each taking its own (local clock gating).
    // The entries that stay, as a number: each count's remainder from the
    // state, picked by kq (a flop), so it is ready long before the banks'
    // ranks.
    rem = '0;
    for (int q = 0; q <= A; q++) rem = rem | ((cnt - LB'(q)) & {LB{kq[q]}});
    room  = LB'(B) - rem;
    added = '0;
    for (int bb = 0; bb < K; bb++) begin
      adv = found[bb] && rank[bb * LB +: LB] < room;   // rank < nfound already
      for (int ii = 0; ii < M; ii++) added[ii * K + bb] = adv && oh[bb * M + ii];
      nxp = (32'(cand[bb * LM +: LM]) == M - 1) ? '0 : cand[bb * LM +: LM] + LM'(1);
      bptr[bb * LM +: LM] = ({LM{adv}} & nxp) | ({LM{!adv}} & bptr[bb * LM +: LM]);
    end
    cnt_nx = (32'(rem) + 32'(nfound) > B) ? LB'(B) : rem + nfound;
    rot = (32'(rot) == K - 1) ? '0 : rot + LK'(1);
    next_state = {(inbuf & ~popped) | added, rot, bptr, cnt_nx, nbuf, (bits & ~popped) | freed};
  endfunction

  // The state; the count of last cycle's allocations, held a cycle; and a
  // copy of the buffer and its count for the ports alone (NGD-7), which
  // starts no other path. The pair is kept, or synthesis merges it back.
  // The registered count needs no copy: its paths, 19.4 NGD, are within
  // its outputs' required 20 (OA's response OI-60).
  (* keep *) logic [SW-1:0]     st_cq02h;
  (* keep *) logic [LB+B*W-1:0] out_cq02h;     // {count, buffer}
  logic [LA-1:0]                rq_cq02h;
  logic [A:0]                   rqh_cq02h;     // rq_cq02h, one-hot
  assign rqh_cq02h = onehot(rq_cq02h);
  always_comb {alloc_v_cq02h, alloc_idx_cq02h} = grants(out_cq02h, rqh_cq02h);
  assign avail_cq02h = out_cq02h[B * W +: LB] - LB'(rq_cq02h);
`ifdef CCV_CHECK
  assign buf_cq02h     = st_cq02h[OBUF +: B * W];
  assign cnt_cq02h     = st_cq02h[OCNT +: LB];
  assign transit_cq02h = rq_cq02h;
  assign free_cq02h = st_cq02h[OBITS +: N];
  assign bptr_cq02h = st_cq02h[OPTR +: K * LM];
  assign rot_cq02h  = st_cq02h[OROT +: LK];
`endif

  // Rename checks the buffer's count first, so every port that asks finds
  // its head entry available.
  `CCV_ASSERT(alloc_granted, (alloc_req_cq01h & ~alloc_v_cq02h) == '0)
  // Port k asks only if ports 0 to k-1 do, the order rename allocates in.
  `CCV_ASSERT(req_prefix, (alloc_req_cq01h & (alloc_req_cq01h + A'(1))) == '0)
  // A free names an entry that is allocated: one in transit (granted last
  // cycle, its free bit still set), or one out of the buffer. Anything else
  // free or buffered is a double free, a bug upstream. A free never names
  // an entry granted this cycle (it comes from registers), and its lead
  // came a cycle before it.
  logic [N-1:0] granted_cq02h, transit_m_cq02h;
  logic         free_en_cq01h;     // the lead's flop: a free this cycle
  always_comb begin
    granted_cq02h   = '0;
    transit_m_cq02h = '0;
    for (int k = 0; k < A; k++)
      if (alloc_req_cq01h[k] && alloc_v_cq02h[k]) granted_cq02h[alloc_idx_cq02h[k*W +: W]] = 1'b1;
    for (int i = 0; i < A && i < B; i++)
      if (LA'(i) < rq_cq02h) transit_m_cq02h[st_cq02h[OBUF + i * W +: W]] = 1'b1;
  end
  `CCV_ASSERT(no_double_free, (free_mask_cq01h & st_cq02h[OBITS +: N] & ~transit_m_cq02h) == '0)
  `CCV_ASSERT(no_free_of_grant, (free_mask_cq01h & granted_cq02h) == '0)
  `CCV_ASSERT(free_led, free_mask_cq01h == '0 || free_en_cq01h)

  // Local clock gating (docs/rtl-coding-style.md). The free bits change on
  // last cycle's allocation (rq_cq02h) or a free (its lead's flop,
  // free_en); the buffer, its count and their copy, the bank
  // pointers and the buffered set when last cycle allocated, or while the
  // buffer has room (a refill may come; whether one does is a search of the
  // pool, too deep for an enable): from the module's own flops (CG-5). The
  // bank order and the registered count are written every edge, five flops
  // with no gate, and the lead's flop.
  logic          bits_en_cq01h, buf_en_cq01h;
  logic [SW-1:0] nx_cq01h;
  logic [LA-1:0] rq_cq01h;          // how many this cycle takes: where the request prefix ends
  assign nx_cq01h      = next_state(st_cq02h, rqh_cq02h, free_mask_cq01h);
  assign bits_en_cq01h = rq_cq02h != '0 || free_en_cq01h;
  assign buf_en_cq01h  = rq_cq02h != '0 || 32'(st_cq02h[OCNT +: LB]) < B;
  always_comb begin
    rq_cq01h = '0;
    for (int q = 1; q < A + 1; q++)
      if (alloc_req_cq01h[q-1] && (q == A || !alloc_req_cq01h[q % A])) rq_cq01h = LA'(q);
  end

  always_ff @(posedge ooe_core_clk) begin
    // The reset state: all free, the buffer empty, pointers and order at 0.
    // The buffer's entries are payload.
    if (rst_r01h) begin
      st_cq02h[OBITS +: N]          <= '1;
      st_cq02h[OCNT +: LB]          <= '0;
      st_cq02h[OPTR +: K * LM + LK] <= '0;
      st_cq02h[OIN +: N]            <= '0;
      out_cq02h[B * W +: LB]        <= '0;
    end else begin
      if (bits_en_cq01h) st_cq02h[OBITS +: N] <= nx_cq01h[OBITS +: N];
      if (buf_en_cq01h) begin
        st_cq02h[OBUF +: B * W + LB + K * LM] <= nx_cq01h[OBUF +: B * W + LB + K * LM];
        st_cq02h[OIN +: N]                    <= nx_cq01h[OIN +: N];
        out_cq02h                             <= nx_cq01h[OBUF +: B * W + LB];
      end
      st_cq02h[OROT +: LK] <= nx_cq01h[OROT +: LK];
    end
  end
  always_ff @(posedge ooe_core_clk) begin
    if (rst_r01h) begin
      rq_cq02h      <= '0;
      free_en_cq01h <= 1'b0;
    end else begin
      rq_cq02h      <= rq_cq01h;
      free_en_cq01h <= free_l_cq00h;
    end
  end

  // -- Owners and the frees they count ------------------------------------------
  // Each head a port offers takes its port's slot, from the grant ports'
  // registers (the buffer's output copy, out_cq02h, and the registered take).
  logic [N*LS-1:0] own_cq02h;
  logic            own_en_cq02h;
  assign own_en_cq02h = alloc_v_cq02h != '0;
  function automatic logic [N*LS-1:0] owners_nx(input logic [N*LS-1:0] o, input logic [A-1:0] v,
                                                input logic [A*W-1:0] idx, input logic [A*LS-1:0] sl);
    logic [N*LS-1:0] x;
    x = o;
    for (int e = 0; e < N; e++)
      for (int k = 0; k < A; k++)
        if (v[k] && idx[k * W +: W] == W'(e)) x[e * LS +: LS] = sl[k * LS +: LS];
    owners_nx = x;
  endfunction
  always_ff @(posedge ooe_core_clk) begin
    if (own_en_cq02h) own_cq02h <= owners_nx(own_cq02h, alloc_v_cq02h, alloc_idx_cq02h, own_slot_cq01h);
  end
  // This cycle's frees by owner and group (FG consecutive entries), exact:
  // a balanced count of each group's freed entries a slot owns. Clocked
  // while a free comes (its lead's flop) or a count is set.
  function automatic logic [LF-1:0] count_of(input logic [FG-1:0] v);
    logic [FP*LF-1:0] t;
    t = '0;
    for (int i = 0; i < FG; i++) t[i * LF +: LF] = LF'(v[i]);
    for (int l = 1; l < FP; l = l * 2)
      for (int i = 0; i + l < FP; i = i + 2 * l) t[i * LF +: LF] = t[i * LF +: LF] + t[(i + l) * LF +: LF];
    count_of = t[LF-1:0];
  endfunction
  logic [S*NF*LF-1:0] fs_nx_cq01h;
  always_comb
    for (int s = 0; s < S; s++)
      for (int g = 0; g < NF; g++) begin
        logic [FG-1:0] v;
        for (int i = 0; i < FG; i++)
          v[i] = free_mask_cq01h[g * FG + i] && own_cq02h[(g * FG + i) * LS +: LS] == LS'(s);
        fs_nx_cq01h[(s * NF + g) * LF +: LF] = count_of(v);
      end
  // The counts hold a free's while they were loaded with one (fsv: the
  // lead's flop, a cycle on), so they clear at the next edge.
  logic [S*NF*LF-1:0] fs_cq02h;
  logic fs_en_cq01h, fsv_cq02h;
  assign fs_en_cq01h = free_en_cq01h || fsv_cq02h;
  always_ff @(posedge ooe_core_clk) begin
    if (rst_r01h) begin
      fs_cq02h  <= '0;
      fsv_cq02h <= 1'b0;
    end else begin
      fsv_cq02h <= free_en_cq01h;
      if (fs_en_cq01h) fs_cq02h <= fs_nx_cq01h;
    end
  end

  // The second stage: each slot's groups to a carry-save pair, registered
  // while the counts hold a free's (fsv) or the pair is set (fpv), so it
  // clears at the next edge.
  logic [S*2*LT-1:0] fsp_nx_cq02h;
  for (genvar s = 0; s < S; s++) begin : g_sp
    logic [NF*LT-1:0] gop_cq02h;
    for (genvar g = 0; g < NF; g++) begin : g_g
      assign gop_cq02h[g * LT +: LT] = LT'(fs_cq02h[(s * NF + g) * LF +: LF]);
    end
    logic [LT-1:0] sum_cq02h;
    ccv_common_csa #(.N(NF), .W(LT)) u_csa (.op(gop_cq02h), .sum(sum_cq02h), .pair(fsp_nx_cq02h[s * 2 * LT +: 2 * LT]));
  end
  logic fsp_en_cq02h, fpv_cq03h;
  assign fsp_en_cq02h = fsv_cq02h || fpv_cq03h;
  always_ff @(posedge ooe_core_clk) begin
    if (rst_r01h) begin
      fsp_cq03h <= '0;
      fpv_cq03h <= 1'b0;
    end else begin
      fpv_cq03h <= fsv_cq02h;
      if (fsp_en_cq02h) fsp_cq03h <= fsp_nx_cq02h;
    end
  end

endmodule
`undef CCV_CLK
`undef CCV_RST
