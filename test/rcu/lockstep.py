#!/usr/bin/env python3
"""Block lock-step (docs/rcu-impl.md section 5, step 3): ccv_rcu's RTL
replayed against the model's ports, from a ccv-skel --port-dump of the RCU
recorded with the model in place (RA-34).

    test/rcu/lockstep.py [--build DIR] [--keep] DUMP.vcd [DUMP.vcd ...]

Every input the dump holds drives the RTL, one cycle a sample; every
output the RTL drives is compared with the model's, every cycle. The
outputs come straight from flops (the block's NGD rule), so the value
during cycle t is the model's at sample t. A payload is compared
where it carries a message: its lead fields in the valid cycle, the rest
in the cycle after (schema: valid leads the payload). The first divergence of each
dump is printed with the ports that differ and, for a payload, its
fields (sim/generated/ccv_skel_wiring.h's layout); later
cycles are not compared, since a replay is open-loop from there.

The CSR ports are tied idle, as the dump says a replay does; CCV_CHECK
and CCV_TRACE are not defined.

Exit 0 when every dump is identical at every output on every cycle."""
import argparse
import hashlib
import os
import re
import shutil
import subprocess
import sys

sys.path.insert(0, os.path.dirname(os.path.abspath(__file__)))
import evmon  # noqa: E402

ROOT = os.path.dirname(os.path.dirname(os.path.dirname(os.path.abspath(__file__))))
PORTS = os.path.join(ROOT, "rtl/top/ports/ccv_rcu_ports.svh")
SCOPE = "u_rcu"


def param(name):
    txt = open(os.path.join(ROOT, "rtl/generated/ccv_params_pkg.sv")).read()
    return int(re.search(r"localparam int %s = (\d+);" % name, txt).group(1))


ROWS = param("CCV_P_PHYS_REGS")
NK = param("CCV_SECTIONS")
NL = 32
NP_ALL = param("CCV_L_OPERANDS_PER_LANE") + 1   # three sources and merge_data
_DEC = open(os.path.join(ROOT, "rtl/rcu/rcu_dec_pkg.sv")).read()
CLS_READS = int(re.search(r"CLS_READS = (\d+)", _DEC).group(1))
CLS_ISLOT = int(re.search(r"CLS_ISLOT = (\d+)", _DEC).group(1))
CLS_UNIT = int(re.search(r"CLS_UNIT = (\d+)", _DEC).group(1))
CLS_MK = int(re.search(r"CLS_MK = (\d+)", _DEC).group(1))
U_LANE, U_SFU = (int(re.search(r"U_%s = 3'd(\d)" % u, _DEC).group(1)) for u in ("LANE", "SFU"))
MK_STORE, MK_FENCE = (int(re.search(r"MK_%s = 3'd(\d)" % u, _DEC).group(1)) for u in ("STORE", "FENCE"))
MK_PSTORE = int(re.search(r"MK_PSTORE = 3'd(\d)", _DEC).group(1))
NSLOTS = len(set(re.findall(r"\booe_rcu_issue_s(\d+)_valid\b", open(PORTS).read())))   # issue slots
CLOCK = "core_clk"
# RCU's Q-53 checkers, bound into ccv_rcu in every replay: the module, then its bind.
Q53 = ("test/rcu/rcu_q53_chk.sv", "test/rcu/rcu_q53_bind.svh")
Q53C = ("arrival", "pair", "rzero", "rdup", "iso")


def port_dirs():
    """name -> 'input'/'output' for the ports outside `ifdef`."""
    dirs, depth = {}, 0
    for line in open(PORTS):
        s = line.strip()
        if s.startswith("`ifdef") or s.startswith("`ifndef"):
            depth += 1
            continue
        if s.startswith("`endif"):
            depth -= 1
            continue
        if depth:
            continue
        m = re.match(r",?\s*(input|output)\s+(.*?)\s*(\w+)\s*,?\s*$", s)
        if m:
            dirs[m.group(3)] = m.group(1)
    return dirs


