//===-- pl_tb.cpp - ooe_rcupl and ooe_mempl against the model's issues ----===//
//
// Runs the model's random unit tests and its atomics', credits' and
// squashes' (sim/ooe/ooe_test.cpp, scenario pl) and, after every
// core cycle, takes what the core sent (Core's out.issues and out.memops).
// Each issue is an RS entry granted at select: the bench packs it as
// ooe_ent_t (rtl/include/ooe_pl.svh), on its home slot (its group's first slot
// plus its footprint's lowest bit, R alone for an RCU op), and a memop's
// memop fields as ooe_mem_t beside the entry of its own P issue, the same
// cycle's issue of its rob tag. A bulk discard goes on P0 as ooe_dsc_t.
//
// The formatters run as ooe_rs and ooe_sched will drive them: the grant
// register's lead (and the discard's) a cycle ahead, the lead read (lv, le,
// the footprint and select's credit flags, Core::wakeLog's sel_cok) in the
// grant's cycle, the late read (pe, the memop fields, the RS index, the
// discard) a cycle on. After each edge every slot of both channels must be
// the model's as the skeleton formats it (sim/ooe/ooe_block.cpp's
// sendOutputs and sendIssues, sim/skel/stub.h's putIssueLead and
// finishIssueLeads, re-derived here, since stub.h needs the skeleton's
// wiring): each slot's valid and lead fields that cycle, its other fields a
// cycle on. The channels' layout is the schema's (test/ooe/pl-fields.py
// writes pl_fields.h), and the RTL's width sums (ooe_pl_tb's constants)
// must equal the bench's packing and the channels' widths.
//
// The memop's tag, row, warp, lanes and pipes come from its entry, not its
// memop fields: the bench holds each to the model's memop.
//
// Followed: cores with sectioned lanes and no model control that breaks
// select's grants or credits; others are skipped and counted.
//
// Negative controls (PL_CONTROL=<name>) must be caught: no-gnt-lead (the
// grant register's lead never comes), no-dsc-lead (nor the discard's),
// early-pe (the late read a cycle early: the grant's own cycle), no-cok
// (every pipe credited) and no-fp (the lead read's footprint zero: no
// continuations, every memop on P0).
//
// With --cg <scenario> <vcd> it runs that scenario (test/ooe/cg_trace.h)
// and dumps the VCD its clock-gating unit measures, checking as ever.
// Usage: pl_tb [seeds] | pl_tb --cg <scenario> <vcd>
//===----------------------------------------------------------------------===//
#include "Vooe_pl_tb.h"
#include "verilated.h"
#include "cg_trace.h"
#include "ooe_core.h"
#include "ccv_params.h"
#include "pl_fields.h"

#include <cstdio>
#include <cstdlib>
#include <cstring>
#include <map>
#include <memory>
#include <string>
#include <vector>

using ccv::ooe::Config;
using ccv::ooe::Core;
using ccv::ooe::Issue;
using ccv::ooe::Memop;

