//===-- reference_ttp.sv - a table writer fed from later registers, compliant ---===//
//
// Spec: docs/rtl-coding-style.md, CCV-L23 across a connection (OI-217)
//
// u_map and u_dep's shape (OI-217): u_w's input d_cy01h is fed from the
// parent's dd_cy04h, three stages past, and reaches u_w's output only
// through its table register tab_cy02h, which u_r reads as a declared table
// (reference_ttr.feedback.json). The back edge at u_w's input is the
// table's write, excused by the verified table.
// tools/check-1d.sh fails if ANY finding is reported here.
//===----------------------------------------------------------------------===//

`define CCV_CLK reference_core_clk
`define CCV_RST ref_rst_r00h

module reference_ttp (
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
  reference_ttw u_w (.reference_core_clk, .ref_rst_r00h, .d_cy01h(dd_cy04h), .en_cy01h(ee_cy04h),
    .rd_cy02h(rd_cy02h));
  reference_ttr u_r (.reference_core_clk, .ref_rst_r00h, .rd_cy02h(rd_cy02h), .pw_cy01h(pw_cy01h),
    .wr_cy01h(en_cy03h), .o_cy02h(o_cy02h));
endmodule

`undef CCV_CLK
`undef CCV_RST
