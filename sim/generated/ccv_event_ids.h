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
static constexpr const char *kSchemaHash = "727da17b3c4367e2";

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
  /// Instruction retires and commits architectural state. Arbitration-sensitive (Q-41, closed by the OOE session 2026-10-02): commit bandwidth is shared across the four tier-1 ROBs, so the cycle a warp retires is an arbiter's decision, as EV_DISPATCH's is. What ccv-sim's oracle is checked against is the per-warp retirement SEQUENCE, correlated separately (the kernel run's retire order), not this event's cycle.
  EV_RETIRE = 8,
  /// A transaction crossed a channel boundary. THE load-bearing event: §1 says decode, dispatch, retire and memory request/response ARE interface transactions, and the block-level grill-me made every one of them a credited channel. So the 40-channel list is the load-bearing event list, and one event type with the channel as a discriminator covers it -- emitted by the shared credit checker, so every boundary emits identically and no block can drift from the schema.
  EV_CH_XFER = 11,
  /// An instruction is re-executed under a NEW id, linked to the old. Squash and replay are central to this machine -- branch recovery, load replay, demotion restore -- and a reused id would show one instruction with overlapping lifetimes instead of the replay. Arbitration-sensitive because whether a replay happens can depend on contention (load replay), so model and RTL may legitimately differ on it.
  EV_ID_LINK = 12,
  /// Rename blocks on a GPR with the free list empty. Per cycle: fires every cycle the condition holds, so its count is a duration. OOE's arbitration-sensitive set (register OI-7; docs/ooe-model.md, "Events owed to the schema").
  EV_OOE_GPR_EMPTY = 13,
  /// Rename blocks on another slot's floor or on this warp's ceiling. b: 0 floor, 1 ceiling; c: 0 GPR, 1 predicate. Per cycle: fires every cycle the condition holds, so its count is a duration. OOE's arbitration-sensitive set (register OI-7; docs/ooe-model.md, "Events owed to the schema").
  EV_OOE_RENAME_LIMIT = 14,
  /// Rename blocks on a predicate with the predicate free list empty. Per cycle: fires every cycle the condition holds, so its count is a duration. OOE's arbitration-sensitive set (register OI-7; docs/ooe-model.md, "Events owed to the schema").
  EV_OOE_PRED_EMPTY = 15,
  /// The warp's ROB has no entry at rename. Per cycle: fires every cycle the condition holds, so its count is a duration. OOE's arbitration-sensitive set (register OI-7; docs/ooe-model.md, "Events owed to the schema").
  EV_OOE_ROB_FULL = 16,
  /// The next ROB slot is held by a squashed op still in flight (deferred free, OI-10). Per cycle: fires every cycle the condition holds, so its count is a duration. OOE's arbitration-sensitive set (register OI-7; docs/ooe-model.md, "Events owed to the schema").
  EV_OOE_ROB_SLOT_HELD = 17,
  /// A reservation-station class has no free entry at rename. b: 0 RCU class, 1 MIU class. Per cycle: fires every cycle the condition holds, so its count is a duration. OOE's arbitration-sensitive set (register OI-7; docs/ooe-model.md, "Events owed to the schema").
  EV_OOE_RS_FULL = 18,
  /// The warp holds its reservation-station cap at rename. Per cycle: fires every cycle the condition holds, so its count is a duration. OOE's arbitration-sensitive set (register OI-7; docs/ooe-model.md, "Events owed to the schema").
  EV_OOE_RS_WARP_CAP = 19,
  /// DEC is held: a uop stays in ccv_dec_ooe_uop with the decode queue full. a is the warp of the oldest held uop. Per cycle: fires every cycle the condition holds, so its count is a duration. OOE's arbitration-sensitive set (register OI-7; docs/ooe-model.md, "Events owed to the schema").
  EV_OOE_DECQ_FULL = 20,
  /// A uop stays in the channel with its warp at its decode-queue maximum. Per cycle: fires every cycle the condition holds, so its count is a duration. OOE's arbitration-sensitive set (register OI-7; docs/ooe-model.md, "Events owed to the schema").
  EV_OOE_DECQ_WARP_MAX = 21,
  /// Rename is held behind an in-flight chwidth change. Per cycle: fires every cycle the condition holds, so its count is a duration. OOE's arbitration-sensitive set (register OI-7; docs/ooe-model.md, "Events owed to the schema").
  EV_OOE_CHWIDTH_HOLD = 22,
  /// Rename is held on a barrier wait. Per cycle: fires every cycle the condition holds, so its count is a duration. OOE's arbitration-sensitive set (register OI-7; docs/ooe-model.md, "Events owed to the schema").
  EV_OOE_BARRIER_HOLD = 23,
  /// A mispredict or epoch notice waits for the rate-1 redirect channel. b: redirects queued. Per cycle: fires every cycle the condition holds, so its count is a duration. OOE's arbitration-sensitive set (register OI-7; docs/ooe-model.md, "Events owed to the schema").
  EV_OOE_REDIRECT_BUSY = 24,
  /// A memop is ready but for an unconfirmed source while an MIU issue slot goes unused ("would have issued"). Per cycle: fires every cycle the condition holds, so its count is a duration. OOE's arbitration-sensitive set (register OI-7; docs/ooe-model.md, "Events owed to the schema").
  EV_OOE_MEMOP_HELD = 25,
  /// A memop issues; once per issue. c: cycles from all operands woken to issue. OOE's arbitration-sensitive set (register OI-7; docs/ooe-model.md, "Events owed to the schema").
  EV_OOE_MEMOP_HOLD_CYCLES = 26,
  /// A squash leaves an entry holding its registers for an op still in flight (OI-10); once per such entry. OOE's arbitration-sensitive set (register OI-7; docs/ooe-model.md, "Events owed to the schema").
  EV_OOE_DEFERRED_FREE = 27,
  /// An entry is ready and not issued; per cycle, per entry. OOE's arbitration-sensitive set (register OI-7; docs/ooe-model.md, "Events owed to the schema").
  EV_OOE_READY_NOT_SELECTED = 28,
  /// A withdrawn wake returns an issued entry to Waiting. c: depth from the missed load. OOE's arbitration-sensitive set (register OI-7; docs/ooe-model.md, "Events owed to the schema").
  EV_OOE_CANCEL_REPLAY = 29,
  /// A demotion trigger crosses its threshold at the ROB head; once per head. b: 0 MLC miss, 1 barrier, 2 fallback timer; c: cycles the head has stalled. OOE's arbitration-sensitive set (register OI-7; docs/ooe-model.md, "Events owed to the schema").
  EV_OOE_DEMOTE_TRIGGER = 30,
  /// A mispredict squashes entries of other PC groups; once per squash. OOE's arbitration-sensitive set (register OI-7; docs/ooe-model.md, "Events owed to the schema").
  EV_OOE_CROSS_GROUP_SQUASH = 31,
  /// A masked load issues its copy-only op (CCV_OP_PRF_COPY, A-38). OOE's arbitration-sensitive set (register OI-7; docs/ooe-model.md, "Events owed to the schema").
  EV_OOE_COPY_ISSUE = 32,
  kEventIdCount = 33,
};

