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
};

inline constexpr FieldDesc kF_ccv_fet_dec_instr[] = {
  {"warp_id", 117, 5, false},
  {"tier1_id", 115, 2, false},
  {"pc", 51, 64, false},
  {"instr", 3, 48, false},
  {"length", 1, 2, false},
  {"fetch_fault", 0, 1, false},
};
inline constexpr FieldDesc kF_ccv_dec_ooe_uop[] = {
  {"warp_id", 132, 5, false},
  {"pc", 68, 64, false},
  {"uop_class", 65, 3, false},
  {"opcode", 56, 9, false},
  {"src_arch", 48, 8, false},
  {"src2_arch", 44, 4, false},
  {"dst_arch", 40, 4, false},
  {"pred_guard", 38, 2, false},
  {"pred_neg", 37, 1, false},
  {"pred_dst", 35, 2, false},
  {"pred_we", 34, 1, false},
  {"imm", 2, 32, false},
  {"scale_en", 1, 1, false},
  {"decode_fault", 0, 1, false},
};
inline constexpr FieldDesc kF_ccv_ooe_rcu_issue[] = {
  {"rob_tag", 131, 7, false},
  {"warp_id", 126, 5, false},
  {"issue_mask", 94, 32, false},
  {"phys_src", 78, 16, false},
  {"phys_src2", 70, 8, false},
  {"phys_dst", 62, 8, false},
  {"phys_pred_guard", 54, 8, false},
  {"pred_neg", 53, 1, false},
  {"phys_pred_dst", 45, 8, false},
  {"pred_we", 44, 1, false},
  {"opcode", 35, 9, false},
  {"imm", 3, 32, false},
  {"chwidth", 1, 2, false},
  {"dispatch_fault", 0, 1, false},
};
inline constexpr FieldDesc kF_ccv_rcu_lane_ops[] = {
  {"opcode", 102, 9, false},
  {"operand", 6, 96, false},
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
  {"rob_tag", 1105, 7, false},
  {"active_mask", 1073, 32, false},
  {"pred_result", 1041, 32, false},
  {"phys_dst", 1033, 8, false},
  {"phys_pred", 1025, 8, false},
  {"pred_we", 1024, 1, false},
  {"load_data", 0, 1024, false},
};
inline constexpr FieldDesc kF_ccv_ooe_miu_memop[] = {
  {"rob_tag", 86, 7, false},
  {"phys_dst", 78, 8, false},
  {"phys_pred", 70, 8, false},
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
  {"warp_id", 196, 5, false},
  {"tier1_id", 194, 2, false},
  {"target_pc", 130, 64, false},
  {"group_masks", 2, 128, false},
  {"fetch_epoch", 0, 2, false},
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
  {"req_id", 1026, 4, false},
  {"read_data", 2, 1024, false},
  {"hit", 1, 1, false},
  {"ownership_granted", 0, 1, false},
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
  {"req_id", 56, 2, false},
  {"phys_addr", 8, 48, false},
  {"asid", 0, 8, false},
};
inline constexpr FieldDesc kF_ccv_mlc_fet_ifill_rsp[] = {
  {"req_id", 1024, 2, false},
  {"line_data", 0, 1024, false},
};
inline constexpr FieldDesc kF_ccv_miu_fet_itlb[] = {
  {"itlb_refill", 0, 64, false},
};
inline constexpr FieldDesc kF_ccv_fet_miu_itlb_req[] = {
  {"virtual_page", 8, 64, false},
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
  {"warp_id", 179, 5, false},
  {"start_pc", 115, 64, false},
  {"code_bounds", 11, 104, false},
  {"asid", 3, 8, false},
  {"cta_slot", 0, 3, false},
};
inline constexpr FieldDesc kF_ccv_rau_ooe_alloc[] = {
  {"warp_id", 54, 5, false},
  {"prf_base", 46, 8, false},
  {"prf_size", 38, 8, false},
  {"activate_or_free", 37, 1, false},
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
inline constexpr FieldDesc kF_ccv_rcu_pca_mig[] = {
  {"warp_id", 2052, 5, false},
  {"row_idx", 2048, 4, false},
  {"gpr_row", 1024, 1024, false},
  {"pred_state", 0, 1024, false},
};
inline constexpr FieldDesc kF_ccv_pca_rcu_mig[] = {
  {"warp_id", 2052, 5, false},
  {"row_idx", 2048, 4, false},
  {"gpr_row", 1024, 1024, false},
  {"pred_state", 0, 1024, false},
};
inline constexpr FieldDesc kF_ccv_fet_pca_mig[] = {
  {"warp_id", 256, 5, false},
  {"pcs", 0, 256, false},
};
inline constexpr FieldDesc kF_ccv_pca_fet_mig[] = {
  {"warp_id", 256, 5, false},
  {"pcs", 0, 256, false},
};
inline constexpr FieldDesc kF_ccv_rau_fet_mig[] = {
  {"warp_id", 4, 5, false},
  {"direction", 3, 1, false},
  {"bank_select", 0, 3, false},
};
inline constexpr FieldDesc kF_ccv_pca_rau_mig_done[] = {
  {"warp_id", 0, 5, false},
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
  {0, "ccv_fet_dec_instr", Blk::FET, Blk::DEC, 8, 122, 6, kF_ccv_fet_dec_instr, 1, false, 2, Order::kSlotGroup, -1, false, 2, 1},
  {1, "ccv_dec_ooe_uop", Blk::DEC, Blk::OOE, 6, 137, 14, kF_ccv_dec_ooe_uop, 1, false, 0, Order::kField, 0, false, 2, -1},
  {2, "ccv_ooe_rcu_issue", Blk::OOE, Blk::RCU, 4, 138, 14, kF_ccv_ooe_rcu_issue, 1, false, 0, Order::kNone, -1, false, 2, -1},
  {3, "ccv_rcu_lane_ops", Blk::RCU, Blk::LANE, 4, 111, 5, kF_ccv_rcu_lane_ops, 32, false, 1, Order::kNone, -1, true, 2, -1},
  {4, "ccv_lane_rcu_res", Blk::LANE, Blk::RCU, 4, 34, 3, kF_ccv_lane_rcu_res, 32, false, 1, Order::kNone, -1, true, 2, -1},
  {5, "ccv_rcu_ooe_done", Blk::RCU, Blk::OOE, 4, 73, 5, kF_ccv_rcu_ooe_done, 1, false, 0, Order::kNone, -1, false, 2, -1},
  {6, "ccv_rcu_miu_addr", Blk::RCU, Blk::MIU, 4, 2151, 5, kF_ccv_rcu_miu_addr, 1, false, 0, Order::kNone, -1, false, 2, -1},
  {7, "ccv_miu_rcu_data", Blk::MIU, Blk::RCU, 4, 1112, 7, kF_ccv_miu_rcu_data, 1, false, 0, Order::kNone, -1, false, 2, -1},
  {8, "ccv_ooe_miu_memop", Blk::OOE, Blk::MIU, 4, 93, 12, kF_ccv_ooe_miu_memop, 1, false, 0, Order::kNone, -1, false, 2, -1},
  {9, "ccv_miu_ooe_cmpl", Blk::MIU, Blk::OOE, 4, 110, 6, kF_ccv_miu_ooe_cmpl, 1, false, 0, Order::kNone, -1, false, 2, -1},
  {10, "ccv_ooe_miu_retire", Blk::OOE, Blk::MIU, 4, 8, 2, kF_ccv_ooe_miu_retire, 1, false, 0, Order::kNone, -1, false, 2, -1},
  {11, "ccv_ooe_fet_redirect", Blk::OOE, Blk::FET, 1, 201, 5, kF_ccv_ooe_fet_redirect, 1, false, 0, Order::kNone, -1, false, 2, -1},
  {12, "ccv_miu_spm_req", Blk::MIU, Blk::SPM, 4, 1477, 5, kF_ccv_miu_spm_req, 1, false, 0, Order::kNone, -1, false, 4, -1},
  {13, "ccv_spm_miu_rsp", Blk::SPM, Blk::MIU, 4, 1033, 3, kF_ccv_spm_miu_rsp, 1, false, 0, Order::kNone, -1, false, 4, -1},
  {14, "ccv_miu_dcu_req", Blk::MIU, Blk::DCU, 4, 1212, 7, kF_ccv_miu_dcu_req, 1, false, 0, Order::kNone, -1, false, 4, -1},
  {15, "ccv_dcu_miu_rsp", Blk::DCU, Blk::MIU, 4, 1030, 4, kF_ccv_dcu_miu_rsp, 1, false, 0, Order::kNone, -1, false, 4, -1},
  {16, "ccv_dcu_mlc_req", Blk::DCU, Blk::MLC, 1, 1082, 5, kF_ccv_dcu_mlc_req, 1, false, 0, Order::kNone, -1, false, 4, -1},
  {17, "ccv_mlc_dcu_rsp", Blk::MLC, Blk::DCU, 1, 1030, 4, kF_ccv_mlc_dcu_rsp, 1, false, 0, Order::kNone, -1, false, 4, -1},
  {18, "ccv_mlc_dcu_probe", Blk::MLC, Blk::DCU, 1, 51, 3, kF_ccv_mlc_dcu_probe, 1, false, 0, Order::kNone, -1, false, 1, -1},
  {19, "ccv_dcu_mlc_probe_ack", Blk::DCU, Blk::MLC, 1, 1027, 3, kF_ccv_dcu_mlc_probe_ack, 1, false, 0, Order::kNone, -1, false, 1, -1},
  {20, "ccv_fet_mlc_ifill", Blk::FET, Blk::MLC, 1, 58, 3, kF_ccv_fet_mlc_ifill, 1, false, 0, Order::kNone, -1, false, 4, -1},
  {21, "ccv_mlc_fet_ifill_rsp", Blk::MLC, Blk::FET, 1, 1026, 2, kF_ccv_mlc_fet_ifill_rsp, 1, false, 0, Order::kNone, -1, false, 4, -1},
  {22, "ccv_miu_fet_itlb", Blk::MIU, Blk::FET, 1, 64, 1, kF_ccv_miu_fet_itlb, 1, false, 0, Order::kNone, -1, false, 4, -1},
  {23, "ccv_fet_miu_itlb_req", Blk::FET, Blk::MIU, 1, 72, 2, kF_ccv_fet_miu_itlb_req, 1, false, 0, Order::kNone, -1, false, 4, -1},
  {24, "ccv_mlc_exb_req", Blk::MLC, Blk::EXB, 1, 1090, 7, kF_ccv_mlc_exb_req, 1, false, 0, Order::kNone, -1, false, 4, -1},
  {25, "ccv_exb_mlc_rsp", Blk::EXB, Blk::MLC, 1, 1082, 6, kF_ccv_exb_mlc_rsp, 1, false, 0, Order::kNone, -1, false, 5, -1},
  {26, "ccv_exb_ext_out", Blk::EXB, Blk::EXTERNAL, 1, 1225, 1, kF_ccv_exb_ext_out, 1, false, 0, Order::kNone, -1, false, 4, -1},
  {27, "ccv_rau_fet_launch", Blk::RAU, Blk::FET, 1, 184, 5, kF_ccv_rau_fet_launch, 1, false, 0, Order::kNone, -1, false, 1, -1},
  {28, "ccv_rau_ooe_alloc", Blk::RAU, Blk::OOE, 1, 59, 6, kF_ccv_rau_ooe_alloc, 1, false, 0, Order::kNone, -1, false, 1, -1},
  {29, "ccv_ooe_rau_status", Blk::OOE, Blk::RAU, 1, 16, 5, kF_ccv_ooe_rau_status, 1, false, 0, Order::kNone, -1, false, 1, -1},
  {30, "ccv_rau_ooe_demote", Blk::RAU, Blk::OOE, 1, 6, 2, kF_ccv_rau_ooe_demote, 1, false, 0, Order::kNone, -1, false, 1, -1},
  {31, "ccv_ooe_rau_drained", Blk::OOE, Blk::RAU, 1, 70, 3, kF_ccv_ooe_rau_drained, 1, false, 0, Order::kNone, -1, false, 1, -1},
  {32, "ccv_rau_rcu_mig", Blk::RAU, Blk::RCU, 1, 9, 3, kF_ccv_rau_rcu_mig, 1, false, 0, Order::kNone, -1, false, 1, -1},
  {33, "ccv_rcu_pca_mig", Blk::RCU, Blk::PCA, 1, 2057, 4, kF_ccv_rcu_pca_mig, 1, false, 0, Order::kNone, -1, false, 1, -1},
  {34, "ccv_pca_rcu_mig", Blk::PCA, Blk::RCU, 1, 2057, 4, kF_ccv_pca_rcu_mig, 1, false, 0, Order::kNone, -1, false, 1, -1},
  {35, "ccv_fet_pca_mig", Blk::FET, Blk::PCA, 1, 261, 2, kF_ccv_fet_pca_mig, 1, false, 0, Order::kNone, -1, false, 1, -1},
  {36, "ccv_pca_fet_mig", Blk::PCA, Blk::FET, 1, 261, 2, kF_ccv_pca_fet_mig, 1, false, 0, Order::kNone, -1, false, 1, -1},
  {37, "ccv_rau_fet_mig", Blk::RAU, Blk::FET, 1, 9, 3, kF_ccv_rau_fet_mig, 1, false, 0, Order::kNone, -1, false, 1, -1},
  {38, "ccv_pca_rau_mig_done", Blk::PCA, Blk::RAU, 1, 5, 1, kF_ccv_pca_rau_mig_done, 1, false, 0, Order::kNone, -1, false, 1, -1},
  {39, "ccv_rau_miu_cta", Blk::RAU, Blk::MIU, 1, 101, 4, kF_ccv_rau_miu_cta, 1, false, 0, Order::kNone, -1, false, 1, -1},
  {40, "ccv_ooe_syu_bar", Blk::OOE, Blk::SYU, 1, 13, 4, kF_ccv_ooe_syu_bar, 1, false, 0, Order::kNone, -1, false, 2, -1},
  {41, "ccv_syu_ooe_rel", Blk::SYU, Blk::OOE, 1, 36, 2, kF_ccv_syu_ooe_rel, 1, false, 0, Order::kNone, -1, false, 1, -1},
  {42, "ccv_rau_syu_alloc", Blk::RAU, Blk::SYU, 1, 17, 4, kF_ccv_rau_syu_alloc, 1, false, 0, Order::kNone, -1, false, 1, -1},
  {43, "ccv_ooe_cru_fault", Blk::OOE, Blk::CRU, 1, 172, 6, kF_ccv_ooe_cru_fault, 1, false, 0, Order::kNone, -1, false, 2, -1},
  {44, "ccv_cru_rau_cfg", Blk::CRU, Blk::RAU, 1, 74, 5, kF_ccv_cru_rau_cfg, 1, false, 0, Order::kNone, -1, false, 1, -1},
  {45, "ccv_ext_exb_in", Blk::EXTERNAL, Blk::EXB, 1, 1176, 1, kF_ccv_ext_exb_in, 1, false, 0, Order::kNone, -1, false, 5, -1},
};
constexpr unsigned kNumChans = 46;

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
struct ChanInst {
  uint16_t chan; uint16_t inst; int16_t src; int16_t dst;
  uint32_t slot_base; uint64_t payload_base;
};
inline constexpr ChanInst kChanInsts[] = {
  {0, 0, 0, 1, 0, 0},
  {1, 0, 1, 2, 8, 976},
  {2, 0, 2, 3, 14, 1798},
  {3, 0, 3, 4, 18, 2350},
  {3, 1, 3, 5, 22, 2794},
  {3, 2, 3, 6, 26, 3238},
  {3, 3, 3, 7, 30, 3682},
  {3, 4, 3, 8, 34, 4126},
  {3, 5, 3, 9, 38, 4570},
  {3, 6, 3, 10, 42, 5014},
  {3, 7, 3, 11, 46, 5458},
  {3, 8, 3, 12, 50, 5902},
  {3, 9, 3, 13, 54, 6346},
  {3, 10, 3, 14, 58, 6790},
  {3, 11, 3, 15, 62, 7234},
  {3, 12, 3, 16, 66, 7678},
  {3, 13, 3, 17, 70, 8122},
  {3, 14, 3, 18, 74, 8566},
  {3, 15, 3, 19, 78, 9010},
  {3, 16, 3, 20, 82, 9454},
  {3, 17, 3, 21, 86, 9898},
  {3, 18, 3, 22, 90, 10342},
  {3, 19, 3, 23, 94, 10786},
  {3, 20, 3, 24, 98, 11230},
  {3, 21, 3, 25, 102, 11674},
  {3, 22, 3, 26, 106, 12118},
  {3, 23, 3, 27, 110, 12562},
  {3, 24, 3, 28, 114, 13006},
  {3, 25, 3, 29, 118, 13450},
  {3, 26, 3, 30, 122, 13894},
  {3, 27, 3, 31, 126, 14338},
  {3, 28, 3, 32, 130, 14782},
  {3, 29, 3, 33, 134, 15226},
  {3, 30, 3, 34, 138, 15670},
  {3, 31, 3, 35, 142, 16114},
  {4, 0, 4, 3, 146, 16558},
  {4, 1, 5, 3, 150, 16694},
  {4, 2, 6, 3, 154, 16830},
  {4, 3, 7, 3, 158, 16966},
  {4, 4, 8, 3, 162, 17102},
  {4, 5, 9, 3, 166, 17238},
  {4, 6, 10, 3, 170, 17374},
  {4, 7, 11, 3, 174, 17510},
  {4, 8, 12, 3, 178, 17646},
  {4, 9, 13, 3, 182, 17782},
  {4, 10, 14, 3, 186, 17918},
  {4, 11, 15, 3, 190, 18054},
  {4, 12, 16, 3, 194, 18190},
  {4, 13, 17, 3, 198, 18326},
  {4, 14, 18, 3, 202, 18462},
  {4, 15, 19, 3, 206, 18598},
  {4, 16, 20, 3, 210, 18734},
  {4, 17, 21, 3, 214, 18870},
  {4, 18, 22, 3, 218, 19006},
  {4, 19, 23, 3, 222, 19142},
  {4, 20, 24, 3, 226, 19278},
  {4, 21, 25, 3, 230, 19414},
  {4, 22, 26, 3, 234, 19550},
  {4, 23, 27, 3, 238, 19686},
  {4, 24, 28, 3, 242, 19822},
  {4, 25, 29, 3, 246, 19958},
  {4, 26, 30, 3, 250, 20094},
  {4, 27, 31, 3, 254, 20230},
  {4, 28, 32, 3, 258, 20366},
  {4, 29, 33, 3, 262, 20502},
  {4, 30, 34, 3, 266, 20638},
  {4, 31, 35, 3, 270, 20774},
  {5, 0, 3, 2, 274, 20910},
  {6, 0, 3, 36, 278, 21202},
  {7, 0, 36, 3, 282, 29806},
  {8, 0, 2, 36, 286, 34254},
  {9, 0, 36, 2, 290, 34626},
  {10, 0, 2, 36, 294, 35066},
  {11, 0, 2, 0, 298, 35098},
  {12, 0, 36, 37, 299, 35299},
  {13, 0, 37, 36, 303, 41207},
  {14, 0, 36, 38, 307, 45339},
  {15, 0, 38, 36, 311, 50187},
  {16, 0, 38, 39, 315, 54307},
  {17, 0, 39, 38, 316, 55389},
  {18, 0, 39, 38, 317, 56419},
  {19, 0, 38, 39, 318, 56470},
  {20, 0, 0, 39, 319, 57497},
  {21, 0, 39, 0, 320, 57555},
  {22, 0, 36, 0, 321, 58581},
  {23, 0, 0, 36, 322, 58645},
  {24, 0, 39, 44, 323, 58717},
  {25, 0, 44, 39, 324, 59807},
  {26, 0, 44, -1, 325, 60889},
  {27, 0, 40, 0, 326, 62114},
  {28, 0, 40, 2, 327, 62298},
  {29, 0, 2, 40, 328, 62357},
  {30, 0, 40, 2, 329, 62373},
  {31, 0, 2, 40, 330, 62379},
  {32, 0, 40, 3, 331, 62449},
  {33, 0, 3, 42, 332, 62458},
  {34, 0, 42, 3, 333, 64515},
  {35, 0, 0, 42, 334, 66572},
  {36, 0, 42, 0, 335, 66833},
  {37, 0, 40, 0, 336, 67094},
  {38, 0, 42, 40, 337, 67103},
  {39, 0, 40, 36, 338, 67108},
  {40, 0, 2, 41, 339, 67209},
  {41, 0, 41, 2, 340, 67222},
  {42, 0, 40, 41, 341, 67258},
  {43, 0, 2, 43, 342, 67275},
  {44, 0, 43, 40, 343, 67447},
  {45, 0, -1, 44, 344, 67521},
};
constexpr unsigned kNumChanInsts = 108;
constexpr unsigned kNumSlots = 345;
constexpr uint64_t kPayloadBits = 68697;

} // namespace skel
} // namespace ccv
#endif // CCV_SKEL_WIRING_H