def read_dump(path, names):
    """(widths, samples): each port's value just before every rising edge."""
    ids, widths = {}, {}
    stack, snaps, cur, start = [], [], {}, None
    with open(path) as f:
        header = True
        for line in f:
            line = line.strip()
            if not line:
                continue
            if header:
                if line.startswith("$scope"):
                    stack.append(line.split()[2])
                elif line.startswith("$upscope"):
                    stack.pop()
                elif line.startswith("$var"):
                    p = line.split()
                    if stack and stack[-1] == SCOPE and (p[4] in names or p[4] == CLOCK):
                        ids.setdefault(p[3], []).append(p[4])
                        widths[p[4]] = int(p[2])
                elif line.startswith("$enddefinitions"):
                    header = False
                continue
            c = line[0]
            if c == "#":
                start = dict(cur)
                continue
            if c == "$":
                continue
            if c in "bB":
                val, vid = line[1:].split()
            elif c in "01xXzZ":
                val, vid = c, line[1:]
            else:
                continue
            v = int(re.sub(r"[xXzZ]", "0", val), 2)
            for n in ids.get(vid, ()):
                if n == CLOCK and v == 1 and cur.get(CLOCK, 0) == 0 and start is not None:
                    snaps.append(start)
                cur[n] = v
    return widths, snaps


def pack(snap, names, widths):
    v, off = 0, 0
    for n in names:
        v |= (snap.get(n, 0) & ((1 << widths[n]) - 1)) << off
        off += widths[n]
    return v


def chan_fields():
    """channel (ccv_ dropped) -> [(field, lsb, width)], from the skeleton's
    generated layout (sim/generated/ccv_skel_wiring.h), the same bits the
    dump writes."""
    out, cur = {}, None
    for line in open(os.path.join(ROOT, "sim/generated/ccv_skel_wiring.h")):
        m = re.match(r"inline constexpr FieldDesc kF_ccv_(\w+)\[\]", line)
        if m:
            cur = out.setdefault(m.group(1), [])
            continue
        m = re.match(r'\s*\{"(\w+)", (\d+), (\d+), (true|false)', line)
        if m and cur is not None:
            cur.append((m.group(1), int(m.group(2)), int(m.group(3)), m.group(4) == "true"))
        elif line.startswith("};"):
            cur = None
    return out


def lead_mask(port, chans):
    ch = re.sub(r"(_c\d+|_s\d+)?_payload$", "", port)
    m = 0
    for _, lsb, w, lead in chans.get(ch, ()):
        if lead:
            m |= ((1 << w) - 1) << lsb
    return m


def dec_classes():
    """(opcode, done_row) -> class word, from rcu_dec_pkg.sv (generated from
    the model's own decode, sim/rcu/rcu_decode.h): the same table both sides
    read. done_row is None but for an atomic, whose step it picks."""
    cls, atom = {}, None
    for line in open(os.path.join(ROOT, "rtl/rcu/rcu_dec_pkg.sv")):
        m = re.match(r"\s*(\d+): case \(drow\)", line)
        if m:
            atom = int(m.group(1))
            continue
        m = re.match(r"\s*2'd(\d): c = \d+'h([0-9a-fA-F]+);", line)
        if m and atom is not None:
            cls[(atom, int(m.group(1)))] = int(m.group(2), 16)
            continue
        if "endcase" in line:
            atom = None
        # A copy's two forms (pcopy ? a : b) differ only below CLS_READS.
        m = re.match(r"\s*(\d+): c = (?:pcopy \? \d+'h[0-9a-fA-F]+ : )?\d+'h([0-9a-fA-F]+);", line)
        if m:
            cls[(int(m.group(1)), None)] = int(m.group(2), 16)
    return cls


def lane_class(cls, op):
    """The class of a lane message's opcode: an atomic's one lane step."""
    if (op, None) in cls:
        return cls[(op, None)]
    steps = [c for (o, _), c in cls.items() if o == op and (c >> CLS_UNIT) & 7 in (U_LANE, U_SFU)]
    return steps[0] if len(steps) == 1 else None


def issues_at(snap, chans):
    """The lead issues (no continuation) whose payload is in this sample:
    slot -> {field: value}."""
    f = {n: (l, w) for n, l, w, _ in chans["ooe_rcu_issue"]}
    out = {}
    for k in range(NSLOTS):
        v = snap.get("ooe_rcu_issue_s%d_payload" % k, 0)
        d = {n: (v >> l) & ((1 << w) - 1) for n, (l, w) in f.items()}
        if not d["cont"]:
            out[k] = d
    return out


