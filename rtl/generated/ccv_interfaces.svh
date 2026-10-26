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
//   core_clk         in   fan-in    The core clock, UNGATED -- the only clock a block receives.
//   rst_n            in   fan-in    Synchronous reset, ACTIVE LOW.
//   kill_valid       in   broadcast Grid teardown, one cycle ahead of the mask, broadcast by RAU to the eight blocks that own warp state (FET, DEC, OOE, RCU, MIU, SPM, SYU, PCA).
//   kill_warp_mask   in   broadcast Warps to discard, one bit per warp CONTEXT (CCV_WARP_CONTEXTS = 32: tier-1 and parked), driven by RAU.
//   kill_epoch       in   broadcast Epoch of the kill being broadcast.
//   kill_ack         out  gather    QUIESCED, not merely stopped: a block acks only when it holds no state for the killed warps AND has nothing in flight toward anyone else on their behalf.
//   kill_ack_epoch   out  gather    The kill_epoch this ack answers.
//   csr_req          in   star      Address, write data, write enable, from CRU, which owns the CSR fabric.
//   csr_rsp          out  star      Read data, done.
//   csr_credit       out  star      Credit return for the CSR channel.
//   clk_gated        out  observe   CCV_CHECK only: the block's clock gate is closed this cycle.

localparam int CCV_NUM_CHANNELS = 55;

