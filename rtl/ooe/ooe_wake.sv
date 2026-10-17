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
//   timed  a fixed-latency unit: the full-latency line at LAT[class]; a
//          class with no latency (0) waits for its done instead;
//   copy   the copy-only half of a masked load: a lane op, at LAT_COPY;
//   spec   an L1-contracted global load: the full-latency line at
//          LAT_SPEC (CCV_LAT_L1_WAKE). No completion by LAT_MISS
//          (payload stages + CCV_LAT_L1_CMPL) is the miss: the line drops,
//          miss_cq02h pulses for cancel's first hop, and the timer waits
//          for the completion;
//   mem    any other memop: waits for its completion.
// A completion for a timer that waits restarts it at age 0 and raises the
// full-latency line at CMPL_DLY (CCV_LAT_L1_MISS_WAKE); a completion for a
// spec timer is the L1 hit, and ends the miss check. A done raises the
// line of an RCU-class timer (entry < NR) that waits. A stop (a replay
// returning the entry to Waiting, or the entry freed) clears issued.
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
// events the model takes in t before its select: dones, completions,
// replays and frees. The lines after that edge are what select reads in t.
// The reference is the model's wakeLine (Core::wakeLine) and its L1 miss
// cancel; test/ooe/wake_tb.cpp drives this module from the live model and
// compares every valid entry's lines, and every miss, each cycle.
//
// Reset line (decision 6): issued resets to 0; the age, kind, class, the
// timer flags and the lines are payload, read only through issued (a line
// is never raised without it). Local clock gating: each entry's state is
// one enable group, clocked only while the entry is in use.
//===----------------------------------------------------------------------===//
`include "ccv_assert.svh"
`define CCV_CLK ooe_core_clk
`define CCV_RST ooe_rst_r00h
module ooe_wake #(
  parameter int N  = 45,               // RS entries (CCV_P_RS_RCU + CCV_P_RS_MIU)
  parameter int NR = 30,               // RCU-class entries, [0, NR): a done wakes these
  parameter int AW = 5,                // age bits; every threshold is below 2**AW
  // Per latency class (8 classes, 8 bits each, class 0 lowest): the full
  // latency (CCV_LAT_RCU, CCV_LAT_LANE, -, -, CCV_LAT_SFU,
  // CCV_LAT_COLLECTIVE; 0 waits for the done), and the fastest bypass point
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
  parameter int CMPL_DLY = 1           // CCV_LAT_L1_MISS_WAKE
) (
  input  logic           ooe_core_clk,
  input  logic           ooe_rst_r00h,
  input  logic [N-1:0]   grant_cq01h,   // granted last cycle
  input  logic [2*N-1:0] kind_cq01h,    // each grant's timer kind
  input  logic [3*N-1:0] cls_cq01h,     // each grant's latency class
  input  logic [N-1:0]   done_cq01h,    // a done for the entry's ROB entry
  input  logic [N-1:0]   cmpl_cq01h,    // a completion for the entry's ROB entry
  input  logic [N-1:0]   stop_cq01h,    // replayed or freed: issued clears
  output logic [4*N-1:0] wake_cq02h,    // entry j's line k at 4j + k
  output logic [N-1:0]   miss_cq02h,    // the L1 miss, found at the last edge
  output logic [N-1:0]   fin_cq02h      // the result is final: confirmation may take it
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
  localparam int FAGE  = FFIN + 1;      // AW
  localparam int EW    = FAGE + AW;
  localparam int SW    = N * EW;

  `CCV_ASSERT_KNOWN(grant_known, grant_cq01h)
  `CCV_ASSERT_KNOWN(done_known, done_cq01h)
  `CCV_ASSERT_KNOWN(cmpl_known, cmpl_cq01h)
  `CCV_ASSERT_KNOWN(stop_known, stop_cq01h)

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
  function automatic logic [EW-1:0] entry_next(input logic [EW-1:0] e, input logic grant,
                                               input logic [1:0] kind, input logic [2:0] cls,
                                               input logic done_ok, input logic cmpl,
                                               input logic stop);
    logic [EW-1:0] n;
    logic          iss, arm, spec, cmpld, late, miss, fire;
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
    age   = e[FAGE +: AW];
    if (!(&age)) age = age + 1'b1;   // saturating
    // The grant, at the edge after its select.
    if (grant) begin
      iss   = 1'b1;
      k     = kind;
      cl    = cls;
      cmpld = 1'b0;
      late  = 1'b0;
      spec  = kind == KSPEC;
      arm   = kind != KMEM && late_time(kind, cls, 1'b0) != 8'd0;
      age   = AW'(1);
    end
    // This cycle's completions, then the timer, then the L1 contract.
    if (iss && done_ok && !arm) late = 1'b1;
    if (iss && cmpl) begin
      if (spec) spec = 1'b0;            // the L1 hit: the speculative wake stands
      else begin
        arm   = 1'b1;
        cmpld = 1'b1;
        age   = '0;
      end
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
    n[FAGE +: AW] = age;
    entry_next = n;
  endfunction


  logic [SW-1:0] st_cq02h;
  logic [N-1:0]  iss_cq02h;
  always_comb
    for (int j = 0; j < N; j++) begin
      wake_cq02h[j * 4 +: 4] = st_cq02h[j * EW + FLINE +: 4];
      miss_cq02h[j]          = st_cq02h[j * EW + FMISS];
      fin_cq02h[j]           = st_cq02h[j * EW + FFIN];
      iss_cq02h[j]           = st_cq02h[j * EW + FISS];
    end

  // Select never grants an issued entry: its issued flag masks its ready.
  `CCV_ASSERT(grant_not_issued, (grant_cq01h & iss_cq02h) == '0)

  // Local clock gating: an entry's timer is clocked on the edge that grants
  // or stops it, and while it is issued until its age saturates; past that
  // only a done or a completion changes it. A miss pulse, and a final flag
  // left by a stop, take one more edge to clear. A free entry holds still.
  logic [N-1:0] ent_en_cq02h;
  always_comb
    for (int j = 0; j < N; j++)
      ent_en_cq02h[j] = grant_cq01h[j] || stop_cq01h[j] || miss_cq02h[j] || (fin_cq02h[j] && !iss_cq02h[j]) ||
                        (iss_cq02h[j] && (!(&st_cq02h[j * EW + FAGE +: AW]) || cmpl_cq01h[j] ||
                                          (done_cq01h[j] && j < NR)));

  for (genvar j = 0; j < N; j++) begin : g_ent
    always_ff @(posedge ooe_core_clk) begin
      // The reset state: nothing issued, no line raised, no miss. The whole
      // entry resets, its payload too, so the entry is one enable group.
      if (ooe_rst_r00h) st_cq02h[j * EW +: EW] <= '0;
      else if (ent_en_cq02h[j]) begin
        st_cq02h[j * EW +: EW] <= entry_next(st_cq02h[j * EW +: EW], grant_cq01h[j], kind_cq01h[j * 2 +: 2],
                                             cls_cq01h[j * 3 +: 3], done_cq01h[j] && j < NR, cmpl_cq01h[j],
                                             stop_cq01h[j]);
      end
    end
  end

endmodule
`undef CCV_CLK
`undef CCV_RST
