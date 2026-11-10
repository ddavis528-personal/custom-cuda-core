# MIU architecture: handoff to the MIU architect session (MA)

Written by AR on 2026-11-10 for the session that starts here. That day
Daniel chose MIU as the next block after OOE and RCU (DA tab, that date). AR
had recommended it because the C++ stub MIU and DCU set the ceiling on every
memory-bound figure the performance register holds. This file says:

- what the MIU is today, what has been decided and where it is written;
- which promises other blocks already count on;
- what is still open;
- a plan skeleton for MA to fill.

**AR expects MA's first output to be questions, not a plan.** Section 8 says
where they go.

Read this once, end to end. After that, the sources of truth are the ones in
section 2, not this file. Like every pinned summary, this one goes stale.
`docs/rcu-arch.md` is the RCU's equivalent and shows how RA used it.

## 1. Who MA is, and what it owns

**MA, MIU and DCU architecture.** MA mints `MA-n` in its own register tab.
AR made that tab, empty, at Daniel's request. Daniel gave MA the DCU as well
the same day (DA tab, 2026-11-10, second row). MA owns:

- the MIU's block architecture;
- its spec, the MIU tab of the per-block specs, which passes from AR to MA;
- its microarchitecture and internal budgets:
  - the AGU pipes and the coalescer;
  - the TLB and the page-table walker;
  - the load and store buffers and the `req_id` tables;
  - disambiguation and ordering;
  - atomics passes, SPM passes and the st.pred drain;
  - per-port NGD budgets (`<module>.ngd.json`);
- the MIU's side of every channel contract;
- the DCU's block architecture as well: its spec (the DCU tab, which passes
  from AR to MA and whose internals are "not drafted"), its lookup, tags,
  data arrays, fills, writebacks and MLC side, and its side of every channel
  contract. The L1-hit contract, `CCV_LAT_L1_HIT` = 7, spans MIU's AGU,
  DCU's lookup and the data's return; owning both sides is what lets you
  budget it.

The other owners:

