//===-- ccv_common_clk.sv - a block's clock gate ----------------------------===//
//
// Spec: docs/clock-gate.md
// One instance per block top, its first act; clk is the block's
// ungated core_clk, so clk/rst_n are generic formals.
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
//   idle logic on the enable path. CSRs are written rarely, and only while
//   the blocks they control are idle (Daniel, 2026-10-17; Q-59), so a
//   threshold is promised only from the start of a run of quiesced or
//   stalled cycles it is steady for; written mid-run, it takes effect at
//   the counter's next step or at the next run.
//
//   WAKE, at the next edge but one. `wake` is registered here first, so
//   the one path from another block ends at a flop, never at the cell's
//   enable (Q-49): a wake high in cycle T opens the edge that ends cycle
//   T + 1. The gate then stays open through T + CCV_WAKE_LAT whatever the
//   block reports (WAKE_HOLD more edges), so a valid that follows its wake
//   by the Q-33 minimum is captured: the receiver's half of the wake
//   contract, wake_keeps_rx, which tools/check-formal.sh proves against
//   ccv_common_chk_wake. The block ORs into `wake` everything that must reach
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
// register, the full flags, the hold counter, the override CSR, the reset
// pipeline; the thresholds reach only the flags' D -- so the
// enable path is local, as a clock gate's must be: it sets up to the rising
// edge at the root of the block's clock tree, earlier than the flops see it.
//===----------------------------------------------------------------------===//
`include "ccv_assert.svh"
`include "ccv_params_pkg.sv"

`define CCV_CLK clk
`define CCV_RST !rst_n

module ccv_common_clk #(
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
    ccv_common_clk_wake_hold_short_of_CCV_WAKE_LAT u_refuse ();
  end

  localparam int HW = $clog2(WAKE_HOLD + 1);
  localparam int CW = HYST_W;
  localparam logic [HW-1:0] HOLD = HW'(WAKE_HOLD);

  `CCV_ASSERT_KNOWN(quiesced_known, quiesced)
  `CCV_ASSERT_KNOWN(stalled_known,  stalled)
  `CCV_ASSERT_KNOWN(wake_known,     wake)
  `CCV_ASSERT_KNOWN(override_known, cg_override)
  `CCV_ASSERT_KNOWN(hyst_known,     {hyst_quiesce, hyst_stall})

  // Consecutive quiesced / stalled cycles, saturating at the threshold, and
  // whether each has reached it; the registered wake; edges still owed to
  // it. On the ungated clock: they must see every cycle. Each full flag is
  // computed a cycle ahead, from the count it is loaded beside, so the
  // threshold compare is on no enable path: a count that has reached
  // max(threshold, 1) is one whose next value does. A threshold of 0 needs
  // no test of its own: count + 1 is never below 1. One bit wider, so a
  // count at the largest threshold does not wrap to 0.
  logic [CW-1:0] q_run_q, s_run_q;
  logic          q_full_q, s_full_q;
  logic [HW-1:0] hold_q;
  logic          wake_q;
  wire           sleep = (q_full_q || s_full_q) && (hold_q == '0);
  wire           en    = !sleep || wake_q || cg_override || !rst_n;

  // The counters and their flags are one clock gate, clocked when either
  // counter moves (local clock gating, docs/rtl-coding-style.md): counting,
  // or clearing when the block reports busy. Full and staying full, or
  // clear and staying clear, both hold and the clock stops. Inside it each
  // counter holds by adding nothing, not through an if, so synthesis keeps
  // the one enable. wake_q is the one path in from another block (Q-49);
  // an enable that saw `wake` would put that path on a clock gate, so it
  // is written every cycle. It and the hold counter, 3 flops, are too few
  // for a gate and within the module's allowance (rtl-coding-style.md).
  wire q_mv    = quiesced ? !q_full_q : (q_run_q != '0);
  wire s_mv    = stalled  ? !s_full_q : (s_run_q != '0);
  wire hyst_en = q_mv || s_mv;
  wire hold_en = wake_q ? (hold_q != HOLD) : (hold_q != '0);

  always_ff @(posedge clk) begin
    if (!rst_n) begin
      q_run_q  <= '0;
      s_run_q  <= '0;
      q_full_q <= 1'b0;
      s_full_q <= 1'b0;
      wake_q   <= 1'b0;
      hold_q   <= '0;
    end else begin
      if (hyst_en) begin
        q_run_q  <= quiesced ? q_run_q + CW'(!q_full_q) : '0;
        s_run_q  <= stalled  ? s_run_q + CW'(!s_full_q) : '0;
        q_full_q <= quiesced && ((CW+1)'(q_run_q) + 1'b1 >= (CW+1)'(hyst_quiesce));
        s_full_q <= stalled  && ((CW+1)'(s_run_q) + 1'b1 >= (CW+1)'(hyst_stall));
      end
      wake_q <= |wake;
      if (hold_en) hold_q <= wake_q ? HOLD : hold_q - 1'b1;
    end
  end

  ccv_common_ctech_icg u_icg (
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
