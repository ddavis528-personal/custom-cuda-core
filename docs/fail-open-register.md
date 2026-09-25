# The fail-open register

**Policy (strategy doc §10):**

> For any mechanism the plan depends on, establish whether it fails loud or
> fails open. Anything that fails open requires a negative control — a
> deliberately violated case that must fire — before any result from it is
> believed.

This file is the register: every fail-open mechanism in the flow, and the
control that makes its results trustworthy. **A mechanism added without a
control belongs here with its control marked missing, not left off the list.**

## Why a register rather than a habit

Stage 1's three worst findings were all fail-open, and none announced itself:

- `bind` under Yosys — parsed, dropped, proof green with no properties in it
- `$isunknown` on un-reset payload under formal — vacuously true, target reads
  as discharged
- a contradictory `assume` set — every dependent proof passes, no
  counterexample, nothing in the output distinguishable from success

A fail-loud mechanism tells you it broke. A fail-open one produces a normal,
confident, wrong answer, and the only way to know is to have deliberately
broken it once and watched it notice.

## The register

| Mechanism | Fails | Negative control | Where |
|---|---|---|---|
| Assertion macros fire at all | open | property written to be violated must fire, per tool | `check-1b.sh` |
| …and do not fire at everything | open | quiet build (`CCV_SMOKE_QUIET`) must report nothing | `check-1b.sh` |
| Assertion enable gate under formal | open | case 29 must still FAIL under `sby` | `check-1a.sh` |
| `assume` as a formal cut-point | open | case 33 PROVE-PASS **plus** a negative control that FAILs | spike 33 |
| Satisfiability covers | open | cases 34/35: vacuous proof passes, cover misses | `check-1a.sh` |
| Checker connection (`bind` vs instantiation) | **silent** | case 31 must stay SILENT, case 32 CHECK | `check-1a.sh` |
| Lint rules | open | every rule must fire on a fixture, rule by rule | `check-1d.sh` |
| …and not on compliant code | open | three `good_*` fixtures must report nothing | `check-1d.sh` |
| Event emission cycle accuracy | **silent** | paper-derived cycles must match exactly | `check-emit-calib.sh` |
| X-determinism construct choice | open | three constructions must DISAGREE on X | `check-xprop.sh` |
| Clock-gate sharing | open | one ICG for eight flops, not eight | `check-clockgate.sh` |
| Tool behaviour itself | **silent** | matrix re-measured, any cell change reported | `check-matrix-drift.py` |
| Documentation | **silent** | references, counts and rule coverage checked | `check-docs.sh` |
| Checker credit depth vs round trip | **silent** | `DEPTH=1` build must trip `cfg_depth_covers_round_trip` | `check-if.sh` |
| Checker timeout vs round trip | **silent** | `TIMEOUT_N=1` build must trip `cfg_timeout_covers_round_trip` | `check-if.sh` |
| Reference producer honours stall at every phase | **silent** | stall pulse swept across 28 phases; the old late-stall producer (`CCV_NEG_LATE_STALL`) must be caught | `check-if.sh` |
| Skeleton checker bank wiring (every slot) | **silent** | `--break phantom-all` / `stall-all`: all 343 checkers fire by name | `check-skel.sh` |
| Atomic acceptance | **silent** | `--break atomic-all`: all 77 groups fire both properties; `--force-atomic` must stay clean | `check-skel.sh` |
| Ordered consumption (per key) | **silent** | `--break misorder` must be caught on exactly the ordered channels | `check-skel.sh` |
| Lane lockstep | **silent** | `--break lockstep-all`: one lane alone — both lockstep checkers fire, nothing else | `check-skel.sh` |
| Lane slot binding (same instruction per slot) | **silent** | `--break misbind`: lane 7 carries slot k+1's instruction in slot k — only `lockstep_id` fires | `check-skel.sh` |
| Slot attribute specification | **silent** | each rule in `gen-interfaces.py` rejects its bad case (checked once, by mutation) | `gen-interfaces.py` |
| Id class per channel | **silent** | `--break wrong-class`: all 41 channels report | `check-skel.sh` |
| Trace id kept out of synthesis | **silent** | Yosys asked both ways: no `ch_tid` without `CCV_TRACE`, present with | `check-skel.sh` |
| Skeleton slot count | **silent** | re-derived from the schema by code sharing nothing with the generator | `check-skel.sh` |
| Gate summary parsing | **silent** | keys matched whole; see below | `check-skel.sh` |
| Credit checker protocol properties | open | 11 cases: each violation trips *exactly* its property on Icarus and trips it first on Verilator; each legal extreme stays quiet | `check-if.sh` |
| S1 final state compared with ccv-sim | **silent** | a compare fed from the oracle instead of the machine would always pass. `--break corrupt-load` must change the final R9, and `--break drop-store` all 32 words of `c[]` | `check-kernel.sh` |
| S1 per-consumer checks against the oracle | **silent** | `--break corrupt-fetch` must be caught at DEC, and `corrupt-load` at the lane receiving the operand | `check-kernel.sh` |
| Response correlation by `req_id` | **silent** | FIFO order matches ids by coincidence while one request is outstanding. `--break corrupt-req-id` must be refused by MLC, not taken as the oldest | `check-kernel.sh` |
| Binding key (fet→dec `tier1_id`) | **silent** | `--break misgroup`: every message names the next group — only `binding_key` fires. The wiring controls force well-formed payloads so they trip only their own property | `check-skel.sh` |
| Outstanding limit (one ITLB miss) | **silent** | `--break itlb-double` must trip `within_limit` and nothing else. The checker's formal covers must be reachable, and they were not at first: see below | `check-kernel.sh`, `check-if.sh` |
| MIU's AGU on carried displacement and scale | **silent** | `--break corrupt-disp`: a displacement off by 4 must fail MIU's address check against ccv-sim | `check-kernel.sh` |
| Branch resolution (guard negate) | **silent** | the negate was not carried, and the check agreed with the stub because both read the un-negated predicate. `--break drop-negate` now must make RCU's resolution and FET's redirect both disagree with ccv-sim | `check-kernel.sh` |
| Stateless load write-back (MIU's echo) | **silent** | a wrong echo writes a load into the wrong register, and the final compare can miss it (the next load overwrites it, and ALU results come from the oracle). `--break corrupt-echo` must be rejected by C_ADD's lanes | `check-kernel.sh` |
| A predicate read as data (`sel`) | **silent** | the lane's result comes from the oracle, so a wrong selector would not show in the result. `--break drop-pred-data` on the sel kernel must be rejected by the lanes that choose `rs0` | `check-kernel.sh` |
| Where an op executes (the lane-data rule, Q-32) | **silent** | a class table that put an op on the wrong side would still produce the right final state, since both sides compute the same answer. The lanes and RCU check every op against what its record reads. `--break drop-q38-exception` removes the one pending exception and must fail exactly the `movi`/`movi48`/`srd` lane checks, all 32 lanes each, and nothing else | `check-kernel.sh` |
| Open-items register consistency | open | a hole in the numbering, a summary that disagrees with the rows, a schema question pointing at the wrong or a closed row, and an undefined Q-n were each introduced once by hand and each failed | `check-docs.sh` |
| Encode/decode round trip coverage (compiler repo) | **silent** | 85 instructions were "unbuildable" and skipped while the check printed clean (compiler F-144). Any unbuildable instruction now fails it | `ccv-roundtrip` |
| Golden oracle record vs ccv-sim | open | SKIPs, visibly, without the compiler repo. The compare was mutated once by hand (one mask bit flipped in the checked-in record) and failed | `gen-golden.sh --check` |
| ccv-sim `-oracle` memory flags | **silent** | the record reported `"load":0` beside 32 reads (compiler F-141). It now refuses a step whose traffic the descriptor does not declare; checked once by dropping `LD_GLOBAL`'s flag | compiler repo |

The ones marked **silent** are the dangerous class: they do not merely fail to
detect, they produce a positive result that is wrong. The two checker
configuration rows are silent in the same sense — a credit depth below the
round trip throttles the channel while breaking no protocol rule, so it
presents as healthy backpressure, and a timeout below the round trip fires on
a channel behaving perfectly, which teaches the reader to disbelieve the
check.

Those two controls are also a worked example of a control that reported the
wrong answer while working: a tripped assertion calls `$stop` and the binary
aborts (F-15), and under `set -o pipefail` that abort status becomes the
*pipeline's* — so `Vtb | grep -q` reported failure on the very run that was
supposed to fail. Both now run to a file. Any future fire-test written the
obvious way has the same bug.

## The gate itself failed open once

The skeleton prints one summary line of `key=value` pairs, and the gate read
each key with a substring match. When `class_violations=` was added to that
line *ahead of* `violations=`, a bare match for `violations=` found the
class count first. **A run with 186 checker violations read as 0.** It was
caught only because a negative control reported the 186 while the summary
line said 0. Keys are now matched whole: preceded by a space or the line
start. The same trap had already bitten once, with `slots=` inside
`idle_slots=`, and that time it failed *closed*. The second time it failed
open.

The lesson is general: a check that parses its own evidence is a mechanism
with its own failure mode, and it needs the same treatment as any other.

## The covers caught a vacuous checker, first time out

`ccv_outstanding_checker` was first written, like the credit checker, with
`CCV_ASSUME_KNOWN` on its two inputs to satisfy CCV-L08. Its formal harness
drives those inputs from a register. With the two assumptions in place,
**every cover in the harness was unreachable**, including a plain
`cover(req)` added as a probe. The assumption set admitted no trace at all,
so any assertion proved against it would have passed having checked nothing.
The mandatory satisfiability covers (§3.3) are what reported it. The
counter now selects with ternaries, CCV-L08's other sanctioned form, and all
covers are reached. The root cause, why the known-assumption on a
register-driven input empties the trace space under Yosys, is not yet
isolated.

## Closed: the credit checker's protocol properties — and what that found

This section used to record a gap: the checker's five protocol properties had
no negative control, only proof that they stayed quiet against a correct
producer. `test/neg/tb_credit_neg.sv` closes it, and **the first run found
four bugs in a checker that every "stays quiet" check had been passing.**
That is the case for this file in one paragraph.

The cases were written from the protocol before looking at how the checker
counts, as the Candidates section below requires. Each drives the checker's
ports directly, one violation per case, and the legal extremes are tested
too — exactly `DEPTH` outstanding, a credit back at exactly N — because an
off-by-one in a tracking register is invisible to a case that only ever
overshoots.

| Case | What it found |
|---|---|
| `timeout_n1` — credit back N+1 cycles after the send | **Quiet.** The age counter started one edge after the credit was consumed, though the checker's own comment says a credit is consumed when valid asserts. Loose by one. |
| `timeout_second` — first message answered, second never | **Fired late.** Answering the oldest message reset the only age counter, so the next message's clock restarted from zero. |
| `second_late` — first answered at exactly N (legal), second never | **Fired 31 cycles late.** The same bug at its worst: any message but the oldest could be outstanding for up to ~2N. The "decorative N" failure below, in a real form. |
| `phantom` — a credit with nothing outstanding | **Right property, then a wrong one.** The count wrapped, so the next report was a bogus `no_overrun` — pointing whoever debugs it at the sender when the receiver is at fault. Only Icarus showed it; Verilator stops at the first failure. |
| `phantom_with_send` — a credit on the same edge a send is consumed | **Quiet.** The property excused it, but the round trip is at least 2, so that credit cannot belong to that message. |

Fixed in the checker, not in the tests: ages are now **per message** (a
three-entry queue at `DEPTH` 2), counted from the consuming edge; the
outstanding count saturates at both ends; and the phantom property no longer
excuses a coincident send. The gate was also run against the **old** checker
to confirm these five cases reject it — a control that passes both versions
proves nothing.

**Then the same discipline turned on the reference producer.** Porting
`test/smoke/credit_smoke.sv` into the skeleton meant reading it closely, and
its sender gated `valid` on a *registered* copy of stall — the stall from one
cycle too early. Swept across every stall phase, it violated the rule at 14 of
28. Its smoke test had passed since Stage 1 because the one stall window it
used landed where the producer was out of credits anyway. That is silent in
exactly the register's sense: a "stays quiet" check, quiet for the wrong
reason. The producer is fixed, the sweep is permanent, and the old bug is
kept behind `CCV_NEG_LATE_STALL` so the sweep has to keep proving it can see
it.

**One structural limit, recorded rather than worked around:** Verilator is
two-state, so `payload_known_when_due` *cannot* fire there — an X is already
a 0 or a 1 by the time anything looks. Icarus is the only witness for that
property, which makes it a required simulator for this check rather than a
redundant one (F-6).

## Candidates Stage 2 introduces

Named in advance, because each will otherwise arrive without a control.

**Tracking registers inside checkers.** ✅ **Control built — and it found
four bugs**; see the section above. No multi-cycle SVA exists (F-2), so every request-response
contract becomes an explicit state machine in the checker. A tracking register
that silently never arms is indistinguishable from one that passes — the same
class as `bind`.

> **Required:** each tracking register ships with a deliberately-violated case
> that must fire, **built at the same time as the tracking logic**. Written
> afterwards, it gets written to match whatever the logic already does.

The controls were written after the tracking logic, which is exactly the
risk named here — so they were written from the protocol and run against the
checker unchanged first, and every disagreement was treated as the checker's
bug until shown otherwise. All four were.

The tier-1b macros (`CCV_ASSERT_STABLE_WHILE`, `..._FOR`,
`..._RESPONSE_WITHIN`) are the worked example: each has a negative control in
`check-1b.sh`, one property per build, because Verilator `$stop`s on the first
failure and a multi-property negative test silently measures only one.

**Bounded-wait N large enough to be decorative.** ✅ **Control built** —
`timeout`, `timeout_n1`, `timeout_second`, `second_late` all exceed N and must
fire; `timeout_at_n` sits exactly at it and must not. Liveness is unstatable, so every interface gets *outstanding more
than N cycles is a failure*. Too large and the property never fires under any
circumstance the design can produce — it is then a fail-open mechanism wearing
a property's clothes. N is now one global provisional (`CCV_P_TIMEOUT_N` = 32)
plus `CCV_P_TIMEOUT_MEM` = 2048 for the memory path.

Note that `cfg_timeout_covers_round_trip` does **not** cover this. It guards N
being too *small*, which is the loud failure. Too large is the quiet one.

> **Required:** each N ships with a case that exceeds it and must fire. Met
> for `CCV_P_TIMEOUT_N`. **Not yet met for `CCV_P_TIMEOUT_MEM`**, because no
> checker instance uses it yet — the first memory-path instance must bring
> its own case.

**Checkers instantiated but never reached.** ✅ **Arrived with its control.** A
checker at a boundary that never carries traffic reports nothing, forever, and
looks identical to a clean one.

> **Required:** the satisfiability covers already mandated by CCV-L14 cover
> this — provided they are *run*, which is why `check-if.sh` puts them through
> `sby -m cover` rather than trusting a simulation regression. A cover is
> `SILENT` in both simulators on this stack; it does real work only under
> formal.
