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

**Next: S2.** vadd leaves 20 of the 46 channels idle and never diverges, loops
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
reads all 192 fields back *through the real SV structs* and compares them with
the C++ table: zero disagreements over 64 random rounds. Its negative control
shifts every C++ offset by one bit, and the probe must catch every field that
can be shifted — 189 of 189 (the other three are single-field payloads).

### 3. Interface checking is the SV checker itself, Verilated in

The skeleton is C++, and the obvious move is a C++ port of the checker. That
is the wrong one: a second implementation of the protocol drifts from the
first, and "zero violations" then becomes a statement about the port. Instead
`rtl/generated/ccv_skel_checkers.sv` instantiates the real
`ccv_credit_checker` once per slot — 345 of them — and the skeleton clocks it
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
| 0 checker violations | `--break phantom-all`: all 345 checkers fire `no_phantom_credit`, each by name — proves every slot's `credit` wiring |
| | `--break stall-all`: all 345 fire `stall_honoured` — proves every `stall` and `valid` |
| `EV_CH_XFER` payloads (bits 63:0) **and trace ids** equal the launched ones, as a multiset | the match is exact, so one miswired payload or sideband bit fails it |
| 0 payload mismatches at the receivers; sent == received; no idle slot | — (end-to-end data check, independent of the bank) |
| `--force-atomic`: every multi-slot channel moves in whole groups, clean | `--break atomic-all`: all 77 atomic checkers fire both properties, and nothing else fires |
| Ordered channels are consumed in order per key — per binding group on fet→dec, per `warp_id` on dec→ooe — with different keys free to pass | `--break misorder`: taking a head that is not the oldest of its key is caught — on exactly the two ordered channels |
| Lane channels advance together: slot *k* moves on all 32 lanes or none | `--break lockstep-all`: one lane's slot alone — both lockstep checkers fire, nothing else |
| Slot *k* carries the same instruction on every lane | `--break misbind`: lane 7 carries slot *k*+1's instruction in slot *k* — only `lockstep_id` fires |
| Every message's id class is in its channel's set | `--break wrong-class`: all 46 channels report |
| The trace id exists only under `CCV_TRACE` | asked of Yosys both ways — absent without, present with |
| Every fet→dec message names its own group (`tier1_id` == slot / 2) | `--break misgroup`: every message names the next group — only `binding_key` fires |
| C++ field offsets == SV packed structs | `--mutate`: every shiftable field must disagree |
| **345 slots**, re-derived from the schema every run | — (see below) |

The payload wiring gets the event-stream check rather than a negative control
because Verilator is two-state: `payload_known_when_due` cannot fire there at
all, so an X-injection control is not available on this simulator.

### The slot count, derived

[`skeleton-slots.md`](skeleton-slots.md) is generated: the count term by term,
and every channel with its attributes. In short:

| Channel types | Rate | Instances each | Slots |
|---|---|---|---|
| 31 | 1 | 1 | 31 |
| 11 | 4 | 1 | 44 |
| 2 | 4 | 32 | 256 |
| 1 | 6 | 1 | 6 |
| 1 | 8 | 1 | 8 |
| **46** | | | **345** |

That is 46 types and 108 channel instances: 44 at one instance, plus the two
lane channels at 32 each. The inbound external channel took it from 40 types
(339 slots) to 41, branch redirect to 42, the FET↔PCA migration pair to 44,
and migration control (a RAU→FET command, a PCA→RAU done) to 46.

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
| `binding_key` | slots | fet→dec `tier1_id` | `ccv_binding_checker`: the key must equal slot / `binding_group` |
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
throughput, as it should: 256 of the 345 slots are lane slots, and the RCU
sender holds all 32 lanes whenever any one stalls, so runs carry ~151k
messages where they carried ~230k.

**The fet→dec binding is checked, not stated.** "Tier-1 stream = slot / 2"
needed a payload field naming the stream; `warp_id` names one of 32 warps,
not the tier-1 slot. `tier1_id` (`CCV_W_TIER1_ID`, 2 bits) is that field, and
`binding_key` points the bank's `ccv_binding_checker` at it: when a payload
lands on slot *s*, its key must equal *s* / 2.

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
| `rtl/top/ccv_core_top.sv` | 45 block instances, 108 channel instances, gated clocks, the checker bank under `CCV_CHECK` |
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
69,803 bits, identical, now including one `_wake` bit per channel
instance, which must run from the same producer to the same consumer as
that instance's slots. A copy with one lane's valid slice swapped is
rejected.

