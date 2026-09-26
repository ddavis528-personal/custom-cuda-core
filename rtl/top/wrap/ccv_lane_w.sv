// GENERATED FILE -- DO NOT EDIT.
//
// Produced by tools/gen-top.py from schema/interfaces.json and
// params/blocks.json. Edit a source and regenerate; tools/verify.sh fails if
// this file is stale.

// HARDENING WRAPPER ccv_lane_w: ccv_lane and the sequential repeaters of its
// channel ends -- the physical hierarchy (docs/physical.md, "Wrappers
// and links"). Nothing but instances and nets, like the top. Every
// end has its repeater whether or not the link is repeated: STAGES is
// a parameter the top sets from params/links.json, 0 meaning wires, so
// a new split changes parameters and never this structure.
`include "ccv_interfaces.svh"

module ccv_lane_w #(
  parameter int RPT_RCU_LANE_OPS = 0,
  parameter int RPT_LANE_RCU_RES = 0
) (
  `include "ccv_lane_ports.svh"
);

  // Between the block and its repeaters: b_<port>, one net per port.
  logic b_rcu_lane_ops_s0_valid;
  ccv_rcu_lane_ops_t b_rcu_lane_ops_s0_payload;
  logic b_rcu_lane_ops_s0_credit;
  logic b_rcu_lane_ops_s0_stall;
  logic b_rcu_lane_ops_s1_valid;
  ccv_rcu_lane_ops_t b_rcu_lane_ops_s1_payload;
  logic b_rcu_lane_ops_s1_credit;
  logic b_rcu_lane_ops_s1_stall;
  logic b_rcu_lane_ops_s2_valid;
  ccv_rcu_lane_ops_t b_rcu_lane_ops_s2_payload;
  logic b_rcu_lane_ops_s2_credit;
  logic b_rcu_lane_ops_s2_stall;
  logic b_rcu_lane_ops_s3_valid;
  ccv_rcu_lane_ops_t b_rcu_lane_ops_s3_payload;
  logic b_rcu_lane_ops_s3_credit;
  logic b_rcu_lane_ops_s3_stall;
  logic b_rcu_lane_ops_wake;
  logic b_lane_rcu_res_s0_valid;
  ccv_lane_rcu_res_t b_lane_rcu_res_s0_payload;
  logic b_lane_rcu_res_s0_credit;
  logic b_lane_rcu_res_s0_stall;
  logic b_lane_rcu_res_s1_valid;
  ccv_lane_rcu_res_t b_lane_rcu_res_s1_payload;
  logic b_lane_rcu_res_s1_credit;
  logic b_lane_rcu_res_s1_stall;
  logic b_lane_rcu_res_s2_valid;
  ccv_lane_rcu_res_t b_lane_rcu_res_s2_payload;
  logic b_lane_rcu_res_s2_credit;
  logic b_lane_rcu_res_s2_stall;
  logic b_lane_rcu_res_s3_valid;
  ccv_lane_rcu_res_t b_lane_rcu_res_s3_payload;
  logic b_lane_rcu_res_s3_credit;
  logic b_lane_rcu_res_s3_stall;
  logic b_lane_rcu_res_wake;
