//===-- ooe_block.cpp - the OOE model at the swap boundary ---------------===//
//
// Packs and unpacks OOE's channels around ooe::Core, and nothing else: the
// core holds every structure and decision. Reads only OOE's own receivers and
// writes only its own senders (stub.h); the oracle is never consulted.
//
// What lives here rather than in the core:
//   - the testbench hooks (Kernel): retire bookkeeping, each warp's maps, coverage bins,
//     events, and check failures for the core's contract and invariant errors;
//   - the negative controls that act on a message (corrupt-ckpt, stale-free,
//     drop-negate, skip-copy, corrupt-disp); free-new acts inside the core;
//   - DEC's src_valid, pred_use and imm_kind into UopShape (A-75, TI-1);
//   - the S1 configuration (docs/ooe-model.md, "S1 modes"): which of the
//     core's mechanisms the S1 neighbours can carry today.
//===----------------------------------------------------------------------===//
#include "stub.h"
#include "ooe_core.h"

#include <cstdlib>
#include <fstream>
#include <map>
#include <set>
#include <tuple>

namespace ccv {
namespace skel {
namespace {

/// Whether a channel carries a field: aux (AR-24 (b)) under either of its
/// names, and own_pc (TI-40), each read or sent only where the schema has it.
bool hasField(unsigned chan, const char *n) {
  const ChanDesc &cd = kChans[chan];
  for (unsigned f = 0; f != cd.nfields; ++f)
    if (!std::strcmp(cd.fields[f].name, n)) return true;
  return false;
}

/// A channel OOE has, by name, or -1 if the wiring gives it none.
int optChan(const char *n) {
  for (const ChanDesc &cd : kChans)
    if (!std::strcmp(cd.name, n)) return int(cd.id);
  return -1;
}

class OoeModel : public Stub {
public:
  OoeModel(int inst, Kernel &k) : Stub(inst, k), core_(config(k)) {
    // A launched warp's registers map to the zero registers (A-64), and so do
    // its predicates while they are renamed: each warp's maps, so made, are
    // what the final compare reads where the warp never writes.
    for (unsigned w = 0; w != k.orcs.size(); ++w) {
      k.ratOf(w);
      k.pratOf(w, core_.config().rename_preds);
      // The final-exit assertion's lanes: the CTA's threads past this warp's
      // first, as RAU's launch names them (TI-27 (a)); a check, not OOE's
      // state.
      const unsigned t = k.orcs[w].threads, first = 32 * k.orcs[w].warp_in_cta;
      const unsigned n = t <= first ? 0 : t - first;
      if (t && n < 32) core_.expectLanes(w, n ? (1u << n) - 1 : 0);
    }
    // A full decode queue holds DEC's uops in their slots: its backpressure.
    holdsBack(ch().dec_ooe);
    core_.on_error = [this](const std::string &m) { k_.fail("ooe: %s", m.c_str()); };
    core_.on_event = [this](const char *n, unsigned w, uint64_t a, uint64_t b, uint64_t tid) {
      event(n, w, a, b, tid);
    };
    // OOE's structural events (OI-7): ids in schema order from EV_OOE_GPR_EMPTY.
    static_assert(EV_OOE_COPY_ISSUE - EV_OOE_GPR_EMPTY + 1 == unsigned(ooe::OoeEv::kCount),
                  "OoeEv must list schema/events.json's EV_OOE_* in id order");
    static_assert(EV_OOE_DECQ_FULL == EV_OOE_GPR_EMPTY + unsigned(ooe::OoeEv::kDecqFull) &&
                  EV_OOE_CANCEL_REPLAY == EV_OOE_GPR_EMPTY + unsigned(ooe::OoeEv::kCancelReplay),
                  "OoeEv out of id order");
    core_.on_ooe_event = [this](ooe::OoeEv k, unsigned w, uint64_t b, uint64_t c, uint64_t tid) {
      emit(now_, tid, EventId(EV_OOE_GPR_EMPTY + unsigned(k)), UNIT_OOE, w, uint32_t(b), uint32_t(c));
    };
  }
  ~OoeModel() override {
    // Sizing-sweep data (docs/ooe-model.md, "Sweeps"): every counter and
    // histogram, as JSON, when CCV_OOE_STATS names a file.
    const char *path = std::getenv("CCV_OOE_STATS");
    if (!path || !*path) return;
    std::ofstream o(path);
    o << "{\n  \"kernel\": \"" << k_.name << "\",\n  \"cycles\": " << now_
      << ",\n  \"retired\": " << k_.retired << ",\n  \"counters\": {";
    const char *sep = "\n";
    for (const auto &c : core_.counters) { o << sep << "    \"" << c.first << "\": " << c.second; sep = ",\n"; }
    o << "\n  },\n  \"histograms\": {";
    sep = "\n";
    for (const auto &h : core_.histograms) {
      o << sep << "    \"" << h.first << "\": {";
      const char *s2 = "";
      for (const auto &b : h.second) { o << s2 << "\"" << b.first << "\": " << b.second; s2 = ", "; }
      o << "}";
      sep = ",\n";
    }
    o << "\n  }\n}\n";
  }
  const char *kind() const override { return "ooe"; }

private:
  ooe::Core core_;
  bool bad_pos_done_ = false;   ///< the bad-pos control names one register
  std::map<unsigned, unsigned> rs_sent_;   ///< rob tag -> its memop's rs_idx (OA-23)
  int demote_ = optChan("ccv_rau_ooe_demote"), rel_ = optChan("ccv_syu_ooe_rel");
  int map_ = optChan("ccv_ooe_rcu_map"), bar_ = optChan("ccv_ooe_syu_bar");
  int drained_ = optChan("ccv_ooe_rau_drained"), status_ = optChan("ccv_ooe_rau_status");
  int fault_ = optChan("ccv_ooe_cru_fault");

