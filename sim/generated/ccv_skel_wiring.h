// GENERATED FILE -- DO NOT EDIT.
//
// Produced by tools/gen-skel.py from schema/interfaces.json,
// params/blocks.json and params/ccv_params.json. Edit a source and
// regenerate; tools/verify.sh fails if this file is stale.

#ifndef CCV_SKEL_WIRING_H
#define CCV_SKEL_WIRING_H

#include <cstdint>

namespace ccv {
namespace skel {

/// Block TYPES, in partition order. EXTERNAL is the testbench end
/// of an outbound external channel, not a block.
enum class Blk : uint8_t {
  FET,
  DEC,
  OOE,
  RCU,
  LANE,
  MIU,
  SPM,
  DCU,
  MLC,
  RAU,
  SYU,
  PCA,
  CRU,
  EXB,
  EXTERNAL,
};
constexpr unsigned kNumBlockTypes = 14;

inline const char *blkName(Blk b) {
  switch (b) {
  case Blk::FET: return "fet";
  case Blk::DEC: return "dec";
  case Blk::OOE: return "ooe";
  case Blk::RCU: return "rcu";
  case Blk::LANE: return "lane";
  case Blk::MIU: return "miu";
  case Blk::SPM: return "spm";
  case Blk::DCU: return "dcu";
  case Blk::MLC: return "mlc";
  case Blk::RAU: return "rau";
  case Blk::SYU: return "syu";
  case Blk::PCA: return "pca";
  case Blk::CRU: return "cru";
  case Blk::EXB: return "exb";
  case Blk::EXTERNAL: return "EXTERNAL";
  }
  return "?";
}

/// One bit field of a payload. lsb/width are positions in the
/// SystemVerilog PACKED struct: the first declared field is the
/// most significant.
/// `lead`: driven with valid, one cycle ahead of the rest of the
/// payload, in the same register (schema lead_fields).
struct FieldDesc { const char *name; uint32_t lsb; uint32_t width; bool lead; };

/// Ordering is a KEY: none; one order per binding group; or one
/// order per value of a payload field (e.g. warp_id).
enum class Order : uint8_t { kNone, kSlotGroup, kField };

struct ChanDesc {
  uint16_t id; const char *name; Blk src, dst;
  uint16_t rate;       ///< slots: independent credited channels
  uint32_t bits;       ///< payload width
  uint16_t nfields; const FieldDesc *fields;
  uint16_t ninst;      ///< copies, one per instance of a multi-instance end
  bool atomic;         ///< acceptance: a group moves together
  uint8_t bind_group;  ///< 0 = free; else slots per binding group
  Order order;         ///< ordering key kind
  int16_t order_field; ///< fields[] index when order == kField
  bool lockstep;       ///< all instances advance together
  uint8_t id_classes;  ///< bit (1 << IdClass) per class it may carry
  int16_t bind_key;    ///< fields[] index of the binding key, or -1:
                       ///< it must equal slot / bind_group
  bool fixed_lat;      ///< receiver never stalls, credits on landing (A-47)
  bool held;           ///< backpressured: its receiver may hold behind a stall (TI-22)
};

inline constexpr FieldDesc kF_ccv_fet_dec_instr[] = {
  {"warp_id", 157, 5, false},
  {"tier1_id", 155, 2, false},
  {"pc", 91, 64, false},
  {"group_mask", 59, 32, false},
  {"fetch_epoch", 56, 3, false},
  {"instr", 8, 48, false},
  {"length", 6, 2, false},
  {"checkpoint_id", 4, 2, false},
  {"pred_taken", 3, 1, false},
  {"fetch_fault", 2, 1, false},
  {"final_exit", 1, 1, false},
  {"all_waiting", 0, 1, false},
};
inline constexpr FieldDesc kF_ccv_dec_ooe_uop[] = {
  {"warp_id", 224, 5, false},
  {"pc", 160, 64, false},
  {"group_mask", 128, 32, false},
  {"fetch_epoch", 125, 3, false},
  {"uop_class", 122, 3, false},
  {"sched_attr", 105, 17, false},
  {"mem_op", 101, 4, false},
  {"space", 100, 1, false},
  {"ordering", 95, 5, false},
  {"opcode", 86, 9, false},
  {"src_arch", 78, 8, false},
  {"src2_arch", 74, 4, false},
  {"dst_arch", 70, 4, false},
  {"pred_guard", 68, 2, false},
  {"pred_neg", 67, 1, false},
  {"pred_dst", 65, 2, false},
  {"pred_we", 64, 1, false},
  {"src_valid", 61, 3, false},
  {"pred_use", 59, 2, false},
  {"imm_kind", 56, 3, false},
  {"imm", 24, 32, false},
  {"ilen", 22, 2, false},
  {"checkpoint_id", 20, 2, false},
  {"pred_taken", 19, 1, false},
  {"scale_en", 18, 1, false},
  {"cause", 14, 4, false},
  {"fmt_rsv", 10, 4, false},
  {"fmt_opnd", 8, 2, false},
  {"final_exit", 7, 1, false},
  {"all_waiting", 6, 1, false},
  {"slot_form", 5, 1, false},
  {"arg_slot", 1, 4, false},
  {"local_form", 0, 1, false},
};
inline constexpr FieldDesc kF_ccv_ooe_rcu_issue[] = {
  {"rob_tag", 168, 7, false},
  {"warp_id", 163, 5, false},
  {"issue_mask", 131, 32, false},
  {"phys_src", 115, 16, false},
  {"phys_src2", 107, 8, false},
  {"phys_dst", 99, 8, false},
  {"phys_old_dst", 91, 8, false},
  {"phys_pred_guard", 85, 6, false},
  {"pred_neg", 84, 1, false},
  {"phys_pred_dst", 78, 6, false},
  {"phys_pred_old_dst", 72, 6, false},
  {"pred_we", 71, 1, false},
  {"merge_en", 70, 1, false},
  {"cont", 69, 1, false},
  {"footprint", 65, 4, false},
  {"bypass_group", 62, 3, false},
  {"src_pos", 56, 6, false},
  {"src_width", 50, 6, false},
  {"dst_pos", 48, 2, false},
  {"old_dst_pos", 46, 2, false},
  {"dst_width", 44, 2, false},
  {"opcode", 35, 9, false},
  {"imm", 3, 32, false},
  {"chwidth", 1, 2, false},
  {"dispatch_fault", 0, 1, false},
};
inline constexpr FieldDesc kF_ccv_rcu_lane_ops[] = {
  {"sec_opcode", 308, 36, false},
  {"operand", 212, 96, false},
  {"merge_data", 180, 32, false},
  {"section_en", 176, 4, true},
  {"sec_owner", 168, 8, false},
  {"sec_pred_bit", 164, 4, true},
  {"sec_pred_data", 160, 4, false},
  {"sec_opnd_pos", 128, 32, false},
  {"sec_opnd_width", 96, 32, false},
  {"sec_dst_pos", 88, 8, false},
  {"sec_dst_width", 80, 8, false},
  {"operand_byp", 0, 80, false},
};
inline constexpr FieldDesc kF_ccv_lane_rcu_res[] = {
  {"result", 8, 32, false},
  {"sec_valid", 4, 4, false},
  {"sec_pred_out", 0, 4, false},
};
inline constexpr FieldDesc kF_ccv_rcu_ooe_done[] = {
  {"rob_tag", 33, 7, false},
  {"branch_taken", 32, 1, false},
  {"branch_mask", 0, 32, false},
};
inline constexpr FieldDesc kF_ccv_rcu_miu_addr[] = {
  {"rob_tag", 3104, 7, false},
  {"active_mask", 3072, 32, false},
  {"base_per_lane", 2048, 1024, false},
  {"index_per_lane", 1024, 1024, false},
  {"store_data", 0, 1024, false},
};
inline constexpr FieldDesc kF_ccv_miu_rcu_data[] = {
  {"rob_tag", 1107, 7, false},
  {"active_mask", 1075, 32, false},
  {"pred_result", 1043, 32, false},
  {"phys_dst", 1035, 8, false},
  {"dst_pos", 1033, 2, false},
  {"dst_width", 1031, 2, false},
  {"phys_pred", 1025, 6, false},
  {"pred_we", 1024, 1, false},
  {"load_data", 0, 1024, false},
};
inline constexpr FieldDesc kF_ccv_ooe_miu_memop[] = {
  {"rob_tag", 114, 7, false},
  {"rs_idx", 108, 6, false},
  {"phys_dst", 100, 8, false},
  {"dst_pos", 98, 2, false},
  {"phys_pred", 92, 6, false},
  {"issue_mask", 60, 32, false},
  {"warp_id", 55, 5, false},
  {"cta_slot", 52, 3, false},
  {"mem_op", 48, 4, false},
  {"chwidth", 46, 2, false},
  {"pipes", 42, 4, false},
  {"disp", 13, 29, false},
  {"scale_en", 12, 1, false},
  {"space", 11, 1, false},
  {"ordering", 6, 5, false},
  {"slot_form", 5, 1, false},
  {"arg_slot", 1, 4, false},
  {"local_form", 0, 1, false},
};
inline constexpr FieldDesc kF_ccv_miu_ooe_cmpl[] = {
  {"rob_tag", 110, 7, false},
  {"rs_idx", 104, 6, false},
  {"status", 102, 2, false},
  {"cause", 98, 4, false},
  {"lane_mask", 66, 32, false},
  {"address", 2, 64, false},
  {"mlc_miss", 1, 1, false},
  {"more", 0, 1, false},
};
inline constexpr FieldDesc kF_ccv_ooe_miu_retire[] = {
  {"rob_tag", 1, 7, false},
  {"commit_or_discard", 0, 1, false},
};
inline constexpr FieldDesc kF_ccv_ooe_fet_redirect[] = {
  {"warp_id", 107, 5, false},
  {"tier1_id", 105, 2, false},
  {"checkpoint_id", 103, 2, false},
  {"taken_mask", 71, 32, false},
  {"target_pc", 7, 64, false},
  {"fetch_epoch", 4, 3, false},
  {"epoch_only", 3, 1, false},
  {"rewind", 2, 1, false},
  {"rewind_held", 1, 1, false},
  {"held_long", 0, 1, false},
};
inline constexpr FieldDesc kF_ccv_ooe_fet_ckpt_free[] = {
  {"free_mask", 0, 16, false},
};
inline constexpr FieldDesc kF_ccv_miu_spm_req[] = {
  {"req_id", 1474, 3, false},
  {"bank_addr", 1154, 320, false},
  {"write_data", 130, 1024, false},
  {"byte_mask", 2, 128, false},
  {"spm_op", 0, 2, false},
};
inline constexpr FieldDesc kF_ccv_spm_miu_rsp[] = {
  {"req_id", 1030, 3, false},
  {"read_data", 6, 1024, false},
  {"conflict_serialization", 0, 6, false},
};
inline constexpr FieldDesc kF_ccv_miu_dcu_req[] = {
  {"req_id", 1208, 4, false},
  {"phys_addr", 1160, 48, false},
  {"size", 1157, 3, false},
  {"coh_op", 1153, 4, false},
  {"exclusive_req", 1152, 1, false},
  {"write_data", 128, 1024, false},
  {"byte_mask", 0, 128, false},
};
inline constexpr FieldDesc kF_ccv_dcu_miu_rsp[] = {
  {"req_id", 1027, 4, false},
  {"read_data", 3, 1024, false},
  {"hit", 2, 1, false},
  {"ownership_granted", 1, 1, false},
  {"mlc_miss", 0, 1, false},
};
inline constexpr FieldDesc kF_ccv_dcu_mlc_req[] = {
  {"req_id", 1078, 4, false},
  {"phys_addr", 1030, 48, false},
  {"coh_op", 1026, 4, false},
  {"core_id", 1024, 2, false},
  {"writeback_data", 0, 1024, false},
};
inline constexpr FieldDesc kF_ccv_mlc_dcu_rsp[] = {
  {"req_id", 1026, 4, false},
  {"line_data", 2, 1024, false},
  {"ownership", 1, 1, false},
  {"miss", 0, 1, false},
};
inline constexpr FieldDesc kF_ccv_mlc_dcu_probe[] = {
  {"req_id", 49, 2, false},
  {"phys_addr", 1, 48, false},
  {"invalidate_or_downgrade", 0, 1, false},
};
inline constexpr FieldDesc kF_ccv_dcu_mlc_probe_ack[] = {
  {"req_id", 1025, 2, false},
  {"ack", 1024, 1, false},
  {"dirty_data", 0, 1024, false},
};
inline constexpr FieldDesc kF_ccv_fet_mlc_ifill[] = {
  {"req_id", 48, 2, false},
  {"phys_addr", 0, 48, false},
};
inline constexpr FieldDesc kF_ccv_mlc_fet_ifill_rsp[] = {
  {"req_id", 1024, 2, false},
  {"line_data", 0, 1024, false},
};
inline constexpr FieldDesc kF_ccv_miu_fet_itlb[] = {
  {"itlb_refill", 0, 64, false},
};
inline constexpr FieldDesc kF_ccv_fet_miu_itlb_req[] = {
  {"virtual_page", 8, 52, false},
  {"asid", 0, 8, false},
};
inline constexpr FieldDesc kF_ccv_mlc_exb_req[] = {
  {"req_id", 1084, 6, false},
  {"phys_addr", 1036, 48, false},
  {"size", 1033, 3, false},
  {"coh_op", 1029, 4, false},
  {"ownership_class", 1026, 3, false},
  {"core_id", 1024, 2, false},
  {"writeback_data", 0, 1024, false},
};
inline constexpr FieldDesc kF_ccv_exb_mlc_rsp[] = {
  {"req_id", 1076, 6, false},
  {"probe_type", 1074, 2, false},
  {"phys_addr", 1026, 48, false},
  {"line_data", 2, 1024, false},
  {"ownership_grant", 1, 1, false},
  {"miss", 0, 1, false},
};
inline constexpr FieldDesc kF_ccv_exb_ext_out[] = {
  {"tl_out", 0, 1225, false},
};
inline constexpr FieldDesc kF_ccv_rau_fet_launch[] = {
  {"warp_id", 213, 5, false},
  {"tier1_id", 211, 2, false},
  {"start_pc", 147, 64, false},
  {"code_bounds", 43, 104, false},
  {"asid", 35, 8, false},
  {"cta_slot", 32, 3, false},
  {"live_mask", 0, 32, false},
};
inline constexpr FieldDesc kF_ccv_rau_ooe_alloc[] = {
  {"warp_id", 49, 5, false},
  {"tier1_id", 47, 2, false},
  {"alloc_op", 45, 2, false},
  {"ctaid", 13, 32, false},
  {"warp_in_cta", 8, 5, false},
  {"barrier_count", 3, 5, false},
  {"cta_slot", 0, 3, false},
};
inline constexpr FieldDesc kF_ccv_ooe_rau_status[] = {
  {"warp_id", 12, 5, false},
  {"fault_taken", 11, 1, false},
  {"stalled", 10, 1, false},
  {"mlc_miss_seen", 9, 1, false},
  {"retired_since_restore", 1, 8, false},
  {"exited", 0, 1, false},
};
inline constexpr FieldDesc kF_ccv_rau_ooe_demote[] = {
  {"warp_id", 1, 5, false},
  {"squash_to_retirement", 0, 1, false},
};
inline constexpr FieldDesc kF_ccv_ooe_rau_drained[] = {
  {"warp_id", 66, 5, false},
  {"resume_pc", 2, 64, false},
  {"arch_state_ready", 1, 1, false},
  {"refused", 0, 1, false},
};
inline constexpr FieldDesc kF_ccv_rau_rcu_mig[] = {
  {"warp_id", 1, 5, false},
  {"direction", 0, 1, false},
};
inline constexpr FieldDesc kF_ccv_ooe_rcu_map[] = {
  {"warp_id", 217, 5, false},
  {"direction", 216, 1, false},
  {"gpr_map", 88, 128, false},
  {"gpr_pos", 56, 32, false},
  {"gpr_width", 24, 32, false},
  {"pred_map", 0, 24, false},
};
inline constexpr FieldDesc kF_ccv_rcu_pca_mig[] = {
  {"warp_id", 1029, 5, false},
  {"mig_row", 1024, 5, false},
  {"row_data", 0, 1024, false},
};
inline constexpr FieldDesc kF_ccv_pca_rcu_mig[] = {
  {"warp_id", 1029, 5, false},
  {"mig_row", 1024, 5, false},
  {"row_data", 0, 1024, false},
};
inline constexpr FieldDesc kF_ccv_fet_pca_mig[] = {
  {"warp_id", 1051, 5, false},
  {"lane_pcs", 59, 992, false},
  {"pc_upper", 43, 16, false},
  {"fair_ptr", 38, 5, false},
  {"fair_cnt", 32, 6, false},
  {"live_mask", 0, 32, false},
};
inline constexpr FieldDesc kF_ccv_pca_fet_mig[] = {
  {"warp_id", 1051, 5, false},
  {"lane_pcs", 59, 992, false},
  {"pc_upper", 43, 16, false},
  {"fair_ptr", 38, 5, false},
  {"fair_cnt", 32, 6, false},
  {"live_mask", 0, 32, false},
};
inline constexpr FieldDesc kF_ccv_rau_fet_mig[] = {
  {"warp_id", 3, 5, false},
  {"tier1_id", 1, 2, false},
  {"direction", 0, 1, false},
};
inline constexpr FieldDesc kF_ccv_pca_rau_mig_done[] = {
  {"warp_id", 1, 5, false},
  {"direction", 0, 1, false},
};
inline constexpr FieldDesc kF_ccv_rau_pca_mig[] = {
  {"warp_id", 6, 5, false},
  {"direction", 5, 1, false},
  {"pca_place", 0, 5, false},
};
inline constexpr FieldDesc kF_ccv_miu_rau_ready[] = {
  {"warp_id", 0, 5, false},
};
inline constexpr FieldDesc kF_ccv_rau_miu_cta[] = {
  {"cta_slot", 226, 3, false},
  {"spm_base", 209, 17, false},
  {"spm_limit", 192, 17, false},
  {"launch_block_addr", 128, 64, false},
  {"const_base", 64, 64, false},
  {"const_limit", 0, 64, false},
};
inline constexpr FieldDesc kF_ccv_ooe_syu_bar[] = {
  {"warp_id", 106, 5, false},
  {"cta_slot", 103, 3, false},
  {"barrier_id", 99, 4, false},
  {"bar_kind", 97, 2, false},
  {"issue_mask", 65, 32, false},
  {"guard_mask", 33, 32, false},
  {"phase_mask", 1, 32, false},
  {"held", 0, 1, false},
};
inline constexpr FieldDesc kF_ccv_syu_ooe_rel[] = {
  {"warp_id", 0, 5, false},
};
inline constexpr FieldDesc kF_ccv_syu_fet_rel[] = {
  {"warp_id", 32, 5, false},
  {"lane_mask", 0, 32, false},
};
inline constexpr FieldDesc kF_ccv_syu_rau_ready[] = {
  {"warp_id", 0, 5, false},
};
inline constexpr FieldDesc kF_ccv_rau_syu_alloc[] = {
  {"cta_slot", 55, 3, false},
  {"barrier_base", 49, 6, false},
  {"barrier_count", 44, 5, false},
  {"syu_alloc_op", 42, 2, false},
  {"warp_mask", 10, 32, false},
  {"warp_id", 5, 5, false},
  {"last_lanes", 0, 5, false},
};
inline constexpr FieldDesc kF_ccv_ooe_cru_fault[] = {
  {"cause", 168, 4, false},
  {"pc", 104, 64, false},
  {"lane_mask", 72, 32, false},
  {"address", 8, 64, false},
  {"cta_slot", 5, 3, false},
  {"warp_id", 0, 5, false},
};
inline constexpr FieldDesc kF_ccv_cru_rau_cfg[] = {
  {"demotion_threshold", 42, 32, false},
  {"progress_threshold", 10, 32, false},
  {"launch_enable", 9, 1, false},
  {"kill_req", 8, 1, false},
  {"kill_grid", 0, 8, false},
};
inline constexpr FieldDesc kF_ccv_ext_exb_in[] = {
  {"tl_in", 0, 1176, false},
};
inline constexpr FieldDesc kF_ccv_dcu_miu_fill_ntc[] = {
  {"req_id", 0, 4, false},
};
inline constexpr FieldDesc kF_ccv_miu_ooe_cmpl_hint[] = {
  {"rs_idx", 7, 6, false},
  {"rob_tag", 0, 7, false},
};

inline constexpr ChanDesc kChans[] = {
  {0, "ccv_fet_dec_instr", Blk::FET, Blk::DEC, 8, 162, 12, kF_ccv_fet_dec_instr, 1, false, 2, Order::kSlotGroup, -1, false, 2, 1, false, false},
  {1, "ccv_dec_ooe_uop", Blk::DEC, Blk::OOE, 6, 229, 33, kF_ccv_dec_ooe_uop, 1, false, 0, Order::kField, 0, false, 2, -1, false, true},
  {2, "ccv_ooe_rcu_issue", Blk::OOE, Blk::RCU, 9, 175, 25, kF_ccv_ooe_rcu_issue, 1, false, 1, Order::kNone, -1, false, 2, -1, true, false},
  {3, "ccv_rcu_lane_ops", Blk::RCU, Blk::LANE, 1, 344, 12, kF_ccv_rcu_lane_ops, 32, false, 0, Order::kNone, -1, true, 2, -1, true, false},
  {4, "ccv_lane_rcu_res", Blk::LANE, Blk::RCU, 1, 40, 3, kF_ccv_lane_rcu_res, 32, false, 0, Order::kNone, -1, true, 2, -1, true, false},
  {5, "ccv_rcu_ooe_done", Blk::RCU, Blk::OOE, 7, 40, 3, kF_ccv_rcu_ooe_done, 1, false, 0, Order::kNone, -1, false, 2, -1, true, false},
  {6, "ccv_rcu_miu_addr", Blk::RCU, Blk::MIU, 4, 3111, 5, kF_ccv_rcu_miu_addr, 1, false, 0, Order::kNone, -1, false, 2, -1, false, false},
  {7, "ccv_miu_rcu_data", Blk::MIU, Blk::RCU, 4, 1114, 9, kF_ccv_miu_rcu_data, 1, false, 0, Order::kNone, -1, false, 2, -1, true, false},
  {8, "ccv_ooe_miu_memop", Blk::OOE, Blk::MIU, 4, 121, 18, kF_ccv_ooe_miu_memop, 1, false, 0, Order::kNone, -1, false, 3, -1, false, false},
  {9, "ccv_miu_ooe_cmpl", Blk::MIU, Blk::OOE, 4, 117, 8, kF_ccv_miu_ooe_cmpl, 1, false, 0, Order::kNone, -1, false, 2, -1, true, false},
  {10, "ccv_ooe_miu_retire", Blk::OOE, Blk::MIU, 4, 8, 2, kF_ccv_ooe_miu_retire, 1, false, 0, Order::kNone, -1, false, 2, -1, false, false},
  {11, "ccv_ooe_fet_redirect", Blk::OOE, Blk::FET, 1, 112, 10, kF_ccv_ooe_fet_redirect, 1, false, 0, Order::kNone, -1, false, 2, -1, true, false},
  {12, "ccv_ooe_fet_ckpt_free", Blk::OOE, Blk::FET, 1, 16, 1, kF_ccv_ooe_fet_ckpt_free, 1, false, 0, Order::kNone, -1, false, 1, -1, true, false},
  {13, "ccv_miu_spm_req", Blk::MIU, Blk::SPM, 4, 1477, 5, kF_ccv_miu_spm_req, 1, false, 0, Order::kNone, -1, false, 4, -1, false, false},
  {14, "ccv_spm_miu_rsp", Blk::SPM, Blk::MIU, 4, 1033, 3, kF_ccv_spm_miu_rsp, 1, false, 0, Order::kNone, -1, false, 4, -1, false, false},
  {15, "ccv_miu_dcu_req", Blk::MIU, Blk::DCU, 4, 1212, 7, kF_ccv_miu_dcu_req, 1, false, 0, Order::kNone, -1, false, 4, -1, false, false},
  {16, "ccv_dcu_miu_rsp", Blk::DCU, Blk::MIU, 4, 1031, 5, kF_ccv_dcu_miu_rsp, 1, false, 0, Order::kNone, -1, false, 4, -1, false, false},
  {17, "ccv_dcu_mlc_req", Blk::DCU, Blk::MLC, 1, 1082, 5, kF_ccv_dcu_mlc_req, 1, false, 0, Order::kNone, -1, false, 4, -1, false, false},
  {18, "ccv_mlc_dcu_rsp", Blk::MLC, Blk::DCU, 1, 1030, 4, kF_ccv_mlc_dcu_rsp, 1, false, 0, Order::kNone, -1, false, 4, -1, false, false},
  {19, "ccv_mlc_dcu_probe", Blk::MLC, Blk::DCU, 1, 51, 3, kF_ccv_mlc_dcu_probe, 1, false, 0, Order::kNone, -1, false, 1, -1, false, false},
  {20, "ccv_dcu_mlc_probe_ack", Blk::DCU, Blk::MLC, 1, 1027, 3, kF_ccv_dcu_mlc_probe_ack, 1, false, 0, Order::kNone, -1, false, 1, -1, false, false},
  {21, "ccv_fet_mlc_ifill", Blk::FET, Blk::MLC, 1, 50, 2, kF_ccv_fet_mlc_ifill, 1, false, 0, Order::kNone, -1, false, 4, -1, false, false},
  {22, "ccv_mlc_fet_ifill_rsp", Blk::MLC, Blk::FET, 1, 1026, 2, kF_ccv_mlc_fet_ifill_rsp, 1, false, 0, Order::kNone, -1, false, 4, -1, false, false},
  {23, "ccv_miu_fet_itlb", Blk::MIU, Blk::FET, 1, 64, 1, kF_ccv_miu_fet_itlb, 1, false, 0, Order::kNone, -1, false, 4, -1, false, false},
  {24, "ccv_fet_miu_itlb_req", Blk::FET, Blk::MIU, 1, 60, 2, kF_ccv_fet_miu_itlb_req, 1, false, 0, Order::kNone, -1, false, 4, -1, false, false},
  {25, "ccv_mlc_exb_req", Blk::MLC, Blk::EXB, 1, 1090, 7, kF_ccv_mlc_exb_req, 1, false, 0, Order::kNone, -1, false, 4, -1, false, false},
  {26, "ccv_exb_mlc_rsp", Blk::EXB, Blk::MLC, 1, 1082, 6, kF_ccv_exb_mlc_rsp, 1, false, 0, Order::kNone, -1, false, 5, -1, false, false},
  {27, "ccv_exb_ext_out", Blk::EXB, Blk::EXTERNAL, 1, 1225, 1, kF_ccv_exb_ext_out, 1, false, 0, Order::kNone, -1, false, 4, -1, false, false},
  {28, "ccv_rau_fet_launch", Blk::RAU, Blk::FET, 1, 218, 7, kF_ccv_rau_fet_launch, 1, false, 0, Order::kNone, -1, false, 1, -1, false, false},
  {29, "ccv_rau_ooe_alloc", Blk::RAU, Blk::OOE, 1, 54, 7, kF_ccv_rau_ooe_alloc, 1, false, 0, Order::kNone, -1, false, 1, -1, false, false},
  {30, "ccv_ooe_rau_status", Blk::OOE, Blk::RAU, 1, 17, 6, kF_ccv_ooe_rau_status, 1, false, 0, Order::kNone, -1, false, 1, -1, false, false},
  {31, "ccv_rau_ooe_demote", Blk::RAU, Blk::OOE, 1, 6, 2, kF_ccv_rau_ooe_demote, 1, false, 0, Order::kNone, -1, false, 1, -1, false, false},
  {32, "ccv_ooe_rau_drained", Blk::OOE, Blk::RAU, 1, 71, 4, kF_ccv_ooe_rau_drained, 1, false, 0, Order::kNone, -1, false, 1, -1, false, false},
  {33, "ccv_rau_rcu_mig", Blk::RAU, Blk::RCU, 1, 6, 2, kF_ccv_rau_rcu_mig, 1, false, 0, Order::kNone, -1, false, 1, -1, false, false},
  {34, "ccv_ooe_rcu_map", Blk::OOE, Blk::RCU, 1, 222, 6, kF_ccv_ooe_rcu_map, 1, false, 0, Order::kNone, -1, false, 1, -1, false, false},
  {35, "ccv_rcu_pca_mig", Blk::RCU, Blk::PCA, 1, 1034, 3, kF_ccv_rcu_pca_mig, 1, false, 0, Order::kNone, -1, false, 1, -1, false, false},
  {36, "ccv_pca_rcu_mig", Blk::PCA, Blk::RCU, 1, 1034, 3, kF_ccv_pca_rcu_mig, 1, false, 0, Order::kNone, -1, false, 1, -1, false, false},
  {37, "ccv_fet_pca_mig", Blk::FET, Blk::PCA, 1, 1056, 6, kF_ccv_fet_pca_mig, 1, false, 0, Order::kNone, -1, false, 2, -1, false, false},
  {38, "ccv_pca_fet_mig", Blk::PCA, Blk::FET, 1, 1056, 6, kF_ccv_pca_fet_mig, 1, false, 0, Order::kNone, -1, false, 2, -1, false, false},
  {39, "ccv_rau_fet_mig", Blk::RAU, Blk::FET, 1, 8, 3, kF_ccv_rau_fet_mig, 1, false, 0, Order::kNone, -1, false, 1, -1, false, false},
  {40, "ccv_pca_rau_mig_done", Blk::PCA, Blk::RAU, 1, 6, 2, kF_ccv_pca_rau_mig_done, 1, false, 0, Order::kNone, -1, false, 1, -1, false, false},
  {41, "ccv_rau_pca_mig", Blk::RAU, Blk::PCA, 1, 11, 3, kF_ccv_rau_pca_mig, 1, false, 0, Order::kNone, -1, false, 1, -1, false, false},
  {42, "ccv_miu_rau_ready", Blk::MIU, Blk::RAU, 1, 5, 1, kF_ccv_miu_rau_ready, 1, false, 0, Order::kNone, -1, false, 1, -1, false, false},
  {43, "ccv_rau_miu_cta", Blk::RAU, Blk::MIU, 1, 229, 6, kF_ccv_rau_miu_cta, 1, false, 0, Order::kNone, -1, false, 1, -1, false, false},
  {44, "ccv_ooe_syu_bar", Blk::OOE, Blk::SYU, 1, 111, 8, kF_ccv_ooe_syu_bar, 1, false, 0, Order::kNone, -1, false, 2, -1, false, false},
  {45, "ccv_syu_ooe_rel", Blk::SYU, Blk::OOE, 1, 5, 1, kF_ccv_syu_ooe_rel, 1, false, 0, Order::kNone, -1, false, 1, -1, false, false},
  {46, "ccv_syu_fet_rel", Blk::SYU, Blk::FET, 1, 37, 2, kF_ccv_syu_fet_rel, 1, false, 0, Order::kNone, -1, false, 1, -1, false, false},
  {47, "ccv_syu_rau_ready", Blk::SYU, Blk::RAU, 1, 5, 1, kF_ccv_syu_rau_ready, 1, false, 0, Order::kNone, -1, false, 1, -1, false, false},
  {48, "ccv_rau_syu_alloc", Blk::RAU, Blk::SYU, 1, 58, 7, kF_ccv_rau_syu_alloc, 1, false, 0, Order::kNone, -1, false, 1, -1, false, false},
  {49, "ccv_ooe_cru_fault", Blk::OOE, Blk::CRU, 1, 172, 6, kF_ccv_ooe_cru_fault, 1, false, 0, Order::kNone, -1, false, 2, -1, false, false},
  {50, "ccv_cru_rau_cfg", Blk::CRU, Blk::RAU, 1, 74, 5, kF_ccv_cru_rau_cfg, 1, false, 0, Order::kNone, -1, false, 1, -1, false, false},
  {51, "ccv_ext_exb_in", Blk::EXTERNAL, Blk::EXB, 1, 1176, 1, kF_ccv_ext_exb_in, 1, false, 0, Order::kNone, -1, false, 5, -1, false, false},
  {52, "ccv_dcu_miu_fill_ntc", Blk::DCU, Blk::MIU, 4, 4, 1, kF_ccv_dcu_miu_fill_ntc, 1, false, 0, Order::kNone, -1, false, 4, -1, true, false},
  {53, "ccv_miu_ooe_cmpl_hint", Blk::MIU, Blk::OOE, 4, 13, 2, kF_ccv_miu_ooe_cmpl_hint, 1, false, 0, Order::kNone, -1, false, 2, -1, true, false},
};
constexpr unsigned kNumChans = 54;

/// Block INSTANCES: 45 of them. A multi-instance type's copies
/// are contiguous.
struct BlkInst { Blk type; uint16_t index; };
inline constexpr BlkInst kBlkInsts[] = {
  {Blk::FET, 0},
  {Blk::DEC, 0},
  {Blk::OOE, 0},
  {Blk::RCU, 0},
  {Blk::LANE, 0},
  {Blk::LANE, 1},
  {Blk::LANE, 2},
  {Blk::LANE, 3},
  {Blk::LANE, 4},
  {Blk::LANE, 5},
  {Blk::LANE, 6},
  {Blk::LANE, 7},
  {Blk::LANE, 8},
  {Blk::LANE, 9},
  {Blk::LANE, 10},
  {Blk::LANE, 11},
  {Blk::LANE, 12},
  {Blk::LANE, 13},
  {Blk::LANE, 14},
  {Blk::LANE, 15},
  {Blk::LANE, 16},
  {Blk::LANE, 17},
  {Blk::LANE, 18},
  {Blk::LANE, 19},
  {Blk::LANE, 20},
  {Blk::LANE, 21},
  {Blk::LANE, 22},
  {Blk::LANE, 23},
  {Blk::LANE, 24},
  {Blk::LANE, 25},
  {Blk::LANE, 26},
  {Blk::LANE, 27},
  {Blk::LANE, 28},
  {Blk::LANE, 29},
  {Blk::LANE, 30},
  {Blk::LANE, 31},
  {Blk::MIU, 0},
  {Blk::SPM, 0},
  {Blk::DCU, 0},
  {Blk::MLC, 0},
  {Blk::RAU, 0},
  {Blk::SYU, 0},
  {Blk::PCA, 0},
  {Blk::CRU, 0},
  {Blk::EXB, 0},
};
constexpr unsigned kNumBlkInsts = 45;

/// Channel INSTANCES. src/dst index kBlkInsts; -1 is EXTERNAL.
/// slot_base and payload_base locate this instance in the
/// checker bank's flat valid/credit/stall and payload vectors.
/// stages: sequential repeater stages each way (params/links.json);
/// src_stages: how many of them are in the source's wrapper, which is
/// where the checker bank watches the link.
struct ChanInst {
  uint16_t chan; uint16_t inst; int16_t src; int16_t dst;
  uint32_t slot_base; uint64_t payload_base;
  uint16_t stages; uint16_t src_stages;
};
inline constexpr ChanInst kChanInsts[] = {
  {0, 0, 0, 1, 0, 0, 0, 0},
  {1, 0, 1, 2, 8, 1296, 0, 0},
  {2, 0, 2, 3, 14, 2670, 0, 0},
  {3, 0, 3, 4, 23, 4245, 0, 0},
  {3, 1, 3, 5, 24, 4589, 0, 0},
  {3, 2, 3, 6, 25, 4933, 0, 0},
  {3, 3, 3, 7, 26, 5277, 0, 0},
  {3, 4, 3, 8, 27, 5621, 0, 0},
  {3, 5, 3, 9, 28, 5965, 0, 0},
  {3, 6, 3, 10, 29, 6309, 0, 0},
  {3, 7, 3, 11, 30, 6653, 0, 0},
  {3, 8, 3, 12, 31, 6997, 0, 0},
  {3, 9, 3, 13, 32, 7341, 0, 0},
  {3, 10, 3, 14, 33, 7685, 0, 0},
  {3, 11, 3, 15, 34, 8029, 0, 0},
  {3, 12, 3, 16, 35, 8373, 0, 0},
  {3, 13, 3, 17, 36, 8717, 0, 0},
  {3, 14, 3, 18, 37, 9061, 0, 0},
  {3, 15, 3, 19, 38, 9405, 0, 0},
  {3, 16, 3, 20, 39, 9749, 0, 0},
  {3, 17, 3, 21, 40, 10093, 0, 0},
  {3, 18, 3, 22, 41, 10437, 0, 0},
  {3, 19, 3, 23, 42, 10781, 0, 0},
  {3, 20, 3, 24, 43, 11125, 0, 0},
  {3, 21, 3, 25, 44, 11469, 0, 0},
  {3, 22, 3, 26, 45, 11813, 0, 0},
  {3, 23, 3, 27, 46, 12157, 0, 0},
  {3, 24, 3, 28, 47, 12501, 0, 0},
  {3, 25, 3, 29, 48, 12845, 0, 0},
  {3, 26, 3, 30, 49, 13189, 0, 0},
  {3, 27, 3, 31, 50, 13533, 0, 0},
  {3, 28, 3, 32, 51, 13877, 0, 0},
  {3, 29, 3, 33, 52, 14221, 0, 0},
  {3, 30, 3, 34, 53, 14565, 0, 0},
  {3, 31, 3, 35, 54, 14909, 0, 0},
  {4, 0, 4, 3, 55, 15253, 0, 0},
  {4, 1, 5, 3, 56, 15293, 0, 0},
  {4, 2, 6, 3, 57, 15333, 0, 0},
  {4, 3, 7, 3, 58, 15373, 0, 0},
  {4, 4, 8, 3, 59, 15413, 0, 0},
  {4, 5, 9, 3, 60, 15453, 0, 0},
  {4, 6, 10, 3, 61, 15493, 0, 0},
  {4, 7, 11, 3, 62, 15533, 0, 0},
  {4, 8, 12, 3, 63, 15573, 0, 0},
  {4, 9, 13, 3, 64, 15613, 0, 0},
  {4, 10, 14, 3, 65, 15653, 0, 0},
  {4, 11, 15, 3, 66, 15693, 0, 0},
  {4, 12, 16, 3, 67, 15733, 0, 0},
  {4, 13, 17, 3, 68, 15773, 0, 0},
  {4, 14, 18, 3, 69, 15813, 0, 0},
  {4, 15, 19, 3, 70, 15853, 0, 0},
  {4, 16, 20, 3, 71, 15893, 0, 0},
  {4, 17, 21, 3, 72, 15933, 0, 0},
  {4, 18, 22, 3, 73, 15973, 0, 0},
  {4, 19, 23, 3, 74, 16013, 0, 0},
  {4, 20, 24, 3, 75, 16053, 0, 0},
  {4, 21, 25, 3, 76, 16093, 0, 0},
  {4, 22, 26, 3, 77, 16133, 0, 0},
  {4, 23, 27, 3, 78, 16173, 0, 0},
  {4, 24, 28, 3, 79, 16213, 0, 0},
  {4, 25, 29, 3, 80, 16253, 0, 0},
  {4, 26, 30, 3, 81, 16293, 0, 0},
  {4, 27, 31, 3, 82, 16333, 0, 0},
  {4, 28, 32, 3, 83, 16373, 0, 0},
  {4, 29, 33, 3, 84, 16413, 0, 0},
  {4, 30, 34, 3, 85, 16453, 0, 0},
  {4, 31, 35, 3, 86, 16493, 0, 0},
  {5, 0, 3, 2, 87, 16533, 0, 0},
  {6, 0, 3, 36, 94, 16813, 0, 0},
  {7, 0, 36, 3, 98, 29257, 0, 0},
  {8, 0, 2, 36, 102, 33713, 0, 0},
  {9, 0, 36, 2, 106, 34197, 0, 0},
  {10, 0, 2, 36, 110, 34665, 0, 0},
  {11, 0, 2, 0, 114, 34697, 0, 0},
  {12, 0, 2, 0, 115, 34809, 0, 0},
  {13, 0, 36, 37, 116, 34825, 0, 0},
  {14, 0, 37, 36, 120, 40733, 0, 0},
  {15, 0, 36, 38, 124, 44865, 0, 0},
  {16, 0, 38, 36, 128, 49713, 0, 0},
  {17, 0, 38, 39, 132, 53837, 0, 0},
  {18, 0, 39, 38, 133, 54919, 0, 0},
  {19, 0, 39, 38, 134, 55949, 0, 0},
  {20, 0, 38, 39, 135, 56000, 0, 0},
  {21, 0, 0, 39, 136, 57027, 0, 0},
  {22, 0, 39, 0, 137, 57077, 0, 0},
  {23, 0, 36, 0, 138, 58103, 0, 0},
  {24, 0, 0, 36, 139, 58167, 0, 0},
  {25, 0, 39, 44, 140, 58227, 0, 0},
  {26, 0, 44, 39, 141, 59317, 0, 0},
  {27, 0, 44, -1, 142, 60399, 0, 0},
  {28, 0, 40, 0, 143, 61624, 0, 0},
  {29, 0, 40, 2, 144, 61842, 0, 0},
  {30, 0, 2, 40, 145, 61896, 0, 0},
  {31, 0, 40, 2, 146, 61913, 0, 0},
  {32, 0, 2, 40, 147, 61919, 0, 0},
  {33, 0, 40, 3, 148, 61990, 0, 0},
  {34, 0, 2, 3, 149, 61996, 0, 0},
  {35, 0, 3, 42, 150, 62218, 0, 0},
  {36, 0, 42, 3, 151, 63252, 0, 0},
  {37, 0, 0, 42, 152, 64286, 0, 0},
  {38, 0, 42, 0, 153, 65342, 0, 0},
  {39, 0, 40, 0, 154, 66398, 0, 0},
  {40, 0, 42, 40, 155, 66406, 0, 0},
  {41, 0, 40, 42, 156, 66412, 0, 0},
  {42, 0, 36, 40, 157, 66423, 0, 0},
  {43, 0, 40, 36, 158, 66428, 0, 0},
  {44, 0, 2, 41, 159, 66657, 0, 0},
  {45, 0, 41, 2, 160, 66768, 0, 0},
  {46, 0, 41, 0, 161, 66773, 0, 0},
  {47, 0, 41, 40, 162, 66810, 0, 0},
  {48, 0, 40, 41, 163, 66815, 0, 0},
  {49, 0, 2, 43, 164, 66873, 0, 0},
  {50, 0, 43, 40, 165, 67045, 0, 0},
  {51, 0, -1, 44, 166, 67119, 0, 0},
  {52, 0, 38, 36, 167, 68295, 0, 0},
  {53, 0, 36, 2, 171, 68311, 0, 0},
};
constexpr unsigned kNumChanInsts = 116;
constexpr unsigned kNumSlots = 175;
constexpr uint64_t kPayloadBits = 68363;

/// Fabrics between blocks, outside the credit scheme (schema
/// common_ports): a broadcast is driven by `end` and read by every
/// block in `blks`; a gather is driven by each block in `blks`, its
/// own copy, and read whole by `end` (its port `port`). Registered:
/// a block reads the value as the cycle starts and drives the next.
/// slot_base locates it in the hosts' fabric state: one slot for a
/// broadcast, one per source for a gather, in `blks` order.
enum class FabKind : uint8_t { BROADCAST, GATHER };
struct FabDesc {
  const char *name, *port; uint32_t width; FabKind kind; Blk end;
  const Blk *blks; uint8_t nblks; uint16_t slot_base;
};
inline constexpr Blk kFabBlks_kill_valid[] = {Blk::FET, Blk::DEC, Blk::OOE, Blk::RCU, Blk::MIU, Blk::SPM, Blk::SYU, Blk::PCA};
inline constexpr Blk kFabBlks_kill_warp_mask[] = {Blk::FET, Blk::DEC, Blk::OOE, Blk::RCU, Blk::MIU, Blk::SPM, Blk::SYU, Blk::PCA};
inline constexpr Blk kFabBlks_kill_epoch[] = {Blk::FET, Blk::DEC, Blk::OOE, Blk::RCU, Blk::MIU, Blk::SPM, Blk::SYU, Blk::PCA};
inline constexpr Blk kFabBlks_kill_ack[] = {Blk::FET, Blk::DEC, Blk::OOE, Blk::RCU, Blk::MIU, Blk::SPM, Blk::SYU, Blk::PCA};
inline constexpr Blk kFabBlks_kill_ack_epoch[] = {Blk::FET, Blk::DEC, Blk::OOE, Blk::RCU, Blk::MIU, Blk::SPM, Blk::SYU, Blk::PCA};
inline constexpr FabDesc kFabs[] = {
  {"kill_valid", "kill_valid", 1, FabKind::BROADCAST, Blk::RAU, kFabBlks_kill_valid, 8, 0},
  {"kill_warp_mask", "kill_warp_mask", 32, FabKind::BROADCAST, Blk::RAU, kFabBlks_kill_warp_mask, 8, 1},
  {"kill_epoch", "kill_epoch", 2, FabKind::BROADCAST, Blk::RAU, kFabBlks_kill_epoch, 8, 2},
  {"kill_ack", "kill_acks", 1, FabKind::GATHER, Blk::RAU, kFabBlks_kill_ack, 8, 3},
  {"kill_ack_epoch", "kill_ack_epochs", 2, FabKind::GATHER, Blk::RAU, kFabBlks_kill_ack_epoch, 8, 11},
};
constexpr unsigned kNumFabs = 5;
constexpr unsigned kNumFabSlots = 19;

} // namespace skel
} // namespace ccv
#endif // CCV_SKEL_WIRING_H
