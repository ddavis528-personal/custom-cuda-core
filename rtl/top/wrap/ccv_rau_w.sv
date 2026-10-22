// GENERATED FILE -- DO NOT EDIT.
//
// Produced by tools/gen-top.py from schema/interfaces.json and
// params/blocks.json. Edit a source and regenerate; tools/verify.sh fails if
// this file is stale.

// HARDENING WRAPPER ccv_rau_w: ccv_rau and the sequential repeaters of its
// channel ends -- the physical hierarchy (docs/physical.md, "Wrappers
// and links"). Nothing but instances and nets, like the top. An end
// whose link has no stages here is connected straight through.
// Each end's stages are a parameter the top sets from params/links.json;
// at 0 the end is wired straight through, with no repeater.
`include "ccv_interfaces.svh"

module ccv_rau_w #(
  parameter int RPT_RAU_FET_LAUNCH = 0,
  parameter int RPT_RAU_OOE_ALLOC = 0,
  parameter int RPT_OOE_RAU_STATUS = 0,
  parameter int RPT_RAU_OOE_DEMOTE = 0,
  parameter int RPT_OOE_RAU_DRAINED = 0,
  parameter int RPT_RAU_RCU_MIG = 0,
  parameter int RPT_RAU_FET_MIG = 0,
  parameter int RPT_PCA_RAU_MIG_DONE = 0,
  parameter int RPT_RAU_PCA_MIG = 0,
  parameter int RPT_MIU_RAU_READY = 0,
  parameter int RPT_RAU_MIU_CTA = 0,
  parameter int RPT_RAU_SYU_ALLOC = 0,
  parameter int RPT_CRU_RAU_CFG = 0
) (
  `include "ccv_rau_ports.svh"
);

  // Between the block and its repeaters: b_<port>, one net per port.
  logic b_rau_fet_launch_valid;
  ccv_rau_fet_launch_t b_rau_fet_launch_payload;
  logic b_rau_fet_launch_credit;
  logic b_rau_fet_launch_stall;
  logic b_rau_fet_launch_wake;
  logic b_rau_ooe_alloc_valid;
  ccv_rau_ooe_alloc_t b_rau_ooe_alloc_payload;
  logic b_rau_ooe_alloc_credit;
  logic b_rau_ooe_alloc_stall;
  logic b_rau_ooe_alloc_wake;
  logic b_ooe_rau_status_valid;
  ccv_ooe_rau_status_t b_ooe_rau_status_payload;
  logic b_ooe_rau_status_credit;
  logic b_ooe_rau_status_stall;
  logic b_ooe_rau_status_wake;
  logic b_rau_ooe_demote_valid;
  ccv_rau_ooe_demote_t b_rau_ooe_demote_payload;
  logic b_rau_ooe_demote_credit;
  logic b_rau_ooe_demote_stall;
  logic b_rau_ooe_demote_wake;
  logic b_ooe_rau_drained_valid;
  ccv_ooe_rau_drained_t b_ooe_rau_drained_payload;
  logic b_ooe_rau_drained_credit;
  logic b_ooe_rau_drained_stall;
  logic b_ooe_rau_drained_wake;
  logic b_rau_rcu_mig_valid;
  ccv_rau_rcu_mig_t b_rau_rcu_mig_payload;
  logic b_rau_rcu_mig_credit;
  logic b_rau_rcu_mig_stall;
  logic b_rau_rcu_mig_wake;
  logic b_rau_fet_mig_valid;
  ccv_rau_fet_mig_t b_rau_fet_mig_payload;
  logic b_rau_fet_mig_credit;
  logic b_rau_fet_mig_stall;
  logic b_rau_fet_mig_wake;
  logic b_pca_rau_mig_done_valid;
  ccv_pca_rau_mig_done_t b_pca_rau_mig_done_payload;
  logic b_pca_rau_mig_done_credit;
  logic b_pca_rau_mig_done_stall;
  logic b_pca_rau_mig_done_wake;
  logic b_rau_pca_mig_valid;
  ccv_rau_pca_mig_t b_rau_pca_mig_payload;
  logic b_rau_pca_mig_credit;
  logic b_rau_pca_mig_stall;
  logic b_rau_pca_mig_wake;
  logic b_miu_rau_ready_valid;
  ccv_miu_rau_ready_t b_miu_rau_ready_payload;
  logic b_miu_rau_ready_credit;
  logic b_miu_rau_ready_stall;
  logic b_miu_rau_ready_wake;
  logic b_rau_miu_cta_valid;
  ccv_rau_miu_cta_t b_rau_miu_cta_payload;
  logic b_rau_miu_cta_credit;
  logic b_rau_miu_cta_stall;
  logic b_rau_miu_cta_wake;
  logic b_rau_syu_alloc_valid;
  ccv_rau_syu_alloc_t b_rau_syu_alloc_payload;
  logic b_rau_syu_alloc_credit;
  logic b_rau_syu_alloc_stall;
  logic b_rau_syu_alloc_wake;
  logic b_cru_rau_cfg_valid;
  ccv_cru_rau_cfg_t b_cru_rau_cfg_payload;
  logic b_cru_rau_cfg_credit;
  logic b_cru_rau_cfg_stall;
  logic b_cru_rau_cfg_wake;
