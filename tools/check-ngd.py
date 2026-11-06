#!/usr/bin/env python3
"""check-ngd: logic depth against the stage and its port budgets.

Daniel, 2026-10-17 (docs/rtl-coding-style.md, "Logic depth"):

  STAGE  CCV_NGD_BUDGET = 25 NGD of combinational logic between two flops.
         The flop itself is outside it: every depth here is measured with
         the flops cut out.
  PORTS  A module is measured alone, so a path that leaves it is cut at the
         port. Each side of a port has a budget, by default CCV_NGD_PORT =
         12 NGD: an output is required within 12 of its module's flops, and
         an input arrives at 25 - 12 = 13 and must reach its module's flops
         within the rest. Two defaults meet within the stage, so nobody need
         plan a port that fits them. A port over 12 needs explicit budgets
         from the architect, kept beside the module's RTL in
         <module>.ngd.json, one consistent format for every module.
  THRU   No module has a path from an input port to an output port, not
         even a wire (Daniel, 2026-10-18): a wire is connected directly
         instead, and logic is grouped with one sequential side. So every
         flop-to-flop path between modules crosses exactly one port, two
         segments, and budgets are pairwise. In a parent, a path that
         touches none of its own flops carries no logic either: wired child
         to child is the parent's connection. An inner helper (a
         combinational module timed only inside its parent, declared in its
         budget file) is exempt, and its logic counts as its parent's; while
         no module instantiates it, it is held alone to CCV_NGD_INNER =
         floor(2 * 25 / 3) = 16 NGD input to output, not the whole stage, as
         its parent's logic will share the stage with it (Daniel,
         2026-10-19); a
         checker-only observation port is exempt; and a channel the
         generated hardening wrappers carry across themselves, the one
         feedthrough allowed (rtl/top/, never a unit here).
  SHARED A register that drives an output is held, on every path it starts,
         to the flops inside as to any output, within that output's
         required time (Daniel, 2026-10-19): a flop on a critical path out
         and on one in is pulled two ways at placement. The remedy is a copy,
         one for the output and one for the rest, each declared (* keep *)
         so synthesis keeps both, here as in a real flow.
  BLOCK  Once a block top is RTL, the assembled block is checked as a sum
         of parts from module-level runs (Daniel, 2026-11-06): a final
         synthesis of a whole block is infeasible within the gate's runtime
         and memory, so nothing above a module is synthesised, and no child
         with its parent. Its hierarchy is read structurally (Yosys's front
         end, hierarchy and proc; leaves' files read -lib), and (block_check):
         every instance is measured by a unit at the instance's parameters
         (coverage), so each module's own paths are held to the stage and
         its ports to its budgets; each level of the hierarchy is timed
         alone, its children black boxes at their budgets, so every
         connection, and any glue between children, must converge (a
         driver's required time no later than its receiver's arrival, glue
         included), which with THRU bounds every flop-to-flop path across
         modules; and its boundary is registered on both sides with nothing
         between: every output straight from a flop, every input straight
         into one, by its parts -- at each level a boundary port meets the
         level's own flop with no logic between or reaches a child's pin by
         a wire only, and that pin is held the same way, down to a leaf,
         whose unit's measurement at the instance's parameters must show it
         straight from or into a flop (the measurement, not the leaf's
         budget, which is a bound the architect may set above 0). A
         crossing carries no logic (AR's rev 285 (5)): the boundary flops are
         the interface module's, built in the block's hardening wrapper
         (rtl/phys/ccv_common_rpt.sv BOUNDARY; Daniel, 2026-11-05), so the
         block's paths run from them within the stage; a no-flop end
         (params/links.json no_flop) is the block's own register at 0 NGD,
         which this holds at the wrapper. The 12-a-side port budget stays
         only between modules inside a block.
         What the parts cannot see, which the flattened pass did: synthesis
         across a boundary (a constant, an unused output, a register
         duplicated or merged, two halves of a function mapping shallower
         together), which leaves the parts conservative; and one net's
         loads as a whole. Each level times its wires with the fanout term
         for the pins on the parent's net, a child's unit for its loads
         inside the child, so a net split across the two is two trees where
         the whole would be one: short of it by one INV stage at most.

Each module is measured at the parameters of its units (test/**/cg-units.json,
and test/**/ngd-units.json for modules with no flops): Yosys synthesises it
flattened, every clock-gated flop becomes a plain flop on its next value (its
enable is timed apart, to its ICG, by check-cg's CG-2), and ABC maps it onto
tools/ngd.genlib, as test/ooe/depth.sh does. A timing pass over the mapped
netlist then splits the depth by where a path starts and ends: input or flop,
output or flop, each gate at the delay of the pin the path enters by (the XOR
family's pins differ). Its longest path must equal ABC's own, or the run stops.

The rules, as findings:
  NGD-1  flop to flop over the stage
  NGD-2  an output reached later than its required time (from flops, or from
         an input at its arrival)
  NGD-3  an input that, from its arrival, reaches a flop over the stage
  NGD-4  a budget file that is malformed, or names a port its module lacks
  NGD-5  a path straight through a module, wire or logic, or, in a parent,
         logic on a path that touches none of its own flops
  NGD-6  an inner helper that no module instantiates yet, input to output
         over CCV_NGD_INNER
  NGD-7  a register that drives an output, on any path it starts, to a flop
         or to any output, over that output's required time (the strictest
         of those it drives)

Modules that broke a default when the rule was made sit on
rtl/ngd-ratchet.json, awaiting budgets from OA or a redesign; the list only
shrinks.

  tools/check-ngd.py              every unit, the ratchet and the blocks
  tools/check-ngd.py --unit NAME  one unit, with its ports
  tools/check-ngd.py --selftest   the negative controls
"""
import argparse
import collections
import copy
import glob
import importlib.util
import json
import math
import os
import re
import subprocess
import sys

ROOT = os.path.dirname(os.path.dirname(os.path.abspath(__file__)))
BUILD = os.path.join(ROOT, "build", "ngd")
FIX = "test/ngd/fixtures"

_spec = importlib.util.spec_from_file_location("check_cg",
                                              os.path.join(ROOT, "tools", "check-cg.py"))
cg = importlib.util.module_from_spec(_spec)
_spec.loader.exec_module(cg)          # puts the strict Yosys on PATH (OI-44)

STAGE = float(cg.param("CCV_NGD_BUDGET"))
PORT = float(cg.param("CCV_NGD_PORT"))
INNER = float(cg.param("CCV_NGD_INNER"))
GENLIB = cg.GENLIB
BUDGET_GLOB = os.path.join(ROOT, "rtl", "**", "*.ngd.json")
RATCHET = os.path.join(ROOT, "rtl", "ngd-ratchet.json")
# The findings that stood when each rule was made: NGD-1 to NGD-4 on
# 2026-10-17, NGD-5 on 2026-10-18 (its through paths had been NGD-2's),
# ooe_rat's then on OI's branch (b9c3a44); NGD-6 on 2026-10-19, ooe_select's
# on OI's branch (d8ffd4c: declared inner, no parent yet); NGD-7 on
# 2026-10-19, at 7ae697c; trimmed to the ratchet as modules pass (last at
# OI's 68d2738, 2026-10-20). Never add to this:
# a module written since meets the rules, or has the architect's budgets, or
# is redesigned.
RATCHET_BASELINE = {(m, k) for m, ks in {
    "ooe_decq": [
        "NGD-2 head_pay_cq02h", "NGD-2 used_cq02h", "NGD-7 st_cq02h",
    ],
    "ooe_rat": [
        "NGD-7 rat_cq02h",
    ],
    "ooe_rs": [
        "NGD-3 free_cq01h",
    ],
}.items() for k in ks}
# The fanout term's ratchet (RA-33; DA, 2026-11-04, OI rev 265): enforcing
# the term put paths that met the stage before over it. Each stood, keyed as
# its finding is and capped at its value, in this baseline, seeded once from
# the pushed tip; rtl/ngd-ratchet.json's "fanout" holds each module's caps,
# which may only fall: an entry not in the baseline, one capped above it, a
# finding over its cap, and an entry that now meets the rule all fail. Never
# add to the baseline: a path written since meets the rule with the term.
FANOUT_BASELINE = os.path.join(ROOT, "rtl", "ngd-fanout-baseline.json")
EPS = 0.005
NEG = float("-inf")


def run(cmd):
    return cg.run(cmd)


# ABC's mapping, cached beside the Yosys netlists (OI-95): keyed by the
# netlist it reads, the genlib, the whole ABC script and yosys-abc's
# version, so a hit is the mapped netlist and the report the run would
# write. verify.sh clears build/synth-cache for a clean gate, as it does the
# netlists; a scoped or --cached run keeps both.
_ABC_VERSION = []


def abc_cached(script, blif, out, genlib=None, cache=None):
    """yosys-abc `script` (reading `blif`, writing `out`), from the cache if
    the same netlist, genlib and script have run before. Returns the
    CompletedProcess, its stdout ABC's report either way."""
    import hashlib, fcntl, shutil, subprocess
    if not _ABC_VERSION:
        # Its `version` prints no version: the binary itself is the key.
        with open(shutil.which("yosys-abc"), "rb") as fh:
            _ABC_VERSION.append(hashlib.sha256(fh.read()).hexdigest())
    h = hashlib.sha256()
    h.update(" ".join(script.replace(blif, "<in>").replace(out, "<out>").split()).encode())
    h.update(b"\0" + _ABC_VERSION[0].encode())
    for f in (blif, genlib or GENLIB):
        with open(f, "rb") as fh:
            h.update(b"\0" + hashlib.sha256(fh.read()).digest())
    cache = cache or cg.SYNTH_CACHE
    os.makedirs(cache, exist_ok=True)
    hit = os.path.join(cache, "abc-" + h.hexdigest())
    with open(hit + ".lock", "w") as lk:
        fcntl.flock(lk, fcntl.LOCK_EX)
        if not os.path.exists(hit + ".blif"):
            r = run(["yosys-abc", "-c", script])
            if r.returncode or not os.path.exists(out):
                return r
            shutil.copyfile(out, hit + ".tmp")
            with open(hit + ".log.tmp", "w") as fh:
                fh.write(r.stdout)
            os.replace(hit + ".log.tmp", hit + ".log")
            os.replace(hit + ".tmp", hit + ".blif")
            return r
    shutil.copyfile(hit + ".blif", out)
    return subprocess.CompletedProcess([], 0, open(hit + ".log").read(), "")


# == The mapped netlist ========================================================

def genlib(path=GENLIB):
    """{gate: {pin: delay}}, as ABC's mapper costs each pin: the slower of its
    rise and fall. A gate whose pins share one line (PIN *) has the key "*".
    A gate's PIN lines may follow it on lines of their own."""
    out, gate = {}, None
    for line in open(path):
        m = re.match(r"GATE\s+(\S+)\s+\S+\s+[^;]*;(.*)", line)
        if m:
            gate, rest = m.group(1), m.group(2)
            out[gate] = {}
        elif gate and line.strip().startswith("PIN"):
            rest = line
        else:
            continue
        for pin, a, b in re.findall(r"PIN\s+(\S+)\s+\S+\s+\S+\s+\S+\s+([\d.]+)\s+\S+\s+([\d.]+)",
                                    rest):
            out[gate][pin] = max(float(a), float(b))
    return out


def delay(lib, gate, pin):
    """A gate's delay from one of its input pins."""
    d = lib[gate]
    return d[pin] if pin in d else d["*"]


LIB = dict(genlib(), WIRE={"*": 0.0}, ZERO={"*": 0.0})

# Every flop kind synthesis can leave, to the plain flop that stands for it:
# an enable is dropped (the flop is clocked through an ICG and takes its next
# value directly), a synchronous reset stays, for dfflegalize to put on D.
UNGATE = [(re.compile(r"^\$_DFFE_([NP])[NP]_$"), r"$_DFF_\1_"),
          (re.compile(r"^\$_SDFFC?E_([NP][NP][01])[NP]_$"), r"$_SDFF_\1_"),
          (re.compile(r"^\$_(S?DFF)_([NP]|[NP][NP][01])_$"), None)]


