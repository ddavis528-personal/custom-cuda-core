// GENERATED FILE -- DO NOT EDIT.
//
// Produced by tools/gen-params.py from params/ccv_params.json.
// Edit the source and regenerate; tools/verify.sh fails if this file is stale.

#ifndef CCV_PARAMS_H
#define CCV_PARAMS_H

#include <cstdint>

namespace ccv {

/// Values that follow from decisions already made.

/// Lanes per warp. A logical GPR holds 32 lanes, one element each, at every chwidth.
/// settled by the ISA -- not a knob (ISA v1.6 §1 -- warp width, settled)
static constexpr uint32_t kWarpLanes = 32;

/// Architectural GPRs. 16 x 1024 bit = 2 KB per warp.
/// settled by the ISA -- not a knob (ISA v1.6 §1, O-25)
static constexpr uint32_t kGprs = 16;

/// Logical predicates. A performance parameter, not a structural ceiling.
/// ISA-level, still provisional (ISA v1.6 §1 -- provisional pending compiler data; measured pressure 1-2 of 4)
static constexpr uint32_t kPreds = 4;

/// Global address width.
/// settled by the ISA -- not a knob (ISA v1.6 §1)
static constexpr uint32_t kAddrBits = 48;

/// Physical datapath width.
/// settled by the ISA -- not a knob (ISA v1.6 §1 -- 32 lanes x 32 bits)
static constexpr uint32_t kDatapathBits = 1024;

/// Tier-1 resident warps, SMT-4 equivalent. Four slots covering a DRAM latency near 1000 cycles requires that demotion happen only on TRUE misses -- demoting on short stalls would need roughly 84 warps to keep 4 slots busy.
/// decided at the block-level grill-me (grill-me 2026-09-23)
static constexpr uint32_t kTier1Warps = 4;

/// Warps parked in PCA. 32 total contexts.
/// decided at the block-level grill-me (grill-me 2026-09-23)
static constexpr uint32_t kParkedWarps = 28;

/// Instructions fetched per warp per cycle, all 4 tier-1 warps in parallel.
/// decided at the block-level grill-me (grill-me 2026-09-23)
static constexpr uint32_t kFetchPerWarp = 2;

/// Rename and issue width. The binding width of the machine.
/// decided at the block-level grill-me (grill-me 2026-09-23)
static constexpr uint32_t kIssueWidth = 4;

/// One ROB per tier-1 warp.
/// decided at the block-level grill-me (grill-me 2026-09-23)
static constexpr uint32_t kRobInstances = 4;

/// Retire per ROB per cycle. 8 peak against 4-wide issue.
/// decided at the block-level grill-me (grill-me 2026-09-23)
static constexpr uint32_t kRetirePerRob = 2;

/// Address generation pipes in MIU, sized for 8-bit coalescing.
/// decided at the block-level grill-me (grill-me 2026-09-23)
static constexpr uint32_t kAguPipes = 4;

/// TLB translations per cycle on the hit path, no page split.
/// decided at the block-level grill-me (grill-me 2026-09-23)
static constexpr uint32_t kTlbXlatPerCycle = 4;

/// Scratchpad capacity, 128 KB.
/// decided at the block-level grill-me (grill-me 2026-09-23)
static constexpr uint32_t kSpmBytes = 131072;

/// Scratchpad banks, 32 x 32 bits. Bank conflicts are a first-order GEMM effect, which is why the scratchpad is a design block rather than testbench.
/// decided at the block-level grill-me (grill-me 2026-09-23)
static constexpr uint32_t kSpmBanks = 32;

/// Barrier table entries, 4 x 16, epoch-tagged. A §7 formal target.
/// settled by the ISA -- not a knob (ISA v1.6 §3, Format E -- 6-bit barrier ID)
static constexpr uint32_t kBarrierEntries = 64;

/// Up to 4 cores per MLC. Present from day one rather than added when a second core appears, because adding a struct field later regenerates every typedef, header, harness and checker at that boundary.
/// decided at the block-level grill-me (grill-me 2026-09-23)
static constexpr uint32_t kCoreIdBits = 2;

/// Migration transfer, 2 KB at 1024 bits, each way. At one swap per ~125 cycles this uses the single migration path at about 25 percent.
/// decided at the block-level grill-me (grill-me 2026-09-23)
static constexpr uint32_t kMigrationCycles = 16;

/// Normalized gate delay in one cycle. OPEN (§2): whether 25 is the Vmin-corner number or a nominal one. Per-INTERFACE-PATH budgets are assigned once contracts are drawn, not per block.
/// physical target, not a structure size (§2 -- ~1.5 GHz at Vmin 0.55 V on an N3E-class process)
static constexpr uint32_t kNgdBudget = 25;

/// Warp id. 32 total warp contexts.
/// decided at the block-level grill-me (ports spec 2026-09-23)
static constexpr uint32_t kWWarpId = 5;

/// Tier-1 slot, which also selects the ROB instance.
/// decided at the block-level grill-me (ports spec 2026-09-23)
static constexpr uint32_t kWTier1Id = 2;

/// Architectural GPR index. 16 GPRs (ISA v1.6 §1).
/// settled by the ISA -- not a knob (ports spec 2026-09-23)
static constexpr uint32_t kWArchReg = 4;

/// Architectural predicate index. 4 predicates (ISA v1.6 §1). A separate namespace from the GPRs, with its own RAT and count, even while the width happens to be smaller.
/// settled by the ISA -- not a knob (Payload spec response (2026-09-25))
static constexpr uint32_t kWArchPred = 2;

/// Memory displacement, sign-extended at the AGU. The widest memory-format offset is cas's 16-bit signed field (ISA v1.6 §3); Format D's simm13, D-prime's simm10, the atomics' simm9 and base+index's simm8 all fit. (The compiler had declared cas's offset uimm16, which would have needed 17: compiler F-143, fixed.)
/// settled by the ISA -- not a knob (Skeleton review response (2026-09-25))
static constexpr uint32_t kWDisp = 16;

/// srd #1's %ctaid, the flat CTA index within the grid (ISA v1.6 §5.3). Dispatch state, held by RAU and shadowed in OOE, which substitutes it into srd's immediate at issue. It exactly fills CCV_P_W_IMM, so it sets that parameter's floor.
/// settled by the ISA -- not a knob (srd response (2026-09-25), Q-38)
static constexpr uint32_t kWCtaid = 32;

/// A warp's index within its CTA. %ctatid is 10 bits (ISA v1.6 §5.3) and a warp is 32 lanes, so 5. srd #0's warp_base = warp_in_cta << 5 has its low five bits zero, so the lane ORs its hardwired index in without an adder.
/// settled by the ISA -- not a knob (srd response (2026-09-25), Q-38)
static constexpr uint32_t kWWarpInCta = 5;

/// One bit per lane.
/// settled by the ISA -- not a knob (ports spec 2026-09-23)
static constexpr uint32_t kWLaneMask = 32;

/// Full datapath, 32 lanes x 32 bits.
/// settled by the ISA -- not a knob (ports spec 2026-09-23)
static constexpr uint32_t kWData = 1024;

/// Lane datapath.
/// settled by the ISA -- not a knob (ports spec 2026-09-23)
static constexpr uint32_t kWLaneData = 32;

/// Element width code: 32, 16, 8, 4.
/// settled by the ISA -- not a knob (ports spec 2026-09-23)
static constexpr uint32_t kWChwidth = 2;

/// Up to 4 cores per MLC.
/// decided at the block-level grill-me (ports spec 2026-09-23)
static constexpr uint32_t kWCoreId = 2;

/// Longest instruction form (ISA v1.6: 16/32/48).
/// settled by the ISA -- not a knob (ports spec 2026-09-23)
static constexpr uint32_t kWInstr = 48;

/// Instruction length code: three lengths.
/// settled by the ISA -- not a knob (ports spec 2026-09-23)
static constexpr uint32_t kWIlen = 2;

/// Address generation is 64-bit, though the ISA's architectural address is 48.
/// decided at the block-level grill-me (ports spec 2026-09-23)
static constexpr uint32_t kWVa = 64;

/// 128 KB scratchpad.
/// decided at the block-level grill-me (ports spec 2026-09-23)
static constexpr uint32_t kWSpmAddr = 17;

/// 32 banks.
/// decided at the block-level grill-me (ports spec 2026-09-23)
static constexpr uint32_t kWSpmBank = 5;

/// 4 KB per bank, 32-bit words.
/// decided at the block-level grill-me (ports spec 2026-09-23)
static constexpr uint32_t kWSpmWord = 10;

/// 64 barrier entries.
/// decided at the block-level grill-me (ports spec 2026-09-23)
static constexpr uint32_t kWBarEntry = 6;

/// 16 barriers per CTA.
/// decided at the block-level grill-me (ports spec 2026-09-23)
static constexpr uint32_t kWBarId = 4;

/// Fault-model cause set, with headroom.
/// decided at the block-level grill-me (ports spec 2026-09-23)
static constexpr uint32_t kWFaultCause = 4;

/// Flop-to-flop round trip, abutting. TWO EVERYWHERE BY CONSTRUCTION -- flops on both sides with no exceptions, plus abutment, gives exactly this. It is not a per-interface choice, and the three values below are not independent numbers but the same number under different names. Only a non-abutting interface would differ, and none is known to be until floorplan.
/// decided at the block-level grill-me (ports spec 2026-09-23)
static constexpr uint32_t kRtAbut = 2;

/// Credits held by a sender: equals the round trip, so abutting blocks are never throttled at steady state.
/// decided at the block-level grill-me (ports spec 2026-09-23)
static constexpr uint32_t kCreditDepth = 2;

/// Storage a stalling receiver reserves to catch everything already in flight. Equals the round trip: no unwinding, no negative acknowledgement.
/// decided at the block-level grill-me (ports spec 2026-09-23)
static constexpr uint32_t kRescueDepth = 2;

/// Cycles to wait after asserting stall before nothing is in flight. Equals the round trip, which is what lets sleep entry, chwidth change and demotion share one mechanism and one proof.
/// decided at the block-level grill-me (ports spec 2026-09-23)
static constexpr uint32_t kDrainWait = 2;

/// Wake latency: round trip plus 2.
/// decided at the block-level grill-me (ports spec 2026-09-23)
static constexpr uint32_t kWakeLat = 4;

/// Address-space id. 256 address spaces before a rollover forces a flush; with one resident context it exists to make switches cheap.
/// decided at the block-level grill-me (Payload widths pass (2026-09-25))
static constexpr uint32_t kWAsid = 8;

/// Memory completion status: complete, replay, fault. `cause` carries the detail, so this stays at exactly the three outcomes.
/// decided at the block-level grill-me (Payload widths pass (2026-09-25))
static constexpr uint32_t kWStatus = 2;

/// Cache access size as a CODE -- powers of two up to a line -- not a byte count. Distinct from CCV_W_CHWIDTH, which is the architectural element width one level up.
/// decided at the block-level grill-me (Payload widths pass (2026-09-25))
static constexpr uint32_t kWAccessSize = 3;

/// Extra cycles an SPM bank conflict cost, bounded by 32 banks with headroom. A per-lane conflict bitmap belongs in a debug trace, not the datapath.
/// decided at the block-level grill-me (Payload widths pass (2026-09-25))
static constexpr uint32_t kWConflictSer = 6;

/// Retire count since context restore, SATURATING. The progress guard stops caring well before 256, so this is a saturation choice rather than a true maximum.
/// decided at the block-level grill-me (Payload widths pass (2026-09-25))
static constexpr uint32_t kWRetiredCnt = 8;

/// CSR-programmed policy value. Thresholds are tuning knobs, so they get the full CSR width rather than a tight fit.
/// decided at the block-level grill-me (Payload widths pass (2026-09-25))
static constexpr uint32_t kWCsr = 32;

/// PLACEHOLDERS awaiting a per-block session. Code referencing
/// ccv::prov is KNOWN UNFINISHED; the nested namespace is what
/// keeps that visible at the use site.
namespace prov {

/// Decode output per cycle. Sized for burst absorption ahead of OOE; expected to move once the timing model produces event traces.
/// PROVISIONAL -- decided by: Stage 4b sweep
static constexpr uint32_t kDecodeWidth = 6;

/// D-cache lookups per cycle.
/// PROVISIONAL -- decided by: Stage 4b sweep
static constexpr uint32_t kDcacheLookups = 4;

/// Cycles before the CSR-programmable demotion fallback fires. MLC miss is the primary trigger; this is the backstop.
/// PROVISIONAL -- decided by: Stage 4b sweep
static constexpr uint32_t kDemotionThreshold = 50;

/// ROB sizing against 4-wide issue.
/// PROVISIONAL -- decided by: OOE per-block session
static constexpr uint32_t kRobDepth = 32;

/// Tier-1 id plus ROB depth.
/// PROVISIONAL -- decided by: OOE per-block session
static constexpr uint32_t kWRobTag = 7;

/// Rename headroom above 16 arch regs per tier-1 warp.
/// PROVISIONAL -- decided by: OOE and RCU per-block sessions
static constexpr uint32_t kPhysRegs = 192;

/// Follows CCV_P_PHYS_REGS.
/// PROVISIONAL -- decided by: OOE and RCU per-block sessions
static constexpr uint32_t kWPhysReg = 8;

/// Predicate file depth.
/// PROVISIONAL -- decided by: RCU per-block session
static constexpr uint32_t kPredRegs = 16;

/// Resident CTAs, bounded by scratchpad allocation.
/// PROVISIONAL -- decided by: RAU per-block session
static constexpr uint32_t kMaxCta = 8;

/// Follows CCV_P_MAX_CTA.
/// PROVISIONAL -- decided by: RAU per-block session
static constexpr uint32_t kWCtaSlot = 3;

/// Physical address width at the coherent boundary.
/// PROVISIONAL -- decided by: MLC and EXB per-block sessions
static constexpr uint32_t kWPa = 48;

/// Cache line size.
/// PROVISIONAL -- decided by: DCU and MLC per-block sessions
static constexpr uint32_t kLineBytes = 128;

/// Widest immediate after format decode. Floor 32, set by identity rather than inherited: OOE substitutes srd #1's %ctaid (CCV_W_CTAID, 32) into this field at issue (Q-38), so it cannot shrink below that.
/// PROVISIONAL -- decided by: DEC per-block session
static constexpr uint32_t kWImm = 32;

/// Outstanding-request timeout for local interfaces. Provisional BY CONSTRUCTION: N cannot be justified before contention data exists, so revising it is an expected Stage 4b output rather than a spec change.
/// PROVISIONAL -- decided by: Stage 4b, from contention data
static constexpr uint32_t kTimeoutN = 32;

/// Outstanding-request timeout for the memory path. Must exceed worst-case DRAM latency.
/// PROVISIONAL -- decided by: MLC and EXB per-block sessions
static constexpr uint32_t kTimeoutMem = 2048;

/// Predicate physical register index. The predicate file is a SEPARATE namespace with its own RAT; sharing CCV_P_W_PHYS_REG would recouple two files that were deliberately split.
/// PROVISIONAL -- decided by: Stage 4a -- OOE rename session sizes the predicate RAT
static constexpr uint32_t kWPhysPred = 8;

/// req_id on MIU -> SPM: correlates a response with its request. Per hop, never shared across hops, and not rob_tag (one instruction can be several transactions; FET has no ROB tag). Eight outstanding scratchpad accesses: four slots, two deep.
/// PROVISIONAL -- decided by: the owning block's session, from its outstanding window
static constexpr uint32_t kWReqMiuSpm = 3;

/// req_id on MIU -> DCU: correlates a response with its request. Per hop, never shared across hops, and not rob_tag (one instruction can be several transactions; FET has no ROB tag). Sixteen outstanding cache accesses: four slots, four deep, since hits and misses return at different times.
/// PROVISIONAL -- decided by: the owning block's session, from its outstanding window
static constexpr uint32_t kWReqMiuDcu = 4;

/// req_id on DCU -> MLC: correlates a response with its request. Per hop, never shared across hops, and not rob_tag (one instruction can be several transactions; FET has no ROB tag). Sixteen fills in flight, i.e. sixteen MSHRs.
/// PROVISIONAL -- decided by: the owning block's session, from its outstanding window
static constexpr uint32_t kWReqDcuMlc = 4;

/// req_id on FET -> MLC: correlates a response with its request. Per hop, never shared across hops, and not rob_tag (one instruction can be several transactions; FET has no ROB tag). Four instruction fills in flight.
/// PROVISIONAL -- decided by: the owning block's session, from its outstanding window
static constexpr uint32_t kWReqFetMlc = 2;

/// req_id on MLC -> EXB: correlates a response with its request. Per hop, never shared across hops, and not rob_tag (one instruction can be several transactions; FET has no ROB tag). The TL-C source-id width the tilelink_tlc sizing assumed (6 bits), so EXB maps it without translation.
/// PROVISIONAL -- decided by: the owning block's session, from its outstanding window
static constexpr uint32_t kWReqMlcExb = 6;

/// req_id on MLC -> DCU probe and its acknowledgement: correlates a response with its request. Per hop, never shared across hops, and not rob_tag (one instruction can be several transactions; FET has no ROB tag). Four probes in flight.
/// PROVISIONAL -- decided by: the owning block's session, from its outstanding window
static constexpr uint32_t kWReqMlcProbe = 2;

/// Kill epoch, broadcast with kill_valid and echoed on every kill ack, so a late ack from a previous kill cannot satisfy the next one. One bit suffices while RAU has one kill in flight; two leaves room.
/// PROVISIONAL -- decided by: RAU session, from how many kills may overlap
static constexpr uint32_t kWKillEpoch = 2;

/// Fetch epoch on ccv_ooe_fet_redirect: FET bumps it on a redirect and discards in-flight fetches from the wrong path by epoch.
/// PROVISIONAL -- decided by: FET session, from fetch pipeline depth
static constexpr uint32_t kWFetchEpoch = 2;

} // namespace prov

/// PRELIMINARY -- the field's ENCODING is undecided, not merely
/// its size. Code referencing ccv::prelim that pattern-matches on
/// a value, rather than just carrying it, is code that will be
/// rewritten. The churn rating on each says how much.
namespace prelim {

/// Eight uop classes: integer, float, SFU and convert, memory, control, collective, predicate, spare. DEC decides whether class is derivable from opcode at all.
/// PRELIMINARY -- churn: LOW
static constexpr uint32_t kWClass = 3;

/// One encoding across all three hops, owned by the schema (Q-34): a block may narrow it locally only as a strict projection, never a re-encoding. Narrowing at RCU->LANE is likely, but the ISA opcode census sets it. Anything decoding this field will be rewritten.
/// PRELIMINARY -- churn: HIGH
static constexpr uint32_t kWOpcode = 9;

/// Architectural memory operation: load, store, atomic family, prefetch, fence.
/// PRELIMINARY -- churn: MED
static constexpr uint32_t kWMemOp = 4;

/// Scratchpad bank access: read, write, and room for a read-modify variant.
/// PRELIMINARY -- churn: LOW
static constexpr uint32_t kWSpmOp = 2;

/// Coherent line request: acquire, release, probe response, writeback, grant acknowledgement. Follows the TL-C subset chosen.
/// PRELIMINARY -- churn: MED
static constexpr uint32_t kWCohOp = 4;

/// Kind of inbound message on ccv_exb_mlc_rsp: 0 = a response to a request; otherwise a probe and what it asks (to-invalid, to-branch, to-trunk, after TL-C Probe param). Replaces the one-bit inbound_probe flag.
/// PRELIMINARY -- churn: MED
static constexpr uint32_t kWProbeType = 2;

/// Grid selector on the host's kill request (ccv_cru_rau_cfg). RAU maps grid to warp mask from tables it owns. Sized for 256 grid slots; the real number is how many grids RAU tracks at once.
/// PRELIMINARY -- churn: MED
static constexpr uint32_t kWGridSel = 8;

/// TL-C permission levels plus an explicit dirty bit, kept wider than TL-C needs so a CHI bridge maps without a second translation.
/// PRELIMINARY -- churn: MED
static constexpr uint32_t kWOwnership = 3;

/// Memory space: global, shared, const, local, with spare codes.
/// PRELIMINARY -- churn: LOW
static constexpr uint32_t kWSpace = 3;

/// Two bits of order and two of scope. Whether scope is a separate field is the open part.
/// PRELIMINARY -- churn: MED
static constexpr uint32_t kWOrdering = 4;

/// ITLB entry: physical page number, permissions, ASID and valid, rounded up.
/// PRELIMINARY -- churn: LOW
static constexpr uint32_t kWItlbEntry = 64;

/// Physical register window base, at REGISTER granularity. Chunked allocation would narrow this and prf_size together -- one decision for the pair.
/// PRELIMINARY -- churn: MED
static constexpr uint32_t kWPrfBase = 8;

/// Physical register window size. Same granularity decision as CCV_L_W_PRF_BASE.
/// PRELIMINARY -- churn: MED
static constexpr uint32_t kWPrfSize = 8;

/// Parked-context bank select: eight banks of four warps, from the proposed PCA organization.
/// PRELIMINARY -- churn: MED
static constexpr uint32_t kWPcaBank = 3;

/// Operands shipped to a lane per beat. Whether a lane receives one instruction's operands or several, and whether the destination is read back for accumulate, both change this.
/// PRELIMINARY -- churn: HIGH
static constexpr uint32_t kOperandsPerLane = 3;

/// PCs carried in one migration, one per PC group. The real count depends on the divergence representation, which is unspecified.
/// PRELIMINARY -- churn: HIGH
static constexpr uint32_t kPcGroups = 4;

/// Predicate registers plus a reconvergence stack of eight entries of mask and PC. THE most likely field to be underestimated: the divergence model is stored here and has never been specified.
/// PRELIMINARY -- churn: HIGH
static constexpr uint32_t kWPredState = 1024;

/// Barrier entries in an allocated range. 7 bits expresses 1..64; 6 would do with a bias. Not stated by the payload pass, so the biasing choice is still open.
/// PRELIMINARY -- churn: LOW
static constexpr uint32_t kWBarCount = 7;

/// Page shift, used to express code bounds at page granularity. 4 KB pages assumed; the MMU session confirms.
/// PRELIMINARY -- churn: LOW
static constexpr uint32_t kPageShift = 12;

/// TL-C outbound, A + C + E plus a valid bit per TL channel, at 512-bit beat, 48-bit address, 6-bit source, 4-bit sink: A 641 (opcode 3, param 3, size 4, source 6, address 48, mask 64, data 512, corrupt 1), C 577 (A without mask), E 4 (sink), valids 3.
/// PRELIMINARY -- churn: HIGH
static constexpr uint32_t kWTlOut = 1225;

/// TL-C inbound, B + D plus a valid bit per TL channel: B 641 (as A), D 533 (opcode 3, param 2, size 4, source 6, sink 4, denied 1, data 512, corrupt 1), valids 2. The earlier single 1760 reproduces exactly as A + C + D + E + 5 valids -- it never included B, the probe.
/// PRELIMINARY -- churn: HIGH
static constexpr uint32_t kWTlIn = 1176;

/// CSR address. A first guess, made only so the common CSR port can be declared: the schema gave csr_req as 'address, write data, write enable' with no widths, and there is no CSR map yet.
/// PRELIMINARY -- churn: MED
static constexpr uint32_t kWCsrAddr = 16;

} // namespace prelim

} // namespace ccv
#endif // CCV_PARAMS_H
