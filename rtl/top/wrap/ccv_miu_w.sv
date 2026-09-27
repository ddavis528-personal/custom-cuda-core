// GENERATED FILE -- DO NOT EDIT.
//
// Produced by tools/gen-top.py from schema/interfaces.json and
// params/blocks.json. Edit a source and regenerate; tools/verify.sh fails if
// this file is stale.

// HARDENING WRAPPER ccv_miu_w: ccv_miu and the sequential repeaters of its
// channel ends -- the physical hierarchy (docs/physical.md, "Wrappers
// and links"). Nothing but instances and nets, like the top. Every
// end has its repeater whether or not the link is repeated.
// STAGES is a parameter the top sets from params/links.json, 0 meaning
// wires, so a new split changes parameters and never this structure.
`include "ccv_interfaces.svh"

module ccv_miu_w #(
  parameter int RPT_RCU_MIU_ADDR = 0,
  parameter int RPT_MIU_RCU_DATA = 0,
  parameter int RPT_OOE_MIU_MEMOP = 0,
  parameter int RPT_MIU_OOE_CMPL = 0,
  parameter int RPT_OOE_MIU_RETIRE = 0,
  parameter int RPT_MIU_SPM_REQ = 0,
  parameter int RPT_SPM_MIU_RSP = 0,
  parameter int RPT_MIU_DCU_REQ = 0,
  parameter int RPT_DCU_MIU_RSP = 0,
  parameter int RPT_MIU_FET_ITLB = 0,
  parameter int RPT_FET_MIU_ITLB_REQ = 0,
  parameter int RPT_RAU_MIU_CTA = 0
) (
  `include "ccv_miu_ports.svh"
);

  // Between the block and its repeaters: b_<port>, one net per port.
  logic b_rcu_miu_addr_s0_valid;
  ccv_rcu_miu_addr_t b_rcu_miu_addr_s0_payload;
  logic b_rcu_miu_addr_s0_credit;
  logic b_rcu_miu_addr_s0_stall;
  logic b_rcu_miu_addr_s1_valid;
  ccv_rcu_miu_addr_t b_rcu_miu_addr_s1_payload;
  logic b_rcu_miu_addr_s1_credit;
  logic b_rcu_miu_addr_s1_stall;
  logic b_rcu_miu_addr_s2_valid;
  ccv_rcu_miu_addr_t b_rcu_miu_addr_s2_payload;
  logic b_rcu_miu_addr_s2_credit;
  logic b_rcu_miu_addr_s2_stall;
  logic b_rcu_miu_addr_s3_valid;
  ccv_rcu_miu_addr_t b_rcu_miu_addr_s3_payload;
  logic b_rcu_miu_addr_s3_credit;
  logic b_rcu_miu_addr_s3_stall;
  logic b_rcu_miu_addr_wake;
  logic b_miu_rcu_data_s0_valid;
  ccv_miu_rcu_data_t b_miu_rcu_data_s0_payload;
  logic b_miu_rcu_data_s0_credit;
  logic b_miu_rcu_data_s0_stall;
  logic b_miu_rcu_data_s1_valid;
  ccv_miu_rcu_data_t b_miu_rcu_data_s1_payload;
  logic b_miu_rcu_data_s1_credit;
  logic b_miu_rcu_data_s1_stall;
  logic b_miu_rcu_data_s2_valid;
  ccv_miu_rcu_data_t b_miu_rcu_data_s2_payload;
  logic b_miu_rcu_data_s2_credit;
  logic b_miu_rcu_data_s2_stall;
  logic b_miu_rcu_data_s3_valid;
  ccv_miu_rcu_data_t b_miu_rcu_data_s3_payload;
  logic b_miu_rcu_data_s3_credit;
  logic b_miu_rcu_data_s3_stall;
  logic b_miu_rcu_data_wake;
  logic b_ooe_miu_memop_s0_valid;
  ccv_ooe_miu_memop_t b_ooe_miu_memop_s0_payload;
  logic b_ooe_miu_memop_s0_credit;
  logic b_ooe_miu_memop_s0_stall;
  logic b_ooe_miu_memop_s1_valid;
  ccv_ooe_miu_memop_t b_ooe_miu_memop_s1_payload;
  logic b_ooe_miu_memop_s1_credit;
  logic b_ooe_miu_memop_s1_stall;
  logic b_ooe_miu_memop_s2_valid;
  ccv_ooe_miu_memop_t b_ooe_miu_memop_s2_payload;
  logic b_ooe_miu_memop_s2_credit;
  logic b_ooe_miu_memop_s2_stall;
  logic b_ooe_miu_memop_s3_valid;
  ccv_ooe_miu_memop_t b_ooe_miu_memop_s3_payload;
  logic b_ooe_miu_memop_s3_credit;
  logic b_ooe_miu_memop_s3_stall;
  logic b_ooe_miu_memop_wake;
  logic b_miu_ooe_cmpl_s0_valid;
  ccv_miu_ooe_cmpl_t b_miu_ooe_cmpl_s0_payload;
  logic b_miu_ooe_cmpl_s0_credit;
  logic b_miu_ooe_cmpl_s0_stall;
  logic b_miu_ooe_cmpl_s1_valid;
  ccv_miu_ooe_cmpl_t b_miu_ooe_cmpl_s1_payload;
  logic b_miu_ooe_cmpl_s1_credit;
  logic b_miu_ooe_cmpl_s1_stall;
  logic b_miu_ooe_cmpl_s2_valid;
  ccv_miu_ooe_cmpl_t b_miu_ooe_cmpl_s2_payload;
  logic b_miu_ooe_cmpl_s2_credit;
  logic b_miu_ooe_cmpl_s2_stall;
  logic b_miu_ooe_cmpl_s3_valid;
  ccv_miu_ooe_cmpl_t b_miu_ooe_cmpl_s3_payload;
  logic b_miu_ooe_cmpl_s3_credit;
  logic b_miu_ooe_cmpl_s3_stall;
  logic b_miu_ooe_cmpl_wake;
  logic b_ooe_miu_retire_s0_valid;
  ccv_ooe_miu_retire_t b_ooe_miu_retire_s0_payload;
  logic b_ooe_miu_retire_s0_credit;
  logic b_ooe_miu_retire_s0_stall;
  logic b_ooe_miu_retire_s1_valid;
  ccv_ooe_miu_retire_t b_ooe_miu_retire_s1_payload;
  logic b_ooe_miu_retire_s1_credit;
  logic b_ooe_miu_retire_s1_stall;
  logic b_ooe_miu_retire_s2_valid;
  ccv_ooe_miu_retire_t b_ooe_miu_retire_s2_payload;
  logic b_ooe_miu_retire_s2_credit;
  logic b_ooe_miu_retire_s2_stall;
  logic b_ooe_miu_retire_s3_valid;
  ccv_ooe_miu_retire_t b_ooe_miu_retire_s3_payload;
  logic b_ooe_miu_retire_s3_credit;
  logic b_ooe_miu_retire_s3_stall;
  logic b_ooe_miu_retire_wake;
  logic b_miu_spm_req_s0_valid;
  ccv_miu_spm_req_t b_miu_spm_req_s0_payload;
  logic b_miu_spm_req_s0_credit;
  logic b_miu_spm_req_s0_stall;
  logic b_miu_spm_req_s1_valid;
  ccv_miu_spm_req_t b_miu_spm_req_s1_payload;
  logic b_miu_spm_req_s1_credit;
  logic b_miu_spm_req_s1_stall;
  logic b_miu_spm_req_s2_valid;
  ccv_miu_spm_req_t b_miu_spm_req_s2_payload;
  logic b_miu_spm_req_s2_credit;
  logic b_miu_spm_req_s2_stall;
  logic b_miu_spm_req_s3_valid;
  ccv_miu_spm_req_t b_miu_spm_req_s3_payload;
  logic b_miu_spm_req_s3_credit;
  logic b_miu_spm_req_s3_stall;
  logic b_miu_spm_req_wake;
  logic b_spm_miu_rsp_s0_valid;
  ccv_spm_miu_rsp_t b_spm_miu_rsp_s0_payload;
  logic b_spm_miu_rsp_s0_credit;
  logic b_spm_miu_rsp_s0_stall;
  logic b_spm_miu_rsp_s1_valid;
  ccv_spm_miu_rsp_t b_spm_miu_rsp_s1_payload;
  logic b_spm_miu_rsp_s1_credit;
  logic b_spm_miu_rsp_s1_stall;
  logic b_spm_miu_rsp_s2_valid;
  ccv_spm_miu_rsp_t b_spm_miu_rsp_s2_payload;
  logic b_spm_miu_rsp_s2_credit;
  logic b_spm_miu_rsp_s2_stall;
  logic b_spm_miu_rsp_s3_valid;
  ccv_spm_miu_rsp_t b_spm_miu_rsp_s3_payload;
  logic b_spm_miu_rsp_s3_credit;
  logic b_spm_miu_rsp_s3_stall;
  logic b_spm_miu_rsp_wake;
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
  logic b_miu_fet_itlb_valid;
  ccv_miu_fet_itlb_t b_miu_fet_itlb_payload;
  logic b_miu_fet_itlb_credit;
  logic b_miu_fet_itlb_stall;
  logic b_miu_fet_itlb_wake;
  logic b_fet_miu_itlb_req_valid;
  ccv_fet_miu_itlb_req_t b_fet_miu_itlb_req_payload;
  logic b_fet_miu_itlb_req_credit;
  logic b_fet_miu_itlb_req_stall;
  logic b_fet_miu_itlb_req_wake;
  logic b_rau_miu_cta_valid;
  ccv_rau_miu_cta_t b_rau_miu_cta_payload;
  logic b_rau_miu_cta_credit;
  logic b_rau_miu_cta_stall;
  logic b_rau_miu_cta_wake;