namespace {
constexpr unsigned NS = PL_NS, K = 2 * NS + 1, kSlotP0 = NS, kSlotR = 2 * NS;
constexpr unsigned kOpCopy = ccv::prelim::kOpPrfCopy;

const PlField &fld(const PlField *fs, size_t n, const char *name) {
  for (size_t i = 0; i != n; ++i)
    if (!std::strcmp(fs[i].name, name)) return fs[i];
  std::fprintf(stderr, "pl_tb: no field %s\n", name);
  std::exit(2);
}
const PlField &iss(const char *n) { return fld(kIssFields, sizeof kIssFields / sizeof kIssFields[0], n); }
const PlField &mo(const char *n) { return fld(kMoFields, sizeof kMoFields / sizeof kMoFields[0], n); }
constexpr unsigned kNIss = sizeof kIssFields / sizeof kIssFields[0], kNMo = sizeof kMoFields / sizeof kMoFields[0];

template <typename T> void setField(T &w, unsigned lsb, unsigned n, uint64_t v) {
  for (unsigned b = 0; b != n; ++b) {
    const unsigned i = lsb + b;
    const bool x = (v >> b) & 1u;
    if constexpr (sizeof(T) <= 8) {
      if (x) w |= (T(1) << i); else w &= ~(T(1) << i);
    } else {
      if (x) w[i / 32] |= (1u << (i % 32)); else w[i / 32] &= ~(1u << (i % 32));
    }
  }
}
template <typename T> uint64_t getField(const T &w, unsigned lsb, unsigned n) {
  uint64_t v = 0;
  for (unsigned b = 0; b != n; ++b) {
    const unsigned i = lsb + b;
    bool x;
    if constexpr (sizeof(T) <= 8) x = (w >> i) & 1u;
    else x = (w[i / 32] >> (i % 32)) & 1u;
    v |= uint64_t(x) << b;
  }
  return v;
}
uint64_t mask(unsigned w) { return w >= 64 ? ~0ull : (1ull << w) - 1; }

/// A struct packed MSB first: (width, value) in declaration order.
struct Packed {
  std::vector<std::pair<unsigned, uint64_t>> f;
  void add(unsigned w, uint64_t v) { f.emplace_back(w, v & mask(w)); }
  unsigned width() const { unsigned t = 0; for (auto &x : f) t += x.first; return t; }
  template <typename T> void put(T &w, unsigned base) const {
    unsigned lsb = base + width();
    for (auto &x : f) { lsb -= x.first; setField(w, lsb, x.first, x.second); }
  }
};

/// A channel message, by field name.
using Msg = std::map<std::string, uint64_t>;

struct Name { unsigned row = 0, pos = 0; };
/// One issue as the bench keeps it: the model's, with its names resolved.
struct Iss {
  Issue x;
  Name src[3], dst, old;
};
struct Mo {
  Memop x;
  Name dst;
};
struct Cycle {
  std::vector<Iss> iss;
  std::vector<Mo> mo;
  unsigned cok = 0xF;
};

Packed entryOf(const Iss &i, bool no_fp) {
  const Issue &x = i.x;
  const unsigned fp = x.res == Issue::kRcuOp ? 0u : x.footprint;
  Packed p;   // ooe_ent_t's order
  p.add(iss("rob_tag").width, x.rob_tag);
  p.add(2, x.row);
  p.add(iss("warp_id").width, x.warp);
  p.add(iss("issue_mask").width, x.issue_mask);
  p.add(NS, no_fp ? 0u : fp);
  p.add(3, x.gpr_reads & 7u);
  p.add(1, x.send_imm);
  p.add(1, x.merge);
  p.add(1, x.pread);
  p.add(iss("lead_guard_pred").width, x.ppguard);
  p.add(iss("opcode").width, x.copy ? kOpCopy : x.opcode);
  p.add(iss("phys_dst").width, i.dst.row);
  p.add(iss("dst_pos").width, i.dst.pos);
  p.add(iss("dst_width").width, x.dst_w);
  p.add(1, x.pred_we);
  p.add(iss("phys_pred_dst").width, x.ppdst);
  p.add(1, x.pred_neg);
  p.add(iss("phys_src").width, uint64_t(i.src[0].row) << ccv::prov::kWPhysReg | i.src[1].row);
  p.add(iss("phys_src2").width, i.src[2].row);
  p.add(iss("phys_old_dst").width, i.old.row);
  p.add(iss("old_dst_pos").width, i.old.pos);
  p.add(iss("src_pos").width,
        i.src[0].pos | i.src[1].pos << ccv::kWPhysPos | i.src[2].pos << (2 * ccv::kWPhysPos));
  p.add(iss("phys_pred_old_dst").width, x.ppold);
  p.add(1, x.merge);
  p.add(iss("bypass_group").width, x.byp_group);
  p.add(iss("src_width").width,
        x.src_w[0] | x.src_w[1] << ccv::kWChwidth | x.src_w[2] << (2 * ccv::kWChwidth));
  p.add(iss("chwidth").width, x.chwidth);
  p.add(iss("imm").width, x.send_imm ? x.imm : 0u);
  return p;
}
Packed memOf(const Mo &m) {
  const Memop &x = m.x;
  Packed p;   // ooe_mem_t's order
  p.add(mo("phys_dst").width, m.dst.row);
  p.add(mo("dst_pos").width, m.dst.pos);
  p.add(mo("phys_pred").width, x.ppred);
  p.add(mo("cta_slot").width, x.cta_slot);
  p.add(mo("mem_op").width, x.mem_op);
  p.add(mo("chwidth").width, x.chwidth);
  p.add(ccv::kWPhysPos, x.data_pos);
  p.add(mo("disp").width, x.disp);
  p.add(1, x.scale_en);
  p.add(mo("space").width, x.space);
  p.add(mo("ordering").width, x.ordering);
  p.add(mo("slot_form").width, x.slot_form);
  p.add(mo("arg_slot").width, x.arg_slot);
  p.add(mo("local_form").width, x.local_form);
  p.add(mo("xfer_size").width, x.xfer_size);
  p.add(mo("xfer_signed").width, x.xfer_signed);
  return p;
}
Packed dscOf(const Memop &x) {
  Packed p;   // ooe_dsc_t's order
  p.add(mo("rob_tag").width, x.rob_tag);
  p.add(mo("warp_id").width, x.warp);
  p.add(ccv::prov::kWRobIdx, x.disp);
  return p;
}

unsigned homeOf(const Issue &x) {
  if (x.res == Issue::kRcuOp) return kSlotR;
  return (x.res == Issue::kMemop ? kSlotP0 : 0u) + unsigned(__builtin_ctz(x.footprint));
}

/// What the skeleton sends on slot s for an issue (ooe_block.cpp,
/// stub.h), every field the slot does not carry zero.
Msg issueMsg(const Iss &i, unsigned s, bool cont) {
  const Issue &x = i.x;
  Msg m;
  m["rob_tag"] = x.rob_tag;
  if (!cont) {
    const unsigned fp = x.res == Issue::kRcuOp ? 0u : x.footprint;
    m["done_row"] = x.row;
    m["warp_id"] = x.warp;
    m["issue_mask"] = x.issue_mask;
    m["phys_src"] = uint64_t(i.src[0].row) << ccv::prov::kWPhysReg | i.src[1].row;
    m["phys_src2"] = i.src[2].row;
    m["src_pos"] = i.src[0].pos | i.src[1].pos << ccv::kWPhysPos | i.src[2].pos << (2 * ccv::kWPhysPos);
    m["imm"] = x.send_imm ? x.imm : 0u;
    m["phys_dst"] = i.dst.row;
    m["dst_pos"] = i.dst.pos;
    m["phys_pred_dst"] = x.ppdst;
    m["pred_we"] = x.pred_we;
    m["merge_en"] = x.merge;
    m["phys_old_dst"] = i.old.row;
    m["old_dst_pos"] = i.old.pos;
    m["phys_pred_old_dst"] = x.ppold;
    m["chwidth"] = x.chwidth;
    m["pred_neg"] = x.pred_neg;
    m["opcode"] = x.copy ? kOpCopy : x.opcode;
    m["bypass_group"] = x.byp_group;
    m["src_width"] = x.src_w[0] | x.src_w[1] << ccv::kWChwidth | x.src_w[2] << (2 * ccv::kWChwidth);
    m["dst_width"] = x.dst_w;
    m["footprint"] = fp;
    m["lead_sec_mask"] = fp;
    m["lead_src_used"] = x.gpr_reads & 7u;
    m["lead_imm_used"] = x.send_imm;
    m["lead_merge_used"] = x.merge;
    m["lead_guard_used"] = x.pread;
    m["lead_guard_pred"] = x.ppguard;
  } else {
    m["cont"] = 1;
  }
  // placeIssueSrcRows: a slot without the payload's source rows takes them
  // in its lead, and R its imm in lead_rpsrc.
  if (!((iss("phys_src").slots >> s) & 1u)) {
    const uint64_t ps = m["phys_src"], ps2 = m["phys_src2"];
    m["phys_src"] = m["phys_src2"] = 0;
    if ((iss("lead_phys_src").slots >> s) & 1u) {
      m["lead_phys_src"] = ps;
      m["lead_phys_src2"] = ps2;
      if ((iss("lead_rpsrc").slots >> s) & 1u && !((iss("imm").slots >> s) & 1u)) {
        m["lead_rpsrc"] = m["imm"];
        m["imm"] = 0;
      }
    }
  }
  // fillIssueLeadCopies (kIssueLeadCopies).
  static const char *const copies[][2] = {
      {"lead_opcode", "opcode"},     {"lead_phys_dst", "phys_dst"},         {"lead_dst_pos", "dst_pos"},
      {"lead_dst_width", "dst_width"}, {"lead_done_row", "done_row"},       {"lead_pred_we", "pred_we"},
      {"lead_phys_pred_dst", "phys_pred_dst"}, {"lead_cont", "cont"},      {"lead_pred_neg", "pred_neg"},
      {"lead_phys_src", "phys_src"}, {"lead_phys_old_dst", "phys_old_dst"}, {"lead_old_dst_pos", "old_dst_pos"},
      {"lead_src_pos", "src_pos"},   {"lead_phys_src2", "phys_src2"}};
  for (const auto &c : copies)
    if ((iss(c[0]).slots >> s) & (iss(c[1]).slots >> s) & 1u) m[c[0]] = m[c[1]];
  // Every field the slot does not carry is zero (slot_fields).
  for (auto &kv : m)
    if (!((iss(kv.first.c_str()).slots >> s) & 1u)) kv.second = 0;
  return m;
}
Msg memopMsg(const Mo &m) {
  const Memop &x = m.x;
  Msg r;
  r["rob_tag"] = x.rob_tag;
  r["done_row"] = x.row;
  r["warp_id"] = x.warp;
  r["mem_op"] = x.mem_op;
  if (x.mem_op == 0xF) {
    r["disp"] = x.disp & mask(ccv::prov::kWRobIdx);
    return r;
  }
  r["rs_idx"] = x.rs_idx;
  r["issue_mask"] = x.issue_mask;
  r["phys_dst"] = m.dst.row;
  r["dst_pos"] = m.dst.pos;
  r["phys_pred"] = x.ppred;
  r["disp"] = x.disp;
  r["scale_en"] = x.scale_en;
  r["space"] = x.space;
  r["ordering"] = x.ordering;
  r["slot_form"] = x.slot_form;
  r["arg_slot"] = x.arg_slot;
  r["local_form"] = x.local_form;
  r["xfer_size"] = x.xfer_size;
  r["xfer_signed"] = x.xfer_signed;
  r["cta_slot"] = x.cta_slot;
  r["chwidth"] = x.chwidth;
  const unsigned span = x.chwidth == 0 ? 4u : x.chwidth == 1 ? 2u : 1u;   // stub.h's spanOf, maskOf
  r["pipes"] = ((1u << span) - 1u) << x.data_pos;
  return r;
}

std::unique_ptr<VerilatedContext> ctx;
std::unique_ptr<Vooe_pl_tb> dut;
std::string control;
CgRun cg;
bool skip_core = false;
unsigned last_cok = 0xF;   // select's credit flags last cycle
uint64_t current = 0;
Cycle pend;
bool have_pend = false;
// The previous drive's expected messages per slot, for the payload a cycle on.
Msg prev_iss[K], prev_mo[NS];
bool prev_iv[K] = {}, prev_mv[NS] = {};
Cycle prev_cy;   // its entries, for the late read
std::vector<std::pair<unsigned, const Iss *>> prev_home;
unsigned long long cycles = 0, cores = 0, skipped = 0, mismatches = 0, n_iss = 0, n_cont = 0, n_r = 0, n_mo = 0,
                   n_up = 0, n_atom = 0, n_dsc = 0, n_unpaired = 0, n_clash = 0;

void tick() {
  dut->ooe_core_clk = 0;
  dut->eval();
  cg.dump();
  dut->ooe_core_clk = 1;
  dut->eval();
  cg.dump();
}

void fail(const char *what, unsigned slot, const char *field, uint64_t rtl, uint64_t model) {
  if (++mismatches <= 8)
    std::fprintf(stderr, "%s, cycle %llu, slot %u: %s %s (rtl %llu, model %llu)\n", ooeTestName(), cycles, slot,
                 what, field, (unsigned long long)rtl, (unsigned long long)model);
}

bool busy(const Cycle &c) {
  return !c.iss.empty() || std::any_of(c.mo.begin(), c.mo.end(), [](const Mo &m) { return m.x.mem_op != 0xF; });
}
bool hasDsc(const Cycle &c) {
  return std::any_of(c.mo.begin(), c.mo.end(), [](const Mo &m) { return m.x.mem_op == 0xF; });
}

void clearInputs() {
  dut->gnt_l_cq01h = 0;
  dut->dsc_l_cq01h = 0;
  dut->lv_cq02h = 0;
  dut->mlv_cq02h = 0;
  dut->dv_cq02h = 0;
  dut->cok_cq02h = 0xF;
  dut->lfp_cq02h = 0;
}

/// Drives the late read of cycle c's entries (pe, pm, pi, pd).
void driveLate(const Cycle &c, const std::vector<std::pair<unsigned, const Iss *>> &home) {
  for (const auto &h : home) entryOf(*h.second, false).put(dut->pe_cq03h, h.first * dut->ew);
  for (const Mo &m : c.mo) {
    if (m.x.mem_op == 0xF) {
      dscOf(m.x).put(dut->pd_cq03h, 0);
      continue;
    }
    for (const auto &h : home)
      if (h.first >= kSlotP0 && h.first < kSlotR && h.second->x.rob_tag == m.x.rob_tag &&
          h.second->x.res == Issue::kMemop) {
        const unsigned p = h.first - kSlotP0;
        entryOf(*h.second, false).put(dut->mpe_cq03h, p * dut->ew);
        memOf(m).put(dut->pm_cq03h, p * dut->mw);
        setField(dut->pi_cq03h, p * ccv::prov::kWRsIdx, ccv::prov::kWRsIdx, m.x.rs_idx);
      }
  }
}

void drive(const Cycle &c, const Cycle *nx) {
  ++cycles;
  clearInputs();
  // The homes; two issues on one home (a model control) leave the core.
  std::vector<std::pair<unsigned, const Iss *>> home;
  uint32_t taken = 0;
  for (const Iss &i : c.iss) {
    const unsigned h = homeOf(i.x);
    if ((taken >> h) & 1u) { ++n_clash; skip_core = true; have_pend = false; return; }
    taken |= 1u << h;
    home.emplace_back(h, &i);
  }
  // The lead read.
  for (const auto &h : home) {
    dut->lv_cq02h |= 1u << h.first;
    entryOf(*h.second, control == "no-fp").put(dut->le_cq02h, h.first * dut->ew);
    if (h.first >= kSlotP0 && h.first < kSlotR) {
      const unsigned p = h.first - kSlotP0;
      // An MIU entry's home is a memop home if a memop of its tag goes now.
      bool memop = false;
      for (const Mo &m : c.mo) memop = memop || (m.x.mem_op != 0xF && m.x.rob_tag == h.second->x.rob_tag);
      if (memop) {
        dut->mlv_cq02h |= 1u << p;
        setField(dut->lfp_cq02h, p * NS, NS, control == "no-fp" ? 0u : h.second->x.footprint);
      }
    }
  }
  for (const Mo &m : c.mo) {
    if (m.x.mem_op == 0xF) { dut->dv_cq02h = 1; continue; }
    bool paired = false;
    for (const auto &h : home) paired = paired || (h.second->x.res == Issue::kMemop && h.second->x.rob_tag == m.x.rob_tag);
    if (!paired) ++n_unpaired;
  }
  dut->cok_cq02h = control == "no-cok" ? 0xF : c.cok;
  // The late read: the previous cycle's entries, or (early-pe) this one's.
  if (control == "early-pe") driveLate(c, home);
  else driveLate(prev_cy, prev_home);
  // The next cycle's leads.
  dut->gnt_l_cq01h = nx && busy(*nx) && control != "no-gnt-lead";
  dut->dsc_l_cq01h = nx && hasDsc(*nx) && control != "no-dsc-lead";
  tick();

  // ccv_ooe_rcu_issue: valid and leads this cycle, the rest a cycle on.
  Msg exp[K];
  bool ev[K] = {};
  for (const auto &h : home) {
    exp[h.first] = issueMsg(*h.second, h.first, false);
    ev[h.first] = true;
    ++n_iss;
    n_r += h.first == kSlotR;
    const Issue &x = h.second->x;
    if (x.res == Issue::kRcuOp) continue;
    const unsigned g = x.res == Issue::kMemop ? kSlotP0 : 0u;
    for (unsigned b = unsigned(__builtin_ctz(x.footprint)) + 1; b < NS; ++b)
      if ((x.footprint >> b) & 1u) {
        exp[g + b] = issueMsg(*h.second, g + b, true);
        ev[g + b] = true;
        ++n_cont;
      }
  }
  for (unsigned s = 0; s != K; ++s) {
    const bool v = (dut->iss_v_cq03h >> s) & 1u;
    if (v != ev[s]) { fail("rcu issue valid differs", s, "", v, ev[s]); continue; }
    for (unsigned f = 0; f != kNIss; ++f) {
      const PlField &d = kIssFields[f];
      const bool now = d.lead;
      if (now ? !ev[s] : !prev_iv[s]) continue;
      const Msg &m = now ? exp[s] : prev_iss[s];
      const auto it = m.find(d.name);
      const uint64_t want = it == m.end() ? 0 : it->second & mask(d.width);
      const uint64_t got = getField(dut->iss_pay_cq04h, s * kIssBits + d.lsb, d.width);
      if (got != want) fail("rcu issue field differs:", s, d.name, got, want);
    }
  }
  // ccv_ooe_miu_memop: valid this cycle, the payload a cycle on.
  Msg mexp[NS];
  bool mv[NS] = {};
  for (const Mo &m : c.mo) {
    if (m.x.port >= NS || mv[m.x.port]) { fail("memop port", m.x.port, "", 0, 0); continue; }
    mv[m.x.port] = true;
    mexp[m.x.port] = memopMsg(m);
    ++(m.x.mem_op == 0xF ? n_dsc : n_mo);
    n_atom += m.x.row == 3 || m.x.mem_op == ccv::ooe::kMemOpAtomicRead;
    for (const auto &h : home)
      n_up += m.x.mem_op != 0xF && h.second->x.rob_tag == m.x.rob_tag && h.second->x.res == Issue::kMemop &&
              h.first - kSlotP0 != m.x.port;
  }
  for (unsigned p = 0; p != NS; ++p) {
    const bool v = (dut->mv_cq03h >> p) & 1u;
    if (v != mv[p]) { fail("memop valid differs", p, "", v, mv[p]); continue; }
    if (!prev_mv[p]) continue;
    for (unsigned f = 0; f != kNMo; ++f) {
      const PlField &d = kMoFields[f];
      const auto it = prev_mo[p].find(d.name);
      const uint64_t want = it == prev_mo[p].end() ? 0 : it->second & mask(d.width);
      const uint64_t got = getField(dut->mo_pay_cq04h, p * kMoBits + d.lsb, d.width);
      if (got != want) fail("memop field differs:", p, d.name, got, want);
    }
  }
  for (unsigned s = 0; s != K; ++s) { prev_iss[s] = exp[s]; prev_iv[s] = ev[s]; }
  for (unsigned p = 0; p != NS; ++p) { prev_mo[p] = mexp[p]; prev_mv[p] = mv[p]; }
  prev_cy = c;
  // The homes point into prev_cy now.
  prev_home.clear();
  for (const Iss &i : prev_cy.iss) prev_home.emplace_back(homeOf(i.x), &i);
}

void resetDut() {
  clearInputs();
  dut->ooe_rst_r00h = 1;
  tick();
  tick();
  dut->ooe_rst_r00h = 0;
  tick();
  for (unsigned s = 0; s != K; ++s) prev_iv[s] = false;
  for (unsigned p = 0; p != NS; ++p) prev_mv[p] = false;
  prev_cy = Cycle();
  prev_home.clear();
}

void push(const Cycle &e) {
  if (have_pend) drive(pend, &e);
  if (skip_core) { have_pend = false; return; }
  pend = e;
  have_pend = true;
}
void flushPend() {
  if (have_pend) {
    drive(pend, nullptr);
    have_pend = false;
    if (!skip_core) {   // the last cycle's payload
      const Cycle none;
      drive(none, nullptr);
    }
  }
}

void pre(const Core &c) {
  if (c.serial() == current) return;
  flushPend();
  current = c.serial();
  ++cores;
  const Config &cf = c.config();
  skip_core = !cf.sectioned || cf.inject_double_grant || cf.inject_no_memop_credit;
  skipped += skip_core;
  if (skip_core) return;
  resetDut();
  last_cok = 0xF;
  pend = Cycle();
  have_pend = true;
}

void post(const Core &c) {
  if (skip_core || c.serial() != current) return;
  Cycle y;
  const auto nm = [&c](unsigned n) { return Name{c.nameRow(n), c.namePos(n)}; };
  for (const Issue &x : c.out.issues) {
    Iss i;
    i.x = x;
    for (unsigned k = 0; k != 3; ++k) i.src[k] = nm(x.psrc[k]);
    i.dst = nm(x.pdst);
    i.old = nm(x.pold);
    y.iss.push_back(i);
  }
  for (const Memop &x : c.out.memops) {
    Mo m;
    m.x = x;
    m.dst = nm(x.pdst);
    y.mo.push_back(m);
  }
  // The credit flags the grants read: this cycle's, or last cycle's when
  // the model holds its grants a cycle (payload_stages, OA-1), as the RTL
  // reads them in the grant's cycle.
  const unsigned cok = c.wakeLog().sel_cok & 0xFu;
  y.cok = c.config().payload_stages ? last_cok : cok;
  last_cok = cok;
  push(y);
}
} // namespace

