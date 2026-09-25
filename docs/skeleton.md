# The Stage 3 skeleton

§8 Stage 3: *"Skeleton — all blocks, whole machine. Built against Stage 2's
interface contracts. Internal timing is placeholder."* Exit criteria: `vadd`
end to end through all blocks, architectural state identical to ccv-sim, a
complete load-bearing event stream that loads in Perfetto, and zero interface
assertion violations.

It is built in two milestones, because the second one is only worth anything
if the first is proven:

| Milestone | What it proves | Status |
|---|---|---|
| **S0 — plumbing** | Every block instance and channel instance exists and is wired to the right two ends; every slot carries traffic under backpressure; the protocol holds; every payload bit lands where both languages agree it should | **Done** — `tools/check-skel.sh` |
| **S1 — `vadd`** | An instruction stream flows through the real channel path, values carried by the channels, retiring state identical to ccv-sim | **Done** — `tools/check-kernel.sh` |

```
build/skel/ccv-skel --cycles 2000 --seed 1 --trace t.ccvtrace        # S0
build/skel/ccv-skel --kernel test/golden/vadd/oracle.jsonl \
                    --trace t.ccvtrace                                # S1
tools/trace2perfetto.py t.ccvtrace -o t.json     # one track per channel
tools/trace2perfetto.py t.ccvtrace --by=instr -o t.json   # per instruction
```

`tools/check-skel.sh` builds the binary and runs S0's checks, and
`tools/check-kernel.sh` runs S1's. Both run in the gate.

**Next: S2.** vadd leaves 15 of the 41 channels idle and never diverges, loops
or uses a second warp. S2 is kernels that do, as far as the open payload
questions allow.

---

## The decisions it rests on

These define the swap boundary, which §8 says is expensive to retrofit — so
they are written down rather than left in the code.

### 1. A cycle is two phases, and that is *because* of the round-trip rule

Every boundary is registered on both sides, no exceptions. So no combinational
path crosses a block boundary, and a cycle is: every block reads `cur` (the
flop outputs during cycle *t*) and writes `nxt` (cycle *t+1*); then every slot
commits. Block evaluation order cannot matter, because nothing reads `nxt`.

That is also what makes the §1 block swap work: a Verilated RTL block is
clocked with `cur` on its inputs and its outputs land in `nxt`, exactly where
a C++ stub's would.

### 2. Payloads are packed bits, in the SystemVerilog layout

Not C++ structs. At 4d an RTL block is swapped in behind the same channel and
it sees bits, so keeping the C++ side in bits means the swap changes who
produces them, never their shape. Field positions are generated
(`sim/generated/ccv_skel_wiring.h`), first field most significant.

**Cross-checked, not assumed.** The C++ offsets and the SV typedefs come from
two generators that agree by construction, which is exactly the agreement F-12
says not to trust at a swap boundary. `rtl/generated/ccv_skel_layout_probe.sv`
reads all 163 fields back *through the real SV structs* and compares them with
the C++ table: zero disagreements over 64 random rounds. Its negative control
shifts every C++ offset by one bit, and the probe must catch every field that
can be shifted — 160 of 160 (the other three are single-field payloads).

### 3. Interface checking is the SV checker itself, Verilated in

The skeleton is C++, and the obvious move is a C++ port of the checker. That
is the wrong one: a second implementation of the protocol drifts from the
first, and "zero violations" then becomes a statement about the port. Instead
`rtl/generated/ccv_skel_checkers.sv` instantiates the real
`ccv_credit_checker` once per slot — 340 of them — and the skeleton clocks it
with every slot's signals each cycle. The skeleton and every future RTL block
are judged by identical logic, and the load-bearing `EV_CH_XFER` stream comes
from identical code on both sides, which is what makes 4d correlation compare
like with like.

### 4. The protocol lives in one place

