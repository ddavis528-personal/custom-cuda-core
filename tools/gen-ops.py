#!/usr/bin/env python3
"""Generate the opcode table, C++ and SystemVerilog, from params/ops.json
(RI-21 (4)).

    tools/gen-ops.py               write sim/generated/ccv_ops.h and
                                   rtl/generated/ccv_ops_pkg.sv
    tools/gen-ops.py --check       fail if either is stale; write nothing
    tools/gen-ops.py --selftest    the source's negative controls: each
                                   mutation (a duplicated key, a row inserted,
                                   removed or swapped, an unknown field ...)
                                   must be refused, and an append accepted
    tools/gen-ops.py --crosscheck  compile a C++ probe against the generated
                                   table (through sim/skel/stub.h) and a
                                   Verilator probe against ccv_op_attr, and
                                   compare every opcode's attributes field by
                                   field, so the two languages cannot drift

The skeleton's kOps[] was a hand table in sim/skel/stub.h, and an RTL decode
would have been a second hand copy of it. Both are generated here from one
source, whose rows are append-only: an opcode is its row's position + 1, so a
row inserted or removed would renumber every opcode after it. `pinned` in the
source holds every row's key in order, and a row whose key is not at its
position there is refused.

stub.h keeps struct OpInfo, its enums and the helpers (schedAttrOf,
immKindOf); ccv_ops.h is included where the table stood. ccv_op_attr()
encodes what an RTL decode reads per opcode, sched_attr and imm_kind among
them, computed here as stub.h computes them; --crosscheck holds the two to
each other through the compiled C++ and the elaborated SV.
"""
import copy
import json
import os
import re
import shutil
import subprocess
import sys
import textwrap
import genout

ROOT = os.path.dirname(os.path.dirname(os.path.abspath(__file__)))
SRC = os.path.join(ROOT, "params", "ops.json")
PARAMS = os.path.join(ROOT, "params", "ccv_params.json")
STUB = os.path.join(ROOT, "sim", "skel", "stub.h")
OUT_H = os.path.join(ROOT, "sim", "generated", "ccv_ops.h")
OUT_SV = os.path.join(ROOT, "rtl", "generated", "ccv_ops_pkg.sv")

# struct OpInfo's fields, in declaration order (sim/skel/stub.h): the ones
# with no default, then the defaulted ones with their defaults.
REQUIRED = ["name", "cls", "nsrc", "gdst", "pread", "pwrite", "guard", "pdata",
            "base_src", "index_src", "data_src", "disp_imm", "scale_imm",
            "alu_imm", "imm_slot"]
DEFAULTS = [("srd_sel", -1), ("or_lane", False), ("cross", False), ("byp", -1),
            ("slot_imm", -1), ("pxfer", False), ("local", False),
            ("old_dst_use", False), ("unread_fields", False), ("chw", 0),
            ("ret", False), ("shared", False)]
FIELDS = REQUIRED + [f for f, _ in DEFAULTS]
DEFAULT = dict(DEFAULTS)
BOOLS = {"gdst", "pread", "pwrite", "guard", "pdata", "or_lane", "cross",
         "pxfer", "local", "old_dst_use", "unread_fields", "ret", "shared"}
INT8 = {"base_src", "index_src", "data_src", "disp_imm", "scale_imm",
        "alu_imm", "imm_slot", "srd_sel", "slot_imm"}
ROW_EXTRA = {"note"}
TOP = {"doc", "pinned", "ops"}

BANNER = """GENERATED FILE -- DO NOT EDIT.

Produced by tools/gen-ops.py from params/ops.json (RI-21 (4)).
Edit the source and regenerate; tools/verify.sh fails if this file is stale."""

# ccv_op_attr()'s struct, MSB first: (field, width or the width's name).
ATTR = [("cls", "W_CLS"), ("nsrc", 3), ("gdst", 1), ("pread", 1), ("pwrite", 1),
        ("guard", 1), ("pdata", 1), ("cross_lane", 1), ("pxfer", 1), ("ret", 1),
        ("chw", 2), ("shared", 1), ("sched_attr", "W_SCHED_ATTR"),
        ("imm_kind", "W_IMM_KIND")]


class Refused(Exception):
    pass


# ---- what the source is read against -----------------------------------------

