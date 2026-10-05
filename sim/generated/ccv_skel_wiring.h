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
};

inline constexpr FieldDesc kF_ccv_fet_dec_instr[] = {
  {"warp_id", 155, 5, false},
  {"tier1_id", 153, 2, false},
  {"pc", 89, 64, false},
  {"group_mask", 57, 32, false},
  {"fetch_epoch", 54, 3, false},
  {"instr", 6, 48, false},
  {"length", 4, 2, false},
  {"checkpoint_id", 2, 2, false},
  {"pred_taken", 1, 1, false},
  {"fetch_fault", 0, 1, false},
};
inline constexpr FieldDesc kF_ccv_dec_ooe_uop[] = {
  {"warp_id", 196, 5, false},
  {"pc", 132, 64, false},
  {"group_mask", 100, 32, false},
  {"fetch_epoch", 97, 3, false},
  {"uop_class", 94, 3, false},
  {"sched_attr", 81, 13, false},
  {"mem_op", 77, 4, false},
  {"space", 74, 3, false},
  {"ordering", 70, 4, false},
  {"opcode", 61, 9, false},
  {"src_arch", 53, 8, false},
  {"src2_arch", 49, 4, false},
  {"dst_arch", 45, 4, false},
  {"pred_guard", 43, 2, false},
  {"pred_neg", 42, 1, false},
  {"pred_dst", 40, 2, false},
  {"pred_we", 39, 1, false},
  {"imm", 7, 32, false},
  {"ilen", 5, 2, false},
  {"checkpoint_id", 3, 2, false},
  {"pred_taken", 2, 1, false},
  {"scale_en", 1, 1, false},
  {"decode_fault", 0, 1, false},
};
inline constexpr FieldDesc kF_ccv_ooe_rcu_issue[] = {
  {"rob_tag", 142, 7, false},
  {"warp_id", 137, 5, false},
  {"issue_mask", 105, 32, false},
  {"phys_src", 89, 16, false},
  {"phys_src2", 81, 8, false},
  {"phys_dst", 73, 8, false},
  {"phys_old_dst", 65, 8, false},
  {"phys_pred_guard", 59, 6, false},
  {"pred_neg", 58, 1, false},
  {"phys_pred_dst", 52, 6, false},
  {"phys_pred_old_dst", 46, 6, false},
  {"pred_we", 45, 1, false},
  {"merge_en", 44, 1, false},
  {"opcode", 35, 9, false},
  {"imm", 3, 32, false},
  {"chwidth", 1, 2, false},
  {"dispatch_fault", 0, 1, false},
};
inline constexpr FieldDesc kF_ccv_rcu_lane_ops[] = {
  {"opcode", 134, 9, false},
  {"operand", 38, 96, false},
  {"merge_data", 6, 32, false},
  {"pred_bit", 5, 1, true},
  {"pred_data", 4, 1, true},
  {"section_en", 0, 4, true},
};
inline constexpr FieldDesc kF_ccv_lane_rcu_res[] = {
  {"result", 2, 32, false},
  {"pred_out", 1, 1, false},
  {"lane_fault", 0, 1, false},
};
inline constexpr FieldDesc kF_ccv_rcu_ooe_done[] = {
  {"rob_tag", 66, 7, false},
  {"exec_fault", 65, 1, false},
  {"branch_taken", 64, 1, false},
  {"branch_mask", 32, 32, false},
  {"fault_lane_mask", 0, 32, false},
};
inline constexpr FieldDesc kF_ccv_rcu_miu_addr[] = {
  {"rob_tag", 2144, 7, false},
  {"active_mask", 2112, 32, false},
  {"base", 2048, 64, false},
  {"index_per_lane", 1024, 1024, false},
  {"store_data", 0, 1024, false},
};
inline constexpr FieldDesc kF_ccv_miu_rcu_data[] = {
  {"rob_tag", 1103, 7, false},
  {"active_mask", 1071, 32, false},
  {"pred_result", 1039, 32, false},
  {"phys_dst", 1031, 8, false},
  {"phys_pred", 1025, 6, false},
  {"pred_we", 1024, 1, false},
  {"load_data", 0, 1024, false},
};
inline constexpr FieldDesc kF_ccv_ooe_miu_memop[] = {
  {"rob_tag", 84, 7, false},
  {"phys_dst", 76, 8, false},
  {"phys_pred", 70, 6, false},
  {"issue_mask", 38, 32, false},
  {"warp_id", 33, 5, false},
  {"cta_slot", 30, 3, false},
  {"mem_op", 26, 4, false},
  {"chwidth", 24, 2, false},
  {"disp", 8, 16, false},
  {"scale_en", 7, 1, false},
  {"space", 4, 3, false},
  {"ordering", 0, 4, false},
};
inline constexpr FieldDesc kF_ccv_miu_ooe_cmpl[] = {
  {"rob_tag", 103, 7, false},
  {"status", 101, 2, false},
  {"cause", 97, 4, false},
  {"lane_mask", 65, 32, false},
  {"address", 1, 64, false},
  {"mlc_miss", 0, 1, false},
};
inline constexpr FieldDesc kF_ccv_ooe_miu_retire[] = {
  {"rob_tag", 1, 7, false},
  {"commit_or_discard", 0, 1, false},
};
inline constexpr FieldDesc kF_ccv_ooe_fet_redirect[] = {
  {"warp_id", 104, 5, false},
  {"tier1_id", 102, 2, false},
  {"checkpoint_id", 100, 2, false},
  {"taken_mask", 68, 32, false},
  {"target_pc", 4, 64, false},
  {"fetch_epoch", 1, 3, false},
  {"epoch_only", 0, 1, false},
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
  {"warp_id", 181, 5, false},
  {"tier1_id", 179, 2, false},
  {"start_pc", 115, 64, false},
  {"code_bounds", 11, 104, false},
  {"asid", 3, 8, false},
  {"cta_slot", 0, 3, false},
};
inline constexpr FieldDesc kF_ccv_rau_ooe_alloc[] = {
  {"warp_id", 41, 5, false},
  {"tier1_id", 39, 2, false},
  {"alloc_op", 37, 2, false},
  {"ctaid", 5, 32, false},
  {"warp_in_cta", 0, 5, false},
};
inline constexpr FieldDesc kF_ccv_ooe_rau_status[] = {
  {"warp_id", 11, 5, false},
  {"fault_taken", 10, 1, false},
  {"stalled", 9, 1, false},
  {"mlc_miss_seen", 8, 1, false},
  {"retired_since_restore", 0, 8, false},
};
inline constexpr FieldDesc kF_ccv_rau_ooe_demote[] = {
  {"warp_id", 1, 5, false},
  {"squash_to_retirement", 0, 1, false},
};
inline constexpr FieldDesc kF_ccv_ooe_rau_drained[] = {
  {"warp_id", 65, 5, false},
  {"resume_pc", 1, 64, false},
  {"arch_state_ready", 0, 1, false},
};
inline constexpr FieldDesc kF_ccv_rau_rcu_mig[] = {
  {"warp_id", 4, 5, false},
  {"direction", 3, 1, false},
  {"bank_select", 0, 3, false},
};
inline constexpr FieldDesc kF_ccv_ooe_rcu_map[] = {
  {"warp_id", 153, 5, false},
  {"direction", 152, 1, false},
  {"gpr_map", 24, 128, false},
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
  {"warp_id", 384, 5, false},
  {"pcs", 128, 256, false},
  {"group_masks", 0, 128, false},
};
inline constexpr FieldDesc kF_ccv_pca_fet_mig[] = {
  {"warp_id", 384, 5, false},
  {"pcs", 128, 256, false},
  {"group_masks", 0, 128, false},
};
inline constexpr FieldDesc kF_ccv_rau_fet_mig[] = {
  {"warp_id", 6, 5, false},
  {"tier1_id", 4, 2, false},
  {"direction", 3, 1, false},
  {"bank_select", 0, 3, false},
};
inline constexpr FieldDesc kF_ccv_pca_rau_mig_done[] = {
  {"warp_id", 1, 5, false},
  {"direction", 0, 1, false},
};
inline constexpr FieldDesc kF_ccv_rau_miu_cta[] = {
  {"cta_slot", 98, 3, false},
  {"spm_base", 81, 17, false},
  {"spm_limit", 64, 17, false},
  {"launch_block_addr", 0, 64, false},
};
inline constexpr FieldDesc kF_ccv_ooe_syu_bar[] = {
  {"warp_id", 8, 5, false},
  {"cta_slot", 5, 3, false},
  {"barrier_id", 1, 4, false},
  {"arrive_or_wait", 0, 1, false},
};
inline constexpr FieldDesc kF_ccv_syu_ooe_rel[] = {
  {"warp_mask_released", 4, 32, false},
  {"barrier_id", 0, 4, false},
};
inline constexpr FieldDesc kF_ccv_rau_syu_alloc[] = {
  {"cta_slot", 14, 3, false},
  {"barrier_base", 8, 6, false},
  {"barrier_count", 1, 7, false},
  {"allocate_or_free", 0, 1, false},
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

inline constexpr ChanDesc kChans[] = {
  {0, "ccv_fet_dec_instr", Blk::FET, Blk::DEC, 8, 160, 10, kF_ccv_fet_dec_instr, 1, false, 2, Order::kSlotGroup, -1, false, 2, 1, false},
  {1, "ccv_dec_ooe_uop", Blk::DEC, Blk::OOE, 6, 201, 23, kF_ccv_dec_ooe_uop, 1, false, 0, Order::kField, 0, false, 2, -1, false},
  {2, "ccv_ooe_rcu_issue", Blk::OOE, Blk::RCU, 4, 149, 17, kF_ccv_ooe_rcu_issue, 1, false, 0, Order::kNone, -1, false, 2, -1, true},
  {3, "ccv_rcu_lane_ops", Blk::RCU, Blk::LANE, 4, 143, 6, kF_ccv_rcu_lane_ops, 32, false, 1, Order::kNone, -1, true, 2, -1, true},
  {4, "ccv_lane_rcu_res", Blk::LANE, Blk::RCU, 4, 34, 3, kF_ccv_lane_rcu_res, 32, false, 1, Order::kNone, -1, true, 2, -1, true},
  {5, "ccv_rcu_ooe_done", Blk::RCU, Blk::OOE, 4, 73, 5, kF_ccv_rcu_ooe_done, 1, false, 0, Order::kNone, -1, false, 2, -1, true},
  {6, "ccv_rcu_miu_addr", Blk::RCU, Blk::MIU, 4, 2151, 5, kF_ccv_rcu_miu_addr, 1, false, 0, Order::kNone, -1, false, 2, -1, false},
  {7, "ccv_miu_rcu_data", Blk::MIU, Blk::RCU, 4, 1110, 7, kF_ccv_miu_rcu_data, 1, false, 0, Order::kNone, -1, false, 2, -1, true},
  {8, "ccv_ooe_miu_memop", Blk::OOE, Blk::MIU, 4, 91, 12, kF_ccv_ooe_miu_memop, 1, false, 0, Order::kNone, -1, false, 2, -1, false},
  {9, "ccv_miu_ooe_cmpl", Blk::MIU, Blk::OOE, 4, 110, 6, kF_ccv_miu_ooe_cmpl, 1, false, 0, Order::kNone, -1, false, 2, -1, true},
  {10, "ccv_ooe_miu_retire", Blk::OOE, Blk::MIU, 4, 8, 2, kF_ccv_ooe_miu_retire, 1, false, 0, Order::kNone, -1, false, 2, -1, false},
  {11, "ccv_ooe_fet_redirect", Blk::OOE, Blk::FET, 1, 109, 7, kF_ccv_ooe_fet_redirect, 1, false, 0, Order::kNone, -1, false, 2, -1, true},
  {12, "ccv_ooe_fet_ckpt_free", Blk::OOE, Blk::FET, 1, 16, 1, kF_ccv_ooe_fet_ckpt_free, 1, false, 0, Order::kNone, -1, false, 1, -1, true},
  {13, "ccv_miu_spm_req", Blk::MIU, Blk::SPM, 4, 1477, 5, kF_ccv_miu_spm_req, 1, false, 0, Order::kNone, -1, false, 4, -1, false},
  {14, "ccv_spm_miu_rsp", Blk::SPM, Blk::MIU, 4, 1033, 3, kF_ccv_spm_miu_rsp, 1, false, 0, Order::kNone, -1, false, 4, -1, false},
  {15, "ccv_miu_dcu_req", Blk::MIU, Blk::DCU, 4, 1212, 7, kF_ccv_miu_dcu_req, 1, false, 0, Order::kNone, -1, false, 4, -1, false},
  {16, "ccv_dcu_miu_rsp", Blk::DCU, Blk::MIU, 4, 1031, 5, kF_ccv_dcu_miu_rsp, 1, false, 0, Order::kNone, -1, false, 4, -1, false},
  {17, "ccv_dcu_mlc_req", Blk::DCU, Blk::MLC, 1, 1082, 5, kF_ccv_dcu_mlc_req, 1, false, 0, Order::kNone, -1, false, 4, -1, false},
  {18, "ccv_mlc_dcu_rsp", Blk::MLC, Blk::DCU, 1, 1030, 4, kF_ccv_mlc_dcu_rsp, 1, false, 0, Order::kNone, -1, false, 4, -1, false},
  {19, "ccv_mlc_dcu_probe", Blk::MLC, Blk::DCU, 1, 51, 3, kF_ccv_mlc_dcu_probe, 1, false, 0, Order::kNone, -1, false, 1, -1, false},
  {20, "ccv_dcu_mlc_probe_ack", Blk::DCU, Blk::MLC, 1, 1027, 3, kF_ccv_dcu_mlc_probe_ack, 1, false, 0, Order::kNone, -1, false, 1, -1, false},
  {21, "ccv_fet_mlc_ifill", Blk::FET, Blk::MLC, 1, 50, 2, kF_ccv_fet_mlc_ifill, 1, false, 0, Order::kNone, -1, false, 4, -1, false},
  {22, "ccv_mlc_fet_ifill_rsp", Blk::MLC, Blk::FET, 1, 1026, 2, kF_ccv_mlc_fet_ifill_rsp, 1, false, 0, Order::kNone, -1, false, 4, -1, false},
  {23, "ccv_miu_fet_itlb", Blk::MIU, Blk::FET, 1, 64, 1, kF_ccv_miu_fet_itlb, 1, false, 0, Order::kNone, -1, false, 4, -1, false},
  {24, "ccv_fet_miu_itlb_req", Blk::FET, Blk::MIU, 1, 60, 2, kF_ccv_fet_miu_itlb_req, 1, false, 0, Order::kNone, -1, false, 4, -1, false},
  {25, "ccv_mlc_exb_req", Blk::MLC, Blk::EXB, 1, 1090, 7, kF_ccv_mlc_exb_req, 1, false, 0, Order::kNone, -1, false, 4, -1, false},
  {26, "ccv_exb_mlc_rsp", Blk::EXB, Blk::MLC, 1, 1082, 6, kF_ccv_exb_mlc_rsp, 1, false, 0, Order::kNone, -1, false, 5, -1, false},
  {27, "ccv_exb_ext_out", Blk::EXB, Blk::EXTERNAL, 1, 1225, 1, kF_ccv_exb_ext_out, 1, false, 0, Order::kNone, -1, false, 4, -1, false},
  {28, "ccv_rau_fet_launch", Blk::RAU, Blk::FET, 1, 186, 6, kF_ccv_rau_fet_launch, 1, false, 0, Order::kNone, -1, false, 1, -1, false},
  {29, "ccv_rau_ooe_alloc", Blk::RAU, Blk::OOE, 1, 46, 5, kF_ccv_rau_ooe_alloc, 1, false, 0, Order::kNone, -1, false, 1, -1, false},
  {30, "ccv_ooe_rau_status", Blk::OOE, Blk::RAU, 1, 16, 5, kF_ccv_ooe_rau_status, 1, false, 0, Order::kNone, -1, false, 1, -1, false},
  {31, "ccv_rau_ooe_demote", Blk::RAU, Blk::OOE, 1, 6, 2, kF_ccv_rau_ooe_demote, 1, false, 0, Order::kNone, -1, false, 1, -1, false},
  {32, "ccv_ooe_rau_drained", Blk::OOE, Blk::RAU, 1, 70, 3, kF_ccv_ooe_rau_drained, 1, false, 0, Order::kNone, -1, false, 1, -1, false},
  {33, "ccv_rau_rcu_mig", Blk::RAU, Blk::RCU, 1, 9, 3, kF_ccv_rau_rcu_mig, 1, false, 0, Order::kNone, -1, false, 1, -1, false},
  {34, "ccv_ooe_rcu_map", Blk::OOE, Blk::RCU, 1, 158, 4, kF_ccv_ooe_rcu_map, 1, false, 0, Order::kNone, -1, false, 1, -1, false},
  {35, "ccv_rcu_pca_mig", Blk::RCU, Blk::PCA, 1, 1034, 3, kF_ccv_rcu_pca_mig, 1, false, 0, Order::kNone, -1, false, 1, -1, false},
  {36, "ccv_pca_rcu_mig", Blk::PCA, Blk::RCU, 1, 1034, 3, kF_ccv_pca_rcu_mig, 1, false, 0, Order::kNone, -1, false, 1, -1, false},
  {37, "ccv_fet_pca_mig", Blk::FET, Blk::PCA, 1, 389, 3, kF_ccv_fet_pca_mig, 1, false, 0, Order::kNone, -1, false, 1, -1, false},
  {38, "ccv_pca_fet_mig", Blk::PCA, Blk::FET, 1, 389, 3, kF_ccv_pca_fet_mig, 1, false, 0, Order::kNone, -1, false, 1, -1, false},
  {39, "ccv_rau_fet_mig", Blk::RAU, Blk::FET, 1, 11, 4, kF_ccv_rau_fet_mig, 1, false, 0, Order::kNone, -1, false, 1, -1, false},
  {40, "ccv_pca_rau_mig_done", Blk::PCA, Blk::RAU, 1, 6, 2, kF_ccv_pca_rau_mig_done, 1, false, 0, Order::kNone, -1, false, 1, -1, false},
  {41, "ccv_rau_miu_cta", Blk::RAU, Blk::MIU, 1, 101, 4, kF_ccv_rau_miu_cta, 1, false, 0, Order::kNone, -1, false, 1, -1, false},
  {42, "ccv_ooe_syu_bar", Blk::OOE, Blk::SYU, 1, 13, 4, kF_ccv_ooe_syu_bar, 1, false, 0, Order::kNone, -1, false, 2, -1, false},
  {43, "ccv_syu_ooe_rel", Blk::SYU, Blk::OOE, 1, 36, 2, kF_ccv_syu_ooe_rel, 1, false, 0, Order::kNone, -1, false, 1, -1, false},
  {44, "ccv_rau_syu_alloc", Blk::RAU, Blk::SYU, 1, 17, 4, kF_ccv_rau_syu_alloc, 1, false, 0, Order::kNone, -1, false, 1, -1, false},
  {45, "ccv_ooe_cru_fault", Blk::OOE, Blk::CRU, 1, 172, 6, kF_ccv_ooe_cru_fault, 1, false, 0, Order::kNone, -1, false, 2, -1, false},
  {46, "ccv_cru_rau_cfg", Blk::CRU, Blk::RAU, 1, 74, 5, kF_ccv_cru_rau_cfg, 1, false, 0, Order::kNone, -1, false, 1, -1, false},
  {47, "ccv_ext_exb_in", Blk::EXTERNAL, Blk::EXB, 1, 1176, 1, kF_ccv_ext_exb_in, 1, false, 0, Order::kNone, -1, false, 5, -1, false},
};
constexpr unsigned kNumChans = 48;

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
  {1, 0, 1, 2, 8, 1280, 0, 0},
  {2, 0, 2, 3, 14, 2486, 0, 0},
  {3, 0, 3, 4, 18, 3082, 0, 0},
  {3, 1, 3, 5, 22, 3654, 0, 0},
  {3, 2, 3, 6, 26, 4226, 0, 0},
  {3, 3, 3, 7, 30, 4798, 0, 0},
  {3, 4, 3, 8, 34, 5370, 0, 0},
  {3, 5, 3, 9, 38, 5942, 0, 0},
  {3, 6, 3, 10, 42, 6514, 0, 0},
  {3, 7, 3, 11, 46, 7086, 0, 0},
  {3, 8, 3, 12, 50, 7658, 0, 0},
  {3, 9, 3, 13, 54, 8230, 0, 0},
  {3, 10, 3, 14, 58, 8802, 0, 0},
  {3, 11, 3, 15, 62, 9374, 0, 0},
  {3, 12, 3, 16, 66, 9946, 0, 0},
  {3, 13, 3, 17, 70, 10518, 0, 0},
  {3, 14, 3, 18, 74, 11090, 0, 0},
  {3, 15, 3, 19, 78, 11662, 0, 0},
  {3, 16, 3, 20, 82, 12234, 0, 0},
  {3, 17, 3, 21, 86, 12806, 0, 0},
  {3, 18, 3, 22, 90, 13378, 0, 0},
  {3, 19, 3, 23, 94, 13950, 0, 0},
  {3, 20, 3, 24, 98, 14522, 0, 0},
  {3, 21, 3, 25, 102, 15094, 0, 0},
  {3, 22, 3, 26, 106, 15666, 0, 0},
  {3, 23, 3, 27, 110, 16238, 0, 0},
  {3, 24, 3, 28, 114, 16810, 0, 0},
  {3, 25, 3, 29, 118, 17382, 0, 0},
  {3, 26, 3, 30, 122, 17954, 0, 0},
  {3, 27, 3, 31, 126, 18526, 0, 0},
  {3, 28, 3, 32, 130, 19098, 0, 0},
  {3, 29, 3, 33, 134, 19670, 0, 0},
  {3, 30, 3, 34, 138, 20242, 0, 0},
  {3, 31, 3, 35, 142, 20814, 0, 0},
  {4, 0, 4, 3, 146, 21386, 0, 0},
  {4, 1, 5, 3, 150, 21522, 0, 0},
  {4, 2, 6, 3, 154, 21658, 0, 0},
  {4, 3, 7, 3, 158, 21794, 0, 0},
  {4, 4, 8, 3, 162, 21930, 0, 0},
  {4, 5, 9, 3, 166, 22066, 0, 0},
  {4, 6, 10, 3, 170, 22202, 0, 0},
  {4, 7, 11, 3, 174, 22338, 0, 0},
  {4, 8, 12, 3, 178, 22474, 0, 0},
  {4, 9, 13, 3, 182, 22610, 0, 0},
  {4, 10, 14, 3, 186, 22746, 0, 0},
  {4, 11, 15, 3, 190, 22882, 0, 0},
  {4, 12, 16, 3, 194, 23018, 0, 0},
  {4, 13, 17, 3, 198, 23154, 0, 0},
  {4, 14, 18, 3, 202, 23290, 0, 0},
  {4, 15, 19, 3, 206, 23426, 0, 0},
  {4, 16, 20, 3, 210, 23562, 0, 0},
  {4, 17, 21, 3, 214, 23698, 0, 0},
  {4, 18, 22, 3, 218, 23834, 0, 0},
  {4, 19, 23, 3, 222, 23970, 0, 0},
  {4, 20, 24, 3, 226, 24106, 0, 0},
  {4, 21, 25, 3, 230, 24242, 0, 0},
  {4, 22, 26, 3, 234, 24378, 0, 0},
  {4, 23, 27, 3, 238, 24514, 0, 0},
  {4, 24, 28, 3, 242, 24650, 0, 0},
  {4, 25, 29, 3, 246, 24786, 0, 0},
  {4, 26, 30, 3, 250, 24922, 0, 0},
  {4, 27, 31, 3, 254, 25058, 0, 0},
  {4, 28, 32, 3, 258, 25194, 0, 0},
  {4, 29, 33, 3, 262, 25330, 0, 0},
  {4, 30, 34, 3, 266, 25466, 0, 0},
  {4, 31, 35, 3, 270, 25602, 0, 0},
  {5, 0, 3, 2, 274, 25738, 0, 0},
  {6, 0, 3, 36, 278, 26030, 0, 0},
  {7, 0, 36, 3, 282, 34634, 0, 0},
  {8, 0, 2, 36, 286, 39074, 0, 0},
  {9, 0, 36, 2, 290, 39438, 0, 0},
  {10, 0, 2, 36, 294, 39878, 0, 0},
  {11, 0, 2, 0, 298, 39910, 0, 0},
  {12, 0, 2, 0, 299, 40019, 0, 0},
  {13, 0, 36, 37, 300, 40035, 0, 0},
  {14, 0, 37, 36, 304, 45943, 0, 0},
  {15, 0, 36, 38, 308, 50075, 0, 0},
  {16, 0, 38, 36, 312, 54923, 0, 0},
  {17, 0, 38, 39, 316, 59047, 0, 0},
  {18, 0, 39, 38, 317, 60129, 0, 0},
  {19, 0, 39, 38, 318, 61159, 0, 0},
  {20, 0, 38, 39, 319, 61210, 0, 0},
  {21, 0, 0, 39, 320, 62237, 0, 0},
  {22, 0, 39, 0, 321, 62287, 0, 0},
  {23, 0, 36, 0, 322, 63313, 0, 0},
  {24, 0, 0, 36, 323, 63377, 0, 0},
  {25, 0, 39, 44, 324, 63437, 0, 0},
  {26, 0, 44, 39, 325, 64527, 0, 0},
  {27, 0, 44, -1, 326, 65609, 0, 0},
  {28, 0, 40, 0, 327, 66834, 0, 0},
  {29, 0, 40, 2, 328, 67020, 0, 0},
  {30, 0, 2, 40, 329, 67066, 0, 0},
  {31, 0, 40, 2, 330, 67082, 0, 0},
  {32, 0, 2, 40, 331, 67088, 0, 0},
  {33, 0, 40, 3, 332, 67158, 0, 0},
  {34, 0, 2, 3, 333, 67167, 0, 0},
  {35, 0, 3, 42, 334, 67325, 0, 0},
  {36, 0, 42, 3, 335, 68359, 0, 0},
  {37, 0, 0, 42, 336, 69393, 0, 0},
  {38, 0, 42, 0, 337, 69782, 0, 0},
  {39, 0, 40, 0, 338, 70171, 0, 0},
  {40, 0, 42, 40, 339, 70182, 0, 0},
  {41, 0, 40, 36, 340, 70188, 0, 0},
  {42, 0, 2, 41, 341, 70289, 0, 0},
  {43, 0, 41, 2, 342, 70302, 0, 0},
  {44, 0, 40, 41, 343, 70338, 0, 0},
  {45, 0, 2, 43, 344, 70355, 0, 0},
  {46, 0, 43, 40, 345, 70527, 0, 0},
  {47, 0, -1, 44, 346, 70601, 0, 0},
};
constexpr unsigned kNumChanInsts = 110;
constexpr unsigned kNumSlots = 347;
constexpr uint64_t kPayloadBits = 71777;

} // namespace skel
} // namespace ccv
#endif // CCV_SKEL_WIRING_H
