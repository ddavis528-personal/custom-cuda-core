#!/usr/bin/env python3
"""Assemble docs/walkthrough.md: one kernel through the Stage 3 machine.

    tools/gen-walkthrough.py            write docs/walkthrough.md
    tools/gen-walkthrough.py --check    fail if it differs from a fresh build

Every listing in the walkthrough is produced here, from the repository and
from runs of the binaries the gate builds (build/skel/ccv-skel, the SV-hosted
build/svh_vo/ccv-svh, the oracle records from the pinned compiler snapshot).
Nothing in it is transcribed. The prose is written here too, and where it
names a thing -- a property, a checker, a file -- the name is checked against
the source it comes from, so the prose cannot drift from the design either.

Needs the gate's build products: run tools/verify.sh (or at least
check-skel, check-kernel and check-sv-hosted) first. verify.sh runs --check
after those sections.
"""
import collections
import importlib.util
import json
import os
import re
import subprocess
import sys
import tempfile

ROOT = os.path.dirname(os.path.dirname(os.path.abspath(__file__)))
DOC = os.path.join(ROOT, "docs", "walkthrough.md")
SKEL = os.path.join(ROOT, "build", "skel", "ccv-skel")
SVH = os.path.join(ROOT, "build", "svh_vo", "ccv-svh")
ORACLE = os.path.join(ROOT, "build", "oracle", "vadd", "oracle.jsonl")
LOAD_SEQ = 12      # vadd's LD_GLOBAL_IDX a[i]
ADD_SEQ = 14       # vadd's C_ADD


class Missing(Exception):
    pass


def rd(*p):
    with open(os.path.join(ROOT, *p)) as f:
        return f.read()


def run(*args):
    r = subprocess.run(args, cwd=ROOT, capture_output=True, text=True)
    return r.stdout + r.stderr


def lines_between(text, start, stop, keep_stop=True):
    """The lines from the first matching `start` through the first `stop`."""
    out, on = [], False
    for l in text.splitlines():
        if not on and re.search(start, l):
            on = True
        if on:
            if re.search(stop, l) and out:
                if keep_stop:
                    out.append(l)
                break
            out.append(l)
    if not out:
        raise Missing("no block matching %r" % start)
    return "\n".join(out)


def need(cond, what):
    if not cond:
        raise Missing(what)


def labels_in(path):
    """Assertion labels a harness or checker defines: `name: assert`, and the
    names the CCV contract macros take."""
    t = rd(path)
    got = set(re.findall(r"\b([a-z_0-9]+)\s*:\s*assert\b", t))
    got |= set(re.findall(r"`CCV_CONTRACT_M\(\s*\w+\s*,\s*([a-z_0-9]+)", t))
    got |= set(re.findall(r"`CCV_ASSERT\(\s*([a-z_0-9]+)", t))
    return got


def load_t2p():
    spec = importlib.util.spec_from_file_location(
        "t2p", os.path.join(ROOT, "tools", "trace2perfetto.py"))
    m = importlib.util.module_from_spec(spec)
    spec.loader.exec_module(m)
    return m


def field(line, key):
    m = re.search(r"(?:^| )%s=(\S+)" % re.escape(key), line)
    return m.group(1) if m else None