def stub_enums():
    """Every enumerator stub.h gives a value or an order, by name: UopClass's
    in order, and each `kName = N` of its anonymous enums."""
    text = open(STUB).read()
    m = re.search(r"enum UopClass : uint8_t \{([^}]*)\}", text)
    if not m:
        raise Refused("sim/skel/stub.h: no enum UopClass")
    classes = [c.strip() for c in m.group(1).split(",") if c.strip()]
    vals = {c: i for i, c in enumerate(classes)}
    for k, v in re.findall(r"\b(k[A-Z]\w*) = (\d+)\b", text):
        vals.setdefault(k, int(v))
    return classes, vals


def params():
    d = json.load(open(PARAMS))
    return {p["name"]: p["value"] for p in d["params"]}


def key(r):
    """A row's key: its name, and an srd selector's number (SRD is four
    opcodes, one per selector)."""
    sel = r.get("srd_sel", -1)
    return r["name"] + ("_SEL%d" % sel if isinstance(sel, int) and sel >= 0 else "")


def validate(d, classes, E, P):
    """Refuse a source that breaks a rule; return the rows, defaults filled."""
    for k in d:
        if k not in TOP:
            raise Refused("params/ops.json: unknown top-level key %r" % k)
    for k in TOP:
        if k not in d:
            raise Refused("params/ops.json: no %r" % k)
    rows = []
    for i, r in enumerate(d["ops"]):
        where = "params/ops.json row %d (opcode %d, %s)" % (i, i + 1, r.get("name"))
        for f in r:
            if f not in FIELDS and f not in ROW_EXTRA:
                raise Refused("%s: unknown field %r" % (where, f))
        for f in REQUIRED:
            if f not in r:
                raise Refused("%s: no %r, which struct OpInfo does not default" % (where, f))
        for f, dv in DEFAULTS:
            if f in r and r[f] == dv and type(r[f]) is type(dv):
                raise Refused("%s: %s spells out its default (%r): omit it" % (where, f, dv))
        x = dict(DEFAULT, **r)
        if not isinstance(x["name"], str) or not re.fullmatch(r"[A-Z][A-Z0-9_]*", x["name"]):
            raise Refused("%s: name must be upper-case letters, digits and _" % where)
        if x["cls"] not in classes:
            raise Refused("%s: cls %r is not a UopClass" % (where, x["cls"]))
        for f in BOOLS:
            if not isinstance(x[f], bool):
                raise Refused("%s: %s must be true or false" % (where, f))
        for f in INT8:
            if isinstance(x[f], bool) or not isinstance(x[f], int) or not -1 <= x[f] <= 127:
                raise Refused("%s: %s must be an integer, -1 for none" % (where, f))
        if isinstance(x["nsrc"], bool) or x["nsrc"] not in range(5):
            raise Refused("%s: nsrc must be 0 to 4" % where)
        if isinstance(x["chw"], bool) or x["chw"] not in (0, 1, 2):
            raise Refused("%s: chw must be 0, 1 or 2" % where)
        b = x["byp"]
        if isinstance(b, str):
            if not b.startswith("kByp") or b not in E:
                raise Refused("%s: byp %r is not a bypass group" % (where, b))
        elif isinstance(b, bool) or not isinstance(b, int) or b != -1:
            raise Refused("%s: byp must be a kByp* name" % where)
        rows.append(x)
    keys = [key(x) for x in rows]
    seen = {}
    for i, k in enumerate(keys):
        if k in seen:
            raise Refused("params/ops.json: rows %d and %d share the key %s"
                          % (seen[k], i, k))
        seen[k] = i
    pinned = d["pinned"]
    if len(set(pinned)) != len(pinned):
        raise Refused("params/ops.json: pinned repeats a key")
    for i in range(max(len(keys), len(pinned))):
        k = keys[i] if i < len(keys) else None
        p = pinned[i] if i < len(pinned) else None
        if k == p:
            continue
        if k is None:
            raise Refused("params/ops.json: %s (opcode %d) is pinned but has no row: "
                          "a row is never removed" % (p, i + 1))
        if p is None:
            raise Refused("params/ops.json: row %d (%s) is not pinned: append its key "
                          "to pinned with it" % (i, k))
        if p not in keys:
            raise Refused("params/ops.json: pinned %s (opcode %d) has no row: a row "
                          "is never removed" % (p, i + 1))
        # Inserted: this row's key is new, or the next row is the one pinned
        # here and this one is not pinned next (that is a swap).
        if k not in pinned or (i + 1 < len(keys) and keys[i + 1] == p and
                               (i + 1 >= len(pinned) or pinned[i + 1] != k)):
            raise Refused("params/ops.json: row %d (%s) is inserted before pinned %s "
                          "(opcode %d): rows are appended, never inserted" % (i, k, p, i + 1))
        raise Refused("params/ops.json: row %d is %s, pinned %s (opcode %d): rows "
                      "never move" % (i, k, p, i + 1))
    if len(rows) + 1 >= P["CCV_OP_PRF_COPY"]:
        raise Refused("params/ops.json: %d opcodes reach CCV_OP_PRF_COPY" % len(rows))
    for x in rows:
        if sched_attr(x, E) >> P["CCV_P_W_SCHED_ATTR"]:
            raise Refused("%s: sched_attr overflows CCV_P_W_SCHED_ATTR" % key(x))
    return rows


