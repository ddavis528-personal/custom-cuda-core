// GENERATED FILE -- DO NOT EDIT.
//
// Produced by tools/gen-top.py from schema/interfaces.json and
// params/blocks.json. Edit a source and regenerate; tools/verify.sh fails if
// this file is stale.

// HARDENING WRAPPER ccv_ooe_w: ccv_ooe and the sequential repeaters of its
// channel ends -- the physical hierarchy (docs/physical.md, "Wrappers
// and links"). Nothing but instances and nets, like the top. An end
// whose link has no stages here is connected straight through.
// Each end's stages are a parameter the top sets from params/links.json;
// at 0 the end is wired straight through, with no repeater.
`include "ccv_interfaces.svh"

module ccv_ooe_w #(
  parameter int RPT_DEC_OOE_UOP = 0,
  parameter int RPT_OOE_RCU_ISSUE = 0,
  parameter int RPT_RCU_OOE_DONE = 0,
  parameter int RPT_OOE_MIU_MEMOP = 0,
  parameter int RPT_MIU_OOE_CMPL = 0,
  parameter int RPT_OOE_MIU_RETIRE = 0,
  parameter int RPT_OOE_FET_REDIRECT = 0,
  parameter int RPT_OOE_FET_CKPT_FREE = 0,
  parameter int RPT_RAU_OOE_ALLOC = 0,
  parameter int RPT_OOE_RAU_STATUS = 0,
  parameter int RPT_RAU_OOE_DEMOTE = 0,
  parameter int RPT_OOE_RAU_DRAINED = 0,
  parameter int RPT_OOE_RCU_MAP = 0,
  parameter int RPT_OOE_SYU_BAR = 0,
  parameter int RPT_SYU_OOE_REL = 0,
  parameter int RPT_OOE_CRU_FAULT = 0
) (
  `include "ccv_ooe_ports.svh"
);

  // Between the block and its repeaters: b_<port>, one net per port.
  logic b_dec_ooe_uop_s0_valid;
  ccv_dec_ooe_uop_t b_dec_ooe_uop_s0_payload;
  logic b_dec_ooe_uop_s0_credit;
  logic b_dec_ooe_uop_s0_stall;
  logic b_dec_ooe_uop_s1_valid;
  ccv_dec_ooe_uop_t b_dec_ooe_uop_s1_payload;
  logic b_dec_ooe_uop_s1_credit;
  logic b_dec_ooe_uop_s1_stall;
  logic b_dec_ooe_uop_s2_valid;
  ccv_dec_ooe_uop_t b_dec_ooe_uop_s2_payload;
  logic b_dec_ooe_uop_s2_credit;
  logic b_dec_ooe_uop_s2_stall;
  logic b_dec_ooe_uop_s3_valid;
  ccv_dec_ooe_uop_t b_dec_ooe_uop_s3_payload;
  logic b_dec_ooe_uop_s3_credit;
  logic b_dec_ooe_uop_s3_stall;
  logic b_dec_ooe_uop_s4_valid;
  ccv_dec_ooe_uop_t b_dec_ooe_uop_s4_payload;
  logic b_dec_ooe_uop_s4_credit;
  logic b_dec_ooe_uop_s4_stall;
  logic b_dec_ooe_uop_s5_valid;
  ccv_dec_ooe_uop_t b_dec_ooe_uop_s5_payload;
  logic b_dec_ooe_uop_s5_credit;
  logic b_dec_ooe_uop_s5_stall;
  logic b_dec_ooe_uop_wake;
  logic b_ooe_rcu_issue_s0_valid;
  ccv_ooe_rcu_issue_t b_ooe_rcu_issue_s0_payload;
  logic b_ooe_rcu_issue_s0_credit;
  logic b_ooe_rcu_issue_s0_stall;
  logic b_ooe_rcu_issue_s1_valid;
  ccv_ooe_rcu_issue_t b_ooe_rcu_issue_s1_payload;
  logic b_ooe_rcu_issue_s1_credit;
  logic b_ooe_rcu_issue_s1_stall;
  logic b_ooe_rcu_issue_s2_valid;
  ccv_ooe_rcu_issue_t b_ooe_rcu_issue_s2_payload;
  logic b_ooe_rcu_issue_s2_credit;
  logic b_ooe_rcu_issue_s2_stall;
  logic b_ooe_rcu_issue_s3_valid;
  ccv_ooe_rcu_issue_t b_ooe_rcu_issue_s3_payload;
  logic b_ooe_rcu_issue_s3_credit;
  logic b_ooe_rcu_issue_s3_stall;
  logic b_ooe_rcu_issue_s4_valid;
  ccv_ooe_rcu_issue_t b_ooe_rcu_issue_s4_payload;
  logic b_ooe_rcu_issue_s4_credit;
  logic b_ooe_rcu_issue_s4_stall;
  logic b_ooe_rcu_issue_s5_valid;
  ccv_ooe_rcu_issue_t b_ooe_rcu_issue_s5_payload;
  logic b_ooe_rcu_issue_s5_credit;
  logic b_ooe_rcu_issue_s5_stall;
  logic b_ooe_rcu_issue_s6_valid;
  ccv_ooe_rcu_issue_t b_ooe_rcu_issue_s6_payload;
  logic b_ooe_rcu_issue_s6_credit;
  logic b_ooe_rcu_issue_s6_stall;
  logic b_ooe_rcu_issue_s7_valid;
  ccv_ooe_rcu_issue_t b_ooe_rcu_issue_s7_payload;
  logic b_ooe_rcu_issue_s7_credit;
  logic b_ooe_rcu_issue_s7_stall;
  logic b_ooe_rcu_issue_s8_valid;
  ccv_ooe_rcu_issue_t b_ooe_rcu_issue_s8_payload;
  logic b_ooe_rcu_issue_s8_credit;
  logic b_ooe_rcu_issue_s8_stall;
  logic b_ooe_rcu_issue_wake;
  logic b_rcu_ooe_done_s0_valid;
  ccv_rcu_ooe_done_t b_rcu_ooe_done_s0_payload;
  logic b_rcu_ooe_done_s0_credit;
  logic b_rcu_ooe_done_s0_stall;
  logic b_rcu_ooe_done_s1_valid;
  ccv_rcu_ooe_done_t b_rcu_ooe_done_s1_payload;
  logic b_rcu_ooe_done_s1_credit;
  logic b_rcu_ooe_done_s1_stall;
  logic b_rcu_ooe_done_s2_valid;
  ccv_rcu_ooe_done_t b_rcu_ooe_done_s2_payload;
  logic b_rcu_ooe_done_s2_credit;
  logic b_rcu_ooe_done_s2_stall;
  logic b_rcu_ooe_done_s3_valid;
  ccv_rcu_ooe_done_t b_rcu_ooe_done_s3_payload;
  logic b_rcu_ooe_done_s3_credit;
  logic b_rcu_ooe_done_s3_stall;
  logic b_rcu_ooe_done_s4_valid;
  ccv_rcu_ooe_done_t b_rcu_ooe_done_s4_payload;
  logic b_rcu_ooe_done_s4_credit;
  logic b_rcu_ooe_done_s4_stall;
  logic b_rcu_ooe_done_s5_valid;
  ccv_rcu_ooe_done_t b_rcu_ooe_done_s5_payload;
  logic b_rcu_ooe_done_s5_credit;
  logic b_rcu_ooe_done_s5_stall;
  logic b_rcu_ooe_done_s6_valid;
  ccv_rcu_ooe_done_t b_rcu_ooe_done_s6_payload;
  logic b_rcu_ooe_done_s6_credit;
  logic b_rcu_ooe_done_s6_stall;
  logic b_rcu_ooe_done_wake;
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
  logic b_ooe_fet_redirect_valid;
  ccv_ooe_fet_redirect_t b_ooe_fet_redirect_payload;
  logic b_ooe_fet_redirect_credit;
  logic b_ooe_fet_redirect_stall;
  logic b_ooe_fet_redirect_wake;
  logic b_ooe_fet_ckpt_free_valid;
  ccv_ooe_fet_ckpt_free_t b_ooe_fet_ckpt_free_payload;
  logic b_ooe_fet_ckpt_free_credit;
  logic b_ooe_fet_ckpt_free_stall;
  logic b_ooe_fet_ckpt_free_wake;
  logic b_rau_ooe_alloc_valid;
  ccv_rau_ooe_alloc_t b_rau_ooe_alloc_payload;
  logic b_rau_ooe_alloc_credit;
  logic b_rau_ooe_alloc_stall;
  logic b_rau_ooe_alloc_wake;
  logic b_ooe_rau_status_valid;
  ccv_ooe_rau_status_t b_ooe_rau_status_payload;
  logic b_ooe_rau_status_credit;
  logic b_ooe_rau_status_stall;
  logic b_ooe_rau_status_wake;
  logic b_rau_ooe_demote_valid;
  ccv_rau_ooe_demote_t b_rau_ooe_demote_payload;
  logic b_rau_ooe_demote_credit;
  logic b_rau_ooe_demote_stall;
  logic b_rau_ooe_demote_wake;
  logic b_ooe_rau_drained_valid;
  ccv_ooe_rau_drained_t b_ooe_rau_drained_payload;
  logic b_ooe_rau_drained_credit;
  logic b_ooe_rau_drained_stall;
  logic b_ooe_rau_drained_wake;
  logic b_ooe_rcu_map_valid;
  ccv_ooe_rcu_map_t b_ooe_rcu_map_payload;
  logic b_ooe_rcu_map_credit;
  logic b_ooe_rcu_map_stall;
  logic b_ooe_rcu_map_wake;
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
  logic b_ooe_cru_fault_valid;
  ccv_ooe_cru_fault_t b_ooe_cru_fault_payload;
  logic b_ooe_cru_fault_credit;
  logic b_ooe_cru_fault_stall;
  logic b_ooe_cru_fault_wake;
