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
         plan a port that fits them. A path straight through a module, input
         to output, fits no default: like a port over 12, it needs explicit
         budgets from the architect, kept beside the module's RTL in
         <module>.ngd.json, one consistent format for every module.
  BLOCK  Once a block top is RTL, the assembled block is checked twice.
         First from the budget files: each level of its hierarchy is timed
         with its children cut out at their budgets, so every connection,
         and any glue between children, must converge (a driver's required
         time no later than its receiver's arrival, glue included). Then
         timed whole, flattened, every flop-to-flop path within the stage,
         for the corner cases where synthesis did across a boundary what it
         could not module by module. And its boundary is registered on both
         sides: every output straight from a flop, every input into its
         flops within the default port budget.

Each module is measured at the parameters of its units (test/**/cg-units.json,
and test/**/ngd-units.json for modules with no flops): Yosys synthesises it
flattened, every clock-gated flop becomes a plain flop on its next value (its
enable is timed apart, to its ICG, by check-cg's CG-2), and ABC maps it onto
test/ooe/ngd.genlib, as test/ooe/depth.sh does. A timing pass over the mapped
netlist then splits the depth by where a path starts and ends: input or flop,
output or flop. Its longest path must equal ABC's own, or the run stops.

The rules, as findings:
  NGD-1  flop to flop over the stage
  NGD-2  an output reached later than its required time (from flops, or from
         an input at its arrival)
  NGD-3  an input that, from its arrival, reaches a flop over the stage
  NGD-4  a budget file that is malformed, or names a port its module lacks

Modules that broke a default when the rule was made sit on
rtl/ngd-ratchet.json, awaiting budgets from OA or a redesign; the list only
shrinks.

  tools/check-ngd.py              every unit, the ratchet and the blocks
  tools/check-ngd.py --unit NAME  one unit, with its ports
  tools/check-ngd.py --selftest   the negative controls
"""
import argparse
import collections
import glob
import importlib.util
import json
import os
import re
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
GENLIB = cg.GENLIB
BUDGET_GLOB = os.path.join(ROOT, "rtl", "**", "*.ngd.json")
RATCHET = os.path.join(ROOT, "rtl", "ngd-ratchet.json")
# The findings that stood when the rule was made (2026-10-17), ooe_rat's
# then on OI's branch (b9c3a44). Never add to this: a module written since
# meets the defaults or has the architect's budgets.
RATCHET_BASELINE = {(m, k) for m, ks in {
    "ooe_confirm": [
        "NGD-2 conf_cq01h", "NGD-2 replay_cq02h",
    ],
    "ooe_decq": [
        "NGD-2 head_pay_cq02h", "NGD-2 used_cq02h", "NGD-3 deq_n_cq01h",
        "NGD-3 enq_slot_cq01h", "NGD-3 enq_v_cq01h", "NGD-3 flush_cq01h",
    ],
    "ooe_freelist": [
        "NGD-2 alloc_idx_cq02h", "NGD-2 alloc_v_cq02h", "NGD-3 alloc_req_cq01h",
    ],
    "ooe_pick": [
        "NGD-2 issue_cq03h", "NGD-2 lost_cq03h", "NGD-2 win_cq03h",
    ],
    "ooe_rat": [
        "NGD-2 ren_pold_cq01h", "NGD-2 ren_ppguard_cq01h", "NGD-2 ren_ppold_cq01h",
        "NGD-2 ren_ppq_cq01h", "NGD-2 ren_psrc_cq01h", "NGD-3 ren_dst_cq01h",
        "NGD-3 ren_gwe_cq01h", "NGD-3 ren_pdst_cq01h", "NGD-3 ren_rst_cq01h",
        "NGD-3 ren_slot_cq01h", "NGD-3 ren_v_cq01h", "NGD-3 restore_ckpt_cq01h",
        "NGD-3 ret_dst_cq01h", "NGD-3 ret_gwe_cq01h", "NGD-3 ret_pdst_cq01h",
        "NGD-3 ret_pwe_cq01h",
    ],
    "ooe_ready": [
        "NGD-2 ready_cq02h",
    ],
    "ooe_rs": [
        "NGD-2 gnt_idx_cq02h", "NGD-2 gnt_v_cq02h", "NGD-3 free_cq01h", "NGD-3 grp_code_cq01h",
        "NGD-3 grp_dep_cq01h", "NGD-3 req_cq01h", "NGD-3 row_code_cq01h",
    ],
    "ooe_select": [
        "NGD-2 cand_cq03h", "NGD-2 grant_cq03h", "NGD-2 lost_cq03h",
    ],
    "ooe_wake": [
        "NGD-3 cls_cq01h", "NGD-3 cmpl_cq01h", "NGD-3 grant_cq01h", "NGD-3 kind_cq01h",
    ],
}.items() for k in ks}
EPS = 0.005
NEG = float("-inf")


def run(cmd):
    return cg.run(cmd)


# == The mapped netlist ========================================================

def genlib(path=GENLIB):
    """{gate: delay}: each gate's slowest pin, as ABC's mapper costs it."""
    out = {}
    for line in open(path):
        m = re.match(r"GATE\s+(\S+)\s+\S+\s+[^;]*;\s*(.*)", line)
        if m:
            pins = re.findall(r"PIN\s+\S+\s+\S+\s+\S+\s+\S+\s+([\d.]+)\s+\S+\s+([\d.]+)",
                              m.group(2))
            out[m.group(1)] = max([max(float(a), float(b)) for a, b in pins] or [0.0])
    return out


LIB = dict(genlib(), WIRE=0.0)

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
            gates.append((t[1], [v for k2, v in pins.items() if k2 != "Y"], pins["Y"]))
        elif t[0] == ".names" and len(t) == 3 and k + 1 < len(lines) and lines[k + 1] == ["1", "1"]:
            # A net wired straight to another, a port to a port: no delay.
            gates.append(("WIRE", [t[1]], t[2]))
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
    A BUF counts nothing here: ABC puts one only where a port is wired to a
    port, and fanout and wire are costed outside the logic (the genlib's
    note). `abc` is ABC's own longest path, BUFs at their genlib delay;
    the timing pass's, taken the same way, must equal it."""

    def __init__(self, blif, abc, lib=LIB):
        ins, outs, latches, gates = parse_blif(blif)
        self.abc = abc
        driver = {o: (g, a) for g, a, o in gates}
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
                stack.extend((a, False) for a in driver[x][1] if a not in seen)

        def prop(start, buf=0.0):
            arr = dict.fromkeys(start, 0.0)
            for n in order:
                g, a = driver[n]
                t = max((arr[x] for x in a if x in arr), default=NEG)
                if t > NEG and g not in ("ZERO", "ONE"):
                    arr[n] = t + (buf if g == "BUF" else lib[g])
            return arr

        ports_in = collections.defaultdict(list)
        for i in ins:
            ports_in[base(i)].append(i)
        ports_out = collections.defaultdict(list)
        for o in outs:
            ports_out[base(o)].append(o)
        d_nets = [d for d, _ in latches]
        every = prop(list(ins) + [q for _, q in latches], buf=lib["BUF"])
        self.abc_like = max([every.get(n, NEG) for n in d_nets + list(outs)] + [0.0])
        r = prop([q for _, q in latches])
        self.rr = max((r.get(d, NEG) for d in d_nets), default=NEG)
        self.ro = {p: max(r.get(o, NEG) for o in bits) for p, bits in ports_out.items()}
        self.ir, self.io = {}, {}
        for p, bits in ports_in.items():
            a = prop(bits)
            self.ir[p] = max((a.get(d, NEG) for d in d_nets), default=NEG)
            for q, obits in ports_out.items():
                t = max(a.get(o, NEG) for o in obits)
                if t > NEG:
                    self.io[(p, q)] = t
        self.ins, self.outs = sorted(ports_in), sorted(ports_out)


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
    r = run(["yosys-abc", "-c", "read_blif %s; read_library %s; strash; dch; map; print_stats; "
             "write_blif %s" % (blif, GENLIB, mapped)])
    m = re.search(r"delay\s*=\s*([\d.]+)", r.stdout)
    if r.returncode or not m:
        raise SystemExit("check-ngd: %s: ABC failed:\n%s" % (work, (r.stdout + r.stderr)[-2000:]))
    t = Timing(mapped, float(m.group(1)), lib)
    t.cut = cut
    if abs(t.abc_like - t.abc) > EPS:
        raise SystemExit("check-ngd: %s: the timing pass's longest path, %.2f NGD, is not "
                         "ABC's, %.2f" % (work, t.abc_like, t.abc))
    return t


def synth(name, top, files, blackbox=(), params=None, defines=(), flat=True):
    """A module at its parameters, as a Yosys JSON netlist: flattened, or
    with its hierarchy kept."""
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
    cmds += ["hierarchy -top %s" % top, "chformal -remove",
             "synth %s-top %s" % ("-flatten " if flat else "", top), "write_json %s" % jf]
    r = run(["yosys", "-q", "-p", "; ".join(cmds)])
    if r.returncode:
        raise SystemExit("check-ngd: %s: yosys failed:\n%s" % (name, (r.stdout + r.stderr)[-2000:]))
    return work, jf


# == Units and budgets =========================================================

class Unit:
    def __init__(self, spec, src):
        self.spec, self.src = spec, src
        self.name, self.module = spec["name"], spec["module"]
        self.t = None

    def measure(self, lib=LIB):
        s = self.spec
        bbs = s.get("blackbox", {})
        work, jf = synth("u_" + self.name, self.module, s["files"],
                         [bbs[b] for b in sorted(bbs)], s.get("params"), s.get("defines", []))
        self.t = map_and_time(work, jf, bbs.keys(), lib)
        return self.t


def load_units():
    out, names = [], set()
    for pat in ("cg-units.json", "ngd-units.json"):
        for f in sorted(glob.glob(os.path.join(ROOT, "test", "**", pat), recursive=True)):
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
                 "gnt_idx_cq02h": {"required": 20.0, "by": ..., "date": ..., "why": ...}}}

    An input's arrival or an output's required time, in NGD from the flop
    that launches it. A port the file does not name takes the default: an
    output required at CCV_NGD_PORT, an input arriving at CCV_NGD_BUDGET -
    CCV_NGD_PORT."""

    def __init__(self, files=(), extra=None):
        self.e, self.files, self.bad = {}, {}, []
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
            for port, b in d.get("ports", {}).items():
                self.e[(mod, port)] = b
        for (mod, port), b in (extra or {}).items():
            self.e[(mod, port)] = b

    @classmethod
    def load(cls):
        return cls(sorted(glob.glob(BUDGET_GLOB, recursive=True)))

    def required(self, mod, port):
        b = self.e.get((mod, port))
        return float(b["required"]) if b and "required" in b else PORT

    def arrival(self, mod, port):
        b = self.e.get((mod, port))
        return float(b["arrival"]) if b and "arrival" in b else STAGE - PORT

    def check(self, units, modules):
        """NGD-4: each file for a design module, each entry well formed and
        on a port its module has, of the right direction."""
        fails = list(self.bad)
        ports = {}
        for u in units:
            if u.t is not None:
                ports.setdefault(u.module, (set(u.t.ins), set(u.t.outs)))
        for mod, rel in sorted(self.files.items()):
            if mod not in modules:
                fails.append("NGD-4 %s: %s is not a design module" % (rel, mod))
        for (mod, port), b in sorted(self.e.items()):
            where = "%s.%s (%s)" % (mod, port, self.files.get(mod, "selftest"))
            for k in ("by", "date", "why"):
                if not b.get(k):
                    fails.append("NGD-4 %s: no %s" % (where, k))
            kind = [k for k in ("arrival", "required") if k in b]
            if len(kind) != 1:
                fails.append("NGD-4 %s: names neither or both of arrival and required" % where)
                continue
            v = float(b[kind[0]])
            if not 0 <= v <= STAGE:
                fails.append("NGD-4 %s: %s %g is outside 0..%g" % (where, kind[0], v, STAGE))
            if mod in ports:
                inp = kind[0] == "arrival"
                if port not in (ports[mod][0] if inp else ports[mod][1]):
                    fails.append("NGD-4 %s: %s has no %s port %s"
                                 % (where, mod, "input" if inp else "output", port))
        return fails


def findings(u, budgets):
    """The unit's findings, as (key, message): key is what the ratchet lists."""
    t, mod, out = u.t, u.module, []
    if t.rr > STAGE + EPS:
        out.append(("NGD-1", "NGD-1 %s (unit %s): flop to flop %.1f NGD, over the %g stage"
                    % (mod, u.name, t.rr, STAGE)))
    for o in t.outs:
        if o in t.cut:
            continue
        req = budgets.required(mod, o)
        worst, why = t.ro[o], "from its flops"
        for (i, q), d in t.io.items():
            if q == o and i not in t.cut and budgets.arrival(mod, i) + d > worst:
                worst, why = budgets.arrival(mod, i) + d, "from input %s, arriving at %g, %.1f " \
                    "through" % (i, budgets.arrival(mod, i), d)
        if worst > req + EPS:
            out.append(("NGD-2 %s" % o, "NGD-2 %s (unit %s): output %s ready at %.1f NGD %s, "
                        "required at %g" % (mod, u.name, o, worst, why, req)))
    for i in t.ins:
        if i in t.cut or t.ir[i] == NEG:
            continue
        arr = budgets.arrival(mod, i)
        if arr + t.ir[i] > STAGE + EPS:
            out.append(("NGD-3 %s" % i, "NGD-3 %s (unit %s): input %s, arriving at %g, reaches "
                        "a flop %.1f later, %.1f in all, over the %g stage"
                        % (mod, u.name, i, arr, t.ir[i], arr + t.ir[i], STAGE)))
    return out


