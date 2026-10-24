// GENERATED FILE -- DO NOT EDIT.
//
// Produced by tools/gen-top.py from schema/interfaces.json and
// params/blocks.json. Edit a source and regenerate; tools/verify.sh fails if
// this file is stale.

// HARDENING WRAPPER ccv_dcu_w: ccv_dcu and the sequential repeaters of its
// channel ends -- the physical hierarchy (docs/physical.md, "Wrappers
// and links"). Nothing but instances and nets, like the top. An end
// whose link has no stages here is connected straight through.
// Each end's stages are a parameter the top sets from params/links.json;
// at 0 the end is wired straight through, with no repeater.
`include "ccv_interfaces.svh"

module ccv_dcu_w #(
  parameter int RPT_MIU_DCU_REQ = 0,
  parameter int RPT_DCU_MIU_RSP = 0,
  parameter int RPT_DCU_MLC_REQ = 0,
  parameter int RPT_MLC_DCU_RSP = 0,
  parameter int RPT_MLC_DCU_PROBE = 0,
  parameter int RPT_DCU_MLC_PROBE_ACK = 0,
  parameter int RPT_DCU_MIU_FILL_NTC = 0
) (
  `include "ccv_dcu_ports.svh"
);

  // Between the block and its repeaters: b_<port>, one net per port.
  logic b_miu_dcu_req_s0_valid;
  ccv_miu_dcu_req_t b_miu_dcu_req_s0_payload;
  logic b_miu_dcu_req_s0_credit;
  logic b_miu_dcu_req_s0_stall;
  logic b_miu_dcu_req_s1_valid;
  ccv_miu_dcu_req_t b_miu_dcu_req_s1_payload;
  logic b_miu_dcu_req_s1_credit;
  logic b_miu_dcu_req_s1_stall;
  logic b_miu_dcu_req_s2_valid;
  ccv_miu_dcu_req_t b_miu_dcu_req_s2_payload;
  logic b_miu_dcu_req_s2_credit;
  logic b_miu_dcu_req_s2_stall;
  logic b_miu_dcu_req_s3_valid;
  ccv_miu_dcu_req_t b_miu_dcu_req_s3_payload;
  logic b_miu_dcu_req_s3_credit;
  logic b_miu_dcu_req_s3_stall;
  logic b_miu_dcu_req_wake;
  logic b_dcu_miu_rsp_s0_valid;
  ccv_dcu_miu_rsp_t b_dcu_miu_rsp_s0_payload;
  logic b_dcu_miu_rsp_s0_credit;
  logic b_dcu_miu_rsp_s0_stall;
  logic b_dcu_miu_rsp_s1_valid;
  ccv_dcu_miu_rsp_t b_dcu_miu_rsp_s1_payload;
  logic b_dcu_miu_rsp_s1_credit;
  logic b_dcu_miu_rsp_s1_stall;
  logic b_dcu_miu_rsp_s2_valid;
  ccv_dcu_miu_rsp_t b_dcu_miu_rsp_s2_payload;
  logic b_dcu_miu_rsp_s2_credit;
  logic b_dcu_miu_rsp_s2_stall;
  logic b_dcu_miu_rsp_s3_valid;
  ccv_dcu_miu_rsp_t b_dcu_miu_rsp_s3_payload;
  logic b_dcu_miu_rsp_s3_credit;
  logic b_dcu_miu_rsp_s3_stall;
  logic b_dcu_miu_rsp_wake;
  logic b_dcu_mlc_req_valid;
  ccv_dcu_mlc_req_t b_dcu_mlc_req_payload;
  logic b_dcu_mlc_req_credit;
  logic b_dcu_mlc_req_stall;
  logic b_dcu_mlc_req_wake;
  logic b_mlc_dcu_rsp_valid;
  ccv_mlc_dcu_rsp_t b_mlc_dcu_rsp_payload;
  logic b_mlc_dcu_rsp_credit;
  logic b_mlc_dcu_rsp_stall;
  logic b_mlc_dcu_rsp_wake;
  logic b_mlc_dcu_probe_valid;
  ccv_mlc_dcu_probe_t b_mlc_dcu_probe_payload;
  logic b_mlc_dcu_probe_credit;
  logic b_mlc_dcu_probe_stall;
  logic b_mlc_dcu_probe_wake;
  logic b_dcu_mlc_probe_ack_valid;
  ccv_dcu_mlc_probe_ack_t b_dcu_mlc_probe_ack_payload;
  logic b_dcu_mlc_probe_ack_credit;
  logic b_dcu_mlc_probe_ack_stall;
  logic b_dcu_mlc_probe_ack_wake;
  logic b_dcu_miu_fill_ntc_s0_valid;
  ccv_dcu_miu_fill_ntc_t b_dcu_miu_fill_ntc_s0_payload;
  logic b_dcu_miu_fill_ntc_s0_credit;
  logic b_dcu_miu_fill_ntc_s0_stall;
  logic b_dcu_miu_fill_ntc_s1_valid;
  ccv_dcu_miu_fill_ntc_t b_dcu_miu_fill_ntc_s1_payload;
  logic b_dcu_miu_fill_ntc_s1_credit;
  logic b_dcu_miu_fill_ntc_s1_stall;
  logic b_dcu_miu_fill_ntc_s2_valid;
  ccv_dcu_miu_fill_ntc_t b_dcu_miu_fill_ntc_s2_payload;
  logic b_dcu_miu_fill_ntc_s2_credit;
  logic b_dcu_miu_fill_ntc_s2_stall;
  logic b_dcu_miu_fill_ntc_s3_valid;
  ccv_dcu_miu_fill_ntc_t b_dcu_miu_fill_ntc_s3_payload;
  logic b_dcu_miu_fill_ntc_s3_credit;
  logic b_dcu_miu_fill_ntc_s3_stall;
  logic b_dcu_miu_fill_ntc_wake;
