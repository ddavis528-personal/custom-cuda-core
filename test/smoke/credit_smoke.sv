//===-- credit_smoke.sv - a protocol-correct producer/consumer pair -----===//
//
// Spec: docs/interface-checker-convention.md
// Reusable: exercises the shared checker; clk/rst_n are generic formals.
//
// Protocol-CORRECT, so nothing may fire. That polarity is the point: the
// spike cases prove the machinery CAN fire, and this proves it does not fire
// at everything -- which a checker with an inverted property would also do,
// and which a "does it fire" test alone would pass.
//
// Exercises all four conventions the grill-me fixed: credited sending, valid
// one cycle ahead of payload, stall-invalidate with no send the following
// cycle, and the checker instantiated at the boundary.
//===----------------------------------------------------------------------===//
`include "ccv_if.svh"
`include "ccv_params_pkg.sv"

`define CCV_CLK clk
`define CCV_RST !rst_n

module credit_smoke #(
  parameter int PAYLOAD_W  = 32,
  parameter int ROUND_TRIP = ccv_params_pkg::CCV_RT_ABUT,
  parameter int DEPTH      = ccv_params_pkg::CCV_CREDIT_DEPTH
) (
  input  logic clk,
  input  logic rst_n,
  input  logic want_send,
  input  logic rx_stall,
  output logic ch_valid,
  output logic ch_credit,
  output logic ch_stall
);

  localparam int CW = $clog2(DEPTH + 2);

  logic [CW-1:0]         credits;
  logic [PAYLOAD_W-1:0]  ch_payload;
  logic [PAYLOAD_W-1:0]  next_data;
  logic                  valid_q;
  logic                  stall_q;

  assign ch_stall = rx_stall;

  // The sender may only assert valid when it holds a credit and was not
  // stalled last cycle. Those two conditions are the whole protocol.
  wire can_send = (credits != '0) && !stall_q;

  always_ff @(posedge clk) begin
    if (!rst_n) begin
      credits    <= DEPTH[CW-1:0];
      ch_valid   <= 1'b0;
      valid_q    <= 1'b0;
      stall_q    <= 1'b0;
      next_data  <= '0;
      ch_payload <= '0;
    end else begin
      stall_q  <= ch_stall;
      valid_q  <= ch_valid;

      ch_valid <= want_send && can_send;

      // Valid leads the payload by exactly one cycle: the data presented now
      // is what last cycle's valid promised.
      if (ch_valid) begin
        ch_payload <= next_data;
        next_data  <= next_data + 1'b1;
      end

      // A credit is spent on VALID, not on the payload landing.
      if ((want_send && can_send) && !ch_credit)      credits <= credits - 1'b1;
      else if (!(want_send && can_send) && ch_credit) credits <= credits + 1'b1;
    end
  end

  // The receiver returns a credit one cycle after the payload lands.
  always_ff @(posedge clk) begin
    if (!rst_n) ch_credit <= 1'b0;
    else        ch_credit <= valid_q;
  end

  // Instantiated directly rather than through `CCV_CHECKER, because this one
  // needs parameters beyond the mode and SystemVerilog allows one parameter
  // list. The mode still comes from the side macro.
  ccv_credit_checker #(
    .MODE(`CCV_IF_MODE_OUT),
    .PAYLOAD_W(PAYLOAD_W), .ROUND_TRIP(ROUND_TRIP), .DEPTH(DEPTH),
    .TIMEOUT_N(ccv_prov_pkg::CCV_P_TIMEOUT_N)
  ) u_chk (
    .clk(clk), .rst_n(rst_n), .ch_valid(ch_valid), .ch_payload(ch_payload),
    .ch_credit(ch_credit), .ch_stall(ch_stall)
  );

endmodule

`undef CCV_CLK
`undef CCV_RST
