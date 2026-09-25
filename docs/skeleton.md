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
| **S1 — `vadd`** | An instruction stream flows through the real channel path, values carried by the channels, retiring state identical to ccv-sim | Next |

`build/skel/ccv-skel --cycles 2000 --seed 1 --trace t.ccvtrace` runs S0.
`tools/trace2perfetto.py t.ccvtrace -o t.json` makes the Perfetto view, one
track per channel; add `--by=instr` for the per-instruction view.

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
reads all 144 fields back *through the real SV structs* and compares them with
the C++ table: zero disagreements over 64 random rounds. Its negative control
shifts every C++ offset by one bit, and the probe must catch every field that
can be shifted — 141 of 141 (the other three are single-field payloads).

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

| Clean result (3 seeds, 2000 cycles, ~230k messages each) | Negative control |
|---|---|
| 0 checker violations | `--break phantom-all`: all 340 checkers fire `no_phantom_credit`, each by name — proves every slot's `credit` wiring |
| | `--break stall-all`: all 340 fire `stall_honoured` — proves every `stall` and `valid` |
| `EV_CH_XFER` payloads (bits 63:0) **and trace ids** equal the launched ones, as a multiset | the match is exact, so one miswired payload or sideband bit fails it |
| 0 payload mismatches at the receivers; sent == received; no idle slot | — (end-to-end data check, independent of the bank) |
| `--force-atomic`: every multi-slot channel moves in whole groups, clean | `--break atomic-all`: all 77 atomic checkers fire both properties, and nothing else fires |
| The ordered channel is consumed in (arrival, slot) order, payloads keyed on its one sequence | `--break misorder`: consuming newest-first is caught — on exactly the ordered channels |
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
types, 102 instances, 339 slots. (The review's "102 from 41 types" was off by
one: 102 is 38 + 2×32.)

The review's point stands regardless: this is the one number a clean run does
not validate. A rate wrong by one on a ×32 channel moves the total by 32, and
every slot that exists is still checked. So `tools/check-skel.sh` re-derives
it from the schema with code that shares nothing with the generator
(`tools/skel-expect.py`), and requires the binary, the generated bank and the
document to agree with it.

---

## Interface decisions (2026-09-24), as built

### Rate > 1: independent slots, plus three attributes

Unchanged mechanism: `rate` independent credited slots, one checker each.
Three attributes per channel, each defaulting to the permissive value.
Only **decided** values are written in the schema. The generators apply
defaults otherwise and mark which is which, so a default is never read as a
decision. Setting one on a rate-1 channel, or without a recorded reason, is a
generation error.

| Attribute | Decided so far | How the skeleton honours it |
|---|---|---|
| `acceptance` | none atomic yet | `ccv_atomic_checker` on all 77 multi-slot channel instances, enabled by the schema; stubs send and consume whole groups |
| `ordering` | `dec→ooe uop` ordered; `miu→ooe cmpl` unordered | one sequence per channel, consumed in (arrival, slot) order |
| `slot_binding` | `fet→dec instr` bound; `ooe→rcu issue` free | slots stay separate streams; nothing in the skeleton pools them |

**Interpretation to confirm — atomic constrains valids too.** The decision
says credits move together, "letting RTL collapse to one counter". Credits
alone don't give that: if slots launched independently while credits came back
in lockstep, the per-slot counts would drift apart and one counter couldn't
represent them. So `ccv_atomic_checker` requires valids *and* credits to be all
or none each cycle. If only credits were meant, the check drops its
`atomic_valid` half.

The check exists before any channel is atomic on purpose. Were it only
recorded, marking a channel atomic later would assert nothing. Its `enable` is
the schema flag OR a test override that can only switch it on, so a channel
decided atomic can't be switched off at run time.

**The binding key is text, not yet a check.** `fet→dec instr` is bound as
"tier-1 stream = slot / 2". Checking that needs a payload field naming the
stream, and the payload carries `warp_id` (5 bits, 32 warps), not the tier-1
slot (2 bits). A check would have to know the warp-to-tier-1 mapping, which
belongs to OOE.

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

**Proposal to confirm — which classes each channel carries.** The decision
defines the classes; it doesn't assign channels. The skeleton proposes a
*set* per channel, since some carry more than one kind: EXB→MLC and the
inbound port carry fills (txn) *and* probes (none). Every message is checked
against its channel's set. The full assignment is in
[`skeleton-slots.md`](skeleton-slots.md); in short:

- **instr (13):** the instruction path, execute and memory ops, completion,
  retire, barrier arrive, fault;
- **txn (13):** SPM, DCU and MLC traffic, ifill, ITLB, outbound external, and
  barrier *release* (it wakes several warps);
- **txn + none (2):** EXB→MLC, inbound external;
- **none (13):** probes, launch, allocation, status, demotion and
  migration, CTA setup, CSR config.

In S0 the ids are synthetic: a pure function of the message, like the payload.
S1 assigns the real sequence at fetch.

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

§1: the timing model *"calls into ccv-sim for what an instruction does and
owns when."* The seam exists: ccv-sim's `Interp::step(Warp&, const MCInst&,
mask, pc, size)` executes one instruction against warp state.

The plan, so the check means something:

1. **Values originate at the oracle, travel the channels, and are committed
   by the sinks.** FET fetches real instruction bytes from testbench memory;
   DEC decodes through the same LLVM disassembler ccv-sim uses; execution
   values come from `Interp::step`; MIU commits stores from the payloads it
   *received*, not from the oracle's copy.
2. **The final state is compared against an independent ccv-sim run.** If
   every value came straight from the oracle to the result, the comparison
   would be tautological. Routing them through the channels is what makes it
   test the machine.
3. **Stubs replace the exerciser one block at a time**, each behind the same
   ports, with the S0 checks still running. Fixed latency, no arbitration
   (§8: "internal timing is placeholder").

**Prerequisite, recorded because it was not obvious.** ccv-sim builds against
LLVM 18 through the compiler repo's CMake, which needs `llvm-18-dev` — the
runtime `llvm-18` package ships no `LLVMConfig.cmake` — and `libzstd-dev`,
because Ubuntu's `LLVMExports.cmake` names `zstd::libzstd_shared` without
depending on it. A stale package index 404s on `libxml2-dev` until
`apt-get update`. With those, `cmake -DLLVM_DIR=/usr/lib/llvm-18/lib/cmake/llvm`
builds `ccv-sim`, and `custom-cuda-complier/test/elementwise.s` computes `c[i] = a[i] + b[i]`
correctly in 17 issue groups. `tools/setup-toolchain.sh` will take these on
when S1 first links the oracle.
