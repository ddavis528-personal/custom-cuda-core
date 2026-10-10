//===-- ccv_common_ctech_icg.sv - integrated clock gate: SIMULATION view ---------===//
//
// Spec: docs/clock-gate.md, "The ctech layer"
// The icg cell's behavioural view, for simulation and formal only.
//
// A ctech cell is a module with one fixed port list and one definition per
// VIEW, selected by the file list (tools/ccv_ctech.py): this one for
// simulation and formal, and one per process library that is nothing but an
// instance of that library's cell (rtl/ctech/<library>/). RTL instantiates
// ccv_common_ctech_icg and never a library cell, so the design is written once and
// the cell is a file-list choice -- and synthesis gets a real ICG, not
// whatever it would infer from a latch and an AND.
//
// THE MODEL is the cell's function, latch included: the enable is captured
// while clk is low and held while it is high, so a change of `en` during
// the high phase cannot chop the gated clock. An AND of the raw enable with
// the clock would produce a runt pulse whenever the enable moved mid-cycle;
// tools/check-ctech.sh drives exactly that and requires a clean gclk, and
// requires this view to match the sky130 cell's own model edge for edge.
//
// `te` is the scan test enable: ORed ahead of the latch, as every library
// ICG does it (sky130 SCE, ASAP7 SE), so a scan shift clocks the block
// whatever the functional enable says.
//
// Refused by synthesis, loudly: under SYNTHESIS this view instantiates a
// module that does not exist. A synthesised behavioural latch would work in
// every simulation and quietly give up the cell's timing checks.
//===----------------------------------------------------------------------===//

module ccv_common_ctech_icg (
  input  logic clk,
  input  logic en,
  input  logic te,
  output logic gclk
);
`ifdef SYNTHESIS
  ccv_ctech_sim_view_in_synthesis u_use_a_library_view ();
  assign gclk = clk;
`else
  logic en_l;
  always_latch begin
    if (!clk) en_l = en | te;
  end
  assign gclk = clk & en_l;
`endif
endmodule
