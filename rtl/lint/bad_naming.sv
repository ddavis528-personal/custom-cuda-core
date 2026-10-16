//===-- bad_naming.sv - lint fixture for the net naming rules -----------===//
//
// Spec: docs/rtl-coding-style.md, net naming section
//
// Every violation is intentional. tools/check-1d.sh fails if any rule stops
// firing here. DO NOT FIX THE VIOLATIONS IN THIS FILE.
//
// The first module is block `reference`'s top by its name (OI-37), which
// is what its stage tags' block letter and the gate rules are read
// against. The others are counter-examples of their own rules, named in no
// shape, so CCV-L28 refuses them too.
//===----------------------------------------------------------------------===//

module ccv_reference (
  input  logic       core_clk,
  input  logic       bad_rst_r00h,
  input  logic [3:0] in_data_cy00h,
  output logic [3:0] out_a_cy04h,
  output logic [3:0] out_b_cy02h,
  output logic [3:0] out_c_cy03h,
  output logic [3:0] out_d_cy01h,
  output logic       out_e_cy01h_b
);

  // CCV-L19: not lower_snake_case.
  logic [3:0] BadCamelNet;

  // CCV-L22: clocks logic on the ungated core_clk. The block's global gate is
  // bypassed, the design still works, and nothing in simulation says so.
  always_ff @(posedge core_clk) begin
    if (bad_rst_r00h) out_a_cy04h <= '0;
    else              out_a_cy04h <= in_data_cy00h;   // CCV-L23 too: 00 -> 04
  end

  // CCV-L21: tagged edge `h` but generated on a negedge.
  always_ff @(negedge core_clk) begin
    out_b_cy02h <= in_data_cy00h;
  end

  // CCV-L21: block letter `z` is not registered in params/blocks.json.
  always_ff @(posedge core_clk) begin
    out_c_cy03h <= in_data_cy00h;
  end
  logic [3:0] stray_cz03h;
  always_ff @(posedge core_clk) begin
    stray_cz03h <= in_data_cy00h;
  end

  // CCV-L23: combinational logic does not advance a stage -- 00 in, 01 out.
  always_comb out_d_cy01h = in_data_cy00h + 4'd1;

  // CCV-L24: `_b` claims to be a complement but is driven without inversion.
  assign out_e_cy01h_b = in_data_cy00h[0];

  assign BadCamelNet = in_data_cy00h;

endmodule

// CCV-L20: a clock edge on a net that is not named as a clock, and a clock
// read as data. Both are how a clock ends up somewhere nobody expects it.
module bad_naming_clocks (
  input  logic       gclk,
  input  logic       core_clk,
  input  logic       ref_rst_r00h,
  input  logic [3:0] in_data_cy00h,
  output logic [3:0] out_f_cy01h,
  output logic [3:0] out_g_cy00h
);
  always_ff @(posedge gclk) begin
    out_f_cy01h <= in_data_cy00h;
  end
  assign out_g_cy00h = in_data_cy00h & {4{core_clk}};
endmodule

// CCV-L02: uses the assertion macros without naming its clock and reset, so
// the macros have nothing to expand to. A sibling failure is defining them
// and never `undef'ing, which lets the next file inherit this one's clock.
module bad_naming_nodefines (
  input  logic ref_core_clk,
  input  logic ref_rst_r00h,
  input  logic a_cy00h
);
  `CCV_ASSERT(bad_no_defines, a_cy00h == a_cy00h)
endmodule

// CCV-L25: a feedback mux inside always_ff. Synthesises identically today,
// but states "mux" where the design intends "gating candidate".
module bad_naming_feedback (
  input  logic       ref_core_clk,
  input  logic       ref_rst_r00h,
  input  logic       ld_en_cy00h,
  input  logic [7:0] in_data_cy00h,
  output logic [7:0] out_h_cy01h
);
  always_ff @(posedge ref_core_clk) begin
    out_h_cy01h <= ld_en_cy00h ? in_data_cy00h : out_h_cy01h;
  end
endmodule

// CCV-L27: a clock gate built by hand -- an AND, which glitches when its
// enable moves while the clock is high -- and a latch, outside rtl/ctech/.
// Both belong to the ctech ICG, reached through ccv_common_clk. The name is
// the third violation: a ccv_common_ctech_<cell> is a ctech cell, and only
// a view in rtl/ctech/<view>/ may hold one.
module ccv_common_ctech_gates (
  input  logic       core_clk,
  input  logic       blk_en_cy00h,
  output logic       bad_core_clk,
  output logic       held_cy00h
);
  assign bad_core_clk = core_clk & blk_en_cy00h;
  always_latch begin
    if (blk_en_cy00h) held_cy00h = 1'b1;
  end
endmodule
