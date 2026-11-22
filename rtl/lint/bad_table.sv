//===-- bad_table.sv - lint fixture for declared tables ----------------===//
//
// Spec: docs/rtl-coding-style.md, CCV-L23 (declared table; DA rev 131,
//       OA 452's seven conditions)
//
// Every violation is intentional. tools/check-1d.sh fails if any stops
// firing here. DO NOT FIX THE VIOLATIONS IN THIS FILE.
//
// Each module is reference_table.sv's ooe_ratmap shape with one condition
// broken, declared in its own <module>.feedback.json, its nets prefixed by
// a letter of its own (the lint reads a file's nets as one graph):
// reference_tscalar declares a plain register (2); reference_tmisidx reads
// through an index a stage before its reader's (4); reference_tbadtag's
// array is tagged a stage past its writer's (3); reference_tnoread lists a
// reader that does not read it (1); reference_tbyoi is declared by OI, not
// an architect (1); reference_tnoassert holds no assertion (5).
// reference_tundecl is the shape with no declaration: the arithmetic
// refuses its read, as it would ooe_ratmap's.
//===----------------------------------------------------------------------===//

`define CCV_CLK reference_core_clk
`define CCV_RST ref_rst_r00h

module reference_tscalar (
  input  logic       reference_core_clk,
  input  logic       ref_rst_r00h,
  input  logic       swe_in_cy02h,
  input  logic [4:0] swi_in_cy02h,
  input  logic [5:0] swd_in_cy02h,
  input  logic [4:0] sri_in_cy00h,
  output logic [5:0] srd_out_cy02h
);
  logic       swe_cy03h;
  logic [4:0] swi_cy03h;
  logic [5:0] swd_cy03h;
  always_ff @(posedge reference_core_clk) begin
    if (ref_rst_r00h) swe_cy03h <= 1'b0;
    else              swe_cy03h <= swe_in_cy02h;
    swi_cy03h <= swi_in_cy02h;
    swd_cy03h <= swd_in_cy02h;
  end

  logic [5:0] spark_cy04h;
  always_ff @(posedge reference_core_clk) begin
    if (swe_cy03h) spark_cy04h <= swd_cy03h;
  end

  logic [4:0] sri_cy01h;
  always_ff @(posedge reference_core_clk) sri_cy01h <= sri_in_cy00h;
  logic [5:0] srd_cy01h;
  assign srd_cy01h = spark_cy04h;
  always_ff @(posedge reference_core_clk) srd_out_cy02h <= srd_cy01h;

  // A word is never read in its write cycle or the next: a same-cycle
  // forward would be a bypass, declared as one.
  logic       swe_cy04h;
  logic [4:0] swi_cy04h;
  always_ff @(posedge reference_core_clk) begin
    if (ref_rst_r00h) swe_cy04h <= 1'b0;
    else              swe_cy04h <= swe_cy03h;
    swi_cy04h <= swi_cy03h;
  end
  `CCV_ASSERT(spark_no_rd_at_wr, !((swe_cy03h && swi_cy03h == sri_cy01h) || (swe_cy04h && swi_cy04h == sri_cy01h)))
endmodule

module reference_tmisidx (
  input  logic       reference_core_clk,
  input  logic       ref_rst_r00h,
  input  logic       mwe_in_cy02h,
  input  logic [4:0] mwi_in_cy02h,
  input  logic [5:0] mwd_in_cy02h,
  input  logic [4:0] mri_in_cy00h,
  output logic [5:0] mrd_out_cy02h
);
  logic       mwe_cy03h;
  logic [4:0] mwi_cy03h;
  logic [5:0] mwd_cy03h;
  always_ff @(posedge reference_core_clk) begin
    if (ref_rst_r00h) mwe_cy03h <= 1'b0;
    else              mwe_cy03h <= mwe_in_cy02h;
    mwi_cy03h <= mwi_in_cy02h;
    mwd_cy03h <= mwd_in_cy02h;
  end

  logic [5:0] mpark_cy04h [32];
  always_ff @(posedge reference_core_clk) begin
    if (mwe_cy03h) mpark_cy04h[mwi_cy03h] <= mwd_cy03h;
  end

  logic [4:0] mri_cy01h;
  always_ff @(posedge reference_core_clk) mri_cy01h <= mri_in_cy00h;
  logic [5:0] mrd_cy01h;
  assign mrd_cy01h = mpark_cy04h[mri_in_cy00h];
  always_ff @(posedge reference_core_clk) mrd_out_cy02h <= mrd_cy01h;

  // A word is never read in its write cycle or the next: a same-cycle
  // forward would be a bypass, declared as one.
  logic       mwe_cy04h;
  logic [4:0] mwi_cy04h;
  always_ff @(posedge reference_core_clk) begin
    if (ref_rst_r00h) mwe_cy04h <= 1'b0;
    else              mwe_cy04h <= mwe_cy03h;
    mwi_cy04h <= mwi_cy03h;
  end
  `CCV_ASSERT(mpark_no_rd_at_wr, !((mwe_cy03h && mwi_cy03h == mri_cy01h) || (mwe_cy04h && mwi_cy04h == mri_cy01h)))
