// GENERATED FILE -- DO NOT EDIT.
//
// Produced by tools/gen-params.py from params/ccv_params.json.
// Edit the source and regenerate; tools/verify.sh fails if this file is stale.

`ifndef CCV_PARAMS_PKG_SV
`define CCV_PARAMS_PKG_SV

// A parameter package is a CATALOGUE: it declares every machine
// parameter, and no single module uses all of them. That is the
// intended shape, not an oversight, so the unused-parameter
// warning is turned off for this file only -- narrowly, and here
// rather than at the instantiation site, so a genuinely unused
// parameter on a hand-written module still gets caught.
/* verilator lint_off UNUSEDPARAM */

// Values that follow from decisions already made. Nothing here
// is expected to move.
package ccv_params_pkg;

  // Lanes per warp. A logical GPR holds 32 lanes, one element each, at every chwidth.
  // settled by the ISA -- not a knob (ISA v1.6 §1 -- warp width, settled)
  localparam int CCV_WARP_LANES = 32;

  // Architectural GPRs. 16 x 1024 bit = 2 KB per warp.
  // settled by the ISA -- not a knob (ISA v1.6 §1, O-25)
  localparam int CCV_GPRS = 16;

  // Logical predicates. A performance parameter, not a structural ceiling.
  // ISA-level, still provisional (ISA v1.6 §1 -- provisional pending compiler data; measured pressure 1-2 of 4)
  localparam int CCV_PREDS = 4;

  // Global address width.
  // settled by the ISA -- not a knob (ISA v1.6 §1)
  localparam int CCV_ADDR_BITS = 48;

  // Physical datapath width.
  // settled by the ISA -- not a knob (ISA v1.6 §1 -- 32 lanes x 32 bits)
  localparam int CCV_DATAPATH_BITS = 1024;

  // Tier-1 resident warps, SMT-4 equivalent. Four slots covering a DRAM latency near 1000 cycles requires that demotion happen only on TRUE misses -- demoting on short stalls would need roughly 84 warps to keep 4 slots busy.
  // decided at the block-level grill-me (grill-me 2026-09-23)
  localparam int CCV_TIER1_WARPS = 4;

  // Warps parked in PCA. 32 total contexts.
  // decided at the block-level grill-me (grill-me 2026-09-23)
  localparam int CCV_PARKED_WARPS = 28;

  // Warp contexts the core holds, resident and parked: the width of every per-warp mask (kill_warp_mask, warp_mask_released). One name, so a mask sized by it cannot miss a residency tier added later. Equal to CCV_W_LANE_MASK today by coincidence only (A-12).  Derived: = CCV_TIER1_WARPS + CCV_PARKED_WARPS.
  // decided at the block-level grill-me (arch open A-23 (2026-09-27))
  localparam int CCV_WARP_CONTEXTS = 32;

  // Instructions fetched per warp per cycle, all 4 tier-1 warps in parallel.
  // decided at the block-level grill-me (grill-me 2026-09-23)
  localparam int CCV_FETCH_PER_WARP = 2;

  // Rename and issue width. The binding width of the machine.
  // decided at the block-level grill-me (grill-me 2026-09-23)
  localparam int CCV_ISSUE_WIDTH = 4;

  // One ROB per tier-1 warp.
  // decided at the block-level grill-me (grill-me 2026-09-23)
  localparam int CCV_ROB_INSTANCES = 4;

  // Retire per ROB per cycle. 8 peak against 4-wide issue.
  // decided at the block-level grill-me (grill-me 2026-09-23)
  localparam int CCV_RETIRE_PER_ROB = 2;

  // Address generation pipes in MIU, sized for 8-bit coalescing.
  // decided at the block-level grill-me (grill-me 2026-09-23)
  localparam int CCV_AGU_PIPES = 4;

  // TLB translations per cycle on the hit path, no page split.
  // decided at the block-level grill-me (grill-me 2026-09-23)
  localparam int CCV_TLB_XLAT_PER_CYCLE = 4;

  // Scratchpad capacity, 128 KB.
  // decided at the block-level grill-me (grill-me 2026-09-23)
  localparam int CCV_SPM_BYTES = 131072;

  // Scratchpad banks, 32 x 32 bits. Bank conflicts are a first-order GEMM effect, which is why the scratchpad is a design block rather than testbench.
  // decided at the block-level grill-me (grill-me 2026-09-23)
  localparam int CCV_SPM_BANKS = 32;

  // Barrier table entries, 4 x 16, epoch-tagged. A §7 formal target.
  // settled by the ISA -- not a knob (ISA v1.6 §3, Format E -- 6-bit barrier ID)
  localparam int CCV_BARRIER_ENTRIES = 64;

  // Up to 4 cores per MLC. Present from day one rather than added when a second core appears, because adding a struct field later regenerates every typedef, header, harness and checker at that boundary.
  // decided at the block-level grill-me (grill-me 2026-09-23)
  localparam int CCV_CORE_ID_BITS = 2;

  // Migration transfer, each way, one 1024-bit row per cycle: the 16 GPR rows plus ceil(CCV_W_PRED_STATE / CCV_W_DATA) rows of predicate state, one. Derived, not chosen (arch open A-22): if the predicate state ever grows past a row this follows, refused by tools/gen-params.py until it does. It was 16, counting GPRs only, while the channel carried the predicate state beside every row (A-1). At one swap per ~125 cycles this uses the single migration path at about 27 percent.  Derived: = CCV_GPRS + cdiv(CCV_W_PRED_STATE, CCV_W_DATA).
  // decided at the block-level grill-me (grill-me 2026-09-23)
  localparam int CCV_MIGRATION_CYCLES = 17;

  // Migration row index on ccv_rcu_pca_mig / ccv_pca_rcu_mig: rows 0-15 GPRs, 16 and up predicate and divergence state. Sized by the row count, so it widens when CCV_MIGRATION_CYCLES does.  Derived: = clog2(CCV_MIGRATION_CYCLES).
  // decided at the block-level grill-me (arch opens A-1, A-22 (2026-09-27))
  localparam int CCV_W_MIG_ROW = 5;

  // A warp's migrated predicate state: its 4 architectural predicates of one bit per lane. It was CCV_L_W_PRED_STATE = 1024, preliminary, sized for a reconvergence stack as well; FET now owns divergence (checkpoints and min-PC reconvergence, no stack) and the PC groups migrate through FET, so RCU migrates only the predicates (A-50). One migration row.  Derived: = CCV_PREDS * CCV_W_LANE_MASK.
  // decided at the block-level grill-me (OOE Stage 4 session (2026-10-02), interface change set; arch open A-50)
  localparam int CCV_W_PRED_STATE = 128;

  // Normalized gate delay in one cycle. OPEN (§2): whether 25 is the Vmin-corner number or a nominal one. Per-INTERFACE-PATH budgets are assigned once contracts are drawn, not per block.
  // physical target, not a structure size (§2 -- ~1.5 GHz at Vmin 0.55 V on an N3E-class process)
  localparam int CCV_NGD_BUDGET = 25;

  // Warp id. 32 total warp contexts.
  // decided at the block-level grill-me (ports spec 2026-09-23)
  localparam int CCV_W_WARP_ID = 5;

  // Tier-1 slot, which also selects the ROB instance.
  // decided at the block-level grill-me (ports spec 2026-09-23)
  localparam int CCV_W_TIER1_ID = 2;

  // Architectural GPR index. 16 GPRs (ISA v1.6 §1).
  // settled by the ISA -- not a knob (ports spec 2026-09-23)
  localparam int CCV_W_ARCH_REG = 4;

  // Architectural predicate index. 4 predicates (ISA v1.6 §1). A separate namespace from the GPRs, with its own RAT and count, even while the width happens to be smaller.
  // settled by the ISA -- not a knob (Payload spec response (2026-09-25))
  localparam int CCV_W_ARCH_PRED = 2;

  // Memory displacement, sign-extended at the AGU. The widest memory-format offset is cas's 16-bit signed field (ISA v1.6 §3); Format D's simm13, D-prime's simm10, the atomics' simm9 and base+index's simm8 all fit. (The compiler had declared cas's offset uimm16, which would have needed 17: compiler F-143, fixed.)
  // settled by the ISA -- not a knob (Skeleton review response (2026-09-25))
  localparam int CCV_W_DISP = 16;

  // srd #1's %ctaid, the flat CTA index within the grid (ISA v1.6 §5.3). Dispatch state, held by RAU and shadowed in OOE, which substitutes it into srd's immediate at issue. It exactly fills CCV_P_W_IMM, so it sets that parameter's floor.
  // settled by the ISA -- not a knob (srd response (2026-09-25), Q-38)
  localparam int CCV_W_CTAID = 32;

  // A warp's index within its CTA. %ctatid is 10 bits (ISA v1.6 §5.3) and a warp is 32 lanes, so 5. srd #0's warp_base = warp_in_cta << 5 has its low five bits zero, so the lane ORs its hardwired index in without an adder.
  // settled by the ISA -- not a knob (srd response (2026-09-25), Q-38)
  localparam int CCV_W_WARP_IN_CTA = 5;

  // One bit per lane.
  // settled by the ISA -- not a knob (ports spec 2026-09-23)
  localparam int CCV_W_LANE_MASK = 32;

  // Full datapath, 32 lanes x 32 bits.
  // settled by the ISA -- not a knob (ports spec 2026-09-23)
  localparam int CCV_W_DATA = 1024;

  // Lane datapath.
  // settled by the ISA -- not a knob (ports spec 2026-09-23)
  localparam int CCV_W_LANE_DATA = 32;

  // Element width code: 32, 16, 8, 4.
  // settled by the ISA -- not a knob (ports spec 2026-09-23)
  localparam int CCV_W_CHWIDTH = 2;

  // Up to 4 cores per MLC.
  // decided at the block-level grill-me (ports spec 2026-09-23)
  localparam int CCV_W_CORE_ID = 2;

  // Longest instruction form (ISA v1.6: 16/32/48).
  // settled by the ISA -- not a knob (ports spec 2026-09-23)
  localparam int CCV_W_INSTR = 48;

  // Instruction length code: three lengths.
  // settled by the ISA -- not a knob (ports spec 2026-09-23)
  localparam int CCV_W_ILEN = 2;

  // Address generation is 64-bit, though the ISA's architectural address is 48.
  // decided at the block-level grill-me (ports spec 2026-09-23)
  localparam int CCV_W_VA = 64;

  // 128 KB scratchpad.
  // decided at the block-level grill-me (ports spec 2026-09-23)
  localparam int CCV_W_SPM_ADDR = 17;

  // 32 banks.
  // decided at the block-level grill-me (ports spec 2026-09-23)
  localparam int CCV_W_SPM_BANK = 5;

  // 4 KB per bank, 32-bit words.
  // decided at the block-level grill-me (ports spec 2026-09-23)
  localparam int CCV_W_SPM_WORD = 10;

  // 64 barrier entries.
  // decided at the block-level grill-me (ports spec 2026-09-23)
  localparam int CCV_W_BAR_ENTRY = 6;

  // 16 barriers per CTA.
  // decided at the block-level grill-me (ports spec 2026-09-23)
  localparam int CCV_W_BAR_ID = 4;

  // Fault-model cause set, with headroom.
  // decided at the block-level grill-me (ports spec 2026-09-23)
  localparam int CCV_W_FAULT_CAUSE = 4;

  // Flop-to-flop round trip, abutting. TWO EVERYWHERE BY CONSTRUCTION -- flops on both sides with no exceptions, plus abutment, gives exactly this. It is not a per-interface choice, and the three values below are not independent numbers but the same number under different names. Only a non-abutting interface would differ, and none is known to be until floorplan.
  // decided at the block-level grill-me (ports spec 2026-09-23)
  localparam int CCV_RT_ABUT = 2;

  // What the endpoints add to the round trip before a credit can be spent again: the payload lands one cycle after its valid, the receiver returns the credit the cycle after that, and a credit that arrives is usable the cycle after (channel.h, credit_smoke.sv). So the credit loop is CCV_RT_ABUT + 2 = 4, not the round trip. Rescue depth and drain wait count only in-flight VALIDS and stay equal to the round trip.
  // decided at the block-level grill-me (Q-43, 2026-09-26)
  localparam int CCV_CREDIT_TURNAROUND = 2;

  // Credits held by a sender, and so the entries a receiver buffers: the CREDIT LOOP, CCV_RT_ABUT + CCV_CREDIT_TURNAROUND, so a channel runs at full bandwidth, one message per slot per cycle, at steady state. It was 2, equal to the round trip on the claim that abutting blocks are never throttled; measured, that runs every slot at half rate (Q-43, decided 2026-09-26: channels always run at full bandwidth). A repeated link's loop is 2N longer, and its depth with it. Proved in tools/check-formal.sh: full rate at this depth, and not at one less.
  // decided at the block-level grill-me (Q-43, 2026-09-26)
  localparam int CCV_CREDIT_DEPTH = 4;

  // Storage a stalling receiver reserves to catch everything already in flight. Equals the round trip: no unwinding, no negative acknowledgement.
  // decided at the block-level grill-me (ports spec 2026-09-23)
  localparam int CCV_RESCUE_DEPTH = 2;

  // Cycles to wait after asserting stall before nothing is in flight. Equals the round trip, which is what lets sleep entry, chwidth change and demotion share one mechanism and one proof.
  // decided at the block-level grill-me (ports spec 2026-09-23)
  localparam int CCV_DRAIN_WAIT = 2;

  // Wake latency: round trip plus 2. The sender's side of Q-33: a channel's wake leads valid toward a gated receiver by at least this many cycles (ccv_wake_checker). The receiver's side is ccv_clk_gate: it registers the wake (Q-49), so a wake in cycle T opens the edge ending T + 1, and holds the gate open through T + this, so a valid that follows the wake by exactly this much is still captured.
  // decided at the block-level grill-me (ports spec 2026-09-23)
  localparam int CCV_WAKE_LAT = 4;

  // One channel crossing with no repeater stages, from the sender launching a message to the receiver holding its payload: the valid crosses in half the round trip and the payload lands one cycle after its valid. A whole crossing is CCV_LAT_HOP + link_n(channel). Latencies that are linear in their crossings fold this into their base; a max over paths with different numbers of crossings (CCV_LAT_L1_WAKE) cannot, so it is named.  Derived: = CCV_RT_ABUT // 2 + 1.
  // decided at the block-level grill-me (channel protocol (channel.h); made explicit for A-61)
  localparam int CCV_LAT_HOP = 2;

  // Address-space id. 256 address spaces before a rollover forces a flush; with one resident context it exists to make switches cheap.
  // decided at the block-level grill-me (Payload widths pass (2026-09-25))
  localparam int CCV_W_ASID = 8;

  // Memory completion status: complete, replay, fault. `cause` carries the detail, so this stays at exactly the three outcomes.
  // decided at the block-level grill-me (Payload widths pass (2026-09-25))
  localparam int CCV_W_STATUS = 2;

  // Cache access size as a CODE -- powers of two up to a line -- not a byte count. Distinct from CCV_W_CHWIDTH, which is the architectural element width one level up.
  // decided at the block-level grill-me (Payload widths pass (2026-09-25))
  localparam int CCV_W_ACCESS_SIZE = 3;

  // Extra cycles an SPM bank conflict cost, bounded by 32 banks with headroom. A per-lane conflict bitmap belongs in a debug trace, not the datapath.
  // decided at the block-level grill-me (Payload widths pass (2026-09-25))
  localparam int CCV_W_CONFLICT_SER = 6;

  // Retire count since context restore, SATURATING. The progress guard stops caring well before 256, so this is a saturation choice rather than a true maximum.
  // decided at the block-level grill-me (Payload widths pass (2026-09-25))
  localparam int CCV_W_RETIRED_CNT = 8;

  // CSR-programmed policy value. Thresholds are tuning knobs, so they get the full CSR width rather than a tight fit.
  // decided at the block-level grill-me (Payload widths pass (2026-09-25))
  localparam int CCV_W_CSR = 32;

