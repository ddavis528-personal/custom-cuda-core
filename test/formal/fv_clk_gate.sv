//===-- fv_clk_gate.sv - formal harness: the block clock gate -------------===//
//
// Spec: docs/clock-gate.md
//
// ccv_common_clk with the SIMULATION view of its ctech ICG, latch and all,
// proved by tools/check-formal.sh on Yosys's multiclock model
// (clk2fflogic): `clk` is an input like any other, toggling every global
// step, so the latch, the AND and the gated clock are modelled as they
// switch -- not as a cycle-level abstraction that would assume the very
// glitch-freedom being proved.
//
// Two stimulus modes:
//   FV_ASYNC  every input may move at ANY step, the high phase included.
//             Proves the gated clock clean whatever the enable does:
//             glitch_high_only, glitch_rise, glitch_fall.
//   default   inputs move only as a flop on clk would drive them, at the
//             rising step. Proves the cycle behaviour:
//               edge_decides   the edge that ends a cycle reaches the block
//                              exactly when `gated` was low in that cycle
//               wake_second_edge  a wake in cycle T opens the edge that
//                              ends T + 1 (it is registered first, Q-49)
//               wake_hold      ...and the WAKE_HOLD edges after it
//               override_opens / reset_opens / te_opens
//               spec           `gated` equals an independent model built
//                              from input HISTORIES (shift registers), not
//                              the design's saturating counters
//   FV_Q33    ccv_common_chk_wake on this gate's own `gated`, the sender's
//             half ASSUMED and the receiver's asserted: proves
//             wake_keeps_rx (the gate runs LAT cycles after any wake) and
//             q33_valid_meets_clock (so no valid that keeps the contract
//             arrives in a cycle whose edge the gate withholds).
//   FV_REACH  non-vacuity: the gate does close (reach_gated), and a valid
//             is captured in a cycle right after a sleep (reach_woken).
//===----------------------------------------------------------------------===//
`include "ccv_if.svh"

module fv_clk_gate #(
  parameter int HQ   = 3,
  parameter int HS   = 5,
  parameter int HOLD = ccv_params_pkg::CCV_WAKE_LAT - 1
) (
  input logic clk,
  input logic rst_n,
  input logic quiesced,
  input logic stalled,
  input logic wake,
  input logic cg_override,
  input logic te,
  input logic valid,
  input logic [ccv_prov_pkg::CCV_CG_HYST_W-1:0] hyst_q_in,
  input logic [ccv_prov_pkg::CCV_CG_HYST_W-1:0] hyst_s_in
);
  localparam int HW = ccv_prov_pkg::CCV_CG_HYST_W;
  // The thresholds are CSR inputs. The cycle model needs them fixed, at HQ
  // and HS; the clean-clock and Q-33 proofs hold for ANY values, changing
  // at any time (FV_FREE_HYST).
`ifdef FV_FREE_HYST
  wire [HW-1:0] hyst_q = hyst_q_in;
  wire [HW-1:0] hyst_s = hyst_s_in;
`else
  wire [HW-1:0] hyst_q = HW'(HQ);
  wire [HW-1:0] hyst_s = HW'(HS);
`endif
  logic gclk, gated;
  ccv_common_clk #(.WAKE_HOLD(HOLD)) dut (
    .clk         (clk),
    .rst_n       (rst_n),
    .quiesced    (quiesced),
    .stalled     (stalled),
    .hyst_quiesce(hyst_q),
    .hyst_stall  (hyst_s),
    .wake        (wake),
    .cg_override (cg_override),
    .te          (te),
    .gclk        (gclk),
    .gated       (gated)
  );

  // -- the clock, and the previous step of everything ----------------------
  logic started;
  initial started = 1'b0;
  logic clk_p, gclk_p, gated_p, rst_n_p, q_p, s_p, w_p, o_p, te_p, v_p;
  always @($global_clock) begin
    started <= 1'b1;
    clk_p   <= clk;
    gclk_p  <= gclk;
    gated_p <= gated;
    rst_n_p <= rst_n;
    q_p     <= quiesced;
    s_p     <= stalled;
    w_p     <= wake;
    o_p     <= cg_override;
    te_p    <= te;
    v_p     <= valid;
  end
  wire rose = started && clk && !clk_p;
  wire fell = started && !clk && clk_p;
  // Each phase lasts one step or two, freely: with a clock that toggled on
  // every step, nothing could ever change MID-phase, and the glitch an AND
  // gate makes would be unrepresentable rather than absent.
  logic held_p;
  always @($global_clock) held_p <= started && (clk == clk_p);
  always @* if (started) assume (!(clk == clk_p && held_p));

