// GENERATED FILE -- DO NOT EDIT.
//
// Produced by tools/gen-top.py from schema/interfaces.json and
// params/blocks.json. Edit a source and regenerate; tools/verify.sh fails if
// this file is stale.

// HARDENING WRAPPER ccv_mlc_w: ccv_mlc and the sequential repeaters of its
// channel ends -- the physical hierarchy (docs/physical.md, "Wrappers
// and links"). Nothing but instances and nets, like the top. Every
// end has its repeater whether or not the link is repeated.
// STAGES is a parameter the top sets from params/links.json, 0 meaning
// wires, so a new split changes parameters and never this structure.
`include "ccv_interfaces.svh"

module ccv_mlc_w #(
  parameter int RPT_DCU_MLC_REQ = 0,
  parameter int RPT_MLC_DCU_RSP = 0,
  parameter int RPT_MLC_DCU_PROBE = 0,
  parameter int RPT_DCU_MLC_PROBE_ACK = 0,
  parameter int RPT_FET_MLC_IFILL = 0,
  parameter int RPT_MLC_FET_IFILL_RSP = 0,
  parameter int RPT_MLC_EXB_REQ = 0,
  parameter int RPT_EXB_MLC_RSP = 0
) (
  `include "ccv_mlc_ports.svh"
);

  // Between the block and its repeaters: b_<port>, one net per port.
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
  logic b_mlc_exb_req_valid;
  ccv_mlc_exb_req_t b_mlc_exb_req_payload;
  logic b_mlc_exb_req_credit;
  logic b_mlc_exb_req_stall;
  logic b_mlc_exb_req_wake;
  logic b_exb_mlc_rsp_valid;
  ccv_exb_mlc_rsp_t b_exb_mlc_rsp_payload;
  logic b_exb_mlc_rsp_credit;
  logic b_exb_mlc_rsp_stall;
  logic b_exb_mlc_rsp_wake;
`ifdef CCV_TRACE
  logic [63:0] b_dcu_mlc_req_tid;
  logic [63:0] b_mlc_dcu_rsp_tid;
  logic [63:0] b_mlc_dcu_probe_tid;
  logic [63:0] b_dcu_mlc_probe_ack_tid;
  logic [63:0] b_fet_mlc_ifill_tid;
  logic [63:0] b_mlc_fet_ifill_rsp_tid;
  logic [63:0] b_mlc_exb_req_tid;
  logic [63:0] b_exb_mlc_rsp_tid;
`endif

  ccv_mlc u_blk (
    .core_clk(core_clk),
    .rst_n(rst_n),
    .csr_req(csr_req),
    .csr_rsp(csr_rsp),
    .csr_credit(csr_credit),
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
    .mlc_exb_req_valid(b_mlc_exb_req_valid),
    .mlc_exb_req_payload(b_mlc_exb_req_payload),
    .mlc_exb_req_credit(b_mlc_exb_req_credit),
    .mlc_exb_req_stall(b_mlc_exb_req_stall),
    .mlc_exb_req_wake(b_mlc_exb_req_wake),
    .exb_mlc_rsp_valid(b_exb_mlc_rsp_valid),
    .exb_mlc_rsp_payload(b_exb_mlc_rsp_payload),
    .exb_mlc_rsp_credit(b_exb_mlc_rsp_credit),
    .exb_mlc_rsp_stall(b_exb_mlc_rsp_stall),
    .exb_mlc_rsp_wake(b_exb_mlc_rsp_wake)
`ifdef CCV_CHECK
    , .clk_gated(clk_gated)
`endif
`ifdef CCV_TRACE
    , .dcu_mlc_req_tid(b_dcu_mlc_req_tid)
    , .mlc_dcu_rsp_tid(b_mlc_dcu_rsp_tid)
    , .mlc_dcu_probe_tid(b_mlc_dcu_probe_tid)
    , .dcu_mlc_probe_ack_tid(b_dcu_mlc_probe_ack_tid)
    , .fet_mlc_ifill_tid(b_fet_mlc_ifill_tid)
    , .mlc_fet_ifill_rsp_tid(b_mlc_fet_ifill_rsp_tid)
    , .mlc_exb_req_tid(b_mlc_exb_req_tid)
    , .exb_mlc_rsp_tid(b_exb_mlc_rsp_tid)
`endif
  );

  // ccv_dcu_mlc_req, destination end
  ccv_seq_rpt #(.STAGES(RPT_DCU_MLC_REQ), .SLOTS(1), .PAYLOAD_W(1082)) u_rpt_dcu_mlc_req (
    .clk(core_clk), .rst_n(rst_n),
    .src_valid({dcu_mlc_req_valid}), .src_payload({dcu_mlc_req_payload}),
    .src_wake(dcu_mlc_req_wake), .src_credit({dcu_mlc_req_credit}), .src_stall({dcu_mlc_req_stall}),
    .dst_valid({b_dcu_mlc_req_valid}), .dst_payload({b_dcu_mlc_req_payload}),
    .dst_wake(b_dcu_mlc_req_wake), .dst_credit({b_dcu_mlc_req_credit}), .dst_stall({b_dcu_mlc_req_stall})
