// GENERATED FILE -- DO NOT EDIT.
//
// Produced by tools/gen-top.py from schema/interfaces.json and
// params/blocks.json. Edit a source and regenerate; tools/verify.sh fails if
// this file is stale.

`timescale 1ns/1ps
// Clock, reset and tie-offs for ccv_core_top. With stub blocks nothing
// moves; what this proves is that the whole top elaborates and runs
// in each simulator, with the checker bank attached under CCV_CHECK.
// The machine's real testbench is the C++ skeleton (sim/skel/).
module tb;
  logic core_clk = 1'b0, rst_n = 1'b0;
  logic [44:0] kill_ack, sleep_ok, csr_credit;
  logic [1484:0] csr_rsp;
  logic exb_ext_out_valid;
  logic [1224:0] exb_ext_out_payload;
  logic exb_ext_out_credit = '0;
`ifdef CCV_TRACE
  logic [63:0] exb_ext_out_tid;
`endif
  logic ext_exb_in_credit, ext_exb_in_stall;

  ccv_core_top u_top (
    .core_clk(core_clk),
    .rst_n(rst_n),
    .kill_valid(1'b0),
    .kill_warp_mask('0),
    .wake_req('0),
    .csr_req('0),
    .kill_ack(kill_ack),
    .sleep_ok(sleep_ok),
    .csr_rsp(csr_rsp),
    .csr_credit(csr_credit),
    .exb_ext_out_valid(exb_ext_out_valid),
    .exb_ext_out_payload(exb_ext_out_payload),
    .exb_ext_out_credit(exb_ext_out_credit),
    .exb_ext_out_stall('0),
    .ext_exb_in_valid('0),
    .ext_exb_in_payload('0),
    .ext_exb_in_credit(ext_exb_in_credit),
    .ext_exb_in_stall(ext_exb_in_stall)
`ifdef CCV_TRACE
    , .exb_ext_out_tid(exb_ext_out_tid),
      .ext_exb_in_tid('0)
`endif
  );

  always #5 core_clk = ~core_clk;
  initial begin
    repeat (3) @(posedge core_clk);
    rst_n = 1'b1;
    // +phantom: a credit returned to the core for nothing it sent.
    // The negative control for the checker bank INSIDE the SV top --
    // with stub blocks, a quiet run looks the same whether the bank
    // is connected or not.
    if ($test$plusargs("phantom")) begin
      repeat (4) @(posedge core_clk);
      #1 exb_ext_out_credit = '1;
      @(posedge core_clk);
      #1 exb_ext_out_credit = '0;
    end
    repeat (50) @(posedge core_clk);
    if (exb_ext_out_valid !== '0) $display("TOP_UNEXPECTED_TRAFFIC");
    $display("TOP_OK");
    $finish;
  end
endmodule