`sim/skel/channel.h` implements the credited protocol once — credit consumed
at the edge that launches valid, payload one cycle behind, no valid the cycle
after a stall, one credit back per message consumed. No stub can get it
wrong, because no stub implements it.

It was ported from `test/smoke/credit_smoke.sv` — and reading that closely is
how the reference producer's late-stall bug was found: it gated `valid` on a
registered copy of stall, one cycle late, and violated the rule at 14 of 28
stall phases while its smoke test passed. See `fail-open-register.md`.

---

## What S0 proves, and how each claim is kept honest

A checker bank that is not connected produces exactly the same clean run as
one that is. So every clean result has a partner that must **not** be clean:

| Clean result (3 seeds, 2000 cycles, ~151k messages each) | Negative control |
|---|---|
| 0 checker violations | `--break phantom-all`: all 340 checkers fire `no_phantom_credit`, each by name — proves every slot's `credit` wiring |
| | `--break stall-all`: all 340 fire `stall_honoured` — proves every `stall` and `valid` |
| `EV_CH_XFER` payloads (bits 63:0) **and trace ids** equal the launched ones, as a multiset | the match is exact, so one miswired payload or sideband bit fails it |
| 0 payload mismatches at the receivers; sent == received; no idle slot | — (end-to-end data check, independent of the bank) |
| `--force-atomic`: every multi-slot channel moves in whole groups, clean | `--break atomic-all`: all 77 atomic checkers fire both properties, and nothing else fires |
| Ordered channels are consumed in order per key — per binding group on fet→dec, per `warp_id` on dec→ooe — with different keys free to pass | `--break misorder`: taking a head that is not the oldest of its key is caught — on exactly the two ordered channels |
| Lane channels advance together: slot *k* moves on all 32 lanes or none | `--break lockstep-all`: one lane's slot alone — both lockstep checkers fire, nothing else |
| Slot *k* carries the same instruction on every lane | `--break misbind`: lane 7 carries slot *k*+1's instruction in slot *k* — only `lockstep_id` fires |
| Every message's id class is in its channel's set | `--break wrong-class`: all 41 channels report |
| The trace id exists only under `CCV_TRACE` | asked of Yosys both ways — absent without, present with |
| C++ field offsets == SV packed structs | `--mutate`: every shiftable field must disagree |
| **340 slots**, re-derived from the schema every run | — (see below) |

The payload wiring gets the event-stream check rather than a negative control
because Verilator is two-state: `payload_known_when_due` cannot fire there at
all, so an X-injection control is not available on this simulator.

### The slot count, derived

[`skeleton-slots.md`](skeleton-slots.md) is generated: the count term by term,
and every channel with its attributes. In short:

| Channel types | Rate | Instances each | Slots |
|---|---|---|---|
| 26 | 1 | 1 | 26 |
| 11 | 4 | 1 | 44 |
| 2 | 4 | 32 | 256 |
| 1 | 6 | 1 | 6 |
| 1 | 8 | 1 | 8 |
| **41** | | | **340** |

That is 41 types and 103 channel instances: 39 at one instance, plus the two
lane channels at 32 each. Before the inbound external channel it was 40
types, 102 instances, 339 slots.

The review's point stands regardless: this is the one number a clean run does
not validate. A rate wrong by one on a ×32 channel moves the total by 32, and
every slot that exists is still checked. So `tools/check-skel.sh` re-derives
it from the schema with code that shares nothing with the generator
(`tools/skel-expect.py`), and requires the binary, the generated bank and the
document to agree with it.

---

## Interface decisions (2026-09-24, revised 2026-09-25), as built

### Rate > 1: independent slots, plus per-channel attributes

The mechanism is unchanged: `rate` independent credited slots, one checker each.
Only **decided** attribute values are written in the schema, each with its
reason. The generators apply the permissive default otherwise and mark which
is which, so a default is never read as a decision. `gen-interfaces.py`
rejects any specification that couldn't mean anything:
- an attribute on a rate-1 channel, or one with no reason recorded;
- `slot_group` ordering without binding;
- an ordering field that isn't in the payload;
- a binding group that doesn't divide the rate;
- lockstep on a channel with one instance.