endpackage

// PLACEHOLDERS awaiting a per-block session. A module that
// references this package is KNOWN UNFINISHED -- that is the
// whole reason it is a separate package rather than a comment.
// Everything here is expected to move, and a change should be a
// one-line edit propagating through the generated typedefs, the
// checkers and the C++ model together.
package ccv_prov_pkg;

  // Decode output per cycle. Sized for burst absorption ahead of OOE; expected to move once the timing model produces event traces.
  // PROVISIONAL -- decided by: Stage 4b sweep
  localparam int CCV_DECODE_WIDTH = 6;

  // D-cache lookups per cycle.
  // PROVISIONAL -- decided by: Stage 4b sweep
  localparam int CCV_DCACHE_LOOKUPS = 4;

  // Cycles before the CSR-programmable demotion fallback fires. MLC miss is the primary trigger; this is the backstop.
  // PROVISIONAL -- decided by: Stage 4b sweep
  localparam int CCV_DEMOTION_THRESHOLD = 50;

  // Width of the block clock gate's hysteresis thresholds, which are CSR fields (Q-47): up to 63 cycles. The thresholds are ccv_clk_gate inputs; CCV_CG_HYST_QUIESCE and CCV_CG_HYST_STALL are their reset values.
  // PROVISIONAL -- decided by: the CSR map (Q-47)
  localparam int CCV_CG_HYST_W = 6;

  // Block clock gate (ccv_clk_gate): consecutive quiesced cycles before the gate closes -- the reset value of the block's hysteresis CSR (Q-47). Placeholder. Too short and a block thrashes between sleep and wake on bursty traffic, paying the wake hold each time; too long and it burns clock power idling. A block programs its own through the CSR.
  // PROVISIONAL -- decided by: power analysis, with the first real block
  localparam int CCV_CG_HYST_QUIESCE = 8;

  // Block clock gate: consecutive stalled cycles before the gate closes. Longer than the quiesce hysteresis by default, because a stall usually ends on its own within a few cycles and a stalled block holds work that sleeping only delays. Placeholder, as CCV_CG_HYST_QUIESCE.
  // PROVISIONAL -- decided by: power analysis, with the first real block
  localparam int CCV_CG_HYST_STALL = 16;

  // ROB entries per tier-1 warp. 32, confirmed for the first build by the OOE session.
  // PROVISIONAL -- decided by: OOE per-block session
  localparam int CCV_P_ROB_DEPTH = 32;

  // rob_tag: the tier-1 slot's ROB (2 bits) and the entry index in it (CCV_P_W_ROB_IDX). Carries no age, since the ROB is circular (A-41).  Derived: = clog2(CCV_ROB_INSTANCES) + clog2(CCV_P_ROB_DEPTH).
  // PROVISIONAL -- decided by: OOE per-block session
  localparam int CCV_P_W_ROB_TAG = 7;

  // ROB entry index within one tier-1 warp's ROB: the low part of rob_tag, and the width of a bulk discard's discard_tail (an overlay on displacement[4:0], A-41).  Derived: = clog2(CCV_P_ROB_DEPTH).
  // PROVISIONAL -- decided by: OOE per-block session, with CCV_P_ROB_DEPTH
  localparam int CCV_P_W_ROB_IDX = 5;

  // Branch checkpoints per warp, held in FET: PC-group state saved at each unresolved branch, restored from checkpoint_id plus taken_mask on a mispredict. Fetch stalls a warp when all are in use.
  // PROVISIONAL -- decided by: FET per-block session
  localparam int CCV_P_BR_CKPTS = 4;

  // checkpoint_id, on ccv_fet_dec_instr, ccv_dec_ooe_uop and ccv_ooe_fet_redirect. Provisional rather than settled because it follows CCV_P_BR_CKPTS, and a derived width is never more settled than its inputs (tools/gen-params.py refuses it).  Derived: = clog2(CCV_P_BR_CKPTS).
  // PROVISIONAL -- decided by: FET per-block session, with CCV_P_BR_CKPTS
  localparam int CCV_P_W_CKPT_ID = 2;

  // Reservation-station entries for RCU-class ops (lanes and RCU-executed).
  // PROVISIONAL -- decided by: OOE per-block session
  localparam int CCV_P_RS_RCU = 30;

  // Reservation-station entries for MIU-class ops. With CCV_P_RS_RCU it sizes the wakeup dependency matrix, 45 x 45; each entry tracks up to six producers (A-43).
  // PROVISIONAL -- decided by: OOE per-block session
  localparam int CCV_P_RS_MIU = 15;

  // Decode queue depth ahead of rename.
  // PROVISIONAL -- decided by: OOE per-block session
  localparam int CCV_P_DECQ = 12;

  // GPR rename registers deliberately left unreachable by any warp's ceiling, as margin.
  // PROVISIONAL -- decided by: OOE per-block session
  localparam int CCV_P_REN_SLACK = 16;

  // GPR rename registers guaranteed to each tier-1 slot above its 16 architectural ones, reserved whether the slot is occupied or not: half the fair share of the rename pool. The reservation is what lets restore admission never wait (A-49).  Derived: = (CCV_P_PHYS_REGS - CCV_TIER1_WARPS * CCV_GPRS) // (2 * CCV_TIER1_WARPS).
  // PROVISIONAL -- decided by: OOE per-block session
  localparam int CCV_P_REN_FLOOR = 16;

  // Most GPR rename registers one warp may hold above its architectural ones. Derived so that one warp at its ceiling and the others at their floors fit the pool with CCV_P_REN_SLACK to spare: ceiling + (warps - 1) x floor <= pool - slack.  Derived: = CCV_P_PHYS_REGS - CCV_TIER1_WARPS * CCV_GPRS - (CCV_TIER1_WARPS - 1) * CCV_P_REN_FLOOR - CCV_P_REN_SLACK.  Requires: CCV_P_REN_CEIL >= CCV_P_REN_FLOOR.
  // PROVISIONAL -- decided by: OOE per-block session
  localparam int CCV_P_REN_CEIL = 64;

  // Predicate rename registers left as margin: none. The exact fit is deliberate; the derivation is what absorbs the risk (A-40).
  // PROVISIONAL -- decided by: OOE per-block session
  localparam int CCV_P_PRED_REN_SLACK = 0;

  // Predicate rename registers guaranteed to each tier-1 slot above its 4 architectural ones, on the same rule as the GPR floor (A-39).  Derived: = (CCV_P_PRED_REGS - CCV_TIER1_WARPS * CCV_PREDS) // (2 * CCV_TIER1_WARPS).
  // PROVISIONAL -- decided by: OOE per-block session
  localparam int CCV_P_PRED_REN_FLOOR = 4;

  // Most predicate rename registers one warp may hold above its architectural ones; as CCV_P_REN_CEIL.  Derived: = CCV_P_PRED_REGS - CCV_TIER1_WARPS * CCV_PREDS - (CCV_TIER1_WARPS - 1) * CCV_P_PRED_REN_FLOOR - CCV_P_PRED_REN_SLACK.  Requires: CCV_P_PRED_REN_CEIL >= CCV_P_PRED_REN_FLOOR.
  // PROVISIONAL -- decided by: OOE per-block session
  localparam int CCV_P_PRED_REN_CEIL = 20;

  // Pipeline depth of an RCU-executed op, from RCU accepting the issue to the result in the PRF. An assumption until RCU's session confirms it.
  // PROVISIONAL -- decided by: RCU per-block session
  localparam int CCV_LAT_RCU_BASE = 3;

  // Lane pipeline depth with abutted links, from RCU accepting the issue to the lane result in the PRF. An assumption until LANE's session confirms it as a contract.
  // PROVISIONAL -- decided by: LANE per-block session
  localparam int CCV_LAT_LANE_BASE = 7;

  // L1 hit latency with abutted links, from MIU accepting the memop to its completion and data leaving MIU. An assumption until MIU's session confirms it.
  // PROVISIONAL -- decided by: MIU per-block session
  localparam int CCV_LAT_L1_HIT_BASE = 7;

  // Contracted latency of an RCU-executed op. Crosses no link after acceptance: a dependant's issue crosses the same ccv_ooe_rcu_issue link, so that link cancels out of the schedule.  Derived: = CCV_LAT_RCU_BASE.
  // PROVISIONAL -- decided by: generated
  localparam int CCV_LAT_RCU = 3;

  // Contracted lane latency: base plus the repeater stages out and back, from params/links.json (A-48). The lane channels are lockstep, so every copy has the same stages.  Derived: = CCV_LAT_LANE_BASE + link_n('rcu_lane_ops') + link_n('lane_rcu_res').
  // PROVISIONAL -- decided by: generated
  localparam int CCV_LAT_LANE = 7;

  // Lane-local bypass (A-59): a dependent lane op may issue this many cycles after its producer, measured issue to dependent issue. Producer and dependant execute at the same lane index and both cross ccv_ooe_rcu_issue and ccv_rcu_lane_ops, so the links cancel and none enters it; the floorplan cannot change it. Applies only where the scheduler marks the pair bypassable: dependants of cross-lane ops wake at CCV_LAT_LANE, and which consumers may take the bypass is open (Q-55).
  // PROVISIONAL -- decided by: LANE per-block session
  localparam int CCV_LAT_LANE_BYP = 4;

  // Contracted L1 hit latency, from the cycle MIU holds both the memop and its address from RCU (A-61) to the hit's completion: base plus the MIU-to-DCU stages out and back (A-48). A hit completes on ccv_miu_ooe_cmpl, with its data on ccv_miu_rcu_data, at exactly this cycle; no completion then is the miss indication (A-46).  Derived: = CCV_LAT_L1_HIT_BASE + link_n('miu_dcu_req') + link_n('dcu_miu_rsp').
  // PROVISIONAL -- decided by: generated
  localparam int CCV_LAT_L1_HIT = 7;

  // RCU's time from accepting a memory op's issue to its address operands leaving on ccv_rcu_miu_addr: the PRF read and the output flop. 2 is the accepted starting point (Daniel, 2026-10-03; the OOE session named the parameter, the schema owner proposed the value). Tunable: RCU's session confirms or moves it.
  // PROVISIONAL -- decided by: RCU per-block session
  localparam int CCV_LAT_RCU_ADDR_BASE = 2;

  // RCU's issue-to-address time (A-61). Inside RCU, so no link enters it; the crossings either side are counted where it is used.  Derived: = CCV_LAT_RCU_ADDR_BASE.
  // PROVISIONAL -- decided by: generated
  localparam int CCV_LAT_RCU_ADDR = 2;

  // Issue to the earliest issue of an L1-hit load's dependant (A-57, A-61). MIU starts when it holds both the memop and the address from RCU, the max of the two paths from OOE's issue; the hit's data then crosses to RCU, and the dependant's own issue crosses ccv_ooe_rcu_issue, which is subtracted. When the address path binds, the issue crossing cancels.  Derived: = max(CCV_LAT_HOP + link_n('ooe_miu_memop'), CCV_LAT_HOP + link_n('ooe_rcu_issue') + CCV_LAT_RCU_ADDR + CCV_LAT_HOP + link_n('rcu_miu_addr')) + CCV_LAT_L1_HIT + CCV_LAT_HOP + link_n('miu_rcu_data') - (CCV_LAT_HOP + link_n('ooe_rcu_issue')).
  // PROVISIONAL -- decided by: generated
  localparam int CCV_LAT_L1_WAKE = 13;

  // Issue to OOE holding an L1 hit's completion (A-57, A-61): when OOE learns hit or miss, which sets the cancel shadow. Same start as CCV_LAT_L1_WAKE, then the completion's crossing back to OOE.  Derived: = max(CCV_LAT_HOP + link_n('ooe_miu_memop'), CCV_LAT_HOP + link_n('ooe_rcu_issue') + CCV_LAT_RCU_ADDR + CCV_LAT_HOP + link_n('rcu_miu_addr')) + CCV_LAT_L1_HIT + CCV_LAT_HOP + link_n('miu_ooe_cmpl').
  // PROVISIONAL -- decided by: generated
  localparam int CCV_LAT_L1_CMPL = 15;

  // Physical GPRs: one global pool, allocated by OOE's free lists (RAU allocates none; A-30). Each tier-1 slot, occupied or not, reserves its 16 architectural registers plus CCV_P_REN_FLOOR, so 64 of the 192 are architectural and 128 rename.  Requires: CCV_P_PHYS_REGS > CCV_TIER1_WARPS * CCV_GPRS.
  // PROVISIONAL -- decided by: OOE and RCU per-block sessions
  localparam int CCV_P_PHYS_REGS = 192;

  // Follows CCV_P_PHYS_REGS. One index past the pool is reserved for the hardwired zero register (A-64, A-67), so the width covers CCV_P_PHYS_REGS + 1 entries.  Derived: = clog2(CCV_P_PHYS_REGS + 1).
  // PROVISIONAL -- decided by: OOE and RCU per-block sessions
  localparam int CCV_P_W_PHYS_REG = 8;

  // Physical predicate file depth. The resident warps' architectural predicates alone fill CCV_TIER1_WARPS x 4 = 16 entries, so the file must be deeper or rename has no free register to allocate and the first predicate write never renames (arch open A-21; it was 16). 48 is the GPR file's ratio, 3x architectural (192 against 64), as a placeholder.  Requires: CCV_P_PRED_REGS > CCV_TIER1_WARPS * CCV_PREDS.
  // PROVISIONAL -- decided by: RCU per-block session
  localparam int CCV_P_PRED_REGS = 48;

  // Resident CTAs, bounded by scratchpad allocation.
  // PROVISIONAL -- decided by: RAU per-block session
  localparam int CCV_P_MAX_CTA = 8;

  // Follows CCV_P_MAX_CTA.
  // PROVISIONAL -- decided by: RAU per-block session
  localparam int CCV_P_W_CTA_SLOT = 3;

  // Physical address width at the coherent boundary.
  // PROVISIONAL -- decided by: MLC and EXB per-block sessions
  localparam int CCV_P_W_PA = 48;

  // Cache line size.
  // PROVISIONAL -- decided by: DCU and MLC per-block sessions
  localparam int CCV_P_LINE_BYTES = 128;

  // Widest immediate after format decode. Floor 32, set by identity rather than inherited: OOE substitutes srd #1's %ctaid (CCV_W_CTAID, 32) into this field at issue (Q-38), so it cannot shrink below that.
  // PROVISIONAL -- decided by: DEC per-block session
  localparam int CCV_P_W_IMM = 32;

  // Outstanding-request timeout for local interfaces. Provisional BY CONSTRUCTION: N cannot be justified before contention data exists, so revising it is an expected Stage 4b output rather than a spec change.
  // PROVISIONAL -- decided by: Stage 4b, from contention data
  localparam int CCV_P_TIMEOUT_N = 32;

  // Outstanding-request timeout for the memory path. Must exceed worst-case DRAM latency.
  // PROVISIONAL -- decided by: MLC and EXB per-block sessions
  localparam int CCV_P_TIMEOUT_MEM = 2048;

  // Predicate physical register index, sized by CCV_P_PRED_REGS (it was 8, addressing 256 entries against a 16-deep file). The predicate file is a SEPARATE namespace with its own RAT; sharing CCV_P_W_PHYS_REG would recouple two files that were deliberately split. One index past the pool is reserved for the hardwired zero predicate (A-64, A-67).  Derived: = clog2(CCV_P_PRED_REGS + 1).
  // PROVISIONAL -- decided by: Stage 4a -- OOE rename session sizes the predicate RAT
  localparam int CCV_P_W_PHYS_PRED = 6;

  // The hardwired zero GPR (A-64): the all-ones physical index, outside the pool. It reads zero in every lane and is never written, allocated or freed. At launch OOE maps all 16 architectural GPRs to it, so a launched warp needs no zeroing traffic; a demotion map may name it. Derived from the width, and required outside the pool, so a pool swept to a power of two widens the index instead of colliding with it (A-67).  Derived: = 2 ** CCV_P_W_PHYS_REG - 1.  Requires: CCV_P_PHYS_ZERO >= CCV_P_PHYS_REGS.
  // PROVISIONAL -- decided by: generated
  localparam int CCV_P_PHYS_ZERO = 255;

  // The hardwired zero predicate (A-64): the all-ones predicate index, outside the pool, reading zero and never written. At launch OOE maps all 4 architectural predicates to it (A-67).  Derived: = 2 ** CCV_P_W_PHYS_PRED - 1.  Requires: CCV_P_PRED_ZERO >= CCV_P_PRED_REGS.
  // PROVISIONAL -- decided by: generated
  localparam int CCV_P_PRED_ZERO = 63;

  // Width of sched_attr on ccv_dec_ooe_uop: the scheduling attributes DEC decodes so OOE never decodes opcode (A-66). Layout, MSB first: rs_miu (1: the MIU reservation station), exec_rcu (1: RCU executes it, not a lane), cross_lane (1), writes_gpr (1), writes_pred (1), mem_kind (2: load, store, atomic, fence; meaningful with rs_miu), branch (1), serial (2: none, chwidth, barrier, spare), lat_class (3: 0 RCU, 1 lane, 2 L1-contracted load, 3 on completion, 4-7 spare). mem_kind is don't-care unless rs_miu is set. A prefetch is mem_kind load with writes_gpr 0: it wakes nothing, so its latency class does not matter, and whether it may fault is MIU's semantics (A-68, confirmed 2026-10-03). Each further fixed-latency lane unit (SFU and others) takes a spare lat_class code, 4 to 7, once the LANE session sets its latency, with its own generated wake parameter. Field set the OOE session's, bit order and codes the schema owner's; confirmed 2026-10-03.
  // PROVISIONAL -- decided by: DEC per-block session, with the LANE and RCU op-class list (A-62, A-66)
  localparam int CCV_P_W_SCHED_ATTR = 13;

  // req_id on MIU -> SPM: correlates a response with its request. Per hop, never shared across hops, and not rob_tag (one instruction can be several transactions; FET has no ROB tag). Eight outstanding scratchpad accesses: four slots, two deep.
  // PROVISIONAL -- decided by: the owning block's session, from its outstanding window
  localparam int CCV_P_W_REQ_MIU_SPM = 3;

  // req_id on MIU -> DCU: correlates a response with its request. Per hop, never shared across hops, and not rob_tag (one instruction can be several transactions; FET has no ROB tag). Sixteen outstanding cache accesses: four slots, four deep, since hits and misses return at different times.
  // PROVISIONAL -- decided by: the owning block's session, from its outstanding window
  localparam int CCV_P_W_REQ_MIU_DCU = 4;

  // req_id on DCU -> MLC: correlates a response with its request. Per hop, never shared across hops, and not rob_tag (one instruction can be several transactions; FET has no ROB tag). Sixteen fills in flight, i.e. sixteen MSHRs.
  // PROVISIONAL -- decided by: the owning block's session, from its outstanding window
  localparam int CCV_P_W_REQ_DCU_MLC = 4;

  // req_id on FET -> MLC: correlates a response with its request. Per hop, never shared across hops, and not rob_tag (one instruction can be several transactions; FET has no ROB tag). Four instruction fills in flight.
  // PROVISIONAL -- decided by: the owning block's session, from its outstanding window
  localparam int CCV_P_W_REQ_FET_MLC = 2;

  // req_id on MLC -> EXB: correlates a response with its request. Per hop, never shared across hops, and not rob_tag (one instruction can be several transactions; FET has no ROB tag). The TL-C source-id width the tilelink_tlc sizing assumed (6 bits), so EXB maps it without translation.
  // PROVISIONAL -- decided by: the owning block's session, from its outstanding window
  localparam int CCV_P_W_REQ_MLC_EXB = 6;

  // req_id on MLC -> DCU probe and its acknowledgement: correlates a response with its request. Per hop, never shared across hops, and not rob_tag (one instruction can be several transactions; FET has no ROB tag). Four probes in flight.
  // PROVISIONAL -- decided by: the owning block's session, from its outstanding window
  localparam int CCV_P_W_REQ_MLC_PROBE = 2;

  // Kill epoch, broadcast with kill_valid and echoed on every kill ack, so a late ack from a previous kill cannot satisfy the next one. One bit suffices while RAU has one kill in flight; two leaves room.
  // PROVISIONAL -- decided by: RAU session, from how many kills may overlap
  localparam int CCV_P_W_KILL_EPOCH = 2;

  // Fetch epoch, on ccv_ooe_fet_redirect and on every uop (ccv_fet_dec_instr, ccv_dec_ooe_uop; A-70). OOE advances a warp's epoch on every redirect, demotion and kill, and drops any arriving uop whose epoch is not current. A uop in flight from FET to OOE can see one epoch change per unresolved branch older than it (they resolve out of order, youngest first in the worst case: CCV_P_BR_CKPTS redirects) plus one demotion or kill, so 2^W must exceed CCV_P_BR_CKPTS + 1, or a uop that many epochs stale aliases the current epoch and executes as correct-path. At 2 bits the rule fails.  Derived: = clog2(CCV_P_BR_CKPTS + 2).  Requires: 2 ** CCV_P_W_FETCH_EPOCH > CCV_P_BR_CKPTS + 1.
  // PROVISIONAL -- decided by: generated
  localparam int CCV_P_W_FETCH_EPOCH = 3;

