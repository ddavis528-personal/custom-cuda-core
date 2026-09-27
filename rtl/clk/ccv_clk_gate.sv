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
//   input changes. The gate closes once either has held for its own
//   hysteresis, HYST_QUIESCE or HYST_STALL consecutive cycles: the edge that
//   ends the HYST-th such cycle is delivered, the next one is not. Both are
//   read from the gated domain, so once the gate closes they hold still and
//   the block stays asleep until something outside it changes.
//
//   WAKE, within one cycle. `wake` goes straight to the cell's enable, past
//   every register here, so a wake that is high in a cycle opens the gate
//   for the edge that ends THAT cycle. It then holds the gate open for
//   WAKE_HOLD more edges, whatever the block reports, so a message whose
//   valid follows its wake by the Q-33 minimum (CCV_WAKE_LAT) is captured:
//   the receiver's half of the wake contract (tools/check-formal.sh proves it
//   against ccv_wake_checker). The block ORs into `wake` everything that
//   must reach it while asleep: every inbound channel's _wake, and any
//   credit, stall release or request it sleeps waiting for.
//
//   CG_OVERRIDE and RESET force the gate open. Override is the chicken bit.
//   Reset is synchronous, so a block in reset must be clocked or it never
//   resets: rst_n low opens the gate on the cycle it arrives.
//
//   TEST. `te` goes to the cell's own test-enable pin, as scan expects.
//
// `gated` is the gate's decision for the coming edge: 1 means that edge will
// not reach the block. A block brings it out as its clk_gated observation
// port (CCV_CHECK only), which is what the wake checkers read.
//
// Timing: the enable path starts at a flop here or at the far end of a wake
// net -- a flop in the sender, or the last repeater stage -- and ends at the
// cell's enable pin, which sets up to the rising edge at the root of the
// block's clock tree. It is the one cross-block path allowed into a clock
// gate, and the reason a wake is registered at its source (docs/clock-gate.md).
//===----------------------------------------------------------------------===//
`include "ccv_assert.svh"
`include "ccv_params_pkg.sv"

`define CCV_CLK clk
`define CCV_RST !rst_n

module ccv_clk_gate #(
  parameter int HYST_QUIESCE = ccv_prov_pkg::CCV_CG_HYST_QUIESCE,
  parameter int HYST_STALL   = ccv_prov_pkg::CCV_CG_HYST_STALL,
  parameter int WAKE_HOLD    = ccv_params_pkg::CCV_WAKE_LAT,
  parameter int NWAKE        = 1
) (
  input  logic             clk,       // core_clk, ungated
  input  logic             rst_n,
  input  logic             quiesced,  // from the block: nothing in flight
  input  logic             stalled,   // from the block: nothing can move
  input  logic [NWAKE-1:0] wake,      // any one opens the next edge
  input  logic             cg_override, // force the clock on
  input  logic             te,        // scan test enable, to the cell
  output logic             gclk,      // the block's clock
  output logic             gated      // the coming edge will not reach it
);

  // A hysteresis of 0 would put the block's own combinational idle signals
  // on the enable path, and a hold short of the wake latency breaks Q-33.
  if (HYST_QUIESCE < 1 || HYST_STALL < 1) begin : g_bad_hyst
    ccv_clk_gate_hysteresis_must_be_at_least_1 u_refuse ();
  end
  if (WAKE_HOLD < ccv_params_pkg::CCV_WAKE_LAT) begin : g_bad_hold
    ccv_clk_gate_wake_hold_below_CCV_WAKE_LAT u_refuse ();
  end

  localparam int MAXC = (HYST_QUIESCE > HYST_STALL ? HYST_QUIESCE : HYST_STALL) > WAKE_HOLD
                      ? (HYST_QUIESCE > HYST_STALL ? HYST_QUIESCE : HYST_STALL) : WAKE_HOLD;
  localparam int CW = $clog2(MAXC + 1);
  localparam logic [CW-1:0] HQ = CW'(HYST_QUIESCE);
  localparam logic [CW-1:0] HS = CW'(HYST_STALL);
  localparam logic [CW-1:0] HOLD = CW'(WAKE_HOLD);

  `CCV_ASSERT_KNOWN(quiesced_known, quiesced)
  `CCV_ASSERT_KNOWN(stalled_known,  stalled)
  `CCV_ASSERT_KNOWN(wake_known,     wake)
  `CCV_ASSERT_KNOWN(override_known, cg_override)

  // Consecutive quiesced / stalled cycles, saturating at the hysteresis, and
  // edges still owed to the last wake. On the ungated clock: they must see
  // every cycle, and there are CW*3 of them.
  logic [CW-1:0] q_run_q, s_run_q, hold_q;
  wire           wake_any = |wake;
  wire           q_full   = (q_run_q == HQ);
  wire           s_full   = (s_run_q == HS);
  wire           sleep    = (q_full || s_full) && (hold_q == '0);
  wire           en       = !sleep || wake_any || cg_override || !rst_n;

  always_ff @(posedge clk) begin
    if (!rst_n) begin
      q_run_q <= '0;
      s_run_q <= '0;
      hold_q  <= '0;
    end else begin
      if (!quiesced)   q_run_q <= '0;
      else if (!q_full) q_run_q <= q_run_q + 1'b1;
      if (!stalled)    s_run_q <= '0;
      else if (!s_full) s_run_q <= s_run_q + 1'b1;
      if (wake_any)    hold_q  <= HOLD;
      else if (hold_q != '0) hold_q <= hold_q - 1'b1;
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
  `CCV_ASSERT(wake_opens,     !(wake_any && gated))
  `CCV_ASSERT(override_opens, !(cg_override && gated))

endmodule

`undef CCV_CLK
`undef CCV_RST
