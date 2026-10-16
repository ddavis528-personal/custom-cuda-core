// GENERATED FILE -- DO NOT EDIT.
//
// Produced by tools/gen-event-schema.py from schema/events.json.
// Edit the schema and regenerate; tools/verify.sh fails if this file is stale.

`ifndef CCV_EVENT_IDS_SVH
`define CCV_EVENT_IDS_SVH

// Same identifiers as sim/generated/ccv_event_ids.h, from the
// same source. §9: a signal that is one name in RTL and another
// in the model imposes a translation tax on every 4d debug
// session, permanently.

// A generated header is a CATALOGUE: it declares every event id and unit in
// the schema, and no single consumer uses all of them. That is the intended
// shape, not an oversight, so the unused-parameter warning is turned off for
// this file only -- narrowly, and here rather than at the call site, so a
// genuinely unused parameter in hand-written RTL still gets caught.
/* verilator lint_off UNUSEDPARAM */
localparam int CCV_SCHEMA_VERSION = 2;
localparam string CCV_SCHEMA_HASH = "727da17b3c4367e2";

localparam int CCV_UNIT_UNKNOWN = 0;
localparam int CCV_UNIT_TESTBENCH = 1;
localparam int CCV_UNIT_FET = 2;
localparam int CCV_UNIT_DEC = 3;
localparam int CCV_UNIT_OOE = 4;
localparam int CCV_UNIT_RCU = 5;
localparam int CCV_UNIT_LANE = 6;
localparam int CCV_UNIT_MIU = 7;
localparam int CCV_UNIT_SPM = 8;
localparam int CCV_UNIT_DCU = 9;
localparam int CCV_UNIT_MLC = 10;
localparam int CCV_UNIT_RAU = 11;
localparam int CCV_UNIT_SYU = 12;
localparam int CCV_UNIT_PCA = 13;
localparam int CCV_UNIT_CRU = 14;
localparam int CCV_UNIT_EXB = 15;

