// GENERATED FILE -- DO NOT EDIT.
//
// Produced by tools/gen-interfaces.py from schema/interfaces.json.
// Edit the source and regenerate; tools/verify.sh fails if this file is stale.

#ifndef CCV_INTERFACES_H
#define CCV_INTERFACES_H

#include <cstdint>

namespace ccv {

/// Channel topology. The skeleton wires blocks from this, so a
/// connection that exists in the model and not in the RTL is a
/// generation error rather than a wiring mistake.
enum Channel : uint16_t {
  /// fet -> dec, 8/cycle
  CH_FET_DEC_INSTR = 0,
  /// dec -> ooe, 6/cycle
  CH_DEC_OOE_UOP = 1,
  /// ooe -> rcu, 4/cycle
  CH_OOE_RCU_ISSUE = 2,
  /// rcu -> lane, 4/cycle
  CH_RCU_LANE_OPS = 3,
  /// lane -> rcu, 4/cycle
  CH_LANE_RCU_RES = 4,
  /// rcu -> ooe, 4/cycle
  CH_RCU_OOE_DONE = 5,
  /// rcu -> miu, 4/cycle
  CH_RCU_MIU_ADDR = 6,
  /// miu -> rcu, 4/cycle
  CH_MIU_RCU_DATA = 7,
  /// ooe -> miu, 4/cycle
  CH_OOE_MIU_MEMOP = 8,
  /// miu -> ooe, 4/cycle
  CH_MIU_OOE_CMPL = 9,
  /// ooe -> miu, 4/cycle
  CH_OOE_MIU_RETIRE = 10,
  /// ooe -> fet, 1/cycle
  CH_OOE_FET_REDIRECT = 11,
  /// miu -> spm, 4/cycle
  CH_MIU_SPM_REQ = 12,
  /// spm -> miu, 4/cycle
  CH_SPM_MIU_RSP = 13,
  /// miu -> dcu, 4/cycle
  CH_MIU_DCU_REQ = 14,
  /// dcu -> miu, 4/cycle
  CH_DCU_MIU_RSP = 15,
  /// dcu -> mlc, 1/cycle
  CH_DCU_MLC_REQ = 16,
  /// mlc -> dcu, 1/cycle
  CH_MLC_DCU_RSP = 17,
  /// mlc -> dcu, 1/cycle
  CH_MLC_DCU_PROBE = 18,
  /// dcu -> mlc, 1/cycle
  CH_DCU_MLC_PROBE_ACK = 19,
  /// fet -> mlc, 1/cycle
  CH_FET_MLC_IFILL = 20,
  /// mlc -> fet, 1/cycle
  CH_MLC_FET_IFILL_RSP = 21,
  /// miu -> fet, 1/cycle
  CH_MIU_FET_ITLB = 22,
  /// fet -> miu, 1/cycle
  CH_FET_MIU_ITLB_REQ = 23,
  /// mlc -> exb, 1/cycle
  CH_MLC_EXB_REQ = 24,
  /// exb -> mlc, 1/cycle
  CH_EXB_MLC_RSP = 25,
  /// exb -> EXTERNAL, 1/cycle
  CH_EXB_EXT_OUT = 26,
  /// rau -> fet, 1/cycle
  CH_RAU_FET_LAUNCH = 27,
  /// rau -> ooe, 1/cycle
  CH_RAU_OOE_ALLOC = 28,
  /// ooe -> rau, 1/cycle
  CH_OOE_RAU_STATUS = 29,
  /// rau -> ooe, 1/cycle
  CH_RAU_OOE_DEMOTE = 30,
  /// ooe -> rau, 1/cycle
  CH_OOE_RAU_DRAINED = 31,
  /// rau -> rcu, 1/cycle
  CH_RAU_RCU_MIG = 32,
  /// rcu -> pca, 1/cycle
  CH_RCU_PCA_MIG = 33,
  /// pca -> rcu, 1/cycle
  CH_PCA_RCU_MIG = 34,
  /// fet -> pca, 1/cycle
  CH_FET_PCA_MIG = 35,
  /// pca -> fet, 1/cycle
  CH_PCA_FET_MIG = 36,
  /// rau -> fet, 1/cycle
  CH_RAU_FET_MIG = 37,
  /// pca -> rau, 1/cycle
  CH_PCA_RAU_MIG_DONE = 38,
  /// rau -> miu, 1/cycle
  CH_RAU_MIU_CTA = 39,
  /// ooe -> syu, 1/cycle
  CH_OOE_SYU_BAR = 40,
  /// syu -> ooe, 1/cycle
  CH_SYU_OOE_REL = 41,
  /// rau -> syu, 1/cycle
  CH_RAU_SYU_ALLOC = 42,
  /// ooe -> cru, 1/cycle
  CH_OOE_CRU_FAULT = 43,
  /// cru -> rau, 1/cycle
  CH_CRU_RAU_CFG = 44,
  /// EXTERNAL -> exb, 1/cycle
  CH_EXT_EXB_IN = 45,
  kChannelCount = 46,
};

struct ChannelInfo {
  const char *name;
  const char *src;
  const char *dst;
  unsigned    rate;
};

inline const ChannelInfo &channelInfo(Channel c) {
  static const ChannelInfo kInfo[] = {
      {"ccv_fet_dec_instr", "fet", "dec", 8},
      {"ccv_dec_ooe_uop", "dec", "ooe", 6},
      {"ccv_ooe_rcu_issue", "ooe", "rcu", 4},
      {"ccv_rcu_lane_ops", "rcu", "lane", 4},
      {"ccv_lane_rcu_res", "lane", "rcu", 4},
      {"ccv_rcu_ooe_done", "rcu", "ooe", 4},
      {"ccv_rcu_miu_addr", "rcu", "miu", 4},
      {"ccv_miu_rcu_data", "miu", "rcu", 4},
      {"ccv_ooe_miu_memop", "ooe", "miu", 4},
      {"ccv_miu_ooe_cmpl", "miu", "ooe", 4},
      {"ccv_ooe_miu_retire", "ooe", "miu", 4},
      {"ccv_ooe_fet_redirect", "ooe", "fet", 1},
      {"ccv_miu_spm_req", "miu", "spm", 4},
      {"ccv_spm_miu_rsp", "spm", "miu", 4},
      {"ccv_miu_dcu_req", "miu", "dcu", 4},
      {"ccv_dcu_miu_rsp", "dcu", "miu", 4},
      {"ccv_dcu_mlc_req", "dcu", "mlc", 1},
      {"ccv_mlc_dcu_rsp", "mlc", "dcu", 1},
      {"ccv_mlc_dcu_probe", "mlc", "dcu", 1},
      {"ccv_dcu_mlc_probe_ack", "dcu", "mlc", 1},
      {"ccv_fet_mlc_ifill", "fet", "mlc", 1},
      {"ccv_mlc_fet_ifill_rsp", "mlc", "fet", 1},
      {"ccv_miu_fet_itlb", "miu", "fet", 1},
      {"ccv_fet_miu_itlb_req", "fet", "miu", 1},
      {"ccv_mlc_exb_req", "mlc", "exb", 1},
      {"ccv_exb_mlc_rsp", "exb", "mlc", 1},
      {"ccv_exb_ext_out", "exb", "EXTERNAL", 1},
      {"ccv_rau_fet_launch", "rau", "fet", 1},
      {"ccv_rau_ooe_alloc", "rau", "ooe", 1},
      {"ccv_ooe_rau_status", "ooe", "rau", 1},
      {"ccv_rau_ooe_demote", "rau", "ooe", 1},
      {"ccv_ooe_rau_drained", "ooe", "rau", 1},
      {"ccv_rau_rcu_mig", "rau", "rcu", 1},
      {"ccv_rcu_pca_mig", "rcu", "pca", 1},
      {"ccv_pca_rcu_mig", "pca", "rcu", 1},
      {"ccv_fet_pca_mig", "fet", "pca", 1},
      {"ccv_pca_fet_mig", "pca", "fet", 1},
      {"ccv_rau_fet_mig", "rau", "fet", 1},
      {"ccv_pca_rau_mig_done", "pca", "rau", 1},
      {"ccv_rau_miu_cta", "rau", "miu", 1},
      {"ccv_ooe_syu_bar", "ooe", "syu", 1},
      {"ccv_syu_ooe_rel", "syu", "ooe", 1},
      {"ccv_rau_syu_alloc", "rau", "syu", 1},
      {"ccv_ooe_cru_fault", "ooe", "cru", 1},
      {"ccv_cru_rau_cfg", "cru", "rau", 1},
      {"ccv_ext_exb_in", "EXTERNAL", "exb", 1},
  };
  return kInfo[static_cast<unsigned>(c)];
}

static constexpr unsigned kPortsCru = 2;  // 1 in, 1 out
static constexpr unsigned kPortsDcu = 6;  // 3 in, 3 out
static constexpr unsigned kPortsDec = 2;  // 1 in, 1 out
static constexpr unsigned kPortsExb = 4;  // 2 in, 2 out
static constexpr unsigned kPortsFet = 10;  // 6 in, 4 out
static constexpr unsigned kPortsLane = 2;  // 1 in, 1 out
static constexpr unsigned kPortsMiu = 12;  // 7 in, 5 out
static constexpr unsigned kPortsMlc = 8;  // 4 in, 4 out
static constexpr unsigned kPortsOoe = 14;  // 6 in, 8 out
static constexpr unsigned kPortsPca = 5;  // 2 in, 3 out
static constexpr unsigned kPortsRau = 11;  // 4 in, 7 out
static constexpr unsigned kPortsRcu = 9;  // 5 in, 4 out
static constexpr unsigned kPortsSpm = 2;  // 1 in, 1 out
static constexpr unsigned kPortsSyu = 3;  // 2 in, 1 out

} // namespace ccv
#endif // CCV_INTERFACES_H
