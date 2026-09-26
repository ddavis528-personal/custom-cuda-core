// GENERATED FILE -- DO NOT EDIT.
//
// Produced by tools/gen-interfaces.py from schema/interfaces.json.
// Edit the source and regenerate; tools/verify.sh fails if this file is stale.

`ifndef CCV_INTERFACES_SVH
`define CCV_INTERFACES_SVH

// The payload structs below are sized from both parameter
// packages, so this header pulls them in rather than relying on a
// consumer having included them first.
`include "ccv_params_pkg.sv"

/* verilator lint_off UNUSEDPARAM */

// Every channel carries the same signals:
//   <name>_valid    Asserted ONE CYCLE AHEAD of the payload, on every interface without exception.
//   <name>_payload  The packed struct.
//   <name>_credit   Credit return.
//   <name>_stall    Stall-invalidate: temporarily invalidates outstanding credits.
//   <name>_wake     Wake request toward the receiver, asserted by the sender ahead of a send so a gated receiver can ungate.
//
// Common ports, on every block (fabric: how the top connects them):
//   clk              in   fan-in    Gated clock for the block.
//   clk_free         in   fan-in    Ungated clock, for the wake detector ONLY.
//   rst_n            in   fan-in    Synchronous reset, ACTIVE LOW.
//   kill_valid       in   broadcast Grid teardown, one cycle ahead of the mask, broadcast by RAU to the eight blocks that own warp state (FET, DEC, OOE, RCU, MIU, SPM, SYU, PCA).
//   kill_warp_mask   in   broadcast Warps to discard, one bit per warp CONTEXT (32: tier-1 and parked), driven by RAU.
//   kill_epoch       in   broadcast Epoch of the kill being broadcast.
//   kill_ack         out  gather    QUIESCED, not merely stopped: a block acks only when it holds no state for the killed warps AND has nothing in flight toward anyone else on their behalf.
//   kill_ack_epoch   out  gather    The kill_epoch this ack answers.
//   sleep_ok         out  local     Block is drained and may be gated.
//   csr_req          in   star      Address, write data, write enable, from CRU, which owns the CSR fabric.
//   csr_rsp          out  star      Read data, done.
//   csr_credit       out  star      Credit return for the CSR channel.

localparam int CCV_NUM_CHANNELS = 46;

// fet -> dec, 8/cycle
localparam int CCV_CH_FET_DEC_INSTR = 0;
// dec -> ooe, 6/cycle
localparam int CCV_CH_DEC_OOE_UOP = 1;
// ooe -> rcu, 4/cycle
localparam int CCV_CH_OOE_RCU_ISSUE = 2;
// rcu -> lane, 4/cycle
localparam int CCV_CH_RCU_LANE_OPS = 3;
// lane -> rcu, 4/cycle
localparam int CCV_CH_LANE_RCU_RES = 4;
// rcu -> ooe, 4/cycle
localparam int CCV_CH_RCU_OOE_DONE = 5;
// rcu -> miu, 4/cycle
localparam int CCV_CH_RCU_MIU_ADDR = 6;
// miu -> rcu, 4/cycle
localparam int CCV_CH_MIU_RCU_DATA = 7;
// ooe -> miu, 4/cycle
localparam int CCV_CH_OOE_MIU_MEMOP = 8;
// miu -> ooe, 4/cycle
localparam int CCV_CH_MIU_OOE_CMPL = 9;
// ooe -> miu, 4/cycle
localparam int CCV_CH_OOE_MIU_RETIRE = 10;
// ooe -> fet, 1/cycle
localparam int CCV_CH_OOE_FET_REDIRECT = 11;
// miu -> spm, 4/cycle
localparam int CCV_CH_MIU_SPM_REQ = 12;
// spm -> miu, 4/cycle
localparam int CCV_CH_SPM_MIU_RSP = 13;
// miu -> dcu, 4/cycle
localparam int CCV_CH_MIU_DCU_REQ = 14;
// dcu -> miu, 4/cycle
localparam int CCV_CH_DCU_MIU_RSP = 15;
// dcu -> mlc, 1/cycle
localparam int CCV_CH_DCU_MLC_REQ = 16;
// mlc -> dcu, 1/cycle
localparam int CCV_CH_MLC_DCU_RSP = 17;
// mlc -> dcu, 1/cycle
localparam int CCV_CH_MLC_DCU_PROBE = 18;
// dcu -> mlc, 1/cycle
localparam int CCV_CH_DCU_MLC_PROBE_ACK = 19;
// fet -> mlc, 1/cycle
localparam int CCV_CH_FET_MLC_IFILL = 20;
// mlc -> fet, 1/cycle
localparam int CCV_CH_MLC_FET_IFILL_RSP = 21;
// miu -> fet, 1/cycle
localparam int CCV_CH_MIU_FET_ITLB = 22;
// fet -> miu, 1/cycle
localparam int CCV_CH_FET_MIU_ITLB_REQ = 23;
// mlc -> exb, 1/cycle
localparam int CCV_CH_MLC_EXB_REQ = 24;
// exb -> mlc, 1/cycle
localparam int CCV_CH_EXB_MLC_RSP = 25;
// exb -> EXTERNAL, 1/cycle
localparam int CCV_CH_EXB_EXT_OUT = 26;
// rau -> fet, 1/cycle
localparam int CCV_CH_RAU_FET_LAUNCH = 27;
// rau -> ooe, 1/cycle
localparam int CCV_CH_RAU_OOE_ALLOC = 28;
// ooe -> rau, 1/cycle
localparam int CCV_CH_OOE_RAU_STATUS = 29;
// rau -> ooe, 1/cycle
localparam int CCV_CH_RAU_OOE_DEMOTE = 30;
// ooe -> rau, 1/cycle
localparam int CCV_CH_OOE_RAU_DRAINED = 31;
// rau -> rcu, 1/cycle
localparam int CCV_CH_RAU_RCU_MIG = 32;
// rcu -> pca, 1/cycle
localparam int CCV_CH_RCU_PCA_MIG = 33;
// pca -> rcu, 1/cycle
localparam int CCV_CH_PCA_RCU_MIG = 34;
// fet -> pca, 1/cycle
localparam int CCV_CH_FET_PCA_MIG = 35;
// pca -> fet, 1/cycle
localparam int CCV_CH_PCA_FET_MIG = 36;
// rau -> fet, 1/cycle
localparam int CCV_CH_RAU_FET_MIG = 37;
// pca -> rau, 1/cycle
localparam int CCV_CH_PCA_RAU_MIG_DONE = 38;
// rau -> miu, 1/cycle
localparam int CCV_CH_RAU_MIU_CTA = 39;
// ooe -> syu, 1/cycle
localparam int CCV_CH_OOE_SYU_BAR = 40;
// syu -> ooe, 1/cycle
localparam int CCV_CH_SYU_OOE_REL = 41;
// rau -> syu, 1/cycle
localparam int CCV_CH_RAU_SYU_ALLOC = 42;
// ooe -> cru, 1/cycle
localparam int CCV_CH_OOE_CRU_FAULT = 43;
// cru -> rau, 1/cycle
localparam int CCV_CH_CRU_RAU_CFG = 44;
// EXTERNAL -> exb, 1/cycle
localparam int CCV_CH_EXT_EXB_IN = 45;

// Payload structs, for channels whose every field has a
// decided width. A channel missing one generates no struct --
// see the list at the end of this file.

typedef struct packed {
  logic [ccv_params_pkg::CCV_W_WARP_ID-1:0]      warp_id;
  logic [ccv_params_pkg::CCV_W_TIER1_ID-1:0]     tier1_id;
  logic [ccv_params_pkg::CCV_W_VA-1:0]           pc;
  logic [ccv_params_pkg::CCV_W_INSTR-1:0]        instr;
  logic [ccv_params_pkg::CCV_W_ILEN-1:0]         length;
  logic                                          fetch_fault;
} ccv_fet_dec_instr_t;

typedef struct packed {
  logic [ccv_params_pkg::CCV_W_WARP_ID-1:0]      warp_id;
  logic [ccv_params_pkg::CCV_W_VA-1:0]           pc;
  logic [ccv_prelim_pkg::CCV_L_W_CLASS-1:0]      uop_class;
  logic [ccv_prelim_pkg::CCV_L_W_OPCODE-1:0]     opcode;
  logic [2*ccv_params_pkg::CCV_W_ARCH_REG-1:0]   src_arch;
  logic [ccv_params_pkg::CCV_W_ARCH_REG-1:0]     src2_arch;
  logic [ccv_params_pkg::CCV_W_ARCH_REG-1:0]     dst_arch;
  logic [ccv_params_pkg::CCV_W_ARCH_PRED-1:0]    pred_guard;
  logic                                          pred_neg;
  logic [ccv_params_pkg::CCV_W_ARCH_PRED-1:0]    pred_dst;
  logic                                          pred_we;
  logic [ccv_prov_pkg::CCV_P_W_IMM-1:0]          imm;
  logic                                          scale_en;
  logic                                          decode_fault;
} ccv_dec_ooe_uop_t;

typedef struct packed {
  logic [ccv_prov_pkg::CCV_P_W_ROB_TAG-1:0]      rob_tag;
  logic [ccv_params_pkg::CCV_W_WARP_ID-1:0]      warp_id;
  logic [ccv_params_pkg::CCV_W_LANE_MASK-1:0]    issue_mask;
  logic [2*ccv_prov_pkg::CCV_P_W_PHYS_REG-1:0]   phys_src;
  logic [ccv_prov_pkg::CCV_P_W_PHYS_REG-1:0]     phys_src2;
  logic [ccv_prov_pkg::CCV_P_W_PHYS_REG-1:0]     phys_dst;
  logic [ccv_prov_pkg::CCV_P_W_PHYS_PRED-1:0]    phys_pred_guard;
  logic                                          pred_neg;
  logic [ccv_prov_pkg::CCV_P_W_PHYS_PRED-1:0]    phys_pred_dst;
  logic                                          pred_we;
  logic [ccv_prelim_pkg::CCV_L_W_OPCODE-1:0]     opcode;
  logic [ccv_prov_pkg::CCV_P_W_IMM-1:0]          imm;
  logic [ccv_params_pkg::CCV_W_CHWIDTH-1:0]      chwidth;
  logic                                          dispatch_fault;
} ccv_ooe_rcu_issue_t;

// LEAD fields are driven with valid, one cycle ahead of the
// rest of the payload (schema lead_fields).
typedef struct packed {
  logic [ccv_prelim_pkg::CCV_L_W_OPCODE-1:0]     opcode;
  logic [ccv_prelim_pkg::CCV_L_OPERANDS_PER_LANE*ccv_params_pkg::CCV_W_LANE_DATA-1:0] operand;
  logic                                          pred_bit;  // LEAD
  logic                                          pred_data;  // LEAD
  logic [4-1:0]                                  section_en;  // LEAD
} ccv_rcu_lane_ops_t;

typedef struct packed {
  logic [ccv_params_pkg::CCV_W_LANE_DATA-1:0]    result;
  logic                                          pred_out;
  logic                                          lane_fault;
} ccv_lane_rcu_res_t;

typedef struct packed {
  logic [ccv_prov_pkg::CCV_P_W_ROB_TAG-1:0]      rob_tag;
  logic                                          exec_fault;
  logic                                          branch_taken;
  logic [ccv_params_pkg::CCV_W_LANE_MASK-1:0]    branch_mask;
  logic [ccv_params_pkg::CCV_W_LANE_MASK-1:0]    fault_lane_mask;
} ccv_rcu_ooe_done_t;

typedef struct packed {
  logic [ccv_prov_pkg::CCV_P_W_ROB_TAG-1:0]      rob_tag;
  logic [ccv_params_pkg::CCV_W_LANE_MASK-1:0]    active_mask;
  logic [ccv_params_pkg::CCV_W_VA-1:0]           base;
  logic [ccv_params_pkg::CCV_W_DATA-1:0]         index_per_lane;
  logic [ccv_params_pkg::CCV_W_DATA-1:0]         store_data;
} ccv_rcu_miu_addr_t;

typedef struct packed {
  logic [ccv_prov_pkg::CCV_P_W_ROB_TAG-1:0]      rob_tag;
  logic [ccv_params_pkg::CCV_W_LANE_MASK-1:0]    active_mask;
  logic [ccv_params_pkg::CCV_W_LANE_MASK-1:0]    pred_result;
  logic [ccv_prov_pkg::CCV_P_W_PHYS_REG-1:0]     phys_dst;
  logic [ccv_prov_pkg::CCV_P_W_PHYS_PRED-1:0]    phys_pred;
  logic                                          pred_we;
  logic [ccv_params_pkg::CCV_W_DATA-1:0]         load_data;
} ccv_miu_rcu_data_t;

typedef struct packed {
  logic [ccv_prov_pkg::CCV_P_W_ROB_TAG-1:0]      rob_tag;
  logic [ccv_prov_pkg::CCV_P_W_PHYS_REG-1:0]     phys_dst;
  logic [ccv_prov_pkg::CCV_P_W_PHYS_PRED-1:0]    phys_pred;
  logic [ccv_params_pkg::CCV_W_LANE_MASK-1:0]    issue_mask;
  logic [ccv_params_pkg::CCV_W_WARP_ID-1:0]      warp_id;
  logic [ccv_prov_pkg::CCV_P_W_CTA_SLOT-1:0]     cta_slot;
  logic [ccv_prelim_pkg::CCV_L_W_MEM_OP-1:0]     mem_op;
  logic [ccv_params_pkg::CCV_W_CHWIDTH-1:0]      chwidth;
  logic [ccv_params_pkg::CCV_W_DISP-1:0]         disp;
  logic                                          scale_en;
  logic [ccv_prelim_pkg::CCV_L_W_SPACE-1:0]      space;
  logic [ccv_prelim_pkg::CCV_L_W_ORDERING-1:0]   ordering;
} ccv_ooe_miu_memop_t;

typedef struct packed {
  logic [ccv_prov_pkg::CCV_P_W_ROB_TAG-1:0]      rob_tag;
  logic [ccv_params_pkg::CCV_W_STATUS-1:0]       status;
  logic [ccv_params_pkg::CCV_W_FAULT_CAUSE-1:0]  cause;
  logic [ccv_params_pkg::CCV_W_LANE_MASK-1:0]    lane_mask;
  logic [ccv_params_pkg::CCV_W_VA-1:0]           address;
  logic                                          mlc_miss;
} ccv_miu_ooe_cmpl_t;

typedef struct packed {
  logic [ccv_prov_pkg::CCV_P_W_ROB_TAG-1:0]      rob_tag;
  logic                                          commit_or_discard;
} ccv_ooe_miu_retire_t;

typedef struct packed {
  logic [ccv_params_pkg::CCV_W_WARP_ID-1:0]      warp_id;
  logic [ccv_params_pkg::CCV_W_TIER1_ID-1:0]     tier1_id;
  logic [ccv_params_pkg::CCV_W_VA-1:0]           target_pc;
  logic [ccv_prelim_pkg::CCV_L_PC_GROUPS*ccv_params_pkg::CCV_W_LANE_MASK-1:0] group_masks;
  logic [ccv_prov_pkg::CCV_P_W_FETCH_EPOCH-1:0]  fetch_epoch;
} ccv_ooe_fet_redirect_t;

typedef struct packed {
  logic [ccv_prov_pkg::CCV_P_W_REQ_MIU_SPM-1:0]  req_id;
  logic [ccv_params_pkg::CCV_SPM_BANKS*ccv_params_pkg::CCV_W_SPM_WORD-1:0] bank_addr;
  logic [ccv_params_pkg::CCV_W_DATA-1:0]         write_data;
  logic [ccv_params_pkg::CCV_W_DATA/8-1:0]       byte_mask;
  logic [ccv_prelim_pkg::CCV_L_W_SPM_OP-1:0]     spm_op;
} ccv_miu_spm_req_t;

typedef struct packed {
  logic [ccv_prov_pkg::CCV_P_W_REQ_MIU_SPM-1:0]  req_id;
  logic [ccv_params_pkg::CCV_W_DATA-1:0]         read_data;
  logic [ccv_params_pkg::CCV_W_CONFLICT_SER-1:0] conflict_serialization;
} ccv_spm_miu_rsp_t;

typedef struct packed {
  logic [ccv_prov_pkg::CCV_P_W_REQ_MIU_DCU-1:0]  req_id;
  logic [ccv_prov_pkg::CCV_P_W_PA-1:0]           phys_addr;
  logic [ccv_params_pkg::CCV_W_ACCESS_SIZE-1:0]  size;
  logic [ccv_prelim_pkg::CCV_L_W_COH_OP-1:0]     coh_op;
  logic                                          exclusive_req;
  logic [ccv_params_pkg::CCV_W_DATA-1:0]         write_data;
  logic [ccv_params_pkg::CCV_W_DATA/8-1:0]       byte_mask;
} ccv_miu_dcu_req_t;

typedef struct packed {
  logic [ccv_prov_pkg::CCV_P_W_REQ_MIU_DCU-1:0]  req_id;
  logic [ccv_params_pkg::CCV_W_DATA-1:0]         read_data;
  logic                                          hit;
  logic                                          ownership_granted;
} ccv_dcu_miu_rsp_t;

typedef struct packed {
  logic [ccv_prov_pkg::CCV_P_W_REQ_DCU_MLC-1:0]  req_id;
  logic [ccv_prov_pkg::CCV_P_W_PA-1:0]           phys_addr;
  logic [ccv_prelim_pkg::CCV_L_W_COH_OP-1:0]     coh_op;
  logic [ccv_params_pkg::CCV_W_CORE_ID-1:0]      core_id;
  logic [8*ccv_prov_pkg::CCV_P_LINE_BYTES-1:0]   writeback_data;
} ccv_dcu_mlc_req_t;

typedef struct packed {
  logic [ccv_prov_pkg::CCV_P_W_REQ_DCU_MLC-1:0]  req_id;
  logic [8*ccv_prov_pkg::CCV_P_LINE_BYTES-1:0]   line_data;
  logic                                          ownership;
  logic                                          miss;
} ccv_mlc_dcu_rsp_t;

typedef struct packed {
  logic [ccv_prov_pkg::CCV_P_W_REQ_MLC_PROBE-1:0] req_id;
  logic [ccv_prov_pkg::CCV_P_W_PA-1:0]           phys_addr;
  logic                                          invalidate_or_downgrade;
} ccv_mlc_dcu_probe_t;

typedef struct packed {
  logic [ccv_prov_pkg::CCV_P_W_REQ_MLC_PROBE-1:0] req_id;
  logic                                          ack;
  logic [8*ccv_prov_pkg::CCV_P_LINE_BYTES-1:0]   dirty_data;
} ccv_dcu_mlc_probe_ack_t;

typedef struct packed {
  logic [ccv_prov_pkg::CCV_P_W_REQ_FET_MLC-1:0]  req_id;
  logic [ccv_prov_pkg::CCV_P_W_PA-1:0]           phys_addr;
  logic [ccv_params_pkg::CCV_W_ASID-1:0]         asid;
} ccv_fet_mlc_ifill_t;

typedef struct packed {
  logic [ccv_prov_pkg::CCV_P_W_REQ_FET_MLC-1:0]  req_id;
  logic [8*ccv_prov_pkg::CCV_P_LINE_BYTES-1:0]   line_data;
} ccv_mlc_fet_ifill_rsp_t;

typedef struct packed {
  logic [ccv_prelim_pkg::CCV_L_W_ITLB_ENTRY-1:0] itlb_refill;
} ccv_miu_fet_itlb_t;

typedef struct packed {
  logic [ccv_params_pkg::CCV_W_VA-1:0]           virtual_page;
  logic [ccv_params_pkg::CCV_W_ASID-1:0]         asid;
} ccv_fet_miu_itlb_req_t;

typedef struct packed {
  logic [ccv_prov_pkg::CCV_P_W_REQ_MLC_EXB-1:0]  req_id;
  logic [ccv_prov_pkg::CCV_P_W_PA-1:0]           phys_addr;
  logic [ccv_params_pkg::CCV_W_ACCESS_SIZE-1:0]  size;
  logic [ccv_prelim_pkg::CCV_L_W_COH_OP-1:0]     coh_op;
  logic [ccv_prelim_pkg::CCV_L_W_OWNERSHIP-1:0]  ownership_class;
  logic [ccv_params_pkg::CCV_W_CORE_ID-1:0]      core_id;
  logic [8*ccv_prov_pkg::CCV_P_LINE_BYTES-1:0]   writeback_data;
} ccv_mlc_exb_req_t;

typedef struct packed {
  logic [ccv_prov_pkg::CCV_P_W_REQ_MLC_EXB-1:0]  req_id;
  logic [ccv_prelim_pkg::CCV_L_W_PROBE_TYPE-1:0] probe_type;
  logic [ccv_prov_pkg::CCV_P_W_PA-1:0]           phys_addr;
  logic [8*ccv_prov_pkg::CCV_P_LINE_BYTES-1:0]   line_data;
  logic                                          ownership_grant;
  logic                                          miss;
} ccv_exb_mlc_rsp_t;

typedef struct packed {
  logic [ccv_prelim_pkg::CCV_L_W_TL_OUT-1:0]     tl_out;
} ccv_exb_ext_out_t;

typedef struct packed {
  logic [ccv_params_pkg::CCV_W_WARP_ID-1:0]      warp_id;
  logic [ccv_params_pkg::CCV_W_VA-1:0]           start_pc;
  logic [2*(ccv_params_pkg::CCV_W_VA-ccv_prelim_pkg::CCV_L_PAGE_SHIFT)-1:0] code_bounds;
  logic [ccv_params_pkg::CCV_W_ASID-1:0]         asid;
  logic [ccv_prov_pkg::CCV_P_W_CTA_SLOT-1:0]     cta_slot;
} ccv_rau_fet_launch_t;

typedef struct packed {
  logic [ccv_params_pkg::CCV_W_WARP_ID-1:0]      warp_id;
  logic [ccv_prelim_pkg::CCV_L_W_PRF_BASE-1:0]   prf_base;
  logic [ccv_prelim_pkg::CCV_L_W_PRF_SIZE-1:0]   prf_size;
  logic                                          activate_or_free;
  logic [ccv_params_pkg::CCV_W_CTAID-1:0]        ctaid;
  logic [ccv_params_pkg::CCV_W_WARP_IN_CTA-1:0]  warp_in_cta;
} ccv_rau_ooe_alloc_t;

typedef struct packed {
  logic [ccv_params_pkg::CCV_W_WARP_ID-1:0]      warp_id;
  logic                                          fault_taken;
  logic                                          stalled;
  logic                                          mlc_miss_seen;
  logic [ccv_params_pkg::CCV_W_RETIRED_CNT-1:0]  retired_since_restore;
} ccv_ooe_rau_status_t;

typedef struct packed {
  logic [ccv_params_pkg::CCV_W_WARP_ID-1:0]      warp_id;
  logic                                          squash_to_retirement;
} ccv_rau_ooe_demote_t;

typedef struct packed {
  logic [ccv_params_pkg::CCV_W_WARP_ID-1:0]      warp_id;
  logic [ccv_params_pkg::CCV_W_VA-1:0]           resume_pc;
  logic                                          arch_state_ready;
} ccv_ooe_rau_drained_t;

typedef struct packed {
  logic [ccv_params_pkg::CCV_W_WARP_ID-1:0]      warp_id;
  logic                                          direction;
  logic [ccv_prelim_pkg::CCV_L_W_PCA_BANK-1:0]   bank_select;
} ccv_rau_rcu_mig_t;

typedef struct packed {
  logic [ccv_params_pkg::CCV_W_WARP_ID-1:0]      warp_id;
  logic [ccv_params_pkg::CCV_W_ARCH_REG-1:0]     row_idx;
  logic [ccv_params_pkg::CCV_W_DATA-1:0]         gpr_row;
  logic [ccv_prelim_pkg::CCV_L_W_PRED_STATE-1:0] pred_state;
} ccv_rcu_pca_mig_t;

typedef struct packed {
  logic [ccv_params_pkg::CCV_W_WARP_ID-1:0]      warp_id;
  logic [ccv_params_pkg::CCV_W_ARCH_REG-1:0]     row_idx;
  logic [ccv_params_pkg::CCV_W_DATA-1:0]         gpr_row;
  logic [ccv_prelim_pkg::CCV_L_W_PRED_STATE-1:0] pred_state;
} ccv_pca_rcu_mig_t;

typedef struct packed {
  logic [ccv_params_pkg::CCV_W_WARP_ID-1:0]      warp_id;
  logic [ccv_prelim_pkg::CCV_L_PC_GROUPS*ccv_params_pkg::CCV_W_VA-1:0] pcs;
} ccv_fet_pca_mig_t;

typedef struct packed {
  logic [ccv_params_pkg::CCV_W_WARP_ID-1:0]      warp_id;
  logic [ccv_prelim_pkg::CCV_L_PC_GROUPS*ccv_params_pkg::CCV_W_VA-1:0] pcs;
} ccv_pca_fet_mig_t;

typedef struct packed {
  logic [ccv_params_pkg::CCV_W_WARP_ID-1:0]      warp_id;
  logic                                          direction;
  logic [ccv_prelim_pkg::CCV_L_W_PCA_BANK-1:0]   bank_select;
} ccv_rau_fet_mig_t;

typedef struct packed {
  logic [ccv_params_pkg::CCV_W_WARP_ID-1:0]      warp_id;
} ccv_pca_rau_mig_done_t;

typedef struct packed {
  logic [ccv_prov_pkg::CCV_P_W_CTA_SLOT-1:0]     cta_slot;
  logic [ccv_params_pkg::CCV_W_SPM_ADDR-1:0]     spm_base;
  logic [ccv_params_pkg::CCV_W_SPM_ADDR-1:0]     spm_limit;
  logic [ccv_params_pkg::CCV_W_VA-1:0]           launch_block_addr;
} ccv_rau_miu_cta_t;

typedef struct packed {
  logic [ccv_params_pkg::CCV_W_WARP_ID-1:0]      warp_id;
  logic [ccv_prov_pkg::CCV_P_W_CTA_SLOT-1:0]     cta_slot;
  logic [ccv_params_pkg::CCV_W_BAR_ID-1:0]       barrier_id;
  logic                                          arrive_or_wait;
} ccv_ooe_syu_bar_t;

typedef struct packed {
  logic [ccv_params_pkg::CCV_W_LANE_MASK-1:0]    warp_mask_released;
  logic [ccv_params_pkg::CCV_W_BAR_ID-1:0]       barrier_id;
} ccv_syu_ooe_rel_t;

typedef struct packed {
  logic [ccv_prov_pkg::CCV_P_W_CTA_SLOT-1:0]     cta_slot;
  logic [ccv_params_pkg::CCV_W_BAR_ENTRY-1:0]    barrier_base;
  logic [ccv_prelim_pkg::CCV_L_W_BAR_COUNT-1:0]  barrier_count;
  logic                                          allocate_or_free;
} ccv_rau_syu_alloc_t;

typedef struct packed {
  logic [ccv_params_pkg::CCV_W_FAULT_CAUSE-1:0]  cause;
  logic [ccv_params_pkg::CCV_W_VA-1:0]           pc;
  logic [ccv_params_pkg::CCV_W_LANE_MASK-1:0]    lane_mask;
  logic [ccv_params_pkg::CCV_W_VA-1:0]           address;
  logic [ccv_prov_pkg::CCV_P_W_CTA_SLOT-1:0]     cta_slot;
  logic [ccv_params_pkg::CCV_W_WARP_ID-1:0]      warp_id;
} ccv_ooe_cru_fault_t;

typedef struct packed {
  logic [ccv_params_pkg::CCV_W_CSR-1:0]          demotion_threshold;
  logic [ccv_params_pkg::CCV_W_CSR-1:0]          progress_threshold;
  logic                                          launch_enable;
  logic                                          kill_req;
  logic [ccv_prelim_pkg::CCV_L_W_GRID_SEL-1:0]   kill_grid;
} ccv_cru_rau_cfg_t;

typedef struct packed {
  logic [ccv_prelim_pkg::CCV_L_W_TL_IN-1:0]      tl_in;
} ccv_ext_exb_in_t;

// Ports per block, derived from the channel list.
localparam int CCV_PORTS_CRU = 2;  // 1 in, 1 out
localparam int CCV_PORTS_DCU = 6;  // 3 in, 3 out
localparam int CCV_PORTS_DEC = 2;  // 1 in, 1 out
localparam int CCV_PORTS_EXB = 4;  // 2 in, 2 out
localparam int CCV_PORTS_FET = 10;  // 6 in, 4 out
localparam int CCV_PORTS_LANE = 2;  // 1 in, 1 out
localparam int CCV_PORTS_MIU = 12;  // 7 in, 5 out
localparam int CCV_PORTS_MLC = 8;  // 4 in, 4 out
localparam int CCV_PORTS_OOE = 14;  // 6 in, 8 out
localparam int CCV_PORTS_PCA = 5;  // 2 in, 3 out
localparam int CCV_PORTS_RAU = 11;  // 4 in, 7 out
localparam int CCV_PORTS_RCU = 9;  // 5 in, 4 out
localparam int CCV_PORTS_SPM = 2;  // 1 in, 1 out
localparam int CCV_PORTS_SYU = 3;  // 2 in, 1 out

/* verilator lint_on UNUSEDPARAM */

`endif // CCV_INTERFACES_SVH