// fet -> dec, 8/cycle
localparam int CCV_CH_FET_DEC_INSTR = 0;
// ooe -> fet, 4/cycle
localparam int CCV_CH_OOE_FET_DECQ_CREDIT = 1;
// dec -> ooe, 6/cycle
localparam int CCV_CH_DEC_OOE_UOP = 2;
// ooe -> rcu, 9/cycle
localparam int CCV_CH_OOE_RCU_ISSUE = 3;
// rcu -> lane, 1/cycle
localparam int CCV_CH_RCU_LANE_OPS = 4;
// lane -> rcu, 1/cycle
localparam int CCV_CH_LANE_RCU_RES = 5;
// rcu -> ooe, 7/cycle
localparam int CCV_CH_RCU_OOE_DONE = 6;
// rcu -> miu, 4/cycle
localparam int CCV_CH_RCU_MIU_ADDR = 7;
// miu -> rcu, 4/cycle
localparam int CCV_CH_MIU_RCU_DATA = 8;
// ooe -> miu, 4/cycle
localparam int CCV_CH_OOE_MIU_MEMOP = 9;
// miu -> ooe, 4/cycle
localparam int CCV_CH_MIU_OOE_CMPL = 10;
// ooe -> miu, 4/cycle
localparam int CCV_CH_OOE_MIU_RETIRE = 11;
// ooe -> fet, 1/cycle
localparam int CCV_CH_OOE_FET_REDIRECT = 12;
// ooe -> fet, 1/cycle
localparam int CCV_CH_OOE_FET_CKPT_FREE = 13;
// miu -> spm, 4/cycle
localparam int CCV_CH_MIU_SPM_REQ = 14;
// spm -> miu, 4/cycle
localparam int CCV_CH_SPM_MIU_RSP = 15;
// miu -> dcu, 4/cycle
localparam int CCV_CH_MIU_DCU_REQ = 16;
// dcu -> miu, 4/cycle
localparam int CCV_CH_DCU_MIU_RSP = 17;
// dcu -> mlc, 1/cycle
localparam int CCV_CH_DCU_MLC_REQ = 18;
// mlc -> dcu, 1/cycle
localparam int CCV_CH_MLC_DCU_RSP = 19;
// mlc -> dcu, 1/cycle
localparam int CCV_CH_MLC_DCU_PROBE = 20;
// dcu -> mlc, 1/cycle
localparam int CCV_CH_DCU_MLC_PROBE_ACK = 21;
// fet -> mlc, 1/cycle
localparam int CCV_CH_FET_MLC_IFILL = 22;
// mlc -> fet, 1/cycle
localparam int CCV_CH_MLC_FET_IFILL_RSP = 23;
// miu -> fet, 1/cycle
localparam int CCV_CH_MIU_FET_ITLB = 24;
// fet -> miu, 1/cycle
localparam int CCV_CH_FET_MIU_ITLB_REQ = 25;
// mlc -> exb, 1/cycle
localparam int CCV_CH_MLC_EXB_REQ = 26;
// exb -> mlc, 1/cycle
localparam int CCV_CH_EXB_MLC_RSP = 27;
// exb -> EXTERNAL, 1/cycle
localparam int CCV_CH_EXB_EXT_OUT = 28;
// rau -> fet, 1/cycle
localparam int CCV_CH_RAU_FET_LAUNCH = 29;
// rau -> ooe, 1/cycle
localparam int CCV_CH_RAU_OOE_ALLOC = 30;
// ooe -> rau, 1/cycle
localparam int CCV_CH_OOE_RAU_STATUS = 31;
// rau -> ooe, 1/cycle
localparam int CCV_CH_RAU_OOE_DEMOTE = 32;
// ooe -> rau, 1/cycle
localparam int CCV_CH_OOE_RAU_DRAINED = 33;
// rau -> rcu, 1/cycle
localparam int CCV_CH_RAU_RCU_MIG = 34;
// ooe -> rcu, 1/cycle
localparam int CCV_CH_OOE_RCU_MAP = 35;
// rcu -> pca, 1/cycle
localparam int CCV_CH_RCU_PCA_MIG = 36;
// pca -> rcu, 1/cycle
localparam int CCV_CH_PCA_RCU_MIG = 37;
// fet -> pca, 1/cycle
localparam int CCV_CH_FET_PCA_MIG = 38;
// pca -> fet, 1/cycle
localparam int CCV_CH_PCA_FET_MIG = 39;
// rau -> fet, 1/cycle
localparam int CCV_CH_RAU_FET_MIG = 40;
// pca -> rau, 1/cycle
localparam int CCV_CH_PCA_RAU_MIG_DONE = 41;
// rau -> pca, 1/cycle
localparam int CCV_CH_RAU_PCA_MIG = 42;
// miu -> rau, 1/cycle
localparam int CCV_CH_MIU_RAU_READY = 43;
// rau -> miu, 1/cycle
localparam int CCV_CH_RAU_MIU_CTA = 44;
// ooe -> syu, 1/cycle
localparam int CCV_CH_OOE_SYU_BAR = 45;
// syu -> ooe, 1/cycle
localparam int CCV_CH_SYU_OOE_REL = 46;
// syu -> fet, 1/cycle
localparam int CCV_CH_SYU_FET_REL = 47;
// syu -> rau, 1/cycle
localparam int CCV_CH_SYU_RAU_READY = 48;
// rau -> syu, 1/cycle
localparam int CCV_CH_RAU_SYU_ALLOC = 49;
// ooe -> cru, 1/cycle
localparam int CCV_CH_OOE_CRU_FAULT = 50;
// cru -> rau, 1/cycle
localparam int CCV_CH_CRU_RAU_CFG = 51;
// EXTERNAL -> exb, 1/cycle
localparam int CCV_CH_EXT_EXB_IN = 52;
// dcu -> miu, 4/cycle
localparam int CCV_CH_DCU_MIU_FILL_NTC = 53;
// miu -> ooe, 4/cycle
localparam int CCV_CH_MIU_OOE_CMPL_HINT = 54;

// Payload structs, for channels whose every field has a
// decided width. A channel missing one generates no struct --
// see the list at the end of this file.

typedef struct packed {
  logic [ccv_params_pkg::CCV_W_WARP_ID-1:0]      warp_id;
  logic [ccv_params_pkg::CCV_W_TIER1_ID-1:0]     tier1_id;
  logic [ccv_params_pkg::CCV_W_VA-1:0]           pc;
  logic [ccv_params_pkg::CCV_W_LANE_MASK-1:0]    group_mask;
  logic [ccv_prov_pkg::CCV_P_W_FETCH_EPOCH-1:0]  fetch_epoch;
  logic [ccv_params_pkg::CCV_W_INSTR-1:0]        instr;
  logic [ccv_params_pkg::CCV_W_ILEN-1:0]         length;
  logic [ccv_prov_pkg::CCV_P_W_CKPT_ID-1:0]      checkpoint_id;
  logic                                          pred_taken;
  logic                                          fetch_fault;
  logic                                          final_exit;
  logic                                          all_waiting;
} ccv_fet_dec_instr_t;