`ifdef CCV_TRACE
  logic [63:0] b_rau_fet_launch_tid;
  logic [63:0] b_rau_ooe_alloc_tid;
  logic [63:0] b_ooe_rau_status_tid;
  logic [63:0] b_rau_ooe_demote_tid;
  logic [63:0] b_ooe_rau_drained_tid;
  logic [63:0] b_rau_rcu_mig_tid;
  logic [63:0] b_rau_fet_mig_tid;
  logic [63:0] b_pca_rau_mig_done_tid;
  logic [63:0] b_rau_pca_mig_tid;
  logic [63:0] b_miu_rau_ready_tid;
  logic [63:0] b_rau_miu_cta_tid;
  logic [63:0] b_rau_syu_alloc_tid;
  logic [63:0] b_cru_rau_cfg_tid;
`endif

  ccv_rau u_blk (
    .core_clk(core_clk),
    .rst_n(rst_n),
    .kill_valid(kill_valid),
    .kill_warp_mask(kill_warp_mask),
    .kill_epoch(kill_epoch),
    .kill_acks(kill_acks),
    .kill_ack_epochs(kill_ack_epochs),
    .csr_req(csr_req),
    .csr_rsp(csr_rsp),
    .csr_credit(csr_credit),
    .rau_fet_launch_valid(b_rau_fet_launch_valid),
    .rau_fet_launch_payload(b_rau_fet_launch_payload),
    .rau_fet_launch_credit(b_rau_fet_launch_credit),
    .rau_fet_launch_stall(b_rau_fet_launch_stall),
    .rau_fet_launch_wake(b_rau_fet_launch_wake),
    .rau_ooe_alloc_valid(b_rau_ooe_alloc_valid),
    .rau_ooe_alloc_payload(b_rau_ooe_alloc_payload),
    .rau_ooe_alloc_credit(b_rau_ooe_alloc_credit),
    .rau_ooe_alloc_stall(b_rau_ooe_alloc_stall),
    .rau_ooe_alloc_wake(b_rau_ooe_alloc_wake),
    .ooe_rau_status_valid(b_ooe_rau_status_valid),
    .ooe_rau_status_payload(b_ooe_rau_status_payload),
    .ooe_rau_status_credit(b_ooe_rau_status_credit),
    .ooe_rau_status_stall(b_ooe_rau_status_stall),
    .ooe_rau_status_wake(b_ooe_rau_status_wake),
    .rau_ooe_demote_valid(b_rau_ooe_demote_valid),
    .rau_ooe_demote_payload(b_rau_ooe_demote_payload),
    .rau_ooe_demote_credit(b_rau_ooe_demote_credit),
    .rau_ooe_demote_stall(b_rau_ooe_demote_stall),
    .rau_ooe_demote_wake(b_rau_ooe_demote_wake),
    .ooe_rau_drained_valid(b_ooe_rau_drained_valid),
    .ooe_rau_drained_payload(b_ooe_rau_drained_payload),
    .ooe_rau_drained_credit(b_ooe_rau_drained_credit),
    .ooe_rau_drained_stall(b_ooe_rau_drained_stall),
    .ooe_rau_drained_wake(b_ooe_rau_drained_wake),
    .rau_rcu_mig_valid(b_rau_rcu_mig_valid),
    .rau_rcu_mig_payload(b_rau_rcu_mig_payload),
    .rau_rcu_mig_credit(b_rau_rcu_mig_credit),
    .rau_rcu_mig_stall(b_rau_rcu_mig_stall),
    .rau_rcu_mig_wake(b_rau_rcu_mig_wake),
    .rau_fet_mig_valid(b_rau_fet_mig_valid),
    .rau_fet_mig_payload(b_rau_fet_mig_payload),
    .rau_fet_mig_credit(b_rau_fet_mig_credit),
    .rau_fet_mig_stall(b_rau_fet_mig_stall),
    .rau_fet_mig_wake(b_rau_fet_mig_wake),
    .pca_rau_mig_done_valid(b_pca_rau_mig_done_valid),
    .pca_rau_mig_done_payload(b_pca_rau_mig_done_payload),
    .pca_rau_mig_done_credit(b_pca_rau_mig_done_credit),
    .pca_rau_mig_done_stall(b_pca_rau_mig_done_stall),
    .pca_rau_mig_done_wake(b_pca_rau_mig_done_wake),
    .rau_pca_mig_valid(b_rau_pca_mig_valid),
    .rau_pca_mig_payload(b_rau_pca_mig_payload),
    .rau_pca_mig_credit(b_rau_pca_mig_credit),
    .rau_pca_mig_stall(b_rau_pca_mig_stall),
    .rau_pca_mig_wake(b_rau_pca_mig_wake),
    .miu_rau_ready_valid(b_miu_rau_ready_valid),
    .miu_rau_ready_payload(b_miu_rau_ready_payload),
    .miu_rau_ready_credit(b_miu_rau_ready_credit),
    .miu_rau_ready_stall(b_miu_rau_ready_stall),
    .miu_rau_ready_wake(b_miu_rau_ready_wake),
    .rau_miu_cta_valid(b_rau_miu_cta_valid),
    .rau_miu_cta_payload(b_rau_miu_cta_payload),
    .rau_miu_cta_credit(b_rau_miu_cta_credit),
    .rau_miu_cta_stall(b_rau_miu_cta_stall),
    .rau_miu_cta_wake(b_rau_miu_cta_wake),
    .rau_syu_alloc_valid(b_rau_syu_alloc_valid),
    .rau_syu_alloc_payload(b_rau_syu_alloc_payload),
    .rau_syu_alloc_credit(b_rau_syu_alloc_credit),
    .rau_syu_alloc_stall(b_rau_syu_alloc_stall),
    .rau_syu_alloc_wake(b_rau_syu_alloc_wake),
    .cru_rau_cfg_valid(b_cru_rau_cfg_valid),
    .cru_rau_cfg_payload(b_cru_rau_cfg_payload),
    .cru_rau_cfg_credit(b_cru_rau_cfg_credit),
    .cru_rau_cfg_stall(b_cru_rau_cfg_stall),
    .cru_rau_cfg_wake(b_cru_rau_cfg_wake)
`ifdef CCV_CHECK
    , .clk_gated(clk_gated)
`endif
`ifdef CCV_TRACE
    , .rau_fet_launch_tid(b_rau_fet_launch_tid)
    , .rau_ooe_alloc_tid(b_rau_ooe_alloc_tid)
    , .ooe_rau_status_tid(b_ooe_rau_status_tid)
    , .rau_ooe_demote_tid(b_rau_ooe_demote_tid)
    , .ooe_rau_drained_tid(b_ooe_rau_drained_tid)
    , .rau_rcu_mig_tid(b_rau_rcu_mig_tid)
    , .rau_fet_mig_tid(b_rau_fet_mig_tid)
    , .pca_rau_mig_done_tid(b_pca_rau_mig_done_tid)
    , .rau_pca_mig_tid(b_rau_pca_mig_tid)
    , .miu_rau_ready_tid(b_miu_rau_ready_tid)
    , .rau_miu_cta_tid(b_rau_miu_cta_tid)
    , .rau_syu_alloc_tid(b_rau_syu_alloc_tid)
    , .cru_rau_cfg_tid(b_cru_rau_cfg_tid)
`endif
  );

  // ccv_rau_fet_launch, source end
  if (RPT_RAU_FET_LAUNCH > 0) begin : g_rpt_rau_fet_launch
    ccv_common_rpt #(.STAGES(RPT_RAU_FET_LAUNCH), .SLOTS(1), .PAYLOAD_W(218)) u_rpt_rau_fet_launch (
      .clk(core_clk), .rst_n(rst_n),
      .src_valid({b_rau_fet_launch_valid}), .src_payload({b_rau_fet_launch_payload}),
      .src_wake(b_rau_fet_launch_wake), .src_credit({b_rau_fet_launch_credit}), .src_stall({b_rau_fet_launch_stall}),
      .dst_valid({rau_fet_launch_valid}), .dst_payload({rau_fet_launch_payload}),
      .dst_wake(rau_fet_launch_wake), .dst_credit({rau_fet_launch_credit}), .dst_stall({rau_fet_launch_stall})
