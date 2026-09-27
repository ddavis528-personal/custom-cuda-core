#!/usr/bin/env python3
"""The sequential repeater's enables, checked on the netlist Yosys infers.

  tools/check-rpt-enables.py [--file=rtl/phys/ccv_seq_rpt.sv]

Simulation cannot see this: a payload register that loads every cycle carries
the same data as one enabled by valid, since the payload only matters when
due. What differs is power, which is the point of the enable. So for each
configuration below, Yosys elaborates the repeater (`proc; opt`) and, stage
by stage, every flop must be one of:

  - payload and trace id: an enable flop whose enable is THIS stage's valid
    flop -- the previous cycle's valid;
  - lead slice: an enable flop whose enable is the stage's INPUT valid -- the
    same cycle's, since a lead rides with valid;
  - valid, wake, credit, stall: one each per stage, with reset, no enable.

Anything else fails, with the flop named. `--file` checks a (mutated) copy,
which is how tools/check-phys.sh proves the check can fail.
"""
import json
import os
import subprocess
import sys
import tempfile

ROOT = os.path.dirname(os.path.dirname(os.path.abspath(__file__)))
CONFIGS = [  # (stages, slots, width, lead mask, trace)
    (1, 1, 8, 0x0, False),
    (3, 1, 12, 0x0, True),
    (2, 1, 20, 0xf, True),
    (4, 1, 16, 0x0c1, False),
    (2, 4, 10, 0x3, True),
]


def netlist(path, stages, slots, width, lead, trace, tmp):
    out = os.path.join(tmp, "rpt.json")
    d = "-DCCV_TRACE " if trace else ""
    script = ("read_verilog -sv -formal %s-Irtl/include -Irtl/generated "
              "rtl/ccv_assert_pkg.sv %s; chparam -set STAGES %d -set SLOTS %d "
              "-set PAYLOAD_W %d -set LEAD_MASK %d ccv_seq_rpt; hierarchy -top "
              "ccv_seq_rpt; proc; opt; write_json %s"
              % (d, path, stages, slots, width, lead, out))
    r = subprocess.run(["yosys", "-q", "-p", script], cwd=ROOT,
                       capture_output=True, text=True)
    if r.returncode:
        sys.exit("yosys failed: %s" % (r.stderr or r.stdout)[:500])
    return json.load(open(out))["modules"]["ccv_seq_rpt"]


def check(mod, stages, slots, width, lead, trace):
    # Every net name a bit carries, so a flop is named by what it drives.
    names = {}
    for n, v in mod["netnames"].items():
        for i, b in enumerate(v["bits"]):
            names.setdefault(b, set()).add((n, i))

    def bit(net, i=0):
        return mod["netnames"][net]["bits"][i]

    def valid_at(node, j):   # slot j's valid on node `node`
        return (bit("src_valid", j) if node == 0
                else bit("g_stage[%d].valid_q" % (node - 1), j))

    bad = []
    pulse_bits = {}
    for cname, c in mod["cells"].items():
        t = c["type"]
        if "dff" not in t:
            continue
        q = c["connections"]["Q"]
        en = c["connections"].get("EN")
        who = sorted(names.get(q[0], {("?", 0)}))
        net = next((n for n, _ in who if n.startswith("g_stage[")), None)
        if net is None:
            if all(n.startswith("$formal") for n, _ in who):
                continue          # the known-assertion's plumbing, under -formal
            bad.append("flop %s drives %s, which is no stage's" % (cname, who[0][0]))
            continue
        k = int(net[len("g_stage["):net.index("]")])
        reg = net.split(".")[-1]
        if reg in ("valid_q", "wake_q", "credit_q", "stall_q"):
            if en is not None or "sdff" not in t:
                bad.append("%s: a pulse, must be reset and never enabled (is %s)" % (net, t))
            pulse_bits[(k, reg)] = pulse_bits.get((k, reg), 0) + len(q)
            continue
        j = int(net.split("g_slot[")[1].split("]")[0]) if "g_slot[" in net else 0
        if reg in ("pay_q", "tid_q"):
            want = bit("g_stage[%d].valid_q" % k, j)
            why = "this stage's slot-%d valid (the previous cycle's)" % j
            mask = ~lead if reg == "pay_q" else -1
        elif reg == "lead_q":
            want, why = valid_at(k, j), "the stage's slot-%d input valid (the same cycle's)" % j
            mask = lead
        else:
            bad.append("%s: an unexpected register" % net)
            continue
        # Only the bits this register exists for: a payload register's lead
        # positions are dead, and so are a lead register's others.
        live = [i for i in range(len(q)) if (mask >> _off(names, q[i], net)) & 1]
        if not live:
            continue
        if en is None:
            bad.append("%s: loads every cycle; must be enabled by %s" % (net, why))
        elif en[0] != want:
            bad.append("%s: enabled by %s, not by %s"
                       % (net, sorted(names.get(en[0], {("?", 0)}))[0][0], why))
    for k in range(stages):
        for reg, n in (("valid_q", slots), ("credit_q", slots),
                       ("stall_q", slots), ("wake_q", 1)):
            if pulse_bits.get((k, reg)) != n:
                bad.append("g_stage[%d].%s: %s flop bits, want %d"
                           % (k, reg, pulse_bits.get((k, reg), 0), n))
    return bad


def _off(names, b, net):
    """The bit's index within `net`."""
    for n, i in names.get(b, ()):
        if n == net:
            return i
    return 0


def main():
    path = "rtl/phys/ccv_seq_rpt.sv"
    for a in sys.argv[1:]:
        if a.startswith("--file="):
            path = a.split("=", 1)[1]
    fails = 0
    with tempfile.TemporaryDirectory() as tmp:
        for stages, slots, width, lead, trace in CONFIGS:
            bad = check(netlist(path, stages, slots, width, lead, trace, tmp),
                        stages, slots, width, lead, trace)
            tag = "STAGES=%d SLOTS=%d W=%d LEAD=%#x%s" % (
                stages, slots, width, lead, " +trace" if trace else "")
            if bad:
                fails += 1
                print("RPT_ENABLES %s: %d finding(s)" % (tag, len(bad)))
                for m in bad[:6]:
                    print("  " + m)
            else:
                print("RPT_ENABLES %s: ok" % tag)
    return 1 if fails else 0


if __name__ == "__main__":
    sys.exit(main())