`ifdef CCV_TRACE
    , .src_tid({dcu_mlc_req_tid}), .dst_tid({b_dcu_mlc_req_tid})
`endif
  );
  // ccv_mlc_dcu_rsp, source end
  ccv_seq_rpt #(.STAGES(RPT_MLC_DCU_RSP), .SLOTS(1), .PAYLOAD_W(1030)) u_rpt_mlc_dcu_rsp (
    .clk(core_clk), .rst_n(rst_n),
    .src_valid({b_mlc_dcu_rsp_valid}), .src_payload({b_mlc_dcu_rsp_payload}),
    .src_wake(b_mlc_dcu_rsp_wake), .src_credit({b_mlc_dcu_rsp_credit}), .src_stall({b_mlc_dcu_rsp_stall}),
    .dst_valid({mlc_dcu_rsp_valid}), .dst_payload({mlc_dcu_rsp_payload}),
    .dst_wake(mlc_dcu_rsp_wake), .dst_credit({mlc_dcu_rsp_credit}), .dst_stall({mlc_dcu_rsp_stall})
`ifdef CCV_TRACE
    , .src_tid({b_mlc_dcu_rsp_tid}), .dst_tid({mlc_dcu_rsp_tid})
`endif
  );
  // ccv_mlc_dcu_probe, source end
  ccv_seq_rpt #(.STAGES(RPT_MLC_DCU_PROBE), .SLOTS(1), .PAYLOAD_W(51)) u_rpt_mlc_dcu_probe (
    .clk(core_clk), .rst_n(rst_n),
    .src_valid({b_mlc_dcu_probe_valid}), .src_payload({b_mlc_dcu_probe_payload}),
    .src_wake(b_mlc_dcu_probe_wake), .src_credit({b_mlc_dcu_probe_credit}), .src_stall({b_mlc_dcu_probe_stall}),
    .dst_valid({mlc_dcu_probe_valid}), .dst_payload({mlc_dcu_probe_payload}),
    .dst_wake(mlc_dcu_probe_wake), .dst_credit({mlc_dcu_probe_credit}), .dst_stall({mlc_dcu_probe_stall})
`ifdef CCV_TRACE
    , .src_tid({b_mlc_dcu_probe_tid}), .dst_tid({mlc_dcu_probe_tid})
`endif
  );
  // ccv_dcu_mlc_probe_ack, destination end
  ccv_seq_rpt #(.STAGES(RPT_DCU_MLC_PROBE_ACK), .SLOTS(1), .PAYLOAD_W(1027)) u_rpt_dcu_mlc_probe_ack (
    .clk(core_clk), .rst_n(rst_n),
    .src_valid({dcu_mlc_probe_ack_valid}), .src_payload({dcu_mlc_probe_ack_payload}),
    .src_wake(dcu_mlc_probe_ack_wake), .src_credit({dcu_mlc_probe_ack_credit}), .src_stall({dcu_mlc_probe_ack_stall}),
    .dst_valid({b_dcu_mlc_probe_ack_valid}), .dst_payload({b_dcu_mlc_probe_ack_payload}),
    .dst_wake(b_dcu_mlc_probe_ack_wake), .dst_credit({b_dcu_mlc_probe_ack_credit}), .dst_stall({b_dcu_mlc_probe_ack_stall})