typedef struct packed {
  logic [ccv_params_pkg::CCV_W_TIER1_ID-1:0]     tier1_id;
  logic [ccv_prov_pkg::CCV_W_DECQ_CREDIT-1:0]    credit_count;
  logic                                          released;
} ccv_ooe_fet_decq_credit_t;

typedef struct packed {
  logic [ccv_params_pkg::CCV_W_WARP_ID-1:0]      warp_id;
  logic [ccv_params_pkg::CCV_W_VA-1:0]           pc;
  logic [ccv_params_pkg::CCV_W_LANE_MASK-1:0]    group_mask;
  logic [ccv_prov_pkg::CCV_P_W_FETCH_EPOCH-1:0]  fetch_epoch;
  logic [ccv_prelim_pkg::CCV_L_W_CLASS-1:0]      uop_class;
  logic [ccv_prelim_pkg::CCV_P_W_SCHED_ATTR-1:0] sched_attr;
  logic [ccv_prelim_pkg::CCV_L_W_MEM_OP-1:0]     mem_op;
  logic [ccv_params_pkg::CCV_L_W_SPACE-1:0]      space;
  logic [ccv_params_pkg::CCV_L_W_ORDERING-1:0]   ordering;
  logic [ccv_prelim_pkg::CCV_L_W_OPCODE-1:0]     opcode;
  logic [2*ccv_params_pkg::CCV_W_ARCH_REG-1:0]   src_arch;
  logic [ccv_params_pkg::CCV_W_ARCH_REG-1:0]     src2_arch;
  logic [ccv_params_pkg::CCV_W_ARCH_REG-1:0]     dst_arch;
  logic [ccv_params_pkg::CCV_W_ARCH_PRED-1:0]    pred_guard;
  logic                                          pred_neg;
  logic [ccv_params_pkg::CCV_W_ARCH_PRED-1:0]    pred_dst;
  logic                                          pred_we;
  logic [3-1:0]                                  src_valid;
  logic [2-1:0]                                  pred_use;
  logic [3-1:0]                                  imm_kind;
  logic [ccv_prov_pkg::CCV_P_W_IMM-1:0]          imm;
  logic [ccv_params_pkg::CCV_W_ILEN-1:0]         ilen;
  logic [ccv_prov_pkg::CCV_P_W_CKPT_ID-1:0]      checkpoint_id;
  logic                                          pred_taken;
  logic                                          scale_en;
  logic [ccv_params_pkg::CCV_W_FAULT_CAUSE-1:0]  cause;
  logic [2**ccv_params_pkg::CCV_W_CHWIDTH-1:0]   fmt_rsv;
  logic [2-1:0]                                  fmt_opnd;
  logic                                          final_exit;
  logic                                          all_waiting;
  logic                                          slot_form;
  logic [4-1:0]                                  arg_slot;
  logic                                          local_form;
  logic [2-1:0]                                  xfer_size;
  logic                                          xfer_signed;
} ccv_dec_ooe_uop_t;

typedef struct packed {
  logic [ccv_prov_pkg::CCV_P_W_ROB_TAG-1:0]      rob_tag;
  logic [ccv_params_pkg::CCV_W_WARP_ID-1:0]      warp_id;
  logic [ccv_params_pkg::CCV_W_LANE_MASK-1:0]    issue_mask;
  logic [2*ccv_prov_pkg::CCV_P_W_PHYS_REG-1:0]   phys_src;
  logic [ccv_prov_pkg::CCV_P_W_PHYS_REG-1:0]     phys_src2;
  logic [ccv_prov_pkg::CCV_P_W_PHYS_REG-1:0]     phys_dst;
  logic [ccv_prov_pkg::CCV_P_W_PHYS_REG-1:0]     phys_old_dst;
  logic [ccv_prov_pkg::CCV_P_W_PHYS_PRED-1:0]    phys_pred_guard;
  logic                                          pred_neg;
  logic [ccv_prov_pkg::CCV_P_W_PHYS_PRED-1:0]    phys_pred_dst;
  logic [ccv_prov_pkg::CCV_P_W_PHYS_PRED-1:0]    phys_pred_old_dst;
  logic                                          pred_we;
  logic                                          merge_en;
  logic                                          cont;
  logic [ccv_params_pkg::CCV_SECTIONS-1:0]       footprint;
  logic [ccv_prelim_pkg::CCV_P_W_BYP_GROUP-1:0]  bypass_group;
  logic [3*ccv_params_pkg::CCV_W_PHYS_POS-1:0]   src_pos;
  logic [3*ccv_params_pkg::CCV_W_CHWIDTH-1:0]    src_width;
  logic [ccv_params_pkg::CCV_W_PHYS_POS-1:0]     dst_pos;
  logic [ccv_params_pkg::CCV_W_PHYS_POS-1:0]     old_dst_pos;
  logic [ccv_params_pkg::CCV_W_CHWIDTH-1:0]      dst_width;
  logic [ccv_prelim_pkg::CCV_L_W_OPCODE-1:0]     opcode;
  logic [ccv_prov_pkg::CCV_P_W_IMM-1:0]          imm;
  logic [ccv_params_pkg::CCV_W_CHWIDTH-1:0]      chwidth;
  logic                                          dispatch_fault;
} ccv_ooe_rcu_issue_t;