`ifdef CCV_TRACE
      , .src_tid({b_rau_fet_launch_tid}), .dst_tid({rau_fet_launch_tid})
`endif
    );
  end else begin : g_wire_rau_fet_launch
    assign {rau_fet_launch_valid} = {b_rau_fet_launch_valid};
    assign {rau_fet_launch_payload} = {b_rau_fet_launch_payload};
    assign rau_fet_launch_wake = b_rau_fet_launch_wake;
    assign {b_rau_fet_launch_credit} = {rau_fet_launch_credit};
    assign {b_rau_fet_launch_stall} = {rau_fet_launch_stall};
`ifdef CCV_TRACE
    assign {rau_fet_launch_tid} = {b_rau_fet_launch_tid};
`endif
  end
  // ccv_rau_ooe_alloc, source end
  if (RPT_RAU_OOE_ALLOC > 0) begin : g_rpt_rau_ooe_alloc
    ccv_common_rpt #(.STAGES(RPT_RAU_OOE_ALLOC), .SLOTS(1), .PAYLOAD_W(51)) u_rpt_rau_ooe_alloc (
      .clk(core_clk), .rst_n(rst_n),
      .src_valid({b_rau_ooe_alloc_valid}), .src_payload({b_rau_ooe_alloc_payload}),
      .src_wake(b_rau_ooe_alloc_wake), .src_credit({b_rau_ooe_alloc_credit}), .src_stall({b_rau_ooe_alloc_stall}),
      .dst_valid({rau_ooe_alloc_valid}), .dst_payload({rau_ooe_alloc_payload}),
      .dst_wake(rau_ooe_alloc_wake), .dst_credit({rau_ooe_alloc_credit}), .dst_stall({rau_ooe_alloc_stall})
