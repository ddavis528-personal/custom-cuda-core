//===-- vl_decq.sv - Verilator regression guard: OI's decode queue, frozen -===//
//
// ooe_decq as OI wrote it on 2026-10-16 (rtl/ooe/ooe_decq.sv at 3be811c),
// frozen here so the guard does not move when the queue does, with its
// flop in either form: IFELSE = 0 is step(), reset folded into one
// function; IFELSE = 1 is the if/else of two function calls that Verilator
// 5.020's statement reordering miscompiled (OI, 2026-10-10: two arrivals'
// payloads dropped; -fno-reorder fixed it, Icarus and 5.052 agree).
// tools/check-vl-reorder.sh drives both from the same random stimulus and
// fails on any difference: a Verilator that miscompiles either form again
// is refused before any bench is believed.
//===----------------------------------------------------------------------===//
`include "ccv_assert.svh"
`define CCV_CLK ooe_core_clk
`define CCV_RST ooe_rst_r00h
module vl_decq #(
  parameter bit IFELSE = 0,
  parameter int S = 4,     // tier-1 slots (CCV_TIER1_WARPS)
  parameter int Q = 12,    // shared entries (CCV_P_DECQ)
  parameter int D = 12,    // uops one slot may hold (CCV_P_DECQ_WARP_MAX, at most Q)
  parameter int E = 6,     // arrivals a cycle (ccv_dec_ooe_uop's rate)
  parameter int R = 4,     // uops rename takes a cycle (CCV_ISSUE_WIDTH)
  parameter int P = 16,    // payload bits
  localparam int LS = $clog2(S),
  localparam int LD = $clog2(D),
  localparam int LC = $clog2(D + 1),
  localparam int LR = $clog2(R + 1),
  localparam int LU = $clog2(Q + 1),
  localparam int LE = $clog2(E + 1)
) (
  input  logic             ooe_core_clk,
  input  logic             ooe_rst_r00h,
  input  logic [E-1:0]     enq_v_cq01h,      // port k delivers a uop
  input  logic [E*LS-1:0]  enq_slot_cq01h,   // its slot
  input  logic [E*P-1:0]   enq_pay_cq01h,    // its payload
  input  logic [S*LR-1:0]  deq_n_cq01h,      // uops rename took from each slot
  input  logic [S-1:0]     flush_cq01h,      // a squash drops each slot's uops
  output logic [S*LC-1:0]  cnt_cq02h,        // uops each slot holds
  output logic [S*R-1:0]   head_v_cq02h,     // slot s's k-th oldest is there
  output logic [S*R*P-1:0] head_pay_cq02h,   // and its payload
  output logic [LU-1:0]    used_cq02h        // entries held: the credits out
);

  // The state's fields.
  localparam int OPAY  = 0;                 // Q payloads (un-reset)
  localparam int OOWN  = OPAY + Q * P;      // Q owners (un-reset)
  localparam int OPOS  = OOWN + Q * LS;     // Q positions (un-reset)
  localparam int OBUSY = OPOS + Q * LD;     // Q busy bits
  localparam int OCNT  = OBUSY + Q;         // S counts
  localparam int SW    = OCNT + S * LC;
  // Banks for the free-entry count.
  localparam int NB    = 4;
  localparam int NBANK = (Q + NB - 1) / NB;

  `CCV_ASSERT_KNOWN(enq_v_known, enq_v_cq01h)
  `CCV_ASSERT_KNOWN_IF(enq_slot_known, |enq_v_cq01h, enq_slot_cq01h)
  `CCV_ASSERT_KNOWN(deq_n_known, deq_n_cq01h)
  `CCV_ASSERT_KNOWN(flush_known, flush_cq01h)

  // Fields of the state.
  function automatic int cnt_of(input logic [SW-1:0] st, input int s);
    cnt_of = 32'(st[OCNT + s * LC +: LC]);
  endfunction
  function automatic int own_of(input logic [SW-1:0] st, input int e);
    own_of = 32'(st[OOWN + e * LS +: LS]);
  endfunction
  function automatic int pos_of(input logic [SW-1:0] st, input int e);
    pos_of = 32'(st[OPOS + e * LD +: LD]);
  endfunction


  // Arrivals ahead of port k in slot sl (k = E: all of the slot's).
  function automatic int ahead_in(input logic [E-1:0] ev, input logic [E*LS-1:0] es, input int k,
                                  input int sl);
    int a;
    a = 0;
    for (int j = 0; j < E; j++) if (j < k && ev[j] && 32'(es[j * LS +: LS]) == sl) a = a + 1;
    ahead_in = a;
  endfunction

  // The next state. Each intermediate is computed once, at its own width:
  // - fr[e], entry e is freed: its owner flushes, or rename took the
  //   owner's uops below its position (never more than the owner holds:
  //   deq_within_count); av[e], entry e can take an arrival;
  // - bl[e], available entries below e, as a banked prefix (a tree, not a
  //   chain); ah[k], arrivals ahead of port k.
  // Port k takes entry e when e is available with as many available
  // entries below it as there are arrivals ahead of k. Then entry by entry:
  // an arrival writes it, a free clears its busy bit, and a survivor moves
  // down by its owner's dequeues. An arrival's position is its slot's
  // survivors (none after a flush) plus the slot's arrivals ahead of it.
  function automatic logic [SW-1:0] next_state(input logic [SW-1:0] st, input logic [E-1:0] ev,
                                               input logic [E*LS-1:0] es, input logic [E*P-1:0] ep,
                                               input logic [S*LR-1:0] dn, input logic [S-1:0] fl);
    logic [SW-1:0] m;
    logic [Q-1:0]  fr, av;
    logic [LS-1:0] ow, sl;
    logic [LD-1:0] ps;
    logic [LR-1:0] dq;
    logic [LC-1:0] left, cn;
    logic [NBANK*LU-1:0] bc, bp;
    logic [Q*LU-1:0]     bl;
    logic [E*LE-1:0]     ah;
    logic [LU-1:0]       run;
    logic [LE-1:0]       aq;
    m = st;
    for (int e = 0; e < Q; e++) begin
      ow    = st[OOWN + e * LS +: LS];
      ps    = st[OPOS + e * LD +: LD];
      dq    = dn[32'(ow) * LR +: LR];
      fr[e] = st[OBUSY + e] && (fl[ow] || LC'(ps) < LC'(dq));
      av[e] = !st[OBUSY + e];   // not fr[e]: freed entries wait a cycle (OI-39)
    end
    for (int b = 0; b < NBANK; b++) begin
      bc[b * LU +: LU] = '0;
      for (int j = 0; j < NB; j++)
        if (b * NB + j < Q && av[b * NB + j]) bc[b * LU +: LU] = bc[b * LU +: LU] + LU'(1);
    end
    for (int b = 0; b < NBANK; b++) begin
      bp[b * LU +: LU] = '0;
      for (int j = 0; j < NBANK; j++)
        if (j < b) bp[b * LU +: LU] = bp[b * LU +: LU] + bc[j * LU +: LU];
    end
    for (int e = 0; e < Q; e++) begin
      run = '0;
      for (int j = 0; j < NB; j++)
        if ((e / NB) * NB + j < e && av[(e / NB) * NB + j]) run = run + LU'(1);
      bl[e * LU +: LU] = bp[(e / NB) * LU +: LU] + run;
    end
    aq = '0;
    for (int k = 0; k < E; k++) begin
      ah[k * LE +: LE] = aq;
      aq               = aq + LE'(ev[k]);
    end
    for (int e = 0; e < Q; e++) begin
      ow = st[OOWN + e * LS +: LS];
      ps = st[OPOS + e * LD +: LD];
      if (fr[e]) m[OBUSY + e] = 1'b0;
      else if (st[OBUSY + e]) m[OPOS + e * LD +: LD] = ps - LD'(dn[32'(ow) * LR +: LR]);
      for (int k = 0; k < E; k++)
        if (ev[k] && av[e] && bl[e * LU +: LU] == LU'(ah[k * LE +: LE])) begin
          sl   = es[k * LS +: LS];
          cn   = st[OCNT + 32'(sl) * LC +: LC];
          left = fl[sl] ? '0 : cn - LC'(dn[32'(sl) * LR +: LR]);
          m[OBUSY + e]           = 1'b1;
          m[OPAY + e * P +: P]   = ep[k * P +: P];
          m[OOWN + e * LS +: LS] = sl;
          m[OPOS + e * LD +: LD] = LD'(left + LC'(ahead_in(ev, es, k, 32'(sl))));
        end
    end
    for (int s = 0; s < S; s++) begin
      cn   = st[OCNT + s * LC +: LC];
      left = fl[s] ? '0 : cn - LC'(dn[s * LR +: LR]);
      m[OCNT + s * LC +: LC] = left + LC'(ahead_in(ev, es, E, s));
    end
    next_state = m;
  endfunction

  // The contracts, stated apart from the update: {rename took more than a
  // slot held, an arrival found no free entry or no room in its slot}.
  function automatic logic [1:0] faults(input logic [SW-1:0] st, input logic [E-1:0] ev,
                                        input logic [E*LS-1:0] es, input logic [S*LR-1:0] dn,
                                        input logic [S-1:0] fl);
    logic under, over;
    int   room, c, n, a;
    under = 1'b0;
    over  = 1'b0;
    room  = 0;
    for (int e = 0; e < Q; e++) room = room + (st[OBUSY + e] ? 0 : 1);
    for (int s = 0; s < S; s++) begin
      c = cnt_of(st, s);
      n = fl[s] ? c : 32'(dn[s * LR +: LR]);
      if (n > c) under = 1'b1;
      a = ahead_in(ev, es, E, s);
      if (c - n + a > D) over = 1'b1;
      room = room - a;          // freed entries are no room until the next edge
    end
    if (room < 0) over = 1'b1;
    faults = {under, over};
  endfunction

  // The reset state: busy bits and counts cleared, the rest kept.
  function automatic logic [SW-1:0] reset_of(input logic [SW-1:0] st);
    logic [SW-1:0] m;
    m = st;
    m[OBUSY +: Q + S * LC] = '0;
    reset_of = m;
  endfunction

  // One edge: reset, or the update.
  function automatic logic [SW-1:0] step(input logic [SW-1:0] st, input logic rst, input logic [E-1:0] ev,
                                         input logic [E*LS-1:0] es, input logic [E*P-1:0] ep,
                                         input logic [S*LR-1:0] dn, input logic [S-1:0] fl);
    step = rst ? reset_of(st) : next_state(st, ev, es, ep, dn, fl);
  endfunction

  logic [SW-1:0] st_cq02h;
  logic [1:0]    fault_cq02h;
  assign fault_cq02h = faults(st_cq02h, enq_v_cq01h, enq_slot_cq01h, deq_n_cq01h, flush_cq01h);

  // Rename takes no more than a slot holds; DEC sends only against credit.
  `CCV_ASSERT(deq_within_count, !fault_cq02h[1])
  `CCV_ASSERT(enq_within_credit, !fault_cq02h[0])

  // What rename sees: each slot's count and its R oldest, each the payload
  // of the busy entry the slot owns at that position.
  logic [S*R-1:0] head_found_cq02h;
  // Reset line (checked on the values below): a payload is read only through a busy entry, and every uop
  // a slot's count says it holds is one.
  `CCV_ASSERT_READ_VALID(head_reads_busy, |head_v_cq02h, head_v_cq02h == head_found_cq02h)
  always_comb begin
    head_pay_cq02h   = '0;
    head_found_cq02h = '0;
    used_cq02h       = '0;
    for (int s = 0; s < S; s++) begin
      cnt_cq02h[s * LC +: LC] = st_cq02h[OCNT + s * LC +: LC];
      for (int k = 0; k < R; k++) begin
        head_v_cq02h[s * R + k] = k < cnt_of(st_cq02h, s);
        for (int e = 0; e < Q; e++)
          if (st_cq02h[OBUSY + e] && own_of(st_cq02h, e) == s && pos_of(st_cq02h, e) == k) begin
            head_pay_cq02h[(s * R + k) * P +: P] = st_cq02h[OPAY + e * P +: P];
            head_found_cq02h[s * R + k]          = 1'b1;
          end
      end
    end
    for (int e = 0; e < Q; e++) used_cq02h = used_cq02h + LU'(st_cq02h[OBUSY + e]);
  end

  if (IFELSE) begin : g_ifelse
    always_ff @(posedge ooe_core_clk) begin
      if (ooe_rst_r00h) st_cq02h <= reset_of(st_cq02h);
      else st_cq02h <= next_state(st_cq02h, enq_v_cq01h, enq_slot_cq01h, enq_pay_cq01h, deq_n_cq01h,
                                  flush_cq01h);
    end
  end else begin : g_step
    always_ff @(posedge ooe_core_clk) begin
      st_cq02h <= step(st_cq02h, ooe_rst_r00h, enq_v_cq01h, enq_slot_cq01h, enq_pay_cq01h, deq_n_cq01h,
                       flush_cq01h);
    end
  end

endmodule
`undef CCV_CLK
`undef CCV_RST
