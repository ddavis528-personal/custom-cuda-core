//===-- ooe_decq.sv - OOE decode queue: per-warp FIFOs, one shared pool ===//
//
// Spec: docs/ooe-rtl-plan.md, decision 3 (DA's response OI-36): per-warp
//       decode FIFOs on a shared 12-entry credit pool, the same behaviour as
//       the model's shared queue, except that a freed entry is held for that
//       cycle's arrivals (DA's response OI-39); decision 6 for the reset line.
//
// The uops wait here between DEC (ccv_dec_ooe_uop, up to E a cycle) and
// rename, which takes each warp's oldest in order, up to R a cycle from one
// warp. Q entries are shared by every warp. Each holds a payload, a busy
// bit, its owner (a tier-1 slot) and its position in the owner's FIFO, 0
// the oldest. A slot's FIFO is its entries in position order, up to D of
// them, so one warp may hold the whole pool, as in the model.
//
// Positions, not pointers, keep the edge shallow. A dequeue of n uops frees
// the owner's entries below position n, and the rest move down by n; an
// arrival takes the position after its slot's survivors and the slot's
// arrivals ahead of it. Rename reads slot s's k-th oldest as the entry
// owned by s at position k. Nothing compacts and nothing is searched in
// series.
//
// One clock edge: rename's dequeues and a squash's flushes free their
// entries, and the cycle's arrivals take entries that were already idle, in
// port order (port 0 first). An entry freed at an edge takes no arrival
// until the next (DA's response OI-39, decided by depth: 31.9 NGD with
// same-edge reuse, 23.1 without), which is the model's decq_late_credit. An
// arrival takes the idle entry with as many idle entries below it as there
// are arrivals ahead of its port. A flush drops every uop its slot holds;
// uops arriving at the same edge carry the new epoch and stay.
//
// The reference is the model's decode queue (Core::decodeQueue,
// Core::decqFlushed); test/ooe/decq_tb.cpp drives this module from the
// live model and compares every slot's queue after every edge.
//
// Reset line (decision 6): the busy bits and each slot's count are reset
// state. Each entry's payload, owner and position are un-reset payload,
// guarded by its busy bit. The read-valid assertion checks that every uop
// the outputs show is a busy entry's.
//
// State is one register, and its next value a function of it and this
// cycle's inputs alone (CCV-L23, as ooe_freelist); reset rewrites only its
// reset fields. (Verilator 5.020's statement reordering miscompiled an
// earlier if/else form of this update; the gate now runs 5.052, OI-40.)
// Local clock gating (OA's response OI-58, V-75): the register is clocked
// on an arrival, a dequeue or a flush. An arrival is led by this module's
// flop of DEC's channel valid (enq_l, L1); a flush is registered per slot
// and applied an edge late (L4: fl_q), rename taking nothing from the slot
// meanwhile (rename's rule, from its own copy of the registered squash: the
// count and heads still show the old uops, and an assertion holds rename to
// it); its entries' credits return that edge later. No uop arrives for a slot in its flush's cycle (an
// assertion; the model's check too), so the late flush drops nothing new.
// Rename's take is registered (tk, OA-21, OA's response OI-58 V-75) and
// popped at the next edge, so the queue is clocked on its own flops
// alone; the take register is enabled by rename's "some warp takes" bit,
// under its CG-5 waiver (about 5 NGD). Meanwhile the taken uops hold their
// entries and credits (the model's decq_take_late), and rename's outputs
// read past them: each slot's count less its take in transit, and its
// heads from that offset. The reset is flopped (RST-1).
//===----------------------------------------------------------------------===//
`include "ccv_assert.svh"
`define CCV_CLK ooe_core_clk
`define CCV_RST rst_r01h
module ooe_decq #(
  parameter int S = 4,     // tier-1 slots (CCV_TIER1_WARPS)
  parameter int Q = 12,    // shared entries (CCV_P_DECQ)
  parameter int D = 12,    // uops one slot may hold (CCV_P_DECQ_WARP_MAX, at most Q)
  parameter int E = 6,     // arrivals a cycle (ccv_dec_ooe_uop's rate)
  parameter int R = 4,     // uops rename takes a cycle (CCV_ISSUE_WIDTH)
  parameter int P = 16,    // payload bits
  parameter int PA = 6,    // the payload's low bits rename's fits read (its admission bits)
  localparam int LS = $clog2(S),
  localparam int LD = $clog2(D),
  localparam int LC = $clog2(D + 1),
  localparam int LR = $clog2(R + 1),
  localparam int LU = $clog2(Q + 1),
  localparam int LE = $clog2(E + 1),
  localparam int H  = 2 * R - 1,  // heads shown per slot: rename's fits read up to 2R - 1
  localparam int NA = H - R,      // heads past the payloads: admission bits only
  localparam int NCAND = 3 * R - 1
) (
  input  logic             ooe_core_clk,
  input  logic             ooe_rst_r00h,
  input  logic             enq_l_cq00h,      // DEC's channel valid: uops arrive next cycle
  input  logic [E-1:0]     enq_v_cq01h,      // port k delivers a uop
  input  logic [E*LS-1:0]  enq_slot_cq01h,   // its slot
  input  logic [E*P-1:0]   enq_pay_cq01h,    // its payload
  input  logic [S*R-1:0]   deq_t_cq01h,      // uops rename took from each slot, a thermometer (bit r: its r-th)
  input  logic [S-1:0]     deq_sel_cq01h,    // rename may take from slot s (a superset, early: each output group's enable)
  input  logic [S-1:0]     flush_cq01h,      // a squash drops each slot's uops
  output logic [S*LC-1:0]  cnt_cq02h,        // uops each slot offers rename, past its latest take
  output logic [S*H-1:0]   head_v_cq02h,     // slot s's k-th offered uop is there (k < 2R - 1)
  output logic [S*R*P-1:0] head_pay_cq02h,   // the first R's payloads
  output logic [S*NA*PA-1:0] head_adm_cq02h, // the rest's admission bits
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

  // The reset, flopped before any use (RST-1).
  logic rst_r01h;
  always_ff @(posedge ooe_core_clk) begin
    rst_r01h <= ooe_rst_r00h;
  end

  `CCV_ASSERT_KNOWN(enq_v_known, enq_v_cq01h)
  `CCV_ASSERT_KNOWN(enq_l_known, enq_l_cq00h)
  `CCV_ASSERT_KNOWN_IF(enq_slot_known, |enq_v_cq01h, enq_slot_cq01h)
  `CCV_ASSERT_KNOWN(deq_t_known, deq_t_cq01h)
  `CCV_ASSERT_KNOWN(deq_sel_known, deq_sel_cq01h)
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
        if (b * NB + j < Q)   // a short last bank: no select past av's end, even unevaluated
          if (av[b * NB + j]) bc[b * LU +: LU] = bc[b * LU +: LU] + LU'(1);
    end
    for (int b = 0; b < NBANK; b++) begin
      bp[b * LU +: LU] = '0;
      for (int j = 0; j < NBANK; j++)
        if (j < b) bp[b * LU +: LU] = bp[b * LU +: LU] + bc[j * LU +: LU];
    end
    for (int e = 0; e < Q; e++) begin
      run = '0;
      for (int j = 0; j < NB; j++)
        if ((e / NB) * NB + j < e)   // below e, so inside av
          if (av[(e / NB) * NB + j]) run = run + LU'(1);
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
      // A held entry keeps its fields; an idle one's are cleared, being read
      // only through busy. So no field is held through an if, and the
      // update's one enable is its clock gate's (local clock gating).
      m[OBUSY + e]           = st[OBUSY + e] && !fr[e];
      m[OPAY + e * P +: P]   = st[OPAY + e * P +: P] & {P{st[OBUSY + e]}};
      m[OOWN + e * LS +: LS] = ow & {LS{st[OBUSY + e]}};
      m[OPOS + e * LD +: LD] = (ps - LD'(dn[32'(ow) * LR +: LR])) & {LD{m[OBUSY + e]}};
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

  logic [SW-1:0]   st_cq02h;
  logic [1:0]      fault_cq02h;
  logic [S-1:0]    fl_q_cq02h;            // a flush registered: applied at the next edge
  logic            enq_en_cq01h;          // the arrival lead's flop
  logic [S-1:0]    arr_q_cq02h;           // a slot had arrivals at the last edge: its heads re-form
  logic [S-1:0]    tkv_cq02h;             // a slot's take in transit (rename took from it at the last edge)
  logic [S*LR-1:0] tk_cq02h;              // rename's take registered: popped at the next edge
  // The entries held, kept as state (the credits out): this edge's
  // arrivals less its frees, each slot's whole count on a flush, else its
  // take in transit. The same as the busy bits' count (an assertion).
  (* keep *) logic [LU-1:0] used_q_cq02h;   // the count, and its copy out (NGD-7)
  (* keep *) logic [LU-1:0] used_o_cq02h;
  // The count's next value, written as the queue's own (next_state): the
  // state it reads is this edge's, as the queue's is.
  function automatic logic [LU-1:0] used_next(input logic [LU-1:0] u, input logic [E-1:0] ev,
                                              input logic [SW-1:0] st, input logic [S*LR-1:0] tk,
                                              input logic [S-1:0] fl);
    used_next = u;
    for (int k = 0; k < E; k++) used_next = used_next + LU'(ev[k]);
    for (int s = 0; s < S; s++)
      used_next = used_next - (fl[s] ? LU'(st[OCNT + s * LC +: LC]) : LU'(tk[s * LR +: LR]));
  endfunction
  logic [LU-1:0]   used_nx_cq01h;
  assign used_nx_cq01h = used_next(used_q_cq02h, enq_v_cq01h, st_cq02h, tk_cq02h, fl_q_cq02h);
  assign fault_cq02h = faults(st_cq02h, enq_v_cq01h, enq_slot_cq01h, tk_cq02h, fl_q_cq02h);

  // Every arrival was led; none arrives for a slot whose flush comes now;
  // rename takes nothing from a slot whose flush is registered.
  logic [S-1:0] enq_s_cq01h;
  always_comb begin
    enq_s_cq01h = '0;
    for (int k = 0; k < E; k++) if (enq_v_cq01h[k]) enq_s_cq01h[enq_slot_cq01h[k * LS +: LS]] = 1'b1;
  end
  // Rename's take per slot: whether it takes, how many (the thermometer's
  // length) and that count one-hot (deq_k[s][t]: t uops).
  logic [S-1:0]       deq_s_cq01h;
  logic [S*LR-1:0]    deq_n_cq01h;
  logic [S*(R+1)-1:0] deq_k_cq01h;
  logic               deq_th_cq01h;      // each take a thermometer
  always_comb begin
    deq_th_cq01h = 1'b1;
    for (int s = 0; s < S; s++) begin
      deq_s_cq01h[s] = deq_t_cq01h[s * R];
      deq_n_cq01h[s * LR +: LR] = '0;
      for (int t = 0; t < R + 1; t++) begin
        deq_k_cq01h[s * (R + 1) + t] = 1'b1;
        // (Indices taken mod R: each is read only where the guard holds.)
        if (t > 0) deq_k_cq01h[s * (R + 1) + t] = deq_k_cq01h[s * (R + 1) + t] & deq_t_cq01h[s * R + (t + R - 1) % R];
        if (t < R) deq_k_cq01h[s * (R + 1) + t] = deq_k_cq01h[s * (R + 1) + t] & ~deq_t_cq01h[s * R + t % R];
        if (t > 0 && deq_t_cq01h[s * R + (t + R - 1) % R]) deq_n_cq01h[s * LR +: LR] = LR'(t);
        if (t > 0 && t < R && deq_t_cq01h[s * R + t % R] && !deq_t_cq01h[s * R + (t + R - 1) % R]) deq_th_cq01h = 1'b0;
      end
    end
  end
  `CCV_ASSERT(deq_thermometer, deq_th_cq01h)
  `CCV_ASSERT(enq_led, enq_v_cq01h == '0 || enq_en_cq01h)
  `CCV_ASSERT(no_enq_at_flush, (enq_s_cq01h & flush_cq01h) == '0)
  `CCV_ASSERT(no_deq_while_flushing, (deq_s_cq01h & fl_q_cq02h) == '0)
  // rename's "may take" bits cover its takes (OA's response OI-65: a
  // superset, from rename's flops).
  `CCV_ASSERT(deq_sel_covers, (deq_s_cq01h & ~deq_sel_cq01h) == '0)
  // Rename takes no more than a slot offers.
  logic deq_over_cq01h;
  always_comb begin
    deq_over_cq01h = 1'b0;
    for (int s = 0; s < S; s++)
      if (LC'(deq_n_cq01h[s * LR +: LR]) > cnt_cq02h[s * LC +: LC]) deq_over_cq01h = 1'b1;
  end
  `CCV_ASSERT(deq_within_offer, !deq_over_cq01h)

  // Rename takes no more than a slot holds; DEC sends only against credit.
  `CCV_ASSERT(deq_within_count, !fault_cq02h[1])
  `CCV_ASSERT(enq_within_credit, !fault_cq02h[0])

  // What rename sees (OA's response OI-65): an output register per slot,
  // the heads past rename's latest take. Its next value is a 5:1 mux by
  // the take arriving now (rename's count, late) over candidates formed
  // early from the entry array past the take in transit (no take on their
  // path): candidate j is the slot's uop at position tk + j. Payloads to
  // position 2R - 1, admission bits (the payload's low PA) to 3R - 2, for
  // the fits' offsets. Uops arriving at this edge show from the next (the
  // model's take_young 0); a slot whose flush applies now shows none.
  logic [S*NCAND-1:0]   cv_cq02h;         // candidate j is there
  logic [S*NCAND*P-1:0] cp_cq02h;         // and its payload
  logic [S*NCAND-1:0]   cfound_cq02h;
  `CCV_ASSERT_READ_VALID(cand_reads_busy, |cv_cq02h, cv_cq02h == cfound_cq02h)
  always_comb begin
    cp_cq02h     = '0;
    cfound_cq02h = '0;
    for (int s = 0; s < S; s++)
      for (int j = 0; j < NCAND; j++) begin
        cv_cq02h[s * NCAND + j] = j + 32'(tk_cq02h[s * LR +: LR]) < cnt_of(st_cq02h, s);
        // One entry at most matches: an AND-OR, not a priority chain.
        for (int e = 0; e < Q; e++) begin
          logic m;
          m = st_cq02h[OBUSY + e] && own_of(st_cq02h, e) == s &&
              pos_of(st_cq02h, e) == j + 32'(tk_cq02h[s * LR +: LR]);
          if (j < 2 * R) cp_cq02h[(s * NCAND + j) * P +: P] = cp_cq02h[(s * NCAND + j) * P +: P] |
                                                               (st_cq02h[OPAY + e * P +: P] & {P{m}});
          else           cp_cq02h[(s * NCAND + j) * P +: PA] = cp_cq02h[(s * NCAND + j) * P +: PA] |
                                                                (st_cq02h[OPAY + e * P +: PA] & {PA{m}});
          cfound_cq02h[s * NCAND + j] = cfound_cq02h[s * NCAND + j] | m;
        end
      end
  end
  logic [S*LC-1:0]      cnt_nx;
  logic [S*H-1:0]       hv_nx;
  logic [S*R*P-1:0]     hp_nx;
  logic [S*NA*PA-1:0]   ha_nx;
  always_comb begin
    hp_nx = '0;
    ha_nx = '0;
    hv_nx = '0;
    for (int s = 0; s < S; s++) begin
      // The count less the take in transit, early; the take arriving now
      // picks which of its R + 1 values to subtract, one-hot.
      logic [LC-1:0] base;
      base = st_cq02h[OCNT + s * LC +: LC] - LC'(tk_cq02h[s * LR +: LR]);
      cnt_nx[s * LC +: LC] = '0;
      for (int t = 0; t < R + 1; t++)
        if (deq_k_cq01h[s * (R + 1) + t] && !fl_q_cq02h[s]) cnt_nx[s * LC +: LC] = cnt_nx[s * LC +: LC] | (base - LC'(t));
      for (int t = 0; t < R + 1; t++)
        if (deq_k_cq01h[s * (R + 1) + t] && !fl_q_cq02h[s])
          for (int i = 0; i < H; i++) begin
            hv_nx[s * H + i] = cv_cq02h[s * NCAND + t + i];
            if (i < R) hp_nx[(s * R + i) * P +: P] = cp_cq02h[(s * NCAND + t + i) * P +: P];
            else       ha_nx[(s * NA + i - R) * PA +: PA] = cp_cq02h[(s * NCAND + t + i) * P +: PA];
          end
    end
  end
  logic [S*LC-1:0]       cnt_o_cq02h;
  logic [S*H-1:0]        hv_o_cq02h;
  logic [S*R*P-1:0]      hp_o_cq02h;
  logic [S*NA*PA-1:0]    ha_o_cq02h;
  assign cnt_cq02h      = cnt_o_cq02h;
  assign head_v_cq02h   = hv_o_cq02h;
  assign head_pay_cq02h = hp_o_cq02h;
  assign head_adm_cq02h = ha_o_cq02h;
  assign used_cq02h     = used_o_cq02h;
  logic [LU-1:0] busy_n_cq02h;
  always_comb begin
    busy_n_cq02h = '0;
    for (int e = 0; e < Q; e++) busy_n_cq02h = busy_n_cq02h + LU'(st_cq02h[OBUSY + e]);
  end
  `CCV_ASSERT(used_is_busy, used_q_cq02h == busy_n_cq02h)

  // Local clock gating (docs/rtl-coding-style.md): the queue changes only on
  // an arrival, its take in transit or a flush, all its own flops. The
  // output register and the take register change on rename's take (its
  // "some warp takes" bit: the waiver, V-75), a queue changed at the last
  // edge, a flush applied now, or a take in transit to clear.
  logic          decq_en_cq01h;
  logic [S-1:0]  out_en;            // each slot's count, valids and take
  logic [S-1:0]  pay_en;            // and its payloads
  // A slot's arrivals change its count whether or not the candidates can
  // see them, so every arrival into the slot clocks its output groups.
  logic [S-1:0]  arr_nx_cq01h;
  assign arr_nx_cq01h = enq_s_cq01h;
  logic [SW-1:0] nx_cq01h;
  assign decq_en_cq01h = enq_en_cq01h || |tkv_cq02h || |fl_q_cq02h;
  // A slot's heads change on rename's take from it (its early "may take"
  // bit: the waiver), on its arrivals at the last edge, or on its flush
  // applied now; its take in transit clears an edge after rename's take.
  always_comb
    for (int s = 0; s < S; s++)
      out_en[s] = deq_sel_cq01h[s] || tkv_cq02h[s] || arr_q_cq02h[s] || fl_q_cq02h[s];
  always_comb
    for (int s = 0; s < S; s++)
      pay_en[s] = deq_sel_cq01h[s] || arr_q_cq02h[s] || fl_q_cq02h[s];
  assign nx_cq01h      = next_state(st_cq02h, enq_v_cq01h, enq_slot_cq01h, enq_pay_cq01h, tk_cq02h,
                                    fl_q_cq02h);
  always_ff @(posedge ooe_core_clk) begin
    if (rst_r01h) begin
      fl_q_cq02h   <= '0;
      enq_en_cq01h <= 1'b0;
      arr_q_cq02h  <= '0;
      tkv_cq02h    <= '0;
    end else begin
      fl_q_cq02h   <= flush_cq01h;
      enq_en_cq01h <= enq_l_cq00h;
      arr_q_cq02h  <= arr_nx_cq01h;
      tkv_cq02h    <= deq_s_cq01h;
    end
  end

  for (genvar s = 0; s < S; s++) begin : g_out
    always_ff @(posedge ooe_core_clk) begin
      if (rst_r01h) begin
        tk_cq02h[s * LR +: LR]    <= '0;
        cnt_o_cq02h[s * LC +: LC] <= '0;
        hv_o_cq02h[s * H +: H]    <= '0;
      end else if (out_en[s]) begin
        tk_cq02h[s * LR +: LR]    <= deq_n_cq01h[s * LR +: LR];
        cnt_o_cq02h[s * LC +: LC] <= cnt_nx[s * LC +: LC];
        hv_o_cq02h[s * H +: H]    <= hv_nx[s * H +: H];
      end
    end
    // The payloads: read only through their valids, so un-reset.
    always_ff @(posedge ooe_core_clk)
      if (pay_en[s]) begin
        hp_o_cq02h[s * R * P +: R * P]                <= hp_nx[s * R * P +: R * P];
        ha_o_cq02h[s * NA * PA +: NA * PA] <= ha_nx[s * NA * PA +: NA * PA];
      end
  end

  always_ff @(posedge ooe_core_clk) begin
    // The reset state: busy bits and counts cleared; the payloads, owners
    // and positions are payload, guarded by busy.
    if (rst_r01h) begin
      st_cq02h[OBUSY +: Q + S * LC] <= '0;
      used_q_cq02h                  <= '0;
      used_o_cq02h                  <= '0;
    end else if (decq_en_cq01h) begin
      st_cq02h     <= nx_cq01h;
      used_q_cq02h <= used_nx_cq01h;
      used_o_cq02h <= used_nx_cq01h;
    end
  end

endmodule
`undef CCV_CLK
`undef CCV_RST