`ifdef CCV_TRACE
  logic [63:0] b_miu_dcu_req_s0_tid;
  logic [63:0] b_miu_dcu_req_s1_tid;
  logic [63:0] b_miu_dcu_req_s2_tid;
  logic [63:0] b_miu_dcu_req_s3_tid;
  logic [63:0] b_dcu_miu_rsp_s0_tid;
  logic [63:0] b_dcu_miu_rsp_s1_tid;
  logic [63:0] b_dcu_miu_rsp_s2_tid;
  logic [63:0] b_dcu_miu_rsp_s3_tid;
  logic [63:0] b_dcu_mlc_req_tid;
  logic [63:0] b_mlc_dcu_rsp_tid;
  logic [63:0] b_mlc_dcu_probe_tid;
  logic [63:0] b_dcu_mlc_probe_ack_tid;
  logic [63:0] b_dcu_miu_fill_ntc_s0_tid;
  logic [63:0] b_dcu_miu_fill_ntc_s1_tid;
  logic [63:0] b_dcu_miu_fill_ntc_s2_tid;
  logic [63:0] b_dcu_miu_fill_ntc_s3_tid;
`endif

  ccv_dcu u_blk (
    .core_clk(core_clk),
    .rst_n(rst_n),
    .csr_req(csr_req),
    .csr_rsp(csr_rsp),
    .csr_credit(csr_credit),
    .miu_dcu_req_s0_valid(b_miu_dcu_req_s0_valid),
    .miu_dcu_req_s0_payload(b_miu_dcu_req_s0_payload),
    .miu_dcu_req_s0_credit(b_miu_dcu_req_s0_credit),
    .miu_dcu_req_s0_stall(b_miu_dcu_req_s0_stall),
    .miu_dcu_req_s1_valid(b_miu_dcu_req_s1_valid),
    .miu_dcu_req_s1_payload(b_miu_dcu_req_s1_payload),
    .miu_dcu_req_s1_credit(b_miu_dcu_req_s1_credit),
    .miu_dcu_req_s1_stall(b_miu_dcu_req_s1_stall),
    .miu_dcu_req_s2_valid(b_miu_dcu_req_s2_valid),
    .miu_dcu_req_s2_payload(b_miu_dcu_req_s2_payload),
    .miu_dcu_req_s2_credit(b_miu_dcu_req_s2_credit),
    .miu_dcu_req_s2_stall(b_miu_dcu_req_s2_stall),
    .miu_dcu_req_s3_valid(b_miu_dcu_req_s3_valid),
    .miu_dcu_req_s3_payload(b_miu_dcu_req_s3_payload),
    .miu_dcu_req_s3_credit(b_miu_dcu_req_s3_credit),
    .miu_dcu_req_s3_stall(b_miu_dcu_req_s3_stall),
    .miu_dcu_req_wake(b_miu_dcu_req_wake),
    .dcu_miu_rsp_s0_valid(b_dcu_miu_rsp_s0_valid),
    .dcu_miu_rsp_s0_payload(b_dcu_miu_rsp_s0_payload),
    .dcu_miu_rsp_s0_credit(b_dcu_miu_rsp_s0_credit),
    .dcu_miu_rsp_s0_stall(b_dcu_miu_rsp_s0_stall),
    .dcu_miu_rsp_s1_valid(b_dcu_miu_rsp_s1_valid),
    .dcu_miu_rsp_s1_payload(b_dcu_miu_rsp_s1_payload),
    .dcu_miu_rsp_s1_credit(b_dcu_miu_rsp_s1_credit),
    .dcu_miu_rsp_s1_stall(b_dcu_miu_rsp_s1_stall),
    .dcu_miu_rsp_s2_valid(b_dcu_miu_rsp_s2_valid),
    .dcu_miu_rsp_s2_payload(b_dcu_miu_rsp_s2_payload),
    .dcu_miu_rsp_s2_credit(b_dcu_miu_rsp_s2_credit),
    .dcu_miu_rsp_s2_stall(b_dcu_miu_rsp_s2_stall),
    .dcu_miu_rsp_s3_valid(b_dcu_miu_rsp_s3_valid),
    .dcu_miu_rsp_s3_payload(b_dcu_miu_rsp_s3_payload),
    .dcu_miu_rsp_s3_credit(b_dcu_miu_rsp_s3_credit),
    .dcu_miu_rsp_s3_stall(b_dcu_miu_rsp_s3_stall),
    .dcu_miu_rsp_wake(b_dcu_miu_rsp_wake),
    .dcu_mlc_req_valid(b_dcu_mlc_req_valid),
    .dcu_mlc_req_payload(b_dcu_mlc_req_payload),
    .dcu_mlc_req_credit(b_dcu_mlc_req_credit),
    .dcu_mlc_req_stall(b_dcu_mlc_req_stall),
    .dcu_mlc_req_wake(b_dcu_mlc_req_wake),
    .mlc_dcu_rsp_valid(b_mlc_dcu_rsp_valid),
    .mlc_dcu_rsp_payload(b_mlc_dcu_rsp_payload),
    .mlc_dcu_rsp_credit(b_mlc_dcu_rsp_credit),
    .mlc_dcu_rsp_stall(b_mlc_dcu_rsp_stall),
    .mlc_dcu_rsp_wake(b_mlc_dcu_rsp_wake),
    .mlc_dcu_probe_valid(b_mlc_dcu_probe_valid),
    .mlc_dcu_probe_payload(b_mlc_dcu_probe_payload),
    .mlc_dcu_probe_credit(b_mlc_dcu_probe_credit),
    .mlc_dcu_probe_stall(b_mlc_dcu_probe_stall),
    .mlc_dcu_probe_wake(b_mlc_dcu_probe_wake),
    .dcu_mlc_probe_ack_valid(b_dcu_mlc_probe_ack_valid),
    .dcu_mlc_probe_ack_payload(b_dcu_mlc_probe_ack_payload),
    .dcu_mlc_probe_ack_credit(b_dcu_mlc_probe_ack_credit),
    .dcu_mlc_probe_ack_stall(b_dcu_mlc_probe_ack_stall),
    .dcu_mlc_probe_ack_wake(b_dcu_mlc_probe_ack_wake),
    .dcu_miu_fill_ntc_s0_valid(b_dcu_miu_fill_ntc_s0_valid),
    .dcu_miu_fill_ntc_s0_payload(b_dcu_miu_fill_ntc_s0_payload),
    .dcu_miu_fill_ntc_s0_credit(b_dcu_miu_fill_ntc_s0_credit),
    .dcu_miu_fill_ntc_s0_stall(b_dcu_miu_fill_ntc_s0_stall),
    .dcu_miu_fill_ntc_s1_valid(b_dcu_miu_fill_ntc_s1_valid),
    .dcu_miu_fill_ntc_s1_payload(b_dcu_miu_fill_ntc_s1_payload),
    .dcu_miu_fill_ntc_s1_credit(b_dcu_miu_fill_ntc_s1_credit),
    .dcu_miu_fill_ntc_s1_stall(b_dcu_miu_fill_ntc_s1_stall),
    .dcu_miu_fill_ntc_s2_valid(b_dcu_miu_fill_ntc_s2_valid),
    .dcu_miu_fill_ntc_s2_payload(b_dcu_miu_fill_ntc_s2_payload),
    .dcu_miu_fill_ntc_s2_credit(b_dcu_miu_fill_ntc_s2_credit),
    .dcu_miu_fill_ntc_s2_stall(b_dcu_miu_fill_ntc_s2_stall),
    .dcu_miu_fill_ntc_s3_valid(b_dcu_miu_fill_ntc_s3_valid),
    .dcu_miu_fill_ntc_s3_payload(b_dcu_miu_fill_ntc_s3_payload),
    .dcu_miu_fill_ntc_s3_credit(b_dcu_miu_fill_ntc_s3_credit),
    .dcu_miu_fill_ntc_s3_stall(b_dcu_miu_fill_ntc_s3_stall),
    .dcu_miu_fill_ntc_wake(b_dcu_miu_fill_ntc_wake)
`ifdef CCV_CHECK
    , .clk_gated(clk_gated)
`endif
`ifdef CCV_TRACE
    , .miu_dcu_req_s0_tid(b_miu_dcu_req_s0_tid)
    , .miu_dcu_req_s1_tid(b_miu_dcu_req_s1_tid)
    , .miu_dcu_req_s2_tid(b_miu_dcu_req_s2_tid)
    , .miu_dcu_req_s3_tid(b_miu_dcu_req_s3_tid)
    , .dcu_miu_rsp_s0_tid(b_dcu_miu_rsp_s0_tid)
    , .dcu_miu_rsp_s1_tid(b_dcu_miu_rsp_s1_tid)
    , .dcu_miu_rsp_s2_tid(b_dcu_miu_rsp_s2_tid)
    , .dcu_miu_rsp_s3_tid(b_dcu_miu_rsp_s3_tid)
    , .dcu_mlc_req_tid(b_dcu_mlc_req_tid)
    , .mlc_dcu_rsp_tid(b_mlc_dcu_rsp_tid)
    , .mlc_dcu_probe_tid(b_mlc_dcu_probe_tid)
    , .dcu_mlc_probe_ack_tid(b_dcu_mlc_probe_ack_tid)
    , .dcu_miu_fill_ntc_s0_tid(b_dcu_miu_fill_ntc_s0_tid)
    , .dcu_miu_fill_ntc_s1_tid(b_dcu_miu_fill_ntc_s1_tid)
    , .dcu_miu_fill_ntc_s2_tid(b_dcu_miu_fill_ntc_s2_tid)
    , .dcu_miu_fill_ntc_s3_tid(b_dcu_miu_fill_ntc_s3_tid)
`endif
  );

  // ccv_miu_dcu_req, destination end
  if (RPT_MIU_DCU_REQ > 0) begin : g_rpt_miu_dcu_req
    ccv_common_rpt #(.STAGES(RPT_MIU_DCU_REQ), .SLOTS(4), .PAYLOAD_W(1212)) u_rpt_miu_dcu_req (
      .clk(core_clk), .rst_n(rst_n),
      .src_valid({miu_dcu_req_s3_valid, miu_dcu_req_s2_valid, miu_dcu_req_s1_valid, miu_dcu_req_s0_valid}), .src_payload({miu_dcu_req_s3_payload, miu_dcu_req_s2_payload, miu_dcu_req_s1_payload, miu_dcu_req_s0_payload}),
      .src_wake(miu_dcu_req_wake), .src_credit({miu_dcu_req_s3_credit, miu_dcu_req_s2_credit, miu_dcu_req_s1_credit, miu_dcu_req_s0_credit}), .src_stall({miu_dcu_req_s3_stall, miu_dcu_req_s2_stall, miu_dcu_req_s1_stall, miu_dcu_req_s0_stall}),
      .dst_valid({b_miu_dcu_req_s3_valid, b_miu_dcu_req_s2_valid, b_miu_dcu_req_s1_valid, b_miu_dcu_req_s0_valid}), .dst_payload({b_miu_dcu_req_s3_payload, b_miu_dcu_req_s2_payload, b_miu_dcu_req_s1_payload, b_miu_dcu_req_s0_payload}),
      .dst_wake(b_miu_dcu_req_wake), .dst_credit({b_miu_dcu_req_s3_credit, b_miu_dcu_req_s2_credit, b_miu_dcu_req_s1_credit, b_miu_dcu_req_s0_credit}), .dst_stall({b_miu_dcu_req_s3_stall, b_miu_dcu_req_s2_stall, b_miu_dcu_req_s1_stall, b_miu_dcu_req_s0_stall})
