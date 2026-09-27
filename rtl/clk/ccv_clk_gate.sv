//===-- ccv_clk_gate.sv - a block's clock gate ----------------------------===//
//
// Spec: docs/clock-gate.md
// Reusable: one instance per block, its first act; clk is the block's
//           ungated core_clk, so clk/rst_n are generic formals.
//
// Every block runs on the gclk of one of these (CCV-L22), and every clock
// gate in the design is the ctech ICG inside one (CCV-L27). Around the cell,
// the policy that decides when a block sleeps:
//
//   SLEEP ENTRY. The block reports two local conditions: `quiesced`, nothing
//   in flight and nothing owed, and `stalled`, nothing can move until an
//   input changes. The gate closes once either has held for its hysteresis,
//   hyst_quiesce or hyst_stall consecutive cycles: the edge that ends the
//   last of them is delivered, the next one is not. Both come from the gated
//   domain, so once the gate closes they hold still and the block stays
//   asleep until something outside it changes. The thresholds are INPUTS,
//   for the block's CSRs to drive (Q-47); a block without CSR decode yet
//   ties them to CCV_CG_HYST_QUIESCE / _STALL, the CSRs' reset values. A
//   threshold of 0 counts as 1: 0 would put the block's own combinational
//   idle logic on the enable path.
//
//   WAKE, at the next edge but one. `wake` is registered here first, so
//   the one path from another block ends at a flop, never at the cell's
//   enable (Q-49): a wake high in cycle T opens the edge that ends cycle
//   T + 1. The gate then stays open through T + CCV_WAKE_LAT whatever the
//   block reports (WAKE_HOLD more edges), so a valid that follows its wake
//   by the Q-33 minimum is captured: the receiver's half of the wake
//   contract, wake_keeps_rx, which tools/check-formal.sh proves against
//   ccv_wake_checker. The block ORs into `wake` everything that must reach
//   it while asleep: every inbound channel's _wake, and any credit, stall
//   release or request it sleeps waiting for.
//
//   CG_OVERRIDE and RESET force the gate open. Override is the chicken bit,
//   a CSR (Q-47). Reset is synchronous, so a block in reset must be clocked
//   or it never resets: rst_n low opens the gate on the cycle it arrives.
//
//   TEST. `te` goes to the cell's own test-enable pin, as scan expects.
//
// `gated` is the gate's decision for the coming edge: 1 means that edge will
// not reach the block. A block brings it out as its clk_gated observation
// port (CCV_CHECK only), which is what the wake checkers read.
//
// Timing: every input of the enable is a flop in this block -- the wake
// register, the counters, the override CSR, the reset pipeline -- so the
// enable path is local, as a clock gate's must be: it sets up to the rising
// edge at the root of the block's clock tree, earlier than the flops see it.
//===----------------------------------------------------------------------===//
`include "ccv_assert.svh"
`include "ccv_params_pkg.sv"

`define CCV_CLK clk
`define CCV_RST !rst_n

module ccv_clk_gate #(
  parameter int HYST_W    = ccv_prov_pkg::CCV_CG_HYST_W,
  parameter int WAKE_HOLD = ccv_params_pkg::CCV_WAKE_LAT - 1,
  parameter int NWAKE     = 1
) (
  input  logic              clk,          // core_clk, ungated
  input  logic              rst_n,
  input  logic              quiesced,     // from the block: nothing in flight
  input  logic              stalled,      // from the block: nothing can move
  input  logic [HYST_W-1:0] hyst_quiesce, // quiesced cycles before sleep (CSR)
  input  logic [HYST_W-1:0] hyst_stall,   // stalled cycles before sleep (CSR)
  input  logic [NWAKE-1:0]  wake,         // any one opens the edge after next
  input  logic              cg_override,  // force the clock on (CSR)
  input  logic              te,           // scan test enable, to the cell
  output logic              gclk,         // the block's clock
  output logic              gated         // the coming edge will not reach it
);

  // Registered wake, then WAKE_HOLD more edges: open from T + 1 through
  // T + 1 + WAKE_HOLD. Short of T + CCV_WAKE_LAT breaks Q-33.
  if (WAKE_HOLD + 1 < ccv_params_pkg::CCV_WAKE_LAT) begin : g_bad_hold
    ccv_clk_gate_wake_hold_short_of_CCV_WAKE_LAT u_refuse ();
  end

  localparam int HW = $clog2(WAKE_HOLD + 1);
  localparam int CW = HYST_W > HW ? HYST_W : HW;
  localparam logic [CW-1:0] HOLD = CW'(WAKE_HOLD);

  `CCV_ASSERT_KNOWN(quiesced_known, quiesced)
  `CCV_ASSERT_KNOWN(stalled_known,  stalled)
  `CCV_ASSERT_KNOWN(wake_known,     wake)
  `CCV_ASSERT_KNOWN(override_known, cg_override)
  `CCV_ASSERT_KNOWN(hyst_known,     {hyst_quiesce, hyst_stall})

  // The thresholds as used: 0 counts as 1.
  wire [CW-1:0] hq = (hyst_quiesce == '0) ? CW'(1) : CW'(hyst_quiesce);
  wire [CW-1:0] hs = (hyst_stall   == '0) ? CW'(1) : CW'(hyst_stall);

  // Consecutive quiesced / stalled cycles, saturating at the threshold; the
  // registered wake; edges still owed to it. On the ungated clock: they must
  // see every cycle. `>=`, so a threshold lowered mid-count takes effect.
  logic [CW-1:0] q_run_q, s_run_q, hold_q;
  logic          wake_q;
  wire           q_full = (q_run_q >= hq);
  wire           s_full = (s_run_q >= hs);
  wire           sleep  = (q_full || s_full) && (hold_q == '0);
  wire           en     = !sleep || wake_q || cg_override || !rst_n;

  always_ff @(posedge clk) begin
    if (!rst_n) begin
      q_run_q <= '0;
      s_run_q <= '0;
      wake_q  <= 1'b0;
      hold_q  <= '0;
    end else begin
      if (!quiesced)    q_run_q <= '0;
      else if (!q_full) q_run_q <= q_run_q + 1'b1;
      if (!stalled)     s_run_q <= '0;
      else if (!s_full) s_run_q <= s_run_q + 1'b1;
      wake_q <= |wake;
      if (wake_q)             hold_q <= HOLD;
      else if (hold_q != '0)  hold_q <= hold_q - 1'b1;
    end
  end

  ccv_ctech_icg u_icg (
    .clk (clk),
    .en  (en),
    .te  (te),
    .gclk(gclk)
  );

  assign gated = !(en || te);

  // The promises, checked wherever this runs; tools/check-formal.sh proves
  // them, with their timing, for all time.
  `CCV_ASSERT(wake_opens,     !(wake_q && gated))
  `CCV_ASSERT(override_opens, !(cg_override && gated))

endmodule

`undef CCV_CLK
`undef CCV_RST