# rcu_lane_ops' per-section fields: entries per section (LAYOUT in the
# schema's doc: S0 at the LSBs, ports section-major).
LANE_SEC_FIELDS = {"sec_opcode": 1, "sec_owner": 1, "sec_pred_data": 1,
                   "sec_dst_pos": 1, "sec_dst_width": 1,
                   "sec_opnd_pos": NP_ALL, "sec_opnd_width": NP_ALL, "operand_byp": NP_ALL}


def lane_ops_care(fields, lead_pay, pay, cls, iss):
    """The bits of one rcu_lane_ops payload a lane consumes, in its payload
    cycle. A section section_en leaves clear carries nothing (RTL holds its
    data-gated flops; the model sends zeros). In a section that is held,
    an operand port's byte counts only when the op reads that port or takes
    its immediate there: the lane reads nothing else, and rcu_lanes loads
    an operand byte only for a port in use (op_en). merge_data counts only
    where the section's op has merge_en (the schema: don't-care at 0); iss
    is the issues the message came from (issues_at, two samples back), and
    a section none of them covers keeps its merge_data compared. Everything
    else in the payload is compared."""
    f = {n: (lsb, w) for n, lsb, w, _ in fields}
    lsb, w = f["section_en"]
    en = (lead_pay >> lsb) & ((1 << w) - 1)
    olsb, ow = f["sec_opcode"]
    wo = ow // NK
    care = (1 << max(l + w for l, w in f.values())) - 1
    for k in range(NK):
        if not (en >> k) & 1:
            for name, per in LANE_SEC_FIELDS.items():
                l, w = f[name]
                ew = w // (NK * per)
                care &= ~(((1 << (ew * per)) - 1) << (l + k * ew * per))
            for name, ports in (("operand", NP_ALL - 1), ("merge_data", 1)):
                l, _ = f[name]
                for i in range(ports):
                    care &= ~(0xff << (l + 32 * i + 8 * k))
            continue
        own = [d for slot, d in iss.items() if slot < NK and (d["footprint"] >> k) & 1]
        if len(own) == 1 and not own[0]["merge_en"]:
            l, _ = f["merge_data"]
            care &= ~(0xff << (l + 8 * k))
        c = lane_class(cls, (pay >> (olsb + k * wo)) & ((1 << wo) - 1))
        if c is None:
            continue
        reads, islot = (c >> CLS_READS) & 7, (c >> CLS_ISLOT) & 3
        l, _ = f["operand"]
        for i in range(NP_ALL - 1):
            if not ((reads >> i) & 1 or islot == i):
                care &= ~(0xff << (l + 32 * i + 8 * k))
    return care


def miu_addr_care(fields, pay, cls, iss):
    """The bits of one rcu_miu_addr payload MIU reads: store_data only for a
    store or a predicate store, base and index for every memop but a fence
    (rcu_mem: a group the memop does not use holds its value, don't-care on
    the wire; the model sends zeros). The memop is the issue in iss with the
    message's rob_tag; with none, the whole payload is compared."""
    f = {n: (l, w) for n, l, w, _ in fields}
    l, w = f["rob_tag"]
    tag = (pay >> l) & ((1 << w) - 1)
    care = (1 << max(l + w for l, w in f.values())) - 1
    for d in iss.values():
        if d["rob_tag"] != tag:
            continue
        c = cls.get((d["opcode"], None), cls.get((d["opcode"], d["done_row"])))
        if c is None:
            break
        mk = (c >> CLS_MK) & 7
        drop = [] if mk in (MK_STORE, MK_PSTORE) else ["store_data"]
        if mk == MK_FENCE:
            drop += ["base_per_lane", "index_per_lane"]
        for n in drop:
            l, w = f[n]
            care &= ~(((1 << w) - 1) << l)
        break
    return care