# ---- stub.h's derivations, mirrored (--crosscheck holds them equal) ----------

def byp_group(x, E):
    if x["byp"] != -1:
        return E[x["byp"]]
    if x["cross"]:
        return E["kBypCollective"]
    if x["cls"] in ("kLoad", "kStore", "kAtomic"):
        return E["kBypAddr"]
    if x["cls"] == "kPredLogic":
        return E["kBypPred"]
    return E["kBypInt"]


def exec_rcu(x):
    return x["cls"] in ("kPredLogic", "kBranch", "kImm") or x["cross"]


def sched_attr(x, E):
    """schedAttrOf() in sim/skel/stub.h."""
    c = x["cls"]
    mem = c in ("kLoad", "kStore", "kFence", "kAtomic")
    memk = (E["kMemKStore"] if c == "kStore" else E["kMemKFence"] if c == "kFence"
            else E["kMemKAtomic"] if c == "kAtomic" else E["kMemKLoad"])
    ctl = c in ("kExit", "kBarArrive", "kBarWait")
    ser = (E["kSerExit"] if c == "kExit" else E["kSerBarrier"] if c == "kBarWait"
           else E["kSerArrive"] if c == "kBarArrive" else E["kSerNop"] if c == "kNop"
           else E["kSerChwidth"] if x["chw"] else E["kSerNone"])
    lat = (E["kLatRcu"] if c == "kNop" else E["kLatL1"] if c == "kLoad"
           else E["kLatCompletion"] if c in ("kStore", "kFence", "kAtomic")
           else E["kLatCollective"] if x["cross"]
           else E["kLatRcu"] if exec_rcu(x) or ctl
           else E["kLatSfu"] if byp_group(x, E) == E["kBypSfu"] and x["byp"] != -1
           else E["kLatLane"])
    return (int(x["ret"]) << E["kAttrRetBit"] | byp_group(x, E) << 14 |
            int(mem) << 13 | int(exec_rcu(x) or ctl) << 12 | int(x["cross"]) << 11 |
            int(x["gdst"]) << 10 | int(x["pwrite"]) << 9 | (memk if mem else 0) << 7 |
            int(c == "kBranch") << 6 | ser << 3 | lat)


def imm_kind(x, E):
    """immKindOf() in sim/skel/stub.h."""
    if x["cls"] == "kPredLogic" or (x["cross"] and x["nsrc"] == 0):
        return E["kImmPredSrcs"]
    if x["cls"] == "kBranch" and x["gdst"]:
        return E["kImmCallLink"]
    return {0: E["kImmWarpBase"], 1: E["kImmCtaid"], 2: E["kImmLaneCtx"],
            3: E["kImmPrivOff"]}.get(x["srd_sel"], E["kImmLiteral"])


def attrs(x, classes, E):
    a = {f: int(x[f]) for f, _ in ATTR if f in x and f != "cls"}
    a["cls"] = classes.index(x["cls"])
    a["cross_lane"] = int(x["cross"])  # `cross` is an SV keyword
    a["sched_attr"] = sched_attr(x, E)
    a["imm_kind"] = imm_kind(x, E)
    return a


# ---- the outputs --------------------------------------------------------------

def comment(prefix, text, width=78):
    return [prefix + l for l in textwrap.wrap(text, width - len(prefix))]