def ungate(d, blackbox):
    """A Yosys JSON netlist, in place: enables dropped; a cell of a type in
    `blackbox` (the ICG, or a child module timed by its budgets) cut out, its
    inputs made outputs and its outputs inputs, under names no port has.
    Returns {cut name: (cell, cell type, pin, the pin's direction)}."""
    cut = {}
    for m in d["modules"].values():
        ports = m["ports"]
        drop = []
        for cn, c in m.get("cells", {}).items():
            t = c["type"]
            if t in blackbox:
                for pin, bits in c["connections"].items():
                    nm = "bb_%s_%s" % (re.sub(r"\W", "_", cn), pin)
                    out = c["port_directions"][pin] == "input"
                    ports[nm] = {"direction": "output" if out else "input", "bits": bits}
                    cut[nm] = (cn, t, pin, c["port_directions"][pin])
                drop.append(cn)
                continue
            if not t.startswith("$_") or "DFF" not in t and "LATCH" not in t:
                continue
            for rx, to in UNGATE:
                if rx.match(t):
                    if to:
                        c["type"] = rx.sub(to, t)
                        for k in ("connections", "port_directions"):
                            c.get(k, {}).pop("E", None)
                    break
            else:
                raise SystemExit("check-ngd: %s: no timing model for a %s cell" % (cn, t))
        for cn in drop:
            del m["cells"][cn]
    return cut


def parse_blif(path):
    text = open(path).read().replace("\\\n", " ")
    lines = [ln.split() for ln in text.splitlines()]
    ins, outs, latches, gates = [], [], [], []
    for k, t in enumerate(lines):
        if not t:
            continue
        if t[0] == ".inputs":
            ins += t[1:]
        elif t[0] == ".outputs":
            outs += t[1:]
        elif t[0] == ".latch":
            latches.append((t[1], t[2]))
        elif t[0] == ".gate":
            pins = dict(x.split("=", 1) for x in t[2:])
            gates.append((t[1], [(k2, v) for k2, v in pins.items() if k2 != "Y"], pins["Y"]))
        elif t[0] == ".names" and len(t) == 3 and k + 1 < len(lines) and lines[k + 1] == ["1", "1"]:
            # A net wired straight to another, a port to a port: no delay.
            gates.append(("WIRE", [("A", t[1])], t[2]))
        elif t[0] == ".names" and len(t) == 2:
            gates.append(("ZERO", [], t[1]))        # a constant: no path through it
        elif t[0] in (".names", ".subckt"):
            raise SystemExit("check-ngd: %s: unexpected %s" % (path, " ".join(t)))
    return ins, outs, latches, gates


def base(net):
    return re.sub(r"\[\d+\]$", "", net)


class Timing:
    """Longest paths of a mapped netlist, by where they start (an input
    port, or a flop) and end (an output port, or a flop):
      rr                     flop to flop
      ir[in]                 input to flop
      ro[out]                flop to output
      io[(in, out)]          input to output
    each with the fanout term (below); p_rr, p_ro, p_ir and p_io without it.
    A BUF counts nothing here: ABC puts one only where a port is wired to a
    port, and fanout and wire are costed outside the logic (the genlib's
    note). `abc` is ABC's own longest path, BUFs at their genlib delay;
    the timing pass's, taken the same way, must equal it."""

    def __init__(self, blif, abc, lib=LIB):
        ins, outs, latches, gates = parse_blif(blif)
        self.abc = abc
        driver = {o: (g, a) for g, a, o in gates}
        # The fanout term (RA-33; DA, 2026-11-02): the genlib's delays are
        # at fanout 4, so a net with more loads is timed as if a buffer tree
        # of inverters at fanout 4 drove them, ceil(log4(loads / 4)) stages,
        # each an INV's delay. Enforced since DA, 2026-11-04 (OI rev 265):
        # rr, ro, ir and io, every rule's depth, block levels' included, are
        # timed with it; the p_ fields are the same depths without it,
        # report-only. ABC's own check (abc_like) stays without it.
        loads = collections.Counter(x for _, a, _ in gates for _, x in a)
        loads.update(d for d, _ in latches)
        loads.update(outs)
        inv = delay(lib, "INV", "A")

        def fo(n):
            k, c = 0, 4
            while c < loads.get(n, 0):
                c, k = c * 4, k + 1
            return k * inv
        self.fanout_max = max(loads.values(), default=0)
        self.loads, self.fo = loads, fo
        order, seen = [], set()
        for n0 in driver:
            stack = [(n0, False)]
            while stack:
                x, done = stack.pop()
                if done:
                    order.append(x)
                    continue
                if x in seen or x not in driver:
                    continue
                seen.add(x)
                stack.append((x, True))
                stack.extend((a, False) for _, a in driver[x][1] if a not in seen)

        def prop(start, buf=0.0, fan=False):
            arr = {x: fo(x) if fan else 0.0 for x in start}
            for n in order:
                g, a = driver[n]
                if g in ("ZERO", "ONE"):
                    continue
                t = max((arr[x] + (buf if g == "BUF" else delay(lib, g, pin))
                         for pin, x in a if x in arr), default=NEG)
                if t > NEG:
                    arr[n] = t + (fo(n) if fan else 0.0)
            return arr

        ports_in = collections.defaultdict(list)
        for i in ins:
            ports_in[base(i)].append(i)
        ports_out = collections.defaultdict(list)
        for o in outs:
            ports_out[base(o)].append(o)
        d_nets = [d for d, _ in latches]
        every = prop(list(ins) + [q for _, q in latches], buf=delay(lib, "BUF", "A"))
        self.abc_like = max([every.get(n, NEG) for n in d_nets + list(outs)] + [0.0])
        r = prop([q for _, q in latches])
        self.p_rr = max((r.get(d, NEG) for d in d_nets), default=NEG)
        self.p_ro = {p: max(r.get(o, NEG) for o in bits) for p, bits in ports_out.items()}
        pa = prop([i for i in ins if not i.startswith("bb_")])
        self.p_ir = max((pa.get(d, NEG) for d in d_nets), default=NEG)
        rf = prop([q for _, q in latches], fan=True)
        self.rr = max((rf.get(d, NEG) for d in d_nets), default=NEG)
        self.ro = {p: max(rf.get(o, NEG) for o in bits) for p, bits in ports_out.items()}
        self.ir, self.io, self.p_io = {}, {}, {}
        for p, bits in ports_in.items():
            a = prop(bits, fan=True)
            z = prop(bits)
            self.ir[p] = max((a.get(d, NEG) for d in d_nets), default=NEG)
            for q, obits in ports_out.items():
                t = max(a.get(o, NEG) for o in obits)
                if t > NEG:
                    self.io[(p, q)] = t
                    self.p_io[(p, q)] = max(z.get(o, NEG) for o in obits)
        # A port's own net, its pins in this netlist: {port: (most loads on
        # one of its bits, that bit's fanout term)}.
        self.port_fan = {p: max((loads.get(b, 0), fo(b)) for b in bits)
                         for p, bits in ports_in.items()}
        self.ins, self.outs = sorted(ports_in), sorted(ports_out)
        self.gates = collections.Counter(g for g, _, _ in gates)
        self.nflops = len(latches)
        # Backward from the endpoints (NGD-7): each flop's longest path to
        # any flop, and to each output port it reaches.
        qs = {q for _, q in latches}

        def back(ends):
            dep = dict.fromkeys(ends, 0.0)
            for n in reversed(order):
                if n not in dep or driver[n][0] in ("ZERO", "ONE"):
                    continue
                g, a = driver[n]
                for pin, x in a:
                    w = dep[n] + (0.0 if g == "BUF" else delay(lib, g, pin))
                    if dep.get(x, NEG) < w:
                        dep[x] = w
            return dep
        self.q_flop = {q: v for q, v in back(d_nets).items() if q in qs}
        self.q_out = collections.defaultdict(dict)
        for p, bits in ports_out.items():
            for q, v in back(bits).items():
                if q in qs:
                    self.q_out[q][p] = v


def reg_names(d):
    """{a net bit as write_blif spells it: its register's name in the RTL}.
    A flop's net is often named for the port it drives; another name for
    the same bit, not a port's, is the register's."""
    mods = list(d["modules"].values())
    top = next((m for m in mods if m.get("attributes", {}).get("top")), mods[0])
    ports = set(top["ports"])
    names = collections.defaultdict(set)
    for nn, v in top["netnames"].items():
        if not v.get("hide_name"):
            for b in v["bits"]:
                if isinstance(b, int):
                    names[b].add(nn)
    out = {}
    for nn, v in top["netnames"].items():
        if v.get("hide_name"):
            continue
        w, off = len(v["bits"]), v.get("offset", 0)
        for i, b in enumerate(v["bits"]):
            alts = [n for n in names.get(b, ()) if n not in ports] if isinstance(b, int) else []
            if alts:
                k = off + (w - 1 - i if v.get("upto") else i)
                out[nn if w == 1 else "%s[%d]" % (nn, k)] = min(
                    alts, key=lambda n: (not n.endswith("_q"), len(n), n))
    return out


# A netlist this size or more maps in series: ABC's peak grows with it.
# Full-size ooe_rob's, the unit it was set for, needed most of the
# container alone; the ROB split (OA-24) replaced it with ooe_rob_w.
PARALLEL_BLIF_MAX = 4 << 20
PARALLEL_FREE_MIN = 8 << 30


def two_maps_fit(blif):
    try:
        if os.path.getsize(blif) >= PARALLEL_BLIF_MAX:
            return False
        with open("/proc/meminfo") as fh:
            free = {l.split(":")[0]: int(l.split()[1]) * 1024 for l in fh if ":" in l}
        return free.get("MemAvailable", 0) >= PARALLEL_FREE_MIN
    except OSError:
        return False


def map_and_time(work, jsonfile, blackbox=(), lib=LIB):
    """Ungate a Yosys JSON netlist, map it with ABC and time it."""
    d = json.load(open(jsonfile))
    cut = ungate(d, set(blackbox))
    ug = os.path.join(work, "ug.json")
    json.dump(d, open(ug, "w"))
    blif, mapped = os.path.join(work, "net.blif"), os.path.join(work, "map.blif")
    r = run(["yosys", "-q", "-p", "read_json %s; dfflegalize -cell $_DFF_P_ x; "
             "opt_clean; write_blif %s" % (ug, blif)])
    if r.returncode:
        raise SystemExit("check-ngd: %s: yosys failed:\n%s" % (work, (r.stdout + r.stderr)[-2000:]))
    def mapped_timing(how, out):
        r = abc_cached("read_blif %s; read_library %s; strash; dch; %s; "
                       "print_stats; write_blif %s" % (blif, GENLIB, how, out), blif, out)
        m = re.search(r"delay\s*=\s*([\d.]+)", r.stdout)
        if r.returncode or not m:
            raise SystemExit("check-ngd: %s: ABC failed:\n%s"
                             % (work, (r.stdout + r.stderr)[-2000:]))
        t = Timing(out, float(m.group(1)), lib)
        if abs(t.abc_like - t.abc) > EPS:
            raise SystemExit("check-ngd: %s: the timing pass's longest path, %.2f NGD, is not "
                             "ABC's, %.2f (%s)" % (work, t.abc_like, t.abc, how))
        return t
    # map and map -r read the same netlist and nothing of each other's, so
    # they may run side by side (OI-95) -- but not on a big unit: full-size
    # ooe_rob's ABC peaked near 6.5 GB each (before the split, OA-24), and two were killed in a
    # 15 GB container at CCV_JOBS=1 (OI-97). Side by side only for a small
    # netlist with the memory for both; in series otherwise.
    if two_maps_fit(blif):
        import concurrent.futures
        with concurrent.futures.ThreadPoolExecutor(2) as ex:
            f_map = ex.submit(mapped_timing, "map", mapped)
            f_r = ex.submit(mapped_timing, "map -r", os.path.join(work, "map_r.blif"))
            t, tr = f_map.result(), f_r.result()
    else:
        t = mapped_timing("map", mapped)
        tr = mapped_timing("map -r", os.path.join(work, "map_r.blif"))
    # Input to flop (NGD-3), each input from the better of two maps (OI-64):
    # map's area recovery lets every path with slack grow to the module's
    # longest, so an input's cone can read the worst path whatever its own
    # logic, and NGD-3 then adds the port's arrival on top. map -r, without
    # area recovery, restores it; but it is a different mapping, not a
    # uniformly shallower one, and some inputs read deeper there. Each is a
    # legal implementation, and timing-driven synthesis takes the better for
    # a critical input. ABC drops BLIF input arrivals, so the inputs cannot
    # be costed in either map.
    t.ir_area, t.ir_r = t.ir, tr.ir
    t.ir = {p: min(v, tr.ir.get(p, v)) for p, v in t.ir.items()}
    # NGD-7's paths from each register, to the flops and to each output,
    # likewise from the better of the two maps (OI-45: ooe_rs's dep reads
    # 14.96 on map, 11.74 on map -r), but only where map -r's netlist is no
    # worse flop to flop: then one netlist meets NGD-1 and NGD-7 together,
    # and only area recovery stretched the register's off-critical paths.
    t.q_flop_area, t.q_out_area, t.rr_r = t.q_flop, t.q_out, tr.rr
    t.q_flop_r, t.q_out_r = tr.q_flop, tr.q_out
    # NGD-2's output ready times the same, on the same condition (OI-68:
    # ooe_go's wb reads 18.7 on map, 11.2 on map -r, flop to flop 21.6
    # against 21.1).
    t.ro_area, t.ro_r = t.ro, tr.ro
    if tr.rr <= t.rr + EPS:
        t.ro = {p: min(v, tr.ro.get(p, v)) for p, v in t.ro.items()}
        t.p_ro = {p: min(v, tr.p_ro.get(p, v)) for p, v in t.p_ro.items()}
        t.q_flop = {q: min(v, tr.q_flop.get(q, v)) for q, v in t.q_flop.items()}
        q_out = collections.defaultdict(dict)
        for q, outs in t.q_out.items():
            for p, v in outs.items():
                q_out[q][p] = min(v, tr.q_out.get(q, {}).get(p, v))
        t.q_out = q_out
    t.cut, t.regname = cut, reg_names(d)
    return t