`ifdef CCV_TRACE
      , .src_tid({miu_dcu_req_s3_tid, miu_dcu_req_s2_tid, miu_dcu_req_s1_tid, miu_dcu_req_s0_tid}), .dst_tid({b_miu_dcu_req_s3_tid, b_miu_dcu_req_s2_tid, b_miu_dcu_req_s1_tid, b_miu_dcu_req_s0_tid})
`endif
    );
  end else begin : g_wire_miu_dcu_req
    assign {b_miu_dcu_req_s3_valid, b_miu_dcu_req_s2_valid, b_miu_dcu_req_s1_valid, b_miu_dcu_req_s0_valid} = {miu_dcu_req_s3_valid, miu_dcu_req_s2_valid, miu_dcu_req_s1_valid, miu_dcu_req_s0_valid};
    assign {b_miu_dcu_req_s3_payload, b_miu_dcu_req_s2_payload, b_miu_dcu_req_s1_payload, b_miu_dcu_req_s0_payload} = {miu_dcu_req_s3_payload, miu_dcu_req_s2_payload, miu_dcu_req_s1_payload, miu_dcu_req_s0_payload};
    assign b_miu_dcu_req_wake = miu_dcu_req_wake;
    assign {miu_dcu_req_s3_credit, miu_dcu_req_s2_credit, miu_dcu_req_s1_credit, miu_dcu_req_s0_credit} = {b_miu_dcu_req_s3_credit, b_miu_dcu_req_s2_credit, b_miu_dcu_req_s1_credit, b_miu_dcu_req_s0_credit};
    assign {miu_dcu_req_s3_stall, miu_dcu_req_s2_stall, miu_dcu_req_s1_stall, miu_dcu_req_s0_stall} = {b_miu_dcu_req_s3_stall, b_miu_dcu_req_s2_stall, b_miu_dcu_req_s1_stall, b_miu_dcu_req_s0_stall};
