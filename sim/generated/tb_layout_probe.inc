// GENERATED FILE -- DO NOT EDIT.
//
// Produced by tools/gen-skel.py from schema/interfaces.json,
// params/blocks.json and params/ccv_params.json. Edit a source and
// regenerate; tools/verify.sh fails if this file is stale.

// Included by sim/skel/layout_probe.cpp, which supplies put/eq.

static unsigned probeOnce(Vtb_layout_probe &p, uint64_t seed) {
  unsigned bad = 0;
  {
    const Bits b = randomBits(162, seed ^ 0u);
    put(p.c0, b);
    p.eval();
    bad += check("ccv_fet_dec_instr", "warp_id", p.c0_f0, b, 157, 5);
    bad += check("ccv_fet_dec_instr", "tier1_id", p.c0_f1, b, 155, 2);
    bad += check("ccv_fet_dec_instr", "pc", p.c0_f2, b, 91, 64);
    bad += check("ccv_fet_dec_instr", "group_mask", p.c0_f3, b, 59, 32);
    bad += check("ccv_fet_dec_instr", "fetch_epoch", p.c0_f4, b, 56, 3);
    bad += check("ccv_fet_dec_instr", "instr", p.c0_f5, b, 8, 48);
    bad += check("ccv_fet_dec_instr", "length", p.c0_f6, b, 6, 2);
    bad += check("ccv_fet_dec_instr", "checkpoint_id", p.c0_f7, b, 4, 2);
    bad += check("ccv_fet_dec_instr", "pred_taken", p.c0_f8, b, 3, 1);
    bad += check("ccv_fet_dec_instr", "fetch_fault", p.c0_f9, b, 2, 1);
    bad += check("ccv_fet_dec_instr", "final_exit", p.c0_f10, b, 1, 1);
    bad += check("ccv_fet_dec_instr", "all_waiting", p.c0_f11, b, 0, 1);
  }
  {
    const Bits b = randomBits(7, seed ^ 7919u);
    put(p.c1, b);
    p.eval();
    bad += check("ccv_ooe_fet_decq_credit", "tier1_id", p.c1_f0, b, 5, 2);
    bad += check("ccv_ooe_fet_decq_credit", "credit_count", p.c1_f1, b, 1, 4);
    bad += check("ccv_ooe_fet_decq_credit", "released", p.c1_f2, b, 0, 1);
  }
  {
    const Bits b = randomBits(236, seed ^ 15838u);
    put(p.c2, b);
    p.eval();
    bad += check("ccv_dec_ooe_uop", "warp_id", p.c2_f0, b, 231, 5);
    bad += check("ccv_dec_ooe_uop", "pc", p.c2_f1, b, 167, 64);
    bad += check("ccv_dec_ooe_uop", "group_mask", p.c2_f2, b, 135, 32);
    bad += check("ccv_dec_ooe_uop", "fetch_epoch", p.c2_f3, b, 132, 3);
    bad += check("ccv_dec_ooe_uop", "uop_class", p.c2_f4, b, 129, 3);
    bad += check("ccv_dec_ooe_uop", "sched_attr", p.c2_f5, b, 108, 21);
    bad += check("ccv_dec_ooe_uop", "mem_op", p.c2_f6, b, 104, 4);
    bad += check("ccv_dec_ooe_uop", "space", p.c2_f7, b, 103, 1);
    bad += check("ccv_dec_ooe_uop", "ordering", p.c2_f8, b, 98, 5);
    bad += check("ccv_dec_ooe_uop", "opcode", p.c2_f9, b, 89, 9);
    bad += check("ccv_dec_ooe_uop", "src_arch", p.c2_f10, b, 81, 8);
    bad += check("ccv_dec_ooe_uop", "src2_arch", p.c2_f11, b, 77, 4);
    bad += check("ccv_dec_ooe_uop", "dst_arch", p.c2_f12, b, 73, 4);
    bad += check("ccv_dec_ooe_uop", "pred_guard", p.c2_f13, b, 71, 2);
    bad += check("ccv_dec_ooe_uop", "pred_neg", p.c2_f14, b, 70, 1);
    bad += check("ccv_dec_ooe_uop", "pred_dst", p.c2_f15, b, 68, 2);
    bad += check("ccv_dec_ooe_uop", "pred_we", p.c2_f16, b, 67, 1);
    bad += check("ccv_dec_ooe_uop", "src_valid", p.c2_f17, b, 64, 3);
    bad += check("ccv_dec_ooe_uop", "pred_use", p.c2_f18, b, 62, 2);
    bad += check("ccv_dec_ooe_uop", "imm_kind", p.c2_f19, b, 59, 3);
    bad += check("ccv_dec_ooe_uop", "imm", p.c2_f20, b, 27, 32);
    bad += check("ccv_dec_ooe_uop", "ilen", p.c2_f21, b, 25, 2);
    bad += check("ccv_dec_ooe_uop", "checkpoint_id", p.c2_f22, b, 23, 2);
    bad += check("ccv_dec_ooe_uop", "pred_taken", p.c2_f23, b, 22, 1);
    bad += check("ccv_dec_ooe_uop", "scale_en", p.c2_f24, b, 21, 1);
    bad += check("ccv_dec_ooe_uop", "cause", p.c2_f25, b, 17, 4);
    bad += check("ccv_dec_ooe_uop", "fmt_rsv", p.c2_f26, b, 13, 4);
    bad += check("ccv_dec_ooe_uop", "fmt_opnd", p.c2_f27, b, 11, 2);
    bad += check("ccv_dec_ooe_uop", "final_exit", p.c2_f28, b, 10, 1);
    bad += check("ccv_dec_ooe_uop", "all_waiting", p.c2_f29, b, 9, 1);
    bad += check("ccv_dec_ooe_uop", "slot_form", p.c2_f30, b, 8, 1);
    bad += check("ccv_dec_ooe_uop", "arg_slot", p.c2_f31, b, 4, 4);
    bad += check("ccv_dec_ooe_uop", "local_form", p.c2_f32, b, 3, 1);
    bad += check("ccv_dec_ooe_uop", "xfer_size", p.c2_f33, b, 1, 2);
    bad += check("ccv_dec_ooe_uop", "xfer_signed", p.c2_f34, b, 0, 1);
  }
  {
    const Bits b = randomBits(177, seed ^ 23757u);
    put(p.c3, b);
    p.eval();
    bad += check("ccv_ooe_rcu_issue", "rob_tag", p.c3_f0, b, 170, 7);
    bad += check("ccv_ooe_rcu_issue", "done_row", p.c3_f1, b, 168, 2);
    bad += check("ccv_ooe_rcu_issue", "warp_id", p.c3_f2, b, 163, 5);
    bad += check("ccv_ooe_rcu_issue", "issue_mask", p.c3_f3, b, 131, 32);
    bad += check("ccv_ooe_rcu_issue", "phys_src", p.c3_f4, b, 115, 16);
    bad += check("ccv_ooe_rcu_issue", "phys_src2", p.c3_f5, b, 107, 8);
    bad += check("ccv_ooe_rcu_issue", "phys_dst", p.c3_f6, b, 99, 8);
    bad += check("ccv_ooe_rcu_issue", "phys_old_dst", p.c3_f7, b, 91, 8);
    bad += check("ccv_ooe_rcu_issue", "phys_pred_guard", p.c3_f8, b, 85, 6);
    bad += check("ccv_ooe_rcu_issue", "pred_neg", p.c3_f9, b, 84, 1);
    bad += check("ccv_ooe_rcu_issue", "phys_pred_dst", p.c3_f10, b, 78, 6);
    bad += check("ccv_ooe_rcu_issue", "phys_pred_old_dst", p.c3_f11, b, 72, 6);
    bad += check("ccv_ooe_rcu_issue", "pred_we", p.c3_f12, b, 71, 1);
    bad += check("ccv_ooe_rcu_issue", "merge_en", p.c3_f13, b, 70, 1);
    bad += check("ccv_ooe_rcu_issue", "cont", p.c3_f14, b, 69, 1);
    bad += check("ccv_ooe_rcu_issue", "footprint", p.c3_f15, b, 65, 4);
    bad += check("ccv_ooe_rcu_issue", "bypass_group", p.c3_f16, b, 62, 3);
    bad += check("ccv_ooe_rcu_issue", "src_pos", p.c3_f17, b, 56, 6);
    bad += check("ccv_ooe_rcu_issue", "src_width", p.c3_f18, b, 50, 6);
    bad += check("ccv_ooe_rcu_issue", "dst_pos", p.c3_f19, b, 48, 2);
    bad += check("ccv_ooe_rcu_issue", "old_dst_pos", p.c3_f20, b, 46, 2);
    bad += check("ccv_ooe_rcu_issue", "dst_width", p.c3_f21, b, 44, 2);
    bad += check("ccv_ooe_rcu_issue", "opcode", p.c3_f22, b, 35, 9);
    bad += check("ccv_ooe_rcu_issue", "imm", p.c3_f23, b, 3, 32);
    bad += check("ccv_ooe_rcu_issue", "chwidth", p.c3_f24, b, 1, 2);
    bad += check("ccv_ooe_rcu_issue", "dispatch_fault", p.c3_f25, b, 0, 1);
  }
  {
    const Bits b = randomBits(344, seed ^ 31676u);
    put(p.c4, b);
    p.eval();
    bad += check("ccv_rcu_lane_ops", "sec_opcode", p.c4_f0, b, 308, 36);
    bad += check("ccv_rcu_lane_ops", "operand", p.c4_f1, b, 212, 96);
    bad += check("ccv_rcu_lane_ops", "merge_data", p.c4_f2, b, 180, 32);
    bad += check("ccv_rcu_lane_ops", "section_en", p.c4_f3, b, 176, 4);
    bad += check("ccv_rcu_lane_ops", "sec_owner", p.c4_f4, b, 168, 8);
    bad += check("ccv_rcu_lane_ops", "sec_pred_bit", p.c4_f5, b, 164, 4);
    bad += check("ccv_rcu_lane_ops", "sec_pred_data", p.c4_f6, b, 160, 4);
    bad += check("ccv_rcu_lane_ops", "sec_opnd_pos", p.c4_f7, b, 128, 32);
    bad += check("ccv_rcu_lane_ops", "sec_opnd_width", p.c4_f8, b, 96, 32);
    bad += check("ccv_rcu_lane_ops", "sec_dst_pos", p.c4_f9, b, 88, 8);
    bad += check("ccv_rcu_lane_ops", "sec_dst_width", p.c4_f10, b, 80, 8);
    bad += check("ccv_rcu_lane_ops", "operand_byp", p.c4_f11, b, 0, 80);
  }
  {
    const Bits b = randomBits(40, seed ^ 39595u);
    put(p.c5, b);
    p.eval();
    bad += check("ccv_lane_rcu_res", "result", p.c5_f0, b, 8, 32);
    bad += check("ccv_lane_rcu_res", "sec_valid", p.c5_f1, b, 4, 4);
    bad += check("ccv_lane_rcu_res", "sec_pred_out", p.c5_f2, b, 0, 4);
  }
  {
    const Bits b = randomBits(74, seed ^ 47514u);
    put(p.c6, b);
    p.eval();
    bad += check("ccv_rcu_ooe_done", "rob_tag", p.c6_f0, b, 67, 7);
    bad += check("ccv_rcu_ooe_done", "done_row", p.c6_f1, b, 65, 2);
    bad += check("ccv_rcu_ooe_done", "branch_taken", p.c6_f2, b, 64, 1);
    bad += check("ccv_rcu_ooe_done", "branch_mask", p.c6_f3, b, 32, 32);
    bad += check("ccv_rcu_ooe_done", "aux", p.c6_f4, b, 0, 32);
  }
  {
    const Bits b = randomBits(3111, seed ^ 55433u);
    put(p.c7, b);
    p.eval();
    bad += check("ccv_rcu_miu_addr", "rob_tag", p.c7_f0, b, 3104, 7);
    bad += check("ccv_rcu_miu_addr", "active_mask", p.c7_f1, b, 3072, 32);
    bad += check("ccv_rcu_miu_addr", "base_per_lane", p.c7_f2, b, 2048, 1024);
    bad += check("ccv_rcu_miu_addr", "index_per_lane", p.c7_f3, b, 1024, 1024);
    bad += check("ccv_rcu_miu_addr", "store_data", p.c7_f4, b, 0, 1024);
  }
  {
    const Bits b = randomBits(1114, seed ^ 63352u);
    put(p.c8, b);
    p.eval();
    bad += check("ccv_miu_rcu_data", "rob_tag", p.c8_f0, b, 1107, 7);
    bad += check("ccv_miu_rcu_data", "active_mask", p.c8_f1, b, 1075, 32);
    bad += check("ccv_miu_rcu_data", "pred_result", p.c8_f2, b, 1043, 32);
    bad += check("ccv_miu_rcu_data", "phys_dst", p.c8_f3, b, 1035, 8);
    bad += check("ccv_miu_rcu_data", "dst_pos", p.c8_f4, b, 1033, 2);
    bad += check("ccv_miu_rcu_data", "dst_width", p.c8_f5, b, 1031, 2);
    bad += check("ccv_miu_rcu_data", "phys_pred", p.c8_f6, b, 1025, 6);
    bad += check("ccv_miu_rcu_data", "pred_we", p.c8_f7, b, 1024, 1);
    bad += check("ccv_miu_rcu_data", "load_data", p.c8_f8, b, 0, 1024);
  }
  {
    const Bits b = randomBits(126, seed ^ 71271u);
    put(p.c9, b);
    p.eval();
    bad += check("ccv_ooe_miu_memop", "rob_tag", p.c9_f0, b, 119, 7);
    bad += check("ccv_ooe_miu_memop", "done_row", p.c9_f1, b, 117, 2);
    bad += check("ccv_ooe_miu_memop", "rs_idx", p.c9_f2, b, 111, 6);
    bad += check("ccv_ooe_miu_memop", "phys_dst", p.c9_f3, b, 103, 8);
    bad += check("ccv_ooe_miu_memop", "dst_pos", p.c9_f4, b, 101, 2);
    bad += check("ccv_ooe_miu_memop", "phys_pred", p.c9_f5, b, 95, 6);
    bad += check("ccv_ooe_miu_memop", "issue_mask", p.c9_f6, b, 63, 32);
    bad += check("ccv_ooe_miu_memop", "warp_id", p.c9_f7, b, 58, 5);
    bad += check("ccv_ooe_miu_memop", "cta_slot", p.c9_f8, b, 55, 3);
    bad += check("ccv_ooe_miu_memop", "mem_op", p.c9_f9, b, 51, 4);
    bad += check("ccv_ooe_miu_memop", "chwidth", p.c9_f10, b, 49, 2);
    bad += check("ccv_ooe_miu_memop", "pipes", p.c9_f11, b, 45, 4);
    bad += check("ccv_ooe_miu_memop", "disp", p.c9_f12, b, 16, 29);
    bad += check("ccv_ooe_miu_memop", "scale_en", p.c9_f13, b, 15, 1);
    bad += check("ccv_ooe_miu_memop", "space", p.c9_f14, b, 14, 1);
    bad += check("ccv_ooe_miu_memop", "ordering", p.c9_f15, b, 9, 5);
    bad += check("ccv_ooe_miu_memop", "slot_form", p.c9_f16, b, 8, 1);
    bad += check("ccv_ooe_miu_memop", "arg_slot", p.c9_f17, b, 4, 4);
    bad += check("ccv_ooe_miu_memop", "local_form", p.c9_f18, b, 3, 1);
    bad += check("ccv_ooe_miu_memop", "xfer_size", p.c9_f19, b, 1, 2);
    bad += check("ccv_ooe_miu_memop", "xfer_signed", p.c9_f20, b, 0, 1);
  }
  {
    const Bits b = randomBits(119, seed ^ 79190u);
    put(p.c10, b);
    p.eval();
    bad += check("ccv_miu_ooe_cmpl", "rob_tag", p.c10_f0, b, 112, 7);
    bad += check("ccv_miu_ooe_cmpl", "done_row", p.c10_f1, b, 110, 2);
    bad += check("ccv_miu_ooe_cmpl", "rs_idx", p.c10_f2, b, 104, 6);
    bad += check("ccv_miu_ooe_cmpl", "status", p.c10_f3, b, 102, 2);
    bad += check("ccv_miu_ooe_cmpl", "cause", p.c10_f4, b, 98, 4);
    bad += check("ccv_miu_ooe_cmpl", "lane_mask", p.c10_f5, b, 66, 32);
    bad += check("ccv_miu_ooe_cmpl", "address", p.c10_f6, b, 2, 64);
    bad += check("ccv_miu_ooe_cmpl", "mlc_miss", p.c10_f7, b, 1, 1);
    bad += check("ccv_miu_ooe_cmpl", "more", p.c10_f8, b, 0, 1);
  }
  {
    const Bits b = randomBits(8, seed ^ 87109u);
    put(p.c11, b);
    p.eval();
    bad += check("ccv_ooe_miu_retire", "rob_tag", p.c11_f0, b, 1, 7);
    bad += check("ccv_ooe_miu_retire", "commit_or_discard", p.c11_f1, b, 0, 1);
  }
  {
    const Bits b = randomBits(114, seed ^ 95028u);
    put(p.c12, b);
    p.eval();
    bad += check("ccv_ooe_fet_redirect", "warp_id", p.c12_f0, b, 109, 5);
    bad += check("ccv_ooe_fet_redirect", "tier1_id", p.c12_f1, b, 107, 2);
    bad += check("ccv_ooe_fet_redirect", "checkpoint_id", p.c12_f2, b, 105, 2);
    bad += check("ccv_ooe_fet_redirect", "taken_mask", p.c12_f3, b, 73, 32);
    bad += check("ccv_ooe_fet_redirect", "target_pc", p.c12_f4, b, 9, 64);
    bad += check("ccv_ooe_fet_redirect", "fetch_epoch", p.c12_f5, b, 6, 3);
    bad += check("ccv_ooe_fet_redirect", "epoch_only", p.c12_f6, b, 5, 1);
    bad += check("ccv_ooe_fet_redirect", "rewind", p.c12_f7, b, 4, 1);
    bad += check("ccv_ooe_fet_redirect", "rewind_held", p.c12_f8, b, 3, 1);
    bad += check("ccv_ooe_fet_redirect", "held_long", p.c12_f9, b, 2, 1);
    bad += check("ccv_ooe_fet_redirect", "own_pc", p.c12_f10, b, 1, 1);
    bad += check("ccv_ooe_fet_redirect", "stay", p.c12_f11, b, 0, 1);
  }
  {
    const Bits b = randomBits(16, seed ^ 102947u);
    put(p.c13, b);
    p.eval();
    bad += check("ccv_ooe_fet_ckpt_free", "free_mask", p.c13_f0, b, 0, 16);
  }
  {
    const Bits b = randomBits(1477, seed ^ 110866u);
    put(p.c14, b);
    p.eval();
    bad += check("ccv_miu_spm_req", "req_id", p.c14_f0, b, 1474, 3);
    bad += check("ccv_miu_spm_req", "bank_addr", p.c14_f1, b, 1154, 320);
    bad += check("ccv_miu_spm_req", "write_data", p.c14_f2, b, 130, 1024);
    bad += check("ccv_miu_spm_req", "byte_mask", p.c14_f3, b, 2, 128);
    bad += check("ccv_miu_spm_req", "spm_op", p.c14_f4, b, 0, 2);
  }
  {
    const Bits b = randomBits(1033, seed ^ 118785u);
    put(p.c15, b);
    p.eval();
    bad += check("ccv_spm_miu_rsp", "req_id", p.c15_f0, b, 1030, 3);
    bad += check("ccv_spm_miu_rsp", "read_data", p.c15_f1, b, 6, 1024);
    bad += check("ccv_spm_miu_rsp", "conflict_serialization", p.c15_f2, b, 0, 6);
  }
  {
    const Bits b = randomBits(1212, seed ^ 126704u);
    put(p.c16, b);
    p.eval();
    bad += check("ccv_miu_dcu_req", "req_id", p.c16_f0, b, 1208, 4);
    bad += check("ccv_miu_dcu_req", "phys_addr", p.c16_f1, b, 1160, 48);
    bad += check("ccv_miu_dcu_req", "size", p.c16_f2, b, 1157, 3);
    bad += check("ccv_miu_dcu_req", "coh_op", p.c16_f3, b, 1153, 4);
    bad += check("ccv_miu_dcu_req", "exclusive_req", p.c16_f4, b, 1152, 1);
    bad += check("ccv_miu_dcu_req", "write_data", p.c16_f5, b, 128, 1024);
    bad += check("ccv_miu_dcu_req", "byte_mask", p.c16_f6, b, 0, 128);
  }
  {
    const Bits b = randomBits(1031, seed ^ 134623u);
    put(p.c17, b);
    p.eval();
    bad += check("ccv_dcu_miu_rsp", "req_id", p.c17_f0, b, 1027, 4);
    bad += check("ccv_dcu_miu_rsp", "read_data", p.c17_f1, b, 3, 1024);
    bad += check("ccv_dcu_miu_rsp", "hit", p.c17_f2, b, 2, 1);
    bad += check("ccv_dcu_miu_rsp", "ownership_granted", p.c17_f3, b, 1, 1);
    bad += check("ccv_dcu_miu_rsp", "mlc_miss", p.c17_f4, b, 0, 1);
  }
  {
    const Bits b = randomBits(1082, seed ^ 142542u);
    put(p.c18, b);
    p.eval();
    bad += check("ccv_dcu_mlc_req", "req_id", p.c18_f0, b, 1078, 4);
    bad += check("ccv_dcu_mlc_req", "phys_addr", p.c18_f1, b, 1030, 48);
    bad += check("ccv_dcu_mlc_req", "coh_op", p.c18_f2, b, 1026, 4);
    bad += check("ccv_dcu_mlc_req", "core_id", p.c18_f3, b, 1024, 2);
    bad += check("ccv_dcu_mlc_req", "writeback_data", p.c18_f4, b, 0, 1024);
  }
  {
    const Bits b = randomBits(1030, seed ^ 150461u);
    put(p.c19, b);
    p.eval();
    bad += check("ccv_mlc_dcu_rsp", "req_id", p.c19_f0, b, 1026, 4);
    bad += check("ccv_mlc_dcu_rsp", "line_data", p.c19_f1, b, 2, 1024);
    bad += check("ccv_mlc_dcu_rsp", "ownership", p.c19_f2, b, 1, 1);
    bad += check("ccv_mlc_dcu_rsp", "miss", p.c19_f3, b, 0, 1);
  }
  {
    const Bits b = randomBits(51, seed ^ 158380u);
    put(p.c20, b);
    p.eval();
    bad += check("ccv_mlc_dcu_probe", "req_id", p.c20_f0, b, 49, 2);
    bad += check("ccv_mlc_dcu_probe", "phys_addr", p.c20_f1, b, 1, 48);
    bad += check("ccv_mlc_dcu_probe", "invalidate_or_downgrade", p.c20_f2, b, 0, 1);
  }
  {
    const Bits b = randomBits(1027, seed ^ 166299u);
    put(p.c21, b);
    p.eval();
    bad += check("ccv_dcu_mlc_probe_ack", "req_id", p.c21_f0, b, 1025, 2);
    bad += check("ccv_dcu_mlc_probe_ack", "ack", p.c21_f1, b, 1024, 1);
    bad += check("ccv_dcu_mlc_probe_ack", "dirty_data", p.c21_f2, b, 0, 1024);
  }
  {
    const Bits b = randomBits(50, seed ^ 174218u);
    put(p.c22, b);
    p.eval();
    bad += check("ccv_fet_mlc_ifill", "req_id", p.c22_f0, b, 48, 2);
    bad += check("ccv_fet_mlc_ifill", "phys_addr", p.c22_f1, b, 0, 48);
  }
  {
    const Bits b = randomBits(1026, seed ^ 182137u);
    put(p.c23, b);
    p.eval();
    bad += check("ccv_mlc_fet_ifill_rsp", "req_id", p.c23_f0, b, 1024, 2);
    bad += check("ccv_mlc_fet_ifill_rsp", "line_data", p.c23_f1, b, 0, 1024);
  }
  {
    const Bits b = randomBits(64, seed ^ 190056u);
    put(p.c24, b);
    p.eval();
    bad += check("ccv_miu_fet_itlb", "itlb_refill", p.c24_f0, b, 0, 64);
  }
  {
    const Bits b = randomBits(60, seed ^ 197975u);
    put(p.c25, b);
    p.eval();
    bad += check("ccv_fet_miu_itlb_req", "virtual_page", p.c25_f0, b, 8, 52);
    bad += check("ccv_fet_miu_itlb_req", "asid", p.c25_f1, b, 0, 8);
  }
  {
    const Bits b = randomBits(1090, seed ^ 205894u);
    put(p.c26, b);
    p.eval();
    bad += check("ccv_mlc_exb_req", "req_id", p.c26_f0, b, 1084, 6);
    bad += check("ccv_mlc_exb_req", "phys_addr", p.c26_f1, b, 1036, 48);
    bad += check("ccv_mlc_exb_req", "size", p.c26_f2, b, 1033, 3);
    bad += check("ccv_mlc_exb_req", "coh_op", p.c26_f3, b, 1029, 4);
    bad += check("ccv_mlc_exb_req", "ownership_class", p.c26_f4, b, 1026, 3);
    bad += check("ccv_mlc_exb_req", "core_id", p.c26_f5, b, 1024, 2);
    bad += check("ccv_mlc_exb_req", "writeback_data", p.c26_f6, b, 0, 1024);
  }
  {
    const Bits b = randomBits(1082, seed ^ 213813u);
    put(p.c27, b);
    p.eval();
    bad += check("ccv_exb_mlc_rsp", "req_id", p.c27_f0, b, 1076, 6);
    bad += check("ccv_exb_mlc_rsp", "probe_type", p.c27_f1, b, 1074, 2);
    bad += check("ccv_exb_mlc_rsp", "phys_addr", p.c27_f2, b, 1026, 48);
    bad += check("ccv_exb_mlc_rsp", "line_data", p.c27_f3, b, 2, 1024);
    bad += check("ccv_exb_mlc_rsp", "ownership_grant", p.c27_f4, b, 1, 1);
    bad += check("ccv_exb_mlc_rsp", "miss", p.c27_f5, b, 0, 1);
  }
  {
    const Bits b = randomBits(1225, seed ^ 221732u);
    put(p.c28, b);
    p.eval();
    bad += check("ccv_exb_ext_out", "tl_out", p.c28_f0, b, 0, 1225);
  }
  {
    const Bits b = randomBits(218, seed ^ 229651u);
    put(p.c29, b);
    p.eval();
    bad += check("ccv_rau_fet_launch", "warp_id", p.c29_f0, b, 213, 5);
    bad += check("ccv_rau_fet_launch", "tier1_id", p.c29_f1, b, 211, 2);
    bad += check("ccv_rau_fet_launch", "start_pc", p.c29_f2, b, 147, 64);
    bad += check("ccv_rau_fet_launch", "code_bounds", p.c29_f3, b, 43, 104);
    bad += check("ccv_rau_fet_launch", "asid", p.c29_f4, b, 35, 8);
    bad += check("ccv_rau_fet_launch", "cta_slot", p.c29_f5, b, 32, 3);
    bad += check("ccv_rau_fet_launch", "live_mask", p.c29_f6, b, 0, 32);
  }
  {
    const Bits b = randomBits(54, seed ^ 237570u);
    put(p.c30, b);
    p.eval();
    bad += check("ccv_rau_ooe_alloc", "warp_id", p.c30_f0, b, 49, 5);
    bad += check("ccv_rau_ooe_alloc", "tier1_id", p.c30_f1, b, 47, 2);
    bad += check("ccv_rau_ooe_alloc", "alloc_op", p.c30_f2, b, 45, 2);
    bad += check("ccv_rau_ooe_alloc", "ctaid", p.c30_f3, b, 13, 32);
    bad += check("ccv_rau_ooe_alloc", "warp_in_cta", p.c30_f4, b, 8, 5);
    bad += check("ccv_rau_ooe_alloc", "barrier_count", p.c30_f5, b, 3, 5);
    bad += check("ccv_rau_ooe_alloc", "cta_slot", p.c30_f6, b, 0, 3);
  }
  {
    const Bits b = randomBits(17, seed ^ 245489u);
    put(p.c31, b);
    p.eval();
    bad += check("ccv_ooe_rau_status", "warp_id", p.c31_f0, b, 12, 5);
    bad += check("ccv_ooe_rau_status", "fault_taken", p.c31_f1, b, 11, 1);
    bad += check("ccv_ooe_rau_status", "stalled", p.c31_f2, b, 10, 1);
    bad += check("ccv_ooe_rau_status", "mlc_miss_seen", p.c31_f3, b, 9, 1);
    bad += check("ccv_ooe_rau_status", "retired_since_restore", p.c31_f4, b, 1, 8);
    bad += check("ccv_ooe_rau_status", "exited", p.c31_f5, b, 0, 1);
  }
  {
    const Bits b = randomBits(6, seed ^ 253408u);
    put(p.c32, b);
    p.eval();
    bad += check("ccv_rau_ooe_demote", "warp_id", p.c32_f0, b, 1, 5);
    bad += check("ccv_rau_ooe_demote", "squash_to_retirement", p.c32_f1, b, 0, 1);
  }
  {
    const Bits b = randomBits(71, seed ^ 261327u);
    put(p.c33, b);
    p.eval();
    bad += check("ccv_ooe_rau_drained", "warp_id", p.c33_f0, b, 66, 5);
    bad += check("ccv_ooe_rau_drained", "resume_pc", p.c33_f1, b, 2, 64);
    bad += check("ccv_ooe_rau_drained", "arch_state_ready", p.c33_f2, b, 1, 1);
    bad += check("ccv_ooe_rau_drained", "refused", p.c33_f3, b, 0, 1);
  }
  {
    const Bits b = randomBits(6, seed ^ 269246u);
    put(p.c34, b);
    p.eval();
    bad += check("ccv_rau_rcu_mig", "warp_id", p.c34_f0, b, 1, 5);
    bad += check("ccv_rau_rcu_mig", "direction", p.c34_f1, b, 0, 1);
  }
  {
    const Bits b = randomBits(222, seed ^ 277165u);
    put(p.c35, b);
    p.eval();
    bad += check("ccv_ooe_rcu_map", "warp_id", p.c35_f0, b, 217, 5);
    bad += check("ccv_ooe_rcu_map", "direction", p.c35_f1, b, 216, 1);
    bad += check("ccv_ooe_rcu_map", "gpr_map", p.c35_f2, b, 88, 128);
    bad += check("ccv_ooe_rcu_map", "gpr_pos", p.c35_f3, b, 56, 32);
    bad += check("ccv_ooe_rcu_map", "gpr_width", p.c35_f4, b, 24, 32);
    bad += check("ccv_ooe_rcu_map", "pred_map", p.c35_f5, b, 0, 24);
  }
  {
    const Bits b = randomBits(1034, seed ^ 285084u);
    put(p.c36, b);
    p.eval();
    bad += check("ccv_rcu_pca_mig", "warp_id", p.c36_f0, b, 1029, 5);
    bad += check("ccv_rcu_pca_mig", "mig_row", p.c36_f1, b, 1024, 5);
    bad += check("ccv_rcu_pca_mig", "row_data", p.c36_f2, b, 0, 1024);
  }
  {
    const Bits b = randomBits(1034, seed ^ 293003u);
    put(p.c37, b);
    p.eval();
    bad += check("ccv_pca_rcu_mig", "warp_id", p.c37_f0, b, 1029, 5);
    bad += check("ccv_pca_rcu_mig", "mig_row", p.c37_f1, b, 1024, 5);
    bad += check("ccv_pca_rcu_mig", "row_data", p.c37_f2, b, 0, 1024);
  }
  {
    const Bits b = randomBits(1056, seed ^ 300922u);
    put(p.c38, b);
    p.eval();
    bad += check("ccv_fet_pca_mig", "warp_id", p.c38_f0, b, 1051, 5);
    bad += check("ccv_fet_pca_mig", "lane_pcs", p.c38_f1, b, 59, 992);
    bad += check("ccv_fet_pca_mig", "pc_upper", p.c38_f2, b, 43, 16);
    bad += check("ccv_fet_pca_mig", "fair_ptr", p.c38_f3, b, 38, 5);
    bad += check("ccv_fet_pca_mig", "fair_cnt", p.c38_f4, b, 32, 6);
    bad += check("ccv_fet_pca_mig", "live_mask", p.c38_f5, b, 0, 32);
  }
  {
    const Bits b = randomBits(1056, seed ^ 308841u);
    put(p.c39, b);
    p.eval();
    bad += check("ccv_pca_fet_mig", "warp_id", p.c39_f0, b, 1051, 5);
    bad += check("ccv_pca_fet_mig", "lane_pcs", p.c39_f1, b, 59, 992);
    bad += check("ccv_pca_fet_mig", "pc_upper", p.c39_f2, b, 43, 16);
    bad += check("ccv_pca_fet_mig", "fair_ptr", p.c39_f3, b, 38, 5);
    bad += check("ccv_pca_fet_mig", "fair_cnt", p.c39_f4, b, 32, 6);
    bad += check("ccv_pca_fet_mig", "live_mask", p.c39_f5, b, 0, 32);
  }
  {
    const Bits b = randomBits(8, seed ^ 316760u);
    put(p.c40, b);
    p.eval();
    bad += check("ccv_rau_fet_mig", "warp_id", p.c40_f0, b, 3, 5);
    bad += check("ccv_rau_fet_mig", "tier1_id", p.c40_f1, b, 1, 2);
    bad += check("ccv_rau_fet_mig", "direction", p.c40_f2, b, 0, 1);
  }
  {
    const Bits b = randomBits(6, seed ^ 324679u);
    put(p.c41, b);
    p.eval();
    bad += check("ccv_pca_rau_mig_done", "warp_id", p.c41_f0, b, 1, 5);
    bad += check("ccv_pca_rau_mig_done", "direction", p.c41_f1, b, 0, 1);
  }
  {
    const Bits b = randomBits(11, seed ^ 332598u);
    put(p.c42, b);
    p.eval();
    bad += check("ccv_rau_pca_mig", "warp_id", p.c42_f0, b, 6, 5);
    bad += check("ccv_rau_pca_mig", "direction", p.c42_f1, b, 5, 1);
    bad += check("ccv_rau_pca_mig", "pca_place", p.c42_f2, b, 0, 5);
  }
  {
    const Bits b = randomBits(5, seed ^ 340517u);
    put(p.c43, b);
    p.eval();
    bad += check("ccv_miu_rau_ready", "warp_id", p.c43_f0, b, 0, 5);
  }
  {
    const Bits b = randomBits(277, seed ^ 348436u);
    put(p.c44, b);
    p.eval();
    bad += check("ccv_rau_miu_cta", "cta_slot", p.c44_f0, b, 274, 3);
    bad += check("ccv_rau_miu_cta", "spm_base", p.c44_f1, b, 257, 17);
    bad += check("ccv_rau_miu_cta", "spm_limit", p.c44_f2, b, 240, 17);
    bad += check("ccv_rau_miu_cta", "launch_block_addr", p.c44_f3, b, 176, 64);
    bad += check("ccv_rau_miu_cta", "const_base", p.c44_f4, b, 112, 64);
    bad += check("ccv_rau_miu_cta", "const_limit", p.c44_f5, b, 48, 64);
    bad += check("ccv_rau_miu_cta", "local_base", p.c44_f6, b, 0, 48);
  }
  {
    const Bits b = randomBits(111, seed ^ 356355u);
    put(p.c45, b);
    p.eval();
    bad += check("ccv_ooe_syu_bar", "warp_id", p.c45_f0, b, 106, 5);
    bad += check("ccv_ooe_syu_bar", "cta_slot", p.c45_f1, b, 103, 3);
    bad += check("ccv_ooe_syu_bar", "barrier_id", p.c45_f2, b, 99, 4);
    bad += check("ccv_ooe_syu_bar", "bar_kind", p.c45_f3, b, 97, 2);
    bad += check("ccv_ooe_syu_bar", "issue_mask", p.c45_f4, b, 65, 32);
    bad += check("ccv_ooe_syu_bar", "guard_mask", p.c45_f5, b, 33, 32);
    bad += check("ccv_ooe_syu_bar", "phase_mask", p.c45_f6, b, 1, 32);
    bad += check("ccv_ooe_syu_bar", "held", p.c45_f7, b, 0, 1);
  }
  {
    const Bits b = randomBits(5, seed ^ 364274u);
    put(p.c46, b);
    p.eval();
    bad += check("ccv_syu_ooe_rel", "warp_id", p.c46_f0, b, 0, 5);
  }
  {
    const Bits b = randomBits(37, seed ^ 372193u);
    put(p.c47, b);
    p.eval();
    bad += check("ccv_syu_fet_rel", "warp_id", p.c47_f0, b, 32, 5);
    bad += check("ccv_syu_fet_rel", "lane_mask", p.c47_f1, b, 0, 32);
  }
  {
    const Bits b = randomBits(5, seed ^ 380112u);
    put(p.c48, b);
    p.eval();
    bad += check("ccv_syu_rau_ready", "warp_id", p.c48_f0, b, 0, 5);
  }
  {
    const Bits b = randomBits(58, seed ^ 388031u);
    put(p.c49, b);
    p.eval();
    bad += check("ccv_rau_syu_alloc", "cta_slot", p.c49_f0, b, 55, 3);
    bad += check("ccv_rau_syu_alloc", "barrier_base", p.c49_f1, b, 49, 6);
    bad += check("ccv_rau_syu_alloc", "barrier_count", p.c49_f2, b, 44, 5);
    bad += check("ccv_rau_syu_alloc", "syu_alloc_op", p.c49_f3, b, 42, 2);
    bad += check("ccv_rau_syu_alloc", "warp_mask", p.c49_f4, b, 10, 32);
    bad += check("ccv_rau_syu_alloc", "warp_id", p.c49_f5, b, 5, 5);
    bad += check("ccv_rau_syu_alloc", "last_lanes", p.c49_f6, b, 0, 5);
  }
  {
    const Bits b = randomBits(172, seed ^ 395950u);
    put(p.c50, b);
    p.eval();
    bad += check("ccv_ooe_cru_fault", "cause", p.c50_f0, b, 168, 4);
    bad += check("ccv_ooe_cru_fault", "pc", p.c50_f1, b, 104, 64);
    bad += check("ccv_ooe_cru_fault", "lane_mask", p.c50_f2, b, 72, 32);
    bad += check("ccv_ooe_cru_fault", "address", p.c50_f3, b, 8, 64);
    bad += check("ccv_ooe_cru_fault", "cta_slot", p.c50_f4, b, 5, 3);
    bad += check("ccv_ooe_cru_fault", "warp_id", p.c50_f5, b, 0, 5);
  }
  {
    const Bits b = randomBits(74, seed ^ 403869u);
    put(p.c51, b);
    p.eval();
    bad += check("ccv_cru_rau_cfg", "demotion_threshold", p.c51_f0, b, 42, 32);
    bad += check("ccv_cru_rau_cfg", "progress_threshold", p.c51_f1, b, 10, 32);
    bad += check("ccv_cru_rau_cfg", "launch_enable", p.c51_f2, b, 9, 1);
    bad += check("ccv_cru_rau_cfg", "kill_req", p.c51_f3, b, 8, 1);
    bad += check("ccv_cru_rau_cfg", "kill_grid", p.c51_f4, b, 0, 8);
  }
  {
    const Bits b = randomBits(1176, seed ^ 411788u);
    put(p.c52, b);
    p.eval();
    bad += check("ccv_ext_exb_in", "tl_in", p.c52_f0, b, 0, 1176);
  }
  {
    const Bits b = randomBits(4, seed ^ 419707u);
    put(p.c53, b);
    p.eval();
    bad += check("ccv_dcu_miu_fill_ntc", "req_id", p.c53_f0, b, 0, 4);
  }
  {
    const Bits b = randomBits(13, seed ^ 427626u);
    put(p.c54, b);
    p.eval();
    bad += check("ccv_miu_ooe_cmpl_hint", "rs_idx", p.c54_f0, b, 7, 6);
    bad += check("ccv_miu_ooe_cmpl_hint", "rob_tag", p.c54_f1, b, 0, 7);
  }
  return bad;
}