`ifdef CCV_TRACE
  logic [63:0] b_dec_ooe_uop_s0_tid;
  logic [63:0] b_dec_ooe_uop_s1_tid;
  logic [63:0] b_dec_ooe_uop_s2_tid;
  logic [63:0] b_dec_ooe_uop_s3_tid;
  logic [63:0] b_dec_ooe_uop_s4_tid;
  logic [63:0] b_dec_ooe_uop_s5_tid;
  logic [63:0] b_ooe_rcu_issue_s0_tid;
  logic [63:0] b_ooe_rcu_issue_s1_tid;
  logic [63:0] b_ooe_rcu_issue_s2_tid;
  logic [63:0] b_ooe_rcu_issue_s3_tid;
  logic [63:0] b_ooe_rcu_issue_s4_tid;
  logic [63:0] b_ooe_rcu_issue_s5_tid;
  logic [63:0] b_ooe_rcu_issue_s6_tid;
  logic [63:0] b_ooe_rcu_issue_s7_tid;
  logic [63:0] b_ooe_rcu_issue_s8_tid;
  logic [63:0] b_rcu_ooe_done_s0_tid;
  logic [63:0] b_rcu_ooe_done_s1_tid;
  logic [63:0] b_rcu_ooe_done_s2_tid;
  logic [63:0] b_rcu_ooe_done_s3_tid;
  logic [63:0] b_rcu_ooe_done_s4_tid;
  logic [63:0] b_rcu_ooe_done_s5_tid;
  logic [63:0] b_rcu_ooe_done_s6_tid;
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
  logic [63:0] b_ooe_fet_redirect_tid;
  logic [63:0] b_ooe_fet_ckpt_free_tid;
  logic [63:0] b_rau_ooe_alloc_tid;
  logic [63:0] b_ooe_rau_status_tid;
  logic [63:0] b_rau_ooe_demote_tid;
  logic [63:0] b_ooe_rau_drained_tid;
  logic [63:0] b_ooe_rcu_map_tid;
  logic [63:0] b_ooe_syu_bar_tid;
  logic [63:0] b_syu_ooe_rel_tid;
  logic [63:0] b_ooe_cru_fault_tid;
`endif

  ccv_ooe u_blk (
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
    .dec_ooe_uop_s0_valid(b_dec_ooe_uop_s0_valid),
    .dec_ooe_uop_s0_payload(b_dec_ooe_uop_s0_payload),
    .dec_ooe_uop_s0_credit(b_dec_ooe_uop_s0_credit),
    .dec_ooe_uop_s0_stall(b_dec_ooe_uop_s0_stall),
    .dec_ooe_uop_s1_valid(b_dec_ooe_uop_s1_valid),
    .dec_ooe_uop_s1_payload(b_dec_ooe_uop_s1_payload),
    .dec_ooe_uop_s1_credit(b_dec_ooe_uop_s1_credit),
    .dec_ooe_uop_s1_stall(b_dec_ooe_uop_s1_stall),
    .dec_ooe_uop_s2_valid(b_dec_ooe_uop_s2_valid),
    .dec_ooe_uop_s2_payload(b_dec_ooe_uop_s2_payload),
    .dec_ooe_uop_s2_credit(b_dec_ooe_uop_s2_credit),
    .dec_ooe_uop_s2_stall(b_dec_ooe_uop_s2_stall),
    .dec_ooe_uop_s3_valid(b_dec_ooe_uop_s3_valid),
    .dec_ooe_uop_s3_payload(b_dec_ooe_uop_s3_payload),
    .dec_ooe_uop_s3_credit(b_dec_ooe_uop_s3_credit),
    .dec_ooe_uop_s3_stall(b_dec_ooe_uop_s3_stall),
    .dec_ooe_uop_s4_valid(b_dec_ooe_uop_s4_valid),
    .dec_ooe_uop_s4_payload(b_dec_ooe_uop_s4_payload),
    .dec_ooe_uop_s4_credit(b_dec_ooe_uop_s4_credit),
    .dec_ooe_uop_s4_stall(b_dec_ooe_uop_s4_stall),
    .dec_ooe_uop_s5_valid(b_dec_ooe_uop_s5_valid),
    .dec_ooe_uop_s5_payload(b_dec_ooe_uop_s5_payload),
    .dec_ooe_uop_s5_credit(b_dec_ooe_uop_s5_credit),
    .dec_ooe_uop_s5_stall(b_dec_ooe_uop_s5_stall),
    .dec_ooe_uop_wake(b_dec_ooe_uop_wake),
    .ooe_rcu_issue_s0_valid(b_ooe_rcu_issue_s0_valid),
    .ooe_rcu_issue_s0_payload(b_ooe_rcu_issue_s0_payload),
    .ooe_rcu_issue_s0_credit(b_ooe_rcu_issue_s0_credit),
    .ooe_rcu_issue_s0_stall(b_ooe_rcu_issue_s0_stall),
    .ooe_rcu_issue_s1_valid(b_ooe_rcu_issue_s1_valid),
    .ooe_rcu_issue_s1_payload(b_ooe_rcu_issue_s1_payload),
    .ooe_rcu_issue_s1_credit(b_ooe_rcu_issue_s1_credit),
    .ooe_rcu_issue_s1_stall(b_ooe_rcu_issue_s1_stall),
    .ooe_rcu_issue_s2_valid(b_ooe_rcu_issue_s2_valid),
    .ooe_rcu_issue_s2_payload(b_ooe_rcu_issue_s2_payload),
    .ooe_rcu_issue_s2_credit(b_ooe_rcu_issue_s2_credit),
    .ooe_rcu_issue_s2_stall(b_ooe_rcu_issue_s2_stall),
    .ooe_rcu_issue_s3_valid(b_ooe_rcu_issue_s3_valid),
    .ooe_rcu_issue_s3_payload(b_ooe_rcu_issue_s3_payload),
    .ooe_rcu_issue_s3_credit(b_ooe_rcu_issue_s3_credit),
    .ooe_rcu_issue_s3_stall(b_ooe_rcu_issue_s3_stall),
    .ooe_rcu_issue_s4_valid(b_ooe_rcu_issue_s4_valid),
    .ooe_rcu_issue_s4_payload(b_ooe_rcu_issue_s4_payload),
    .ooe_rcu_issue_s4_credit(b_ooe_rcu_issue_s4_credit),
    .ooe_rcu_issue_s4_stall(b_ooe_rcu_issue_s4_stall),
    .ooe_rcu_issue_s5_valid(b_ooe_rcu_issue_s5_valid),
    .ooe_rcu_issue_s5_payload(b_ooe_rcu_issue_s5_payload),
    .ooe_rcu_issue_s5_credit(b_ooe_rcu_issue_s5_credit),
    .ooe_rcu_issue_s5_stall(b_ooe_rcu_issue_s5_stall),
    .ooe_rcu_issue_s6_valid(b_ooe_rcu_issue_s6_valid),
    .ooe_rcu_issue_s6_payload(b_ooe_rcu_issue_s6_payload),
    .ooe_rcu_issue_s6_credit(b_ooe_rcu_issue_s6_credit),
    .ooe_rcu_issue_s6_stall(b_ooe_rcu_issue_s6_stall),
    .ooe_rcu_issue_s7_valid(b_ooe_rcu_issue_s7_valid),
    .ooe_rcu_issue_s7_payload(b_ooe_rcu_issue_s7_payload),
    .ooe_rcu_issue_s7_credit(b_ooe_rcu_issue_s7_credit),
    .ooe_rcu_issue_s7_stall(b_ooe_rcu_issue_s7_stall),
    .ooe_rcu_issue_s8_valid(b_ooe_rcu_issue_s8_valid),
    .ooe_rcu_issue_s8_payload(b_ooe_rcu_issue_s8_payload),
    .ooe_rcu_issue_s8_credit(b_ooe_rcu_issue_s8_credit),
    .ooe_rcu_issue_s8_stall(b_ooe_rcu_issue_s8_stall),
    .ooe_rcu_issue_wake(b_ooe_rcu_issue_wake),
    .rcu_ooe_done_s0_valid(b_rcu_ooe_done_s0_valid),
    .rcu_ooe_done_s0_payload(b_rcu_ooe_done_s0_payload),
    .rcu_ooe_done_s0_credit(b_rcu_ooe_done_s0_credit),
    .rcu_ooe_done_s0_stall(b_rcu_ooe_done_s0_stall),
    .rcu_ooe_done_s1_valid(b_rcu_ooe_done_s1_valid),
    .rcu_ooe_done_s1_payload(b_rcu_ooe_done_s1_payload),
    .rcu_ooe_done_s1_credit(b_rcu_ooe_done_s1_credit),
    .rcu_ooe_done_s1_stall(b_rcu_ooe_done_s1_stall),
    .rcu_ooe_done_s2_valid(b_rcu_ooe_done_s2_valid),
    .rcu_ooe_done_s2_payload(b_rcu_ooe_done_s2_payload),
    .rcu_ooe_done_s2_credit(b_rcu_ooe_done_s2_credit),
    .rcu_ooe_done_s2_stall(b_rcu_ooe_done_s2_stall),
    .rcu_ooe_done_s3_valid(b_rcu_ooe_done_s3_valid),
    .rcu_ooe_done_s3_payload(b_rcu_ooe_done_s3_payload),
    .rcu_ooe_done_s3_credit(b_rcu_ooe_done_s3_credit),
    .rcu_ooe_done_s3_stall(b_rcu_ooe_done_s3_stall),
    .rcu_ooe_done_s4_valid(b_rcu_ooe_done_s4_valid),
    .rcu_ooe_done_s4_payload(b_rcu_ooe_done_s4_payload),
    .rcu_ooe_done_s4_credit(b_rcu_ooe_done_s4_credit),
    .rcu_ooe_done_s4_stall(b_rcu_ooe_done_s4_stall),
    .rcu_ooe_done_s5_valid(b_rcu_ooe_done_s5_valid),
    .rcu_ooe_done_s5_payload(b_rcu_ooe_done_s5_payload),
    .rcu_ooe_done_s5_credit(b_rcu_ooe_done_s5_credit),
    .rcu_ooe_done_s5_stall(b_rcu_ooe_done_s5_stall),
    .rcu_ooe_done_s6_valid(b_rcu_ooe_done_s6_valid),
    .rcu_ooe_done_s6_payload(b_rcu_ooe_done_s6_payload),
    .rcu_ooe_done_s6_credit(b_rcu_ooe_done_s6_credit),
    .rcu_ooe_done_s6_stall(b_rcu_ooe_done_s6_stall),
    .rcu_ooe_done_wake(b_rcu_ooe_done_wake),
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
    .ooe_fet_redirect_valid(b_ooe_fet_redirect_valid),
    .ooe_fet_redirect_payload(b_ooe_fet_redirect_payload),
    .ooe_fet_redirect_credit(b_ooe_fet_redirect_credit),
    .ooe_fet_redirect_stall(b_ooe_fet_redirect_stall),
    .ooe_fet_redirect_wake(b_ooe_fet_redirect_wake),
    .ooe_fet_ckpt_free_valid(b_ooe_fet_ckpt_free_valid),
    .ooe_fet_ckpt_free_payload(b_ooe_fet_ckpt_free_payload),
    .ooe_fet_ckpt_free_credit(b_ooe_fet_ckpt_free_credit),
    .ooe_fet_ckpt_free_stall(b_ooe_fet_ckpt_free_stall),
    .ooe_fet_ckpt_free_wake(b_ooe_fet_ckpt_free_wake),
    .rau_ooe_alloc_valid(b_rau_ooe_alloc_valid),
    .rau_ooe_alloc_payload(b_rau_ooe_alloc_payload),
    .rau_ooe_alloc_credit(b_rau_ooe_alloc_credit),
    .rau_ooe_alloc_stall(b_rau_ooe_alloc_stall),
    .rau_ooe_alloc_wake(b_rau_ooe_alloc_wake),
    .ooe_rau_status_valid(b_ooe_rau_status_valid),
    .ooe_rau_status_payload(b_ooe_rau_status_payload),
    .ooe_rau_status_credit(b_ooe_rau_status_credit),
    .ooe_rau_status_stall(b_ooe_rau_status_stall),
    .ooe_rau_status_wake(b_ooe_rau_status_wake),
    .rau_ooe_demote_valid(b_rau_ooe_demote_valid),
    .rau_ooe_demote_payload(b_rau_ooe_demote_payload),
    .rau_ooe_demote_credit(b_rau_ooe_demote_credit),
    .rau_ooe_demote_stall(b_rau_ooe_demote_stall),
    .rau_ooe_demote_wake(b_rau_ooe_demote_wake),
    .ooe_rau_drained_valid(b_ooe_rau_drained_valid),
    .ooe_rau_drained_payload(b_ooe_rau_drained_payload),
    .ooe_rau_drained_credit(b_ooe_rau_drained_credit),
    .ooe_rau_drained_stall(b_ooe_rau_drained_stall),
    .ooe_rau_drained_wake(b_ooe_rau_drained_wake),
    .ooe_rcu_map_valid(b_ooe_rcu_map_valid),
    .ooe_rcu_map_payload(b_ooe_rcu_map_payload),
    .ooe_rcu_map_credit(b_ooe_rcu_map_credit),
    .ooe_rcu_map_stall(b_ooe_rcu_map_stall),
    .ooe_rcu_map_wake(b_ooe_rcu_map_wake),
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
    .ooe_cru_fault_valid(b_ooe_cru_fault_valid),
    .ooe_cru_fault_payload(b_ooe_cru_fault_payload),
    .ooe_cru_fault_credit(b_ooe_cru_fault_credit),
    .ooe_cru_fault_stall(b_ooe_cru_fault_stall),
    .ooe_cru_fault_wake(b_ooe_cru_fault_wake)
`ifdef CCV_CHECK
    , .clk_gated(clk_gated)
`endif
`ifdef CCV_TRACE
    , .dec_ooe_uop_s0_tid(b_dec_ooe_uop_s0_tid)
    , .dec_ooe_uop_s1_tid(b_dec_ooe_uop_s1_tid)
    , .dec_ooe_uop_s2_tid(b_dec_ooe_uop_s2_tid)
    , .dec_ooe_uop_s3_tid(b_dec_ooe_uop_s3_tid)
    , .dec_ooe_uop_s4_tid(b_dec_ooe_uop_s4_tid)
    , .dec_ooe_uop_s5_tid(b_dec_ooe_uop_s5_tid)
    , .ooe_rcu_issue_s0_tid(b_ooe_rcu_issue_s0_tid)
    , .ooe_rcu_issue_s1_tid(b_ooe_rcu_issue_s1_tid)
    , .ooe_rcu_issue_s2_tid(b_ooe_rcu_issue_s2_tid)
    , .ooe_rcu_issue_s3_tid(b_ooe_rcu_issue_s3_tid)
    , .ooe_rcu_issue_s4_tid(b_ooe_rcu_issue_s4_tid)
    , .ooe_rcu_issue_s5_tid(b_ooe_rcu_issue_s5_tid)
    , .ooe_rcu_issue_s6_tid(b_ooe_rcu_issue_s6_tid)
    , .ooe_rcu_issue_s7_tid(b_ooe_rcu_issue_s7_tid)
    , .ooe_rcu_issue_s8_tid(b_ooe_rcu_issue_s8_tid)
    , .rcu_ooe_done_s0_tid(b_rcu_ooe_done_s0_tid)
    , .rcu_ooe_done_s1_tid(b_rcu_ooe_done_s1_tid)
    , .rcu_ooe_done_s2_tid(b_rcu_ooe_done_s2_tid)
    , .rcu_ooe_done_s3_tid(b_rcu_ooe_done_s3_tid)
    , .rcu_ooe_done_s4_tid(b_rcu_ooe_done_s4_tid)
    , .rcu_ooe_done_s5_tid(b_rcu_ooe_done_s5_tid)
    , .rcu_ooe_done_s6_tid(b_rcu_ooe_done_s6_tid)
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
    , .ooe_fet_redirect_tid(b_ooe_fet_redirect_tid)
    , .ooe_fet_ckpt_free_tid(b_ooe_fet_ckpt_free_tid)
    , .rau_ooe_alloc_tid(b_rau_ooe_alloc_tid)
    , .ooe_rau_status_tid(b_ooe_rau_status_tid)
    , .rau_ooe_demote_tid(b_rau_ooe_demote_tid)
    , .ooe_rau_drained_tid(b_ooe_rau_drained_tid)
    , .ooe_rcu_map_tid(b_ooe_rcu_map_tid)
    , .ooe_syu_bar_tid(b_ooe_syu_bar_tid)
    , .syu_ooe_rel_tid(b_syu_ooe_rel_tid)
    , .ooe_cru_fault_tid(b_ooe_cru_fault_tid)
`endif
  );

  // ccv_dec_ooe_uop, destination end
  if (RPT_DEC_OOE_UOP > 0) begin : g_rpt_dec_ooe_uop
    ccv_common_rpt #(.STAGES(RPT_DEC_OOE_UOP), .SLOTS(6), .PAYLOAD_W(219)) u_rpt_dec_ooe_uop (
      .clk(core_clk), .rst_n(rst_n),
      .src_valid({dec_ooe_uop_s5_valid, dec_ooe_uop_s4_valid, dec_ooe_uop_s3_valid, dec_ooe_uop_s2_valid, dec_ooe_uop_s1_valid, dec_ooe_uop_s0_valid}), .src_payload({dec_ooe_uop_s5_payload, dec_ooe_uop_s4_payload, dec_ooe_uop_s3_payload, dec_ooe_uop_s2_payload, dec_ooe_uop_s1_payload, dec_ooe_uop_s0_payload}),
      .src_wake(dec_ooe_uop_wake), .src_credit({dec_ooe_uop_s5_credit, dec_ooe_uop_s4_credit, dec_ooe_uop_s3_credit, dec_ooe_uop_s2_credit, dec_ooe_uop_s1_credit, dec_ooe_uop_s0_credit}), .src_stall({dec_ooe_uop_s5_stall, dec_ooe_uop_s4_stall, dec_ooe_uop_s3_stall, dec_ooe_uop_s2_stall, dec_ooe_uop_s1_stall, dec_ooe_uop_s0_stall}),
      .dst_valid({b_dec_ooe_uop_s5_valid, b_dec_ooe_uop_s4_valid, b_dec_ooe_uop_s3_valid, b_dec_ooe_uop_s2_valid, b_dec_ooe_uop_s1_valid, b_dec_ooe_uop_s0_valid}), .dst_payload({b_dec_ooe_uop_s5_payload, b_dec_ooe_uop_s4_payload, b_dec_ooe_uop_s3_payload, b_dec_ooe_uop_s2_payload, b_dec_ooe_uop_s1_payload, b_dec_ooe_uop_s0_payload}),
      .dst_wake(b_dec_ooe_uop_wake), .dst_credit({b_dec_ooe_uop_s5_credit, b_dec_ooe_uop_s4_credit, b_dec_ooe_uop_s3_credit, b_dec_ooe_uop_s2_credit, b_dec_ooe_uop_s1_credit, b_dec_ooe_uop_s0_credit}), .dst_stall({b_dec_ooe_uop_s5_stall, b_dec_ooe_uop_s4_stall, b_dec_ooe_uop_s3_stall, b_dec_ooe_uop_s2_stall, b_dec_ooe_uop_s1_stall, b_dec_ooe_uop_s0_stall})
