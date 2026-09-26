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
localparam string CCV_SCHEMA_HASH = "aef57f9e3784cd2d";

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
// Instruction retires and commits architectural state. The event ccv-sim's functional oracle is checked against.
localparam int CCV_EV_RETIRE = 8;
// A transaction crossed a channel boundary. THE load-bearing event: §1 says decode, dispatch, retire and memory request/response ARE interface transactions, and the block-level grill-me made every one of them a credited channel. So the 40-channel list is the load-bearing event list, and one event type with the channel as a discriminator covers it -- emitted by the shared credit checker, so every boundary emits identically and no block can drift from the schema.
localparam int CCV_EV_CH_XFER = 11;
// An instruction is re-executed under a NEW id, linked to the old. Squash and replay are central to this machine -- branch recovery, load replay, demotion restore -- and a reused id would show one instruction with overlapping lifetimes instead of the replay. Arbitration-sensitive because whether a replay happens can depend on contention (load replay), so model and RTL may legitimately differ on it.
localparam int CCV_EV_ID_LINK = 12;

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