// LEAD fields are driven with valid, one cycle ahead of the
// rest of the payload (schema lead_fields).
typedef struct packed {
  logic [ccv_params_pkg::CCV_SECTIONS*ccv_prelim_pkg::CCV_L_W_OPCODE-1:0] sec_opcode;
  logic [ccv_prelim_pkg::CCV_L_OPERANDS_PER_LANE*ccv_params_pkg::CCV_W_LANE_DATA-1:0] operand;
  logic [ccv_params_pkg::CCV_W_LANE_DATA-1:0]    merge_data;
  logic [ccv_params_pkg::CCV_SECTIONS-1:0]       section_en;  // LEAD
  logic [ccv_params_pkg::CCV_SECTIONS*ccv_params_pkg::CCV_W_PHYS_POS-1:0] sec_owner;
  logic [ccv_params_pkg::CCV_SECTIONS-1:0]       sec_pred_bit;  // LEAD
  logic [ccv_params_pkg::CCV_SECTIONS-1:0]       sec_pred_data;
  logic [ccv_params_pkg::CCV_SECTIONS*(ccv_prelim_pkg::CCV_L_OPERANDS_PER_LANE+1)*ccv_params_pkg::CCV_W_PHYS_POS-1:0] sec_opnd_pos;
  logic [ccv_params_pkg::CCV_SECTIONS*(ccv_prelim_pkg::CCV_L_OPERANDS_PER_LANE+1)*ccv_params_pkg::CCV_W_CHWIDTH-1:0] sec_opnd_width;
  logic [ccv_params_pkg::CCV_SECTIONS*ccv_params_pkg::CCV_W_PHYS_POS-1:0] sec_dst_pos;
  logic [ccv_params_pkg::CCV_SECTIONS*ccv_params_pkg::CCV_W_CHWIDTH-1:0] sec_dst_width;
  logic [ccv_params_pkg::CCV_SECTIONS*(ccv_prelim_pkg::CCV_L_OPERANDS_PER_LANE+1)*ccv_prov_pkg::CCV_P_W_LANE_BYP_SEL-1:0] operand_byp;
} ccv_rcu_lane_ops_t;

typedef struct packed {
  logic [ccv_params_pkg::CCV_W_LANE_DATA-1:0]    result;
  logic [ccv_params_pkg::CCV_SECTIONS-1:0]       sec_valid;
  logic [ccv_params_pkg::CCV_SECTIONS-1:0]       sec_pred_out;
} ccv_lane_rcu_res_t;

typedef struct packed {
  logic [ccv_prov_pkg::CCV_P_W_ROB_TAG-1:0]      rob_tag;
  logic                                          branch_taken;
  logic [ccv_params_pkg::CCV_W_LANE_MASK-1:0]    branch_mask;
  logic [32-1:0]                                 aux;
} ccv_rcu_ooe_done_t;