  /// S1 modes: the core runs with what the S1 neighbours carry today, and
  /// CCV_OOE_CONFIG ("name=value,...") overrides any of it for a sweep.
  static ooe::Config config(Kernel &k) {
    ooe::Config c;
    // The design's modes: the lanes forward at CCV_LAT_LANE_BYP (TI-8) and
    // MIU completes an L1 hit at the contract (A-46), so both are on (OI-5).
    // CCV_OOE_CONFIG=bypass=0,l1_spec=0 runs the conservative path.
    // Predicates are renamed (Q-21, A-39): RCU reads the renamed sources
    // (TI-1) and the final compare reads through Kernel::prat0 (OI-3).
    // CCV_OOE_CONFIG=rename_preds=0 restores the fixed physPred windows.
    c.memop_rcu_done = false; // RCU sends no done for a memop (OI-4)
    // Sectioned lanes (OI-29 to OI-33): registers are slices of rows, and
    // select grants the nine resources one op each (V-60). Every S1 op is
    // full width, so a cycle carries one lane op, one memop and one RCU op.
    // no-resource-cap grants a second lane op onto held sections, and RCU
    // must refuse the overlap (V-60).
    c.sectioned = true;
    c.inject_double_grant = k.brk == "no-resource-cap";
    c.pred_window = [](unsigned w, unsigned p) { return physPred(w, p); };
    c.inject_free_new = k.brk == "free-new";
    unsigned data_link = ccv::kLatHop, cmpl_link = ccv::kLatHop;
    for (const ChanInst &ci : kChanInsts) {
      if (ci.chan == chanId("ccv_ooe_fet_redirect")) c.redirect_lat = ccv::kLatHop + ci.stages;
      if (ci.chan == chanId("ccv_ooe_rcu_issue")) c.issue_link = ccv::kLatHop + ci.stages;
      if (ci.chan == chanId("ccv_rcu_ooe_done")) c.done_link = ccv::kLatHop + ci.stages;
      if (ci.chan == chanId("ccv_miu_rcu_data")) data_link = ccv::kLatHop + ci.stages;
      if (ci.chan == chanId("ccv_miu_ooe_cmpl")) cmpl_link = ccv::kLatHop + ci.stages;
    }
    // CCV_LAT_L1_MISS_WAKE is generated from the same links (OI-13), plus
    // the cycle an event-driven wake loses against a timed one (OA's
    // response OI-26); a build whose parameters and wiring disagree is
    // stale, not a run.
    const int d = int(data_link) - int(cmpl_link) - int(c.issue_link) + 1;
    const unsigned want = unsigned(d > 0 ? d : 0) + 1;
    if (want != c.cmpl_wake_delay) {
      std::fprintf(stderr, "ooe: CCV_LAT_L1_MISS_WAKE %u, but the wiring gives %u: regenerate\n",
                   c.cmpl_wake_delay, want);
      std::abort();
    }
    if (const char *s = std::getenv("CCV_OOE_CONFIG")) {
      const std::string e = c.apply(s);
      if (!e.empty()) {
        std::fprintf(stderr, "%s\n", e.c_str());
        std::abort();
      }
    }
    return c;
  }

  bool hasIn(int chan) const {
    if (chan < 0) return false;
    for (const In &i : ins) if (int(i.ci->chan) == chan) return true;
    return false;
  }
  bool hasOut(int chan) const {
    if (chan < 0) return false;
    for (const Out &o : outs) if (int(o.ci->chan) == chan) return true;
    return false;
  }
  const Receiver *peek(unsigned chan, unsigned slot) const {
    for (const In &i : ins)
      if (i.ci->chan == chan && i.slot == slot) return i.rx;
    return nullptr;
  }

  void event(const char *n, unsigned w, uint64_t a, uint64_t b, uint64_t tid) {
    const std::string s(n);
    if (s == "dispatch") emit(now_, tid, EV_DISPATCH, UNIT_OOE, w, uint32_t(a));
    else if (s == "issue") emit(now_, tid, EV_ISSUE, UNIT_OOE, w, uint32_t(a), uint32_t(b));
    else if (s == "wakeup") emit(now_, tid, EV_WAKEUP, UNIT_OOE, w, uint32_t(a), uint32_t(b));
    else if (s == "retire") emit(now_, tid, EV_RETIRE, UNIT_OOE, w, uint32_t(a), 0xffffffffu);
    // Coverage bins (docs/coverage.md), counted where the path is taken.
    else if (s == "redirect" || s == "merge" || s == "copy" || s == "zero_read" ||
             s == "reg_reuse" || s == "epoch_drop")
      k_.hit(n);
  }