`ifdef CCV_TRACE
  logic [63:0] b_rcu_miu_addr_s0_tid;
  logic [63:0] b_rcu_miu_addr_s1_tid;
  logic [63:0] b_rcu_miu_addr_s2_tid;
  logic [63:0] b_rcu_miu_addr_s3_tid;
  logic [63:0] b_miu_rcu_data_s0_tid;
  logic [63:0] b_miu_rcu_data_s1_tid;
  logic [63:0] b_miu_rcu_data_s2_tid;
  logic [63:0] b_miu_rcu_data_s3_tid;
  logic [63:0] b_ooe_miu_memop_s0_tid;
  logic [63:0] b_ooe_miu_memop_s1_tid;
  logic [63:0] b_ooe_miu_memop_s2_tid;
  logic [63:0] b_ooe_miu_memop_s3_tid;
  logic [63:0] b_miu_ooe_cmpl_s0_tid;
  logic [63:0] b_miu_ooe_cmpl_s1_tid;
  logic [63:0] b_miu_ooe_cmpl_s2_tid;
  logic [63:0] b_miu_ooe_cmpl_s3_tid;
  logic [63:0] b_ooe_miu_retire_s0_tid;
  logic [63:0] b_ooe_miu_retire_s1_tid;
  logic [63:0] b_ooe_miu_retire_s2_tid;
  logic [63:0] b_ooe_miu_retire_s3_tid;
  logic [63:0] b_miu_spm_req_s0_tid;
  logic [63:0] b_miu_spm_req_s1_tid;
  logic [63:0] b_miu_spm_req_s2_tid;
  logic [63:0] b_miu_spm_req_s3_tid;
  logic [63:0] b_spm_miu_rsp_s0_tid;
  logic [63:0] b_spm_miu_rsp_s1_tid;
  logic [63:0] b_spm_miu_rsp_s2_tid;
  logic [63:0] b_spm_miu_rsp_s3_tid;
  logic [63:0] b_miu_dcu_req_s0_tid;
  logic [63:0] b_miu_dcu_req_s1_tid;
  logic [63:0] b_miu_dcu_req_s2_tid;
  logic [63:0] b_miu_dcu_req_s3_tid;
  logic [63:0] b_dcu_miu_rsp_s0_tid;
  logic [63:0] b_dcu_miu_rsp_s1_tid;
  logic [63:0] b_dcu_miu_rsp_s2_tid;
  logic [63:0] b_dcu_miu_rsp_s3_tid;
  logic [63:0] b_miu_fet_itlb_tid;
  logic [63:0] b_fet_miu_itlb_req_tid;
  logic [63:0] b_rau_miu_cta_tid;
`endif

  ccv_miu u_blk (
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
    .rcu_miu_addr_s0_valid(b_rcu_miu_addr_s0_valid),
    .rcu_miu_addr_s0_payload(b_rcu_miu_addr_s0_payload),
    .rcu_miu_addr_s0_credit(b_rcu_miu_addr_s0_credit),
    .rcu_miu_addr_s0_stall(b_rcu_miu_addr_s0_stall),
    .rcu_miu_addr_s1_valid(b_rcu_miu_addr_s1_valid),
    .rcu_miu_addr_s1_payload(b_rcu_miu_addr_s1_payload),
    .rcu_miu_addr_s1_credit(b_rcu_miu_addr_s1_credit),
    .rcu_miu_addr_s1_stall(b_rcu_miu_addr_s1_stall),
    .rcu_miu_addr_s2_valid(b_rcu_miu_addr_s2_valid),
    .rcu_miu_addr_s2_payload(b_rcu_miu_addr_s2_payload),
    .rcu_miu_addr_s2_credit(b_rcu_miu_addr_s2_credit),
    .rcu_miu_addr_s2_stall(b_rcu_miu_addr_s2_stall),
    .rcu_miu_addr_s3_valid(b_rcu_miu_addr_s3_valid),
    .rcu_miu_addr_s3_payload(b_rcu_miu_addr_s3_payload),
    .rcu_miu_addr_s3_credit(b_rcu_miu_addr_s3_credit),
    .rcu_miu_addr_s3_stall(b_rcu_miu_addr_s3_stall),
    .rcu_miu_addr_wake(b_rcu_miu_addr_wake),
    .miu_rcu_data_s0_valid(b_miu_rcu_data_s0_valid),
    .miu_rcu_data_s0_payload(b_miu_rcu_data_s0_payload),
    .miu_rcu_data_s0_credit(b_miu_rcu_data_s0_credit),
    .miu_rcu_data_s0_stall(b_miu_rcu_data_s0_stall),
    .miu_rcu_data_s1_valid(b_miu_rcu_data_s1_valid),
    .miu_rcu_data_s1_payload(b_miu_rcu_data_s1_payload),
    .miu_rcu_data_s1_credit(b_miu_rcu_data_s1_credit),
    .miu_rcu_data_s1_stall(b_miu_rcu_data_s1_stall),
    .miu_rcu_data_s2_valid(b_miu_rcu_data_s2_valid),
    .miu_rcu_data_s2_payload(b_miu_rcu_data_s2_payload),
    .miu_rcu_data_s2_credit(b_miu_rcu_data_s2_credit),
    .miu_rcu_data_s2_stall(b_miu_rcu_data_s2_stall),
    .miu_rcu_data_s3_valid(b_miu_rcu_data_s3_valid),
    .miu_rcu_data_s3_payload(b_miu_rcu_data_s3_payload),
    .miu_rcu_data_s3_credit(b_miu_rcu_data_s3_credit),
    .miu_rcu_data_s3_stall(b_miu_rcu_data_s3_stall),
    .miu_rcu_data_wake(b_miu_rcu_data_wake),
    .ooe_miu_memop_s0_valid(b_ooe_miu_memop_s0_valid),
    .ooe_miu_memop_s0_payload(b_ooe_miu_memop_s0_payload),
    .ooe_miu_memop_s0_credit(b_ooe_miu_memop_s0_credit),
    .ooe_miu_memop_s0_stall(b_ooe_miu_memop_s0_stall),
    .ooe_miu_memop_s1_valid(b_ooe_miu_memop_s1_valid),
    .ooe_miu_memop_s1_payload(b_ooe_miu_memop_s1_payload),
    .ooe_miu_memop_s1_credit(b_ooe_miu_memop_s1_credit),
    .ooe_miu_memop_s1_stall(b_ooe_miu_memop_s1_stall),
    .ooe_miu_memop_s2_valid(b_ooe_miu_memop_s2_valid),
    .ooe_miu_memop_s2_payload(b_ooe_miu_memop_s2_payload),
    .ooe_miu_memop_s2_credit(b_ooe_miu_memop_s2_credit),
    .ooe_miu_memop_s2_stall(b_ooe_miu_memop_s2_stall),
    .ooe_miu_memop_s3_valid(b_ooe_miu_memop_s3_valid),
    .ooe_miu_memop_s3_payload(b_ooe_miu_memop_s3_payload),
    .ooe_miu_memop_s3_credit(b_ooe_miu_memop_s3_credit),
    .ooe_miu_memop_s3_stall(b_ooe_miu_memop_s3_stall),
    .ooe_miu_memop_wake(b_ooe_miu_memop_wake),
    .miu_ooe_cmpl_s0_valid(b_miu_ooe_cmpl_s0_valid),
    .miu_ooe_cmpl_s0_payload(b_miu_ooe_cmpl_s0_payload),
    .miu_ooe_cmpl_s0_credit(b_miu_ooe_cmpl_s0_credit),
    .miu_ooe_cmpl_s0_stall(b_miu_ooe_cmpl_s0_stall),
    .miu_ooe_cmpl_s1_valid(b_miu_ooe_cmpl_s1_valid),
    .miu_ooe_cmpl_s1_payload(b_miu_ooe_cmpl_s1_payload),
    .miu_ooe_cmpl_s1_credit(b_miu_ooe_cmpl_s1_credit),
    .miu_ooe_cmpl_s1_stall(b_miu_ooe_cmpl_s1_stall),
    .miu_ooe_cmpl_s2_valid(b_miu_ooe_cmpl_s2_valid),
    .miu_ooe_cmpl_s2_payload(b_miu_ooe_cmpl_s2_payload),
    .miu_ooe_cmpl_s2_credit(b_miu_ooe_cmpl_s2_credit),
    .miu_ooe_cmpl_s2_stall(b_miu_ooe_cmpl_s2_stall),
    .miu_ooe_cmpl_s3_valid(b_miu_ooe_cmpl_s3_valid),
    .miu_ooe_cmpl_s3_payload(b_miu_ooe_cmpl_s3_payload),
    .miu_ooe_cmpl_s3_credit(b_miu_ooe_cmpl_s3_credit),
    .miu_ooe_cmpl_s3_stall(b_miu_ooe_cmpl_s3_stall),
    .miu_ooe_cmpl_wake(b_miu_ooe_cmpl_wake),
    .ooe_miu_retire_s0_valid(b_ooe_miu_retire_s0_valid),
    .ooe_miu_retire_s0_payload(b_ooe_miu_retire_s0_payload),
    .ooe_miu_retire_s0_credit(b_ooe_miu_retire_s0_credit),
    .ooe_miu_retire_s0_stall(b_ooe_miu_retire_s0_stall),
    .ooe_miu_retire_s1_valid(b_ooe_miu_retire_s1_valid),
    .ooe_miu_retire_s1_payload(b_ooe_miu_retire_s1_payload),
    .ooe_miu_retire_s1_credit(b_ooe_miu_retire_s1_credit),
    .ooe_miu_retire_s1_stall(b_ooe_miu_retire_s1_stall),
    .ooe_miu_retire_s2_valid(b_ooe_miu_retire_s2_valid),
    .ooe_miu_retire_s2_payload(b_ooe_miu_retire_s2_payload),
    .ooe_miu_retire_s2_credit(b_ooe_miu_retire_s2_credit),
    .ooe_miu_retire_s2_stall(b_ooe_miu_retire_s2_stall),
    .ooe_miu_retire_s3_valid(b_ooe_miu_retire_s3_valid),
    .ooe_miu_retire_s3_payload(b_ooe_miu_retire_s3_payload),
    .ooe_miu_retire_s3_credit(b_ooe_miu_retire_s3_credit),
    .ooe_miu_retire_s3_stall(b_ooe_miu_retire_s3_stall),
    .ooe_miu_retire_wake(b_ooe_miu_retire_wake),
    .miu_spm_req_s0_valid(b_miu_spm_req_s0_valid),
    .miu_spm_req_s0_payload(b_miu_spm_req_s0_payload),
    .miu_spm_req_s0_credit(b_miu_spm_req_s0_credit),
    .miu_spm_req_s0_stall(b_miu_spm_req_s0_stall),
    .miu_spm_req_s1_valid(b_miu_spm_req_s1_valid),
    .miu_spm_req_s1_payload(b_miu_spm_req_s1_payload),
    .miu_spm_req_s1_credit(b_miu_spm_req_s1_credit),
    .miu_spm_req_s1_stall(b_miu_spm_req_s1_stall),
    .miu_spm_req_s2_valid(b_miu_spm_req_s2_valid),
    .miu_spm_req_s2_payload(b_miu_spm_req_s2_payload),
    .miu_spm_req_s2_credit(b_miu_spm_req_s2_credit),
    .miu_spm_req_s2_stall(b_miu_spm_req_s2_stall),
    .miu_spm_req_s3_valid(b_miu_spm_req_s3_valid),
    .miu_spm_req_s3_payload(b_miu_spm_req_s3_payload),
    .miu_spm_req_s3_credit(b_miu_spm_req_s3_credit),
    .miu_spm_req_s3_stall(b_miu_spm_req_s3_stall),
    .miu_spm_req_wake(b_miu_spm_req_wake),
    .spm_miu_rsp_s0_valid(b_spm_miu_rsp_s0_valid),
    .spm_miu_rsp_s0_payload(b_spm_miu_rsp_s0_payload),
    .spm_miu_rsp_s0_credit(b_spm_miu_rsp_s0_credit),
    .spm_miu_rsp_s0_stall(b_spm_miu_rsp_s0_stall),
    .spm_miu_rsp_s1_valid(b_spm_miu_rsp_s1_valid),
    .spm_miu_rsp_s1_payload(b_spm_miu_rsp_s1_payload),
    .spm_miu_rsp_s1_credit(b_spm_miu_rsp_s1_credit),
    .spm_miu_rsp_s1_stall(b_spm_miu_rsp_s1_stall),
    .spm_miu_rsp_s2_valid(b_spm_miu_rsp_s2_valid),
    .spm_miu_rsp_s2_payload(b_spm_miu_rsp_s2_payload),
    .spm_miu_rsp_s2_credit(b_spm_miu_rsp_s2_credit),
    .spm_miu_rsp_s2_stall(b_spm_miu_rsp_s2_stall),
    .spm_miu_rsp_s3_valid(b_spm_miu_rsp_s3_valid),
    .spm_miu_rsp_s3_payload(b_spm_miu_rsp_s3_payload),
    .spm_miu_rsp_s3_credit(b_spm_miu_rsp_s3_credit),
    .spm_miu_rsp_s3_stall(b_spm_miu_rsp_s3_stall),
    .spm_miu_rsp_wake(b_spm_miu_rsp_wake),
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
    .miu_fet_itlb_valid(b_miu_fet_itlb_valid),
    .miu_fet_itlb_payload(b_miu_fet_itlb_payload),
    .miu_fet_itlb_credit(b_miu_fet_itlb_credit),
    .miu_fet_itlb_stall(b_miu_fet_itlb_stall),
    .miu_fet_itlb_wake(b_miu_fet_itlb_wake),
    .fet_miu_itlb_req_valid(b_fet_miu_itlb_req_valid),
    .fet_miu_itlb_req_payload(b_fet_miu_itlb_req_payload),
    .fet_miu_itlb_req_credit(b_fet_miu_itlb_req_credit),
    .fet_miu_itlb_req_stall(b_fet_miu_itlb_req_stall),
    .fet_miu_itlb_req_wake(b_fet_miu_itlb_req_wake),
    .rau_miu_cta_valid(b_rau_miu_cta_valid),
    .rau_miu_cta_payload(b_rau_miu_cta_payload),
    .rau_miu_cta_credit(b_rau_miu_cta_credit),
    .rau_miu_cta_stall(b_rau_miu_cta_stall),
    .rau_miu_cta_wake(b_rau_miu_cta_wake)
`ifdef CCV_CHECK
    , .clk_gated(clk_gated)
`endif
`ifdef CCV_TRACE
    , .rcu_miu_addr_s0_tid(b_rcu_miu_addr_s0_tid)
    , .rcu_miu_addr_s1_tid(b_rcu_miu_addr_s1_tid)
    , .rcu_miu_addr_s2_tid(b_rcu_miu_addr_s2_tid)
    , .rcu_miu_addr_s3_tid(b_rcu_miu_addr_s3_tid)
    , .miu_rcu_data_s0_tid(b_miu_rcu_data_s0_tid)
    , .miu_rcu_data_s1_tid(b_miu_rcu_data_s1_tid)
    , .miu_rcu_data_s2_tid(b_miu_rcu_data_s2_tid)
    , .miu_rcu_data_s3_tid(b_miu_rcu_data_s3_tid)
    , .ooe_miu_memop_s0_tid(b_ooe_miu_memop_s0_tid)
    , .ooe_miu_memop_s1_tid(b_ooe_miu_memop_s1_tid)
    , .ooe_miu_memop_s2_tid(b_ooe_miu_memop_s2_tid)
    , .ooe_miu_memop_s3_tid(b_ooe_miu_memop_s3_tid)
    , .miu_ooe_cmpl_s0_tid(b_miu_ooe_cmpl_s0_tid)
    , .miu_ooe_cmpl_s1_tid(b_miu_ooe_cmpl_s1_tid)
    , .miu_ooe_cmpl_s2_tid(b_miu_ooe_cmpl_s2_tid)
    , .miu_ooe_cmpl_s3_tid(b_miu_ooe_cmpl_s3_tid)
    , .ooe_miu_retire_s0_tid(b_ooe_miu_retire_s0_tid)
    , .ooe_miu_retire_s1_tid(b_ooe_miu_retire_s1_tid)
    , .ooe_miu_retire_s2_tid(b_ooe_miu_retire_s2_tid)
    , .ooe_miu_retire_s3_tid(b_ooe_miu_retire_s3_tid)
    , .miu_spm_req_s0_tid(b_miu_spm_req_s0_tid)
    , .miu_spm_req_s1_tid(b_miu_spm_req_s1_tid)
    , .miu_spm_req_s2_tid(b_miu_spm_req_s2_tid)
    , .miu_spm_req_s3_tid(b_miu_spm_req_s3_tid)
    , .spm_miu_rsp_s0_tid(b_spm_miu_rsp_s0_tid)
    , .spm_miu_rsp_s1_tid(b_spm_miu_rsp_s1_tid)
    , .spm_miu_rsp_s2_tid(b_spm_miu_rsp_s2_tid)
    , .spm_miu_rsp_s3_tid(b_spm_miu_rsp_s3_tid)
    , .miu_dcu_req_s0_tid(b_miu_dcu_req_s0_tid)
    , .miu_dcu_req_s1_tid(b_miu_dcu_req_s1_tid)
    , .miu_dcu_req_s2_tid(b_miu_dcu_req_s2_tid)
    , .miu_dcu_req_s3_tid(b_miu_dcu_req_s3_tid)
    , .dcu_miu_rsp_s0_tid(b_dcu_miu_rsp_s0_tid)
    , .dcu_miu_rsp_s1_tid(b_dcu_miu_rsp_s1_tid)
    , .dcu_miu_rsp_s2_tid(b_dcu_miu_rsp_s2_tid)
    , .dcu_miu_rsp_s3_tid(b_dcu_miu_rsp_s3_tid)
    , .miu_fet_itlb_tid(b_miu_fet_itlb_tid)
    , .fet_miu_itlb_req_tid(b_fet_miu_itlb_req_tid)
    , .rau_miu_cta_tid(b_rau_miu_cta_tid)
`endif
  );

  // ccv_rcu_miu_addr, destination end
  ccv_seq_rpt #(.STAGES(RPT_RCU_MIU_ADDR), .SLOTS(4), .PAYLOAD_W(2151)) u_rpt_rcu_miu_addr (
    .clk(core_clk), .rst_n(rst_n),
    .src_valid({rcu_miu_addr_s3_valid, rcu_miu_addr_s2_valid, rcu_miu_addr_s1_valid, rcu_miu_addr_s0_valid}), .src_payload({rcu_miu_addr_s3_payload, rcu_miu_addr_s2_payload, rcu_miu_addr_s1_payload, rcu_miu_addr_s0_payload}),
    .src_wake(rcu_miu_addr_wake), .src_credit({rcu_miu_addr_s3_credit, rcu_miu_addr_s2_credit, rcu_miu_addr_s1_credit, rcu_miu_addr_s0_credit}), .src_stall({rcu_miu_addr_s3_stall, rcu_miu_addr_s2_stall, rcu_miu_addr_s1_stall, rcu_miu_addr_s0_stall}),
    .dst_valid({b_rcu_miu_addr_s3_valid, b_rcu_miu_addr_s2_valid, b_rcu_miu_addr_s1_valid, b_rcu_miu_addr_s0_valid}), .dst_payload({b_rcu_miu_addr_s3_payload, b_rcu_miu_addr_s2_payload, b_rcu_miu_addr_s1_payload, b_rcu_miu_addr_s0_payload}),
    .dst_wake(b_rcu_miu_addr_wake), .dst_credit({b_rcu_miu_addr_s3_credit, b_rcu_miu_addr_s2_credit, b_rcu_miu_addr_s1_credit, b_rcu_miu_addr_s0_credit}), .dst_stall({b_rcu_miu_addr_s3_stall, b_rcu_miu_addr_s2_stall, b_rcu_miu_addr_s1_stall, b_rcu_miu_addr_s0_stall})