`ifdef CCV_TRACE
      , .src_tid({b_rau_ooe_alloc_tid}), .dst_tid({rau_ooe_alloc_tid})
`endif
    );
  end else begin : g_wire_rau_ooe_alloc
    assign {rau_ooe_alloc_valid} = {b_rau_ooe_alloc_valid};
    assign {rau_ooe_alloc_payload} = {b_rau_ooe_alloc_payload};
    assign rau_ooe_alloc_wake = b_rau_ooe_alloc_wake;
    assign {b_rau_ooe_alloc_credit} = {rau_ooe_alloc_credit};
    assign {b_rau_ooe_alloc_stall} = {rau_ooe_alloc_stall};
`ifdef CCV_TRACE
    assign {rau_ooe_alloc_tid} = {b_rau_ooe_alloc_tid};
`endif
  end
  // ccv_ooe_rau_status, destination end
  if (RPT_OOE_RAU_STATUS > 0) begin : g_rpt_ooe_rau_status
    ccv_common_rpt #(.STAGES(RPT_OOE_RAU_STATUS), .SLOTS(1), .PAYLOAD_W(17)) u_rpt_ooe_rau_status (
      .clk(core_clk), .rst_n(rst_n),
      .src_valid({ooe_rau_status_valid}), .src_payload({ooe_rau_status_payload}),
      .src_wake(ooe_rau_status_wake), .src_credit({ooe_rau_status_credit}), .src_stall({ooe_rau_status_stall}),
      .dst_valid({b_ooe_rau_status_valid}), .dst_payload({b_ooe_rau_status_payload}),
      .dst_wake(b_ooe_rau_status_wake), .dst_credit({b_ooe_rau_status_credit}), .dst_stall({b_ooe_rau_status_stall})
`ifdef CCV_TRACE
      , .src_tid({ooe_rau_status_tid}), .dst_tid({b_ooe_rau_status_tid})
`endif
    );
  end else begin : g_wire_ooe_rau_status
    assign {b_ooe_rau_status_valid} = {ooe_rau_status_valid};
    assign {b_ooe_rau_status_payload} = {ooe_rau_status_payload};
    assign b_ooe_rau_status_wake = ooe_rau_status_wake;
    assign {ooe_rau_status_credit} = {b_ooe_rau_status_credit};
    assign {ooe_rau_status_stall} = {b_ooe_rau_status_stall};
