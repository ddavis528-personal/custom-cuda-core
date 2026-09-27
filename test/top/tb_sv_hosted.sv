// GENERATED FILE -- DO NOT EDIT.
//
// Produced by tools/gen-top.py from schema/interfaces.json and
// params/blocks.json. Edit a source and regenerate; tools/verify.sh fails if
// this file is stale.

`timescale 1ns/1ps
// The SV-hosted run: ccv_core_top built from rtl/top/dpi/ shims, so
// every block is the C++ skeleton's and every connection between them
// is this top's Verilog. The kernel, trace and negative controls come
// in as plusargs the host reads (+ccv_oracle= +ccv_trace= +ccv_break=
// +ccv_shim_delay=<instance> +ccv_cycles=). Reset is low for the first
// two edges, as in the C++ skeleton's loop.
`include "ccv_interfaces.svh"
module tb;
  logic core_clk = 1'b0, rst_n = 1'b0;
  // The CSR owner's host side: idle, and nothing here reads it.
  /* verilator lint_off UNUSEDSIGNAL */
  logic [32:0] csr_rsp;
  logic csr_credit;
  /* verilator lint_on UNUSEDSIGNAL */
  logic exb_ext_out_valid;
  ccv_exb_ext_out_t exb_ext_out_payload;
  logic exb_ext_out_credit;
  logic exb_ext_out_stall;
  logic exb_ext_out_wake;
`ifdef CCV_TRACE
  logic [63:0] exb_ext_out_tid;
`endif
  logic ext_exb_in_valid;
  ccv_ext_exb_in_t ext_exb_in_payload;
  logic ext_exb_in_credit;
  logic ext_exb_in_stall;
  logic ext_exb_in_wake;
`ifdef CCV_TRACE
  logic [63:0] ext_exb_in_tid;
`endif

  ccv_core_top u_top (
    .core_clk(core_clk),
    .rst_n(rst_n),
    .csr_req('0),
    .csr_rsp(csr_rsp),
    .csr_credit(csr_credit),
    .exb_ext_out_valid(exb_ext_out_valid),
    .exb_ext_out_payload(exb_ext_out_payload),
    .exb_ext_out_credit(exb_ext_out_credit),
    .exb_ext_out_stall(exb_ext_out_stall),
    .exb_ext_out_wake(exb_ext_out_wake),
    .ext_exb_in_valid(ext_exb_in_valid),
    .ext_exb_in_payload(ext_exb_in_payload),
    .ext_exb_in_credit(ext_exb_in_credit),
    .ext_exb_in_stall(ext_exb_in_stall),
    .ext_exb_in_wake(ext_exb_in_wake)
`ifdef CCV_TRACE
    , .exb_ext_out_tid(exb_ext_out_tid),
      .ext_exb_in_tid(ext_exb_in_tid)
`endif
  );
  ccv_ext u_ext (
    .core_clk(core_clk),
    .rst_n(rst_n),
    .exb_ext_out_valid(exb_ext_out_valid),
    .exb_ext_out_payload(exb_ext_out_payload),
    .exb_ext_out_credit(exb_ext_out_credit),
    .exb_ext_out_stall(exb_ext_out_stall),
    .exb_ext_out_wake(exb_ext_out_wake),
    .ext_exb_in_valid(ext_exb_in_valid),
    .ext_exb_in_payload(ext_exb_in_payload),
    .ext_exb_in_credit(ext_exb_in_credit),
    .ext_exb_in_stall(ext_exb_in_stall),
    .ext_exb_in_wake(ext_exb_in_wake)
`ifdef CCV_TRACE
    , .exb_ext_out_tid(exb_ext_out_tid),
      .ext_exb_in_tid(ext_exb_in_tid)
`endif
  );

  import "DPI-C" context function bit ccv_dpi_done(input longint cyc);
  import "DPI-C" context function void ccv_dpi_report();
  initial forever #5 core_clk = ~core_clk;
  // Off the edge, so no block samples it mid-change.
  initial begin
    repeat (2) @(posedge core_clk);
    #1 rst_n = 1'b1;
  end
  // Between edges every block has run the cycle: ask whether it is over.
  longint c = 0;
  always @(negedge core_clk) begin
    if (ccv_dpi_done(c)) begin
      ccv_dpi_report();
      $finish;
    end
    c <= c + 1;
  end
endmodule