def care_masks(outs, widths, chans, snaps):
    """Per cycle, the output bits that carry a message: a payload's lead
    fields in its valid cycle, the rest in the cycle after (the schema's
    valid lead), narrowed on rcu_lane_ops and rcu_miu_addr to what their
    receivers read (lane_ops_care, miu_addr_care); kill_ack_epoch while the
    model's kill_ack is high (a level: RAU reads the epoch only with it);
    every other output always."""
    cls = dec_classes()
    layout, off = [], 0
    for n in outs:
        w = widths[n]
        if n.endswith("_payload"):
            full = (1 << w) - 1
            lm = lead_mask(n, chans) & full
            ch = re.sub(r"(_c\d+|_s\d+)?_payload$", "", n)
            layout.append((off, n[:-len("_payload")] + "_valid", lm, full & ~lm, n,
                           ch if ch in ("rcu_lane_ops", "rcu_miu_addr") else None))
        elif n == "kill_ack_epoch":
            layout.append((off, "kill_ack", (1 << w) - 1, 0, n, "ack"))
        else:
            layout.append((off, None, (1 << w) - 1, 0, n, None))
        off += w
    out, prev = [], {}
    for t, s in enumerate(snaps):
        iss = issues_at(snaps[t - 2], chans) if t >= 2 else {}
        m = 0
        for o, v, now, nxt, n, kind in layout:
            if v is None:
                m |= now << o
            elif kind == "ack":
                if s.get(v):
                    m |= now << o
            else:
                if s.get(v):
                    m |= now << o
                if prev.get(v):
                    if kind == "rcu_lane_ops":
                        nxt &= lane_ops_care(chans[kind], prev.get(n, 0), s.get(n, 0), cls, iss)
                    elif kind == "rcu_miu_addr":
                        nxt &= miu_addr_care(chans[kind], s.get(n, 0), cls, iss)
                    m |= nxt << o
        out.append(m)
        prev = s
    return out


def fields_diff(port, a, b, chans):
    """The fields of payload port `port` that differ between a and b."""
    ch = re.sub(r"(_c\d+|_s\d+)?_payload$", "", port)
    diffs = []
    for name, lsb, w, _ in chans.get(ch, ()):
        fa, fb = (a >> lsb) & ((1 << w) - 1), (b >> lsb) & ((1 << w) - 1)
        if fa != fb:
            diffs.append("%s rtl %x model %x" % (name, fa, fb))
    return "; ".join(diffs)


