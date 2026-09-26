// GENERATED FILE -- DO NOT EDIT.
//
// Produced by tools/gen-top.py from schema/interfaces.json and
// params/blocks.json. Edit a source and regenerate; tools/verify.sh fails if
// this file is stale.

// HARDENING WRAPPER ccv_fet_w: ccv_fet and the sequential repeaters of its
// channel ends -- the physical hierarchy (docs/physical.md, "Wrappers
// and links"). Nothing but instances and nets, like the top. Every
// end has its repeater whether or not the link is repeated: STAGES is
// a parameter the top sets from params/links.json, 0 meaning wires, so
// a new split changes parameters and never this structure.
`include "ccv_interfaces.svh"

module ccv_fet_w #(
  parameter int RPT_FET_DEC_INSTR = 0,
  parameter int RPT_OOE_FET_REDIRECT = 0,
  parameter int RPT_FET_MLC_IFILL = 0,
  parameter int RPT_MLC_FET_IFILL_RSP = 0,
  parameter int RPT_MIU_FET_ITLB = 0,
  parameter int RPT_FET_MIU_ITLB_REQ = 0,
  parameter int RPT_RAU_FET_LAUNCH = 0,
  parameter int RPT_FET_PCA_MIG = 0,
  parameter int RPT_PCA_FET_MIG = 0,
  parameter int RPT_RAU_FET_MIG = 0
) (
  `include "ccv_fet_ports.svh"
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
  logic b_ooe_fet_redirect_valid;
  ccv_ooe_fet_redirect_t b_ooe_fet_redirect_payload;
  logic b_ooe_fet_redirect_credit;
  logic b_ooe_fet_redirect_stall;
  logic b_ooe_fet_redirect_wake;
  logic b_fet_mlc_ifill_valid;
  ccv_fet_mlc_ifill_t b_fet_mlc_ifill_payload;
  logic b_fet_mlc_ifill_credit;
  logic b_fet_mlc_ifill_stall;
  logic b_fet_mlc_ifill_wake;
  logic b_mlc_fet_ifill_rsp_valid;
  ccv_mlc_fet_ifill_rsp_t b_mlc_fet_ifill_rsp_payload;
  logic b_mlc_fet_ifill_rsp_credit;
  logic b_mlc_fet_ifill_rsp_stall;
  logic b_mlc_fet_ifill_rsp_wake;
  logic b_miu_fet_itlb_valid;
  ccv_miu_fet_itlb_t b_miu_fet_itlb_payload;
  logic b_miu_fet_itlb_credit;
  logic b_miu_fet_itlb_stall;
  logic b_miu_fet_itlb_wake;
  logic b_fet_miu_itlb_req_valid;
  ccv_fet_miu_itlb_req_t b_fet_miu_itlb_req_payload;
  logic b_fet_miu_itlb_req_credit;
  logic b_fet_miu_itlb_req_stall;
  logic b_fet_miu_itlb_req_wake;
  logic b_rau_fet_launch_valid;
  ccv_rau_fet_launch_t b_rau_fet_launch_payload;
  logic b_rau_fet_launch_credit;
  logic b_rau_fet_launch_stall;
  logic b_rau_fet_launch_wake;
  logic b_fet_pca_mig_valid;
  ccv_fet_pca_mig_t b_fet_pca_mig_payload;
  logic b_fet_pca_mig_credit;
  logic b_fet_pca_mig_stall;
  logic b_fet_pca_mig_wake;
  logic b_pca_fet_mig_valid;
  ccv_pca_fet_mig_t b_pca_fet_mig_payload;
  logic b_pca_fet_mig_credit;
  logic b_pca_fet_mig_stall;
  logic b_pca_fet_mig_wake;
  logic b_rau_fet_mig_valid;
  ccv_rau_fet_mig_t b_rau_fet_mig_payload;
  logic b_rau_fet_mig_credit;
  logic b_rau_fet_mig_stall;
  logic b_rau_fet_mig_wake;
