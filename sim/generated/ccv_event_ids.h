// GENERATED FILE -- DO NOT EDIT.
//
// Produced by tools/gen-event-schema.py from schema/events.json.
// Edit the schema and regenerate; tools/verify.sh fails if this file is stale.

#ifndef CCV_EVENT_IDS_H
#define CCV_EVENT_IDS_H

#include <cstdint>

namespace ccv {

/// Bumped whenever the schema's semantic content changes.
static constexpr uint32_t kSchemaVersion = 2;
/// Semantic hash of the schema. Written into every trace header
/// and checked on read, so a trace can never be silently
/// interpreted against a schema it was not written under.
static constexpr const char *kSchemaHash = "aef57f9e3784cd2d";

enum class EventClass : uint16_t {
  kLoadBearing = 0,          ///< exact match required (§1)
  kArbitrationSensitive = 1, ///< comparable only against a faithful arbiter model
};

enum Unit : uint16_t {
  UNIT_UNKNOWN = 0,
  UNIT_TESTBENCH = 1,
  UNIT_FET = 2,
  UNIT_DEC = 3,
  UNIT_OOE = 4,
  UNIT_RCU = 5,
  UNIT_LANE = 6,
  UNIT_MIU = 7,
  UNIT_SPM = 8,
  UNIT_DCU = 9,
  UNIT_MLC = 10,
  UNIT_RAU = 11,
  UNIT_SYU = 12,
  UNIT_PCA = 13,
  UNIT_CRU = 14,
  UNIT_EXB = 15,
};

enum EventId : uint16_t {
  /// ROB allocation in OOE: the cycle an instruction takes a reorder-buffer entry. Kept under Q-2's principle because that cycle is decided by OOE's allocation arbitration, internal to the block; the uop's arrival is ccv_dec_ooe_uop's EV_CH_XFER. Q-1 content: its final definition comes with OOE's Stage 4a.
  EV_DISPATCH = 2,
  /// Instruction is selected by the arbiter and issues. §1 names issue cycle as the canonical arbitration-sensitive event: an oldest-ready model and a priority-encoder tie-break diverge on every tie, permanently, and it looks exactly like a bug.
  EV_ISSUE = 3,
  /// An operand became ready. Paired with EV_ISSUE it gives §1's wakeup-to-issue latency.
  EV_WAKEUP = 4,
  /// Two-tier SMT warp-select outcome, including which warps were eligible but not chosen -- a losing candidate is what makes a tie-break diff meaningful.
  EV_WARP_SELECT = 5,
  /// Instruction retires and commits architectural state. The event ccv-sim's functional oracle is checked against.
  EV_RETIRE = 8,
  /// A transaction crossed a channel boundary. THE load-bearing event: §1 says decode, dispatch, retire and memory request/response ARE interface transactions, and the block-level grill-me made every one of them a credited channel. So the 40-channel list is the load-bearing event list, and one event type with the channel as a discriminator covers it -- emitted by the shared credit checker, so every boundary emits identically and no block can drift from the schema.
  EV_CH_XFER = 11,
  /// An instruction is re-executed under a NEW id, linked to the old. Squash and replay are central to this machine -- branch recovery, load replay, demotion restore -- and a reused id would show one instruction with overlapping lifetimes instead of the replay. Arbitration-sensitive because whether a replay happens can depend on contention (load replay), so model and RTL may legitimately differ on it.
  EV_ID_LINK = 12,
  kEventIdCount = 13,
};

/// Class of each event id, for the §5 correlation split.
inline EventClass eventClass(EventId id) {
  switch (id) {
  case EV_DISPATCH: return EventClass::kArbitrationSensitive;
  case EV_ISSUE: return EventClass::kArbitrationSensitive;
  case EV_WAKEUP: return EventClass::kArbitrationSensitive;
  case EV_WARP_SELECT: return EventClass::kArbitrationSensitive;
  case EV_RETIRE: return EventClass::kLoadBearing;
  case EV_CH_XFER: return EventClass::kLoadBearing;
  case EV_ID_LINK: return EventClass::kArbitrationSensitive;
  default: return EventClass::kLoadBearing;
  }
}

inline const char *eventName(EventId id) {
  switch (id) {
  case EV_DISPATCH: return "EV_DISPATCH";
  case EV_ISSUE: return "EV_ISSUE";
  case EV_WAKEUP: return "EV_WAKEUP";
  case EV_WARP_SELECT: return "EV_WARP_SELECT";
  case EV_RETIRE: return "EV_RETIRE";
  case EV_CH_XFER: return "EV_CH_XFER";
  case EV_ID_LINK: return "EV_ID_LINK";
  default: return "EV_UNKNOWN";
  }
}

inline const char *unitName(uint16_t u) {
  switch (u) {
  case 0: return "UNIT_UNKNOWN";
  case 1: return "UNIT_TESTBENCH";
  case 2: return "UNIT_FET";
  case 3: return "UNIT_DEC";
  case 4: return "UNIT_OOE";
  case 5: return "UNIT_RCU";
  case 6: return "UNIT_LANE";
  case 7: return "UNIT_MIU";
  case 8: return "UNIT_SPM";
  case 9: return "UNIT_DCU";
  case 10: return "UNIT_MLC";
  case 11: return "UNIT_RAU";
  case 12: return "UNIT_SYU";
  case 13: return "UNIT_PCA";
  case 14: return "UNIT_CRU";
  case 15: return "UNIT_EXB";
  default: return "UNIT_UNKNOWN";
  }
}

/// Field names per event, in payload order (a, b, c). These are
/// the names §9 requires the RTL to use for the same signals.
inline const char *fieldName(EventId id, unsigned slot) {
  switch (id) {
  case EV_DISPATCH:
    return slot == 0 ? "warp_id" : slot == 1 ? "rob_slot" : "unused";
  case EV_ISSUE:
    return slot == 0 ? "warp_id" : slot == 1 ? "issue_port" : "iq_slot";
  case EV_WAKEUP:
    return slot == 0 ? "warp_id" : slot == 1 ? "iq_slot" : "src_idx";
  case EV_WARP_SELECT:
    return slot == 0 ? "warp_id" : slot == 1 ? "tier" : "eligible_mask";
  case EV_RETIRE:
    return slot == 0 ? "warp_id" : slot == 1 ? "rob_slot" : "active_mask";
  case EV_CH_XFER:
    return slot == 0 ? "channel_id" : slot == 1 ? "payload_lo" : "payload_hi";
  case EV_ID_LINK:
    return slot == 0 ? "new_seq" : slot == 1 ? "old_seq" : "reason";
  default: return "unused";
  }
}

/// Trace identity (the instr_uid of every event). Trace-only:
/// it rides in a CCV_TRACE sideband, never in a payload struct.
enum class IdClass : uint8_t {
  kNone = 0,
  kInstr = 1,
  kTxn = 2,
};
enum ReplayReason : uint32_t {
  kReplayBranchRecovery = 1,
  kReplayLoadReplay = 2,
  kReplayDemotionRestore = 3,
};
static constexpr unsigned kUidSeqLsb = 0, kUidSeqWidth = 32;
static constexpr unsigned kUidSubLsb = 32, kUidSubWidth = 16;
static constexpr unsigned kUidOwnedLsb = 61, kUidOwnedWidth = 1;
static constexpr unsigned kUidClassLsb = 62, kUidClassWidth = 2;
inline uint64_t makeUid(IdClass c, uint32_t seq, uint16_t sub = 0,
                        bool owned = false) {
  return (uint64_t(c) << kUidClassLsb) | (uint64_t(owned) << kUidOwnedLsb) |
         (uint64_t(sub) << kUidSubLsb) | (uint64_t(seq) << kUidSeqLsb);
}
inline IdClass uidClass(uint64_t u) {
  return IdClass((u >> kUidClassLsb) & ((1u << kUidClassWidth) - 1));
}
inline uint32_t uidSeq(uint64_t u) { return uint32_t(u >> kUidSeqLsb); }
inline uint16_t uidSub(uint64_t u) { return uint16_t(u >> kUidSubLsb); }
inline bool uidOwned(uint64_t u) { return (u >> kUidOwnedLsb) & 1u; }

} // namespace ccv
#endif // CCV_EVENT_IDS_H
