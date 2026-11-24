//===-- bad_table3.sv - lint fixture for row-register tables ---===//
//
// Spec: docs/rtl-coding-style.md, CCV-L23 (declared table, two writers, row
//       registers; OA-479 (b), DI-51)
//
// Every violation is intentional. tools/check-1d.sh fails if any stops
// firing here. DO NOT FIX THE VIOLATIONS IN THIS FILE.
//
// reference_t3misidx is reference_table3.sv with its lookup's row compare
// made on the index a stage early (li_cy01h), not at the reader's stage;
// reference_t3noloop's declaration leaves out the rows' own read (rn_cy02h),
// so no listed reader feeds the loop writer.
//===----------------------------------------------------------------------===//

`define CCV_CLK reference_core_clk
`define CCV_RST ref_rst_r00h

module reference_t3misidx (
  input  logic       reference_core_clk,
  input  logic       ref_rst_r00h,
  input  logic       mlv_in_cy01h,
  input  logic [2:0] mli_in_cy01h,
  input  logic       mfe_in_cy03h,
  input  logic [2:0] mfi_in_cy03h,
  input  logic [5:0] mfd_in_cy03h,
  output logic [5:0] mrd_out_cy03h
);
  logic       mlv_cy02h;
  logic [2:0] mli_cy02h;
  logic [2:0] mli_cy01h;
  always_ff @(posedge reference_core_clk) begin
    if (ref_rst_r00h) mlv_cy02h <= 1'b0;
    else              mlv_cy02h <= mlv_in_cy01h;
    mli_cy01h <= mli_in_cy01h;
    mli_cy02h <= mli_cy01h;
  end
  logic       mfe_cy04h;
  logic [2:0] mfi_cy04h;
  logic [5:0] mfd_cy04h;
  always_ff @(posedge reference_core_clk) begin
    if (ref_rst_r00h) mfe_cy04h <= 1'b0;
    else              mfe_cy04h <= mfe_in_cy03h;
    mfi_cy04h <= mfi_in_cy03h;
    mfd_cy04h <= mfd_in_cy03h;
  end

  // Row registers; the lookup selects its row by a one-hot compare.
  logic [5:0] mtab_cy03h [8];
  logic [5:0] mrd_cy02h;
  always_comb begin
    mrd_cy02h = 6'd0;
    for (int r = 0; r < 8; r++) begin
      if (mli_cy01h == 3'(r)) mrd_cy02h = mrd_cy02h | mtab_cy03h[r];
    end
  end

  // The write port: the lookup writes unless the fill has it (it then waits).
  logic       mpw_cy02h;
  logic [2:0] mpi_cy02h;
  assign mpw_cy02h = mlv_cy02h & ~mfe_cy04h;
  assign mpi_cy02h = mfe_cy04h ? mfi_cy04h : mli_cy02h;
  // Each row's own read-modify-write: the row's next value reads the row,
  // its compare in the sibling enable (DI-53).
  for (genvar r = 0; r < 8; r++) begin : g_tab
    logic       mren_cy02h;
    logic [5:0] mrn_cy02h;
    assign mren_cy02h = (mpw_cy02h | mfe_cy04h) && mpi_cy02h == 3'(r);
    assign mrn_cy02h  = mfe_cy04h ? mfd_cy04h : mtab_cy03h[r] + 6'd1;
    always_ff @(posedge reference_core_clk) begin
      if (mren_cy02h) mtab_cy03h[r] <= mrn_cy02h;
    end
  end
  always_ff @(posedge reference_core_clk) mrd_out_cy03h <= mrd_cy02h;

  logic       mfe_cy05h;
  logic [2:0] mfi_cy05h;
  always_ff @(posedge reference_core_clk) begin
    if (ref_rst_r00h) mfe_cy05h <= 1'b0;
    else              mfe_cy05h <= mfe_cy04h;
    mfi_cy05h <= mfi_cy04h;
  end
  `CCV_ASSERT(mtab_one_writer, !(mpw_cy02h && mfe_cy04h))
  `CCV_ASSERT(mtab_margin, !((mfe_cy04h && mfi_cy04h == mli_cy02h) || (mfe_cy05h && mfi_cy05h == mli_cy02h)))
endmodule

module reference_t3noloop (
  input  logic       reference_core_clk,
  input  logic       ref_rst_r00h,
  input  logic       olv_in_cy01h,
  input  logic [2:0] oli_in_cy01h,
  input  logic       ofe_in_cy03h,
  input  logic [2:0] ofi_in_cy03h,
  input  logic [5:0] ofd_in_cy03h,
  output logic [5:0] ord_out_cy03h
);
  logic       olv_cy02h;
  logic [2:0] oli_cy02h;
  logic [2:0] oli_cy01h;
  always_ff @(posedge reference_core_clk) begin
    if (ref_rst_r00h) olv_cy02h <= 1'b0;
    else              olv_cy02h <= olv_in_cy01h;
    oli_cy01h <= oli_in_cy01h;
    oli_cy02h <= oli_cy01h;
  end
  logic       ofe_cy04h;
  logic [2:0] ofi_cy04h;
  logic [5:0] ofd_cy04h;
  always_ff @(posedge reference_core_clk) begin
    if (ref_rst_r00h) ofe_cy04h <= 1'b0;
    else              ofe_cy04h <= ofe_in_cy03h;
    ofi_cy04h <= ofi_in_cy03h;
    ofd_cy04h <= ofd_in_cy03h;
  end

  // Row registers; the lookup selects its row by a one-hot compare.
  logic [5:0] otab_cy03h [8];
  logic [5:0] ord_cy02h;
  always_comb begin
    ord_cy02h = 6'd0;
    for (int r = 0; r < 8; r++) begin
      if (oli_cy02h == 3'(r)) ord_cy02h = ord_cy02h | otab_cy03h[r];
    end
  end

  // The write port: the lookup writes unless the fill has it (it then waits).
  logic       opw_cy02h;
  logic [2:0] opi_cy02h;
  assign opw_cy02h = olv_cy02h & ~ofe_cy04h;
  assign opi_cy02h = ofe_cy04h ? ofi_cy04h : oli_cy02h;
  // Each row's own read-modify-write: the row's next value reads the row,
  // its compare in the sibling enable (DI-53).
  for (genvar r = 0; r < 8; r++) begin : g_tab
    logic       oren_cy02h;
    logic [5:0] orn_cy02h;
    assign oren_cy02h = (opw_cy02h | ofe_cy04h) && opi_cy02h == 3'(r);
    assign orn_cy02h  = ofe_cy04h ? ofd_cy04h : otab_cy03h[r] + 6'd1;
    always_ff @(posedge reference_core_clk) begin
      if (oren_cy02h) otab_cy03h[r] <= orn_cy02h;
    end
  end
  always_ff @(posedge reference_core_clk) ord_out_cy03h <= ord_cy02h;

  logic       ofe_cy05h;
  logic [2:0] ofi_cy05h;
  always_ff @(posedge reference_core_clk) begin
    if (ref_rst_r00h) ofe_cy05h <= 1'b0;
    else              ofe_cy05h <= ofe_cy04h;
    ofi_cy05h <= ofi_cy04h;
  end
  `CCV_ASSERT(otab_one_writer, !(opw_cy02h && ofe_cy04h))
  `CCV_ASSERT(otab_margin, !((ofe_cy04h && ofi_cy04h == oli_cy02h) || (ofe_cy05h && ofi_cy05h == oli_cy02h)))
endmodule

`undef CCV_CLK
`undef CCV_RST
