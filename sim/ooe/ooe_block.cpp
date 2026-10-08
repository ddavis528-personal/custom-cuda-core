//===-- ooe_block.cpp - the OOE model at the swap boundary ---------------===//
//
// Packs and unpacks OOE's channels around ooe::Core, and nothing else: the
// core holds every structure and decision. Reads only OOE's own receivers and
// writes only its own senders (stub.h); the oracle is never consulted.
//
// What lives here rather than in the core:
//   - the testbench hooks (Kernel): retire bookkeeping, rat0, coverage bins,
//     events, and check failures for the core's contract and invariant errors;
//   - the negative controls that act on a message (corrupt-ckpt, stale-free,
//     drop-negate, skip-copy, corrupt-disp); free-new acts inside the core;
//   - A-75's temporary opcode lookup (UopShape), until DEC delivers it;
//   - the S1 configuration (docs/ooe-model.md, "S1 modes"): which of the
//     core's mechanisms the S1 neighbours can carry today.
//===----------------------------------------------------------------------===//
#include "stub.h"
#include "ooe_core.h"

#include <cstdlib>
#include <fstream>

namespace ccv {
namespace skel {
namespace {

/// A channel OOE has, by name, or -1 if the wiring gives it none.
int optChan(const char *n) {
  for (const ChanDesc &cd : kChans)
    if (!std::strcmp(cd.name, n)) return int(cd.id);
  return -1;
}

class OoeModel : public Stub {
public:
  OoeModel(int inst, Kernel &k) : Stub(inst, k), core_(config(k)) {
    k.rat0.assign(kArchGprs, ccv::prov::kPhysZero);
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
  int demote_ = optChan("ccv_rau_ooe_demote"), rel_ = optChan("ccv_syu_ooe_rel");
  int map_ = optChan("ccv_ooe_rcu_map"), bar_ = optChan("ccv_ooe_syu_bar");
  int drained_ = optChan("ccv_ooe_rau_drained"), status_ = optChan("ccv_ooe_rau_status");
  int fault_ = optChan("ccv_ooe_cru_fault");

  /// S1 modes: the core runs with what the S1 neighbours carry today, and
  /// CCV_OOE_CONFIG ("name=value,...") overrides any of it for a sweep.
  static ooe::Config config(Kernel &k) {
    ooe::Config c;
    c.bypass = false;        // RCU reads the PRF when it takes the issue
    c.l1_spec = false;       // the gate also runs every kernel with it on (OI-5)
    c.rename_preds = false;  // RCU and compareFinal read physPred windows
    c.memop_rcu_done = true; // RCU sends a done for loads and stores too
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
    // CCV_LAT_L1_MISS_WAKE is generated from the same links (OI-13); a
    // build whose parameters and wiring disagree is stale, not a run.
    const int d = int(data_link) - int(cmpl_link) - int(c.issue_link) + 1;
    if (unsigned(d > 0 ? d : 0) != c.cmpl_wake_delay) {
      std::fprintf(stderr, "ooe: CCV_LAT_L1_MISS_WAKE %u, but the wiring gives %d: regenerate\n",
                   c.cmpl_wake_delay, d > 0 ? d : 0);
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
    u.decode_fault = get(p, c.dec_ooe, "decode_fault") != 0;
    // TEMPORARY (A-75): what DEC does not yet deliver -- which source
    // fields are real reads, guard or data predicate, predicate logic's
    // sources, exit, srd's identity -- from the skeleton's opcode table.
    // Nothing else in OOE looks at opcode.
    if (!u.decode_fault) {
      const OpInfo *op = opByCode(u.opcode);
      if (!op) {
        k_.fail("ooe: a uop it cannot execute");
        u.decode_fault = true;
      } else {
        for (unsigned i = 0; i != op->nsrc; ++i) u.shape.gpr_reads |= uint8_t(1u << i);
        u.shape.guard = op->guard;
        u.shape.pdata = op->pdata;
        u.shape.pred_logic = op->cls == kPredLogic;
        u.shape.exit = op->cls == kExit;
        u.shape.srd = op->srd_sel < 0 ? -1 : op->or_lane ? 0 : 1;
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
      core_.alloc(a);
    }
    if (hasIn(demote_) && has(unsigned(demote_), 0)) {
      Receiver::Msg m = take(unsigned(demote_), 0);
      core_.demote(unsigned(get(m.payload, unsigned(demote_), "warp_id")));
    }
    if (hasIn(rel_) && has(unsigned(rel_), 0)) {
      Receiver::Msg m = take(unsigned(rel_), 0);
      core_.barRelease(uint32_t(get(m.payload, unsigned(rel_), "warp_mask_released")));
    }
    for (unsigned s = 0; s != kChans[c.rcu_ooe].rate; ++s)
      while (has(c.rcu_ooe, s)) {
        Receiver::Msg m = take(c.rcu_ooe, s);
        ooe::Done d;
        d.rob_tag = unsigned(get(m.payload, c.rcu_ooe, "rob_tag"));
        d.exec_fault = get(m.payload, c.rcu_ooe, "exec_fault") != 0;
        d.branch_taken = get(m.payload, c.rcu_ooe, "branch_taken") != 0;
        d.branch_mask = uint32_t(get(m.payload, c.rcu_ooe, "branch_mask"));
        d.fault_lane_mask = uint32_t(get(m.payload, c.rcu_ooe, "fault_lane_mask"));
        core_.done(d);
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
        core_.cmpl(x);
      }
  }

  /// Uops, oldest first by (arrival, slot): ordering is per warp_id, so a
  /// warp whose oldest uop cannot be taken takes none behind it this cycle.
  /// A uop not taken stays in its slot, its credit unreturned.
  void takeUops() {
    const Ch &c = ch();
    const unsigned rate = kChans[c.dec_ooe].rate;
    std::set<unsigned> held;
    for (;;) {
      int best = -1;
      uint64_t when = 0;
      for (unsigned s = 0; s != rate; ++s) {
        const Receiver *r = peek(c.dec_ooe, s);
        if (!r || r->empty()) continue;
        const unsigned w = unsigned(get(r->front().payload, c.dec_ooe, "warp_id"));
        if (held.count(w)) continue;
        if (best < 0 || r->front().arrived < when) { best = int(s); when = r->front().arrived; }
      }
      if (best < 0) return;
      const Receiver *r = peek(c.dec_ooe, unsigned(best));
      const unsigned w = unsigned(get(r->front().payload, c.dec_ooe, "warp_id"));
      if (!core_.canAccept(w)) { core_.noteRefused(w); held.insert(w); continue; }
      core_.uop(decode(take(c.dec_ooe, unsigned(best))));
    }
  }

  // -- outputs --------------------------------------------------------------------------

  void sendOutputs() {
    const Ch &c = ch();
    const ooe::Outputs &o = core_.out;
    for (const ooe::Issue &x : o.issues) {
      Bits is = msgOf(c.ooe_rcu);
      put(is, c.ooe_rcu, "rob_tag", x.rob_tag);
      put(is, c.ooe_rcu, "warp_id", x.warp);
      put(is, c.ooe_rcu, "issue_mask", x.issue_mask);
      put(is, c.ooe_rcu, "phys_src", (x.psrc[0] << 8) | x.psrc[1]);
      put(is, c.ooe_rcu, "phys_src2", x.psrc[2]);
      if (x.send_imm) put(is, c.ooe_rcu, "imm", x.imm);
      put(is, c.ooe_rcu, "phys_dst", x.pdst);
      put(is, c.ooe_rcu, "phys_pred_guard", x.ppguard);
      put(is, c.ooe_rcu, "phys_pred_dst", x.ppdst);
      put(is, c.ooe_rcu, "pred_we", x.pred_we);
      put(is, c.ooe_rcu, "merge_en", x.merge);
      put(is, c.ooe_rcu, "phys_old_dst", x.pold);
      put(is, c.ooe_rcu, "phys_pred_old_dst", x.ppold);
      put(is, c.ooe_rcu, "chwidth", x.chwidth);
      // corrupt-ckpt and stale-free ride drop-negate's forced mispredict:
      // each needs a redirect.
      put(is, c.ooe_rcu, "pred_neg", x.pred_neg && k_.brk != "drop-negate" &&
                                     k_.brk != "corrupt-ckpt" && k_.brk != "stale-free");
      put(is, c.ooe_rcu, "opcode", x.copy ? kOpCopy : x.opcode);
      // skip-copy: the load issues alone, so its inactive lanes keep whatever
      // the fresh register held (A-38).
      if (x.copy && k_.brk == "skip-copy") continue;
      sendOn(c.ooe_rcu, x.port, is, x.tid);
    }
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
        put(mo, c.ooe_miu, "issue_mask", x.issue_mask);
        put(mo, c.ooe_miu, "phys_dst", x.pdst);
        put(mo, c.ooe_miu, "phys_pred", x.ppred);
        put(mo, c.ooe_miu, "disp",                 // truncated to CCV_W_DISP
            x.disp + (k_.brk == "corrupt-disp" && uidSeq(x.tid) == 6 ? 4u : 0u));
        put(mo, c.ooe_miu, "scale_en", x.scale_en);
        put(mo, c.ooe_miu, "space", x.space);
        put(mo, c.ooe_miu, "ordering", x.ordering);
        put(mo, c.ooe_miu, "chwidth", x.chwidth);
      }
      sendOn(c.ooe_miu, x.port, mo, x.tid);
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
      if (!x.epoch_only) {
        put(r, c.ooe_fet, "target_pc", x.target_pc);
        put(r, c.ooe_fet, "checkpoint_id",
            k_.brk == "corrupt-ckpt" ? (x.ckpt + 1) % ccv::prov::kBrCkpts : x.ckpt);
        put(r, c.ooe_fet, "taken_mask", x.taken_mask);
        // stale-free breaks A-58's first rule on purpose: it frees the
        // checkpoint the same cycle's redirect restores.
        if (k_.brk == "stale-free") free_mask |= uint64_t(1) << (x.slot * ccv::prov::kBrCkpts + x.ckpt);
      }
      sendOn(c.ooe_fet, 0, r, x.epoch_only ? makeUid(IdClass::kInstr, 0) : x.tid);
    }
    if (free_mask) {
      Bits f = msgOf(c.ooe_free);
      put(f, c.ooe_free, "free_mask", free_mask);
      sendOn(c.ooe_free, 0, f, makeUid(IdClass::kNone, 0));
    }
    // RAU, CRU, SYU and RCU's map: in S1 nothing consumes these (the RAU,
    // CRU and SYU stubs are idle on them), and no S1 kernel demotes, kills,
    // waits at a barrier or restores. A fault is a check failure here; a
    // status report is counted and dropped (docs/ooe-model.md, "S1 modes").
    for (const ooe::Fault &x : o.faults)
      k_.fail("ooe: warp %u faults at retirement (cause %u) at pc %llx", x.warp, x.cause,
              (unsigned long long)x.pc);
    if (!o.status.empty()) core_.counters["s1.status_dropped"] += o.status.size();
    if (!o.maps.empty() || !o.drained.empty() || !o.bars.empty() || !o.kill_acks.empty())
      k_.fail("ooe: a map, drained, barrier or kill ack with no S1 consumer");
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
      ++k_.retired;
      k_.retire_order.push_back(uidSeq(r.tid));
      if (r.exit) k_.exited = true;
      if (r.warp == 0 && r.writes_gpr) k_.rat0[r.dst] = r.pnew;   // the final compare's map
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
