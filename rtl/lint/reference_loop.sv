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
  output logic lead_out_cy04h,
  output logic byp_out_cy02h
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

  // A bypass (DA, 2026-10-23; OI-72 (A)): hit_cy02h reads g2_cy03h, the
  // stage-03 copy of g1_cy02h, which its own stage also holds: a bypass mux
  // around a table written a cycle late, declared with its offset. It is
  // assigned under an if, whose condition counts as its input too
  // (OI's rev 188): sel_cy02h, its own stage.
  logic g1_cy02h, g2_cy03h, sel_cy02h, hit_cy02h;
  always_ff @(posedge reference_core_clk) begin
    g1_cy02h  <= req_in_cy01h;
    sel_cy02h <= req_in_cy01h;
    g2_cy03h  <= g1_cy02h;
  end
  always_comb begin
    hit_cy02h = 1'b0;
    if (sel_cy02h) hit_cy02h = g2_cy03h | g1_cy02h;
  end
  // And a bypass reader whose other inputs are all a stage earlier: the
  // bypass read counts at its register's stage less its offset, 02, so the
  // net is stage 02 (OI's rev 189, OA's rev 212). Were the read dropped,
  // the arithmetic would give 01.
  logic hit2_cy02h;
  assign hit2_cy02h = g2_cy03h & req_in_cy01h;
  assign byp_out_cy02h = hit_cy02h | hit2_cy02h;
endmodule
