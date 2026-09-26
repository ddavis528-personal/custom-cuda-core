// GENERATED FILE -- DO NOT EDIT.
//
// Produced by tools/gen-top.py from schema/interfaces.json and
// params/blocks.json. Edit a source and regenerate; tools/verify.sh fails if
// this file is stale.

// HARDENING WRAPPER ccv_syu_w: ccv_syu and the sequential repeaters of its
// channel ends -- the physical hierarchy (docs/physical.md, "Wrappers
// and links"). Nothing but instances and nets, like the top. Every
// end has its repeater whether or not the link is repeated.
// STAGES is a parameter the top sets from params/links.json, 0 meaning
// wires, so a new split changes parameters and never this structure.
`include "ccv_interfaces.svh"

module ccv_syu_w #(
  parameter int RPT_OOE_SYU_BAR = 0,
  parameter int RPT_SYU_OOE_REL = 0,
  parameter int RPT_RAU_SYU_ALLOC = 0
) (
  `include "ccv_syu_ports.svh"
);

  // Between the block and its repeaters: b_<port>, one net per port.
  logic b_ooe_syu_bar_valid;
  ccv_ooe_syu_bar_t b_ooe_syu_bar_payload;
  logic b_ooe_syu_bar_credit;
  logic b_ooe_syu_bar_stall;
  logic b_ooe_syu_bar_wake;
  logic b_syu_ooe_rel_valid;
  ccv_syu_ooe_rel_t b_syu_ooe_rel_payload;
  logic b_syu_ooe_rel_credit;
  logic b_syu_ooe_rel_stall;
  logic b_syu_ooe_rel_wake;
  logic b_rau_syu_alloc_valid;
  ccv_rau_syu_alloc_t b_rau_syu_alloc_payload;
  logic b_rau_syu_alloc_credit;
  logic b_rau_syu_alloc_stall;
  logic b_rau_syu_alloc_wake;
`ifdef CCV_TRACE
  logic [63:0] b_ooe_syu_bar_tid;
  logic [63:0] b_syu_ooe_rel_tid;
  logic [63:0] b_rau_syu_alloc_tid;
`endif

  ccv_syu u_blk (
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
    .ooe_syu_bar_valid(b_ooe_syu_bar_valid),
    .ooe_syu_bar_payload(b_ooe_syu_bar_payload),
    .ooe_syu_bar_credit(b_ooe_syu_bar_credit),
    .ooe_syu_bar_stall(b_ooe_syu_bar_stall),
    .ooe_syu_bar_wake(b_ooe_syu_bar_wake),
    .syu_ooe_rel_valid(b_syu_ooe_rel_valid),
    .syu_ooe_rel_payload(b_syu_ooe_rel_payload),
    .syu_ooe_rel_credit(b_syu_ooe_rel_credit),
    .syu_ooe_rel_stall(b_syu_ooe_rel_stall),
    .syu_ooe_rel_wake(b_syu_ooe_rel_wake),
    .rau_syu_alloc_valid(b_rau_syu_alloc_valid),
    .rau_syu_alloc_payload(b_rau_syu_alloc_payload),
    .rau_syu_alloc_credit(b_rau_syu_alloc_credit),
    .rau_syu_alloc_stall(b_rau_syu_alloc_stall),
    .rau_syu_alloc_wake(b_rau_syu_alloc_wake)
`ifdef CCV_CHECK
    , .clk_gated(clk_gated)
`endif
`ifdef CCV_TRACE
    , .ooe_syu_bar_tid(b_ooe_syu_bar_tid)
    , .syu_ooe_rel_tid(b_syu_ooe_rel_tid)
    , .rau_syu_alloc_tid(b_rau_syu_alloc_tid)
`endif
  );

  // ccv_ooe_syu_bar, destination end
  ccv_seq_rpt #(.STAGES(RPT_OOE_SYU_BAR), .SLOTS(1), .PAYLOAD_W(13)) u_rpt_ooe_syu_bar (
    .clk(core_clk), .rst_n(rst_n),
    .src_valid({ooe_syu_bar_valid}), .src_payload({ooe_syu_bar_payload}),
    .src_wake(ooe_syu_bar_wake), .src_credit({ooe_syu_bar_credit}), .src_stall({ooe_syu_bar_stall}),
    .dst_valid({b_ooe_syu_bar_valid}), .dst_payload({b_ooe_syu_bar_payload}),
    .dst_wake(b_ooe_syu_bar_wake), .dst_credit({b_ooe_syu_bar_credit}), .dst_stall({b_ooe_syu_bar_stall})
`ifdef CCV_TRACE
    , .src_tid({ooe_syu_bar_tid}), .dst_tid({b_ooe_syu_bar_tid})
`endif
  );
  // ccv_syu_ooe_rel, source end
  ccv_seq_rpt #(.STAGES(RPT_SYU_OOE_REL), .SLOTS(1), .PAYLOAD_W(36)) u_rpt_syu_ooe_rel (
    .clk(core_clk), .rst_n(rst_n),
    .src_valid({b_syu_ooe_rel_valid}), .src_payload({b_syu_ooe_rel_payload}),
    .src_wake(b_syu_ooe_rel_wake), .src_credit({b_syu_ooe_rel_credit}), .src_stall({b_syu_ooe_rel_stall}),
    .dst_valid({syu_ooe_rel_valid}), .dst_payload({syu_ooe_rel_payload}),
    .dst_wake(syu_ooe_rel_wake), .dst_credit({syu_ooe_rel_credit}), .dst_stall({syu_ooe_rel_stall})
`ifdef CCV_TRACE
    , .src_tid({b_syu_ooe_rel_tid}), .dst_tid({syu_ooe_rel_tid})
`endif
  );
  // ccv_rau_syu_alloc, destination end
  ccv_seq_rpt #(.STAGES(RPT_RAU_SYU_ALLOC), .SLOTS(1), .PAYLOAD_W(17)) u_rpt_rau_syu_alloc (
    .clk(core_clk), .rst_n(rst_n),
    .src_valid({rau_syu_alloc_valid}), .src_payload({rau_syu_alloc_payload}),
    .src_wake(rau_syu_alloc_wake), .src_credit({rau_syu_alloc_credit}), .src_stall({rau_syu_alloc_stall}),
    .dst_valid({b_rau_syu_alloc_valid}), .dst_payload({b_rau_syu_alloc_payload}),
    .dst_wake(b_rau_syu_alloc_wake), .dst_credit({b_rau_syu_alloc_credit}), .dst_stall({b_rau_syu_alloc_stall})
`ifdef CCV_TRACE
    , .src_tid({rau_syu_alloc_tid}), .dst_tid({b_rau_syu_alloc_tid})
`endif
  );
endmodule