  // -- inputs ---------------------------------------------------------------------------

  ooe::Uop decode(const Receiver::Msg &m) {
    const Ch &c = ch();
    const Bits &p = m.payload;
    ooe::Uop u;
    u.tid = m.tid;
    u.warp = unsigned(get(p, c.dec_ooe, "warp_id"));
    u.pc = get(p, c.dec_ooe, "pc");
    u.group_mask = uint32_t(get(p, c.dec_ooe, "group_mask"));
    u.fetch_epoch = unsigned(get(p, c.dec_ooe, "fetch_epoch"));
    u.attr_raw = uint32_t(get(p, c.dec_ooe, "sched_attr"));
    u.attr = ooe::SchedAttr::decode(u.attr_raw);
    u.mem_op = unsigned(get(p, c.dec_ooe, "mem_op"));
    u.space = unsigned(get(p, c.dec_ooe, "space"));
    u.ordering = unsigned(get(p, c.dec_ooe, "ordering"));
    u.opcode = unsigned(get(p, c.dec_ooe, "opcode"));
    const unsigned sa = unsigned(get(p, c.dec_ooe, "src_arch"));
    u.src[0] = (sa >> 4) & 15;
    u.src[1] = sa & 15;
    u.src[2] = unsigned(get(p, c.dec_ooe, "src2_arch"));
    u.dst = unsigned(get(p, c.dec_ooe, "dst_arch"));
    u.pred_guard = unsigned(get(p, c.dec_ooe, "pred_guard"));
    u.pred_neg = get(p, c.dec_ooe, "pred_neg") != 0;
    u.pred_dst = unsigned(get(p, c.dec_ooe, "pred_dst"));
    u.pred_we = get(p, c.dec_ooe, "pred_we") != 0;
    u.imm = uint32_t(get(p, c.dec_ooe, "imm"));
    u.ilen = unsigned(get(p, c.dec_ooe, "ilen"));
    u.ckpt = unsigned(get(p, c.dec_ooe, "checkpoint_id"));
    u.pred_taken = get(p, c.dec_ooe, "pred_taken") != 0;
    u.scale_en = get(p, c.dec_ooe, "scale_en") != 0;
    u.slot_form = unsigned(get(p, c.dec_ooe, "slot_form"));
    u.arg_slot = unsigned(get(p, c.dec_ooe, "arg_slot"));
    u.local_form = unsigned(get(p, c.dec_ooe, "local_form"));
    if (hasField(c.dec_ooe, "xfer_size")) {   // O-80
      u.xfer_size = unsigned(get(p, c.dec_ooe, "xfer_size"));
      u.xfer_signed = get(p, c.dec_ooe, "xfer_signed") != 0;
    }
    u.cause = unsigned(get(p, c.dec_ooe, "cause"));
    u.fmt_rsv = unsigned(get(p, c.dec_ooe, "fmt_rsv"));
    u.fmt_opnd = unsigned(get(p, c.dec_ooe, "fmt_opnd"));
    // What DEC decodes so OOE never looks at opcode (A-75, TI-1): which
    // source fields are real reads, how the predicate is read, what imm
    // holds, and exit as sched_attr's serial code 3.
    if (!u.cause) {
      u.shape.gpr_reads = uint8_t(get(p, c.dec_ooe, "src_valid") & 7u);
      const unsigned pu = unsigned(get(p, c.dec_ooe, "pred_use"));
      const unsigned ik = unsigned(get(p, c.dec_ooe, "imm_kind"));
      u.shape.guard = pu == kPredUseGuard;
      u.shape.pdata = pu == kPredUseData;
      u.shape.pred_logic = ik == kImmPredSrcs;
      u.shape.exit = u.attr.serial == kSerExit;
      // TI-27's final-exit bit (OA's rev 170): FET marks the exit that
      // clears the warp's last live lanes.
      u.shape.final_exit = u.shape.exit && get(p, c.dec_ooe, "final_exit") != 0;
      // TI-40: FET's all_waiting mark, a converged wait's and the barrier
      // timer's.
      u.all_waiting = get(p, c.dec_ooe, "all_waiting") != 0;
      // lanectx-as-ctatid: srd #2 taken as srd #0, the warp's index in its
      // CTA where O-64 names its hardware context.
      u.shape.srd = ik == kImmWarpBase ? 0 : ik == kImmCtaid ? 1
                  : ik == kImmLaneCtx ? (k_.brk == "lanectx-as-ctatid" ? 0 : 2) : -1;
      if (pu > kPredUseData) {
        k_.fail("ooe: pred_use %u is not a code", pu);
        u.cause = 2;   // F-ILLEGAL: an encoding naming nothing
      }
    }
    return u;
  }

