// GENERATED FILE -- DO NOT EDIT.
//
// Produced by tools/gen-skel.py from schema/interfaces.json,
// params/blocks.json and params/ccv_params.json. Edit a source and
// regenerate; tools/verify.sh fails if this file is stale.


`include "ccv_interfaces.svh"

module ccv_skel_layout_probe (
  input  logic [121:0] c0,
  output logic [4:0] c0_f0,
  output logic [1:0] c0_f1,
  output logic [63:0] c0_f2,
  output logic [47:0] c0_f3,
  output logic [1:0] c0_f4,
  output logic c0_f5,
  input  logic [136:0] c1,
  output logic [4:0] c1_f0,
  output logic [63:0] c1_f1,
  output logic [2:0] c1_f2,
  output logic [8:0] c1_f3,
  output logic [7:0] c1_f4,
  output logic [3:0] c1_f5,
  output logic [3:0] c1_f6,
  output logic [1:0] c1_f7,
  output logic c1_f8,
  output logic [1:0] c1_f9,
  output logic c1_f10,
  output logic [31:0] c1_f11,
  output logic c1_f12,
  output logic c1_f13,
  input  logic [137:0] c2,
  output logic [6:0] c2_f0,
  output logic [4:0] c2_f1,
  output logic [31:0] c2_f2,
  output logic [15:0] c2_f3,
  output logic [7:0] c2_f4,
  output logic [7:0] c2_f5,
  output logic [7:0] c2_f6,
  output logic c2_f7,
  output logic [7:0] c2_f8,
  output logic c2_f9,
  output logic [8:0] c2_f10,
  output logic [31:0] c2_f11,
  output logic [1:0] c2_f12,
  output logic c2_f13,
  input  logic [110:0] c3,
  output logic [8:0] c3_f0,
  output logic [95:0] c3_f1,
  output logic c3_f2,
  output logic c3_f3,
  output logic [3:0] c3_f4,
  input  logic [33:0] c4,
  output logic [31:0] c4_f0,
  output logic c4_f1,
  output logic c4_f2,
  input  logic [72:0] c5,
  output logic [6:0] c5_f0,
  output logic c5_f1,
  output logic c5_f2,
  output logic [31:0] c5_f3,
  output logic [31:0] c5_f4,
  input  logic [2150:0] c6,
  output logic [6:0] c6_f0,
  output logic [31:0] c6_f1,
  output logic [63:0] c6_f2,
  output logic [1023:0] c6_f3,
  output logic [1023:0] c6_f4,
  input  logic [1111:0] c7,
  output logic [6:0] c7_f0,
  output logic [31:0] c7_f1,
  output logic [31:0] c7_f2,
  output logic [7:0] c7_f3,
  output logic [7:0] c7_f4,
  output logic c7_f5,
  output logic [1023:0] c7_f6,
  input  logic [92:0] c8,
  output logic [6:0] c8_f0,
  output logic [7:0] c8_f1,
  output logic [7:0] c8_f2,
  output logic [31:0] c8_f3,
  output logic [4:0] c8_f4,
  output logic [2:0] c8_f5,
  output logic [3:0] c8_f6,
  output logic [1:0] c8_f7,
  output logic [15:0] c8_f8,
  output logic c8_f9,
  output logic [2:0] c8_f10,
  output logic [3:0] c8_f11,
  input  logic [109:0] c9,
  output logic [6:0] c9_f0,
  output logic [1:0] c9_f1,
  output logic [3:0] c9_f2,
  output logic [31:0] c9_f3,
  output logic [63:0] c9_f4,
  output logic c9_f5,
  input  logic [7:0] c10,
  output logic [6:0] c10_f0,
  output logic c10_f1,
  input  logic [200:0] c11,
  output logic [4:0] c11_f0,
  output logic [1:0] c11_f1,
  output logic [63:0] c11_f2,
  output logic [127:0] c11_f3,
  output logic [1:0] c11_f4,
  input  logic [1476:0] c12,
  output logic [2:0] c12_f0,
  output logic [319:0] c12_f1,
  output logic [1023:0] c12_f2,
  output logic [127:0] c12_f3,
  output logic [1:0] c12_f4,
  input  logic [1032:0] c13,
  output logic [2:0] c13_f0,
  output logic [1023:0] c13_f1,
  output logic [5:0] c13_f2,
  input  logic [1211:0] c14,
  output logic [3:0] c14_f0,
  output logic [47:0] c14_f1,
  output logic [2:0] c14_f2,
  output logic [3:0] c14_f3,
  output logic c14_f4,
  output logic [1023:0] c14_f5,
  output logic [127:0] c14_f6,
  input  logic [1029:0] c15,
  output logic [3:0] c15_f0,
  output logic [1023:0] c15_f1,
  output logic c15_f2,
  output logic c15_f3,
  input  logic [1081:0] c16,
  output logic [3:0] c16_f0,
  output logic [47:0] c16_f1,
  output logic [3:0] c16_f2,
  output logic [1:0] c16_f3,
  output logic [1023:0] c16_f4,
  input  logic [1029:0] c17,
  output logic [3:0] c17_f0,
  output logic [1023:0] c17_f1,
  output logic c17_f2,
  output logic c17_f3,
  input  logic [50:0] c18,
  output logic [1:0] c18_f0,
  output logic [47:0] c18_f1,
  output logic c18_f2,
  input  logic [1026:0] c19,
  output logic [1:0] c19_f0,
  output logic c19_f1,
  output logic [1023:0] c19_f2,
  input  logic [57:0] c20,
  output logic [1:0] c20_f0,
  output logic [47:0] c20_f1,
  output logic [7:0] c20_f2,
  input  logic [1025:0] c21,
  output logic [1:0] c21_f0,
  output logic [1023:0] c21_f1,
  input  logic [63:0] c22,
  output logic [63:0] c22_f0,
  input  logic [71:0] c23,
  output logic [63:0] c23_f0,
  output logic [7:0] c23_f1,
  input  logic [1089:0] c24,
  output logic [5:0] c24_f0,
  output logic [47:0] c24_f1,
  output logic [2:0] c24_f2,
  output logic [3:0] c24_f3,
  output logic [2:0] c24_f4,
  output logic [1:0] c24_f5,
  output logic [1023:0] c24_f6,
  input  logic [1081:0] c25,
  output logic [5:0] c25_f0,
  output logic [1:0] c25_f1,
  output logic [47:0] c25_f2,
  output logic [1023:0] c25_f3,
  output logic c25_f4,
  output logic c25_f5,
  input  logic [1224:0] c26,
  output logic [1224:0] c26_f0,
  input  logic [183:0] c27,
  output logic [4:0] c27_f0,
  output logic [63:0] c27_f1,
  output logic [103:0] c27_f2,
  output logic [7:0] c27_f3,
  output logic [2:0] c27_f4,
  input  logic [58:0] c28,
  output logic [4:0] c28_f0,
  output logic [7:0] c28_f1,
  output logic [7:0] c28_f2,
  output logic c28_f3,
  output logic [31:0] c28_f4,
  output logic [4:0] c28_f5,
  input  logic [15:0] c29,
  output logic [4:0] c29_f0,
  output logic c29_f1,
  output logic c29_f2,
  output logic c29_f3,
  output logic [7:0] c29_f4,
  input  logic [5:0] c30,
  output logic [4:0] c30_f0,
  output logic c30_f1,
  input  logic [69:0] c31,
  output logic [4:0] c31_f0,
  output logic [63:0] c31_f1,
  output logic c31_f2,
  input  logic [8:0] c32,
  output logic [4:0] c32_f0,
  output logic c32_f1,
  output logic [2:0] c32_f2,
  input  logic [2056:0] c33,
  output logic [4:0] c33_f0,
  output logic [3:0] c33_f1,
  output logic [1023:0] c33_f2,
  output logic [1023:0] c33_f3,
  input  logic [2056:0] c34,
  output logic [4:0] c34_f0,
  output logic [3:0] c34_f1,
  output logic [1023:0] c34_f2,
  output logic [1023:0] c34_f3,
  input  logic [260:0] c35,
  output logic [4:0] c35_f0,
  output logic [255:0] c35_f1,
  input  logic [260:0] c36,
  output logic [4:0] c36_f0,
  output logic [255:0] c36_f1,
  input  logic [8:0] c37,
  output logic [4:0] c37_f0,
  output logic c37_f1,
  output logic [2:0] c37_f2,
  input  logic [4:0] c38,
  output logic [4:0] c38_f0,
  input  logic [100:0] c39,
  output logic [2:0] c39_f0,
  output logic [16:0] c39_f1,
  output logic [16:0] c39_f2,
  output logic [63:0] c39_f3,
  input  logic [12:0] c40,
  output logic [4:0] c40_f0,
  output logic [2:0] c40_f1,
  output logic [3:0] c40_f2,
  output logic c40_f3,
  input  logic [35:0] c41,
  output logic [31:0] c41_f0,
  output logic [3:0] c41_f1,
  input  logic [16:0] c42,
  output logic [2:0] c42_f0,
  output logic [5:0] c42_f1,
  output logic [6:0] c42_f2,
  output logic c42_f3,
  input  logic [171:0] c43,
  output logic [3:0] c43_f0,
  output logic [63:0] c43_f1,
  output logic [31:0] c43_f2,
  output logic [63:0] c43_f3,
  output logic [2:0] c43_f4,
  output logic [4:0] c43_f5,
  input  logic [73:0] c44,
  output logic [31:0] c44_f0,
  output logic [31:0] c44_f1,
  output logic c44_f2,
  output logic c44_f3,
  output logic [7:0] c44_f4,
  input  logic [1175:0] c45,
  output logic [1175:0] c45_f0
);
  ccv_fet_dec_instr_t s0;
  assign s0 = c0;
  assign c0_f0 = s0.warp_id;
  assign c0_f1 = s0.tier1_id;
  assign c0_f2 = s0.pc;
  assign c0_f3 = s0.instr;
  assign c0_f4 = s0.length;
  assign c0_f5 = s0.fetch_fault;
  ccv_dec_ooe_uop_t s1;
  assign s1 = c1;
  assign c1_f0 = s1.warp_id;
  assign c1_f1 = s1.pc;
  assign c1_f2 = s1.uop_class;
  assign c1_f3 = s1.opcode;
  assign c1_f4 = s1.src_arch;
  assign c1_f5 = s1.src2_arch;
  assign c1_f6 = s1.dst_arch;
  assign c1_f7 = s1.pred_guard;
  assign c1_f8 = s1.pred_neg;
  assign c1_f9 = s1.pred_dst;
  assign c1_f10 = s1.pred_we;
  assign c1_f11 = s1.imm;
  assign c1_f12 = s1.scale_en;
  assign c1_f13 = s1.decode_fault;
  ccv_ooe_rcu_issue_t s2;
  assign s2 = c2;
  assign c2_f0 = s2.rob_tag;
  assign c2_f1 = s2.warp_id;
  assign c2_f2 = s2.issue_mask;
  assign c2_f3 = s2.phys_src;
  assign c2_f4 = s2.phys_src2;
  assign c2_f5 = s2.phys_dst;
  assign c2_f6 = s2.phys_pred_guard;
  assign c2_f7 = s2.pred_neg;
  assign c2_f8 = s2.phys_pred_dst;
  assign c2_f9 = s2.pred_we;
  assign c2_f10 = s2.opcode;
  assign c2_f11 = s2.imm;
  assign c2_f12 = s2.chwidth;
  assign c2_f13 = s2.dispatch_fault;
  ccv_rcu_lane_ops_t s3;
  assign s3 = c3;
  assign c3_f0 = s3.opcode;
  assign c3_f1 = s3.operand;
  assign c3_f2 = s3.pred_bit;
  assign c3_f3 = s3.pred_data;
  assign c3_f4 = s3.section_en;
  ccv_lane_rcu_res_t s4;
  assign s4 = c4;
  assign c4_f0 = s4.result;
  assign c4_f1 = s4.pred_out;
  assign c4_f2 = s4.lane_fault;
  ccv_rcu_ooe_done_t s5;
  assign s5 = c5;
  assign c5_f0 = s5.rob_tag;
  assign c5_f1 = s5.exec_fault;
  assign c5_f2 = s5.branch_taken;
  assign c5_f3 = s5.branch_mask;
  assign c5_f4 = s5.fault_lane_mask;
  ccv_rcu_miu_addr_t s6;
  assign s6 = c6;
  assign c6_f0 = s6.rob_tag;
  assign c6_f1 = s6.active_mask;
  assign c6_f2 = s6.base;
  assign c6_f3 = s6.index_per_lane;
  assign c6_f4 = s6.store_data;
  ccv_miu_rcu_data_t s7;
  assign s7 = c7;
  assign c7_f0 = s7.rob_tag;
  assign c7_f1 = s7.active_mask;
  assign c7_f2 = s7.pred_result;
  assign c7_f3 = s7.phys_dst;
  assign c7_f4 = s7.phys_pred;
  assign c7_f5 = s7.pred_we;
  assign c7_f6 = s7.load_data;
  ccv_ooe_miu_memop_t s8;
  assign s8 = c8;
  assign c8_f0 = s8.rob_tag;
  assign c8_f1 = s8.phys_dst;
  assign c8_f2 = s8.phys_pred;
  assign c8_f3 = s8.issue_mask;
  assign c8_f4 = s8.warp_id;
  assign c8_f5 = s8.cta_slot;
  assign c8_f6 = s8.mem_op;
  assign c8_f7 = s8.chwidth;
  assign c8_f8 = s8.disp;
  assign c8_f9 = s8.scale_en;
  assign c8_f10 = s8.space;
  assign c8_f11 = s8.ordering;
  ccv_miu_ooe_cmpl_t s9;
  assign s9 = c9;
  assign c9_f0 = s9.rob_tag;
  assign c9_f1 = s9.status;
  assign c9_f2 = s9.cause;
  assign c9_f3 = s9.lane_mask;
  assign c9_f4 = s9.address;
  assign c9_f5 = s9.mlc_miss;
  ccv_ooe_miu_retire_t s10;
  assign s10 = c10;
  assign c10_f0 = s10.rob_tag;
  assign c10_f1 = s10.commit_or_discard;
  ccv_ooe_fet_redirect_t s11;
  assign s11 = c11;
  assign c11_f0 = s11.warp_id;
  assign c11_f1 = s11.tier1_id;
  assign c11_f2 = s11.target_pc;
  assign c11_f3 = s11.group_masks;
  assign c11_f4 = s11.fetch_epoch;
  ccv_miu_spm_req_t s12;
  assign s12 = c12;
  assign c12_f0 = s12.req_id;
  assign c12_f1 = s12.bank_addr;
  assign c12_f2 = s12.write_data;
  assign c12_f3 = s12.byte_mask;
  assign c12_f4 = s12.spm_op;
  ccv_spm_miu_rsp_t s13;
  assign s13 = c13;
  assign c13_f0 = s13.req_id;
  assign c13_f1 = s13.read_data;
  assign c13_f2 = s13.conflict_serialization;
  ccv_miu_dcu_req_t s14;
  assign s14 = c14;
  assign c14_f0 = s14.req_id;
  assign c14_f1 = s14.phys_addr;
  assign c14_f2 = s14.size;
  assign c14_f3 = s14.coh_op;
  assign c14_f4 = s14.exclusive_req;
  assign c14_f5 = s14.write_data;
  assign c14_f6 = s14.byte_mask;
  ccv_dcu_miu_rsp_t s15;
  assign s15 = c15;
  assign c15_f0 = s15.req_id;
  assign c15_f1 = s15.read_data;
  assign c15_f2 = s15.hit;
  assign c15_f3 = s15.ownership_granted;
  ccv_dcu_mlc_req_t s16;
  assign s16 = c16;
  assign c16_f0 = s16.req_id;
  assign c16_f1 = s16.phys_addr;
  assign c16_f2 = s16.coh_op;
  assign c16_f3 = s16.core_id;
  assign c16_f4 = s16.writeback_data;
  ccv_mlc_dcu_rsp_t s17;
  assign s17 = c17;
  assign c17_f0 = s17.req_id;
  assign c17_f1 = s17.line_data;
  assign c17_f2 = s17.ownership;
  assign c17_f3 = s17.miss;
  ccv_mlc_dcu_probe_t s18;
  assign s18 = c18;
  assign c18_f0 = s18.req_id;
  assign c18_f1 = s18.phys_addr;
  assign c18_f2 = s18.invalidate_or_downgrade;
  ccv_dcu_mlc_probe_ack_t s19;
  assign s19 = c19;
  assign c19_f0 = s19.req_id;
  assign c19_f1 = s19.ack;
  assign c19_f2 = s19.dirty_data;
  ccv_fet_mlc_ifill_t s20;
  assign s20 = c20;
  assign c20_f0 = s20.req_id;
  assign c20_f1 = s20.phys_addr;
  assign c20_f2 = s20.asid;
  ccv_mlc_fet_ifill_rsp_t s21;
  assign s21 = c21;
  assign c21_f0 = s21.req_id;
  assign c21_f1 = s21.line_data;
  ccv_miu_fet_itlb_t s22;
  assign s22 = c22;
  assign c22_f0 = s22.itlb_refill;
  ccv_fet_miu_itlb_req_t s23;
  assign s23 = c23;
  assign c23_f0 = s23.virtual_page;
  assign c23_f1 = s23.asid;
  ccv_mlc_exb_req_t s24;
  assign s24 = c24;
  assign c24_f0 = s24.req_id;
  assign c24_f1 = s24.phys_addr;
  assign c24_f2 = s24.size;
  assign c24_f3 = s24.coh_op;
  assign c24_f4 = s24.ownership_class;
  assign c24_f5 = s24.core_id;
  assign c24_f6 = s24.writeback_data;
  ccv_exb_mlc_rsp_t s25;
  assign s25 = c25;
  assign c25_f0 = s25.req_id;
  assign c25_f1 = s25.probe_type;
  assign c25_f2 = s25.phys_addr;
  assign c25_f3 = s25.line_data;
  assign c25_f4 = s25.ownership_grant;
  assign c25_f5 = s25.miss;
  ccv_exb_ext_out_t s26;
  assign s26 = c26;
  assign c26_f0 = s26.tl_out;
  ccv_rau_fet_launch_t s27;
  assign s27 = c27;
  assign c27_f0 = s27.warp_id;
  assign c27_f1 = s27.start_pc;
  assign c27_f2 = s27.code_bounds;
  assign c27_f3 = s27.asid;
  assign c27_f4 = s27.cta_slot;
  ccv_rau_ooe_alloc_t s28;
  assign s28 = c28;
  assign c28_f0 = s28.warp_id;
  assign c28_f1 = s28.prf_base;
  assign c28_f2 = s28.prf_size;
  assign c28_f3 = s28.activate_or_free;
  assign c28_f4 = s28.ctaid;
  assign c28_f5 = s28.warp_in_cta;
  ccv_ooe_rau_status_t s29;
  assign s29 = c29;
  assign c29_f0 = s29.warp_id;
  assign c29_f1 = s29.fault_taken;
  assign c29_f2 = s29.stalled;
  assign c29_f3 = s29.mlc_miss_seen;
  assign c29_f4 = s29.retired_since_restore;
  ccv_rau_ooe_demote_t s30;
  assign s30 = c30;
  assign c30_f0 = s30.warp_id;
  assign c30_f1 = s30.squash_to_retirement;
  ccv_ooe_rau_drained_t s31;
  assign s31 = c31;
  assign c31_f0 = s31.warp_id;
  assign c31_f1 = s31.resume_pc;
  assign c31_f2 = s31.arch_state_ready;
  ccv_rau_rcu_mig_t s32;
  assign s32 = c32;
  assign c32_f0 = s32.warp_id;
  assign c32_f1 = s32.direction;
  assign c32_f2 = s32.bank_select;
  ccv_rcu_pca_mig_t s33;
  assign s33 = c33;
  assign c33_f0 = s33.warp_id;
  assign c33_f1 = s33.row_idx;
  assign c33_f2 = s33.gpr_row;
  assign c33_f3 = s33.pred_state;
  ccv_pca_rcu_mig_t s34;
  assign s34 = c34;
  assign c34_f0 = s34.warp_id;
  assign c34_f1 = s34.row_idx;
  assign c34_f2 = s34.gpr_row;
  assign c34_f3 = s34.pred_state;
  ccv_fet_pca_mig_t s35;
  assign s35 = c35;
  assign c35_f0 = s35.warp_id;
  assign c35_f1 = s35.pcs;
  ccv_pca_fet_mig_t s36;
  assign s36 = c36;
  assign c36_f0 = s36.warp_id;
  assign c36_f1 = s36.pcs;
  ccv_rau_fet_mig_t s37;
  assign s37 = c37;
  assign c37_f0 = s37.warp_id;
  assign c37_f1 = s37.direction;
  assign c37_f2 = s37.bank_select;
  ccv_pca_rau_mig_done_t s38;
  assign s38 = c38;
  assign c38_f0 = s38.warp_id;
  ccv_rau_miu_cta_t s39;
  assign s39 = c39;
  assign c39_f0 = s39.cta_slot;
  assign c39_f1 = s39.spm_base;
  assign c39_f2 = s39.spm_limit;
  assign c39_f3 = s39.launch_block_addr;
  ccv_ooe_syu_bar_t s40;
  assign s40 = c40;
  assign c40_f0 = s40.warp_id;
  assign c40_f1 = s40.cta_slot;
  assign c40_f2 = s40.barrier_id;
  assign c40_f3 = s40.arrive_or_wait;
  ccv_syu_ooe_rel_t s41;
  assign s41 = c41;
  assign c41_f0 = s41.warp_mask_released;
  assign c41_f1 = s41.barrier_id;
  ccv_rau_syu_alloc_t s42;
  assign s42 = c42;
  assign c42_f0 = s42.cta_slot;
  assign c42_f1 = s42.barrier_base;
  assign c42_f2 = s42.barrier_count;
  assign c42_f3 = s42.allocate_or_free;
  ccv_ooe_cru_fault_t s43;
  assign s43 = c43;
  assign c43_f0 = s43.cause;
  assign c43_f1 = s43.pc;
  assign c43_f2 = s43.lane_mask;
  assign c43_f3 = s43.address;
  assign c43_f4 = s43.cta_slot;
  assign c43_f5 = s43.warp_id;
  ccv_cru_rau_cfg_t s44;
  assign s44 = c44;
  assign c44_f0 = s44.demotion_threshold;
  assign c44_f1 = s44.progress_threshold;
  assign c44_f2 = s44.launch_enable;
  assign c44_f3 = s44.kill_req;
  assign c44_f4 = s44.kill_grid;
  ccv_ext_exb_in_t s45;
  assign s45 = c45;
  assign c45_f0 = s45.tl_in;
endmodule