def gen_h(rows):
    L = ["//===-- ccv_ops.h - the skeleton's opcode table ------------*- C++ -*-===//",
         "//"] + ["// " + l if l else "//" for l in BANNER.splitlines()] + [
         "//",
         "// kOps[]: an opcode is its row's position + 1. Included by",
         "// sim/skel/stub.h where the table stood, inside namespace ccv::skel,",
         "// after struct OpInfo, UopClass and the bypass groups: not a header",
         "// of its own.",
         "//===----------------------------------------------------------------------===//",
         "#ifndef CCV_OPS_H", "#define CCV_OPS_H", "",
         "inline constexpr OpInfo kOps[] = {"]
    for i, x in enumerate(rows):
        if x.get("note"):
            L += comment("  // ", x["note"])
        last = max([FIELDS.index(f) for f, dv in DEFAULTS if x[f] != dv] or [len(REQUIRED) - 1])
        vals = []
        for f in FIELDS[:last + 1]:
            v = x[f]
            if f == "name":
                vals.append(('"%s",' % v).ljust(18))
            elif f == "cls":
                vals.append(v + ",")
                continue
            elif isinstance(v, bool):
                vals.append("true" if v else "false")
            else:
                vals.append(str(v))
        L.append("  {%s %s %s},  // %d" % (vals[0], vals[1].ljust(12), ", ".join(vals[2:]), i + 1))
    L += ["};", "", "#endif  // CCV_OPS_H", ""]
    return "\n".join(L)


def sv_name(c):
    return re.sub(r"(?<!^)(?=[A-Z])", "_", c[1:]).upper()


def widths(classes, P):
    return {"W_CLS": max(1, (len(classes) - 1).bit_length()),
            "W_SCHED_ATTR": P["CCV_P_W_SCHED_ATTR"], "W_IMM_KIND": 3}


def gen_sv(rows, classes, E, P):
    W = widths(classes, P)
    wop = P["CCV_L_W_OPCODE"]
    L = ["// " + l if l else "//" for l in BANNER.splitlines()] + [
         "",
         "`ifndef CCV_OPS_PKG_SV", "`define CCV_OPS_PKG_SV", "",
         "`include \"ccv_params_pkg.sv\"", "",
         "// The opcode table's codes and the attributes an RTL module's own decode",
         "// reads per opcode (RI-21 (4)). The table is a catalogue: no module uses",
         "// every code, so the unused-parameter warning is off for this file only.",
         "/* verilator lint_off UNUSEDPARAM */",
         "package ccv_ops_pkg;", "",
         "  localparam int W_OPCODE = ccv_prelim_pkg::CCV_L_W_OPCODE;  // %d" % wop,
         "  localparam int N_OPS = %d;" % len(rows), ""]
    L.append("  // Opcodes: a row's position in params/ops.json + 1; 0 is reserved and")
    L.append("  // ccv_prelim_pkg::CCV_OP_PRF_COPY, the all-ones code, is the copy-only op.")
    for i, x in enumerate(rows):
        L.append("  localparam logic [W_OPCODE-1:0] OP_%s = %d'd%d;" % (key(x), wop, i + 1))
    L += ["", "  // uop class (UopClass in sim/skel/stub.h)."]
    L.append("  localparam int W_CLS = %d;" % W["W_CLS"])
    for i, c in enumerate(classes):
        L.append("  localparam logic [W_CLS-1:0] CLS_%s = %d'd%d;" % (sv_name(c), W["W_CLS"], i))
    L += ["", "  // imm_kind (ccv_dec_ooe_uop; immKindOf in sim/skel/stub.h)."]
    L.append("  localparam int W_IMM_KIND = %d;" % W["W_IMM_KIND"])
    for k in sorted((k for k in E if k.startswith("kImm") and k != "kImm"), key=E.get):
        L.append("  localparam logic [W_IMM_KIND-1:0] IMM_%s = %d'd%d;"
                 % (sv_name("k" + k[4:]), W["W_IMM_KIND"], E[k]))
    L += ["", "  localparam int W_SCHED_ATTR = ccv_prelim_pkg::CCV_P_W_SCHED_ATTR;  // %d"
          % W["W_SCHED_ATTR"], "",
          "  // An opcode's attributes, MSB first. sched_attr is schedAttrOf()'s",
          "  // value (its pair and commit_width bits, which DEC sets per slot, are",
          "  // 0); imm_kind is immKindOf()'s. The rest are OpInfo's fields, cross",
          "  // as cross_lane (cross is a keyword).",
          "  typedef struct packed {"]
    for f, w in ATTR:
        w = W[w] if isinstance(w, str) else w
        L.append("    logic %s%s;" % ("[%d:0] " % (w - 1) if w > 1 else "", f))
    L += ["  } ccv_op_attr_t;", "",
          "  // Pure combinational; an opcode outside the table returns zeros.",
          "  function automatic ccv_op_attr_t ccv_op_attr(input logic [W_OPCODE-1:0] opc);",
          "    ccv_op_attr_t a;",
          "    a = '0;",
          "    case (opc)"]
    for x in rows:
        a = attrs(x, classes, E)
        parts = []
        for f, w in ATTR:
            w = W[w] if isinstance(w, str) else w
            parts.append("%d'h%05x" % (w, a[f]) if w > 4 else
                         "%d'd%d" % (w, a[f]) if w > 1 else "1'b%d" % a[f])
        L.append("      OP_%s: a = {%s};" % (key(x), ", ".join(parts)))
    L += ["      default: a = '0;", "    endcase", "    return a;", "  endfunction", "",
          "endpackage", "/* verilator lint_on UNUSEDPARAM */", "", "`endif  // CCV_OPS_PKG_SV", ""]
    return "\n".join(L)


