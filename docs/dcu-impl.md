# DCU implementation: handoff to the DCU implementation session (DI)

MA (the MIU and DCU block architect) wrote this on 2026-11-19, at Daniel's
request (DA tab, re: MA-23), for the session that builds the DCU. It is DI's
first read and its standing reference for who owns what. It points at the
spec rather than restating it. Where this file and the spec disagree, the
spec wins; raise the disagreement as a row.

Its twin, [`miu-impl.md`](miu-impl.md), is the fuller of the two: its
sections 1, 2, 4, 5 (the model rules and the verification order), 8 and 9
apply to DI as written, with MI read as DI, MIU as DCU, sim/miu/ as sim/dcu/,
`makeMiu` as `makeDcu` and `CCV_MIU_IMPL` as `CCV_DCU_IMPL`. Read it first.
This file holds what differs.

**Status (2026-11-19).** MA's Phase 1 architecture is decided (DCU tab of the
per-block specs, rev 50; MIU tab rev 144). The arrays and the hit pipeline
are option (B), tag then data, with way prediction (C) as a parameter
(Daniel, DA rev 128, closing MA-23; MA-26). **Phase 2 slice 1, the L1-hit
path, has landed** (DCU tab rev 82, section "MA's Phase 2"; DI-20): the
module partition, the per-cycle stage table and the port NGD budgets of the
hit path (section 5). The miss path and the rest follow as further slices.
Everything still open is a parameter with a default (section 4).

Paths under rtl/dcu/ and test/dcu/ are written plain, not as code, until
they exist.

---

## 1. Who DI is, and what it owns

- **DI = DCU implementation.** It mints `DI-n` in its own register tab and
  writes nowhere else in the register.
  - Register: https://claude.ai/artifact/JApHYjaUESeq8tsGMGXMU5, tab DI (node
    `1ea5d5b3-6e9c`), added 2026-11-19 by MA.
- **DI owns:** the DCU's cycle-accurate C++ model in `sim/dcu/` (its own
  files there; see below) and its lock-step with the RTL; the DCU's RTL,
  rtl/dcu/, once Phase 2 gives its partition; its units, benches and
  fixtures, test/dcu/; the DCU-internal assertions and Q-53 checkers; every
  coverage bin and control in section 3; its `<module>.ngd.json` files, whose
  numbers are MA's.
- **DI does not own:** the architecture (MA); the schema, parameters,
  generators, gate, `rtl/top/` and the DCU stub (TI); the MIU (MI, from
  [`miu-impl.md`](miu-impl.md)); MLC's side of the coherence channels (AR);
  Daniel's decisions.
