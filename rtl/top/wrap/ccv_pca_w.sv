// GENERATED FILE -- DO NOT EDIT.
//
// Produced by tools/gen-top.py from schema/interfaces.json and
// params/blocks.json. Edit a source and regenerate; tools/verify.sh fails if
// this file is stale.

// HARDENING WRAPPER ccv_pca_w: ccv_pca and the sequential repeaters of its
// channel ends -- the physical hierarchy (docs/physical.md, "Wrappers
// and links"). Nothing but instances and nets, like the top. An end
// whose link has no stages here is connected straight through.
// Each end's stages are a parameter the top sets from params/links.json;
// at 0 the end is wired straight through, with no repeater.
`include "ccv_interfaces.svh"

module ccv_pca_w #(
  parameter int RPT_RCU_PCA_MIG = 0,
  parameter int RPT_PCA_RCU_MIG = 0,
  parameter int RPT_FET_PCA_MIG = 0,
  parameter int RPT_PCA_FET_MIG = 0,
  parameter int RPT_PCA_RAU_MIG_DONE = 0,
  parameter int RPT_RAU_PCA_MIG = 0
) (
  `include "ccv_pca_ports.svh"
);

  // Between the block and its repeaters: b_<port>, one net per port.
  logic b_rcu_pca_mig_valid;
  ccv_rcu_pca_mig_t b_rcu_pca_mig_payload;
  logic b_rcu_pca_mig_credit;
  logic b_rcu_pca_mig_stall;
  logic b_rcu_pca_mig_wake;
  logic b_pca_rcu_mig_valid;
  ccv_pca_rcu_mig_t b_pca_rcu_mig_payload;
  logic b_pca_rcu_mig_credit;
  logic b_pca_rcu_mig_stall;
  logic b_pca_rcu_mig_wake;
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
`ifdef CCV_TRACE
  logic [63:0] b_rcu_pca_mig_tid;
  logic [63:0] b_pca_rcu_mig_tid;
  logic [63:0] b_fet_pca_mig_tid;
  logic [63:0] b_pca_fet_mig_tid;
  logic [63:0] b_pca_rau_mig_done_tid;
  logic [63:0] b_rau_pca_mig_tid;
`endif

  ccv_pca u_blk (
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
    .rcu_pca_mig_valid(b_rcu_pca_mig_valid),
    .rcu_pca_mig_payload(b_rcu_pca_mig_payload),
    .rcu_pca_mig_credit(b_rcu_pca_mig_credit),
    .rcu_pca_mig_stall(b_rcu_pca_mig_stall),
    .rcu_pca_mig_wake(b_rcu_pca_mig_wake),
    .pca_rcu_mig_valid(b_pca_rcu_mig_valid),
    .pca_rcu_mig_payload(b_pca_rcu_mig_payload),
    .pca_rcu_mig_credit(b_pca_rcu_mig_credit),
    .pca_rcu_mig_stall(b_pca_rcu_mig_stall),
    .pca_rcu_mig_wake(b_pca_rcu_mig_wake),
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
    .pca_rau_mig_done_valid(b_pca_rau_mig_done_valid),
    .pca_rau_mig_done_payload(b_pca_rau_mig_done_payload),
    .pca_rau_mig_done_credit(b_pca_rau_mig_done_credit),
    .pca_rau_mig_done_stall(b_pca_rau_mig_done_stall),
    .pca_rau_mig_done_wake(b_pca_rau_mig_done_wake),
    .rau_pca_mig_valid(b_rau_pca_mig_valid),
    .rau_pca_mig_payload(b_rau_pca_mig_payload),
    .rau_pca_mig_credit(b_rau_pca_mig_credit),
    .rau_pca_mig_stall(b_rau_pca_mig_stall),
    .rau_pca_mig_wake(b_rau_pca_mig_wake)
`ifdef CCV_CHECK
    , .clk_gated(clk_gated)
`endif
`ifdef CCV_TRACE
    , .rcu_pca_mig_tid(b_rcu_pca_mig_tid)
    , .pca_rcu_mig_tid(b_pca_rcu_mig_tid)
    , .fet_pca_mig_tid(b_fet_pca_mig_tid)
    , .pca_fet_mig_tid(b_pca_fet_mig_tid)
    , .pca_rau_mig_done_tid(b_pca_rau_mig_done_tid)
    , .rau_pca_mig_tid(b_rau_pca_mig_tid)
`endif
  );

  // ccv_rcu_pca_mig, destination end
  if (RPT_RCU_PCA_MIG > 0) begin : g_rpt_rcu_pca_mig
    ccv_common_rpt #(.STAGES(RPT_RCU_PCA_MIG), .SLOTS(1), .PAYLOAD_W(1034)) u_rpt_rcu_pca_mig (
      .clk(core_clk), .rst_n(rst_n),
      .src_valid({rcu_pca_mig_valid}), .src_payload({rcu_pca_mig_payload}),
      .src_wake(rcu_pca_mig_wake), .src_credit({rcu_pca_mig_credit}), .src_stall({rcu_pca_mig_stall}),
      .dst_valid({b_rcu_pca_mig_valid}), .dst_payload({b_rcu_pca_mig_payload}),
      .dst_wake(b_rcu_pca_mig_wake), .dst_credit({b_rcu_pca_mig_credit}), .dst_stall({b_rcu_pca_mig_stall})
