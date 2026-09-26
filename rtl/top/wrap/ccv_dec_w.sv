// GENERATED FILE -- DO NOT EDIT.
//
// Produced by tools/gen-top.py from schema/interfaces.json and
// params/blocks.json. Edit a source and regenerate; tools/verify.sh fails if
// this file is stale.

// HARDENING WRAPPER ccv_dec_w: ccv_dec and the sequential repeaters of its
// channel ends -- the physical hierarchy (docs/physical.md, "Wrappers
// and links"). Nothing but instances and nets, like the top. Every
// end has its repeater whether or not the link is repeated: STAGES is
// a parameter the top sets from params/links.json, 0 meaning wires, so
// a new split changes parameters and never this structure.
`include "ccv_interfaces.svh"

module ccv_dec_w #(
  parameter int RPT_FET_DEC_INSTR = 0,
  parameter int RPT_DEC_OOE_UOP = 0
) (
  `include "ccv_dec_ports.svh"
);

  // Between the block and its repeaters: b_<port>, one net per port.
  logic b_fet_dec_instr_s0_valid;
  ccv_fet_dec_instr_t b_fet_dec_instr_s0_payload;
  logic b_fet_dec_instr_s0_credit;
  logic b_fet_dec_instr_s0_stall;
  logic b_fet_dec_instr_s1_valid;
  ccv_fet_dec_instr_t b_fet_dec_instr_s1_payload;
  logic b_fet_dec_instr_s1_credit;
  logic b_fet_dec_instr_s1_stall;
  logic b_fet_dec_instr_s2_valid;
  ccv_fet_dec_instr_t b_fet_dec_instr_s2_payload;
  logic b_fet_dec_instr_s2_credit;
  logic b_fet_dec_instr_s2_stall;
  logic b_fet_dec_instr_s3_valid;
  ccv_fet_dec_instr_t b_fet_dec_instr_s3_payload;
  logic b_fet_dec_instr_s3_credit;
  logic b_fet_dec_instr_s3_stall;
  logic b_fet_dec_instr_s4_valid;
  ccv_fet_dec_instr_t b_fet_dec_instr_s4_payload;
  logic b_fet_dec_instr_s4_credit;
  logic b_fet_dec_instr_s4_stall;
  logic b_fet_dec_instr_s5_valid;
  ccv_fet_dec_instr_t b_fet_dec_instr_s5_payload;
  logic b_fet_dec_instr_s5_credit;
  logic b_fet_dec_instr_s5_stall;
  logic b_fet_dec_instr_s6_valid;
  ccv_fet_dec_instr_t b_fet_dec_instr_s6_payload;
  logic b_fet_dec_instr_s6_credit;
  logic b_fet_dec_instr_s6_stall;
  logic b_fet_dec_instr_s7_valid;
  ccv_fet_dec_instr_t b_fet_dec_instr_s7_payload;
  logic b_fet_dec_instr_s7_credit;
  logic b_fet_dec_instr_s7_stall;
  logic b_fet_dec_instr_wake;
  logic b_dec_ooe_uop_s0_valid;
  ccv_dec_ooe_uop_t b_dec_ooe_uop_s0_payload;
  logic b_dec_ooe_uop_s0_credit;
  logic b_dec_ooe_uop_s0_stall;
  logic b_dec_ooe_uop_s1_valid;
  ccv_dec_ooe_uop_t b_dec_ooe_uop_s1_payload;
  logic b_dec_ooe_uop_s1_credit;
  logic b_dec_ooe_uop_s1_stall;
  logic b_dec_ooe_uop_s2_valid;
  ccv_dec_ooe_uop_t b_dec_ooe_uop_s2_payload;
  logic b_dec_ooe_uop_s2_credit;
  logic b_dec_ooe_uop_s2_stall;
  logic b_dec_ooe_uop_s3_valid;
  ccv_dec_ooe_uop_t b_dec_ooe_uop_s3_payload;
  logic b_dec_ooe_uop_s3_credit;
  logic b_dec_ooe_uop_s3_stall;
  logic b_dec_ooe_uop_s4_valid;
  ccv_dec_ooe_uop_t b_dec_ooe_uop_s4_payload;
  logic b_dec_ooe_uop_s4_credit;
  logic b_dec_ooe_uop_s4_stall;
  logic b_dec_ooe_uop_s5_valid;
  ccv_dec_ooe_uop_t b_dec_ooe_uop_s5_payload;
  logic b_dec_ooe_uop_s5_credit;
  logic b_dec_ooe_uop_s5_stall;
  logic b_dec_ooe_uop_wake;