  void takeInputs() {
    const Ch &c = ch();
    if (has(c.rau_ooe, 0)) {
      Receiver::Msg m = take(c.rau_ooe, 0);
      ooe::Alloc a;
      a.warp = unsigned(get(m.payload, c.rau_ooe, "warp_id"));
      a.op = unsigned(get(m.payload, c.rau_ooe, "alloc_op"));
      a.slot = unsigned(get(m.payload, c.rau_ooe, "tier1_id"));
      a.ctaid = uint32_t(get(m.payload, c.rau_ooe, "ctaid"));
      a.warp_in_cta = uint32_t(get(m.payload, c.rau_ooe, "warp_in_cta"));
      a.barrier_count = unsigned(get(m.payload, c.rau_ooe, "barrier_count"));
      a.cta_slot = unsigned(get(m.payload, c.rau_ooe, "cta_slot"));
      core_.alloc(a);
    }
    if (hasIn(demote_) && has(unsigned(demote_), 0)) {
      Receiver::Msg m = take(unsigned(demote_), 0);
      core_.demote(unsigned(get(m.payload, unsigned(demote_), "warp_id")));
    }
    if (hasIn(rel_) && has(unsigned(rel_), 0)) {
      Receiver::Msg m = take(unsigned(rel_), 0);
      // A held wait's answer names its warp (TI-40); the core takes a mask.
      core_.barRelease(uint32_t(1) << get(m.payload, unsigned(rel_), "warp_id"));
    }
    for (unsigned s = 0; s != kChans[c.rcu_ooe].rate; ++s)
      while (has(c.rcu_ooe, s)) {
        Receiver::Msg m = take(c.rcu_ooe, s);
        ooe::Done d;
        d.rob_tag = unsigned(get(m.payload, c.rcu_ooe, "rob_tag"));
        d.branch_taken = get(m.payload, c.rcu_ooe, "branch_taken") != 0;
        d.branch_mask = uint32_t(get(m.payload, c.rcu_ooe, "branch_mask"));
        // TI's d347d2c names the field branch_aux, renamed aux after it.
        for (const char *f : {"aux", "branch_aux"})
          if (hasField(c.rcu_ooe, f)) d.aux = uint32_t(get(m.payload, c.rcu_ooe, f));
        core_.done(d);
      }
    // Completion hints (OA-23), taken as they land, as a fixed-latency
    // channel's must be: each names the memop's RS entry, and the model
    // keeps a spec load's wake on one that comes by its miss's lead
    // (Config::miss_lead). The bank holds MIU to each one's promise.
    for (unsigned s = 0; s != kChans[c.cmpl_hint].rate; ++s)
      while (has(c.cmpl_hint, s)) {
        Receiver::Msg m = take(c.cmpl_hint, s);
        const unsigned tag = unsigned(get(m.payload, c.cmpl_hint, "rob_tag"));
        const unsigned rs = unsigned(get(m.payload, c.cmpl_hint, "rs_idx"));
        auto e = rs_sent_.find(tag);
        if (e != rs_sent_.end() && e->second != rs)
          k_.fail("ooe: rob tag %u hinted for RS entry %u, but its memop named entry %u", tag, rs, e->second);
        core_.hint(tag);
      }
    for (unsigned s = 0; s != kChans[c.miu_ooe].rate; ++s)
      while (has(c.miu_ooe, s)) {
        Receiver::Msg m = take(c.miu_ooe, s);
        ooe::Cmpl x;
        x.rob_tag = unsigned(get(m.payload, c.miu_ooe, "rob_tag"));
        x.status = unsigned(get(m.payload, c.miu_ooe, "status"));
        x.cause = unsigned(get(m.payload, c.miu_ooe, "cause"));
        x.lane_mask = uint32_t(get(m.payload, c.miu_ooe, "lane_mask"));
        x.address = get(m.payload, c.miu_ooe, "address");
        x.mlc_miss = get(m.payload, c.miu_ooe, "mlc_miss") != 0;
        // MIU echoes the memop's RS entry (OA-23): any other is a completion
        // that would wake the wrong entry.
        const unsigned rs = unsigned(get(m.payload, c.miu_ooe, "rs_idx"));
        x.rs_idx = rs;
        x.more = get(m.payload, c.miu_ooe, "more") != 0;   // an atomic's write (AR-21)
        auto e = rs_sent_.find(x.rob_tag);
        if (e != rs_sent_.end() && e->second != rs)
          k_.fail("ooe: rob tag %u completed for RS entry %u, but its memop "
                  "named entry %u", x.rob_tag, rs, e->second);
        core_.cmpl(x);
      }
  }