def synth(name, top, files, blackbox=(), params=None, defines=(), flat=True, inner=()):
    """A module at its parameters, as a Yosys JSON netlist: flattened, or
    with its hierarchy kept, less the `inner` helpers, which are flattened
    into their parents (a parameterised copy is $paramod\\<module>\\..., or
    $paramod$<sha1>\\<module> when its parameter string is long; OI-69)."""
    work = os.path.join(BUILD, name)
    os.makedirs(work, exist_ok=True)
    jf = os.path.join(work, "net.json")
    cmds = ["read_verilog -sv -formal %s -Irtl/include -Irtl/generated %s"
            % (" ".join("-D%s" % x for x in defines),
               " ".join(["rtl/ccv_assert_pkg.sv"] + list(files)))]
    for bb in blackbox:
        cmds.append("read_verilog -sv -lib -Irtl/include -Irtl/generated %s" % bb)
    if params:
        cmds.append("chparam %s %s" % (" ".join(
            "-set %s %s" % (k, v) for k, v in sorted(params.items())), top))
    # A register declared (* keep *) keeps its flops (NGD-7's copies), as
    # in check-cg's flows (cg.KEEP_FLOPS).
    cmds += ["hierarchy -top %s" % top, "chformal -remove"] + cg.KEEP_FLOPS
    if not flat and inner:
        cmds += ["setattr -mod -set keep_hierarchy 1 *",
                 "setattr -mod -unset keep_hierarchy %s" % " ".join(
                     "%s $paramod\\%s\\* $paramod$*\\%s" % (m, m, m) for m in sorted(inner))]
        flat = True
    cmds += ["synth %s-top %s" % ("-flatten " if flat else "", top)]
    r = cg.yosys_json(cmds, jf)
    if r.returncode:
        raise SystemExit("check-ngd: %s: yosys failed:\n%s" % (name, (r.stdout + r.stderr)[-2000:]))
    return work, jf


# == Units and budgets =========================================================

def children(module, files, modules):
    """The design modules `module` instantiates, from its source."""
    out = set()
    for f in files:
        src = cg.lint.strip_comments(open(os.path.join(ROOT, f)).read())
        for s, e, name, _ in cg.lint.module_spans(src):
            if name == module:
                out |= {m for m in modules if m != module and re.search(
                    r"\b%s\s*(#|[A-Za-z_]\w*\s*\()" % re.escape(m), src[s:e])}
    return out


class Unit:
    def __init__(self, spec, src):
        self.spec, self.src = spec, src
        self.name, self.module = spec["name"], spec["module"]
        self.t, self.h = None, []

    def measure(self, lib=LIB, budgets=None, modules=None):
        """Flattened, the module's ports; and, if it instantiates a design
        module that is not an inner helper, its own level with its children
        cut out (converge), as findings in self.h."""
        s = self.spec
        bbs = s.get("blackbox", {})
        bbfiles = [bbs[b] for b in sorted(bbs)]
        work, jf = synth("u_" + self.name, self.module, s["files"],
                         bbfiles, s.get("params"), s.get("defines", []))
        self.jf = jf
        self.t = map_and_time(work, jf, bbs.keys(), lib)
        if budgets is not None and children(self.module, s["files"], modules or {}) - set(
                budgets.inner):
            self.h = converge("u_" + self.name, self.module, s["files"], bbfiles, budgets, lib,
                              s.get("params"), s.get("defines", []), unit=self.name)
        return self.t


def load_units():
    out, names = [], set()
    files = [f for pat in ("cg-units.json", "ngd-units.json")
             for f in sorted(glob.glob(os.path.join(ROOT, "test", "**", pat), recursive=True))]
    for f in files + [cg.RPT_UNITS]:
        if os.path.exists(f):
            for spec in json.load(open(f))["units"]:
                if spec["name"] in names:
                    raise SystemExit("check-ngd: unit %s defined twice" % spec["name"])
                names.add(spec["name"])
                out.append(Unit(spec, os.path.relpath(f, ROOT)))
    return out


def design_modules():
    """{module: rel path} for every design module, with flops or without,
    less checkers and ctech cells."""
    _, by_letter = cg.lint.load_blocks()
    blocknames = {b["name"] for b in by_letter.values()}
    out = {}
    for path in sorted(glob.glob(os.path.join(ROOT, "rtl", "**", "*.sv"), recursive=True)):
        rel = os.path.relpath(path, ROOT)
        if rel.startswith(cg.DESIGN_SKIP):
            continue
        src = cg.lint.strip_comments(open(path).read())
        for _, _, name, _ in cg.lint.module_spans(src):
            if cg.lint.classify(name, blocknames).typ not in ("chk", "ctech"):
                out[name] = rel
    return out


class Budgets:
    """Each module's non-default port budgets, from <module>.ngd.json beside
    its RTL:

      {"module": "ooe_rs",
       "ports": {"free_cq01h":    {"arrival": 3.0,   "by": ..., "date": ..., "why": ...},
                 "gnt_idx_cq02h": {"required": 20.0, "by": ..., "date": ..., "why": ...},
                 "dbg_cq02h":     {"observation": true, "by": ..., "date": ..., "why": ...}}}

    An input's arrival or an output's required time, in NGD from the flop
    that launches it; or an output read only by checkers, which sample it
    at the edge as a flop would, exempt from the port rules. A port the file
    does not name takes the default: an output required at CCV_NGD_PORT, an
    input arriving at CCV_NGD_BUDGET - CCV_NGD_PORT. A combinational helper
    timed only inside its parent says so instead, and has no ports:

      {"module": "ooe_pick", "inner": true, "by": ..., "date": ..., "why": ...}"""

    def __init__(self, files=(), extra=None, inner=None):
        self.e, self.files, self.inner, self.bad = {}, {}, {}, []
        for f in files:
            rel = os.path.relpath(f, ROOT)
            try:
                d = json.load(open(f))
            except ValueError as e:
                self.bad.append("NGD-4 %s: not JSON: %s" % (rel, e))
                continue
            mod = d.get("module")
            if os.path.basename(f) != "%s.ngd.json" % mod:
                self.bad.append("NGD-4 %s: names module %s, not its file name's" % (rel, mod))
                continue
            self.files[mod] = rel
            if d.get("inner"):
                self.inner[mod] = d
            for port, b in d.get("ports", {}).items():
                self.e[(mod, port)] = b
        for (mod, port), b in (extra or {}).items():
            self.e[(mod, port)] = b
        self.inner.update(inner or {})

    @classmethod
    def load(cls):
        return cls(sorted(glob.glob(BUDGET_GLOB, recursive=True)))

    def is_inner(self, mod):
        return mod in self.inner

    def observation(self, mod, port):
        b = self.e.get((mod, port))
        return bool(b and b.get("observation"))

    def required(self, mod, port):
        b = self.e.get((mod, port))
        if b and b.get("observation"):
            return STAGE
        return float(b["required"]) if b and "required" in b else PORT

    def arrival(self, mod, port):
        b = self.e.get((mod, port))
        return float(b["arrival"]) if b and "arrival" in b else STAGE - PORT

    def check(self, units, modules):
        """NGD-4: each file for a design module, an inner helper's with no
        ports, each entry well formed and on a port its module has, of the
        right direction."""
        fails = list(self.bad)
        ports = {}
        for u in units:
            if u.t is not None:
                ports.setdefault(u.module, (set(u.t.ins), set(u.t.outs)))
        for mod, rel in sorted(self.files.items()):
            if mod not in modules:
                fails.append("NGD-4 %s: %s is not a design module" % (rel, mod))
        for mod, d in sorted(self.inner.items()):
            where = "%s (%s)" % (mod, self.files.get(mod, "selftest"))
            for k in ("by", "date", "why"):
                if not d.get(k):
                    fails.append("NGD-4 %s: an inner helper with no %s" % (where, k))
            if any(m == mod for m, _ in self.e):
                fails.append("NGD-4 %s: an inner helper has no port budgets; its parent's "
                             "ports carry them" % where)
            if any(u.module == mod and u.t is not None and u.t.nflops for u in units):
                fails.append("NGD-4 %s: an inner helper has flops; only a combinational "
                             "module is timed inside its parent" % where)
        for (mod, port), b in sorted(self.e.items()):
            where = "%s.%s (%s)" % (mod, port, self.files.get(mod, "selftest"))
            for k in ("by", "date", "why"):
                if not b.get(k):
                    fails.append("NGD-4 %s: no %s" % (where, k))
            kind = [k for k in ("arrival", "required", "observation") if k in b]
            if len(kind) != 1:
                fails.append("NGD-4 %s: names not exactly one of arrival, required and "
                             "observation" % where)
                continue
            if kind[0] == "observation":
                if b["observation"] is not True:
                    fails.append("NGD-4 %s: observation is true or absent" % where)
            else:
                v = float(b[kind[0]])
                if not 0 <= v <= STAGE:
                    fails.append("NGD-4 %s: %s %g is outside 0..%g" % (where, kind[0], v, STAGE))
            if mod in ports:
                inp = kind[0] == "arrival"
                if port not in (ports[mod][0] if inp else ports[mod][1]):
                    fails.append("NGD-4 %s: %s has no %s port %s"
                                 % (where, mod, "input" if inp else "output", port))
        return fails


def parented(units, modules):
    """The design modules some unit's module instantiates. An inner helper
    among them is timed inside that parent; one that is not is held alone to
    CCV_NGD_INNER (NGD-6)."""
    out = set()
    for u in units:
        out |= children(u.module, u.spec["files"], modules)
    return out


def findings(u, budgets, parents=frozenset()):
    """The unit's findings, as (key, message): key is what the ratchet lists.
    An inner helper is held only to the stage: its ports are its parent's
    logic. Until a module instantiates it (`parents`), it is held alone to
    CCV_NGD_INNER input to output: the parent's logic will share its stage."""
    t, mod, out = u.t, u.module, []
    if t.rr > STAGE + EPS:
        out.append(("NGD-1", "NGD-1 %s (unit %s): flop to flop %.1f NGD, over the %g stage"
                    % (mod, u.name, t.rr, STAGE)))
    if budgets.is_inner(mod):
        if mod not in parents:
            for (i, o), d in sorted(t.io.items()):
                if i in t.cut or o in t.cut or is_clock(i) or d <= INNER + EPS:
                    continue
                out.append(("NGD-6 %s>%s" % (i, o), "NGD-6 %s (unit %s): an inner helper no "
                            "module instantiates yet, %.1f NGD from input %s to output %s, over "
                            "the %g it is held to alone (CCV_NGD_INNER)"
                            % (mod, u.name, d, i, o, INNER)))
        return out
    out += u.h
    for o in t.outs:
        if o in t.cut or budgets.observation(mod, o):
            continue
        req = budgets.required(mod, o)
        if t.ro[o] > req + EPS:
            out.append(("NGD-2 %s" % o, "NGD-2 %s (unit %s): output %s ready %.1f NGD after its "
                        "flops, required at %g" % (mod, u.name, o, t.ro[o], req)))
    for i in t.ins:
        if i in t.cut or t.ir[i] == NEG:
            continue
        arr = budgets.arrival(mod, i)
        if arr + t.ir[i] > STAGE + EPS:
            out.append(("NGD-3 %s" % i, "NGD-3 %s (unit %s): input %s, arriving at %g, reaches "
                        "a flop %.1f later, %.1f in all, over the %g stage"
                        % (mod, u.name, i, arr, t.ir[i], arr + t.ir[i], STAGE)))
    out += shared_flops(u, budgets)
    for (i, o), d in sorted(t.io.items()):
        if i in t.cut or o in t.cut or is_clock(i) or budgets.observation(mod, o):
            continue
        what = ("%.1f NGD of logic" % d) if d > EPS else "a wire"
        out.append(("NGD-5 %s>%s" % (i, o), "NGD-5 %s (unit %s): %s straight through, input "
                    "%s to output %s: connect a wire directly, group logic with a "
                    "sequential side" % (mod, u.name, what, i, o)))
    return out


