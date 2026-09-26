// GENERATED FILE -- DO NOT EDIT.
//
// Produced by tools/gen-top.py from schema/interfaces.json and
// params/blocks.json. Edit a source and regenerate; tools/verify.sh fails if
// this file is stale.

// SV-HOSTED C++ for ccv_dec: the C++ skeleton's functional stub, run through DPI-C
// by sim/skel/dpi_host.cpp. Same module name and port list as the
// stub in rtl/top/stubs/ and the real RTL to come, so any mix of the
// three is a file-list change; tools/check-sv-hosted.sh builds the top
// from these alone and requires the run the C++ skeleton produces.
//
// At each edge of its clock: sample every channel signal (2736 bits,
// first port at the LSB), let the C++ block run its cycle, register
// what it drove (1228 bits). Common-port outputs sit inactive, as in
// the stub. Simulation only, and only with the trace sideband: the
// C++ blocks carry trace identity on every message.
`include "ccv_interfaces.svh"

/* verilator lint_off UNUSEDSIGNAL */
module ccv_dec (
  `include "ccv_dec_ports.svh"
);
`ifndef CCV_TRACE
  // Refused at elaboration: without _tid there is no identity to carry.
  ccv_sv_hosted_needs_CCV_TRACE u_needs_trace ();
`else
  import "DPI-C" context function int ccv_dpi_register(input string path);
  import "DPI-C" function bit ccv_dpi_skew(input int h);
  import "DPI-C" context function void ccv_dpi_cycle_dec(
    input int h, input longint cyc, input bit rst,
    input bit [2735:0] sample, output bit [1227:0] drive);

  int h;
  bit skew;              // negative control: one extra register
  longint cyc = 0;
  bit [1227:0] drv, q, q2;
  initial begin
    h = ccv_dpi_register($sformatf("%m"));
    skew = ccv_dpi_skew(h);
  end
  always @(posedge clk) begin
    ccv_dpi_cycle_dec(h, cyc, !rst_n, {
      dec_ooe_uop_s5_tid, dec_ooe_uop_s4_tid, dec_ooe_uop_s3_tid,
      dec_ooe_uop_s2_tid, dec_ooe_uop_s1_tid, dec_ooe_uop_s0_tid,
      dec_ooe_uop_s5_stall, dec_ooe_uop_s5_credit, dec_ooe_uop_s5_payload,
      dec_ooe_uop_s5_valid, dec_ooe_uop_s4_stall, dec_ooe_uop_s4_credit,
      dec_ooe_uop_s4_payload, dec_ooe_uop_s4_valid, dec_ooe_uop_s3_stall,
      dec_ooe_uop_s3_credit, dec_ooe_uop_s3_payload, dec_ooe_uop_s3_valid,
      dec_ooe_uop_s2_stall, dec_ooe_uop_s2_credit, dec_ooe_uop_s2_payload,
      dec_ooe_uop_s2_valid, dec_ooe_uop_s1_stall, dec_ooe_uop_s1_credit,
      dec_ooe_uop_s1_payload, dec_ooe_uop_s1_valid, dec_ooe_uop_s0_stall,
      dec_ooe_uop_s0_credit, dec_ooe_uop_s0_payload, dec_ooe_uop_s0_valid,
      fet_dec_instr_s7_tid, fet_dec_instr_s6_tid, fet_dec_instr_s5_tid,
      fet_dec_instr_s4_tid, fet_dec_instr_s3_tid, fet_dec_instr_s2_tid,
      fet_dec_instr_s1_tid, fet_dec_instr_s0_tid, fet_dec_instr_s7_stall,
      fet_dec_instr_s7_credit, fet_dec_instr_s7_payload, fet_dec_instr_s7_valid,
      fet_dec_instr_s6_stall, fet_dec_instr_s6_credit, fet_dec_instr_s6_payload,
      fet_dec_instr_s6_valid, fet_dec_instr_s5_stall, fet_dec_instr_s5_credit,
      fet_dec_instr_s5_payload, fet_dec_instr_s5_valid, fet_dec_instr_s4_stall,
      fet_dec_instr_s4_credit, fet_dec_instr_s4_payload, fet_dec_instr_s4_valid,
      fet_dec_instr_s3_stall, fet_dec_instr_s3_credit, fet_dec_instr_s3_payload,
      fet_dec_instr_s3_valid, fet_dec_instr_s2_stall, fet_dec_instr_s2_credit,
      fet_dec_instr_s2_payload, fet_dec_instr_s2_valid, fet_dec_instr_s1_stall,
      fet_dec_instr_s1_credit, fet_dec_instr_s1_payload, fet_dec_instr_s1_valid,
      fet_dec_instr_s0_stall, fet_dec_instr_s0_credit, fet_dec_instr_s0_payload,
      fet_dec_instr_s0_valid
    }, drv);
    q <= drv;
    q2 <= q;
    cyc <= cyc + 1;
  end
  assign {
    dec_ooe_uop_s5_tid, dec_ooe_uop_s4_tid, dec_ooe_uop_s3_tid,
    dec_ooe_uop_s2_tid, dec_ooe_uop_s1_tid, dec_ooe_uop_s0_tid,
    dec_ooe_uop_s5_payload, dec_ooe_uop_s5_valid, dec_ooe_uop_s4_payload,
    dec_ooe_uop_s4_valid, dec_ooe_uop_s3_payload, dec_ooe_uop_s3_valid,
    dec_ooe_uop_s2_payload, dec_ooe_uop_s2_valid, dec_ooe_uop_s1_payload,
    dec_ooe_uop_s1_valid, dec_ooe_uop_s0_payload, dec_ooe_uop_s0_valid,
    fet_dec_instr_s7_stall, fet_dec_instr_s7_credit, fet_dec_instr_s6_stall,
    fet_dec_instr_s6_credit, fet_dec_instr_s5_stall, fet_dec_instr_s5_credit,
    fet_dec_instr_s4_stall, fet_dec_instr_s4_credit, fet_dec_instr_s3_stall,
    fet_dec_instr_s3_credit, fet_dec_instr_s2_stall, fet_dec_instr_s2_credit,
    fet_dec_instr_s1_stall, fet_dec_instr_s1_credit, fet_dec_instr_s0_stall,
    fet_dec_instr_s0_credit
  } = skew ? q2 : q;
`endif
  assign kill_ack = '0;
  assign kill_ack_epoch = '0;
  assign sleep_ok = '0;
  assign csr_rsp = '0;
  assign csr_credit = '0;
  assign dec_ooe_uop_wake = '0;
endmodule
/* verilator lint_on UNUSEDSIGNAL */