| Attribute | Level | Decided so far | Checked by |
|---|---|---|---|
| `acceptance` | slots | none atomic yet | `ccv_atomic_checker`, all 77 multi-slot instances |
| `slot_binding` + `binding_group` | slots | fet→dec bound, groups of 2; lane channels bound, groups of 1; ooe→rcu issue free | `lockstep_id` on the lane channels (below) |
| `ordering` — a **key** | slots | fet→dec `slot_group`; dec→ooe `warp_id`; miu→ooe cmpl `none` | the stubs' in-order consumption, and `--break misorder` |
| `lockstep` | **instances** | both lane channels | `ccv_lockstep_checker`, one per lane channel |

**Atomic means the message, valid and payload together.** Confirmed: a
message is its valid *and* its payload despite the one-cycle stagger. So
`ccv_atomic_checker` requires valids and credits both to be all-or-none. It
exists before any channel is atomic on purpose, and its `enable` is the schema
flag OR a test override that can only switch it on.

**Ordering is a key, not a boolean.** Six uops from up to four warps have no
total order, only a per-warp one, and fet→dec's two slots per stream are
strictly program-ordered. So `ordering` is `none`, `slot_group` (one order
per binding group), or a payload field name (one order per value of that
field). A receiver may take a head only if no older message shares its key.
Different keys pass each other freely; one key never passes itself.

**Lockstep is the missing instance-level attribute.** Every other check looks
inside one channel instance; `ccv_lockstep_checker` looks across all 32. Per
slot *k*, valid and credit must be all-or-none across the lanes. Under
`CCV_TRACE`, when slot *k* lands on every lane, every lane must carry the
**same trace id**.

That last property is what makes binding checkable here. Lane 3 taking
instruction A in slot 0 while lane 7 takes it in slot 2 has matching valids
and different ids. Stall is not required to match: a lane may stall on its
own, provided the single sender holds every lane for it. A sender that
doesn't is caught by `lockstep_valid` plus `stall_honoured` on the stalled lane.

In the stubs, a decision that spans blocks — 32 lane blocks — comes from a
hash of (channel, slot, cycle) shared by every block, not a block's private
RNG. Otherwise the stub would break lockstep by construction. Lockstep costs
throughput, as it should: 256 of the 340 slots are lane slots, and the RCU
sender holds all 32 lanes whenever any one stalls, so runs carry ~151k
messages where they carried ~230k.

**The fet→dec binding key is still text, not a check.** "Tier-1 stream =
slot / 2" needs a payload field naming the stream; the payload carries
`warp_id` (32 warps), not the tier-1 slot. Its ordering, however, is now
checked through `slot_group`.

**What the stub got wrong on the way, and the check that caught it.** The
first keyed receiver served eligible heads in slot order and stopped at its
first failed coin. That starved fet→dec's higher binding groups: slots 4–7
were held past N = 32 cycles, and `response_within_n` fired 175 times — the
bounded-response check doing exactly its job, on the stub. It now picks at
random among eligible heads, with one coin per step. Not in slot order,
which is a fixed priority; not oldest-first, which is plain FIFO and would
never let one key pass another. Clean across eight seeds.

### The external port is a pair

`ccv_exb_ext_out` carries TL-C A + C + E; `ccv_ext_exb_in` carries B + D.
The testbench end is now a sender as well as a receiver, so the testbench can
initiate traffic into EXB — the path that inbound probes will take.