typedef struct packed {
  logic [ccv_prov_pkg::CCV_P_W_ROB_TAG-1:0]      rob_tag;
  logic [ccv_params_pkg::CCV_W_LANE_MASK-1:0]    active_mask;
  logic [ccv_params_pkg::CCV_W_DATA-1:0]         base_per_lane;
  logic [ccv_params_pkg::CCV_W_DATA-1:0]         index_per_lane;
  logic [ccv_params_pkg::CCV_W_DATA-1:0]         store_data;
} ccv_rcu_miu_addr_t;

typedef struct packed {
  logic [ccv_prov_pkg::CCV_P_W_ROB_TAG-1:0]      rob_tag;
  logic [ccv_params_pkg::CCV_W_LANE_MASK-1:0]    active_mask;
  logic [ccv_params_pkg::CCV_W_LANE_MASK-1:0]    pred_result;
  logic [ccv_prov_pkg::CCV_P_W_PHYS_REG-1:0]     phys_dst;
  logic [ccv_params_pkg::CCV_W_PHYS_POS-1:0]     dst_pos;
  logic [ccv_params_pkg::CCV_W_CHWIDTH-1:0]      dst_width;
  logic [ccv_prov_pkg::CCV_P_W_PHYS_PRED-1:0]    phys_pred;
  logic                                          pred_we;
  logic [ccv_params_pkg::CCV_W_DATA-1:0]         load_data;
} ccv_miu_rcu_data_t;

typedef struct packed {
  logic [ccv_prov_pkg::CCV_P_W_ROB_TAG-1:0]      rob_tag;
  logic [ccv_prov_pkg::CCV_P_W_RS_IDX-1:0]       rs_idx;
  logic [ccv_prov_pkg::CCV_P_W_PHYS_REG-1:0]     phys_dst;
  logic [ccv_params_pkg::CCV_W_PHYS_POS-1:0]     dst_pos;
  logic [ccv_prov_pkg::CCV_P_W_PHYS_PRED-1:0]    phys_pred;
  logic [ccv_params_pkg::CCV_W_LANE_MASK-1:0]    issue_mask;
  logic [ccv_params_pkg::CCV_W_WARP_ID-1:0]      warp_id;
  logic [ccv_prov_pkg::CCV_P_W_CTA_SLOT-1:0]     cta_slot;
  logic [ccv_prelim_pkg::CCV_L_W_MEM_OP-1:0]     mem_op;
  logic [ccv_params_pkg::CCV_W_CHWIDTH-1:0]      chwidth;
  logic [ccv_params_pkg::CCV_MIU_PIPES-1:0]      pipes;
  logic [ccv_params_pkg::CCV_W_DISP-1:0]         disp;
  logic                                          scale_en;
  logic [ccv_params_pkg::CCV_L_W_SPACE-1:0]      space;
  logic [ccv_params_pkg::CCV_L_W_ORDERING-1:0]   ordering;
  logic                                          slot_form;
  logic [4-1:0]                                  arg_slot;
  logic                                          local_form;
  logic [2-1:0]                                  xfer_size;
  logic                                          xfer_signed;
} ccv_ooe_miu_memop_t;
// OVERLAY discard_tail: disp[0 +: CCV_P_W_ROB_IDX], valid only when mem_op == 0xF.
localparam int CCV_OOE_MIU_MEMOP_DISCARD_TAIL_LSB = 0;
localparam int CCV_OOE_MIU_MEMOP_DISCARD_TAIL_W = ccv_prov_pkg::CCV_P_W_ROB_IDX;

typedef struct packed {
  logic [ccv_prov_pkg::CCV_P_W_ROB_TAG-1:0]      rob_tag;
  logic [ccv_prov_pkg::CCV_P_W_RS_IDX-1:0]       rs_idx;
  logic [ccv_params_pkg::CCV_W_STATUS-1:0]       status;
  logic [ccv_params_pkg::CCV_W_FAULT_CAUSE-1:0]  cause;
  logic [ccv_params_pkg::CCV_W_LANE_MASK-1:0]    lane_mask;
  logic [ccv_params_pkg::CCV_W_VA-1:0]           address;
  logic                                          mlc_miss;
  logic                                          more;
} ccv_miu_ooe_cmpl_t;

typedef struct packed {
  logic [ccv_prov_pkg::CCV_P_W_ROB_TAG-1:0]      rob_tag;
  logic                                          commit_or_discard;
} ccv_ooe_miu_retire_t;