  /// Uops, oldest first by (arrival, slot): ordering is per warp_id, so a
  /// warp whose oldest uop cannot be taken takes none behind it this cycle.
  /// A uop not taken stays in its slot, its credit unreturned. At most one a
  /// slot a cycle: a slot returns one credit a cycle, so a second take from
  /// it would lose one (Receiver::pop). With several warps the slots back up
  /// two deep, and the first multi-warp kernels lost credits here (TI). The
  /// uop left behind holds its warp for the cycle, so a warp's uops are
  /// still taken in its order.
  void takeUops() {
    const Ch &c = ch();
    const unsigned rate = kChans[c.dec_ooe].rate;
    std::set<unsigned> held, taken;
    for (;;) {
      // Each warp's oldest uop buffered anywhere, by (arrival, slot, place):
      // a slot's head is taken only if it is its warp's oldest, so a younger
      // uop never passes one of its warp's held behind another warp's.
      std::map<unsigned, std::tuple<uint64_t, unsigned, size_t>> oldest;
      for (unsigned s = 0; s != rate; ++s) {
        const Receiver *r = peek(c.dec_ooe, s);
        for (size_t i = 0; r && i != r->size(); ++i) {
          const unsigned w = unsigned(get(r->at(i).payload, c.dec_ooe, "warp_id"));
          const auto key = std::make_tuple(r->at(i).arrived, s, i);
          auto o = oldest.find(w);
          if (o == oldest.end() || key < o->second) oldest[w] = key;
        }
      }
      int best = -1;
      uint64_t when = 0;
      for (unsigned s = 0; s != rate; ++s) {
        const Receiver *r = peek(c.dec_ooe, s);
        if (!r || r->empty()) continue;
        const unsigned w = unsigned(get(r->front().payload, c.dec_ooe, "warp_id"));
        // A slot already taken from this cycle holds its next uop back, and
        // with it that uop's warp: nothing younger of the warp may pass it.
        if (taken.count(s)) { held.insert(w); continue; }
        if (held.count(w) || oldest[w] != std::make_tuple(r->front().arrived, s, size_t(0)))
          continue;
        if (best < 0 || r->front().arrived < when) { best = int(s); when = r->front().arrived; }
      }
      if (best < 0) return;
      const Receiver *r = peek(c.dec_ooe, unsigned(best));
      const unsigned w = unsigned(get(r->front().payload, c.dec_ooe, "warp_id"));
      if (!core_.canAccept(w)) { core_.noteRefused(w); held.insert(w); continue; }
      taken.insert(unsigned(best));
      core_.uop(decode(take(c.dec_ooe, unsigned(best))));
    }
  }

  // -- outputs --------------------------------------------------------------------------