**Common-port fabrics** (decided 2026-09-25; each common port's `fabric` in
the schema says how the top connects it):

- **Kill is the one true broadcast, from RAU, and RAU gathers the acks.**
  RAU reallocates warp slots, PRF partitions, scratchpad regions and barrier
  entries, so it is the one block that must know teardown finished. Only
  the eight blocks that own warp state take part: FET, DEC, OOE, RCU, MIU,
  SPM, SYU and PCA. Lanes hold nothing that survives RCU ceasing to send, and
  DCU, MLC and EXB are physically addressed. So RAU's `kill_acks` is eight
  bits, each meaning something, not 45 with 32 tied high.
  - An ack means **quiesced**, not stopped: no state held for the killed
    warps, and nothing in flight toward anyone else on their behalf. MIU is
    the awkward one: its ack waits on retired stores draining, while its
    pending loads are dropped.
  - `kill_epoch` is broadcast with the kill and echoed on every ack
    (`kill_ack_epoch`), so a late ack from one kill can't satisfy the next.
  - `kill_warp_mask` is 32 bits, one per warp context. It was sized to the
    four tier-1 warps, but PCA and SYU hold state for parked warps, which a
    tier-1 mask can't name. Confirmed (Q-31): SYU must record arrival for
    a warp parked at `bar.sync`, since it can be demoted.
- **Both kill sources land at RAU, the single issuer.** A fault comes direct
  from OOE: `fault_taken` with the `warp_id` on `ccv_ooe_rau_status`, and RAU
  maps warp to grid to mask. CRU records the fault in parallel for the host
  and is not on the path that stops execution. The host's kill comes as
  `kill_req` plus `kill_grid` on `ccv_cru_rau_cfg`.
- **Wake is not a fabric.** It is `_wake`, a fifth channel signal from sender
  to receiver, one per channel instance. `sleep_ok` goes to the block's own
  clock gate only (`<blk>_core_clk = core_clk & ~<blk>_sleep_ok`).
- **CRU owns the CSR fabric,** as a star: it drives every block's `csr_req`
  and gathers `csr_rsp` and `csr_credit`, and its own CSR ports are the host
  side, at the top boundary.

**Gaps still visible:**

- **Wake's timing contract (Q-33).** `_wake` exists, but how far it must
  lead valid (`CCV_WAKE_LAT`, 4) is not yet a checked property. A stub never
  sleeps, so nothing depends on it yet.
- **CSR widths were unspecified** (`"struct"`). `csr_req` is address + data +
  write enable, with the address a preliminary 16 bits (`CCV_L_W_CSR_ADDR`,
  churn med); `csr_rsp` is data + done.
- The reset tree (block letter `z`) isn't modelled; `rst_n` fans out
  directly (Q-37).

## Known limitations

