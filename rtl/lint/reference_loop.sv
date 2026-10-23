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
  output logic gnt_out_cy03h
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
endmodule
