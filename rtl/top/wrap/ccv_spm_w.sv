// GENERATED FILE -- DO NOT EDIT.
//
// Produced by tools/gen-top.py from schema/interfaces.json and
// params/blocks.json. Edit a source and regenerate; tools/verify.sh fails if
// this file is stale.

// HARDENING WRAPPER ccv_spm_w: ccv_spm and the sequential repeaters of its
// channel ends -- the physical hierarchy (docs/physical.md, "Wrappers
// and links"). Nothing but instances and nets, like the top. Every
// end has its repeater whether or not the link is repeated: STAGES is
// a parameter the top sets from params/links.json, 0 meaning wires, so
// a new split changes parameters and never this structure.
`include "ccv_interfaces.svh"

module ccv_spm_w #(
  parameter int RPT_MIU_SPM_REQ = 0,
  parameter int RPT_SPM_MIU_RSP = 0
) (
  `include "ccv_spm_ports.svh"
);

  // Between the block and its repeaters: b_<port>, one net per port.
  logic b_miu_spm_req_s0_valid;
  ccv_miu_spm_req_t b_miu_spm_req_s0_payload;
  logic b_miu_spm_req_s0_credit;
  logic b_miu_spm_req_s0_stall;
  logic b_miu_spm_req_s1_valid;
  ccv_miu_spm_req_t b_miu_spm_req_s1_payload;
  logic b_miu_spm_req_s1_credit;
  logic b_miu_spm_req_s1_stall;
  logic b_miu_spm_req_s2_valid;
  ccv_miu_spm_req_t b_miu_spm_req_s2_payload;
  logic b_miu_spm_req_s2_credit;
  logic b_miu_spm_req_s2_stall;
  logic b_miu_spm_req_s3_valid;
  ccv_miu_spm_req_t b_miu_spm_req_s3_payload;
  logic b_miu_spm_req_s3_credit;
  logic b_miu_spm_req_s3_stall;
  logic b_miu_spm_req_wake;
  logic b_spm_miu_rsp_s0_valid;
  ccv_spm_miu_rsp_t b_spm_miu_rsp_s0_payload;
  logic b_spm_miu_rsp_s0_credit;
  logic b_spm_miu_rsp_s0_stall;
  logic b_spm_miu_rsp_s1_valid;
  ccv_spm_miu_rsp_t b_spm_miu_rsp_s1_payload;
  logic b_spm_miu_rsp_s1_credit;
  logic b_spm_miu_rsp_s1_stall;
  logic b_spm_miu_rsp_s2_valid;
  ccv_spm_miu_rsp_t b_spm_miu_rsp_s2_payload;
  logic b_spm_miu_rsp_s2_credit;
  logic b_spm_miu_rsp_s2_stall;
  logic b_spm_miu_rsp_s3_valid;
  ccv_spm_miu_rsp_t b_spm_miu_rsp_s3_payload;
  logic b_spm_miu_rsp_s3_credit;
  logic b_spm_miu_rsp_s3_stall;
  logic b_spm_miu_rsp_wake;