`ifdef CCV_TRACE
    , .src_tid({rcu_miu_addr_s3_tid, rcu_miu_addr_s2_tid, rcu_miu_addr_s1_tid, rcu_miu_addr_s0_tid}), .dst_tid({b_rcu_miu_addr_s3_tid, b_rcu_miu_addr_s2_tid, b_rcu_miu_addr_s1_tid, b_rcu_miu_addr_s0_tid})
`endif
  );
  // ccv_miu_rcu_data, source end
  ccv_seq_rpt #(.STAGES(RPT_MIU_RCU_DATA), .SLOTS(4), .PAYLOAD_W(1112)) u_rpt_miu_rcu_data (
    .clk(core_clk), .rst_n(rst_n),
    .src_valid({b_miu_rcu_data_s3_valid, b_miu_rcu_data_s2_valid, b_miu_rcu_data_s1_valid, b_miu_rcu_data_s0_valid}), .src_payload({b_miu_rcu_data_s3_payload, b_miu_rcu_data_s2_payload, b_miu_rcu_data_s1_payload, b_miu_rcu_data_s0_payload}),
    .src_wake(b_miu_rcu_data_wake), .src_credit({b_miu_rcu_data_s3_credit, b_miu_rcu_data_s2_credit, b_miu_rcu_data_s1_credit, b_miu_rcu_data_s0_credit}), .src_stall({b_miu_rcu_data_s3_stall, b_miu_rcu_data_s2_stall, b_miu_rcu_data_s1_stall, b_miu_rcu_data_s0_stall}),
    .dst_valid({miu_rcu_data_s3_valid, miu_rcu_data_s2_valid, miu_rcu_data_s1_valid, miu_rcu_data_s0_valid}), .dst_payload({miu_rcu_data_s3_payload, miu_rcu_data_s2_payload, miu_rcu_data_s1_payload, miu_rcu_data_s0_payload}),
    .dst_wake(miu_rcu_data_wake), .dst_credit({miu_rcu_data_s3_credit, miu_rcu_data_s2_credit, miu_rcu_data_s1_credit, miu_rcu_data_s0_credit}), .dst_stall({miu_rcu_data_s3_stall, miu_rcu_data_s2_stall, miu_rcu_data_s1_stall, miu_rcu_data_s0_stall})
