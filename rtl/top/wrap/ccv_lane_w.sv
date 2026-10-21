// GENERATED FILE -- DO NOT EDIT.
//
// Produced by tools/gen-top.py from schema/interfaces.json and
// params/blocks.json. Edit a source and regenerate; tools/verify.sh fails if
// this file is stale.

// HARDENING WRAPPER ccv_lane_w: ccv_lane and the sequential repeaters of its
// channel ends -- the physical hierarchy (docs/physical.md, "Wrappers
// and links"). Nothing but instances and nets, like the top. An end
// whose link has no stages here is connected straight through.
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
  assign {b_rcu_lane_ops_valid} = {rcu_lane_ops_valid};
  assign {b_rcu_lane_ops_payload} = {rcu_lane_ops_payload};
  assign b_rcu_lane_ops_wake = rcu_lane_ops_wake;
  assign {rcu_lane_ops_credit} = {b_rcu_lane_ops_credit};
  assign {rcu_lane_ops_stall} = {b_rcu_lane_ops_stall};
`ifdef CCV_TRACE
  assign {b_rcu_lane_ops_tid} = {rcu_lane_ops_tid};
`endif
  // ccv_lane_rcu_res, source end
  assign {lane_rcu_res_valid} = {b_lane_rcu_res_valid};
  assign {lane_rcu_res_payload} = {b_lane_rcu_res_payload};
  assign lane_rcu_res_wake = b_lane_rcu_res_wake;
  assign {b_lane_rcu_res_credit} = {lane_rcu_res_credit};
  assign {b_lane_rcu_res_stall} = {lane_rcu_res_stall};
`ifdef CCV_TRACE
  assign {lane_rcu_res_tid} = {b_lane_rcu_res_tid};
`endif
endmodule