  void sendOutputs() {
    const Ch &c = ch();
    const ooe::Outputs &o = core_.out;
    std::vector<std::pair<const ooe::Issue *, Bits>> issues;
    for (const ooe::Issue &x : o.issues) {
      Bits is = msgOf(c.ooe_rcu);
      put(is, c.ooe_rcu, "rob_tag", x.rob_tag);
      put(is, c.ooe_rcu, "warp_id", x.warp);
      put(is, c.ooe_rcu, "issue_mask", x.issue_mask);
      // A name is a row and a position (sectioned; unsectioned the position
      // is 0): rows in the phys_ fields, positions beside them.
      const auto row = [this](unsigned n) { return core_.nameRow(n); };
      const auto pos = [this](unsigned n) { return core_.namePos(n); };
      put(is, c.ooe_rcu, "phys_src", (row(x.psrc[0]) << 8) | row(x.psrc[1]));
      put(is, c.ooe_rcu, "phys_src2", row(x.psrc[2]));
      put(is, c.ooe_rcu, "src_pos",
          pos(x.psrc[0]) | pos(x.psrc[1]) << ccv::kWPhysPos | pos(x.psrc[2]) << (2 * ccv::kWPhysPos));
      if (x.send_imm) put(is, c.ooe_rcu, "imm", x.imm);
      put(is, c.ooe_rcu, "phys_dst", row(x.pdst));
      put(is, c.ooe_rcu, "dst_pos", pos(x.pdst));
      put(is, c.ooe_rcu, "phys_pred_guard", x.ppguard);
      put(is, c.ooe_rcu, "phys_pred_dst", x.ppdst);
      put(is, c.ooe_rcu, "pred_we", x.pred_we);
      put(is, c.ooe_rcu, "merge_en", x.merge);
      put(is, c.ooe_rcu, "phys_old_dst", row(x.pold));
      put(is, c.ooe_rcu, "old_dst_pos", pos(x.pold));
      put(is, c.ooe_rcu, "phys_pred_old_dst", x.ppold);
      put(is, c.ooe_rcu, "chwidth", x.chwidth);
      // corrupt-ckpt and stale-free ride drop-negate's forced mispredict:
      // each needs a redirect.
      put(is, c.ooe_rcu, "pred_neg", x.pred_neg && k_.brk != "drop-negate" &&
                                     k_.brk != "corrupt-ckpt" && k_.brk != "stale-free");
      put(is, c.ooe_rcu, "opcode", x.copy ? kOpCopy : x.opcode);
      put(is, c.ooe_rcu, "bypass_group", x.byp_group);
      // Each operand carries its register's width code (AR-24 (d)). bad-pos
      // names the first lane op's 32-bit destination at position 1, which
      // overruns its row: RCU must refuse it.
      for (unsigned i = 0; i != 3; ++i)
        is.set(field(c.ooe_rcu, "src_width").lsb + ccv::kWChwidth * i, ccv::kWChwidth, x.src_w[i]);
      put(is, c.ooe_rcu, "dst_width", x.dst_w);
      const OpInfo *gop = x.copy ? nullptr : opByCode(x.opcode);
      if (k_.brk == "bad-pos" && x.res == ooe::Issue::kLaneOp && gop && gop->gdst &&
          !bad_pos_done_) {
        put(is, c.ooe_rcu, "dst_pos", 1);
        bad_pos_done_ = true;
      }
      // skip-copy: the load issues alone, so its inactive lanes keep whatever
      // the fresh register held (A-38).
      if (x.copy && k_.brk == "skip-copy") continue;
      issues.emplace_back(&x, is);
    }
    sendIssues(issues);
    for (const ooe::Memop &x : o.memops) {
      Bits mo = msgOf(c.ooe_miu);
      put(mo, c.ooe_miu, "rob_tag", x.rob_tag);
      put(mo, c.ooe_miu, "warp_id", x.warp);
      put(mo, c.ooe_miu, "mem_op", x.mem_op);
      if (x.mem_op == 0xF) {
        // A bulk discard: every other field reserved and zero (V-40).
        const FieldDesc &d = field(c.ooe_miu, "disp");
        mo.set(d.lsb, ccv::prov::kWRobIdx, x.disp);
      } else {
        // The RS entry, which MIU echoes on the completion and names on its
        // hint (OA-23).
        put(mo, c.ooe_miu, "rs_idx", x.rs_idx);
        rs_sent_[x.rob_tag] = x.rs_idx;
        put(mo, c.ooe_miu, "issue_mask", x.issue_mask);
        put(mo, c.ooe_miu, "phys_dst", core_.nameRow(x.pdst));
        put(mo, c.ooe_miu, "dst_pos", core_.namePos(x.pdst));
        put(mo, c.ooe_miu, "phys_pred", x.ppred);
        put(mo, c.ooe_miu, "disp",                 // truncated to CCV_W_DISP
            x.disp + (k_.brk == "corrupt-disp" && uidSeq(x.tid) == 6 ? 4u : 0u));
        put(mo, c.ooe_miu, "scale_en", x.scale_en);
        put(mo, c.ooe_miu, "space", x.space);
        put(mo, c.ooe_miu, "ordering", x.ordering);
        put(mo, c.ooe_miu, "slot_form", x.slot_form);
        put(mo, c.ooe_miu, "arg_slot", x.arg_slot);
        put(mo, c.ooe_miu, "local_form", x.local_form);
        if (hasField(c.ooe_miu, "xfer_size")) {
          put(mo, c.ooe_miu, "xfer_size", x.xfer_size);
          put(mo, c.ooe_miu, "xfer_signed", x.xfer_signed);
        }
        // zero-cta-slot: every memop and fault named CTA slot 0, as before
        // TI-34; MIU's and CRU's checks refuse a warp of any other slot.
        put(mo, c.ooe_miu, "cta_slot", k_.brk == "zero-cta-slot" ? 0u : x.cta_slot);
        put(mo, c.ooe_miu, "chwidth", x.chwidth);
        // The memop's pipe footprint at its data register's position, at
        // that register's width (AR-24 (d)). narrow-pipes names one pipe for
        // a 32-bit memop: MIU refuses it.
        put(mo, c.ooe_miu, "pipes",
            k_.brk == "narrow-pipes" ? 1u : maskOf(x.chwidth, x.data_pos));
      }
      // A demotion's discard of an empty ROB names no instruction (TI-21).
      sendOn(c.ooe_miu, x.port, mo,
             x.mem_op == 0xF && !x.tid ? makeUid(IdClass::kNone, 0) : x.tid);
    }
    for (const ooe::Commit &x : o.commits) {
      Bits r = msgOf(c.ooe_ret);
      put(r, c.ooe_ret, "rob_tag", x.rob_tag);
      put(r, c.ooe_ret, "commit_or_discard", x.commit);
      sendOn(c.ooe_ret, x.port, r, x.tid);
    }
    uint64_t free_mask = o.free_mask;
    for (const ooe::Redirect &x : o.redirects) {
      Bits r = msgOf(c.ooe_fet);
      put(r, c.ooe_fet, "warp_id", x.warp);
      put(r, c.ooe_fet, "tier1_id", x.slot);
      put(r, c.ooe_fet, "fetch_epoch", x.epoch);
      put(r, c.ooe_fet, "epoch_only", x.epoch_only);
      // A demotion's rewind beat (TI-24 (3)): the lanes and their PC.
      put(r, c.ooe_fet, "rewind", x.rewind);
      if (x.rewind) {
        put(r, c.ooe_fet, "taken_mask", x.taken_mask);
        // rewind-pc: each beat names the next instruction's PC, so the
        // lanes resume one past their boundary (TI's control).
        put(r, c.ooe_fet, "target_pc", x.target_pc + (k_.brk == "rewind-pc" ? 2u : 0u));
        // A beat of a warp held behind a retired wait (TI-40): FET steps
        // its lanes back over the wait.
        put(r, c.ooe_fet, "rewind_held", x.rewind_held);
        put(r, c.ooe_fet, "held_long", x.held_long);
        if (hasField(c.ooe_fet, "own_pc")) put(r, c.ooe_fet, "own_pc", x.own_pc);
      }
      if (!x.epoch_only) {
        put(r, c.ooe_fet, "target_pc", x.target_pc);
        put(r, c.ooe_fet, "checkpoint_id",
            k_.brk == "corrupt-ckpt" ? (x.ckpt + 1) % ccv::prov::kBrCkpts : x.ckpt);
        put(r, c.ooe_fet, "taken_mask", x.taken_mask);
        if (hasField(c.ooe_fet, "stay")) put(r, c.ooe_fet, "stay", x.stay);   // a ret's (AR-24 (b))
        // stale-free breaks A-58's first rule on purpose: it frees the
        // checkpoint the same cycle's redirect restores.
        if (k_.brk == "stale-free") free_mask |= uint64_t(1) << (x.slot * ccv::prov::kBrCkpts + x.ckpt);
      }
      sendOn(c.ooe_fet, 0, r, x.epoch_only && !x.rewind ? makeUid(IdClass::kInstr, 0) : x.tid);
    }
    if (free_mask) {
      Bits f = msgOf(c.ooe_free);
      put(f, c.ooe_free, "free_mask", free_mask);
      sendOn(c.ooe_free, 0, f, makeUid(IdClass::kNone, 0));
    }
    // Demotion (TI-24): the status reports RAU decides on, and a demoting
    // warp's map to RCU and drained report to RAU. Each channel is rate 1
    // and the core may make two in a cycle, so they queue here in order.
    const uint64_t none = makeUid(IdClass::kNone, 0);
    for (const ooe::Status &x : o.status) {
      Bits m = msgOf(unsigned(status_));
      put(m, unsigned(status_), "warp_id", x.warp);
      put(m, unsigned(status_), "fault_taken", x.fault_taken);
      put(m, unsigned(status_), "stalled", x.stalled);
      put(m, unsigned(status_), "mlc_miss_seen", x.mlc_miss_seen);
      put(m, unsigned(status_), "retired_since_restore", x.retired_since_restore);
      put(m, unsigned(status_), "exited", x.exited);   // OA's rev 149
      held_.push_back({unsigned(status_), m});
    }
    for (const ooe::RatMap &x : o.maps) {
      // Rows, positions and widths (OI-29): each register's position its
      // name's, its width its committed code (TI's rev 184).
      const unsigned mc = unsigned(map_);
      Bits m = msgOf(mc);
      put(m, mc, "warp_id", x.warp);
      put(m, mc, "direction", x.direction);
      const FieldDesc &gm = field(mc, "gpr_map"), &gp = field(mc, "gpr_pos"),
                      &gw = field(mc, "gpr_width"), &pm = field(mc, "pred_map");
      for (unsigned a = 0; a != kArchGprs; ++a) {
        // corrupt-map: R1 named by R2's row, so PCA saves the wrong value.
        // restore-share: a restore map naming R2's row for R1 too, so two
        // registers share one row: RCU refuses it (TI-25 (1)).
        const unsigned g = (k_.brk == "corrupt-map" || (k_.brk == "restore-share" && x.direction == 1)) && a == 1
                               ? x.gpr[2] : x.gpr[a];
        m.set(gm.lsb + a * (gm.width / kArchGprs), gm.width / kArchGprs, core_.nameRow(g));
        m.set(gp.lsb + a * (gp.width / kArchGprs), gp.width / kArchGprs, core_.namePos(x.gpr[a]));
        m.set(gw.lsb + a * (gw.width / kArchGprs), gw.width / kArchGprs, x.w[a]);
      }
      for (unsigned p = 0; p != kArchPreds; ++p)
        m.set(pm.lsb + p * (pm.width / kArchPreds), pm.width / kArchPreds, x.pred[p]);
      held_.push_back({mc, m});
    }
    for (const ooe::Drained &x : o.drained) {
      const unsigned dc = unsigned(drained_);
      Bits m = msgOf(dc);
      put(m, dc, "warp_id", x.warp);
      put(m, dc, "resume_pc", x.resume_pc + (k_.brk == "resume-pc" ? 2u : 0u));
      put(m, dc, "arch_state_ready", x.refused ? 0 : 1);
      put(m, dc, "refused", x.refused);   // TI-25 (2)
      held_.push_back({dc, m});
    }
    for (auto it = held_.begin(); it != held_.end();) {
      bool first = true;   // the oldest held message on its channel only
      for (auto j = held_.begin(); j != it; ++j) first = first && j->chan != it->chan;
      if (first && can(it->chan, 0)) {
        send(it->chan, 0, it->msg, it->tid ? it->tid : none);
        it = held_.erase(it);
      } else {
        ++it;
      }
    }
    // A fault taken at retirement goes to CRU (TI-26), whose stub holds it
    // to the fault ccv-sim ended the run with. No kernel is
    // killed yet.
    for (const ooe::Fault &x : o.faults) {
      if (fault_ < 0) {
        k_.fail("ooe: warp %u faults at retirement (cause %u) at pc %llx", x.warp, x.cause,
                (unsigned long long)x.pc);
        continue;
      }
      const unsigned fc = unsigned(fault_);
      Bits m = msgOf(fc);
      put(m, fc, "cause", x.cause);
      put(m, fc, "pc", x.pc);
      put(m, fc, "lane_mask", x.lane_mask);
      put(m, fc, "address", x.address);
      put(m, fc, "cta_slot", k_.brk == "zero-cta-slot" ? 0u : x.cta_slot);
      put(m, fc, "warp_id", x.warp);
      held_.push_back({fc, m, x.tid});
    }
    // Barrier reports at retire (TI-40), to SYU.
    for (const ooe::Bar &x : o.bars) {
      if (bar_ < 0) {
        k_.fail("ooe: warp %u's barrier report with no ccv_ooe_syu_bar", x.warp);
        continue;
      }
      const unsigned bc = unsigned(bar_);
      Bits m = msgOf(bc);
      put(m, bc, "warp_id", x.warp);
      put(m, bc, "cta_slot", x.cta_slot);
      put(m, bc, "barrier_id", x.barrier_id);
      put(m, bc, "bar_kind", x.kind);
      put(m, bc, "issue_mask", x.issue_mask);
      put(m, bc, "guard_mask", x.guard_mask);
      put(m, bc, "phase_mask", x.phase_mask);
      put(m, bc, "held", x.held);
      held_.push_back({bc, m, x.tid});
    }
    // The model's kill ack (V-24): it has squashed and released the killed
    // warps, its epoch notice has landed in FET, and no memop is out at MIU.
    for (unsigned e : o.kill_acks)
      if (kill_live_ && e == kill_epoch_) kill_acked_ = true;
  }
  /// The kill (V-24): the model takes it, and acks once quiesced.
  void onKill(uint32_t mask, unsigned epoch) override {
    core_.kill(mask, epoch);
    kill_live_ = true;
    kill_acked_ = false;
    kill_epoch_ = epoch;
  }
  bool killQuiet(uint32_t) const override { return kill_acked_; }
  bool kill_live_ = false, kill_acked_ = false;
  unsigned kill_epoch_ = 0;
  struct Held { unsigned chan; Bits msg; uint64_t tid = 0; };   ///< tid: the fault's instruction
  std::deque<Held> held_;   ///< status, maps and drained reports, in order