`ifdef CCV_TRACE
      , .src_tid({dec_ooe_uop_s5_tid, dec_ooe_uop_s4_tid, dec_ooe_uop_s3_tid, dec_ooe_uop_s2_tid, dec_ooe_uop_s1_tid, dec_ooe_uop_s0_tid}), .dst_tid({b_dec_ooe_uop_s5_tid, b_dec_ooe_uop_s4_tid, b_dec_ooe_uop_s3_tid, b_dec_ooe_uop_s2_tid, b_dec_ooe_uop_s1_tid, b_dec_ooe_uop_s0_tid})
`endif
    );
  end else begin : g_wire_dec_ooe_uop
    assign {b_dec_ooe_uop_s5_valid, b_dec_ooe_uop_s4_valid, b_dec_ooe_uop_s3_valid, b_dec_ooe_uop_s2_valid, b_dec_ooe_uop_s1_valid, b_dec_ooe_uop_s0_valid} = {dec_ooe_uop_s5_valid, dec_ooe_uop_s4_valid, dec_ooe_uop_s3_valid, dec_ooe_uop_s2_valid, dec_ooe_uop_s1_valid, dec_ooe_uop_s0_valid};
    assign {b_dec_ooe_uop_s5_payload, b_dec_ooe_uop_s4_payload, b_dec_ooe_uop_s3_payload, b_dec_ooe_uop_s2_payload, b_dec_ooe_uop_s1_payload, b_dec_ooe_uop_s0_payload} = {dec_ooe_uop_s5_payload, dec_ooe_uop_s4_payload, dec_ooe_uop_s3_payload, dec_ooe_uop_s2_payload, dec_ooe_uop_s1_payload, dec_ooe_uop_s0_payload};
    assign b_dec_ooe_uop_wake = dec_ooe_uop_wake;
    assign {dec_ooe_uop_s5_credit, dec_ooe_uop_s4_credit, dec_ooe_uop_s3_credit, dec_ooe_uop_s2_credit, dec_ooe_uop_s1_credit, dec_ooe_uop_s0_credit} = {b_dec_ooe_uop_s5_credit, b_dec_ooe_uop_s4_credit, b_dec_ooe_uop_s3_credit, b_dec_ooe_uop_s2_credit, b_dec_ooe_uop_s1_credit, b_dec_ooe_uop_s0_credit};
    assign {dec_ooe_uop_s5_stall, dec_ooe_uop_s4_stall, dec_ooe_uop_s3_stall, dec_ooe_uop_s2_stall, dec_ooe_uop_s1_stall, dec_ooe_uop_s0_stall} = {b_dec_ooe_uop_s5_stall, b_dec_ooe_uop_s4_stall, b_dec_ooe_uop_s3_stall, b_dec_ooe_uop_s2_stall, b_dec_ooe_uop_s1_stall, b_dec_ooe_uop_s0_stall};