`ifdef CCV_TRACE
    , .src_tid({b_miu_rcu_data_s3_tid, b_miu_rcu_data_s2_tid, b_miu_rcu_data_s1_tid, b_miu_rcu_data_s0_tid}), .dst_tid({miu_rcu_data_s3_tid, miu_rcu_data_s2_tid, miu_rcu_data_s1_tid, miu_rcu_data_s0_tid})
`endif
  );
  // ccv_ooe_miu_memop, destination end
  ccv_seq_rpt #(.STAGES(RPT_OOE_MIU_MEMOP), .SLOTS(4), .PAYLOAD_W(93)) u_rpt_ooe_miu_memop (
    .clk(core_clk), .rst_n(rst_n),
    .src_valid({ooe_miu_memop_s3_valid, ooe_miu_memop_s2_valid, ooe_miu_memop_s1_valid, ooe_miu_memop_s0_valid}), .src_payload({ooe_miu_memop_s3_payload, ooe_miu_memop_s2_payload, ooe_miu_memop_s1_payload, ooe_miu_memop_s0_payload}),
    .src_wake(ooe_miu_memop_wake), .src_credit({ooe_miu_memop_s3_credit, ooe_miu_memop_s2_credit, ooe_miu_memop_s1_credit, ooe_miu_memop_s0_credit}), .src_stall({ooe_miu_memop_s3_stall, ooe_miu_memop_s2_stall, ooe_miu_memop_s1_stall, ooe_miu_memop_s0_stall}),
    .dst_valid({b_ooe_miu_memop_s3_valid, b_ooe_miu_memop_s2_valid, b_ooe_miu_memop_s1_valid, b_ooe_miu_memop_s0_valid}), .dst_payload({b_ooe_miu_memop_s3_payload, b_ooe_miu_memop_s2_payload, b_ooe_miu_memop_s1_payload, b_ooe_miu_memop_s0_payload}),
    .dst_wake(b_ooe_miu_memop_wake), .dst_credit({b_ooe_miu_memop_s3_credit, b_ooe_miu_memop_s2_credit, b_ooe_miu_memop_s1_credit, b_ooe_miu_memop_s0_credit}), .dst_stall({b_ooe_miu_memop_s3_stall, b_ooe_miu_memop_s2_stall, b_ooe_miu_memop_s1_stall, b_ooe_miu_memop_s0_stall})