The widths are split from the old single preliminary 1760 bits, and that
number is worth a note. **1760 reproduces exactly as TL-C A + C + D + E plus
five per-channel valid bits** at the stated parameters (512-bit beat, 48-bit
address, 6-bit source, 4-bit sink). It never included **B**, the probe
channel, which is consistent with the port having been outbound-only. With B:
out = 1225 (A 641 + C 577 + E 4 + 3 valids), in = 1176 (B 641 + D 533 +
2 valids). Both are preliminary, churn high: flattened versus decomposed is
still EXB's call.

### Instruction identity is trace-only

Every message carries a 64-bit id in a sideband beside the payload, never in
it. In the RTL it's a checker port that exists only under `CCV_TRACE`, and
Yosys is asked both ways to prove synthesis never sees it. Layout
(`schema/events.json` `uid_layout`, in the schema hash):

| Bits | Field | |
|---|---|---|
| 31:0 | `seq` | 32-bit monotonic; instr: assigned at fetch |
| 47:32 | `sub` | nests one instruction's many transactions (page split) |
| 61 | `owned` | txn only: `seq` names the owning instruction |
| 63:62 | `class` | none / instr / txn |

A re-execution gets a new id and an `EV_ID_LINK` (new, old, reason). That
event is classed **arbitration-sensitive**: whether a load replays can depend
on contention, so model and RTL may legitimately differ on it. `--by=instr`
in the Perfetto view makes each instruction a process. Its owned transactions
nest under it by sub-index, a replay is an arrow from the old id to the new,
and `none` stays in the structure view. `tools/check-trace-ids.py` checks
that structure, and fails on the obvious wrong implementation (owned
transactions drawn as peers).

**Which classes each channel carries.** Each channel has a *set*, since
some carry more than one kind: EXB→MLC and the inbound port carry fills
(txn) *and* probes (none). Every message is checked against its channel's
set. The full assignment is in [`skeleton-slots.md`](skeleton-slots.md); in
short:

- **instr (13):** the instruction path, execute and memory ops, completion,
  retire, barrier arrive, fault;
- **txn (12):** SPM, DCU and MLC traffic, ifill, ITLB, outbound external;
- **txn + none (2):** EXB→MLC, inbound external;
- **none (14):** probes, launch, allocation, status, demotion and
  migration, CTA setup, CSR config — and barrier **release**.

A release wakes a *set* of warps and has no single owning transaction, so it
is `none` rather than `txn`. The link back to each `bar.sync` is already in
the trace — the arrives on the same `barrier_id` since its previous release —
so no set-valued id is needed. An explicit link, if wanted, would be a trace
event, not an id.

In S0 the ids are synthetic: a pure function of the message, like the payload.
In S1 they are real: FET assigns the instruction's sequence, and the memory
path's transactions are owned by it (see "S1 wire conventions").

## The SV top

The same machine as SystemVerilog, generated by `tools/gen-top.py` and
**tracked**, so it can be read in the repo:

| File | What |
|---|---|
| `rtl/top/ccv_core_top.sv` | 45 block instances, 103 channel instances, gated clocks, the checker bank under `CCV_CHECK` |
| `rtl/top/ports/ccv_<blk>_ports.svh` | each block type's port list — included by the stub and by real RTL alike |
| `rtl/top/stubs/ccv_<blk>.sv` | stubs that never send: protocol-legal on every channel |
| `test/top/tb_core_top.sv` | clock, reset, tie-offs; `+phantom` is its negative control |

A stub is replaced at 4c by real RTL with the same module name and the same
included port list, so the swap is a file-list change — the SV analogue of
the C++ skeleton's block swap. The machine's *functional* testbench remains
the C++ skeleton; this one proves structure.

**The checker bank is shared.** Under `CCV_CHECK` the top instantiates the
same `ccv_skel_checkers` the C++ skeleton Verilates, fed by concatenating its
channel nets in slot order. Without `CCV_CHECK` there is no checker at all —
the synthesis exclusion open item B-1 asked for, checked in Yosys both ways
round.