`ifdef CCV_TRACE
    assign {b_dec_ooe_uop_s5_tid, b_dec_ooe_uop_s4_tid, b_dec_ooe_uop_s3_tid, b_dec_ooe_uop_s2_tid, b_dec_ooe_uop_s1_tid, b_dec_ooe_uop_s0_tid} = {dec_ooe_uop_s5_tid, dec_ooe_uop_s4_tid, dec_ooe_uop_s3_tid, dec_ooe_uop_s2_tid, dec_ooe_uop_s1_tid, dec_ooe_uop_s0_tid};
`endif
  end
  // ccv_ooe_rcu_issue, source end
  if (RPT_OOE_RCU_ISSUE > 0) begin : g_rpt_ooe_rcu_issue
    ccv_common_rpt #(.STAGES(RPT_OOE_RCU_ISSUE), .SLOTS(9), .PAYLOAD_W(175)) u_rpt_ooe_rcu_issue (
      .clk(core_clk), .rst_n(rst_n),
      .src_valid({b_ooe_rcu_issue_s8_valid, b_ooe_rcu_issue_s7_valid, b_ooe_rcu_issue_s6_valid, b_ooe_rcu_issue_s5_valid, b_ooe_rcu_issue_s4_valid, b_ooe_rcu_issue_s3_valid, b_ooe_rcu_issue_s2_valid, b_ooe_rcu_issue_s1_valid, b_ooe_rcu_issue_s0_valid}), .src_payload({b_ooe_rcu_issue_s8_payload, b_ooe_rcu_issue_s7_payload, b_ooe_rcu_issue_s6_payload, b_ooe_rcu_issue_s5_payload, b_ooe_rcu_issue_s4_payload, b_ooe_rcu_issue_s3_payload, b_ooe_rcu_issue_s2_payload, b_ooe_rcu_issue_s1_payload, b_ooe_rcu_issue_s0_payload}),
      .src_wake(b_ooe_rcu_issue_wake), .src_credit({b_ooe_rcu_issue_s8_credit, b_ooe_rcu_issue_s7_credit, b_ooe_rcu_issue_s6_credit, b_ooe_rcu_issue_s5_credit, b_ooe_rcu_issue_s4_credit, b_ooe_rcu_issue_s3_credit, b_ooe_rcu_issue_s2_credit, b_ooe_rcu_issue_s1_credit, b_ooe_rcu_issue_s0_credit}), .src_stall({b_ooe_rcu_issue_s8_stall, b_ooe_rcu_issue_s7_stall, b_ooe_rcu_issue_s6_stall, b_ooe_rcu_issue_s5_stall, b_ooe_rcu_issue_s4_stall, b_ooe_rcu_issue_s3_stall, b_ooe_rcu_issue_s2_stall, b_ooe_rcu_issue_s1_stall, b_ooe_rcu_issue_s0_stall}),
      .dst_valid({ooe_rcu_issue_s8_valid, ooe_rcu_issue_s7_valid, ooe_rcu_issue_s6_valid, ooe_rcu_issue_s5_valid, ooe_rcu_issue_s4_valid, ooe_rcu_issue_s3_valid, ooe_rcu_issue_s2_valid, ooe_rcu_issue_s1_valid, ooe_rcu_issue_s0_valid}), .dst_payload({ooe_rcu_issue_s8_payload, ooe_rcu_issue_s7_payload, ooe_rcu_issue_s6_payload, ooe_rcu_issue_s5_payload, ooe_rcu_issue_s4_payload, ooe_rcu_issue_s3_payload, ooe_rcu_issue_s2_payload, ooe_rcu_issue_s1_payload, ooe_rcu_issue_s0_payload}),
      .dst_wake(ooe_rcu_issue_wake), .dst_credit({ooe_rcu_issue_s8_credit, ooe_rcu_issue_s7_credit, ooe_rcu_issue_s6_credit, ooe_rcu_issue_s5_credit, ooe_rcu_issue_s4_credit, ooe_rcu_issue_s3_credit, ooe_rcu_issue_s2_credit, ooe_rcu_issue_s1_credit, ooe_rcu_issue_s0_credit}), .dst_stall({ooe_rcu_issue_s8_stall, ooe_rcu_issue_s7_stall, ooe_rcu_issue_s6_stall, ooe_rcu_issue_s5_stall, ooe_rcu_issue_s4_stall, ooe_rcu_issue_s3_stall, ooe_rcu_issue_s2_stall, ooe_rcu_issue_s1_stall, ooe_rcu_issue_s0_stall})
`ifdef CCV_TRACE
      , .src_tid({b_ooe_rcu_issue_s8_tid, b_ooe_rcu_issue_s7_tid, b_ooe_rcu_issue_s6_tid, b_ooe_rcu_issue_s5_tid, b_ooe_rcu_issue_s4_tid, b_ooe_rcu_issue_s3_tid, b_ooe_rcu_issue_s2_tid, b_ooe_rcu_issue_s1_tid, b_ooe_rcu_issue_s0_tid}), .dst_tid({ooe_rcu_issue_s8_tid, ooe_rcu_issue_s7_tid, ooe_rcu_issue_s6_tid, ooe_rcu_issue_s5_tid, ooe_rcu_issue_s4_tid, ooe_rcu_issue_s3_tid, ooe_rcu_issue_s2_tid, ooe_rcu_issue_s1_tid, ooe_rcu_issue_s0_tid})
`endif
    );
  end else begin : g_wire_ooe_rcu_issue
    assign {ooe_rcu_issue_s8_valid, ooe_rcu_issue_s7_valid, ooe_rcu_issue_s6_valid, ooe_rcu_issue_s5_valid, ooe_rcu_issue_s4_valid, ooe_rcu_issue_s3_valid, ooe_rcu_issue_s2_valid, ooe_rcu_issue_s1_valid, ooe_rcu_issue_s0_valid} = {b_ooe_rcu_issue_s8_valid, b_ooe_rcu_issue_s7_valid, b_ooe_rcu_issue_s6_valid, b_ooe_rcu_issue_s5_valid, b_ooe_rcu_issue_s4_valid, b_ooe_rcu_issue_s3_valid, b_ooe_rcu_issue_s2_valid, b_ooe_rcu_issue_s1_valid, b_ooe_rcu_issue_s0_valid};
    assign {ooe_rcu_issue_s8_payload, ooe_rcu_issue_s7_payload, ooe_rcu_issue_s6_payload, ooe_rcu_issue_s5_payload, ooe_rcu_issue_s4_payload, ooe_rcu_issue_s3_payload, ooe_rcu_issue_s2_payload, ooe_rcu_issue_s1_payload, ooe_rcu_issue_s0_payload} = {b_ooe_rcu_issue_s8_payload, b_ooe_rcu_issue_s7_payload, b_ooe_rcu_issue_s6_payload, b_ooe_rcu_issue_s5_payload, b_ooe_rcu_issue_s4_payload, b_ooe_rcu_issue_s3_payload, b_ooe_rcu_issue_s2_payload, b_ooe_rcu_issue_s1_payload, b_ooe_rcu_issue_s0_payload};
    assign ooe_rcu_issue_wake = b_ooe_rcu_issue_wake;
    assign {b_ooe_rcu_issue_s8_credit, b_ooe_rcu_issue_s7_credit, b_ooe_rcu_issue_s6_credit, b_ooe_rcu_issue_s5_credit, b_ooe_rcu_issue_s4_credit, b_ooe_rcu_issue_s3_credit, b_ooe_rcu_issue_s2_credit, b_ooe_rcu_issue_s1_credit, b_ooe_rcu_issue_s0_credit} = {ooe_rcu_issue_s8_credit, ooe_rcu_issue_s7_credit, ooe_rcu_issue_s6_credit, ooe_rcu_issue_s5_credit, ooe_rcu_issue_s4_credit, ooe_rcu_issue_s3_credit, ooe_rcu_issue_s2_credit, ooe_rcu_issue_s1_credit, ooe_rcu_issue_s0_credit};
    assign {b_ooe_rcu_issue_s8_stall, b_ooe_rcu_issue_s7_stall, b_ooe_rcu_issue_s6_stall, b_ooe_rcu_issue_s5_stall, b_ooe_rcu_issue_s4_stall, b_ooe_rcu_issue_s3_stall, b_ooe_rcu_issue_s2_stall, b_ooe_rcu_issue_s1_stall, b_ooe_rcu_issue_s0_stall} = {ooe_rcu_issue_s8_stall, ooe_rcu_issue_s7_stall, ooe_rcu_issue_s6_stall, ooe_rcu_issue_s5_stall, ooe_rcu_issue_s4_stall, ooe_rcu_issue_s3_stall, ooe_rcu_issue_s2_stall, ooe_rcu_issue_s1_stall, ooe_rcu_issue_s0_stall};