def finding_value(u, budgets, key):
    """The depth a finding reads, for the fanout ratchet's caps: NGD-1's flop
    to flop, NGD-2's output ready time, NGD-3's arrival plus logic, NGD-6's
    input to output, NGD-7's reach from the register; None for NGD-5, which
    has no depth to cap (a path straight through is refused at any depth)."""
    t, kind, _, rest = u.t, key[:5], key[5:6], key[6:]
    if kind == "NGD-1":
        return t.rr
    if kind == "NGD-2":
        return t.ro.get(rest)
    if kind == "NGD-3":
        return budgets.arrival(u.module, rest) + t.ir[rest] if rest in t.ir else None
    if kind == "NGD-6":
        i, o = rest.split(">", 1)
        return t.io.get((i, o))
    if kind == "NGD-7":
        w = shared_worst(u, budgets).get(rest)
        return w[4] if w else None
    return None


def shared_flops(u, budgets):
    """NGD-7 (Daniel, 2026-10-19): a register that drives an output is held,
    on every path it starts, to that output's required time: to the module's
    own flops as to any output. A flop on a critical path out and on one in
    is pulled two ways at placement. Where a register drives several
    outputs, the strictest holds; a path to an output over that output's own
    required time is NGD-2's. The remedy is a copy of the register, one
    for the output and one for the paths inside, each declared (* keep *).
    Keyed by register."""
    return [("NGD-7 %s" % reg, "NGD-7 %s (unit %s): register %s drives output %s, required at "
             "%g, and reaches %s %.1f NGD away: copy the register, one copy for the output and "
             "one for the rest, each (* keep *)" % (u.module, u.name, reg, port, lim, what, d))
            for reg, (_, q, port, lim, d, what) in sorted(shared_worst(u, budgets).items())]


def shared_worst(u, budgets):
    """NGD-7's worst path per register: {register: (excess, q, port, required,
    depth, what)}."""
    t, mod, worst = u.t, u.module, {}
    for q, outs in t.q_out.items():
        defs = {p: budgets.required(mod, p) for p in outs
                if p not in t.cut and not budgets.observation(mod, p)}
        if not defs:
            continue
        port = min(defs, key=lambda p: (defs[p], p))
        # An output over its own required time is NGD-2's, not counted here.
        ends = [(t.q_flop.get(q, NEG), "a flop")] + [
            (d, "output %s" % p) for p, d in outs.items()
            if p in t.cut or p in defs and d <= defs[p] + EPS]
        d, what = max(ends)
        reg = t.regname.get(q, base(q))
        if d > defs[port] + EPS and d - defs[port] > worst.get(reg, (NEG,))[0]:
            worst[reg] = (d - defs[port], q, port, defs[port], d, what)
    return worst


def report(u, verbose=False):
    t = u.t
    ro = max([v for k, v in t.ro.items() if k not in t.cut] + [0.0])
    ir = max([v for k, v in t.ir.items() if k not in t.cut] + [0.0])
    io = max([v for (i, o), v in t.io.items() if i not in t.cut and o not in t.cut] + [0.0])
    print("  unit %-16s %-14s flop-flop %5.1f  in-flop %5.1f  flop-out %5.1f  in-out %5.1f"
          % (u.name, u.module, max(t.rr, 0.0), ir, ro, io))
    # The depths above carry the fanout term (RA-33, enforced since DA,
    # 2026-11-04); report-only, what the same paths read without it.
    p_ro = max([v for k, v in t.p_ro.items() if k not in t.cut] + [0.0])
    if max(t.rr, ir, ro, 0.0) > max(t.p_rr, t.p_ir, p_ro, 0.0) + EPS:
        print("    without the fanout term flop-flop %5.1f  in-flop %5.1f  flop-out %5.1f;"
              " widest net %d loads" % (max(t.p_rr, 0.0), max(t.p_ir, 0.0), p_ro, t.fanout_max))
    if verbose:
        for o in t.outs:
            if o not in t.cut:
                print("    out %-28s from flops %5.1f" % (o, max(t.ro[o], 0.0)))
        for i in t.ins:
            if i not in t.cut:
                print("    in  %-28s to flops   %5.1f" % (i, max(t.ir[i], 0.0)))
        for (i, o), v in sorted(t.io.items()):
            if i not in t.cut and o not in t.cut:
                print("    thru %s -> %s %5.1f" % (i, o, v))


# == The policy ================================================================

def load(path, key, default):
    return json.load(open(path)).get(key, default) if os.path.exists(path) else default


def policy(units, budgets, ratchet, modules, baseline=RATCHET_BASELINE, fan=None,
           fan_base=None):
    """Findings excused by the ratchet; a ratchet entry that is no longer a
    finding, or was never in the baseline, refused; a design module no unit
    measures, refused. `fan` ({module: {key: cap}}, the ratchet's "fanout")
    excuses a finding the fanout term made, up to its cap, which must be in
    `fan_base` and no higher than it. Returns the failures."""
    fan, fan_base = fan or {}, fan_base or {}
    fails = list(budgets.check(units, modules))
    found = collections.defaultdict(set)
    parents = parented(units, modules)
    for u in units:
        for key, msg in findings(u, budgets, parents):
            found[u.module].add(key)
            if key in ratchet.get(u.module, []):
                continue
            cap = fan.get(u.module, {}).get(key)
            v = finding_value(u, budgets, key)
            if cap is None:
                fails.append(msg)
            elif v is None or v > cap + EPS:
                fails.append("%s; its fanout ratchet cap is %g (RA-33): a capped path may only "
                             "get shorter" % (msg, cap))
    for mod, caps in sorted(fan.items()):
        for k, cap in sorted(caps.items()):
            b = fan_base.get(mod, {}).get(k)
            if b is None:
                fails.append("fanout ratchet: %s %s was not over the stage when the fanout term "
                             "was enforced (%s); the list only shrinks"
                             % (mod, k, os.path.relpath(FANOUT_BASELINE, ROOT)))
            elif cap > b + EPS:
                fails.append("fanout ratchet: %s %s capped at %g, above its baseline %g; a cap "
                             "only falls" % (mod, k, cap, b))
            elif k not in found.get(mod, set()) and any(u.module == mod for u in units):
                fails.append("fanout ratchet: %s %s now meets the rule: remove it from %s"
                             % (mod, k, os.path.relpath(RATCHET, ROOT)))
    for mod, keys in sorted(ratchet.items()):
        for k in keys:
            if (mod, k) not in baseline:
                fails.append("ratchet: %s %s was not on the list when the rule was made; the "
                             "list only shrinks" % (mod, k))
            elif k not in found.get(mod, set()) and any(u.module == mod for u in units):
                fails.append("ratchet: %s %s now meets the rule: remove it from %s"
                             % (mod, k, os.path.relpath(RATCHET, ROOT)))
    have = {u.module for u in units}
    for mod in sorted(modules):
        if mod not in have:
            fails.append("%s (%s) has no timing unit (test/**/cg-units.json or ngd-units.json)"
                         % (mod, modules[mod]))
    return fails


def is_clock(pin):
    """A clock pin by its name (CCV-L20): its net is the clock tree's, not
    logic's."""
    return pin == "clk" or pin.endswith("_clk") or pin == "gclk"


src_name = cg.src_name


def time_level(tag, st, mn, kids, lib=LIB):
    """One level of a structural read (cg.Structure) mapped and timed alone:
    its children `kids` black boxes (those read whole made so with Yosys's
    `blackbox` before synthesis; leaves read -lib are already), its inner
    helpers flattened into it as its own logic. Nothing of a child is
    synthesised (Daniel, 2026-11-06)."""
    whole = sorted(k for k in kids if k not in st.leaf)
    cmds = list(st.cmds) + (["blackbox %s" % " ".join(whole)] if whole else []) + \
        cg.KEEP_FLOPS + ["synth -flatten -top %s" % mn]
    sub = os.path.join(BUILD, "h_" + tag, re.sub(r"\W", "_", mn)[:80] + "_" +
                       cg.hashlib.sha1(mn.encode()).hexdigest()[:8])
    os.makedirs(sub, exist_ok=True)
    jf = os.path.join(sub, "one.json")
    r = cg.yosys_json(cmds, jf)
    if r.returncode:
        raise SystemExit("check-ngd: %s, level %s: yosys failed:\n%s"
                         % (tag, src_name(mn), (r.stdout + r.stderr)[-2000:]))
    TIMED_ALONE.append(mn)
    return map_and_time(sub, jf, set(kids) | st.lib, lib)


# Every level time_level() synthesised, in order: the selftest's record that
# a child is never one of them.
TIMED_ALONE = []


def level_kids(st, mn, budgets):
    """A level's children that are cut out: every design child but an inner
    helper, which is its parent's logic."""
    return {t for _, t in st.cells(mn) if not budgets.is_inner(src_name(t))}