`ifdef CCV_TRACE
  logic [63:0] b_fet_dec_instr_s0_tid;
  logic [63:0] b_fet_dec_instr_s1_tid;
  logic [63:0] b_fet_dec_instr_s2_tid;
  logic [63:0] b_fet_dec_instr_s3_tid;
  logic [63:0] b_fet_dec_instr_s4_tid;
  logic [63:0] b_fet_dec_instr_s5_tid;
  logic [63:0] b_fet_dec_instr_s6_tid;
  logic [63:0] b_fet_dec_instr_s7_tid;
  logic [63:0] b_dec_ooe_uop_s0_tid;
  logic [63:0] b_dec_ooe_uop_s1_tid;
  logic [63:0] b_dec_ooe_uop_s2_tid;
  logic [63:0] b_dec_ooe_uop_s3_tid;
  logic [63:0] b_dec_ooe_uop_s4_tid;
  logic [63:0] b_dec_ooe_uop_s5_tid;
`endif

  ccv_dec u_blk (
    .core_clk(core_clk),
    .rst_n(rst_n),
    .kill_valid(kill_valid),
    .kill_warp_mask(kill_warp_mask),
    .kill_epoch(kill_epoch),
    .kill_ack(kill_ack),
    .kill_ack_epoch(kill_ack_epoch),
    .csr_req(csr_req),
    .csr_rsp(csr_rsp),
    .csr_credit(csr_credit),
    .fet_dec_instr_s0_valid(b_fet_dec_instr_s0_valid),
    .fet_dec_instr_s0_payload(b_fet_dec_instr_s0_payload),
    .fet_dec_instr_s0_credit(b_fet_dec_instr_s0_credit),
    .fet_dec_instr_s0_stall(b_fet_dec_instr_s0_stall),
    .fet_dec_instr_s1_valid(b_fet_dec_instr_s1_valid),
    .fet_dec_instr_s1_payload(b_fet_dec_instr_s1_payload),
    .fet_dec_instr_s1_credit(b_fet_dec_instr_s1_credit),
    .fet_dec_instr_s1_stall(b_fet_dec_instr_s1_stall),
    .fet_dec_instr_s2_valid(b_fet_dec_instr_s2_valid),
    .fet_dec_instr_s2_payload(b_fet_dec_instr_s2_payload),
    .fet_dec_instr_s2_credit(b_fet_dec_instr_s2_credit),
    .fet_dec_instr_s2_stall(b_fet_dec_instr_s2_stall),
    .fet_dec_instr_s3_valid(b_fet_dec_instr_s3_valid),
    .fet_dec_instr_s3_payload(b_fet_dec_instr_s3_payload),
    .fet_dec_instr_s3_credit(b_fet_dec_instr_s3_credit),
    .fet_dec_instr_s3_stall(b_fet_dec_instr_s3_stall),
    .fet_dec_instr_s4_valid(b_fet_dec_instr_s4_valid),
    .fet_dec_instr_s4_payload(b_fet_dec_instr_s4_payload),
    .fet_dec_instr_s4_credit(b_fet_dec_instr_s4_credit),
    .fet_dec_instr_s4_stall(b_fet_dec_instr_s4_stall),
    .fet_dec_instr_s5_valid(b_fet_dec_instr_s5_valid),
    .fet_dec_instr_s5_payload(b_fet_dec_instr_s5_payload),
    .fet_dec_instr_s5_credit(b_fet_dec_instr_s5_credit),
    .fet_dec_instr_s5_stall(b_fet_dec_instr_s5_stall),
    .fet_dec_instr_s6_valid(b_fet_dec_instr_s6_valid),
    .fet_dec_instr_s6_payload(b_fet_dec_instr_s6_payload),
    .fet_dec_instr_s6_credit(b_fet_dec_instr_s6_credit),
    .fet_dec_instr_s6_stall(b_fet_dec_instr_s6_stall),
    .fet_dec_instr_s7_valid(b_fet_dec_instr_s7_valid),
    .fet_dec_instr_s7_payload(b_fet_dec_instr_s7_payload),
    .fet_dec_instr_s7_credit(b_fet_dec_instr_s7_credit),
    .fet_dec_instr_s7_stall(b_fet_dec_instr_s7_stall),
    .fet_dec_instr_wake(b_fet_dec_instr_wake),
    .dec_ooe_uop_s0_valid(b_dec_ooe_uop_s0_valid),
    .dec_ooe_uop_s0_payload(b_dec_ooe_uop_s0_payload),
    .dec_ooe_uop_s0_credit(b_dec_ooe_uop_s0_credit),
    .dec_ooe_uop_s0_stall(b_dec_ooe_uop_s0_stall),
    .dec_ooe_uop_s1_valid(b_dec_ooe_uop_s1_valid),
    .dec_ooe_uop_s1_payload(b_dec_ooe_uop_s1_payload),
    .dec_ooe_uop_s1_credit(b_dec_ooe_uop_s1_credit),
    .dec_ooe_uop_s1_stall(b_dec_ooe_uop_s1_stall),
    .dec_ooe_uop_s2_valid(b_dec_ooe_uop_s2_valid),
    .dec_ooe_uop_s2_payload(b_dec_ooe_uop_s2_payload),
    .dec_ooe_uop_s2_credit(b_dec_ooe_uop_s2_credit),
    .dec_ooe_uop_s2_stall(b_dec_ooe_uop_s2_stall),
    .dec_ooe_uop_s3_valid(b_dec_ooe_uop_s3_valid),
    .dec_ooe_uop_s3_payload(b_dec_ooe_uop_s3_payload),
    .dec_ooe_uop_s3_credit(b_dec_ooe_uop_s3_credit),
    .dec_ooe_uop_s3_stall(b_dec_ooe_uop_s3_stall),
    .dec_ooe_uop_s4_valid(b_dec_ooe_uop_s4_valid),
    .dec_ooe_uop_s4_payload(b_dec_ooe_uop_s4_payload),
    .dec_ooe_uop_s4_credit(b_dec_ooe_uop_s4_credit),
    .dec_ooe_uop_s4_stall(b_dec_ooe_uop_s4_stall),
    .dec_ooe_uop_s5_valid(b_dec_ooe_uop_s5_valid),
    .dec_ooe_uop_s5_payload(b_dec_ooe_uop_s5_payload),
    .dec_ooe_uop_s5_credit(b_dec_ooe_uop_s5_credit),
    .dec_ooe_uop_s5_stall(b_dec_ooe_uop_s5_stall),
    .dec_ooe_uop_wake(b_dec_ooe_uop_wake)
`ifdef CCV_CHECK
    , .clk_gated(clk_gated)
`endif
`ifdef CCV_TRACE
    , .fet_dec_instr_s0_tid(b_fet_dec_instr_s0_tid)
    , .fet_dec_instr_s1_tid(b_fet_dec_instr_s1_tid)
    , .fet_dec_instr_s2_tid(b_fet_dec_instr_s2_tid)
    , .fet_dec_instr_s3_tid(b_fet_dec_instr_s3_tid)
    , .fet_dec_instr_s4_tid(b_fet_dec_instr_s4_tid)
    , .fet_dec_instr_s5_tid(b_fet_dec_instr_s5_tid)
    , .fet_dec_instr_s6_tid(b_fet_dec_instr_s6_tid)
    , .fet_dec_instr_s7_tid(b_fet_dec_instr_s7_tid)
    , .dec_ooe_uop_s0_tid(b_dec_ooe_uop_s0_tid)
    , .dec_ooe_uop_s1_tid(b_dec_ooe_uop_s1_tid)
    , .dec_ooe_uop_s2_tid(b_dec_ooe_uop_s2_tid)
    , .dec_ooe_uop_s3_tid(b_dec_ooe_uop_s3_tid)
    , .dec_ooe_uop_s4_tid(b_dec_ooe_uop_s4_tid)
    , .dec_ooe_uop_s5_tid(b_dec_ooe_uop_s5_tid)
`endif
  );

  // ccv_fet_dec_instr, destination end
  ccv_seq_rpt #(.STAGES(RPT_FET_DEC_INSTR), .SLOTS(8), .PAYLOAD_W(122)) u_rpt_fet_dec_instr (
    .clk(core_clk), .rst_n(rst_n),
    .src_valid({fet_dec_instr_s7_valid, fet_dec_instr_s6_valid, fet_dec_instr_s5_valid, fet_dec_instr_s4_valid, fet_dec_instr_s3_valid, fet_dec_instr_s2_valid, fet_dec_instr_s1_valid, fet_dec_instr_s0_valid}), .src_payload({fet_dec_instr_s7_payload, fet_dec_instr_s6_payload, fet_dec_instr_s5_payload, fet_dec_instr_s4_payload, fet_dec_instr_s3_payload, fet_dec_instr_s2_payload, fet_dec_instr_s1_payload, fet_dec_instr_s0_payload}),
    .src_wake(fet_dec_instr_wake), .src_credit({fet_dec_instr_s7_credit, fet_dec_instr_s6_credit, fet_dec_instr_s5_credit, fet_dec_instr_s4_credit, fet_dec_instr_s3_credit, fet_dec_instr_s2_credit, fet_dec_instr_s1_credit, fet_dec_instr_s0_credit}), .src_stall({fet_dec_instr_s7_stall, fet_dec_instr_s6_stall, fet_dec_instr_s5_stall, fet_dec_instr_s4_stall, fet_dec_instr_s3_stall, fet_dec_instr_s2_stall, fet_dec_instr_s1_stall, fet_dec_instr_s0_stall}),
    .dst_valid({b_fet_dec_instr_s7_valid, b_fet_dec_instr_s6_valid, b_fet_dec_instr_s5_valid, b_fet_dec_instr_s4_valid, b_fet_dec_instr_s3_valid, b_fet_dec_instr_s2_valid, b_fet_dec_instr_s1_valid, b_fet_dec_instr_s0_valid}), .dst_payload({b_fet_dec_instr_s7_payload, b_fet_dec_instr_s6_payload, b_fet_dec_instr_s5_payload, b_fet_dec_instr_s4_payload, b_fet_dec_instr_s3_payload, b_fet_dec_instr_s2_payload, b_fet_dec_instr_s1_payload, b_fet_dec_instr_s0_payload}),
    .dst_wake(b_fet_dec_instr_wake), .dst_credit({b_fet_dec_instr_s7_credit, b_fet_dec_instr_s6_credit, b_fet_dec_instr_s5_credit, b_fet_dec_instr_s4_credit, b_fet_dec_instr_s3_credit, b_fet_dec_instr_s2_credit, b_fet_dec_instr_s1_credit, b_fet_dec_instr_s0_credit}), .dst_stall({b_fet_dec_instr_s7_stall, b_fet_dec_instr_s6_stall, b_fet_dec_instr_s5_stall, b_fet_dec_instr_s4_stall, b_fet_dec_instr_s3_stall, b_fet_dec_instr_s2_stall, b_fet_dec_instr_s1_stall, b_fet_dec_instr_s0_stall})