`ifdef CCV_TRACE
    assign {ooe_rcu_issue_s8_tid, ooe_rcu_issue_s7_tid, ooe_rcu_issue_s6_tid, ooe_rcu_issue_s5_tid, ooe_rcu_issue_s4_tid, ooe_rcu_issue_s3_tid, ooe_rcu_issue_s2_tid, ooe_rcu_issue_s1_tid, ooe_rcu_issue_s0_tid} = {b_ooe_rcu_issue_s8_tid, b_ooe_rcu_issue_s7_tid, b_ooe_rcu_issue_s6_tid, b_ooe_rcu_issue_s5_tid, b_ooe_rcu_issue_s4_tid, b_ooe_rcu_issue_s3_tid, b_ooe_rcu_issue_s2_tid, b_ooe_rcu_issue_s1_tid, b_ooe_rcu_issue_s0_tid};
`endif
  end
  // ccv_rcu_ooe_done, destination end
  if (RPT_RCU_OOE_DONE > 0) begin : g_rpt_rcu_ooe_done
    ccv_common_rpt #(.STAGES(RPT_RCU_OOE_DONE), .SLOTS(7), .PAYLOAD_W(40)) u_rpt_rcu_ooe_done (
      .clk(core_clk), .rst_n(rst_n),
      .src_valid({rcu_ooe_done_s6_valid, rcu_ooe_done_s5_valid, rcu_ooe_done_s4_valid, rcu_ooe_done_s3_valid, rcu_ooe_done_s2_valid, rcu_ooe_done_s1_valid, rcu_ooe_done_s0_valid}), .src_payload({rcu_ooe_done_s6_payload, rcu_ooe_done_s5_payload, rcu_ooe_done_s4_payload, rcu_ooe_done_s3_payload, rcu_ooe_done_s2_payload, rcu_ooe_done_s1_payload, rcu_ooe_done_s0_payload}),
      .src_wake(rcu_ooe_done_wake), .src_credit({rcu_ooe_done_s6_credit, rcu_ooe_done_s5_credit, rcu_ooe_done_s4_credit, rcu_ooe_done_s3_credit, rcu_ooe_done_s2_credit, rcu_ooe_done_s1_credit, rcu_ooe_done_s0_credit}), .src_stall({rcu_ooe_done_s6_stall, rcu_ooe_done_s5_stall, rcu_ooe_done_s4_stall, rcu_ooe_done_s3_stall, rcu_ooe_done_s2_stall, rcu_ooe_done_s1_stall, rcu_ooe_done_s0_stall}),
      .dst_valid({b_rcu_ooe_done_s6_valid, b_rcu_ooe_done_s5_valid, b_rcu_ooe_done_s4_valid, b_rcu_ooe_done_s3_valid, b_rcu_ooe_done_s2_valid, b_rcu_ooe_done_s1_valid, b_rcu_ooe_done_s0_valid}), .dst_payload({b_rcu_ooe_done_s6_payload, b_rcu_ooe_done_s5_payload, b_rcu_ooe_done_s4_payload, b_rcu_ooe_done_s3_payload, b_rcu_ooe_done_s2_payload, b_rcu_ooe_done_s1_payload, b_rcu_ooe_done_s0_payload}),
      .dst_wake(b_rcu_ooe_done_wake), .dst_credit({b_rcu_ooe_done_s6_credit, b_rcu_ooe_done_s5_credit, b_rcu_ooe_done_s4_credit, b_rcu_ooe_done_s3_credit, b_rcu_ooe_done_s2_credit, b_rcu_ooe_done_s1_credit, b_rcu_ooe_done_s0_credit}), .dst_stall({b_rcu_ooe_done_s6_stall, b_rcu_ooe_done_s5_stall, b_rcu_ooe_done_s4_stall, b_rcu_ooe_done_s3_stall, b_rcu_ooe_done_s2_stall, b_rcu_ooe_done_s1_stall, b_rcu_ooe_done_s0_stall})
`ifdef CCV_TRACE
      , .src_tid({rcu_ooe_done_s6_tid, rcu_ooe_done_s5_tid, rcu_ooe_done_s4_tid, rcu_ooe_done_s3_tid, rcu_ooe_done_s2_tid, rcu_ooe_done_s1_tid, rcu_ooe_done_s0_tid}), .dst_tid({b_rcu_ooe_done_s6_tid, b_rcu_ooe_done_s5_tid, b_rcu_ooe_done_s4_tid, b_rcu_ooe_done_s3_tid, b_rcu_ooe_done_s2_tid, b_rcu_ooe_done_s1_tid, b_rcu_ooe_done_s0_tid})
`endif
    );
  end else begin : g_wire_rcu_ooe_done
    assign {b_rcu_ooe_done_s6_valid, b_rcu_ooe_done_s5_valid, b_rcu_ooe_done_s4_valid, b_rcu_ooe_done_s3_valid, b_rcu_ooe_done_s2_valid, b_rcu_ooe_done_s1_valid, b_rcu_ooe_done_s0_valid} = {rcu_ooe_done_s6_valid, rcu_ooe_done_s5_valid, rcu_ooe_done_s4_valid, rcu_ooe_done_s3_valid, rcu_ooe_done_s2_valid, rcu_ooe_done_s1_valid, rcu_ooe_done_s0_valid};
    assign {b_rcu_ooe_done_s6_payload, b_rcu_ooe_done_s5_payload, b_rcu_ooe_done_s4_payload, b_rcu_ooe_done_s3_payload, b_rcu_ooe_done_s2_payload, b_rcu_ooe_done_s1_payload, b_rcu_ooe_done_s0_payload} = {rcu_ooe_done_s6_payload, rcu_ooe_done_s5_payload, rcu_ooe_done_s4_payload, rcu_ooe_done_s3_payload, rcu_ooe_done_s2_payload, rcu_ooe_done_s1_payload, rcu_ooe_done_s0_payload};
    assign b_rcu_ooe_done_wake = rcu_ooe_done_wake;
    assign {rcu_ooe_done_s6_credit, rcu_ooe_done_s5_credit, rcu_ooe_done_s4_credit, rcu_ooe_done_s3_credit, rcu_ooe_done_s2_credit, rcu_ooe_done_s1_credit, rcu_ooe_done_s0_credit} = {b_rcu_ooe_done_s6_credit, b_rcu_ooe_done_s5_credit, b_rcu_ooe_done_s4_credit, b_rcu_ooe_done_s3_credit, b_rcu_ooe_done_s2_credit, b_rcu_ooe_done_s1_credit, b_rcu_ooe_done_s0_credit};
    assign {rcu_ooe_done_s6_stall, rcu_ooe_done_s5_stall, rcu_ooe_done_s4_stall, rcu_ooe_done_s3_stall, rcu_ooe_done_s2_stall, rcu_ooe_done_s1_stall, rcu_ooe_done_s0_stall} = {b_rcu_ooe_done_s6_stall, b_rcu_ooe_done_s5_stall, b_rcu_ooe_done_s4_stall, b_rcu_ooe_done_s3_stall, b_rcu_ooe_done_s2_stall, b_rcu_ooe_done_s1_stall, b_rcu_ooe_done_s0_stall};
`ifdef CCV_TRACE
    assign {b_rcu_ooe_done_s6_tid, b_rcu_ooe_done_s5_tid, b_rcu_ooe_done_s4_tid, b_rcu_ooe_done_s3_tid, b_rcu_ooe_done_s2_tid, b_rcu_ooe_done_s1_tid, b_rcu_ooe_done_s0_tid} = {rcu_ooe_done_s6_tid, rcu_ooe_done_s5_tid, rcu_ooe_done_s4_tid, rcu_ooe_done_s3_tid, rcu_ooe_done_s2_tid, rcu_ooe_done_s1_tid, rcu_ooe_done_s0_tid};
`endif
  end
  // ccv_ooe_miu_memop, source end
  if (RPT_OOE_MIU_MEMOP > 0) begin : g_rpt_ooe_miu_memop
    ccv_common_rpt #(.STAGES(RPT_OOE_MIU_MEMOP), .SLOTS(4), .PAYLOAD_W(109)) u_rpt_ooe_miu_memop (
      .clk(core_clk), .rst_n(rst_n),
      .src_valid({b_ooe_miu_memop_s3_valid, b_ooe_miu_memop_s2_valid, b_ooe_miu_memop_s1_valid, b_ooe_miu_memop_s0_valid}), .src_payload({b_ooe_miu_memop_s3_payload, b_ooe_miu_memop_s2_payload, b_ooe_miu_memop_s1_payload, b_ooe_miu_memop_s0_payload}),
      .src_wake(b_ooe_miu_memop_wake), .src_credit({b_ooe_miu_memop_s3_credit, b_ooe_miu_memop_s2_credit, b_ooe_miu_memop_s1_credit, b_ooe_miu_memop_s0_credit}), .src_stall({b_ooe_miu_memop_s3_stall, b_ooe_miu_memop_s2_stall, b_ooe_miu_memop_s1_stall, b_ooe_miu_memop_s0_stall}),
      .dst_valid({ooe_miu_memop_s3_valid, ooe_miu_memop_s2_valid, ooe_miu_memop_s1_valid, ooe_miu_memop_s0_valid}), .dst_payload({ooe_miu_memop_s3_payload, ooe_miu_memop_s2_payload, ooe_miu_memop_s1_payload, ooe_miu_memop_s0_payload}),
      .dst_wake(ooe_miu_memop_wake), .dst_credit({ooe_miu_memop_s3_credit, ooe_miu_memop_s2_credit, ooe_miu_memop_s1_credit, ooe_miu_memop_s0_credit}), .dst_stall({ooe_miu_memop_s3_stall, ooe_miu_memop_s2_stall, ooe_miu_memop_s1_stall, ooe_miu_memop_s0_stall})