`ifdef CCV_TRACE
    assign {b_miu_dcu_req_s3_tid, b_miu_dcu_req_s2_tid, b_miu_dcu_req_s1_tid, b_miu_dcu_req_s0_tid} = {miu_dcu_req_s3_tid, miu_dcu_req_s2_tid, miu_dcu_req_s1_tid, miu_dcu_req_s0_tid};
`endif
  end
  // ccv_dcu_miu_rsp, source end
  if (RPT_DCU_MIU_RSP > 0) begin : g_rpt_dcu_miu_rsp
    ccv_common_rpt #(.STAGES(RPT_DCU_MIU_RSP), .SLOTS(4), .PAYLOAD_W(1031)) u_rpt_dcu_miu_rsp (
      .clk(core_clk), .rst_n(rst_n),
      .src_valid({b_dcu_miu_rsp_s3_valid, b_dcu_miu_rsp_s2_valid, b_dcu_miu_rsp_s1_valid, b_dcu_miu_rsp_s0_valid}), .src_payload({b_dcu_miu_rsp_s3_payload, b_dcu_miu_rsp_s2_payload, b_dcu_miu_rsp_s1_payload, b_dcu_miu_rsp_s0_payload}),
      .src_wake(b_dcu_miu_rsp_wake), .src_credit({b_dcu_miu_rsp_s3_credit, b_dcu_miu_rsp_s2_credit, b_dcu_miu_rsp_s1_credit, b_dcu_miu_rsp_s0_credit}), .src_stall({b_dcu_miu_rsp_s3_stall, b_dcu_miu_rsp_s2_stall, b_dcu_miu_rsp_s1_stall, b_dcu_miu_rsp_s0_stall}),
      .dst_valid({dcu_miu_rsp_s3_valid, dcu_miu_rsp_s2_valid, dcu_miu_rsp_s1_valid, dcu_miu_rsp_s0_valid}), .dst_payload({dcu_miu_rsp_s3_payload, dcu_miu_rsp_s2_payload, dcu_miu_rsp_s1_payload, dcu_miu_rsp_s0_payload}),
      .dst_wake(dcu_miu_rsp_wake), .dst_credit({dcu_miu_rsp_s3_credit, dcu_miu_rsp_s2_credit, dcu_miu_rsp_s1_credit, dcu_miu_rsp_s0_credit}), .dst_stall({dcu_miu_rsp_s3_stall, dcu_miu_rsp_s2_stall, dcu_miu_rsp_s1_stall, dcu_miu_rsp_s0_stall})