`ifdef CCV_TRACE
  logic [63:0] b_miu_spm_req_s0_tid;
  logic [63:0] b_miu_spm_req_s1_tid;
  logic [63:0] b_miu_spm_req_s2_tid;
  logic [63:0] b_miu_spm_req_s3_tid;
  logic [63:0] b_spm_miu_rsp_s0_tid;
  logic [63:0] b_spm_miu_rsp_s1_tid;
  logic [63:0] b_spm_miu_rsp_s2_tid;
  logic [63:0] b_spm_miu_rsp_s3_tid;
`endif

  ccv_spm u_blk (
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
    .miu_spm_req_s0_valid(b_miu_spm_req_s0_valid),
    .miu_spm_req_s0_payload(b_miu_spm_req_s0_payload),
    .miu_spm_req_s0_credit(b_miu_spm_req_s0_credit),
    .miu_spm_req_s0_stall(b_miu_spm_req_s0_stall),
    .miu_spm_req_s1_valid(b_miu_spm_req_s1_valid),
    .miu_spm_req_s1_payload(b_miu_spm_req_s1_payload),
    .miu_spm_req_s1_credit(b_miu_spm_req_s1_credit),
    .miu_spm_req_s1_stall(b_miu_spm_req_s1_stall),
    .miu_spm_req_s2_valid(b_miu_spm_req_s2_valid),
    .miu_spm_req_s2_payload(b_miu_spm_req_s2_payload),
    .miu_spm_req_s2_credit(b_miu_spm_req_s2_credit),
    .miu_spm_req_s2_stall(b_miu_spm_req_s2_stall),
    .miu_spm_req_s3_valid(b_miu_spm_req_s3_valid),
    .miu_spm_req_s3_payload(b_miu_spm_req_s3_payload),
    .miu_spm_req_s3_credit(b_miu_spm_req_s3_credit),
    .miu_spm_req_s3_stall(b_miu_spm_req_s3_stall),
    .miu_spm_req_wake(b_miu_spm_req_wake),
    .spm_miu_rsp_s0_valid(b_spm_miu_rsp_s0_valid),
    .spm_miu_rsp_s0_payload(b_spm_miu_rsp_s0_payload),
    .spm_miu_rsp_s0_credit(b_spm_miu_rsp_s0_credit),
    .spm_miu_rsp_s0_stall(b_spm_miu_rsp_s0_stall),
    .spm_miu_rsp_s1_valid(b_spm_miu_rsp_s1_valid),
    .spm_miu_rsp_s1_payload(b_spm_miu_rsp_s1_payload),
    .spm_miu_rsp_s1_credit(b_spm_miu_rsp_s1_credit),
    .spm_miu_rsp_s1_stall(b_spm_miu_rsp_s1_stall),
    .spm_miu_rsp_s2_valid(b_spm_miu_rsp_s2_valid),
    .spm_miu_rsp_s2_payload(b_spm_miu_rsp_s2_payload),
    .spm_miu_rsp_s2_credit(b_spm_miu_rsp_s2_credit),
    .spm_miu_rsp_s2_stall(b_spm_miu_rsp_s2_stall),
    .spm_miu_rsp_s3_valid(b_spm_miu_rsp_s3_valid),
    .spm_miu_rsp_s3_payload(b_spm_miu_rsp_s3_payload),
    .spm_miu_rsp_s3_credit(b_spm_miu_rsp_s3_credit),
    .spm_miu_rsp_s3_stall(b_spm_miu_rsp_s3_stall),
    .spm_miu_rsp_wake(b_spm_miu_rsp_wake)
`ifdef CCV_CHECK
    , .clk_gated(clk_gated)
`endif
`ifdef CCV_TRACE
    , .miu_spm_req_s0_tid(b_miu_spm_req_s0_tid)
    , .miu_spm_req_s1_tid(b_miu_spm_req_s1_tid)
    , .miu_spm_req_s2_tid(b_miu_spm_req_s2_tid)
    , .miu_spm_req_s3_tid(b_miu_spm_req_s3_tid)
    , .spm_miu_rsp_s0_tid(b_spm_miu_rsp_s0_tid)
    , .spm_miu_rsp_s1_tid(b_spm_miu_rsp_s1_tid)
    , .spm_miu_rsp_s2_tid(b_spm_miu_rsp_s2_tid)
    , .spm_miu_rsp_s3_tid(b_spm_miu_rsp_s3_tid)
`endif
  );

  // ccv_miu_spm_req, destination end
  ccv_seq_rpt #(.STAGES(RPT_MIU_SPM_REQ), .SLOTS(4), .PAYLOAD_W(1477)) u_rpt_miu_spm_req (
    .clk(core_clk), .rst_n(rst_n),
    .src_valid({miu_spm_req_s3_valid, miu_spm_req_s2_valid, miu_spm_req_s1_valid, miu_spm_req_s0_valid}), .src_payload({miu_spm_req_s3_payload, miu_spm_req_s2_payload, miu_spm_req_s1_payload, miu_spm_req_s0_payload}),
    .src_wake(miu_spm_req_wake), .src_credit({miu_spm_req_s3_credit, miu_spm_req_s2_credit, miu_spm_req_s1_credit, miu_spm_req_s0_credit}), .src_stall({miu_spm_req_s3_stall, miu_spm_req_s2_stall, miu_spm_req_s1_stall, miu_spm_req_s0_stall}),
    .dst_valid({b_miu_spm_req_s3_valid, b_miu_spm_req_s2_valid, b_miu_spm_req_s1_valid, b_miu_spm_req_s0_valid}), .dst_payload({b_miu_spm_req_s3_payload, b_miu_spm_req_s2_payload, b_miu_spm_req_s1_payload, b_miu_spm_req_s0_payload}),
    .dst_wake(b_miu_spm_req_wake), .dst_credit({b_miu_spm_req_s3_credit, b_miu_spm_req_s2_credit, b_miu_spm_req_s1_credit, b_miu_spm_req_s0_credit}), .dst_stall({b_miu_spm_req_s3_stall, b_miu_spm_req_s2_stall, b_miu_spm_req_s1_stall, b_miu_spm_req_s0_stall})