**The wiring is checked against the C++, not against the generator.**
`tools/check-top-wiring.py` elaborates the top in Yosys and maps every bit of
every channel port to a (channel, copy, slot, signal, bit) coordinate from
names and the layout rule alone. It then requires one driver and one load per
net, identical coordinates at both ends, and the right direction per signal.
The resulting producer→consumer map must equal `ccv-skel --dump-wiring`:
68,345 bits, identical. A copy with one lane's valid slice swapped is
rejected.

**Gaps it exposed, left visible rather than guessed:**

- **Common-port fabrics have no topology.** The schema says kill comes "from
  RAU", but RAU declares `kill_valid` as an *input* like every other block,
  and has no kill output. Wake/sleep and CSR have no fabric at all. So
  `kill_valid`/`kill_warp_mask` are broadcast from top inputs, and every
  block's `kill_ack`, `wake_req`, `sleep_ok` and CSR ports are brought to the
  top boundary as vectors indexed by block instance.
- **CSR widths were unspecified** (`"struct"`). `csr_req` is address + data +
  write enable, with the address a preliminary 16 bits (`CCV_L_W_CSR_ADDR`,
  churn med); `csr_rsp` is data + done.
- **The clock gate's owner is unspecified.** The schema's `clk` is "gated for
  the block", so the top makes `<blk>_core_clk` from `core_clk`, with the
  enable tied high until a power controller drives it from
  `sleep_ok`/`wake_req`. The reset tree (block letter `z`) isn't modelled;
  `rst_n` fans out directly.

## Still open

- **Unit is `UNIT_UNKNOWN`** for every channel transfer, because the checker
  sits between two blocks and belongs to neither. The Perfetto view puts
  `EV_CH_XFER` on a track per channel instead, recovered from its `a` field.
  Nothing is lost; it's noted only because the record itself doesn't say.
- **A-S2 — a multi-instance endpoint replicates the channel.** LANE has 32
  instances, so the two lane channels are 32 channel instances each. A channel
  with *both* ends multi-instance has no defined pairing and is a generation
  error rather than a guess. None exists today.

---

## S1 — `vadd` through the machine

**Done.** `tools/check-kernel.sh`, in the gate after S0.

```
build/skel/ccv-skel --kernel test/golden/vadd/oracle.jsonl --trace t.ccvtrace
tools/trace2perfetto.py t.ccvtrace --by=instr -o t.json
```

vadd (`c[i] = a[i] + b[i]`, 32 threads, one warp, 17 issue groups) runs to
completion in **355 cycles** on functional stubs behind the same ports the S0
exerciser used, with the checker bank judging every slot. It ends with the
register file (16 GPRs × 32 lanes, 4 predicates) and memory (every word
touched) **identical to ccv-sim's**, **0 interface violations**, 0 id-class
violations, and the bank's 691 `EV_CH_XFER` events matching every launch
exactly. It carries traffic on 26 of the 41 channels; the 15 idle ones are
SPM, barriers, migration, demotion, probes and faults, none of which vadd
reaches.

| Clean result | Negative control that must fail it |
|---|---|
| Instruction bytes DEC receives == bytes ccv-sim ran | `--break corrupt-fetch` flips one byte FET→DEC; DEC rejects seq 5 |
| Operands every lane receives == ccv-sim's; final register file == ccv-sim's | `--break corrupt-load` flips lane 5's load data MIU→RCU; lane 5 rejects the `C_ADD` operand *and* the final R9 differs |
| Final memory == ccv-sim's | `--break drop-store` has MIU discard the committed store; all 32 words of `c[]` differ |
| 0 bank violations | S0's controls prove the same bank, driven by the same code, is wired to every slot |
| `EV_CH_XFER` == every launch | Exact multiset over channel, payload bits and identity, so one wrong bit fails it |
| Every response matched to its request by `req_id` | `--break corrupt-req-id` gives the first EXB→MLC response the wrong id; MLC refuses it and nothing retires |

