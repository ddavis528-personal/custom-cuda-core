// GENERATED FILE -- DO NOT EDIT.
//
// Produced by tools/gen-top.py from schema/interfaces.json and
// params/blocks.json. Edit a source and regenerate; tools/verify.sh fails if
// this file is stale.

// HARDENING WRAPPER ccv_exb_w: ccv_exb and the sequential repeaters of its
// channel ends -- the physical hierarchy (docs/physical.md, "Wrappers
// and links"). Nothing but instances and nets, like the top. Every
// end has its repeater whether or not the link is repeated: STAGES is
// a parameter the top sets from params/links.json, 0 meaning wires, so
// a new split changes parameters and never this structure.
`include "ccv_interfaces.svh"

module ccv_exb_w #(
  parameter int RPT_MLC_EXB_REQ = 0,
  parameter int RPT_EXB_MLC_RSP = 0,
  parameter int RPT_EXB_EXT_OUT = 0,
  parameter int RPT_EXT_EXB_IN = 0
) (
  `include "ccv_exb_ports.svh"
);

  // Between the block and its repeaters: b_<port>, one net per port.
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
  logic b_exb_ext_out_valid;
  ccv_exb_ext_out_t b_exb_ext_out_payload;
  logic b_exb_ext_out_credit;
  logic b_exb_ext_out_stall;
  logic b_exb_ext_out_wake;
  logic b_ext_exb_in_valid;
  ccv_ext_exb_in_t b_ext_exb_in_payload;
  logic b_ext_exb_in_credit;
  logic b_ext_exb_in_stall;
  logic b_ext_exb_in_wake;
`ifdef CCV_TRACE
  logic [63:0] b_mlc_exb_req_tid;
  logic [63:0] b_exb_mlc_rsp_tid;
  logic [63:0] b_exb_ext_out_tid;
  logic [63:0] b_ext_exb_in_tid;
`endif

  ccv_exb u_blk (
    .core_clk(core_clk),
    .rst_n(rst_n),
    .csr_req(csr_req),
    .csr_rsp(csr_rsp),
    .csr_credit(csr_credit),
    .mlc_exb_req_valid(b_mlc_exb_req_valid),
    .mlc_exb_req_payload(b_mlc_exb_req_payload),
    .mlc_exb_req_credit(b_mlc_exb_req_credit),
    .mlc_exb_req_stall(b_mlc_exb_req_stall),
    .mlc_exb_req_wake(b_mlc_exb_req_wake),
    .exb_mlc_rsp_valid(b_exb_mlc_rsp_valid),
    .exb_mlc_rsp_payload(b_exb_mlc_rsp_payload),
    .exb_mlc_rsp_credit(b_exb_mlc_rsp_credit),
    .exb_mlc_rsp_stall(b_exb_mlc_rsp_stall),
    .exb_mlc_rsp_wake(b_exb_mlc_rsp_wake),
    .exb_ext_out_valid(b_exb_ext_out_valid),
    .exb_ext_out_payload(b_exb_ext_out_payload),
    .exb_ext_out_credit(b_exb_ext_out_credit),
    .exb_ext_out_stall(b_exb_ext_out_stall),
    .exb_ext_out_wake(b_exb_ext_out_wake),
    .ext_exb_in_valid(b_ext_exb_in_valid),
    .ext_exb_in_payload(b_ext_exb_in_payload),
    .ext_exb_in_credit(b_ext_exb_in_credit),
    .ext_exb_in_stall(b_ext_exb_in_stall),
    .ext_exb_in_wake(b_ext_exb_in_wake)
`ifdef CCV_CHECK
    , .clk_gated(clk_gated)
`endif
`ifdef CCV_TRACE
    , .mlc_exb_req_tid(b_mlc_exb_req_tid)
    , .exb_mlc_rsp_tid(b_exb_mlc_rsp_tid)
    , .exb_ext_out_tid(b_exb_ext_out_tid)
    , .ext_exb_in_tid(b_ext_exb_in_tid)
`endif
  );

  // ccv_mlc_exb_req, destination end
  ccv_seq_rpt #(.STAGES(RPT_MLC_EXB_REQ), .SLOTS(1), .PAYLOAD_W(1090)) u_rpt_mlc_exb_req (
    .clk(core_clk), .rst_n(rst_n),
    .src_valid({mlc_exb_req_valid}), .src_payload({mlc_exb_req_payload}),
    .src_wake(mlc_exb_req_wake), .src_credit({mlc_exb_req_credit}), .src_stall({mlc_exb_req_stall}),
    .dst_valid({b_mlc_exb_req_valid}), .dst_payload({b_mlc_exb_req_payload}),
    .dst_wake(b_mlc_exb_req_wake), .dst_credit({b_mlc_exb_req_credit}), .dst_stall({b_mlc_exb_req_stall})