`ifdef CCV_TRACE
    , .src_tid({dcu_mlc_probe_ack_tid}), .dst_tid({b_dcu_mlc_probe_ack_tid})
`endif
  );
  // ccv_fet_mlc_ifill, destination end
  ccv_seq_rpt #(.STAGES(RPT_FET_MLC_IFILL), .SLOTS(1), .PAYLOAD_W(58)) u_rpt_fet_mlc_ifill (
    .clk(core_clk), .rst_n(rst_n),
    .src_valid({fet_mlc_ifill_valid}), .src_payload({fet_mlc_ifill_payload}),
    .src_wake(fet_mlc_ifill_wake), .src_credit({fet_mlc_ifill_credit}), .src_stall({fet_mlc_ifill_stall}),
    .dst_valid({b_fet_mlc_ifill_valid}), .dst_payload({b_fet_mlc_ifill_payload}),
    .dst_wake(b_fet_mlc_ifill_wake), .dst_credit({b_fet_mlc_ifill_credit}), .dst_stall({b_fet_mlc_ifill_stall})
`ifdef CCV_TRACE
    , .src_tid({fet_mlc_ifill_tid}), .dst_tid({b_fet_mlc_ifill_tid})
`endif
  );
  // ccv_mlc_fet_ifill_rsp, source end
  ccv_seq_rpt #(.STAGES(RPT_MLC_FET_IFILL_RSP), .SLOTS(1), .PAYLOAD_W(1026)) u_rpt_mlc_fet_ifill_rsp (
    .clk(core_clk), .rst_n(rst_n),
    .src_valid({b_mlc_fet_ifill_rsp_valid}), .src_payload({b_mlc_fet_ifill_rsp_payload}),
    .src_wake(b_mlc_fet_ifill_rsp_wake), .src_credit({b_mlc_fet_ifill_rsp_credit}), .src_stall({b_mlc_fet_ifill_rsp_stall}),
    .dst_valid({mlc_fet_ifill_rsp_valid}), .dst_payload({mlc_fet_ifill_rsp_payload}),
    .dst_wake(mlc_fet_ifill_rsp_wake), .dst_credit({mlc_fet_ifill_rsp_credit}), .dst_stall({mlc_fet_ifill_rsp_stall})
`ifdef CCV_TRACE
    , .src_tid({b_mlc_fet_ifill_rsp_tid}), .dst_tid({mlc_fet_ifill_rsp_tid})
`endif
  );
  // ccv_mlc_exb_req, source end
  ccv_seq_rpt #(.STAGES(RPT_MLC_EXB_REQ), .SLOTS(1), .PAYLOAD_W(1090)) u_rpt_mlc_exb_req (
    .clk(core_clk), .rst_n(rst_n),
    .src_valid({b_mlc_exb_req_valid}), .src_payload({b_mlc_exb_req_payload}),
    .src_wake(b_mlc_exb_req_wake), .src_credit({b_mlc_exb_req_credit}), .src_stall({b_mlc_exb_req_stall}),
    .dst_valid({mlc_exb_req_valid}), .dst_payload({mlc_exb_req_payload}),
    .dst_wake(mlc_exb_req_wake), .dst_credit({mlc_exb_req_credit}), .dst_stall({mlc_exb_req_stall})
`ifdef CCV_TRACE
    , .src_tid({b_mlc_exb_req_tid}), .dst_tid({mlc_exb_req_tid})
`endif
  );
  // ccv_exb_mlc_rsp, destination end
  ccv_seq_rpt #(.STAGES(RPT_EXB_MLC_RSP), .SLOTS(1), .PAYLOAD_W(1082)) u_rpt_exb_mlc_rsp (
    .clk(core_clk), .rst_n(rst_n),
    .src_valid({exb_mlc_rsp_valid}), .src_payload({exb_mlc_rsp_payload}),
    .src_wake(exb_mlc_rsp_wake), .src_credit({exb_mlc_rsp_credit}), .src_stall({exb_mlc_rsp_stall}),
    .dst_valid({b_exb_mlc_rsp_valid}), .dst_payload({b_exb_mlc_rsp_payload}),
    .dst_wake(b_exb_mlc_rsp_wake), .dst_credit({b_exb_mlc_rsp_credit}), .dst_stall({b_exb_mlc_rsp_stall})
`ifdef CCV_TRACE
    , .src_tid({exb_mlc_rsp_tid}), .dst_tid({b_exb_mlc_rsp_tid})
`endif
  );
endmodule