def converge(name, top, files, bbs, budgets, lib=LIB, params=None, defines=(), unit=None,
             st=None, start=None, timings=None):
    """A hierarchy from its budget files, as a sum of parts (Daniel,
    2026-11-06): the hierarchy is read structurally (cg.Structure: front end,
    hierarchy and proc, nothing synthesised), and each module in it that
    instantiates others (the hardening wrapper aside, which is nets and
    repeaters) is mapped alone, its children black boxes, never synthesised
    (time_level), its inner helpers flattened into it. A child's output
    starts at its required time, a child's input must be reached by its
    arrival; the module's own ports take its budgets, or, for a block top,
    the boundary's: inputs arriving at 0, straight from the interface
    module's flop in its wrapper (AR's rev 285 (5)); its outputs, straight
    from a flop, and its inputs, straight into one, are block_check's
    boundary rule. So every connection must converge, and a path that
    touches none of the module's own flops must be a wire (NGD-5: glue
    between children is a third segment on a flop-to-flop path).

    The level's nets carry the fanout term (RA-33) for the pins on the
    parent's net only: each cut child input, output port, own gate input and
    own flop D on it. A child's unit counts the loads inside the child on its
    port's net, its output port as one; the level does not count those, and
    the child does not count the parent's pins, so no load counts twice. A
    wire (no logic, p_io 0) from a child's output, an own input or an own
    flop converges only when its start plus that term (io) is within each
    receiver's arrival; a path through the level's logic to a flop or from
    one (ir, ro) carries the term on every net it crosses.

    For a block, every level from `start` (default the read's top) in `st`
    (default a read of `top`), the block's own top level timed even with no
    children, and findings are messages; each level's timing lands in
    `timings`. For a unit (`unit`, its name), the top level only, its
    children's connections alone (its own ports are its flattened findings'),
    as (key, message) for the ratchet. A path from a port of the module's to
    a port of its own is its unit's NGD-5, or a wire, which carries its
    driver's time to its receiver."""
    if st is None:
        st = cg.Structure("h_" + name, top, files, bbs, params, defines,
                          keep=sorted(budgets.inner))
    start = start or st.top
    out = []
    for mn in st.reachable(start):
        if mn in st.leaf or src_name(mn).endswith("_w") or budgets.is_inner(src_name(mn)):
            continue
        if unit and mn != start:
            continue
        kids = level_kids(st, mn, budgets)
        edge = mn == start and not unit
        if not kids and not edge:
            continue
        own = src_name(mn)
        t = time_level(name, st, mn, kids, lib)
        if timings is not None:
            timings[mn] = t

        def pin(p):
            """(module, pin, name) of a cut child's pin; None for the ICG's
            or a clock's."""
            cell, typ, pn, _ = t.cut[p]
            if typ in st.lib or is_clock(pn):
                return None
            return src_name(typ), pn, "%s.%s" % (cell, pn)

        def start_(p):
            if p in t.cut:
                c = pin(p)
                return (budgets.required(c[0], c[1]), c[2], True) if c else (None, None, True)
            if is_clock(p):
                return None, None, False
            return (0.0 if edge else budgets.arrival(own, p)), p, False

        def end(p):
            if p in t.cut:
                c = pin(p)
                return (budgets.arrival(c[0], c[1]), c[2], True) if c else (None, None, True)
            if edge:
                return None, p, False      # the boundary rule: straight from a flop
            return budgets.required(own, p), p, False

        if unit:
            where = "%s (unit %s)" % (own, unit)
        else:
            where = "block %s, in %s" % (name, own)
        if t.rr > STAGE + EPS and not unit:
            out.append(("NGD-1", "%s: flop to flop %.1f NGD, over the %g stage"
                        % (where, t.rr, STAGE)))
        for p in t.ins:
            a, nm, kid = start_(p)
            if (kid or not unit) and a is not None and t.ir[p] > NEG and a + t.ir[p] > STAGE + EPS:
                out.append(("budgets %s>flops" % nm, "%s: %s, starting at %g, reaches a flop at "
                            "%.1f, over the %g stage" % (where, nm, a, a + t.ir[p], STAGE)))
        for p in t.outs:
            r, nm, kid = end(p)
            if (kid or not unit) and r is not None and t.ro[p] > r + EPS:
                out.append(("budgets flops>%s" % nm, "%s: %s, required at %g, is reached from "
                            "a flop at %.1f" % (where, nm, r, t.ro[p])))
        for (p, q), dl in sorted(t.io.items()):
            (a, na, ka), (r, nr, kr) = start_(p), end(q)
            if not (ka or kr) or (ka and na is None) or (kr and nr is None) or is_clock(p):
                continue
            lg = t.p_io[(p, q)]
            if lg > EPS:
                out.append(("NGD-5 %s>%s" % (na, nr), "NGD-5 %s: %.1f NGD of logic from %s to %s, "
                            "a path that touches none of its flops" % (where, lg, na, nr)))
            elif a is not None and r is not None and a + dl > r + EPS:
                n, _ = t.port_fan.get(p, (0, 0.0))
                fan = (", plus %.1f NGD of fanout term for the %d loads on the parent's net"
                       % (dl, n)) if dl > EPS else ""
                out.append(("budgets %s>%s" % (na, nr), "%s: budgets do not converge: %s, "
                            "starting at %g%s, reaches %s, required at %g"
                            % (where, na, a, fan, nr, r)))
    return out


def ngd_keyed(units):
    """[(unit, cg.unit_key)] for every measured timing unit."""
    return [(u, cg.unit_key(u.spec, u.jf)) for u in units
            if u.t is not None and getattr(u, "jf", None)]


def block_check(name, top, files, bbs, budgets, units, block=None, lib=LIB, params=None):
    """A block assembled, as a sum of parts (Daniel, 2026-11-06): no
    whole-block synthesis, no child synthesised with its parent. The
    hierarchy of `top` (the partition: the block's hardening wrapper, or the
    block) is read structurally, and:

      (a) coverage: every instance below the block's own top level (the
          wrapper's repeaters too) is measured by a timing unit at the
          instance's parameters, so its own paths are held to the stage and
          its ports to its budgets (NGD-1 to NGD-3, NGD-5, NGD-7, by policy());
      (b) convergence: each level from the block's own module (`block`)
          down is timed alone, children cut at their budgets (converge), so
          every flop-to-flop path across modules, two port segments at most
          (THRU), is within the stage;
      (c) the boundary: every output of the partition is straight from a
          flop and every input straight into one, by its parts. At each
          level a boundary port must meet its own flop with no logic
          between, or reach a child's pin by a wire only (no glue), and
          that child's port is then held the same way: a level's by its own
          timing alone, a leaf's by its unit's measurement at the
          instance's parameters (ro and ir 0 NGD, nothing straight
          through). The measurement, not the budget: a leaf's port budget
          is a bound, 0 only by the architect's choice, where the unit
          measures the netlist the block instantiates.

    The fanout term at the boundary: an input wired to more than 4 pins on
    a level's net is a buffer tree before its flops, so it is not straight
    into one (the level's ir and io carry the term; glue is judged on p_io,
    without it). An output is held by its shape, straight from a flop
    (p_ro, without the term): the load past the crossing is the receiving
    block's input net, timed there.

    What this cannot see that the flattened pass could: synthesis across a
    boundary (a constant, an unused output or a duplicated register that
    only the whole would simplify, or a path one module's logic and its
    neighbour's would merge into a shallower tree) -- conservative, as each
    part is timed without that help; and one net's loads as a whole: a
    child's output net is timed in two parts, its loads inside the child by
    the unit and the parent's pins by the level, each its own fanout tree,
    where the whole would take one tree over both: short of it by one INV
    stage at most (ceil(log4(2n/4)) <= ceil(log4(n/4)) + 1). `units` are the measured timing units. Returns (line,
    failures)."""
    inner = sorted(budgets.inner)
    st = cg.Structure("b_" + name, top, files, bbs, params, keep=inner)
    want = block or src_name(top)
    start = next((mn for mn in st.reachable() if src_name(mn) == want), st.top)
    timings = {}
    fails = [msg for _, msg in converge(name, top, files, bbs, budgets, lib, st=st,
                                        start=start, timings=timings)]
    if st.top != start:
        timings[st.top] = time_level(name, st, st.top, level_kids(st, st.top, budgets), lib)
    keyed = ngd_keyed(units)
    found, missing, n = {}, collections.OrderedDict(), [0]

    def walk(mn, cell, path):
        if mn not in (st.top, start) and not src_name(mn).endswith("_w") \
                and not budgets.is_inner(src_name(mn)):
            n[0] += 1
            key = st.key(mn, cell)
            u = cg.find_unit(st, key, keyed)
            if u is None:
                missing.setdefault(key, []).append(path)
            else:
                found[(mn, cell)] = u
        for cn, t in st.cells(mn):
            walk(t, (mn, cn), "%s.%s" % (path, cn) if path else cn)
    walk(st.top, None, "")
    for key, paths in missing.items():
        others = sorted(cg.show_key((None,) + k[:2] + (k[3],)) for _, k in keyed
                        if k[0] == key[1])
        fails.append("block %s: %s, instantiated as %s, has no timing unit at its parameters, "
                     "so its paths and ports are timed nowhere (units time it at: %s)"
                     % (name, cg.show_key(key), ", ".join(paths[:3]) + (
                         " and %d more" % (len(paths) - 3) if len(paths) > 3 else ""),
                        "; ".join(others) or "none"))

    def straight(mn, cell, port, out, path):
        """Why `port` of instance (mn, cell) is not straight from (out) or
        into a flop: [] when it is, or when no unit times it (coverage says
        so)."""
        where = "%s%s" % (path + "." if path else "", port)
        if mn in timings:
            t, why = timings[mn], []
            own = t.p_ro.get(port, NEG) if out else t.ir.get(port, NEG)
            if own > EPS:
                why.append("%s is %.1f NGD %s a flop" % (where, own, "after" if out else
                                                         "before"))
            for (p, q), dl in sorted(t.io.items()):
                if (q if out else p) != port:
                    continue
                o = p if out else q
                if is_clock(p) and not out:
                    continue
                if o not in t.cut:
                    if not is_clock(o):
                        why.append("%s is wired straight %s %s" % (
                            where, "from input" if out else "to output", o))
                    continue
                c, typ, pn, _ = t.cut[o]
                if typ in st.lib or is_clock(pn):
                    continue
                lg = t.p_io[(p, q)]
                if lg > EPS:
                    why.append("%s is %.1f NGD of glue %s %s.%s" % (
                        where, lg, "after" if out else "before", c, pn))
                elif not out and dl > EPS:
                    why.append("%s is fanned out to %d loads on its net, %.1f NGD of fanout "
                               "term before %s.%s" % (where, t.port_fan[p][0], dl, c, pn))
                else:
                    why += straight(typ, (mn, c), pn, out,
                                    "%s.%s" % (path, c) if path else c)
            return why
        u = found.get((mn, cell))
        if u is None:
            return []
        if out:
            v = u.t.p_ro.get(port, NEG)
            thru = any(q == port for (_, q) in u.t.io)
        else:
            v = u.t.ir.get(port, NEG)
            thru = any(p == port for (p, _) in u.t.io)
        why = []
        if v > EPS:
            why.append("%s is %.1f NGD %s a flop in %s (unit %s)" % (
                where, v, "after" if out else "before", src_name(mn), u.name))
        if thru:
            why.append("%s is reached %s a port of %s's (unit %s)" % (
                where, "from" if out else "to", src_name(mn), u.name))
        return why
    t = timings[st.top]
    for o in [o for o in t.outs if o not in t.cut]:
        # Straight from a flop is the netlist's shape: timed without the
        # fanout term, which a flop with more than 4 loads would add.
        why = straight(st.top, None, o, True, "")
        if why:
            fails.append("block %s: output %s is not straight from a flop: %s"
                         % (name, o, "; ".join(why)))
    for i in t.ins:
        if is_clock(i) or i in t.cut:
            continue
        why = straight(st.top, None, i, False, "")
        if why:
            fails.append("block %s: input %s does not go straight into a flop: a crossing "
                         "carries no logic, so it goes straight into a flop, the interface "
                         "module's or, at a no-flop end, the block's own (AR's rev 285 (5)): %s"
                         % (name, i, "; ".join(why)))
    line = ("block %-8s sum of parts: %d level(s) timed alone for convergence, %d of %d "
            "instance(s) on units at their parameters, the boundary held by its parts "
            "(structural read %.1f s)" % (name, len(timings), n[0] - sum(
                len(p) for p in missing.values()), n[0], st.seconds))
    return line, fails


def fanout_caps(units, budgets, ratchet, parents):
    """The seed's caps: {module: {key: cap}} for every finding the plain
    ratchet does not list, each at its depth rounded up to 0.1. A module
    timed by several units (ooe_freelist's gpr and gsec) is capped at its
    worst unit's depth, since policy() holds every unit to the one cap."""
    caps = collections.defaultdict(dict)
    for u in units:
        for key, _ in findings(u, budgets, parents):
            if key in ratchet.get(u.module, []):
                continue
            v = finding_value(u, budgets, key)
            if v is None:
                raise SystemExit("check-ngd: %s %s has no depth to cap; fix it before seeding"
                                 % (u.module, key))
            c = math.ceil(v * 10 - EPS) / 10
            caps[u.module][key] = max(c, caps[u.module].get(key, c))
    return {m: dict(sorted(k.items())) for m, k in sorted(caps.items())}


def seed_fanout(units, budgets, ratchet, modules):
    """--seed-fanout: write the fanout baseline and the ratchet's "fanout"
    from this run's findings that the plain ratchet does not list, each
    capped at its depth rounded up to 0.1. Run once, on the pushed tip, when
    the term was enforced (DA, 2026-11-04); never again."""
    if os.path.exists(FANOUT_BASELINE):
        raise SystemExit("check-ngd: %s exists; the fanout baseline is seeded once"
                         % os.path.relpath(FANOUT_BASELINE, ROOT))
    caps = fanout_caps(units, budgets, ratchet, parented(units, modules))
    git = subprocess.run(["git", "rev-parse", "--short", "HEAD"], cwd=ROOT,
                         capture_output=True, text=True).stdout.strip()
    with open(FANOUT_BASELINE, "w") as f:
        json.dump({"_comment": "The paths over the stage when the fanout term (RA-33) was "
                   "enforced (DA, 2026-11-04), seeded by check-ngd --seed-fanout at %s, each "
                   "capped at its depth. Never edited: rtl/ngd-ratchet.json's \"fanout\" "
                   "holds the caps, which only fall." % git, "modules": caps}, f, indent=2)
        f.write("\n")
    r = json.load(open(RATCHET))
    r["fanout"] = caps
    with open(RATCHET, "w") as f:
        json.dump(r, f, indent=2)
        f.write("\n")
    print("  fanout ratchet seeded: %d path(s) in %d module(s)"
          % (sum(len(v) for v in caps.values()), len(caps)))