`ifdef CCV_TRACE
    , .src_tid({ooe_miu_memop_s3_tid, ooe_miu_memop_s2_tid, ooe_miu_memop_s1_tid, ooe_miu_memop_s0_tid}), .dst_tid({b_ooe_miu_memop_s3_tid, b_ooe_miu_memop_s2_tid, b_ooe_miu_memop_s1_tid, b_ooe_miu_memop_s0_tid})
`endif
  );
  // ccv_miu_ooe_cmpl, source end
  ccv_seq_rpt #(.STAGES(RPT_MIU_OOE_CMPL), .SLOTS(4), .PAYLOAD_W(110)) u_rpt_miu_ooe_cmpl (
    .clk(core_clk), .rst_n(rst_n),
    .src_valid({b_miu_ooe_cmpl_s3_valid, b_miu_ooe_cmpl_s2_valid, b_miu_ooe_cmpl_s1_valid, b_miu_ooe_cmpl_s0_valid}), .src_payload({b_miu_ooe_cmpl_s3_payload, b_miu_ooe_cmpl_s2_payload, b_miu_ooe_cmpl_s1_payload, b_miu_ooe_cmpl_s0_payload}),
    .src_wake(b_miu_ooe_cmpl_wake), .src_credit({b_miu_ooe_cmpl_s3_credit, b_miu_ooe_cmpl_s2_credit, b_miu_ooe_cmpl_s1_credit, b_miu_ooe_cmpl_s0_credit}), .src_stall({b_miu_ooe_cmpl_s3_stall, b_miu_ooe_cmpl_s2_stall, b_miu_ooe_cmpl_s1_stall, b_miu_ooe_cmpl_s0_stall}),
    .dst_valid({miu_ooe_cmpl_s3_valid, miu_ooe_cmpl_s2_valid, miu_ooe_cmpl_s1_valid, miu_ooe_cmpl_s0_valid}), .dst_payload({miu_ooe_cmpl_s3_payload, miu_ooe_cmpl_s2_payload, miu_ooe_cmpl_s1_payload, miu_ooe_cmpl_s0_payload}),
    .dst_wake(miu_ooe_cmpl_wake), .dst_credit({miu_ooe_cmpl_s3_credit, miu_ooe_cmpl_s2_credit, miu_ooe_cmpl_s1_credit, miu_ooe_cmpl_s0_credit}), .dst_stall({miu_ooe_cmpl_s3_stall, miu_ooe_cmpl_s2_stall, miu_ooe_cmpl_s1_stall, miu_ooe_cmpl_s0_stall})
