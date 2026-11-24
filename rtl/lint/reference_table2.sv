//===-- reference_table2.sv - a two-writer declared table, compliant ---===//
//
// Spec: docs/rtl-coding-style.md, CCV-L23 (declared table, two writers;
//       OA-479 (b), Daniel 2026-11-24)
//
// dcu_bctl's fold-table shape: an 8-word table tagged 03, written by a
// lookup's read-modify-write at stage 02 (the loop writer, its back edge the
// table's own read) and by a fill at stage 04 muxed into the same port. The
// declaration lists both writers with their stages; the port's nets read
// the fill's registers, and the module asserts no write conflict and no
// lookup of a word the fill wrote that cycle or the next.
// tools/check-1d.sh fails if ANY finding is reported here.
//===----------------------------------------------------------------------===//

`define CCV_CLK reference_core_clk
`define CCV_RST ref_rst_r00h

module reference_table2 (
  input  logic       reference_core_clk,
  input  logic       ref_rst_r00h,
  input  logic       le_in_cy01h,
  input  logic [2:0] li_in_cy01h,
  input  logic       fe_in_cy03h,
  input  logic [2:0] fi_in_cy03h,
  input  logic [5:0] fd_in_cy03h,
  output logic [5:0] rd_out_cy03h
);
  // The loop writer: a lookup at stage 02 reads the word and writes it back,
  // plus one, at the same port (its back edge is the table's own read).
  logic       le_cy02h;
  logic [2:0] li_cy02h;
  always_ff @(posedge reference_core_clk) begin
    if (ref_rst_r00h) le_cy02h <= 1'b0;
    else              le_cy02h <= le_in_cy01h;
    li_cy02h <= li_in_cy01h;
  end
  // A later writer from another pipeline: a fill at stage 04, its data,
  // index and enable its own registers, muxed into the same port.
  logic       fe_cy04h;
  logic [2:0] fi_cy04h;
  logic [5:0] fd_cy04h;
  always_ff @(posedge reference_core_clk) begin
    if (ref_rst_r00h) fe_cy04h <= 1'b0;
    else              fe_cy04h <= fe_in_cy03h;
    fi_cy04h <= fi_in_cy03h;
    fd_cy04h <= fd_in_cy03h;
  end

  logic [5:0] tab_cy03h [8];
  logic [5:0] rd_cy02h;
  assign rd_cy02h = tab_cy03h[li_cy02h];

  // The write port.
  logic       pe_cy02h;
  logic [2:0] pi_cy02h;
  logic [5:0] pd_cy02h;
  assign pe_cy02h = le_cy02h | fe_cy04h;
  assign pi_cy02h = fe_cy04h ? fi_cy04h : li_cy02h;
  assign pd_cy02h = fe_cy04h ? fd_cy04h : rd_cy02h + 6'd1;
  always_ff @(posedge reference_core_clk) begin
    if (pe_cy02h) tab_cy03h[pi_cy02h] <= pd_cy02h;
  end
  always_ff @(posedge reference_core_clk) rd_out_cy03h <= rd_cy02h;

  // No write conflict at the port; no lookup reads a word the fill wrote in
  // that cycle or the next.
  logic       fe_cy05h;
  logic [2:0] fi_cy05h;
  always_ff @(posedge reference_core_clk) begin
    if (ref_rst_r00h) fe_cy05h <= 1'b0;
    else              fe_cy05h <= fe_cy04h;
    fi_cy05h <= fi_cy04h;
  end
  `CCV_ASSERT(tab_one_writer, !(le_cy02h && fe_cy04h))
  `CCV_ASSERT(tab_margin, !((fe_cy04h && fi_cy04h == li_cy02h) || (fe_cy05h && fi_cy05h == li_cy02h)))
endmodule

`undef CCV_CLK
`undef CCV_RST