- **`sim/dcu/dcu_p1.cpp` is MA's Phase 1 resource model, not the DCU
  model.** It stays as it is, behind `CCV_DCU_IMPL=p1`, for MA's sweeps. Read
  it: it already has the banks, the half-rate single-port timing, the
  conflict queue and its age bound, store variant (b) with its read-to-write
  gap, the hash and the way-prediction fold, and MA's measurements came from
  it. It is not built to the swap boundary on the MIU side (it keeps MIU's
  bank credits inside DCU's block, since it was a sweep tool), and it has
  none of ECC, UE recovery, the miss buffers' hold rule or the eviction and
  probe paths at the spec's timing. Write the model in files of your own
  (for example sim/dcu/dcu_core.cpp and sim/dcu/dcu_block.cpp, the RCU
  pattern), take what helps from `dcu_p1.cpp`, and leave it untouched.

## 2. Reading order (the first day)

1. [`miu-impl.md`](miu-impl.md), all of it, then this file.
2. **The DCU tab** ([`design-snapshots/dcu-spec.md`](design-snapshots/dcu-spec.md)),
   "Internals, mechanisms, risks", all of it. This is your work plan for the
   model:
   - geometry: 512 KiB, 8 ways, 512 sets of 128-byte lines; 128 and 64 KiB
     are configured-down points that reduce sets only, at the same hit
     latency;
   - ports: the banked tag register files, 8 single-ported data banks at
     half rate, slot-order conflicts, the age bound;
   - the bank queue and deferred stores (MA-24, MA-25): QDEPTH and STDATA,
     variant (b), the gap of 5, the two credit-return vectors;
   - the hit pipeline D1 to D3, speculative on the index lead;
   - miss buffers, the fill path, eviction, probes;
   - the arrays, pipelines (B) and (C), and the predictor;
   - ECC, BIST and repair; machine errors and the UE track table;
   - the contracts set before the block's session: the refill notice, slot
     reservation, the floor, probes between fill and response, holding a
     request; the write policy.
3. **The MIU tab's Phase 1 section**: what MIU sends and when, and what it
   holds on DCU's behalf (the bank credits).
4. **The DCU stub, `class Dcu` in `sim/skel/kernel.cpp`**: the function every
   kernel passes with today (write-back L1, ownership, misses by req_id, fill
   notices), and the model's head start. Then `sim/dcu/dcu_p1.cpp`.

## 3. What the model must do, and its coverage bins

The model rules are [`miu-impl.md`](miu-impl.md) section 5's: every output on
its cycle, every input taken on its cycle, every event emitted, every hold and
stall reproduced, every never-happens condition flagged, idle modelled, the
inside DI's to organise, the swap boundary kept.

### Obligations beyond the stub

| Obligation | Spec, and the row |
|---|---|
| **The hit pipeline at the spec's latency:** under (B) (`CCV_DCU_WAYPRED_BITS` = 0) the tags then the data, `CCV_LAT_L1_HIT` 9; under (C) (bits k > 0) the predicted way's data with the tags, `CCV_LAT_L1_HIT` 8, and a mispredict re-reads with a second bank access that obeys the half-rate rule, so it answers no earlier than due + 2, on the bank-conflict loser's path (DI-2; AR 390, OA-442). The prediction is the lowest way whose fold matches the request's PA fold (`CCV_DCU_WAYPRED_SEL` index); the fold table is in flops and the PLRU bits too, so a hit never writes the tag RF; once TI lands `pa_fold` on `ccv_miu_dcu_req`, the fold comes from MIU's payload (MA-30). Only valid ways match (a valid bit beside each fold), so no match is a miss and reads nothing; a hit in a way other than the picked one sends nothing at the hit slot and re-reads at H+5, a late answer at due + 2; a fold match on a miss discards its word. One fold function, PA[47:16] XOR-chunked, from the shared wayfold helper; CHECKs: `pa_fold` equals DCU's fold of the PA on every lookup not dropped, and no tag hit without a fold match (AR 405) | DCU tab, arrays and pipelines, Phase 2 slice 1; MA-23, MA-26, MA-30, AR 405, DA rev 128; TI-478 |
| **Banks:** a bank takes one access every other cycle; same-cycle collisions go in slot order and the loser answers later as a miss would; a waiter that reaches `CCV_DCU_BANK_AGE` blocks new lookups and fills to its bank until served | DCU tab, ports; MA-7, AR 364 |
| **The bank queue and its credits (MA-25):** up to `CCV_DCU_BANK_QDEPTH` (16) lookup entries and `CCV_DCU_BANK_STDATA` (12) store-data entries a bank, never more (MIU's credits guarantee it: flag an overflow as a failure); an entry credit returned when a lookup entry leaves, a store-data credit when a store's write leaves, at most one of each a bank a cycle, on the two per-bank vectors | DCU tab, bank queue; MA-24, MA-25 |
| **Store hits, variant (b):** the store's read and its whole-line write wait in the bank's queue as deferred work under the age bound, holding the data and byte mask, read to write 5 cycles (SECDED's corrected read); D3 merges under the byte mask; the line is written whole and marked dirty | DCU tab, hit pipeline and bank queue; MA-17, MA-24; TI-466, TI-483 |
| **ECC (TI-474, TI-475):** a hit's data leaves uncorrected at `CCV_LAT_L1_HIT`; the completion `CCV_LAT_L1_ECC` later; a non-zero syndrome withholds the completion (OOE takes a miss), MIU corrects the data it holds and delivers it as a refill, and DCU counts the CE and rewrites the line, sending nothing more (MA rev 148, DI-18) | DCU tab, ECC; AR-368, OA-424, RA 153 |
| **Machine errors (MA-19, AR 370):** a CE is counted and never faults; a UE in a clean line is recovered (invalidate, refetch as a miss, record it in the `CCV_DCU_UE_TRACK` (16) table); a second UE at a recorded location, or one that finds the table full, is core-fatal; a UE in a dirty line is fatal, and the real DCU withholds the read so MIU completes it with no data | DCU tab, machine errors; MA-19; TI-476; TI-485 |
| **Miss buffers, holding and fills:** 16 buffers of a line and up to 4 merged requests; hold `ccv_miu_dcu_req` only when every buffer is in use or a line's merge list is full; a fill writes its bank only in a cycle with no lookup to it and answers its merged requests from its own data; a notice is a promise, its response exactly `CCV_LAT_FILL_NOTICE` later, its slot reserved when it is sent; notices off by default (`CCV_DCU_NOTICE` = 0, the channel's valid held low): an un-noticed refill answers at F+4 from its fill's payload, a noticed one at F+6; the bench shows no refill hint and F+6 completions with notices off, and OA-23's hint controls caught with them on | DCU tab, miss buffers, fill path, contracts; MA-12, TI-22, OA-23; DI-4, AR 394, OA 453-454 |
| **Eviction and probes:** LRU over 8 ways; a dirty victim leaves whole from the 2-entry writeback buffer, which a probe also searches; probes on the fifth tag port never cancel a promised response | DCU tab, eviction, probes; TI-36 |
| **BIST and repair** are tied off at the block wrapper until BIST insertion; the model has none. The spare rows exist only as the UE track table's bound | DCU tab, ECC, BIST and repair; TI-475 |

### Coverage bins

The MIU tab's "Events the model must cover" holds the bins both blocks share:
the L1 hit on each pipe, bank conflicts, the miss with its notice, hint and
completion, the merged miss (`dcu-one-miss`), DCU holding a request, the
eviction writeback and dirty probe (`drop-writeback`, `write-through`), the
refill controls (`hint-wrong-tag`, `late-refill`, `notice-wrong-id`). DI
owns the DCU side of each. These are the DCU's own; MA folds them into the
DCU tab:

| Event | Bin counts | Negative control |
|---|---|---|
| A bank conflict, the loser served later as a miss | slot-order losers, per bank | both granted: two reads of one bank in its busy cycle |
| A waiter at the age bound blocking its bank | age-bound blocks | bound ignored: a waiter starves under a stream of hits |
| A full bank queue, entries and store data (MA-25) | cycles at QDEPTH, cycles at STDATA, credits returned per bank | an extra credit returned lets MIU overfill the queue, which the model flags |
| A deferred store's read, gap and write | deferred stores; read-to-write cycles | a write before the gap merges stale data |
| A way mispredict (k > 0) | second accesses; answers on the loser's path, at due + 2 or later | answering at due with the predicted way's data fails the oracle |
| Fold aliasing and fold misses (MA-30, AR 405) | alias mispredicts; fold-match misses; no-match misses (reads saved); re-access cycles | dcu-wp-nocompare (the picked way's data completed without the tag compare) and miu-fold-flip (one bit of MIU's `pa_fold` flipped) must each be caught |
| A fill held off a bank by lookups | fill-wait cycles | a fill written over a lookup's bank cycle |
| A CE on a hit (injected) | corrected errors; withheld completions; corrected refills | completing anyway retires uncorrected data |
| A UE in a clean line (injected) | recoveries; table entries in use | no refetch: the load hangs |
| A second UE at a recorded row, and a UE with the table full | fatal errors, by cause | treating either as recoverable |
| A UE in a dirty line | fatal errors; withheld reads | returning the line retires bad data |
| A machine-check kill with a retired store's merge read withheld (TI-487) | kills completed with a store still held in MIU | a kill that waits on MIU's ack hangs |

Errors are reached by injection: `CCV_DCU_ECC_INJECT` (TI-484; AR 401 moved it from MIU's `CCV_MIU_ECC_INJECT`) and whatever
DCU-side injection DI asks TI for, as a DI row.

## 4. What DI waits on

None blocks the model. Each open item is a parameter with the default the
model builds with; a measurement moves a default, never the structure.

| Item | Owner | Row | Default | Meanwhile |
|---|---|---|---|---|
| `CCV_DCU_BANK_QDEPTH`, `CCV_DCU_BANK_STDATA`, the two credit-return vectors (TI picks the channel) | TI | MA-25 | 16, 12 | named constants; wire the vectors when TI lands them |
| `CCV_DCU_WAYPRED_BITS`, `CCV_DCU_WAYPRED_SEL`, and `CCV_LAT_L1_HIT` derived from them; `pa_fold` on `ccv_miu_dcu_req` | TI | MA-26, MA-30, AR 405, DA rev 128 | 4 bits, index (MA-30, AR 405; 5 and recent until TI lands it), so L1_HIT 8 | build both pipelines; test bits 0 and 4; compute the fold from the PA until the field and TI's wayfold helper land |
| `CCV_DCU_BANK_AGE` | RH's sweep, then MA | MA-25 | 16 (sweep 8, 16, 32, 64) | read it from the parameters |
| `CCV_DCU_BANK_HASH` (the within-page bank hash) | TI, RH's sweep | MA-20 | off | one bank function, so the hash changes one place |
| `CCV_DCU_UE_TRACK` | landed | TI-485 | 16 | — |
| The SRAM wrapper's BIST style and `ccv_common_err` (the error-event sink) | TI | TI-474, TI-475 | tied off | the model needs neither; the RTL waits |
| `makeDcu` selecting DI's model (TI adds a value beside `p1`; the stub stays the default until M0), the files in blocks.list, a `check-dcu-unit` job, the lock-step job | TI | a DI row with TI in Needs, your first | — | unit tests |
| Phase 2, the slices after the L1-hit path (miss buffers, fills, eviction and writeback, stores and the merge, probes, UE recovery) | MA | DI-20, DI-30; DCU tab, "MA's Phase 2" | slice 1 landed (tab rev 82); slice 2 part 1, miss buffers and fills, landed (tab rev 89); parts 2 to 4 (eviction and writeback with DI-21, stores and the merge, probes, UE recovery) to come | slice 1's modules, then part 1's |

## 5. Build order, setup and the others

- **Build order** is [`miu-impl.md`](miu-impl.md) section 6's: phase 0 setup;
  phase 1 the model (M0) against the MIU stub, every kernel and control on
  both hosts, every bin reached, cycles against the stub's and against
  `CCV_DCU_IMPL=p1`'s (the second should agree to within what `dcu_p1.cpp`
  leaves out); phase 1b with MI's model; then the RTL, in the phases below.
  **MA reads each exit row.**
- **RTL modules: Phase 2 slice 1, the L1-hit path** (DCU tab rev 82,
  section "MA's Phase 2"; DI-20). rtl/dcu/, named and partitioned exactly
  as the tab's module table: `ccv_dcu`, the top (`ccv_common_clk`, children
  and wires only, the generated stub's name and ports); `dcu_cap` ×4,
  `dcu_btag` ×8, `dcu_bctl` ×8, `dcu_bdat` ×8, `dcu_rarb`, `dcu_rslot` ×4,
  `dcu_fix`, `dcu_err`, `dcu_wake`. Each port's budget is the tab's port NGD
  table, transcribed into `<module>.ngd.json` with `"by": "MA"`. Later
  slices may add modules or ports to these.

| Phase | Build | Exit, and who reads the row |
|---|---|---|
| 2a, lookup | `dcu_cap`, `dcu_btag`, `dcu_bctl` (arbitration, queue, PLRU and fold flops, drop) | per module: a bench against the model's D0 to D2 (tag result, predicted way, mispredict, queue, `ent_ret`), check-cg and check-ngd at the tab's budgets |
| 2b, data and return | `dcu_bdat`, `dcu_rarb`, `dcu_rslot`, `dcu_err` | the same, against the model's response at H+6 and H+7 and its CE and UE events |
| 2c, the CE rewrite and wake | `dcu_fix`, `dcu_wake` | the same, against the model's rewrite (read to write 5 cycles, `ce_rewrite_full`) and wakes |
| 2d, the L1-hit block | `ccv_dcu` from slice 1's modules, the rest still the model's | the block as a sum of parts (check-cg's 2%, check-ngd level by level); an L1-hit kernel lock-stepped against the model in the SV top. **MA reads it** |
| 3a, misses and fills | `dcu_mshr`, `dcu_fill`, and what part 1 grows in `dcu_bctl`, `dcu_btag`, `dcu_rarb`, `dcu_rslot` (DCU tab rev 89, "Slice 2, part 1") | per module against the model's miss path: merge or allocate or miss-wait at D2, the MLC request at H+5, a fill's answers at F+4, the write at W with tag-stale re-looks; the part's bins, CHECKs and its four controls |
| 3 onward, the other paths | each slice MA lands | per module as above; then the whole block, then SV-hosted equivalence on every kernel and control |
- **Setup** is [`miu-impl.md`](miu-impl.md) section 8's, with your roster
  entry `DI`, your handoff `.claude/handoff/DI.md` and your sweep at minute
  43.
- **MI** builds the MIU model beside yours. The bank credits, the mispredict
  on the loser's path, the withheld completion and the UE-withheld read cross between
  the two models: agree in your tabs which lands first, so each model passes
  against the other's stub first and the other's model second.
- **MA** answers every architecture question and folds each answer into the
  DCU tab and its snapshot. **TI** applies schema, parameter, stub and gate
  changes. **AR** owns MLC's side of the coherence channels. **RH** can take
  long runs; ask Daniel first.