def build(d):
    classes, E = stub_enums()
    P = params()
    rows = validate(d, classes, E, P)
    return rows, classes, E, P


# ---- negative controls ----------------------------------------------------------

def selftest(d):
    classes, E = stub_enums()
    P = params()

    def new_row(name):
        return {"name": name, "cls": "kAlu", "nsrc": 2, "gdst": True, "pread": False,
                "pwrite": False, "guard": False, "pdata": False, "base_src": -1,
                "index_src": -1, "data_src": -1, "disp_imm": -1, "scale_imm": -1,
                "alu_imm": -1, "imm_slot": -1}

    def dup(m):
        m["ops"].append(copy.deepcopy(m["ops"][0]))
        m["pinned"].append(key(m["ops"][0]))

    def insert(m):
        m["ops"].insert(5, new_row("NEW_OP"))
        m["pinned"].append("NEW_OP")

    def remove(m):
        del m["ops"][10]

    def swap(m):
        m["ops"][3], m["ops"][4] = m["ops"][4], m["ops"][3]

    def unpinned(m):
        m["ops"].append(new_row("NEW_OP"))

    def unknown(m):
        m["ops"][7]["latency"] = 3

    def spelled(m):
        m["ops"][0]["cross"] = False

    def badcls(m):
        m["ops"][0]["cls"] = "kVector"

    def badbyp(m):
        m["ops"][0]["byp"] = "kBypVector"

    def missing(m):
        del m["ops"][0]["nsrc"]

    def topkey(m):
        m["opcodes"] = []

    def repin(m):
        m["pinned"][3], m["pinned"][4] = m["pinned"][4], m["pinned"][3]

    cases = [("a duplicated key", dup, "share the key"),
             ("a row inserted, its key appended", insert, "inserted"),
             ("a row removed", remove, "never removed"),
             ("two rows swapped", swap, "never move"),
             ("a row appended unpinned", unpinned, "not pinned"),
             ("an unknown field", unknown, "unknown field"),
             ("a default spelled out", spelled, "spells out its default"),
             ("an unknown class", badcls, "not a UopClass"),
             ("an unknown bypass group", badbyp, "not a bypass group"),
             ("a required field missing", missing, "does not default"),
             ("an unknown top-level key", topkey, "unknown top-level key"),
             ("pinned reordered", repin, "never move")]
    missed = []
    for what, mut, want in cases:
        m = copy.deepcopy(d)
        mut(m)
        try:
            validate(m, classes, E, P)
            missed.append("%s was accepted" % what)
        except Refused as e:
            if want not in str(e):
                missed.append("%s was refused for the wrong reason: %s" % (what, e))
    # The positive control: an append with its key pinned is accepted, and
    # moves no opcode.
    m = copy.deepcopy(d)
    m["ops"].append(new_row("NEW_OP"))
    m["pinned"].append("NEW_OP")
    try:
        rows = validate(m, classes, E, P)
        if [key(x) for x in rows[:-1]] != d["pinned"]:
            missed.append("an append moved an opcode")
    except Refused as e:
        missed.append("an append was refused: %s" % e)
    # The derivations mirror stub.h: a mutated class must move sched_attr.
    x = dict(DEFAULT, **d["ops"][0])
    y = dict(x, cls="kLoad")
    if sched_attr(x, E) == sched_attr(y, E):
        missed.append("sched_attr does not see the class")
    # ...and the SFU bypass group must move lat_class to 4, and only it.
    z = dict(DEFAULT, **[r for r in d["ops"] if r.get("byp") == "kBypSfu"][0])
    if sched_attr(z, E) & 7 != E["kLatSfu"]:
        missed.append("an SFU op is not lat_class 4")
    if sched_attr(dict(z, byp="kBypFp"), E) & 7 != E["kLatLane"]:
        missed.append("lat_class 4 reaches an op outside the SFU group")
    if missed:
        sys.stderr.write("".join("gen-ops selftest: %s\n" % s for s in missed))
        return 1
    print("  opcode table: %d mutation(s), each refused by name; an append accepted"
          % len(cases))
    return 0