`ifndef FV_ASYNC
  // Driven by flops on clk: a change lands only at a rising step.
  always @* if (started && !rose)
    assume (rst_n == rst_n_p && quiesced == q_p && stalled == s_p &&
            wake == w_p && cg_override == o_p && te == te_p && valid == v_p);
`endif

  // -- the gated clock is clean, whatever the enable does -------------------
  wire g_rise = started && gclk && !gclk_p;
  wire g_fall = started && !gclk && gclk_p;
  always @* begin
    glitch_high_only: assert (!gclk || clk);
    glitch_rise:      assert (!g_rise || rose);
    glitch_fall:      assert (!g_fall || fell);
  end

`ifndef FV_ASYNC
  // -- the decision is the edge ---------------------------------------------
  // `gated` in the cycle's last step is what the next rising edge does.
  always @* if (rose) edge_decides: assert (gclk == !gated_p);

  // -- cycle behaviour, sampled at the edge that ends each cycle ------------
  // History of the last HQ / HS / HOLD cycles, cleared by reset: the model
  // the gate is held to, deliberately not built the way the gate is.
  logic [HQ-1:0]   qh;
  logic [HS-1:0]   sh;
  logic [HOLD:0]   wh;     // the wake is registered: HOLD + 1 cycles open
  initial begin qh = '0; sh = '0; wh = '0; end
  always @(posedge clk) begin
    qh <= !rst_n ? '0 : HQ'({qh, quiesced});
    sh <= !rst_n ? '0 : HS'({sh, stalled});
    wh <= !rst_n ? '0 : (HOLD+1)'({wh, wake});
  end
  // No `wake` term: this cycle's wake reaches the gate a cycle later.
  wire exp_gated = rst_n && !te && !cg_override && !(|wh) &&
                   ((&qh) || (&sh));

  // Flops power up anything (formalff -ff2anyinit), the gate's counters as
  // real ones do; the cycle properties hold from the first reset edge on.
  logic reset_seen;
  initial reset_seen = 1'b0;
  always @(posedge clk) if (!rst_n) reset_seen <= 1'b1;
  // ...and the first cycle is one, as the top's is: the checker below has
  // flops of its own that mean nothing before it.
  always @(posedge clk) if (!reset_seen) assume (!rst_n);

  always @(posedge clk) if (started && reset_seen) begin
`ifndef FV_Q33
`ifndef FV_REACH
    spec:             assert (gated == exp_gated);
    wake_second_edge: assert (!(rst_n && wh[0] && gated));
    wake_hold:        assert (!(rst_n && (|wh) && gated));
    override_opens: assert (!(cg_override && gated));
    reset_opens:    assert (!(!rst_n && gated));
    te_opens:       assert (!(te && gated));
`endif
`endif
  end

`ifdef FV_Q33
  // -- Q-33, both halves, as ccv_common_chk_wake states them about THIS gate ---
  // The sender's half assumed, the receiver's asserted: the gate keeps
  // wake_keeps_rx (running LAT cycles after any wake), and so any sender
  // keeping its half never lands a valid on a withheld edge.
  ccv_common_chk_wake #(.MODE(`CCV_MODE_ASSUME), .RX_MODE(`CCV_MODE_ASSERT),
                     .LAT(ccv_params_pkg::CCV_WAKE_LAT)) u_contract (
    .clk       (clk),
    .rst_n     (rst_n),
    .rx_gated  (gated),
    .wake_seen (wake),
    .valid_seen(valid)
  );
  always @(posedge clk) if (started && reset_seen && rst_n)
    q33_valid_meets_clock: assert (!(valid && gated));
`endif

`ifdef FV_REACH
  // Asserted false: their counterexamples ARE the witnesses.
  logic slept_q;
  initial slept_q = 1'b0;
  always @(posedge clk)
    slept_q <= (gated && reset_seen && rst_n) ? 1'b1 : (valid ? 1'b0 : slept_q);
  always @(posedge clk) if (started && reset_seen) begin
    reach_gated: assert (!gated);
    reach_woken: assert (!(valid && !gated && slept_q && rst_n));
  end
`endif
`endif

endmodule
