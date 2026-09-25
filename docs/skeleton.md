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

`build/skel/ccv-skel --cycles 2000 --seed 1 --trace t.ccvtrace` runs S0;
`tools/trace2perfetto.py t.ccvtrace -o t.json` makes the Perfetto view, one
track per channel.

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
`ccv_credit_checker` once per slot — 339 of them — and the skeleton clocks it
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

| Clean result (3 seeds, 2000 cycles, ~231k messages each) | Negative control |
|---|---|
| 0 checker violations | `--break phantom-all`: all 339 checkers fire `no_phantom_credit`, each by name — proves every slot's `credit` wiring |
| | `--break stall-all`: all 339 fire `stall_honoured` — proves every `stall` and `valid` |
| `EV_CH_XFER` payloads (bits 63:0) equal the launched payloads, as a multiset | the match is exact, so one miswired payload bit fails it |
| 0 payload mismatches at the receivers; sent == received; no idle slot | — (end-to-end data check, independent of the bank) |
| C++ field offsets == SV packed structs | `--mutate`: every shiftable field must disagree |

The payload wiring gets the event-stream check rather than a negative control
because Verilator is two-state: `payload_known_when_due` cannot fire there at
all, so an X-injection control is not available on this simulator.

---

## Assumptions that need your confirmation

**A-S1 — rate > 1 means independent slots.** 15 channels have rate > 1. The
specs say only *"rate is per cycle at peak"*; nothing says what a rate-4
channel is at signal level. The skeleton models it as `rate` independent
slots, each a complete four-signal credited channel with its own checker —
the literal reading of "every channel follows the common conventions". The
alternative is one valid vector with a shared credit pool and one stall.

The two differ in RTL port count, in whether messages on different slots can
reorder, and in receiver buffering (8 slots × depth 2 = 16 entries, versus a
pool sized independently). It is isolated in `tools/gen-skel.py` and
`sim/skel/channel.h`, so changing it touches those two, not the stubs.

**A-S2 — a multi-instance endpoint replicates the channel.** LANE has 32
instances, so `rcu→lane ops` and `lane→rcu res` are 32 channel instances each
(256 of the 339 slots). A channel with *both* ends multi-instance has no
defined pairing and is a generation error rather than a guess. None exists
today.

## Gaps found while wiring it

- **The external port is outbound only.** `ccv_exb_ext` goes EXB → EXTERNAL
  and nothing comes back. TileLink TL-C has inbound channels (B and D), so
  either the flattened `tilelink_tlc` bundle is meant to be bidirectional —
  which a one-direction channel cannot be — or an inbound channel is missing.
  S1 does not need it (memory is testbench-side, behind MIU), but the EXB
  session does.
- **`EV_CH_XFER` has no real instruction id.** The checker passes the payload
  where the record's `instr_uid` goes. §1 pins every event to an instruction;
  for channel transfers, identity lives in payload fields (`rob_tag` on some
  channels, nothing on others). S1 is where that has to be decided, since
  `--by=instr` in the Perfetto view is meaningless until it is.
- **Unit is `UNIT_UNKNOWN`** for every channel transfer, because the checker
  sits between two blocks and belongs to neither. The Perfetto view puts
  `EV_CH_XFER` on a track per channel instead, recovered from its `a` field,
  so nothing is lost; noted only because the record itself does not say.

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