Neither is an open item; both are recorded so nobody mistakes them for one.
Open items are in [`open-items.md`](open-items.md).

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
completion in **365 cycles** on functional stubs behind the same ports the S0
exerciser used, with the checker bank judging every slot. It ends with the
register file (16 GPRs × 32 lanes, 4 predicates) and memory (every word
touched) **identical to ccv-sim's**, **0 interface violations**, 0 id-class
violations, and the bank's 509 `EV_CH_XFER` events matching every launch
exactly. It carries traffic on 26 of the 46 channels; the 20 idle ones are
SPM, barriers, migration (both pairs and its command and done), probes, faults and branch redirect
(vadd's one branch is never taken), none of which vadd reaches.

| Clean result | Negative control that must fail it |
|---|---|
| Instruction bytes DEC receives == bytes ccv-sim ran | `--break corrupt-fetch` flips one byte FET→DEC; DEC rejects seq 5 |
| Operands every lane receives == ccv-sim's; final register file == ccv-sim's | `--break corrupt-load` flips lane 5's load data MIU→RCU; lane 5 rejects the `C_ADD` operand *and* the final R9 differs |
| Final memory == ccv-sim's | `--break drop-store` has MIU discard the committed store; all 32 words of `c[]` differ |
| 0 bank violations | S0's controls prove the same bank, driven by the same code, is wired to every slot |
| `EV_CH_XFER` == every launch | Exact multiset over channel, payload bits and identity, so one wrong bit fails it |
| Every response matched to its request by `req_id` | `--break corrupt-req-id` gives the first EXB→MLC response the wrong id; MLC refuses it and nothing retires |
| Addresses computed by MIU's AGU from the carried base, index, displacement and scale | `--break corrupt-disp` adds 4 to one load's displacement OOE→MIU; MIU's address check rejects all 32 lanes |
| Branches resolve in RCU from the guard, negate included, and redirect fetch only when taken | `--break drop-negate` drops the guard's negate at issue: vadd's `@!P0` resolves as taken by all 32 lanes, RCU disagrees with ccv-sim, and the redirect it causes is rejected by FET (the one run that exercises `ooe_fet_redirect`) |
| FET has at most one ITLB miss outstanding | `--break itlb-double` asks for a second page; the bank's `within_limit` fires, and nothing else (FET then matches a refill to the wrong page, which is the reason for the rule) |

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
| Immediates (the record's `imms`), at decode | Displacement and scale enable: DEC → OOE → MIU's AGU; ALU immediate: DEC → OOE → RCU, substituted into an operand |
| | Store data: RCU's register file → MIU → DCU (RMW) → MLC → EXB → memory |

The trace identity (uid seq = record seq) is how a checker finds the record.
It's trace-only, so no stub uses it to decide what to do. (The one exception,
the per-lane address offset, is gone: displacement and scale now travel.)

**What this does not test.** Because ALU results come from the record, a
wrong operand doesn't produce a wrong result. It's caught by the lanes'
operand check instead, which `corrupt-load` proves is live. The stubs have
placeholder timing: in-order issue with a scoreboard, one memory op at a time,
no caches, a 10-cycle testbench memory. The 365 cycles measure the stubs, not
the machine.

### Findings — payload gaps the first kernel exposed

Each is numbered in [`open-items.md`](open-items.md). The ones still open
are also entries in `schema/interfaces.json` `open_questions`, under the same
ID, rendered in `docs/payload-spec.md`.

1. **No store data to DCU: confirmed as built (Q-19).** `ccv_miu_dcu_req`
   had nothing that could carry what a store writes. S1 added `write_data`
   (1024) and `byte_mask` (128), mirroring `ccv_miu_spm_req` (56 → 1208 bits
   at rate 4). A separate store-data channel would duplicate flow control for
   nothing, and byte granularity is enough because a 4-bit access faults.
2. **Immediates: decided (Q-22).** The AGU is MIU's: `disp` (`CCV_W_DISP`, 16,
   the widest memory-format offset) and `scale_en` ride on `ooe_miu_memop`,
   and the shift is derived from `chwidth`. ALU immediates ride on
   `ooe_rcu_issue`, and RCU substitutes them into an operand slot at register
   read, so lanes never see an immediate. The oracle substitution is gone.
3. **Masks: decided (Q-23).** Only RCU holds both the issue mask and the
   predicate values, so it is the sole producer of `active_mask`, on
   `rcu_miu_addr` and `miu_rcu_data`. `ooe_rcu_issue` and `ooe_miu_memop`
   carry `issue_mask`, a different field that is never compared with it.
   `pred_bit` is the same computation per lane. MIU checks the invariant that
   holds, active ⊆ issue. `EV_RETIRE.active_mask` is still always
   `0xffffffff`.