int main(int argc, char **argv) {
  const unsigned seeds = argc > 1 && argv[1][0] != '-' ? unsigned(std::atoi(argv[1])) : 25;
  if (const char *c = std::getenv("PL_CONTROL")) control = c;
  ctx = std::make_unique<VerilatedContext>();
  ctx->commandArgs(argc, argv);
  std::string vcd;
  if (cg.parse(argc, argv, vcd)) CgRun::prepare(*ctx);
  dut = std::make_unique<Vooe_pl_tb>(ctx.get());
  if (cg.on()) cg.open(*dut, vcd);
  dut->ooe_core_clk = 0;
  dut->ooe_rst_r00h = 1;
  dut->eval();
  // The RTL's width sums against the bench's packing and the channels.
  {
    Iss i;
    Mo m;
    unsigned bad = 0;
    bad += dut->ew != entryOf(i, false).width();
    bad += dut->mw != memOf(m).width();
    bad += dut->dw != dscOf(m.x).width();
    bad += dut->iw != kIssBits;
    bad += dut->ow != kMoBits;
    if (bad) {
      std::fprintf(stderr, "pl_tb: widths differ: entry %u/%u, memop fields %u/%u, discard %u/%u, issue %u/%u, memop %u/%u\n",
                   dut->ew, entryOf(i, false).width(), dut->mw, memOf(m).width(), dut->dw, dscOf(m.x).width(), dut->iw,
                   kIssBits, dut->ow, kMoBits);
      return 1;
    }
  }
  const int model_fails = cg.on() ? cg.run(seeds, pre, post) : ooeTestScenario("pl", seeds, 0, pre, post, nullptr);
  flushPend();
  cg.close();
  dut->final();
  std::printf("pl_tb control=%s seeds=%u cores=%llu (skipped: unsectioned or a model control=%llu, two on a home=%llu) "
              "cycles=%llu issues=%llu (on R %llu) continuations=%llu memops=%llu (atomic %llu, above home %llu, no P issue %llu) "
              "discards=%llu "
              "mismatches=%llu model_failures=%d\n",
              control.empty() ? "none" : control.c_str(), seeds, cores, skipped, n_clash, cycles, n_iss, n_r, n_cont,
              n_mo, n_atom, n_up, n_unpaired, n_dsc, mismatches, model_fails);
  const int rc = mismatches || model_fails || n_unpaired ? 1 : 0;
  dut.reset();
  ctx.reset();
  return rc;
}