A second run is byte-identical (trace and cycle count), and
`tools/gen-golden.sh --check` fails the gate if the checked-in oracle record
drifts from what the compiler repo's ccv-sim now produces.

### Where the values come from

§1: the timing model *"calls into ccv-sim for what an instruction does and
owns when."* The seam is `ccv-sim -oracle` (added in the compiler repo for
this): one JSON record per issue group with the bytes, the issue mask, every
register read (value before) and written (value after), and each memory
access attributed to its lane. It is checked in as
`test/golden/vadd/oracle.jsonl`, generated from `test/golden/vadd/kernel.cfg`
by `tools/gen-golden.sh`. Regenerating it needs the compiler repo built:
LLVM 18 through its CMake, which needs `llvm-18-dev` and `libzstd-dev`, with
an `apt-get update` first. Without the compiler repo, the drift check
SKIPs.

The original plan had DEC decoding through LLVM's disassembler and lanes
calling `Interp::step`. S1 reads the record instead, so the core repo
doesn't link LLVM. Only one thing changes: the "what" is read from ccv-sim's
record rather than computed by ccv-sim in-process. What the record may be
used for:

| From the record (the "what") | Carried by the channels, checked against the record |
|---|---|
| Fetch **order** (no branch unit yet) | Instruction **bytes**: testbench memory → EXB → MLC → FET, via ITLB and ifill |
| Decode: which registers an instruction reads and writes | Operands: out of RCU's register file, to the lanes |
| ALU **results**: a lane returns ccv-sim's value | Load data: memory → EXB → MLC → DCU → MIU → RCU |
| **Substitution:** each lane's address offset | Store data: RCU's register file → MIU → DCU (RMW) → MLC → EXB → memory |

The trace identity (uid seq = record seq) is how a checker finds the record.
It's trace-only, so no stub uses it to decide what to do. There is one
exception: the address offset, because no payload carries the displacement
or the scale (finding 2 below).

**What this does not test.** Because ALU results come from the record, a
wrong operand doesn't produce a wrong result. It's caught by the lanes'
operand check instead, which `corrupt-load` proves is live. The stubs have
placeholder timing: in-order issue with a scoreboard, one memory op at a time,
no caches, a 10-cycle testbench memory. The 355 cycles measure the stubs, not
the machine.

### Findings — payload gaps the first kernel exposed

Each one is an entry in `schema/interfaces.json` `open_questions`, and
rendered in `docs/payload-spec.md`.

1. **No store data to DCU** (`miu_dcu_req_store_data`). `ccv_miu_dcu_req`
   had nothing that could carry what a store writes. **S1 added `write_data`
   and `byte_mask`**, mirroring `ccv_miu_spm_req` (56 → 1208 bits at rate 4).
   *Needs confirmation*, or a separate store-data channel.
2. **No route for the immediate or scale to the AGU** (`agu_immediate`).
   `imm` is on the uop and dropped at issue, and nothing downstream carries a
   displacement or scale. S1 substitutes the oracle's per-lane offset. ALU
   immediates have the same gap.
3. **Active-lane mask** (`active_lane_mask`). The response added
   `active_mask` to the three memory-path channels; see below for what
   remains open. `EV_RETIRE.active_mask` is still always `0xffffffff`.
4. **One predicate field for guard and destination** (`pred_src_and_dst`).
   `@P0 setp P1, …` has no encoding. S1 refuses such a record; vadd only uses
   P0.
5. **`ccv_miu_rcu_data.phys_dst` has no source** (`miu_rcu_phys_dst`).
   Nothing MIU receives names a destination register. RCU keeps it by
   `rob_tag` from issue, and the field is left zero.
6. **Three-source ops ride on `dst_arch`** (the existing
   `src_arch_vs_operand`). `MADLO` (accumulate: destination == third source)
   and `ST_GLOBAL_IDX` (data, base, index; no destination) both fit if the
   third source travels in `dst_arch` / `phys_dst`, and S1 does that. A
   three-source op with a *different* destination would not fit, and DEC
   refuses one.