`ifdef CCV_TRACE
      , .src_tid({b_dcu_miu_rsp_s3_tid, b_dcu_miu_rsp_s2_tid, b_dcu_miu_rsp_s1_tid, b_dcu_miu_rsp_s0_tid}), .dst_tid({dcu_miu_rsp_s3_tid, dcu_miu_rsp_s2_tid, dcu_miu_rsp_s1_tid, dcu_miu_rsp_s0_tid})
`endif
    );
  end else begin : g_wire_dcu_miu_rsp
    assign {dcu_miu_rsp_s3_valid, dcu_miu_rsp_s2_valid, dcu_miu_rsp_s1_valid, dcu_miu_rsp_s0_valid} = {b_dcu_miu_rsp_s3_valid, b_dcu_miu_rsp_s2_valid, b_dcu_miu_rsp_s1_valid, b_dcu_miu_rsp_s0_valid};
    assign {dcu_miu_rsp_s3_payload, dcu_miu_rsp_s2_payload, dcu_miu_rsp_s1_payload, dcu_miu_rsp_s0_payload} = {b_dcu_miu_rsp_s3_payload, b_dcu_miu_rsp_s2_payload, b_dcu_miu_rsp_s1_payload, b_dcu_miu_rsp_s0_payload};
    assign dcu_miu_rsp_wake = b_dcu_miu_rsp_wake;
    assign {b_dcu_miu_rsp_s3_credit, b_dcu_miu_rsp_s2_credit, b_dcu_miu_rsp_s1_credit, b_dcu_miu_rsp_s0_credit} = {dcu_miu_rsp_s3_credit, dcu_miu_rsp_s2_credit, dcu_miu_rsp_s1_credit, dcu_miu_rsp_s0_credit};
    assign {b_dcu_miu_rsp_s3_stall, b_dcu_miu_rsp_s2_stall, b_dcu_miu_rsp_s1_stall, b_dcu_miu_rsp_s0_stall} = {dcu_miu_rsp_s3_stall, dcu_miu_rsp_s2_stall, dcu_miu_rsp_s1_stall, dcu_miu_rsp_s0_stall};