`ifdef CCV_TRACE
    , .src_tid({mlc_exb_req_tid}), .dst_tid({b_mlc_exb_req_tid})
`endif
  );
  // ccv_exb_mlc_rsp, source end
  ccv_seq_rpt #(.STAGES(RPT_EXB_MLC_RSP), .SLOTS(1), .PAYLOAD_W(1082)) u_rpt_exb_mlc_rsp (
    .clk(core_clk), .rst_n(rst_n),
    .src_valid({b_exb_mlc_rsp_valid}), .src_payload({b_exb_mlc_rsp_payload}),
    .src_wake(b_exb_mlc_rsp_wake), .src_credit({b_exb_mlc_rsp_credit}), .src_stall({b_exb_mlc_rsp_stall}),
    .dst_valid({exb_mlc_rsp_valid}), .dst_payload({exb_mlc_rsp_payload}),
    .dst_wake(exb_mlc_rsp_wake), .dst_credit({exb_mlc_rsp_credit}), .dst_stall({exb_mlc_rsp_stall})
`ifdef CCV_TRACE
    , .src_tid({b_exb_mlc_rsp_tid}), .dst_tid({exb_mlc_rsp_tid})
`endif
  );
  // ccv_exb_ext_out, source end
  ccv_seq_rpt #(.STAGES(RPT_EXB_EXT_OUT), .SLOTS(1), .PAYLOAD_W(1225)) u_rpt_exb_ext_out (
    .clk(core_clk), .rst_n(rst_n),
    .src_valid({b_exb_ext_out_valid}), .src_payload({b_exb_ext_out_payload}),
    .src_wake(b_exb_ext_out_wake), .src_credit({b_exb_ext_out_credit}), .src_stall({b_exb_ext_out_stall}),
    .dst_valid({exb_ext_out_valid}), .dst_payload({exb_ext_out_payload}),
    .dst_wake(exb_ext_out_wake), .dst_credit({exb_ext_out_credit}), .dst_stall({exb_ext_out_stall})
`ifdef CCV_TRACE
    , .src_tid({b_exb_ext_out_tid}), .dst_tid({exb_ext_out_tid})
`endif
  );
  // ccv_ext_exb_in, destination end
  ccv_seq_rpt #(.STAGES(RPT_EXT_EXB_IN), .SLOTS(1), .PAYLOAD_W(1176)) u_rpt_ext_exb_in (
    .clk(core_clk), .rst_n(rst_n),
    .src_valid({ext_exb_in_valid}), .src_payload({ext_exb_in_payload}),
    .src_wake(ext_exb_in_wake), .src_credit({ext_exb_in_credit}), .src_stall({ext_exb_in_stall}),
    .dst_valid({b_ext_exb_in_valid}), .dst_payload({b_ext_exb_in_payload}),
    .dst_wake(b_ext_exb_in_wake), .dst_credit({b_ext_exb_in_credit}), .dst_stall({b_ext_exb_in_stall})
`ifdef CCV_TRACE
    , .src_tid({ext_exb_in_tid}), .dst_tid({b_ext_exb_in_tid})
`endif
  );
endmodule