Also found and fixed, in the compiler repo:

- **compiler F-141.** Compiler F-50's `mayLoad`/`mayStore` fix had bound its TableGen `let`s one
  def late. `LD_GLOBAL`, `LD_GLOBAL_P`, the compressed pair and both atomics
  had no memory effect, and three narrow stores were marked as loads. It
  showed up because the oracle reported `"load":0` beside 32 reads. `-oracle`
  now refuses any step whose memory traffic its descriptor doesn't declare.
- **compiler F-142.** ccv-sim recognized 42 of the 64 `setp` forms as compares when
  excluding Format C's unwritten `rd`. No benchmark output changed.

### Payload spec response (2026-09-25), as built

The partitioning response to `payload-spec.md`, applied. Every change is
covered by the S0 checks (the new fields are random traffic, their bits are
cross-checked C++ against SV) and exercised by vadd.

- **`req_id` on every request/response pair, per hop.** Added to the five
  pairs (`miu_spm`, `miu_dcu`, `dcu_mlc`, `fet_mlc` ifill, `mlc_exb`) and to
  the probe/acknowledgement pair. Each hop has its own provisional width, set
  by its outstanding window: MIU→SPM 3, MIU→DCU 4, DCU→MLC 4, FET→MLC 2,
  MLC→EXB 6 (the TL-C source width the `tilelink_tlc` sizing assumed), probe 2
  (`CCV_P_W_REQ_*`). One field name with a different width per hop needed a
  per-channel override of `field_widths`. That rule is in `tools/ccv_schema.py`
  and all six width consumers use it. The S1 stubs now match every response by
  id instead of by slot or arrival order.
- **`active_mask`** (`CCV_W_LANE_MASK`) on `ooe_miu_memop`, `rcu_miu_addr`
  and `miu_rcu_data`. MIU checks the two copies agree, touches only active
  lanes and checks them against ccv-sim's; RCU writes only active lanes.
- **`pred_reg` is `CCV_W_ARCH_PRED`** (2 bits, new, isa). S1 had packed
  read/write flags into the spare bits; now they come from the opcode, like
  GPR source counts.
- **Inbound probe:** `exb_mlc_rsp`'s one-bit `inbound_probe` is replaced by
  `probe_type` (`CCV_L_W_PROBE_TYPE`, 2, preliminary; 0 = a response) and
  `phys_addr`. The flag was on `exb_mlc_rsp`, not `ext_exb_in`: `tl_in` is the
  flattened TL bundle and already carries the probe's address and param in its
  B-channel fields. EXB translates them. Decomposing `tl_in` into named fields
  is the EXB session's `tilelink_tlc` decision, and is left to it.
- **Lane channels have no tag:** added as the third reason in
  `rcu_lane_ops`' binding rationale. They were already `bound` and lockstep.

**Stale in the response, already true of the build:** both migration
channels are rate 1 in the schema (the 340-slot total is derived from it and
re-derived independently in the gate). The four sizing corrections were
already applied: `warp_mask_released` 32, `bank_addr` 320, `phys_pred` on
`CCV_P_W_PHYS_PRED`, and barrier base plus count. `dcu_miu_rsp` already says
`read_data`.

**Raised by applying it** (in `open_questions`):

- **Neither producer can compute `active_mask`.** It is issue mask ∧ guard
  predicate. OOE knows the issue mask but not predicate values, which live in
  RCU's file. RCU has the values but `ooe_rcu_issue` carries no issue mask.
  The same gap means `pred_bit` can't fold in the issue mask, so "the
  arithmetic path is already correct" holds only while every group issues all
  32 lanes. Proposal: add `issue_mask` to `ooe_rcu_issue`.