`ifdef CCV_TRACE
    assign {dcu_miu_rsp_s3_tid, dcu_miu_rsp_s2_tid, dcu_miu_rsp_s1_tid, dcu_miu_rsp_s0_tid} = {b_dcu_miu_rsp_s3_tid, b_dcu_miu_rsp_s2_tid, b_dcu_miu_rsp_s1_tid, b_dcu_miu_rsp_s0_tid};
`endif
  end
  // ccv_dcu_mlc_req, source end
  if (RPT_DCU_MLC_REQ > 0) begin : g_rpt_dcu_mlc_req
    ccv_common_rpt #(.STAGES(RPT_DCU_MLC_REQ), .SLOTS(1), .PAYLOAD_W(1082)) u_rpt_dcu_mlc_req (
      .clk(core_clk), .rst_n(rst_n),
      .src_valid({b_dcu_mlc_req_valid}), .src_payload({b_dcu_mlc_req_payload}),
      .src_wake(b_dcu_mlc_req_wake), .src_credit({b_dcu_mlc_req_credit}), .src_stall({b_dcu_mlc_req_stall}),
      .dst_valid({dcu_mlc_req_valid}), .dst_payload({dcu_mlc_req_payload}),
      .dst_wake(dcu_mlc_req_wake), .dst_credit({dcu_mlc_req_credit}), .dst_stall({dcu_mlc_req_stall})
`ifdef CCV_TRACE
      , .src_tid({b_dcu_mlc_req_tid}), .dst_tid({dcu_mlc_req_tid})
`endif
    );
  end else begin : g_wire_dcu_mlc_req
    assign {dcu_mlc_req_valid} = {b_dcu_mlc_req_valid};
    assign {dcu_mlc_req_payload} = {b_dcu_mlc_req_payload};
    assign dcu_mlc_req_wake = b_dcu_mlc_req_wake;
    assign {b_dcu_mlc_req_credit} = {dcu_mlc_req_credit};
    assign {b_dcu_mlc_req_stall} = {dcu_mlc_req_stall};
`ifdef CCV_TRACE
    assign {dcu_mlc_req_tid} = {b_dcu_mlc_req_tid};
`endif
  end
  // ccv_mlc_dcu_rsp, destination end
  if (RPT_MLC_DCU_RSP > 0) begin : g_rpt_mlc_dcu_rsp
    ccv_common_rpt #(.STAGES(RPT_MLC_DCU_RSP), .SLOTS(1), .PAYLOAD_W(1030)) u_rpt_mlc_dcu_rsp (
      .clk(core_clk), .rst_n(rst_n),
      .src_valid({mlc_dcu_rsp_valid}), .src_payload({mlc_dcu_rsp_payload}),
      .src_wake(mlc_dcu_rsp_wake), .src_credit({mlc_dcu_rsp_credit}), .src_stall({mlc_dcu_rsp_stall}),
      .dst_valid({b_mlc_dcu_rsp_valid}), .dst_payload({b_mlc_dcu_rsp_payload}),
      .dst_wake(b_mlc_dcu_rsp_wake), .dst_credit({b_mlc_dcu_rsp_credit}), .dst_stall({b_mlc_dcu_rsp_stall})
`ifdef CCV_TRACE
      , .src_tid({mlc_dcu_rsp_tid}), .dst_tid({b_mlc_dcu_rsp_tid})
`endif
    );
  end else begin : g_wire_mlc_dcu_rsp
    assign {b_mlc_dcu_rsp_valid} = {mlc_dcu_rsp_valid};
    assign {b_mlc_dcu_rsp_payload} = {mlc_dcu_rsp_payload};
    assign b_mlc_dcu_rsp_wake = mlc_dcu_rsp_wake;
    assign {mlc_dcu_rsp_credit} = {b_mlc_dcu_rsp_credit};
    assign {mlc_dcu_rsp_stall} = {b_mlc_dcu_rsp_stall};