`ifdef CCV_TRACE
      , .src_tid({rcu_pca_mig_tid}), .dst_tid({b_rcu_pca_mig_tid})
`endif
    );
  end else begin : g_wire_rcu_pca_mig
    assign {b_rcu_pca_mig_valid} = {rcu_pca_mig_valid};
    assign {b_rcu_pca_mig_payload} = {rcu_pca_mig_payload};
    assign b_rcu_pca_mig_wake = rcu_pca_mig_wake;
    assign {rcu_pca_mig_credit} = {b_rcu_pca_mig_credit};
    assign {rcu_pca_mig_stall} = {b_rcu_pca_mig_stall};
`ifdef CCV_TRACE
    assign {b_rcu_pca_mig_tid} = {rcu_pca_mig_tid};
`endif
  end
  // ccv_pca_rcu_mig, source end
  if (RPT_PCA_RCU_MIG > 0) begin : g_rpt_pca_rcu_mig
    ccv_common_rpt #(.STAGES(RPT_PCA_RCU_MIG), .SLOTS(1), .PAYLOAD_W(1034)) u_rpt_pca_rcu_mig (
      .clk(core_clk), .rst_n(rst_n),
      .src_valid({b_pca_rcu_mig_valid}), .src_payload({b_pca_rcu_mig_payload}),
      .src_wake(b_pca_rcu_mig_wake), .src_credit({b_pca_rcu_mig_credit}), .src_stall({b_pca_rcu_mig_stall}),
      .dst_valid({pca_rcu_mig_valid}), .dst_payload({pca_rcu_mig_payload}),
      .dst_wake(pca_rcu_mig_wake), .dst_credit({pca_rcu_mig_credit}), .dst_stall({pca_rcu_mig_stall})
`ifdef CCV_TRACE
      , .src_tid({b_pca_rcu_mig_tid}), .dst_tid({pca_rcu_mig_tid})
`endif
    );
  end else begin : g_wire_pca_rcu_mig
    assign {pca_rcu_mig_valid} = {b_pca_rcu_mig_valid};
    assign {pca_rcu_mig_payload} = {b_pca_rcu_mig_payload};
    assign pca_rcu_mig_wake = b_pca_rcu_mig_wake;
    assign {b_pca_rcu_mig_credit} = {pca_rcu_mig_credit};
    assign {b_pca_rcu_mig_stall} = {pca_rcu_mig_stall};
`ifdef CCV_TRACE
    assign {pca_rcu_mig_tid} = {b_pca_rcu_mig_tid};
`endif
  end
  // ccv_fet_pca_mig, destination end
  if (RPT_FET_PCA_MIG > 0) begin : g_rpt_fet_pca_mig
    ccv_common_rpt #(.STAGES(RPT_FET_PCA_MIG), .SLOTS(1), .PAYLOAD_W(1056)) u_rpt_fet_pca_mig (
      .clk(core_clk), .rst_n(rst_n),
      .src_valid({fet_pca_mig_valid}), .src_payload({fet_pca_mig_payload}),
      .src_wake(fet_pca_mig_wake), .src_credit({fet_pca_mig_credit}), .src_stall({fet_pca_mig_stall}),
      .dst_valid({b_fet_pca_mig_valid}), .dst_payload({b_fet_pca_mig_payload}),
      .dst_wake(b_fet_pca_mig_wake), .dst_credit({b_fet_pca_mig_credit}), .dst_stall({b_fet_pca_mig_stall})
`ifdef CCV_TRACE
      , .src_tid({fet_pca_mig_tid}), .dst_tid({b_fet_pca_mig_tid})
`endif
    );
  end else begin : g_wire_fet_pca_mig
    assign {b_fet_pca_mig_valid} = {fet_pca_mig_valid};
    assign {b_fet_pca_mig_payload} = {fet_pca_mig_payload};
    assign b_fet_pca_mig_wake = fet_pca_mig_wake;
    assign {fet_pca_mig_credit} = {b_fet_pca_mig_credit};
    assign {fet_pca_mig_stall} = {b_fet_pca_mig_stall};