- **ITLB refills have no correlation either** (`itlb_correlation`).
  `miu_fet_itlb` returns an entry naming no virtual page, and the request
  carries no tag. It's the same defect one level up, unless FET is defined to
  have at most one miss outstanding.

### S1 wire conventions (placeholders)

These are encodings the payload spec leaves to each block's owner. They are
chosen in `sim/skel/kernel.cpp` and listed here so nobody mistakes them for
decisions.

| Where | Convention |
|---|---|
| `fet_dec_instr.length` | 0/1/2 = 2/4/6 bytes; `instr` little-endian bytes |
| `fet_dec_instr` slots | warp *w* is tier-1 stream *w*: binding group *w*, age = slot order |
| `dec_ooe_uop.opcode` | skeleton-local table, 1..11 for vadd's ops (0 reserved) |
| `dec_ooe_uop.src_arch` | `[7:4]` src0, `[3:0]` src1; a third source in `dst_arch` |
| `dec_ooe_uop.pred_reg` | the index (`CCV_W_ARCH_PRED`); read/written comes from the opcode |
| `dec_ooe_uop.imm` | 0: not decoded (finding 2) |
| `ooe_rcu_issue.phys_src` | `[15:8]` src0, `[7:0]` src1; rename is `prf_base + arch` (no renaming yet) |
| `ooe_rcu_issue.phys_pred` | `4·warp + index` (predicates not renamed) |
| `rcu_lane_ops.operand` | `[32i+31:32i]` = source *i* |
| `lane_rcu_res.result` | GPR value, or the predicate bit in bit 0 |
| `rcu_miu_addr.base` | window base `GPR[base] << 16` (§5.1), checked uniform across lanes |
| per-lane wide fields | lane *L* at `[32L+31:32L]`; line byte *k* at `[8k+7:8k]` |
| `coh_op` | 0 read, 1 write |
| `ooe_miu_memop.mem_op` | 0 load, 1 store |
| `size` | log2 bytes; 7 = a 128-byte line |
| `rau_fet_launch.code_bounds` | `[63:0]` base, `[103:64]` length |
| `exb_ext_out.tl_out` | `[2:0]` op (1 Get, 2 PutFull), `[8:3]` source (= MLC→EXB `req_id`), `[56:9]` address, `[184:57]` byte mask, `[1208:185]` data |
| `ext_exb_in.tl_in` | `[2:0]` op (1 AccessAckData, 2 AccessAck), `[8:3]` source, `[1032:9]` data |
| `req_id` | each requester allocates the lowest free id below 2^width on its own hop and holds it until the response; MLC maps its EXB-side id back to the requester's id |
| `active_mask` | OOE sends its issue mask (all 32 lanes: no divergence yet); RCU sends issue mask ∧ guard. They differ for a predicated memory op, which MIU reports (open question `active_lane_mask`). MIU touches and RCU writes only active lanes |
| identities | instruction: `instr` class, seq = record seq. Line request on an instruction's behalf: owned `txn`, same seq, sub = line. ITLB and ifill: unowned `txn` |

### Events: what the skeleton emits

Seven of the twelve schema events:

| Event | Emitted by | vadd count |
|---|---|---|
| `EV_CH_XFER` | the checker bank, every transfer | 691 |
| `EV_DECODE` | DEC | 17 |
| `EV_DISPATCH` | OOE, ROB allocation | 17 |
| `EV_ISSUE` | OOE (`C_EXIT` isn't issued) | 16 |
| `EV_MEM_REQ` / `EV_MEM_RSP` | MIU per line; FET per ifill | 9 / 9 |
| `EV_RETIRE` | OOE, in order | 17 |

Not yet emitted: `EV_WAKEUP` and `EV_WARP_SELECT`, which need more than one
warp and a real scheduler; `EV_BARRIER_ARRIVE`/`RELEASE`, which need a
barrier kernel; and `EV_ID_LINK`, which needs a replay. Those come from S2's
kernels.