def build():
    for p, what in ((SKEL, "build/skel/ccv-skel (tools/check-skel.sh)"),
                    (ORACLE, "the vadd oracle (tools/check-kernel.sh)"),
                    (SVH, "build/svh_vo/ccv-svh (tools/check-sv-hosted.sh)")):
        need(os.path.exists(p), "no %s -- run the gate first" % what)

    iface = json.loads(rd("schema", "interfaces.json"))
    chans = iface["channels"]
    chan = {c["name"]: c for c in chans}
    chan_by_id = {i: c for i, c in enumerate(chans)}
    lock = dict(l.split("=", 1) for l in rd("tools", "compiler.lock").splitlines()
                if "=" in l and not l.startswith("#"))
    snap = os.path.join(ROOT, "build", "compiler", lock["commit"])
    need(os.path.isdir(snap), "no compiler snapshot at build/compiler/%s" % lock["commit"][:7])
    cfg = rd("test", "kernels", "vadd", "kernel.cfg")
    src_rel = re.search(r"^SOURCE=(\S+)", cfg, re.M).group(1)
    asm = open(os.path.join(snap, src_rel)).read().rstrip()

    oracle = [json.loads(l) for l in open(ORACLE)]
    instrs = [r for r in oracle if "seq" in r]

    tmp = tempfile.mkdtemp()
    tr_cpp = os.path.join(tmp, "cpp.ccvtrace")
    tr_sv = os.path.join(tmp, "sv.ccvtrace")
    run_cpp = run(SKEL, "--kernel", ORACLE, "--trace", tr_cpp)
    run_sv = run(SVH, "+ccv_oracle=" + ORACLE, "+ccv_trace=" + tr_sv)
    kline = next(l for l in run_cpp.splitlines() if l.startswith("KERNEL "))
    xline = next(l for l in run_cpp.splitlines() if l.startswith("XFER "))
    uline = next(l for l in run_cpp.splitlines() if l.startswith("UNUSED "))
    kline_sv = next(l for l in run_sv.splitlines() if l.startswith("KERNEL "))
    shost = next(l for l in run_sv.splitlines() if l.startswith("SVHOST "))
    cmp_tr = run("python3", "tools/compare-traces.py", tr_cpp, tr_sv).splitlines()[0]
    s0 = run(SKEL)
    s0line = next(l for l in s0.splitlines() if l.startswith("SKEL "))
    dp = run(SKEL, "--break", "double-pop")
    dpline = next(l for l in dp.splitlines() if l.startswith("SKEL "))
    dperr = [l for l in dp.splitlines() if "quiesced_at_end failed" in l]
    need(dperr, "--break double-pop did not trip quiesced_at_end")
    need(field(kline, "violations") == "0" and field(kline, "finished") == "1",
         "vadd did not run clean: " + kline)
    need(kline == kline_sv, "SV-hosted KERNEL line differs")
    need("equal=yes" in cmp_tr, "SV-hosted trace differs: " + cmp_tr)

    # -- the trace: one load and one add, instruction by instruction --------
    t2p = load_t2p()
    schema = t2p.load_schema()
    ev = {e["id"]: e for e in schema["events"]}
    units = {v: k for k, v in schema["units"].items() if not k.startswith("_")}
    uf = schema["uid_layout"]["fields"]
    cls = schema["uid_layout"]["classes"]

    def uget(u, k):
        return (u >> uf[k]["lsb"]) & ((1 << uf[k]["width"]) - 1)

    _, recs = t2p.read_trace(tr_cpp)

    def journey(seq):
        rows = collections.OrderedDict()
        for cyc, uid, eid, unit, a, b, c in recs:
            k = uget(uid, "class")
            if uget(uid, "seq") != seq or not (
                    k == cls["instr"] or (k == cls["txn"] and uget(uid, "owned"))):
                continue
            name = ev[eid]["name"]
            if name == "EV_CH_XFER":
                ch = chan_by_id[a]
                key = (cyc, ch["name"])
                what = (ch["name"], ch["src"], ch["dst"], "txn" if k == cls["txn"] else "instr")
            else:
                key = (cyc, name)
                what = (name, units.get(unit, "?"), b, None)
            if key in rows:
                rows[key][1] += 1
            else:
                rows[key] = [what, 1]
        return [(cyc, w, n) for (cyc, _), (w, n) in rows.items()]

    def render(j):
        out = ["  cycle  event / channel                src  -> dst    msgs"]
        out.append("  " + "-" * 60)
        for cyc, w, n in j:
            if w[0].startswith("EV_"):
                out.append("  %5d  %-30s %-13s" % (cyc, w[0], w[1].replace("UNIT_", "").lower()))
            else:
                ext = lambda b: "ext" if b == "EXTERNAL" else b
                out.append("  %5d  %-30s %-4s -> %-5s %4s" % (
                    cyc, w[0], ext(w[1]), ext(w[2]),
                    ("x%d" % n) if n > 1 else ""))
        return "\n".join(out)

    jl = journey(LOAD_SEQ)
    ja = journey(ADD_SEQ)
    need(jl and ja, "no trace records for seq %d/%d" % (LOAD_SEQ, ADD_SEQ))
    cyc_of = lambda j, name: next(c for c, w, n in j if w[0] == name)
    l_fetch = cyc_of(jl, "ccv_fet_dec_instr")
    l_disp = cyc_of(jl, "EV_DISPATCH")
    l_issue = cyc_of(jl, "EV_ISSUE")
    l_out = cyc_of(jl, "ccv_exb_ext_out")
    l_in = cyc_of(jl, "ccv_ext_exb_in")
    l_ret = cyc_of(jl, "EV_RETIRE")
    a_ops = next(n for c, w, n in ja if w[0] == "ccv_rcu_lane_ops")
    a_res = next(n for c, w, n in ja if w[0] == "ccv_lane_rcu_res")
    a_ret = cyc_of(ja, "EV_RETIRE")
    beats = sum(n for c, w, n in jl if w[0] == "ccv_ext_exb_in")
    a_dt = cyc_of(ja, "ccv_lane_rcu_res") - cyc_of(ja, "ccv_rcu_lane_ops")
    n_thr = int(re.search(r"^0x20004=(\d+)", cfg, re.M).group(1))
    guard = next(r for r in instrs if r["kind"] == "branchpred")
    need(not guard["taken"], "vadd's guard is taken")
    earlier_mem = [r["seq"] for r in instrs if r["seq"] < LOAD_SEQ and (r["load"] or r["store"])]
    need(instrs[LOAD_SEQ]["op"] == "LD_GLOBAL_IDX" and instrs[ADD_SEQ]["op"] == "C_ADD",
         "vadd's instruction order moved: seq %d is %s, seq %d is %s"
         % (LOAD_SEQ, instrs[LOAD_SEQ]["op"], ADD_SEQ, instrs[ADD_SEQ]["op"]))

    otable = ["  seq   pc      op              kind        mem    lanes",
              "  " + "-" * 56]
    for r in instrs:
        otable.append("  %3d   0x%04x  %-15s %-11s %-6s %5d" % (
            r["seq"], r["pc"], r["op"], r["kind"],
            "load" if r["load"] else ("store" if r["store"] else ""),
            bin(r["mask"]).count("1")))

    # -- one parameter, three languages -------------------------------------
    pj = json.loads(rd("params", "ccv_params.json"))
    pd = next(p for p in pj["params"] if p["name"] == "CCV_CREDIT_DEPTH")
    sv_line = next(l.strip() for l in rd("rtl", "generated", "ccv_params_pkg.sv").splitlines()
                   if "CCV_CREDIT_DEPTH =" in l)
    cpp_line = next(l.strip() for l in rd("sim", "generated", "ccv_params.h").splitlines()
                    if re.search(r"\bkCreditDepth\b\s*=", l))
    pjson = json.dumps({k: pd[k] for k in ("name", "value", "status")}, indent=2)

    # -- one channel -------------------------------------------------------
    cm = chan["ccv_miu_dcu_req"]
    cjson = json.dumps({k: cm[k] for k in ("name", "src", "dst", "rate", "payload_fields")},
                       indent=2)
    typedef = lines_between(rd("rtl", "generated", "ccv_interfaces.svh"),
                            r"^typedef struct packed", r"\} ccv_miu_dcu_req_t;")
    typedef = "typedef struct packed" + typedef.split("typedef struct packed")[-1]
    ports = "\n".join(l for l in rd("rtl", "top", "ports", "ccv_dcu_ports.svh").splitlines()
                      if ("miu_dcu_req_s0_" in l or "miu_dcu_req_wake" in l)
                    and "_tid" not in l)
    chk = lines_between(rd("rtl", "generated", "ccv_skel_checkers.sv"),
                        r"ccv_credit_checker .* u_miu_dcu_req_s0 \(", r"^  \);")

    # -- the machine --------------------------------------------------------
    top = rd("rtl", "top", "ccv_core_top.sv")
    inst = re.findall(r"^  (ccv_(\w+?)_w(?:_v\d+)?) u_(\w+) \(", top, re.M)
    per = collections.Counter(t for _, t, _ in inst)
    ext_ch = sum(1 for c in chans if "EXTERNAL" in (c["src"], c["dst"]))
    bank = rd("rtl", "generated", "ccv_skel_checkers.sv")
    chk_counts = collections.Counter(re.findall(r"^\s+(ccv_\w+_checker)\b", bank, re.M))
    need(sum(per.values()) == int(field(s0line, "blocks")), "instance count disagrees with SKEL")

    wrap_inst = lines_between(top, r"^  ccv_dcu_w u_dcu \(", r"miu_dcu_req_s0_valid")
    wrap_blk = lines_between(rd("rtl", "top", "wrap", "ccv_dcu_w.sv"), r"^  ccv_dcu u_blk \(",
                             r"\.rst_n")
    wrap_rpt = lines_between(rd("rtl", "top", "wrap", "ccv_dcu_w.sv"),
                             r"u_rpt_miu_dcu_req \(", r"\.clk\(core_clk\)")
    gate = lines_between(rd("rtl", "top", "stubs", "ccv_dcu.sv"),
                         r"localparam int CG_HW", r"^`endif")
    en_line = next(l.strip() for l in rd("rtl", "clk", "ccv_clk_gate.sv").splitlines()
                   if re.search(r"wire\s+en\s*=", l))
    links = json.loads(rd("params", "links.json"))

    # -- names the prose uses, checked against where they are defined -------
    link_props = ["data_in_order", "no_overflow", "credit_per_msg", "conservation",
                  "full_bandwidth"]
    cg_props = ["glitch_high_only", "glitch_rise", "glitch_fall", "edge_decides", "spec",
                "wake_second_edge", "wake_hold", "q33_valid_meets_clock"]
    have = labels_in("test/formal/fv_link.sv")
    for p in link_props:
        need(p in have, "fv_link.sv has no property %s" % p)
    have = labels_in("test/formal/fv_clk_gate.sv")
    for p in cg_props:
        need(p in have, "fv_clk_gate.sv has no property %s" % p)
    need("wake_keeps_rx" in labels_in("rtl/if/ccv_wake_checker.sv"), "no wake_keeps_rx")
    need("quiesced_at_end" in rd("rtl", "if", "ccv_credit_checker.sv"), "no quiesced_at_end")

    sections = re.findall(r'^section "([^"]+)"', rd("tools", "verify.sh"), re.M)
    oi = rd("docs", "open-items.md")
    oi_open = re.search(r"^- \*\*Open:\*\* (.*)$", oi, re.M).group(1)
    oi_sched = re.search(r"^- \*\*Scheduled:\*\* (.*)$", oi, re.M).group(1)
    nrules = len(set(re.findall(r'(?:add|Finding)\("(CCV-L\d+)"', rd("tools", "lint-rtl.py"))))
    views = sorted(d for d in os.listdir(os.path.join(ROOT, "rtl", "ctech"))
                   if os.path.isdir(os.path.join(ROOT, "rtl", "ctech", d)))

    blocks_tbl = ["| Block | Instances | Block | Instances |", "|---|---|---|---|"]
    items = sorted(per.items())
    half = (len(items) + 1) // 2
    for i in range(half):
        a = items[i]
        b = items[i + half] if i + half < len(items) else ("", "")
        blocks_tbl.append("| `%s` | %s | %s | %s |" % (
            a[0], a[1], ("`%s`" % b[0]) if b[0] else "", b[1]))
    chk_tbl = ["| Checker | In the bank | Judges |", "|---|---|---|"]
    judges = {
        "ccv_credit_checker": "one slot: credit, stall, payload known when due, bounded response, at the end nothing left uncredited, and on a fixed-latency channel no stall and every credit on landing",
        "ccv_wake_checker": "one channel instance: wake leads valid toward a gated receiver (sender), the receiver runs `CCV_WAKE_LAT` after a wake (receiver)",
        "ccv_atomic_checker": "a channel's slots that must move together",
        "ccv_lockstep_checker": "copies of a channel that must move in lockstep across the 32 lanes",
        "ccv_binding_checker": "a slot's group key stays bound",
        "ccv_outstanding_checker": "request / response pairs across two channels",
    }
    for k in sorted(chk_counts, key=lambda k: -chk_counts[k]):
        chk_tbl.append("| `%s` | %d | %s |" % (k, chk_counts[k], judges.get(k, "")))

    lock_short = lock["commit"][:7]
    src_short = lock["source"][:7]

    doc = f"""# Walkthrough — one kernel through the Stage 3 machine

What exists at the end of Stage 3, traced through one kernel that runs today.
Every listing is generated by `tools/gen-walkthrough.py`, from the repository
and from runs of the binaries the gate builds; nothing here is transcribed.
`tools/verify.sh` regenerates it and fails if this file is stale.

```
params/ + schema/ ──generators──▶ C++ skeleton (ccv-skel) ─┐
                                ▶ SV top, wrappers, stubs  │  same wiring,
                                ▶ checker bank ────────────┤  same run
compiler snapshot ──ccv-sim──▶ oracle record ─────────────▶ vadd on the machine
                                                           │
                                          event trace ◀────┘──▶ Perfetto
```

The core repository does not compile or architecturally simulate anything;
the compiler repository does both. What this one builds is the machine those
results have to come out of: 45 block instances joined by credited channels,
wired once from a schema, run in C++ and in SystemVerilog, and checked on
every message.

---

## 1. The kernel, from the compiler

`c[i] = a[i] + b[i]` for 32 threads. The core pins one compiler snapshot,
`tools/compiler.lock`: the `release` branch at `{lock_short}` (source
`{src_short}`). The kernel is that snapshot's own hand-scheduled listing,
{src_rel} in the compiler repository, and `test/kernels/vadd/kernel.cfg`
gives the launch block and memory it runs against.

```
{asm}
```

## 2. The oracle

The snapshot's built `ccv-sim` runs the kernel once and records every
instruction: its bytes, its lanes, every register it read and wrote, every
memory access (`tools/gen-oracle.sh`). The record is generated on each run of
the gate from the pinned snapshot; none of it is checked in.

```
{chr(10).join(otable)}
```

{len(instrs)} instructions, all 32 lanes on every one: `n` = {n_thr}, so the
guard at seq {guard['seq']} falls through. The machine must end with the same registers, predicates
and memory, and retire the same instructions in the same order.

## 3. One source for every number

Machine parameters live in `params/ccv_params.json`, and `tools/gen-params.py`
writes them into both languages. The credit depth, which is Q-43's full
bandwidth decision:

```json
{pjson}
```

```systemverilog
{sv_line}
```

```cpp
{cpp_line}
```

The status decides which package a value lands in: `arch` and `isa` values in
`ccv_params_pkg`, `tunable` and `provisional` ones in `ccv_prov_pkg`, and
undecided encodings in `ccv_prelim_pkg`. A module that uses a placeholder
names the placeholder's package at the use site, and `docs/trust-report.md`
lists every such module.

## 4. The partition

{len(per)} block types, {sum(per.values())} instances, {len(chans)} channel types
({ext_ch} of them to and from the testbench's `EXTERNAL`). Every channel is
point to point, credited, and declared in `schema/interfaces.json`, which is
the only place a channel is defined.

{chr(10).join(blocks_tbl)}

The C++ skeleton's plumbing run, S0, sends random traffic on every slot of
every channel for 2000 cycles, through the same wiring and the same checker
bank:

```
{s0line}
```

## 5. One channel, from the schema down

`ccv_miu_dcu_req`, the MIU's cache request to the DCU, rate {cm['rate']}: {cm['rate']}
independent slots, each its own credited link.

```json
{cjson}
```

`tools/gen-interfaces.py` turns the payload into a packed struct. Each width
comes from the parameter package of its tier:

```systemverilog
{typedef}
```

and `tools/gen-top.py` into ports on both ends. The DCU's side of slot 0, and
the channel instance's one `_wake`:

```systemverilog
{ports}
```

Valid leads the payload by one cycle; credit and stall run backwards. A
message costs one credit, and the credit comes back when the receiver
consumes it. At abutment the loop takes 4 cycles: the valid, the payload
landing, the credit registered, and the credit usable again. A depth of
`CCV_CREDIT_DEPTH` = {pd['value']} therefore sends one message per cycle,
every cycle, on every slot, and 3 would not. That is proved, not assumed
(section 10).

## 6. vadd on the machine

`ccv-skel --kernel` runs the oracle's kernel on the S1 functional stubs:
behavioural C++ blocks, one per block type, that move real values over the
real channels. It then compares the final state with the oracle's.

```
{kline}
{xline}
```

Retired in order, every register, predicate and memory word equal to
`ccv-sim`'s, and every one of the {field(xline, 'launched')} messages
launched was seen by the checker bank, which reported nothing. The run
touches {field(kline, 'channels_used')} channel types. The rest are waiting for
kernels that need them:

```
{uline}
```

## 7. One instruction through the machine

The run's event trace carries a trace identity on every message, so one
instruction can be followed across every block it touches. Seq {LOAD_SEQ},
`{instrs[LOAD_SEQ]['op']}`, the load of `a[i]`:

```
{render(jl)}
```

- **Fetch to dispatch in {l_disp - l_fetch} cycles:** FET to DEC to OOE, one
  channel hop each.
- **Dispatched at {l_disp}, issued at {l_issue}.** The S1 OOE issues in order
  and lets one memory operation be in flight at a time. The loads ahead of
  this one (seq {', '.join(str(s) for s in earlier_mem)}) each make the whole
  trip first.
- **Issue:** OOE sends the operation to RCU, which reads the index register,
  and to MIU, which gets the address from RCU.
- **Memory:** MIU to DCU to MLC to EXB, and out to the testbench's memory at
  {l_out}. The data comes back at {l_in}, in {beats} beats, and returns the
  same way.
- **Completion:** MIU delivers the data to RCU and completion to OOE, and
  the instruction retires at {l_ret}, {l_ret - l_fetch} cycles after fetch.

Seq {ADD_SEQ}, `{instrs[ADD_SEQ]['op']}`, the add, is the other shape of
traffic: the lanes. RCU sends {a_ops} lane operations, one per lane instance,
in the same cycle, and gets {a_res} results back {a_dt} cycles later:

```
{render(ja)}
```

The trace converts to Perfetto (`tools/trace2perfetto.py`), with a track per
structure or a process per instruction.

## 8. The same run in SystemVerilog

The top level is generated too: `rtl/top/ccv_core_top.sv`. It holds one
hardening wrapper per block instance and the nets between them, and nothing
else. There is no gate, flop or tie-off at the top (`check-top-pure.py`). The
DCU's wrapper, as the top instantiates it:

```systemverilog
{wrap_inst}
    ...
```

Inside it, the block, and one sequential repeater per channel end. Each
repeater is at 0 stages, plain wires, until `params/links.json` says
otherwise:

```systemverilog
{wrap_blk}
    ...
{wrap_rpt}
    ...
```

The design's `params/links.json` repeats nothing yet (`"links": []`), and
`"hard_reuse": {json.dumps(links.get('hard_reuse', []))}` keeps every lane on
one wrapper template. `test/phys/links_split.json` is a busy split the gate
builds anyway: links repeated at both ends, feedthroughs, and lockstep lanes.

Every block is a stub today, and every stub already has its clock gate, tied
open:

```systemverilog
{gate}
```

The gate's enable reads only flops of its own block. The wake is registered
first (Q-49):

```systemverilog
{en_line}
```

The same top can be built with the C++ blocks inside it: `rtl/top/dpi/` holds
one DPI-C shim per block type, with the same module name and ports as the
stub. That is the machine in Verilog, with every block's behaviour the C++
skeleton's:

```
{shost}
{kline_sv}
{cmp_tr}
```

The same KERNEL line, and the same event trace, record for record. Swapping a
block to RTL at Stage 4 is a file-list change inside a machine already shown
to be the same one.

## 9. Every message checked

The checker bank (`rtl/generated/ccv_skel_checkers.sv`) is generated from the
schema and Verilated into the C++ skeleton. The same module sits beside the
SV top under `CCV_CHECK`.

{chr(10).join(chk_tbl)}

One of them: slot 0 of the channel from section 5.

```systemverilog
{chk}
```

A checker that has never fired proves nothing, so each mechanism has a
control that must trip it (`docs/fail-open-register.md`). The one that
matters most here is a receiver that consumes two messages and returns one
credit. It was a real bug, found in dynamic simulation. It is proved against
now (section 10), and caught in simulation by the checker's end-of-test
check:

```
{dperr[0].strip()}
{dpline}
```

The C++ receivers count the same leak from their side:
`credit_leaks={field(dpline, 'credit_leaks')}`, and only
{field(dpline, 'credits_home')} of {field(dpline, 'slots')} slots have all
their credits home at the end.

## 10. Proved, for all time

`tools/check-formal.sh` proves the protocol by PDR (ABC), unbounded, not over
a window.

**One credited link** (`test/formal/fv_link.sv`): a sender, a receiver, N = 0,
1, 2 repeater stages, and the credit checker at both ends.
- **Safety, with no assumption at all:** `{link_props[0]}`, `{link_props[1]}`,
  `{link_props[2]}` and `{link_props[3]}`, plus every property of the
  checker.
- **`{link_props[4]}`:** a launch every cycle at the credit-loop depth, with
  a counterexample at one entry less.
- **Mutants:** the double-pop receiver, and repeaters with their enables
  wrong, must each be refuted.

**The block clock gate** (`test/formal/fv_clk_gate.sv`), on the multiclock
model, where the clock is an input and the ICG's latch switches as it does:
- **A clean gated clock**, whatever the inputs do: `{cg_props[0]}`,
  `{cg_props[1]}`, `{cg_props[2]}`.
- **The cycle behaviour** against an independent model: `{cg_props[3]}`,
  `{cg_props[4]}`, `{cg_props[5]}`, `{cg_props[6]}`.
- **Both halves of the wake contract,** with `ccv_wake_checker`:
  `wake_keeps_rx` and `{cg_props[7]}`.

The gate itself is the ctech ICG `ccv_ctech_icg`, one module with a view per
use. The views are {', '.join('`%s`' % v for v in views)}: behavioural for
simulation and formal, and one per process library, each nothing but that
library's cell (`docs/clock-gate.md`).

## 11. The gate

`tools/verify.sh` runs everything above on every change. Anything that can be
a script is one. Its sections:

{chr(10).join('- ' + s for s in sections if s not in ('pending stages', 'result'))}

It includes {nrules} lint rules (`tools/lint-rtl.py`). Each has a
counter-example that must fire, and a paragraph in
`docs/rtl-coding-style.md`.

## 12. What Stage 3 leaves open

From `docs/open-items.md`, which numbers every open item and never reuses an
ID:

- **Open:** {oi_open}
- **Scheduled:** {oi_sched}

Stage 4 replaces the stubs, block by block, with RTL written against the
ports, the checkers and the clock gate already in place.
"""
    return doc


def main():
    check = "--check" in sys.argv
    try:
        doc = build()
    except Missing as e:
        print("gen-walkthrough: %s" % e, file=sys.stderr)
        return 1
    if check:
        cur = open(DOC).read() if os.path.exists(DOC) else ""
        if cur != doc:
            print("docs/walkthrough.md is stale: run tools/gen-walkthrough.py",
                  file=sys.stderr)
            return 1
        print("  walkthrough current")
        return 0
    with open(DOC, "w") as f:
        f.write(doc)
    print("  wrote docs/walkthrough.md")
    return 0


if __name__ == "__main__":
    sys.exit(main())
