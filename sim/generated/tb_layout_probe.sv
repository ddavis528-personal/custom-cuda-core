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
  input  logic [235:0] c1,
  output logic [4:0] c1_f0,
  output logic [63:0] c1_f1,
  output logic [31:0] c1_f2,
  output logic [2:0] c1_f3,
  output logic [2:0] c1_f4,
  output logic [20:0] c1_f5,
  output logic [3:0] c1_f6,
  output logic c1_f7,
  output logic [4:0] c1_f8,
  output logic [8:0] c1_f9,
  output logic [7:0] c1_f10,
  output logic [3:0] c1_f11,
  output logic [3:0] c1_f12,
  output logic [1:0] c1_f13,
  output logic c1_f14,
  output logic [1:0] c1_f15,
  output logic c1_f16,
  output logic [2:0] c1_f17,
  output logic [1:0] c1_f18,
  output logic [2:0] c1_f19,
  output logic [31:0] c1_f20,
  output logic [1:0] c1_f21,
  output logic [1:0] c1_f22,
  output logic c1_f23,
  output logic c1_f24,
  output logic [3:0] c1_f25,
  output logic [3:0] c1_f26,
  output logic [1:0] c1_f27,
  output logic c1_f28,
  output logic c1_f29,
  output logic c1_f30,
  output logic [3:0] c1_f31,
  output logic c1_f32,
  output logic [1:0] c1_f33,
  output logic c1_f34,
  input  logic [174:0] c2,
  output logic [6:0] c2_f0,
  output logic [4:0] c2_f1,
  output logic [31:0] c2_f2,
  output logic [15:0] c2_f3,
  output logic [7:0] c2_f4,
  output logic [7:0] c2_f5,
  output logic [7:0] c2_f6,
  output logic [5:0] c2_f7,
  output logic c2_f8,
  output logic [5:0] c2_f9,
  output logic [5:0] c2_f10,
  output logic c2_f11,
  output logic c2_f12,
  output logic c2_f13,
  output logic [3:0] c2_f14,
  output logic [2:0] c2_f15,
  output logic [5:0] c2_f16,
  output logic [5:0] c2_f17,
  output logic [1:0] c2_f18,
  output logic [1:0] c2_f19,
  output logic [1:0] c2_f20,
  output logic [8:0] c2_f21,
  output logic [31:0] c2_f22,
  output logic [1:0] c2_f23,
  output logic c2_f24,
  input  logic [343:0] c3,
  output logic [35:0] c3_f0,
  output logic [95:0] c3_f1,
  output logic [31:0] c3_f2,
  output logic [3:0] c3_f3,
  output logic [7:0] c3_f4,
  output logic [3:0] c3_f5,
  output logic [3:0] c3_f6,
  output logic [31:0] c3_f7,
  output logic [31:0] c3_f8,
  output logic [7:0] c3_f9,
  output logic [7:0] c3_f10,
  output logic [79:0] c3_f11,
  input  logic [39:0] c4,
  output logic [31:0] c4_f0,
  output logic [3:0] c4_f1,
  output logic [3:0] c4_f2,
  input  logic [71:0] c5,
  output logic [6:0] c5_f0,
  output logic c5_f1,
  output logic [31:0] c5_f2,
  output logic [31:0] c5_f3,
  input  logic [3110:0] c6,
  output logic [6:0] c6_f0,
  output logic [31:0] c6_f1,
  output logic [1023:0] c6_f2,
  output logic [1023:0] c6_f3,
  output logic [1023:0] c6_f4,
  input  logic [1113:0] c7,
  output logic [6:0] c7_f0,
  output logic [31:0] c7_f1,
  output logic [31:0] c7_f2,
  output logic [7:0] c7_f3,
  output logic [1:0] c7_f4,
  output logic [1:0] c7_f5,
  output logic [5:0] c7_f6,
  output logic c7_f7,
  output logic [1023:0] c7_f8,
  input  logic [123:0] c8,
  output logic [6:0] c8_f0,
  output logic [5:0] c8_f1,
  output logic [7:0] c8_f2,
  output logic [1:0] c8_f3,
  output logic [5:0] c8_f4,
  output logic [31:0] c8_f5,
  output logic [4:0] c8_f6,
  output logic [2:0] c8_f7,
  output logic [3:0] c8_f8,
  output logic [1:0] c8_f9,
  output logic [3:0] c8_f10,
  output logic [28:0] c8_f11,
  output logic c8_f12,
  output logic c8_f13,
  output logic [4:0] c8_f14,
  output logic c8_f15,
  output logic [3:0] c8_f16,
  output logic c8_f17,
  output logic [1:0] c8_f18,
  output logic c8_f19,
  input  logic [116:0] c9,
  output logic [6:0] c9_f0,
  output logic [5:0] c9_f1,
  output logic [1:0] c9_f2,
  output logic [3:0] c9_f3,
  output logic [31:0] c9_f4,
  output logic [63:0] c9_f5,
  output logic c9_f6,
  output logic c9_f7,
  input  logic [7:0] c10,
  output logic [6:0] c10_f0,
  output logic c10_f1,
  input  logic [113:0] c11,
  output logic [4:0] c11_f0,
  output logic [1:0] c11_f1,
  output logic [1:0] c11_f2,
  output logic [31:0] c11_f3,
  output logic [63:0] c11_f4,
  output logic [2:0] c11_f5,
  output logic c11_f6,
  output logic c11_f7,
  output logic c11_f8,
  output logic c11_f9,
  output logic c11_f10,
  output logic c11_f11,
  input  logic [15:0] c12,
  output logic [15:0] c12_f0,
  input  logic [1476:0] c13,
  output logic [2:0] c13_f0,
  output logic [319:0] c13_f1,
  output logic [1023:0] c13_f2,
  output logic [127:0] c13_f3,
  output logic [1:0] c13_f4,
  input  logic [1032:0] c14,
  output logic [2:0] c14_f0,
  output logic [1023:0] c14_f1,
  output logic [5:0] c14_f2,
  input  logic [1211:0] c15,
  output logic [3:0] c15_f0,
  output logic [47:0] c15_f1,
  output logic [2:0] c15_f2,
  output logic [3:0] c15_f3,
  output logic c15_f4,
  output logic [1023:0] c15_f5,
  output logic [127:0] c15_f6,
  input  logic [1030:0] c16,
  output logic [3:0] c16_f0,
  output logic [1023:0] c16_f1,
  output logic c16_f2,
  output logic c16_f3,
  output logic c16_f4,
  input  logic [1081:0] c17,
  output logic [3:0] c17_f0,
  output logic [47:0] c17_f1,
  output logic [3:0] c17_f2,
  output logic [1:0] c17_f3,
  output logic [1023:0] c17_f4,
  input  logic [1029:0] c18,
  output logic [3:0] c18_f0,
  output logic [1023:0] c18_f1,
  output logic c18_f2,
  output logic c18_f3,
  input  logic [50:0] c19,
  output logic [1:0] c19_f0,
  output logic [47:0] c19_f1,
  output logic c19_f2,
  input  logic [1026:0] c20,
  output logic [1:0] c20_f0,
  output logic c20_f1,
  output logic [1023:0] c20_f2,
  input  logic [49:0] c21,
  output logic [1:0] c21_f0,
  output logic [47:0] c21_f1,
  input  logic [1025:0] c22,
  output logic [1:0] c22_f0,
  output logic [1023:0] c22_f1,
  input  logic [63:0] c23,
  output logic [63:0] c23_f0,
  input  logic [59:0] c24,
  output logic [51:0] c24_f0,
  output logic [7:0] c24_f1,
  input  logic [1089:0] c25,
  output logic [5:0] c25_f0,
  output logic [47:0] c25_f1,
  output logic [2:0] c25_f2,
  output logic [3:0] c25_f3,
  output logic [2:0] c25_f4,
  output logic [1:0] c25_f5,
  output logic [1023:0] c25_f6,
  input  logic [1081:0] c26,
  output logic [5:0] c26_f0,
  output logic [1:0] c26_f1,
  output logic [47:0] c26_f2,
  output logic [1023:0] c26_f3,
  output logic c26_f4,
  output logic c26_f5,
  input  logic [1224:0] c27,
  output logic [1224:0] c27_f0,
  input  logic [217:0] c28,
  output logic [4:0] c28_f0,
  output logic [1:0] c28_f1,
  output logic [63:0] c28_f2,
  output logic [103:0] c28_f3,
  output logic [7:0] c28_f4,
  output logic [2:0] c28_f5,
  output logic [31:0] c28_f6,
  input  logic [53:0] c29,
  output logic [4:0] c29_f0,
  output logic [1:0] c29_f1,
  output logic [1:0] c29_f2,
  output logic [31:0] c29_f3,
  output logic [4:0] c29_f4,
  output logic [4:0] c29_f5,
  output logic [2:0] c29_f6,
  input  logic [16:0] c30,
  output logic [4:0] c30_f0,
  output logic c30_f1,
  output logic c30_f2,
  output logic c30_f3,
  output logic [7:0] c30_f4,
  output logic c30_f5,
  input  logic [5:0] c31,
  output logic [4:0] c31_f0,
  output logic c31_f1,
  input  logic [70:0] c32,
  output logic [4:0] c32_f0,
  output logic [63:0] c32_f1,
  output logic c32_f2,
  output logic c32_f3,
  input  logic [5:0] c33,
  output logic [4:0] c33_f0,
  output logic c33_f1,
  input  logic [221:0] c34,
  output logic [4:0] c34_f0,
  output logic c34_f1,
  output logic [127:0] c34_f2,
  output logic [31:0] c34_f3,
  output logic [31:0] c34_f4,
  output logic [23:0] c34_f5,
  input  logic [1033:0] c35,
  output logic [4:0] c35_f0,
  output logic [4:0] c35_f1,
  output logic [1023:0] c35_f2,
  input  logic [1033:0] c36,
  output logic [4:0] c36_f0,
  output logic [4:0] c36_f1,
  output logic [1023:0] c36_f2,
  input  logic [1055:0] c37,
  output logic [4:0] c37_f0,
  output logic [991:0] c37_f1,
  output logic [15:0] c37_f2,
  output logic [4:0] c37_f3,
  output logic [5:0] c37_f4,
  output logic [31:0] c37_f5,
  input  logic [1055:0] c38,
  output logic [4:0] c38_f0,
  output logic [991:0] c38_f1,
  output logic [15:0] c38_f2,
  output logic [4:0] c38_f3,
  output logic [5:0] c38_f4,
  output logic [31:0] c38_f5,
  input  logic [7:0] c39,
  output logic [4:0] c39_f0,
  output logic [1:0] c39_f1,
  output logic c39_f2,
  input  logic [5:0] c40,
  output logic [4:0] c40_f0,
  output logic c40_f1,
  input  logic [10:0] c41,
  output logic [4:0] c41_f0,
  output logic c41_f1,
  output logic [4:0] c41_f2,
  input  logic [4:0] c42,
  output logic [4:0] c42_f0,
  input  logic [228:0] c43,
  output logic [2:0] c43_f0,
  output logic [16:0] c43_f1,
  output logic [16:0] c43_f2,
  output logic [63:0] c43_f3,
  output logic [63:0] c43_f4,
  output logic [63:0] c43_f5,
  input  logic [110:0] c44,
  output logic [4:0] c44_f0,
  output logic [2:0] c44_f1,
  output logic [3:0] c44_f2,
  output logic [1:0] c44_f3,
  output logic [31:0] c44_f4,
  output logic [31:0] c44_f5,
  output logic [31:0] c44_f6,
  output logic c44_f7,
  input  logic [4:0] c45,
  output logic [4:0] c45_f0,
  input  logic [36:0] c46,
  output logic [4:0] c46_f0,
  output logic [31:0] c46_f1,
  input  logic [4:0] c47,
  output logic [4:0] c47_f0,
  input  logic [57:0] c48,
  output logic [2:0] c48_f0,
  output logic [5:0] c48_f1,
  output logic [4:0] c48_f2,
  output logic [1:0] c48_f3,
  output logic [31:0] c48_f4,
  output logic [4:0] c48_f5,
  output logic [4:0] c48_f6,
  input  logic [171:0] c49,
  output logic [3:0] c49_f0,
  output logic [63:0] c49_f1,
  output logic [31:0] c49_f2,
  output logic [63:0] c49_f3,
  output logic [2:0] c49_f4,
  output logic [4:0] c49_f5,
  input  logic [73:0] c50,
  output logic [31:0] c50_f0,
  output logic [31:0] c50_f1,
  output logic c50_f2,
  output logic c50_f3,
  output logic [7:0] c50_f4,
  input  logic [1175:0] c51,
  output logic [1175:0] c51_f0,
  input  logic [3:0] c52,
  output logic [3:0] c52_f0,
  input  logic [12:0] c53,
  output logic [5:0] c53_f0,
  output logic [6:0] c53_f1
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
  ccv_dec_ooe_uop_t s1;
  assign s1 = c1;
  assign c1_f0 = s1.warp_id;
  assign c1_f1 = s1.pc;
  assign c1_f2 = s1.group_mask;
  assign c1_f3 = s1.fetch_epoch;
  assign c1_f4 = s1.uop_class;
  assign c1_f5 = s1.sched_attr;
  assign c1_f6 = s1.mem_op;
  assign c1_f7 = s1.space;
  assign c1_f8 = s1.ordering;
  assign c1_f9 = s1.opcode;
  assign c1_f10 = s1.src_arch;
  assign c1_f11 = s1.src2_arch;
  assign c1_f12 = s1.dst_arch;
  assign c1_f13 = s1.pred_guard;
  assign c1_f14 = s1.pred_neg;
  assign c1_f15 = s1.pred_dst;
  assign c1_f16 = s1.pred_we;
  assign c1_f17 = s1.src_valid;
  assign c1_f18 = s1.pred_use;
  assign c1_f19 = s1.imm_kind;
  assign c1_f20 = s1.imm;
  assign c1_f21 = s1.ilen;
  assign c1_f22 = s1.checkpoint_id;
  assign c1_f23 = s1.pred_taken;
  assign c1_f24 = s1.scale_en;
  assign c1_f25 = s1.cause;
  assign c1_f26 = s1.fmt_rsv;
  assign c1_f27 = s1.fmt_opnd;
  assign c1_f28 = s1.final_exit;
  assign c1_f29 = s1.all_waiting;
  assign c1_f30 = s1.slot_form;
  assign c1_f31 = s1.arg_slot;
  assign c1_f32 = s1.local_form;
  assign c1_f33 = s1.xfer_size;
  assign c1_f34 = s1.xfer_signed;
  ccv_ooe_rcu_issue_t s2;
  assign s2 = c2;
  assign c2_f0 = s2.rob_tag;
  assign c2_f1 = s2.warp_id;
  assign c2_f2 = s2.issue_mask;
  assign c2_f3 = s2.phys_src;
  assign c2_f4 = s2.phys_src2;
  assign c2_f5 = s2.phys_dst;
  assign c2_f6 = s2.phys_old_dst;
  assign c2_f7 = s2.phys_pred_guard;
  assign c2_f8 = s2.pred_neg;
  assign c2_f9 = s2.phys_pred_dst;
  assign c2_f10 = s2.phys_pred_old_dst;
  assign c2_f11 = s2.pred_we;
  assign c2_f12 = s2.merge_en;
  assign c2_f13 = s2.cont;
  assign c2_f14 = s2.footprint;
  assign c2_f15 = s2.bypass_group;
  assign c2_f16 = s2.src_pos;
  assign c2_f17 = s2.src_width;
  assign c2_f18 = s2.dst_pos;
  assign c2_f19 = s2.old_dst_pos;
  assign c2_f20 = s2.dst_width;
  assign c2_f21 = s2.opcode;
  assign c2_f22 = s2.imm;
  assign c2_f23 = s2.chwidth;
  assign c2_f24 = s2.dispatch_fault;
  ccv_rcu_lane_ops_t s3;
  assign s3 = c3;
  assign c3_f0 = s3.sec_opcode;
  assign c3_f1 = s3.operand;
  assign c3_f2 = s3.merge_data;
  assign c3_f3 = s3.section_en;
  assign c3_f4 = s3.sec_owner;
  assign c3_f5 = s3.sec_pred_bit;
  assign c3_f6 = s3.sec_pred_data;
  assign c3_f7 = s3.sec_opnd_pos;
  assign c3_f8 = s3.sec_opnd_width;
  assign c3_f9 = s3.sec_dst_pos;
  assign c3_f10 = s3.sec_dst_width;
  assign c3_f11 = s3.operand_byp;
  ccv_lane_rcu_res_t s4;
  assign s4 = c4;
  assign c4_f0 = s4.result;
  assign c4_f1 = s4.sec_valid;
  assign c4_f2 = s4.sec_pred_out;
  ccv_rcu_ooe_done_t s5;
  assign s5 = c5;
  assign c5_f0 = s5.rob_tag;
  assign c5_f1 = s5.branch_taken;
  assign c5_f2 = s5.branch_mask;
  assign c5_f3 = s5.aux;
  ccv_rcu_miu_addr_t s6;
  assign s6 = c6;
  assign c6_f0 = s6.rob_tag;
  assign c6_f1 = s6.active_mask;
  assign c6_f2 = s6.base_per_lane;
  assign c6_f3 = s6.index_per_lane;
  assign c6_f4 = s6.store_data;
  ccv_miu_rcu_data_t s7;
  assign s7 = c7;
  assign c7_f0 = s7.rob_tag;
  assign c7_f1 = s7.active_mask;
  assign c7_f2 = s7.pred_result;
  assign c7_f3 = s7.phys_dst;
  assign c7_f4 = s7.dst_pos;
  assign c7_f5 = s7.dst_width;
  assign c7_f6 = s7.phys_pred;
  assign c7_f7 = s7.pred_we;
  assign c7_f8 = s7.load_data;
  ccv_ooe_miu_memop_t s8;
  assign s8 = c8;
  assign c8_f0 = s8.rob_tag;
  assign c8_f1 = s8.rs_idx;
  assign c8_f2 = s8.phys_dst;
  assign c8_f3 = s8.dst_pos;
  assign c8_f4 = s8.phys_pred;
  assign c8_f5 = s8.issue_mask;
  assign c8_f6 = s8.warp_id;
  assign c8_f7 = s8.cta_slot;
  assign c8_f8 = s8.mem_op;
  assign c8_f9 = s8.chwidth;
  assign c8_f10 = s8.pipes;
  assign c8_f11 = s8.disp;
  assign c8_f12 = s8.scale_en;
  assign c8_f13 = s8.space;
  assign c8_f14 = s8.ordering;
  assign c8_f15 = s8.slot_form;
  assign c8_f16 = s8.arg_slot;
  assign c8_f17 = s8.local_form;
  assign c8_f18 = s8.xfer_size;
  assign c8_f19 = s8.xfer_signed;
  ccv_miu_ooe_cmpl_t s9;
  assign s9 = c9;
  assign c9_f0 = s9.rob_tag;
  assign c9_f1 = s9.rs_idx;
  assign c9_f2 = s9.status;
  assign c9_f3 = s9.cause;
  assign c9_f4 = s9.lane_mask;
  assign c9_f5 = s9.address;
  assign c9_f6 = s9.mlc_miss;
  assign c9_f7 = s9.more;
  ccv_ooe_miu_retire_t s10;
  assign s10 = c10;
  assign c10_f0 = s10.rob_tag;
  assign c10_f1 = s10.commit_or_discard;
  ccv_ooe_fet_redirect_t s11;
  assign s11 = c11;
  assign c11_f0 = s11.warp_id;
  assign c11_f1 = s11.tier1_id;
  assign c11_f2 = s11.checkpoint_id;
  assign c11_f3 = s11.taken_mask;
  assign c11_f4 = s11.target_pc;
  assign c11_f5 = s11.fetch_epoch;
  assign c11_f6 = s11.epoch_only;
  assign c11_f7 = s11.rewind;
  assign c11_f8 = s11.rewind_held;
  assign c11_f9 = s11.held_long;
  assign c11_f10 = s11.own_pc;
  assign c11_f11 = s11.stay;
  ccv_ooe_fet_ckpt_free_t s12;
  assign s12 = c12;
  assign c12_f0 = s12.free_mask;
  ccv_miu_spm_req_t s13;
  assign s13 = c13;
  assign c13_f0 = s13.req_id;
  assign c13_f1 = s13.bank_addr;
  assign c13_f2 = s13.write_data;
  assign c13_f3 = s13.byte_mask;
  assign c13_f4 = s13.spm_op;
  ccv_spm_miu_rsp_t s14;
  assign s14 = c14;
  assign c14_f0 = s14.req_id;
  assign c14_f1 = s14.read_data;
  assign c14_f2 = s14.conflict_serialization;
  ccv_miu_dcu_req_t s15;
  assign s15 = c15;
  assign c15_f0 = s15.req_id;
  assign c15_f1 = s15.phys_addr;
  assign c15_f2 = s15.size;
  assign c15_f3 = s15.coh_op;
  assign c15_f4 = s15.exclusive_req;
  assign c15_f5 = s15.write_data;
  assign c15_f6 = s15.byte_mask;
  ccv_dcu_miu_rsp_t s16;
  assign s16 = c16;
  assign c16_f0 = s16.req_id;
  assign c16_f1 = s16.read_data;
  assign c16_f2 = s16.hit;
  assign c16_f3 = s16.ownership_granted;
  assign c16_f4 = s16.mlc_miss;
  ccv_dcu_mlc_req_t s17;
  assign s17 = c17;
  assign c17_f0 = s17.req_id;
  assign c17_f1 = s17.phys_addr;
  assign c17_f2 = s17.coh_op;
  assign c17_f3 = s17.core_id;
  assign c17_f4 = s17.writeback_data;
  ccv_mlc_dcu_rsp_t s18;
  assign s18 = c18;
  assign c18_f0 = s18.req_id;
  assign c18_f1 = s18.line_data;
  assign c18_f2 = s18.ownership;
  assign c18_f3 = s18.miss;
  ccv_mlc_dcu_probe_t s19;
  assign s19 = c19;
  assign c19_f0 = s19.req_id;
  assign c19_f1 = s19.phys_addr;
  assign c19_f2 = s19.invalidate_or_downgrade;
  ccv_dcu_mlc_probe_ack_t s20;
  assign s20 = c20;
  assign c20_f0 = s20.req_id;
  assign c20_f1 = s20.ack;
  assign c20_f2 = s20.dirty_data;
  ccv_fet_mlc_ifill_t s21;
  assign s21 = c21;
  assign c21_f0 = s21.req_id;
  assign c21_f1 = s21.phys_addr;
  ccv_mlc_fet_ifill_rsp_t s22;
  assign s22 = c22;
  assign c22_f0 = s22.req_id;
  assign c22_f1 = s22.line_data;
  ccv_miu_fet_itlb_t s23;
  assign s23 = c23;
  assign c23_f0 = s23.itlb_refill;
  ccv_fet_miu_itlb_req_t s24;
  assign s24 = c24;
  assign c24_f0 = s24.virtual_page;
  assign c24_f1 = s24.asid;
  ccv_mlc_exb_req_t s25;
  assign s25 = c25;
  assign c25_f0 = s25.req_id;
  assign c25_f1 = s25.phys_addr;
  assign c25_f2 = s25.size;
  assign c25_f3 = s25.coh_op;
  assign c25_f4 = s25.ownership_class;
  assign c25_f5 = s25.core_id;
  assign c25_f6 = s25.writeback_data;
  ccv_exb_mlc_rsp_t s26;
  assign s26 = c26;
  assign c26_f0 = s26.req_id;
  assign c26_f1 = s26.probe_type;
  assign c26_f2 = s26.phys_addr;
  assign c26_f3 = s26.line_data;
  assign c26_f4 = s26.ownership_grant;
  assign c26_f5 = s26.miss;
  ccv_exb_ext_out_t s27;
  assign s27 = c27;
  assign c27_f0 = s27.tl_out;
  ccv_rau_fet_launch_t s28;
  assign s28 = c28;
  assign c28_f0 = s28.warp_id;
  assign c28_f1 = s28.tier1_id;
  assign c28_f2 = s28.start_pc;
  assign c28_f3 = s28.code_bounds;
  assign c28_f4 = s28.asid;
  assign c28_f5 = s28.cta_slot;
  assign c28_f6 = s28.live_mask;
  ccv_rau_ooe_alloc_t s29;
  assign s29 = c29;
  assign c29_f0 = s29.warp_id;
  assign c29_f1 = s29.tier1_id;
  assign c29_f2 = s29.alloc_op;
  assign c29_f3 = s29.ctaid;
  assign c29_f4 = s29.warp_in_cta;
  assign c29_f5 = s29.barrier_count;
  assign c29_f6 = s29.cta_slot;
  ccv_ooe_rau_status_t s30;
  assign s30 = c30;
  assign c30_f0 = s30.warp_id;
  assign c30_f1 = s30.fault_taken;
  assign c30_f2 = s30.stalled;
  assign c30_f3 = s30.mlc_miss_seen;
  assign c30_f4 = s30.retired_since_restore;
  assign c30_f5 = s30.exited;
  ccv_rau_ooe_demote_t s31;
  assign s31 = c31;
  assign c31_f0 = s31.warp_id;
  assign c31_f1 = s31.squash_to_retirement;
  ccv_ooe_rau_drained_t s32;
  assign s32 = c32;
  assign c32_f0 = s32.warp_id;
  assign c32_f1 = s32.resume_pc;
  assign c32_f2 = s32.arch_state_ready;
  assign c32_f3 = s32.refused;
  ccv_rau_rcu_mig_t s33;
  assign s33 = c33;
  assign c33_f0 = s33.warp_id;
  assign c33_f1 = s33.direction;
  ccv_ooe_rcu_map_t s34;
  assign s34 = c34;
  assign c34_f0 = s34.warp_id;
  assign c34_f1 = s34.direction;
  assign c34_f2 = s34.gpr_map;
  assign c34_f3 = s34.gpr_pos;
  assign c34_f4 = s34.gpr_width;
  assign c34_f5 = s34.pred_map;
  ccv_rcu_pca_mig_t s35;
  assign s35 = c35;
  assign c35_f0 = s35.warp_id;
  assign c35_f1 = s35.mig_row;
  assign c35_f2 = s35.row_data;
  ccv_pca_rcu_mig_t s36;
  assign s36 = c36;
  assign c36_f0 = s36.warp_id;
  assign c36_f1 = s36.mig_row;
  assign c36_f2 = s36.row_data;
  ccv_fet_pca_mig_t s37;
  assign s37 = c37;
  assign c37_f0 = s37.warp_id;
  assign c37_f1 = s37.lane_pcs;
  assign c37_f2 = s37.pc_upper;
  assign c37_f3 = s37.fair_ptr;
  assign c37_f4 = s37.fair_cnt;
  assign c37_f5 = s37.live_mask;
  ccv_pca_fet_mig_t s38;
  assign s38 = c38;
  assign c38_f0 = s38.warp_id;
  assign c38_f1 = s38.lane_pcs;
  assign c38_f2 = s38.pc_upper;
  assign c38_f3 = s38.fair_ptr;
  assign c38_f4 = s38.fair_cnt;
  assign c38_f5 = s38.live_mask;
  ccv_rau_fet_mig_t s39;
  assign s39 = c39;
  assign c39_f0 = s39.warp_id;
  assign c39_f1 = s39.tier1_id;
  assign c39_f2 = s39.direction;
  ccv_pca_rau_mig_done_t s40;
  assign s40 = c40;
  assign c40_f0 = s40.warp_id;
  assign c40_f1 = s40.direction;
  ccv_rau_pca_mig_t s41;
  assign s41 = c41;
  assign c41_f0 = s41.warp_id;
  assign c41_f1 = s41.direction;
  assign c41_f2 = s41.pca_place;
  ccv_miu_rau_ready_t s42;
  assign s42 = c42;
  assign c42_f0 = s42.warp_id;
  ccv_rau_miu_cta_t s43;
  assign s43 = c43;
  assign c43_f0 = s43.cta_slot;
  assign c43_f1 = s43.spm_base;
  assign c43_f2 = s43.spm_limit;
  assign c43_f3 = s43.launch_block_addr;
  assign c43_f4 = s43.const_base;
  assign c43_f5 = s43.const_limit;
  ccv_ooe_syu_bar_t s44;
  assign s44 = c44;
  assign c44_f0 = s44.warp_id;
  assign c44_f1 = s44.cta_slot;
  assign c44_f2 = s44.barrier_id;
  assign c44_f3 = s44.bar_kind;
  assign c44_f4 = s44.issue_mask;
  assign c44_f5 = s44.guard_mask;
  assign c44_f6 = s44.phase_mask;
  assign c44_f7 = s44.held;
  ccv_syu_ooe_rel_t s45;
  assign s45 = c45;
  assign c45_f0 = s45.warp_id;
  ccv_syu_fet_rel_t s46;
  assign s46 = c46;
  assign c46_f0 = s46.warp_id;
  assign c46_f1 = s46.lane_mask;
  ccv_syu_rau_ready_t s47;
  assign s47 = c47;
  assign c47_f0 = s47.warp_id;
  ccv_rau_syu_alloc_t s48;
  assign s48 = c48;
  assign c48_f0 = s48.cta_slot;
  assign c48_f1 = s48.barrier_base;
  assign c48_f2 = s48.barrier_count;
  assign c48_f3 = s48.syu_alloc_op;
  assign c48_f4 = s48.warp_mask;
  assign c48_f5 = s48.warp_id;
  assign c48_f6 = s48.last_lanes;
  ccv_ooe_cru_fault_t s49;
  assign s49 = c49;
  assign c49_f0 = s49.cause;
  assign c49_f1 = s49.pc;
  assign c49_f2 = s49.lane_mask;
  assign c49_f3 = s49.address;
  assign c49_f4 = s49.cta_slot;
  assign c49_f5 = s49.warp_id;
  ccv_cru_rau_cfg_t s50;
  assign s50 = c50;
  assign c50_f0 = s50.demotion_threshold;
  assign c50_f1 = s50.progress_threshold;
  assign c50_f2 = s50.launch_enable;
  assign c50_f3 = s50.kill_req;
  assign c50_f4 = s50.kill_grid;
  ccv_ext_exb_in_t s51;
  assign s51 = c51;
  assign c51_f0 = s51.tl_in;
  ccv_dcu_miu_fill_ntc_t s52;
  assign s52 = c52;
  assign c52_f0 = s52.req_id;
  ccv_miu_ooe_cmpl_hint_t s53;
  assign s53 = c53;
  assign c53_f0 = s53.rs_idx;
  assign c53_f1 = s53.rob_tag;
endmodule
