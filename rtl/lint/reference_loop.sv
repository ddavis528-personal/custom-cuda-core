//===-- reference_loop.sv - a declared feedback read, compliant --------===//
//
// Spec: docs/rtl-coding-style.md, CCV-L23 (declared feedback)
//
// A one-cycle select loop, as ooe_sched's: the request register (stage 02)
// reads back the grant register (stage 03) that its own value feeds. The read
// is the loop's back edge, declared in reference_loop.feedback.json, so the
// arithmetic skips its stage, and the lint finds the loop it closes.
// tools/check-1d.sh fails if ANY finding is reported here.
//===----------------------------------------------------------------------===//

module reference_loop (
  input  logic reference_core_clk,
  input  logic ref_rst_r00h,
  input  logic req_in_cy01h,
  output logic gnt_out_cy03h,
  output logic lead_out_cy04h
);
  logic req_cy02h, gnt_cy03h;
  always_ff @(posedge reference_core_clk) begin
    if (ref_rst_r00h) req_cy02h <= 1'b0;
    else              req_cy02h <= req_in_cy01h & ~gnt_cy03h;
  end
  always_ff @(posedge reference_core_clk) begin
    if (ref_rst_r00h) gnt_cy03h <= 1'b0;
    else              gnt_cy03h <= req_cy02h;
  end
  assign gnt_out_cy03h = gnt_cy03h;

  // A three-register loop (OA's rev 191, ooe_sched's ready, grant and gl):
  // rdy_cy02h reads lead_cy04h back through grt_cy03h, declared with its
  // registers in order, each hop of which the lint traces.
  logic rdy_cy02h, grt_cy03h, lead_cy04h;
  always_ff @(posedge reference_core_clk) begin
    if (ref_rst_r00h) rdy_cy02h <= 1'b0;
    else              rdy_cy02h <= req_in_cy01h & ~lead_cy04h;
  end
  always_ff @(posedge reference_core_clk) begin
    if (ref_rst_r00h) grt_cy03h <= 1'b0;
    else              grt_cy03h <= rdy_cy02h;
  end
  always_ff @(posedge reference_core_clk) begin
    if (ref_rst_r00h) lead_cy04h <= 1'b0;
    else              lead_cy04h <= grt_cy03h;
  end
  assign lead_out_cy04h = lead_cy04h;
endmodule
