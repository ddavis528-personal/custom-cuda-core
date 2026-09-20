# Reset-line template

**Fixed before Stage 4a**, while it is still a template question. Discovering
the format at the first block's grill-me means reopening it.

§6 of the strategy doc makes reset selective — not every state node is reset —
and rests the safety argument on one invariant:

> Un-reset state is payload. Payload is only ever read when an accompanying
> valid bit says it was written — and valid bits are always reset.

§7 makes proving that the third formal target. **F-8 changed what a block has
to write down for the property to be expressible at all.**

## What changed, and why the obvious format does not work

The natural reset line is a list: *these nodes are reset, these are not*. That
is not enough.

Under formal an un-reset register gets a free **two-state** value, not X. So
`$isunknown(payload)` is identically false, the property is vacuously true, and
**the formal target reads as discharged having never been checked** — the worst
available outcome, because it is green.

The invariant has to be stated structurally instead, over the valid bit:

```systemverilog
`CCV_ASSERT_READ_VALID(rob_read_guarded, rob_rd_en_cs02h, rob_entry_v_cs01h)
```

which requires knowing, for each payload field, **which bit guards it**. A list
of un-reset nodes does not carry that.

## The format

Each block's Stage 4a spec carries a table. One row per un-reset field; no
field may be omitted.

| Payload field | Guarding valid bit | Read enable | Written by |
|---|---|---|---|
| `rob_pc_cs01h` | `rob_entry_v_cs01h` | `rob_rd_en_cs02h` | dispatch |
| `iq_operand_cs03h` | `iq_slot_v_cs03h` | `iq_issue_sel_cs03h` | wakeup |

And a matching list of reset state, which needs no pairing:

| Reset state | Why it must be reset |
|---|---|
| `rob_entry_v_cs01h` | valid bit — the guard itself |
| `rob_head_cs00h` | pointer; an un-reset pointer aliases a live entry |
| `iq_credit_cs00h` | credit counter |

## Rules

1. **Every un-reset field names its guard.** No guard, no un-reset — reset it
   instead. An un-reset field whose guard cannot be named is one whose safety
   argument does not exist.
2. **Guards are always reset.** §6's invariant, and the reason the pairing is
   sound: the guard's own correctness does not depend on anything un-reset.
3. **The read enable is named too.** `CCV_ASSERT_READ_VALID` needs it, and
   naming it at 4a is what makes the property writable at 4c without
   re-deriving it.
4. **One property per row**, generated from the table rather than written by
   hand, so a row added without a property is not possible.

## What this is not

Not a claim that formal will *prove* the block X-free. It cannot — see F-8 and
F-16: under formal there is no X to find, and Verilator is 2-state, so Icarus
is the only tool in the flow that observes X at all.

What this discharges is the **structural** invariant — that a read is always
guarded — which is what §6 actually asserts and what makes selective reset safe.
The X-propagation question is separate and answered by the Stage 4c X-pass.
