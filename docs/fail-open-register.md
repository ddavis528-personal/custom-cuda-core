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

The three marked **silent** are the dangerous class: they do not merely fail to
detect, they produce a positive result that is wrong.

## Candidates Stage 2 introduces

Named in advance, because each will otherwise arrive without a control.

**Tracking registers inside checkers.** No multi-cycle SVA exists (F-2), so
every request-response contract becomes an explicit state machine in the
checker. A tracking register that silently never arms is indistinguishable from
one that passes — the same class as `bind`.

> **Required:** each tracking register ships with a deliberately-violated case
> that must fire, **built at the same time as the tracking logic**. Written
> afterwards, it gets written to match whatever the logic already does.

The tier-1b macros (`CCV_ASSERT_STABLE_WHILE`, `..._FOR`,
`..._RESPONSE_WITHIN`) are the worked example: each has a negative control in
`check-1b.sh`, one property per build, because Verilator `$stop`s on the first
failure and a multi-property negative test silently measures only one.

**Bounded-wait N large enough to be decorative.** Liveness is unstatable, so
every interface gets *outstanding more than N cycles is a failure*. Too large
and the property never fires under any circumstance the design can produce —
it is then a fail-open mechanism wearing a property's clothes.

> **Required:** each N ships with a case that exceeds it and must fire.

**Checkers instantiated but never reached.** A checker bound to a boundary that
never carries traffic reports nothing, forever, and looks identical to a clean
one.

> **Required:** the satisfiability covers already mandated by CCV-L14 cover
> this — provided they are *run*, which is why `check-if.sh` puts them through
> `sby -m cover` rather than trusting a simulation regression. A cover is
> `SILENT` in both simulators on this stack; it does real work only under
> formal.