typedef struct packed {
  logic [ccv_params_pkg::CCV_W_WARP_ID-1:0]      warp_id;
  logic [ccv_params_pkg::CCV_W_TIER1_ID-1:0]     tier1_id;
  logic [ccv_prov_pkg::CCV_P_W_CKPT_ID-1:0]      checkpoint_id;
  logic [ccv_params_pkg::CCV_W_LANE_MASK-1:0]    taken_mask;
  logic [ccv_params_pkg::CCV_W_VA-1:0]           target_pc;
  logic [ccv_prov_pkg::CCV_P_W_FETCH_EPOCH-1:0]  fetch_epoch;
  logic                                          epoch_only;
  logic                                          rewind;
  logic                                          rewind_held;
  logic                                          held_long;
  logic                                          own_pc;
  logic                                          stay;
} ccv_ooe_fet_redirect_t;

typedef struct packed {
  logic [ccv_params_pkg::CCV_TIER1_WARPS*ccv_prov_pkg::CCV_P_BR_CKPTS-1:0] free_mask;
} ccv_ooe_fet_ckpt_free_t;

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
  logic                                          mlc_miss;
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
} ccv_fet_mlc_ifill_t;

typedef struct packed {
  logic [ccv_prov_pkg::CCV_P_W_REQ_FET_MLC-1:0]  req_id;
  logic [8*ccv_prov_pkg::CCV_P_LINE_BYTES-1:0]   line_data;
} ccv_mlc_fet_ifill_rsp_t;

typedef struct packed {
  logic [ccv_prelim_pkg::CCV_L_W_ITLB_ENTRY-1:0] itlb_refill;
} ccv_miu_fet_itlb_t;

typedef struct packed {
  logic [ccv_params_pkg::CCV_W_VA-ccv_prelim_pkg::CCV_L_PAGE_SHIFT-1:0] virtual_page;
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
  logic [ccv_params_pkg::CCV_W_TIER1_ID-1:0]     tier1_id;
  logic [ccv_params_pkg::CCV_W_VA-1:0]           start_pc;
  logic [2*(ccv_params_pkg::CCV_W_VA-ccv_prelim_pkg::CCV_L_PAGE_SHIFT)-1:0] code_bounds;
  logic [ccv_params_pkg::CCV_W_ASID-1:0]         asid;
  logic [ccv_prov_pkg::CCV_P_W_CTA_SLOT-1:0]     cta_slot;
  logic [ccv_params_pkg::CCV_W_LANE_MASK-1:0]    live_mask;
} ccv_rau_fet_launch_t;

typedef struct packed {
  logic [ccv_params_pkg::CCV_W_WARP_ID-1:0]      warp_id;
  logic [ccv_params_pkg::CCV_W_TIER1_ID-1:0]     tier1_id;
  logic [2-1:0]                                  alloc_op;
  logic [ccv_params_pkg::CCV_W_CTAID-1:0]        ctaid;
  logic [ccv_params_pkg::CCV_W_WARP_IN_CTA-1:0]  warp_in_cta;
  logic [ccv_params_pkg::CCV_L_W_BAR_COUNT-1:0]  barrier_count;
  logic [ccv_prov_pkg::CCV_P_W_CTA_SLOT-1:0]     cta_slot;
} ccv_rau_ooe_alloc_t;

typedef struct packed {
  logic [ccv_params_pkg::CCV_W_WARP_ID-1:0]      warp_id;
  logic                                          fault_taken;
  logic                                          stalled;
  logic                                          mlc_miss_seen;
  logic [ccv_params_pkg::CCV_W_RETIRED_CNT-1:0]  retired_since_restore;
  logic                                          exited;
} ccv_ooe_rau_status_t;

typedef struct packed {
  logic [ccv_params_pkg::CCV_W_WARP_ID-1:0]      warp_id;
  logic                                          squash_to_retirement;
} ccv_rau_ooe_demote_t;

typedef struct packed {
  logic [ccv_params_pkg::CCV_W_WARP_ID-1:0]      warp_id;
  logic [ccv_params_pkg::CCV_W_VA-1:0]           resume_pc;
  logic                                          arch_state_ready;
  logic                                          refused;
} ccv_ooe_rau_drained_t;