endmodule

module reference_tbadtag (
  input  logic       reference_core_clk,
  input  logic       ref_rst_r00h,
  input  logic       bwe_in_cy02h,
  input  logic [4:0] bwi_in_cy02h,
  input  logic [5:0] bwd_in_cy02h,
  input  logic [4:0] bri_in_cy00h,
  output logic [5:0] brd_out_cy02h
);
  logic       bwe_cy03h;
  logic [4:0] bwi_cy03h;
  logic [5:0] bwd_cy03h;
  always_ff @(posedge reference_core_clk) begin
    if (ref_rst_r00h) bwe_cy03h <= 1'b0;
    else              bwe_cy03h <= bwe_in_cy02h;
    bwi_cy03h <= bwi_in_cy02h;
    bwd_cy03h <= bwd_in_cy02h;
  end

  logic [5:0] bpark_cy05h [32];
  always_ff @(posedge reference_core_clk) begin
    if (bwe_cy03h) bpark_cy05h[bwi_cy03h] <= bwd_cy03h;
  end

  logic [4:0] bri_cy01h;
  always_ff @(posedge reference_core_clk) bri_cy01h <= bri_in_cy00h;
  logic [5:0] brd_cy01h;
  assign brd_cy01h = bpark_cy05h[bri_cy01h];
  always_ff @(posedge reference_core_clk) brd_out_cy02h <= brd_cy01h;

  // A word is never read in its write cycle or the next: a same-cycle
  // forward would be a bypass, declared as one.
  logic       bwe_cy04h;
  logic [4:0] bwi_cy04h;
  always_ff @(posedge reference_core_clk) begin
    if (ref_rst_r00h) bwe_cy04h <= 1'b0;
    else              bwe_cy04h <= bwe_cy03h;
    bwi_cy04h <= bwi_cy03h;
  end
  `CCV_ASSERT(bpark_no_rd_at_wr, !((bwe_cy03h && bwi_cy03h == bri_cy01h) || (bwe_cy04h && bwi_cy04h == bri_cy01h)))
endmodule

module reference_tnoread (
  input  logic       reference_core_clk,
  input  logic       ref_rst_r00h,
  input  logic       nwe_in_cy02h,
  input  logic [4:0] nwi_in_cy02h,
  input  logic [5:0] nwd_in_cy02h,
  input  logic [4:0] nri_in_cy00h,
  output logic [5:0] nrd_out_cy02h
);
  logic       nwe_cy03h;
  logic [4:0] nwi_cy03h;
  logic [5:0] nwd_cy03h;
  always_ff @(posedge reference_core_clk) begin
    if (ref_rst_r00h) nwe_cy03h <= 1'b0;
    else              nwe_cy03h <= nwe_in_cy02h;
    nwi_cy03h <= nwi_in_cy02h;
    nwd_cy03h <= nwd_in_cy02h;
  end

  logic [5:0] npark_cy04h [32];
  always_ff @(posedge reference_core_clk) begin
    if (nwe_cy03h) npark_cy04h[nwi_cy03h] <= nwd_cy03h;
  end

  logic [4:0] nri_cy01h;
  always_ff @(posedge reference_core_clk) nri_cy01h <= nri_in_cy00h;
  logic [5:0] nrd_cy01h;
  assign nrd_cy01h = npark_cy04h[nri_cy01h];
  always_ff @(posedge reference_core_clk) nrd_out_cy02h <= nrd_cy01h;

  // A word is never read in its write cycle or the next: a same-cycle
  // forward would be a bypass, declared as one.
  logic       nwe_cy04h;
  logic [4:0] nwi_cy04h;
  always_ff @(posedge reference_core_clk) begin
    if (ref_rst_r00h) nwe_cy04h <= 1'b0;
    else              nwe_cy04h <= nwe_cy03h;
    nwi_cy04h <= nwi_cy03h;
  end
  `CCV_ASSERT(npark_no_rd_at_wr, !((nwe_cy03h && nwi_cy03h == nri_cy01h) || (nwe_cy04h && nwi_cy04h == nri_cy01h)))
endmodule