endpackage

// PRELIMINARY -- a width good enough to WIRE, for a field whose
// encoding is not decided at all. Referencing this package says
// more than that a number will move: the field's SHAPE may move,
// so code that pattern-matches on its contents is code that will
// be rewritten. The churn rating on each says how much.
//
// This tier exists so the skeleton can be wired end to end
// without anyone having to pretend the encodings are known.
package ccv_prelim_pkg;

  // Eight uop classes: integer, float, SFU and convert, memory, control, collective, predicate, spare. DEC decides whether class is derivable from opcode at all.
  // PRELIMINARY -- churn: LOW
  localparam int CCV_L_W_CLASS = 3;

  // One encoding across all three hops, owned by the schema (Q-34): a block may narrow it locally only as a strict projection, never a re-encoding. Narrowing at RCU->LANE is likely, but the ISA opcode census sets it. Anything decoding this field will be rewritten.
  // PRELIMINARY -- churn: HIGH  (the FIELD may change shape, not just this number)
  localparam int CCV_L_W_OPCODE = 9;

  // The copy-only op's opcode on ccv_ooe_rcu_issue and ccv_rcu_lane_ops: the all-ones code, which no ISA opcode takes. A masked load issues it beside the load, with the load's rob_tag and destinations and the old destination as merge_data: a lane returns merge_data on its inactive lanes, RCU writes only those, and no done comes back -- the load keeps one completion, its own (A-38). OOE clears the load's copy-pending at issue + CCV_LAT_LANE, as for any lane op; RCU owes the PRF write within CCV_LAT_LANE of accepting it.  Derived: = 2 ** CCV_L_W_OPCODE - 1.
  // PRELIMINARY -- churn: LOW
  localparam int CCV_OP_PRF_COPY = 511;

  // Architectural memory operation: load, store, atomic family, prefetch, fence. Decoded by DEC and passed through OOE (A-68). Code 0xF is reserved for OOE's bulk discard (A-41): DEC never emits it.
  // PRELIMINARY -- churn: MED
  localparam int CCV_L_W_MEM_OP = 4;

  // Scratchpad bank access: read, write, and room for a read-modify variant.
  // PRELIMINARY -- churn: LOW
  localparam int CCV_L_W_SPM_OP = 2;

  // Coherent line request: acquire, release, probe response, writeback, grant acknowledgement. Follows the TL-C subset chosen.
  // PRELIMINARY -- churn: MED
  localparam int CCV_L_W_COH_OP = 4;

  // Kind of inbound message on ccv_exb_mlc_rsp: 0 = a response to a request; otherwise a probe and what it asks (to-invalid, to-branch, to-trunk, after TL-C Probe param). Replaces the one-bit inbound_probe flag.
  // PRELIMINARY -- churn: MED
  localparam int CCV_L_W_PROBE_TYPE = 2;

  // Grid selector on the host's kill request (ccv_cru_rau_cfg). RAU maps grid to warp mask from tables it owns. Sized for 256 grid slots; the real number is how many grids RAU tracks at once.
  // PRELIMINARY -- churn: MED
  localparam int CCV_L_W_GRID_SEL = 8;

  // TL-C permission levels plus an explicit dirty bit, kept wider than TL-C needs so a CHI bridge maps without a second translation.
  // PRELIMINARY -- churn: MED
  localparam int CCV_L_W_OWNERSHIP = 3;

  // Memory space: global, shared, const, local, with spare codes.
  // PRELIMINARY -- churn: LOW
  localparam int CCV_L_W_SPACE = 3;

  // Two bits of order and two of scope. Whether scope is a separate field is the open part.
  // PRELIMINARY -- churn: MED
  localparam int CCV_L_W_ORDERING = 4;

  // ITLB entry: physical page number, permissions, ASID and valid, rounded up.
  // PRELIMINARY -- churn: LOW
  localparam int CCV_L_W_ITLB_ENTRY = 64;

  // Parked-context bank select: eight banks of four warps, from the proposed PCA organization.
  // PRELIMINARY -- churn: MED
  localparam int CCV_L_W_PCA_BANK = 3;

  // Operands shipped to a lane per beat. Whether a lane receives one instruction's operands or several, and whether the destination is read back for accumulate, both change this.
  // PRELIMINARY -- churn: HIGH  (the FIELD may change shape, not just this number)
  localparam int CCV_L_OPERANDS_PER_LANE = 3;

  // PCs carried in one migration, one per PC group. The real count depends on the divergence representation, which is unspecified.
  // PRELIMINARY -- churn: HIGH  (the FIELD may change shape, not just this number)
  localparam int CCV_L_PC_GROUPS = 4;

  // Barrier entries in an allocated range. 7 bits expresses 1..64; 6 would do with a bias. Not stated by the payload pass, so the biasing choice is still open.
  // PRELIMINARY -- churn: LOW
  localparam int CCV_L_W_BAR_COUNT = 7;

  // Page shift, used to express code bounds at page granularity. 4 KB pages assumed; the MMU session confirms.
  // PRELIMINARY -- churn: LOW
  localparam int CCV_L_PAGE_SHIFT = 12;

  // TL-C outbound, A + C + E plus a valid bit per TL channel, at 512-bit beat, 48-bit address, 6-bit source, 4-bit sink: A 641 (opcode 3, param 3, size 4, source 6, address 48, mask 64, data 512, corrupt 1), C 577 (A without mask), E 4 (sink), valids 3.
  // PRELIMINARY -- churn: HIGH  (the FIELD may change shape, not just this number)
  localparam int CCV_L_W_TL_OUT = 1225;

  // TL-C inbound, B + D plus a valid bit per TL channel: B 641 (as A), D 533 (opcode 3, param 2, size 4, source 6, sink 4, denied 1, data 512, corrupt 1), valids 2. The earlier single 1760 reproduces exactly as A + C + D + E + 5 valids -- it never included B, the probe.
  // PRELIMINARY -- churn: HIGH  (the FIELD may change shape, not just this number)
  localparam int CCV_L_W_TL_IN = 1176;

  // CSR address. A first guess, made only so the common CSR port can be declared: the schema gave csr_req as 'address, write data, write enable' with no widths, and there is no CSR map yet.
  // PRELIMINARY -- churn: MED
  localparam int CCV_L_W_CSR_ADDR = 16;

endpackage

/* verilator lint_on UNUSEDPARAM */
`endif // CCV_PARAMS_PKG_SV