def main_check(only=None, seed=False):
    units = load_units()
    modules = design_modules()
    parents = parented(units, modules)
    if only:
        units = [u for u in units if u.name == only]
        if not units:
            raise SystemExit("check-ngd: no unit %s" % only)
    budgets = Budgets.load()
    for u in cg.measured(units, lambda u: u.measure(budgets=budgets, modules=modules),
                         times=cg.last_times("check-ngd")):
        report(u, verbose=bool(only))
    if only:
        for _, msg in findings(units[0], budgets, parents):
            print("    " + msg)
        return 0
    ratchet = load(RATCHET, "modules", {})
    fan = load(RATCHET, "fanout", {})
    fails = policy(units, budgets, ratchet, modules, fan=fan,
                   fan_base=load(FANOUT_BASELINE, "modules", {}))
    if seed:
        seed_fanout(units, budgets, ratchet, modules)
    for mod in sorted(fan):
        print("  fanout ratchet: %-14s %2d path(s) over the stage with the fanout term, "
              "capped: %s" % (mod, len(fan[mod]), ", ".join(
                  "%s %g" % (k, v) for k, v in sorted(fan[mod].items()))))
    for mod in sorted(ratchet):
        n5 = sum(k.startswith("NGD-5") for k in ratchet[mod])
        n6 = sum(k.startswith("NGD-6") for k in ratchet[mod])
        n7 = sum(k.startswith("NGD-7") for k in ratchet[mod])
        print("  ratchet: %-14s %2d port finding(s) awaiting budgets, %2d path(s) straight "
              "through awaiting a redesign%s%s" % (
                  mod, len(ratchet[mod]) - n5 - n6 - n7, n5,
                  ", %d helper path(s) awaiting a parent" % n6 if n6 else "",
                  ", %d register(s) shared by an output awaiting a copy" % n7 if n7 else ""))
    inner = sorted(m for m in budgets.inner if any(u.module == m for u in units))
    if inner:
        print("  inner helpers: %s" % ", ".join(
            "%s inside its parent" % m if m in parents else
            "%s alone, within %g (no module instantiates it yet)" % (m, INNER) for m in inner))
    parts = cg.partitions(cg.design_modules())
    for name, top, files, bbs in parts:
        line, more = block_check(name, top, files, bbs, budgets, units, block="ccv_%s" % name)
        print("  " + line)
        fails += more
    if not parts:
        print("  blocks: none assembled yet (every block top is a generated stub)")
    more, over = cg.heavy_check("check-ngd")
    for l in more + cg.time_lines():
        print("  " + l)
    cg.save_times("check-ngd")
    fails += over
    print("  %d unit(s), %d port budget(s) in %d module file(s), stage %g NGD, ports %g by "
          "default" % (len(units), len(budgets.e), len(budgets.files), STAGE, PORT))
    for f in fails:
        sys.stderr.write("check-ngd: %s\n" % f)
    return 1 if fails else 0


# == The negative controls =====================================================

def fixture(name, module, files=None):
    return Unit({"name": name, "module": module,
                 "files": files or ["%s/%s.sv" % (FIX, module)]}, "selftest")


