//===-- reference_table.sv - a declared table read, compliant ---------===//
//
// Spec: docs/rtl-coding-style.md, CCV-L23 (declared table; DA rev 131,
//       OA 452)
//
// ooe_ratmap's shape: a 32-word parked table, written at stage 04 (one past
// its writer's data, index and enable, at 03) and read long after through
// an index register at the reader's own stage, 01. Declared in
// reference_table.feedback.json, so the read counts at the reader's stage;
// the module asserts that a word is never read in the cycle it is written,
// nor the cycle after (the write is flopped).
// tools/check-1d.sh fails if ANY finding is reported here.
//===----------------------------------------------------------------------===//

`define CCV_CLK reference_core_clk
`define CCV_RST ref_rst_r00h

module reference_table (
  input  logic       reference_core_clk,
  input  logic       ref_rst_r00h,
  input  logic       we_in_cy02h,
  input  logic [4:0] wi_in_cy02h,
  input  logic [5:0] wd_in_cy02h,
  input  logic [4:0] ri_in_cy00h,
  output logic [5:0] rd_out_cy02h
);
  logic       we_cy03h;
  logic [4:0] wi_cy03h;
  logic [5:0] wd_cy03h;
  always_ff @(posedge reference_core_clk) begin
    if (ref_rst_r00h) we_cy03h <= 1'b0;
    else              we_cy03h <= we_in_cy02h;
    wi_cy03h <= wi_in_cy02h;
    wd_cy03h <= wd_in_cy02h;
  end

  logic [5:0] park_cy04h [32];
  always_ff @(posedge reference_core_clk) begin
    if (we_cy03h) park_cy04h[wi_cy03h] <= wd_cy03h;
  end

  logic [4:0] ri_cy01h;
  always_ff @(posedge reference_core_clk) ri_cy01h <= ri_in_cy00h;
  logic [5:0] rd_cy01h;
  assign rd_cy01h = park_cy04h[ri_cy01h];
  always_ff @(posedge reference_core_clk) rd_out_cy02h <= rd_cy01h;

  // A word is never read in its write cycle or the next: a same-cycle
  // forward would be a bypass, declared as one.
  logic       we_cy04h;
  logic [4:0] wi_cy04h;
  always_ff @(posedge reference_core_clk) begin
    if (ref_rst_r00h) we_cy04h <= 1'b0;
    else              we_cy04h <= we_cy03h;
    wi_cy04h <= wi_cy03h;
  end
  `CCV_ASSERT(park_no_rd_at_wr, !((we_cy03h && wi_cy03h == ri_cy01h) || (we_cy04h && wi_cy04h == ri_cy01h)))
endmodule

`undef CCV_CLK
`undef CCV_RST
