// GENERATED FILE -- DO NOT EDIT.
//
// Produced by tools/gen-skel.py from schema/interfaces.json,
// params/blocks.json and params/ccv_params.json. Edit a source and
// regenerate; tools/verify.sh fails if this file is stale.


`include "ccv_interfaces.svh"

module tb_layout_probe (
  input  logic [161:0] c0,
  output logic [4:0] c0_f0,
  output logic [1:0] c0_f1,
  output logic [63:0] c0_f2,
  output logic [31:0] c0_f3,
  output logic [2:0] c0_f4,
  output logic [47:0] c0_f5,
  output logic [1:0] c0_f6,
  output logic [1:0] c0_f7,
  output logic c0_f8,
  output logic c0_f9,
  output logic c0_f10,
  output logic c0_f11,
  input  logic [6:0] c1,
  output logic [1:0] c1_f0,
  output logic [3:0] c1_f1,
  output logic c1_f2,
  input  logic [235:0] c2,
  output logic [4:0] c2_f0,
  output logic [63:0] c2_f1,
  output logic [31:0] c2_f2,
  output logic [2:0] c2_f3,
  output logic [2:0] c2_f4,
  output logic [20:0] c2_f5,
  output logic [3:0] c2_f6,
  output logic c2_f7,
  output logic [4:0] c2_f8,
  output logic [8:0] c2_f9,
  output logic [7:0] c2_f10,
  output logic [3:0] c2_f11,
  output logic [3:0] c2_f12,
  output logic [1:0] c2_f13,
  output logic c2_f14,
  output logic [1:0] c2_f15,
  output logic c2_f16,
  output logic [2:0] c2_f17,
  output logic [1:0] c2_f18,
  output logic [2:0] c2_f19,
  output logic [31:0] c2_f20,
  output logic [1:0] c2_f21,
  output logic [1:0] c2_f22,
  output logic c2_f23,
  output logic c2_f24,
  output logic [3:0] c2_f25,
  output logic [3:0] c2_f26,
  output logic [1:0] c2_f27,
  output logic c2_f28,
  output logic c2_f29,
  output logic c2_f30,
  output logic [3:0] c2_f31,
  output logic c2_f32,
  output logic [1:0] c2_f33,
  output logic c2_f34,
  input  logic [176:0] c3,
  output logic [6:0] c3_f0,
  output logic [1:0] c3_f1,
  output logic [4:0] c3_f2,
  output logic [31:0] c3_f3,
  output logic [15:0] c3_f4,
  output logic [7:0] c3_f5,
  output logic [7:0] c3_f6,
  output logic [7:0] c3_f7,
  output logic [5:0] c3_f8,
  output logic c3_f9,
  output logic [5:0] c3_f10,
  output logic [5:0] c3_f11,
  output logic c3_f12,
  output logic c3_f13,
  output logic c3_f14,
  output logic [3:0] c3_f15,
  output logic [2:0] c3_f16,
  output logic [5:0] c3_f17,
  output logic [5:0] c3_f18,
  output logic [1:0] c3_f19,
  output logic [1:0] c3_f20,
  output logic [1:0] c3_f21,
  output logic [8:0] c3_f22,
  output logic [31:0] c3_f23,
  output logic [1:0] c3_f24,
  output logic c3_f25,
  input  logic [343:0] c4,
  output logic [35:0] c4_f0,
  output logic [95:0] c4_f1,
  output logic [31:0] c4_f2,
  output logic [3:0] c4_f3,
  output logic [7:0] c4_f4,
  output logic [3:0] c4_f5,
  output logic [3:0] c4_f6,
  output logic [31:0] c4_f7,
  output logic [31:0] c4_f8,
  output logic [7:0] c4_f9,
  output logic [7:0] c4_f10,
  output logic [79:0] c4_f11,
  input  logic [39:0] c5,
  output logic [31:0] c5_f0,
  output logic [3:0] c5_f1,
  output logic [3:0] c5_f2,
  input  logic [73:0] c6,
  output logic [6:0] c6_f0,
  output logic [1:0] c6_f1,
  output logic c6_f2,
  output logic [31:0] c6_f3,
  output logic [31:0] c6_f4,
  input  logic [3110:0] c7,
  output logic [6:0] c7_f0,
  output logic [31:0] c7_f1,
  output logic [1023:0] c7_f2,
  output logic [1023:0] c7_f3,
  output logic [1023:0] c7_f4,
  input  logic [1113:0] c8,
  output logic [6:0] c8_f0,
  output logic [31:0] c8_f1,
  output logic [31:0] c8_f2,
  output logic [7:0] c8_f3,
  output logic [1:0] c8_f4,
  output logic [1:0] c8_f5,
  output logic [5:0] c8_f6,
  output logic c8_f7,
  output logic [1023:0] c8_f8,
  input  logic [125:0] c9,
  output logic [6:0] c9_f0,
  output logic [1:0] c9_f1,
  output logic [5:0] c9_f2,
  output logic [7:0] c9_f3,
  output logic [1:0] c9_f4,
  output logic [5:0] c9_f5,
  output logic [31:0] c9_f6,
  output logic [4:0] c9_f7,
  output logic [2:0] c9_f8,
  output logic [3:0] c9_f9,
  output logic [1:0] c9_f10,
  output logic [3:0] c9_f11,
  output logic [28:0] c9_f12,
  output logic c9_f13,
  output logic c9_f14,
  output logic [4:0] c9_f15,
  output logic c9_f16,
  output logic [3:0] c9_f17,
  output logic c9_f18,
  output logic [1:0] c9_f19,
  output logic c9_f20,
  input  logic [118:0] c10,
  output logic [6:0] c10_f0,
  output logic [1:0] c10_f1,
  output logic [5:0] c10_f2,
  output logic [1:0] c10_f3,
  output logic [3:0] c10_f4,
  output logic [31:0] c10_f5,
  output logic [63:0] c10_f6,
  output logic c10_f7,
  output logic c10_f8,
  input  logic [7:0] c11,
  output logic [6:0] c11_f0,
  output logic c11_f1,
  input  logic [113:0] c12,
  output logic [4:0] c12_f0,
  output logic [1:0] c12_f1,
  output logic [1:0] c12_f2,
  output logic [31:0] c12_f3,
  output logic [63:0] c12_f4,
  output logic [2:0] c12_f5,
  output logic c12_f6,
  output logic c12_f7,
  output logic c12_f8,
  output logic c12_f9,
  output logic c12_f10,
  output logic c12_f11,
  input  logic [15:0] c13,
  output logic [15:0] c13_f0,
  input  logic [1476:0] c14,
  output logic [2:0] c14_f0,
  output logic [319:0] c14_f1,
  output logic [1023:0] c14_f2,
  output logic [127:0] c14_f3,
  output logic [1:0] c14_f4,
  input  logic [1032:0] c15,
  output logic [2:0] c15_f0,
  output logic [1023:0] c15_f1,
  output logic [5:0] c15_f2,
  input  logic [1211:0] c16,
  output logic [3:0] c16_f0,
  output logic [47:0] c16_f1,
  output logic [2:0] c16_f2,
  output logic [3:0] c16_f3,
  output logic c16_f4,
  output logic [1023:0] c16_f5,
  output logic [127:0] c16_f6,
  input  logic [1030:0] c17,
  output logic [3:0] c17_f0,
  output logic [1023:0] c17_f1,
  output logic c17_f2,
  output logic c17_f3,
  output logic c17_f4,
  input  logic [1081:0] c18,
  output logic [3:0] c18_f0,
  output logic [47:0] c18_f1,
  output logic [3:0] c18_f2,
  output logic [1:0] c18_f3,
  output logic [1023:0] c18_f4,
  input  logic [1029:0] c19,
  output logic [3:0] c19_f0,
  output logic [1023:0] c19_f1,
  output logic c19_f2,
  output logic c19_f3,
  input  logic [50:0] c20,
  output logic [1:0] c20_f0,
  output logic [47:0] c20_f1,
  output logic c20_f2,
  input  logic [1026:0] c21,
  output logic [1:0] c21_f0,
  output logic c21_f1,
  output logic [1023:0] c21_f2,
  input  logic [49:0] c22,
  output logic [1:0] c22_f0,
  output logic [47:0] c22_f1,
  input  logic [1025:0] c23,
  output logic [1:0] c23_f0,
  output logic [1023:0] c23_f1,
  input  logic [63:0] c24,
  output logic [63:0] c24_f0,
  input  logic [59:0] c25,
  output logic [51:0] c25_f0,
  output logic [7:0] c25_f1,
  input  logic [1089:0] c26,
  output logic [5:0] c26_f0,
  output logic [47:0] c26_f1,
  output logic [2:0] c26_f2,
  output logic [3:0] c26_f3,
  output logic [2:0] c26_f4,
  output logic [1:0] c26_f5,
  output logic [1023:0] c26_f6,
  input  logic [1081:0] c27,
  output logic [5:0] c27_f0,
  output logic [1:0] c27_f1,
  output logic [47:0] c27_f2,
  output logic [1023:0] c27_f3,
  output logic c27_f4,
  output logic c27_f5,
  input  logic [1224:0] c28,
  output logic [1224:0] c28_f0,
  input  logic [217:0] c29,
  output logic [4:0] c29_f0,
  output logic [1:0] c29_f1,
  output logic [63:0] c29_f2,
  output logic [103:0] c29_f3,
  output logic [7:0] c29_f4,
  output logic [2:0] c29_f5,
  output logic [31:0] c29_f6,
  input  logic [53:0] c30,
  output logic [4:0] c30_f0,
  output logic [1:0] c30_f1,
  output logic [1:0] c30_f2,
  output logic [31:0] c30_f3,
  output logic [4:0] c30_f4,
  output logic [4:0] c30_f5,
  output logic [2:0] c30_f6,
  input  logic [16:0] c31,
  output logic [4:0] c31_f0,
  output logic c31_f1,
  output logic c31_f2,
  output logic c31_f3,
  output logic [7:0] c31_f4,
  output logic c31_f5,
  input  logic [5:0] c32,
  output logic [4:0] c32_f0,
  output logic c32_f1,
  input  logic [70:0] c33,
  output logic [4:0] c33_f0,
  output logic [63:0] c33_f1,
  output logic c33_f2,
  output logic c33_f3,
  input  logic [5:0] c34,
  output logic [4:0] c34_f0,
  output logic c34_f1,
  input  logic [221:0] c35,
  output logic [4:0] c35_f0,
  output logic c35_f1,
  output logic [127:0] c35_f2,
  output logic [31:0] c35_f3,
  output logic [31:0] c35_f4,
  output logic [23:0] c35_f5,
  input  logic [1033:0] c36,
  output logic [4:0] c36_f0,
  output logic [4:0] c36_f1,
  output logic [1023:0] c36_f2,
  input  logic [1033:0] c37,
  output logic [4:0] c37_f0,
  output logic [4:0] c37_f1,
  output logic [1023:0] c37_f2,
  input  logic [1055:0] c38,
  output logic [4:0] c38_f0,
  output logic [991:0] c38_f1,
  output logic [15:0] c38_f2,
  output logic [4:0] c38_f3,
  output logic [5:0] c38_f4,
  output logic [31:0] c38_f5,
  input  logic [1055:0] c39,
  output logic [4:0] c39_f0,
  output logic [991:0] c39_f1,
  output logic [15:0] c39_f2,
  output logic [4:0] c39_f3,
  output logic [5:0] c39_f4,
  output logic [31:0] c39_f5,
  input  logic [7:0] c40,
  output logic [4:0] c40_f0,
  output logic [1:0] c40_f1,
  output logic c40_f2,
  input  logic [5:0] c41,
  output logic [4:0] c41_f0,
  output logic c41_f1,
  input  logic [10:0] c42,
  output logic [4:0] c42_f0,
  output logic c42_f1,
  output logic [4:0] c42_f2,
  input  logic [4:0] c43,
  output logic [4:0] c43_f0,
  input  logic [276:0] c44,
  output logic [2:0] c44_f0,
  output logic [16:0] c44_f1,
  output logic [16:0] c44_f2,
  output logic [63:0] c44_f3,
  output logic [63:0] c44_f4,
  output logic [63:0] c44_f5,
  output logic [47:0] c44_f6,
  input  logic [110:0] c45,
  output logic [4:0] c45_f0,
  output logic [2:0] c45_f1,
  output logic [3:0] c45_f2,
  output logic [1:0] c45_f3,
  output logic [31:0] c45_f4,
  output logic [31:0] c45_f5,
  output logic [31:0] c45_f6,
  output logic c45_f7,
  input  logic [4:0] c46,
  output logic [4:0] c46_f0,
  input  logic [36:0] c47,
  output logic [4:0] c47_f0,
  output logic [31:0] c47_f1,
  input  logic [4:0] c48,
  output logic [4:0] c48_f0,
  input  logic [57:0] c49,
  output logic [2:0] c49_f0,
  output logic [5:0] c49_f1,
  output logic [4:0] c49_f2,
  output logic [1:0] c49_f3,
  output logic [31:0] c49_f4,
  output logic [4:0] c49_f5,
  output logic [4:0] c49_f6,
  input  logic [171:0] c50,
  output logic [3:0] c50_f0,
  output logic [63:0] c50_f1,
  output logic [31:0] c50_f2,
  output logic [63:0] c50_f3,
  output logic [2:0] c50_f4,
  output logic [4:0] c50_f5,
  input  logic [73:0] c51,
  output logic [31:0] c51_f0,
  output logic [31:0] c51_f1,
  output logic c51_f2,
  output logic c51_f3,
  output logic [7:0] c51_f4,
  input  logic [1175:0] c52,
  output logic [1175:0] c52_f0,
  input  logic [3:0] c53,
  output logic [3:0] c53_f0,
  input  logic [12:0] c54,
  output logic [5:0] c54_f0,
  output logic [6:0] c54_f1
);
  ccv_fet_dec_instr_t s0;
  assign s0 = c0;
  assign c0_f0 = s0.warp_id;
  assign c0_f1 = s0.tier1_id;
  assign c0_f2 = s0.pc;
  assign c0_f3 = s0.group_mask;
  assign c0_f4 = s0.fetch_epoch;
  assign c0_f5 = s0.instr;
  assign c0_f6 = s0.length;
  assign c0_f7 = s0.checkpoint_id;
  assign c0_f8 = s0.pred_taken;
  assign c0_f9 = s0.fetch_fault;
  assign c0_f10 = s0.final_exit;
  assign c0_f11 = s0.all_waiting;
  ccv_ooe_fet_decq_credit_t s1;
  assign s1 = c1;
  assign c1_f0 = s1.tier1_id;
  assign c1_f1 = s1.credit_count;
  assign c1_f2 = s1.released;
  ccv_dec_ooe_uop_t s2;
  assign s2 = c2;
  assign c2_f0 = s2.warp_id;
  assign c2_f1 = s2.pc;
  assign c2_f2 = s2.group_mask;
  assign c2_f3 = s2.fetch_epoch;
  assign c2_f4 = s2.uop_class;
  assign c2_f5 = s2.sched_attr;
  assign c2_f6 = s2.mem_op;
  assign c2_f7 = s2.space;
  assign c2_f8 = s2.ordering;
  assign c2_f9 = s2.opcode;
  assign c2_f10 = s2.src_arch;
  assign c2_f11 = s2.src2_arch;
  assign c2_f12 = s2.dst_arch;
  assign c2_f13 = s2.pred_guard;
  assign c2_f14 = s2.pred_neg;
  assign c2_f15 = s2.pred_dst;
  assign c2_f16 = s2.pred_we;
  assign c2_f17 = s2.src_valid;
  assign c2_f18 = s2.pred_use;
  assign c2_f19 = s2.imm_kind;
  assign c2_f20 = s2.imm;
  assign c2_f21 = s2.ilen;
  assign c2_f22 = s2.checkpoint_id;
  assign c2_f23 = s2.pred_taken;
  assign c2_f24 = s2.scale_en;
  assign c2_f25 = s2.cause;
  assign c2_f26 = s2.fmt_rsv;
  assign c2_f27 = s2.fmt_opnd;
  assign c2_f28 = s2.final_exit;
  assign c2_f29 = s2.all_waiting;
  assign c2_f30 = s2.slot_form;
  assign c2_f31 = s2.arg_slot;
  assign c2_f32 = s2.local_form;
  assign c2_f33 = s2.xfer_size;
  assign c2_f34 = s2.xfer_signed;
  ccv_ooe_rcu_issue_t s3;
  assign s3 = c3;
  assign c3_f0 = s3.rob_tag;
  assign c3_f1 = s3.done_row;
  assign c3_f2 = s3.warp_id;
  assign c3_f3 = s3.issue_mask;
  assign c3_f4 = s3.phys_src;
  assign c3_f5 = s3.phys_src2;
  assign c3_f6 = s3.phys_dst;
  assign c3_f7 = s3.phys_old_dst;
  assign c3_f8 = s3.phys_pred_guard;
  assign c3_f9 = s3.pred_neg;
  assign c3_f10 = s3.phys_pred_dst;
  assign c3_f11 = s3.phys_pred_old_dst;
  assign c3_f12 = s3.pred_we;
  assign c3_f13 = s3.merge_en;
  assign c3_f14 = s3.cont;
  assign c3_f15 = s3.footprint;
  assign c3_f16 = s3.bypass_group;
  assign c3_f17 = s3.src_pos;
  assign c3_f18 = s3.src_width;
  assign c3_f19 = s3.dst_pos;
  assign c3_f20 = s3.old_dst_pos;
  assign c3_f21 = s3.dst_width;
  assign c3_f22 = s3.opcode;
  assign c3_f23 = s3.imm;
  assign c3_f24 = s3.chwidth;
  assign c3_f25 = s3.dispatch_fault;
  ccv_rcu_lane_ops_t s4;
  assign s4 = c4;
  assign c4_f0 = s4.sec_opcode;
  assign c4_f1 = s4.operand;
  assign c4_f2 = s4.merge_data;
  assign c4_f3 = s4.section_en;
  assign c4_f4 = s4.sec_owner;
  assign c4_f5 = s4.sec_pred_bit;
  assign c4_f6 = s4.sec_pred_data;
  assign c4_f7 = s4.sec_opnd_pos;
  assign c4_f8 = s4.sec_opnd_width;
  assign c4_f9 = s4.sec_dst_pos;
  assign c4_f10 = s4.sec_dst_width;
  assign c4_f11 = s4.operand_byp;
  ccv_lane_rcu_res_t s5;
  assign s5 = c5;
  assign c5_f0 = s5.result;
  assign c5_f1 = s5.sec_valid;
  assign c5_f2 = s5.sec_pred_out;
  ccv_rcu_ooe_done_t s6;
  assign s6 = c6;
  assign c6_f0 = s6.rob_tag;
  assign c6_f1 = s6.done_row;
  assign c6_f2 = s6.branch_taken;
  assign c6_f3 = s6.branch_mask;
  assign c6_f4 = s6.aux;
  ccv_rcu_miu_addr_t s7;
  assign s7 = c7;
  assign c7_f0 = s7.rob_tag;
  assign c7_f1 = s7.active_mask;
  assign c7_f2 = s7.base_per_lane;
  assign c7_f3 = s7.index_per_lane;
  assign c7_f4 = s7.store_data;
  ccv_miu_rcu_data_t s8;
  assign s8 = c8;
  assign c8_f0 = s8.rob_tag;
  assign c8_f1 = s8.active_mask;
  assign c8_f2 = s8.pred_result;
  assign c8_f3 = s8.phys_dst;
  assign c8_f4 = s8.dst_pos;
  assign c8_f5 = s8.dst_width;
  assign c8_f6 = s8.phys_pred;
  assign c8_f7 = s8.pred_we;
  assign c8_f8 = s8.load_data;
  ccv_ooe_miu_memop_t s9;
  assign s9 = c9;
  assign c9_f0 = s9.rob_tag;
  assign c9_f1 = s9.done_row;
  assign c9_f2 = s9.rs_idx;
  assign c9_f3 = s9.phys_dst;
  assign c9_f4 = s9.dst_pos;
  assign c9_f5 = s9.phys_pred;
  assign c9_f6 = s9.issue_mask;
  assign c9_f7 = s9.warp_id;
  assign c9_f8 = s9.cta_slot;
  assign c9_f9 = s9.mem_op;
  assign c9_f10 = s9.chwidth;
  assign c9_f11 = s9.pipes;
  assign c9_f12 = s9.disp;
  assign c9_f13 = s9.scale_en;
  assign c9_f14 = s9.space;
  assign c9_f15 = s9.ordering;
  assign c9_f16 = s9.slot_form;
  assign c9_f17 = s9.arg_slot;
  assign c9_f18 = s9.local_form;
  assign c9_f19 = s9.xfer_size;
  assign c9_f20 = s9.xfer_signed;
  ccv_miu_ooe_cmpl_t s10;
  assign s10 = c10;
  assign c10_f0 = s10.rob_tag;
  assign c10_f1 = s10.done_row;
  assign c10_f2 = s10.rs_idx;
  assign c10_f3 = s10.status;
  assign c10_f4 = s10.cause;
  assign c10_f5 = s10.lane_mask;
  assign c10_f6 = s10.address;
  assign c10_f7 = s10.mlc_miss;
  assign c10_f8 = s10.more;
  ccv_ooe_miu_retire_t s11;
  assign s11 = c11;
  assign c11_f0 = s11.rob_tag;
  assign c11_f1 = s11.commit_or_discard;
  ccv_ooe_fet_redirect_t s12;
  assign s12 = c12;
  assign c12_f0 = s12.warp_id;
  assign c12_f1 = s12.tier1_id;
  assign c12_f2 = s12.checkpoint_id;
  assign c12_f3 = s12.taken_mask;
  assign c12_f4 = s12.target_pc;
  assign c12_f5 = s12.fetch_epoch;
  assign c12_f6 = s12.epoch_only;
  assign c12_f7 = s12.rewind;
  assign c12_f8 = s12.rewind_held;
  assign c12_f9 = s12.held_long;
  assign c12_f10 = s12.own_pc;
  assign c12_f11 = s12.stay;
  ccv_ooe_fet_ckpt_free_t s13;
  assign s13 = c13;
  assign c13_f0 = s13.free_mask;
  ccv_miu_spm_req_t s14;
  assign s14 = c14;
  assign c14_f0 = s14.req_id;
  assign c14_f1 = s14.bank_addr;
  assign c14_f2 = s14.write_data;
  assign c14_f3 = s14.byte_mask;
  assign c14_f4 = s14.spm_op;
  ccv_spm_miu_rsp_t s15;
  assign s15 = c15;
  assign c15_f0 = s15.req_id;
  assign c15_f1 = s15.read_data;
  assign c15_f2 = s15.conflict_serialization;
  ccv_miu_dcu_req_t s16;
  assign s16 = c16;
  assign c16_f0 = s16.req_id;
  assign c16_f1 = s16.phys_addr;
  assign c16_f2 = s16.size;
  assign c16_f3 = s16.coh_op;
  assign c16_f4 = s16.exclusive_req;
  assign c16_f5 = s16.write_data;
  assign c16_f6 = s16.byte_mask;
  ccv_dcu_miu_rsp_t s17;
  assign s17 = c17;
  assign c17_f0 = s17.req_id;
  assign c17_f1 = s17.read_data;
  assign c17_f2 = s17.hit;
  assign c17_f3 = s17.ownership_granted;
  assign c17_f4 = s17.mlc_miss;
  ccv_dcu_mlc_req_t s18;
  assign s18 = c18;
  assign c18_f0 = s18.req_id;
  assign c18_f1 = s18.phys_addr;
  assign c18_f2 = s18.coh_op;
  assign c18_f3 = s18.core_id;
  assign c18_f4 = s18.writeback_data;
  ccv_mlc_dcu_rsp_t s19;
  assign s19 = c19;
  assign c19_f0 = s19.req_id;
  assign c19_f1 = s19.line_data;
  assign c19_f2 = s19.ownership;
  assign c19_f3 = s19.miss;
  ccv_mlc_dcu_probe_t s20;
  assign s20 = c20;
  assign c20_f0 = s20.req_id;
  assign c20_f1 = s20.phys_addr;
  assign c20_f2 = s20.invalidate_or_downgrade;
  ccv_dcu_mlc_probe_ack_t s21;
  assign s21 = c21;
  assign c21_f0 = s21.req_id;
  assign c21_f1 = s21.ack;
  assign c21_f2 = s21.dirty_data;
  ccv_fet_mlc_ifill_t s22;
  assign s22 = c22;
  assign c22_f0 = s22.req_id;
  assign c22_f1 = s22.phys_addr;
  ccv_mlc_fet_ifill_rsp_t s23;
  assign s23 = c23;
  assign c23_f0 = s23.req_id;
  assign c23_f1 = s23.line_data;
  ccv_miu_fet_itlb_t s24;
  assign s24 = c24;
  assign c24_f0 = s24.itlb_refill;
  ccv_fet_miu_itlb_req_t s25;
  assign s25 = c25;
  assign c25_f0 = s25.virtual_page;
  assign c25_f1 = s25.asid;
  ccv_mlc_exb_req_t s26;
  assign s26 = c26;
  assign c26_f0 = s26.req_id;
  assign c26_f1 = s26.phys_addr;
  assign c26_f2 = s26.size;
  assign c26_f3 = s26.coh_op;
  assign c26_f4 = s26.ownership_class;
  assign c26_f5 = s26.core_id;
  assign c26_f6 = s26.writeback_data;
  ccv_exb_mlc_rsp_t s27;
  assign s27 = c27;
  assign c27_f0 = s27.req_id;
  assign c27_f1 = s27.probe_type;
  assign c27_f2 = s27.phys_addr;
  assign c27_f3 = s27.line_data;
  assign c27_f4 = s27.ownership_grant;
  assign c27_f5 = s27.miss;
  ccv_exb_ext_out_t s28;
  assign s28 = c28;
  assign c28_f0 = s28.tl_out;
  ccv_rau_fet_launch_t s29;
  assign s29 = c29;
  assign c29_f0 = s29.warp_id;
  assign c29_f1 = s29.tier1_id;
  assign c29_f2 = s29.start_pc;
  assign c29_f3 = s29.code_bounds;
  assign c29_f4 = s29.asid;
  assign c29_f5 = s29.cta_slot;
  assign c29_f6 = s29.live_mask;
  ccv_rau_ooe_alloc_t s30;
  assign s30 = c30;
  assign c30_f0 = s30.warp_id;
  assign c30_f1 = s30.tier1_id;
  assign c30_f2 = s30.alloc_op;
  assign c30_f3 = s30.ctaid;
  assign c30_f4 = s30.warp_in_cta;
  assign c30_f5 = s30.barrier_count;
  assign c30_f6 = s30.cta_slot;
  ccv_ooe_rau_status_t s31;
  assign s31 = c31;
  assign c31_f0 = s31.warp_id;
  assign c31_f1 = s31.fault_taken;
  assign c31_f2 = s31.stalled;
  assign c31_f3 = s31.mlc_miss_seen;
  assign c31_f4 = s31.retired_since_restore;
  assign c31_f5 = s31.exited;
  ccv_rau_ooe_demote_t s32;
  assign s32 = c32;
  assign c32_f0 = s32.warp_id;
  assign c32_f1 = s32.squash_to_retirement;
  ccv_ooe_rau_drained_t s33;
  assign s33 = c33;
  assign c33_f0 = s33.warp_id;
  assign c33_f1 = s33.resume_pc;
  assign c33_f2 = s33.arch_state_ready;
  assign c33_f3 = s33.refused;
  ccv_rau_rcu_mig_t s34;
  assign s34 = c34;
  assign c34_f0 = s34.warp_id;
  assign c34_f1 = s34.direction;
  ccv_ooe_rcu_map_t s35;
  assign s35 = c35;
  assign c35_f0 = s35.warp_id;
  assign c35_f1 = s35.direction;
  assign c35_f2 = s35.gpr_map;
  assign c35_f3 = s35.gpr_pos;
  assign c35_f4 = s35.gpr_width;
  assign c35_f5 = s35.pred_map;
  ccv_rcu_pca_mig_t s36;
  assign s36 = c36;
  assign c36_f0 = s36.warp_id;
  assign c36_f1 = s36.mig_row;
  assign c36_f2 = s36.row_data;
  ccv_pca_rcu_mig_t s37;
  assign s37 = c37;
  assign c37_f0 = s37.warp_id;
  assign c37_f1 = s37.mig_row;
  assign c37_f2 = s37.row_data;
  ccv_fet_pca_mig_t s38;
  assign s38 = c38;
  assign c38_f0 = s38.warp_id;
  assign c38_f1 = s38.lane_pcs;
  assign c38_f2 = s38.pc_upper;
  assign c38_f3 = s38.fair_ptr;
  assign c38_f4 = s38.fair_cnt;
  assign c38_f5 = s38.live_mask;
  ccv_pca_fet_mig_t s39;
  assign s39 = c39;
  assign c39_f0 = s39.warp_id;
  assign c39_f1 = s39.lane_pcs;
  assign c39_f2 = s39.pc_upper;
  assign c39_f3 = s39.fair_ptr;
  assign c39_f4 = s39.fair_cnt;
  assign c39_f5 = s39.live_mask;
  ccv_rau_fet_mig_t s40;
  assign s40 = c40;
  assign c40_f0 = s40.warp_id;
  assign c40_f1 = s40.tier1_id;
  assign c40_f2 = s40.direction;
  ccv_pca_rau_mig_done_t s41;
  assign s41 = c41;
  assign c41_f0 = s41.warp_id;
  assign c41_f1 = s41.direction;
  ccv_rau_pca_mig_t s42;
  assign s42 = c42;
  assign c42_f0 = s42.warp_id;
  assign c42_f1 = s42.direction;
  assign c42_f2 = s42.pca_place;
  ccv_miu_rau_ready_t s43;
  assign s43 = c43;
  assign c43_f0 = s43.warp_id;
  ccv_rau_miu_cta_t s44;
  assign s44 = c44;
  assign c44_f0 = s44.cta_slot;
  assign c44_f1 = s44.spm_base;
  assign c44_f2 = s44.spm_limit;
  assign c44_f3 = s44.launch_block_addr;
  assign c44_f4 = s44.const_base;
  assign c44_f5 = s44.const_limit;
  assign c44_f6 = s44.local_base;
  ccv_ooe_syu_bar_t s45;
  assign s45 = c45;
  assign c45_f0 = s45.warp_id;
  assign c45_f1 = s45.cta_slot;
  assign c45_f2 = s45.barrier_id;
  assign c45_f3 = s45.bar_kind;
  assign c45_f4 = s45.issue_mask;
  assign c45_f5 = s45.guard_mask;
  assign c45_f6 = s45.phase_mask;
  assign c45_f7 = s45.held;
  ccv_syu_ooe_rel_t s46;
  assign s46 = c46;
  assign c46_f0 = s46.warp_id;
  ccv_syu_fet_rel_t s47;
  assign s47 = c47;
  assign c47_f0 = s47.warp_id;
  assign c47_f1 = s47.lane_mask;
  ccv_syu_rau_ready_t s48;
  assign s48 = c48;
  assign c48_f0 = s48.warp_id;
  ccv_rau_syu_alloc_t s49;
  assign s49 = c49;
  assign c49_f0 = s49.cta_slot;
  assign c49_f1 = s49.barrier_base;
  assign c49_f2 = s49.barrier_count;
  assign c49_f3 = s49.syu_alloc_op;
  assign c49_f4 = s49.warp_mask;
  assign c49_f5 = s49.warp_id;
  assign c49_f6 = s49.last_lanes;
  ccv_ooe_cru_fault_t s50;
  assign s50 = c50;
  assign c50_f0 = s50.cause;
  assign c50_f1 = s50.pc;
  assign c50_f2 = s50.lane_mask;
  assign c50_f3 = s50.address;
  assign c50_f4 = s50.cta_slot;
  assign c50_f5 = s50.warp_id;
  ccv_cru_rau_cfg_t s51;
  assign s51 = c51;
  assign c51_f0 = s51.demotion_threshold;
  assign c51_f1 = s51.progress_threshold;
  assign c51_f2 = s51.launch_enable;
  assign c51_f3 = s51.kill_req;
  assign c51_f4 = s51.kill_grid;
  ccv_ext_exb_in_t s52;
  assign s52 = c52;
  assign c52_f0 = s52.tl_in;
  ccv_dcu_miu_fill_ntc_t s53;
  assign s53 = c53;
  assign c53_f0 = s53.req_id;
  ccv_miu_ooe_cmpl_hint_t s54;
  assign s54 = c54;
  assign c54_f0 = s54.rs_idx;
  assign c54_f1 = s54.rob_tag;
endmodule
