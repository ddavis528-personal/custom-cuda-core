// GENERATED FILE -- DO NOT EDIT.
//
// Produced by tools/gen-top.py from schema/interfaces.json and
// params/blocks.json. Edit a source and regenerate; tools/verify.sh fails if
// this file is stale.

// HARDENING WRAPPER ccv_lane_w: ccv_lane and the sequential repeaters of its
// channel ends -- the physical hierarchy (docs/physical.md, "Wrappers
// and links"). Nothing but instances and nets, like the top. Every
// end has its repeater whether or not the link is repeated.
//
// A HARD-REUSE TEMPLATE (params/links.json hard_reuse): its stages
// are fixed here, so every instance that holds the same is this one
// module with no parameters -- one hard macro. Used by:
//   lane_00, lane_01, lane_02, lane_03, lane_04, lane_05, lane_06,
//   lane_07, lane_08, lane_09, lane_10, lane_11, lane_12, lane_13,
//   lane_14, lane_15, lane_16, lane_17, lane_18, lane_19, lane_20,
//   lane_21, lane_22, lane_23, lane_24, lane_25, lane_26, lane_27,
//   lane_28, lane_29, lane_30, lane_31
`include "ccv_interfaces.svh"

module ccv_lane_w (
  `include "ccv_lane_ports.svh"
);

  // This template's stages, fixed.
  localparam int RPT_RCU_LANE_OPS = 0;
  localparam int RPT_LANE_RCU_RES = 0;

  // Between the block and its repeaters: b_<port>, one net per port.
  logic b_rcu_lane_ops_valid;
  ccv_rcu_lane_ops_t b_rcu_lane_ops_payload;
  logic b_rcu_lane_ops_credit;
  logic b_rcu_lane_ops_stall;
  logic b_rcu_lane_ops_wake;
  logic b_lane_rcu_res_valid;
  ccv_lane_rcu_res_t b_lane_rcu_res_payload;
  logic b_lane_rcu_res_credit;
  logic b_lane_rcu_res_stall;
  logic b_lane_rcu_res_wake;
`ifdef CCV_TRACE
  logic [63:0] b_rcu_lane_ops_tid;
  logic [63:0] b_lane_rcu_res_tid;
`endif

  ccv_lane u_blk (
    .core_clk(core_clk),
    .rst_n(rst_n),
    .csr_req(csr_req),
    .csr_rsp(csr_rsp),
    .csr_credit(csr_credit),
    .rcu_lane_ops_valid(b_rcu_lane_ops_valid),
    .rcu_lane_ops_payload(b_rcu_lane_ops_payload),
    .rcu_lane_ops_credit(b_rcu_lane_ops_credit),
    .rcu_lane_ops_stall(b_rcu_lane_ops_stall),
    .rcu_lane_ops_wake(b_rcu_lane_ops_wake),
    .lane_rcu_res_valid(b_lane_rcu_res_valid),
    .lane_rcu_res_payload(b_lane_rcu_res_payload),
    .lane_rcu_res_credit(b_lane_rcu_res_credit),
    .lane_rcu_res_stall(b_lane_rcu_res_stall),
    .lane_rcu_res_wake(b_lane_rcu_res_wake)
`ifdef CCV_CHECK
    , .clk_gated(clk_gated)
`endif
`ifdef CCV_TRACE
    , .rcu_lane_ops_tid(b_rcu_lane_ops_tid)
    , .lane_rcu_res_tid(b_lane_rcu_res_tid)
`endif
  );

  // ccv_rcu_lane_ops, destination end
  ccv_seq_rpt #(.STAGES(RPT_RCU_LANE_OPS), .SLOTS(1), .PAYLOAD_W(344), .LEAD_MASK(344'hfffff0000000000000000000000000000000000000000)) u_rpt_rcu_lane_ops (
    .clk(core_clk), .rst_n(rst_n),
    .src_valid({rcu_lane_ops_valid}), .src_payload({rcu_lane_ops_payload}),
    .src_wake(rcu_lane_ops_wake), .src_credit({rcu_lane_ops_credit}), .src_stall({rcu_lane_ops_stall}),
    .dst_valid({b_rcu_lane_ops_valid}), .dst_payload({b_rcu_lane_ops_payload}),
    .dst_wake(b_rcu_lane_ops_wake), .dst_credit({b_rcu_lane_ops_credit}), .dst_stall({b_rcu_lane_ops_stall})
`ifdef CCV_TRACE
    , .src_tid({rcu_lane_ops_tid}), .dst_tid({b_rcu_lane_ops_tid})
`endif
  );
  // ccv_lane_rcu_res, source end
  ccv_seq_rpt #(.STAGES(RPT_LANE_RCU_RES), .SLOTS(1), .PAYLOAD_W(44)) u_rpt_lane_rcu_res (
    .clk(core_clk), .rst_n(rst_n),
    .src_valid({b_lane_rcu_res_valid}), .src_payload({b_lane_rcu_res_payload}),
    .src_wake(b_lane_rcu_res_wake), .src_credit({b_lane_rcu_res_credit}), .src_stall({b_lane_rcu_res_stall}),
    .dst_valid({lane_rcu_res_valid}), .dst_payload({lane_rcu_res_payload}),
    .dst_wake(lane_rcu_res_wake), .dst_credit({lane_rcu_res_credit}), .dst_stall({lane_rcu_res_stall})
`ifdef CCV_TRACE
    , .src_tid({b_lane_rcu_res_tid}), .dst_tid({lane_rcu_res_tid})
`endif
  );
endmodule