def report(u, verbose=False):
    t = u.t
    ro = max([v for k, v in t.ro.items() if k not in t.cut] + [0.0])
    ir = max([v for k, v in t.ir.items() if k not in t.cut] + [0.0])
    io = max([v for (i, o), v in t.io.items() if i not in t.cut and o not in t.cut] + [0.0])
    print("  unit %-16s %-14s flop-flop %5.1f  in-flop %5.1f  flop-out %5.1f  in-out %5.1f"
          % (u.name, u.module, max(t.rr, 0.0), ir, ro, io))
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


def policy(units, budgets, ratchet, modules, baseline=RATCHET_BASELINE):
    """Findings excused by the ratchet; a ratchet entry that is no longer a
    finding, or was never in the baseline, refused; a design module no unit
    measures, refused. Returns the failures."""
    fails = list(budgets.check(units, modules))
    found = collections.defaultdict(set)
    for u in units:
        for key, msg in findings(u, budgets):
            found[u.module].add(key)
            if key not in ratchet.get(u.module, []):
                fails.append(msg)
    for mod, keys in sorted(ratchet.items()):
        for k in keys:
            if (mod, k) not in baseline:
                fails.append("ratchet: %s %s was not on the list when the rule was made; the "
                             "list only shrinks" % (mod, k))
            elif k not in found.get(mod, set()) and any(u.module == mod for u in units):
                fails.append("ratchet: %s %s now meets its budget: remove it from %s"
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


def src_name(mod):
    """A module's source name from Yosys's name for one parameterisation."""
    m = re.match(r"^\$paramod(?:\$[0-9a-f]+)?\\([^\\]+)", mod)
    return m.group(1) if m else mod.lstrip("\\")


def converge(name, block, files, bbs, budgets, lib=LIB):
    """The block's hierarchy from its budget files: each module in it that
    instantiates others (the hardening wrapper aside, which is nets and
    repeaters) is mapped alone, its children cut out. A child's output
    starts at its required time, a child's input must be reached by its
    arrival; the module's own ports take its budgets, or, for the block top,
    the boundary's: inputs arriving at the default (its outputs, straight from
    a flop, are the flattened pass's). So every connection, and the glue
    between, must converge."""
    work, jf = synth("h_" + name, block, files, bbs, flat=False)
    d = json.load(open(jf))
    mods = d["modules"]
    lib_cells = {m for m, v in mods.items() if v.get("attributes", {}).get("blackbox")}
    fails = []
    for mn, m in sorted(mods.items()):
        if mn in lib_cells or src_name(mn).endswith("_w"):
            continue
        kids = {c["type"] for c in m.get("cells", {}).values() if c["type"] in mods} - lib_cells
        if not kids:
            continue
        own = src_name(mn)
        sub = os.path.join(BUILD, "h_" + name, re.sub(r"\W", "_", own))
        os.makedirs(sub, exist_ok=True)
        one = os.path.join(sub, "one.json")
        json.dump({"creator": d.get("creator", ""), "modules": {mn: m}}, open(one, "w"))
        t = map_and_time(sub, one, kids | lib_cells, lib)

        def start(p):
            if p in t.cut:
                cell, typ, pin, _ = t.cut[p]
                if typ in lib_cells or is_clock(pin):
                    return None, None
                return budgets.required(src_name(typ), pin), "%s.%s" % (cell, pin)
            if is_clock(p):
                return None, None
            return (STAGE - PORT if own == block else budgets.arrival(own, p)), p

        def end(p):
            if p in t.cut:
                cell, typ, pin, _ = t.cut[p]
                if typ in lib_cells or is_clock(pin):
                    return None, None
                return budgets.arrival(src_name(typ), pin), "%s.%s" % (cell, pin)
            if own == block:
                return None, None      # the flattened pass: straight from a flop
            return budgets.required(own, p), p

        where = "block %s, in %s" % (name, own)
        if t.rr > STAGE + EPS:
            fails.append("%s: flop to flop %.1f NGD, over the %g stage" % (where, t.rr, STAGE))
        for p in t.ins:
            a, nm = start(p)
            if a is not None and t.ir[p] > NEG and a + t.ir[p] > STAGE + EPS:
                fails.append("%s: %s, starting at %g, reaches a flop at %.1f, over the %g stage"
                             % (where, nm, a, a + t.ir[p], STAGE))
        for p in t.outs:
            r, nm = end(p)
            if r is not None and t.ro[p] > r + EPS:
                fails.append("%s: %s, required at %g, is reached from a flop at %.1f"
                             % (where, nm, r, t.ro[p]))
        for (p, q), dl in sorted(t.io.items()):
            (a, na), (r, nr) = start(p), end(q)
            if a is not None and r is not None and a + dl > r + EPS:
                fails.append("%s: budgets do not converge: %s, starting at %g, reaches %s at "
                             "%.1f, required at %g" % (where, na, a, nr, a + dl, r))
    return fails


def block_check(name, top, files, bbs, budgets, block=None, lib=LIB):
    """A block assembled: first converged from its budget files, level by
    level; then timed whole, flattened, every flop-to-flop path within the
    stage, every output straight from a flop, every input into its flops
    within the default port budget. `block` is the block's own module (the
    partition's top may be its hardening wrapper). Returns (line, failures)."""
    fails = converge(name, block or top, files, bbs, budgets, lib)
    work, jf = synth("b_" + name, top, files, bbs)
    t = map_and_time(work, jf, [os.path.basename(b)[:-3] for b in bbs], lib)
    if t.rr > STAGE + EPS:
        fails.append("block %s: flop to flop %.1f NGD, over the %g stage" % (name, t.rr, STAGE))
    for o in t.outs:
        if o in t.cut:
            continue
        thru = any(q == o for (_, q) in t.io)
        if t.ro[o] > EPS or thru:
            fails.append("block %s: output %s is not straight from a flop (%.1f NGD after one%s)"
                         % (name, o, max(t.ro[o], 0.0),
                            ", and reached from an input" if thru else ""))
    for i in t.ins:
        if i not in t.cut and t.ir[i] > PORT + EPS:
            fails.append("block %s: input %s reaches its flops %.1f NGD after arriving, over "
                         "the %g port budget" % (name, i, t.ir[i], PORT))
    line = ("block %-8s budgets converge level by level; whole, flop-flop %5.1f, outputs "
            "from flops, inputs within %g" % (name, max(t.rr, 0.0), PORT))
    return line, fails


def main_check(only=None):
    units = load_units()
    if only:
        units = [u for u in units if u.name == only]
        if not units:
            raise SystemExit("check-ngd: no unit %s" % only)
    budgets = Budgets.load()
    for u in units:
        u.measure()
        report(u, verbose=bool(only))
    if only:
        for _, msg in findings(units[0], budgets):
            print("    " + msg)
        return 0
    ratchet = load(RATCHET, "modules", {})
    fails = policy(units, budgets, ratchet, design_modules())
    for mod in sorted(ratchet):
        print("  ratchet: %-14s %d port finding(s) awaiting budgets" % (mod, len(ratchet[mod])))
    parts = cg.partitions(cg.design_modules())
    for name, top, files, bbs in parts:
        line, more = block_check(name, top, files, bbs, budgets, block="ccv_%s" % name)
        print("  " + line)
        fails += more
    if not parts:
        print("  blocks: none assembled yet (every block top is a generated stub)")
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
          ("ngd_fx_ok", "ngd_fx_out", "ngd_fx_in", "ngd_fx_thru", "ngd_fx_stage")}
    for u in fx.values():
        u.measure()
    none = Budgets()

    def keys(u, b=none):
        return {k for k, _ in findings(u, b)}

    # 1. The timing pass agrees with ABC on every fixture (map_and_time
    #    stops otherwise), and a wrong delay table is caught.
    wrong = dict(LIB, NAND2=LIB["NAND2"] * 2)
    try:
        u = fixture("fx_wrong", "ngd_fx_stage")
        u.measure(lib=wrong)
        expect(False, "a timing pass with a wrong NAND2 delay agreed with ABC")
    except SystemExit as e:
        expect("is not ABC's" in str(e), "a wrong delay table stopped the run otherwise: %s" % e)
    # 2. Within every default: nothing.
    expect(not keys(fx["ngd_fx_ok"]), "the compliant fixture has findings: %s"
           % findings(fx["ngd_fx_ok"], none))
    # 3. An output its flops reach too late (NGD-2), an input that reaches
    #    a flop too late (NGD-3), flop to flop over the stage (NGD-1).
    expect("NGD-2 y" in keys(fx["ngd_fx_out"]), "a deep output passed: %.1f"
           % fx["ngd_fx_out"].t.ro.get("y", NEG))
    expect("NGD-3 a" in keys(fx["ngd_fx_in"]), "a deep input passed: %.1f"
           % fx["ngd_fx_in"].t.ir.get("a", NEG))
    expect("NGD-1" in keys(fx["ngd_fx_stage"]), "a path over the stage passed: %.1f"
           % fx["ngd_fx_stage"].t.rr)
    # 4. A path straight through fits no default; its module's budget file
    #    (test/ngd/fixtures/ngd_fx_thru.ngd.json: a at 6, y by 18) clears it.
    thru = fx["ngd_fx_thru"]
    expect("NGD-2 y" in keys(thru), "a path straight through passed on defaults")
    tf = os.path.join(ROOT, FIX, "ngd_fx_thru.ngd.json")
    b = Budgets([tf])
    thru_mods = {"ngd_fx_thru": "f"}
    expect(not keys(thru, b) and not b.check([thru], thru_mods),
           "its budget file did not clear a path straight through: %s %s"
           % (findings(thru, b), b.check([thru], thru_mods)))
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
    expect(any("neither or both" in x for x in
               bfile("ngd_fx_thru.ngd.json", dict(good, ports={"a": dict(entry, required=9)}))),
           "a budget naming both an arrival and a required time was accepted")
    entry_nowhy = {k: v for k, v in entry.items() if k != "why"}
    expect(any("no why" in x for x in
               bfile("ngd_fx_thru.ngd.json", dict(good, ports={"a": entry_nowhy}))),
           "a budget with no why was accepted")
    # 6. The ratchet: a listed finding excused; one that now passes, or one
    #    outside the baseline, refused; a module with no unit, refused.
    us = [fx["ngd_fx_out"], fx["ngd_fx_ok"]]
    mods = {"ngd_fx_out": "f", "ngd_fx_ok": "f"}
    base = {("ngd_fx_out", "NGD-2 y"), ("ngd_fx_ok", "NGD-2 y")}
    fails = policy(us, none, {"ngd_fx_out": ["NGD-2 y"]}, mods, base)
    expect(not fails, "a ratcheted finding was not excused: %s" % fails)
    fails = policy(us, none, {"ngd_fx_ok": ["NGD-2 y"]}, mods, base)
    expect(any("now meets its budget" in x for x in fails),
           "a ratchet entry that passes stayed on the list")
    fails = policy(us, none, {"ngd_fx_out": ["NGD-2 y"]}, mods, set())
    expect(any("only shrinks" in x for x in fails), "the ratchet grew")
    fails = policy(us, none, {}, dict(mods, ngd_fx_lost="f"), base)
    expect(any("ngd_fx_lost" in x and "no timing unit" in x for x in fails),
           "a module with no unit passed")
    # 7. The assembled block from its budget files, level by level: a
    #    driver required at 14 straight into a receiver arriving at 15
    #    converges; through an XOR it does not; and with the driver's budget
    #    moved to 16, neither does the straight connection.
    files = ["%s/ngd_fx_blk.sv" % FIX]
    fb = Budgets([os.path.join(ROOT, FIX, "ngd_fx_bsrc.ngd.json"),
                  os.path.join(ROOT, FIX, "ngd_fx_bdst.ngd.json")])
    f = converge("fx_asm_ok", "ngd_fx_asm_ok", files, [], fb)
    expect(not f, "budgets that converge were refused: %s" % f)
    f = converge("fx_asm_gap", "ngd_fx_asm_gap", files, [], fb)
    expect(any("do not converge" in x and "u_src.y" in x and "u_dst.a" in x for x in f),
           "glue between two children past their budgets passed: %s" % f)
    late = Budgets(extra={("ngd_fx_bsrc", "y"): dict(json.load(open(os.path.join(
        ROOT, FIX, "ngd_fx_bsrc.ngd.json")))["ports"]["y"], required=16)})
    late.e[("ngd_fx_bdst", "a")] = fb.e[("ngd_fx_bdst", "a")]
    f = converge("fx_asm_late", "ngd_fx_asm_ok", files, [], late)
    expect(any("do not converge" in x for x in f),
           "a driver required after its receiver's arrival passed: %s" % f)
    # 8. The assembled block, whole: every path in the stage; outputs from
    #    flops; inputs within the port budget. Two 8-bit multiplies in series
    #    across a module boundary are over the stage, whatever the budgets.
    _, f = block_check("fx_ok", "ngd_fx_blk_ok", files, [], none)
    expect(not f, "a compliant assembled block failed: %s" % f)
    _, f = block_check("fx_long", "ngd_fx_blk_long", files, [], none)
    expect(any("over the" in x and "flop to flop" in x and "block fx_long:" in x for x in f),
           "a block with a path over the stage across two modules passed")
    _, f = block_check("fx_comb", "ngd_fx_blk_comb", files, [], none)
    expect(any("not straight from a flop" in x for x in f),
           "a block output driven through logic passed")
    _, f = block_check("fx_deep_in", "ngd_fx_blk_deepin", files, [], none)
    expect(any("input" in x and "port budget" in x for x in f),
           "a block input deep before its flop passed")
    for x in bad:
        sys.stderr.write("check-ngd selftest: %s\n" % x)
    if not bad:
        print("  timing pass against ABC, outputs, inputs, the stage, paths straight through, "
              "budget files, ratchet, coverage, the assembled block from its budgets and whole "
              "(%d controls)" % checks)
    return 1 if bad else 0


def main():
    ap = argparse.ArgumentParser()
    ap.add_argument("--selftest", action="store_true")
    ap.add_argument("--unit")
    a = ap.parse_args()
    os.makedirs(BUILD, exist_ok=True)
    if a.selftest:
        return selftest()
    return main_check(a.unit)


if __name__ == "__main__":
    sys.exit(main())