def selftest():
    bad, checks = [], 0

    def expect(cond, what):
        nonlocal checks
        checks += 1
        if not cond:
            bad.append(what)

    fx = {m: fixture("fx_" + m[7:], m) for m in
          ("ngd_fx_ok", "ngd_fx_out", "ngd_fx_in", "ngd_fx_thru", "ngd_fx_stage",
           "ngd_fx_wire", "ngd_fx_relax")}
    for u in fx.values():
        u.measure()
    none = Budgets()

    def keys(u, b=none):
        return {k for k, _ in findings(u, b)}

    # 1. The timing pass agrees with ABC on every fixture (map_and_time
    #    stops otherwise), and a wrong delay table is caught.
    wrong = dict(LIB, NAND2={p: d * 2 for p, d in LIB["NAND2"].items()})
    try:
        u = fixture("fx_wrong", "ngd_fx_stage")
        u.measure(lib=wrong)
        expect(False, "a timing pass with a wrong NAND2 delay agreed with ABC")
    except SystemExit as e:
        expect("is not ABC's" in str(e), "a wrong delay table stopped the run otherwise: %s" % e)
    # 1c. The timing pass is per pin: ngd_fx_xor3's tree maps onto XOR3, whose
    #     last select C is fast, and agrees with ABC; timed again with every
    #     gate at its slowest pin, it must not.
    x3 = fixture("fx_xor3", "ngd_fx_xor3")
    x3.measure()
    expect(x3.t.gates.get("XOR3", 0) + x3.t.gates.get("XNOR3", 0) > 0,
           "ngd_fx_xor3 maps onto no XOR3 or XNOR3, so 1c tests nothing: %s" % dict(x3.t.gates))
    slow = {g: {"*": max(d.values())} if d else d for g, d in LIB.items()}
    try:
        fixture("fx_xor3_slow", "ngd_fx_xor3").measure(lib=slow)
        expect(False, "ngd_fx_xor3 timed at each gate's slowest pin agreed with ABC")
    except SystemExit as e:
        expect("is not ABC's" in str(e), "the slowest-pin table stopped the run otherwise: %s" % e)
    # 1d. The fanout term (RA-33; DA, 2026-11-02): ngd_fx_fanout's select
    #     flop drives 1,024 loads, so its paths gain ceil(log4(1024/4)) = 4
    #     inverter stages; a fixture with no net past fanout 4 gains nothing.
    ff = fixture("fx_fanout", "ngd_fx_fanout")
    ff.measure()
    inv = delay(LIB, "INV", "A")
    expect(ff.t.fanout_max >= 1024, "ngd_fx_fanout's widest net has %d loads, not 1,024: 1d "
           "tests nothing" % ff.t.fanout_max)
    expect(ff.t.rr >= ff.t.p_rr + 4 * inv - EPS,
           "1,024 loads cost %.2f NGD flop to flop with the fanout term, against %.2f without: "
           "want 4 inverter stages (%.2f) more" % (ff.t.rr, ff.t.p_rr, 4 * inv))
    ok = fx["ngd_fx_ok"].t
    expect(ok.fanout_max > 4 or abs(ok.rr - ok.p_rr) < EPS,
           "ngd_fx_ok has no net past fanout 4, yet the fanout term moved it (%.2f, %.2f)"
           % (ok.rr, ok.p_rr))
    # 1b. NGD-3 takes each input from the better of two maps (OI-64): area
    #     recovery relaxes ngd_fx_relax's 8-bit add toward its multiplier, so
    #     the area map alone would put input i over the stage at the default
    #     arrival; map -r keeps it within. And NGD-3 is the shorter of the two,
    #     for every input of every fixture.
    rx = fx["ngd_fx_relax"].t
    expect(rx.ir_area["i"] + (STAGE - PORT) > STAGE + EPS
           and rx.ir["i"] + (STAGE - PORT) <= STAGE + EPS,
           "ngd_fx_relax no longer shows area recovery's relaxed input (area %.1f, -r %.1f)"
           % (rx.ir_area["i"], rx.ir_r.get("i", NEG)))
    expect("NGD-3 i" not in keys(fx["ngd_fx_relax"]),
           "NGD-3 took input i from the area-recovered map: %s"
           % findings(fx["ngd_fx_relax"], none))
    expect(all(u.t.ir[p] == min(u.t.ir_area[p], u.t.ir_r.get(p, u.t.ir_area[p]))
               for u in fx.values() for p in u.t.ir),
           "an input's NGD-3 depth is not the shorter of its two maps")
    #     NGD-7 the same, per register, wherever map -r is no worse flop to
    #     flop; and the area map's alone wherever it is worse.
    wrong = []
    for u in fx.values():
        t = u.t
        rbetter = t.rr_r <= t.rr + EPS
        for q, v in t.q_flop.items():
            a, r = t.q_flop_area[q], t.q_flop_r.get(q, t.q_flop_area[q])
            if v != (min(a, r) if rbetter else a):
                wrong.append("%s %s: %.2f (area %.2f, -r %.2f%s)" % (
                    u.name, q, v, a, r, "" if rbetter else ", -r worse flop to flop"))
    expect(not wrong, "a register's NGD-7 depth is not the rule's: %s" % "; ".join(wrong[:3]))
    #     NGD-2 the same, per output (OI-68).
    wrong = []
    for u in fx.values():
        t = u.t
        rbetter = t.rr_r <= t.rr + EPS
        for o, v in t.ro.items():
            a, r = t.ro_area[o], t.ro_r.get(o, t.ro_area[o])
            if v != (min(a, r) if rbetter else a):
                wrong.append("%s %s: %.2f (area %.2f, -r %.2f%s)" % (
                    u.name, o, v, a, r, "" if rbetter else ", -r worse flop to flop"))
    expect(not wrong, "an output's NGD-2 ready time is not the rule's: %s" % "; ".join(wrong[:3]))
    # 2. Within every default: nothing. An input wired straight to an
    #    output, timed as a wire, is still NGD-5 (Daniel, 2026-10-18).
    ok = fx["ngd_fx_ok"]
    expect(not keys(ok), "the compliant fixture has findings: %s" % findings(ok, none))
    wire = fx["ngd_fx_wire"]
    expect(wire.t.io.get(("w", "z"), NEG) == 0.0,
           "a wire straight through was not timed as a wire: %s" % wire.t.io.get(("w", "z")))
    expect(keys(wire) == {"NGD-5 w>z"}, "a wire straight through passed, or more was found: "
           "%s" % findings(wire, none))
    # 3. An output its flops reach too late (NGD-2), an input that reaches
    #    a flop too late (NGD-3), flop to flop over the stage (NGD-1).
    expect("NGD-2 y" in keys(fx["ngd_fx_out"]), "a deep output passed: %.1f"
           % fx["ngd_fx_out"].t.ro.get("y", NEG))
    expect(not any(k.startswith("NGD-7") for k in keys(fx["ngd_fx_out"])),
           "a deep output was NGD-7's too: %s" % findings(fx["ngd_fx_out"], none))
    expect("NGD-3 a" in keys(fx["ngd_fx_in"]), "a deep input passed: %.1f"
           % fx["ngd_fx_in"].t.ir.get("a", NEG))
    expect("NGD-1" in keys(fx["ngd_fx_stage"]), "a path over the stage passed: %.1f"
           % fx["ngd_fx_stage"].t.rr)
    # 4. Logic straight through a module (NGD-5), refused on defaults and
    #    with budgets that would converge over it (ngd_fx_thru.ngd.json: a
    #    at 6, y by 18); exempt when the module is an inner helper, or the
    #    output an observation port.
    thru = fx["ngd_fx_thru"]
    expect({"NGD-5 a>y", "NGD-5 b>y"} <= keys(thru), "a path straight through passed: %s"
           % findings(thru, none))
    tf = os.path.join(ROOT, FIX, "ngd_fx_thru.ngd.json")
    b = Budgets([tf])
    thru_mods = {"ngd_fx_thru": "f"}
    expect("NGD-5 a>y" in keys(thru, b) and not b.check([thru], thru_mods),
           "port budgets cleared a path straight through: %s %s"
           % (findings(thru, b), b.check([thru], thru_mods)))
    sig = {"by": "selftest", "date": "2026-10-18", "why": "control"}
    b = Budgets(inner={"ngd_fx_thru": dict(sig)})
    expect(not keys(thru, b) and not b.check([thru], thru_mods),
           "an inner helper was held to its ports: %s %s"
           % (findings(thru, b), b.check([thru], thru_mods)))
    b = Budgets(extra={("ngd_fx_thru", "y"): dict(sig, observation=True)})
    expect(not keys(thru, b) and not b.check([thru], thru_mods),
           "a path to an observation port was refused: %s %s"
           % (findings(thru, b), b.check([thru], thru_mods)))
    #    An inner helper no module instantiates is held alone to
    #    CCV_NGD_INNER, not the stage (NGD-6): a 6 by 6 multiply, between
    #    the two, is refused alone, through the policy too, and passes once a
    #    parent puts it between two of its flops. (The one-gate helper above
    #    passed alone.)
    hf = ["%s/ngd_fx_helper.sv" % FIX]
    hlp, par = fixture("fx_helper", "ngd_fx_helper", hf), fixture("fx_hpar",
                                                                 "ngd_fx_helper_par", hf)
    hb = Budgets(inner={"ngd_fx_helper": dict(sig)})
    hmods = {"ngd_fx_helper": "f", "ngd_fx_helper_par": "f"}
    hlp.measure()
    par.measure(budgets=hb, modules=hmods)
    d = max(hlp.t.io.values())
    expect(INNER + EPS < d < STAGE and par.t.rr < STAGE,
           "the helper fixture is not between CCV_NGD_INNER and the stage: %.1f, %.1f in its "
           "parent" % (d, par.t.rr))
    k = keys(hlp, hb)
    expect(k and all(x.startswith("NGD-6") for x in k),
           "an inner helper over CCV_NGD_INNER, which no module instantiates, passed: %s" % k)
    hp = parented([hlp, par], hmods)
    expect(hp == {"ngd_fx_helper"}, "the helper's parent was not found: %s" % hp)
    expect(not {x for x, _ in findings(hlp, hb, hp)} and not keys(par, hb),
           "an inner helper inside its parent's stage was refused: %s %s"
           % (findings(hlp, hb, hp), findings(par, hb)))
    f = policy([hlp], hb, {}, {"ngd_fx_helper": "f"}, set())
    expect(any(x.startswith("NGD-6 ngd_fx_helper") for x in f),
           "the policy passed an inner helper over CCV_NGD_INNER alone: %s" % f)
    f = policy([hlp, par], hb, {}, hmods, set())
    expect(not f, "the policy held an inner helper inside its parent to CCV_NGD_INNER: %s" % f)
    #    A register that drives an output is held, on every path it starts,
    #    to that output's required time (NGD-7, Daniel, 2026-10-19). a_q
    #    drives y and w and, 15.9 NGD away, the flop p_q: refused, by its RTL
    #    name; passing with y and w required at 18, not with y alone (w's 12
    #    holds); passing with both observation ports. Split into two copies
    #    each (* keep *), it passes; split bare, synthesis merges them and it
    #    is refused. A flop whose only long path is to an output over its own
    #    budget is NGD-2's alone (ngd_fx_out, above).
    sf = ["%s/ngd_fx_shared.sv" % FIX]
    sh, sp, sb = (fixture("fx_" + m[7:], m, sf) for m in
                  ("ngd_fx_shared", "ngd_fx_split", "ngd_fx_split_bare"))
    for x in (sh, sp, sb):
        x.measure()
    expect(keys(sh) == {"NGD-7 a_q"}, "a register driving an output and a flop 15.9 NGD away "
           "passed, or was not named for its register: %s" % findings(sh, none))
    v7 = finding_value(sh, none, "NGD-7 a_q")
    expect(v7 is not None and v7 > PORT, "NGD-7 a_q has no depth for the fanout ratchet to cap: "
           "%s" % v7)
    req = dict(sig, required=18)
    late = {("ngd_fx_shared", p): dict(req) for p in ("y", "w")}
    expect("NGD-7 a_q" not in keys(sh, Budgets(extra=late)),
           "a register was held under its outputs' required times: %s"
           % findings(sh, Budgets(extra=late)))
    one = Budgets(extra={("ngd_fx_shared", "y"): dict(req)})
    expect("NGD-7 a_q" in keys(sh, one),
           "a register driving two outputs was held to the looser one: %s" % findings(sh, one))
    obs = Budgets(extra={("ngd_fx_shared", p): dict(sig, observation=True) for p in ("y", "w")})
    expect("NGD-7 a_q" not in keys(sh, obs),
           "a register driving only observation ports was held to them: %s" % findings(sh, obs))
    expect(not keys(sp) and sp.t.nflops > sh.t.nflops,
           "a register split into two (* keep *) copies was refused, or merged: %s, %d flops"
           % (findings(sp, none), sp.t.nflops))
    expect(keys(sb) == {"NGD-7 a_q"} and sb.t.nflops == sh.t.nflops,
           "copies not marked (* keep *) were not merged back and refused: %s, %d flops"
           % (findings(sb, none), sb.t.nflops))
    # 5. Budget files refused: one whose module is not its file name's, one
    #    for a module that is not a design module, an entry on a port the
    #    module lacks, an entry naming both an arrival and a required time,
    #    an entry with no why.
    work = os.path.join(BUILD, "fx_budgets")
    os.makedirs(work, exist_ok=True)

    def bfile(fname, d):
        path = os.path.join(work, fname)
        json.dump(d, open(path, "w"))
        return Budgets([path]).check([thru], thru_mods)

    good = json.load(open(tf))
    expect(any("not its file name" in x for x in bfile("ngd_fx_other.ngd.json", good)),
           "a budget file named for another module was accepted")
    expect(any("not a design module" in x for x in
               bfile("ngd_fx_gone.ngd.json", dict(good, module="ngd_fx_gone"))),
           "a budget file for a module that does not exist was accepted")
    entry = dict(good["ports"]["a"])
    expect(any("has no input port" in x for x in
               bfile("ngd_fx_thru.ngd.json", dict(good, ports={"nope": entry}))),
           "a budget for a port the module lacks was accepted")
    expect(any("not exactly one of" in x for x in
               bfile("ngd_fx_thru.ngd.json", dict(good, ports={"a": dict(entry, required=9)}))),
           "a budget naming both an arrival and a required time was accepted")
    entry_nowhy = {k: v for k, v in entry.items() if k != "why"}
    expect(any("no why" in x for x in
               bfile("ngd_fx_thru.ngd.json", dict(good, ports={"a": entry_nowhy}))),
           "a budget with no why was accepted")
    expect(any("observation is true" in x for x in
               bfile("ngd_fx_thru.ngd.json", dict(good, ports={"y": dict(sig, observation=1)}))),
           "an observation entry not true was accepted")
    #    And inner helpers refused: one with port budgets, one with flops,
    #    one with no why.
    expect(any("has no port budgets" in x for x in
               bfile("ngd_fx_thru.ngd.json", dict(good, inner=True, **sig))),
           "an inner helper with port budgets was accepted")
    f = Budgets(inner={"ngd_fx_ok": dict(sig)}).check([ok], {"ngd_fx_ok": "f"})
    expect(any("has flops" in x for x in f), "an inner helper with flops was accepted: %s" % f)
    f = Budgets(inner={"ngd_fx_thru": {"by": "selftest", "date": "2026-10-18"}}).check(
        [thru], thru_mods)
    expect(any("with no why" in x for x in f), "an inner helper with no why was accepted")
    # 6. The ratchet: a listed finding excused; one that now passes, or one
    #    outside the baseline, refused; a module with no unit, refused.
    us = [fx["ngd_fx_out"], fx["ngd_fx_ok"]]
    mods = {"ngd_fx_out": "f", "ngd_fx_ok": "f"}
    base = {("ngd_fx_out", "NGD-2 y"), ("ngd_fx_ok", "NGD-2 y")}
    fails = policy(us, none, {"ngd_fx_out": ["NGD-2 y"]}, mods, base)
    expect(not fails, "a ratcheted finding was not excused: %s" % fails)
    fails = policy(us, none, {"ngd_fx_ok": ["NGD-2 y"]}, mods, base)
    expect(any("now meets the rule" in x for x in fails),
           "a ratchet entry that passes stayed on the list")
    fails = policy(us, none, {"ngd_fx_out": ["NGD-2 y"]}, mods, set())
    expect(any("only shrinks" in x for x in fails), "the ratchet grew")
    fails = policy(us, none, {}, dict(mods, ngd_fx_lost="f"), base)
    expect(any("ngd_fx_lost" in x and "no timing unit" in x for x in fails),
           "a module with no unit passed")
    # 6b. The fanout ratchet (RA-33; DA, 2026-11-04): a finding at or under
    #     its cap excused; one over it refused; a cap above its baseline, one
    #     not in the baseline, or one on a path that now meets the rule,
    #     refused.
    y = finding_value(fx["ngd_fx_out"], none, "NGD-2 y")
    expect(y is not None and y > PORT, "ngd_fx_out's NGD-2 y has no depth to cap: %s" % y)
    fb = {"ngd_fx_out": {"NGD-2 y": y + 1}, "ngd_fx_ok": {"NGD-2 y": y}}
    fails = policy(us, none, {}, mods, base, {"ngd_fx_out": {"NGD-2 y": y}}, fb)
    expect(not fails, "a finding at its fanout cap was not excused: %s" % fails)
    fails = policy(us, none, {}, mods, base, {"ngd_fx_out": {"NGD-2 y": y - 0.5}}, fb)
    expect(any("fanout ratchet cap" in x for x in fails),
           "a finding over its fanout cap was excused")
    fails = policy(us, none, {}, mods, base, {"ngd_fx_out": {"NGD-2 y": y + 2}}, fb)
    expect(any("above its baseline" in x for x in fails), "a fanout cap rose past its baseline")
    fails = policy(us, none, {}, mods, base, {"ngd_fx_out": {"NGD-2 y": y}}, {})
    expect(any("the list only shrinks" in x for x in fails), "the fanout ratchet grew")
    fails = policy(us, none, {}, mods, base, {"ngd_fx_out": {"NGD-2 y": y},
                                              "ngd_fx_ok": {"NGD-2 y": y}}, fb)
    expect(any("ngd_fx_ok" in x and "now meets the rule" in x for x in fails),
           "a fanout ratchet entry that passes stayed on the list")
    #     A module timed by two units is seeded at the deeper one's depth,
    #     whichever unit comes first, and that cap excuses both.
    deep = copy.copy(fx["ngd_fx_out"])
    deep.t = copy.copy(deep.t)
    deep.t.ro = dict(deep.t.ro, y=y + 3)
    pair = [deep, fx["ngd_fx_out"]]
    for order in (pair, pair[::-1]):
        c = fanout_caps(order, none, {}, {}).get("ngd_fx_out", {}).get("NGD-2 y")
        expect(c is not None and c >= y + 3 - EPS,
               "a module with two units was seeded at the shallower one's depth: %s" % c)
    c = fanout_caps(pair, none, {}, {})
    fails = policy(pair + [u for u in us if u.module != "ngd_fx_out"], none, {}, mods, base,
                   c, c)
    expect(not any("fanout ratchet cap" in x for x in fails),
           "a two-unit module's seed did not excuse both units: %s" % fails)
    # 7. The assembled block from its budget files, level by level: a
    #    driver required at 14 straight into a receiver arriving at 15
    #    converges; with the driver's budget moved to 16 it does not. Logic
    #    between the two children, touching no flop of the parent's, is
    #    refused (NGD-5), the parent's own or an inner helper's; an inner
    #    helper before the parent's flop is the parent's logic, and passes,
    #    where cut out at its default ports it would not.
    files = ["%s/ngd_fx_blk.sv" % FIX]
    bfiles = [os.path.join(ROOT, FIX, "ngd_fx_%s.ngd.json" % m) for m in ("bsrc", "bdst")]
    fb = Budgets(bfiles)
    fi = Budgets(bfiles + [os.path.join(ROOT, FIX, "ngd_fx_inner.ngd.json")])

    def msgs(f):
        return [m for _, m in f]
    f = msgs(converge("fx_asm_ok", "ngd_fx_asm_ok", files, [], fb))
    expect(not f, "budgets that converge were refused: %s" % f)
    late = Budgets(extra={("ngd_fx_bsrc", "y"): dict(fb.e[("ngd_fx_bsrc", "y")], required=16),
                          ("ngd_fx_bdst", "a"): fb.e[("ngd_fx_bdst", "a")]})
    f = msgs(converge("fx_asm_late", "ngd_fx_asm_ok", files, [], late))
    expect(any("do not converge" in x for x in f),
           "a driver required after its receiver's arrival passed: %s" % f)
    #    The parent's wire carries the fanout term on its own net's pins
    #    (RA-33): budgets that meet exactly, a driver required at 15 into
    #    receivers arriving at 15, converge with 4 receivers on the net and
    #    not with 8, one INV stage past FO4.
    exact = Budgets(extra={("ngd_fx_bsrc", "y"): dict(fb.e[("ngd_fx_bsrc", "y")], required=15),
                           ("ngd_fx_bdst", "a"): dict(fb.e[("ngd_fx_bdst", "a")], arrival=15)})
    f = msgs(converge("fx_asm_fan4", "ngd_fx_asm_fan", files, [], exact, params={"N": 4}))
    expect(not f, "a wire to 4 receivers, budgets meeting exactly, was refused: %s" % f)
    f = msgs(converge("fx_asm_fan8", "ngd_fx_asm_fan", files, [], exact, params={"N": 8}))
    expect(any("do not converge" in x and "fanout term for the 8 loads" in x for x in f)
           and not any(x.startswith("NGD-5") for x in f),
           "a child's output fanned out to 8 receivers on the parent's net, its budgets "
           "meeting exactly, converged, or was called glue: %s" % f)
    f = msgs(converge("fx_asm_gap", "ngd_fx_asm_gap", files, [], fb))
    expect(any(x.startswith("NGD-5") and "u_src.y to u_dst.a" in x for x in f),
           "glue between two children passed: %s" % f)
    f = msgs(converge("fx_asm_igap", "ngd_fx_asm_inner_gap", files, [], fi))
    expect(any(x.startswith("NGD-5") and "u_src.y to u_dst.a" in x for x in f),
           "an inner helper between two children passed: %s" % f)
    f = msgs(converge("fx_asm_inner", "ngd_fx_asm_inner", files, [], fi))
    expect(not f, "an inner helper before its parent's flop was refused: %s" % f)
    # A parameterised helper's copy carries a hashed name, $paramod$<sha1>
    # \<module>, when its parameter string is long (OI-69): flattened too.
    fp = Budgets(bfiles + [os.path.join(ROOT, FIX, "ngd_fx_pinner.ngd.json")])
    f = msgs(converge("fx_asm_pinner", "ngd_fx_asm_pinner", files, [], fp))
    expect(not f, "a parameterised inner helper was cut out at its ports: %s" % f)
    f = msgs(converge("fx_asm_cut", "ngd_fx_asm_inner", files, [], fb))
    expect(any("do not converge" in x and "u_inn.a" in x for x in f),
           "a helper not declared inner was not cut out at its ports: %s" % f)
    #    A unit's own level is checked the same way, for the ratchet: glue
    #    in a module with children is its finding, keyed by the pins.
    blk = {m: "f" for m in ("ngd_fx_bsrc", "ngd_fx_bdst", "ngd_fx_inner", "ngd_fx_asm_gap",
                            "ngd_fx_asm_inner")}
    u = fixture("fx_ugap", "ngd_fx_asm_gap", files)
    u.measure(budgets=fb, modules=blk)
    expect("NGD-5 u_src.y>u_dst.a" in keys(u, fb), "a unit's glue passed: %s" % u.h)
    u = fixture("fx_uinner", "ngd_fx_asm_inner", files)
    u.measure(budgets=fi, modules=blk)
    expect(not keys(u, fi), "a unit with only an inner helper inside had findings: %s"
           % findings(u, fi))
    # 8. The assembled block as a sum of parts (Daniel, 2026-11-06): no
    #    whole-block pass, so each control the flattened pass held is held
    #    by the parts. Each child is measured by a unit at the parameters
    #    the block gives it.
    def funit(n, mod, params):
        x = fixture(n, mod, files)
        x.spec["params"] = params
        x.measure()
        return x
    src2, dst2 = funit("fx_src2", "ngd_fx_src", {"W": 2}), funit("fx_dst2", "ngd_fx_dst", {"W": 2})
    src8, dst8 = funit("fx_src8", "ngd_fx_src", {"W": 8}), funit("fx_dst8", "ngd_fx_dst", {"W": 8})
    _, f = block_check("fx_ok", "ngd_fx_blk_ok", files, [], none, [src2, dst2])
    expect(not f, "a compliant assembled block failed: %s" % f)
    #    Flop to flop over the stage across two modules (two 8-bit
    #    multiplies in series): the flattened pass timed it whole; by parts,
    #    each unit is over its default port (NGD-2 on y, NGD-3 on a), and
    #    with budgets that let each unit pass alone, the block's budgets do
    #    not converge. Either way it fails.
    expect("NGD-2 y" in keys(src8) and "NGD-3 a" in keys(dst8),
           "8-bit multiplies at default ports passed their units: %s, %s"
           % (keys(src8), keys(dst8)))
    ro_y, ir_a = src8.t.ro["y"], dst8.t.ir["a"]
    why = {"by": "selftest", "date": "2026-11-06", "why": "control"}
    loose = Budgets(extra={("ngd_fx_src", "y"): dict(why, required=math.ceil(ro_y * 10) / 10),
                           ("ngd_fx_dst", "a"): dict(why, arrival=math.floor(
                               (STAGE - ir_a) * 10) / 10)})
    _, f = block_check("fx_long", "ngd_fx_blk_long", files, [], loose, [src8, dst8])
    expect(not {"NGD-2 y", "NGD-3 a"} & (keys(src8, loose) | keys(dst8, loose))
           and any("block fx_long" in x and "do not converge" in x and "u_src.y" in x
                   for x in f),
           "a path over the stage across two modules, %.1f + %.1f NGD, passed with budgets "
           "each unit meets: %s" % (ro_y, ir_a, f))
    _, f = block_check("fx_comb", "ngd_fx_blk_comb", files, [], none, [])
    expect(any("output o is not straight from a flop" in x for x in f),
           "a block output driven through logic passed: %s" % f)
    _, f = block_check("fx_deep_in", "ngd_fx_blk_deepin", files, [], none, [])
    expect(any("input i" in x and "carries no logic" in x for x in f),
           "a block input deep before its flop passed: %s" % f)
    _, f = block_check("fx_one_in", "ngd_fx_blk_onein", files, [], none, [])
    expect(any("input i" in x and "carries no logic" in x for x in f),
           "a block input one gate before its flop passed (within the old 12-NGD port "
           "budget, not within a crossing): %s" % f)
    #    The boundary through a child: an output wired from a child's pin
    #    that is logic after the child's flops fails, by the child's unit;
    #    so does an input wired into a child's pin that is logic before its
    #    flop. (fx_ok's output, wired from u_dst.q, a flop, passes.)
    _, f = block_check("fx_kidout", "ngd_fx_blk_kidout", files, [], none, [src2])
    expect(any("output o is not straight from a flop" in x and "u_src.y" in x
               and "unit fx_src2" in x for x in f),
           "a block output wired from a child's pin after logic passed: %s" % f)
    _, f = block_check("fx_kidin", "ngd_fx_blk_kidin", files, [], none, [dst2])
    expect(any("input i" in x and "u_dst.a" in x and "unit fx_dst2" in x for x in f),
           "a block input wired into a child's pin before logic passed: %s" % f)
    #    The fanout term holds at the boundary too: an input wired straight
    #    into 8 children's flops is a buffer tree before them, not straight
    #    into one; into 4 it passes.
    reg = funit("fx_reg", "ngd_fx_reg", {})
    _, f = block_check("fx_fanin4", "ngd_fx_blk_fanin", files, [], none, [reg], params={"N": 4})
    expect(not f, "an input wired straight into 4 children's flops was refused: %s" % f)
    _, f = block_check("fx_fanin8", "ngd_fx_blk_fanin", files, [], none, [reg], params={"N": 8})
    expect(any("input i" in x and "fanned out to 8 loads" in x for x in f),
           "an input fanned out to 8 children's flops on the parent's net passed as "
           "straight into a flop: %s" % f)
    #    Coverage: an instance no unit times at its parameters fails, naming
    #    the module and the parameters (here, units at W=8 only).
    _, f = block_check("fx_ok_nou", "ngd_fx_blk_ok", files, [], none, [src8, dst8])
    expect(any("ngd_fx_src #(W=2)" in x and "no timing unit at its parameters" in x
               and "W=8" in x for x in f)
           and any("ngd_fx_dst #(W=2)" in x for x in f),
           "a block instance at parameters no unit times passed: %s" % f)
    #    No child is synthesised: a child with a combinational loop, which
    #    the strict Yosys refuses to synthesise (OI-44), under a parent timed
    #    alone; the same hierarchy synthesised with its children kept, as
    #    converge did before, fails.
    lf = ["%s/ngd_fx_loopkid.sv" % FIX]
    del TIMED_ALONE[:]
    try:
        f = msgs(converge("fx_loopkid", "ngd_fx_blk_loopkid", lf, [], none))
        timed = [src_name(m) for m in TIMED_ALONE]
    except SystemExit as e:
        f, timed = ["converge failed: %s" % str(e)[-300:]], None
    r = run(["yosys", "-q", "-p", "; ".join(cg.read_cmds(lf) + [
        "hierarchy -top ngd_fx_blk_loopkid", "setattr -mod -set keep_hierarchy 1 *",
        "synth -top ngd_fx_blk_loopkid"])])
    expect(not f and timed == ["ngd_fx_blk_loopkid"] and r.returncode != 0,
           "a level's child was synthesised, or the looped child synthesises: converge %s, "
           "levels synthesised %s, whole synthesis exit %d" % (f, timed, r.returncode))
    # 9. ABC's cache (OI-95) misses on every input it reads: the netlist,
    #    the genlib's contents behind the same path, and the script; and a
    #    hit hands back the report and netlist the run wrote.
    #    Against a cache of its own, empty at the start: the gate's may keep
    #    these entries from an earlier run (OI-97).
    cdir = os.path.join(BUILD, "fixture", "abc_cache")
    ccache = os.path.join(cdir, "cache")
    __import__("shutil").rmtree(ccache, ignore_errors=True)
    os.makedirs(cdir, exist_ok=True)
    nb, lib2 = os.path.join(cdir, "t.blif"), os.path.join(cdir, "lib.genlib")
    def blif_of(body):
        with open(nb, "w") as fh:
            fh.write(".model t\n.inputs a b c\n.outputs y\n%s.end\n" % body)
    def abc_delay(how, lib):
        o = os.path.join(cdir, "o.blif")
        if os.path.exists(o):
            os.remove(o)
        r = abc_cached("read_blif %s; read_library %s; strash; %s; print_stats; write_blif %s"
                       % (nb, lib, how, o), nb, o, genlib=lib, cache=ccache)
        m = re.search(r"delay\s*=\s*([\d.]+)", r.stdout)
        return (float(m.group(1)) if m else None), os.path.exists(o)
    shutil_ = __import__("shutil")
    shutil_.copyfile(GENLIB, lib2)
    blif_of(".names a b x\n11 1\n.names x c y\n11 1\n")
    d1, o1 = abc_delay("map", lib2)
    d1b, o1b = abc_delay("map", lib2)
    expect(d1 is not None and o1 and (d1b, o1b) == (d1, o1),
           "an ABC cache hit did not hand back the run's report and netlist (%s, %s)" % (d1, d1b))
    blif_of(".names a b y\n11 1\n")
    d2, _ = abc_delay("map", lib2)
    expect(d2 is not None and d2 < d1, "the ABC cache handed back a map after its netlist "
           "changed (%s then %s)" % (d1, d2))
    blif_of(".names a b x\n11 1\n.names x c y\n11 1\n")
    txt = open(lib2).read()
    with open(lib2, "w") as fh:
        fh.write(re.sub(r"(PIN\s+\S+\s+\S+\s+\S+\s+\S+\s+)([\d.]+)(\s+\S+\s+)([\d.]+)",
                        lambda m: "%s%g%s%g" % (m.group(1), float(m.group(2)) * 3, m.group(3),
                                                float(m.group(4)) * 3), txt))
    d3, _ = abc_delay("map", lib2)
    expect(d3 is not None and d3 > d1, "the ABC cache handed back a map after the genlib "
           "behind its path changed (%s then %s)" % (d1, d3))
    n0 = len(glob.glob(os.path.join(ccache, "abc-*.blif")))
    abc_delay("map -r", lib2)
    expect(len(glob.glob(os.path.join(ccache, "abc-*.blif"))) == n0 + 1,
           "the ABC cache keyed map -r as map")
    for x in bad:
        sys.stderr.write("check-ngd selftest: %s\n" % x)
    if not bad:
        print("  timing pass against ABC, outputs, inputs, the stage, paths straight through, "
              "inner helpers alone and inside a parent, registers shared by an output and the "
              "rest, observation ports, budget files, ratchet, coverage, glue, the assembled "
              "block as a sum of parts, ABC's cache, the fanout term (%d controls)"
              % checks)
    return 1 if bad else 0


def main():
    ap = argparse.ArgumentParser()
    ap.add_argument("--selftest", action="store_true")
    ap.add_argument("--unit")
    ap.add_argument("--seed-fanout", action="store_true",
                    help="write the fanout baseline and ratchet from this run (once)")
    a = ap.parse_args()
    os.makedirs(BUILD, exist_ok=True)
    if a.selftest:
        return selftest()
    return main_check(a.unit, a.seed_fanout)


if __name__ == "__main__":
    sys.exit(main())