`ifdef CCV_TRACE
    assign {b_ooe_rau_status_tid} = {ooe_rau_status_tid};
`endif
  end
  // ccv_rau_ooe_demote, source end
  if (RPT_RAU_OOE_DEMOTE > 0) begin : g_rpt_rau_ooe_demote
    ccv_common_rpt #(.STAGES(RPT_RAU_OOE_DEMOTE), .SLOTS(1), .PAYLOAD_W(6)) u_rpt_rau_ooe_demote (
      .clk(core_clk), .rst_n(rst_n),
      .src_valid({b_rau_ooe_demote_valid}), .src_payload({b_rau_ooe_demote_payload}),
      .src_wake(b_rau_ooe_demote_wake), .src_credit({b_rau_ooe_demote_credit}), .src_stall({b_rau_ooe_demote_stall}),
      .dst_valid({rau_ooe_demote_valid}), .dst_payload({rau_ooe_demote_payload}),
      .dst_wake(rau_ooe_demote_wake), .dst_credit({rau_ooe_demote_credit}), .dst_stall({rau_ooe_demote_stall})
`ifdef CCV_TRACE
      , .src_tid({b_rau_ooe_demote_tid}), .dst_tid({rau_ooe_demote_tid})
`endif
    );
  end else begin : g_wire_rau_ooe_demote
    assign {rau_ooe_demote_valid} = {b_rau_ooe_demote_valid};
    assign {rau_ooe_demote_payload} = {b_rau_ooe_demote_payload};
    assign rau_ooe_demote_wake = b_rau_ooe_demote_wake;
    assign {b_rau_ooe_demote_credit} = {rau_ooe_demote_credit};
    assign {b_rau_ooe_demote_stall} = {rau_ooe_demote_stall};
`ifdef CCV_TRACE
    assign {rau_ooe_demote_tid} = {b_rau_ooe_demote_tid};
`endif
  end
  // ccv_ooe_rau_drained, destination end
  if (RPT_OOE_RAU_DRAINED > 0) begin : g_rpt_ooe_rau_drained
    ccv_common_rpt #(.STAGES(RPT_OOE_RAU_DRAINED), .SLOTS(1), .PAYLOAD_W(71)) u_rpt_ooe_rau_drained (
      .clk(core_clk), .rst_n(rst_n),
      .src_valid({ooe_rau_drained_valid}), .src_payload({ooe_rau_drained_payload}),
      .src_wake(ooe_rau_drained_wake), .src_credit({ooe_rau_drained_credit}), .src_stall({ooe_rau_drained_stall}),
      .dst_valid({b_ooe_rau_drained_valid}), .dst_payload({b_ooe_rau_drained_payload}),
      .dst_wake(b_ooe_rau_drained_wake), .dst_credit({b_ooe_rau_drained_credit}), .dst_stall({b_ooe_rau_drained_stall})
`ifdef CCV_TRACE
      , .src_tid({ooe_rau_drained_tid}), .dst_tid({b_ooe_rau_drained_tid})
`endif
    );
  end else begin : g_wire_ooe_rau_drained
    assign {b_ooe_rau_drained_valid} = {ooe_rau_drained_valid};
    assign {b_ooe_rau_drained_payload} = {ooe_rau_drained_payload};
    assign b_ooe_rau_drained_wake = ooe_rau_drained_wake;
    assign {ooe_rau_drained_credit} = {b_ooe_rau_drained_credit};
    assign {ooe_rau_drained_stall} = {b_ooe_rau_drained_stall};
`ifdef CCV_TRACE
    assign {b_ooe_rau_drained_tid} = {ooe_rau_drained_tid};
`endif
  end
  // ccv_rau_rcu_mig, source end
  if (RPT_RAU_RCU_MIG > 0) begin : g_rpt_rau_rcu_mig
    ccv_common_rpt #(.STAGES(RPT_RAU_RCU_MIG), .SLOTS(1), .PAYLOAD_W(6)) u_rpt_rau_rcu_mig (
      .clk(core_clk), .rst_n(rst_n),
      .src_valid({b_rau_rcu_mig_valid}), .src_payload({b_rau_rcu_mig_payload}),
      .src_wake(b_rau_rcu_mig_wake), .src_credit({b_rau_rcu_mig_credit}), .src_stall({b_rau_rcu_mig_stall}),
      .dst_valid({rau_rcu_mig_valid}), .dst_payload({rau_rcu_mig_payload}),
      .dst_wake(rau_rcu_mig_wake), .dst_credit({rau_rcu_mig_credit}), .dst_stall({rau_rcu_mig_stall})
