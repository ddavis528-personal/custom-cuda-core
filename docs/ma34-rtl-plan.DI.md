# MA-34 RTL plan (DI working notes; delete before the gate or move to DI.md)

Spec: DCU tab rev 150 (miss buffers, module table rows dcu_mshr / dcu_mpick),
DI-58, DI-61, DI-64. Model: sim/dcu/dcu_core.cpp (5de5b967).

## dcu_mshr: one instance a bank (parameter BK), 16 entries, ids {BK, e}
- One request port a cycle: the granted retry (from dcu_mpick's flops, its
  one-hot valid bit for this bank) else the bank's own new miss. bctl queues
  a new miss behind a waiter or pending retry, so they never meet.
- D1 staging: only the slot whose line is this bank's (A2 sends no two
  lookups to one bank, MA-27). Enable from this module's flop of the lead's
  bank match at H+2 (CG-5), so it needs each slot's lead bank bits at cc02h.
  One staged payload, not four (8 x 4 would cost ~2,200 flops).
- D2: line compare vs its 16, merge / allocate / wait, next free id (one
  offer, picked a cycle ahead), outcome at D3 (ov/owait/owhy for its bank).
- Per-entry 10-bit stamp at allocation (D2), from a free-running counter
  every bank and dcu_mpick reset together.
- MLC offer to dcu_mpick:
  - head: oldest unsent by the 16-entry age matrix, picked a cycle ahead,
    from flops: hv, hstamp; excludes the entry whose valid launched last
    cycle (DI-34 (iv)).
  - straight: this D2 allocates and no unsent entry is older (no head):
    sv, combinational from D2 (port budget: measure, ask MA).
- Sent: dcu_mpick's flopped one-hot grant (arrival 0) marks the head (or
  the straight record) sent; the payload (req_id low 4, PA, coh_op) for
  T+1 comes from flops: head flops if hv was set at T, else the record.
- Fill: frid {bank, entry}; reads its entry only when frid's bank == BK;
  its F+1 flops zero unless it was its fill, so dcu_fill ORs 8 buses
  (logic in dcu_fill, a child: no parent logic). flv is per bank already
  (bank b's mshr drives bank b's bctl lead), fwpa/fwfold to its own bctl.
- Free: xid {bank, entry}, decoded per bank.

## dcu_mpick: one instance
- Retry grant moved verbatim from dcu_mshr (DI-35): offers rov/rstp from
  bctl, rgv/rgb out, payload captured from the granted bank's flops into
  its flops, one-hot retry valid to the bank's mshr at D2.
- MLC pick at T: if any head offer valid, the oldest head by 10-bit stamp
  modulo, ties to the lowest bank; else the lowest bank with a straight
  offer (every straight stamp is now, younger than any head). Credit count
  (counting last cycle's send, DI-34 update 2). Writebacks first: not in
  RTL yet (part 2), leave a hook.
- valid flop at T+1 (H+5 for a straight), payload flops at T+2 from the
  sent bank's payload outputs (8:1 by its own grant flop, arrival 0).
- Bins / assertions: one send a cycle; never without a credit; alias (an
  offer older than 512) as an assertion-backed bench bin.

## Benches
- mshr_tb: one bank instance against the value model at BK = 0 and BK = 5.
- mpick_tb: random offers against a value model of both picks.
- a test-only harness of 8 mshr + mpick (test/dcu/), checking ids' banks
  and one new miss a bank a cycle against the model's CHECKs.
- Controls: dcu-miss-other-bank (an id from another bank), the age-alias
  bin, plus every control the single mshr had.

## Then, same gate
NGD/CG --unit for dcu_mshr (BK 0), dcu_mpick, bctl (req_id 8); budgets to
MA; increment B; DI-25 btag fill write; rarb/rslot; bdat wdata; p1 drop fix
(MA) and TI-537 if landed.
