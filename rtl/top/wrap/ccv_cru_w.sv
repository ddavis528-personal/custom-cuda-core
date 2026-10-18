// GENERATED FILE -- DO NOT EDIT.
//
// Produced by tools/gen-top.py from schema/interfaces.json and
// params/blocks.json. Edit a source and regenerate; tools/verify.sh fails if
// this file is stale.

// HARDENING WRAPPER ccv_cru_w: ccv_cru and the sequential repeaters of its
// channel ends -- the physical hierarchy (docs/physical.md, "Wrappers
// and links"). Nothing but instances and nets, like the top. An end
// whose link has no stages here is connected straight through.
// Each end's stages are a parameter the top sets from params/links.json;
// at 0 the end is wired straight through, with no repeater.
`include "ccv_interfaces.svh"

module ccv_cru_w #(
  parameter int RPT_OOE_CRU_FAULT = 0,
  parameter int RPT_CRU_RAU_CFG = 0
) (
  `include "ccv_cru_ports.svh"
);

  // Between the block and its repeaters: b_<port>, one net per port.
  logic b_ooe_cru_fault_valid;
  ccv_ooe_cru_fault_t b_ooe_cru_fault_payload;
  logic b_ooe_cru_fault_credit;
  logic b_ooe_cru_fault_stall;
  logic b_ooe_cru_fault_wake;
  logic b_cru_rau_cfg_valid;
  ccv_cru_rau_cfg_t b_cru_rau_cfg_payload;
  logic b_cru_rau_cfg_credit;
  logic b_cru_rau_cfg_stall;
  logic b_cru_rau_cfg_wake;
`ifdef CCV_TRACE
  logic [63:0] b_ooe_cru_fault_tid;
  logic [63:0] b_cru_rau_cfg_tid;
`endif

  ccv_cru u_blk (
    .core_clk(core_clk),
    .rst_n(rst_n),
    .csr_req(csr_req),
    .csr_reqs(csr_reqs),
    .csr_rsp(csr_rsp),
    .csr_rsps(csr_rsps),
    .csr_credit(csr_credit),
    .csr_credits(csr_credits),
    .ooe_cru_fault_valid(b_ooe_cru_fault_valid),
    .ooe_cru_fault_payload(b_ooe_cru_fault_payload),
    .ooe_cru_fault_credit(b_ooe_cru_fault_credit),
    .ooe_cru_fault_stall(b_ooe_cru_fault_stall),
    .ooe_cru_fault_wake(b_ooe_cru_fault_wake),
    .cru_rau_cfg_valid(b_cru_rau_cfg_valid),
    .cru_rau_cfg_payload(b_cru_rau_cfg_payload),
    .cru_rau_cfg_credit(b_cru_rau_cfg_credit),
    .cru_rau_cfg_stall(b_cru_rau_cfg_stall),
    .cru_rau_cfg_wake(b_cru_rau_cfg_wake)
`ifdef CCV_CHECK
    , .clk_gated(clk_gated)
`endif
`ifdef CCV_TRACE
    , .ooe_cru_fault_tid(b_ooe_cru_fault_tid)
    , .cru_rau_cfg_tid(b_cru_rau_cfg_tid)
`endif
  );

  // ccv_ooe_cru_fault, destination end
  if (RPT_OOE_CRU_FAULT > 0) begin : g_rpt_ooe_cru_fault
    ccv_common_rpt #(.STAGES(RPT_OOE_CRU_FAULT), .SLOTS(1), .PAYLOAD_W(172)) u_rpt_ooe_cru_fault (
      .clk(core_clk), .rst_n(rst_n),
      .src_valid({ooe_cru_fault_valid}), .src_payload({ooe_cru_fault_payload}),
      .src_wake(ooe_cru_fault_wake), .src_credit({ooe_cru_fault_credit}), .src_stall({ooe_cru_fault_stall}),
      .dst_valid({b_ooe_cru_fault_valid}), .dst_payload({b_ooe_cru_fault_payload}),
      .dst_wake(b_ooe_cru_fault_wake), .dst_credit({b_ooe_cru_fault_credit}), .dst_stall({b_ooe_cru_fault_stall})
`ifdef CCV_TRACE
      , .src_tid({ooe_cru_fault_tid}), .dst_tid({b_ooe_cru_fault_tid})
`endif
    );
  end else begin : g_wire_ooe_cru_fault
    assign {b_ooe_cru_fault_valid} = {ooe_cru_fault_valid};
    assign {b_ooe_cru_fault_payload} = {ooe_cru_fault_payload};
    assign b_ooe_cru_fault_wake = ooe_cru_fault_wake;
    assign {ooe_cru_fault_credit} = {b_ooe_cru_fault_credit};
    assign {ooe_cru_fault_stall} = {b_ooe_cru_fault_stall};
`ifdef CCV_TRACE
    assign {b_ooe_cru_fault_tid} = {ooe_cru_fault_tid};
`endif
  end
  // ccv_cru_rau_cfg, source end
  if (RPT_CRU_RAU_CFG > 0) begin : g_rpt_cru_rau_cfg
    ccv_common_rpt #(.STAGES(RPT_CRU_RAU_CFG), .SLOTS(1), .PAYLOAD_W(74)) u_rpt_cru_rau_cfg (
      .clk(core_clk), .rst_n(rst_n),
      .src_valid({b_cru_rau_cfg_valid}), .src_payload({b_cru_rau_cfg_payload}),
      .src_wake(b_cru_rau_cfg_wake), .src_credit({b_cru_rau_cfg_credit}), .src_stall({b_cru_rau_cfg_stall}),
      .dst_valid({cru_rau_cfg_valid}), .dst_payload({cru_rau_cfg_payload}),
      .dst_wake(cru_rau_cfg_wake), .dst_credit({cru_rau_cfg_credit}), .dst_stall({cru_rau_cfg_stall})
`ifdef CCV_TRACE
      , .src_tid({b_cru_rau_cfg_tid}), .dst_tid({cru_rau_cfg_tid})
`endif
    );
  end else begin : g_wire_cru_rau_cfg
    assign {cru_rau_cfg_valid} = {b_cru_rau_cfg_valid};
    assign {cru_rau_cfg_payload} = {b_cru_rau_cfg_payload};
    assign cru_rau_cfg_wake = b_cru_rau_cfg_wake;
    assign {b_cru_rau_cfg_credit} = {cru_rau_cfg_credit};
    assign {b_cru_rau_cfg_stall} = {cru_rau_cfg_stall};
`ifdef CCV_TRACE
    assign {cru_rau_cfg_tid} = {b_cru_rau_cfg_tid};
`endif
  end
endmodule