- **MI and DI** implement the MIU and the DCU, as separate sessions (Daniel,
  2026-11-10: "we will have separate agents (MI and DI) to own
  implementation for those two units"). Their prefixes are reserved in the
  Conventions tab, with no tab or session yet. Each starts from a handoff you
  write when that block's architecture is ready, as RA wrote
  `docs/rcu-impl.md` for RI: you make its register tab, its roster entry and
  that file.
- **AR** stays the top-level architect. AR owns:
  - partitioning and floorplan adjacency (Q-42);
  - cross-block contracts and conventions;
  - the performance register (`docs/perf-register.md`, PF-30 onward);
  - the specs of blocks that have no session.

  Bring AR anything that crosses a block boundary or moves a top-level
  parameter.
- **TI** owns `schema/`, `params/`, `tools/`, `rtl/top/` and the gate. It
  also owns every block's stub, the MIU's and DCU's included (section 6). An
  interface or parameter change is a row in MA's tab with TI in Needs. MA
  never edits the schema directly.
- **OA / OI** own OOE's architecture and implementation. OOE sends MIU the
  memop and its retire, and takes MIU's completion and hint. It counts on the
  L1-hit contract for its speculative wake.
- **RA / RI** own RCU's architecture and implementation. RCU sends the
  memop's operands (`ccv_rcu_miu_addr`) and takes the load data
  (`ccv_miu_rcu_data`).
- **IS** owns the ISA. Every address form, fault, ordering and atomic rule
  MIU implements comes from IS's document in the pinned compiler snapshot.
  An opcode-level question goes to IS.
- **CP** owns the compiler. Window, frame and spill layouts (O-69, O-83) are
  shared with it.
- **DA** is Daniel. He decides cost and scope trades, and anything no agent
  owns.

**Who builds the MIU is not decided.** RCU had RI, a C++ model first, then
RTL. Whether an MIU implementation session (MI, the prefix the Conventions
tab reserves) follows, and when, goes to DA too.

## 2. Sources of truth, in order of authority

1. `schema/interfaces.json`: every MIU channel, field, width, rate, lead
   field and slot attribute. `docs/payload-spec.md` is the readable form,
   generated from it. Where any prose disagrees, the schema wins.
2. `params/ccv_params.json`: every size and latency (the `CCV_*` names
   below), with `derive` and `require` for the derived ones.
   `params/links.json`: repeater stages and end treatments per channel.
3. The **MIU tab** of *Per-block architecture specs*
   (https://claude.ai/artifact/DJeg9Hh8rkPDecq4hrAz35, MIU tab, rev 63; tab
   id c4c7d09e-a445, body aa7a288a-dae2). It is yours from now on. Parts of
   it are stale (section 5), and reconciling it is your first task. The DCU
   tab (rev 17; tab 8c191d75-5ff3, body c18a112b-d2c6) is beside it.
4. *OOE microarchitecture, Stage 4*
   (https://claude.ai/artifact/7tpEyGaCvfdvYYWUQJvJSU) and the RCU spec
   (https://claude.ai/artifact/4k7VrEKJG4KUgMYG1Qz8mB): your two partners'
   sides of each contract. Pinned copies are in `docs/design-snapshots/`.
5. The register (https://claude.ai/artifact/JApHYjaUESeq8tsGMGXMU5). Read
   the Conventions tab first. To find a decision's thread, search its ID
   across tabs. Most MIU threads sit in the AR tab, because AR has held the
   MIU spec until now. Section 4 lists the ones that matter.
6. `docs/open-items.md` (Q-n), the repository's own tracker.
7. The stubs, `class Miu` and `class Dcu` in `sim/skel/kernel.cpp`. They
   are the executable reference for MIU and DCU behaviour on every kernel the
   gate runs, on both hosts. They are functional. **Their timing and their
   resource model are placeholders**, and that is the reason this session
   exists (section 6).

## 3. The MIU in one page

Block M, `ccv_miu`, one instance. It holds:

- four AGU pipes (`CCV_MIU_PIPES` = 4, arch). A memop's footprint is 4, 2 or
  1 pipes at 32-, 16- or 8-bit `chwidth`, and slot k of `ccv_rcu_miu_addr`
  is pipe Pk;
- the coalescer;
- the TLB, with `CCV_TLB_XLAT_PER_CYCLE` = 4 translations a cycle on the hit
  path, and a page-table walker that may be shared with FET's ITLB;
- the load and store buffers;
- the per-hop `req_id` tables;
- the per-CTA bounds and window table;
- every execute-stage memory fault.

It routes each lane's access to DCU (global, local, const) or to SPM
(shared). It holds no register state: the destination it writes is echoed
from the memop (Q-25).

**Its channels** (from the schema; rate = slots a cycle; bits a slot):

| Channel | Dir | Rate | Bits | What it carries |
|---|---|---|---|---|
| `ccv_ooe_miu_memop` | OOE → MIU | 4 | 126 | The memop: `rob_tag`, `done_row`, `rs_idx`, `phys_dst`/`dst_pos`/`phys_pred`, `issue_mask`, warp and CTA slot, `mem_op`, `chwidth`, `pipes`, `disp`, `space`, `ordering`, the slot and local forms, `xfer_size`/`xfer_signed`. `discard_tail` overlays `disp` when `mem_op` = 0xF. |
| `ccv_rcu_miu_addr` | RCU → MIU | 4 | 3,111 | The operands: `active_mask`, `base_per_lane`, `index_per_lane` and `store_data` at 1,024 bits each, plus `rob_tag`. Fixed latency and no stall path: MIU never refuses an address. About 12,400 wires, the widest interface in the design. |
| `ccv_ooe_miu_retire` | OOE → MIU | 4 | 8 | `rob_tag`, commit or discard. |
| `ccv_miu_ooe_cmpl` | MIU → OOE | 4 | 120 | The completion: status, cause, `lane_mask`, fault address, `mlc_miss`, `more`, `lead_fault` (a lead field). Fixed latency. |
| `ccv_miu_ooe_cmpl_hint` | MIU → OOE | 4 | 13 | `rs_idx`, `rob_tag`, exactly `CCV_LAT_CMPL_HINT` before its completion (`notice_of`). |
| `ccv_miu_rcu_data` | MIU → RCU | 4 | 1,114 | `load_data` (1,024) and `pred_result`, with the echoed `phys_dst`, `dst_pos`, `dst_width`, `phys_pred`, `pred_we`, `active_mask`. Six lead fields (51 bits, RA-40). Fixed latency. Credit on receipt at RCU (RA-41). |
| `ccv_miu_dcu_req` | MIU → DCU | 4 | 1,212 | `req_id`, `phys_addr`, size, `coh_op`, `exclusive_req`, `write_data` (1,024), `byte_mask` (128). Rate `CCV_DCACHE_LOOKUPS`. DCU may hold a request ("held", DCU spec rev 15). |
| `ccv_dcu_miu_rsp` | DCU → MIU | 4 | 1,031 | `read_data`, `hit`, `ownership_granted`, `mlc_miss`. |
| `ccv_dcu_miu_fill_ntc` | DCU → MIU | 4 | 4 | `req_id`, exactly `CCV_LAT_FILL_NOTICE` before its response. A promise once sent. |
| `ccv_miu_spm_req` / `ccv_spm_miu_rsp` | MIU ↔ SPM | 4 | 1,477 / 1,033 | Bank-addressed shared-memory passes. `byte_mask` is ANDed with `active_mask` (A-20). The response carries `conflict_serialization`. |
| `ccv_fet_miu_itlb_req` / `ccv_miu_fet_itlb` | FET ↔ MIU | 1 | 60 / 64 | ITLB refills, one outstanding. |
| `ccv_rau_miu_cta` | RAU → MIU | 1 | 277 | A CTA's SPM base and limit, launch block, const range and local base. |
| `ccv_miu_rau_ready` | MIU → RAU | 1 | 5 | A parked warp's abandoned loads are all answered (TI-21). |

DCU's other channels go to MLC: the request, the response, the probe (a wake
source) and the probe's ack. `params/links.json` puts no repeater stages on
any MIU or DCU link today, and both blocks are DPI hosts in its `no_flop`
list.

**Its sizes and latencies** (status in brackets; `params/ccv_params.json`
at cf613958):

- `CCV_LAT_L1_HIT_BASE` = 7 (tunable), giving `CCV_LAT_L1_HIT` = 7. It runs
  from the cycle MIU holds both the memop and its address (A-61, Q-54).
- `CCV_LAT_RCU_ADDR_BASE` = 5 (tunable), RCU's issue-to-address time.
  - PF-47 takes it toward 1 or 2. It is approved in principle (RA-31) but
    not yet re-applied in params.
  - `docs/rcu-arch.md` section 3 already quotes 1, so check params before
    quoting either.
- The derived latencies:
  - `CCV_LAT_L1_WAKE` = 17;
  - `CCV_LAT_L1_CMPL` = 18 since RA-43 made `ooe_rcu_issue` zero-cycle at
    RCU. Under PF-47 they become 13 and 14;
  - `CCV_LAT_L1_MISS_WAKE` = 1;
  - `CCV_LAT_RCU_KILL_DRAIN` = 15.
- `CCV_LAT_CMPL_HINT` = 2 (arch), `CCV_LAT_MIU_FILL` = 2 (provisional; "the
  MIU session confirms"), `CCV_LAT_FILL_NOTICE` = 4 (provisional, = HINT +
  MIU_FILL).
- `CCV_DCACHE_LOOKUPS` = 4 (tunable). The L1 is 8 ways (TI rev 234). Its
  capacity is unset: 64 KiB and 512 KiB are the candidates, and AR owes the
  sweep at 8 ways. No DCU geometry parameter exists; sets and ways are stub
  environment variables only.
- Widths, all provisional:
  - `CCV_P_W_REQ_MIU_DCU` = 4 and `CCV_P_W_REQ_MIU_SPM` = 3. The buffer
    depths you choose set these;
  - `CCV_P_RS_MIU` = 15;
  - `CCV_P_W_PA` = 48;
  - `CCV_P_LINE_BYTES` = 128;
  - `CCV_L_PAGE_SHIFT` = 12 (preliminary).
- Encodings:
  - `CCV_L_W_MEM_OP` = 4, preliminary: 0 ld, 1 st, 2 A1, 3 A3, 4 ld.pred,
    5 st.pred, 0xE fence, 0xF discard;
  - `CCV_L_W_SPACE` = 1 and `CCV_L_W_ORDERING` = 5, both isa.

## 4. What is decided, and where it is written down

Cite these; don't restate them. Each is a register thread or a Q-n.

- **The AGU stays in MIU** (Q-18, closed 2026-11-04; AR's response RA-10,
  RA-36). `ccv_rcu_miu_addr` is a floorplan adjacency, not a partitioning
  change. TI deleted the schema question.
- **The L1-hit contract** (A-46, A-47, A-61, Q-54; OA-5):
  - a hit's completion and data come at exactly `CCV_LAT_L1_HIT` from the
    holding cycle, and their absence at that cycle is the miss;
  - data and completion leave together, or neither leaves as a hit;
  - OOE wakes dependants speculatively on it, and `OA-17`/V-67 (a
    stale-ready grant never confirms) is the check that the speculation is
    safe. It is clean since OI's 11386e7.
- **The refill hint** (OA-23, TI-23; AR 93 to 95, MIU spec rev 16):
  - DCU originates the notice, and MIU carries it on as the hint to OOE;
  - each is exactly its latency ahead, kept by reserving the slot and its
    credit;
  - the hint echoes the RS identity statelessly. Check `rob_tag` for
    staleness, not the 1-bit `rs_gen`, which aliases.
- **The end treatments.**
  - `miu_rcu_data` keeps its receiving flop at RCU (DA 116, 2026-11-09:
    zero-cycle gained S1 −0.26% and cost cm128 +1.27%).
  - `miu_ooe_cmpl` and its hint are zero-cycle at OOE (C9, AR 335). The two
    must keep one treatment.
  - MIU's end of `rcu_miu_addr` is 0 NGD. Flopping it adds a cycle to
    L1_WAKE and L1_CMPL.
- **Stateless write-back** (Q-25): MIU echoes `phys_dst`, `phys_pred` and
  `pred_we`. Coincident `miu_rcu_data` slots write disjoint sections, and
  MIU never writes an inactive lane; the copy op does (A-33, A-38).
- **The completion is MIU's alone.** RCU sends no done for a memop (DA tab;
  a late done could match a reused `rob_tag`).
  - There is exactly one completion per accepted memop, and none for a
    discard.
  - A1/A3 status is 0 or 1, and `lead_fault` == (status == 1) (OI-125).
  - `mlc_miss` rides the completion and is the demotion trigger (TI-24 (5);
    PF-39 is its early-notice alternative).
- **Ordering and stores:**
  - memops issue in program order per warp, and MIU orders memory; OOE does
    no disambiguation (PF-6);
  - a load waits behind any older overlapping store or atomic of its warp,
    at line granularity, with no forwarding (TI-27 (d); PF-7 and PF-42 are
    the alternatives);
  - committed stores carry no live tag and drain through teardown (TI-24;
    AR, MIU spec rev 17).
- **Discard, replay and orphans** (TI-21, OI-127):
  - `mem_op` 0xF with `discard_tail` drops a warp's uncommitted memops.
    Atomics (`mem_op` 2/3) are exempt;
  - orphans are counted per warp, and `ccv_miu_rau_ready` reports a parked
    warp clean;
  - after a replay completion or a kill, nothing more is written to RCU
    except a data beat already started.
- **Addressing and faults:**
  - MIU owns every execute-stage memory fault. Only lanes in `active_mask`
    raise one, and the lowest lane with the highest cause wins;
  - `.shared` is 32 bits with the carry dropped, and F-SHARED is checked on
    the wrapped address (CP-33);
  - narrow address registers are zero-extended (O-79);
  - sized loads and stores (O-80) need their sized fill to fit
    `CCV_LAT_L1_HIT` without a stage;
  - F-RO covers the launch window and the `.const` range (TI-26, O-51);
  - the slot-form window table is about 4,096 flops (TI-31);
  - interleaved local (O-69) and private window W (O-83, IS-24/IS-25) are
    built and priced. AR's estimate is about 2 NGD.
- **Atomics:**
  - addressed as Format D (O-72), with the line held from A1 to A3;
  - one lane per address a pass, in ascending lane order (IS-21);
  - `atom.add.f32` adds in LANE, not MIU: no FP outside LANE (O-76).
- **st.pred** is a read-merge-write drain after commit (O-63, IS-18).
  `ld.pred`/`st.pred` crack to one uop per predicate (TI-36).
- **DCU** (its tab):
  - write-back, write-allocate with ownership (TI-36);
  - a full-line store miss is an AcquirePerm, with no data;
  - DCU holds a request only behind a memory stall (TI-22, so
    `CCV_P_TIMEOUT_BP`);
  - a probe never cancels a promised response.

## 5. What in the MIU spec is stale (AR's debt, yours to reconcile first)

AR checked the MIU tab against the schema and params while writing this.
Fix these before building anything on the spec.

- **Q-18** is still "open" and still the Risks' "defining question" and the
  first session question, at "~8,400 wires". It closed on 2026-11-04 (AGU
  in MIU), and the channel is ~12,400 wires.
- **`ccv_miu_ooe_cmpl`** is "110 bits per slot" in the prose and 119 in the
  wires table; the schema has 120. Its field table lacks `done_row`,
  `rs_idx`, `more` and `lead_fault`.
- **`ccv_miu_rcu_data`'s field table** lacks `dst_pos` and `dst_width`. Its
  total already counts them.
- **The L1 contract paragraph:**
  - it says `ooe_rcu_issue` is flopped at RCU; it has been zero-cycle since
    RA-43;
  - it gives `CCV_LAT_L1_CMPL` = 19 where params have 18, and "15 at PF-47's
    base" where the value is 14;
  - L1_WAKE 17, and 13 under PF-47, still hold.
- **The undecided-encoding list:**
  - `CCV_L_W_SPACE` = 3 and `CCV_L_W_ORDERING` = 4 are now 1 and 5, both
    isa (IS-11);
  - `mem_op`'s "prefetch" was removed.
- **Alignment** is asked as open but settled by O-58, which the tab cites
  elsewhere.
- **The 4-bit access fault** is now F-WIDTH, OOE's at dispatch (O-80); the
  tab's own sized-load section says so.
- **The bulk-discard bullet** says "discards every store". It also drops
  uncommitted loads (TI-21), and it exempts atomics (OI-127).
- **"What the S1 model does today"** says "one memory operation at a time".
  The stub runs up to four jobs (section 6).
- **The wake sideband** counts "7 inbound channel wakes" against 8 inbound
  channels. This probably predates `fill_ntc`; check it.
- **Tier labels** say "settled" where the schema now says isa or arch.
- **Missing:** the sectioned footprint (the `pipes` field, OI-33's slices,
  slot k = pipe Pk) appears only through RA-21.
- **The DCU tab** still says "the schema's pending note waits on this
  statement". The schema reads "held (DCU spec rev 15, AR-25)".

## 6. What is open

**Promises other blocks are already built against, which only MIU's build
can keep.** These come first: each one that fails sends a change back to
OA/OI or RA/RI.

1. **An L1 hit in exactly `CCV_LAT_L1_HIT` = 7 from holding.** That covers
   the AGU sum (with the window and frame forms, O-69/O-83), translation, the
   DCU lookup, way select, the sized fill and data out. This is the
   contract with the least slack; budget it first.
2. **Never refuse an address.** `ccv_rcu_miu_addr` has no stall path, so
   MIU must have room for every memop OOE issued.
3. **The hint, exactly `CCV_LAT_CMPL_HINT` = 2 ahead,** never displacing a
   contracted hit.
4. **`CCV_LAT_MIU_FILL` = 2,** notice to hint. It is provisional and waits
   for you.
5. **One completion per memop.** A kill and a discard are answered without
   dropping a retired store.

**The spec's own questions** (MIU tab, verbatim where quoted):

- "TLB size, associativity, and whether the walker is shared with FET or
  duplicated."
- "Load and store buffer depths, which set the `req_id` widths."
- "Page-split serialization: one lookup port or spread across four." Today
  translation assumes a warp's lanes fall in one page.
- The coalescer: per pipe or shared.
- Disambiguation width (4-wide).
- In the text, waiting on you:
  - whether O-80's sized fill fits `CCV_LAT_L1_HIT` without a stage;
  - O-83's ~2 NGD;
  - `CCV_LAT_MIU_FILL`.
- From the AR tab:
  - the pass deadlock rule ("a pass never waits for a line while holding
    another"), whose spec status is unconfirmed;
  - a warp-uniform base on the AGU's base input, option (c), which needs
    IS-24 to fault b outside [0, 2^32) and a 128-byte-aligned base.

**DCU's questions** (its tab):

- four tag lookups a cycle: multi-ported, or banked with conflict
  serialization;
- the TL-C subset, and with it `CCV_L_W_COH_OP`;
- capacity.

**Repository items:**

- **Q-53 (scheduled, with each block):** MIU's half is the outstanding-tag
  checker on `ccv_miu_ooe_cmpl`, which needs MIU's squash state. Name the
  rest.
- **Q-60 (open, under Q-50):** a host remap between launches never reaches
  MIU's TLB. AR proposes that a CRU command, issued while launch is closed,
  invalidates it. Put it in the spec; the channel waits on Q-50.
- **Q-42 (open, AR's):** full abutment, meaning the floorplan neighbours of
  MIU: RCU (the widest channel), DCU, SPM and OOE. It changes port lists, so
  it settles before MIU's RTL.

**Performance items naming MIU** (`docs/perf-register.md`; AR owns it, and
your numbers are welcome there):

- PF-2 (cancel squashed memops at MIU) and PF-4 (speculative memop issue);
- PF-5 (split store address from data) and PF-6 (loads pass older stores);
- PF-7 and PF-42 (store-to-load forwarding);
- PF-8, PF-9, PF-10 and PF-11 (the L1 hit, miss and wake signals);
- PF-23 (demotion abandons outstanding loads);
- PF-33 (fewer crossings on the L1-hit path);
- PF-34 (atomics combining);
- PF-39 (an early MLC-miss notice);
- PF-41 (restore before ready);
- PF-43 (a per-lane base field);
- PF-46 (interleaved per-thread memory);
- PF-47 (RCU's address time).

None needs action now. Read them before deciding the buffers and the
ordering, since several move ports.

**The stubs, and why this session exists.** At cf613958:

- **`class Dcu`** (`sim/skel/kernel.cpp` from line 517):
  - models an L1 of `CCV_DCU_SETS` × `CCV_DCU_WAYS`, default 64 × 8 with
    LRU (the comment near line 550 still says direct-mapped);
  - write-back with ownership;
  - a hit answers the cycle it arrives, with hit-under-miss;
  - one MLC request per `req_id`;
  - the refill notice, with the slot reserved;
  - no probes, banking, port conflicts or pipeline timing.
- **`class Miu`** (from line 875):
  - up to four jobs in flight, but `start()` begins one a cycle, in this
    order: committed stores first, then an atomic's A3, then only the head
    of one global order. **A held load blocks every memop behind it, every
    warp.**
  - A job holds its pipe from start to completion, misses included. The
    spec's pipe is a pipelined AGU stage busy one cycle a memop, with misses
    parked in the buffers.
  - No TLB (VA is PA), no coalescer, no sized buffers, no forwarding, and no
    F-ALIGN check.
  - It does model the faults, windows, SPM and atomic passes, the st.pred
    drain, hints, replay and orphans.

The consequence is in the performance register (J9 to J11, AR revs 318 to
321):

- a +19% step on the vadd16 loop was the stub's 1-way L1, not RCU. It fell
  to +3.1% at 8 ways;
- TI's local four-start patch (never merged) moved cm128 +26.1%, with waits
  for a free pipe going from 4.26M to 9.59M;
- so cm128's memory-bound figures, and every zero-cycle-end and PHYS_REGS
  price measured on them, are **bounds, not measurements**.

A spec-faithful MIU model is what turns them into measurements.

**The stubs' controls.** Each claim in the gate has a negative control that
must fail. The MIU and DCU `--break` controls (`tools/check-kernel.sh` runs
them):

- MIU:
  - echoes and timing: `corrupt-echo`, `corrupt-load`, `one-line`,
    `rs-echo`, `late-cmpl`, `late-hit-data`, `early-hit`;
  - stores, replay and readiness: `drop-store`, `drop-replay`,
    `replay-twice`, `no-ready`, `early-ready`, `no-st-wait`;
  - hints and fault leads: `hint-wrong-tag`, `lead-fault-drop`,
    `lead-fault-replay`;
  - address forms and windows: `no-ro`, `addr-wrap`, `no-window-fill`,
    `window-from-base`, `local-base-slot`, `local-no-ctx`, `priv-lane0`,
    `priv-no-ctx`;
  - sized transfers: `xfer-ignored`, `xfer-low-lane`, `wide-xfer`;
  - predicates: `ldpred-whole-word`, `stpred-whole-word`;
  - atomics and SPM: `atom-one-pass`, `atom-no-more`, `atom-descending`,
    `spm-one-pass`.
- DCU: `skip-read-partial`, `write-through`, `drop-writeback`,
  `dcu-one-miss`, `notice-wrong-id`, `late-refill`.
- MLC: `deny-ownership`.

A real MIU must keep every one of these failing. Never weaken one.

## 7. A plan skeleton for MA to fill

AR's proposed order, not a decision. Each phase ends in something
measurable. Change the order if your questions show a better one, and say
why in a row.

- **Phase 0, reconcile (days).**
  - Fix section 5 in the MIU spec against the schema and params.
  - Raise every row that section 8 implies.
  - Put this file's open list into your tab as `MA-n` opens, each with an
    owner in Needs.
- **Phase 1, the resource model first.** This is what moves the performance
  register and the top-level parameters, so it comes before the
  microarchitecture. Decide, with the arithmetic:
  - the pipe model (busy a cycle, or longer for a split footprint);
  - the load and store buffer depths, and so the `req_id` widths and
    `CCV_P_RS_MIU`;
  - where misses park;
  - how a held load blocks: per warp, never across warps;
  - the coalescer;
  - the TLB's hit path and miss path;
  - the DCU's lookup ports, its geometry parameters (`CCV_DCU_SETS`,
    `CCV_DCU_WAYS`) and where its misses park.

  **Exit:** a behavioural spec precise enough for TI to make the MIU and DCU
  stubs spec-faithful. Then re-run S1, cm32 and cm128 at 8 ways, so the
  booked deltas that rest on the stub get re-checked against Daniel's 0.2%
  bar (DA 114). If the figures move a top-level parameter (`CCV_MIU_PIPES`,
  `CCV_DCACHE_LOOKUPS`, the L1 capacity), bring it to AR.
- **Phase 2, microarchitecture.** For the L1-hit path, give the stages from
  holding to data out at `CCV_LAT_L1_HIT` - 1, with an NGD budget per port:
  - the AGU and its forms;
  - translation;
  - DCU lookup and way select;
  - the sized fill;
  - write-back section scheduling.

  Then the miss and refill path (the notice, the hint, `CCV_LAT_MIU_FILL`),
  stores and the drain, atomics and SPM passes, faults, discard, replay and
  kill. The deliverable is a module partition (sub-blocks, inner helpers,
  units) that the gate can time level by level.
- **Phase 3, implementation plan.** Both blocks start with the C++ model,
  as RCU did (RI's `docs/rcu-impl.md`). Daniel, 2026-11-10 (DA tab): "both
  MIU and DCU implementation should start with the C++ model. Emphasis
  should be put on making sure that all important events are covered in the
  model. Of course, the model may evolve as the RTL uncovers timing
  limitations." MI implements the MIU and DI the DCU; each block's plan
  becomes its implementer's handoff (a miu-impl.md and a dcu-impl.md in
  docs). Plan, per block:
  - the important events the model must cover, named in the architecture
    and carried into the handoff as coverage bins, each with a negative
    control that must fail. At least: L1 hit and miss on every pipe; a fill
    and its notice and hint; a held request; a write-back; a split
    footprint; a TLB miss and walk; every fault; discard, replay and kill
    against an in-flight miss; an atomic and an SPM pass; the st.pred
    drain; a full buffer on every queue; same-line and cross-warp ordering
    hazards; a DCU request held behind a memory stall. The architecture
    decides the full list; this is AR's floor;
  - the model behind the swap boundary (`sim/skel/blocks.list`);
  - the RTL's units for check-cg and check-ngd;
  - the MIU-internal checkers (Q-53).
- **Phase 4, verification and closure:**
  - every stub control, carried to the model and the RTL;
  - SV-hosted equivalence;
  - kernel coverage bins for every event in Phase 3's list, MIU's and
    DCU's, with the kernels or directed stimulus that reach each;
  - where the RTL finds a timing limit, the model changes with it (and the
    spec, by an MA row, when a contract moves), and the bins re-run.
  - the performance items that the measurements make worth reopening.

**Compute is the constraint. Design for the gate from day one:**

- `ccv_rcu_miu_addr` alone is 3,111 bits a slot. Never put a whole slot's
  datapath in one unit. Units measure sub-modules at small parameters (see
  `test/rcu/` and `test/ooe/` for how RA and OA did it), and the assembled
  block is checked from its `.ngd.json` budgets, level by level.
- A working-branch push takes the scoped gate (`tools/verify.sh --changed
  <base>`, SCOPED PASS). The synthesis cache is shared; only the daily
  sweep's merge runs the full clean gate.
- Long experiments can go to RH, DA's run helper (roster). Ask DA first.
- Use `run-tabulate` for sweeps and `gate-triage` for a red gate, so their
  logs stay out of your context.

## 8. The questions AR expects, and where each goes

MA should come back with many questions. Raise each as a row in your tab,
with its answerer in Needs, and notify them (the register skill, section
2). AR expects at least these:

- **To DA:**
  - Answered 2026-11-10: MA takes DCU, and MI and DI implement (section 1).
    Both start with the C++ model, covering every important event (DA tab,
    2026-11-10, third row). Still open: when each implementer starts.
  - What priority does it have on compute (RH, `CCV_JOBS`) against OOE's
    and RCU's closure?
- **To AR:**
  - The L1 capacity (64 or 512 KiB), which AR owes as a sweep at 8 ways.
  - Q-42, MIU's floorplan neighbours.
  - Q-60's TLB invalidation.
  - Whether the coalescer or the TLB is its own block.
  - Any top-level parameter your Phase 1 moves.
- **To OA/OI:**
  - the L1-hit wake and its speculation (OA-17/V-67);
  - what OOE's model assumes about MIU timing that the stub hides;
  - PF-2, PF-4 and PF-23 if your buffers make them cheap.
- **To RA/RI:**
  - the address channel's timing (`CCV_LAT_RCU_ADDR`, PF-47);
  - write-back section scheduling on `miu_rcu_data`;
  - the lead fields (RA-40).
- **To TI:**
  - the spec-faithful stub (Phase 1's exit);
  - a home for MIU model and RTL files (sim/miu and rtl/miu, beside RCU's) and their
    entries in `tools/gate-scope.py`;
  - the units in `test/**/cg-units.json` and `ngd-units.json`;
  - every schema or parameter change the reconciliation exposes;
  - a DCU geometry parameter, if DCU's sets and ways should leave the
    environment.
- **To IS:** the address forms, the fault list and its priority, the
  ordering bits, and the atomics passes, all in the pinned ISA; and option
  (c)'s fault rule.
- **To CP:** window and frame layouts (O-69, O-83) wherever the AGU's forms
  depend on them.

## 9. Getting the session set up (first hour)

1. **Roster.** Write your session id into `docs/register/roster.json`,
   entry `MA`, in a commit of its own. AR has added the entry with
   `session: null` and your tab's node id (`1f971016-3f72`). That entry is
   how the handoff hook finds your prefix and how other agents notify you.
2. **Session home.** Run the `session-home` skill
   (`.claude/skills/session-home/`) so `.claude/settings.json` (the
   compaction window, the handoff hook) and `.claude/agents/` reach a
   session that runs from `/home/user`. It writes into the home directory,
   so ask Daniel to approve first, as every agent has. Then check it with
   `tools/setup-session-home.py --check`.
3. **Handoff.** Create `.claude/handoff/MA.md`: your working rules, branch,
   bookmarks and open work, in a few kB. Keep it current at every task's end
   (CLAUDE.md, "Context and handoff").
4. **Register.**
   - Read the Conventions tab and the register skill
     (`.claude/skills/register/SKILL.md`).
   - Search every tab for `MA` in Needs.
   - Create your daily sweep task as the skill's section 5 says, at minute
     35. The series runs AR 3, OA 7, TI 11, OI 15, CP 19, IS 23, RA 27,
     RI 31. AR has asked OA, the skill's owner, to add MA at 35. AR
     added MA to the Conventions tab's prefix table.
   - Read rows through the `register-reader` subagent. Ring a notice only
     for a row that asks something of its receiver.
5. **Your branch.** Work on the branch your session was given. Never push
   to another agent's. Merges take merge commits, never a rebase or
   force-push. A push needs a green gate: the scoped gate on a
   working-branch push.
6. **CLAUDE.md** in this repository is written for TI ("This session is
   TI"). Read it for the rules and the gate. Your role is the one in
   section 1 of this file.

## 10. The specs doc's ownership line

The MIU tab of the per-block specs now opens with an owner line naming MA.
From your first edit on, AR stops editing it. AR will send any cross-block
text it needs there as a row in AR's tab with MA in Needs. The DCU tab now
opens with the same line (DA tab, 2026-11-10, second row).