`ifdef CCV_TRACE
      , .src_tid({b_rau_rcu_mig_tid}), .dst_tid({rau_rcu_mig_tid})
`endif
    );
  end else begin : g_wire_rau_rcu_mig
    assign {rau_rcu_mig_valid} = {b_rau_rcu_mig_valid};
    assign {rau_rcu_mig_payload} = {b_rau_rcu_mig_payload};
    assign rau_rcu_mig_wake = b_rau_rcu_mig_wake;
    assign {b_rau_rcu_mig_credit} = {rau_rcu_mig_credit};
    assign {b_rau_rcu_mig_stall} = {rau_rcu_mig_stall};
`ifdef CCV_TRACE
    assign {rau_rcu_mig_tid} = {b_rau_rcu_mig_tid};
`endif
  end
  // ccv_rau_fet_mig, source end
  if (RPT_RAU_FET_MIG > 0) begin : g_rpt_rau_fet_mig
    ccv_common_rpt #(.STAGES(RPT_RAU_FET_MIG), .SLOTS(1), .PAYLOAD_W(8)) u_rpt_rau_fet_mig (
      .clk(core_clk), .rst_n(rst_n),
      .src_valid({b_rau_fet_mig_valid}), .src_payload({b_rau_fet_mig_payload}),
      .src_wake(b_rau_fet_mig_wake), .src_credit({b_rau_fet_mig_credit}), .src_stall({b_rau_fet_mig_stall}),
      .dst_valid({rau_fet_mig_valid}), .dst_payload({rau_fet_mig_payload}),
      .dst_wake(rau_fet_mig_wake), .dst_credit({rau_fet_mig_credit}), .dst_stall({rau_fet_mig_stall})
`ifdef CCV_TRACE
      , .src_tid({b_rau_fet_mig_tid}), .dst_tid({rau_fet_mig_tid})
`endif
    );
  end else begin : g_wire_rau_fet_mig
    assign {rau_fet_mig_valid} = {b_rau_fet_mig_valid};
    assign {rau_fet_mig_payload} = {b_rau_fet_mig_payload};
    assign rau_fet_mig_wake = b_rau_fet_mig_wake;
    assign {b_rau_fet_mig_credit} = {rau_fet_mig_credit};
    assign {b_rau_fet_mig_stall} = {rau_fet_mig_stall};
`ifdef CCV_TRACE
    assign {rau_fet_mig_tid} = {b_rau_fet_mig_tid};
`endif
  end
  // ccv_pca_rau_mig_done, destination end
  if (RPT_PCA_RAU_MIG_DONE > 0) begin : g_rpt_pca_rau_mig_done
    ccv_common_rpt #(.STAGES(RPT_PCA_RAU_MIG_DONE), .SLOTS(1), .PAYLOAD_W(6)) u_rpt_pca_rau_mig_done (
      .clk(core_clk), .rst_n(rst_n),
      .src_valid({pca_rau_mig_done_valid}), .src_payload({pca_rau_mig_done_payload}),
      .src_wake(pca_rau_mig_done_wake), .src_credit({pca_rau_mig_done_credit}), .src_stall({pca_rau_mig_done_stall}),
      .dst_valid({b_pca_rau_mig_done_valid}), .dst_payload({b_pca_rau_mig_done_payload}),
      .dst_wake(b_pca_rau_mig_done_wake), .dst_credit({b_pca_rau_mig_done_credit}), .dst_stall({b_pca_rau_mig_done_stall})
`ifdef CCV_TRACE
      , .src_tid({pca_rau_mig_done_tid}), .dst_tid({b_pca_rau_mig_done_tid})
`endif
    );
  end else begin : g_wire_pca_rau_mig_done
    assign {b_pca_rau_mig_done_valid} = {pca_rau_mig_done_valid};
    assign {b_pca_rau_mig_done_payload} = {pca_rau_mig_done_payload};
    assign b_pca_rau_mig_done_wake = pca_rau_mig_done_wake;
    assign {pca_rau_mig_done_credit} = {b_pca_rau_mig_done_credit};
    assign {pca_rau_mig_done_stall} = {b_pca_rau_mig_done_stall};
