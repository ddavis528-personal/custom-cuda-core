//===-- ccv_wake_checker.sv - wake leads valid by CCV_WAKE_LAT ------------===//
//
// Spec: open item Q-33 (docs/open-items.md); schema channel_signals `_wake`
// Reusable: one instance per channel instance; clk/rst_n are generic formals.
//
// THE CONTRACT. If valid asserts toward a gated receiver at cycle T, the
// channel's wake must have asserted at or before T - LAT. A receiver's clock
// takes LAT cycles to come back after a wake, so a later wake means the
// message meets a stopped clock.
//
// WHAT "GATED AT T" MEANS HERE, since a correctly woken receiver is running
// by T and cannot be judged from its state at T alone: the obligation starts
// when the receiver gates (`rx_gated` rises) and holds until either
//   - THIS channel's wake, asserted after the receiver gated, has aged LAT
//     cycles; or
//   - the receiver has run ungated for LAT consecutive cycles, woken by
//     something else, and is up by any account.
// A wake that arrived while the receiver was still awake does not count
// toward a sleep that begins after it: nothing obliges a receiver to stay
// awake because a wake passed it by.
//
// A tracking register rather than a sequence, because no multi-cycle
// construct exists in any tool (F-2). Ternary selects, not `if` on the
// inputs (CCV-L08), as in ccv_outstanding_checker.
//===----------------------------------------------------------------------===//
`include "ccv_if.svh"

`define CCV_CLK clk
`define CCV_RST !rst_n

module ccv_wake_checker #(
  parameter int MODE = `CCV_MODE_ASSERT,
  parameter int LAT  = ccv_params_pkg::CCV_WAKE_LAT
) (
  input logic clk,
  input logic rst_n,
  input logic rx_gated,   // the receiver's sleep_ok: its clock is stopped
  input logic wake,       // this channel instance's _wake
  input logic valid       // any slot of this channel instance
);

  localparam int AW = $clog2(LAT + 1);
  localparam int AW_LAT = LAT;
  wire [AW-1:0] lat = AW_LAT[AW-1:0];

  logic          gated_q;   // rx_gated last cycle: a rise starts a sleep
  logic          owed_q;    // a sleep began and is not yet answered
  logic          woken_q;   // this channel's wake has answered it
  logic [AW-1:0] age_q;     // cycles since that wake, saturating at LAT
  logic [AW-1:0] run_q;     // cycles the receiver has run ungated, saturating

  wire sleep_start = rx_gated && !gated_q;
  // Answered as of THIS cycle: the wake is LAT old, or the receiver is up.
  wire answered = (woken_q && age_q >= lat) || (run_q >= lat);
  wire owed_now = sleep_start || (owed_q && !answered);

  wire          woken_d = sleep_start ? wake : owed_now && (woken_q || wake);
  // The wake that answers a sleep: the first one after it began. A new sleep
  // restarts the count even if an older wake is still recorded.
  wire first_wake = wake && (sleep_start || (owed_now && !woken_q));
  wire [AW-1:0] age_d   = first_wake ? AW'(1) :
                          (woken_q && age_q != lat) ? age_q + 1'b1 : age_q;
  wire [AW-1:0] run_d   = rx_gated ? '0 : (run_q != lat) ? run_q + 1'b1 : run_q;

  always_ff @(posedge clk) begin
    if (!rst_n) begin
      gated_q <= 1'b0;
      owed_q  <= 1'b0;
      woken_q <= 1'b0;
      age_q   <= '0;
      run_q   <= lat;      // blocks come out of reset running
    end else begin
      gated_q <= rx_gated;
      owed_q  <= owed_now;
      woken_q <= woken_d;
      age_q   <= woken_d ? age_d : '0;
      run_q   <= run_d;
    end
  end

  `CCV_CONTRACT_M(MODE, wake_leads_valid, !(valid && owed_now))

  // -- satisfiability (§3.3): a sleep is answered by this channel's wake --
  `CCV_IF_SAT(slept,        sleep_start)
  `CCV_IF_SAT(woken_in_time, valid && woken_q && age_q >= lat)

endmodule

`undef CCV_CLK
`undef CCV_RST