`ifdef CCV_TRACE
    , .src_tid({miu_spm_req_s3_tid, miu_spm_req_s2_tid, miu_spm_req_s1_tid, miu_spm_req_s0_tid}), .dst_tid({b_miu_spm_req_s3_tid, b_miu_spm_req_s2_tid, b_miu_spm_req_s1_tid, b_miu_spm_req_s0_tid})
`endif
  );
  // ccv_spm_miu_rsp, source end
  ccv_seq_rpt #(.STAGES(RPT_SPM_MIU_RSP), .SLOTS(4), .PAYLOAD_W(1033)) u_rpt_spm_miu_rsp (
    .clk(core_clk), .rst_n(rst_n),
    .src_valid({b_spm_miu_rsp_s3_valid, b_spm_miu_rsp_s2_valid, b_spm_miu_rsp_s1_valid, b_spm_miu_rsp_s0_valid}), .src_payload({b_spm_miu_rsp_s3_payload, b_spm_miu_rsp_s2_payload, b_spm_miu_rsp_s1_payload, b_spm_miu_rsp_s0_payload}),
    .src_wake(b_spm_miu_rsp_wake), .src_credit({b_spm_miu_rsp_s3_credit, b_spm_miu_rsp_s2_credit, b_spm_miu_rsp_s1_credit, b_spm_miu_rsp_s0_credit}), .src_stall({b_spm_miu_rsp_s3_stall, b_spm_miu_rsp_s2_stall, b_spm_miu_rsp_s1_stall, b_spm_miu_rsp_s0_stall}),
    .dst_valid({spm_miu_rsp_s3_valid, spm_miu_rsp_s2_valid, spm_miu_rsp_s1_valid, spm_miu_rsp_s0_valid}), .dst_payload({spm_miu_rsp_s3_payload, spm_miu_rsp_s2_payload, spm_miu_rsp_s1_payload, spm_miu_rsp_s0_payload}),
    .dst_wake(spm_miu_rsp_wake), .dst_credit({spm_miu_rsp_s3_credit, spm_miu_rsp_s2_credit, spm_miu_rsp_s1_credit, spm_miu_rsp_s0_credit}), .dst_stall({spm_miu_rsp_s3_stall, spm_miu_rsp_s2_stall, spm_miu_rsp_s1_stall, spm_miu_rsp_s0_stall})
`ifdef CCV_TRACE
    , .src_tid({b_spm_miu_rsp_s3_tid, b_spm_miu_rsp_s2_tid, b_spm_miu_rsp_s1_tid, b_spm_miu_rsp_s0_tid}), .dst_tid({spm_miu_rsp_s3_tid, spm_miu_rsp_s2_tid, spm_miu_rsp_s1_tid, spm_miu_rsp_s0_tid})
`endif
  );
endmodule