`ifdef CCV_TRACE
    assign {b_mlc_dcu_rsp_tid} = {mlc_dcu_rsp_tid};
`endif
  end
  // ccv_mlc_dcu_probe, destination end
  if (RPT_MLC_DCU_PROBE > 0) begin : g_rpt_mlc_dcu_probe
    ccv_common_rpt #(.STAGES(RPT_MLC_DCU_PROBE), .SLOTS(1), .PAYLOAD_W(51)) u_rpt_mlc_dcu_probe (
      .clk(core_clk), .rst_n(rst_n),
      .src_valid({mlc_dcu_probe_valid}), .src_payload({mlc_dcu_probe_payload}),
      .src_wake(mlc_dcu_probe_wake), .src_credit({mlc_dcu_probe_credit}), .src_stall({mlc_dcu_probe_stall}),
      .dst_valid({b_mlc_dcu_probe_valid}), .dst_payload({b_mlc_dcu_probe_payload}),
      .dst_wake(b_mlc_dcu_probe_wake), .dst_credit({b_mlc_dcu_probe_credit}), .dst_stall({b_mlc_dcu_probe_stall})
`ifdef CCV_TRACE
      , .src_tid({mlc_dcu_probe_tid}), .dst_tid({b_mlc_dcu_probe_tid})
`endif
    );
  end else begin : g_wire_mlc_dcu_probe
    assign {b_mlc_dcu_probe_valid} = {mlc_dcu_probe_valid};
    assign {b_mlc_dcu_probe_payload} = {mlc_dcu_probe_payload};
    assign b_mlc_dcu_probe_wake = mlc_dcu_probe_wake;
    assign {mlc_dcu_probe_credit} = {b_mlc_dcu_probe_credit};
    assign {mlc_dcu_probe_stall} = {b_mlc_dcu_probe_stall};
`ifdef CCV_TRACE
    assign {b_mlc_dcu_probe_tid} = {mlc_dcu_probe_tid};
`endif
  end
  // ccv_dcu_mlc_probe_ack, source end
  if (RPT_DCU_MLC_PROBE_ACK > 0) begin : g_rpt_dcu_mlc_probe_ack
    ccv_common_rpt #(.STAGES(RPT_DCU_MLC_PROBE_ACK), .SLOTS(1), .PAYLOAD_W(1027)) u_rpt_dcu_mlc_probe_ack (
      .clk(core_clk), .rst_n(rst_n),
      .src_valid({b_dcu_mlc_probe_ack_valid}), .src_payload({b_dcu_mlc_probe_ack_payload}),
      .src_wake(b_dcu_mlc_probe_ack_wake), .src_credit({b_dcu_mlc_probe_ack_credit}), .src_stall({b_dcu_mlc_probe_ack_stall}),
      .dst_valid({dcu_mlc_probe_ack_valid}), .dst_payload({dcu_mlc_probe_ack_payload}),
      .dst_wake(dcu_mlc_probe_ack_wake), .dst_credit({dcu_mlc_probe_ack_credit}), .dst_stall({dcu_mlc_probe_ack_stall})
`ifdef CCV_TRACE
      , .src_tid({b_dcu_mlc_probe_ack_tid}), .dst_tid({dcu_mlc_probe_ack_tid})
`endif
    );
  end else begin : g_wire_dcu_mlc_probe_ack
    assign {dcu_mlc_probe_ack_valid} = {b_dcu_mlc_probe_ack_valid};
    assign {dcu_mlc_probe_ack_payload} = {b_dcu_mlc_probe_ack_payload};
    assign dcu_mlc_probe_ack_wake = b_dcu_mlc_probe_ack_wake;
    assign {b_dcu_mlc_probe_ack_credit} = {dcu_mlc_probe_ack_credit};
    assign {b_dcu_mlc_probe_ack_stall} = {dcu_mlc_probe_ack_stall};
