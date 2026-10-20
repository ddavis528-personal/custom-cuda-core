//===-- ooe_wake.sv - OOE wake timers: each producer's four wake lines --===//
//
// Spec: the design doc's Scheduler timing estimate (OA-1: "wake generation
//       is registered timers, off this path"; "a producer's timer starts
//       when it is granted and raises its wake one cycle early"), its
//       Confirmation and transitive cancel section (A-46: the L1 contract,
//       the miss as no completion at CCV_LAT_L1_CMPL), the bypass groups
//       (OI-16, DA's responses OA-4) and the reset line (OI-36 (6): wake
//       timers are payload guarded by the producer's issued flag).
//
// One timer per RS entry. Each drives the four wake lines ooe_ready reads:
// line k < 3 is the k-th distinct bypass penalty past the producer's
// fastest bypass point, and line 3 the full-latency wake, the PRF read.
// Every line is a flop: the ready stage reads it at the start of the cycle
// it holds for, so the timer decides at the edge before ("one cycle
// early"), and none of this logic is on the ready path.
//
// A grant starts the timer at age 1, the edge after the select cycle; age
// counts cycles since the grant and saturates. What the timer waits for is
// the grant's kind, decided at rename and held in the RS payload:
//   timed  a fixed-latency unit: the full-latency line at LAT[class] (every
//          class a grant names has one);
//   copy   the copy-only half of a masked load: a lane op, at LAT_COPY;
//   spec   an L1-contracted global load: the full-latency line at
//          LAT_SPEC (CCV_LAT_L1_WAKE). No completion by LAT_MISS
//          (payload stages + CCV_LAT_L1_CMPL) is the miss: the line drops,
//          miss_cq02h pulses for cancel's first hop, and the timer waits
//          for the completion;
//   mem    any other memop: waits for its completion.
// A completion for a timer that waits restarts it and raises the
// full-latency line at CMPL_DLY (CCV_LAT_L1_MISS_WAKE); a completion for a
// spec timer is the L1 hit, and ends the miss check. A stop (a replay
// returning the entry to Waiting, or the entry freed) clears issued.
//
// Completions (OA's response OI-58, L1): the channel's valid leads its
// payload by a cycle, and this module flops it (cv). The payload's RS
// indices are decoded per entry as they arrive and registered (cm), so a
// restart is taken an edge later from this module's own flop, at age 1, so the
// line rises on the model's cycle (CMPL_DLY of 1 or more). The L1 hit is
// taken from the payload as it arrives, gated by cv: a spec timer is
// clocked anyway until its miss check ends, below its age's saturation.
// No latency class waits for a done (the latency table has none), so this
// module takes no done; a timed grant with no latency is an assertion.
//
// fin_cq02h is the timer's word to confirmation: issued, the full-latency
// line raised and the miss check over, so the result can no longer be
// cancelled (V-16). It is taken before this edge's stop, because
// confirmation frees the entry in the cycle the line rises.
//
// The bypass lines follow the class alone: FAST[class] is its fastest
// bypass point (0: none), so line k rises at FAST[class] + PEN[k] while
// the timer is issued. A class that waits for a completion has no bypass
// point, so the restart at a completion never moves a bypass line.
//
// Inputs of the edge into cycle t are the previous cycle's grants and the
// events the model takes in t before its select: completions, replays
// and frees. The lines after that edge are what select reads in t.
// The reference is the model's wakeLine (Core::wakeLine) and its L1 miss
// cancel; test/ooe/wake_tb.cpp drives this module from the live model and
// compares every valid entry's lines, and every miss, each cycle.
//
// Leads for ooe_sched (OI-54): wtl_cq02h, per line, a change the timer
// makes at the next edge, and wml_cq02h, a miss pulse or a registered
// completion now. Both are registers (NGD-7: the outputs leave from flops
// of their own), wtl in each timer's enable group: its next value is the
// change at the edge after next, from the state alone (tl2), or from a
// grant or a registered restart taken at this edge, and none on a stop.
//
// Reset line (decision 6): issued resets to 0; the age, kind, class, the
// timer flags and the lines are payload, read only through issued (a line
// is never raised without it). The reset is flopped before use (RST-1).
//
// Local clock gating (OA's response OI-58; V-75): each entry's state is
// one enable group, clocked on its grant, its registered completion, and
// while it is in use, from this module's own flops: issued with its age
// not saturated (a miss pulse's too); a final flag to clear; issued and final,
// or issued and writing nothing (prod), for its free by confirmation (OA's
// response OI-62); and the registered squash's lead (sq_en: every entry,
// the edge ooe_rs frees on). A replay needs no lead of its own: it comes a
// few cycles after a producer's miss or an issue on a stale ready bit,
// never past the age's saturation (LAT_MISS - LAT_SPEC, and a cycle a
// hop, below 2**AW - 1), so the age term clocks it. An assertion holds
// every stop to a clocked entry. The grant is the one input in the enable:
// ooe_sched's third copy of its grant register, at 2 NGD: 6.1 NGD in all
// as check-cg measures it (rtl/cg-waivers.json).
//===----------------------------------------------------------------------===//
`include "ccv_assert.svh"
`define CCV_CLK ooe_core_clk
`define CCV_RST rst_r01h
module ooe_wake #(
  parameter int N  = 45,               // RS entries (CCV_P_RS_RCU + CCV_P_RS_MIU)
  parameter int AW = 5,                // age bits; every threshold is below 2**AW
  // Per latency class (8 classes, 8 bits each, class 0 lowest): the full
  // latency (CCV_LAT_RCU, CCV_LAT_LANE, -, -, CCV_LAT_SFU,
  // CCV_LAT_COLLECTIVE; 0 for a class no grant names), and the fastest bypass point
  // (CCV_LAT_LANE_BYP for the lane; 0 for none).
  parameter logic [63:0] LAT  = 64'h0000_050c_0000_0703,
  parameter logic [63:0] FAST = 64'h0000_0000_0000_0400,
  // The distinct bypass penalties, ascending, and how many there are
  // (CCV_LAT_BYP_PEN_SAME, _INT_FP, _SFU).
  parameter logic [23:0] PEN  = 24'h03_02_00,
  parameter int NPEN     = 3,
  parameter int LAT_COPY = 7,          // CCV_LAT_LANE
  parameter int LAT_SPEC = 16,         // CCV_LAT_L1_WAKE
  parameter int LAT_MISS = 19,         // payload stages + CCV_LAT_L1_CMPL
  parameter int CMPL_DLY = 1,          // CCV_LAT_L1_MISS_WAKE
  parameter int NC       = 4,          // completions a cycle (ccv_miu_ooe_cmpl's rate)
  localparam int W       = $clog2(N)
) (
  input  logic           ooe_core_clk,
  input  logic           ooe_rst_r00h,
  input  logic [N-1:0]   grant_cq01h,   // granted last cycle (ooe_sched's copy for this module)
  input  logic [2*N-1:0] kind_cq01h,    // each grant's timer kind
  input  logic [3*N-1:0] cls_cq01h,     // each grant's latency class
  input  logic [N-1:0]   prod_cq01h,    // each grant writes a register some entry may wake on
  input  logic [NC-1:0]  cmpl_l_cq00h,  // the completion channel's valid: a payload next cycle
  input  logic [NC*W-1:0] cmpl_idx_cq01h, // each completion's RS entry
  input  logic [N-1:0]   stop_cq01h,    // replayed or freed: issued clears
  input  logic           sq_l_cq00h,    // the registered squash frees next cycle
  output logic [4*N-1:0] wake_cq02h,    // entry j's line k at 4j + k
  output logic [N-1:0]   miss_cq02h,    // the L1 miss, found at the last edge
  output logic [N-1:0]   fin_cq02h,     // the result is final: confirmation may take it
  output logic [N-1:0]   iss_cq02h,     // issued: ooe_sched's, ooe_rs's and the hop's
  output logic [4*N-1:0] wtl_cq02h,     // the timer changes the line at the next edge
  output logic           wml_cq02h      // a miss or a completion changes lines at the next edge
);

  localparam logic [1:0] KTIMED = 2'd0, KCOPY = 2'd1, KSPEC = 2'd2, KMEM = 2'd3;

  // One entry's fields.
  localparam int FISS  = 0;             // issued
  localparam int FARM  = 1;             // the full-latency line has a time to rise at
  localparam int FSPEC = 2;             // the L1 miss check runs
  localparam int FCMPL = 3;             // restarted by a completion
  localparam int FMISS = 4;             // the miss pulse
  localparam int FLINE = 5;             // 4 lines
  localparam int FKIND = FLINE + 4;     // 2
  localparam int FCLS  = FKIND + 2;     // 3
  localparam int FFIN  = FCLS + 3;      // the result is final
  localparam int FPROD = FFIN + 1;      // writes a register some entry may wake on
  localparam int FAGE  = FPROD + 1;     // AW
  localparam int EW    = FAGE + AW;
  localparam int SW    = N * EW;

  // The reset, flopped before any use (RST-1).
  logic rst_r01h;
  always_ff @(posedge ooe_core_clk) begin
    rst_r01h <= ooe_rst_r00h;
  end

  `CCV_ASSERT_KNOWN(grant_known, grant_cq01h)
  `CCV_ASSERT_KNOWN(cmpl_l_known, cmpl_l_cq00h)
  `CCV_ASSERT_KNOWN(stop_known, stop_cq01h)
  `CCV_ASSERT_KNOWN(sq_l_known, sq_l_cq00h)

  // Age reaches a threshold (a constant once the class is decoded).
  function automatic logic reached(input logic [AW-1:0] age, input logic [7:0] thr);
    reached = {{(8 - AW){1'b0}}, age} >= thr;
  endfunction

  // The full-latency line's time for a kind and class; 0 when it waits.
  function automatic logic [7:0] late_time(input logic [1:0] kind, input logic [2:0] cls,
                                           input logic cmpld);
    logic [7:0] t;
    t = '0;
    if (cmpld)              t = 8'(CMPL_DLY);
    else if (kind == KCOPY) t = 8'(LAT_COPY);
    else if (kind == KSPEC) t = 8'(LAT_SPEC);
    else if (kind == KTIMED)
      for (int c = 0; c < 8; c++)
        if (cls == 3'(c)) t = LAT[c * 8 +: 8];
    late_time = t;
  endfunction

  // Bypass line k: the class's fastest point plus penalty k.
  function automatic logic byp_line(input logic [AW-1:0] age, input logic [2:0] cls, input int k);
    logic l;
    l = 1'b0;
    for (int c = 0; c < 8; c++)
      if (cls == 3'(c) && FAST[c * 8 +: 8] != 8'd0 && k < NPEN)
        l = reached(age, FAST[c * 8 +: 8] + PEN[k * 8 +: 8]);
    byp_line = l;
  endfunction

  // One entry's next state.
  // hit: a completion arriving now (the L1 hit, for a spec timer); cmpl:
  // one registered at the last edge (a restart, for a timer that waits).
  function automatic logic [EW-1:0] entry_next(input logic [EW-1:0] e, input logic grant,
                                               input logic [1:0] kind, input logic [2:0] cls,
                                               input logic prod, input logic hit, input logic cmpl,
                                               input logic stop);
    logic [EW-1:0] n;
    logic          iss, arm, spec, cmpld, late, miss, fire, pr;
    logic [1:0]    k;
    logic [2:0]    cl;
    logic [AW-1:0] age;
    n     = e;
    iss   = e[FISS];
    arm   = e[FARM];
    spec  = e[FSPEC];
    cmpld = e[FCMPL];
    late  = e[FLINE + 3];
    k     = e[FKIND +: 2];
    cl    = e[FCLS +: 3];
    pr    = e[FPROD];
    age   = e[FAGE +: AW];
    if (!(&age)) age = age + 1'b1;   // saturating
    // The grant, at the edge after its select.
    if (grant) begin
      iss   = 1'b1;
      k     = kind;
      cl    = cls;
      pr    = prod;
      cmpld = 1'b0;
      late  = 1'b0;
      spec  = kind == KSPEC;
      arm   = kind != KMEM && late_time(kind, cls, 1'b0) != 8'd0;
      age   = AW'(1);
    end
    // This cycle's completions, then the timer, then the L1 contract. A
    // restart is taken an edge after its completion, at age 1: the age it
    // would have reached.
    if (iss && hit && spec) spec = 1'b0;   // the L1 hit: the speculative wake stands
    else if (iss && cmpl && !spec && !arm) begin
      arm   = 1'b1;
      cmpld = 1'b1;
      age   = AW'(1);
    end
    fire = arm && reached(age, late_time(k, cl, cmpld));
    if (fire) late = 1'b1;
    miss = iss && spec && reached(age, 8'(LAT_MISS));
    if (miss) begin
      late = 1'b0;
      spec = 1'b0;
      arm  = 1'b0;
    end
    n[FFIN]       = iss && late && !spec;
    if (stop) iss = 1'b0;
    n[FISS]       = iss;
    n[FARM]       = arm;
    n[FSPEC]      = spec;
    n[FCMPL]      = cmpld;
    n[FMISS]      = miss && !stop;
    for (int l = 0; l < 3; l++) n[FLINE + l] = iss && byp_line(age, cl, l);
    n[FLINE + 3]  = iss && late;
    n[FKIND +: 2] = k;
    n[FCLS +: 3]  = cl;
    n[FPROD]      = pr && iss;          // read only while issued: cleared with it
    n[FAGE +: AW] = age;
    entry_next = n;
  endfunction

  // The timer's line changes at the edge after next, from its state alone,
  // with nothing arriving at either edge: the bypass lines and the
  // full-latency line, between the ages it reaches at the next edge and the
  // one after. A miss at the next edge drops the lines (an event, wml's)
  // and stops the timer.
  function automatic logic [3:0] tl2(input logic [EW-1:0] e);
    logic [AW-1:0] a1, a2;
    logic [7:0]    lt;
    logic          arm, late1, late2;
    logic [3:0]    c;
    a1    = (&e[FAGE +: AW]) ? e[FAGE +: AW] : e[FAGE +: AW] + 1'b1;
    a2    = (&a1) ? a1 : a1 + 1'b1;
    lt    = late_time(e[FKIND +: 2], e[FCLS +: 3], e[FCMPL]);
    arm   = e[FARM];
    late1 = e[FLINE + 3] || (arm && reached(a1, lt));
    late2 = late1 || (arm && reached(a2, lt));
    for (int l = 0; l < 3; l++) c[l] = byp_line(a2, e[FCLS +: 3], l) ^ byp_line(a1, e[FCLS +: 3], l);
    c[3]  = late2 ^ late1;
    tl2   = (e[FISS] && !(e[FSPEC] && reached(a1, 8'(LAT_MISS)))) ? c : 4'b0;
  endfunction


  (* keep *) logic [SW-1:0] st_cq02h;   // kept: its issued bits have a copy (iso_cq02h)
  always_comb
    for (int j = 0; j < N; j++) begin
      wake_cq02h[j * 4 +: 4] = st_cq02h[j * EW + FLINE +: 4];
      miss_cq02h[j]          = st_cq02h[j * EW + FMISS];
      fin_cq02h[j]           = st_cq02h[j * EW + FFIN];
    end
  // The issued bits leave from a copy of their own (NGD-7: the state's
  // issued bit starts paths deeper than the output's budget).
  (* keep *) logic [N-1:0] iso_cq02h;
  logic [N-1:0] is_cq02h;              // the state's, for this module's own logic
  always_comb
    for (int j = 0; j < N; j++) is_cq02h[j] = st_cq02h[j * EW + FISS];
  assign iss_cq02h = iso_cq02h;

  // Select never grants an issued entry: its issued flag masks its ready.
  `CCV_ASSERT(grant_not_issued, (grant_cq01h & is_cq02h) == '0)
  // No class waits for a done: a timed grant has a latency.
  logic undone_cq01h;
  always_comb begin
    undone_cq01h = 1'b0;
    for (int j = 0; j < N; j++)
      if (grant_cq01h[j] && kind_cq01h[j * 2 +: 2] == KTIMED && late_time(KTIMED, cls_cq01h[j * 3 +: 3], 1'b0) == 8'd0)
        undone_cq01h = 1'b1;
  end
  `CCV_ASSERT(no_done_wait, !undone_cq01h)

  // -- Completions -----------------------------------------------------------
  // The channel's valid, flopped (cv); the payload decoded per timer as
  // it arrives (hit), and registered so (cm_cq02h), cleared the edge after:
  // a timer's registered completion is one flop, straight into its enable.
  logic [NC-1:0]   cv_cq01h;
  logic [N-1:0]    hit, cm_cq02h;
  logic            cm_en;
  assign cm_en = cv_cq01h != '0 || cm_cq02h != '0;
  always_comb begin
    hit = '0;
    for (int k = 0; k < NC; k++)
      for (int j = 0; j < N; j++)
        if (cv_cq01h[k] && cmpl_idx_cq01h[k * W +: W] == W'(j)) hit[j] = 1'b1;
  end

  // -- Leads -----------------------------------------------------------------
  logic [EW*N-1:0] nx;
  logic [N-1:0]    ent_en;
  logic            sq_en_cq01h;
  // Every stop lands on a clocked entry: no stop is lost. A miss pulse
  // clears on its own: its timer is issued and below saturation.
  `CCV_ASSERT(stop_clocked, (stop_cq01h & is_cq02h & ~ent_en) == '0)
  `CCV_ASSERT(miss_clocked, (miss_cq02h & ~ent_en) == '0)
  // A completion names an issued timer (the model's check too).
  `CCV_ASSERT(cmpl_issued, (hit & ~is_cq02h) == '0)

  // The leads' next values. A grant's timer starts at age 1 (its state
  // with nothing before it); a restart at age 1 raises the full-latency
  // line at the edge after next when CMPL_DLY is 2.
  logic [4*N-1:0] wtl_nx;
  logic           wml_nx;
  always_comb begin
    wml_nx = cv_cq01h != '0;
    for (int j = 0; j < N; j++) begin
      logic [EW-1:0] g;
      g = entry_next('0, 1'b1, kind_cq01h[j * 2 +: 2], cls_cq01h[j * 3 +: 3], prod_cq01h[j], 1'b0, 1'b0, 1'b0);
      if (grant_cq01h[j])
        wtl_nx[j * 4 +: 4] = tl2({AW'(0), g[FAGE-1:0]}) & {4{!stop_cq01h[j]}};
      else
        wtl_nx[j * 4 +: 4] = (tl2(st_cq02h[j * EW +: EW]) |
                              {cm_cq02h[j] && is_cq02h[j] && !st_cq02h[j * EW + FSPEC] && !st_cq02h[j * EW + FARM] &&
                               CMPL_DLY == 2, 3'b0}) & {4{!stop_cq01h[j]}};
      wml_nx = wml_nx || (ent_en[j] && nx[j * EW + FMISS]);
    end
  end

  // Local clock gating (OA's responses OI-58, OI-62): see the header.
  always_comb
    for (int j = 0; j < N; j++) begin
      nx[j * EW +: EW] = entry_next(st_cq02h[j * EW +: EW], grant_cq01h[j], kind_cq01h[j * 2 +: 2],
                                    cls_cq01h[j * 3 +: 3], prod_cq01h[j], hit[j], cm_cq02h[j], stop_cq01h[j]);
      ent_en[j] = cm_cq02h[j] || sq_en_cq01h || (fin_cq02h[j] && !is_cq02h[j]) ||
                  (is_cq02h[j] && (fin_cq02h[j] || !st_cq02h[j * EW + FPROD] ||
                                    !(&st_cq02h[j * EW + FAGE +: AW]))) ||
                  grant_cq01h[j];
    end

  logic wml_cq01h;
  assign wml_cq02h = wml_cq01h;
  always_ff @(posedge ooe_core_clk) begin
    if (rst_r01h) begin
      cv_cq01h    <= '0;
      sq_en_cq01h <= 1'b0;
      wml_cq01h   <= 1'b0;
    end else begin
      cv_cq01h    <= cmpl_l_cq00h;
      sq_en_cq01h <= sq_l_cq00h;
      wml_cq01h   <= wml_nx;
    end
  end
  always_ff @(posedge ooe_core_clk) begin
    if (rst_r01h)   cm_cq02h <= '0;
    else if (cm_en) cm_cq02h <= hit;
  end

  for (genvar j = 0; j < N; j++) begin : g_ent
    always_ff @(posedge ooe_core_clk) begin
      // The reset state: nothing issued, no line raised, no miss. The whole
      // entry resets, its payload too, so the entry is one enable group.
      if (rst_r01h) begin
        st_cq02h[j * EW +: EW] <= '0;
        wtl_cq02h[j * 4 +: 4]  <= '0;
        iso_cq02h[j]           <= 1'b0;
      end else if (ent_en[j]) begin
        st_cq02h[j * EW +: EW] <= nx[j * EW +: EW];
        wtl_cq02h[j * 4 +: 4]  <= wtl_nx[j * 4 +: 4];
        iso_cq02h[j]           <= nx[j * EW + FISS];
      end
    end
  end

endmodule
`undef CCV_CLK
`undef CCV_RST