  /// ccv_ooe_rcu_issue is one slot per select resource (S0-S3, P0-P3, R): an
  /// op goes in its footprint's lowest slot, and the rest of its footprint
  /// carries continuation, its rob_tag and cont = 1. Leads go first, then
  /// continuations. Under no-resource-cap (inject_double_grant) two ops claim
  /// one group in a cycle: the second lead takes the next free slot, as a
  /// select with no per-resource pick would place it, continuations take
  /// what is left, and RCU must refuse the overlap (V-60) or the slot.
  void sendIssues(const std::vector<std::pair<const ooe::Issue *, Bits>> &issues) {
    const Ch &c = ch();
    const bool loose = k_.brk == "no-resource-cap";
    auto group = [](const ooe::Issue &x) {
      return x.res == ooe::Issue::kRcuOp ? kSlotR
             : x.res == ooe::Issue::kMemop ? kSlotP0 : kSlotS0;
    };
    for (const auto &p : issues) {
      const ooe::Issue &x = *p.first;
      const unsigned fp = x.res == ooe::Issue::kRcuOp ? 0u : x.footprint;
      unsigned s = group(x) + (fp ? unsigned(__builtin_ctz(fp)) : 0u);
      for (unsigned k = 0; loose && k != kSlotR && !can(c.ooe_rcu, s); ++k)
        s = (s + 1) % (kSlotR + 1);
      Bits msg = p.second;
      put(msg, c.ooe_rcu, "footprint", fp);
      sendOn(c.ooe_rcu, s, msg, x.tid);
    }
    for (const auto &p : issues) {
      const ooe::Issue &x = *p.first;
      if (x.res == ooe::Issue::kRcuOp) continue;
      for (unsigned b = unsigned(__builtin_ctz(x.footprint)) + 1; b < kSecs; ++b) {
        const unsigned s = group(x) + b;
        if (!((x.footprint >> b) & 1u) || (loose && !can(c.ooe_rcu, s))) continue;
        Bits ct = msgOf(c.ooe_rcu);
        put(ct, c.ooe_rcu, "rob_tag", x.rob_tag);
        put(ct, c.ooe_rcu, "cont", 1);
        sendOn(c.ooe_rcu, s, ct, x.tid);
      }
    }
  }