`ifdef CCV_TRACE
      , .src_tid({b_ooe_miu_memop_s3_tid, b_ooe_miu_memop_s2_tid, b_ooe_miu_memop_s1_tid, b_ooe_miu_memop_s0_tid}), .dst_tid({ooe_miu_memop_s3_tid, ooe_miu_memop_s2_tid, ooe_miu_memop_s1_tid, ooe_miu_memop_s0_tid})
`endif
    );
  end else begin : g_wire_ooe_miu_memop
    assign {ooe_miu_memop_s3_valid, ooe_miu_memop_s2_valid, ooe_miu_memop_s1_valid, ooe_miu_memop_s0_valid} = {b_ooe_miu_memop_s3_valid, b_ooe_miu_memop_s2_valid, b_ooe_miu_memop_s1_valid, b_ooe_miu_memop_s0_valid};
    assign {ooe_miu_memop_s3_payload, ooe_miu_memop_s2_payload, ooe_miu_memop_s1_payload, ooe_miu_memop_s0_payload} = {b_ooe_miu_memop_s3_payload, b_ooe_miu_memop_s2_payload, b_ooe_miu_memop_s1_payload, b_ooe_miu_memop_s0_payload};
    assign ooe_miu_memop_wake = b_ooe_miu_memop_wake;
    assign {b_ooe_miu_memop_s3_credit, b_ooe_miu_memop_s2_credit, b_ooe_miu_memop_s1_credit, b_ooe_miu_memop_s0_credit} = {ooe_miu_memop_s3_credit, ooe_miu_memop_s2_credit, ooe_miu_memop_s1_credit, ooe_miu_memop_s0_credit};
    assign {b_ooe_miu_memop_s3_stall, b_ooe_miu_memop_s2_stall, b_ooe_miu_memop_s1_stall, b_ooe_miu_memop_s0_stall} = {ooe_miu_memop_s3_stall, ooe_miu_memop_s2_stall, ooe_miu_memop_s1_stall, ooe_miu_memop_s0_stall};
`ifdef CCV_TRACE
    assign {ooe_miu_memop_s3_tid, ooe_miu_memop_s2_tid, ooe_miu_memop_s1_tid, ooe_miu_memop_s0_tid} = {b_ooe_miu_memop_s3_tid, b_ooe_miu_memop_s2_tid, b_ooe_miu_memop_s1_tid, b_ooe_miu_memop_s0_tid};
`endif
  end
  // ccv_miu_ooe_cmpl, destination end
  if (RPT_MIU_OOE_CMPL > 0) begin : g_rpt_miu_ooe_cmpl
    ccv_common_rpt #(.STAGES(RPT_MIU_OOE_CMPL), .SLOTS(4), .PAYLOAD_W(111)) u_rpt_miu_ooe_cmpl (
      .clk(core_clk), .rst_n(rst_n),
      .src_valid({miu_ooe_cmpl_s3_valid, miu_ooe_cmpl_s2_valid, miu_ooe_cmpl_s1_valid, miu_ooe_cmpl_s0_valid}), .src_payload({miu_ooe_cmpl_s3_payload, miu_ooe_cmpl_s2_payload, miu_ooe_cmpl_s1_payload, miu_ooe_cmpl_s0_payload}),
      .src_wake(miu_ooe_cmpl_wake), .src_credit({miu_ooe_cmpl_s3_credit, miu_ooe_cmpl_s2_credit, miu_ooe_cmpl_s1_credit, miu_ooe_cmpl_s0_credit}), .src_stall({miu_ooe_cmpl_s3_stall, miu_ooe_cmpl_s2_stall, miu_ooe_cmpl_s1_stall, miu_ooe_cmpl_s0_stall}),
      .dst_valid({b_miu_ooe_cmpl_s3_valid, b_miu_ooe_cmpl_s2_valid, b_miu_ooe_cmpl_s1_valid, b_miu_ooe_cmpl_s0_valid}), .dst_payload({b_miu_ooe_cmpl_s3_payload, b_miu_ooe_cmpl_s2_payload, b_miu_ooe_cmpl_s1_payload, b_miu_ooe_cmpl_s0_payload}),
      .dst_wake(b_miu_ooe_cmpl_wake), .dst_credit({b_miu_ooe_cmpl_s3_credit, b_miu_ooe_cmpl_s2_credit, b_miu_ooe_cmpl_s1_credit, b_miu_ooe_cmpl_s0_credit}), .dst_stall({b_miu_ooe_cmpl_s3_stall, b_miu_ooe_cmpl_s2_stall, b_miu_ooe_cmpl_s1_stall, b_miu_ooe_cmpl_s0_stall})
`ifdef CCV_TRACE
      , .src_tid({miu_ooe_cmpl_s3_tid, miu_ooe_cmpl_s2_tid, miu_ooe_cmpl_s1_tid, miu_ooe_cmpl_s0_tid}), .dst_tid({b_miu_ooe_cmpl_s3_tid, b_miu_ooe_cmpl_s2_tid, b_miu_ooe_cmpl_s1_tid, b_miu_ooe_cmpl_s0_tid})
`endif
    );
  end else begin : g_wire_miu_ooe_cmpl
    assign {b_miu_ooe_cmpl_s3_valid, b_miu_ooe_cmpl_s2_valid, b_miu_ooe_cmpl_s1_valid, b_miu_ooe_cmpl_s0_valid} = {miu_ooe_cmpl_s3_valid, miu_ooe_cmpl_s2_valid, miu_ooe_cmpl_s1_valid, miu_ooe_cmpl_s0_valid};
    assign {b_miu_ooe_cmpl_s3_payload, b_miu_ooe_cmpl_s2_payload, b_miu_ooe_cmpl_s1_payload, b_miu_ooe_cmpl_s0_payload} = {miu_ooe_cmpl_s3_payload, miu_ooe_cmpl_s2_payload, miu_ooe_cmpl_s1_payload, miu_ooe_cmpl_s0_payload};
    assign b_miu_ooe_cmpl_wake = miu_ooe_cmpl_wake;
    assign {miu_ooe_cmpl_s3_credit, miu_ooe_cmpl_s2_credit, miu_ooe_cmpl_s1_credit, miu_ooe_cmpl_s0_credit} = {b_miu_ooe_cmpl_s3_credit, b_miu_ooe_cmpl_s2_credit, b_miu_ooe_cmpl_s1_credit, b_miu_ooe_cmpl_s0_credit};
    assign {miu_ooe_cmpl_s3_stall, miu_ooe_cmpl_s2_stall, miu_ooe_cmpl_s1_stall, miu_ooe_cmpl_s0_stall} = {b_miu_ooe_cmpl_s3_stall, b_miu_ooe_cmpl_s2_stall, b_miu_ooe_cmpl_s1_stall, b_miu_ooe_cmpl_s0_stall};
`ifdef CCV_TRACE
    assign {b_miu_ooe_cmpl_s3_tid, b_miu_ooe_cmpl_s2_tid, b_miu_ooe_cmpl_s1_tid, b_miu_ooe_cmpl_s0_tid} = {miu_ooe_cmpl_s3_tid, miu_ooe_cmpl_s2_tid, miu_ooe_cmpl_s1_tid, miu_ooe_cmpl_s0_tid};
`endif
  end
  // ccv_ooe_miu_retire, source end
  if (RPT_OOE_MIU_RETIRE > 0) begin : g_rpt_ooe_miu_retire
    ccv_common_rpt #(.STAGES(RPT_OOE_MIU_RETIRE), .SLOTS(4), .PAYLOAD_W(8)) u_rpt_ooe_miu_retire (
      .clk(core_clk), .rst_n(rst_n),
      .src_valid({b_ooe_miu_retire_s3_valid, b_ooe_miu_retire_s2_valid, b_ooe_miu_retire_s1_valid, b_ooe_miu_retire_s0_valid}), .src_payload({b_ooe_miu_retire_s3_payload, b_ooe_miu_retire_s2_payload, b_ooe_miu_retire_s1_payload, b_ooe_miu_retire_s0_payload}),
      .src_wake(b_ooe_miu_retire_wake), .src_credit({b_ooe_miu_retire_s3_credit, b_ooe_miu_retire_s2_credit, b_ooe_miu_retire_s1_credit, b_ooe_miu_retire_s0_credit}), .src_stall({b_ooe_miu_retire_s3_stall, b_ooe_miu_retire_s2_stall, b_ooe_miu_retire_s1_stall, b_ooe_miu_retire_s0_stall}),
      .dst_valid({ooe_miu_retire_s3_valid, ooe_miu_retire_s2_valid, ooe_miu_retire_s1_valid, ooe_miu_retire_s0_valid}), .dst_payload({ooe_miu_retire_s3_payload, ooe_miu_retire_s2_payload, ooe_miu_retire_s1_payload, ooe_miu_retire_s0_payload}),
      .dst_wake(ooe_miu_retire_wake), .dst_credit({ooe_miu_retire_s3_credit, ooe_miu_retire_s2_credit, ooe_miu_retire_s1_credit, ooe_miu_retire_s0_credit}), .dst_stall({ooe_miu_retire_s3_stall, ooe_miu_retire_s2_stall, ooe_miu_retire_s1_stall, ooe_miu_retire_s0_stall})
