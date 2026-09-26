// GENERATED FILE -- DO NOT EDIT.
//
// Produced by tools/gen-skel.py from schema/interfaces.json,
// params/blocks.json and params/ccv_params.json. Edit a source and
// regenerate; tools/verify.sh fails if this file is stale.

// Included by sim/skel/layout_probe.cpp, which supplies put/eq.

static unsigned probeOnce(Vccv_skel_layout_probe &p, uint64_t seed) {
  unsigned bad = 0;
  {
    const Bits b = randomBits(122, seed ^ 0u);
    put(p.c0, b);
    p.eval();
    bad += check("ccv_fet_dec_instr", "warp_id", p.c0_f0, b, 117, 5);
    bad += check("ccv_fet_dec_instr", "tier1_id", p.c0_f1, b, 115, 2);
    bad += check("ccv_fet_dec_instr", "pc", p.c0_f2, b, 51, 64);
    bad += check("ccv_fet_dec_instr", "instr", p.c0_f3, b, 3, 48);
    bad += check("ccv_fet_dec_instr", "length", p.c0_f4, b, 1, 2);
    bad += check("ccv_fet_dec_instr", "fetch_fault", p.c0_f5, b, 0, 1);
  }
  {
    const Bits b = randomBits(137, seed ^ 7919u);
    put(p.c1, b);
    p.eval();
    bad += check("ccv_dec_ooe_uop", "warp_id", p.c1_f0, b, 132, 5);
    bad += check("ccv_dec_ooe_uop", "pc", p.c1_f1, b, 68, 64);
    bad += check("ccv_dec_ooe_uop", "uop_class", p.c1_f2, b, 65, 3);
    bad += check("ccv_dec_ooe_uop", "opcode", p.c1_f3, b, 56, 9);
    bad += check("ccv_dec_ooe_uop", "src_arch", p.c1_f4, b, 48, 8);
    bad += check("ccv_dec_ooe_uop", "src2_arch", p.c1_f5, b, 44, 4);
    bad += check("ccv_dec_ooe_uop", "dst_arch", p.c1_f6, b, 40, 4);
    bad += check("ccv_dec_ooe_uop", "pred_guard", p.c1_f7, b, 38, 2);
    bad += check("ccv_dec_ooe_uop", "pred_neg", p.c1_f8, b, 37, 1);
    bad += check("ccv_dec_ooe_uop", "pred_dst", p.c1_f9, b, 35, 2);
    bad += check("ccv_dec_ooe_uop", "pred_we", p.c1_f10, b, 34, 1);
    bad += check("ccv_dec_ooe_uop", "imm", p.c1_f11, b, 2, 32);
    bad += check("ccv_dec_ooe_uop", "scale_en", p.c1_f12, b, 1, 1);
    bad += check("ccv_dec_ooe_uop", "decode_fault", p.c1_f13, b, 0, 1);
  }
  {
    const Bits b = randomBits(138, seed ^ 15838u);
    put(p.c2, b);
    p.eval();
    bad += check("ccv_ooe_rcu_issue", "rob_tag", p.c2_f0, b, 131, 7);
    bad += check("ccv_ooe_rcu_issue", "warp_id", p.c2_f1, b, 126, 5);
    bad += check("ccv_ooe_rcu_issue", "issue_mask", p.c2_f2, b, 94, 32);
    bad += check("ccv_ooe_rcu_issue", "phys_src", p.c2_f3, b, 78, 16);
    bad += check("ccv_ooe_rcu_issue", "phys_src2", p.c2_f4, b, 70, 8);
    bad += check("ccv_ooe_rcu_issue", "phys_dst", p.c2_f5, b, 62, 8);
    bad += check("ccv_ooe_rcu_issue", "phys_pred_guard", p.c2_f6, b, 54, 8);
    bad += check("ccv_ooe_rcu_issue", "pred_neg", p.c2_f7, b, 53, 1);
    bad += check("ccv_ooe_rcu_issue", "phys_pred_dst", p.c2_f8, b, 45, 8);
    bad += check("ccv_ooe_rcu_issue", "pred_we", p.c2_f9, b, 44, 1);
    bad += check("ccv_ooe_rcu_issue", "opcode", p.c2_f10, b, 35, 9);
    bad += check("ccv_ooe_rcu_issue", "imm", p.c2_f11, b, 3, 32);
    bad += check("ccv_ooe_rcu_issue", "chwidth", p.c2_f12, b, 1, 2);
    bad += check("ccv_ooe_rcu_issue", "dispatch_fault", p.c2_f13, b, 0, 1);
  }
  {
    const Bits b = randomBits(111, seed ^ 23757u);
    put(p.c3, b);
    p.eval();
    bad += check("ccv_rcu_lane_ops", "opcode", p.c3_f0, b, 102, 9);
    bad += check("ccv_rcu_lane_ops", "operand", p.c3_f1, b, 6, 96);
    bad += check("ccv_rcu_lane_ops", "pred_bit", p.c3_f2, b, 5, 1);
    bad += check("ccv_rcu_lane_ops", "pred_data", p.c3_f3, b, 4, 1);
    bad += check("ccv_rcu_lane_ops", "section_en", p.c3_f4, b, 0, 4);
  }
  {
    const Bits b = randomBits(34, seed ^ 31676u);
    put(p.c4, b);
    p.eval();
    bad += check("ccv_lane_rcu_res", "result", p.c4_f0, b, 2, 32);
    bad += check("ccv_lane_rcu_res", "pred_out", p.c4_f1, b, 1, 1);
    bad += check("ccv_lane_rcu_res", "lane_fault", p.c4_f2, b, 0, 1);
  }
  {
    const Bits b = randomBits(73, seed ^ 39595u);
    put(p.c5, b);
    p.eval();
    bad += check("ccv_rcu_ooe_done", "rob_tag", p.c5_f0, b, 66, 7);
    bad += check("ccv_rcu_ooe_done", "exec_fault", p.c5_f1, b, 65, 1);
    bad += check("ccv_rcu_ooe_done", "branch_taken", p.c5_f2, b, 64, 1);
    bad += check("ccv_rcu_ooe_done", "branch_mask", p.c5_f3, b, 32, 32);
    bad += check("ccv_rcu_ooe_done", "fault_lane_mask", p.c5_f4, b, 0, 32);
  }
  {
    const Bits b = randomBits(2151, seed ^ 47514u);
    put(p.c6, b);
    p.eval();
    bad += check("ccv_rcu_miu_addr", "rob_tag", p.c6_f0, b, 2144, 7);
    bad += check("ccv_rcu_miu_addr", "active_mask", p.c6_f1, b, 2112, 32);
    bad += check("ccv_rcu_miu_addr", "base", p.c6_f2, b, 2048, 64);
    bad += check("ccv_rcu_miu_addr", "index_per_lane", p.c6_f3, b, 1024, 1024);
    bad += check("ccv_rcu_miu_addr", "store_data", p.c6_f4, b, 0, 1024);
  }
  {
    const Bits b = randomBits(1112, seed ^ 55433u);
    put(p.c7, b);
    p.eval();
    bad += check("ccv_miu_rcu_data", "rob_tag", p.c7_f0, b, 1105, 7);
    bad += check("ccv_miu_rcu_data", "active_mask", p.c7_f1, b, 1073, 32);
    bad += check("ccv_miu_rcu_data", "pred_result", p.c7_f2, b, 1041, 32);
    bad += check("ccv_miu_rcu_data", "phys_dst", p.c7_f3, b, 1033, 8);
    bad += check("ccv_miu_rcu_data", "phys_pred", p.c7_f4, b, 1025, 8);
    bad += check("ccv_miu_rcu_data", "pred_we", p.c7_f5, b, 1024, 1);
    bad += check("ccv_miu_rcu_data", "load_data", p.c7_f6, b, 0, 1024);
  }
  {
    const Bits b = randomBits(93, seed ^ 63352u);
    put(p.c8, b);
    p.eval();
    bad += check("ccv_ooe_miu_memop", "rob_tag", p.c8_f0, b, 86, 7);
    bad += check("ccv_ooe_miu_memop", "phys_dst", p.c8_f1, b, 78, 8);
    bad += check("ccv_ooe_miu_memop", "phys_pred", p.c8_f2, b, 70, 8);
    bad += check("ccv_ooe_miu_memop", "issue_mask", p.c8_f3, b, 38, 32);
    bad += check("ccv_ooe_miu_memop", "warp_id", p.c8_f4, b, 33, 5);
    bad += check("ccv_ooe_miu_memop", "cta_slot", p.c8_f5, b, 30, 3);
    bad += check("ccv_ooe_miu_memop", "mem_op", p.c8_f6, b, 26, 4);
    bad += check("ccv_ooe_miu_memop", "chwidth", p.c8_f7, b, 24, 2);
    bad += check("ccv_ooe_miu_memop", "disp", p.c8_f8, b, 8, 16);
    bad += check("ccv_ooe_miu_memop", "scale_en", p.c8_f9, b, 7, 1);
    bad += check("ccv_ooe_miu_memop", "space", p.c8_f10, b, 4, 3);
    bad += check("ccv_ooe_miu_memop", "ordering", p.c8_f11, b, 0, 4);
  }
  {
    const Bits b = randomBits(110, seed ^ 71271u);
    put(p.c9, b);
    p.eval();
    bad += check("ccv_miu_ooe_cmpl", "rob_tag", p.c9_f0, b, 103, 7);
    bad += check("ccv_miu_ooe_cmpl", "status", p.c9_f1, b, 101, 2);
    bad += check("ccv_miu_ooe_cmpl", "cause", p.c9_f2, b, 97, 4);
    bad += check("ccv_miu_ooe_cmpl", "lane_mask", p.c9_f3, b, 65, 32);
    bad += check("ccv_miu_ooe_cmpl", "address", p.c9_f4, b, 1, 64);
    bad += check("ccv_miu_ooe_cmpl", "mlc_miss", p.c9_f5, b, 0, 1);
  }
  {
    const Bits b = randomBits(8, seed ^ 79190u);
    put(p.c10, b);
    p.eval();
    bad += check("ccv_ooe_miu_retire", "rob_tag", p.c10_f0, b, 1, 7);
    bad += check("ccv_ooe_miu_retire", "commit_or_discard", p.c10_f1, b, 0, 1);
  }
  {
    const Bits b = randomBits(201, seed ^ 87109u);
    put(p.c11, b);
    p.eval();
    bad += check("ccv_ooe_fet_redirect", "warp_id", p.c11_f0, b, 196, 5);
    bad += check("ccv_ooe_fet_redirect", "tier1_id", p.c11_f1, b, 194, 2);
    bad += check("ccv_ooe_fet_redirect", "target_pc", p.c11_f2, b, 130, 64);
    bad += check("ccv_ooe_fet_redirect", "group_masks", p.c11_f3, b, 2, 128);
    bad += check("ccv_ooe_fet_redirect", "fetch_epoch", p.c11_f4, b, 0, 2);
  }
  {
    const Bits b = randomBits(1477, seed ^ 95028u);
    put(p.c12, b);
    p.eval();
    bad += check("ccv_miu_spm_req", "req_id", p.c12_f0, b, 1474, 3);
    bad += check("ccv_miu_spm_req", "bank_addr", p.c12_f1, b, 1154, 320);
    bad += check("ccv_miu_spm_req", "write_data", p.c12_f2, b, 130, 1024);
    bad += check("ccv_miu_spm_req", "byte_mask", p.c12_f3, b, 2, 128);
    bad += check("ccv_miu_spm_req", "spm_op", p.c12_f4, b, 0, 2);
  }
  {
    const Bits b = randomBits(1033, seed ^ 102947u);
    put(p.c13, b);
    p.eval();
    bad += check("ccv_spm_miu_rsp", "req_id", p.c13_f0, b, 1030, 3);
    bad += check("ccv_spm_miu_rsp", "read_data", p.c13_f1, b, 6, 1024);
    bad += check("ccv_spm_miu_rsp", "conflict_serialization", p.c13_f2, b, 0, 6);
  }
  {
    const Bits b = randomBits(1212, seed ^ 110866u);
    put(p.c14, b);
    p.eval();
    bad += check("ccv_miu_dcu_req", "req_id", p.c14_f0, b, 1208, 4);
    bad += check("ccv_miu_dcu_req", "phys_addr", p.c14_f1, b, 1160, 48);
    bad += check("ccv_miu_dcu_req", "size", p.c14_f2, b, 1157, 3);
    bad += check("ccv_miu_dcu_req", "coh_op", p.c14_f3, b, 1153, 4);
    bad += check("ccv_miu_dcu_req", "exclusive_req", p.c14_f4, b, 1152, 1);
    bad += check("ccv_miu_dcu_req", "write_data", p.c14_f5, b, 128, 1024);
    bad += check("ccv_miu_dcu_req", "byte_mask", p.c14_f6, b, 0, 128);
  }
  {
    const Bits b = randomBits(1030, seed ^ 118785u);
    put(p.c15, b);
    p.eval();
    bad += check("ccv_dcu_miu_rsp", "req_id", p.c15_f0, b, 1026, 4);
    bad += check("ccv_dcu_miu_rsp", "read_data", p.c15_f1, b, 2, 1024);
    bad += check("ccv_dcu_miu_rsp", "hit", p.c15_f2, b, 1, 1);
    bad += check("ccv_dcu_miu_rsp", "ownership_granted", p.c15_f3, b, 0, 1);
  }
  {
    const Bits b = randomBits(1082, seed ^ 126704u);
    put(p.c16, b);
    p.eval();
    bad += check("ccv_dcu_mlc_req", "req_id", p.c16_f0, b, 1078, 4);
    bad += check("ccv_dcu_mlc_req", "phys_addr", p.c16_f1, b, 1030, 48);
    bad += check("ccv_dcu_mlc_req", "coh_op", p.c16_f2, b, 1026, 4);
    bad += check("ccv_dcu_mlc_req", "core_id", p.c16_f3, b, 1024, 2);
    bad += check("ccv_dcu_mlc_req", "writeback_data", p.c16_f4, b, 0, 1024);
  }
  {
    const Bits b = randomBits(1030, seed ^ 134623u);
    put(p.c17, b);
    p.eval();
    bad += check("ccv_mlc_dcu_rsp", "req_id", p.c17_f0, b, 1026, 4);
    bad += check("ccv_mlc_dcu_rsp", "line_data", p.c17_f1, b, 2, 1024);
    bad += check("ccv_mlc_dcu_rsp", "ownership", p.c17_f2, b, 1, 1);
    bad += check("ccv_mlc_dcu_rsp", "miss", p.c17_f3, b, 0, 1);
  }
  {
    const Bits b = randomBits(51, seed ^ 142542u);
    put(p.c18, b);
    p.eval();
    bad += check("ccv_mlc_dcu_probe", "req_id", p.c18_f0, b, 49, 2);
    bad += check("ccv_mlc_dcu_probe", "phys_addr", p.c18_f1, b, 1, 48);
    bad += check("ccv_mlc_dcu_probe", "invalidate_or_downgrade", p.c18_f2, b, 0, 1);
  }
  {
    const Bits b = randomBits(1027, seed ^ 150461u);
    put(p.c19, b);
    p.eval();
    bad += check("ccv_dcu_mlc_probe_ack", "req_id", p.c19_f0, b, 1025, 2);
    bad += check("ccv_dcu_mlc_probe_ack", "ack", p.c19_f1, b, 1024, 1);
    bad += check("ccv_dcu_mlc_probe_ack", "dirty_data", p.c19_f2, b, 0, 1024);
  }
  {
    const Bits b = randomBits(58, seed ^ 158380u);
    put(p.c20, b);
    p.eval();
    bad += check("ccv_fet_mlc_ifill", "req_id", p.c20_f0, b, 56, 2);
    bad += check("ccv_fet_mlc_ifill", "phys_addr", p.c20_f1, b, 8, 48);
    bad += check("ccv_fet_mlc_ifill", "asid", p.c20_f2, b, 0, 8);
  }
  {
    const Bits b = randomBits(1026, seed ^ 166299u);
    put(p.c21, b);
    p.eval();
    bad += check("ccv_mlc_fet_ifill_rsp", "req_id", p.c21_f0, b, 1024, 2);
    bad += check("ccv_mlc_fet_ifill_rsp", "line_data", p.c21_f1, b, 0, 1024);
  }
  {
    const Bits b = randomBits(64, seed ^ 174218u);
    put(p.c22, b);
    p.eval();
    bad += check("ccv_miu_fet_itlb", "itlb_refill", p.c22_f0, b, 0, 64);
  }
  {
    const Bits b = randomBits(72, seed ^ 182137u);
    put(p.c23, b);
    p.eval();
    bad += check("ccv_fet_miu_itlb_req", "virtual_page", p.c23_f0, b, 8, 64);
    bad += check("ccv_fet_miu_itlb_req", "asid", p.c23_f1, b, 0, 8);
  }
  {
    const Bits b = randomBits(1090, seed ^ 190056u);
    put(p.c24, b);
    p.eval();
    bad += check("ccv_mlc_exb_req", "req_id", p.c24_f0, b, 1084, 6);
    bad += check("ccv_mlc_exb_req", "phys_addr", p.c24_f1, b, 1036, 48);
    bad += check("ccv_mlc_exb_req", "size", p.c24_f2, b, 1033, 3);
    bad += check("ccv_mlc_exb_req", "coh_op", p.c24_f3, b, 1029, 4);
    bad += check("ccv_mlc_exb_req", "ownership_class", p.c24_f4, b, 1026, 3);
    bad += check("ccv_mlc_exb_req", "core_id", p.c24_f5, b, 1024, 2);
    bad += check("ccv_mlc_exb_req", "writeback_data", p.c24_f6, b, 0, 1024);
  }
  {
    const Bits b = randomBits(1082, seed ^ 197975u);
    put(p.c25, b);
    p.eval();
    bad += check("ccv_exb_mlc_rsp", "req_id", p.c25_f0, b, 1076, 6);
    bad += check("ccv_exb_mlc_rsp", "probe_type", p.c25_f1, b, 1074, 2);
    bad += check("ccv_exb_mlc_rsp", "phys_addr", p.c25_f2, b, 1026, 48);
    bad += check("ccv_exb_mlc_rsp", "line_data", p.c25_f3, b, 2, 1024);
    bad += check("ccv_exb_mlc_rsp", "ownership_grant", p.c25_f4, b, 1, 1);
    bad += check("ccv_exb_mlc_rsp", "miss", p.c25_f5, b, 0, 1);
  }
  {
    const Bits b = randomBits(1225, seed ^ 205894u);
    put(p.c26, b);
    p.eval();
    bad += check("ccv_exb_ext_out", "tl_out", p.c26_f0, b, 0, 1225);
  }
  {
    const Bits b = randomBits(184, seed ^ 213813u);
    put(p.c27, b);
    p.eval();
    bad += check("ccv_rau_fet_launch", "warp_id", p.c27_f0, b, 179, 5);
    bad += check("ccv_rau_fet_launch", "start_pc", p.c27_f1, b, 115, 64);
    bad += check("ccv_rau_fet_launch", "code_bounds", p.c27_f2, b, 11, 104);
    bad += check("ccv_rau_fet_launch", "asid", p.c27_f3, b, 3, 8);
    bad += check("ccv_rau_fet_launch", "cta_slot", p.c27_f4, b, 0, 3);
  }
  {
    const Bits b = randomBits(59, seed ^ 221732u);
    put(p.c28, b);
    p.eval();
    bad += check("ccv_rau_ooe_alloc", "warp_id", p.c28_f0, b, 54, 5);
    bad += check("ccv_rau_ooe_alloc", "prf_base", p.c28_f1, b, 46, 8);
    bad += check("ccv_rau_ooe_alloc", "prf_size", p.c28_f2, b, 38, 8);
    bad += check("ccv_rau_ooe_alloc", "activate_or_free", p.c28_f3, b, 37, 1);
    bad += check("ccv_rau_ooe_alloc", "ctaid", p.c28_f4, b, 5, 32);
    bad += check("ccv_rau_ooe_alloc", "warp_in_cta", p.c28_f5, b, 0, 5);
  }
  {
    const Bits b = randomBits(16, seed ^ 229651u);
    put(p.c29, b);
    p.eval();
    bad += check("ccv_ooe_rau_status", "warp_id", p.c29_f0, b, 11, 5);
    bad += check("ccv_ooe_rau_status", "fault_taken", p.c29_f1, b, 10, 1);
    bad += check("ccv_ooe_rau_status", "stalled", p.c29_f2, b, 9, 1);
    bad += check("ccv_ooe_rau_status", "mlc_miss_seen", p.c29_f3, b, 8, 1);
    bad += check("ccv_ooe_rau_status", "retired_since_restore", p.c29_f4, b, 0, 8);
  }
  {
    const Bits b = randomBits(6, seed ^ 237570u);
    put(p.c30, b);
    p.eval();
    bad += check("ccv_rau_ooe_demote", "warp_id", p.c30_f0, b, 1, 5);
    bad += check("ccv_rau_ooe_demote", "squash_to_retirement", p.c30_f1, b, 0, 1);
  }
  {
    const Bits b = randomBits(70, seed ^ 245489u);
    put(p.c31, b);
    p.eval();
    bad += check("ccv_ooe_rau_drained", "warp_id", p.c31_f0, b, 65, 5);
    bad += check("ccv_ooe_rau_drained", "resume_pc", p.c31_f1, b, 1, 64);
    bad += check("ccv_ooe_rau_drained", "arch_state_ready", p.c31_f2, b, 0, 1);
  }
  {
    const Bits b = randomBits(9, seed ^ 253408u);
    put(p.c32, b);
    p.eval();
    bad += check("ccv_rau_rcu_mig", "warp_id", p.c32_f0, b, 4, 5);
    bad += check("ccv_rau_rcu_mig", "direction", p.c32_f1, b, 3, 1);
    bad += check("ccv_rau_rcu_mig", "bank_select", p.c32_f2, b, 0, 3);
  }
  {
    const Bits b = randomBits(2057, seed ^ 261327u);
    put(p.c33, b);
    p.eval();
    bad += check("ccv_rcu_pca_mig", "warp_id", p.c33_f0, b, 2052, 5);
    bad += check("ccv_rcu_pca_mig", "row_idx", p.c33_f1, b, 2048, 4);
    bad += check("ccv_rcu_pca_mig", "gpr_row", p.c33_f2, b, 1024, 1024);
    bad += check("ccv_rcu_pca_mig", "pred_state", p.c33_f3, b, 0, 1024);
  }
  {
    const Bits b = randomBits(2057, seed ^ 269246u);
    put(p.c34, b);
    p.eval();
    bad += check("ccv_pca_rcu_mig", "warp_id", p.c34_f0, b, 2052, 5);
    bad += check("ccv_pca_rcu_mig", "row_idx", p.c34_f1, b, 2048, 4);
    bad += check("ccv_pca_rcu_mig", "gpr_row", p.c34_f2, b, 1024, 1024);
    bad += check("ccv_pca_rcu_mig", "pred_state", p.c34_f3, b, 0, 1024);
  }
  {
    const Bits b = randomBits(261, seed ^ 277165u);
    put(p.c35, b);
    p.eval();
    bad += check("ccv_fet_pca_mig", "warp_id", p.c35_f0, b, 256, 5);
    bad += check("ccv_fet_pca_mig", "pcs", p.c35_f1, b, 0, 256);
  }
  {
    const Bits b = randomBits(261, seed ^ 285084u);
    put(p.c36, b);
    p.eval();
    bad += check("ccv_pca_fet_mig", "warp_id", p.c36_f0, b, 256, 5);
    bad += check("ccv_pca_fet_mig", "pcs", p.c36_f1, b, 0, 256);
  }
  {
    const Bits b = randomBits(9, seed ^ 293003u);
    put(p.c37, b);
    p.eval();
    bad += check("ccv_rau_fet_mig", "warp_id", p.c37_f0, b, 4, 5);
    bad += check("ccv_rau_fet_mig", "direction", p.c37_f1, b, 3, 1);
    bad += check("ccv_rau_fet_mig", "bank_select", p.c37_f2, b, 0, 3);
  }
  {
    const Bits b = randomBits(5, seed ^ 300922u);
    put(p.c38, b);
    p.eval();
    bad += check("ccv_pca_rau_mig_done", "warp_id", p.c38_f0, b, 0, 5);
  }
  {
    const Bits b = randomBits(101, seed ^ 308841u);
    put(p.c39, b);
    p.eval();
    bad += check("ccv_rau_miu_cta", "cta_slot", p.c39_f0, b, 98, 3);
    bad += check("ccv_rau_miu_cta", "spm_base", p.c39_f1, b, 81, 17);
    bad += check("ccv_rau_miu_cta", "spm_limit", p.c39_f2, b, 64, 17);
    bad += check("ccv_rau_miu_cta", "launch_block_addr", p.c39_f3, b, 0, 64);
  }
  {
    const Bits b = randomBits(13, seed ^ 316760u);
    put(p.c40, b);
    p.eval();
    bad += check("ccv_ooe_syu_bar", "warp_id", p.c40_f0, b, 8, 5);
    bad += check("ccv_ooe_syu_bar", "cta_slot", p.c40_f1, b, 5, 3);
    bad += check("ccv_ooe_syu_bar", "barrier_id", p.c40_f2, b, 1, 4);
    bad += check("ccv_ooe_syu_bar", "arrive_or_wait", p.c40_f3, b, 0, 1);
  }
  {
    const Bits b = randomBits(36, seed ^ 324679u);
    put(p.c41, b);
    p.eval();
    bad += check("ccv_syu_ooe_rel", "warp_mask_released", p.c41_f0, b, 4, 32);
    bad += check("ccv_syu_ooe_rel", "barrier_id", p.c41_f1, b, 0, 4);
  }
  {
    const Bits b = randomBits(17, seed ^ 332598u);
    put(p.c42, b);
    p.eval();
    bad += check("ccv_rau_syu_alloc", "cta_slot", p.c42_f0, b, 14, 3);
    bad += check("ccv_rau_syu_alloc", "barrier_base", p.c42_f1, b, 8, 6);
    bad += check("ccv_rau_syu_alloc", "barrier_count", p.c42_f2, b, 1, 7);
    bad += check("ccv_rau_syu_alloc", "allocate_or_free", p.c42_f3, b, 0, 1);
  }
  {
    const Bits b = randomBits(172, seed ^ 340517u);
    put(p.c43, b);
    p.eval();
    bad += check("ccv_ooe_cru_fault", "cause", p.c43_f0, b, 168, 4);
    bad += check("ccv_ooe_cru_fault", "pc", p.c43_f1, b, 104, 64);
    bad += check("ccv_ooe_cru_fault", "lane_mask", p.c43_f2, b, 72, 32);
    bad += check("ccv_ooe_cru_fault", "address", p.c43_f3, b, 8, 64);
    bad += check("ccv_ooe_cru_fault", "cta_slot", p.c43_f4, b, 5, 3);
    bad += check("ccv_ooe_cru_fault", "warp_id", p.c43_f5, b, 0, 5);
  }
  {
    const Bits b = randomBits(74, seed ^ 348436u);
    put(p.c44, b);
    p.eval();
    bad += check("ccv_cru_rau_cfg", "demotion_threshold", p.c44_f0, b, 42, 32);
    bad += check("ccv_cru_rau_cfg", "progress_threshold", p.c44_f1, b, 10, 32);
    bad += check("ccv_cru_rau_cfg", "launch_enable", p.c44_f2, b, 9, 1);
    bad += check("ccv_cru_rau_cfg", "kill_req", p.c44_f3, b, 8, 1);
    bad += check("ccv_cru_rau_cfg", "kill_grid", p.c44_f4, b, 0, 8);
  }
  {
    const Bits b = randomBits(1176, seed ^ 356355u);
    put(p.c45, b);
    p.eval();
    bad += check("ccv_ext_exb_in", "tl_in", p.c45_f0, b, 0, 1176);
  }
  return bad;
}