4. **Guard and predicate destination: two fields (Q-21).** The ISA encodes
   them separately (Format C: qualifier `[29:27]`, destination `[31:30]`),
   and one `pred_reg` couldn't carry `@P0 setp P1`. Now `pred_guard` with
   `pred_neg`, and `pred_dst` with `pred_we` (see "Skeleton review response
   4").
5. **Load write-back destination: decided (Q-25).** OOE carries `phys_dst` and
   `phys_pred` on the memop, and MIU echoes them, so RCU is stateless on
   write-back (see "Skeleton review response 3").
6. **Three sources: answered from the ISA, and the uop widened (Q-20).**
   Format A `dp4.*`, `dp2.*`, `ffma.f0` and `mad.lo` read `rs0`, `rs1` *and*
   `rs2` (the accumulator input) and write an **independent** `rd`; only the
   compressed Format J forms (`dp4.acc`, `mad.acc`, `ffma.acc`) tie the
   destination to the accumulator. The ISA's own walkthrough has
   `mad.lo r1, r3, r1, r2`, with `rd` ≠ `rs2`; vadd's hand-written
   `MADLO R1, R2, R3, R1` just happened to fit. `cas` reads three GPRs as well. So the third source
   has its own field (`src2_arch`, `phys_src2`), and the S1 workaround of
   carrying it in `dst_arch` is removed. (`dp8` is in the ISA table, but no
   instruction definition exists for it yet.)

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
channels are rate 1 in the schema (the slot total is derived from it and
re-derived independently in the gate). The four sizing corrections were
already applied: `warp_mask_released` 32, `bank_addr` 320, `phys_pred` on
`CCV_P_W_PHYS_PRED`, and barrier base plus count. `dcu_miu_rsp` already says
`read_data`.

**Raised by applying it, and since answered** (see the next section): who
computes `active_mask` (Q-23), and ITLB correlation (Q-24).

### Skeleton review response (2026-09-25), as built

- **`issue_mask` and `active_mask` are two fields, not two copies** (finding
  3 above). This retires the equality check, which would have fired on the
  first predicated load, and closes Q-23.
- **ITLB: FET is single-miss-outstanding, asserted (Q-24).** An `outstanding`
  attribute on `fet_miu_itlb_req` (`answered_by: ccv_miu_fet_itlb`,
  `max: 1`) generates a `ccv_outstanding_checker` in the bank. It counts
  requests against responses at valid, and fires on a second request or on
  a response with nothing outstanding. The S0 exerciser's synthetic traffic
  can't honour a pairing, so the bank's `pair_enable` is off for S0 and on for
  S1 and the SV top. `--break itlb-double` is its control.
- **Kill from RAU, wake per channel, sleep local, CSR from CRU** (the SV top
  section above).
- **Three sources** (finding 6 above) and **immediates** (finding 2).
- **`tier1_id`** makes fet→dec's binding a check (the interface decisions
  section above).
- **The link carries TL-C beats, not lines.** S1's placeholder had put a
  whole 1024-bit line in one `tl_out` message, contradicting the 512-bit beat
  the width was derived from. It now uses the real flattened layout
  (A/C/E out, B/D in, the per-channel valid bits at the top). A line is a
  two-beat burst: EXB splits `PutFullData` into beats and gathers
  `AccessAckData` beats back into one response. **For the EXB session:** the
  flattened width stands in for a burst sequencer, not just a bus.

**Raised by applying it, and answered in the next round:** branch
resolution (Q-26), predicate source operands (Q-27), and compiler F-143 (see
below).

The formal covers for the new outstanding checker caught a vacuous setup on
the way. See `fail-open-register.md`.

### Skeleton review response 2 (2026-09-25), as built

- **Kill** (the SV top section above): eight owning blocks, quiesced acks,
  an epoch, a 32-bit warp mask, and both sources (a fault from OOE, a
  request from the host) landing at RAU.
- **Branch resolution is built (Q-26).** The condition is a predicate in RCU's
  file, so RCU resolves: `branch_taken` and `branch_mask` (issue ∧ guard)
  on `ccv_rcu_ooe_done`. OOE redirects on the new `ccv_ooe_fet_redirect`:
  warp, tier-1 stream, target PC, updated group masks, and a fetch epoch.
  - The immediate route it depends on was already built last round. DEC folds
    the instruction length into the offset, since the uop carries no
    length, so OOE computes the target as `pc + imm`.
  - vadd's one branch is never taken, so the redirect channel carries
    nothing in a clean run. `--break drop-negate` exercises it.
- **Found on the way: the guard's negate was not carried.** `pred_reg` is
  the predicate *index*, but a guard qualifier is index plus negate, and
  vadd's branch is `@!P0`. It resolved correctly only because the lanes
  compared against the same un-negated value. `pred_neg` now rides on the
  uop and the issue, and RCU and the lanes honour it. ccv-sim's oracle now
  emits the raw qualifiers (`quals`) so decode can see the negate.