`ifdef CCV_TRACE
      , .src_tid({b_ooe_miu_retire_s3_tid, b_ooe_miu_retire_s2_tid, b_ooe_miu_retire_s1_tid, b_ooe_miu_retire_s0_tid}), .dst_tid({ooe_miu_retire_s3_tid, ooe_miu_retire_s2_tid, ooe_miu_retire_s1_tid, ooe_miu_retire_s0_tid})
`endif
    );
  end else begin : g_wire_ooe_miu_retire
    assign {ooe_miu_retire_s3_valid, ooe_miu_retire_s2_valid, ooe_miu_retire_s1_valid, ooe_miu_retire_s0_valid} = {b_ooe_miu_retire_s3_valid, b_ooe_miu_retire_s2_valid, b_ooe_miu_retire_s1_valid, b_ooe_miu_retire_s0_valid};
    assign {ooe_miu_retire_s3_payload, ooe_miu_retire_s2_payload, ooe_miu_retire_s1_payload, ooe_miu_retire_s0_payload} = {b_ooe_miu_retire_s3_payload, b_ooe_miu_retire_s2_payload, b_ooe_miu_retire_s1_payload, b_ooe_miu_retire_s0_payload};
    assign ooe_miu_retire_wake = b_ooe_miu_retire_wake;
    assign {b_ooe_miu_retire_s3_credit, b_ooe_miu_retire_s2_credit, b_ooe_miu_retire_s1_credit, b_ooe_miu_retire_s0_credit} = {ooe_miu_retire_s3_credit, ooe_miu_retire_s2_credit, ooe_miu_retire_s1_credit, ooe_miu_retire_s0_credit};
    assign {b_ooe_miu_retire_s3_stall, b_ooe_miu_retire_s2_stall, b_ooe_miu_retire_s1_stall, b_ooe_miu_retire_s0_stall} = {ooe_miu_retire_s3_stall, ooe_miu_retire_s2_stall, ooe_miu_retire_s1_stall, ooe_miu_retire_s0_stall};
`ifdef CCV_TRACE
    assign {ooe_miu_retire_s3_tid, ooe_miu_retire_s2_tid, ooe_miu_retire_s1_tid, ooe_miu_retire_s0_tid} = {b_ooe_miu_retire_s3_tid, b_ooe_miu_retire_s2_tid, b_ooe_miu_retire_s1_tid, b_ooe_miu_retire_s0_tid};
`endif
  end
  // ccv_ooe_fet_redirect, source end
  if (RPT_OOE_FET_REDIRECT > 0) begin : g_rpt_ooe_fet_redirect
    ccv_common_rpt #(.STAGES(RPT_OOE_FET_REDIRECT), .SLOTS(1), .PAYLOAD_W(109)) u_rpt_ooe_fet_redirect (
      .clk(core_clk), .rst_n(rst_n),
      .src_valid({b_ooe_fet_redirect_valid}), .src_payload({b_ooe_fet_redirect_payload}),
      .src_wake(b_ooe_fet_redirect_wake), .src_credit({b_ooe_fet_redirect_credit}), .src_stall({b_ooe_fet_redirect_stall}),
      .dst_valid({ooe_fet_redirect_valid}), .dst_payload({ooe_fet_redirect_payload}),
      .dst_wake(ooe_fet_redirect_wake), .dst_credit({ooe_fet_redirect_credit}), .dst_stall({ooe_fet_redirect_stall})
`ifdef CCV_TRACE
      , .src_tid({b_ooe_fet_redirect_tid}), .dst_tid({ooe_fet_redirect_tid})
`endif
    );
  end else begin : g_wire_ooe_fet_redirect
    assign {ooe_fet_redirect_valid} = {b_ooe_fet_redirect_valid};
    assign {ooe_fet_redirect_payload} = {b_ooe_fet_redirect_payload};
    assign ooe_fet_redirect_wake = b_ooe_fet_redirect_wake;
    assign {b_ooe_fet_redirect_credit} = {ooe_fet_redirect_credit};
    assign {b_ooe_fet_redirect_stall} = {ooe_fet_redirect_stall};
`ifdef CCV_TRACE
    assign {ooe_fet_redirect_tid} = {b_ooe_fet_redirect_tid};
`endif
  end
  // ccv_ooe_fet_ckpt_free, source end
  if (RPT_OOE_FET_CKPT_FREE > 0) begin : g_rpt_ooe_fet_ckpt_free
    ccv_common_rpt #(.STAGES(RPT_OOE_FET_CKPT_FREE), .SLOTS(1), .PAYLOAD_W(16)) u_rpt_ooe_fet_ckpt_free (
      .clk(core_clk), .rst_n(rst_n),
      .src_valid({b_ooe_fet_ckpt_free_valid}), .src_payload({b_ooe_fet_ckpt_free_payload}),
      .src_wake(b_ooe_fet_ckpt_free_wake), .src_credit({b_ooe_fet_ckpt_free_credit}), .src_stall({b_ooe_fet_ckpt_free_stall}),
      .dst_valid({ooe_fet_ckpt_free_valid}), .dst_payload({ooe_fet_ckpt_free_payload}),
      .dst_wake(ooe_fet_ckpt_free_wake), .dst_credit({ooe_fet_ckpt_free_credit}), .dst_stall({ooe_fet_ckpt_free_stall})
`ifdef CCV_TRACE
      , .src_tid({b_ooe_fet_ckpt_free_tid}), .dst_tid({ooe_fet_ckpt_free_tid})
`endif
    );
  end else begin : g_wire_ooe_fet_ckpt_free
    assign {ooe_fet_ckpt_free_valid} = {b_ooe_fet_ckpt_free_valid};
    assign {ooe_fet_ckpt_free_payload} = {b_ooe_fet_ckpt_free_payload};
    assign ooe_fet_ckpt_free_wake = b_ooe_fet_ckpt_free_wake;
    assign {b_ooe_fet_ckpt_free_credit} = {ooe_fet_ckpt_free_credit};
    assign {b_ooe_fet_ckpt_free_stall} = {ooe_fet_ckpt_free_stall};
`ifdef CCV_TRACE
    assign {ooe_fet_ckpt_free_tid} = {b_ooe_fet_ckpt_free_tid};
`endif
  end
  // ccv_rau_ooe_alloc, destination end
  if (RPT_RAU_OOE_ALLOC > 0) begin : g_rpt_rau_ooe_alloc
    ccv_common_rpt #(.STAGES(RPT_RAU_OOE_ALLOC), .SLOTS(1), .PAYLOAD_W(51)) u_rpt_rau_ooe_alloc (
      .clk(core_clk), .rst_n(rst_n),
      .src_valid({rau_ooe_alloc_valid}), .src_payload({rau_ooe_alloc_payload}),
      .src_wake(rau_ooe_alloc_wake), .src_credit({rau_ooe_alloc_credit}), .src_stall({rau_ooe_alloc_stall}),
      .dst_valid({b_rau_ooe_alloc_valid}), .dst_payload({b_rau_ooe_alloc_payload}),
      .dst_wake(b_rau_ooe_alloc_wake), .dst_credit({b_rau_ooe_alloc_credit}), .dst_stall({b_rau_ooe_alloc_stall})
`ifdef CCV_TRACE
      , .src_tid({rau_ooe_alloc_tid}), .dst_tid({b_rau_ooe_alloc_tid})
`endif
    );
  end else begin : g_wire_rau_ooe_alloc
    assign {b_rau_ooe_alloc_valid} = {rau_ooe_alloc_valid};
    assign {b_rau_ooe_alloc_payload} = {rau_ooe_alloc_payload};
    assign b_rau_ooe_alloc_wake = rau_ooe_alloc_wake;
    assign {rau_ooe_alloc_credit} = {b_rau_ooe_alloc_credit};
    assign {rau_ooe_alloc_stall} = {b_rau_ooe_alloc_stall};
`ifdef CCV_TRACE
    assign {b_rau_ooe_alloc_tid} = {rau_ooe_alloc_tid};
`endif
  end
  // ccv_ooe_rau_status, source end
  if (RPT_OOE_RAU_STATUS > 0) begin : g_rpt_ooe_rau_status
    ccv_common_rpt #(.STAGES(RPT_OOE_RAU_STATUS), .SLOTS(1), .PAYLOAD_W(16)) u_rpt_ooe_rau_status (
      .clk(core_clk), .rst_n(rst_n),
      .src_valid({b_ooe_rau_status_valid}), .src_payload({b_ooe_rau_status_payload}),
      .src_wake(b_ooe_rau_status_wake), .src_credit({b_ooe_rau_status_credit}), .src_stall({b_ooe_rau_status_stall}),
      .dst_valid({ooe_rau_status_valid}), .dst_payload({ooe_rau_status_payload}),
      .dst_wake(ooe_rau_status_wake), .dst_credit({ooe_rau_status_credit}), .dst_stall({ooe_rau_status_stall})
`ifdef CCV_TRACE
      , .src_tid({b_ooe_rau_status_tid}), .dst_tid({ooe_rau_status_tid})
`endif
    );
  end else begin : g_wire_ooe_rau_status
    assign {ooe_rau_status_valid} = {b_ooe_rau_status_valid};
    assign {ooe_rau_status_payload} = {b_ooe_rau_status_payload};
    assign ooe_rau_status_wake = b_ooe_rau_status_wake;
    assign {b_ooe_rau_status_credit} = {ooe_rau_status_credit};
    assign {b_ooe_rau_status_stall} = {ooe_rau_status_stall};
