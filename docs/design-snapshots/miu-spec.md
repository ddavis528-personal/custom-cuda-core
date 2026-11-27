<!-- design-snapshot url=https://claude.ai/artifact/DJeg9Hh8rkPDecq4hrAz35 tab=MIU rev=226 exported=2026-11-24 status=living -->
> **Snapshot: do not edit.** Exported from *CCV per-block architecture specs*, tab *MIU*, at revision 226 on 2026-11-24 ([live doc](https://claude.ai/artifact/DJeg9Hh8rkPDecq4hrAz35)). The live doc is the source; it is a living document, so this copy is refreshed whenever it changes. This copy pins what the repo was built against; see [README.md](README.md).

# MIU — memory interface unit

**Owner: MA** (MIU and DCU architecture), from 2026-11-10, at Daniel's request (register, DA tab); MI implements the MIU from MA's handoff when the architecture is ready (DA tab, 2026-11-10, second row). AR wrote this tab until then; from MA's first edit, only MA edits it, and AR sends cross-block text as a row with MA in Needs. MA's handoff is `docs/miu-arch.md` in custom-cuda-core, whose section 5 listed what was stale against the schema; MA's Phase 0 (2026-11-13) reconciled it, and this tab is current as of 2026-11-15.

Block M, `ccv_miu`, one instance. Four address-generation pipes, the load and store buffers, disambiguation, the TLB and its walker, and every execute-stage memory fault.

## Scope and ports

**Owns:** four AGU pipes, the coalescer, load and store buffers, disambiguation, the TLB and page-table walker, exclusive-ownership requests for atomics, the scratchpad bounds check, and every execute-stage memory fault.

**Does not own:** the cache or scratchpad arrays, and no architectural register state. It holds transactions, not values.

| In | From | Rate |
| --- | --- | --- |
| `ccv_ooe_miu_memop` | OOE — op (or the bulk-discard command), space, ordering, `disp`, `issue_mask`, `phys_dst` | 4 |
| `ccv_rcu_miu_addr` | RCU — base, per-lane index, store data, `active_mask` | 4 |
| `ccv_ooe_miu_retire` | OOE — commit or discard | 4 |
| `ccv_spm_miu_rsp` | SPM | 4 |
| `ccv_dcu_miu_rsp` | DCU | 4 |
| `ccv_fet_miu_itlb_req` | FET | 1 |
| `ccv_rau_miu_cta` | RAU | 1 |
| `ccv_dcu_miu_fill_ntc` | DCU — refill notice | 4 |

| Out | To | Rate |
| --- | --- | --- |
| `ccv_miu_ooe_cmpl` | OOE — complete, replay, fault, MLC miss | 4 |
| `ccv_miu_rcu_data` | RCU — load data, `pred_result` | 4 |
| `ccv_miu_spm_req` | SPM | 4 |
| `ccv_miu_dcu_req` | DCU | 4 |
| `ccv_miu_fet_itlb` | FET — walker refill | 1 |
| `ccv_miu_ooe_cmpl_hint` | OOE — completion hint | 4 |
| `ccv_miu_rau_ready` | RAU — demoted warp ready | 1 |

Fifteen channels, eight in and seven out, and the widest by far: `ccv_rcu_miu_addr` alone is about 12,460 wires at rate 4 (3,111 bits a slot).

## Internals, mechanisms, risks

### Structures

| Structure | Size | Tier |
| --- | --- | --- |
| AGU pipes | 4, each 32 lanes wide | decided |
| Coalescer | per pipe, by lane group (MA-4, MA-7) | decided |
| TLB | an L0 of 6 entries per lookup slot in A2 (fully associative, round robin per slot, no broadcast; MA rev 206), and behind it a 32-entry fully associative TLB in A3 that refills the L0s (MA-8; MA rev 199). The 32-entry TLB has 1 port, with a round-robin refill grant (MA rev 203) | decided |
| Page-table walker | one, shared with FET's ITLB | decided (MA-8) |
| Load buffer | one 40-entry memop queue (MQ) holds loads and stores, a payload slot per entry (MA-5) | decided |
| Store buffer | one 40-entry memop queue (MQ) holds loads and stores, a payload slot per entry (MA-5) | decided |
| Disambiguation | none: a memop waits only behind its own warp's older memops to the same line (TI-27 (d), MA-11) | decided |
| `req_id` tables | per hop: SPM, DCU | prov |
| CTA bounds | `CCV_P_MAX_CTA` entries | prov |

### Mechanisms

- **Predicate gating**, the rule most likely to be got wrong: faults are raised only for lanes in `active_mask`, and MIU checks `active` is a subset of `issue`. Masked lanes routinely compute out-of-bounds addresses that must not fault.
- **Fault priority**, lowest lane with the highest-priority cause, reported with the lane mask and that lane's address.
- **Translation at 4 per cycle on the hit path**, assuming each instruction's 32 lanes fall in one page. A page-split access leaves the hit path and completes in passes (MA's Phase 1 architecture below).
- **Coalescing** to distinct pages for translation and to bank sets for the scratchpad. The 8-bit case must reach full bandwidth when byte ranges are bank-disjoint.
- **Exclusive ownership** for atomics, released on kill and on demotion.
- **Store commit at retire**, with retired stores draining even during teardown while pending loads are dropped.
- **Bulk discard** (A-41, A-53): on a mispredict OOE sends one `ccv_ooe_miu_memop` with `mem_op` 0xF, and MIU discards every uncommitted store and every uncommitted load of that warp whose ROB index lies in the circular range (branch, tail\] (loads by TI-21, each completed with status replay). Atomics (mem\_op 2 and 3) are exempt (OI-127): a mispredict's range never covers an issued A1, and a killed atomic finishes its pass. `rob_tag` names the branch; the tail rides the `discard_tail` overlay on `disp[4:0]` (`CCV_P_W_ROB_IDX` bits, emitted as `CCV_OOE_MIU_MEMOP_DISCARD_TAIL_LSB` / `_W`). The command gets no completion; each store it discards still completes individually.
- **L1-hit contract** (A-46, A-47): `ccv_miu_ooe_cmpl` and `ccv_miu_rcu_data` are fixed latency, and an L1 hit completes and lands its data at exactly `CCV_LAT_L1_HIT` = `CCV_LAT_L1_HIT_BASE` (7, tunable) plus the repeater stages on `ccv_miu_dcu_req` and `ccv_dcu_miu_rsp`. No completion at that cycle is the miss indication. Nothing past L1 is contracted; scratchpad loads and atomics never wake dependants speculatively.
- **Where the L1 contract starts** (A-61, A-63; custom-cuda-core `0cf039a`): `CCV_LAT_RCU_ADDR_BASE` = 1 (PF-47, adopted, AR 351; applied once OI's control passes, and reapplied as 1, not 2), so `CCV_LAT_L1_WAKE` = 13, `CCV_LAT_L1_CMPL` = 14 and `CCV_LAT_L1_HIT` = 7. `CCV_LAT_L1_HIT` runs from the cycle MIU holds both the memop and its address from RCU. 'Holds' means MIU's first registers hold both payloads (RI-11; AR rev 286). MIU's pairing and tag work start from those registers, so `CCV_LAT_L1_HIT` stays 7 with the interface flops built. The address path is usually the later one. RI-11's extra cycle is a link term, not a base (AR rev 300): a crossing costs `CCV_LAT_HOP` + its repeater stages + bnd\_rx, where bnd\_rx is 1 for a flopped receiving end and 0 for a no-flop one. miu\_rcu\_data is flopped at RCU (bnd\_rx 1; DA 116, 2026-11-09, kept). ooe\_rcu\_issue has been zero-cycle at RCU since RA-43 (bnd\_rx 0). rcu\_miu\_addr's end at MIU is no-flop (bnd\_rx 0): MIU's end of rcu\_miu\_addr stays at 0 NGD (A1 reads the capture registers), so neither contract grows. Measured from OOE's issue (history: at RCU's block-internal base of 5, before PF-47, `CCV_LAT_L1_WAKE` was 17, 16 before RI-11, and `CCV_LAT_L1_CMPL` 18):
  - start = max(memop crossing, issue crossing + `CCV_LAT_RCU_ADDR` + `ccv_rcu_miu_addr` crossing);
  - `CCV_LAT_L1_WAKE` = start + hit + data crossing − issue crossing = 13 at PF-47's base 1. The issue's bnd\_rx sits in both the start and the subtracted crossing, so it cancels while the address path binds; the extra cycle is miu\_rcu\_data's flopped end at RCU. History: 17 at base 5 (16 before RI-11);
  - `CCV_LAT_L1_CMPL` = start + hit + completion crossing = 14 at PF-47's base 1. The completion's end at OOE adds nothing. OOE takes `ccv_miu_ooe_cmpl` and `ccv_miu_ooe_cmpl_hint` both at no-flop ends of the first kind, capture registers enabled from OOE's own flops (OA rev 363, configuration C9: +0.444% S1, and OOE's ROB sees a memop's done a cycle later, inside OOE). So bnd\_rx(miu\_ooe\_cmpl) is 0, and `CCV_LAT_CMPL_HINT` 2, `CCV_LAT_FILL_NOTICE` 4 and `CCV_LAT_MLC_HIT_MAX` 39 stand. MIU and DCU change nothing for RI-11. The two channels must keep one end treatment: flopping either alone breaks the hint's lead, and TI asserts it. History: 18 at base 5 (19 between RI-11 and RA-43, when the issue's flopped end at RCU sat in the start).

  Each crossing is `CCV_LAT_HOP` (2) + its repeater stages, and both values assume no repeater stages.
- **One address message per memop** (RA-21, settled by AR). `ccv_rcu_miu_addr` is slot-bound, slot k to pipe Pk, and fixed-latency. Every memop OOE issues, a fence included, gets exactly one address message, `CCV_LAT_RCU_ADDR` after its issue. A fence's carries only `rob_tag` and `active_mask`, and every other field is don't-care. A bulk discard (mem\_op 0xF) goes from OOE to MIU alone and gets none. MIU returns each slot's credit in the cycle its message lands and has no stall path on this channel: nothing in MIU may refuse an address.
- **The sectioned footprint** (OI-33; RA-21). A memop's `pipes` field is its footprint over P0-P3 at its data position: four pipes at 32-bit `chwidth`, two at 16 and one at 8. Slot k of `ccv_rcu_miu_addr`, `ccv_miu_dcu_req`, `ccv_miu_spm_req` and `ccv_miu_rcu_data` is pipe Pk. `phys_dst` is a row, and `dst_pos` and `dst_width` the slice a load writes; `load_data` carries the slice right-aligned in each lane's 32 bits. The stub checks that `pipes` matches `chwidth` and `dst_pos`. How MIU uses the footprint's pipes beyond the address slot (lookup slots, data beats) is in MA's Phase 1 architecture below.
- **Orphaned responses dropped** on a validity check, since holding the entry would refill the buffer and stall again.
- **MLC miss notification**, which is the primary demotion trigger and rides the completion path.
- **Addressing**: `disp` sign-extended, `scale` derived from `chwidth`, or from xfer\_size for a sized transfer (O-80). A 4-bit memory access is F-WIDTH, raised by OOE at dispatch (O-80), never by MIU.

**Refill completion hint** (AR, 2026-10-21; register OA-23, OA's acceptance at its rev 140), a contract on MIU before its session:

- **The hint.** On DCU's refill notice (`ccv_dcu_miu_fill_ntc`, `CCV_LAT_FILL_NOTICE` ahead of the response), MIU sends a hint on ccv\_miu\_ooe\_cmpl\_hint, the fixed-latency notice channel beside `ccv_miu_ooe_cmpl`: a valid and the completing memop's RS identity as OOE sent it on `ccv_ooe_miu_memop`. Its completion's valid follows exactly CCV\_LAT\_CMPL\_HINT (2) cycles after the hint's fields land. A refill's completion valid follows its response valid by CCV\_LAT\_MIU\_FILL = 2, MIU's pass-through, confirmed by MA (TI-23). The hint is a promise. A completion that does not follow is a defect, not a cancelled wake.
- **How MIU keeps it: slot reservation.** MIU's L1-hit completions are fixed at `CCV_LAT_L1_HIT`, so MIU knows its completion slots that far ahead. It reserves the refill's slot when it sends the hint, and never displaces a contracted hit.
- **Stateless echo.** MIU stores the RS identity with the memop and echoes it on the hint and on the completion, as it echoes `phys_dst`. OOE decides whether a hint or completion is stale, never MIU (register OA-23: the identity's form is OA's).

**Committed stores carry no live tag** (AR, 2026-10-21; register TI-24). Once a store commits at retire, nothing matches it by `rob_tag` or `warp_id` again. Bulk discard and kill touch only uncommitted stores. A committed store drains by its store-buffer entry. So a tier-1 slot's ROB tags, or an exited warp's `warp_id` given to a new launch, may be reused while it drains.

**A demoted warp's loads are abandoned, not awaited** (AR, 2026-10-22; register TI-21, AR's rev 106, OA's rev 160, PF-23). A demotion's squash sends the bulk discard (`mem_op` 0xF) for the warp, with its uncommitted loads included. For each discarded load MIU:

- **sends its one completion now**, status replay (A-41), and marks the entry orphaned;
- **(a) writes no `ccv_miu_rcu_data` after that completion.** If the load's data beat has already started, MIU finishes the write first, and the completion may then carry its real status. This makes OOE's deferred free safe, because the freed register may go at once to another slot's warp;
- **(b) raises no hint for an orphan**, and ignores its `ccv_dcu_miu_fill_ntc`;
- **(c) sends exactly one completion** when a discard races a normal completion in the same cycle;
- **drops DCU's eventual answer**: no completion and no data. The line still fills DCU, so the restored warp's replayed load hits.

**The ready report.** MIU counts each warp context's orphans in flight (32 counters, at most 2^`CCV_P_W_REQ_MIU_DCU` each). When a warp's count returns to zero, MIU sends `warp_id` on `ccv_miu_rau_ready` (rate 1, MIU to RAU). RAU marks the parked warp ready to restore. A kill clears the warp's count and sends no report. The cost: an orphan holds its entry and `req_id` until DCU answers, which is MIU's pressure and never the slot's.

**Read-only memory and F-RO (AR, 2026-10-22; register TI-26; ISA O-51, §5.2, §12.5).** MIU raises F-RO, cause 8, on any lane in active\_mask of a store or atomic whose effective address lies in either read-only region. Loads are never checked. The check is on the effective address, before MIU maps the launch window.

- The launch window. Address bits \[47:16\] equal LAUNCH\_WINDOW (LAUNCH\_BASE >> 16 = 2). The whole window is read-only, not just the block, so no per-CTA bound is needed. An address there past the block's end is unmapped, and F-ADDR wins, or it is read-only.
- The .const range. \[const\_base, const\_limit) from ccv\_rau\_miu\_cta, held per CTA slot (8 × 128 bits). Any byte of the access in the range faults (ISA v1.9 §12.3; §5.2 at 46bb17c, no padding). The limit may be at any byte, so a store can straddle it, but its first byte then lies below the limit. The base is 64 KiB-aligned, and every access is naturally aligned (O-58), so nothing straddles the base. So const\_base ≤ addr < const\_limit on each lane's first byte is exact: two compares. Every atomic faults, a failing cas included, and st.pred is a store. An empty range faults nothing.
- No effect. An instruction with an F-RO lane has no effect on any lane. A store puts nothing committable in the store buffer, and an atomic sends no exclusive request, so a read-only line is never exclusive or dirty in the core. Priority is last in §12.5, and the record takes the lowest such lane's address. A squashed path's store only marks its entry.
- Host writes. A host write to \_\_constant\_\_ data, or any host write, between launches reaches MIU's loads through the coherent boundary: MLC's probe invalidates DCU's copy (ccv\_mlc\_dcu\_probe). MIU holds no data across launches, so nothing of MIU's is stale. Its TLB is, if the host remaps: CRU invalidates the whole TLB while launch is closed (MA-10).

**A load behind an older store (AR, 2026-10-22; register TI-27 (d)).** MIU holds a load while any older store or atomic of its warp that overlaps one of the load's lines has not yet written DCU, committed or not. Nothing is forwarded from the store buffer. This is exact with no disambiguation, because OOE issues a warp's memops in program order (OI-15), so every older store is already in MIU. It cannot deadlock, because the store retires without the load. Line granularity is decided (MA-11); a byte-granular check is not built. Store-to-load forwarding is PF-42.

**A bit-masked st.pred (ISA v1.9 O-63, c685aee; register IS-18, AR's revs 132 and 133).** st.pred stores only the issuing group's bits, merged as one indivisible step. To OOE it is a store. Once it commits, MIU drains it as a read-merge-write of each word it names, up to four contiguous words in one 16-byte frame: new = (old & \~m) | (d & m). m is the entry's active\_mask, which equals the issue mask, since st.pred has no guard. d is the store data. That is 128 two-input muxes in the drain.

- Global: one line holds the frame. MIU takes it with exclusive ownership and holds it from the read to the write, as for an atomic, so no other agent's write lands in between.
- .shared: MIU reads the bank words and writes them back with no other access to those banks in between, using CCV\_L\_W\_SPM\_OP's read-modify code.
- It runs after commit, so it is never speculative. If m is empty, nothing is read or written. F-RO, F-ALIGN and F-SHARED are raised at execute, as for any store. A younger ld.pred waits for the write under the older-store rule above.

**Predicate transfers on the channels (AR, 2026-10-23; register TI-36).** ld.pred is mem\_op 4 and st.pred is mem\_op 5. DEC cracks a mask of N predicates into N uops, in ascending order, uop k at disp + 4k, one predicate each. MIU forms the address from lane 0's element of base\_per\_lane plus disp, whether or not lane 0 is active. st.pred's word rides in store\_data's lane 0 slot, and ld.pred's returns as pred\_result to the memop's phys\_pred, gated by active\_mask. A fault names active\_mask and the word's address. The cracked uops are separate ROB entries, so a demotion between them re-executes the earlier ones. That is sound because both forms are idempotent there: the slot is warp-private, and the predicate source is unchanged.

ld.pred's pred\_result lands on ccv\_miu\_rcu\_data at the cycle a GPR load's data would (OA's rev 180). On an L1 hit that is CCV\_LAT\_L1\_WAKE's fixed time, so OOE wakes a predicate consumer by the same rule as a GPR one, with no second latency class.

**Atomics' address (ISA v1.9 O-72, 530391d, adopted by DA; register IS-21, CP-26).** Every Format M form addresses as Format D's base+index does: (rbase << 16) + (rindex << scale) + disp for .global, and rbase + (rindex << scale) + disp for .shared, which is flat. A1 forms each lane's address in the AGU on that path, base\_per\_lane and index\_per\_lane, at no new cost. MIU keeps each lane's address from A1 to A3, as it already holds the line across that span, so A3 names no address sources. A further pass (more = 1) re-issues A1, which forms the addresses again from its own renamed sources.

Kill obligations (OA 436, final per OA 438 and AR 385, on TI-485 (5)(a); the OOE doc's Atomics "Demotion and kill" and V-70). MIU completes every outstanding memop of a killed warp, A1 included, and OOE's kill ack waits on them all. An atomic's pass in flight keeps its state, address and exclusive hold (or SPM bank entry) from A1 through its A3. OOE still issues that A3 after the kill, and MIU completes it with more = 0 and releases the hold. A kill starts no further pass. A DCU read withheld for an uncorrectable error (MA-19, TI-485) still completes to OOE, with no data. Under a machine check the values are moot, and the pass's A2 and A3 run as usual, so any hold is released. Dropping a memop without a completion would need a no-data completion OOE can tell apart, which is a row in OA's tab first.

**The .shared adder is 32 bits and drops its carry (ISA v1.9 §5.1, .shared is flat 32-bit; register CP-33, TI's rev 156).** Every .shared address, of a Format D memop or a Format M atomic, is rbase + (rindex << scale) + disp taken modulo 2^32. disp is sign-extended into that 32-bit sum. A carry out of bit 31 is discarded, so LLVM's base - 256 + t\*4 lands where ccv-sim puts it. F-SHARED's bound check is made on the wrapped 32-bit address. Only .global's sum, (rbase << 16) + (rindex << scale) + disp, is wider.

**atom.add.f32 (ISA v1.9 O-76, Format M 9 and 25; Daniel, 2026-10-23, DA's response IS-14 item 1; AR's rev 166).** MIU does no arithmetic for it. A1 and A3 are an integer RMW's: the read and the write under the line hold, and the address kept between them. The add is A2 in LANE's existing FP adder. There is no adder at the RMW site, which was Daniel's condition. One rule becomes observable here. Each pass takes, for every address, the lowest lane not yet done, so same-address lanes apply in ascending lane order as O-76 and the AR-21 rule require. A lane deferred because its line is unavailable cannot be overtaken by a higher lane at the same address, since that lane needs the same line. An integer add could not show the order. An FP add shows it in every result, and so does exch's old value. TI's chain check holds the order per address.

**A narrow address register contributes its element, zero-extended (ISA v1.9 O-79, 1891eb0, amending O-39; register AR-24, AR's rev 182).** base\_per\_lane and index\_per\_lane come from RCU's operand read of the register's section set, and a sliced register holds nothing above its element. So an 8- or 16-bit base or index enters the AGU's sum zero-extended to 32 bits, before the shift and the scale. This holds in every form: Format D, Format M, and the .local and predicate transfers. It is the only reading the core can give, and ccv-sim is to read a narrow address register the same way under O-79 (CP's change).

**Sized loads and stores (ISA v1.9 O-80, a468ba9; Daniel, 2026-10-24, DA's response IS-23; AR's rev 184).** The memop carries xfer\_size (0 = the data register's width, 1 = one byte, 2 = two bytes) and xfer\_signed, from DEC through OOE. MIU's changes are small, because it already moves 1- and 2-byte transfers.

- Size. A nonzero xfer\_size sets the transfer, and the byte mask with it. Zero keeps today's rule, the data register's width.
- Address. Scale-enable shifts rindex by the transfer size, 1 or 2 bytes, so the AGU's scale takes 0 or 1 from xfer\_size: a two-way mux before the adder. F-ALIGN checks the transfer size (O-58): a halfword must be 2-byte aligned. A byte is always aligned.
- Load fill. MIU extends each lane's byte or halfword to rdata's width before ccv\_miu\_rcu\_data: zero-filled for ld.u8 and ld.u16, sign-filled for ld.s8 and ld.s16. rdata stays at its committed width, usually 32. That is the whole datapath cost: per lane, a fill of 8 or 16 bits from the element's top bit or from zero, after the existing byte select. It adds about one mux level to the return path after the byte select. It fits the L1-hit contract's fixed latency without a stage: the fill sits in R2 after the lane extract (the L1-hit budget below).
- Store. st.8 and st.16 write rdata's low one or two bytes, which MIU takes from the store data RCU sends, with the byte mask at the transfer size. The partial-line store path (DCU's read-merge) is unchanged.
- Faults. O-80's F-WIDTH (a transfer wider than rdata's width, or rdata at 4 bits) is OOE's, at dispatch. MIU's execute faults (F-ALIGN, F-ADDR, F-SHARED, F-RO) apply per lane as for any memop.

**Slot-form addressing (ISA v1.9 O-45; AR, 2026-10-22; register TI-31).** A slot-form load or store names launch slot k (arg\_slot on ccv\_ooe\_miu\_memop, with slot\_form). Its window is the 32-bit word at launch\_block\_addr + 32 + 8k. MIU holds a window table per CTA slot: 16 windows × 32 bits × 8 slots = 4,096 flops, plus 128 valid bits. It reads the table, registered, when the memop arrives, CCV\_LAT\_RCU\_ADDR cycles before the index from RCU, so the AGU sees a flop. An invalid entry makes the access an L1 miss: MIU reads the window's line and fills every slot that line holds (slots 0 to 11 or 12 to 15), then performs the access. The valid bits clear only on the slot's ccv\_rau\_miu\_cta: MIU sees warp kills, not CTA kills, and a launch's windows are invariant. A window fill writes the table only for a live memop's response, never an orphan's, a killed warp's or a discarded load's; a live memop's fill lands before it completes, so before its warp's exit or kill ack and the slot's reuse (MI-22, MA rev 187). Assertion: no fill to a slot whose ccv\_rau\_miu\_cta is newer than the fill's request; control: an orphan's response that fills, across a slot reuse. Within a launch the windows are invariant (§5.2), and F-RO forbids writing them. Fault checks apply to the formed address.

**Interleaved local (ISA v1.9 O-69, 961eb60; DA's adoption of IS-19, 2026-10-23).** ld.local, st.local, ld.pred.local and st.pred.local name no base register. Lane l's byte b, an unsigned 17-bit offset, is at ((local\_base + CCV\_LANE\_CONTEXTS) << 16) + (ctx << 22) + 128 × ⌊b / 4⌋ + 4l + (b mod 4). ctx is the device-unique warp context, (core index << CCV\_W\_WARP\_ID) | warp\_id, which is the memop's warp\_id with the strapped core index wired above it. The predicate forms take lane term 0, so they are one word a warp, with O-63's merge on the store.

**Interleaved private window (IS-24 option W, adopted by DA 2026-10-26; PF-46; ISA O-83, §5.9, compiler 3424e9a).** Any .global access, of any form, is interleaved when the rbase of the lowest lane in its issue mask lies in the window, an aligned run of 2^k 64 KiB windows starting at W: rbase >> k equals W >> k, with k fixed by the device constant CCV\_PRIV\_WINDOWS. W is local\_base plus 3 × CCV\_LANE\_CONTEXTS, which MIU forms once a CTA from local\_base as ccv\_rau\_miu\_cta delivers it at the CTA's dispatch (TI-47 (a)), and holds beside it: about 32 flops a CTA slot. So W is valid before the CTA's first memop, and needs no launch-block fill: compiled code reads word 24 with an ordinary load, which never fills the table. The decision compares every lane's rbase high bits in parallel and takes the lowest issuing lane's result from a priority encode of the issue mask, about 1,000 to 1,500 gates, beside the address add, not after it. Lane l's logical offset is b = ((rbase − W) << 16) + (rindex << scale) + disp, exact; b outside \[0, L) raises F-ADDR. So does an access decided ordinary whose address lies in the run's own windows, a launch-slot form's included (§5.9; IS's rev 171): the run is reached only through an interleaved pointer. TI built both checks (5fe7177, gate kernel privwin). Its byte goes to R(ctx) + 128 × ⌊b / 4⌋ + 4l + (b mod 4), with R(ctx) the warp context's region, 32 × L bytes apart, wiring as O-69's ctx << 22. MIU forms it in the base + index form's own 3-input add: rindex rewired as {rindex\[31:2\], 11111, rindex\[1:0\]}, disp as {disp\[31:2\], 00000, disp\[1:0\]}, and rbase's k low bits, which are (rbase − W) since W is aligned, placed where b's bits \[16+k−1:16\] land after the same rewiring, at \[20+k:21\]; the region term is the fourth operand. The ones carry bit 1's carry straight to bit 7, and bits \[6:2\] of the sum are then replaced by l. AR's revs 211, 215, 218 and 219 put this in one sum, one more carry-save level per lane and no new adder. That does not fit (MI-21): the decision needs rbase, which lands at H, so a decision ahead of the carry-save level makes A1 about 32 NGD. So each lane forms two sums in parallel, ordinary and interleaved, and the decision picks between them after the adders (MA, MI-21 (a)). The interleaved sum is narrow. R(ctx) is aligned at 32 × L (ctx << 22), and 128 × ⌊b / 4⌋ + 4l + (b mod 4) lies below 32 × L, so the bits above that alignment are R(ctx)'s own wiring. Its adder spans only log2(32 × L) bits, after one carry-save level over the rewired index, disp and rbase's k low bits. The \[0, L) check on b runs from the same operands beside it, and F-ADDR takes it ANDed with the decision at the end. The decision is then about 8 NGD: the per-lane compares, and lane d's result taken by a one-hot select flopped at H-1 from the issue mask. The 32 × 48-bit operand fanout leaves its path, and the late select costs 1 NGD, so A1 stays within 25 with no extra cycle. miu\_lead's leaders do the same. Every access stays in its lane's 4-byte cell (F-ALIGN). Sized forms and atomics act per lane in the cell; ld.pred and st.pred take l = 0. A plain access into R(ctx) is an ordinary .global access (IS's rev 167); no check.

- local\_base is launch-block word 24, which RAU also sends on ccv\_rau\_miu\_cta at dispatch (TI-47 (a)), so neither O-69's local forms nor W wait on the window table's fill. The table keeps local\_base + CCV\_LANE\_CONTEXTS per CTA slot, added once at the CTA's arrival: 8 × 32 = 256 flops and 8 valid bits.
- The uniform part, the window term plus ctx << 22 plus 128 × ⌊b / 4⌋, is one 48-bit scalar add a memop. It is made in the cycles the memop leads RCU's operands, and feeds the AGU's displacement input. The 128 × ⌊b / 4⌋ term reaches at most bit 21, under ctx << 22, so those two never overlap.
- The per-lane base input is gated to zero, and the index input takes 4l, or 0 for the predicate forms. A word access is then one line and one page a warp. The memop's displacement is 17 bits for these forms.
- ctx needs no memop field (OA's rev 183). MIU forms it from warp\_id and CCV\_P\_CORE\_ID, and the stubs and RTL assert that it equals the value srd #2 gives the same warp.

### Risks

**Q-18 is closed** (2026-11-04; AR's responses RA-10 and RA-36): the AGUs and the coalescer stay in MIU, and `ccv_rcu_miu_addr`, about 12,460 wires, is a floorplan adjacency with RCU (Q-42), not a partitioning change. The block's defining risk is now the L1-hit budget: `CCV_LAT_L1_HIT_BASE` = 7 includes the MIU-DCU round trip, two crossings at `CCV_LAT_HOP` = 2, which leaves about three cycles for the AGU, translation, DCU's lookup and the return datapath (the L1-hit budget below).

**Four tag and TLB lookups per cycle** is the dominant NGD and area item. Decided: the TLB has 4 read ports, the tags are a register file banked with the data, and the data is 8 single-ported half-rate banks (DA rev 123, MA-16) whose conflicts resolve in slot order (MA-7, MA-8).

**Disambiguation is not built**: the own-warp line hold replaces it (MA-11).

### Questions for the session

- **Settled (Q-18, closed 2026-11-04): the AGUs and the coalescer stay in MIU**.
- Answered: TLB size, associativity, and whether the walker is shared with FET or duplicated: 32 entries, fully associative, walker shared with FET (MA-8).
- Answered: load and store buffer depths, which set the `req_id` widths: one 40-entry MQ; req\_id 6 bits toward DCU and 5 toward SPM (MA-5, MA-6, MA-15).
- Settled (ISA O-58): every access is naturally aligned at its transfer size, and F-ALIGN is a check of the low address bits against that size, per active lane, beside the AGU's sum.
- Settled (ISA O-51; register TI-26): .const is hardware-protected, and a store or atomic into it, or into the launch window, raises F-RO. See Mechanisms.
- Answered: page-split serialization, one lookup port or spread across four: it leaves the hit path and completes in passes.

## MA's Phase 1 architecture: resource model and L1-hit budget

**Status: decided.** MA's draft of 2026-11-13 was agreed by AR (rev 344) and, for MA-4, by OA (OA-408, OA-410). Daniel's rulings of 2026-11-15 (DA rev 121) build the L1 for 512 KiB, with 64 and 128 KiB as configured-down points at the same hit latency (PF-51 tracks a latency that follows the size), and keep MIU and DCU as separate blocks; a merge, tags inside MIU or a direct return to OOE is a Phase 2 decision (MA-9 closed). The hit path is budgeted at `CCV_LAT_L1_HIT` = 7 at 512 KiB with the set index sent as a lead field (B below); AR's PF-33/PF-47 sweeps at hit base 7, 8 and 9 price the fallback. AR agreed MA-1 to MA-8, MA-10, MA-11, MA-12 and MA-14 (AR revs 344 and 345), MA-5 as per-slot credits at 10 a slot (AR revs 345 and 347; OI-138 measured the select at 0 NGD), and DA answered MA-13. MA-15's parameter and schema changes are applied (TI 420, TI-420's a46afef7). The set-index lead (AR 362, MA rev 65) is TI's next (TI-449); until it lands, the schema and params win. AR's condition stands: `CCV_LAT_L1_HIT_BASE` = 7 holds only while `ccv_miu_dcu_req` and `ccv_dcu_miu_rsp` keep link\_n 0, so MIU and DCU abut (a floorplan constraint under Q-42).

**Also decided.** The memop watchdog is `CCV_P_TIMEOUT_MEMOP` = `CCV_MEMOP_CREDITS` × `CCV_P_TIMEOUT_MEM` = 20480 per slot (MA 51), since MIU holds a warp only behind its own memops. The performance baseline is coremark-derived-priv, the window form (AR 358). A gather of 25 to 32 lines leaves the L1-hit contract (MA-4's eligibility rule), and more L1 ports are ruled out as its fix: the fix is the layout (IS-24 option W, O-83).

### The L1-hit budget (MA-1, MA-2)

With abutted links, `CCV_LAT_L1_HIT_BASE` = 7 closes **with no slack**, and only if DCU reads its arrays and decides a hit in two cycles. The two crossings cost 4 of the 7 cycles. A set index sent as a lead field buys one cycle back, but only if a way fits in a page.

The convention (MA-1, agreed by AR rev 344):

- H is the cycle MIU's first registers hold both the memop and its address (A-61).
- A crossing launched at t has its valid held at t+1 and its payload held at t+2 (`CCV_LAT_HOP` = 2, valid a cycle ahead of payload).
- "Leaves at H+7" means the valids of `ccv_miu_ooe_cmpl` and `ccv_miu_rcu_data` launch at H+7, with RA-40's lead fields; `load_data` launches at H+8.

**Strawman A (not chosen): physically indexed, no new field.**

| Cycle | Where | Work | Budget |
| --- | --- | --- | --- |
| H | MIU A1 | AGU: per-lane 3-input sum (48 bits .global, 32 .shared), slot, local and window forms; F-ALIGN; lane-group leaders (resource model below) | 25 NGD |
| H+1 | MIU A2 | `miu_dcu_req` valid launches (known from the memop alone). TLB, 4 ports; F-ADDR, F-SHARED, F-RO; group check and dedupe; byte masks | 25 NGD |
| H+2 | link | the req payload launches (PA, size, mask, data) | – |
| H+3 | DCU D1 | payload held; tag and data arrays read on the index | one array access |
| H+4 | DCU D2 | tag compare over 8 ways, hit and way; rsp valid flopped | 25 NGD |
| H+5 | DCU D3 | rsp valid launches; 8:1 way select of 1,024 bits, flopped | 25 NGD |
| H+6 | MIU R1 | rsp valid held; completion valid and section schedule flopped; rsp payload launches | 25 NGD |
| H+7 | MIU R2 | completion and data valids launch, with the lead fields; `read_data` held; lane extract (up to 32:1 a lane) and O-80's sized fill | 25 NGD |
| H+8 | MIU out | `load_data` launches | – |

Nothing is left over, so under A the 512 KiB array, any second cycle of array access and any repeater stage on either link push the base to 8. Each cycle of L1 wake costs about 2% on single-thread code (AR-24). That is why B is chosen.

**Chosen, B: the set index as a lead field on `ccv_miu_dcu_req`.** MIU sends the set index, whose low 3 bits name the bank, with the request's valid, at H+1, and DCU starts its arrays at H+2 while MIU translates. That frees one cycle: margin for a 2-cycle array, or for the 512 KiB array at base 7. It needs the index bits inside the page offset, so a way must fit in a page. With 64 KiB pages (`CCV_L_PAGE_SHIFT` = 16; MA-2, MA-15) and the 512 KiB 8-way L1's 64 KiB way, the index bits \[15:7\] sit inside the page offset, so B holds at 512 KiB and at every configured-down size. The lead field is an interface change: an MA row asks AR and TI for it (MA rev 64). AR agreed (AR 362) on six conditions, all accepted (MA rev 65): (1) a params require, `CCV_DCU_SETS` × `CCV_P_LINE_BYTES` ≤ the page; (2) the index comes from the final formed address of the slot's position-chosen leader, and A1 still closes in 25 NGD; (3) the array read on the lead is speculative, and no state, LRU included, changes until the payload; (4) 9 bits a slot, no separate bank field (AR 364), held a cycle ahead of the payload; (5) DCU's 36 capture flops are a lead waiver (`"lead": true`) in DCU's 2%; (6) probes and fills do not change. B saves +0.57% on cm128priv against hit 8 at 512 KiB (AR 362). If the 512 KiB array needs more than B's margin, AR's base-8 runs price that.

**What the budget assumes, for check-ngd:**

- an SRAM read is one cycle from a registered index, outside the 25 NGD (MA-3 (b): hard SRAM macros, `rtl/macro/ccv_common_sram_*`, TI rev 409);
- MIU's end of `rcu_miu_addr` stays 0 NGD, and A1 reads the capture registers;
- `CCV_LAT_MIU_FILL` = 2 holds by the same R1 and R2 stages: a refill's rsp valid launched at t gives the completion valid at t+2. MA confirms 2 (TI-23).

O-80's sized fill and O-83's interleaved sum both fit: the fill in R2 after the lane extract, and the interleaved sum in A1 as a second, narrow adder per lane, selected after both adders (MI-21 (a)).

**Early no-hit (MA-4, OA-408 and OA-410, decided).** A load that loses the contract for a reason A2 knows (lane-group check, page split, TLB miss, bank conflict) sends a 1-bit no\_hit on `ccv_miu_ooe_cmpl_hint`, launched at H+2 (`CCV_LAT_MIU_NOHIT_A2` = 2), so `CCV_LAT_L1_NOHIT` = issue-to-H + 2 + `CCV_LAT_HOP` = 9 under PF-47, 4 cycles before the speculative wake at `CCV_LAT_L1_WAKE` = 13, and OOE wakes no dependant. It is advice, never a promise; a refill hint wins a slot collision. A tag miss keeps today's signal, the missing completion.

### Pipes, lane groups and lookup slots (MA-4, MA-7)

A memop's footprint is its lookup budget. A memop of footprint F pipes (4, 2 or 1 at 32-, 16- or 8-bit) owns lookup slots Pk of its footprint on `ccv_miu_dcu_req` in its first pass, as it owns those slots on `ccv_miu_rcu_data`. Co-issued footprints are disjoint (V-60), so a cycle's first passes never ask for more than `CCV_DCACHE_LOOKUPS` = 4 lookups, and no arbiter sits on the hit path.

- **AGU.** Four AGUs, each 32 lanes wide, one per address slot. A memop holds its AGU for one cycle, A1. Misses and later passes park in the queues, never in a pipe, unlike the stub, whose job holds its pipe to completion.
- **Coalescing by lane group, per pipe.** The memop's 32 lanes split into F groups of 32/F consecutive lanes, group g on the footprint's g-th slot. Each group's lookup is the line of its lowest active lane, its leader. All F leaders are found in parallel. A2 compares every active lane's line with its group's leader, and compares the leaders pairwise to drop duplicate lookups. That is two levels of compare and a priority encode, with no serial search. A shared coalescer that finds up to four distinct lines among 32 lanes needs four serial leader searches, about 60 NGD, so it does not fit A2.
- **What one pass covers.** Unit stride is one line at every width. A 32-bit stride of 2 or 4 words is two or four lines, one per group pair or group. So every footprint carries its width's natural access pattern in one pass.
- **Eligibility for the L1-hit contract.** A load completes at `CCV_LAT_L1_HIT` only if every active lane matches its group's leader, the access stays in one page, its lookups meet no bank conflict, and every lookup hits. Otherwise there is no completion at H+7, and OOE treats it as a miss. Its remaining lines go out in later passes from the load queue, on idle lookup slots, and it completes past L1.
- **Bank conflicts.** DCU's data array is 8 half-rate banks by line address bits \[9:7\] (DCU tab, Internals). A cycle's deduplicated lookups that collide on a bank go in slot order. The later one loses its first pass and its contract, never someone else's.
- DCU bank credits (MA-24, MA-25; AR 382). MIU keeps two credit counters per DCU bank, which reset full: 16 lookup entries (CCV\_DCU\_BANK\_QDEPTH) and 12 store-data entries (CCV\_DCU\_BANK\_STDATA). A lookup goes to DCU only with an entry credit for its bank, and a store only with both. DCU returns credits on two per-bank vectors, ccv\_dcu\_miu\_cred's ent\_ret and std\_ret (rate 1, CCV\_DCU\_BANKS bits each; landed under MA-25, TI-506). A request without its credit is held in MIU. A held load loses its L1 contract for a reason known at A2, beside a bank conflict, so the early no-hit covers it. A held store stays in the store buffer, where loads still forward from it, and blocks every younger store to its bank, including st.pred's drain and an atomic's exclusive request. Credits return within CCV\_DCU\_BANK\_AGE, so a held request's wait is bounded, and the oldest held store takes the next store-data credit.
- **SPM** takes the same group rule for its passes. Its contract is unchanged: SPM loads never wake dependants speculatively (A-46).

### Entries, credits and req\_ids (MA-5, MA-6)

MIU never refuses an address because it never accepts a memop it has no room for. Each credit it returns on `ccv_ooe_miu_memop` stands for a free entry in its memop queue. The address follows its memop at a fixed time, so it lands in an entry already held (OA-409 confirms that every memop OOE sends spends a credit). Credits stay per slot, `CCV_MEMOP_CREDITS` = 10 a slot over the 40 entries, a new per-channel param (TI rev 413; AR's ruling on MA-5, AR rev 345; no shared pool, no new credit class). OOE sends a memop on the first slot within its pipes that holds a credit, not always on the footprint's lowest pipe, so a 32-bit memop can use any slot's credits (40/18 = 2.2 a cycle) and a 16-bit one either slot of its pair. MIU's side: one physical 40-entry queue, not split by slot. Each entry records its arrival slot (2 bits) and returns its credit on that slot when it frees; a bulk discard returns its credit on take. Lookup slots come from the memop's pipes, never from its arrival slot. The address still arrives on the lead pipe's slot of ccv\_rcu\_miu\_addr, ctz(footprint), so MIU writes each entry's lead pipe at arrival and pairs the address by arrival cycle and lead pipe; co-issued footprints are disjoint (V-60), so lead pipes never collide (OA-412, confirmed by MA). A credit return is a 1-bit pulse a slot a cycle, and two entries of one arrival slot can free in the same cycle, so MIU keeps a 4-bit owed count per slot and returns one credit a cycle from it. OI measured the credit term in OOE's select at 0 NGD on its flop-to-flop paths (OI-138), so the shared-pool fallback is closed.

- **One memop queue (MQ), 40 entries**, holding loads, stores, atomics' A1 and A3, fences and predicate transfers from arrival to completion. A store keeps its entry after completion until it drains, so committed stores throttle new memops through the same credit. An entry is about 90 bits of echoed memop state (`rob_tag`, `rs_idx`, `phys_dst`, `dst_pos`, `phys_pred`, warp, CTA slot, op), plus up to 4 line addresses and the lane-to-line map.
- **Payload slots.** Each entry has a 1,152-bit slot: a store's data and byte mask, or a multi-pass load's per-lane address state. A 40 × 1,152-bit array is about 46 Kbit, the largest structure in MIU, held in a register file (`ccv_common_rf_1r1w`, about 138 Kbit SRAM-equivalent). It is one instance of 5,760 B, or two of 2,880 B with entries steered by arrival if Phase 1 needs two writes a cycle. SRAM is out: two half-rate banks would be 2,880 B each, below TI-467's 4 KiB SRAM minimum. The window table's register file is 512 B, exactly at the register-file minimum (DA rev 123, MA-16, TI-467; MA-18).
- **Why 40.** An entry lives from the memop's arrival, about `CCV_LAT_RCU_ADDR` + 2 before H, to its completion at H+7 on a hit. With the credit's own crossing back, an entry's credit loop is about 14 cycles from OOE's issue under PF-47 (18 at base 5). Issue is bounded by footprints, 4 pipes a cycle. One memop a cycle at 32 bits needs 14 entries, 2 at 16 bits 28, and 4 at 8 bits 56 (18, 36 and 72 at base 5). So 40, 10 a slot, carries 16-bit full rate with 12 entries to spare for misses. It binds on sustained byte traffic above about 2.9 memops a cycle (2.2 at base 5; AR's MA-5 ask). The model counts the cycles OOE holds a ready memop for want of a credit.
- **`req_id` toward DCU: 6 bits** (MA-6, agreed; in params since MA-15). A lookup holds its id from launch (H+1) until its response is held (H+7): 6 cycles × 4 slots = 24 ids for hits at full rate, before any miss. At 4 bits, 16 ids would cap the hit rate at about 2.7 lookups a cycle. 64 ids give room for 16 DCU misses with merged requests behind them.
- **`req_id` toward SPM: 5 bits, not 3.** SPM's round trip, about 2 × `CCV_LAT_HOP` + `CCV_LAT_SPM_BASE` + 1 = 7 cycles × 4 slots, is 28 ids at full rate; 3 bits gives 8.
- **Orphans** (TI-21) keep their entry and their ids until DCU answers. Their per-warp count is 32 counters of 6 bits.

### Ordering, the drain, translation and the miss path (MA-8, MA-10, MA-11, MA-12)

- **A held load blocks its own warp only.** TI-27 (d)'s rule stands: a load waits for every older overlapping store or atomic of its warp, at line granularity, with no forwarding. The check is a compare of the load's up to 4 lines against the MQ's undrained stores of the same warp. A store over more than 4 lines sets a wide bit, which holds every younger load of its warp until it drains: exact, coarse and rare. A held load holds only itself. A younger load of its warp that overlaps nothing goes ahead, keeps its contract and may complete first. One that overlaps the same line is held by the same store, so same-address order is kept. A fence not yet complete holds every younger memop of its warp, whatever its ordering bits say, until a measurement shows a narrower hold is worth it (MI-3, MA rev 123). Other warps never wait, which removes the stub's global head-of-line block.
- **The drain.** Committed stores drain in commit order per warp, on lookup slots no first pass uses that cycle. A drain that has waited `N_drain` = 16 cycles withholds one memop credit until it goes, so stores cannot starve under full-rate issue. st.pred's read-merge-write and atomics' A1-to-A3 hold use the same slots with exclusive ownership (DCU's write policy).
- **Translation.** Each lookup slot has its own L0 TLB of 6 entries (MA rev 206: rope's working set is 6 pages, and at 4 entries it costs 2.6%), fully associative, replaced round robin per slot, holding VPN, PPN, the PFN's fold and the permissions, looked up in A2 on the slot's leader page. The leader is fixed as the first lane of the slot's quarter. A slot whose first lane is inactive drops its first pass, and the memop finishes in passes (ropediv +2.1%, 0 on vadd, colwalk-p1k and cm32priv; MA rev 199). A leader page that misses its L0 drops the first pass (the no-hit path) and refills that L0 from a fully associative 32-entry TLB in A3, off the hit path. A miss at A2 gives a usable L0 entry 5 cycles later; the 32-entry TLB has one port, granted round robin over the four slots, and the fold comes from the walker's fill. The faults that drop the first pass at A2 are the L0 miss, an inactive leader lane, F-ADDR on the ordinary leader, a bank's loser (a duplicate line included), the page split, drop\_line, F-ALIGN, the interleaved and window F-ADDR, and drop\_held; F-RO, F-SHARED and .const are found at A3 and reported in the completion (MA rev 203). The passes look up the 32-entry TLB too. The split, the 32-entry TLB's PPN select in A3 with the payload a cycle later, was rejected: it costs a cycle of CCV\_LAT\_L1\_HIT (MI-30, MA rev 198). A memop whose active lanes span two pages leaves the hit path and finishes in passes. With 64 KiB pages (MA-2), 32 entries reach 2 MiB. A miss goes to one page-table walker, shared with FET's ITLB (one walk at a time). Its reads are DCU lookups on a slot no first pass uses, never contract-timed, so the tables cache in L1 and stay coherent through the probe path (MA-8, agreed). An ITLB miss may wait behind a data-side walk. Q-60's invalidate (MA-10, agreed) is a CRU command, legal only while launch is closed (Q-59's idle rule), that clears every TLB entry and the walker's state; MIU acks once clear. No per-page invalidate and no ASID. The same command clears FET's ITLB and I-cache, FET's side. The channel waits on Q-50 (the host launch path, RAU and CRU's).
- **The miss path.** A lookup that misses parks in the MQ entry, never in a pipe. DCU's miss buffers (16, `CCV_P_W_REQ_DCU_MLC` = 4) merge requests to the same line, up to 4 a line. So DCU holds a request only when all 16 are in use or a line's merge list is full, which narrows TI-22's hold statement (MA-12). The refill sends its notice, MIU its hint 2 cycles before the completion, and the completion follows the response valid by `CCV_LAT_MIU_FILL` = 2.

### Events the model must cover (for MI's and DI's handoffs)

Each event is a coverage bin in the C++ model, reached by a gate kernel or by directed stimulus, with a negative control that must fail (DA 119). This is AR's floor in `docs/miu-arch.md` section 7, made specific to the architecture above. The existing stub controls carry over unchanged.

| Event | Bin counts | Negative control |
| --- | --- | --- |
| L1 hit on each pipe and each footprint (1, 2, 4) | hits at exactly H+7, per slot | `late-hit-data`, `early-hit` |
| One-pass multi-line (stride 2 and 4 words) | hits with 2 and 4 deduped lookups | a 1-lookup coalescer loses the contract |
| Lane outside its group's line | multi-pass loads | a model that hits anyway corrupts data |
| Bank conflict among a cycle's lookups | slot-order losers | both granted: two reads of one bank |
| Page-split access | 2-page passes | a single translation fails the oracle |
| TLB miss, walk, and a walk racing FET's | walks, shared-walker waits | a dropped ITLB refill hangs FET |
| L1 miss, refill notice, hint, completion | notices; hint-to-completion = 2 | `hint-wrong-tag`, `late-refill`, `notice-wrong-id` |
| Merged miss to a line in flight | secondary requests per line | `dcu-one-miss` |
| DCU holding a request | held cycles, all miss buffers in use | a hold with buffers free fails TI-22's check |
| Eviction writeback and probe with dirty data | writebacks, dirty probe acks | `drop-writeback`, `write-through` |
| Full MQ | cycles with no memop credit, per slot | a model that accepts past 40 refuses an address; a credit returned on a slot other than its entry's arrival slot fails the credit checker |
| Load behind an older overlapping store, same warp | held loads; cross-warp loads never held | `no-st-wait`; a global hold fails a cross-warp bin |
| Wide store (over 4 lines) holding its warp's loads | wide-bit holds | wide bit ignored: ordering failure |
| Drain starvation guard | withheld credits | guard off: a store never drains under full issue |
| Every execute fault (F-ALIGN, F-ADDR, F-SHARED, F-RO) | per cause, per lane priority | `no-ro`, `addr-wrap`, a fault on an inactive lane |
| Discard, replay and kill against an in-flight miss | orphans; ready reports | `drop-replay`, `replay-twice`, `early-ready`, `no-ready` |
| Atomic passes, st.pred drain, SPM passes | passes per op | `atom-one-pass`, `atom-descending`, `stpred-whole-word`, `spm-one-pass` |

**Statistics the models report** (AR's asks, AR rev 344), per kernel, beside the bins:

- L1-contracted loads that lost the contract, by reason: a lane off its group's line, a page split, a bank conflict, a tag miss (MA-4);
- cycles OOE held a ready memop for want of a memop credit, by width (MA-5, AR rev 345), and cycles a slot had credits owed past one a cycle;
- bank conflicts among lookups, and fill-lookup collisions counted apart (MA-7);
- walker occupancy, and ITLB misses waiting behind a data-side walk (MA-8);
- loads held by the wide bit, loads held behind an overlapping own-warp store (PF-42's signal), and drain-guard firings (MA-11).

## MA's Phase 2: microarchitecture and module partition

**Status: slice 1, the L1-hit path, MA's (2026-11-21, MI-15).** The miss and refill path, stores and the drain, atomics, SPM, the walker, faults, discard, replay and kill follow as further slices, each announced to MI by a notice. Inside MIU the partition and its port budgets are MA's to decide. Two parts touch DCU's interface, and AR agreed both (AR 400, AR 401; MA rev 143); TI landed the fields (TI-513, 8ac4c441). MA-27 is the lookup drop bit. MA-28 is the hit's ECC check in MIU, option (c).

### Stages of an L1 hit at `CCV_LAT_L1_HIT` = 8 (way prediction on)

H is the cycle MIU's first registers hold both the memop and its address (A-61). Every MIU output launches from a flop, and both links are abutted (link\_n 0, bnd\_rx 0). Every MIU receiving end is no-flop at RTL, ooe\_miu\_memop included: MIU's own registers capture it at 0 NGD, enabled by MIU's flop of its valid (MI-18, MA rev 145). The address lands CCV\_LAT\_MIU\_PAIR\_LAG (3) cycles after the memop, the address path minus the memop path, required to be at least 1. miu\_pair loads the A1 memop fields from the MQ entry at H-1.

| Cycle | Stage | Work | Modules |
| --- | --- | --- | --- |
| H | A1 | Per lane, the AGU's 3-input sum with the window carry-save level; F-ALIGN. Each lookup slot's group leader, chosen by lane position, gets its own adder. The leader's set index and bank; the bank-credit gate (MA-27 (2)). Flops: the lane VAs, the leaders' lines and pages, and the req valid and `lead_set_index` (output copies `(* keep *)`) | miu\_cap, miu\_pair, miu\_agu8, miu\_lead, miu\_cred |
| H+1 | A2 | The req valid and lead launch. the L0 TLB of each lookup slot on its fixed leader's page (the quarter's first lane); the group and page check over every active lane; dedupe of the leaders and bank conflicts; F-ADDR, F-SHARED, F-RO; PA; drop (MA-27); req\_id from the preselected free ids. An L0 miss refills from the 32-entry TLB in A3, off the hit path. Flops: the req payload, the no-hit, and the MQ entry's lines and lane map | miu\_tlb, miu\_grp, miu\_a2, miu\_ids, miu\_mq |
| H+2 | link | The req payload launches; the no-hit launches on `ccv_miu_ooe_cmpl_hint` (`CCV_LAT_MIU_NOHIT_A2` = 2) | – |
| H+2 to H+6 | DCU | The lead held at H+2, the payload at H+3; the rsp valid launches at H+6 (the DCU tab's pipeline). A first-pass lookup's rsp valid at its contracted slot is its hit | – |
| H+7 | R1 | The rsp valid held (a no-flop end: capture enabled from MIU's own flops). The hit delay line names each slot's MQ entry. A memop's data is valid only if all F of its lookups are valid. The MQ entry's echo is read, with the per-lane line and word selects (7 bits a lane) and the byte offset. Flops: the data valid and `ccv_miu_rcu_data`'s lead fields (launch H+8), the selects, the completion state | miu\_hitq, miu\_rsp |
| H+8 | R2 | The data valid and leads launch. read\_data is held in the rsp capture. Per lane, a 128:1 word select (F lines of 32 words), the byte align and O-80's sized fill. The syndrome over each slot's line (MA-28 (c)). Flops: `load_data`, and the completion valid gated by the syndrome | miu\_rcap, miu\_ext, miu\_ecc, miu\_out |
| H+9 | out | `load_data` launches; the completion valid launches (`CCV_LAT_L1_ECC` = 1) | – |
| H+10 | out | The completion payload launches | – |

### Module partition (slice 1)

Modules live in rtl/miu/. Each size is a module parameter defaulting to `ccv_params_pkg`, and each module gets a reduced unit for loops and a full-size unit for its exit. No unit holds a whole slot's datapath: `ccv_rcu_miu_addr` is cut by lane octet. The flop counts are MA's estimates at full size; check-cg's figures replace them.

| Module | Instances | Stage | Contents | Flops each, about |
| --- | --- | --- | --- | --- |
| ccv\_miu | 1 | – | the top: `ccv_common_clk`, children and wires only; the generated stub's name and ports | 0 |
| miu\_cap | 4, one per address slot | H | `ccv_rcu_miu_addr`'s capture: active\_mask, base and index per lane (store\_data goes to slice 2's payload RF). Flops only, enabled from the pairing flop | 2,080 |
| miu\_pair | 1 | H−1 | pairs each arriving address with its MQ entry by arrival cycle and lead pipe; holds the 4 slots' A1 memop fields (form, scale, disp, W, chwidth, footprint, warp, entry) (disp copies drop to one per quarter, MA rev 203) | 754 |
| miu\_form | 1 | H−1 | the slot and local forms (MI-21, MI-22): the window table (8 CTA slots × 16 windows, a 32-bit word and a valid each), written from ccv\_rau\_miu\_cta's capture flops a cycle after they capture (clear the slot's 16 valids; local\_base + CCV\_LANE\_CONTEXTS, W >> k, W's k low bits), from miu\_rsp's window fill (a live memop's only); per address slot, its own 40:1 read of miu\_mq's issue\_mask by the paired entry, the issue mask's lowest lane d, and the 128:1 window read. Flops per slot at H: win, wv, fsel {slot, local, eligible}, wh, wl, rk {ctx, hi + 1, hi, lo8, bl}, dh, with win and fsel's slot bit as one (\* keep \*) copy per lane octet; per slot C for the local form; the H flops' enable is its own flop of miu\_pair's pen\_cm03h | 6,900 |
| miu\_agu8 | 16, slot s × lane octet u | A1 | 8 lanes: the ordinary 3-input sum with the window level and the slot form's base 2:1; the interleaved (O-83) and local (O-69) forms take no adder of their own (MI-25, MI-26, MA rev 195): an interleaved lane's field is the sum's low bits rearranged, and a local lane's address is miu\_form's per-slot C with 4l; F-ALIGN; flops 8 VAs (each the chosen form's field) and 8 align faults. On octets 0 and 2 (parameter LC = 1) also lc\_cm06h, a (\* keep \*) copy of the octet's first lane's VA\[47:7\] for miu\_grp's far lanes: 453 flops there, 412 elsewhere, +328 over the 4 slots (MI-42, MA rev 211) | 412 |
| miu\_lead | 1 | A1 | 16 leader adders (4 a slot) on operands muxed by lane position; routing to lookup slots by footprint; set index, bank, credit gate; the req valid and lead flops | 332 |
| miu\_cred | 1 | A1 | per-bank entry and store-data counters (MA-25), spent at the valid, returned from `ccv_dcu_miu_cred`; the per-bank gate flop (count after this cycle's spends ≥ `CCV_DCACHE_LOOKUPS`) | 120 |
| miu\_tlb | 1 | A2 | the L0 TLB of 6 entries per lookup slot (A2) and the 32-entry fully associative TLB behind it (A3, refills and passes; 1 port, round-robin grant, MA rev 203); each entry also keeps fold(PFN), CCV\_DCU\_WAYPRED\_BITS bits from the shared wayfold helper, written at the fill and read beside the ppn, which miu\_a2 sends as the req payload's pa\_fold at 0 NGD of fold logic (MA-30, AR 405, TI-518 landed; the line tag PA\[47:16\] is the PFN at CCV\_L\_PAGE\_SHIFT 16); the walker's fill port in slice 2; the L0s are 1,680 flops (24 × 70 bits; MI-40); the invalidate iv\_cm05h clears every entry, the last-write copy and the refill stages in one cycle (OA-484; tied 0 until Q-50); the L0 compare is in miu\_a2 | 4,259 |
| miu\_grp | 4, one per address slot | A2 | an inner helper declared in miu\_a2's file, timed as miu\_a2's logic (NGD-5; MA rev 209): each active lane's line against its group leader's line, and the page check. miu\_a2 takes every lane's sum (lv\_cm06h, 4 × 32 × 50) and active bit (am\_cm06h, 128) from miu\_agu8's flops; ge\_cm06h is gone | 0 |
| miu\_a2 | 1 | A2 | dedupe, bank conflict, faults, PA, drop (MA-27), req payload flops, no-hit flops, MQ writes | 361 |
| miu\_ids | 1 | A2, R1 | the 64 DCU req\_ids: free list with 4 preselected ids flopped a cycle ahead; id to entry table | 560 |
| miu\_mq | 1 (sliced in slice 2) | all | the 40-entry memop queue: echo state, lines, lane map, lost flag; read by entry at R1 | 13,000 |
| miu\_hitq | 1 | H+2 to R1 | first-pass delay line: entry and slot a lookup slot a cycle | 150 |
| miu\_rsp | 1 | R1 | data valid, lead fields of `ccv_miu_rcu_data`, per-lane selects, completion state | 1,400 |
| miu\_rcap | 4, one per rsp slot | R2 | `ccv_dcu_miu_rsp`'s payload capture (read\_data, hit, req\_id, and MA-28's check bits) | 1,170 |
| miu\_ext | 16, data slot s × lane octet u | R2 | 8 lanes: word select over F lines, byte align, sized fill; flops 8 lanes of `load_data` | 260 |
| miu\_ecc | 4, one per rsp slot | R2 | (137,128) syndrome over the slot's line, 8 code words (MA-29), non-zero flag out (MA-28 (c), pending) | 0 |
| miu\_out | 1 | R2 | the completion valid (gated by the syndrome) and the completion payload flops | 500 |

### Port NGD budgets (slice 1)

Arrival is the depth before the port, and the module's own share is what is left of 25. A port not listed keeps the default, 12 a side. MI transcribes these into `rtl/miu/<module>.ngd.json` with `"by": "MA"` and the tab's revision.

| Module and port | Side | Budget | Why |
| --- | --- | --- | --- |
| every input from `ccv_rcu_miu_addr`, `ccv_dcu_miu_rsp` and `ccv_dcu_miu_cred` | in | arrival 0 | interface capture flops; MIU's ends stay at 0 NGD (A-61, RI-11) |
| miu\_cap, miu\_pair, miu\_form, miu\_rcap, miu\_lead, miu\_a2, miu\_rsp, miu\_out, miu\_ids, miu\_hitq outputs, miu\_mq issue\_mask | out | 0 | straight from flops; a flop that also feeds logic inside has a `(* keep *)` copy for the port |
| miu\_agu8 inputs, miu\_lead inputs | in | arrival 0 | from miu\_cap and miu\_pair flops; the adders take the whole 25 (about 18 for the sum, 2 for the window level, 4 for the leader's operand mux) |
| miu\_form inputs from miu\_pair, miu\_mq and miu\_rsp | in | arrival 0 | from flops: miu\_pair's pe and pv from (\* keep \*) copies of its pairing flops, miu\_mq's A1 view and its new issue\_mask output (40 × 32 bits), miu\_rsp's window fill; miu\_form's 25 hold the 40:1 issue\_mask read (about 6), the lowest lane (about 5) and the 128:1 window read (about 8), fanout terms included |
| miu\_form inputs from ccv\_rau\_miu\_cta | in | arrival 0 | interface capture flops (A-61, RI-11); the table write and its add are the next cycle's logic, behind the captured valid |
| miu\_pair pen\_cm03h; miu\_form's pen\_cm03h input | out; in | 3; arrival 3 | the OR of the paired row's valid bits (about 3), from its own (\* keep \*) copies of the row-valid flops; lands straight in miu\_form's enable flop (CG-5) (MI-22, MA rev 187) |
| miu\_agu8 inputs from miu\_form | in | arrival 0 | win and fsel's slot bit from per-octet (\* keep \*) copies; the slot form's 2:1 base mux before the ordinary adder adds 1 to the adder's 25 (MI-22: 23.3 measured, about 24.3), fanout terms included |
| miu\_tlb hit, ppn, fold, perms | out | out 0 (flops) | miu\_tlb's outputs leave flops; the L0 compare is in miu\_a2, whose in-to-flop worst is 24.7 NGD from arrival 0 with the L0 of 6 (MI-37, MA rev 206) |
| miu\_a2 inputs from miu\_tlb | in | arrival 0 | the L0 compare, PA, pa\_fold, the A2 faults and the drop OR to the payload flops, 24.7 worst; from miu\_tlb's and miu\_lead's flops at out 0 (MA rev 203) |
| miu\_agu8 lv\_cm06h, am\_cm06h, lc\_cm06h | out | required 0 | from flops. lc\_cm06h is the second (\* keep \*) copy of lanes 0 and 16's lines: each original drives its own half of the group's lanes and the page compares, the copy the other half (MA revs 209, 211); a third copy is pre-approved if miu\_a2 grows past 25 |
| miu\_a2 lv\_cm06h, am\_cm06h, lc\_cm06h (miu\_grp inside) | in | arrival 0 | the group and page compares, the OR tree, then the footprint select, to the drop flop: 25.6 without the copy (MI-40), 25.0 with it (lc 25.0, fm 24.9, lv 24.6, lq 23.5; MI-42), accepted at zero margin. Each lane is compared once with each leader it may have (lane 0, lane 16, its octet's), and F picks among three OR trees after the compares, with F derived from lq |
| miu\_ext read\_data inputs | in | arrival 1 | read\_data's fanout to 16 miu\_ext instances (one inverter stage) |
| miu\_ecc read\_data inputs | in | arrival 1 | the same fanout |
| miu\_ecc non-zero flag | out | 17 | 15.4 for the (137,128) syndrome tree (MA-29), 1 for the fanout term, 1 to spare |
| miu\_out inputs from miu\_ecc | in | arrival 17 | 8 left: OR over a memop's up to 4 slots, AND with R1's flop, the output flop's keep copy |

The slot form's base mux sits in miu\_agu8, before the ordinary adder, on miu\_form's per-octet win and select copies; not in miu\_cap, whose capture end stays at 0 NGD and which would need win a cycle before miu\_form has it (MI-22, MA rev 185).

R(ctx) is an add, not wiring (MI-23, MA rev 186). The ISA guarantees only that W is a multiple of CCV\_PRIV\_WINDOWS, and the natural alignments wiring would need for O-69 and O-83 cannot both hold with W = local\_base + 3·CCV\_LANE\_CONTEXTS. For either region, with narrow width n (22 for O-69, 21 + k for O-83) and region base B in bytes, R = ((B\_hi + ctx) << n) + B\_lo. B\_lo is the narrow carry-save level's fourth operand (+1 level, about 2 NGD). The upper part is B\_hi + ctx + c, with c the narrow adder's carry. miu\_form stores per CTA and region, at the table write, B\_lo, B\_hi's ctxw-bit field f, and the upper part U and U + 1. At H−1, beside the issue-mask chain, it adds f + ctx with carry-in 0 and 1, and each carry selects U or U + 1 (about 10 NGD). It flops both R\_hi candidates at H, and the AGU path selects on c. That is about 900 table flops more. Control: a local\_base not naturally aligned, which a wiring form fails. miu\_form flops rk {ctx, hi + 1, hi, lo8, bl} per slot, and the ctx add sits in miu\_agu8 beside the narrow sum: lo8 + ctx + c, carry-selected per lane on the narrow carry c, each carry choosing hi or hi + 1 (MI-22, MA rev 187).

The forms take no adder of their own (MI-25, MI-26, MA rev 195; MI-24's A2 select withdrawn). With S each lane's ordinary sum, kept exact, an interleaved lane's b is S − (W << 16); W is a multiple of 2^k, so F-ADDR is S >> (16 + k) ≠ W >> k (at A2, a fault only), and an in-range b is S's low 16 + k bits. Its address R(ctx) + {b >> 2, l, b\[1:0\]} is wiring below bit 16 (the page offset, line and set bits); only the leader's VPN takes a (5 + k)-bit add into R's field, carry-selected between R\_hi and R\_hi + 1. A local lane's address is C | (l << 2), C = ((local\_base + LC) << 16) + (ctx << 22) + 128·⌊disp/4⌋ + disp mod 4 per slot in miu\_form; O-69's offset is unsigned 17-bit, so 128·⌊b/4⌋ < 2^22 never reaches the ctx field. miu\_agu8 measured 24.5 NGD, 412 flops.

**The drop (MA-27; AR 400, DI-12).** A first-pass valid at H+1 is decided from A1 alone: a global load on that footprint slot whose bank has at least CCV\_DCACHE\_LOOKUPS entry credits after this cycle's spends. A bank below that holds the load at A1, which loses the contract through A2's no-hit. The gate (MI-17, MA rev 144): miu\_cred flops ge1\[b\] (count >= CCV\_DCACHE\_LOOKUPS) and ge2\[b\] (count >= 2 x CCV\_DCACHE\_LOOKUPS) from its count net of every spend already launched and every refund. miu\_lead's own flop used\[b\] marks a launch to bank b this cycle, which miu\_cred has not counted yet. A1 gates on used\[b\] ? ge2\[b\] : ge1\[b\], one mux on flops. The valid spends its bank's entry credit. A2 sets drop on a TLB miss, a fault, a page split, a bank-conflict loser, a duplicate leader line (A1 has no line compare; MI-19 (3)), a lane off its leader's line (drop\_line, which drops all of the load's lookups) or an older-store overlap found at A2 (drop\_held; a hold A1 knows from flopped state, a fence, an atomic hold or a write in flight, launches no valid at all). miu\_cred then refunds that credit from miu\_a2's flopped drop, and DCU never returns it: ent\_ret returns only lookups that entered DCU's queue. A dropped lookup gets no req\_id and no response, and its line goes out again from the MQ in a later pass. Bins: a drop for each cause. Controls: dcu-drop-answers, and a DCU that keeps a dropped lookup's credit; both must fail. Price (MA rev 149): the A1 hold fires 0 times on S1, cm32priv and cm128priv at defaults, and the duplicate drops cost at most 0.008% against an ideal A1 dedupe, so A1 has no line compare.

**The hit's ECC check (MA-28 (c); AR 401).** ccv\_dcu\_miu\_rsp carries the stored (137,128) check bits of every code word in a slot's line, 72 bits a slot (MA-29, AR-404; MACRO-1's 137-bit word). miu\_ecc computes the syndrome in R2, and its flag is the OR over every code word the slot carries. A memop's completion is withheld if any of its slots' flags is set, so `CCV_LAT_L1_ECC` stays 1. On a CE MIU corrects the slot's data itself from the response and check bits it holds, and delivers the corrected data and the completion to the withheld slots as a refill delivery (MA rev 148, DI-18; TI-513 (2)). DCU sends nothing more: it computes the same syndrome over the same scope, counts the CE and rewrites the line, and its req\_id frees with its one response as usual. A UE follows AR 370. A recovered one (a clean line) is answered twice under the same req\_id: the first answer's flag withholds the completion and MIU keeps the id live, and DCU then refetches the line and sends a second answer from the fill, with hit = 0 and no new credit, which MIU takes as a refill and completes from (DCU tab, slice 2 part 4). On a core-fatal path no second answer comes, and MI-8's quiescence exemption (AR 389) covers the id. The models check that the withheld slots equal the slots DCU counts. Controls: ecc-err-ignored, and a narrowed scope on one side (it must hang or be caught). The injection is DCU's CCV\_DCU\_ECC\_INJECT, which flips a stored bit; MIU's knob goes.

## From the repository, as of Stage 3

Added 2026-09-27. Generated from `schema/interfaces.json`, the parameter packages, the S1 model and `docs/open-items.md`; the channel lists above match the schema exactly.

**Sidebands**

- **Kill:** receives the broadcast from RAU and acks with the epoch echoed once it holds no state for the killed warps and its last message on their behalf has landed (quiesced, not stopped; RA-23). Their pending loads are dropped as in a replay drain: nothing is written on ccv\_miu\_rcu\_data for them after the kill, except that a data beat already started finishes, and the ack waits for that last beat to land. Their retired stores still drain, and the ack waits for those too. kill\_ack is a level, held with its epoch until the next kill.
- **CSR:** a credited request/response port from CRU; the clock gate's override and thresholds are among its CSRs (Q-47).
- **Wake:** 8 inbound channel wakes (one per inbound channel, ccv\_dcu\_miu\_fill\_ntc's included; rtl/top/ports/ccv\_miu\_ports.svh), ORed into its clock gate's registered wake; it drives the wake of each channel it sends on, at least `CCV_WAKE_LAT` = 4 cycles before valid.
- **Clock:** `core_clk` ungated, gated inside by its `ccv_clk_gate`; `clk_gated` out to the checker bank under `CCV_CHECK` only.

### Payloads it drives

Each width comes from its parameter; the tier is the schema's: isa or arch (fixed; the tables' older label 'settled' means one of these), provisional (a placeholder a session sets), or preliminary (an encoding not yet decided). docs/payload-spec.md is the generated form and wins.

**`ccv_miu_rcu_data`** to RCU, rate 4, 1114 bits per slot (fixed latency). Load return data written into the register file. `active_mask` (echoing rcu\_miu\_addr's) gates the write: an inactive lane keeps its old value. `pred_result` carries a per-lane predicate the memory op produces (cas's success), for RCU's predicate file. `phys_dst` and `phys_pred` echo the memop's, so RCU writes back without state: `load_data` to `phys_dst`, `pred_result` to `phys_pred`. `pred_we`, set by MIU from the op (cas, not a load), says whether `pred_result` is written at all -- without it a stateless RCU would clobber the predicate `phys_pred` names on every load. An L1 hit's data lands at the contracted cycle, with its completion (A-47). A masked load's inactive lanes are written by its copy-only op through a lane, never by MIU, so this channel carries no merge fields (A-33).

**Its lead slice** (RA-4, agreed at AR rev 262; RA-40, built at b85595b). On each of the four slots, six of the payload's own fields lead: MIU drives them with the slot's valid, a cycle ahead of the rest of the payload. They are `phys_dst` (`CCV_P_W_PHYS_REG`, 8 bits), `dst_pos` (2), `dst_width` (2), `active_mask` (`CCV_W_LANE_MASK`, 32), `phys_pred` (6) and `pred_we` (1), 51 bits a slot. They are the fields themselves, not copies, so the channel adds no wires: 1,114 bits a slot and 4,469 wires, as before.

- **Where they come from.** Each is the memop's own value, from MIU's flops, which hold it from the memop long before the data. They are binding once sent and zero when the slot's valid is clear.
- **Why RCU needs them early.** MW writes the PRF in T, the cycle the payload lands. Its row predecode, bank enables, position shift, lane mask and predicate write enable must come from RCU's own flops (CG-5), so RCU flops these fields at T-1. The same flops select RCU's forward of hit-load data into an R op that reads in that cycle (RA-39 (i)).
- **What it costs.** No wires. Nothing moves on an L1 hit, since valid already leads the data by a cycle. MIU's cost is having 204 of its output bits (51 a slot) ready a cycle early, from flops it already holds, and the select depth behind them. A replay drain sends no write, so it is unaffected.
- **No copies.** The payload carries the six fields once, in the lead (TI's choice at b85595b, AR's preference at rev 278). RCU reads them only from the lead, at T-1.
- **No warp field.** The lead carries none, so a killed warp's late write lands and is credited as usual (AR rev 262).

**One GPR write per section per cycle** (AR, decided with RA's write-port count). Coincident slots on this channel write disjoint sections: no two slots in one cycle name the same section of any row, whichever rows they write. MIU guarantees it when it schedules data beats. RCU relies on it twice: MW needs only one write port per section bank, and the forward needs only one select per section. A top-level assertion checks it on the channel.

| Field | Bits | Width from |
| --- | --- | --- |
| `rob_tag` | 7 | `CCV_P_W_ROB_TAG` (provisional) |
| `active_mask` | 32 | `CCV_W_LANE_MASK` (isa), lead |
| `pred_result` | 32 | `CCV_W_LANE_MASK` (isa) |
| `phys_dst` | 8 | `CCV_P_W_PHYS_REG` (provisional), lead |
| `dst_pos` | 2 | `CCV_W_PHYS_POS` (arch), lead |
| `dst_width` | 2 | `CCV_W_CHWIDTH` (isa), lead |
| `phys_pred` | 6 | `CCV_P_W_PHYS_PRED` (provisional), lead |
| `pred_we` | 1 | literal, lead |
| `load_data` | 1024 | `CCV_W_DATA` (isa) |
| **total** | **1114** | 21 provisional; 51 lead bits (RA-40) |

**`ccv_miu_ooe_cmpl`** to OOE, rate 4, 120 bits per slot (ordering none, fixed latency). Completion, replay, fault and MLC miss. The miss indication is the primary demotion trigger, which is why it rides the completion path rather than its own channel. Every memop MIU accepts gets exactly one completion, including a store later bulk-discarded; the bulk-discard command itself gets none (A-41, A-53). An L1 hit completes at exactly `CCV_LAT_L1_HIT`; no completion at that cycle is the miss indication. Past L1 nothing is contracted, and scratchpad loads and atomics never wake dependants speculatively (A-46). Each completion echoes the 2-bit row index its memop carried on ccv\_ooe\_miu\_memop, so OOE's ROB sets that row's done bit (OA's rev 282, OI-85; RCU's dones carry the same field). MIU never discards or replays an atomic's A1 or A3: their completion status is 0 or 1, and a nonzero status on A1 is a fault (IS-21; OA's rev 380, OI-127, V-72; TI writes it into the schema text with an assertion). A miss on A1 only completes it later.

**lead\_fault on `ccv_miu_ooe_cmpl` (OA rev 376, OI-125; AR rev 314; schema row TI 5a2f4aa).** It is one bit per completion slot, a lead sent in the same cycle as that slot's valid, a cycle ahead of its payload, as RCU's `lead_br_taken` is. It is set exactly when the completion's `status` is 1 (fault), and never for 2 (replay) or 0 (complete). OOE gates its fault capture (the V-74 register and the per-entry cause) on it, which keeps that capture CG-clean. MIU drives it from its own flops. All of MIU's execute faults (F-ALIGN, F-ADDR, F-SHARED, F-RO) are decided by the address check, stages before any completion, so the bit is known in time. MIU settles a completion's status no later than the cycle it sends the valid, including a bulk discard racing a normal completion (A-41); a discard that arrives after the valid has gone does not change that completion. A faulting memop is never an L1 hit, so `ccv_miu_ooe_cmpl_hint` is unaffected. Asserted at OOE: `lead_fault` == (`status` == 1) on every slot.

| Field | Bits | Width from |
| --- | --- | --- |
| `rob_tag` | 7 | `CCV_P_W_ROB_TAG` (provisional) |
| `done_row` | 2 | literal (OI-85) |
| `rs_idx` | 6 | `CCV_P_W_RS_IDX` (provisional) |
| `status` | 2 | `CCV_W_STATUS` (arch) |
| `cause` | 4 | `CCV_W_FAULT_CAUSE` (arch) |
| `lane_mask` | 32 | `CCV_W_LANE_MASK` (isa) |
| `address` | 64 | `CCV_W_VA` (arch) |
| `mlc_miss` | 1 | literal |
| `more` | 1 | literal (AR-21: A3 with lanes left) |
| `lead_fault` | 1 | literal, a lead field (OI-125) |
| **total** | **120** | 13 provisional |

**`ccv_miu_spm_req`** to SPM, rate 4, 1479 bits per slot. Scratchpad access with a per-bank address set. Bank conflicts resolve inside SPM. `byte_mask` is already ANDed with the instruction's `active_mask`: a predicated-off lane's bytes are never enabled, so SPM needs no lane mask of its own. That is now a stated rule of the channel (A-20); it becomes an MIU assertion when MIU is RTL.

| Field | Bits | Width from |
| --- | --- | --- |
| `req_id` | 5 | `CCV_P_W_REQ_MIU_SPM` (provisional) |
| `bank_addr` | 320 | `CCV_SPM_BANKS` (settled), `CCV_W_SPM_WORD` (settled) |
| `write_data` | 1024 | `CCV_W_DATA` (settled) |
| `byte_mask` | 128 | `CCV_W_DATA` (settled) |
| `spm_op` | 2 | `CCV_L_W_SPM_OP` (preliminary) |

**`ccv_miu_dcu_req`** to DCU, rate 4, 1214 bits per slot. Cache access, physically addressed, with the exclusive-ownership request for atomics, and the store data with its byte mask.

| Field | Bits | Width from |
| --- | --- | --- |
| `req_id` | 6 | `CCV_P_W_REQ_MIU_DCU` (provisional) |
| `phys_addr` | 48 | `CCV_P_W_PA` (provisional) |
| `size` | 3 | `CCV_W_ACCESS_SIZE` (settled) |
| `coh_op` | 4 | `CCV_L_W_COH_OP` (preliminary) |
| `exclusive_req` | 1 | literal |
| `write_data` | 1024 | `CCV_W_DATA` (settled) |
| `byte_mask` | 128 | `CCV_W_DATA` (settled) |

The set-index lead (9 bits a slot, AR 362 and AR 364) joins this channel with TI-449; the schema wins until then.

**`ccv_miu_fet_itlb`** to FET, rate 1, 64 bits per slot. Walker returning an ITLB entry.

| Field | Bits | Width from |
| --- | --- | --- |
| `itlb_refill` | 64 | `CCV_L_W_ITLB_ENTRY` (preliminary) |

### Width and wires per channel

Wires count each slot's valid, credit and stall with its payload, times the rate, plus the channel instance's wake; the trace sideband is excluded. MIU terminates 21,691 inbound and 15,902 outbound wires (schema at 8dccb77; ccv\_miu\_ooe\_cmpl at 120 bits, 493 wires). RA-40's lead slice (b85595b) leaves both unchanged: it sends six of ccv\_miu\_rcu\_data's payload fields a cycle early and adds no wires.

| Channel | Dir | Peer | Rate | Bits per slot | Wires |
| --- | --- | --- | --- | --- | --- |
| `ccv_rcu_miu_addr` | in | RCU | 4 | 3111 | 12,457 |
| `ccv_ooe_miu_memop` | in | OOE | 4 | 126 | 517 |
| `ccv_ooe_miu_retire` | in | OOE | 4 | 8 | 45 |
| `ccv_spm_miu_rsp` | in | SPM | 4 | 1033 | 4,145 |
| `ccv_dcu_miu_rsp` | in | DCU | 4 | 1033 | 4,145 |
| `ccv_fet_miu_itlb_req` | in | FET | 1 | 60 | 64 |
| `ccv_rau_miu_cta` | in | RAU | 1 | 277 | 281 |
| `ccv_dcu_miu_fill_ntc` | in | DCU | 4 | 6 | 37 |
| `ccv_miu_rcu_data` | out | RCU | 4 | 1114 | 4,469 |
| `ccv_miu_ooe_cmpl` | out | OOE | 4 | 120 | 493 |
| `ccv_miu_spm_req` | out | SPM | 4 | 1479 | 5,929 |
| `ccv_miu_dcu_req` | out | DCU | 4 | 1214 | 4,869 |
| `ccv_miu_fet_itlb` | out | FET | 1 | 64 | 68 |
| `ccv_miu_ooe_cmpl_hint` | out | OOE | 4 | 13 | 65 |
| `ccv_miu_rau_ready` | out | RAU | 1 | 5 | 9 |

### What the S1 model does today

The AGU: window shift, scale and the sign-extended displacement applied to the base and per-lane index RCU sends, with the slot, local and private-window forms. One line request per 128-byte line to DCU. Up to four jobs in flight, but start() begins one a cycle, in the order committed stores, then an atomic's A3, then the head of one global order, so a held load blocks every memop behind it, every warp. A job holds its pipe from start to completion, misses included. No TLB (VA is PA), no coalescer, no sized buffers and no F-ALIGN check. It models faults, windows, SPM and atomic passes, the st.pred drain, hints, replay and orphans; touches only active lanes; echoes `phys_dst` and `phys_pred` back to RCU with the data. This is the C++ functional stub behind the same ports (`sim/skel/kernel.cpp`); its timing is a placeholder.

### Registered items touching this block

- **Q-18** (closed 2026-11-04): the AGUs stay in MIU; RCU→MIU is about 12,460 wires, a floorplan adjacency (Q-42).
- Undecided encoding: `CCV_L_W_MEM_OP` = 4 (preliminary, churn med): 0 load, 1 store, 2 atomic-read (A1), 3 atomic-write (A3), 4 ld.pred, 5 st.pred, 0xE fence, 0xF OOE's bulk discard; 6 to 0xD spare. The ISA has no prefetch, so there is no prefetch code (OA's response IS-11).
- Encoding: `CCV_L_PAGE_SHIFT` = 16 and `CCV_L_W_ITLB_ENTRY` = 64 (preliminary, churn low): 64 KiB pages (MA-2) and an ITLB entry of physical page number, permissions and valid, with no ASID (MA-10); the MMU session confirms both.
- Decided encoding: `CCV_L_W_SPACE` = 1 (isa, IS-11): .global or .shared. .const and .local are .global addresses (F-RO's range; O-69's local form).
- Decided encoding: `CCV_L_W_ORDERING` = 5 (isa, IS-11), non-zero only on a fence (`mem_op` 0xE).
- Undecided encoding: `CCV_L_W_SPM_OP` = 2 (preliminary, churn low): scratchpad bank access, read, write, and room for a read-modify variant.