`ifdef CCV_TRACE
  logic [63:0] b_rcu_lane_ops_s0_tid;
  logic [63:0] b_rcu_lane_ops_s1_tid;
  logic [63:0] b_rcu_lane_ops_s2_tid;
  logic [63:0] b_rcu_lane_ops_s3_tid;
  logic [63:0] b_lane_rcu_res_s0_tid;
  logic [63:0] b_lane_rcu_res_s1_tid;
  logic [63:0] b_lane_rcu_res_s2_tid;
  logic [63:0] b_lane_rcu_res_s3_tid;
`endif

  ccv_lane u_blk (
    .core_clk(core_clk),
    .rst_n(rst_n),
    .csr_req(csr_req),
    .csr_rsp(csr_rsp),
    .csr_credit(csr_credit),
    .rcu_lane_ops_s0_valid(b_rcu_lane_ops_s0_valid),
    .rcu_lane_ops_s0_payload(b_rcu_lane_ops_s0_payload),
    .rcu_lane_ops_s0_credit(b_rcu_lane_ops_s0_credit),
    .rcu_lane_ops_s0_stall(b_rcu_lane_ops_s0_stall),
    .rcu_lane_ops_s1_valid(b_rcu_lane_ops_s1_valid),
    .rcu_lane_ops_s1_payload(b_rcu_lane_ops_s1_payload),
    .rcu_lane_ops_s1_credit(b_rcu_lane_ops_s1_credit),
    .rcu_lane_ops_s1_stall(b_rcu_lane_ops_s1_stall),
    .rcu_lane_ops_s2_valid(b_rcu_lane_ops_s2_valid),
    .rcu_lane_ops_s2_payload(b_rcu_lane_ops_s2_payload),
    .rcu_lane_ops_s2_credit(b_rcu_lane_ops_s2_credit),
    .rcu_lane_ops_s2_stall(b_rcu_lane_ops_s2_stall),
    .rcu_lane_ops_s3_valid(b_rcu_lane_ops_s3_valid),
    .rcu_lane_ops_s3_payload(b_rcu_lane_ops_s3_payload),
    .rcu_lane_ops_s3_credit(b_rcu_lane_ops_s3_credit),
    .rcu_lane_ops_s3_stall(b_rcu_lane_ops_s3_stall),
    .rcu_lane_ops_wake(b_rcu_lane_ops_wake),
    .lane_rcu_res_s0_valid(b_lane_rcu_res_s0_valid),
    .lane_rcu_res_s0_payload(b_lane_rcu_res_s0_payload),
    .lane_rcu_res_s0_credit(b_lane_rcu_res_s0_credit),
    .lane_rcu_res_s0_stall(b_lane_rcu_res_s0_stall),
    .lane_rcu_res_s1_valid(b_lane_rcu_res_s1_valid),
    .lane_rcu_res_s1_payload(b_lane_rcu_res_s1_payload),
    .lane_rcu_res_s1_credit(b_lane_rcu_res_s1_credit),
    .lane_rcu_res_s1_stall(b_lane_rcu_res_s1_stall),
    .lane_rcu_res_s2_valid(b_lane_rcu_res_s2_valid),
    .lane_rcu_res_s2_payload(b_lane_rcu_res_s2_payload),
    .lane_rcu_res_s2_credit(b_lane_rcu_res_s2_credit),
    .lane_rcu_res_s2_stall(b_lane_rcu_res_s2_stall),
    .lane_rcu_res_s3_valid(b_lane_rcu_res_s3_valid),
    .lane_rcu_res_s3_payload(b_lane_rcu_res_s3_payload),
    .lane_rcu_res_s3_credit(b_lane_rcu_res_s3_credit),
    .lane_rcu_res_s3_stall(b_lane_rcu_res_s3_stall),
    .lane_rcu_res_wake(b_lane_rcu_res_wake)
`ifdef CCV_CHECK
    , .clk_gated(clk_gated)
`endif
`ifdef CCV_TRACE
    , .rcu_lane_ops_s0_tid(b_rcu_lane_ops_s0_tid)
    , .rcu_lane_ops_s1_tid(b_rcu_lane_ops_s1_tid)
    , .rcu_lane_ops_s2_tid(b_rcu_lane_ops_s2_tid)
    , .rcu_lane_ops_s3_tid(b_rcu_lane_ops_s3_tid)
    , .lane_rcu_res_s0_tid(b_lane_rcu_res_s0_tid)
    , .lane_rcu_res_s1_tid(b_lane_rcu_res_s1_tid)
    , .lane_rcu_res_s2_tid(b_lane_rcu_res_s2_tid)
    , .lane_rcu_res_s3_tid(b_lane_rcu_res_s3_tid)
`endif
  );

  // ccv_rcu_lane_ops, destination end
  ccv_seq_rpt #(.STAGES(RPT_RCU_LANE_OPS), .SLOTS(4), .PAYLOAD_W(111), .LEAD_MASK(111'h3f)) u_rpt_rcu_lane_ops (
    .clk(core_clk), .rst_n(rst_n),
    .src_valid({rcu_lane_ops_s3_valid, rcu_lane_ops_s2_valid, rcu_lane_ops_s1_valid, rcu_lane_ops_s0_valid}), .src_payload({rcu_lane_ops_s3_payload, rcu_lane_ops_s2_payload, rcu_lane_ops_s1_payload, rcu_lane_ops_s0_payload}),
    .src_wake(rcu_lane_ops_wake), .src_credit({rcu_lane_ops_s3_credit, rcu_lane_ops_s2_credit, rcu_lane_ops_s1_credit, rcu_lane_ops_s0_credit}), .src_stall({rcu_lane_ops_s3_stall, rcu_lane_ops_s2_stall, rcu_lane_ops_s1_stall, rcu_lane_ops_s0_stall}),
    .dst_valid({b_rcu_lane_ops_s3_valid, b_rcu_lane_ops_s2_valid, b_rcu_lane_ops_s1_valid, b_rcu_lane_ops_s0_valid}), .dst_payload({b_rcu_lane_ops_s3_payload, b_rcu_lane_ops_s2_payload, b_rcu_lane_ops_s1_payload, b_rcu_lane_ops_s0_payload}),
    .dst_wake(b_rcu_lane_ops_wake), .dst_credit({b_rcu_lane_ops_s3_credit, b_rcu_lane_ops_s2_credit, b_rcu_lane_ops_s1_credit, b_rcu_lane_ops_s0_credit}), .dst_stall({b_rcu_lane_ops_s3_stall, b_rcu_lane_ops_s2_stall, b_rcu_lane_ops_s1_stall, b_rcu_lane_ops_s0_stall})
