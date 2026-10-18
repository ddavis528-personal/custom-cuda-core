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
| …and not on compliant code | open | six compliant fixtures, one per namespace shape (`ccv_reference*.sv`, `reference_*.sv`) and `reference_compare.sv`'s comparisons, must report nothing | `check-1d.sh` |
| How the rules read an assignment (CCV-L20, L23, L24) | **silent** | a comparison read as an assignment ran to the next semicolon and took the statements after it as its right-hand side, so the real assignment there was never checked, or its finding named the compared net (OI-40). Two findings behind a comparison, in `bad_naming.sv`, must each name the net that is wrong | `check-1d.sh` |
| Stale generated files | **silent** | a file a generator no longer writes stayed in `rtl/generated/`, `sim/generated/`, `rtl/top/` or `test/top/`, and the globs that build from them went on compiling it; only a fresh checkout differed (OI-40). Six controls on a scratch tree (`genout.py --selftest`): a dropped output reported under `--check` and removed on a run, another generator's file left alone, an unowned file and a deleted generator's file each a stray, a manifest missing a new output stale | `verify.sh` (`genout.py`) |
| A build made by another Verilator | **silent** | make tracks sources, not the tool, so after a Verilator change `build/` kept the old version's objects. With the old headers removed every build stopped, which is loud; with them still installed (a later version under its own `/opt` prefix) make rebuilt nothing and linked the old objects (OI-40). `build/.verilator` records the version; three controls on a scratch tree (`build-stamp.py --selftest`): no record clears, the same version clears nothing, another version clears all but the compiler snapshot and the oracles | `verify.sh` (`build-stamp.py`) |
| A Verilator that miscompiles RTL it accepts | **silent** | 5.020 dropped two arrivals' payloads from ooe_decq when its flop was an if/else of two function calls, and every bench built on it would have trusted the result (OI-40). OI's RTL now avoids the form, so nothing in `rtl/` would show it coming back. `test/vl/vl_decq.sv` freezes the queue with its flop in both forms, driven alike and compared every cycle; one planted payload must be caught, and the guard fails under 5.020 (checked by hand with `--expect-fail`, since CI has no 5.020) | `check-vl-reorder.sh` |
| Yosys reading RTL differently from the simulators | **silent** | a netlist that is not the RTL makes every count, depth and proof over it wrong while it passes. Each Yosys warning that means so (a select out of bounds set to undef, an implicit net, conflicting drivers, an undriven read, a loop) is an error wherever the gate runs Yosys, SymbiYosys's included (`tools/shim/yosys`, OI-44). Each is provoked by a fixture in `test/yosys/` that plain Yosys passes with a warning and the shim must refuse; clean RTL must pass; a proof over the out-of-bounds fixture must fail inside sby; the gate's PATH must have the shim first. Not caught: a misread with no warning, as `ooe_wake`'s (Yosys 0.33 dropped a saturating increment in a function); only a replay shows one, which is what check-cg does for every unit | `check-yosys-strict.sh` |
| Logic depth: the stage and the port budgets (NGD-1 to NGD-5) | **silent** | each module is measured alone, so a path that crosses a port is cut there, and a timing pass that misread the mapped netlist would pass anything. The pass's longest path must equal ABC's on every run, and a delay table with one gate wrong must stop it. Fixtures in `test/ngd/fixtures/`: an output 13.5 NGD after its flops, an input 13.5 before its flop, a 16 x 16 multiply flop to flop (32 NGD), and a gate straight through a module, input to output, must each be found, the last with budgets that would converge over it; an input wired straight to an output must be timed as a wire and pass; the gate straight through must pass when its module is declared an inner helper, or its output an observation port; a budget file named for another module, one for a module that does not exist, and entries on a missing port, naming both an arrival and a required time, not true as an observation, or with no why must each be refused, as must an inner helper with port budgets, with flops, or with no why; the ratchet only shrinks; a module with no unit is refused | `check-ngd.py --selftest` |
| Logic depth: the assembled block | **silent** | the budget files can claim a convergence the hierarchy does not have, and port budgets assume synthesis keeps a module's logic on its side of the port, which flattened it does not (two 64-bit parities in series map shallower than their halves add up to). So an assembled block is converged from its budget files, level by level, inner helpers flattened into their parents: a driver required at 14 straight into a receiver arriving at 15 must pass, and with the driver moved to 16 must fail; an XOR between the two, the parent's own or an inner helper's, touching no flop of the parent's, must fail as glue (NGD-5); the inner helper's XOR before the parent's flop must pass, and fail when the helper is not declared inner and is cut out at its default ports. A unit with children is checked on its own level the same way: its glue must be found, keyed by the pins, and a unit with only an inner helper inside has no findings. Then it is timed whole: two 8-bit multiplies in series across a module boundary (42.6 NGD) must fail, a block output one gate after its flop must fail, and an input through 64-bit parity before its flop must fail. Not exercised on the real tree until a block top is RTL | `check-ngd.py --selftest` |
| Local clock gating: the form of an `always_ff` (CG-1) | **silent** | a parser that cannot read a block, or a reset taken for an enable, would pass a register no enable guards. Unreadable is never compliant: anything that is not an enable `if` is reported. Controls on `test/cg/fixtures/`: a register written every cycle, an expression enable and an enable not named `_en` must each be found, and the compliant fixture, whose free-running LFSR is excused by measurement, must be clean | `check-cg.py --selftest` |
| Local clock gating: enable depth (CG-2) | **silent** | a cone cut short (an input taken for a flop, a gate type dropped) reads shallow. An unknown cell type stops the run; a 16-bit add and compare into an enable must measure over `CCV_NGD_CG_EN`, and a flop-driven enable beside it must not | `check-cg.py --selftest` |
| Local clock gating: DCGE (CG-3) and its replay | **silent** | DCGE is counted on the netlist from a bench's port trace, so a trace sampled on the wrong edge, from the wrong instance, or of another parameterisation measures something the bench never ran. The replay compares every output with the bench's on every cycle; a trace of another module must be refused. A group enabled on every valid that almost never changes must be found | `check-cg.py --selftest` |
| Local clock gating: what counts as a clock gate (CG-4) | **silent** | a group under `CCV_CG_MIN_FLOPS` gets no ICG, so judging it as a gate would pass flops that are clocked every cycle; splitting one enable into two groups by a reset that acts only in reset cycles would push both under it. A 4-flop group that holds when idle must be reported under CG-4 and never judged by CG-2 or CG-3; a register with the module's reset must share its enable's gate with one without | `check-cg.py --selftest` |
| Local clock gating: the module and block budgets | **silent** | a budget excuses findings with no one looking, so a wrong count excuses too much. Each module may leave the larger of 2% of its flops and fewer than `CCV_CG_MODULE_FLOPS` outside the rules: a 4-flop finding must be taken by the fixed count, a 9-flop one in a 521-flop module only by the 2%, 16 loose flops in a small module must not be, and a misnamed enable never is. What the modules take counts per instance against 2% of each block: 4 of 260 flops must hold, 8 of 136 must fail. The block check is not exercised on the real tree until a block top is RTL. Its counts come from a netlist synthesised with its hierarchy kept, which nothing replays, so each unit's module synthesised that way must count what its replayed netlist counts, totals and taken findings; a fixture read one flop short in that flow alone must be refused (OI-44) | `check-cg.py --selftest` |
| Local clock gating: the scenarios | **silent** | DCGE is only as good as the scenarios. An idle that is not idle, or a high that is not high, passes enables that would fail in use. All three must exist, each at least 1,000 counted cycles, with input activity rising idle < medium < high; swapped idle and high, and a short scenario, must each be refused. Not caught: a scenario whose data changes with no message, which inflates every DCGE (the guide names it) | `check-cg.py --selftest` |
| Local clock gating: waivers and the ratchet | **silent** | a waiver outliving its finding, or a ratchet that grows, quietly widens what is excused. A waiver that excuses nothing is refused, and so is one for a finding a module's budget already takes; a ratchet entry outside the 2026-10-16 baseline is refused, and so is a listed module that now meets the rule; a module with flops and no unit and no ratchet entry is refused | `check-cg.py --selftest` |
| Module classification by name (CCV-L28) | **silent** | a common module is exempt from the clock-naming and stage rules, so a name misread as common silences them, and a block top read as anything else loses its gate check. 19 refusals (`bad_module_names.sv`, `bad_blocks.json`, the real top under its pre-OI-37 name for the generated-tree pass) must each be found by name, exactly 19 | `check-1d.sh` |
| Event emission cycle accuracy | **silent** | paper-derived cycles must match exactly | `check-emit-calib.sh` |
| X-determinism construct choice | open | three constructions must DISAGREE on X | `check-xprop.sh` |
| Clock-gate sharing | open | one ICG for eight flops, not eight | `check-clockgate.sh` |
| Tool behaviour itself | **silent** | matrix re-measured, any cell change reported | `check-matrix-drift.py` |
| Documentation | **silent** | references, counts and rule coverage checked | `check-docs.sh` |
| Checker credit depth vs the credit loop | **silent** | a depth below the loop runs the channel below full bandwidth with no protocol violation (Q-43). A `DEPTH` one below the loop must trip `cfg_depth_covers_credit_loop`; full rate at the loop and not below it is proved (`check-formal.sh`) | `check-if.sh`, `check-formal.sh` |
| Checker timeout vs round trip | **silent** | `TIMEOUT_N=1` build must trip `cfg_timeout_covers_round_trip` | `check-if.sh` |
| Reference producer honours stall at every phase | **silent** | stall pulse swept across 28 phases; the old late-stall producer (`CCV_NEG_LATE_STALL`) must be caught | `check-if.sh` |
| Skeleton checker bank wiring (every slot) | **silent** | `--break phantom-all` / `stall-all`: all 163 checkers fire by name; `fixed-all`: all 90 fixed-latency ones | `check-skel.sh` |
| Atomic acceptance | **silent** | `--break atomic-all`: all 13 groups fire both properties; `--force-atomic` must stay clean | `check-skel.sh` |
| Ordered consumption (per key) | **silent** | `--break misorder` must be caught on exactly the ordered channels | `check-skel.sh` |
| Lane lockstep | **silent** | `--break lockstep-all`: one lane alone — both lockstep checkers fire, nothing else | `check-skel.sh` |
| Lane slot binding (same instruction per slot) | **silent** | `--break misbind`: lane 7 carries slot k+1's instruction in slot k, or its stream's next one on a one-slot channel — only `lockstep_id` fires | `check-skel.sh` |
| Slot attribute specification | **silent** | each rule in `gen-interfaces.py` rejects its bad case (checked once, by mutation) | `gen-interfaces.py` |
| Id class per channel | **silent** | `--break wrong-class`: all 41 channels report | `check-skel.sh` |
| Trace id kept out of synthesis | **silent** | Yosys asked both ways: no `ch_tid` without `CCV_TRACE`, present with | `check-skel.sh` |
| Skeleton slot count | **silent** | re-derived from the schema by code sharing nothing with the generator | `check-skel.sh` |
| Gate summary parsing | **silent** | keys matched whole; see below | `check-skel.sh` |
| Credit checker protocol properties | open | 13 cases: each violation trips *exactly* its property on Icarus and trips it first on Verilator; each legal extreme stays quiet | `check-if.sh` |
| S1 final state compared with ccv-sim | **silent** | a compare fed from the oracle instead of the machine would always pass. `--break corrupt-load` must change the final R9, and `--break drop-store` all 32 words of `c[]` | `check-kernel.sh` |
| S1 per-consumer checks against the oracle | **silent** | `--break corrupt-fetch` must be caught at DEC, and `corrupt-load` at the lane receiving the operand | `check-kernel.sh` |
| Response correlation by `req_id` | **silent** | FIFO order matches ids by coincidence while one request is outstanding. `--break corrupt-req-id` must be refused by MLC, not taken as the oldest | `check-kernel.sh` |
| Binding key (fet→dec `tier1_id`) | **silent** | `--break misgroup`: every message names the next group — only `binding_key` fires. The wiring controls force well-formed payloads so they trip only their own property | `check-skel.sh` |
| Outstanding limit (one ITLB miss) | **silent** | `--break itlb-double` must trip `within_limit` and nothing else. The checker's formal covers must be reachable, and they were not at first: see below | `check-kernel.sh`, `check-if.sh` |
| MIU's AGU on carried displacement and scale | **silent** | `--break corrupt-disp`: a displacement off by 4 must fail MIU's address check against ccv-sim | `check-kernel.sh` |
| Branch resolution (guard negate) | **silent** | the negate was not carried, and the check agreed with the stub because both read the un-negated predicate. `--break drop-negate` now must make RCU's resolution and FET's redirect both disagree with ccv-sim | `check-kernel.sh` |
| Stateless load write-back (MIU's echo) | **silent** | a wrong echo writes a load into the wrong register, and the final compare can miss it (the next load overwrites it, and ALU results come from the oracle). `--break corrupt-echo` must be rejected by C_ADD's lanes | `check-kernel.sh` |
| A predicate read as data (`sel`) | **silent** | the lane's result comes from the oracle, so a wrong selector would not show in the result. `--break drop-pred-data` on the sel kernel must be rejected by the lanes that choose `rs0` | `check-kernel.sh` |
| Where an op executes (Q-32, Q-38) | **silent** | a class table that put an op on the wrong side would still produce the right final state, since both sides compute the same answer. The lanes and RCU check every op against its record: a per-lane input or none. `--break movi-in-lane` must be refused by every lane for `movi` and `movi48`, and nothing else may fail |  `check-kernel.sh` |
| `srd`'s identity (OOE's shadow of RAU's table) | **silent** | every kernel but one runs CTA 0, where a missing or wrong `%ctaid` reads as right. The srd kernel runs CTA 7, and `--break corrupt-ctaid` must be rejected by the lanes computing `srd` | `check-kernel.sh` |
| DEC's selector range check | **silent** | an unallocated selector folded into the zero checks would have nothing to fail on. `--break srd-selector` must be named by the range check | `check-kernel.sh` |
| The lane mask one cycle ahead (lead fields, Q-40) | **silent** | the final state is the same whichever cycle the mask arrives in. The lane uses the mask it took off the wire in the valid cycle, so `--break late-lead`, which drives it with the operands instead, must make every lane reject a stale mask | `check-kernel.sh` |
| Disjoint footprints on the nine issue slots (V-60, TI-9) | **silent** | the stubs execute each op whole, so two ops granted one section still give every kernel its final state. `--break no-resource-cap` makes OOE's select grant a second lane op and a second memop onto resources already held (`inject_double_grant`); RCU must refuse each of the 12 shared slots | `check-kernel.sh` |
| A register fits its row at its position (OI-29, TI-9) | **silent** | every S1 register is 32-bit at position 0, so a wrong position changes no value. `--break bad-pos` names a 32-bit destination at position 1; RCU and all 32 lanes must refuse it | `check-kernel.sh` |
| A memop's pipe footprint (OI-33, TI-9) | **silent** | MIU serves each memop whole whatever `pipes` says. `--break narrow-pipes` gives every 32-bit memop one pipe; MIU must refuse all eight of vadd's | `check-kernel.sh` |
| Channel rates tied to the parameters deriving them (TI-9) | **silent** | every tool reads a channel's literal rate, so a parameter that grows (a pipe, a latency class) would leave the channel narrow and nothing would fail. `gen-interfaces.py --selftest` sets each tied rate one off and must see it refused by name | `verify.sh` |
| A masked-off lane does nothing, and RCU relies on it | **silent** | a lane result from the oracle is right on every lane, so writing back a masked-off lane was invisible. A masked-off lane now drives poison, and `--break ignore-mask` (RCU writes every lane) must put it into pguard's P1 | `check-kernel.sh` |
| Guard and predicate destination as separate fields | **silent** | with guard = destination (every S1 kernel before pguard) one field serves both and nothing can tell. `--break conflate-pred` on the pguard kernel must make the next guard wrong at the lanes, and both predicates wrong at the end | `check-kernel.sh` |
| The wake contract (Q-33) | **silent** | no stub sleeps, so in the skeleton and the SV top every wake checker holds without being exercised -- exactly the shape of a vacuous pass. Its own testbench must make `wake_t3` fire and `wake_t4` stay quiet, with six more cases around the reading of "gated", and `rx_early` must trip only the receiver's half, on both simulators | `check-if.sh` |
| Cross-hop field ownership (Q-34) | open | a per-channel width override of a non-per-hop field was introduced once by hand (`opcode` on `ooe_rcu_issue`) and refused | `gen-interfaces.py` |
| Yosys elaboration of struct-typed ports | **silent** | Yosys 0.33 elaborates a packed array of packed structs at a port into a different circuit, with warnings only, while both simulators are right. The wiring check refuses the telltale warnings (`Resizing cell port`, `is implicitly declared`); proven once by adding an implicit net to a stub, which it refused by name. CCV-L26 refuses the construct, with a fixture | `check-top.sh`, `check-1d.sh` |
| Open-items register consistency | open | a hole in the numbering, a summary that disagrees with the rows, a schema question pointing at the wrong or a closed row, and an undefined Q-n were each introduced once by hand and each failed | `check-docs.sh` |
| Encode/decode round trip coverage (compiler repo) | **silent** | 85 instructions were "unbuildable" and skipped while the check printed clean (compiler F-144). Any unbuildable instruction now fails it | `ccv-roundtrip` |
| Top level holds only block instances and nets | open | a check that isn't looking passes any top. Five impure copies, each refused for the rule it breaks: the top-level clock gate the top used to have, a tied reset, a top-level flop, a floating input, an unloaded output. A floating input got through once, because Yosys drops an unconnected port from the cell's connections, so ports are checked against the module's own list | `check-top.sh` (`check-top-pure.py`) |
| Formal known-assumptions (`$isunknown` under Yosys) | **silent** | Yosys reads `$isunknown(s)` as "`s` equals 0", so `CCV_ASSUME_KNOWN` pinned inputs to all ones and any proof over them explored a sender whose valid never fell (F-20). The known-macros are now constant true under formal; the link proofs carry no known-assumption, and their witnesses show traffic flowing and buffers filling | `check-formal.sh` |
| Formal link proofs | **silent** | a proof passes over an assumption set too narrow to reach the states it is about. Every proof has a mutant that must be refuted, and two witnesses must be reachable under the proofs' own assumptions. The first version's fairness assumption made a full buffer unreachable, which one witness caught | `check-formal.sh` |
| End-of-test quiescence | **silent** | a message never credited back outlives a run that ends first. `quiesced_at_end` (the credit checker, `+ccv_eot_quiesce` on drained runs) must fire on `--break double-pop`, independently of the C++ leak count | `check-skel.sh` |
| Hard reuse | **silent** | a template set that isn't minimal, or an instance with a parameter override, still simulates and synthesises, and only the hard macros multiply. R6 on the netlist refuses a duplicated template and a parameterised lane | `check-top.sh` |
| S0 credit conservation | **silent** | a keyed exerciser receiver popped one slot twice in a cycle, returning one credit for two messages, 7 to 10 times a run, and the gate was clean: the orphan only ages out on an idle slot, and the drain ended first. Found when a repeated link's deeper queues starved a slot. Receivers now count double pops (`credit_leaks`, required 0 in S0 and every kernel), and S0 requires every sender's credits home after the drain | `check-skel.sh`, `check-kernel.sh` |
| params/links.json validation | open | a validator that accepts a bad file builds a machine nobody specified. Eleven malformed configurations, each refused with its reason named | `check-links.sh` |
| Repeated links, both hosts | **silent** | the C++ link model and the SV repeaters are separate implementations of the same latency. A busy split must run cycle for cycle the same in both, and the wiring trace must count each link's stages flop by flop | `check-links.sh` |
| Repeater payload enabled by valid | **silent** | a payload register that loads every cycle carries the same data, so every simulation passes and only power differs. `check-rpt-enables.py` reads the enables off the Yosys netlist, and the free-running mutant is required to simulate clean and be refused there | `check-phys.sh` |
| Stall rule along a repeated link | open | a checker told the wrong distance from the sender either fires on legal in-flight valids or excuses late ones. The receiver-end checker told it sits at the sender must fire `stall_honoured`, and only there | `check-phys.sh` |
| SV-hosted C++ == C++-hosted | **silent** | a comparison too coarse to see a block running a cycle late would call two different machines the same. `+ccv_shim_delay` puts one block's outputs a cycle late, with every port still legal: DEC late differs in 223 cycles, one lane in 173. A skew on a block the kernel never uses is invisible, so the controls target blocks on its path. Also: every shim must register (`SVHOST shims=46/46`), since a stub left in the file list would idle quietly | `check-sv-hosted.sh` |
| Oracle records from the pinned compiler snapshot | **silent** | a snapshot that isn't what the lock says would feed the skeleton a different machine's answers, and every kernel would still agree with them. `tools/fetch-compiler.sh` uses a snapshot only if it names the lock's source commit and its `ccv-sim` matches the sha256 in its own manifest; a binary altered by one byte was refused once, by name. A fetch that fails fails the gate rather than skipping. When the records stopped being checked in, the live ones were byte-identical to the four they replaced | `check-kernel.sh` |
| ccv-sim `-oracle` memory flags | **silent** | the record reported `"load":0` beside 32 reads (compiler F-141). It now refuses a step whose traffic the descriptor does not declare; checked once by dropping `LD_GLOBAL`'s flag | compiler repo |
| The simulation view of a ctech cell reaching synthesis | **silent** | a behavioural latch-and-AND synthesises, works in every simulation, and gives up the library ICG's clock-gating checks. Under `SYNTHESIS` the view instantiates `ccv_ctech_sim_view_in_synthesis`, which does not exist; synthesising `ccv_common_clk` with it must fail naming that module, and with each library view must give exactly one library ICG and no latch | `check-ctech.sh` |
| A clock gate that glitches | **silent** | an AND of clock and enable passes every RTL simulation whose enable only moves at edges. The testbench moves `en` in either phase and requires every gclk edge at a clk edge; the formal model lets every input move at any step. An ICG with no latch, and one latched in the high phase, must fail both, on both simulators. The first formal model could not fail them at all (F-21) | `check-ctech.sh`, `check-formal.sh` |
| `clk_gated`, the bank's view of each receiver's gate | **silent** | a tie reads as a receiver that never sleeps, so every wake checker holds without being exercised. R7 requires each block's `clk_gated` to be its `ccv_common_clk`'s own `gated`; `gatetie` (tied) and `gateclk` (gate off `core_clk`) must be refused | `check-top.sh` |
| The wake contract's receiver half | **silent** | the checker's reading of Q-33 excused a receiver that slept again before `LAT`, and charged the sender. A clock gate holding open one cycle too few passed the Q-33 proof. `wake_keeps_rx` now states it: `rx_early` must trip only it, and the one-short hold mutant must fail it | `check-if.sh`, `check-formal.sh` |

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

`ccv_common_chk_outstanding` was first written, like the credit checker, with
`CCV_ASSUME_KNOWN` on its two inputs to satisfy CCV-L08. Its formal harness
drives those inputs from a register. With the two assumptions in place,
**every cover in the harness was unreachable**, including a plain
`cover(req)` added as a probe. The assumption set admitted no trace at all,
so any assertion proved against it would have passed having checked nothing.
The mandatory satisfiability covers (§3.3) are what reported it. The
counter now selects with ternaries, CCV-L08's other sanctioned form, and all
covers are reached. **Root cause, isolated 2026-09-26 (F-20):** Yosys reads
`$isunknown(s)` as "`s` equals 0", so the known-assumption pinned each input
to all ones, which a register driven from reset can never hold. The
known-macros are now constant true under formal, and the formal link proofs
carry no such assumption.

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
two-state, so `payload_known_when_due` and `lead_known_at_valid` *cannot*
fire there — an X is already a 0 or a 1 by the time anything looks. Icarus is the only witness for that
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
