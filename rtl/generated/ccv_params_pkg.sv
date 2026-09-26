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

  // Migration transfer, 2 KB at 1024 bits, each way. At one swap per ~125 cycles this uses the single migration path at about 25 percent.
  // decided at the block-level grill-me (grill-me 2026-09-23)
  localparam int CCV_MIGRATION_CYCLES = 16;

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

  // Credits held by a sender: equals the round trip, so abutting blocks are never throttled at steady state.
  // decided at the block-level grill-me (ports spec 2026-09-23)
  localparam int CCV_CREDIT_DEPTH = 2;

  // Storage a stalling receiver reserves to catch everything already in flight. Equals the round trip: no unwinding, no negative acknowledgement.
  // decided at the block-level grill-me (ports spec 2026-09-23)
  localparam int CCV_RESCUE_DEPTH = 2;

  // Cycles to wait after asserting stall before nothing is in flight. Equals the round trip, which is what lets sleep entry, chwidth change and demotion share one mechanism and one proof.
  // decided at the block-level grill-me (ports spec 2026-09-23)
  localparam int CCV_DRAIN_WAIT = 2;

  // Wake latency: round trip plus 2.
  // decided at the block-level grill-me (ports spec 2026-09-23)
  localparam int CCV_WAKE_LAT = 4;

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

  // ROB sizing against 4-wide issue.
  // PROVISIONAL -- decided by: OOE per-block session
  localparam int CCV_P_ROB_DEPTH = 32;

  // Tier-1 id plus ROB depth.
  // PROVISIONAL -- decided by: OOE per-block session
  localparam int CCV_P_W_ROB_TAG = 7;

  // Rename headroom above 16 arch regs per tier-1 warp.
  // PROVISIONAL -- decided by: OOE and RCU per-block sessions
  localparam int CCV_P_PHYS_REGS = 192;

  // Follows CCV_P_PHYS_REGS.
  // PROVISIONAL -- decided by: OOE and RCU per-block sessions
  localparam int CCV_P_W_PHYS_REG = 8;

  // Predicate file depth.
  // PROVISIONAL -- decided by: RCU per-block session
  localparam int CCV_P_PRED_REGS = 16;

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

  // Predicate physical register index. The predicate file is a SEPARATE namespace with its own RAT; sharing CCV_P_W_PHYS_REG would recouple two files that were deliberately split.
  // PROVISIONAL -- decided by: Stage 4a -- OOE rename session sizes the predicate RAT
  localparam int CCV_P_W_PHYS_PRED = 8;

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

  // Fetch epoch on ccv_ooe_fet_redirect: FET bumps it on a redirect and discards in-flight fetches from the wrong path by epoch.
  // PROVISIONAL -- decided by: FET session, from fetch pipeline depth
  localparam int CCV_P_W_FETCH_EPOCH = 2;

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

  // Architectural memory operation: load, store, atomic family, prefetch, fence.
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

  // Physical register window base, at REGISTER granularity. Chunked allocation would narrow this and prf_size together -- one decision for the pair.
  // PRELIMINARY -- churn: MED
  localparam int CCV_L_W_PRF_BASE = 8;

  // Physical register window size. Same granularity decision as CCV_L_W_PRF_BASE.
  // PRELIMINARY -- churn: MED
  localparam int CCV_L_W_PRF_SIZE = 8;

  // Parked-context bank select: eight banks of four warps, from the proposed PCA organization.
  // PRELIMINARY -- churn: MED
  localparam int CCV_L_W_PCA_BANK = 3;

  // Operands shipped to a lane per beat. Whether a lane receives one instruction's operands or several, and whether the destination is read back for accumulate, both change this.
  // PRELIMINARY -- churn: HIGH  (the FIELD may change shape, not just this number)
  localparam int CCV_L_OPERANDS_PER_LANE = 3;

  // PCs carried in one migration, one per PC group. The real count depends on the divergence representation, which is unspecified.
  // PRELIMINARY -- churn: HIGH  (the FIELD may change shape, not just this number)
  localparam int CCV_L_PC_GROUPS = 4;

  // Predicate registers plus a reconvergence stack of eight entries of mask and PC. THE most likely field to be underestimated: the divergence model is stored here and has never been specified.
  // PRELIMINARY -- churn: HIGH  (the FIELD may change shape, not just this number)
  localparam int CCV_L_W_PRED_STATE = 1024;

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
