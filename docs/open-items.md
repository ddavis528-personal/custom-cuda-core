# Open items

The one list of what is undecided, unbuilt or unconfirmed, with **running,
fixed numbering**, as in the compiler repo's F-/O- registers. It exists so a
review can say "Q-21" instead of "item 4 of the latest five".

**Rules** (`tools/check-docs.sh` enforces the ones a script can check):

- **An ID is never renumbered and never reused.** A new item takes the next
  number. The numbering has no holes: closing an item changes its status and
  keeps its row, with the resolution in it.
- **Every item has one row here,** and other docs refer to it by ID rather
  than restating it. Where a doc does give the context, the ID comes with it.
- **Status is one of four,** and it's the first word of the row's status:
  - **open**: a decision nobody has made yet;
  - **awaiting confirmation**: built one way provisionally, needs a yes or a
    redirect;
  - **scheduled**: the answer is a named stage's deliverable, and nothing is
    blocked before then;
  - **closed**: decided or built, with what was decided.
- **A schema `open_questions` entry carries its ID** (`"id": "Q-n"`), and its
  row names the key (`Schema: key`). The check requires the two to agree, and
  requires the row not to be closed. Closing one means deleting the schema
  entry and closing the row, in the same change.
- **Not in this list:**
  - Stage 1a tool findings (`F-n`, [`stage1a-findings.md`](stage1a-findings.md)).
  - Mechanisms that could pass vacuously ([`fail-open-register.md`](fail-open-register.md)).
  - Undecided payload widths. [`trust-report.md`](trust-report.md) generates
    that list from the parameters.
  - The compiler repo's numbering. That is always written "compiler F-n" or
    "compiler O-n" here.

## Now

The summary is checked against the table, so it can't drift from it.

- **Awaiting confirmation:** Q-19, Q-31, Q-32
- **Open:** Q-2, Q-3, Q-5, Q-7, Q-10, Q-17, Q-18, Q-21, Q-30, Q-33, Q-34
- **Scheduled:** Q-1, Q-4, Q-6, Q-8, Q-12, Q-13, Q-35, Q-36, Q-37

The ones with a deadline are Q-5, which must be settled before Stage 4a
populates the first arbitration-sensitive event, and Q-18, before floorplan.

## The register

"Raised" says where an item came from:

- *strategy §8 n*: the strategy doc's open item n.
- *Stage 1*: the Stage 1 review ([`rtl-findings-stage1.md`](rtl-findings-stage1.md)).
- *payload pass*: the 2026-09-25 width pass.
- *S1*: running `vadd`.
- *review n*: the n-th skeleton review response ([`skeleton.md`](skeleton.md)).