typedef struct packed {
  logic [ccv_params_pkg::CCV_W_WARP_ID-1:0]      warp_id;
  logic                                          direction;
} ccv_rau_rcu_mig_t;

typedef struct packed {
  logic [ccv_params_pkg::CCV_W_WARP_ID-1:0]      warp_id;
  logic                                          direction;
  logic [ccv_params_pkg::CCV_GPRS*ccv_prov_pkg::CCV_P_W_PHYS_REG-1:0] gpr_map;
  logic [ccv_params_pkg::CCV_GPRS*ccv_params_pkg::CCV_W_PHYS_POS-1:0] gpr_pos;
  logic [ccv_params_pkg::CCV_GPRS*ccv_params_pkg::CCV_W_CHWIDTH-1:0] gpr_width;
  logic [ccv_params_pkg::CCV_PREDS*ccv_prov_pkg::CCV_P_W_PHYS_PRED-1:0] pred_map;
} ccv_ooe_rcu_map_t;

typedef struct packed {
  logic [ccv_params_pkg::CCV_W_WARP_ID-1:0]      warp_id;
  logic [ccv_params_pkg::CCV_W_MIG_ROW-1:0]      mig_row;
  logic [ccv_params_pkg::CCV_W_DATA-1:0]         row_data;
} ccv_rcu_pca_mig_t;

typedef struct packed {
  logic [ccv_params_pkg::CCV_W_WARP_ID-1:0]      warp_id;
  logic [ccv_params_pkg::CCV_W_MIG_ROW-1:0]      mig_row;
  logic [ccv_params_pkg::CCV_W_DATA-1:0]         row_data;
} ccv_pca_rcu_mig_t;

typedef struct packed {
  logic [ccv_params_pkg::CCV_W_WARP_ID-1:0]      warp_id;
  logic [ccv_params_pkg::CCV_WARP_LANES*ccv_params_pkg::CCV_W_LANE_PC-1:0] lane_pcs;
  logic [ccv_params_pkg::CCV_W_PC_UPPER-1:0]     pc_upper;
  logic [ccv_params_pkg::CCV_W_FAIR_PTR-1:0]     fair_ptr;
  logic [ccv_prov_pkg::CCV_W_FAIR_CNT-1:0]       fair_cnt;
  logic [ccv_params_pkg::CCV_W_LANE_MASK-1:0]    live_mask;
} ccv_fet_pca_mig_t;

typedef struct packed {
  logic [ccv_params_pkg::CCV_W_WARP_ID-1:0]      warp_id;
  logic [ccv_params_pkg::CCV_WARP_LANES*ccv_params_pkg::CCV_W_LANE_PC-1:0] lane_pcs;
  logic [ccv_params_pkg::CCV_W_PC_UPPER-1:0]     pc_upper;
  logic [ccv_params_pkg::CCV_W_FAIR_PTR-1:0]     fair_ptr;
  logic [ccv_prov_pkg::CCV_W_FAIR_CNT-1:0]       fair_cnt;
  logic [ccv_params_pkg::CCV_W_LANE_MASK-1:0]    live_mask;
} ccv_pca_fet_mig_t;

typedef struct packed {
  logic [ccv_params_pkg::CCV_W_WARP_ID-1:0]      warp_id;
  logic [ccv_params_pkg::CCV_W_TIER1_ID-1:0]     tier1_id;
  logic                                          direction;
} ccv_rau_fet_mig_t;

typedef struct packed {
  logic [ccv_params_pkg::CCV_W_WARP_ID-1:0]      warp_id;
  logic                                          direction;
} ccv_pca_rau_mig_done_t;

typedef struct packed {
  logic [ccv_params_pkg::CCV_W_WARP_ID-1:0]      warp_id;
  logic                                          direction;
  logic [ccv_params_pkg::CCV_W_PCA_PLACE-1:0]    pca_place;
} ccv_rau_pca_mig_t;

typedef struct packed {
  logic [ccv_params_pkg::CCV_W_WARP_ID-1:0]      warp_id;
} ccv_miu_rau_ready_t;