# ---- C++ against SV ------------------------------------------------------------

PROBE_CPP = r"""
#include "stub.h"
#include <cstdio>
using namespace ccv::skel;
int main() {
  for (const OpInfo &o : kOps)
    std::printf("%u %s %u %u %u %u %u %u %u %u %u %u %u %u %u %u\n", opcodeOf(&o), o.name,
                unsigned(o.cls), unsigned(o.nsrc), o.gdst, o.pread, o.pwrite, o.guard,
                o.pdata, o.cross, o.pxfer, o.ret, unsigned(o.chw), o.shared,
                schedAttrOf(&o), immKindOf(&o));
  std::printf("N %u\n", kNumOps);
}
"""
CPP_FIELDS = ["cls", "nsrc", "gdst", "pread", "pwrite", "guard", "pdata", "cross_lane",
              "pxfer", "ret", "chw", "shared", "sched_attr", "imm_kind"]


def crosscheck(d):
    rows, classes, E, P = build(d)
    for path in (OUT_H, OUT_SV):
        if not os.path.exists(path):
            sys.stderr.write("%s is missing: run tools/gen-ops.py\n" % os.path.relpath(path, ROOT))
            return 1
    b = os.path.join(ROOT, "build", "gen-ops")
    shutil.rmtree(b, ignore_errors=True)
    os.makedirs(b)
    # C++: the table through stub.h's own schedAttrOf and immKindOf.
    open(os.path.join(b, "probe.cpp"), "w").write(PROBE_CPP)
    inc = ["-I" + os.path.join(ROOT, p) for p in ("sim/include", "sim/generated", "sim/skel")]
    r = subprocess.run(["g++", "-std=c++17", "-O0", "-w"] + inc +
                       [os.path.join(b, "probe.cpp"), "-o", os.path.join(b, "probe")],
                       capture_output=True, text=True)
    if r.returncode:
        sys.stderr.write("gen-ops crosscheck: the C++ probe did not build:\n%s" % r.stderr[-3000:])
        return 1
    out = subprocess.run([os.path.join(b, "probe")], capture_output=True, text=True,
                         check=True).stdout.split("\n")
    cpp = {}
    for l in out:
        t = l.split()
        if len(t) == 2 and t[0] == "N":
            ncpp = int(t[1])
        elif t:
            cpp[int(t[0])] = (t[1], [int(v) for v in t[2:]])
    # SV: ccv_op_attr elaborated by Verilator, every code 0 to 2^W - 1.
    names = " ".join("$display(\"O %d %%0d\", ccv_ops_pkg::OP_%s);" % (i + 1, key(x))
                     for i, x in enumerate(rows))
    tb = ["module probe;", "  initial begin",
          "    for (int c = 0; c < (1 << ccv_ops_pkg::W_OPCODE); c++) begin",
          "      ccv_ops_pkg::ccv_op_attr_t a;",
          "      a = ccv_ops_pkg::ccv_op_attr(c[ccv_ops_pkg::W_OPCODE-1:0]);",
          "      $display(\"A %%0d %s\", c, %s);" % (" ".join(["%0d"] * len(CPP_FIELDS)),
                                                   ", ".join("a.%s" % f for f in CPP_FIELDS)),
          "    end",
          "    " + names,
          "    $finish;", "  end", "endmodule", ""]
    open(os.path.join(b, "probe.sv"), "w").write("\n".join(tb))
    r = subprocess.run(["verilator", "--binary", "-Wno-fatal", "-Wno-WIDTHTRUNC",
                        "-I" + os.path.join(ROOT, "rtl", "generated"),
                        "--Mdir", os.path.join(b, "obj"), "--top-module", "probe",
                        OUT_SV, os.path.join(b, "probe.sv")],
                       capture_output=True, text=True)
    if r.returncode:
        sys.stderr.write("gen-ops crosscheck: the SV probe did not build:\n%s" % r.stderr[-3000:])
        return 1
    sv = subprocess.run([os.path.join(b, "obj", "Vprobe")], capture_output=True, text=True,
                        check=True).stdout.split("\n")
    attr, codes = {}, {}
    for l in sv:
        t = l.split()
        if t and t[0] == "A":
            attr[int(t[1])] = [int(v) for v in t[2:]]
        elif t and t[0] == "O":
            codes[int(t[1])] = int(t[2])
    bad = []
    if ncpp != len(rows) or len(cpp) != len(rows):
        bad.append("C++ has %d opcodes, params/ops.json %d" % (ncpp, len(rows)))
    for i, x in enumerate(rows):
        c = i + 1
        if c not in cpp:
            bad.append("opcode %d (%s): not in the C++ table" % (c, key(x)))
            continue
        name, vals = cpp[c]
        if name != x["name"]:
            bad.append("opcode %d: C++ %s, params/ops.json %s" % (c, name, x["name"]))
        if codes.get(c) != c:
            bad.append("opcode %d: OP_%s is %s in SV" % (c, key(x), codes.get(c)))
        for f, cv, sv_v in zip(CPP_FIELDS, vals, attr.get(c, [None] * len(CPP_FIELDS))):
            if cv != sv_v:
                bad.append("opcode %d (%s): %s is %s in C++, %s in SV" % (c, key(x), f, cv, sv_v))
    for c, v in attr.items():
        if not 1 <= c <= len(rows) and any(v):
            bad.append("SV code %d is outside the table but its attributes are not zero" % c)
    if len(attr) != 1 << P["CCV_L_W_OPCODE"]:
        bad.append("the SV probe ran %d codes, not %d" % (len(attr), 1 << P["CCV_L_W_OPCODE"]))
    if bad:
        sys.stderr.write("".join("gen-ops crosscheck: %s\n" % s for s in bad[:40]))
        return 1
    print("  opcode table: C++ (stub.h's schedAttrOf, immKindOf) and SV (ccv_op_attr) "
          "agree on %d opcodes, %d fields each; the other %d codes are zero"
          % (len(rows), len(CPP_FIELDS), len(attr) - len(rows)))
    return 0