`ifdef CCV_TRACE
    , .src_tid({rcu_lane_ops_s3_tid, rcu_lane_ops_s2_tid, rcu_lane_ops_s1_tid, rcu_lane_ops_s0_tid}), .dst_tid({b_rcu_lane_ops_s3_tid, b_rcu_lane_ops_s2_tid, b_rcu_lane_ops_s1_tid, b_rcu_lane_ops_s0_tid})
`endif
  );
  // ccv_lane_rcu_res, source end
  ccv_seq_rpt #(.STAGES(RPT_LANE_RCU_RES), .SLOTS(4), .PAYLOAD_W(34)) u_rpt_lane_rcu_res (
    .clk(core_clk), .rst_n(rst_n),
    .src_valid({b_lane_rcu_res_s3_valid, b_lane_rcu_res_s2_valid, b_lane_rcu_res_s1_valid, b_lane_rcu_res_s0_valid}), .src_payload({b_lane_rcu_res_s3_payload, b_lane_rcu_res_s2_payload, b_lane_rcu_res_s1_payload, b_lane_rcu_res_s0_payload}),
    .src_wake(b_lane_rcu_res_wake), .src_credit({b_lane_rcu_res_s3_credit, b_lane_rcu_res_s2_credit, b_lane_rcu_res_s1_credit, b_lane_rcu_res_s0_credit}), .src_stall({b_lane_rcu_res_s3_stall, b_lane_rcu_res_s2_stall, b_lane_rcu_res_s1_stall, b_lane_rcu_res_s0_stall}),
    .dst_valid({lane_rcu_res_s3_valid, lane_rcu_res_s2_valid, lane_rcu_res_s1_valid, lane_rcu_res_s0_valid}), .dst_payload({lane_rcu_res_s3_payload, lane_rcu_res_s2_payload, lane_rcu_res_s1_payload, lane_rcu_res_s0_payload}),
    .dst_wake(lane_rcu_res_wake), .dst_credit({lane_rcu_res_s3_credit, lane_rcu_res_s2_credit, lane_rcu_res_s1_credit, lane_rcu_res_s0_credit}), .dst_stall({lane_rcu_res_s3_stall, lane_rcu_res_s2_stall, lane_rcu_res_s1_stall, lane_rcu_res_s0_stall})
`ifdef CCV_TRACE
    , .src_tid({b_lane_rcu_res_s3_tid, b_lane_rcu_res_s2_tid, b_lane_rcu_res_s1_tid, b_lane_rcu_res_s0_tid}), .dst_tid({lane_rcu_res_s3_tid, lane_rcu_res_s2_tid, lane_rcu_res_s1_tid, lane_rcu_res_s0_tid})
`endif
  );
endmodule