/// Class of each event id, for the §5 correlation split.
inline EventClass eventClass(EventId id) {
  switch (id) {
  case EV_DISPATCH: return EventClass::kArbitrationSensitive;
  case EV_ISSUE: return EventClass::kArbitrationSensitive;
  case EV_WAKEUP: return EventClass::kArbitrationSensitive;
  case EV_WARP_SELECT: return EventClass::kArbitrationSensitive;
  case EV_RETIRE: return EventClass::kArbitrationSensitive;
  case EV_CH_XFER: return EventClass::kLoadBearing;
  case EV_ID_LINK: return EventClass::kArbitrationSensitive;
  case EV_OOE_GPR_EMPTY: return EventClass::kArbitrationSensitive;
  case EV_OOE_RENAME_LIMIT: return EventClass::kArbitrationSensitive;
  case EV_OOE_PRED_EMPTY: return EventClass::kArbitrationSensitive;
  case EV_OOE_ROB_FULL: return EventClass::kArbitrationSensitive;
  case EV_OOE_ROB_SLOT_HELD: return EventClass::kArbitrationSensitive;
  case EV_OOE_RS_FULL: return EventClass::kArbitrationSensitive;
  case EV_OOE_RS_WARP_CAP: return EventClass::kArbitrationSensitive;
  case EV_OOE_DECQ_FULL: return EventClass::kArbitrationSensitive;
  case EV_OOE_DECQ_WARP_MAX: return EventClass::kArbitrationSensitive;
  case EV_OOE_CHWIDTH_HOLD: return EventClass::kArbitrationSensitive;
  case EV_OOE_BARRIER_HOLD: return EventClass::kArbitrationSensitive;
  case EV_OOE_REDIRECT_BUSY: return EventClass::kArbitrationSensitive;
  case EV_OOE_MEMOP_HELD: return EventClass::kArbitrationSensitive;
  case EV_OOE_MEMOP_HOLD_CYCLES: return EventClass::kArbitrationSensitive;
  case EV_OOE_DEFERRED_FREE: return EventClass::kArbitrationSensitive;
  case EV_OOE_READY_NOT_SELECTED: return EventClass::kArbitrationSensitive;
  case EV_OOE_CANCEL_REPLAY: return EventClass::kArbitrationSensitive;
  case EV_OOE_DEMOTE_TRIGGER: return EventClass::kArbitrationSensitive;
  case EV_OOE_CROSS_GROUP_SQUASH: return EventClass::kArbitrationSensitive;
  case EV_OOE_COPY_ISSUE: return EventClass::kArbitrationSensitive;
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
  case EV_OOE_GPR_EMPTY: return "EV_OOE_GPR_EMPTY";
  case EV_OOE_RENAME_LIMIT: return "EV_OOE_RENAME_LIMIT";
  case EV_OOE_PRED_EMPTY: return "EV_OOE_PRED_EMPTY";
  case EV_OOE_ROB_FULL: return "EV_OOE_ROB_FULL";
  case EV_OOE_ROB_SLOT_HELD: return "EV_OOE_ROB_SLOT_HELD";
  case EV_OOE_RS_FULL: return "EV_OOE_RS_FULL";
  case EV_OOE_RS_WARP_CAP: return "EV_OOE_RS_WARP_CAP";
  case EV_OOE_DECQ_FULL: return "EV_OOE_DECQ_FULL";
  case EV_OOE_DECQ_WARP_MAX: return "EV_OOE_DECQ_WARP_MAX";
  case EV_OOE_CHWIDTH_HOLD: return "EV_OOE_CHWIDTH_HOLD";
  case EV_OOE_BARRIER_HOLD: return "EV_OOE_BARRIER_HOLD";
  case EV_OOE_REDIRECT_BUSY: return "EV_OOE_REDIRECT_BUSY";
  case EV_OOE_MEMOP_HELD: return "EV_OOE_MEMOP_HELD";
  case EV_OOE_MEMOP_HOLD_CYCLES: return "EV_OOE_MEMOP_HOLD_CYCLES";
  case EV_OOE_DEFERRED_FREE: return "EV_OOE_DEFERRED_FREE";
  case EV_OOE_READY_NOT_SELECTED: return "EV_OOE_READY_NOT_SELECTED";
  case EV_OOE_CANCEL_REPLAY: return "EV_OOE_CANCEL_REPLAY";
  case EV_OOE_DEMOTE_TRIGGER: return "EV_OOE_DEMOTE_TRIGGER";
  case EV_OOE_CROSS_GROUP_SQUASH: return "EV_OOE_CROSS_GROUP_SQUASH";
  case EV_OOE_COPY_ISSUE: return "EV_OOE_COPY_ISSUE";
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
  case EV_OOE_GPR_EMPTY:
    return slot == 0 ? "warp_id" : slot == 1 ? "owned_gprs" : "free_gprs";
  case EV_OOE_RENAME_LIMIT:
    return slot == 0 ? "warp_id" : slot == 1 ? "limit" : "pool";
  case EV_OOE_PRED_EMPTY:
    return slot == 0 ? "warp_id" : slot == 1 ? "owned_preds" : "unused";
  case EV_OOE_ROB_FULL:
    return slot == 0 ? "warp_id" : slot == 1 ? "rob_count" : "unused";
  case EV_OOE_ROB_SLOT_HELD:
    return slot == 0 ? "warp_id" : slot == 1 ? "rob_tag" : "unused";
  case EV_OOE_RS_FULL:
    return slot == 0 ? "warp_id" : slot == 1 ? "rs_class" : "free_entries";
  case EV_OOE_RS_WARP_CAP:
    return slot == 0 ? "warp_id" : slot == 1 ? "rs_held" : "cap";
  case EV_OOE_DECQ_FULL:
    return slot == 0 ? "warp_id" : slot == 1 ? "occupancy" : "unused";
  case EV_OOE_DECQ_WARP_MAX:
    return slot == 0 ? "warp_id" : slot == 1 ? "warp_entries" : "maximum";
  case EV_OOE_CHWIDTH_HOLD:
    return slot == 0 ? "warp_id" : slot == 1 ? "rob_tag" : "unused";
  case EV_OOE_BARRIER_HOLD:
    return slot == 0 ? "warp_id" : slot == 1 ? "barrier_id" : "unused";
  case EV_OOE_REDIRECT_BUSY:
    return slot == 0 ? "warp_id" : slot == 1 ? "queued" : "unused";
  case EV_OOE_MEMOP_HELD:
    return slot == 0 ? "warp_id" : slot == 1 ? "rs_entry" : "unused";
  case EV_OOE_MEMOP_HOLD_CYCLES:
    return slot == 0 ? "warp_id" : slot == 1 ? "rob_tag" : "cycles";
  case EV_OOE_DEFERRED_FREE:
    return slot == 0 ? "warp_id" : slot == 1 ? "rob_tag" : "unused";
  case EV_OOE_READY_NOT_SELECTED:
    return slot == 0 ? "warp_id" : slot == 1 ? "rs_entry" : "unused";
  case EV_OOE_CANCEL_REPLAY:
    return slot == 0 ? "warp_id" : slot == 1 ? "rs_entry" : "depth";
  case EV_OOE_DEMOTE_TRIGGER:
    return slot == 0 ? "warp_id" : slot == 1 ? "trigger" : "stall_cycles";
  case EV_OOE_CROSS_GROUP_SQUASH:
    return slot == 0 ? "warp_id" : slot == 1 ? "other_group_entries" : "branch_rob_tag";
  case EV_OOE_COPY_ISSUE:
    return slot == 0 ? "warp_id" : slot == 1 ? "rob_tag" : "issue_slot";
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