`ifdef CCV_TRACE
  logic [63:0] b_fet_dec_instr_s0_tid;
  logic [63:0] b_fet_dec_instr_s1_tid;
  logic [63:0] b_fet_dec_instr_s2_tid;
  logic [63:0] b_fet_dec_instr_s3_tid;
  logic [63:0] b_fet_dec_instr_s4_tid;
  logic [63:0] b_fet_dec_instr_s5_tid;
  logic [63:0] b_fet_dec_instr_s6_tid;
  logic [63:0] b_fet_dec_instr_s7_tid;
  logic [63:0] b_ooe_fet_redirect_tid;
  logic [63:0] b_fet_mlc_ifill_tid;
  logic [63:0] b_mlc_fet_ifill_rsp_tid;
  logic [63:0] b_miu_fet_itlb_tid;
  logic [63:0] b_fet_miu_itlb_req_tid;
  logic [63:0] b_rau_fet_launch_tid;
  logic [63:0] b_fet_pca_mig_tid;
  logic [63:0] b_pca_fet_mig_tid;
  logic [63:0] b_rau_fet_mig_tid;
`endif

  ccv_fet u_blk (
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
    .ooe_fet_redirect_valid(b_ooe_fet_redirect_valid),
    .ooe_fet_redirect_payload(b_ooe_fet_redirect_payload),
    .ooe_fet_redirect_credit(b_ooe_fet_redirect_credit),
    .ooe_fet_redirect_stall(b_ooe_fet_redirect_stall),
    .ooe_fet_redirect_wake(b_ooe_fet_redirect_wake),
    .fet_mlc_ifill_valid(b_fet_mlc_ifill_valid),
    .fet_mlc_ifill_payload(b_fet_mlc_ifill_payload),
    .fet_mlc_ifill_credit(b_fet_mlc_ifill_credit),
    .fet_mlc_ifill_stall(b_fet_mlc_ifill_stall),
    .fet_mlc_ifill_wake(b_fet_mlc_ifill_wake),
    .mlc_fet_ifill_rsp_valid(b_mlc_fet_ifill_rsp_valid),
    .mlc_fet_ifill_rsp_payload(b_mlc_fet_ifill_rsp_payload),
    .mlc_fet_ifill_rsp_credit(b_mlc_fet_ifill_rsp_credit),
    .mlc_fet_ifill_rsp_stall(b_mlc_fet_ifill_rsp_stall),
    .mlc_fet_ifill_rsp_wake(b_mlc_fet_ifill_rsp_wake),
    .miu_fet_itlb_valid(b_miu_fet_itlb_valid),
    .miu_fet_itlb_payload(b_miu_fet_itlb_payload),
    .miu_fet_itlb_credit(b_miu_fet_itlb_credit),
    .miu_fet_itlb_stall(b_miu_fet_itlb_stall),
    .miu_fet_itlb_wake(b_miu_fet_itlb_wake),
    .fet_miu_itlb_req_valid(b_fet_miu_itlb_req_valid),
    .fet_miu_itlb_req_payload(b_fet_miu_itlb_req_payload),
    .fet_miu_itlb_req_credit(b_fet_miu_itlb_req_credit),
    .fet_miu_itlb_req_stall(b_fet_miu_itlb_req_stall),
    .fet_miu_itlb_req_wake(b_fet_miu_itlb_req_wake),
    .rau_fet_launch_valid(b_rau_fet_launch_valid),
    .rau_fet_launch_payload(b_rau_fet_launch_payload),
    .rau_fet_launch_credit(b_rau_fet_launch_credit),
    .rau_fet_launch_stall(b_rau_fet_launch_stall),
    .rau_fet_launch_wake(b_rau_fet_launch_wake),
    .fet_pca_mig_valid(b_fet_pca_mig_valid),
    .fet_pca_mig_payload(b_fet_pca_mig_payload),
    .fet_pca_mig_credit(b_fet_pca_mig_credit),
    .fet_pca_mig_stall(b_fet_pca_mig_stall),
    .fet_pca_mig_wake(b_fet_pca_mig_wake),
    .pca_fet_mig_valid(b_pca_fet_mig_valid),
    .pca_fet_mig_payload(b_pca_fet_mig_payload),
    .pca_fet_mig_credit(b_pca_fet_mig_credit),
    .pca_fet_mig_stall(b_pca_fet_mig_stall),
    .pca_fet_mig_wake(b_pca_fet_mig_wake),
    .rau_fet_mig_valid(b_rau_fet_mig_valid),
    .rau_fet_mig_payload(b_rau_fet_mig_payload),
    .rau_fet_mig_credit(b_rau_fet_mig_credit),
    .rau_fet_mig_stall(b_rau_fet_mig_stall),
    .rau_fet_mig_wake(b_rau_fet_mig_wake)
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
    , .ooe_fet_redirect_tid(b_ooe_fet_redirect_tid)
    , .fet_mlc_ifill_tid(b_fet_mlc_ifill_tid)
    , .mlc_fet_ifill_rsp_tid(b_mlc_fet_ifill_rsp_tid)
    , .miu_fet_itlb_tid(b_miu_fet_itlb_tid)
    , .fet_miu_itlb_req_tid(b_fet_miu_itlb_req_tid)
    , .rau_fet_launch_tid(b_rau_fet_launch_tid)
    , .fet_pca_mig_tid(b_fet_pca_mig_tid)
    , .pca_fet_mig_tid(b_pca_fet_mig_tid)
    , .rau_fet_mig_tid(b_rau_fet_mig_tid)
`endif
  );

  // ccv_fet_dec_instr, source end
  ccv_seq_rpt #(.STAGES(RPT_FET_DEC_INSTR), .SLOTS(8), .PAYLOAD_W(122)) u_rpt_fet_dec_instr (
    .clk(core_clk), .rst_n(rst_n),
    .src_valid({b_fet_dec_instr_s7_valid, b_fet_dec_instr_s6_valid, b_fet_dec_instr_s5_valid, b_fet_dec_instr_s4_valid, b_fet_dec_instr_s3_valid, b_fet_dec_instr_s2_valid, b_fet_dec_instr_s1_valid, b_fet_dec_instr_s0_valid}), .src_payload({b_fet_dec_instr_s7_payload, b_fet_dec_instr_s6_payload, b_fet_dec_instr_s5_payload, b_fet_dec_instr_s4_payload, b_fet_dec_instr_s3_payload, b_fet_dec_instr_s2_payload, b_fet_dec_instr_s1_payload, b_fet_dec_instr_s0_payload}),
    .src_wake(b_fet_dec_instr_wake), .src_credit({b_fet_dec_instr_s7_credit, b_fet_dec_instr_s6_credit, b_fet_dec_instr_s5_credit, b_fet_dec_instr_s4_credit, b_fet_dec_instr_s3_credit, b_fet_dec_instr_s2_credit, b_fet_dec_instr_s1_credit, b_fet_dec_instr_s0_credit}), .src_stall({b_fet_dec_instr_s7_stall, b_fet_dec_instr_s6_stall, b_fet_dec_instr_s5_stall, b_fet_dec_instr_s4_stall, b_fet_dec_instr_s3_stall, b_fet_dec_instr_s2_stall, b_fet_dec_instr_s1_stall, b_fet_dec_instr_s0_stall}),
    .dst_valid({fet_dec_instr_s7_valid, fet_dec_instr_s6_valid, fet_dec_instr_s5_valid, fet_dec_instr_s4_valid, fet_dec_instr_s3_valid, fet_dec_instr_s2_valid, fet_dec_instr_s1_valid, fet_dec_instr_s0_valid}), .dst_payload({fet_dec_instr_s7_payload, fet_dec_instr_s6_payload, fet_dec_instr_s5_payload, fet_dec_instr_s4_payload, fet_dec_instr_s3_payload, fet_dec_instr_s2_payload, fet_dec_instr_s1_payload, fet_dec_instr_s0_payload}),
    .dst_wake(fet_dec_instr_wake), .dst_credit({fet_dec_instr_s7_credit, fet_dec_instr_s6_credit, fet_dec_instr_s5_credit, fet_dec_instr_s4_credit, fet_dec_instr_s3_credit, fet_dec_instr_s2_credit, fet_dec_instr_s1_credit, fet_dec_instr_s0_credit}), .dst_stall({fet_dec_instr_s7_stall, fet_dec_instr_s6_stall, fet_dec_instr_s5_stall, fet_dec_instr_s4_stall, fet_dec_instr_s3_stall, fet_dec_instr_s2_stall, fet_dec_instr_s1_stall, fet_dec_instr_s0_stall})
`ifdef CCV_TRACE
    , .src_tid({b_fet_dec_instr_s7_tid, b_fet_dec_instr_s6_tid, b_fet_dec_instr_s5_tid, b_fet_dec_instr_s4_tid, b_fet_dec_instr_s3_tid, b_fet_dec_instr_s2_tid, b_fet_dec_instr_s1_tid, b_fet_dec_instr_s0_tid}), .dst_tid({fet_dec_instr_s7_tid, fet_dec_instr_s6_tid, fet_dec_instr_s5_tid, fet_dec_instr_s4_tid, fet_dec_instr_s3_tid, fet_dec_instr_s2_tid, fet_dec_instr_s1_tid, fet_dec_instr_s0_tid})
`endif
  );
  // ccv_ooe_fet_redirect, destination end
  ccv_seq_rpt #(.STAGES(RPT_OOE_FET_REDIRECT), .SLOTS(1), .PAYLOAD_W(201)) u_rpt_ooe_fet_redirect (
    .clk(core_clk), .rst_n(rst_n),
    .src_valid({ooe_fet_redirect_valid}), .src_payload({ooe_fet_redirect_payload}),
    .src_wake(ooe_fet_redirect_wake), .src_credit({ooe_fet_redirect_credit}), .src_stall({ooe_fet_redirect_stall}),
    .dst_valid({b_ooe_fet_redirect_valid}), .dst_payload({b_ooe_fet_redirect_payload}),
    .dst_wake(b_ooe_fet_redirect_wake), .dst_credit({b_ooe_fet_redirect_credit}), .dst_stall({b_ooe_fet_redirect_stall})
`ifdef CCV_TRACE
    , .src_tid({ooe_fet_redirect_tid}), .dst_tid({b_ooe_fet_redirect_tid})
`endif
  );
  // ccv_fet_mlc_ifill, source end
  ccv_seq_rpt #(.STAGES(RPT_FET_MLC_IFILL), .SLOTS(1), .PAYLOAD_W(58)) u_rpt_fet_mlc_ifill (
    .clk(core_clk), .rst_n(rst_n),
    .src_valid({b_fet_mlc_ifill_valid}), .src_payload({b_fet_mlc_ifill_payload}),
    .src_wake(b_fet_mlc_ifill_wake), .src_credit({b_fet_mlc_ifill_credit}), .src_stall({b_fet_mlc_ifill_stall}),
    .dst_valid({fet_mlc_ifill_valid}), .dst_payload({fet_mlc_ifill_payload}),
    .dst_wake(fet_mlc_ifill_wake), .dst_credit({fet_mlc_ifill_credit}), .dst_stall({fet_mlc_ifill_stall})
`ifdef CCV_TRACE
    , .src_tid({b_fet_mlc_ifill_tid}), .dst_tid({fet_mlc_ifill_tid})
`endif
  );
  // ccv_mlc_fet_ifill_rsp, destination end
  ccv_seq_rpt #(.STAGES(RPT_MLC_FET_IFILL_RSP), .SLOTS(1), .PAYLOAD_W(1026)) u_rpt_mlc_fet_ifill_rsp (
    .clk(core_clk), .rst_n(rst_n),
    .src_valid({mlc_fet_ifill_rsp_valid}), .src_payload({mlc_fet_ifill_rsp_payload}),
    .src_wake(mlc_fet_ifill_rsp_wake), .src_credit({mlc_fet_ifill_rsp_credit}), .src_stall({mlc_fet_ifill_rsp_stall}),
    .dst_valid({b_mlc_fet_ifill_rsp_valid}), .dst_payload({b_mlc_fet_ifill_rsp_payload}),
    .dst_wake(b_mlc_fet_ifill_rsp_wake), .dst_credit({b_mlc_fet_ifill_rsp_credit}), .dst_stall({b_mlc_fet_ifill_rsp_stall})
`ifdef CCV_TRACE
    , .src_tid({mlc_fet_ifill_rsp_tid}), .dst_tid({b_mlc_fet_ifill_rsp_tid})
`endif
  );
  // ccv_miu_fet_itlb, destination end
  ccv_seq_rpt #(.STAGES(RPT_MIU_FET_ITLB), .SLOTS(1), .PAYLOAD_W(64)) u_rpt_miu_fet_itlb (
    .clk(core_clk), .rst_n(rst_n),
    .src_valid({miu_fet_itlb_valid}), .src_payload({miu_fet_itlb_payload}),
    .src_wake(miu_fet_itlb_wake), .src_credit({miu_fet_itlb_credit}), .src_stall({miu_fet_itlb_stall}),
    .dst_valid({b_miu_fet_itlb_valid}), .dst_payload({b_miu_fet_itlb_payload}),
    .dst_wake(b_miu_fet_itlb_wake), .dst_credit({b_miu_fet_itlb_credit}), .dst_stall({b_miu_fet_itlb_stall})
`ifdef CCV_TRACE
    , .src_tid({miu_fet_itlb_tid}), .dst_tid({b_miu_fet_itlb_tid})
`endif
  );
  // ccv_fet_miu_itlb_req, source end
  ccv_seq_rpt #(.STAGES(RPT_FET_MIU_ITLB_REQ), .SLOTS(1), .PAYLOAD_W(72)) u_rpt_fet_miu_itlb_req (
    .clk(core_clk), .rst_n(rst_n),
    .src_valid({b_fet_miu_itlb_req_valid}), .src_payload({b_fet_miu_itlb_req_payload}),
    .src_wake(b_fet_miu_itlb_req_wake), .src_credit({b_fet_miu_itlb_req_credit}), .src_stall({b_fet_miu_itlb_req_stall}),
    .dst_valid({fet_miu_itlb_req_valid}), .dst_payload({fet_miu_itlb_req_payload}),
    .dst_wake(fet_miu_itlb_req_wake), .dst_credit({fet_miu_itlb_req_credit}), .dst_stall({fet_miu_itlb_req_stall})
`ifdef CCV_TRACE
    , .src_tid({b_fet_miu_itlb_req_tid}), .dst_tid({fet_miu_itlb_req_tid})
`endif
  );
  // ccv_rau_fet_launch, destination end
  ccv_seq_rpt #(.STAGES(RPT_RAU_FET_LAUNCH), .SLOTS(1), .PAYLOAD_W(184)) u_rpt_rau_fet_launch (
    .clk(core_clk), .rst_n(rst_n),
    .src_valid({rau_fet_launch_valid}), .src_payload({rau_fet_launch_payload}),
    .src_wake(rau_fet_launch_wake), .src_credit({rau_fet_launch_credit}), .src_stall({rau_fet_launch_stall}),
    .dst_valid({b_rau_fet_launch_valid}), .dst_payload({b_rau_fet_launch_payload}),
    .dst_wake(b_rau_fet_launch_wake), .dst_credit({b_rau_fet_launch_credit}), .dst_stall({b_rau_fet_launch_stall})
`ifdef CCV_TRACE
    , .src_tid({rau_fet_launch_tid}), .dst_tid({b_rau_fet_launch_tid})
`endif
  );
  // ccv_fet_pca_mig, source end
  ccv_seq_rpt #(.STAGES(RPT_FET_PCA_MIG), .SLOTS(1), .PAYLOAD_W(261)) u_rpt_fet_pca_mig (
    .clk(core_clk), .rst_n(rst_n),
    .src_valid({b_fet_pca_mig_valid}), .src_payload({b_fet_pca_mig_payload}),
    .src_wake(b_fet_pca_mig_wake), .src_credit({b_fet_pca_mig_credit}), .src_stall({b_fet_pca_mig_stall}),
    .dst_valid({fet_pca_mig_valid}), .dst_payload({fet_pca_mig_payload}),
    .dst_wake(fet_pca_mig_wake), .dst_credit({fet_pca_mig_credit}), .dst_stall({fet_pca_mig_stall})
`ifdef CCV_TRACE
    , .src_tid({b_fet_pca_mig_tid}), .dst_tid({fet_pca_mig_tid})
`endif
  );
  // ccv_pca_fet_mig, destination end
  ccv_seq_rpt #(.STAGES(RPT_PCA_FET_MIG), .SLOTS(1), .PAYLOAD_W(261)) u_rpt_pca_fet_mig (
    .clk(core_clk), .rst_n(rst_n),
    .src_valid({pca_fet_mig_valid}), .src_payload({pca_fet_mig_payload}),
    .src_wake(pca_fet_mig_wake), .src_credit({pca_fet_mig_credit}), .src_stall({pca_fet_mig_stall}),
    .dst_valid({b_pca_fet_mig_valid}), .dst_payload({b_pca_fet_mig_payload}),
    .dst_wake(b_pca_fet_mig_wake), .dst_credit({b_pca_fet_mig_credit}), .dst_stall({b_pca_fet_mig_stall})
`ifdef CCV_TRACE
    , .src_tid({pca_fet_mig_tid}), .dst_tid({b_pca_fet_mig_tid})
`endif
  );
  // ccv_rau_fet_mig, destination end
  ccv_seq_rpt #(.STAGES(RPT_RAU_FET_MIG), .SLOTS(1), .PAYLOAD_W(9)) u_rpt_rau_fet_mig (
    .clk(core_clk), .rst_n(rst_n),
    .src_valid({rau_fet_mig_valid}), .src_payload({rau_fet_mig_payload}),
    .src_wake(rau_fet_mig_wake), .src_credit({rau_fet_mig_credit}), .src_stall({rau_fet_mig_stall}),
    .dst_valid({b_rau_fet_mig_valid}), .dst_payload({b_rau_fet_mig_payload}),
    .dst_wake(b_rau_fet_mig_wake), .dst_credit({b_rau_fet_mig_credit}), .dst_stall({b_rau_fet_mig_stall})
`ifdef CCV_TRACE
    , .src_tid({rau_fet_mig_tid}), .dst_tid({b_rau_fet_mig_tid})
`endif
  );
endmodule