  void sendOn(unsigned chan, unsigned port, const Bits &msg, uint64_t tid) {
    if (!can(chan, port)) {
      // Every OOE output is fixed-latency or credited from a pool OOE sized
      // its issue against; a missing credit is a model error, not a stall.
      k_.fail("ooe: no credit on %s slot %u", kChans[chan].name, port);
      return;
    }
    send(chan, port, msg, tid);
  }

  void work() override {
    takeInputs();
    core_.cycle(now_);
    takeUops();
    sendOutputs();
    for (const ooe::Retired &r : core_.retired) {
      // An instruction retires with its last uop (TI-36's cracked ones).
      if (k_.lastUop(r.tid)) {
        ++k_.retired;
        k_.retire_order.push_back(uidSeq(r.tid));
      }
      if (r.exit) ++k_.exits;
      // Each warp's map for the final compare (rows), made at its first use.
      if (r.writes_gpr) k_.ratOf(r.warp)[r.dst] = core_.nameRow(r.pnew);
      // The predicate map likewise, while predicates are renamed (OI-3);
      // left empty, the final compare reads the fixed physPred windows.
      if (r.writes_pred && core_.config().rename_preds)
        k_.pratOf(r.warp, true)[r.pdst] = r.ppnew;
    }

  }

  bool busy() const override { return core_.busy(); }
};

} // namespace

std::unique_ptr<Block> makeOoeModel(int inst, Kernel &k) {
  return std::make_unique<OoeModel>(inst, k);
}

} // namespace skel
} // namespace ccv
