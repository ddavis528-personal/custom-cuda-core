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
// same-edge reuse, 23.1 without), which is the model's decq_late_credit. A
// flush drops every uop its slot holds; uops arriving at the same edge
// carry the new epoch and stay.
//
// Arrivals are staged (OA's response OI-107: the arrival lead spent, so the
// array loads from flops). At its edge an arrival enters its slot's count
// and the staging register, packed by rank (the arrivals ahead of its
// port), with its slot and its slot's arrivals from it on, decoded one-hot
// at the input. At the next edge it takes the available entry of its rank,
// by a rank register computed a cycle earlier on the lead: available is
// idle and not taken by the arrivals staged then, so an entry freed at an
// edge is available from the next lead (its credit returns no sooner).
// Until it takes its entry a staged arrival is an entry all the same: its
// position is its slot's count less its arrivals from it on, it holds its
// credit, and the heads' candidates read it. So the staging adds no cycle
// between DEC and rename. Small counts are saturating thermometers, whose
// sums are AND-ORs, not carry chains.
//
// The reference is the model's decode queue (Core::decodeQueue,
// Core::decqFlushed); test/ooe/decq_tb.cpp drives this module from the
// live model and compares every slot's queue after every edge.
//
// Reset line (decision 6): the busy bits, each slot's count and the staged
// valids are reset state, and the positions are reset with the busy bits
// (one gate). Each entry's payload and owner are un-reset payload, guarded
// by its busy bit, as are the staged fields by their valids and the ranks
// by the staged valids. The read-valid assertion checks that every uop
// the outputs show is a busy entry's.
//
// State is one register, and its next value a function of it and this
// cycle's inputs alone (CCV-L23, as ooe_freelist); reset rewrites only its
// reset fields. (Verilator 5.020's statement reordering miscompiled an
// earlier if/else form of this update; the gate now runs 5.052, OI-40.)
// Local clock gating (OA's response OI-58, V-75): the state is clocked in
// two gates, the payloads and owners on a placement (arrivals staged), the
// positions, busy bits and counts on a placement, an arrival, a dequeue or
// a flush; the staging and rank registers on the lead or a placement. An
// arrival is led by this module's
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
  parameter bit FL = 1,    // the credits out count an entry freed at an edge held a cycle more
                           // (the model's decq_free_lag; DA, OA's rev 327)
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
  output logic [LU-1:0]    used_cq02h,       // entries held: the credits out
  output logic [S-1:0]     arr_cq02h         // a slot took arrivals at the last edge: its heads re-form
                                             // at the next (rename's change lead, OA's rev 174)
);

  // The state's fields.
  localparam int OPAY  = 0;                 // Q payloads (un-reset)
  localparam int OOWN  = OPAY + Q * P;      // Q owners (un-reset)
  localparam int OPOS  = OOWN + Q * LS;     // Q positions (un-reset)
  localparam int OBUSY = OPOS + Q * LD;     // Q busy bits
  localparam int OCNT  = OBUSY + Q;         // S counts
  localparam int SW    = OCNT + S * LC;

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

  // Counts to E, saturating, as thermometers (bit i: at least i + 1): a
  // sum is an AND-OR, not a carry chain.
  function automatic logic [E-1:0] tadd(input logic [E-1:0] a, input logic [E-1:0] b);
    for (int k = 0; k < E; k++) begin
      tadd[k] = a[k] | b[k];
      for (int i = 0; i < k; i++) tadd[k] = tadd[k] | (a[i] & b[k - 1 - i]);
    end
  endfunction
  function automatic logic [E-1:0] tbit(input logic x);
    tbit = '0;
    tbit[0] = x;
  endfunction
  // The thermometer's value one-hot: bit v, exactly v + 1 (or v: see rank).
  function automatic logic tis(input logic [E-1:0] t, input int v);   // exactly v (0 <= v < E)
    tis = (v == 0 ? 1'b1 : t[v - 1]) && !t[v];
  endfunction

  // The arrivals packed by rank, from the inputs alone: rank r is the port
  // with r arrivals ahead of it, with its slot, payload and the slot's
  // arrivals from it on (itself and those behind it). One port at most has
  // each rank: an AND-OR, not a priority chain. Flopped (the staging
  // register), they take their entries at the next edge, from flops alone
  // (OA's response OI-107). A staged arrival's position is its slot's count
  // (which took this edge's arrivals) less its arrivals from it on.
  // {valid, slot, payload, slot one-hot, from-it-on one-hot (bit b: b + 1)} per rank
  localparam int GW = E * (1 + LS + P + S + E);
  localparam int GV = 0, GSL = E, GPY = GSL + E * LS, GSO = GPY + E * P, GBO = GSO + E * S;
  function automatic logic [GW-1:0] pack(input logic [E-1:0] ev, input logic [E*LS-1:0] es,
                                         input logic [E*P-1:0] ep);
    logic [GW-1:0] g;
    logic [LS-1:0] sl;
    logic [LE-1:0] aq;
    logic [E-1:0]  bh;
    logic          hit;
    g  = '0;
    aq = '0;
    for (int k = 0; k < E; k++) begin
      sl = es[k * LS +: LS];
      // its slot's arrivals from it on, a thermometer (a sum tree)
      bh = tbit(ev[k]);
      for (int j = k + 1; j < E; j++) bh = tadd(bh, tbit(ev[j] && es[j * LS +: LS] == sl));
      for (int r = 0; r < E; r++)
        if (r <= k) begin
          hit = ev[k] && aq == LE'(r);
          g[GV + r]             = g[GV + r] | hit;
          g[GSL + r * LS +: LS] = g[GSL + r * LS +: LS] | (sl & {LS{hit}});
          g[GPY + r * P +: P]   = g[GPY + r * P +: P] | (ep[k * P +: P] & {P{hit}});
          for (int q = 0; q < S; q++)
            g[GSO + r * S + q] = g[GSO + r * S + q] | (hit && 32'(sl) == q);
          for (int q = 0; q < E; q++)
            g[GBO + r * E + q] = g[GBO + r * E + q] | (hit && bh[q] && (q == E - 1 || !bh[(q + 1) % E]));
        end
      aq = aq + LE'(ev[k]);
    end
    pack = g;
  endfunction

  // Each entry's rank among the entries the staged arrivals may take, one-hot
  // (rq[e][r]: e has rank r; none at rank E or above, or not available),
  // registered on the arrival lead: the next edge's staged arrivals take
  // their entries by it, from flops. Available: idle now and not taken by
  // the arrivals staged now. An entry freed at this edge is available from
  // the next lead on (its credit returns no sooner).
  function automatic logic [Q*E-1:0] rank_next(input logic [SW-1:0] st, input logic [E-1:0] gv,
                                               input logic [Q*E-1:0] rq);
    logic [Q-1:0]        av;
    logic [Q*E-1:0]      bt, nt;
    for (int e = 0; e < Q; e++) av[e] = !st[OBUSY + e] && !(|(rq[e * E +: E] & gv));
    // the available entries below each, a prefix of thermometers (log depth)
    for (int e = 0; e < Q; e++) bt[e * E +: E] = e == 0 ? '0 : tbit(av[(e + Q - 1) % Q]);
    for (int d = 1; d < Q; d = 2 * d) begin
      nt = bt;
      for (int e = 0; e < Q; e++) if (e >= d) nt[e * E +: E] = tadd(bt[e * E +: E], bt[(e - d) * E +: E]);
      bt = nt;
    end
    for (int e = 0; e < Q; e++)
      for (int r = 0; r < E; r++) rank_next[e * E + r] = av[e] && tis(bt[e * E +: E], r);
  endfunction

  // The next state:
  // - fr[e], entry e is freed: its owner flushes, or rename took the
  //   owner's uops below its position (never more than the owner holds:
  //   deq_within_count);
  // - the staged arrival of rank r takes the entry of rank r (rq).
  // Then entry by entry: a staged arrival writes it, a free clears its busy
  // bit, and a survivor, staged or held, moves down by its owner's
  // dequeues. Each slot's count takes this cycle's arrivals at once (they
  // are staged, and shown, from the edge).
  function automatic logic [SW-1:0] next_state(input logic [SW-1:0] st, input logic [GW-1:0] g,
                                               input logic [Q*E-1:0] rq,
                                               input logic [E-1:0] ev, input logic [E*LS-1:0] es,
                                               input logic [S*LR-1:0] dn, input logic [S-1:0] fl);
    logic [SW-1:0]   m;
    logic [Q-1:0]    fr;
    logic [LS-1:0]   ow;
    logic [LD-1:0]   ps;
    logic [LR-1:0]   dq;
    logic [LC-1:0]   left, cn;
    logic [E*LD-1:0] gp;
    logic [E-1:0]    rk;
    m = st;
    for (int e = 0; e < Q; e++) begin
      ow    = st[OOWN + e * LS +: LS];
      ps    = st[OPOS + e * LD +: LD];
      dq    = dn[32'(ow) * LR +: LR];
      fr[e] = st[OBUSY + e] && (fl[ow] || LC'(ps) < LC'(dq));
    end
    // Each staged arrival's position less its slot's dequeues now (no
    // staged arrival's slot flushes now: an assertion).
    // (Its slot's count less the slot's dequeues, per slot, picked by the
    // staged slot one-hot.)
    for (int r = 0; r < E; r++) begin
      logic [LD-1:0] lf;
      lf = '0;
      for (int q = 0; q < S; q++)
        lf = lf | (LD'(st[OCNT + q * LC +: LC] - LC'(dn[q * LR +: LR])) & {LD{g[GSO + r * S + q]}});
      for (int b = 0; b < E; b++) if (g[GBO + r * E + b]) lf = lf - LD'(b + 1);
      gp[r * LD +: LD] = lf;
    end
    for (int e = 0; e < Q; e++) begin
      ow = st[OOWN + e * LS +: LS];
      ps = st[OPOS + e * LD +: LD];
      rk = rq[e * E +: E] & g[GV +: E];
      // A held entry keeps its fields; an idle one's are cleared, being read
      // only through busy. So no field is held through an if, and the
      // update's one enable is its clock gate's (local clock gating). An
      // entry taking an arrival is idle (rq), so its old fields are clear.
      m[OBUSY + e]           = (st[OBUSY + e] && !fr[e]) || |rk;
      m[OPAY + e * P +: P]   = st[OPAY + e * P +: P] & {P{st[OBUSY + e]}};
      m[OOWN + e * LS +: LS] = ow & {LS{st[OBUSY + e]}};
      m[OPOS + e * LD +: LD] = (ps - LD'(dn[32'(ow) * LR +: LR])) & {LD{st[OBUSY + e] && !fr[e]}};
      for (int r = 0; r < E; r++) begin
        m[OPAY + e * P +: P]   = m[OPAY + e * P +: P] | (g[GPY + r * P +: P] & {P{rk[r]}});
        m[OOWN + e * LS +: LS] = m[OOWN + e * LS +: LS] | (g[GSL + r * LS +: LS] & {LS{rk[r]}});
        m[OPOS + e * LD +: LD] = m[OPOS + e * LD +: LD] | (gp[r * LD +: LD] & {LD{rk[r]}});
      end
    end
    // Each slot's survivors plus its arrivals, picked by its arrivals'
    // count (a thermometer, from the inputs) among the sums from flops.
    for (int s = 0; s < S; s++) begin
      logic [E-1:0] na;
      cn   = st[OCNT + s * LC +: LC];
      left = fl[s] ? '0 : cn - LC'(dn[s * LR +: LR]);
      na   = '0;
      for (int k = 0; k < E; k++) na = tadd(na, tbit(ev[k] && 32'(es[k * LS +: LS]) == s));
      m[OCNT + s * LC +: LC] = left & {LC{!na[0]}};
      for (int v = 1; v <= E; v++)
        if (na[v - 1] && (v == E || !na[v % E])) m[OCNT + s * LC +: LC] = m[OCNT + s * LC +: LC] | (left + LC'(v));
    end
    next_state = m;
  endfunction

  // The contracts, stated apart from the update: {rename took more than a
  // slot held, an arrival found no free entry or no room in its slot}. The
  // staged arrivals take their entries now and this cycle's at the next
  // edge: both within the entries idle now (freed entries are no room until
  // the next edge, and DEC's credits cover both).
  function automatic logic [1:0] faults(input logic [SW-1:0] st, input logic [GW-1:0] g,
                                        input logic [E-1:0] ev,
                                        input logic [E*LS-1:0] es, input logic [S*LR-1:0] dn,
                                        input logic [S-1:0] fl);
    logic under, over;
    int   room, c, n, a;
    under = 1'b0;
    over  = 1'b0;
    room  = 0;
    for (int e = 0; e < Q; e++) room = room + (st[OBUSY + e] ? 0 : 1);
    for (int r = 0; r < E; r++) room = room - (g[GV + r] ? 1 : 0);
    for (int s = 0; s < S; s++) begin
      c = cnt_of(st, s);
      n = fl[s] ? c : 32'(dn[s * LR +: LR]);
      if (n > c) under = 1'b1;
      a = ahead_in(ev, es, E, s);
      if (c - n + a > D) over = 1'b1;
      room = room - a;
    end
    if (room < 0) over = 1'b1;
    faults = {under, over};
  endfunction

  logic [SW-1:0]   st_cq02h;
  logic [1:0]      fault_cq02h;
  // The staging register: this edge's arrivals, packed by rank, which take
  // their entries at the next edge. Until then they are entries all the
  // same: counted in their slots' counts and the credits, and read by the
  // heads' candidates.
  logic [GW-1:0]   sg_cq02h, sg_nx_cq01h;
  logic [Q*E-1:0]  rq_cq02h, rq_nx_cq01h;  // each entry's rank for the staged arrivals
  (* keep *) logic [S-1:0] fl_q_cq02h;    // a flush registered: applied at the next edge
  (* keep *) logic [S-1:0] fl_o_cq02h;    // and its copy for the outputs' mask (NGD-7)
  logic            enq_en_cq01h;          // the arrival lead's flop
  logic [S-1:0]    arr_q_cq02h;           // a slot had arrivals at the last edge: its heads re-form
  logic [S-1:0]    tkv_cq02h;             // a slot's take in transit (rename took from it at the last edge)
  logic [S*LR-1:0] tk_cq02h;              // rename's take registered: popped at the next edge
  logic [S*(R+1)-1:0] tko_cq02h;          // and one-hot (tko[s][t]: t uops)
  // The entries held, kept as state (the credits out): this edge's
  // arrivals less its frees, each slot's whole count on a flush, else its
  // take in transit. The same as the busy bits' count (an assertion).
  (* keep *) logic [LU-1:0] used_q_cq02h;   // the count, and its copy out (NGD-7)
  (* keep *) logic [LU-1:0] used_o_cq02h;
  // With FL the count takes an edge's frees an edge late: the frees,
  // summed from flops and registered (frn), come off at the next edge,
  // beside that edge's arrivals, so no slot's count is in the arrivals'
  // cycle. Both copies hold it; the count is clocked with the queue, and
  // on the edge after one that freed entries (fr_q), so their credits
  // return then.
  logic [LU-1:0]   used_l_cq01h, frn_cq02h, frn_nx_cq01h;
  logic            fr_q_cq02h, uo_en_cq01h;
  function automatic logic [LU-1:0] used_late(input logic [LU-1:0] u, input logic [E-1:0] ev,
                                              input logic [LU-1:0] fr);
    used_late = u - fr;
    for (int k = 0; k < E; k++) used_late = used_late + LU'(ev[k]);
  endfunction
  function automatic logic [LU-1:0] freed_of(input logic [SW-1:0] st, input logic [S*LR-1:0] tk,
                                             input logic [S-1:0] fl);
    freed_of = '0;
    for (int s = 0; s < S; s++)
      freed_of = freed_of + (fl[s] ? LU'(st[OCNT + s * LC +: LC]) : LU'(tk[s * LR +: LR]));
  endfunction
  assign used_l_cq01h = used_late(used_q_cq02h, enq_v_cq01h, frn_cq02h);
  assign frn_nx_cq01h = freed_of(st_cq02h, tk_cq02h, fl_q_cq02h);
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
  assign fault_cq02h = faults(st_cq02h, sg_cq02h, enq_v_cq01h, enq_slot_cq01h, tk_cq02h, fl_q_cq02h);

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
  logic deq_over_cq02h;
  always_comb begin
    deq_over_cq02h = 1'b0;
    for (int s = 0; s < S; s++)
      if (LC'(deq_n_cq01h[s * LR +: LR]) > cnt_cq02h[s * LC +: LC]) deq_over_cq02h = 1'b1;
  end
  `CCV_ASSERT(deq_within_offer, !deq_over_cq02h)

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
  // First each slot's uop at each position p < D, the entries' and the
  // staged arrivals' (one at most matches: an AND-OR), with no take on
  // their path; then candidate j is the one at tk + j, by the take in
  // transit registered one-hot (tko).
  logic [S*D*P-1:0] ap_cq02h;
  logic [S*D-1:0]   af_cq02h;
  always_comb begin
    ap_cq02h = '0;
    af_cq02h = '0;
    for (int s = 0; s < S; s++)
      for (int q = 0; q < D; q++) begin
        for (int e = 0; e < Q; e++) begin
          logic m;
          m = st_cq02h[OBUSY + e] && own_of(st_cq02h, e) == s && pos_of(st_cq02h, e) == q;
          ap_cq02h[(s * D + q) * P +: P] = ap_cq02h[(s * D + q) * P +: P] | (st_cq02h[OPAY + e * P +: P] & {P{m}});
          af_cq02h[s * D + q]            = af_cq02h[s * D + q] | m;
        end
        for (int r = 0; r < E; r++) begin
          logic m;
          // at q: its slot's count is q plus its arrivals from it on
          m = 1'b0;
          for (int b = 0; b < E; b++)
            m = m | (sg_cq02h[GBO + r * E + b] && cnt_of(st_cq02h, s) == q + b + 1);
          m = m && sg_cq02h[GV + r] && sg_cq02h[GSO + r * S + s];
          ap_cq02h[(s * D + q) * P +: P] = ap_cq02h[(s * D + q) * P +: P] | (sg_cq02h[GPY + r * P +: P] & {P{m}});
          af_cq02h[s * D + q]            = af_cq02h[s * D + q] | m;
        end
      end
  end
  always_comb begin
    cp_cq02h     = '0;
    cfound_cq02h = '0;
    for (int s = 0; s < S; s++)
      for (int j = 0; j < NCAND; j++) begin
        cv_cq02h[s * NCAND + j] = j + 32'(tk_cq02h[s * LR +: LR]) < cnt_of(st_cq02h, s);
        for (int t = 0; t < R + 1; t++)
          if (j + t < D) begin
            if (j < 2 * R) cp_cq02h[(s * NCAND + j) * P +: P] = cp_cq02h[(s * NCAND + j) * P +: P] |
                                                                 (ap_cq02h[(s * D + j + t) * P +: P] & {P{tko_cq02h[s * (R + 1) + t]}});
            else           cp_cq02h[(s * NCAND + j) * P +: PA] = cp_cq02h[(s * NCAND + j) * P +: PA] |
                                                                  (ap_cq02h[(s * D + j + t) * P +: PA] & {PA{tko_cq02h[s * (R + 1) + t]}});
            cfound_cq02h[s * NCAND + j] = cfound_cq02h[s * NCAND + j] | (af_cq02h[s * D + j + t] & tko_cq02h[s * (R + 1) + t]);
          end
      end
  end
  // c[n], n the thermometer th's count (0 to R): for R = 4 a balanced tree
  // of 2:1 selects (th[1]: n >= 2), else the one-hot AND-OR. One per width.
  function automatic logic [LC-1:0] thsel_c(input logic [(R+1)*LC-1:0] c, input logic [R-1:0] th);
    if (R == 4) begin
      thsel_c = th[1 % R] ? (th[3 % R] ? c[(4 % (R + 1)) * LC +: LC]
                                       : th[2 % R] ? c[(3 % (R + 1)) * LC +: LC] : c[(2 % (R + 1)) * LC +: LC])
                          : (th[0] ? c[(1 % (R + 1)) * LC +: LC] : c[0 +: LC]);
    end else begin
      thsel_c = '0;
      for (int t = 0; t < R + 1; t++)
        if ((t == 0 || th[(t + R - 1) % R]) && (t == R || !th[t % R])) thsel_c = thsel_c | c[t * LC +: LC];
    end
  endfunction
  function automatic logic [1-1:0] thsel_v(input logic [(R+1)*1-1:0] c, input logic [R-1:0] th);
    if (R == 4) begin
      thsel_v = th[1 % R] ? (th[3 % R] ? c[(4 % (R + 1)) * 1 +: 1]
                                       : th[2 % R] ? c[(3 % (R + 1)) * 1 +: 1] : c[(2 % (R + 1)) * 1 +: 1])
                          : (th[0] ? c[(1 % (R + 1)) * 1 +: 1] : c[0 +: 1]);
    end else begin
      thsel_v = '0;
      for (int t = 0; t < R + 1; t++)
        if ((t == 0 || th[(t + R - 1) % R]) && (t == R || !th[t % R])) thsel_v = thsel_v | c[t * 1 +: 1];
    end
  endfunction
  function automatic logic [P-1:0] thsel_p(input logic [(R+1)*P-1:0] c, input logic [R-1:0] th);
    if (R == 4) begin
      thsel_p = th[1 % R] ? (th[3 % R] ? c[(4 % (R + 1)) * P +: P]
                                       : th[2 % R] ? c[(3 % (R + 1)) * P +: P] : c[(2 % (R + 1)) * P +: P])
                          : (th[0] ? c[(1 % (R + 1)) * P +: P] : c[0 +: P]);
    end else begin
      thsel_p = '0;
      for (int t = 0; t < R + 1; t++)
        if ((t == 0 || th[(t + R - 1) % R]) && (t == R || !th[t % R])) thsel_p = thsel_p | c[t * P +: P];
    end
  endfunction
  function automatic logic [PA-1:0] thsel_a(input logic [(R+1)*PA-1:0] c, input logic [R-1:0] th);
    if (R == 4) begin
      thsel_a = th[1 % R] ? (th[3 % R] ? c[(4 % (R + 1)) * PA +: PA]
                                       : th[2 % R] ? c[(3 % (R + 1)) * PA +: PA] : c[(2 % (R + 1)) * PA +: PA])
                          : (th[0] ? c[(1 % (R + 1)) * PA +: PA] : c[0 +: PA]);
    end else begin
      thsel_a = '0;
      for (int t = 0; t < R + 1; t++)
        if ((t == 0 || th[(t + R - 1) % R]) && (t == R || !th[t % R])) thsel_a = thsel_a | c[t * PA +: PA];
    end
  endfunction
  logic [S*LC-1:0]      cnt_nx_cq01h;
  logic [S*H-1:0]       hv_nx_cq01h;
  logic [S*R*P-1:0]     hp_nx_cq01h;
  logic [S*NA*PA-1:0]   ha_nx_cq01h;
  always_comb begin
    hp_nx_cq01h = '0;
    ha_nx_cq01h = '0;
    hv_nx_cq01h = '0;
    for (int s = 0; s < S; s++) begin
      // The count less the take in transit, early; the take arriving now
      // picks which of its R + 1 values to subtract, one-hot.
      logic [LC-1:0] base;
      base = st_cq02h[OCNT + s * LC +: LC] - LC'(tk_cq02h[s * LR +: LR]);
      // The take arriving now (a thermometer) picks among R + 1 values each:
      // a balanced tree of 2:1 selects on its bits (thsel), no decode ahead
      // of it. A flushed slot shows nothing (its mask on the early side);
      // the payloads are read only through their valids, so unmasked.
      begin
        logic [(R+1)*LC-1:0] cc;
        for (int t = 0; t < R + 1; t++) cc[t * LC +: LC] = (base - LC'(t)) & {LC{!fl_q_cq02h[s]}};
        cnt_nx_cq01h[s * LC +: LC] = thsel_c(cc, deq_t_cq01h[s * R +: R]);
      end
      for (int i = 0; i < H; i++) begin
        logic [R:0] cvv;
        for (int t = 0; t < R + 1; t++) cvv[t] = cv_cq02h[s * NCAND + t + i] && !fl_q_cq02h[s];
        hv_nx_cq01h[s * H + i] = thsel_v(cvv, deq_t_cq01h[s * R +: R]);
        if (i < R) begin
          logic [(R+1)*P-1:0] cc;
          for (int t = 0; t < R + 1; t++) cc[t * P +: P] = cp_cq02h[(s * NCAND + t + i) * P +: P];
          hp_nx_cq01h[(s * R + i) * P +: P] = thsel_p(cc, deq_t_cq01h[s * R +: R]);
        end else begin
          logic [(R+1)*PA-1:0] cc;
          for (int t = 0; t < R + 1; t++) cc[t * PA +: PA] = cp_cq02h[(s * NCAND + t + i) * P +: PA];
          ha_nx_cq01h[(s * NA + i - R) * PA +: PA] = thsel_a(cc, deq_t_cq01h[s * R +: R]);
        end
      end
    end
  end
  logic [S*LC-1:0]       cnt_o_cq02h;
  logic [S*H-1:0]        hv_o_cq02h;
  logic [S*R*P-1:0]      hp_o_cq02h;
  logic [S*NA*PA-1:0]    ha_o_cq02h;
  // A slot whose flush is registered shows nothing: its uops go at the next
  // edge, and rename (ooe_go) need not block it a second cycle.
  always_comb
    for (int s = 0; s < S; s++) begin
      cnt_cq02h[s * LC +: LC]  = cnt_o_cq02h[s * LC +: LC] & {LC{~fl_o_cq02h[s]}};
      head_v_cq02h[s * H +: H] = hv_o_cq02h[s * H +: H] & {H{~fl_o_cq02h[s]}};
    end
  assign head_pay_cq02h = hp_o_cq02h;
  assign head_adm_cq02h = ha_o_cq02h;
  assign used_cq02h     = used_o_cq02h;
  assign arr_cq02h      = arr_q_cq02h;
  logic [LU-1:0] busy_n_cq02h;
  always_comb begin
    busy_n_cq02h = '0;
    for (int e = 0; e < Q; e++) busy_n_cq02h = busy_n_cq02h + LU'(st_cq02h[OBUSY + e]);
    for (int r = 0; r < E; r++) busy_n_cq02h = busy_n_cq02h + LU'(sg_cq02h[GV + r]);
  end
  `CCV_ASSERT(used_is_busy, used_q_cq02h == busy_n_cq02h + (FL ? frn_cq02h : LU'(0)))

  // Local clock gating (docs/rtl-coding-style.md): the queue changes only on
  // an arrival, its take in transit or a flush, all its own flops. The
  // output register and the take register change on rename's take (its
  // "some warp takes" bit: the waiver, V-75), a queue changed at the last
  // edge, a flush applied now, or a take in transit to clear.
  logic [S-1:0]  out_en_cq01h;            // each slot's count, valids and take
  logic [S-1:0]  pay_en_cq01h;            // and its payloads
  // A slot's arrivals change its count whether or not the candidates can
  // see them, so every arrival into the slot clocks its output groups.
  logic [S-1:0]  arr_nx_cq01h;
  assign arr_nx_cq01h = enq_s_cq01h;
  logic [SW-1:0] nx_cq01h;
  // A slot's heads change on rename's take from it (its early "may take"
  // bit: the waiver), on its arrivals at the last edge, or on its flush
  // applied now; its take in transit clears an edge after rename's take.
  always_comb
    for (int s = 0; s < S; s++)
      out_en_cq01h[s] = deq_sel_cq01h[s] || tkv_cq02h[s] || arr_q_cq02h[s] || fl_q_cq02h[s];
  always_comb
    for (int s = 0; s < S; s++)
      pay_en_cq01h[s] = deq_sel_cq01h[s] || arr_q_cq02h[s] || fl_q_cq02h[s];
  assign nx_cq01h      = next_state(st_cq02h, sg_cq02h, rq_cq02h, enq_v_cq01h, enq_slot_cq01h, tk_cq02h,
                                    fl_q_cq02h);
  assign sg_nx_cq01h   = pack(enq_v_cq01h, enq_slot_cq01h, enq_pay_cq01h);
  assign rq_nx_cq01h   = rank_next(st_cq02h, sg_cq02h[GV +: E], rq_cq02h);
  always_ff @(posedge ooe_core_clk) begin
    if (rst_r01h) begin
      fl_q_cq02h   <= '0;
      fl_o_cq02h   <= '0;
      enq_en_cq01h <= 1'b0;
      arr_q_cq02h  <= '0;
      tkv_cq02h    <= '0;
    end else begin
      fl_q_cq02h   <= flush_cq01h;
      fl_o_cq02h   <= flush_cq01h;
      enq_en_cq01h <= enq_l_cq00h;
      arr_q_cq02h  <= arr_nx_cq01h;
      tkv_cq02h    <= deq_s_cq01h;
    end
  end

  for (genvar s = 0; s < S; s++) begin : g_out
    always_ff @(posedge ooe_core_clk) begin
      if (rst_r01h) begin
        tk_cq02h[s * LR +: LR]    <= '0;
        tko_cq02h[s * (R + 1) +: R + 1] <= (R + 1)'(1);
        cnt_o_cq02h[s * LC +: LC] <= '0;
        hv_o_cq02h[s * H +: H]    <= '0;
      end else if (out_en_cq01h[s]) begin
        tk_cq02h[s * LR +: LR]    <= deq_n_cq01h[s * LR +: LR];
        tko_cq02h[s * (R + 1) +: R + 1] <= deq_k_cq01h[s * (R + 1) +: R + 1];
        cnt_o_cq02h[s * LC +: LC] <= cnt_nx_cq01h[s * LC +: LC];
        hv_o_cq02h[s * H +: H]    <= hv_nx_cq01h[s * H +: H];
      end
    end
    // The payloads: read only through their valids, so un-reset.
    always_ff @(posedge ooe_core_clk)
      if (pay_en_cq01h[s]) begin
        hp_o_cq02h[s * R * P +: R * P]                <= hp_nx_cq01h[s * R * P +: R * P];
        ha_o_cq02h[s * NA * PA +: NA * PA] <= ha_nx_cq01h[s * NA * PA +: NA * PA];
      end
  end

  // The state under its own enable (its events: arrivals, a take in
  // transit, a flush); the credit count, its copy out and the frees in
  // their own gate, which with the free lag clocks the edge after a free
  // too (fr_q), when the count takes it. fr_q and frn under it as well:
  // when it is low, so are they and their inputs.
  // The state in two gates, by what changes each: the payloads and owners
  // on a placement (staged arrivals, sgv); the positions, busy bits and
  // counts on a placement, an arrival, a take in transit (its frees, and
  // the survivors move down) or a flush.
  logic pl_en_cq01h, pb_en_cq01h;
  assign pl_en_cq01h = sgv_cq02h;
  assign pb_en_cq01h = sgv_cq02h || enq_en_cq01h || |tkv_cq02h || |fl_q_cq02h;
  assign uo_en_cq01h = enq_en_cq01h || |tkv_cq02h || |fl_q_cq02h || (FL && fr_q_cq02h);
  // The staging register and the ranks: on the arrival lead, or to clear
  // the staged arrivals (sgv: some arrival staged). The ranks are read only
  // when arrivals are staged, the edge after one on the lead; the staged
  // fields only through their valids.
  logic sgv_cq02h, sg_en_cq01h;
  assign sg_en_cq01h = enq_en_cq01h || sgv_cq02h;
  always_ff @(posedge ooe_core_clk) begin
    if (rst_r01h) begin
      sg_cq02h[GV +: E] <= '0;
      sgv_cq02h         <= 1'b0;
    end else if (sg_en_cq01h) begin
      sg_cq02h[GV +: E] <= sg_nx_cq01h[GV +: E];
      sgv_cq02h         <= |enq_v_cq01h;
    end
  end
  always_ff @(posedge ooe_core_clk)
    if (sg_en_cq01h) begin
      sg_cq02h[GW-1:GSL] <= sg_nx_cq01h[GW-1:GSL];
      rq_cq02h           <= rq_nx_cq01h;
    end
  // Every staged arrival finds its entry (DEC's credits cover it).
  logic [E-1:0] rq_any_cq02h;
  always_comb begin
    rq_any_cq02h = '0;
    for (int e = 0; e < Q; e++) rq_any_cq02h = rq_any_cq02h | rq_cq02h[e * E +: E];
  end
  `CCV_ASSERT(staged_finds_entry, (sg_cq02h[GV +: E] & ~rq_any_cq02h) == '0)
  // No staged arrival's slot flushes as it takes its entry: it arrived in
  // its flush's cycle (no_enq_at_flush).
  logic [S-1:0] sg_s_cq02h;
  always_comb begin
    sg_s_cq02h = '0;
    for (int r = 0; r < E; r++) if (sg_cq02h[GV + r]) sg_s_cq02h[sg_cq02h[GSL + r * LS +: LS]] = 1'b1;
  end
  `CCV_ASSERT(no_staged_flush, (sg_s_cq02h & fl_q_cq02h) == '0)
  // The reset state: busy bits and counts cleared, and the positions with
  // them (one gate); the payloads and owners are payload, guarded by busy.
  always_ff @(posedge ooe_core_clk)
    if (pl_en_cq01h) st_cq02h[OPOS-1:0] <= nx_cq01h[OPOS-1:0];
  always_ff @(posedge ooe_core_clk) begin
    if (rst_r01h) st_cq02h[SW-1:OPOS] <= '0;
    else if (pb_en_cq01h) st_cq02h[SW-1:OPOS] <= nx_cq01h[SW-1:OPOS];
  end
  always_ff @(posedge ooe_core_clk) begin
    if (rst_r01h) begin
      used_q_cq02h <= '0;
      used_o_cq02h <= '0;
      frn_cq02h    <= '0;
      fr_q_cq02h   <= 1'b0;
    end else if (uo_en_cq01h) begin
      used_q_cq02h <= FL ? used_l_cq01h : used_nx_cq01h;
      used_o_cq02h <= FL ? used_l_cq01h : used_nx_cq01h;
      frn_cq02h    <= FL ? frn_nx_cq01h : '0;
      fr_q_cq02h   <= |tkv_cq02h || |fl_q_cq02h;
    end
  end

endmodule
`undef CCV_CLK
`undef CCV_RST
