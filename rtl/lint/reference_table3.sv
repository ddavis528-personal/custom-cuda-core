//===-- reference_table3.sv - a row-register two-writer table, compliant ---===//
//
// Spec: docs/rtl-coding-style.md, CCV-L23 (declared table, two writers, row
//       registers; OA-479 (b), DI-51)
//
// dcu_bctl's fold table as written: 8 row registers, each written in a
// generate block under a compare of the port's tagged row with its number,
// and read by a loop selecting the row by the same compare, its tagged side
// at the reader's stage. The lookup's enable is a net, pw_cy02h, reaching
// the rows through the generate block. Each row's next value reads the row
// itself, its compare in the sibling write enable.
// tools/check-1d.sh fails if ANY finding is reported here.
//===----------------------------------------------------------------------===//

`define CCV_CLK reference_core_clk
`define CCV_RST ref_rst_r00h

module reference_table3 (
  input  logic       reference_core_clk,
  input  logic       ref_rst_r00h,
  input  logic       lv_in_cy01h,
  input  logic [2:0] li_in_cy01h,
  input  logic       fe_in_cy03h,
  input  logic [2:0] fi_in_cy03h,
  input  logic [5:0] fd_in_cy03h,
  output logic [5:0] rd_out_cy03h
);
  logic       lv_cy02h;
  logic [2:0] li_cy02h;
  logic [2:0] li_cy01h;
  always_ff @(posedge reference_core_clk) begin
    if (ref_rst_r00h) lv_cy02h <= 1'b0;
    else              lv_cy02h <= lv_in_cy01h;
    li_cy01h <= li_in_cy01h;
    li_cy02h <= li_cy01h;
  end
  logic       fe_cy04h;
  logic [2:0] fi_cy04h;
  logic [5:0] fd_cy04h;
  always_ff @(posedge reference_core_clk) begin
    if (ref_rst_r00h) fe_cy04h <= 1'b0;
    else              fe_cy04h <= fe_in_cy03h;
    fi_cy04h <= fi_in_cy03h;
    fd_cy04h <= fd_in_cy03h;
  end

  // Row registers; the lookup selects its row by a one-hot compare.
  logic [5:0] tab_cy03h [8];
  logic [5:0] rd_cy02h;
  always_comb begin
    rd_cy02h = 6'd0;
    for (int r = 0; r < 8; r++) begin
      if (li_cy02h == 3'(r)) rd_cy02h = rd_cy02h | tab_cy03h[r];
    end
  end

  // The write port: the lookup writes unless the fill has it (it then waits).
  logic       pw_cy02h;
  logic [2:0] pi_cy02h;
  assign pw_cy02h = lv_cy02h & ~fe_cy04h;
  assign pi_cy02h = fe_cy04h ? fi_cy04h : li_cy02h;
  // Each row's own read-modify-write: the row's next value reads the row,
  // its compare in the sibling enable (DI-53).
  for (genvar r = 0; r < 8; r++) begin : g_tab
    logic       ren_cy02h;
    logic [5:0] rn_cy02h;
    assign ren_cy02h = (pw_cy02h | fe_cy04h) && pi_cy02h == 3'(r);
    assign rn_cy02h  = fe_cy04h ? fd_cy04h : tab_cy03h[r] + 6'd1;
    always_ff @(posedge reference_core_clk) begin
      if (ren_cy02h) tab_cy03h[r] <= rn_cy02h;
    end
  end
  always_ff @(posedge reference_core_clk) rd_out_cy03h <= rd_cy02h;

  logic       fe_cy05h;
  logic [2:0] fi_cy05h;
  always_ff @(posedge reference_core_clk) begin
    if (ref_rst_r00h) fe_cy05h <= 1'b0;
    else              fe_cy05h <= fe_cy04h;
    fi_cy05h <= fi_cy04h;
  end
  `CCV_ASSERT(tab_one_writer, !(pw_cy02h && fe_cy04h))
  `CCV_ASSERT(tab_margin, !((fe_cy04h && fi_cy04h == li_cy02h) || (fe_cy05h && fi_cy05h == li_cy02h)))
endmodule

`undef CCV_CLK
`undef CCV_RST
