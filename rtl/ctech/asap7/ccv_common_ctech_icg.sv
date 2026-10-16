//===-- ccv_common_ctech_icg.sv - integrated clock gate: ASAP7 view --------------===//
//
// Spec: docs/clock-gate.md, "The ctech layer"
// The icg cell's ASAP7 view: the 7 nm predictive library, RVT.
//
// The library's ICG, and nothing else. Pin roles from its Liberty cell
// (asap7sc7p5t_SEQ_RVT, clock_gating_integrated_cell latch_posedge_precontrol):
// CLK clock_gate_clock_pin, ENA clock_gate_enable_pin, SE clock_gate_test_pin,
// GCLK clock_gate_out_pin, state_function CLK & IQ.
//===----------------------------------------------------------------------===//

module ccv_common_ctech_icg (
  input  logic clk,
  input  logic en,
  input  logic te,
  output logic gclk
);
  ICGx1_ASAP7_75t_R u_cell (
    .CLK (clk),
    .ENA (en),
    .SE  (te),
    .GCLK(gclk)
  );
endmodule