`ifdef CCV_TRACE
    , .src_tid({b_miu_ooe_cmpl_s3_tid, b_miu_ooe_cmpl_s2_tid, b_miu_ooe_cmpl_s1_tid, b_miu_ooe_cmpl_s0_tid}), .dst_tid({miu_ooe_cmpl_s3_tid, miu_ooe_cmpl_s2_tid, miu_ooe_cmpl_s1_tid, miu_ooe_cmpl_s0_tid})
`endif
  );
  // ccv_ooe_miu_retire, destination end
  ccv_seq_rpt #(.STAGES(RPT_OOE_MIU_RETIRE), .SLOTS(4), .PAYLOAD_W(8)) u_rpt_ooe_miu_retire (
    .clk(core_clk), .rst_n(rst_n),
    .src_valid({ooe_miu_retire_s3_valid, ooe_miu_retire_s2_valid, ooe_miu_retire_s1_valid, ooe_miu_retire_s0_valid}), .src_payload({ooe_miu_retire_s3_payload, ooe_miu_retire_s2_payload, ooe_miu_retire_s1_payload, ooe_miu_retire_s0_payload}),
    .src_wake(ooe_miu_retire_wake), .src_credit({ooe_miu_retire_s3_credit, ooe_miu_retire_s2_credit, ooe_miu_retire_s1_credit, ooe_miu_retire_s0_credit}), .src_stall({ooe_miu_retire_s3_stall, ooe_miu_retire_s2_stall, ooe_miu_retire_s1_stall, ooe_miu_retire_s0_stall}),
    .dst_valid({b_ooe_miu_retire_s3_valid, b_ooe_miu_retire_s2_valid, b_ooe_miu_retire_s1_valid, b_ooe_miu_retire_s0_valid}), .dst_payload({b_ooe_miu_retire_s3_payload, b_ooe_miu_retire_s2_payload, b_ooe_miu_retire_s1_payload, b_ooe_miu_retire_s0_payload}),
    .dst_wake(b_ooe_miu_retire_wake), .dst_credit({b_ooe_miu_retire_s3_credit, b_ooe_miu_retire_s2_credit, b_ooe_miu_retire_s1_credit, b_ooe_miu_retire_s0_credit}), .dst_stall({b_ooe_miu_retire_s3_stall, b_ooe_miu_retire_s2_stall, b_ooe_miu_retire_s1_stall, b_ooe_miu_retire_s0_stall})