// ROB allocation in OOE: the cycle an instruction takes a reorder-buffer entry. Kept under Q-2's principle because that cycle is decided by OOE's allocation arbitration, internal to the block; the uop's arrival is ccv_dec_ooe_uop's EV_CH_XFER. Q-1 content: its final definition comes with OOE's Stage 4a.
localparam int CCV_EV_DISPATCH = 2;
// Instruction is selected by the arbiter and issues. §1 names issue cycle as the canonical arbitration-sensitive event: an oldest-ready model and a priority-encoder tie-break diverge on every tie, permanently, and it looks exactly like a bug.
localparam int CCV_EV_ISSUE = 3;
// An operand became ready. Paired with EV_ISSUE it gives §1's wakeup-to-issue latency.
localparam int CCV_EV_WAKEUP = 4;
// Two-tier SMT warp-select outcome, including which warps were eligible but not chosen -- a losing candidate is what makes a tie-break diff meaningful.
localparam int CCV_EV_WARP_SELECT = 5;
// Instruction retires and commits architectural state. Arbitration-sensitive (Q-41, closed by the OOE session 2026-10-02): commit bandwidth is shared across the four tier-1 ROBs, so the cycle a warp retires is an arbiter's decision, as EV_DISPATCH's is. What ccv-sim's oracle is checked against is the per-warp retirement SEQUENCE, correlated separately (the kernel run's retire order), not this event's cycle.
localparam int CCV_EV_RETIRE = 8;
// A transaction crossed a channel boundary. THE load-bearing event: §1 says decode, dispatch, retire and memory request/response ARE interface transactions, and the block-level grill-me made every one of them a credited channel. So the 40-channel list is the load-bearing event list, and one event type with the channel as a discriminator covers it -- emitted by the shared credit checker, so every boundary emits identically and no block can drift from the schema.
localparam int CCV_EV_CH_XFER = 11;
// An instruction is re-executed under a NEW id, linked to the old. Squash and replay are central to this machine -- branch recovery, load replay, demotion restore -- and a reused id would show one instruction with overlapping lifetimes instead of the replay. Arbitration-sensitive because whether a replay happens can depend on contention (load replay), so model and RTL may legitimately differ on it.
localparam int CCV_EV_ID_LINK = 12;
// Rename blocks on a GPR with the free list empty. Per cycle: fires every cycle the condition holds, so its count is a duration. OOE's arbitration-sensitive set (register OI-7; docs/ooe-model.md, "Events owed to the schema").
localparam int CCV_EV_OOE_GPR_EMPTY = 13;
// Rename blocks on another slot's floor or on this warp's ceiling. b: 0 floor, 1 ceiling; c: 0 GPR, 1 predicate. Per cycle: fires every cycle the condition holds, so its count is a duration. OOE's arbitration-sensitive set (register OI-7; docs/ooe-model.md, "Events owed to the schema").
localparam int CCV_EV_OOE_RENAME_LIMIT = 14;
// Rename blocks on a predicate with the predicate free list empty. Per cycle: fires every cycle the condition holds, so its count is a duration. OOE's arbitration-sensitive set (register OI-7; docs/ooe-model.md, "Events owed to the schema").
localparam int CCV_EV_OOE_PRED_EMPTY = 15;
// The warp's ROB has no entry at rename. Per cycle: fires every cycle the condition holds, so its count is a duration. OOE's arbitration-sensitive set (register OI-7; docs/ooe-model.md, "Events owed to the schema").
localparam int CCV_EV_OOE_ROB_FULL = 16;
// The next ROB slot is held by a squashed op still in flight (deferred free, OI-10). Per cycle: fires every cycle the condition holds, so its count is a duration. OOE's arbitration-sensitive set (register OI-7; docs/ooe-model.md, "Events owed to the schema").
localparam int CCV_EV_OOE_ROB_SLOT_HELD = 17;
// A reservation-station class has no free entry at rename. b: 0 RCU class, 1 MIU class. Per cycle: fires every cycle the condition holds, so its count is a duration. OOE's arbitration-sensitive set (register OI-7; docs/ooe-model.md, "Events owed to the schema").
localparam int CCV_EV_OOE_RS_FULL = 18;
// The warp holds its reservation-station cap at rename. Per cycle: fires every cycle the condition holds, so its count is a duration. OOE's arbitration-sensitive set (register OI-7; docs/ooe-model.md, "Events owed to the schema").
localparam int CCV_EV_OOE_RS_WARP_CAP = 19;
// DEC is held: a uop stays in ccv_dec_ooe_uop with the decode queue full. a is the warp of the oldest held uop. Per cycle: fires every cycle the condition holds, so its count is a duration. OOE's arbitration-sensitive set (register OI-7; docs/ooe-model.md, "Events owed to the schema").
localparam int CCV_EV_OOE_DECQ_FULL = 20;
// A uop stays in the channel with its warp at its decode-queue maximum. Per cycle: fires every cycle the condition holds, so its count is a duration. OOE's arbitration-sensitive set (register OI-7; docs/ooe-model.md, "Events owed to the schema").
localparam int CCV_EV_OOE_DECQ_WARP_MAX = 21;
// Rename is held behind an in-flight chwidth change. Per cycle: fires every cycle the condition holds, so its count is a duration. OOE's arbitration-sensitive set (register OI-7; docs/ooe-model.md, "Events owed to the schema").
localparam int CCV_EV_OOE_CHWIDTH_HOLD = 22;
// Rename is held on a barrier wait. Per cycle: fires every cycle the condition holds, so its count is a duration. OOE's arbitration-sensitive set (register OI-7; docs/ooe-model.md, "Events owed to the schema").
localparam int CCV_EV_OOE_BARRIER_HOLD = 23;
// A mispredict or epoch notice waits for the rate-1 redirect channel. b: redirects queued. Per cycle: fires every cycle the condition holds, so its count is a duration. OOE's arbitration-sensitive set (register OI-7; docs/ooe-model.md, "Events owed to the schema").
localparam int CCV_EV_OOE_REDIRECT_BUSY = 24;
// A memop is ready but for an unconfirmed source while an MIU issue slot goes unused ("would have issued"). Per cycle: fires every cycle the condition holds, so its count is a duration. OOE's arbitration-sensitive set (register OI-7; docs/ooe-model.md, "Events owed to the schema").
localparam int CCV_EV_OOE_MEMOP_HELD = 25;
// A memop issues; once per issue. c: cycles from all operands woken to issue. OOE's arbitration-sensitive set (register OI-7; docs/ooe-model.md, "Events owed to the schema").
localparam int CCV_EV_OOE_MEMOP_HOLD_CYCLES = 26;
// A squash leaves an entry holding its registers for an op still in flight (OI-10); once per such entry. OOE's arbitration-sensitive set (register OI-7; docs/ooe-model.md, "Events owed to the schema").
localparam int CCV_EV_OOE_DEFERRED_FREE = 27;
// An entry is ready and not issued; per cycle, per entry. OOE's arbitration-sensitive set (register OI-7; docs/ooe-model.md, "Events owed to the schema").
localparam int CCV_EV_OOE_READY_NOT_SELECTED = 28;
// A withdrawn wake returns an issued entry to Waiting. c: depth from the missed load. OOE's arbitration-sensitive set (register OI-7; docs/ooe-model.md, "Events owed to the schema").
localparam int CCV_EV_OOE_CANCEL_REPLAY = 29;
// A demotion trigger crosses its threshold at the ROB head; once per head. b: 0 MLC miss, 1 barrier, 2 fallback timer; c: cycles the head has stalled. OOE's arbitration-sensitive set (register OI-7; docs/ooe-model.md, "Events owed to the schema").
localparam int CCV_EV_OOE_DEMOTE_TRIGGER = 30;
// A mispredict squashes entries of other PC groups; once per squash. OOE's arbitration-sensitive set (register OI-7; docs/ooe-model.md, "Events owed to the schema").
localparam int CCV_EV_OOE_CROSS_GROUP_SQUASH = 31;
// A masked load issues its copy-only op (CCV_OP_PRF_COPY, A-38). OOE's arbitration-sensitive set (register OI-7; docs/ooe-model.md, "Events owed to the schema").
localparam int CCV_EV_OOE_COPY_ISSUE = 32;

// Trace identity layout. Only meaningful under CCV_TRACE.
localparam int CCV_UID_SEQ_LSB = 0;
localparam int CCV_UID_SEQ_W = 32;
localparam int CCV_UID_SUB_LSB = 32;
localparam int CCV_UID_SUB_W = 16;
localparam int CCV_UID_OWNED_LSB = 61;
localparam int CCV_UID_OWNED_W = 1;
localparam int CCV_UID_CLASS_LSB = 62;
localparam int CCV_UID_CLASS_W = 2;
localparam int CCV_ID_NONE = 0;
localparam int CCV_ID_INSTR = 1;
localparam int CCV_ID_TXN = 2;

/* verilator lint_on UNUSEDPARAM */

`endif // CCV_EVENT_IDS_SVH
