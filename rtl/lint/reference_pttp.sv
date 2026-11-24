//===-- reference_pttp.sv - a table writer behind a write pipeline, compliant ---===//
//
// Spec: docs/rtl-coding-style.md, CCV-L23 across a connection (OA-500)
//
// u_map's shape (OA-500): u_w's inputs d_cy00h and en_cy00h are fed from
// the parent's registers at 04, four stages past, and reach u_w's table
// register tab_cy02h only through the write-pipeline registers dq_cy01h and
// eq_cy01h, whose whole fanout ends at the table register. u_r reads the
// table as declared (reference_pttr.feedback.json), so the back edges at
// u_w's inputs are the table's write, excused by the verified table.
// bad_conn5.sv's reference_xttp gives a pipeline register one more fanout,
// and the finding comes back.
// tools/check-1d.sh fails if ANY finding is reported here.
//===----------------------------------------------------------------------===//

`define CCV_CLK reference_core_clk
`define CCV_RST ref_rst_r00h

module reference_pttp (
  input  logic       reference_core_clk,
  input  logic       ref_rst_r00h,
  input  logic [3:0] x_cy03h,
  input  logic       en_cy03h,
  input  logic       pw_cy01h,
  output logic [3:0] o_cy02h
);
  logic [3:0] rd_cy02h;
  logic [3:0] dd_cy04h;
  logic       ee_cy04h;
  always_ff @(posedge reference_core_clk) begin
    dd_cy04h <= x_cy03h;
    ee_cy04h <= en_cy03h;
  end
  reference_pttw u_w (.reference_core_clk, .ref_rst_r00h, .d_cy00h(dd_cy04h), .en_cy00h(ee_cy04h),
    .rd_cy02h(rd_cy02h));
  reference_pttr u_r (.reference_core_clk, .ref_rst_r00h, .rd_cy02h(rd_cy02h), .pw_cy01h(pw_cy01h),
    .wr_cy01h(en_cy03h), .o_cy02h(o_cy02h));
endmodule

`undef CCV_CLK
`undef CCV_RST