`ifdef CCV_TRACE
    , .src_tid({fet_dec_instr_s7_tid, fet_dec_instr_s6_tid, fet_dec_instr_s5_tid, fet_dec_instr_s4_tid, fet_dec_instr_s3_tid, fet_dec_instr_s2_tid, fet_dec_instr_s1_tid, fet_dec_instr_s0_tid}), .dst_tid({b_fet_dec_instr_s7_tid, b_fet_dec_instr_s6_tid, b_fet_dec_instr_s5_tid, b_fet_dec_instr_s4_tid, b_fet_dec_instr_s3_tid, b_fet_dec_instr_s2_tid, b_fet_dec_instr_s1_tid, b_fet_dec_instr_s0_tid})
`endif
  );
  // ccv_dec_ooe_uop, source end
  ccv_seq_rpt #(.STAGES(RPT_DEC_OOE_UOP), .SLOTS(6), .PAYLOAD_W(137)) u_rpt_dec_ooe_uop (
    .clk(core_clk), .rst_n(rst_n),
    .src_valid({b_dec_ooe_uop_s5_valid, b_dec_ooe_uop_s4_valid, b_dec_ooe_uop_s3_valid, b_dec_ooe_uop_s2_valid, b_dec_ooe_uop_s1_valid, b_dec_ooe_uop_s0_valid}), .src_payload({b_dec_ooe_uop_s5_payload, b_dec_ooe_uop_s4_payload, b_dec_ooe_uop_s3_payload, b_dec_ooe_uop_s2_payload, b_dec_ooe_uop_s1_payload, b_dec_ooe_uop_s0_payload}),
    .src_wake(b_dec_ooe_uop_wake), .src_credit({b_dec_ooe_uop_s5_credit, b_dec_ooe_uop_s4_credit, b_dec_ooe_uop_s3_credit, b_dec_ooe_uop_s2_credit, b_dec_ooe_uop_s1_credit, b_dec_ooe_uop_s0_credit}), .src_stall({b_dec_ooe_uop_s5_stall, b_dec_ooe_uop_s4_stall, b_dec_ooe_uop_s3_stall, b_dec_ooe_uop_s2_stall, b_dec_ooe_uop_s1_stall, b_dec_ooe_uop_s0_stall}),
    .dst_valid({dec_ooe_uop_s5_valid, dec_ooe_uop_s4_valid, dec_ooe_uop_s3_valid, dec_ooe_uop_s2_valid, dec_ooe_uop_s1_valid, dec_ooe_uop_s0_valid}), .dst_payload({dec_ooe_uop_s5_payload, dec_ooe_uop_s4_payload, dec_ooe_uop_s3_payload, dec_ooe_uop_s2_payload, dec_ooe_uop_s1_payload, dec_ooe_uop_s0_payload}),
    .dst_wake(dec_ooe_uop_wake), .dst_credit({dec_ooe_uop_s5_credit, dec_ooe_uop_s4_credit, dec_ooe_uop_s3_credit, dec_ooe_uop_s2_credit, dec_ooe_uop_s1_credit, dec_ooe_uop_s0_credit}), .dst_stall({dec_ooe_uop_s5_stall, dec_ooe_uop_s4_stall, dec_ooe_uop_s3_stall, dec_ooe_uop_s2_stall, dec_ooe_uop_s1_stall, dec_ooe_uop_s0_stall})
`ifdef CCV_TRACE
    , .src_tid({b_dec_ooe_uop_s5_tid, b_dec_ooe_uop_s4_tid, b_dec_ooe_uop_s3_tid, b_dec_ooe_uop_s2_tid, b_dec_ooe_uop_s1_tid, b_dec_ooe_uop_s0_tid}), .dst_tid({dec_ooe_uop_s5_tid, dec_ooe_uop_s4_tid, dec_ooe_uop_s3_tid, dec_ooe_uop_s2_tid, dec_ooe_uop_s1_tid, dec_ooe_uop_s0_tid})
`endif
  );
endmodule