`ifdef CCV_TRACE
    assign {dcu_mlc_probe_ack_tid} = {b_dcu_mlc_probe_ack_tid};
`endif
  end
  // ccv_dcu_miu_fill_ntc, source end
  if (RPT_DCU_MIU_FILL_NTC > 0) begin : g_rpt_dcu_miu_fill_ntc
    ccv_common_rpt #(.STAGES(RPT_DCU_MIU_FILL_NTC), .SLOTS(4), .PAYLOAD_W(4)) u_rpt_dcu_miu_fill_ntc (
      .clk(core_clk), .rst_n(rst_n),
      .src_valid({b_dcu_miu_fill_ntc_s3_valid, b_dcu_miu_fill_ntc_s2_valid, b_dcu_miu_fill_ntc_s1_valid, b_dcu_miu_fill_ntc_s0_valid}), .src_payload({b_dcu_miu_fill_ntc_s3_payload, b_dcu_miu_fill_ntc_s2_payload, b_dcu_miu_fill_ntc_s1_payload, b_dcu_miu_fill_ntc_s0_payload}),
      .src_wake(b_dcu_miu_fill_ntc_wake), .src_credit({b_dcu_miu_fill_ntc_s3_credit, b_dcu_miu_fill_ntc_s2_credit, b_dcu_miu_fill_ntc_s1_credit, b_dcu_miu_fill_ntc_s0_credit}), .src_stall({b_dcu_miu_fill_ntc_s3_stall, b_dcu_miu_fill_ntc_s2_stall, b_dcu_miu_fill_ntc_s1_stall, b_dcu_miu_fill_ntc_s0_stall}),
      .dst_valid({dcu_miu_fill_ntc_s3_valid, dcu_miu_fill_ntc_s2_valid, dcu_miu_fill_ntc_s1_valid, dcu_miu_fill_ntc_s0_valid}), .dst_payload({dcu_miu_fill_ntc_s3_payload, dcu_miu_fill_ntc_s2_payload, dcu_miu_fill_ntc_s1_payload, dcu_miu_fill_ntc_s0_payload}),
      .dst_wake(dcu_miu_fill_ntc_wake), .dst_credit({dcu_miu_fill_ntc_s3_credit, dcu_miu_fill_ntc_s2_credit, dcu_miu_fill_ntc_s1_credit, dcu_miu_fill_ntc_s0_credit}), .dst_stall({dcu_miu_fill_ntc_s3_stall, dcu_miu_fill_ntc_s2_stall, dcu_miu_fill_ntc_s1_stall, dcu_miu_fill_ntc_s0_stall})
`ifdef CCV_TRACE
      , .src_tid({b_dcu_miu_fill_ntc_s3_tid, b_dcu_miu_fill_ntc_s2_tid, b_dcu_miu_fill_ntc_s1_tid, b_dcu_miu_fill_ntc_s0_tid}), .dst_tid({dcu_miu_fill_ntc_s3_tid, dcu_miu_fill_ntc_s2_tid, dcu_miu_fill_ntc_s1_tid, dcu_miu_fill_ntc_s0_tid})
`endif
    );
  end else begin : g_wire_dcu_miu_fill_ntc
    assign {dcu_miu_fill_ntc_s3_valid, dcu_miu_fill_ntc_s2_valid, dcu_miu_fill_ntc_s1_valid, dcu_miu_fill_ntc_s0_valid} = {b_dcu_miu_fill_ntc_s3_valid, b_dcu_miu_fill_ntc_s2_valid, b_dcu_miu_fill_ntc_s1_valid, b_dcu_miu_fill_ntc_s0_valid};
    assign {dcu_miu_fill_ntc_s3_payload, dcu_miu_fill_ntc_s2_payload, dcu_miu_fill_ntc_s1_payload, dcu_miu_fill_ntc_s0_payload} = {b_dcu_miu_fill_ntc_s3_payload, b_dcu_miu_fill_ntc_s2_payload, b_dcu_miu_fill_ntc_s1_payload, b_dcu_miu_fill_ntc_s0_payload};
    assign dcu_miu_fill_ntc_wake = b_dcu_miu_fill_ntc_wake;
    assign {b_dcu_miu_fill_ntc_s3_credit, b_dcu_miu_fill_ntc_s2_credit, b_dcu_miu_fill_ntc_s1_credit, b_dcu_miu_fill_ntc_s0_credit} = {dcu_miu_fill_ntc_s3_credit, dcu_miu_fill_ntc_s2_credit, dcu_miu_fill_ntc_s1_credit, dcu_miu_fill_ntc_s0_credit};
    assign {b_dcu_miu_fill_ntc_s3_stall, b_dcu_miu_fill_ntc_s2_stall, b_dcu_miu_fill_ntc_s1_stall, b_dcu_miu_fill_ntc_s0_stall} = {dcu_miu_fill_ntc_s3_stall, dcu_miu_fill_ntc_s2_stall, dcu_miu_fill_ntc_s1_stall, dcu_miu_fill_ntc_s0_stall};
`ifdef CCV_TRACE
    assign {dcu_miu_fill_ntc_s3_tid, dcu_miu_fill_ntc_s2_tid, dcu_miu_fill_ntc_s1_tid, dcu_miu_fill_ntc_s0_tid} = {b_dcu_miu_fill_ntc_s3_tid, b_dcu_miu_fill_ntc_s2_tid, b_dcu_miu_fill_ntc_s1_tid, b_dcu_miu_fill_ntc_s0_tid};
`endif
  end
endmodule