def build(bdir, ins, outs, widths, trace=0, watch=()):
    bdir = os.path.abspath(bdir)
    iw = sum(widths[n] for n in ins)
    ow = sum(widths[n] for n in outs)
    conns, off, ioff = [".%s(clk)" % CLOCK], 0, {}
    for p in ins:
        conns.append(".%s(in_v[%d +: %d])" % (p, off, widths[p]))
        ioff[p] = off
        off += widths[p]
    off = 0
    for p in outs:
        conns.append(".%s(out_v[%d +: %d])" % (p, off, widths[p]))
        off += widths[p]
    init = []
    for k in range(NK):
        for j in range(NL // 4):
            for r in range(ROWS):
                w = 0
                for l in range(4):
                    v = 0xdead0000 | r << 5 | (4 * j + l)
                    w |= ((v >> (8 * k)) & 0xff) << (8 * l)
                init.append("    dut.g_k[%d].g_j[%d].u_slice.g_row[%d].rq_cr03h = 32'h%08x;" % (k, j, r, w))
    tb = """// Generated by test/rcu/lockstep.py: the dump's inputs into ccv_rcu,
// its outputs written one line a cycle.
module rcu_ls_tb;
  logic clk = 1'b0;
  logic [%(iw)d-1:0] in_v;
  wire  [%(ow)d-1:0] out_v;
  ccv_rcu dut (%(conns)s);
  // RCU's Q-53 checkers (test/rcu/rcu_q53_chk.sv), bound into the block.
`include "rcu_q53_bind.svh"
  // The register file powers up as the model's does (sim/rcu/rcu_block.cpp:
  // physical GPR p, lane l holds 0xdead0000 | p << 5 | l), so a read of a
  // row nothing wrote compares like any other (+noinit, control init: not).
  initial if (!$test$plusargs("noinit")) begin
%(init)s
  end
  int n, fd, fi, fe;
  string base;
  // The Q-53 checkers' controls (lockstep.py --control arrival, pair, rzero,
  // rdup), each a fault forced into the block, which its checker must name:
  // arrival holds R's done valid a cycle after one ends; pair forces a
  // demotion launch with nothing paired; rzero and rdup force a restore map
  // onto the block's ports naming the zero register, or one row twice; iso
  // forces one naming rows 0-15, which the kernel then reads unrestored.
  string q53c = "";
  logic  q53p = 1'b0;
  int    q53t = -1;
  task automatic rcu_q53_ctl(input int t);
    if (q53c == "arrival") begin
      if (q53t < 0 && q53p && !dut.rcu_ooe_done_s5_valid) begin
        q53t = t;
        force dut.rcu_ooe_done_s5_valid = 1'b1;
      end else if (q53t >= 0 && t == q53t + 1) release dut.rcu_ooe_done_s5_valid;
      q53p = dut.rcu_ooe_done_s5_valid;
    end
    if (q53c == "pair") begin
      if (t == 40) force dut.u_mig.dl_cr02h = 1'b1;
      if (t == 41) release dut.u_mig.dl_cr02h;
    end
    if (q53c == "rzero" || q53c == "rdup" || q53c == "iso") begin
      // Written into the stimulus (an input port's field cannot be forced).
      if (t == 40) in_v[%(map_v)d] = 1'b1;
      if (t == 41) begin
        ccv_ooe_rcu_map_t mp;
        mp = in_v[%(map_p)d +: $bits(ccv_ooe_rcu_map_t)];
        mp.direction = 1'b1;
        if (q53c == "rzero")    mp.gpr_map = 128'h0f0e0d0c0b0a090807060504030201ff;
        else if (q53c == "rdup") mp.gpr_map = 128'h0f0e0d0c0b0a09080706050403020101;
        else                     mp.gpr_map = 128'h0f0e0d0c0b0a09080706050403020100;
        in_v[%(map_p)d +: $bits(ccv_ooe_rcu_map_t)] = mp;
      end
    end
  endtask
%(watch)s
%(ev)s
  initial begin
    void'($value$plusargs("n=%%d", n));
    void'($value$plusargs("base=%%s", base));
    void'($value$plusargs("q53ctl=%%s", q53c));
    fi = $fopen({base, ".in"}, "r");
    fd = $fopen({base, ".obs"}, "w");
    fe = $fopen({base, ".rtl.ev"}, "w");
    if ($test$plusargs("vcd")) begin
      $dumpfile({base, ".rtl.vcd"});
      $dumpvars(0, rcu_ls_tb);
    end
    for (int t = 0; t < n; t++) begin
      if ($fscanf(fi, "%%h", in_v) != 1) $fatal(1, "RCU-LS short stimulus at %%0d", t);
      rcu_q53_ctl(t);
      #1;
      $fdisplay(fd, "%%h", out_v);
      $fflush(fd);
      rcu_ev(t, fe);
      clk = 1'b1; #1; clk = 1'b0; #1;
    end
    $fclose(fd);
    $fclose(fe);
    $display("RCU-LS done %%0d", n);
    $finish;
  end
endmodule
""" % {"iw": iw, "ow": ow, "conns": ",\n    ".join(conns), "init": "\n".join(init),
       "ev": evmon.sv("dut"),
       "map_v": ioff["ooe_rcu_map_valid"], "map_p": ioff["ooe_rcu_map_payload"],
       "watch": "\n".join('  always @(dut.%s) $display("WATCH %%0d %s %%h", $time / 3, dut.%s);' % (w, w, w)
                          for w in watch)}
    os.makedirs(bdir, exist_ok=True)
    tf = os.path.join(bdir, "rcu_ls_tb.sv")
    old = open(tf).read() if os.path.exists(tf) else None
    exe = os.path.join(bdir, "obj", "rcu_ls_tb")
    rtl = sorted(os.path.join(ROOT, "rtl/rcu", f) for f in os.listdir(os.path.join(ROOT, "rtl/rcu"))
                 if f.endswith(".sv") and f != "rcu_dec_pkg.sv")
    # The binary is reused only for the same testbench and the same RTL.
    h = hashlib.sha256()
    for f in rtl + [os.path.join(ROOT, f) for f in ("rtl/rcu/rcu_dec_pkg.sv", "rtl/clk/ccv_common_clk.sv",
                                                     "rtl/generated/ccv_params_pkg.sv") + Q53]:
        h.update(open(f, "rb").read())
    tb += "// trace %d, rtl %s\n" % (trace, h.hexdigest()[:16])
    if old == tb and os.path.exists(exe):
        return exe
    open(tf, "w").write(tb)
    cmd = (["verilator", "--binary", "--timing", "-j", "0", "-O2", "--assert",
            "-Wno-fatal", "-Wno-lint", "-Wno-style", "--top-module", "rcu_ls_tb"]
           + ["-I" + os.path.join(ROOT, d) for d in ("rtl/include", "rtl/generated", "rtl/top/ports", "test/rcu")]
           + (["--trace", "--trace-depth", str(trace)] if trace else [])
           + ["--Mdir", os.path.join(bdir, "obj"), "-o", "rcu_ls_tb"]
           + [os.path.join(ROOT, f) for f in ("rtl/generated/ccv_params_pkg.sv", "rtl/ccv_assert_pkg.sv",
                                              "rtl/rcu/rcu_dec_pkg.sv", "rtl/ctech/sim/ccv_common_ctech_icg.sv",
                                              "rtl/clk/ccv_common_clk.sv")]
           + rtl + [os.path.join(ROOT, Q53[0]), tf])
    r = subprocess.run(cmd, cwd=bdir, capture_output=True, text=True)
    if r.returncode:
        sys.exit("lockstep: build failed:\n" + (r.stdout + r.stderr)[-3000:])
    return exe


def flip_operand(snaps, outs, widths, chans, care):
    """Control opnd: flip the expected value of the first operand bit a lane
    consumes (the care mask holds it), on lane 0's rcu_lane_ops."""
    port = "rcu_lane_ops_c00_payload"
    off = sum(widths[n] for n in outs[:outs.index(port)])
    lsb, w = next((l, w) for n, l, w, _ in chans["rcu_lane_ops"] if n == "operand")
    for t, c in enumerate(care):
        m = (c >> (off + lsb)) & ((1 << w) - 1)
        if m:
            snaps[t][port] = snaps[t].get(port, 0) ^ ((m & -m) << lsb)
            return
    sys.exit("lockstep: control opnd: no consumed operand bit in the dump")


def main():
    ap = argparse.ArgumentParser()
    ap.add_argument("--build", default=os.path.join(ROOT, "build/rcu-ls"))
    ap.add_argument("--show", type=int, default=12, help="ports shown at a divergence")
    ap.add_argument("--vcd", type=int, default=0, metavar="DEPTH",
                    help="build with tracing to DEPTH and write <dump>.rtl.vcd")
    ap.add_argument("--triage", action="store_true",
                    help="past the first divergence, each port's own first one (open-loop: a triage aid)")
    ap.add_argument("--credit-lead", type=int, default=0, metavar="N",
                    help="cycles the RTL's credits lead the model's (default 0, strict): the "
                         "model credits issue and lane results in the landing cycle "
                         "(creditAtLanding), as the RTL's <ch>_v_q does (RI-36); a triage aid")
    ap.add_argument("--control", choices=("init", "opnd", "ev", "gate", "row", "lead") + Q53C,
                    help="a negative control, which must diverge on every dump: init leaves "
                         "the RTL's register file unmatched to the model's power-up; opnd flips "
                         "one consumed operand bit of the dump's first lane message; ev drops the "
                         "model's first compared event; gate drops its first idle, so the clock "
                         "gate's first sleep finds the model busy; row flips a bit of the first "
                         "written row's value; lead holds the RTL's credits a cycle ahead of the "
                         "model's (--credit-lead 1), so the strict credit compare must fail; "
                         "arrival, pair, rzero, rdup and iso force a fault the Q-53 checker of that "
                         "name must report (rcu_q53_ctl in the testbench)")
    ap.add_argument("--watch", action="append", default=[], metavar="PATH",
                    help="print a signal under ccv_rcu (e.g. u_pred.g_row[6].pq_cr02h) at each change, "
                         "with its cycle (a triage aid)")
    ap.add_argument("--replayed", action="store_true",
                    help="each dump is a run that already happened (test/rcu/svh.py: the SV top "
                         "with the RTL driving and the model shadowing): its outputs are "
                         "<dump>.obs and its events <dump>.rtl.ev beside it, compared as a "
                         "replay's; nothing is built or run")
    ap.add_argument("dumps", nargs="+")
    a = ap.parse_args()
    a.build = os.path.abspath(a.build)
    if a.control == "lead":
        a.credit_lead = 1
    dirs = port_dirs()
    chans = chan_fields()
    exe, fail, diverged, q53hit = None, 0, set(), set()
    for d in a.dumps:
        widths, snaps = read_dump(d, set(dirs))
        missing = sorted(n for n in dirs if n not in widths and not n.startswith("csr_"))
        if missing:
            sys.exit("lockstep: %s lacks %s" % (d, ", ".join(missing[:8])))
        for n in dirs:
            widths.setdefault(n, 1 if n.endswith(("_valid", "_credit", "_stall", "_wake")) else 0)
        ins = sorted(n for n, k in dirs.items() if k == "input" and widths[n] and n != CLOCK)
        outs = sorted(n for n, k in dirs.items() if k == "output" and widths[n])
        if a.credit_lead:
            # The model's credit stream, a.credit_lead cycles earlier: what the
            # RTL is held to. Everything else in the sample is unchanged.
            cr = [n for n in outs if n.endswith("_credit")]
            snaps = [dict(s, **{n: (snaps[t + a.credit_lead].get(n, 0) if t + a.credit_lead < len(snaps) else 0)
                                for n in cr}) for t, s in enumerate(snaps)]
        if a.replayed:
            base = os.path.splitext(d)[0]
        elif exe is None:
            exe = build(a.build, ins, outs, widths, a.vcd, a.watch)
        if not a.replayed:
            base = os.path.join(a.build, os.path.splitext(os.path.basename(d))[0])
        iw = sum(widths[n] for n in ins)
        if a.replayed:
            # The run happened in the SV top; its assertions are its own log's.
            r = subprocess.CompletedProcess([], 0, "RCU-LS done\n", "")
        else:
            with open(base + ".in", "w") as f:
                for s in snaps:
                    f.write("%0*x\n" % ((iw + 3) // 4, pack(s, ins, widths)))
            # Assertions report and the replay runs on, so the outputs are
            # compared to the end; each failing assertion is named once.
            r = subprocess.run([exe, "+n=%d" % len(snaps), "+base=" + base, "+verilator+error+limit+1000000"]
                               + (["+vcd"] if a.vcd else []) + (["+noinit"] if a.control == "init" else [])
                               + (["+q53ctl=" + a.control] if a.control in Q53C else []),
                               capture_output=True, text=True)
        asserts = {}
        for m in re.finditer(r"\[(\d+)\] %Error: (\S+): Assertion failed in (\S+)", r.stdout + r.stderr):
            key = re.sub(r"\[\d+\]", "[N]", m.group(3))
            asserts.setdefault(key, [int(m.group(1)) // 3, 0])[1] += 1
        if a.control in Q53C and any(k.rstrip(":").endswith("q53_" + a.control) for k in asserts):
            q53hit.add(d)
        for k, (c, cnt) in sorted(asserts.items(), key=lambda kv: kv[1][0]):
            print("%s: ASSERTION %s, first at cycle %d, %d failures" % (d, k, c, cnt))
            fail = 1
            diverged.add(d)
        for line in r.stdout.splitlines():
            if line.startswith("WATCH "):
                print("%s: %s" % (d, line))
        if "RCU-LS done" not in r.stdout:
            print("%s: replay stopped:\n%s" % (d, (r.stdout + r.stderr)[-1500:]))
            fail = 1
            diverged.add(d)
        obs = [int(l, 16) for l in open(base + ".obs") if l.strip()]
        first = None
        # A wake output in the dump is derived, the latest legal one: the
        # RTL's must be high wherever it is (earlier is legal, later is not).
        wmask = pack({n: -1 for n in outs if n.endswith("_wake")}, outs, widths)
        care = care_masks(outs, widths, chans, snaps)
        if a.control == "opnd":
            flip_operand(snaps, outs, widths, chans, care)
        for t, s in enumerate(snaps[:len(obs)]):
            want = pack(s, outs, widths)
            if (obs[t] ^ want) & care[t] & ~wmask or want & wmask & ~obs[t]:
                first = t
                break
        # The events: the model's log beside the dump (CCV_RCU_EVLOG), the
        # RTL's from the monitor (test/rcu/evmon.py), every kind the monitor
        # derives, every cycle the replay ran.
        evs = ""
        mev = os.path.splitext(d)[0] + ".ev"
        if os.path.exists(mev):
            mod = evmon.read(mev)
            if a.control == "row":
                t0 = min(t for t, v in mod.items() if any(e[0] == "gpr_row" for e in v))
                i = next(i for i, e in enumerate(mod[t0]) if e[0] == "gpr_row")
                e = mod[t0][i]
                mod[t0][i] = e[:2] + (e[2] ^ 1,) + e[3:]
            if a.control == "ev":
                t0 = min(mod)
                mod[t0] = mod[t0][1:]
                if not mod[t0]:
                    del mod[t0]
            ed = evmon.compare(mod, evmon.read(base + ".rtl.ev"), len(obs))
            if ed:
                fail = 1
                diverged.add(d)
                print("%s: EVENTS DIVERGE at cycle %d: model %s, rtl %s" % (d, ed[0], ed[1], ed[2]))
            iev = mev
            if a.control == "gate":
                # The model busy from reset to its second idle: the gate's
                # first sleep must be caught.
                iev = base + ".gate.ev"
                lines = open(mev).readlines()
                i0 = next(i for i, l in enumerate(lines) if l.split()[1:2] == ["idle"])
                open(iev, "w").writelines(lines[:i0] + lines[i0 + 1:])
            it = evmon.idle_check(iev, base + ".rtl.ev", len(obs))
            if it is not None and not ed:
                fail = 1
                diverged.add(d)
                print("%s: EVENTS DIVERGE at cycle %d: the clock gate closed while the model is busy" % (d, it))
            evs = ", %d events" % sum(len(v) for v in mod.values())
        elif a.control in ("ev", "gate", "row"):
            sys.exit("lockstep: control %s: no model event log %s" % (a.control, mev))
        if first is None and len(obs) < len(snaps):
            print("%s: identical up to cycle %d" % (d, len(obs)))
            continue
        if first is None:
            if d not in diverged:
                print("%s: IDENTICAL, %d outputs over %d cycles%s" % (d, len(outs), len(snaps), evs))
            continue
        fail = 1
        diverged.add(d)
        got, want, off, shown = obs[first] & care[first], pack(snaps[first], outs, widths) & care[first], 0, 0
        print("%s: DIVERGES at cycle %d of %d" % (d, first, len(snaps)))
        for n in outs:
            w = widths[n]
            gv, wv = (got >> off) & ((1 << w) - 1), (want >> off) & ((1 << w) - 1)
            off += w
            if n.endswith("_wake"):
                bad = wv & ~gv
            else:
                bad = gv != wv
            if bad and shown < a.show:
                shown += 1
                fd = fields_diff(n, gv, wv, chans) if n.endswith("_payload") else ""
                print("  %s: rtl %x model %x%s" % (n, gv, wv, (" [" + fd + "]") if fd else ""))
        if a.triage:
            seen = set()
            print("  triage, each port group's first divergence:")
            for t in range(first, len(obs)):
                off = 0
                for n in outs:
                    w = widths[n]
                    cm = (care[t] >> off) & ((1 << w) - 1)
                    gv, wv = (obs[t] >> off) & cm, snaps[t].get(n, 0) & cm
                    off += w
                    bad = (wv & ~gv) if n.endswith("_wake") else gv != wv
                    key = re.sub(r"_c\d+_", "_cNN_", n)
                    if bad and key not in seen:
                        seen.add(key)
                        fd = fields_diff(n, gv, wv, chans) if n.endswith("_payload") else ""
                        print("    %d %s: rtl %x model %x%s" % (t, n, gv, wv, (" [" + fd + "]") if fd else ""))
    if a.control:
        for d in a.dumps:
            got = q53hit if a.control in Q53C else diverged
            print("%s: control %s %s" % (d, a.control, "caught" if d in got else "NOT CAUGHT"))
        return int(any(d not in (q53hit if a.control in Q53C else diverged) for d in a.dumps))
    return fail


if __name__ == "__main__":
    sys.exit(main())
