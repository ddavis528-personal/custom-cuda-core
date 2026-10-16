//===-- ccv_common_ctech_icg.sv - integrated clock gate: sky130_fd_sc_hd view ----===//
//
// Spec: docs/clock-gate.md, "The ctech layer"
// The icg cell's SkyWater 130 nm high-density library view.
//
// The library's latch-based, scan-enabled ICG, and nothing else. Drive
// strength 1: clock-tree synthesis resizes it. Pin roles, from the cell's
// own model (test/ctech/vendor/sky130_fd_sc_hd/): GATE the functional enable,
// SCE the scan enable, both latched while CLK is low; GCLK = CLK & latch.
//===----------------------------------------------------------------------===//

module ccv_common_ctech_icg (
  input  logic clk,
  input  logic en,
  input  logic te,
  output logic gclk
);
  sky130_fd_sc_hd__sdlclkp_1 u_cell (
    .CLK (clk),
    .GATE(en),
    .SCE (te),
    .GCLK(gclk)
  );
endmodule