`ifdef CCV_TRACE
    assign {ooe_rau_status_tid} = {b_ooe_rau_status_tid};
`endif
  end
  // ccv_rau_ooe_demote, destination end
  if (RPT_RAU_OOE_DEMOTE > 0) begin : g_rpt_rau_ooe_demote
    ccv_common_rpt #(.STAGES(RPT_RAU_OOE_DEMOTE), .SLOTS(1), .PAYLOAD_W(6)) u_rpt_rau_ooe_demote (
      .clk(core_clk), .rst_n(rst_n),
      .src_valid({rau_ooe_demote_valid}), .src_payload({rau_ooe_demote_payload}),
      .src_wake(rau_ooe_demote_wake), .src_credit({rau_ooe_demote_credit}), .src_stall({rau_ooe_demote_stall}),
      .dst_valid({b_rau_ooe_demote_valid}), .dst_payload({b_rau_ooe_demote_payload}),
      .dst_wake(b_rau_ooe_demote_wake), .dst_credit({b_rau_ooe_demote_credit}), .dst_stall({b_rau_ooe_demote_stall})
`ifdef CCV_TRACE
      , .src_tid({rau_ooe_demote_tid}), .dst_tid({b_rau_ooe_demote_tid})
`endif
    );
  end else begin : g_wire_rau_ooe_demote
    assign {b_rau_ooe_demote_valid} = {rau_ooe_demote_valid};
    assign {b_rau_ooe_demote_payload} = {rau_ooe_demote_payload};
    assign b_rau_ooe_demote_wake = rau_ooe_demote_wake;
    assign {rau_ooe_demote_credit} = {b_rau_ooe_demote_credit};
    assign {rau_ooe_demote_stall} = {b_rau_ooe_demote_stall};
`ifdef CCV_TRACE
    assign {b_rau_ooe_demote_tid} = {rau_ooe_demote_tid};
`endif
  end
  // ccv_ooe_rau_drained, source end
  if (RPT_OOE_RAU_DRAINED > 0) begin : g_rpt_ooe_rau_drained
    ccv_common_rpt #(.STAGES(RPT_OOE_RAU_DRAINED), .SLOTS(1), .PAYLOAD_W(70)) u_rpt_ooe_rau_drained (
      .clk(core_clk), .rst_n(rst_n),
      .src_valid({b_ooe_rau_drained_valid}), .src_payload({b_ooe_rau_drained_payload}),
      .src_wake(b_ooe_rau_drained_wake), .src_credit({b_ooe_rau_drained_credit}), .src_stall({b_ooe_rau_drained_stall}),
      .dst_valid({ooe_rau_drained_valid}), .dst_payload({ooe_rau_drained_payload}),
      .dst_wake(ooe_rau_drained_wake), .dst_credit({ooe_rau_drained_credit}), .dst_stall({ooe_rau_drained_stall})
`ifdef CCV_TRACE
      , .src_tid({b_ooe_rau_drained_tid}), .dst_tid({ooe_rau_drained_tid})
`endif
    );
  end else begin : g_wire_ooe_rau_drained
    assign {ooe_rau_drained_valid} = {b_ooe_rau_drained_valid};
    assign {ooe_rau_drained_payload} = {b_ooe_rau_drained_payload};
    assign ooe_rau_drained_wake = b_ooe_rau_drained_wake;
    assign {b_ooe_rau_drained_credit} = {ooe_rau_drained_credit};
    assign {b_ooe_rau_drained_stall} = {ooe_rau_drained_stall};
`ifdef CCV_TRACE
    assign {ooe_rau_drained_tid} = {b_ooe_rau_drained_tid};
`endif
  end
  // ccv_ooe_rcu_map, source end
  if (RPT_OOE_RCU_MAP > 0) begin : g_rpt_ooe_rcu_map
    ccv_common_rpt #(.STAGES(RPT_OOE_RCU_MAP), .SLOTS(1), .PAYLOAD_W(222)) u_rpt_ooe_rcu_map (
      .clk(core_clk), .rst_n(rst_n),
      .src_valid({b_ooe_rcu_map_valid}), .src_payload({b_ooe_rcu_map_payload}),
      .src_wake(b_ooe_rcu_map_wake), .src_credit({b_ooe_rcu_map_credit}), .src_stall({b_ooe_rcu_map_stall}),
      .dst_valid({ooe_rcu_map_valid}), .dst_payload({ooe_rcu_map_payload}),
      .dst_wake(ooe_rcu_map_wake), .dst_credit({ooe_rcu_map_credit}), .dst_stall({ooe_rcu_map_stall})
`ifdef CCV_TRACE
      , .src_tid({b_ooe_rcu_map_tid}), .dst_tid({ooe_rcu_map_tid})
`endif
    );
  end else begin : g_wire_ooe_rcu_map
    assign {ooe_rcu_map_valid} = {b_ooe_rcu_map_valid};
    assign {ooe_rcu_map_payload} = {b_ooe_rcu_map_payload};
    assign ooe_rcu_map_wake = b_ooe_rcu_map_wake;
    assign {b_ooe_rcu_map_credit} = {ooe_rcu_map_credit};
    assign {b_ooe_rcu_map_stall} = {ooe_rcu_map_stall};
`ifdef CCV_TRACE
    assign {ooe_rcu_map_tid} = {b_ooe_rcu_map_tid};
`endif
  end
  // ccv_ooe_syu_bar, source end
  if (RPT_OOE_SYU_BAR > 0) begin : g_rpt_ooe_syu_bar
    ccv_common_rpt #(.STAGES(RPT_OOE_SYU_BAR), .SLOTS(1), .PAYLOAD_W(13)) u_rpt_ooe_syu_bar (
      .clk(core_clk), .rst_n(rst_n),
      .src_valid({b_ooe_syu_bar_valid}), .src_payload({b_ooe_syu_bar_payload}),
      .src_wake(b_ooe_syu_bar_wake), .src_credit({b_ooe_syu_bar_credit}), .src_stall({b_ooe_syu_bar_stall}),
      .dst_valid({ooe_syu_bar_valid}), .dst_payload({ooe_syu_bar_payload}),
      .dst_wake(ooe_syu_bar_wake), .dst_credit({ooe_syu_bar_credit}), .dst_stall({ooe_syu_bar_stall})
`ifdef CCV_TRACE
      , .src_tid({b_ooe_syu_bar_tid}), .dst_tid({ooe_syu_bar_tid})
`endif
    );
  end else begin : g_wire_ooe_syu_bar
    assign {ooe_syu_bar_valid} = {b_ooe_syu_bar_valid};
    assign {ooe_syu_bar_payload} = {b_ooe_syu_bar_payload};
    assign ooe_syu_bar_wake = b_ooe_syu_bar_wake;
    assign {b_ooe_syu_bar_credit} = {ooe_syu_bar_credit};
    assign {b_ooe_syu_bar_stall} = {ooe_syu_bar_stall};
`ifdef CCV_TRACE
    assign {ooe_syu_bar_tid} = {b_ooe_syu_bar_tid};
`endif
  end
  // ccv_syu_ooe_rel, destination end
  if (RPT_SYU_OOE_REL > 0) begin : g_rpt_syu_ooe_rel
    ccv_common_rpt #(.STAGES(RPT_SYU_OOE_REL), .SLOTS(1), .PAYLOAD_W(36)) u_rpt_syu_ooe_rel (
      .clk(core_clk), .rst_n(rst_n),
      .src_valid({syu_ooe_rel_valid}), .src_payload({syu_ooe_rel_payload}),
      .src_wake(syu_ooe_rel_wake), .src_credit({syu_ooe_rel_credit}), .src_stall({syu_ooe_rel_stall}),
      .dst_valid({b_syu_ooe_rel_valid}), .dst_payload({b_syu_ooe_rel_payload}),
      .dst_wake(b_syu_ooe_rel_wake), .dst_credit({b_syu_ooe_rel_credit}), .dst_stall({b_syu_ooe_rel_stall})
`ifdef CCV_TRACE
      , .src_tid({syu_ooe_rel_tid}), .dst_tid({b_syu_ooe_rel_tid})
`endif
    );
  end else begin : g_wire_syu_ooe_rel
    assign {b_syu_ooe_rel_valid} = {syu_ooe_rel_valid};
    assign {b_syu_ooe_rel_payload} = {syu_ooe_rel_payload};
    assign b_syu_ooe_rel_wake = syu_ooe_rel_wake;
    assign {syu_ooe_rel_credit} = {b_syu_ooe_rel_credit};
    assign {syu_ooe_rel_stall} = {b_syu_ooe_rel_stall};
`ifdef CCV_TRACE
    assign {b_syu_ooe_rel_tid} = {syu_ooe_rel_tid};
`endif
  end
  // ccv_ooe_cru_fault, source end
  if (RPT_OOE_CRU_FAULT > 0) begin : g_rpt_ooe_cru_fault
    ccv_common_rpt #(.STAGES(RPT_OOE_CRU_FAULT), .SLOTS(1), .PAYLOAD_W(172)) u_rpt_ooe_cru_fault (
      .clk(core_clk), .rst_n(rst_n),
      .src_valid({b_ooe_cru_fault_valid}), .src_payload({b_ooe_cru_fault_payload}),
      .src_wake(b_ooe_cru_fault_wake), .src_credit({b_ooe_cru_fault_credit}), .src_stall({b_ooe_cru_fault_stall}),
      .dst_valid({ooe_cru_fault_valid}), .dst_payload({ooe_cru_fault_payload}),
      .dst_wake(ooe_cru_fault_wake), .dst_credit({ooe_cru_fault_credit}), .dst_stall({ooe_cru_fault_stall})
`ifdef CCV_TRACE
      , .src_tid({b_ooe_cru_fault_tid}), .dst_tid({ooe_cru_fault_tid})
`endif
    );
  end else begin : g_wire_ooe_cru_fault
    assign {ooe_cru_fault_valid} = {b_ooe_cru_fault_valid};
    assign {ooe_cru_fault_payload} = {b_ooe_cru_fault_payload};
    assign ooe_cru_fault_wake = b_ooe_cru_fault_wake;
    assign {b_ooe_cru_fault_credit} = {ooe_cru_fault_credit};
    assign {b_ooe_cru_fault_stall} = {ooe_cru_fault_stall};
`ifdef CCV_TRACE
    assign {ooe_cru_fault_tid} = {b_ooe_cru_fault_tid};
`endif
  end
endmodule