`ifdef CCV_TRACE
    , .src_tid({ooe_miu_retire_s3_tid, ooe_miu_retire_s2_tid, ooe_miu_retire_s1_tid, ooe_miu_retire_s0_tid}), .dst_tid({b_ooe_miu_retire_s3_tid, b_ooe_miu_retire_s2_tid, b_ooe_miu_retire_s1_tid, b_ooe_miu_retire_s0_tid})
`endif
  );
  // ccv_miu_spm_req, source end
  ccv_seq_rpt #(.STAGES(RPT_MIU_SPM_REQ), .SLOTS(4), .PAYLOAD_W(1477)) u_rpt_miu_spm_req (
    .clk(core_clk), .rst_n(rst_n),
    .src_valid({b_miu_spm_req_s3_valid, b_miu_spm_req_s2_valid, b_miu_spm_req_s1_valid, b_miu_spm_req_s0_valid}), .src_payload({b_miu_spm_req_s3_payload, b_miu_spm_req_s2_payload, b_miu_spm_req_s1_payload, b_miu_spm_req_s0_payload}),
    .src_wake(b_miu_spm_req_wake), .src_credit({b_miu_spm_req_s3_credit, b_miu_spm_req_s2_credit, b_miu_spm_req_s1_credit, b_miu_spm_req_s0_credit}), .src_stall({b_miu_spm_req_s3_stall, b_miu_spm_req_s2_stall, b_miu_spm_req_s1_stall, b_miu_spm_req_s0_stall}),
    .dst_valid({miu_spm_req_s3_valid, miu_spm_req_s2_valid, miu_spm_req_s1_valid, miu_spm_req_s0_valid}), .dst_payload({miu_spm_req_s3_payload, miu_spm_req_s2_payload, miu_spm_req_s1_payload, miu_spm_req_s0_payload}),
    .dst_wake(miu_spm_req_wake), .dst_credit({miu_spm_req_s3_credit, miu_spm_req_s2_credit, miu_spm_req_s1_credit, miu_spm_req_s0_credit}), .dst_stall({miu_spm_req_s3_stall, miu_spm_req_s2_stall, miu_spm_req_s1_stall, miu_spm_req_s0_stall})
`ifdef CCV_TRACE
    , .src_tid({b_miu_spm_req_s3_tid, b_miu_spm_req_s2_tid, b_miu_spm_req_s1_tid, b_miu_spm_req_s0_tid}), .dst_tid({miu_spm_req_s3_tid, miu_spm_req_s2_tid, miu_spm_req_s1_tid, miu_spm_req_s0_tid})
`endif
  );
  // ccv_spm_miu_rsp, destination end
  ccv_seq_rpt #(.STAGES(RPT_SPM_MIU_RSP), .SLOTS(4), .PAYLOAD_W(1033)) u_rpt_spm_miu_rsp (
    .clk(core_clk), .rst_n(rst_n),
    .src_valid({spm_miu_rsp_s3_valid, spm_miu_rsp_s2_valid, spm_miu_rsp_s1_valid, spm_miu_rsp_s0_valid}), .src_payload({spm_miu_rsp_s3_payload, spm_miu_rsp_s2_payload, spm_miu_rsp_s1_payload, spm_miu_rsp_s0_payload}),
    .src_wake(spm_miu_rsp_wake), .src_credit({spm_miu_rsp_s3_credit, spm_miu_rsp_s2_credit, spm_miu_rsp_s1_credit, spm_miu_rsp_s0_credit}), .src_stall({spm_miu_rsp_s3_stall, spm_miu_rsp_s2_stall, spm_miu_rsp_s1_stall, spm_miu_rsp_s0_stall}),
    .dst_valid({b_spm_miu_rsp_s3_valid, b_spm_miu_rsp_s2_valid, b_spm_miu_rsp_s1_valid, b_spm_miu_rsp_s0_valid}), .dst_payload({b_spm_miu_rsp_s3_payload, b_spm_miu_rsp_s2_payload, b_spm_miu_rsp_s1_payload, b_spm_miu_rsp_s0_payload}),
    .dst_wake(b_spm_miu_rsp_wake), .dst_credit({b_spm_miu_rsp_s3_credit, b_spm_miu_rsp_s2_credit, b_spm_miu_rsp_s1_credit, b_spm_miu_rsp_s0_credit}), .dst_stall({b_spm_miu_rsp_s3_stall, b_spm_miu_rsp_s2_stall, b_spm_miu_rsp_s1_stall, b_spm_miu_rsp_s0_stall})
`ifdef CCV_TRACE
    , .src_tid({spm_miu_rsp_s3_tid, spm_miu_rsp_s2_tid, spm_miu_rsp_s1_tid, spm_miu_rsp_s0_tid}), .dst_tid({b_spm_miu_rsp_s3_tid, b_spm_miu_rsp_s2_tid, b_spm_miu_rsp_s1_tid, b_spm_miu_rsp_s0_tid})
`endif
  );
  // ccv_miu_dcu_req, source end
  ccv_seq_rpt #(.STAGES(RPT_MIU_DCU_REQ), .SLOTS(4), .PAYLOAD_W(1212)) u_rpt_miu_dcu_req (
    .clk(core_clk), .rst_n(rst_n),
    .src_valid({b_miu_dcu_req_s3_valid, b_miu_dcu_req_s2_valid, b_miu_dcu_req_s1_valid, b_miu_dcu_req_s0_valid}), .src_payload({b_miu_dcu_req_s3_payload, b_miu_dcu_req_s2_payload, b_miu_dcu_req_s1_payload, b_miu_dcu_req_s0_payload}),
    .src_wake(b_miu_dcu_req_wake), .src_credit({b_miu_dcu_req_s3_credit, b_miu_dcu_req_s2_credit, b_miu_dcu_req_s1_credit, b_miu_dcu_req_s0_credit}), .src_stall({b_miu_dcu_req_s3_stall, b_miu_dcu_req_s2_stall, b_miu_dcu_req_s1_stall, b_miu_dcu_req_s0_stall}),
    .dst_valid({miu_dcu_req_s3_valid, miu_dcu_req_s2_valid, miu_dcu_req_s1_valid, miu_dcu_req_s0_valid}), .dst_payload({miu_dcu_req_s3_payload, miu_dcu_req_s2_payload, miu_dcu_req_s1_payload, miu_dcu_req_s0_payload}),
    .dst_wake(miu_dcu_req_wake), .dst_credit({miu_dcu_req_s3_credit, miu_dcu_req_s2_credit, miu_dcu_req_s1_credit, miu_dcu_req_s0_credit}), .dst_stall({miu_dcu_req_s3_stall, miu_dcu_req_s2_stall, miu_dcu_req_s1_stall, miu_dcu_req_s0_stall})
