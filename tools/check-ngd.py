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
INNER = float(cg.param("CCV_NGD_INNER"))
GENLIB = cg.GENLIB
BUDGET_GLOB = os.path.join(ROOT, "rtl", "**", "*.ngd.json")
RATCHET = os.path.join(ROOT, "rtl", "ngd-ratchet.json")
# The findings that stood when each rule was made: NGD-1 to NGD-4 on
# 2026-10-17, NGD-5 on 2026-10-18 (its through paths had been NGD-2's),
# ooe_rat's then on OI's branch (b9c3a44); NGD-6 on 2026-10-19, ooe_select's
# on OI's branch (d8ffd4c: declared inner, no parent yet); NGD-7 on
# 2026-10-19, at 7ae697c. Never add to this:
# a module written since meets the rules, or has the architect's budgets, or
# is redesigned.
RATCHET_BASELINE = {(m, k) for m, ks in {
    "ooe_confirm": [
        "NGD-5 dep_cq01h>conf_cq01h", "NGD-5 dep_cq01h>replay_cq02h", "NGD-5 fin_cq01h>conf_cq01h",
        "NGD-5 iss_cq01h>conf_cq01h", "NGD-5 iss_cq01h>replay_cq02h",
        "NGD-5 miss_cq01h>replay_cq02h", "NGD-5 prod_cq01h>conf_cq01h",
    ],
    "ooe_decq": [
        "NGD-2 head_pay_cq02h", "NGD-2 used_cq02h", "NGD-3 deq_n_cq01h", "NGD-3 enq_slot_cq01h",
        "NGD-3 enq_v_cq01h", "NGD-3 flush_cq01h",
        "NGD-7 st_cq02h",
    ],
    "ooe_freelist": [
        "NGD-3 alloc_req_cq01h", "NGD-5 alloc_req_cq01h>alloc_idx_cq02h",
        "NGD-5 alloc_req_cq01h>alloc_v_cq02h",
        "NGD-7 st_cq02h",
    ],
    "ooe_pick": [
        "NGD-5 older_cq03h>issue_cq03h", "NGD-5 older_cq03h>lost_cq03h",
        "NGD-5 older_cq03h>win_cq03h", "NGD-5 req_cq03h>issue_cq03h", "NGD-5 req_cq03h>lost_cq03h",
        "NGD-5 req_cq03h>win_cq03h",
    ],
    "ooe_rat": [
        "NGD-2 ren_pold_cq01h", "NGD-2 ren_psrc_cq01h", "NGD-3 ren_dst_cq01h",
        "NGD-3 ren_gwe_cq01h", "NGD-3 ren_pdst_cq01h", "NGD-3 ren_rst_cq01h",
        "NGD-3 ren_slot_cq01h", "NGD-3 ren_v_cq01h", "NGD-3 restore_ckpt_cq01h",
        "NGD-3 ret_dst_cq01h", "NGD-3 ret_gwe_cq01h", "NGD-3 ret_pdst_cq01h",
        "NGD-3 ret_pwe_cq01h", "NGD-5 ren_dst_cq01h>ren_pold_cq01h",
        "NGD-5 ren_dst_cq01h>ren_psrc_cq01h", "NGD-5 ren_gname_cq01h>ren_pold_cq01h",
        "NGD-5 ren_gname_cq01h>ren_psrc_cq01h", "NGD-5 ren_gwe_cq01h>ren_pold_cq01h",
        "NGD-5 ren_gwe_cq01h>ren_psrc_cq01h", "NGD-5 ren_pdst_cq01h>ren_ppguard_cq01h",
        "NGD-5 ren_pdst_cq01h>ren_ppold_cq01h", "NGD-5 ren_pdst_cq01h>ren_ppq_cq01h",
        "NGD-5 ren_pguard_cq01h>ren_ppguard_cq01h", "NGD-5 ren_pname_cq01h>ren_ppguard_cq01h",
        "NGD-5 ren_pname_cq01h>ren_ppold_cq01h", "NGD-5 ren_pname_cq01h>ren_ppq_cq01h",
        "NGD-5 ren_pq_cq01h>ren_ppq_cq01h", "NGD-5 ren_pwe_cq01h>ren_ppguard_cq01h",
        "NGD-5 ren_pwe_cq01h>ren_ppold_cq01h", "NGD-5 ren_pwe_cq01h>ren_ppq_cq01h",
        "NGD-5 ren_rst_cq01h>ren_pold_cq01h", "NGD-5 ren_rst_cq01h>ren_ppguard_cq01h",
        "NGD-5 ren_rst_cq01h>ren_ppold_cq01h", "NGD-5 ren_rst_cq01h>ren_ppq_cq01h",
        "NGD-5 ren_rst_cq01h>ren_psrc_cq01h", "NGD-5 ren_slot_cq01h>ren_pold_cq01h",
        "NGD-5 ren_slot_cq01h>ren_ppguard_cq01h", "NGD-5 ren_slot_cq01h>ren_ppold_cq01h",
        "NGD-5 ren_slot_cq01h>ren_ppq_cq01h", "NGD-5 ren_slot_cq01h>ren_psrc_cq01h",
        "NGD-5 ren_src_cq01h>ren_psrc_cq01h", "NGD-5 ren_v_cq01h>ren_pold_cq01h",
        "NGD-5 ren_v_cq01h>ren_ppguard_cq01h", "NGD-5 ren_v_cq01h>ren_ppold_cq01h",
        "NGD-5 ren_v_cq01h>ren_ppq_cq01h", "NGD-5 ren_v_cq01h>ren_psrc_cq01h",
        "NGD-7 rat_cq02h",
    ],
    "ooe_ready": [
        "NGD-5 code_cq02h>ready_cq02h", "NGD-5 dep_cq02h>ready_cq02h",
        "NGD-5 wake_cq02h>ready_cq02h",
    ],
    "ooe_rs": [
        "NGD-2 gnt_idx_cq02h", "NGD-2 gnt_v_cq02h", "NGD-3 free_cq01h", "NGD-3 grp_code_cq01h",
        "NGD-3 grp_dep_cq01h", "NGD-3 req_cq01h", "NGD-3 row_code_cq01h",
        "NGD-5 free_cq01h>gnt_idx_cq02h", "NGD-5 free_cq01h>gnt_v_cq02h",
        "NGD-5 req_cq01h>gnt_idx_cq02h", "NGD-5 req_cq01h>gnt_v_cq02h",
        "NGD-7 valid_cq02h",
    ],
    "ooe_select": [
        "NGD-5 active_cq03h>cand_cq03h", "NGD-5 active_cq03h>grant_cq03h",
        "NGD-5 active_cq03h>lost_cq03h", "NGD-5 active_cq03h>pick_m.req_cq03h",
        "NGD-5 active_cq03h>pick_r.req_cq03h", "NGD-5 block_cq03h>cand_cq03h",
        "NGD-5 block_cq03h>grant_cq03h", "NGD-5 block_cq03h>lost_cq03h",
        "NGD-5 block_cq03h>pick_m.req_cq03h", "NGD-5 busy_cq03h>cand_cq03h",
        "NGD-5 busy_cq03h>grant_cq03h", "NGD-5 busy_cq03h>lost_cq03h",
        "NGD-5 busy_cq03h>pick_m.req_cq03h", "NGD-5 busy_cq03h>pick_r.req_cq03h",
        "NGD-5 chas_cq03h>cand_cq03h", "NGD-5 chas_cq03h>grant_cq03h",
        "NGD-5 chas_cq03h>lost_cq03h", "NGD-5 chas_cq03h>pick_m.req_cq03h",
        "NGD-5 cidx_cq03h>cand_cq03h", "NGD-5 cidx_cq03h>grant_cq03h",
        "NGD-5 cidx_cq03h>lost_cq03h", "NGD-5 cidx_cq03h>pick_m.req_cq03h",
        "NGD-5 copy_cq03h>cand_cq03h", "NGD-5 copy_cq03h>grant_cq03h",
        "NGD-5 copy_cq03h>lost_cq03h", "NGD-5 copy_cq03h>pick_r.req_cq03h",
        "NGD-5 dep_cq03h>cand_cq03h", "NGD-5 dep_cq03h>grant_cq03h", "NGD-5 dep_cq03h>lost_cq03h",
        "NGD-5 dep_cq03h>pick_m.req_cq03h", "NGD-5 dep_cq03h>pick_r.req_cq03h",
        "NGD-5 elig_cq03h>cand_cq03h", "NGD-5 elig_cq03h>grant_cq03h",
        "NGD-5 elig_cq03h>lost_cq03h", "NGD-5 elig_cq03h>pick_m.req_cq03h",
        "NGD-5 elig_cq03h>pick_r.req_cq03h", "NGD-5 iss_cq03h>cand_cq03h",
        "NGD-5 iss_cq03h>grant_cq03h", "NGD-5 iss_cq03h>lost_cq03h",
        "NGD-5 iss_cq03h>pick_m.req_cq03h", "NGD-5 iss_cq03h>pick_r.req_cq03h",
        "NGD-5 older_m_cq03h>cand_cq03h", "NGD-5 older_m_cq03h>grant_cq03h",
        "NGD-5 older_m_cq03h>lost_cq03h", "NGD-5 older_m_cq03h>pick_m.req_cq03h",
        "NGD-5 older_r_cq03h>grant_cq03h", "NGD-5 older_r_cq03h>lost_cq03h",
        "NGD-5 ready_cq03h>cand_cq03h", "NGD-5 ready_cq03h>grant_cq03h",
        "NGD-5 ready_cq03h>lost_cq03h", "NGD-5 ready_cq03h>pick_m.req_cq03h",
        "NGD-5 ready_cq03h>pick_r.req_cq03h", "NGD-5 res_cq03h>cand_cq03h",
        "NGD-5 res_cq03h>grant_cq03h", "NGD-5 res_cq03h>lost_cq03h",
        "NGD-5 res_cq03h>pick_m.req_cq03h", "NGD-5 res_cq03h>pick_r.req_cq03h",
        "NGD-5 slot_cq03h>cand_cq03h", "NGD-5 slot_cq03h>grant_cq03h",
        "NGD-5 slot_cq03h>lost_cq03h", "NGD-5 slot_cq03h>pick_m.req_cq03h",
        "NGD-5 slot_cq03h>pick_r.req_cq03h", "NGD-5 valid_cq03h>cand_cq03h",
        "NGD-5 valid_cq03h>grant_cq03h", "NGD-5 valid_cq03h>lost_cq03h",
        "NGD-5 valid_cq03h>pick_m.req_cq03h", "NGD-5 valid_cq03h>pick_r.req_cq03h",
        "NGD-6 active_cq03h>grant_cq03h", "NGD-6 active_cq03h>lost_cq03h",
        "NGD-6 block_cq03h>grant_cq03h", "NGD-6 block_cq03h>lost_cq03h",
        "NGD-6 busy_cq03h>grant_cq03h", "NGD-6 busy_cq03h>lost_cq03h",
        "NGD-6 cidx_cq03h>grant_cq03h", "NGD-6 cidx_cq03h>lost_cq03h",
        "NGD-6 dep_cq03h>grant_cq03h", "NGD-6 dep_cq03h>lost_cq03h",
        "NGD-6 elig_cq03h>grant_cq03h", "NGD-6 elig_cq03h>lost_cq03h",
        "NGD-6 iss_cq03h>grant_cq03h", "NGD-6 iss_cq03h>lost_cq03h",
        "NGD-6 older_m_cq03h>grant_cq03h", "NGD-6 ready_cq03h>grant_cq03h",
        "NGD-6 ready_cq03h>lost_cq03h", "NGD-6 res_cq03h>grant_cq03h",
        "NGD-6 res_cq03h>lost_cq03h", "NGD-6 slot_cq03h>grant_cq03h",
        "NGD-6 slot_cq03h>lost_cq03h", "NGD-6 valid_cq03h>grant_cq03h",
        "NGD-6 valid_cq03h>lost_cq03h",
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
                w = dep[n] + (0.0 if g == "BUF" else lib[g])
                for x in a:
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
    t.cut, t.regname = cut, reg_names(d)
    if abs(t.abc_like - t.abc) > EPS:
        raise SystemExit("check-ngd: %s: the timing pass's longest path, %.2f NGD, is not "
                         "ABC's, %.2f" % (work, t.abc_like, t.abc))
    return t


def synth(name, top, files, blackbox=(), params=None, defines=(), flat=True, inner=()):
    """A module at its parameters, as a Yosys JSON netlist: flattened, or
    with its hierarchy kept, less the `inner` helpers, which are flattened
    into their parents (a parameterised copy is $paramod\\<module>\\...)."""
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
                     "%s $paramod\\%s\\*" % (m, m) for m in sorted(inner))]
        flat = True
    cmds += ["synth %s-top %s" % ("-flatten " if flat else "", top), "write_json %s" % jf]
    r = run(["yosys", "-q", "-p", "; ".join(cmds)])
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


def shared_flops(u, budgets):
    """NGD-7 (Daniel, 2026-10-19): a register that drives an output is held,
    on every path it starts, to that output's required time: to the module's
    own flops as to any output. A flop on a critical path out and on one in
    is pulled two ways at placement. Where a register drives several
    outputs, the strictest holds; a path to an output over that output's own
    required time is NGD-2's. The remedy is a copy of the register, one
    for the output and one for the paths inside, each declared (* keep *).
    Keyed by register."""
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
    return [("NGD-7 %s" % reg, "NGD-7 %s (unit %s): register %s drives output %s, required at "
             "%g, and reaches %s %.1f NGD away: copy the register, one copy for the output and "
             "one for the rest, each (* keep *)" % (mod, u.name, reg, port, lim, what, d))
            for reg, (_, q, port, lim, d, what) in sorted(worst.items())]


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
    parents = parented(units, modules)
    for u in units:
        for key, msg in findings(u, budgets, parents):
            found[u.module].add(key)
            if key not in ratchet.get(u.module, []):
                fails.append(msg)
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


def src_name(mod):
    """A module's source name from Yosys's name for one parameterisation."""
    m = re.match(r"^\$paramod(?:\$[0-9a-f]+)?\\([^\\]+)", mod)
    return m.group(1) if m else mod.lstrip("\\")


def converge(name, top, files, bbs, budgets, lib=LIB, params=None, defines=(), unit=None):
    """A hierarchy from its budget files, inner helpers flattened into their
    parents: each module in it that instantiates others (the hardening
    wrapper aside, which is nets and repeaters) is mapped alone, its
    children cut out. A child's output starts at its required time, a
    child's input must be reached by its arrival; the module's own ports take
    its budgets, or, for a block top, the boundary's: inputs arriving at the
    default (its outputs, straight from a flop, are the flattened pass's).
    So every connection must converge, and a path that touches none of the
    module's own flops must be a wire (NGD-5: glue between children is a
    third segment on a flop-to-flop path).

    For a block, every level, and findings are messages. For a unit
    (`unit`, its name), the top level only, its children's connections
    alone (its own ports are its flattened findings'), as (key, message)
    for the ratchet. A path from a port of the module's to a port of its own
    is its unit's NGD-5, or a wire, which carries its driver's time to its
    receiver and is timed by the flattened pass."""
    work, jf = synth("h_" + name, top, files, bbs, params, defines, flat=False,
                     inner=sorted(budgets.inner))
    d = json.load(open(jf))
    mods = d["modules"]
    lib_cells = {m for m, v in mods.items() if v.get("attributes", {}).get("blackbox")}
    out = []
    for mn, m in sorted(mods.items()):
        if mn in lib_cells or src_name(mn).endswith("_w"):
            continue
        if unit and not m.get("attributes", {}).get("top"):
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
        edge = own == top and not unit

        def pin(p):
            """(module, pin, name) of a cut child's pin; None for the ICG's
            or a clock's."""
            cell, typ, pn, _ = t.cut[p]
            if typ in lib_cells or is_clock(pn):
                return None
            return src_name(typ), pn, "%s.%s" % (cell, pn)

        def start(p):
            if p in t.cut:
                c = pin(p)
                return (budgets.required(c[0], c[1]), c[2], True) if c else (None, None, True)
            if is_clock(p):
                return None, None, False
            return (STAGE - PORT if edge else budgets.arrival(own, p)), p, False

        def end(p):
            if p in t.cut:
                c = pin(p)
                return (budgets.arrival(c[0], c[1]), c[2], True) if c else (None, None, True)
            if edge:
                return None, p, False      # the flattened pass: straight from a flop
            return budgets.required(own, p), p, False

        if unit:
            where = "%s (unit %s)" % (own, unit)
        else:
            where = "block %s, in %s" % (name, own)
        if t.rr > STAGE + EPS and not unit:
            out.append(("NGD-1", "%s: flop to flop %.1f NGD, over the %g stage"
                        % (where, t.rr, STAGE)))
        for p in t.ins:
            a, nm, kid = start(p)
            if (kid or not unit) and a is not None and t.ir[p] > NEG and a + t.ir[p] > STAGE + EPS:
                out.append(("budgets %s>flops" % nm, "%s: %s, starting at %g, reaches a flop at "
                            "%.1f, over the %g stage" % (where, nm, a, a + t.ir[p], STAGE)))
        for p in t.outs:
            r, nm, kid = end(p)
            if (kid or not unit) and r is not None and t.ro[p] > r + EPS:
                out.append(("budgets flops>%s" % nm, "%s: %s, required at %g, is reached from "
                            "a flop at %.1f" % (where, nm, r, t.ro[p])))
        for (p, q), dl in sorted(t.io.items()):
            (a, na, ka), (r, nr, kr) = start(p), end(q)
            if not (ka or kr) or (ka and na is None) or (kr and nr is None) or is_clock(p):
                continue
            if dl > EPS:
                out.append(("NGD-5 %s>%s" % (na, nr), "NGD-5 %s: %.1f NGD of logic from %s to %s, "
                            "a path that touches none of its flops" % (where, dl, na, nr)))
            elif a is not None and r is not None and a > r + EPS:
                out.append(("budgets %s>%s" % (na, nr), "%s: budgets do not converge: %s, "
                            "starting at %g, reaches %s, required at %g" % (where, na, a, nr, r)))
    return out


def block_check(name, top, files, bbs, budgets, block=None, lib=LIB):
    """A block assembled: first converged from its budget files, level by
    level; then timed whole, flattened, every flop-to-flop path within the
    stage, every output straight from a flop, every input into its flops
    within the default port budget. `block` is the block's own module (the
    partition's top may be its hardening wrapper). Returns (line, failures)."""
    fails = [msg for _, msg in converge(name, block or top, files, bbs, budgets, lib)]
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
    modules = design_modules()
    parents = parented(units, modules)
    if only:
        units = [u for u in units if u.name == only]
        if not units:
            raise SystemExit("check-ngd: no unit %s" % only)
    budgets = Budgets.load()
    for u in units:
        u.measure(budgets=budgets, modules=modules)
        report(u, verbose=bool(only))
    if only:
        for _, msg in findings(units[0], budgets, parents):
            print("    " + msg)
        return 0
    ratchet = load(RATCHET, "modules", {})
    fails = policy(units, budgets, ratchet, modules)
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
          ("ngd_fx_ok", "ngd_fx_out", "ngd_fx_in", "ngd_fx_thru", "ngd_fx_stage",
           "ngd_fx_wire")}
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
    f = msgs(converge("fx_asm_gap", "ngd_fx_asm_gap", files, [], fb))
    expect(any(x.startswith("NGD-5") and "u_src.y to u_dst.a" in x for x in f),
           "glue between two children passed: %s" % f)
    f = msgs(converge("fx_asm_igap", "ngd_fx_asm_inner_gap", files, [], fi))
    expect(any(x.startswith("NGD-5") and "u_src.y to u_dst.a" in x for x in f),
           "an inner helper between two children passed: %s" % f)
    f = msgs(converge("fx_asm_inner", "ngd_fx_asm_inner", files, [], fi))
    expect(not f, "an inner helper before its parent's flop was refused: %s" % f)
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
              "inner helpers alone and inside a parent, registers shared by an output and the "
              "rest, observation ports, budget files, ratchet, coverage, glue, the assembled "
              "block from its budgets and whole (%d controls)"
              % checks)
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