- **Predicate logic executes in RCU (Q-27),** as already decided (O-33's second
  obligation; round 16). `por` never reaches a lane. Its two source
  qualifiers ride in the uop's `imm` (a skeleton convention), and RCU
  computes the result from its predicate file and checks it against
  ccv-sim's. That removes the transfers for `por` and the branch from all
  32 lanes: 701 → 573.
- **`sel` reads a predicate as data, and executes in the lane (Q-28,
  decided).** `@pq sel rd, rs0, rs1` writes `rd` on every issue-mask lane,
  choosing by the predicate. **The rule (Q-32, stated without special
  cases):** the lane executes anything that reads lane data; RCU executes
  everything that reads none, plus the ops that move data horizontally
  between lanes (`shfl`, `vote`, `ballot`, `unballot`). Predicate logic,
  `pmov` and branch resolution read no lane data, so they are RCU's. `setp`,
  `add.pp` and `cas` read lane data, so they run in the lane although they
  write predicates. A lane stub fails if an op that reads no lane data reaches
  it, and RCU fails if one it executes reads a GPR. Three built ops break the
  rule (`movi`, `movi48`, `srd`) and are the one pending exception (Q-38).
  The fields this implies:
  - `pred_data` on `rcu_lane_ops`, sel's selector, beside `pred_bit`, which
    stays the enable;
  - `pred_out` on `lane_rcu_res`, a lane's predicate result (`setp` used to
    borrow `result[0]`, which `add.pp`'s GPR-plus-predicate could not share);
  - `pred_result` on `miu_rcu_data`, per lane, for `cas`'s success predicate.

  A second kernel, `test/golden/sel/`, exercises it: `c[tid] = tid < 16 ? tid
  : 16`, so half the lanes choose `rs1`. It ends identical to ccv-sim in 120
  cycles, and `--break drop-pred-data` must be rejected by those lanes.
- **The PC-group owner (Q-29):** FET owns divergent PC state, but
  `ccv_rcu_pca_mig` carried `pcs` from RCU. Built in the next round: a FET↔PCA
  pair.
- **Compiler F-143 is fixed** (`cas`'s offset is `simm16`, decoded
  sign-extended), and escalated as you said: an offset at or above 0x8000
  would have been emitted as a large positive and executed as negative.
  **Compiler F-144:** fixing it exposed that 85 predicated instructions had
  silently left the encode/decode round trip since the predicate operand
  types were added (see `fail-open-register.md`).

### Skeleton review response 3 (2026-09-25), as built

- **The PC groups migrate FET↔PCA (Q-29).** `pcs` is off `ccv_rcu_pca_mig` and
  `ccv_pca_rcu_mig`, and onto the new `ccv_fet_pca_mig` / `ccv_pca_fet_mig`,
  each carrying `warp_id` and the groups. The design is at 44 channels.
  - **Open (Q-30, `migration_control`):** RAU sequences both halves and waits
    for both acks, but at 44 channels nothing carries that. Nothing tells FET
    to send or accept, no ack reaches RAU from FET, RCU or PCA, and
    `ccv_rcu_pca_mig` never said which warp or bank it carries. The smallest
    fix is a RAU→FET migrate command and a PCA→RAU done, which would make 46
    channels. Built in review 4.
- **Already built last round, and unchanged:**
  - `issue_mask` / `active_mask` as two fields, with the agree check retired
    (it is now active ⊆ issue): Q-23.
  - FET's single ITLB miss, asserted by the bank's outstanding checker: Q-24.