`ifdef CCV_TRACE
    , .src_tid({b_miu_dcu_req_s3_tid, b_miu_dcu_req_s2_tid, b_miu_dcu_req_s1_tid, b_miu_dcu_req_s0_tid}), .dst_tid({miu_dcu_req_s3_tid, miu_dcu_req_s2_tid, miu_dcu_req_s1_tid, miu_dcu_req_s0_tid})
`endif
  );
  // ccv_dcu_miu_rsp, destination end
  ccv_seq_rpt #(.STAGES(RPT_DCU_MIU_RSP), .SLOTS(4), .PAYLOAD_W(1030)) u_rpt_dcu_miu_rsp (
    .clk(core_clk), .rst_n(rst_n),
    .src_valid({dcu_miu_rsp_s3_valid, dcu_miu_rsp_s2_valid, dcu_miu_rsp_s1_valid, dcu_miu_rsp_s0_valid}), .src_payload({dcu_miu_rsp_s3_payload, dcu_miu_rsp_s2_payload, dcu_miu_rsp_s1_payload, dcu_miu_rsp_s0_payload}),
    .src_wake(dcu_miu_rsp_wake), .src_credit({dcu_miu_rsp_s3_credit, dcu_miu_rsp_s2_credit, dcu_miu_rsp_s1_credit, dcu_miu_rsp_s0_credit}), .src_stall({dcu_miu_rsp_s3_stall, dcu_miu_rsp_s2_stall, dcu_miu_rsp_s1_stall, dcu_miu_rsp_s0_stall}),
    .dst_valid({b_dcu_miu_rsp_s3_valid, b_dcu_miu_rsp_s2_valid, b_dcu_miu_rsp_s1_valid, b_dcu_miu_rsp_s0_valid}), .dst_payload({b_dcu_miu_rsp_s3_payload, b_dcu_miu_rsp_s2_payload, b_dcu_miu_rsp_s1_payload, b_dcu_miu_rsp_s0_payload}),
    .dst_wake(b_dcu_miu_rsp_wake), .dst_credit({b_dcu_miu_rsp_s3_credit, b_dcu_miu_rsp_s2_credit, b_dcu_miu_rsp_s1_credit, b_dcu_miu_rsp_s0_credit}), .dst_stall({b_dcu_miu_rsp_s3_stall, b_dcu_miu_rsp_s2_stall, b_dcu_miu_rsp_s1_stall, b_dcu_miu_rsp_s0_stall})
`ifdef CCV_TRACE
    , .src_tid({dcu_miu_rsp_s3_tid, dcu_miu_rsp_s2_tid, dcu_miu_rsp_s1_tid, dcu_miu_rsp_s0_tid}), .dst_tid({b_dcu_miu_rsp_s3_tid, b_dcu_miu_rsp_s2_tid, b_dcu_miu_rsp_s1_tid, b_dcu_miu_rsp_s0_tid})
`endif
  );
  // ccv_miu_fet_itlb, source end
  ccv_seq_rpt #(.STAGES(RPT_MIU_FET_ITLB), .SLOTS(1), .PAYLOAD_W(64)) u_rpt_miu_fet_itlb (
    .clk(core_clk), .rst_n(rst_n),
    .src_valid({b_miu_fet_itlb_valid}), .src_payload({b_miu_fet_itlb_payload}),
    .src_wake(b_miu_fet_itlb_wake), .src_credit({b_miu_fet_itlb_credit}), .src_stall({b_miu_fet_itlb_stall}),
    .dst_valid({miu_fet_itlb_valid}), .dst_payload({miu_fet_itlb_payload}),
    .dst_wake(miu_fet_itlb_wake), .dst_credit({miu_fet_itlb_credit}), .dst_stall({miu_fet_itlb_stall})
`ifdef CCV_TRACE
    , .src_tid({b_miu_fet_itlb_tid}), .dst_tid({miu_fet_itlb_tid})
`endif
  );
  // ccv_fet_miu_itlb_req, destination end
  ccv_seq_rpt #(.STAGES(RPT_FET_MIU_ITLB_REQ), .SLOTS(1), .PAYLOAD_W(72)) u_rpt_fet_miu_itlb_req (
    .clk(core_clk), .rst_n(rst_n),
    .src_valid({fet_miu_itlb_req_valid}), .src_payload({fet_miu_itlb_req_payload}),
    .src_wake(fet_miu_itlb_req_wake), .src_credit({fet_miu_itlb_req_credit}), .src_stall({fet_miu_itlb_req_stall}),
    .dst_valid({b_fet_miu_itlb_req_valid}), .dst_payload({b_fet_miu_itlb_req_payload}),
    .dst_wake(b_fet_miu_itlb_req_wake), .dst_credit({b_fet_miu_itlb_req_credit}), .dst_stall({b_fet_miu_itlb_req_stall})
`ifdef CCV_TRACE
    , .src_tid({fet_miu_itlb_req_tid}), .dst_tid({b_fet_miu_itlb_req_tid})
`endif
  );
  // ccv_rau_miu_cta, destination end
  ccv_seq_rpt #(.STAGES(RPT_RAU_MIU_CTA), .SLOTS(1), .PAYLOAD_W(101)) u_rpt_rau_miu_cta (
    .clk(core_clk), .rst_n(rst_n),
    .src_valid({rau_miu_cta_valid}), .src_payload({rau_miu_cta_payload}),
    .src_wake(rau_miu_cta_wake), .src_credit({rau_miu_cta_credit}), .src_stall({rau_miu_cta_stall}),
    .dst_valid({b_rau_miu_cta_valid}), .dst_payload({b_rau_miu_cta_payload}),
    .dst_wake(b_rau_miu_cta_wake), .dst_credit({b_rau_miu_cta_credit}), .dst_stall({b_rau_miu_cta_stall})
`ifdef CCV_TRACE
    , .src_tid({rau_miu_cta_tid}), .dst_tid({b_rau_miu_cta_tid})
`endif
  );
endmodule
