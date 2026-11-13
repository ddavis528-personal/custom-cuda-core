//===-- rcu_kill.sv - RCU kill drain and ack, done wake, idle, credits ----===//
//
// Spec: docs/design-snapshots/rcu-arch-done-kill-reset.md (live: CCV RCU
//       Architecture, Done, kill and reset tab: Kill, Wakes RCU sends,
//       Credits RCU returns, CSRs, Block clock gate);
//       docs/design-snapshots/rcu-arch-partition.md (rcu_kill's row).
//
// Kill. kill_valid comes a cycle ahead of kill_epoch (and the mask, which
// is rcu_mig's): kill_v_q is set in K. It is ccv_rcu's kill detector, a flop
// on the ungated clock (RA rev 127, AR 336): the block's gate opens on a
// wake only from the edge after next, so a kill landing while RCU sleeps
// would miss a kill_v_q on the gated clock; the epoch and the mask, in K,
// meet the first edge the wake opens. RCU's pipe carries no warp id, so it
// drains everything: at K's edge kill_drain is loaded with KILL_DRAIN - 1
// (K is the drain's first cycle, as the model counts it: the ack is high
// from K + KILL_DRAIN + 1, the bound M4's KILL_DRAIN - 1 control holds
// tight; the tab's K + KILL_DRAIN + 2 is a cycle over it, RI-36) and
// counts to 0 and kill_ack_q clears; the epoch, flopped by the detector
// at K's edge, is taken at K+1's (into the ack epoch itself: the ack is low
// until ack-ready). The detector's three flops are RCU's boundary flops for
// the kill inputs (AR 338). Ack-ready is
// kill_drain == 0 with migration's quiesce term (rcu_mig's, a flop): at its
// edge kill_ack_q <- 1, held (a level, RA-23) until the next kill's K. A
// kill during a drain reloads the drain, takes its epoch and is answered
// once.
//   KILL_DRAIN = CCV_LAT_RCU_KILL_DRAIN = 2 + link_n(ooe_rcu_issue)
//                + bnd_rx(ooe_rcu_issue) + CCV_LAT_SFU + 1 + link_n(rcu_ooe_done)
//   (+ bnd_rx(rcu_ooe_done)), derived in params at the build's links: 15 at
//   the defaults, the issue end zero-cycle (RA-43: bnd_rx(ooe_rcu_issue)
//   0, the last issue's A is K+2; it was 16 with the end flopped, RA-42).
// The drain counter and the ack epoch are small groups (allowance waivers,
// rtl/cg-waivers.json); the ack and pending bits sit in the allowance.
//
// Done wake (rcu_ooe_done_wake): a flop written every cycle, D = any issue
// valid on the wire, or any lane or SFU descriptor stage valid, or R's pipe
// valid (each of rcu_lanes and rcu_r ORs its own flops into one term), or
// OOE's issue wake a cycle on (ccv_rcu's wake detector): R's done lands at
// A + 2, so its wake is due at A - 2, before any valid of the op is on the
// wire (the block lock-step on vadd).
//
// Idle (rcu_idle_q, the block gate's quiesced): no busy term from any
// module, no valid on any inbound channel, no kill or drain, no done wake.
//
// Credits. RCU never holds an inbound message on the issue and
// lane-result channels: each slot's credit flop takes the slot's valid on
// the wire, so its credit returns in the cycle the payload lands (valid
// leads payload by a cycle). 41 flops: issue slots 0-8, lane-result copies
// 0-31, written every cycle, the channels' own control
// pulses (an allowance waiver, rtl/cg-waivers.json, as a repeater's pulses
// go to the block's budget). miu_rcu_data has no credit port at RCU (RA-41,
// credit on receipt; AR 331). The issue credits leave the ports file with
// RA-41 and return with RA-43 (AR 331): RCU keeps their 9 flops.
//
// CSRs (RA-26): no CSRs; a 1-entry responder answers each request the
// cycle after it lands, done = 1 and data 0, with its credit in the same
// cycle. What marks a request is the fabric's (Q-59): csr_v_cr00h here.
//
// The reference is the RCU model's kill (sim/rcu/rcu_core.cpp, kill(),
// killQuiet()) and the Done, kill and reset tab; test/rcu/kill_tb.cpp holds
// this module to a value model of them.
//===----------------------------------------------------------------------===//
`include "ccv_assert.svh"
`define CCV_CLK rcu_core_clk
`define CCV_RST rst_r01h
module rcu_kill #(
  parameter int NB = 6,          // busy terms from the other modules
  parameter int ND = 3,          // done-wake terms: rcu_lanes' descriptor stages, R's pipe, the issue wake a cycle on
  localparam int NS = ccv_params_pkg::CCV_ISSUE_RESOURCES,   // issue slots, 9
  localparam int NL = 32,        // lane-result copies
  localparam int NM = 4,         // MIU data slots (idle only: no credit, RA-41)
  localparam int NC = NS + NL,
  localparam int WE = ccv_prov_pkg::CCV_P_W_KILL_EPOCH,
  localparam int KILL_DRAIN = ccv_prov_pkg::CCV_LAT_RCU_KILL_DRAIN,
  localparam int WD = $clog2(KILL_DRAIN + 1)
) (
  input  logic          rcu_core_clk,
  input  logic          rst_n,
  // Kill: valid in K-1, epoch in K; migration's quiesce term.
  input  logic          kv_cr01h,     // kill_valid, from ccv_rcu's kill detector flop (K)
  input  logic [WE-1:0] kep_cr02h,    // kill_epoch of K, from ccv_rcu's kill detector flop (K+1)
  input  logic          mq_cr01h,     // rcu_mig: no demotion, live restore row or unpaired entry of a killed warp
  output logic          kack_cr02h,   // kill_ack
  output logic [WE-1:0] kaep_cr03h,   // kill_ack_epoch
  // Inbound valids on the wire, each a cycle ahead of its payload.
  input  logic [NS-1:0] iv_cr00h,     // ooe_rcu_issue_s*_valid
  input  logic [NL-1:0] lv_cr00h,     // lane_rcu_res_c*_valid
  input  logic [NM-1:0] mv_cr00h,     // miu_rcu_data_s*_valid (idle)
  output logic [NC-1:0] cr_cr01h,     // credits: issue at [8:0], lane copies [40:9]
  // Wake and idle.
  input  logic [ND-1:0] dbusy_cr00h,  // a lane or SFU descriptor stage valid, R's pipe valid (each module's OR), the issue wake a cycle on
  input  logic [NB-1:0] busy_cr00h,   // each module's busy OR, from its flops
  output logic          dwake_cr01h,  // rcu_ooe_done_wake
  output logic          idle_cr01h,   // rcu_idle_q
  // CSRs.
  input  logic          csr_v_cr00h,  // a request lands
  output logic          csr_done_cr01h,
  output logic [31:0]   csr_data_cr01h,
  output logic          csr_cr_cr01h  // csr_credit
);

  // rst_n flopped before any use (RST-1), inverted after the flop.
  logic rst_cr01h_n;
  always_ff @(posedge rcu_core_clk) begin
    rst_cr01h_n <= rst_n;
  end
  wire rst_r01h = !rst_cr01h_n;

  // ---- Kill ------------------------------------------------------------
  // kv_cr01h is kill_v_q: ccv_rcu's kill detector flops kill_valid on the
  // ungated clock (RA rev 127, AR 336), so a kill that lands while the block
  // sleeps is seen in K, as an awake one is.
  // The ack is low from K's edge to ack-ready, so the ack epoch takes the
  // new epoch at K+1, from the detector's epoch flop under kvd_cr02h (kill_v_q
  // a cycle on, this module's own flop: CG-5, AR 338): it is the tab's
  // kill_ep_q and kill_ack_ep_q in one, set KILL_DRAIN - 2 cycles before ack-ready.
  logic [WE-1:0] kaep_q_cr03h;
  logic          kvd_cr02h;
  logic [WD-1:0] kd_cr02h;
  logic          kack_q_cr02h, kpend_cr02h;
  wire rdy_cr01h = kpend_cr02h & (kd_cr02h == '0) & mq_cr01h;
  wire kep_en_cr02h = kvd_cr02h;                    // the epoch at K+1
  wire kd_en_cr01h = kv_cr01h | (kd_cr02h != '0);   // load at K, count to 0
  wire ka_en_cr01h = kv_cr01h | rdy_cr01h;          // clear at K, set at ack-ready
  always_ff @(posedge rcu_core_clk) begin
    if (rst_r01h) begin
      kd_cr02h     <= '0;
      kack_q_cr02h <= 1'b0;
      kaep_q_cr03h <= '0;
      kvd_cr02h    <= 1'b0;
      kpend_cr02h  <= 1'b0;
    end else begin
      if (kd_en_cr01h) kd_cr02h <= kv_cr01h ? WD'(KILL_DRAIN - 1) : kd_cr02h - WD'(1);
      kvd_cr02h <= kv_cr01h;
      if (kep_en_cr02h) kaep_q_cr03h <= kep_cr02h;
      if (ka_en_cr01h) begin
        kack_q_cr02h <= ~kv_cr01h;
        kpend_cr02h  <= kv_cr01h;
      end
    end
  end
  assign kack_cr02h = kack_q_cr02h;
  assign kaep_cr03h = kaep_q_cr03h;

  // ---- Credits ---------------------------------------------------------
  logic [NC-1:0] cr_q_cr01h;
  always_ff @(posedge rcu_core_clk) begin
    if (rst_r01h) cr_q_cr01h <= '0;
    else          cr_q_cr01h <= {lv_cr00h, iv_cr00h};
  end
  assign cr_cr01h = cr_q_cr01h;

  // ---- Done wake and idle ----------------------------------------------
  logic dwake_q_cr01h, idle_q_cr01h;
  always_ff @(posedge rcu_core_clk) begin
    if (rst_r01h) begin
      dwake_q_cr01h <= 1'b0;
      idle_q_cr01h  <= 1'b0;
    end else begin
      dwake_q_cr01h <= |iv_cr00h | (|dbusy_cr00h);
      // lane_rcu_res and kill land at no-flop ends: those inputs go straight
      // into a flop (AR rev 285 (5)), so idle reads their captures, a cycle
      // on; the clock gate's quiesce hysteresis (8) and each channel's wake
      // cover the cycle.
      idle_q_cr01h  <= ~|busy_cr00h & ~|dbusy_cr00h & ~|iv_cr00h & ~|cr_q_cr01h[NS +: NL] &
                       ~|mv_cr00h & ~kv_cr01h & (kd_cr02h == '0) & ~dwake_q_cr01h;
    end
  end
  assign dwake_cr01h = dwake_q_cr01h;
  assign idle_cr01h = idle_q_cr01h;

  // ---- CSRs (RA-26) ----------------------------------------------------
  logic csr_q_cr01h;
  always_ff @(posedge rcu_core_clk) begin
    if (rst_r01h) csr_q_cr01h <= 1'b0;
    else          csr_q_cr01h <= csr_v_cr00h;
  end
  assign csr_done_cr01h = csr_q_cr01h;
  assign csr_cr_cr01h = csr_q_cr01h;
  assign csr_data_cr01h = '0;

  // ---- Contracts -------------------------------------------------------
  // The ack is low through every drain.
  `CCV_ASSERT(kill_ack_low_in_drain, !(kack_q_cr02h && kd_cr02h != '0))
  // One register is kill_ep_q and kill_ack_ep_q (RA rev 81, departure (4)):
  // the epoch is taken only a cycle after a K, whose edge cleared the ack, so
  // an ack that is high always reports the epoch it was raised for.
  `CCV_ASSERT(kill_ack_epoch_at_k, !(kep_en_cr02h && kack_q_cr02h))
  // A raised ack answers a pending kill, which it retires in the same edge.
  `CCV_ASSERT(kill_ack_not_pending, !(kack_q_cr02h && kpend_cr02h))

endmodule
`undef CCV_CLK
`undef CCV_RST