def main():
    check = "--check" in sys.argv
    with open(SRC) as f:
        d = json.load(f)
    try:
        if "--selftest" in sys.argv:
            return selftest(d)
        if "--crosscheck" in sys.argv:
            return crosscheck(d)
        rows, classes, E, P = build(d)
    except Refused as e:
        sys.stderr.write("%s\n" % e)
        return 1
    targets = [(OUT_H, gen_h(rows)), (OUT_SV, gen_sv(rows, classes, E, P))]
    stale = []
    for path, text in targets:
        os.makedirs(os.path.dirname(path), exist_ok=True)
        cur = open(path).read() if os.path.exists(path) else None
        if cur != text:
            stale.append(os.path.relpath(path, ROOT))
            if not check:
                with open(path, "w") as f:
                    f.write(text)
    # A file this generator wrote last run and no longer does (OI-40).
    stale += genout.sync("gen-ops", [p for p, _ in targets], check)
    if check:
        if stale:
            sys.stderr.write("generated opcode files are stale: %s\n"
                             "  run tools/gen-ops.py\n" % ", ".join(stale))
            return 1
        print("  opcode table up to date (%d opcodes)" % len(rows))
        return 0
    print("  generated the opcode table from params/ops.json (%d opcodes)" % len(rows))
    return 0


if __name__ == "__main__":
    sys.exit(main())
