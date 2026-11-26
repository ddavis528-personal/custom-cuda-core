<!-- design-snapshot url=https://claude.ai/artifact/DJeg9Hh8rkPDecq4hrAz35 tab=DCU rev=147 exported=2026-11-26 status=living -->
> **Snapshot: do not edit.** Exported from *CCV per-block architecture specs*, tab *DCU*, at revision 147 on 2026-11-26 ([live doc](https://claude.ai/artifact/DJeg9Hh8rkPDecq4hrAz35)). The live doc is the source; it is a living document, so this copy is refreshed whenever it changes. This copy pins what the repo was built against; see [README.md](README.md).

# DCU — L1 data cache

**Owner: MA** (MIU and DCU architecture), from 2026-11-10, at Daniel's request (register, DA tab, 2026-11-10, second row); DI implements the DCU from MA's handoff when the architecture is ready. AR wrote this tab until then; from MA's first edit, only MA edits it, and AR sends cross-block text as a row with MA in Needs. MA's handoff is `docs/miu-arch.md` in custom-cuda-core, which lists the DCU's open questions with the MIU's.

Block C, `ccv_dcu`, one instance. The L1 data cache: 4 lookups per cycle (`CCV_DCACHE_LOOKUPS`, tunable) and a probe and invalidate port. Physically addressed, with no notion of a warp. Lines are `CCV_P_LINE_BYTES` = 128 bytes.

Drafted 2026-09-27 from the repository at Stage 3. Everything under **Scope and ports** is generated from `schema/interfaces.json` and the parameter packages, so it is settled; **Internals** holds MA's Phase 1 architecture (decided 2026-11-15), which DI implements. Ports and payloads were rechecked against the schema on 2026-11-04 (AR).

## Scope and ports

**In**

| Channel | From | Rate | Bits per slot | Wires | What it carries |
| --- | --- | --- | --- | --- | --- |
| `ccv_miu_dcu_req` | MIU | 4 | 1214 | 4,869 | Cache access, physically addressed, with the exclusive-ownership request for atomics, and the store data with its byte mask. |
| `ccv_mlc_dcu_rsp` | MLC | 1 | 1030 | 1,034 | Line fills and ownership grants back to L1. |
| `ccv_mlc_dcu_probe` | MLC | 1 | 51 | 55 | Inbound invalidate or downgrade: unsolicited, and a wake source, since a sleeping D-cache must still answer. |

**Out**

| Channel | To | Rate | Bits per slot | Wires | What it carries |
| --- | --- | --- | --- | --- | --- |
| `ccv_dcu_miu_rsp` | MIU | 4 | 1033 | 4,145 | Cache read data, hit indication and whether ownership was granted, and `mlc_miss`: the fill that served this access missed in MLC (`ccv_mlc_dcu_rsp`.miss, passed through). |
| `ccv_dcu_mlc_req` | MLC | 1 | 1082 | 1,086 | Fills and writebacks from L1 to the shared cache, tagged with core ID. |
| `ccv_dcu_mlc_probe_ack` | MLC | 1 | 1027 | 1,031 | Probe response, carrying dirty data when the line was modified. |
| `ccv_dcu_miu_fill_ntc` | MIU | 4 | 6 | 37 | A refill notice: the req\_id of an MIU request whose refill leaves on the same slot of ccv\_dcu\_miu\_rsp, valid exactly CCV\_LAT\_FILL\_NOTICE cycles after this payload lands. Fixed latency (OA-23, TI-23). |

Wires count each slot's valid, credit and stall with its payload, times the rate, plus the channel instance's wake; the trace sideband is excluded.

**Sidebands**

- **Kill:** not a recipient. DCU is physically addressed and holds no warp-tagged state.
- **CSR:** a credited request/response port from CRU; the clock gate's override and thresholds are among its CSRs (Q-47).
- **Wake:** 3 inbound channel wakes, ORed into its clock gate's registered wake, the probe's among them; it drives the wake of each channel it sends on, at least `CCV_WAKE_LAT` = 4 cycles before valid.
- **Clock:** `core_clk` ungated, gated inside by its `ccv_clk_gate`; `clk_gated` out to the checker bank under `CCV_CHECK` only.

## Payloads it drives

Each width comes from its parameter; the tier says whether it is fixed (settled), a placeholder the session sets (provisional), or an encoding never decided (preliminary).

**`ccv_dcu_miu_rsp`** to MIU, rate 4, 1033 bits per slot. Cache read data, `hit` indication and whether ownership was granted, and `mlc_miss`: the fill that served this access missed in MLC (`ccv_mlc_dcu_rsp`.miss, passed through). MIU reports it on `ccv_miu_ooe_cmpl`, since an MLC miss is the primary demotion trigger; without this field the signal stopped at DCU (A-9).

| Field | Bits | Width from |
| --- | --- | --- |
| `req_id` | 8 (6 until TI applies MA-34) | `CCV_P_W_REQ_MIU_DCU` (provisional) |
| `read_data` | 1024 | `CCV_W_DATA` (settled) |
| `hit` | 1 | literal |
| `ownership_granted` | 1 | literal |
| `mlc_miss` | 1 | literal |

**`ccv_dcu_mlc_req`** to MLC, rate 1, 1082 bits per slot. It carries no byte mask, so a partial store cannot leave DCU as it arrived.

| Field | Bits | Width from |
| --- | --- | --- |
| `req_id` | 7 (4 until TI applies MA-34) | `CCV_P_W_REQ_DCU_MLC` (provisional) |
| `phys_addr` | 48 | `CCV_P_W_PA` (provisional) |
| `coh_op` | 4 | `CCV_L_W_COH_OP` (preliminary) |
| `core_id` | 2 | `CCV_W_CORE_ID` (settled) |
| `writeback_data` | 1024 | `CCV_P_LINE_BYTES` (provisional) |

**`ccv_dcu_mlc_probe_ack`** to MLC, rate 1, 1027 bits per slot.

| Field | Bits | Width from |
| --- | --- | --- |
| `req_id` | 2 | `CCV_P_W_REQ_MLC_PROBE` (provisional) |
| `ack` | 1 | literal |
| `dirty_data` | 1024 | `CCV_P_LINE_BYTES` (provisional) |

**`ccv_dcu_miu_fill_ntc`** to MIU, rate 4, 6 bits per slot. A refill notice (OA-23, TI-23): the refill answering `req_id` leaves on the same slot of `ccv_dcu_miu_rsp`, its valid exactly `CCV_LAT_FILL_NOTICE` cycles after this notice's payload lands. A channel of its own, so its payload register is enabled by its own valid flop (CG-5).

| Field | Bits | Width from |
| --- | --- | --- |
| `req_id` | 8 (6 until TI applies MA-34) | `CCV_P_W_REQ_MIU_DCU` (provisional) |

## What the S1 model does today

A small L1: `CCV_DCU_SETS` sets (default 512 from TI 447; 64 before) of `CCV_DCU_WAYS` ways (default 8 since TI's 31168a3; it was 1 before, and CCV\_DCU\_WAYS=1 restores it for a comparison), LRU, write-back and write-allocate with ownership as below. A hit answers the cycle it arrives; a refill sends its notice on `ccv_dcu_miu_fill_ntc` and holds back its slot's credit until the promised cycle. Non-blocking: one request to MLC per `req_id` in flight, and a line with a miss in flight takes nothing more until it is answered. One core, so nothing probes. This is the C++ functional stub behind the same ports (`sim/skel/kernel.cpp`); its timing is a placeholder, and the RTL replaces it at Stage 4.

## Internals, mechanisms, risks

**MA's Phase 1 architecture (MA, 2026-11-13; agreed by AR at AR rev 344 for MA-3, MA-7, MA-8 and MA-12; MA-15 carries the parameters to TI; L1 size and the block partition set by Daniel, DA rev 121).** The rows that decide it are MA-1 to MA-14 in the register's MA tab; the MIU tab's Phase 1 architecture section holds the matching MIU side. MIU and DCU stay separate blocks in the first implementation; a merge, tags inside MIU or a direct return to OOE is a Phase 2 decision (MA-9 closed, DA rev 121). DCU's hit pipeline is three stages, D1 to D3, and it must decide a hit in two of them.

- **Geometry.** 512 KiB: 8 ways, 512 sets of 128-byte lines. The design is built for 512 KiB (Daniel, 2026-11-15; register MA rev 61, superseding MA 60's 64 KiB baseline). 128 and 64 KiB are configured-down points that reduce sets only: they reuse the same pipeline and keep the 512 KiB hit latency. A hit latency that follows the configured size is deferred to PF-51 (Daniel, 2026-11-15). The tag index, data banks and hit path are timed at 512 KiB. On -priv, cm128priv runs 1,925,434 cycles at 512 KiB, against 2,132,774 at 64 KiB (AR 360). The set index is sent as a lead field (the MIU tab's L1-hit budget, B). The hit latency follows the arrays chosen in MA-23 (Daniel, DA rev 128): `CCV_LAT_L1_HIT` = 8 with way prediction on and 9 with it off, derived from `CCV_DCU_WAYPRED_BITS` (MA-26; the arrays item below). Sets and ways are parameters (`CCV_DCU_SETS`, `CCV_DCU_WAYS`, MA-15); `CCV_DCU_SETS` is 512 (TI 447).
- **Ports.** Tags for 4 lookups a cycle: 4,096 entries (512 sets × 8 ways) × 34 bits (tag and 3 state bits; the dirty bits are in flops, slice 2 part 3; the index grows 3 bits from 64 sets, so the tag shrinks 3), held once in a 1R1W register file banked like the data, 8 banks of 512 entries, so a lookup reads only its own bank's tags (DA rev 123, MA-16). Data in 8 single-ported SRAM banks by line address bits \[9:7\], the set index's low 3 bits, 64 KiB each, reading a whole 1,024-bit line; a bank takes one access every other cycle (`CCV_DCU_BANKS` = 8, AR 364). Same-cycle lookups that collide on a bank, or find it still busy, go in slot order. The loser's response is not a hit at the contracted cycle, and it answers later as a miss would (MA-7). A loser waits at most `CCV_DCU_BANK_AGE` cycles (16 to start; the Phase 1 model sets it): once a waiter reaches it, its bank takes no new lookup or fill until that waiter is served (AR 364).

  Bank queue and deferred stores (MA-24, MA-25; Phase 1 sweep MA-7; AR 382). Each bank holds up to 16 lookup entries (CCV\_DCU\_BANK\_QDEPTH) and up to 12 store-data entries (CCV\_DCU\_BANK\_STDATA). Both are hard reservations kept by MIU as per-bank credits, so DCU never refuses a request and never holds more than they allow. A store hit uses MA-17's variant (b). Its read and write wait in the bank's queue as deferred work under the age bound, holding the store's data and byte mask, with a read-to-write gap of 5 cycles, since SECDED's corrected read takes 2 stages (TI-483). DCU returns credits to MIU as two per-bank vectors: an entry credit when a lookup entry leaves the queue, and a store-data credit when a store's write leaves. Each bank returns at most one of each a cycle. Both vectors ride ccv\_dcu\_miu\_cred (DCU to MIU, rate 1; ent\_ret and std\_ret, CCV\_DCU\_BANKS bits each), landed with the two params under MA-25 (TI-506). A fill uses its own fill buffer, not these entries. On cm128 at gap 5, credits run 5,130,918 cycles, 1.47% faster than variant (a) at depth 16 and 0.10% faster than the soft cap with re-pass. Loads-first arbitration was neutral and rotating arbitration gained nothing at depth 16, so neither is taken; arbitration is slot order, as above.
- **Hit pipeline, from the index lead held at H+2, with the PA held at H+3 for the tag compare (the MIU tab's L1-hit budget, B).** D1 reads tags and the bank. D2 compares 8 ways and flops hit and way, which is the response's valid. D3 selects the way's 1,024 bits, the response's payload. The read on the lead is speculative (AR 362 (3)): D1 reads, but nothing changes state, LRU included, until the payload at H+3 confirms the request; a lead without a payload leaves no trace. A store hit to an owned line merges in DCU, since the data SRAM takes whole-word writes only (DA, 2026-11-17, TI-466; MA-17). Its own lookup has already read the whole line. dcu\_bstm corrects that line, merges the store's bytes under its byte mask, encodes it, and writes it back whole to its bank, read to write 5 cycles, which sets the line's dirty bit in dcu\_bctl's flops (slice 2, part 3). A store therefore takes two bank slots, one for its read and one for its write. A later lookup to the same line waits for that write; other lines in the bank do not wait. A partial store that misses merges its bytes into the fill buffer's line before the fill writes it.
- **Miss buffers: 128, 16 a bank** (`CCV_P_W_REQ_DCU_MLC` = 7, req\_id {bank, entry}; 128 lines in flight cover a 1,000-cycle DRAM at the bandwidth AR 412 asked for: MA-31, Daniel's B, DA rev 136). Each holds a line and up to 4 merged MIU requests. DCU holds `ccv_miu_dcu_req` only when every buffer is in use or a line's merge list is full (MA-12 narrows TI-22's statement).
- **Fill path.** A fill from MLC waits in a fill buffer and writes its line into its bank only in a cycle with no lookup to that bank (AR's MA-7 ask), and answers its merged requests from the fill's own data, so no read follows the write. Each answer may be noticed. Fill to response has at least `CCV_LAT_FILL_NOTICE` = 4 cycles from the cycle the fill's payload lands (F), enough for the line write, so an un-noticed answer leaves at F+4. A noticed one leaves exactly CCV\_LAT\_FILL\_NOTICE after its notice lands, F+6 with the notice sent at F: a notice costs its refill 2 cycles (DI-4; MA rev 129-132).
- **Eviction.** LRU over 8 ways. A dirty victim goes out whole on `ccv_dcu_mlc_req` from a 2-entry writeback buffer, which a probe also searches.
- Probes look up tags on a fifth, lower-priority tag port. They never cancel a promised response. A page-table walk's lookup (MA-8) uses a slot no first pass uses, so walked tables cache here and probes keep them coherent.

  Arrays and the hit pipeline: option (B), tag then data, with way prediction (C) as a parameter (Daniel, DA rev 128, closing MA-23; params MA-26). The array rules are DA rev 123 (MA-16): SRAM is single-port 1RW only, accessed at most every other cycle, with a 2-cycle read. An array read and written every cycle is a register file, 3× an SRAM's area per bit. **Data:** each 64 KiB bank is 8 `ccv_common_sram_1rw` instances of 512 words × 137 bits: 128 data bits and 9 SECDED bits, with ECC outside the wrapper (TI-474, TI-475). A word is addressed by {set within the bank, way}, and the 8 instances side by side give one way's 1,024-bit line. A lookup reads one line, never eight. Writes are whole-word with no byte mask (TI-466). A write holds the bank for its 2 cycles, and a store hit takes a read slot and a write slot (MA-17). An instance is 8,768 B, legal under TI-467 with no waiver: 64 instances in all, with a TI-469 size penalty of 16.7%. **Tags:** per bank, 2 `ccv_common_rf_1r1w` instances of 64 set words × 136 bits. Each holds four ways' 34-bit tags and state (the dirty bits are in flops, slice 2 part 3); the set's tree-PLRU bits are in flops (Phase 2, MA-30). A lookup reads both halves of its set. A fill writes the word with its new tag, and a hit never writes it. A 1R1W read of a word written that same cycle returns the old data, so DCU forwards a fill itself. **Pipeline (B), CCV\_DCU\_WAYPRED\_BITS = 0:** under the index lead, the tags are read from H+2. The tag compare picks the way, which addresses the data bank at H+4, and the data is valid at H+6, so CCV\_LAT\_L1\_HIT = 9. **Pipeline (C), WAYPRED\_BITS = k > 0:** a per-bank fold table of 64 × (8 × k) bits, in flops (MA-30), holds a k-bit fold of each way's tag. It is read on the lead and compared with MIU's pa\_fold in the payload cycle, so the predicted way's line is read in parallel with the tag compare, and CCV\_LAT\_L1\_HIT = 8. A hit on another way is a mispredict. It re-reads the true way with a second bank access. The bank took the predicted read at H+3 and takes one access every other cycle, so the re-read starts at H+5 at the earliest, and its data is valid at H+7, due + 2. A mispredict therefore takes the bank-conflict loser's path: it is not a hit at the contracted cycle, and it answers later as a miss would. TI-478's late-hit slot stays at due + 1, and OOE is unchanged (DI-2; AR 390, OA-442, MA rev 118). Among the ways whose fold matches, CCV\_DCU\_WAYPRED\_SEL = index picks the lowest way (recent is dropped with the LRU bits' move to flops). The defaults are k = 4 with index (MA-30, repriced on the MIU and DCU models; AR 405 agreed), replacing k = 5 with recent (AR 386, MA rev 112). A miss is known from the tags either way. The model counts bank conflicts, busy-bank waits, age-bound holds, fill-lookup collisions and way mispredicts apart.
- ECC, BIST and repair follow DA's rulings TI-474 and TI-475. Every SRAM carries SECDED, (137,128) per 128-bit word (MA-29, AR-404), so a bank's data is 8 instances of 512 × 137 bits, each built with a column mux of at least 4. Each counts as 8 KiB, since TI-475 sizes an array by its logical bits before ECC and repair, so no waiver is needed. ECC sits outside the SRAM wrapper, which holds only the BIST override and repair. A hit's data leaves at CCV\_LAT\_L1\_HIT (8 with way prediction, 9 without) uncorrected. With it, ccv\_dcu\_miu\_rsp carries the stored (137,128) check bits of every code word in the slot's line, 72 bits a slot (MA-28 (c), AR 401, MA-29). MIU computes the syndrome in its R2 and withholds the completion, which goes CCV\_LAT\_L1\_ECC (1) cycle after the data, so CCV\_LAT\_L1\_CMPL is 16 at hit 8 (AR-368, OA-424). A non-zero syndrome withholds the completion, so OOE takes the load as a miss. DCU computes the same syndrome from the flop behind the macro, about 15 NGD, over the same scope: the OR over every code word the slot's response carries. DCU counts exactly the slots MIU withholds, and the models check that the two sets agree. DCU then corrects and rewrites the line, holding the bank like an RMW, and sends nothing more: MIU corrects the data it already holds and delivers it as a refill (MA rev 148, DI-18; TI-513 (2)). A UE follows AR 370. The fill path keeps RA-28 (a) and lands the data no later than the completion (RA 153, MA rev 79). A store's merge reads corrected data: the read-to-write gap is 4 cycles, not 3 (AR-367). A merged line or a fill is flopped and then encoded in a stage of its own, so only a flop drives wdata. The tag register files carry no ECC. Every instance has one spare row in flops outside the array (137 flops a data instance, 140 a tag instance). Column repair and the BIST broadcast groups (up to 32 KiB) are restated for the 8 KiB data instances in slice 2, against TI-475. BIST and repair controls are ported up to the block wrapper and tied off until BIST insertion. Corrected and uncorrectable error events go to the architectural fault system that AR is defining (TI-475 (4)). The injection is DCU's: CCV\_DCU\_ECC\_INJECT flips a stored bit (AR 401), and MIU's knob goes. A dedicated test covers a double-bit error. Controls: ecc-err-ignored, and a scope narrowed on one side (it must hang or be caught). A dropped lookup (MA-27, AR 400, DI-12) commits nothing: on drop DCU reads no data on it, changes no state (LRU and way-predictor training included), allocates no queue entry, sends no response, and raises no CE, UE or core-fatal from any read the lead started. A real error on that line is found by the pass that reads it for a reason. DCU never returns a dropped lookup's entry credit, because MIU refunds it itself. ent\_ret returns only lookups that entered DCU's queue. Controls: dcu-drop-answers; a DCU that keeps a dropped lookup's credit; a UE injected on a dropped lookup (no MACHINE\_CHECK). All must fail.
- Machine errors follow AR 370 (DA rev 124). A corrected error (CE) is counted and never faults. An uncorrectable error (UE) in a clean line is recovered: DCU invalidates the line and refetches it as a miss, and records its location in the UE track table. The table has CCV\_DCU\_UE\_TRACK = 16 entries, one for each spare row. Each entry is a valid bit and a 13-bit location: the bank (3 bits), the instance (1 bit, from which syndrome slices failed) and the row (9 bits: the set within the bank and its way). That is 224 flops, scan only (TI-476). Entries are allocated on a recovery and cleared only by reset. A second UE at a recorded location is a hard error. So is a UE that finds the table full, since 16 distinct bad rows exceed the spare rows. Both are core-fatal. The compare runs only on a UE, already on the miss path, so it can take a cycle of its own and is off every timed path. A UE in a dirty line, in a victim's writeback read, or a hard error, raises the sticky ue level on ccv\_dcu\_cru\_err. CRU then latches MACHINE\_CHECK, kills every grid, and writes F-MACHINE into every context's record. DCU withholds the read the error hit, for containment: a load completes with no data (OA 436), and a store whose merge read was withheld never writes over the lost bytes. The machine check ends it, with nothing waiting on the store. Once MACHINE\_CHECK is latched, RAU's kill waits on no ack from MIU (it still requires the seven others; AR 389), so a retired store still held in MIU until the host's reset hangs nothing (TI-487; AR 387 and 389, OA 441, MA rev 114). A fill is encoded as it is written, so DCU cannot see a UE in one. No ue field goes on dcu\_miu\_rsp. One ccv\_common\_err serves DCU's 16 data arrays. Its CE\_COUNT and UE\_COUNT saturate and add a popcount, since up to 8 banks can report in one cycle. The first-error log holds the lowest reporting bank's array, row, syndrome, CE or UE, and track-table hit, with an overflow bit. ERR\_CTRL holds the CE alert threshold, which raises ce\_alert, and INJECT, which flips 1 or 2 bits on the next write to a named array. All of it is host-only on the CSR star (IS O-38), and the host can read the track table to map rows out at the next reset.

**Contracts set before the block's session** (AR, 2026-10-21; register OA-23, OA's acceptance at its rev 140). These bind the Stage 4 session's design:

- **The refill notice.** When a fill lands on `ccv_mlc_dcu_rsp`, DCU knows from its miss buffers which MIU requests it serves. For each one, DCU may send a notice on `ccv_dcu_miu_fill_ntc`, the fixed-latency notice channel beside `ccv_dcu_miu_rsp`: the request's `req_id` and a valid. Its refill then leaves on the same slot of `ccv_dcu_miu_rsp`, its valid exactly `CCV_LAT_FILL_NOTICE` cycles after the notice's payload lands in MIU. A notice is optional and off by default (CCV\_DCU\_NOTICE = 0, a parameter; the channel stays, its valid held low; DI-4, AR 394, OA 453-454). Sent at F it gives no earlier wake than none: MIU hints a refill only on a notice, and an un-noticed refill completes at F+6, unhinted, OOE waking on the completion itself. Measured on the model at L1\_HIT 8, notices off is -0.43% mean over the 64 oracle kernels. Once sent, a notice is a promise, not a hint. No response may slip.
- **How DCU keeps it: slot reservation.** DCU's hit pipeline, accept to response, is fixed, so DCU knows every response slot that far ahead. (`CCV_LAT_L1_HIT_BASE` is longer: it runs from MIU accepting the memop to the data leaving MIU.) It reserves the refill's slot, and its credit, when it sends the notice, so a reservation never displaces a contracted hit. If every slot at the promised cycle is already taken, DCU delays the notice, not the response.
- **The floor.** A fill's response follows the notice by at least `CCV_LAT_FILL_NOTICE`, which is CCV\_LAT\_CMPL\_HINT (2) plus CCV\_LAT\_MIU\_FILL, MIU's pass-through from a refill's response valid to its completion's valid (register TI-23). DCU's line write and data select must fit inside it. If DCU's natural fill-to-response is shorter, every noticed refill pays the difference. Then the notice is worth moving upstream, to a notice from MLC at its tag lookup (register OA-23, AR's response on TI's 12f497c). As built, a notice can leave no earlier than the fill's payload, so a noticed refill pays 2 cycles (F+6 against F+4) and notices are off by default (the refill notice, above). Phase 2: an earlier notice, from MLC's tag lookup first and a lead field on ccv\_mlc\_dcu\_rsp only if that cannot reach F+4, priced once MLC has a model; under 0.5% on S1 it is not worth a schema change (OA 453, AR 394). OA-23 stays open until then.
- **A probe between fill and response** does not cancel a promised response. The response carries the data the fill delivered.
- **Holding a request** (AR, 2026-11-04; register TI-22). DCU holds a request on `ccv_miu_dcu_req` only when all 16 miss buffers are in use, or the line's 4-entry merge list is full (MA-12). So the channel is backpressured, the class TI-22 defined, and takes `CCV_P_TIMEOUT_BP`. The schema records it: "held (DCU spec rev 15, AR-25)" on ccv\_miu\_dcu\_req.

**Write policy (AR, 2026-10-23; register TI-36): write-back and write-allocate, with ownership.** This settles the partial-store question below.

- A store that hits a line DCU owns writes its bytes into the line under its byte mask and marks it dirty. Nothing goes to MLC.
- A store that hits a shared line, or misses, acquires ownership from MLC, then merges. A miss whose byte mask covers the whole 128-byte line, a coalesced 32-lane word store, acquires ownership without data (TL-C's AcquirePerm), since every byte is overwritten. A partial miss fetches the line with ownership.
- A dirty line leaves DCU only whole: a writeback on ccv\_dcu\_mlc\_req when it is evicted, or dirty\_data on ccv\_dcu\_mlc\_probe\_ack when MLC probes it. So ccv\_dcu\_mlc\_req needs no byte mask.
- A drain's read-merge-write (st.pred, O-63) and an atomic's read-hold-write run on an owned line in DCU, so a hit makes no MLC trip.

Why: the channels were already shaped for it, with ownership grants, a writeback field and dirty data on the probe ack. Atomics need the line held exclusive in L1 (AR-21). And spills write before they read, so write-through would send every spill to MLC and every reload behind it. Lost: write-through's simplicity, with no dirty state and a probe ack that is always clean. Cost: a dirty bit a line, an eviction writeback path, and ownership state, which the grants already imply.

## Questions for the session

- Undecided encoding: `CCV_L_W_COH_OP` = 4 (preliminary, churn med): coherent line request, acquire, release, probe response, writeback, grant acknowledgement; follows the TL-C subset chosen.
- Answered: four tag lookups per cycle, multi-ported or banked with conflict serialization (the MIU tab names it the dominant NGD and area item): the tags are one register file banked with the data's 8 half-rate banks, so each lookup reads only its own bank (DA rev 123, MA-16) (Internals, Ports).
- Partial stores: settled by the write policy above. They merge into an owned line in DCU, and only whole dirty lines leave, so ccv\_dcu\_mlc\_req keeps no byte mask (register TI-36).
- Capacity is decided: the L1 is built for 512 KiB (DA rev 121), and what follows is the history that led to it; associativity is 8 ways, settled by the corpus sweep at the end of this item (TI's rev 234). The skeleton's stub defaults to 8 ways × 64 sets, 64 KiB, since TI's 31168a3 (2026-11-07; CCV\_DCU\_SETS, CCV\_DCU\_WAYS). Until then it was direct-mapped with 64 sets, and almost every timed run was measured on that: TI 373 re-baselines them. J9 showed the cost. rel-vadd16's three arrays sit in one set, and Z's one-cycle step on its loop was +26.8% at 1 way and +3.1% at 8 ways (AR revs 318–320), and TI's rope-diverged run (TI's rev 138) shows why that matters: addresses 64 KiB apart all land in one set and evict each other, as O-30's per-thread frames do. O-69 takes spills off that pattern, but address-taken frame objects and power-of-two strides keep it. The session sizes ways against a sweep of 1, 2, 4 and 8 on the corpus, the frame-object kernels among them. First input, CoreMark-derived at four warps with its per-thread state interleaved (PF-46; TI's revs 225 and 226; 64 sets of 128-byte lines; warm MLC). 8, 16, 32, 64 and 512 KiB run in 3,340,054, 3,258,477, 3,109,940, 2,838,912 and 2,636,535 cycles. So 32 to 64 KiB buys 8.7%, and 64 to 512 KiB 7.1%. The DCU-MLC req\_id pool at 64 KiB is near its knee: 8 ids cost 12.8%, and 32 buy 1.9%. The misses left at 512 KiB are mostly ownership acquires (a store to a line held shared from a load), not capacity. Uninterleaved, the same kernel's 2,000-byte per-thread stride piles up to 159 lines into one set at 64 sets, so no associativity a real L1 has sizes it (TI's rev 222). The two candidates were 64 KiB (64 sets × 8 ways) and 512 KiB (512 sets × 8 ways), each with 16 req\_ids; Daniel chose 512 KiB, with 64 and 128 KiB as configured-down points at the same latency (DA rev 121). 512 KiB is not ruled out on area: DA expects about 3 MB/mm² in the target process, so its data array is about 0.17 mm² (DA tab rev 95). It is taken if its gain holds across the corpus, not on CoreMark alone. Its hit latency must be priced with it. CCV\_LAT\_L1\_HIT\_BASE is 7 as assumed today, and an array 8× larger may cost a cycle or two. On single-thread code each cycle of L1 wake costs about 2% (AR-24), so the sweep runs 512 KiB at hit base 7, 8 and 9. The corpus sweep (TI's rev 234; six four-warp kernels, one CTA each) settles 8 ways: 1 to 8 ways is -48.9% on gemv, -33.4% on sgemm and -27.7% on rope-diverged, and 4 to 8 is still -17% on sgemm. It cannot test capacity, since each kernel holds a few KiB, so 512 KiB equals 64 KiB on all six. Where capacity does not pay, the larger array's latency is pure cost: base 9 costs sgemm 7.9%. On coremark128, 512 KiB at base 9 is still -5.9% against 64 KiB at base 7. AR's rev 229 left capacity to larger and multi-CTA exports. On coremark-derived-priv, now the baseline (AR 358), 512 KiB is 9.7% faster than 64 KiB on cm128priv (AR 360).

## MA's Phase 2: microarchitecture and module partition

**Status: slice 1, the L1-hit path, MA's (2026-11-22, DI-20).** Slice 2 follows in parts (DI-30): part 1, miss buffers and fills, part 2, eviction and writeback, part 3, stores and their merge, and part 4, probes, UE recovery, repair and BIST groups, are below, each announced to DI by a notice. Inside DCU the partition and its port budgets are MA's to decide. It meets MIU's slice 1 (the MIU tab) at `ccv_miu_dcu_req` and `ccv_dcu_miu_rsp`. Two findings change Phase 1 text: the data code is (137,128), so `check_bits` is 72 bits a slot (MA-29, AR-404 agreed; TI-517 landed); and the way predictor's fold table moves from a register file into flops, with MIU sending the line PA's fold in the payload (MA-30, AR 405 agreed; TI-518 landed pa\_fold, the defaults and the shared wayfold helper), since a fold read from a register file cannot address the SRAM in the payload cycle under the macro timing (NGD-8).

**Macro timing at DCU's shapes** (check-ngd's `macro_timing`, NGD-8). Data SRAM, 512 x 137: address setup 13.1 NGD, `rdata` launch 18.1. Tag register file, 64 x 140 (136 since slice 2 part 3, the same timing to a tenth): address setup 8.7, `rdata` launch 12.6. A fold table in a register file, read at H+2 and compared with the payload's PA fold at H+3, takes 12.6 + about 6 for the compare and pick + 13.1, over 25 before any fanout. So the table is held in flops: read on the lead at H+2 through a 64:1 select and flopped, its folds are ready at 0 NGD at H+3. The PA fold itself comes from MIU (computed in its A2), since folding the PA in DCU's H+3 would also pass 25.

### Stages of an L1 hit at `CCV_LAT_L1_HIT` = 8 (way prediction on)

H as in the MIU tab. Both links are abutted (link\_n 0, bnd\_rx 0); every DCU receiving end is no-flop, DCU's own registers capturing at 0 NGD, the payload enabled by DCU's flop of the valid. Every DCU output launches from a flop. An SRAM read addressed in cycle X has its word on `rdata` in X+2, flopped behind the macro at the end of X+2.

| Cycle | Stage | Work | Modules |
| --- | --- | --- | --- |
| H+2 | D0, lead | The req valid and `lead_set_index` held. Per bank, the lowest slot whose lead names it reads the tag RF (MIU's A2 drops every other slot on that bank, MA-27); the bank's arbitration picks this cycle's owner of the H+3 access (below); the set's 8 way folds (4 bits each) are read from the fold flops and flopped | dcu\_cap, dcu\_btag, dcu\_bctl |
| H+3 | D1, payload | The payload held: req\_id, the line's PA, its fold, drop. The predicted way is the lowest valid way whose fold equals the payload's; with none matching the lookup is a miss and the SRAM is not read (its ce cleared, the access cycle freed). Tag compare against `rdata` (8 ways), hit, way and state flopped (the way's dirty bit is in dcu\_bctl's flops, slice 2 part 3). The data SRAM is addressed with {set within the bank, predicted way}, its `ce` cleared by drop. A lookup that did not win the bank enters the bank queue unless dropped. A dropped lookup does nothing more | dcu\_cap, dcu\_btag, dcu\_bctl, dcu\_bdat |
| H+4 | D2 | Mispredict: a hit on a way other than the predicted one gets no contracted slot, so nothing goes out at the hit slot, and it claims the bank's H+5 access for the re-read (a late answer, due + 2). A fold match on a miss discards the word read. The fold table's second writer is the fill (OA-479 (b), adopted by Daniel). Its read-after-write margin holds by re-reading, never by forwarding (MA, DI-42). A lookup whose D0 row is the row a fill writes, in the write cycle or the cycle after, discards its fold compare and predicted read and takes the mispredict's re-read, a late answer at due + 2, with its fold compare redone at the re-read. The re-read is checked the same way, so it repeats if another fill writes the row, and a CHECK bounds it at 2 a lookup. A fill whose set is in a fill write's margin still takes its slot (set, fold, buffer, age) at F+3, but with no way, and reserves none. One victim snapshot is taken a cycle, from a set outside its margin: the oldest slot that still needs a way first, by DI-37's age, else the new fill's payload. A new fill that loses also waits for its way. A slot's write becomes a waiter only once it has a way, and its pick sees the other slots' reservations. A slot holds its way's reservation until its write is visible to the snapshot, the cycle after the write, not just until its grant (MA, DI-43: a snapshot in the grant cycle is outside the margin). Assertion bctl\_one\_fill\_per\_way, with a control that releases at the grant. A slot waits at most 3 x (fill slots - 1) + 2 cycles for a way, 11 at 4 slots: each older slot costs its own snapshot and its write's two-cycle margin, and a write already at W costs 2 (CHECK, with a bin of the wait; DI-44, MA rev 189). The fold table's port is shared by the port writes (fwe/fws/fwy/fwf) and the fill at W, never both in a cycle (bctl\_ft\_one\_writer, control no\_yield). A held fill yields to a port write at most once, then wins until it writes, so a port write waits at most the fill slots' count, 4 cycles, and a fill's write lands within 22 cycles of ready, against ccv\_mlc\_dcu\_rsp's 32 (CHECKs with bins; control: a fill that always yields, under a port-write flood; DI-45, MA rev 192). A port write that waits sits in a buffer in dcu\_bctl, 2 entries deep, with 4 credits to its driver (the loop's round trip; 2 are always in the stages before the buffer): the return fwcr\_cc03h is a one-cycle pulse from a flop, set the cycle after an entry writes. Assertion: no overflow (control: 5 credits, which must reach a third entry); CHECK the buffer wait at most 4 plus occupancy (DI-46, DI-47, MA rev 194). DI-37's age counts from F+2 throughout, and the bound with that wait stays under ccv\_mlc\_dcu\_rsp's 32-cycle check. Bins: lookups re-read for the margin, fills re-snapshot. Control dcu-ft-margin turns the re-read off, and bctl\_ft\_lookup\_margin must fire. A hit updates the set's PLRU bits. A miss goes to the miss buffers (slice 2). The entry credit of a lookup that read the bank at H+3 launches on `ent_ret` | dcu\_bctl |
| H+5 | D3 | The word on `rdata`, flopped behind the macro. Each response slot's valid and its bank select are decided: a contracted first-pass hit takes its own slot; a late answer takes a free one | dcu\_bdat, dcu\_rarb |
| H+6 | D4 | The rsp valid launches. Each slot's 8:1 bank route into its payload flops (read\_data, check\_bits, req\_id, hit, ownership\_granted, mlc\_miss). The syndrome of each of the bank's 8 code words (`ccv_common_secded_syn`, K = 128) from the flop behind the macro, flopped | dcu\_rslot, dcu\_bdat |
| H+7 | D5 | The rsp payload launches (lands in MIU's R2 at H+8). The syndromes are classified: zero, CE (one bit) or UE; a CE is counted and asks for a rewrite, a UE is recovered or fatal (AR 370; slice 2) | dcu\_rslot, dcu\_bdat, dcu\_err |

With way prediction off (`CCV_LAT_L1_HIT` = 9) the SRAM is addressed at H+4 with the compared way, and D3 to D5 follow a cycle later. A mispredict's re-read is addressed at H+5 and answers at H+10 in MIU's R2, due + 2, as a late answer. A lookup from the bank queue reads its line when it wins the bank and answers late the same way.

**Bank arbitration.** A bank takes one SRAM access every other cycle (`ce` never two cycles running). For each access cycle its dcu\_bctl decides a cycle ahead, from its own flops, in this order: the mispredict re-read; a queue waiter at `CCV_DCU_BANK_AGE`; the CE rewrite's read or write; the new lookup from the lead; then queue waiters, oldest first. A fill's write takes only a cycle with no lookup to the bank (slice 2). A queued lookup keeps the tag result its lead read (hit, way); a fill or eviction that writes its set makes it re-read the tags before its data (slice 2 defines the write). An entry credit returns on `ent_ret` when a lookup reads its line or leaves for a miss buffer, at most one a bank a cycle; a dropped lookup never enters the queue and returns none (MIU refunds it, DI-12).

**Response slots.** A contracted first-pass hit answers on the slot its request came in on, at its contracted cycle, and always gets it. Late answers (queue waiters, re-reads, and slice 2's fills) take the slots left, lowest bank first. A late answer that finds no slot keeps its word in the flop behind the macro, and its bank takes no new read until it leaves.

**The CE rewrite (DI-18).** dcu\_fix holds one rewrite and one pending request; a CE that finds both in use is counted and not rewritten (the line is corrected again on its next read; bin `ce_rewrite_full`). It reads the line again through the bank's arbitration, corrects it (`ccv_common_secded_fix`, K = 128, 10.7 NGD to `q`) from the routed flop behind the macro, flops it, encodes it (`ccv_common_secded_enc`, 14.5 NGD) from those flops, flops the word, and writes it: read to write 5 cycles, wdata straight from a flop. A store or fill that writes the same set and way between the rewrite's read and write cancels the rewrite (slice 2 holds it to that).

**LRU and the predictor (MA-30).** Each set's 7 tree-PLRU bits sit in dcu\_bctl's flops (448 a bank), not in the tag RF, so the tag RF is written only by fills and state changes and a hit never writes it. The predictor is a fold table in dcu\_bctl's flops: per set and way, `CCV_DCU_WAYPRED_BITS` (4) bits and a valid bit, 2,560 flops a bank, written only by a fill (fold and valid set), an eviction or an invalidation (valid cleared), whose enable gates them. The fold of a PA is the XOR of PA\[47:16\]'s k-bit chunks from bit 16 up, the last zero-extended: the tag above the 7 line-offset and 9 set-and-bank bits, which at CCV\_L\_PAGE\_SHIFT 16 is exactly the PFN. One helper computes it on both sides (sim/skel/wayfold.h and rtl/common/ccv\_common\_wayfold.sv, TI's, held together as secded.h is): MIU keeps fold(PFN) in each TLB entry, written at the TLB fill, and DCU writes its table with it at a fill. MISPREDICT (AR 405): a tag hit in a way other than the picked one (two valid ways sharing a fold, the lowest taken) gets no contracted slot, so nothing goes out at the hit slot and MIU gives no completion at CCV\_LAT\_L1\_HIT + CCV\_LAT\_L1\_ECC, as for a bank-conflict loser (AR 368); the right way is re-read at H+5, top priority, and answers at MIU's R2 at H+10, due + 2, a late answer under the original req\_id with no new credit (DI-2, AR 390), its entry credit returned at the re-read. A fold match on a miss reads and discards the word, with no response and no CE or UE counted, and the miss goes on as any miss. No match is always a miss, since only valid ways match: no read. CHECKs: pa\_fold equals DCU's fold of the request's PA on every lookup not dropped; no tag hit without a fold match. Controls (must fail): dcu-wp-nocompare, the picked way's data completed without the tag compare; miu-fold-flip, one bit of MIU's pa\_fold flipped. Bins: alias mispredicts, fold-match misses, no-match misses, re-access cycles. MIU sends that fold of the request's PA as `pa_fold` (MA-30, AR 405; TI-518 landed it), and `CCV_DCU_WAYPRED_SEL` is 0: the lowest matching way. Priced on the MIU and DCU models: k = 4 is within 0.3% of k = 5 on every workload; k = 2 costs 3.5% on cm128priv; prediction off (hit 9) costs 0.8 to 1.1%; the set's MRU way alone cost 3.4% on S1. Prediction off is `CCV_DCU_WAYPRED_BITS` = 0, the hit then 9.

### Module partition (slice 1)

Modules live in rtl/dcu/. Each size is a module parameter defaulting to `ccv_params_pkg`, and each module gets a reduced unit for loops and a full-size unit for its exit. The flop counts are MA's estimates at full size; check-cg's figures replace them.

| Module | Instances | Stage | Contents | Flops each, about |
| --- | --- | --- | --- | --- |
| ccv\_dcu | 1 | – | the top: `ccv_common_clk`, children and wires only; the generated stub's name and ports. `ent_ret` from each dcu\_bctl's flop, wired straight to the port | 0 |
| dcu\_cap | 4, one per req slot | D0, D1 | `ccv_miu_dcu_req`'s capture: the valid and `lead_set_index` (interface lead flops, a `"lead": true` waiver against the block's 2%), and the lookup payload (req\_id, line PA, `pa_fold`, drop, kind) enabled by the valid's flop. Store data and its mask go to slice 2 | 69 |
| dcu\_btag | 8, one per bank | D0, D1 | 2 `ccv_common_rf_1r1w` of 64 x 136 (four ways' 34-bit tag and state each; slice 2 part 3); the lowest-slot pick of the leads naming the bank, made from the channel's valid and lead\_set\_index bank bits at H+1 and flopped in dcu\_btag itself, since the RFs' re must come from its own flops (CG-5; 4 lead flops a bank, a "lead": true waiver against the block's 2%; DI-25); the RF read address, the pick's 4:1 select of dcu\_cap's lead\_set\_index; the PA select and the 8-way compare; flops hit, way, state | 20 |
| dcu\_bctl | 8, one per bank | D0 to D4 | the bank's arbitration and cadence; the 16-entry lookup queue (req\_id, slot, line, tag result, age); the 64 sets' PLRU bits; the fold table (64 x 8 x (4 + valid)) with its 64:1 read select, the fold compare and the lowest-match pick; mispredict; the pipeline's carry (req\_id, slot, valid, late); `ent_ret`; the SRAM's address, `ce` and `we` | 4,000 |
| dcu\_bdat | 8, one per bank | D1 to D5 | 8 `ccv_common_sram_1rw` of 512 x 137 ((137,128), MA-29; built with a column mux of at least 4, so an upset over adjacent cells in a row is one bit in each word, AR-404 (4)); the flop behind the macro (1,096); the 8 syndromes and their flops; the CE or UE event | 1,200 |
| dcu\_rarb | 1 | D3 | each slot's valid and its one-hot bank select (copied per 137-bit group for fanout), contracted hits first, late answers lowest bank first | 80 |
| dcu\_rslot | 4, one per rsp slot | D4 | the 8:1 route from the banks' flops behind the macro and the payload flops of `ccv_dcu_miu_rsp` | 1,110 |
| dcu\_fix | 1 | – | the CE rewrite: request queue (2), the route of its bank's line, fix, encode, wdata flops | 2,150 |
| dcu\_err | 1 | D5 | CE and UE event collection; the counts and first-error log go to `ccv_common_err` when TI lands it (AR 370 (6)) | 100 |
| dcu\_wake | 1 | – | each outbound channel's wake from the registered inbound wakes and DCU's pending work, at least `CCV_WAKE_LAT` before any valid | 10 |

### Port NGD budgets (slice 1)

Arrival is the depth before the port. A port not listed keeps the default, 12 a side. DI transcribes these into `rtl/dcu/<module>.ngd.json` with `"by": "MA"` and the tab's revision.

| Module and port | Side | Budget | Why |
| --- | --- | --- | --- |
| every input from `ccv_miu_dcu_req` | in | arrival 0 | interface capture flops; DCU's ends stay at 0 NGD |
| dcu\_cap, dcu\_btag, dcu\_bdat, dcu\_rarb, dcu\_rslot, dcu\_fix, dcu\_err outputs | out | 0 | straight from flops; a flop that also feeds logic inside has a `(* keep *)` copy for the port |
| dcu\_bctl outputs but `ce` and the SRAM address | out | 0 | from flops; `we` and the write select are flopped a cycle ahead |
| dcu\_bctl SRAM address | out | 9 | the way bits from the fold compare (4-bit equality and the valid bit, 3), the lowest-match pick (3) and a 2:1 select against the flopped address of an arbitrated access (2), 1 to spare; the set bits from a flop |
| dcu\_bdat SRAM address | in | arrival 9 | fanout to 8 instances (1.4) and the address setup (13.1): 23.5 |
| dcu\_bctl `ce` | out | 4 | the flopped enable cleared by the bank's lookup's drop: a 4:1 select of the drop (2), the AND (1), 1 to spare |
| dcu\_bdat `ce` | in | arrival 4 | fanout to 8 instances (1.4) and the SRAM address setup (13.1): 18.5 |
| dcu\_btag, dcu\_bctl inputs from dcu\_cap | in | arrival 0 | lead and payload flops. dcu\_btag's RF read address: bank decode and lowest-slot pick (4), a 4:1 select (2), fanout to 2 instances (1), setup 8.7: 15.7. Its compare: `rdata` at 12.6, about 10 for the 8-way compare and encode: 22.6 |
| dcu\_bctl inputs from dcu\_btag | in | arrival 0 | flopped tag results; the mispredict compare and the arbitration of the next access stay well inside 25. DI-26: dcu\_bctl also takes req\_id, pa\_fold and drop from the channel's wires as they land (arrival 0, abutted link), so the fold compare is at D0 and the pick at D1 from flops; dcu\_fix's request (lead fxv, then payload) and every other input arrive at 0, from flops. Measured: flop to flop 24.96, in to flop 23.2, flop to out 7.4 |
| dcu\_rslot inputs from dcu\_bdat and dcu\_rarb | in | arrival 0 | flops; the select's fanout over 1,103 bits (about 5, less with the copies) and the 8:1 AND-OR (3) |
| dcu\_fix inputs from dcu\_bdat | in | arrival 0 | flops; the route (about 8 with fanout) and the fix (10.7 to `q`) |
| dcu\_bdat `wdata` | in | arrival 0 | from dcu\_fix's flops (slice 2 adds the fill and store writers behind a flopped select): a 2:1 select (2), fanout (1), data setup 8 |
| dcu\_bdat syndrome | – | internal | from the flop behind the macro: fanout (1.4) and the syndrome tree (15.4), to its flop |

**The drop (MA-27).** On drop DCU's dcu\_bctl clears the SRAM `ce` for the lookup in the payload cycle, so the bank reads nothing, and the access cycle it would have taken is free again. The tag RF read on the lead happened, as every lead's does; it changes no state. A dropped lookup takes no queue entry, updates no PLRU bit, returns no credit and sends no response, and no syndrome is computed for it, since no data was read.

**ECC (MA-28 (c), DI-18, MA-29).** The syndrome is DCU's own, from the flop behind the macro, over the same scope as MIU's: every code word of the line the response carries. A non-zero syndrome on a response's line is a CE or UE that MIU will see too; DCU counts it and the models check the two sets agree. A CE asks dcu\_fix for a rewrite. A UE is recovered or fatal by AR 370, in slice 2.

### Slice 2, part 1: miss buffers and fills

**Status: MA's (DI-30).** This part covers a miss from the cycle its tags say so to its fill's write and answers. It covers loads, merging, the request to MLC, the fill's capture, encode, victim choice, tag and data write, and the answers. Eviction and writeback (with DI-21), stores and their merge, probes, and UE recovery's second response follow as parts 2 to 4. Where this part leaves a hook for them, it says so. Nothing here crosses a block: `ccv_dcu_mlc_req`, `ccv_mlc_dcu_rsp` and `ccv_dcu_miu_rsp` are used as the schema has them, and 4 fill buffers are `ccv_mlc_dcu_rsp`'s `CCV_CREDIT_DEPTH` credits.

**Miss buffers (dcu\_mshr).** There are 16 entries in each of the 8 L1 banks (8 dcu\_mshr instances; CCV\_DCU\_MSHR\_PER\_BANK), 128 in all (MA-31, Daniel's B, DA rev 136), one per `ccv_dcu_mlc_req` req\_id (`CCV_P_W_REQ_DCU_MLC` = 7): the req\_id is {bank, entry}, and a bank's entries hold only lines of that bank. A lookup's line compare, merge, allocate and free-id pick stay within its own bank's 16, as the single 16 did before; each bank's partition takes at most one new miss a cycle (A2 sends no two lookups to one bank, MA-27) and its own retries. Unsent misses go oldest first within a bank by its 16-entry age matrix; across the 8 banks dcu\_mpick takes the oldest head by a stamp, behind any writeback, and grants the retries the same way. A fill's entry read is its req\_id's top 3 bits to the bank and a 16:1 select. Each entry holds:

- valid, state (unsent, sent, filled) and kind (the coh\_op it sent)
- the line PA\[47:7\] and its bank, set and fold
- a merge list of up to 4 MIU requests in arrival order, each with req\_id, op, exclusive, and a store-data index (4 bits, the bank's store-data entry that holds a store's bytes until the fill merges them; part 3)
- its age order among unsent entries

That is about 110 flops an entry, 1,760 in all.

An entry stays valid from allocation until its fill has written the bank and every merged request has been answered. Only then is its req\_id free again. A line is in at most one valid entry.

**Allocation and merge, at D2 (H+4).** dcu\_btag's flopped tag result says miss: either the fold matched no way, or the tag compare found none. DCU then compares the lookup's line PA, in dcu\_cap's payload flops, with the line of all 16 entries (4 slots × 16 × 41-bit equality, about 7 NGD with fanout). Up to 4 misses arrive a cycle, one per bank at most. Two lookups to one line share a bank, and MIU's A2 drops all but one of them (MA-27), so same-cycle misses never share a line or a set; a CHECK holds that. A miss then does one of three things:

- **Merges** into its line's entry if the entry is unsent or sent and its list has room. A merged miss sends nothing to MLC.
- **Allocates** the next free entry if its line has none and a free entry is left. The 4 next free ids are picked a cycle ahead, from flops.
- **Waits.** It waits if its line's list is full, or its line's entry is filled but not yet written, or no entry of its bank is free, or its bank already holds a waiting miss. The miss takes an entry in its bank's queue, marked miss-wait, keeping the entry credit it holds. Its payload lives in that queue entry, in dcu\_bctl's flops (DI-34): every one of the bank's 16 entries carries the fields a retry needs, so that no other store holds a waiter and none can run out. The fields are req\_id (MIU's, 8 at MA-31), slot (2), line PA\[47:7\] (41), pa\_fold (4), op and kind (2), exclusive (1), std index (4), the tag result (way, state, hit: about 5), age (5), the miss-wait flag (1), the cause (2) and tag-stale (1): about 77 flops an entry, 1,232 a bank. Each entry's flops sit behind its own write enable. A store's data stays in dcu\_bstd, named by the std index. Retries are one a cycle across all banks (DI-34 (i)). Each bank offers its head waiter every cycle with a 10-bit stamp, taken when the waiter becomes the head, from a counter all banks keep in step (offer at R, grant at R+1, the payload captured in dcu\_mpick's flops and the retry's D2 at R+2); dcu\_mpick grants the oldest offer (modulo compare, ties to the lowest bank), and the granted bank dequeues on a placed outcome or keeps its head on a wait. A wait-again re-stamps the head with the current count, so a stuck head rotates behind the other banks' offers and no bank's ready waiter is held off by another's (DI-35). A late lookup's miss (a waiter's re-look, or a mispredict re-read, decided at its access cycles past its D) never takes its slot's port: it joins its bank's queue as miss-wait and leaves by the retry port, so it cannot meet the slot's own on-time miss with one offered id (MA-33, DI-55; control dcu-late-miss-port, bin dcu\_late\_miss\_retry). A bank holding a waiter or a pending retry queues its own new miss behind it. Each bank's dcu\_bctl flops its oldest ready waiter's payload onto its retry output, the entry chosen a cycle ahead (16:1 one-hot); dcu\_mpick's retry port routes the picked bank's 8:1 from those flops (arrival 0) and is served before slots 0 to 3. Each bank's dcu\_mshr holds its next free id ready, picked a cycle ahead, for the one miss its bank can take a cycle (a retry or a slot's; MA-31); which free id a miss gets is not architectural (DI-34 (ii)). An entry may turn sent a cycle after its request's valid (DI-34 (iv)), so the request pick excludes an entry whose valid launched the cycle before, and a probe's writeback cancel (part 4) goes by the pick, not by the sent state. All entry writes land at D3 from per-port records, D2 forwarding from them. Unsent misses go oldest first within a bank by its age matrix and across the banks by dcu\_mpick's stamp pick, behind any writeback. If ccv\_dcu\_mlc\_req's credit count takes a send a cycle late, the send decision subtracts last cycle's send, so DCU never sends without a credit (DI-34 update 2). dcu\_mshr stages the D2 PA in its own flops, since dcu\_cap's is overwritten back to back; it writes entries at D3, and forwards those writes to the next cycle's D2 line compare, free-entry pick and merge-list count, so a miss in the cycle after an allocate or merge to its line merges or waits as if the write had landed. The MLC request's valid stays at H+5. This is MA-12's hold: MIU's credits stop the channel, and the request is never refused.

The last of those rules keeps every line's requests in arrival order, since one line is always one bank. A bank's miss waiters retry oldest first, one a cycle, ahead of that bank's new misses, whenever an entry or a list place frees.

A lookup's entry credit returns on `ent_ret` when it merges or allocates, or, if it waited, when it leaves the queue for an entry (slice 1's rule).

**The request to MLC.** `ccv_dcu_mlc_req` is rate 1. In its D2, a miss that allocates is picked straight away if no older entry is unsent and the channel holds a credit, so the request's valid launches at H+5. Otherwise the oldest unsent entry goes, one a cycle. The payload follows a cycle after the valid, from flops. It carries:

- req\_id, the entry index
- the line PA
- coh\_op: a load miss reads shared; a store or an atomic acquires (part 3)
- core\_id
- writeback\_data, unused until part 2

Part 2 sets a writeback's place in this order.

**Fill buffers (dcu\_fill).** There are 4 fill buffers, matching `ccv_mlc_dcu_rsp`'s 4 credits. Each holds the fill's 1,024 data bits, its 72 encoded check bits, req\_id, ownership, miss, and its answers still owed. That is about 1,120 flops a buffer, 4,480 in all. A fill buffer's credit returns when its line is written and its last answer has left. The receiving end is no-flop: the payload lands at 0 NGD into the free buffer named a cycle ahead.

**Stages of a fill.** F is the cycle the fill's payload lands; its valid landed at F-1.

| Cycle | Work | Modules |
| --- | --- | --- |
| F-1 | The fill's valid lands and is flopped. The free buffer it will take was chosen from flops | dcu\_fill |
| F | The payload is captured into that buffer. Its req\_id, from the wires at arrival 0, reads its miss buffer entry (a 16:1 select, about 5 NGD), and the entry's line, bank, set, fold and merge list are flopped in dcu\_mshr for the buffer | dcu\_fill, dcu\_mshr |
| F+1 | The buffer's 8 code words are encoded (8 `ccv_common_secded_enc`, K = 128, 14.5 NGD) and the 72 check bits flopped. Part 3 merges a store's bytes into the data first: only the stores ahead of the list's first load, so that no load sees a younger store. The fill asks its bank to write (a lead, `flv`, then the payload: set, fold, tag, state, buffer index), as dcu\_fix asks for a rewrite. The lead is dcu\_mshr's own flop of its F read: the fill's valid with the bank one-hot, about 2 NGD on the 16:1 select. The payload follows at F+2 from flops, line PA, set and fold from dcu\_mshr and buffer index and state from dcu\_fill. The bank captures it under its flopped lead, and the write is its queue waiter from F+4 (MA, DI-39: one cycle with no lead would enable bctl's reservation flops from an input, CG-5). At F+2 the bank picks the victim way: the lowest invalid way, else the tree-PLRU victim, skipping a way that another fill's write still reserves or that a pending store write holds. It reserves that way and marks it most recently used | dcu\_fill, dcu\_bctl |
| F+2 | dcu\_rarb gives slots to the fill's answers: one per merged load, as late answers (below). Each answer's buffer select is flopped. The bank may take the write for any access cycle from F+3 on | dcu\_rarb, dcu\_bctl |
| F+3 | The answers' valids launch, and each slot routes its buffer's data and check bits into its payload flops. At the earliest, W = F+3 is the bank's data write: `ce` and `we`, with {set, way} as the address and wdata from the buffer | dcu\_rslot, dcu\_bctl, dcu\_bdat |
| F+4 | The answers' payloads launch, so each valid is at MIU at F+4: the floor, `CCV_LAT_FILL_NOTICE` from F (DI-4) | dcu\_rslot |

A fill's answer carries:

- req\_id: the merged request's
- read\_data and check\_bits: the buffer's line and its encoded bits, so MIU's R2 finds a zero syndrome
- hit = 0
- ownership\_granted and mlc\_miss: the fill's ownership and miss

A noticed answer (CCV\_DCU\_NOTICE = 1) is sent its notice at F, and dcu\_rarb reserves its slot at F+6 then (slice 1's reservation rule).

**The fill's write.** A fill's write takes only a bank access cycle with no lookup (AR's MA-7 ask). It is a queue waiter under `CCV_DCU_BANK_AGE`: once it has waited that long, its bank takes no new lookup until the write is done. A fill holds a credit on ccv\_mlc\_dcu\_rsp until its buffer frees, so its write has a shorter bound of its own (DI-37): once a ready fill write (or its victim's read) has waited CCV\_DCU\_FILL\_AGE (4) cycles, it takes its bank's next free access cycle ahead of new lookups and of queued store reads, and a new lookup that loses goes to the queue as a bank-conflict loser. Only two things stay ahead of it: a store write already booked (its merged line sits in dcu\_bstm's flops and writes at its booked cycle), and an older queued store to the same (set, way) (same-line order). A store read granted at ready + K − 1 books its write at ready + K + gap − 1, so the write lands within K + gap + 1 cycles of being ready (10; DI-37). Three rarer waits fall outside that bound and are held only by the channel's own response check: an older store to the victim's (set, way), which suspends the hold until it passes (the age is kept, not cleared); a late answer that holds its bank while it waits for a response slot; and a fill behind its victim's read waiting for a writeback buffer (DI-21). Each has a bin of its longest wait. In one cycle W it writes three things together:

- The data: the 8 instances, at {set within the bank, way}, from the buffer.
- The fold table: the way's fold and valid set, in flops.
- The tag RF: the way's tag and state. The way's dirty bit, in dcu\_bctl's flops, is set if a store merged into the fill and cleared otherwise (part 3). A tag RF word holds four ways, so the write is DI-25's read-modify-write. The word is read in a cycle when no lead names the bank, merged with the new tag, and written at W. The read waits for that free cycle under the same age bound. A lookup that reads the word between the read and W is forwarded the new tag (slice 1's forwarding).

The victim's line is gone at W. If it was dirty, its writeback read must come first (part 2), and the bank orders the write behind that read.

**Lookups whose tags went stale.** A lookup whose tag result names the (set, way) a fill writes, and whose data read would come at or after W, would read the new line under the old tag. dcu\_bctl compares the fill's (set, way) with its queue and pipeline carry (9-bit equality, 16 + 2 compares). Each match is marked tag-stale. It reads its tags again in a free RF cycle before its data read. If it now misses, it goes to the miss buffers as any miss. Part 2's eviction marks lookups the same way.

**Answer slots.** Late answers take the slots left after the contracted first-pass hits, in this order:

1. a bank's late answer that has waited `CCV_DCU_BANK_AGE`
2. fill answers, oldest fill first
3. the banks' other late answers, lowest bank first

A fill answer that finds no slot waits in its buffer. dcu\_rslot's route grows from 8:1 to 12:1, the 8 banks' flops behind the macro and the 4 fill buffers, one-hot from dcu\_rarb's flops.

**Merged requests the fill cannot answer.** Merged requests that need ownership a shared fill did not bring go back into their bank's queue in list order after the fill's write, and look up again. So does a store merged behind a load (part 3).

**Module partition (slice 2, part 1).** Two modules are added; four grow.

| Module | Instances | Contents | Flops, about |
| --- | --- | --- | --- |
| dcu\_mshr | 8, one per L1 bank (MA-31) | its bank's 16 entries (req\_ids {bank, entry}); its one lookup a cycle against its 16 lines; merge, allocate and wait; its next free id; its 16-entry unsent age order, offering its oldest unsent with a stamp to dcu\_mpick; its retry offer; `ccv_dcu_mlc_req`'s payload source; the entry read by a fill's req\_id (the bank in its top 3 bits) | 1,760 each (14,080 in all) |
| dcu\_mpick | 1 | the cross-bank picks (MA-31): the MLC request, the oldest of the 8 banks' unsent heads by stamp behind any writeback, and the retry grant (moved from dcu\_mshr, DI-35's rule unchanged); ccv\_dcu\_mlc\_req's valid and payload flops | about 1,200 (the request's 1,120 and the picks) |
| dcu\_fill | 1 | `ccv_mlc_dcu_rsp`'s capture into the 4 buffers; the 8 encoders; the bank write request (flv, payload); answers owed; the credits back to MLC | 4,500 |
| dcu\_bctl | grows | the fill's write as a queue waiter; victim choice, reservation and MRU; tag-stale marking; miss-wait entries, their payload in every queue entry (about 75 flops each, 1,200 a bank; DI-34) and their retry; the wdata select | – |
| dcu\_btag | grows | the RF's read-modify-write port for a fill's tag write, and its forward | – |
| dcu\_rarb | grows | fill answers as a late source, oldest first, with the age rule above | – |
| dcu\_rslot | grows | the 12:1 route | – |

**Port NGD budgets (slice 2, part 1).** As in slice 1, every output launches from a flop (budget 0), and every input from a flop or a channel arrives at 0, unless listed here.

| Module and port | Side | Budget | Why |
| --- | --- | --- | --- |
| dcu\_fill inputs from `ccv_mlc_dcu_rsp` | in | arrival 0 | no-flop end; the payload into the chosen buffer, and req\_id into the entry read (5) and its flop |
| dcu\_mshr entry read address (`ccv_mlc_dcu_rsp` req\_id) | in | arrival 0 | wired from the channel port in ccv\_dcu, not through dcu\_fill (no feedthrough); the 16:1 select (5) to dcu\_mshr's own flops, which dcu\_fill reads at F+1 |
| dcu\_mshr inputs from dcu\_btag and dcu\_cap | in | arrival 0 | flops; the line compare (7), the merge or allocate decision (4) and the write enable fanout (3): 14 |
| dcu\_bdat `wdata` | in | arrival 0 | a 5:1 one-hot select (dcu\_fix and the 4 fill buffers; part 3 adds the store writer) from dcu\_bctl's flops (3), fanout to 8 instances (1.4), data setup 8: 12.4 |
| dcu\_rslot inputs from dcu\_fill | in | arrival 0 | flops; the 12:1 AND-OR (4) and the select's fanout over 1,103 bits (about 5): 9 |

**Bins, CHECKs and controls.**

- **Bins:**
  - misses
  - merged (and merges that later needed a re-look)
  - allocations sent straight from D2
  - miss-wait cycles by cause: no entry, list full, filled not written, or bank order
  - maximum entries in use
  - maximum fill buffers in use
  - fill answers that waited for a slot
  - fill writes that waited for a bank, and those that reached the age bound
  - tag-stale re-looks
  - victims that were invalid, PLRU, or skipped for a reservation
- **CHECKs:**
  - no two valid entries hold one line
  - MLC answers only an id in flight
  - every merged request is answered exactly once, from its own fill or by its re-look
  - no fill answer's valid reaches MIU before F+4, and a noticed one comes exactly `CCV_LAT_FILL_NOTICE` after its notice
  - a tag compare finds at most one hit in a set
  - a lookup never reads data under a tag a fill has since replaced
- **Controls (must fail):**
  - dcu-mshr-nomerge: a second miss to a line allocates its own entry, so the line lands in two ways
  - dcu-fill-nostale: tag-stale marking off, so a lookup reads the fill's line under the victim's tag
  - dcu-fill-early: answers at F+3
  - dcu-miss-reorder: a bank's new miss passes its waiting one to the same line

### Slice 2, part 2: eviction and writeback

**Status: MA's (DI-30, answers DI-21).** This part covers a fill's victim, from its choice at F+2 to MLC's acknowledgement of its writeback. A probe's invalidation and any clean-eviction notice to MLC are part 4's.

**A clean victim** leaves with no read and no message. The fill's write at W replaces it.

**A dirty victim** is read from its bank before the fill writes over it, and is written back whole on `ccv_dcu_mlc_req`.

**The victim's id: the fill's own entry.** A writeback needs an MLC req\_id until MLC acknowledges it. It reuses the miss buffer entry of the fill that evicted it. That entry's req\_id is already done with MLC, since the fill has landed. The entry keeps the fill's line until W, so that misses to that line wait (part 1). At W it turns into the writeback's entry: its line becomes the victim's, its kind writeback and its state unsent. Requests in its merge list that must look up again have entered their bank's queue by then (part 1).

So a writeback never needs a free entry. Waiting for one is what could deadlock: every entry filled and waiting to write, with no id left for their victims.

From W until MLC's acknowledgement, a miss to the victim's line matches the entry and waits, like any filled-not-written entry (part 1's miss-wait). It then misses again and fetches the line back after the writeback.

**Writeback buffers (dcu\_wb): 2.** Each holds the victim's 1,024 corrected data bits, its line PA\[47:7\] and its entry index, about 1,070 flops a buffer, 2,140 in all.

**The victim's read.** The read is a bank access, a queue waiter under `CCV_DCU_BANK_AGE` like the fill's write. In each bank, the fill's write waits behind its victim's read. The bank takes it no earlier than F+3, decided a cycle ahead. The read's word is on `rdata` two cycles later and is flopped behind the macro. dcu\_wb then routes the bank's line 8:1 from those flops and corrects each code word (8 `ccv_common_secded_fix`, K = 128, 10.7 NGD) from dcu\_bdat's flopped syndromes. It flops the line into its buffer, about 18 NGD in all. The fill's write can take the bank's next access, 2 cycles after the read. So a dirty victim moves the fill's earliest W from F+3 to F+5. The fill's answers come from its buffer at F+4 either way.

On the victim read, a CE is corrected in the route and counted, with no rewrite, since the line is leaving. A UE is core-fatal (AR 370): the sticky ue level is raised, the writeback is not sent (containment), and MACHINE\_CHECK ends it.

**From victim choice to W, the victim's way is reserved.** It stays reserved until the fill's write (part 1). A load may still hit it: if its data read comes before W it reads the victim's line, and after W part 1's tag-stale rule makes it look up again. A store that hits a reserved dirty victim waits in its bank's queue as miss-wait, and looks up again after W. So no store writes a line whose read has already gone to the writeback buffer (part 3 holds the store side to this).

**DI-21, both writeback buffers in use.** The dirty victim is still chosen at F+2, but its read waits in its bank's queue until a buffer frees, and the fill's write waits behind it. The fill buffer, and with it its credit on `ccv_mlc_dcu_rsp`, stays held, so MLC is backpressured, and nothing else waits. Nothing deadlocks: a writeback buffer frees when its request's payload launches, which needs only a credit on `ccv_dcu_mlc_req`. A clean victim chosen instead when the buffers are full is not taken. It would add a second victim rule for a case the bins should show is rare. Bin: `dcu_wb_full`, cycles a victim read waited for a buffer.

**The writeback request.** It goes on `ccv_dcu_mlc_req` with:

- req\_id: the entry
- phys\_addr: the victim's line
- coh\_op: write, a writeback (the stub's code until MLC's session sets `CCV_L_W_COH_OP`)
- core\_id
- writeback\_data: the buffer's line

Writebacks go ahead of unsent misses, oldest first, since each one frees a writeback buffer and so lets a fill write. Part 1's straight-from-D2 request is taken only when no writeback waits either. The buffer frees as the request's payload launches. The entry stays valid until MLC's acknowledgement.

**MLC's acknowledgement** comes on `ccv_mlc_dcu_rsp` under the entry's req\_id. dcu\_fill sees from the entry's read at F that its kind is writeback. It takes no fill buffer, returns the channel's credit at once, and frees the entry at F+1.

**Module partition (slice 2, part 2).**

| Module | Instances | Contents | Flops, about |
| --- | --- | --- | --- |
| dcu\_wb | 1 | the 2 writeback buffers; the 8:1 route from the banks' flops behind the macro; 8 fixes; the CE count and UE event of a victim read | 2,140 |
| dcu\_mshr | grows | an entry's turn into a writeback at W; writebacks first in the request order; the request's 2:1 data select from the 2 buffers | – |
| dcu\_fill | grows | an acknowledgement: no buffer, the credit at once, the entry freed | – |
| dcu\_bctl | grows | the victim read as a queue waiter ahead of its fill's write; dirty victim reserved, its stores held | – |

**Port NGD budgets (slice 2, part 2).** As before, every output launches from a flop and every input arrives at 0 unless listed here.

| Module and port | Side | Budget | Why |
| --- | --- | --- | --- |
| dcu\_wb inputs from dcu\_bdat | in | arrival 0 | flops behind the macro and the syndrome flops; the 8:1 route (3), fanout over 1,096 bits (about 4) and the fix (10.7): about 18 to the buffer's flops |
| dcu\_mshr inputs from dcu\_wb | in | arrival 0 | flops; the 2:1 select into the payload flops (2) and fanout (2) |

**Bins, CHECKs and controls.**

- **Bins:**
  - evictions, clean and dirty
  - `dcu_wb_full` cycles
  - maximum writeback buffers in use
  - fill writes delayed by a victim read
  - misses that waited on a writeback in flight
  - stores held on a reserved victim
  - victim reads with a CE
- **CHECKs:**
  - a dirty victim's line reaches MLC exactly once, with the data its last write left
  - no fill writes over a dirty victim before its read
  - a line is never fetched while its writeback awaits MLC's acknowledgement
  - an acknowledgement names an entry whose kind is writeback
- **Controls (must fail):**
  - dcu-wb-drop: the model's drop-writeback, a dirty victim never written back
  - dcu-wb-early: the fill's write before its victim's read
  - dcu-wb-refetch: a miss to a line in writeback does not wait
  - dcu-wb-store: a store writes a reserved dirty victim after its read

### Slice 2, part 3: stores and the merge

**Status: MA's (DI-30, and DI-26 (f)'s same-line ordering).** This part covers a store or exclusive read: its data, its hit with MA-17's variant (b), its upgrade or miss, its merge into a fill, and the ordering of a bank's queue. Probes are part 4.

**Store data: a register file a bank.** A store's `write_data` (1,024 bits) and `byte_mask` (128) go into its bank's store-data entries. There are `CCV_DCU_BANK_STDATA` (12) of them, and MIU holds one credit for each (MA-25).

In flops that would be 8 × 12 × 1,152, about 110,600 flops. So each bank's data entries are 4 `ccv_common_rf_1r1w` of 16 × 256 bits, 12 of the 16 words used. That is MACRO-1's widest register file word, and 512 B, its least size. The 12 byte masks are in flops, 1,536 a bank, since a 128-bit register file of 16 words would be 256 B, under the least. A read is addressed a cycle before its `rdata` launches, as with the tag RF. The array rules allow a register file here, since each port is used at most once a cycle:

- The write port: MIU's A2 sends at most one lookup to a bank a cycle (MA-27).
- The read port: the bank's own arbitration grants it, to a store hit's merge or to a fill's merge, one a cycle.

dcu\_bstd keeps a free list of its 12 entries.

The write happens in the payload cycle (H+3). It comes from the channel's wires through the bank's 4:1 slot select, one-hot from dcu\_btag's flopped pick (2 NGD), with fanout (1.5) and the RF's write setup (8.7). Its write enable is the pick, the store kind and not drop (3 NGD). A dropped store writes nothing (MA-27).

The entry's index travels with the store, in the bank queue or a miss buffer's merge list (part 1's 4-bit field). The store-data credit returns on `std_ret` when the entry frees: at the store's write for a hit, or at its merge into the fill buffer for a miss.

dcu\_cap's slice 1 capture is unchanged. The store payload never enters its flops.

**Dirty bits move to flops.** Each bank keeps one dirty bit per (set, way) in dcu\_bctl, 512 flops. A store's write sets the bit, a fill's write sets or clears it (part 1), and the victim choice reads it (part 2). So the tag RF holds only tag and state, 4 × 34 = 136 bits a word, and only a fill or a probe writes it. A store never writes the tag RF.

**A store hit: MA-17's variant (b).** A store hits when the tag compare finds its line and the line's state is owned. The tags alone decide that, so its answer leaves on its own slot at its contracted cycle, whether or not it won the bank (MA-24). The answer carries `hit` = 1 and no data, and it is the ack that frees MIU's store. MIU checks no syndrome for it. The store's read and its whole-line write then wait in the bank's queue as deferred work, under the age bound, and its way is held from victim choice until the write (part 1). When the read is taken, dcu\_bstm, the bank's merge unit, works from the flop behind the macro:

1. **Correct and merge.** Each code word is corrected with dcu\_bdat's flopped syndrome (`ccv_common_secded_fix`, 10.7 NGD). The store-data RF, addressed at the store's entry a cycle earlier, launches its `rdata` in the same stage, and the store's mask comes from its flops. The store's bytes are merged over the corrected line under that mask (2 NGD). The result is flopped, at about 15 NGD.
2. **Encode.** The merged line is encoded (8 `ccv_common_secded_enc`, 14.5 NGD) and flopped.
3. **Write.** The line is written back whole to the same {set, way}, with wdata straight from that flop.

The stages are the CE rewrite's (dcu\_fix), so the read-to-write gap is the same 5 cycles (TI-483). The bank books the write's access cycle when it takes the read, so a store's write is never late and its flops are free for the next store. A bank holds at most two stores between read and write, and the cadence fits both: reads at R and R+2, writes at R+5 and R+7.

At the write, the line's dirty bit is set and its store-data entry frees.

A CE found by the merge's read is corrected by that same write, so it asks dcu\_fix for nothing. A UE found by the merge's read is core-fatal (AR 370): the write is withheld, so the lost bytes are never written over, and MACHINE\_CHECK ends it, with nothing waiting on the acked store (slice 1's ECC bullet).

**An exclusive read** (an atomic's A1, `exclusive_req`) that hits an owned line is a load hit with its data. It does not need dcu\_bstm. An atomic's A3 is a store.

**A store or exclusive read on a line that is not owned** is an upgrade. It goes to the miss buffers as a miss whose coh\_op acquires:

- AcquirePerm for a store whose mask covers the whole line
- AcquireData for anything else

Its fill writes the line's own way, so it chooses no victim. Loads keep hitting the shared copy until that write.

**A store or exclusive read that misses** allocates or merges as any miss (part 1), with the same coh\_op rule. An exclusive read merged behind a read-shared entry, and a store merged behind one, go back to their bank's queue after the fill and look up again (part 1).

**The merge into a fill.** The fill buffer takes the bytes of the stores that come ahead of the list's first load, in list order, and only those. A store behind a load goes back to its bank's queue and looks up again after the fill's write. So a load never sees a store that MIU sent after it (a warp's younger store), and it does see every store sent before it.

The merges run one a cycle. Each store's entry is read from its bank's store-data RF, granted by the bank and addressed from F+1, with `rdata` a cycle later. The `rdata` and the mask are routed 8:1 to dcu\_fill (about 7 NGD after the RF's launch) and flopped. In the next cycle the store is merged under its mask into the buffer's data flops.

With k leading stores, the last merge is at F+k+2 and the encode at F+k+3, so the loads' answers move from F+4 to F+k+5. That is still no earlier than the floor. A fill with no store encodes at F+1, as part 1 has it.

AcquirePerm's grant carries no data. The buffer starts from all zeros, and its one full-line store covers every byte.

A store merged into a fill is answered with the fill's other answers, as a late answer with `hit` = 0 and no data, and its entry frees at the merge. The fill's write sets the line's dirty bit if any store merged.

**Same-line order in a bank (DI-26 (f)).** Lookups to the same line keep the order they arrived in, so that a load never reads ahead of an older store to its line, nor a store ahead of an older load or store. Every lookup that reads from a bank's queue is a hit, and a hit names its (set, way), so dcu\_bctl compares (set, way), 9 bits, instead of the line:

- A queue waiter is not picked while an older entry with the same (set, way) is a store, or while it is itself a store and an older entry with the same (set, way) is waiting.
- A new first-pass lookup whose (set, way) matches a store in the queue or in dcu\_bstm goes into the queue behind it, and does not read.

That is 16 + 2 compares for a new lookup and 120 pairs within the queue, cheap at 9 bits. A miss keeps its order by part 1's miss-wait rule. A store that hits a reserved dirty victim waits (part 2).

**The CE rewrite's cancel (slice 1's promise).** A store's write or a fill's write to the (set, way) of dcu\_fix's held rewrite, between the rewrite's read and its write, cancels the rewrite. dcu\_bctl compares its writes with the rewrite's (bank, set, way), and dcu\_fix drops the rewrite (bin `ce_rewrite_cancelled`).

**Module partition (slice 2, part 3).**

| Module | Instances | Contents | Flops, about |
| --- | --- | --- | --- |
| dcu\_bstd | 8, one per bank | 4 `ccv_common_rf_1r1w` of 16 × 256 bits for the data; the 12 masks in flops; the 4:1 slot select and write enable; the free list; the read address from dcu\_bctl's grant, a cycle ahead; `std_ret`'s request | 1,570 |
| dcu\_bstm | 8, one per bank | the store merge: fix and merge from the flop behind the macro and the RF's `rdata`, its flop (1,024); encode and its flop (1,096, wdata to dcu\_bdat) | 2,130 |
| dcu\_bctl | grows | dirty bits in flops (512); store hits' booked writes; same-line order by (set, way); upgrades to the miss buffers; the RF read grant; the rewrite's cancel | – |
| dcu\_btag | shrinks | the RF word goes from 140 to 136 bits: no dirty bit | – |
| dcu\_fill | grows | the merge from the 8 store-data RFs and masks (8:1 route), the stores ahead of the first load, an AcquirePerm grant's zeroed data | – |
| dcu\_bdat | grows | the wdata select takes dcu\_bstm's flop: 6:1 | – |

**Port NGD budgets (slice 2, part 3).** As before, every output launches from a flop, and every input arrives at 0, unless listed here.

| Module and port | Side | Budget | Why |
| --- | --- | --- | --- |
| dcu\_bstd write data, mask and index from `ccv_miu_dcu_req` | in | arrival 0 | the channel's wires; the 4:1 select (2), fanout (1.5) and RF data setup: about 12, the mask to its flops |
| dcu\_bstd `rdata` out to dcu\_bstm and dcu\_fill | out | the RF's launch | the `rdata` launch at 16 × 256 (check-ngd's macro timing; 12.6 at the tag RF's 64 × 140, less at 16 words); no logic after it. The mask leaves from flops, at 0 |
| dcu\_bstm `rdata` in | in | arrival: the RF's launch | the merge select (2) and its flop: under 15, beside the fix path from the flop behind the macro (10.7 + 2) |
| dcu\_fill store `rdata` in (8 banks) | in | arrival: the RF's launch | the 8:1 route (3) and fanout (about 4) to its flop: about 20 |
| dcu\_bdat `wdata` | in | arrival 0 | now a 6:1 one-hot select (3), fanout (1.4) and setup 8: 12.4, unchanged |

**Bins, CHECKs and controls.**

- **Bins:**
  - store hits
  - store hits whose read waited for the merge unit's two bookings
  - upgrades, AcquirePerm and AcquireData
  - store misses
  - stores merged into a fill, by position (ahead of or behind the first load)
  - store re-looks
  - same-line waits: a load behind a store, a store behind a load or store, and a first-pass lookup sent to the queue
  - store-data RF read conflicts between a hit's merge and a fill's merge
  - maximum store-data entries in use a bank
  - `ce_rewrite_cancelled`
- **CHECKs:**
  - every store's bytes reach the array or a fill buffer exactly once, under its mask
  - no load reads a line that an older store to it has not yet written
  - no store writes before an older load to its line has read
  - a store-data entry frees exactly when its credit returns
  - a store hit's write comes exactly the gap after its read, and its ack at its contracted cycle
  - no store writes a line that is not owned
- **Controls (must fail):**
  - dcu-st-noorder: same-line ordering off
  - dcu-st-mergeall: a fill merges every store in its list, a store behind a load included
  - dcu-st-shared: a store hit on a shared line writes without an upgrade
  - dcu-st-dirty: a store's write does not set the dirty bit, so its line is lost at eviction

### Slice 2, part 4: probes, UE recovery, repair and BIST groups

**Status: MA's (DI-30).** This part closes slice 2. It covers MLC's probes, a recovered UE's second answer (a rule the MIU tab also states), and TI-475's column repair and BIST broadcast groups for the 8 KiB data instances. MLC's own ordering of a probe against its grants and a writeback is MLC's session's to state. Where DCU depends on it, this part says so.

**Probe buffers (dcu\_prb): 4**, matching `ccv_mlc_dcu_probe`'s `CCV_CREDIT_DEPTH` credits and its 2-bit req\_id. Each holds the probe's req\_id, line PA\[47:7\], invalidate-or-downgrade, its (set, way) once known, and its state. That is about 50 flops a buffer. The probe channel is a wake source (dcu\_wake), and its receiving end is no-flop: the payload lands into the free buffer named a cycle ahead. A buffer's credit returns when its ack's payload launches.

**The probe's lookup.** A probe reads its set's tag RF word through the bank's read-modify-write port. That is the same port a fill's tag write uses (part 1), in a cycle when no lead names the bank, under `CCV_DCU_BANK_AGE`. The word is flopped. The next cycle, dcu\_btag compares it with the probe's line from flops (8 ways, about 10 NGD) and flops the hit, way, state and the way's dirty bit. The PA select of the lookup path is left alone, so slice 1's 22.6 NGD compare does not grow.

**Before the lookup, the probe checks the miss buffers.** It compares its line with all 16 entries, as a miss does:

- **An entry that is sent but not filled:** DCU acks at once with no data. It does not hold the line, and the fill that follows brings what MLC grants after the probe. DCU waits for nothing here. If it held the probe until the fill, it could deadlock against an MLC that holds the grant until the ack.
- **An entry that is filled but not written:** the probe waits for that write (W, under the age bound), then looks up.
- **An entry in writeback** (written back, not yet acknowledged): DCU acks with no data, since the writeback carries the line (ack = 0 for a writeback already sent; AR-409). If the writeback's request has not launched, its line still sits in a dcu\_wb buffer: the probe takes the line from that buffer with ack = 1, and that writeback is cancelled, so the line reaches MLC exactly once. dcu\_prb's compare with the 2 buffers and dcu\_mshr's request pick are decided in the same cycle from flops, and the probe wins: a cancelled buffer is never picked, and one picked a cycle earlier counts as sent. The cancelled buffer frees when the ack's payload launches, and its entry frees with it, since no MLC acknowledgement will come; misses to the line wait until then.
- **A reserved dirty victim** (part 2): the probe waits for the fill's write, then finds the writeback entry as above.

**The probe's outcomes.**

| Line in DCU | Invalidate | Downgrade |
| --- | --- | --- |
| absent | ack, no data | ack, no data |
| shared, clean | state invalid; ack, no data | ack, no data (already shared) |
| owned, clean | state invalid; ack, no data | state shared; ack, no data |
| owned, dirty | data read; state invalid; ack with `dirty_data` | data read; state shared, dirty cleared; ack with `dirty_data` |

A state change writes the tag RF word in the same read-modify-write as the lookup's read, so the probe's tag update is atomic against fills to the set. An invalidate also clears the way's fold valid bit and dirty bit in dcu\_bctl's flops.

A dirty line's data is read as a bank access in the probe's queue place. It goes through part 2's path (dcu\_wb's route and fix) into a writeback buffer, and the ack's `dirty_data` comes from that buffer. A probe that finds both writeback buffers in use waits, as a victim read does (DI-21). On the probe's read, a CE is corrected and counted. A UE is core-fatal (AR 370), and its ack is withheld.

**Order against stores.** A probe that hits is a bank queue entry with its (set, way). Part 3's same-line order holds it behind every older store to its line, so a store already acked to MIU writes before the probe reads or changes the line. Lookups behind the probe that named its (set, way) are marked tag-stale by its state change (part 1's rule), and look up again. A store behind it then misses or upgrades, and acquires again.

**The ack** goes on `ccv_dcu_mlc_probe_ack` with:

- req\_id: the probe's
- ack: 1 when dirty\_data carries the line, 0 when it does not. That is DCU's reading of the 1-bit field until MLC's session states the encoding; nothing probes yet, with one core.
- dirty\_data: the dirty line, or zeros

Acks leave in the order their probes finish, one a cycle.

**A recovered UE's second answer (AR 370; a rule for both tabs).** A UE in a clean line, found on a load's read, is recovered:

1. **MIU** withholds that slot's completion, as for any non-zero syndrome, and keeps the req\_id live. OOE takes the load as a miss.
2. **DCU** sends nothing more on that response. It invalidates the line (tag RF read-modify-write; fold valid and dirty cleared) and records the location in the UE track table. It then allocates or merges a miss for the line with that req\_id in the merge list, as a re-look does, so no new credit is spent.
3. **The fill's answer** under the same req\_id is the second answer, a late answer with `hit` = 0. MIU takes it as a refill and completes from it.

A second UE at a recorded location, or one that finds the table full, is core-fatal, as slice 1's ECC bullet says. So is a UE in a dirty line, in a victim's read, in a store's merge read, or in a probe's read. On a core-fatal path no second answer comes, and MI-8's quiescence exemption covers the req\_id (AR 389).

- **CHECKs:**
  - every recovered UE's req\_id is answered exactly twice, the first with a non-zero syndrome
  - the second answer comes from a fill
- **Controls (must fail):**
  - dcu-ue-noanswer: the refetch never answers
  - dcu-ue-stale: the line is not invalidated, so the second answer reads the same bad word

**Column repair and BIST groups (TI-475, for the 8 KiB data instances).**

- **Spare row:** each data instance keeps its one spare row in flops outside the array, 137 flops, as slice 1 has it. So does each tag RF instance, 136 flops. The store-data RF instances follow the common wrapper's rule when TI lands it.
- **Spare column:** each data instance has one spare column, which the common wrapper steers by its repair register: the column's index (8 bits over 137 columns) and a valid bit. That is 9 flops an instance and 576 in all, scan-loaded, ported up to the block wrapper and tied off until BIST insertion.
- **BIST broadcast groups** of at most 32 KiB each:
  - each bank's data instances 0 to 3 as one group, and 4 to 7 as another, 32 KiB each: 16 groups
  - each bank's register files, 2 tag RFs and 4 store-data RFs, about 4.2 KiB: 8 groups
  - 24 groups in all, each with its own BIST override and done or fail pair at the block wrapper, tied off until insertion

**Module partition (slice 2, part 4).**

| Module | Instances | Contents | Flops, about |
| --- | --- | --- | --- |
| dcu\_prb | 1 | `ccv_mlc_dcu_probe`'s capture into 4 buffers; the line compare with the miss buffers; each probe's state; `ccv_dcu_mlc_probe_ack`'s valid and payload flops (the data from dcu\_wb's buffer, 2:1) | 200 plus the ack's 1,030 |
| dcu\_btag | grows | the probe's compare from the RMW read's flop; the state write | – |
| dcu\_bctl | grows | the probe as a queue entry (same-line order); its data read; the fold valid and dirty clears | – |
| dcu\_mshr | grows | a UE refetch as a re-look under the same req\_id; the probe's line compare (16 more, at 41 bits) | – |
| dcu\_err | grows | the UE track table and recovery decision (AR 370) | – |
| ccv\_dcu | grows | the 24 BIST groups and 64 repair registers ported and tied off | – |

**Port NGD budgets (slice 2, part 4).** As before, every output launches from a flop and every input arrives at 0, unless listed here.

| Module and port | Side | Budget | Why |
| --- | --- | --- | --- |
| dcu\_prb inputs from `ccv_mlc_dcu_probe` | in | arrival 0 | no-flop end, into the buffer's flops |
| dcu\_mshr's line compare for dcu\_prb | in | arrival 0 | from the probe buffer's flops; 7 NGD to dcu\_mshr's flopped match |
| dcu\_btag's probe compare | – | internal | from the RMW read's flop and the probe line's flop: about 10 to its flop |

**Bins, CHECKs and controls.**

- **Bins:**
  - probes by kind and outcome, as in the table
  - probes that waited for a filled entry's write
  - probes acked against an entry that was sent or in writeback
  - probes that waited behind a store
  - probe data reads, and those that waited for a writeback buffer
  - re-looks a probe caused, and writebacks a probe cancelled
  - recovered UEs
  - BIST and repair ports tied off (a count, so a later change to them shows)
- **CHECKs:**
  - every probe is acked exactly once
  - an ack carries data if and only if the line was dirty
  - after an invalidate, no hit finds the line until it is filled again
  - no acked store is lost to a probe
- **Controls (must fail):**
  - dcu-prb-nostore: a probe passes an older store to its line
  - dcu-prb-nodirty: a dirty line's probe acks without data
  - dcu-prb-stale: a probe's invalidate leaves the fold valid bit set; and dcu-prb-double, a writeback a probe cancelled is also sent
  - dcu-ue-noanswer and dcu-ue-stale, above