module reference_tbyoi (
  input  logic       reference_core_clk,
  input  logic       ref_rst_r00h,
  input  logic       owe_in_cy02h,
  input  logic [4:0] owi_in_cy02h,
  input  logic [5:0] owd_in_cy02h,
  input  logic [4:0] ori_in_cy00h,
  output logic [5:0] ord_out_cy02h
);
  logic       owe_cy03h;
  logic [4:0] owi_cy03h;
  logic [5:0] owd_cy03h;
  always_ff @(posedge reference_core_clk) begin
    if (ref_rst_r00h) owe_cy03h <= 1'b0;
    else              owe_cy03h <= owe_in_cy02h;
    owi_cy03h <= owi_in_cy02h;
    owd_cy03h <= owd_in_cy02h;
  end

  logic [5:0] opark_cy04h [32];
  always_ff @(posedge reference_core_clk) begin
    if (owe_cy03h) opark_cy04h[owi_cy03h] <= owd_cy03h;
  end

  logic [4:0] ori_cy01h;
  always_ff @(posedge reference_core_clk) ori_cy01h <= ori_in_cy00h;
  logic [5:0] ord_cy01h;
  assign ord_cy01h = opark_cy04h[ori_cy01h];
  always_ff @(posedge reference_core_clk) ord_out_cy02h <= ord_cy01h;

  // A word is never read in its write cycle or the next: a same-cycle
  // forward would be a bypass, declared as one.
  logic       owe_cy04h;
  logic [4:0] owi_cy04h;
  always_ff @(posedge reference_core_clk) begin
    if (ref_rst_r00h) owe_cy04h <= 1'b0;
    else              owe_cy04h <= owe_cy03h;
    owi_cy04h <= owi_cy03h;
  end
  `CCV_ASSERT(opark_no_rd_at_wr, !((owe_cy03h && owi_cy03h == ori_cy01h) || (owe_cy04h && owi_cy04h == ori_cy01h)))
endmodule

module reference_tnoassert (
  input  logic       reference_core_clk,
  input  logic       ref_rst_r00h,
  input  logic       awe_in_cy02h,
  input  logic [4:0] awi_in_cy02h,
  input  logic [5:0] awd_in_cy02h,
  input  logic [4:0] ari_in_cy00h,
  output logic [5:0] ard_out_cy02h
);
  logic       awe_cy03h;
  logic [4:0] awi_cy03h;
  logic [5:0] awd_cy03h;
  always_ff @(posedge reference_core_clk) begin
    if (ref_rst_r00h) awe_cy03h <= 1'b0;
    else              awe_cy03h <= awe_in_cy02h;
    awi_cy03h <= awi_in_cy02h;
    awd_cy03h <= awd_in_cy02h;
  end

  logic [5:0] apark_cy04h [32];
  always_ff @(posedge reference_core_clk) begin
    if (awe_cy03h) apark_cy04h[awi_cy03h] <= awd_cy03h;
  end

  logic [4:0] ari_cy01h;
  always_ff @(posedge reference_core_clk) ari_cy01h <= ari_in_cy00h;
  logic [5:0] ard_cy01h;
  assign ard_cy01h = apark_cy04h[ari_cy01h];
  always_ff @(posedge reference_core_clk) ard_out_cy02h <= ard_cy01h;

endmodule

module reference_tundecl (
  input  logic       reference_core_clk,
  input  logic       ref_rst_r00h,
  input  logic       uwe_in_cy02h,
  input  logic [4:0] uwi_in_cy02h,
  input  logic [5:0] uwd_in_cy02h,
  input  logic [4:0] uri_in_cy00h,
  output logic [5:0] urd_out_cy02h
);
  logic       uwe_cy03h;
  logic [4:0] uwi_cy03h;
  logic [5:0] uwd_cy03h;
  always_ff @(posedge reference_core_clk) begin
    if (ref_rst_r00h) uwe_cy03h <= 1'b0;
    else              uwe_cy03h <= uwe_in_cy02h;
    uwi_cy03h <= uwi_in_cy02h;
    uwd_cy03h <= uwd_in_cy02h;
  end

  logic [5:0] upark_cy04h [32];
  always_ff @(posedge reference_core_clk) begin
    if (uwe_cy03h) upark_cy04h[uwi_cy03h] <= uwd_cy03h;
  end

  logic [4:0] uri_cy01h;
  always_ff @(posedge reference_core_clk) uri_cy01h <= uri_in_cy00h;
  logic [5:0] urd_cy01h;
  assign urd_cy01h = upark_cy04h[uri_cy01h];
  always_ff @(posedge reference_core_clk) urd_out_cy02h <= urd_cy01h;

  // A word is never read in its write cycle or the next: a same-cycle
  // forward would be a bypass, declared as one.
  logic       uwe_cy04h;
  logic [4:0] uwi_cy04h;
  always_ff @(posedge reference_core_clk) begin
    if (ref_rst_r00h) uwe_cy04h <= 1'b0;
    else              uwe_cy04h <= uwe_cy03h;
    uwi_cy04h <= uwi_cy03h;
  end
  `CCV_ASSERT(upark_no_rd_at_wr, !((uwe_cy03h && uwi_cy03h == uri_cy01h) || (uwe_cy04h && uwi_cy04h == uri_cy01h)))
endmodule

`undef CCV_CLK
`undef CCV_RST