| Item | Raised | Owner | Status |
|---|---|---|---|
| Q-1 Arbitration-sensitive event content | strategy §8 1 | per block | **scheduled — Stage 4a, per block.** The mechanism shipped at 1c. The load-bearing content is the channel list, emitted as `EV_CH_XFER` by the shared checker, so it can't drift per block. What remains are the events whose outcome depends on an arbiter (issue cycle, wakeup-to-issue latency, warp select), which each block defines along with its internals. Q-5 comes first |
| Q-2 Six seed events coincide with a channel transfer | S1 | planning | **open.** `DECODE`, `DISPATCH`, `MEM_REQ`, `MEM_RSP`, `BARRIER_ARRIVE` and `BARRIER_RELEASE` each coincide with an `EV_CH_XFER` on a named channel. Each one needs a channel mapping or deleting. S1's stubs emit the first four as block-internal events (DEC; OOE at ROB allocation; MIU and FET per line). That works, but answers neither question |
| Q-3 `EV_DECODE` still claims to establish the uid | S1 | planning | **open.** Its schema text says it "establishes its uid for every later event", but the identity decision moved uid creation to fetch. It's a one-line edit, but in the planning side's schema, and it goes with Q-2 |
| Q-4 Arbitration policy spec | strategy §8 2 | per block | **scheduled — Stage 4a/4b, before each block's 4c RTL.** Not started. §5 is explicit that this buys temporal precedence, not independence: it makes a policy change a visible decision rather than silent drift in one implementation |
| Q-5 The 4d correlation criterion (A-1) | strategy §8 4; Stage 1 | planning | **open — a decision, due before Stage 4a populates the first arbitration-sensitive event.** The choice is exact match against a tie-break-faithful arbiter model, or a stated tolerance. `schema/events.json` records the criterion as OPEN, and the event record carries no tolerance metadata. So a tolerance answer adds a field and moves the schema hash, and after 4a that means reprocessing or discarding every trace captured |
| Q-6 Event-driven timing-model scheduler | strategy §8 6 | infrastructure | **scheduled — Stage 4b.** The skeleton's loop is a plain two-phase cycle over every block, which is enough while timing is placeholder. The swap interface the scheduler must preserve is channel ends plus one `cycle()` per clock (`sim/skel/machine.h`) |
| Q-7 Is 25 NGD the Vmin-corner number or a nominal one? | Stage 1 (§2) | planning | **open.** `CCV_NGD_BUDGET` carries the question. It sets how much margin each block holds back: at 0.55 V, variation and the wire/gate delay ratio both worsen, so headroom at nominal doesn't translate linearly. Q-17 depends on it |
| Q-8 The bounded-latency N, justified (A-3) | Stage 1, F-2 | infrastructure | **scheduled — a Stage 4b output; provisional by construction.** One global `CCV_P_TIMEOUT_N` (32) and a memory-path `CCV_P_TIMEOUT_MEM` (2048), which must exceed worst-case DRAM latency. Justifying either needs contention data that only 4b produces, so revising them is expected, not a spec change. Each N ships with a case that exceeds it and must fire. That's not yet met for `CCV_P_TIMEOUT_MEM` (`fail-open-register.md`) |
| Q-9 Do testbench-side memory interfaces consume block letters? (A-2) | Stage 1 | — | **closed — yes, and registered rather than left to collide.** `y` is reserved for fixtures. `z` is reserved for the reset tree, which needs stage numbering because a synchronous reset can't be delivered globally in one cycle |
| Q-10 Clock-gating equivalence is unverified (F-18) | Stage 1 | infrastructure | **open — settle before any synthesis result is believed.** The gated netlist has never been proved against the ungated one. That needs a real ICG cell rather than a blackbox, and a gated clock that isn't a free variable. Nothing relies on it today |
| Q-11 Block letters: is 26 enough? | Stage 1 | — | **closed by the partition.** 14 block types plus `y` and `z` leaves 8 spare, so the single-letter stage tag stands and no tagged net changes |
| Q-12 Synthesis exclusion for checkers | Stage 1, F-9 | per block | **scheduled — Stage 4c.** `bind` provided it for free; F-9 removed `bind`. The SV top instantiates its checkers only under `CCV_CHECK`, and Yosys is asked both ways that the synthesis view has none. Real block RTL must follow the same rule at its own ports |
| Q-13 Direction discipline without modports | Stage 1 | infrastructure | **scheduled — re-ask at the end of Stage 3.** Direction is declared in `schema/interfaces.json` and carried into the generated header. The test is whether a block author can get a direction wrong and have it caught, and nobody has yet written a block by hand against a generated port list |
| Q-14 Backpressure convention | Stage 1 | — | **closed at Stage 2 — a credited protocol, not `_ready`.** `_valid` and `_payload` come from the producer, `_credit` and `_stall` from the consumer, and `_wake` is a fifth signal from the sender (review 1). Backpressure stays outside the packed struct, so the swap harness drives the payload one way (F-12) |
| Q-15 Payload field widths | Stage 2 | — | **closed for wiring by the payload pass (2026-09-25).** Every field has a width, tiered decided / provisional / preliminary in [`trust-report.md`](trust-report.md). The pass also corrected four widths that were confidently wrong: `warp_mask_released`, `bank_addr`, `phys_pred` and `barrier_entries` ([`roadmap.md`](roadmap.md) Part 1). The cross-channel part is Q-34 |
| Q-16 Checker reuse across block swap | Stage 1 | — | **closed at Stage 3 — the SV checker itself.** The C++ skeleton Verilates the bank of real checkers rather than porting them, so a C++ stub and a swapped-in RTL block are judged by the same code |
| Q-17 Per-interface NGD budgets | Stage 2 | planning | **open — not started,** against the 25 NGD envelope (Q-7) |
| Q-18 RCU→MIU is ~8,400 wires: co-locate the AGUs? | payload pass | partitioning / floorplan | **open — settle before floorplan.** Schema: `rcu_miu_width`. `index_per_lane` (1024) sits beside `store_data` (1024) at rate 4. That argues for putting the AGUs with RCU, or moving address generation into register read. Block boundaries are swap boundaries, so the answer may move one. Q-22 put the AGU in MIU for S1 |
| Q-19 Store data on MIU→DCU | S1 | memory-path payload owner | **awaiting confirmation.** Schema: `miu_dcu_req_store_data`. `ccv_miu_dcu_req` had nothing that could carry what a store writes. S1 added `write_data` and `byte_mask`, mirroring `ccv_miu_spm_req`, which takes it from 56 to 1208 bits at rate 4. Confirm this, or name a separate store-data channel |
| Q-20 A third source register | payload pass; review 1 | — | **closed (review 3) — named fields `src2_arch` and `phys_src2`.** Format A `mad.lo`, `dp4.*`, `dp2.*` and `ffma.f0` read an independent `rs2`. The invariant, recorded in [`skeleton.md`](skeleton.md): accumulate-into-destination is Format J's alone (`mad.acc`, `dp4.acc`, `ffma.acc`). `dst_arch` always means the destination |
| Q-21 One predicate field for guard and destination | S1 | ISA / compiler track | **open.** Schema: `pred_src_and_dst`. The uop has one `pred_reg`, so `@P0 setp P1, …` has no encoding. It blocks rename of predicate destinations. S1 refuses such a record, and vadd only uses P0 |
| Q-22 Immediates, and where the AGU lives | S1 | — | **closed (review 1).** `disp` (sign-extended, compiler F-143) and `scale_en` ride on `ooe_miu_memop`, and MIU is the AGU. ALU immediates ride on `ooe_rcu_issue`, and RCU substitutes them into an operand slot at register read. Was schema key `agu_immediate` |
| Q-23 Two lane masks | S1 | — | **closed (review 1).** `issue_mask` rides on `ooe_rcu_issue` and `ooe_miu_memop`. `active_mask` is produced only by RCU, which holds the predicates. MIU checks active ⊆ issue. Was schema key `active_lane_mask` |
| Q-24 ITLB response correlation | payload pass | — | **closed (review 1) — FET is single-miss-outstanding, asserted rather than tagged.** The bank's outstanding checker enforces it, and `--break itlb-double` is its control. Was schema key `itlb_correlation` |
| Q-25 Load write-back destination | S1 | — | **closed (review 3).** The memop carries `phys_dst` and `phys_pred`, and MIU echoes both with `pred_we`, so RCU is stateless on write-back. `--break corrupt-echo` is its control. Was schema key `miu_rcu_phys_dst` |
| Q-26 Branch resolution | review 1 | — | **closed (review 2) — RCU resolves.** `branch_taken` and `branch_mask` ride on `ccv_rcu_ooe_done`, and OOE redirects on the new `ccv_ooe_fet_redirect`. The guard's negate (`pred_neg`) was found missing on the way. Was schema key `branch_resolution` |
| Q-27 Predicate source operands | review 1 | — | **closed (review 2) — already decided** by compiler O-33 (round 16): predicate logic executes in RCU. Was schema key `pred_source_operands` |
| Q-28 A predicate read as lane data (`sel`) | review 2 | — | **closed (2026-09-25) — `sel` runs in the lane, with a `pred_data` bit.** RCU executes exactly two classes: ops whose sources and destinations are all predicates, and data moving horizontally between lanes (`shfl`, `vote`, `ballot`, `unballot`). Q-32 is the boundary. Was schema key `predicate_as_lane_data` |
| Q-29 Who owns PC-group state | review 2 | — | **closed (review 3) — FET, migrating over a FET↔PCA pair.** `pcs` moved off the RCU↔PCA pair, which took the design to 44 channels. The sequencing is Q-30. Was schema key `pc_group_state_owner` |
| Q-30 Nothing carries migration sequencing | review 3 | RAU / PCA sessions | **open.** Schema: `migration_control`. RAU sequences both migrations and waits for both acks, but no channel tells FET to send or accept, and no ack reaches RAU. `ccv_rcu_pca_mig` also never said which warp or bank it carries. Smallest fix: a RAU→FET migrate command and a PCA→RAU done, making 46 channels. Blocks demotion and restore |
| Q-31 `kill_warp_mask` is 32 bits, not 4 | review 2 | you | **awaiting confirmation.** It was sized to the four tier-1 warps, but PCA and SYU hold state for parked warps, which a tier-1 mask can't name. Built at 32, one bit per warp context |
| Q-32 RCU op-class boundary cases | review 2 | you / ISA | **awaiting confirmation.** Two ops are filed under Q-28's first class (all-predicate) by reading rather than by statement. Branch resolution reads a predicate and produces a lane mask for OOE, touching no GPR. `pmov` writes a constant to a predicate and has no register source at all. Both execute in RCU as built, and `payload-spec.md` says so |
| Q-33 Wake's timing contract | review 1 | infrastructure | **open — before any block sleeps.** `_wake` exists, but how far it must lead valid (`CCV_WAKE_LAT`, 4) is not a checked property. No stub sleeps, so nothing depends on it yet |
| Q-34 Fields that cross abutting channels | payload pass | per-block sessions, jointly | **open.** `opcode` (three hops), `asid` (three channels) and `size`: two sessions each deciding one hop independently produce incompatible encodings, so these are settled across sessions rather than within one |
| Q-35 OOE sizing: `CCV_P_ROB_DEPTH`, `CCV_P_PHYS_REGS` | review 3 | OOE session | **scheduled — OOE's per-block session.** Both are provisional placeholders today |
| Q-36 TL-C burst structure | review 1 | EXB session | **scheduled — EXB's per-block session.** The flattened TL-C link stands in for a burst sequencer, not just a bus: a line is two 512-bit beats, and S1's EXB splits `PutFullData` into beats and gathers `AccessAckData` beats back |
| Q-37 The reset tree isn't modelled | S0 | infrastructure | **scheduled — before block RTL at Stage 4c.** Block letter `z` is reserved for it. In the skeleton `rst_n` fans out directly |

## Where the old numbers went

Before this register, open items were numbered per list, and every new list
restarted at 1:

| Old reference | Now |
|---|---|
| strategy §8 open items 1, 2, 4, 6 | Q-1–Q-3, Q-4, Q-5, Q-6 (3 and 5 were completed at Stage 1) |
| roadmap Part 3 items 7, 8, 11–19 | Q-7, Q-8, Q-9, Q-10, Q-11, Q-12, Q-13, Q-14, Q-15, Q-20, Q-18 |
| roadmap Part 3 items 9 and 10 | duplicates of Q-5 and Q-8 |
| roadmap Part 3 item 20 (payload questions) | Q-19, Q-21, Q-30 open; Q-20, Q-22–Q-29 closed |
| review 3's five items | Q-29, Q-23, Q-24, Q-20, Q-25 |
| `interface-checker-convention.md` §8 | Q-13, Q-14, Q-16 |