`ifdef CCV_TRACE
    assign {b_pca_rau_mig_done_tid} = {pca_rau_mig_done_tid};
`endif
  end
  // ccv_rau_pca_mig, source end
  if (RPT_RAU_PCA_MIG > 0) begin : g_rpt_rau_pca_mig
    ccv_common_rpt #(.STAGES(RPT_RAU_PCA_MIG), .SLOTS(1), .PAYLOAD_W(11)) u_rpt_rau_pca_mig (
      .clk(core_clk), .rst_n(rst_n),
      .src_valid({b_rau_pca_mig_valid}), .src_payload({b_rau_pca_mig_payload}),
      .src_wake(b_rau_pca_mig_wake), .src_credit({b_rau_pca_mig_credit}), .src_stall({b_rau_pca_mig_stall}),
      .dst_valid({rau_pca_mig_valid}), .dst_payload({rau_pca_mig_payload}),
      .dst_wake(rau_pca_mig_wake), .dst_credit({rau_pca_mig_credit}), .dst_stall({rau_pca_mig_stall})
`ifdef CCV_TRACE
      , .src_tid({b_rau_pca_mig_tid}), .dst_tid({rau_pca_mig_tid})
`endif
    );
  end else begin : g_wire_rau_pca_mig
    assign {rau_pca_mig_valid} = {b_rau_pca_mig_valid};
    assign {rau_pca_mig_payload} = {b_rau_pca_mig_payload};
    assign rau_pca_mig_wake = b_rau_pca_mig_wake;
    assign {b_rau_pca_mig_credit} = {rau_pca_mig_credit};
    assign {b_rau_pca_mig_stall} = {rau_pca_mig_stall};
`ifdef CCV_TRACE
    assign {rau_pca_mig_tid} = {b_rau_pca_mig_tid};
`endif
  end
  // ccv_miu_rau_ready, destination end
  if (RPT_MIU_RAU_READY > 0) begin : g_rpt_miu_rau_ready
    ccv_common_rpt #(.STAGES(RPT_MIU_RAU_READY), .SLOTS(1), .PAYLOAD_W(5)) u_rpt_miu_rau_ready (
      .clk(core_clk), .rst_n(rst_n),
      .src_valid({miu_rau_ready_valid}), .src_payload({miu_rau_ready_payload}),
      .src_wake(miu_rau_ready_wake), .src_credit({miu_rau_ready_credit}), .src_stall({miu_rau_ready_stall}),
      .dst_valid({b_miu_rau_ready_valid}), .dst_payload({b_miu_rau_ready_payload}),
      .dst_wake(b_miu_rau_ready_wake), .dst_credit({b_miu_rau_ready_credit}), .dst_stall({b_miu_rau_ready_stall})
`ifdef CCV_TRACE
      , .src_tid({miu_rau_ready_tid}), .dst_tid({b_miu_rau_ready_tid})
`endif
    );
  end else begin : g_wire_miu_rau_ready
    assign {b_miu_rau_ready_valid} = {miu_rau_ready_valid};
    assign {b_miu_rau_ready_payload} = {miu_rau_ready_payload};
    assign b_miu_rau_ready_wake = miu_rau_ready_wake;
    assign {miu_rau_ready_credit} = {b_miu_rau_ready_credit};
    assign {miu_rau_ready_stall} = {b_miu_rau_ready_stall};
`ifdef CCV_TRACE
    assign {b_miu_rau_ready_tid} = {miu_rau_ready_tid};
`endif
  end
  // ccv_rau_miu_cta, source end
  if (RPT_RAU_MIU_CTA > 0) begin : g_rpt_rau_miu_cta
    ccv_common_rpt #(.STAGES(RPT_RAU_MIU_CTA), .SLOTS(1), .PAYLOAD_W(101)) u_rpt_rau_miu_cta (
      .clk(core_clk), .rst_n(rst_n),
      .src_valid({b_rau_miu_cta_valid}), .src_payload({b_rau_miu_cta_payload}),
      .src_wake(b_rau_miu_cta_wake), .src_credit({b_rau_miu_cta_credit}), .src_stall({b_rau_miu_cta_stall}),
      .dst_valid({rau_miu_cta_valid}), .dst_payload({rau_miu_cta_payload}),
      .dst_wake(rau_miu_cta_wake), .dst_credit({rau_miu_cta_credit}), .dst_stall({rau_miu_cta_stall})