`ifdef CCV_TRACE
    assign {b_fet_pca_mig_tid} = {fet_pca_mig_tid};
`endif
  end
  // ccv_pca_fet_mig, source end
  if (RPT_PCA_FET_MIG > 0) begin : g_rpt_pca_fet_mig
    ccv_common_rpt #(.STAGES(RPT_PCA_FET_MIG), .SLOTS(1), .PAYLOAD_W(1056)) u_rpt_pca_fet_mig (
      .clk(core_clk), .rst_n(rst_n),
      .src_valid({b_pca_fet_mig_valid}), .src_payload({b_pca_fet_mig_payload}),
      .src_wake(b_pca_fet_mig_wake), .src_credit({b_pca_fet_mig_credit}), .src_stall({b_pca_fet_mig_stall}),
      .dst_valid({pca_fet_mig_valid}), .dst_payload({pca_fet_mig_payload}),
      .dst_wake(pca_fet_mig_wake), .dst_credit({pca_fet_mig_credit}), .dst_stall({pca_fet_mig_stall})
`ifdef CCV_TRACE
      , .src_tid({b_pca_fet_mig_tid}), .dst_tid({pca_fet_mig_tid})
`endif
    );
  end else begin : g_wire_pca_fet_mig
    assign {pca_fet_mig_valid} = {b_pca_fet_mig_valid};
    assign {pca_fet_mig_payload} = {b_pca_fet_mig_payload};
    assign pca_fet_mig_wake = b_pca_fet_mig_wake;
    assign {b_pca_fet_mig_credit} = {pca_fet_mig_credit};
    assign {b_pca_fet_mig_stall} = {pca_fet_mig_stall};
`ifdef CCV_TRACE
    assign {pca_fet_mig_tid} = {b_pca_fet_mig_tid};
`endif
  end
  // ccv_pca_rau_mig_done, source end
  if (RPT_PCA_RAU_MIG_DONE > 0) begin : g_rpt_pca_rau_mig_done
    ccv_common_rpt #(.STAGES(RPT_PCA_RAU_MIG_DONE), .SLOTS(1), .PAYLOAD_W(6)) u_rpt_pca_rau_mig_done (
      .clk(core_clk), .rst_n(rst_n),
      .src_valid({b_pca_rau_mig_done_valid}), .src_payload({b_pca_rau_mig_done_payload}),
      .src_wake(b_pca_rau_mig_done_wake), .src_credit({b_pca_rau_mig_done_credit}), .src_stall({b_pca_rau_mig_done_stall}),
      .dst_valid({pca_rau_mig_done_valid}), .dst_payload({pca_rau_mig_done_payload}),
      .dst_wake(pca_rau_mig_done_wake), .dst_credit({pca_rau_mig_done_credit}), .dst_stall({pca_rau_mig_done_stall})
`ifdef CCV_TRACE
      , .src_tid({b_pca_rau_mig_done_tid}), .dst_tid({pca_rau_mig_done_tid})
`endif
    );
  end else begin : g_wire_pca_rau_mig_done
    assign {pca_rau_mig_done_valid} = {b_pca_rau_mig_done_valid};
    assign {pca_rau_mig_done_payload} = {b_pca_rau_mig_done_payload};
    assign pca_rau_mig_done_wake = b_pca_rau_mig_done_wake;
    assign {b_pca_rau_mig_done_credit} = {pca_rau_mig_done_credit};
    assign {b_pca_rau_mig_done_stall} = {pca_rau_mig_done_stall};
`ifdef CCV_TRACE
    assign {pca_rau_mig_done_tid} = {b_pca_rau_mig_done_tid};
`endif
  end
  // ccv_rau_pca_mig, destination end
  if (RPT_RAU_PCA_MIG > 0) begin : g_rpt_rau_pca_mig
    ccv_common_rpt #(.STAGES(RPT_RAU_PCA_MIG), .SLOTS(1), .PAYLOAD_W(11)) u_rpt_rau_pca_mig (
      .clk(core_clk), .rst_n(rst_n),
      .src_valid({rau_pca_mig_valid}), .src_payload({rau_pca_mig_payload}),
      .src_wake(rau_pca_mig_wake), .src_credit({rau_pca_mig_credit}), .src_stall({rau_pca_mig_stall}),
      .dst_valid({b_rau_pca_mig_valid}), .dst_payload({b_rau_pca_mig_payload}),
      .dst_wake(b_rau_pca_mig_wake), .dst_credit({b_rau_pca_mig_credit}), .dst_stall({b_rau_pca_mig_stall})
`ifdef CCV_TRACE
      , .src_tid({rau_pca_mig_tid}), .dst_tid({b_rau_pca_mig_tid})
`endif
    );
  end else begin : g_wire_rau_pca_mig
    assign {b_rau_pca_mig_valid} = {rau_pca_mig_valid};
    assign {b_rau_pca_mig_payload} = {rau_pca_mig_payload};
    assign b_rau_pca_mig_wake = rau_pca_mig_wake;
    assign {rau_pca_mig_credit} = {b_rau_pca_mig_credit};
    assign {rau_pca_mig_stall} = {b_rau_pca_mig_stall};
`ifdef CCV_TRACE
    assign {b_rau_pca_mig_tid} = {rau_pca_mig_tid};
`endif
  end
endmodule
