//===-- bad_module_names.sv - lint fixture for the module namespace -----===//
//
// Spec: docs/rtl-coding-style.md, Module names
//
// Every module here is refused BY NAME: tools/check-1d.sh looks for each
// one's finding under its own rule, so a shape the lint stopped refusing is
// named rather than lost among the others. Each module is judged by its own
// name (OI-37). The compliant shapes are rtl/lint/ccv_reference.sv (block
// top), ccv_reference_w.sv (wrapper), reference_gated_enable.sv (sub-block)
// and reference_common_*.sv (common modules), which must stay silent.
//
// DO NOT FIX THE VIOLATIONS IN THIS FILE.
//===----------------------------------------------------------------------===//

// -- CCV-L28: names in no shape ------------------------------------------

// No ccv_ prefix and no block's: nothing says what it is.
module widget (input logic a, output logic b);
  assign b = a;
endmodule

// ccv_<x> where x is no block in params/blocks.json.
module ccv_nosuch (input logic a, output logic b);
  assign b = a;
endmodule

// A wrapper of a block that does not exist.
module ccv_nosuch_w (input logic a, output logic b);
  assign b = a;
endmodule

// A sub-block spelled as though it were a block's top: ccv_<block>_ takes
// only a wrapper's _w after it.
module ccv_reference_pick (input logic a, output logic b);
  assign b = a;
endmodule

// A common module without its type, globally and within a block.
module ccv_common (input logic a, output logic b);
  assign b = a;
endmodule

module reference_common (input logic a, output logic b);
  assign b = a;
endmodule

// -- CCV-L22: the gate where the shape says it is not --------------------

// A block top with sequential logic and no gate.
module ccv_reference (
  input  logic       core_clk,
  input  logic       ref_rst_r00h,
  input  logic [3:0] in_data_cy00h,
  output logic [3:0] out_a_cy01h
);
  logic reference_core_clk;
  assign reference_core_clk = core_clk;
  always_ff @(posedge reference_core_clk) begin
    if (ref_rst_r00h) out_a_cy01h <= '0;
    else              out_a_cy01h <= in_data_cy00h;
  end
endmodule

// The core top is a block top in this respect: logic in it gates too.
module ccv_top (
  input  logic       core_clk,
  input  logic [3:0] in_data_cy00h,
  output logic [3:0] out_a_cy01h
);
  always_ff @(posedge core_clk) out_a_cy01h <= in_data_cy00h;
endmodule

// A wrapper with a gate of its own: the block inside it gates.
module ccv_reference_w (
  input  logic core_clk,
  input  logic ref_rst_r00h,
  output logic wrap_core_clk
);
  ccv_common_clk u_cg (
    .clk(core_clk), .rst_n(!ref_rst_r00h), .quiesced(1'b0), .stalled(1'b0),
    .hyst_quiesce(6'd8), .hyst_stall(6'd16), .wake(1'b0), .cg_override(1'b1),
    .te(1'b0), .gclk(wrap_core_clk), .gated());
endmodule

// A sub-block that gates its block's clock again.
module reference_gated (
  input  logic reference_core_clk,
  input  logic ref_rst_r00h,
  output logic inner_core_clk
);
  ccv_common_clk u_cg (
    .clk(reference_core_clk), .rst_n(!ref_rst_r00h), .quiesced(1'b0),
    .stalled(1'b0), .hyst_quiesce(6'd8), .hyst_stall(6'd16), .wake(1'b0),
    .cg_override(1'b1), .te(1'b0), .gclk(inner_core_clk), .gated());
endmodule

// A sub-block on the ungated clock: it escapes the block's gate.
module reference_ungated (
  input  logic       core_clk,
  input  logic [3:0] in_data_cy00h,
  output logic [3:0] out_a_cy01h
);
  always_ff @(posedge core_clk) out_a_cy01h <= in_data_cy00h;
endmodule

// A sub-block on another block's gated clock: a crossing nobody declared.
module reference_borrowed (
  input  logic       ooe_core_clk,
  input  logic [3:0] in_data_cy00h,
  output logic [3:0] out_a_cy01h
);
  always_ff @(posedge ooe_core_clk) out_a_cy01h <= in_data_cy00h;
endmodule

// A common module with a gate inside it.
module ccv_common_rpt_gated (
  input  logic clk,
  input  logic rst,
  output logic gclk
);
  ccv_common_clk u_cg (
    .clk(clk), .rst_n(!rst), .quiesced(1'b0), .stalled(1'b0),
    .hyst_quiesce(6'd8), .hyst_stall(6'd16), .wake(1'b0), .cg_override(1'b1),
    .te(1'b0), .gclk(gclk), .gated());
endmodule