`ifdef CCV_TRACE
      , .src_tid({b_rau_miu_cta_tid}), .dst_tid({rau_miu_cta_tid})
`endif
    );
  end else begin : g_wire_rau_miu_cta
    assign {rau_miu_cta_valid} = {b_rau_miu_cta_valid};
    assign {rau_miu_cta_payload} = {b_rau_miu_cta_payload};
    assign rau_miu_cta_wake = b_rau_miu_cta_wake;
    assign {b_rau_miu_cta_credit} = {rau_miu_cta_credit};
    assign {b_rau_miu_cta_stall} = {rau_miu_cta_stall};
`ifdef CCV_TRACE
    assign {rau_miu_cta_tid} = {b_rau_miu_cta_tid};
`endif
  end
  // ccv_rau_syu_alloc, source end
  if (RPT_RAU_SYU_ALLOC > 0) begin : g_rpt_rau_syu_alloc
    ccv_common_rpt #(.STAGES(RPT_RAU_SYU_ALLOC), .SLOTS(1), .PAYLOAD_W(15)) u_rpt_rau_syu_alloc (
      .clk(core_clk), .rst_n(rst_n),
      .src_valid({b_rau_syu_alloc_valid}), .src_payload({b_rau_syu_alloc_payload}),
      .src_wake(b_rau_syu_alloc_wake), .src_credit({b_rau_syu_alloc_credit}), .src_stall({b_rau_syu_alloc_stall}),
      .dst_valid({rau_syu_alloc_valid}), .dst_payload({rau_syu_alloc_payload}),
      .dst_wake(rau_syu_alloc_wake), .dst_credit({rau_syu_alloc_credit}), .dst_stall({rau_syu_alloc_stall})
`ifdef CCV_TRACE
      , .src_tid({b_rau_syu_alloc_tid}), .dst_tid({rau_syu_alloc_tid})
`endif
    );
  end else begin : g_wire_rau_syu_alloc
    assign {rau_syu_alloc_valid} = {b_rau_syu_alloc_valid};
    assign {rau_syu_alloc_payload} = {b_rau_syu_alloc_payload};
    assign rau_syu_alloc_wake = b_rau_syu_alloc_wake;
    assign {b_rau_syu_alloc_credit} = {rau_syu_alloc_credit};
    assign {b_rau_syu_alloc_stall} = {rau_syu_alloc_stall};
`ifdef CCV_TRACE
    assign {rau_syu_alloc_tid} = {b_rau_syu_alloc_tid};
`endif
  end
  // ccv_cru_rau_cfg, destination end
  if (RPT_CRU_RAU_CFG > 0) begin : g_rpt_cru_rau_cfg
    ccv_common_rpt #(.STAGES(RPT_CRU_RAU_CFG), .SLOTS(1), .PAYLOAD_W(74)) u_rpt_cru_rau_cfg (
      .clk(core_clk), .rst_n(rst_n),
      .src_valid({cru_rau_cfg_valid}), .src_payload({cru_rau_cfg_payload}),
      .src_wake(cru_rau_cfg_wake), .src_credit({cru_rau_cfg_credit}), .src_stall({cru_rau_cfg_stall}),
      .dst_valid({b_cru_rau_cfg_valid}), .dst_payload({b_cru_rau_cfg_payload}),
      .dst_wake(b_cru_rau_cfg_wake), .dst_credit({b_cru_rau_cfg_credit}), .dst_stall({b_cru_rau_cfg_stall})
`ifdef CCV_TRACE
      , .src_tid({cru_rau_cfg_tid}), .dst_tid({b_cru_rau_cfg_tid})
`endif
    );
  end else begin : g_wire_cru_rau_cfg
    assign {b_cru_rau_cfg_valid} = {cru_rau_cfg_valid};
    assign {b_cru_rau_cfg_payload} = {cru_rau_cfg_payload};
    assign b_cru_rau_cfg_wake = cru_rau_cfg_wake;
    assign {cru_rau_cfg_credit} = {b_cru_rau_cfg_credit};
    assign {cru_rau_cfg_stall} = {b_cru_rau_cfg_stall};
`ifdef CCV_TRACE
    assign {b_cru_rau_cfg_tid} = {cru_rau_cfg_tid};
`endif
  end
endmodule