typedef struct packed {
  logic [ccv_prov_pkg::CCV_P_W_CTA_SLOT-1:0]     cta_slot;
  logic [ccv_params_pkg::CCV_W_SPM_ADDR-1:0]     spm_base;
  logic [ccv_params_pkg::CCV_W_SPM_ADDR-1:0]     spm_limit;
  logic [ccv_params_pkg::CCV_W_VA-1:0]           launch_block_addr;
  logic [ccv_params_pkg::CCV_W_VA-1:0]           const_base;
  logic [ccv_params_pkg::CCV_W_VA-1:0]           const_limit;
} ccv_rau_miu_cta_t;

typedef struct packed {
  logic [ccv_params_pkg::CCV_W_WARP_ID-1:0]      warp_id;
  logic [ccv_prov_pkg::CCV_P_W_CTA_SLOT-1:0]     cta_slot;
  logic [ccv_params_pkg::CCV_W_BAR_ID-1:0]       barrier_id;
  logic [2-1:0]                                  bar_kind;
  logic [ccv_params_pkg::CCV_W_LANE_MASK-1:0]    issue_mask;
  logic [ccv_params_pkg::CCV_W_LANE_MASK-1:0]    guard_mask;
  logic [ccv_params_pkg::CCV_W_LANE_MASK-1:0]    phase_mask;
  logic                                          held;
} ccv_ooe_syu_bar_t;

typedef struct packed {
  logic [ccv_params_pkg::CCV_W_WARP_ID-1:0]      warp_id;
} ccv_syu_ooe_rel_t;

typedef struct packed {
  logic [ccv_params_pkg::CCV_W_WARP_ID-1:0]      warp_id;
  logic [ccv_params_pkg::CCV_W_LANE_MASK-1:0]    lane_mask;
} ccv_syu_fet_rel_t;

typedef struct packed {
  logic [ccv_params_pkg::CCV_W_WARP_ID-1:0]      warp_id;
} ccv_syu_rau_ready_t;

typedef struct packed {
  logic [ccv_prov_pkg::CCV_P_W_CTA_SLOT-1:0]     cta_slot;
  logic [ccv_params_pkg::CCV_W_BAR_ENTRY-1:0]    barrier_base;
  logic [ccv_params_pkg::CCV_L_W_BAR_COUNT-1:0]  barrier_count;
  logic [2-1:0]                                  syu_alloc_op;
  logic [ccv_params_pkg::CCV_WARP_CONTEXTS-1:0]  warp_mask;
  logic [ccv_params_pkg::CCV_W_WARP_ID-1:0]      warp_id;
  logic [ccv_params_pkg::CCV_W_LANE_IDX-1:0]     last_lanes;
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

typedef struct packed {
  logic [ccv_prov_pkg::CCV_P_W_REQ_MIU_DCU-1:0]  req_id;
} ccv_dcu_miu_fill_ntc_t;

typedef struct packed {
  logic [ccv_prov_pkg::CCV_P_W_RS_IDX-1:0]       rs_idx;
  logic [ccv_prov_pkg::CCV_P_W_ROB_TAG-1:0]      rob_tag;
} ccv_miu_ooe_cmpl_hint_t;

// Ports per block, derived from the channel list.
localparam int CCV_PORTS_CRU = 2;  // 1 in, 1 out
localparam int CCV_PORTS_DCU = 7;  // 3 in, 4 out
localparam int CCV_PORTS_DEC = 2;  // 1 in, 1 out
localparam int CCV_PORTS_EXB = 4;  // 2 in, 2 out
localparam int CCV_PORTS_FET = 13;  // 9 in, 4 out
localparam int CCV_PORTS_LANE = 2;  // 1 in, 1 out
localparam int CCV_PORTS_MIU = 15;  // 8 in, 7 out
localparam int CCV_PORTS_MLC = 8;  // 4 in, 4 out
localparam int CCV_PORTS_OOE = 18;  // 7 in, 11 out
localparam int CCV_PORTS_PCA = 6;  // 3 in, 3 out
localparam int CCV_PORTS_RAU = 14;  // 6 in, 8 out
localparam int CCV_PORTS_RCU = 10;  // 6 in, 4 out
localparam int CCV_PORTS_SPM = 2;  // 1 in, 1 out
localparam int CCV_PORTS_SYU = 5;  // 2 in, 3 out

/* verilator lint_on UNUSEDPARAM */

`endif // CCV_INTERFACES_SVH