- **The third source is a named field** (Q-20; `src2_arch`, 4 bits; `phys_src2`,
  8 bits). Last round had widened `src_arch` to a packed three-source field;
  now `src_arch` holds two again and `dst_arch` means the destination,
  always.
  - The ISA question was answered last round: Format A `dp4` takes a separate
    third source (`rs2`), so the field is required, not merely cleaner.
  - **One correction to the invariant to record.** `mad.lo` does *not*
    accumulate into its destination: `mad.lo rd, rs0, rs1, rs2` has `rd`
    independent of `rs2` (the ISA walkthrough's `mad.lo r1, r3, r1, r2`).
    vadd's `MADLO R1, R2, R3, R1` accumulates only because it names the same
    register twice. The invariant is Format J's: `mad.acc`, `dp4.acc` and
    `ffma.acc` read and write `rd` (TableGen ties `rd` to `rd_in`), and every
    Format A four-register form takes `rs2` as an independent source.
- **Load write-back is stateless in RCU (Q-25).** The memop carries `phys_dst`
  and `phys_pred`, and MIU echoes both on `miu_rcu_data`, so RCU writes where
  the data says and holds no table of outstanding loads.
  - One bit beyond your spec: `pred_we`, set by MIU from the op. Without it,
    a stateless RCU can't tell a `cas` from a load, and would write
    `pred_result` over the predicate that `phys_pred` names on every load.
  - Control: `--break corrupt-echo` sends one load's data to the wrong
    register, which C_ADD's lanes then reject.

### Skeleton review response 4 (2026-09-25), as built

The first round against the numbered register ([`open-items.md`](open-items.md)).

- **Confirmed as built:** store data on `ccv_miu_dcu_req` (Q-19) and a 32-bit
  `kill_warp_mask` (Q-31).
- **Where an op executes, stated once (Q-32):** the lane executes anything
  that reads lane data; RCU executes everything that reads none, plus the
  horizontal ops. Both sides now check every op against its record.
  - **Raised by it (Q-38):** `movi`, `movi48` and `srd` read no lane data, so
    the rule puts them in RCU, and S1 built them in the lane. They are the one
    pending exception. `--break drop-q38-exception` removes it, and exactly
    their lane checks must fail.
- **Guard and predicate destination split (Q-21).** It was a payload fix,
  not an ISA question: Format C encodes the qualifier and the destination
  separately. The uop carries `pred_guard` + `pred_neg` and `pred_dst` +
  `pred_we`, and the issue carries `phys_pred_guard`, `phys_pred_dst` and
  `pred_we`. The memop's `phys_pred` is the destination.
  - RCU now writes a lane result only on active lanes, so a lane the guard
    disables keeps its old value (invariant 10). This is what makes a guarded
    write to another predicate observable.
  - A third kernel, `test/golden/pguard/`, runs `@P0 setp P1`. P1 ends as
    tid < 8 on the lanes P0 enables and keeps tid < 24 on the rest, and
    `sel` stores it. It ends identical to ccv-sim.
  - `--break conflate-pred` puts the destination back in the guard's field.
    The next compare's guard is then wrong at its lanes, and P0 and P1 both
    end wrong.
- **Migration is addressed and sequenced (Q-30), 46 channels.** The finding
  inside the gap: `ccv_rcu_pca_mig` never named a warp or a row, so the
  migration data path was unaddressed. The command carried `warp_id`,
  `direction` and `bank_select`, but only to RCU, so PCA would have had to
  infer placement from a command it never sees.
  - Both RCU↔PCA data channels now carry `warp_id` and `row_idx` (the GPR
    the 1024-bit row holds, `CCV_W_ARCH_REG`).
  - `ccv_rau_fet_mig` gives FET the same command RCU gets.
  - `ccv_pca_rau_mig_done` returns `warp_id` once PCA holds both halves, so
    RAU waits on one ack from the block that sees both land.
  - Demotion now has every message it needs. No S1 kernel migrates, so the
    four new or changed channels carry S0's random traffic, judged by the
    bank like every other slot.
  - **Raised by it (Q-39):** restore has no command to PCA. On restore PCA
    is the sender, of both the GPR rows and the PC groups, and no channel
    tells it which warp to send. PCA also never sees `bank_select`.

### Skeleton review response 5 (2026-09-25), as built

The `srd` response: Q-38 closed, and Q-32's rule amended.

- **The rule, amended:** the lane executes anything whose result differs per
  lane; RCU executes what is warp-uniform, plus the horizontal ops. "Reads
  lane data" meant register reads, and taken literally it sent `srd` to RCU.
  How the stubs check it, and a wording question it raises, is Q-40.
- **`movi` and `movi48` execute in RCU.** RCU writes the immediate into the
  register file on the issue-mask lanes and checks it against ccv-sim, with
  no lane round trip. That takes vadd from 573 channel transfers to 509.
  `--break movi-in-lane` sends them to the lanes instead, and every lane must
  refuse both.
- **`srd` stays in the lane, with its value from OOE.** Lane identity is
  wiring: each lane knows its index as a constant.
  - The warp-level part is identity RAU already holds. It arrives on
    `ccv_rau_ooe_alloc` (`ctaid`, 32 bits; `warp_in_cta`, 5), which promotion
    re-sends.
  - OOE substitutes it into the immediate at issue: `warp_in_cta << 5` for
    `%ctatid`, `%ctaid` itself for selector 1.
  - The lane ORs its index in for selector 0, with no adder since the low
    five bits are zero, and passes selector 1 through.
  - **The lane's selector is a stated choice: two opcodes, not a bit.** DEC
    decodes the selector once, and every later block keys off the opcode:
    OOE to pick the identity, the lane to pick OR or pass-through. A bit on
    `rcu_lane_ops` would also have needed one on the issue, since the
    immediate no longer holds the selector by the time RCU sees it.
  - The lane computes `srd`'s result and checks it against ccv-sim. It is the
    first lane result the machine computes rather than takes from the
    record.
  - A fourth kernel, `test/golden/srd/`, runs at CTA 7, since every other
    kernel runs CTA 0, where a missing `%ctaid` reads as right.
    `--break corrupt-ctaid` sends OOE ctaid + 1, and the lanes' result is
    rejected. (`warp_in_cta` is always 0 here: the skeleton runs one warp.)
- **DEC's selector check is its own obligation** (`params/blocks.json`).
  Selectors 2–15 are a legal field holding an unallocated value, a range
  comparison beside the reserved-field zero checks. `--break srd-selector`
  must be named by it, and the instruction must not retire.
- **`CCV_P_W_IMM`'s floor is 32, set by `%ctaid`,** and recorded where the
  width is declared. The same goes for `CCV_W_CTAID` and
  `CCV_W_WARP_IN_CTA`.
- **The compiler's obligations are in the compiler repo.**
  - **The narrow-destination refusal is compiler F-145.** It already held
    structurally, and now a named error refuses any change that breaks it.
    A mutation test proves the refusal fires.
  - **Rematerialization is compiler F-146, and it did not happen.** `srd`
    has no pattern, so TableGen inferred side effects and vetoed remat, and
    `sgemm` spills `%ctatid`. Making it real is a trade: `sgemm` 4×4 gains,
    but `igemm` 1×1 picks up a 14-`mov` rotation in its loop. So it's left
    as an open choice with the numbers.

### S1 wire conventions (placeholders)

These are encodings the payload spec leaves to each block's owner. They are
chosen in `sim/skel/kernel.cpp` and listed here so nobody mistakes them for
decisions.

| Where | Convention |
|---|---|
| `fet_dec_instr.length` | 0/1/2 = 2/4/6 bytes; `instr` little-endian bytes |
| `fet_dec_instr` slots | warp *w* is tier-1 stream *w*: binding group *w*, age = slot order |
| `dec_ooe_uop.opcode` | skeleton-local table (0 reserved); `srd` decodes to one opcode per allocated selector |
| `dec_ooe_uop.src_arch`, `src2_arch` | `[7:4]` src0, `[3:0]` src1; the third source in `src2_arch` |
| `dec_ooe_uop.pred_guard`, `pred_neg`, `pred_dst`, `pred_we` | the guard's index and negate (from the qualifier; sel's selector too); the predicate destination, valid when `pred_we` |
| `dec_ooe_uop.imm` | the displacement for a memory op, else the ALU immediate; `scale_en` beside it. A branch: its byte offset from its own pc (DEC folds in the length). Predicate logic: its source qualifiers, `[2:0]` ps0, `[5:3]` ps1 |
| `srd`'s immediate at issue | identity from OOE: `warp_in_cta << 5` for selector 0 (the lane ORs its index in), `ctaid` for selector 1 (the lane passes it through) |
| `ooe_miu_memop.disp` | **sign-extended** from `CCV_W_DISP` at the AGU, as the ISA's signed offsets require (compiler F-143) |
| `ooe_rcu_issue.phys_src`, `phys_src2` | `[15:8]` src0, `[7:0]` src1; the third in `phys_src2`. Rename is `prf_base + arch` (no renaming yet) |
| `ooe_miu_memop.phys_dst`, `phys_pred` → `miu_rcu_data` | echoed unchanged by MIU; RCU writes `load_data` to `phys_dst`, and `pred_result` to `phys_pred` only when `pred_we` |
| operand slot of an ALU immediate | per opcode (the skeleton's table); RCU fills it at register read |
| `ooe_rcu_issue.phys_pred_guard`, `phys_pred_dst` | `4·warp + index` (predicates not renamed); RCU writes the destination only when `pred_we`, and only on active lanes |
| `rcu_lane_ops.operand` | `[32i+31:32i]` = source *i* |
| `lane_rcu_res.result`, `pred_out` | the GPR value; the predicate result in `pred_out` |
| `rcu_lane_ops.pred_data` | a predicate read as data (sel's selector), negate applied; `pred_bit` is the enable |
| `rcu_miu_addr.base`, `index_per_lane` | raw register values; the base checked uniform across active lanes. MIU's AGU applies the window shift (§5.1), the scale and the displacement |
| per-lane wide fields | lane *L* at `[32L+31:32L]`; line byte *k* at `[8k+7:8k]` |
| `coh_op` | 0 read, 1 write |
| `ooe_miu_memop.mem_op`, `space` | 0 load, 1 store; 0 global, 1 shared |
| `size` | log2 bytes; 7 = a 128-byte line |
| `rau_fet_launch.code_bounds` | `[63:0]` base, `[103:64]` length |
| `exb_ext_out.tl_out` | flattened TL-C: A `[640:0]` (opcode, param, size, source = MLC→EXB `req_id`, address, mask, data 512, corrupt), C `[1217:641]`, E `[1221:1218]`, valids a/c/e `[1224:1222]`. Get = 4, PutFullData = 0 |
| `ext_exb_in.tl_in` | flattened TL-C: B `[640:0]`, D `[1173:641]` (opcode, param, size, source, sink, denied, data 512, corrupt), valids b/d `[1175:1174]`. AccessAck = 0, AccessAckData = 1 |
| line on the link | two 512-bit beats, same address; EXB and the testbench count them |
| `req_id` | each requester allocates the lowest free id below 2^width on its own hop and holds it until the response; MLC maps its EXB-side id back to the requester's id |
| `issue_mask` / `active_mask` / `pred_bit` | OOE sends `issue_mask` (all 32: no divergence yet). RCU computes issue ∧ guard as `active_mask` and per lane as `pred_bit`; a predicate read as data is not a guard. MIU touches, and RCU writes, only active lanes |
| `fet_dec_instr.tier1_id` | slot / 2: warp 0 is tier-1 stream 0 |
| `ooe_fet_redirect.group_masks` | 32 bits per PC group, the taken lanes first, then the fall-through lanes |
| `kill_acks`, `kill_ack_epochs` | FET, DEC, OOE, RCU, MIU, SPM, SYU, PCA from bit 0 up |
| identities | instruction: `instr` class, seq = record seq. Line request on an instruction's behalf: owned `txn`, same seq, sub = line. ITLB and ifill: unowned `txn` |

### Events: what the skeleton emits

Seven of the twelve schema events:

| Event | Emitted by | vadd count |
|---|---|---|
| `EV_CH_XFER` | the checker bank, every transfer | 509 |
| `EV_DECODE` | DEC | 17 |
| `EV_DISPATCH` | OOE, ROB allocation | 17 |
| `EV_ISSUE` | OOE (`C_EXIT` isn't issued) | 16 |
| `EV_MEM_REQ` / `EV_MEM_RSP` | MIU per line; FET per ifill | 9 / 9 |
| `EV_RETIRE` | OOE, in order | 17 |

Not yet emitted: `EV_WAKEUP` and `EV_WARP_SELECT`, which need more than one
warp and a real scheduler; `EV_BARRIER_ARRIVE`/`RELEASE`, which need a
barrier kernel; and `EV_ID_LINK`, which needs a replay. Those come from S2's
kernels.
